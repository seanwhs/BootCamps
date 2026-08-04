# Appendix A: RevenueCat SDK Deep Dive

## Overview

This appendix provides a comprehensive reference for the RevenueCat SDK, covering API details, platform-specific nuances, and advanced configuration options. While the main tutorial focused on practical implementation, this reference goes deeper into the SDK's capabilities and behavior.

Think of this appendix as your "cheat sheet" for the RevenueCat SDK – everything you need to know about the API, from initialization to advanced features, in one place .

---

## SDK Initialization & Configuration

### Core Configuration

The SDK must be configured once, early in your application lifecycle, typically in your main `Application` class or app entry point .

```typescript
// React Native / TypeScript
import Purchases, { LOG_LEVEL } from 'react-native-purchases';

// Configure with minimal options
Purchases.configure({
  apiKey: 'your_public_api_key',
  appUserID: userId, // optional - if omitted, an anonymous ID is generated
});

// Enable debug logging during development
Purchases.setLogLevel(LOG_LEVEL.DEBUG);
```

```swift
// iOS / Swift
import RevenueCat

Purchases.logLevel = .debug
Purchases.configure(withAPIKey: "your_public_api_key", appUserID: userId)
```

```kotlin
// Android / Kotlin
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.LogLevel

Purchases.logLevel = LogLevel.DEBUG
Purchases.configure(
    PurchasesConfiguration.Builder(context, "your_public_api_key")
        .appUserID(userId)
        .build()
)
```

```dart
// Flutter / Dart
import 'package:purchases_flutter/purchases_flutter.dart';

Purchases.setLogLevel(LogLevel.debug);
await Purchases.configure(
    PurchasesConfiguration('your_public_api_key')
      ..appUserId = userId,
);
```

### Configuration Options

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apiKey` | string | ✅ Yes | Your RevenueCat Public API Key from the dashboard |
| `appUserID` | string | ❌ No | Custom user ID (if not provided, anonymous ID is generated) |
| `observerMode` | boolean | ❌ No | If true, you handle purchase completion manually |
| `userDefaultsSuiteName` | string | ❌ No | iOS only - for app extensions |
| `proxyURL` | string | ❌ No | Custom proxy URL for restricted regions (China, Russia, Myanmar) |
| `verboseLogs` | boolean | ❌ No | Enable verbose logging for debugging (deprecated, use logLevel) |
| `logLevel` | enum | ❌ No | `DEBUG`, `INFO`, `WARN`, `ERROR` |

### Environment Strategies

#### Test Store vs Production

RevenueCat supports a built-in Test Store for development that doesn't require connecting to real app stores . This is configured automatically when you use a Test Store API key.

**Critical**: Never submit an app with a Test Store API key to the App Store or Google Play. Always use the correct platform-specific API key for production builds .

#### Environment Separation

For larger teams, consider creating separate RevenueCat projects for different environments (DEV, TEST, PROD) :

```typescript
// Example: Environment-based configuration
const getApiKey = () => {
  switch (process.env.NODE_ENV) {
    case 'development':
      return process.env.REVENUECAT_DEV_API_KEY;
    case 'test':
      return process.env.REVENUECAT_TEST_API_KEY;
    case 'production':
    default:
      return process.env.REVENUECAT_PROD_API_KEY;
  }
};
```

**Advantages of separate projects** :
- Clear separation of data across environments
- Better control over environment-specific settings
- No risk of sandbox data mixing with production data

**Considerations**:
- Requires additional setup and ongoing maintenance
- Need to manually replicate all aspects (paywalls, offerings, targeting rules)
- More suited for larger teams or stricter environment requirements

---

## CustomerInfo

### What is CustomerInfo?

`CustomerInfo` is the object that contains all information RevenueCat has about a user . It's the source of truth for subscription status and entitlements.

### Key Properties

```typescript
interface CustomerInfo {
  // Entitlements
  entitlements: {
    active: Record<string, EntitlementInfo>;    // Currently active entitlements
    all: Record<string, EntitlementInfo>;       // All entitlements (active and inactive)
  };
  
  // Subscription metadata
  activeSubscriptions: string[];                // Product IDs of active subscriptions
  allPurchasedProductIdentifiers: string[];     // All products ever purchased
  managementURL: string | null;                 // URL to manage subscription
  managementURLSandbox: string | null;          // Sandbox management URL
  
  // User metadata
  originalAppUserId: string;                    // Original user ID
  originalApplicationVersion: string | null;    // App version at first use
  firstSeen: string;                            // ISO date when user was first seen
  
  // Subscription lifecycle
  latestExpirationDate: string | null;          // Latest expiration date
  requestDate: string;                          // When this info was fetched
}
```

### EntitlementInfo

Each entitlement object contains detailed information about a specific entitlement :

```typescript
interface EntitlementInfo {
  identifier: string;                           // e.g., "premium_workouts"
  isActive: boolean;                            // Is this entitlement currently active?
  willRenew: boolean;                           // Will the subscription auto-renew?
  periodType: PeriodType;                       // 'normal', 'intro', 'trial'
  latestPurchaseDate: string;                   // ISO date of latest purchase
  originalPurchaseDate: string;                 // ISO date of first purchase
  expirationDate: string;                       // ISO date of expiration
  store: Store;                                 // 'app_store', 'play_store'
  productIdentifier: string;                    // Store product ID
  productPlanIdentifier: string | null;         // Plan identifier (Google Play)
  productPlatformIdentifier: string | null;     // Platform-specific product ID
  unsubscribeDetectedAt: string | null;         // When cancellation was detected
  billingIssueDetectedAt: string | null;        // When billing issues started
  gracePeriodExpiresAt: string | null;          // Grace period end date
}
```

### Listening for Updates

To keep your UI in sync, add a listener for CustomerInfo changes :

```typescript
// React Native
const listener = Purchases.addCustomerInfoUpdateListener((customerInfo) => {
  // Update your UI with the new customer info
  console.log('Customer info updated:', customerInfo);
});

// Remember to remove the listener when done
listener.remove();
```

```swift
// iOS
Purchases.shared.delegate = self

extension MyClass: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        // Update UI with new customer info
    }
}
```

```kotlin
// Android
Purchases.sharedInstance.setUpdatedCustomerInfoListener { customerInfo ->
    // Update UI with new customer info
}
```

### Caching and Refresh

CustomerInfo is cached locally and refreshed automatically . You can also manually refresh:

```typescript
// Force a refresh from RevenueCat's servers
const customerInfo = await Purchases.getCustomerInfo();

// Invalidate cache (force refresh on next call)
Purchases.invalidateCustomerInfoCache();
```

---

## Offerings & Packages

### Understanding Offerings

Offerings are groups of packages configured in the RevenueCat dashboard. They are the recommended way to display products because you can change what's offered without an app update .

```typescript
// Fetch offerings
const offerings = await Purchases.getOfferings();
const currentOffering = offerings.current;

// Check if an offering is available
if (currentOffering && currentOffering.availablePackages.length > 0) {
  // Display the packages
  const monthlyPackage = currentOffering.availablePackages.find(
    pkg => pkg.identifier === 'monthly'
  );
}
```

### Package Structure

```typescript
interface Package {
  identifier: string;                           // e.g., 'monthly', 'annual', '$rc_monthly'
  packageType: PackageType;                     // 'monthly', 'annual', 'lifetime', 'custom'
  product: StoreProduct;                        // The underlying store product
  storeProduct: StoreProduct;                   // Alias for product (newer SDK)
  presentedOfferingContext: PresentedOfferingContext; // Context about the offering
  localizedPriceString: string;                 // Already localized price
}
```

### StoreProduct Fields

`StoreProduct` represents the actual product from the app store :

```typescript
interface StoreProduct {
  identifier: string;                           // Store product ID
  price: number;                                // Raw price (use for calculations)
  priceString: string;                          // Localized price (display this!)
  localizedPriceString: string;                 // Same as priceString
  currencyCode: string;                         // ISO currency code
  title: string;                                // Product title
  description: string;                          // Product description
  productCategory: ProductCategory;             // 'subscription' or 'non_subscription'
  subscriptionGroupIdentifier: string | null;   // iOS subscription group
  subscriptionPeriod: SubscriptionPeriod | null; // Duration of subscription
  introductoryPrice: IntroductoryPrice | null;  // Introductory offer details
  discount: Discount | null;                    // Available discounts
}
```

### Critical Rule: Always Display Localized Price

**Never** hardcode a currency symbol or amount. Always display the store-provided localized price string :

```typescript
// ✅ DO THIS
<Text>{package.product.priceString}</Text>

// ❌ DON'T DO THIS
<Text>{'$' + package.product.price}</Text>
```

The localized price string already includes the correct currency symbol and locale formatting for the user's region .

### Fallback Strategies

If `offerings.current` is null or empty, implement fallback logic:

```typescript
const getOfferings = async () => {
  try {
    const offerings = await Purchases.getOfferings();
    
    if (offerings.current && offerings.current.availablePackages.length > 0) {
      return offerings.current;
    }
    
    // Fallback: Try to find any offering
    const allOfferings = Object.values(offerings.all);
    if (allOfferings.length > 0) {
      return allOfferings[0];
    }
    
    // Last resort: Fetch products by ID
    const products = await Purchases.getProducts(
      ['com.yourcompany.fittrackpro.monthly'],
      PRODUCT_CATEGORY.SUBSCRIPTION
    );
    
    if (products.length > 0) {
      // Build a package manually from the product
      // Note: This is less flexible than using offerings
    }
  } catch (error) {
    // Handle error - show cached or default prices
  }
};
```

---

## Purchase Flow

### Making a Purchase

```typescript
// React Native
import Purchases, { Package } from 'react-native-purchases';

const purchasePackage = async (packageToPurchase: Package) => {
  try {
    const { customerInfo, productIdentifier } = await Purchases.purchasePackage(
      packageToPurchase
    );
    
    // Check if purchase was successful
    const activeEntitlements = Object.keys(customerInfo.entitlements.active);
    if (activeEntitlements.length > 0) {
      console.log('🎉 Purchase successful!');
    }
  } catch (error) {
    // Handle error
    console.error('Purchase failed:', error);
  }
};
```

### Error Handling

RevenueCat provides specific error codes that can be used to show appropriate messages :

| Error Code | Description | User-Friendly Message |
|------------|-------------|----------------------|
| `PURCHASE_CANCELLED` | User cancelled | "You cancelled the purchase." |
| `PRODUCT_NOT_AVAILABLE` | Product not available | "This product is not available." |
| `PURCHASE_NOT_ALLOWED` | IAP not allowed | "In-app purchases are not allowed." |
| `NETWORK_ERROR` | Network issue | "Please check your internet connection." |
| `INVALID_CREDENTIALS` | Invalid API key | "Configuration error. Please contact support." |
| `RECEIPT_ALREADY_IN_USE` | Receipt already used | "This purchase has already been used." |

```typescript
try {
  await Purchases.purchasePackage(packageToPurchase);
} catch (error) {
  // RevenueCat error handling
  switch (error.code) {
    case 'PURCHASE_CANCELLED':
      // Don't show error dialog for user cancellation
      break;
    case 'NETWORK_ERROR':
      showUserMessage('Please check your internet connection');
      break;
    default:
      showUserMessage('Purchase failed. Please try again.');
      break;
  }
}
```

### Restoring Purchases

Apple requires all apps with subscriptions to provide a restore function :

```typescript
const restorePurchases = async () => {
  try {
    const customerInfo = await Purchases.restorePurchases();
    const activeEntitlements = Object.keys(customerInfo.entitlements.active);
    
    if (activeEntitlements.length > 0) {
      // Successfully restored
    } else {
      // No purchases to restore
    }
  } catch (error) {
    // Handle error
  }
};
```

---

## RevenueCat SDK vs Raw Store APIs

RevenueCat abstracts away much of the complexity of dealing with app stores directly :

| Concern | Raw Store API | RevenueCat |
|---------|---------------|------------|
| BillingClient setup and configuration | You write | Handled internally |
| Connection lifecycle and reconnection | You write | Handled internally |
| Receipt verification | You build server | Automatic |
| Purchase acknowledgement | You write | Handled automatically |
| Cloud Pub/Sub / RTDN | You set up | Not needed (webhooks instead) |
| Subscription state machine | You build | `isActive` computed by RC |
| Retry logic for transient errors | You write | Handled internally |
| Product-to-entitlement mapping | You build | Configured in RC dashboard |
| Grace period tracking | You build | `billingIssueDetectedAt` |

### What Remains Your Responsibility 

- **User authentication system**: You bring your own; pass user ID to RC
- **Your own database of users**: RC is not your primary user database
- **Premium content server-side**: Verify via RC REST API or webhooks
- **Webhook receiver endpoint**: You build; RC sends, you receive
- **Store product creation**: Still done in App Store Connect / Play Console
- **App UI (paywalls, onboarding)**: You build (RC Paywalls UI is optional)
- **Push notifications**: You build on top of webhook events

---

## Platform-Specific Notes

### iOS (Swift)

**Migration from v3 to v4** :

| v3 | v4 |
|----|-----|
| `import Purchases` | `import RevenueCat` |
| `PurchaserInfo` | `CustomerInfo` |
| `Transaction` | `StoreTransaction` |
| `purchaserInfoWithCompletion:` | `getCustomerInfoWithCompletion:` |
| `restoreTransactionsWithCompletion:` | `restorePurchasesWithCompletion:` |
| `offeringsWithCompletion:` | `getOfferingsWithCompletion:` |

**Async/await alternative** (iOS 13+):
```swift
let offerings = try await Purchases.shared.offerings()
let customerInfo = try await Purchases.shared.customerInfo()
```

### Android (Kotlin)

**Setup** :

```kotlin
// In Application.onCreate()
Purchases.logLevel = LogLevel.DEBUG
Purchases.configure(
    PurchasesConfiguration.Builder(context, "your_public_api_key")
        .appUserID(userId)
        .build()
)
```

**Note**: The SDK includes `com.android.billingclient:billing` as a transitive dependency. Do not add a conflicting version .

### React Native

**Version Requirements** :
- Test Store: `react-native-purchases` 9.5.4 or higher
- Virtual Currencies: `react-native-purchases` 9.1.0 or higher

**Setup**:
```typescript
import Purchases from 'react-native-purchases';

// Configure with platform-specific keys
Purchases.configure({
  apiKey: Platform.select({
    ios: 'ios_public_api_key',
    android: 'android_public_api_key',
  }),
  appUserID: userId,
});
```

---

## Advanced Features

### Virtual Currencies

RevenueCat supports virtual currencies for monetizing AI-powered features or in-app economies :

```typescript
// Fetch virtual currency balance
const currencies = await Purchases.getVirtualCurrencies();
const coinBalance = currencies.all['COINS'].balance;

// Invalidate cache for fresh balance
await Purchases.invalidateVirtualCurrenciesCache();
```

### Test Store

RevenueCat's Test Store allows you to test purchases without connecting to real app stores :

```typescript
// Use Test Store API key (from dashboard)
Purchases.configure({
  apiKey: 'test_store_api_key',
});
```

**Test Store features**:
- No real transactions
- Instant purchase processing
- No sandbox account setup required
- Automatically works with your configured products

### Proxy Configuration

For users in regions where RevenueCat's API is blocked (mainland China, Russia, Myanmar) :

```typescript
// Set proxy before configuring
Purchases.setProxyURL('https://api.rc-backup.com/');
Purchases.configure({
  apiKey: 'your_api_key',
});
```

---

## Error Handling Reference

### HTTP Status Codes 

| Code | Name | Description |
|------|------|-------------|
| 200 | OK | Request processed successfully |
| 400 | Bad Request | Client error |
| 401 | Unauthorized | Not authenticated |
| 403 | Forbidden | Authorization failed |
| 404 | Not Found | Resource not found |
| 422 | Unprocessable entity | Valid request but couldn't process |
| 429 | Too Many Requests | Rate limited |
| 500 | Internal Server Error | RevenueCat server issue |

### Rate Limits 

| Domain | Limit (requests/minute) |
|--------|-------------------------|
| Customer Information | 480 |
| Charts & Metrics | 25 |
| Project Configuration | 60 |

Rate limit headers:
- `RevenueCat-Rate-Limit-Current-Usage`: Requests used
- `RevenueCat-Rate-Limit-Current-Limit`: Limit per minute
- `Retry-After`: Seconds to wait (when 429 is returned)

---

This appendix serves as a comprehensive reference for the RevenueCat SDK. For the latest updates and platform-specific details, always refer to the [official RevenueCat documentation](https://www.revenuecat.com/docs).
