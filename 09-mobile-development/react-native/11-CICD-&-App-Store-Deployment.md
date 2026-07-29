# Part 4: Testing, Performance & Production Deployment
## Phase 3: CI/CD & App Store Deployment

Welcome to the final phase of the entire series! Your TaskFlow app is feature-complete, thoroughly tested, and performance-optimized. Now it's time to automate your build process and deploy to the Apple App Store and Google Play Store. This is the moment you become a published mobile developer!

---

## Target 1: Continuous Integration with GitHub Actions

**The Target:** Set up automated testing and building with GitHub Actions.

**The Concept:** CI/CD automates the process of testing and building your app every time you push code. Think of it as having a robot that checks your work and prepares it for release.

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18.x]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint

      - name: Run type checking
        run: npm run type-check

      - name: Run unit tests
        run: npm test -- --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/lcov.info
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: true

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install EAS CLI
        run: npm install -g eas-cli

      - name: Login to Expo
        run: eas login --non-interactive --username ${{ secrets.EXPO_USERNAME }} --password ${{ secrets.EXPO_PASSWORD }}

      - name: Build iOS
        run: eas build --platform ios --non-interactive --no-wait
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}

      - name: Build Android
        run: eas build --platform android --non-interactive --no-wait
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}

  deploy:
    name: Deploy to Stores
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install EAS CLI
        run: npm install -g eas-cli

      - name: Login to Expo
        run: eas login --non-interactive --username ${{ secrets.EXPO_USERNAME }} --password ${{ secrets.EXPO_PASSWORD }}

      - name: Submit to iOS App Store
        run: eas submit --platform ios --non-interactive
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}

      - name: Submit to Google Play Store
        run: eas submit --platform android --non-interactive
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
```

### GitHub Actions for Pull Request Checks

```yaml
# .github/workflows/pr-checks.yml
name: PR Checks

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  validate:
    name: Validate PR
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint

      - name: Run type checking
        run: npm run type-check

      - name: Run tests with coverage
        run: npm test -- --coverage

      - name: Check bundle size
        run: npm run bundle:size

      - name: Comment PR with results
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const coverage = JSON.parse(fs.readFileSync('./coverage/coverage-summary.json', 'utf8'));
            const comment = `## PR Validation Results
            - ✅ Linting passed
            - ✅ Type checking passed
            - ✅ Tests passed (${coverage.total.statements.pct}% coverage)
            - ✅ Bundle size check passed
            `;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

---

## Target 2: EAS Build Configuration

**The Target:** Configure EAS Build for automated app builds.

**The Concept:** EAS Build handles the complex build process for iOS and Android, managing certificates, provisioning profiles, and build variants.

### EAS Configuration Files

```json
// eas.json - EAS Build configuration
{
  "cli": {
    "version": ">= 3.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "channel": "development",
      "ios": {
        "simulator": true
      },
      "android": {
        "buildType": "apk"
      }
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview",
      "ios": {
        "simulator": false
      },
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "distribution": "store",
      "channel": "production",
      "autoIncrement": true,
      "ios": {
        "image": "latest",
        "simulator": false,
        "resourceClass": "m1-medium"
      },
      "android": {
        "buildType": "app-bundle",
        "image": "latest",
        "resourceClass": "medium"
      },
      "env": {
        "APP_ENV": "production",
        "SENTRY_DSN": "https://your-sentry-dsn"
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "$APPLE_ID",
        "ascAppId": "$ASC_APP_ID",
        "appleTeamId": "$APPLE_TEAM_ID"
      },
      "android": {
        "track": "production",
        "serviceAccountKeyPath": "./service-account-key.json",
        "packageName": "com.yourcompany.taskflow"
      }
    }
  }
}
```

### App Configuration

```json
// app.json - Expo app configuration
{
  "expo": {
    "name": "TaskFlow",
    "slug": "taskflow",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": ["**/*"],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.yourcompany.taskflow",
      "buildNumber": "1",
      "infoPlist": {
        "UIBackgroundModes": ["remote-notification"],
        "NSCameraUsageDescription": "TaskFlow uses your camera to attach photos to tasks.",
        "NSPhotoLibraryUsageDescription": "TaskFlow uses your photo library to attach images to tasks.",
        "NSLocationWhenInUseUsageDescription": "TaskFlow uses your location to tag tasks with your current location.",
        "NSLocationAlwaysAndWhenInUseUsageDescription": "TaskFlow uses your location to tag tasks with your current location."
      }
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.yourcompany.taskflow",
      "versionCode": 1,
      "permissions": [
        "android.permission.CAMERA",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.ACCESS_FINE_LOCATION",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.RECEIVE_BOOT_COMPLETED",
        "android.permission.VIBRATE"
      ]
    },
    "extra": {
      "eas": {
        "projectId": "your-eas-project-id"
      }
    },
    "plugins": [
      [
        "expo-image-picker",
        {
          "photosPermission": "TaskFlow uses your photo library to attach images to tasks."
        }
      ],
      [
        "expo-camera",
        {
          "cameraPermission": "TaskFlow uses your camera to attach photos to tasks."
        }
      ],
      [
        "expo-location",
        {
          "locationAlwaysAndWhenInUsePermission": "TaskFlow uses your location to tag tasks with your current location.",
          "locationWhenInUsePermission": "TaskFlow uses your location to tag tasks with your current location."
        }
      ],
      [
        "expo-notifications",
        {
          "icon": "./assets/notification-icon.png",
          "color": "#3498db"
        }
      ]
    ]
  }
}
```

---

## Target 3: Code Signing and Certificates

**The Target:** Manage signing certificates and provisioning profiles.

**The Concept:** Code signing ensures your app is trusted and hasn't been tampered with. Apple and Google require signed apps for distribution.

### iOS Code Signing Setup

```bash
# 1. Generate a Certificate Signing Request (CSR)
# Open Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority
# Save as CertificateSigningRequest.certSigningRequest

# 2. Create a Distribution Certificate in Apple Developer Portal
# https://developer.apple.com/account/resources/certificates/add

# 3. Create an App ID
# https://developer.apple.com/account/resources/identifiers/add

# 4. Create a Provisioning Profile
# https://developer.apple.com/account/resources/profiles/add

# 5. Download and install certificates
# Double-click the .cer file to install in Keychain

# 6. Use EAS to manage signing automatically
eas credentials
```

### Android Code Signing Setup

```bash
# 1. Generate a keystore file
keytool -genkey -v -keystore taskflow-release.keystore -alias taskflow -keyalg RSA -keysize 2048 -validity 10000

# 2. Store keystore information in environment variables
# In your CI/CD pipeline or .env file:
export ANDROID_KEYSTORE_PASSWORD=your_password
export ANDROID_KEY_ALIAS=taskflow
export ANDROID_KEY_PASSWORD=your_key_password

# 3. Use EAS to manage signing
eas credentials --platform android
```

### Environment Variables for Builds

```bash
# .env.production
APP_ENV=production
API_URL=https://api.taskflow.app
SENTRY_DSN=https://your-sentry-dsn
EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=your-google-maps-api-key
EXPO_PUBLIC_ANALYTICS_KEY=your-analytics-key

# .env.staging
APP_ENV=staging
API_URL=https://staging-api.taskflow.app
SENTRY_DSN=https://staging-sentry-dsn
EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=your-staging-google-maps-api-key
EXPO_PUBLIC_ANALYTICS_KEY=your-staging-analytics-key
```

### Secure Environment Variables in GitHub

```bash
# Add secrets to GitHub repository
# Settings → Secrets and variables → Actions → New repository secret

# Required secrets:
# APPLE_ID
# APPLE_TEAM_ID
# ASC_APP_ID
# EXPO_TOKEN
# EXPO_USERNAME
# EXPO_PASSWORD
# SENTRY_AUTH_TOKEN
# SENTRY_DSN
# ANDROID_KEYSTORE_PASSWORD
# ANDROID_KEY_ALIAS
# ANDROID_KEY_PASSWORD
# ANDROID_GOOGLE_SERVICES_JSON (base64 encoded)
# GOOGLE_SERVICE_ACCOUNT_KEY (base64 encoded)
```

---

## Target 4: App Store Preparation

**The Target:** Prepare your app for submission to app stores.

**The Concept:** App stores have specific requirements for metadata, screenshots, and app content. We'll prepare everything needed for submission.

### App Store Metadata

```json
// store-metadata.json
{
  "ios": {
    "name": "TaskFlow - Task Manager",
    "subtitle": "Smart Task Management",
    "description": "TaskFlow is the ultimate task management app for busy professionals. Organize your tasks, collaborate with your team, and boost your productivity with our intuitive interface.",
    "keywords": "task, productivity, manager, organize, team, collaborate, schedule",
    "supportUrl": "https://taskflow.app/support",
    "marketingUrl": "https://taskflow.app",
    "privacyPolicyUrl": "https://taskflow.app/privacy",
    "primaryCategory": "PRODUCTIVITY",
    "secondaryCategory": "BUSINESS",
    "screenshots": {
      "6.5inch": [
        "screenshots/ios/6.5inch/1.png",
        "screenshots/ios/6.5inch/2.png",
        "screenshots/ios/6.5inch/3.png"
      ],
      "5.5inch": [
        "screenshots/ios/5.5inch/1.png",
        "screenshots/ios/5.5inch/2.png",
        "screenshots/ios/5.5inch/3.png"
      ]
    }
  },
  "android": {
    "title": "TaskFlow - Task Manager",
    "shortDescription": "Smart Task Management App",
    "fullDescription": "TaskFlow is the ultimate task management app for busy professionals. Organize your tasks, collaborate with your team, and boost your productivity with our intuitive interface.",
    "category": "PRODUCTIVITY",
    "screenshots": [
      "screenshots/android/1.png",
      "screenshots/android/2.png",
      "screenshots/android/3.png",
      "screenshots/android/4.png"
    ],
    "featureGraphic": "screenshots/android/feature-graphic.png",
    "promoVideo": "https://taskflow.app/promo-video.mp4"
  }
}
```

### Privacy Policy

```html
<!-- public/privacy-policy.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Privacy Policy - TaskFlow</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Privacy Policy for TaskFlow</h1>
    <p>Last updated: January 1, 2024</p>

    <h2>1. Information We Collect</h2>
    <p>TaskFlow collects the following information to provide our services:</p>
    <ul>
        <li><strong>Account Information:</strong> Name, email address, and profile picture</li>
        <li><strong>Task Data:</strong> Tasks, subtasks, comments, and attachments</li>
        <li><strong>Device Information:</strong> Device model, OS version, and unique identifiers</li>
        <li><strong>Location:</strong> Location data when you tag tasks with your location</li>
        <li><strong>Usage Data:</strong> How you interact with the app</li>
    </ul>

    <h2>2. How We Use Your Information</h2>
    <ul>
        <li>To provide and maintain our services</li>
        <li>To notify you about changes to our services</li>
        <li>To provide customer support</li>
        <li>To gather analysis or valuable information to improve our services</li>
        <li>To monitor the usage of our services</li>
        <li>To detect, prevent and address technical issues</li>
    </ul>

    <h2>3. Information Sharing and Disclosure</h2>
    <p>We do not sell or share your personal information with third parties except:</p>
    <ul>
        <li>With your explicit consent</li>
        <li>To comply with legal obligations</li>
        <li>To protect and defend our rights and property</li>
        <li>With service providers who assist us in operating our app</li>
    </ul>

    <h2>4. Data Security</h2>
    <p>We implement appropriate technical and organizational measures to protect your data. All data is encrypted in transit and at rest.</p>

    <h2>5. Your Rights</h2>
    <p>You have the right to:</p>
    <ul>
        <li>Access your personal data</li>
        <li>Correct inaccurate data</li>
        <li>Request deletion of your data</li>
        <li>Object to processing of your data</li>
        <li>Request transfer of your data</li>
    </ul>

    <h2>6. Contact Us</h2>
    <p>If you have questions about this privacy policy, please contact us at:</p>
    <p>Email: privacy@taskflow.app</p>
    <p>Address: 123 Tech Street, Silicon Valley, CA 94000</p>
</body>
</html>
```

---

## Target 5: App Store Submission Scripts

**The Target:** Automate app store submissions using EAS.

**The Concept:** Automating submissions reduces errors and makes releases seamless.

### Submission Scripts

```typescript
// scripts/submit.ts
import { execSync } from 'child_process';
import { readFileSync } from 'fs';
import { config } from 'dotenv';

// Load environment variables
config();

interface SubmissionConfig {
  platform: 'ios' | 'android';
  track?: 'production' | 'beta' | 'internal';
  releaseNotes?: string;
}

/**
 * Auto-submit app to stores using EAS
 */
async function submitApp(config: SubmissionConfig) {
  const { platform, track = 'production' } = config;
  
  console.log(`🚀 Starting ${platform} submission...`);

  try {
    // 1. Build the app
    console.log('📦 Building app...');
    execSync(`eas build --platform ${platform} --non-interactive`, { 
      stdio: 'inherit' 
    });

    // 2. Submit to store
    console.log(`📤 Submitting to ${platform} store...`);
    const submitCmd = `eas submit --platform ${platform} --track ${track} --non-interactive`;
    execSync(submitCmd, { stdio: 'inherit' });

    console.log(`✅ ${platform} submission completed!`);
  } catch (error) {
    console.error(`❌ ${platform} submission failed:`, error);
    process.exit(1);
  }
}

/**
 * Check app store status
 */
async function checkSubmissionStatus(platform: 'ios' | 'android') {
  try {
    execSync(`eas submissions --platform ${platform} --limit 5`, { 
      stdio: 'inherit' 
    });
  } catch (error) {
    console.error('Error checking status:', error);
  }
}

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);
  const platform = args[0] as 'ios' | 'android';
  const track = args[1] as 'production' | 'beta' | 'internal' || 'production';

  if (!platform) {
    console.error('❌ Please specify platform: ios or android');
    console.log('Usage: npm run submit ios production');
    process.exit(1);
  }

  submitApp({ platform, track });
}
```

### Package.json Scripts

```json
// package.json - Add submission scripts
{
  "scripts": {
    "submit:ios": "ts-node scripts/submit.ts ios",
    "submit:android": "ts-node scripts/submit.ts android",
    "submit:ios:beta": "ts-node scripts/submit.ts ios beta",
    "submit:android:beta": "ts-node scripts/submit.ts android beta",
    "submit:all": "npm run submit:ios && npm run submit:android",
    "build:ios": "eas build --platform ios",
    "build:android": "eas build --platform android",
    "build:all": "eas build --platform all"
  }
}
```

---

## Target 6: App Store Optimization (ASO)

**The Target:** Optimize your app store listing for visibility.

**The Concept:** ASO is the app store equivalent of SEO. It helps your app get discovered by users.

### ASO Checklist

```typescript
// src/utils/aso-checklist.ts
export const ASOChecklist = {
  appName: {
    check: 'App name includes keywords',
    details: 'TaskFlow - Smart Task Manager (includes "Task Manager")',
    status: '✅'
  },
  
  appSubtitle: {
    check: 'Subtitle describes app value',
    details: 'Organize, Collaborate, Succeed',
    status: '✅'
  },
  
  keywords: {
    check: 'Relevant keywords included',
    details: ['productivity', 'task management', 'team collaboration', 'organizer', 'schedule'],
    status: '✅'
  },
  
  description: {
    check: 'Compelling description with value proposition',
    details: 'Highlights key features: offline mode, team collaboration, analytics',
    status: '✅'
  },
  
  screenshots: {
    check: 'High-quality screenshots showing key features',
    details: '6 screenshots showing: dashboard, task list, task detail, calendar view, team features, settings',
    status: '✅'
  },
  
  appIcon: {
    check: 'Professional, recognizable icon',
    details: 'Simple, bold design with task-related imagery',
    status: '✅'
  },
  
  ratings: {
    check: 'Rating prompt implemented',
    details: 'Prompts users after completing 5 tasks',
    status: '✅'
  },
  
  reviews: {
    check: 'Review response strategy',
    details: 'Respond to all reviews within 24 hours',
    status: '✅'
  }
};

/**
 * Rating Prompt Implementation
 */
export const RatingPrompt = () => {
  const promptForRating = () => {
    // In React Native, use react-native-rate or similar
    console.log('⭐ Would you like to rate TaskFlow?');
    // Show rating dialog
  };

  return { promptForRating };
};
```

---

## Target 7: Post-Launch Monitoring

**The Target:** Monitor app performance and user feedback after launch.

**The Concept:** Launch is just the beginning. Continuous monitoring helps you identify issues and improve your app.

### Monitoring Setup

```typescript
// src/utils/monitoring.ts
import * as Sentry from 'sentry-expo';
import * as Analytics from 'expo-analytics';
import { Platform } from 'react-native';
import { appVersion } from 'expo-constants';

interface AppError {
  message: string;
  stack?: string;
  context?: Record<string, any>;
  severity?: 'fatal' | 'error' | 'warning' | 'info';
}

/**
 * MonitoringService - Handles error tracking and analytics
 * 
 * This service integrates with Sentry for error tracking
 * and analytics for user behavior monitoring.
 */
export class MonitoringService {
  private static instance: MonitoringService;
  private isEnabled = !__DEV__;

  private constructor() {
    this.initializeSentry();
    this.initializeAnalytics();
  }

  static getInstance(): MonitoringService {
    if (!MonitoringService.instance) {
      MonitoringService.instance = new MonitoringService();
    }
    return MonitoringService.instance;
  }

  /**
   * Initialize Sentry error tracking
   */
  private initializeSentry() {
    if (!this.isEnabled) return;

    Sentry.init({
      dsn: process.env.EXPO_PUBLIC_SENTRY_DSN,
      enableInExpoDevelopment: false,
      debug: false,
      environment: process.env.APP_ENV || 'production',
      release: appVersion,
    });

    // Set user context
    Sentry.setContext('app', {
      platform: Platform.OS,
      version: appVersion,
    });
  }

  /**
   * Initialize analytics
   */
  private initializeAnalytics() {
    if (!this.isEnabled) return;
    
    // Analytics implementation
    console.log('📊 Analytics initialized');
  }

  /**
   * Capture an error
   */
  captureError(error: AppError): void {
    if (!this.isEnabled) {
      console.error('❌ Error:', error.message);
      return;
    }

    Sentry.captureException(new Error(error.message), {
      extra: error.context,
      level: error.severity || 'error',
    });

    // Also log to analytics
    this.logEvent('error_occurred', {
      message: error.message,
      severity: error.severity,
    });
  }

  /**
   * Log a user event
   */
  logEvent(eventName: string, properties?: Record<string, any>): void {
    if (!this.isEnabled) return;

    console.log(`📊 Event: ${eventName}`, properties);
    
    // Send to analytics service
    // Example: Amplitude, Mixpanel, etc.
  }

  /**
   * Set user ID for tracking
   */
  setUserId(userId: string): void {
    if (!this.isEnabled) return;

    Sentry.setUser({ id: userId });
    // Analytics set user ID
  }

  /**
   * Track screen views
   */
  trackScreen(screenName: string): void {
    this.logEvent('screen_view', { screen: screenName });
  }

  /**
   * Track performance metrics
   */
  trackPerformance(metric: string, value: number): void {
    this.logEvent('performance_metric', { metric, value });
  }

  /**
   * Check app health
   */
  async checkAppHealth(): Promise<{ status: 'healthy' | 'degraded' | 'unhealthy'; details: string }> {
    // In a real app, check API status, database connectivity, etc.
    return {
      status: 'healthy',
      details: 'All systems operational',
    };
  }
}

export const monitoring = MonitoringService.getInstance();

// Usage in components
export const useMonitoring = () => {
  const captureError = (error: AppError) => {
    monitoring.captureError(error);
  };

  const logEvent = (eventName: string, properties?: Record<string, any>) => {
    monitoring.logEvent(eventName, properties);
  };

  return { captureError, logEvent };
};
```

### Error Boundary Component

```typescript
// src/components/ErrorBoundary.tsx
import React, { Component, ReactNode } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Platform } from 'react-native';
import { monitoring } from '../utils/monitoring';

interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error) => void;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

/**
 * ErrorBoundary - Catches and handles component errors
 * 
 * This component prevents the entire app from crashing
 * when a component throws an error.
 */
export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Report to monitoring service
    monitoring.captureError({
      message: error.message,
      stack: error.stack,
      context: errorInfo,
      severity: 'fatal',
    });

    this.props.onError?.(error);
  }

  handleReset = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <View style={styles.container}>
          <Text style={styles.icon}>😅</Text>
          <Text style={styles.title}>Something went wrong</Text>
          <Text style={styles.message}>
            We're sorry, but an unexpected error occurred.
          </Text>
          {__DEV__ && this.state.error && (
            <View style={styles.errorDetails}>
              <Text style={styles.errorText}>
                {this.state.error.message}
              </Text>
            </View>
          )}
          <TouchableOpacity style={styles.button} onPress={this.handleReset}>
            <Text style={styles.buttonText}>Try Again</Text>
          </TouchableOpacity>
        </View>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#f8f9fa',
  },
  icon: {
    fontSize: 48,
    marginBottom: 16,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 8,
  },
  message: {
    fontSize: 14,
    color: '#7f8c8d',
    textAlign: 'center',
    marginBottom: 20,
  },
  errorDetails: {
    backgroundColor: '#f1f2f6',
    padding: 12,
    borderRadius: 8,
    marginBottom: 20,
    width: '100%',
  },
  errorText: {
    fontSize: 12,
    color: '#e74c3c',
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  button: {
    backgroundColor: '#3498db',
    paddingHorizontal: 32,
    paddingVertical: 12,
    borderRadius: 8,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

---

## Target 8: Production Deployment Checklist

**The Target:** Complete final checklist before production deployment.

**The Concept:** Ensure everything is ready before hitting that "Submit" button.

### Final Production Checklist

```typescript
// src/utils/deployment-checklist.ts
export const DeploymentChecklist = {
  // Code Quality
  linting: {
    check: 'No linting errors',
    status: '✅',
    command: 'npm run lint'
  },
  types: {
    check: 'No TypeScript errors',
    status: '✅',
    command: 'npm run type-check'
  },
  tests: {
    check: 'All tests pass',
    status: '✅',
    command: 'npm test'
  },

  // Performance
  bundleSize: {
    check: 'Bundle size < 15MB',
    status: '✅',
    metric: '12.3MB'
  },
  startupTime: {
    check: 'Startup time < 2s',
    status: '✅',
    metric: '1.4s'
  },
  memoryUsage: {
    check: 'Memory usage < 50MB',
    status: '✅',
    metric: '32MB'
  },

  // Assets
  appIcon: {
    check: 'All icon sizes configured',
    status: '✅'
  },
  splashScreen: {
    check: 'Splash screen configured',
    status: '✅'
  },
  screenshots: {
    check: 'All required screenshots ready',
    status: '✅'
  },

  // Content
  privacyPolicy: {
    check: 'Privacy policy available',
    status: '✅',
    url: 'https://taskflow.app/privacy'
  },
  termsOfService: {
    check: 'Terms of service available',
    status: '✅',
    url: 'https://taskflow.app/terms'
  },
  supportEmail: {
    check: 'Support contact set up',
    status: '✅',
    email: 'support@taskflow.app'
  },

  // App Store
  appStoreListing: {
    check: 'App Store listing complete',
    status: '✅'
  },
  googlePlayListing: {
    check: 'Google Play listing complete',
    status: '✅'
  },
  appStoreCredentials: {
    check: 'App Store credentials ready',
    status: '✅'
  },
  googlePlayCredentials: {
    check: 'Google Play credentials ready',
    status: '✅'
  },

  // Monitoring
  analytics: {
    check: 'Analytics configured',
    status: '✅'
  },
  errorTracking: {
    check: 'Error tracking configured',
    status: '✅'
  },
  performanceMonitoring: {
    check: 'Performance monitoring configured',
    status: '✅'
  },

  // Security
  sslCertificates: {
    check: 'SSL certificates configured',
    status: '✅'
  },
  apiKeys: {
    check: 'API keys rotated and secured',
    status: '✅'
  },
  environmentVariables: {
    check: 'Environment variables set',
    status: '✅'
  }
};
```

---

## Verification: Production Deployment

```bash
# 1. Run final checks
npm run lint
npm run type-check
npm test

# 2. Build production app
eas build --platform ios --profile production
eas build --platform android --profile production

# 3. Test production build on TestFlight/Internal Testing
# Install the build on your device and thoroughly test

# 4. Submit to stores
npm run submit:ios
npm run submit:android

# 5. Monitor launch
# Check Sentry, analytics, and app store reviews
```

---

## What We've Accomplished

You've done it! You've completed the entire React Native development journey from blueprint to production. Here's what you've achieved:

1. **CI/CD Automation:** GitHub Actions for automated testing and building
2. **EAS Build:** Configured build pipelines for iOS and Android
3. **Code Signing:** Managed certificates and provisioning profiles
4. **App Store Preparation:** Metadata, screenshots, and privacy policies
5. **Automated Submissions:** Scripts for app store deployment
6. **App Store Optimization:** ASO strategies for visibility
7. **Post-Launch Monitoring:** Error tracking and analytics
8. **Deployment Checklist:** Comprehensive final validation

### Your Journey Recap

You started with environment setup, mastered React Native architecture, built a complete app with navigation, implemented state management with Zustand, added offline persistence, integrated device capabilities (camera, location, notifications), created fluid gestures and animations, wrote comprehensive tests, optimized performance, and finally deployed to the app stores.

---

## Final Words

Congratulations on completing this comprehensive series! You're now a React Native developer capable of building, testing, optimizing, and deploying production-ready mobile applications.

**Remember:**
- The journey of learning never ends
- Keep building and experimenting
- Contribute to open source
- Share your knowledge with others
- Stay curious and keep learning

Your TaskFlow app is now available to millions of users worldwide. Welcome to the world of mobile development!

*This concludes the complete React Native tutorial series. You've built a production-ready app, learned industry best practices, and mastered the full development lifecycle. Thank you for joining this journey, and happy coding! 🚀*
