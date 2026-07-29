# Appendix H: Internationalization (i18n)

Welcome to Appendix H! This comprehensive guide covers everything you need to know about making your React Native app available in multiple languages and regions. From translation management to localization best practices, you'll learn how to create a truly global application.

---

## Table of Contents

1. [Internationalization Architecture](#internationalization-architecture)
2. [Translation Management](#translation-management)
3. [RTL Language Support](#rtl-language-support)
4. [Date, Time & Number Formatting](#date-time--number-formatting)
5. [Pluralization & Grammar](#pluralization--grammar)
6. [Translation Workflow](#translation-workflow)
7. [Testing Internationalization](#testing-internationalization)
8. [Performance Considerations](#performance-considerations)

---

## Internationalization Architecture

### Complete i18n Setup

```typescript
// src/i18n/index.ts
import * as Localization from 'expo-localization';
import { I18n } from 'i18n-js';
import { translations } from './translations';
import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Internationalization Configuration
 * 
 * This provides comprehensive i18n setup:
 * - Language detection
 * - Translation loading
 * - Fallback handling
 * - RTL support
 * - Number/date formatting
 */

// Supported languages
export const SUPPORTED_LANGUAGES = [
  { code: 'en', name: 'English', nativeName: 'English', rtl: false },
  { code: 'es', name: 'Spanish', nativeName: 'Español', rtl: false },
  { code: 'fr', name: 'French', nativeName: 'Français', rtl: false },
  { code: 'de', name: 'German', nativeName: 'Deutsch', rtl: false },
  { code: 'ja', name: 'Japanese', nativeName: '日本語', rtl: false },
  { code: 'zh', name: 'Chinese', nativeName: '中文', rtl: false },
  { code: 'ar', name: 'Arabic', nativeName: 'العربية', rtl: true },
  { code: 'he', name: 'Hebrew', nativeName: 'עברית', rtl: true },
];

// Create i18n instance
const i18n = new I18n(translations);

// Set default locale
i18n.defaultLocale = 'en';
i18n.locale = 'en';
i18n.enableFallback = true;

/**
 * I18n Manager
 */
export class I18nManager {
  private static instance: I18nManager;
  private currentLocale: string = 'en';
  private isRTL: boolean = false;
  private listeners: Array<(locale: string) => void> = [];

  private constructor() {}

  static getInstance(): I18nManager {
    if (!I18nManager.instance) {
      I18nManager.instance = new I18nManager();
    }
    return I18nManager.instance;
  }

  /**
   * Initialize i18n
   */
  async initialize(): Promise<void> {
    try {
      // Get saved language preference
      const savedLocale = await AsyncStorage.getItem('app_language');
      
      if (savedLocale && this.isLanguageSupported(savedLocale)) {
        this.setLocale(savedLocale);
        return;
      }

      // Detect device language
      const deviceLocale = this.getDeviceLocale();
      if (this.isLanguageSupported(deviceLocale)) {
        this.setLocale(deviceLocale);
      } else {
        this.setLocale('en');
      }
    } catch (error) {
      console.error('i18n initialization error:', error);
      this.setLocale('en');
    }
  }

  /**
   * Get device locale
   */
  private getDeviceLocale(): string {
    const locales = Localization.getLocales();
    if (locales.length > 0) {
      // Get language code from locale (e.g., 'en-US' -> 'en')
      const locale = locales[0].languageCode || 'en';
      return locale.split('-')[0];
    }
    return 'en';
  }

  /**
   * Check if language is supported
   */
  private isLanguageSupported(locale: string): boolean {
    return SUPPORTED_LANGUAGES.some(lang => lang.code === locale);
  }

  /**
   * Set current locale
   */
  setLocale(locale: string): void {
    if (!this.isLanguageSupported(locale)) {
      console.warn(`Language ${locale} not supported, falling back to English`);
      locale = 'en';
    }

    this.currentLocale = locale;
    i18n.locale = locale;
    
    // Check if RTL
    const langInfo = SUPPORTED_LANGUAGES.find(l => l.code === locale);
    this.isRTL = langInfo?.rtl || false;
    
    // Update RTL in React Native
    if (this.isRTL) {
      // @ts-ignore - React Native I18nManager
      require('react-native').I18nManager.forceRTL(true);
    } else {
      // @ts-ignore - React Native I18nManager
      require('react-native').I18nManager.forceRTL(false);
    }

    // Save preference
    AsyncStorage.setItem('app_language', locale);
    
    // Notify listeners
    this.listeners.forEach(listener => listener(locale));
  }

  /**
   * Get current locale
   */
  getLocale(): string {
    return this.currentLocale;
  }

  /**
   * Check if RTL
   */
  isRTLLocale(): boolean {
    return this.isRTL;
  }

  /**
   * Subscribe to locale changes
   */
  subscribe(listener: (locale: string) => void): () => void {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  /**
   * Translate a key
   */
  t(key: string, params?: Record<string, any>): string {
    return i18n.t(key, params);
  }

  /**
   * Get supported languages
   */
  getSupportedLanguages(): typeof SUPPORTED_LANGUAGES {
    return SUPPORTED_LANGUAGES;
  }

  /**
   * Get language name
   */
  getLanguageName(code: string): string {
    const lang = SUPPORTED_LANGUAGES.find(l => l.code === code);
    return lang?.name || code;
  }

  /**
   * Get native language name
   */
  getNativeLanguageName(code: string): string {
    const lang = SUPPORTED_LANGUAGES.find(l => l.code === code);
    return lang?.nativeName || code;
  }
}

export const i18nManager = I18nManager.getInstance();

// Translation function for easy access
export const t = (key: string, params?: Record<string, any>): string => {
  return i18nManager.t(key, params);
};
```

### Translation Files

```typescript
// src/i18n/translations/index.ts
import en from './en.json';
import es from './es.json';
import fr from './fr.json';
import de from './de.json';
import ja from './ja.json';
import zh from './zh.json';
import ar from './ar.json';
import he from './he.json';

/**
 * Translation Files
 * 
 * All translations are organized by language code.
 * Each translation file follows the same structure.
 */

export const translations = {
  en,
  es,
  fr,
  de,
  ja,
  zh,
  ar,
  he,
};

// src/i18n/translations/en.json
export default {
  common: {
    appName: 'TaskFlow',
    welcome: 'Welcome',
    loading: 'Loading...',
    error: 'Error',
    success: 'Success',
    cancel: 'Cancel',
    confirm: 'Confirm',
    save: 'Save',
    delete: 'Delete',
    edit: 'Edit',
    search: 'Search',
    filter: 'Filter',
    noResults: 'No results found',
    retry: 'Retry',
    done: 'Done',
    back: 'Back',
    next: 'Next',
    continue: 'Continue',
    skip: 'Skip',
  },
  auth: {
    login: {
      title: 'Sign In',
      email: 'Email Address',
      password: 'Password',
      forgotPassword: 'Forgot Password?',
      noAccount: "Don't have an account?",
      signUp: 'Sign Up',
      submit: 'Sign In',
      errors: {
        invalidEmail: 'Please enter a valid email address',
        invalidPassword: 'Password must be at least 6 characters',
        invalidCredentials: 'Invalid email or password',
        accountLocked: 'Account locked. Please try again later',
      },
    },
    register: {
      title: 'Create Account',
      name: 'Full Name',
      email: 'Email Address',
      password: 'Password',
      confirmPassword: 'Confirm Password',
      haveAccount: 'Already have an account?',
      signIn: 'Sign In',
      submit: 'Create Account',
      terms: 'By signing up, you agree to our Terms of Service',
      errors: {
        nameRequired: 'Name is required',
        nameLength: 'Name must be at least 2 characters',
        passwordMismatch: 'Passwords do not match',
        weakPassword: 'Password must include uppercase, lowercase, number, and special character',
      },
    },
  },
  tasks: {
    title: 'My Tasks',
    create: 'Create Task',
    edit: 'Edit Task',
    delete: 'Delete Task',
    deleteConfirm: 'Are you sure you want to delete this task?',
    empty: {
      title: 'No tasks found',
      subtitle: 'Create your first task to get started',
    },
    fields: {
      title: 'Title',
      description: 'Description',
      priority: 'Priority',
      dueDate: 'Due Date',
      category: 'Category',
      assignee: 'Assignee',
      status: 'Status',
      reminder: 'Set Reminder',
    },
    priority: {
      low: 'Low',
      medium: 'Medium',
      high: 'High',
    },
    status: {
      todo: 'To Do',
      inProgress: 'In Progress',
      done: 'Done',
    },
    filters: {
      all: 'All Tasks',
      todo: 'To Do',
      inProgress: 'In Progress',
      done: 'Completed',
    },
    errors: {
      titleRequired: 'Title is required',
      titleLength: 'Title must be at least 3 characters',
      dueDatePast: 'Due date cannot be in the past',
      categoryRequired: 'Category is required',
    },
    messages: {
      created: 'Task created successfully',
      updated: 'Task updated successfully',
      deleted: 'Task deleted successfully',
      completed: 'Task completed! 🎉',
    },
  },
  settings: {
    title: 'Settings',
    general: {
      title: 'General',
      language: 'Language',
      theme: 'Theme',
      notifications: 'Notifications',
      sound: 'Sound',
      vibration: 'Vibration',
    },
    security: {
      title: 'Security',
      biometric: 'Biometric Login',
      changePassword: 'Change Password',
      twoFactor: 'Two-Factor Authentication',
    },
    about: {
      title: 'About',
      version: 'Version',
      privacy: 'Privacy Policy',
      terms: 'Terms of Service',
      feedback: 'Send Feedback',
      rate: 'Rate App',
    },
    theme: {
      light: 'Light',
      dark: 'Dark',
      system: 'System Default',
    },
    language: {
      select: 'Select Language',
    },
  },
  errors: {
    network: 'Network error. Please check your connection.',
    server: 'Server error. Please try again later.',
    unauthorized: 'Unauthorized. Please login again.',
    forbidden: 'Forbidden. You do not have permission.',
    notFound: 'Resource not found.',
    conflict: 'Data conflict. Please refresh and try again.',
    validation: 'Validation failed. Please check your input.',
    unknown: 'An unexpected error occurred. Please try again.',
  },
  notifications: {
    title: 'Notifications',
    empty: 'No notifications',
    taskReminder: 'Task Reminder',
    dueSoon: 'Task "{title}" is due soon!',
    overdue: 'Task "{title}" is overdue!',
    assigned: 'Task "{title}" assigned to you',
    completed: 'Task "{title}" completed by {user}',
    commented: '{user} commented on "{title}"',
  },
};
```

---

## Translation Management

### Translation Management System

```typescript
// src/i18n/TranslationManager.ts
import * as FileSystem from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface TranslationEntry {
  key: string;
  values: Record<string, string>;
  lastUpdated: string;
  needsReview: boolean;
}

/**
 * Translation Management System
 * 
 * This provides comprehensive translation management:
 * - Translation storage
 * - Missing translation tracking
 * - Translation export/import
 * - Review workflow
 */

export class TranslationManager {
  private static instance: TranslationManager;
  private missingTranslations: Map<string, string[]> = new Map();
  private translationCache: Map<string, any> = new Map();

  private constructor() {}

  static getInstance(): TranslationManager {
    if (!TranslationManager.instance) {
      TranslationManager.instance = new TranslationManager();
    }
    return TranslationManager.instance;
  }

  /**
   * Track missing translation
   */
  trackMissingTranslation(locale: string, key: string): void {
    if (!this.missingTranslations.has(locale)) {
      this.missingTranslations.set(locale, []);
    }
    const list = this.missingTranslations.get(locale)!;
    if (!list.includes(key)) {
      list.push(key);
      this.saveMissingTranslations();
    }
  }

  /**
   * Get missing translations
   */
  getMissingTranslations(locale: string): string[] {
    return this.missingTranslations.get(locale) || [];
  }

  /**
   * Clear missing translations
   */
  clearMissingTranslations(locale: string): void {
    this.missingTranslations.set(locale, []);
    this.saveMissingTranslations();
  }

  /**
   * Save missing translations
   */
  private async saveMissingTranslations(): Promise<void> {
    try {
      const data = Array.from(this.missingTranslations.entries());
      await AsyncStorage.setItem('missing_translations', JSON.stringify(data));
    } catch (error) {
      console.error('Error saving missing translations:', error);
    }
  }

  /**
   * Load missing translations
   */
  async loadMissingTranslations(): Promise<void> {
    try {
      const data = await AsyncStorage.getItem('missing_translations');
      if (data) {
        const entries = JSON.parse(data);
        this.missingTranslations = new Map(entries);
      }
    } catch (error) {
      console.error('Error loading missing translations:', error);
    }
  }

  /**
   * Export translations
   */
  async exportTranslations(locale: string): Promise<void> {
    try {
      const translations = await this.getTranslations(locale);
      const jsonString = JSON.stringify(translations, null, 2);
      const filePath = `${FileSystem.documentDirectory}translations_${locale}.json`;
      
      await FileSystem.writeAsStringAsync(filePath, jsonString);
      
      // Share file
      if (await Sharing.isAvailableAsync()) {
        await Sharing.shareAsync(filePath);
      }
    } catch (error) {
      console.error('Error exporting translations:', error);
    }
  }

  /**
   * Import translations
   */
  async importTranslations(fileUri: string, locale: string): Promise<void> {
    try {
      const content = await FileSystem.readAsStringAsync(fileUri);
      const translations = JSON.parse(content);
      
      // Validate and merge translations
      await this.mergeTranslations(locale, translations);
    } catch (error) {
      console.error('Error importing translations:', error);
    }
  }

  /**
   * Get translations for a locale
   */
  private async getTranslations(locale: string): Promise<any> {
    // In production, load from translation files
    // For demo, return empty object
    return {};
  }

  /**
   * Merge translations
   */
  private async mergeTranslations(locale: string, newTranslations: any): Promise<void> {
    // In production, merge with existing translations
    console.log(`Merging translations for ${locale}`);
  }

  /**
   * Get translation coverage
   */
  getTranslationCoverage(): Record<string, number> {
    const coverage: Record<string, number> = {};
    
    SUPPORTED_LANGUAGES.forEach(({ code }) => {
      const missing = this.getMissingTranslations(code).length;
      const total = this.getTotalTranslationKeys();
      coverage[code] = total > 0 ? ((total - missing) / total) * 100 : 0;
    });
    
    return coverage;
  }

  /**
   * Get total translation keys
   */
  private getTotalTranslationKeys(): number {
    // In production, count all translation keys
    return 100; // Placeholder
  }
}

export const translationManager = TranslationManager.getInstance();
```

---

## RTL Language Support

### RTL Support Implementation

```typescript
// src/i18n/RTLSupport.ts
import React from 'react';
import { View, Text, StyleSheet, I18nManager, Platform } from 'react-native';
import { i18nManager } from './index';

/**
 * RTL Support
 * 
 * This provides comprehensive RTL support:
 * - Text alignment
 * - Layout mirroring
 * - Icon flipping
 * - Animation direction
 */

export const RTLSupport: React.FC = () => {
  const isRTL = i18nManager.isRTLLocale();

  return (
    <View style={[styles.container, isRTL && styles.containerRTL]}>
      <RTLTextExample />
      <RTLLayoutExample />
    </View>
  );
};

/**
 * RTL Text Example
 */
const RTLTextExample: React.FC = () => {
  const isRTL = i18nManager.isRTLLocale();

  return (
    <View style={styles.textContainer}>
      <Text
        style={[
          styles.text,
          isRTL && styles.textRTL,
        ]}
      >
        {isRTL ? 'مرحباً بكم في تطبيقنا' : 'Welcome to our app'}
      </Text>
      
      <Text
        style={[
          styles.subtext,
          isRTL && styles.textRTL,
        ]}
      >
        {isRTL ? 'هذا النص يوضح دعم اللغة العربية' : 'This text demonstrates RTL support'}
      </Text>
    </View>
  );
};

/**
 * RTL Layout Example
 */
const RTLLayoutExample: React.FC = () => {
  const isRTL = i18nManager.isRTLLocale();

  return (
    <View style={styles.layoutContainer}>
      <View style={[
        styles.layoutRow,
        isRTL && styles.layoutRowRTL,
      ]}>
        <View style={[styles.layoutItem, styles.layoutItemLeft]} />
        <View style={[styles.layoutItem, styles.layoutItemCenter]} />
        <View style={[styles.layoutItem, styles.layoutItemRight]} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f8f9fa',
  },
  containerRTL: {
    flexDirection: 'row-reverse',
  },
  textContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  text: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
    textAlign: 'left',
  },
  textRTL: {
    textAlign: 'right',
    writingDirection: 'rtl',
  },
  subtext: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 8,
    textAlign: 'left',
  },
  layoutContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
  },
  layoutRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 8,
  },
  layoutRowRTL: {
    flexDirection: 'row-reverse',
  },
  layoutItem: {
    flex: 1,
    height: 60,
    borderRadius: 4,
  },
  layoutItemLeft: {
    backgroundColor: '#3498db',
  },
  layoutItemCenter: {
    backgroundColor: '#2ecc71',
  },
  layoutItemRight: {
    backgroundColor: '#e74c3c',
  },
});

/**
 * RTL Safe Text Component
 */
export const RTLSafeText: React.FC<{
  children: React.ReactNode;
  style?: any;
  [key: string]: any;
}> = ({ children, style, ...props }) => {
  const isRTL = i18nManager.isRTLLocale();

  return (
    <Text
      {...props}
      style={[
        style,
        isRTL && styles.rtlSafeText,
      ]}
      textAlign={isRTL ? 'right' : 'left'}
    >
      {children}
    </Text>
  );
};

/**
 * RTL Safe View Component
 */
export const RTLSafeView: React.FC<{
  children: React.ReactNode;
  style?: any;
  [key: string]: any;
}> = ({ children, style, ...props }) => {
  const isRTL = i18nManager.isRTLLocale();

  return (
    <View
      {...props}
      style={[
        style,
        isRTL && styles.rtlSafeView,
      ]}
    >
      {children}
    </View>
  );
};

export const rtlStyles = StyleSheet.create({
  rtlSafeText: {
    textAlign: 'right',
    writingDirection: 'rtl',
  },
  rtlSafeView: {
    flexDirection: 'row-reverse',
  },
});
```

---

## Date, Time & Number Formatting

### Localized Formatting

```typescript
// src/i18n/Formatters.ts
import { Platform } from 'react-native';
import { i18nManager } from './index';

/**
 * Localized Formatting
 * 
 * This provides comprehensive localized formatting:
 * - Date formatting
 * - Time formatting
 * - Number formatting
 * - Currency formatting
 * - Relative time
 */

export class Formatters {
  private static instance: Formatters;

  private constructor() {}

  static getInstance(): Formatters {
    if (!Formatters.instance) {
      Formatters.instance = new Formatters();
    }
    return Formatters.instance;
  }

  /**
   * Format date
   */
  formatDate(date: Date | string, options: Intl.DateTimeFormatOptions = {}): string {
    const locale = i18nManager.getLocale();
    const defaultOptions: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    };

    const dateObj = typeof date === 'string' ? new Date(date) : date;

    try {
      return new Intl.DateTimeFormat(locale, { ...defaultOptions, ...options }).format(dateObj);
    } catch (error) {
      console.error('Date formatting error:', error);
      return dateObj.toLocaleDateString();
    }
  }

  /**
   * Format time
   */
  formatTime(date: Date | string, options: Intl.DateTimeFormatOptions = {}): string {
    const locale = i18nManager.getLocale();
    const defaultOptions: Intl.DateTimeFormatOptions = {
      hour: 'numeric',
      minute: 'numeric',
    };

    const dateObj = typeof date === 'string' ? new Date(date) : date;

    try {
      return new Intl.DateTimeFormat(locale, { ...defaultOptions, ...options }).format(dateObj);
    } catch (error) {
      console.error('Time formatting error:', error);
      return dateObj.toLocaleTimeString();
    }
  }

  /**
   * Format relative time
   */
  formatRelativeTime(date: Date | string): string {
    const now = new Date();
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    const diffMs = dateObj.getTime() - now.getTime();
    const diffSec = Math.floor(diffMs / 1000);
    const diffMin = Math.floor(diffSec / 60);
    const diffHour = Math.floor(diffMin / 60);
    const diffDay = Math.floor(diffHour / 24);
    const diffMonth = Math.floor(diffDay / 30);
    const diffYear = Math.floor(diffDay / 365);

    const t = i18nManager.t.bind(i18nManager);

    if (diffSec < 0) {
      // Past
      const absSec = Math.abs(diffSec);
      const absMin = Math.abs(diffMin);
      const absHour = Math.abs(diffHour);
      const absDay = Math.abs(diffDay);
      const absMonth = Math.abs(diffMonth);
      const absYear = Math.abs(diffYear);

      if (absSec < 60) return t('time.justNow');
      if (absMin < 60) return t('time.minutesAgo', { count: absMin });
      if (absHour < 24) return t('time.hoursAgo', { count: absHour });
      if (absDay < 7) return t('time.daysAgo', { count: absDay });
      if (absMonth < 12) return t('time.monthsAgo', { count: absMonth });
      return t('time.yearsAgo', { count: absYear });
    } else {
      // Future
      if (diffSec < 60) return t('time.inSeconds', { count: diffSec });
      if (diffMin < 60) return t('time.inMinutes', { count: diffMin });
      if (diffHour < 24) return t('time.inHours', { count: diffHour });
      if (diffDay < 7) return t('time.inDays', { count: diffDay });
      if (diffMonth < 12) return t('time.inMonths', { count: diffMonth });
      return t('time.inYears', { count: diffYear });
    }
  }

  /**
   * Format number
   */
  formatNumber(number: number, options: Intl.NumberFormatOptions = {}): string {
    const locale = i18nManager.getLocale();

    try {
      return new Intl.NumberFormat(locale, options).format(number);
    } catch (error) {
      console.error('Number formatting error:', error);
      return String(number);
    }
  }

  /**
   * Format currency
   */
  formatCurrency(
    amount: number,
    currency: string = 'USD',
    options: Intl.NumberFormatOptions = {}
  ): string {
    const locale = i18nManager.getLocale();

    try {
      return new Intl.NumberFormat(locale, {
        style: 'currency',
        currency,
        ...options,
      }).format(amount);
    } catch (error) {
      console.error('Currency formatting error:', error);
      return `${currency} ${amount}`;
    }
  }

  /**
   * Format percentage
   */
  formatPercentage(value: number, options: Intl.NumberFormatOptions = {}): string {
    const locale = i18nManager.getLocale();

    try {
      return new Intl.NumberFormat(locale, {
        style: 'percent',
        ...options,
      }).format(value / 100);
    } catch (error) {
      console.error('Percentage formatting error:', error);
      return `${value}%`;
    }
  }

  /**
   * Format list
   */
  formatList(items: string[], type: 'conjunction' | 'disjunction' = 'conjunction'): string {
    const locale = i18nManager.getLocale();

    try {
      return new Intl.ListFormat(locale, { type }).format(items);
    } catch (error) {
      console.error('List formatting error:', error);
      return items.join(', ');
    }
  }

  /**
   * Format duration
   */
  formatDuration(milliseconds: number): string {
    const seconds = Math.floor(milliseconds / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    const parts: string[] = [];
    if (days > 0) parts.push(`${days}d`);
    if (hours % 24 > 0) parts.push(`${hours % 24}h`);
    if (minutes % 60 > 0) parts.push(`${minutes % 60}m`);
    if (seconds % 60 > 0) parts.push(`${seconds % 60}s`);

    return parts.length > 0 ? parts.join(' ') : '0s';
  }
}

export const formatters = Formatters.getInstance();
```

---

## Translation Workflow

### Complete Translation Workflow

```typescript
// src/i18n/TranslationWorkflow.ts
import { i18nManager } from './index';
import { translationManager } from './TranslationManager';

/**
 * Translation Workflow
 * 
 * This provides a complete translation workflow:
 * - Translation management
 * - Review process
 * - Version control
 * - Deployment
 */

export class TranslationWorkflow {
  private static instance: TranslationWorkflow;

  private constructor() {}

  static getInstance(): TranslationWorkflow {
    if (!TranslationWorkflow.instance) {
      TranslationWorkflow.instance = new TranslationWorkflow();
    }
    return TranslationWorkflow.instance;
  }

  /**
   * Add new translation key
   */
  addTranslationKey(key: string, defaultText: string): void {
    // Add to all language files
    SUPPORTED_LANGUAGES.forEach(({ code }) => {
      // In production, add to translation files
      console.log(`Adding key "${key}" to ${code}`);
    });
    
    // Mark for review
    this.markForReview(key);
  }

  /**
   * Mark translation for review
   */
  markForReview(key: string): void {
    // In production, store in review queue
    console.log(`Marking "${key}" for review`);
  }

  /**
   * Request translation
   */
  requestTranslation(locale: string, key: string): void {
    // Track missing translation
    translationManager.trackMissingTranslation(locale, key);
    
    // Send notification to translators
    this.notifyTranslators(locale, key);
  }

  /**
   * Notify translators
   */
  private notifyTranslators(locale: string, key: string): void {
    // In production, send email or slack notification
    console.log(`🔔 Translation needed: "${key}" for ${locale}`);
  }

  /**
   * Publish translations
   */
  publishTranslations(version: string): void {
    // In production, compile translations for production
    console.log(`📦 Publishing translations v${version}`);
    
    // Clear missing translations
    SUPPORTED_LANGUAGES.forEach(({ code }) => {
      translationManager.clearMissingTranslations(code);
    });
  }

  /**
   * Get translation status
   */
  getTranslationStatus(): {
    totalKeys: number;
    languages: Array<{
      code: string;
      name: string;
      translated: number;
      missing: number;
      coverage: number;
    }>;
  } {
    const totalKeys = this.getTotalKeys();
    const coverage = translationManager.getTranslationCoverage();
    
    const languages = SUPPORTED_LANGUAGES.map(({ code, name }) => {
      const missing = translationManager.getMissingTranslations(code).length;
      const translated = totalKeys - missing;
      
      return {
        code,
        name,
        translated,
        missing,
        coverage: (translated / totalKeys) * 100,
      };
    });

    return {
      totalKeys,
      languages,
    };
  }

  /**
   * Get total translation keys
   */
  private getTotalKeys(): number {
    // In production, count all keys
    return 150; // Placeholder
  }
}

export const translationWorkflow = TranslationWorkflow.getInstance();
```

---

## Testing Internationalization

### i18n Testing Framework

```typescript
// src/__tests__/i18n.test.ts
import { i18nManager, SUPPORTED_LANGUAGES } from '../i18n';
import { formatters } from '../i18n/Formatters';
import { translationManager } from '../i18n/TranslationManager';

describe('Internationalization', () => {
  describe('Translation Loading', () => {
    it('should load translations for all supported languages', () => {
      SUPPORTED_LANGUAGES.forEach(({ code }) => {
        i18nManager.setLocale(code);
        expect(i18nManager.getLocale()).toBe(code);
        
        // Test a common translation
        const welcome = i18nManager.t('common.welcome');
        expect(welcome).toBeDefined();
        expect(typeof welcome).toBe('string');
      });
    });

    it('should fallback to English for missing translations', () => {
      i18nManager.setLocale('es');
      const missingKey = i18nManager.t('nonexistent.key');
      expect(missingKey).toBe('nonexistent.key');
    });

    it('should track missing translations', () => {
      i18nManager.setLocale('fr');
      const missingKey = i18nManager.t('test.missing.key');
      
      const missing = translationManager.getMissingTranslations('fr');
      expect(missing).toContain('test.missing.key');
    });
  });

  describe('Date Formatting', () => {
    const testDate = new Date('2024-01-15T10:30:00');

    it('should format dates correctly for different locales', () => {
      i18nManager.setLocale('en');
      const enDate = formatters.formatDate(testDate);
      expect(enDate).toMatch(/Jan 15, 2024/);

      i18nManager.setLocale('es');
      const esDate = formatters.formatDate(testDate);
      expect(esDate).toMatch(/15 ene 2024/);
    });

    it('should handle relative time correctly', () => {
      const now = new Date();
      const oneHourAgo = new Date(now.getTime() - 3600000);
      
      const relative = formatters.formatRelativeTime(oneHourAgo);
      expect(relative).toContain('1 hour');
    });
  });

  describe('Number Formatting', () => {
    it('should format numbers with correct separators', () => {
      i18nManager.setLocale('en');
      expect(formatters.formatNumber(1234567.89)).toBe('1,234,567.89');

      i18nManager.setLocale('es');
      expect(formatters.formatNumber(1234567.89)).toBe('1.234.567,89');
    });

    it('should format currency correctly', () => {
      i18nManager.setLocale('en');
      expect(formatters.formatCurrency(1234.56)).toMatch(/\$1,234.56/);
    });
  });

  describe('RTL Support', () => {
    it('should detect RTL languages correctly', () => {
      SUPPORTED_LANGUAGES.forEach(({ code, rtl }) => {
        i18nManager.setLocale(code);
        expect(i18nManager.isRTLLocale()).toBe(rtl);
      });
    });
  });
});
```

---

## Performance Considerations

### i18n Performance Optimization

```typescript
// src/i18n/Performance.ts
import { i18nManager } from './index';

/**
 * i18n Performance Optimization
 * 
 * This provides performance optimizations for i18n:
 * - Translation caching
 * - Lazy loading
 * - Memory management
 * - Batch updates
 */

export class I18nPerformance {
  private static instance: I18nPerformance;
  private translationCache: Map<string, string> = new Map();
  private cacheSize = 0;
  private readonly MAX_CACHE_SIZE = 1000;

  private constructor() {}

  static getInstance(): I18nPerformance {
    if (!I18nPerformance.instance) {
      I18nPerformance.instance = new I18nPerformance();
    }
    return I18nPerformance.instance;
  }

  /**
   * Get translation with caching
   */
  t(key: string, params?: Record<string, any>): string {
    // Create cache key
    const cacheKey = this.getCacheKey(key, params);
    
    // Check cache
    if (this.translationCache.has(cacheKey)) {
      return this.translationCache.get(cacheKey)!;
    }

    // Get translation
    const translation = i18nManager.t(key, params);
    
    // Cache translation
    this.cacheTranslation(cacheKey, translation);
    
    return translation;
  }

  /**
   * Get cache key
   */
  private getCacheKey(key: string, params?: Record<string, any>): string {
    if (!params) return key;
    return `${key}_${JSON.stringify(params)}`;
  }

  /**
   * Cache translation
   */
  private cacheTranslation(key: string, value: string): void {
    // Check cache size
    if (this.cacheSize >= this.MAX_CACHE_SIZE) {
      this.clearCache();
    }
    
    this.translationCache.set(key, value);
    this.cacheSize++;
  }

  /**
   * Clear translation cache
   */
  clearCache(): void {
    this.translationCache.clear();
    this.cacheSize = 0;
  }

  /**
   * Preload translations
   */
  async preloadTranslations(locales: string[]): Promise<void> {
    // Preload common translations
    const commonKeys = [
      'common.welcome',
      'common.loading',
      'common.error',
      'common.success',
      'common.cancel',
      'common.confirm',
      'common.save',
      'common.delete',
    ];

    for (const locale of locales) {
      i18nManager.setLocale(locale);
      for (const key of commonKeys) {
        const translation = i18nManager.t(key);
        const cacheKey = this.getCacheKey(key);
        this.cacheTranslation(cacheKey, translation);
      }
    }
  }

  /**
   * Get cache statistics
   */
  getCacheStats(): {
    size: number;
    maxSize: number;
    hitRate: number;
  } {
    // In production, track cache hits/misses
    return {
      size: this.cacheSize,
      maxSize: this.MAX_CACHE_SIZE,
      hitRate: 0.95, // Placeholder
    };
  }
}

export const i18nPerformance = I18nPerformance.getInstance();
```

---

This appendix provides a comprehensive internationalization framework for your React Native application. By implementing these patterns, you'll create a truly global app that works seamlessly across languages and cultures.

