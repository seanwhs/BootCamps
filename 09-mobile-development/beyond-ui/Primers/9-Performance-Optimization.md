# Primer 9: Performance Optimization

## Your Complete Guide to Fast, Smooth Mobile Apps

Welcome to the Performance Optimization Primer! This guide covers everything you need to know about making your React Native app fast, responsive, and battery-efficient. Performance is critical to user satisfaction—slow apps are quickly abandoned.

---

## P.1 Understanding Mobile Performance

### The Concept: Speed Matters

Mobile performance is about how quickly your app responds to user interactions and how efficiently it uses device resources (CPU, memory, battery). A fast app feels professional and keeps users engaged.

**Simple Analogy:** Think of your app like a restaurant. Performance is the speed of service. Customers (users) want their food (content) delivered quickly. They don't want to wait for a table (loading screen) or watch the chef (app) struggle with orders (lag).

### Performance Metrics to Track

| Metric | Description | Good Target |
|--------|-------------|-------------|
| FPS (Frames Per Second) | How smooth animations are | 60 FPS |
| Startup Time | Time to first render | < 2 seconds |
| Time to Interactive | App becomes usable | < 5 seconds |
| Memory Usage | RAM consumption | < 200 MB |
| CPU Usage | Processing power used | < 30% |
| Battery Impact | Energy consumption | Minimal |
| Network Requests | API call performance | < 200ms |
| Bundle Size | App download size | < 50 MB |

---

## P.2 Rendering Performance

### The Concept: Smooth UI Updates

Rendering performance is about how quickly your UI updates. In React Native, this means minimizing re-renders and optimizing component updates.

### Complete Rendering Guide

```typescript
// 1. Use React.memo to Prevent Unnecessary Renders
import React, { memo } from 'react';

// ❌ Bad - Re-renders whenever parent updates
const UserCard = ({ user }) => {
  return (
    <View>
      <Text>{user.name}</Text>
      <Text>{user.email}</Text>
    </View>
  );
};

// ✅ Good - Only re-renders when user prop changes
const UserCard = memo(({ user }) => {
  return (
    <View>
      <Text>{user.name}</Text>
      <Text>{user.email}</Text>
    </View>
  );
});

// 2. Use useMemo for Expensive Calculations
import { useMemo } from 'react';

function UserList({ users }) {
  // ❌ Bad - Recalculates on every render
  const activeUsers = users.filter(user => user.active);
  
  // ✅ Good - Only recalculates when users changes
  const activeUsers = useMemo(() => {
    return users.filter(user => user.active);
  }, [users]);
  
  return <FlatList data={activeUsers} />;
}

// 3. Use useCallback for Stable Function References
import { useCallback } from 'react';

function UserList({ onSelectUser }) {
  // ❌ Bad - New function created on every render
  const handlePress = (user) => {
    onSelectUser(user.id);
  };
  
  // ✅ Good - Stable function reference
  const handlePress = useCallback((user) => {
    onSelectUser(user.id);
  }, [onSelectUser]);
  
  return <Button onPress={() => handlePress(user)} />;
}

// 4. Use FlatList Instead of ScrollView for Lists
// ❌ Bad - Renders all items at once
<ScrollView>
  {items.map(item => <Text key={item.id}>{item.name}</Text>)}
</ScrollView>

// ✅ Good - Renders only visible items
<FlatList
  data={items}
  renderItem={({ item }) => <Text>{item.name}</Text>}
  keyExtractor={item => item.id}
  maxToRenderPerBatch={10}
  windowSize={21}
  initialNumToRender={10}
  removeClippedSubviews={true}
/>

// 5. Use PureComponent for Class Components
import { PureComponent } from 'react';

class UserCard extends PureComponent {
  render() {
    return (
      <View>
        <Text>{this.props.user.name}</Text>
      </View>
    );
  }
}

// 6. Optimize with shouldComponentUpdate
class ExpensiveComponent extends Component {
  shouldComponentUpdate(nextProps, nextState) {
    // Only update if relevant props changed
    return nextProps.id !== this.props.id;
  }
  
  render() {
    // Expensive rendering
  }
}

// 7. Avoid Inline Styles for Dynamic Styles
// ❌ Bad - New style object every render
<View style={{ flex: 1, backgroundColor: '#fff' }} />

// ✅ Good - Use StyleSheet
<View style={styles.container} />

// ✅ Good - For dynamic styles, use useMemo
const dynamicStyle = useMemo(() => ({
  backgroundColor: isActive ? '#2196F3' : '#ccc',
}), [isActive]);

// 8. Use InteractionManager for Heavy Operations
import { InteractionManager } from 'react-native';

function HeavyComponent() {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    // Run heavy operation after animations are complete
    InteractionManager.runAfterInteractions(() => {
      const processedData = processHeavyData();
      setData(processedData);
    });
  }, []);
  
  return <View>{data && <DataDisplay data={data} />}</View>;
}
```

---

## P.3 List Performance

### The Concept: Efficient List Rendering

Lists are common in mobile apps. Optimizing them is crucial for performance.

### Complete List Performance Guide

```typescript
// 1. Optimize FlatList Performance
import { FlatList, View, Text } from 'react-native';

function OptimizedList({ data }) {
  return (
    <FlatList
      data={data}
      renderItem={({ item }) => <ListItem item={item} />}
      keyExtractor={item => item.id}
      
      // Performance optimizations
      initialNumToRender={10}          // Renders 10 items initially
      maxToRenderPerBatch={10}         // Updates in batches of 10
      updateCellsBatchingPeriod={50}    // Wait 50ms between batches
      windowSize={21}                  // Render 21 items window
      removeClippedSubviews={true}     // Remove off-screen items
      
      // Optimize for large lists
      getItemLayout={(data, index) => ({
        length: 80,                    // Item height
        offset: 80 * index,
        index,
      })}
      
      // Optimize scrolling
      scrollEventThrottle={16}          // Match 60fps
      
      // Loading states
      ListFooterComponent={<LoadingSpinner />}
      onEndReached={() => loadMore()}
      onEndReachedThreshold={0.5}
      
      // Extras
      showsVerticalScrollIndicator={false}
      contentContainerStyle={styles.listContainer}
    />
  );
}

// 2. Memoize List Items
const ListItem = memo(({ item }) => {
  return (
    <View style={styles.item}>
      <Text>{item.name}</Text>
      <Text>{item.description}</Text>
    </View>
  );
});

// 3. Use SectionList for Grouped Data
import { SectionList } from 'react-native';

function GroupedList({ sections }) {
  return (
    <SectionList
      sections={sections}
      renderItem={({ item }) => <Text>{item}</Text>}
      renderSectionHeader={({ section }) => (
        <Text style={styles.header}>{section.title}</Text>
      )}
      stickySectionHeadersEnabled={true}
      keyExtractor={(item, index) => item + index}
    />
  );
}

// 4. Use VirtualizedList for Custom Lists
import { VirtualizedList } from 'react-native';

function CustomList({ data }) {
  const getItemCount = (data) => data.length;
  const getItem = (data, index) => data[index];
  
  return (
    <VirtualizedList
      data={data}
      getItemCount={getItemCount}
      getItem={getItem}
      renderItem={({ item }) => <Text>{item}</Text>}
      keyExtractor={(item, index) => item.id || index.toString()}
    />
  );
}
```

---

## P.4 Image Optimization

### The Concept: Fast Image Loading

Images are often the largest assets in your app. Optimizing them significantly improves performance.

### Complete Image Optimization Guide

```typescript
// 1. Use expo-image for Better Image Loading
import { Image } from 'expo-image';

function OptimizedImage({ source, style }) {
  return (
    <Image
      source={source}
      style={style}
      contentFit="cover"
      transition={300}
      cachePolicy="memory-disk"
      placeholder={require('@assets/placeholder.png')}
      blurRadius={10}
    />
  );
}

// 2. Lazy Load Images
import { Image } from 'react-native';

function LazyImage({ source, style }) {
  const [loaded, setLoaded] = useState(false);
  
  return (
    <View>
      {!loaded && <LoadingPlaceholder />}
      <Image
        source={source}
        style={[style, !loaded && { opacity: 0 }]}
        onLoad={() => setLoaded(true)}
        resizeMode="cover"
      />
    </View>
  );
}

// 3. Cache Images with expo-file-system
import * as FileSystem from 'expo-file-system';
import { Image } from 'react-native';

async function cacheImage(url: string): Promise<string> {
  const filename = url.split('/').pop() || 'image.jpg';
  const fileUri = `${FileSystem.cacheDirectory}${filename}`;
  
  const fileInfo = await FileSystem.getInfoAsync(fileUri);
  if (fileInfo.exists) {
    return fileUri;
  }
  
  await FileSystem.downloadAsync(url, fileUri);
  return fileUri;
}

function CachedImage({ url, style }) {
  const [uri, setUri] = useState(null);
  
  useEffect(() => {
    cacheImage(url).then(setUri);
  }, [url]);
  
  return <Image source={{ uri }} style={style} />;
}

// 4. Use Progressive JPEG
// Implement progressive loading with blurhash
import { Blurhash } from 'react-native-blurhash';

function ProgressiveImage({ source, blurhash, style }) {
  const [loaded, setLoaded] = useState(false);
  
  return (
    <View>
      {!loaded && (
        <Blurhash
          blurhash={blurhash}
          style={style}
          decodeWidth={32}
          decodeHeight={32}
        />
      )}
      <Image
        source={source}
        style={[style, !loaded && { opacity: 0 }]}
        onLoad={() => setLoaded(true)}
      />
    </View>
  );
}

// 5. Use FastImage (Alternative)
import FastImage from 'react-native-fast-image';

function FastImageComponent({ source, style }) {
  return (
    <FastImage
      source={{
        uri: source.uri,
        priority: FastImage.priority.normal,
        cache: FastImage.cacheControl.immutable,
      }}
      style={style}
      resizeMode={FastImage.resizeMode.cover}
    />
  );
}
```

---

## P.5 Network Optimization

### The Concept: Fast Data Loading

Network optimization reduces load times and data usage.

### Complete Network Optimization Guide

```typescript
// 1. Implement Caching Strategy
import { QueryClient } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Cache for 5 minutes
      staleTime: 5 * 60 * 1000,
      // Keep in cache for 10 minutes
      cacheTime: 10 * 60 * 1000,
      // Retry failed requests
      retry: 3,
      // Refetch when window focuses
      refetchOnWindowFocus: true,
    },
  },
});

// 2. Use React Query for Data Fetching
import { useQuery } from '@tanstack/react-query';

function UserProfile({ userId }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    // Data is fresh for 5 minutes
    staleTime: 5 * 60 * 1000,
    // Cache for 1 hour
    cacheTime: 60 * 60 * 1000,
  });
  
  // ...
}

// 3. Implement Request Debouncing
import { useDebounce } from '@hooks/useDebounce';

function SearchComponent() {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearch = useDebounce(searchTerm, 300);
  
  const { data } = useQuery({
    queryKey: ['search', debouncedSearch],
    queryFn: () => searchAPI(debouncedSearch),
    enabled: debouncedSearch.length > 2,
  });
  
  return (
    <TextInput
      value={searchTerm}
      onChangeText={setSearchTerm}
      placeholder="Search..."
    />
  );
}

// 4. Implement Pagination
function PaginatedList() {
  const [page, setPage] = useState(1);
  
  const { data, isLoading, fetchNextPage } = useInfiniteQuery({
    queryKey: ['items'],
    queryFn: ({ pageParam = 1 }) => fetchItems(pageParam),
    getNextPageParam: (lastPage) => lastPage.nextPage,
  });
  
  return (
    <FlatList
      data={data}
      onEndReached={() => fetchNextPage()}
      onEndReachedThreshold={0.5}
      ListFooterComponent={isLoading && <LoadingSpinner />}
    />
  );
}

// 5. Compress API Payloads
// Use gzip compression on server
// For mobile, use smaller payloads

// 6. Batch API Requests
async function batchRequests(requests) {
  const responses = await Promise.all(
    requests.map(req => axios(req))
  );
  return responses;
}

// 7. Use WebSocket for Real-time Data
import { supabase } from '@api/supabase';

function RealtimeComponent() {
  useEffect(() => {
    const subscription = supabase
      .channel('items')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'items' },
        (payload) => {
          // Update UI
        }
      )
      .subscribe();
    
    return () => subscription.unsubscribe();
  }, []);
}
```

---

## P.6 Memory Management

### The Concept: Efficient Memory Usage

Memory leaks can crash your app and cause performance issues.

### Complete Memory Management Guide

```typescript
// 1. Clean Up Event Listeners
useEffect(() => {
  const subscription = someEmitter.addListener('event', handler);
  
  return () => {
    subscription.remove();
  };
}, []);

// 2. Clean Up Timers
useEffect(() => {
  const timer = setTimeout(() => {
    // Do something
  }, 1000);
  
  return () => {
    clearTimeout(timer);
  };
}, []);

// 3. Clean Up Animations
useEffect(() => {
  const animation = Animated.timing(value, {
    toValue: 1,
    duration: 1000,
    useNativeDriver: true,
  });
  
  animation.start();
  
  return () => {
    animation.stop();
  };
}, []);

// 4. Avoid Memory Leaks in Async Operations
useEffect(() => {
  let isMounted = true;
  
  const fetchData = async () => {
    const data = await api.getData();
    if (isMounted) {
      setData(data);
    }
  };
  
  fetchData();
  
  return () => {
    isMounted = false;
  };
}, []);

// 5. Use WeakMap for Caching
const cache = new WeakMap();

function getCachedData(key) {
  if (cache.has(key)) {
    return cache.get(key);
  }
  const data = computeData(key);
  cache.set(key, data);
  return data;
}

// 6. Use React.memo to Prevent Memory Bloat
const MemoizedComponent = memo(({ data }) => {
  // Component logic
});

// 7. Clean Up Large Objects
useEffect(() => {
  const largeObject = createLargeObject();
  
  return () => {
    // Let garbage collector clean up
    largeObject.data = null;
    largeObject.cache.clear();
  };
}, []);
```

---

## P.7 App Startup Performance

### The Concept: Fast Launch Times

First impressions matter. Your app should load quickly.

### Complete Startup Optimization Guide

```typescript
// 1. Lazy Load Non-Critical Screens
const ProfileScreen = React.lazy(() => import('@screens/ProfileScreen'));
const SettingsScreen = React.lazy(() => import('@screens/SettingsScreen'));

function App() {
  return (
    <Suspense fallback={<LoadingScreen />}>
      <NavigationContainer>
        <Stack.Navigator>
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="Profile" component={ProfileScreen} />
          <Stack.Screen name="Settings" component={SettingsScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    </Suspense>
  );
}

// 2. Preload Critical Assets
import * as Font from 'expo-font';
import { Asset } from 'expo-asset';

async function loadAssets() {
  // Load fonts
  await Font.loadAsync({
    'custom-font': require('@assets/fonts/CustomFont.ttf'),
  });
  
  // Preload images
  await Asset.loadAsync([
    require('@assets/images/splash.png'),
    require('@assets/images/logo.png'),
  ]);
}

// 3. Show Splash Screen While Loading
import { SplashScreen } from 'expo-splash-screen';

SplashScreen.preventAutoHideAsync();

useEffect(() => {
  const prepare = async () => {
    try {
      await loadAssets();
    } catch (e) {
      console.warn(e);
    } finally {
      SplashScreen.hideAsync();
    }
  };
  prepare();
}, []);

// 4. Defer Non-Critical Operations
useEffect(() => {
  InteractionManager.runAfterInteractions(() => {
    // Load non-critical data
    loadAnalytics();
    preloadNextScreen();
  });
}, []);

// 5. Use Hermes Engine (for Android)
// In app.json:
{
  "expo": {
    "android": {
      "jsEngine": "hermes"
    }
  }
}

// 6. Optimize Bundle Size
// Use Babel to remove console logs in production
// Use code splitting for larger apps
```

---

## P.8 Performance Monitoring

### The Concept: Measuring Performance

You can't improve what you don't measure.

### Complete Monitoring Guide

```typescript
// 1. Performance Monitoring Service
// src/utils/performance.ts
import { Performance } from '@react-native-community/performance';

export class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private marks: Map<string, number> = new Map();

  static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  /**
   * Mark the start of a performance measurement
   */
  markStart(name: string): void {
    this.marks.set(name, performance.now());
  }

  /**
   * Mark the end and measure duration
   */
  markEnd(name: string): number {
    const start = this.marks.get(name);
    if (!start) {
      console.warn(`No start mark found for: ${name}`);
      return 0;
    }
    
    const duration = performance.now() - start;
    this.marks.delete(name);
    
    // Log slow operations
    if (duration > 100) {
      console.warn(`⚠️ Slow operation: ${name} took ${duration.toFixed(2)}ms`);
    }
    
    return duration;
  }

  /**
   * Measure a function's execution time
   */
  async measure<T>(name: string, fn: () => Promise<T> | T): Promise<T> {
    this.markStart(name);
    try {
      const result = await fn();
      this.markEnd(name);
      return result;
    } catch (error) {
      this.markEnd(name);
      throw error;
    }
  }

  /**
   * Track render performance
   */
  trackRender(componentName: string): void {
    const renderCount = this.getRenderCount(componentName);
    if (renderCount > 100) {
      console.warn(`⚠️ Component rendered many times: ${componentName} (${renderCount})`);
    }
  }

  private renderCounts: Map<string, number> = new Map();
  private getRenderCount(name: string): number {
    const count = this.renderCounts.get(name) || 0;
    this.renderCounts.set(name, count + 1);
    return count;
  }

  /**
   * Track memory usage
   */
  async getMemoryUsage(): Promise<{
    used: number;
    total: number;
    percent: number;
  }> {
    // Platform specific memory tracking
    // This is a simplified example
    return {
      used: 0,
      total: 0,
      percent: 0,
    };
  }
}

export const performanceMonitor = PerformanceMonitor.getInstance();

// 2. Use in Components
// Wrap component renders
function UserList({ data }) {
  performanceMonitor.trackRender('UserList');
  
  return <FlatList data={data} />;
}

// 3. Measure API Calls
const fetchUsers = async () => {
  return performanceMonitor.measure('fetchUsers', async () => {
    const response = await apiClient.get('/users');
    return response.data;
  });
};

// 4. React Native Performance (built-in)
import { Performance } from '@react-native-community/performance';

// Log performance marks
Performance.getInstance().addListener(
  'mark',
  (mark) => {
    console.log(`Performance mark: ${mark.name}`, mark);
  }
);

// 5. FPS Monitoring
import { useFPS } from 'react-native-fps';

function FPSMonitor() {
  const fps = useFPS();
  
  if (fps < 30) {
    console.warn('⚠️ Low FPS detected:', fps);
  }
  
  return null;
}
```

---

## P.9 Quick Reference

### Performance Commands

```bash
# Enable Hermes (Android)
# In app.json:
{
  "android": {
    "jsEngine": "hermes"
  }
}

# Enable Proguard (Android)
# android/app/proguard-rules.pro
-keep class com.facebook.hermes.unicode.** { *; }

# Bundle Analysis
npm run build:prod -- --analyze

# Debugging
npx react-native start --reset-cache
```

### Performance Checklist

| Item | Status |
|------|--------|
| Use FlatList for lists | ✅ |
| Memoize components | ✅ |
| Use useMemo/useCallback | ✅ |
| Optimize images | ✅ |
| Implement caching | ✅ |
| Lazy load screens | ✅ |
| Use Hermes (Android) | ✅ |
| Remove console logs | ✅ |
| Profile JS thread | ✅ |
| Monitor memory usage | ✅ |

---

**Ready to make your app fly? Let's build NexusCollect!**
