# Part 5: Integrating RevenueCat with React Native

## Module Overview

Welcome to the final part of our RevenueCat tutorial series! This is where we bring everything together into a complete, production-ready React Native application. By the end of this module, you'll have a fully functional subscription app that combines all the concepts we've learned.

By the end of this module, you'll have:

- ✅ A complete React Native app with navigation
- ✅ Full subscription flow from paywall to premium features
- ✅ User authentication with subscription transfer
- ✅ Offline support and caching
- ✅ Production-ready error handling
- ✅ Analytics integration
- ✅ App store configuration for release

Think of this as the "grand finale" – we're assembling all the pieces we've built throughout the series into one polished application.

---

## Phase 1: Project Structure & Navigation

### The Target

Set up the complete project structure with navigation between all screens.

### The Concept

A well-organized project structure is crucial for maintainability. We'll use React Navigation for screen management and organize our code by feature.

### Implementation

#### Step 1.1: Install Dependencies

**File: `FitTrackPro/frontend/package.json` (Additions)**

```json
{
  "dependencies": {
    // Existing dependencies...
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/native-stack": "^6.9.17",
    "@react-navigation/bottom-tabs": "^6.5.11",
    "react-native-screens": "^3.27.0",
    "react-native-safe-area-context": "^4.7.4",
    "react-native-vector-icons": "^10.0.0",
    "react-native-gesture-handler": "^2.12.0",
    "react-native-reanimated": "^3.5.4",
    "@react-native-async-storage/async-storage": "^1.19.6",
    "react-native-config": "^1.5.1"
  }
}
```

**Install the dependencies:**

```bash
cd FitTrackPro/frontend
npm install @react-navigation/native @react-navigation/native-stack @react-navigation/bottom-tabs
npm install react-native-screens react-native-safe-area-context
npm install react-native-vector-icons react-native-gesture-handler react-native-reanimated
npm install react-native-config
```

#### Step 1.2: Create Navigation Setup

**File: `FitTrackPro/frontend/src/navigation/types.ts`**

```typescript
/**
 * Navigation Types
 * 
 * Defines the type-safe navigation structure for the app.
 * 
 * 🧭 This ensures we don't accidentally navigate to the wrong screen
 * or pass incorrect parameters.
 */

import { NavigatorScreenParams } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';

export type RootStackParamList = {
  Splash: undefined;
  Login: undefined;
  Paywall: undefined;
  Main: NavigatorScreenParams<MainTabParamList>;
  SubscriptionStatus: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Workouts: undefined;
  Nutrition: undefined;
  Trainer: undefined;
  Profile: undefined;
};

export type RootStackNavigationProp = NativeStackNavigationProp<RootStackParamList>;

// Screen names as constants for type safety
export const SCREENS = {
  SPLASH: 'Splash' as const,
  LOGIN: 'Login' as const,
  PAYWALL: 'Paywall' as const,
  MAIN: 'Main' as const,
  SUBSCRIPTION_STATUS: 'SubscriptionStatus' as const,
};

export const TABS = {
  HOME: 'Home' as const,
  WORKOUTS: 'Workouts' as const,
  NUTRITION: 'Nutrition' as const,
  TRAINER: 'Trainer' as const,
  PROFILE: 'Profile' as const,
};
```

**File: `FitTrackPro/frontend/src/navigation/RootNavigator.tsx`**

```typescript
import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useSubscription } from '../context/SubscriptionContext';
import { RootStackParamList, SCREENS } from './types';

// Import screens
import { SplashScreen } from '../screens/SplashScreen';
import { LoginScreen } from '../screens/LoginScreen';
import { PaywallScreen } from '../screens/PaywallScreen';
import { MainNavigator } from './MainNavigator';
import { SubscriptionStatusScreen } from '../screens/SubscriptionStatusScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();

/**
 * Root Navigator
 * 
 * The main navigation container that manages the app's screens.
 * 
 * 🧭 Navigation flow:
 * 1. Splash → Check authentication & subscription status
 * 2. If not authenticated → Login
 * 3. If not subscribed → Paywall
 * 4. If subscribed → Main app
 * 
 * This ensures users always see the right screen at the right time.
 */
export const RootNavigator: React.FC = () => {
  const { isSubscribed, isLoading, isAuthenticated } = useSubscription();
  const [initialRoute, setInitialRoute] = useState<keyof RootStackParamList>('Splash');

  useEffect(() => {
    if (!isLoading) {
      // Determine initial route based on state
      if (!isAuthenticated) {
        setInitialRoute('Login');
      } else if (!isSubscribed) {
        setInitialRoute('Paywall');
      } else {
        setInitialRoute('Main');
      }
    }
  }, [isLoading, isAuthenticated, isSubscribed]);

  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName={initialRoute}
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
        }}
      >
        <Stack.Screen name={SCREENS.SPLASH} component={SplashScreen} />
        <Stack.Screen name={SCREENS.LOGIN} component={LoginScreen} />
        <Stack.Screen name={SCREENS.PAYWALL} component={PaywallScreen} />
        <Stack.Screen name={SCREENS.MAIN} component={MainNavigator} />
        <Stack.Screen 
          name={SCREENS.SUBSCRIPTION_STATUS} 
          component={SubscriptionStatusScreen}
          options={{
            headerShown: true,
            headerTitle: 'Subscription Status',
            headerBackTitle: 'Back',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

**File: `FitTrackPro/frontend/src/navigation/MainNavigator.tsx`**

```typescript
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/Ionicons';
import { MainTabParamList, TABS } from './types';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';

// Import main screens
import { HomeScreen } from '../screens/main/HomeScreen';
import { WorkoutsScreen } from '../screens/main/WorkoutsScreen';
import { NutritionScreen } from '../screens/main/NutritionScreen';
import { TrainerScreen } from '../screens/main/TrainerScreen';
import { ProfileScreen } from '../screens/main/ProfileScreen';

const Tab = createBottomTabNavigator<MainTabParamList>();

/**
 * Main Navigator
 * 
 * The main tab navigation for authenticated, subscribed users.
 * 
 * 🏠 This is the primary navigation for the app.
 * Each tab represents a major feature area.
 */
export const MainNavigator: React.FC = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: string = '';

          switch (route.name) {
            case TABS.HOME:
              iconName = focused ? 'home' : 'home-outline';
              break;
            case TABS.WORKOUTS:
              iconName = focused ? 'barbell' : 'barbell-outline';
              break;
            case TABS.NUTRITION:
              iconName = focused ? 'restaurant' : 'restaurant-outline';
              break;
            case TABS.TRAINER:
              iconName = focused ? 'chatbubbles' : 'chatbubbles-outline';
              break;
            case TABS.PROFILE:
              iconName = focused ? 'person' : 'person-outline';
              break;
            default:
              iconName = 'circle';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: colors.primary.main,
        tabBarInactiveTintColor: colors.text.tertiary,
        tabBarStyle: {
          backgroundColor: colors.background.secondary,
          borderTopColor: colors.border.light,
          paddingBottom: 8,
          paddingTop: 8,
          height: 64,
        },
        tabBarLabelStyle: {
          ...typography.caption,
          fontWeight: '500',
        },
        headerShown: false,
      })}
    >
      <Tab.Screen 
        name={TABS.HOME} 
        component={HomeScreen}
        options={{
          tabBarLabel: 'Home',
        }}
      />
      <Tab.Screen 
        name={TABS.WORKOUTS} 
        component={WorkoutsScreen}
        options={{
          tabBarLabel: 'Workouts',
        }}
      />
      <Tab.Screen 
        name={TABS.NUTRITION} 
        component={NutritionScreen}
        options={{
          tabBarLabel: 'Nutrition',
        }}
      />
      <Tab.Screen 
        name={TABS.TRAINER} 
        component={TrainerScreen}
        options={{
          tabBarLabel: 'Trainer',
        }}
      />
      <Tab.Screen 
        name={TABS.PROFILE} 
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profile',
        }}
      />
    </Tab.Navigator>
  );
};
```

---

## Phase 2: Main Application Screens

### The Target

Build the complete main application screens with premium features.

### The Concept

The main app provides the core functionality that users subscribe for. Each screen demonstrates different aspects of premium feature gating.

### Implementation

**File: `FitTrackPro/frontend/src/screens/main/HomeScreen.tsx`**

```typescript
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
} from 'react-native';
import { useSubscription } from '../../context/SubscriptionContext';
import { Card } from '../../components/common/Card';
import { EntitlementGate } from '../../components/guards/EntitlementGate';
import { colors } from '../../theme/colors';
import { typography } from '../../theme/typography';
import { spacing } from '../../theme/spacing';

/**
 * Home Screen
 * 
 * The main dashboard showing user's fitness overview.
 * Premium features are gated based on subscription status.
 */

export const HomeScreen: React.FC = () => {
  const { activeEntitlements } = useSubscription();

  // Mock workout data
  const todayWorkout = {
    name: 'Full Body Strength',
    exercises: 8,
    duration: 45,
    calories: 320,
  };

  const progress = {
    weeklyWorkouts: 4,
    weeklyGoal: 5,
    streak: 12,
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.greeting}>Good morning 👋</Text>
          <Text style={styles.subGreeting}>Let's crush your fitness goals today!</Text>
        </View>
        <View style={styles.streakBadge}>
          <Text style={styles.streakEmoji}>🔥</Text>
          <Text style={styles.streakText}>{progress.streak} day streak</Text>
        </View>
      </View>

      {/* Today's Workout */}
      <Card variant="elevated" style={styles.workoutCard}>
        <Text style={styles.sectionTitle}>Today's Workout</Text>
        <View style={styles.workoutContent}>
          <View style={styles.workoutInfo}>
            <Text style={styles.workoutName}>{todayWorkout.name}</Text>
            <View style={styles.workoutStats}>
              <Text style={styles.workoutStat}>🏋️ {todayWorkout.exercises} exercises</Text>
              <Text style={styles.workoutStat}>⏱️ {todayWorkout.duration} min</Text>
              <Text style={styles.workoutStat}>🔥 {todayWorkout.calories} cal</Text>
            </View>
          </View>
          <TouchableOpacity style={styles.startButton}>
            <Text style={styles.startButtonText}>Start</Text>
          </TouchableOpacity>
        </View>
      </Card>

      {/* Progress */}
      <Card variant="elevated" style={styles.progressCard}>
        <Text style={styles.sectionTitle}>Weekly Progress</Text>
        <View style={styles.progressBar}>
          <View 
            style={[
              styles.progressFill,
              { width: `${(progress.weeklyWorkouts / progress.weeklyGoal) * 100}%` }
            ]} 
          />
        </View>
        <Text style={styles.progressText}>
          {progress.weeklyWorkouts} of {progress.weeklyGoal} workouts this week
        </Text>
      </Card>

      {/* Premium Feature Preview */}
      <View style={styles.premiumSection}>
        <Text style={styles.sectionTitle}>Premium Features</Text>
        
        {/* Premium Workouts Preview */}
        <EntitlementGate entitlementId="premium_workouts">
          <Card style={styles.premiumCard}>
            <View style={styles.premiumCardHeader}>
              <Text style={styles.premiumIcon}>🏋️</Text>
              <View style={styles.premiumInfo}>
                <Text style={styles.premiumTitle}>Premium Workouts</Text>
                <Text style={styles.premiumSubtitle}>500+ exercises available</Text>
              </View>
              <View style={styles.premiumBadge}>
                <Text style={styles.premiumBadgeText}>Unlocked</Text>
              </View>
            </View>
          </Card>
        </EntitlementGate>

        {/* Nutrition Tracking Preview */}
        <EntitlementGate entitlementId="nutrition_tracking">
          <Card style={styles.premiumCard}>
            <View style={styles.premiumCardHeader}>
              <Text style={styles.premiumIcon}>🥗</Text>
              <View style={styles.premiumInfo}>
                <Text style={styles.premiumTitle}>Nutrition Tracking</Text>
                <Text style={styles.premiumSubtitle}>Full meal logging</Text>
              </View>
              <View style={styles.premiumBadge}>
                <Text style={styles.premiumBadgeText}>Unlocked</Text>
              </View>
            </View>
          </Card>
        </EntitlementGate>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
    paddingHorizontal: spacing.lg,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: spacing.xl,
    paddingBottom: spacing.lg,
  },
  greeting: {
    ...typography.h3,
    color: colors.text.primary,
  },
  subGreeting: {
    ...typography.body,
    color: colors.text.secondary,
  },
  streakBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.background.secondary,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.border.light,
  },
  streakEmoji: {
    fontSize: 16,
    marginRight: spacing.xs,
  },
  streakText: {
    ...typography.bodySmall,
    color: colors.text.primary,
    fontWeight: '600',
  },
  sectionTitle: {
    ...typography.h4,
    color: colors.text.primary,
    marginBottom: spacing.md,
  },
  workoutCard: {
    marginBottom: spacing.md,
  },
  workoutContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  workoutInfo: {
    flex: 1,
  },
  workoutName: {
    ...typography.bodyBold,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  workoutStats: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },
  workoutStat: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  startButton: {
    backgroundColor: colors.primary.main,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 8,
  },
  startButtonText: {
    ...typography.buttonSmall,
    color: colors.text.inverse,
  },
  progressCard: {
    marginBottom: spacing.lg,
  },
  progressBar: {
    height: 8,
    backgroundColor: colors.background.tertiary,
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: spacing.sm,
  },
  progressFill: {
    height: '100%',
    backgroundColor: colors.secondary.main,
    borderRadius: 4,
  },
  progressText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  premiumSection: {
    marginBottom: spacing.xl,
  },
  premiumCard: {
    marginBottom: spacing.sm,
  },
  premiumCardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  premiumIcon: {
    fontSize: 28,
    marginRight: spacing.md,
  },
  premiumInfo: {
    flex: 1,
  },
  premiumTitle: {
    ...typography.bodyBold,
    color: colors.text.primary,
  },
  premiumSubtitle: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  premiumBadge: {
    backgroundColor: colors.secondary.main,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: 12,
  },
  premiumBadgeText: {
    ...typography.caption,
    color: colors.text.inverse,
    fontWeight: '600',
  },
});
```

**File: `FitTrackPro/frontend/src/screens/main/WorkoutsScreen.tsx`**

```typescript
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  FlatList,
} from 'react-native';
import { RequireEntitlement } from '../../components/guards/RequireEntitlement';
import { Card } from '../../components/common/Card';
import { colors } from '../../theme/colors';
import { typography } from '../../theme/typography';
import { spacing } from '../../theme/spacing';
import { useNavigation } from '@react-navigation/native';

/**
 * Workouts Screen
 * 
 * Shows available workouts. Premium workouts are gated behind
 * the premium_workouts entitlement.
 * 
 * 🏋️ This demonstrates how to gate content within a screen.
 */

// Mock workout data
const FREE_WORKOUTS = [
  { id: '1', name: 'Morning Stretch', difficulty: 'Beginner', duration: 10 },
  { id: '2', name: 'Quick Cardio', difficulty: 'Beginner', duration: 15 },
  { id: '3', name: 'Core Basics', difficulty: 'Intermediate', duration: 20 },
];

const PREMIUM_WORKOUTS = [
  { id: '4', name: 'Advanced HIIT', difficulty: 'Advanced', duration: 45 },
  { id: '5', name: 'Strength Training', difficulty: 'Intermediate', duration: 40 },
  { id: '6', name: 'Power Yoga', difficulty: 'Intermediate', duration: 35 },
  { id: '7', name: 'Full Body Blast', difficulty: 'Advanced', duration: 50 },
  { id: '8', name: 'Endurance Run', difficulty: 'Advanced', duration: 60 },
];

export const WorkoutsScreen: React.FC = () => {
  const navigation = useNavigation();
  const [selectedCategory, setSelectedCategory] = useState<'all' | 'free' | 'premium'>('all');

  const getDisplayedWorkouts = () => {
    if (selectedCategory === 'free') return FREE_WORKOUTS;
    if (selectedCategory === 'premium') return PREMIUM_WORKOUTS;
    return [...FREE_WORKOUTS, ...PREMIUM_WORKOUTS];
  };

  const renderWorkout = ({ item }: { item: any }) => (
    <TouchableOpacity 
      style={styles.workoutItem}
      onPress={() => {
        // Navigate to workout detail
        console.log('Selected workout:', item.name);
      }}
    >
      <View style={styles.workoutItemContent}>
        <Text style={styles.workoutItemName}>{item.name}</Text>
        <View style={styles.workoutItemTags}>
          <Text style={styles.workoutItemTag}>{item.difficulty}</Text>
          <Text style={styles.workoutItemTag}>{item.duration} min</Text>
        </View>
      </View>
      <Text style={styles.workoutArrow}>›</Text>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* Category Filter */}
      <View style={styles.filterContainer}>
        <TouchableOpacity
          style={[styles.filterButton, selectedCategory === 'all' && styles.filterActive]}
          onPress={() => setSelectedCategory('all')}
        >
          <Text style={[styles.filterText, selectedCategory === 'all' && styles.filterTextActive]}>
            All
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.filterButton, selectedCategory === 'free' && styles.filterActive]}
          onPress={() => setSelectedCategory('free')}
        >
          <Text style={[styles.filterText, selectedCategory === 'free' && styles.filterTextActive]}>
            Free
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.filterButton, selectedCategory === 'premium' && styles.filterActive]}
          onPress={() => setSelectedCategory('premium')}
        >
          <Text style={[styles.filterText, selectedCategory === 'premium' && styles.filterTextActive]}>
            Premium ⭐
          </Text>
        </TouchableOpacity>
      </View>

      {/* Workout List */}
      <FlatList
        data={getDisplayedWorkouts()}
        renderItem={renderWorkout}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      />

      {/* Premium Section (gated) */}
      <RequireEntitlement 
        entitlementId="premium_workouts"
        onUpgradePress={() => {
          // Navigate to paywall
          navigation.navigate('Paywall' as never);
        }}
      >
        <View style={styles.premiumSection}>
          <Card variant="elevated" style={styles.premiumCard}>
            <Text style={styles.premiumEmoji}>🏋️</Text>
            <Text style={styles.premiumTitle}>Advanced Workouts Unlocked!</Text>
            <Text style={styles.premiumDescription}>
              You have access to all premium workouts with advanced techniques and personalized plans.
            </Text>
          </Card>
        </View>
      </RequireEntitlement>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
  },
  filterContainer: {
    flexDirection: 'row',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    backgroundColor: colors.background.secondary,
    borderBottomWidth: 1,
    borderBottomColor: colors.border.light,
  },
  filterButton: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 20,
    marginRight: spacing.sm,
    backgroundColor: colors.background.tertiary,
  },
  filterActive: {
    backgroundColor: colors.primary.main,
  },
  filterText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  filterTextActive: {
    color: colors.text.inverse,
    fontWeight: '600',
  },
  listContent: {
    padding: spacing.lg,
  },
  workoutItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: colors.background.secondary,
    padding: spacing.md,
    borderRadius: 12,
    marginBottom: spacing.sm,
    borderWidth: 1,
    borderColor: colors.border.light,
  },
  workoutItemContent: {
    flex: 1,
  },
  workoutItemName: {
    ...typography.bodyBold,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  workoutItemTags: {
    flexDirection: 'row',
    gap: spacing.sm,
  },
  workoutItemTag: {
    ...typography.caption,
    color: colors.text.secondary,
    backgroundColor: colors.background.tertiary,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: 12,
  },
  workoutArrow: {
    fontSize: 24,
    color: colors.text.tertiary,
  },
  premiumSection: {
    padding: spacing.lg,
    paddingTop: 0,
  },
  premiumCard: {
    alignItems: 'center',
    padding: spacing.xl,
  },
  premiumEmoji: {
    fontSize: 48,
    marginBottom: spacing.md,
  },
  premiumTitle: {
    ...typography.h4,
    color: colors.text.primary,
    textAlign: 'center',
    marginBottom: spacing.sm,
  },
  premiumDescription: {
    ...typography.body,
    color: colors.text.secondary,
    textAlign: 'center',
  },
});
```

**File: `FitTrackPro/frontend/src/screens/main/ProfileScreen.tsx`**

```typescript
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useSubscription } from '../../context/SubscriptionContext';
import { useNavigation } from '@react-navigation/native';
import { Card } from '../../components/common/Card';
import { colors } from '../../theme/colors';
import { typography } from '../../theme/typography';
import { spacing } from '../../theme/spacing';
import { authService } from '../../services/AuthService';

/**
 * Profile Screen
 * 
 * Shows user profile and subscription management options.
 * Includes navigation to subscription status and logout.
 */

export const ProfileScreen: React.FC = () => {
  const navigation = useNavigation();
  const { isSubscribed, customerInfo, logout } = useSubscription();
  const currentUser = authService.getCurrentUser();

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
              // Navigation will automatically redirect to login
            } catch (error) {
              Alert.alert('Error', 'Failed to logout. Please try again.');
            }
          },
        },
      ]
    );
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* User Info */}
      <Card variant="elevated" style={styles.userCard}>
        <View style={styles.avatarContainer}>
          <Text style={styles.avatarEmoji}>👤</Text>
        </View>
        <Text style={styles.userName}>
          {currentUser?.displayName || 'Guest User'}
        </Text>
        <Text style={styles.userEmail}>
          {currentUser?.email || 'Not signed in'}
        </Text>
        <View style={styles.membershipBadge}>
          <Text style={styles.membershipText}>
            {isSubscribed ? '⭐ Premium Member' : 'Free Member'}
          </Text>
        </View>
      </Card>

      {/* Subscription Status */}
      <TouchableOpacity
        style={styles.menuItem}
        onPress={() => navigation.navigate('SubscriptionStatus' as never)}
      >
        <View style={styles.menuItemLeft}>
          <Text style={styles.menuIcon}>📊</Text>
          <Text style={styles.menuText}>Subscription Status</Text>
        </View>
        <Text style={styles.menuArrow}>›</Text>
      </TouchableOpacity>

      {/* Manage Subscription */}
      {customerInfo?.managementURL && (
        <TouchableOpacity
          style={styles.menuItem}
          onPress={() => {
            // Open management URL
            // We'll use Linking in production
          }}
        >
          <View style={styles.menuItemLeft}>
            <Text style={styles.menuIcon}>🔄</Text>
            <Text style={styles.menuText}>Manage Subscription</Text>
          </View>
          <Text style={styles.menuArrow}>›</Text>
        </TouchableOpacity>
      )}

      {/* Account Management */}
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionHeaderText}>Account</Text>
      </View>

      <TouchableOpacity style={styles.menuItem}>
        <View style={styles.menuItemLeft}>
          <Text style={styles.menuIcon}>👤</Text>
          <Text style={styles.menuText}>Edit Profile</Text>
        </View>
        <Text style={styles.menuArrow}>›</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.menuItem}>
        <View style={styles.menuItemLeft}>
          <Text style={styles.menuIcon}>🔒</Text>
          <Text style={styles.menuText}>Privacy Settings</Text>
        </View>
        <Text style={styles.menuArrow}>›</Text>
      </TouchableOpacity>

      {/* Support */}
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionHeaderText}>Support</Text>
      </View>

      <TouchableOpacity style={styles.menuItem}>
        <View style={styles.menuItemLeft}>
          <Text style={styles.menuIcon}>❓</Text>
          <Text style={styles.menuText}>Help Center</Text>
        </View>
        <Text style={styles.menuArrow}>›</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.menuItem}>
        <View style={styles.menuItemLeft}>
          <Text style={styles.menuIcon}>📧</Text>
          <Text style={styles.menuText}>Contact Support</Text>
        </View>
        <Text style={styles.menuArrow}>›</Text>
      </TouchableOpacity>

      {/* Logout */}
      <TouchableOpacity style={[styles.menuItem, styles.logoutItem]} onPress={handleLogout}>
        <View style={styles.menuItemLeft}>
          <Text style={styles.menuIcon}>🚪</Text>
          <Text style={[styles.menuText, styles.logoutText]}>Logout</Text>
        </View>
        <Text style={styles.menuArrow}>›</Text>
      </TouchableOpacity>

      {/* Version Info */}
      <Text style={styles.versionText}>Version 1.0.0</Text>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
    paddingHorizontal: spacing.lg,
  },
  userCard: {
    marginTop: spacing.lg,
    marginBottom: spacing.md,
    alignItems: 'center',
    padding: spacing.xl,
  },
  avatarContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.background.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  avatarEmoji: {
    fontSize: 40,
  },
  userName: {
    ...typography.h3,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  userEmail: {
    ...typography.body,
    color: colors.text.secondary,
    marginBottom: spacing.md,
  },
  membershipBadge: {
    backgroundColor: colors.primary.main,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 20,
  },
  membershipText: {
    ...typography.bodySmall,
    color: colors.text.inverse,
    fontWeight: '600',
  },
  menuItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.md,
    backgroundColor: colors.background.secondary,
    borderRadius: 12,
    marginBottom: spacing.sm,
    borderWidth: 1,
    borderColor: colors.border.light,
  },
  menuItemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  menuIcon: {
    fontSize: 20,
    marginRight: spacing.md,
  },
  menuText: {
    ...typography.body,
    color: colors.text.primary,
  },
  menuArrow: {
    fontSize: 20,
    color: colors.text.tertiary,
  },
  logoutItem: {
    borderColor: colors.status.error,
  },
  logoutText: {
    color: colors.status.error,
  },
  sectionHeader: {
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.sm,
  },
  sectionHeaderText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  versionText: {
    ...typography.caption,
    color: colors.text.tertiary,
    textAlign: 'center',
    paddingVertical: spacing.xl,
  },
});
```

---

## Phase 3: Splash Screen & App Initialization

### The Target

Create a splash screen that handles app initialization and state loading.

### The Concept

The splash screen is the first thing users see. It should:
1. Show a branded loading experience
2. Initialize RevenueCat and other services
3. Determine the user's authentication and subscription state
4. Navigate to the appropriate screen

### Implementation

**File: `FitTrackPro/frontend/src/screens/SplashScreen.tsx`**

```typescript
import React, { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ActivityIndicator,
  Animated,
  Easing,
} from 'react-native';
import { useSubscription } from '../context/SubscriptionContext';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing } from '../theme/spacing';

/**
 * Splash Screen
 * 
 * The initial loading screen that handles app initialization.
 * 
 * 🚀 This screen:
 * 1. Shows a branded loading experience
 * 2. Initializes RevenueCat (handled by SubscriptionContext)
 * 3. Waits for initialization to complete
 * 4. Automatically navigates to the correct screen
 * 
 * The navigation is handled by the RootNavigator based on state.
 */

export const SplashScreen: React.FC = () => {
  const { isLoading, error } = useSubscription();
  
  // Animated values for a nice loading effect
  const fadeAnim = new Animated.Value(0);
  const scaleAnim = new Animated.Value(0.8);

  useEffect(() => {
    // Fade in the content
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        easing: Easing.ease,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        friction: 8,
        tension: 40,
        useNativeDriver: true,
      }),
    ]).start();
  }, [fadeAnim, scaleAnim]);

  // If there's an error, show it but still try to load
  if (error) {
    return (
      <View style={styles.container}>
        <Animated.View
          style={[
            styles.content,
            {
              opacity: fadeAnim,
              transform: [{ scale: scaleAnim }],
            },
          ]}
        >
          <Text style={styles.emoji}>💪</Text>
          <Text style={styles.title}>FitTrack Pro</Text>
          <Text style={styles.subtitle}>Your fitness journey starts here</Text>
          <ActivityIndicator 
            size="large" 
            color={colors.primary.main}
            style={styles.loader}
          />
          <Text style={styles.errorText}>
            {error}
          </Text>
          <Text style={styles.retryText}>
            Retrying...
          </Text>
        </Animated.View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Animated.View
        style={[
          styles.content,
          {
            opacity: fadeAnim,
            transform: [{ scale: scaleAnim }],
          },
        ]}
      >
        <View style={styles.logoContainer}>
          <Text style={styles.emoji}>💪</Text>
        </View>
        <Text style={styles.title}>FitTrack Pro</Text>
        <Text style={styles.subtitle}>Your fitness journey starts here</Text>
        <ActivityIndicator 
          size="large" 
          color={colors.primary.main}
          style={styles.loader}
        />
        <Text style={styles.loadingText}>Loading your fitness experience...</Text>
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    alignItems: 'center',
    padding: spacing.xl,
  },
  logoContainer: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: colors.primary.main,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.xl,
    shadowColor: colors.primary.main,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.3,
    shadowRadius: 16,
    elevation: 10,
  },
  emoji: {
    fontSize: 60,
  },
  title: {
    ...typography.h1,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  subtitle: {
    ...typography.body,
    color: colors.text.secondary,
    marginBottom: spacing.xxl,
  },
  loader: {
    marginBottom: spacing.lg,
  },
  loadingText: {
    ...typography.bodySmall,
    color: colors.text.tertiary,
  },
  errorText: {
    ...typography.bodySmall,
    color: colors.status.error,
    textAlign: 'center',
    marginBottom: spacing.sm,
  },
  retryText: {
    ...typography.caption,
    color: colors.text.tertiary,
  },
});
```

---

## Phase 4: Production Configuration

### The Target

Configure the app for production release on iOS and Android.

### The Concept

Before releasing to the app stores, we need to:
1. Configure app icons and splash screens
2. Set up production API keys
3. Configure build settings
4. Test thoroughly

### Implementation

#### Step 4.1: iOS Configuration

**File: `FitTrackPro/frontend/ios/FitTrackPro/Info.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>FitTrack Pro</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    
    <!-- App Store Configuration -->
    <key>SKAdNetworkItems</key>
    <array>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>YOUR_SK_AD_NETWORK_ID</string>
        </dict>
    </array>
    
    <!-- Push Notifications -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
    
    <!-- User Activity Types for StoreKit -->
    <key>NSUserActivityTypes</key>
    <array>
        <string>com.yourcompany.fittrackpro.purchase</string>
    </array>
    
    <!-- URL Schemes -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>fittrackpro</string>
            </array>
        </dict>
    </array>
    
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    
    <!-- StoreKit Configuration for testing -->
    <key>SKStoreKitConfiguration</key>
    <dict>
        <key>FitTrackPro.storekit</key>
        <dict>
            <key>Products</key>
            <array>
                <string>com.yourcompany.fittrackpro.monthly</string>
                <string>com.yourcompany.fittrackpro.annual</string>
            </array>
        </dict>
    </dict>
    
    <!-- Privacy Permissions -->
    <key>NSHealthShareUsageDescription</key>
    <string>FitTrack Pro needs access to your health data to track workouts and nutrition.</string>
    
    <key>NSHealthUpdateUsageDescription</key>
    <string>FitTrack Pro needs to write workout data to your health records.</string>
    
    <key>NSCameraUsageDescription</key>
    <string>FitTrack Pro needs camera access to scan food barcodes for nutrition tracking.</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>FitTrack Pro needs photo access to save workout progress pictures.</string>
</dict>
</plist>
```

#### Step 4.2: Android Configuration

**File: `FitTrackPro/frontend/android/app/build.gradle`**

```gradle
apply plugin: "com.android.application"
apply plugin: "com.facebook.react"

project.ext.envConfigFiles = [
    debug: ".env.development",
    release: ".env.production",
]

apply from: project(':react-native-config').projectDir.getPath() + "/dotenv.gradle"

/**
 * This is the configuration block to customize your React Native Android app.
 * By default you don't need to apply any configuration, just uncomment the lines you need.
 */
android {
    ndkVersion rootProject.ext.ndkVersion

    compileSdkVersion rootProject.ext.compileSdkVersion

    namespace "com.yourcompany.fittrackpro"
    
    defaultConfig {
        applicationId "com.yourcompany.fittrackpro"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode 1
        versionName "1.0"
        
        // For Google Play Billing
        buildConfigField "String", "PLAY_STORE_BILLING_KEY", "\"YOUR_PLAY_STORE_BILLING_KEY\""
        
        // For RevenueCat
        manifestPlaceholders = [
            revenueCatApiKey: "${env.REVENUECAT_PUBLIC_API_KEY}",
        ]
    }
    
    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
        
        release {
            storeFile file('fittrackpro.keystore')
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
    
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
        }
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro"
        }
    }
}

dependencies {
    implementation("com.facebook.react:react-android")

    // Google Play Billing Library
    implementation 'com.android.billingclient:billing:6.0.1'
    implementation 'com.android.billingclient:billing-ktx:6.0.1'

    // RevenueCat dependencies
    implementation 'com.revenuecat.purchases:purchases:7.0.0'
    implementation 'com.revenuecat.purchases:purchases-hybrid-common:7.0.0'

    if (hermesEnabled.toBoolean()) {
        implementation("com.facebook.react:hermes-android")
    } else {
        implementation jscFlavor
    }
}

apply from: file("../../node_modules/@react-native-community/cli-platform-android/native_modules.gradle"); applyNativeModulesAppBuildGradle(project)
apply from: "../../node_modules/react-native-vector-icons/fonts.gradle"
```

**File: `FitTrackPro/frontend/android/app/src/main/AndroidManifest.xml`**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.yourcompany.fittrackpro">

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.COM.android.vending.BILLING" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />

    <application
        android:name=".MainApplication"
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:theme="@style/AppTheme"
        android:hardwareAccelerated="true"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|screenSize|smallestScreenSize|uiMode"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- Deep linking -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="fittrackpro" />
            </intent-filter>
        </activity>

        <!-- RevenueCat configuration -->
        <meta-data
            android:name="com.revenuecat.purchases.Purchases"
            android:value="${revenueCatApiKey}" />
    </application>
</manifest>
```

#### Step 4.3: Environment Configuration

**File: `FitTrackPro/frontend/.env.production`**

```bash
# RevenueCat Configuration
REVENUECAT_PUBLIC_API_KEY=app_production_1234567890

# Backend API Configuration
BACKEND_API_URL=https://api.fittrackpro.com/api
BACKEND_WEBHOOK_SECRET=wh_production_1234567890

# App Configuration
APP_BUNDLE_ID=com.yourcompany.fittrackpro
APP_PACKAGE_NAME=com.yourcompany.fittrackpro

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGS=false

# Analytics
MIXPANEL_TOKEN=prod_1234567890
AMPLITUDE_API_KEY=prod_1234567890
POSTHOG_API_KEY=prod_1234567890
```

---

## Phase 5: Final Verification & Testing

### The Target

Comprehensively test the entire application before production release.

### Implementation

#### Step 5.1: Test Checklist

Create a test checklist to ensure everything works:

**File: `FitTrackPro/TEST_CHECKLIST.md`**

```markdown
# FitTrack Pro Test Checklist

## RevenueCat Integration

### SDK Initialization
- [ ] App starts successfully
- [ ] No initialization errors
- [ ] Debug logs show properly
- [ ] Anonymous user ID is generated

### Offering Fetching
- [ ] Offerings load successfully
- [ ] Packages display with correct pricing
- [ ] Monthly and annual packages available
- [ ] Localized prices display correctly

### Purchase Flow
- [ ] Can select a package
- [ ] Purchase sheet appears
- [ ] Can complete purchase with sandbox
- [ ] Success state shows
- [ ] Entitlements are granted
- [ ] CustomerInfo updates correctly
- [ ] Error handling works for cancellations

### Restoration
- [ ] Restore button works
- [ ] Existing purchases are found
- [ ] No purchases message shows when appropriate
- [ ] Entitlements are restored correctly

## Subscription Management

### State Management
- [ ] Subscription state persists across app restarts
- [ ] Real-time updates work
- [ ] Offline cache loads correctly
- [ ] State updates on purchase

### Feature Gating
- [ ] Premium features are locked for free users
- [ ] Premium features unlock after purchase
- [ ] Feature gating works across all screens
- [ ] Upgrade prompts show appropriately

### User Identity
- [ ] Can sign up
- [ ] Can sign in
- [ ] Can sign out
- [ ] Anonymous subscription transfers to account
- [ ] Subscription persists across devices

## Navigation

### Root Navigation
- [ ] Splash screen shows
- [ ] Login screen shows when not authenticated
- [ ] Paywall shows when not subscribed
- [ ] Main app shows when subscribed

### Main Navigation
- [ ] All tabs work
- [ ] Can navigate to subscription status
- [ ] Back navigation works
- [ ] Deep linking works

## Backend Integration

### Webhooks
- [ ] Webhook endpoint receives events
- [ ] Signature verification works
- [ ] All event types processed
- [ ] Database updates correctly
- [ ] Analytics events track

### API
- [ ] Health check works
- [ ] Error handling works
- [ ] Rate limiting works
- [ ] CORS configured

## Performance

### Loading Times
- [ ] App launches in < 2 seconds
- [ ] Paywall loads in < 1 second
- [ ] Main app loads in < 1 second
- [ ] Purchases process in < 3 seconds

### Memory
- [ ] No memory leaks
- [ ] Images load efficiently
- [ ] Lists scroll smoothly

## Security

### Data Protection
- [ ] API keys not exposed
- [ ] Webhook signatures verified
- [ ] JWT tokens validate
- [ ] Sensitive data encrypted

### User Data
- [ ] User data properly secured
- [ ] Logout clears sensitive data
- [ ] Session management works

## Platform Specific

### iOS
- [ ] Build succeeds
- [ ] App Store Connect configuration correct
- [ ] StoreKit configuration works
- [ ] Sandbox testing works
- [ ] Bundle ID matches

### Android
- [ ] Build succeeds
- [ ] Google Play Console configuration correct
- [ ] Billing permission declared
- [ ] Internal testing works
- [ ] Package name matches

## User Experience

### UI/UX
- [ ] Colors and typography consistent
- [ ] Animations smooth
- [ ] Loading states show
- [ ] Error messages are helpful
- [ ] Accessibility works

### Responsive
- [ ] Works on different screen sizes
- [ ] Works in portrait and landscape
- [ ] Safe area handling works

## Analytics

### Events
- [ ] Purchase events tracked
- [ ] Subscription events tracked
- [ ] User events tracked
- [ ] Error events tracked

### Metrics
- [ ] MRR calculation works
- [ ] ARPU calculation works
- [ ] Conversion rate tracks
- [ ] Churn rate tracks
```

#### Step 5.2: Performance Monitoring

**File: `FitTrackPro/frontend/src/utils/performance.ts`**

```typescript
/**
 * Performance Monitoring Utilities
 * 
 * Tracks app performance metrics and logs them.
 * Helps identify bottlenecks and optimization opportunities.
 * 
 * 📊 This is crucial for production monitoring.
 */

import { PerformanceObserver, performance } from 'react-native-performance';

class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private measurements: Record<string, number[]> = {};

  private constructor() {
    this.setupPerformanceObserver();
  }

  public static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  private setupPerformanceObserver(): void {
    if (typeof PerformanceObserver !== 'undefined') {
      const observer = new PerformanceObserver((list) => {
        const entries = list.getEntries();
        for (const entry of entries) {
          console.log(`[Performance] ${entry.name}: ${entry.duration}ms`);
          
          // Track measurements
          if (!this.measurements[entry.name]) {
            this.measurements[entry.name] = [];
          }
          this.measurements[entry.name].push(entry.duration);
          
          // Keep only last 100 measurements
          if (this.measurements[entry.name].length > 100) {
            this.measurements[entry.name].shift();
          }
        }
      });

      observer.observe({ entryTypes: ['navigation', 'measure'] });
    }
  }

  /**
   * Start a performance measurement
   */
  public startMeasure(name: string): void {
    performance.mark(`${name}_start`);
  }

  /**
   * End a performance measurement
   */
  public endMeasure(name: string): void {
    performance.mark(`${name}_end`);
    performance.measure(name, `${name}_start`, `${name}_end`);
    performance.clearMarks(`${name}_start`);
    performance.clearMarks(`${name}_end`);
  }

  /**
   * Get metrics for a measurement
   */
  public getMetrics(name: string): {
    count: number;
    avg: number;
    max: number;
    min: number;
    p95: number;
  } | null {
    const values = this.measurements[name];
    if (!values || values.length === 0) return null;

    const sorted = [...values].sort((a, b) => a - b);
    const sum = values.reduce((a, b) => a + b, 0);
    const p95Index = Math.floor(sorted.length * 0.95);

    return {
      count: values.length,
      avg: sum / values.length,
      max: sorted[sorted.length - 1],
      min: sorted[0],
      p95: sorted[p95Index] || sorted[sorted.length - 1],
    };
  }

  /**
   * Log all metrics
   */
  public logMetrics(): void {
    console.log('[Performance] 📊 Metrics Summary:');
    for (const [name, _] of Object.entries(this.measurements)) {
      const metrics = this.getMetrics(name);
      if (metrics) {
        console.log(`  ${name}: avg=${metrics.avg.toFixed(2)}ms, p95=${metrics.p95.toFixed(2)}ms`);
      }
    }
  }
}

export const performanceMonitor = PerformanceMonitor.getInstance();
export default performanceMonitor;
```

---

## Final Application Structure

Here's the complete structure of your finished application:

```
FitTrackPro/
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   │   ├── health.ts
│   │   │   └── webhook.ts
│   │   ├── services/
│   │   │   ├── analyticsService.ts
│   │   │   ├── databaseService.ts
│   │   │   ├── eventProcessor.ts
│   │   │   ├── experimentService.ts
│   │   │   ├── monitoringService.ts
│   │   │   └── notificationService.ts
│   │   ├── types/
│   │   │   └── revenueCat.ts
│   │   ├── utils/
│   │   │   ├── logger.ts
│   │   │   ├── security.ts
│   │   │   └── webhookVerifier.ts
│   │   ├── middleware/
│   │   │   ├── errorHandler.ts
│   │   │   └── rateLimiter.ts
│   │   └── index.ts
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
├── frontend/
│   ├── android/
│   │   ├── app/
│   │   │   ├── src/
│   │   │   │   └── main/
│   │   │   │       ├── AndroidManifest.xml
│   │   │   │       └── java/
│   │   │   │           └── com/
│   │   │   │               └── yourcompany/
│   │   │   │                   └── fittrackpro/
│   │   │   │                       └── MainApplication.java
│   │   │   └── build.gradle
│   │   └── gradle/
│   ├── ios/
│   │   ├── FitTrackPro/
│   │   │   ├── AppDelegate.mm
│   │   │   ├── Info.plist
│   │   │   └── FitTrackPro.entitlements
│   │   └── Podfile
│   ├── src/
│   │   ├── components/
│   │   │   ├── common/
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Card.tsx
│   │   │   │   └── Badge.tsx
│   │   │   ├── guards/
│   │   │   │   ├── RequireEntitlement.tsx
│   │   │   │   └── EntitlementGate.tsx
│   │   │   └── paywall/
│   │   │       └── PurchaseFlow.tsx
│   │   ├── context/
│   │   │   └── SubscriptionContext.tsx
│   │   ├── hooks/
│   │   │   ├── useRevenueCat.ts
│   │   │   └── useAppState.ts
│   │   ├── navigation/
│   │   │   ├── RootNavigator.tsx
│   │   │   ├── MainNavigator.tsx
│   │   │   └── types.ts
│   │   ├── screens/
│   │   │   ├── SplashScreen.tsx
│   │   │   ├── LoginScreen.tsx
│   │   │   ├── PaywallScreen.tsx
│   │   │   ├── SubscriptionStatusScreen.tsx
│   │   │   └── main/
│   │   │       ├── HomeScreen.tsx
│   │   │       ├── WorkoutsScreen.tsx
│   │   │       ├── NutritionScreen.tsx
│   │   │       ├── TrainerScreen.tsx
│   │   │       └── ProfileScreen.tsx
│   │   ├── services/
│   │   │   ├── RevenueCatService.ts
│   │   │   ├── AuthService.ts
│   │   │   └── AnalyticsService.ts
│   │   ├── theme/
│   │   │   ├── colors.ts
│   │   │   ├── typography.ts
│   │   │   ├── spacing.ts
│   │   │   └── index.ts
│   │   ├── types/
│   │   │   └── revenueCat.ts
│   │   ├── utils/
│   │   │   ├── errorUtils.ts
│   │   │   ├── performance.ts
│   │   │   └── validators.ts
│   │   └── config/
│   │       └── env.ts
│   ├── .env.example
│   ├── .env.production
│   ├── app.json
│   ├── package.json
│   ├── tsconfig.json
│   └── metro.config.js
├── TEST_CHECKLIST.md
└── README.md
```

---

## Verification

### Final Test Commands

```bash
# Clean build iOS
cd frontend/ios
pod deintegrate
pod install
cd ..

# Clean build Android
cd frontend/android
./gradlew clean
cd ..

# Start Metro bundler
npx react-native start --reset-cache

# Run iOS
npx react-native run-ios --configuration Release

# Run Android
npx react-native run-android --variant release

# Build release APK
cd android
./gradlew assembleRelease

# Build iOS archive
cd ../ios
xcodebuild -workspace FitTrackPro.xcworkspace -scheme FitTrackPro -configuration Release archive

# Run backend
cd ../backend
npm run build
npm start
```

---

## Module Summary

🎉 **Congratulations!** You've completed the entire RevenueCat tutorial series. Here's what you've built:

### Full Application Features

✅ **RevenueCat Integration**
- Cross-platform SDK configuration
- Entitlement management
- Offering and package management

✅ **Subscription Management**
- Real-time state management
- Offline support and caching
- Premium feature gating

✅ **Purchase Flow**
- Beautiful paywall UI
- Complete purchase handling
- Error recovery and retry logic

✅ **User Identity**
- Anonymous and authenticated users
- Account migration
- Cross-device synchronization

✅ **Backend Infrastructure**
- Webhook event processing
- Analytics integration
- Churn reduction strategies
- A/B testing with Experiments

✅ **Production Ready**
- Performance monitoring
- Error handling
- Security best practices
- App store configuration

### What You've Learned

You now have a comprehensive understanding of building subscription-based mobile applications with RevenueCat:

1. **Architecture**: How to structure a subscription app
2. **Implementation**: How to integrate RevenueCat SDK
3. **State Management**: How to handle subscription state
4. **User Identity**: How to manage users and subscriptions
5. **Backend Integration**: How to process subscription events
6. **Analytics**: How to track revenue and user metrics
7. **Optimization**: How to reduce churn and improve conversion
8. **Production**: How to build and deploy to app stores

### Next Steps

Now that you've completed the series, here are some suggestions for continuing your journey:

1. **Add More Features**: Expand the app with additional premium features
2. **Implement A/B Tests**: Run experiments to optimize your paywall
3. **Add Social Features**: User profiles, sharing, and community
4. **Integrate with Wearables**: Apple Watch, Wear OS integration
5. **Build a Web Version**: React Native Web or separate web app
6. **Scale Your Backend**: Containerization, load balancing, monitoring

### Final Thoughts

Building a subscription-based mobile app is complex, but you now have the tools and knowledge to do it effectively. RevenueCat simplifies the technical complexity, but the real success comes from understanding your users and continuously optimizing your monetization strategy.

Remember:
- **Start simple** and iterate based on data
- **Listen to your users** and solve their problems
- **Test everything** and measure the results
- **Keep learning** and stay up to date with best practices

Thank you for following along with this comprehensive series. Now go build something amazing! 💪

---

**[GENERATED: Part 5: Integrating RevenueCat with React Native]**

**[COMPLETED: Entire RevenueCat Tutorial Series]**

---

## Course Completion Certificate

You've successfully completed:

# Master RevenueCat: In-App Subscriptions & Monetization

### Completion Date: August 4, 2026

### Skills Achieved:
- ✅ RevenueCat SDK Integration
- ✅ Subscription State Management
- ✅ Premium Feature Gating
- ✅ Webhook Implementation
- ✅ Analytics Integration
- ✅ Churn Reduction Strategies
- ✅ A/B Testing with Experiments
- ✅ Production Deployment

### Project Completed:
FitTrack Pro - A complete subscription-based fitness application with:
- iOS and Android support
- Monthly and annual subscriptions
- Premium feature gating
- User authentication
- Real-time subscription updates
- Backend webhook processing
- Analytics tracking
- Production-ready architecture

---

*End of Tutorial Series*
