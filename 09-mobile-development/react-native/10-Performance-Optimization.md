# Part 4: Testing, Performance & Production Deployment
## Phase 2: Performance Optimization

Welcome to the performance optimization phase! Your TaskFlow app is feature-rich, beautifully designed, and thoroughly tested. Now it's time to make it blazing fast. In this phase, you'll learn to identify performance bottlenecks, optimize rendering, reduce memory usage, and create a buttery-smooth experience that users will love.

---

## Target 1: Understanding React Native Performance

**The Target:** Master the performance architecture of React Native.

**The Concept:** React Native performance is about managing the bridge between JavaScript and native code, optimizing render cycles, and ensuring smooth 60fps animations. Think of it like a highway—too much traffic (re-renders) causes jams (jank).

### Performance Architecture Overview

```typescript
// src/utils/performance/architecture.ts
/**
 * React Native Performance Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │                    JavaScript Thread                        │
 * │  ┌─────────────────────────────────────────────────────┐   │
 * │  │  React Reconciliation  │  Business Logic           │   │
 * │  │  Virtual DOM Diffing   │  State Updates            │   │
 * │  └─────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────┘
 *                              │
 *                        ┌─────▼─────┐
 *                        │   Bridge  │ ← Potential Bottleneck
 *                        └─────┬─────┘
 *                              │
 * ┌─────────────────────────────────────────────────────────────┐
 * │                   Native UI Thread                         │
 * │  ┌─────────────────────────────────────────────────────┐   │
 * │  │  Layout Calculations  │  Rendering  │  Gestures    │   │
 * │  └─────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────┘
 */

export const PerformanceGuidelines = {
  // 1. Minimize Bridge Traffic
  bridgeTraffic: {
    description: 'Each call across the bridge adds overhead',
    optimization: 'Batch updates, use JSI when possible',
    metrics: 'Measure bridge call frequency in React DevTools',
  },

  // 2. Reduce Re-renders
  reRenders: {
    description: 'Unnecessary component updates waste CPU cycles',
    optimization: 'Use memo, useMemo, useCallback, PureComponent',
    metrics: 'React DevTools profiler shows render counts',
  },

  // 3. Optimize List Rendering
  listRendering: {
    description: 'Large lists are a common performance killer',
    optimization: 'Use FlatList with getItemLayout, virtualization',
    metrics: 'FPS drops during scrolling indicate issues',
  },

  // 4. Manage Memory
  memory: {
    description: 'Memory leaks cause crashes and sluggishness',
    optimization: 'Clean up subscriptions, listeners, and timers',
    metrics: 'Monitor memory usage in Xcode/Android Studio',
  },

  // 5. Optimize Images
  images: {
    description: 'Large images consume memory and bandwidth',
    optimization: 'Resize, compress, use WebP format',
    metrics: 'Measure image loading time and memory usage',
  },
};
```

---

## Target 2: Performance Profiling Tools

**The Target:** Use performance profiling tools to identify bottlenecks.

**The Concept:** You can't optimize what you can't measure. Profiling tools show you exactly where your app is spending time and resources.

### Performance Monitoring Setup

```typescript
// src/utils/performance/performanceMonitor.ts
import { Performance } from 'react-native-performance';
import { Platform } from 'react-native';

interface PerformanceMetric {
  name: string;
  startTime: number;
  endTime?: number;
  duration?: number;
  metadata?: Record<string, any>;
}

/**
 * PerformanceMonitor - Tracks app performance metrics
 * 
 * This utility helps identify performance bottlenecks
 * by measuring operation durations and tracking metrics.
 */
export class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private metrics: Map<string, PerformanceMetric[]> = new Map();
  private isEnabled: boolean = __DEV__;

  private constructor() {}

  static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  /**
   * Start measuring an operation
   */
  startMeasure(name: string, metadata?: Record<string, any>): void {
    if (!this.isEnabled) return;

    const metric: PerformanceMetric = {
      name,
      startTime: performance.now(),
      metadata,
    };

    if (!this.metrics.has(name)) {
      this.metrics.set(name, []);
    }
    this.metrics.get(name)!.push(metric);

    console.log(`⏱️ Started measuring: ${name}`);
  }

  /**
   * Stop measuring and record duration
   */
  stopMeasure(name: string): number | null {
    if (!this.isEnabled) return null;

    const metrics = this.metrics.get(name);
    if (!metrics || metrics.length === 0) {
      console.warn(`No metric found for: ${name}`);
      return null;
    }

    const lastMetric = metrics[metrics.length - 1];
    lastMetric.endTime = performance.now();
    lastMetric.duration = lastMetric.endTime - lastMetric.startTime;

    console.log(`⏱️ ${name} took ${lastMetric.duration.toFixed(2)}ms`);

    // Report to analytics in production
    if (!__DEV__) {
      this.reportMetric(lastMetric);
    }

    return lastMetric.duration;
  }

  /**
   * Measure a function's execution time
   */
  async measureAsync<T>(
    name: string,
    fn: () => Promise<T>,
    metadata?: Record<string, any>
  ): Promise<T> {
    this.startMeasure(name, metadata);
    try {
      const result = await fn();
      this.stopMeasure(name);
      return result;
    } catch (error) {
      this.stopMeasure(name);
      throw error;
    }
  }

  /**
   * Measure synchronous function
   */
  measureSync<T>(name: string, fn: () => T, metadata?: Record<string, any>): T {
    this.startMeasure(name, metadata);
    try {
      const result = fn();
      this.stopMeasure(name);
      return result;
    } catch (error) {
      this.stopMeasure(name);
      throw error;
    }
  }

  /**
   * Get all metrics
   */
  getMetrics(): Record<string, PerformanceMetric[]> {
    const result: Record<string, PerformanceMetric[]> = {};
    this.metrics.forEach((value, key) => {
      result[key] = value;
    });
    return result;
  }

  /**
   * Clear all metrics
   */
  clearMetrics(): void {
    this.metrics.clear();
  }

  /**
   * Report metric to analytics (production)
   */
  private reportMetric(metric: PerformanceMetric): void {
    // In production, send to analytics service
    // Example: mixpanel.track('performance_metric', metric)
    console.log(`📊 [Performance] ${metric.name}: ${metric.duration}ms`);
  }

  /**
   * Enable/disable monitoring
   */
  setEnabled(enabled: boolean): void {
    this.isEnabled = enabled;
  }
}

export const perfMonitor = PerformanceMonitor.getInstance();
```

### Using Performance Monitor in Components

```typescript
// src/components/PerformanceExample.tsx
import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { perfMonitor } from '../utils/performance/performanceMonitor';

export const PerformanceExample: React.FC = () => {
  const [data, setData] = useState<string[]>([]);

  useEffect(() => {
    // Measure data loading
    const loadData = async () => {
      const result = await perfMonitor.measureAsync(
        'loadData',
        async () => {
          // Simulate loading
          await new Promise(resolve => setTimeout(resolve, 500));
          return Array.from({ length: 100 }, (_, i) => `Item ${i}`);
        },
        { source: 'performance_example' }
      );
      setData(result);
    };

    loadData();
  }, []);

  // Measure render performance
  perfMonitor.measureSync('renderPerformance', () => {
    // This runs during render
  });

  const renderItem = ({ item, index }: { item: string; index: number }) => {
    // Measure item rendering
    perfMonitor.measureSync(`renderItem_${index}`, () => {});
    
    return (
      <View style={styles.item}>
        <Text>{item}</Text>
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <FlatList
        data={data}
        renderItem={renderItem}
        keyExtractor={(_, index) => `item-${index}`}
        onScroll={() => {
          // Measure scroll performance
          perfMonitor.startMeasure('scroll');
        }}
        onScrollEndDrag={() => {
          perfMonitor.stopMeasure('scroll');
        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  item: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e1e8ed',
  },
});
```

### React DevTools Profiling

```typescript
// src/utils/performance/devtools.ts
/**
 * React DevTools Profiler Integration
 * 
 * Enable profiling in development to identify re-render issues
 */

import { Profiler, ProfilerOnRenderCallback } from 'react';

// In App.tsx or root component
const onRenderCallback: ProfilerOnRenderCallback = (
  id,
  phase,
  actualDuration,
  baseDuration,
  startTime,
  commitTime,
  interactions
) => {
  if (actualDuration > 20) {
    // Highlight slow renders
    console.warn(
      `⚠️ Slow render detected in ${id} (${phase}): ${actualDuration.toFixed(2)}ms`
    );
  }
};

// Wrap components with Profiler
// <Profiler id="TaskList" onRender={onRenderCallback}>
//   <TaskList />
// </Profiler>
```

---

## Target 3: Optimizing Rendering Performance

**The Target:** Implement strategies to reduce unnecessary re-renders.

**The Concept:** React re-renders when state or props change. Unnecessary re-renders waste CPU cycles and cause jank. We'll use memoization, component splitting, and careful state management to minimize re-renders.

### Optimized Component Patterns

```typescript
// src/components/OptimizedTaskItem.tsx
import React, { memo, useMemo, useCallback } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

interface Task {
  id: string;
  title: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  dueDate: string;
}

interface OptimizedTaskItemProps {
  task: Task;
  onPress: (task: Task) => void;
  onToggle: (task: Task) => void;
}

/**
 * OptimizedTaskItem - Uses memo to prevent unnecessary re-renders
 * 
 * This component demonstrates:
 * - React.memo for component memoization
 * - useMemo for derived values
 * - useCallback for stable function references
 */
const OptimizedTaskItem = memo(({ task, onPress, onToggle }: OptimizedTaskItemProps) => {
  // Memoized derived values
  const priorityColor = useMemo(() => {
    switch (task.priority) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  }, [task.priority]);

  const statusIcon = useMemo(() => {
    return task.status === 'done' ? '✓' : '○';
  }, [task.status]);

  const dueDateFormatted = useMemo(() => {
    return new Date(task.dueDate).toLocaleDateString();
  }, [task.dueDate]);

  // Stable callbacks
  const handlePress = useCallback(() => {
    onPress(task);
  }, [task, onPress]);

  const handleToggle = useCallback(() => {
    onToggle(task);
  }, [task, onToggle]);

  // Only re-render if task reference changes
  // (memo compares props deeply)
  return (
    <TouchableOpacity
      style={styles.container}
      onPress={handlePress}
      activeOpacity={0.7}
    >
      <View style={[styles.priorityIndicator, { backgroundColor: priorityColor }]} />
      
      <View style={styles.content}>
        <Text style={styles.title}>{task.title}</Text>
        <Text style={styles.meta}>Due: {dueDateFormatted}</Text>
      </View>

      <TouchableOpacity style={styles.toggleButton} onPress={handleToggle}>
        <Text style={styles.toggleIcon}>{statusIcon}</Text>
      </TouchableOpacity>
    </TouchableOpacity>
  );
});

// Add display name for debugging
OptimizedTaskItem.displayName = 'OptimizedTaskItem';

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: 12,
    marginVertical: 4,
    marginHorizontal: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  priorityIndicator: {
    width: 4,
    height: 40,
    borderRadius: 2,
    marginRight: 12,
  },
  content: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    color: '#2c3e50',
  },
  meta: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 2,
  },
  toggleButton: {
    padding: 8,
  },
  toggleIcon: {
    fontSize: 20,
    color: '#3498db',
  },
});

export default OptimizedTaskItem;

// Parent component with optimized state
export const TaskList: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [filter, setFilter] = useState<'all' | 'todo' | 'done'>('all');

  // Memoize filtered tasks
  const filteredTasks = useMemo(() => {
    if (filter === 'all') return tasks;
    return tasks.filter(task => task.status === filter);
  }, [tasks, filter]);

  // Stable callbacks
  const handleTaskPress = useCallback((task: Task) => {
    // Navigate to task detail
    console.log('Task pressed:', task.id);
  }, []);

  const handleTaskToggle = useCallback((task: Task) => {
    setTasks(prev =>
      prev.map(t =>
        t.id === task.id
          ? { ...t, status: t.status === 'done' ? 'todo' : 'done' }
          : t
      )
    );
  }, []);

  return (
    <FlatList
      data={filteredTasks}
      renderItem={({ item }) => (
        <OptimizedTaskItem
          task={item}
          onPress={handleTaskPress}
          onToggle={handleTaskToggle}
        />
      )}
      keyExtractor={item => item.id}
      // Optimize FlatList rendering
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      updateCellsBatchingPeriod={50}
      windowSize={10}
      initialNumToRender={20}
    />
  );
};
```

### Component Splitting Strategy

```typescript
// src/components/SmartComponent.tsx
/**
 * Component Splitting Strategy
 * 
 * Split large components into smaller, focused components
 * to isolate re-renders and improve performance
 */

// ❌ Bad - One giant component that re-renders everything
const BadComponent = ({ user, tasks, settings, notifications }) => {
  // Everything re-renders when any prop changes
  return (
    <View>
      <UserProfile user={user} />
      <TaskList tasks={tasks} />
      <SettingsPanel settings={settings} />
      <NotificationBadge notifications={notifications} />
    </View>
  );
};

// ✅ Good - Split into smaller, memoized components
const UserProfile = memo(({ user }) => {
  // Only re-renders when user changes
  return <View>{/* User profile UI */}</View>;
});

const TaskList = memo(({ tasks }) => {
  // Only re-renders when tasks change
  return <FlatList data={tasks} renderItem={/* ... */} />;
});

const SettingsPanel = memo(({ settings }) => {
  // Only re-renders when settings change
  return <View>{/* Settings UI */}</View>;
});

const NotificationBadge = memo(({ notifications }) => {
  // Only re-renders when notifications change
  return <View>{/* Notification UI */}</View>;
});

const SmartComponent = ({ user, tasks, settings, notifications }) => {
  // Parent component doesn't re-render children unnecessarily
  return (
    <View>
      <UserProfile user={user} />
      <TaskList tasks={tasks} />
      <SettingsPanel settings={settings} />
      <NotificationBadge notifications={notifications} />
    </View>
  );
};
```

---

## Target 4: FlatList Optimization

**The Target:** Master FlatList optimization for large lists.

**The Concept:** FlatList is the workhorse of React Native lists, but it needs careful tuning to handle large datasets smoothly. We'll configure it for optimal performance.

### Optimized FlatList Configuration

```typescript
// src/components/OptimizedTaskList.tsx
import React, { useState, useCallback, useMemo, useRef } from 'react';
import {
  FlatList,
  View,
  Text,
  StyleSheet,
  ActivityIndicator,
  Platform,
  RefreshControl,
} from 'react-native';
import { OptimizedTaskItem } from './OptimizedTaskItem';

interface Task {
  id: string;
  title: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  dueDate: string;
}

interface OptimizedTaskListProps {
  tasks: Task[];
  onRefresh: () => Promise<void>;
  onLoadMore: () => Promise<void>;
  onTaskPress: (task: Task) => void;
  onTaskToggle: (task: Task) => void;
  isLoading: boolean;
  hasMore: boolean;
}

/**
 * OptimizedTaskList - Fully optimized FlatList implementation
 * 
 * This component demonstrates all FlatList optimization techniques:
 * - getItemLayout for fixed-height items
 * - windowSize and maxToRenderPerBatch
 * - removeClippedSubviews
 * - Viewability tracking
 * - Pagination
 */
export const OptimizedTaskList: React.FC<OptimizedTaskListProps> = ({
  tasks,
  onRefresh,
  onLoadMore,
  onTaskPress,
  onTaskToggle,
  isLoading,
  hasMore,
}) => {
  const [refreshing, setRefreshing] = useState(false);
  const flatListRef = useRef<FlatList>(null);

  // Fixed item height for getItemLayout optimization
  const ITEM_HEIGHT = 64; // Adjust based on your item height
  const SEPARATOR_HEIGHT = 8;

  // Memoize render item function
  const renderItem = useCallback(
    ({ item }: { item: Task }) => (
      <OptimizedTaskItem
        task={item}
        onPress={onTaskPress}
        onToggle={onTaskToggle}
      />
    ),
    [onTaskPress, onTaskToggle]
  );

  // Key extractor
  const keyExtractor = useCallback((item: Task) => item.id, []);

  // Item separator
  const ItemSeparator = useCallback(() => <View style={styles.separator} />, []);

  // List footer
  const ListFooter = useCallback(() => {
    if (!hasMore && tasks.length > 0) {
      return (
        <View style={styles.footerContainer}>
          <Text style={styles.footerText}>No more tasks</Text>
        </View>
      );
    }
    return null;
  }, [hasMore, tasks.length]);

  // Empty component
  const ListEmpty = useCallback(() => (
    <View style={styles.emptyContainer}>
      <Text style={styles.emptyEmoji}>📋</Text>
      <Text style={styles.emptyTitle}>No tasks found</Text>
      <Text style={styles.emptySubtitle}>Create your first task</Text>
    </View>
  ), []);

  // getItemLayout for fixed-height items
  const getItemLayout = useCallback(
    (_: any, index: number) => ({
      length: ITEM_HEIGHT,
      offset: (ITEM_HEIGHT + SEPARATOR_HEIGHT) * index,
      index,
    }),
    []
  );

  // Handle refresh
  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    await onRefresh();
    setRefreshing(false);
  }, [onRefresh]);

  // Handle load more (pagination)
  const handleLoadMore = useCallback(() => {
    if (!isLoading && hasMore) {
      onLoadMore();
    }
  }, [isLoading, hasMore, onLoadMore]);

  // Viewability tracking
  const viewabilityConfig = useMemo(
    () => ({
      itemVisiblePercentThreshold: 50,
      minimumViewTime: 300,
    }),
    []
  );

  const onViewableItemsChanged = useCallback(({ viewableItems }) => {
    // Log or track which items are visible
    // Useful for analytics or lazy loading
    console.log('Visible items:', viewableItems.length);
  }, []);

  // Scroll to top
  const scrollToTop = useCallback(() => {
    flatListRef.current?.scrollToOffset({ offset: 0, animated: true });
  }, []);

  return (
    <View style={styles.container}>
      <FlatList
        ref={flatListRef}
        data={tasks}
        renderItem={renderItem}
        keyExtractor={keyExtractor}
        ItemSeparatorComponent={ItemSeparator}
        ListFooterComponent={ListFooter}
        ListEmptyComponent={ListEmpty}
        getItemLayout={getItemLayout}
        
        // Performance optimizations
        removeClippedSubviews={Platform.OS === 'android'}
        maxToRenderPerBatch={10}
        updateCellsBatchingPeriod={50}
        windowSize={10}
        initialNumToRender={20}
        pagingEnabled={false}
        scrollEventThrottle={16}
        decelerationRate="normal"
        
        // Scroll to top functionality
        showsVerticalScrollIndicator={true}
        contentContainerStyle={styles.contentContainer}
        
        // Pull to refresh
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            colors={['#3498db']}
            tintColor="#3498db"
            progressBackgroundColor="#ffffff"
          />
        }
        
        // Viewability
        viewabilityConfig={viewabilityConfig}
        onViewableItemsChanged={onViewableItemsChanged}
        
        // Pagination
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.5}
        
        // Keyboard handling
        keyboardShouldPersistTaps="handled"
        keyboardDismissMode="on-drag"
      />
      
      {/* Scroll to top button */}
      {tasks.length > 10 && (
        <View style={styles.scrollToTopContainer}>
          <TouchableOpacity style={styles.scrollToTopButton} onPress={scrollToTop}>
            <Text style={styles.scrollToTopIcon}>↑</Text>
          </TouchableOpacity>
        </View>
      )}
      
      {/* Loading indicator for pagination */}
      {isLoading && tasks.length > 0 && (
        <View style={styles.loadingMoreContainer}>
          <ActivityIndicator size="small" color="#3498db" />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  contentContainer: {
    paddingVertical: 8,
    paddingBottom: 20,
  },
  separator: {
    height: 8,
  },
  footerContainer: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 14,
    color: '#95a5a6',
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyEmoji: {
    fontSize: 48,
    marginBottom: 16,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#7f8c8d',
  },
  scrollToTopContainer: {
    position: 'absolute',
    bottom: 20,
    right: 20,
  },
  scrollToTopButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#3498db',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 4,
  },
  scrollToTopIcon: {
    fontSize: 20,
    color: '#ffffff',
  },
  loadingMoreContainer: {
    paddingVertical: 16,
    alignItems: 'center',
  },
});
```

---

## Target 5: Image Optimization

**The Target:** Implement image optimization for faster loading and lower memory usage.

**The Concept:** Images are often the heaviest assets in your app. We'll resize, compress, and cache images for optimal performance.

### Image Optimization Service

```typescript
// src/utils/imageOptimization.ts
import { Image } from 'react-native';
import * as ImageManipulator from 'expo-image-manipulator';
import * as FileSystem from 'expo-file-system';

interface ImageOptimizationOptions {
  maxWidth?: number;
  maxHeight?: number;
  quality?: number;
  compress?: number;
  base64?: boolean;
}

/**
 * ImageOptimization - Optimizes images for mobile
 * 
 * This service resizes, compresses, and caches images
 * to reduce memory usage and improve performance.
 */
export class ImageOptimization {
  private static cache: Map<string, string> = new Map();

  /**
   * Optimize an image from URI
   */
  static async optimizeImage(
    uri: string,
    options: ImageOptimizationOptions = {}
  ): Promise<string> {
    const cacheKey = `${uri}-${JSON.stringify(options)}`;
    
    // Check cache
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey)!;
    }

    try {
      // Get image dimensions
      const dimensions = await this.getImageDimensions(uri);
      
      // Calculate optimal dimensions
      const targetWidth = options.maxWidth || dimensions.width;
      const targetHeight = options.maxHeight || dimensions.height;
      
      // Resize if needed
      let optimizedUri = uri;
      if (dimensions.width > targetWidth || dimensions.height > targetHeight) {
        const manipResult = await ImageManipulator.manipulateAsync(
          uri,
          [
            {
              resize: {
                width: Math.min(dimensions.width, targetWidth),
                height: Math.min(dimensions.height, targetHeight),
              },
            },
          ],
          {
            compress: options.compress || 0.7,
            format: ImageManipulator.SaveFormat.JPEG,
            base64: options.base64 || false,
          }
        );
        optimizedUri = manipResult.uri;
      }

      // Cache result
      this.cache.set(cacheKey, optimizedUri);
      
      // Limit cache size
      if (this.cache.size > 100) {
        const firstKey = this.cache.keys().next().value;
        this.cache.delete(firstKey);
      }

      return optimizedUri;
    } catch (error) {
      console.error('Image optimization failed:', error);
      return uri; // Return original on failure
    }
  }

  /**
   * Get image dimensions
   */
  static getImageDimensions(uri: string): Promise<{ width: number; height: number }> {
    return new Promise((resolve, reject) => {
      Image.getSize(
        uri,
        (width, height) => resolve({ width, height }),
        (error) => reject(error)
      );
    });
  }

  /**
   * Calculate appropriate image size for device
   */
  static getTargetDimensions(): { width: number; height: number } {
    const { width, height } = Dimensions.get('window');
    
    // Scale images for retina displays
    const scale = PixelRatio.get();
    const targetWidth = Math.floor(width * scale * 0.8);
    const targetHeight = Math.floor(height * scale * 0.6);
    
    return {
      width: Math.min(targetWidth, 1200),
      height: Math.min(targetHeight, 800),
    };
  }

  /**
   * Preload images for smoother scrolling
   */
  static preloadImages(uris: string[]): Promise<void[]> {
    return Promise.all(
      uris.map(uri => {
        return new Promise((resolve) => {
          Image.prefetch(uri)
            .then(() => resolve())
            .catch(() => resolve());
        });
      })
    );
  }

  /**
   * Clear image cache
   */
  static clearCache(): void {
    this.cache.clear();
  }
}
```

### Optimized Image Component

```typescript
// src/components/OptimizedImage.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Image,
  ImageProps,
  ActivityIndicator,
  StyleSheet,
  Dimensions,
  Platform,
} from 'react-native';
import { ImageOptimization } from '../utils/imageOptimization';

interface OptimizedImageProps extends Omit<ImageProps, 'source'> {
  uri: string;
  placeholderUri?: string;
  resizeMode?: 'cover' | 'contain' | 'stretch' | 'center';
  showLoader?: boolean;
  maxWidth?: number;
  maxHeight?: number;
  quality?: number;
}

/**
 * OptimizedImage - Image component with automatic optimization
 * 
 * This component handles image loading with:
 * - Automatic resizing
 * - Progressive loading (placeholder → optimized)
 * - Loading indicators
 * - Error handling
 */
export const OptimizedImage: React.FC<OptimizedImageProps> = ({
  uri,
  placeholderUri,
  resizeMode = 'cover',
  showLoader = true,
  maxWidth,
  maxHeight,
  quality = 0.7,
  style,
  ...props
}) => {
  const [optimizedUri, setOptimizedUri] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    let isMounted = true;

    const optimizeImage = async () => {
      try {
        setIsLoading(true);
        setHasError(false);

        // Get target dimensions
        const targetWidth = maxWidth || ImageOptimization.getTargetDimensions().width;
        const targetHeight = maxHeight || ImageOptimization.getTargetDimensions().height;

        // Optimize image
        const optimized = await ImageOptimization.optimizeImage(uri, {
          maxWidth: targetWidth,
          maxHeight: targetHeight,
          compress: quality,
        });

        if (isMounted) {
          setOptimizedUri(optimized);
          setIsLoading(false);
        }
      } catch (error) {
        console.error('Error optimizing image:', error);
        if (isMounted) {
          setHasError(true);
          setIsLoading(false);
          // Fall back to original URI
          setOptimizedUri(uri);
        }
      }
    };

    optimizeImage();

    return () => {
      isMounted = false;
    };
  }, [uri, maxWidth, maxHeight, quality]);

  // Show placeholder while loading
  if (isLoading && placeholderUri) {
    return (
      <Image
        source={{ uri: placeholderUri }}
        style={style}
        resizeMode={resizeMode}
        blurRadius={20}
        {...props}
      />
    );
  }

  return (
    <View style={[styles.container, style]}>
      {optimizedUri && (
        <Image
          source={{ uri: optimizedUri }}
          style={styles.image}
          resizeMode={resizeMode}
          onLoad={() => setIsLoading(false)}
          onError={() => {
            setHasError(true);
            setIsLoading(false);
            // Try original URI on error
            if (optimizedUri !== uri) {
              setOptimizedUri(uri);
            }
          }}
          {...props}
        />
      )}
      
      {isLoading && showLoader && (
        <View style={styles.loaderContainer}>
          <ActivityIndicator size="small" color="#3498db" />
        </View>
      )}
      
      {hasError && !isLoading && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>🖼️</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    overflow: 'hidden',
    backgroundColor: '#f8f9fa',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  loaderContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.05)',
  },
  errorContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f1f2f6',
  },
  errorText: {
    fontSize: 24,
  },
});
```

---

## Target 6: Memory Management

**The Target:** Implement memory management strategies to prevent leaks.

**The Concept:** Memory leaks occur when your app holds onto objects it no longer needs. This causes gradual performance degradation and eventually crashes.

### Memory Management Utilities

```typescript
// src/utils/memoryManagement.ts
import { useEffect, useRef } from 'react';
import { InteractionManager, AppState } from 'react-native';

/**
 * useCleanup - Hook for managing component cleanup
 * 
 * This hook handles cleanup of timers, subscriptions,
 * and other resources when components unmount.
 */
export function useCleanup() {
  const cleanupFunctions = useRef<Array<() => void>>([]);
  const isMounted = useRef(true);

  useEffect(() => {
    isMounted.current = true;
    
    return () => {
      isMounted.current = false;
      // Execute all cleanup functions
      cleanupFunctions.current.forEach(fn => {
        try {
          fn();
        } catch (error) {
          console.error('Cleanup error:', error);
        }
      });
      cleanupFunctions.current = [];
    };
  }, []);

  const addCleanup = (fn: () => void) => {
    cleanupFunctions.current.push(fn);
  };

  return { addCleanup, isMounted };
}

/**
 * MemoryManager - Handles app-wide memory management
 * 
 * This service manages memory-intensive operations
 * and provides tools to prevent memory leaks.
 */
export class MemoryManager {
  private static instance: MemoryManager;
  private intervals: NodeJS.Timeout[] = [];
  private timeouts: NodeJS.Timeout[] = [];
  private listeners: Array<{ remove: () => void }> = [];
  private isAppInForeground = true;

  private constructor() {
    this.setupAppStateListener();
  }

  static getInstance(): MemoryManager {
    if (!MemoryManager.instance) {
      MemoryManager.instance = new MemoryManager();
    }
    return MemoryManager.instance;
  }

  /**
   * Setup app state listener to pause/resume operations
   */
  private setupAppStateListener() {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      this.isAppInForeground = nextAppState === 'active';
      
      if (this.isAppInForeground) {
        console.log('📱 App foreground - resuming operations');
      } else {
        console.log('📱 App background - pausing operations');
      }
    });

    this.listeners.push(subscription);
  }

  /**
   * Register a timer for automatic cleanup
   */
  registerInterval(interval: NodeJS.Timeout) {
    this.intervals.push(interval);
    return interval;
  }

  /**
   * Register a timeout for automatic cleanup
   */
  registerTimeout(timeout: NodeJS.Timeout) {
    this.timeouts.push(timeout);
    return timeout;
  }

  /**
   * Schedule an operation with InteractionManager
   * (Runs after animations/completed)
   */
  scheduleAfterInteraction(callback: () => void): void {
    InteractionManager.runAfterInteractions(callback);
  }

  /**
   * Run operation when app is in foreground
   */
  runWhenForeground(operation: () => void): void {
    if (this.isAppInForeground) {
      operation();
    } else {
      // Wait for foreground
      const subscription = AppState.addEventListener('change', (state) => {
        if (state === 'active') {
          operation();
          subscription.remove();
        }
      });
      this.listeners.push(subscription);
    }
  }

  /**
   * Clean up all registered resources
   */
  cleanup(): void {
    // Clear intervals
    this.intervals.forEach(clearInterval);
    this.intervals = [];

    // Clear timeouts
    this.timeouts.forEach(clearTimeout);
    this.timeouts = [];

    // Remove listeners
    this.listeners.forEach(listener => listener.remove());
    this.listeners = [];
  }

  /**
   * Check memory usage (development only)
   */
  async checkMemoryUsage(): Promise<{ used: number; total: number; percentage: number }> {
    if (!__DEV__) {
      return { used: 0, total: 0, percentage: 0 };
    }

    // @ts-ignore - Memory info is available in React Native
    const memory = global.performance?.memory;
    if (memory) {
      return {
        used: Math.round(memory.usedJSHeapSize / (1024 * 1024)),
        total: Math.round(memory.totalJSHeapSize / (1024 * 1024)),
        percentage: (memory.usedJSHeapSize / memory.totalJSHeapSize) * 100,
      };
    }

    return { used: 0, total: 0, percentage: 0 };
  }
}

export const memoryManager = MemoryManager.getInstance();
```

### Memory-Efficient Component Pattern

```typescript
// src/components/MemoryOptimizedComponent.tsx
import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing } from 'react-native';
import { useCleanup, memoryManager } from '../utils/memoryManagement';

/**
 * MemoryOptimizedComponent - Demonstrates memory management
 * 
 * This component shows how to properly manage:
 * - Animations (cleanup)
 * - Intervals (cleanup)
 * - Subscriptions (cleanup)
 * - Heavy operations (schedule after interactions)
 */
export const MemoryOptimizedComponent: React.FC = () => {
  const { addCleanup, isMounted } = useCleanup();
  const animation = useRef(new Animated.Value(0)).current;

  // Setup animation with cleanup
  useEffect(() => {
    const startAnimation = () => {
      Animated.loop(
        Animated.timing(animation, {
          toValue: 1,
          duration: 1000,
          easing: Easing.linear,
          useNativeDriver: true,
        })
      ).start();
    };

    // Schedule animation after interactions
    memoryManager.scheduleAfterInteraction(startAnimation);

    // Cleanup animation
    addCleanup(() => {
      animation.stopAnimation();
      animation.removeAllListeners();
    });
  }, []);

  // Setup interval with cleanup
  useEffect(() => {
    const interval = memoryManager.registerInterval(
      setInterval(() => {
        if (isMounted.current) {
          console.log('⏰ Interval tick');
        }
      }, 5000)
    );

    addCleanup(() => {
      clearInterval(interval);
    });
  }, [isMounted]);

  // Handle app state changes
  useEffect(() => {
    // Run expensive operation when foregrounded
    memoryManager.runWhenForeground(() => {
      console.log('🔄 Running foreground operation');
    });
  }, []);

  // Check memory usage
  useEffect(() => {
    if (__DEV__) {
      const checkMemory = async () => {
        const memory = await memoryManager.checkMemoryUsage();
        console.log('💾 Memory usage:', memory);
      };
      
      const interval = setInterval(checkMemory, 30000);
      addCleanup(() => clearInterval(interval));
    }
  }, []);

  const animatedStyle = {
    transform: [
      {
        rotate: animation.interpolate({
          inputRange: [0, 1],
          outputRange: ['0deg', '360deg'],
        }),
      },
    ],
  };

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.spinner, animatedStyle]} />
      <Text style={styles.text}>Memory optimized component</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 20,
    alignItems: 'center',
  },
  spinner: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 4,
    borderColor: '#3498db',
    borderTopColor: 'transparent',
    marginBottom: 12,
  },
  text: {
    fontSize: 14,
    color: '#7f8c8d',
  },
});
```

---

## Target 7: Bundle Optimization

**The Target:** Reduce app bundle size for faster downloads and startup.

**The Concept:** Smaller bundles mean faster downloads, less storage usage, and quicker startup times. We'll analyze and optimize your bundle size.

### Bundle Analysis Configuration

```javascript
// metro.config.js
const { getDefaultConfig } = require('@expo/metro-config');

const defaultConfig = getDefaultConfig(__dirname);

module.exports = {
  ...defaultConfig,
  transformer: {
    ...defaultConfig.transformer,
    // Enable minification
    minifierConfig: {
      compress: {
        drop_console: true, // Remove console.log in production
        drop_debugger: true,
        pure_funcs: ['console.log', 'console.debug'],
      },
      mangle: true,
    },
  },
  resolver: {
    ...defaultConfig.resolver,
    // Enable tree shaking
    sourceExts: ['jsx', 'js', 'ts', 'tsx', 'json'],
  },
};
```

### Bundle Optimization Scripts

```json
// package.json - Add bundle analysis scripts
{
  "scripts": {
    "bundle:analyze": "npx expo export --platform ios --dump-sourcemap && npx source-map-explorer dist/bundles/*.js",
    "bundle:optimize": "npx expo export --platform ios --dump-sourcemap --minify",
    "bundle:size": "npx expo export --platform ios && ls -lh dist/bundles/"
  }
}
```

### Lazy Loading Implementation

```typescript
// src/navigation/LazyNavigation.tsx
import React, { lazy, Suspense } from 'react';
import { View, ActivityIndicator, StyleSheet } from 'react-native';

/**
 * LazyLoading - Dynamically import heavy components
 * 
 * This reduces initial bundle size by loading
 * screens and components only when needed.
 */

// Lazy load screens
const TaskDetailScreen = lazy(() => import('../screens/tasks/TaskDetailScreen'));
const TaskCreateScreen = lazy(() => import('../screens/tasks/TaskCreateScreen'));
const TaskEditScreen = lazy(() => import('../screens/tasks/TaskEditScreen'));
const TaskStatsScreen = lazy(() => import('../screens/tasks/TaskStatsScreen'));
const UserProfileScreen = lazy(() => import('../screens/profile/UserProfileScreen'));
const SettingsScreen = lazy(() => import('../screens/SettingsScreen'));

// Lazy load heavy components
const ImageViewer = lazy(() => import('../components/ImageViewer'));
const PDFViewer = lazy(() => import('../components/PDFViewer'));
const VideoPlayer = lazy(() => import('../components/VideoPlayer'));
const MapView = lazy(() => import('../components/MapView'));

// Loading fallback component
const LoadingFallback = () => (
  <View style={styles.loadingContainer}>
    <ActivityIndicator size="large" color="#3498db" />
  </View>
);

// Lazy wrapper component
export const LazyComponent: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <Suspense fallback={<LoadingFallback />}>
      {children}
    </Suspense>
  );
};

// Navigation with lazy loading
export const LazyTaskDetail = (props: any) => (
  <Suspense fallback={<LoadingFallback />}>
    <TaskDetailScreen {...props} />
  </Suspense>
);

export const LazyTaskCreate = (props: any) => (
  <Suspense fallback={<LoadingFallback />}>
    <TaskCreateScreen {...props} />
  </Suspense>
);

// Conditional imports for heavy features
export const ImageViewerLazy = (props: any) => {
  const [Component, setComponent] = React.useState<React.ComponentType | null>(null);

  React.useEffect(() => {
    import('../components/ImageViewer')
      .then(module => setComponent(() => module.default))
      .catch(error => console.error('Failed to load ImageViewer:', error));
  }, []);

  if (!Component) {
    return <LoadingFallback />;
  }

  return <Component {...props} />;
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
});
```

---

## Target 8: Performance Testing

**The Target:** Implement performance testing and monitoring.

**The Concept:** Continuous performance monitoring catches regressions before they reach users. We'll implement automated performance tests.

### Performance Tests

```typescript
// src/__tests__/performance/performance.test.ts
import { measurePerformance } from 'react-native-performance-testing';

describe('Performance Tests', () => {
  it('should render TaskList within performance budget', async () => {
    const tasks = Array.from({ length: 100 }, (_, i) => ({
      id: `task-${i}`,
      title: `Task ${i}`,
      priority: 'medium' as const,
      status: 'todo' as const,
      dueDate: new Date().toISOString(),
    }));

    const metrics = await measurePerformance(
      () => {
        // Render TaskList component
        render(
          <TaskList
            tasks={tasks}
            onRefresh={jest.fn()}
            onLoadMore={jest.fn()}
            onTaskPress={jest.fn()}
            onTaskToggle={jest.fn()}
            isLoading={false}
            hasMore={false}
          />
        );
      },
      {
        duration: 1000, // Performance budget
        iterations: 5, // Run multiple times for accuracy
      }
    );

    expect(metrics.average).toBeLessThan(100);
    expect(metrics.max).toBeLessThan(150);
  });

  it('should handle 1000 tasks in FlatList', async () => {
    const tasks = Array.from({ length: 1000 }, (_, i) => ({
      id: `task-${i}`,
      title: `Task ${i}`,
      priority: 'low' as const,
      status: 'todo' as const,
      dueDate: new Date().toISOString(),
    }));

    const metrics = await measurePerformance(
      () => {
        render(
          <OptimizedTaskList
            tasks={tasks}
            onRefresh={jest.fn()}
            onLoadMore={jest.fn()}
            onTaskPress={jest.fn()}
            onTaskToggle={jest.fn()}
            isLoading={false}
            hasMore={false}
          />
        );
      },
      {
        iterations: 3,
      }
    );

    expect(metrics.memory).toBeLessThan(50); // MB
    expect(metrics.fps).toBeGreaterThan(30);
  });
});
```

---

## Verification: Performance Testing

```bash
# Run performance tests
npm test -- --testPathPattern=performance

# Analyze bundle size
npm run bundle:analyze

# Check app size
npm run bundle:size

# Run React DevTools profiling
# Open React DevTools → Profiler → Start recording
# Interact with app → Stop recording → Analyze
```

### Performance Checklist

- [ ] React DevTools shows < 10ms renders
- [ ] FlatList scrolling maintains 60fps
- [ ] Memory usage < 50MB on iOS
- [ ] App bundle size < 15MB
- [ ] Startup time < 2 seconds
- [ ] No memory leaks (tested with Xcode/Android Studio)
- [ ] Images load with < 100ms delay
- [ ] Animation runs at 60fps
- [ ] No console warnings/errors
- [ ] `removeClippedSubviews` enabled on FlatLists

---

## What We've Accomplished

Congratulations! Your TaskFlow app is now performance-optimized:

1. **Profiling Tools:** Performance monitoring and measurement
2. **Rendering Optimization:** Memoization, component splitting, minimal re-renders
3. **FlatList Optimization:** Full configuration for smooth scrolling
4. **Image Optimization:** Resizing, compression, and caching
5. **Memory Management:** Proper cleanup and leak prevention
6. **Bundle Optimization:** Lazy loading and tree shaking
7. **Performance Testing:** Automated performance regression tests

### What's Next: Part 4, Phase 3 - CI/CD & App Store Deployment

*Your app is now lightning-fast and memory-efficient! Next, we'll automate builds with CI/CD and submit TaskFlow to the Apple App Store and Google Play Store. You're about to become a published developer!*
