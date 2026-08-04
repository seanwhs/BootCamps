# Mastering Mobile Development Beyond the UI
## Complete Student Notes

Welcome to the comprehensive student notes for the "Mastering Mobile Development Beyond the UI" tutorial series. These notes are designed to accompany the course materials, providing structured summaries, key takeaways, code snippets, and important concepts for each module. Use these notes as a quick reference and study guide.

---

## HOW TO USE THESE NOTES

1. **Before Each Module:** Review the key concepts and objectives
2. **During the Module:** Follow along with the code examples
3. **After the Module:** Use these notes for revision and reference
4. **For Quick Reference:** Find important commands and patterns

---

## TABLE OF CONTENTS

**MODULE 0: Introduction & Course Setup** (Page 4)
- Course Overview
- Architecture Summary
- Technology Stack
- Setup Checklist

**MODULE 1: Native Foundations & Build Environments** (Page 7)
- Platform Architecture
- Development Tools
- Native Modules
- Code Signing

**MODULE 2: Project Architecture & Core Setup** (Page 12)
- Architecture Design
- Navigation System
- State Management
- Theme System

**MODULE 3: Backend Integration & Authentication** (Page 17)
- Supabase Setup
- Authentication Flow
- Row Level Security
- Social Login

**MODULE 4: Data Management & Offline Sync** (Page 22)
- Offline-First Architecture
- WatermelonDB
- Repository Pattern
- Sync Engine

**MODULE 5: Hardware Integration** (Page 27)
- Camera & Photos
- Location Services
- Biometric Authentication
- Push Notifications

**MODULE 6: Testing & Quality Assurance** (Page 32)
- Testing Strategy
- Unit Testing
- Component Testing
- E2E Testing
- CI/CD

**MODULE 7: Security & Production Deployment** (Page 37)
- Security Hardening
- Code Signing
- OTA Updates
- App Store Deployment

**APPENDICES** (Page 42)
- A: Quick Reference
- B: Command Reference
- C: Common Patterns
- D: Troubleshooting

---

## MODULE 0: INTRODUCTION & COURSE SETUP

### Course Overview

**Course Title:** Mastering Mobile Development Beyond the UI

**Goal:** Build a production-ready mobile application (NexusCollect) from scratch, learning enterprise-level skills.

**Key Learning Outcomes:**
- Understand mobile platform architecture
- Set up professional development environments
- Build native modules
- Implement offline-first architecture
- Integrate hardware features
- Test and deploy to app stores

---

### NexusCollect Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT: React Native Mobile App          │
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

---

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Framework** | React Native + Expo | Cross-platform mobile development |
| **Language** | TypeScript | Type-safe JavaScript |
| **Navigation** | React Navigation | Screen routing |
| **State** | Zustand | Global state management |
| **Data** | WatermelonDB | Local database |
| **Backend** | Supabase | Authentication, database, storage |
| **Testing** | Jest, Detox | Unit and E2E testing |
| **Deployment** | EAS Build, Fastlane | CI/CD and store submission |

---

### Environment Setup Checklist

**Required Software:**

```bash
# Node.js
node --version  # v18+

# npm
npm --version   # v9+

# Git
git --version

# Watchman (macOS/Linux)
watchman --version

# Xcode (macOS only)
xcode-select -p

# CocoaPods (macOS only)
pod --version

# Android Studio
# ANDROID_HOME environment variable set
# Android SDK Platform 33+ installed
```

**Key Commands:**

```bash
# Create project
npx create-expo-app NexusCollect --template

# Start development
npx expo start

# Run on iOS (macOS)
npx expo start --ios

# Run on Android
npx expo start --android

# Install iOS pods (macOS)
cd ios && pod install && cd ..
```

---

## MODULE 1: NATIVE FOUNDATIONS & BUILD ENVIRONMENTS

### Platform Architecture

**iOS Architecture:**
- UIKit framework
- Swift/Objective-C
- Cocoa Touch
- Application lifecycle: Not running → Inactive → Active → Background → Suspended

**Android Architecture:**
- Android Framework
- Kotlin/Java
- Activity lifecycle: Created → Started → Resumed → Paused → Stopped → Destroyed

---

### React Native Architecture

**Bridge (Legacy):**
- JavaScript ↔ Bridge ↔ Native
- Asynchronous communication
- Serialized messages
- Single JavaScript thread

**New Architecture (JSI):**
- JavaScript ↔ JSI ↔ Native
- Synchronous/async communication
- Direct calls
- Multiple threads
- Better performance

**Key Components:**
- **TurboModules:** Lazy-loaded native modules
- **Fabric Renderer:** New UI rendering system
- **Hermes:** Optimized JavaScript engine

---

### Development Tools

**Xcode (iOS):**
```bash
# Install Xcode from Mac App Store
# Install Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Verify
pod --version
```

**Android Studio:**
```bash
# Download from developer.android.com/studio
# Install Android SDK Platform 33+
# Set environment variables
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

---

### Native Modules

**iOS Native Module (Swift):**

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

**Android Native Module (Kotlin):**

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

---

### Key Commands Summary

```bash
# Project creation
npx create-expo-app NexusCollect --template

# Development
npx expo start --ios
npx expo start --android
npx expo start --clear

# Native module testing
# iOS: Pod install after changes
cd ios && pod install && cd ..

# Android: Rebuild after changes
npx expo run:android
```

---

## MODULE 2: PROJECT ARCHITECTURE & CORE SETUP

### Architecture Design

**Separation of Concerns:**

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

**Data Flow:**
```
User Action → Component → Store/Service → API → Backend
                      ↓
UI Update ← Component ← Store ← Response
```

---

### Folder Structure

```
src/
├── api/           # API clients and services
├── components/    # Reusable UI components
├── screens/       # Screen components
├── navigation/    # Navigation configuration
├── store/         # Zustand stores
├── hooks/         # Custom React hooks
├── database/      # WatermelonDB schema/models
├── services/      # Business logic services
├── utils/         # Helpers and utilities
├── types/         # TypeScript definitions
├── themes/        # Theme system
└── constants/     # App constants
```

---

### Navigation System

**Navigation Types:**

```typescript
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
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

**Key Navigation Components:**
1. **AuthStack:** Login, Register, ForgotPassword
2. **MainTabs:** Dashboard, Forms, Collections, Profile, Settings
3. **RootNavigator:** Determines Auth vs Main based on authentication state

---

### State Management (Zustand)

**Auth Store:**

```typescript
interface AuthStore {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  register: (email: string, password: string, name: string) => Promise<void>;
}
```

**Persistence:**
```typescript
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
};

const useAuthStore = create(
  persist(
    (set) => ({
      // ... state and actions
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

### Theme System

**Colors:**
```typescript
export const colors = {
  primary: {
    50: '#e8f4fd',
    500: '#2196F3',
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
};
```

**Theme Provider:**
```typescript
const ThemeContext = createContext<Theme>(lightTheme);

export const ThemeProvider = ({ children }) => {
  const theme = useSettingsStore((state) => state.settings.theme);
  const currentTheme = theme === 'dark' ? darkTheme : lightTheme;
  return (
    <ThemeContext.Provider value={currentTheme}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => useContext(ThemeContext);
```

---

## MODULE 3: BACKEND INTEGRATION & AUTHENTICATION

### Supabase Setup

**Supabase Configuration:**

```typescript
import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';

const ExpoSecureStoreAdapter = {
  getItem: async (key) => {
    const value = await SecureStore.getItemAsync(key);
    return value ?? null;
  },
  setItem: async (key, value) => {
    await SecureStore.setItemAsync(key, value);
  },
  removeItem: async (key) => {
    await SecureStore.deleteItemAsync(key);
  },
};

export const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY,
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

### Database Schema

**Tables:**
1. **profiles:** User profiles (extends auth.users)
2. **forms:** Form definitions
3. **collections:** Data entries
4. **sync_queue:** Offline sync operations
5. **notifications:** User notifications

**Row Level Security (RLS):**
```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own profile
CREATE POLICY "Users can view their own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update their own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
```

---

### Authentication Flow

**Email/Password Authentication:**

```typescript
export const authService = {
  login: async (credentials: LoginCredentials) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    });
    if (error) throw error;
    return data;
  },

  register: async (data: RegisterData) => {
    const { data: authData, error } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: { full_name: data.fullName },
      },
    });
    if (error) throw error;
    return authData;
  },

  resetPassword: async (email: string) => {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: 'nexuscollect://reset-password',
    });
    if (error) throw error;
  },
};
```

**Social Login (Google):**

```typescript
const handleGoogleLogin = async () => {
  const result = await googlePromptAsync();
  if (result?.type === 'success') {
    const { id_token, access_token } = result.params;
    const { data, error } = await supabase.auth.signInWithIdToken({
      provider: 'google',
      token: id_token,
      access_token: access_token,
    });
    if (error) throw error;
  }
};
```

---

## MODULE 4: DATA MANAGEMENT & OFFLINE SYNC

### Offline-First Architecture

**Key Concepts:**
1. All data stored locally (WatermelonDB)
2. Offline operations (CRUD)
3. Sync queue for pending operations
4. Automatic sync when online

**Benefits:**
- Reliable user experience
- Reduced server load
- Faster app performance
- Works in remote areas

---

### WatermelonDB

**Schema Definition:**

```typescript
export const schema = appSchema({
  version: 1,
  tables: [
    tableSchema({
      name: 'forms',
      columns: [
        { name: 'title', type: 'string' },
        { name: 'fields', type: 'string' },
        { name: 'user_id', type: 'string' },
        { name: 'sync_status', type: 'string' },
      ],
    }),
    tableSchema({
      name: 'collections',
      columns: [
        { name: 'form_id', type: 'string' },
        { name: 'data', type: 'string' },
        { name: 'status', type: 'string' },
        { name: 'sync_status', type: 'string' },
      ],
    }),
  ],
});
```

**Model Definition:**

```typescript
import { Model } from '@nozbe/watermelondb';
import { text, field, json } from '@nozbe/watermelondb/decorators';

export default class FormModel extends Model {
  static table = 'forms';
  
  @text('title') title!: string;
  @json('fields') fields!: any[];
  @text('user_id') userId!: string;
  @text('sync_status') syncStatus!: string;
}
```

---

### Repository Pattern

```typescript
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
}
```

---

### Sync Engine

**Core Components:**

```typescript
class SyncEngine {
  private isSyncing = false;

  async sync(): Promise<SyncResult> {
    if (this.isSyncing) return;
    this.isSyncing = true;

    try {
      // 1. Upload pending items
      await this.uploadPendingItems();

      // 2. Download latest data
      await this.downloadUpdates();

      // 3. Handle conflicts
      await this.resolveConflicts();

      // 4. Clean up
      await this.cleanup();
    } finally {
      this.isSyncing = false;
    }
  }
}
```

**Sync Queue:**

```typescript
class SyncQueueManager {
  static async enqueue(
    operation: 'create' | 'update' | 'delete',
    tableName: string,
    recordId: string,
    data: any
  ) {
    await database.write(async () => {
      await database.get('sync_queue').create(record => {
        record.operation = operation;
        record.tableName = tableName;
        record.recordId = recordId;
        record.data = data;
        record.status = 'pending';
      });
    });
  }
}
```

---

## MODULE 5: HARDWARE INTEGRATION

### Camera & Photos

**Camera Service:**

```typescript
export class CameraService {
  async capturePhoto(options?: { quality?: number; base64?: boolean }) {
    const hasPermission = await this.requestCameraPermissions();
    if (!hasPermission) return null;

    const result = await ImagePicker.launchCameraAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: options?.quality || 0.8,
      base64: options?.base64 || true,
    });

    if (result.canceled) return null;
    return result.assets[0];
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

    return result.assets || [];
  }
}
```

---

### Location Services

**Location Service:**

```typescript
export class LocationService {
  async getCurrentLocation(): Promise<LocationData | null> {
    const hasPermission = await this.requestLocationPermissions();
    if (!hasPermission) return null;

    const location = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.High,
      timeout: 10000,
    });

    return {
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      accuracy: location.coords.accuracy,
      timestamp: location.timestamp,
    };
  }

  async reverseGeocode(lat: number, lng: number) {
    const results = await Location.reverseGeocodeAsync({
      latitude: lat,
      longitude: lng,
    });
    return results.length > 0 ? results[0] : null;
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

---

### Biometric Authentication

**Biometric Service:**

```typescript
export class BiometricService {
  async checkAvailability() {
    const [hasHardware, hasEnrolled, supportedTypes] = await Promise.all([
      LocalAuthentication.hasHardwareAsync(),
      LocalAuthentication.isEnrolledAsync(),
      LocalAuthentication.supportedAuthenticationTypesAsync(),
    ]);

    return {
      isAvailable: hasHardware && hasEnrolled,
      hardwareAvailable: hasHardware,
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

  async authenticate(config?: { title: string }) {
    const availability = await this.checkAvailability();
    if (!availability.isAvailable) {
      Alert.alert('Biometric Not Available', 'Please set up biometric authentication.');
      return false;
    }

    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: config?.title || 'Authenticate to access',
      fallbackLabel: 'Use Passcode',
      cancelLabel: 'Cancel',
    });

    return result.success;
  }
}
```

---

### Push Notifications

**Notification Service:**

```typescript
export class NotificationService {
  async initialize(): Promise<void> {
    const { status } = await Notifications.requestPermissionsAsync();
    if (status !== 'granted') return;

    const token = await Notifications.getExpoPushTokenAsync({
      projectId: Constants.expoConfig?.extra?.eas?.projectId,
    });

    this.pushToken = token.data;
    this.setupNotificationListeners();
  }

  private setupNotificationListeners(): void {
    Notifications.addNotificationReceivedListener((notification) => {
      // Handle foreground notification
    });

    Notifications.addNotificationResponseReceivedListener((response) => {
      // Handle notification tap
      const data = response.notification.request.content.data;
      // Navigate to screen
    });
  }

  async sendNotification(recipient: string, payload: any): Promise<void> {
    await fetch('https://exp.host/--/api/v2/push/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        to: recipient,
        title: payload.title,
        body: payload.body,
        data: payload.data || {},
        sound: 'default',
      }),
    });
  }
}
```

---

## MODULE 6: TESTING & QUALITY ASSURANCE

### Testing Pyramid

```
        /\
       /  \      E2E Tests (Few, Slow, Expensive)
      /    \     
     /______\    Integration Tests (Some, Medium)
    /        \
   /__________\  Unit Tests (Many, Fast, Cheap)
```

---

### Unit Testing (Jest)

**Jest Configuration:**

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  testRegex: '(/__tests__/.*|(\\.|/)(test|spec))\\.[jt]sx?$',
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

**Unit Test Example:**

```typescript
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
});
```

---

### Component Testing

**Component Test Example:**

```typescript
import { render, fireEvent, screen } from '@testing-library/react-native';

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

---

### E2E Testing (Detox)

**E2E Test Example:**

```typescript
// e2e/auth.e2e.js
describe('Authentication Flow', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
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

---

### CI/CD Pipeline

**GitHub Actions Workflow:**

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
```

---

## MODULE 7: SECURITY & PRODUCTION DEPLOYMENT

### OWASP Mobile Top 10

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

---

### Security Hardening

**Code Obfuscation:**

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
        properties: { regex: /^_/ },
      },
      output: {
        comments: false,
        beautify: false,
      },
    },
  },
};
```

**Certificate Pinning:**

```typescript
const EXPECTED_PUBLIC_KEYS = {
  production: ['sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='],
};

export const secureFetch = async (url: string, options?: RequestInit) => {
  // Validate certificate pinning
  const response = await fetch(url, {
    ...options,
    sslPinning: {
      certs: EXPECTED_PUBLIC_KEYS.production,
    },
  });
  return response;
};
```

---

### Code Signing

**iOS Code Signing:**
1. Generate CSR in Keychain Access
2. Create Certificate in Apple Developer Portal
3. Create App ID with bundle identifier
4. Create Provisioning Profile
5. Configure in Xcode

**Android Code Signing:**

```bash
# Generate keystore
keytool -genkey -v -keystore nexuscollect-release.keystore \
  -alias nexuscollect-release \
  -keyalg RSA -keysize 2048 -validity 10000
```

---

### OTA Updates

```typescript
import * as Updates from 'expo-updates';

export class OTAService {
  static async checkForUpdates() {
    const update = await Updates.checkForUpdateAsync();
    if (update.isAvailable) {
      await Updates.fetchUpdateAsync();
      await Updates.reloadAsync();
    }
  }
}
```

---

### App Store Submission

**EAS Commands:**

```bash
# Build for production
eas build --platform ios --profile production
eas build --platform android --profile production

# Submit to stores
eas submit --platform ios
eas submit --platform android
eas submit --platform all

# OTA Update
eas update --branch production --message "Update message"
```

---

## APPENDIX A: QUICK REFERENCE

### Key Commands

| Command | Purpose |
|---------|---------|
| `npx create-expo-app NexusCollect --template` | Create project |
| `npx expo start` | Start development |
| `npx expo start --ios` | Run on iOS |
| `npx expo start --android` | Run on Android |
| `eas build --platform ios --profile production` | Build for iOS |
| `eas build --platform android --profile production` | Build for Android |
| `eas submit --platform ios` | Submit to App Store |
| `eas submit --platform android` | Submit to Play Store |
| `eas update --branch production --message "Update"` | OTA Update |
| `npm test` | Run tests |
| `npm run test:coverage` | Run tests with coverage |
| `npm run lint` | Run ESLint |
| `npm run type-check` | TypeScript type check |

---

### Key Concepts

| Concept | Definition |
|---------|------------|
| **Bridge** | Communication layer between JS and native code |
| **JSI** | JavaScript Interface - New Architecture |
| **TurboModules** | Lazy-loaded native modules |
| **RLS** | Row Level Security - Database access control |
| **OTA** | Over-The-Air updates |
| **EAS** | Expo Application Services |
| **CI/CD** | Continuous Integration/Continuous Deployment |

---

## APPENDIX B: COMMON PATTERNS

### Zustand Store Pattern

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      data: null,
      setData: (data) => set({ data }),
    }),
    { name: 'store-storage' }
  )
);
```

### Repository Pattern

```typescript
export class Repository {
  static async getAll() {
    return await database.get('table').query().fetch();
  }

  static async create(data: any) {
    return await database.write(async () => {
      return await database.get('table').create(record => {
        Object.assign(record, data);
      });
    });
  }
}
```

### Navigation Pattern

```typescript
const Stack = createNativeStackNavigator<StackParamList>();

function Navigator() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Screen1" component={Screen1} />
      <Stack.Screen name="Screen2" component={Screen2} />
    </Stack.Navigator>
  );
}
```

---

## APPENDIX C: TROUBLESHOOTING

### Common Issues

| Issue | Solution |
|-------|----------|
| `xcodebuild: command not found` | Install Xcode Command Line Tools |
| `pod: command not found` | `sudo gem install cocoapods` |
| `Module not found` | `npm install` or `npx expo install` |
| `Build failed` | `npx expo start --clear` |
| `Simulator won't open` | Check Xcode → Settings → Platforms |

### Error Log Template

| Date | Error | Solution |
|------|-------|----------|
| | | |
| | | |
| | | |

---

## NOTES & ANNOTATIONS

### Personal Notes

_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________

### Important Code Snippets

_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________

### Questions for Review

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

---

*These notes are a comprehensive reference for the "Mastering Mobile Development Beyond the UI" course. Use them alongside the course materials and hands-on exercises for optimal learning.*
