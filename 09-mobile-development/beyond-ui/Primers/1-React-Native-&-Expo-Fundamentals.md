# Primer 1: React Native & Expo Fundamentals

## Your Quick-Start Guide to Mobile Development

Welcome to the NexusCollect Primer! This guide is designed to give you a solid foundation in React Native and Expo before diving into the main tutorial series. Think of this as your "boot camp" - we'll cover all the essential concepts you need to understand, with practical examples you can run immediately.

---

## P.1 What is React Native?

### The Concept: Write Once, Run Anywhere

React Native is a framework that lets you build mobile apps using JavaScript and React. Instead of writing separate Swift (iOS) and Kotlin (Android) code, you write JavaScript/TypeScript once, and React Native translates it to native components for each platform.

**Simple Analogy:** Think of React Native as a universal translator. You speak one language (JavaScript/React), and it translates your words into the native language of each platform (Swift for iOS, Kotlin for Android). The result is an app that looks and feels native on both platforms.

### Key Concepts

```javascript
// 1. Components - The building blocks of your UI
const HelloWorld = () => {
  return (
    <View>
      <Text>Hello, World!</Text>
    </View>
  );
};

// 2. JSX - JavaScript XML - Allows you to write HTML-like code in JavaScript
// This:
const element = <Text>Hello</Text>;

// Is transformed to:
const element = React.createElement(Text, null, 'Hello');

// 3. Props - Properties passed to components
const Greeting = ({ name }) => {
  return <Text>Hello, {name}!</Text>;
};

// 4. State - Data that changes over time
const Counter = () => {
  const [count, setCount] = useState(0);
  return (
    <Button 
      title="Click me" 
      onPress={() => setCount(count + 1)}
    />
  );
};
```

---

## P.2 What is Expo?

### The Concept: The Easy Button for React Native

Expo is a platform and framework that makes React Native development significantly easier. It provides:
- **Pre-built components** for common features (camera, location, etc.)
- **Development tools** for fast iteration
- **Build services** (EAS) for deployment
- **OTA updates** for instant bug fixes

**Simple Analogy:** If React Native is a car, Expo is a luxury sedan that comes with all the features pre-installed. You don't need to worry about the engine (native code) - just drive!

### Expo vs React Native CLI

| Feature | Expo | React Native CLI |
|---------|------|------------------|
| Setup | ✅ 10 minutes | ❌ 2+ hours |
| Native Modules | ✅ Easy via plugins | ❌ Manual setup |
| Builds | ✅ EAS handles it | ❌ Manual configuration |
| Updates | ✅ OTA built-in | ❌ Manual implementation |
| Learning Curve | ✅ Gentle | ❌ Steep |
| Customization | ⚠️ Limited to plugins | ✅ Full control |

### Basic Expo Commands

```bash
# Create a new project
npx create-expo-app MyApp --template

# Start development server
npx expo start

# Run on iOS (requires Mac)
npx expo start --ios

# Run on Android
npx expo start --android

# Run on web
npx expo start --web

# Build for production
eas build --platform all
```

---

## P.3 React Native Core Components

### Essential Components You'll Use Daily

```javascript
// 1. View - Container component (like div in web)
import { View } from 'react-native';

<View style={styles.container}>
  {/* Content here */}
</View>

// 2. Text - Display text (like p or span in web)
import { Text } from 'react-native';

<Text style={styles.title}>Hello World</Text>

// 3. TextInput - Text input field (like input in web)
import { TextInput } from 'react-native';

<TextInput 
  style={styles.input}
  placeholder="Enter your name"
  onChangeText={handleChange}
  value={name}
/>

// 4. Button - Clickable button
import { Button } from 'react-native';

<Button 
  title="Submit"
  onPress={handleSubmit}
  color="#841584"
/>

// 5. Image - Display images
import { Image } from 'react-native';

<Image 
  source={{ uri: 'https://example.com/photo.jpg' }}
  style={{ width: 100, height: 100 }}
/>

// 6. ScrollView - Scrollable content
import { ScrollView } from 'react-native';

<ScrollView>
  <Text>Content 1</Text>
  <Text>Content 2</Text>
  <Text>Content 3</Text>
</ScrollView>

// 7. FlatList - Efficient list rendering
import { FlatList } from 'react-native';

<FlatList
  data={items}
  renderItem={({ item }) => <Text>{item.name}</Text>}
  keyExtractor={(item) => item.id}
/>
```

---

## P.4 Styling in React Native

### The Concept: CSS in JavaScript

React Native uses a StyleSheet API that looks like CSS but is actually JavaScript objects. Styles are scoped to the component and don't cascade globally.

### Complete Styling Guide

```javascript
import { StyleSheet, View, Text } from 'react-native';

// 1. Basic Styling - Create styles with StyleSheet
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#7f8c8d',
    lineHeight: 24,
  },
});

// 2. Flexbox Layout - Similar to CSS Flexbox
const FlexboxExample = () => (
  <View style={{ flex: 1 }}>
    {/* Row layout */}
    <View style={{ flexDirection: 'row' }}>
      <View style={{ flex: 1, backgroundColor: 'red' }} />
      <View style={{ flex: 2, backgroundColor: 'blue' }} />
    </View>
    
    {/* Column layout */}
    <View style={{ flexDirection: 'column' }}>
      <View style={{ flex: 1, backgroundColor: 'green' }} />
      <View style={{ flex: 1, backgroundColor: 'yellow' }} />
    </View>
  </View>
);

// 3. Conditional Styling
const ConditionStyleExample = ({ isActive }) => (
  <View style={[
    styles.baseStyle,
    isActive && styles.activeStyle,
    !isActive && styles.inactiveStyle,
  ]}>
    <Text>Conditional Style</Text>
  </View>
);

// 4. Platform-Specific Styles
import { Platform } from 'react-native';

const PlatformStyleExample = () => (
  <View style={{
    paddingTop: Platform.OS === 'ios' ? 40 : 20,
    backgroundColor: Platform.select({
      ios: '#f0f0f0',
      android: '#e0e0e0',
      default: '#ffffff',
    }),
  }}>
    <Text>Platform-specific styling</Text>
  </View>
);

// 5. Common Style Properties
const CommonStyles = {
  // Layout
  flex: 1,
  flexDirection: 'row',
  justifyContent: 'center',
  alignItems: 'center',
  alignSelf: 'center',
  
  // Dimensions
  width: 100,
  height: 100,
  maxWidth: '80%',
  minHeight: 50,
  
  // Spacing
  margin: 8,
  marginHorizontal: 16,
  marginVertical: 24,
  padding: 12,
  paddingTop: 20,
  
  // Border
  borderWidth: 1,
  borderColor: '#ddd',
  borderRadius: 8,
  borderTopWidth: 0,
  
  // Background
  backgroundColor: '#fff',
  
  // Shadow (iOS) / Elevation (Android)
  shadowColor: '#000',
  shadowOffset: { width: 0, height: 2 },
  shadowOpacity: 0.1,
  shadowRadius: 4,
  elevation: 3,
  
  // Text
  fontSize: 16,
  fontWeight: '600',
  color: '#333',
  textAlign: 'center',
  lineHeight: 24,
  letterSpacing: 0.5,
};
```

---

## P.5 Navigation Basics

### The Concept: Moving Between Screens

Navigation is how users move between different screens in your app. React Navigation is the standard library for this.

### Complete Navigation Guide

```javascript
// 1. Install React Navigation
// npm install @react-navigation/native @react-navigation/native-stack

// 2. Setup Navigation Container
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Details" component={DetailsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

// 3. Navigate Between Screens
function HomeScreen({ navigation }) {
  return (
    <View>
      <Text>Home Screen</Text>
      <Button
        title="Go to Details"
        onPress={() => navigation.navigate('Details', {
          itemId: 86,
          otherParam: 'anything you want here',
        })}
      />
    </View>
  );
}

function DetailsScreen({ route }) {
  // Access navigation parameters
  const { itemId, otherParam } = route.params;
  
  return (
    <View>
      <Text>Details Screen</Text>
      <Text>itemId: {itemId}</Text>
      <Text>otherParam: {otherParam}</Text>
    </View>
  );
}

// 4. Stack Navigation Options
<Stack.Navigator
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
        <Button
          onPress={() => alert('Menu pressed!')}
          title="Menu"
        />
      ),
    }}
  />
</Stack.Navigator>

// 5. Bottom Tab Navigation
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';

const Tab = createBottomTabNavigator();

function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;
          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'Settings') {
            iconName = focused ? 'settings' : 'settings-outline';
          }
          return <Ionicons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: 'tomato',
        tabBarInactiveTintColor: 'gray',
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
}
```

---

## P.6 State Management

### The Concept: Managing Data in Your App

State management is how you handle data that changes over time. In React Native, you have several options.

### Complete State Management Guide

```javascript
// 1. useState - Local component state
import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('John');
  const [user, setUser] = useState({
    name: 'John',
    age: 30,
    email: 'john@example.com'
  });

  return (
    <View>
      <Text>Count: {count}</Text>
      <Button title="Increment" onPress={() => setCount(count + 1)} />
      
      {/* Update object state */}
      <Button 
        title="Update Age" 
        onPress={() => setUser({ ...user, age: 31 })}
      />
    </View>
  );
}

// 2. useEffect - Handle side effects
import React, { useState, useEffect } from 'react';

function DataFetcher() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Runs after component mounts
    fetchData();
    
    // Cleanup function (runs when component unmounts)
    return () => {
      console.log('Component unmounted');
    };
  }, []); // Empty array = run once

  // Runs when dependencies change
  useEffect(() => {
    console.log('Data updated:', data);
  }, [data]);

  return (
    <View>
      {loading ? <Text>Loading...</Text> : <Text>{data}</Text>}
    </View>
  );
}

// 3. Context - Global state without prop drilling
import React, { createContext, useContext, useState } from 'react';

// Create context
const UserContext = createContext();

// Provider component
function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

// Consume context
function UserProfile() {
  const { user } = useContext(UserContext);
  return <Text>User: {user?.name}</Text>;
}

// 4. Zustand - Simple global state management
import { create } from 'zustand';

const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));

function CounterApp() {
  const { count, increment, decrement, reset } = useStore();
  
  return (
    <View>
      <Text>Count: {count}</Text>
      <Button title="+" onPress={increment} />
      <Button title="-" onPress={decrement} />
      <Button title="Reset" onPress={reset} />
    </View>
  );
}
```

---

## P.7 Handling User Input

### The Concept: Capturing User Data

Forms and input handling are essential for any app that collects data.

### Complete Input Handling Guide

```javascript
// 1. Basic Text Input
import { TextInput, View, Text } from 'react-native';
import { useState } from 'react';

function BasicInput() {
  const [text, setText] = useState('');
  
  return (
    <View>
      <TextInput
        style={{
          height: 40,
          borderColor: 'gray',
          borderWidth: 1,
          paddingHorizontal: 8,
        }}
        placeholder="Enter text"
        onChangeText={setText}
        value={text}
      />
      <Text>You typed: {text}</Text>
    </View>
  );
}

// 2. Complete Form Example
import { useState } from 'react';
import { View, Text, TextInput, Button, Alert } from 'react-native';

function LoginForm() {
  const [form, setForm] = useState({
    email: '',
    password: '',
    rememberMe: false,
  });
  const [errors, setErrors] = useState({});

  const validate = () => {
    const newErrors = {};
    if (!form.email) {
      newErrors.email = 'Email is required';
    } else if (!form.email.includes('@')) {
      newErrors.email = 'Invalid email format';
    }
    if (!form.password) {
      newErrors.password = 'Password is required';
    } else if (form.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = () => {
    if (validate()) {
      Alert.alert('Success', 'Login successful!');
    }
  };

  return (
    <View style={{ padding: 16 }}>
      <TextInput
        style={{
          borderWidth: 1,
          borderColor: errors.email ? 'red' : 'gray',
          padding: 12,
          marginBottom: 4,
        }}
        placeholder="Email"
        value={form.email}
        onChangeText={(text) => setForm({ ...form, email: text })}
      />
      {errors.email && (
        <Text style={{ color: 'red', marginBottom: 8 }}>{errors.email}</Text>
      )}

      <TextInput
        style={{
          borderWidth: 1,
          borderColor: errors.password ? 'red' : 'gray',
          padding: 12,
          marginBottom: 4,
        }}
        placeholder="Password"
        secureTextEntry
        value={form.password}
        onChangeText={(text) => setForm({ ...form, password: text })}
      />
      {errors.password && (
        <Text style={{ color: 'red', marginBottom: 8 }}>{errors.password}</Text>
      )}

      <Button title="Login" onPress={handleSubmit} />
    </View>
  );
}

// 3. Form Library - react-hook-form (recommended for complex forms)
import { useForm, Controller } from 'react-hook-form';

function FormWithLibrary() {
  const { control, handleSubmit, formState: { errors } } = useForm({
    defaultValues: {
      name: '',
      email: '',
    },
  });

  const onSubmit = (data) => {
    console.log(data);
  };

  return (
    <View>
      <Controller
        control={control}
        rules={{
          required: true,
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            placeholder="Name"
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name="name"
      />
      {errors.name && <Text>Name is required.</Text>}

      <Controller
        control={control}
        rules={{
          required: true,
          pattern: /^\S+@\S+$/i,
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            placeholder="Email"
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name="email"
      />
      {errors.email && <Text>Valid email is required.</Text>}

      <Button title="Submit" onPress={handleSubmit(onSubmit)} />
    </View>
  );
}
```

---

## P.8 Networking & APIs

### The Concept: Talking to the Cloud

Most apps need to fetch data from and send data to servers. Here's how to handle network requests.

### Complete Networking Guide

```javascript
// 1. Basic Fetch
const fetchData = async () => {
  try {
    const response = await fetch('https://api.example.com/data');
    const data = await response.json();
    console.log(data);
    return data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};

// 2. Complete API Service Example
import axios from 'axios';

// Create axios instance
const apiClient = axios.create({
  baseURL: 'https://api.example.com',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add authentication token
apiClient.interceptors.request.use(
  (config) => {
    const token = getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// API Service Class
class ApiService {
  // GET request
  static async get(endpoint, params = {}) {
    try {
      const response = await apiClient.get(endpoint, { params });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // POST request
  static async post(endpoint, data = {}) {
    try {
      const response = await apiClient.post(endpoint, data);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // PUT request
  static async put(endpoint, data = {}) {
    try {
      const response = await apiClient.put(endpoint, data);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // DELETE request
  static async delete(endpoint) {
    try {
      const response = await apiClient.delete(endpoint);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Error handler
  static handleError(error) {
    if (error.response) {
      // Server responded with error
      console.error('API Error:', error.response.data);
      return new Error(error.response.data.message || 'Server error');
    } else if (error.request) {
      // No response received
      console.error('Network Error:', error.request);
      return new Error('Network error - please check your connection');
    } else {
      // Request setup error
      console.error('Request Error:', error.message);
      return error;
    }
  }
}

// Usage
const fetchUsers = async () => {
  try {
    const users = await ApiService.get('/users', { limit: 10 });
    console.log('Users:', users);
  } catch (error) {
    console.error('Failed to fetch users:', error.message);
  }
};

// 3. React Query - Advanced Data Management
import { useQuery, useMutation, QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      {/* Your app */}
    </QueryClientProvider>
  );
}

function UserList() {
  // Fetch data with caching and refetching
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => ApiService.get('/users'),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });

  // Mutation for updating data
  const mutation = useMutation({
    mutationFn: (newUser) => ApiService.post('/users', newUser),
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });

  if (isLoading) return <Text>Loading...</Text>;
  if (error) return <Text>Error: {error.message}</Text>;

  return (
    <View>
      {data?.map(user => (
        <Text key={user.id}>{user.name}</Text>
      ))}
      <Button 
        title="Add User" 
        onPress={() => mutation.mutate({ name: 'New User' })}
      />
    </View>
  );
}
```

---

## P.9 Platform-Specific Code

### The Concept: Handling iOS and Android Differences

Sometimes you need different behavior for iOS and Android. Here's how to handle platform differences.

### Platform-Specific Guide

```javascript
import { Platform, PixelRatio } from 'react-native';

// 1. Platform Detection
const isIOS = Platform.OS === 'ios';
const isAndroid = Platform.OS === 'android';

// 2. Platform-Specific Styles
const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 24,
    backgroundColor: Platform.OS === 'ios' ? '#f8f8f8' : '#ffffff',
  },
});

// 3. Platform-Specific Components
const PlatformButton = () => {
  if (Platform.OS === 'ios') {
    return <ButtonIOS title="iOS Button" />;
  } else {
    return <ButtonAndroid title="Android Button" />;
  }
};

// 4. Platform-Specific Imports
import iOSComponent from './Component.ios';
import AndroidComponent from './Component.android';

// Or use:
const Component = Platform.select({
  ios: require('./Component.ios'),
  android: require('./Component.android'),
});

// 5. Platform-Specific Files
// Component.ios.js - iOS only
// Component.android.js - Android only
// Component.js - fallback

// 6. Platform-Specific Navigation
const HeaderHeight = Platform.select({
  ios: 44,
  android: 56,
  default: 44,
});

// 7. Platform-Specific Styles for Safe Area
import { SafeAreaView } from 'react-native-safe-area-context';

function App() {
  return (
    <SafeAreaView style={{ flex: 1 }}>
      {/* Your content */}
    </SafeAreaView>
  );
}

// 8. Platform-Specific Dimensions
import { Dimensions } from 'react-native';

const { width, height } = Dimensions.get('window');
const isSmallDevice = width < 375; // iPhone SE size

// 9. Platform-Specific Status Bar
import { StatusBar } from 'react-native';

<StatusBar
  barStyle={Platform.OS === 'ios' ? 'dark-content' : 'light-content'}
  backgroundColor={Platform.OS === 'android' ? '#2196F3' : undefined}
/>
```

---

## P.10 Common Patterns & Best Practices

### The Concept: Writing Clean, Maintainable Code

Learn the patterns and practices that professional React Native developers use.

### Best Practices Guide

```javascript
// 1. Component Organization
// components/
//   common/
//     Button.js
//     Input.js
//     Card.js
//   forms/
//     LoginForm.js
//     RegistrationForm.js
//   screens/
//     HomeScreen.js
//     ProfileScreen.js

// 2. Export Patterns
// Component.js
export const Component = () => { /* ... */ };
export default Component;

// index.js
export { default } from './Component';
export * from './Component';

// 3. Custom Hooks - Reusable Logic
// hooks/useFetch.js
import { useState, useEffect } from 'react';

export const useFetch = (url) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(url);
        const json = await response.json();
        setData(json);
        setLoading(false);
      } catch (err) {
        setError(err);
        setLoading(false);
      }
    };
    fetchData();
  }, [url]);

  return { data, loading, error };
};

// Usage
function UserList() {
  const { data, loading, error } = useFetch('https://api.example.com/users');
  
  if (loading) return <Text>Loading...</Text>;
  if (error) return <Text>Error: {error.message}</Text>;
  
  return /* render data */;
}

// 4. Higher-Order Components (HOC)
const withAuth = (WrappedComponent) => {
  return (props) => {
    const isAuthenticated = useAuth();
    if (!isAuthenticated) {
      return <Navigate to="/login" />;
    }
    return <WrappedComponent {...props} />;
  };
};

// 5. Render Props
const DataFetcher = ({ url, children }) => {
  const { data, loading, error } = useFetch(url);
  return children({ data, loading, error });
};

// Usage
<DataFetcher url="https://api.example.com/users">
  {({ data, loading, error }) => {
    if (loading) return <Text>Loading...</Text>;
    if (error) return <Text>Error</Text>;
    return <UserList users={data} />;
  }}
</DataFetcher>

// 6. Memoization for Performance
import React, { useMemo, useCallback } from 'react';

function ExpensiveComponent({ data, onPress }) {
  // Memoize expensive calculations
  const processedData = useMemo(() => {
    return data.map(item => ({
      ...item,
      processed: item.value * 2,
    }));
  }, [data]);

  // Memoize callbacks
  const handlePress = useCallback(() => {
    onPress(processedData);
  }, [onPress, processedData]);

  return <Button title="Process" onPress={handlePress} />;
}

// 7. Error Boundaries
import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <Text>Something went wrong</Text>;
    }
    return this.props.children;
  }
}
```

---

## P.11 Quick Reference: Essential Commands

### Development Commands

```bash
# Creating a project
npx create-expo-app MyApp --template

# Development
npx expo start                     # Start dev server
npx expo start --ios               # Start with iOS
npx expo start --android           # Start with Android
npx expo start --web               # Start with Web
npx expo start --clear             # Clear cache and start

# Building
eas build --platform ios           # Build for iOS
eas build --platform android        # Build for Android
eas build --platform all            # Build for both

# Submitting
eas submit --platform ios          # Submit to App Store
eas submit --platform android       # Submit to Play Store

# Testing
npm test                           # Run tests
npm run test:coverage              # Run tests with coverage

# Code Quality
npm run lint                       # Run ESLint
npm run format                     # Run Prettier
npx tsc --noEmit                   # Type check
```

---

## P.12 Next Steps

Now that you have a solid foundation in React Native and Expo, you're ready to dive into the main tutorial series. Here's what to focus on:

1. **Complete Part 0** to understand the overall architecture
2. **Set up your environment** as described in Part 1
3. **Follow along** with each step - type the code yourself
4. **Run the verification steps** to ensure everything works
5. **Experiment and break things** - that's how you learn!

### Additional Resources

- **React Native Docs:** https://reactnative.dev/docs
- **Expo Docs:** https://docs.expo.dev
- **React Navigation:** https://reactnavigation.org/docs
- **Zustand:** https://zustand-demo.pmnd.rs
- **WatermelonDB:** https://watermelondb.dev
- **Supabase:** https://supabase.com/docs

---

**Ready to build NexusCollect? Let's go!**
