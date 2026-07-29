# Appendix O: Complete Project Template

Welcome to Appendix O! This appendix provides a complete, production-ready project template that you can use to bootstrap new React Native applications. It includes all the best practices, configurations, and boilerplate code covered throughout this series, packaged into a reusable template.

---

## Table of Contents

1. [Template Overview](#template-overview)
2. [Project Structure](#project-structure)
3. [Configuration Files](#configuration-files)
4. [Core Boilerplate Code](#core-boilerplate-code)
5. [Getting Started](#getting-started)
6. [Customization Guide](#customization-guide)
7. [Template Scripts](#template-scripts)

---

## Template Overview

### Quick Start

```bash
# Clone the template
git clone https://github.com/yourorg/react-native-template-taskflow my-app

# Navigate to project
cd my-app

# Install dependencies
npm install

# Setup environment
cp .env.example .env

# Start development
npm start
```

### Template Features

```typescript
// template-features.ts
export const TemplateFeatures = {
  // Architecture
  architecture: {
    type: 'Modular',
    stateManagement: 'Zustand',
    navigation: 'React Navigation v6',
    styling: 'StyleSheet + Design System',
  },

  // Core Features
  core: {
    authentication: 'JWT + Biometric',
    offlineFirst: 'SQLite + MMKV + Sync Engine',
    pushNotifications: 'Expo Notifications + FCM',
    analytics: 'Mixpanel + Segment',
    i18n: 'i18n-js + Localization',
  },

  // Development Tools
  tools: {
    linting: 'ESLint + Prettier',
    testing: 'Jest + React Native Testing Library',
    ci: 'GitHub Actions',
    builds: 'EAS Build',
    typescript: 'Strict Mode',
  },

  // Performance
  performance: {
    profiling: 'React DevTools + Performance Monitor',
    optimization: 'Memoization + FlatList Optimizations',
    bundleSize: 'Lazy Loading + Tree Shaking',
  },

  // Security
  security: {
    storage: 'Expo SecureStore + MMKV Encryption',
    networking: 'Certificate Pinning + Request Signing',
    auth: 'JWT + Refresh Token Rotation',
  },
};
```

---

## Project Structure

### Complete File Tree

```
my-app/
├── .env.example                 # Environment variables template
├── .env.production              # Production environment
├── .env.staging                 # Staging environment
├── .eslintrc.js                # ESLint configuration
├── .gitignore                  # Git ignore
├── .prettierrc                 # Prettier configuration
├── app.config.js               # Expo app configuration
├── App.tsx                     # Root component
├── babel.config.js             # Babel configuration
├── eas.json                    # EAS Build configuration
├── jest.config.js              # Jest configuration
├── jest.setup.js               # Jest setup
├── metro.config.js             # Metro bundler configuration
├── package.json                # Dependencies
├── tsconfig.json               # TypeScript configuration
├── README.md                   # Documentation
├── .github/
│   └── workflows/
│       ├── ci.yml              # Continuous integration
│       ├── cd.yml              # Continuous deployment
│       └── pr-checks.yml       # Pull request checks
├── assets/
│   ├── icon.png                # App icon
│   ├── adaptive-icon.png       # Android adaptive icon
│   ├── splash.png              # Splash screen
│   └── fonts/                  # Custom fonts
├── src/
│   ├── __tests__/              # Test files
│   │   ├── components/
│   │   ├── stores/
│   │   ├── utils/
│   │   ├── integration/
│   │   └── performance/
│   ├── analytics/              # Analytics setup
│   │   ├── AnalyticsService.ts
│   │   ├── EventTracker.ts
│   │   ├── UserIdentity.ts
│   │   └── index.ts
│   ├── components/             # Reusable components
│   │   ├── atoms/
│   │   │   ├── Button/
│   │   │   ├── Input/
│   │   │   ├── Typography/
│   │   │   └── Icon/
│   │   ├── molecules/
│   │   │   ├── Card/
│   │   │   ├── Modal/
│   │   │   └── Toast/
│   │   └── organisms/
│   │       ├── Header/
│   │       └── Footer/
│   ├── config/                 # Configuration
│   │   ├── constants.ts
│   │   ├── environment.ts
│   │   └── index.ts
│   ├── database/               # Database setup
│   │   ├── migrations/
│   │   ├── models/
│   │   └── index.ts
│   ├── hooks/                  # Custom hooks
│   │   ├── useApi.ts
│   │   ├── useAuth.ts
│   │   ├── useDebounce.ts
│   │   ├── useKeyboard.ts
│   │   ├── useTheme.ts
│   │   └── index.ts
│   ├── i18n/                   # Internationalization
│   │   ├── translations/
│   │   │   ├── en.json
│   │   │   ├── es.json
│   │   │   └── index.ts
│   │   ├── Formatters.ts
│   │   └── index.ts
│   ├── navigation/             # Navigation setup
│   │   ├── guards/
│   │   │   └── AuthGuard.tsx
│   │   ├── stacks/
│   │   │   ├── AuthStack.tsx
│   │   │   └── MainStack.tsx
│   │   ├── NavigationService.ts
│   │   ├── types.ts
│   │   └── index.ts
│   ├── offline/                # Offline-first setup
│   │   ├── LocalStorage.ts
│   │   ├── SyncEngine.ts
│   │   ├── ConflictResolver.ts
│   │   ├── OptimisticUI.ts
│   │   └── index.ts
│   ├── screens/                # Screen components
│   │   ├── auth/
│   │   │   ├── LoginScreen.tsx
│   │   │   └── RegisterScreen.tsx
│   │   ├── main/
│   │   │   ├── HomeScreen.tsx
│   │   │   └── ProfileScreen.tsx
│   │   └── index.ts
│   ├── services/               # Service layer
│   │   ├── api/
│   │   │   ├── client.ts
│   │   │   ├── endpoints.ts
│   │   │   └── index.ts
│   │   ├── notifications/
│   │   │   ├── NotificationService.ts
│   │   │   └── index.ts
│   │   └── index.ts
│   ├── stores/                 # Zustand stores
│   │   ├── authStore.ts
│   │   ├── taskStore.ts
│   │   ├── uiStore.ts
│   │   ├── settingsStore.ts
│   │   └── index.ts
│   ├── styles/                 # Styling
│   │   ├── colors.ts
│   │   ├── typography.ts
│   │   ├── spacing.ts
│   │   ├── shadows.ts
│   │   └── index.ts
│   ├── types/                  # TypeScript types
│   │   ├── navigation.ts
│   │   ├── api.ts
│   │   ├── store.ts
│   │   └── index.ts
│   └── utils/                  # Utilities
│       ├── validation/
│       ├── date/
│       ├── storage/
│       └── index.ts
├── docs/                       # Documentation
│   ├── api/
│   ├── architecture/
│   └── contributing/
└── scripts/                    # Scripts
    ├── setup.sh
    ├── build.ts
    └── deploy.ts
```

---

## Configuration Files

### Package.json

```json
{
  "name": "taskflow-app",
  "version": "1.0.0",
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "e2e": "detox test",
    "e2e:build": "detox build",
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write .",
    "type-check": "tsc --noEmit",
    "build": "expo build",
    "build:ios": "eas build --platform ios",
    "build:android": "eas build --platform android",
    "submit:ios": "eas submit --platform ios",
    "submit:android": "eas submit --platform android",
    "postinstall": "expo install"
  },
  "dependencies": {
    "expo": "~49.0.0",
    "expo-status-bar": "~1.6.0",
    "react": "18.2.0",
    "react-native": "0.72.6",
    "react-native-safe-area-context": "4.6.3",
    "react-native-screens": "~3.22.0",
    "@react-navigation/native": "^6.1.7",
    "@react-navigation/stack": "^6.3.17",
    "@react-navigation/bottom-tabs": "^6.5.8",
    "@react-navigation/drawer": "^6.6.3",
    "zustand": "^4.3.8",
    "@react-native-async-storage/async-storage": "1.18.2",
    "expo-sqlite": "~11.0.0",
    "react-native-mmkv": "^2.5.1",
    "expo-secure-store": "~12.0.0",
    "expo-notifications": "~0.20.0",
    "expo-camera": "~13.0.0",
    "expo-image-picker": "~14.0.0",
    "expo-location": "~16.0.0",
    "expo-haptics": "~12.0.0",
    "expo-localization": "~14.0.0",
    "expo-constants": "~14.0.0",
    "expo-device": "~5.0.0",
    "expo-file-system": "~11.0.0",
    "expo-image-manipulator": "~11.0.0",
    "i18n-js": "^4.2.2",
    "axios": "^1.4.0",
    "date-fns": "^2.30.0",
    "react-native-gesture-handler": "~2.12.0",
    "react-native-reanimated": "~3.3.0",
    "react-native-svg": "13.9.0",
    "@sentry/react-native": "^5.10.0",
    "mixpanel-react-native": "^2.2.0",
    "@react-native-community/netinfo": "9.3.7"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@types/react": "~18.2.0",
    "@types/react-native": "~0.72.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.45.0",
    "eslint-config-prettier": "^8.8.0",
    "jest": "^29.5.0",
    "jest-expo": "^49.0.0",
    "prettier": "^3.0.0",
    "typescript": "^5.0.0",
    "@testing-library/react-native": "^12.0.0",
    "@testing-library/jest-native": "^5.1.0",
    "detox": "^20.0.0",
    "eas-cli": "^4.0.0"
  }
}
```

### tsconfig.json

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
      "@assets/*": ["assets/*"],
      "@i18n/*": ["src/i18n/*"],
      "@analytics/*": ["src/analytics/*"],
      "@offline/*": ["src/offline/*"]
    },
    "types": [
      "jest",
      "@testing-library/jest-native",
      "node",
      "react-native",
      "expo"
    ]
  },
  "include": [
    "src/**/*",
    "App.tsx",
    "*.config.js",
    "*.setup.js"
  ],
  "exclude": [
    "node_modules",
    "babel.config.js",
    "metro.config.js",
    "jest.config.js",
    "**/__tests__/**/*.test.ts"
  ]
}
```

### .eslintrc.js

```javascript
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },
  settings: {
    react: {
      version: 'detect',
    },
    'import/resolver': {
      typescript: {},
    },
  },
  env: {
    jest: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'plugin:import/typescript',
    'prettier',
  ],
  plugins: [
    'react',
    'react-hooks',
    '@typescript-eslint',
    'import',
    'prettier',
  ],
  rules: {
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    'import/order': [
      'error',
      {
        groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],
    'prettier/prettier': ['error', {}, { usePrettierrc: true }],
  },
};
```

### .prettierrc

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf",
  "jsxSingleQuote": false,
  "jsxBracketSameLine": false
}
```

---

## Core Boilerplate Code

### App.tsx (Root Component)

```typescript
// App.tsx
import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { Platform } from 'react-native';

import { ThemeProvider } from '@/styles';
import { I18nProvider } from '@/i18n';
import { AnalyticsProvider } from '@/analytics';
import { OfflineProvider } from '@/offline';
import { AuthGuard } from '@/navigation/guards/AuthGuard';
import { RootStackNavigator } from '@/navigation/stacks/RootStack';
import { navigationService } from '@/navigation/NavigationService';
import { useAuthStore } from '@/stores/authStore';
import { useUIStore } from '@/stores/uiStore';

/**
 * App - Root component with all providers
 * 
 * This is the entry point of the application.
 * All global providers are wrapped here.
 */
export default function App() {
  const { checkAuth } = useAuthStore();
  const { setOnlineStatus } = useUIStore();

  useEffect(() => {
    // Initialize authentication
    checkAuth();

    // Set up network monitoring
    // NetInfo.addEventListener((state) => {
    //   setOnlineStatus(state.isConnected ?? false);
    // });

    // Initialize analytics
    // analytics.initialize();

    // Initialize offline sync
    // syncEngine.loadQueue();

    // Set up notifications
    // notificationService.requestPermissions();

    // Check for updates
    // checkForUpdates();

    // Performance monitoring
    // performanceMonitor.startFrameMeasurement();
  }, []);

  return (
    <SafeAreaProvider>
      <ThemeProvider>
        <I18nProvider>
          <AnalyticsProvider>
            <OfflineProvider>
              <NavigationContainer
                ref={navigationService.setTopLevelNavigator}
                // linking={DEEP_LINKING}
                // onStateChange={(state) => {
                //   if (state) {
                //     saveNavigationState(state);
                //   }
                // }}
              >
                <AuthGuard>
                  <RootStackNavigator />
                </AuthGuard>
                <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
              </NavigationContainer>
            </OfflineProvider>
          </AnalyticsProvider>
        </I18nProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
```

### Environment Configuration

```typescript
// src/config/environment.ts
import Constants from 'expo-constants';

export interface Environment {
  apiUrl: string;
  apiKey: string;
  environment: 'development' | 'staging' | 'production';
  sentryDsn: string;
  mixpanelToken: string;
  segmentKey: string;
  projectId: string;
  encryptionKey: string;
  googleMapsApiKey: string;
}

export const env: Environment = {
  apiUrl: Constants.manifest?.extra?.apiUrl || 'https://api.taskflow.app',
  apiKey: Constants.manifest?.extra?.apiKey || '',
  environment: Constants.manifest?.extra?.environment || 'development',
  sentryDsn: Constants.manifest?.extra?.sentryDsn || '',
  mixpanelToken: Constants.manifest?.extra?.mixpanelToken || '',
  segmentKey: Constants.manifest?.extra?.segmentKey || '',
  projectId: Constants.manifest?.extra?.projectId || '',
  encryptionKey: Constants.manifest?.extra?.encryptionKey || '',
  googleMapsApiKey: Constants.manifest?.extra?.googleMapsApiKey || '',
};

// Type-safe environment access
export const isDev = env.environment === 'development';
export const isStaging = env.environment === 'staging';
export const isProd = env.environment === 'production';

export default env;
```

### Root Store Setup

```typescript
// src/stores/index.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

import { authStore } from './authStore';
import { taskStore } from './taskStore';
import { uiStore } from './uiStore';
import { settingsStore } from './settingsStore';

/**
 * Root Store - Combines all stores
 * 
 * This provides a unified interface for all stores
 * and handles cross-store actions.
 */
export interface RootStore {
  auth: typeof authStore;
  tasks: typeof taskStore;
  ui: typeof uiStore;
  settings: typeof settingsStore;
  resetAll: () => void;
}

export const useRootStore = create<RootStore>()(
  persist(
    (set) => ({
      auth: authStore,
      tasks: taskStore,
      ui: uiStore,
      settings: settingsStore,
      
      resetAll: () => {
        // Reset all stores
        authStore.getState().logout();
        taskStore.getState().clearTasks();
        uiStore.getState().resetUI();
        settingsStore.getState().resetSettings();
        
        // Clear storage
        AsyncStorage.multiRemove(['auth-storage', 'task-storage', 'ui-storage', 'settings-storage']);
      },
    }),
    {
      name: 'root-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        // Only persist what's needed
        auth: {
          isAuthenticated: state.auth.isAuthenticated,
          user: state.auth.user,
        },
        tasks: {
          tasks: state.tasks.tasks,
          filters: state.tasks.filters,
        },
        settings: state.settings,
      }),
    }
  )
);

// Export individual stores for direct access
export * from './authStore';
export * from './taskStore';
export * from './uiStore';
export * from './settingsStore';

// Export hooks for convenience
export { useAuthStore, useTaskStore, useUIStore, useSettingsStore };
```

---

## Getting Started

### Step-by-Step Setup

```bash
# 1. Clone the template
git clone https://github.com/yourorg/react-native-template-taskflow my-app
cd my-app

# 2. Install dependencies
npm install

# 3. Set up environment
cp .env.example .env
# Edit .env with your values

# 4. Set up database
npm run db:init

# 5. Start development
npm start

# 6. Run on device
# Press 'i' for iOS, 'a' for Android, or scan QR code

# 7. Run tests
npm test

# 8. Build for production
npm run build:ios
npm run build:android
```

### Quick Customization Guide

```typescript
// src/config/constants.ts
export const AppConstants = {
  // App name
  APP_NAME: 'MyApp',
  
  // App version
  VERSION: '1.0.0',
  
  // Default language
  DEFAULT_LANGUAGE: 'en',
  
  // Supported languages
  SUPPORTED_LANGUAGES: ['en', 'es', 'fr'],
  
  // API endpoints
  API_ENDPOINTS: {
    AUTH: '/auth',
    TASKS: '/tasks',
    USERS: '/users',
  },
  
  // Feature flags
  FEATURES: {
    ENABLE_BIOMETRIC: true,
    ENABLE_OFFLINE: true,
    ENABLE_PUSH_NOTIFICATIONS: true,
    ENABLE_ANALYTICS: true,
  },
};
```

---

## Template Scripts

### Setup Script

```bash
#!/bin/bash
# scripts/setup.sh

echo "🚀 Setting up TaskFlow project..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+"
    exit 1
fi

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please install npm"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Setup environment
echo "🔧 Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env file"
fi

# Initialize database
echo "🗄️ Initializing database..."
npm run db:init

# Setup git hooks
echo "🔗 Setting up git hooks..."
npx husky install

echo "✅ Setup complete!"
echo ""
echo "📱 To start development:"
echo "  npm start"
echo ""
echo "📚 To run tests:"
echo "  npm test"
```

### Build Script

```typescript
// scripts/build.ts
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

/**
 * Build Script
 * 
 * This script handles building the app for production.
 */

interface BuildConfig {
  platform: 'ios' | 'android';
  configuration: 'development' | 'staging' | 'production';
  version: string;
  buildNumber: string;
}

const config: BuildConfig = {
  platform: process.argv[2] as 'ios' | 'android' || 'ios',
  configuration: process.argv[3] as 'development' | 'staging' | 'production' || 'production',
  version: process.env.npm_package_version || '1.0.0',
  buildNumber: process.env.BUILD_NUMBER || '1',
};

console.log(`📦 Building ${config.platform} (${config.configuration})`);

// Validate build
console.log('🔍 Validating build...');
execSync('npm run type-check', { stdio: 'inherit' });
execSync('npm run lint', { stdio: 'inherit' });
execSync('npm test', { stdio: 'inherit' });

// Build app
console.log('🏗️ Building app...');

try {
  const buildCommand = `eas build --platform ${config.platform} --profile ${config.configuration}`;
  execSync(buildCommand, { stdio: 'inherit' });
  console.log('✅ Build complete!');
} catch (error) {
  console.error('❌ Build failed:', error);
  process.exit(1);
}
```

---

## Quick Reference

### Common Commands

```bash
# Development
npm start                 # Start development server
npm run android          # Run on Android
npm run ios              # Run on iOS

# Testing
npm test                 # Run tests
npm run test:watch       # Run tests in watch mode
npm run test:coverage    # Run tests with coverage

# Linting
npm run lint             # Check linting
npm run lint:fix         # Fix linting issues
npm run format           # Format code

# Building
npm run build:ios        # Build for iOS
npm run build:android    # Build for Android
npm run build            # Build for both

# Submitting
npm run submit:ios       # Submit to App Store
npm run submit:android   # Submit to Play Store

# Type checking
npm run type-check       # Check TypeScript types
```

---

This appendix provides a complete, production-ready project template that incorporates all the patterns and best practices covered throughout this series. Use it as a starting point for your own projects.
