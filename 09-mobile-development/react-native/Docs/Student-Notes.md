# React Native: From Blueprint to Production
## Student Notes - Complete Course Companion

---

# STUDENT NOTES

## Mobile Development with React Native: From Blueprint to Production

---

**Student Name:** _______________________

**Course Dates:** _______________________

**Instructor:** _______________________

---

## Table of Contents

| Part | Topic | Page |
|------|-------|------|
| 0 | Introduction & Mental Model | 3 |
| 1 | Foundations & Environment | 8 |
| 2 | State Management & Persistence | 16 |
| 3 | Device Capabilities & Native Features | 24 |
| 4 | Testing, Performance & Deployment | 32 |
| | Reference & Cheat Sheets | 40 |

---

# PART 0: INTRODUCTION

## The Mental Model Shift

### What is React Native?

**Definition:** React Native is a framework for building native mobile apps using React and JavaScript.

**Key Insight:** React Native is NOT a webview. It renders REAL native components.

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOW REACT NATIVE WORKS                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Your React Code         Bridge            Native UI           │
│  ┌─────────────┐        ┌─────────┐      ┌──────────────┐    │
│  │ <View>      │───────▶│  JSON   │──────▶│ UIView (iOS)  │    │
│  │   <Text>    │        │ Serial- │      │ ViewGroup    │    │
│  │   Hello     │        │ ization │      │ (Android)    │    │
│  │   </Text>   │        └─────────┘      └──────────────┘    │
│  │ </View>     │                                             │
│  └─────────────┘                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The Three Threads

| Thread | Purpose | What Blocks It |
|--------|---------|----------------|
| **JavaScript** | Runs React code, business logic | Heavy JS computation |
| **UI Thread** | Renders pixels, handles input | Bridge traffic, layout |
| **Shadow Thread** | Calculates layouts | Complex layout work |

### The Bridge

**What it is:** Communication channel between JavaScript and Native code.

**Key Characteristics:**
- Asynchronous (non-blocking)
- Serializes data to JSON
- Has performance cost

**Why it matters:** Too much bridge traffic = poor performance.

### React Native vs Alternatives

| Feature | React Native | Flutter | Webview (Cordova) | Native (Swift/Kotlin) |
|---------|--------------|---------|-------------------|----------------------|
| Performance | Near-native | Native | Poor | Best |
| Code Reuse | High | High | High | Low |
| Learning Curve | Moderate | Steep | Easy | Steep |
| Ecosystem | Large | Growing | Large | Platform-specific |

### Key Mindset Shifts

1. **Think in Components** (not pages)
2. **Think Native-First** (not web-first)
3. **Think Performance** (60fps, 16.67ms/frame)
4. **Think Offline-First** (app works without internet)
5. **Think Accessibility** (all users can use your app)

---

# PART 1: FOUNDATIONS & ENVIRONMENT

## Development Environment Setup

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 18+ | JavaScript runtime |
| npm/yarn | Latest | Package management |
| Git | Latest | Version control |
| Xcode | Latest | iOS development (Mac only) |
| Android Studio | Latest | Android development |

### Expo vs Bare React Native

| Aspect | Expo | Bare React Native |
|--------|------|-------------------|
| Setup | Easy, one command | Complex, manual |
| Custom Native Modules | Limited | Full access |
| App Size | Larger | Smaller |
| Development Speed | Fast | Moderate |
| Best For | Beginners, rapid dev | Production, custom needs |

### Project Creation

```bash
# Expo (Recommended for beginners)
npx create-expo-app TaskFlow --template

# Bare React Native
npx react-native init TaskFlow --template react-native-template-typescript
```

### Project Structure

```
TaskFlow/
├── .expo/              # Expo configuration
├── .gitignore          # Git ignore file
├── App.tsx             # Root component
├── app.json            # App configuration
├── assets/             # Images, fonts
├── babel.config.js     # Babel config
├── package.json        # Dependencies
├── tsconfig.json       # TypeScript config
└── node_modules/       # Installed packages
```

### Running the App

```bash
# Start development server
npm start

# iOS Simulator
npm run ios
# or press 'i' in terminal

# Android Emulator
npm run android
# or press 'a' in terminal

# Physical Device
# Scan QR code with Expo Go app
```

---

## Core Components & Styling

### Essential Components

| Component | Purpose | Example |
|-----------|---------|---------|
| **View** | Container (like div) | `<View style={styles.container}>` |
| **Text** | Display text | `<Text>Hello</Text>` |
| **SafeAreaView** | Handle notches | `<SafeAreaView>` |
| **ScrollView** | Scrollable content | `<ScrollView>` |
| **FlatList** | Optimized lists | `<FlatList data={...} />` |
| **TouchableOpacity** | Pressable | `<TouchableOpacity>` |
| **TextInput** | Text input | `<TextInput />` |
| **Image** | Display images | `<Image source={...} />` |

### StyleSheet System

```tsx
const styles = StyleSheet.create({
  container: {
    flex: 1,                    // Fill available space
    backgroundColor: '#fff',    // Background color
    padding: 20,               // Padding
    alignItems: 'center',      // Cross-axis alignment
    justifyContent: 'center',  // Main-axis alignment
  },
  text: {
    fontSize: 16,
    color: '#333',
    fontWeight: 'bold',
  },
});
```

### Platform-Specific Styling

```tsx
import { Platform } from 'react-native';

const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 24,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
      },
      android: {
        elevation: 4,
      },
    }),
  },
});
```

### Responsive Design

```tsx
import { Dimensions } from 'react-native';

const { width, height } = Dimensions.get('window');

// Scale based on screen size
const scale = width / 375; // Based on iPhone SE

const responsiveSize = (size) => size * scale;
```

---

## Flexbox Mastery

### Flexbox Mental Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLEXBOX AXES                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  flexDirection: 'row'                                          │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                                                             ││
│  │  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐             ││
│  │  │       │  │       │  │       │  │       │             ││
│  │  └───────┘  └───────┘  └───────┘  └───────┘             ││
│  │  ←───────────────── Main Axis ─────────────────────────→   ││
│  │                                                             ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
│  flexDirection: 'column'                                       │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    ┌───────┐                               ││
│  │                    │       │                               ││
│  │                    └───────┘                               ││
│  │  Cross Axis →      ┌───────┐                               ││
│  │                    │       │                               ││
│  │                    └───────┘                               ││
│  │                    ┌───────┐                               ││
│  │                    │       │                               ││
│  │                    └───────┘                               ││
│  │                         ↓ Main Axis                        ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Flexbox Properties Quick Reference

| Property | Values | Effect |
|----------|--------|--------|
| **flexDirection** | row, column, row-reverse, column-reverse | Direction of main axis |
| **justifyContent** | flex-start, center, flex-end, space-between, space-around, space-evenly | Alignment along main axis |
| **alignItems** | flex-start, center, flex-end, stretch | Alignment along cross axis |
| **flex** | number | Grow/shrink factor |
| **flexWrap** | wrap, nowrap | Allow wrapping to next line |
| **alignSelf** | auto, flex-start, center, flex-end, stretch | Override alignItems for single item |
| **position** | relative, absolute | Positioning mode |

### Common Layout Patterns

#### Centering Content
```tsx
container: {
  flex: 1,
  justifyContent: 'center',
  alignItems: 'center',
}
```

#### Two Column Layout
```tsx
container: {
  flexDirection: 'row',
}
left: {
  flex: 1,
}
right: {
  flex: 1,
}
```

#### Stack Layout (Column)
```tsx
container: {
  flexDirection: 'column',
}
item: {
  marginVertical: 8,
}
```

#### Full-Screen Background
```tsx
container: {
  flex: 1,
  width: '100%',
  height: '100%',
}
```

---

## Navigation

### Navigation Types

```
┌─────────────────────────────────────────────────────────────────┐
│                    NAVIGATION TYPES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Stack Navigation               Tab Navigation                │
│  ┌───────────────────┐         ┌───────────────────────────┐ │
│  │                   │         │  Home  │ Tasks │ Profile  │ │
│  │   Screen 3        │         │                         │ │
│  │   (Detail)        │         │                         │ │
│  │                   │         │                         │ │
│  ├───────────────────┤         │                         │ │
│  │   Screen 2        │         │                         │ │
│  │   (List)          │         │                         │ │
│  ├───────────────────┤         │                         │ │
│  │   Screen 1        │         │                         │ │
│  │   (Home)          │         │                         │ │
│  └───────────────────┘         └───────────────────────────┘ │
│                                                                 │
│  Drawer Navigation              Authentication Flow            │
│  ┌───────────────────┐         ┌───────────────────────────┐ │
│  │  ┌────────────┐    │         │                           │ │
│  │  │  Home      │    │         │   Login  ──┐             │ │
│  │  │  Profile   │    │         │            │             │ │
│  │  │  Settings  │    │         │   Register─┘             │ │
│  │  │  Help      │    │         │            │             │ │
│  │  │  Logout    │    │         │            ▼             │ │
│  │  └────────────┘    │         │        Main App          │ │
│  └───────────────────┘         │                           │ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Installation

```bash
# Core navigation
npm install @react-navigation/native
npm install react-native-screens react-native-safe-area-context

# Stack navigation
npm install @react-navigation/stack
npm install react-native-gesture-handler

# Tab navigation
npm install @react-navigation/bottom-tabs

# Drawer navigation
npm install @react-navigation/drawer
```

### Stack Navigator

```tsx
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator<RootStackParamList>();

<Stack.Navigator>
  <Stack.Screen 
    name="Home" 
    component={HomeScreen}
    options={{ title: 'Home' }}
  />
  <Stack.Screen 
    name="Detail" 
    component={DetailScreen}
    options={{ title: 'Details' }}
  />
</Stack.Navigator>

// Navigation with params
navigation.navigate('Detail', { id: '123' });

// Type-safe params
type RootStackParamList = {
  Home: undefined;
  Detail: { id: string };
};
```

### Tab Navigator

```tsx
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

const Tab = createBottomTabNavigator<MainTabParamList>();

<Tab.Navigator>
  <Tab.Screen 
    name="Home" 
    component={HomeScreen}
    options={{
      tabBarIcon: ({ color }) => <Icon name="home" color={color} />,
      tabBarLabel: 'Home',
    }}
  />
  <Tab.Screen 
    name="Tasks" 
    component={TasksScreen}
    options={{
      tabBarIcon: ({ color }) => <Icon name="tasks" color={color} />,
      tabBarBadge: 3,  // Notification count
    }}
  />
</Tab.Navigator>
```

### Drawer Navigator

```tsx
import { createDrawerNavigator } from '@react-navigation/drawer';

const Drawer = createDrawerNavigator();

<Drawer.Navigator
  drawerContent={(props) => <CustomDrawer {...props} />}
  screenOptions={{
    drawerStyle: { width: 280 },
    drawerType: 'slide',
  }}
>
  <Drawer.Screen name="Main" component={MainTabs} />
  <Drawer.Screen name="Settings" component={SettingsScreen} />
  <Drawer.Screen name="Help" component={HelpScreen} />
</Drawer.Navigator>
```

### Navigation Best Practices

1. **Keep navigation tree shallow** - Deep nesting hurts performance
2. **Use TypeScript for type safety** - Prevent navigation errors
3. **Implement deep linking** - Allow external navigation to screens
4. **Persist navigation state** - Restore user's last screen
5. **Use navigation guards** - Protect authenticated routes

---

# PART 2: STATE MANAGEMENT & PERSISTENCE

## Local State

### useState

```tsx
// Basic usage
const [count, setCount] = useState(0);

// Functional update
setCount(prev => prev + 1);

// Object state
const [user, setUser] = useState({ name: '', age: 0 });
setUser(prev => ({ ...prev, name: 'John' }));

// Lazy initialization
const [data, setData] = useState(() => expensiveComputation());
```

### useEffect

```tsx
// Run once on mount
useEffect(() => {
  fetchData();
}, []);

// Run on dependency change
useEffect(() => {
  console.log('Count changed:', count);
}, [count]);

// Cleanup on unmount
useEffect(() => {
  const subscription = subscribe();
  return () => {
    subscription.unsubscribe();
  };
}, []);
```

### useMemo & useCallback

```tsx
// Memoize expensive computation
const expensiveValue = useMemo(() => {
  return heavyComputation(data);
}, [data]);

// Memoize function
const handlePress = useCallback(() => {
  doSomething(id);
}, [id]);
```

### Custom Hooks

```tsx
// useDebounce
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);
  
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  
  return debouncedValue;
}

// useApi
function useApi<T>(apiFunction: () => Promise<T>) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  
  const execute = useCallback(async () => {
    setLoading(true);
    try {
      const result = await apiFunction();
      setData(result);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setLoading(false);
    }
  }, [apiFunction]);
  
  return { data, loading, error, execute };
}
```

---

## Global State with Zustand

### Why Zustand?

| Feature | Zustand | Redux |
|---------|---------|-------|
| Boilerplate | Minimal | Heavy |
| Learning Curve | Low | Steep |
| Performance | Excellent | Good |
| TypeScript | Excellent | Good |
| Bundle Size | Small | Large |

### Basic Store

```tsx
import { create } from 'zustand';

interface StoreState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

const useStore = create<StoreState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));

// Usage
const { count, increment } = useStore();
```

### Async Actions

```tsx
interface TaskStore {
  tasks: Task[];
  isLoading: boolean;
  fetchTasks: () => Promise<void>;
  addTask: (task: Task) => void;
}

const useTaskStore = create<TaskStore>((set, get) => ({
  tasks: [],
  isLoading: false,
  
  fetchTasks: async () => {
    set({ isLoading: true });
    try {
      const tasks = await api.getTasks();
      set({ tasks, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
      throw error;
    }
  },
  
  addTask: (task) => {
    set((state) => ({ tasks: [task, ...state.tasks] }));
  },
}));
```

### Store Persistence

```tsx
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      login: (user, token) => set({ user, token }),
      logout: () => set({ user: null, token: null }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

### Store Selectors

```tsx
// Optimize re-renders
const user = useAuthStore((state) => state.user);
const isAuthenticated = useAuthStore((state) => state.isAuthenticated);

// Derived state
const completedTasks = useTaskStore((state) => 
  state.tasks.filter(task => task.status === 'done')
);
```

---

## Data Persistence

### Storage Options

| Storage | Type | Speed | Use Case |
|---------|------|-------|----------|
| AsyncStorage | Key-Value | Slow | Settings, simple data |
| MMKV | Key-Value | Very Fast | Caching, performance-critical |
| SQLite | Relational | Moderate | Complex data, queries |
| SecureStore | Encrypted | Slow | Tokens, sensitive data |

### AsyncStorage

```tsx
import AsyncStorage from '@react-native-async-storage/async-storage';

// Save
await AsyncStorage.setItem('@key', JSON.stringify(value));

// Load
const value = await AsyncStorage.getItem('@key');
const parsed = value ? JSON.parse(value) : null;

// Remove
await AsyncStorage.removeItem('@key');

// Multiple operations
await AsyncStorage.multiSet([
  ['@key1', 'value1'],
  ['@key2', 'value2'],
]);

const results = await AsyncStorage.multiGet(['@key1', '@key2']);
```

### MMKV

```tsx
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

// Save
storage.set('key', 'value');
storage.set('number', 42);
storage.set('boolean', true);
storage.set('object', JSON.stringify({ foo: 'bar' }));

// Load
const value = storage.getString('key');
const number = storage.getNumber('number');
const boolean = storage.getBoolean('boolean');
const object = JSON.parse(storage.getString('object') || '{}');

// Delete
storage.delete('key');

// Clear all
storage.clearAll();
```

### SQLite

```tsx
import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabaseSync('taskflow.db');

// Create table
await db.execAsync(`
  CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL,
    created_at TEXT NOT NULL
  )
`);

// Insert
await db.execAsync(
  'INSERT INTO tasks (id, title, description, status, created_at) VALUES (?, ?, ?, ?, ?)',
  [id, title, description, status, new Date().toISOString()]
);

// Query
const tasks = await db.execAsync('SELECT * FROM tasks ORDER BY created_at DESC');

// Update
await db.execAsync(
  'UPDATE tasks SET status = ? WHERE id = ?',
  [status, id]
);

// Delete
await db.execAsync('DELETE FROM tasks WHERE id = ?', [id]);
```

---

## Offline-First Architecture

### Principles

1. **Local First**: Always read from and write to local storage first
2. **Sync Later**: Sync with server when connectivity is available
3. **Optimistic UI**: Update UI immediately, rollback on failure
4. **Conflict Resolution**: Handle conflicts when data diverges

### Sync Engine

```tsx
interface SyncOperation {
  id: string;
  type: 'create' | 'update' | 'delete';
  entity: string;
  data: any;
  status: 'pending' | 'synced' | 'failed';
  retries: number;
}

class SyncEngine {
  private queue: SyncOperation[] = [];
  private isOnline: boolean = true;
  
  enqueue(operation: Omit<SyncOperation, 'id' | 'status' | 'retries'>) {
    this.queue.push({
      ...operation,
      id: generateId(),
      status: 'pending',
      retries: 0,
    });
    this.saveQueue();
    this.sync();
  }
  
  async sync() {
    if (!this.isOnline || this.queue.length === 0) return;
    
    const pending = this.queue.filter(op => op.status === 'pending');
    for (const operation of pending) {
      try {
        await this.processOperation(operation);
        operation.status = 'synced';
      } catch (error) {
        operation.status = 'failed';
        operation.retries++;
        if (operation.retries < 5) {
          // Retry with backoff
          setTimeout(() => {
            operation.status = 'pending';
            this.sync();
          }, 1000 * Math.pow(2, operation.retries));
        }
      }
    }
    this.saveQueue();
  }
}
```

### Optimistic UI

```tsx
const updateTask = async (id: string, data: Partial<Task>) => {
  // 1. Update UI immediately
  useTaskStore.getState().updateTask(id, data);
  
  // 2. Queue sync
  syncEngine.enqueue({
    type: 'update',
    entity: 'task',
    data: { id, ...data },
  });
  
  // 3. Rollback on failure
  try {
    await api.updateTask(id, data);
  } catch (error) {
    // Rollback to original state
    const original = await storage.get(`task_${id}`);
    useTaskStore.getState().updateTask(id, original);
  }
};
```

---

# PART 3: DEVICE CAPABILITIES

## Camera & Photos

### Installation

```bash
npx expo install expo-camera expo-image-picker
```

### Camera Permissions

```tsx
import { Camera } from 'expo-camera';

const requestPermissions = async () => {
  const { status } = await Camera.requestCameraPermissionsAsync();
  if (status === 'granted') {
    // Camera ready
  } else {
    // Show explanation
  }
};
```

### Camera Component

```tsx
import { Camera } from 'expo-camera';

function CameraScreen() {
  const [cameraRef, setCameraRef] = useState<Camera | null>(null);
  const [hasPermission, setHasPermission] = useState(false);
  
  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);
  
  const takePicture = async () => {
    if (cameraRef) {
      const photo = await cameraRef.takePictureAsync({
        quality: 0.8,
        base64: true,
      });
      // Use photo
    }
  };
  
  if (!hasPermission) {
    return <Text>No camera access</Text>;
  }
  
  return (
    <Camera
      ref={setCameraRef}
      style={styles.camera}
      type={Camera.Constants.Type.back}
    >
      <TouchableOpacity onPress={takePicture}>
        <Text>Take Photo</Text>
      </TouchableOpacity>
    </Camera>
  );
}
```

### Image Picker

```tsx
import * as ImagePicker from 'expo-image-picker';

const pickImage = async () => {
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ImagePicker.MediaTypeOptions.Images,
    allowsEditing: true,
    aspect: [4, 3],
    quality: 0.8,
  });
  
  if (!result.canceled) {
    const uri = result.assets[0].uri;
    // Use image
  }
};
```

### Image Optimization

```tsx
import * as ImageManipulator from 'expo-image-manipulator';

const optimizeImage = async (uri: string) => {
  const result = await ImageManipulator.manipulateAsync(
    uri,
    [
      {
        resize: {
          width: 1200,
          height: 1200,
        },
      },
    ],
    {
      compress: 0.7,
      format: ImageManipulator.SaveFormat.JPEG,
    }
  );
  return result.uri;
};
```

---

## Geolocation

### Installation

```bash
npx expo install expo-location
```

### Location Permissions

```tsx
import * as Location from 'expo-location';

const requestPermissions = async () => {
  const { status } = await Location.requestForegroundPermissionsAsync();
  if (status === 'granted') {
    // Location ready
  }
};
```

### Get Current Location

```tsx
const getLocation = async () => {
  const location = await Location.getCurrentPositionAsync({
    accuracy: Location.Accuracy.Balanced,
    timeout: 10000,
  });
  
  return {
    latitude: location.coords.latitude,
    longitude: location.coords.longitude,
  };
};
```

### Reverse Geocoding

```tsx
const getAddress = async (latitude: number, longitude: number) => {
  const results = await Location.reverseGeocodeAsync({
    latitude,
    longitude,
  });
  
  if (results.length > 0) {
    return results[0];
  }
  return null;
};
```

---

## Push Notifications

### Installation

```bash
npx expo install expo-notifications
```

### Request Permissions

```tsx
import * as Notifications from 'expo-notifications';

const requestPermissions = async () => {
  const { status } = await Notifications.requestPermissionsAsync();
  return status === 'granted';
};
```

### Get Push Token

```tsx
const getPushToken = async () => {
  const token = await Notifications.getExpoPushTokenAsync({
    projectId: 'your-project-id',
  });
  return token.data;
};
```

### Send Notification

```tsx
const sendNotification = async (title: string, body: string, data?: any) => {
  await Notifications.scheduleNotificationAsync({
    content: {
      title,
      body,
      data: data || {},
      sound: true,
    },
    trigger: null, // Send immediately
  });
};
```

### Schedule Notification

```tsx
const scheduleNotification = async (
  title: string,
  body: string,
  date: Date,
  data?: any
) => {
  await Notifications.scheduleNotificationAsync({
    content: {
      title,
      body,
      data: data || {},
    },
    trigger: {
      date,
    },
  });
};
```

### Handle Notification Taps

```tsx
Notifications.addNotificationResponseReceivedListener((response) => {
  const data = response.notification.request.content.data;
  // Navigate based on data
});
```

---

## Gestures & Animations

### Installation

```bash
npx expo install react-native-gesture-handler react-native-reanimated
```

### Gesture Handler Basics

```tsx
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, { useSharedValue, useAnimatedStyle } from 'react-native-reanimated';

function DraggableBox() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX;
      translateY.value = event.translationY;
    })
    .onEnd(() => {
      translateX.value = withSpring(0);
      translateY.value = withSpring(0);
    });
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }));
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

### Swipe-to-Delete

```tsx
function SwipeableItem({ onDelete }: { onDelete: () => void }) {
  const translateX = useSharedValue(0);
  const THRESHOLD = -100;
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = Math.min(0, event.translationX);
    })
    .onEnd((event) => {
      if (translateX.value < THRESHOLD) {
        translateX.value = withTiming(-300);
        onDelete();
      } else {
        translateX.value = withSpring(0);
      }
    });
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }));
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={animatedStyle}>
        {/* Item content */}
      </Animated.View>
    </GestureDetector>
  );
}
```

### Pull-to-Refresh

```tsx
function PullToRefresh({ onRefresh, children }: { onRefresh: () => Promise<void>, children: React.ReactNode }) {
  const translateY = useSharedValue(0);
  const isRefreshing = useSharedValue(false);
  const THRESHOLD = 80;
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      if (event.translationY > 0 && !isRefreshing.value) {
        translateY.value = Math.min(event.translationY, 150);
      }
    })
    .onEnd(async (event) => {
      if (translateY.value > THRESHOLD) {
        isRefreshing.value = true;
        await onRefresh();
        isRefreshing.value = false;
      }
      translateY.value = withSpring(0);
    });
  
  // ... render
}
```

---

# PART 4: TESTING & DEPLOYMENT

## Testing

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!(jest-)?react-native|@react-native|expo)',
  ],
};
```

### Unit Testing

```tsx
// Utility test
describe('validateEmail', () => {
  it('returns true for valid emails', () => {
    expect(validateEmail('test@example.com')).toBe(true);
  });
  
  it('returns false for invalid emails', () => {
    expect(validateEmail('invalid')).toBe(false);
  });
});
```

### Component Testing

```tsx
import { render, fireEvent } from '@testing-library/react-native';

describe('TaskCard', () => {
  it('renders task title', () => {
    const { getByText } = render(
      <TaskCard title="Test Task" onPress={jest.fn()} />
    );
    expect(getByText('Test Task')).toBeTruthy();
  });
  
  it('calls onPress when tapped', () => {
    const onPress = jest.fn();
    const { getByTestId } = render(
      <TaskCard title="Test" onPress={onPress} />
    );
    fireEvent.press(getByTestId('task-card'));
    expect(onPress).toHaveBeenCalled();
  });
});
```

### Store Testing

```tsx
import { act, renderHook } from '@testing-library/react-hooks';

describe('useTaskStore', () => {
  it('adds task correctly', () => {
    const { result } = renderHook(() => useTaskStore());
    
    act(() => {
      result.current.addTask({ id: '1', title: 'Test' });
    });
    
    expect(result.current.tasks).toHaveLength(1);
    expect(result.current.tasks[0].title).toBe('Test');
  });
});
```

### E2E Testing with Detox

```javascript
// e2e/taskFlow.e2e.js
describe('TaskFlow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });
  
  it('should login and create a task', async () => {
    await element(by.id('email-input')).typeText('demo@example.com');
    await element(by.id('password-input')).typeText('password');
    await element(by.id('login-button')).tap();
    
    await expect(element(by.id('home-screen'))).toBeVisible();
    
    await element(by.id('add-task-button')).tap();
    await element(by.id('task-title-input')).typeText('E2E Test');
    await element(by.id('save-task-button')).tap();
    
    await expect(element(by.text('E2E Test'))).toBeVisible();
  });
});
```

---

## Performance Optimization

### Performance Targets

- **FPS**: 60 (16.67ms/frame)
- **App Startup**: < 2 seconds
- **Memory**: < 50MB
- **Bundle Size**: < 15MB

### Optimization Strategies

| Issue | Solution |
|-------|----------|
| Slow renders | Use memo, useMemo, useCallback |
| Large lists | FlatList with getItemLayout |
| Heavy JS | Offload to native |
| Bridge traffic | Batch updates |
| Bundle size | Lazy loading, tree shaking |
| Images | Optimize size and format |

### FlatList Optimization

```tsx
<FlatList
  data={data}
  renderItem={renderItem}
  keyExtractor={keyExtractor}
  // Optimizations
  removeClippedSubviews={Platform.OS === 'android'}
  maxToRenderPerBatch={10}
  updateCellsBatchingPeriod={50}
  windowSize={10}
  initialNumToRender={20}
  getItemLayout={(data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  })}
/>
```

### Bundle Optimization

```tsx
// Lazy loading
const TaskDetailScreen = lazy(() => import('./screens/TaskDetailScreen'));

// Dynamic import
const loadModule = () => import('heavy-module');

// Webpack optimization
// Configure tree shaking and code splitting in metro.config.js
```

---

## CI/CD & Deployment

### EAS Build Configuration

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "distribution": "store",
      "channel": "production"
    }
  }
}
```

### GitHub Actions

```yaml
name: CI/CD
on:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: eas build --platform all --profile production
  deploy:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v3
      - run: eas submit --platform ios
      - run: eas submit --platform android
```

### Code Signing

```bash
# iOS - EAS manages certificates
eas credentials --platform ios

# Android - Keystore
keytool -genkey -v -keystore app.keystore -alias app -keyalg RSA -keysize 2048 -validity 10000
```

### App Store Requirements

| Requirement | iOS | Android |
|-------------|-----|---------|
| App Icon | ✅ | ✅ |
| Splash Screen | ✅ | ✅ |
| Screenshots | 6.5", 5.5" | Phone, Tablet |
| App Description | ✅ | ✅ |
| Privacy Policy | ✅ | ✅ |
| Support URL | ✅ | ✅ |

---

# REFERENCE & CHEAT SHEETS

## Quick Reference Cards

### Navigation
```tsx
// Stack
navigation.push('Screen', { param: value })
navigation.pop()
navigation.popToTop()

// Tab
navigation.navigate('TabName')

// Drawer
navigation.openDrawer()
navigation.closeDrawer()
navigation.toggleDrawer()
```

### State Management
```tsx
// Zustand
const useStore = create((set) => ({
  value: 0,
  setValue: (v) => set({ value: v }),
}))

// Selector
const value = useStore((state) => state.value)
```

### AsyncStorage
```tsx
// Save
await AsyncStorage.setItem('key', JSON.stringify(value))

// Load
const value = JSON.parse(await AsyncStorage.getItem('key') || 'null')

// Delete
await AsyncStorage.removeItem('key')
```

### Flexbox
```tsx
flexDirection: 'row' | 'column'
justifyContent: 'center' | 'flex-start' | 'flex-end' | 'space-between'
alignItems: 'center' | 'flex-start' | 'flex-end' | 'stretch'
flex: number
flexWrap: 'wrap'
```

### Testing
```tsx
// Render
render(<Component />)

// Queries
getByText('text')
getByTestId('id')
getByLabelText('label')

// Events
fireEvent.press(element)
fireEvent.changeText(input, 'text')

// Assertions
expect(element).toBeTruthy()
expect(element).toBeNull()
```

---

## Common Errors & Solutions

| Error | Solution |
|-------|----------|
| `Cannot read property 'navigate' of undefined` | Ensure navigation prop is available or use useNavigation hook |
| `Text strings must be rendered within Text component` | Wrap text in `<Text>` component |
| `Invariant violation` | Check for proper navigation setup |
| `Module not found` | Check import paths and installed dependencies |
| `Bridge timeout` | Check for infinite loops or heavy operations |

---

## Useful Resources

### Documentation
- [React Native Docs](https://reactnative.dev/docs/getting-started)
- [Expo Docs](https://docs.expo.dev/)
- [React Navigation Docs](https://reactnavigation.org/docs/getting-started)
- [Zustand Docs](https://docs.pmnd.rs/zustand/getting-started/introduction)

### Libraries
- [React Native Elements](https://reactnativeelements.com/)
- [NativeBase](https://nativebase.io/)
- [React Native Paper](https://callstack.github.io/react-native-paper/)
- [React Native Vector Icons](https://github.com/oblador/react-native-vector-icons)

### Tools
- [React DevTools](https://reactnative.dev/docs/react-devtools)
- [Flipper](https://fbflipper.com/)
- [Expo Go](https://expo.dev/client)
- [EAS Build](https://expo.dev/eas)

---

## Final Checklist

### Before Deployment
- [ ] All tests passing
- [ ] Bundle size optimized
- [ ] App icon and splash screen ready
- [ ] Screenshots prepared
- [ ] Privacy policy available
- [ ] Support contact set up
- [ ] Code signing certificates valid
- [ ] App metadata complete

### During Deployment
- [ ] Build production version
- [ ] Test on physical devices
- [ ] Submit to app stores
- [ ] Monitor for issues
- [ ] Respond to user feedback

### After Deployment
- [ ] Monitor crash reports
- [ ] Track performance metrics
- [ ] Gather user feedback
- [ ] Plan next release

---

**End of Student Notes**

---

*These notes are designed to be a living document. Add your own notes, examples, and insights as you progress through the course.*

*Good luck with your React Native journey! 🚀*
