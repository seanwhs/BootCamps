# Appendix H: Advanced RevenueCat Features

## Overview

This appendix explores advanced RevenueCat features that go beyond basic subscription management. These features enable sophisticated monetization strategies, better user experiences, and more powerful business intelligence.

Think of this as your "power user guide" – features and techniques for taking your subscription business to the next level.

---

## 1. Virtual Currencies

### Overview

Virtual currencies allow you to monetize features that don't fit the traditional subscription model – like AI credits, consumable items, or token-based usage. RevenueCat handles the purchase, tracking, and validation of virtual currencies.

### Use Cases

| Use Case | Description | Example |
|----------|-------------|---------|
| **AI Credits** | Pay-per-use AI features | 10 credits = 1 AI workout plan |
| **Virtual Items** | In-app cosmetics or boosts | 50 gems = 1 premium avatar |
| **Gated Content** | Unlock premium articles/lessons | 5 tokens = 1 expert video |
| **Feature Access** | Unlock specific features | 100 coins = Advanced analytics |
| **Consumable Usage** | Pay for each use | 1 credit per workout class |

### Implementation

```typescript
// React Native - Virtual Currencies
import Purchases from 'react-native-purchases';

// Purchase virtual currency
const purchaseCoins = async () => {
  try {
    // Create a product for virtual currency
    const offerings = await Purchases.getOfferings();
    const coinPackage = offerings.current?.availablePackages.find(
      pkg => pkg.identifier === 'coins_100'
    );
    
    if (!coinPackage) {
      console.error('Coin package not found');
      return;
    }
    
    const { customerInfo } = await Purchases.purchasePackage(coinPackage);
    
    // Currency balances are in customerInfo
    const coinBalance = customerInfo.currencies.all['COINS']?.balance || 0;
    console.log(`💰 New coin balance: ${coinBalance}`);
    
  } catch (error) {
    console.error('Purchase failed:', error);
  }
};

// Check currency balance
const checkBalance = async () => {
  const customerInfo = await Purchases.getCustomerInfo();
  const balances = customerInfo.currencies.all;
  
  console.log('Currency balances:', {
    coins: balances['COINS']?.balance || 0,
    gems: balances['GEMS']?.balance || 0,
  });
};

// Spend virtual currency
const spendCoins = async (amount: number) => {
  try {
    // Invalidate cache for fresh balance
    await Purchases.invalidateVirtualCurrenciesCache();
    const customerInfo = await Purchases.getCustomerInfo();
    const currentBalance = customerInfo.currencies.all['COINS']?.balance || 0;
    
    if (currentBalance < amount) {
      throw new Error(`Insufficient balance. Have ${currentBalance}, need ${amount}`);
    }
    
    // Spend the coins on your server
    const response = await fetch('/api/spend-coins', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        userId: customerInfo.originalAppUserId,
        amount: amount,
      }),
    });
    
    const result = await response.json();
    
    // Refresh balance after spending
    await Purchases.invalidateVirtualCurrenciesCache();
    const updatedInfo = await Purchases.getCustomerInfo();
    const newBalance = updatedInfo.currencies.all['COINS']?.balance || 0;
    
    console.log(`💰 Spent ${amount} coins. New balance: ${newBalance}`);
    
  } catch (error) {
    console.error('Failed to spend coins:', error);
  }
};
```

### Server-Side Validation

```typescript
// Backend - Validate and deduct currency
const handleSpendCoins = async (req: Request, res: Response) => {
  const { userId, amount } = req.body;
  
  try {
    // Get subscriber info
    const subscriber = await fetchSubscriber(userId);
    const coinBalance = subscriber.subscriber.currencies?.COINS?.balance || 0;
    
    if (coinBalance < amount) {
      return res.status(400).json({
        error: 'Insufficient balance',
        balance: coinBalance,
        required: amount,
      });
    }
    
    // Deduct coins - use RevenueCat REST API
    // Note: Deduct operation requires server-side SDK or custom integration
    
    // Log transaction
    await logTransaction({
      userId,
      type: 'spend_coins',
      amount: amount,
      previousBalance: coinBalance,
      newBalance: coinBalance - amount,
    });
    
    // Grant whatever the coins were for
    await grantFeatureAccess(userId, 'premium_workout');
    
    res.json({
      success: true,
      newBalance: coinBalance - amount,
    });
    
  } catch (error) {
    console.error('Failed to spend coins:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
```

---

## 2. Promotional Offers

### Overview

Promotional offers are targeted discounts or incentives designed to attract new subscribers, win back lapsed users, or encourage upgrades. RevenueCat supports various types of promotional offers across platforms.

### Offer Types

| Type | Description | Best For |
|------|-------------|----------|
| **Free Trial** | X days free before charging | New users, onboarding |
| **Introductory Discount** | Discounted price for X months | Converting price-sensitive users |
| **Win-Back Offer** | Discounted price for returning users | Lapsed subscribers |
| **Upgrade Offer** | Discount for upgrading tier | Moving users to higher value |
| **Referral Offer** | Discount for referring friends | Viral growth |

### Implementation

```typescript
// React Native - Check for available offers
const checkPromotionalOffers = async () => {
  const customerInfo = await Purchases.getCustomerInfo();
  const productIdentifier = 'com.fittrackpro.annual';
  
  // Check if user is eligible for promotional offer
  try {
    const products = await Purchases.getProducts(
      [productIdentifier],
      'subscription'
    );
    
    const product = products[0];
    
    // Check for eligible offers on iOS
    if (product.discounts && product.discounts.length > 0) {
      const eligibleDiscounts = product.discounts.filter(
        discount => discount.isEligible
      );
      
      console.log('Eligible discounts:', eligibleDiscounts);
      
      // Show promotional offer
      if (eligibleDiscounts.length > 0) {
        const bestOffer = eligibleDiscounts[0];
        showPromotionalOffer(bestOffer);
      }
    }
    
    // Check for introductory offers
    if (product.introductoryPrice) {
      console.log('Introductory offer available:', product.introductoryPrice);
      // Show introductory pricing
    }
    
  } catch (error) {
    console.error('Failed to check offers:', error);
  }
};

// Purchase with promotional offer
const purchaseWithPromotionalOffer = async (
  packageToPurchase: Package,
  discount: any
) => {
  try {
    // On iOS, apply discount when purchasing
    const { customerInfo } = await Purchases.purchasePackage(packageToPurchase);
    
    console.log('Purchase with discount complete');
    return customerInfo;
    
  } catch (error) {
    console.error('Promotional purchase failed:', error);
    throw error;
  }
};
```

### Server-Side Offer Management

```typescript
// Backend - Manage promotional offers
class PromotionalOfferService {
  private database: DatabaseService;
  
  constructor() {
    this.database = new DatabaseService();
  }
  
  /**
   * Check if user is eligible for win-back offer
   */
  async getWinBackOffer(userId: string): Promise<any | null> {
    const user = await this.database.getUser(userId);
    if (!user) return null;
    
    // Check if user has been expired for less than 30 days
    if (user.subscriptionStatus !== 'expired') {
      return null;
    }
    
    const daysSinceExpiration = Math.floor(
      (Date.now() - new Date(user.expirationDate).getTime()) / (1000 * 60 * 60 * 24)
    );
    
    if (daysSinceExpiration > 30) {
      return null;
    }
    
    // Offer 20% discount on first month
    return {
      type: 'win_back',
      discount: 20,
      duration: 1, // months
      expiresIn: 7, // days
      productId: 'com.fittrackpro.monthly',
      campaign: 'win_back_q4',
    };
  }
  
  /**
   * Track offer usage
   */
  async trackOfferUsage(
    userId: string,
    offerId: string,
    success: boolean
  ): Promise<void> {
    await this.database.trackOfferEvent({
      userId,
      offerId,
      event: success ? 'converted' : 'declined',
      timestamp: new Date(),
    });
  }
}
```

---

## 3. RevenueCat Experiments

### Overview

RevenueCat Experiments allows you to A/B test paywalls, pricing, and offers without releasing new app versions. This enables data-driven optimization of your monetization strategy.

### Experiment Types

| Type | Description | Metrics to Track |
|------|-------------|------------------|
| **Paywall Design** | Test different layouts, colors, copy | Conversion rate, Time to purchase |
| **Pricing** | Test different price points | Conversion rate, Revenue per user |
| **Offer Structure** | Test free trials vs. discounts | Conversion rate, Retention rate |
| **Feature Presentation** | Test feature highlighting | Feature adoption, Conversion rate |
| **Messaging** | Test different value propositions | Conversion rate, Engagement |

### Implementation

```typescript
// React Native - Integration with RevenueCat Experiments
const usePaywallExperiment = () => {
  const [experimentData, setExperimentData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  
  useEffect(() => {
    const fetchExperiment = async () => {
      setIsLoading(true);
      try {
        // RevenueCat Experiments are handled server-side
        // The client doesn't need to know about variants directly
        // The server provides the configuration based on user assignment
        
        const response = await fetch(`/api/experiments/paywall`, {
          headers: {
            'Authorization': `Bearer ${await getAuthToken()}`,
          },
        });
        
        const data = await response.json();
        setExperimentData(data);
        
        // Track experiment impression
        if (data.variantId) {
          await trackExperimentImpression(data.variantId);
        }
        
      } catch (error) {
        console.error('Failed to fetch experiment:', error);
        // Fallback to default paywall
        setExperimentData({ variantId: 'control', config: {} });
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchExperiment();
  }, []);
  
  // Render paywall based on experiment variant
  const renderPaywall = () => {
    if (isLoading) {
      return <LoadingSpinner />;
    }
    
    switch (experimentData?.variantId) {
      case 'variant_a':
        return <PaywallVariantA config={experimentData.config} />;
      case 'variant_b':
        return <PaywallVariantB config={experimentData.config} />;
      default:
        return <PaywallControl config={experimentData.config} />;
    }
  };
  
  // Track experiment events
  const trackExperimentConversion = async (success: boolean) => {
    await fetch('/api/experiments/track', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        experimentId: experimentData.id,
        variantId: experimentData.variantId,
        event: success ? 'conversion' : 'abandoned',
      }),
    });
  };
  
  return {
    renderPaywall,
    trackExperimentConversion,
    variant: experimentData?.variantId || 'control',
  };
};
```

### Experiment Management API

```typescript
// Backend - Experiment Management
class ExperimentService {
  private database: DatabaseService;
  
  constructor() {
    this.database = new DatabaseService();
  }
  
  /**
   * Get experiment assignment for user
   */
  async getExperimentAssignment(
    userId: string,
    experimentId: string
  ): Promise<ExperimentAssignment> {
    // Check if user already has an assignment
    const existing = await this.database.getExperimentAssignment(userId, experimentId);
    if (existing) {
      return existing;
    }
    
    // Get experiment configuration
    const experiment = await this.database.getExperiment(experimentId);
    if (!experiment || experiment.status !== 'active') {
      return { variantId: 'control', config: {} };
    }
    
    // Assign user to a variant based on weight
    const variant = this.assignVariant(experiment.variants);
    
    // Store assignment
    const assignment = {
      userId,
      experimentId,
      variantId: variant.id,
      config: variant.config,
      assignedAt: new Date(),
    };
    
    await this.database.saveExperimentAssignment(assignment);
    
    return assignment;
  }
  
  /**
   * Assign variant based on weights
   */
  private assignVariant(variants: ExperimentVariant[]): ExperimentVariant {
    const totalWeight = variants.reduce((sum, v) => sum + v.weight, 0);
    let random = Math.random() * totalWeight;
    
    for (const variant of variants) {
      random -= variant.weight;
      if (random <= 0) {
        return variant;
      }
    }
    
    return variants[variants.length - 1];
  }
  
  /**
   * Track experiment event
   */
  async trackExperimentEvent(
    userId: string,
    experimentId: string,
    variantId: string,
    event: string
  ): Promise<void> {
    await this.database.logExperimentEvent({
      userId,
      experimentId,
      variantId,
      event,
      timestamp: new Date(),
    });
    
    // Update experiment statistics
    await this.updateExperimentStats(experimentId, variantId, event);
  }
}
```

---

## 4. Cross-Platform Synchronization

### Overview

RevenueCat enables seamless cross-platform synchronization, allowing users to access their subscriptions across iOS, Android, and web. This is critical for apps available on multiple platforms.

### Implementation

```typescript
// React Native - Cross-platform sync
class CrossPlatformManager {
  /**
   * Sync subscription across platforms
   * Uses the same AppUserID across all platforms
   */
  async syncSubscription(userId: string, platform: 'ios' | 'android' | 'web') {
    try {
      // Set the same AppUserID on all platforms
      await Purchases.setAppUserID(userId);
      
      // CustomerInfo will be identical across platforms
      const customerInfo = await Purchases.getCustomerInfo();
      
      console.log(`✅ Subscription synced for ${platform}:`, {
        userId,
        platform,
        entitlements: Object.keys(customerInfo.entitlements.active),
      });
      
      return customerInfo;
      
    } catch (error) {
      console.error(`Failed to sync subscription for ${platform}:`, error);
      throw error;
    }
  }
  
  /**
   * Handle platform migration
   * User moves from one platform to another with an active subscription
   */
  async handlePlatformMigration(
    oldUserId: string,
    newUserId: string,
    fromPlatform: 'ios' | 'android' | 'web',
    toPlatform: 'ios' | 'android' | 'web'
  ) {
    try {
      // Get subscription info from old platform
      const oldInfo = await fetch(`https://api.revenuecat.com/v1/subscribers/${oldUserId}`, {
        headers: {
          'Authorization': `Bearer ${process.env.REVENUECAT_SECRET_API_KEY}`,
        },
      }).then(res => res.json());
      
      const hasActiveSubscription = Object.keys(
        oldInfo.subscriber.entitlements.active
      ).length > 0;
      
      if (!hasActiveSubscription) {
        console.log('No active subscription to migrate');
        return;
      }
      
      // Migrate to new platform
      // Set the same AppUserID on the new platform
      await Purchases.setAppUserID(newUserId);
      
      console.log(`✅ Subscription migrated from ${fromPlatform} to ${toPlatform}`, {
        oldUserId,
        newUserId,
        platforms: [fromPlatform, toPlatform],
      });
      
    } catch (error) {
      console.error('Platform migration failed:', error);
      throw error;
    }
  }
}
```

### Server-Side Sync

```typescript
// Backend - Cross-platform sync endpoint
const syncSubscriptions = async (req: Request, res: Response) => {
  const { userId, platform } = req.body;
  
  try {
    // Get subscriber from RevenueCat
    const subscriber = await fetchSubscriber(userId);
    const activeEntitlements = subscriber.subscriber.entitlements.active;
    const hasSubscription = Object.keys(activeEntitlements).length > 0;
    
    // Update user status in your database
    await db.updateUser({
      id: userId,
      subscriptionStatus: hasSubscription ? 'premium' : 'free',
      subscriptionPlatform: platform,
      entitlements: activeEntitlements,
      lastSync: new Date(),
    });
    
    // If premium, ensure user has premium access in your system
    if (hasSubscription) {
      await grantPremiumAccess(userId);
    } else {
      await revokePremiumAccess(userId);
    }
    
    res.json({
      success: true,
      hasSubscription,
      entitlements: activeEntitlements,
      platform,
    });
    
  } catch (error) {
    console.error('Sync failed:', error);
    res.status(500).json({ error: 'Sync failed' });
  }
};
```

---

## 5. Advanced Webhook Handling

### Overview

Advanced webhook handling includes sophisticated error handling, retry logic, and event processing patterns that ensure reliability and data integrity.

### Implementation

```typescript
// Advanced Webhook Handler
class AdvancedWebhookHandler {
  private database: DatabaseService;
  private eventQueue: EventQueue;
  
  constructor() {
    this.database = new DatabaseService();
    this.eventQueue = new EventQueue();
  }
  
  /**
   * Process webhook with advanced features
   */
  async processWebhook(event: WebhookEvent): Promise<void> {
    // 1. Verify signature
    if (!this.verifySignature(event)) {
      throw new Error('Invalid signature');
    }
    
    // 2. Check idempotency
    const processed = await this.checkIdempotency(event.id);
    if (processed) {
      console.log(`Event ${event.id} already processed, skipping`);
      return;
    }
    
    // 3. Validate event data
    if (!this.validateEvent(event)) {
      throw new Error('Invalid event data');
    }
    
    // 4. Process event in transaction
    const transaction = await this.database.beginTransaction();
    
    try {
      // Process event
      await this.processEvent(event, transaction);
      
      // Mark as processed
      await this.markProcessed(event.id, transaction);
      
      // Commit transaction
      await transaction.commit();
      
      // 5. Trigger side effects
      await this.triggerSideEffects(event);
      
    } catch (error) {
      // Rollback transaction
      await transaction.rollback();
      
      // Log error
      await this.logError(event, error);
      
      // Retry or escalate
      await this.handleError(event, error);
    }
  }
  
  /**
   * Process event with side effects
   */
  private async processEvent(
    event: WebhookEvent,
    transaction: any
  ): Promise<void> {
    // Update subscription status
    await this.updateSubscriptionStatus(event, transaction);
    
    // Update user status
    await this.updateUserStatus(event, transaction);
    
    // Record history
    await this.recordHistory(event, transaction);
    
    // Update analytics
    await this.updateAnalytics(event, transaction);
  }
  
  /**
   * Trigger side effects
   */
  private async triggerSideEffects(event: WebhookEvent): Promise<void> {
    // Send notifications
    await this.sendNotifications(event);
    
    // Update auth system (Firebase, Auth0, etc.)
    await this.updateAuthSystem(event);
    
    // Update CRM
    await this.updateCRM(event);
    
    // Trigger email campaigns
    await this.triggerEmailCampaigns(event);
  }
  
  /**
   * Handle errors with retry
   */
  private async handleError(event: WebhookEvent, error: Error): Promise<void> {
    const retryCount = event.retryCount || 0;
    const maxRetries = 5;
    
    if (retryCount < maxRetries) {
      // Retry with exponential backoff
      const delay = Math.pow(2, retryCount) * 1000;
      await this.enqueueRetry(event, delay);
      
      console.log(`Event ${event.id} retry scheduled in ${delay}ms`);
      
    } else {
      // Escalate to manual intervention
      await this.escalateEvent(event, error);
      
      console.error(`Event ${event.id} failed after ${maxRetries} retries`);
    }
  }
  
  /**
   * Idempotency check
   */
  private async checkIdempotency(eventId: string): Promise<boolean> {
    const processed = await this.database.getProcessedEvent(eventId);
    return processed !== null;
  }
}
```

---

## 6. Performance Optimization

### Overview

Advanced performance optimization techniques for RevenueCat integration, ensuring fast, responsive subscription experiences.

### Implementation

```typescript
// Performance Optimization Service
class PerformanceOptimizationService {
  private cache: CacheService;
  private metrics: MetricsService;
  
  constructor() {
    this.cache = new CacheService();
    this.metrics = new MetricsService();
  }
  
  /**
   * Optimized customer info fetching
   */
  async getOptimizedCustomerInfo(userId: string): Promise<CustomerInfo> {
    // Start timing
    const startTime = Date.now();
    
    // Check cache first
    const cacheKey = `customer_info:${userId}`;
    const cached = await this.cache.get(cacheKey);
    
    if (cached && !this.isStale(cached)) {
      // Cache hit
      this.metrics.track('cache_hit', { type: 'customer_info' });
      return cached;
    }
    
    // Cache miss - fetch from RevenueCat
    try {
      const customerInfo = await Purchases.getCustomerInfo();
      
      // Cache with TTL
      await this.cache.set(cacheKey, customerInfo, 60); // 1 minute cache
      
      // Track performance
      const duration = Date.now() - startTime;
      this.metrics.track('customer_info_fetch', { duration });
      
      return customerInfo;
      
    } catch (error) {
      // If fetch fails, return stale cache if available
      if (cached) {
        this.metrics.track('cache_fallback', { type: 'customer_info' });
        return cached;
      }
      throw error;
    }
  }
  
  /**
   * Batch offering fetching
   */
  async getOptimizedOfferings(userId: string): Promise<Offerings> {
    const cacheKey = `offerings:${userId}`;
    const cached = await this.cache.get(cacheKey);
    
    if (cached && !this.isStale(cached)) {
      return cached;
    }
    
    // Fetch only if needed
    const offerings = await Purchases.getOfferings();
    
    // Cache with longer TTL (offerings change less frequently)
    await this.cache.set(cacheKey, offerings, 300); // 5 minute cache
    
    return offerings;
  }
  
  /**
   * Check if cached data is stale
   */
  private isStale(cached: any): boolean {
    if (!cached) return true;
    if (!cached._timestamp) return true;
    
    const age = Date.now() - cached._timestamp;
    const staleThreshold = 60000; // 1 minute
    
    return age > staleThreshold;
  }
  
  /**
   * Prefetch customer info
   */
  async prefetchCustomerInfo(userId: string): Promise<void> {
    // Prefetch in background for authenticated users
    try {
      const customerInfo = await Purchases.getCustomerInfo();
      
      // Cache aggressively
      await this.cache.set(
        `customer_info:${userId}`,
        customerInfo,
        300 // 5 minute cache
      );
      
      console.log('Customer info prefetched successfully');
      
    } catch (error) {
      // Prefetch failure is non-critical
      console.warn('Customer info prefetch failed:', error);
    }
  }
}
```

---

## 7. RevenueCat Paywalls (Beta)

### Overview

RevenueCat Paywalls is a new feature that allows you to create and manage paywalls directly in the RevenueCat dashboard, without needing to update your app. This enables rapid iteration and A/B testing.

### Features

| Feature | Description |
|---------|-------------|
| **No-Code Editor** | Drag-and-drop paywall builder |
| **Remote Configuration** | Update paywalls without app release |
| **A/B Testing** | Test multiple paywall variants |
| **Localization** | Support for multiple languages |
| **Analytics** | Built-in paywall performance metrics |

### Implementation

```typescript
// React Native - RevenueCat Paywalls
const RevenueCatPaywall = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [paywall, setPaywall] = useState<PaywallResponse | null>(null);
  
  useEffect(() => {
    const fetchPaywall = async () => {
      setIsLoading(true);
      try {
        // Fetch paywall configuration from RevenueCat
        const response = await Purchases.getOfferings();
        const offering = response.current;
        
        if (offering) {
          // Paywall configuration is included in the offering
          const paywallConfig = offering.paywall;
          
          if (paywallConfig) {
            setPaywall({
              template: paywallConfig.template,
              colors: paywallConfig.colors,
              assets: paywallConfig.assets,
              text: paywallConfig.text,
              packages: offering.availablePackages,
            });
          } else {
            // Fallback to local paywall
            setPaywall({ template: 'default', packages: offering.availablePackages });
          }
        }
      } catch (error) {
        console.error('Failed to fetch paywall:', error);
        // Fallback to default paywall
        setPaywall({ template: 'default', packages: [] });
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchPaywall();
  }, []);
  
  if (isLoading) {
    return <LoadingSpinner />;
  }
  
  if (!paywall) {
    return <DefaultPaywall />;
  }
  
  // Render paywall based on configuration
  return <DynamicPaywall config={paywall} />;
};
```

---

## Summary

This appendix covers advanced RevenueCat features:

1. **Virtual Currencies**: Monetize consumable features
2. **Promotional Offers**: Targeted discounts and incentives
3. **RevenueCat Experiments**: A/B testing for optimization
4. **Cross-Platform Sync**: Seamless user experience across platforms
5. **Advanced Webhooks**: Reliable event processing
6. **Performance Optimization**: Fast, efficient integration
7. **RevenueCat Paywalls**: Remote paywall management

### Key Takeaways

1. **Virtual Currencies** enable new revenue streams
2. **Promotional Offers** improve conversion
3. **Experiments** drive data-driven decisions
4. **Cross-Platform** sync ensures user retention
5. **Webhooks** power your backend integrations
6. **Performance** is critical for user experience
7. **Paywalls** can be managed remotely
