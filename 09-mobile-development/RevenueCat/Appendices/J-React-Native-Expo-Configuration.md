# Appendix J: React Native Expo Configuration

## Overview

This appendix provides comprehensive configuration instructions for using RevenueCat with React Native Expo. Expo's managed workflow simplifies React Native development but requires specific configuration for native modules like RevenueCat.

Think of this as your "Expo setup guide" – everything you need to know about integrating RevenueCat with Expo, from basic setup to advanced configurations.

---

## 1. Expo Compatibility

### Supported Workflows

| Workflow | Support | Notes |
|----------|---------|-------|
| **Expo Managed** | ✅ Supported | Requires Expo SDK 46+ |
| **Expo Development Builds** | ✅ Fully Supported | Recommended for production |
| **Expo Go** | ✅ Limited | Only works with Test Store |
| **React Native CLI** | ✅ Fully Supported | Not using Expo |

### Version Requirements

| Package | Minimum Version | Recommended Version |
|---------|-----------------|---------------------|
| Expo SDK | 46.0.0 | 50.0.0+ |
| react-native-purchases | 7.0.0 | 7.10.0+ |
| expo-build-properties | 0.8.0 | 0.12.0+ |
| expo-dev-client | 3.0.0 | 3.4.0+ |

### Compatibility Matrix

```
Expo SDK 46-49  → react-native-purchases 6.x
Expo SDK 50+    → react-native-purchases 7.x
Expo SDK 51+    → react-native-purchases 7.x (fully compatible)
```

---

## 2. Project Setup

### Create Expo Project

```bash
# Create new Expo project with TypeScript
npx create-expo-app FitTrackPro --template

# Navigate to project
cd FitTrackPro

# Install required dependencies
npx expo install react-native-purchases @react-native-async-storage/async-storage
```

### Install Development Build Dependencies

```bash
# Install development build tools
npx expo install expo-dev-client expo-build-properties

# Install iOS and Android specific dependencies
npx expo install react-native-safe-area-context react-native-screens
```

### Configure app.json

**File: `app.json`**

```json
{
  "expo": {
    "name": "FitTrack Pro",
    "slug": "fittrackpro",
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
      "bundleIdentifier": "com.yourcompany.fittrackpro",
      "buildNumber": "1",
      "infoPlist": {
        "NSUserActivityTypes": ["com.yourcompany.fittrackpro.purchase"],
        "SKAdNetworkItems": [
          {
            "SKAdNetworkIdentifier": "YOUR_SK_AD_NETWORK_ID"
          }
        ]
      }
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.yourcompany.fittrackpro",
      "versionCode": 1,
      "permissions": ["com.android.vending.BILLING"]
    },
    "plugins": [
      "expo-build-properties",
      [
        "expo-build-properties",
        {
          "ios": {
            "deploymentTarget": "13.0",
            "useFrameworks": "static"
          },
          "android": {
            "minSdkVersion": 21,
            "targetSdkVersion": 33,
            "compileSdkVersion": 33,
            "kotlinVersion": "1.8.0"
          }
        }
      ]
    ],
    "extra": {
      "eas": {
        "projectId": "your-eas-project-id"
      },
      "revenueCat": {
        "iosApiKey": "app_ios_development_123",
        "androidApiKey": "app_android_development_123"
      }
    }
  }
}
```

---

## 3. Environment Configuration

### Install Environment Variable Package

```bash
# For Expo managed workflow
npx expo install expo-constants

# For development builds (recommended)
npx expo install expo-config
```

### Configure Environment Variables

**File: `.env.development`**

```bash
REVENUECAT_IOS_API_KEY=app_ios_development_123
REVENUECAT_ANDROID_API_KEY=app_android_development_123
```

**File: `.env.production`**

```bash
REVENUECAT_IOS_API_KEY=app_ios_production_456
REVENUECAT_ANDROID_API_KEY=app_android_production_456
```

### Create Environment Config

**File: `src/config/env.ts`**

```typescript
import Constants from 'expo-constants';

/**
 * Environment Configuration for Expo
 * 
 * Uses Expo Constants for environment variables
 * and build-time configuration
 */
export const env = {
  // RevenueCat API Keys
  revenueCatIosApiKey: Constants.expoConfig?.extra?.revenueCat?.iosApiKey || '',
  revenueCatAndroidApiKey: Constants.expoConfig?.extra?.revenueCat?.androidApiKey || '',
  
  // Backend API
  backendApiUrl: Constants.expoConfig?.extra?.backendApiUrl || 'http://localhost:3000/api',
  
  // Feature Flags
  enableAnalytics: Constants.expoConfig?.extra?.enableAnalytics !== false,
  enableDebugLogs: Constants.expoConfig?.extra?.enableDebugLogs || false,
  
  // App Information
  appName: Constants.expoConfig?.name || 'FitTrack Pro',
  appVersion: Constants.expoConfig?.version || '1.0.0',
  appBuild: Constants.expoConfig?.ios?.buildNumber || Constants.expoConfig?.android?.versionCode || '1',
};

// Validation
if (!env.revenueCatIosApiKey && !env.revenueCatAndroidApiKey) {
  console.warn('⚠️ RevenueCat API keys not configured');
}

export default env;
```

### Update app.json for Environment Variables

```json
{
  "expo": {
    // ... other config
    "extra": {
      "eas": {
        "projectId": "your-eas-project-id"
      },
      "revenueCat": {
        "iosApiKey": "app_ios_development_123",
        "androidApiKey": "app_android_development_123"
      },
      "backendApiUrl": "http://localhost:3000/api",
      "enableAnalytics": true,
      "enableDebugLogs": false
    }
  }
}
```

---

## 4. Development Build Configuration

### Install Development Build Dependencies

```bash
# Install development build tools
npx expo install expo-dev-client expo-build-properties

# Install RevenueCat native dependencies
npx expo install react-native-purchases

# iOS specific
cd ios && pod install && cd ..
```

### Configure Build Properties

**File: `app.json` (with build properties)**

```json
{
  "expo": {
    // ... other config
    "plugins": [
      "expo-build-properties",
      [
        "expo-build-properties",
        {
          "ios": {
            "deploymentTarget": "13.0",
            "useFrameworks": "static"
          },
          "android": {
            "minSdkVersion": 21,
            "targetSdkVersion": 33,
            "compileSdkVersion": 33,
            "kotlinVersion": "1.8.0"
          }
        }
      ]
    ]
  }
}
```

### Create Development Build

```bash
# Create iOS development build
npx eas build --platform ios --profile development

# Create Android development build
npx eas build --platform android --profile development

# Run development build locally
npx expo run:ios
npx expo run:android
```

**File: `eas.json`**

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      },
      "android": {
        "buildType": "apk"
      }
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": true
      },
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your-apple-id@example.com",
        "ascAppId": "your-asc-app-id",
        "appleTeamId": "your-apple-team-id"
      },
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

---

## 5. RevenueCat SDK Initialization with Expo

### Create RevenueCat Service

**File: `src/services/RevenueCatService.ts`**

```typescript
import Purchases, { 
  LOG_LEVEL, 
  PurchasesConfiguration,
  CustomerInfo,
  Offerings,
  Package,
} from 'react-native-purchases';
import { Platform } from 'react-native';
import env from '../config/env';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * RevenueCat Service for Expo
 * 
 * Handles initialization and configuration specific to Expo apps
 */
export class RevenueCatService {
  private static instance: RevenueCatService;
  private isConfigured: boolean = false;
  
  private constructor() {}
  
  public static getInstance(): RevenueCatService {
    if (!RevenueCatService.instance) {
      RevenueCatService.instance = new RevenueCatService();
    }
    return RevenueCatService.instance;
  }
  
  /**
   * Initialize RevenueCat SDK
   * 
   * Note: In Expo Go, only the Test Store works
   * For production, use development builds
   */
  public async initialize(): Promise<void> {
    if (this.isConfigured) {
      console.log('RevenueCat already configured');
      return;
    }
    
    try {
      // Get platform-specific API key
      const apiKey = Platform.select({
        ios: env.revenueCatIosApiKey,
        android: env.revenueCatAndroidApiKey,
        default: '',
      });
      
      if (!apiKey) {
        throw new Error('RevenueCat API key not configured');
      }
      
      // Set log level
      const logLevel = env.enableDebugLogs ? LOG_LEVEL.DEBUG : LOG_LEVEL.INFO;
      Purchases.setLogLevel(logLevel);
      
      // Get stored user ID
      const storedUserId = await AsyncStorage.getItem('@app_user_id');
      
      // Configure
      const config: PurchasesConfiguration = {
        apiKey,
        appUserID: storedUserId || undefined,
        verboseLogs: env.enableDebugLogs,
        logLevel,
      };
      
      await Purchases.configure(config);
      
      this.isConfigured = true;
      console.log('✅ RevenueCat initialized successfully');
      
    } catch (error) {
      console.error('❌ RevenueCat initialization failed:', error);
      throw error;
    }
  }
  
  /**
   * Check if in Expo Go
   */
  public isExpoGo(): boolean {
    // @ts-ignore - Constants is available in Expo
    return Constants.appOwnership === 'expo';
  }
  
  /**
   * Get platform-specific API key
   */
  private getApiKey(): string {
    if (this.isExpoGo()) {
      // In Expo Go, only Test Store works
      return env.revenueCatTestStoreKey || '';
    }
    
    return Platform.select({
      ios: env.revenueCatIosApiKey,
      android: env.revenueCatAndroidApiKey,
      default: '',
    });
  }
}

export const revenueCatService = RevenueCatService.getInstance();
```

### Initialize in App

**File: `App.tsx`**

```typescript
import React, { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator } from 'react-native';
import { revenueCatService } from './src/services/RevenueCatService';
import { SubscriptionProvider } from './src/context/SubscriptionContext';
import { RootNavigator } from './src/navigation/RootNavigator';

const AppContent = () => {
  const [isReady, setIsReady] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    const initialize = async () => {
      try {
        await revenueCatService.initialize();
        setIsReady(true);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Initialization failed');
      }
    };
    
    initialize();
  }, []);
  
  if (error) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 }}>
        <Text style={{ fontSize: 18, color: '#E74C3C', textAlign: 'center' }}>
          {error}
        </Text>
        <Text style={{ fontSize: 14, color: '#666', marginTop: 8, textAlign: 'center' }}>
          Please check your configuration
        </Text>
      </View>
    );
  }
  
  if (!isReady) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color="#4A90D9" />
        <Text style={{ marginTop: 12, fontSize: 16, color: '#666' }}>
          Initializing...
        </Text>
      </View>
    );
  }
  
  return (
    <SubscriptionProvider>
      <RootNavigator />
    </SubscriptionProvider>
  );
};

const App = () => {
  return <AppContent />;
};

export default App;
```

---

## 6. Expo Go Limitations

### Features Not Available in Expo Go

| Feature | Expo Go | Development Build |
|---------|---------|-------------------|
| **RevenueCat SDK** | ❌ Limited | ✅ Full |
| **Test Store** | ✅ Yes | ✅ Yes |
| **App Store Purchases** | ❌ No | ✅ Yes |
| **Google Play Purchases** | ❌ No | ✅ Yes |
| **Receipt Validation** | ❌ No | ✅ Yes |
| **Subscription Management** | ❌ No | ✅ Yes |
| **Restore Purchases** | ❌ No | ✅ Yes |

### Working with Expo Go

**File: `src/services/ExpoGoAdapter.ts`**

```typescript
import { Platform } from 'react-native';
import Purchases from 'react-native-purchases';

/**
 * Expo Go Adapter
 * 
 * Provides fallback functionality for Expo Go environment
 */
export class ExpoGoAdapter {
  private static instance: ExpoGoAdapter;
  
  private constructor() {}
  
  public static getInstance(): ExpoGoAdapter {
    if (!ExpoGoAdapter.instance) {
      ExpoGoAdapter.instance = new ExpoGoAdapter();
    }
    return ExpoGoAdapter.instance;
  }
  
  /**
   * Check if running in Expo Go
   */
  public isExpoGo(): boolean {
    // @ts-ignore
    return Constants?.appOwnership === 'expo';
  }
  
  /**
   * Get appropriate API key for the environment
   */
  public getApiKey(): string {
    if (this.isExpoGo()) {
      // Use Test Store API key
      return process.env.EXPO_REVENUECAT_TEST_STORE_KEY || '';
    }
    
    return Platform.select({
      ios: process.env.REVENUECAT_IOS_API_KEY || '',
      android: process.env.REVENUECAT_ANDROID_API_KEY || '',
      default: '',
    });
  }
  
  /**
   * Show Expo Go warning
   */
  public showExpoGoWarning(): void {
    if (this.isExpoGo()) {
      console.warn(
        '⚠️ Running in Expo Go. RevenueCat features are limited.\n' +
        'Use development builds for full functionality.'
      );
    }
  }
}
```

---

## 7. Test Store Configuration

### Configure Test Store

**File: `src/config/testStore.ts`**

```typescript
/**
 * Test Store Configuration
 * 
 * Use for testing in Expo Go or sandbox environments
 * Never use in production
 */
export const testStoreConfig = {
  // Test product IDs
  products: {
    monthly: 'com.fittrackpro.monthly.test',
    annual: 'com.fittrackpro.annual.test',
  },
  
  // Test offers
  offers: {
    monthlyTrial: 'com.fittrackpro.monthly.trial',
    annualDiscount: 'com.fittrackpro.annual.discount',
  },
  
  // Test user IDs
  testUsers: {
    free: 'test_free_001',
    subscriber: 'test_subscriber_001',
    trial: 'test_trial_001',
  },
};

/**
 * Check if using Test Store
 */
export const isUsingTestStore = (apiKey: string): boolean => {
  return apiKey.startsWith('test_') || apiKey.includes('test_store');
};
```

---

## 8. Production Build Configuration

### EAS Build Configuration

**File: `eas.json`**

```json
{
  "build": {
    "production": {
      "autoIncrement": true,
      "ios": {
        "image": "latest",
        "distribution": "store",
        "simulator": false
      },
      "android": {
        "image": "latest",
        "distribution": "store",
        "buildType": "app-bundle"
      },
      "env": {
        "REVENUECAT_IOS_API_KEY": "app_ios_production_456",
        "REVENUECAT_ANDROID_API_KEY": "app_android_production_456",
        "BACKEND_API_URL": "https://api.fittrackpro.com/api"
      }
    }
  }
}
```

### Production Environment Variables

**File: `.env.production`**

```bash
# RevenueCat Production Keys
REVENUECAT_IOS_API_KEY=app_ios_production_456
REVENUECAT_ANDROID_API_KEY=app_android_production_456

# Backend Production URL
BACKEND_API_URL=https://api.fittrackpro.com/api

# Feature Flags - Production
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGS=false

# Monitoring
SENTRY_DSN=https://sentry.io/your-project-dsn
```

### Build for Production

```bash
# Build iOS for App Store
npx eas build --platform ios --profile production

# Build Android for Google Play
npx eas build --platform android --profile production

# Submit to App Store
npx eas submit --platform ios

# Submit to Google Play
npx eas submit --platform android
```

---

## 9. Troubleshooting Expo Issues

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| **"Purchases module not found"** | Run `npx expo install react-native-purchases` |
| **Pod install fails** | Run `cd ios && pod install && cd ..` |
| **Build fails on iOS** | Check deployment target (iOS 13+) |
| **Build fails on Android** | Check minSdkVersion (21+) |
| **Expo Go purchases not working** | Use development builds |
| **API key invalid** | Check platform-specific keys |

### Debug Commands

```bash
# Clear Expo cache
npx expo start -c

# Clear iOS build cache
cd ios && pod deintegrate && pod install && cd ..

# Clear Android build cache
cd android && ./gradlew clean && cd ..

# Check environment variables
npx expo print:env

# Check Expo configuration
npx expo config

# Check native dependencies
npx expo install --check
```

---

## Summary

This appendix covers Expo-specific configuration for RevenueCat:

1. **Compatibility**: Supported workflows and version requirements
2. **Project Setup**: Creating and configuring Expo projects
3. **Environment**: Environment variable configuration
4. **Development Builds**: Setting up development builds
5. **SDK Initialization**: RevenueCat with Expo
6. **Expo Go**: Limitations and workarounds
7. **Test Store**: Testing in Expo Go
8. **Production**: Building for production
9. **Troubleshooting**: Common issues and solutions

### Key Takeaways

1. **Use Development Builds** for production-quality testing
2. **Expo Go** only works with Test Store
3. **Environment Variables** require special handling
4. **Build Properties** must be configured correctly
5. **EAS Build** simplifies production deployment
