# Mastering Mobile Development Beyond the UI
## Comprehensive Course Slide Outline

Welcome to the complete slide outline for the "Mastering Mobile Development Beyond the UI" tutorial series. This outline is designed for educators, workshop leaders, or self-paced learners who want a structured, comprehensive presentation of the entire course material. Each module includes learning objectives, key concepts, code demonstrations, and practical exercises.

---

## SLIDE DECK OVERVIEW

**Total Modules:** 8 (including Introduction)
**Total Slide Count:** ~350-400 slides
**Estimated Delivery Time:** 30-40 hours (including hands-on labs)
**Target Audience:** React developers, front-end developers transitioning to mobile, full-stack developers
**Prerequisites:** Intermediate JavaScript, React fundamentals, basic REST APIs, Git

---

## MODULE 0: INTRODUCTION & COURSE OVERVIEW

### Section 0.1: Course Welcome (5 slides)

**Slide 0.1: Title Slide**
- Course Title: Mastering Mobile Development Beyond the UI
- Subtitle: Building Enterprise-Grade Mobile Applications with React Native
- Duration: Comprehensive multi-part series
- Instructor Introduction

**Slide 0.2: The Problem with Most Tutorials**
- Most tutorials stop at the UI layer
- Missing: Authentication, offline sync, security, deployment
- The gap between "hello world" and production apps
- Why understanding the full lifecycle matters 

**Slide 0.3: What This Course Covers**
- Native development environments (Xcode, Android Studio)
- React Native integration and architecture
- Hardware APIs (camera, GPS, biometrics)
- Offline-first data persistence and sync
- Mobile security (OWASP Top 10)
- Testing (unit, component, E2E)
- CI/CD and app store deployment
- Production monitoring and analytics

**Slide 0.4: What You Will Build**
- Application name: NexusCollect
- Field data collection platform
- Offline-first architecture
- Custom form builder
- Real-time sync with Supabase
- Biometric authentication
- Push notifications
- Full CI/CD pipeline

**Slide 0.5: Target Audience & Prerequisites**
- Target Audience: React developers, front-end engineers, full-stack developers
- Prerequisites:
  - Intermediate JavaScript (ES6+)
  - React fundamentals
  - RESTful APIs
  - Git version control
  - Command-line proficiency
- Prior mobile experience: Beneficial but not required

---

### Section 0.2: Architecture Overview (8 slides)

**Slide 0.6: The Complete Architecture Diagram**
```
┌─────────────────────────────────────────────────────────────┐
│                   CLIENT: React Native Mobile App           │
│         (iOS & Android from a single TypeScript codebase)  │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │   UI     │  │  State   │  │  Native  │                 │
│  │  Layer   │  │  Mgmt    │  │   APIs   │                 │
│  │  React   │  │ Zustand  │  │ Camera   │                 │
│  │  Nav     │  │ TanStack │  │  GPS     │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │  Local   │  │ Security │  │ Offline  │                 │
│  │ Database │  │ Encrypt  │  │  Sync    │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
└─────────────────────────────────────────────────────────────┘
                               │
                         HTTPS / WebSocket
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND: Supabase Platform               │
│          (PostgreSQL + Auth + Storage + Realtime)          │
└─────────────────────────────────────────────────────────────┘
                               │
                          CI/CD Pipeline
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               DEPLOYMENT & DISTRIBUTION                    │
│      Apple App Store  │  Google Play Store  │  EAS/OTA     │
└─────────────────────────────────────────────────────────────┘
```

**Slide 0.7: Technology Stack Overview**
- **Core Framework:** React Native + Expo
- **Language:** TypeScript
- **Navigation:** React Navigation
- **State Management:** Zustand
- **Data:** WatermelonDB (local) + Supabase (cloud)
- **Testing:** Jest, React Native Testing Library, Detox
- **Deployment:** EAS Build, Fastlane
- **Monitoring:** Sentry

**Slide 0.8: Why This Stack?**
| Technology | Why This Choice |
|------------|-----------------|
| React Native | Industry standard, huge ecosystem |
| TypeScript | Reduces bugs, improves maintainability |
| Expo | Simplifies build process, OTA updates |
| Zustand | Simple, performant, minimal boilerplate |
| Supabase | PostgreSQL, built-in auth, real-time |
| WatermelonDB | High-performance, reactive, sync-ready |

**Slide 0.9: Learning Philosophy**
- Code-heavy, never abstract
- No placeholders like `// implement this part`
- Every line of code shown and explained
- Beginner-friendly language, expert code quality
- Each step builds directly on the previous
- Verification steps for every implementation

**Slide 0.10: Series Structure Overview**
| Part | Title | Estimated Hours | Difficulty |
|------|-------|-----------------|------------|
| 0 | Introduction | 1 hour | Beginner |
| 1 | Native Foundations | 3-4 hours | Intermediate |
| 2 | Project Architecture | 2-3 hours | Beginner |
| 3 | Backend Integration | 3-4 hours | Intermediate |
| 4 | Data Management | 4-5 hours | Advanced |
| 5 | Hardware Integration | 3-4 hours | Advanced |
| 6 | Testing & QA | 3-4 hours | Intermediate |
| 7 | Security & Deployment | 4-5 hours | Advanced |

**Slide 0.11: Course Resources**
- GitHub repository with complete source code
- Detailed primers for each topic
- Environment setup guides
- Troubleshooting documentation
- Community support channels

**Slide 0.12: Getting Started Checklist**
- [ ] Install Node.js (v18+)
- [ ] Install Git
- [ ] Install Xcode (macOS users)
- [ ] Install Android Studio
- [ ] Create Supabase account
- [ ] Create GitHub account
- [ ] Prepare code editor (VS Code recommended)
- [ ] Install React Native extensions

---

## MODULE 1: NATIVE FOUNDATIONS & BUILD ENVIRONMENTS

### Section 1.1: Understanding Native Platforms (10 slides)

**Slide 1.1: Module Overview**
- Module 1: Native Foundations & Build Environments
- Learning Objectives:
  - Understand mobile platform architecture
  - Set up professional development environments
  - Configure code signing and certificates
  - Create native modules in Swift and Kotlin

**Slide 1.2: Mobile Platform Architecture**
- iOS Architecture: UIKit, Swift, Cocoa Touch
- Android Architecture: Android Framework, Kotlin/Java
- Key components: Application lifecycle, Activity/ViewController
- Native SDKs and their role

**Slide 1.3: The Application Lifecycle (iOS vs Android)**
| iOS | Android |
|-----|---------|
| Not running | Terminated |
| Inactive | Created |
| Active | Started |
| Background | Resumed |
| Suspended | Paused |
| | Stopped |

**Slide 1.4: React Native's Integration Layer**
- JavaScript thread vs Native thread
- The Bridge (legacy architecture)
- JSI (JavaScript Interface - New Architecture)
- Fabric Renderer
- TurboModules 

**Slide 1.5: Development Tooling Overview**
- **iOS:** Xcode, Simulator, CocoaPods, Swift Package Manager
- **Android:** Android Studio, Emulator, Gradle
- **Cross-platform:** Node.js, Watchman, Metro Bundler

**Slide 1.6: Setting Up Xcode (macOS)**
1. Install Xcode from Mac App Store (~12GB)
2. Install Command Line Tools: `xcode-select --install`
3. Accept license agreement: `sudo xcodebuild -license accept`
4. Install CocoaPods: `sudo gem install cocoapods`
5. Verify: `pod --version`
6. Launch Simulator: `open -a Simulator`

**Slide 1.7: Setting Up Android Studio**
1. Download from developer.android.com/studio
2. Choose "Custom" installation
3. Install Android SDK Platform 33+
4. Install Intel HAXM (hardware acceleration)
5. Set environment variable: `ANDROID_HOME`
6. Add to PATH: `$ANDROID_HOME/emulator`, `$ANDROID_HOME/platform-tools`

**Slide 1.8: Setting Up Environment Variables (macOS)**
```bash
# Add to ~/.zshrc or ~/.bash_profile
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

**Slide 1.9: Creating an Android Emulator**
1. Open Android Studio → More Actions → AVD Manager
2. Create Virtual Device
3. Select device (e.g., Pixel 6)
4. Select system image (API 33)
5. Click Next and Finish
6. Test with: `emulator -list-avds`

**Slide 1.10: Verification Checklist**
- [ ] Xcode installed (macOS only)
- [ ] Command Line Tools installed
- [ ] CocoaPods installed
- [ ] Android Studio installed
- [ ] SDK Platform installed
- [ ] Environment variables set
- [ ] Emulator created

---

### Section 1.2: React Native Project Setup (12 slides)

**Slide 1.11: Expo vs React Native CLI**
| Feature | Expo | React Native CLI |
|---------|------|------------------|
| Setup time | 10 minutes | 2+ hours |
| Native modules | Easy via plugins | Manual setup |
| Builds | EAS handles it | Manual config |
| OTA updates | Built-in | Manual implementation |
| Learning curve | Gentle | Steep |
| Customization | Limited to plugins | Full control |

**Slide 1.12: Creating the Project**
```bash
# Install Expo CLI
npm install -g expo-cli

# Create project with TypeScript
npx create-expo-app NexusCollect --template

# Navigate to project
cd NexusCollect

# Install additional packages
npm install react-native-safe-area-context react-native-screens
npm install -D @types/react @types/react-native
```

**Slide 1.13: Understanding the Project Structure**
```
nexuscollect/
├── android/        # Native Android project
├── ios/            # Native iOS project
├── app/            # Expo Router app directory
├── assets/         # Static assets
├── package.json    # Dependencies
├── tsconfig.json   # TypeScript config
└── app.json        # Expo config
```

**Slide 1.14: Installing iOS Dependencies**
```bash
# For iOS (macOS only)
cd ios
pod install
cd ..
```

**Slide 1.15: Verifying the Setup**
```bash
# Start development server
npx expo start

# Press 'i' for iOS simulator
# Press 'a' for Android emulator
# Press 'w' for web browser

# Expected: "Welcome to Expo" screen
```

**Slide 1.16: TypeScript Configuration**
```json
// tsconfig.json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@screens/*": ["./src/screens/*"],
      "@utils/*": ["./src/utils/*"]
    }
  }
}
```

**Slide 1.17: Creating the Source Directory**
```bash
# Create source folders
mkdir -p src/components
mkdir -p src/screens
mkdir -p src/utils
mkdir -p src/types
mkdir -p src/navigation
mkdir -p src/store
mkdir -p src/api
mkdir -p src/hooks
mkdir -p src/constants
mkdir -p src/database
mkdir -p src/themes
mkdir -p src/services
```

**Slide 1.18: Path Aliases with Babel**
```javascript
// babel.config.js
plugins: [
  [
    'module-resolver',
    {
      root: ['./src'],
      alias: {
        '@': './src',
        '@components': './src/components',
        '@screens': './src/screens',
        '@utils': './src/utils',
        '@types': './src/types',
        '@navigation': './src/navigation',
        '@store': './src/store',
        '@api': './src/api',
        '@hooks': './src/hooks',
        '@constants': './src/constants',
        '@database': './src/database',
        '@themes': './src/themes',
        '@services': './src/services',
      }
    }
  ]
]
```

**Slide 1.19: Running on iOS Simulator**
```bash
# Start with iOS
npx expo start --ios

# Or press 'i' in Metro

# Verify Simulator launched
xcrun simctl list devices --json
```

**Slide 1.20: Running on Android Emulator**
```bash
# Start emulator from Android Studio
# Then run:
npx expo start --android

# Or press 'a' in Metro

# Verify device connected
adb devices
```

**Slide 1.21: Running on Physical Devices**
**iOS:**
1. Connect iPhone via USB
2. Set bundle identifier in app.json
3. `npx expo run:ios --device`

**Android:**
1. Enable Developer Mode
2. Enable USB Debugging
3. Connect via USB
4. `npx expo start --tunnel`

**Slide 1.22: Verification: Project Setup**
- [ ] Project created with Expo
- [ ] TypeScript configured
- [ ] iOS app runs (macOS)
- [ ] Android app runs
- [ ] Path aliases working
- [ ] Physical device testing works

---

### Section 1.3: Native Modules (8 slides)

**Slide 1.23: Understanding the Bridge**
- JavaScript and Native run on separate threads
- The Bridge serializes messages between them
- Async communication
- New Architecture: JSI enables direct calls

**Slide 1.24: Native Module Overview**
- Why Native Modules?
  - Access platform-specific features
  - Performance-critical operations
  - Reuse existing native libraries
- **iOS:** Swift/Objective-C
- **Android:** Kotlin/Java

**Slide 1.25: Creating an iOS Native Module (Swift)**

**DeviceInfoModule.swift:**
```swift
import Foundation
import React

@objc(DeviceInfoModule)
class DeviceInfoModule: NSObject, RCTBridgeModule {
  static func moduleName() -> String! {
    return "DeviceInfoModule"
  }
  
  @objc(getDeviceInfo:rejecter:)
  func getDeviceInfo(_ resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
    let device = UIDevice.current
    let deviceInfo: [String: Any] = [
      "model": device.model,
      "systemName": device.systemName,
      "systemVersion": device.systemVersion
    ]
    resolve(deviceInfo)
  }
}
```

**DeviceInfoModule.h:**
```objc
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(DeviceInfoModule, NSObject)
RCT_EXTERN_METHOD(getDeviceInfo:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end
```

**Slide 1.26: Creating an Android Native Module (Kotlin)**

**DeviceInfoModule.kt:**
```kotlin
package com.yourcompany.nexuscollect

import android.os.Build
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class DeviceInfoModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {
    
    override fun getName(): String = "DeviceInfoModule"
    
    @ReactMethod
    fun getDeviceInfo(promise: Promise) {
        val deviceInfo = HashMap<String, Any>()
        deviceInfo["model"] = Build.MODEL
        deviceInfo["manufacturer"] = Build.MANUFACTURER
        deviceInfo["version"] = Build.VERSION.RELEASE
        promise.resolve(deviceInfo)
    }
}
```

**DeviceInfoPackage.kt:**
```kotlin
class DeviceInfoPackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext)
        : List<NativeModule> {
        return listOf(DeviceInfoModule(reactContext))
    }
}
```

**Slide 1.27: Registering the Android Module**
```kotlin
// MainApplication.kt
override fun getPackages(): List<ReactPackage> =
    PackageList(this).packages.apply {
        add(DeviceInfoPackage())
    }
```

**Slide 1.28: Using Native Modules in JavaScript**
```typescript
import { NativeModules } from 'react-native';

const { DeviceInfoModule } = NativeModules;

// Call the native method
DeviceInfoModule.getDeviceInfo()
  .then(info => console.log(info))
  .catch(error => console.error(error));
```

**Slide 1.29: Verification: Native Modules**
- [ ] iOS module created
- [ ] Android module created
- [ ] Module registered
- [ ] iOS pod install run
- [ ] Device info displays correctly
- [ ] Both platforms working

**Slide 1.30: Module Summary**
- Native modules bridge JavaScript to native
- iOS uses Swift/Objective-C
- Android uses Kotlin/Java
- Register modules in respective platforms
- Call from JavaScript using `NativeModules`

---

### Section 1.4: Build Signing & Distribution (10 slides)

**Slide 1.31: Code Signing Overview**
- Apple: Provisioning profiles, certificates
- Android: Keystores, signing configs
- Development vs Distribution signing
- Why signing matters: App integrity, trust

**Slide 1.32: iOS Code Signing**
1. Generate CSR in Keychain Access
2. Create Certificate in Apple Developer Portal
3. Create App ID with bundle identifier
4. Create Provisioning Profile
5. Configure in Xcode

**Slide 1.33: iOS Configuration in Xcode**
1. Open `ios/NexusCollect.xcworkspace`
2. Select project → Signing & Capabilities
3. Check "Automatically manage signing"
4. Select team
5. No signing errors = success

**Slide 1.34: Android Keystore Setup**
```bash
# Generate keystore
keytool -genkey -v -keystore ~/.android/keystores/nexuscollect-release.keystore \
  -alias nexuscollect-release \
  -keyalg RSA -keysize 2048 -validity 10000

# You'll be prompted for:
# - Password (remember this!)
# - Your name
# - Organizational unit
# - Organization
# - City, State, Country
```

**Slide 1.35: Android Keystore Configuration**
```properties
# android/gradle.properties
NEXUSCOLLECT_RELEASE_STORE_FILE=nexuscollect-release.keystore
NEXUSCOLLECT_RELEASE_STORE_PASSWORD=your_keystore_password
NEXUSCOLLECT_RELEASE_KEY_ALIAS=nexuscollect-release
NEXUSCOLLECT_RELEASE_KEY_PASSWORD=your_key_password
```

**Slide 1.36: Build Variants**
| Variant | Purpose |
|---------|---------|
| Debug | Development, unoptimized |
| Release | Production, optimized |
| Custom | Staging, internal testing |

**Slide 1.37: New Architecture Overview**
- **Old Architecture:** Bridge (serialized messages)
- **New Architecture:** JSI (direct calls)
- **Key Components:**
  - TurboModules (lazy-loaded)
  - Fabric Renderer
  - Hermes Engine

**Slide 1.38: Enabling New Architecture**
**iOS Podfile:**
```ruby
use_react_native!(
  :hermes_enabled => true,
  :fabric_enabled => true,
)
```

**Android:**
```properties
# gradle.properties
newArchEnabled=true
hermesEnabled=true
```

**Slide 1.39: Module 1 Summary**
- Set up complete native development environment
- Created React Native project with TypeScript
- Built native modules for iOS and Android
- Configured code signing
- Enabled New Architecture

**Slide 1.40: Verification: Build Signing**
- [ ] iOS certificate created
- [ ] Provisioning profile configured
- [ ] Android keystore generated
- [ ] Build variants understood
- [ ] New Architecture enabled
- [ ] Clean build succeeds

---

## MODULE 2: PROJECT ARCHITECTURE & CORE SETUP

### Section 2.1: Architecture Design (10 slides)

**Slide 2.1: Module Overview**
- Module 2: Project Architecture & Core Setup
- Learning Objectives:
  - Design application architecture
  - Set up navigation system
  - Implement state management
  - Build theme and styling system

**Slide 2.2: Separation of Concerns**
```
┌─────────────────────────────────────────┐
│          UI LAYER (Components)          │
├─────────────────────────────────────────┤
│       STATE LAYER (Zustand Stores)      │
├─────────────────────────────────────────┤
│     DATA LAYER (Services/APIs)          │
├─────────────────────────────────────────┤
│     NAVIGATION LAYER (React Nav)        │
└─────────────────────────────────────────┘
```

**Slide 2.3: Architecture Principles**
1. **Separation of Concerns:** Each layer has specific responsibility
2. **Unidirectional Data Flow:** Action → Store → Service → Store → UI
3. **Dependency Injection:** Services injected where needed
4. **Testability:** Each layer independently testable

**Slide 2.4: Complete Architecture Flow**
```
User Action → Component → Store/Service → API → Backend
                      ↓
UI Update ← Component ← Store ← Response
```

**Slide 2.5: Folder Structure Deep Dive**
```
src/
├── api/          # API clients and services
├── components/   # Reusable UI components
├── screens/      # Screen components
├── navigation/   # Navigation configuration
├── store/        # Zustand stores
├── hooks/        # Custom React hooks
├── database/     # WatermelonDB schema/models
├── services/     # Business logic services
├── utils/        # Helpers and utilities
├── types/        # TypeScript definitions
├── themes/       # Theme system
└── constants/    # App constants
```

**Slide 2.6: Understanding the Data Flow**
1. **User Interaction:** User taps button
2. **Action Dispatched:** Component calls store action
3. **API Request:** Store calls service API
4. **Response Processed:** Service returns data
5. **State Updated:** Store updates state
6. **UI Re-renders:** Component displays new data

**Slide 2.7: Architecture Documentation**
```typescript
// src/constants/architecture.ts
export const ARCHITECTURE = {
  layers: ['UI', 'State', 'Data', 'Navigation', 'Utility'],
  dataFlow: 'Unidirectional (Action → Store → Service → API → Store → UI)',
  persistence: {
    auth: 'SecureStore',
    preferences: 'AsyncStorage',
    appData: 'WatermelonDB',
  },
} as const;
```

**Slide 2.8: Complete Folder Creation**
```bash
mkdir -p src/api/{interceptors,services}
mkdir -p src/components/{common,forms,navigation,layouts}
mkdir -p src/screens/{auth,main,settings,diagnostics}
mkdir -p src/navigation/{stacks,tabs}
mkdir -p src/store/{slices,persistence}
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/types
mkdir -p src/constants
mkdir -p src/themes
mkdir -p src/assets/{images,fonts}
mkdir -p src/lib
mkdir -p src/database/{models,repositories,sync}
```

**Slide 2.9: Verification: Architecture Setup**
- [ ] Folder structure created
- [ ] Architecture documented
- [ ] Data flow understood
- [ ] Layers defined

**Slide 2.10: Module Section Complete**
- Architecture established
- Data flow defined
- Folder structure created

---

### Section 2.2: Navigation System (12 slides)

**Slide 2.11: Navigation Dependencies**
```bash
# Core navigation
npm install @react-navigation/native @react-navigation/native-stack
npm install @react-navigation/bottom-tabs @react-navigation/drawer

# Native dependencies
npm install react-native-screens react-native-safe-area-context
npm install react-native-gesture-handler react-native-reanimated

# iOS: Install pods
cd ios && pod install && cd ..
```

**Slide 2.12: Navigation Architecture**
```
┌─────────────────────────────────────┐
│        Root Navigator               │
│   (Splash → Auth/Main)              │
├─────────────────────────────────────┤
│              │                       │
│   Auth Stack │   Main Stack         │
│   Login      │   Main Tabs          │
│   Register   │   │                  │
│   ForgotPwd  │   ├─ Dashboard       │
│              │   ├─ Forms           │
│              │   ├─ Collections     │
│              │   ├─ Profile         │
│              │   └─ Settings        │
└─────────────────────────────────────┘
```

**Slide 2.13: Navigation Types**
```typescript
// src/types/navigation.ts
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  Onboarding: undefined;
};

export type MainTabParamList = {
  Dashboard: undefined;
  Forms: undefined;
  Collections: undefined;
  Profile: undefined;
  Settings: undefined;
};

export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  Splash: undefined;
};
```

**Slide 2.14: Auth Stack Implementation**
```typescript
// src/navigation/stacks/AuthStack.tsx
const Stack = createNativeStackNavigator<AuthStackParamList>();

export const AuthStack = () => {
  return (
    <Stack.Navigator
      initialRouteName="Login"
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
      }}
    >
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Register" component={RegisterScreen} />
      <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </Stack.Navigator>
  );
};
```

**Slide 2.15: Main Tabs Implementation**
```typescript
// src/navigation/tabs/MainTabs.tsx
const Tab = createBottomTabNavigator<MainTabParamList>();

export const MainTabs = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          // Return appropriate icon based on route
        },
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.gray,
      })}
    >
      <Tab.Screen name="Dashboard" component={DashboardScreen} />
      <Tab.Screen name="Forms" component={FormsScreen} />
      <Tab.Screen name="Collections" component={CollectionsScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
};
```

**Slide 2.16: Root Navigator Implementation**
```typescript
// src/navigation/RootNavigator.tsx
export const RootNavigator = () => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <Stack.Screen name="Main" component={MainTabs} />
        ) : (
          <Stack.Screen name="Auth" component={AuthStack} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

**Slide 2.17: Navigation Verification**
- [ ] Navigation installed
- [ ] Types defined
- [ ] Auth stack created
- [ ] Main tabs created
- [ ] Root navigator implemented
- [ ] Navigation works between screens

**Slide 2.18: Deep Linking Setup**
```typescript
// src/navigation/linking.ts
export const linking = {
  prefixes: ['nexuscollect://', 'https://nexuscollect.com'],
  config: {
    screens: {
      Main: {
        screens: {
          Dashboard: 'dashboard',
          Collections: 'collections',
          Profile: 'profile/:userId',
        },
      },
      Auth: {
        screens: {
          Login: 'login',
          Register: 'register',
        },
      },
    },
  },
};
```

**Slide 2.19: Navigation Utilities**
```typescript
// src/hooks/useDeepLinking.ts
export const useDeepLinking = () => {
  const navigation = useRootNavigation();

  useEffect(() => {
    const handleDeepLink = (url: string) => {
      // Parse and navigate to appropriate screen
    };

    const subscription = Linking.addEventListener('url', ({ url }) => {
      handleDeepLink(url);
    });

    return () => subscription.remove();
  }, [navigation]);
};
```

**Slide 2.20: Navigation Best Practices**
1. Use TypeScript for type safety
2. Define all param lists
3. Use navigation hooks
4. Handle deep linking
5. Implement auth-aware navigation
6. Use proper nesting

**Slide 2.21: Verification: Navigation**
- [ ] Type-safe navigation
- [ ] Auth flow works
- [ ] Tab navigation works
- [ ] Deep linking prepared

**Slide 2.22: Module Section Complete**
- Navigation system built
- Auth flow implemented
- Deep linking configured

---

### Section 2.3: State Management with Zustand (12 slides)

**Slide 2.23: Why Zustand?**
| Feature | Zustand | Redux | Context API |
|---------|---------|-------|-------------|
| Boilerplate | Minimal | Heavy | Moderate |
| Learning Curve | Easy | Steep | Easy |
| Performance | Excellent | Good | Moderate |
| Size | 1KB | 40KB | Built-in |
| Dev Tools | ✅ | ✅ | Limited |

**Slide 2.24: Zustand Installation**
```bash
npm install zustand
npm install @react-native-async-storage/async-storage
npm install expo-secure-store
```

**Slide 2.25: Auth Store**
```typescript
// src/store/slices/authSlice.ts
interface AuthStore extends AuthState {
  setUser: (user: User | null) => void;
  setAuthenticated: (isAuthenticated: boolean) => void;
  logout: () => void;
  updateUser: (userData: Partial<User>) => void;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
      
      setUser: (user) => set({ user }),
      setAuthenticated: (isAuthenticated) => set({ isAuthenticated }),
      
      logout: () => {
        set({ user: null, isAuthenticated: false });
        secureStorage.removeItem('auth-storage');
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

**Slide 2.26: Secure Storage Adapter**
```typescript
// src/store/persistence/storage.ts
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
```

**Slide 2.27: Settings Store**
```typescript
// src/store/slices/settingsSlice.ts
interface SettingsStore {
  settings: AppSettings;
  updateSettings: (newSettings: Partial<AppSettings>) => void;
  toggleTheme: (theme: 'light' | 'dark' | 'system') => void;
  toggleNotifications: (type: keyof Notifications) => void;
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      settings: defaultSettings,
      
      toggleTheme: (theme) =>
        set((state) => ({
          settings: { ...state.settings, theme },
        })),
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**Slide 2.28: Form Store**
```typescript
// src/store/slices/formSlice.ts
interface FormStore {
  forms: CollectionForm[];
  currentForm: CollectionForm | null;
  isLoading: boolean;
  
  setForms: (forms: CollectionForm[]) => void;
  setCurrentForm: (form: CollectionForm | null) => void;
  addForm: (form: CollectionForm) => void;
  updateForm: (formId: string, updates: Partial<CollectionForm>) => void;
  deleteForm: (formId: string) => void;
}

export const useFormStore = create<FormStore>((set, get) => ({
  forms: [],
  currentForm: null,
  isLoading: false,
  
  addForm: (form) =>
    set((state) => ({
      forms: [...state.forms, form],
    })),
}));
```

**Slide 2.29: Combined Store Export**
```typescript
// src/store/index.ts
export { useAuthStore } from './slices/authSlice';
export { useSettingsStore } from './slices/settingsSlice';
export { useFormStore } from './slices/formSlice';

export const useAppStore = <T>(
  selector: (state: {
    auth: ReturnType<typeof useAuthStore>;
    settings: ReturnType<typeof useSettingsStore>;
    forms: ReturnType<typeof useFormStore>;
  }) => T
): T => {
  const auth = useAuthStore();
  const settings = useSettingsStore();
  const forms = useFormStore();
  return selector({ auth, settings, forms });
};
```

**Slide 2.30: Using Zustand in Components**
```typescript
function UserProfile() {
  // Select specific state
  const user = useAuthStore((state) => state.user);
  
  // Select multiple with shallow
  const { user, isAuthenticated } = useAuthStore(
    (state) => ({
      user: state.user,
      isAuthenticated: state.isAuthenticated,
    }),
    shallow
  );
  
  // Get actions
  const { logout, updateUser } = useAuthStore();
  
  return <View>...</View>;
}
```

**Slide 2.31: Verification: State Management**
- [ ] Auth store created
- [ ] Settings store created
- [ ] Form store created
- [ ] Persistence configured
- [ ] State updates work

**Slide 2.32: Module Section Complete**
- Complete state management system built
- Secure persistence implemented
- Stores integrated with components

---

### Section 2.4: Theme & Styling System (10 slides)

**Slide 2.33: Theme System Overview**
- Centralized color palette
- Typography system
- Spacing system
- Light/Dark theme support

**Slide 2.34: Color System**
```typescript
// src/themes/colors.ts
export const colors = {
  primary: {
    50: '#e8f4fd',
    100: '#d1e9fb',
    500: '#2196F3',
    600: '#1a78c2',
    900: '#071e31',
  },
  secondary: {
    50: '#fce8e6',
    500: '#E74C3C',
  },
  gray: {
    50: '#f8f9fa',
    500: '#adb5bd',
    900: '#212529',
  },
  success: '#2ECC71',
  warning: '#F39C12',
  error: '#E74C3C',
  background: '#ffffff',
  text: '#212529',
  border: '#dee2e6',
};
```

**Slide 2.35: Typography System**
```typescript
// src/themes/typography.ts
export const typography = {
  fontFamily: Platform.select({
    ios: 'System',
    android: 'Roboto',
    default: 'System',
  }),
  fontSize: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 18,
    xl: 20,
    xxl: 24,
    xxxl: 32,
  },
  weight: {
    light: '300',
    regular: '400',
    medium: '500',
    bold: '700',
  },
};
```

**Slide 2.36: Spacing System**
```typescript
// src/themes/spacing.ts
export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};
```

**Slide 2.37: Theme Provider**
```typescript
// src/themes/index.ts
const ThemeContext = createContext<Theme>(lightTheme);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const theme = useSettingsStore((state) => state.settings.theme);
  const currentTheme = theme === 'dark' ? darkTheme : lightTheme;
  
  return (
    <ThemeContext.Provider value={currentTheme}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};
```

**Slide 2.38: Creating Themed Styles**
```typescript
export const createThemedStyles = <T extends StyleSheet.NamedStyles<T>>(
  styles: (theme: Theme) => T
) => {
  return (theme: Theme) => StyleSheet.create(styles(theme));
};

// Usage
const useStyles = createThemedStyles((theme) => ({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
    padding: theme.spacing.md,
  },
  title: {
    fontSize: theme.typography.fontSize.xl,
    color: theme.colors.text,
  },
}));
```

**Slide 2.39: Base Components**
```typescript
// src/components/common/Button.tsx
const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  loading = false,
  disabled = false,
  style,
}) => {
  const theme = useTheme();
  
  const getVariantStyles = () => {
    switch (variant) {
      case 'primary':
        return {
          backgroundColor: theme.colors.primary[500],
          textColor: '#ffffff',
        };
      case 'outline':
        return {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: theme.colors.primary[500],
          textColor: theme.colors.primary[500],
        };
      // ...
    }
  };
  
  return <TouchableOpacity>...</TouchableOpacity>;
};
```

**Slide 2.40: Card Component**
```typescript
// src/components/common/Card.tsx
export const Card: React.FC<CardProps> = ({
  children,
  elevation = true,
  padding = 'md',
  style,
}) => {
  const theme = useTheme();
  
  return (
    <View
      style={[
        {
          backgroundColor: theme.components.card.backgroundColor,
          borderRadius: theme.components.card.borderRadius,
          padding: theme.spacing[padding],
        },
        elevation && styles.shadow,
        style,
      ]}
    >
      {children}
    </View>
  );
};
```

**Slide 2.41: Verification: Theme System**
- [ ] Colors defined
- [ ] Typography defined
- [ ] Spacing defined
- [ ] Theme provider working
- [ ] Base components created

**Slide 2.42: Module 2 Summary**
- Built complete architecture
- Created navigation system
- Implemented Zustand state management
- Created theme and styling system
- Built base UI components

---

## MODULE 3: BACKEND INTEGRATION & AUTHENTICATION

### Section 3.1: Supabase Setup (8 slides)

**Slide 3.1: Module Overview**
- Module 3: Backend Integration & Authentication
- Learning Objectives:
  - Configure Supabase backend
  - Implement authentication (email, social)
  - Set up Row Level Security
  - Manage user sessions

**Slide 3.2: Why Supabase?**
- Open-source Firebase alternative
- PostgreSQL database (not NoSQL)
- Built-in authentication
- Real-time subscriptions
- Row Level Security
- Storage for files
- Edge functions

**Slide 3.3: Supabase Project Setup**
1. Go to app.supabase.com
2. Click "New Project"
3. Project name: `nexuscollect`
4. Set database password
5. Choose region
6. Wait for initialization

**Slide 3.4: Database Schema**
```sql
-- Profiles table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Forms table
CREATE TABLE public.forms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  fields JSONB NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Collections table
CREATE TABLE public.collections (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  form_id UUID REFERENCES public.forms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  data JSONB NOT NULL,
  location JSONB,
  photos TEXT[],
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Slide 3.5: Row Level Security (RLS)**
```sql
-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view their own forms"
  ON public.forms FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own forms"
  ON public.forms FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**Slide 3.6: Supabase Client Setup**
```typescript
// src/api/supabase.ts
import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { CONFIG } from '@constants/config';

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

export const supabase = createClient(
  CONFIG.supabase.url,
  CONFIG.supabase.anonKey,
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

**Slide 3.7: Environment Variables**
```env
# .env.development
API_URL=http://localhost:3000
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ENVIRONMENT=development
LOG_LEVEL=debug

# .env.production
API_URL=https://api.nexuscollect.com
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ENVIRONMENT=production
LOG_LEVEL=error
```

**Slide 3.8: Verification: Supabase Setup**
- [ ] Supabase project created
- [ ] Tables created
- [ ] RLS policies configured
- [ ] Client configured
- [ ] Environment variables set

---

### Section 3.2: Authentication Flow (12 slides)

**Slide 3.9: Authentication Service**
```typescript
// src/api/services/authService.ts
export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData extends LoginCredentials {
  fullName: string;
}

export const authService = {
  login: async (credentials: LoginCredentials) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    });
    
    if (error) throw new Error(error.message);
    if (!data.user) throw new Error('Login failed');
    
    return {
      user: {
        id: data.user.id,
        email: data.user.email!,
        fullName: data.user.user_metadata?.full_name,
      },
      session: data.session,
    };
  },

  register: async (data: RegisterData) => {
    const { data: authData, error } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: { full_name: data.fullName },
      },
    });
    
    if (error) throw new Error(error.message);
    return authData;
  },
};
```

**Slide 3.10: Login Screen Implementation**
```typescript
// src/screens/auth/LoginScreen.tsx
function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({ email: '', password: '' });
  const { login, isLoading, error } = useAuth();
  const navigation = useNavigation();

  const validate = () => {
    let isValid = true;
    const newErrors = { email: '', password: '' };
    
    if (!email) {
      newErrors.email = 'Email is required';
      isValid = false;
    } else if (!email.includes('@')) {
      newErrors.email = 'Invalid email';
      isValid = false;
    }
    
    if (!password) {
      newErrors.password = 'Password is required';
      isValid = false;
    }
    
    setErrors(newErrors);
    return isValid;
  };

  const handleLogin = async () => {
    if (!validate()) return;
    await login(email, password);
  };

  return (
    <View>
      <Input
        label="Email"
        value={email}
        onChangeText={setEmail}
        error={errors.email}
        placeholder="you@example.com"
        autoCapitalize="none"
      />
      <Input
        label="Password"
        value={password}
        onChangeText={setPassword}
        error={errors.password}
        secureTextEntry
      />
      {error && <Text style={{ color: theme.colors.error }}>{error}</Text>}
      <Button title="Sign In" onPress={handleLogin} loading={isLoading} />
      <TouchableOpacity onPress={() => navigation.navigate('Register')}>
        <Text>Don't have an account? Sign Up</Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Slide 3.11: Register Screen**
```typescript
// src/screens/auth/RegisterScreen.tsx
function RegisterScreen() {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [errors, setErrors] = useState({});
  const { register, isLoading } = useAuth();
  const navigation = useNavigation();

  const validate = () => {
    const newErrors = {};
    // Validate full name, email, password, confirm
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleRegister = async () => {
    if (!validate()) return;
    await register(formData.email, formData.password, formData.fullName);
  };

  return (
    <View>
      <Input
        label="Full Name"
        value={formData.fullName}
        onChangeText={(text) => setFormData({ ...formData, fullName: text })}
        error={errors.fullName}
      />
      <Input
        label="Email"
        value={formData.email}
        onChangeText={(text) => setFormData({ ...formData, email: text })}
        error={errors.email}
        autoCapitalize="none"
      />
      <Input
        label="Password"
        value={formData.password}
        onChangeText={(text) => setFormData({ ...formData, password: text })}
        error={errors.password}
        secureTextEntry
      />
      <Input
        label="Confirm Password"
        value={formData.confirmPassword}
        onChangeText={(text) => setFormData({ ...formData, confirmPassword: text })}
        error={errors.confirmPassword}
        secureTextEntry
      />
      <Button title="Create Account" onPress={handleRegister} loading={isLoading} />
      <TouchableOpacity onPress={() => navigation.navigate('Login')}>
        <Text>Already have an account? Sign In</Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Slide 3.12: Forgot Password Screen**
```typescript
// src/screens/auth/ForgotPasswordScreen.tsx
function ForgotPasswordScreen() {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const navigation = useNavigation();

  const handleReset = async () => {
    setIsLoading(true);
    try {
      await authService.resetPassword(email);
      setSuccess(true);
    } catch (error) {
      Alert.alert('Error', error.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View>
      <Text style={styles.title}>Reset Password</Text>
      <Text style={styles.subtitle}>
        Enter your email and we'll send you a reset link
      </Text>
      <Input
        value={email}
        onChangeText={setEmail}
        placeholder="you@example.com"
        autoCapitalize="none"
      />
      <Button
        title="Send Reset Link"
        onPress={handleReset}
        loading={isLoading}
        disabled={!email}
      />
      {success && (
        <Text style={styles.successText}>
          Reset link sent! Check your email.
        </Text>
      )}
      <TouchableOpacity onPress={() => navigation.goBack()}>
        <Text>Back to Sign In</Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Slide 3.13: Social Login (Google)**
```typescript
// src/screens/auth/LoginScreen.tsx - Social Login
import * as Google from 'expo-auth-session/providers/google';

const [googleRequest, googleResponse, googlePromptAsync] = Google.useAuthRequest({
  expoClientId: 'your-google-expo-client-id',
  iosClientId: 'your-google-ios-client-id',
  androidClientId: 'your-google-android-client-id',
});

const handleGoogleLogin = async () => {
  try {
    const result = await googlePromptAsync();
    if (result?.type === 'success') {
      const { access_token, id_token } = result.params;
      const { data, error } = await supabase.auth.signInWithIdToken({
        provider: 'google',
        token: id_token,
        access_token: access_token,
      });
      if (error) throw error;
    }
  } catch (error) {
    Alert.alert('Error', 'Google login failed');
  }
};
```

**Slide 3.14: Social Login (Apple)**
```typescript
// src/screens/auth/LoginScreen.tsx - Apple Login
import * as Apple from 'expo-auth-session/providers/apple';

const [appleRequest, appleResponse, applePromptAsync] = Apple.useAuthRequest({
  clientId: 'com.yourcompany.nexuscollect',
  redirectUri: 'nexuscollect://apple-callback',
  scopes: ['email', 'name'],
});

const handleAppleLogin = async () => {
  try {
    const result = await applePromptAsync();
    if (result?.type === 'success') {
      const { id_token } = result.params;
      const { data, error } = await supabase.auth.signInWithIdToken({
        provider: 'apple',
        token: id_token,
      });
      if (error) throw error;
    }
  } catch (error) {
    Alert.alert('Error', 'Apple login failed');
  }
};
```

**Slide 3.15: Auth Hook**
```typescript
// src/hooks/useAuth.ts
export const useAuth = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const authState = useAuthStore();

  const initializeAuth = async () => {
    try {
      const session = await authService.getSession();
      if (session) {
        const { data } = await supabase.auth.getUser();
        if (data.user) {
          authState.setUser({
            id: data.user.id,
            email: data.user.email!,
            fullName: data.user.user_metadata?.full_name,
          });
          authState.setAuthenticated(true);
        }
      }
    } catch (error) {
      console.error('Auth initialization error:', error);
    }
  };

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await authService.login({ email, password });
      authState.setUser(response.user);
      authState.setAuthenticated(true);
      return { success: true };
    } catch (err: any) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (email: string, password: string, fullName: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await authService.register({ email, password, fullName });
      // Auto-login after registration
      return await login(email, password);
    } catch (err: any) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    try {
      await authService.logout();
      authState.logout();
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  return {
    ...authState,
    isLoading,
    error,
    initializeAuth,
    login,
    register,
    logout,
  };
};
```

**Slide 3.16: Protecting Routes**
```typescript
// src/navigation/RootNavigator.tsx
export const RootNavigator = () => {
  const { isAuthenticated, isLoading, initializeAuth } = useAuth();
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const init = async () => {
      await initializeAuth();
      setIsReady(true);
    };
    init();
  }, []);

  if (!isReady || isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <Stack.Screen name="Main" component={MainTabs} />
        ) : (
          <Stack.Screen name="Auth" component={AuthStack} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

**Slide 3.17: Verification: Authentication**
- [ ] Login works
- [ ] Registration works
- [ ] Password reset works
- [ ] Social login works
- [ ] Session persists
- [ ] Auth state initializes
- [ ] Routes protected

**Slide 3.18: Module 3 Summary**
- Configured Supabase backend
- Implemented full authentication flow
- Added social login support
- Set up session management
- Protected routes with auth guard

---

## MODULE 4: DATA MANAGEMENT & OFFLINE SYNC

### Section 4.1: Local Database Setup (10 slides)

**Slide 4.1: Module Overview**
- Module 4: Data Management & Offline Sync
- Learning Objectives:
  - Set up WatermelonDB
  - Build database schema and models
  - Implement offline-first architecture
  - Build sync engine

**Slide 4.2: Why Offline-First?**
- Users don't always have internet
- Offline-first = better UX
- Data must sync automatically
- Resilient to network issues
- Reduced server load

**Slide 4.3: Why WatermelonDB?**
| Feature | WatermelonDB | SQLite | Realm |
|---------|--------------|--------|-------|
| Performance | ⚡ Excellent | Good | Good |
| Reactive | ✅ Built-in | ❌ Manual | ✅ |
| Sync Engine | ✅ Built-in | ❌ Manual | ✅ |
| TypeScript | ✅ Full | Limited | Good |
| Size | Small | Small | Large |

**Slide 4.4: Installation**
```bash
npm install @nozbe/watermelondb @nozbe/with-observables
npm install expo-sqlite
npm install react-native-reanimated
npm install -D @nozbe/watermelondb-devtools
cd ios && pod install && cd ..
```

**Slide 4.5: Database Schema**
```typescript
// src/database/schema.ts
export const schema = appSchema({
  version: 1,
  tables: [
    // Users table
    tableSchema({
      name: 'users',
      columns: [
        { name: 'email', type: 'string' },
        { name: 'full_name', type: 'string' },
        { name: 'avatar_url', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),
    
    // Forms table
    tableSchema({
      name: 'forms',
      columns: [
        { name: 'title', type: 'string' },
        { name: 'description', type: 'string', isOptional: true },
        { name: 'fields', type: 'string' }, // JSON string
        { name: 'user_id', type: 'string' },
        { name: 'is_public', type: 'boolean' },
        { name: 'is_template', type: 'boolean' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'sync_status', type: 'string' },
        { name: 'is_deleted', type: 'boolean' },
      ],
    }),
    
    // Collections table
    tableSchema({
      name: 'collections',
      columns: [
        { name: 'form_id', type: 'string' },
        { name: 'user_id', type: 'string' },
        { name: 'data', type: 'string' }, // JSON string
        { name: 'location_lat', type: 'number', isOptional: true },
        { name: 'location_lng', type: 'number', isOptional: true },
        { name: 'photos', type: 'string', isOptional: true },
        { name: 'status', type: 'string' },
        { name: 'synced_at', type: 'number', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'sync_status', type: 'string' },
        { name: 'is_deleted', type: 'boolean' },
      ],
    }),
    
    // Sync Queue
    tableSchema({
      name: 'sync_queue',
      columns: [
        { name: 'operation', type: 'string' },
        { name: 'table_name', type: 'string' },
        { name: 'record_id', type: 'string' },
        { name: 'data', type: 'string' },
        { name: 'status', type: 'string' },
        { name: 'retry_count', type: 'number' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),
  ],
});
```

**Slide 4.6: Database Models**
```typescript
// src/database/models/Form.ts
import { Model } from '@nozbe/watermelondb';
import { field, text, date, readonly, json } from '@nozbe/watermelondb/decorators';

export default class FormModel extends Model {
  static table = 'forms';

  @text('title') title!: string;
  @text('description') description?: string;
  @json('fields') fields!: FormField[];
  @text('user_id') userId!: string;
  @field('is_public') isPublic!: boolean;
  @text('sync_status') syncStatus!: string;
  
  @readonly @date('created_at') createdAt!: number;
  @readonly @date('updated_at') updatedAt!: number;
}
```

**Slide 4.7: Database Initialization**
```typescript
// src/database/index.ts
import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import { schema } from './schema';
import FormModel from './models/Form';
import CollectionModel from './models/Collection';
import SyncQueueModel from './models/SyncQueue';

const models = [FormModel, CollectionModel, SyncQueueModel];

const adapter = new SQLiteAdapter({
  schema,
  dbName: 'NexusCollectDB',
  // encryptionKey: 'your-encryption-key', // Optional
});

export const database = new Database({
  adapter,
  modelClasses: models,
  actionsEnabled: true,
});

export const dbUtils = {
  clearAll: async () => {
    await database.write(async () => {
      const collections = await database.get('collections').query().fetch();
      await Promise.all(collections.map(c => c.destroyPermanently()));
    });
  },
};
```

**Slide 4.8: Repository Pattern**
```typescript
// src/database/repositories/FormRepository.ts
export class FormRepository {
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

  static async create(userId: string, formData: any): Promise<FormModel> {
    return await database.write(async () => {
      return await database
        .get<FormModel>('forms')
        .create(record => {
          record.userId = userId;
          record.title = formData.title;
          record.description = formData.description || '';
          record.fields = formData.fields;
          record.syncStatus = 'pending';
          record.isPublic = false;
        });
    });
  }

  static async markSynced(id: string): Promise<void> {
    await database.write(async () => {
      const form = await database.get<FormModel>('forms').find(id);
      await form.update(record => {
        record.syncStatus = 'synced';
      });
    });
  }
}
```

**Slide 4.9: Collection Repository**
```typescript
// src/database/repositories/CollectionRepository.ts
export class CollectionRepository {
  static async create(
    userId: string,
    data: { formId: string; data: any; location?: any; photos?: string[] }
  ): Promise<CollectionModel> {
    return await database.write(async () => {
      return await database
        .get<CollectionModel>('collections')
        .create(record => {
          record.userId = userId;
          record.formId = data.formId;
          record.data = data.data;
          record.photos = data.photos || [];
          record.status = 'draft';
          record.syncStatus = 'pending';
          if (data.location) {
            record.locationLat = data.location.latitude;
            record.locationLng = data.location.longitude;
          }
        });
    });
  }

  static async getUnsynced(userId: string): Promise<CollectionModel[]> {
    return await database
      .get<CollectionModel>('collections')
      .query(
        Q.where('user_id', userId),
        Q.where('sync_status', Q.notEq('synced')),
        Q.where('is_deleted', false)
      )
      .fetch();
  }
}
```

**Slide 4.10: Verification: Local Database**
- [ ] WatermelonDB installed
- [ ] Schema defined
- [ ] Models created
- [ ] Database initialized
- [ ] Repositories working
- [ ] CRUD operations work

---

### Section 4.2: Sync Engine (10 slides)

**Slide 4.11: Sync Architecture**
```
┌─────────────────────────────────────────────────────────┐
│                     Sync Engine                         │
├─────────────────────────────────────────────────────────┤
│  1. Network Check → 2. Pull Changes → 3. Process       │
│  4. Push Changes → 5. Handle Conflicts → 6. Cleanup    │
└─────────────────────────────────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
         ┌──────────┐ ┌──────────┐ ┌──────────┐
         │  Local   │ │  API     │ │  Queue   │
         │ Database │ │  Server  │ │          │
         └──────────┘ └──────────┘ └──────────┘
```

**Slide 4.12: Sync Engine Implementation**
```typescript
// src/database/sync/SyncEngine.ts
export class SyncEngine {
  private isSyncing = false;
  private syncInterval: NodeJS.Timeout | null = null;
  private isNetworkAvailable = true;

  constructor() {
    NetInfo.addEventListener(state => {
      const wasAvailable = this.isNetworkAvailable;
      this.isNetworkAvailable = state.isConnected && state.isInternetReachable;
      if (!wasAvailable && this.isNetworkAvailable) {
        this.sync();
      }
    });
  }

  start(intervalMinutes: number = 5): void {
    this.sync();
    this.syncInterval = setInterval(() => this.sync(), intervalMinutes * 60 * 1000);
    console.log(`Sync engine started (interval: ${intervalMinutes} minutes)`);
  }

  stop(): void {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
    }
  }

  async sync(): Promise<SyncResult> {
    if (this.isSyncing) return { success: false, itemsProcessed: 0, itemsFailed: 0 };
    if (!this.isNetworkAvailable) return { success: false, itemsProcessed: 0, itemsFailed: 0 };

    const user = useAuthStore.getState().user;
    if (!user) return { success: false, itemsProcessed: 0, itemsFailed: 0 };

    this.isSyncing = true;
    let itemsProcessed = 0;
    let itemsFailed = 0;

    try {
      // Upload pending items
      const uploadResult = await this.uploadPendingItems(user.id);
      itemsProcessed += uploadResult.processed;
      itemsFailed += uploadResult.failed;

      // Download latest data
      const downloadResult = await this.downloadLatestData(user.id);
      itemsProcessed += downloadResult.processed;
      itemsFailed += downloadResult.failed;

      // Clean up
      await SyncQueueRepository.cleanupOld();
    } catch (error) {
      console.error('Sync failed:', error);
    } finally {
      this.isSyncing = false;
    }

    return { success: itemsFailed === 0, itemsProcessed, itemsFailed };
  }

  private async uploadPendingItems(userId: string) {
    const pendingItems = await SyncQueueRepository.getPending();
    let processed = 0, failed = 0;

    for (const item of pendingItems) {
      try {
        await SyncQueueRepository.markProcessing(item.id);
        await this.processSyncItem(item, userId);
        await SyncQueueRepository.markCompleted(item.id);
        processed++;
      } catch (error) {
        await SyncQueueRepository.markFailed(item.id, error.message);
        failed++;
      }
    }

    return { processed, failed };
  }

  private async downloadLatestData(userId: string) {
    let processed = 0, failed = 0;

    try {
      // Download forms
      const { data: forms, error: formsError } = await supabase
        .from('forms')
        .select('*')
        .eq('user_id', userId);

      if (formsError) throw formsError;

      // Download collections
      const { data: collections, error: collectionsError } = await supabase
        .from('collections')
        .select('*')
        .eq('user_id', userId);

      if (collectionsError) throw collectionsError;

      // Update local database
      await database.write(async () => {
        // Upsert forms
        if (forms) {
          for (const form of forms) {
            const existing = await database.get('forms').find(form.id).catch(() => null);
            if (existing) {
              await existing.update(record => {
                record.title = form.title;
                record.description = form.description || '';
                record.fields = form.fields;
              });
            } else {
              await database.get('forms').create(record => {
                record.id = form.id;
                record.userId = form.user_id;
                record.title = form.title;
                record.description = form.description || '';
                record.fields = form.fields;
                record.syncStatus = 'synced';
              });
            }
          }
        }

        // Upsert collections similarly
      });

      processed = (forms?.length || 0) + (collections?.length || 0);
    } catch (error) {
      console.error('Download failed:', error);
      failed++;
    }

    return { processed, failed };
  }
}

export const syncEngine = new SyncEngine();
```

**Slide 4.13: Sync Queue Manager**
```typescript
// src/database/sync/SyncQueueManager.ts
export class SyncQueueManager {
  static async enqueue(
    operation: 'create' | 'update' | 'delete',
    tableName: string,
    recordId: string,
    data: any
  ) {
    await database.write(async () => {
      await database
        .get<SyncQueueModel>('sync_queue')
        .create(record => {
          record.operation = operation;
          record.tableName = tableName;
          record.recordId = recordId;
          record.data = data;
          record.status = 'pending';
          record.retryCount = 0;
        });
    });
  }

  static async markProcessing(id: string) {
    await database.write(async () => {
      const item = await database.get<SyncQueueModel>('sync_queue').find(id);
      await item.update(record => {
        record.status = 'processing';
        record.lastAttempt = Date.now();
      });
    });
  }

  static async markCompleted(id: string) {
    await database.write(async () => {
      const item = await database.get<SyncQueueModel>('sync_queue').find(id);
      await item.update(record => {
        record.status = 'completed';
        record.processedAt = Date.now();
      });
    });
  }

  static async markFailed(id: string, error: string) {
    await database.write(async () => {
      const item = await database.get<SyncQueueModel>('sync_queue').find(id);
      await item.update(record => {
        record.status = 'failed';
        record.errorMessage = error;
        record.retryCount += 1;
        if (record.retryCount < 5) {
          record.status = 'pending';
          record.nextRetryAt = Date.now() + (2 ** record.retryCount) * 1000;
        }
      });
    });
  }
}
```

**Slide 4.14: Auto-Sync Hook**
```typescript
// src/hooks/useAutoSync.ts
export const useAutoSync = () => {
  const { user } = useAuth();
  const { isActive } = useAppState();

  useEffect(() => {
    if (isActive && user) {
      syncEngine.sync();
    }
  }, [isActive, user]);

  useEffect(() => {
    const interval = setInterval(() => {
      if (isActive && user) {
        syncEngine.sync();
      }
    }, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, [isActive, user]);
};
```

**Slide 4.15: Conflict Resolution**
```typescript
// src/database/sync/ConflictResolver.ts
export class ConflictResolver {
  static resolve(server: any, local: any): any {
    // Last write wins
    if (server.updated_at > local.updated_at) {
      return server;
    }
    return local;
  }

  static merge(server: any, local: any): any {
    // Merge fields
    return {
      ...local,
      ...server,
      // Keep local edits
      local_edits: local.local_edits || [],
    };
  }

  static detectConflicts(server: any, local: any): Conflict[] {
    const conflicts = [];
    // Check for conflicting edits
    return conflicts;
  }
}
```

**Slide 4.16: Verification: Offline Sync**
- [ ] Sync engine starts
- [ ] Offline entries saved
- [ ] Auto-sync on network restore
- [ ] Conflict resolution works
- [ ] Queue processes correctly
- [ ] Retry logic works

**Slide 4.17: Module 4 Summary**
- Built offline-first architecture
- Configured WatermelonDB
- Implemented sync engine
- Added conflict resolution
- Auto-sync on network changes

---

## MODULE 5: DEVICE HARDWARE INTEGRATION

### Section 5.1: Camera Integration (8 slides)

**Slide 5.1: Module Overview**
- Module 5: Device Hardware Integration
- Learning Objectives:
  - Integrate camera and photo gallery
  - Implement GPS location tracking
  - Add biometric authentication
  - Configure push notifications

**Slide 5.2: Camera Installation**
```bash
npm install expo-camera expo-image-picker expo-media-library
npm install react-native-image-crop-picker
npm install react-native-fs
cd ios && pod install && cd ..
```

**Slide 5.3: Camera Service**
```typescript
// src/services/CameraService.ts
export class CameraService {
  private static instance: CameraService;

  static getInstance(): CameraService {
    if (!CameraService.instance) {
      CameraService.instance = new CameraService();
    }
    return CameraService.instance;
  }

  async capturePhoto(options?: { quality?: number; base64?: boolean }) {
    const hasPermission = await this.requestCameraPermissions();
    if (!hasPermission) return null;

    const result = await ImagePicker.launchCameraAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: options?.quality || 0.8,
      base64: options?.base64 || true,
    });

    if (result.canceled || !result.assets[0]) return null;

    const asset = result.assets[0];
    const fileName = `photo_${generateSecureId(8)}_${Date.now()}.jpg`;
    const localUri = await this.savePhotoLocally(asset.uri, fileName);

    return {
      uri: localUri,
      width: asset.width,
      height: asset.height,
      base64: asset.base64,
      fileName,
    };
  }

  async pickFromGallery(options?: { selectionLimit?: number }) {
    const hasPermission = await this.requestMediaLibraryPermissions();
    if (!hasPermission) return [];

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 0.8,
      base64: true,
      selectionLimit: options?.selectionLimit || 1,
    });

    if (result.canceled) return [];
    return result.assets.map(asset => ({ /* ... */ }));
  }
}
```

**Slide 5.4: Camera Screen Component**
```typescript
// src/screens/main/CameraScreen.tsx
export default function CameraScreen() {
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [cameraType, setCameraType] = useState<CameraType>('back');
  const [flashMode, setFlashMode] = useState(false);
  const [capturedPhotos, setCapturedPhotos] = useState<PhotoResult[]>([]);
  const cameraRef = useRef<Camera>(null);
  const navigation = useNavigation();
  const route = useRoute();
  const { returnTo, maxPhotos = 10 } = route.params;

  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  const takePhoto = async () => {
    if (!cameraRef.current || capturedPhotos.length >= maxPhotos) return;
    
    const photo = await cameraRef.current.takePictureAsync({
      quality: 0.8,
      base64: true,
      exif: true,
    });
    
    const savedPhoto = await cameraService.savePhotoLocally(
      photo.uri,
      `photo_${Date.now()}.jpg`
    );
    
    setCapturedPhotos(prev => [...prev, { uri: savedPhoto, ...photo }]);
  };

  const finishCapture = () => {
    navigation.navigate(returnTo, {
      photos: capturedPhotos.map(p => p.uri),
    });
  };

  return (
    <View style={{ flex: 1 }}>
      <Camera ref={cameraRef} style={{ flex: 1 }} type={cameraType} flashMode={flashMode ? 'on' : 'off'} />
      <View style={styles.controls}>
        <TouchableOpacity onPress={() => setFlashMode(!flashMode)}>
          <Ionicons name={flashMode ? 'flash' : 'flash-off'} size={28} color="#fff" />
        </TouchableOpacity>
        <TouchableOpacity onPress={takePhoto} style={styles.captureButton}>
          <View style={styles.captureButtonInner} />
        </TouchableOpacity>
        <TouchableOpacity onPress={() => setCameraType(cameraType === 'back' ? 'front' : 'back')}>
          <Ionicons name="camera-reverse" size={28} color="#fff" />
        </TouchableOpacity>
      </View>
      <TouchableOpacity style={styles.finishButton} onPress={finishCapture}>
        <Text>Finish ({capturedPhotos.length} photos)</Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Slide 5.5: Verification: Camera**
- [ ] Camera permissions requested
- [ ] Photo capture works
- [ ] Gallery pick works
- [ ] Photos saved locally
- [ ] Flash toggle works
- [ ] Front/back camera works

**Slide 5.6: Module Section Complete**
- Camera integration complete
- Photo capture and storage working
- Gallery access implemented

---

### Section 5.2: Location Services (6 slides)

**Slide 5.7: Location Installation**
```bash
npm install expo-location
```

**Slide 5.8: Location Service**
```typescript
// src/services/LocationService.ts
export class LocationService {
  private static instance: LocationService;
  private currentLocation: LocationData | null = null;
  private locationSubscription: any = null;

  static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }

  async getCurrentLocation(): Promise<LocationData | null> {
    const hasPermission = await this.requestLocationPermissions();
    if (!hasPermission) return null;

    const location = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.High,
      timeout: 10000,
    });

    this.currentLocation = {
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      accuracy: location.coords.accuracy,
      timestamp: location.timestamp,
    };
    return this.currentLocation;
  }

  async startTracking(callback: (location: LocationData) => void) {
    const hasPermission = await this.requestLocationPermissions();
    if (!hasPermission) return false;

    this.locationSubscription = await Location.watchPositionAsync(
      {
        accuracy: Location.Accuracy.Balanced,
        distanceInterval: 1,
        timeInterval: 5000,
      },
      (location) => {
        const locationData = {
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
          accuracy: location.coords.accuracy,
          timestamp: location.timestamp,
        };
        this.currentLocation = locationData;
        callback(locationData);
      }
    );
    return true;
  }

  async reverseGeocode(lat: number, lng: number) {
    const results = await Location.reverseGeocodeAsync({ latitude: lat, longitude: lng });
    if (results.length === 0) return null;
    return {
      address: results[0].name || '',
      city: results[0].city || '',
      country: results[0].country || '',
      formattedAddress: `${results[0].name}, ${results[0].city}, ${results[0].country}`,
    };
  }

  calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371;
    const dLat = this.toRadians(lat2 - lat1);
    const dLng = this.toRadians(lng2 - lng1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2);
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }
}
```

**Slide 5.9: LocationPicker Component**
```typescript
// src/components/common/LocationPicker.tsx
export const LocationPicker: React.FC<LocationPickerProps> = ({
  value,
  onChange,
  onError,
}) => {
  const [isLoading, setIsLoading] = useState(false);
  const [address, setAddress] = useState('');

  const getCurrentLocation = async () => {
    try {
      setIsLoading(true);
      const location = await locationService.getCurrentLocation();
      if (location) {
        onChange(location);
        const geocode = await locationService.reverseGeocode(location.latitude, location.longitude);
        if (geocode) setAddress(geocode.formattedAddress);
      }
    } catch (error) {
      if (onError) onError('Failed to get location');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View>
      <TouchableOpacity style={styles.button} onPress={getCurrentLocation} disabled={isLoading}>
        {isLoading ? <ActivityIndicator /> : <Text>Get Current Location</Text>}
      </TouchableOpacity>
      {value && (
        <Text style={styles.coordinates}>
          {value.latitude.toFixed(6)}, {value.longitude.toFixed(6)}
          {address && <Text> - {address}</Text>}
        </Text>
      )}
    </View>
  );
};
```

**Slide 5.10: Verification: Location**
- [ ] Location permissions requested
- [ ] Current location acquired
- [ ] Location tracking works
- [ ] Reverse geocoding works
- [ ] Distance calculation works

---

### Section 5.3: Biometric Authentication (6 slides)

**Slide 5.11: Biometric Installation**
```bash
npm install expo-local-authentication
```

**Slide 5.12: Biometric Service**
```typescript
// src/services/BiometricService.ts
export class BiometricService {
  private static instance: BiometricService;

  static getInstance(): BiometricService {
    if (!BiometricService.instance) {
      BiometricService.instance = new BiometricService();
    }
    return BiometricService.instance;
  }

  async checkAvailability() {
    const [hasHardware, hasEnrolled, supportedTypes] = await Promise.all([
      LocalAuthentication.hasHardwareAsync(),
      LocalAuthentication.isEnrolledAsync(),
      LocalAuthentication.supportedAuthenticationTypesAsync(),
    ]);

    return {
      isAvailable: hasHardware && hasEnrolled,
      hardwareAvailable: hasHardware,
      enrolledLevel: hasEnrolled ? 1 : 0,
      supportedTypes: supportedTypes.map(type => {
        switch (type) {
          case LocalAuthentication.AuthenticationType.FINGERPRINT:
            return 'Fingerprint';
          case LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION:
            return 'Face Recognition';
          default:
            return 'Unknown';
        }
      }),
    };
  }

  async authenticate(config?: { title: string; subtitle?: string }) {
    const availability = await this.checkAvailability();
    if (!availability.isAvailable) {
      Alert.alert('Biometric Not Available', 'Please set up biometric authentication in your device settings.');
      return false;
    }

    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: config?.title || 'Authenticate to access NexusCollect',
      fallbackLabel: 'Use Passcode',
      cancelLabel: 'Cancel',
      disableDeviceFallback: false,
      requireConfirmation: true,
    });

    return result.success;
  }

  async performSecureAction<T>(action: () => Promise<T>, config?: { title: string }): Promise<T | null> {
    const authenticated = await this.authenticate(config);
    if (!authenticated) return null;
    return await action();
  }
}
```

**Slide 5.13: Biometric Hook**
```typescript
// src/hooks/useBiometric.ts
export const useBiometric = () => {
  const [isAvailable, setIsAvailable] = useState(false);
  const [biometricType, setBiometricType] = useState('');
  const settings = useSettingsStore();

  useEffect(() => {
    checkBiometricAvailability();
  }, []);

  const checkBiometricAvailability = async () => {
    const availability = await biometricService.checkAvailability();
    setIsAvailable(availability.isAvailable);
    setBiometricType(availability.supportedTypes[0] || 'Biometric');
  };

  const authenticate = useCallback(async (): Promise<boolean> => {
    if (!settings.settings.privacy.biometricAuth) {
      Alert.alert('Biometric Disabled', 'Please enable biometric authentication in settings.');
      return false;
    }
    return await biometricService.authenticate({
      title: `Use ${biometricType}`,
    });
  }, [settings.settings.privacy.biometricAuth, biometricType]);

  const secureAction = useCallback(
    async <T>(action: () => Promise<T>): Promise<T | null> => {
      return await biometricService.performSecureAction(action, {
        title: 'Authentication Required',
      });
    },
    []
  );

  return {
    isAvailable,
    biometricType,
    authenticate,
    secureAction,
    checkBiometricAvailability,
  };
};
```

**Slide 5.14: Verification: Biometric**
- [ ] Biometric availability checked
- [ ] Authentication works
- [ ] Settings toggle works
- [ ] Secure actions protected

---

### Section 5.4: Push Notifications (6 slides)

**Slide 5.15: Notification Installation**
```bash
npm install expo-notifications
```

**Slide 5.16: Notification Service**
```typescript
// src/services/NotificationService.ts
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import Constants from 'expo-constants';

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export class NotificationService {
  private static instance: NotificationService;
  private pushToken: string | null = null;

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  async initialize(): Promise<void> {
    const { status } = await Notifications.requestPermissionsAsync();
    if (status !== 'granted') return;

    if (!Device.isDevice) return;

    const projectId = Constants.expoConfig?.extra?.eas?.projectId;
    if (!projectId) return;

    const token = await Notifications.getExpoPushTokenAsync({ projectId });
    this.pushToken = token.data;
    await this.registerTokenWithBackend(token.data);

    this.setupNotificationListeners();
  }

  private setupNotificationListeners(): void {
    Notifications.addNotificationReceivedListener((notification) => {
      console.log('Notification received:', notification);
    });

    Notifications.addNotificationResponseReceivedListener((response) => {
      const data = response.notification.request.content.data;
      this.handleDeepLink(data);
    });
  }

  private handleDeepLink(data: any): void {
    if (!data) return;
    const { screen, params } = data;
    // Navigate to appropriate screen
  }

  async sendNotification(recipient: string, payload: any): Promise<void> {
    const message = {
      to: recipient,
      title: payload.title,
      body: payload.body,
      data: payload.data || {},
      sound: 'default',
      badge: 1,
    };
    await fetch('https://exp.host/--/api/v2/push/send', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    });
  }
}
```

**Slide 5.17: Notification Hook**
```typescript
// src/hooks/useNotifications.ts
export const useNotifications = () => {
  const [isEnabled, setIsEnabled] = useState(false);
  const [pushToken, setPushToken] = useState<string | null>(null);

  useEffect(() => {
    initializeNotifications();
  }, []);

  const initializeNotifications = async () => {
    await notificationService.initialize();
    const token = notificationService.getPushToken();
    setPushToken(token);
    const enabled = await notificationService.areNotificationsEnabled();
    setIsEnabled(enabled);
  };

  const sendNotification = async (recipient: string, payload: any) => {
    return await notificationService.sendNotification(recipient, payload);
  };

  return {
    isEnabled,
    pushToken,
    sendNotification,
    requestPermissions: notificationService.requestPermissions,
  };
};
```

**Slide 5.18: Verification: Notifications**
- [ ] Permissions requested
- [ ] Push token acquired
- [ ] Notification received in foreground
- [ ] Notification received in background
- [ ] Deep linking works

**Slide 5.19: Module 5 Summary**
- Camera integration complete
- Location services implemented
- Biometric authentication working
- Push notifications configured

---

## MODULE 6: TESTING & QUALITY ASSURANCE

### Section 6.1: Testing Strategy (10 slides)

**Slide 6.1: Module Overview**
- Module 6: Testing & Quality Assurance
- Learning Objectives:
  - Implement unit testing with Jest
  - Add component testing with React Native Testing Library
  - Configure E2E testing with Detox
  - Set up CI/CD pipeline 

**Slide 6.2: Testing Pyramid**
```
        /\
       /  \      E2E Tests (User journeys)
      /    \     Integration Tests (Multiple components)
     /______\    Unit Tests (Individual units)
```

**Slide 6.3: Installation**
```bash
npm install -D jest @types/jest ts-jest
npm install -D @testing-library/react-native @testing-library/jest-native
npm install -D react-test-renderer
npm install -D detox jest-jasmine2
```

**Slide 6.4: Jest Configuration**
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

**Slide 6.5: Unit Testing Example**
```typescript
// __tests__/unit/utils/validation.test.ts
describe('Validation Utilities', () => {
  describe('validateEmail', () => {
    it('should return true for valid emails', () => {
      expect(validateEmail('test@example.com')).toBe(true);
      expect(validateEmail('user.name@domain.co')).toBe(true);
    });

    it('should return false for invalid emails', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('test@example')).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('should validate password strength', () => {
      expect(validatePassword('Password123!')).toBe(true);
      expect(validatePassword('Pass1!')).toBe(false);
      expect(validatePassword('Password123')).toBe(false);
    });
  });
});
```

**Slide 6.6: Component Testing Example**
```typescript
// __tests__/components/Button.test.tsx
describe('Button Component', () => {
  it('renders correctly', () => {
    render(<Button title="Click Me" onPress={jest.fn()} />);
    expect(screen.getByText('Click Me')).toBeTruthy();
  });

  it('handles press events', () => {
    const onPress = jest.fn();
    render(<Button title="Click Me" onPress={onPress} />);
    fireEvent.press(screen.getByText('Click Me'));
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('disables button when disabled', () => {
    const onPress = jest.fn();
    render(<Button title="Click Me" onPress={onPress} disabled />);
    fireEvent.press(screen.getByText('Click Me'));
    expect(onPress).not.toHaveBeenCalled();
  });
});
```

**Slide 6.7: Integration Testing**
```typescript
// __tests__/integration/authStore.test.ts
describe('Auth Store', () => {
  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
  });

  it('should handle login flow', async () => {
    (authService.login as jest.Mock).mockResolvedValue({
      user: mockUser,
      session: mockSession,
    });

    const { login } = useAuthStore.getState();
    await login('test@example.com', 'password');

    const state = useAuthStore.getState();
    expect(state.user).toEqual(mockUser);
    expect(state.isAuthenticated).toBe(true);
  });
});
```

**Slide 6.8: E2E Testing with Detox**
```typescript
// e2e/auth.e2e.js
describe('Authentication Flow', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
  });

  it('should show login screen', async () => {
    await expect(element(by.text('Welcome Back'))).toBeVisible();
  });

  it('should login successfully', async () => {
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.id('passwordInput')).typeText('Password123!');
    await element(by.text('Sign In')).tap();
    await waitFor(element(by.text('Dashboard')))
      .toBeVisible()
      .withTimeout(10000);
  });
});
```

**Slide 6.9: Code Quality Tools**
```bash
# ESLint
npm install -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
npm install -D prettier eslint-config-prettier eslint-plugin-prettier
npm install -D husky lint-staged

# Configuration
.eslintrc.js
.prettierrc.js
.husky/pre-commit
.husky/pre-push
```

**Slide 6.10: Verification: Testing**
- [ ] Jest configured
- [ ] Unit tests pass
- [ ] Component tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Coverage >= 70%

---

### Section 6.2: CI/CD Pipeline (8 slides)

**Slide 6.11: CI/CD Overview**
```
┌─────────────────────────────────────────────────────────────┐
│                      CI/CD PIPELINE                         │
│                                                             │
│  1. Code Commit → 2. Build → 3. Test → 4. Deploy          │
│                                                             │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐│
│  │  Push    │   │  Build   │   │  Test    │   │  Deploy  ││
│  │  Code    │ → │  App     │ → │  Suite   │ → │  Store   ││
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘│
└─────────────────────────────────────────────────────────────┘
```

**Slide 6.12: GitHub Actions Workflow**
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:ci

  build:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
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

**Slide 6.13: EAS Build Configuration**
```json
// eas.json
{
  "cli": {
    "version": ">= 3.0.0"
  },
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
      "channel": "production",
      "autoIncrement": true,
      "android": {
        "buildType": "app-bundle"
      },
      "ios": {
        "buildConfiguration": "Release"
      },
      "env": {
        "ENVIRONMENT": "production",
        "LOG_LEVEL": "error"
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your-apple-id",
        "ascAppId": "your-app-id",
        "appleTeamId": "your-team-id"
      },
      "android": {
        "serviceAccountKeyPath": "path/to/service-account-key.json",
        "track": "production"
      }
    }
  }
}
```

**Slide 6.14: Verification: CI/CD**
- [ ] GitHub Actions workflow created
- [ ] EAS Build configured
- [ ] Automated tests run in CI
- [ ] Production builds created
- [ ] Deployment automated

**Slide 6.15: Module 6 Summary**
- Comprehensive testing suite
- Unit, component, integration, E2E
- Code quality tools
- CI/CD pipeline configured

---

## MODULE 7: SECURITY HARDENING & PRODUCTION DEPLOYMENT

### Section 7.1: Security Hardening (12 slides)

**Slide 7.1: Module Overview**
- Module 7: Security Hardening & Production Deployment
- Learning Objectives:
  - Implement OWASP Mobile Top 10 controls
  - Configure production signing
  - Build for app stores
  - Set up OTA updates
  - Deploy to production

**Slide 7.2: OWASP Mobile Top 10**
1. Improper Platform Usage
2. Insecure Data Storage
3. Insecure Communication
4. Insecure Authentication
5. Insufficient Cryptography
6. Insecure Authorization
7. Client Code Quality
8. Code Tampering
9. Reverse Engineering
10. Extraneous Functionality

**Slide 7.3: Code Obfuscation**
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

**Slide 7.4: Data Encryption**
```typescript
// src/utils/encryption.ts
export class EncryptionService {
  private encryptionKey: string | null = null;

  async initialize() {
    let key = await SecureStore.getItemAsync('encryption_key');
    if (!key) {
      const randomBytes = await Crypto.getRandomBytesAsync(32);
      key = randomBytes.toString('base64');
      await SecureStore.setItemAsync('encryption_key', key);
    }
    this.encryptionKey = key;
  }

  async encrypt(data: string): Promise<string> {
    // Production: Use proper encryption algorithm
    const encoded = btoa(encodeURIComponent(data));
    return `encrypted_${encoded}`;
  }

  async decrypt(encryptedData: string): Promise<string> {
    const encoded = encryptedData.replace('encrypted_', '');
    return decodeURIComponent(atob(encoded));
  }
}
```

**Slide 7.5: Certificate Pinning**
```typescript
// src/utils/certificatePinning.ts
const EXPECTED_PUBLIC_KEYS = {
  production: ['sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='],
};

export const secureFetch = async (url: string, options?: RequestInit) => {
  // Validate certificate pinning
  // Use react-native-ssl-pinning for actual implementation
  const response = await fetch(url, options);
  // Verify public key hash matches expected
  return response;
};
```

**Slide 7.6: Runtime Integrity Checks**
```typescript
// src/utils/integrity.ts
export class IntegrityChecker {
  static async checkDeviceIntegrity() {
    const isRooted = await DeviceInfo.isRooted();
    const isEmulator = await DeviceInfo.isEmulator();
    const isDebug = __DEV__;

    const isCompromised = isRooted || isEmulator || isDebug;

    if (isCompromised && !__DEV__) {
      Alert.alert(
        'Security Warning',
        'This device appears to be compromised. Some features may be limited.'
      );
    }

    return {
      isCompromised,
      checks: { isRooted, isEmulator, isDebug },
    };
  }
}
```

**Slide 7.7: Production Signing - iOS**
1. Generate Certificate Signing Request
2. Create Development Certificate in Apple Developer Portal
3. Create App ID with bundle identifier
4. Create Provisioning Profile
5. Configure in Xcode

**Slide 7.8: Production Signing - Android**
```bash
# Generate keystore
keytool -genkey -v -keystore nexuscollect-release.keystore \
  -alias nexuscollect-release \
  -keyalg RSA -keysize 2048 -validity 10000

# Configure in gradle.properties
NEXUSCOLLECT_RELEASE_STORE_FILE=nexuscollect-release.keystore
NEXUSCOLLECT_RELEASE_STORE_PASSWORD=your_password
NEXUSCOLLECT_RELEASE_KEY_ALIAS=nexuscollect-release
NEXUSCOLLECT_RELEASE_KEY_PASSWORD=your_password
```

**Slide 7.9: App Store Metadata**
```typescript
// app-store-metadata.ts
export const appStoreMetadata = {
  ios: {
    name: 'NexusCollect',
    subtitle: 'Field Data Collection Made Easy',
    description: `
      NexusCollect is a powerful field data collection platform designed for professionals who need to capture, manage, and sync data in real-time—even offline.
      
      Key Features:
      • Offline-first data collection
      • Custom form builder
      • GPS location tagging
      • Photo capture and storage
      • Real-time sync
      • Team collaboration
      • Secure biometric authentication
    `,
    keywords: 'field data,collection,offline,survey',
    supportUrl: 'https://nexuscollect.com/support',
    privacyPolicyUrl: 'https://nexuscollect.com/privacy',
    category: 'Business',
  },
};
```

**Slide 7.10: Privacy Manifest**
```xml
<!-- ios/NexusCollect/PrivacyInfo.xcprivacy -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeEmail</string>
      <key>NSPrivacyCollectedDataLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataPurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
        <string>NSPrivacyCollectedDataTypePurposeAccountManagement</string>
      </array>
    </dict>
  </array>
  <key>NSPrivacyTracking</key>
  <false/>
</dict>
</plist>
```

**Slide 7.11: OTA Updates**
```typescript
// src/utils/ota.ts
export class OTAService {
  static async checkForUpdates() {
    const update = await Updates.checkForUpdateAsync();
    if (update.isAvailable) {
      await Updates.fetchUpdateAsync();
      await Updates.reloadAsync();
    }
  }

  static async applyUpdate() {
    await Updates.reloadAsync();
  }

  static getUpdateStatus() {
    return {
      isUpdateAvailable: Updates.isUpdateAvailable,
      isUpdatePending: Updates.isUpdatePending,
    };
  }
}

// Usage in app
useEffect(() => {
  OTAService.checkForUpdates();
}, []);
```

**Slide 7.12: Verification: Security**
- [ ] Code obfuscation enabled
- [ ] Data encryption implemented
- [ ] Certificate pinning configured
- [ ] Integrity checks working
- [ ] Signing configured
- [ ] OTA updates working
- [ ] Privacy manifest created

---

### Section 7.2: Production Deployment (10 slides)

**Slide 7.13: Deployment Process**
```
┌─────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT PROCESS                      │
│                                                             │
│  1. Version → 2. Build → 3. Test → 4. Submit → 5. Monitor │
│                                                             │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐│
│  │ Version  │   │  Build   │   │  Submit  │   │  Monitor ││
│  │  Update  │ → │  Apps    │ → │  Stores  │ → │  Health  ││
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘│
└─────────────────────────────────────────────────────────────┘
```

**Slide 7.14: Version Management**
```javascript
// scripts/version.js
async function main() {
  const current = getCurrentVersion();
  const version = await promptVersion(current);
  updateVersion(version);
  
  execSync(`git add package.json app.json`);
  execSync(`git commit -m "chore: release version ${version}"`);
  execSync(`git tag -a v${version} -m "Release version ${version}"`);
  execSync(`git push origin main --tags`);
}
```

**Slide 7.15: Build for Production**
```bash
# EAS Build
eas build --platform ios --profile production
eas build --platform android --profile production

# Or use scripts
npm run build:prod:ios
npm run build:prod:android
npm run build:prod:all
```

**Slide 7.16: App Store Submission**
```bash
# iOS App Store
eas submit --platform ios

# Google Play Store
eas submit --platform android

# Submit to both
npm run submit:all
```

**Slide 7.17: Fastlane Automation**
```ruby
# fastlane/Fastfile
platform :ios do
  lane :deploy do
    build_app(scheme: "NexusCollect")
    upload_to_app_store(
      skip_metadata: false,
      skip_screenshots: false
    )
  end
end

platform :android do
  lane :deploy do
    gradle(task: "bundle", build_type: "Release")
    upload_to_play_store(track: "production")
  end
end
```

**Slide 7.18: Post-Launch Monitoring**
```typescript
// src/utils/monitoring.ts
export class MonitoringService {
  static trackAppStart() {
    Sentry.addBreadcrumb({
      message: 'App started',
      category: 'lifecycle',
    });
  }

  static trackScreen(screen: string) {
    Sentry.addBreadcrumb({
      message: `Screen: ${screen}`,
      category: 'navigation',
    });
  }

  static trackError(error: Error, context?: any) {
    Sentry.captureException(error, { extra: context });
  }
}
```

**Slide 7.19: Pre-Launch Checklist**
```
[ ] All tests passing
[ ] Code coverage >= 70%
[ ] E2E tests passing
[ ] ESLint no errors
[ ] TypeScript no errors
[ ] App icons generated
[ ] Splash screen configured
[ ] App store screenshots captured
[ ] App description written
[ ] Privacy policy URL configured
[ ] Terms of service URL configured
[ ] App signing configured
[ ] Environment variables set
[ ] Sentry configured
[ ] Analytics configured
[ ] OTA updates configured
```

**Slide 7.20: Post-Launch Checklist**
```
[ ] Monitor crash rates
[ ] Check error logs
[ ] Review user feedback
[ ] Track performance metrics
[ ] Monitor app store ratings
[ ] Plan next release
[ ] Update documentation
[ ] Review security reports
```

**Slide 7.21: Course Summary**
What You've Built:
1. Native Foundations - Xcode, Android Studio, native modules
2. Project Architecture - Navigation, state management
3. Backend Integration - Supabase, authentication
4. Offline Data - WatermelonDB, sync engine
5. Hardware Integration - Camera, GPS, biometrics
6. Testing - Unit, component, E2E, CI/CD
7. Security - Encryption, certificate pinning
8. Deployment - App Store, Play Store, OTA updates

**Slide 7.22: Next Steps**
- Maintain your app
- Add new features
- Optimize performance
- Expand to new platforms
- Build your portfolio
- Share your knowledge

---

## SLIDE DECK SUMMARY

| Module | Title | Slides | Estimated Time |
|--------|-------|--------|----------------|
| 0 | Introduction & Course Overview | 12 | 1 hour |
| 1 | Native Foundations & Build Environments | 40 | 3-4 hours |
| 2 | Project Architecture & Core Setup | 42 | 2-3 hours |
| 3 | Backend Integration & Authentication | 35 | 3-4 hours |
| 4 | Data Management & Offline Sync | 36 | 4-5 hours |
| 5 | Device Hardware Integration | 30 | 3-4 hours |
| 6 | Testing & Quality Assurance | 34 | 3-4 hours |
| 7 | Security Hardening & Production Deployment | 33 | 4-5 hours |

**Total: 262 slides | ~30-40 hours**

---

*This completes the comprehensive slide outline for the "Mastering Mobile Development Beyond the UI" tutorial series. Each module builds upon the previous, following the principles of code-heavy, unabbreviated instruction with clear verification steps.*
