# Appendix D: Performance Optimization Deep Dive

Welcome to Appendix D! This comprehensive guide takes you deep into the performance optimization techniques that separate good apps from great ones. You'll learn advanced profiling, memory management, rendering optimization, and production-ready performance monitoring strategies that will ensure your TaskFlow app runs smoothly on every device.

---

## Table of Contents

1. [Performance Profiling & Measurement](#performance-profiling--measurement)
2. [Rendering Optimization Strategies](#rendering-optimization-strategies)
3. [Memory Management Deep Dive](#memory-management-deep-dive)
4. [JavaScript Thread Optimization](#javascript-thread-optimization)
5. [Native Performance Optimization](#native-performance-optimization)
6. [Network & Data Optimization](#network--data-optimization)
7. [Bundle Size Optimization](#bundle-size-optimization)
8. [Startup Performance](#startup-performance)
9. [Performance Monitoring in Production](#performance-monitoring-in-production)

---

## Performance Profiling & Measurement

### Advanced Performance Profiler

```typescript
// src/utils/performance/Profiler.ts
import { Performance } from 'react-native-performance';
import { InteractionManager } from 'react-native';

interface ProfilerConfig {
  enabled: boolean;
  logToConsole: boolean;
  reportToAnalytics: boolean;
  slowThreshold: number; // ms
}

interface ProfileData {
  name: string;
  startTime: number;
  endTime: number;
  duration: number;
  isInteractive: boolean;
  metadata?: Record<string, any>;
}

/**
 * Advanced Performance Profiler
 * 
 * This profiler provides detailed performance metrics
 * including frame timing, render times, and operation costs.
 */
export class PerformanceProfiler {
  private static instance: PerformanceProfiler;
  private profiles: ProfileData[] = [];
  private config: ProfilerConfig = {
    enabled: __DEV__,
    logToConsole: true,
    reportToAnalytics: false,
    slowThreshold: 16, // 16ms = 60fps
  };
  private frameTimings: number[] = [];
  private isMeasuringFrames = false;

  private constructor() {}

  static getInstance(): PerformanceProfiler {
    if (!PerformanceProfiler.instance) {
      PerformanceProfiler.instance = new PerformanceProfiler();
    }
    return PerformanceProfiler.instance;
  }

  /**
   * Configure the profiler
   */
  configure(config: Partial<ProfilerConfig>) {
    this.config = { ...this.config, ...config };
  }

  /**
   * Start measuring a profile
   */
  startProfile(name: string, metadata?: Record<string, any>) {
    if (!this.config.enabled) return;

    const profile: ProfileData = {
      name,
      startTime: performance.now(),
      endTime: 0,
      duration: 0,
      isInteractive: false,
      metadata,
    };

    this.profiles.push(profile);
  }

  /**
   * End measuring a profile
   */
  endProfile(name: string): number | null {
    if (!this.config.enabled) return null;

    const profile = this.profiles.find(p => p.name === name && p.endTime === 0);
    if (!profile) return null;

    profile.endTime = performance.now();
    profile.duration = profile.endTime - profile.startTime;

    // Log if slow
    if (profile.duration > this.config.slowThreshold && this.config.logToConsole) {
      console.warn(
        `⚠️ Slow operation detected: ${name} took ${profile.duration.toFixed(2)}ms`
      );
    }

    // Report to analytics
    if (this.config.reportToAnalytics) {
      // this.reportMetric(profile);
    }

    return profile.duration;
  }

  /**
   * Measure a function's execution time
   */
  measure<T>(name: string, fn: () => T, metadata?: Record<string, any>): T {
    this.startProfile(name, metadata);
    try {
      const result = fn();
      this.endProfile(name);
      return result;
    } catch (error) {
      this.endProfile(name);
      throw error;
    }
  }

  /**
   * Measure an async function
   */
  async measureAsync<T>(
    name: string,
    fn: () => Promise<T>,
    metadata?: Record<string, any>
  ): Promise<T> {
    this.startProfile(name, metadata);
    try {
      const result = await fn();
      this.endProfile(name);
      return result;
    } catch (error) {
      this.endProfile(name);
      throw error;
    }
  }

  /**
   * Measure React component render
   */
  measureRender(name: string, renderFn: () => JSX.Element): JSX.Element {
    const profiler = this;
    return (
      <React.Profiler
        id={name}
        onRender={(
          id,
          phase,
          actualDuration,
          baseDuration,
          startTime,
          commitTime,
          interactions
        ) => {
          if (actualDuration > this.config.slowThreshold) {
            console.warn(
              `⚠️ Slow render in ${id} (${phase}): ${actualDuration.toFixed(2)}ms`
            );
          }
          profiler.endProfile(`${id}-${phase}`);
        }}
      >
        {renderFn()}
      </React.Profiler>
    );
  }

  /**
   * Measure frame rate
   */
  startFrameMeasurement() {
    if (this.isMeasuringFrames) return;
    this.isMeasuringFrames = true;
    this.frameTimings = [];
    this.measureFrame();
  }

  private measureFrame() {
    if (!this.isMeasuringFrames) return;

    const start = performance.now();
    requestAnimationFrame(() => {
      const end = performance.now();
      const duration = end - start;
      this.frameTimings.push(duration);

      if (duration > 16.67) {
        // Frame drop
        console.warn(`⚠️ Frame drop: ${duration.toFixed(2)}ms`);
      }

      this.measureFrame();
    });
  }

  stopFrameMeasurement(): { avgFPS: number; drops: number; droppedFrames: number[] } {
    this.isMeasuringFrames = false;
    const avgDuration = this.frameTimings.reduce((a, b) => a + b, 0) / this.frameTimings.length;
    const drops = this.frameTimings.filter(t => t > 16.67);
    
    return {
      avgFPS: 1000 / avgDuration,
      drops: drops.length,
      droppedFrames: drops,
    };
  }

  /**
   * Get all profiles
   */
  getProfiles(): ProfileData[] {
    return this.profiles;
  }

  /**
   * Clear all profiles
   */
  clearProfiles() {
    this.profiles = [];
  }
}

export const profiler = PerformanceProfiler.getInstance();

/**
 * Performance HOC for measuring component renders
 */
export function withPerformanceMonitoring<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  name: string
) {
  return function PerformanceMonitoredComponent(props: P) {
    React.useEffect(() => {
      profiler.startProfile(`${name}-mount`);
      return () => {
        profiler.endProfile(`${name}-mount`);
      };
    }, []);

    return <WrappedComponent {...props} />;
  };
}
```

### Performance Timeline Visualization

```typescript
// src/utils/performance/TimelineVisualizer.ts
import React from 'react';
import { View, Text, StyleSheet, Dimensions, ScrollView } from 'react-native';
import { profiler, ProfileData } from './Profiler';

interface TimelineVisualizerProps {
  profiles: ProfileData[];
  height?: number;
  width?: number;
}

/**
 * Performance Timeline Visualizer
 * 
 * This component visualizes performance profiles
 * for debugging and optimization.
 */
export const TimelineVisualizer: React.FC<TimelineVisualizerProps> = ({
  profiles,
  height = 200,
  width = Dimensions.get('window').width - 32,
}) => {
  const maxDuration = Math.max(...profiles.map(p => p.duration), 1);
  const totalTime = profiles.reduce((sum, p) => sum + p.duration, 0);

  return (
    <View style={[styles.container, { height }]}>
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <View style={[styles.timeline, { width: Math.max(width, profiles.length * 20) }]}>
          {profiles.map((profile, index) => {
            const barHeight = (profile.duration / maxDuration) * (height - 40);
            const isSlow = profile.duration > 16;

            return (
              <View key={index} style={styles.barContainer}>
                <View
                  style={[
                    styles.bar,
                    {
                      height: Math.max(barHeight, 2),
                      backgroundColor: isSlow ? '#e74c3c' : '#3498db',
                    },
                  ]}
                />
                <Text style={styles.barLabel} numberOfLines={1}>
                  {profile.name}
                </Text>
                <Text style={styles.barDuration}>
                  {profile.duration.toFixed(1)}ms
                </Text>
              </View>
            );
          })}
        </View>
      </ScrollView>
      
      <View style={styles.legend}>
        <View style={styles.legendItem}>
          <View style={[styles.legendDot, { backgroundColor: '#3498db' }]} />
          <Text style={styles.legendText}>Normal</Text>
        </View>
        <View style={styles.legendItem}>
          <View style={[styles.legendDot, { backgroundColor: '#e74c3c' }]} />
          <Text style={styles.legendText}>Slow (&gt;16ms)</Text>
        </View>
        <View style={styles.legendItem}>
          <Text style={styles.legendText}>Total: {totalTime.toFixed(1)}ms</Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: 12,
    margin: 8,
  },
  timeline: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingBottom: 20,
  },
  barContainer: {
    alignItems: 'center',
    marginHorizontal: 4,
    width: 20,
  },
  bar: {
    width: 12,
    borderRadius: 2,
    minHeight: 2,
  },
  barLabel: {
    fontSize: 8,
    color: '#7f8c8d',
    marginTop: 4,
    textAlign: 'center',
    width: 60,
  },
  barDuration: {
    fontSize: 8,
    color: '#2c3e50',
    fontWeight: '600',
    marginTop: 2,
  },
  legend: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 8,
    gap: 16,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  legendDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  legendText: {
    fontSize: 10,
    color: '#7f8c8d',
  },
});
```

---

## Rendering Optimization Strategies

### Advanced Render Optimization

```typescript
// src/utils/performance/RenderOptimizer.ts
import React, { useMemo, useCallback, useRef, useState, useEffect } from 'react';
import { useUpdateEffect } from 'react-use';

/**
 * Render Optimization Utilities
 * 
 * This provides advanced patterns for reducing unnecessary re-renders:
 * - Selective re-rendering with selectors
 * - Render batching
 * - Debounced updates
 * - Virtualized rendering with viewport tracking
 */

/**
 * Selector pattern - Only update when selected data changes
 */
export function useSelector<T, S>(
  store: { getState: () => T },
  selector: (state: T) => S
): S {
  const [selected, setSelected] = useState(() => selector(store.getState()));
  
  useEffect(() => {
    // Subscribe to store changes
    const unsubscribe = (() => {
      // In Zustand, you'd use the store's subscribe method
      // For this example, we'll use a simple interval
      const interval = setInterval(() => {
        const newValue = selector(store.getState());
        if (newValue !== selected) {
          setSelected(newValue);
        }
      }, 100);
      
      return () => clearInterval(interval);
    })();
    
    return unsubscribe;
  }, [store, selector]);
  
  return selected;
}

/**
 * Render batching - Batch multiple state updates
 */
export function useBatchUpdates() {
  const [batch, setBatch] = useState<Record<string, any>>({});
  const timerRef = useRef<NodeJS.Timeout>();
  
  const addUpdate = useCallback((key: string, value: any) => {
    setBatch(prev => ({ ...prev, [key]: value }));
    
    // Clear existing timer
    if (timerRef.current) {
      clearTimeout(timerRef.current);
    }
    
    // Schedule batch commit
    timerRef.current = setTimeout(() => {
      const updates = { ...batch };
      setBatch({});
      // Apply all updates
      // In a real app, you'd update state here
    }, 16); // One frame delay
  }, [batch]);
  
  return { addUpdate };
}

/**
 * Debounced component - Only update after a delay
 */
export function withDebouncedUpdates<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  delay: number = 300
) {
  return function DebouncedComponent(props: P) {
    const [debouncedProps, setDebouncedProps] = useState(props);
    const timerRef = useRef<NodeJS.Timeout>();
    
    useUpdateEffect(() => {
      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }
      
      timerRef.current = setTimeout(() => {
        setDebouncedProps(props);
      }, delay);
    }, [props]);
    
    return <WrappedComponent {...debouncedProps} />;
  };
}

/**
 * Virtualized list with viewport tracking
 */
interface VirtualItem {
  id: string;
  height: number;
  offset: number;
}

export function useVirtualizedList<T extends { id: string }>(
  items: T[],
  itemHeight: number,
  windowSize: number = 10
) {
  const [scrollPosition, setScrollPosition] = useState(0);
  const [visibleItems, setVisibleItems] = useState<T[]>([]);
  
  useEffect(() => {
    const startIndex = Math.floor(scrollPosition / itemHeight);
    const endIndex = Math.min(
      startIndex + windowSize,
      items.length
    );
    
    setVisibleItems(items.slice(startIndex, endIndex));
  }, [scrollPosition, items, itemHeight, windowSize]);
  
  const handleScroll = useCallback((offset: number) => {
    setScrollPosition(offset);
  }, []);
  
  const totalHeight = items.length * itemHeight;
  const paddingTop = Math.floor(scrollPosition / itemHeight) * itemHeight;
  
  return {
    visibleItems,
    totalHeight,
    paddingTop,
    onScroll: handleScroll,
  };
}

/**
 * Render guard - Prevent unnecessary renders
 */
export function withRenderGuard<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  shouldUpdate: (prev: P, next: P) => boolean = (prev, next) => 
    JSON.stringify(prev) !== JSON.stringify(next)
) {
  return React.memo(WrappedComponent, (prev, next) => !shouldUpdate(prev, next));
}
```

---

## Memory Management Deep Dive

### Memory Leak Detection

```typescript
// src/utils/performance/MemoryManager.ts
import { Platform, AppState } from 'react-native';
import * as Heap from 'react-native-heap';

interface MemorySnapshot {
  timestamp: number;
  heapUsed: number;
  heapTotal: number;
  external: number;
  allocations: number;
}

/**
 * Advanced Memory Manager
 * 
 * This provides comprehensive memory management:
 * - Leak detection
 * - Memory pressure handling
 * - Cache management
 * - Heap snapshots
 */
export class MemoryManager {
  private static instance: MemoryManager;
  private snapshots: MemorySnapshot[] = [];
  private maxSnapshots = 100;
  private isRecording = false;
  private appState = 'active';
  private memoryWarningThreshold = 0.8; // 80%

  private constructor() {
    // Monitor app state
    AppState.addEventListener('change', this.handleAppStateChange.bind(this));
    
    // Monitor memory warnings
    if (Platform.OS === 'ios') {
      // iOS memory warnings
      // @ts-ignore - iOS specific
      global?.notifyMemoryWarning = this.handleMemoryWarning.bind(this);
    }
  }

  static getInstance(): MemoryManager {
    if (!MemoryManager.instance) {
      MemoryManager.instance = new MemoryManager();
    }
    return MemoryManager.instance;
  }

  /**
   * Start recording memory snapshots
   */
  startRecording(interval: number = 5000) {
    this.isRecording = true;
    this.snapshots = [];
    
    const record = () => {
      if (!this.isRecording) return;
      
      this.takeSnapshot();
      setTimeout(record, interval);
    };
    
    record();
  }

  /**
   * Stop recording
   */
  stopRecording() {
    this.isRecording = false;
  }

  /**
   * Take a memory snapshot
   */
  private takeSnapshot() {
    // In React Native, we can't directly access heap stats
    // This is a simulation - in production, use react-native-heap or similar
    
    const snapshot: MemorySnapshot = {
      timestamp: Date.now(),
      heapUsed: this.estimateHeapUsed(),
      heapTotal: this.estimateHeapTotal(),
      external: this.estimateExternalMemory(),
      allocations: 0,
    };
    
    this.snapshots.push(snapshot);
    
    // Limit snapshots
    if (this.snapshots.length > this.maxSnapshots) {
      this.snapshots.shift();
    }
    
    // Check for memory growth
    this.detectMemoryLeaks();
  }

  /**
   * Estimate heap usage (simulated)
   */
  private estimateHeapUsed(): number {
    // @ts-ignore - Memory info available in some RN versions
    if (global.performance?.memory) {
      // @ts-ignore
      return global.performance.memory.usedJSHeapSize;
    }
    // Fallback - rough estimate
    return 0;
  }

  /**
   * Estimate total heap
   */
  private estimateHeapTotal(): number {
    // @ts-ignore
    if (global.performance?.memory) {
      // @ts-ignore
      return global.performance.memory.totalJSHeapSize;
    }
    return 0;
  }

  /**
   * Estimate external memory
   */
  private estimateExternalMemory(): number {
    // @ts-ignore
    if (global.performance?.memory) {
      // @ts-ignore
      return global.performance.memory.external;
    }
    return 0;
  }

  /**
   * Detect potential memory leaks
   */
  private detectMemoryLeaks() {
    if (this.snapshots.length < 10) return;
    
    const recent = this.snapshots.slice(-5);
    const avgGrowth = this.calculateGrowthRate(recent);
    
    if (avgGrowth > 0.1) { // 10% growth per snapshot
      console.warn(`⚠️ Possible memory leak detected: ${(avgGrowth * 100).toFixed(1)}% growth`);
    }
  }

  /**
   * Calculate growth rate
   */
  private calculateGrowthRate(snapshots: MemorySnapshot[]): number {
    if (snapshots.length < 2) return 0;
    
    const first = snapshots[0];
    const last = snapshots[snapshots.length - 1];
    
    if (first.heapUsed === 0) return 0;
    
    return (last.heapUsed - first.heapUsed) / first.heapUsed / snapshots.length;
  }

  /**
   * Handle app state changes
   */
  private handleAppStateChange(state: string) {
    this.appState = state;
    
    if (state === 'background') {
      // Clear caches when app goes to background
      this.clearCaches();
    }
  }

  /**
   * Handle memory warning
   */
  private handleMemoryWarning() {
    console.warn('⚠️ Memory warning received');
    this.clearCaches();
    
    // Force garbage collection if available
    if (global.gc) {
      global.gc();
    }
  }

  /**
   * Clear caches
   */
  clearCaches() {
    // Clear image cache
    // Clear React Native cache
    // Clear local storage
    console.log('🧹 Clearing caches');
  }

  /**
   * Get memory statistics
   */
  getMemoryStats() {
    if (this.snapshots.length === 0) return null;
    
    const last = this.snapshots[this.snapshots.length - 1];
    const growth = this.calculateGrowthRate(this.snapshots.slice(-10));
    
    return {
      ...last,
      growthRate: growth,
      snapshotCount: this.snapshots.length,
      appState: this.appState,
      memoryPressure: last.heapUsed / last.heapTotal,
    };
  }

  /**
   * Get leak detection report
   */
  getLeakReport() {
    if (this.snapshots.length < 2) return null;
    
    const sorted = [...this.snapshots];
    sorted.sort((a, b) => a.timestamp - b.timestamp);
    
    const first = sorted[0];
    const last = sorted[sorted.length - 1];
    
    const totalGrowth = last.heapUsed - first.heapUsed;
    const isLeaking = totalGrowth > 0 && this.calculateGrowthRate(sorted.slice(-5)) > 0.05;
    
    return {
      isLeaking,
      totalGrowth: totalGrowth,
      growthPercentage: (totalGrowth / first.heapUsed) * 100,
      duration: (last.timestamp - first.timestamp) / 1000, // seconds
      suggestions: this.getLeakSuggestions(isLeaking),
    };
  }

  /**
   * Get leak suggestions
   */
  private getLeakSuggestions(isLeaking: boolean): string[] {
    if (!isLeaking) return [];
    
    return [
      'Check for event listeners not being cleaned up',
      'Verify useEffect cleanup functions',
      'Check for subscriptions and intervals',
      'Ensure large objects are being garbage collected',
      'Check for reference cycles in state',
    ];
  }
}

export const memoryManager = MemoryManager.getInstance();
```

---

## JavaScript Thread Optimization

### Optimizing JavaScript Execution

```typescript
// src/utils/performance/ThreadOptimizer.ts
import { InteractionManager, AppState } from 'react-native';

/**
 * JavaScript Thread Optimization
 * 
 * This provides strategies for optimizing
 * JavaScript thread performance:
 * - Task scheduling
 * - Heavy operation offloading
 * - Interaction priority
 */

export class ThreadOptimizer {
  private static instance: ThreadOptimizer;
  private taskQueue: Array<{ fn: () => void; priority: 'high' | 'normal' | 'low' }> = [];
  private isProcessing = false;

  private constructor() {
    // Process queue on idle
    this.scheduleProcessing();
  }

  static getInstance(): ThreadOptimizer {
    if (!ThreadOptimizer.instance) {
      ThreadOptimizer.instance = new ThreadOptimizer();
    }
    return ThreadOptimizer.instance;
  }

  /**
   * Schedule a task with priority
   */
  scheduleTask(fn: () => void, priority: 'high' | 'normal' | 'low' = 'normal') {
    this.taskQueue.push({ fn, priority });
  }

  /**
   * Schedule a task to run after interactions
   */
  scheduleAfterInteraction(fn: () => void) {
    InteractionManager.runAfterInteractions(fn);
  }

  /**
   * Schedule a task to run at idle
   */
  scheduleAtIdle(fn: () => void) {
    if (this.isProcessing) {
      this.scheduleTask(fn, 'low');
      return;
    }
    
    requestIdleCallback(() => {
      fn();
    });
  }

  /**
   * Process tasks in priority order
   */
  private processQueue() {
    if (this.isProcessing) return;
    if (this.taskQueue.length === 0) return;
    
    this.isProcessing = true;
    
    // Sort by priority
    this.taskQueue.sort((a, b) => {
      const priorities = { high: 0, normal: 1, low: 2 };
      return priorities[a.priority] - priorities[b.priority];
    });
    
    // Process high priority tasks immediately
    while (this.taskQueue.length > 0) {
      const task = this.taskQueue.shift()!;
      try {
        task.fn();
      } catch (error) {
        console.error('Task execution error:', error);
      }
    }
    
    this.isProcessing = false;
  }

  /**
   * Schedule queue processing
   */
  private scheduleProcessing() {
    setInterval(() => {
      this.processQueue();
    }, 100);
  }

  /**
   * Offload heavy computation
   */
  async offloadComputation<T>(
    computation: () => T,
    onComplete: (result: T) => void
  ) {
    // In production, use a separate thread/worker
    // For React Native, consider using react-native-workers
    
    this.scheduleTask(() => {
      try {
        const result = computation();
        this.scheduleTask(() => onComplete(result), 'high');
      } catch (error) {
        console.error('Computation error:', error);
      }
    }, 'normal');
  }

  /**
   * Batch updates to reduce render cycles
   */
  batchUpdates(updates: Array<() => void>) {
    this.scheduleTask(() => {
      // Batch all updates
      updates.forEach(update => update());
    }, 'high');
  }
}

export const threadOptimizer = ThreadOptimizer.getInstance();

/**
 * Hook for scheduling tasks
 */
export const useThreadOptimizer = () => {
  const schedule = threadOptimizer.scheduleTask.bind(threadOptimizer);
  const scheduleAfterInteraction = threadOptimizer.scheduleAfterInteraction.bind(threadOptimizer);
  const scheduleAtIdle = threadOptimizer.scheduleAtIdle.bind(threadOptimizer);
  const offload = threadOptimizer.offloadComputation.bind(threadOptimizer);
  
  return { schedule, scheduleAfterInteraction, scheduleAtIdle, offload };
};
```

---

## Network & Data Optimization

### Advanced Data Caching

```typescript
// src/utils/performance/DataOptimizer.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Cache } from 'react-native-cache';

interface CacheConfig {
  maxSize: number;
  maxAge: number;
  storage: AsyncStorage;
}

interface CacheEntry<T> {
  data: T;
  timestamp: number;
  expiresAt: number;
  etag?: string;
}

/**
 * Advanced Data Caching System
 * 
 * This provides comprehensive data caching:
 * - In-memory cache
 * - Persistent cache
 * - Stale-while-revalidate
 * - Cache invalidation
 * - Optimistic updates
 */
export class DataOptimizer {
  private static instance: DataOptimizer;
  private memoryCache = new Map<string, CacheEntry<any>>();
  private persistentCache: any; // Use react-native-cache or similar
  
  private constructor() {
    this.setupPersistentCache();
  }

  static getInstance(): DataOptimizer {
    if (!DataOptimizer.instance) {
      DataOptimizer.instance = new DataOptimizer();
    }
    return DataOptimizer.instance;
  }

  /**
   * Setup persistent cache
   */
  private async setupPersistentCache() {
    this.persistentCache = new Cache({
      maxSize: 50 * 1024 * 1024, // 50MB
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      storage: AsyncStorage,
    });
  }

  /**
   * Get data from cache with stale-while-revalidate
   */
  async getWithStaleRevalidate<T>(
    key: string,
    fetchFn: () => Promise<T>,
    maxAge: number = 5 * 60 * 1000 // 5 minutes
  ): Promise<T> {
    const cached = await this.getFromCache<T>(key);
    
    // Return cached data if not expired
    if (cached && cached.expiresAt > Date.now()) {
      // Revalidate in background
      this.revalidate(key, fetchFn);
      return cached.data;
    }
    
    // Cache expired or not found - fetch fresh
    try {
      const data = await fetchFn();
      await this.setCache(key, data, maxAge);
      return data;
    } catch (error) {
      // If fetch fails and we have stale cache, return it
      if (cached) {
        console.warn('Using stale cache for:', key);
        return cached.data;
      }
      throw error;
    }
  }

  /**
   * Get from cache
   */
  async getFromCache<T>(key: string): Promise<CacheEntry<T> | null> {
    // Check memory cache first
    const memoryEntry = this.memoryCache.get(key);
    if (memoryEntry) {
      return memoryEntry as CacheEntry<T>;
    }
    
    // Check persistent cache
    try {
      const persistentEntry = await AsyncStorage.getItem(`cache_${key}`);
      if (persistentEntry) {
        const entry = JSON.parse(persistentEntry);
        this.memoryCache.set(key, entry);
        return entry;
      }
    } catch (error) {
      console.error('Cache get error:', error);
    }
    
    return null;
  }

  /**
   * Set cache
   */
  async setCache<T>(key: string, data: T, maxAge: number) {
    const entry: CacheEntry<T> = {
      data,
      timestamp: Date.now(),
      expiresAt: Date.now() + maxAge,
    };
    
    // Set in memory cache
    this.memoryCache.set(key, entry);
    
    // Set in persistent cache
    try {
      await AsyncStorage.setItem(`cache_${key}`, JSON.stringify(entry));
    } catch (error) {
      console.error('Cache set error:', error);
    }
  }

  /**
   * Revalidate cache in background
   */
  private async revalidate<T>(key: string, fetchFn: () => Promise<T>) {
    try {
      const data = await fetchFn();
      const entry = await this.getFromCache<T>(key);
      if (entry) {
        const newEntry: CacheEntry<T> = {
          data,
          timestamp: Date.now(),
          expiresAt: entry.expiresAt,
        };
        await this.setCache(key, data, entry.expiresAt - entry.timestamp);
      }
    } catch (error) {
      console.error('Revalidation failed:', error);
    }
  }

  /**
   * Invalidate cache
   */
  async invalidateCache(key: string) {
    this.memoryCache.delete(key);
    await AsyncStorage.removeItem(`cache_${key}`);
  }

  /**
   * Clear all cache
   */
  async clearAllCache() {
    this.memoryCache.clear();
    // Clear persistent cache
    const keys = await AsyncStorage.getAllKeys();
    const cacheKeys = keys.filter(key => key.startsWith('cache_'));
    await AsyncStorage.multiRemove(cacheKeys);
  }

  /**
   * Optimistic update - update UI immediately, revert on failure
   */
  async optimisticUpdate<T>(
    key: string,
    optimisticData: T,
    serverUpdate: () => Promise<T>
  ): Promise<T> {
    // Save current cache
    const oldCache = await this.getFromCache<T>(key);
    
    // Apply optimistic update
    await this.setCache(key, optimisticData, 1000);
    
    try {
      // Perform server update
      const serverData = await serverUpdate();
      await this.setCache(key, serverData, 5 * 60 * 1000);
      return serverData;
    } catch (error) {
      // Revert to old cache
      if (oldCache) {
        await this.setCache(key, oldCache.data, oldCache.expiresAt - oldCache.timestamp);
      }
      throw error;
    }
  }
}

export const dataOptimizer = DataOptimizer.getInstance();
```

---

## Bundle Size Optimization

### Advanced Bundle Analysis

```typescript
// src/utils/performance/BundleOptimizer.ts
/**
 * Bundle Size Optimization Strategies
 * 
 * This provides comprehensive bundle optimization:
 * - Code splitting
 * - Tree shaking
 * - Dependency analysis
 * - Lazy loading
 */

export class BundleOptimizer {
  private static instance: BundleOptimizer;

  static getInstance(): BundleOptimizer {
    if (!BundleOptimizer.instance) {
      BundleOptimizer.instance = new BundleOptimizer();
    }
    return BundleOptimizer.instance;
  }

  /**
   * Lazy load a component
   */
  lazyComponent<T extends React.ComponentType<any>>(
    importFn: () => Promise<{ default: T }>
  ) {
    return React.lazy(importFn);
  }

  /**
   * Dynamic import for code splitting
   */
  async importModule<T>(path: string): Promise<T> {
    // @ts-ignore - Webpack dynamic import
    return import(path);
  }

  /**
   * Preload a module
   */
  preloadModule(path: string) {
    // @ts-ignore - Webpack prefetch
    import(/* webpackPrefetch: true */ path);
  }

  /**
   * Prefetch a module
   */
  prefetchModule(path: string) {
    // @ts-ignore - Webpack prefetch
    import(/* webpackPrefetch: true, webpackChunkName: "prefetch" */ path);
  }

  /**
   * Analyze bundle size
   */
  analyzeBundle(): {
    totalSize: number;
    dependencies: Record<string, number>;
    suggestions: string[];
  } {
    // In production, use tools like source-map-explorer
    // This is a placeholder
    return {
      totalSize: 0,
      dependencies: {},
      suggestions: [
        'Remove unused dependencies',
        'Replace large libraries with smaller alternatives',
        'Enable tree shaking in webpack',
        'Use code splitting for routes',
      ],
    };
  }

  /**
   * Get dependency size
   */
  async getDependencySize(packageName: string): Promise<number> {
    // Implementation would use package size APIs
    return 0;
  }

  /**
   * Suggest alternative smaller packages
   */
  getAlternativePackage(packageName: string): string | null {
    const alternatives: Record<string, string> = {
      'moment': 'dayjs',
      'lodash': 'lodash-es',
      'axios': 'ky',
      'react-native-mmkv': 'react-native-mmkv',
    };
    
    return alternatives[packageName] || null;
  }
}

export const bundleOptimizer = BundleOptimizer.getInstance();
```

---

## Startup Performance

### Startup Optimization Strategies

```typescript
// src/utils/performance/StartupOptimizer.ts
import { SplashScreen } from 'expo-splash-screen';
import * as Updates from 'expo-updates';
import { Platform, AppState } from 'react-native';

/**
 * Startup Performance Optimization
 * 
 * This provides strategies for optimizing app startup:
 * - Splash screen management
 * - Preloading
 * - Lazy initialization
 * - App state management
 */

export class StartupOptimizer {
  private static instance: StartupOptimizer;
  private isInitialized = false;
  private startTime = 0;

  private constructor() {
    this.startTime = performance.now();
  }

  static getInstance(): StartupOptimizer {
    if (!StartupOptimizer.instance) {
      StartupOptimizer.instance = new StartupOptimizer();
    }
    return StartupOptimizer.instance;
  }

  /**
   * Initialize app with splash screen
   */
  async initializeApp() {
    // Keep splash screen visible
    await SplashScreen.preventAutoHideAsync();
    
    // Initialize critical services
    await this.initializeCriticalServices();
    
    // Hide splash screen
    await SplashScreen.hideAsync();
    
    this.isInitialized = true;
    
    // Report startup time
    const startupTime = performance.now() - this.startTime;
    console.log(`🚀 Startup time: ${startupTime.toFixed(2)}ms`);
    
    // Initialize non-critical services
    this.initializeNonCriticalServices();
  }

  /**
   * Initialize critical services
   */
  private async initializeCriticalServices() {
    // Load authentication state
    // Initialize database
    // Initialize crash reporting
    // Load critical configuration
  }

  /**
   * Initialize non-critical services
   */
  private initializeNonCriticalServices() {
    // Lazy initialize in background
    const initialize = () => {
      // Load analytics
      // Initialize push notifications
      // Prefetch data
    };
    
    if (this.isInitialized) {
      setTimeout(initialize, 500);
    } else {
      // Wait for app to be ready
      AppState.addEventListener('change', (state) => {
        if (state === 'active') {
          setTimeout(initialize, 500);
        }
      });
    }
  }

  /**
   * Preload screens
   */
  preloadScreens(screens: Array<{ component: React.ComponentType<any>; props?: any }>) {
    // Preload screens in the background
    setTimeout(() => {
      screens.forEach(({ component, props }) => {
        // Pre-render component
        try {
          // Use React.Profiler to measure rendering
        } catch (error) {
          console.error('Preload error:', error);
        }
      });
    }, 1000);
  }

  /**
   * Check for updates
   */
  async checkForUpdates() {
    try {
      const update = await Updates.checkForUpdateAsync();
      if (update.isAvailable) {
        await Updates.fetchUpdateAsync();
        return true;
      }
    } catch (error) {
      console.error('Update check error:', error);
    }
    return false;
  }

  /**
   * Get startup performance metrics
   */
  getStartupMetrics() {
    return {
      startupTime: performance.now() - this.startTime,
      isInitialized: this.isInitialized,
      platform: Platform.OS,
      version: Updates.manifest?.version,
    };
  }
}

export const startupOptimizer = StartupOptimizer.getInstance();
```

---

## Performance Monitoring in Production

### Production Performance Monitoring

```typescript
// src/utils/performance/ProductionMonitor.ts
import { Analytics } from 'expo-analytics';
import { Platform } from 'react-native';

interface PerformanceMetric {
  name: string;
  value: number;
  tags?: Record<string, string>;
  timestamp: number;
}

interface PerformanceAlert {
  metric: string;
  threshold: number;
  currentValue: number;
  severity: 'warning' | 'critical';
}

/**
 * Production Performance Monitoring
 * 
 * This provides real-time performance monitoring
 * for production apps:
 * - Custom metrics
 * - Performance alerts
 * - Crash reporting
 * - User experience monitoring
 */

export class ProductionMonitor {
  private static instance: ProductionMonitor;
  private metrics: PerformanceMetric[] = [];
  private alerts: PerformanceAlert[] = [];
  private lastReport = 0;
  private reportInterval = 60000; // 1 minute

  private constructor() {
    // Start periodic reporting
    setInterval(this.reportMetrics.bind(this), this.reportInterval);
  }

  static getInstance(): ProductionMonitor {
    if (!ProductionMonitor.instance) {
      ProductionMonitor.instance = new ProductionMonitor();
    }
    return ProductionMonitor.instance;
  }

  /**
   * Track a performance metric
   */
  trackMetric(name: string, value: number, tags?: Record<string, string>) {
    const metric: PerformanceMetric = {
      name,
      value,
      tags: {
        ...tags,
        platform: Platform.OS,
      },
      timestamp: Date.now(),
    };
    
    this.metrics.push(metric);
    
    // Check thresholds
    this.checkThresholds(metric);
    
    // Limit memory usage
    if (this.metrics.length > 10000) {
      this.metrics = this.metrics.slice(-5000);
    }
  }

  /**
   * Track screen load time
   */
  trackScreenLoad(screenName: string, duration: number) {
    this.trackMetric(`screen_${screenName}_load`, duration, {
      screen: screenName,
      type: 'load',
    });
  }

  /**
   * Track network request
   */
  trackNetworkRequest(endpoint: string, duration: number, success: boolean) {
    this.trackMetric('network_request', duration, {
      endpoint,
      success: success.toString(),
    });
  }

  /**
   * Track user interaction
   */
  trackInteraction(interaction: string, duration: number) {
    this.trackMetric(`interaction_${interaction}`, duration);
  }

  /**
   * Check performance thresholds
   */
  private checkThresholds(metric: PerformanceMetric) {
    const thresholds: Record<string, { warning: number; critical: number }> = {
      'network_request': { warning: 2000, critical: 5000 },
      'screen_*_load': { warning: 1000, critical: 3000 },
      'interaction_*': { warning: 500, critical: 1000 },
    };
    
    // Check matching thresholds
    Object.entries(thresholds).forEach(([pattern, threshold]) => {
      if (this.matchesPattern(metric.name, pattern)) {
        const severity = 
          metric.value > threshold.critical ? 'critical' as const :
          metric.value > threshold.warning ? 'warning' as const : null;
        
        if (severity) {
          this.alerts.push({
            metric: metric.name,
            threshold: severity === 'critical' ? threshold.critical : threshold.warning,
            currentValue: metric.value,
            severity,
          });
          
          // Log alert
          console.warn(
            `⚠️ Performance alert: ${metric.name} = ${metric.value}ms (${severity})`
          );
        }
      }
    });
  }

  /**
   * Match pattern with wildcards
   */
  private matchesPattern(name: string, pattern: string): boolean {
    if (pattern.includes('*')) {
      const regex = new RegExp(pattern.replace('*', '.*'));
      return regex.test(name);
    }
    return name === pattern;
  }

  /**
   * Report metrics to analytics
   */
  private reportMetrics() {
    if (this.metrics.length === 0) return;
    
    // Group metrics by name
    const grouped = this.metrics.reduce((acc, metric) => {
      if (!acc[metric.name]) {
        acc[metric.name] = [];
      }
      acc[metric.name].push(metric.value);
      return acc;
    }, {} as Record<string, number[]>);
    
    // Calculate statistics
    Object.entries(grouped).forEach(([name, values]) => {
      const avg = values.reduce((a, b) => a + b, 0) / values.length;
      const max = Math.max(...values);
      const min = Math.min(...values);
      const p95 = this.percentile(values, 95);
      
      // Report to analytics
      console.log(`📊 ${name}: avg=${avg.toFixed(2)}ms, p95=${p95.toFixed(2)}ms`);
    });
    
    this.metrics = [];
  }

  /**
   * Calculate percentile
   */
  private percentile(values: number[], percentile: number): number {
    const sorted = [...values].sort((a, b) => a - b);
    const index = Math.ceil((percentile / 100) * sorted.length) - 1;
    return sorted[index] || 0;
  }

  /**
   * Get alerts
   */
  getAlerts(): PerformanceAlert[] {
    return this.alerts;
  }

  /**
   * Clear alerts
   */
  clearAlerts() {
    this.alerts = [];
  }

  /**
   * Get current metrics summary
   */
  getMetricsSummary() {
    if (this.metrics.length === 0) return null;
    
    const grouped = this.metrics.reduce((acc, metric) => {
      if (!acc[metric.name]) {
        acc[metric.name] = [];
      }
      acc[metric.name].push(metric.value);
      return acc;
    }, {} as Record<string, number[]>);
    
    return Object.entries(grouped).map(([name, values]) => ({
      name,
      count: values.length,
      avg: values.reduce((a, b) => a + b, 0) / values.length,
      max: Math.max(...values),
      min: Math.min(...values),
      p95: this.percentile(values, 95),
    }));
  }
}

export const productionMonitor = ProductionMonitor.getInstance();
```

---

This appendix provides a comprehensive deep dive into performance optimization strategies used in production-grade React Native applications. By implementing these techniques, your TaskFlow app will run smoothly on all devices and provide an exceptional user experience.
