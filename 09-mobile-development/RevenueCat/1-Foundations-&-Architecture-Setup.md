# Part 1: Foundations & Architecture Setup

## Module Overview

Welcome to the first hands-on module of the RevenueCat tutorial series! We're going to build the foundation upon which everything else depends. By the end of this module, you'll have:

- ✅ A RevenueCat account configured with your first project
- ✅ App Store Connect products created and configured
- ✅ Google Play Console products created and configured
- ✅ RevenueCat entitlements and offerings defined
- ✅ The RevenueCat SDK installed and initialized in your React Native app
- ✅ A working paywall that displays dynamic pricing from RevenueCat

Think of this as laying the concrete foundation for a house. Everything we build later depends on getting this part right.

## How This Module Is Structured

We'll progress through four phases:

```
Phase 1: RevenueCat Platform Setup (30 min)
  └─ Create account, project, API keys

Phase 2: Store Configuration (60 min)
  ├─ App Store Connect (iOS)
  └─ Google Play Console (Android)

Phase 3: RevenueCat Product Configuration (30 min)
  ├─ Create products
  ├─ Define entitlements
  └─ Set up offerings

Phase 4: SDK Initialization (45 min)
  ├─ Create React Native project
  ├─ Install RevenueCat SDK
  ├─ Configure platform-specific settings
  └─ Initialize SDK and fetch offerings
```

---

## Phase 1: RevenueCat Platform Setup

### The Target

Create a RevenueCat account, set up your first project, and generate API keys for development.

### The Concept

RevenueCat acts as the middleware between your app and the app stores. To use it, you need:
1. **A Project**: Think of this as a container for all your app's configuration (similar to a Firebase project)
2. **API Keys**: These are credentials that allow your app to communicate with RevenueCat's servers
3. **Platform Configuration**: You'll tell RevenueCat which app stores you're using and provide necessary IDs

### Implementation

#### Step 1.1: Create Your RevenueCat Account

1. Navigate to [RevenueCat's website](https://www.revenuecat.com/)
2. Click "Start Free Trial" (don't worry, the free tier is generous)
3. Sign up using:
   - Google account
   - GitHub account
   - Email and password
4. After signing up, you'll land on the RevenueCat dashboard

#### Step 1.2: Create Your First Project

1. In the RevenueCat dashboard, click "New Project" in the top right
2. Enter a project name: **FitTrack Pro**
3. Select the platform(s) you'll be using:
   - ✅ iOS (App Store)
   - ✅ Android (Google Play)
   - ❌ Web (unchecked for now)
   - ❌ Amazon Appstore (unchecked)
4. Click "Create"

#### Step 1.3: Configure Project Details

You'll now see the project setup wizard. We'll configure the iOS and Android app settings:

**For iOS Configuration:**
1. Click "Configure" under the iOS section
2. You'll need:
   - **Bundle ID**: This matches your Xcode project (we'll use `com.yourcompany.fittrackpro`)
   - **App Store Connect Shared Secret**: We'll get this from App Store Connect in Phase 2
   - **Sandbox API Key**: Generated automatically by RevenueCat

**For Android Configuration:**
1. Click "Configure" under the Android section
2. You'll need:
   - **Package Name**: This matches your Android app ID (we'll use `com.yourcompany.fittrackpro`)
   - **Service Account Credentials**: We'll get these from Google Play Console in Phase 2

**Don't worry if you don't have all these IDs yet** – we can add them later. For now, just click "Skip" and we'll come back.

#### Step 1.4: Generate API Keys

1. In the left sidebar, click "Settings" (gear icon)
2. Click on "API Keys"
3. You'll see:
   - **Public API Key**: Used by your mobile app (safe to include in code)
   - **Secret API Key**: Used by your backend (keep this secure!)
   - **Webhook API Key**: Used for webhook verification (keep this secure!)

Let's generate a development API key:

1. Click "Create API Key"
2. Name it: **Development Key**
3. Permissions: Select "Read" and "Write" (for development)
4. Click "Create"
5. Copy the generated key – **save it somewhere secure** (we'll need it later)

Here's what your API keys should look like (these are examples, don't use these):

```
Public API Key:      app_abc123def456...
Secret API Key:      sk_hij789klm012...
Webhook API Key:     wh_nop345qrs678...
```

#### Step 1.5: Set Up Project Environment

Now let's create a `.env` file structure for our project that will securely store our keys:

**File: `FitTrackPro/frontend/.env.example`**

```bash
# RevenueCat Configuration
REVENUECAT_PUBLIC_API_KEY=your_public_api_key_here

# App Store Connect Configuration
APP_STORE_SHARED_SECRET=your_app_store_shared_secret_here

# Google Play Configuration
GOOGLE_PLAY_SERVICE_ACCOUNT=your_service_account_json_path_here

# App Configuration
APP_BUNDLE_ID=com.yourcompany.fittrackpro
APP_PACKAGE_NAME=com.yourcompany.fittrackpro

# Backend Configuration
BACKEND_API_URL=http://localhost:3000/api
BACKEND_WEBHOOK_SECRET=your_webhook_secret_here
```

### Verification

To verify your RevenueCat setup is working:

1. **Check Dashboard Access**: Log out and log back in to ensure your account is active
2. **API Key Test**: We'll test the API key in Phase 4 when we initialize the SDK
3. **Project Created**: You should see "FitTrack Pro" in your RevenueCat dashboard

---

## Phase 2: Store Configuration

### The Target

Configure in-app products and subscriptions in both App Store Connect and Google Play Console so they can be synced with RevenueCat.

### The Concept

Before RevenueCat can sell anything, you need to create products in the app stores themselves. Think of it like this:

- **App Store/Google Play**: The storefront (where products are listed)
- **RevenueCat**: The cash register (processes purchases and manages subscriptions)
- **Your App**: The customer (makes purchases at the cash register)

Products must exist in both places, and their identifiers must match for RevenueCat to connect them properly.

### Implementation

#### Step 2.1: Configure App Store Connect (iOS)

##### A. Prepare Your Environment

1. **Log in to App Store Connect** at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Navigate to "Apps" → Click the "+" button → Select "New App"
3. Fill in:
   - **Platform**: iOS
   - **Name**: FitTrack Pro
   - **Primary Language**: English (or your preference)
   - **Bundle ID**: You'll need to create one if you haven't already
   - **SKU**: `fittrackpro_001` (unique identifier for your app)
   - **User Access**: Full access
4. Click "Create"

##### B. Create Subscription Group

Subscription groups allow you to organize related subscription tiers:

1. In your app's page, click on "Subscriptions" in the left sidebar
2. Click the "+" button next to "Subscription Groups"
3. Name: **FitTrack Pro Subscriptions**
4. Reference Name: **Main Subscription Group**
5. Click "Create"

##### C. Create Subscription Products

Now we'll create our two subscription tiers:

**Monthly Subscription:**

1. In your subscription group, click the "+" button next to "Subscriptions"
2. Product Name: **FitTrack Pro Monthly**
3. Product ID: **com.yourcompany.fittrackpro.monthly**
   - ⚠️ **Important**: This ID must be unique and we'll use it in RevenueCat
4. Reference Name: **Monthly Subscription - $9.99**
5. Click "Create"

6. Now configure the pricing:
   - Click on your new subscription → "Pricing" tab
   - Click "Add Pricing"
   - Duration: 1 month
   - Introductory Offer: Optional (we'll add a free trial later)
   - Price: $9.99 USD (or your local currency equivalent)
   - Click "Save"

7. Configure the subscription details:
   - Click "Subscription Details" tab
   - Description: "Unlock all premium features with monthly access to workout tracking, nutrition logging, and personal trainer chat."
   - Promotional Text: "Get fit with daily workouts and personalized nutrition plans."
   - Click "Save"

**Annual Subscription:**

1. In the same subscription group, click the "+" button again
2. Product Name: **FitTrack Pro Annual**
3. Product ID: **com.yourcompany.fittrackpro.annual**
4. Reference Name: **Annual Subscription - $99.99**
5. Click "Create"

6. Configure pricing:
   - Click on your new subscription → "Pricing" tab
   - Click "Add Pricing"
   - Duration: 1 year
   - Introductory Offer: Optional
   - Price: $99.99 USD (20% savings vs monthly)
   - Click "Save"

7. Configure the subscription details:
   - Description: "Save 20% with annual access to all premium features including workout tracking, nutrition logging, and personal trainer chat."
   - Click "Save"

##### D. Add Introductory Offers (Free Trials)

Let's add a 7-day free trial to both subscriptions:

1. Go to the Monthly subscription → "Pricing" tab
2. Click "Add Introductory Offer"
3. Choose: **Free Trial**
4. Duration: 7 days
5. Click "Save"

6. Repeat for the Annual subscription

##### E. Generate the Shared Secret

1. In App Store Connect, go to "Users and Access" → "Shared Secret"
2. Under "App-Specific Shared Secret" for your app, click "Generate"
3. Copy the secret – **save this securely** (we'll need it for RevenueCat)

##### F. Set Up Sandbox Testing

1. Go to "Users and Access" → "Sandbox Testers"
2. Click the "+" button
3. Add a tester:
   - Name: Test User 1
   - Email: test1@example.com
   - Password: (generate a test password)
   - Territory: United States
   - Store: App Store
4. Click "Create"

We'll use this sandbox account to test purchases without real money.

#### Step 2.2: Configure Google Play Console (Android)

##### A. Prepare Your Environment

1. **Log in to Google Play Console** at [play.google.com/console](https://play.google.com/console)
2. Click "Create App"
3. Fill in:
   - **App Name**: FitTrack Pro
   - **Default Language**: English
   - **App or Game**: App
   - **Paid or Free**: Free (with in-app purchases)
   - **App Type**: Mobile
   - **Categories**: Health & Fitness
   - **Target Audience**: 13+
   - Click "Create"

##### B. Set Up In-App Products

1. Navigate to "Products" → "Subscriptions" in the left sidebar
2. Click "Create Subscription"

**Monthly Subscription:**
1. Product ID: **com.yourcompany.fittrackpro.monthly**
   - ⚠️ **Important**: This must match your App Store product ID exactly
2. Name: **FitTrack Pro Monthly**
3. Base Plan:
   - Name: Monthly Plan
   - Price: $9.99 USD
   - Billing Period: Monthly
   - Renewal Type: Auto-renewing
4. Click "Continue"
5. Activate the base plan
6. Click "Create"

**Annual Subscription:**
1. Click "Create Subscription"
2. Product ID: **com.yourcompany.fittrackpro.annual**
3. Name: **FitTrack Pro Annual**
4. Base Plan:
   - Name: Annual Plan
   - Price: $99.99 USD
   - Billing Period: Yearly
   - Renewal Type: Auto-renewing
5. Click "Continue"
6. Activate the base plan
7. Click "Create"

##### C. Set Up Service Account for RevenueCat

1. Navigate to "Setup" → "API Access" in the left sidebar
2. Click "Create New Service Account" under "Service Accounts"
3. Give it a name: **RevenueCat Integration**
4. Note the email address of the service account (it looks like `[your-project-name]@[your-project-id].iam.gserviceaccount.com`)
5. Click "Next"

6. Now we need to grant permissions:
   - Click "Grant Access" in the Google Cloud Console (this opens a new window)
   - Add these roles:
     - ✅ Google Play Console → Pub/Sub Subscriber
     - ✅ Google Play Console → Developer Account Viewer
     - ✅ Google Play Console → Android Publisher
   - Click "Save"

7. Go back to the Play Console and click "Next"
8. Download the JSON key file
   - Click "Create JSON"
   - The file will download automatically
   - **Save this file securely** – treat it like a password
   - Click "Done"

##### D. Add Test Accounts

1. In Google Play Console, go to "Setup" → "Testers"
2. Add your email address and any team members as testers
3. Click "Save"

##### E. Publish to Internal Testing Track

1. Go to "Release" → "Testing" → "Internal testing"
2. Click "Create New Release" if you haven't published before
3. Upload a test APK or bundle (we'll build this in Phase 4)
4. Add your testers to the test track
5. Click "Save"

### Verification

To verify your store configuration:

1. **Check Product IDs**: Ensure the Product IDs match between App Store Connect, Google Play Console, and RevenueCat
2. **App Store Sandbox Tester**: Log in with your sandbox account on a test device
3. **Google Play Test Track**: Ensure you can see your test app in the Play Store

---

## Phase 3: RevenueCat Product Configuration

### The Target

Connect your app store products to RevenueCat, create entitlements, and set up offerings.

### The Concept

This phase is where RevenueCat becomes your central source of truth. You'll define:
- **Entitlements**: The premium features users unlock (e.g., "premium_workouts")
- **Offerings**: The packages users can purchase (e.g., "Monthly" and "Annual")
- **Products**: Links to your App Store and Google Play products

### Implementation

#### Step 3.1: Configure Project Settings in RevenueCat

1. Log in to your RevenueCat dashboard
2. Click on "FitTrack Pro" project
3. Go to "Settings" → "Project Settings"

##### A. Add iOS Configuration

1. Under "iOS", click "Configure"
2. Enter:
   - **Bundle ID**: `com.yourcompany.fittrackpro`
   - **Shared Secret**: Paste the App Store Connect shared secret from Phase 2
3. Click "Save"

##### B. Add Android Configuration

1. Under "Android", click "Configure"
2. Enter:
   - **Package Name**: `com.yourcompany.fittrackpro`
   - Upload the JSON key file from Google Play Console
3. Click "Save"

#### Step 3.2: Create Entitlements

Entitlements are what your users actually get when they subscribe. Think of them as "keys" to premium features.

1. In the RevenueCat dashboard, go to "Entitlements"
2. Click "Create Entitlement"

**Create "premium_workouts" Entitlement:**
1. Name: **premium_workouts**
2. Display Name: **Premium Workouts**
3. Description: **Access to all workout types, including advanced routines and personalized plans**
4. Click "Create"

**Create "nutrition_tracking" Entitlement:**
1. Name: **nutrition_tracking**
2. Display Name: **Nutrition Tracking**
3. Description: **Full meal logging, calorie tracking, and macronutrient analysis**
4. Click "Create"

**Create "personal_trainer" Entitlement:**
1. Name: **personal_trainer**
2. Display Name: **Personal Trainer Access**
3. Description: **Chat with certified personal trainers for customized workout and nutrition advice**
4. Click "Create"

#### Step 3.3: Link Products to Entitlements

Now we need to tell RevenueCat which products grant which entitlements:

1. Go back to "Entitlements"
2. Click on "premium_workouts"
3. Under "Products", click "Add Product"
4. Add both:
   - **com.yourcompany.fittrackpro.monthly**
   - **com.yourcompany.fittrackpro.annual**
5. Click "Save"

6. Repeat for "nutrition_tracking" and "personal_trainer"
   - Add both products to each entitlement

#### Step 3.4: Create Offerings

Offerings are groups of packages you present to users. This is what your app will fetch and display on the paywall.

1. Go to "Offerings" in the RevenueCat dashboard
2. Click "Create Offering"

**Create "default" Offering:**
1. Name: **default**
2. Display Name: **Default Offering**
3. Description: **Standard subscription options for new users**

**Add Packages:**
1. Click "Add Package"
2. Select: **Monthly**
3. Product: **com.yourcompany.fittrackpro.monthly**
4. Click "Add"

5. Click "Add Package" again
6. Select: **Annual**
7. Product: **com.yourcompany.fittrackpro.annual**
8. Click "Add"

9. Click "Save"

**Now let's configure the trial for Annual:**
1. In the "Annual" package, click the edit icon
2. Under "Offer", select: **Introductory Offer** (this will use the free trial we set up)
3. Click "Save"

#### Step 3.5: Configure StoreKit Configuration (Optional but Recommended)

StoreKit configuration allows you to test purchases without real transactions:

1. In Xcode, create a StoreKit Configuration file:
   - File → New → File
   - Select "StoreKit Configuration"
   - Name it: `FitTrackPro.storekit`
   - Save it in your iOS project

2. Add your products to the StoreKit configuration:
   - Open the `.storekit` file
   - Click "+" → "Add Subscription"
   - Product ID: `com.yourcompany.fittrackpro.monthly`
   - Duration: 1 Month
   - Price: $9.99
   - Click "Save"

3. Repeat for annual subscription

This allows you to test purchases in the iOS simulator without connecting to the real App Store.

### Verification

To verify your RevenueCat configuration:

1. **Check Product Sync**: In RevenueCat, go to "Products" and verify both products appear with a green checkmark
2. **Test Offerings**: In the RevenueCat dashboard, go to "Offerings" and click "Test" → you should see your packages
3. **API Response**: We'll test this properly in Phase 4

---

## Phase 4: SDK Installation & Initialization

### The Target

Create a React Native project, install the RevenueCat SDK, configure platform-specific settings, and initialize the SDK with proper error handling.

### The Concept

The RevenueCat SDK is the bridge between your app and RevenueCat's servers. It handles:
- Purchase initiation and completion
- Receipt validation
- Subscription status checking
- Entitlement management
- Cross-device sync

When we initialize the SDK, we're essentially saying to RevenueCat: "Here's my app, here's who the user is, now let me know what they have access to."

### Implementation

#### Step 4.1: Create React Native Project

We'll use React Native CLI for this tutorial (Expo also works, but CLI gives us more control over native configurations):

**Open your terminal and run:**

```bash
# Navigate to your projects folder
cd ~/Projects

# Create a new React Native project with TypeScript
npx react-native init FitTrackPro --template react-native-template-typescript

# Navigate to the project directory
cd FitTrackPro
```

#### Step 4.2: Install RevenueCat SDK

```bash
# Install the RevenueCat React Native SDK
npm install react-native-purchases

# Install peer dependencies
npm install @react-native-async-storage/async-storage
```

#### Step 4.3: Configure iOS Native Settings

**Update the iOS Podfile:**

**File: `FitTrackPro/ios/Podfile`**

```ruby
require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

platform :ios, '13.0'

target 'FitTrackPro' do
  config = use_native_modules!

  use_react_native(
    :path => config[:reactNativePath],
    # Hermes is now enabled by default. Disable by setting this flag to false.
    :hermes_enabled => true
  )

  # Add RevenueCat pod
  pod 'RevenueCat', '~> 4.38'

  post_install do |installer|
    react_native_post_install(installer)
    
    # Fix for RevenueCat's required version
    installer.pods_project.targets.each do |target|
      if target.name == 'RevenueCat'
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end
end
```

**Install iOS dependencies:**

```bash
cd ios
pod install
cd ..
```

**Configure Info.plist for StoreKit:**

**File: `FitTrackPro/ios/FitTrackPro/Info.plist`**

Add this after the `</dict>` tag but before `</plist>`:

```xml
<key>NSUserActivityTypes</key>
<array>
    <string>com.yourcompany.fittrackpro.purchase</string>
</array>
```

**Enable In-App Purchase Capability in Xcode:**

1. Open `FitTrackPro/ios/FitTrackPro.xcworkspace`
2. Click on the project in the navigator
3. Select the "FitTrackPro" target
4. Click "Signing & Capabilities"
5. Click the "+" button
6. Search for "In-App Purchase" and add it
7. Enable "StoreKit" in the capabilities

#### Step 4.4: Configure Android Native Settings

**Update AndroidManifest.xml:**

**File: `FitTrackPro/android/app/src/main/AndroidManifest.xml`**

Add the billing permission and update the `launchMode`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.fittrackpro">

    <!-- Add billing permission -->
    <uses-permission android:name="com.android.vending.BILLING" />

    <application
        android:name=".MainApplication"
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:theme="@style/AppTheme">

        <activity
            android:name=".MainActivity"
            android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|screenSize|smallestScreenSize|uiMode"
            android:exported="true"
            android:launchMode="singleTop"  <!-- Important for Google Play Billing -->
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

**Update build.gradle:**

**File: `FitTrackPro/android/app/build.gradle`**

```gradle
android {
    ...
    defaultConfig {
        applicationId "com.yourcompany.fittrackpro"
        minSdkVersion 21  // Minimum version that supports Google Play Billing Library
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }
    ...
}

dependencies {
    // Ensure Google Play Billing Library is included
    implementation 'com.android.billingclient:billing:6.0.1'
    implementation 'com.android.billingclient:billing-ktx:6.0.1'  // For Kotlin
    ...
}
```

#### Step 4.5: Create Environment Configuration

Now let's set up environment variables for secure configuration:

**File: `FitTrackPro/.env`**

```bash
# RevenueCat Public API Key (safe to include in client)
REVENUECAT_PUBLIC_API_KEY=app_abc123def456...

# Backend API URL (for webhooks)
BACKEND_API_URL=http://localhost:3000/api

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGS=true
```

**File: `FitTrackPro/src/config/env.ts`**

```typescript
/**
 * Environment Configuration
 * Centralizes all environment variables with type safety
 */

// We need to import the config from react-native-dotenv
// This assumes you've installed and configured it

export interface Environment {
  revenueCatPublicApiKey: string;
  backendApiUrl: string;
  enableAnalytics: boolean;
  enableDebugLogs: boolean;
}

class EnvironmentManager {
  private static instance: EnvironmentManager;
  private config: Environment;

  private constructor() {
    this.config = {
      // In a real app, you'd use react-native-dotenv or react-native-config
      // For this tutorial, we'll use process.env with a fallback
      revenueCatPublicApiKey: process.env.REVENUECAT_PUBLIC_API_KEY || '',
      backendApiUrl: process.env.BACKEND_API_URL || 'http://localhost:3000/api',
      enableAnalytics: process.env.ENABLE_ANALYTICS === 'true',
      enableDebugLogs: process.env.ENABLE_DEBUG_LOGS === 'true',
    };

    // Validate critical configuration
    if (!this.config.revenueCatPublicApiKey) {
      console.warn('[Environment] RevenueCat Public API Key is not set');
    }
  }

  public static getInstance(): EnvironmentManager {
    if (!EnvironmentManager.instance) {
      EnvironmentManager.instance = new EnvironmentManager();
    }
    return EnvironmentManager.instance;
  }

  public getConfig(): Environment {
    return this.config;
  }

  public isDevelopment(): boolean {
    return process.env.NODE_ENV === 'development';
  }

  public isProduction(): boolean {
    return process.env.NODE_ENV === 'production';
  }
}

export const env = EnvironmentManager.getInstance().getConfig();
export default EnvironmentManager;
```

#### Step 4.6: Initialize RevenueCat SDK

Now let's create the RevenueCat service that initializes the SDK and provides clean interfaces:

**File: `FitTrackPro/src/services/RevenueCatService.ts`**

```typescript
import Purchases, {
  PurchasesConfiguration,
  CustomerInfo,
  Offerings,
  PurchasesError,
  PurchasePackage,
  LOG_LEVEL,
} from 'react-native-purchases';
import { env } from '../config/env';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * RevenueCat Service
 * 
 * This service handles all interactions with the RevenueCat SDK.
 * It provides a clean, error-handled interface for:
 * - SDK initialization
 * - Fetching offerings
 * - Making purchases
 * - Restoring purchases
 * - Getting customer information
 * - Listening to subscription changes
 * 
 * 🎯 Think of this as the "billing department" of your app.
 * It doesn't know about UI or business logic - it just handles
 * the technical aspects of purchases and subscriptions.
 */
export class RevenueCatService {
  private static instance: RevenueCatService;
  private isConfigured: boolean = false;
  private customerInfoListeners: Array<(info: CustomerInfo) => void> = [];

  private constructor() {
    // Private constructor for singleton pattern
  }

  /**
   * Get the singleton instance of the RevenueCat service
   */
  public static getInstance(): RevenueCatService {
    if (!RevenueCatService.instance) {
      RevenueCatService.instance = new RevenueCatService();
    }
    return RevenueCatService.instance;
  }

  /**
   * Initialize the RevenueCat SDK
   * 
   * This must be called before any other RevenueCat methods.
   * The SDK needs to know:
   * 1. Your Public API Key (to authenticate with RevenueCat servers)
   * 2. Your App User ID (to identify the user)
   * 3. The log level (for debugging)
   */
  public async initialize(appUserId?: string): Promise<void> {
    try {
      // Check if the SDK is already configured
      if (this.isConfigured) {
        console.log('[RevenueCat] SDK already configured');
        
        // If we have a new user ID, set it
        if (appUserId) {
          await Purchases.setAppUserID(appUserId);
        }
        return;
      }

      console.log('[RevenueCat] Initializing SDK...');

      // Get the API key from environment
      const apiKey = env.revenueCatPublicApiKey;
      if (!apiKey) {
        throw new Error('RevenueCat Public API Key is not configured');
      }

      // Configuration for the SDK
      const configuration: PurchasesConfiguration = {
        apiKey: apiKey,
        appUserID: appUserId, // If undefined, RevenueCat will generate an anonymous ID
        // Enable debug logs in development
        verboseLogs: env.enableDebugLogs,
        // Set log level - more verbose in development
        logLevel: env.isDevelopment ? LOG_LEVEL.DEBUG : LOG_LEVEL.INFO,
      };

      // Initialize the SDK
      await Purchases.configure(configuration);

      // Set the user ID if provided
      if (appUserId) {
        await Purchases.setAppUserID(appUserId);
      }

      this.isConfigured = true;
      console.log('[RevenueCat] SDK initialized successfully');

    } catch (error) {
      console.error('[RevenueCat] Failed to initialize SDK:', error);
      throw new Error(`RevenueCat initialization failed: ${error}`);
    }
  }

  /**
   * Get the current customer information
   * 
   * CustomerInfo contains:
   * - Active entitlements
   * - Subscription status
   * - Expiration dates
   * - Purchase history
   * 
   * 🔄 This method always fetches fresh data from RevenueCat
   */
  public async getCustomerInfo(): Promise<CustomerInfo | null> {
    if (!this.isConfigured) {
      console.warn('[RevenueCat] SDK not configured. Call initialize() first.');
      return null;
    }

    try {
      const customerInfo = await Purchases.getCustomerInfo();
      console.log('[RevenueCat] Customer info retrieved successfully');
      return customerInfo;
    } catch (error) {
      console.error('[RevenueCat] Failed to get customer info:', error);
      return null;
    }
  }

  /**
   * Fetch available offerings
   * 
   * Offerings are the groups of packages you've configured in the RevenueCat dashboard.
   * Each offering contains one or more packages (e.g., monthly, annual).
   * 
   * 📦 This is what you'll display on your paywall screen.
   */
  public async getOfferings(): Promise<Offerings | null> {
    if (!this.isConfigured) {
      console.warn('[RevenueCat] SDK not configured. Call initialize() first.');
      return null;
    }

    try {
      const offerings = await Purchases.getOfferings();
      console.log('[RevenueCat] Offerings fetched successfully', {
        currentOffering: offerings.current?.identifier,
        packageCount: offerings.current?.availablePackages.length,
      });
      return offerings;
    } catch (error) {
      console.error('[RevenueCat] Failed to get offerings:', error);
      return null;
    }
  }

  /**
   * Purchase a package
   * 
   * This is the core purchase method. It handles:
   * 1. Presenting the purchase sheet to the user
   * 2. Processing the transaction with the app store
   * 3. Validating the receipt with RevenueCat
   * 4. Granting entitlements
   * 
   * 💳 This is where the money changes hands (or doesn't, if the user cancels)
   */
  public async purchasePackage(packageToPurchase: PurchasePackage): Promise<{
    customerInfo: CustomerInfo;
    success: boolean;
  }> {
    if (!this.isConfigured) {
      throw new Error('RevenueCat SDK not configured. Call initialize() first.');
    }

    try {
      console.log('[RevenueCat] Starting purchase for package:', packageToPurchase.identifier);

      // The purchase method returns a transaction result with updated CustomerInfo
      const { customerInfo } = await Purchases.purchasePackage(packageToPurchase);

      console.log('[RevenueCat] Purchase completed successfully');
      return {
        customerInfo: customerInfo,
        success: true,
      };
    } catch (error) {
      // Handle specific purchase errors gracefully
      const purchaseError = error as PurchasesError;
      
      console.error('[RevenueCat] Purchase failed:', {
        code: purchaseError.code,
        message: purchaseError.message,
        userInfo: purchaseError.userInfo,
      });

      // Return a structured error that the UI can handle
      throw this.handlePurchaseError(purchaseError);
    }
  }

  /**
   * Restore purchases
   * 
   * This allows users to restore their purchases across devices.
   * For example, if a user gets a new phone, they can restore their
   * subscription.
   * 
   * 🎁 Apple requires this feature in all apps with subscriptions.
   */
  public async restorePurchases(): Promise<CustomerInfo> {
    if (!this.isConfigured) {
      throw new Error('RevenueCat SDK not configured. Call initialize() first.');
    }

    try {
      console.log('[RevenueCat] Restoring purchases...');
      const customerInfo = await Purchases.restorePurchases();
      console.log('[RevenueCat] Purchases restored successfully');
      return customerInfo;
    } catch (error) {
      console.error('[RevenueCat] Failed to restore purchases:', error);
      throw error;
    }
  }

  /**
   * Set the App User ID
   * 
   * If your app has its own user authentication system, you should
   * set the App User ID when the user logs in or logs out.
   * 
   * 🧑 This ensures that a user's subscription follows them across devices.
   */
  public async setAppUserID(userId: string): Promise<void> {
    if (!this.isConfigured) {
      console.warn('[RevenueCat] SDK not configured. Call initialize() first.');
      return;
    }

    try {
      await Purchases.setAppUserID(userId);
      console.log('[RevenueCat] App User ID set to:', userId);
    } catch (error) {
      console.error('[RevenueCat] Failed to set App User ID:', error);
      throw error;
    }
  }

  /**
   * Reset the App User ID to anonymous
   * 
   * Use this when a user logs out of your app.
   * The user's subscription will remain associated with their account,
   * but the SDK will now treat them as a new anonymous user.
   */
  public async resetAppUserID(): Promise<void> {
    if (!this.isConfigured) {
      console.warn('[RevenueCat] SDK not configured. Call initialize() first.');
      return;
    }

    try {
      await Purchases.resetAppUserID();
      console.log('[RevenueCat] App User ID reset to anonymous');
    } catch (error) {
      console.error('[RevenueCat] Failed to reset App User ID:', error);
      throw error;
    }
  }

  /**
   * Add a listener for CustomerInfo changes
   * 
   * This is the most important method for keeping your app's UI in sync
   * with the user's subscription status.
   * 
   * 🎯 When a user subscribes, cancels, or their subscription renews,
   * this listener will be called with updated CustomerInfo.
   * 
   * @param callback - Function called with updated CustomerInfo
   * @returns A function that removes the listener when called
   */
  public addCustomerInfoListener(
    callback: (info: CustomerInfo) => void
  ): () => void {
    // Store the callback so we can notify all listeners
    this.customerInfoListeners.push(callback);

    // Create the listener for RevenueCat
    const listener = Purchases.addCustomerInfoUpdateListener((info) => {
      console.log('[RevenueCat] CustomerInfo updated');
      // Notify all registered callbacks
      this.customerInfoListeners.forEach((cb) => cb(info));
    });

    // Return a function that removes the listener
    return () => {
      listener.remove();
      const index = this.customerInfoListeners.indexOf(callback);
      if (index > -1) {
        this.customerInfoListeners.splice(index, 1);
      }
    };
  }

  /**
   * Check if a specific entitlement is active
   * 
   * Convenience method to check if the user has access to a specific feature.
   * 
   * @param entitlementId - The ID of the entitlement to check
   * @param customerInfo - Optional CustomerInfo (if not provided, it will be fetched)
   */
  public async hasEntitlement(
    entitlementId: string,
    customerInfo?: CustomerInfo
  ): Promise<boolean> {
    try {
      let info = customerInfo;
      if (!info) {
        info = await this.getCustomerInfo();
        if (!info) {
          return false;
        }
      }

      // Check if the entitlement is active in the CustomerInfo
      const entitlement = info.entitlements.active[entitlementId];
      const isActive = entitlement !== undefined && entitlement !== null;

      console.log(`[RevenueCat] Entitlement "${entitlementId}" is active:`, isActive);
      return isActive;
    } catch (error) {
      console.error('[RevenueCat] Failed to check entitlement:', error);
      return false;
    }
  }

  /**
   * Get all active entitlements
   * 
   * Returns a map of all currently active entitlements with their details.
   * Useful for gating multiple premium features.
   */
  public async getActiveEntitlements(customerInfo?: CustomerInfo): Promise<Record<string, any>> {
    try {
      let info = customerInfo;
      if (!info) {
        info = await this.getCustomerInfo();
        if (!info) {
          return {};
        }
      }

      return info.entitlements.active;
    } catch (error) {
      console.error('[RevenueCat] Failed to get active entitlements:', error);
      return {};
    }
  }

  /**
   * Handle purchase errors and convert them to user-friendly messages
   * 
   * RevenueCat provides specific error codes that we can use to show
   * appropriate messages to the user.
   */
  private handlePurchaseError(error: PurchasesError): Error {
    // Map RevenueCat error codes to user-friendly messages
    const errorMessages: Record<string, string> = {
      'PURCHASE_CANCELLED': 'You cancelled the purchase. No charges were made.',
      'PRODUCT_NOT_AVAILABLE': 'This product is currently not available for purchase.',
      'USER_CANCELLED': 'The purchase was cancelled.',
      'PURCHASE_NOT_ALLOWED': 'In-app purchases are not allowed on this device.',
      'NETWORK_ERROR': 'Network error. Please check your internet connection and try again.',
      'INVALID_CREDENTIALS': 'Your account is not properly configured for purchases.',
      'RECEIPT_ALREADY_IN_USE': 'This receipt has already been used.',
      'UNKNOWN': 'An unexpected error occurred. Please try again later.',
    };

    const message = errorMessages[error.code] || errorMessages.UNKNOWN;
    return new Error(message);
  }

  /**
   * Log out of RevenueCat
   * 
   * This should be called when a user logs out of your app.
   * It resets the App User ID and clears any cached customer info.
   */
  public async logout(): Promise<void> {
    try {
      await this.resetAppUserID();
      console.log('[RevenueCat] User logged out');
    } catch (error) {
      console.error('[RevenueCat] Failed to logout:', error);
      throw error;
    }
  }
}

// Export a singleton instance
export const revenueCatService = RevenueCatService.getInstance();
export default revenueCatService;
```

#### Step 4.7: Create the Initialization Hook

Let's create a React hook that handles SDK initialization and provides a clean interface for components:

**File: `FitTrackPro/src/hooks/useRevenueCat.ts`**

```typescript
import { useEffect, useState, useCallback } from 'react';
import { CustomerInfo, Offerings, PurchasePackage } from 'react-native-purchases';
import { revenueCatService } from '../services/RevenueCatService';

/**
 * RevenueCat Hook
 * 
 * This hook provides a React-friendly interface to the RevenueCat service.
 * It handles:
 * - SDK initialization
 * - Loading states
 * - Error handling
 * - CustomerInfo updates
 * - Offerings fetching
 * 
 * 🔄 The hook automatically refreshes data when the user's subscription changes.
 */
export const useRevenueCat = (appUserId?: string) => {
  const [isInitialized, setIsInitialized] = useState<boolean>(false);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<Error | null>(null);
  const [customerInfo, setCustomerInfo] = useState<CustomerInfo | null>(null);
  const [offerings, setOfferings] = useState<Offerings | null>(null);
  const [activeEntitlements, setActiveEntitlements] = useState<Record<string, any>>({});

  /**
   * Initialize the RevenueCat SDK and fetch initial data
   */
  const initialize = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);

      // Initialize the SDK
      await revenueCatService.initialize(appUserId);

      // Fetch initial data
      const [info, offeringsData] = await Promise.all([
        revenueCatService.getCustomerInfo(),
        revenueCatService.getOfferings(),
      ]);

      setCustomerInfo(info);
      setOfferings(offeringsData);
      
      if (info) {
        setActiveEntitlements(info.entitlements.active);
      }

      setIsInitialized(true);
      console.log('[useRevenueCat] Initialization complete');
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error');
      setError(error);
      console.error('[useRevenueCat] Initialization failed:', error);
    } finally {
      setIsLoading(false);
    }
  }, [appUserId]);

  /**
   * Refresh customer info
   * 
   * Call this when you need fresh data (e.g., after a purchase or restore)
   */
  const refreshCustomerInfo = useCallback(async () => {
    try {
      setIsLoading(true);
      const info = await revenueCatService.getCustomerInfo();
      setCustomerInfo(info);
      if (info) {
        setActiveEntitlements(info.entitlements.active);
      }
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to refresh');
      setError(error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  /**
   * Purchase a package
   */
  const purchasePackage = useCallback(async (pkg: PurchasePackage) => {
    try {
      setIsLoading(true);
      const result = await revenueCatService.purchasePackage(pkg);
      
      // Update customer info with the new data
      setCustomerInfo(result.customerInfo);
      setActiveEntitlements(result.customerInfo.entitlements.active);
      
      return result;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Purchase failed');
      setError(error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  /**
   * Restore purchases
   */
  const restorePurchases = useCallback(async () => {
    try {
      setIsLoading(true);
      const info = await revenueCatService.restorePurchases();
      setCustomerInfo(info);
      setActiveEntitlements(info.entitlements.active);
      return info;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Restore failed');
      setError(error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  /**
   * Check if a specific entitlement is active
   */
  const hasEntitlement = useCallback(async (entitlementId: string) => {
    return revenueCatService.hasEntitlement(entitlementId, customerInfo || undefined);
  }, [customerInfo]);

  /**
   * Set up CustomerInfo listeners
   */
  useEffect(() => {
    if (!isInitialized) return;

    // Add listener for CustomerInfo updates
    const removeListener = revenueCatService.addCustomerInfoListener((info) => {
      console.log('[useRevenueCat] CustomerInfo updated via listener');
      setCustomerInfo(info);
      setActiveEntitlements(info.entitlements.active);
    });

    // Clean up listener on unmount
    return () => {
      removeListener();
    };
  }, [isInitialized]);

  /**
   * Initialize on mount
   */
  useEffect(() => {
    initialize();

    // Clean up on unmount
    return () => {
      // Any cleanup if needed
    };
  }, [initialize]);

  return {
    isInitialized,
    isLoading,
    error,
    customerInfo,
    offerings,
    activeEntitlements,
    initialize,
    refreshCustomerInfo,
    purchasePackage,
    restorePurchases,
    hasEntitlement,
  };
};

export default useRevenueCat;
```

#### Step 4.8: Create the App Entry Point with Initialization

**File: `FitTrackPro/App.tsx`**

```typescript
import React, { useEffect } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
  ActivityIndicator,
  Alert,
  Button,
} from 'react-native';
import { useRevenueCat } from './src/hooks/useRevenueCat';

/**
 * Main Application Component
 * 
 * This is the entry point of the app. It:
 * 1. Initializes the RevenueCat SDK
 * 2. Shows loading state while initializing
 * 3. Displays subscription status and offerings
 * 4. Provides a simple interface to test RevenueCat functionality
 */
const App = () => {
  // Initialize RevenueCat hook
  const {
    isInitialized,
    isLoading,
    error,
    customerInfo,
    offerings,
    activeEntitlements,
    purchasePackage,
    restorePurchases,
    hasEntitlement,
  } = useRevenueCat();

  /**
   * Handle purchase of a package
   */
  const handlePurchase = async (packageIdentifier: string) => {
    if (!offerings || !offerings.current) {
      Alert.alert('Error', 'No offerings available');
      return;
    }

    // Find the package by identifier
    const packageToPurchase = offerings.current.availablePackages.find(
      (pkg) => pkg.identifier === packageIdentifier
    );

    if (!packageToPurchase) {
      Alert.alert('Error', `Package "${packageIdentifier}" not found`);
      return;
    }

    try {
      const result = await purchasePackage(packageToPurchase);
      
      // Check what entitlements were granted
      const grantedEntitlements = Object.keys(result.customerInfo.entitlements.active);
      
      if (grantedEntitlements.length > 0) {
        Alert.alert(
          'Success! 🎉',
          `You now have access to: ${grantedEntitlements.join(', ')}`
        );
      } else {
        Alert.alert(
          'Purchase Complete',
          'Your purchase was successful. Your subscription may take a moment to activate.'
        );
      }
    } catch (error) {
      Alert.alert(
        'Purchase Failed',
        error instanceof Error ? error.message : 'An unknown error occurred'
      );
    }
  };

  /**
   * Handle restore purchase
   */
  const handleRestore = async () => {
    try {
      const info = await restorePurchases();
      const grantedEntitlements = Object.keys(info.entitlements.active);
      
      if (grantedEntitlements.length > 0) {
        Alert.alert(
          'Restored Successfully! ✅',
          `You have access to: ${grantedEntitlements.join(', ')}`
        );
      } else {
        Alert.alert(
          'No Purchases Found',
          'We couldn\'t find any existing purchases to restore.'
        );
      }
    } catch (error) {
      Alert.alert(
        'Restore Failed',
        error instanceof Error ? error.message : 'An unknown error occurred'
      );
    }
  };

  /**
   * Test checking a specific entitlement
   */
  const checkEntitlement = async (entitlementId: string) => {
    const hasAccess = await hasEntitlement(entitlementId);
    Alert.alert(
      'Entitlement Check',
      `Do you have "${entitlementId}"? ${hasAccess ? '✅ Yes' : '❌ No'}`
    );
  };

  // Show loading indicator while initializing
  if (isLoading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContent}>
          <ActivityIndicator size="large" color="#4A90D9" />
          <Text style={styles.loadingText}>Initializing RevenueCat...</Text>
        </View>
      </SafeAreaView>
    );
  }

  // Show error state
  if (error) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContent}>
          <Text style={styles.errorText}>Error: {error.message}</Text>
          <Text style={styles.subText}>
            Please check your configuration and try again.
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        {/* Header */}
        <Text style={styles.title}>FitTrack Pro</Text>
        <Text style={styles.subtitle}>RevenueCat Test App</Text>

        {/* Status Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Subscription Status</Text>
          <Text style={styles.statusText}>
            Initialized: {isInitialized ? '✅' : '❌'}
          </Text>
          <Text style={styles.statusText}>
            Active Entitlements: {Object.keys(activeEntitlements).length > 0 
              ? Object.keys(activeEntitlements).join(', ') 
              : 'None'}
          </Text>
        </View>

        {/* Offerings Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Available Packages</Text>
          {offerings && offerings.current ? (
            offerings.current.availablePackages.map((pkg) => (
              <View key={pkg.identifier} style={styles.packageCard}>
                <Text style={styles.packageName}>{pkg.identifier}</Text>
                <Text style={styles.packagePrice}>
                  {pkg.localizedPriceString}
                </Text>
                <Text style={styles.packageDetails}>
                  Product: {pkg.productIdentifier}
                </Text>
                <Button
                  title={`Subscribe to ${pkg.identifier}`}
                  onPress={() => handlePurchase(pkg.identifier)}
                  color="#4A90D9"
                />
              </View>
            ))
          ) : (
            <Text style={styles.noPackagesText}>
              No offerings available. Please check your RevenueCat configuration.
            </Text>
          )}
        </View>

        {/* Actions Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Actions</Text>
          <View style={styles.buttonContainer}>
            <Button
              title="Restore Purchases"
              onPress={handleRestore}
              color="#34A853"
            />
          </View>
          <View style={styles.buttonContainer}>
            <Button
              title="Check Premium Workouts"
              onPress={() => checkEntitlement('premium_workouts')}
              color="#FBBC04"
            />
          </View>
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
  },
  centerContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  content: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1A2B3C',
    textAlign: 'center',
    marginTop: 20,
  },
  subtitle: {
    fontSize: 16,
    color: '#657786',
    textAlign: 'center',
    marginBottom: 30,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#657786',
  },
  errorText: {
    fontSize: 18,
    color: '#E74C3C',
    textAlign: 'center',
    fontWeight: '600',
  },
  subText: {
    fontSize: 14,
    color: '#657786',
    textAlign: 'center',
    marginTop: 8,
  },
  section: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1A2B3C',
    marginBottom: 12,
  },
  statusText: {
    fontSize: 15,
    color: '#1A2B3C',
    marginBottom: 4,
  },
  packageCard: {
    backgroundColor: '#F8F9FA',
    borderRadius: 8,
    padding: 12,
    marginBottom: 12,
  },
  packageName: {
    fontSize: 16,
    fontWeight: '500',
    color: '#1A2B3C',
    marginBottom: 4,
  },
  packagePrice: {
    fontSize: 14,
    color: '#34A853',
    fontWeight: '600',
    marginBottom: 2,
  },
  packageDetails: {
    fontSize: 12,
    color: '#657786',
    marginBottom: 8,
  },
  noPackagesText: {
    fontSize: 14,
    color: '#657786',
    textAlign: 'center',
    paddingVertical: 16,
  },
  buttonContainer: {
    marginBottom: 8,
  },
});

export default App;
```

#### Step 4.9: Run the Application

**Testing on iOS:**

```bash
# Navigate to the iOS folder and install pods
cd ios
pod install
cd ..

# Start the React Native Metro bundler
npx react-native start

# In a new terminal, run the iOS app
npx react-native run-ios
```

**Testing on Android:**

```bash
# Start the React Native Metro bundler (if not already running)
npx react-native start

# In a new terminal, run the Android app
npx react-native run-android
```

### Verification

To verify your RevenueCat SDK is working:

1. **Check Console Logs**: You should see RevenueCat initialization logs
2. **View Offerings**: Your app should display the packages you created
3. **Test Purchase Flow**: Click "Subscribe" on a package to test the purchase flow
4. **Check Entitlements**: After purchasing, active entitlements should appear

**Test Purchase Steps:**
1. In the app, click "Subscribe to monthly" or "Subscribe to annual"
2. Use a sandbox/test account to complete the purchase
3. The app should show a success alert with the granted entitlements
4. The subscription should appear in the "Active Entitlements" section

**Common Issues and Solutions:**

| Issue | Solution |
|-------|----------|
| "No offerings available" | Check RevenueCat configuration, ensure products are linked |
| "API key invalid" | Verify your Public API key in `.env` |
| "Product not found" | Ensure Product IDs match between stores and RevenueCat |
| "Sandbox account not working" | Create a new sandbox tester in App Store Connect |

---

## Module Summary

Congratulations! You've completed Part 1 of the RevenueCat tutorial series. Here's what you've accomplished:

✅ **Created a RevenueCat Project**: Set up your account and project
✅ **Configured App Store Products**: Created subscriptions in App Store Connect
✅ **Configured Google Play Products**: Created subscriptions in Google Play Console
✅ **Set Up Entitlements**: Defined premium features in RevenueCat
✅ **Created Offerings**: Grouped packages into offerings for display
✅ **Installed RevenueCat SDK**: Added the SDK to your React Native project
✅ **Initialized the SDK**: Configured and initialized RevenueCat with proper error handling
✅ **Fetched Offerings**: Retrieved and displayed packages from RevenueCat
✅ **Implemented Purchase Flow**: Added basic purchase capabilities
✅ **Added Restore Functionality**: Implemented purchase restoration
✅ **Verified Everything Works**: Tested the entire flow in the app

### What You Can Do Now

Your app can now:
- Display subscription pricing from RevenueCat
- Process in-app purchases (in sandbox/test mode)
- Check a user's subscription status
- Restore existing purchases

### Next Steps

In **Part 2: Building the Paywall & Purchase Flow**, we'll:
- Create a beautiful, production-quality paywall UI
- Handle all purchase states and errors
- Improve the user experience with proper loading states
- Add promotional offers and free trials
- Build a robust restoration flow

---

## Reference: RevenueCat SDK Configuration Options

### Configuration Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apiKey` | string | ✅ Yes | Your RevenueCat Public API Key |
| `appUserID` | string | ❌ No | Custom user ID (if not provided, anonymous ID is generated) |
| `verboseLogs` | boolean | ❌ No | Enable verbose logging for debugging |
| `logLevel` | enum | ❌ No | Log level: `LOG_LEVEL.ERROR`, `LOG_LEVEL.WARN`, `LOG_LEVEL.INFO`, `LOG_LEVEL.DEBUG` |

### CustomerInfo Properties

| Property | Type | Description |
|----------|------|-------------|
| `entitlements` | object | Map of all entitlements and their status |
| `entitlements.active` | object | Currently active entitlements |
| `entitlements.all` | object | All entitlements (active and inactive) |
| `latestExpirationDate` | Date | Latest expiration date for any subscription |
| `firstSeen` | Date | When the user was first seen by RevenueCat |
| `originalAppUserId` | string | The original user ID |
| `originalApplicationVersion` | string | Original app version when user was first seen |
| `managementURL` | string | URL for managing subscription (App Store/Play Store) |

### Error Codes

| Code | Description |
|------|-------------|
| `PURCHASE_CANCELLED` | User cancelled the purchase |
| `PRODUCT_NOT_AVAILABLE` | Product not available for purchase |
| `USER_CANCELLED` | User cancelled the purchase |
| `PURCHASE_NOT_ALLOWED` | In-app purchases not allowed |
| `NETWORK_ERROR` | Network connectivity issue |
| `INVALID_CREDENTIALS` | Invalid API key or credentials |
| `RECEIPT_ALREADY_IN_USE` | Receipt already used |
| `UNKNOWN` | Unknown error occurred |

---

You now have a working RevenueCat integration with a basic interface. In Part 2, we'll transform this into a beautiful, user-friendly paywall that maximizes conversion rates while providing an excellent user experience.
