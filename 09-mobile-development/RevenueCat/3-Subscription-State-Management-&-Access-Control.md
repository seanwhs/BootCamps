# Part 3: Subscription State Management & Access Control

## Module Overview

Welcome to Part 3! Now that you have a beautiful paywall and working purchase flow, it's time to build the infrastructure that makes subscriptions actually useful: state management and access control.

By the end of this module, you'll have:

- ✅ A real-time subscription state management system
- ✅ Premium feature gating throughout the app
- ✅ User identity management (anonymous vs. authenticated)
- ✅ Account migration (transferring subscriptions between users)
- ✅ A subscription status dashboard for users
- ✅ Secure backend verification of subscription status
- ✅ Offline support and caching strategies

Think of this as building the "security system" of your app. You need to know who has access to what, and you need to know it reliably, even when the user is offline.

---

## Phase 1: Subscription State Management Architecture

### The Target

Build a robust state management system that handles subscription data, user identity, and real-time updates.

### The Concept

Subscription state management is about answering one question: "What does this user have access to right now?" But answering this question involves:

1. **Real-time updates**: Subscriptions can change at any time (renewals, cancellations, expirations)
2. **Offline support**: Users should be able to access their premium features even without an internet connection
3. **Multiple users**: If your app has authentication, users may log in/out
4. **Cross-device sync**: A purchase on one device should be recognized on all devices

We'll build a state management system using React Context that handles all of this seamlessly.

### Implementation

#### Step 1.1: Create the Subscription Context

**File: `FitTrackPro/src/context/SubscriptionContext.tsx`**

```typescript
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { CustomerInfo, PurchasesError } from 'react-native-purchases';
import { revenueCatService } from '../services/RevenueCatService';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { parseError, logError } from '../utils/errorUtils';

/**
 * Subscription Context
 * 
 * This context provides subscription state management throughout the app.
 * It handles:
 * - Current subscription status
 * - Active entitlements
 * - User identity (anonymous vs. authenticated)
 * - Real-time updates from RevenueCat
 * - Offline caching
 * 
 * 🎯 This is the single source of truth for subscription state.
 */

interface SubscriptionState {
  customerInfo: CustomerInfo | null;
  isSubscribed: boolean;
  activeEntitlements: Record<string, any>;
  isLoading: boolean;
  error: string | null;
  isAnonymous: boolean;
  appUserId: string | null;
}

interface SubscriptionContextValue extends SubscriptionState {
  // User identity methods
  setUserId: (userId: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  
  // Subscription methods
  refreshSubscription: () => Promise<void>;
  hasEntitlement: (entitlementId: string) => Promise<boolean>;
  getActiveEntitlements: () => Record<string, any>;
  
  // Purchase methods (proxy to RevenueCat)
  purchasePackage: (packageToPurchase: any) => Promise<{ customerInfo: CustomerInfo; success: boolean }>;
  restorePurchases: () => Promise<CustomerInfo>;
}

const SubscriptionContext = createContext<SubscriptionContextValue | undefined>(undefined);

/**
 * Subscription Provider Component
 * 
 * Wraps the app with subscription state management.
 * Initializes RevenueCat and sets up real-time listeners.
 */
export const SubscriptionProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, setState] = useState<SubscriptionState>({
    customerInfo: null,
    isSubscribed: false,
    activeEntitlements: {},
    isLoading: true,
    error: null,
    isAnonymous: true,
    appUserId: null,
  });

  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);

  /**
   * Update subscription state from CustomerInfo
   */
  const updateStateFromCustomerInfo = useCallback((customerInfo: CustomerInfo | null) => {
    if (!customerInfo) {
      setState(prev => ({
        ...prev,
        customerInfo: null,
        isSubscribed: false,
        activeEntitlements: {},
      }));
      return;
    }

    const activeEntitlements = customerInfo.entitlements.active || {};
    const isSubscribed = Object.keys(activeEntitlements).length > 0;

    setState(prev => ({
      ...prev,
      customerInfo,
      isSubscribed,
      activeEntitlements,
      isLoading: false,
      error: null,
    }));

    // Cache the subscription state for offline use
    cacheSubscriptionState({
      customerInfo,
      isSubscribed,
      activeEntitlements,
      timestamp: Date.now(),
    });
  }, []);

  /**
   * Load cached subscription state for offline use
   */
  const loadCachedState = useCallback(async () => {
    try {
      const cached = await AsyncStorage.getItem('@subscription_cache');
      if (cached) {
        const parsed = JSON.parse(cached);
        // Only use cache if it's less than 24 hours old
        if (parsed.timestamp && Date.now() - parsed.timestamp < 24 * 60 * 60 * 1000) {
          console.log('[SubscriptionContext] Loading cached subscription state');
          setState(prev => ({
            ...prev,
            customerInfo: parsed.customerInfo,
            isSubscribed: parsed.isSubscribed,
            activeEntitlements: parsed.activeEntitlements || {},
            isLoading: false,
          }));
          return true;
        }
      }
    } catch (error) {
      console.warn('[SubscriptionContext] Failed to load cache:', error);
    }
    return false;
  }, []);

  /**
   * Cache subscription state for offline use
   */
  const cacheSubscriptionState = useCallback(async (data: any) => {
    try {
      await AsyncStorage.setItem('@subscription_cache', JSON.stringify(data));
    } catch (error) {
      console.warn('[SubscriptionContext] Failed to cache state:', error);
    }
  }, []);

  /**
   * Initialize subscription state
   */
  const initializeSubscription = useCallback(async (userId?: string) => {
    try {
      setState(prev => ({ ...prev, isLoading: true, error: null }));

      // Initialize RevenueCat
      await revenueCatService.initialize(userId);

      // Get current user info
      const customerInfo = await revenueCatService.getCustomerInfo();
      updateStateFromCustomerInfo(customerInfo);

      // Update anonymous status
      const isAnonymous = !userId;
      setState(prev => ({
        ...prev,
        isAnonymous,
        appUserId: userId || null,
      }));
      
      setIsAuthenticated(!!userId);

    } catch (error) {
      console.error('[SubscriptionContext] Initialization failed:', error);
      
      // Try to load cached state
      const hasCache = await loadCachedState();
      
      if (!hasCache) {
        setState(prev => ({
          ...prev,
          isLoading: false,
          error: error instanceof Error ? error.message : 'Failed to initialize subscription system',
        }));
      }
    }
  }, [updateStateFromCustomerInfo, loadCachedState]);

  /**
   * Set user ID (for authenticated users)
   */
  const setUserId = useCallback(async (userId: string) => {
    if (!userId) {
      throw new Error('User ID is required');
    }

    try {
      setState(prev => ({ ...prev, isLoading: true, error: null }));
      
      // Set the user ID in RevenueCat
      await revenueCatService.setAppUserID(userId);
      
      // Refresh customer info
      const customerInfo = await revenueCatService.getCustomerInfo();
      updateStateFromCustomerInfo(customerInfo);
      
      setState(prev => ({
        ...prev,
        isAnonymous: false,
        appUserId: userId,
      }));
      
      setIsAuthenticated(true);
      
      // Store user ID for future sessions
      await AsyncStorage.setItem('@user_id', userId);
      
    } catch (error) {
      console.error('[SubscriptionContext] Failed to set user ID:', error);
      const appError = parseError(error);
      setState(prev => ({
        ...prev,
        isLoading: false,
        error: appError.userMessage,
      }));
      throw error;
    }
  }, [updateStateFromCustomerInfo]);

  /**
   * Logout user
   */
  const logout = useCallback(async () => {
    try {
      setState(prev => ({ ...prev, isLoading: true }));
      
      // Reset RevenueCat to anonymous
      await revenueCatService.logout();
      
      // Get fresh customer info for anonymous user
      const customerInfo = await revenueCatService.getCustomerInfo();
      updateStateFromCustomerInfo(customerInfo);
      
      setState(prev => ({
        ...prev,
        isAnonymous: true,
        appUserId: null,
      }));
      
      setIsAuthenticated(false);
      
      // Clear stored user ID
      await AsyncStorage.removeItem('@user_id');
      
    } catch (error) {
      console.error('[SubscriptionContext] Logout failed:', error);
      setState(prev => ({
        ...prev,
        isLoading: false,
        error: error instanceof Error ? error.message : 'Logout failed',
      }));
      throw error;
    }
  }, [updateStateFromCustomerInfo]);

  /**
   * Refresh subscription state
   */
  const refreshSubscription = useCallback(async () => {
    try {
      setState(prev => ({ ...prev, isLoading: true }));
      
      const customerInfo = await revenueCatService.getCustomerInfo();
      updateStateFromCustomerInfo(customerInfo);
      
    } catch (error) {
      console.error('[SubscriptionContext] Refresh failed:', error);
      setState(prev => ({
        ...prev,
        isLoading: false,
        error: error instanceof Error ? error.message : 'Failed to refresh subscription',
      }));
    }
  }, [updateStateFromCustomerInfo]);

  /**
   * Check if user has a specific entitlement
   */
  const hasEntitlement = useCallback(async (entitlementId: string): Promise<boolean> => {
    return revenueCatService.hasEntitlement(entitlementId, state.customerInfo || undefined);
  }, [state.customerInfo]);

  /**
   * Get all active entitlements
   */
  const getActiveEntitlements = useCallback((): Record<string, any> => {
    return state.activeEntitlements;
  }, [state.activeEntitlements]);

  /**
   * Purchase a package (proxy to RevenueCat)
   */
  const purchasePackage = useCallback(async (packageToPurchase: any) => {
    const result = await revenueCatService.purchasePackage(packageToPurchase);
    updateStateFromCustomerInfo(result.customerInfo);
    return result;
  }, [updateStateFromCustomerInfo]);

  /**
   * Restore purchases
   */
  const restorePurchases = useCallback(async () => {
    const customerInfo = await revenueCatService.restorePurchases();
    updateStateFromCustomerInfo(customerInfo);
    return customerInfo;
  }, [updateStateFromCustomerInfo]);

  /**
   * Set up RevenueCat listener for real-time updates
   */
  useEffect(() => {
    // Add listener for CustomerInfo changes
    const removeListener = revenueCatService.addCustomerInfoListener((customerInfo) => {
      console.log('[SubscriptionContext] Received customer info update');
      updateStateFromCustomerInfo(customerInfo);
    });

    // Clean up listener on unmount
    return () => {
      removeListener();
    };
  }, [updateStateFromCustomerInfo]);

  /**
   * Initialize on mount
   */
  useEffect(() => {
    const init = async () => {
      // Check for stored user ID
      const storedUserId = await AsyncStorage.getItem('@user_id');
      
      // Initialize with stored user ID if available
      await initializeSubscription(storedUserId || undefined);
    };

    init();
  }, [initializeSubscription]);

  // Provide context value
  const contextValue: SubscriptionContextValue = {
    ...state,
    setUserId,
    logout,
    isAuthenticated,
    refreshSubscription,
    hasEntitlement,
    getActiveEntitlements,
    purchasePackage,
    restorePurchases,
  };

  return (
    <SubscriptionContext.Provider value={contextValue}>
      {children}
    </SubscriptionContext.Provider>
  );
};

/**
 * Hook to use subscription context
 */
export const useSubscription = (): SubscriptionContextValue => {
  const context = useContext(SubscriptionContext);
  if (!context) {
    throw new Error('useSubscription must be used within a SubscriptionProvider');
  }
  return context;
};

export default SubscriptionContext;
```

#### Step 1.2: Update the App Entry Point

**File: `FitTrackPro/App.tsx`**

```typescript
import React, { useEffect, useState } from 'react';
import { 
  SafeAreaView, 
  StatusBar, 
  View, 
  Text, 
  ActivityIndicator,
  StyleSheet,
} from 'react-native';
import { SubscriptionProvider, useSubscription } from './src/context/SubscriptionContext';
import { PaywallScreen } from './src/screens/PaywallScreen';
import { MainAppScreen } from './src/screens/MainAppScreen';
import { colors } from './src/theme/colors';
import { typography } from './src/theme/typography';

/**
 * Main App Content
 * 
 * This component decides which screen to show based on subscription state.
 * Uses the subscription context for state management.
 */
const AppContent: React.FC = () => {
  const { isLoading, isSubscribed, customerInfo, error } = useSubscription();
  const [showPaywall, setShowPaywall] = useState<boolean>(false);

  // Determine which screen to show
  useEffect(() => {
    if (!isLoading) {
      // If user is subscribed, show main app
      // Otherwise, show paywall
      setShowPaywall(!isSubscribed);
    }
  }, [isLoading, isSubscribed]);

  // Loading state
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary.main} />
        <Text style={styles.loadingText}>Loading your fitness experience...</Text>
      </View>
    );
  }

  // Error state
  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorEmoji}>😕</Text>
        <Text style={styles.errorTitle}>Something went wrong</Text>
        <Text style={styles.errorText}>{error}</Text>
        <Text style={styles.errorSubtext}>
          Please check your internet connection and try again.
        </Text>
      </View>
    );
  }

  // Show the appropriate screen
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor={colors.background.primary} />
      {showPaywall ? <PaywallScreen /> : <MainAppScreen />}
    </SafeAreaView>
  );
};

/**
 * Main Application Component
 * 
 * Wraps the app with SubscriptionProvider for global state management.
 */
const App = () => {
  return (
    <SubscriptionProvider>
      <AppContent />
    </SubscriptionProvider>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background.primary,
    padding: 40,
  },
  loadingText: {
    ...typography.body,
    color: colors.text.secondary,
    marginTop: 16,
    textAlign: 'center',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background.primary,
    padding: 40,
  },
  errorEmoji: {
    fontSize: 48,
    marginBottom: 16,
  },
  errorTitle: {
    ...typography.h3,
    color: colors.text.primary,
    marginBottom: 8,
  },
  errorText: {
    ...typography.body,
    color: colors.status.error,
    textAlign: 'center',
    marginBottom: 8,
  },
  errorSubtext: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    textAlign: 'center',
  },
});

export default App;
```

---

## Phase 2: Premium Feature Gating

### The Target

Implement secure premium feature gating throughout the app, protecting content and features from unauthorized access.

### The Concept

Premium feature gating is about controlling access to features based on subscription status. Think of it like a VIP section at a club:

1. **Entitlements are the VIP passes** - Each entitlement grants access to specific features
2. **The gatekeeper checks passes** - Your app checks if the user has the required entitlement
3. **Access is granted or denied** - Show premium content or show an upgrade prompt

We'll implement this at multiple levels:
- Component level (hide/show UI elements)
- Navigation level (block access to screens)
- Data level (prevent API calls for premium data)

### Implementation

#### Step 2.1: Create Feature Guard Components

**File: `FitTrackPro/src/components/guards/RequireEntitlement.tsx`**

```typescript
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useSubscription } from '../../context/SubscriptionContext';
import { colors } from '../../theme/colors';
import { typography } from '../../theme/typography';
import { spacing } from '../../theme/spacing';

/**
 * RequireEntitlement Component
 * 
 * A wrapper component that only renders its children if the user has the specified entitlement.
 * If the user doesn't have access, it shows an upgrade prompt.
 * 
 * Usage:
 * ```tsx
 * <RequireEntitlement entitlementId="premium_workouts">
 *   <PremiumWorkoutScreen />
 * </RequireEntitlement>
 * ```
 * 
 * 🎯 This is the primary way to gate premium features in your app.
 * Think of it as a bouncer at the door of a VIP section.
 */

interface RequireEntitlementProps {
  entitlementId: string;
  children: React.ReactNode;
  fallback?: React.ReactNode;
  onUpgradePress?: () => void;
  loadingComponent?: React.ReactNode;
}

export const RequireEntitlement: React.FC<RequireEntitlementProps> = ({
  entitlementId,
  children,
  fallback,
  onUpgradePress,
  loadingComponent,
}) => {
  const { 
    isLoading, 
    hasEntitlement, 
    isSubscribed,
  } = useSubscription();

  const [hasAccess, setHasAccess] = useState<boolean>(false);
  const [isChecking, setIsChecking] = useState<boolean>(true);

  // Check entitlement on mount and when it might change
  useEffect(() => {
    const checkAccess = async () => {
      setIsChecking(true);
      const access = await hasEntitlement(entitlementId);
      setHasAccess(access);
      setIsChecking(false);
    };

    checkAccess();
  }, [entitlementId, hasEntitlement, isSubscribed]);

  // Show loading state
  if (isLoading || isChecking) {
    return (
      <View style={styles.loadingContainer}>
        {loadingComponent || (
          <View>
            <Text style={styles.loadingText}>Checking access...</Text>
          </View>
        )}
      </View>
    );
  }

  // If user has access, render children
  if (hasAccess) {
    return <>{children}</>;
  }

  // If custom fallback provided, use it
  if (fallback) {
    return <>{fallback}</>;
  }

  // Default upgrade prompt
  return (
    <View style={styles.container}>
      <View style={styles.iconContainer}>
        <Text style={styles.lockIcon}>🔒</Text>
      </View>
      <Text style={styles.title}>Premium Feature</Text>
      <Text style={styles.description}>
        This feature requires a {entitlementId.replace('_', ' ')} subscription.
        Upgrade to unlock all premium features.
      </Text>
      <TouchableOpacity style={styles.upgradeButton} onPress={onUpgradePress}>
        <Text style={styles.upgradeButtonText}>Upgrade Now</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xxl,
    backgroundColor: colors.background.primary,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    ...typography.body,
    color: colors.text.secondary,
  },
  iconContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.background.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  lockIcon: {
    fontSize: 40,
  },
  title: {
    ...typography.h3,
    color: colors.text.primary,
    marginBottom: spacing.sm,
  },
  description: {
    ...typography.body,
    color: colors.text.secondary,
    textAlign: 'center',
    marginBottom: spacing.xl,
    paddingHorizontal: spacing.lg,
  },
  upgradeButton: {
    backgroundColor: colors.primary.main,
    paddingHorizontal: spacing.xxl,
    paddingVertical: spacing.md,
    borderRadius: 12,
  },
  upgradeButtonText: {
    ...typography.button,
    color: colors.text.inverse,
  },
});

export default RequireEntitlement;
```

**File: `FitTrackPro/src/components/guards/EntitlementGate.tsx`**

```typescript
import React, { ReactNode } from 'react';
import { View, StyleSheet } from 'react-native';
import { useSubscription } from '../../context/SubscriptionContext';

/**
 * EntitlementGate Component
 * 
 * A simple wrapper that conditionally renders content based on entitlement.
 * Unlike RequireEntitlement, this doesn't show an upgrade prompt - it just
 * renders or doesn't render the content.
 * 
 * Useful for hiding/showing UI elements like buttons or badges.
 * 
 * Usage:
 * ```tsx
 * <EntitlementGate entitlementId="premium_workouts">
 *   <PremiumBadge />
 * </EntitlementGate>
 * ```
 */

interface EntitlementGateProps {
  entitlementId: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export const EntitlementGate: React.FC<EntitlementGateProps> = ({
  entitlementId,
  children,
  fallback = null,
}) => {
  const { hasEntitlement } = useSubscription();
  const [hasAccess, setHasAccess] = React.useState<boolean>(false);
  const [isChecking, setIsChecking] = React.useState<boolean>(true);

  React.useEffect(() => {
    const check = async () => {
      setIsChecking(true);
      const access = await hasEntitlement(entitlementId);
      setHasAccess(access);
      setIsChecking(false);
    };
    check();
  }, [entitlementId, hasEntitlement]);

  if (isChecking) {
    return <View style={styles.placeholder} />;
  }

  return <>{hasAccess ? children : fallback}</>;
};

const styles = StyleSheet.create({
  placeholder: {
    width: 0,
    height: 0,
  },
});

export default EntitlementGate;
```

#### Step 2.2: Create the Main App Screen with Premium Features

**File: `FitTrackPro/src/screens/MainAppScreen.tsx`**

```typescript
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useSubscription } from '../context/SubscriptionContext';
import { RequireEntitlement } from '../components/guards/RequireEntitlement';
import { EntitlementGate } from '../components/guards/EntitlementGate';
import { Button } from '../components/common/Button';
import { Card } from '../components/common/Card';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing } from '../theme/spacing';

/**
 * Main App Screen
 * 
 * The main screen of the app, showing fitness features with premium gating.
 * Users see different content based on their subscription status.
 */

export const MainAppScreen: React.FC = () => {
  const { 
    customerInfo, 
    isSubscribed, 
    activeEntitlements, 
    logout,
    refreshSubscription,
  } = useSubscription();

  const [isRefreshing, setIsRefreshing] = useState(false);

  // Handle refresh
  const handleRefresh = async () => {
    setIsRefreshing(true);
    await refreshSubscription();
    setIsRefreshing(false);
  };

  // Handle logout
  const handleLogout = () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Logout',
          style: 'destructive',
          onPress: async () => {
            try {
              await logout();
            } catch (error) {
              Alert.alert('Error', 'Failed to logout. Please try again.');
            }
          },
        },
      ]
    );
  };

  return (
    <ScrollView 
      style={styles.container}
      contentContainerStyle={styles.content}
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.welcomeText}>Welcome to FitTrack Pro</Text>
          <View style={styles.statusRow}>
            <View style={[styles.statusDot, isSubscribed ? styles.statusActive : styles.statusInactive]} />
            <Text style={styles.statusText}>
              {isSubscribed ? 'Premium Member' : 'Free User'}
            </Text>
          </View>
        </View>
        <TouchableOpacity style={styles.refreshButton} onPress={handleRefresh}>
          <Text style={styles.refreshText}>⟳</Text>
        </TouchableOpacity>
      </View>

      {/* Subscription Card */}
      <Card variant="elevated" style={styles.subscriptionCard}>
        <Text style={styles.cardTitle}>Your Subscription</Text>
        {isSubscribed ? (
          <View>
            <Text style={styles.activeText}>✅ Active</Text>
            {Object.entries(activeEntitlements).map(([key, value]) => (
              <View key={key} style={styles.entitlementRow}>
                <Text style={styles.entitlementName}>
                  • {key.replace('_', ' ')}
                </Text>
                {value.expirationDate && (
                  <Text style={styles.entitlementDate}>
                    Expires: {new Date(value.expirationDate).toLocaleDateString()}
                  </Text>
                )}
              </View>
            ))}
            {customerInfo?.managementURL && (
              <TouchableOpacity 
                style={styles.manageButton}
                onPress={() => {
                  // Open management URL in browser
                  // We'll use Linking in production
                }}
              >
                <Text style={styles.manageButtonText}>Manage Subscription</Text>
              </TouchableOpacity>
            )}
          </View>
        ) : (
          <View>
            <Text style={styles.inactiveText}>⚠️ No Active Subscription</Text>
            <Text style={styles.inactiveSubtext}>
              Upgrade to access premium features
            </Text>
          </View>
        )}
      </Card>

      {/* Premium Features */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Premium Features</Text>
        
        {/* Feature 1: Premium Workouts */}
        <RequireEntitlement 
          entitlementId="premium_workouts"
          onUpgradePress={() => {
            // Navigate to paywall
          }}
        >
          <Card variant="elevated" style={styles.featureCard}>
            <View style={styles.featureHeader}>
              <Text style={styles.featureIcon}>🏋️</Text>
              <View style={styles.featureInfo}>
                <Text style={styles.featureTitle}>Premium Workouts</Text>
                <Text style={styles.featureDescription}>
                  500+ exercises, custom routines, advanced programs
                </Text>
              </View>
            </View>
            <View style={styles.featureContent}>
              <Text style={styles.workoutCount}>128 workouts available</Text>
              <TouchableOpacity style={styles.startWorkoutButton}>
                <Text style={styles.startWorkoutText}>Start Workout</Text>
              </TouchableOpacity>
            </View>
          </Card>
        </RequireEntitlement>

        {/* Feature 2: Nutrition Tracking */}
        <RequireEntitlement 
          entitlementId="nutrition_tracking"
          onUpgradePress={() => {
            // Navigate to paywall
          }}
        >
          <Card variant="elevated" style={styles.featureCard}>
            <View style={styles.featureHeader}>
              <Text style={styles.featureIcon}>🥗</Text>
              <View style={styles.featureInfo}>
                <Text style={styles.featureTitle}>Nutrition Tracking</Text>
                <Text style={styles.featureDescription}>
                  Log meals, track macros, personalized recommendations
                </Text>
              </View>
            </View>
            <View style={styles.featureContent}>
              <Text style={styles.mealCount}>Today's meals: 2/3 logged</Text>
              <TouchableOpacity style={styles.logMealButton}>
                <Text style={styles.logMealText}>Log Meal</Text>
              </TouchableOpacity>
            </View>
          </Card>
        </RequireEntitlement>

        {/* Feature 3: Personal Trainer (shows differently based on access) */}
        <Card variant="elevated" style={styles.featureCard}>
          <View style={styles.featureHeader}>
            <Text style={styles.featureIcon}>💬</Text>
            <View style={styles.featureInfo}>
              <Text style={styles.featureTitle}>Personal Trainer</Text>
              <Text style={styles.featureDescription}>
                Get 1-on-1 guidance from certified trainers
              </Text>
            </View>
            <EntitlementGate entitlementId="personal_trainer">
              <View style={styles.accessBadge}>
                <Text style={styles.accessBadgeText}>✓ Access</Text>
              </View>
            </EntitlementGate>
          </View>
          <EntitlementGate 
            entitlementId="personal_trainer"
            fallback={
              <View style={styles.lockedContent}>
                <Text style={styles.lockedText}>🔒 Upgrade to Personal Trainer</Text>
                <TouchableOpacity 
                  style={styles.lockedUpgradeButton}
                  onPress={() => {
                    // Navigate to paywall
                  }}
                >
                  <Text style={styles.lockedUpgradeText}>Upgrade</Text>
                </TouchableOpacity>
              </View>
            }
          >
            <View style={styles.trainerContent}>
              <View style={styles.trainerMessage}>
                <Text style={styles.trainerName}>Sarah, CPT</Text>
                <Text style={styles.trainerText}>
                  Great job on your workout today! Let me know if you need any help with your form.
                </Text>
                <Text style={styles.trainerTime}>2 min ago</Text>
              </View>
              <TouchableOpacity style={styles.chatButton}>
                <Text style={styles.chatButtonText}>Chat Now</Text>
              </TouchableOpacity>
            </View>
          </EntitlementGate>
        </Card>
      </View>

      {/* User Actions */}
      <View style={styles.actionsSection}>
        <TouchableOpacity style={styles.actionButton} onPress={handleLogout}>
          <Text style={styles.actionButtonText}>Logout</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
  },
  content: {
    padding: spacing.lg,
    paddingBottom: spacing.xxxl,
  },
  
  // Header
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.xl,
    paddingTop: spacing.md,
  },
  welcomeText: {
    ...typography.h3,
    color: colors.text.primary,
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.xs,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: spacing.sm,
  },
  statusActive: {
    backgroundColor: colors.secondary.main,
  },
  statusInactive: {
    backgroundColor: colors.border.medium,
  },
  statusText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  refreshButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background.tertiary,
    borderRadius: 20,
  },
  refreshText: {
    fontSize: 24,
    color: colors.text.secondary,
  },
  
  // Subscription Card
  subscriptionCard: {
    marginBottom: spacing.xl,
  },
  cardTitle: {
    ...typography.h4,
    color: colors.text.primary,
    marginBottom: spacing.md,
  },
  activeText: {
    ...typography.body,
    color: colors.secondary.main,
    fontWeight: '600',
  },
  inactiveText: {
    ...typography.body,
    color: colors.status.warning,
    fontWeight: '600',
  },
  inactiveSubtext: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    marginTop: spacing.xs,
  },
  entitlementRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.xs,
    borderBottomWidth: 1,
    borderBottomColor: colors.border.light,
  },
  entitlementName: {
    ...typography.body,
    color: colors.text.primary,
    textTransform: 'capitalize',
  },
  entitlementDate: {
    ...typography.caption,
    color: colors.text.tertiary,
  },
  manageButton: {
    marginTop: spacing.md,
    padding: spacing.sm,
    backgroundColor: colors.background.tertiary,
    borderRadius: 8,
    alignItems: 'center',
  },
  manageButtonText: {
    ...typography.bodySmall,
    color: colors.primary.main,
  },
  
  // Section
  section: {
    marginBottom: spacing.xl,
  },
  sectionTitle: {
    ...typography.h4,
    color: colors.text.primary,
    marginBottom: spacing.md,
  },
  
  // Feature Cards
  featureCard: {
    marginBottom: spacing.md,
  },
  featureHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: spacing.sm,
  },
  featureIcon: {
    fontSize: 28,
    marginRight: spacing.md,
  },
  featureInfo: {
    flex: 1,
  },
  featureTitle: {
    ...typography.bodyBold,
    color: colors.text.primary,
  },
  featureDescription: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  featureContent: {
    marginTop: spacing.sm,
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.border.light,
  },
  workoutCount: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    marginBottom: spacing.sm,
  },
  startWorkoutButton: {
    backgroundColor: colors.secondary.main,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 8,
    alignItems: 'center',
  },
  startWorkoutText: {
    ...typography.buttonSmall,
    color: colors.text.inverse,
  },
  mealCount: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    marginBottom: spacing.sm,
  },
  logMealButton: {
    backgroundColor: colors.primary.main,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 8,
    alignItems: 'center',
  },
  logMealText: {
    ...typography.buttonSmall,
    color: colors.text.inverse,
  },
  accessBadge: {
    backgroundColor: colors.secondary.main,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: 12,
    marginLeft: spacing.sm,
  },
  accessBadgeText: {
    ...typography.caption,
    color: colors.text.inverse,
    fontWeight: '600',
  },
  lockedContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.border.light,
  },
  lockedText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  lockedUpgradeButton: {
    backgroundColor: colors.premium.main,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 8,
  },
  lockedUpgradeText: {
    ...typography.buttonSmall,
    color: colors.text.inverse,
  },
  trainerContent: {
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.border.light,
  },
  trainerMessage: {
    backgroundColor: colors.background.tertiary,
    padding: spacing.md,
    borderRadius: 8,
    marginBottom: spacing.sm,
  },
  trainerName: {
    ...typography.bodyBold,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  trainerText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    marginBottom: spacing.xs,
  },
  trainerTime: {
    ...typography.caption,
    color: colors.text.tertiary,
  },
  chatButton: {
    backgroundColor: colors.primary.light,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 8,
    alignItems: 'center',
  },
  chatButtonText: {
    ...typography.buttonSmall,
    color: colors.text.inverse,
  },
  
  // Actions
  actionsSection: {
    marginTop: spacing.md,
    alignItems: 'center',
  },
  actionButton: {
    padding: spacing.md,
  },
  actionButtonText: {
    ...typography.bodySmall,
    color: colors.status.error,
  },
});

export default MainAppScreen;
```

---

## Phase 3: User Identity & Account Migration

### The Target

Implement user authentication integration with RevenueCat, enabling users to maintain their subscriptions across devices and handle account migrations.

### The Concept

User identity management is crucial for subscription apps because:

1. **Subscriptions are tied to users**, not devices
2. **Users may log in/out** on the same device
3. **Users may use multiple devices** (phone, tablet, web)
4. **Account migration**: What happens when User A logs out and User B logs in on the same device?

RevenueCat handles this through the `AppUserID` system. When you set a user ID, RevenueCat associates all purchases with that ID. When a user logs out, you can reset to anonymous mode.

The key is to ensure that:
- Subscriptions follow the user, not the device
- Users can seamlessly switch between devices
- Purchases are never lost or misattributed

### Implementation

#### Step 3.1: Create Auth Service

**File: `FitTrackPro/src/services/AuthService.ts`**

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { revenueCatService } from './RevenueCatService';

/**
 * Auth Service
 * 
 * Handles user authentication and identity management.
 * This is a mock implementation for the tutorial - in production,
 * you'd integrate with Firebase Auth, Supabase Auth, or your own backend.
 * 
 * The key concept here is how we sync our app's user identity
 * with RevenueCat's AppUserID system.
 */

export interface User {
  id: string;
  email: string;
  displayName: string;
  createdAt: string;
}

export class AuthService {
  private static instance: AuthService;
  private currentUser: User | null = null;
  private isAuthenticated: boolean = false;

  private constructor() {
    // Initialize from storage
    this.loadUser();
  }

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  /**
   * Load user from storage on init
   */
  private async loadUser(): Promise<void> {
    try {
      const userData = await AsyncStorage.getItem('@auth_user');
      if (userData) {
        this.currentUser = JSON.parse(userData);
        this.isAuthenticated = true;
        
        // If user is authenticated, set the AppUserID in RevenueCat
        if (this.currentUser) {
          await revenueCatService.setAppUserID(this.currentUser.id);
        }
      }
    } catch (error) {
      console.warn('[AuthService] Failed to load user:', error);
    }
  }

  /**
   * Sign in a user
   * 
   * In production, this would validate credentials with your backend.
   * For this tutorial, we'll create a mock user.
   */
  public async signIn(email: string, password: string): Promise<User> {
    // Mock authentication - in production, call your backend
    if (!email || !password) {
      throw new Error('Email and password are required');
    }

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Create a mock user
    const user: User = {
      id: `user_${Date.now()}`,
      email: email,
      displayName: email.split('@')[0] || 'User',
      createdAt: new Date().toISOString(),
    };

    // Store user
    this.currentUser = user;
    this.isAuthenticated = true;
    
    // Set the user ID in RevenueCat
    await revenueCatService.setAppUserID(user.id);
    
    // Store user data
    await AsyncStorage.setItem('@auth_user', JSON.stringify(user));

    return user;
  }

  /**
   * Sign up a new user
   */
  public async signUp(email: string, password: string, displayName: string): Promise<User> {
    // Mock sign up - in production, call your backend
    if (!email || !password || !displayName) {
      throw new Error('All fields are required');
    }

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    const user: User = {
      id: `user_${Date.now()}`,
      email,
      displayName,
      createdAt: new Date().toISOString(),
    };

    this.currentUser = user;
    this.isAuthenticated = true;
    
    await revenueCatService.setAppUserID(user.id);
    await AsyncStorage.setItem('@auth_user', JSON.stringify(user));

    return user;
  }

  /**
   * Sign out a user
   * 
   * 🚨 IMPORTANT: When signing out, we reset the RevenueCat AppUserID
   * to anonymous. This ensures that the next user (or the same user in a
   * different session) doesn't inherit the previous user's subscription.
   */
  public async signOut(): Promise<void> {
    // Reset RevenueCat to anonymous
    await revenueCatService.resetAppUserID();
    
    // Clear local state
    this.currentUser = null;
    this.isAuthenticated = false;
    
    // Clear storage
    await AsyncStorage.removeItem('@auth_user');
  }

  /**
   * Transfer a subscription from anonymous to authenticated
   * 
   * This is crucial for converting anonymous users who already purchased
   * a subscription before creating an account.
   * 
   * The process:
   * 1. User has an anonymous subscription (no AppUserID set)
   * 2. User creates an account and logs in
   * 3. We set the AppUserID to the new user ID
   * 4. RevenueCat transfers the subscription to the new user ID
   * 
   * 🎯 This ensures users don't lose their subscription when they create an account.
   */
  public async transferAnonymousSubscriptionToUser(userId: string): Promise<void> {
    if (!userId) {
      throw new Error('User ID is required for transfer');
    }

    // This sets the AppUserID, which transfers any anonymous purchases
    // to the new user ID
    await revenueCatService.setAppUserID(userId);
    
    console.log(`[AuthService] Transferred anonymous subscription to user: ${userId}`);
  }

  /**
   * Get the current user
   */
  public getCurrentUser(): User | null {
    return this.currentUser;
  }

  /**
   * Check if user is authenticated
   */
  public isUserAuthenticated(): boolean {
    return this.isAuthenticated;
  }
}

// Export singleton instance
export const authService = AuthService.getInstance();
export default authService;
```

#### Step 3.2: Update Subscription Context to Handle Auth Changes

**File: `FitTrackPro/src/context/SubscriptionContext.tsx` (Additions)**

Add these methods to the SubscriptionContext:

```typescript
// Add to the context value interface
interface SubscriptionContextValue extends SubscriptionState {
  // ... existing methods ...
  
  // Auth integration methods
  transferAnonymousSubscription: (userId: string) => Promise<void>;
  isAnonymousUserSubscribed: boolean; // Was subscription purchased while anonymous?
}

// Add to the provider
const [anonymousSubscriptionDetected, setAnonymousSubscriptionDetected] = useState<boolean>(false);

// Add method to check if anonymous user has subscription
const checkAnonymousSubscription = useCallback(async (customerInfo: CustomerInfo | null) => {
  if (!customerInfo) return false;
  
  // Check if there are any active entitlements
  const hasEntitlements = Object.keys(customerInfo.entitlements.active).length > 0;
  
  // We also need to check if the user is anonymous
  // In a real app, you might store a flag when an anonymous user purchases
  const isAnonymous = state.isAnonymous;
  
  return hasEntitlements && isAnonymous;
}, [state.isAnonymous]);

// Add method to transfer anonymous subscription
const transferAnonymousSubscription = useCallback(async (userId: string) => {
  if (!userId) {
    throw new Error('User ID is required for subscription transfer');
  }
  
  try {
    setState(prev => ({ ...prev, isLoading: true }));
    
    // Transfer the subscription to the new user ID
    await authService.transferAnonymousSubscriptionToUser(userId);
    
    // Refresh customer info with the new user ID
    const customerInfo = await revenueCatService.getCustomerInfo();
    updateStateFromCustomerInfo(customerInfo);
    
    // Update state
    setState(prev => ({
      ...prev,
      isAnonymous: false,
      appUserId: userId,
      isLoading: false,
    }));
    
    setAnonymousSubscriptionDetected(false);
    
  } catch (error) {
    console.error('[SubscriptionContext] Transfer failed:', error);
    setState(prev => ({
      ...prev,
      isLoading: false,
      error: error instanceof Error ? error.message : 'Failed to transfer subscription',
    }));
    throw error;
  }
}, [updateStateFromCustomerInfo]);

// Add anonymous subscription detection to the initialization
// In initializeSubscription, after getting customerInfo:
const hasAnonymousSubscription = await checkAnonymousSubscription(customerInfo);
setAnonymousSubscriptionDetected(hasAnonymousSubscription);

// Add to context value
const contextValue: SubscriptionContextValue = {
  // ... existing properties ...
  transferAnonymousSubscription,
  isAnonymousUserSubscribed: anonymousSubscriptionDetected,
};
```

#### Step 3.3: Create Login Screen

**File: `FitTrackPro/src/screens/LoginScreen.tsx`**

```typescript
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useSubscription } from '../context/SubscriptionContext';
import { authService } from '../services/AuthService';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing } from '../theme/spacing';

/**
 * Login Screen
 * 
 * Allows users to sign in or create an account.
 * Handles the critical case where an anonymous user has a subscription
 * and needs to transfer it to their new account.
 */

export const LoginScreen: React.FC = () => {
  const { isAnonymousUserSubscribed, transferAnonymousSubscription } = useSubscription();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [isSignUp, setIsSignUp] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [showTransferPrompt, setShowTransferPrompt] = useState(false);

  /**
   * Handle login
   */
  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setIsLoading(true);
    try {
      await authService.signIn(email, password);
      
      // After login, check if we need to transfer a subscription
      if (isAnonymousUserSubscribed) {
        setShowTransferPrompt(true);
      } else {
        // Success - the subscription context will handle the rest
        Alert.alert('Welcome back!', 'You are now logged in.');
      }
    } catch (error) {
      Alert.alert('Login Failed', error instanceof Error ? error.message : 'Please try again');
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Handle sign up
   */
  const handleSignUp = async () => {
    if (!email || !password || !displayName) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    if (password.length < 6) {
      Alert.alert('Error', 'Password must be at least 6 characters');
      return;
    }

    setIsLoading(true);
    try {
      await authService.signUp(email, password, displayName);
      
      // Check if we need to transfer an anonymous subscription
      if (isAnonymousUserSubscribed) {
        setShowTransferPrompt(true);
      } else {
        Alert.alert('Welcome!', 'Your account has been created.');
      }
    } catch (error) {
      Alert.alert('Sign Up Failed', error instanceof Error ? error.message : 'Please try again');
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Transfer anonymous subscription to the new user account
   */
  const handleTransferSubscription = async () => {
    const user = authService.getCurrentUser();
    if (!user) {
      Alert.alert('Error', 'No user found to transfer subscription to');
      return;
    }

    setIsLoading(true);
    try {
      await transferAnonymousSubscription(user.id);
      Alert.alert(
        '🎉 Subscription Transferred!',
        'Your subscription has been transferred to your new account. You can now access all premium features.'
      );
      setShowTransferPrompt(false);
    } catch (error) {
      Alert.alert(
        'Transfer Failed',
        'We couldn\'t transfer your subscription. Please contact support for assistance.'
      );
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Skip subscription transfer (user will lose access)
   */
  const handleSkipTransfer = () => {
    Alert.alert(
      'Are you sure?',
      'If you skip this step, you may lose access to your subscription on this device. You can always transfer it later from settings.',
      [
        { text: 'Go Back', style: 'cancel' },
        { 
          text: 'Skip', 
          style: 'destructive',
          onPress: () => {
            setShowTransferPrompt(false);
          },
        },
      ]
    );
  };

  // Show transfer prompt if an anonymous subscription was detected
  if (showTransferPrompt) {
    return (
      <View style={styles.transferContainer}>
        <Text style={styles.transferEmoji}>🎁</Text>
        <Text style={styles.transferTitle}>Found Your Subscription!</Text>
        <Text style={styles.transferDescription}>
          We found a subscription on this device. Would you like to link it to your account?
        </Text>
        <Text style={styles.transferSubtext}>
          This ensures you can access your subscription on all your devices.
        </Text>
        <TouchableOpacity 
          style={styles.transferButton}
          onPress={handleTransferSubscription}
          disabled={isLoading}
        >
          {isLoading ? (
            <ActivityIndicator color={colors.white} />
          ) : (
            <Text style={styles.transferButtonText}>Yes, Transfer Subscription</Text>
          )}
        </TouchableOpacity>
        <TouchableOpacity 
          style={styles.skipButton}
          onPress={handleSkipTransfer}
          disabled={isLoading}
        >
          <Text style={styles.skipButtonText}>Skip for Now</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.logo}>💪</Text>
          <Text style={styles.title}>FitTrack Pro</Text>
          <Text style={styles.subtitle}>
            {isSignUp ? 'Create your account' : 'Welcome back!'}
          </Text>
        </View>

        <View style={styles.form}>
          {isSignUp && (
            <TextInput
              style={styles.input}
              placeholder="Display Name"
              value={displayName}
              onChangeText={setDisplayName}
              autoCapitalize="words"
            />
          )}
          
          <TextInput
            style={styles.input}
            placeholder="Email"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
          
          <TextInput
            style={styles.input}
            placeholder="Password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            autoCapitalize="none"
          />

          <TouchableOpacity
            style={styles.mainButton}
            onPress={isSignUp ? handleSignUp : handleLogin}
            disabled={isLoading}
          >
            {isLoading ? (
              <ActivityIndicator color={colors.white} />
            ) : (
              <Text style={styles.mainButtonText}>
                {isSignUp ? 'Create Account' : 'Sign In'}
              </Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.switchButton}
            onPress={() => setIsSignUp(!isSignUp)}
            disabled={isLoading}
          >
            <Text style={styles.switchText}>
              {isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up"}
            </Text>
          </TouchableOpacity>

          <View style={styles.anonymousSection}>
            <Text style={styles.anonymousText}>or</Text>
            <TouchableOpacity
              style={styles.anonymousButton}
              onPress={() => {
                // Continue as anonymous - just close the login screen
                // The subscription context will handle it
              }}
            >
              <Text style={styles.anonymousButtonText}>Continue as Guest</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: spacing.xl,
  },
  header: {
    alignItems: 'center',
    marginBottom: spacing.xxl,
  },
  logo: {
    fontSize: 60,
    marginBottom: spacing.md,
  },
  title: {
    ...typography.h1,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  subtitle: {
    ...typography.body,
    color: colors.text.secondary,
  },
  form: {
    gap: spacing.md,
  },
  input: {
    backgroundColor: colors.background.secondary,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 12,
    ...typography.body,
    color: colors.text.primary,
    borderWidth: 1,
    borderColor: colors.border.light,
  },
  mainButton: {
    backgroundColor: colors.primary.main,
    paddingVertical: spacing.md,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: spacing.sm,
  },
  mainButtonText: {
    ...typography.button,
    color: colors.text.inverse,
  },
  switchButton: {
    padding: spacing.md,
    alignItems: 'center',
  },
  switchText: {
    ...typography.bodySmall,
    color: colors.primary.main,
  },
  anonymousSection: {
    marginTop: spacing.lg,
    alignItems: 'center',
  },
  anonymousText: {
    ...typography.bodySmall,
    color: colors.text.tertiary,
    marginBottom: spacing.sm,
  },
  anonymousButton: {
    padding: spacing.sm,
  },
  anonymousButtonText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  
  // Transfer prompt styles
  transferContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.xxl,
    backgroundColor: colors.background.primary,
  },
  transferEmoji: {
    fontSize: 64,
    marginBottom: spacing.lg,
  },
  transferTitle: {
    ...typography.h3,
    color: colors.text.primary,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  transferDescription: {
    ...typography.body,
    color: colors.text.secondary,
    textAlign: 'center',
    marginBottom: spacing.sm,
  },
  transferSubtext: {
    ...typography.bodySmall,
    color: colors.text.tertiary,
    textAlign: 'center',
    marginBottom: spacing.xl,
  },
  transferButton: {
    backgroundColor: colors.primary.main,
    paddingHorizontal: spacing.xxl,
    paddingVertical: spacing.md,
    borderRadius: 12,
    width: '100%',
    alignItems: 'center',
  },
  transferButtonText: {
    ...typography.button,
    color: colors.text.inverse,
  },
  skipButton: {
    marginTop: spacing.md,
    padding: spacing.md,
  },
  skipButtonText: {
    ...typography.bodySmall,
    color: colors.text.tertiary,
  },
});

export default LoginScreen;
```

---

## Phase 4: Subscription Status Dashboard

### The Target

Create a detailed subscription status dashboard where users can view their subscription details and manage their account.

### The Concept

Users need to see:
- What they're subscribed to
- When it expires
- How to cancel or manage their subscription
- Their billing history

This builds trust and reduces support tickets.

### Implementation

**File: `FitTrackPro/src/screens/SubscriptionStatusScreen.tsx`**

```typescript
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Linking,
} from 'react-native';
import { useSubscription } from '../context/SubscriptionContext';
import { Card } from '../components/common/Card';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing } from '../theme/spacing';

/**
 * Subscription Status Screen
 * 
 * Displays detailed subscription information to the user.
 * Includes:
 * - Active entitlements with expiration dates
 * - Billing history (if available)
 * - Management options
 * - Support contact info
 */

export const SubscriptionStatusScreen: React.FC = () => {
  const { customerInfo, isSubscribed, activeEntitlements, refreshSubscription } = useSubscription();

  // Format date for display
  const formatDate = (dateString: string | undefined): string => {
    if (!dateString) return 'N/A';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      });
    } catch {
      return dateString;
    }
  };

  // Get subscription details
  const getSubscriptionDetails = () => {
    if (!customerInfo) return null;
    
    // Find the first active entitlement for display
    const firstEntitlement = Object.values(activeEntitlements)[0];
    if (!firstEntitlement) return null;
    
    return {
      productIdentifier: firstEntitlement.productIdentifier || 'Unknown',
      purchaseDate: firstEntitlement.purchaseDate,
      expirationDate: firstEntitlement.expirationDate,
      willRenew: firstEntitlement.willRenew,
      isSandbox: firstEntitlement.isSandbox,
    };
  };

  const details = getSubscriptionDetails();

  // Open subscription management URL
  const handleManageSubscription = () => {
    if (customerInfo?.managementURL) {
      Linking.openURL(customerInfo.managementURL);
    } else {
      // Fallback: open App Store or Play Store
      // We'll implement this in production
    }
  };

  return (
    <ScrollView 
      style={styles.container}
      contentContainerStyle={styles.content}
      showsVerticalScrollIndicator={false}
    >
      {/* Status Overview */}
      <View style={styles.statusCard}>
        <View style={styles.statusIcon}>
          <Text style={styles.statusEmoji}>
            {isSubscribed ? '✅' : '⚠️'}
          </Text>
        </View>
        <Text style={styles.statusTitle}>
          {isSubscribed ? 'Subscription Active' : 'No Active Subscription'}
        </Text>
        <Text style={styles.statusSubtext}>
          {isSubscribed 
            ? 'You have access to all premium features'
            : 'Upgrade to access premium features'
          }
        </Text>
      </View>

      {/* Subscription Details */}
      {isSubscribed && details && (
        <Card variant="elevated" style={styles.detailsCard}>
          <Text style={styles.cardTitle}>Subscription Details</Text>
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Plan</Text>
            <Text style={styles.detailValue}>
              {details.productIdentifier.split('.').pop() || details.productIdentifier}
            </Text>
          </View>
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Purchase Date</Text>
            <Text style={styles.detailValue}>
              {formatDate(details.purchaseDate)}
            </Text>
          </View>
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Expiration Date</Text>
            <Text style={styles.detailValue}>
              {formatDate(details.expirationDate)}
            </Text>
          </View>
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Auto-Renew</Text>
            <Text style={[styles.detailValue, details.willRenew ? styles.renewActive : styles.renewInactive]}>
              {details.willRenew ? '✅ Active' : '❌ Inactive'}
            </Text>
          </View>
        </Card>
      )}

      {/* Entitlements List */}
      {isSubscribed && (
        <Card variant="elevated" style={styles.entitlementsCard}>
          <Text style={styles.cardTitle}>Your Premium Features</Text>
          {Object.entries(activeEntitlements).map(([key, value]) => (
            <View key={key} style={styles.entitlementItem}>
              <View style={styles.entitlementIconContainer}>
                <Text style={styles.entitlementIcon}>✓</Text>
              </View>
              <View style={styles.entitlementInfo}>
                <Text style={styles.entitlementName}>
                  {key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                </Text>
                {value.expirationDate && (
                  <Text style={styles.entitlementDate}>
                    Expires: {formatDate(value.expirationDate)}
                  </Text>
                )}
              </View>
            </View>
          ))}
        </Card>
      )}

      {/* Management Actions */}
      <Card variant="elevated" style={styles.actionsCard}>
        <Text style={styles.cardTitle}>Manage Subscription</Text>
        
        {customerInfo?.managementURL && (
          <TouchableOpacity 
            style={styles.actionItem}
            onPress={handleManageSubscription}
          >
            <Text style={styles.actionItemIcon}>🔄</Text>
            <View style={styles.actionItemInfo}>
              <Text style={styles.actionItemTitle}>Manage in App Store</Text>
              <Text style={styles.actionItemDescription}>
                View, modify, or cancel your subscription
              </Text>
            </View>
            <Text style={styles.actionArrow}>›</Text>
          </TouchableOpacity>
        )}
        
        <TouchableOpacity 
          style={styles.actionItem}
          onPress={refreshSubscription}
        >
          <Text style={styles.actionItemIcon}>🔄</Text>
          <View style={styles.actionItemInfo}>
            <Text style={styles.actionItemTitle}>Refresh Subscription Status</Text>
            <Text style={styles.actionItemDescription}>
              Check for the latest subscription updates
            </Text>
          </View>
          <Text style={styles.actionArrow}>›</Text>
        </TouchableOpacity>
      </Card>

      {/* Support Section */}
      <Card variant="elevated" style={styles.supportCard}>
        <Text style={styles.cardTitle}>Need Help?</Text>
        <Text style={styles.supportText}>
          If you're experiencing any issues with your subscription, please contact our support team.
        </Text>
        <TouchableOpacity 
          style={styles.supportButton}
          onPress={() => {
            // Open support email
          }}
        >
          <Text style={styles.supportButtonText}>Contact Support</Text>
        </TouchableOpacity>
      </Card>

      {/* Fine Print */}
      <Text style={styles.finePrint}>
        All prices are in USD. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.
      </Text>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
  },
  content: {
    padding: spacing.lg,
    paddingBottom: spacing.xxxl,
  },
  
  // Status Card
  statusCard: {
    backgroundColor: colors.background.secondary,
    borderRadius: 16,
    padding: spacing.xl,
    alignItems: 'center',
    marginBottom: spacing.lg,
    shadowColor: colors.shadow.medium,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
  },
  statusIcon: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: colors.background.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  statusEmoji: {
    fontSize: 32,
  },
  statusTitle: {
    ...typography.h3,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  statusSubtext: {
    ...typography.body,
    color: colors.text.secondary,
    textAlign: 'center',
  },
  
  // Cards
  detailsCard: {
    marginBottom: spacing.md,
  },
  entitlementsCard: {
    marginBottom: spacing.md,
  },
  actionsCard: {
    marginBottom: spacing.md,
  },
  supportCard: {
    marginBottom: spacing.md,
  },
  cardTitle: {
    ...typography.h4,
    color: colors.text.primary,
    marginBottom: spacing.md,
  },
  
  // Detail rows
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.border.light,
  },
  detailLabel: {
    ...typography.body,
    color: colors.text.secondary,
  },
  detailValue: {
    ...typography.body,
    color: colors.text.primary,
  },
  renewActive: {
    color: colors.secondary.main,
  },
  renewInactive: {
    color: colors.status.error,
  },
  
  // Entitlements
  entitlementItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.border.light,
  },
  entitlementIconContainer: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: colors.secondary.main,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  entitlementIcon: {
    color: colors.white,
    fontWeight: 'bold',
    fontSize: 16,
  },
  entitlementInfo: {
    flex: 1,
  },
  entitlementName: {
    ...typography.bodyBold,
    color: colors.text.primary,
    textTransform: 'capitalize',
  },
  entitlementDate: {
    ...typography.caption,
    color: colors.text.secondary,
  },
  
  // Actions
  actionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border.light,
  },
  actionItemIcon: {
    fontSize: 24,
    marginRight: spacing.md,
  },
  actionItemInfo: {
    flex: 1,
  },
  actionItemTitle: {
    ...typography.bodyBold,
    color: colors.text.primary,
  },
  actionItemDescription: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  actionArrow: {
    fontSize: 24,
    color: colors.text.tertiary,
  },
  
  // Support
  supportText: {
    ...typography.body,
    color: colors.text.secondary,
    marginBottom: spacing.md,
  },
  supportButton: {
    backgroundColor: colors.primary.light,
    paddingVertical: spacing.md,
    borderRadius: 12,
    alignItems: 'center',
  },
  supportButtonText: {
    ...typography.button,
    color: colors.text.inverse,
  },
  
  // Fine print
  finePrint: {
    ...typography.caption,
    color: colors.text.tertiary,
    textAlign: 'center',
    marginTop: spacing.md,
    lineHeight: 18,
  },
});

export default SubscriptionStatusScreen;
```

---

## Verification

### Test Subscription State Management

1. **Initial Load Test**:
   - Launch the app without being logged in
   - Verify the paywall shows (no subscription)
   - Verify subscription context loads correctly

2. **Purchase Flow Test**:
   - Complete a purchase in sandbox
   - Verify the app transitions to the main screen
   - Verify active entitlements appear

3. **Feature Gating Test**:
   - Navigate to premium features
   - Verify access is granted based on entitlements
   - Test both granted and denied scenarios

4. **Login/Logout Test**:
   - Create an account while subscribed
   - Verify subscription transfers correctly
   - Logout and verify state resets

5. **Offline Test**:
   - Turn off internet connection
   - Open the app
   - Verify cached subscription state loads

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Subscription not transferring after login | Ensure `setAppUserID` is called correctly |
| Entitlement not showing | Check RevenueCat configuration, refresh state |
| App crashes on logout | Ensure RevenueCat reset is handled properly |
| Offline state not loading | Check AsyncStorage permissions |

---

## Module Summary

Congratulations! You've completed Part 3 of the RevenueCat tutorial series. Here's what you've accomplished:

✅ **Built Subscription Context**: Centralized state management with React Context
✅ **Implemented Premium Gating**: Multiple levels of feature protection
✅ **Added User Identity Management**: Anonymous vs. authenticated users
✅ **Created Account Migration Flow**: Transfer subscriptions between users
✅ **Built Subscription Dashboard**: Detailed view for users
✅ **Added Offline Support**: Cached subscription state
✅ **Implemented Real-time Updates**: Automatic state sync with RevenueCat

### What You Can Do Now

Your app now has:
- Complete subscription state management
- Premium feature gating throughout the app
- User identity integration with RevenueCat
- Account migration capabilities
- A comprehensive subscription dashboard

### Next Steps

In **Part 4: Webhooks, Analytics & Revenue Optimization**, we'll:
- Set up RevenueCat webhooks
- Build a backend to handle subscription events
- Integrate analytics for revenue tracking
- Implement churn reduction strategies
- Set up A/B testing with RevenueCat Experiments

---

You now have a fully functional subscription app with state management, gating, and user identity. In Part 4, we'll build the backend infrastructure that makes everything production-ready.
