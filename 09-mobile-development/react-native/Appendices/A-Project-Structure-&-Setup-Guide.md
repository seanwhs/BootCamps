# Appendix A: Complete Project Structure & Setup Guide

Welcome to the Appendix section! This reference guide provides a bird's-eye view of the entire TaskFlow project structure, complete file-by-file breakdown, and a quick-start setup guide to get you running in minutes. Use this as your project roadmap and reference manual.

---

## Table of Contents

1. [Project Directory Tree](#project-directory-tree)
2. [Complete File-by-File Breakdown](#complete-file-by-file-breakdown)
3. [Environment Setup Quickstart](#environment-setup-quickstart)
4. [Dependencies Reference](#dependencies-reference)
5. [Common Commands Cheat Sheet](#common-commands-cheat-sheet)
6. [Troubleshooting Common Issues](#troubleshooting-common-issues)

---

## Project Directory Tree

```
TaskFlow/
├── .env                        # Environment variables (local development)
├── .env.example                # Environment variables template
├── .env.production             # Production environment variables
├── .gitignore                  # Git ignore file
├── .prettierrc                 # Prettier configuration
├── .eslintrc.js               # ESLint configuration
├── app.json                    # Expo app configuration
├── App.tsx                     # Root component (production)
├── babel.config.js             # Babel configuration
├── eas.json                    # EAS Build configuration
├── jest.config.js              # Jest testing configuration
├── jest.setup.js               # Jest setup and mocks
├── metro.config.js             # Metro bundler configuration
├── package.json                # Dependencies and scripts
├── tsconfig.json               # TypeScript configuration
├── yarn.lock / package-lock.json
├── .github/                    # GitHub Actions workflows
│   └── workflows/
│       ├── ci.yml             # Continuous integration
│       └── pr-checks.yml      # Pull request checks
├── assets/                     # Static assets
│   ├── icon.png               # App icon
│   ├── adaptive-icon.png      # Android adaptive icon
│   ├── splash.png             # Splash screen image
│   ├── notification-icon.png  # Notification icon
│   └── fonts/                 # Custom fonts
├── docs/                       # Documentation
│   ├── api/                   # API documentation
│   ├── architecture.md        # Architecture overview
│   └── testing.md             # Testing guide
├── scripts/                    # Build and utility scripts
│   ├── setup.sh               # Environment setup script
│   ├── submit.ts              # App store submission script
│   └── generate-screenshots.ts # Screenshot generation
├── e2e/                        # End-to-end tests (Detox)
│   ├── config.json            # Detox configuration
│   └── taskFlow.e2e.ts        # E2E test suite
├── src/
│   ├── __tests__/             # Test files
│   │   ├── components/        # Component tests
│   │   ├── stores/            # Store tests
│   │   ├── utils/             # Utility tests
│   │   ├── integration/       # Integration tests
│   │   └── performance/       # Performance tests
│   ├── components/            # Reusable components
│   │   ├── AddTaskButton.tsx
│   │   ├── CustomStatusBar.tsx
│   │   ├── CustomPullToRefresh.tsx
│   │   ├── DragReorderList.tsx
│   │   ├── ErrorBoundary.tsx
│   │   ├── HapticButton.tsx
│   │   ├── ImageAttachment.tsx
│   │   ├── LocationPicker.tsx
│   │   ├── NotificationPermissionPrompt.tsx
│   │   ├── OfflineStatusIndicator.tsx
│   │   ├── OptimizedImage.tsx
│   │   ├── OptimizedTaskItem.tsx
│   │   ├── OptimizedTaskList.tsx
│   │   ├── ResponsiveCard.tsx
│   │   ├── SafeAreaWrapper.tsx
│   │   ├── SharedElementTransition.tsx
│   │   ├── StaggeredTaskList.tsx
│   │   ├── SwipeableTaskItem.tsx
│   │   └── TaskForm.tsx
│   ├── database/              # SQLite database
│   │   ├── database.ts       # Database initialization
│   │   ├── migrations.ts     # Schema migrations
│   │   ├── sampleData.ts     # Sample data for development
│   │   └── index.ts          # Database setup entry point
│   ├── examples/             # Demonstration components
│   │   ├── CustomHooksDemo.tsx
│   │   ├── EffectExamples.tsx
│   │   ├── GestureBasics.tsx
│   │   ├── MemoizationExamples.tsx
│   │   ├── StateFundamentals.tsx
│   │   └── ZustandBasics.tsx
│   ├── hooks/                # Custom React hooks
│   │   ├── useApi.ts
│   │   ├── useAsyncStorage.ts
│   │   ├── useDebounce.ts
│   │   ├── useKeyboard.ts
│   │   └── useNavigation.ts
│   ├── navigation/           # Navigation system
│   │   ├── AuthGuard.tsx    # Protected route guard
│   │   ├── deepLinking.ts   # Deep link configuration
│   │   ├── DrawerNavigator.tsx
│   │   ├── MainTabNavigator.tsx
│   │   ├── NavigationService.ts
│   │   ├── persistence.ts   # Navigation state persistence
│   │   ├── RootStackNavigator.tsx
│   │   └── types.ts         # Navigation type definitions
│   ├── screens/              # Screen components
│   │   ├── auth/
│   │   │   ├── LoginScreen.tsx
│   │   │   ├── RegisterScreen.tsx
│   │   │   └── ForgotPasswordScreen.tsx
│   │   ├── tasks/
│   │   │   ├── TaskCreateScreen.tsx
│   │   │   ├── TaskDetailScreen.tsx
│   │   │   ├── TaskEditScreen.tsx
│   │   │   └── TasksScreen.tsx
│   │   ├── modals/
│   │   │   ├── TaskFilterScreen.tsx
│   │   │   └── UserSearchScreen.tsx
│   │   ├── profile/
│   │   │   └── ProfileScreen.tsx
│   │   ├── HomeScreen.tsx
│   │   ├── NotificationsScreen.tsx
│   │   ├── SettingsScreen.tsx
│   │   ├── HelpScreen.tsx
│   │   └── AboutScreen.tsx
│   ├── services/             # Service layer
│   │   ├── cameraService.ts
│   │   ├── hapticService.ts
│   │   ├── locationService.ts
│   │   ├── notificationService.ts
│   │   ├── offlineSync.ts
│   │   └── taskService.ts
│   ├── stores/               # Zustand stores
│   │   ├── actions.ts       # Cross-store actions
│   │   ├── authStore.ts
│   │   ├── counterStore.ts
│   │   ├── rootStore.ts
│   │   ├── settingsStore.ts
│   │   ├── taskStore.ts
│   │   ├── taskStoreWithMMKV.ts
│   │   └── uiStore.ts
│   ├── styles/               # Styling utilities
│   │   ├── colors.ts        # Color palette
│   │   ├── global.ts        # Global styles
│   │   ├── responsive.ts    # Responsive design system
│   │   └── typography.ts    # Typography system
│   ├── types/                # TypeScript type definitions
│   │   ├── navigation.ts
│   │   ├── store.ts
│   │   └── api.ts
│   └── utils/                # Utility functions
│       ├── asyncStorage.ts
│       ├── dateUtils.ts
│       ├── dimensions.ts
│       ├── imageOptimization.ts
│       ├── memoryManagement.ts
│       ├── mmkvStorage.ts
│       ├── monitoring.ts
│       ├── performance/
│       │   ├── architecture.ts
│       │   ├── devtools.ts
│       │   └── performanceMonitor.ts
│       ├── secureStorage.ts
│       └── validation.ts
└── public/                    # Public static files
    ├── privacy-policy.html
    └── terms-of-service.html
```

---

## Complete File-by-File Breakdown

### Root Configuration Files

#### `.env.example`
```bash
# Environment Variables Template

# API Configuration
EXPO_PUBLIC_API_URL=http://localhost:3000/api
EXPO_PUBLIC_API_KEY=your-api-key

# Expo
EXPO_PUBLIC_PROJECT_ID=your-project-id

# Services
EXPO_PUBLIC_SENTRY_DSN=your-sentry-dsn
EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=your-google-maps-key
EXPO_PUBLIC_ANALYTICS_KEY=your-analytics-key

# App Settings
APP_ENV=development
EXPO_PUBLIC_ENCRYPTION_KEY=your-encryption-key

# Apple App Store (for submissions)
APPLE_ID=your-apple-id
APPLE_TEAM_ID=your-apple-team-id
ASC_APP_ID=your-app-store-connect-app-id
```

#### `app.json`
```json
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
      ["expo-image-picker", {
        "photosPermission": "TaskFlow uses your photo library to attach images to tasks."
      }],
      ["expo-camera", {
        "cameraPermission": "TaskFlow uses your camera to attach photos to tasks."
      }],
      ["expo-location", {
        "locationAlwaysAndWhenInUsePermission": "TaskFlow uses your location to tag tasks with your current location.",
        "locationWhenInUsePermission": "TaskFlow uses your location to tag tasks with your current location."
      }],
      ["expo-notifications", {
        "icon": "./assets/notification-icon.png",
        "color": "#3498db"
      }]
    ]
  }
}
```

#### `eas.json`
```json
{
  "cli": {
    "version": ">= 3.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "channel": "development",
      "ios": { "simulator": true },
      "android": { "buildType": "apk" }
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview",
      "ios": { "simulator": false },
      "android": { "buildType": "apk" }
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

#### `tsconfig.json`
```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "jsx": "react",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "noEmit": true,
    "allowJs": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@screens/*": ["src/screens/*"],
      "@stores/*": ["src/stores/*"],
      "@utils/*": ["src/utils/*"],
      "@hooks/*": ["src/hooks/*"],
      "@services/*": ["src/services/*"],
      "@navigation/*": ["src/navigation/*"],
      "@types/*": ["src/types/*"],
      "@assets/*": ["assets/*"]
    },
    "types": ["jest", "@testing-library/jest-native"]
  },
  "include": ["src/**/*", "App.tsx", "*.config.js", "*.setup.js"],
  "exclude": [
    "node_modules",
    "babel.config.js",
    "metro.config.js",
    "jest.config.js"
  ]
}
```

---

### Core Component Files

#### `src/components/TaskCard.tsx`
```typescript
import React, { memo } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Platform,
} from 'react-native';
import { Task } from '../stores/taskStore';

interface TaskCardProps {
  task: Task;
  onPress: (task: Task) => void;
  onDelete: (id: string) => void;
  onEdit: (task: Task) => void;
}

export const TaskCard = memo(({ task, onPress, onDelete, onEdit }: TaskCardProps) => {
  const getPriorityColor = (priority: Task['priority']) => {
    switch (priority) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  };

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={() => onPress(task)}
      testID="task-card"
      activeOpacity={0.7}
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.title} numberOfLines={1}>
            {task.title}
          </Text>
          <View style={styles.actions}>
            <TouchableOpacity
              style={styles.actionButton}
              onPress={() => onEdit(task)}
              testID="edit-button"
            >
              <Text style={styles.actionText}>✎</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.actionButton}
              onPress={() => onDelete(task.id)}
              testID="delete-button"
            >
              <Text style={[styles.actionText, styles.deleteText]}>✕</Text>
            </TouchableOpacity>
          </View>
        </View>

        {task.description && (
          <Text style={styles.description} numberOfLines={2}>
            {task.description}
          </Text>
        )}

        <View style={styles.footer}>
          <View style={styles.priorityContainer}>
            <View
              style={[
                styles.priorityDot,
                { backgroundColor: getPriorityColor(task.priority) },
              ]}
              testID="priority-indicator"
            />
            <Text style={styles.priorityText}>
              {task.priority.charAt(0).toUpperCase() + task.priority.slice(1)}
            </Text>
          </View>

          <Text style={styles.dueDate}>
            Due: {task.dueDate}
          </Text>

          <View style={styles.statusBadge} testID="status-badge">
            <Text style={styles.statusText} testID="status-text">
              {task.status === 'done' ? '✓' : '○'}
            </Text>
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );
});

TaskCard.displayName = 'TaskCard';

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 6,
    marginHorizontal: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  content: {
    gap: 8,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginRight: 8,
  },
  actions: {
    flexDirection: 'row',
    gap: 8,
  },
  actionButton: {
    padding: 4,
  },
  actionText: {
    fontSize: 16,
    color: '#7f8c8d',
  },
  deleteText: {
    color: '#e74c3c',
  },
  description: {
    fontSize: 14,
    color: '#7f8c8d',
    lineHeight: 20,
  },
  footer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 4,
  },
  priorityContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  priorityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  priorityText: {
    fontSize: 12,
    color: '#7f8c8d',
  },
  dueDate: {
    fontSize: 12,
    color: '#95a5a6',
  },
  statusBadge: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#f1f2f6',
    alignItems: 'center',
    justifyContent: 'center',
  },
  statusText: {
    fontSize: 14,
    color: '#2c3e50',
  },
});
```

---

## Environment Setup Quickstart

### Prerequisites Installation

```bash
# 1. Install Node.js (v18+)
# Visit https://nodejs.org or use a version manager

# 2. Install npm or yarn
npm install -g yarn

# 3. Install Expo CLI
npm install -g expo-cli

# 4. Install EAS CLI (for builds)
npm install -g eas-cli

# 5. Install Git
# Visit https://git-scm.com/downloads
```

### Platform-Specific Setup

#### macOS (iOS + Android)
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Watchman
brew install watchman

# Install Xcode from App Store
# Then install Command Line Tools
xcode-select --install

# Install Android Studio
# Download from https://developer.android.com/studio

# Set environment variables
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc
```

#### Windows
```bash
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Node.js, Watchman, Java
choco install nodejs-lts watchman openjdk11

# Install Android Studio
# Download from https://developer.android.com/studio

# Set environment variables
# Add ANDROID_HOME=C:\Users\YourUser\AppData\Local\Android\Sdk
# Add to Path: %ANDROID_HOME%\emulator, %ANDROID_HOME%\platform-tools
```

#### Linux (Ubuntu/Debian)
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Watchman
sudo apt-get install watchman

# Install Java
sudo apt-get install openjdk-11-jdk

# Install Android Studio
# Download and extract from https://developer.android.com/studio

# Set environment variables
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```

### Project Creation and Setup

```bash
# 1. Clone or create project
npx create-expo-app TaskFlow --template
# Select "blank (TypeScript)"

# 2. Navigate to project
cd TaskFlow

# 3. Install dependencies
npm install

# 4. Install core libraries
npx expo install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs @react-navigation/drawer
npx expo install react-native-screens react-native-safe-area-context
npx expo install react-native-gesture-handler react-native-reanimated
npx expo install @react-native-async-storage/async-storage
npx expo install expo-camera expo-image-picker expo-location expo-notifications
npx expo install expo-secure-store expo-device expo-haptics
npx expo install react-native-mmkv expo-sqlite

# 5. Install Zustand
npm install zustand

# 6. Install testing libraries
npm install --save-dev @testing-library/react-native jest jest-expo
npm install --save-dev @testing-library/jest-native @testing-library/react-hooks

# 7. Install development utilities
npm install --save-dev @types/react @types/react-native typescript
npm install --save-dev eslint prettier @typescript-eslint/eslint-plugin @typescript-eslint/parser

# 8. Start development
expo start
```

---

## Dependencies Reference

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **Core** | | |
| react-native | ~0.72.0 | React Native framework |
| expo | ~49.0.0 | Expo SDK |
| react | 18.2.0 | React library |
| **Navigation** | | |
| @react-navigation/native | ^6.1.7 | Navigation core |
| @react-navigation/stack | ^6.3.17 | Stack navigator |
| @react-navigation/bottom-tabs | ^6.5.8 | Tab navigator |
| @react-navigation/drawer | ^6.6.3 | Drawer navigator |
| react-native-screens | ~3.22.0 | Screen rendering |
| react-native-safe-area-context | 4.6.3 | Safe area handling |
| **State Management** | | |
| zustand | ^4.3.8 | State management |
| **Storage** | | |
| @react-native-async-storage/async-storage | 1.18.2 | Key-value storage |
| react-native-mmkv | ^2.5.1 | High-performance storage |
| expo-sqlite | ~11.0.0 | SQLite database |
| expo-secure-store | ~12.0.0 | Encrypted storage |
| **Device APIs** | | |
| expo-camera | ~13.0.0 | Camera access |
| expo-image-picker | ~14.0.0 | Photo library |
| expo-location | ~16.0.0 | Geolocation |
| expo-notifications | ~0.20.0 | Push notifications |
| expo-haptics | ~12.0.0 | Haptic feedback |
| **Animations & Gestures** | | |
| react-native-gesture-handler | ~2.12.0 | Gesture handling |
| react-native-reanimated | ~3.3.0 | Animations |
| **Networking** | | |
| axios | ^1.4.0 | HTTP client |
| **Utilities** | | |
| expo-constants | ~14.0.0 | App constants |
| expo-device | ~5.0.0 | Device info |
| expo-file-system | ~11.0.0 | File system access |
| expo-image-manipulator | ~11.0.0 | Image optimization |
| date-fns | ^2.30.0 | Date utilities |
| zod | ^3.21.0 | Schema validation |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **Testing** | | |
| @testing-library/react-native | ^12.0.0 | Component testing |
| @testing-library/jest-native | ^5.1.0 | Jest native matchers |
| @testing-library/react-hooks | ^8.0.0 | Hook testing |
| jest | ^29.5.0 | Test runner |
| jest-expo | ^49.0.0 | Expo Jest preset |
| detox | ^20.0.0 | E2E testing |
| **TypeScript** | | |
| typescript | ^5.0.0 | TypeScript |
| @types/react | ~18.2.0 | React types |
| @types/react-native | ~0.72.0 | React Native types |
| **Linting** | | |
| eslint | ^8.45.0 | ESLint |
| @typescript-eslint/eslint-plugin | ^6.0.0 | TypeScript ESLint |
| @typescript-eslint/parser | ^6.0.0 | TypeScript parser |
| prettier | ^3.0.0 | Code formatting |
| **Build** | | |
| @expo/metro-config | ^0.10.0 | Metro configuration |
| eas-cli | ^4.0.0 | EAS CLI |

---

## Common Commands Cheat Sheet

### Development

```bash
# Start development server
expo start

# Start with clearing cache
expo start --clear

# Start on specific platform
expo start --ios
expo start --android

# Run on physical device (scan QR code)
expo start --tunnel
```

### Building

```bash
# Development build
eas build --platform ios --profile development
eas build --platform android --profile development

# Preview build (internal distribution)
eas build --platform ios --profile preview
eas build --platform android --profile preview

# Production build
eas build --platform ios --profile production
eas build --platform android --profile production

# Build all platforms
eas build --platform all
```

### Testing

```bash
# Run unit tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- src/__tests__/components/TaskCard.test.tsx

# E2E tests (iOS)
npm run e2e:build
npm run test:e2e

# E2E tests (Android)
npm run e2e:build:android
npm run test:e2e:android
```

### Linting and Formatting

```bash
# Run linting
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Type checking
npm run type-check
```

### Submitting to Stores

```bash
# Submit to iOS App Store
eas submit --platform ios

# Submit to Android Google Play
eas submit --platform android

# Submit with specific track
eas submit --platform ios --track beta
eas submit --platform android --track internal
```

### Cleaning and Maintenance

```bash
# Clear npm cache
npm cache clean --force

# Clear Expo cache
expo start --clear

# Clear EAS cache
eas build --clear-cache

# Uninstall and reinstall dependencies
rm -rf node_modules
npm install
```

---

## Troubleshooting Common Issues

### Build Issues

| Issue | Solution |
|-------|----------|
| **iOS Build Fails** | - Check Xcode version: `xcodebuild -version`<br>- Clear derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`<br>- Run: `pod install` in ios directory<br>- Check certificates in Apple Developer portal |
| **Android Build Fails** | - Check Java version: `java -version`<br>- Clean project: `cd android && ./gradlew clean`<br>- Check ANDROID_HOME path<br>- Check keystore configuration |
| **EAS Build Fails** | - Check environment variables<br>- Verify app.json configuration<br>- Run: `eas build --platform ios --clear-cache`<br>- Check EAS credentials |

### Development Issues

| Issue | Solution |
|-------|----------|
| **Metro Bundler Stuck** | - Clear cache: `expo start --clear`<br>- Kill process: `killall node`<br>- Check port 8081 availability |
| **App Won't Launch** | - Check Expo Go version<br>- Restart emulator/simulator<br>- Run: `expo doctor` to fix issues |
| **Module Not Found** | - Run: `npm install`<br>- Clear cache: `expo start --clear`<br>- Check import paths |
| **TypeScript Errors** | - Run: `npm run type-check`<br>- Update TypeScript config<br>- Add missing type declarations |
| **HMR Not Working** | - Disable Fast Refresh temporarily<br>- Restart Metro bundler<br>- Check file watcher limits |

### Device Issues

| Issue | Solution |
|-------|----------|
| **Camera Not Working** | - Check permissions<br>- Verify camera availability<br>- Test in Expo Go first |
| **Location Not Working** | - Enable location services<br>- Check permissions<br>- Test with mock location |
| **Notifications Not Working** | - Check push token registration<br>- Verify device is physical (not simulator)<br>- Test with Expo Notifications tool |
| **Permissions Denied** | - Check app.json permissions<br>- Re-request permissions<br>- Check device settings |

### Performance Issues

| Issue | Solution |
|-------|----------|
| **Janky Animations** | - Use `useNativeDriver: true`<br>- Reduce bridge traffic<br>- Use Reanimated with Gesture Handler |
| **Slow FlatList** | - Enable `removeClippedSubviews`<br>- Use `getItemLayout`<br>- Reduce `maxToRenderPerBatch`<br>- Use `windowSize` |
| **Memory Leaks** | - Clean up useEffect subscriptions<br>- Remove event listeners<br>- Cancel animations on unmount |
| **Large Bundle Size** | - Enable lazy loading<br>- Use tree shaking<br>- Optimize images<br>- Remove unused dependencies |

### App Store Issues

| Issue | Solution |
|-------|----------|
| **App Rejected** | - Check App Store guidelines<br>- Fix privacy policy issues<br>- Test on all supported devices<br>- Provide clear app description |
| **Provisioning Profile Issues** | - Regenerate profiles<br>- Check bundle identifier<br>- Verify team membership |
| **Build Validation Fails** | - Check app icon sizes<br>- Validate app.json configuration<br>- Run local validation: `eas build:validate` |

---

## Quick Debugging Commands

```bash
# Check Expo version
expo --version

# Check Node version
node --version

# Check environment variables
npx expo env

# Run diagnostic
expo doctor

# View build logs
eas build:logs

# Check submission status
eas submissions:list

# View device logs
npx react-native log-ios
npx react-native log-android
```

---

This appendix serves as your complete reference for the TaskFlow project. Keep it handy as you build, test, and deploy your application. For any issues not covered here, consult the official documentation or the community forums.

x
