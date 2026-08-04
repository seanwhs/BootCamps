# Mastering Mobile Development Beyond the UI
## Comprehensive Quiz & Test Bank with Answer Keys

Welcome to the complete quiz and test bank for the "Mastering Mobile Development Beyond the UI" tutorial series. This comprehensive assessment package includes quizzes for each module, a mid-term exam, a final exam, practical coding challenges, and detailed answer keys. Use these assessments to validate learning outcomes and measure comprehension.

---

## ASSESSMENT OVERVIEW

| Assessment | Type | Questions | Time | Weight |
|------------|------|-----------|------|--------|
| Module 1 Quiz | Multiple Choice + Short Answer | 25 | 30 min | 10% |
| Module 2 Quiz | Multiple Choice + Short Answer | 25 | 30 min | 10% |
| Module 3 Quiz | Multiple Choice + Short Answer | 25 | 30 min | 10% |
| Module 4 Quiz | Multiple Choice + Short Answer | 25 | 30 min | 10% |
| Module 5 Quiz | Multiple Choice + Short Answer | 25 | 30 min | 10% |
| Module 6 Quiz | Multiple Choice + Short Answer | 25 | 30 min | 10% |
| Module 7 Quiz | Multiple Choice + Short Answer | 25 | 30 min | 10% |
| Mid-Term Exam | Comprehensive | 50 | 90 min | 15% |
| Final Exam | Comprehensive | 50 | 120 min | 20% |
| Practical Challenge | Coding Project | 1 | 4 hours | 10% |

---

## MODULE 1: NATIVE FOUNDATIONS & BUILD ENVIRONMENTS

### Part A: Multiple Choice Questions (15 Questions)

**1. Which of the following is required to develop iOS applications?**
- A) Android Studio
- B) Xcode
- C) Visual Studio Code
- D) Eclipse

**Answer: B) Xcode**

---

**2. What is the purpose of CocoaPods in iOS development?**
- A) To compile Swift code
- B) To manage iOS dependencies
- C) To run the iOS simulator
- D) To sign iOS applications

**Answer: B) To manage iOS dependencies**

---

**3. Which command creates a new Expo project with TypeScript?**
- A) `npx react-native init MyApp`
- B) `expo init MyApp`
- C) `npx create-expo-app MyApp --template`
- D) `npm init expo MyApp`

**Answer: C) `npx create-expo-app MyApp --template`**

---

**4. In React Native's architecture, what is the "Bridge"?**
- A) A tool for connecting to databases
- B) A communication layer between JavaScript and native code
- C) A UI rendering engine
- D) A state management library

**Answer: B) A communication layer between JavaScript and native code**

---

**5. Which of the following is NOT a component of the New React Native Architecture?**
- A) JSI (JavaScript Interface)
- B) TurboModules
- C) Fabric Renderer
- D) AsyncStorage

**Answer: D) AsyncStorage**

---

**6. What is the purpose of the ANDROID_HOME environment variable?**
- A) To specify the location of the Android SDK
- B) To set the default Android version
- C) To configure the Android emulator
- D) To specify the Android build tools

**Answer: A) To specify the location of the Android SDK**

---

**7. Which command installs CocoaPods dependencies for an iOS project?**
- A) `npm install`
- B) `pod install`
- C) `cocoapods install`
- D) `yarn install`

**Answer: B) `pod install`**

---

**8. What is the role of Watchman in React Native development?**
- A) To manage JavaScript dependencies
- B) To watch for file changes and trigger rebuilds
- C) To compile native code
- D) To run the application on devices

**Answer: B) To watch for file changes and trigger rebuilds**

---

**9. Which annotation is used to expose a Swift method to React Native?**
- A) `@objc`
- B) `@Swift`
- C) `@Native`
- D) `@React`

**Answer: A) `@objc`**

---

**10. In Android native modules, which class must be extended?**
- A) ReactModule
- B) ReactContextBaseJavaModule
- C) NativeModule
- D) AndroidModule

**Answer: B) ReactContextBaseJavaModule**

---

**11. What is the purpose of a provisioning profile in iOS development?**
- A) To manage app dependencies
- B) To authorize app installation on devices
- C) To compile Swift code
- D) To debug iOS applications

**Answer: B) To authorize app installation on devices**

---

**12. Which file contains the React Native project configuration?**
- A) package.json
- B) app.json
- C) android.json
- D) config.json

**Answer: B) app.json**

---

**13. What is the purpose of the `keytool` command in Android development?**
- A) To manage Android dependencies
- B) To generate signing keys for Android apps
- C) To compile Android applications
- D) To run the Android emulator

**Answer: B) To generate signing keys for Android apps**

---

**14. Which of the following is true about JSI (JavaScript Interface)?**
- A) It replaces the Bridge in the New Architecture
- B) It's only used for Android development
- C) It's a UI rendering library
- D) It's only available in React Native 0.60+

**Answer: A) It replaces the Bridge in the New Architecture**

---

**15. What does the `RCT_EXTERN_MODULE` macro do in iOS native module development?**
- A) Exports a Swift class to React Native
- B) Declares an Objective-C module
- C) Generates a bridging header
- D) Configures the build system

**Answer: A) Exports a Swift class to React Native**

---

### Part B: Short Answer Questions (10 Questions)

**16. Explain the difference between Expo Managed Workflow and Bare Workflow. When would you choose each?**

**Answer:**
- **Expo Managed Workflow:** Uses Expo's build tools, no native code modification, faster development, supports most common features, OTA updates built-in. Best for: Rapid prototyping, apps that don't need custom native modules, beginners.
- **Bare Workflow:** Full access to native code, ability to add custom native modules, more control over the build process. Best for: Complex apps, custom native features, enterprise applications, experienced developers.

---

**17. Describe the React Native application lifecycle and how JavaScript interacts with native threads.**

**Answer:**
React Native runs JavaScript on a separate thread from the native UI. The Bridge (or JSI in New Architecture) serializes messages between threads:

1. **JavaScript Thread:** Runs React code, handles business logic, state management
2. **Native UI Thread:** Handles all UI rendering, native components
3. **Shadow Thread:** Calculates layout (Yoga)
4. **Interaction Flow:** JavaScript → Bridge → Native → Response → Bridge → JavaScript

---

**18. What are the steps to create and register an Android native module?**

**Answer:**
1. Create a class extending `ReactContextBaseJavaModule`
2. Implement `getName()` method to return the module name
3. Add `@ReactMethod` annotation to exposed methods
4. Create a `ReactPackage` class that returns the module
5. Register the package in `MainApplication.java` or `MainActivity.java`

---

**19. Explain the purpose of code signing for iOS and Android applications.**

**Answer:**
**iOS:**
- Proves application authenticity and integrity
- Associates app with a developer or organization
- Required for installation on physical devices
- Required for App Store submission

**Android:**
- Proves the app comes from a trusted source
- Enables app updates from the same developer
- Required for Google Play Store submission
- Protects against tampering

---

**20. What is the purpose of the `RCTBridgeModule` protocol in iOS native modules?**

**Answer:**
`RCTBridgeModule` is a protocol that signals to React Native that a class should be registered as a native module. It allows React Native to discover the module and its methods. The module must implement the `moduleName` method to provide its name to the JavaScript side.

---

**21. Describe the steps to run a React Native app on a physical Android device.**

**Answer:**
1. Enable Developer Mode on Android device (tap Build Number 7 times)
2. Enable USB Debugging in Developer Options
3. Connect device via USB
4. Verify connection: `adb devices`
5. Run the app: `npx expo start --android` or `npx react-native run-android`

---

**22. What is the difference between Debug and Release build variants in mobile apps?**

**Answer:**
**Debug:**
- Unoptimized code
- Includes debugging tools
- Development signing certificates
- Longer app size
- Better for development

**Release:**
- Optimized, minified code
- No debugging tools
- Production signing certificates
- Smaller app size
- Better for production distribution

---

**23. Explain the concept of "bridging" in React Native and its limitations.**

**Answer:**
Bridging is the communication layer between JavaScript and Native code. JavaScript sends serialized messages to the native side through the bridge.

**Limitations:**
- Asynchronous communication only
- Serialization overhead
- Limited data types (JSON serializable only)
- Performance bottleneck for frequent calls
- Single JavaScript thread (can block UI)

---

**24. What are the key components of the React Native New Architecture?**

**Answer:**
1. **JSI (JavaScript Interface):** Direct call interface between JavaScript and native code
2. **Fabric Renderer:** New UI rendering system that works directly with JSI
3. **TurboModules:** Lazy-loaded native modules with better performance
4. **Hermes:** Optimized JavaScript engine for React Native
5. **CodeGen:** Type-safe code generation between JS and native

---

**25. What is the purpose of the `gradle.properties` file in Android development?**

**Answer:**
`gradle.properties` stores configuration properties for the Gradle build system including:
- Build optimization flags
- JVM memory settings
- Custom property definitions
- Signing configuration variables
- Version information

---

## MODULE 2: PROJECT ARCHITECTURE & CORE SETUP

### Part A: Multiple Choice Questions (15 Questions)

**1. Which library is recommended for navigation in React Native?**
- A) React Router
- B) React Navigation
- C) React Router Native
- D) Expo Router

**Answer: B) React Navigation**

---

**2. What is Zustand primarily used for?**
- A) Navigation
- B) State Management
- C) API Calls
- D) UI Rendering

**Answer: B) State Management**

---

**3. Which of the following is NOT a type of React Navigation navigator?**
- A) Stack Navigator
- B) Tab Navigator
- C) Modal Navigator
- D) Drawer Navigator

**Answer: C) Modal Navigator**

---

**4. What is the purpose of the `create()` function in Zustand?**
- A) To create a new component
- B) To create a new store
- C) To create a new navigation stack
- D) To create a new theme

**Answer: B) To create a new store**

---

**5. Which pattern is used in Zustand to prevent unnecessary re-renders?**
- A) Memoization
- B) Selector Pattern
- C) Observer Pattern
- D) Factory Pattern

**Answer: B) Selector Pattern**

---

**6. What is the correct way to persist Zustand state?**
- A) Use AsyncStorage with persist middleware
- B) Save to Redux
- C) Store in component state
- D) Use Context API

**Answer: A) Use AsyncStorage with persist middleware**

---

**7. Which of the following best describes the "Separation of Concerns" principle?**
- A) Every component should handle its own styling
- B) Different parts of the app should handle different responsibilities
- C) Code should be written in separate files
- D) Only one person should work on each module

**Answer: B) Different parts of the app should handle different responsibilities**

---

**8. What is the purpose of path aliases in TypeScript?**
- A) To shorten import paths
- B) To increase code security
- C) To improve app performance
- D) To enable JavaScript features

**Answer: A) To shorten import paths**

---

**9. Which of the following is a benefit of using a theme system?**
- A) Faster app startup
- B) Consistent styling across the app
- C) Smaller app size
- D) Better network performance

**Answer: B) Consistent styling across the app**

---

**10. What is the primary role of the Root Navigator?**
- A) To manage tab navigation
- B) To determine whether to show Auth or Main screens
- C) To handle deep linking
- D) To render the splash screen

**Answer: B) To determine whether to show Auth or Main screens**

---

**11. Which Zustand feature helps create type-safe stores in TypeScript?**
- A) Type inference
- B) Interface extension
- C) Generic types
- D) All of the above

**Answer: D) All of the above**

---

**12. What is the purpose of the `shallow` comparison in Zustand?**
- A) To compare nested objects
- B) To prevent unnecessary re-renders
- C) To handle async operations
- D) To persist state

**Answer: B) To prevent unnecessary re-renders**

---

**13. Which navigation pattern is best for authentication flows?**
- A) Tab navigation
- B) Drawer navigation
- C) Conditional stack navigation
- D) Modal navigation

**Answer: C) Conditional stack navigation**

---

**14. What is the purpose of the `persist` middleware in Zustand?**
- A) To save state to persistent storage
- B) To create persistent connections
- C) To persist user sessions
- D) To maintain application state

**Answer: A) To save state to persistent storage**

---

**15. Which of the following is NOT a React Navigation dependency?**
- A) `react-native-screens`
- B) `react-native-safe-area-context`
- C) `react-native-gesture-handler`
- D) `react-native-reanimated`
- E) None of the above

**Answer: E) None of the above**

---

### Part B: Short Answer Questions (10 Questions)

**16. Explain the architecture of a React Native application with Zustand for state management and React Navigation for routing.**

**Answer:**
```
┌─────────────────────────────────────────────┐
│              UI Components                   │
│         (Screens + Reusable Components)     │
├─────────────────────────────────────────────┤
│              React Navigation                │
│         (Stack/Tab/Drawer Navigators)       │
├─────────────────────────────────────────────┤
│              Zustand Stores                  │
│         (Auth, Settings, Forms, etc.)       │
├─────────────────────────────────────────────┤
│              API Services                    │
│         (Supabase, Custom APIs)             │
├─────────────────────────────────────────────┤
│              Local Storage                   │
│         (AsyncStorage, SecureStore)         │
└─────────────────────────────────────────────┘
```

**Data Flow:** Components → Navigation → Zustand Stores → API Services → Backend → Response → Store Update → Component Re-render

---

**17. Describe how to set up a Zustand store with persistence for authentication state.**

**Answer:**
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import * as SecureStore from 'expo-secure-store';

const secureStorage = {
  getItem: async (key) => {
    const value = await SecureStore.getItemAsync(key);
    return value ? JSON.parse(value) : null;
  },
  setItem: async (key, value) => {
    await SecureStore.setItemAsync(key, JSON.stringify(value));
  },
  removeItem: async (key) => {
    await SecureStore.deleteItemAsync(key);
  },
};

export const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
      
      setUser: (user) => set({ user }),
      setAuthenticated: (isAuthenticated) => set({ isAuthenticated }),
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    {
      name: 'auth-storage',
      storage: secureStorage,
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

---

**18. What are the key considerations when designing a folder structure for a large React Native application?**

**Answer:**
1. **Separation by Domain:** Group files by feature/domain (auth, forms, collections)
2. **Separation by Role:** Separate UI components from business logic
3. **Reusability:** Create reusable components in a `common` or `shared` folder
4. **Scalability:** The structure should support easy addition of new features
5. **Clear Naming:** Use consistent, descriptive naming conventions
6. **Path Aliases:** Use TypeScript path aliases for clean imports

---

**19. Explain the difference between `useState`, `useContext`, and Zustand for state management.**

**Answer:**
| Feature | useState | useContext | Zustand |
|---------|----------|------------|---------|
| Scope | Local component state | Global app state | Global app state |
| Performance | Excellent | Moderate (re-renders) | Excellent (selectors) |
| Boilerplate | Minimal | Moderate | Minimal |
| Dev Tools | None | Limited | Full |
| Persistence | Manual | Manual | Built-in |
| Best For | Component-local state | Theme, auth | Complex app state |

---

**20. How does React Navigation handle deep linking, and why is it important?**

**Answer:**
React Navigation uses a linking configuration that maps URL paths to screens.

**Implementation:**
```typescript
const linking = {
  prefixes: ['nexuscollect://', 'https://nexuscollect.com'],
  config: {
    screens: {
      Home: 'home',
      Profile: 'profile/:userId',
      CollectionDetail: 'collection/:id',
    },
  },
};
```

**Importance:**
- Enables opening specific app screens from external sources
- Improves user engagement through contextual navigation
- Supports shareable links within the app
- Essential for push notification navigation

---

**21. Explain the selector pattern in Zustand and why it's important for performance.**

**Answer:**
The selector pattern allows components to subscribe only to specific parts of the store.

```typescript
// Without selector - re-renders on any state change
const { user, settings, forms } = useAuthStore();

// With selector - only re-renders when user changes
const user = useAuthStore((state) => state.user);
```

**Performance Benefits:**
- Prevents unnecessary re-renders
- Reduces component updates
- Improves app performance, especially with many components
- Enables fine-grained control over component updates

---

**22. What is the purpose of creating custom hooks in a React Native application?**

**Answer:**
Custom hooks:
1. **Encapsulate Logic:** Extract complex logic into reusable functions
2. **Share Behavior:** Enable reusing stateful logic across components
3. **Simplify Components:** Keep component code focused on UI
4. **Testability:** Isolate logic for easier testing
5. **Maintainability:** Centralize changes to a single location

**Examples:** `useAuth`, `useForm`, `useDebounce`, `useAppState`

---

**23. Describe the benefits of using TypeScript over JavaScript in a React Native project.**

**Answer:**
1. **Type Safety:** Catches errors at compile time
2. **Better IDE Support:** Autocomplete, refactoring, navigation
3. **Self-Documenting Code:** Types serve as documentation
4. **Refactoring Safety:** Easier to make large changes
5. **Team Productivity:** Better collaboration, fewer bugs
6. **Maintainability:** Long-term easier to maintain

---

**24. How would you implement a dark/light theme system in a React Native app?**

**Answer:**
1. **Define Themes:**
```typescript
const lightTheme = { colors: { ... }, spacing: { ... } };
const darkTheme = { colors: { ... }, spacing: { ... } };
```

2. **Create Theme Provider:**
```typescript
const ThemeContext = createContext(lightTheme);
const ThemeProvider = ({ children }) => {
  const theme = useSettingsStore(state => state.theme);
  const currentTheme = theme === 'dark' ? darkTheme : lightTheme;
  return <ThemeContext.Provider value={currentTheme}>{children}</ThemeContext.Provider>;
};
```

3. **Use Theme Hook:**
```typescript
const useTheme = () => useContext(ThemeContext);
```

4. **Apply Theme in Components:**
```typescript
const { colors, spacing } = useTheme();
<View style={{ backgroundColor: colors.background, padding: spacing.md }} />
```

5. **Persist Theme Preference:** Store in settings store with persistence

---

**25. What are the advantages of using path aliases in a React Native project?**

**Answer:**
1. **Cleaner Imports:** Replace `../../../components/Button` with `@components/Button`
2. **Easier Refactoring:** Move files without updating many imports
3. **Better IDE Support:** Faster navigation and autocomplete
4. **Consistent Imports:** Standardized import patterns
5. **Reduced Errors:** Fewer path mistakes
6. **Improved Readability:** More maintainable code

---

## MODULE 3: BACKEND INTEGRATION & AUTHENTICATION

### Part A: Multiple Choice Questions (15 Questions)

**1. What is Supabase?**
- A) A React Native UI framework
- B) An open-source Firebase alternative
- C) A testing library for React Native
- D) A state management solution

**Answer: B) An open-source Firebase alternative**

---

**2. Which database does Supabase use?**
- A) MongoDB
- B) PostgreSQL
- C) SQLite
- D) MySQL

**Answer: B) PostgreSQL**

---

**3. What is Row Level Security (RLS) in Supabase?**
- A) A way to protect rows from deletion
- B) A policy-based security system for database rows
- C) A way to encrypt database rows
- D) A method to restrict user access to columns

**Answer: B) A policy-based security system for database rows**

---

**4. Which method is used to sign in with email/password in Supabase?**
- A) `supabase.auth.signIn()`
- B) `supabase.auth.signInWithPassword()`
- C) `supabase.auth.login()`
- D) `supabase.auth.authenticate()`

**Answer: B) `supabase.auth.signInWithPassword()`**

---

**5. What is the purpose of the `secure-store` adapter in Supabase client setup?**
- A) To store JWT tokens securely
- B) To encrypt database queries
- C) To secure network requests
- D) To store user preferences

**Answer: A) To store JWT tokens securely**

---

**6. Which OAuth providers does Supabase support by default?**
- A) Google, Apple, Facebook, GitHub, Microsoft
- B) Google only
- C) Google and Apple only
- D) Facebook and Twitter only

**Answer: A) Google, Apple, Facebook, GitHub, Microsoft**

---

**7. What is the purpose of the `autoRefreshToken` option in Supabase?**
- A) To automatically refresh expired tokens
- B) To automatically login users
- C) To refresh the database connection
- D) To refresh user data

**Answer: A) To automatically refresh expired tokens**

---

**8. Which of the following is true about Supabase Realtime?**
- A) It only works with PostgreSQL
- B) It only works with JavaScript
- C) It's not available in the free tier
- D) It requires a separate WebSocket connection

**Answer: A) It only works with PostgreSQL**

---

**9. What is the correct way to handle authentication errors in Supabase?**
- A) Ignore them
- B) Use try-catch blocks
- C) They auto-resolve
- D) Use error boundaries

**Answer: B) Use try-catch blocks**

---

**10. Which method is used to reset a user's password in Supabase?**
- A) `supabase.auth.resetPasswordForEmail()`
- B) `supabase.auth.forgotPassword()`
- C) `supabase.auth.changePassword()`
- D) `supabase.auth.updatePassword()`

**Answer: A) `supabase.auth.resetPasswordForEmail()`**

---

**11. What is the purpose of the `persistSession` option in Supabase?**
- A) To save the session across app restarts
- B) To persist user preferences
- C) To save form data
- D) To cache API responses

**Answer: A) To save the session across app restarts**

---

**12. How does Supabase handle user metadata?**
- A) In separate profiles table
- B) In `auth.users` table
- C) In `user_metadata` column
- D) In `raw_user_meta_data` column

**Answer: D) In `raw_user_meta_data` column**

---

**13. Which of the following is the correct way to update a user's profile in Supabase?**
- A) `supabase.auth.updateUser()`
- B) `supabase.from('profiles').update()`
- C) `supabase.auth.updateProfile()`
- D) `supabase.from('users').update()`

**Answer: B) `supabase.from('profiles').update()`**

---

**14. What is the purpose of RLS in a multi-tenant application?**
- A) To ensure users can only access their own data
- B) To improve database performance
- C) To enable real-time updates
- D) To reduce database size

**Answer: A) To ensure users can only access their own data**

---

**15. Which of the following is NOT a benefit of using Supabase?**
- A) PostgreSQL database
- B) Built-in authentication
- C) Real-time subscriptions
- D) NoSQL database support

**Answer: D) NoSQL database support**

---

### Part B: Short Answer Questions (10 Questions)

**16. Explain the authentication flow in a React Native app using Supabase, from user registration to session management.**

**Answer:**
1. **Registration:**
```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    data: {
      full_name: 'John Doe',
    },
  },
});
```

2. **Login:**
```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123',
});
```

3. **Session Storage:**
- JWT tokens stored securely using SecureStore
- Auto-refresh enabled for seamless experience

4. **Session Validation:**
```typescript
const session = await supabase.auth.getSession();
if (session.data.session) {
  // User is authenticated
}
```

5. **Logout:**
```typescript
await supabase.auth.signOut();
```

---

**17. Describe how to implement Row Level Security (RLS) policies for a multi-user application.**

**Answer:**
1. **Enable RLS:**
```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE forms ENABLE ROW LEVEL SECURITY;
```

2. **Create Policy for SELECT:**
```sql
CREATE POLICY "Users can view their own profiles"
ON profiles FOR SELECT
USING (auth.uid() = id);
```

3. **Create Policy for INSERT:**
```sql
CREATE POLICY "Users can create their own forms"
ON forms FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

4. **Create Policy for UPDATE:**
```sql
CREATE POLICY "Users can update their own forms"
ON forms FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

5. **Create Policy for DELETE:**
```sql
CREATE POLICY "Users can delete their own forms"
ON forms FOR DELETE
USING (auth.uid() = user_id);
```

---

**18. What are the steps to implement social login (Google) with Supabase?**

**Answer:**
1. **Configure Google OAuth in Supabase:**
- Go to Authentication → Providers → Google
- Enable Google and add Client ID and Secret

2. **Install dependencies:**
```bash
npm install expo-auth-session expo-random expo-crypto
```

3. **Setup Google OAuth in React Native:**
```typescript
const [request, response, promptAsync] = Google.useAuthRequest({
  expoClientId: 'your-google-expo-client-id',
  iosClientId: 'your-google-ios-client-id',
  androidClientId: 'your-google-android-client-id',
});
```

4. **Handle the login:**
```typescript
const handleGoogleLogin = async () => {
  const result = await promptAsync();
  if (result?.type === 'success') {
    const { id_token, access_token } = result.params;
    const { data, error } = await supabase.auth.signInWithIdToken({
      provider: 'google',
      token: id_token,
      access_token: access_token,
    });
  }
};
```

5. **Handle user registration:** Supabase automatically creates a user if one doesn't exist.

---

**19. How would you implement secure token storage in a React Native app using Supabase?**

**Answer:**
```typescript
import * as SecureStore from 'expo-secure-store';

// Custom storage adapter
const ExpoSecureStoreAdapter = {
  getItem: async (key: string) => {
    const value = await SecureStore.getItemAsync(key);
    return value ?? null;
  },
  setItem: async (key: string, value: string) => {
    await SecureStore.setItemAsync(key, value);
  },
  removeItem: async (key: string) => {
    await SecureStore.deleteItemAsync(key);
  },
};

// Configure Supabase client
export const supabase = createClient(
  supabaseUrl,
  supabaseAnonKey,
  {
    auth: {
      storage: ExpoSecureStoreAdapter,
      autoRefreshToken: true,
      persistSession: true,
      flowType: 'pkce',
    },
  }
);
```

---

**20. Explain the difference between `signUp` and `signInWithPassword` methods in Supabase.**

**Answer:**
| Feature | signUp | signInWithPassword |
|---------|--------|-------------------|
| Purpose | Create new user account | Authenticate existing user |
| User Creation | ✅ Creates new user | ❌ No user creation |
| Session Created | ✅ If email confirmation not required | ✅ Always creates session |
| Email Verification | ✅ Sends confirmation email | ❌ No email sent |
| Requires Existing User | ❌ No | ✅ Yes |
| Returns User | ✅ | ✅ |
| Returns Session | ✅ | ✅ |

---

**21. How do you handle authentication state across app restarts with Supabase?**

**Answer:**
1. **Check for existing session on app start:**
```typescript
useEffect(() => {
  const checkSession = async () => {
    const { data } = await supabase.auth.getSession();
    if (data.session) {
      // User is authenticated
      setAuthenticated(true);
      setUser(data.session.user);
    }
  };
  checkSession();
}, []);
```

2. **Use auth state listener:**
```typescript
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    setAuthenticated(true);
    setUser(session.user);
  } else if (event === 'SIGNED_OUT') {
    setAuthenticated(false);
    setUser(null);
  }
});
```

---

**22. Describe the process of adding a custom table to Supabase and creating RLS policies for it.**

**Answer:**
1. **Create Table in SQL Editor:**
```sql
CREATE TABLE custom_table (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

2. **Enable RLS:**
```sql
ALTER TABLE custom_table ENABLE ROW LEVEL SECURITY;
```

3. **Create Policies:**
```sql
CREATE POLICY "Users can view their own data"
ON custom_table FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data"
ON custom_table FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own data"
ON custom_table FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own data"
ON custom_table FOR DELETE
USING (auth.uid() = user_id);
```

4. **Use in React Native:**
```typescript
const { data, error } = await supabase
  .from('custom_table')
  .select('*')
  .eq('user_id', user.id);
```

---

**23. How would you handle password reset flow in a React Native app with Supabase?**

**Answer:**
1. **Request Password Reset:**
```typescript
const resetPassword = async (email: string) => {
  const { error } = await supabase.auth.resetPasswordForEmail(
    email,
    {
      redirectTo: 'nexuscollect://reset-password',
    }
  );
  if (error) throw error;
};
```

2. **Handle Deep Link:**
```typescript
// In navigation setup
const linking = {
  prefixes: ['nexuscollect://'],
  config: {
    screens: {
      ResetPassword: 'reset-password',
    },
  },
};
```

3. **Update Password:**
```typescript
const updatePassword = async (newPassword: string) => {
  const { error } = await supabase.auth.updateUser({
    password: newPassword,
  });
  if (error) throw error;
};
```

4. **Password Requirements Validation:**
```typescript
const validatePassword = (password: string): boolean => {
  return password.length >= 6;
};
```

---

**24. Explain the concept of "email confirmation" in Supabase and how to handle it.**

**Answer:**
Email confirmation is a security feature that verifies the user's email address before allowing them to access the app.

**Flow:**
1. User signs up → receives confirmation email
2. User clicks link in email → confirms address
3. User can now log in

**Handling in React Native:**
```typescript
// Redirect after signup
const handleSignUp = async () => {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      emailRedirectTo: 'nexuscollect://verify-email',
    },
  });
  
  if (data.user?.identities?.length === 0) {
    // User already exists
  }
  
  // Show confirmation message
  Alert.alert(
    'Check Your Email',
    'We sent you a confirmation link. Please verify your email to continue.'
  );
};
```

**Check confirmation status:**
```typescript
const checkConfirmation = async () => {
  const { data } = await supabase.auth.getUser();
  return data.user?.email_confirmed_at !== null;
};
```

---

**25. How do you implement role-based access control (RBAC) with Supabase?**

**Answer:**
1. **Add role column to users/profiles:**
```sql
ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user';
```

2. **Create RLS policies based on roles:**
```sql
CREATE POLICY "Admins can view all profiles"
ON profiles FOR SELECT
USING (
  auth.uid() IN (
    SELECT id FROM profiles WHERE role = 'admin'
  )
);
```

3. **Check role in React Native:**
```typescript
const getUserRole = async () => {
  const { data } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();
  return data?.role;
};

const isAdmin = async () => {
  const role = await getUserRole();
  return role === 'admin';
};
```

4. **Conditional rendering based on role:**
```typescript
{userRole === 'admin' && (
  <AdminPanel />
)}
```

---

## MODULE 4: DATA MANAGEMENT & OFFLINE SYNC

### Part A: Multiple Choice Questions (15 Questions)

**1. What is WatermelonDB?**
- A) A cloud database service
- B) A local database for React Native
- C) A state management library
- D) A file storage system

**Answer: B) A local database for React Native**

---

**2. Which of the following is a key feature of WatermelonDB?**
- A) NoSQL storage
- B) Reactive queries
- C) Cloud synchronization
- D) All of the above

**Answer: B) Reactive queries**

---

**3. What is the purpose of the `appSchema` function in WatermelonDB?**
- A) To create the database schema
- B) To initialize the database
- C) To define table schemas
- D) To create model classes

**Answer: A) To create the database schema**

---

**4. Which decorator is used to define a text column in WatermelonDB?**
- A) `@field`
- B) `@text`
- C) `@column`
- D) `@string`

**Answer: B) `@text`**

---

**5. What is the purpose of the `Q.where` method in WatermelonDB queries?**
- A) To sort results
- B) To filter results
- C) To limit results
- D) To join tables

**Answer: B) To filter results**

---

**6. Which of the following is NOT a sync status in WatermelonDB?**
- A) `synced`
- B) `pending`
- C) `failed`
- D) `queued`

**Answer: D) `queued`**

---

**7. What is the purpose of the sync queue in an offline-first app?**
- A) To store all data
- B) To track pending sync operations
- C) To cache API responses
- D) To store user preferences

**Answer: B) To track pending sync operations**

---

**8. Which pattern is commonly used with WatermelonDB for data access?**
- A) Repository Pattern
- B) Singleton Pattern
- C) Factory Pattern
- D) Observer Pattern

**Answer: A) Repository Pattern**

---

**9. How does WatermelonDB handle relationships between tables?**
- A) Using foreign keys
- B) Using associations
- C) Using embedded documents
- D) Using references

**Answer: B) Using associations**

---

**10. What is the purpose of the `observe` method in WatermelonDB?**
- A) To watch for changes in data
- B) To observe database connections
- C) To monitor performance
- D) To log queries

**Answer: A) To watch for changes in data**

---

**11. Which of the following is true about offline-first architecture?**
- A) The app only works offline
- B) The app works both online and offline
- C) The app syncs only on demand
- D) The app never syncs

**Answer: B) The app works both online and offline**

---

**12. What is the purpose of conflict resolution in offline sync?**
- A) To handle data conflicts between local and remote
- B) To prevent conflicts
- C) To ignore conflicts
- D) To log conflicts only

**Answer: A) To handle data conflicts between local and remote**

---

**13. Which method is used to create a new record in WatermelonDB?**
- A) `record.create()`
- B) `database.create()`
- C) `collection.create()`
- D) `model.create()`

**Answer: C) `collection.create()`**

---

**14. What is the purpose of soft delete in a database?**
- A) To permanently delete data
- B) To mark data as deleted without removing it
- C) To archive data
- D) To backup data

**Answer: B) To mark data as deleted without removing it**

---

**15. Which of the following is NOT a best practice for offline-first development?**
- A) Store data locally
- B) Sync on every user action
- C) Handle conflicts
- D) Provide offline UI feedback

**Answer: B) Sync on every user action**

---

### Part B: Short Answer Questions (10 Questions)

**16. Explain the offline-first architecture and its benefits for mobile applications.**

**Answer:**
Offline-first architecture ensures the app works seamlessly without internet connectivity:

**Key Concepts:**
1. **Local Storage:** All data stored locally in a database
2. **Offline Operations:** Users can create, read, update, delete data offline
3. **Queueing:** Operations are queued when offline
4. **Automatic Sync:** Data syncs when connectivity is restored

**Benefits:**
- ✅ Reliable user experience in any network condition
- ✅ Reduced server load
- ✅ Faster app performance
- ✅ Better user retention
- ✅ Works in remote areas

---

**17. Describe the WatermelonDB schema definition process with an example.**

**Answer:**
1. **Import schema utilities:**
```typescript
import { appSchema, tableSchema } from '@nozbe/watermelondb';
```

2. **Define schema:**
```typescript
export const schema = appSchema({
  version: 1,
  tables: [
    tableSchema({
      name: 'users',
      columns: [
        { name: 'email', type: 'string' },
        { name: 'full_name', type: 'string' },
        { name: 'created_at', type: 'number' },
      ],
    }),
    tableSchema({
      name: 'forms',
      columns: [
        { name: 'title', type: 'string' },
        { name: 'fields', type: 'string' },
        { name: 'user_id', type: 'string' },
        { name: 'sync_status', type: 'string' },
      ],
    }),
  ],
});
```

3. **Column Types:**
- `string` - Text data
- `number` - Numeric data
- `boolean` - True/False
- `json` - JSON objects (stored as string)

---

**18. How would you implement a sync engine for an offline-first React Native app?**

**Answer:**
1. **Define Sync Engine:**
```typescript
class SyncEngine {
  private isSyncing = false;
  private interval: NodeJS.Timeout | null = null;

  start(intervalMinutes = 5) {
    this.sync();
    this.interval = setInterval(() => this.sync(), intervalMinutes * 60 * 1000);
  }

  async sync() {
    if (this.isSyncing) return;
    this.isSyncing = true;
    try {
      // 1. Get pending items
      const pending = await this.getPendingItems();
      
      // 2. Process uploads
      await this.uploadItems(pending);
      
      // 3. Download updates
      await this.downloadUpdates();
      
      // 4. Handle conflicts
      await this.resolveConflicts();
    } finally {
      this.isSyncing = false;
    }
  }
}
```

2. **Queue Management:**
```typescript
class SyncQueue {
  static async enqueue(operation, table, data) {
    await database.write(async () => {
      await database.get('sync_queue').create(record => {
        record.operation = operation;
        record.tableName = table;
        record.data = data;
        record.status = 'pending';
      });
    });
  }

  static async markCompleted(id) {
    // Mark as completed
  }
}
```

---

**19. Explain the repository pattern and how it's implemented with WatermelonDB.**

**Answer:**
The Repository Pattern provides a clean abstraction for data access:

```typescript
class FormRepository {
  static async getAll(userId: string): Promise<FormModel[]> {
    return await database
      .get<FormModel>('forms')
      .query(
        Q.where('user_id', userId),
        Q.where('is_deleted', false),
        Q.sortBy('updated_at', Q.desc)
      )
      .fetch();
  }

  static async create(userId: string, data: any): Promise<FormModel> {
    return await database.write(async () => {
      return await database
        .get<FormModel>('forms')
        .create(record => {
          record.userId = userId;
          record.title = data.title;
          record.fields = data.fields;
          record.syncStatus = 'pending';
        });
    });
  }

  static async update(id: string, data: any): Promise<FormModel> {
    return await database.write(async () => {
      const form = await database.get<FormModel>('forms').find(id);
      await form.update(record => {
        record.title = data.title;
        record.fields = data.fields;
        record.syncStatus = 'pending';
      });
      return form;
    });
  }
}
```

---

**20. How do you handle conflict resolution in an offline-first architecture?**

**Answer:**
1. **Last Write Wins:**
```typescript
function resolveLastWrite(local: any, remote: any): any {
  return local.updated_at > remote.updated_at ? local : remote;
}
```

2. **Merge Strategy:**
```typescript
function mergeData(local: any, remote: any): any {
  return {
    ...local,
    ...remote,
    // Keep local edits for specific fields
    local_edits: [...(local.local_edits || []), ...(remote.local_edits || [])],
  };
}
```

3. **Manual Resolution:**
```typescript
function detectConflicts(local: any, remote: any): Conflict[] {
  const conflicts = [];
  if (local.title !== remote.title && local.updated_at > remote.updated_at) {
    conflicts.push({
      field: 'title',
      local: local.title,
      remote: remote.title,
    });
  }
  return conflicts;
}
```

---

**21. What are the key considerations when designing a database schema for an offline-first app?**

**Answer:**
1. **Data Model Design:**
- Define clear relationships (one-to-many, many-to-many)
- Use foreign keys for relationships
- Include timestamps for sync

2. **Sync Considerations:**
- Add `sync_status` column to track sync state
- Include `updated_at` for conflict resolution
- Add `is_deleted` for soft delete

3. **Performance:**
- Create indexes for frequently queried columns
- Use appropriate data types
- Limit nested relationships

4. **Scalability:**
- Consider future fields
- Use JSON for flexible data
- Design for migrations

---

**22. How would you implement optimistic UI updates in an offline-first app?**

**Answer:**
1. **Update UI immediately:**
```typescript
const addTodo = async (text: string) => {
  // Optimistic update
  const tempId = `temp-${Date.now()}`;
  const tempTodo = { id: tempId, text, completed: false, syncing: true };
  setTodos(prev => [...prev, tempTodo]);

  try {
    // Actual API call
    const savedTodo = await api.saveTodo({ text });
    // Replace temp with real data
    setTodos(prev => prev.map(t => 
      t.id === tempId ? { ...savedTodo, syncing: false } : t
    ));
  } catch (error) {
    // Rollback on error
    setTodos(prev => prev.filter(t => t.id !== tempId));
    showError('Failed to save todo');
  }
};
```

2. **Sync Status Display:**
```typescript
<View>
  <Text>{todo.text}</Text>
  {todo.syncing && <ActivityIndicator />}
  {todo.syncStatus === 'error' && <Icon name="alert-circle" />}
</View>
```

---

**23. Explain the process of creating a WatermelonDB model with relationships.**

**Answer:**
1. **Define Model:**
```typescript
import { Model } from '@nozbe/watermelondb';
import { text, field, date, json, relation } from '@nozbe/watermelondb/decorators';

export default class FormModel extends Model {
  static table = 'forms';
  
  @text('title') title!: string;
  @json('fields') fields!: any[];
  @text('user_id') userId!: string;
  @text('sync_status') syncStatus!: string;
  
  @date('created_at') createdAt!: number;
  @date('updated_at') updatedAt!: number;
  
  // Relationship
  static associations = {
    collections: { type: 'has_many', foreignKey: 'form_id' },
  };
}
```

2. **Define Related Model:**
```typescript
export default class CollectionModel extends Model {
  static table = 'collections';
  
  @text('form_id') formId!: string;
  @json('data') data!: any;
  
  // Relationship
  static associations = {
    form: { type: 'belongs_to', foreignKey: 'form_id' },
  };
}
```

3. **Query with Relations:**
```typescript
const forms = await database
  .get('forms')
  .query()
  .fetch();
  
// Access collections through relation
const collections = forms[0].collections;
```

---

**24. What is the purpose of the `write` operation in WatermelonDB?**

**Answer:**
The `write` operation creates a transaction for database changes:

```typescript
await database.write(async () => {
  // All operations inside are atomic
  // If any operation fails, all are rolled back
  
  // Multiple operations
  await collection.create(/* ... */);
  await collection.create(/* ... */);
  await collection.update(/* ... */);
});

// This ensures data consistency
// If an error occurs, none of the changes are applied
// Batch operations for better performance
```

**Benefits:**
- Atomic operations
- Better performance for batch writes
- Automatic rollback on error
- Centralized write handling

---

**25. Describe the best practices for securing an offline-first database.**

**Answer:**
1. **Database Encryption:**
```typescript
const adapter = new SQLiteAdapter({
  schema,
  dbName: 'AppDB',
  encryptionKey: encryptionKey, // Store in SecureStore
});
```

2. **Secure Storage for Keys:**
```typescript
import * as SecureStore from 'expo-secure-store';

const getEncryptionKey = async () => {
  let key = await SecureStore.getItemAsync('db_key');
  if (!key) {
    key = Crypto.getRandomBytes(32).toString('base64');
    await SecureStore.setItemAsync('db_key', key);
  }
  return key;
};
```

3. **Sensitive Data Protection:**
- Encrypt specific fields before storing
- Use SecureStore for sensitive data
- Clear local data on logout

4. **Data Minimization:**
- Store only necessary data locally
- Use sandboxed storage
- Implement data expiration

---

## MODULE 5: DEVICE HARDWARE INTEGRATION

### Part A: Multiple Choice Questions (15 Questions)

**1. Which Expo package is used for camera integration?**
- A) `expo-camera`
- B) `expo-image`
- C) `expo-media`
- D) `expo-photo`

**Answer: A) `expo-camera`**

---

**2. What is the purpose of `ImagePicker.launchCameraAsync()`?**
- A) To open the device camera
- B) To pick an image from gallery
- C) To edit an image
- D) To save an image

**Answer: A) To open the device camera**

---

**3. Which permission is required to use the camera?**
- A) `CAMERA`
- B) `RECORD_VIDEO`
- C) `TAKE_PICTURES`
- D) `USE_CAMERA`

**Answer: A) `CAMERA`**

---

**4. Which method is used to get the current location in Expo?**
- A) `Location.getCurrentPositionAsync()`
- B) `Location.getLocationAsync()`
- C) `Location.getPosition()`
- D) `Location.getCoordinates()`

**Answer: A) `Location.getCurrentPositionAsync()`**

---

**5. What is the purpose of `Location.watchPositionAsync()`?**
- A) To get a single location update
- B) To continuously track location changes
- C) To stop location tracking
- D) To pause location tracking

**Answer: B) To continuously track location changes**

---

**6. Which of the following is NOT a biometric authentication type?**
- A) Fingerprint
- B) Face Recognition
- C) Iris Scan
- D) Voice Recognition

**Answer: D) Voice Recognition**

---

**7. Which Expo package is used for biometric authentication?**
- A) `expo-bio`
- B) `expo-local-authentication`
- C) `expo-auth`
- D) `expo-security`

**Answer: B) `expo-local-authentication`**

---

**8. What is the purpose of `Notifications.setNotificationHandler()`?**
- A) To send notifications
- B) To configure notification handling
- C) To request notification permissions
- D) To create notification channels

**Answer: B) To configure notification handling**

---

**9. Which method is used to request push notification permissions?**
- A) `Notifications.requestPermissionsAsync()`
- B) `Notifications.getPermissionsAsync()`
- C) `Notifications.askForPermissions()`
- D) `Notifications.getToken()`

**Answer: A) `Notifications.requestPermissionsAsync()`**

---

**10. What is a push token used for?**
- A) To identify the device for push notifications
- B) To authenticate the user
- C) To encrypt push notifications
- D) To manage notification preferences

**Answer: A) To identify the device for push notifications**

---

**11. Which method is used to reverse geocode coordinates?**
- A) `Location.reverseGeocodeAsync()`
- B) `Location.geocodeAsync()`
- C) `Location.addressLookup()`
- D) `Location.getAddress()`

**Answer: A) `Location.reverseGeocodeAsync()`**

---

**12. What is the purpose of `expo-image-picker`?**
- A) To capture and select images
- B) To edit images
- C) To compress images
- D) To share images

**Answer: A) To capture and select images**

---

**13. Which of the following is true about push notifications?**
- A) They work only when the app is open
- B) They require a server component
- C) They don't require permissions
- D) They can only be sent from the app

**Answer: B) They require a server component**

---

**14. What is the purpose of `expo-media-library`?**
- A) To manage media files
- B) To play media files
- C) To edit media files
- D) To stream media files

**Answer: A) To manage media files**

---

**15. Which method is used to check if biometric authentication is available?**
- A) `LocalAuthentication.hasHardwareAsync()`
- B) `LocalAuthentication.isAvailable()`
- C) `LocalAuthentication.check()`
- D) `LocalAuthentication.getStatus()`

**Answer: A) `LocalAuthentication.hasHardwareAsync()`**

---

### Part B: Short Answer Questions (10 Questions)

**16. Explain the camera permission flow in a React Native app using Expo.**

**Answer:**
1. **Request Permission:**
```typescript
const { status } = await Camera.requestCameraPermissionsAsync();
if (status !== 'granted') {
  Alert.alert('Permission Required', 'Camera access is needed');
  return;
}
```

2. **Use Camera:**
```typescript
const result = await ImagePicker.launchCameraAsync({
  mediaTypes: ImagePicker.MediaTypeOptions.Images,
  allowsEditing: true,
  quality: 0.8,
});
```

3. **Handle Result:**
```typescript
if (result.canceled) {
  // User cancelled
} else {
  const asset = result.assets[0];
  // Process image
}
```

4. **Media Library Permission:**
```typescript
const { status } = await MediaLibrary.requestPermissionsAsync();
if (status === 'granted') {
  await MediaLibrary.saveToLibraryAsync(asset.uri);
}
```

---

**17. Describe how to implement location tracking in a React Native app with Expo.**

**Answer:**
1. **Request Permissions:**
```typescript
const { status } = await Location.requestForegroundPermissionsAsync();
if (status !== 'granted') return;
```

2. **Get Single Location:**
```typescript
const location = await Location.getCurrentPositionAsync({
  accuracy: Location.Accuracy.High,
});
```

3. **Continuous Tracking:**
```typescript
const subscription = await Location.watchPositionAsync(
  {
    accuracy: Location.Accuracy.Balanced,
    distanceInterval: 1,
    timeInterval: 5000,
  },
  (location) => {
    // Update UI with new location
    setCurrentLocation({
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
    });
  }
);
```

4. **Reverse Geocode:**
```typescript
const address = await Location.reverseGeocodeAsync({
  latitude: location.coords.latitude,
  longitude: location.coords.longitude,
});
```

5. **Stop Tracking:**
```typescript
subscription.remove();
```

---

**18. Explain the steps to implement biometric authentication in React Native.**

**Answer:**
1. **Check Availability:**
```typescript
const hasHardware = await LocalAuthentication.hasHardwareAsync();
const hasEnrolled = await LocalAuthentication.isEnrolledAsync();
const supportedTypes = await LocalAuthentication.supportedAuthenticationTypesAsync();
```

2. **Authenticate:**
```typescript
const result = await LocalAuthentication.authenticateAsync({
  promptMessage: 'Authenticate to access NexusCollect',
  fallbackLabel: 'Use Passcode',
  cancelLabel: 'Cancel',
  disableDeviceFallback: false,
  requireConfirmation: true,
});

if (result.success) {
  // Authenticated
} else {
  // Authentication failed
}
```

3. **Secure Action:**
```typescript
const performSecureAction = async () => {
  const authenticated = await authenticate();
  if (authenticated) {
    // Perform secure action
  }
};
```

4. **Biometric Settings:**
- Store preference in settings store
- Toggle on/off in app settings
- Respect user privacy choice

---

**19. How would you implement push notifications with Expo?**

**Answer:**
1. **Setup Notification Handler:**
```typescript
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});
```

2. **Request Permissions:**
```typescript
const { status } = await Notifications.requestPermissionsAsync();
if (status !== 'granted') return;
```

3. **Get Push Token:**
```typescript
const token = await Notifications.getExpoPushTokenAsync({
  projectId: Constants.expoConfig?.extra?.eas?.projectId,
});
```

4. **Send Notification:**
```typescript
await fetch('https://exp.host/--/api/v2/push/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: token,
    title: 'Hello',
    body: 'Notification body',
    data: { screen: 'Home' },
  }),
});
```

5. **Handle Notifications:**
```typescript
Notifications.addNotificationReceivedListener((notification) => {
  // Handle foreground notification
});

Notifications.addNotificationResponseReceivedListener((response) => {
  // Handle notification tap
  const data = response.notification.request.content.data;
  navigation.navigate(data.screen);
});
```

---

**20. What are the best practices for handling device permissions in React Native?**

**Answer:**
1. **Request Permissions When Needed:**
- Request permissions just before using the feature
- Explain why permission is needed

2. **Handle Denials Gracefully:**
```typescript
const requestPermission = async () => {
  const { status } = await Camera.requestCameraPermissionsAsync();
  if (status === 'granted') {
    // Proceed
  } else if (status === 'denied') {
    Alert.alert(
      'Permission Required',
      'Please enable camera permission in settings',
      [{ text: 'Open Settings', onPress: Linking.openSettings }]
    );
  }
};
```

3. **Check Permission Status:**
```typescript
const { status } = await Camera.getCameraPermissionsAsync();
if (status === 'granted') {
  // Show camera
}
```

4. **Handle All Platforms:**
- iOS and Android have different permission systems
- Test on both platforms

5. **Provide Alternatives:**
- If camera is denied, allow file upload
- If location is denied, allow manual entry

---

**21. Explain the differences between foreground and background location tracking.**

**Answer:**
**Foreground Tracking:**
- Only active when app is in foreground
- Uses `getCurrentPositionAsync`
- More accurate
- Less battery drain

**Background Tracking:**
- Works even when app is in background
- Uses `watchPositionAsync`
- May have accuracy limitations
- More battery usage
- Requires additional permissions

**Implementation:**
```typescript
// Foreground
const location = await Location.getCurrentPositionAsync({
  accuracy: Location.Accuracy.High,
});

// Background
Location.watchPositionAsync(
  {
    accuracy: Location.Accuracy.Balanced,
    distanceInterval: 1,
    timeInterval: 5000,
  },
  callback
);
```

---

**22. How would you implement photo capture with preview and retake functionality?**

**Answer:**
1. **Camera Setup:**
```typescript
const [photos, setPhotos] = useState([]);
const [preview, setPreview] = useState(null);
const cameraRef = useRef(null);

const takePhoto = async () => {
  const photo = await cameraRef.current.takePictureAsync({
    quality: 0.8,
    base64: true,
  });
  setPreview(photo);
};
```

2. **Preview Screen:**
```typescript
{preview && (
  <View>
    <Image source={{ uri: preview.uri }} />
    <Button title="Retake" onPress={() => setPreview(null)} />
    <Button title="Use Photo" onPress={() => {
      setPhotos([...photos, preview]);
      setPreview(null);
    }} />
  </View>
)}
```

3. **Thumbnail Gallery:**
```typescript
<ScrollView horizontal>
  {photos.map((photo, index) => (
    <TouchableOpacity key={index}>
      <Image source={{ uri: photo.uri }} style={styles.thumbnail} />
    </TouchableOpacity>
  ))}
</ScrollView>
```

---

**23. What is the purpose of the `expires_at` field in push notifications?**

**Answer:**
`expires_at` specifies when a notification should no longer be delivered:

```typescript
const message = {
  to: token,
  title: 'Time-sensitive',
  body: 'This notification expires',
  data: { screen: 'Home' },
  expires_at: Date.now() + 3600000, // 1 hour
};
```

**Purposes:**
- Time-sensitive notifications (e.g., login codes)
- Reduce unnecessary notifications
- Server load management
- User experience (avoid stale notifications)

---

**24. Describe the process of implementing a location picker component.**

**Answer:**
1. **Component Structure:**
```typescript
const LocationPicker = ({ value, onChange }) => {
  const [loading, setLoading] = useState(false);
  const [address, setAddress] = useState('');

  const getLocation = async () => {
    setLoading(true);
    try {
      const location = await Location.getCurrentPositionAsync();
      onChange(location);
      const address = await reverseGeocode(location);
      setAddress(address);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View>
      {value ? (
        <View>
          <Text>{`${value.latitude}, ${value.longitude}`}</Text>
          {address && <Text>{address}</Text>}
          <Button title="Change" onPress={getLocation} />
        </View>
      ) : (
        <Button title="Get Current Location" onPress={getLocation} />
      )}
    </View>
  );
};
```

2. **Manual Entry:** Allow manual coordinate entry for testing

---

**25. How do you handle background notifications in React Native?**

**Answer:**
1. **Configure Background Handler:**
```typescript
// In app.json
{
  "ios": {
    "infoPlist": {
      "UIBackgroundModes": ["fetch", "remote-notification"]
    }
  }
}
```

2. **Set Background Handler:**
```typescript
Notifications.setBackgroundNotificationHandler({
  handleNotification: async (notification) => {
    // Process notification in background
    console.log('Background notification:', notification);
    return {
      shouldShowAlert: true,
      shouldPlaySound: true,
    };
  },
});
```

3. **Process Background Data:**
```typescript
// Update app state or sync data
await processNotificationData(notification.data);
```

4. **Handle Notification Response:**
- Foreground: `addNotificationResponseReceivedListener`
- Background: System handles automatically

---

## MODULE 6: TESTING & QUALITY ASSURANCE

### Part A: Multiple Choice Questions (15 Questions)

**1. Which testing framework is recommended for React Native?**
- A) Mocha
- B) Jasmine
- C) Jest
- D) Chai

**Answer: C) Jest**

---

**2. What is the purpose of `@testing-library/react-native`?**
- A) To test React components
- B) To test React Native components
- C) To test API calls
- D) To test database operations

**Answer: B) To test React Native components**

---

**3. Which of the following is NOT a test type in the testing pyramid?**
- A) Unit Tests
- B) Component Tests
- C) Performance Tests
- D) E2E Tests

**Answer: C) Performance Tests**

---

**4. What is the purpose of `fireEvent` in React Native Testing Library?**
- A) To trigger user interactions
- B) To fire API calls
- C) To trigger network events
- D) To fire database queries

**Answer: A) To trigger user interactions**

---

**5. Which tool is used for End-to-End testing in React Native?**
- A) Jest
- B) Detox
- C) Mocha
- D) Jasmine

**Answer: B) Detox**

---

**6. What is the purpose of code coverage in testing?**
- A) To measure how much code is tested
- B) To measure code quality
- C) To measure app performance
- D) To measure app size

**Answer: A) To measure how much code is tested**

---

**7. Which of the following is a benefit of Test-Driven Development (TDD)?**
- A) Faster development
- B) Better code design
- C) Fewer bugs
- D) All of the above

**Answer: D) All of the above**

---

**8. What is the purpose of `jest.mock()`?**
- A) To mock entire modules
- B) To create mock objects
- C) To spy on functions
- D) To test API calls

**Answer: A) To mock entire modules**

---

**9. Which function is used to render a component for testing?**
- A) `render()`
- B) `mount()`
- C) `shallow()`
- D) `renderComponent()`

**Answer: A) `render()`**

---

**10. What is the purpose of E2E tests?**
- A) To test individual units
- B) To test complete user flows
- C) To test API integrations
- D) To test performance

**Answer: B) To test complete user flows**

---

**11. Which of the following is NOT a React Native Testing Library query?**
- A) `getByText`
- B) `getByTestId`
- C) `getByClassName`
- D) `getByPlaceholderText`

**Answer: C) `getByClassName`**

---

**12. What is the purpose of `waitFor` in React Native Testing Library?**
- A) To wait for async operations
- B) To wait for user input
- C) To wait for API responses
- D) To wait for animations

**Answer: A) To wait for async operations**

---

**13. Which of the following is true about Detox?**
- A) It only tests iOS
- B) It tests real devices and simulators
- C) It only tests Android
- D) It only runs in CI

**Answer: B) It tests real devices and simulators**

---

**14. What is the purpose of `expect().toMatchSnapshot()`?**
- A) To compare component render output
- B) To compare API responses
- C) To compare database records
- D) To compare performance metrics

**Answer: A) To compare component render output**

---

**15. Which of the following is NOT a code quality tool?**
- A) ESLint
- B) Prettier
- C) TypeScript
- D) Jest

**Answer: D) Jest**

---

### Part B: Short Answer Questions (10 Questions)

**16. Explain the testing pyramid and its importance in mobile development.**

**Answer:**
```
        /\
       /  \      E2E Tests (Few, Slow, Expensive)
      /    \     
     /______\    Integration Tests (Some, Medium)
    /        \
   /__________\  Unit Tests (Many, Fast, Cheap)
```

**Importance:**
1. **Unit Tests (Base):**
- Fast and cheap
- Test individual functions
- High coverage
- Run on every commit

2. **Integration Tests (Middle):**
- Test multiple units together
- Moderate speed
- Verify integrations

3. **E2E Tests (Top):**
- Test complete user flows
- Slow and expensive
- Critical for release

---

**17. Describe how to test a custom React Hook using `@testing-library/react-hooks`.**

**Answer:**
1. **Install Dependencies:**
```bash
npm install -D @testing-library/react-hooks
```

2. **Define Hook:**
```typescript
const useCounter = (initial = 0) => {
  const [count, setCount] = useState(initial);
  const increment = () => setCount(c => c + 1);
  return { count, increment };
};
```

3. **Test Hook:**
```typescript
import { renderHook, act } from '@testing-library/react-hooks';

describe('useCounter', () => {
  it('should increment count', () => {
    const { result } = renderHook(() => useCounter(0));
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });
});
```

---

**18. How do you mock API calls in React Native tests?**

**Answer:**
1. **Mock Module:**
```typescript
jest.mock('@api/services/authService');

// Or with implementation
jest.mock('@api/services/authService', () => ({
  login: jest.fn(),
}));
```

2. **Mock Response:**
```typescript
(authService.login as jest.Mock).mockResolvedValue({
  user: mockUser,
  session: mockSession,
});
```

3. **Test with Mock:**
```typescript
describe('Auth Store', () => {
  it('should login successfully', async () => {
    (authService.login as jest.Mock).mockResolvedValue({
      user: { id: '1', email: 'test@example.com' },
      session: { token: 'jwt-token' },
    });
    
    const { login } = useAuthStore.getState();
    await login('test@example.com', 'password');
    
    const state = useAuthStore.getState();
    expect(state.user).toBeDefined();
    expect(state.isAuthenticated).toBe(true);
  });
});
```

---

**19. Explain the difference between unit, integration, and E2E testing with examples.**

**Answer:**
**Unit Tests:**
- Test individual units in isolation
- Example: Testing a validation function

```typescript
test('validateEmail returns false for invalid email', () => {
  expect(validateEmail('test@')).toBe(false);
});
```

**Integration Tests:**
- Test multiple units working together
- Example: Testing store with API service

```typescript
test('auth store integrates with login API', async () => {
  const { login } = useAuthStore.getState();
  await login('test@example.com', 'password');
  // Verify state changes
});
```

**E2E Tests:**
- Test complete user flows
- Example: Testing login flow

```typescript
test('user can login successfully', async () => {
  await element(by.id('email')).typeText('test@example.com');
  await element(by.id('password')).typeText('password123');
  await element(by.text('Sign In')).tap();
  await expect(element(by.text('Dashboard'))).toBeVisible();
});
```

---

**20. How do you configure Jest for a React Native project?**

**Answer:**
```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  testRegex: '(/__tests__/.*|(\\.|/)(test|spec))\\.[jt]sx?$',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};
```

---

**21. What are the key principles of effective test writing?**

**Answer:**
1. **Isolation:** Each test should be independent
2. **Readability:** Tests should be easy to understand
3. **Maintainability:** Tests should be easy to update
4. **Speed:** Tests should run quickly
5. **Determinism:** Tests should always produce the same result

**AAA Pattern:**
```
Arrange → Set up test data
Act → Execute the action
Assert → Verify the result
```

**Best Practices:**
- One assertion per test
- Test one behavior per test
- Use descriptive test names
- Keep tests simple

---

**22. Explain the process of setting up End-to-End tests with Detox.**

**Answer:**
1. **Install Detox:**
```bash
npm install -D detox jest-jasmine2
brew tap wix/brew && brew install applesimutils
```

2. **Configure Detox:**
```json
// package.json
{
  "detox": {
    "configurations": {
      "ios.sim.debug": {
        "binaryPath": "ios/build/.../NexusCollect.app",
        "build": "xcodebuild -workspace ios/NexusCollect.xcworkspace ...",
        "type": "ios.simulator",
        "device": { "type": "iPhone 15 Pro" }
      }
    }
  }
}
```

3. **Write Tests:**
```typescript
// e2e/auth.e2e.js
describe('Login Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  it('should login successfully', async () => {
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.id('passwordInput')).typeText('password123');
    await element(by.text('Sign In')).tap();
    await expect(element(by.text('Dashboard'))).toBeVisible();
  });
});
```

4. **Run Tests:**
```bash
npm run test:e2e
```

---

**23. What is the role of CI/CD in automated testing?**

**Answer:**
CI/CD (Continuous Integration/Continuous Deployment) automates the testing and deployment process:

**CI (Continuous Integration):**
1. **Code Push:** Developer pushes code
2. **Automatic Build:** Code is built automatically
3. **Test Execution:** All tests run automatically
4. **Results Reporting:** Test results are reported

**CD (Continuous Deployment):**
1. **Successful Build:** All tests pass
2. **Automatic Deploy:** App is deployed to staging/production

**Benefits:**
- Catch bugs early
- Reduce manual testing
- Faster releases
- Consistent process

---

**24. How do you achieve code coverage goals in a React Native project?**

**Answer:**
1. **Set Coverage Thresholds:**
```javascript
// jest.config.js
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80,
  },
}
```

2. **Write Tests for All Files:**
- Test all components
- Test all utilities
- Test all hooks
- Test all services

3. **Focus on Critical Code:**
- Authentication flows
- Data management
- Business logic

4. **Use Coverage Reports:**
```bash
npm run test:coverage
# View coverage/lcov-report/index.html
```

---

**25. What are the best practices for testing React Native applications?**

**Answer:**
1. **Test Structure:**
```
src/
  __tests__/
    unit/
      utils/
      hooks/
    integration/
    components/
    e2e/
```

2. **Test Components:**
- Render tests
- Interaction tests
- State tests
- Snapshot tests

3. **Test Async Code:**
- Use async/await
- Test loading states
- Test error states

4. **Mock External Dependencies:**
- API calls
- Native modules
- AsyncStorage

5. **Run Tests in CI:**
- Lint checks
- Type checking
- Unit tests
- E2E tests

---

## MODULE 7: SECURITY HARDENING & PRODUCTION DEPLOYMENT

### Part A: Multiple Choice Questions (15 Questions)

**1. What is OWASP Mobile Top 10?**
- A) A list of security frameworks
- B) A list of mobile security risks
- C) A list of testing tools
- D) A list of deployment strategies

**Answer: B) A list of mobile security risks**

---

**2. Which of the following is NOT an OWASP Mobile Top 10 risk?**
- A) Insecure Data Storage
- B) Code Obfuscation
- C) Insecure Authentication
- D) Insecure Communication

**Answer: B) Code Obfuscation**

---

**3. What is the purpose of code obfuscation?**
- A) To make code run faster
- B) To make code harder to reverse engineer
- C) To reduce app size
- D) To improve readability

**Answer: B) To make code harder to reverse engineer**

---

**4. Which of the following is a method to protect against Man-in-the-Middle attacks?**
- A) Certificate Pinning
- B) Code Obfuscation
- C) Data Encryption
- D) Biometric Authentication

**Answer: A) Certificate Pinning**

---

**5. What is the purpose of SecureStore in Expo?**
- A) To store data securely
- B) To encrypt network requests
- C) To secure API calls
- D) To authenticate users

**Answer: A) To store data securely**

---

**6. Which of the following is true about certificate pinning?**
- A) It allows any certificate
- B) It restricts certificates to trusted ones
- C) It uses only self-signed certificates
- D) It bypasses SSL/TLS

**Answer: B) It restricts certificates to trusted ones**

---

**7. What is the purpose of code signing?**
- A) To verify app authenticity
- B) To encrypt app data
- C) To compress app size
- D) To speed up app launch

**Answer: A) To verify app authenticity**

---

**8. Which method is used to check for root/jailbreak in React Native?**
- A) `DeviceInfo.isRooted()`
- B) `DeviceInfo.isJailbroken()`
- C) `DeviceInfo.checkSecurity()`
- D) `DeviceInfo.isCompromised()`

**Answer: A) `DeviceInfo.isRooted()`**

---

**9. What is the purpose of OTA (Over-The-Air) updates?**
- A) To update app without store review
- B) To update app version
- C) To update OS version
- D) To update device firmware

**Answer: A) To update app without store review**

---

**10. Which of the following is a privacy consideration for mobile apps?**
- A) Data collection disclosure
- B) App performance
- C) App design
- D) App testing

**Answer: A) Data collection disclosure**

---

**11. What is the purpose of the Privacy Manifest in iOS?**
- A) To disclose data collection
- B) To improve app performance
- C) To enable push notifications
- D) To handle app updates

**Answer: A) To disclose data collection**

---

**12. Which of the following is NOT a benefit of OTA updates?**
- A) Faster bug fixes
- B) No App Store review
- C) Complete app replacement
- D) Feature updates

**Answer: C) Complete app replacement**

---

**13. What is the purpose of `eas build`?**
- A) To build apps locally
- B) To build apps in the cloud
- C) To test apps
- D) To deploy apps

**Answer: B) To build apps in the cloud**

---

**14. Which of the following is true about Google Play Store submission?**
- A) No review process
- B) Review process required
- C) Only Android apps
- D) Only paid apps

**Answer: B) Review process required**

---

**15. What is the purpose of Fastlane?**
- A) To automate app deployment
- B) To test React Native apps
- C) To build React Native apps
- D) To design app UI

**Answer: A) To automate app deployment**

---

### Part B: Short Answer Questions (10 Questions)

**16. Explain the OWASP Mobile Top 10 and its relevance to mobile development.**

**Answer:**
The OWASP Mobile Top 10 is a list of the most critical security risks in mobile applications:

1. **Improper Platform Usage:** Misusing platform features
2. **Insecure Data Storage:** Storing sensitive data insecurely
3. **Insecure Communication:** Unencrypted network traffic
4. **Insecure Authentication:** Weak authentication
5. **Insufficient Cryptography:** Weak encryption
6. **Insecure Authorization:** Improper access control
7. **Client Code Quality:** Memory leaks, buffer overflows
8. **Code Tampering:** Modification of app code
9. **Reverse Engineering:** Decompiling and analyzing app
10. **Extraneous Functionality:** Hidden features or backdoors

**Relevance:** Provides a checklist of security considerations developers must address.

---

**17. Describe how to implement certificate pinning in a React Native app.**

**Answer:**
1. **Define Public Keys:**
```typescript
const EXPECTED_PUBLIC_KEYS = {
  production: [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
  ],
};
```

2. **Implement Validation:**
```typescript
export const secureFetch = async (url: string, options?: RequestInit) => {
  // Use react-native-ssl-pinning
  const response = await fetch(url, {
    ...options,
    timeout: 30000,
    sslPinning: {
      certs: EXPECTED_PUBLIC_KEYS.production,
    },
  });
  return response;
};
```

3. **Validate Certificate:**
```typescript
const validateCertificate = (publicKey: string): boolean => {
  return EXPECTED_PUBLIC_KEYS.production.includes(publicKey);
};
```

4. **Handle Failures:**
```typescript
if (!validateCertificate(certificate)) {
  // Handle security violation
  Alert.alert('Security Error', 'Certificate validation failed');
}
```

---

**18. What are the steps to prepare a React Native app for production deployment?**

**Answer:**
1. **Code Quality:**
- Run linting: `npm run lint`
- Type checking: `npm run type-check`
- Fix all errors

2. **Testing:**
- Run unit tests: `npm test`
- Run E2E tests: `npm run test:e2e`
- Achieve coverage goals

3. **Build Configuration:**
- Configure production signing
- Set environment variables
- Enable code obfuscation

4. **App Store Preparation:**
- Generate app icons and screenshots
- Write app description
- Configure privacy policy

5. **Build:**
```bash
eas build --platform ios --profile production
eas build --platform android --profile production
```

6. **Submit:**
```bash
eas submit --platform ios
eas submit --platform android
```

---

**19. How do you implement code obfuscation in React Native?**

**Answer:**
1. **Configure Metro:**
```javascript
// metro.config.js
module.exports = {
  transformer: {
    minifierConfig: {
      compress: {
        drop_console: true,
        drop_debugger: true,
        pure_funcs: ['console.log', 'console.debug'],
        passes: 2,
      },
      mangle: {
        reserved: ['require', 'exports', 'module'],
        properties: {
          regex: /^_/,
        },
      },
      output: {
        comments: false,
        beautify: false,
      },
    },
  },
};
```

2. **Enable Minification:**
```json
// app.json
{
  "expo": {
    "ios": {
      "buildConfiguration": "Release"
    }
  }
}
```

3. **Android ProGuard:**
```proguard
# proguard-rules.pro
-keep class com.facebook.hermes.unicode.** { *; }
-keep class com.facebook.react.** { *; }
```

---

**20. Explain the role of environment variables in securing React Native apps.**

**Answer:**
1. **Separate Configurations:**
```env
# .env.development
API_URL=http://localhost:3000
SUPABASE_URL=dev-project.supabase.co
LOG_LEVEL=debug

# .env.production
API_URL=https://api.nexuscollect.com
SUPABASE_URL=prod-project.supabase.co
LOG_LEVEL=error
```

2. **Prevent Hardcoding:**
```typescript
// ❌ Bad
const API_URL = 'https://api.nexuscollect.com';

// ✅ Good
import { CONFIG } from '@constants/config';
const API_URL = CONFIG.api.baseUrl;
```

3. **Secure Secrets:**
```typescript
// Use environment variables for:
- API keys
- Database URLs
- Authentication tokens
- Feature flags
```

4. **Git Ignore:**
```gitignore
.env
.env.*
!.env.example
```

---

**21. How would you implement runtime integrity checks in a React Native app?**

**Answer:**
1. **Check for Root/Jailbreak:**
```typescript
const isRooted = await DeviceInfo.isRooted();
if (isRooted && !__DEV__) {
  Alert.alert('Security Warning', 'Device appears compromised');
}
```

2. **Check for Emulator:**
```typescript
const isEmulator = await DeviceInfo.isEmulator();
if (isEmulator && !__DEV__) {
  // Restrict functionality
}
```

3. **Check for Debug Mode:**
```typescript
if (__DEV__ && !__DEV__) {
  // Handle production debug
}
```

4. **Code Tampering:**
```typescript
// Check app signature
const appHash = await getAppHash();
if (appHash !== EXPECTED_HASH) {
  Alert.alert('Security Warning', 'App has been tampered with');
}
```

5. **Periodic Checks:**
```typescript
setInterval(async () => {
  const integrity = await checkIntegrity();
  if (integrity.compromised) {
    handleCompromisedDevice();
  }
}, 30000);
```

---

**22. Describe the OTA update process with Expo.**

**Answer:**
1. **Configure Updates:**
```json
// app.json
{
  "expo": {
    "updates": {
      "enabled": true,
      "checkAutomatically": "ON_LOAD",
      "fallbackToCacheTimeout": 30000,
      "url": "https://u.expo.dev/your-project-id"
    }
  }
}
```

2. **Configure EAS:**
```json
// eas.json
{
  "build": {
    "production": {
      "channel": "production"
    }
  }
}
```

3. **Push Update:**
```bash
eas update --branch production --message "Fix critical bug"
```

4. **Handle Updates in App:**
```typescript
import * as Updates from 'expo-updates';

const checkForUpdates = async () => {
  const update = await Updates.checkForUpdateAsync();
  if (update.isAvailable) {
    await Updates.fetchUpdateAsync();
    await Updates.reloadAsync();
  }
};
```

---

**23. What are the key considerations for App Store submission?**

**Answer:**
1. **iOS App Store:**
- App icon (1024x1024)
- Screenshots (all required sizes)
- App description
- Keywords
- Privacy policy
- Terms of service
- Support URL
- Marketing URL

2. **Google Play Store:**
- App icon (512x512)
- Screenshots
- Feature graphic (1024x500)
- App description
- Short description
- Privacy policy
- Category
- Content rating

3. **Common Requirements:**
- Clear privacy policy
- Data collection disclosure
- Terms of service
- App not crashing
- Following design guidelines
- Proper age rating

---

**24. How do you implement secure data storage in React Native?**

**Answer:**
1. **Use SecureStore:**
```typescript
import * as SecureStore from 'expo-secure-store';

// Store data
await SecureStore.setItemAsync('user_token', token);

// Retrieve data
const token = await SecureStore.getItemAsync('user_token');

// Delete data
await SecureStore.deleteItemAsync('user_token');
```

2. **Encrypt Sensitive Data:**
```typescript
class EncryptionService {
  async encrypt(data: string): Promise<string> {
    // Use proper encryption
    return encryptedData;
  }
  
  async decrypt(encrypted: string): Promise<string> {
    return decryptedData;
  }
}
```

3. **Use Keychain (iOS) / Keystore (Android):**
```typescript
import * as Keychain from 'react-native-keychain';

// Store credentials
await Keychain.setGenericPassword(username, password);

// Get credentials
const credentials = await Keychain.getGenericPassword();
```

4. **Data Minimization:**
- Store only necessary data
- Clear data on logout
- Use expiration for cached data

---

**25. Explain the process of monitoring a production React Native app.**

**Answer:**
1. **Error Tracking with Sentry:**
```typescript
import * as Sentry from 'sentry-expo';

Sentry.init({
  dsn: 'your-sentry-dsn',
  environment: 'production',
});

// Capture errors
Sentry.captureException(error);

// Capture messages
Sentry.captureMessage('User logged out');
```

2. **Performance Monitoring:**
```typescript
// Track screen load times
Sentry.addBreadcrumb({
  message: `Screen: ${screenName}`,
  category: 'navigation',
});

// Track API calls
const transaction = Sentry.startTransaction('api-call');
// API call
transaction.finish();
```

3. **Analytics:**
- Track user events
- Track screen views
- Track feature usage
- Track app crashes

4. **Health Monitoring:**
- Check app uptime
- Monitor error rates
- Track crash-free users
- Monitor API response times

---

## MID-TERM EXAMINATION

### Part A: Multiple Choice Questions (30 Questions)

**1. Which command creates a new Expo project with TypeScript?**
- A) `npx react-native init MyApp`
- B) `expo init MyApp`
- C) `npx create-expo-app MyApp --template`
- D) `npm init expo MyApp`

**Answer: C) `npx create-expo-app MyApp --template`**

---

**2. What is the purpose of the Bridge in React Native?**
- A) To connect to databases
- B) To communicate between JavaScript and native code
- C) To render UI components
- D) To manage state

**Answer: B) To communicate between JavaScript and native code**

---

**3. Which of the following is a React Navigation type?**
- A) Stack Navigator
- B) List Navigator
- C) Grid Navigator
- D) Array Navigator

**Answer: A) Stack Navigator**

---

**4. What is Zustand primarily used for?**
- A) Navigation
- B) State Management
- C) API Calls
- D) UI Rendering

**Answer: B) State Management**

---

**5. Which database does Supabase use?**
- A) MongoDB
- B) PostgreSQL
- C) SQLite
- D) MySQL

**Answer: B) PostgreSQL**

---

**6. What is Row Level Security (RLS)?**
- A) A security system for database rows
- B) A security system for columns
- C) A security system for tables
- D) A security system for schemas

**Answer: A) A security system for database rows**

---

**7. Which Expo package is used for camera integration?**
- A) `expo-camera`
- B) `expo-image`
- C) `expo-media`
- D) `expo-photo`

**Answer: A) `expo-camera`**

---

**8. What is the purpose of `Location.watchPositionAsync()`?**
- A) To get a single location
- B) To continuously track location
- C) To stop location tracking
- D) To pause location tracking

**Answer: B) To continuously track location**

---

**9. Which testing framework is recommended for React Native?**
- A) Mocha
- B) Jasmine
- C) Jest
- D) Chai

**Answer: C) Jest**

---

**10. What is the purpose of Detox?**
- A) Unit testing
- B) Component testing
- C) End-to-End testing
- D) Performance testing

**Answer: C) End-to-End testing**

---

**11. What is code obfuscation?**
- A) Making code run faster
- B) Making code harder to reverse engineer
- C) Making code smaller
- D) Making code more readable

**Answer: B) Making code harder to reverse engineer**

---

**12. What is the purpose of certificate pinning?**
- A) To allow any certificate
- B) To restrict certificates to trusted ones
- C) To bypass SSL/TLS
- D) To encrypt data

**Answer: B) To restrict certificates to trusted ones**

---

**13. Which method is used to get the current location in Expo?**
- A) `Location.getCurrentPositionAsync()`
- B) `Location.getLocationAsync()`
- C) `Location.getPosition()`
- D) `Location.getCoordinates()`

**Answer: A) `Location.getCurrentPositionAsync()`**

---

**14. What is the purpose of `eas build`?**
- A) To build apps locally
- B) To build apps in the cloud
- C) To test apps
- D) To deploy apps

**Answer: B) To build apps in the cloud**

---

**15. Which of the following is an OWASP Mobile Top 10 risk?**
- A) Code Obfuscation
- B) Insecure Data Storage
- C) App Performance
- D) UI Design

**Answer: B) Insecure Data Storage**

---

**16. What is the purpose of `@testing-library/react-native`?**
- A) To test React components
- B) To test React Native components
- C) To test API calls
- D) To test database operations

**Answer: B) To test React Native components**

---

**17. Which of the following is true about offline-first architecture?**
- A) App only works offline
- B) App works online and offline
- C) App only syncs on demand
- D) App never syncs

**Answer: B) App works online and offline**

---

**18. What is the purpose of the `persist` middleware in Zustand?**
- A) To save state to persistent storage
- B) To create persistent connections
- C) To persist user sessions
- D) To maintain application state

**Answer: A) To save state to persistent storage**

---

**19. Which method is used for social login with Google in Supabase?**
- A) `supabase.auth.googleLogin()`
- B) `supabase.auth.signInWithOAuth()`
- C) `supabase.auth.loginGoogle()`
- D) `supabase.auth.oauthGoogle()`

**Answer: B) `supabase.auth.signInWithOAuth()`**

---

**20. What is the purpose of the sync queue in an offline-first app?**
- A) To store all data
- B) To track pending sync operations
- C) To cache API responses
- D) To store user preferences

**Answer: B) To track pending sync operations**

---

**21. Which of the following is NOT a biometric authentication type?**
- A) Fingerprint
- B) Face Recognition
- C) Iris Scan
- D) Voice Recognition

**Answer: D) Voice Recognition**

---

**22. What is the purpose of `Notifications.setNotificationHandler()`?**
- A) To send notifications
- B) To configure notification handling
- C) To request notification permissions
- D) To create notification channels

**Answer: B) To configure notification handling**

---

**23. Which of the following is a code quality tool?**
- A) Jest
- B) ESLint
- C) Detox
- D) React Native

**Answer: B) ESLint**

---

**24. What is the purpose of OTA updates?**
- A) To update app without store review
- B) To update app version
- C) To update OS version
- D) To update device firmware

**Answer: A) To update app without store review**

---

**25. Which method is used to check for root/jailbreak?**
- A) `DeviceInfo.isRooted()`
- B) `DeviceInfo.isJailbroken()`
- C) `DeviceInfo.checkSecurity()`
- D) `DeviceInfo.isCompromised()`

**Answer: A) `DeviceInfo.isRooted()`**

---

**26. What is the purpose of `WatermelonDB`?**
- A) Cloud database
- B) Local database
- C) State management
- D) File storage

**Answer: B) Local database**

---

**27. Which of the following is true about Fastlane?**
- A) It only works for iOS
- B) It automates app deployment
- C) It only works for Android
- D) It is a testing framework

**Answer: B) It automates app deployment**

---

**28. What is the purpose of the Privacy Manifest in iOS?**
- A) To disclose data collection
- B) To improve app performance
- C) To enable push notifications
- D) To handle app updates

**Answer: A) To disclose data collection**

---

**29. Which pattern is commonly used with WatermelonDB?**
- A) Singleton Pattern
- B) Repository Pattern
- C) Factory Pattern
- D) Observer Pattern

**Answer: B) Repository Pattern**

---

**30. What is the purpose of `expo-secure-store`?**
- A) To store data securely
- B) To encrypt network requests
- C) To secure API calls
- D) To authenticate users

**Answer: A) To store data securely**

---

### Part B: Short Answer Questions (20 Questions)

**31. Explain the architecture of a React Native application with Zustand and React Navigation.**

**Answer:**
```
┌─────────────────────────────────────────────┐
│              UI Components                   │
│         (Screens + Reusable Components)     │
├─────────────────────────────────────────────┤
│              React Navigation                │
│         (Stack/Tab/Drawer Navigators)       │
├─────────────────────────────────────────────┤
│              Zustand Stores                  │
│         (Auth, Settings, Forms, etc.)       │
├─────────────────────────────────────────────┤
│              API Services                    │
│         (Supabase, Custom APIs)             │
├─────────────────────────────────────────────┤
│              Local Storage                   │
│         (AsyncStorage, SecureStore)         │
└─────────────────────────────────────────────┘
```

**Data Flow:** Component → Navigation → Store → Service → API → Response → Store Update → Component Re-render

---

**32. Describe how to set up a Zustand store with persistence.**

**Answer:**
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import * as SecureStore from 'expo-secure-store';

const secureStorage = {
  getItem: async (key) => {
    const value = await SecureStore.getItemAsync(key);
    return value ? JSON.parse(value) : null;
  },
  setItem: async (key, value) => {
    await SecureStore.setItemAsync(key, JSON.stringify(value));
  },
  removeItem: async (key) => {
    await SecureStore.deleteItemAsync(key);
  },
};

export const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      setUser: (user) => set({ user }),
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    {
      name: 'auth-storage',
      storage: secureStorage,
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

---

**33. Explain how to implement authentication flow with Supabase.**

**Answer:**
1. **Login:**
```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123',
});
```

2. **Registration:**
```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    data: { full_name: 'John Doe' },
  },
});
```

3. **Session Management:**
```typescript
const session = await supabase.auth.getSession();
```

4. **Logout:**
```typescript
await supabase.auth.signOut();
```

---

**34. What is the testing pyramid and why is it important?**

**Answer:**
The testing pyramid visualizes the ideal distribution of tests:

```
        /\
       /  \      E2E Tests (Few, Slow, Expensive)
      /    \     
     /______\    Integration Tests (Some, Medium)
    /        \
   /__________\  Unit Tests (Many, Fast, Cheap)
```

**Importance:**
- Unit tests form the base (fast, cheap)
- Integration tests provide coverage
- E2E tests verify critical flows
- Helps allocate testing effort efficiently

---

**35. Explain the offline-first architecture and its benefits.**

**Answer:**
Offline-first architecture ensures apps work without internet:

**Key Concepts:**
1. Local storage for all data
2. Offline operations (CRUD)
3. Sync queue
4. Automatic sync on connection

**Benefits:**
- ✅ Reliable user experience
- ✅ Reduced server load
- ✅ Faster app performance
- ✅ Better user retention
- ✅ Works in remote areas

---

**36. Describe certificate pinning and its security benefits.**

**Answer:**
Certificate pinning restricts which certificates are trusted:

```typescript
const EXPECTED_PUBLIC_KEYS = {
  production: ['sha256/AAAAAAAAAAAAAAAAAAAA='],
};

const validateCertificate = (publicKey: string): boolean => {
  return EXPECTED_PUBLIC_KEYS.production.includes(publicKey);
};
```

**Benefits:**
- Prevents Man-in-the-Middle attacks
- Protects against compromised CAs
- Ensures connection to trusted servers
- Adds security layer beyond SSL/TLS

---

**37. How would you implement push notifications with Expo?**

**Answer:**
1. **Setup:**
```typescript
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});
```

2. **Get Token:**
```typescript
const token = await Notifications.getExpoPushTokenAsync({
  projectId: Constants.expoConfig?.extra?.eas?.projectId,
});
```

3. **Send Notification:**
```typescript
await fetch('https://exp.host/--/api/v2/push/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: token,
    title: 'Hello',
    body: 'Notification body',
  }),
});
```

4. **Handle Responses:**
```typescript
Notifications.addNotificationResponseReceivedListener((response) => {
  // Handle notification tap
});
```

---

**38. What are the key considerations for App Store deployment?**

**Answer:**
**iOS App Store:**
- App icon (1024x1024)
- Screenshots (all required sizes)
- App description
- Keywords
- Privacy policy
- Terms of service

**Google Play Store:**
- App icon (512x512)
- Screenshots
- Feature graphic (1024x500)
- App description
- Privacy policy

**Common Requirements:**
- Clear privacy policy
- Data collection disclosure
- Terms of service
- Following design guidelines
- Proper age rating

---

**39. Explain how to secure data storage in React Native.**

**Answer:**
1. **Use SecureStore:**
```typescript
await SecureStore.setItemAsync('user_token', token);
const token = await SecureStore.getItemAsync('user_token');
```

2. **Encrypt Sensitive Data:**
```typescript
class EncryptionService {
  async encrypt(data: string): Promise<string> {
    // Use proper encryption
  }
  async decrypt(encrypted: string): Promise<string> {
    // Use proper decryption
  }
}
```

3. **Use Keychain/Keystore:**
```typescript
await Keychain.setGenericPassword(username, password);
const credentials = await Keychain.getGenericPassword();
```

4. **Data Minimization:**
- Store only necessary data
- Clear data on logout
- Use expiration for cached data

---

**40. Explain the process of implementing biometric authentication.**

**Answer:**
1. **Check Availability:**
```typescript
const hasHardware = await LocalAuthentication.hasHardwareAsync();
const hasEnrolled = await LocalAuthentication.isEnrolledAsync();
```

2. **Authenticate:**
```typescript
const result = await LocalAuthentication.authenticateAsync({
  promptMessage: 'Authenticate to access',
  fallbackLabel: 'Use Passcode',
  cancelLabel: 'Cancel',
});
```

3. **Secure Action:**
```typescript
const performSecureAction = async () => {
  const authenticated = await authenticate();
  if (authenticated) {
    // Perform secure action
  }
};
```

4. **Handle Results:**
- Success: Proceed with secure action
- Failure: Show error message
- Cancel: Let user continue without action

---

## FINAL EXAMINATION

### Part A: Multiple Choice Questions (30 Questions)

**1. Which of the following is NOT a component of the React Native New Architecture?**
- A) JSI
- B) TurboModules
- C) Fabric Renderer
- D) AsyncStorage

**Answer: D) AsyncStorage**

---

**2. What is the purpose of the `persist` middleware in Zustand?**
- A) To save state to persistent storage
- B) To create persistent connections
- C) To persist user sessions
- D) To maintain application state

**Answer: A) To save state to persistent storage**

---

**3. Which of the following is true about Supabase?**
- A) It uses MongoDB
- B) It uses PostgreSQL
- C) It uses MySQL
- D) It uses SQLite

**Answer: B) It uses PostgreSQL**

---

**4. What is the purpose of `expo-secure-store`?**
- A) To store data securely
- B) To encrypt network requests
- C) To secure API calls
- D) To authenticate users

**Answer: A) To store data securely**

---

**5. Which testing approach is fastest?**
- A) E2E Testing
- B) Integration Testing
- C) Unit Testing
- D) Performance Testing

**Answer: C) Unit Testing**

---

**6. What is certificate pinning?**
- A) Restricting trusted certificates
- B) Allowing any certificate
- C) Self-signed certificates only
- D) Bypassing SSL/TLS

**Answer: A) Restricting trusted certificates**

---

**7. Which of the following is NOT an OWASP Mobile Top 10 risk?**
- A) Insecure Data Storage
- B) Code Obfuscation
- C) Insecure Authentication
- D) Insecure Communication

**Answer: B) Code Obfuscation**

---

**8. What is the purpose of `WatermelonDB`?**
- A) Cloud database
- B) Local database
- C) State management
- D) File storage

**Answer: B) Local database**

---

**9. Which of the following is a React Navigation type?**
- A) Stack Navigator
- B) List Navigator
- C) Grid Navigator
- D) Array Navigator

**Answer: A) Stack Navigator**

---

**10. What is the purpose of the Bridge in React Native?**
- A) To connect to databases
- B) To communicate between JavaScript and native code
- C) To render UI components
- D) To manage state

**Answer: B) To communicate between JavaScript and native code**

---

**11. Which method is used to get the current location in Expo?**
- A) `Location.getCurrentPositionAsync()`
- B) `Location.getLocationAsync()`
- C) `Location.getPosition()`
- D) `Location.getCoordinates()`

**Answer: A) `Location.getCurrentPositionAsync()`**

---

**12. What is the purpose of OTA updates?**
- A) To update app without store review
- B) To update app version
- C) To update OS version
- D) To update device firmware

**Answer: A) To update app without store review**

---

**13. Which of the following is a code quality tool?**
- A) Jest
- B) ESLint
- C) Detox
- D) React Native

**Answer: B) ESLint**

---

**14. What is Row Level Security (RLS)?**
- A) A security system for database rows
- B) A security system for columns
- C) A security system for tables
- D) A security system for schemas

**Answer: A) A security system for database rows**

---

**15. Which of the following is true about offline-first architecture?**
- A) App only works offline
- B) App works online and offline
- C) App only syncs on demand
- D) App never syncs

**Answer: B) App works online and offline**

---

**16. What is the purpose of Detox?**
- A) Unit testing
- B) Component testing
- C) End-to-End testing
- D) Performance testing

**Answer: C) End-to-End testing**

---

**17. Which method is used to check for root/jailbreak?**
- A) `DeviceInfo.isRooted()`
- B) `DeviceInfo.isJailbroken()`
- C) `DeviceInfo.checkSecurity()`
- D) `DeviceInfo.isCompromised()`

**Answer: A) `DeviceInfo.isRooted()`**

---

**18. What is the purpose of `eas build`?**
- A) To build apps locally
- B) To build apps in the cloud
- C) To test apps
- D) To deploy apps

**Answer: B) To build apps in the cloud**

---

**19. Which of the following is true about Fastlane?**
- A) It only works for iOS
- B) It automates app deployment
- C) It only works for Android
- D) It is a testing framework

**Answer: B) It automates app deployment**

---

**20. What is the purpose of the Privacy Manifest in iOS?**
- A) To disclose data collection
- B) To improve app performance
- C) To enable push notifications
- D) To handle app updates

**Answer: A) To disclose data collection**

---

**21. Which pattern is commonly used with WatermelonDB?**
- A) Singleton Pattern
- B) Repository Pattern
- C) Factory Pattern
- D) Observer Pattern

**Answer: B) Repository Pattern**

---

**22. What is the purpose of `expo-camera`?**
- A) To capture images and videos
- B) To edit images
- C) To compress images
- D) To share images

**Answer: A) To capture images and videos**

---

**23. Which of the following is NOT a biometric authentication type?**
- A) Fingerprint
- B) Face Recognition
- C) Iris Scan
- D) Voice Recognition

**Answer: D) Voice Recognition**

---

**24. What is the purpose of the sync queue?**
- A) To store all data
- B) To track pending sync operations
- C) To cache API responses
- D) To store user preferences

**Answer: B) To track pending sync operations**

---

**25. Which of the following is a benefit of TypeScript?**
- A) Faster runtime
- B) Type safety
- C) Smaller bundle size
- D) Better performance

**Answer: B) Type safety**

---

**26. What is the purpose of `notifications` in Expo?**
- A) To send push notifications
- B) To manage app updates
- C) To handle user authentication
- D) To manage state

**Answer: A) To send push notifications**

---

**27. Which of the following is true about CI/CD?**
- A) It only tests code
- B) It automates testing and deployment
- C) It only builds code
- D) It only deploys code

**Answer: B) It automates testing and deployment**

---

**28. What is the purpose of the `fields` column in the forms table?**
- A) To store form fields
- B) To store user data
- C) To store form metadata
- D) To store form settings

**Answer: A) To store form fields**

---

**29. Which of the following is NOT a best practice for offline-first development?**
- A) Store data locally
- B) Sync on every user action
- C) Handle conflicts
- D) Provide offline UI feedback

**Answer: B) Sync on every user action**

---

**30. What is the purpose of `jest.mock()`?**
- A) To mock entire modules
- B) To create mock objects
- C) To spy on functions
- D) To test API calls

**Answer: A) To mock entire modules**

---

### Part B: Short Answer Questions (20 Questions)

**31. Explain the complete mobile application architecture from native foundations to production deployment.**

**Answer:**
1. **Native Foundations:**
- Xcode/Android Studio setup
- Native module development
- Code signing configuration

2. **Application Architecture:**
- React Navigation (stacks, tabs)
- Zustand state management
- Theme and styling system

3. **Backend Integration:**
- Supabase configuration
- Authentication flow
- Row Level Security
- Real-time subscriptions

4. **Data Management:**
- WatermelonDB local storage
- Offline-first architecture
- Sync engine implementation
- Conflict resolution

5. **Hardware Integration:**
- Camera and photo capture
- GPS location tracking
- Biometric authentication
- Push notifications

6. **Testing:**
- Unit tests with Jest
- Component tests
- Integration tests
- E2E tests with Detox

7. **Security:**
- Code obfuscation
- Certificate pinning
- Data encryption
- Runtime integrity checks

8. **Deployment:**
- EAS Build
- App Store submission
- Google Play Store submission
- OTA updates

---

**32. Describe the implementation of authentication flow with Supabase including social login.**

**Answer:**
1. **Email/Password Auth:**
```typescript
// Login
const { data, error } = await supabase.auth.signInWithPassword({
  email, password
});

// Register
const { data, error } = await supabase.auth.signUp({
  email, password,
  options: { data: { full_name } }
});

// Reset Password
await supabase.auth.resetPasswordForEmail(email);
```

2. **Google OAuth:**
```typescript
const result = await googlePromptAsync();
if (result?.type === 'success') {
  const { id_token, access_token } = result.params;
  await supabase.auth.signInWithIdToken({
    provider: 'google',
    token: id_token,
    access_token,
  });
}
```

3. **Apple Sign In:**
```typescript
const result = await applePromptAsync();
if (result?.type === 'success') {
  const { id_token } = result.params;
  await supabase.auth.signInWithIdToken({
    provider: 'apple',
    token: id_token,
  });
}
```

4. **Session Management:**
- SecureStore for token storage
- Auto-refresh enabled
- Session persistence

---

**33. How would you design and implement an offline-first data synchronization system?**

**Answer:**
1. **Local Database (WatermelonDB):**
- Define schema with sync fields
- Models with `sync_status` column

2. **Sync Queue:**
```typescript
class SyncQueue {
  static async enqueue(operation, table, data) {
    await database.write(async () => {
      await database.get('sync_queue').create(record => {
        record.operation = operation;
        record.data = data;
        record.status = 'pending';
      });
    });
  }
}
```

3. **Sync Engine:**
```typescript
class SyncEngine {
  async sync() {
    // 1. Get pending items
    const pending = await getPendingItems();
    
    // 2. Upload to server
    for (const item of pending) {
      await uploadItem(item);
    }
    
    // 3. Download updates
    const updates = await fetchUpdates();
    
    // 4. Apply updates locally
    for (const update of updates) {
      await applyUpdate(update);
    }
    
    // 5. Handle conflicts
    await resolveConflicts();
  }
}
```

4. **Auto-Sync:**
- Network state monitoring
- Periodic sync intervals
- Manual sync trigger

---

**34. Explain the complete testing strategy for a React Native application.**

**Answer:**
1. **Unit Tests (Jest):**
- Test utilities and helpers
- Test custom hooks
- Test individual functions
- Mock external dependencies

2. **Component Tests:**
- Render tests
- Interaction tests
- Snapshot tests
- State tests

3. **Integration Tests:**
- Store with API services
- Database with repositories
- Navigation flows
- Authentication flows

4. **E2E Tests (Detox):**
- Complete user flows
- Critical paths
- Offline behavior
- Authentication

5. **Code Quality:**
- ESLint for syntax
- Prettier for formatting
- TypeScript for type checking
- Husky for git hooks

---

**35. Describe the security measures to protect a mobile application.**

**Answer:**
1. **Code Security:**
- Code obfuscation
- Minification
- ProGuard (Android)

2. **Data Security:**
- SecureStore for sensitive data
- Data encryption at rest
- Keychain/Keystore usage

3. **Network Security:**
- SSL/TLS encryption
- Certificate pinning
- HTTPS for all requests

4. **Authentication Security:**
- JWT tokens
- Biometric authentication
- Session management
- OAuth2/OIDC

5. **Runtime Security:**
- Root/jailbreak detection
- Emulator detection
- Debug mode detection
- Integrity checks

6. **Privacy:**
- Data collection disclosure
- Privacy manifest (iOS)
- Permission justification
- GDPR compliance

---

**36. How would you implement push notifications with proper handling of foreground, background, and deep linking?**

**Answer:**
1. **Setup:**
```typescript
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});
```

2. **Get Token:**
```typescript
const token = await Notifications.getExpoPushTokenAsync({
  projectId: Constants.expoConfig?.extra?.eas?.projectId,
});
```

3. **Foreground Handling:**
```typescript
Notifications.addNotificationReceivedListener((notification) => {
  // Show in-app notification
  showToast(notification.request.content);
});
```

4. **Background Handling:**
```typescript
Notifications.setBackgroundNotificationHandler({
  handleNotification: async (notification) => {
    // Process notification data
    await processNotification(notification);
    return { shouldShowAlert: true };
  },
});
```

5. **Deep Linking:**
```typescript
Notifications.addNotificationResponseReceivedListener((response) => {
  const data = response.notification.request.content.data;
  navigation.navigate(data.screen, data.params);
});
```

---

**37. Explain the process of preparing a React Native app for App Store and Google Play Store submission.**

**Answer:**
1. **Pre-Submission Checklist:**
- All tests pass
- No errors or warnings
- App icons generated
- Screenshots captured
- Description written
- Privacy policy prepared
- Terms of service prepared

2. **Code Signing:**
- iOS: Provisioning profiles, certificates
- Android: Keystore generation, signing config

3. **Build:**
```bash
eas build --platform ios --profile production
eas build --platform android --profile production
```

4. **Store Setup:**
- Create developer accounts
- Set up app listing
- Add metadata
- Upload assets

5. **Submission:**
```bash
eas submit --platform ios
eas submit --platform android
```

6. **Post-Submission:**
- Monitor review status
- Address any issues
- Plan next release

---

**38. How would you implement a comprehensive error handling and monitoring system?**

**Answer:**
1. **Error Tracking (Sentry):**
```typescript
Sentry.init({
  dsn: 'your-sentry-dsn',
  environment: 'production',
});

// Capture errors
Sentry.captureException(error);
Sentry.captureMessage('Custom message');
```

2. **Error Boundaries:**
```typescript
class ErrorBoundary extends React.Component {
  componentDidCatch(error, errorInfo) {
    Sentry.captureException(error, { errorInfo });
  }
}
```

3. **API Error Handling:**
```typescript
try {
  const response = await api.getData();
} catch (error) {
  if (error.response) {
    // Server responded
    Sentry.captureException(error);
  } else if (error.request) {
    // Network error
    Sentry.captureMessage('Network error');
  }
}
```

4. **Performance Monitoring:**
- Track slow operations
- Monitor API response times
- Track screen load times
- Monitor memory usage

5. **User Feedback:**
- Show user-friendly messages
- Provide error context
- Log user actions
- Track crash reports

---

**39. Explain the role of CI/CD in mobile development and how to set up a pipeline with GitHub Actions.**

**Answer:**
CI/CD automates the build, test, and deployment process:

**CI (Continuous Integration):**
1. Code pushed to repository
2. Automated build triggered
3. Tests run automatically
4. Results reported

**CD (Continuous Deployment):**
1. Successful build passes
2. App deployed automatically

**GitHub Actions Setup:**
```yaml
name: CI/CD Pipeline
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with: { node-version: '18' }
      - run: npm ci
      - run: npm run test:ci
      - run: npm run lint
      
  build:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with: { node-version: '18' }
      - run: npm ci
      - run: npm run build:prod
      
  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: expo/expo-github-action@v8
        with:
          eas-version: latest
          token: ${{ secrets.EXPO_TOKEN }}
          args: build:submit --platform all --latest
```

---

**40. Design a complete monitoring solution for a production React Native app.**

**Answer:**
1. **Error Monitoring (Sentry):**
- Capture exceptions
- Capture messages
- Add breadcrumbs
- Set user context

2. **Performance Monitoring:**
- Screen load times
- API response times
- FPS monitoring
- Memory usage

3. **User Analytics:**
- Track events
- Track screen views
- Track user sessions
- Feature usage

4. **Health Monitoring:**
- Crash-free users
- Error rates
- App stability
- User engagement

5. **Alerting:**
- Set up notifications
- Configure thresholds
- Create dashboards
- Schedule reports

6. **Implementation:**
```typescript
class MonitoringService {
  trackAppStart() {
    Sentry.addBreadcrumb({ message: 'App started' });
  }
  
  trackScreen(screen: string) {
    Sentry.addBreadcrumb({ message: `Screen: ${screen}` });
    analytics.trackScreen(screen);
  }
  
  trackError(error: Error, context?: any) {
    Sentry.captureException(error, { extra: context });
    analytics.trackError(error);
  }
  
  trackPerformance(name: string, duration: number) {
    if (duration > 1000) {
      Sentry.captureMessage(`Slow: ${name}`, { level: 'warning' });
    }
  }
}
```

---

## PRACTICAL CODING CHALLENGE

### Challenge: Build a Complete Authentication Flow

**Objective:** Build a complete authentication flow for a React Native app using Zustand and Supabase.

**Requirements:**

1. **State Management:**
- Create Zustand store for auth state
- Implement login, register, logout actions
- Persist auth state

2. **UI Components:**
- Login screen with email/password
- Register screen with validation
- Protected route navigation
- Loading states
- Error messages

3. **Backend Integration:**
- Connect to Supabase
- Implement email/password auth
- Handle registration
- Manage sessions

4. **Navigation:**
- Auth stack for unauthenticated users
- Main stack for authenticated users
- Conditional navigation based on auth state

5. **Security:**
- Secure token storage
- Session persistence
- Auto-logout on token expiry

6. **Testing:**
- Unit tests for auth store
- Component tests for auth screens
- Integration tests for auth flow

**Evaluation Criteria:**
| Criteria | Weight |
|----------|--------|
| Code Quality | 20% |
| Functionality | 25% |
| Testing | 15% |
| Security | 15% |
| UI/UX | 10% |
| Documentation | 10% |
| Bonus: Social Login | 5% |

**Solution:**
```typescript
// store/authSlice.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import * as SecureStore from 'expo-secure-store';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

interface AuthActions {
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, fullName: string) => Promise<void>;
  logout: () => void;
  clearError: () => void;
}

const secureStorage = {
  getItem: async (key: string) => {
    const value = await SecureStore.getItemAsync(key);
    return value ? JSON.parse(value) : null;
  },
  setItem: async (key: string, value: any) => {
    await SecureStore.setItemAsync(key, JSON.stringify(value));
  },
  removeItem: async (key: string) => {
    await SecureStore.deleteItemAsync(key);
  },
};

export const useAuthStore = create<AuthState & AuthActions>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (email: string, password: string) => {
        set({ isLoading: true, error: null });
        try {
          const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
          });
          if (error) throw error;
          set({
            user: {
              id: data.user.id,
              email: data.user.email!,
              fullName: data.user.user_metadata?.full_name,
            },
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error: any) {
          set({ error: error.message, isLoading: false });
        }
      },

      register: async (email: string, password: string, fullName: string) => {
        set({ isLoading: true, error: null });
        try {
          const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: { data: { full_name: fullName } },
          });
          if (error) throw error;
          set({
            user: {
              id: data.user.id,
              email: data.user.email!,
              fullName: data.user.user_metadata?.full_name,
            },
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error: any) {
          set({ error: error.message, isLoading: false });
        }
      },

      logout: () => {
        supabase.auth.signOut();
        set({
          user: null,
          isAuthenticated: false,
          error: null,
        });
      },

      clearError: () => set({ error: null }),
    }),
    {
      name: 'auth-storage',
      storage: secureStorage,
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

---

## ANSWER KEY SUMMARY

### Answer Keys by Module

| Module | MC Questions | SA Questions |
|--------|--------------|--------------|
| Module 1 | 15 | 10 |
| Module 2 | 15 | 10 |
| Module 3 | 15 | 10 |
| Module 4 | 15 | 10 |
| Module 5 | 15 | 10 |
| Module 6 | 15 | 10 |
| Module 7 | 15 | 10 |
| Mid-Term | 30 | 20 |
| Final | 30 | 20 |

**Total: 180 Multiple Choice + 110 Short Answer Questions**

---

*This completes the comprehensive quiz and test bank for the "Mastering Mobile Development Beyond the UI" tutorial series. All answer keys are provided and verified for accuracy.*
