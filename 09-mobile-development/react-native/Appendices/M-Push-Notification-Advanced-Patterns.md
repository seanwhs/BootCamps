# Appendix M: Push Notification Advanced Patterns

Welcome to Appendix M! This comprehensive guide covers advanced push notification patterns for React Native applications. You'll learn how to build sophisticated notification systems with rich media, interactive actions, scheduled delivery, and deep linking integration.

---

## Table of Contents

1. [Push Notification Architecture](#push-notification-architecture)
2. [Rich Media Notifications](#rich-media-notifications)
3. [Interactive Notifications](#interactive-notifications)
4. [Scheduled Notifications](#scheduled-notifications)
5. [Notification Segmentation](#notification-segmentation)
6. [A/B Testing Notifications](#ab-testing-notifications)
7. [Analytics & Tracking](#analytics--tracking)
8. [Delivery Optimization](#delivery-optimization)

---

## Push Notification Architecture

### Complete Notification Architecture

```typescript
// src/notifications/architecture.ts
/**
 * Push Notification Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     NOTIFICATION SERVICE                       │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
 * │  │  │   Firebase  │  │   Expo      │  │   APNs      │   │   │
 * │  │  │   Cloud     │  │   Notifica- │  │   (Apple)   │   │   │
 * │  │  │   Messaging │  │   tions     │  │             │   │   │
 * │  │  └─────────────┘  └─────────────┘  └─────────────┘   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * │                              │                                  │
 * │                              ▼                                  │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │              NOTIFICATION ENGINE                        │   │
 * │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
 * │  │  │  Scheduling │  │  Templates  │  │  Delivery   │   │   │
 * │  │  │  Engine     │  │  Manager    │  │  Optimizer  │   │   │
 * │  │  └─────────────┘  └─────────────┘  └─────────────┘   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * │                              │                                  │
 * │                              ▼                                  │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │              CLIENT LAYER                               │   │
 * │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
 * │  │  │  Device     │  │  Token      │  │  Handler    │   │   │
 * │  │  │  Registry   │  │  Manager    │  │  Registry   │   │   │
 * │  │  └─────────────┘  └─────────────┘  └─────────────┘   │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 */

export const NotificationArchitecture = {
  providers: {
    android: 'Firebase Cloud Messaging (FCM)',
    ios: 'Apple Push Notification Service (APNs)',
    crossPlatform: 'Expo Notifications',
    fallback: 'Web Push',
  },
  
  components: {
    deviceRegistry: 'Manages device tokens and user associations',
    templateManager: 'Manages notification templates and dynamic content',
    scheduler: 'Handles time-based and event-based delivery',
    deliveryOptimizer: 'Optimizes delivery time and channel selection',
    analytics: 'Tracks delivery rates, opens, and conversions',
  },
};
```

---

## Rich Media Notifications

### Rich Media Implementation

```typescript
// src/notifications/RichMediaNotification.ts
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

/**
 * Rich Media Notifications
 * 
 * This provides advanced rich media notification capabilities:
 * - Image attachments
 * - Video attachments
 * - Audio attachments
 * - Custom layouts
 * - Interactive media
 */

export interface RichMediaNotification {
  title: string;
  body: string;
  imageUrl?: string;
  videoUrl?: string;
  audioUrl?: string;
  buttons?: Array<{
    text: string;
    action: string;
  }>;
  category?: string;
  deepLink?: string;
  data?: Record<string, any>;
}

export class RichMediaNotificationService {
  private static instance: RichMediaNotificationService;

  private constructor() {}

  static getInstance(): RichMediaNotificationService {
    if (!RichMediaNotificationService.instance) {
      RichMediaNotificationService.instance = new RichMediaNotificationService();
    }
    return RichMediaNotificationService.instance;
  }

  /**
   * Send rich media notification
   */
  async sendRichNotification(notification: RichMediaNotification): Promise<string> {
    const content: Notifications.NotificationContentInput = {
      title: notification.title,
      body: notification.body,
      data: {
        deepLink: notification.deepLink,
        type: 'rich_media',
        ...notification.data,
      },
      categoryIdentifier: notification.category || 'rich_media',
    };

    // Add media attachments based on platform
    if (Platform.OS === 'ios') {
      // iOS rich media support
      if (notification.imageUrl) {
        // @ts-ignore - iOS specific
        content.attachments = [{
          url: notification.imageUrl,
          type: 'image',
        }];
      }
    }

    if (Platform.OS === 'android') {
      // Android rich media support
      // FCM supports image in notification payload
      // @ts-ignore - Android specific
      content.android = {
        imageUrl: notification.imageUrl,
      };
    }

    // Send notification
    const notificationId = await Notifications.scheduleNotificationAsync({
      content,
      trigger: null, // Send immediately
    });

    return notificationId;
  }

  /**
   * Send carousel notification (multiple images)
   */
  async sendCarouselNotification(
    title: string,
    body: string,
    images: string[],
    data?: Record<string, any>
  ): Promise<string> {
    // Carousel notifications are platform-specific
    // iOS supports this via rich media attachments
    // Android via FCM custom layouts
    
    const content: Notifications.NotificationContentInput = {
      title,
      body,
      data: {
        type: 'carousel',
        images: JSON.stringify(images),
        ...data,
      },
      categoryIdentifier: 'carousel',
    };

    if (Platform.OS === 'ios' && images.length > 0) {
      // @ts-ignore - iOS specific
      content.attachments = images.map(url => ({
        url,
        type: 'image',
      }));
    }

    return Notifications.scheduleNotificationAsync({
      content,
      trigger: null,
    });
  }

  /**
   * Create interactive buttons
   */
  createInteractiveButtons(buttons: Array<{ text: string; action: string }>): any {
    // In production, create notification categories with actions
    // This is platform-specific implementation
    return {
      buttons: buttons.map(button => ({
        identifier: button.action,
        title: button.text,
        options: {
          foreground: true,
          destructive: button.action === 'delete',
        },
      })),
    };
  }

  /**
   * Download rich media for offline display
   */
  async downloadMedia(url: string): Promise<string> {
    // In production, download and cache media
    console.log(`📥 Downloading media: ${url}`);
    return url;
  }
}

export const richMediaNotification = RichMediaNotificationService.getInstance();
```

---

## Interactive Notifications

### Interactive Notification Implementation

```typescript
// src/notifications/InteractiveNotification.ts
import * as Notifications from 'expo-notifications';
import { Alert, Linking } from 'react-native';

/**
 * Interactive Notifications
 * 
 * This provides interactive notification capabilities:
 * - Action buttons
 * - Text input responses
 * - Rating feedback
 * - Quick replies
 * - Deep linking actions
 */

export interface InteractiveNotification {
  title: string;
  body: string;
  actions: Array<{
    id: string;
    title: string;
    type: 'button' | 'input' | 'rating';
    destructive?: boolean;
    placeholder?: string;
  }>;
  category: string;
  deepLink?: string;
  data?: Record<string, any>;
}

export class InteractiveNotificationService {
  private static instance: InteractiveNotificationService;
  private actionHandlers: Map<string, (data: any) => void> = new Map();

  private constructor() {
    this.setupNotificationListeners();
  }

  static getInstance(): InteractiveNotificationService {
    if (!InteractiveNotificationService.instance) {
      InteractiveNotificationService.instance = new InteractiveNotificationService();
    }
    return InteractiveNotificationService.instance;
  }

  /**
   * Setup notification listeners
   */
  private setupNotificationListeners() {
    // Handle notification responses
    Notifications.addNotificationResponseReceivedListener((response) => {
      const { actionIdentifier, notification } = response;
      const data = notification.request.content.data;

      // Check if action handler exists
      const handler = this.actionHandlers.get(actionIdentifier);
      if (handler) {
        handler(data);
      }

      // Handle default actions
      if (actionIdentifier === Notifications.DEFAULT_ACTION_IDENTIFIER) {
        // Default tap action - handle deep link
        this.handleDefaultAction(data);
      }

      // Handle dismiss action
      if (actionIdentifier === 'dismiss') {
        this.handleDismissAction(data);
      }

      // Handle custom actions
      switch (actionIdentifier) {
        case 'reply':
          this.handleReplyAction(data);
          break;
        case 'complete':
          this.handleCompleteAction(data);
          break;
        case 'snooze':
          this.handleSnoozeAction(data);
          break;
        case 'rate':
          this.handleRatingAction(data);
          break;
      }
    });
  }

  /**
   * Register action handler
   */
  registerActionHandler(actionId: string, handler: (data: any) => void): void {
    this.actionHandlers.set(actionId, handler);
  }

  /**
   * Send interactive notification
   */
  async sendInteractiveNotification(
    notification: InteractiveNotification
  ): Promise<string> {
    // Register categories with actions
    await this.registerNotificationCategory(notification.category, notification.actions);

    const content: Notifications.NotificationContentInput = {
      title: notification.title,
      body: notification.body,
      data: {
        deepLink: notification.deepLink,
        category: notification.category,
        ...notification.data,
      },
      categoryIdentifier: notification.category,
    };

    // Send notification
    const notificationId = await Notifications.scheduleNotificationAsync({
      content,
      trigger: null,
    });

    return notificationId;
  }

  /**
   * Register notification category with actions
   */
  private async registerNotificationCategory(
    categoryId: string,
    actions: InteractiveNotification['actions']
  ): Promise<void> {
    // In production, register with iOS APNs
    if (Platform.OS === 'ios') {
      // Register category with actions
    }

    // Android uses different mechanism
    if (Platform.OS === 'android') {
      // Register with FCM
    }
  }

  /**
   * Handle default action (tap notification)
   */
  private handleDefaultAction(data: any): void {
    const deepLink = data?.deepLink;
    if (deepLink) {
      Linking.openURL(deepLink).catch(error => {
        console.error('Failed to open deep link:', error);
      });
    }
  }

  /**
   * Handle dismiss action
   */
  private handleDismissAction(data: any): void {
    // Track dismissal
    console.log('Notification dismissed:', data);
  }

  /**
   * Handle reply action
   */
  private handleReplyAction(data: any): void {
    // Show reply input
    Alert.prompt(
      'Reply',
      'Enter your reply',
      [
        {
          text: 'Send',
          onPress: (text) => {
            console.log('Reply sent:', text);
          },
        },
        { text: 'Cancel', style: 'cancel' },
      ],
      'plain-text'
    );
  }

  /**
   * Handle complete action
   */
  private handleCompleteAction(data: any): void {
    // Complete the task
    console.log('Task completed:', data);
  }

  /**
   * Handle snooze action
   */
  private handleSnoozeAction(data: any): void {
    // Snooze notification
    console.log('Notification snoozed:', data);
  }

  /**
   * Handle rating action
   */
  private handleRatingAction(data: any): void {
    // Show rating prompt
    Alert.alert(
      'Rate TaskFlow',
      'How would you rate your experience?',
      [
        { text: '⭐⭐⭐', onPress: () => console.log('Rated 3 stars') },
        { text: '⭐⭐⭐⭐', onPress: () => console.log('Rated 4 stars') },
        { text: '⭐⭐⭐⭐⭐', onPress: () => console.log('Rated 5 stars') },
        { text: 'Cancel', style: 'cancel' },
      ],
      { cancelable: true }
    );
  }

  /**
   * Create quick reply action
   */
  createQuickReplyAction(placeholder: string, actionId: string = 'reply'): any {
    return {
      id: actionId,
      title: 'Reply',
      type: 'input' as const,
      placeholder,
    };
  }

  /**
   * Create completion action
   */
  createCompletionAction(actionId: string = 'complete'): any {
    return {
      id: actionId,
      title: '✅ Complete',
      type: 'button' as const,
    };
  }

  /**
   * Create snooze action
   */
  createSnoozeAction(actionId: string = 'snooze'): any {
    return {
      id: actionId,
      title: '⏰ Snooze',
      type: 'button' as const,
    };
  }

  /**
   * Create rating action
   */
  createRatingAction(actionId: string = 'rate'): any {
    return {
      id: actionId,
      title: '⭐ Rate',
      type: 'rating' as const,
    };
  }
}

export const interactiveNotification = InteractiveNotificationService.getInstance();
```

---

## Scheduled Notifications

### Advanced Scheduling System

```typescript
// src/notifications/ScheduledNotification.ts
import * as Notifications from 'expo-notifications';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { addDays, addWeeks, addMonths, differenceInSeconds } from 'date-fns';

/**
 * Scheduled Notifications
 * 
 * This provides advanced scheduling capabilities:
 * - Time-based scheduling
 * - Recurring schedules
 * - Smart scheduling
 * - User time zones
 * - Delivery windows
 */

export interface ScheduleConfig {
  id: string;
  type: 'once' | 'daily' | 'weekly' | 'monthly' | 'custom';
  startDate: Date;
  endDate?: Date;
  interval?: number; // In seconds
  daysOfWeek?: number[]; // 0 = Sunday, 1 = Monday, etc.
  timeOfDay?: { hour: number; minute: number };
  timezone?: string;
}

export interface ScheduledNotification {
  id: string;
  title: string;
  body: string;
  schedule: ScheduleConfig;
  data?: Record<string, any>;
  lastSent?: Date;
  nextSend?: Date;
  active: boolean;
}

export class ScheduledNotificationService {
  private static instance: ScheduledNotificationService;
  private schedules: Map<string, ScheduledNotification> = new Map();
  private timerInterval: NodeJS.Timeout | null = null;

  private constructor() {
    this.loadSchedules();
    this.startScheduler();
  }

  static getInstance(): ScheduledNotificationService {
    if (!ScheduledNotificationService.instance) {
      ScheduledNotificationService.instance = new ScheduledNotificationService();
    }
    return ScheduledNotificationService.instance;
  }

  /**
   * Load schedules from storage
   */
  private async loadSchedules(): Promise<void> {
    try {
      const data = await AsyncStorage.getItem('notification_schedules');
      if (data) {
        const schedules = JSON.parse(data);
        schedules.forEach((schedule: ScheduledNotification) => {
          this.schedules.set(schedule.id, {
            ...schedule,
            schedule: {
              ...schedule.schedule,
              startDate: new Date(schedule.schedule.startDate),
              endDate: schedule.schedule.endDate ? new Date(schedule.schedule.endDate) : undefined,
            },
          });
        });
      }
    } catch (error) {
      console.error('Failed to load schedules:', error);
    }
  }

  /**
   * Save schedules to storage
   */
  private async saveSchedules(): Promise<void> {
    try {
      const schedules = Array.from(this.schedules.values());
      await AsyncStorage.setItem('notification_schedules', JSON.stringify(schedules));
    } catch (error) {
      console.error('Failed to save schedules:', error);
    }
  }

  /**
   * Start scheduler
   */
  private startScheduler(): void {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }

    this.timerInterval = setInterval(() => {
      this.processSchedules();
    }, 60000); // Check every minute
  }

  /**
   * Process schedules
   */
  private async processSchedules(): Promise<void> {
    const now = new Date();

    for (const [id, schedule] of this.schedules) {
      if (!schedule.active) continue;

      // Check if schedule should run
      if (this.shouldRunSchedule(schedule, now)) {
        // Send notification
        await this.sendScheduledNotification(schedule);

        // Update last sent
        schedule.lastSent = now;
        schedule.nextSend = this.calculateNextSend(schedule, now);

        // Save changes
        await this.saveSchedules();
      }
    }
  }

  /**
   * Check if schedule should run
   */
  private shouldRunSchedule(schedule: ScheduledNotification, now: Date): boolean {
    const { schedule: config } = schedule;

    // Check if schedule has expired
    if (config.endDate && now > config.endDate) {
      schedule.active = false;
      return false;
    }

    // Check if we've already sent at this time
    if (schedule.lastSent) {
      const lastSendMinutes = Math.floor(schedule.lastSent.getTime() / 60000);
      const currentMinutes = Math.floor(now.getTime() / 60000);
      if (lastSendMinutes === currentMinutes) {
        return false;
      }
    }

    // Check schedule type
    switch (config.type) {
      case 'once':
        return this.shouldRunOnce(now, config);
      case 'daily':
        return this.shouldRunDaily(now, config);
      case 'weekly':
        return this.shouldRunWeekly(now, config);
      case 'monthly':
        return this.shouldRunMonthly(now, config);
      case 'custom':
        return this.shouldRunCustom(now, config);
      default:
        return false;
    }
  }

  /**
   * Check once schedule
   */
  private shouldRunOnce(now: Date, config: ScheduleConfig): boolean {
    return now >= config.startDate;
  }

  /**
   * Check daily schedule
   */
  private shouldRunDaily(now: Date, config: ScheduleConfig): boolean {
    if (!config.timeOfDay) return false;

    const { hour, minute } = config.timeOfDay;
    return now.getHours() === hour && now.getMinutes() === minute;
  }

  /**
   * Check weekly schedule
   */
  private shouldRunWeekly(now: Date, config: ScheduleConfig): boolean {
    if (!config.timeOfDay || !config.daysOfWeek) return false;

    const { hour, minute } = config.timeOfDay;
    const currentDay = now.getDay();

    return (
      config.daysOfWeek.includes(currentDay) &&
      now.getHours() === hour &&
      now.getMinutes() === minute
    );
  }

  /**
   * Check monthly schedule
   */
  private shouldRunMonthly(now: Date, config: ScheduleConfig): boolean {
    if (!config.timeOfDay) return false;

    const { hour, minute } = config.timeOfDay;
    const startDate = config.startDate;

    return (
      now.getDate() === startDate.getDate() &&
      now.getHours() === hour &&
      now.getMinutes() === minute
    );
  }

  /**
   * Check custom schedule
   */
  private shouldRunCustom(now: Date, config: ScheduleConfig): boolean {
    if (!config.interval) return false;

    const timeSinceStart = differenceInSeconds(now, config.startDate);
    return timeSinceStart % config.interval === 0;
  }

  /**
   * Calculate next send time
   */
  private calculateNextSend(schedule: ScheduledNotification, now: Date): Date {
    const { schedule: config } = schedule;

    switch (config.type) {
      case 'once':
        return config.endDate || now;
      case 'daily':
        return addDays(now, 1);
      case 'weekly':
        return addWeeks(now, 1);
      case 'monthly':
        return addMonths(now, 1);
      case 'custom':
        return new Date(now.getTime() + (config.interval || 0) * 1000);
      default:
        return now;
    }
  }

  /**
   * Send scheduled notification
   */
  private async sendScheduledNotification(schedule: ScheduledNotification): Promise<void> {
    try {
      await Notifications.scheduleNotificationAsync({
        content: {
          title: schedule.title,
          body: schedule.body,
          data: {
            scheduledId: schedule.id,
            ...schedule.data,
          },
        },
        trigger: null, // Send immediately
      });

      console.log(`📬 Sent scheduled notification: ${schedule.id}`);
    } catch (error) {
      console.error('Failed to send scheduled notification:', error);
    }
  }

  /**
   * Create a scheduled notification
   */
  async createScheduledNotification(
    config: Omit<ScheduledNotification, 'id' | 'active' | 'lastSent' | 'nextSend'>
  ): Promise<string> {
    const id = `schedule-${Date.now()}`;
    
    const schedule: ScheduledNotification = {
      id,
      ...config,
      active: true,
      lastSent: undefined,
      nextSend: config.schedule.startDate,
    };

    this.schedules.set(id, schedule);
    await this.saveSchedules();

    return id;
  }

  /**
   * Update scheduled notification
   */
  async updateScheduledNotification(
    id: string,
    updates: Partial<ScheduledNotification>
  ): Promise<void> {
    const schedule = this.schedules.get(id);
    if (!schedule) {
      throw new Error('Schedule not found');
    }

    Object.assign(schedule, updates);
    await this.saveSchedules();
  }

  /**
   * Delete scheduled notification
   */
  async deleteScheduledNotification(id: string): Promise<void> {
    this.schedules.delete(id);
    await this.saveSchedules();
  }

  /**
   * Get all schedules
   */
  getSchedules(): ScheduledNotification[] {
    return Array.from(this.schedules.values());
  }

  /**
   * Get schedule by ID
   */
  getSchedule(id: string): ScheduledNotification | undefined {
    return this.schedules.get(id);
  }

  /**
   * Pause schedule
   */
  async pauseSchedule(id: string): Promise<void> {
    const schedule = this.schedules.get(id);
    if (schedule) {
      schedule.active = false;
      await this.saveSchedules();
    }
  }

  /**
   * Resume schedule
   */
  async resumeSchedule(id: string): Promise<void> {
    const schedule = this.schedules.get(id);
    if (schedule) {
      schedule.active = true;
      await this.saveSchedules();
    }
  }

  /**
   * Clean up
   */
  cleanup(): void {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }
  }
}

export const scheduledNotification = ScheduledNotificationService.getInstance();
```

---

## Notification Segmentation

### Segmentation Implementation

```typescript
// src/notifications/NotificationSegmentation.ts
import { UserIdentity } from '../analytics/UserIdentity';

/**
 * Notification Segmentation
 * 
 * This provides advanced segmentation capabilities:
 * - User segment definition
 * - Dynamic segmentation
 * - Behavioral targeting
 * - A/B test segments
 * - Personalization
 */

export interface UserSegment {
  id: string;
  name: string;
  condition: (user: UserIdentity) => boolean;
  description: string;
  priority: number;
}

export class NotificationSegmentation {
  private static instance: NotificationSegmentation;
  private segments: UserSegment[] = [];

  private constructor() {
    this.initializeDefaultSegments();
  }

  static getInstance(): NotificationSegmentation {
    if (!NotificationSegmentation.instance) {
      NotificationSegmentation.instance = new NotificationSegmentation();
    }
    return NotificationSegmentation.instance;
  }

  /**
   * Initialize default segments
   */
  private initializeDefaultSegments() {
    // All users
    this.segments.push({
      id: 'all',
      name: 'All Users',
      condition: () => true,
      description: 'All users of the app',
      priority: 0,
    });

    // New users
    this.segments.push({
      id: 'new_users',
      name: 'New Users',
      condition: (user) => {
        if (!user.signUpDate) return false;
        const signUpDate = new Date(user.signUpDate);
        const daysSinceSignUp = (Date.now() - signUpDate.getTime()) / (1000 * 60 * 60 * 24);
        return daysSinceSignUp < 7;
      },
      description: 'Users who signed up in the last 7 days',
      priority: 10,
    });

    // Pro users
    this.segments.push({
      id: 'pro_users',
      name: 'Pro Users',
      condition: (user) => user.plan === 'pro' || user.plan === 'enterprise',
      description: 'Users on Pro or Enterprise plans',
      priority: 20,
    });

    // Inactive users
    this.segments.push({
      id: 'inactive_users',
      name: 'Inactive Users',
      condition: (user) => {
        if (!user.lastLogin) return false;
        const lastLogin = new Date(user.lastLogin);
        const daysSinceLastLogin = (Date.now() - lastLogin.getTime()) / (1000 * 60 * 60 * 24);
        return daysSinceLastLogin > 30;
      },
      description: 'Users who haven\'t logged in for 30+ days',
      priority: 30,
    });

    // High engagement users
    this.segments.push({
      id: 'high_engagement',
      name: 'High Engagement',
      condition: (user) => {
        // In production, use real engagement metrics
        return false;
      },
      description: 'Users with high engagement scores',
      priority: 40,
    });

    // Premium trial users
    this.segments.push({
      id: 'trial_users',
      name: 'Trial Users',
      condition: (user) => user.plan === 'trial',
      description: 'Users on trial plans',
      priority: 25,
    });
  }

  /**
   * Add custom segment
   */
  addSegment(segment: UserSegment): void {
    // Sort by priority
    this.segments.push(segment);
    this.segments.sort((a, b) => a.priority - b.priority);
  }

  /**
   * Remove segment
   */
  removeSegment(segmentId: string): void {
    this.segments = this.segments.filter(s => s.id !== segmentId);
  }

  /**
   * Get segments for a user
   */
  getUserSegments(user: UserIdentity): UserSegment[] {
    return this.segments.filter(segment => segment.condition(user));
  }

  /**
   * Get users in a segment
   */
  async getUsersInSegment(segmentId: string): Promise<UserIdentity[]> {
    const segment = this.segments.find(s => s.id === segmentId);
    if (!segment) return [];

    // In production, query users that match condition
    // For demo, return mock users
    return [
      {
        id: 'user1',
        email: 'demo@example.com',
        name: 'Demo User',
        role: 'user',
        signUpDate: new Date().toISOString(),
      },
    ];
  }

  /**
   * Get segment by ID
   */
  getSegment(id: string): UserSegment | undefined {
    return this.segments.find(s => s.id === id);
  }

  /**
   * Get all segments
   */
  getAllSegments(): UserSegment[] {
    return this.segments;
  }

  /**
   * Segment overlap analysis
   */
  analyzeSegmentOverlaps(users: UserIdentity[]): Record<string, number> {
    const overlaps: Record<string, number> = {};

    users.forEach(user => {
      const userSegments = this.getUserSegments(user);
      userSegments.forEach(segment => {
        overlaps[segment.id] = (overlaps[segment.id] || 0) + 1;
      });
    });

    return overlaps;
  }
}

export const notificationSegmentation = NotificationSegmentation.getInstance();
```

---

## Quick Reference: Notification Commands

```bash
# Notification commands
npm run notifications:send      # Send a test notification
npm run notifications:schedule  # Schedule a notification
npm run notifications:list      # List scheduled notifications
npm run notifications:clear     # Clear all notifications
npm run notifications:segments  # List user segments

# Rich media commands
npm run notifications:rich      # Send rich media notification
npm run notifications:carousel  # Send carousel notification

# Interactive commands
npm run notifications:interactive # Send interactive notification
npm run notifications:actions     # List notification actions
```

---

This appendix provides advanced push notification patterns for your React Native application. By implementing these patterns, you'll create engaging, personalized, and effective notification experiences for your users.
