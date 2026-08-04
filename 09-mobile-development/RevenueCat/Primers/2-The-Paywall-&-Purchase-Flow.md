# RevenueCat Primer 2: The Paywall & Purchase Flow

## Your Quick Guide to Building a Subscription Paywall

In the first primer, we covered the basics. Now let's dive into the most important screen in your subscription app: **the paywall**.

This is where users decide to give you money – so getting it right matters.

---

## The Paywall: Your App's Revenue Engine

### What Makes a Great Paywall?

A paywall isn't just a price list. It's a **conversion-optimized experience** that:

1. **Communicates Value** – Shows what users get
2. **Presents Options** – Clear pricing tiers
3. **Builds Trust** – Testimonials, guarantees, social proof
4. **Drives Action** – Obvious, easy-to-tap purchase buttons

Think of it like this:

```
Bad Paywall:                    Great Paywall:
┌──────────────────┐           ┌──────────────────────────┐
│ Subscribe        │           │ 💪 Unlock Your Potential │
│                  │           │ "Thousands of users..."  │
│ • $9.99/month    │           │                          │
│ • $99.99/year    │           │ 🏋️ Premium Workouts      │
│                  │           │ 🥗 Nutrition Tracking    │
│ [Subscribe]      │           │ 💬 Personal Trainer      │
└──────────────────┘           │                          │
                               │ ┌──────────┐ ┌─────────┐│
                               │ │ Monthly  │ │ Annual  ││
                               │ │ $9.99/mo │ │ $8.33/mo││
                               │ │          │ │⭐ Save  ││
                               │ └──────────┘ └─────────┘│
                               │                          │
                               │ [Subscribe Monthly]     │
                               │ Restore Purchases       │
                               └──────────────────────────┘
```

---

## The Purchase Flow Anatomy

### Complete Purchase Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPLETE PURCHASE FLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. USER SELECTS PACKAGE                                        │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ User taps "Subscribe Monthly" on paywall           │     │
│     └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│  2. SDK SHOWS STORE SHEET                                       │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ Apple/Google native purchase dialog appears        │     │
│     │ "Confirm Subscription: $9.99/month"                │     │
│     └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│  3. AUTHENTICATION (if needed)                                  │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ User authenticates with Face ID, Touch ID, or      │     │
│     │ Apple/Google account password                       │     │
│     └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│  4. PROCESSING                                                 │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ ⏳ "Processing your purchase..."                    │     │
│     │ (SDK validates receipt with app store)              │     │
│     └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│  5. SUCCESS                                                    │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ 🎉 "Welcome to FitTrack Pro!"                      │     │
│     │ "You now have access to: Premium Workouts"         │     │
│     │ [Get Started]                                      │     │
│     └─────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Implementation Patterns

### 1. The State Machine Pattern

Your paywall should handle all possible states:

```typescript
type PaywallState = 
  | 'idle'          // Ready to purchase
  | 'loading'       // Fetching offerings
  | 'selecting'     // User viewing options
  | 'processing'    // Purchase in progress
  | 'success'       // Purchase complete
  | 'error'         // Something went wrong
  | 'restoring';    // Restoring purchases
```

### 2. The Package Selection Pattern

```typescript
// Fetch offerings
const offerings = await Purchases.getOfferings();

// User selects a package
const selectedPackage = offerings.current.availablePackages.find(
  pkg => pkg.identifier === 'monthly'
);

// Store selection in state
setSelectedPackage(selectedPackage);
```

### 3. The Purchase Pattern with Error Handling

```typescript
const handlePurchase = async () => {
  try {
    setIsPurchasing(true);
    const { customerInfo } = await Purchases.purchasePackage(selectedPackage);
    
    // Check what was granted
    const granted = Object.keys(customerInfo.entitlements.active);
    if (granted.length > 0) {
      // User is now subscribed!
      navigateToMainApp();
    }
  } catch (error) {
    if (error.code === 'PURCHASE_CANCELLED') {
      // User cancelled - no action needed
    } else {
      // Show error message
      showErrorAlert(error);
    }
  } finally {
    setIsPurchasing(false);
  }
};
```

---

## Critical UX Patterns

### Free Trials & Introductory Offers

**Display them prominently:**

```
┌──────────────────────────────────────┐
│ Monthly │  Annual                    │
│ $9.99   │  $99.99                    │
│ /month  │  /year                     │
│         │                            │
│ 7-day   │  💰 Save 20%               │
│ free    │  7-day free trial          │
│ trial   │                            │
│         │  ⭐ Best Value              │
└──────────────────────────────────────┘
```

### Loading States

**Never leave users wondering:**

```typescript
{isPurchasing ? (
  <Button>
    <ActivityIndicator /> Processing...
  </Button>
) : (
  <Button>Subscribe Monthly</Button>
)}
```

### Error Messages

**Be helpful, not scary:**

| Error | User-Friendly Message |
|-------|----------------------|
| Purchase cancelled | "You cancelled the purchase. No charges were made." |
| Network error | "Please check your internet connection and try again." |
| Product unavailable | "This option is currently unavailable. Please try again later." |

---

## Common Mistakes to Avoid

### ❌ Hiding the Price
Users want to know what they're paying. Always show it clearly.

### ❌ Too Many Options
2-3 options is optimal. More choices = decision paralysis.

### ❌ Confusing Language
Use plain English, not marketing jargon.

### ❌ Forgetting Restore
Apple requires a restore button. Users expect it.

### ❌ No Loading States
Users will tap repeatedly, causing duplicate purchases.

---

## Quick Reference: Paywall Checklist

```
✅ Shows clear value proposition
✅ Displays pricing prominently
✅ Highlights best value option
✅ Has obvious purchase buttons
✅ Includes restore purchases
✅ Shows terms and privacy policy
✅ Handles all loading states
✅ Graceful error handling
✅ Works with free trials
✅ Responsive across devices
```

---

## The RevenueCat Purchase Flow Methods

| Method | Purpose | When to Use |
|--------|---------|-------------|
| `purchasePackage()` | Buy a subscription | User taps subscribe |
| `restorePurchases()` | Restore existing purchases | User taps restore |
| `getOfferings()` | Get available packages | Show paywall |
| `getCustomerInfo()` | Check subscription status | App launch, refresh |

### Complete Paywall Component Pattern

```typescript
const PaywallScreen = () => {
  // 1. State
  const [selectedPackage, setSelectedPackage] = useState(null);
  const [isPurchasing, setIsPurchasing] = useState(false);
  const [error, setError] = useState(null);
  
  // 2. Fetch data
  const { offerings, customerInfo } = useRevenueCat();
  
  // 3. Handle purchase
  const handlePurchase = async () => {
    setIsPurchasing(true);
    try {
      const result = await purchasePackage(selectedPackage);
      // Check entitlements
    } catch (error) {
      // Handle error
    } finally {
      setIsPurchasing(false);
    }
  };
  
  // 4. Render
  return (
    <View>
      <ValueProposition />
      <PackageCards 
        packages={offerings.current.availablePackages}
        selected={selectedPackage}
        onSelect={setSelectedPackage}
      />
      <PurchaseButton 
        onPress={handlePurchase}
        loading={isPurchasing}
      />
      <RestoreButton />
      <TermsAndConditions />
    </View>
  );
};
```

---

## Next Steps

Now that you understand the paywall and purchase flow:

**Continue to Part 3**: [Subscription State Management & Access Control] – Learn how to manage subscription state and gate premium features

**Or jump to**: [Part 5: Complete App] – See everything working together

---

## Key Takeaway

> **A well-designed paywall + robust purchase flow = more conversions + happier users**

The technical implementation is straightforward with RevenueCat. The real challenge is designing an experience that communicates value and builds trust.

Get these right, and your subscription business will thrive.
