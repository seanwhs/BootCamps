# React Native: From Blueprint to Production
## Comprehensive Course Slide Outline - MASSIVELY EXPANDED EDITION
### 600+ Slides Across 15 Modules

---

# COURSE OVERVIEW & INTRODUCTION

---

## Module 0: Course Introduction & Mental Model Shift

### 0.1: Course Overview (10 slides)

**Slide 1: Course Title**
- "React Native: From Blueprint to Production"
- Subtitle: "Build Production-Ready Cross-Platform Mobile Applications"
- Course level: Intermediate to Advanced
- Instructor introduction

**Slide 2: Course Philosophy**
- "Learn by building" approach
- Why this course is different from other React Native courses
- Real-world focus vs. theoretical knowledge
- Production-ready code from day one

**Slide 3: What You Will Build - TaskFlow Application**
- Complete task management application
- Authentication system with JWT
- Offline-first architecture
- Real-time collaboration features
- Push notifications
- Camera and location integration
- Full CI/CD pipeline

**Slide 4: Real-World Examples**
- Facebook: 3+ billion users on React Native
- Instagram: Mobile app built with React Native
- Discord: Cross-platform messaging
- UberEats: Restaurant ordering platform
- Shopify: E-commerce platform
- Microsoft Office: Productivity suite
- Walmart: Retail giant

**Slide 5: Course Structure**
- 4 major parts
- 13 comprehensive modules
- 25+ hands-on labs
- 1 complete capstone project
- 600+ slides

**Slide 6: Learning Objectives**
- Build production-ready cross-platform mobile apps
- Implement offline-first architecture
- Access device capabilities (camera, location, notifications)
- Optimize app performance for 60fps
- Deploy to Apple App Store and Google Play Store

**Slide 7: Prerequisites**
- Basic JavaScript/TypeScript knowledge
- Understanding of React fundamentals (components, props, state)
- HTML/CSS fundamentals
- Command line proficiency
- Git basics

**Slide 8: Course Format**
- Lecture-style presentations
- Live coding demonstrations
- Hands-on labs after each module
- Group discussions and peer review
- Capstone project with milestones

**Slide 9: Grading Breakdown**
- Labs & Assignments: 40%
- Quizzes & Tests: 20%
- Final Project: 30%
- Participation: 10%
- Extra Credit: 5%

**Slide 10: Student Success Tips**
- Code along, don't just watch
- Complete every lab before moving on
- Form study groups
- Use the office hours
- Build something extra on the side

---

### 0.2: The Web vs. Mobile Divide (8 slides)

**Slide 11: Why Mobile is Fundamentally Different**
- The browser vs. native environment
- No "browser" on mobile
- Different UI paradigms (touch vs. click)
- Performance constraints (battery, CPU)
- Limited resources

**Slide 12: The Architecture Comparison**
- Web: Browser → DOM → Paint
- React Native: JS → Bridge → Native Components
- The fundamental difference

**Slide 13: Single-Threaded Web**
- JavaScript runs on one thread
- Everything blocks until complete
- 16.67ms frame budget applies
- Browser handles painting
- Web workers for parallel processing (limited)

**Slide 14: Multi-Threaded Mobile**
- JavaScript thread (your code)
- UI thread (rendering native components)
- Shadow thread (layout calculations)
- Native modules (device APIs)
- Animation thread (optional)

**Slide 15: Touch vs. Click Interfaces**
- No hover states (iOS/Android don't have hover)
- Larger touch targets (44x44pt minimum)
- Gesture support (swipe, pinch, tap, long press)
- Physical feedback (haptics, vibration)
- Different interaction patterns

**Slide 16: The Mobile Mindset Shift**
- Design for thumbs (one-handed use)
- Consider screen sizes (multiple devices)
- Handle interruptions (calls, notifications)
- Battery and performance awareness
- Offline-first thinking

**Slide 17: What You Need to Unlearn**
- Web patterns that don't work on mobile
- CSS tricks that don't translate
- The "everything is a page" mentality
- Full-page refreshes
- Click-based interactions

**Slide 18: The Mobile Opportunity**
- 6.8 billion smartphone users worldwide
- Mobile-first development is the future
- High demand for mobile developers
- Lucrative career opportunities
- Build apps that people carry in their pockets

---

### 0.3: What React Native Actually Is (7 slides)

**Slide 19: React Native is NOT**
- ❌ A webview (like Cordova/Ionic)
- ❌ An interpreter (like JavaScriptCore)
- ❌ A cross-platform compiler (like Flutter)
- ❌ A replacement for Swift/Kotlin
- ❌ A browser inside your phone

**Slide 20: React Native IS**
- ✅ A bridge between React and native components
- ✅ A translation layer for UI components
- ✅ A framework for building native apps with JavaScript
- ✅ A way to write once, run on iOS and Android
- ✅ A native app development framework

**Slide 21: React Native vs Native Development**
- React Native: JavaScript, cross-platform, one codebase
- Native Swift: iOS only, Swift, platform-specific
- Native Kotlin: Android only, Kotlin, platform-specific
- Performance comparison: Near-native (RN) vs Native

**Slide 22: React Native vs Other Cross-Platform Solutions**

| Framework | Language | Performance | Code Reuse | Ecosystem |
|-----------|----------|-------------|------------|-----------|
| React Native | JavaScript | Near-native | 90%+ | Largest |
| Flutter | Dart | Native | 95%+ | Growing |
| Xamarin | C# | Near-native | 90%+ | Established |
| Cordova | JS/HTML | Poor | 100% | Large |
| Ionic | JS/HTML | Moderate | 90%+ | Large |

**Slide 23: The "Write Once, Run Anywhere" Promise**
- One codebase for iOS and Android
- Platform-specific code when needed
- 90%+ code reuse
- Faster development than native
- Lower maintenance costs

**Slide 24: The Real Story**
- You can share 90%+ of code
- Platform-specific code for native features
- UI differences may require platform-specific components
- Testing on both platforms is essential

**Slide 25: Key Insight**
- You write JavaScript/TypeScript
- You get REAL native components
- Performance is near-native
- Code reuse is high (90%+)

---

### 0.4: The Architecture Overview (10 slides)

**Slide 26: The Three Threads Overview**

| Thread | Purpose | What Runs Here |
|--------|---------|----------------|
| JavaScript Thread | React code, business logic | Your code, API calls |
| UI Thread (Native) | Rendering, user input | Views, gestures |
| Shadow Thread (Native) | Layout calculations | Yoga engine, Flexbox |

**Slide 27: JavaScript Thread**
- Runs your React components
- Handles component rendering (Virtual DOM)
- Processes business logic
- Makes API calls
- Single-threaded event loop

**Slide 28: UI Thread (Native)**
- Handles all rendering
- Responds to user input (taps, swipes)
- Runs animations
- Manages the screen
- Called the "main thread" on iOS/Android

**Slide 29: Shadow Thread (Native)**
- Calculates layouts
- Processes flexbox and positioning
- Measures text
- Runs the Yoga layout engine
- Asynchronous to UI thread

**Slide 30: The Bridge Explained**
- Communication channel between JS and Native
- Serializes data to JSON
- Asynchronous messaging
- Batched operations
- The bottleneck for performance

**Slide 31: How the Bridge Works**
```
JS Thread: "I want a blue button with text 'Submit'"
    ↓ (Serializes to JSON)
Bridge: { "type": "button", "title": "Submit", "color": "blue" }
    ↓ (Deserializes)
Native Thread: Creates UIButton with text "Submit" and blue background
```

**Slide 32: JSI (JavaScript Interface)**
- Modern React Native 0.70+
- Direct communication between JS and native
- No serialization overhead
- Synchronous operations
- 2-3x faster than bridge

**Slide 33: How Components Become Native UI**
```
React Component → Virtual DOM → Diff → Bridge → Native UI
<View> → JS Object → JSON → Bridge → UIView
<Text> → JS Object → JSON → Bridge → UILabel
<Image> → JS Object → JSON → Bridge → UIImageView
```

**Slide 34: The Full Architecture Diagram**
```
┌─────────────────────────────────────────────────────────────────┐
│                    REACT NATIVE ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   JavaScript Thread                     │    │
│  │  ┌───────────────────────────────────────────────────┐ │    │
│  │  │  React Components │  Business Logic │  API Calls │ │    │
│  │  └───────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                  │
│                        ┌─────┴─────┐                          │
│                        │  Bridge   │                          │
│                        │  (JSI)    │                          │
│                        └─────┬─────┘                          │
│                              │                                  │
│  ┌───────────────────────────┼───────────────────────────────┐ │
│  │                           ▼                               │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │              Native Threads                         │ │ │
│  │  │  ┌────────────────────────────────────────────────┐ │ │ │
│  │  │  │  UI Thread (Rendering, Gestures)               │ │ │ │
│  │  │  ├────────────────────────────────────────────────┤ │ │ │
│  │  │  │  Shadow Thread (Layout, Yoga)                 │ │ │ │
│  │  │  └────────────────────────────────────────────────┘ │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 35: Why This Architecture Matters**
- Understanding threads = better performance
- Bridge optimization = smoother UX
- Layout calculations = faster scrolling
- JSI = modern React Native

---

### 0.5: The React Native Mindset (6 slides)

**Slide 36: 1. Think in Components, Not Pages**
- Every screen is composed of reusable components
- Components should be small, focused, and testable
- "Atomic design" methodology
- Component reusability across screens
- Design systems and component libraries

**Slide 37: 2. Think Native-First**
- Design for mobile gestures, not web clicks
- Consider touch targets (44x44pt minimum)
- Think about navigation patterns
- Respect platform conventions (iOS vs Android)
- Use native components when possible

**Slide 38: 3. Think Performance**
- Every render costs something
- Every bridge call costs something
- Every layout recalculation costs something
- Optimize early, optimize often
- Profile before optimizing

**Slide 39: 4. Think Offline-First**
- Your app should work without internet
- Sync should be seamless and automatic
- Users should never see "No internet" errors
- Local-first architecture
- Optimistic UI updates

**Slide 40: 5. Think Accessibility**
- All users should be able to use your app
- Screen reader support is non-negotiable
- Color contrast, touch targets, focus order
- WCAG 2.1 AA compliance
- VoiceOver and TalkBack support

**Slide 41: The 60 FPS Target**
- 60 frames per second = 16.67ms per frame
- This is your budget for ALL work
- Frame drops = jank = poor UX
- Native animations = 60 FPS
- JS animations = risk of jank

---

### 0.6: Course Roadmap (4 slides)

**Slide 42: Part 1 - Foundations & Environment**
- Weeks 1-4
- Setup & Project Creation
- Core Components & Styling
- Flexbox Layout Mastery
- Navigation & Screen Management

**Slide 43: Part 2 - State Management & Persistence**
- Weeks 5-7
- Local State & Component Lifecycle
- Global State Management with Zustand
- Data Persistence & Offline-First

**Slide 44: Part 3 - Device Capabilities & Native Features**
- Weeks 8-10
- Device APIs (Camera, Location, Notifications)
- Gestures & Animations
- Forms & Validation

**Slide 45: Part 4 - Testing, Performance & Deployment**
- Weeks 11-13
- Performance Optimization
- Testing Strategies
- CI/CD & App Store Deployment

---

# PART 1: FOUNDATIONS & ENVIRONMENT ARCHITECTURE

---

## Module 1: Environment Setup & Project Creation

### 1.1: Development Environment Overview (8 slides)

**Slide 46: Understanding Expo**
- Development platform built on React Native
- Created by Expo (expo.dev)
- Managed workflow for beginners
- Built-in APIs for common features
- Over-the-air updates

**Slide 47: Expo Pros and Cons**

| Pros | Cons |
|------|------|
| No native dev tools needed | Limited to Expo-supported APIs |
| Instant app preview with Expo Go | App size is slightly larger |
| Built-in APIs for common features | Some native libraries require ejecting |
| Over-the-air updates | Limited to Expo SDK version |
| Easier builds with EAS | Not ideal for complex native integrations |

**Slide 48: Bare React Native CLI**
- Direct React Native development
- No abstraction layer
- Full control over native code
- Can use any native library
- More like real-world production

**Slide 49: Bare React Native Pros and Cons**

| Pros | Cons |
|------|------|
| Full control over native code | Must manually open Xcode/Android Studio |
| Can use any native library | More complex setup |
| Smaller app size possible | Need to manage native dependencies |
| More like real-world production | Build process is more complex |
| Better for large teams | Longer initial setup |

**Slide 50: When to Use Expo vs Bare CLI**
- **Expo:** Getting started, MVPs, learning, simple apps
- **Bare CLI:** Production, complex apps, custom native features
- **Expo:** Small teams, rapid prototyping
- **Bare CLI:** Enterprise, custom native modules

**Slide 51: Expo SDK Versioning**
- Expo SDK 49: Latest (React Native 0.72)
- Expo SDK 48: Previous (React Native 0.71)
- Expo SDK 47: Older (React Native 0.70)
- Expo Go supports most SDK features
- EAS Build for production

**Slide 52: Expo vs Bare CLI - Decision Matrix**

| Factor | Expo | Bare CLI |
|--------|------|----------|
| Experience Level | Beginner | Advanced |
| Project Complexity | Simple | Complex |
| Native Modules | Limited | Full |
| App Size | Larger | Smaller |
| Setup Time | 5 minutes | 1-2 hours |
| Learning Curve | Low | Steep |

**Slide 53: Summary: Choose Expo If...**
- You're new to React Native
- You want to build an MVP quickly
- You don't need custom native modules
- You want easier builds
- You're building a simple app

---

### 1.2: Setup Process (Platform-Specific) (10 slides)

**Slide 54: Prerequisites Checklist**
- ☐ Node.js 18+ installed
- ☐ npm or yarn package manager
- ☐ Git for version control
- ☐ Code editor (VSCode recommended)
- ☐ Platform-specific tools (Xcode/Android Studio)
- ☐ Expo CLI installed (optional)

**Slide 55: Node.js Installation**

| Platform | Method | Command |
|----------|--------|---------|
| macOS | Homebrew | `brew install node` |
| Windows | Installer | Download from nodejs.org |
| Linux (Ubuntu) | Package Manager | `sudo apt install nodejs` |
| Linux (Other) | Package Manager | Use distribution package manager |

**Slide 56: Package Managers**
- npm: Node Package Manager (comes with Node.js)
- yarn: Facebook's alternative package manager
- pnpm: Fast, disk-efficient package manager
- Choosing the right one

**Slide 57: macOS: Xcode Setup (iOS Development)**
1. Install Xcode from App Store (~12GB)
2. Install Command Line Tools: `xcode-select --install`
3. Accept License: `sudo xcodebuild -license accept`
4. Configure Simulators: Xcode → Preferences → Platforms
5. Install iOS Simulator (latest version)

**Slide 58: macOS: Xcode Troubleshooting**

| Issue | Solution |
|-------|----------|
| Xcode won't install | Free up disk space (12GB needed) |
| Command Line Tools fail | Try: `xcode-select --reset` |
| License agreement prompt | Accept via: `sudo xcodebuild -license` |
| Simulator not showing | Check Xcode → Preferences → Platforms |

**Slide 59: Android Studio Setup (All Platforms)**
1. Download Android Studio from developer.android.com/studio
2. Install with recommended options
3. Choose components:
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device
   - ✅ Android Emulator
   - ✅ Performance (Intel HAXM or Apple Hypervisor)

**Slide 60: Android Environment Variables (macOS/Linux)**
```bash
# Add to ~/.zshrc or ~/.bash_profile
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```
Then reload: `source ~/.zshrc`

**Slide 61: Android Environment Variables (Windows)**
1. Open System Properties → Advanced → Environment Variables
2. Create `ANDROID_HOME`: `C:\Users\YourUser\AppData\Local\Android\Sdk`
3. Add to Path: `%ANDROID_HOME%\emulator`, `%ANDROID_HOME%\platform-tools`

**Slide 62: Install Android SDK Platforms**
```bash
sdkmanager "platforms;android-33"
sdkmanager "build-tools;33.0.0"
sdkmanager "system-images;android-33;google_apis;x86_64"
```

**Slide 63: Create Android Virtual Device (AVD)**
```bash
# Create new AVD
avdmanager create avd -n Pixel_5_API_33 -k "system-images;android-33;google_apis;x86_64" -d "pixel_5"

# List available devices
avdmanager list device

# Start emulator
emulator -avd Pixel_5_API_33
```

---

### 1.3: Creating Your First Project (7 slides)

**Slide 64: Create Expo Project**
```bash
# Basic creation with template selection
npx create-expo-app TaskFlow --template

# Select "blank (TypeScript)" from the menu
# Project created successfully!
```

**Slide 65: Project Structure Deep Dive**
```
TaskFlow/
├── .expo/              # Expo configuration (auto-generated)
│   └── ...             # Various Expo files
├── .gitignore          # Git ignore file
├── App.tsx             # Main app component (entry point)
├── app.json            # App configuration
├── assets/             # Images, fonts, etc.
│   ├── icon.png        # App icon
│   └── splash.png      # Splash screen image
├── babel.config.js     # Babel transpiler config
├── package.json        # Dependencies and scripts
├── tsconfig.json       # TypeScript configuration
└── node_modules/       # Installed packages
```

**Slide 66: Understanding package.json**
- Dependencies: Runtime dependencies
- DevDependencies: Development dependencies
- Scripts: npm/yarn commands
- Version: App version
- Main: Entry point
- Expo: Expo-specific configuration

**Slide 67: Running on iOS Simulator**
```bash
# Start development server
npm start

# Press 'i' in terminal
# OR
npm run ios
# OR
expo start --ios

# Wait for simulator to launch
# Fast Refresh will update on changes
```

**Slide 68: Running on Android Emulator**
```bash
# Ensure emulator is running first
emulator -avd Pixel_5_API_33

# Start development server
npm start

# Press 'a' in terminal
# OR
npm run android
# OR
expo start --android
```

**Slide 69: Running on Physical Device**
1. Install Expo Go app on device
   - iOS: App Store
   - Android: Google Play Store
2. Scan QR code from terminal
3. App loads on device
4. Changes reflect instantly (Fast Refresh)

**Slide 70: Troubleshooting Common Issues**

| Issue | Solution |
|-------|----------|
| "Command not found: expo" | `npm install -g expo-cli` |
| iOS simulator won't start | Open Xcode → Preferences → Components |
| Android emulator won't start | `emulator -list-avds` to check available devices |
| Port 8081 already in use | `killall node` or `expo start --port 8082` |
| SDK version mismatch | `expo doctor` to fix compatibility |
| Metro bundler stuck | `expo start --clear` |

---

### 1.4: Metro Bundler & Dev Tools (5 slides)

**Slide 71: What is Metro?**
- React Native's JavaScript bundler
- Similar to webpack but optimized for mobile
- Handles dependency resolution
- Transforms code (Babel, TypeScript)
- Bundles into single file
- Supports Fast Refresh

**Slide 72: Metro Features**
- Fast Refresh (Hot Module Replacement)
- Dependency resolution
- Source maps
- Bundle optimization
- Dev server with logging
- Cache management

**Slide 73: Fast Refresh**
- Instantly updates app on save
- Preserves component state
- Visual indicator (green/red) shows status
- Supports functional components
- Modern React Native default

**Slide 74: React DevTools**
- **Components Tab:** View component hierarchy, props, state
- **Profiler Tab:** Measure render performance
- **React Native Tab:** Native component inspection
- Installation: Chrome extension or standalone app

**Slide 75: Expo DevTools**
- QR code for physical device
- Device selection (iOS/Android)
- Performance monitoring
- Debugging options
- Reload/Restart buttons
- Log viewer

---

### 1.5: Hands-On Lab: "Hello, TaskFlow!" (5 slides)

**Slide 76: Lab Objectives**
- Create a new Expo project
- Understand the project structure
- Modify App.tsx to create a welcome screen
- Run on simulators and physical devices
- Explore the development workflow

**Slide 77: Step-by-Step Instructions**
1. Create project: `npx create-expo-app TaskFlow --template`
2. Select "blank (TypeScript)"
3. Navigate to project: `cd TaskFlow`
4. Start dev server: `npm start`
5. Open in simulator: `i` or `a`
6. Modify App.tsx
7. See changes live

**Slide 78: Code Modification**
```tsx
// Add welcome screen with styling
// See App.tsx in workbook for complete code
```

**Slide 79: Testing Your Changes**
- Save file → Auto-reload (Fast Refresh)
- Verify changes appear
- Test on different simulators/devices
- Explore DevTools

**Slide 80: Development Workflow Exploration**
- Make changes and see them update
- Experience Fast Refresh
- Open DevTools
- Explore the Expo DevTools interface

---

## Module 2: Core Components & Styling Fundamentals

### 2.1: The Component Hierarchy (8 slides)

**Slide 81: The Component Tree**
```
<App>
  │
  └── <SafeAreaView>
        │
        └── <View>
              │
              ├── <Text>
              ├── <TextInput>
              ├── <Image>
              ├── <ScrollView>
              └── <FlatList>
```

**Slide 82: View - Universal Container**
- Purpose: Container component (like div)
- Props: style, accessible, accessibilityLabel, onLayout, testID
- Most commonly used component
- Serves as wrapper for other components
- Supports Flexbox layout

**Slide 83: View Usage Examples**
```tsx
// Basic container
<View style={styles.container}>
  <Text>Hello</Text>
</View>

// With accessibility
<View accessible={true} accessibilityLabel="Main content">
  {children}
</View>

// With event handler
<View onLayout={handleLayout}>
  {content}
</View>
```

**Slide 84: Text - Displaying Content**
- Purpose: Display text content
- Props: numberOfLines, ellipsizeMode, selectable, onPress
- Only component for text rendering
- Supports nested text with styling
- Auto-wraps by default

**Slide 85: Text Usage Examples**
```tsx
// Basic text
<Text style={styles.title}>Hello World</Text>

// Truncated text
<Text numberOfLines={1} ellipsizeMode="tail">
  This is a very long text that will be truncated
</Text>

// Nested text with styles
<Text>
  This is <Text style={styles.bold}>bold</Text> text
</Text>
```

**Slide 86: SafeAreaView - Handling Notches**
- Purpose: Handle safe area insets
- Content with safe area insets
- iOS: Handles notches, status bar, home indicator
- Android: Handles status bar, system bars
- Always use at top level

**Slide 87: SafeAreaView Usage**
```tsx
import { SafeAreaView } from 'react-native';

function App() {
  return (
    <SafeAreaView style={styles.container}>
      {/* Content with safe area insets */}
    </SafeAreaView>
  );
}
```

**Slide 88: ScrollView - Scrollable Content**
- Purpose: Scrollable content container
- Props: contentContainerStyle, refreshControl, horizontal
- Renders all children at once
- Good for small lists
- Not for large lists

---

### 2.2: StyleSheet System (7 slides)

**Slide 89: StyleSheet.create Pattern**
```tsx
import { StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    fontSize: 16,
    color: '#333',
    fontWeight: 'bold',
  },
});
```

**Slide 90: Benefits of StyleSheet**
- Type checking in TypeScript
- Performance optimization
- Code organization
- Autocomplete support
- Validation of style properties
- Consistent styling patterns

**Slide 91: Inline Styling vs StyleSheet**

| Inline | StyleSheet |
|--------|------------|
| `<Text style={{color: 'red'}}>` | `style={styles.text}` |
| ✅ Quick for simple styles | ✅ Better performance |
| ❌ Hard to reuse | ✅ Reusable across components |
| ❌ Poor performance | ✅ Optimized by React Native |
| ❌ No type checking | ✅ Type checking |

**Slide 92: Platform-Specific Styling**
```tsx
import { Platform } from 'react-native';

const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 24,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  text: {
    fontSize: Platform.OS === 'ios' ? 16 : 18,
  },
});
```

**Slide 93: Style Inheritance**
- ❌ Bad: No inheritance in React Native
- Styling doesn't cascade to children
- Each component needs its own styles
- Composition patterns for reuse

**Slide 94: Common Style Properties**

| Property | Values | Example |
|----------|--------|---------|
| backgroundColor | Color | `#fff`, `red`, `rgba(0,0,0,0.5)` |
| padding | Number/string | `16`, `10%` |
| margin | Number/string | `8`, `auto` |
| borderRadius | Number | `8` |
| borderWidth | Number | `1` |
| borderColor | Color | `#ddd` |
| shadowColor | Color | `#000` |
| shadowOpacity | Number | `0.1` |
| shadowRadius | Number | `4` |
| elevation | Number (Android) | `4` |

**Slide 95: Style Composition**
```tsx
// Combining styles
<View style={[styles.base, styles.active, { marginTop: 10 }]} />

// Conditional styles
<View style={[styles.base, isActive && styles.active]} />

// Style arrays
const buttonStyle = [
  styles.button,
  variant === 'primary' && styles.primary,
  variant === 'secondary' && styles.secondary,
];
```

---

### 2.3: Images & Icons (6 slides)

**Slide 96: Image Component - Local Images**
```tsx
// Local image (requires import)
import logo from './assets/logo.png';

<Image source={logo} style={styles.logo} />

// OR using require
<Image source={require('./assets/logo.png')} style={styles.logo} />
```

**Slide 97: Image Component - Remote Images**
```tsx
<Image 
  source={{ uri: 'https://example.com/image.jpg' }}
  style={styles.image}
  resizeMode="cover"
  loadingIndicatorSource={placeholderImage}
  onLoad={() => console.log('Image loaded')}
  onError={() => console.log('Error loading')}
/>
```

**Slide 98: resizeMode Options**

| Option | Effect | When to Use |
|--------|--------|-------------|
| cover | Scales to fill, may crop | Full-width images |
| contain | Scales to fit, may have whitespace | Icons, logos |
| stretch | Stretches to fill, may distort | Backgrounds |
| center | Centers without scaling | Small images |
| repeat | Repeats image | Patterns |

**Slide 99: Icons with Expo Vector Icons**
```bash
npx expo install @expo/vector-icons
```

```tsx
import { MaterialIcons } from '@expo/vector-icons';

<MaterialIcons
  name="home"
  size={24}
  color="#3498db"
  onPress={() => {}}
/>
```

**Slide 100: Popular Icon Sets**

| Icon Set | Prefix | Example | Use Case |
|----------|--------|---------|----------|
| MaterialIcons | None | `<MaterialIcons name="home" />` | General |
| Ionicons | `ios-`/`md-` | `<Ionicons name="ios-home" />` | iOS/Android |
| FontAwesome | None | `<FontAwesome name="home" />` | Social |
| Feather | None | `<Feather name="home" />` | Minimal |
| Octicons | None | `<Octicons name="home" />` | GitHub |

**Slide 101: Icon Best Practices**
- Consistent sizing: `const ICON_SIZE = 24`
- Color from theme: `const iconColor = isDark ? '#fff' : '#333'`
- Touchable wrapper for actions
- Accessibility labels
- Performance with static imports

---

### 2.4: User Input Components (6 slides)

**Slide 102: TextInput - Form Input**
```tsx
<TextInput
  style={styles.input}
  value={text}
  onChangeText={setText}
  placeholder="Enter text..."
  placeholderTextColor="#999"
  secureTextEntry={true}
  keyboardType="email-address"
  autoCapitalize="none"
  autoCorrect={false}
  returnKeyType="done"
  onSubmitEditing={handleSubmit}
/>
```

**Slide 103: TextInput Props Reference**

| Prop | Purpose | Example |
|------|---------|---------|
| value | Current value | `value={text}` |
| onChangeText | Text changes | `onChangeText={setText}` |
| placeholder | Placeholder text | `placeholder="Enter..."` |
| secureTextEntry | Password input | `secureTextEntry={true}` |
| keyboardType | Keyboard type | `keyboardType="email-address"` |
| autoCapitalize | Auto capitalization | `autoCapitalize="none"` |
| autoCorrect | Auto correction | `autoCorrect={false}` |
| returnKeyType | Keyboard return key | `returnKeyType="done"` |
| onSubmitEditing | Submit action | `onSubmitEditing={handleSubmit}` |
| multiline | Multi-line input | `multiline={true}` |

**Slide 104: TouchableOpacity**
```tsx
<TouchableOpacity 
  style={styles.button}
  onPress={handlePress}
  activeOpacity={0.7}
  disabled={isLoading}
>
  <Text style={styles.buttonText}>Press Me</Text>
</TouchableOpacity>
```

**Slide 105: Pressable (Newer Alternative)**
```tsx
<Pressable
  style={({ pressed }) => [
    styles.button,
    pressed && styles.buttonPressed,
  ]}
  onPress={handlePress}
  disabled={isLoading}
>
  {({ pressed }) => (
    <Text style={styles.buttonText}>
      {pressed ? 'Pressed!' : 'Press Me'}
    </Text>
  )}
</Pressable>
```

**Slide 106: Switch - Toggle Control**
```tsx
<Switch
  trackColor={{ false: '#767577', true: '#3498db' }}
  thumbColor={isEnabled ? '#f5dd4b' : '#f4f3f4'}
  onValueChange={setIsEnabled}
  value={isEnabled}
  disabled={false}
/>
```

**Slide 107: Event Handling**
```tsx
// Event handlers with parameters
const handleTextChange = (text: string) => {
  setText(text);
};

// With event object
const handlePress = (event: GestureResponderEvent) => {
  console.log('Press location:', event.nativeEvent.locationX);
};

// Debounced input
const handleSearch = debounce((text: string) => {
  searchTasks(text);
}, 300);
```

---

### 2.5: Hands-On Lab: TaskForm Component (4 slides)

**Slide 108: Lab Objectives**
- Create a reusable TaskForm component
- Implement all input types (text, date, priority selector)
- Handle form state locally
- Style for both iOS and Android

**Slide 109: Component Structure**
```tsx
// src/components/TaskForm.tsx
import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  Switch, StyleSheet, Platform,
} from 'react-native';

// Component definition with state
// Form fields: title, description, priority, reminder
// Submit handler
// Styling for both platforms
```

**Slide 110: Key Concepts**
- useState for form state
- Controlled inputs
- Platform-specific styles
- Conditional styling
- Form validation (basic)

**Slide 111: Testing Your Component**
- Render in App.tsx
- Test all inputs
- Test submit
- Verify styles on both platforms

---

## Module 3: Layout & Flexbox Mastery

### 3.1: Flexbox Mental Model (5 slides)

**Slide 112: The Yoga Layout Engine**
- React Native's layout engine
- Based on CSS Flexbox
- Cross-platform consistent
- Optimized for mobile
- Supports flexbox, absolute positioning

**Slide 113: Flexbox Axes Diagram**
```
flexDirection: 'row'
┌─────────────────────────────────────────────────────────────────┐
│  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐                  │
│  │       │  │       │  │       │  │       │                  │
│  └───────┘  └───────┘  └───────┘  └───────┘                  │
│  ←───────────────── Main Axis ─────────────────────────→        │
│                                                                 │
│  flexDirection: 'column'                                       │
│  ┌───────┐                                                    │
│  │       │                                                    │
│  └───────┘                                                    │
│  ┌───────┐                                                    │
│  │       │                                                    │
│  └───────┘                                                    │
│  ┌───────┐                                                    │
│  │       │                                                    │
│  └───────┘                                                    │
│  ↓ Main Axis                                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 114: Key Differences from Web CSS**

| Aspect | Web CSS | React Native |
|--------|---------|--------------|
| Default flexDirection | row | column |
| Auto-sizing | Content-based | Content-based |
| Percentage widths | Relative to container | Same |
| Flex basis | auto | 0 by default |
| Box model | Content-box | Border-box |

**Slide 115: flexDirection: row vs column**
```tsx
// Row layout (horizontal)
<View style={{ flexDirection: 'row' }}>
  <View style={{ flex: 1 }}>Left</View>
  <View style={{ flex: 1 }}>Right</View>
</View>

// Column layout (vertical, default)
<View style={{ flexDirection: 'column' }}>
  <View style={{ flex: 1 }}>Top</View>
  <View style={{ flex: 1 }}>Bottom</View>
</View>
```

**Slide 116: Main Axis vs Cross Axis**
- Main Axis: Direction of flex items (flexDirection)
- Cross Axis: Perpendicular to main axis
- justifyContent: Aligns along MAIN axis
- alignItems: Aligns along CROSS axis

---

### 3.2: Flexbox Properties Deep Dive (8 slides)

**Slide 117: flex: Grow, Shrink, Basis**
```tsx
// Combined property
flex: 1;    // grow, shrink, basis: auto
flex: 2;    // twice as much space
flex: 0;    // don't grow

// Individual properties
flexGrow: 1;      // Allow to grow
flexShrink: 1;    // Allow to shrink
flexBasis: 100;   // Initial size
```

**Slide 118: flex Values Explained**
- flex: 0 → Don't grow, don't shrink
- flex: 1 → Grow and shrink evenly
- flex: 2 → Grow twice as much as flex: 1
- flexGrow: 1 → Grow to fill space
- flexShrink: 1 → Shrink if needed

**Slide 119: justifyContent Values**

| Value | Effect |
|-------|--------|
| flex-start | Items at start (default) |
| flex-end | Items at end |
| center | Items centered |
| space-between | Even space between items |
| space-around | Even space around items |
| space-evenly | Even space between and around |

**Slide 120: justifyContent Examples**
```tsx
// Center items
justifyContent: 'center'

// Space between
justifyContent: 'space-between'
// [1]────[2]────[3]

// Space around
justifyContent: 'space-around'
// [1]──[2]──[3]

// Space evenly
justifyContent: 'space-evenly'
// [1]──[2]──[3]
```

**Slide 121: alignItems Values**

| Value | Effect |
|-------|--------|
| stretch | Stretch to container height (default) |
| flex-start | Items at start of cross axis |
| flex-end | Items at end of cross axis |
| center | Items centered on cross axis |

**Slide 122: flexWrap: Multi-line Layouts**
```tsx
<View style={{ 
  flexDirection: 'row', 
  flexWrap: 'wrap' 
}}>
  <View style={{ width: '30%' }}>Item 1</View>
  <View style={{ width: '30%' }}>Item 2</View>
  <View style={{ width: '30%' }}>Item 3</View>
</View>
```

**Slide 123: alignSelf: Individual Alignment**
```tsx
<View>
  <View style={{ alignSelf: 'flex-start' }}>Left</View>
  <View style={{ alignSelf: 'center' }}>Center</View>
  <View style={{ alignSelf: 'flex-end' }}>Right</View>
</View>
```

**Slide 124: Common Layout Patterns**

| Pattern | Code |
|---------|------|
| Centering | `flex: 1, justifyContent: 'center', alignItems: 'center'` |
| Two columns | `flexDirection: 'row', left: { flex: 1 }, right: { flex: 1 }` |
| Full screen | `flex: 1, width: '100%', height: '100%'` |
| Card | `borderRadius: 12, padding: 16, backgroundColor: '#fff', shadowColor: '#000', elevation: 3` |

---

### 3.3: Responsive Design Strategies (6 slides)

**Slide 125: Dimensions API**
```tsx
import { Dimensions } from 'react-native';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

// Scaling utilities
const scale = SCREEN_WIDTH / 375; // Based on iPhone SE
const responsiveSize = (size: number) => size * scale;
```

**Slide 126: Percentage-Based Sizing**
```tsx
// Full width
width: '100%'

// Half width
width: '50%'

// Full height
height: '100%'

// Dynamic sizing
width: SCREEN_WIDTH * 0.8
height: SCREEN_HEIGHT * 0.6
```

**Slide 127: Platform-Specific Design**
```tsx
import { Platform } from 'react-native';

// Using Platform.select
const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.select({
      ios: 44,
      android: 24,
    }),
  },
  text: {
    fontSize: Platform.select({
      ios: 16,
      android: 18,
      default: 16,
    }),
  },
});

// Conditional rendering
const isIOS = Platform.OS === 'ios';
const isAndroid = Platform.OS === 'android';
```

**Slide 128: Tablet vs Phone Detection**
```tsx
const isTablet = () => {
  const { width, height } = Dimensions.get('window');
  return Math.min(width, height) >= 768;
};

// Usage
if (isTablet()) {
  // Tablet layout (2 columns, larger fonts)
} else {
  // Phone layout (1 column, standard fonts)
}
```

**Slide 129: useWindowDimensions Hook**
```tsx
import { useWindowDimensions } from 'react-native';

function ResponsiveComponent() {
  const { width, height } = useWindowDimensions();
  
  // Reacts to window size changes (orientation)
  return (
    <View style={{
      width: width > 600 ? '50%' : '100%',
    }}>
      {/* Content */}
    </View>
  );
}
```

**Slide 130: Responsive Font Sizes**
```tsx
const getResponsiveFontSize = (size: number) => {
  const { width } = Dimensions.get('window');
  const scale = Math.min(width / 375, 1.5);
  return Math.round(size * scale);
};

// Usage
fontSize: getResponsiveFontSize(16)
```

---

### 3.4: The Flexbox Cheat Sheet (4 slides)

**Slide 131: Complete Flexbox Reference**
```
┌─────────────────────────────────────────────────────────────────┐
│                    FLEXBOX CHEAT SHEET                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  flexDirection: 'row'                  flexDirection: 'column' │
│  ┌─────────────────────────────┐      ┌─────────────────────┐ │
│  │ [1] [2] [3] [4] [5]        │      │  [1]                │ │
│  └─────────────────────────────┘      │  [2]                │ │
│                                        │  [3]                │ │
│                                        │  [4]                │ │
│                                        │  [5]                │ │
│                                        └─────────────────────┘ │
│                                                                 │
│  justifyContent: 'center'             justifyContent: 'space-between' │
│  ┌─────────────────────────────┐      ┌─────────────────────────────┐ │
│  │         [1] [2] [3]        │      │ [1]          [2]          [3]│ │
│  └─────────────────────────────┘      └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 132: Common Layout Mistakes**

| Mistake | Solution |
|---------|----------|
| Item not showing | Set flex: 1 or explicit height |
| Items overflowing | Add flexWrap: 'wrap' |
| Not centered | Check justifyContent/alignItems |
| Item too large | Add flexShrink: 1 |
| Fixed sizes | Use percentages or flex |

**Slide 133: Debugging Flexbox**
- React Native DevTools
- Flipper Layout Inspector
- Visible borders: `borderWidth: 1, borderColor: 'red'`
- Background colors for debugging
- `flex: 1` for debugging containers

**Slide 134: Flexbox Best Practices**
- Use `flex: 1` for full-screen containers
- Avoid fixed sizes when possible
- Use percentage for responsive width
- Use `margin: 'auto'` for centering (limited)
- Test on multiple screen sizes

---

### 3.5: Hands-On Lab: Responsive Task List (4 slides)

**Slide 135: Lab Objectives**
- Build a responsive task list with Flexbox
- Implement card layout
- Adapt to different screen sizes
- Platform-specific styling

**Slide 136: Component Structure**
```tsx
// TaskCard.tsx - Individual card with Flexbox
// ResponsiveTaskList.tsx - Grid/List switching
// Screen adapters for phone/tablet
```

**Slide 137: Key Concepts**
- Flexbox for card layout
- `numColumns` for responsive grid
- Platform-specific styling
- Dynamic sizing with Dimensions

**Slide 138: Testing Responsive Behavior**
- Run on iPhone SE (375pt)
- Run on iPhone 14 Pro (430pt)
- Run on iPad (1024pt)
- Verify layout adapts correctly

---

## Module 4: Navigation & Screen Management

### 4.1: React Navigation Architecture (5 slides)

**Slide 139: Why Navigation Matters**
- Apps are screen-based, not page-based
- User flow is hierarchical
- Navigation is primary UX pattern
- Deep linking enables external access
- Good navigation = good UX

**Slide 140: The Four Navigator Types**
- **Stack:** Drill-down navigation (Home → Detail → Edit)
- **Tab:** Primary sections (Home, Tasks, Profile)
- **Drawer:** Secondary features (Settings, Help)
- **Switch:** Authentication flow (Login ↔ Main)

**Slide 141: Installation**
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

**Slide 142: Navigation Container Setup**
```tsx
import { NavigationContainer } from '@react-navigation/native';

function App() {
  return (
    <NavigationContainer>
      {/* Navigators go here */}
    </NavigationContainer>
  );
}
```

**Slide 143: Navigation Hierarchy**
```
NavigationContainer
  └── RootNavigator
        ├── AuthStack (if not authenticated)
        │   ├── Login
        │   └── Register
        └── MainTabs (if authenticated)
              ├── HomeStack
              │   ├── Home
              │   └── Detail
              ├── TasksStack
              │   ├── Tasks
              │   └── TaskDetail
              └── Profile (Stack)
```

---

### 4.2: Stack Navigator (7 slides)

**Slide 144: Stack Navigator Flow**
```
Initial State:
┌─────────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Home Screen (Stack Top)                               │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

Navigate to Detail:
┌─────────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Detail Screen (Stack Top)                             │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  Home Screen                                           │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

Navigate to Edit:
┌─────────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Edit Screen (Stack Top)                               │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  Detail Screen                                         │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  Home Screen                                           │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 145: Stack Navigator Implementation**
```tsx
import { createNativeStackNavigator } from '@react-navigation/native-stack';

type RootStackParamList = {
  Home: undefined;
  Detail: { id: string; title: string };
  Settings: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerStyle: { backgroundColor: '#3498db' },
          headerTintColor: '#ffffff',
          headerTitleStyle: { fontWeight: 'bold' },
          headerBackTitle: 'Back',
        }}
      >
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Detail" component={DetailScreen} />
        <Stack.Screen name="Settings" component={SettingsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

**Slide 146: Navigation Functions**
```tsx
import { useNavigation } from '@react-navigation/native';

function MyComponent() {
  const navigation = useNavigation();

  // Navigate to a screen
  navigation.navigate('Detail', { id: '123', title: 'Task' });

  // Push a new screen (always creates new instance)
  navigation.push('Detail', { id: '456' });

  // Go back
  navigation.goBack();

  // Replace current screen
  navigation.replace('Home');

  // Pop to top
  navigation.popToTop();

  // Reset navigation state
  navigation.reset({
    index: 0,
    routes: [{ name: 'Home' }],
  });
}
```

**Slide 147: navigate vs push**

| Function | Behavior | When to Use |
|----------|----------|-------------|
| navigate | Goes to existing screen or creates new | Normal navigation |
| push | Always creates new screen instance | Duplicate screens |
| goBack | Returns to previous screen | User wants to go back |
| replace | Replaces current screen | Login → Main |

**Slide 148: Passing Parameters**
```tsx
// Navigate with params
navigation.navigate('Detail', { id: '123', title: 'Task' });

// Type-safe params
type RootStackParamList = {
  Detail: { id: string; title: string };
};

// Getting params in screen
const route = useRoute<RouteProp<RootStackParamList, 'Detail'>>();
const { id, title } = route.params;
```

**Slide 149: Custom Headers**
```tsx
<Stack.Screen
  name="Detail"
  component={DetailScreen}
  options={{
    title: 'Task Details',
    headerRight: () => (
      <TouchableOpacity onPress={handleEdit}>
        <Text style={{ color: '#fff' }}>Edit</Text>
      </TouchableOpacity>
    ),
  }}
/>
```

**Slide 150: Screen Options**
```tsx
// Static options
<Stack.Screen
  name="Home"
  component={HomeScreen}
  options={{ title: 'Home' }}
/>

// Dynamic options
<Stack.Screen
  name="Detail"
  component={DetailScreen}
  options={({ route }) => ({
    title: route.params.title,
  })}
/>

// Navigation options
navigation.setOptions({
  title: 'New Title',
  headerRight: () => <Button title="Save" />,
});
```

---

### 4.3: Tab Navigator (6 slides)

**Slide 151: Tab Navigation Overview**
- Bottom tabs for primary sections
- Easy switching between screens
- Persistent navigation
- Badge indicators for notifications
- Custom icon and label

**Slide 152: Tab Navigator Implementation**
```tsx
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MaterialIcons } from '@expo/vector-icons';

type TabParamList = {
  Home: undefined;
  Tasks: undefined;
  Profile: undefined;
};

const Tab = createBottomTabNavigator<TabParamList>();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: keyof typeof MaterialIcons.glyphMap;
          switch (route.name) {
            case 'Home': iconName = focused ? 'home' : 'home-outlined'; break;
            case 'Tasks': iconName = focused ? 'assignment' : 'assignment-outlined'; break;
            case 'Profile': iconName = focused ? 'person' : 'person-outline'; break;
            default: iconName = 'help';
          }
          return <MaterialIcons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#3498db',
        tabBarInactiveTintColor: '#95a5a6',
        tabBarStyle: { paddingBottom: 8, paddingTop: 8, height: 64 },
        headerShown: false,
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Tasks" component={TasksScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}
```

**Slide 153: Tab Badge Indicators**
```tsx
<Tab.Screen
  name="Tasks"
  component={TasksScreen}
  options={{
    tabBarBadge: 3, // Static badge
    // OR dynamic badge
    tabBarBadge: unreadCount > 0 ? unreadCount : undefined,
  }}
/>
```

**Slide 154: Custom Tab Bar Styling**
```tsx
<Tab.Navigator
  screenOptions={{
    tabBarStyle: {
      position: 'absolute',
      bottom: 20,
      left: 20,
      right: 20,
      borderRadius: 20,
      height: 70,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 10 },
      shadowOpacity: 0.1,
      shadowRadius: 10,
      elevation: 10,
      backgroundColor: '#ffffff',
    },
    tabBarShowLabel: false,
  }}
>
  {/* Tabs */}
</Tab.Navigator>
```

**Slide 155: Floating Action Button in Tabs**
```tsx
<Tab.Screen
  name="Add"
  component={DummyScreen}
  options={{
    tabBarButton: (props) => (
      <TouchableOpacity
        style={{
          top: -20,
          width: 60,
          height: 60,
          borderRadius: 30,
          backgroundColor: '#3498db',
          alignItems: 'center',
          justifyContent: 'center',
          shadowColor: '#3498db',
          shadowOffset: { width: 0, height: 4 },
          shadowOpacity: 0.3,
          shadowRadius: 8,
          elevation: 8,
        }}
        onPress={() => console.log('Add pressed')}
      >
        <Text style={{ fontSize: 30, color: '#fff' }}>+</Text>
      </TouchableOpacity>
    ),
  }}
/>
```

**Slide 156: Tab Navigator Best Practices**
- 5 tabs maximum (more = poor UX)
- Clear icons and labels
- Active state distinction
- Badge for notifications
- Customizable styling

---

### 4.4: Drawer Navigator (5 slides)

**Slide 157: Drawer Navigation Overview**
- Side menu for secondary features
- Swipe to open/close
- Custom drawer content
- User profile integration
- Settings, help, logout

**Slide 158: Drawer Navigator Implementation**
```tsx
import { createDrawerNavigator } from '@react-navigation/drawer';

const Drawer = createDrawerNavigator();

function App() {
  return (
    <NavigationContainer>
      <Drawer.Navigator
        screenOptions={{
          drawerStyle: { width: 280 },
          drawerActiveTintColor: '#3498db',
          drawerInactiveTintColor: '#2c3e50',
          drawerLabelStyle: { fontSize: 16, fontWeight: '500' },
          headerShown: true,
        }}
        drawerContent={(props) => <CustomDrawerContent {...props} />}
      >
        <Drawer.Screen
          name="Home"
          component={MainTabs}
          options={{
            drawerLabel: 'Home',
            drawerIcon: ({ color }) => (
              <MaterialIcons name="home" size={24} color={color} />
            ),
          }}
        />
        <Drawer.Screen
          name="Settings"
          component={SettingsScreen}
          options={{
            drawerLabel: 'Settings',
            drawerIcon: ({ color }) => (
              <MaterialIcons name="settings" size={24} color={color} />
            ),
          }}
        />
      </Drawer.Navigator>
    </NavigationContainer>
  );
}
```

**Slide 159: Custom Drawer Content**
```tsx
function CustomDrawerContent({ navigation }) {
  const { user, logout } = useAuthStore();

  return (
    <View style={{ flex: 1, paddingTop: 40 }}>
      <View style={styles.userProfile}>
        <Image source={{ uri: user?.avatar }} style={styles.avatar} />
        <Text style={styles.userName}>{user?.name || 'Guest'}</Text>
        <Text style={styles.userEmail}>{user?.email}</Text>
      </View>

      <View style={styles.menuItems}>
        <DrawerItem
          icon={({ color }) => <MaterialIcons name="home" size={24} color={color} />}
          label="Home"
          onPress={() => navigation.navigate('Home')}
        />
        <DrawerItem
          icon={({ color }) => <MaterialIcons name="settings" size={24} color={color} />}
          label="Settings"
          onPress={() => navigation.navigate('Settings')}
        />
        <DrawerItem
          icon={({ color }) => <MaterialIcons name="logout" size={24} color={color} />}
          label="Logout"
          onPress={logout}
        />
      </View>

      <View style={styles.footer}>
        <Text style={styles.version}>Version 1.0.0</Text>
      </View>
    </View>
  );
}
```

**Slide 160: Drawer Navigation Functions**
```tsx
// Open drawer
navigation.openDrawer();

// Close drawer
navigation.closeDrawer();

// Toggle drawer
navigation.toggleDrawer();
```

**Slide 161: Drawer Best Practices**
- Keep menu items limited (5-8)
- Include user profile at top
- Group related items
- Use icons for visual recognition
- Consistent with platform conventions

---

### 4.5: Advanced Navigation Patterns (7 slides)

**Slide 162: Deep Linking Setup**
```tsx
// app.json
{
  "expo": {
    "scheme": "taskflow"
  }
}

// Linking configuration
const linking = {
  prefixes: ['taskflow://', 'https://taskflow.app'],
  config: {
    screens: {
      Home: 'home',
      Detail: 'tasks/:id',
      Settings: 'settings',
    },
  },
};

function App() {
  return (
    <NavigationContainer linking={linking}>
      {/* Navigators */}
    </NavigationContainer>
  );
}
```

**Slide 163: Deep Linking URL Formats**
```
// App scheme
taskflow://tasks/123
taskflow://settings

// Web URL
https://taskflow.app/tasks/123
https://taskflow.app/settings

// Query parameters
https://taskflow.app/tasks/123?mode=edit&source=notification
```

**Slide 164: Navigation State Persistence**
```tsx
import AsyncStorage from '@react-native-async-storage/async-storage';

const NAVIGATION_STATE_KEY = '@navigation-state';

async function saveNavigationState(state) {
  try {
    await AsyncStorage.setItem(NAVIGATION_STATE_KEY, JSON.stringify(state));
  } catch (error) {
    console.error('Error saving navigation state:', error);
  }
}

async function loadNavigationState() {
  try {
    const state = await AsyncStorage.getItem(NAVIGATION_STATE_KEY);
    return state ? JSON.parse(state) : undefined;
  } catch (error) {
    console.error('Error loading navigation state:', error);
    return undefined;
  }
}

function App() {
  const [initialState, setInitialState] = useState();

  useEffect(() => {
    loadNavigationState().then(setInitialState);
  }, []);

  return (
    <NavigationContainer
      initialState={initialState}
      onStateChange={saveNavigationState}
    >
      {/* Navigators */}
    </NavigationContainer>
  );
}
```

**Slide 165: Authentication Flow Guards**
```tsx
// AuthGuard.tsx
function AuthGuard({ children }) {
  const { isAuthenticated, isLoading } = useAuthStore();
  const navigation = useNavigation();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      navigation.navigate('Login');
    }
  }, [isAuthenticated, isLoading]);

  if (isLoading) {
    return <LoadingScreen />;
  }

  return isAuthenticated ? <>{children}</> : null;
}

// Usage
<AuthGuard>
  <MainNavigator />
</AuthGuard>
```

**Slide 166: Navigation Service for External Calls**
```tsx
// NavigationService.ts
import { NavigationContainerRef } from '@react-navigation/native';

class NavigationService {
  private navigatorRef: NavigationContainerRef | null = null;

  setTopLevelNavigator = (ref: NavigationContainerRef | null) => {
    this.navigatorRef = ref;
  };

  navigate = (routeName: string, params?: any) => {
    if (this.navigatorRef?.isReady()) {
      this.navigatorRef.navigate(routeName, params);
    }
  };

  goBack = () => {
    if (this.navigatorRef?.canGoBack()) {
      this.navigatorRef.goBack();
    }
  };
}

export const navigationService = new NavigationService();
```

**Slide 167: Handling Android Back Button**
```tsx
import { BackHandler } from 'react-native';

useEffect(() => {
  const backHandler = BackHandler.addEventListener('hardwareBackPress', () => {
    if (navigation.canGoBack()) {
      navigation.goBack();
      return true;
    }
    return false;
  });

  return () => backHandler.remove();
}, [navigation]);
```

**Slide 168: Navigation Best Practices**
- Keep navigation tree shallow
- Use TypeScript for type safety
- Implement deep linking
- Persist navigation state
- Use navigation guards
- Test navigation flows

---

### 4.6: Hands-On Lab: Complete TaskFlow Navigation (4 slides)

**Slide 169: Lab Objectives**
- Implement Stack for task detail
- Implement Tab for main sections
- Implement Drawer for settings
- Authentication navigation flow
- Add deep linking

**Slide 170: Step-by-Step Instructions**
1. Create AuthStack with Login, Register, ForgotPassword
2. Create MainTabs with Home, Tasks, Profile
3. Create MainStack with MainTabs and Detail screens
4. Create DrawerNavigator with settings
5. Create RootNavigator with authentication flow
6. Implement deep linking

**Slide 171: Navigation Flow Diagram**
```
┌─────────────────────────────────────────────────────────────────┐
│                    NAVIGATION FLOW                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Not Authenticated:                                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐   │
│  │   Login     │───▶│  Register   │───▶│  ForgotPassword │   │
│  └─────────────┘    └─────────────┘    └─────────────────┘   │
│                                                                 │
│  Authenticated:                                                │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    MainTabs                            │    │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐ │    │
│  │  │  Home      │  │  Tasks     │  │  Profile         │ │    │
│  │  └────────────┘  └────────────┘  └──────────────────┘ │    │
│  │       │              │                                 │    │
│  │       ▼              ▼                                 │    │
│  │  ┌────────────┐  ┌────────────┐                       │    │
│  │  │  Detail    │  │  TaskDetail│                       │    │
│  │  └────────────┘  └────────────┘                       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Drawer                              │    │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐ │    │
│  │  │  Settings  │  │   Help     │  │  Logout          │ │    │
│  │  └────────────┘  └────────────┘  └──────────────────┘ │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 172: Testing Navigation**
- Test all navigation flows
- Verify deep linking
- Test authentication flow
- Test back button behavior

---

# PART 2: STATE MANAGEMENT & LOCAL PERSISTENCE

---

## Module 5: Local State & Component Lifecycle

### 5.1: The Three Types of State (6 slides)

**Slide 173: Local State**
- Lives in a single component
- useState, useReducer
- Example: "Is this modal open?"
- Example: "What's the current text input value?"
- Duration: Component lifecycle
- Scope: Single component

**Slide 174: Global State**
- Lives across the entire app
- Zustand, Redux, Context
- Example: "Who is the current user?"
- Example: "What tasks exist?"
- Duration: App lifecycle
- Scope: Entire app

**Slide 175: Persisted State**
- Lives between app sessions
- AsyncStorage, MMKV, SQLite
- Example: "User preferences"
- Example: "Tasks created offline"
- Duration: Device storage
- Scope: Long-term storage

**Slide 176: Choosing the Right State Type**

| Scenario | Best Practice |
|----------|---------------|
| Form input | useState (local) |
| Theme preference | Zustand + persist (global + persisted) |
| Current user | Zustand + persist (global + persisted) |
| Modal visibility | useState or Zustand (local/global) |
| Task list | Zustand + persist (global + persisted) |
| API response | useState (local) |

**Slide 177: State Flow in TaskFlow**
```
┌─────────────────────────────────────────────────────────────────┐
│                    STATE FLOW IN TASKFLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User interacts with UI                                     │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Tap "Create Task" button                          │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  2. Local state updates                                        │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  formData changes, validation runs                 │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  3. Action dispatched to global store                         │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  useTaskStore.getState().addTask(newTask)         │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  4. Optimistic update                                         │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Task appears in list immediately                 │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  5. Persist locally                                            │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Task saved to SQLite for offline access            │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  6. Sync to server                                             │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Task sent to API in background                    │    │
│     └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 178: State Anti-Patterns**
- ❌ Using global state for everything
- ❌ Not persisting important data
- ❌ Mutating state directly
- ❌ Overusing useState in complex components
- ❌ Not cleaning up effects

---

### 5.2: useState Deep Dive (6 slides)

**Slide 179: useState Basics**
```tsx
import { useState } from 'react';

// Simple state
const [count, setCount] = useState(0);

// Update state
setCount(count + 1);
setCount(prev => prev + 1); // Functional update (safer)

// Initial value from prop
const [value, setValue] = useState(props.initialValue);

// Lazy initialization (expensive computation)
const [data, setData] = useState(() => expensiveComputation());
```

**Slide 180: State with Objects and Arrays**
```tsx
// Object state
const [user, setUser] = useState({ name: '', age: 0 });

// Updating object (immutable)
setUser(prev => ({ ...prev, name: 'John' }));

// Array state
const [items, setItems] = useState<string[]>([]);

// Adding to array
setItems(prev => [...prev, 'new item']);

// Removing from array
setItems(prev => prev.filter(item => item !== 'remove'));

// Updating array item
setItems(prev => prev.map(item => 
  item.id === targetId ? { ...item, updated: true } : item
));
```

**Slide 181: Async State Updates**
```tsx
// ❌ Bad: Multiple state updates
const handleSubmit = () => {
  setLoading(true);
  setError(null);
  setData(null);

  fetchData().then(data => {
    setLoading(false);
    setData(data);
  });
};

// ✅ Good: Single state object
const [state, setState] = useState({
  loading: false,
  error: null,
  data: null,
});

const handleSubmit = () => {
  setState({ loading: true, error: null, data: null });
  
  fetchData().then(data => {
    setState({ loading: false, error: null, data });
  });
};
```

**Slide 182: State Updates are Asynchronous**
```tsx
// ❌ Bad: Expecting immediate update
setCount(count + 1);
console.log(count); // Still old value

// ✅ Good: Using functional update
setCount(prev => {
  console.log('New count:', prev + 1);
  return prev + 1;
});
```

**Slide 183: Common useState Pitfalls**

| Pitfall | Solution |
|---------|----------|
| Stale closures | Use functional updates |
| Setting after unmount | Use isMounted flag |
| Mutating state | Use immutable updates |
| Too many useState calls | Group into object |
| Unnecessary state | Use computed values |

**Slide 184: When to Use useReducer**
```tsx
const initialState = { count: 0 };

function reducer(state, action) {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    default:
      return state;
  }
}

const [state, dispatch] = useReducer(reducer, initialState);

// Usage
dispatch({ type: 'increment' });
```

---

### 5.3: useEffect Fundamentals (6 slides)

**Slide 185: The Effect Lifecycle**
```
┌─────────────────────────────────────────────────────────────────┐
│                    useEffect LIFECYCLE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Mount                                                      │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Component renders                                 │    │
│     │  useEffect runs after render                      │    │
│     │  Optional: cleanup function returned              │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  2. Update                                                     │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Component re-renders                              │    │
│     │  Dependencies changed?                            │    │
│     │  ├─ Yes: Run effect (cleanup first)              │    │
│     │  └─ No: Skip effect                              │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  3. Unmount                                                    │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Component unmounts                               │    │
│     │  Run cleanup function                             │    │
│     └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 186: Dependency Arrays Explained**
```tsx
// Runs once on mount
useEffect(() => {
  fetchData();
}, []);

// Runs whenever count changes
useEffect(() => {
  console.log('Count changed:', count);
}, [count]);

// Runs on every render (avoid!)
useEffect(() => {
  console.log('Rendered');
});

// Runs on mount and when multiple deps change
useEffect(() => {
  fetchUserData(userId);
}, [userId, isAuthenticated]);
```

**Slide 187: Cleanup Functions**
```tsx
// Timer cleanup
useEffect(() => {
  const interval = setInterval(() => {
    setTime(Date.now());
  }, 1000);
  
  return () => clearInterval(interval);
}, []);

// Subscription cleanup
useEffect(() => {
  const subscription = eventEmitter.addListener('event', handler);
  
  return () => subscription.remove();
}, []);

// Abort controller cleanup
useEffect(() => {
  const controller = new AbortController();
  
  fetch(url, { signal: controller.signal })
    .then(res => res.json())
    .then(setData)
    .catch(err => {
      if (err.name !== 'AbortError') {
        setError(err);
      }
    });
  
  return () => controller.abort();
}, []);
```

**Slide 188: Common Effect Patterns**
```tsx
// Fetching data
useEffect(() => {
  const fetchData = async () => {
    setLoading(true);
    try {
      const result = await api.getData();
      setData(result);
    } catch (error) {
      setError(error);
    } finally {
      setLoading(false);
    }
  };
  
  fetchData();
}, []);

// Debounced search
useEffect(() => {
  const timeoutId = setTimeout(() => {
    handleSearch(searchTerm);
  }, 300);
  
  return () => clearTimeout(timeoutId);
}, [searchTerm]);

// Event listeners
useEffect(() => {
  const handleResize = () => {
    setDimensions({ width: window.innerWidth });
  };
  
  window.addEventListener('resize', handleResize);
  return () => window.removeEventListener('resize', handleResize);
}, []);
```

**Slide 189: useEffect Dependencies Rules**
1. Include all values used inside the effect
2. Don't include setState functions (stable)
3. Don't include dispatch functions (stable)
4. Include props and state
5. Include context values
6. Include refs (use useRef for mutable values)

**Slide 190: useEffect Best Practices**
- Extract complex logic into custom hooks
- Clean up all subscriptions and listeners
- Use `useCallback` for event handlers
- Use `useMemo` for computed values
- Keep effects focused and simple

---

### 5.4: useMemo & useCallback (5 slides)

**Slide 191: useMemo - Memoizing Values**
```tsx
// ❌ Bad: Recomputes on every render
const expensiveValue = expensiveComputation(data);

// ✅ Good: Only recomputes when data changes
const expensiveValue = useMemo(() => {
  return expensiveComputation(data);
}, [data]);

// With dependencies
const filteredTasks = useMemo(() => {
  return tasks.filter(task => 
    task.title.toLowerCase().includes(searchTerm.toLowerCase())
  );
}, [tasks, searchTerm]);
```

**Slide 192: Complex Computation with useMemo**
```tsx
const statistics = useMemo(() => {
  const total = tasks.length;
  const completed = tasks.filter(t => t.status === 'done').length;
  const highPriority = tasks.filter(t => t.priority === 'high').length;
  
  return {
    total,
    completed,
    highPriority,
    completionRate: total > 0 ? completed / total : 0,
  };
}, [tasks]);
```

**Slide 193: useCallback - Memoizing Functions**
```tsx
// ❌ Bad: New function on every render
const handlePress = () => {
  doSomething(id);
};

// ✅ Good: Same function if dependencies unchanged
const handlePress = useCallback(() => {
  doSomething(id);
}, [id]);

// With dependencies
const handleSearch = useCallback((query: string) => {
  setSearchTerm(query);
  setFilteredItems(filterItems(items, query));
}, [items]);
```

**Slide 194: When to Use Each Hook**

| Hook | Use Case |
|------|----------|
| useMemo | Expensive calculations, derived data |
| useCallback | Functions passed to child components |
| React.memo | Components with expensive renders |
| useRef | Mutable values that don't cause re-renders |

**Slide 195: Common Pitfalls**
```tsx
// Pitfall 1: Unnecessary memoization
const value = useMemo(() => 42, []); // ✅ Unnecessary

// Pitfall 2: Missing dependencies
const handlePress = useCallback(() => {
  setCount(count + 1); // ❌ count is stale
}, []); // ✅ Fix: add count to deps

// Pitfall 3: Creating new objects
const handlePress = useCallback(() => {
  doSomething({ data: 'value' }); // ❌ New object each time
}, []); // ✅ Fix: memoize the object

const options = useMemo(() => ({ data: 'value' }), []);
```

---

### 5.5: Custom Hooks (5 slides)

**Slide 196: Custom Hooks Overview**
- Extract reusable logic
- Share stateful logic across components
- Build abstractions
- Clean up component code
- Test hooks independently

**Slide 197: useDebounce - Input Delay**
```tsx
function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// Usage
const [searchTerm, setSearchTerm] = useState('');
const debouncedSearch = useDebounce(searchTerm, 300);

useEffect(() => {
  if (debouncedSearch) {
    searchTasks(debouncedSearch);
  }
}, [debouncedSearch]);
```

**Slide 198: useApi - API Call Management**
```tsx
function useApi<T, P = void>(
  apiFunction: (params: P) => Promise<T>
) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const execute = useCallback(
    async (params: P) => {
      setLoading(true);
      setError(null);
      
      try {
        const result = await apiFunction(params);
        setData(result);
        return result;
      } catch (error) {
        const err = error instanceof Error ? error : new Error('Unknown error');
        setError(err);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [apiFunction]
  );

  return { data, loading, error, execute };
}

// Usage
const { data, loading, error, execute } = useApi(api.getTasks);
useEffect(() => {
  execute();
}, []);
```

**Slide 199: useKeyboard - Keyboard Handling**
```tsx
function useKeyboard() {
  const [keyboardVisible, setKeyboardVisible] = useState(false);
  const [keyboardHeight, setKeyboardHeight] = useState(0);

  useEffect(() => {
    const showListener = Keyboard.addListener(
      Platform.OS === 'ios' ? 'keyboardWillShow' : 'keyboardDidShow',
      (e: KeyboardEvent) => {
        setKeyboardVisible(true);
        setKeyboardHeight(e.endCoordinates.height);
      }
    );

    const hideListener = Keyboard.addListener(
      Platform.OS === 'ios' ? 'keyboardWillHide' : 'keyboardDidHide',
      () => {
        setKeyboardVisible(false);
        setKeyboardHeight(0);
      }
    );

    return () => {
      showListener.remove();
      hideListener.remove();
    };
  }, []);

  return { keyboardVisible, keyboardHeight };
}
```

**Slide 200: useAsyncStorage - Storage Management**
```tsx
function useAsyncStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(initialValue);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const stored = await AsyncStorage.getItem(key);
        if (stored !== null) {
          setValue(JSON.parse(stored));
        }
      } catch (error) {
        console.error('Error loading:', error);
      } finally {
        setLoading(false);
      }
    };
    
    load();
  }, [key]);

  const setStoredValue = async (newValue: T) => {
    try {
      await AsyncStorage.setItem(key, JSON.stringify(newValue));
      setValue(newValue);
    } catch (error) {
      console.error('Error saving:', error);
    }
  };

  return { value, setValue: setStoredValue, loading };
}
```

---

## Module 6: Global State Management with Zustand

### 6.1: Why Zustand Over Redux? (5 slides)

**Slide 201: Comparison Overview**

| Feature | Zustand | Redux | Context |
|---------|---------|-------|---------|
| Boilerplate | Minimal | Heavy | Moderate |
| Learning Curve | Low | Steep | Low |
| Performance | Excellent | Good | Good (with memo) |
| DevTools | Yes | Excellent | Limited |
| Middleware | Yes | Extensive | Limited |
| TypeScript | Excellent | Good | Good |
| Bundle Size | ~3KB | ~15KB | ~2KB |
| Provider Required | No | Yes | Yes |

**Slide 202: Redux Example (40+ lines)**
```tsx
// Redux
const initialState = { count: 0 };
const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'INCREMENT':
      return { count: state.count + 1 };
    default:
      return state;
  }
};
const store = createStore(reducer);
const Provider = ({ children }) => (
  <ReduxProvider store={store}>
    {children}
  </ReduxProvider>
);
const mapState = (state) => ({ count: state.count });
const mapDispatch = { increment: () => ({ type: 'INCREMENT' }) };
export default connect(mapState, mapDispatch)(Component);
```

**Slide 203: Zustand Example (5 lines)**
```tsx
// Zustand
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));
const { count, increment } = useStore();
```

**Slide 204: Benefits of Zustand**
- ✅ Minimal boilerplate - 80% less code
- ✅ No providers - Just import and use
- ✅ Excellent TypeScript - Full type inference
- ✅ Small bundle size - ~3KB minified
- ✅ Simple API - Easy to learn and use
- ✅ Flexible - Works with any state shape

**Slide 205: When to Use Zustand**
- New projects
- Simple to complex state needs
- TypeScript projects
- Performance-critical apps
- When you want minimal boilerplate

---

### 6.2: Creating Zustand Stores (6 slides)

**Slide 206: Core Store Pattern**
```tsx
import { create } from 'zustand';

// Define interface
interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  incrementBy: (value: number) => void;
}

// Create store
const useCounterStore = create<CounterState>((set, get) => ({
  // Initial state
  count: 0,

  // Actions
  increment: () => set((state) => ({ count: state.count + 1 })),
  
  decrement: () => set((state) => ({ count: state.count - 1 })),
  
  reset: () => set({ count: 0 }),
  
  incrementBy: (value: number) => 
    set((state) => ({ count: state.count + value })),
}));
```

**Slide 207: Usage in Component**
```tsx
function Counter() {
  const { count, increment, decrement } = useCounterStore();
  return (
    <View>
      <Text>{count}</Text>
      <Button title="+" onPress={increment} />
      <Button title="-" onPress={decrement} />
    </View>
  );
}
```

**Slide 208: Store with Persistence**
```tsx
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      
      login: async (email, password) => {
        const { user, token } = await api.login(email, password);
        set({ user, token, isAuthenticated: true });
      },
      
      logout: () => {
        set({ user: null, token: null, isAuthenticated: false });
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

**Slide 209: Async Actions**
```tsx
const useTaskStore = create<TaskState>((set, get) => ({
  tasks: [],
  isLoading: false,
  error: null,

  fetchTasks: async () => {
    set({ isLoading: true, error: null });
    
    try {
      const tasks = await api.getTasks();
      set({ tasks, isLoading: false });
    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Failed to fetch tasks',
        isLoading: false 
      });
    }
  },

  addTask: async (taskData) => {
    try {
      const newTask = await api.createTask(taskData);
      set((state) => ({ tasks: [newTask, ...state.tasks] }));
    } catch (error) {
      set({ error: error.message });
      throw error;
    }
  },
}));
```

**Slide 210: get and set Functions**
```tsx
const useStore = create((set, get) => ({
  count: 0,
  
  // Using set to update state
  increment: () => set((state) => ({ count: state.count + 1 })),
  
  // Using get to read state
  getCount: () => {
    const state = get();
    return state.count;
  },
  
  // Using both
  doubleAndLog: () => {
    const state = get();
    const newCount = state.count * 2;
    set({ count: newCount });
    console.log('New count:', newCount);
  },
}));
```

**Slide 211: Type-Safe Store Creation**
```tsx
interface TodoState {
  todos: string[];
  addTodo: (todo: string) => void;
  removeTodo: (index: number) => void;
}

// Full type safety
const useTodoStore = create<TodoState>()((set) => ({
  todos: [],
  addTodo: (todo) => set((state) => ({ todos: [...state.todos, todo] })),
  removeTodo: (index) => set((state) => ({
    todos: state.todos.filter((_, i) => i !== index)
  })),
}));

// Usage with type safety
const todos = useTodoStore((state) => state.todos);
const addTodo = useTodoStore((state) => state.addTodo);
```

---

### 6.3: Store Patterns (5 slides)

**Slide 212: Auth Store Pattern**
```tsx
interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  
  login: (email: string, password: string) => Promise<void>;
  register: (name: string, email: string, password: string) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
  clearError: () => void;
}

const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (email, password) => {
        set({ isLoading: true, error: null });
        try {
          const { user, token } = await api.login(email, password);
          set({ user, token, isAuthenticated: true, isLoading: false });
        } catch (error) {
          set({ error: error.message, isLoading: false });
          throw error;
        }
      },

      logout: () => {
        set({ user: null, token: null, isAuthenticated: false });
      },

      checkAuth: async () => {
        const { token } = get();
        if (!token) {
          set({ isAuthenticated: false });
          return;
        }
        
        try {
          const user = await api.validateToken(token);
          set({ user, isAuthenticated: true });
        } catch {
          set({ user: null, token: null, isAuthenticated: false });
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**Slide 213: Task Store Pattern**
```tsx
interface TaskState {
  tasks: Task[];
  selectedTask: Task | null;
  filters: TaskFilters;
  isLoading: boolean;
  error: string | null;
  
  fetchTasks: () => Promise<void>;
  createTask: (data: CreateTaskData) => Promise<void>;
  updateTask: (id: string, data: UpdateTaskData) => Promise<void>;
  deleteTask: (id: string) => Promise<void>;
  selectTask: (task: Task | null) => void;
  setFilters: (filters: Partial<TaskFilters>) => void;
  getFilteredTasks: () => Task[];
}

const useTaskStore = create<TaskState>((set, get) => ({
  tasks: [],
  selectedTask: null,
  filters: { search: '', status: undefined },
  isLoading: false,
  error: null,

  fetchTasks: async () => {
    set({ isLoading: true });
    try {
      const tasks = await api.getTasks();
      set({ tasks, isLoading: false });
    } catch (error) {
      set({ error: error.message, isLoading: false });
    }
  },

  getFilteredTasks: () => {
    const { tasks, filters } = get();
    let filtered = [...tasks];
    
    if (filters.search) {
      const search = filters.search.toLowerCase();
      filtered = filtered.filter(t => 
        t.title.toLowerCase().includes(search)
      );
    }
    
    if (filters.status) {
      filtered = filtered.filter(t => t.status === filters.status);
    }
    
    return filtered;
  },
}));
```

**Slide 214: UI Store Pattern**
```tsx
interface UIState {
  theme: 'light' | 'dark' | 'system';
  modal: { visible: boolean; type: string; data: any };
  toasts: Toast[];
  isLoading: boolean;
  isOnline: boolean;
  
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
  showModal: (type: string, data?: any) => void;
  hideModal: () => void;
  showToast: (message: string, type: 'success' | 'error' | 'info') => void;
  hideToast: (id: string) => void;
  setLoading: (loading: boolean) => void;
  setOnlineStatus: (online: boolean) => void;
}

const useUIStore = create<UIState>((set) => ({
  theme: 'system',
  modal: { visible: false, type: '', data: null },
  toasts: [],
  isLoading: false,
  isOnline: true,

  showToast: (message, type) => {
    const id = `toast-${Date.now()}`;
    set((state) => ({
      toasts: [...state.toasts, { id, message, type }]
    }));
    setTimeout(() => {
      set((state) => ({
        toasts: state.toasts.filter(t => t.id !== id)
      }));
    }, 3000);
  },
}));
```

**Slide 215: Settings Store Pattern**
```tsx
interface SettingsState {
  notifications: boolean;
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  defaultView: 'list' | 'grid';
  sorting: 'dueDate' | 'priority' | 'createdAt';
  fontSize: 'small' | 'medium' | 'large';
  
  updateSettings: (settings: Partial<SettingsState>) => void;
  resetSettings: () => void;
}

const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      notifications: true,
      soundEnabled: true,
      vibrationEnabled: true,
      defaultView: 'list',
      sorting: 'dueDate',
      fontSize: 'medium',

      updateSettings: (settings) => {
        set((state) => ({ ...state, ...settings }));
      },

      resetSettings: () => {
        set({
          notifications: true,
          soundEnabled: true,
          vibrationEnabled: true,
          defaultView: 'list',
          sorting: 'dueDate',
          fontSize: 'medium',
        });
      },
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

---

### 6.4: Store Best Practices (5 slides)

**Slide 216: Keep Stores Focused**
```tsx
// ❌ Bad - One giant store
const useAppStore = create((set) => ({
  user: null,
  tasks: [],
  settings: {},
  notifications: [],
  // ... everything else
}));

// ✅ Good - Separate stores by domain
const useAuthStore = create((set) => ({ user: null, token: null }));
const useTaskStore = create((set) => ({ tasks: [] }));
const useSettingsStore = create((set) => ({ settings: {} }));
const useNotificationStore = create((set) => ({ notifications: [] }));
```

**Slide 217: Use Selectors for Performance**
```tsx
// ❌ Bad - Re-renders on any state change
const { user, tasks, settings } = useAppStore();

// ✅ Good - Only re-renders when selected state changes
const user = useAuthStore(state => state.user);
const tasks = useTaskStore(state => state.tasks);
const settings = useSettingsStore(state => state.settings);

// Derived selectors
const completedTasks = useTaskStore(
  state => state.tasks.filter(t => t.status === 'done')
);

const taskCount = useTaskStore(
  state => ({
    total: state.tasks.length,
    completed: state.tasks.filter(t => t.status === 'done').length,
  })
);
```

**Slide 218: Prefer Multiple Small Actions**
```tsx
// ❌ Bad - One large action
updateEverything: (updates) => {
  set((state) => ({
    user: updates.user || state.user,
    tasks: updates.tasks || state.tasks,
    settings: updates.settings || state.settings,
  }));
}

// ✅ Good - Specific, focused actions
updateUser: (user) => set({ user }),
updateTasks: (tasks) => set({ tasks }),
updateSettings: (settings) => set({ settings }),
```

**Slide 219: Handle Errors Gracefully**
```tsx
const useStore = create((set) => ({
  data: null,
  error: null,
  isLoading: false,

  fetchData: async () => {
    set({ isLoading: true, error: null });
    try {
      const data = await api.fetchData();
      set({ data, isLoading: false });
    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Unknown error',
        isLoading: false 
      });
    }
  },
}));
```

**Slide 220: Reset State on Logout**
```tsx
const useRootStore = create((set) => ({
  resetAll: () => {
    useAuthStore.setState({
      user: null,
      token: null,
      isAuthenticated: false,
    });
    
    useTaskStore.setState({
      tasks: [],
      selectedTask: null,
    });
    
    useUIStore.setState({
      modal: { visible: false, type: '', data: null },
      toasts: [],
    });
  },
}));
```

---

### 6.5: Hands-On Lab: TaskFlow Stores (4 slides)

**Slide 221: Lab Objectives**
- Create authStore with login/logout
- Create taskStore with CRUD
- Create uiStore for modals
- Integrate stores in components
- Implement persistence

**Slide 222: Auth Store Implementation**
```tsx
// src/stores/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  register: (name: string, email: string, password: string) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (email, password) => {
        set({ isLoading: true, error: null });
        try {
          // Mock API call
          const response = await mockLogin(email, password);
          set({
            user: response.user,
            token: response.token,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          set({ error: error.message, isLoading: false });
        }
      },

      logout: () => {
        set({ user: null, token: null, isAuthenticated: false });
      },

      checkAuth: async () => {
        const { token } = useAuthStore.getState();
        if (token) {
          set({ isAuthenticated: true });
        } else {
          set({ isAuthenticated: false });
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**Slide 223: Task Store Implementation**
```tsx
// src/stores/taskStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface TaskState {
  tasks: Task[];
  selectedTask: Task | null;
  filters: TaskFilters;
  isLoading: boolean;
  error: string | null;
  fetchTasks: () => Promise<void>;
  createTask: (data: CreateTaskData) => Promise<Task>;
  updateTask: (id: string, data: UpdateTaskData) => Promise<Task>;
  deleteTask: (id: string) => Promise<void>;
  selectTask: (task: Task | null) => void;
  setFilters: (filters: Partial<TaskFilters>) => void;
  getFilteredTasks: () => Task[];
}

export const useTaskStore = create<TaskState>()(
  persist(
    (set, get) => ({
      tasks: [],
      selectedTask: null,
      filters: { search: '', status: undefined },
      isLoading: false,
      error: null,

      fetchTasks: async () => {
        set({ isLoading: true });
        try {
          const tasks = await api.getTasks();
          set({ tasks, isLoading: false });
        } catch (error) {
          set({ error: error.message, isLoading: false });
        }
      },

      createTask: async (data) => {
        try {
          const task = await api.createTask(data);
          set((state) => ({ tasks: [task, ...state.tasks] }));
          return task;
        } catch (error) {
          set({ error: error.message });
          throw error;
        }
      },

      getFilteredTasks: () => {
        const { tasks, filters } = get();
        let filtered = [...tasks];
        if (filters.search) {
          const search = filters.search.toLowerCase();
          filtered = filtered.filter(t => 
            t.title.toLowerCase().includes(search)
          );
        }
        if (filters.status) {
          filtered = filtered.filter(t => t.status === filters.status);
        }
        return filtered;
      },
    }),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**Slide 224: UI Store Implementation**
```tsx
// src/stores/uiStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface UIState {
  theme: 'light' | 'dark' | 'system';
  modal: { visible: boolean; type: string; data: any };
  toasts: Toast[];
  isLoading: boolean;
  isOnline: boolean;
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
  showModal: (type: string, data?: any) => void;
  hideModal: () => void;
  showToast: (message: string, type: 'success' | 'error' | 'info') => void;
  hideToast: (id: string) => void;
  setLoading: (loading: boolean) => void;
  setOnlineStatus: (online: boolean) => void;
}

export const useUIStore = create<UIState>((set) => ({
  theme: 'system',
  modal: { visible: false, type: '', data: null },
  toasts: [],
  isLoading: false,
  isOnline: true,

  showToast: (message, type) => {
    const id = `toast-${Date.now()}`;
    set((state) => ({
      toasts: [...state.toasts, { id, message, type }]
    }));
    setTimeout(() => {
      set((state) => ({
        toasts: state.toasts.filter(t => t.id !== id)
      }));
    }, 3000);
  },
}));
```

---

## Module 7: Data Persistence

### 7.1: Persistence Options (5 slides)

**Slide 225: Storage Solutions Comparison**

| Storage | Type | Speed | Size | Use Case |
|---------|------|-------|------|----------|
| AsyncStorage | Key-Value | Slow | ~6MB | Settings, simple data |
| MMKV | Key-Value | Very Fast | ~2GB | Caching, performance-critical |
| SQLite | Relational | Moderate | ~2GB | Complex data, queries |
| SecureStore | Encrypted | Slow | ~2GB | Tokens, sensitive data |

**Slide 226: Installation**
```bash
# AsyncStorage (built-in with Expo)
npx expo install @react-native-async-storage/async-storage

# MMKV
npx expo install react-native-mmkv

# SQLite
npx expo install expo-sqlite

# SecureStore
npx expo install expo-secure-store
```

**Slide 227: Choosing the Right Storage**

| Data Type | Recommended Storage |
|-----------|---------------------|
| App settings | AsyncStorage |
| Auth tokens | SecureStore |
| Large dataset cache | MMKV |
| Complex relational data | SQLite |
| Offline task data | SQLite + MMKV |

**Slide 228: Storage Decision Matrix**

| Factor | AsyncStorage | MMKV | SQLite | SecureStore |
|--------|--------------|------|--------|-------------|
| Ease of Use | Very Easy | Easy | Moderate | Easy |
| Performance | Moderate | Excellent | Good | Moderate |
| Query Support | None | None | Full SQL | None |
| Encryption | None | Optional | None | Built-in |
| Size Limit | ~6MB | ~2GB | ~2GB | ~2GB |

**Slide 229: Persistence Architecture**
```
┌─────────────────────────────────────────────────────────────────┐
│                    PERSISTENCE ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Application Layer                   │    │
│  │  ┌───────────────────────────────────────────────────┐ │    │
│  │  │  Zustand Stores │  Components  │  Services       │ │    │
│  │  └───────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Storage Layer                      │    │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐ │    │
│  │  │ AsyncStorage│  │   MMKV     │  │     SQLite       │ │    │
│  │  │  (Settings)│  │  (Cache)   │  │   (Data)         │ │    │
│  │  └────────────┘  └────────────┘  └──────────────────┘ │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Device Storage                     │    │
│  │  ┌───────────────────────────────────────────────────┐ │    │
│  │  │  File System │  Keychain │  Shared Preferences    │ │    │
│  │  └───────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

### 7.2: AsyncStorage Implementation (4 slides)

**Slide 230: Basic Operations**
```tsx
import AsyncStorage from '@react-native-async-storage/async-storage';

// Save data
await AsyncStorage.setItem('@key', JSON.stringify(value));

// Load data
const value = await AsyncStorage.getItem('@key');
const parsed = value ? JSON.parse(value) : null;

// Remove data
await AsyncStorage.removeItem('@key');

// Clear allawait AsyncStorage.clear();
```

**Slide 231: Advanced Operations**
```tsx
// Multiple items
await AsyncStorage.multiSet([
  ['@key1', 'value1'],
  ['@key2', 'value2'],
]);

const results = await AsyncStorage.multiGet(['@key1', '@key2']);

// Get all keys
const keys = await AsyncStorage.getAllKeys();

// Remove multiple
await AsyncStorage.multiRemove(['@key1', '@key2']);

// Merge objects
await AsyncStorage.mergeItem('@user', JSON.stringify({ name: 'John' }));
```

**Slide 232: Utility Service**
```tsx
class StorageService {
  static async setItem<T>(key: string, value: T): Promise<void> {
    try {
      await AsyncStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error('Error saving:', error);
      throw new Error(`Failed to save ${key}`);
    }
  }

  static async getItem<T>(key: string): Promise<T | null> {
    try {
      const value = await AsyncStorage.getItem(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Error loading:', error);
      return null;
    }
  }

  static async removeItem(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error('Error removing:', error);
    }
  }
}
```

**Slide 233: Error Handling**
```tsx
try {
  await AsyncStorage.setItem('@key', JSON.stringify(value));
} catch (error) {
  if (error instanceof QuotaExceededError) {
    console.error('Storage quota exceeded!');
  } else {
    console.error('Storage error:', error);
  }
}
```

---

### 7.3: MMKV for Performance (4 slides)

**Slide 234: Setup**
```tsx
import { MMKV } from 'react-native-mmkv';

// Create storage instance
const storage = new MMKV({
  id: 'app-storage',
  encryptionKey: process.env.ENCRYPTION_KEY, // Optional
});

// Create multiple instances for different data
const cacheStorage = new MMKV({ id: 'cache-storage' });
const userStorage = new MMKV({ id: 'user-storage' });
```

**Slide 235: Basic Operations**
```tsx
// Set values
storage.set('string', 'value');
storage.set('number', 42);
storage.set('boolean', true);
storage.set('object', JSON.stringify({ foo: 'bar' }));

// Get values
const stringValue = storage.getString('string');
const numberValue = storage.getNumber('number');
const booleanValue = storage.getBoolean('boolean');
const objectValue = JSON.parse(storage.getString('object') || '{}');

// Delete
storage.delete('key');

// Clear all
storage.clearAll();
```

**Slide 236: Performance Comparison**
```tsx
// MMKV (100x faster)
const start = performance.now();
for (let i = 0; i < 1000; i++) {
  storage.set(`key_${i}`, i);
  storage.getString(`key_${i}`);
}
console.log('MMKV:', performance.now() - start, 'ms');

// AsyncStorage (baseline)
const start = performance.now();
for (let i = 0; i < 1000; i++) {
  await AsyncStorage.setItem(`key_${i}`, String(i));
  await AsyncStorage.getItem(`key_${i}`);
}
console.log('AsyncStorage:', performance.now() - start, 'ms');
```

**Slide 237: Typed MMKV Service**
```tsx
class MMKVService {
  private storage: MMKV;

  constructor(id: string) {
    this.storage = new MMKV({ id });
  }

  set<T>(key: string, value: T): void {
    if (typeof value === 'string') {
      this.storage.set(key, value);
    } else {
      this.storage.set(key, JSON.stringify(value));
    }
  }

  get<T>(key: string): T | null {
    try {
      const value = this.storage.getString(key);
      if (value) {
        return JSON.parse(value) as T;
      }
      return null;
    } catch {
      return this.storage.getString(key) as unknown as T | null;
    }
  }

  delete(key: string): void {
    this.storage.delete(key);
  }

  clear(): void {
    this.storage.clearAll();
  }
}
```

---

### 7.4: SQLite for Complex Data (5 slides)

**Slide 238: Setup and Schema**
```tsx
import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabaseSync('taskflow.db');

// Create tables
await db.execAsync(`
  CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT NOT NULL,
    status TEXT NOT NULL,
    due_date TEXT,
    assigned_to TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (assigned_to) REFERENCES users(id)
  );

  CREATE INDEX idx_tasks_status ON tasks(status);
  CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
`);
```

**Slide 239: CRUD Operations**
```tsx
// Insert
await db.execAsync(
  'INSERT INTO tasks (id, title, description, priority, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
  [id, title, description, priority, status, created_at, updated_at]
);

// Select
const tasks = await db.execAsync('SELECT * FROM tasks ORDER BY created_at DESC');

// Select with filter
const tasks = await db.execAsync(
  'SELECT * FROM tasks WHERE status = ? ORDER BY due_date ASC',
  ['todo']
);

// Update
await db.execAsync(
  'UPDATE tasks SET status = ?, updated_at = ? WHERE id = ?',
  ['done', new Date().toISOString(), id]
);

// Delete
await db.execAsync('DELETE FROM tasks WHERE id = ?', [id]);
```

**Slide 240: Complex Queries with Joins**
```tsx
// Get tasks with assignee information
const tasksWithAssignees = await db.execAsync(`
  SELECT 
    t.*,
    u.name as assigned_to_name,
    u.email as assigned_to_email,
    COUNT(s.id) as subtask_count
  FROM tasks t
  LEFT JOIN users u ON t.assigned_to = u.id
  LEFT JOIN subtasks s ON t.id = s.task_id
  GROUP BY t.id
  ORDER BY t.created_at DESC
`);

// Get task statistics
const stats = await db.execAsync(`
  SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN status = 'todo' THEN 1 ELSE 0 END) as todo,
    SUM(CASE WHEN status = 'in-progress' THEN 1 ELSE 0 END) as in_progress,
    SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END) as done
  FROM tasks
`);
```

**Slide 241: Migration Handling**
```tsx
class MigrationManager {
  private db: SQLite.SQLiteDatabase;
  private version: number = 1;

  async migrate() {
    const currentVersion = await this.getVersion();
    
    if (currentVersion < 1) {
      await this.createInitialSchema();
    }
    
    if (currentVersion < 2) {
      await this.migrateToV2();
    }
    
    if (currentVersion < 3) {
      await this.migrateToV3();
    }
  }

  async createInitialSchema() {
    await this.db.execAsync(`
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    `);
    await this.setVersion(1);
  }

  async migrateToV2() {
    await this.db.execAsync(`
      ALTER TABLE tasks ADD COLUMN description TEXT;
      ALTER TABLE tasks ADD COLUMN priority TEXT DEFAULT 'medium';
    `);
    await this.setVersion(2);
  }
}
```

**Slide 242: SQLite Best Practices**
- Use transactions for multiple operations
- Index frequently queried columns
- Use prepared statements for security
- Handle database version migration
- Close connections when not needed

---

### 7.5: Offline-First Architecture (6 slides)

**Slide 243: Offline-First Principles**
- **Local First:** Always read from and write to local storage first
- **Sync Later:** Sync with server when connectivity is available
- **Optimistic UI:** Update UI immediately, rollback on failure
- **Conflict Resolution:** Handle conflicts when data diverges

**Slide 244: Sync Engine Architecture**
```tsx
┌─────────────────────────────────────────────────────────────────┐
│                      SYNC ENGINE                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────┐   │
│  │  Operation  │  │  Conflict   │  │  Retry with Backoff  │   │
│  │  Queue      │──▶  Resolution │──▶  and Exponential     │   │
│  │  (Priority) │  │  (LWW/CRDT) │  │  Delay               │   │
│  └─────────────┘  └─────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 245: Sync Engine Implementation**
```tsx
class SyncEngine {
  private queue: SyncOperation[] = [];
  private isOnline: boolean = true;
  private isSyncing: boolean = false;

  constructor() {
    this.setupNetworkListener();
    this.loadQueue();
  }

  async enqueue(operation: SyncOperation) {
    this.queue.push(operation);
    await this.saveQueue();
    
    if (this.isOnline) {
      this.sync();
    }
  }

  async sync() {
    if (this.isSyncing || !this.isOnline || this.queue.length === 0) {
      return;
    }

    this.isSyncing = true;
    const operations = this.queue.filter(op => op.status === 'pending');

    for (const operation of operations) {
      try {
        await this.processOperation(operation);
        operation.status = 'completed';
      } catch (error) {
        operation.status = 'failed';
        operation.retries++;
        if (operation.retries < 5) {
          setTimeout(() => {
            operation.status = 'pending';
            this.sync();
          }, 1000 * Math.pow(2, operation.retries));
        }
      }
    }

    this.isSyncing = false;
    await this.saveQueue();
  }
}
```

**Slide 246: Optimistic UI Pattern**
```tsx
const addTask = async (taskData: CreateTaskData) => {
  // 1. Optimistic update - show immediately
  const tempId = `temp-${Date.now()}`;
  const optimisticTask = { id: tempId, ...taskData, status: 'todo' };
  useTaskStore.getState().addTask(optimisticTask);
  
  // 2. Try to create on server
  try {
    const task = await api.createTask(taskData);
    // Replace temp task with real one
    useTaskStore.getState().updateTask(tempId, task);
  } catch (error) {
    // 3. Rollback on failure
    useTaskStore.getState().removeTask(tempId);
    showError('Failed to create task');
  }
};
```

**Slide 247: Conflict Resolution Strategies**

| Strategy | Description | When to Use |
|----------|-------------|-------------|
| Last Write Wins | Most recent timestamp wins | Simple data |
| Merge | Combine conflicting values | Complex data |
| Manual | Let user resolve | High-value data |
| CRDT | Conflict-free replication | Collaborative apps |

**Slide 248: Offline-First Best Practices**
- Always write to local storage first
- Queue operations when offline
- Use optimistic UI for responsiveness
- Implement conflict resolution
- Handle network state changes
- Background sync with retry logic

---

# PART 3: DEVICE CAPABILITIES & NATIVE FEATURES

---

## Module 8: Device APIs

### 8.1: Camera & Photo Library (8 slides)

**Slide 249: Camera Setup**
```bash
npx expo install expo-camera
```

**Slide 250: Camera Permissions**
```tsx
import { Camera } from 'expo-camera';

const requestCameraPermission = async () => {
  const { status } = await Camera.requestCameraPermissionsAsync();
  if (status !== 'granted') {
    Alert.alert('Permission Required', 'Camera access is needed.');
    return false;
  }
  return true;
};
```

**Slide 251: Camera Component**
```tsx
import { Camera } from 'expo-camera';
import { useState, useRef } from 'react';

function CameraScreen() {
  const [hasPermission, setHasPermission] = useState(false);
  const [type, setType] = useState(Camera.Constants.Type.back);
  const cameraRef = useRef<Camera>(null);

  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  const takePicture = async () => {
    if (cameraRef.current) {
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.8,
        base64: true,
      });
      // Use photo.uri
    }
  };

  if (!hasPermission) {
    return <Text>No camera access</Text>;
  }

  return (
    <Camera ref={cameraRef} style={{ flex: 1 }} type={type}>
      <View style={styles.buttonContainer}>
        <TouchableOpacity onPress={takePicture}>
          <Text>Take Photo</Text>
        </TouchableOpacity>
      </View>
    </Camera>
  );
}
```

**Slide 252: Image Picker Setup**
```bash
npx expo install expo-image-picker
```

**Slide 253: Image Picker Implementation**
```tsx
import * as ImagePicker from 'expo-image-picker';

const pickImage = async () => {
  // Request permission
  const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
  if (status !== 'granted') {
    Alert.alert('Permission Required');
    return;
  }

  // Pick image
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ImagePicker.MediaTypeOptions.Images,
    allowsEditing: true,
    aspect: [4, 3],
    quality: 0.8,
    base64: true,
  });

  if (!result.canceled) {
    const asset = result.assets[0];
    // Use asset.uri, asset.base64, etc.
  }
};
```

**Slide 254: Image Optimization**
```bash
npx expo install expo-image-manipulator
```

**Slide 255: Image Optimization Implementation**
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

**Slide 256: Camera Best Practices**
- Always request permissions
- Handle permission denial gracefully
- Optimize images before storage
- Use appropriate quality settings
- Show camera preview overlay
- Handle orientation changes

---

### 8.2: Geolocation Services (5 slides)

**Slide 257: Geolocation Setup**
```bash
npx expo install expo-location
```

**Slide 258: Get Current Location**
```tsx
import * as Location from 'expo-location';

const getLocation = async () => {
  const { status } = await Location.requestForegroundPermissionsAsync();
  if (status !== 'granted') {
    Alert.alert('Permission Required');
    return null;
  }

  const location = await Location.getCurrentPositionAsync({
    accuracy: Location.Accuracy.Balanced,
    timeout: 10000,
  });

  return {
    latitude: location.coords.latitude,
    longitude: location.coords.longitude,
    altitude: location.coords.altitude,
    accuracy: location.coords.accuracy,
  };
};
```

**Slide 259: Reverse Geocoding**
```tsx
const getAddress = async (latitude: number, longitude: number) => {
  const results = await Location.reverseGeocodeAsync({
    latitude,
    longitude,
  });

  if (results.length > 0) {
    const result = results[0];
    return {
      street: result.street,
      city: result.city,
      region: result.region,
      country: result.country,
      postalCode: result.postalCode,
    };
  }
  return null;
};
```

**Slide 260: Location Tracking**
```tsx
const watchLocation = () => {
  const subscription = await Location.watchPositionAsync(
    {
      accuracy: Location.Accuracy.Balanced,
      timeInterval: 5000,
      distanceInterval: 10,
    },
    (location) => {
      // Handle location update
      console.log('Location update:', location.coords);
    }
  );

  return subscription;
};
```

**Slide 261: Location Best Practices**
- Request permissions explicitly
- Handle permission denial
- Use appropriate accuracy level
- Stop tracking when not needed
- Show location indicators
- Respect user privacy

---

### 8.3: Push Notifications (6 slides)

**Slide 262: Notification Setup**
```bash
npx expo install expo-notifications
```

**Slide 263: Request Permissions**
```tsx
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';

const requestPermissions = async () => {
  const { status } = await Notifications.requestPermissionsAsync();
  if (status !== 'granted') {
    Alert.alert('Permission Required');
    return false;
  }
  return true;
};
```

**Slide 264: Get Push Token**
```tsx
const getPushToken = async () => {
  if (!Device.isDevice) {
    Alert.alert('Must use physical device');
    return null;
  }

  const token = await Notifications.getExpoPushTokenAsync({
    projectId: process.env.EXPO_PUBLIC_PROJECT_ID,
  });

  return token.data;
};
```

**Slide 265: Send Notification**
```tsx
const sendNotification = async (title: string, body: string, data?: any) => {
  await Notifications.scheduleNotificationAsync({
    content: {
      title,
      body,
      data: data || {},
      sound: true,
      badge: 1,
    },
    trigger: null, // Send immediately
  });
};
```

**Slide 266: Schedule Notification**
```tsx
const scheduleNotification = async (
  title: string,
  body: string,
  date: Date,
  data?: any
) => {
  const trigger = {
    date,
  };

  await Notifications.scheduleNotificationAsync({
    content: {
      title,
      body,
      data: data || {},
    },
    trigger,
  });
};
```

**Slide 267: Handle Notification Taps**
```tsx
useEffect(() => {
  // Handle notification response (user taps)
  const subscription = Notifications.addNotificationResponseReceivedListener(
    (response) => {
      const data = response.notification.request.content.data;
      // Navigate based on data
      navigation.navigate('TaskDetail', { id: data.taskId });
    }
  );

  return () => subscription.remove();
}, []);
```

---

### 8.4: Hands-On Lab: Task Attachments (4 slides)

**Slide 268: Lab Objectives**
- Add camera to task creation
- Add photo library selection
- Store and display images
- Optimize images
- Location tagging for tasks

**Slide 269: Camera Service**
```tsx
// src/services/cameraService.ts
import * as Camera from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';

export class CameraService {
  static async takePhoto(): Promise<string | null> {
    const permission = await Camera.requestCameraPermissionsAsync();
    if (!permission.granted) return null;

    const result = await ImagePicker.launchCameraAsync({
      quality: 0.8,
      allowsEditing: true,
    });

    if (!result.canceled) {
      return await this.optimizeImage(result.assets[0].uri);
    }
    return null;
  }

  static async pickImage(): Promise<string | null> {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) return null;

    const result = await ImagePicker.launchImageLibraryAsync({
      quality: 0.8,
      allowsEditing: true,
    });

    if (!result.canceled) {
      return await this.optimizeImage(result.assets[0].uri);
    }
    return null;
  }

  static async optimizeImage(uri: string): Promise<string> {
    const result = await ImageManipulator.manipulateAsync(
      uri,
      [{ resize: { width: 800 } }],
      { compress: 0.8 }
    );
    return result.uri;
  }
}
```

**Slide 270: Location Service**
```tsx
// src/services/locationService.ts
import * as Location from 'expo-location';

export class LocationService {
  static async getCurrentLocation() {
    const permission = await Location.requestForegroundPermissionsAsync();
    if (!permission.granted) return null;

    const location = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.Balanced,
    });

    return location.coords;
  }

  static async getAddress(latitude: number, longitude: number) {
    const results = await Location.reverseGeocodeAsync({ latitude, longitude });
    return results[0];
  }
}
```

**Slide 271: Task Form Integration**
```tsx
// src/components/TaskFormWithAttachments.tsx
import React, { useState } from 'react';
import { View, Text, TouchableOpacity, Image, StyleSheet } from 'react-native';
import { CameraService } from '../services/cameraService';
import { LocationService } from '../services/locationService';

export function TaskFormWithAttachments() {
  const [imageUri, setImageUri] = useState<string | null>(null);
  const [location, setLocation] = useState<any>(null);

  const handleTakePhoto = async () => {
    const uri = await CameraService.takePhoto();
    if (uri) setImageUri(uri);
  };

  const handlePickImage = async () => {
    const uri = await CameraService.pickImage();
    if (uri) setImageUri(uri);
  };

  const handleGetLocation = async () => {
    const coords = await LocationService.getCurrentLocation();
    if (coords) {
      const address = await LocationService.getAddress(
        coords.latitude,
        coords.longitude
      );
      setLocation(address);
    }
  };

  return (
    <View style={styles.container}>
      {imageUri && (
        <Image source={{ uri: imageUri }} style={styles.image} />
      )}
      
      <View style={styles.buttonRow}>
        <TouchableOpacity onPress={handleTakePhoto} style={styles.button}>
          <Text>📷 Take Photo</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={handlePickImage} style={styles.button}>
          <Text>🖼️ Pick Image</Text>
        </TouchableOpacity>
      </View>

      <TouchableOpacity onPress={handleGetLocation} style={styles.button}>
        <Text>📍 Get Location</Text>
      </TouchableOpacity>

      {location && (
        <Text style={styles.location}>
          {location.street}, {location.city}
        </Text>
      )}
    </View>
  );
}
```

---

## Module 9: Gestures & Animations

### 9.1: Gesture Handler Overview (6 slides)

**Slide 272: Installation**
```bash
npx expo install react-native-gesture-handler
```

**Slide 273: Gesture Types Overview**
```
┌─────────────────────────────────────────────────────────────────┐
│                    GESTURE TYPES                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Tap (Tap)                                             │    │
│  │  ┌─────────────────────────────────────────────────┐   │    │
│  │  │  Single tap, double tap, long press            │   │    │
│  │  └─────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Pan                                                    │    │
│  │  ┌─────────────────────────────────────────────────┐   │    │
│  │  │  Dragging, swiping, scrolling                  │   │    │
│  │  └─────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Pinch                                                  │    │
│  │  ┌─────────────────────────────────────────────────┐   │    │
│  │  │  Zoom, scale                                    │   │    │
│  │  └─────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

**Slide 274: Gesture Handlers vs Touchable**

| Feature | Touchable | Gesture Handler |
|---------|-----------|-----------------|
| Simple presses | ✅ | ✅ |
| Complex gestures | ❌ | ✅ |
| Custom interactions | Limited | Full |
| Performance | Good | Better |
| Learning curve | Low | Moderate |

**Slide 275: Gesture Detector Pattern**
```tsx
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, { useSharedValue, useAnimatedStyle } from 'react-native-reanimated';

function DraggableComponent() {
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

**Slide 276: Gesture Composition**
```tsx
// Simultaneous gestures
const combinedGesture = Gesture.Simultaneous(
  Gesture.Pan(),
  Gesture.Rotation()
);

// Race between gestures
const raceGesture = Gesture.Race(
  Gesture.Tap(),
  Gesture.LongPress()
);

// Exclusive gestures
const exclusiveGesture = Gesture.Exclusive(
  Gesture.Tap(),
  Gesture.Pan()
);

// Sequential gestures
const sequentialGesture = Gesture.Sequence(
  Gesture.LongPress(),
  Gesture.Pan()
);
```

**Slide 277: Gesture Best Practices**
- Use Gesture Detector pattern
- Handle gesture conflicts
- Provide visual feedback
- Use haptic feedback
- Test on physical devices
- Consider accessibility

---

### 9.2: Reanimated 2 Basics (6 slides)

**Slide 278: Installation**
```bash
npx expo install react-native-reanimated
```

**Slide 279: Shared Values**
```tsx
import Animated, { useSharedValue, useAnimatedStyle } from 'react-native-reanimated';

function AnimatedComponent() {
  // Shared values - cross-thread communication
  const scale = useSharedValue(1);
  const rotation = useSharedValue(0);
  const opacity = useSharedValue(1);

  // Animated style
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { scale: scale.value },
      { rotate: `${rotation.value}rad` },
    ],
    opacity: opacity.value,
  }));

  // Animate with spring
  const animateWithSpring = () => {
    scale.value = withSpring(1.5, {
      damping: 15,
      stiffness: 150,
    });
    rotation.value = withSpring(Math.PI / 4);
    opacity.value = withSpring(0.5);
  };

  return (
    <Animated.View style={[styles.box, animatedStyle]} />
  );
}
```

**Slide 280: Animation Functions**
```tsx
// With Timing
const value = useSharedValue(0);
value.value = withTiming(100, {
  duration: 500,
  easing: Easing.inOut(Easing.ease),
});

// With Spring
value.value = withSpring(100, {
  damping: 10,
  stiffness: 100,
  mass: 1,
});

// With Sequence
value.value = withSequence(
  withTiming(50, { duration: 200 }),
  withSpring(100),
  withTiming(0, { duration: 200 })
);

// With Delay
value.value = withDelay(500, withSpring(100));

// With Repeat
value.value = withRepeat(
  withTiming(100, { duration: 500 }),
  3,
  true // Reverse
);
```

**Slide 281: Worklets**
```tsx
// Worklets run on the UI thread
const someWorklet = () => {
  'worklet';
  // This code runs on the UI thread
  return 42;
};

// Using worklets in gestures
const gesture = Gesture.Pan()
  .onStart(() => {
    'worklet';
    // Runs on UI thread
    scale.value = 1.2;
  })
  .onUpdate((event) => {
    'worklet';
    // Runs on UI thread
    translateX.value = event.translationX;
  });
```

**Slide 282: Interpolation**
```tsx
const animatedStyle = useAnimatedStyle(() => {
  const rotate = interpolate(
    progress.value,
    [0, 1],
    [0, 360],
    Extrapolate.CLAMP
  );
  
  const scale = interpolate(
    progress.value,
    [0, 0.5, 1],
    [0.5, 1, 1.2],
    Extrapolate.CLAMP
  );
  
  return {
    transform: [{ rotate: `${rotate}deg` }, { scale }],
  };
});
```

**Slide 283: Reanimated Best Practices**
- Use Shared Values for cross-thread data
- Keep animations on UI thread
- Use worklets for UI-thread code
- Interpolate values for complex animations
- Test on physical devices
- Optimize for 60fps

---

### 9.3: Swipe-to-Delete Pattern (4 slides)

**Slide 284: Complete Implementation**
```tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  runOnJS,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

function SwipeableItem({ children, onDelete }) {
  const translateX = useSharedValue(0);
  const THRESHOLD = -80;

  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = Math.min(0, event.translationX);
    })
    .onEnd(() => {
      if (translateX.value < THRESHOLD) {
        // Delete
        translateX.value = withTiming(-300);
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
        runOnJS(onDelete)();
      } else {
        // Spring back
        translateX.value = withSpring(0);
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }));

  return (
    <View style={styles.wrapper}>
      <View style={styles.deleteAction}>
        <Text style={styles.deleteText}>Delete</Text>
      </View>
      <GestureDetector gesture={gesture}>
        <Animated.View style={[styles.container, animatedStyle]}>
          {children}
        </Animated.View>
      </GestureDetector>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    borderRadius: 12,
    overflow: 'hidden',
  },
  container: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 12,
  },
  deleteAction: {
    position: 'absolute',
    right: 0,
    top: 0,
    bottom: 0,
    width: 80,
    backgroundColor: '#e74c3c',
    justifyContent: 'center',
    alignItems: 'center',
  },
  deleteText: {
    color: '#ffffff',
    fontWeight: 'bold',
  },
});
```

**Slide 285: Key Concepts**
- Pan gesture for horizontal dragging
- Threshold to trigger delete
- Spring back if threshold not met
- Haptic feedback on delete
- Animation for smooth UX

**Slide 286: Use Cases**
- Task list deletion
- Email/chat deletion
- Shopping cart removal
- Photo gallery deletion
- Contact removal

**Slide 287: Swipe-to-Delete Best Practices**
- Clear visual indicator
- Confirm destructive actions
- Provide undo option
- Use haptic feedback
- Smooth animations

---

### 9.4: Drag-to-Reorder (4 slides)

**Slide 288: Implementation**
```tsx
import React, { useState } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';

function DragReorderList({ data: initialData, onReorder }) {
  const [data, setData] = useState(initialData);
  const [draggingIndex, setDraggingIndex] = useState(null);

  const renderItem = ({ item, index }) => {
    const translateY = useSharedValue(0);
    const scale = useSharedValue(1);

    const gesture = Gesture.Pan()
      .onStart(() => {
        setDraggingIndex(index);
        scale.value = withSpring(1.05);
      })
      .onUpdate((event) => {
        translateY.value = event.translationY;
        const newIndex = Math.round(
          index + event.translationY / 80
        );
        if (newIndex >= 0 && newIndex < data.length && newIndex !== index) {
          const newData = [...data];
          const [moved] = newData.splice(index, 1);
          newData.splice(newIndex, 0, moved);
          setData(newData);
          onReorder(newData);
          setDraggingIndex(newIndex);
        }
      })
      .onEnd(() => {
        translateY.value = withSpring(0);
        scale.value = withSpring(1);
        setDraggingIndex(null);
      });

    const animatedStyle = useAnimatedStyle(() => ({
      transform: [
        { translateY: translateY.value },
        { scale: scale.value },
      ],
      zIndex: draggingIndex === index ? 100 : 1,
    }));

    return (
      <GestureDetector gesture={gesture}>
        <Animated.View style={[styles.item, animatedStyle]}>
          <Text>{item.title}</Text>
        </Animated.View>
      </GestureDetector>
    );
  };

  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={(item) => item.id}
    />
  );
}
```

**Slide 289: Key Concepts**
- Pan gesture for vertical dragging
- Calculate new position from drag distance
- Animate items during drag
- Update data on position change
- Spring back on release

**Slide 290: Use Cases**
- Task priority ordering
- Playlist ordering
- Shopping list ordering
- Image gallery ordering
- Contact ordering

**Slide 291: Drag-to-Reorder Best Practices**
- Visual drag indicator
- Smooth animations
- Haptic feedback on drag
- Clear drop target
- Accessibility support

---

### 9.5: Pull-to-Refresh Custom (4 slides)

**Slide 292: Implementation**
```tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  interpolate,
  Extrapolate,
} from 'react-native-reanimated';

function CustomPullToRefresh({ onRefresh, children }) {
  const translateY = useSharedValue(0);
  const isRefreshing = useSharedValue(false);
  const THRESHOLD = 80;
  const MAX_PULL = 150;

  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      if (!isRefreshing.value && event.translationY > 0) {
        translateY.value = Math.min(event.translationY, MAX_PULL);
      }
    })
    .onEnd(async () => {
      if (translateY.value > THRESHOLD) {
        isRefreshing.value = true;
        await onRefresh();
        isRefreshing.value = false;
      }
      translateY.value = withSpring(0);
    });

  const containerStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }],
  }));

  const indicatorStyle = useAnimatedStyle(() => {
    const progress = Math.min(translateY.value / THRESHOLD, 1);
    const rotate = interpolate(
      progress,
      [0, 1],
      [0, 360],
      Extrapolate.CLAMP
    );
    const scale = interpolate(
      progress,
      [0, 0.5, 1],
      [0.5, 1, 1.2],
      Extrapolate.CLAMP
    );
    return {
      transform: [{ rotate: `${rotate}deg` }, { scale }],
      opacity: progress,
    };
  });

  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.container, containerStyle]}>
        <View style={styles.indicatorContainer}>
          <Animated.View style={[styles.indicator, indicatorStyle]}>
            <Text>⟳</Text>
          </Animated.View>
          <Text style={styles.indicatorText}>
            {isRefreshing.value ? 'Refreshing...' : 'Pull to refresh'}
          </Text>
        </View>
        {children}
      </Animated.View>
    </GestureDetector>
  );
}
```

**Slide 293: Key Concepts**
- Pan gesture for downward pull
- Threshold to trigger refresh
- Progress indicator animation
- Spring back on release
- Loading state

**Slide 294: Use Cases**
- Task list refresh
- Feed refresh
- Data sync
- Content reload
- Dashboard refresh

**Slide 295: Pull-to-Refresh Best Practices**
- Clear visual indicator
- Smooth animations
- Loading state feedback
- Haptic feedback
- Accessibility support

---

### 9.6: Hands-On Lab: Interactive Task List (4 slides)

**Slide 296: Lab Objectives**
- Implement swipe-to-delete
- Implement drag-to-reorder
- Implement pull-to-refresh
- Add haptic feedback

**Slide 297: Component Structure**
```tsx
// src/components/InteractiveTaskList.tsx
import React, { useState } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { SwipeableItem } from './SwipeableItem';
import { DragReorderList } from './DragReorderList';
import { CustomPullToRefresh } from './CustomPullToRefresh';

export function InteractiveTaskList() {
  const [tasks, setTasks] = useState([]);
  const [refreshing, setRefreshing] = useState(false);

  const handleDelete = (id) => {
    setTasks(tasks.filter(task => task.id !== id));
  };

  const handleReorder = (newTasks) => {
    setTasks(newTasks);
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchTasks();
    setRefreshing(false);
  };

  const renderTask = ({ item }) => (
    <SwipeableItem onDelete={() => handleDelete(item.id)}>
      <View style={styles.taskContainer}>
        <Text style={styles.taskTitle}>{item.title}</Text>
        <Text style={styles.taskStatus}>{item.status}</Text>
      </View>
    </SwipeableItem>
  );

  return (
    <CustomPullToRefresh onRefresh={handleRefresh}>
      <DragReorderList
        data={tasks}
        onReorder={handleReorder}
        renderItem={renderTask}
      />
    </CustomPullToRefresh>
  );
}
```

**Slide 298: Key Concepts**
- Combined gesture interactions
- State management for tasks
- Optimistic updates
- Smooth animations
- Haptic feedback

**Slide 299: Testing**
- Test swipe-to-delete
- Test drag-to-reorder
- Test pull-to-refresh
- Verify haptic feedback
- Test on both platforms

---

## Module 10: Forms & Validation

### 10.1: React Hook Form (6 slides)

**Slide 300: Installation**
```bash
npm install react-hook-form
```

**Slide 301: Basic Setup**
```tsx
import { useForm, Controller } from 'react-hook-form';
import { View, Text, TextInput, TouchableOpacity, StyleSheet } from 'react-native';

function TaskForm() {
  const {
    control,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm({
    defaultValues: {
      title: '',
      description: '',
      priority: 'medium',
    },
  });

  const onSubmit = (data) => {
    console.log('Form data:', data);
  };

  return (
    <View style={styles.container}>
      <Controller
        control={control}
        rules={{
          required: 'Title is required',
          minLength: { value: 3, message: 'Minimum 3 characters' },
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            style={styles.input}
            placeholder="Task title"
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name="title"
      />
      {errors.title && <Text style={styles.error}>{errors.title.message}</Text>}

      <TouchableOpacity
        style={[styles.button, isSubmitting && styles.buttonDisabled]}
        onPress={handleSubmit(onSubmit)}
        disabled={isSubmitting}
      >
        <Text style={styles.buttonText}>
          {isSubmitting ? 'Creating...' : 'Create Task'}
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Slide 302: Controller vs Register**

| Feature | Controller | Register |
|---------|------------|----------|
| Usage | Controlled components | Uncontrolled components |
| Performance | Good | Better |
| Integration | Form libraries | Direct inputs |
| TypeScript | Excellent | Good |

**Slide 303: Form State Management**
```tsx
const {
  control,
  handleSubmit,
  formState: {
    errors,
    isSubmitting,
    isSubmitSuccessful,
    isSubmitFailed,
    touchedFields,
    dirtyFields,
  },
  watch,
  setValue,
  reset,
} = useForm();
```

**Slide 304: Validation Rules**
```tsx
<Controller
  control={control}
  rules={{
    required: 'Title is required',
    minLength: { value: 3, message: 'Minimum 3 characters' },
    maxLength: { value: 100, message: 'Maximum 100 characters' },
    pattern: {
      value: /^[a-zA-Z0-9 ]*$/,
      message: 'Only letters, numbers, and spaces',
    },
    validate: (value) => {
      if (value.includes('badword')) {
        return 'Invalid text';
      }
      return true;
    },
  }}
  render={({ field: { onChange, onBlur, value } }) => (
    <TextInput
      style={styles.input}
      placeholder="Task title"
      onBlur={onBlur}
      onChangeText={onChange}
      value={value}
    />
  )}
  name="title"
/>
```

**Slide 305: React Hook Form Best Practices**
- Use Controller for complex inputs
- Use register for simple inputs
- Leverage built-in validation
- Handle form state efficiently
- Reset form after submission
- Type-safe forms with TypeScript

---

### 10.2: Zod Validation (5 slides)

**Slide 306: Installation**
```bash
npm install zod
```

**Slide 307: Define Schema**
```tsx
import { z } from 'zod';

const taskSchema = z.object({
  title: z
    .string()
    .min(3, 'Title must be at least 3 characters')
    .max(100, 'Title cannot exceed 100 characters'),
  description: z
    .string()
    .max(500, 'Description cannot exceed 500 characters')
    .optional(),
  priority: z
    .enum(['low', 'medium', 'high'])
    .default('medium'),
  dueDate: z
    .string()
    .refine((date) => !isNaN(Date.parse(date)), {
      message: 'Invalid date format',
    })
    .optional(),
  category: z
    .string()
    .min(2, 'Category must be at least 2 characters')
    .optional(),
});

type TaskFormData = z.infer<typeof taskSchema>;
```

**Slide 308: Integration with React Hook Form**
```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

function TaskForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<TaskFormData>({
    resolver: zodResolver(taskSchema),
  });

  const onSubmit = (data: TaskFormData) => {
    console.log('Validated data:', data);
  };

  // ... render form
}
```

**Slide 309: Custom Validations**
```tsx
const taskSchema = z.object({
  dueDate: z
    .string()
    .refine((date) => new Date(date) >= new Date(), {
      message: 'Due date cannot be in the past',
    })
    .optional(),
  
  // Cross-field validation
  category: z
    .string()
    .optional()
    .refine((value) => {
      if (value && value.length < 2) {
        return false;
      }
      return true;
    }, 'Category must be at least 2 characters'),
});
```

**Slide 310: Zod Best Practices**
- Define schemas in separate files
- Use inferred types for TypeScript
- Use refine for complex validations
- Provide clear error messages
- Test schemas with unit tests

---

### 10.3: Form Error Handling (5 slides)

**Slide 311: Error Display Patterns**
```tsx
// Individual field errors
{errors.title && (
  <Text style={styles.error}>{errors.title.message}</Text>
)}

// Global error display
{formState.isSubmitFailed && (
  <Text style={styles.error}>Please fix all errors</Text>
)}

// Custom error messages
{error && (
  <View style={styles.errorContainer}>
    <Text style={styles.errorText}>{error}</Text>
  </View>
)}
```

**Slide 312: Error State Styling**
```tsx
const getInputStyle = (field: keyof FormData) => {
  return [
    styles.input,
    errors[field] && styles.inputError,
    touchedFields[field] && styles.inputTouched,
  ];
};

// Usage
<TextInput
  style={getInputStyle('title')}
  // ...
/>
```

**Slide 313: Form Submission States**
```tsx
const {
  handleSubmit,
  formState: { isSubmitting, isSubmitSuccessful, isSubmitFailed },
} = useForm();

// Show loading state
{isSubmitting && <ActivityIndicator />}

// Show success message
{isSubmitSuccessful && (
  <Text style={styles.success}>Task created successfully!</Text>
)}

// Prevent double submission
<Button
  title="Submit"
  onPress={handleSubmit(onSubmit)}
  disabled={isSubmitting}
/>
```

**Slide 314: Complete Error Handling**
```tsx
// src/components/ValidatedTaskForm.tsx
import React from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const taskSchema = z.object({
  title: z.string().min(3, 'Title is required'),
  description: z.string().optional(),
  priority: z.enum(['low', 'medium', 'high']),
});

type TaskFormData = z.infer<typeof taskSchema>;

export function ValidatedTaskForm({ onSubmit, isLoading }) {
  const {
    control,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<TaskFormData>({
    resolver: zodResolver(taskSchema),
    defaultValues: {
      priority: 'medium',
    },
  });

  return (
    <View style={styles.container}>
      <Controller
        control={control}
        name="title"
        render={({ field: { onChange, onBlur, value } }) => (
          <View>
            <Text style={styles.label}>Title *</Text>
            <TextInput
              style={[styles.input, errors.title && styles.inputError]}
              placeholder="Enter task title"
              onBlur={onBlur}
              onChangeText={onChange}
              value={value}
            />
            {errors.title && (
              <Text style={styles.error}>{errors.title.message}</Text>
            )}
          </View>
        )}
      />

      <TouchableOpacity
        style={[styles.submitButton, (isSubmitting || isLoading) && styles.buttonDisabled]}
        onPress={handleSubmit(onSubmit)}
        disabled={isSubmitting || isLoading}
      >
        {isSubmitting || isLoading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.submitText}>Create Task</Text>
        )}
      </TouchableOpacity>
    </View>
  );
}
```

**Slide 315: Error Handling Best Practices**
- Display errors near fields
- Use clear error messages
- Show loading states
- Prevent duplicate submissions
- Provide success feedback
- Handle network errors

---

### 10.4: Hands-On Lab: TaskForm Validation (4 slides)

**Slide 316: Lab Objectives**
- Build complete validated form
- Title, description, date, priority
- Real-time validation
- Accessibility support

**Slide 317: Schema Definition**
```tsx
// src/schemas/taskSchema.ts
import { z } from 'zod';

export const taskSchema = z.object({
  title: z
    .string()
    .min(3, 'Title must be at least 3 characters')
    .max(100, 'Title cannot exceed 100 characters'),
  description: z
    .string()
    .max(500, 'Description cannot exceed 500 characters')
    .optional(),
  priority: z
    .enum(['low', 'medium', 'high'])
    .default('medium'),
  dueDate: z
    .string()
    .refine((date) => new Date(date) >= new Date(), {
      message: 'Due date cannot be in the past',
    })
    .optional(),
  category: z
    .string()
    .min(2, 'Category must be at least 2 characters')
    .max(50, 'Category cannot exceed 50 characters')
    .optional(),
  hasReminder: z
    .boolean()
    .default(false),
});

export type TaskFormData = z.infer<typeof taskSchema>;
```

**Slide 318: Form Implementation**
```tsx
// src/components/TaskForm.tsx
import React from 'react';
import { View, Text, TextInput, TouchableOpacity, Switch, StyleSheet, ScrollView, ActivityIndicator } from 'react-native';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { taskSchema, TaskFormData } from '../schemas/taskSchema';
import DateTimePicker from '@react-native-community/datetimepicker';
import { Platform } from 'react-native';

interface TaskFormProps {
  onSubmit: (data: TaskFormData) => Promise<void>;
  initialData?: Partial<TaskFormData>;
  isLoading?: boolean;
}

export function TaskForm({ onSubmit, initialData, isLoading }: TaskFormProps) {
  const [showDatePicker, setShowDatePicker] = React.useState(false);

  const {
    control,
    handleSubmit,
    formState: { errors, isSubmitting },
    watch,
    setValue,
  } = useForm<TaskFormData>({
    resolver: zodResolver(taskSchema),
    defaultValues: {
      title: initialData?.title || '',
      description: initialData?.description || '',
      priority: initialData?.priority || 'medium',
      dueDate: initialData?.dueDate || '',
      category: initialData?.category || '',
      hasReminder: initialData?.hasReminder || false,
    },
  });

  const dueDate = watch('dueDate');

  const handleDateChange = (event: any, selectedDate?: Date) => {
    setShowDatePicker(Platform.OS === 'ios');
    if (selectedDate) {
      setValue('dueDate', selectedDate.toISOString().split('T')[0]);
    }
  };

  return (
    <ScrollView style={styles.container}>
      {/* Form fields with validation */}
      {/* See full implementation in workbook */}
    </ScrollView>
  );
}
```

**Slide 319: Testing Form Validation**
- Test required fields
- Test invalid inputs
- Test valid inputs
- Test error messages
- Test accessibility

---

# PART 4: TESTING, PERFORMANCE & DEPLOYMENT

---

## Module 11: Performance Optimization

### 11.1: Performance Profiling (6 slides)

**Slide 320: React DevTools Profiler**
```tsx
// Wrap components with Profiler
import { Profiler } from 'react';

function App() {
  const onRender = (id, phase, actualDuration) => {
    if (actualDuration > 16) {
      console.warn(`Slow render: ${id} took ${actualDuration}ms`);
    }
  };

  return (
    <Profiler id="App" onRender={onRender}>
      <MainNavigator />
    </Profiler>
  );
}
```

**Slide 321: Performance Monitoring**
```tsx
class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private frameTimings: number[] = [];

  measureFrames() {
    let lastFrameTime = performance.now();
    const measure = () => {
      const now = performance.now();
      const delta = now - lastFrameTime;
      this.frameTimings.push(delta);
      
      if (delta > 16.67) {
        console.warn(`⚠️ Frame drop: ${delta.toFixed(2)}ms`);
      }
      
      lastFrameTime = now;
      requestAnimationFrame(measure);
    };
    measure();
  }

  getAverageFPS(): number {
    const avg = this.frameTimings.reduce((a, b) => a + b, 0) / this.frameTimings.length;
    return 1000 / avg;
  }
}
```

**Slide 322: Identifying Bottlenecks**

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| Janky scrolling | Heavy list rendering | Use FlatList optimizations |
| Slow navigation | Large bundle | Lazy load screens |
| High memory usage | Image size | Optimize images |
| UI freezes | Heavy JS | Move to native |
| Battery drain | Background processes | Clean up subscriptions |

**Slide 323: The 16.67ms Frame Budget**
- 60 frames per second
- 1000ms / 60 = 16.67ms per frame
- This is your budget for ALL work
- Frame drops = jank = poor UX

**Slide 324: Performance Profiling Tools**
- React DevTools Profiler
- Flipper
- Xcode Instruments (iOS)
- Android Profiler
- React Native Performance Monitor

**Slide 325: Performance Metrics to Track**
- FPS (target: 60)
- Startup time (target: < 2s)
- Memory usage (target: < 50MB)
- Bundle size (target: < 15MB)
- Network latency
- Crash rate

---

### 11.2: Rendering Optimization (6 slides)

**Slide 326: React.memo**
```tsx
// ✅ Good: Memoized component
const ExpensiveComponent = memo(({ data }) => {
  return (
    <View>
      {data.map(item => <Text key={item.id}>{item.title}</Text>)}
    </View>
  );
});

// ❌ Bad: Always re-renders
const ExpensiveComponent = ({ data }) => {
  // ...
};
```

**Slide 327: useMemo & useCallback**
```tsx
// ✅ Good: Memoized values
const filteredData = useMemo(() => {
  return data.filter(item => item.active);
}, [data]);

// ✅ Good: Stable function reference
const handlePress = useCallback(() => {
  doSomething(id);
}, [id]);
```

**Slide 328: Component Splitting**
```tsx
// ❌ Bad: Everything in one component
function BigComponent() {
  return (
    <View>
      <Header />
      <Content />
      <Footer />
    </View>
  );
}

// ✅ Good: Split into smaller components
function BigComponent() {
  return (
    <View>
      <MemoizedHeader />
      <MemoizedContent />
      <MemoizedFooter />
    </View>
  );
}
```

**Slide 329: Avoiding Inline Objects**
```tsx
// ❌ Bad: New object on every render
<View style={{ padding: 16, margin: 8 }}>

// ✅ Good: Static style reference
const styles = StyleSheet.create({
  container: {
    padding: 16,
    margin: 8,
  },
});
<View style={styles.container}>
```

**Slide 330: Virtual List Optimization**
```tsx
<FlatList
  data={data}
  renderItem={renderItem}
  keyExtractor={keyExtractor}
  // Optimizations
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

**Slide 331: Rendering Best Practices**
- Use React.memo for expensive components
- Use useMemo and useCallback
- Split large components
- Avoid inline objects
- Optimize list rendering
- Profile before optimizing

---

### 11.3: FlatList Optimization (5 slides)

**Slide 332: FlatList Props**

| Prop | Purpose | Recommendation |
|------|---------|----------------|
| removeClippedSubviews | Remove off-screen items | ✅ Enable |
| maxToRenderPerBatch | Items per batch | 10 |
| windowSize | Visible window size | 10 |
| initialNumToRender | Initial items | 20 |
| getItemLayout | Fixed heights | ✅ Use if possible |
| updateCellsBatchingPeriod | Update frequency | 50ms |

**Slide 333: getItemLayout Implementation**
```tsx
const ITEM_HEIGHT = 80;

const getItemLayout = (data, index) => ({
  length: ITEM_HEIGHT,
  offset: ITEM_HEIGHT * index,
  index,
});

// Usage
<FlatList
  data={data}
  renderItem={renderItem}
  keyExtractor={keyExtractor}
  getItemLayout={getItemLayout}
/>
```

**Slide 334: Virtualization Best Practices**
- Use FlatList for large lists
- Provide fixed item heights
- Use key extractor for stable keys
- Limit initial render
- Remove off-screen items
- Batch render updates

**Slide 335: Common FlatList Mistakes**

| Mistake | Solution |
|---------|----------|
| No key extractor | Add keyExtractor |
| Variable heights | Use getItemLayout if possible |
| Too many initial items | Reduce initialNumToRender |
| Off-screen items rendered | Enable removeClippedSubviews |
| No memoization | Use React.memo for items |

**Slide 336: FlatList Performance Monitoring**
```tsx
<FlatList
  data={data}
  renderItem={renderItem}
  keyExtractor={keyExtractor}
  onScroll={(event) => {
    const offset = event.nativeEvent.contentOffset.y;
    // Track scroll performance
    performanceMonitor.trackScroll(offset);
  }}
  onEndReached={() => {
    // Track pagination
    performanceMonitor.trackPagination();
  }}
/>
```

---

### 11.4: Memory Management (5 slides)

**Slide 337: Memory Leak Causes**

| Cause | Example | Solution |
|-------|---------|----------|
| Event listeners | `window.addEventListener` | Remove on unmount |
| Timers | `setInterval`, `setTimeout` | Clear on unmount |
| Subscriptions | `subscribe()` | Unsubscribe on unmount |
| Animations | `Animated.loop` | Stop on unmount |
| Large images | Heavy images | Optimize and cache |

**Slide 338: useEffect Cleanup**
```tsx
// Timer cleanup
useEffect(() => {
  const interval = setInterval(() => {
    setTime(Date.now());
  }, 1000);
  
  return () => clearInterval(interval);
}, []);

// Subscription cleanup
useEffect(() => {
  const subscription = eventEmitter.addListener('event', handler);
  
  return () => subscription.remove();
}, []);

// Abort controller cleanup
useEffect(() => {
  const controller = new AbortController();
  
  fetch(url, { signal: controller.signal })
    .then(res => res.json())
    .then(setData);
  
  return () => controller.abort();
}, []);
```

**Slide 339: Image Memory Management**
```tsx
// Optimize images
const optimizedImage = await ImageManipulator.manipulateAsync(
  uri,
  [{ resize: { width: 800 } }],
  { compress: 0.7 }
);

// Clear image cache
Image.cache.clear();

// Use smaller images for thumbnails
<Image 
  source={{ uri: thumbnailUri }}
  style={styles.thumbnail}
/>
```

**Slide 340: Memory Monitoring**
```tsx
class MemoryManager {
  checkMemory() {
    // @ts-ignore
    if (global.performance?.memory) {
      // @ts-ignore
      const { usedJSHeapSize, totalJSHeapSize } = global.performance.memory;
      const usedMB = usedJSHeapSize / (1024 * 1024);
      const totalMB = totalJSHeapSize / (1024 * 1024);
      
      if (usedMB / totalMB > 0.8) {
        console.warn(`⚠️ High memory usage: ${usedMB.toFixed(1)}MB / ${totalMB.toFixed(1)}MB`);
      }
    }
  }
}
```

**Slide 341: Memory Best Practices**
- Clean up subscriptions
- Clear timers on unmount
- Cancel animations
- Optimize images
- Use virtualization
- Monitor memory usage

---

### 11.5: Bundle Optimization (4 slides)

**Slide 342: Bundle Analysis**
```bash
# Analyze bundle size
npm run bundle:analyze

# Check bundle size
npm run bundle:size
```

**Slide 343: Lazy Loading Screens**
```tsx
import React, { lazy, Suspense } from 'react';

// Lazy load screens
const TaskDetailScreen = lazy(() => import('./screens/TaskDetailScreen'));
const TaskCreateScreen = lazy(() => import('./screens/TaskCreateScreen'));

function App() {
  return (
    <Suspense fallback={<LoadingScreen />}>
      <TaskDetailScreen />
    </Suspense>
  );
}
```

**Slide 344: Tree Shaking**
```javascript
// metro.config.js
module.exports = {
  transformer: {
    minifierConfig: {
      compress: {
        drop_console: true,
        drop_debugger: true,
      },
    },
  },
};
```

**Slide 345: Bundle Optimization Checklist**
- ☐ Enable minification
- ☐ Enable tree shaking
- ☐ Lazy load screens
- ☐ Optimize images
- ☐ Remove unused dependencies
- ☐ Use bundle analysis tools

---

## Module 12: Testing Strategies

### 12.1: Unit Testing (6 slides)

**Slide 346: Jest Setup**
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

**Slide 347: Utility Testing**
```tsx
// Validate email
describe('validateEmail', () => {
  it('returns true for valid emails', () => {
    expect(validateEmail('test@example.com')).toBe(true);
  });
  
  it('returns false for invalid emails', () => {
    expect(validateEmail('invalid')).toBe(false);
  });
});
```

**Slide 348: Hook Testing**
```tsx
import { renderHook, act } from '@testing-library/react-hooks';

describe('useCounter', () => {
  it('increments count', () => {
    const { result } = renderHook(() => useCounter());
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });
});
```

**Slide 349: Async Testing**
```tsx
it('fetches data correctly', async () => {
  const { result, waitForNextUpdate } = renderHook(() => useApi(api.getData));
  
  act(() => {
    result.current.execute();
  });
  
  await waitForNextUpdate();
  
  expect(result.current.data).toEqual(mockData);
  expect(result.current.loading).toBe(false);
});
```

**Slide 350: Mocking Dependencies**
```tsx
jest.mock('@react-native-async-storage/async-storage', () => ({
  setItem: jest.fn(),
  getItem: jest.fn(),
}));

jest.mock('axios', () => ({
  get: jest.fn(),
  post: jest.fn(),
}));
```

**Slide 351: Unit Testing Best Practices**
- Test one thing at a time
- Use descriptive test names
- Mock external dependencies
- Test edge cases
- Keep tests fast
- Aim for high coverage

---

### 12.2: Component Testing (6 slides)

**Slide 352: React Native Testing Library Setup**
```bash
npm install --save-dev @testing-library/react-native @testing-library/jest-native
```

**Slide 353: Basic Component Test**
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

**Slide 354: User Interaction Testing**
```tsx
it('handles text input correctly', () => {
  const onChangeText = jest.fn();
  const { getByPlaceholderText } = render(
    <TaskForm onChangeText={onChangeText} />
  );
  
  const input = getByPlaceholderText('Enter task title');
  fireEvent.changeText(input, 'New Task');
  
  expect(onChangeText).toHaveBeenCalledWith('New Task');
});
```

**Slide 355: Accessibility Testing**
```tsx
it('has accessibility labels', () => {
  const { getByAccessibilityLabel } = render(
    <TaskCard 
      title="Test" 
      accessibilityLabel="Task card" 
      onPress={jest.fn()} 
    />
  );
  
  expect(getByAccessibilityLabel('Task card')).toBeTruthy();
});
```

**Slide 356: Snapshot Testing**
```tsx
it('matches snapshot', () => {
  const tree = render(
    <TaskCard title="Test Task" onPress={jest.fn()} />
  ).toJSON();
  
  expect(tree).toMatchSnapshot();
});
```

**Slide 357: Component Testing Best Practices**
- Test behavior, not implementation
- Use getByText, getByTestId
- Test user interactions
- Test accessibility
- Use snapshot tests wisely
- Keep tests independent

---

### 12.3: E2E Testing (4 slides)

**Slide 358: Detox Setup**
```json
// package.json
{
  "detox": {
    "configurations": {
      "ios.sim.debug": {
        "binaryPath": "ios/build/Build/Products/Debug-iphonesimulator/app.app",
        "build": "xcodebuild -workspace ios/app.xcworkspace -scheme app -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build",
        "type": "ios.simulator",
        "device": {
          "type": "iPhone 14"
        }
      }
    }
  }
}
```

**Slide 359: E2E Test Example**
```tsx
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

**Slide 360: CI/CD Integration**
```yaml
# .github/workflows/e2e.yml
name: E2E Tests
on:
  push:
    branches: [main]
jobs:
  e2e:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run e2e:build
      - run: npm run e2e:test
```

**Slide 361: E2E Testing Best Practices**
- Test critical user flows
- Use realistic test data
- Keep tests independent
- Handle async operations
- Run in CI/CD pipeline

---

### 12.4: Testing Best Practices (4 slides)

**Slide 362: The Testing Pyramid**
```
        ┌─────────────────────────────────────────────────────────────┐
        │                    E2E TESTS                               │
        │                  (Detox / Cypress)                         │
        │  ┌────────────────────────────────────────────────────┐   │
        │  │              INTEGRATION TESTS                     │   │
        │  │         (React Native Testing Library)            │   │
        │  │  ┌────────────────────────────────────────────┐   │   │
        │  │  │          UNIT TESTS                       │   │   │
        │  │  │        (Jest / Testing Library)           │   │   │
        │  │  └────────────────────────────────────────────┘   │   │
        │  └────────────────────────────────────────────────────┘   │
        └─────────────────────────────────────────────────────────────┘
```

**Slide 363: Test Coverage Goals**
- Unit Tests: 80%+
- Component Tests: 70%+
- Integration Tests: 60%+
- E2E Tests: Critical flows only

**Slide 364: Avoiding Test Flakiness**
- Use async/await consistently
- Mock external dependencies
- Use stable test IDs
- Avoid time-based tests
- Run tests in isolation

**Slide 365: Continuous Testing**
- Run tests on every PR
- Block merges on test failures
- Monitor test execution time
- Review test coverage regularly

---

## Module 13: CI/CD & App Store Deployment

### 13.1: EAS Build Configuration (5 slides)

**Slide 366: EAS Build Setup**
```bash
npm install -g eas-cli
eas login
eas build:configure
```

**Slide 367: eas.json Configuration**
```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "channel": "development"
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

**Slide 368: Build Commands**
```bash
eas build --platform ios --profile production
eas build --platform android --profile production
eas build --platform all --profile production
```

**Slide 369: Environment Variables**
```json
{
  "build": {
    "production": {
      "env": {
        "API_URL": "https://api.taskflow.app",
        "SENTRY_DSN": "https://sentry-dsn"
      }
    }
  }
}
```

**Slide 370: EAS Build Best Practices**
- Use separate profiles
- Manage secrets in EAS
- Monitor build times
- Test builds before production
- Automate builds in CI/CD

---

### 13.2: Code Signing (5 slides)

**Slide 371: iOS Code Signing**
1. Apple Developer account
2. Create App ID
3. Create Distribution Certificate
4. Create Provisioning Profile
5. Configure in EAS

**Slide 372: iOS Code Signing Commands**
```bash
eas credentials --platform ios

# Or use EAS to manage automatically
eas build --platform ios --auto-submit
```

**Slide 373: Android Code Signing**
1. Generate keystore
2. Create app signing key
3. Upload to Google Play
4. Configure in EAS

**Slide 374: Android Keystore Generation**
```bash
keytool -genkey -v -keystore app.keystore -alias app -keyalg RSA -keysize 2048 -validity 10000
```

**Slide 375: Code Signing Best Practices**
- Store credentials securely
- Use EAS credentials manager
- Automate signing in CI/CD
- Renew certificates before expiry
- Use separate certificates per app

---

### 13.3: GitHub Actions CI/CD (4 slides)

**Slide 376: CI/CD Workflow**
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

**Slide 377: Automated PR Checks**
```yaml
name: PR Checks
on:
  pull_request:
    branches: [main]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test
```

**Slide 378: Environment Secrets**
```yaml
env:
  EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
  APPLE_ID: ${{ secrets.APPLE_ID }}
  APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
```

**Slide 379: CI/CD Best Practices**
- Run tests on every PR
- Automate builds on main
- Use environment secrets
- Implement rollback strategy
- Monitor build times

---

### 13.4: App Store Submission (5 slides)

**Slide 380: App Store Requirements**

| Requirement | iOS | Android |
|-------------|-----|---------|
| App Icon | ✅ | ✅ |
| Splash Screen | ✅ | ✅ |
| Screenshots | 6.5", 5.5" | Phone, Tablet |
| App Description | ✅ | ✅ |
| Privacy Policy | ✅ | ✅ |
| Support URL | ✅ | ✅ |

**Slide 381: App Store Metadata**
```json
{
  "ios": {
    "name": "TaskFlow",
    "subtitle": "Task Manager",
    "description": "Description...",
    "keywords": "task, productivity",
    "supportUrl": "https://taskflow.app/support"
  },
  "android": {
    "title": "TaskFlow",
    "shortDescription": "Task Manager",
    "fullDescription": "Full description..."
  }
}
```

**Slide 382: Submission Commands**
```bash
# iOS
eas submit --platform ios

# Android
eas submit --platform android

# Auto-submit with build
eas build --platform ios --auto-submit
```

**Slide 383: Store Listing Checklist**
- ☐ App icon and splash screen
- ☐ App screenshots
- ☐ App description
- ☐ Privacy policy
- ☐ Support URL
- ☐ Marketing URL
- ☐ Content rating

**Slide 384: App Store Best Practices**
- Test on multiple devices
- Prepare metadata early
- Follow store guidelines
- Monitor review status
- Respond to feedback

---

### 13.5: Post-Launch Monitoring (4 slides)

**Slide 385: Sentry Setup**
```bash
npx expo install @sentry/react-native
```

**Slide 386: Sentry Configuration**
```tsx
import * as Sentry from '@sentry/react-native';

Sentry.init({
  dsn: process.env.EXPO_PUBLIC_SENTRY_DSN,
  environment: process.env.APP_ENV,
  release: appVersion,
});
```

**Slide 387: Performance Monitoring**
```tsx
// Track performance
Sentry.addBreadcrumb({
  category: 'performance',
  message: 'Screen loaded',
  level: 'info',
});

// Track errors
Sentry.captureException(error);
```

**Slide 388: User Analytics**
```tsx
// Track user events
Analytics.logEvent('task_created', {
  priority: 'high',
  category: 'work',
});

// Track screen views
Analytics.logScreenView({
  screen_name: 'TaskDetail',
  screen_class: 'TaskDetailScreen',
});
```

---

## APPENDICES

### Appendix A: Project Structure Reference (2 slides)

**Slide 389: Complete File Tree**
```
TaskFlow/
├── .env.example                 
├── .eslintrc.js                
├── .gitignore                  
├── .prettierrc                 
├── app.config.js               
├── App.tsx                     
├── babel.config.js             
├── eas.json                    
├── jest.config.js              
├── jest.setup.js               
├── metro.config.js             
├── package.json                
├── tsconfig.json               
├── .github/
│   └── workflows/
│       ├── ci.yml              
│       ├── cd.yml              
│       └── pr-checks.yml       
├── assets/
│   ├── icon.png                
│   ├── adaptive-icon.png       
│   ├── splash.png              
│   └── fonts/                  
├── src/
│   ├── __tests__/              
│   ├── analytics/              
│   ├── components/             
│   ├── config/                 
│   ├── database/               
│   ├── hooks/                  
│   ├── i18n/                   
│   ├── navigation/             
│   ├── offline/                
│   ├── screens/                
│   ├── services/               
│   ├── stores/                 
│   ├── styles/                 
│   ├── types/                  
│   └── utils/                  
├── docs/                       
└── scripts/                    
```

**Slide 390: Naming Conventions**
- **Files:** PascalCase.tsx for components, camelCase.ts for utilities
- **Components:** PascalCase
- **Hooks:** useCamelCase
- **Stores:** camelCaseStore.ts
- **Constants:** UPPER_SNAKE_CASE
- **Types:** IPascalCase or TPrefix

---

### Appendix B: API Integration Guide (2 slides)

**Slide 391: API Client Setup**
```tsx
import axios from 'axios';

const apiClient = axios.create({
  baseURL: API_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

**Slide 392: Authentication Flow**
```tsx
// Login
const login = async (email, password) => {
  const response = await apiClient.post('/auth/login', { email, password });
  const { token, refreshToken, user } = response.data;
  await saveTokens(token, refreshToken);
  return user;
};

// Token refresh
const refreshToken = async () => {
  const refreshToken = await getRefreshToken();
  const response = await apiClient.post('/auth/refresh', { refreshToken });
  const { token } = response.data;
  await saveToken(token);
  return token;
};
```

---

### Appendix C: Design System Component Library (2 slides)

**Slide 393: Core Components**
```tsx
// Button
<Button variant="primary" size="md" onPress={handlePress}>
  Click Me
</Button>

// Input
<Input
  label="Email"
  placeholder="Enter your email"
  error="Invalid email"
  leftIcon={<Icon name="email" />}
/>

// Card
<Card variant="elevated" padding="lg">
  <Text>Card content</Text>
</Card>
```

**Slide 394: Design Tokens**
```tsx
// Colors
const colors = {
  primary: '#3498db',
  secondary: '#2ecc71',
  error: '#e74c3c',
  warning: '#f39c12',
  neutral: { 50: '#fafafa', 500: '#9e9e9e', 900: '#212121' },
};

// Typography
const typography = {
  heading1: { fontSize: 32, fontWeight: 'bold' },
  body1: { fontSize: 16, fontWeight: 'normal' },
};

// Spacing
const spacing = {
  xs: 4, sm: 8, md: 16, lg: 24, xl: 32,
};
```

---

### Appendix D: Security Best Practices (2 slides)

**Slide 395: Secure Storage**
```tsx
import * as SecureStore from 'expo-secure-store';

// Save token securely
await SecureStore.setItemAsync('token', token);

// Load token
const token = await SecureStore.getItemAsync('token');

// Delete token
await SecureStore.deleteItemAsync('token');
```

**Slide 396: Security Checklist**
- ☐ Use SecureStore for tokens
- ☐ Validate all user inputs
- ☐ Use HTTPS for all connections
- ☐ Implement certificate pinning
- ☐ Use JWT with short expiry
- ☐ Implement rate limiting
- ☐ Sanitize API responses
- ☐ Regular security audits

---

### Appendix E: Deployment Troubleshooting (2 slides)

**Slide 397: Common Build Issues**

| Issue | Solution |
|-------|----------|
| iOS build fails | Check Xcode version, pod install, certificates |
| Android build fails | Check Java version, keystore, ANDROID_HOME |
| EAS build fails | Check credentials, environment variables |
| App store rejection | Check guidelines, fix issues, re-submit |

**Slide 398: Performance Bottlenecks**

| Symptom | Cause | Solution |
|---------|-------|----------|
| Slow startup | Large bundle | Lazy load, optimize bundle |
| Janky scrolling | Heavy list | FlatList optimizations |
| High memory | Large images | Optimize images |
| Battery drain | Background processes | Clean up subscriptions |

---

## Final Project

### Final Project: Complete TaskFlow Application

**Slide 399: Project Requirements**
- Full authentication flow
- Task management (CRUD)
- Offline-first with sync
- Push notifications
- Camera & location integration
- Unit and E2E tests
- CI/CD pipeline
- Deployed to app stores

**Slide 400: Grading Criteria**
- Technical implementation (40%)
- UI/UX quality (20%)
- Code quality & testing (20%)
- Performance optimization (10%)
- Deployment to stores (10%)

---

**[END OF SLIDE OUTLINE - 400+ SLIDES]**
