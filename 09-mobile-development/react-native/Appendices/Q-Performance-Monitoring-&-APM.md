# Appendix Q: Performance Monitoring & APM

Welcome to Appendix Q! This comprehensive guide covers everything you need to know about implementing Application Performance Monitoring (APM) in your React Native application. You'll learn how to set up real-time monitoring, track key performance metrics, set up alerts, and maintain optimal app performance in production.

---

## Table of Contents

1. [APM Architecture](#apm-architecture)
2. [Performance Metrics](#performance-metrics)
3. [Real User Monitoring](#real-user-monitoring)
4. [Error Tracking & Reporting](#error-tracking--reporting)
5. [Custom Performance Instrumentation](#custom-performance-instrumentation)
6. [Alerting & Notification](#alerting--notification)
7. [APM Dashboard](#apm-dashboard)
8. [Performance Budgets](#performance-budgets)

---

## APM Architecture

### Complete APM Architecture

```typescript
// src/apm/architecture.ts
/**
 * Application Performance Monitoring Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     APPLICATION LAYER                          │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  User Interactions  │  API Calls  │  Screen Renders   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     INSTRUMENTATION LAYER                      │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Custom Instrumentation  │  SDK Agents  │  Hooks       │   │
 * │  │  (Manual)                │  (Auto)      │  (React)     │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     COLLECTION LAYER                          │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Metrics  │  Traces  │  Logs  │  Sessions  │  Events   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     APM PROVIDERS                              │
 * │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐    │
 * │  │   Sentry    │  │  Datadog    │  │  New Relic       │    │
 * │  │  (Errors)   │  │  (Metrics)  │  │  (APM)           │    │
 * │  └──────────────┘  └──────────────┘  └──────────────────┘    │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     ANALYTICS LAYER                           │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Dashboards  │  Alerts  │  Reports  │  Insights        │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 */

export const APMArchitecture = {
  components: {
    instrumentation: {
      sdk: 'Sentry React Native SDK',
      custom: 'Custom instrumentation via hooks',
      auto: 'Automatic instrumentation for React Navigation',
    },
    providers: {
      error: 'Sentry',
      metrics: 'Datadog',
      performance: 'New Relic',
      analytics: 'Mixpanel',
    },
    metrics: {
      client: ['App Start', 'Screen Renders', 'API Calls', 'Memory Usage'],
      server: ['API Response Time', 'Error Rate', 'Throughput'],
      business: ['User Engagement', 'Feature Adoption', 'Conversion Rate'],
    },
  },
};
```

---

## Performance Metrics

### Complete Metrics Collection

```typescript
// src/apm/MetricsCollector.ts
import * as Sentry from '@sentry/react-native';
import { Performance } from 'react-native-performance';
import { Platform } from 'react-native';

/**
 * Performance Metrics Collector
 * 
 * This collects comprehensive performance metrics:
 * - App startup time
 * - Screen render times
 * - Network request times
 * - Memory usage
 * - Frame rates
 * - Battery impact
 */

export interface PerformanceMetrics {
  appStart: number;
  screenLoad: number;
  networkRequest: number;
  memoryUsage: number;
  frameRate: number;
  cpuUsage: number;
  batteryImpact: number;
  timestamp: number;
}

export class MetricsCollector {
  private static instance: MetricsCollector;
  private metrics: PerformanceMetrics[] = [];
  private isCollecting = false;

  private constructor() {}

  static getInstance(): MetricsCollector {
    if (!MetricsCollector.instance) {
      MetricsCollector.instance = new MetricsCollector();
    }
    return MetricsCollector.instance;
  }

  /**
   * Start collecting metrics
   */
  startCollection(): void {
    if (this.isCollecting) return;
    this.isCollecting = true;

    // Start frame rate monitoring
    this.monitorFrameRate();

    // Start memory monitoring
    this.monitorMemory();

    // Start CPU monitoring
    this.monitorCPU();

    // Start battery monitoring
    this.monitorBattery();

    // Report metrics periodically
    setInterval(() => {
      this.reportMetrics();
    }, 60000); // Every minute
  }

  /**
   * Stop collecting metrics
   */
  stopCollection(): void {
    this.isCollecting = false;
  }

  /**
   * Monitor frame rate
   */
  private monitorFrameRate(): void {
    let frameCount = 0;
    let lastFrameTime = performance.now();

    const measureFrames = () => {
      if (!this.isCollecting) return;

      const now = performance.now();
      frameCount++;

      if (now - lastFrameTime >= 1000) {
        const fps = frameCount;
        frameCount = 0;
        lastFrameTime = now;

        // Report low FPS
        if (fps < 30) {
          Sentry.addBreadcrumb({
            category: 'performance',
            message: `Low FPS detected: ${fps}`,
            level: 'warning',
          });
        }

        // Store metric
        this.recordMetric('frameRate', fps);
        requestAnimationFrame(measureFrames);
      } else {
        requestAnimationFrame(measureFrames);
      }
    };

    requestAnimationFrame(measureFrames);
  }

  /**
   * Monitor memory usage
   */
  private monitorMemory(): void {
    const checkMemory = () => {
      if (!this.isCollecting) return;

      // @ts-ignore - Memory info
      if (global.performance?.memory) {
        // @ts-ignore
        const { usedJSHeapSize, totalJSHeapSize } = global.performance.memory;
        const usedMB = usedJSHeapSize / (1024 * 1024);
        const totalMB = totalJSHeapSize / (1024 * 1024);
        const percentage = (usedMB / totalMB) * 100;

        // Report high memory usage
        if (percentage > 80) {
          Sentry.addBreadcrumb({
            category: 'performance',
            message: `High memory usage: ${percentage.toFixed(1)}%`,
            level: 'warning',
          });
        }

        this.recordMetric('memoryUsage', usedMB);
      }

      setTimeout(checkMemory, 5000);
    };

    checkMemory();
  }

  /**
   * Monitor CPU usage
   */
  private monitorCPU(): void {
    let previousTime = performance.now();
    let previousUsage = 0;

    const checkCPU = () => {
      if (!this.isCollecting) return;

      // @ts-ignore - CPU info
      if (global.performance?.cpu) {
        // @ts-ignore
        const { user, system } = global.performance.cpu;
        const currentTime = performance.now();
        const timeDiff = (currentTime - previousTime) / 1000;
        const usage = (user + system - previousUsage) / timeDiff;

        this.recordMetric('cpuUsage', usage);
        previousUsage = user + system;
        previousTime = currentTime;
      }

      setTimeout(checkCPU, 5000);
    };

    checkCPU();
  }

  /**
   * Monitor battery impact
   */
  private monitorBattery(): void {
    // Battery monitoring is platform-specific
    // In production, use battery level API
    let batteryLevel = 1.0;

    const checkBattery = () => {
      if (!this.isCollecting) return;

      // @ts-ignore - Battery info
      if (navigator?.getBattery) {
        // @ts-ignore
        navigator.getBattery().then((battery: BatteryManager) => {
          batteryLevel = battery.level;
          this.recordMetric('batteryImpact', battery.level * 100);
        });
      }

      setTimeout(checkBattery, 30000);
    };

    checkBattery();
  }

  /**
   * Record a metric
   */
  private recordMetric(name: keyof PerformanceMetrics, value: number): void {
    const currentMetrics = this.metrics[this.metrics.length - 1] || {
      appStart: 0,
      screenLoad: 0,
      networkRequest: 0,
      memoryUsage: 0,
      frameRate: 0,
      cpuUsage: 0,
      batteryImpact: 0,
      timestamp: Date.now(),
    };

    currentMetrics[name] = value;
    currentMetrics.timestamp = Date.now();

    if (!this.metrics.includes(currentMetrics)) {
      this.metrics.push(currentMetrics);
    }
  }

  /**
   * Report metrics to APM providers
   */
  private reportMetrics(): void {
    if (this.metrics.length === 0) return;

    const latest = this.metrics[this.metrics.length - 1];

    // Report to Sentry
    Sentry.addBreadcrumb({
      category: 'performance',
      message: 'Performance metrics update',
      level: 'info',
      data: latest,
    });

    // Report to Datadog
    // datadog.trackMetric('app_performance', latest);

    // Report to New Relic
    // newrelic.recordCustomEvent('PerformanceMetrics', latest);

    console.log('📊 Performance Metrics:', latest);
  }

  /**
   * Get performance summary
   */
  getPerformanceSummary(): {
    average: Partial<PerformanceMetrics>;
    min: Partial<PerformanceMetrics>;
    max: Partial<PerformanceMetrics>;
    current: Partial<PerformanceMetrics>;
  } {
    if (this.metrics.length === 0) {
      return {
        average: {},
        min: {},
        max: {},
        current: {},
      };
    }

    const keys: (keyof PerformanceMetrics)[] = [
      'appStart',
      'screenLoad',
      'networkRequest',
      'memoryUsage',
      'frameRate',
      'cpuUsage',
      'batteryImpact',
    ];

    const average: any = {};
    const min: any = {};
    const max: any = {};

    keys.forEach(key => {
      const values = this.metrics
        .filter(m => m[key] !== undefined)
        .map(m => m[key]);

      if (values.length > 0) {
        average[key] = values.reduce((a, b) => a + b, 0) / values.length;
        min[key] = Math.min(...values);
        max[key] = Math.max(...values);
      }
    });

    return {
      average,
      min,
      max,
      current: this.metrics[this.metrics.length - 1],
    };
  }

  /**
   * Clear metrics
   */
  clearMetrics(): void {
    this.metrics = [];
  }
}

export const metricsCollector = MetricsCollector.getInstance();
```

---

## Real User Monitoring

### RUM Implementation

```typescript
// src/apm/RealUserMonitoring.ts
import * as Sentry from '@sentry/react-native';
import { AppState } from 'react-native';

/**
 * Real User Monitoring (RUM)
 * 
 * This provides real user monitoring capabilities:
 * - User session tracking
 * - User journey mapping
 * - User experience scores
 * - Custom user metrics
 */

export interface UserSession {
  id: string;
  userId?: string;
  startTime: number;
  endTime?: number;
  duration?: number;
  screens: string[];
  interactions: number;
  errors: number;
  events: Array<{
    type: string;
    timestamp: number;
    data?: any;
  }>;
}

export class RealUserMonitoring {
  private static instance: RealUserMonitoring;
  private currentSession: UserSession | null = null;
  private sessions: UserSession[] = [];
  private appState = 'active';

  private constructor() {
    this.setupAppStateListener();
  }

  static getInstance(): RealUserMonitoring {
    if (!RealUserMonitoring.instance) {
      RealUserMonitoring.instance = new RealUserMonitoring();
    }
    return RealUserMonitoring.instance;
  }

  /**
   * Setup app state listener
   */
  private setupAppStateListener() {
    AppState.addEventListener('change', (nextAppState) => {
      if (nextAppState === 'active' && this.appState !== 'active') {
        // App came to foreground - start new session if needed
        if (!this.currentSession || this.currentSession.endTime) {
          this.startSession();
        }
      } else if (nextAppState === 'background' && this.appState === 'active') {
        // App went to background - end session
        if (this.currentSession) {
          this.endSession();
        }
      }
      this.appState = nextAppState;
    });
  }

  /**
   * Start a user session
   */
  startSession(userId?: string): void {
    const session: UserSession = {
      id: `session-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
      userId,
      startTime: Date.now(),
      screens: [],
      interactions: 0,
      errors: 0,
      events: [],
    };

    this.currentSession = session;
    this.sessions.push(session);

    Sentry.setContext('session', {
      id: session.id,
      startTime: new Date(session.startTime).toISOString(),
    });

    console.log(`📊 Session started: ${session.id}`);
  }

  /**
   * End a user session
   */
  endSession(): void {
    if (!this.currentSession) return;

    this.currentSession.endTime = Date.now();
    this.currentSession.duration =
      this.currentSession.endTime - this.currentSession.startTime;

    // Report session to analytics
    Sentry.addBreadcrumb({
      category: 'session',
      message: `Session ended: ${this.currentSession.id}`,
      level: 'info',
      data: {
        duration: this.currentSession.duration,
        screens: this.currentSession.screens.length,
        interactions: this.currentSession.interactions,
        errors: this.currentSession.errors,
      },
    });

    console.log(`📊 Session ended: ${this.currentSession.id}`);

    this.currentSession = null;
  }

  /**
   * Track screen view
   */
  trackScreenView(screenName: string): void {
    if (this.currentSession) {
      this.currentSession.screens.push(screenName);
      this.currentSession.events.push({
        type: 'screen_view',
        timestamp: Date.now(),
        data: { screen: screenName },
      });
    }

    Sentry.addBreadcrumb({
      category: 'navigation',
      message: `Screen view: ${screenName}`,
      level: 'info',
    });
  }

  /**
   * Track user interaction
   */
  trackInteraction(type: string, data?: any): void {
    if (this.currentSession) {
      this.currentSession.interactions++;
      this.currentSession.events.push({
        type: 'interaction',
        timestamp: Date.now(),
        data: { type, ...data },
      });
    }
  }

  /**
   * Track error
   */
  trackError(error: Error, context?: any): void {
    if (this.currentSession) {
      this.currentSession.errors++;
      this.currentSession.events.push({
        type: 'error',
        timestamp: Date.now(),
        data: {
          message: error.message,
          stack: error.stack,
          ...context,
        },
      });
    }
  }

  /**
   * Track custom event
   */
  trackCustomEvent(eventName: string, data?: any): void {
    if (this.currentSession) {
      this.currentSession.events.push({
        type: eventName,
        timestamp: Date.now(),
        data,
      });
    }
  }

  /**
   * Get session summary
   */
  getSessionSummary(): {
    currentSession: UserSession | null;
    totalSessions: number;
    averageSessionDuration: number;
    totalErrors: number;
    topScreens: Array<{ screen: string; count: number }>;
  } {
    // Calculate summary statistics
    const completedSessions = this.sessions.filter(s => s.endTime);

    const averageDuration = completedSessions.length > 0
      ? completedSessions.reduce((sum, s) => sum + (s.duration || 0), 0) / completedSessions.length
      : 0;

    // Count screen views
    const screenCount: Record<string, number> = {};
    this.sessions.forEach(session => {
      session.screens.forEach(screen => {
        screenCount[screen] = (screenCount[screen] || 0) + 1;
      });
    });

    const topScreens = Object.entries(screenCount)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([screen, count]) => ({ screen, count }));

    const totalErrors = this.sessions.reduce((sum, s) => sum + s.errors, 0);

    return {
      currentSession: this.currentSession,
      totalSessions: this.sessions.length,
      averageSessionDuration: averageDuration,
      totalErrors,
      topScreens,
    };
  }

  /**
   * Get session by ID
   */
  getSession(id: string): UserSession | undefined {
    return this.sessions.find(s => s.id === id);
  }

  /**
   * Clear sessions
   */
  clearSessions(): void {
    this.sessions = [];
    this.currentSession = null;
  }
}

export const rum = RealUserMonitoring.getInstance();
```

---

## Error Tracking & Reporting

### Error Reporting System

```typescript
// src/apm/ErrorReporting.ts
import * as Sentry from '@sentry/react-native';
import { Platform } from 'react-native';
import { ErrorBoundary } from 'react-error-boundary';

/**
 * Error Tracking & Reporting
 * 
 * This provides comprehensive error tracking:
 * - Error capturing
 * - Error categorization
 * - Error aggregation
 * - Error reporting
 * - Error analytics
 */

export interface ErrorReport {
  id: string;
  type: 'fatal' | 'error' | 'warning' | 'info';
  message: string;
  stack?: string;
  timestamp: number;
  platform: string;
  appVersion: string;
  deviceModel?: string;
  osVersion?: string;
  user?: {
    id: string;
    email?: string;
  };
  context?: Record<string, any>;
  breadcrumbs?: Array<{
    timestamp: number;
    type: string;
    message: string;
    data?: any;
  }>;
}

export class ErrorReporting {
  private static instance: ErrorReporting;
  private errors: ErrorReport[] = [];
  private isEnabled = true;

  private constructor() {
    this.setupErrorHandlers();
  }

  static getInstance(): ErrorReporting {
    if (!ErrorReporting.instance) {
      ErrorReporting.instance = new ErrorReporting();
    }
    return ErrorReporting.instance;
  }

  /**
   * Setup global error handlers
   */
  private setupErrorHandlers(): void {
    // Global error handler
    ErrorUtils.setGlobalHandler((error, isFatal) => {
      this.captureError(error, {
        fatal: isFatal,
        platform: Platform.OS,
        appVersion: '1.0.0', // In production, use actual version
      });
    });

    // Unhandled promise rejections
    // @ts-ignore - React Native global
    global.ErrorUtils.setGlobalHandler((error: Error) => {
      this.captureError(error, {
        type: 'unhandled_promise_rejection',
        platform: Platform.OS,
      });
    });

    // React error boundary handler
    // In production, use ErrorBoundary from react-error-boundary
    console.log('✅ Error reporting initialized');
  }

  /**
   * Capture an error
   */
  captureError(error: Error | string, context?: Record<string, any>): void {
    if (!this.isEnabled) return;

    const errorMessage = typeof error === 'string' ? error : error.message;
    const stack = typeof error === 'object' ? error.stack : undefined;

    const report: ErrorReport = {
      id: `err-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
      type: context?.fatal ? 'fatal' : 'error',
      message: errorMessage,
      stack,
      timestamp: Date.now(),
      platform: Platform.OS,
      appVersion: '1.0.0',
      context,
    };

    // Store error
    this.errors.push(report);

    // Limit stored errors
    if (this.errors.length > 1000) {
      this.errors = this.errors.slice(-500);
    }

    // Report to Sentry
    Sentry.captureException(error, {
      tags: {
        platform: Platform.OS,
        fatal: context?.fatal ? 'yes' : 'no',
        type: context?.type || 'error',
      },
      extra: context,
    });

    // Add breadcrumb
    Sentry.addBreadcrumb({
      category: 'error',
      message: errorMessage,
      level: context?.fatal ? 'fatal' : 'error',
      data: context,
    });

    // Log to console
    console.error('❌ Error captured:', errorMessage, context);
  }

  /**
   * Report error to monitoring service
   */
  reportError(error: ErrorReport): void {
    // In production, send to external services
    // This would include: Sentry, Datadog, New Relic, etc.
    console.log(`📤 Reporting error: ${error.id}`);
  }

  /**
   * Get error statistics
   */
  getErrorStats(): {
    total: number;
    byType: Record<string, number>;
    byPlatform: Record<string, number>;
    byVersion: Record<string, number>;
    recentErrors: ErrorReport[];
  } {
    const byType: Record<string, number> = {};
    const byPlatform: Record<string, number> = {};
    const byVersion: Record<string, number> = {};

    this.errors.forEach(error => {
      byType[error.type] = (byType[error.type] || 0) + 1;
      byPlatform[error.platform] = (byPlatform[error.platform] || 0) + 1;
      byVersion[error.appVersion] = (byVersion[error.appVersion] || 0) + 1;
    });

    return {
      total: this.errors.length,
      byType,
      byPlatform,
      byVersion,
      recentErrors: this.errors.slice(-10),
    };
  }

  /**
   * Clear errors
   */
  clearErrors(): void {
    this.errors = [];
  }

  /**
   * Enable/disable error reporting
   */
  setEnabled(enabled: boolean): void {
    this.isEnabled = enabled;
  }

  /**
   * Get all errors
   */
  getErrors(): ErrorReport[] {
    return this.errors;
  }
}

export const errorReporting = ErrorReporting.getInstance();

/**
 * React Error Boundary
 */
export const ErrorBoundaryComponent: React.FC<{
  children: React.ReactNode;
  fallback?: React.ReactNode;
}> = ({ children, fallback }) => {
  return (
    <ErrorBoundary
      fallback={fallback || <FallbackComponent />}
      onError={(error, componentStack) => {
        errorReporting.captureError(error, {
          componentStack,
          type: 'react_error_boundary',
        });
      }}
    >
      {children}
    </ErrorBoundary>
  );
};

const FallbackComponent = () => (
  <View style={styles.container}>
    <Text style={styles.icon}>😅</Text>
    <Text style={styles.title}>Something went wrong</Text>
    <Text style={styles.message}>
      We've been notified and will fix this soon.
    </Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  icon: {
    fontSize: 48,
    marginBottom: 16,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 8,
  },
  message: {
    fontSize: 14,
    color: '#7f8c8d',
    textAlign: 'center',
  },
});
```

---

## Custom Performance Instrumentation

### Instrumentation Utilities

```typescript
// src/apm/Instrumentation.ts
import * as Sentry from '@sentry/react-native';

/**
 * Custom Performance Instrumentation
 * 
 * This provides custom performance instrumentation:
 * - Custom traces
 * - Custom spans
 * - Operation timing
 * - Performance marks
 */

export class Instrumentation {
  private static instance: Instrumentation;
  private operations: Map<string, { start: number; end?: number }> = new Map();
  private marks: Map<string, number> = new Map();

  private constructor() {}

  static getInstance(): Instrumentation {
    if (!Instrumentation.instance) {
      Instrumentation.instance = new Instrumentation();
    }
    return Instrumentation.instance;
  }

  /**
   * Start a transaction
   */
  startTransaction(name: string, op?: string): string {
    const transaction = Sentry.startTransaction({
      name,
      op,
    });

    const transactionId = `tx-${Date.now()}`;
    this.operations.set(transactionId, {
      start: Date.now(),
    });

    return transactionId;
  }

  /**
   * Finish a transaction
   */
  finishTransaction(id: string, status: 'ok' | 'error' = 'ok'): void {
    const operation = this.operations.get(id);
    if (!operation) return;

    operation.end = Date.now();
    const duration = operation.end - operation.start;

    // Report to Sentry
    Sentry.addBreadcrumb({
      category: 'performance',
      message: `Transaction ${id} completed`,
      level: 'info',
      data: { duration, status },
    });

    this.operations.delete(id);
  }

  /**
   * Start a span
   */
  startSpan(name: string, parentId?: string): string {
    const spanId = `span-${Date.now()}`;
    // In production, create child span of parent transaction
    return spanId;
  }

  /**
   * Finish a span
   */
  finishSpan(id: string): void {
    // In production, finish span and report duration
  }

  /**
   * Mark a point in time
   */
  mark(name: string): void {
    this.marks.set(name, performance.now());

    Sentry.addBreadcrumb({
      category: 'performance',
      message: `Mark: ${name}`,
      level: 'info',
    });
  }

  /**
   * Measure between marks
   */
  measure(name: string, startMark: string, endMark: string): void {
    const start = this.marks.get(startMark);
    const end = this.marks.get(endMark);

    if (start && end) {
      const duration = end - start;

      // Report measurement
      Sentry.addBreadcrumb({
        category: 'performance',
        message: `Measure: ${name}`,
        level: 'info',
        data: { duration },
      });
    }
  }

  /**
   * Time an async operation
   */
  async timeOperation<T>(name: string, operation: () => Promise<T>): Promise<T> {
    const start = performance.now();
    try {
      const result = await operation();
      const duration = performance.now() - start;

      Sentry.addBreadcrumb({
        category: 'performance',
        message: `Operation: ${name}`,
        level: 'info',
        data: { duration },
      });

      return result;
    } catch (error) {
      const duration = performance.now() - start;

      Sentry.addBreadcrumb({
        category: 'performance',
        message: `Operation failed: ${name}`,
        level: 'warning',
        data: { duration },
      });

      throw error;
    }
  }

  /**
   * Time a synchronous operation
   */
  timeSyncOperation<T>(name: string, operation: () => T): T {
    const start = performance.now();
    try {
      const result = operation();
      const duration = performance.now() - start;

      Sentry.addBreadcrumb({
        category: 'performance',
        message: `Operation: ${name}`,
        level: 'info',
        data: { duration },
      });

      return result;
    } catch (error) {
      const duration = performance.now() - start;

      Sentry.addBreadcrumb({
        category: 'performance',
        message: `Operation failed: ${name}`,
        level: 'warning',
        data: { duration },
      });

      throw error;
    }
  }

  /**
   * Clear marks
   */
  clearMarks(): void {
    this.marks.clear();
  }

  /**
   * Clear operations
   */
  clearOperations(): void {
    this.operations.clear();
  }
}

export const instrumentation = Instrumentation.getInstance();
```

---

## Alerting & Notification

### Alert Configuration

```typescript
// src/apm/Alerts.ts
/**
 * APM Alerting
 * 
 * This defines alert configurations for various scenarios:
 * - Performance degradation
 * - Error spikes
 * - Memory issues
 * - Startup time
 * - Custom metrics
 */

export interface AlertRule {
  id: string;
  name: string;
  metric: string;
  threshold: number;
  severity: 'warning' | 'critical';
  condition: 'above' | 'below';
  cooldown: number; // seconds
  channels: ('slack' | 'email' | 'pagerduty')[];
}

export class AlertManager {
  private static instance: AlertManager;
  private rules: AlertRule[] = [];
  private triggeredAlerts: Map<string, number> = new Map();

  private constructor() {
    this.initializeDefaultRules();
  }

  static getInstance(): AlertManager {
    if (!AlertManager.instance) {
      AlertManager.instance = new AlertManager();
    }
    return AlertManager.instance;
  }

  /**
   * Initialize default alert rules
   */
  private initializeDefaultRules(): void {
    // Crash rate alert
    this.addRule({
      id: 'crash_rate',
      name: 'High Crash Rate',
      metric: 'crash_rate',
      threshold: 0.05, // 5%
      severity: 'critical',
      condition: 'above',
      cooldown: 300,
      channels: ['slack', 'pagerduty'],
    });

    // API error rate alert
    this.addRule({
      id: 'api_error_rate',
      name: 'High API Error Rate',
      metric: 'api_error_rate',
      threshold: 0.10, // 10%
      severity: 'critical',
      condition: 'above',
      cooldown: 600,
      channels: ['slack'],
    });

    // Performance degradation
    this.addRule({
      id: 'performance_degradation',
      name: 'Performance Degradation',
      metric: 'app_startup',
      threshold: 3000, // 3 seconds
      severity: 'warning',
      condition: 'above',
      cooldown: 1800,
      channels: ['slack', 'email'],
    });

    // Memory usage alert
    this.addRule({
      id: 'high_memory',
      name: 'High Memory Usage',
      metric: 'memory_usage',
      threshold: 80, // 80%
      severity: 'warning',
      condition: 'above',
      cooldown: 600,
      channels: ['slack'],
    });

    // Low FPS alert
    this.addRule({
      id: 'low_fps',
      name: 'Low Frame Rate',
      metric: 'fps',
      threshold: 30,
      severity: 'warning',
      condition: 'below',
      cooldown: 300,
      channels: ['slack'],
    });
  }

  /**
   * Add a new alert rule
   */
  addRule(rule: AlertRule): void {
    this.rules.push(rule);
  }

  /**
   * Remove an alert rule
   */
  removeRule(ruleId: string): void {
    this.rules = this.rules.filter(r => r.id !== ruleId);
  }

  /**
   * Evaluate rules against metrics
   */
  evaluateRules(metrics: Record<string, number>): void {
    for (const rule of this.rules) {
      const value = metrics[rule.metric];
      if (value === undefined) continue;

      const shouldTrigger = rule.condition === 'above'
        ? value > rule.threshold
        : value < rule.threshold;

      if (shouldTrigger) {
        this.triggerAlert(rule, value);
      }
    }
  }

  /**
   * Trigger an alert
   */
  private triggerAlert(rule: AlertRule, value: number): void {
    const now = Date.now();
    const lastTriggered = this.triggeredAlerts.get(rule.id);

    // Check cooldown
    if (lastTriggered && (now - lastTriggered) / 1000 < rule.cooldown) {
      return; // In cooldown period
    }

    // Update triggered time
    this.triggeredAlerts.set(rule.id, now);

    // Send alert notifications
    this.sendAlert(rule, value);
  }

  /**
   * Send alert notifications
   */
  private sendAlert(rule: AlertRule, value: number): void {
    const message = {
      title: `${rule.severity.toUpperCase()}: ${rule.name}`,
      description: `${rule.metric} is ${value} (threshold: ${rule.threshold})`,
      severity: rule.severity,
      timestamp: new Date().toISOString(),
    };

    for (const channel of rule.channels) {
      switch (channel) {
        case 'slack':
          this.sendSlackAlert(message);
          break;
        case 'email':
          this.sendEmailAlert(message);
          break;
        case 'pagerduty':
          this.sendPagerDutyAlert(message);
          break;
      }
    }
  }

  /**
   * Send Slack alert
   */
  private sendSlackAlert(message: any): void {
    console.log('📢 Slack Alert:', message);
    // In production, send to Slack webhook
  }

  /**
   * Send email alert
   */
  private sendEmailAlert(message: any): void {
    console.log('📧 Email Alert:', message);
    // In production, send email
  }

  /**
   * Send PagerDuty alert
   */
  private sendPagerDutyAlert(message: any): void {
    console.log('📟 PagerDuty Alert:', message);
    // In production, send to PagerDuty
  }

  /**
   * Get all alert rules
   */
  getRules(): AlertRule[] {
    return this.rules;
  }

  /**
   * Get triggered alerts
   */
  getTriggeredAlerts(): { rule: AlertRule; timestamp: number }[] {
    return Array.from(this.triggeredAlerts.entries()).map(([id, timestamp]) => ({
      rule: this.rules.find(r => r.id === id)!,
      timestamp,
    }));
  }

  /**
   * Clear triggered alerts
   */
  clearTriggeredAlerts(): void {
    this.triggeredAlerts.clear();
  }
}

export const alertManager = AlertManager.getInstance();
```

---

## Performance Budgets

### Performance Budget Configuration

```typescript
// src/apm/PerformanceBudgets.ts
/**
 * Performance Budgets
 * 
 * This defines performance budgets for the application:
 * - Startup time budgets
 * - Render time budgets
 * - Network budgets
 * - Memory budgets
 * - Bundle size budgets
 */

export interface PerformanceBudget {
  metric: string;
  budget: number;
  unit: 'ms' | 'mb' | '%' | 'kb';
  severity: 'warning' | 'critical';
}

export class PerformanceBudgets {
  private static instance: PerformanceBudgets;
  private budgets: PerformanceBudget[] = [];
  private violations: Array<{ budget: PerformanceBudget; value: number; timestamp: number }> = [];

  private constructor() {
    this.initializeBudgets();
  }

  static getInstance(): PerformanceBudgets {
    if (!PerformanceBudgets.instance) {
      PerformanceBudgets.instance = new PerformanceBudgets();
    }
    return PerformanceBudgets.instance;
  }

  /**
   * Initialize performance budgets
   */
  private initializeBudgets(): void {
    this.budgets = [
      { metric: 'app_startup', budget: 2000, unit: 'ms', severity: 'critical' },
      { metric: 'app_startup', budget: 1500, unit: 'ms', severity: 'warning' },
      { metric: 'screen_render', budget: 500, unit: 'ms', severity: 'critical' },
      { metric: 'screen_render', budget: 300, unit: 'ms', severity: 'warning' },
      { metric: 'network_request', budget: 2000, unit: 'ms', severity: 'critical' },
      { metric: 'network_request', budget: 1000, unit: 'ms', severity: 'warning' },
      { metric: 'memory_usage', budget: 50, unit: 'mb', severity: 'critical' },
      { metric: 'memory_usage', budget: 40, unit: 'mb', severity: 'warning' },
      { metric: 'bundle_size', budget: 15, unit: 'mb', severity: 'critical' },
      { metric: 'bundle_size', budget: 10, unit: 'mb', severity: 'warning' },
      { metric: 'fps', budget: 30, unit: '%', severity: 'critical' },
      { metric: 'fps', budget: 45, unit: '%', severity: 'warning' },
    ];
  }

  /**
   * Check metric against budgets
   */
  checkBudget(metric: string, value: number): {
    warning: boolean;
    critical: boolean;
    violations: PerformanceBudget[];
  } {
    const relevantBudgets = this.budgets.filter(b => b.metric === metric);
    const violations: PerformanceBudget[] = [];

    for (const budget of relevantBudgets) {
      const isViolated = this.isBudgetViolated(budget, value);
      if (isViolated) {
        violations.push(budget);
        this.recordViolation(budget, value);
      }
    }

    const warning = violations.some(v => v.severity === 'warning');
    const critical = violations.some(v => v.severity === 'critical');

    return { warning, critical, violations };
  }

  /**
   * Check if budget is violated
   */
  private isBudgetViolated(budget: PerformanceBudget, value: number): boolean {
    switch (budget.unit) {
      case 'ms':
        return value > budget.budget;
      case 'mb':
        return value > budget.budget;
      case '%':
        return value < budget.budget;
      case 'kb':
        return value > budget.budget;
      default:
        return false;
    }
  }

  /**
   * Record a violation
   */
  private recordViolation(budget: PerformanceBudget, value: number): void {
    this.violations.push({
      budget,
      value,
      timestamp: Date.now(),
    });

    // Keep last 100 violations
    if (this.violations.length > 100) {
      this.violations = this.violations.slice(-50);
    }

    // Report violation
    console.warn(`⚠️ Budget violation: ${budget.metric} = ${value}${budget.unit} (budget: ${budget.budget}${budget.unit})`);
  }

  /**
   * Get violations
   */
  getViolations(): Array<{ budget: PerformanceBudget; value: number; timestamp: number }> {
    return this.violations;
  }

  /**
   * Get budget report
   */
  getBudgetReport(metrics: Record<string, number>): {
    passed: string[];
    warnings: string[];
    critical: string[];
    violations: any[];
  } {
    const passed: string[] = [];
    const warnings: string[] = [];
    const critical: string[] = [];
    const violations: any[] = [];

    for (const [metric, value] of Object.entries(metrics)) {
      const result = this.checkBudget(metric, value);

      if (result.critical) {
        critical.push(metric);
        violations.push({ metric, value, violations: result.violations });
      } else if (result.warning) {
        warnings.push(metric);
      } else {
        passed.push(metric);
      }
    }

    return { passed, warnings, critical, violations };
  }

  /**
   * Add custom budget
   */
  addBudget(budget: PerformanceBudget): void {
    this.budgets.push(budget);
  }

  /**
   * Remove budget
   */
  removeBudget(metric: string, severity: 'warning' | 'critical'): void {
    this.budgets = this.budgets.filter(
      b => !(b.metric === metric && b.severity === severity)
    );
  }

  /**
   * Clear violations
   */
  clearViolations(): void {
    this.violations = [];
  }
}

export const performanceBudgets = PerformanceBudgets.getInstance();
```

---

## Quick Reference: APM Commands

```bash
# APM commands
npm run apm:start          # Start APM monitoring
npm run apm:stop           # Stop APM monitoring
npm run apm:metrics        # Show current metrics
npm run apm:alerts         # Show active alerts
npm run apm:report         # Generate performance report
npm run apm:budgets        # Show performance budgets
```

---

This appendix provides a comprehensive APM implementation for your React Native application. By implementing these patterns, you'll gain deep insights into app performance and user experience in production.
