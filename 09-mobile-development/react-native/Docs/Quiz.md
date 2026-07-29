# React Native: From Blueprint to Production
## Comprehensive Quiz & Test Bank with Answer Keys

---

# STUDENT QUIZ & TEST BANK

## Mobile Development with React Native: From Blueprint to Production

---

**Instructor Use Only - Answer Keys Included**

---

## Table of Contents

| Part | Topic | Page |
|------|-------|------|
| 1 | Foundations & Environment Architecture | 3 |
| 2 | Core Components & Styling | 8 |
| 3 | Navigation | 13 |
| 4 | State Management | 18 |
| 5 | Data Persistence & Offline-First | 23 |
| 6 | Device Capabilities | 28 |
| 7 | Gestures & Animations | 33 |
| 8 | Testing | 38 |
| 9 | Performance Optimization | 43 |
| 10 | Deployment & CI/CD | 48 |
| | Final Exam | 53 |

---

# PART 1: FOUNDATIONS & ENVIRONMENT

## Module 1: React Native Fundamentals Quiz

### Multiple Choice Questions

**1. What is the primary purpose of the React Native bridge?**

A) To compile JavaScript to native code
B) To communicate between JavaScript and native threads
C) To render React components in a webview
D) To manage state across components

**Answer: B**

**Explanation:** The bridge is the communication channel between the JavaScript thread and native threads. It serializes data to JSON and passes messages asynchronously.

---

**2. Which of the following is NOT a thread in React Native?**

A) JavaScript Thread
B) UI Thread
C) Shadow Thread
D) Animation Thread

**Answer: D**

**Explanation:** The three main threads are JavaScript (runs React code), UI (renders native components), and Shadow (calculates layouts). Animation is handled by the UI thread or native driver, not a separate thread.

---

**3. What is the recommended development approach for beginners in React Native?**

A) Bare React Native CLI
B) Expo
C) Native Swift/Kotlin
D) Webview wrappers

**Answer: B**

**Explanation:** Expo provides a faster, easier development experience with built-in APIs, instant preview, and managed workflows, making it ideal for beginners.

---

**4. What command creates a new Expo project with TypeScript?**

A) `expo init MyApp --typescript`
B) `npx create-expo-app MyApp --template`
C) `react-native init MyApp --typescript`
D) `npm init expo MyApp`

**Answer: B**

**Explanation:** `npx create-expo-app MyApp --template` creates a new Expo project with template selection (blank TypeScript is an option).

---

**5. What is the minimum Node.js version required for React Native development?**

A) 12.x
B) 14.x
C) 16.x
D) 18.x

**Answer: D**

**Explanation:** React Native requires Node.js 18 or newer for compatibility with modern JavaScript features and dependencies.

---

**6. Which of the following is true about the React Native bridge?**

A) It is synchronous
B) It uses binary serialization
C) It is asynchronous
D) It runs on the UI thread

**Answer: C**

**Explanation:** The bridge is asynchronous to prevent blocking either thread. This allows JavaScript and native code to work independently.

---

**7. What is the purpose of the Metro bundler?**

A) To compile native code
B) To bundle JavaScript and assets
C) To manage dependencies
D) To run the app on a simulator

**Answer: B**

**Explanation:** Metro is React Native's JavaScript bundler that processes, transpiles, and bundles your code and assets for the app.

---

**8. Which tool allows you to preview your Expo app on a physical device?**

A) Xcode Simulator
B) Android Emulator
C) Expo Go
D) React Native Debugger

**Answer: C**

**Explanation:** Expo Go is a mobile app that allows you to preview Expo projects on physical devices by scanning a QR code.

---

**9. What happens when the JavaScript thread is blocked for too long?**

A) The app crashes
B) Frame drops and UI lag occur
C) The bridge disconnects
D) The app automatically restarts

**Answer: B**

**Explanation:** When the JavaScript thread is blocked, it cannot send updates to the UI thread, causing dropped frames and UI lag (jank).

---

**10. Which of the following is NOT a benefit of using Expo?**

A) Over-the-air updates
B) Full access to native modules
C) Built-in device APIs
D) Easier build process

**Answer: B**

**Explanation:** While Expo provides many built-in APIs, full access to custom native modules requires ejecting to the bare workflow. This is a limitation of the managed workflow.

---

### True/False Questions

**11. React Native apps run inside a webview.**

**Answer: False**

**Explanation:** React Native renders native components, not webviews. Components like `<View>` and `<Text>` become native UI elements.

---

**12. The Shadow Thread calculates layout positions and sizes.**

**Answer: True**

**Explanation:** The Shadow Thread runs the Yoga layout engine to calculate positions and sizes before sending them to the UI thread for rendering.

---

**13. JSI replaces the bridge in React Native 0.70+.**

**Answer: False**

**Explanation:** JSI (JavaScript Interface) provides a faster alternative to the bridge for certain operations, but the bridge is still used for many communications. It's not a full replacement.

---

**14. Expo apps cannot be published to the App Store.**

**Answer: False**

**Explanation:** Expo apps can be published to both the Apple App Store and Google Play Store using EAS Build.

---

**15. The Metro bundler supports Fast Refresh for instant code updates.**

**Answer: True**

**Explanation:** Metro supports Fast Refresh (formerly Hot Module Replacement) which updates your app instantly when you save code changes.

---

### Short Answer Questions

**16. Explain the three threads in React Native and what each one does.**

**Answer:**
- **JavaScript Thread:** Runs your React code, handles component rendering (Virtual DOM), business logic, and API calls.
- **UI Thread (Native):** Handles all rendering, responds to user input (taps, swipes), runs animations, and manages the screen.
- **Shadow Thread (Native):** Calculates layouts using the Yoga engine, processes flexbox and positioning, and measures text.

---

**17. What are the key differences between Expo and Bare React Native workflows?**

**Answer:**
- **Expo:** Easier setup, built-in APIs, over-the-air updates, faster development. Limited to Expo-supported native modules.
- **Bare React Native:** Full control over native code, can use any native library, smaller app size. More complex setup and manual configuration.

---

**18. Why is the bridge asynchronous, and what are the implications of this?**

**Answer:**
The bridge is asynchronous to prevent blocking either the JavaScript or native threads. This means you cannot send a message and expect an immediate response. You must use callbacks, promises, or event emitters. This has performance implications as every bridge call has overhead.

---

**19. What is JSI and how does it improve performance?**

**Answer:**
JSI (JavaScript Interface) allows direct communication between JavaScript and native code without serialization to JSON, reducing overhead and improving performance for synchronous operations.

---

**20. How would you diagnose if your app's JavaScript thread is being blocked?**

**Answer:**
- Use React DevTools Profiler to measure render times
- Monitor frame rates (drop below 60fps indicates lag)
- Use Flipper or React Native Debugger to profile JS execution
- Look for long-running loops or heavy computations in your code

---

# PART 2: CORE COMPONENTS & STYLING

## Module 2: Components & Styling Quiz

### Multiple Choice Questions

**21. Which component is used as a container similar to `<div>` in HTML?**

A) `<Container>`
B) `<View>`
C) `<Box>`
D) `<Wrapper>`

**Answer: B**

**Explanation:** `<View>` is the fundamental container component in React Native, similar to `<div>` in HTML.

---

**22. How do you create styles in React Native?**

A) CSS files
B) Inline styles only
C) StyleSheet.create()
D) Styled Components

**Answer: C**

**Explanation:** `StyleSheet.create()` is the recommended way to define styles in React Native, providing optimization and validation.

---

**23. What is the default flexDirection in React Native?**

A) row
B) column
C) row-reverse
D) column-reverse

**Answer: B**

**Explanation:** Unlike web CSS where flexDirection defaults to row, React Native defaults to column (vertical layout).

---

**24. How do you handle safe area insets for notched devices?**

A) `<SafeView>`
B) `<SafeAreaView>`
C) `<NotchView>`
D) `<SafeContainer>`

**Answer: B**

**Explanation:** `<SafeAreaView>` automatically applies padding to avoid notches, status bars, and home indicators.

---

**25. Which property controls alignment along the main axis in Flexbox?**

A) alignItems
B) justifyContent
C) alignSelf
D) flexDirection

**Answer: B**

**Explanation:** `justifyContent` controls alignment along the main axis (primary axis determined by flexDirection).

---

**26. How do you make a component fill all available space?**

A) width: '100%', height: '100%'
B) flex: 1
C) flexGrow: 1
D) fill: true

**Answer: B**

**Explanation:** `flex: 1` makes a component expand to fill all available space in its container along the flex direction.

---

**27. What is the correct way to handle platform-specific styling?**

A) Platform.select()
B) if (Platform.OS === 'ios')
C) Both A and B are valid
D) Platform-specific style files

**Answer: C**

**Explanation:** Both `Platform.select()` and conditional statements with `Platform.OS` are valid ways to handle platform-specific styling.

---

**28. Which component should you use for large lists with many items?**

A) ScrollView
B) FlatList
C) ListView
D) CollectionView

**Answer: B**

**Explanation:** `FlatList` is optimized for large lists by rendering only visible items (virtualization) and recycling views.

---

**29. What is the minimum recommended touch target size for accessibility?**

A) 30x30 points
B) 44x44 points
C) 50x50 points
D) 60x60 points

**Answer: B**

**Explanation:** Apple HIG recommends a minimum touch target size of 44x44 points for accessibility and usability.

---

**30. Which property handles shadows on iOS?**

A) shadowColor, shadowOffset, shadowOpacity, shadowRadius
B) elevation
C) boxShadow
D) Both A and B work on all platforms

**Answer: A**

**Explanation:** iOS uses `shadowColor`, `shadowOffset`, `shadowOpacity`, and `shadowRadius`. Android uses `elevation` for shadows.

---

### True/False Questions

**31. In React Native, `flexDirection: row` behaves differently than in web CSS.**

**Answer: True**

**Explanation:** In React Native, the default flexDirection is 'column', while web CSS defaults to 'row'.

---

**32. `ScrollView` is suitable for rendering thousands of items.**

**Answer: False**

**Explanation:** `ScrollView` renders all items at once, which can cause performance issues with thousands of items. `FlatList` should be used for large lists.

---

**33. The `Image` component automatically handles image caching.**

**Answer: True**

**Explanation:** React Native's `Image` component caches remote images automatically, improving performance on subsequent loads.

---

**34. `TouchableOpacity` provides haptic feedback on iOS.**

**Answer: False**

**Explanation:** `TouchableOpacity` does not provide haptic feedback. Use `expo-haptics` or `react-native-haptic-feedback` for haptic feedback.

---

**35. The `Text` component always renders text on a single line by default.**

**Answer: False**

**Explanation:** `Text` wraps text by default. Use `numberOfLines` to limit lines.

---

### Short Answer Questions

**36. Compare and contrast ScrollView and FlatList. When would you use each?**

**Answer:**
- **ScrollView:** Renders all children at once. Suitable for small, fixed-size content (forms, small lists).
- **FlatList:** Uses virtualization to render only visible items. Suitable for large, dynamic lists (news feeds, task lists, contacts).

---

**37. Explain how to create a responsive layout in React Native.**

**Answer:**
- Use flexbox with percentage-based sizing
- Use `Dimensions` API to get screen size
- Use `scaleSize` helper functions for adaptive sizing
- Use `Platform.select()` for platform-specific sizing
- Use `SafeAreaView` for safe area handling

---

**38. What are the key differences between styling in React Native and CSS?**

**Answer:**
- React Native uses camelCase properties (e.g., `backgroundColor` vs `background-color`)
- No inheritance of styles
- No CSS selectors or cascading
- Flexbox defaults to column direction
- Limited to subset of CSS properties
- StyleSheet is optimized for performance

---

**39. How do you implement a two-column layout in React Native?**

**Answer:**
```tsx
<View style={{ flexDirection: 'row' }}>
  <View style={{ flex: 1 }}>
    {/* Left column content */}
  </View>
  <View style={{ flex: 1 }}>
    {/* Right column content */}
  </View>
</View>
```

---

**40. What strategies can you use for responsive design in React Native?**

**Answer:**
- Use flexbox for flexible layouts
- Use percentage dimensions for relative sizing
- Use `Dimensions.get('window')` for screen dimensions
- Create utility functions for scaling sizes
- Use `Platform.select()` for platform-specific styles
- Use `useWindowDimensions` hook for reactive updates

---

# PART 3: NAVIGATION

## Module 3: Navigation Quiz

### Multiple Choice Questions

**41. Which navigator type is best for a settings menu?**

A) Stack Navigator
B) Tab Navigator
C) Drawer Navigator
D) Switch Navigator

**Answer: C**

**Explanation:** The Drawer Navigator provides a side-swipe menu, which is commonly used for settings, help, and secondary navigation.

---

**42. How do you pass parameters to a screen in React Navigation?**

A) `navigation.setParams({ id: '123' })`
B) `navigation.navigate('Screen', { id: '123' })`
C) `navigation.push('Screen', { id: '123' })`
D) Both B and C are valid

**Answer: D**

**Explanation:** Both `navigate` and `push` can pass parameters. `push` adds a new screen to the stack even if it already exists.

---

**43. What hook provides access to navigation props?**

A) `useNavigationProps`
B) `useNavigation`
C) `useRouter`
D) `useNavigator`

**Answer: B**

**Explanation:** `useNavigation` is the hook that provides navigation props for navigating between screens.

---

**44. Which is the correct way to protect authenticated routes?**

A) Conditional rendering
B) Navigation guards
C) Both A and B
D) Authentication middleware

**Answer: C**

**Explanation:** Both conditional rendering (rendering different navigators) and navigation guards (checking auth before rendering) are valid approaches.

---

**45. What is deep linking?**

A) Linking between screens within the app
B) Opening the app from a URL
C) Linking to external apps
D) Passing deep data between screens

**Answer: B**

**Explanation:** Deep linking allows external URLs to open specific screens within your app.

---

**46. Which component is used to create a tab navigator?**

A) `createTabNavigator`
B) `createBottomTabNavigator`
C) `TabNavigator`
D) `BottomTab`

**Answer: B**

**Explanation:** `createBottomTabNavigator` creates a bottom tab navigator with iOS-style tabs.

---

**47. How do you set screen options like title and header style?**

A) `options` prop on `Screen`
B) `screenOptions` on `Navigator`
C) Both A and B
D) `navigation.setOptions`

**Answer: C**

**Explanation:** You can set options either on individual screens (`options` prop) or globally on the navigator (`screenOptions`).

---

**48. What is the purpose of `navigation.goBack()`?**

A) Navigate to the previous screen in history
B) Navigate to the home screen
C) Close the current screen
D) Navigate to the parent screen

**Answer: A**

**Explanation:** `navigation.goBack()` navigates to the previous screen in the navigation history.

---

**49. How do you handle deep linking in Expo?**

A) `expo-linking`
B) `Linking` from React Native
C) `NavigationContainer` linking prop
D) All of the above

**Answer: D**

**Explanation:** Deep linking in Expo can be handled using the Linking API, `expo-linking`, or the `linking` prop on `NavigationContainer`.

---

**50. What is the difference between `navigate` and `push` in Stack Navigation?**

A) `navigate` goes to an existing screen, `push` always creates a new instance
B) `navigate` creates a new instance, `push` goes to an existing screen
C) There is no difference
D) `push` is only for modal screens

**Answer: A**

**Explanation:** `navigate` navigates to an existing screen in the stack (if it exists), while `push` always adds a new screen to the stack.

---

### True/False Questions

**51. React Navigation only supports Stack and Tab navigators.**

**Answer: False**

**Explanation:** React Navigation supports Stack, Tab (bottom and top), Drawer, and Switch navigators, among others.

---

**52. Navigation state can be persisted across app restarts.**

**Answer: True**

**Explanation:** You can persist navigation state using AsyncStorage and the `onStateChange` prop of `NavigationContainer`.

---

**53. Deep linking requires setting up URL schemes in app.json.**

**Answer: True**

**Explanation:** URL schemes must be configured in app.json to handle deep links in Expo apps.

---

**54. `useRoute` hook gives access to navigation functions.**

**Answer: False**

**Explanation:** `useRoute` gives access to route parameters. `useNavigation` gives access to navigation functions.

---

**55. Switch Navigator is used for authentication flows.**

**Answer: True**

**Explanation:** Switch Navigator is commonly used for authentication flows where you switch between auth screens and main app screens.

---

### Short Answer Questions

**56. Explain the three main types of navigation in React Native and when to use each.**

**Answer:**
- **Stack Navigation:** For hierarchical navigation where screens are pushed and popped (e.g., home → list → detail).
- **Tab Navigation:** For navigating between primary sections of the app (e.g., Home, Tasks, Profile).
- **Drawer Navigation:** For secondary navigation like settings, help, and user profile.

---

**57. How would you implement authentication flow with navigation guards?**

**Answer:**
```tsx
function AuthGuard({ children }) {
  const { isAuthenticated, isLoading } = useAuthStore();
  const navigation = useNavigation();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      navigation.navigate('Login');
    }
  }, [isAuthenticated, isLoading, navigation]);

  if (isLoading) {
    return <LoadingScreen />;
  }

  return isAuthenticated ? <>{children}</> : null;
}
```

---

**58. What is deep linking and why is it important for mobile apps?**

**Answer:**
Deep linking allows external URLs to open specific screens in your app. It's important for:
- Push notifications (navigating to specific content)
- Share links (opening shared content)
- Marketing campaigns (tracking campaigns)
- Web-to-app transitions (seamless user experience)

---

**59. How do you persist navigation state in React Navigation?**

**Answer:**
```tsx
<NavigationContainer
  linking={linking}
  onStateChange={(state) => {
    if (state) {
      saveNavigationState(state);
    }
  }}
  initialState={initialState}
>
  {/* Navigators */}
</NavigationContainer>
```
Where `saveNavigationState` and `initialState` manage AsyncStorage persistence.

---

**60. Compare and contrast the different navigator types in React Navigation.**

**Answer:**
- **Stack:** Linear navigation with back navigation. Best for drill-down interfaces.
- **Bottom Tabs:** Primary navigation at bottom of screen. Best for main sections.
- **Drawer:** Side menu navigation. Best for secondary features and settings.
- **Switch:** Conditional navigation. Best for auth flows and feature flags.
- **Top Tabs:** Tabs at top of screen. Best for category filtering within a section.

---

# PART 4: STATE MANAGEMENT

## Module 4: State Management Quiz

### Multiple Choice Questions

**61. Which Zustand function is used to create a store?**

A) `createStore`
B) `create`
C) `defineStore`
D) `makeStore`

**Answer: B**

**Explanation:** `create` is the Zustand function used to create a store: `const useStore = create((set) => ({ ... }))`

---

**62. How do you update state in a Zustand store?**

A) `setState`
B) `set`
C) `update`
D) `dispatch`

**Answer: B**

**Explanation:** `set` is used to update state in Zustand: `set((state) => ({ count: state.count + 1 }))`

---

**63. Which hook is used for local component state?**

A) `useState`
B) `useReducer`
C) Both A and B
D) `useStore`

**Answer: C**

**Explanation:** Both `useState` (simpler) and `useReducer` (complex state logic) are used for local component state.

---

**64. How do you access store values in a component?**

A) `useStore()`
B) `useStore(state => state.value)`
C) Both A and B
D) `useSelector`

**Answer: B**

**Explanation:** The recommended way is using a selector: `const value = useStore(state => state.value)` to optimize re-renders.

---

**65. What is the purpose of `useMemo`?**

A) To memoize functions
B) To memoize values
C) To memoize components
D) To manage state

**Answer: B**

**Explanation:** `useMemo` memoizes computed values, recalculating only when dependencies change.

---

**66. Which of the following is NOT a valid Zustand middleware?**

A) `persist`
B) `devtools`
C) `logger`
D) `thunk`

**Answer: D**

**Explanation:** `thunk` is a Redux middleware. Zustand has `persist`, `devtools`, and built-in support for async actions.

---

**67. How do you persist Zustand store data?**

A) `AsyncStorage` manually
B) `persist` middleware
C) Both A and B
D) Zustand doesn't support persistence

**Answer: C**

**Explanation:** Both manual implementation and the `persist` middleware can be used for persistence.

---

**68. What is the dependency array in `useEffect` used for?**

A) Running effects when specified values change
B) Running effects only on mount
C) Running effects only on unmount
D) All of the above

**Answer: D**

**Explanation:** The dependency array controls when the effect runs:
- Empty array: runs once on mount
- With dependencies: runs when dependencies change
- No array: runs on every render

---

**69. Which hook prevents unnecessary re-renders for expensive components?**

A) `useMemo`
B) `useCallback`
C) `React.memo`
D) All of the above

**Answer: D**

**Explanation:** All three help optimize performance:
- `React.memo`: Memoizes components
- `useMemo`: Memoizes values
- `useCallback`: Memoizes functions

---

**70. What is the difference between `useState` and `useReducer`?**

A) `useState` is simpler, `useReducer` handles complex state logic
B) `useState` is for objects, `useReducer` is for arrays
C) `useReducer` is faster
D) No difference

**Answer: A**

**Explanation:** `useState` is simpler for basic state. `useReducer` is better for complex state logic with multiple sub-values or when next state depends on previous state.

---

### True/False Questions

**71. Zustand requires wrapping your app in a Provider.**

**Answer: False**

**Explanation:** Unlike Redux or Context, Zustand does not require a Provider wrapper.

---

**72. `useCallback` memoizes values like `useMemo`.**

**Answer: False**

**Explanation:** `useCallback` memoizes functions, while `useMemo` memoizes values.

---

**73. Zustand stores can be used outside of React components.**

**Answer: True**

**Explanation:** Zustand stores can be used outside React components, useful for utility functions and services.

---

**74. The `persist` middleware stores all state by default.**

**Answer: True**

**Explanation:** By default, `persist` stores all state. You can use `partialize` to store only specific fields.

---

**75. `React.memo` compares props using shallow comparison by default.**

**Answer: True**

**Explanation:** `React.memo` uses shallow comparison of props to determine if re-render is needed.

---

### Short Answer Questions

**76. Compare and contrast Zustand and Redux.**

**Answer:**
- **Zustand:** Minimal boilerplate, no providers needed, simple API, smaller bundle, easier to learn. Uses hooks directly.
- **Redux:** More boilerplate, requires Provider, more complex setup, larger bundle, steeper learning curve. Uses connect or hooks.

---

**77. How do you handle async actions in Zustand?**

**Answer:**
```tsx
const useStore = create((set) => ({
  data: null,
  loading: false,
  error: null,
  fetchData: async () => {
    set({ loading: true });
    try {
      const data = await api.getData();
      set({ data, loading: false });
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },
}));
```

---

**78. Explain the concept of "lifting state up" in React Native.**

**Answer:**
"Lifting state up" means moving state from a child component to a common ancestor to share it between multiple components. This is done when two or more components need to access or modify the same data.

---

**79. When would you use `useContext` vs Zustand?**

**Answer:**
- `useContext`: For simple, infrequently changing state that is used by a few components in a small subtree.
- `Zustand`: For complex, frequently changing state that is used by many components across the entire app.

---

**80. What are selectors and why are they important in Zustand?**

**Answer:**
Selectors are functions that extract specific pieces of state from a store. They are important because they:
- Optimize re-renders (components only re-render when selected state changes)
- Allow derived state calculations
- Provide better type safety
- Make code more maintainable

---

# PART 5: DATA PERSISTENCE & OFFLINE-FIRST

## Module 5: Persistence & Offline Quiz

### Multiple Choice Questions

**81. Which storage option is fastest for key-value data in React Native?**

A) AsyncStorage
B) MMKV
C) SQLite
D) SecureStore

**Answer: B**

**Explanation:** MMKV is up to 100x faster than AsyncStorage due to its synchronous, memory-mapped approach.

---

**82. How do you encrypt sensitive data in Expo?**

A) AsyncStorage
B) MMKV
C) SecureStore
D) SQLite

**Answer: C**

**Explanation:** `expo-secure-store` provides encrypted storage using the device's secure enclave/keychain.

---

**83. What is the primary benefit of offline-first architecture?**

A) Faster development
B) Better user experience without internet
C) Reduced server costs
D) Smaller app size

**Answer: B**

**Explanation:** The primary benefit is that the app works seamlessly without internet connectivity, providing a better user experience.

---

**84. How do you handle conflicts in offline-first apps?**

A) Last Write Wins
B) Merge strategies
C) Manual resolution
D) All of the above

**Answer: D**

**Explanation:** Various conflict resolution strategies can be used:
- Last Write Wins (LWW): Most recent timestamp wins
- Merge: Combine conflicting data
- Manual: User chooses which version to keep

---

**85. What is optimistic UI?**

A) UI that is optimistic about loading times
B) UI that updates immediately, rolling back on failure
C) UI that waits for server response
D) UI that uses optimistic animations

**Answer: B**

**Explanation:** Optimistic UI updates the interface immediately when a user action occurs, then reverts if the server operation fails.

---

**86. Which SQLite method is used to create a table?**

A) `db.createTable`
B) `db.execAsync`
C) `db.run`
D) `db.execute`

**Answer: B**

**Explanation:** `db.execAsync` executes SQL statements including CREATE TABLE in Expo SQLite.

---

**87. What is a sync engine?**

A) A tool for syncing code between developers
B) A system for syncing data between local and remote
C) A tool for syncing app versions
D) A system for syncing user preferences

**Answer: B**

**Explanation:** A sync engine manages the synchronization of data between local storage and remote servers.

---

**88. How does AsyncStorage serialize data?**

A) Binary encoding
B) JSON serialization
C) XML encoding
D) Protocol Buffers

**Answer: B**

**Explanation:** AsyncStorage stores data as JSON strings and requires serialization/deserialization.

---

**89. What is the maximum size limit for AsyncStorage on iOS?**

A) ~1MB
B) ~6MB
C) ~50MB
D) Unlimited

**Answer: B**

**Explanation:** AsyncStorage on iOS has a limit of approximately 6MB due to iOS storage constraints.

---

**90. Which MMKV feature allows it to be so fast?**

A) Asynchronous operations
B) Memory-mapped files
C) SQL-like queries
D) WebView integration

**Answer: B**

**Explanation:** MMKV uses memory-mapped files, allowing synchronous reads and writes without serialization overhead.

---

### True/False Questions

**91. SQLite is slower than AsyncStorage for simple operations.**

**Answer: True**

**Explanation:** For simple key-value operations, AsyncStorage is faster. SQLite is better for complex queries and relational data.

---

**92. MMKV supports encryption out of the box.**

**Answer: True**

**Explanation:** MMKV supports encryption using an encryption key passed during initialization.

---

**93. Offline-first apps cannot sync data when online.**

**Answer: False**

**Explanation:** Offline-first apps sync data automatically when connectivity is restored.

---

**94. Conflict resolution is only needed in multi-user apps.**

**Answer: False**

**Explanation:** Conflicts can occur even in single-user apps when data is modified on multiple devices (e.g., phone and tablet).

---

**95. Optimistic UI can lead to data inconsistencies.**

**Answer: True**

**Explanation:** If the server operation fails, the optimistic update must be rolled back, which can cause temporary inconsistencies.

---

### Short Answer Questions

**96. Compare and contrast AsyncStorage, MMKV, and SQLite.**

**Answer:**
- **AsyncStorage:** Key-value, async, easy to use, limited capacity (~6MB), best for simple data.
- **MMKV:** Key-value, sync, very fast, larger capacity (~2GB), best for performance-critical data.
- **SQLite:** Relational, async, complex queries, best for structured data with relationships.

---

**97. What is the structure of a sync engine in an offline-first app?**

**Answer:**
- **Operation Queue:** Stores pending sync operations
- **Conflict Resolution:** Handles data conflicts
- **Retry Logic:** Manages retries with backoff
- **Network Detection:** Monitors connectivity
- **Background Sync:** Syncs in background

---

**98. Explain the optimistic UI pattern with a code example.**

**Answer:**
```tsx
const addTask = async (task) => {
  // Optimistic update
  useTaskStore.getState().addTask(task);
  
  try {
    await api.createTask(task);
  } catch (error) {
    // Rollback on failure
    useTaskStore.getState().removeTask(task.id);
    showError('Failed to create task');
  }
};
```

---

**99. How would you design a database schema for a task management app in SQLite?**

**Answer:**
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL
);

CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  due_date TEXT,
  assigned_to TEXT,
  FOREIGN KEY (assigned_to) REFERENCES users(id)
);

CREATE TABLE subtasks (
  id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL,
  title TEXT NOT NULL,
  completed INTEGER DEFAULT 0,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);
```

---

**100. What strategies can you use to handle conflicts in offline-first apps?**

**Answer:**
- **Last Write Wins (LWW):** Compare timestamps, keep the most recent version.
- **Merge:** Combine changes from both versions (e.g., merge tags, combine field values).
- **Manual Resolution:** Present conflicts to the user for decision.
- **CRDTs:** Use Conflict-free Replicated Data Types for automatic resolution.
- **Version Vectors:** Track versions to detect and resolve conflicts.

---

# PART 6: DEVICE CAPABILITIES

## Module 6: Device APIs Quiz

### Multiple Choice Questions

**101. Which Expo module provides camera access?**

A) `expo-camera`
B) `expo-media`
C) `expo-video`
D) `expo-image`

**Answer: A**

**Explanation:** `expo-camera` provides access to the device camera with photo and video capture.

---

**102. How do you request camera permissions in Expo?**

A) `Camera.requestPermissionsAsync()`
B) `Camera.requestCameraPermissionsAsync()`
C) `Permissions.askAsync(Permissions.CAMERA)`
D) `requestPermission('camera')`

**Answer: B**

**Explanation:** `Camera.requestCameraPermissionsAsync()` is the correct method in Expo Camera.

---

**103. Which location accuracy setting uses GPS only?**

A) Location.Accuracy.Low
B) Location.Accuracy.Balanced
C) Location.Accuracy.High
D) Location.Accuracy.BestForNavigation

**Answer: D**

**Explanation:** `BestForNavigation` uses GPS and other sensors for the highest accuracy.

---

**104. How do you get a push notification token in Expo?**

A) `Notifications.getToken()`
B) `Notifications.getExpoPushTokenAsync()`
C) `PushNotification.getToken()`
D) `getToken()`

**Answer: B**

**Explanation:** `getExpoPushTokenAsync()` returns the Expo push token for the device.

---

**105. What is the purpose of `expo-image-picker`?**

A) To edit images
B) To capture and select images
C) To compress images
D) To display images

**Answer: B**

**Explanation:** `expo-image-picker` allows taking photos with the camera or selecting from the photo library.

---

**106. How do you handle notification taps in Expo?**

A) `addNotificationTapListener`
B) `addNotificationResponseReceivedListener`
C) `addNotificationPressedListener`
D) `onNotificationTap`

**Answer: B**

**Explanation:** `addNotificationResponseReceivedListener` listens for user taps on notifications.

---

**107. Which image optimization technique reduces file size with minimal quality loss?**

A) Resizing
B) Compression
C) Format conversion
D) All of the above

**Answer: D**

**Explanation:** All three techniques (resizing, compression, format conversion) can reduce file size.

---

**108. What is the `quality` parameter in `takePictureAsync`?**

A) Image quality (0-1)
B) Image quality (0-100)
C) Image resolution
D) Image aspect ratio

**Answer: A**

**Explanation:** `quality` is a value from 0 to 1 indicating JPEG quality (0 = lowest quality, 1 = highest).

---

**109. Which method is used to get the current location?**

A) `Location.getCurrentPositionAsync()`
B) `Location.getPositionAsync()`
C) `Location.getLocation()`
D) `Location.getCoordinates()`

**Answer: A**

**Explanation:** `getCurrentPositionAsync()` is the correct method for getting the current location.

---

**110. How do you schedule a notification for a specific time?**

A) `scheduleNotificationAsync` with `trigger: { date: Date }`
B) `scheduleNotification` with `time: Date`
C) `sendNotification` with `delay: number`
D) `pushNotification` with `date: Date`

**Answer: A**

**Explanation:** `scheduleNotificationAsync` with `trigger: { date: Date }` schedules a notification at a specific time.

---

### True/False Questions

**111. The camera permission must be requested each time the app is opened.**

**Answer: False**

**Explanation:** Permission status persists across app sessions. You only need to request if the user hasn't granted permission yet.

---

**112. Location accuracy settings do not affect battery life.**

**Answer: False**

**Explanation:** Higher accuracy (GPS) uses more battery than lower accuracy (WiFi/cellular).

---

**113. Expo push notifications work on both iOS and Android without additional configuration.**

**Answer: True**

**Explanation:** Expo handles the platform-specific setup for push notifications.

---

**114. `expo-image-picker` can compress images automatically.**

**Answer: True**

**Explanation:** The `quality` parameter in `launchImageLibraryAsync` compresses the image.

---

**115. Background location tracking does not require special permissions.**

**Answer: False**

**Explanation:** Background location tracking requires additional permissions and may require special app entitlements.

---

### Short Answer Questions

**116. Describe the process of adding camera functionality to a React Native app with Expo.**

**Answer:**
1. Install `expo-camera`
2. Request permissions: `Camera.requestCameraPermissionsAsync()`
3. Render Camera component: `<Camera ref={...} type={...} />`
4. Take picture: `cameraRef.takePictureAsync()`
5. Handle result: save file, display, or upload

---

**117. How do you handle push notifications in TaskFlow? Include setup and handling.**

**Answer:**
```tsx
// Setup
import * as Notifications from 'expo-notifications';

// Request permissions
Notifications.requestPermissionsAsync();

// Get token
const token = await Notifications.getExpoPushTokenAsync();

// Handle received notifications
Notifications.addNotificationReceivedListener((notification) => {
  // Handle notification
});

// Handle notification taps
Notifications.addNotificationResponseReceivedListener((response) => {
  const data = response.notification.request.content.data;
  navigation.navigate('TaskDetail', { id: data.taskId });
});

// Send notification
await Notifications.scheduleNotificationAsync({
  content: {
    title: 'Task Reminder',
    body: 'Don\'t forget to complete your tasks!',
  },
  trigger: null,
});
```

---

**118. What are the best practices for image optimization in React Native?**

**Answer:**
- Resize images to appropriate dimensions for the device
- Compress images (quality 0.7-0.8 for JPEG)
- Use appropriate format (WebP, JPEG, PNG)
- Cache images using Image component's built-in caching
- Use progressive loading with placeholders
- Limit image resolution based on device capabilities

---

**119. How would you implement location tagging for tasks?**

**Answer:**
```tsx
const tagLocation = async () => {
  const permission = await Location.requestForegroundPermissionsAsync();
  if (!permission.granted) return;
  
  const location = await Location.getCurrentPositionAsync();
  const address = await Location.reverseGeocodeAsync({
    latitude: location.coords.latitude,
    longitude: location.coords.longitude,
  });
  
  const taskData = {
    ...task,
    location: {
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      address: address[0],
    },
  };
  
  await createTask(taskData);
};
```

---

**120. Explain the difference between foreground and background location permissions.**

**Answer:**
- **Foreground Permissions:** Allow location access only when the app is in the foreground (visible to the user). This is the standard permission level.
- **Background Permissions:** Allow location access even when the app is in the background. Requires additional permissions and may require special app store review.

---

# PART 7: GESTURES & ANIMATIONS

## Module 7: Gestures & Animations Quiz

### Multiple Choice Questions

**121. Which library provides gesture handling in React Native?**

A) `react-native-gesture-handler`
B) `react-native-gestures`
C) `expo-gestures`
D) `react-native-touch`

**Answer: A**

**Explanation:** `react-native-gesture-handler` is the standard gesture handling library for React Native.

---

**122. What is a Shared Value in Reanimated?**

A) A value shared between components
B) A value shared between threads
C) A value shared between gestures
D) A value shared between animations

**Answer: B**

**Explanation:** Shared Values in Reanimated can be accessed and modified across JavaScript and UI threads.

---

**123. Which gesture is used for swipe-to-delete?**

A) Tap
B) Pan
C) LongPress
D) Pinch

**Answer: B**

**Explanation:** Pan gesture (dragging) is used for swipe-to-delete interactions.

---

**124. How do you animate a value in Reanimated?**

A) `Animated.timing`
B) `withTiming`
C) `animate`
D) `transition`

**Answer: B**

**Explanation:** `withTiming` and `withSpring` are Reanimated's animation functions.

---

**125. What is the purpose of `useAnimatedStyle`?**

A) To create styles that update with animations
B) To create styles that persist across renders
C) To create styles for gestures
D) To create styles for components

**Answer: A**

**Explanation:** `useAnimatedStyle` creates styles that automatically update when Shared Values change.

---

**126. Which gesture is best for implementing drag-to-reorder?**

A) Tap
B) Pan
C) LongPress
D) Rotation

**Answer: B**

**Explanation:** Pan gesture handles dragging interactions, making it ideal for drag-to-reorder.

---

**127. How do you provide haptic feedback in React Native?**

A) `react-native-haptic`
B) `expo-haptics`
C) `react-native-vibration`
D) `expo-feedback`

**Answer: B**

**Explanation:** `expo-haptics` provides haptic feedback for iOS and Android.

---

**128. What is the threshold concept in swipe-to-delete?**

A) The minimum swipe distance to trigger delete
B) The maximum swipe distance allowed
C) The speed required for swipe
D) The angle required for swipe

**Answer: A**

**Explanation:** The threshold is the minimum distance the user must swipe to trigger the delete action.

---

**129. Which method creates a spring animation in Reanimated?**

A) `withTiming`
B) `withSpring`
C) `withSpringAnimation`
D) `spring`

**Answer: B**

**Explanation:** `withSpring` creates a spring-based animation in Reanimated.

---

**130. What is the purpose of `GestureDetector`?**

A) To detect gestures
B) To wrap components that need gestures
C) To handle gesture conflicts
D) To configure gesture settings

**Answer: B**

**Explanation:** `GestureDetector` wraps a component to enable gesture handling.

---

### True/False Questions

**131. Reanimated animations run on the UI thread by default.**

**Answer: True**

**Explanation:** Reanimated runs animations on the UI thread, providing 60fps performance.

---

**132. Gesture Handler supports simultaneous gestures.**

**Answer: True**

**Explanation:** Gesture Handler supports simultaneous gestures using `Gesture.Simultaneous()`.

---

**133. Haptic feedback works on all Android devices.**

**Answer: False**

**Explanation:** Not all Android devices support haptic feedback. Always check device capabilities.

---

**134. Shared Values can only be used with Reanimated.**

**Answer: True**

**Explanation:** Shared Values are a Reanimated-specific concept for cross-thread communication.

---

**135. Gesture Handler and React Native's TouchableOpacity can be used together.**

**Answer: True**

**Explanation:** You can use both, but Gesture Handler is recommended for complex gesture interactions.

---

### Short Answer Questions

**136. Explain the difference between Animated API and Reanimated 2.**

**Answer:**
- **Animated API:** Older API, runs on JavaScript thread, limited performance, simpler for basic animations.
- **Reanimated 2:** Modern API, runs on UI thread, better performance, more complex but more powerful, supports gestures and shared values.

---

**137. How do you implement swipe-to-delete in React Native?**

**Answer:**
```tsx
const SwipeableItem = ({ children, onDelete }) => {
  const translateX = useSharedValue(0);
  const THRESHOLD = -100;
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = Math.min(0, event.translationX);
    })
    .onEnd(() => {
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
        {children}
      </Animated.View>
    </GestureDetector>
  );
};
```

---

**138. What are the performance benefits of using Reanimated over Animated API?**

**Answer:**
- Reanimated runs on UI thread, avoiding bridge communication
- No JavaScript thread blocking
- 60fps performance guaranteed
- Better support for gestures and complex animations
- Lower battery consumption

---

**139. How would you implement a custom pull-to-refresh animation?**

**Answer:**
- Use Pan gesture to detect pull-down
- Track pull distance with Shared Value
- Animate a progress indicator based on pull distance
- Trigger refresh when threshold is reached
- Animate refresh completion

---

**140. Explain the concept of gesture composition in Gesture Handler.**

**Answer:**
Gesture composition allows combining multiple gestures:
- `Gesture.Simultaneous()`: Both gestures trigger simultaneously
- `Gesture.Race()`: First gesture to activate wins
- `Gesture.Exclusive()`: One gesture blocks others
- `Gesture.Sequence()`: Gestures trigger in sequence

---

# PART 8: TESTING

## Module 8: Testing Quiz

### Multiple Choice Questions

**141. Which testing library is recommended for React Native component testing?**

A) Jest
B) React Native Testing Library
C) Both A and B
D) Detox

**Answer: C**

**Explanation:** Jest is the test runner, and React Native Testing Library provides component testing utilities.

---

**142. What is the purpose of `render` in React Native Testing Library?**

A) To render a component for testing
B) To render HTML
C) To render native views
D) To render snapshots

**Answer: A**

**Explanation:** `render` renders a React Native component in a test environment for querying and interaction.

---

**143. Which tool is used for E2E testing in React Native?**

A) Jest
B) Detox
C) Cypress
D) Selenium

**Answer: B**

**Explanation:** Detox is the most common E2E testing framework for React Native apps.

---

**144. How do you simulate a press event in tests?**

A) `fireEvent.press(element)`
B) `element.simulatePress()`
C) `element.press()`
D) `press(element)`

**Answer: A**

**Explanation:** `fireEvent.press(element)` from React Native Testing Library simulates press events.

---

**145. What is a snapshot test?**

A) A test that captures an image of the component
B) A test that captures the rendered output for comparison
C) A test that captures performance metrics
D) A test that captures user interactions

**Answer: B**

**Explanation:** Snapshot tests capture the rendered output and compare it to a stored baseline to detect changes.

---

**146. Which of the following is NOT a testing level?**

A) Unit Testing
B) Integration Testing
C) System Testing
D) Component Testing

**Answer: C**

**Explanation:** System testing is a broader category that includes multiple testing levels. Unit, Integration, and Component are specific testing levels.

---

**147. What is the purpose of `jest.fn()`?**

A) To create a mock function
B) To create a test function
C) To create a spy function
D) To create an assertion

**Answer: A**

**Explanation:** `jest.fn()` creates a mock function that can track calls and return values.

---

**148. How do you test async code in Jest?**

A) Use `async/await`
B) Use `done` callback
C) Use `Promise` resolution
D) All of the above

**Answer: D**

**Explanation:** Jest supports all async testing patterns: `async/await`, `done` callback, and `Promise` resolution.

---

**149. What is the purpose of `waitFor` in testing?**

A) To wait for async operations to complete
B) To wait for a specific time
C) To wait for user input
D) To wait for network requests

**Answer: A**

**Explanation:** `waitFor` waits for async operations (like state updates) to complete before asserting.

---

**150. Which hook is used to test Zustand stores?**

A) `renderHook`
B) `testHook`
C) `useHook`
D) `hookTest`

**Answer: A**

**Explanation:** `renderHook` from `@testing-library/react-hooks` is used to test hooks and stores.

---

### True/False Questions

**151. Unit tests should test implementation details.**

**Answer: False**

**Explanation:** Unit tests should test behavior, not implementation details. Testing implementation details makes tests brittle.

---

**152. Snapshot tests replace unit tests.**

**Answer: False**

**Explanation:** Snapshot tests complement unit tests but don't replace them. They catch unintended changes but don't verify logic.

---

**153. E2E tests run faster than unit tests.**

**Answer: False**

**Explanation:** E2E tests are typically the slowest because they run on real devices/simulators and test full user journeys.

---

**154. `fireEvent.changeText` simulates typing in a TextInput.**

**Answer: True**

**Explanation:** `fireEvent.changeText` simulates user typing in a TextInput component.

---

**155. Test coverage above 80% guarantees bug-free code.**

**Answer: False**

**Explanation:** High test coverage doesn't guarantee quality. Tests must test the right things to be effective.

---

### Short Answer Questions

**156. Explain the testing pyramid and its components.**

**Answer:**
- **Unit Tests:** Fast, many, test individual functions and components in isolation.
- **Integration Tests:** Medium, fewer, test how components work together.
- **E2E Tests:** Slow, few, test complete user journeys on real devices.

---

**157. How do you test a React Native component that uses navigation?**

**Answer:**
```tsx
import { NavigationContainer } from '@react-navigation/native';

it('navigates correctly', () => {
  const navigation = useNavigation();
  const { getByText } = render(
    <NavigationContainer>
      <MyComponent navigation={navigation} />
    </NavigationContainer>
  );
  
  fireEvent.press(getByText('Go to Detail'));
  expect(navigation.navigate).toHaveBeenCalledWith('Detail', { id: '123' });
});
```

---

**158. What strategies can you use to test Zustand stores?**

**Answer:**
```tsx
import { act, renderHook } from '@testing-library/react-hooks';

it('adds task correctly', () => {
  const { result } = renderHook(() => useTaskStore());
  
  act(() => {
    result.current.addTask({ id: '1', title: 'Test' });
  });
  
  expect(result.current.tasks).toHaveLength(1);
  expect(result.current.tasks[0].title).toBe('Test');
});
```

---

**159. How would you test an async API call in a component?**

**Answer:**
```tsx
it('displays data after fetch', async () => {
  const mockData = { id: '1', name: 'Test' };
  api.getData.mockResolvedValue(mockData);
  
  const { getByText, findByText } = render(<DataComponent />);
  
  expect(getByText('Loading...')).toBeTruthy();
  await waitFor(() => expect(api.getData).toHaveBeenCalled());
  expect(await findByText('Test')).toBeTruthy();
});
```

---

**160. Explain the difference between unit and integration testing in React Native.**

**Answer:**
- **Unit Testing:** Tests individual components, functions, or hooks in isolation. Mocks dependencies. Fast and focused.
- **Integration Testing:** Tests how multiple components work together. May include real API calls or store interactions. Slower but more realistic.

---

# PART 9: PERFORMANCE OPTIMIZATION

## Module 9: Performance Quiz

### Multiple Choice Questions

**161. What is the 60 FPS target in mobile apps?**

A) 60 frames per second for smooth animations
B) 60 milliseconds to load a screen
C) 60% CPU usage target
D) 60% battery usage target

**Answer: A**

**Explanation:** 60 FPS provides smooth animations with each frame taking approximately 16.67ms.

---

**162. What tool can you use to profile React Native performance?**

A) React DevTools Profiler
B) Flipper
C) Both A and B
D) Xcode Instruments only

**Answer: C**

**Explanation:** Both React DevTools Profiler and Flipper can be used for performance profiling.

---

**163. Which FlatList prop prevents rendering off-screen items?**

A) `removeClippedSubviews`
B) `renderOffscreen`
C) `virtualize`
D) `lazyLoading`

**Answer: A**

**Explanation:** `removeClippedSubviews` removes off-screen items from the render tree to improve memory and performance.

---

**164. What is the purpose of `getItemLayout` in FlatList?**

A) To improve scrolling performance with fixed heights
B) To calculate item heights dynamically
C) To add animations to items
D) To handle item selection

**Answer: A**

**Explanation:** `getItemLayout` improves performance by providing the height/width of items, allowing FlatList to calculate offsets without measuring.

---

**165. Which of the following can cause memory leaks in React Native?**

A) Not cleaning up event listeners
B) Not canceling subscriptions
C) Not clearing intervals
D) All of the above

**Answer: D**

**Explanation:** All of these can cause memory leaks if not properly cleaned up in useEffect cleanup functions.

---

**166. How do you optimize large images in React Native?**

A) Resize and compress
B) Use WebP format
C) Cache images
D) All of the above

**Answer: D**

**Explanation:** All three strategies help optimize images: resizing/compression, format conversion, and caching.

---

**167. What is tree shaking?**

A) Removing unused code from the bundle
B) Removing unused CSS
C) Removing unused images
D) Removing unused dependencies

**Answer: A**

**Explanation:** Tree shaking removes unused code from the bundle during the build process.

---

**168. Which hook prevents unnecessary re-renders for expensive components?**

A) `useMemo`
B) `useCallback`
C) `React.memo`
D) All of the above

**Answer: D**

**Explanation:** All three help optimize performance:
- `React.memo`: Memoizes components
- `useMemo`: Memoizes values
- `useCallback`: Memoizes functions

---

**169. What is the recommended maximum bundle size for a React Native app?**

A) 5MB
B) 10MB
C) 15MB
D) 50MB

**Answer: C**

**Explanation:** A bundle size of 10-15MB is recommended for React Native apps.

---

**170. What is the purpose of `useMemo`?**

A) To memoize functions
B) To memoize values
C) To memoize components
D) To memoize hooks

**Answer: B**

**Explanation:** `useMemo` memoizes computed values, recalculating only when dependencies change.

---

### True/False Questions

**171. Lazy loading always improves performance for all screens.**

**Answer: False**

**Explanation:** Lazy loading improves startup time but can impact navigation performance if not implemented properly.

---

**172. `React.memo` performs deep comparison of props.**

**Answer: False**

**Explanation:** `React.memo` performs shallow comparison of props by default.

---

**173. Memory leaks can cause app crashes over time.**

**Answer: True**

**Explanation:** Memory leaks gradually consume memory, eventually causing app crashes.

---

**174. The Animated API uses the native driver by default.**

**Answer: False**

**Explanation:** You must explicitly enable the native driver with `useNativeDriver: true` for the Animated API.

---

**175. Bundle size has no impact on app startup time.**

**Answer: False**

**Explanation:** Larger bundles take longer to download and parse, increasing startup time.

---

### Short Answer Questions

**176. List 5 strategies for optimizing FlatList performance.**

**Answer:**
1. `removeClippedSubviews={true}` - Remove off-screen items
2. `maxToRenderPerBatch={10}` - Limit items rendered per batch
3. `windowSize={10}` - Reduce visible window
4. `getItemLayout` - Provide fixed heights for items
5. `initialNumToRender={20}` - Limit initial render

---

**177. How do you profile and identify performance bottlenecks in React Native?**

**Answer:**
1. Use React DevTools Profiler to measure render times
2. Use Flipper to monitor FPS and memory
3. Use Xcode Instruments (iOS) or Android Profiler for native performance
4. Monitor console logs for slow operations
5. Use `performance.now()` for custom timing

---

**178. Explain the difference between `useMemo` and `useCallback`.**

**Answer:**
- **useMemo:** Memoizes the result of a function call (value). Used for expensive computations.
- **useCallback:** Memoizes the function itself. Used for functions passed to child components to prevent re-renders.

---

**179. How can you reduce bundle size in a React Native app?**

**Answer:**
- Enable tree shaking in Metro config
- Lazy load screens and components
- Optimize images (resize, compress, WebP)
- Remove unused dependencies
- Use code splitting
- Minify code in production

---

**180. What are the key performance metrics to monitor in production?**

**Answer:**
- **FPS:** Frame rate (target: 60 FPS)
- **App Startup Time:** Time to interactive (target: < 2 seconds)
- **Memory Usage:** Memory consumption (target: < 50MB)
- **Bundle Size:** Download size (target: < 15MB)
- **Network Latency:** API response times
- **Crash Rate:** Percentage of sessions ending in crash

---

# PART 10: DEPLOYMENT & CI/CD

## Module 10: Deployment Quiz

### Multiple Choice Questions

**181. Which service is used for React Native builds in Expo?**

A) Expo Build
B) EAS Build
C) Expo Deploy
D) Expo Compile

**Answer: B**

**Explanation:** EAS (Expo Application Services) Build is the build service for Expo apps.

---

**182. What is required to submit an iOS app to the App Store?**

A) Apple Developer account
B) App Store Connect access
C) iOS distribution certificate
D) All of the above

**Answer: D**

**Explanation:** All three are required for iOS app submission.

---

**183. What does CI/CD stand for?**

A) Continuous Integration/Continuous Development
B) Continuous Integration/Continuous Deployment
C) Continuous Implementation/Continuous Deployment
D) Continuous Integration/Continuous Delivery

**Answer: B**

**Explanation:** CI/CD stands for Continuous Integration/Continuous Deployment (or Continuous Delivery).

---

**184. Which file contains EAS Build configuration?**

A) app.json
B) eas.json
C) build.json
D) config.json

**Answer: B**

**Explanation:** `eas.json` contains EAS Build configuration with build profiles and settings.

---

**185. What is the purpose of code signing?**

A) To ensure the app is from a trusted developer
B) To encrypt the app bundle
C) To compress the app bundle
D) To add DRM to the app

**Answer: A**

**Explanation:** Code signing ensures the app is from a trusted developer and hasn't been tampered with.

---

**186. Which GitHub Actions workflow runs on pull requests?**

A) ci.yml
B) cd.yml
C) deploy.yml
D) pr-checks.yml

**Answer: D**

**Explanation:** `pr-checks.yml` typically runs on pull requests to validate changes.

---

**187. How do you store secrets in GitHub Actions?**

A) Environment variables
B) GitHub Secrets
C) Configuration files
D) Command line arguments

**Answer: B**

**Explanation:** GitHub Secrets securely store sensitive information like API keys and passwords.

---

**188. What is the Android equivalent of Apple's App Store?**

A) Google Play Store
B) Android Market
C) Google App Store
D) Android Store

**Answer: A**

**Explanation:** Google Play Store is the official app store for Android apps.

---

**189. What is a build profile in EAS?**

A) A configuration for different environments
B) A user profile for builds
C) A performance profile
D) A security profile

**Answer: A**

**Explanation:** Build profiles (development, preview, production) configure builds for different environments.

---

**190. What is required for Android app submission?**

A) Google Play Developer account
B) Android keystore
C) Signed APK or App Bundle
D) All of the above

**Answer: D**

**Explanation:** All three are required for Android app submission.

---

### True/False Questions

**191. EAS Build can only build Expo apps.**

**Answer: True**

**Explanation:** EAS Build is designed for Expo apps, though it can be used with bare React Native projects.

---

**192. GitHub Actions can only run on push events.**

**Answer: False**

**Explanation:** GitHub Actions can be triggered by many events: push, pull_request, schedule, workflow_dispatch, etc.

---

**193. Code signing is optional for Android apps.**

**Answer: False**

**Explanation:** All Android apps must be signed before they can be published to Google Play.

---

**194. App Store submissions require manual approval only for major updates.**

**Answer: False**

**Explanation:** All App Store submissions require review by Apple's app review team.

---

**195. CI/CD pipelines can automatically deploy to app stores.**

**Answer: True**

**Explanation:** CI/CD pipelines can automate the entire deployment process, including app store submission.

---

### Short Answer Questions

**196. What are the differences between development, preview, and production builds?**

**Answer:**
- **Development:** Development client, debugging enabled, internal distribution, fast iteration.
- **Preview:** Internal distribution, testing features, not for production.
- **Production:** Store distribution, optimized, minified, production environment variables.

---

**197. How do you automate app store submissions with EAS?**

**Answer:**
```json
// eas.json
{
  "submit": {
    "production": {
      "ios": {
        "appleId": "$APPLE_ID",
        "ascAppId": "$ASC_APP_ID"
      },
      "android": {
        "track": "production",
        "serviceAccountKeyPath": "./service-account-key.json"
      }
    }
  }
}
```

```bash
# Command
eas submit --platform ios --profile production
eas submit --platform android --profile production
```

---

**198. What security measures should you implement in your CI/CD pipeline?**

**Answer:**
- Use GitHub Secrets or environment variables for sensitive data
- Never commit secrets to version control
- Use encrypted environment variables
- Implement role-based access control
- Audit all pipeline changes
- Use branch protection rules
- Scan for vulnerabilities

---

**199. How would you implement a rollback strategy for app store deployments?**

**Answer:**
- **iOS:** Submit a new version with fixes (App Store doesn't support easy rollback)
- **Android:** Publish a previous APK/AAB to the same track
- **Feature Flags:** Use feature flags to disable problematic features
- **OTA Updates:** Use Expo's over-the-air updates for quick fixes
- **Version Pinning:** Use version pinning with Firebase Remote Config

---

**200. What are the key requirements for publishing an app to the App Store and Google Play?**

**Answer:**

| Requirement | iOS | Android |
|-------------|-----|---------|
| Developer Account | Apple Developer ($99/year) | Google Play ($25 one-time) |
| App Icon | ✓ | ✓ |
| Screenshots | ✓ | ✓ |
| App Description | ✓ | ✓ |
| Privacy Policy | ✓ | ✓ |
| Code Signing | Distribution Certificate | Keystore |
| Build File | .ipa | .apk or .aab |
| Store Listing | App Store Connect | Google Play Console |

---

# FINAL EXAM

## Comprehensive Final Exam

### Part A: Multiple Choice (40 Questions)

**1. What is the React Native bridge primarily used for?**

A) Rendering components
B) Communicating between JS and Native
C) Managing state
D) Handling animations

**Answer: B**

---

**2. Which component is best for rendering large lists?**

A) ScrollView
B) FlatList
C) View
D) ListView

**Answer: B**

---

**3. What is the default flexDirection in React Native?**

A) row
B) column
C) row-reverse
D) column-reverse

**Answer: B**

---

**4. How do you create a Zustand store?**

A) `createStore`
B) `create`
C) `defineStore`
D) `makeStore`

**Answer: B**

---

**5. Which hook memoizes a function?**

A) `useMemo`
B) `useCallback`
C) `React.memo`
D) `useRef`

**Answer: B**

---

**6. What is the recommended minimum touch target size?**

A) 30x30
B) 44x44
C) 50x50
D) 60x60

**Answer: B**

---

**7. Which storage option is fastest for key-value data?**

A) AsyncStorage
B) MMKV
C) SQLite
D) SecureStore

**Answer: B**

---

**8. How do you request camera permissions in Expo?**

A) `Camera.requestPermissionsAsync()`
B) `Camera.requestCameraPermissionsAsync()`
C) `Permissions.askAsync(Permissions.CAMERA)`
D) `requestPermission('camera')`

**Answer: B**

---

**9. What is the purpose of `useEffect`?**

A) To manage state
B) To handle side effects
C) To memoize values
D) To render components

**Answer: B**

---

**10. Which library provides gesture handling?**

A) `react-native-gesture-handler`
B) `react-native-gestures`
C) `expo-gestures`
D) `react-native-touch`

**Answer: A**

---

**11. What is the Expo service for building apps?**

A) Expo Build
B) EAS Build
C) Expo Deploy
D) Expo Compile

**Answer: B**

---

**12. Which testing library is recommended for React Native?**

A) Jest
B) React Native Testing Library
C) Both A and B
D) Detox

**Answer: C**

---

**13. What is the 60 FPS target?**

A) 60 frames per second
B) 60 milliseconds per frame
C) 60% CPU usage
D) 60% battery usage

**Answer: A**

---

**14. How do you schedule a notification?**

A) `scheduleNotification`
B) `scheduleNotificationAsync`
C) `sendNotification`
D) `pushNotification`

**Answer: B**

---

**15. What is optimistic UI?**

A) UI that updates before server confirms
B) UI that waits for server response
C) UI that uses optimistic animations
D) UI that is optimistic about loading times

**Answer: A**

---

**16. Which of the following is NOT a testing level?**

A) Unit Testing
B) Integration Testing
C) System Testing
D) Component Testing

**Answer: C**

---

**17. What is the purpose of `getItemLayout` in FlatList?**

A) Improve scrolling performance
B) Calculate item heights dynamically
C) Add animations
D) Handle selection

**Answer: A**

---

**18. What is tree shaking?**

A) Removing unused code
B) Removing unused CSS
C) Removing unused images
D) Removing unused dependencies

**Answer: A**

---

**19. Which hook prevents unnecessary re-renders?**

A) `useMemo`
B) `useCallback`
C) `React.memo`
D) All of the above

**Answer: D**

---

**20. How do you get a push notification token in Expo?**

A) `Notifications.getToken()`
B) `Notifications.getExpoPushTokenAsync()`
C) `PushNotification.getToken()`
D) `getToken()`

**Answer: B**

---

**21. What is the purpose of `useAnimatedStyle`?**

A) Create styles for animations
B) Create styles for components
C) Create styles for gestures
D) Create styles for navigation

**Answer: A**

---

**22. Which gesture is used for swipe-to-delete?**

A) Tap
B) Pan
C) LongPress
D) Pinch

**Answer: B**

---

**23. What is the purpose of code signing?**

A) Ensure app is from trusted developer
B) Encrypt app bundle
C) Compress app bundle
D) Add DRM

**Answer: A**

---

**24. Which SQLite method creates a table?**

A) `db.createTable`
B) `db.execAsync`
C) `db.run`
D) `db.execute`

**Answer: B**

---

**25. What is the purpose of `useRoute`?**

A) Get navigation functions
B) Get route parameters
C) Get route history
D) Get route options

**Answer: B**

---

**26. How do you handle notification taps in Expo?**

A) `addNotificationTapListener`
B) `addNotificationResponseReceivedListener`
C) `addNotificationPressedListener`
D) `onNotificationTap`

**Answer: B**

---

**27. What is the purpose of `persist` middleware?**

A) Persist store state to storage
B) Persist component state
C) Persist navigation state
D) Persist user preferences

**Answer: A**

---

**28. Which storage option encrypts sensitive data?**

A) AsyncStorage
B) MMKV
C) SecureStore
D) SQLite

**Answer: C**

---

**29. What is the purpose of `useDebounce`?**

A) Delay function execution
B) Delay state updates
C) Delay component rendering
D) Delay network requests

**Answer: B**

---

**30. How do you test a store in Zustand?**

A) `renderStore`
B) `renderHook`
C) `testStore`
D) `hookTest`

**Answer: B**

---

**31. What is the purpose of CI/CD?**

A) Automate testing and deployment
B) Automate code writing
C) Automate design
D) Automate project management

**Answer: A**

---

**32. What is required for Android app signing?**

A) Keystore
B) Certificate
C) Both A and B
D) None of the above

**Answer: C**

---

**33. What is the purpose of `removeClippedSubviews`?**

A) Remove off-screen items from render tree
B) Remove hidden views
C) Remove unused components
D) Remove clipped text

**Answer: A**

---

**34. Which hook memoizes a value?**

A) `useMemo`
B) `useCallback`
C) `React.memo`
D) `useRef`

**Answer: A**

---

**35. What is the purpose of `expo-location`?**

A) Get device location
B) Get device orientation
C) Get device sensors
D) Get device network

**Answer: A**

---

**36. What is the purpose of `expo-image-picker`?**

A) Capture and select images
B) Edit images
C) Compress images
D) Display images

**Answer: A**

---

**37. What is the purpose of `expo-haptics`?**

A) Provide haptic feedback
B) Provide vibration feedback
C) Provide sound feedback
D) Provide visual feedback

**Answer: A**

---

**38. What is the purpose of `NavigationContainer`?**

A) Container for navigation
B) Container for screens
C) Container for components
D) Container for state

**Answer: A**

---

**39. What is the purpose of `createNativeStackNavigator`?**

A) Create stack navigator
B) Create tab navigator
C) Create drawer navigator
D) Create switch navigator

**Answer: A**

---

**40. What is the purpose of `createBottomTabNavigator`?**

A) Create stack navigator
B) Create tab navigator
C) Create drawer navigator
D) Create switch navigator

**Answer: B**

---

### Part B: True/False (20 Questions)

**41. React Native apps run in a webview.**

**Answer: False**

---

**42. The bridge in React Native is asynchronous.**

**Answer: True**

---

**43. Expo does not require native development tools.**

**Answer: True**

---

**44. FlatList renders all items at once.**

**Answer: False**

---

**45. Zustand requires a Provider wrapper.**

**Answer: False**

---

**46. MMKV is faster than AsyncStorage.**

**Answer: True**

---

**47. SecureStore encrypts stored data.**

**Answer: True**

---

**48. Gesture Handler gestures run on the UI thread.**

**Answer: True**

---

**49. EAS Build can only build Expo apps.**

**Answer: True**

---

**50. Code signing is optional for iOS apps.**

**Answer: False**

---

**51. GitHub Actions can be triggered by pull requests.**

**Answer: True**

---

**52. Snapshot tests replace unit tests.**

**Answer: False**

---

**53. Test coverage above 80% guarantees bug-free code.**

**Answer: False**

---

**54. The Animated API uses the native driver by default.**

**Answer: False**

---

**55. Bundle size has no impact on app startup time.**

**Answer: False**

---

**56. Lazy loading always improves performance for all screens.**

**Answer: False**

---

**57. React Native supports TypeScript out of the box.**

**Answer: True**

---

**58. Expo apps can be published to the App Store.**

**Answer: True**

---

**59. Deep linking allows external URLs to open specific screens.**

**Answer: True**

---

**60. Optimistic UI updates wait for server confirmation.**

**Answer: False**

---

### Part C: Short Answer (10 Questions)

**61. Explain the three threads in React Native.**

**Answer:**
- **JavaScript Thread:** Runs React code, business logic, state management
- **UI Thread:** Handles rendering, user input, animations
- **Shadow Thread:** Calculates layouts, processes flexbox

---

**62. Compare Zustand and Redux.**

**Answer:**
- **Zustand:** Minimal boilerplate, no providers, simple API, smaller bundle
- **Redux:** More boilerplate, requires Provider, more setup, larger bundle

---

**63. What is offline-first architecture and why is it important?**

**Answer:**
Offline-first architecture prioritizes local data storage and syncs with servers when online. It provides better user experience, works without internet, and ensures data availability.

---

**64. How do you implement swipe-to-delete in React Native?**

**Answer:**
Using Pan gesture with Gesture Handler and Reanimated:
- Track horizontal translation
- Apply threshold for delete
- Animate translation on swipe
- Trigger delete on threshold
- Spring back if threshold not met

---

**65. Explain the testing pyramid.**

**Answer:**
- **Unit Tests:** Fast, many, test individual functions in isolation
- **Integration Tests:** Medium, fewer, test component interactions
- **E2E Tests:** Slow, few, test complete user journeys

---

**66. What are performance optimization strategies for React Native?**

**Answer:**
- Use memo, useMemo, useCallback
- Optimize FlatList with removeClippedSubviews
- Use native animations
- Optimize images
- Lazy load screens
- Reduce bundle size

---

**67. How do you handle push notifications in TaskFlow?**

**Answer:**
- Request permissions
- Get Expo push token
- Register token with backend
- Handle received notifications
- Handle notification taps
- Navigate to appropriate screen

---

**68. What is the difference between AsyncStorage, MMKV, and SQLite?**

**Answer:**
- **AsyncStorage:** Key-value, async, simple, limited capacity
- **MMKV:** Key-value, sync, very fast, larger capacity
- **SQLite:** Relational, async, complex queries

---

**69. How do you implement authentication in React Native?**

**Answer:**
- Create auth store (Zustand) for user state
- Login/Register functions
- Store token securely (SecureStore)
- Navigation guard for protected routes
- Handle token refresh
- Logout functionality

---

**70. What are the key steps for publishing an app?**

**Answer:**
1. Create developer accounts
2. Prepare app metadata (icon, screenshots)
3. Code signing certificates
4. Build production version
5. Test on physical devices
6. Submit to stores
7. Monitor for issues
8. Respond to feedback

---

### Part D: Code Writing (5 Questions)

**71. Write a Zustand store for a counter with increment, decrement, and reset actions.**

```tsx
const useCounterStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

---

**72. Write a FlatList component with optimization props.**

```tsx
<FlatList
  data={data}
  renderItem={renderItem}
  keyExtractor={keyExtractor}
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
  windowSize={10}
  initialNumToRender={20}
  getItemLayout={(data, index) => ({
    length: 80,
    offset: 80 * index,
    index,
  })}
/>
```

---

**73. Write a swipe-to-delete component.**

```tsx
const SwipeableItem = ({ children, onDelete }) => {
  const translateX = useSharedValue(0);
  const THRESHOLD = -100;
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = Math.min(0, event.translationX);
    })
    .onEnd(() => {
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
        {children}
      </Animated.View>
    </GestureDetector>
  );
};
```

---

**74. Write a component test for a TaskCard.**

```tsx
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

---

**75. Write a push notification handler.**

```tsx
import * as Notifications from 'expo-notifications';

// Setup
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

// Request permissions
const requestPermissions = async () => {
  const { status } = await Notifications.requestPermissionsAsync();
  return status === 'granted';
};

// Get token
const getPushToken = async () => {
  const token = await Notifications.getExpoPushTokenAsync();
  return token.data;
};

// Handle notification taps
Notifications.addNotificationResponseReceivedListener((response) => {
  const data = response.notification.request.content.data;
  navigation.navigate('TaskDetail', { id: data.taskId });
});

// Send notification
await Notifications.scheduleNotificationAsync({
  content: {
    title: 'Task Reminder',
    body: 'Don\'t forget to complete your tasks!',
  },
  trigger: null,
});
```

---

### Part E: Essay Question

**76. Describe the complete architecture of TaskFlow from user interface to data persistence.**

**Answer:**

TaskFlow's architecture follows a layered approach:

**1. UI Layer:**
- React Native components (atoms, molecules, organisms)
- React Navigation for screen management (Stack, Tab, Drawer)
- Gesture Handler and Reanimated for interactions
- Design system with consistent styling

**2. State Layer:**
- Zustand stores (auth, tasks, UI, settings)
- Selectors for optimized re-renders
- Local state for component-specific data
- Zustand persistence middleware

**3. Service Layer:**
- API client for network requests
- Notification service for push notifications
- Camera and location services
- Sync engine for offline-first architecture

**4. Data Layer:**
- MMKV for fast key-value storage
- SQLite for relational task data
- AsyncStorage for simple preferences
- SecureStore for sensitive data (tokens)

**5. Offline-First Architecture:**
- Local-first data operations
- Sync queue for pending changes
- Optimistic UI updates
- Conflict resolution strategies

**6. Testing Strategy:**
- Unit tests for utilities and stores
- Component tests for UI elements
- Integration tests for feature flows
- E2E tests for critical user journeys

**7. CI/CD Pipeline:**
- GitHub Actions for automated testing
- EAS Build for app compilation
- Automated app store submissions
- Monitoring and analytics

---

## Answer Key Summary

| Question | Answer | Question | Answer | Question | Answer |
|----------|--------|----------|--------|----------|--------|
| 1 | B | 27 | A | 53 | False |
| 2 | B | 28 | C | 54 | False |
| 3 | B | 29 | B | 55 | False |
| 4 | B | 30 | B | 56 | False |
| 5 | B | 31 | A | 57 | True |
| 6 | B | 32 | C | 58 | True |
| 7 | B | 33 | A | 59 | True |
| 8 | B | 34 | A | 60 | False |
| 9 | B | 35 | A | 61 | See answer |
| 10 | A | 36 | A | 62 | See answer |
| 11 | B | 37 | A | 63 | See answer |
| 12 | C | 38 | A | 64 | See answer |
| 13 | A | 39 | A | 65 | See answer |
| 14 | B | 40 | B | 66 | See answer |
| 15 | A | 41 | False | 67 | See answer |
| 16 | C | 42 | True | 68 | See answer |
| 17 | A | 43 | True | 69 | See answer |
| 18 | A | 44 | False | 70 | See answer |
| 19 | D | 45 | False | 71 | Code writing |
| 20 | B | 46 | True | 72 | Code writing |
| 21 | A | 47 | True | 73 | Code writing |
| 22 | B | 48 | True | 74 | Code writing |
| 23 | A | 49 | True | 75 | Code writing |
| 24 | B | 50 | False | 76 | Essay |
| 25 | B | 51 | True | - | - |
| 26 | B | 52 | False | - | - |

---

**End of Quiz & Test Bank**
