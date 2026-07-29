# Part 1: Foundations & Environment Architecture
## Phase 3: Navigation & Screen Management

Welcome to the final phase of Part 1! Navigation is the backbone of any mobile app—it's how users move between screens and interact with your application's features. In this phase, we'll build a complete navigation system for TaskFlow that's production-ready, type-safe, and handles all the edge cases your users will encounter.

---

## Target 1: Understanding React Navigation

**The Target:** Master React Navigation's architecture and capabilities.

**The Concept:** Think of navigation as a stack of cards. When you open a new screen, you place a new card on top. When you go back, you remove the top card. Different navigation patterns—stack, tab, drawer—are just different ways of organizing these cards.

### Installation & Setup

First, let's install all the navigation dependencies:

```bash
# Core navigation packages
npx expo install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs @react-navigation/drawer

# Dependencies
npx expo install react-native-screens react-native-safe-area-context
npx expo install react-native-gesture-handler react-native-reanimated
npx expo install react-native-drawer-layout

# TypeScript types
npm install -D @types/react-navigation @types/react-native-screens
```

### Understanding Navigation Types

```typescript
// src/navigation/types.ts
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { DrawerNavigationProp } from '@react-navigation/drawer';
import { RouteProp } from '@react-navigation/native';

/**
 * Navigation Types - Type-safe navigation throughout your app
 * 
 * This ensures you can only navigate to screens that exist
 * and with the correct parameters.
 */

// Define all your screen parameters
export type RootStackParamList = {
  // Auth screens
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  
  // Main app screens
  MainTabs: undefined;
  TaskDetail: { taskId: string };
  TaskCreate: undefined;
  TaskEdit: { taskId: string };
  Profile: undefined;
  Settings: undefined;
  
  // Modal screens
  TaskFilter: undefined;
  UserSearch: undefined;
  
  // Drawer screens
  Drawer: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Tasks: undefined;
  AddTask: undefined;
  Notifications: undefined;
  Profile: undefined;
};

export type DrawerParamList = {
  MainTabs: undefined;
  Settings: undefined;
  Help: undefined;
  About: undefined;
  Logout: undefined;
};

// Type-safe navigation hooks
export type RootStackNavigationProp<T extends keyof RootStackParamList> = 
  NativeStackNavigationProp<RootStackParamList, T>;

export type MainTabNavigationProp<T extends keyof MainTabParamList> = 
  BottomTabNavigationProp<MainTabParamList, T>;

export type DrawerNavigationProp<T extends keyof DrawerParamList> = 
  DrawerNavigationProp<DrawerParamList, T>;

// Type-safe route props
export type RootStackRouteProp<T extends keyof RootStackParamList> = 
  RouteProp<RootStackParamList, T>;

export type MainTabRouteProp<T extends keyof MainTabParamList> = 
  RouteProp<MainTabParamList, T>;

// Navigation props for screens
export type ScreenProps<T extends keyof RootStackParamList> = {
  navigation: RootStackNavigationProp<T>;
  route: RootStackRouteProp<T>;
};
```

---

## Target 2: Implementing Stack Navigation

**The Target:** Build a robust stack navigation system for hierarchical screen flows.

**The Concept:** Stack navigation is like a browser's history—each new screen pushes onto the stack, and going back pops it off. This is perfect for drill-down interfaces where users need to navigate from a list to detail views.

### Root Stack Navigator

```typescript
// src/navigation/RootStackNavigator.tsx
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Platform, View, Text, TouchableOpacity } from 'react-native';

// Import screens (we'll build these)
import { LoginScreen } from '../screens/auth/LoginScreen';
import { RegisterScreen } from '../screens/auth/RegisterScreen';
import { ForgotPasswordScreen } from '../screens/auth/ForgotPasswordScreen';
import { TaskDetailScreen } from '../screens/tasks/TaskDetailScreen';
import { TaskCreateScreen } from '../screens/tasks/TaskCreateScreen';
import { TaskEditScreen } from '../screens/tasks/TaskEditScreen';
import { UserSearchScreen } from '../screens/modals/UserSearchScreen';
import { TaskFilterScreen } from '../screens/modals/TaskFilterScreen';

// Import main tab navigator
import { MainTabNavigator } from './MainTabNavigator';

// Import types
import { RootStackParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();

/**
 * RootStackNavigator - The main navigation container
 * 
 * This handles all screen transitions in the app, including
 * auth flows, main app screens, and modals.
 */
export const RootStackNavigator: React.FC = () => {
  const insets = useSafeAreaInsets();

  // Custom header back button
  const CustomBackButton = ({ onPress }: { onPress: () => void }) => (
    <TouchableOpacity 
      onPress={onPress}
      style={{
        paddingHorizontal: 12,
        paddingVertical: 8,
        marginLeft: 8,
      }}
    >
      <Text style={{ fontSize: 24, color: '#3498db' }}>‹</Text>
    </TouchableOpacity>
  );

  return (
    <Stack.Navigator
      initialRouteName="Login"
      screenOptions={{
        headerStyle: {
          backgroundColor: '#ffffff',
        },
        headerTitleStyle: {
          fontSize: 18,
          fontWeight: '600',
          color: '#2c3e50',
        },
        headerTintColor: '#3498db',
        headerBackTitleVisible: false,
        headerShadowVisible: false,
        contentStyle: {
          backgroundColor: '#f8f9fa',
        },
        animation: Platform.OS === 'ios' ? 'default' : 'fade_from_bottom',
        presentation: 'card',
      }}
    >
      {/* Auth Screens - No header */}
      <Stack.Screen 
        name="Login" 
        component={LoginScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="Register" 
        component={RegisterScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="ForgotPassword" 
        component={ForgotPasswordScreen}
        options={{
          headerShown: false,
        }}
      />

      {/* Main App Screens */}
      <Stack.Screen 
        name="MainTabs" 
        component={MainTabNavigator}
        options={{
          headerShown: false,
        }}
      />

      {/* Task Screens */}
      <Stack.Screen 
        name="TaskDetail" 
        component={TaskDetailScreen}
        options={({ navigation }) => ({
          title: 'Task Details',
          headerLeft: () => (
            <CustomBackButton onPress={() => navigation.goBack()} />
          ),
          headerRight: () => (
            <TouchableOpacity 
              onPress={() => console.log('Edit task')}
              style={{ paddingHorizontal: 12 }}
            >
              <Text style={{ color: '#3498db', fontSize: 16 }}>Edit</Text>
            </TouchableOpacity>
          ),
        })}
      />
      
      <Stack.Screen 
        name="TaskCreate" 
        component={TaskCreateScreen}
        options={{
          title: 'Create Task',
          presentation: 'modal',
        }}
      />
      
      <Stack.Screen 
        name="TaskEdit" 
        component={TaskEditScreen}
        options={{
          title: 'Edit Task',
        }}
      />

      {/* Modal Screens */}
      <Stack.Screen 
        name="UserSearch" 
        component={UserSearchScreen}
        options={{
          title: 'Search Users',
          presentation: 'modal',
        }}
      />
      
      <Stack.Screen 
        name="TaskFilter" 
        component={TaskFilterScreen}
        options={{
          title: 'Filter Tasks',
          presentation: 'modal',
        }}
      />
    </Stack.Navigator>
  );
};
```

### Login Screen with Navigation

```typescript
// src/screens/auth/LoginScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { ScreenProps } from '../../navigation/types';

type LoginScreenProps = ScreenProps<'Login'>;

export const LoginScreen: React.FC<LoginScreenProps> = ({ navigation }) => {
  const insets = useSafeAreaInsets();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const handleLogin = async () => {
    // Validate inputs
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    if (!email.includes('@')) {
      Alert.alert('Error', 'Please enter a valid email address');
      return;
    }

    // Simulate login
    setLoading(true);
    try {
      // TODO: Replace with actual API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Navigate to main app on success
      navigation.replace('MainTabs');
    } catch (error) {
      Alert.alert('Login Failed', 'Invalid email or password');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={[styles.container, { paddingTop: insets.top }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 20}
    >
      <View style={styles.content}>
        {/* Logo/Header */}
        <View style={styles.header}>
          <Text style={styles.logo}>✓</Text>
          <Text style={styles.title}>TaskFlow</Text>
          <Text style={styles.subtitle}>Sign in to continue</Text>
        </View>

        {/* Form */}
        <View style={styles.form}>
          <View style={styles.inputContainer}>
            <Text style={styles.label}>Email Address</Text>
            <TextInput
              style={styles.input}
              placeholder="you@example.com"
              value={email}
              onChangeText={setEmail}
              autoCapitalize="none"
              keyboardType="email-address"
              autoComplete="email"
              placeholderTextColor="#95a5a6"
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.label}>Password</Text>
            <View style={styles.passwordContainer}>
              <TextInput
                style={[styles.input, styles.passwordInput]}
                placeholder="Enter your password"
                value={password}
                onChangeText={setPassword}
                secureTextEntry={!showPassword}
                autoComplete="password"
                placeholderTextColor="#95a5a6"
              />
              <TouchableOpacity
                style={styles.eyeButton}
                onPress={() => setShowPassword(!showPassword)}
              >
                <Text style={styles.eyeText}>
                  {showPassword ? '👁️' : '👁️‍🗨️'}
                </Text>
              </TouchableOpacity>
            </View>
          </View>

          <TouchableOpacity
            style={styles.forgotPassword}
            onPress={() => navigation.navigate('ForgotPassword')}
          >
            <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.loginButton, loading && styles.loginButtonDisabled]}
            onPress={handleLogin}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#ffffff" />
            ) : (
              <Text style={styles.loginButtonText}>Sign In</Text>
            )}
          </TouchableOpacity>

          <View style={styles.registerContainer}>
            <Text style={styles.registerText}>Don't have an account? </Text>
            <TouchableOpacity onPress={() => navigation.navigate('Register')}>
              <Text style={styles.registerLink}>Sign Up</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <Text style={styles.footerText}>
            By signing in, you agree to our Terms of Service
          </Text>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
    justifyContent: 'space-between',
  },
  header: {
    alignItems: 'center',
    marginTop: 60,
    marginBottom: 40,
  },
  logo: {
    fontSize: 48,
    color: '#3498db',
    marginBottom: 12,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#7f8c8d',
  },
  form: {
    flex: 1,
    justifyContent: 'center',
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
    color: '#2c3e50',
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  passwordContainer: {
    position: 'relative',
  },
  passwordInput: {
    paddingRight: 50,
  },
  eyeButton: {
    position: 'absolute',
    right: 16,
    top: 14,
  },
  eyeText: {
    fontSize: 20,
  },
  forgotPassword: {
    alignSelf: 'flex-end',
    marginBottom: 24,
  },
  forgotPasswordText: {
    color: '#3498db',
    fontSize: 14,
  },
  loginButton: {
    backgroundColor: '#3498db',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    marginBottom: 16,
  },
  loginButtonDisabled: {
    opacity: 0.7,
  },
  loginButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  registerContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
  },
  registerText: {
    color: '#7f8c8d',
    fontSize: 14,
  },
  registerLink: {
    color: '#3498db',
    fontSize: 14,
    fontWeight: '600',
  },
  footer: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#95a5a6',
    textAlign: 'center',
  },
});
```

---

## Target 3: Tab Navigation - The Primary Interface

**The Target:** Create a bottom tab navigation system for the main app sections.

**The Concept:** Bottom tabs are the primary navigation method for most apps. They provide quick access to the most important sections, always visible at the bottom of the screen.

### Main Tab Navigator

```typescript
// src/navigation/MainTabNavigator.tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Platform, View, Text, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// Import screens
import { HomeScreen } from '../screens/HomeScreen';
import { TasksScreen } from '../screens/tasks/TasksScreen';
import { ProfileScreen } from '../screens/profile/ProfileScreen';
import { NotificationsScreen } from '../screens/NotificationsScreen';
import { AddTaskButton } from '../components/AddTaskButton';

// Import types
import { MainTabParamList } from './types';

const Tab = createBottomTabNavigator<MainTabParamList>();

/**
 * Custom Tab Bar Icon
 */
const TabIcon = ({ 
  focused, 
  label, 
  icon 
}: { 
  focused: boolean; 
  label: string; 
  icon: string;
}) => (
  <View style={styles.tabIconContainer}>
    <Text style={[styles.tabIcon, focused && styles.tabIconFocused]}>
      {icon}
    </Text>
    <Text style={[styles.tabLabel, focused && styles.tabLabelFocused]}>
      {label}
    </Text>
  </View>
);

/**
 * MainTabNavigator - Primary navigation for the app
 * 
 * This provides the main bottom tabs that users interact with
 * most frequently. Each tab represents a major section of the app.
 */
export const MainTabNavigator: React.FC = () => {
  const insets = useSafeAreaInsets();

  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: '#ffffff',
          borderTopWidth: 1,
          borderTopColor: '#f0f0f0',
          height: Platform.OS === 'ios' ? 88 : 68,
          paddingBottom: Platform.OS === 'ios' ? 20 : 8,
          paddingTop: 8,
        },
        tabBarActiveTintColor: '#3498db',
        tabBarInactiveTintColor: '#95a5a6',
        tabBarShowLabel: false,
      }}
    >
      {/* Home Tab */}
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon 
              focused={focused} 
              label="Home" 
              icon={focused ? '🏠' : '🏠'} 
            />
          ),
        }}
      />

      {/* Tasks Tab */}
      <Tab.Screen
        name="Tasks"
        component={TasksScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon 
              focused={focused} 
              label="Tasks" 
              icon={focused ? '📋' : '📋'} 
            />
          ),
        }}
      />

      {/* Add Task Button */}
      <Tab.Screen
        name="AddTask"
        component={View as any} // Placeholder, will be handled by button
        options={{
          tabBarButton: () => <AddTaskButton />,
          tabBarIcon: () => null,
        }}
        listeners={{
          tabPress: (e) => {
            e.preventDefault();
            // Handle add task navigation
            console.log('Add task pressed');
          },
        }}
      />

      {/* Notifications Tab */}
      <Tab.Screen
        name="Notifications"
        component={NotificationsScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon 
              focused={focused} 
              label="Alerts" 
              icon={focused ? '🔔' : '🔔'} 
            />
          ),
          tabBarBadge: 3, // Show notification count
          tabBarBadgeStyle: {
            backgroundColor: '#e74c3c',
            color: '#ffffff',
            fontSize: 10,
            fontWeight: '600',
            paddingHorizontal: 4,
            minWidth: 18,
            height: 18,
          },
        }}
      />

      {/* Profile Tab */}
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabIcon 
              focused={focused} 
              label="Profile" 
              icon={focused ? '👤' : '👤'} 
            />
          ),
        }}
      />
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  tabIconContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  tabIcon: {
    fontSize: 24,
    opacity: 0.6,
  },
  tabIconFocused: {
    opacity: 1,
  },
  tabLabel: {
    fontSize: 10,
    color: '#95a5a6',
    marginTop: 2,
    fontWeight: '500',
  },
  tabLabelFocused: {
    color: '#3498db',
  },
});
```

### Floating Add Task Button

```typescript
// src/components/AddTaskButton.tsx
import React from 'react';
import { TouchableOpacity, StyleSheet, View, Text } from 'react-native';

interface AddTaskButtonProps {
  onPress?: () => void;
}

export const AddTaskButton: React.FC<AddTaskButtonProps> = ({ onPress }) => {
  const handlePress = () => {
    if (onPress) {
      onPress();
    } else {
      // Default navigation
      console.log('Add task button pressed');
    }
  };

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={handlePress}
      activeOpacity={0.8}
    >
      <View style={styles.button}>
        <Text style={styles.plusIcon}>+</Text>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 8,
  },
  button: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#3498db',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#3498db',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  plusIcon: {
    fontSize: 32,
    color: '#ffffff',
    fontWeight: '300',
    marginTop: -2,
  },
});
```

---

## Target 4: Drawer Navigation - Advanced Features

**The Target:** Implement a drawer navigation for secondary features and settings.

**The Concept:** The drawer slides in from the side and contains features that don't need constant access—settings, help, account management, and other secondary actions.

### Drawer Navigator

```typescript
// src/navigation/DrawerNavigator.tsx
import React from 'react';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { View, Text, StyleSheet, TouchableOpacity, Image, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// Import screens
import { SettingsScreen } from '../screens/SettingsScreen';
import { HelpScreen } from '../screens/HelpScreen';
import { AboutScreen } from '../screens/AboutScreen';

// Import main navigator
import { MainTabNavigator } from './MainTabNavigator';

// Import types
import { DrawerParamList } from './types';

const Drawer = createDrawerNavigator<DrawerParamList>();

/**
 * Custom Drawer Content
 */
const CustomDrawerContent = ({ navigation }: any) => {
  const insets = useSafeAreaInsets();
  const user = {
    name: 'John Doe',
    email: 'john@example.com',
    avatar: 'https://ui-avatars.com/api/?name=John+Doe&background=3498db&color=fff&size=128',
  };

  const menuItems = [
    { label: 'Home', icon: '🏠', route: 'MainTabs' },
    { label: 'Settings', icon: '⚙️', route: 'Settings' },
    { label: 'Help & Support', icon: '💬', route: 'Help' },
    { label: 'About', icon: 'ℹ️', route: 'About' },
    { label: 'Logout', icon: '🚪', route: null },
  ];

  const handleLogout = () => {
    // Handle logout
    console.log('Logging out...');
  };

  return (
    <View style={[styles.drawerContent, { paddingTop: insets.top }]}>
      {/* User Profile */}
      <View style={styles.userProfile}>
        <Image 
          source={{ uri: user.avatar }} 
          style={styles.avatar}
        />
        <Text style={styles.userName}>{user.name}</Text>
        <Text style={styles.userEmail}>{user.email}</Text>
      </View>

      {/* Menu Items */}
      <View style={styles.menuItems}>
        {menuItems.map((item) => (
          <TouchableOpacity
            key={item.label}
            style={styles.menuItem}
            onPress={() => {
              if (item.route) {
                navigation.navigate(item.route);
              } else {
                handleLogout();
              }
            }}
          >
            <Text style={styles.menuIcon}>{item.icon}</Text>
            <Text style={styles.menuLabel}>{item.label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Footer */}
      <View style={styles.drawerFooter}>
        <Text style={styles.versionText}>Version 1.0.0</Text>
      </View>
    </View>
  );
};

/**
 * DrawerNavigator - Side drawer for secondary navigation
 * 
 * This provides access to settings, help, and other secondary
 * features that don't need to be in the main tabs.
 */
export const DrawerNavigator: React.FC = () => {
  return (
    <Drawer.Navigator
      screenOptions={{
        headerShown: false,
        drawerStyle: {
          width: Platform.OS === 'ios' ? 320 : 280,
          backgroundColor: '#ffffff',
        },
        drawerType: Platform.OS === 'ios' ? 'slide' : 'front',
        drawerPosition: 'left',
        overlayColor: 'rgba(0, 0, 0, 0.4)',
        swipeEnabled: true,
        swipeEdgeWidth: 30,
      }}
      drawerContent={(props) => <CustomDrawerContent {...props} />}
    >
      <Drawer.Screen name="MainTabs" component={MainTabNavigator} />
      <Drawer.Screen name="Settings" component={SettingsScreen} />
      <Drawer.Screen name="Help" component={HelpScreen} />
      <Drawer.Screen name="About" component={AboutScreen} />
    </Drawer.Navigator>
  );
};

const styles = StyleSheet.create({
  drawerContent: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  userProfile: {
    padding: 20,
    paddingBottom: 24,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
    alignItems: 'center',
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    marginBottom: 12,
    borderWidth: 3,
    borderColor: '#3498db',
  },
  userName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
  },
  userEmail: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 4,
  },
  menuItems: {
    flex: 1,
    paddingVertical: 8,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    paddingHorizontal: 20,
  },
  menuIcon: {
    fontSize: 20,
    width: 28,
    textAlign: 'center',
  },
  menuLabel: {
    fontSize: 16,
    color: '#2c3e50',
    marginLeft: 12,
  },
  drawerFooter: {
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    alignItems: 'center',
  },
  versionText: {
    fontSize: 12,
    color: '#95a5a6',
  },
});
```

---

## Target 5: Navigation Helpers and Hooks

**The Target:** Create reusable navigation utilities and hooks.

**The Concept:** Centralizing navigation logic makes your code cleaner and easier to maintain. These helpers handle common navigation patterns.

### Navigation Service

```typescript
// src/navigation/NavigationService.ts
import { NavigationContainerRef } from '@react-navigation/native';
import { RootStackParamList } from './types';

/**
 * NavigationService - Navigation helper that works outside React components
 * 
 * This allows navigation from anywhere in your app, including
 * utility functions and state management layers.
 */
class NavigationService {
  private navigatorRef: NavigationContainerRef<RootStackParamList> | null = null;

  /**
   * Set the navigation ref (called by the NavigationContainer)
   */
  setTopLevelNavigator = (
    ref: NavigationContainerRef<RootStackParamList> | null
  ) => {
    this.navigatorRef = ref;
  };

  /**
   * Navigate to a screen
   */
  navigate = <T extends keyof RootStackParamList>(
    routeName: T,
    params?: RootStackParamList[T]
  ) => {
    if (this.navigatorRef?.isReady()) {
      // @ts-ignore - TypeScript limitation with params
      this.navigatorRef.navigate(routeName, params);
    }
  };

  /**
   * Go back to the previous screen
   */
  goBack = () => {
    if (this.navigatorRef?.canGoBack()) {
      this.navigatorRef.goBack();
    }
  };

  /**
   * Reset the navigation state (e.g., after login)
   */
  reset = (routeName: keyof RootStackParamList) => {
    if (this.navigatorRef?.isReady()) {
      this.navigatorRef.resetRoot({
        index: 0,
        routes: [{ name: routeName }],
      });
    }
  };

  /**
   * Replace the current screen
   */
  replace = <T extends keyof RootStackParamList>(
    routeName: T,
    params?: RootStackParamList[T]
  ) => {
    // Note: replace is not directly available on the ref
    // Use reset instead with the new route
    if (this.navigatorRef?.isReady()) {
      this.navigatorRef.resetRoot({
        index: 0,
        routes: [{ name: routeName, params }],
      });
    }
  };
}

export const navigationService = new NavigationService();
```

### Custom Navigation Hooks

```typescript
// src/hooks/useNavigation.ts
import { useNavigation, useRoute } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RouteProp } from '@react-navigation/native';
import { RootStackParamList } from '../navigation/types';

/**
 * Type-safe navigation hook for stack navigation
 */
export function useStackNavigation<T extends keyof RootStackParamList>() {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList, T>>();
  const route = useRoute<RouteProp<RootStackParamList, T>>();
  
  return { navigation, route };
}

/**
 * Hook to get the current route name
 */
export function useCurrentRoute() {
  const route = useRoute();
  return route.name;
}

/**
 * Hook to handle navigation params with type safety
 */
export function useRouteParams<T extends keyof RootStackParamList>() {
  const route = useRoute<RouteProp<RootStackParamList, T>>();
  return route.params;
}

/**
 * Hook to check if navigation is ready
 */
export function useNavigationReady() {
  const navigation = useNavigation();
  return navigation.isFocused();
}
```

---

## Target 6: Deep Linking Support

**The Target:** Implement deep linking for external navigation and push notifications.

**The Concept:** Deep linking allows users to open specific screens in your app from URLs or push notifications, creating a seamless user experience.

### Deep Linking Configuration

```typescript
// src/navigation/deepLinking.ts
import { Linking } from 'react-native';

export const DEEP_LINKING = {
  prefixes: [
    'taskflow://',
    'https://taskflow.app',
    'https://*.taskflow.app',
  ],
  
  config: {
    screens: {
      Login: 'auth/login',
      Register: 'auth/register',
      TaskDetail: 'tasks/:taskId',
      TaskCreate: 'tasks/create',
      UserSearch: 'search/users',
      MainTabs: {
        screens: {
          Home: 'home',
          Tasks: 'tasks',
          Profile: 'profile',
        },
      },
    },
  },

  /**
   * Handle incoming deep links
   */
  handleDeepLink: async (url: string) => {
    try {
      // Parse the URL
      const parsedUrl = new URL(url);
      const path = parsedUrl.pathname;
      
      console.log('Deep link received:', { url, path });
      
      // Extract parameters
      const params: Record<string, string> = {};
      parsedUrl.searchParams.forEach((value, key) => {
        params[key] = value;
      });
      
      // Navigate based on the path
      const routeMap: Record<string, { route: string; params?: any }> = {
        '/auth/login': { route: 'Login' },
        '/auth/register': { route: 'Register' },
        '/tasks/create': { route: 'TaskCreate' },
        '/search/users': { route: 'UserSearch' },
      };
      
      // Check for dynamic routes
      const taskDetailMatch = path.match(/^\/tasks\/(.+)$/);
      if (taskDetailMatch) {
        return {
          route: 'TaskDetail',
          params: { taskId: taskDetailMatch[1] },
        };
      }
      
      const mappedRoute = routeMap[path];
      if (mappedRoute) {
        return {
          route: mappedRoute.route,
          params: { ...mappedRoute.params, ...params },
        };
      }
      
      return { route: 'MainTabs' };
    } catch (error) {
      console.error('Error handling deep link:', error);
      return { route: 'MainTabs' };
    }
  },

  /**
   * Generate a deep link URL for a screen
   */
  generateDeepLink: (screen: string, params?: Record<string, any>) => {
    let url = `taskflow://${screen}`;
    
    if (params) {
      const searchParams = new URLSearchParams(params);
      url += `?${searchParams.toString()}`;
    }
    
    return url;
  },

  /**
   * Subscribe to deep link events
   */
  subscribeToDeepLinks: (callback: (url: string) => void) => {
    // Handle app opening from a deep link
    Linking.getInitialURL().then((url) => {
      if (url) {
        callback(url);
      }
    });
    
    // Handle deep links while app is running
    const subscription = Linking.addEventListener('url', ({ url }) => {
      callback(url);
    });
    
    return subscription;
  },
};
```

### Integrating Deep Links in App.tsx

```typescript
// App.tsx (Updated with deep linking)
import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { Platform } from 'react-native';
import { DEEP_LINKING } from './src/navigation/deepLinking';

import { SafeAreaWrapper } from './src/components/SafeAreaWrapper';
import { RootStackNavigator } from './src/navigation/RootStackNavigator';
import { navigationService } from './src/navigation/NavigationService';

// ... other imports

export default function App() {
  useEffect(() => {
    // Subscribe to deep links
    const subscription = DEEP_LINKING.subscribeToDeepLinks(async (url) => {
      const { route, params } = await DEEP_LINKING.handleDeepLink(url);
      
      // Navigate using the navigation service
      if (route) {
        navigationService.navigate(route as any, params);
      }
    });

    return () => {
      subscription.remove();
    };
  }, []);

  return (
    <SafeAreaProvider>
      <NavigationContainer
        ref={navigationService.setTopLevelNavigator}
        linking={DEEP_LINKING as any}
      >
        <SafeAreaWrapper>
          <RootStackNavigator />
        </SafeAreaWrapper>
        <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
```

---

## Target 7: Navigation State Persistence

**The Target:** Save and restore navigation state between app sessions.

**The Concept:** Users expect to return to exactly where they left off when they reopen your app. Navigation state persistence handles this automatically.

### Persistence Helper

```typescript
// src/navigation/persistence.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import { NavigationState } from '@react-navigation/native';

const NAVIGATION_STATE_KEY = '@TaskFlow/navigationState';

/**
 * Save the navigation state
 */
export const saveNavigationState = async (state: NavigationState) => {
  try {
    const stateString = JSON.stringify(state);
    await AsyncStorage.setItem(NAVIGATION_STATE_KEY, stateString);
  } catch (error) {
    console.error('Error saving navigation state:', error);
  }
};

/**
 * Load the navigation state
 */
export const loadNavigationState = async (): Promise<NavigationState | undefined> => {
  try {
    const stateString = await AsyncStorage.getItem(NAVIGATION_STATE_KEY);
    if (stateString) {
      return JSON.parse(stateString);
    }
  } catch (error) {
    console.error('Error loading navigation state:', error);
  }
  return undefined;
};

/**
 * Clear the navigation state (e.g., on logout)
 */
export const clearNavigationState = async () => {
  try {
    await AsyncStorage.removeItem(NAVIGATION_STATE_KEY);
  } catch (error) {
    console.error('Error clearing navigation state:', error);
  }
};
```

### Updated App.tsx with Persistence

```typescript
// App.tsx (Final version with persistence)
import React, { useEffect, useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { Platform, View, ActivityIndicator } from 'react-native';
import { DEEP_LINKING } from './src/navigation/deepLinking';
import { loadNavigationState, saveNavigationState } from './src/navigation/persistence';

import { SafeAreaWrapper } from './src/components/SafeAreaWrapper';
import { RootStackNavigator } from './src/navigation/RootStackNavigator';
import { navigationService } from './src/navigation/NavigationService';

/**
 * App - Root component with navigation persistence
 */
export default function App() {
  const [isReady, setIsReady] = useState(false);
  const [initialState, setInitialState] = useState(undefined);

  useEffect(() => {
    // Load navigation state
    const loadState = async () => {
      try {
        const state = await loadNavigationState();
        if (state) {
          setInitialState(state as any);
        }
      } catch (error) {
        console.error('Error loading navigation state:', error);
      } finally {
        setIsReady(true);
      }
    };

    loadState();
  }, []);

  useEffect(() => {
    // Subscribe to deep links
    const subscription = DEEP_LINKING.subscribeToDeepLinks(async (url) => {
      const { route, params } = await DEEP_LINKING.handleDeepLink(url);
      if (route) {
        navigationService.navigate(route as any, params);
      }
    });

    return () => {
      subscription.remove();
    };
  }, []);

  if (!isReady) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color="#3498db" />
      </View>
    );
  }

  return (
    <SafeAreaProvider>
      <NavigationContainer
        ref={navigationService.setTopLevelNavigator}
        initialState={initialState}
        onStateChange={(state) => {
          if (state) {
            saveNavigationState(state);
          }
        }}
        linking={DEEP_LINKING as any}
      >
        <SafeAreaWrapper>
          <RootStackNavigator />
        </SafeAreaWrapper>
        <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
```

---

## Target 8: Sample Screens

Let's build the minimal screens we referenced to complete the navigation system:

### TasksScreen.tsx

```typescript
// src/screens/tasks/TasksScreen.tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, TextInput } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { CustomStatusBar } from '../../components/CustomStatusBar';

// Mock data
const MOCK_TASKS = [
  { id: '1', title: 'Complete project proposal', dueDate: '2024-01-15', priority: 'high' },
  { id: '2', title: 'Team meeting preparation', dueDate: '2024-01-16', priority: 'medium' },
  { id: '3', title: 'Review design mockups', dueDate: '2024-01-18', priority: 'low' },
];

export const TasksScreen: React.FC = () => {
  const navigation = useNavigation();
  const [searchQuery, setSearchQuery] = useState('');
  const [tasks, setTasks] = useState(MOCK_TASKS);

  const renderTask = ({ item }: { item: any }) => (
    <TouchableOpacity
      style={styles.taskItem}
      onPress={() => navigation.navigate('TaskDetail' as any, { taskId: item.id })}
    >
      <View style={styles.taskContent}>
        <View style={[styles.priorityDot, { 
          backgroundColor: item.priority === 'high' ? '#e74c3c' : 
                           item.priority === 'medium' ? '#f39c12' : '#2ecc71' 
        }]} />
        <View style={styles.taskInfo}>
          <Text style={styles.taskTitle}>{item.title}</Text>
          <Text style={styles.taskDueDate}>Due: {item.dueDate}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <CustomStatusBar 
        title="My Tasks" 
        rightComponent={
          <TouchableOpacity onPress={() => console.log('Filter tasks')}>
            <Text style={{ fontSize: 20 }}>🔍</Text>
          </TouchableOpacity>
        }
      />
      
      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          placeholder="Search tasks..."
          value={searchQuery}
          onChangeText={setSearchQuery}
          placeholderTextColor="#95a5a6"
        />
      </View>

      <FlatList
        data={tasks}
        renderItem={renderTask}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  searchContainer: {
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  searchInput: {
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 10,
    fontSize: 16,
    color: '#2c3e50',
  },
  listContent: {
    padding: 16,
  },
  taskItem: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  taskContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  priorityDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 12,
  },
  taskInfo: {
    flex: 1,
  },
  taskTitle: {
    fontSize: 16,
    color: '#2c3e50',
    fontWeight: '500',
  },
  taskDueDate: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 4,
  },
});
```

### ProfileScreen.tsx

```typescript
// src/screens/profile/ProfileScreen.tsx
import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image } from 'react-native';
import { CustomStatusBar } from '../../components/CustomStatusBar';

export const ProfileScreen: React.FC = () => {
  const user = {
    name: 'John Doe',
    email: 'john@example.com',
    avatar: 'https://ui-avatars.com/api/?name=John+Doe&background=3498db&color=fff&size=200',
    joined: 'January 2024',
    tasksCompleted: 47,
  };

  const menuItems = [
    { icon: '📊', label: 'Statistics', onPress: () => console.log('Statistics') },
    { icon: '🏆', label: 'Achievements', onPress: () => console.log('Achievements') },
    { icon: '👥', label: 'Team', onPress: () => console.log('Team') },
    { icon: '🔔', label: 'Notifications', onPress: () => console.log('Notifications') },
    { icon: '⚙️', label: 'Settings', onPress: () => console.log('Settings') },
  ];

  return (
    <View style={styles.container}>
      <CustomStatusBar title="Profile" />
      
      <ScrollView contentContainerStyle={styles.content}>
        {/* Profile Header */}
        <View style={styles.profileHeader}>
          <Image source={{ uri: user.avatar }} style={styles.avatar} />
          <Text style={styles.userName}>{user.name}</Text>
          <Text style={styles.userEmail}>{user.email}</Text>
          <View style={styles.statsContainer}>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>{user.tasksCompleted}</Text>
              <Text style={styles.statLabel}>Tasks Completed</Text>
            </View>
            <View style={styles.statDivider} />
            <View style={styles.statItem}>
              <Text style={styles.statValue}>12</Text>
              <Text style={styles.statLabel}>In Progress</Text>
            </View>
          </View>
        </View>

        {/* Menu Items */}
        <View style={styles.menuContainer}>
          {menuItems.map((item, index) => (
            <TouchableOpacity
              key={index}
              style={[
                styles.menuItem,
                index === menuItems.length - 1 && styles.menuItemLast
              ]}
              onPress={item.onPress}
            >
              <Text style={styles.menuIcon}>{item.icon}</Text>
              <Text style={styles.menuLabel}>{item.label}</Text>
              <Text style={styles.menuArrow}>›</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Logout Button */}
        <TouchableOpacity style={styles.logoutButton}>
          <Text style={styles.logoutText}>Logout</Text>
        </TouchableOpacity>

        <Text style={styles.versionText}>TaskFlow v1.0.0</Text>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    paddingBottom: 40,
  },
  profileHeader: {
    backgroundColor: '#ffffff',
    padding: 24,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    marginBottom: 12,
    borderWidth: 3,
    borderColor: '#3498db',
  },
  userName: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 4,
  },
  userEmail: {
    fontSize: 14,
    color: '#7f8c8d',
  },
  statsContainer: {
    flexDirection: 'row',
    marginTop: 16,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    width: '100%',
    justifyContent: 'center',
  },
  statItem: {
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  statValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
  },
  statLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 4,
  },
  statDivider: {
    width: 1,
    backgroundColor: '#f0f0f0',
  },
  menuContainer: {
    backgroundColor: '#ffffff',
    marginTop: 20,
    marginHorizontal: 16,
    borderRadius: 12,
    overflow: 'hidden',
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  menuItemLast: {
    borderBottomWidth: 0,
  },
  menuIcon: {
    fontSize: 20,
    marginRight: 16,
  },
  menuLabel: {
    flex: 1,
    fontSize: 16,
    color: '#2c3e50',
  },
  menuArrow: {
    fontSize: 20,
    color: '#95a5a6',
  },
  logoutButton: {
    backgroundColor: '#e74c3c',
    marginHorizontal: 16,
    marginTop: 24,
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  logoutText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  versionText: {
    textAlign: 'center',
    color: '#95a5a6',
    fontSize: 12,
    marginTop: 20,
  },
});
```

---

## Verification: Test Your Navigation

```bash
# Run the app
cd ~/projects/TaskFlow
expo start

# Test the following:
```

### Navigation Test Checklist

1. **Login Flow:**
   - [ ] Login screen displays correctly
   - [ ] Login button navigates to MainTabs
   - [ ] Register link navigates to Register screen
   - [ ] Forgot password link navigates to ForgotPassword screen

2. **Tab Navigation:**
   - [ ] Five tabs visible (Home, Tasks, Add, Notifications, Profile)
   - [ ] Add button shows floating plus icon
   - [ ] Notification badge shows count (3)
   - [ ] Tabs switch smoothly

3. **Stack Navigation:**
   - [ ] Click a task → navigates to TaskDetail
   - [ ] Back button returns to Tasks
   - [ ] Edit button shows in header
   - [ ] TaskCreate opens as modal

4. **Drawer Navigation:**
   - [ ] Swipe from left edge or tap menu icon
   - [ ] User profile shows in drawer
   - [ ] Menu items navigate correctly
   - [ ] Drawer closes when selecting item

5. **Deep Linking:**
   ```bash
   # Test on iOS simulator
   npx uri-scheme open "taskflow://tasks/123" --ios
   
   # Test on Android emulator
   npx uri-scheme open "taskflow://tasks/123" --android
   ```

6. **Persistence:**
   - [ ] Navigate to a screen
   - [ ] Close the app
   - [ ] Reopen the app → should return to last screen

### Common Navigation Issues and Solutions

| Issue | Solution |
|-------|----------|
| "Cannot read property 'navigate' of undefined" | Ensure navigation prop is passed or use `useNavigation` hook |
| Navigation state lost on app restart | Check AsyncStorage permissions and state saving logic |
| Deep links not working | Verify URI scheme registration in app.json |
| Header buttons not showing | Check `headerRight`/`headerLeft` options in screen options |
| Tab bar disappears | Ensure `headerShown: false` is set for tab navigator screens |

---

## What We've Accomplished

Congratulations! You've completed the navigation system for TaskFlow. Here's what you've built:

1. **Complete Navigation Architecture:**
   - Stack navigation for hierarchical flows
   - Tab navigation for primary sections
   - Drawer navigation for secondary features

2. **Type-Safe Navigation:**
   - Full TypeScript support
   - Parameter validation
   - Automatic type inference

3. **Production-Ready Features:**
   - Deep linking support
   - Navigation state persistence
   - Authentication flow
   - Modal screens

4. **User Experience:**
   - Smooth transitions
   - Custom headers
   - Badge indicators
   - Floating action button

### Next Steps: Part 2

You've completed the foundational phase! In Part 2, you'll learn:
- **State Management:** Building robust state with Zustand
- **Local Storage:** Persisting data with MMKV and SQLite
- **Network Integration:** API calls with React Query
- **Offline Support:** Building offline-first applications

*You've successfully built the complete foundation of TaskFlow! In Part 2, we'll bring your app to life with robust state management, local data persistence, and network integration. Your app will become fully functional and data-driven. See you in Part 2!*
