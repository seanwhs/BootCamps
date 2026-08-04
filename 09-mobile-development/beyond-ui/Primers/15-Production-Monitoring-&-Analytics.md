# Primer 15: Production Monitoring & Analytics

## Your Complete Guide to Keeping Your App Healthy in Production

Welcome to the Production Monitoring & Analytics Primer! This guide covers everything you need to know about monitoring your app after launch, tracking errors, measuring performance, and understanding user behavior. Production monitoring is like having a control center for your app—it gives you visibility into how your app is performing in the real world.

---

## M.1 Understanding Production Monitoring

### The Concept: Keeping Watch Over Your App

Production monitoring is the process of tracking your app's health, performance, and usage after it's been released to users. Think of it as a dashboard that shows you what's happening with your app in real-time—errors, performance issues, user behavior, and more.

**Simple Analogy:** Production monitoring is like an air traffic control tower. You can see all the planes (users) in your airspace (app), track their movements, detect problems (errors), and respond quickly to emergencies (crashes).

### What to Monitor

| Category | What to Track | Why |
|----------|---------------|-----|
| **Errors** | Crashes, exceptions, API errors | Fix bugs quickly |
| **Performance** | Load times, FPS, memory usage | Optimize app speed |
| **Analytics** | User behavior, feature usage | Improve product |
| **Health** | Uptime, API status, response times | Ensure availability |
| **Feedback** | User reviews, ratings, support | Understand users |
| **Business** | Active users, retention, revenue | Track success |

---

## M.2 Error Tracking with Sentry

### The Concept: Catching Bugs in Production

Sentry captures errors and crashes in real-time, helping you find and fix issues before they affect many users.

### Complete Sentry Integration

```bash
# 1. Install Sentry
npm install sentry-expo

# 2. Configure Sentry
# Initialize in your app
```

```typescript
// src/utils/errorTracking.ts
import * as Sentry from 'sentry-expo';
import { Platform } from 'react-native';
import { CONFIG } from '@constants/config';

/**
 * Initialize Sentry for error tracking
 */
export const initSentry = () => {
  Sentry.init({
    dsn: CONFIG.sentry.dsn || process.env.SENTRY_DSN,
    enableInExpoDevelopment: CONFIG.isDevelopment,
    debug: CONFIG.isDevelopment,
    environment: CONFIG.environment,
    release: process.env.APP_VERSION,
    integrations: [
      new Sentry.Native.ReactNativeTracing({
        tracingOrigins: ['localhost', 'https://nexuscollect.com'],
      }),
    ],
    beforeSend: (event) => {
      // Filter out sensitive data
      if (event.user) {
        delete event.user.email;
      }
      if (event.request?.url?.includes('localhost')) {
        return null; // Don't send localhost errors
      }
      return event;
    },
    // Sample rate for performance monitoring (0-1)
    tracesSampleRate: 0.2,
  });
};

/**
 * Error tracking service
 */
export const errorTracker = {
  /**
   * Capture an exception
   */
  captureException: (error: Error, context?: Record<string, any>) => {
    console.error('Error captured:', error);

    Sentry.withScope((scope) => {
      if (context) {
        scope.setExtras(context);
      }
      scope.setExtra('platform', Platform.OS);
      scope.setExtra('isDevelopment', CONFIG.isDevelopment);
      scope.setExtra('appVersion', process.env.APP_VERSION);

      Sentry.captureException(error);
    });
  },

  /**
   * Capture a message
   */
  captureMessage: (message: string, level: 'info' | 'warning' | 'error' = 'info') => {
    console.log(`[${level}] ${message}`);

    Sentry.addBreadcrumb({
      message,
      level: level === 'error' ? Sentry.Severity.Error :
             level === 'warning' ? Sentry.Severity.Warning :
             Sentry.Severity.Info,
      timestamp: Date.now(),
    });
  },

  /**
   * Set user context
   */
  setUser: (user: { id: string; email?: string; name?: string }) => {
    Sentry.setUser({
      id: user.id,
      email: user.email,
      username: user.name,
    });
  },

  /**
   * Clear user context (logout)
   */
  clearUser: () => {
    Sentry.setUser(null);
  },

  /**
   * Add a breadcrumb (contextual information)
   */
  addBreadcrumb: (breadcrumb: {
    message: string;
    category?: string;
    data?: Record<string, any>;
    level?: Sentry.Severity;
  }) => {
    Sentry.addBreadcrumb({
      message: breadcrumb.message,
      category: breadcrumb.category || 'app',
      data: breadcrumb.data || {},
      level: breadcrumb.level || Sentry.Severity.Info,
    });
  },

  /**
   * Start a transaction for performance monitoring
   */
  startTransaction: (name: string, op: string) => {
    return Sentry.startTransaction({
      name,
      op,
    });
  },

  /**
   * Wrap a function for performance monitoring
   */
  wrapFunction: <T extends (...args: any[]) => any>(
    fn: T,
    name: string
  ): T => {
    return Sentry.wrap(fn, {
      transaction: name,
    });
  },

  /**
   * Setup global error handlers
   */
  setupGlobalErrorHandling: () => {
    // Handle unhandled promise rejections
    const originalHandler = global.ErrorUtils?.getGlobalHandler();

    if (originalHandler) {
      global.ErrorUtils.setGlobalHandler((error: Error, isFatal: boolean) => {
        errorTracker.captureException(error, { isFatal });
        originalHandler(error, isFatal);
      });
    }

    // Handle unhandled rejections
    process.on('unhandledRejection', (reason: any) => {
      if (reason instanceof Error) {
        errorTracker.captureException(reason);
      } else {
        errorTracker.captureMessage(`Unhandled rejection: ${reason}`, 'error');
      }
    });
  },
};

/**
 * Hook for error tracking
 */
export const useErrorTracking = () => {
  useEffect(() => {
    // Initialize on mount
    initSentry();
    errorTracker.setupGlobalErrorHandling();

    // Cleanup
    return () => {
      // No cleanup needed
    };
  }, []);
};

// Wrap functions for performance monitoring
export const withErrorTracking = errorTracker.wrapFunction;
```

---

## M.3 Performance Monitoring

### The Concept: Keeping Your App Fast

Performance monitoring tracks how fast your app runs and identifies bottlenecks.

### Complete Performance Monitoring Guide

```typescript
// src/utils/performance.ts
import * as Sentry from 'sentry-expo';
import { PerformanceObserver, performance } from 'react-native-performance';

/**
 * Performance Monitoring Service
 */
export class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private marks: Map<string, number> = new Map();
  private isEnabled: boolean = true;

  private constructor() {
    // Setup performance observer for native events
    if (PerformanceObserver) {
      const observer = new PerformanceObserver((list) => {
        list.getEntries().forEach((entry) => {
          if (entry.duration > 100) {
            this.logSlowOperation(entry.name, entry.duration);
          }
        });
      });
      observer.observe({ entryTypes: ['measure', 'navigation', 'resource'] });
    }
  }

  static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  /**
   * Mark the start of a performance measurement
   */
  markStart(name: string): void {
    if (!this.isEnabled) return;
    this.marks.set(name, performance.now());
    performance.mark(`${name}-start`);
  }

  /**
   * Mark the end and measure duration
   */
  markEnd(name: string): number {
    if (!this.isEnabled) return 0;

    const start = this.marks.get(name);
    if (!start) {
      console.warn(`No start mark found for: ${name}`);
      return 0;
    }

    const duration = performance.now() - start;
    this.marks.delete(name);

    // Send to performance monitoring
    performance.mark(`${name}-end`);
    performance.measure(name, `${name}-start`, `${name}-end`);

    // Log slow operations
    if (duration > 100) {
      this.logSlowOperation(name, duration);
    }

    return duration;
  }

  /**
   * Measure a function's execution time
   */
  async measure<T>(name: string, fn: () => Promise<T> | T): Promise<T> {
    if (!this.isEnabled) return fn();

    this.markStart(name);
    try {
      const result = await fn();
      this.markEnd(name);
      return result;
    } catch (error) {
      this.markEnd(name);
      throw error;
    }
  }

  /**
   * Track render performance
   */
  trackRender(componentName: string, renderTime: number): void {
    if (renderTime > 100) {
      this.logSlowOperation(`render-${componentName}`, renderTime);
    }
  }

  /**
   * Track memory usage
   */
  async getMemoryUsage(): Promise<{
    used: number;
    total: number;
    percent: number;
  }> {
    try {
      // @ts-ignore - performance.memory is not standard
      const memory = performance.memory;
      if (memory) {
        return {
          used: memory.usedJSHeapSize,
          total: memory.totalJSHeapSize,
          percent: (memory.usedJSHeapSize / memory.totalJSHeapSize) * 100,
        };
      }
      return { used: 0, total: 0, percent: 0 };
    } catch (error) {
      return { used: 0, total: 0, percent: 0 };
    }
  }

  /**
   * Log slow operations
   */
  private logSlowOperation(name: string, duration: number): void {
    console.warn(`⚠️ Slow operation: ${name} took ${duration.toFixed(2)}ms`);

    // Send to Sentry
    if (duration > 500) {
      Sentry.captureMessage(`Slow operation: ${name} (${duration.toFixed(0)}ms)`, {
        level: 'warning',
        extra: {
          operation: name,
          duration: duration,
        },
      });
    }
  }

  /**
   * Enable/disable monitoring
   */
  setEnabled(enabled: boolean): void {
    this.isEnabled = enabled;
  }

  /**
   * Track network request
   */
  trackNetworkRequest(url: string, duration: number, success: boolean): void {
    if (duration > 5000) {
      Sentry.captureMessage(`Slow network request: ${url} (${duration.toFixed(0)}ms)`, {
        level: success ? 'info' : 'warning',
        extra: {
          url,
          duration,
          success,
        },
      });
    }
  }
}

export const performanceMonitor = PerformanceMonitor.getInstance();

/**
 * Hook for performance monitoring
 */
export const usePerformance = () => {
  const [fps, setFps] = useState<number>(60);

  useEffect(() => {
    // Track FPS
    let frameCount = 0;
    let lastTime = performance.now();

    const measureFPS = () => {
      frameCount++;
      const currentTime = performance.now();
      if (currentTime - lastTime >= 1000) {
        const currentFps = frameCount;
        setFps(currentFps);
        frameCount = 0;
        lastTime = currentTime;

        if (currentFps < 30) {
          console.warn(`⚠️ Low FPS: ${currentFps}`);
        }
      }
      requestAnimationFrame(measureFPS);
    };

    measureFPS();

    return () => {
      // Cleanup
    };
  }, []);

  return { fps };
};
```

---

## M.4 User Analytics

### The Concept: Understanding User Behavior

Analytics helps you understand how users interact with your app.

### Complete Analytics Guide

```typescript
// src/utils/analytics.ts
import * as Analytics from 'expo-analytics';
import { Platform } from 'react-native';
import { CONFIG } from '@constants/config';

/**
 * Analytics Service
 * Tracks user behavior and app usage
 */
export class AnalyticsService {
  private static instance: AnalyticsService;
  private enabled: boolean = CONFIG.environment === 'production';
  private userId: string | null = null;
  private sessionId: string | null = null;

  private constructor() {
    this.sessionId = this.generateSessionId();
  }

  static getInstance(): AnalyticsService {
    if (!AnalyticsService.instance) {
      AnalyticsService.instance = new AnalyticsService();
    }
    return AnalyticsService.instance;
  }

  /**
   * Generate a unique session ID
   */
  private generateSessionId(): string {
    return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
  }

  /**
   * Set user ID for analytics
   */
  setUser(userId: string, userProperties?: Record<string, any>): void {
    this.userId = userId;
    this.trackEvent('identify', {
      userId,
      ...userProperties,
    });
  }

  /**
   * Track an event
   */
  trackEvent(eventName: string, properties?: Record<string, any>): void {
    if (!this.enabled) return;

    const event = {
      name: eventName,
      properties: {
        ...properties,
        userId: this.userId,
        sessionId: this.sessionId,
        platform: Platform.OS,
        timestamp: new Date().toISOString(),
      },
    };

    console.log('📊 [Analytics]', event);

    // Send to analytics service
    // This would integrate with services like Amplitude, Mixpanel, or Segment
  }

  /**
   * Track screen view
   */
  trackScreen(screenName: string, properties?: Record<string, any>): void {
    this.trackEvent('screen_view', {
      screen_name: screenName,
      ...properties,
    });
  }

  /**
   * Track user engagement
   */
  trackEngagement(
    type: 'like' | 'share' | 'comment' | 'rate' | 'report',
    properties?: Record<string, any>
  ): void {
    this.trackEvent(`engagement_${type}`, properties);
  }

  /**
   * Track feature usage
   */
  trackFeature(featureName: string, properties?: Record<string, any>): void {
    this.trackEvent(`feature_${featureName}`, properties);
  }

  /**
   * Track revenue/transaction
   */
  trackRevenue(
    amount: number,
    currency: string = 'USD',
    properties?: Record<string, any>
  ): void {
    this.trackEvent('revenue', {
      amount,
      currency,
      ...properties,
    });
  }

  /**
   * Track error
   */
  trackError(error: Error, context?: Record<string, any>): void {
    this.trackEvent('error', {
      error_name: error.name,
      error_message: error.message,
      ...context,
    });
  }

  /**
   * Track session start
   */
  trackSessionStart(): void {
    this.sessionId = this.generateSessionId();
    this.trackEvent('session_start', {
      sessionId: this.sessionId,
    });
  }

  /**
   * Track session end
   */
  trackSessionEnd(): void {
    this.trackEvent('session_end', {
      sessionId: this.sessionId,
    });
    this.sessionId = null;
  }

  /**
   * Enable/disable analytics
   */
  setEnabled(enabled: boolean): void {
    this.enabled = enabled && CONFIG.environment === 'production';
  }
}

export const analytics = AnalyticsService.getInstance();

/**
 * Hook for analytics
 */
export const useAnalytics = () => {
  const navigation = useNavigation();

  useEffect(() => {
    // Track screen views
    const unsubscribe = navigation.addListener('state', (e) => {
      const state = e.data.state;
      const route = state.routes[state.index];
      if (route) {
        analytics.trackScreen(route.name, {
          params: route.params,
        });
      }
    });

    return unsubscribe;
  }, [navigation]);

  return analytics;
};
```

---

## M.5 Crash Reporting

### The Concept: Understanding Crashes

Crash reporting helps you identify and fix app crashes that affect users.

### Complete Crash Reporting Guide

```typescript
// src/utils/crashReporting.ts
import * as Sentry from 'sentry-expo';
import { Platform } from 'react-native';
import DeviceInfo from 'react-native-device-info';

/**
 * Crash Reporting Service
 */
export class CrashReporter {
  private static instance: CrashReporter;
  private crashCount: number = 0;
  private lastCrash: Date | null = null;

  private constructor() {}

  static getInstance(): CrashReporter {
    if (!CrashReporter.instance) {
      CrashReporter.instance = new CrashReporter();
    }
    return CrashReporter.instance;
  }

  /**
   * Report a crash
   */
  reportCrash(error: Error, context?: Record<string, any>): void {
    this.crashCount++;
    this.lastCrash = new Date();

    // Add device context
    const deviceInfo = {
      platform: Platform.OS,
      deviceModel: DeviceInfo.getModel(),
      osVersion: DeviceInfo.getSystemVersion(),
      appVersion: DeviceInfo.getVersion(),
      buildNumber: DeviceInfo.getBuildNumber(),
    };

    Sentry.captureException(error, {
      extra: {
        ...context,
        ...deviceInfo,
        crashCount: this.crashCount,
        crashHistory: this.getCrashHistory(),
      },
    });
  }

  /**
   * Get crash history
   */
  getCrashHistory(): { count: number; lastCrash: Date | null } {
    return {
      count: this.crashCount,
      lastCrash: this.lastCrash,
    };
  }

  /**
   * Get crash statistics
   */
  getCrashStats(): { stabilityScore: number; crashFreeUsers: number } {
    // In production, this would come from a backend
    return {
      stabilityScore: 99.5,
      crashFreeUsers: 10000,
    };
  }

  /**
   * Setup crash handling
   */
  setupCrashHandling(): void {
    // Setup native crash handlers
    if (Platform.OS === 'ios') {
      // iOS specific setup
    } else if (Platform.OS === 'android') {
      // Android specific setup
    }

    // Setup error boundary for React
    const originalErrorHandler = global.ErrorUtils?.getGlobalHandler();
    if (originalErrorHandler) {
      global.ErrorUtils.setGlobalHandler((error: Error, isFatal: boolean) => {
        if (isFatal) {
          this.reportCrash(error, { isFatal });
        }
        originalErrorHandler(error, isFatal);
      });
    }
  }
}

export const crashReporter = CrashReporter.getInstance();
```

---

## M.6 Health Monitoring

### The Concept: App Health Dashboard

Health monitoring tracks the overall health of your app.

### Complete Health Monitoring Guide

```typescript
// src/utils/health.ts
import { AppState, Platform } from 'react-native';
import DeviceInfo from 'react-native-device-info';
import { performanceMonitor } from './performance';
import { errorTracker } from './errorTracking';

/**
 * Health Monitoring Service
 * Tracks app health and performance metrics
 */
export class HealthMonitor {
  private static instance: HealthMonitor;
  private startTime: number = Date.now();
  private appState: string = 'active';
  private sessions: number = 0;
  private errors: number = 0;

  private constructor() {
    // Track app state
    AppState.addEventListener('change', this.handleAppStateChange.bind(this));
  }

  static getInstance(): HealthMonitor {
    if (!HealthMonitor.instance) {
      HealthMonitor.instance = new HealthMonitor();
    }
    return HealthMonitor.instance;
  }

  /**
   * Handle app state changes
   */
  private handleAppStateChange(state: string): void {
    if (state === 'active') {
      this.sessions++;
      this.startTime = Date.now();
    } else if (state === 'background') {
      this.logSession();
    }
    this.appState = state;
  }

  /**
   * Log session data
   */
  private logSession(): void {
    const duration = (Date.now() - this.startTime) / 1000;
    console.log(`📊 Session ended: ${duration}s, Errors: ${this.errors}`);

    // Send session data to analytics
    errorTracker.captureMessage(`Session ended: ${duration}s`, 'info');
  }

  /**
   * Get health report
   */
  async getHealthReport(): Promise<{
    uptime: number;
    sessions: number;
    errors: number;
    stability: string;
    memory: { used: number; total: number; percent: number };
  }> {
    const uptime = (Date.now() - this.startTime) / 1000;
    const memory = await performanceMonitor.getMemoryUsage();

    return {
      uptime,
      sessions: this.sessions,
      errors: this.errors,
      stability: this.errors === 0 ? 'Excellent' : 'Needs attention',
      memory,
    };
  }

  /**
   * Track error
   */
  trackError(): void {
    this.errors++;
  }

  /**
   * Check app health
   */
  checkHealth(): {
    isHealthy: boolean;
    issues: string[];
  } {
    const issues: string[] = [];

    // Check memory
    performanceMonitor.getMemoryUsage().then((memory) => {
      if (memory.percent > 80) {
        issues.push(`High memory usage: ${memory.percent.toFixed(1)}%`);
      }
    });

    // Check errors
    if (this.errors > 10) {
      issues.push(`High error rate: ${this.errors} errors`);
    }

    return {
      isHealthy: issues.length === 0,
      issues,
    };
  }
}

export const healthMonitor = HealthMonitor.getInstance();
```

---

## M.7 Quick Reference

### Monitoring Commands

```bash
# Sentry CLI
sentry-cli debug-files upload --org nexuscollect --project react-native ./ios/main.jsbundle
sentry-cli releases new 1.0.0
sentry-cli releases set-commits 1.0.0 --auto
sentry-cli releases finalize 1.0.0

# Analytics
# Check analytics dashboard
# Monitor user events
# Track conversion funnels

# Monitoring
# App Store Connect - App Analytics
# Google Play Console - Android Vitals
# Sentry - Error Dashboard
```

### Monitoring Checklist

| Item | Status |
|------|--------|
| Sentry configured | ✅ |
| Error tracking working | ✅ |
| Performance monitoring | ✅ |
| Analytics tracking | ✅ |
| Crash reporting | ✅ |
| Health monitoring | ✅ |
| Alerting configured | ✅ |
| Dashboard created | ✅ |

---

**Ready to monitor your production app? Let's build NexusCollect!**
