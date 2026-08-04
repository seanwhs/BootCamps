# Part 1: Native Foundations & Build Environment

## Building Your Native Development Foundation

Welcome to the first hands-on part of our series! Before we write a single line of mobile application code, we need to establish the professional development environment that will support everything we build. Think of this as preparing your workshop before you start crafting furniture—the right tools and a well-organized workspace make all the difference.

### The Target

By the end of this part, you will have:

1. A fully configured native development environment for both iOS and Android
2. A brand new React Native project with TypeScript support
3. The application running successfully on both iOS Simulator and Android Emulator
4. A basic understanding of how React Native bridges to native platforms
5. A custom native module written in both Swift and Kotlin

### Why This Matters

When you run `npx react-native init`, you're not just creating JavaScript files—you're generating native iOS and Android projects. React Native delegates rendering and device access to these platforms. Understanding this foundation is crucial because:

- Build failures often originate in native configuration
- Performance bottlenecks are sometimes native-side issues
- Adding device features (camera, biometrics) requires native module knowledge
- App store deployment demands familiarity with native build tools

Let's build this foundation together, step by step.

---

## Phase 1.1: Setting Up the Native Development Environment

### The Concept: Your Development Workshop

Think of your computer as a workshop. Just as a carpenter needs different tools for cutting wood (a saw) and joining pieces (a hammer), mobile developers need different tools for iOS (Xcode) and Android (Android Studio). Both environments generate apps that run on their respective platforms, and React Native coordinates between them.

We'll set up each tool separately, then bring them together.

---

### Step 1.1.1: macOS-Specific Setup (iOS Development)

**Target:** Install Xcode and related iOS development tools

**The Concept:** Xcode is Apple's all-in-one development environment. It includes the iOS Simulator (a virtual iPhone on your Mac), the Swift compiler, and all the SDKs needed to build iOS apps. While React Native handles the cross-platform abstraction, Xcode is the actual tool that produces the `.ipa` file that runs on iPhones.

**The Implementation:**

1. **Install Xcode from the Mac App Store:**
   - Open the App Store on your Mac
   - Search for "Xcode"
   - Click "Install" (this may take 1-2 hours, as it's ~12GB)

2. **After installation, set up Xcode Command Line Tools:**
```bash
# Open Xcode first to accept the license agreement
$ sudo xcodebuild -license accept

# Install command line tools
$ xcode-select --install
# A popup will appear - click "Install"

# Verify installation
$ xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# Install CocoaPods (dependency manager for iOS libraries)
$ sudo gem install cocoapods

# Verify CocoaPods installation
$ pod --version
# Should output version number (e.g., 1.15.2)
```

3. **Install iOS Simulator:**
   - Open Xcode
   - Go to Preferences → Platforms
   - Ensure iOS 17.0+ is installed (click the + button if needed)

4. **Verify Simulator availability:**
```bash
# List available simulators
$ xcrun simctl list devices
# You should see iPhone 15, iPhone 15 Pro Max, etc.
```

**The Verification:**

```bash
# Check that all tools are available
$ xcodebuild -version
# Should output Xcode version (e.g., 15.0)

$ clang --version
# Should output Apple clang version

$ swift --version
# Should output Swift version

$ pod --version
# Should output CocoaPods version

# Try launching the simulator (this will open a new window)
$ open -a Simulator
```

**Troubleshooting:**

- **If `xcode-select` fails:** Run `sudo xcode-select --reset` and try again
- **If CocoaPods install fails with permissions:** Try `sudo gem install cocoapods -n /usr/local/bin`
- **If Simulator won't launch:** Restart your Mac and try again

---

### Step 1.1.2: Cross-Platform Setup (Android Development)

**Target:** Install Android Studio and configure Android SDK

**The Concept:** Android Studio is Google's official IDE for Android development. It includes the Android SDK (Software Development Kit)—the libraries and tools needed to build Android apps, the Android Emulator (a virtual Android device on your computer), and build tools that produce `.apk` files.

**The Implementation:**

1. **Download and install Android Studio:**
   - Go to https://developer.android.com/studio
   - Download the version for your operating system
   - Follow the installation wizard
   - **On macOS:** Drag to Applications folder
   - **On Windows:** Run the installer
   - **On Linux:** Extract the tar.gz file

2. **Install Android SDK components:**

   Open Android Studio and follow the setup wizard:
   - Select "Custom" installation
   - Choose the Android SDK location (default is fine)
   - Install the recommended SDK packages
   - **Ensure you install:**
     - Android SDK Platform 33 (Android 13)
     - Android SDK Platform 34 (Android 14)
     - Intel HAXM (hardware acceleration for emulator)
     - Android SDK Build-Tools 34.0.0

3. **Set up environment variables (CRITICAL for React Native):**

   **For macOS/Linux (add to `~/.zshrc` or `~/.bash_profile`):**
```bash
# Open your shell configuration file
$ nano ~/.zshrc

# Add these lines:
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

# Save and reload
$ source ~/.zshrc
```

   **For Windows (Add to System Environment Variables):**
```
ANDROID_HOME = C:\Users\YourUsername\AppData\Local\Android\Sdk
Add to Path:
%ANDROID_HOME%\emulator
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%ANDROID_HOME%\tools\bin
```

4. **Verify Android SDK:**
```bash
# Check that adb (Android Debug Bridge) is available
$ adb --version
# Should output Android Debug Bridge version

# Check that emulator is available
$ emulator -list-avds
# Initially empty - that's fine
```

5. **Create an Android Virtual Device (AVD) - an emulator:**
   - Open Android Studio
   - Click "More Actions" → "AVD Manager"
   - Click "Create Virtual Device"
   - Select a device (e.g., Pixel 6)
   - Select a system image (e.g., API 33)
   - Click "Next" and "Finish"

**The Verification:**

```bash
# Check Java (required for Android builds)
$ java -version
# Should output openjdk version 17.x

# Test adb connection
$ adb devices
# Should show "List of devices attached" (no devices yet)

# Test that environment variables are set
$ echo $ANDROID_HOME
# Should output the SDK path
```

**Troubleshooting:**

- **Java not found:** Install OpenJDK 17: `brew install openjdk@17` (macOS) or download from AdoptOpenJDK
- **Android SDK not found:** Make sure you completed the Android Studio setup wizard
- **Emulator won't start:** Ensure virtualization is enabled in your BIOS

---

## Phase 1.2: Creating Your React Native Project

### The Concept: Starting with the Right Foundation

React Native projects come in two main flavors: Expo (managed) and React Native CLI (bare). We're using Expo with development builds for this series because:

1. **Development builds** give us the best of both worlds—Expo's easy development experience with the flexibility to add native code when needed
2. **EAS (Expo Application Services)** provides OTA updates and easy builds
3. **TypeScript** integration is seamless out of the box

Think of it like buying a partially-assembled piece of furniture. Expo gives you the sturdy frame and tools (development builds), and we'll customize the rest.

---

### Step 1.2.1: Initializing the Project

**Target:** Create the NexusCollect project with TypeScript and Expo

**The Implementation:**

1. **Create the project using the latest Expo CLI:**
```bash
# Install Expo CLI globally (if not already installed)
$ npm install -g expo-cli

# Create a new Expo project with TypeScript template
$ npx create-expo-app NexusCollect --template

# Select the template when prompted:
# > TypeScript (with Expo Router)

# Navigate into the project directory
$ cd NexusCollect

# Install additional packages we'll need
$ npm install react-native-safe-area-context react-native-screens
$ npm install -D @types/react @types/react-native
```

2. **Verify project structure:**
```bash
$ ls -la
# Should show:
# android/        - Native Android project
# ios/            - Native iOS project
# app/            - Expo Router app directory
# assets/         - Static assets
# package.json    - Dependencies
# tsconfig.json   - TypeScript config
# app.json        - Expo config
```

3. **Install iOS dependencies (macOS only):**
```bash
# Navigate to iOS folder and install pods
$ cd ios
$ pod install
$ cd ..
```

**The Verification:**

```bash
# Start the development server
$ npx expo start

# You should see a QR code and a menu with options
# Press 'i' to open iOS simulator
# Press 'a' to open Android emulator
# Press 'w' to open web browser

# Verify it builds successfully - you should see:
# "Welcome to Expo" screen in the simulator/emulator
```

**Expected Output:**
```
Starting Metro Bundler
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█ ▄▄▄▄▄ █ ▄▄▄ ▄ █ ▄▄▄▄▄ █
█ █   █ █ █▄▄█▄▄█ █   █ █
█ █▄▄▄█ █▄▄ ▄▄█▄█ █▄▄▄█ █
█▄▄▄▄▄▄▄█▄▄▄█▄▄█▄▄▄▄▄▄▄█
...
› Using Expo
› Press i │ open iOS simulator
› Press a │ open Android emulator
```

**Troubleshooting:**

- **If `pod install` fails:** Try `pod install --repo-update`
- **If Expo start shows "Unable to find a suitable version":** Delete `node_modules` and `package-lock.json`, then run `npm install` again
- **If iOS simulator won't open:** Check Xcode → Settings → Platforms → iOS is installed

---

### Step 1.2.2: Configuring TypeScript Strictly

**Target:** Set up TypeScript with strict mode for better type safety

**The Concept:** TypeScript provides type checking that catches errors before runtime. It's like having a proofreader for your code—it won't fix problems, but it will tell you where to look. We'll use strict mode to enforce the highest level of type safety.

**The Implementation:**

1. **Update `tsconfig.json` with strict settings:**
```json
// tsconfig.json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@screens/*": ["./src/screens/*"],
      "@utils/*": ["./src/utils/*"],
      "@types/*": ["./src/types/*"]
    }
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", "**/__tests__/*", "**/*.test.ts"]
}
```

2. **Create the src directory structure:**
```bash
# Create source folders
$ mkdir -p src/components
$ mkdir -p src/screens
$ mkdir -p src/utils
$ mkdir -p src/types
$ mkdir -p src/navigation
$ mkdir -p src/store
$ mkdir -p src/api
$ mkdir -p src/hooks
$ mkdir -p src/constants
$ mkdir -p src/database
```

3. **Create a type definition file:**
```typescript
// src/types/index.ts
/**
 * Global type definitions for the NexusCollect application.
 * These types are used across multiple parts of the app.
 */

export type User = {
  id: string;
  email: string;
  fullName: string;
  avatarUrl?: string;
  createdAt: Date;
  updatedAt: Date;
};

export type AuthState = {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
};

export type CollectionForm = {
  id: string;
  title: string;
  description: string;
  fields: FormField[];
  createdAt: Date;
  updatedAt: Date;
};

export type FormField = {
  id: string;
  label: string;
  type: 'text' | 'number' | 'date' | 'select' | 'checkbox' | 'photo';
  required: boolean;
  options?: string[]; // For select fields
  defaultValue?: string | number | boolean;
};

export type CollectionEntry = {
  id: string;
  formId: string;
  data: Record<string, any>; // Key-value pairs for form data
  location?: {
    latitude: number;
    longitude: number;
    accuracy?: number;
  };
  photos?: string[]; // URLs or local paths
  syncedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
};

export type ApiResponse<T> = {
  data: T;
  error?: string;
  status: number;
};

export type SyncStatus = 'idle' | 'syncing' | 'synced' | 'error';
```

**The Verification:**

```bash
# Check TypeScript configuration works
$ npx tsc --noEmit
# Should run without errors (may have warnings about missing files - that's fine)
```

---

## Phase 1.3: Running on Devices and Simulators

### The Concept: Testing on Multiple Platforms

Professional developers test on both simulators/emulators (for quick iteration) and real devices (for final verification). Simulators are faster for development, but real devices are essential for testing hardware features, performance, and platform-specific behaviors.

---

### Step 1.3.1: Running on iOS Simulator

**Target:** Launch the app on the iPhone Simulator

**The Implementation:**

1. **From the command line:**
```bash
# Start Expo with iOS
$ npx expo start --ios

# Or after already running, press 'i' in the Metro bundler terminal
```

2. **Verify the Simulator launched:**
   - The Simulator window should appear
   - The Expo app should be loading
   - You should see "Welcome to Expo" on the screen

**The Verification:**

```bash
# List all simulator devices
$ xcrun simctl list devices --json | grep -A 2 "iPhone 15"
# Should show available iPhone 15 simulators

# Test that the app is running
# In the simulator, the app should be responsive to clicks
```

### Step 1.3.2: Running on Android Emulator

**Target:** Launch the app on the Android Emulator

**The Implementation:**

1. **Start the emulator from Android Studio:**
   - Open Android Studio
   - Click "AVD Manager" (or Tools → AVD Manager)
   - Click the play button next to your virtual device

2. **From the command line:**
```bash
# Start Expo with Android
$ npx expo start --android

# Or after already running, press 'a' in the Metro bundler terminal
```

**The Verification:**

```bash
# Check emulator status
$ adb devices
# Should show:
# List of devices attached
# emulator-5554   device

# Test that the app installed correctly
$ adb shell pm list packages | grep nexuscollect
# Should show the app package name
```

### Step 1.3.3: Running on Physical Devices

**Target:** Run the app on your actual iPhone or Android device

**The Concept:** Physical devices test real hardware, permissions, and performance. However, they require some setup:

- **iOS:** Requires an Apple Developer account and Xcode
- **Android:** Requires USB debugging enabled

**The Implementation:**

**For iOS (requires Apple Developer account):**

1. Connect your iPhone via USB
2. Set the build target:
```bash
# Update app.json with your bundle identifier
# Edit app.json:
{
  "expo": {
    "name": "NexusCollect",
    "slug": "nexuscollect",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "light",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": [
      "**/*"
    ],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.yourcompany.nexuscollect"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.yourcompany.nexuscollect"
    },
    "web": {
      "favicon": "./assets/favicon.png"
    },
    "experiments": {
      "tsconfigPaths": true
    }
  }
}
```

**For Android:**

1. Enable Developer Mode:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

2. Connect your phone via USB:
```bash
# Check if your device is recognized
$ adb devices
# Should show your device

# Install the app
$ npx expo start --tunnel
# Use tunnel mode if you're on a different network
```

**The Verification:**

```bash
# For iOS (in Xcode):
# Open ios/NexusCollect.xcworkspace
# Select your device from the scheme menu
# Click "Run" (play button)

# For Android:
$ npx expo start --android
# Select your device from the list
```

---

## Phase 1.4: Understanding Native Modules & Bridging

### The Concept: How JavaScript Talks to Native Code

React Native apps run JavaScript in a separate thread from the native UI. When your JavaScript code needs to use a device feature (like the camera or GPS), it sends a message across a "bridge" to the native side. This bridge is like a translation layer—it converts JavaScript function calls into native code execution.

In the new React Native architecture (which we'll explore), this is replaced with JSI (JavaScript Interface), which allows direct communication between JavaScript and native code, improving performance.

**Why Native Modules Matter:**
- Access to platform-specific features
- Performance-critical operations
- Reusing existing native libraries
- Integration with platform-specific APIs

Let's create a simple native module to understand how this works.

---

### Step 1.4.1: Creating an iOS Native Module (Swift)

**Target:** Build a simple native module that returns device information

**The Concept:** Our native module will expose a function that returns device model and iOS version. This demonstrates how to bridge Swift code to JavaScript.

**The Implementation:**

1. **Create the native module files:**

```swift
// ios/NexusCollect/NexusCollect-Bridging-Header.h
// This file exposes Swift to Objective-C
#import <React/RCTBridgeModule.h>
```

```objc
// ios/NexusCollect/DeviceInfoModule.h
// Objective-C header that exposes our Swift module to React Native

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(DeviceInfoModule, NSObject)
RCT_EXTERN_METHOD(getDeviceInfo:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
@end
```

```swift
// ios/NexusCollect/DeviceInfoModule.swift
// Swift implementation of our native module

import Foundation
import React

@objc(DeviceInfoModule)
class DeviceInfoModule: NSObject, RCTBridgeModule {
  
  // This tells React Native this is a bridge module
  static func moduleName() -> String! {
    return "DeviceInfoModule"
  }
  
  // This ensures the module is initialized on the main queue (required for UI-related modules)
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  // The method exposed to JavaScript
  @objc(getDeviceInfo:rejecter:)
  func getDeviceInfo(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    // Get device information
    let device = UIDevice.current
    let deviceInfo: [String: Any] = [
      "model": device.model,
      "name": device.name,
      "systemName": device.systemName,
      "systemVersion": device.systemVersion,
      "identifierForVendor": device.identifierForVendor?.uuidString ?? "unknown"
    ]
    
    // Resolve the promise with the device info
    resolve(deviceInfo)
  }
}
```

2. **Update the Podfile to include the module:**
```ruby
# ios/Podfile
require File.join(File.dirname(`node --print "require.resolve('expo/package.json')"`), "scripts/autolinking")
require File.join(File.dirname(`node --print "require.resolve('react-native/package.json')"`), "scripts/react_native_pods")
require File.join(File.dirname(`node --print "require.resolve('@react-native-community/cli-platform-ios/package.json')"`), "native_modules")

platform :ios, min_ios_version_supported
prepare_react_native_project!

# If you are using the `expo` package and not using Expo Modules, you can remove this line!
Expo::use_expo_modules!

# If you are using Expo Modules, you may need to change this line!
# ExpoModulesCore is not auto-linked when using use_expo_modules! with Expo 50+
pod 'ExpoModulesCore', :path => "../node_modules/expo-modules-core"

target 'NexusCollect' do
  config = use_native_modules!

  # Flags change depending on the env values.
  flags = get_default_flags()

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => flags[:hermes_enabled] || false,
    :fabric_enabled => flags[:fabric_enabled] || false,
    # :flipper_configuration => FlipperConfiguration.enabled,
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

  # Explicitly include our native module
  pod 'NexusCollect', :path => '../'
  
  # Expo-specific dependencies
  target 'NexusCollectTests' do
    inherit! :complete
    # Pods for testing
  end

  post_install do |installer|
    react_native_post_install(
      installer,
      # Set `mac_catalyst_enabled` to `true` in order to apply patches
      # necessary for Mac Catalyst builds
      :mac_catalyst_enabled => false
    )
    __apply_Xcode_12_5_M1_post_install_workaround(installer)
  end
end
```

3. **Install the new pod:**
```bash
$ cd ios
$ pod install
$ cd ..
```

**The Verification:**

```javascript
// app/index.tsx
import { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NativeModules } from 'react-native';

const { DeviceInfoModule } = NativeModules;

export default function HomeScreen() {
  useEffect(() => {
    // Call our native module
    DeviceInfoModule.getDeviceInfo()
      .then((info: any) => {
        console.log('Device Info:', info);
        // Should output device model, system version, etc.
      })
      .catch((error: any) => {
        console.error('Error getting device info:', error);
      });
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>NexusCollect</Text>
      <Text style={styles.subtitle}>Your device info is in the console</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
  },
});
```

---

### Step 1.4.2: Creating an Android Native Module (Kotlin)

**Target:** Build the same device info module for Android

**The Concept:** Android native modules follow the same pattern but use Kotlin/Java and the React Native bridge API. We'll create a module that returns Android-specific device information.

**The Implementation:**

1. **Create the Android native module:**

```kotlin
// android/app/src/main/java/com/yourcompany/nexuscollect/DeviceInfoModule.kt
package com.yourcompany.nexuscollect

import android.os.Build
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import java.util.HashMap

/**
 * Native module for Android device information.
 * This module exposes device-specific information to JavaScript.
 */
class DeviceInfoModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    // The name exposed to JavaScript
    override fun getName(): String {
        return "DeviceInfoModule"
    }

    // ReactMethod annotation exposes this method to JavaScript
    @ReactMethod
    fun getDeviceInfo(promise: Promise) {
        try {
            // Build a map of device information
            val deviceInfo = HashMap<String, Any>()
            deviceInfo["model"] = Build.MODEL
            deviceInfo["manufacturer"] = Build.MANUFACTURER
            deviceInfo["brand"] = Build.BRAND
            deviceInfo["device"] = Build.DEVICE
            deviceInfo["product"] = Build.PRODUCT
            deviceInfo["version"] = Build.VERSION.RELEASE
            deviceInfo["sdkVersion"] = Build.VERSION.SDK_INT
            deviceInfo["hardware"] = Build.HARDWARE
            deviceInfo["fingerprint"] = Build.FINGERPRINT

            // Resolve the promise with the device info
            promise.resolve(deviceInfo)
        } catch (e: Exception) {
            // Reject the promise with an error
            promise.reject("DEVICE_INFO_ERROR", "Failed to get device info", e)
        }
    }
}
```

2. **Register the module with React Native:**

```kotlin
// android/app/src/main/java/com/yourcompany/nexuscollect/DeviceInfoPackage.kt
package com.yourcompany.nexuscollect

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

/**
 * Package that registers our DeviceInfoModule with React Native.
 * React Native uses packages to discover all native modules.
 */
class DeviceInfoPackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        return listOf(DeviceInfoModule(reactContext))
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return emptyList()
    }
}
```

3. **Update MainApplication to include our package:**

```kotlin
// android/app/src/main/java/com/yourcompany/nexuscollect/MainApplication.kt
package com.yourcompany.nexuscollect

import android.app.Application
import android.content.res.Configuration
import expo.modules.ApplicationLifecycleDispatcher
import expo.modules.ReactNativeHostWrapper
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.soloader.SoLoader
import expo.modules.core.interfaces.Package

class MainApplication : Application(), ReactApplication {
    private val mReactNativeHost: ReactNativeHost = object : DefaultReactNativeHost(this) {
        override fun getPackages(): List<ReactPackage> =
            PackageList(this).packages.apply {
                // Add our custom package
                add(DeviceInfoPackage())
            }

        override fun getJSMainModuleName(): String = ".expo/.virtual-metro-entry"

        override fun getUseDeveloperSupport(): Boolean = BuildConfig.DEBUG

        override val isNewArchEnabled: Boolean = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
        override val isHermesEnabled: Boolean = BuildConfig.IS_HERMES_ENABLED
    }

    override fun getReactNativeHost(): ReactNativeHost =
        ReactNativeHostWrapper(this, mReactNativeHost)

    override fun onCreate() {
        super.onCreate()
        SoLoader.init(this, false)
        if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
            // If you opted-in for the New Architecture, we load the native entry point for this app.
            DefaultNewArchitectureEntryPoint.load()
        }
        ReactNativeFlipper.initializeFlipper(this, reactNativeHost.reactInstanceManager)
        ApplicationLifecycleDispatcher.onApplicationCreate(this)
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        ApplicationLifecycleDispatcher.onConfigurationChanged(this, newConfig)
    }
}
```

**The Verification:**

```typescript
// app/index.tsx (updated to use the same native module on both platforms)
import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import { NativeModules } from 'react-native';

const { DeviceInfoModule } = NativeModules;

interface DeviceInfo {
  model: string;
  systemName?: string;
  systemVersion: string;
  identifierForVendor?: string;
  manufacturer?: string;
  brand?: string;
  sdkVersion?: number;
}

export default function HomeScreen() {
  const [deviceInfo, setDeviceInfo] = useState<DeviceInfo | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Check if the native module exists
    if (!DeviceInfoModule) {
      setError('Native module not available');
      return;
    }

    // Call the native module
    DeviceInfoModule.getDeviceInfo()
      .then((info: DeviceInfo) => {
        console.log('Device Info:', info);
        setDeviceInfo(info);
      })
      .catch((err: any) => {
        console.error('Error getting device info:', err);
        setError(err.message || 'Failed to get device info');
      });
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>NexusCollect</Text>
      <Text style={styles.subtitle}>Device Information</Text>
      
      {error && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )}
      
      {deviceInfo && (
        <View style={styles.infoContainer}>
          <Text style={styles.infoText}>Platform: {Platform.OS}</Text>
          <Text style={styles.infoText}>Model: {deviceInfo.model}</Text>
          <Text style={styles.infoText}>Version: {deviceInfo.systemVersion}</Text>
          {Platform.OS === 'ios' && deviceInfo.systemName && (
            <Text style={styles.infoText}>System: {deviceInfo.systemName}</Text>
          )}
          {Platform.OS === 'android' && deviceInfo.manufacturer && (
            <Text style={styles.infoText}>Manufacturer: {deviceInfo.manufacturer}</Text>
          )}
          {Platform.OS === 'android' && deviceInfo.brand && (
            <Text style={styles.infoText}>Brand: {deviceInfo.brand}</Text>
          )}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#2c3e50',
  },
  subtitle: {
    fontSize: 18,
    color: '#7f8c8d',
    marginBottom: 30,
  },
  errorContainer: {
    backgroundColor: '#fee',
    padding: 15,
    borderRadius: 8,
    marginBottom: 20,
    width: '100%',
  },
  errorText: {
    color: '#e74c3c',
    fontSize: 14,
  },
  infoContainer: {
    backgroundColor: 'white',
    padding: 20,
    borderRadius: 12,
    width: '100%',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  infoText: {
    fontSize: 16,
    color: '#34495e',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#ecf0f1',
  },
});
```

**The Verification:**

```bash
# Rebuild the Android app (important for changes to native code)
$ npx expo run:android

# Or if using development build:
$ npx expo start --android

# Check the console logs - you should see device info printed
# Look for: "Device Info:" followed by the device information

# Test on both platforms:
# - iOS: Press 'i' in Metro
# - Android: Press 'a' in Metro
# The app should show device information on both platforms
```

---

## Phase 1.5: Build Variants and Signing

### The Concept: Preparing for Distribution

Mobile apps have different build variants for development, testing, and production. Each variant may have different:
- **Bundle identifiers** (com.company.app.dev vs com.company.app)
- **API endpoints** (development vs production)
- **Logging levels** (verbose vs minimal)
- **Signing certificates** (development vs distribution)

Let's set up signing configurations, which will be essential when we eventually deploy to app stores.

---

### Step 1.5.1: iOS Code Signing Setup

**Target:** Configure development and distribution provisioning profiles

**The Concept:** Apple uses code signing to verify that you're the legitimate developer of an app. Without proper signing, apps can't run on actual devices or be submitted to the App Store. We'll set up automatic signing for development.

**The Implementation:**

1. **Open the iOS project in Xcode:**
```bash
$ open ios/NexusCollect.xcworkspace
```

2. **Configure signing in Xcode:**
   - Select the project in the navigator (left sidebar)
   - Select the "NexusCollect" target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your team from the dropdown

3. **Update build configurations in `app.json`:**
```json
// app.json
{
  "expo": {
    "name": "NexusCollect",
    "slug": "nexuscollect",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "light",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": ["**/*"],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.yourcompany.nexuscollect",
      "buildNumber": "1.0.0",
      "infoPlist": {
        "UIBackgroundModes": ["fetch", "remote-notification"],
        "NSLocationWhenInUseUsageDescription": "NexusCollect needs your location to tag entries",
        "NSCameraUsageDescription": "NexusCollect needs camera access to capture photos",
        "NSPhotoLibraryUsageDescription": "NexusCollect needs photo library access to save images"
      }
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.yourcompany.nexuscollect",
      "versionCode": 1,
      "permissions": [
        "CAMERA",
        "READ_EXTERNAL_STORAGE",
        "WRITE_EXTERNAL_STORAGE",
        "ACCESS_FINE_LOCATION",
        "ACCESS_COARSE_LOCATION",
        "INTERNET"
      ]
    },
    "plugins": [
      "expo-camera",
      "expo-location",
      "expo-image-picker",
      "expo-secure-store",
      "expo-notifications"
    ],
    "extra": {
      "eas": {
        "projectId": "your-project-id" // Will be set when you configure EAS
      }
    }
  }
}
```

**The Verification:**
```bash
# Check if Xcode shows no signing errors
# The target should show a checkmark for signing

# Try building for a physical device:
$ npx expo run:ios --device

# The app should install on your device
```

---

### Step 1.5.2: Android Keystore Setup

**Target:** Generate a keystore for signing Android applications

**The Concept:** Android uses keystore files to sign APKs. You'll need a production keystore for releasing to the Play Store. For development, Android Studio auto-generates debug keys.

**The Implementation:**

1. **Generate a debug keystore (automatically created):**
```bash
# The debug keystore is typically located at:
# macOS: ~/.android/debug.keystore
# Windows: C:\Users\YourUsername\.android\debug.keystore

# Check if it exists:
$ ls ~/.android/debug.keystore
```

2. **Generate a release keystore:**
```bash
# Create a keystore directory (keep this safe!)
$ mkdir -p ~/.android/keystores

# Generate a release keystore
$ keytool -genkey -v -keystore ~/.android/keystores/nexuscollect-release.keystore \
  -alias nexuscollect-release \
  -keyalg RSA -keysize 2048 -validity 10000

# You'll be prompted for:
# - Keystore password (remember this!)
# - Key password (can be same as keystore)
# - First and last name (your name)
# - Organizational unit (e.g., Engineering)
# - Organization (e.g., YourCompany)
# - City, State, Country
```

3. **Create a `gradle.properties` file for signing credentials:**
```properties
# android/gradle.properties
# Add these lines at the end of the file

# Release signing configuration
NEXUSCOLLECT_RELEASE_STORE_FILE=nexuscollect-release.keystore
NEXUSCOLLECT_RELEASE_STORE_PASSWORD=your_keystore_password
NEXUSCOLLECT_RELEASE_KEY_ALIAS=nexuscollect-release
NEXUSCOLLECT_RELEASE_KEY_PASSWORD=your_key_password

# Note: For production, use environment variables instead of hardcoding
```

**The Verification:**

```bash
# Test the keystore
$ keytool -list -v -keystore ~/.android/keystores/nexuscollect-release.keystore

# Should list the keystore contents
# Key entry with alias "nexuscollect-release"
```

---

## Phase 1.6: Understanding the New Architecture

### The Concept: React Native's Evolution

React Native 0.70+ introduced a "New Architecture" that replaces the bridge with JSI (JavaScript Interface). This is a significant improvement:

**Old Architecture (Bridge):**
- JavaScript ↔ Bridge ↔ Native (serialized messages)
- Async communication
- Single thread for JavaScript

**New Architecture (JSI + Fabric + TurboModules):**
- JavaScript ↔ JSI ↔ Native (direct calls)
- Synchronous/async communication
- Multiple threads
- Better performance

**Key Components:**
1. **TurboModules:** Lazy-loaded, faster native modules
2. **Fabric Renderer:** New UI rendering system
3. **Hermes:** Optimized JavaScript engine

---

### Step 1.6.1: Enabling the New Architecture

**Target:** Enable the New Architecture in our project

**The Implementation:**

1. **Update the iOS Podfile:**
```ruby
# ios/Podfile (update the use_react_native call)

use_react_native!(
  :path => config[:reactNativePath],
  :hermes_enabled => true,  # Enable Hermes
  :fabric_enabled => true,  # Enable Fabric
  # ...
)
```

2. **Update Android settings:**
```gradle
// android/gradle.properties
# Add or update these lines:
newArchEnabled=true
hermesEnabled=true
```

3. **Update `app.json` for New Architecture:**
```json
{
  "expo": {
    // ... other config
    "experiments": {
      "tsconfigPaths": true,
      "turboModules": true
    }
  }
}
```

**The Verification:**

```bash
# Clean rebuild for iOS
$ cd ios
$ pod install
$ cd ..
$ npx expo run:ios

# Check the console for New Architecture logs
# You should see references to JSI, Fabric, or TurboModules

# For Android:
$ npx expo run:android

# Verify the build succeeded
```

---

## Phase 1.7: Environment Variables and Configuration

### The Concept: Managing Secrets Safely

Never hardcode API keys or credentials in your code. Use environment variables to keep secrets out of version control.

---

### Step 1.7.1: Setting Up Environment Variables

**Target:** Configure environment variables for different build flavors

**The Implementation:**

1. **Install necessary packages:**
```bash
$ npm install react-native-dotenv
$ npm install -D @types/react-native-dotenv
```

2. **Create environment files:**
```bash
# Create a .env file in the project root
$ touch .env .env.development .env.production

# Add .env to .gitignore
$ echo ".env" >> .gitignore
$ echo ".env.development" >> .gitignore
$ echo ".env.production" >> .gitignore
```

3. **Configure environment variables:**
```env
# .env.development
API_URL=http://localhost:3000
SUPABASE_URL=your-supabase-development-url
SUPABASE_ANON_KEY=your-supabase-development-anon-key
ENVIRONMENT=development
LOG_LEVEL=debug

# .env.production
API_URL=https://api.nexuscollect.com
SUPABASE_URL=your-supabase-production-url
SUPABASE_ANON_KEY=your-supabase-production-anon-key
ENVIRONMENT=production
LOG_LEVEL=error
```

4. **Update babel.config.js:**
```javascript
// babel.config.js
module.exports = function(api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'module:react-native-dotenv',
        {
          envName: 'APP_ENV',
          moduleName: '@env',
          path: '.env',
          blocklist: null,
          allowlist: null,
          blacklist: null, // DEPRECATED
          whitelist: null, // DEPRECATED
          safe: false,
          allowUndefined: true,
          verbose: false,
        },
      ],
      [
        'module-resolver',
        {
          root: ['./src'],
          extensions: ['.ios.js', '.android.js', '.js', '.ts', '.tsx', '.json'],
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
          },
        },
      ],
    ],
  };
};
```

5. **Create a configuration file:**
```typescript
// src/constants/config.ts
import {
  API_URL,
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  ENVIRONMENT,
  LOG_LEVEL,
} from '@env';

export const CONFIG = {
  api: {
    baseUrl: API_URL,
    timeout: 30000,
  },
  supabase: {
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  },
  environment: ENVIRONMENT as 'development' | 'production' | 'test',
  logLevel: LOG_LEVEL as 'debug' | 'info' | 'warn' | 'error',
  isDevelopment: ENVIRONMENT === 'development',
  isProduction: ENVIRONMENT === 'production',
} as const;

// Type-safe configuration
export type Config = typeof CONFIG;
```

**The Verification:**

```bash
# Check that environment variables work
$ npx expo start

# The app should load without errors
# Check if console logs show the environment
```

---

## Phase 1.8: Testing Everything Works

### The Concept: Integration Test

Now we'll verify that everything we've built works together—the native modules, the build system, and the configuration.

---

### Step 1.8.1: Final Integration Test

**Target:** Run a comprehensive check of all components

**The Implementation:**

1. **Create a diagnostics screen:**
```typescript
// src/screens/DiagnosticsScreen.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Button } from 'react-native';
import { NativeModules, Platform, Dimensions } from 'react-native';
import * as Device from 'expo-device';
import Constants from 'expo-constants';
import { CONFIG } from '@constants/config';

const { DeviceInfoModule } = NativeModules;

export default function DiagnosticsScreen() {
  const [deviceInfo, setDeviceInfo] = useState<any>(null);
  const [diagnostics, setDiagnostics] = useState<string[]>([]);

  const addDiagnostic = (label: string, value: any) => {
    setDiagnostics(prev => [...prev, `${label}: ${String(value)}`]);
  };

  const runDiagnostics = async () => {
    setDiagnostics([]);
    
    // 1. Check environment
    addDiagnostic('Environment', CONFIG.environment);
    addDiagnostic('API URL', CONFIG.api.baseUrl);
    addDiagnostic('Supabase URL', CONFIG.supabase.url);
    
    // 2. Check device info
    addDiagnostic('Platform', Platform.OS);
    addDiagnostic('Device Name', Device.deviceName || 'Unknown');
    addDiagnostic('Device Model', Device.modelName || 'Unknown');
    addDiagnostic('OS Version', Device.osVersion || 'Unknown');
    addDiagnostic('Expo Version', Constants.expoVersion);
    
    // 3. Check native modules
    addDiagnostic('DeviceInfoModule', DeviceInfoModule ? '✅ Available' : '❌ Missing');
    
    // 4. Check dimensions
    const { width, height } = Dimensions.get('window');
    addDiagnostic('Screen Dimensions', `${width}x${height}`);
    
    // 5. Get detailed device info from native module
    if (DeviceInfoModule) {
      try {
        const info = await DeviceInfoModule.getDeviceInfo();
        setDeviceInfo(info);
        addDiagnostic('Native Module Test', '✅ Success');
      } catch (error) {
        addDiagnostic('Native Module Test', '❌ Failed');
      }
    }
  };

  useEffect(() => {
    runDiagnostics();
  }, []);

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Diagnostics</Text>
      <Text style={styles.subtitle}>NexusCollect System Status</Text>
      
      <View style={styles.diagnosticContainer}>
        {diagnostics.map((item, index) => (
          <Text key={index} style={styles.diagnosticText}>
            {item}
          </Text>
        ))}
      </View>
      
      {deviceInfo && (
        <View style={styles.infoContainer}>
          <Text style={styles.sectionTitle}>Device Details</Text>
          {Object.entries(deviceInfo).map(([key, value]) => (
            <Text key={key} style={styles.detailText}>
              {key}: {String(value)}
            </Text>
          ))}
        </View>
      )}
      
      <Button title="Refresh Diagnostics" onPress={runDiagnostics} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#f8f9fa',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#2c3e50',
  },
  subtitle: {
    fontSize: 16,
    color: '#7f8c8d',
    marginBottom: 20,
  },
  diagnosticContainer: {
    backgroundColor: '#1e1e1e',
    padding: 15,
    borderRadius: 8,
    marginBottom: 20,
  },
  diagnosticText: {
    color: '#00ff00',
    fontFamily: Platform.OS === 'ios' ? 'Courier' : 'monospace',
    fontSize: 13,
    paddingVertical: 3,
  },
  infoContainer: {
    backgroundColor: 'white',
    padding: 15,
    borderRadius: 8,
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 10,
    color: '#2c3e50',
  },
  detailText: {
    fontSize: 14,
    color: '#34495e',
    paddingVertical: 4,
    borderBottomWidth: 1,
    borderBottomColor: '#ecf0f1',
  },
});
```

2. **Update navigation to include the diagnostics screen:**
```typescript
// app/index.tsx (updated with navigation)
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from './home';
import DiagnosticsScreen from '../src/screens/DiagnosticsScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen 
          name="Home" 
          component={HomeScreen} 
          options={{ title: 'NexusCollect' }}
        />
        <Stack.Screen 
          name="Diagnostics" 
          component={DiagnosticsScreen} 
          options={{ title: 'System Diagnostics' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

**The Verification:**

```bash
# Run the complete integration test
$ npx expo start --clear

# On the emulator/simulator:
# 1. Navigate to the Diagnostics screen
# 2. Check that all diagnostic tests pass
# 3. Verify device info is displayed correctly
# 4. Check console logs for any errors

# Expected output: All green checkmarks and no errors
```

---

## Part 1 Summary

Congratulations! You've completed Part 1 of our series. Here's what you've accomplished:

### ✅ Completed:
1. **Native Environment Setup**
   - Xcode and iOS toolchain installed and configured
   - Android Studio and SDK configured
   - Both platforms running successfully

2. **Project Foundation**
   - Created React Native project with TypeScript
   - Set up folder structure
   - Configured strict TypeScript
   - Set up path aliases

3. **Native Modules**
   - Created iOS native module in Swift
   - Created Android native module in Kotlin
   - Tested bridging between JavaScript and native code

4. **Build Configuration**
   - Set up code signing for iOS
   - Generated Android keystore
   - Configured environment variables
   - Enabled New Architecture

5. **Testing**
   - Created diagnostics screen
   - Verified all systems work
   - Tested on both platforms

### Key Concepts Learned:
- Mobile platform architecture
- Native development tooling
- React Native's bridge system
- Code signing and certificates
- Environment configuration
- Build variants

### Next Steps
In **Part 2: Project Architecture & Core Setup**, you'll:
- Design the complete application architecture
- Set up navigation with React Navigation
- Implement state management with Zustand
- Create the core UI components
- Establish the data layer foundation

### Common Issues Resolved:
- Xcode command line tools
- Android SDK path configuration
- CocoaPods installation
- Native module linking
- Environment variable setup

---

## Quick Reference: Native Development Commands

```bash
# iOS Commands
$ npx expo start --ios          # Start iOS simulator
$ open ios/NexusCollect.xcworkspace  # Open in Xcode
$ cd ios && pod install && cd ..     # Install iOS dependencies

# Android Commands
$ npx expo start --android      # Start Android emulator
$ adb devices                    # List connected devices
$ adb logcat                    # View Android logs

# General Commands
$ npx expo start --clear        # Clear cache and start
$ npx tsc --noEmit              # TypeScript type checking
$ npm run lint                  # Run linting

# Building
$ npx expo build:android        # Build Android APK
$ npx expo build:ios            # Build iOS (requires Apple Developer)
```
