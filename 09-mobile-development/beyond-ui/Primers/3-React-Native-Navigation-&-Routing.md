# Primer 3: React Native Navigation & Routing

## Your Complete Guide to Moving Between Screens

Welcome to the Navigation Primer! This guide covers everything you need to know about navigation in React Native apps. Navigation is the backbone of your mobile app—it's how users move between different screens and features. Think of it as the GPS system for your app; without it, users would be lost.

---

## N.1 Understanding Navigation in React Native

### The Concept: The App's Traffic Controller

Navigation in React Native is like a traffic controller at a busy intersection. It directs users where they want to go, handles transitions between screens, and manages the history of where users have been.

**Simple Analogy:** Think of navigation like a book with tabs, chapters, and pages. The tabs are bottom navigation, chapters are stacks, and pages are screens. Users can flip through pages (screens), jump to chapters (stack navigation), and use tabs (tab navigation) to switch between major sections.

### Key Navigation Concepts

```typescript
// 1. Screens - Individual pages in your app
const HomeScreen = () => { /* ... */ };
const ProfileScreen = () => { /* ... */ };

// 2. Navigation Container - The root component that manages navigation
<NavigationContainer>
  {/* Your navigators here */}
</NavigationContainer>

// 3. Stack Navigator - Screens stacked on top of each other
const Stack = createNativeStackNavigator();
<Stack.Navigator>
  <Stack.Screen name="Home" component={HomeScreen} />
  <Stack.Screen name="Profile" component={ProfileScreen} />
</Stack.Navigator>

// 4. Tab Navigator - Screens accessible via tabs at bottom/top
const Tab = createBottomTabNavigator();
<Tab.Navigator>
  <Tab.Screen name="Home" component={HomeScreen} />
  <Tab.Screen name="Profile" component={ProfileScreen} />
</Tab.Navigator>

// 5. Navigation Prop - Used to navigate between screens
const navigation = useNavigation();
navigation.navigate('Profile');

// 6. Route Prop - Contains parameters passed to the screen
const route = useRoute();
const { userId } = route.params;
```

---

## N.2 Navigation Setup

### The Concept: Setting Up Your Navigation System

Before you can navigate, you need to install and configure the navigation libraries.

### Complete Setup Guide

```bash
# 1. Install core navigation packages
npm install @react-navigation/native

# 2. Install dependencies
npm install react-native-screens react-native-safe-area-context

# 3. Install stack navigator
npm install @react-navigation/native-stack

# 4. Install tab navigator
npm install @react-navigation/bottom-tabs

# 5. Install drawer navigator
npm install @react-navigation/drawer

# 6. Install gesture handler (for drawer and more)
npm install react-native-gesture-handler

# 7. Install vector icons (for tab icons)
npm install @expo/vector-icons

# 8. iOS only: Install pods
cd ios && pod install && cd ..
```

### Basic Navigation Setup

```typescript
// App.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

// Import screens
import HomeScreen from './screens/HomeScreen';
import ProfileScreen from './screens/ProfileScreen';
import SettingsScreen from './screens/SettingsScreen';
import DetailsScreen from './screens/DetailsScreen';

// Create navigators
const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

// Main Tab Navigator
function MainTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

// Root Stack Navigator
export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Main" component={MainTabs} />
        <Stack.Screen name="Details" component={DetailsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

---

## N.3 Stack Navigation

### The Concept: Pages in a Stack

Stack navigation works like a stack of cards. When you navigate to a new screen, it's placed on top of the stack. When you go back, it's removed from the stack. This is the most common navigation pattern in mobile apps.

### Complete Stack Navigation Guide

```typescript
// 1. Creating a Stack Navigator
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#f4511e',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}
      >
        <Stack.Screen 
          name="Home" 
          component={HomeScreen}
          options={{
            title: 'My Home',
            headerRight: () => (
              <Button title="Menu" onPress={() => console.log('Menu pressed')} />
            ),
          }}
        />
        <Stack.Screen 
          name="Details" 
          component={DetailsScreen}
          options={({ route }) => ({
            title: route.params?.title || 'Details',
          })}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

// 2. Navigating Between Screens
function HomeScreen({ navigation }) {
  return (
    <View>
      <Button
        title="Go to Details"
        onPress={() => navigation.navigate('Details', {
          itemId: 86,
          title: 'Custom Title',
        })}
      />
      
      {/* Replace current screen */}
      <Button
        title="Replace with Details"
        onPress={() => navigation.replace('Details', { itemId: 42 })}
      />
      
      {/* Go back */}
      <Button
        title="Go Back"
        onPress={() => navigation.goBack()}
      />
      
      {/* Go to top of stack */}
      <Button
        title="Go to Home"
        onPress={() => navigation.popToTop()}
      />
    </View>
  );
}

// 3. Accessing Route Parameters
function DetailsScreen({ route }) {
  const { itemId, title } = route.params;
  
  return (
    <View>
      <Text>Item ID: {itemId}</Text>
      <Text>Title: {title}</Text>
    </View>
  );
}

// 4. Common Stack Navigation Options
<Stack.Screen
  name="Profile"
  component={ProfileScreen}
  options={{
    // Hide header
    headerShown: false,
    
    // Custom header
    header: ({ navigation, route }) => (
      <View style={{ height: 80, backgroundColor: '#2196F3' }}>
        <Text>Custom Header</Text>
      </View>
    ),
    
    // Animation
    animation: 'slide_from_right',
    
    // Presentation (modal)
    presentation: 'modal',
    
    // Full-screen modal
    presentation: 'fullScreenModal',
    
    // Transparent background
    presentation: 'transparentModal',
  }}
/>
```

---

## N.4 Tab Navigation

### The Concept: Switching Between Sections

Tab navigation provides a bottom or top bar that lets users switch between major sections of your app. It's like a filing cabinet with multiple drawers—each drawer (tab) contains different content.

### Complete Tab Navigation Guide

```typescript
// 1. Basic Tab Navigation
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';

const Tab = createBottomTabNavigator();

function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={({ route }) => ({
          tabBarIcon: ({ focused, color, size }) => {
            let iconName;
            
            if (route.name === 'Home') {
              iconName = focused ? 'home' : 'home-outline';
            } else if (route.name === 'Profile') {
              iconName = focused ? 'person' : 'person-outline';
            } else if (route.name === 'Settings') {
              iconName = focused ? 'settings' : 'settings-outline';
            }
            
            return <Ionicons name={iconName} size={size} color={color} />;
          },
          tabBarActiveTintColor: '#2196F3',
          tabBarInactiveTintColor: 'gray',
          tabBarStyle: {
            backgroundColor: '#ffffff',
            height: 60,
            paddingBottom: 8,
            paddingTop: 8,
          },
          headerStyle: {
            backgroundColor: '#2196F3',
          },
          headerTintColor: '#ffffff',
        })}
      >
        <Tab.Screen 
          name="Home" 
          component={HomeScreen}
          options={{
            title: 'Dashboard',
            headerTitle: 'NexusCollect',
          }}
        />
        <Tab.Screen 
          name="Profile" 
          component={ProfileScreen}
          options={{
            tabBarBadge: 3, // Show badge with count
          }}
        />
        <Tab.Screen 
          name="Settings" 
          component={SettingsScreen}
        />
      </Tab.Navigator>
    </NavigationContainer>
  );
}

// 2. Custom Tab Bar
import { BottomTabBar } from '@react-navigation/bottom-tabs';

function CustomTabBar({ state, descriptors, navigation }) {
  return (
    <View style={{ flexDirection: 'row', backgroundColor: '#fff', height: 70 }}>
      {state.routes.map((route, index) => {
        const { options } = descriptors[route.key];
        const isFocused = state.index === index;
        
        const onPress = () => {
          const event = navigation.emit({
            type: 'tabPress',
            target: route.key,
          });
          
          if (!isFocused && !event.defaultPrevented) {
            navigation.navigate(route.name);
          }
        };
        
        return (
          <TouchableOpacity
            key={route.key}
            onPress={onPress}
            style={{
              flex: 1,
              alignItems: 'center',
              justifyContent: 'center',
              paddingVertical: 8,
            }}
          >
            <Ionicons
              name={options.tabBarIconName || 'circle'}
              size={24}
              color={isFocused ? '#2196F3' : 'gray'}
            />
            <Text style={{ color: isFocused ? '#2196F3' : 'gray', fontSize: 12 }}>
              {options.title || route.name}
            </Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}

// Usage
<Tab.Navigator tabBar={(props) => <CustomTabBar {...props} />}>
  {/* Tab screens */}
</Tab.Navigator>

// 3. Nested Tabs and Stacks
function HomeStack() {
  const Stack = createNativeStackNavigator();
  return (
    <Stack.Navigator>
      <Stack.Screen name="HomeList" component={HomeListScreen} />
      <Stack.Screen name="HomeDetail" component={HomeDetailScreen} />
    </Stack.Navigator>
  );
}

function ProfileStack() {
  const Stack = createNativeStackNavigator();
  return (
    <Stack.Navigator>
      <Stack.Screen name="ProfileList" component={ProfileListScreen} />
      <Stack.Screen name="ProfileDetail" component={ProfileDetailScreen} />
    </Stack.Navigator>
  );
}

// Main Tab Navigator with nested stacks
function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator>
        <Tab.Screen name="Home" component={HomeStack} />
        <Tab.Screen name="Profile" component={ProfileStack} />
        <Tab.Screen name="Settings" component={SettingsScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}
```

---

## N.5 Authentication Flow Navigation

### The Concept: Conditional Navigation

Authentication flow navigation shows different screens based on whether the user is logged in. This is a common pattern in mobile apps.

### Complete Authentication Flow Guide

```typescript
// 1. Auth Flow Setup
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Auth Stack (unauthenticated)
const AuthStack = createNativeStackNavigator();
function AuthNavigator() {
  return (
    <AuthStack.Navigator screenOptions={{ headerShown: false }}>
      <AuthStack.Screen name="Login" component={LoginScreen} />
      <AuthStack.Screen name="Register" component={RegisterScreen} />
      <AuthStack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </AuthStack.Navigator>
  );
}

// Main Stack (authenticated)
const MainStack = createNativeStackNavigator();
function MainNavigator() {
  return (
    <MainStack.Navigator>
      <MainStack.Screen name="MainTabs" component={MainTabs} />
      <MainStack.Screen name="Details" component={DetailsScreen} />
    </MainStack.Navigator>
  );
}

// 2. Root Navigator with Authentication State
import { useAuthStore } from '@store';

function RootNavigator() {
  const { isAuthenticated, isLoading } = useAuthStore();

  // Show splash screen while loading
  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      {isAuthenticated ? <MainNavigator /> : <AuthNavigator />}
    </NavigationContainer>
  );
}

// 3. Complete Auth Flow Example
function LoginScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login, isLoading } = useAuthStore();

  const handleLogin = async () => {
    const success = await login(email, password);
    if (success) {
      // Navigation automatically changes to MainNavigator
      // due to auth state change
    }
  };

  return (
    <View>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <Button
        title={isLoading ? 'Logging in...' : 'Login'}
        onPress={handleLogin}
        disabled={isLoading}
      />
      <Button
        title="Create Account"
        onPress={() => navigation.navigate('Register')}
      />
      <Button
        title="Forgot Password?"
        onPress={() => navigation.navigate('ForgotPassword')}
      />
    </View>
  );
}

function RegisterScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const { register, isLoading } = useAuthStore();

  const handleRegister = async () => {
    if (password !== confirmPassword) {
      Alert.alert('Error', 'Passwords do not match');
      return;
    }
    await register(email, password);
  };

  return (
    <View>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <TextInput
        placeholder="Confirm Password"
        secureTextEntry
        value={confirmPassword}
        onChangeText={setConfirmPassword}
      />
      <Button
        title={isLoading ? 'Creating Account...' : 'Create Account'}
        onPress={handleRegister}
        disabled={isLoading}
      />
      <Button
        title="Already have an account? Sign In"
        onPress={() => navigation.navigate('Login')}
      />
    </View>
  );
}
```

---

## N.6 Drawer Navigation

### The Concept: Hidden Navigation Menu

Drawer navigation provides a hidden menu that slides in from the side. It's commonly used for navigation items that don't fit in the tab bar.

### Complete Drawer Navigation Guide

```typescript
// 1. Basic Drawer Navigation
import { createDrawerNavigator } from '@react-navigation/drawer';

const Drawer = createDrawerNavigator();

function App() {
  return (
    <NavigationContainer>
      <Drawer.Navigator
        screenOptions={{
          drawerStyle: {
            backgroundColor: '#fff',
            width: 240,
          },
          drawerLabelStyle: {
            fontSize: 16,
          },
          drawerActiveBackgroundColor: '#2196F3',
          drawerActiveTintColor: '#fff',
          drawerInactiveTintColor: '#333',
        }}
      >
        <Drawer.Screen 
          name="Home" 
          component={HomeScreen}
          options={{
            drawerIcon: ({ color, size }) => (
              <Ionicons name="home-outline" size={size} color={color} />
            ),
          }}
        />
        <Drawer.Screen 
          name="Profile" 
          component={ProfileScreen}
          options={{
            drawerIcon: ({ color, size }) => (
              <Ionicons name="person-outline" size={size} color={color} />
            ),
          }}
        />
        <Drawer.Screen 
          name="Settings" 
          component={SettingsScreen}
          options={{
            drawerIcon: ({ color, size }) => (
              <Ionicons name="settings-outline" size={size} color={color} />
            ),
          }}
        />
      </Drawer.Navigator>
    </NavigationContainer>
  );
}

// 2. Custom Drawer Content
import { DrawerContentScrollView, DrawerItemList, DrawerItem } from '@react-navigation/drawer';

function CustomDrawerContent(props) {
  const { user, logout } = useAuthStore();

  return (
    <DrawerContentScrollView {...props}>
      {/* User header */}
      <View style={{ padding: 16, backgroundColor: '#2196F3' }}>
        <Text style={{ color: '#fff', fontSize: 18, fontWeight: 'bold' }}>
          {user?.name || 'Guest'}
        </Text>
        <Text style={{ color: '#fff', fontSize: 14 }}>
          {user?.email || 'Not logged in'}
        </Text>
      </View>

      {/* Navigation items */}
      <DrawerItemList {...props} />

      {/* Custom items */}
      <DrawerItem
        label="Logout"
        icon={({ color, size }) => (
          <Ionicons name="log-out-outline" size={size} color={color} />
        )}
        onPress={() => {
          logout();
          props.navigation.closeDrawer();
        }}
      />

      <DrawerItem
        label="Feedback"
        icon={({ color, size }) => (
          <Ionicons name="chatbubble-outline" size={size} color={color} />
        )}
        onPress={() => {
          // Navigate to feedback
        }}
      />
    </DrawerContentScrollView>
  );
}

// Usage
<Drawer.Navigator
  drawerContent={(props) => <CustomDrawerContent {...props} />}
>
  {/* Drawer screens */}
</Drawer.Navigator>

// 3. Opening and Closing Drawer
function HomeScreen({ navigation }) {
  return (
    <View>
      <Button
        title="Open Drawer"
        onPress={() => navigation.openDrawer()}
      />
      <Button
        title="Close Drawer"
        onPress={() => navigation.closeDrawer()}
      />
      <Button
        title="Toggle Drawer"
        onPress={() => navigation.toggleDrawer()}
      />
    </View>
  );
}
```

---

## N.7 Deep Linking

### The Concept: Opening Specific Screens

Deep linking allows your app to be opened to a specific screen from external links. It's like having a URL that opens a specific page in your app.

### Complete Deep Linking Guide

```typescript
// 1. Configure Deep Linking
import { Linking } from 'react-native';
import * as WebBrowser from 'expo-web-browser';

function App() {
  const linking = {
    prefixes: ['nexuscollect://', 'https://nexuscollect.com'],
    config: {
      screens: {
        Home: 'home',
        Profile: 'profile/:userId',
        Settings: 'settings',
        Details: 'details/:itemId',
        Auth: {
          screens: {
            Login: 'login',
            Register: 'register',
          },
        },
      },
    },
    // Handle specific deep links
    subscribe: (listener) => {
      const onReceiveURL = ({ url }) => listener(url);
      
      // Listen for incoming links
      const subscription = Linking.addEventListener('url', onReceiveURL);
      
      return () => {
        subscription.remove();
      };
    },
    // Get initial URL
    async getInitialURL() {
      const url = await Linking.getInitialURL();
      if (url) {
        return url;
      }
      return null;
    },
    // Custom parser
    parse: (url) => {
      // Parse URL and return navigation parameters
      const parsed = new URL(url);
      const path = parsed.pathname;
      const params = Object.fromEntries(parsed.searchParams);
      return { screen: path.slice(1), params };
    },
  };

  return (
    <NavigationContainer linking={linking} fallback={<LoadingScreen />}>
      <RootNavigator />
    </NavigationContainer>
  );
}

// 2. Handle Deep Links in Screens
import { useEffect } from 'react';
import { useNavigation, useRoute } from '@react-navigation/native';

function DetailsScreen() {
  const route = useRoute();
  const navigation = useNavigation();
  
  useEffect(() => {
    // Handle deep link params
    if (route.params?.itemId) {
      // Load item based on ID
      console.log('Deep link to item:', route.params.itemId);
    }
  }, [route.params]);

  return <Text>Item ID: {route.params?.itemId}</Text>;
}

// 3. Generate Deep Links
import { generateDeepLink } from '@utils/navigation';

function ShareButton({ itemId }) {
  const handleShare = async () => {
    try {
      const deepLink = `nexuscollect://details/${itemId}`;
      await Share.share({
        title: 'Check this out!',
        message: `Open this link in the app: ${deepLink}`,
        url: `https://nexuscollect.com/details/${itemId}`,
      });
    } catch (error) {
      console.error('Share error:', error);
    }
  };

  return <Button title="Share" onPress={handleShare} />;
}

// 4. Universal Links (iOS) / App Links (Android)
// Configure in app.json
{
  "expo": {
    "ios": {
      "associatedDomains": ["applinks:nexuscollect.com"]
    },
    "android": {
      "intentFilters": [
        {
          "action": "VIEW",
          "data": [
            {
              "scheme": "https",
              "host": "nexuscollect.com",
              "pathPrefix": "/"
            }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}
```

---

## N.8 Navigation Types & TypeScript

### The Concept: Type-Safe Navigation

TypeScript makes navigation safer by ensuring you only navigate to screens that exist and pass the correct parameters.

### Complete Type-Safe Navigation Guide

```typescript
// 1. Define Navigation Types
// types/navigation.ts
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { CompositeNavigationProp } from '@react-navigation/native';
import { RouteProp } from '@react-navigation/native';

// Root Stack
export type RootStackParamList = {
  Splash: undefined;
  Auth: undefined;
  Main: undefined;
};

// Auth Stack
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

// Main Tab Navigator
export type MainTabParamList = {
  Home: undefined;
  Profile: { userId?: string };
  Settings: undefined;
};

// Main Stack
export type MainStackParamList = {
  MainTabs: undefined;
  Details: { itemId: string };
  FormEntry: { formId: string; entryId?: string };
};

// Navigation Props
export type AuthScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList>;
export type MainScreenNavigationProp = CompositeNavigationProp<
  NativeStackNavigationProp<MainStackParamList>,
  BottomTabNavigationProp<MainTabParamList>
>;

// Route Props
export type DetailsScreenRouteProp = RouteProp<MainStackParamList, 'Details'>;
export type ProfileScreenRouteProp = RouteProp<MainTabParamList, 'Profile'>;

// 2. Use in Components
import { useNavigation, useRoute } from '@react-navigation/native';
import { AuthScreenNavigationProp } from '@types/navigation';

function LoginScreen() {
  const navigation = useNavigation<AuthScreenNavigationProp>();
  
  const handleRegister = () => {
    navigation.navigate('Register'); // ✅ Type-safe
    // navigation.navigate('NonExistent'); ❌ Type error
  };

  return (
    <Button title="Create Account" onPress={handleRegister} />
  );
}

// 3. Use Route Parameters
import { RouteProp } from '@react-navigation/native';
import { MainStackParamList } from '@types/navigation';

type DetailsScreenRouteProp = RouteProp<MainStackParamList, 'Details'>;

function DetailsScreen() {
  const route = useRoute<DetailsScreenRouteProp>();
  const { itemId } = route.params; // TypeScript knows it's a string
  
  return <Text>Item ID: {itemId}</Text>;
}

// 4. Navigation with Custom Hooks
import { useNavigation } from '@react-navigation/native';
import { RootStackParamList } from '@types/navigation';
import { StackNavigationProp } from '@react-navigation/stack';

export const useRootNavigation = () => {
  return useNavigation<StackNavigationProp<RootStackParamList>>();
};

// Usage
function SomeScreen() {
  const navigation = useRootNavigation();
  
  navigation.navigate('Main'); // Type-safe
}
```

---

## N.9 Advanced Navigation Patterns

### The Concept: Complex Navigation Scenarios

Advanced patterns for complex navigation needs.

### Complete Advanced Guide

```typescript
// 1. Modal Screens
function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          presentation: 'modal',
        }}
      >
        <Stack.Screen name="Main" component={MainTabs} />
        <Stack.Screen 
          name="Create" 
          component={CreateScreen}
          options={{
            presentation: 'modal',
            headerShown: false,
          }}
        />
        <Stack.Screen 
          name="FullScreenModal" 
          component={FullScreenModal}
          options={{
            presentation: 'fullScreenModal',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

// 2. Navigation with Parameters
function HomeScreen({ navigation }) {
  const goToProfile = (userId: string) => {
    navigation.navigate('Profile', {
      userId,
      source: 'home',
    });
  };

  return (
    <Button 
      title="View Profile" 
      onPress={() => goToProfile('123')}
    />
  );
}

function ProfileScreen({ route }) {
  const { userId, source } = route.params;
  
  return (
    <View>
      <Text>User ID: {userId}</Text>
      <Text>Source: {source}</Text>
    </View>
  );
}

// 3. Navigation State Persistence
import { createNavigationContainerRef } from '@react-navigation/native';

export const navigationRef = createNavigationContainerRef();

function App() {
  return (
    <NavigationContainer ref={navigationRef}>
      <RootNavigator />
    </NavigationContainer>
  );
}

// Navigate from anywhere
export const navigate = (name: string, params?: object) => {
  if (navigationRef.isReady()) {
    navigationRef.navigate(name, params);
  }
};

// Usage anywhere in app
import { navigate } from './App';
navigate('Profile', { userId: '123' });

// 4. Reset Navigation Stack
function LogoutButton() {
  const navigation = useNavigation();
  
  const handleLogout = () => {
    // Reset navigation to auth screen
    navigation.reset({
      index: 0,
      routes: [{ name: 'Auth' }],
    });
  };

  return <Button title="Logout" onPress={handleLogout} />;
}

// 5. Navigation with State
function AuthGuard({ children }) {
  const { isAuthenticated } = useAuthStore();
  const navigation = useNavigation();

  useEffect(() => {
    if (!isAuthenticated) {
      navigation.reset({
        index: 0,
        routes: [{ name: 'Auth' }],
      });
    }
  }, [isAuthenticated]);

  return children;
}
```

---

## N.10 Common Navigation Issues & Solutions

### The Concept: Troubleshooting Navigation

Common navigation issues and how to fix them.

### Complete Troubleshooting Guide

| Issue | Cause | Solution |
|-------|-------|----------|
| `Cannot read property 'navigate' of undefined` | Navigation not initialized | Use `useNavigation` hook or check navigation ref |
| Screen not updating when params change | Params not being watched | Use `useEffect` with `route.params` dependency |
| Navigation state lost on app restart | State not persisted | Use `persistState` or save navigation state |
| Header not showing | `headerShown` set to `false` | Set `headerShown: true` or customize |
| Back button not working | No screen to go back to | Check navigation history or use `canGoBack()` |
| Deep links not working | Incorrect configuration | Check `app.json` and linking config |
| Tab bar not showing | `headerShown` conflict | Tab bar shows when header is visible |

```typescript
// 1. Fix: Navigation not initialized
// Use the navigation hook
import { useNavigation } from '@react-navigation/native';

function MyComponent() {
  const navigation = useNavigation();
  
  const handlePress = () => {
    navigation.navigate('Screen');
  };
}

// Or check navigation ref
if (navigationRef.isReady()) {
  navigationRef.navigate('Screen');
}

// 2. Fix: Screen not updating with params
function DetailsScreen({ route }) {
  const { itemId } = route.params;
  
  useEffect(() => {
    // Re-fetch data when itemId changes
    fetchItem(itemId);
  }, [itemId]);
}

// 3. Fix: Missing back button
<Stack.Navigator
  screenOptions={{
    headerBackTitle: 'Back',
    headerBackTitleVisible: true,
  }}
>
  <Stack.Screen
    name="Details"
    component={DetailsScreen}
    options={{
      headerLeft: ({ canGoBack }) => canGoBack ? (
        <BackButton />
      ) : undefined,
    }}
  />
</Stack.Navigator>

// 4. Fix: Persist navigation state
import { createNavigationContainerRef } from '@react-navigation/native';
import { AsyncStorage } from 'react-native';

const NAVIGATION_STATE_KEY = 'navigation_state';

function App() {
  const [isReady, setIsReady] = useState(false);
  const [initialState, setInitialState] = useState();

  useEffect(() => {
    const restoreState = async () => {
      try {
        const savedState = await AsyncStorage.getItem(NAVIGATION_STATE_KEY);
        if (savedState) {
          setInitialState(JSON.parse(savedState));
        }
      } finally {
        setIsReady(true);
      }
    };

    restoreState();
  }, []);

  if (!isReady) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer
      initialState={initialState}
      onStateChange={(state) => {
        AsyncStorage.setItem(NAVIGATION_STATE_KEY, JSON.stringify(state));
      }}
    >
      <RootNavigator />
    </NavigationContainer>
  );
}
```

---

## Quick Reference: Navigation Commands

```bash
# Install navigation packages
npm install @react-navigation/native @react-navigation/native-stack
npm install @react-navigation/bottom-tabs @react-navigation/drawer
npm install react-native-screens react-native-safe-area-context
npm install react-native-gesture-handler react-native-reanimated

# iOS only
cd ios && pod install && cd ..

# Types
npm install -D @types/react-navigation

# Debugging
npx react-native start --reset-cache
```

---

**Ready to navigate your way through NexusCollect? Let's go!**
