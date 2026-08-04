# Primer 7: Mobile Security & Deployment

## Your Complete Guide to Shipping Production-Ready Apps

Welcome to the Security & Deployment Primer! This guide covers everything you need to know about securing your mobile app and deploying it to the Apple App Store and Google Play Store. Security and deployment are the final steps in your development journey—they protect your users and get your app into their hands.

---

## S.1 Mobile Security Fundamentals

### The Concept: Protecting Your Users and Data

Mobile security is about protecting your app, your users' data, and your backend infrastructure from threats. It's a multi-layered approach that covers everything from code obfuscation to secure data storage.

**Simple Analogy:** Think of mobile security like a bank. You have multiple layers of protection:
- **Outer layer:** Security cameras, guards (App Store review, SSL/TLS)
- **Middle layer:** Vault door (Code signing, certificate pinning)
- **Inner layer:** Safety deposit boxes (Data encryption, secure storage)
- **Personal layer:** ID verification (Authentication, biometrics)

### OWASP Mobile Top 10

1. **Improper Platform Usage:** Misusing platform features
2. **Insecure Data Storage:** Storing sensitive data insecurely
3. **Insecure Communication:** Unencrypted network traffic
4. **Insecure Authentication:** Weak authentication mechanisms
5. **Insufficient Cryptography:** Weak encryption algorithms
6. **Insecure Authorization:** Improper access control
7. **Client Code Quality:** Memory leaks, buffer overflows
8. **Code Tampering:** Modification of app code
9. **Reverse Engineering:** Decompiling and analyzing app
10. **Extraneous Functionality:** Hidden features or backdoors

---

## S.2 Security Hardening Implementation

### The Concept: Implementing Security Controls

Here's how to implement the security controls that protect your app.

### Complete Security Implementation

```typescript
// 1. Code Obfuscation Configuration
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

// 2. Certificate Pinning
// src/utils/certificatePinning.ts
import { fetch } from 'react-native-ssl-pinning';

// Public key hashes for your server certificates
const EXPECTED_PUBLIC_KEYS = {
  production: [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
  ],
  staging: [
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
  ],
};

export const secureFetch = async (url: string, options?: RequestInit) => {
  // Validate certificate pinning
  const response = await fetch(url, {
    ...options,
    timeout: 30000,
    sslPinning: {
      certs: EXPECTED_PUBLIC_KEYS.production,
    },
  });
  
  return response;
};

// 3. Secure Storage
// src/utils/secureStorage.ts
import * as SecureStore from 'expo-secure-store';
import * as Crypto from 'expo-crypto';

export class SecureStorage {
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

  async set(key: string, value: string) {
    if (!this.encryptionKey) await this.initialize();
    // Encrypt value before storing
    const encrypted = await this.encrypt(value);
    await SecureStore.setItemAsync(key, encrypted);
  }

  async get(key: string): Promise<string | null> {
    const encrypted = await SecureStore.getItemAsync(key);
    if (!encrypted) return null;
    return this.decrypt(encrypted);
  }

  async delete(key: string) {
    await SecureStore.deleteItemAsync(key);
  }

  private async encrypt(value: string): Promise<string> {
    // In production, use a proper encryption library
    // This is a simplified example
    const encoder = new TextEncoder();
    const data = encoder.encode(value);
    const base64 = btoa(String.fromCharCode(...data));
    return `encrypted_${base64}`;
  }

  private async decrypt(encrypted: string): Promise<string> {
    const base64 = encrypted.replace('encrypted_', '');
    const binary = atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return new TextDecoder().decode(bytes);
  }
}

export const secureStorage = new SecureStorage();

// 4. Runtime Integrity Checks
// src/utils/integrity.ts
import DeviceInfo from 'react-native-device-info';
import { Platform, Alert } from 'react-native';

export class IntegrityChecker {
  static async checkDeviceIntegrity(): Promise<{
    isCompromised: boolean;
    details: string[];
  }> {
    const details: string[] = [];
    let isCompromised = false;

    // Check for root/jailbreak
    try {
      const isRooted = await DeviceInfo.isRooted();
      if (isRooted) {
        details.push('Device is rooted/jailbroken');
        isCompromised = true;
      }
    } catch (error) {
      details.push('Failed to check root status');
    }

    // Check for emulator
    try {
      const isEmulator = await DeviceInfo.isEmulator();
      if (isEmulator && !__DEV__) {
        details.push('Running on emulator in production');
        isCompromised = true;
      }
    } catch (error) {
      details.push('Failed to check emulator status');
    }

    // Check for debug mode
    try {
      if (__DEV__ && !__DEV__) {
        // This condition is always false in production
        details.push('Running in debug mode');
        isCompromised = true;
      }
    } catch (error) {
      details.push('Failed to check debug status');
    }

    return { isCompromised, details };
  }

  static handleCompromisedDevice() {
    Alert.alert(
      'Security Warning',
      'This device appears to be compromised. For your security, some features may be limited.',
      [{ text: 'OK' }]
    );
    // Optionally restrict app functionality
  }
}
```

---

## S.3 Code Signing & Certificates

### The Concept: Proving Your Identity

Code signing proves that your app comes from you and hasn't been tampered with. Think of it like a signature on a legal document.

### Complete Code Signing Guide

#### iOS Code Signing

```bash
# 1. Generate Certificate Signing Request (CSR)
# Open Keychain Access → Certificate Assistant → Request a Certificate...
# Save as: CertificateSigningRequest.certSigningRequest

# 2. Create Development Certificate
# Apple Developer Portal → Certificates → Add (+) → iOS App Development
# Upload CSR → Download certificate (development.cer)
# Double-click to install in Keychain

# 3. Create App ID
# Apple Developer Portal → Identifiers → App IDs → Add (+)
# Description: NexusCollect
# Bundle ID: com.yourcompany.nexuscollect
# Enable capabilities as needed

# 4. Create Provisioning Profile
# Apple Developer Portal → Profiles → Add (+)
# Select: iOS App Development
# Select App ID: NexusCollect
# Select certificates
# Select devices
# Download provisioning profile

# 5. Configure in Xcode
# Open ios/NexusCollect.xcworkspace
# Select project → Signing & Capabilities
# Check "Automatically manage signing"
# Select team
```

#### Android Code Signing

```bash
# 1. Generate Keystore
keytool -genkey -v -keystore nexuscollect-release.keystore \
  -alias nexuscollect-release \
  -keyalg RSA -keysize 2048 -validity 10000

# You'll be prompted for:
# - Keystore password
# - Key password
# - Your name
# - Organizational unit
# - Organization
# - City, State, Country

# 2. Configure Gradle
# android/gradle.properties
NEXUSCOLLECT_RELEASE_STORE_FILE=nexuscollect-release.keystore
NEXUSCOLLECT_RELEASE_STORE_PASSWORD=your_keystore_password
NEXUSCOLLECT_RELEASE_KEY_ALIAS=nexuscollect-release
NEXUSCOLLECT_RELEASE_KEY_PASSWORD=your_key_password

# 3. Configure app/build.gradle
android {
  signingConfigs {
    release {
      storeFile file(NEXUSCOLLECT_RELEASE_STORE_FILE)
      storePassword NEXUSCOLLECT_RELEASE_STORE_PASSWORD
      keyAlias NEXUSCOLLECT_RELEASE_KEY_ALIAS
      keyPassword NEXUSCOLLECT_RELEASE_KEY_PASSWORD
    }
  }
  buildTypes {
    release {
      signingConfig signingConfigs.release
      minifyEnabled true
      proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
  }
}

# 4. EAS Build Configuration
# app.json
{
  "expo": {
    "android": {
      "package": "com.yourcompany.nexuscollect"
    }
  }
}

# 5. Build for Release
eas build --platform android --profile production
```

---

## S.4 App Store Preparation

### The Concept: Getting Your App Ready for Review

App Store preparation involves creating assets, writing metadata, and ensuring your app complies with store guidelines.

### Complete App Store Guide

#### App Store Assets

```bash
# 1. App Icons
# Create 1024x1024 icon.png
# Use tool: https://icon.kitchen/
# Generate all required sizes

# 2. Screenshots
# iPhone: 1290x2796 (6.5")
# iPad: 2048x2732 (12.9")
# Use simulator to capture screenshots

# 3. App Preview Video (optional)
# Record using QuickTime Player
# Format: .mp4
# Duration: 15-30 seconds

# 4. Feature Graphic (Android)
# 1024x500px
```

#### App Store Metadata

```typescript
// app-store-metadata.ts
export const appStoreMetadata = {
  // iOS (App Store Connect)
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
      
      Perfect for:
      • Field researchers
      • Survey teams
      • Construction inspectors
      • Environmental monitors
      • Healthcare professionals
    `,
    keywords: 'field data,collection,offline,survey,forms,gps,photos,sync',
    supportUrl: 'https://nexuscollect.com/support',
    privacyPolicyUrl: 'https://nexuscollect.com/privacy',
    termsOfServiceUrl: 'https://nexuscollect.com/terms',
    copyright: '© 2024 NexusCollect Inc.',
    category: 'Business',
    languages: ['en-US'],
  },
  
  // Android (Google Play Console)
  android: {
    name: 'NexusCollect',
    shortDescription: 'Offline-first field data collection',
    fullDescription: `
      NexusCollect is a powerful field data collection platform designed for professionals who need to capture, manage, and sync data in real-time—even offline.
      
      📱 OFFLINE-FIRST
      Collect data anywhere, even without internet. NexusCollect automatically syncs when you're back online.
      
      📝 CUSTOM FORMS
      Build custom data collection forms with our intuitive form builder.
      
      📍 GPS LOCATION
      Automatically tag entries with GPS coordinates.
      
      📷 PHOTO CAPTURE
      Capture photos directly in the app.
      
      🔒 SECURE
      Your data is encrypted end-to-end.
    `,
    category: 'Business',
    contentRating: 'Everyone',
    languages: ['en-US'],
  },
};
```

#### Privacy Policy

```markdown
# Privacy Policy for NexusCollect

Last updated: January 1, 2024

## 1. Information We Collect

We collect information you provide directly, including:
- Name and email address
- Profile information
- Location data (with permission)
- Photos (with permission)
- Device information

## 2. How We Use Information

We use your information to:
- Provide and improve our services
- Sync your data across devices
- Send notifications
- Analyze app usage

## 3. Data Storage and Security

Your data is:
- Encrypted in transit (SSL/TLS)
- Encrypted at rest
- Stored securely in the cloud
- Protected by biometric authentication

## 4. Your Rights

You have the right to:
- Access your data
- Correct your data
- Delete your data
- Opt-out of notifications

## 5. Contact Us

Contact us at: support@nexuscollect.com
```

---

## S.5 Over-the-Air (OTA) Updates

### The Concept: Instant Updates Without Store Approval

OTA updates allow you to push bug fixes and minor updates directly to users without going through app store review.

### Complete OTA Guide

```bash
# 1. Configure OTA Updates in app.json
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

# 2. Configure EAS Build
# eas.json
{
  "build": {
    "production": {
      "channel": "production"
    }
  }
}

# 3. Push OTA Update
eas update --branch production --message "Fix: Critical bug fix"

# 4. Channel Configuration
# Development: development
# Staging: staging
# Production: production

# 5. Update Management
# src/utils/ota.ts
import * as Updates from 'expo-updates';

export class OTAService {
  static async checkForUpdates() {
    try {
      const update = await Updates.checkForUpdateAsync();
      if (update.isAvailable) {
        await Updates.fetchUpdateAsync();
        await Updates.reloadAsync();
      }
    } catch (error) {
      console.error('OTA update failed:', error);
    }
  }

  static async getUpdateStatus() {
    return {
      isUpdateAvailable: Updates.isUpdateAvailable,
      isUpdatePending: Updates.isUpdatePending,
      lastUpdateCheck: Updates.lastUpdateCheck,
    };
  }
}
```

---

## S.6 App Store Submission

### The Concept: Submitting Your App to Stores

The final step in your development journey—submitting your app to the Apple App Store and Google Play Store.

### Complete Submission Guide

#### iOS App Store Submission

```bash
# 1. Prepare App Store Connect
# https://appstoreconnect.apple.com
# Create app
# Select bundle ID
# Fill in metadata
# Upload screenshots

# 2. Build for Distribution
eas build --platform ios --profile production

# 3. Submit to App Store
eas submit --platform ios --latest

# 4. Manual Submission
# Open App Store Connect
# Select app → TestFlight
# Submit for review
# Wait for approval (1-3 days)

# 5. Post-Submission Checklist
# ✓ Privacy policy URL
# ✓ Support URL
# ✓ Marketing URL
# ✓ Copyright information
# ✓ App icon
# ✓ Screenshots
# ✓ App preview
# ✓ App description
# ✓ Keywords
# ✓ Category
# ✓ Content rating
```

#### Android Play Store Submission

```bash
# 1. Prepare Google Play Console
# https://play.google.com/console
# Create app
# Select package name
# Fill in metadata
# Upload screenshots

# 2. Build for Distribution
eas build --platform android --profile production

# 3. Submit to Play Store
eas submit --platform android --latest

# 4. Manual Submission
# Open Google Play Console
# Select app → Release Management
# Create release
# Upload APK/AAB
# Fill in release notes
# Submit for review
# Wait for approval (1-2 days)

# 5. Post-Submission Checklist
# ✓ Feature graphic
# ✓ Screenshots
# ✓ App description
# ✓ Short description
# ✓ Category
# ✓ Content rating
# ✓ Privacy policy
# ✓ Terms of service
```

---

## S.7 Post-Launch Monitoring

### The Concept: Keeping Your App Healthy

After launch, monitor your app for issues, performance problems, and user feedback.

### Complete Monitoring Guide

```typescript
// 1. Error Tracking with Sentry
// src/utils/errorTracking.ts
import * as Sentry from 'sentry-expo';
import { Platform } from 'react-native';

Sentry.init({
  dsn: 'YOUR_SENTRY_DSN',
  environment: CONFIG.environment,
  release: APP_VERSION,
  enableInExpoDevelopment: false,
  beforeSend: (event) => {
    // Filter out sensitive data
    delete event.user?.email;
    return event;
  },
});

export const errorTracker = {
  captureException: (error: Error, context?: any) => {
    Sentry.captureException(error, {
      extra: {
        ...context,
        platform: Platform.OS,
        version: APP_VERSION,
      },
    });
  },
  
  captureMessage: (message: string) => {
    Sentry.captureMessage(message);
  },
  
  setUser: (user: { id: string; email?: string }) => {
    Sentry.setUser({ id: user.id, email: user.email });
  },
};

// 2. Performance Monitoring
// src/utils/performance.ts
export const performanceTracker = {
  measure: async <T>(name: string, fn: () => Promise<T>): Promise<T> => {
    const start = performance.now();
    try {
      const result = await fn();
      const duration = performance.now() - start;
      
      if (duration > 1000) {
        console.warn(`Slow operation: ${name} took ${duration.toFixed(2)}ms`);
      }
      
      return result;
    } catch (error) {
      throw error;
    }
  },
  
  trackRender: (componentName: string, renderTime: number) => {
    if (renderTime > 100) {
      console.warn(`Slow render: ${componentName} took ${renderTime.toFixed(2)}ms`);
    }
  },
};

// 3. App Health Monitoring
// src/utils/health.ts
export class HealthMonitor {
  private static instance: HealthMonitor;
  private startTime: number = Date.now();
  private crashes: number = 0;
  private errors: number = 0;

  static getInstance(): HealthMonitor {
    if (!HealthMonitor.instance) {
      HealthMonitor.instance = new HealthMonitor();
    }
    return HealthMonitor.instance;
  }

  trackAppStart() {
    this.startTime = Date.now();
    console.log(`App started at ${new Date(this.startTime)}`);
  }

  trackAppClose() {
    const duration = Date.now() - this.startTime;
    console.log(`App ran for ${duration / 1000} seconds`);
  }

  trackCrash() {
    this.crashes++;
    console.warn(`App crashed ${this.crashes} times`);
  }

  trackError() {
    this.errors++;
    console.warn(`App errors: ${this.errors}`);
  }

  getHealthReport() {
    const uptime = Date.now() - this.startTime;
    return {
      uptime: uptime / 1000,
      uptimeString: `${Math.floor(uptime / 60000)}m ${Math.floor((uptime % 60000) / 1000)}s`,
      crashes: this.crashes,
      errors: this.errors,
      stability: this.errors === 0 && this.crashes === 0 ? 'Excellent' : 'Needs attention',
    };
  }
}
```

---

## S.8 Quick Reference

### Store Submission Checklist

| Item | iOS | Android | Status |
|------|-----|---------|--------|
| App Icon | ✅ | ✅ | |
| Screenshots | ✅ | ✅ | |
| App Description | ✅ | ✅ | |
| Privacy Policy | ✅ | ✅ | |
| Terms of Service | ✅ | ✅ | |
| Support URL | ✅ | ✅ | |
| Category | ✅ | ✅ | |
| Content Rating | ✅ | ✅ | |
| App Signing | ✅ | ✅ | |
| TestFlight/Internal Testing | ✅ | ✅ | |

### Security Checklist

| Security Item | Status |
|---------------|--------|
| Code Obfuscation | ✅ |
| Certificate Pinning | ✅ |
| Data Encryption | ✅ |
| Secure Storage | ✅ |
| Biometric Auth | ✅ |
| Runtime Integrity Checks | ✅ |
| OWASP Mobile Top 10 | ✅ |
| Privacy Manifest | ✅ |
| Permission Justification | ✅ |

### Common Commands

```bash
# Build
eas build --platform ios --profile production
eas build --platform android --profile production

# Submit
eas submit --platform ios
eas submit --platform android

# OTA Update
eas update --branch production --message "Update message"

# Test
npm test
npm run test:e2e

# Lint
npm run lint
npm run type-check
```

---

**Ready to deploy your app? Let's build NexusCollect!**
