# RevenueCat Primer 5: Full React Native App Integration

## Your Complete Guide to Building a Production Subscription App

In the first four primers, we covered the foundations, paywall, state management, and backend. Now let's bring it all together into a complete, production-ready React Native application.

---

## The Complete Architecture

### What a Production App Looks Like

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PRODUCTION APP ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    REACT NATIVE APP                              │   │
│  ├─────────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │   │
│  │  │ Splash      │  │ Login       │  │ Paywall     │            │   │
│  │  │ Screen      │──│ Screen      │──│ Screen      │            │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘            │   │
│  │         │                │                │                    │   │
│  │         ▼                ▼                ▼                    │   │
│  │  ┌─────────────────────────────────────────────────────────┐   │   │
│  │  │                    MAIN APP                              │   │   │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │   │   │
│  │  │  │ Home    │  │Workouts │  │Nutrition│  │ Profile │  │   │   │
│  │  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  │   │   │
│  │  └─────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                   │
│                                    ▼                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    SHARED LAYERS                                │   │
│  ├─────────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐  │   │
│  │  │ Subscription    │  │ Feature         │  │ Navigation    │  │   │
│  │  │ Context         │  │ Guards          │  │ System        │  │   │
│  │  └─────────────────┘  └─────────────────┘  └───────────────┘  │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐  │   │
│  │  │ RevenueCat      │  │ Auth            │  │ Theme/Design  │  │   │
│  │  │ Service         │  │ Service         │  │ System        │  │   │
│  │  └─────────────────┘  └─────────────────┘  └───────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                   │
│                                    ▼                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    BACKEND INFRASTRUCTURE                       │   │
│  ├─────────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐  │   │
│  │  │ Webhook         │  │ Database        │  │ Analytics     │  │   │
│  │  │ Handler         │  │ Service         │  │ Service       │  │   │
│  │  └─────────────────┘  └─────────────────┘  └───────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                   │
│                                    ▼                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    REVENUECAT PLATFORM                          │   │
│  ├─────────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐  │   │
│  │  │ Entitlements    │  │ Offerings       │  │ Webhooks      │  │   │
│  │  └─────────────────┘  └─────────────────┘  └───────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## The Navigation Flow

### Complete User Journey

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    USER JOURNEY MAP                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  APP LAUNCH                                                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                          SPLASH SCREEN                          │   │
│  │                                                                 │   │
│  │  ┌─────────────────────────────────────────────────────────┐   │   │
│  │  │  1. Check authentication status                         │   │   │
│  │  │  2. Check subscription status                           │   │   │
│  │  │  3. Initialize RevenueCat                               │   │   │
│  │  │  4. Load cached state                                   │   │   │
│  │  └─────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                   │
│                                    ▼                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    IS USER AUTHENTICATED?                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                │                           │                           │
│                ▼ NO                        ▼ YES                       │
│  ┌─────────────────────────┐   ┌─────────────────────────────────┐   │
│  │     LOGIN SCREEN        │   │      IS USER SUBSCRIBED?        │   │
│  │                         │   └─────────────────────────────────┘   │
│  │  • Sign in with email   │                │               │        │
│  │  • Sign up new account  │                ▼ NO            ▼ YES    │
│  │  • Continue as guest    │   ┌─────────────────┐   ┌───────────┐  │
│  └─────────────────────────┘   │    PAYWALL      │   │  MAIN APP │  │
│                │               │    SCREEN       │   │           │  │
│                ▼               │                 │   │  • Home   │  │
│  ┌─────────────────────────┐   │  • View plans   │   │  • Workouts│  │
│  │ TRANSFER SUBSCRIPTION?  │   │  • Subscribe    │   │  • Nutrition│  │
│  │ (if purchased anonymous)│   │  • Restore      │   │  • Trainer │  │
│  └─────────────────────────┘   └─────────────────┘   │  • Profile │  │
│                │                                       └───────────┘  │
│                ▼                                        │             │
│  ┌─────────────────────────┐                           │             │
│  │ SUBSCRIPTION TRANSFERRED│                           │             │
│  │ • Subscription moved to │                           │             │
│  │   user account          │                           │             │
│  └─────────────────────────┘                           │             │
│                │                                       │             │
│                └───────────────────────────────────────┘             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Key Components in Detail

### 1. Root Navigator

The entry point that decides which screen to show:

```typescript
// RootNavigator.tsx
export const RootNavigator = () => {
  const { isSubscribed, isLoading, isAuthenticated } = useSubscription();
  
  if (isLoading) {
    return <SplashScreen />;
  }
  
  if (!isAuthenticated) {
    return <LoginScreen />;
  }
  
  if (!isSubscribed) {
    return <PaywallScreen />;
  }
  
  return <MainNavigator />;
};
```

### 2. Subscription Context

The central state manager:

```typescript
// SubscriptionContext.tsx
export const SubscriptionProvider = ({ children }) => {
  const [state, setState] = useState({
    customerInfo: null,
    isSubscribed: false,
    activeEntitlements: {},
    isLoading: true,
  });
  
  // Initialize on mount
  useEffect(() => {
    initializeSubscription();
  }, []);
  
  // Real-time updates
  useEffect(() => {
    const listener = Purchases.addCustomerInfoUpdateListener((info) => {
      updateStateFromCustomerInfo(info);
    });
    return () => listener.remove();
  }, []);
  
  // Methods
  const value = {
    ...state,
    hasEntitlement: (id) => state.activeEntitlements[id] !== undefined,
    purchasePackage: async (pkg) => { /* ... */ },
    restorePurchases: async () => { /* ... */ },
    // ... etc
  };
  
  return (
    <SubscriptionContext.Provider value={value}>
      {children}
    </SubscriptionContext.Provider>
  );
};
```

### 3. Feature Guards

Components that gate premium features:

```tsx
// RequireEntitlement.tsx
export const RequireEntitlement = ({ 
  entitlementId, 
  children,
  onUpgradePress 
}) => {
  const { hasEntitlement, isLoading } = useSubscription();
  const [hasAccess, setHasAccess] = useState(false);
  
  useEffect(() => {
    hasEntitlement(entitlementId).then(setHasAccess);
  }, [entitlementId]);
  
  if (isLoading) {
    return <LoadingSpinner />;
  }
  
  if (!hasAccess) {
    return (
      <UpgradePrompt 
        entitlementId={entitlementId}
        onUpgradePress={onUpgradePress}
      />
    );
  }
  
  return children;
};
```

### 4. Paywall Screen

The revenue engine:

```tsx
// PaywallScreen.tsx
export const PaywallScreen = () => {
  const { offerings, purchasePackage, restorePurchases } = useSubscription();
  const [selectedPackage, setSelectedPackage] = useState(null);
  const [isPurchasing, setIsPurchasing] = useState(false);
  
  const handlePurchase = async () => {
    setIsPurchasing(true);
    try {
      await purchasePackage(selectedPackage);
      // Navigation will automatically handle the transition
    } catch (error) {
      // Handle error
    } finally {
      setIsPurchasing(false);
    }
  };
  
  return (
    <View style={styles.container}>
      <ValueProposition />
      <PackageCards 
        packages={offerings?.current?.availablePackages}
        selected={selectedPackage}
        onSelect={setSelectedPackage}
      />
      <PurchaseButton 
        loading={isPurchasing}
        onPress={handlePurchase}
      />
      <RestoreButton onPress={restorePurchases} />
    </View>
  );
};
```

---

## Premium Feature Gating Examples

### 1. Screen-Level Gating

```tsx
// WorkoutsScreen.tsx
<RequireEntitlement 
  entitlementId="premium_workouts"
  onUpgradePress={() => navigation.navigate('Paywall')}
>
  <PremiumWorkoutScreen />
</RequireEntitlement>
```

### 2. Component-Level Gating

```tsx
// HomeScreen.tsx
<EntitlementGate entitlementId="nutrition_tracking">
  <NutritionCard />
</EntitlementGate>
```

### 3. Conditional UI Elements

```tsx
// FeatureCard.tsx
const { hasEntitlement } = useSubscription();
const [hasFeature, setHasFeature] = useState(false);

useEffect(() => {
  hasEntitlement('personal_trainer').then(setHasFeature);
}, []);

return (
  <Card>
    <Card.Header>Personal Trainer</Card.Header>
    {hasFeature ? (
      <ChatInterface />
    ) : (
      <UpgradeButton onPress={() => navigation.navigate('Paywall')} />
    )}
  </Card>
);
```

### 4. API Call Protection

```tsx
// api.ts
const fetchPremiumData = async (userId: string) => {
  const hasAccess = await revenueCatService.hasEntitlement(
    userId, 
    'premium_workouts'
  );
  
  if (!hasAccess) {
    throw new Error('Premium subscription required');
  }
  
  // Make the API call
  return await api.get('/workouts/premium');
};
```

---

## Complete Screen Structure

### Home Screen (Dashboard)

```tsx
export const HomeScreen = () => {
  const { isSubscribed, activeEntitlements } = useSubscription();
  
  return (
    <ScrollView>
      {/* Header */}
      <Header user={user} />
      
      {/* Today's Workout - Available to all */}
      <DailyWorkoutCard />
      
      {/* Premium Features */}
      {isSubscribed && (
        <>
          <EntitlementGate entitlementId="premium_workouts">
            <PremiumWorkoutsSection />
          </EntitlementGate>
          
          <EntitlementGate entitlementId="nutrition_tracking">
            <NutritionSummary />
          </EntitlementGate>
        </>
      )}
      
      {/* Upgrade Banner (free users) */}
      {!isSubscribed && (
        <UpgradeBanner onPress={() => navigation.navigate('Paywall')} />
      )}
    </ScrollView>
  );
};
```

### Profile Screen (Subscription Management)

```tsx
export const ProfileScreen = () => {
  const { customerInfo, isSubscribed, logout } = useSubscription();
  
  return (
    <View>
      <UserInfo user={user} />
      
      {/* Subscription Status */}
      <SubscriptionCard 
        isActive={isSubscribed}
        expiresAt={customerInfo?.entitlements.active?.[0]?.expirationDate}
        onManagePress={() => {
          Linking.openURL(customerInfo?.managementURL);
        }}
      />
      
      {/* Premium Features List */}
      <PremiumFeaturesList entitlements={customerInfo?.entitlements.active} />
      
      {/* Settings */}
      <SettingsGroup>
        <SettingsItem 
          icon="🔔" 
          label="Notifications" 
          onPress={() => navigation.navigate('Notifications')}
        />
        <SettingsItem 
          icon="📊" 
          label="Subscription Status" 
          onPress={() => navigation.navigate('SubscriptionStatus')}
        />
        <SettingsItem 
          icon="🚪" 
          label="Logout" 
          onPress={logout}
          destructive
        />
      </SettingsGroup>
    </View>
  );
};
```

---

## The Complete File Structure

```
src/
├── components/
│   ├── common/
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Badge.tsx
│   │   └── LoadingSpinner.tsx
│   ├── guards/
│   │   ├── RequireEntitlement.tsx
│   │   └── EntitlementGate.tsx
│   └── paywall/
│       ├── PackageCard.tsx
│       ├── ValueProposition.tsx
│       └── PurchaseFlow.tsx
├── context/
│   └── SubscriptionContext.tsx
├── hooks/
│   ├── useRevenueCat.ts
│   ├── useSubscription.ts
│   └── useAppState.ts
├── navigation/
│   ├── RootNavigator.tsx
│   ├── MainNavigator.tsx
│   └── types.ts
├── screens/
│   ├── SplashScreen.tsx
│   ├── LoginScreen.tsx
│   ├── PaywallScreen.tsx
│   ├── SubscriptionStatusScreen.tsx
│   └── main/
│       ├── HomeScreen.tsx
│       ├── WorkoutsScreen.tsx
│       ├── NutritionScreen.tsx
│       ├── TrainerScreen.tsx
│       └── ProfileScreen.tsx
├── services/
│   ├── RevenueCatService.ts
│   ├── AuthService.ts
│   └── AnalyticsService.ts
├── theme/
│   ├── colors.ts
│   ├── typography.ts
│   └── spacing.ts
├── types/
│   └── revenueCat.ts
└── utils/
    ├── errorUtils.ts
    └── validators.ts
```

---

## Testing Checklist

### Pre-Launch Verification

```
📱 App Launch
  ✅ Splash screen shows
  ✅ RevenueCat initializes
  ✅ Cached state loads

🔐 Authentication
  ✅ Login works
  ✅ Signup works
  ✅ Anonymous mode works
  ✅ Account migration works

💰 Paywall
  ✅ Offerings load
  ✅ Packages display correctly
  ✅ Purchase flow works
  ✅ Restore works
  ✅ Error handling works

🎯 Feature Gating
  ✅ Premium features locked for free users
  ✅ Premium features unlock after purchase
  ✅ Real-time updates work
  ✅ Offline mode works

📊 Analytics
  ✅ Purchase events tracked
  ✅ Subscription events tracked
  ✅ User events tracked

🚀 Performance
  ✅ App launches in < 2 seconds
  ✅ Paywall loads in < 1 second
  ✅ Purchase processes in < 3 seconds

🛡️ Security
  ✅ API keys not exposed
  ✅ User data protected
  ✅ Session management works
```

---

## Quick Reference: Key Files

| File | Purpose |
|------|---------|
| `App.tsx` | Entry point, wraps app with providers |
| `SubscriptionContext.tsx` | Central state management |
| `RootNavigator.tsx` | Navigation decision tree |
| `PaywallScreen.tsx` | Purchase experience |
| `RequireEntitlement.tsx` | Feature guard component |
| `RevenueCatService.ts` | SDK wrapper |
| `useSubscription.ts` | Hook for components |

---

## Key Takeaway

> **A production subscription app is more than just a paywall. It's:**
> - A **navigation system** that guides users to the right screen
> - A **state management system** that knows who has access
> - **Feature guards** that protect premium content
> - A **backup system** (caching, offline support)
> - A **monetization engine** (paywall, purchases)
> - A **user management system** (auth, account migration)

Build each piece correctly, and they work together seamlessly.

---

## Your Journey Complete 🎉

You've now learned everything you need to build a production subscription app with RevenueCat:

1. ✅ **Foundations** - Setup, configuration, SDK initialization
2. ✅ **Paywall** - Beautiful purchase flow
3. ✅ **State Management** - Access control, real-time updates
4. ✅ **Backend** - Webhooks, analytics, optimization
5. ✅ **Full App** - Complete production implementation

**Now go build something amazing! 💪**
