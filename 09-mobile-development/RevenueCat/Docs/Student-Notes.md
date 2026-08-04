# RevenueCat Masterclass: Student Notes

## Complete Lecture Notes & Key Takeaways

---

# PART 1: FOUNDATIONS & ARCHITECTURE SETUP

## Core Concepts

### RevenueCat's Four Pillars

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE FOUR PILLARS                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  📦 PRODUCT                                                         │
│  └── Individual purchasable item in App Store/Google Play          │
│  └── Example: "Monthly Subscription - $9.99"                      │
│  └── Created in: App Store Connect / Google Play Console          │
│                                                                     │
│  🏷️ ENTITLEMENT                                                    │
│  └── What users unlock when they purchase                          │
│  └── Example: "premium_workouts", "nutrition_tracking"            │
│  └── Created in: RevenueCat Dashboard                             │
│                                                                     │
│  📦 PACKAGE                                                         │
│  └── Wrapper that connects products across platforms               │
│  └── Example: "monthly" maps to iOS + Android products            │
│  └── Created in: RevenueCat Dashboard                             │
│                                                                     │
│  🎯 OFFERING                                                        │
│  └── Group of packages presented to users                          │
│  └── Example: "default" = Monthly + Annual                        │
│  └── Created in: RevenueCat Dashboard                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Takeaway**: Products live in app stores. Entitlements define features. Packages group products. Offerings present options to users.

---

### RevenueCat vs Native IAP

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NATIVE IAP (BEFORE)                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐          │
│  │  iOS App    │────▶│  StoreKit   │────▶│  Receipt    │          │
│  │             │     │  (Apple)    │     │ Validation  │          │
│  └─────────────┘     └─────────────┘     └─────────────┘          │
│                                                                     │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐          │
│  │ Android App │────▶│ Billing Lib │────▶│ Custom      │          │
│  │             │     │ (Google)    │     │ Backend     │          │
│  └─────────────┘     └─────────────┘     └─────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

                    ▼ WITH REVENUECAT ▼

┌─────────────────────────────────────────────────────────────────────┐
│                    REVENUECAT (AFTER)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐                         ┌───────────────┐        │
│  │  iOS App    │────▶                     │               │        │
│  │             │     │  ┌───────────────┐ │  RevenueCat   │        │
│  └─────────────┘     ├──│    ONE SDK   │─┤  Platform     │        │
│                      │  └───────────────┘ │               │        │
│  ┌─────────────┐     │                     │               │        │
│  │ Android App │────▶                     │               │        │
│  │             │                          └───────────────┘        │
│  └─────────────┘                                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Setup Steps

### 1. RevenueCat Account Creation

**Steps**:
1. Go to revenuecat.com → Start Free Trial
2. Create account (Google/GitHub/Email)
3. Click "New Project" → Name it
4. Select platforms (iOS, Android, Web)

**Project Settings**:
- iOS: Bundle ID, Shared Secret
- Android: Package Name, Service Account JSON

### 2. App Store Configuration (iOS)

**Products to Create**:
| Product | Product ID | Price | Duration |
|---------|------------|-------|----------|
| Monthly | com.app.monthly | $9.99 | 1 month |
| Annual | com.app.annual | $99.99 | 1 year |

**Key Steps**:
1. Create app in App Store Connect
2. Create Subscription Group
3. Create subscription products
4. Add introductory offers (free trials)
5. Generate Shared Secret
6. Create Sandbox Testers

### 3. Google Play Configuration (Android)

**Products to Create**:
| Product | Product ID | Price | Duration |
|---------|------------|-------|----------|
| Monthly | com.app.monthly | $9.99 | 1 month |
| Annual | com.app.annual | $99.99 | 1 year |

**Key Steps**:
1. Create app in Google Play Console
2. Create subscription products
3. Configure base plans
4. Create Service Account for RevenueCat
5. Download JSON key file

### 4. RevenueCat Dashboard Configuration

**Entitlements**:
| Entitlement ID | Display Name | Description |
|----------------|--------------|-------------|
| premium_workouts | Premium Workouts | Access to all workout types |
| nutrition_tracking | Nutrition Tracking | Full meal logging |
| personal_trainer | Personal Trainer | Chat with trainers |

**Offerings**:
| Offering ID | Display Name | Packages |
|-------------|--------------|----------|
| default | Default Offering | Monthly, Annual |

### 5. SDK Installation

```bash
# Install RevenueCat SDK
npm install react-native-purchases
npm install @react-native-async-storage/async-storage

# iOS: Install pods
cd ios && pod install && cd ..

# Start the project
npx react-native start
```

---

# PART 2: PAYWALL & PURCHASE FLOW

## Paywall Design Principles

### The Three Essential Elements

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PAYWALL ESSENTIALS                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. VALUE PROPOSITION                                               │
│     └── What do users get? (Clear, benefits-focused)              │
│     └── Example: "Unlock 500+ premium workouts"                   │
│                                                                     │
│  2. PRICING OPTIONS                                                 │
│     └── Show clear comparison between tiers                        │
│     └── Annual vs Monthly side-by-side                            │
│     └── Highlight "Best Value"                                     │
│                                                                     │
│  3. CLEAR CALL-TO-ACTION                                            │
│     └── Action-oriented button text                                │
│     └── Obvious and easy to tap                                    │
│     └── Example: "Subscribe Monthly" vs "Subscribe"               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Price Anchoring

**Concept**: Making the annual plan appear more valuable by showing it alongside the monthly plan.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PRICE ANCHORING EXAMPLE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐   │
│  │    MONTHLY           │  │    ANNUAL ⭐ BEST VALUE          │   │
│  │    $9.99             │  │    $99.99                       │   │
│  │    /month            │  │    $8.33/month                 │   │
│  │                      │  │                                  │   │
│  │    Flexible          │  │    SAVE 20%                    │   │
│  │    Cancel anytime    │  │    Cancel anytime              │   │
│  │                      │  │    7-day free trial            │   │
│  └──────────────────────┘  └──────────────────────────────────┘   │
│                                                                     │
│  The annual plan is "anchored" to the monthly price, making it    │
│  seem like a better deal.                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Paywall Placement Strategies

| Strategy | Timing | Best For | Conversion Rate |
|----------|--------|----------|-----------------|
| **Onboarding** | Immediately after signup | High-intent users | Highest |
| **Contextual** | When users hit premium features | Users who've demonstrated interest | Medium |
| **Settings** | Accessible from app settings | Users who weren't ready initially | Lowest |

**Key Insight**: 82% of trial starts happen on the same day a user installs an app.

---

## Purchase Flow

### Complete Purchase Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PURCHASE FLOW STATES                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. IDLE                                                            │
│     └── User sees paywall, ready to select package                 │
│                                                                     │
│  2. SELECTING                                                       │
│     └── User chooses Monthly or Annual                             │
│                                                                     │
│  3. PROCESSING                                                      │
│     └── Purchase in progress, show loading state                   │
│     └── ⏳ "Processing your purchase..."                          │
│                                                                     │
│  4. SUCCESS                                                         │
│     └── Purchase complete, entitlements granted                    │
│     └── 🎉 "Welcome to FitTrack Pro!"                             │
│                                                                     │
│  5. ERROR                                                           │
│     └── Purchase failed, show helpful message                      │
│     └── 😕 "You cancelled the purchase."                          │
│                                                                     │
│  6. RESTORING                                                       │
│     └── User restoring previous purchases                          │
│     └── 📦 "Restoring purchases..."                               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Purchase Code Pattern

```typescript
const handlePurchase = async () => {
  // 1. Set loading state
  setIsPurchasing(true);
  setError(null);
  
  try {
    // 2. Make the purchase
    const { customerInfo } = await Purchases.purchasePackage(selectedPackage);
    
    // 3. Check entitlements
    const granted = Object.keys(customerInfo.entitlements.active);
    
    if (granted.length > 0) {
      // 4. Success - update UI
      setPurchaseFlowState('success');
      // Navigation will automatically transition
    }
  } catch (error) {
    // 5. Handle errors
    if (error.code === 'PURCHASE_CANCELLED') {
      // User cancelled - no action needed
      setPurchaseFlowState('idle');
    } else {
      // Show user-friendly error
      setPurchaseFlowState('error');
      setFlowErrorMessage(error.userMessage);
    }
  } finally {
    // 6. Reset loading state
    setIsPurchasing(false);
  }
};
```

### Error Handling Map

| RevenueCat Error Code | User-Friendly Message | Recovery Action |
|----------------------|----------------------|-----------------|
| `PURCHASE_CANCELLED` | "You cancelled the purchase. No charges were made." | Try again |
| `NETWORK_ERROR` | "Please check your internet connection and try again." | Retry |
| `PRODUCT_NOT_AVAILABLE` | "This option is currently unavailable. Please try again later." | Try later |
| `PURCHASE_NOT_ALLOWED` | "In-app purchases are not allowed on this device." | Check settings |
| `INVALID_CREDENTIALS` | "There was a problem with your account. Please contact support." | Contact support |
| `UNKNOWN` | "Something went wrong. Please try again." | Try again |

---

## Design Best Practices

### ✅ DO's

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PAYWALL DO'S                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ✅ Show clear value proposition                                   │
│  ✅ Display prices prominently                                     │
│  ✅ Highlight the best value option                                │
│  ✅ Use clear, action-oriented buttons                             │
│  ✅ Include "Restore Purchases"                                    │
│  ✅ Show terms and privacy policy                                  │
│  ✅ Handle all loading states                                     │
│  ✅ Graceful error handling                                       │
│  ✅ Show free trial information clearly                           │
│  ✅ Make it responsive across devices                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### ❌ DON'Ts

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PAYWALL DON'TS                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ❌ Hide the price from users                                      │
│  ❌ Show too many options (max 3)                                  │
│  ❌ Use confusing language or jargon                               │
│  ❌ Forget to include "Restore Purchases"                         │
│  ❌ Skip loading states                                            │
│  ❌ Show technical error messages to users                         │
│  ❌ Hide auto-renewal information                                  │
│  ❌ Make it hard to find the cancellation option                   │
│  ❌ Forget to include Privacy Policy and Terms of Service          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

# PART 3: SUBSCRIPTION STATE MANAGEMENT & ACCESS CONTROL

## The Three-Layer Access System

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THREE LAYERS OF ACCESS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  LAYER 1: STATE MANAGEMENT                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ SubscriptionContext - Single source of truth                │   │
│  │ • CustomerInfo                                              │   │
│  │ • Active entitlements                                       │   │
│  │ • Loading states                                            │   │
│  │ • User identity                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  LAYER 2: FEATURE GATING                                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Guard Components - Protect content                          │   │
│  │ • RequireEntitlement (screen-level)                         │   │
│  │ • EntitlementGate (component-level)                         │   │
│  │ • Conditional UI rendering                                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  LAYER 3: REAL-TIME UPDATES                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Listeners - Keep state fresh                                │   │
│  │ • CustomerInfo update listener                              │   │
│  │ • Automatic state refresh                                   │   │
│  │ • Background sync                                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Subscription Context

### State Structure

```typescript
interface SubscriptionState {
  customerInfo: CustomerInfo | null;        // Full RevenueCat data
  isSubscribed: boolean;                    // Has any active entitlement
  activeEntitlements: Record<string, any>;  // Map of active entitlements
  isLoading: boolean;                       // Loading state
  error: string | null;                     // Error message
  isAnonymous: boolean;                     // Anonymous user?
  appUserId: string | null;                 // User ID
}
```

### Key Methods

```typescript
interface SubscriptionContextValue extends SubscriptionState {
  // User identity
  setUserId: (userId: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  
  // Subscription management
  refreshSubscription: () => Promise<void>;
  hasEntitlement: (entitlementId: string) => Promise<boolean>;
  
  // Purchase methods
  purchasePackage: (pkg: Package) => Promise<any>;
  restorePurchases: () => Promise<CustomerInfo>;
}
```

### Real-time Updates

```typescript
useEffect(() => {
  // Add listener for CustomerInfo changes
  const removeListener = revenueCatService.addCustomerInfoListener((info) => {
    console.log('CustomerInfo updated');
    updateStateFromCustomerInfo(info);
  });
  
  // Clean up listener on unmount
  return () => {
    removeListener();
  };
}, []);
```

---

## Feature Guard Components

### RequireEntitlement (Screen-Level)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REQUIRE ENTITLEMENT FLOW                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Component Mounts                                               │
│     └── Check if user has entitlement                             │
│                                                                     │
│  2. Loading State                                                  │
│     └── Show spinner while checking                                │
│                                                                     │
│  3. Decision                                                       │
│     ┌─────────────────────────────────────────────────────┐        │
│     │              HAS ENTITLEMENT?                       │        │
│     └─────────────────────────────────────────────────────┘        │
│                │                           │                       │
│                ▼ YES                       ▼ NO                    │
│  ┌─────────────────────────┐   ┌─────────────────────────┐        │
│  │ Show Protected Content  │   │ Show Upgrade Prompt     │        │
│  │                         │   │ • Explain feature       │        │
│  │ [Children]              │   │ • "Upgrade to access"   │        │
│  │                         │   │ • Navigate to paywall   │        │
│  └─────────────────────────┘   └─────────────────────────┘        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### EntitlementGate (Component-Level)

```tsx
<EntitlementGate entitlementId="nutrition_tracking">
  <PremiumBadge />
</EntitlementGate>
```

**Use Cases**:
- Show/hide UI elements
- Conditional rendering
- Feature flags
- Premium badges/indicators

---

## User Identity & Account Migration

### Identity Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    IDENTITY FLOW                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  APP LAUNCH                                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Check for stored user ID                                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                │                           │                       │
│                ▼ NO                       ▼ YES                    │
│  ┌─────────────────────────┐   ┌─────────────────────────────┐   │
│  │ ANONYMOUS USER          │   │ AUTHENTICATED USER          │   │
│  │ • RevenueCat generates  │   │ • Set AppUserID to          │   │
│  │   anonymous ID          │   │   stored ID                 │   │
│  │ • Can still purchase    │   │ • Load subscription         │   │
│  │ • Subscription is       │   │ • Restore purchases         │   │
│  │   device-bound          │   │ • Access on all devices     │   │
│  └─────────────────────────┘   └─────────────────────────────┘   │
│                │                                                 │
│                ▼                                                 │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ USER LOGS IN                                                │   │
│  │ • Transfer anonymous subscription to account               │   │
│  │ • Set AppUserID to account ID                              │   │
│  │ • Refresh customer info                                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Account Migration Code

```typescript
// Transfer anonymous subscription to user account
const transferSubscription = async (userId: string) => {
  // 1. Set the user ID (transfers all purchases)
  await Purchases.setAppUserID(userId);
  
  // 2. Get fresh CustomerInfo
  const customerInfo = await Purchases.getCustomerInfo();
  
  // 3. Verify transfer
  const granted = Object.keys(customerInfo.entitlements.active);
  if (granted.length > 0) {
    console.log('Subscription transferred successfully!');
  }
};
```

---

## Offline Support

### Caching Strategy

```
┌─────────────────────────────────────────────────────────────────────┐
│                    OFFLINE STRATEGY                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. ON APP LAUNCH                                                   │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ Load cached state from AsyncStorage (fast)              │   │
│     │ Show cached data immediately                            │   │
│     └─────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  2. IN BACKGROUND                                                  │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ Fetch fresh data from RevenueCat (accurate)            │   │
│     │ Update cache with fresh data                           │   │
│     │ Update UI if different                                 │   │
│     └─────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  3. CACHE MANAGEMENT                                               │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ Cache expires after 24 hours                           │   │
│     │ Refresh on purchase/restore                            │   │
│     │ Clear on logout                                        │   │
│     └─────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Cache Implementation

```typescript
// Save to cache
const cacheSubscriptionState = async (customerInfo: CustomerInfo) => {
  await AsyncStorage.setItem('@subscription_cache', JSON.stringify({
    customerInfo,
    timestamp: Date.now(),
  }));
};

// Load from cache
const loadCachedState = async () => {
  const cached = await AsyncStorage.getItem('@subscription_cache');
  if (!cached) return null;
  
  const parsed = JSON.parse(cached);
  const isRecent = Date.now() - parsed.timestamp < 24 * 60 * 60 * 1000;
  
  return isRecent ? parsed.customerInfo : null;
};
```

---

# PART 4: WEBHOOKS, ANALYTICS & REVENUE OPTIMIZATION

## Webhooks

### Why Webhooks Matter

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHY WEBHOOKS MATTER                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  App Store Events:            Why Your Backend Needs to Know:      │
│                                                                     │
│  🎉 User subscribes           → Send welcome email                 │
│  🔄 Subscription renews       → Update user's premium status       │
│  ❌ User cancels              → Prepare win-back campaign          │
│  ⏰ Subscription expires      → Revoke premium access              │
│  💰 Refund issued             → Revoke access, track losses        │
│  💳 Billing issue             → Send payment reminder              │
│  ⏳ Grace period starts       → Send warning notification          │
│  🔄 Product changed           → Update subscription tier           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Webhook Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WEBHOOK FLOW                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. EVENT OCCURS                                                    │
│     └── User subscribes, renews, cancels, etc.                    │
│                                                                     │
│  2. REVENUECAT SENDS WEBHOOK                                        │
│     └── POST to your server with event data                       │
│                                                                     │
│  3. YOUR SERVER VERIFIES                                            │
│     └── Check signature → Validate event data                     │
│                                                                     │
│  4. YOUR SERVER PROCESSES                                           │
│     ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│     │ Database    │  │ Analytics   │  │ Email       │             │
│     │ Update      │  │ Track Event │  │ Send        │             │
│     └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                     │
│  5. RESPONSE                                                        │
│     └── 200 OK (RevenueCat stops retrying)                        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Webhook Implementation

```typescript
app.post('/webhook/revenuecat', async (req, res) => {
  try {
    // 1. Verify signature
    const isValid = verifyWebhookSignature(req.body, req.headers);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid signature' });
    }
    
    // 2. Process based on event type
    const event = req.body;
    switch (event.type) {
      case 'INITIAL_PURCHASE':
        await handleNewSubscription(event);
        break;
      case 'RENEWAL':
        await handleRenewal(event);
        break;
      case 'CANCELLATION':
        await handleCancellation(event);
        break;
      case 'EXPIRATION':
        await handleExpiration(event);
        break;
      case 'REFUND':
        await handleRefund(event);
        break;
      case 'BILLING_ISSUE':
        await handleBillingIssue(event);
        break;
    }
    
    // 3. Always return 200
    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Webhook error:', error);
    // Always return 200 to prevent retries
    res.status(200).json({ received: true, error: 'Handled internally' });
  }
});
```

### Event Types

| Event | Description | Action |
|-------|-------------|--------|
| `INITIAL_PURCHASE` | First purchase | Welcome email, grant access |
| `RENEWAL` | Successful renewal | Update expiration date |
| `CANCELLATION` | User cancelled | Update status, prepare win-back |
| `EXPIRATION` | Subscription ended | Revoke access, win-back campaign |
| `REFUND` | Refund processed | Revoke access, track loss |
| `BILLING_ISSUE` | Payment failed | Send payment reminder |
| `GRACE_PERIOD` | Grace period started | Notify user, extend access |

---

## Analytics

### Key Revenue Metrics

| Metric | Definition | Formula | Why It Matters |
|--------|------------|---------|----------------|
| **MRR** | Monthly Recurring Revenue | Sum of all monthly subscription payments | Predictable revenue baseline |
| **ARPU** | Average Revenue Per User | MRR / Total Active Users | User value, growth potential |
| **LTV** | Lifetime Value | ARPU × Average Customer Lifetime | How much can you spend to acquire users? |
| **Churn Rate** | % of subscribers who cancel | Cancelled / Total Subscribers × 100 | Health of your business |
| **Conversion Rate** | % of free users who subscribe | New Subscribers / Free Users × 100 | Paywall effectiveness |
| **Trial Conversion** | % of trials that convert | Converted Trials / Total Trials × 100 | Product-market fit |

### Analytics Events to Track

```typescript
const eventsToTrack = {
  // Subscription events
  'subscription_purchase': { userId, productId, price },
  'subscription_renewal': { userId, productId },
  'subscription_cancelled': { userId, reason },
  'subscription_expired': { userId },
  'subscription_refunded': { userId, amount },
  
  // User events
  'user_signup': { userId, source },
  'user_login': { userId },
  'user_logout': { userId },
  
  // Paywall events
  'paywall_viewed': { userId, source },
  'paywall_closed': { userId },
  'paywall_conversion': { userId, productId },
  
  // Feature events
  'premium_feature_used': { userId, feature },
  'upgrade_prompt_shown': { userId, feature },
};
```

---

## Churn Reduction Strategies

### Churn Prevention Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CHURN PREVENTION PIPELINE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. BILLING ISSUE DETECTED                                         │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ User's payment fails                                    │   │
│     └─────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  2. GRACE PERIOD STARTS (3-7 days)                                 │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ User keeps access while we try to fix payment           │   │
│     └─────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  3. NOTIFICATIONS SENT                                            │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ • Day 1: "Payment failed, update your card"            │   │
│     │ • Day 3: "Your access expires in 2 days"               │   │
│     │ • Day 5: "Last chance to update payment"               │   │
│     └─────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  4. SUBSCRIPTION EXPIRES                                           │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ User loses access                                       │   │
│     └─────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  5. WIN-BACK CAMPAIGN STARTS                                      │
│     ┌─────────────────────────────────────────────────────────┐   │
│     │ • Day 7: "We miss you! Come back"                      │   │
│     │ • Day 14: "30% off your first month"                   │   │
│     │ • Day 30: "Your workout data is waiting"               │   │
│     └─────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Win-Back Campaign Timing

| Days After Expiration | Offer | Message |
|----------------------|-------|---------|
| 7 days | 30% off | "We miss you! Come back and continue your fitness journey." |
| 14 days | 50% off | "Special offer just for you! Don't let your progress go to waste." |
| 30 days | First month free | "Your workout data is still here. Come back and start where you left off!" |

---

## RevenueCat Experiments (A/B Testing)

### What to Test

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHAT TO TEST                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  💰 PRICING                                                         │
│     └── $9.99 vs $12.99/month                                     │
│     └── $99.99 vs $119.99/year                                   │
│                                                                     │
│  📝 MESSAGING                                                       │
│     └── "Save 20%" vs "Unlock All Features"                       │
│     └── "7-day free trial" vs "Free trial"                        │
│                                                                     │
│  🎨 LAYOUT                                                          │
│     └── 2 cards vs 3 cards                                        │
│     └── Order of plans (monthly first vs annual first)            │
│                                                                     │
│  ⏰ OFFER LENGTH                                                    │
│     └── 7-day vs 14-day trial                                     │
│     └── 1-month vs 3-month trial                                  │
│                                                                     │
│  📍 PLACEMENT                                                       │
│     └── Onboarding vs Contextual vs Settings                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Insight**: Price anchoring (showing monthly + annual side-by-side) increased annual subscriptions by 31%.

---

# PART 5: FULL APP INTEGRATION

## Navigation Flow

### Complete User Journey

```
┌─────────────────────────────────────────────────────────────────────┐
│                    USER JOURNEY MAP                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  APP LAUNCH                                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ SPLASH SCREEN                                               │   │
│  │ • Check authentication status                               │   │
│  │ • Check subscription status                                 │   │
│  │ • Initialize RevenueCat                                     │   │
│  │ • Load cached state                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                          │                                         │
│                          ▼                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ IS USER AUTHENTICATED?                                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                │                           │                       │
│                ▼ NO                       ▼ YES                    │
│  ┌─────────────────────────┐   ┌─────────────────────────────┐   │
│  │ LOGIN SCREEN            │   │ IS USER SUBSCRIBED?          │   │
│  │ • Sign in / Sign up     │   └─────────────────────────────┘   │
│  │ • Continue as guest     │                │           │       │
│  └─────────────────────────┘                ▼ NO       ▼ YES    │
│                │                     ┌─────────────┐   ┌─────────┐│
│                ▼                     │ PAYWALL     │   │ MAIN    ││
│  ┌─────────────────────────┐        │ SCREEN      │   │ APP     ││
│  │ TRANSFER SUBSCRIPTION?  │        └─────────────┘   └─────────┘│
│  │ (if purchased anonymous)│                                    │
│  └─────────────────────────┘                                    │
│                │                                                │
│                ▼                                                │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ SUBSCRIPTION TRANSFERRED → Continue to Main App            ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Complete Screen Structure

### Screen Checklist

| Screen | Purpose | RevenueCat Integration |
|--------|---------|----------------------|
| **Splash** | Initialize, check state | `Purchases.configure()` |
| **Login** | Auth, account migration | `setAppUserID()` |
| **Paywall** | Show offerings, purchase | `getOfferings()`, `purchasePackage()` |
| **Home** | Dashboard, feature access | `getCustomerInfo()` |
| **Workouts** | Gated content | `hasEntitlement()` |
| **Nutrition** | Gated content | `hasEntitlement()` |
| **Trainer** | Premium feature | `RequireEntitlement` |
| **Profile** | Subscription management | `customerInfo`, `managementURL` |
| **Subscription Status** | Detailed view | All customer info |

---

## App Entry Point Structure

```typescript
// App.tsx

const App = () => {
  return (
    <SubscriptionProvider>
      <SafeAreaView style={{ flex: 1 }}>
        <StatusBar barStyle="dark-content" />
        <RootNavigator />
      </SafeAreaView>
    </SubscriptionProvider>
  );
};

export default App;
```

---

## Production Readiness Checklist

### Pre-Launch Verification

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LAUNCH CHECKLIST                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  📱 APP LAUNCH                                                      │
│  ✅ Splash screen shows                                            │
│  ✅ RevenueCat initializes                                         │
│  ✅ Cached state loads                                             │
│                                                                     │
│  🔐 AUTHENTICATION                                                  │
│  ✅ Login works                                                    │
│  ✅ Signup works                                                   │
│  ✅ Anonymous mode works                                           │
│  ✅ Account migration works                                        │
│                                                                     │
│  💰 PAYWALL                                                         │
│  ✅ Offerings load                                                 │
│  ✅ Packages display correctly                                    │
│  ✅ Purchase flow works                                           │
│  ✅ Restore works                                                 │
│  ✅ Error handling works                                          │
│                                                                     │
│  🎯 FEATURE GATING                                                  │
│  ✅ Premium features locked for free users                        │
│  ✅ Premium features unlock after purchase                        │
│  ✅ Real-time updates work                                        │
│  ✅ Offline mode works                                            │
│                                                                     │
│  🔌 BACKEND                                                         │
│  ✅ Webhooks configured                                            │
│  ✅ All event types handled                                        │
│  ✅ Analytics events tracked                                       │
│  ✅ Email notifications set up                                     │
│                                                                     │
│  📊 MONITORING                                                      │
│  ✅ Revenue alerts                                                 │
│  ✅ Technical alerts                                               │
│  ✅ Performance monitoring                                         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Key Takeaways Summary

### Part 1: Foundations
- Products in app stores → Packages in RevenueCat → Offerings to users
- Set up app stores FIRST, then RevenueCat, then SDK
- Four pillars: Products, Packages, Offerings, Entitlements

### Part 2: Paywall
- Paywall = value proposition + pricing options + clear CTA
- Handle all purchase states: idle, processing, success, error
- Price anchoring works: show monthly + annual together
- Always include restore purchases

### Part 3: State Management
- Three layers: State + Guards + Real-time updates
- Account migration is critical for cross-device access
- Cache state for offline support (24 hours expiry)
- React Context provides global source of truth

### Part 4: Backend
- Webhooks keep your server in sync with subscriptions
- Always verify signatures and return 200 OK
- Track MRR, ARPU, LTV, churn, and conversion
- Churn reduction is systematic (grace periods + win-back)
- A/B test pricing, messaging, and layout

### Part 5: Full App
- Navigation decisions driven by auth + subscription state
- Gate premium features at screen, component, and API levels
- Complete production checklist before launch
- Test with sandbox accounts before going live

---

# QUICK REFERENCE CARDS

## RevenueCat Methods

```typescript
// Initialize
Purchases.configure({ apiKey: 'your_key' });

// Get offerings
const offerings = await Purchases.getOfferings();

// Get customer info
const info = await Purchases.getCustomerInfo();

// Purchase
const { customerInfo } = await Purchases.purchasePackage(pkg);

// Restore
const info = await Purchases.restorePurchases();

// Set user ID
await Purchases.setAppUserID('user_123');

// Reset to anonymous
await Purchases.resetAppUserID();

// Add listener
const listener = Purchases.addCustomerInfoUpdateListener((info) => {
  // React to changes
});
```

## Error Codes

| Code | Message |
|------|---------|
| `PURCHASE_CANCELLED` | You cancelled the purchase. |
| `NETWORK_ERROR` | Check your internet connection. |
| `PRODUCT_NOT_AVAILABLE` | Product is currently unavailable. |
| `PURCHASE_NOT_ALLOWED` | Purchases not allowed on this device. |
| `INVALID_CREDENTIALS` | Account configuration issue. |

## Entitlement Checks

```tsx
// Screen-level guard
<RequireEntitlement entitlementId="premium_workouts">
  <PremiumContent />
</RequireEntitlement>

// Component-level guard
<EntitlementGate entitlementId="nutrition_tracking">
  <PremiumBadge />
</EntitlementGate>

// Conditional check
const { hasEntitlement } = useSubscription();
if (await hasEntitlement('personal_trainer')) {
  // Show trainer features
}
```

---

# NOTES SPACE

```
┌─────────────────────────────────────────────────────────────────────┐
│                    YOUR NOTES                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```
