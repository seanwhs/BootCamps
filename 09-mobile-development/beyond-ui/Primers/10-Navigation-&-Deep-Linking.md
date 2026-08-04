# Primer 10: Navigation & Deep Linking

## Your Complete Guide to App Navigation and External Links

Welcome to the Navigation & Deep Linking Primer! This guide covers advanced navigation patterns, deep linking, universal links, and handling navigation state in your React Native app. Navigation is the backbone of user experience—it determines how users move through your app and how they return to it.

---

## N.1 Advanced Navigation Patterns

### The Concept: Complex Navigation Flows

Real apps often have complex navigation requirements: authentication flows, nested navigators, modals, and conditional navigation.

### Complete Advanced Navigation Guide

```typescript
// 1. Authentication Flow with Navigation
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAuthStore } from '@store';

// Auth Stack (Unauthenticated)
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

// Main Stack (Authenticated)
const MainStack = createNativeStackNavigator();
function MainNavigator() {
  return (
    <MainStack.Navigator>
      <MainStack.Screen name="MainTabs" component={MainTabs} />
      <MainStack.Screen name="Profile" component={ProfileScreen} />
      <MainStack.Screen name="Settings" component={SettingsScreen} />
    </MainStack.Navigator>
  );
}

// Root Navigator with Auth State
function RootNavigator() {
  const { isAuthenticated, isLoading } = useAuthStore();

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      {isAuthenticated ? <MainNavigator /> : <AuthNavigator />}
    </NavigationContainer>
  );
}

// 2. Nested Navigators
const HomeStack = createNativeStackNavigator();
function HomeStackNavigator() {
  return (
    <HomeStack.Navigator>
      <HomeStack.Screen name="HomeList" component={HomeListScreen} />
      <HomeStack.Screen name="HomeDetail" component={HomeDetailScreen} />
    </HomeStack.Navigator>
  );
}

const ProfileStack = createNativeStackNavigator();
function ProfileStackNavigator() {
  return (
    <ProfileStack.Navigator>
      <ProfileStack.Screen name="ProfileList" component={ProfileListScreen} />
      <ProfileStack.Screen name="ProfileDetail" component={ProfileDetailScreen} />
    </ProfileStack.Navigator>
  );
}

// Main Tabs with Nested Stacks
function MainTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeStackNavigator} />
      <Tab.Screen name="Profile" component={ProfileStackNavigator} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

// 3. Modal Navigation
function AppNavigator() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Main" component={MainTabs} />
      <Stack.Screen 
        name="Modal" 
        component={ModalScreen}
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
      <Stack.Screen 
        name="TransparentModal" 
        component={TransparentModal}
        options={{
          presentation: 'transparentModal',
        }}
      />
    </Stack.Navigator>
  );
}

// 4. Conditional Navigation
function ConditionalNavigator({ isAdmin }) {
  if (isAdmin) {
    return <AdminNavigator />;
  }
  return <UserNavigator />;
}

// 5. Navigation with State Preservation
import { createNavigationContainerRef } from '@react-navigation/native';

export const navigationRef = createNavigationContainerRef();

function App() {
  const [isReady, setIsReady] = useState(false);
  const [initialState, setInitialState] = useState();

  useEffect(() => {
    const restoreState = async () => {
      try {
        const savedState = await AsyncStorage.getItem('NAVIGATION_STATE');
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
      ref={navigationRef}
      initialState={initialState}
      onStateChange={(state) => {
        AsyncStorage.setItem('NAVIGATION_STATE', JSON.stringify(state));
      }}
    >
      <RootNavigator />
    </NavigationContainer>
  );
}
```

---

## N.2 Deep Linking

### The Concept: Opening Specific Screens

Deep linking allows your app to be opened to specific screens from external sources like websites, emails, or other apps.

### Complete Deep Linking Guide

```typescript
// 1. Configure Deep Linking
// app.json
{
  "expo": {
    "scheme": "nexuscollect",
    "ios": {
      "bundleIdentifier": "com.yourcompany.nexuscollect",
      "associatedDomains": ["applinks:nexuscollect.com"]
    },
    "android": {
      "package": "com.yourcompany.nexuscollect",
      "intentFilters": [
        {
          "action": "VIEW",
          "data": [
            {
              "scheme": "https",
              "host": "nexuscollect.com",
              "pathPrefix": "/"
            },
            {
              "scheme": "nexuscollect"
            }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}

// 2. Linking Configuration
// src/navigation/linking.ts
import { Linking } from 'react-native';

export const linking = {
  prefixes: [
    'nexuscollect://',
    'https://nexuscollect.com',
    'https://*.nexuscollect.com',
  ],
  
  config: {
    screens: {
      // Auth screens
      Auth: {
        screens: {
          Login: 'login',
          Register: 'register',
          ForgotPassword: 'forgot-password',
        },
      },
      
      // Main screens
      Main: {
        screens: {
          MainTabs: {
            screens: {
              Home: {
                screens: {
                  HomeList: 'home',
                  HomeDetail: 'home/:id',
                },
              },
              Profile: {
                screens: {
                  ProfileList: 'profile',
                  ProfileDetail: 'profile/:userId',
                },
              },
            },
          },
          CollectionDetail: 'collection/:id',
          FormEntry: 'form/:formId/entry/:entryId?',
        },
      },
      
      // Not found
      NotFound: '*',
    },
  },
  
  // Custom URL parser
  parse: (url: string) => {
    const parsed = new URL(url);
    const path = parsed.pathname;
    const params = Object.fromEntries(parsed.searchParams);
    
    // Custom parsing logic
    if (path.startsWith('/invite/')) {
      const inviteId = path.split('/')[2];
      return {
        screen: 'Invite',
        params: { inviteId },
      };
    }
    
    return { path, params };
  },
  
  // Custom URL generator
  stringify: (state: any) => {
    // Generate custom URLs from navigation state
    return `nexuscollect://${state.routeName}?${new URLSearchParams(state.params)}`;
  },
};

// 3. Use in Navigation
import { NavigationContainer } from '@react-navigation/native';
import { linking } from './linking';

function App() {
  return (
    <NavigationContainer linking={linking} fallback={<LoadingScreen />}>
      <RootNavigator />
    </NavigationContainer>
  );
}

// 4. Handle Deep Links in Components
import { useRoute } from '@react-navigation/native';

function CollectionDetailScreen() {
  const route = useRoute();
  const { id } = route.params as { id: string };
  
  // Fetch collection data
  const { data } = useQuery({
    queryKey: ['collection', id],
    queryFn: () => fetchCollection(id),
  });
  
  return <CollectionDetail collection={data} />;
}

// 5. Generate Deep Links Programmatically
import { generateDeepLink } from '@utils/navigation';

function ShareButton({ collectionId }) {
  const handleShare = async () => {
    const deepLink = `nexuscollect://collection/${collectionId}`;
    const webLink = `https://nexuscollect.com/collection/${collectionId}`;
    
    await Share.share({
      title: 'Check out this collection',
      message: `Open in app: ${deepLink}`,
      url: webLink,
    });
  };
  
  return <Button title="Share" onPress={handleShare} />;
}
```

---

## N.3 Universal Links (iOS) / App Links (Android)

### The Concept: Seamless Web-to-App Experience

Universal links (iOS) and App Links (Android) allow your app to open automatically when users click links to your website.

### Complete Universal Links Guide

```typescript
// 1. iOS - Configure Associated Domains
// In Xcode project settings:
// Capabilities → Associated Domains
// Add: applinks:nexuscollect.com

// 2. iOS - Apple App Site Association File
// /.well-known/apple-app-site-association
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.yourcompany.nexuscollect",
        "paths": ["*", "!/privacy", "!/terms"]
      }
    ]
  }
}

// 3. Android - Asset Links File
// /.well-known/assetlinks.json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.yourcompany.nexuscollect",
      "sha256_cert_fingerprints": ["YOUR_CERT_FINGERPRINT"]
    }
  }
]

// 4. Handle Universal Links
import { Linking, Platform } from 'react-native';

function useUniversalLinks() {
  useEffect(() => {
    // Handle initial URL
    const handleInitialURL = async () => {
      const url = await Linking.getInitialURL();
      if (url) {
        handleDeepLink(url);
      }
    };
    handleInitialURL();

    // Listen for URL events
    const subscription = Linking.addEventListener('url', ({ url }) => {
      handleDeepLink(url);
    });

    return () => {
      subscription.remove();
    };
  }, []);

  const handleDeepLink = (url: string) => {
    // Parse URL and navigate
    console.log('Universal link received:', url);
    
    // Extract path and parameters
    const parsed = new URL(url);
    const path = parsed.pathname;
    const params = Object.fromEntries(parsed.searchParams);
    
    // Navigate based on path
    if (path === '/collection') {
      navigation.navigate('CollectionDetail', { id: params.id });
    } else if (path === '/profile') {
      navigation.navigate('Profile', { userId: params.userId });
    }
  };
}

// 5. Test Universal Links
// iOS: Use a tool like https://branch.io
// Android: Use adb to test:
// adb shell am start -W -a android.intent.action.VIEW -d "nexuscollect://collection/123"
```

---

## N.4 Navigation State Management

### The Concept: Persisting Navigation State

Saving and restoring navigation state allows users to return to where they left off.

### Complete Navigation State Guide

```typescript
// 1. Persist Navigation State
import { createNavigationContainerRef } from '@react-navigation/native';
import AsyncStorage from '@react-native-async-storage/async-storage';

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
      } catch (error) {
        console.error('Failed to restore navigation state:', error);
      } finally {
        setIsReady(true);
      }
    };

    restoreState();
  }, []);

  const onStateChange = async (state: any) => {
    try {
      await AsyncStorage.setItem(NAVIGATION_STATE_KEY, JSON.stringify(state));
    } catch (error) {
      console.error('Failed to save navigation state:', error);
    }
  };

  if (!isReady) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer
      initialState={initialState}
      onStateChange={onStateChange}
      fallback={<LoadingScreen />}
    >
      <RootNavigator />
    </NavigationContainer>
  );
}

// 2. Navigation State Hook
import { useNavigationState } from '@react-navigation/native';

function useCurrentRoute() {
  const state = useNavigationState(state => state);
  
  // Get current route
  const currentRoute = state?.routes[state.index];
  return currentRoute;
}

function usePreviousRoute() {
  const state = useNavigationState(state => state);
  
  // Get previous route
  const routes = state?.routes || [];
  const previousRoute = routes.length > 1 ? routes[routes.length - 2] : null;
  return previousRoute;
}

// 3. Navigation Stack Tracking
function useNavigationHistory() {
  const [history, setHistory] = useState<string[]>([]);
  const state = useNavigationState(state => state);

  useEffect(() => {
    if (state) {
      const currentRoute = state.routes[state.index];
      const routeName = currentRoute.name;
      
      setHistory(prev => {
        // Avoid duplicate consecutive entries
        if (prev[prev.length - 1] === routeName) {
          return prev;
        }
        return [...prev, routeName];
      });
    }
  }, [state]);

  const getPreviousScreen = () => {
    return history[history.length - 2] || null;
  };

  const getScreenCount = (screenName: string) => {
    return history.filter(name => name === screenName).length;
  };

  return { history, getPreviousScreen, getScreenCount };
}
```

---

## N.5 Navigation with React Native Web

### The Concept: Web Support

React Navigation supports web with browser-style navigation.

### Complete Web Navigation Guide

```typescript
// 1. Web Configuration
// app.json
{
  "expo": {
    "web": {
      "favicon": "./assets/favicon.png"
    }
  }
}

// 2. Web-Specific Navigation
import { Platform } from 'react-native';

function WebNavigationBar() {
  if (Platform.OS !== 'web') {
    return null;
  }
  
  return (
    <View style={styles.webBar}>
      <Button title="Home" onPress={() => navigate('Home')} />
      <Button title="Profile" onPress={() => navigate('Profile')} />
    </View>
  );
}

// 3. Use Browser Router
import { BrowserRouter } from 'react-router-dom';

function WebApp() {
  return (
    <BrowserRouter>
      <NavigationContainer>
        <RootNavigator />
      </NavigationContainer>
    </BrowserRouter>
  );
}

// 4. Web Navigation Configuration
const webLinking = {
  prefixes: ['https://nexuscollect.com'],
  config: {
    screens: {
      Home: '/',
      Profile: '/profile/:userId',
      Settings: '/settings',
      CollectionDetail: '/collection/:id',
      FormEntry: '/form/:formId',
    },
  },
};

function App() {
  return (
    <NavigationContainer
      linking={Platform.OS === 'web' ? webLinking : linking}
      documentTitle={{
        formatter: (options) => {
          const title = options?.title || 'NexusCollect';
          return `NexusCollect - ${title}`;
        },
      }}
    >
      <RootNavigator />
    </NavigationContainer>
  );
}
```

---

## N.6 TypeScript Navigation Types

### The Concept: Type-Safe Navigation

Ensure navigation is type-safe with TypeScript.

### Complete TypeScript Navigation Guide

```typescript
// 1. Define Navigation Types
// src/types/navigation.ts
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { CompositeNavigationProp } from '@react-navigation/native';
import { RouteProp } from '@react-navigation/native';

// Auth Stack
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

// Main Stack
export type MainStackParamList = {
  MainTabs: undefined;
  CollectionDetail: { id: string };
  FormEntry: { formId: string; entryId?: string };
  Profile: { userId?: string };
};

// Main Tabs
export type MainTabParamList = {
  Home: undefined;
  Collections: undefined;
  Settings: undefined;
};

// Root Stack
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  Splash: undefined;
};

// Navigation Props
export type AuthScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList>;
export type MainScreenNavigationProp = CompositeNavigationProp<
  NativeStackNavigationProp<MainStackParamList>,
  BottomTabNavigationProp<MainTabParamList>
>;

// Route Props
export type CollectionDetailRouteProp = RouteProp<MainStackParamList, 'CollectionDetail'>;
export type FormEntryRouteProp = RouteProp<MainStackParamList, 'FormEntry'>;

// 2. Use Navigation with Types
import { useNavigation, useRoute } from '@react-navigation/native';
import { MainScreenNavigationProp } from '@types/navigation';

function HomeScreen() {
  const navigation = useNavigation<MainScreenNavigationProp>();
  
  const handlePress = () => {
    navigation.navigate('CollectionDetail', { id: '123' });
    // navigation.navigate('NonExistent'); ❌ Type error
  };
  
  return <Button title="View Collection" onPress={handlePress} />;
}

// 3. Use Route with Types
function CollectionDetailScreen() {
  const route = useRoute<CollectionDetailRouteProp>();
  const { id } = route.params; // TypeScript knows it's string
  
  return <Text>Collection ID: {id}</Text>;
}

// 4. Navigation Hook with Type Safety
export const useRootNavigation = () => {
  return useNavigation<StackNavigationProp<RootStackParamList>>();
};

export const useMainNavigation = () => {
  return useNavigation<NativeStackNavigationProp<MainStackParamList>>();
};

// 5. Navigate with Params
interface NavigationParams {
  CollectionDetail: { id: string; title?: string };
  FormEntry: { formId: string; entryId?: string };
}

export const navigateTo = <T extends keyof NavigationParams>(
  screen: T,
  params: NavigationParams[T]
) => {
  // Implementation
};
```

---

## N.7 Quick Reference

### Navigation Commands

```bash
# Install Navigation
npm install @react-navigation/native @react-navigation/native-stack
npm install @react-navigation/bottom-tabs @react-navigation/drawer
npm install react-native-screens react-native-safe-area-context

# iOS
cd ios && pod install && cd ..

# Types
npm install -D @types/react-navigation
```

### Deep Linking Examples

| URL | Screen | Params |
|-----|--------|--------|
| `nexuscollect://collection/123` | CollectionDetail | { id: '123' } |
| `nexuscollect://profile/user-456` | Profile | { userId: '456' } |
| `nexuscollect://form/789/entry/101` | FormEntry | { formId: '789', entryId: '101' } |
| `nexuscollect://login` | Login | {} |
| `nexuscollect://home` | Home | {} |

### Common Navigation Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `Cannot read property 'navigate'` | Navigation not ready | Check navigation ref |
| Screen not updating | Params not watched | Use useEffect with params |
| Deep link not working | Incorrect config | Check app.json and linking |
| Navigation state lost | Not persisted | Use AsyncStorage |
| Header missing | headerShown false | Set headerShown true |

---

**Ready to master navigation? Let's build NexusCollect!**
