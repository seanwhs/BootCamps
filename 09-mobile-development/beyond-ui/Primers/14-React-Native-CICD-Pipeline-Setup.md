# Primer 14: React Native CI/CD Pipeline Setup

## Your Complete Guide to Automated Mobile Deployments

Welcome to the CI/CD Primer! This guide covers everything you need to know about setting up Continuous Integration and Continuous Deployment (CI/CD) for your React Native applications. CI/CD automates the process of building, testing, and deploying your app—ensuring quality and speeding up delivery.

---

## C.1 Understanding CI/CD

### The Concept: Automated Delivery Pipeline

CI/CD is a set of practices that automate the building, testing, and deployment of software. Think of it as an automated assembly line for your code—each change goes through the same process, ensuring consistency and quality.

**Simple Analogy:** CI/CD is like an automated car wash. You drive in (commit code), the machine washes (builds), dries (tests), and polishes (deploys) your car, and it comes out clean and ready to go. Every car goes through the same process, so you know it will be done right.

### CI/CD Pipeline Stages

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CI/CD PIPELINE                                  │
│                                                                             │
│  1. Code Commit → 2. Build → 3. Test → 4. Deploy to Staging → 5. Deploy   │
│                                                                             │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐ │
│  │  Push    │   │  Build   │   │  Test    │   │  Staging │   │  Prod    │ │
│  │  Code    │ → │  App     │ → │  Suite   │ → │  Deploy  │ → │  Deploy  │ │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## C.2 GitHub Actions CI/CD

### The Concept: GitHub's Native CI/CD

GitHub Actions provides powerful CI/CD capabilities directly in your GitHub repository.

### Complete GitHub Actions Guide

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # 1. Lint & Format
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Check formatting
        run: npm run format -- --check

  # 2. Type Checking
  type-check:
    name: TypeScript Type Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run TypeScript type check
        run: npm run type-check

  # 3. Unit & Integration Tests
  test:
    name: Unit & Integration Tests
    runs-on: ubuntu-latest
    needs: [lint, type-check]
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npm run test:ci

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          directory: ./coverage
          flags: unittests
          fail_ci_if_error: false

  # 4. E2E Tests (iOS)
  e2e-ios:
    name: E2E Tests (iOS)
    runs-on: macos-latest
    needs: [test]
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Detox dependencies
        run: |
          brew tap wix/brew
          brew install applesimutils

      - name: Build iOS app
        run: npm run build:ios:ci

      - name: Run E2E tests
        run: npm run test:e2e:ios

  # 5. E2E Tests (Android)
  e2e-android:
    name: E2E Tests (Android)
    runs-on: macos-latest
    needs: [test]
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Setup Android SDK
        uses: android-actions/setup-android@v2

      - name: Create emulator
        run: |
          avdmanager create avd -n Pixel_4_API_33 -k "system-images;android-33;google_apis;x86_64"

      - name: Build Android app
        run: npm run build:android:ci

      - name: Run E2E tests
        run: npm run test:e2e:android

  # 6. Build Production
  build:
    name: Build Production
    runs-on: ubuntu-latest
    needs: [e2e-ios, e2e-android]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build for production
        run: npm run build:prod

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-artifacts
          path: |
            dist/
            build/
          retention-days: 30

  # 7. Deploy to Stores
  deploy:
    name: Deploy to App Stores
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: build-artifacts
          path: ./dist

      - name: Deploy to EAS
        uses: expo/expo-github-action@v8
        with:
          eas-version: latest
          token: ${{ secrets.EXPO_TOKEN }}
          args: build:submit --platform all --latest
```

---

## C.3 EAS Build Configuration

### The Concept: Expo's Build Service

EAS Build is Expo's cloud-based build service that handles building and deploying React Native apps.

### Complete EAS Guide

```json
// eas.json
{
  "cli": {
    "version": ">= 3.0.0"
  },
  "build": {
    // Development builds
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "channel": "development",
      "android": {
        "gradleCommand": ":app:assembleDebug"
      },
      "ios": {
        "buildConfiguration": "Debug"
      }
    },

    // Preview/Staging builds
    "preview": {
      "distribution": "internal",
      "channel": "preview",
      "android": {
        "buildType": "apk"
      },
      "ios": {
        "simulator": true
      }
    },

    // Production builds
    "production": {
      "channel": "production",
      "autoIncrement": true,
      "android": {
        "buildType": "app-bundle",
        "gradleCommand": ":app:bundleRelease"
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

```json
// app.json - EAS Configuration
{
  "expo": {
    "name": "NexusCollect",
    "slug": "nexuscollect",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "updates": {
      "enabled": true,
      "checkAutomatically": "ON_LOAD",
      "fallbackToCacheTimeout": 30000,
      "url": "https://u.expo.dev/your-project-id"
    },
    "ios": {
      "bundleIdentifier": "com.yourcompany.nexuscollect",
      "buildNumber": "1.0.0"
    },
    "android": {
      "package": "com.yourcompany.nexuscollect",
      "versionCode": 1
    },
    "extra": {
      "eas": {
        "projectId": "your-project-id"
      }
    }
  }
}
```

---

## C.4 Fastlane Automation

### The Concept: Automating App Store Tasks

Fastlane automates the tedious tasks of building, signing, and submitting apps to stores.

### Complete Fastlane Guide

```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Deploy to App Store"
  lane :deploy do
    # Build the app
    build_app(
      scheme: "NexusCollect",
      configuration: "Release",
      export_method: "app-store"
    )

    # Upload to App Store
    upload_to_app_store(
      skip_metadata: false,
      skip_screenshots: false,
      precheck_include_in_app_purchases: false,
      submission_information: {
        add_id_info_uses_idfa: false
      }
    )
  end

  desc "Deploy to TestFlight"
  lane :beta do
    build_app(
      scheme: "NexusCollect",
      configuration: "Release",
      export_method: "app-store"
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end

platform :android do
  desc "Deploy to Play Store"
  lane :deploy do
    # Build the app
    gradle(
      task: "bundle",
      build_type: "Release",
      properties: {
        "android.injected.signing.store.file" => "keystore.jks",
        "android.injected.signing.store.password" => ENV["ANDROID_STORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["ANDROID_KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["ANDROID_KEY_PASSWORD"],
      }
    )

    # Upload to Play Store
    upload_to_play_store(
      track: "production",
      release_status: "completed"
    )
  end

  desc "Deploy to Internal Testing"
  lane :beta do
    gradle(
      task: "bundle",
      build_type: "Release"
    )

    upload_to_play_store(
      track: "internal",
      release_status: "draft"
    )
  end
end

# Shared lanes
lane :ci_setup do
  # Set up environment
  setup_ci
end

lane :screenshots do
  # Capture screenshots
  capture_screenshots
end
```

```ruby
# fastlane/Appfile
app_identifier("com.yourcompany.nexuscollect")
apple_id("your-apple-id@example.com")
team_id("your-team-id")

# For Android
json_key_file("path/to/service-account-key.json")
package_name("com.yourcompany.nexuscollect")
```

```ruby
# fastlane/Matchfile
git_url("https://github.com/your-org/certificates")
type("development")
app_identifier("com.yourcompany.nexuscollect")
```

---

## C.5 Deployment Scripts

### The Concept: One-Command Deployment

Deployment scripts automate the entire release process.

### Complete Deployment Scripts

```json
// package.json - Scripts
{
  "scripts": {
    // Build scripts
    "build:prod": "eas build --platform all --profile production",
    "build:prod:ios": "eas build --platform ios --profile production",
    "build:prod:android": "eas build --platform android --profile production",

    // Submit scripts
    "submit:ios": "eas submit --platform ios",
    "submit:android": "eas submit --platform android",
    "submit:all": "eas submit --platform all",

    // OTA Update scripts
    "deploy:ota": "eas update --branch production --message 'OTA Update'",
    "deploy:ota:staging": "eas update --branch staging --message 'Staging OTA Update'",

    // CI scripts
    "build:ios:ci": "xcodebuild -workspace ios/NexusCollect.xcworkspace -scheme NexusCollect -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build",
    "build:android:ci": "cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug && cd ..",
    "test:ci": "jest --ci --coverage --maxWorkers=2",
    "test:e2e:ci": "detox test --ci",

    // Full deployment
    "deploy": "npm run version && npm run build:prod && npm run submit:all",
    "deploy:ios": "npm run version && npm run build:prod:ios && npm run submit:ios",
    "deploy:android": "npm run version && npm run build:prod:android && npm run submit:android",

    // Version management
    "version": "node scripts/version.js",
    "release": "npm run type-check && npm run test && npm run deploy"
  }
}
```

```javascript
// scripts/version.js
/**
 * Version Management Script
 * Handles versioning for releases
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function getCurrentVersion() {
  const packageJson = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../package.json'), 'utf8')
  );
  return packageJson.version;
}

function updateVersion(newVersion) {
  // Update package.json
  const packagePath = path.join(__dirname, '../package.json');
  const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
  packageJson.version = newVersion;
  fs.writeFileSync(packagePath, JSON.stringify(packageJson, null, 2));

  // Update app.json
  const appPath = path.join(__dirname, '../app.json');
  const appJson = JSON.parse(fs.readFileSync(appPath, 'utf8'));
  appJson.expo.version = newVersion;
  appJson.expo.ios.buildNumber = newVersion;
  appJson.expo.android.versionCode = parseInt(newVersion.replace(/\./g, ''));
  fs.writeFileSync(appPath, JSON.stringify(appJson, null, 2));

  console.log(`✅ Updated version to ${newVersion}`);
}

function getNextVersion(current, type) {
  const parts = current.split('.').map(Number);

  switch (type) {
    case 'patch':
      parts[2] += 1;
      break;
    case 'minor':
      parts[1] += 1;
      parts[2] = 0;
      break;
    case 'major':
      parts[0] += 1;
      parts[1] = 0;
      parts[2] = 0;
      break;
    default:
      throw new Error('Invalid version type');
  }

  return parts.join('.');
}

async function promptVersion() {
  const current = getCurrentVersion();
  console.log(`📦 Current version: ${current}`);

  return new Promise((resolve) => {
    rl.question('Version type (patch/minor/major): ', (type) => {
      const version = getNextVersion(current, type.trim());
      console.log(`📦 New version: ${version}`);

      rl.question('Confirm? (y/n): ', (confirmed) => {
        if (confirmed.toLowerCase() === 'y') {
          resolve(version);
        } else {
          console.log('❌ Cancelled');
          process.exit(0);
        }
      });
    });
  });
}

async function main() {
  try {
    const version = await promptVersion();
    updateVersion(version);

    // Git commit and tag
    const { execSync } = require('child_process');
    execSync(`git add package.json app.json`);
    execSync(`git commit -m "chore: release version ${version}"`);
    execSync(`git tag -a v${version} -m "Release version ${version}"`);
    execSync(`git push origin main --tags`);

    console.log(`✅ Version ${version} released successfully!`);
  } catch (error) {
    console.error('❌ Version update failed:', error);
    process.exit(1);
  } finally {
    rl.close();
  }
}

main();
```

---

## C.6 Environment Secrets

### The Concept: Securing Sensitive Data

Environment secrets protect sensitive information in CI/CD pipelines.

### Complete Secrets Guide

```bash
# 1. GitHub Secrets
# Repository → Settings → Secrets and variables → Actions

# Required Secrets:
# EXPO_TOKEN - Expo authentication token
# CODECOV_TOKEN - Codecov upload token
# SENTRY_DSN - Sentry error tracking
# SUPABASE_URL - Supabase project URL
# SUPABASE_ANON_KEY - Supabase anonymous key

# iOS Secrets:
# APPLE_ID - Apple Developer account email
# APPLE_TEAM_ID - Apple Developer team ID
# APP_STORE_CONNECT_API_KEY - App Store Connect API key

# Android Secrets:
# ANDROID_SERVICE_ACCOUNT_KEY - Google Play service account key
# ANDROID_STORE_PASSWORD - Keystore password
# ANDROID_KEY_ALIAS - Keystore alias
# ANDROID_KEY_PASSWORD - Key password

# 2. Access Secrets in CI
# .github/workflows/ci.yml
- name: Build with secrets
  run: npm run build:prod
  env:
    EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}

# 3. Local Environment Variables
# .env.production
API_URL=https://api.nexuscollect.com
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-key
ENVIRONMENT=production
LOG_LEVEL=error

# 4. Encrypted Secrets in Repository
# Using git-crypt or similar tools
git-crypt init
git-crypt add-gpg-user your-gpg-key
echo "*.env" > .gitattributes
git add .gitattributes
git-crypt lock
```

---

## C.7 Quick Reference

### Deployment Commands

```bash
# EAS Build
eas build --platform ios --profile production
eas build --platform android --profile production
eas build --platform all --profile production

# EAS Submit
eas submit --platform ios
eas submit --platform android
eas submit --platform all

# OTA Updates
eas update --branch production --message "Update message"

# Fastlane
fastlane ios deploy
fastlane android deploy
fastlane ios beta
fastlane android beta

# Version Management
npm run version
npm run deploy
npm run deploy:ios
npm run deploy:android
```

### CI/CD Checklist

| Item | Status |
|------|--------|
| GitHub Actions configured | ✅ |
| EAS Build configured | ✅ |
| Fastlane configured | ✅ |
| Environment secrets set | ✅ |
| Unit tests running in CI | ✅ |
| E2E tests running in CI | ✅ |
| Production builds working | ✅ |
| Store submission automated | ✅ |
| OTA updates configured | ✅ |
| Rollback strategy ready | ✅ |

---

**Ready to automate your deployment? Let's build NexusCollect!**
