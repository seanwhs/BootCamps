# RevenueCat Masterclass: References & Resources

## Complete Reference Guide for Building Subscription Apps

---

# OFFICIAL DOCUMENTATION

## RevenueCat Core Documentation

### Getting Started
| Resource | Description | Link |
|----------|-------------|------|
| RevenueCat Documentation | Complete guide to all features | [docs.revenuecat.com](https://www.revenuecat.com/docs) |
| Getting Started Guide | Step-by-step setup instructions | [RevenueCat Docs](https://www.revenuecat.com/docs/getting-started) |
| Configuring the SDK | Platform-specific setup guides | [docs.revenuecat.com/docs/getting-started/configuring-sdk](https://www.revenuecat.com/docs/getting-started/configuring-sdk)  |
| Error Handling Guide | Understanding error codes and solutions | [RevenueCat Docs](https://www.revenuecat.com/docs/error-handling) |
| Debugging Guide | Official troubleshooting tips | [RevenueCat Docs](https://www.revenuecat.com/docs/debugging) |

### Product Configuration
| Resource | Description |
|----------|-------------|
| Configuring Products | Set up products, entitlements, and offerings in the dashboard  |
| Creating Entitlements | Define access levels users unlock |
| Creating Offerings | Group products for paywall display |
| Test Store | Create products instantly without app store accounts |

**Key Concepts** :
- **Products** - Individual items users purchase (e.g., "Monthly Premium")
- **Entitlements** - The access level users receive (e.g., "premium")
- **Offerings** - How you group and display products in your app

---

# SDK & API REFERENCES

## React Native SDK

### Installation & Setup
```bash
npm install --save react-native-purchases
# or
yarn add react-native-purchases
```

For RevenueCatUI (pre-built paywall components):
```bash
npm install --save react-native-purchases-ui
```

### Platform-Specific Configuration 

**iOS Setup**:
1. Open project in Xcode
2. Select project target → "Signing & Capabilities"
3. Add "In-App Purchase" capability

**Android Setup**:
Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

Set `launchMode` to `standard` or `singleTop`:
```xml
<activity android:launchMode="standard" ... />
```

### React Native Web Support 

Starting from release **9.7.6** of `react-native-purchases`, you can manage subscriptions across iOS, Android, and web using the same SDK.

**Configuration**:
```javascript
import { Platform } from 'react-native';
import Purchases from 'react-native-purchases';

if (Platform.OS === 'web') {
  Purchases.configure({ apiKey: '<public_web_billing_api_key>' });
} else if (Platform.OS === 'ios') {
  Purchases.configure({ apiKey: '<public_apple_api_key>' });
} else if (Platform.OS === 'android') {
  Purchases.configure({ apiKey: '<public_google_api_key>' });
}
```

**Key Methods That Work on All Platforms** :
- `Purchases.getOfferings()` - Check offerings
- `Purchases.getCustomerInfo()` - Check entitlements
- `Purchases.purchasePackage()` - Purchase a package

**Note**: `restorePurchases()` is not supported on web environments.

---

# CODELABS & TUTORIALS

## Interactive Learning

### RevenueCat Codelabs
| Codelab | Description | Time |
|---------|-------------|------|
| React Native In-App Purchases | Integrate SDK, fetch offerings, display paywalls  | ~45 min |
| Monetization Strategies | Optimize paywalls, A/B testing, reduce churn  | ~44 min |
| Troubleshooting Guide | Debug common issues with RevenueCat  | ~30 min |
| Google Play Configuration | Set up Google Play products | ~20 min |
| App Store Configuration | Set up App Store products | ~20 min |

**All codelabs available at**: [revenuecat.github.io/codelabs/](https://revenuecat.github.io/codelabs/) 

---

# KEY BENCHMARKS & DATA

## Industry Benchmarks 

### Conversion Rates
| Metric | Median | Top Quartile |
|--------|--------|--------------|
| App Downloads → Paying Users (30 days) | 1.7% | 4.2% |
| Trial → Paid Conversion | 38% | 60%+ |

### 14-Day ARPU by Category 
| Category | Median ARPU |
|----------|-------------|
| Health & Fitness | $0.44 |
| All Apps | $0.31 |
| Top Quartile Apps | $0.89 |

### Plan Mix by Category 
| Category | Dominant Plan |
|----------|---------------|
| Gaming | Weekly (82% short plans) |
| Productivity | Yearly (77%) |
| Health & Fitness | Yearly (68%) |
| Travel, Shopping | Yearly (~66%) |

**Key Insight**: Yearly plans renew at 83.4% overall vs 39.2% monthly and 18.7% weekly .

### Regional Preferences 
| Region | Preferred Plan |
|--------|----------------|
| North America | Yearly-skewed (40%) |
| Western Europe | Yearly-skewed (35%) |
| MEA | Monthly-skewed (55%) |
| Latin America | Weekly-skewed (29%) |

---

# GROWTH TOOLS & FEATURES

## RevenueCat Growth Suite 

### Paywalls
- Remotely configurable native paywall templates
- No engineering effort required to launch or update
- A/B test different designs and copy

### Targeting
- Tailor offerings by country, platform, and app version
- Custom-defined audience segments
- Show the right offer to the right user

### Experiments 
- A/B test pricing, packaging, and paywall design
- Analyze full subscription lifecycle metrics
- Potential revenue boost up to 40%

**What to Test** :
- **Subscription duration**: Weekly vs Monthly vs Annual
- **Trial length**: 3-day vs 7-day vs 14-day
- **Introductory pricing**: Discount levels, free vs paid trial
- **Paywall design**: Layout, copy, images, CTAs

---

# COMMUNITY & SUPPORT

## Getting Help 

### Community Resources
- **RevenueCat Community Forum**: Ask questions, share solutions
- **GitHub Repositories**: Report bugs, request features
- **RevenueCat YouTube Channel**: Video tutorials and walkthroughs
- **RevenueCat Blog**: Latest news, tips, best practices

### Best Practices for Getting Help 
When asking for help, include:
- Platform & SDK version
- Complete error message from logs
- Steps to reproduce
- What you've already tried
- Code snippets (remove sensitive data)
- SDK debug logs
- Dashboard configuration screenshots

**Pro Tip**: Search for your error message first - many issues have already been solved!

---

# API QUICK REFERENCE

## Common RevenueCat Methods

### Initialization
```javascript
// React Native
import Purchases from 'react-native-purchases';

Purchases.configure({ 
  apiKey: 'your_public_api_key' 
});
```

### Customer Info
```javascript
// Get current customer info
const customerInfo = await Purchases.getCustomerInfo();

// Check entitlement
const isPremium = customerInfo.entitlements.active['premium'] !== undefined;

// Get all active entitlements
const activeEntitlements = customerInfo.entitlements.active;
```

### Offerings & Packages
```javascript
// Get offerings
const offerings = await Purchases.getOfferings();
const currentOffering = offerings.current;

// Get packages
const packages = currentOffering?.availablePackages || [];
const monthlyPackage = packages.find(pkg => pkg.identifier === 'monthly');
```

### Purchases
```javascript
// Purchase a package
const { customerInfo } = await Purchases.purchasePackage(package);

// Restore purchases (iOS/Android only)
const customerInfo = await Purchases.restorePurchases();

// Get products directly
const products = await Purchases.getProducts(['product_id']);
const { customerInfo } = await Purchases.purchaseStoreProduct(products[0]);
```

### User Identity
```javascript
// Set user ID (authenticated user)
await Purchases.setAppUserID('user_123');

// Reset to anonymous
await Purchases.resetAppUserID();

// Add listener for real-time updates
const listener = Purchases.addCustomerInfoUpdateListener((info) => {
  // React to subscription changes
});
```

### Logging
```javascript
// Enable debug logging
Purchases.setLogLevel(Purchases.LOG_LEVEL.DEBUG);
```

---

# WEB BILLING

## React Native Web Support

### Getting Started 
1. Create Web Billing app in RevenueCat dashboard
2. Configure web products alongside iOS/Android products
3. Initialize SDK with Web Billing API key for web platform
4. Same entitlement checks work across all platforms

### Supported Platforms
| Platform | Payment Method | Integration |
|----------|----------------|-------------|
| iOS | App Store | Native SDK |
| Android | Google Play | Native SDK |
| Web | Stripe/Paddle | RevenueCat Web Billing |

**Key Benefit**: A user who subscribes on the web immediately gets access on mobile, without custom logic .

---

# GLOSSARY OF TERMS

| Term | Definition | Source |
|------|------------|--------|
| **Product** | Individual purchasable item in app store (e.g., "Monthly Subscription") |  |
| **Entitlement** | Access level users receive (e.g., "premium") |  |
| **Offering** | Group of products displayed to users as a paywall |  |
| **Package** | Equivalent products across platforms bundled under one identifier |  |
| **CustomerInfo** | User's subscription and entitlement data |  |
| **AppUserID** | RevenueCat's user identifier |  |
| **MRR** | Monthly Recurring Revenue |  |
| **ARPU** | Average Revenue Per User |  |
| **LTV** | Lifetime Value |  |
| **Churn Rate** | Percentage of subscribers who cancel |  |

---

# RECOMMENDED READING ORDER

### 1. Complete Beginner
1. [Getting Started Guide](https://www.revenuecat.com/docs/getting-started)
2. [React Native Codelab](https://revenuecat.github.io/codelabs/react-native.html) 
3. [Configuring Products](https://www.revenuecat.com/docs/configuring-products) 

### 2. Intermediate Developer
1. [Error Handling Documentation](https://www.revenuecat.com/docs/error-handling)
2. [Monetization Strategies Codelab](https://revenuecat.github.io/codelab/monetization-strategies/) 
3. [RevenueCat Experiments Guide](https://www.revenuecat.com/docs/experiments)

### 3. Advanced Developer
1. [Webhooks Guide](https://www.revenuecat.com/docs/webhooks)
2. [RevenueCat for Startups](https://www.revenuecat.com/for-startups) 
3. [React Native Web Support Blog](https://www.revenuecat.com/blog/engineering/revenuecat-react-native-sdk-adds-react-native-web-support/) 

---

*This reference guide is designed to accompany the RevenueCat Masterclass series. Bookmark these resources for quick access during development.*
