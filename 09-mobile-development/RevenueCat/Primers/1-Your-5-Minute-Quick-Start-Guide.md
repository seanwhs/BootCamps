# RevenueCat Primer 1: Your 5-Minute Quick Start Guide

## What is RevenueCat?

RevenueCat is the **"Stripe for mobile subscriptions"** – it handles all the complex billing infrastructure so you can focus on building your app instead of wrestling with App Store Connect, Google Play Console, and receipt validation.

Think of it like this:

```
Without RevenueCat:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  iOS App    │────▶│  StoreKit   │────▶│  Receipt    │
│             │     │  (Apple)    │     │ Validation  │
└─────────────┘     └─────────────┘     └─────────────┘
                                                      │
┌─────────────┐     ┌─────────────┐                  ▼
│ Android App │────▶│ Billing Lib │────▶│ Custom     │
│             │     │ (Google)    │     │ Backend    │
└─────────────┘     └─────────────┘     └─────────────┘

With RevenueCat:
┌─────────────┐                      ┌─────────────────┐
│  iOS App    │────▶                 │                 │
│             │     │                 │                 │
└─────────────┘     │  ┌───────────┐ │   RevenueCat    │
                    ├──│  ONE SDK  │─┤   Platform      │
┌─────────────┐     │  └───────────┘ │                 │
│ Android App │────▶                 │                 │
│             │                      │                 │
└─────────────┘                      └─────────────────┘
```

## Core Concepts in 60 Seconds

### Entitlements
**What premium features users unlock** (e.g., "premium_workouts", "nutrition_tracking")

### Offerings
**Groups of packages** you display to users (e.g., "Monthly" + "Annual" options)

### Packages
**The actual products** users buy (e.g., "$9.99/month", "$99.99/year")

### CustomerInfo
**Everything RevenueCat knows about a user** – their active subscriptions, entitlements, and expiration dates

## The 4-Step Setup Process

### Step 1: Create Products in App Stores
You create subscriptions in App Store Connect and Google Play Console first. RevenueCat syncs with them.

### Step 2: Configure RevenueCat
Link your app store products, define entitlements, and create offerings in the RevenueCat dashboard.

### Step 3: Install the SDK
Add `react-native-purchases` to your app.

### Step 4: Initialize and Start Selling
Call `Purchases.configure()` once, then fetch offerings and let users subscribe.

## Implementation Pattern

Here's the pattern you'll use everywhere:

```typescript
// 1. Initialize (once, at app launch)
await Purchases.configure({ apiKey: 'your_key' });

// 2. Get offerings (show on paywall)
const offerings = await Purchases.getOfferings();

// 3. User selects a package
const pkg = offerings.current.availablePackages[0];

// 4. Make purchase
const { customerInfo } = await Purchases.purchasePackage(pkg);

// 5. Check entitlements (gate premium features)
const isPremium = customerInfo.entitlements.active['premium'] !== undefined;
```

## Key Benefits

**✅ One SDK for iOS & Android**
**✅ No receipt validation code**
**✅ Real-time subscription state**
**✅ Remote config (update pricing without app review)**
**✅ Webhooks for your backend**
**✅ Analytics & revenue dashboards**
**✅ A/B testing built in**

## Common Questions

**Q: Do I still need developer accounts?**
A: Yes – Apple ($99/year) and Google ($25 one-time) accounts are still required to list apps.

**Q: How much does RevenueCat cost?**
A: Free for the first $2,500/month in tracked revenue, then 1% of tracked revenue.

**Q: Does it work offline?**
A: Yes – it caches subscription state locally.

**Q: What about user accounts?**
A: RevenueCat supports anonymous users and authenticated users with the same ID system.

## Next Steps

This primer gave you the high-level view. Now dive into:

**[Part 1: Foundations & Architecture Setup](./1-Foundations-&-Architecture-Setup.md)** – Create your RevenueCat account, configure app stores, and initialize the SDK

---

## Quick Reference Cheatsheet

| Concept | Purpose | Example |
|---------|---------|---------|
| **Entitlement** | Feature access | `premium_workouts` |
| **Offering** | Group of packages | `default` |
| **Package** | Purchase option | `monthly` ($9.99) |
| **CustomerInfo** | User's status | Active entitlements |
| **AppUserID** | User identity | `user_123` |

### Common RevenueCat Methods

```typescript
// Initialize
Purchases.configure({ apiKey: 'your_key' });

// Get user status
const info = await Purchases.getCustomerInfo();

// Get pricing
const offerings = await Purchases.getOfferings();

// Buy
await Purchases.purchasePackage(pkg);

// Restore
await Purchases.restorePurchases();

// Set user identity
await Purchases.setAppUserID('user_123');
```

---

**Ready to start building?** Continue to Part 1 for the complete implementation.
