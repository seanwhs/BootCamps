# Appendix L: Analytics & User Tracking

Welcome to Appendix L! This comprehensive guide covers everything you need to know about implementing analytics and user tracking in your React Native application. You'll learn how to track user behavior, measure feature adoption, analyze user journeys, and make data-driven decisions to improve your app.

---

## Table of Contents

1. [Analytics Architecture](#analytics-architecture)
2. [Analytics Service Implementation](#analytics-service-implementation)
3. [User Event Tracking](#user-event-tracking)
4. [Screen Tracking & Navigation](#screen-tracking--navigation)
5. [User Identification](#user-identification)
6. [Feature Usage Analytics](#feature-usage-analytics)
7. [Performance Analytics](#performance-analytics)
8. [Analytics Dashboard & Reporting](#analytics-dashboard--reporting)

---

## Analytics Architecture

### Complete Analytics Architecture

```typescript
// src/analytics/architecture.ts
/**
 * Analytics Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     ANALYTICS LAYER                            │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │              Analytics Service                          │   │
 * │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
 * │  │  │   Mixpanel  │  │   Segment   │  │  Amplitude  │   │   │
 * │  │  └─────────────┘  └─────────────┘  └─────────────┘   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * │                              │                                  │
 * │                              ▼                                  │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │              Event Context                             │   │
 * │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
 * │  │  │  User Info  │  │  Device     │  │  App State  │   │   │
 * │  │  │  (ID, Role) │  │  (OS, Model)│  │  (Version)  │   │   │
 * │  │  └─────────────┘  └─────────────┘  └─────────────┘   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * │                              │                                  │
 * │                              ▼                                  │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │              Event Types                               │   │
 * │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
 * │  │  │   Screen    │  │   Action    │  │   Feature   │   │   │
 * │  │  │   Views     │  │   Events    │  │   Usage     │   │   │
 * │  │  └─────────────┘  └─────────────┘  └─────────────┘   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 */

export const AnalyticsArchitecture = {
  providers: {
    primary: 'Mixpanel',
    secondary: 'Segment',
    backup: 'Amplitude',
  },
  
  eventCategories: {
    screenView: 'Screen View',
    userAction: 'User Action',
    featureUsage: 'Feature Usage',
    performance: 'Performance',
    error: 'Error',
    revenue: 'Revenue',
    engagement: 'Engagement',
  },
  
  eventPriorities: {
    critical: ['User Login', 'Payment Success', 'Error Occurred'],
    high: ['Feature Use', 'Screen Navigation', 'Task Creation'],
    medium: ['Settings Change', 'Profile Update', 'Notification Interact'],
    low: ['Screen Scrolling', 'Hover Events', 'Background Events'],
  },
};
```

---

## Analytics Service Implementation

### Complete Analytics Service

```typescript
// src/analytics/AnalyticsService.ts
import { Platform } from 'react-native';
import { Constants } from 'expo-constants';
import * as Mixpanel from 'mixpanel-react-native';
import * as Segment from '@segment/analytics-react-native';

/**
 * Analytics Service
 * 
 * This provides a comprehensive analytics service:
 * - Multiple provider support
 * - Event batching
 * - Context enrichment
 * - Error handling
 * - Offline queueing
 */

interface AnalyticsConfig {
  mixpanelToken?: string;
  segmentKey?: string;
  amplitudeKey?: string;
  environment: 'development' | 'staging' | 'production';
  batchSize: number;
  flushInterval: number;
  debug: boolean;
}

interface AnalyticsEvent {
  name: string;
  properties?: Record<string, any>;
  timestamp?: number;
  context?: Record<string, any>;
}

interface UserProperties {
  id: string;
  email?: string;
  name?: string;
  role?: string;
  signUpDate?: string;
  preferences?: Record<string, any>;
}

export class AnalyticsService {
  private static instance: AnalyticsService;
  private config: AnalyticsConfig;
  private eventQueue: AnalyticsEvent[] = [];
  private isFlushing = false;
  private userProperties: UserProperties | null = null;
  private initialized = false;

  private constructor() {
    this.config = {
      environment: __DEV__ ? 'development' : 'production',
      batchSize: 10,
      flushInterval: 10000,
      debug: __DEV__,
    };
  }

  static getInstance(): AnalyticsService {
    if (!AnalyticsService.instance) {
      AnalyticsService.instance = new AnalyticsService();
    }
    return AnalyticsService.instance;
  }

  /**
   * Initialize analytics
   */
  async initialize(config: Partial<AnalyticsConfig> = {}): Promise<void> {
    if (this.initialized) return;

    this.config = { ...this.config, ...config };

    // Initialize providers
    if (this.config.mixpanelToken) {
      await this.initializeMixpanel();
    }

    if (this.config.segmentKey) {
      await this.initializeSegment();
    }

    this.initialized = true;

    // Set up flush interval
    setInterval(() => {
      this.flushQueue();
    }, this.config.flushInterval);

    // Handle app state changes
    // AppState.addEventListener('change', this.handleAppStateChange);

    console.log('✅ Analytics initialized');
  }

  /**
   * Initialize Mixpanel
   */
  private async initializeMixpanel(): Promise<void> {
    try {
      // In production, use real Mixpanel SDK
      console.log('📊 Mixpanel initialized');
    } catch (error) {
      console.error('Mixpanel initialization failed:', error);
    }
  }

  /**
   * Initialize Segment
   */
  private async initializeSegment(): Promise<void> {
    try {
      // In production, use real Segment SDK
      console.log('📊 Segment initialized');
    } catch (error) {
      console.error('Segment initialization failed:', error);
    }
  }

  /**
   * Identify user
   */
  identifyUser(user: UserProperties): void {
    this.userProperties = user;

    // Send to providers
    const identify = {
      userId: user.id,
      traits: {
        email: user.email,
        name: user.name,
        role: user.role,
        signUpDate: user.signUpDate,
        ...user.preferences,
      },
    };

    console.log('👤 User identified:', identify);

    // Identify in providers
    // Mixpanel.identify(identify.userId);
    // Segment.identify(identify);
  }

  /**
   * Track event
   */
  track(eventName: string, properties?: Record<string, any>): void {
    if (!this.initialized) {
      console.warn('Analytics not initialized, event not tracked:', eventName);
      return;
    }

    const event: AnalyticsEvent = {
      name: eventName,
      properties: {
        ...properties,
        platform: Platform.OS,
        appVersion: Constants.manifest?.version,
        environment: this.config.environment,
      },
      timestamp: Date.now(),
      context: {
        user: this.userProperties,
        device: {
          platform: Platform.OS,
          osVersion: Platform.Version,
        },
      },
    };

    this.eventQueue.push(event);

    // Flush if batch size reached
    if (this.eventQueue.length >= this.config.batchSize) {
      this.flushQueue();
    }

    // Log in development
    if (this.config.debug) {
      console.log(`📊 Event: ${eventName}`, properties);
    }
  }

  /**
   * Flush event queue
   */
  private async flushQueue(): Promise<void> {
    if (this.isFlushing || this.eventQueue.length === 0) return;

    this.isFlushing = true;

    try {
      const events = this.eventQueue.splice(0, this.config.batchSize);

      // Send events to providers
      // In production, send to real services
      events.forEach(event => {
        // Mixpanel.track(event.name, event.properties);
        // Segment.track(event.name, event.properties);
      });

      console.log(`📤 Flushed ${events.length} events`);
    } catch (error) {
      console.error('Failed to flush events:', error);
      // Re-add events to queue
      // this.eventQueue.unshift(...events);
    } finally {
      this.isFlushing = false;
    }
  }

  /**
   * Track screen view
   */
  trackScreen(screenName: string, properties?: Record<string, any>): void {
    this.track('screen_view', {
      screen_name: screenName,
      ...properties,
    });
  }

  /**
   * Track error
   */
  trackError(error: Error, context?: Record<string, any>): void {
    this.track('error_occurred', {
      error_name: error.name,
      error_message: error.message,
      error_stack: error.stack,
      ...context,
    });
  }

  /**
   * Track performance metric
   */
  trackPerformance(metricName: string, value: number, tags?: Record<string, string>): void {
    this.track('performance_metric', {
      metric_name: metricName,
      value,
      ...tags,
    });
  }

  /**
   * Set user property
   */
  setUserProperty(property: string, value: any): void {
    if (this.userProperties) {
      this.userProperties[property as keyof UserProperties] = value;
    }
  }

  /**
   * Get user ID
   */
  getUserId(): string | undefined {
    return this.userProperties?.id;
  }

  /**
   * Reset analytics
   */
  reset(): void {
    this.userProperties = null;
    this.eventQueue = [];
    // Reset providers
    // Mixpanel.reset();
    // Segment.reset();
  }

  /**
   * Handle app state changes
   */
  private handleAppStateChange(state: string): void {
    if (state === 'background') {
      // Flush on background
      this.flushQueue();
    }
  }

  /**
   * Clean up
   */
  cleanup(): void {
    // Flush remaining events
    this.flushQueue();
    // Remove listeners
    // AppState.removeEventListener('change', this.handleAppStateChange);
  }
}

export const analytics = AnalyticsService.getInstance();
```

---

## User Event Tracking

### Complete Event Tracking System

```typescript
// src/analytics/EventTracker.ts
import { analytics } from './AnalyticsService';

/**
 * Event Tracking System
 * 
 * This provides comprehensive event tracking:
 * - Pre-defined event types
 * - Event validation
 * - Property enrichment
 * - Event grouping
 * - User journey tracking
 */

// Event Types
export enum AnalyticsEventType {
  // User Actions
  USER_LOGIN = 'user_login',
  USER_LOGOUT = 'user_logout',
  USER_REGISTER = 'user_register',
  USER_PROFILE_UPDATE = 'user_profile_update',
  USER_PASSWORD_CHANGE = 'user_password_change',

  // Task Actions
  TASK_CREATE = 'task_create',
  TASK_UPDATE = 'task_update',
  TASK_DELETE = 'task_delete',
  TASK_COMPLETE = 'task_complete',
  TASK_REOPEN = 'task_reopen',
  TASK_SHARE = 'task_share',
  TASK_ASSIGN = 'task_assign',

  // Navigation
  SCREEN_VIEW = 'screen_view',
  NAVIGATE_BACK = 'navigate_back',
  DEEP_LINK = 'deep_link',

  // Features
  FEATURE_SEARCH = 'feature_search',
  FEATURE_FILTER = 'feature_filter',
  FEATURE_SORT = 'feature_sort',
  FEATURE_EXPORT = 'feature_export',
  FEATURE_IMPORT = 'feature_import',

  // Engagement
  ENGAGE_READ = 'engage_read',
  ENGAGE_CLICK = 'engage_click',
  ENGAGE_SCROLL = 'engage_scroll',
  ENGAGE_SWIPE = 'engage_swipe',

  // Notifications
  NOTIFICATION_RECEIVE = 'notification_receive',
  NOTIFICATION_OPEN = 'notification_open',
  NOTIFICATION_DISMISS = 'notification_dismiss',

  // Revenue
  REVENUE_PURCHASE = 'revenue_purchase',
  REVENUE_SUBSCRIPTION = 'revenue_subscription',
  REVENUE_UPGRADE = 'revenue_upgrade',
}

export class EventTracker {
  private static instance: EventTracker;
  private sessionId: string | null = null;
  private sessionStartTime: number | null = null;

  private constructor() {}

  static getInstance(): EventTracker {
    if (!EventTracker.instance) {
      EventTracker.instance = new EventTracker();
    }
    return EventTracker.instance;
  }

  /**
   * Start a session
   */
  startSession(): void {
    this.sessionId = `session-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    this.sessionStartTime = Date.now();

    analytics.track('session_start', {
      session_id: this.sessionId,
      timestamp: this.sessionStartTime,
    });
  }

  /**
   * End a session
   */
  endSession(): void {
    if (this.sessionId && this.sessionStartTime) {
      const duration = Date.now() - this.sessionStartTime;

      analytics.track('session_end', {
        session_id: this.sessionId,
        duration,
      });
    }

    this.sessionId = null;
    this.sessionStartTime = null;
  }

  /**
   * Track user login
   */
  trackLogin(method: 'email' | 'google' | 'apple' | 'facebook', success: boolean): void {
    analytics.track(AnalyticsEventType.USER_LOGIN, {
      method,
      success,
      session_id: this.sessionId,
    });
  }

  /**
   * Track task creation
   */
  trackTaskCreate(taskProperties: {
    title: string;
    priority: string;
    category: string;
    hasDueDate: boolean;
    hasDescription: boolean;
  }): void {
    analytics.track(AnalyticsEventType.TASK_CREATE, {
      ...taskProperties,
      session_id: this.sessionId,
    });
  }

  /**
   * Track task completion
   */
  trackTaskComplete(taskId: string, timeToComplete: number): void {
    analytics.track(AnalyticsEventType.TASK_COMPLETE, {
      task_id: taskId,
      time_to_complete: timeToComplete,
      session_id: this.sessionId,
    });
  }

  /**
   * Track search
   */
  trackSearch(query: string, resultsCount: number): void {
    analytics.track(AnalyticsEventType.FEATURE_SEARCH, {
      query,
      results_count: resultsCount,
      session_id: this.sessionId,
    });
  }

  /**
   * Track notification interaction
   */
  trackNotification(type: string, action: 'receive' | 'open' | 'dismiss'): void {
    analytics.track(`notification_${action}`, {
      notification_type: type,
      session_id: this.sessionId,
    });
  }

  /**
   * Track purchase
   */
  trackPurchase(amount: number, currency: string, productId: string): void {
    analytics.track(AnalyticsEventType.REVENUE_PURCHASE, {
      amount,
      currency,
      product_id: productId,
      session_id: this.sessionId,
    });
  }

  /**
   * Track feature usage
   */
  trackFeatureUsage(featureName: string, action: string, properties?: Record<string, any>): void {
    analytics.track(`feature_${featureName}_${action}`, {
      feature: featureName,
      action,
      ...properties,
      session_id: this.sessionId,
    });
  }

  /**
   * Track user journey
   */
  trackJourneyStep(step: string, properties?: Record<string, any>): void {
    analytics.track('journey_step', {
      step,
      ...properties,
      session_id: this.sessionId,
      journey_time: this.sessionStartTime ? Date.now() - this.sessionStartTime : 0,
    });
  }

  /**
   * Track error with context
   */
  trackErrorWithContext(error: Error, context: {
    screen?: string;
    action?: string;
    userAction?: string;
  }): void {
    analytics.trackError(error, {
      ...context,
      session_id: this.sessionId,
    });
  }

  /**
   * Track app state changes
   */
  trackAppState(state: 'foreground' | 'background' | 'inactive'): void {
    analytics.track('app_state_change', {
      state,
      session_id: this.sessionId,
    });
  }

  /**
   * Track user engagement
   */
  trackEngagement(activity: string, duration?: number): void {
    analytics.track('user_engagement', {
      activity,
      duration,
      session_id: this.sessionId,
    });
  }

  /**
   * Get session data
   */
  getSessionData(): { sessionId: string | null; duration: number } {
    return {
      sessionId: this.sessionId,
      duration: this.sessionStartTime ? Date.now() - this.sessionStartTime : 0,
    };
  }
}

export const eventTracker = EventTracker.getInstance();
```

---

## Screen Tracking & Navigation

### Navigation Tracking Implementation

```typescript
// src/analytics/NavigationTracker.ts
import { useNavigation, useRoute } from '@react-navigation/native';
import { useEffect, useRef } from 'react';
import { analytics } from './AnalyticsService';
import { eventTracker } from './EventTracker';

/**
 * Navigation Tracking
 * 
 * This provides comprehensive navigation tracking:
 * - Automatic screen tracking
 * - Screen time measurement
 * - Navigation flow tracking
 * - Deep link tracking
 */

export class NavigationTracker {
  private static instance: NavigationTracker;
  private screenTimers: Map<string, number> = new Map();
  private currentScreen: string | null = null;

  private constructor() {}

  static getInstance(): NavigationTracker {
    if (!NavigationTracker.instance) {
      NavigationTracker.instance = new NavigationTracker();
    }
    return NavigationTracker.instance;
  }

  /**
   * Track screen view
   */
  trackScreenView(
    screenName: string,
    params?: Record<string, any>
  ): void {
    // Track previous screen duration
    if (this.currentScreen) {
      this.trackScreenDuration(this.currentScreen);
    }

    this.currentScreen = screenName;
    this.screenTimers.set(screenName, Date.now());

    // Track screen view
    analytics.trackScreen(screenName, {
      params,
      previous_screen: this.currentScreen,
    });

    // Track journey step
    eventTracker.trackJourneyStep(`screen_${screenName}`, { params });
  }

  /**
   * Track screen duration
   */
  private trackScreenDuration(screenName: string): void {
    const startTime = this.screenTimers.get(screenName);
    if (startTime) {
      const duration = Date.now() - startTime;
      
      analytics.track('screen_duration', {
        screen_name: screenName,
        duration,
      });

      this.screenTimers.delete(screenName);
    }
  }

  /**
   * Track navigation flow
   */
  trackNavigationFlow(from: string, to: string, action: string): void {
    analytics.track('navigation_flow', {
      from_screen: from,
      to_screen: to,
      action,
    });
  }

  /**
   * Track deep link
   */
  trackDeepLink(url: string, params: Record<string, any>): void {
    analytics.track('deep_link_handled', {
      url,
      params,
    });

    eventTracker.trackJourneyStep('deep_link', { url, params });
  }

  /**
   * Get current screen
   */
  getCurrentScreen(): string | null {
    return this.currentScreen;
  }

  /**
   * Reset navigation tracker
   */
  reset(): void {
    this.screenTimers.clear();
    this.currentScreen = null;
  }
}

export const navigationTracker = NavigationTracker.getInstance();

/**
 * React Hook for Screen Tracking
 * 
 * Usage:
 * const { trackScreen } = useScreenTracking();
 * trackScreen('HomeScreen');
 */
export const useScreenTracking = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const previousRouteName = useRef<string | null>(null);

  useEffect(() => {
    const unsubscribe = navigation.addListener('state', () => {
      const currentRoute = route.name;
      
      if (previousRouteName.current && currentRoute !== previousRouteName.current) {
        // Track navigation flow
        navigationTracker.trackNavigationFlow(
          previousRouteName.current,
          currentRoute,
          'navigation'
        );
      }
      
      // Track screen view
      navigationTracker.trackScreenView(
        currentRoute,
        route.params
      );
      
      previousRouteName.current = currentRoute;
    });

    return unsubscribe;
  }, [navigation, route]);

  const trackScreen = (screenName: string, params?: Record<string, any>) => {
    navigationTracker.trackScreenView(screenName, params);
  };

  return { trackScreen };
};
```

---

## User Identification

### User Identity Management

```typescript
// src/analytics/UserIdentity.ts
import { analytics } from './AnalyticsService';
import { eventTracker } from './EventTracker';

/**
 * User Identity Management
 * 
 * This provides comprehensive user identity management:
 * - User identification
 * - User property tracking
 * - Anonymous tracking
 * - Cross-device identity
 */

export interface UserIdentity {
  id: string;
  email?: string;
  name?: string;
  role?: 'user' | 'admin' | 'tester';
  company?: string;
  plan?: 'free' | 'pro' | 'enterprise';
  signUpDate?: string;
  lastLogin?: string;
  preferences?: Record<string, any>;
}

export class UserIdentityManager {
  private static instance: UserIdentityManager;
  private currentUser: UserIdentity | null = null;
  private anonymousId: string | null = null;

  private constructor() {
    this.anonymousId = this.generateAnonymousId();
  }

  static getInstance(): UserIdentityManager {
    if (!UserIdentityManager.instance) {
      UserIdentityManager.instance = new UserIdentityManager();
    }
    return UserIdentityManager.instance;
  }

  /**
   * Identify user
   */
  identifyUser(user: UserIdentity): void {
    this.currentUser = user;

    // Update analytics
    analytics.identifyUser({
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      signUpDate: user.signUpDate,
      preferences: user.preferences,
    });

    // Track user identification
    eventTracker.trackJourneyStep('user_identified', {
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    // Merge anonymous data
    this.mergeAnonymousData();
  }

  /**
   * Update user properties
   */
  updateUserProperties(properties: Partial<UserIdentity>): void {
    if (this.currentUser) {
      this.currentUser = { ...this.currentUser, ...properties };
      
      // Update analytics
      analytics.setUserProperty('user', this.currentUser);
    }
  }

  /**
   * Get current user
   */
  getCurrentUser(): UserIdentity | null {
    return this.currentUser;
  }

  /**
   * Get anonymous ID
   */
  getAnonymousId(): string {
    return this.anonymousId || '';
  }

  /**
   * Generate anonymous ID
   */
  private generateAnonymousId(): string {
    return `anon-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
  }

  /**
   * Merge anonymous data
   */
  private mergeAnonymousData(): void {
    // In production, merge anonymous session data with user
    // This would include: session history, anonymous events, etc.
  }

  /**
   * Clear user identity
   */
  clearUser(): void {
    this.currentUser = null;
    analytics.reset();
  }

  /**
   * Check if user is identified
   */
  isIdentified(): boolean {
    return !!this.currentUser;
  }
}

export const userIdentity = UserIdentityManager.getInstance();
```

---

## Feature Usage Analytics

### Feature Usage Tracking

```typescript
// src/analytics/FeatureUsage.ts
import { analytics } from './AnalyticsService';
import { eventTracker } from './EventTracker';

/**
 * Feature Usage Analytics
 * 
 * This provides comprehensive feature usage tracking:
 * - Feature adoption metrics
 * - Feature usage frequency
 * - Feature abandonment tracking
 * - Feature success metrics
 */

export interface FeatureUsage {
  featureId: string;
  featureName: string;
  category: string;
  firstUse: number;
  lastUse: number;
  useCount: number;
  successRate: number;
  averageTime: number;
}

export class FeatureUsageTracker {
  private static instance: FeatureUsageTracker;
  private usageData: Map<string, FeatureUsage> = new Map();
  private sessionStartTimes: Map<string, number> = new Map();

  private constructor() {}

  static getInstance(): FeatureUsageTracker {
    if (!FeatureUsageTracker.instance) {
      FeatureUsageTracker.instance = new FeatureUsageTracker();
    }
    return FeatureUsageTracker.instance;
  }

  /**
   * Track feature start
   */
  trackFeatureStart(featureId: string, featureName: string, category: string): void {
    this.sessionStartTimes.set(featureId, Date.now());

    // Track usage start
    analytics.track('feature_usage_start', {
      feature_id: featureId,
      feature_name: featureName,
      category,
    });
  }

  /**
   * Track feature completion
   */
  trackFeatureComplete(
    featureId: string,
    success: boolean,
    error?: string
  ): void {
    const startTime = this.sessionStartTimes.get(featureId);
    const duration = startTime ? Date.now() - startTime : 0;

    // Update usage data
    const usage = this.usageData.get(featureId) || {
      featureId,
      featureName: '',
      category: '',
      firstUse: Date.now(),
      lastUse: Date.now(),
      useCount: 0,
      successRate: 0,
      averageTime: 0,
    };

    usage.lastUse = Date.now();
    usage.useCount++;
    usage.successRate = ((usage.successRate * (usage.useCount - 1)) + (success ? 1 : 0)) / usage.useCount;
    usage.averageTime = ((usage.averageTime * (usage.useCount - 1)) + duration) / usage.useCount;

    this.usageData.set(featureId, usage);

    // Track completion
    analytics.track('feature_usage_complete', {
      feature_id: featureId,
      success,
      duration,
      error,
    });

    // Track journey if successful
    if (success) {
      eventTracker.trackJourneyStep(`feature_${featureId}_success`, { duration });
    }

    // Clear session time
    this.sessionStartTimes.delete(featureId);
  }

  /**
   * Track feature adoption
   */
  trackFeatureAdoption(featureId: string, userId: string): void {
    analytics.track('feature_adoption', {
      feature_id: featureId,
      user_id: userId,
      first_time: true,
    });
  }

  /**
   * Get feature usage data
   */
  getFeatureUsage(featureId: string): FeatureUsage | null {
    return this.usageData.get(featureId) || null;
  }

  /**
   * Get all feature usage data
   */
  getAllFeatureUsage(): FeatureUsage[] {
    return Array.from(this.usageData.values());
  }

  /**
   * Get feature usage statistics
   */
  getFeatureStats(): {
    totalFeatures: number;
    adoptedFeatures: number;
    abandonedFeatures: number;
    mostUsed: string[];
    avgSuccessRate: number;
  } {
    const features = this.getAllFeatureUsage();
    const adopted = features.filter(f => f.useCount > 0);
    const abandoned = features.filter(f => {
      const daysSinceLastUse = (Date.now() - f.lastUse) / (1000 * 60 * 60 * 24);
      return daysSinceLastUse > 30;
    });

    const mostUsed = features
      .sort((a, b) => b.useCount - a.useCount)
      .slice(0, 5)
      .map(f => f.featureName);

    const avgSuccess = features.reduce((sum, f) => sum + f.successRate, 0) / features.length;

    return {
      totalFeatures: features.length,
      adoptedFeatures: adopted.length,
      abandonedFeatures: abandoned.length,
      mostUsed,
      avgSuccessRate: avgSuccess || 0,
    };
  }

  /**
   * Reset feature usage data
   */
  reset(): void {
    this.usageData.clear();
    this.sessionStartTimes.clear();
  }
}

export const featureUsage = FeatureUsageTracker.getInstance();
```

---

## Analytics Dashboard & Reporting

### Analytics Reporting System

```typescript
// src/analytics/Reporting.ts
import { analytics } from './AnalyticsService';
import { eventTracker } from './EventTracker';
import { featureUsage } from './FeatureUsage';

/**
 * Analytics Reporting System
 * 
 * This provides comprehensive analytics reporting:
 * - Dashboard metrics
 * - User engagement reports
 * - Feature adoption reports
 * - Performance reports
 * - Custom reports
 */

export interface Metric {
  name: string;
  value: number;
  change: number;
  trend: 'up' | 'down' | 'stable';
  target?: number;
}

export interface Report {
  id: string;
  name: string;
  date: string;
  metrics: Metric[];
  insights: string[];
  recommendations: string[];
}

export class AnalyticsReporting {
  private static instance: AnalyticsReporting;
  private reports: Report[] = [];

  private constructor() {}

  static getInstance(): AnalyticsReporting {
    if (!AnalyticsReporting.instance) {
      AnalyticsReporting.instance = new AnalyticsReporting();
    }
    return AnalyticsReporting.instance;
  }

  /**
   * Generate daily report
   */
  generateDailyReport(): Report {
    const metrics = this.collectMetrics();
    const insights = this.generateInsights(metrics);
    const recommendations = this.generateRecommendations(metrics);

    const report: Report = {
      id: `report-${Date.now()}`,
      name: 'Daily Analytics Report',
      date: new Date().toISOString().split('T')[0],
      metrics,
      insights,
      recommendations,
    };

    this.reports.push(report);
    return report;
  }

  /**
   * Collect metrics
   */
  private collectMetrics(): Metric[] {
    // In production, collect from analytics providers
    // For demo, return sample metrics
    return [
      {
        name: 'Daily Active Users',
        value: 1250,
        change: 5.2,
        trend: 'up',
        target: 1500,
      },
      {
        name: 'Session Duration',
        value: 4.8,
        change: -2.1,
        trend: 'down',
        target: 5.5,
      },
      {
        name: 'Task Completion Rate',
        value: 68.5,
        change: 3.8,
        trend: 'up',
        target: 75,
      },
      {
        name: 'Feature Adoption',
        value: 42.3,
        change: 8.5,
        trend: 'up',
        target: 50,
      },
      {
        name: 'App Crashes',
        value: 0.8,
        change: -0.3,
        trend: 'down',
        target: 1.0,
      },
      {
        name: 'User Retention',
        value: 82.1,
        change: 1.2,
        trend: 'up',
        target: 85,
      },
    ];
  }

  /**
   * Generate insights
   */
  private generateInsights(metrics: Metric[]): string[] {
    const insights: string[] = [];

    metrics.forEach(metric => {
      if (metric.trend === 'up' && metric.change > 5) {
        insights.push(`${metric.name} is showing strong growth (+${metric.change}%)`);
      } else if (metric.trend === 'down' && metric.change < -5) {
        insights.push(`${metric.name} is declining (${metric.change}%). Investigation recommended.`);
      } else if (metric.value < (metric.target || 0) * 0.8) {
        insights.push(`${metric.name} is below target. Consider implementing improvement strategies.`);
      }
    });

    if (insights.length === 0) {
      insights.push('All metrics are stable. Continue current strategies.');
    }

    return insights;
  }

  /**
   * Generate recommendations
   */
  private generateRecommendations(metrics: Metric[]): string[] {
    const recommendations: string[] = [];

    const sessionMetric = metrics.find(m => m.name === 'Session Duration');
    if (sessionMetric && sessionMetric.trend === 'down') {
      recommendations.push('Investigate session duration drop. Review onboarding and engagement features.');
    }

    const taskMetric = metrics.find(m => m.name === 'Task Completion Rate');
    if (taskMetric && taskMetric.value < 70) {
      recommendations.push('Improve task completion flow. Consider simplifying the task creation process.');
    }

    const crashMetric = metrics.find(m => m.name === 'App Crashes');
    if (crashMetric && crashMetric.value > 1) {
      recommendations.push('Address crash issues. Review error logs and prioritize bug fixes.');
    }

    if (recommendations.length === 0) {
      recommendations.push('Continue monitoring metrics. Consider A/B testing for new features.');
    }

    return recommendations;
  }

  /**
   * Get all reports
   */
  getReports(): Report[] {
    return this.reports;
  }

  /**
   * Get report by ID
   */
  getReport(id: string): Report | null {
    return this.reports.find(r => r.id === id) || null;
  }

  /**
   * Export report as markdown
   */
  exportReportMarkdown(report: Report): string {
    let markdown = `# ${report.name}\n\n`;
    markdown += `**Date:** ${report.date}\n\n`;
    markdown += `## Metrics\n\n`;

    markdown += '| Metric | Value | Change | Trend | Target |\n';
    markdown += '|--------|--------|--------|--------|--------|\n';

    report.metrics.forEach(metric => {
      const trendIcon = metric.trend === 'up' ? '📈' : metric.trend === 'down' ? '📉' : '➡️';
      markdown += `| ${metric.name} | ${metric.value}${metric.value > 100 ? '' : '%'} | ${metric.change > 0 ? '+' : ''}${metric.change}% | ${trendIcon} | ${metric.target || '-'} |\n`;
    });

    markdown += `\n## Insights\n\n`;
    report.insights.forEach(insight => {
      markdown += `- ${insight}\n`;
    });

    markdown += `\n## Recommendations\n\n`;
    report.recommendations.forEach(rec => {
      markdown += `- ${rec}\n`;
    });

    return markdown;
  }
}

export const analyticsReporting = AnalyticsReporting.getInstance();
```

---

## Quick Reference: Analytics Commands

```bash
# Analytics commands
npm run analytics:check       # Check analytics service status
npm run analytics:events      # List recent events
npm run analytics:report      # Generate daily report
npm run analytics:export      # Export analytics data

# User tracking
npm run analytics:identify    # Identify current user
npm run analytics:track       # Track a custom event

# Feature analytics
npm run analytics:features    # View feature usage
npm run analytics:adoption    # View feature adoption metrics
```

---

This appendix provides a comprehensive analytics and user tracking framework for your React Native application. By implementing these patterns, you'll gain valuable insights into user behavior, feature adoption, and app performance to drive data-informed decisions.

