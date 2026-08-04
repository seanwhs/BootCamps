# RevenueCat Masterclass: Student Workbook

## Complete Companion Guide for Building Subscription Apps with RevenueCat

---

# WELCOME & INTRODUCTION

## About This Workbook

This workbook is designed to accompany the RevenueCat Masterclass slide deck and video series. It provides:

- **Pre-class preparation** - What to review before each session
- **In-class activities** - Hands-on exercises to reinforce learning
- **Post-class homework** - Practice assignments to cement concepts
- **Self-assessment questions** - Check your understanding
- **Project tracking** - Build your app as you learn

## How to Use This Workbook

1. **Before each session**: Complete the "Pre-Class Preparation" section
2. **During the session**: Follow along with the "In-Class Activities"
3. **After each session**: Complete the "Homework" assignments
4. **Throughout**: Use the "Self-Check" questions to test your understanding

## Student Information

| Field | Your Answer |
|-------|-------------|
| Name | |
| Date Started | |
| Project Name | |
| GitHub Repository | |

---

# PART 1: FOUNDATIONS & ARCHITECTURE SETUP

## Pre-Class Preparation

### Readings
- [ ] Review RevenueCat documentation: [Getting Started](https://www.revenuecat.com/docs/getting-started)
- [ ] Watch: [RevenueCat Platform Overview](https://www.youtube.com/watch?v=abc123)
- [ ] Create a RevenueCat account (free tier)

### Accounts Needed
- [ ] Apple Developer Account (iOS development required)
- [ ] Google Play Console Account (Android development required)
- [ ] RevenueCat Account
- [ ] GitHub Account

### Environment Setup Checklist
- [ ] Node.js (v16+) installed - `node --version`: _______
- [ ] npm or yarn installed - `npm --version`: _______
- [ ] Xcode installed (Mac only)
- [ ] Android Studio installed
- [ ] VS Code or preferred editor installed
- [ ] iOS simulator configured
- [ ] Android emulator configured

---

## In-Class Activity 1.1: Create Your RevenueCat Account

### Steps
1. Go to https://www.revenuecat.com/
2. Click "Start Free Trial"
3. Sign up with your preferred method
4. Create your first project:

| Field | Your Value |
|-------|------------|
| Project Name | |
| Platform(s) | ☐ iOS ☐ Android ☐ Web |
| Bundle ID (iOS) | |
| Package Name (Android) | |

5. Generate and save your API keys:

| Key Type | Your Key (masked) |
|----------|-------------------|
| Public API Key | |
| Secret API Key | |
| Webhook API Key | |

---

## In-Class Activity 1.2: Configure App Store Connect

### iOS Product Setup Worksheet

**App Information**
| Field | Your Value |
|-------|------------|
| App Name | |
| Bundle ID | |
| SKU | |

**Subscription Group**
| Field | Your Value |
|-------|------------|
| Group Name | |
| Reference Name | |

**Monthly Subscription**
| Field | Your Value |
|-------|------------|
| Product ID | |
| Product Name | |
| Price | |
| Duration | |
| Introductory Offer | |

**Annual Subscription**
| Field | Your Value |
|-------|------------|
| Product ID | |
| Product Name | |
| Price | |
| Duration | |
| Introductory Offer | |

**Shared Secret**
| Field | Your Value |
|-------|------------|
| App Store Shared Secret | |

---

## In-Class Activity 1.3: Configure Google Play Console

### Android Product Setup Worksheet

**App Information**
| Field | Your Value |
|-------|------------|
| App Name | |
| Package Name | |
| App Category | |
| Target Audience | |

**Monthly Subscription**
| Field | Your Value |
|-------|------------|
| Product ID | |
| Product Name | |
| Price | |
| Billing Period | |

**Annual Subscription**
| Field | Your Value |
|-------|------------|
| Product ID | |
| Product Name | |
| Price | |
| Billing Period | |

**Service Account**
| Field | Your Value |
|-------|------------|
| Service Account Email | |
| JSON Key File Location | |

---

## In-Class Activity 1.4: Configure RevenueCat Dashboard

### Entitlements Worksheet

| Entitlement ID | Display Name | Description | Products Linked |
|----------------|--------------|-------------|-----------------|
| | | | |
| | | | |
| | | | |

### Offerings Worksheet

| Offering ID | Display Name | Packages Included |
|-------------|--------------|-------------------|
| | | |
| | | |

### Packages Worksheet

| Package ID | Product ID (iOS) | Product ID (Android) | Price | Trial |
|------------|------------------|---------------------|-------|-------|
| monthly | | | | |
| annual | | | | |

---

## In-Class Activity 1.5: SDK Installation

### Project Setup Commands

```bash
# Create React Native project
npx react-native init FitTrackPro --template react-native-template-typescript

# Navigate to project
cd FitTrackPro

# Install RevenueCat SDK
npm install react-native-purchases
npm install @react-native-async-storage/async-storage

# iOS: Install pods
cd ios && pod install && cd ..

# Start the project
npx react-native start
```

### Configuration Files

**Create `.env` file:**
```bash
REVENUECAT_PUBLIC_API_KEY=your_key_here
BACKEND_API_URL=http://localhost:3000/api
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGS=true
```

### RevenueCat Service Implementation

Fill in the blanks:

```typescript
// RevenueCatService.ts

import Purchases from 'react-native-purchases';
import { env } from '../config/env';

export class RevenueCatService {
  private static instance: RevenueCatService;
  private isConfigured: boolean = false;

  public static getInstance(): RevenueCatService {
    if (!RevenueCatService.instance) {
      RevenueCatService.instance = new ___________();
    }
    return RevenueCatService.instance;
  }

  public async initialize(appUserId?: string): Promise<void> {
    try {
      if (this.isConfigured) {
        if (appUserId) {
          await Purchases.___________(appUserId);
        }
        return;
      }

      const configuration = {
        apiKey: env.revenueCatPublicApiKey,
        appUserID: ___________,
        verboseLogs: env.enableDebugLogs,
        logLevel: env.isDevelopment ? Purchases.LOG_LEVEL.DEBUG : Purchases.LOG_LEVEL.INFO,
      };

      await Purchases.___________(configuration);
      this.isConfigured = true;
    } catch (error) {
      console.error('[RevenueCat] Failed to initialize SDK:', error);
      throw error;
    }
  }

  public async getOfferings(): Promise<Offerings | null> {
    try {
      return await Purchases.___________();
    } catch (error) {
      console.error('[RevenueCat] Failed to get offerings:', error);
      return null;
    }
  }
}
```

---

## Homework: Part 1

### Assignment 1: RevenueCat Dashboard

1. Create your RevenueCat project
2. Configure both iOS and Android store settings
3. Create 3 entitlements for your app
4. Create a default offering with monthly and annual packages
5. Generate your API keys and store them securely

### Assignment 2: SDK Integration

1. Complete the RevenueCatService.ts implementation
2. Create the useRevenueCat hook
3. Initialize the SDK in App.tsx
4. Display offerings on the home screen

### Self-Check Questions

1. What are the four pillars of RevenueCat's architecture?

2. Where must Products be created before using them in RevenueCat?

3. What is the difference between a Public API Key and a Secret API Key?

4. Why do you need a separate App User ID for authenticated users?

5. What is the purpose of the `addCustomerInfoUpdateListener` method?

---

# PART 2: PAYWALL & PURCHASE FLOW

## Pre-Class Preparation

### Readings
- [ ] Review: [Building a Paywall](https://www.revenuecat.com/docs/paywall)
- [ ] Review: [Apple HIG for In-App Purchases](https://developer.apple.com/design/human-interface-guidelines/in-app-purchases)
- [ ] Review: [Google Play UX Guidelines](https://developer.android.com/design/patterns/purchase-flow)

### Design Review
- [ ] Save 3 screenshots of effective paywalls from apps you use
- [ ] Note what makes them effective (value prop, pricing, CTA)

---

## In-Class Activity 2.1: Design System Creation

### Theme Structure

Create the following theme files:

**colors.ts** - Define your brand colors:

| Color Role | Hex Value |
|------------|-----------|
| Primary Main | |
| Primary Light | |
| Primary Dark | |
| Secondary Main | |
| Background Primary | |
| Background Secondary | |
| Text Primary | |
| Text Secondary | |

**typography.ts** - Define your text styles:

| Style | Font Size | Weight | Line Height |
|-------|-----------|--------|-------------|
| h1 | | | |
| h2 | | | |
| h3 | | | |
| body | | | |
| bodySmall | | | |
| caption | | | |
| button | | | |

---

## In-Class Activity 2.2: Paywall Screen Implementation

### Paywall Component Checklist

- [ ] Hero section with value proposition
- [ ] Feature list (3-5 key benefits)
- [ ] Pricing cards for each tier
- [ ] Monthly/Annual toggle (if applicable)
- [ ] "Best Value" badge on annual plan
- [ ] Purchase button with loading state
- [ ] Restore purchases button
- [ ] Terms and Privacy Policy links
- [ ] Error message display

### Package Card Component

Complete the following code:

```tsx
// PackageCard.tsx

interface PackageCardProps {
  pkg: Package;
  selected: boolean;
  onSelect: (pkg: Package) => void;
  isBestValue?: boolean;
}

export const PackageCard: React.FC<PackageCardProps> = ({
  pkg,
  selected,
  onSelect,
  isBestValue,
}) => {
  const { identifier, localizedPriceString } = pkg;
  
  return (
    <TouchableOpacity 
      style={[
        styles.card,
        selected && styles.selected,
        isBestValue && styles.bestValue,
      ]}
      onPress={() => onSelect(pkg)}
    >
      {isBestValue && (
        <View style={styles.badge}>
          <Text style={styles.badgeText}>⭐ Best Value</Text>
        </View>
      )}
      
      <Text style={styles.name}>
        {identifier === 'monthly' ? 'Monthly' : 
         identifier === 'annual' ? 'Annual' : identifier}
      </Text>
      
      <Text style={styles.price}>
        {localizedPriceString}
        {identifier === 'annual' && <Text style={styles.priceSubtext}> / year</Text>}
        {identifier === 'monthly' && <Text style={styles.priceSubtext}> / month</Text>}
      </Text>
      
      <Text style={styles.savings}>
        {identifier === 'annual' && 'Save 20% vs monthly'}
      </Text>
      
      <View style={styles.features}>
        <Text style={styles.featureText}>✅ Full access to all features</Text>
        <Text style={styles.featureText}>✅ Cancel anytime</Text>
        {identifier === 'annual' && (
          <Text style={styles.featureText}>✅ Priority support</Text>
        )}
      </View>
    </TouchableOpacity>
  );
};
```

---

## In-Class Activity 2.3: Purchase Flow Implementation

### Purchase Flow State Machine

Complete the purchase flow states:

```
States:
- IDLE: Ready to purchase
- LOADING: Fetching offerings
- PROCESSING: Purchase in progress
- SUCCESS: Purchase completed
- ERROR: Purchase failed
- RESTORING: Restoring purchases
```

### Purchase Error Handling Map

| Error Code | User-Friendly Message | Recovery Action |
|------------|----------------------|-----------------|
| PURCHASE_CANCELLED | | |
| NETWORK_ERROR | | |
| PRODUCT_NOT_AVAILABLE | | |
| PURCHASE_NOT_ALLOWED | | |
| INVALID_CREDENTIALS | | |

### Purchase Flow Component

Complete the implementation:

```tsx
// PurchaseFlow.tsx

export const PurchaseFlow: React.FC<PurchaseFlowProps> = ({
  isVisible,
  state,
  errorMessage,
  onClose,
  onRetry,
}) => {
  const renderContent = () => {
    switch (state) {
      case 'processing':
        return (
          <View style={styles.content}>
            <ActivityIndicator size="large" />
            <Text style={styles.title}>Processing Purchase</Text>
            <Text style={styles.subtitle}>
              Please wait while we complete your transaction...
            </Text>
          </View>
        );
        
      case 'success':
        return (
          <View style={styles.content}>
            <Text style={styles.emoji}>🎉</Text>
            <Text style={styles.title}>Welcome Aboard!</Text>
            <Text style={styles.subtitle}>
              Your subscription has been activated.
            </Text>
            <TouchableOpacity onPress={onClose}>
              <Text>Get Started</Text>
            </TouchableOpacity>
          </View>
        );
        
      case 'error':
        return (
          <View style={styles.content}>
            <Text style={styles.emoji}>😕</Text>
            <Text style={styles.title}>Something Went Wrong</Text>
            <Text style={styles.subtitle}>
              {errorMessage}
            </Text>
            <TouchableOpacity onPress={onRetry}>
              <Text>Try Again</Text>
            </TouchableOpacity>
          </View>
        );
        
      default:
        return null;
    }
  };
  
  // ... rest of component
};
```

---

## In-Class Activity 2.4: Paywall Integration

### Complete Paywall Screen

Integrate all components into the final PaywallScreen:

```tsx
export const PaywallScreen = () => {
  const { offerings, purchasePackage, restorePurchases } = useRevenueCat();
  const [selectedPackage, setSelectedPackage] = useState<Package | null>(null);
  const [isPurchasing, setIsPurchasing] = useState(false);
  const [showAnnual, setShowAnnual] = useState(false);
  
  // 1. Get packages from offerings
  const packages = offerings?.current?.availablePackages || [];
  
  // 2. Separate monthly and annual
  const monthlyPackages = packages.filter(p => p.identifier.includes('monthly'));
  const annualPackages = packages.filter(p => p.identifier.includes('annual'));
  
  // 3. Handle purchase
  const handlePurchase = async () => {
    if (!selectedPackage) return;
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
  
  // 4. Handle restore
  const handleRestore = async () => {
    // ... implementation
  };
  
  // 5. Render the paywall
  return (
    <View>
      {/* Hero section */}
      {/* Feature list */}
      {/* Toggle */}
      {/* Package cards */}
      {/* Purchase button */}
      {/* Restore button */}
      {/* Terms */}
    </View>
  );
};
```

---

## Homework: Part 2

### Assignment 1: Paywall Design

1. Design and implement a complete paywall screen
2. Include all states: loading, idle, purchasing, success, error
3. Implement monthly/annual toggle
4. Add "Best Value" highlighting
5. Include restore purchases functionality

### Assignment 2: Purchase Handling

1. Implement complete purchase flow with error handling
2. Test with sandbox accounts
3. Handle all error states gracefully
4. Test cancellation flow
5. Test successful purchase flow

### Self-Check Questions

1. What are the three essential elements of a conversion-optimized paywall?

2. How should you handle the PURCHASE_CANCELLED error?

3. Why is price anchoring effective in paywall design?

4. What should be included in the terms and conditions section?

5. How do you handle a purchase that succeeds but doesn't grant entitlements?

---

# PART 3: SUBSCRIPTION STATE MANAGEMENT & ACCESS CONTROL

## Pre-Class Preparation

### Readings
- [ ] Review: [State Management Best Practices](https://www.revenuecat.com/docs/state-management)
- [ ] Review: [React Context Documentation](https://react.dev/learn/passing-data-deeply-with-context)

### Key Concepts
- [ ] React Context
- [ ] Feature Gating
- [ ] User Identity
- [ ] Account Migration
- [ ] Offline Support

---

## In-Class Activity 3.1: Subscription Context

### Context Structure

Complete the SubscriptionContext implementation:

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

interface SubscriptionContextValue extends SubscriptionState {
  setUserId: (userId: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshSubscription: () => Promise<void>;
  hasEntitlement: (entitlementId: string) => Promise<boolean>;
  purchasePackage: (pkg: Package) => Promise<any>;
  restorePurchases: () => Promise<CustomerInfo>;
  isAuthenticated: boolean;
}

const SubscriptionContext = createContext<SubscriptionContextValue | undefined>(
  undefined
);

export const SubscriptionProvider: React.FC = ({ children }) => {
  const [state, setState] = useState<SubscriptionState>({
    customerInfo: null,
    isSubscribed: false,
    activeEntitlements: {},
    isLoading: true,
    error: null,
    isAnonymous: true,
    appUserId: null,
  });
  
  // 1. Update state from CustomerInfo
  const updateStateFromCustomerInfo = useCallback((customerInfo: CustomerInfo) => {
    const activeEntitlements = customerInfo.entitlements.active || {};
    const isSubscribed = Object.keys(activeEntitlements).length > 0;
    
    setState(prev => ({
      ...prev,
      customerInfo,
      isSubscribed,
      activeEntitlements,
      isLoading: false,
      error: null,
    }));
    
    // Cache for offline use
    cacheSubscriptionState({ customerInfo, isSubscribed, activeEntitlements });
  }, []);
  
  // 2. Initialize
  const initialize = useCallback(async () => {
    try {
      setState(prev => ({ ...prev, isLoading: true }));
      await revenueCatService.initialize();
      const customerInfo = await revenueCatService.getCustomerInfo();
      if (customerInfo) {
        updateStateFromCustomerInfo(customerInfo);
      }
    } catch (error) {
      // Load from cache
      const cached = await loadCachedState();
      if (cached) {
        updateStateFromCustomerInfo(cached.customerInfo);
      } else {
        setState(prev => ({
          ...prev,
          isLoading: false,
          error: 'Failed to initialize',
        }));
      }
    }
  }, []);
  
  // 3. Real-time updates
  useEffect(() => {
    const listener = revenueCatService.addCustomerInfoListener((info) => {
      updateStateFromCustomerInfo(info);
    });
    return () => listener.remove();
  }, []);
  
  // 4. Methods
  const hasEntitlement = useCallback(async (entitlementId: string) => {
    return revenueCatService.hasEntitlement(entitlementId, state.customerInfo);
  }, [state.customerInfo]);
  
  const purchasePackage = useCallback(async (pkg: Package) => {
    const result = await revenueCatService.purchasePackage(pkg);
    updateStateFromCustomerInfo(result.customerInfo);
    return result;
  }, []);
  
  // 5. Return context value
  const value = {
    ...state,
    setUserId,
    logout,
    refreshSubscription,
    hasEntitlement,
    purchasePackage,
    restorePurchases,
    isAuthenticated: !state.isAnonymous && !!state.appUserId,
  };
  
  return (
    <SubscriptionContext.Provider value={value}>
      {children}
    </SubscriptionContext.Provider>
  );
};
```

---

## In-Class Activity 3.2: Feature Guard Components

### RequireEntitlement Component

Complete the implementation:

```tsx
interface RequireEntitlementProps {
  entitlementId: string;
  children: React.ReactNode;
  fallback?: React.ReactNode;
  onUpgradePress?: () => void;
}

export const RequireEntitlement: React.FC<RequireEntitlementProps> = ({
  entitlementId,
  children,
  fallback,
  onUpgradePress,
}) => {
  const { hasEntitlement, isLoading } = useSubscription();
  const [hasAccess, setHasAccess] = useState<boolean | null>(null);
  
  useEffect(() => {
    const checkAccess = async () => {
      const access = await hasEntitlement(entitlementId);
      setHasAccess(access);
    };
    checkAccess();
  }, [entitlementId, hasEntitlement]);
  
  if (isLoading || hasAccess === null) {
    return <LoadingSpinner />;
  }
  
  if (hasAccess) {
    return <>{children}</>;
  }
  
  if (fallback) {
    return <>{fallback}</>;
  }
  
  return (
    <UpgradePrompt 
      entitlementId={entitlementId}
      onUpgradePress={onUpgradePress}
    />
  );
};
```

### EntitlementGate Component

```tsx
interface EntitlementGateProps {
  entitlementId: string;
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export const EntitlementGate: React.FC<EntitlementGateProps> = ({
  entitlementId,
  children,
  fallback = null,
}) => {
  const { hasEntitlement } = useSubscription();
  const [hasAccess, setHasAccess] = useState<boolean | null>(null);
  
  // Similar to RequireEntitlement but simpler
  // Only shows/hides content, no upgrade prompt
  
  if (hasAccess === null) {
    return <View style={styles.placeholder} />;
  }
  
  return <>{hasAccess ? children : fallback}</>;
};
```

---

## In-Class Activity 3.3: User Identity & Account Migration

### Auth Service Implementation

Complete the authentication service:

```typescript
// AuthService.ts

export class AuthService {
  private static instance: AuthService;
  private currentUser: User | null = null;
  
  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }
  
  public async signIn(email: string, password: string): Promise<User> {
    // 1. Validate input
    if (!email || !password) {
      throw new Error('Email and password are required');
    }
    
    // 2. Mock authentication (replace with real backend)
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // 3. Create user
    const user: User = {
      id: `user_${Date.now()}`,
      email,
      displayName: email.split('@')[0],
      createdAt: new Date().toISOString(),
    };
    
    // 4. Set RevenueCat user ID
    await revenueCatService.setAppUserID(user.id);
    
    // 5. Store user
    this.currentUser = user;
    await AsyncStorage.setItem('@auth_user', JSON.stringify(user));
    
    return user;
  }
  
  public async signOut(): Promise<void> {
    // 1. Reset RevenueCat to anonymous
    await revenueCatService.resetAppUserID();
    
    // 2. Clear local state
    this.currentUser = null;
    await AsyncStorage.removeItem('@auth_user');
  }
  
  public async transferAnonymousSubscription(userId: string): Promise<void> {
    // This transfers the subscription from anonymous to authenticated
    await revenueCatService.setAppUserID(userId);
  }
}
```

---

## In-Class Activity 3.4: Login Screen with Migration

### Login Screen with Account Migration

```tsx
export const LoginScreen = () => {
  const { isAnonymousUserSubscribed, transferAnonymousSubscription } = useSubscription();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [showTransferPrompt, setShowTransferPrompt] = useState(false);
  
  const handleLogin = async () => {
    setIsLoading(true);
    try {
      await authService.signIn(email, password);
      
      // Check if we need to transfer a subscription
      if (isAnonymousUserSubscribed) {
        setShowTransferPrompt(true);
      } else {
        // Navigate to main app
      }
    } catch (error) {
      Alert.alert('Login Failed', error.message);
    } finally {
      setIsLoading(false);
    }
  };
  
  const handleTransferSubscription = async () => {
    setIsLoading(true);
    try {
      const user = authService.getCurrentUser();
      await transferAnonymousSubscription(user.id);
      setShowTransferPrompt(false);
      // Navigate to main app
    } catch (error) {
      Alert.alert('Transfer Failed', error.message);
    } finally {
      setIsLoading(false);
    }
  };
  
  // Render login form or transfer prompt
};
```

---

## Homework: Part 3

### Assignment 1: Subscription Context

1. Implement the complete SubscriptionContext
2. Add caching for offline support
3. Test with anonymous and authenticated users
4. Handle all loading and error states

### Assignment 2: Feature Gating

1. Implement RequireEntitlement component
2. Implement EntitlementGate component
3. Gate at least 3 premium features in your app
4. Show appropriate upgrade prompts

### Assignment 3: Account Migration

1. Implement authentication service
2. Create login screen with migration flow
3. Test anonymous subscription transfer
4. Test cross-device access

### Self-Check Questions

1. What is the difference between RequireEntitlement and EntitlementGate?

2. How does account migration work in RevenueCat?

3. Why should you cache subscription state?

4. What happens when resetAppUserID() is called?

5. How do you check if a user has a specific entitlement?

---

# PART 4: WEBHOOKS, ANALYTICS & REVENUE OPTIMIZATION

## Pre-Class Preparation

### Readings
- [ ] Review: [Webhooks Guide](https://www.revenuecat.com/docs/webhooks)
- [ ] Review: [RevenueCat Analytics](https://www.revenuecat.com/docs/analytics)
- [ ] Review: [RevenueCat Experiments](https://www.revenuecat.com/docs/experiments)

### Project Setup
- [ ] Create a backend project (Node.js/Express)
- [ ] Set up environment variables
- [ ] Test webhook endpoint locally (ngrok)

---

## In-Class Activity 4.1: Webhook Setup

### Backend Project Structure

```
backend/
├── src/
│   ├── webhooks/
│   │   └── revenueCatHandler.ts
│   ├── services/
│   │   ├── databaseService.ts
│   │   ├── analyticsService.ts
│   │   └── notificationService.ts
│   ├── utils/
│   │   ├── security.ts
│   │   └── logger.ts
│   ├── routes/
│   │   └── webhook.ts
│   └── index.ts
├── .env
├── package.json
└── tsconfig.json
```

### Webhook Handler Implementation

Complete the webhook handler:

```typescript
// revenueCatHandler.ts

export class RevenueCatWebhookHandler {
  private database: DatabaseService;
  private analytics: AnalyticsService;
  private notifications: NotificationService;
  
  async handleWebhook(body: any, headers: any): Promise<void> {
    // 1. Verify signature
    if (!verifyWebhookSignature(body, headers)) {
      throw new Error('Invalid webhook signature');
    }
    
    // 2. Get event type
    const event = body as RevenueCatEvent;
    const eventType = event.type;
    
    // 3. Process by type
    switch (eventType) {
      case 'INITIAL_PURCHASE':
        await this.handleInitialPurchase(event);
        break;
      case 'RENEWAL':
        await this.handleRenewal(event);
        break;
      case 'CANCELLATION':
        await this.handleCancellation(event);
        break;
      case 'EXPIRATION':
        await this.handleExpiration(event);
        break;
      case 'REFUND':
        await this.handleRefund(event);
        break;
      case 'BILLING_ISSUE':
        await this.handleBillingIssue(event);
        break;
      case 'GRACE_PERIOD':
        await this.handleGracePeriod(event);
        break;
      default:
        console.log(`Unknown event type: ${eventType}`);
    }
  }
  
  private async handleInitialPurchase(event: RevenueCatEvent): Promise<void> {
    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'active',
      startDate: new Date(event.purchase_date),
      expirationDate: new Date(event.expiration_date),
    });
    
    // Send welcome email
    await this.notifications.sendWelcomeEmail(event.subscriber_id);
    
    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'subscription_purchase',
      productId: event.product_id,
      price: event.price,
    });
  }
}
```

---

## In-Class Activity 4.2: Analytics Integration

### Analytics Service Implementation

```typescript
// analyticsService.ts

export class AnalyticsService {
  async trackSubscriptionEvent(data: {
    userId: string;
    event: string;
    productId?: string;
    price?: number;
    currency?: string;
  }): Promise<void> {
    // Track to multiple providers
    
    // 1. Mixpanel
    await this.trackMixpanel(data);
    
    // 2. Amplitude
    await this.trackAmplitude(data);
    
    // 3. PostHog
    await this.trackPostHog(data);
    
    // 4. Custom database
    await this.trackCustomAnalytics(data);
  }
  
  private async trackMixpanel(data: AnalyticsEvent): Promise<void> {
    // Simulate Mixpanel tracking
    console.log('[Mixpanel] Track:', data);
  }
}
```

### Events to Track Worksheet

| Event Name | Properties | When to Track |
|------------|------------|---------------|
| subscription_purchase | userId, productId, price | After successful purchase |
| subscription_renewal | userId, productId | On renewal |
| subscription_cancelled | userId, reason | On cancellation |
| subscription_expired | userId | On expiration |
| paywall_viewed | userId, source | When paywall opens |
| paywall_conversion | userId, productId | On purchase |
| user_signup | userId, source | On signup |
| user_login | userId | On login |

---

## In-Class Activity 4.3: Churn Reduction Strategies

### Churn Prevention Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CHURN PREVENTION PIPELINE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. BILLING ISSUE DETECTED                                         │
│     └── Send notification: "Update payment method"                │
│                                                                     │
│  2. GRACE PERIOD STARTS (3-7 days)                                 │
│     └── Send notification: "Update payment or lose access"        │
│                                                                     │
│  3. EXPIRATION                                                     │
│     └── Send notification: "Your access has ended"                │
│                                                                     │
│  4. WIN-BACK CAMPAIGN                                              │
│     └── Day 7: "We miss you! 30% off"                            │
│     └── Day 14: "Special offer just for you"                     │
│     └── Day 30: "Your data is waiting"                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Win-Back Campaign Implementation

```typescript
// notificationService.ts

async checkWinBackEligibility(userId: string): Promise<void> {
  const user = await this.database.getUser(userId);
  if (!user) return;
  
  const daysSinceExpiration = Math.floor(
    (Date.now() - new Date(user.expirationDate).getTime()) / (1000 * 60 * 60 * 24)
  );
  
  // Send different offers at different times
  if (daysSinceExpiration === 7) {
    await this.sendWinBackEmail(userId, {
      offer: '30% off your first month',
      message: 'We miss you! Come back and continue your fitness journey.'
    });
  } else if (daysSinceExpiration === 14) {
    await this.sendWinBackEmail(userId, {
      offer: '50% off your first month',
      message: 'Special offer just for you! Don\'t let your progress go to waste.'
    });
  } else if (daysSinceExpiration === 30) {
    await this.sendWinBackEmail(userId, {
      offer: 'First month free',
      message: 'Your workout data is still here. Come back and start where you left off!'
    });
  }
}
```

---

## Homework: Part 4

### Assignment 1: Webhook Implementation

1. Create a webhook endpoint
2. Implement signature verification
3. Handle at least 5 event types
4. Update database on events
5. Always return 200 OK

### Assignment 2: Analytics Integration

1. Integrate at least one analytics provider
2. Track all subscription events
3. Track paywall events
4. Set up a revenue dashboard

### Assignment 3: Churn Reduction

1. Implement grace period handling
2. Set up win-back email campaigns
3. Implement billing issue notifications
4. Create a cancellation feedback flow

### Self-Check Questions

1. Why is webhook signature verification important?

2. What HTTP status code should your webhook return?

3. What is the purpose of a grace period?

4. What metrics should you track for subscription revenue?

5. What is the difference between churn rate and retention rate?

---

# PART 5: FULL APP INTEGRATION

## Pre-Class Preparation

### Readings
- [ ] Review: [React Navigation Documentation](https://reactnavigation.org/docs/getting-started)
- [ ] Review: [Production Checklist](https://www.revenuecat.com/docs/production-checklist)

### Final Review
- [ ] All previous parts completed
- [ ] RevenueCat configured
- [ ] Paywall working
- [ ] State management working
- [ ] Webhooks implemented

---

## In-Class Activity 5.1: Navigation Setup

### Root Navigator Implementation

Complete the navigation structure:

```typescript
// RootNavigator.tsx

export type RootStackParamList = {
  Splash: undefined;
  Login: undefined;
  Paywall: undefined;
  Main: NavigatorScreenParams<MainTabParamList>;
  SubscriptionStatus: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Workouts: undefined;
  Nutrition: undefined;
  Trainer: undefined;
  Profile: undefined;
};

export const RootNavigator: React.FC = () => {
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

### Navigation Flow Diagram

Draw the complete navigation flow:

```
[Start] → [Splash] → [Check State]
                        ↓
              ┌────────┴────────┐
              ↓                 ↓
         [Login]           [Authenticated]
              ↓                 ↓
         [Paywall]     [Main App]
              ↓                 ↓
         [Main App]    [Home → Workouts → Nutrition → Trainer → Profile]
              ↓
    [Subscription Status]
```

---

## In-Class Activity 5.2: Main App Screens

### Home Screen Implementation

Complete the home screen with premium gating:

```tsx
export const HomeScreen = () => {
  const { isSubscribed, activeEntitlements } = useSubscription();
  
  return (
    <ScrollView>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.greeting}>Good morning 👋</Text>
        <Text style={styles.subGreeting}>Let's crush your fitness goals!</Text>
      </View>
      
      {/* Today's Workout - Free Feature */}
      <Card>
        <Text style={styles.sectionTitle}>Today's Workout</Text>
        <WorkoutCard workout={todayWorkout} />
      </Card>
      
      {/* Premium Features - Gated */}
      {isSubscribed && (
        <>
          <RequireEntitlement entitlementId="premium_workouts">
            <PremiumWorkoutsSection />
          </RequireEntitlement>
          
          <RequireEntitlement entitlementId="nutrition_tracking">
            <NutritionSection />
          </RequireEntitlement>
        </>
      )}
      
      {/* Upgrade Banner - Free Users */}
      {!isSubscribed && (
        <UpgradeBanner onPress={() => navigation.navigate('Paywall')} />
      )}
    </ScrollView>
  );
};
```

### Profile Screen with Subscription Management

```tsx
export const ProfileScreen = () => {
  const { customerInfo, isSubscribed, logout } = useSubscription();
  
  return (
    <View>
      <UserCard user={user} />
      
      <SubscriptionCard
        isActive={isSubscribed}
        expiresAt={customerInfo?.entitlements.active?.[0]?.expirationDate}
        onManagePress={() => {
          if (customerInfo?.managementURL) {
            Linking.openURL(customerInfo.managementURL);
          }
        }}
      />
      
      <SettingsGroup>
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

## In-Class Activity 5.3: Complete Integration

### App.tsx - Entry Point

```tsx
import React from 'react';
import { SafeAreaView, StatusBar } from 'react-native';
import { SubscriptionProvider } from './src/context/SubscriptionContext';
import { RootNavigator } from './src/navigation/RootNavigator';
import { colors } from './src/theme/colors';

const App = () => {
  return (
    <SubscriptionProvider>
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
        <StatusBar barStyle="dark-content" backgroundColor={colors.background.primary} />
        <RootNavigator />
      </SafeAreaView>
    </SubscriptionProvider>
  );
};

export default App;
```

### Production Readiness Checklist

- [ ] All environment variables configured
- [ ] Error handling implemented throughout
- [ ] Analytics integrated
- [ ] Performance monitoring set up
- [ ] App store assets prepared
- [ ] Production API keys ready
- [ ] Webhook endpoint live
- [ ] Tested with sandbox accounts
- [ ] Privacy policy in place
- [ ] Terms of service in place

---

## Homework: Part 5

### Assignment 1: Complete Navigation

1. Implement all screens in the navigation flow
2. Add tab navigation for main app
3. Implement deep linking
4. Add navigation transitions

### Assignment 2: Feature Gating

1. Gate all premium features
2. Implement upgrade prompts
3. Test with free and subscribed users
4. Handle edge cases (offline, etc.)

### Assignment 3: Production Readiness

1. Complete the production readiness checklist
2. Deploy webhook endpoint
3. Configure production API keys
4. Test on both iOS and Android
5. Submit to app stores

### Self-Check Questions

1. How does the navigation flow work with subscription state?

2. What screens should be accessible to free users?

3. How do you handle subscription status changes in real-time?

4. What should be included in the production checklist?

5. How do you test purchases before going live?

---

# APPENDIX: QUICK REFERENCE

## RevenueCat Core Concepts

| Concept | Definition | Example |
|---------|------------|---------|
| Product | Purchasable item in app store | `com.app.monthly` |
| Entitlement | What users unlock | `premium_workouts` |
| Package | Wrapper for cross-platform | `monthly` |
| Offering | Group of packages | `default` |

## Common RevenueCat Methods

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

| Code | Meaning | User Message |
|------|---------|--------------|
| PURCHASE_CANCELLED | User cancelled | "You cancelled the purchase." |
| NETWORK_ERROR | No internet | "Check your connection." |
| PRODUCT_NOT_AVAILABLE | Product unavailable | "Try again later." |
| PURCHASE_NOT_ALLOWED | IAP not allowed | "Check your settings." |
| INVALID_CREDENTIALS | API key issue | "Contact support." |

---

# PROJECT TRACKER

## Overall Progress

| Part | Status | Date Completed | Notes |
|------|--------|----------------|-------|
| Part 1: Foundations | ☐ | | |
| Part 2: Paywall | ☐ | | |
| Part 3: State Management | ☐ | | |
| Part 4: Webhooks & Analytics | ☐ | | |
| Part 5: Full Integration | ☐ | | |

## Milestone Checklist

### Pre-Launch
- [ ] RevenueCat account created
- [ ] App store products configured
- [ ] RevenueCat entitlements created
- [ ] RevenueCat offerings configured
- [ ] SDK installed and initialized
- [ ] Paywall screen built
- [ ] Purchase flow implemented
- [ ] Subscription context built
- [ ] Feature gating implemented
- [ ] Authentication implemented
- [ ] Account migration implemented
- [ ] Webhook endpoint built
- [ ] Analytics integrated
- [ ] Churn reduction strategies implemented
- [ ] Navigation implemented
- [ ] All screens built
- [ ] Testing completed
- [ ] App store submission ready

---

# NOTES & OBSERVATIONS

## Session Notes

### Part 1:
```
[Your notes here]
```

### Part 2:
```
[Your notes here]
```

### Part 3:
```
[Your notes here]
```

### Part 4:
```
[Your notes here]
```

### Part 5:
```
[Your notes here]
```

## Questions for Instructor

1. 
2. 
3. 
4. 
5. 

## Key Takeaways

1. 
2. 
3. 
4. 
5. 

---

*This workbook is designed to accompany the RevenueCat Masterclass. Complete all sections for maximum learning benefit.*
