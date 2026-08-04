# RevenueCat Primer 3: Subscription State Management & Access Control

## Your Quick Guide to Managing Subscriptions & Gating Premium Features

In the first two primers, we covered the basics and the paywall. Now let's tackle the most critical part of any subscription app: **knowing who has access to what, and enforcing it everywhere.**

---

## The Core Challenge

Your app needs to answer one question constantly:

> **"Does this user have access to this feature right now?"**

But this simple question has complex requirements:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE ACCESS CHALLENGE                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  "Does this user have access?" requires knowing:                   │
│                                                                     │
│  ✅ Is the user logged in?                                         │
│  ✅ Do they have a valid subscription?                             │
│  ✅ Which entitlement do they have?                                │
│  ✅ Has their subscription expired?                                │
│  ✅ Did they purchase on another device?                           │
│  ✅ Are they offline? (cached state)                               │
│  ✅ Did they just purchase? (real-time update)                    │
│  ✅ Did they cancel? (grace period)                                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Three-Layer Access Control System

### Layer 1: State Management (The Source of Truth)

Your subscription state lives in a central context that all screens can access:

```typescript
// SubscriptionContext.tsx
interface SubscriptionState {
  customerInfo: CustomerInfo | null;
  isSubscribed: boolean;
  activeEntitlements: Record<string, any>;
  isLoading: boolean;
  error: string | null;
  isAnonymous: boolean;
  appUserId: string | null;
}
```

**Key insight:** This is the single source of truth. Everything else reads from here.

### Layer 2: Feature Gating (The Guards)

Components that check access before rendering content:

```tsx
// Component-level gating
<RequireEntitlement entitlementId="premium_workouts">
  <PremiumWorkoutScreen />
</RequireEntitlement>

// UI element gating
<EntitlementGate entitlementId="nutrition_tracking">
  <PremiumBadge />
</EntitlementGate>
```

### Layer 3: Real-time Updates (The Sync)

Listeners that keep state fresh:

```typescript
// Auto-updates when subscription changes
const removeListener = Purchases.addCustomerInfoUpdateListener((info) => {
  updateStateFromCustomerInfo(info);
});
```

---

## The Access Control Flow

### Complete Access Decision Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│              ACCESS DECISION FLOW                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. USER ATTEMPTS TO ACCESS FEATURE                                │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ User taps "Premium Workouts"                        │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  2. CHECK ENTITLEMENT                                             │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ const hasAccess = await hasEntitlement(            │        │
│     │   'premium_workouts'                               │        │
│     │ );                                                │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  3. DECISION                                                      │
│     ┌─────────────────────────────────────────────────────┐        │
│     │              DOES USER HAVE ACCESS?                  │        │
│     │                                                     │        │
│     │     YES                     NO                      │        │
│     │      │                       │                      │        │
│     │      ▼                       ▼                      │        │
│     │ ┌─────────────┐   ┌─────────────────────────┐      │        │
│     │ │ Show        │   │ Show Upgrade Prompt      │      │        │
│     │ │ Content     │   │ "Upgrade to access this  │      │        │
│     │ │             │   │  premium feature"        │      │        │
│     │ └─────────────┘   └─────────────────────────┘      │        │
│     └─────────────────────────────────────────────────────┘        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Key Implementation Patterns

### 1. The Subscription Context Pattern

```typescript
// Provider wraps your app
<SubscriptionProvider>
  <App />
</SubscriptionProvider>

// Any component can check access
const { isSubscribed, hasEntitlement } = useSubscription();

// Check specific entitlement
const hasWorkoutAccess = await hasEntitlement('premium_workouts');
```

### 2. The Feature Guard Pattern

```typescript
// Guard component
<RequireEntitlement 
  entitlementId="premium_workouts"
  onUpgradePress={() => navigateToPaywall()}
>
  <PremiumContent />
</RequireEntitlement>

// The guard handles:
// - Checking entitlement
// - Showing loading state
// - Showing upgrade prompt if no access
// - Rendering children if access granted
```

### 3. The Cached State Pattern

```typescript
// Cache subscription state for offline use
const cacheSubscriptionState = async (customerInfo) => {
  await AsyncStorage.setItem('@subscription_cache', JSON.stringify({
    customerInfo,
    timestamp: Date.now(),
  }));
};

// Load from cache when offline
const loadCachedState = async () => {
  const cached = await AsyncStorage.getItem('@subscription_cache');
  if (cached) {
    const parsed = JSON.parse(cached);
    // Only use if less than 24 hours old
    if (Date.now() - parsed.timestamp < 24 * 60 * 60 * 1000) {
      return parsed.customerInfo;
    }
  }
  return null;
};
```

---

## User Identity Management

### Anonymous vs. Authenticated Users

```
┌─────────────────────────────────────────────────────────────────────┐
│                    USER IDENTITY FLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  APP LAUNCH                                                        │
│  ┌─────────────────────────────────────────────────────┐           │
│  │ Check for stored user ID in AsyncStorage            │           │
│  └─────────────────────────────────────────────────────┘           │
│                          │                                         │
│                          ▼                                         │
│  ┌─────────────────────────────────────────────────────┐           │
│  │                  USER ID FOUND?                     │           │
│  └─────────────────────────────────────────────────────┘           │
│                │                           │                       │
│                ▼                           ▼                       │
│  ┌─────────────────────────┐   ┌─────────────────────────┐       │
│  │ YES: Authenticated User │   │ NO: Anonymous User      │       │
│  │ • Set AppUserID         │   │ • RevenueCat generates  │       │
│  │ • Load subscription     │   │   anonymous ID          │       │
│  │ • Restore purchases     │   │ • Can still purchase    │       │
│  └─────────────────────────┘   └─────────────────────────┘       │
│                │                           │                       │
│                └─────────────┬─────────────┘                       │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────┐           │
│  │ USER LOGS IN / SIGNS UP                             │           │
│  │ • Transfer anonymous subscription to account        │           │
│  │ • Set AppUserID to account ID                       │           │
│  │ • Refresh customer info                             │           │
│  └─────────────────────────────────────────────────────┘           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### The Account Migration Pattern

```typescript
// Critical: Transfer anonymous subscription to user account
const transferAnonymousSubscription = async (userId: string) => {
  // This tells RevenueCat to associate all purchases with this user ID
  await Purchases.setAppUserID(userId);
  
  // Refresh to get updated CustomerInfo
  const customerInfo = await Purchases.getCustomerInfo();
  
  // User now has their subscription on their account
  // They can access it from any device
};
```

---

## Offline Support

### The Challenge

Users need to access premium features even without internet.

### The Solution: Caching

```typescript
// On app launch
const initialize = async () => {
  // 1. Try to load from cache immediately (fast)
  const cached = await loadCachedState();
  if (cached) {
    updateStateFromCustomerInfo(cached);
  }
  
  // 2. Then fetch fresh data (accurate)
  try {
    const fresh = await Purchases.getCustomerInfo();
    updateStateFromCustomerInfo(fresh);
    await cacheSubscriptionState(fresh);
  } catch (error) {
    // If offline, cache is already showing
  }
};
```

---

## Real-time Updates

### The Listener Pattern

```typescript
// Automatic updates when subscription changes
useEffect(() => {
  const removeListener = Purchases.addCustomerInfoUpdateListener((info) => {
    // This fires when:
    // - User purchases
    // - Subscription renews
    // - Subscription expires
    // - User cancels
    // - Any subscription change
    
    updateStateFromCustomerInfo(info);
  });

  return removeListener; // Clean up on unmount
}, []);

// Now any component using `useSubscription()` gets real-time updates
```

---

## Common Patterns by Use Case

### 1. Show Premium Badge

```tsx
<EntitlementGate entitlementId="premium_workouts">
  <Badge text="PREMIUM" variant="gold" />
</EntitlementGate>
```

### 2. Block Entire Screen

```tsx
<RequireEntitlement 
  entitlementId="personal_trainer"
  onUpgradePress={() => navigation.navigate('Paywall')}
>
  <TrainerChatScreen />
</RequireEntitlement>
```

### 3. Conditional Content

```tsx
const { isSubscribed, hasEntitlement } = useSubscription();

return (
  <View>
    <FreeContent />
    {isSubscribed && (
      <PremiumContent />
    )}
    {await hasEntitlement('nutrition_tracking') && (
      <NutritionFeatures />
    )}
  </View>
);
```

### 4. Check Before API Call

```tsx
const fetchPremiumData = async () => {
  const hasAccess = await hasEntitlement('premium_workouts');
  if (!hasAccess) {
    throw new Error('Premium required');
  }
  // Make the API call
};
```

---

## Critical Error States

### What Can Go Wrong?

| Scenario | User Experience | Recovery |
|----------|-----------------|----------|
| No internet | Can't verify subscription | Show cached state, retry button |
| SDK not initialized | No access info | Show loading state, auto-retry |
| Purchase not synced | Entitlements missing | Restore purchases button |
| Expired subscription | Access revoked | Show upgrade prompt |
| Account conflict | Wrong user's subscription | Re-authenticate, restore |

### Handling Network Errors

```typescript
const checkAccess = async () => {
  try {
    const info = await Purchases.getCustomerInfo();
    return info.entitlements.active['premium'] !== undefined;
  } catch (error) {
    // Fall back to cache
    const cached = await loadCachedState();
    if (cached) {
      return cached.entitlements.active['premium'] !== undefined;
    }
    // If no cache, assume no access
    return false;
  }
};
```

---

## Quick Reference: Access Control Methods

| Method | Purpose | When to Use |
|--------|---------|-------------|
| `getCustomerInfo()` | Get full subscription state | App launch, refresh |
| `hasEntitlement()` | Check specific feature | Feature gating |
| `getActiveEntitlements()` | Get all active features | Dashboard, profile |
| `addCustomerInfoUpdateListener()` | Real-time updates | App-wide state |
| `setAppUserID()` | Set user identity | Login/signup |
| `resetAppUserID()` | Reset to anonymous | Logout |

---

## Complete Access Control Pattern

```typescript
// 1. Context provides state
const SubscriptionProvider = ({ children }) => {
  const [state, setState] = useState({ /* ... */ });
  
  // Real-time updates
  useEffect(() => {
    const listener = Purchases.addCustomerInfoUpdateListener((info) => {
      setState(prev => ({ ...prev, customerInfo: info }));
    });
    return () => listener.remove();
  }, []);
  
  // Methods
  const hasEntitlement = (id) => {
    return state.customerInfo?.entitlements.active[id] !== undefined;
  };
  
  return (
    <SubscriptionContext.Provider value={{ ...state, hasEntitlement }}>
      {children}
    </SubscriptionContext.Provider>
  );
};

// 2. Components use the context
const PremiumFeature = () => {
  const { hasEntitlement } = useSubscription();
  const [hasAccess, setHasAccess] = useState(false);
  
  useEffect(() => {
    hasEntitlement('premium_workouts').then(setHasAccess);
  }, []);
  
  return hasAccess ? <Feature /> : <UpgradePrompt />;
};
```

---

## Key Takeaway

> **Access control is not just about checking a flag. It's about:**
> - Knowing the user's state (cached + real-time)
> - Reacting to changes (listeners)
> - Handling edge cases (offline, errors)
> - Providing a seamless experience (upgrade prompts)

Get these right, and your users will never be confused about what they have access to.

---

## Next Steps

Now that you understand subscription state management:

**Continue to Part 4**: [Webhooks, Analytics & Revenue Optimization] – Learn how to process subscription events on your server and track revenue metrics

**Or jump to**: [Part 5: Complete App] – See everything working together in a production app
