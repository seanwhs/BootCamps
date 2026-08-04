# Appendix D: Troubleshooting Common Issues

## Overview

This appendix provides a comprehensive troubleshooting guide for common issues encountered when integrating RevenueCat and building subscription-based applications. Each issue includes symptoms, root causes, solutions, and prevention strategies.

Think of this as your "diagnostic manual" – when something goes wrong, use this reference to quickly identify and fix the issue.

---

## Issue 1: SDK Initialization Fails

### Symptoms
- App crashes on launch
- "API key invalid" error
- "Configuration failed" error
- SDK methods return null/undefined

### Root Causes

| Cause | Description |
|-------|-------------|
| **Invalid API Key** | Using a sandbox API key in production or vice versa |
| **Incorrect Platform** | Using iOS API key on Android or vice versa |
| **Missing Configuration** | Required parameters not provided |
| **Network Blocked** | RevenueCat API endpoints unreachable |
| **Version Mismatch** | SDK version incompatible with React Native/Flutter |

### Solutions

#### Verify API Key

```typescript
// Check API key format
const isValidApiKey = (key: string) => {
  // Public API keys start with 'app_'
  // Secret API keys start with 'sk_'
  // Webhook keys start with 'wh_'
  return key.startsWith('app_') || 
         key.startsWith('sk_') || 
         key.startsWith('wh_');
};

// Example: Check before configuration
if (!isValidApiKey(apiKey)) {
  console.error('Invalid API key format:', apiKey);
  return;
}
```

#### Platform-Specific Configuration

```typescript
// React Native - platform-specific API keys
import { Platform } from 'react-native';

const getApiKey = () => {
  switch (Platform.OS) {
    case 'ios':
      return process.env.REVENUECAT_IOS_API_KEY;
    case 'android':
      return process.env.REVENUECAT_ANDROID_API_KEY;
    default:
      throw new Error('Unsupported platform');
  }
};

// Use Platform-specific keys
Purchases.configure({
  apiKey: getApiKey(),
  // ...
});
```

#### Network Debugging

```bash
# Check if RevenueCat is reachable
curl -I https://api.revenuecat.com/v1/health

# Check for DNS issues
nslookup api.revenuecat.com

# Check network connectivity from device
# Use Charles Proxy or similar to inspect traffic
```

#### SDK Version Compatibility

```json
// package.json - ensure compatible versions
{
  "dependencies": {
    "react-native": "0.72.0",
    "react-native-purchases": "^7.0.0",
    "@react-native-async-storage/async-storage": "^1.19.6"
  }
}
```

### Prevention

1. **Use Environment Variables**: Never hardcode API keys
2. **Version Locking**: Use exact versions in package.json
3. **Fallback UI**: Show error screen with retry option
4. **Health Checks**: Implement API health check on startup
5. **Logging**: Enable verbose logging during development

---

## Issue 2: Offerings Not Loading

### Symptoms
- `offerings.current` is null
- Empty packages array
- Packages show incorrect pricing
- Offering fetch times out

### Root Causes

| Cause | Description |
|-------|-------------|
| **Products Not Configured** | Products not created in RevenueCat dashboard |
| **Store Products Missing** | Products not created in App Store Connect/Play Console |
| **Entitlement Misconfiguration** | Products not linked to entitlements |
| **Network Issues** | Unable to reach RevenueCat API |
| **Cache Stale** | Local cache outdated |

### Solutions

#### Verify RevenueCat Configuration

```typescript
// Check if offerings exist
const checkOfferings = async () => {
  try {
    const offerings = await Purchases.getOfferings();
    
    if (!offerings) {
      console.error('No offerings returned');
      return false;
    }
    
    if (!offerings.current) {
      console.warn('No current offering available');
      console.log('Available offerings:', Object.keys(offerings.all));
      return false;
    }
    
    if (offerings.current.availablePackages.length === 0) {
      console.error('No packages in current offering');
      return false;
    }
    
    console.log('✅ Offerings loaded successfully');
    console.log('Packages:', offerings.current.availablePackages.map(p => p.identifier));
    return true;
    
  } catch (error) {
    console.error('Failed to fetch offerings:', error);
    return false;
  }
};
```

#### Force Refresh Cache

```typescript
// Invalidate cache to force refresh
const refreshOfferings = async () => {
  Purchases.invalidateOfferingsCache();
  const offerings = await Purchases.getOfferings();
  return offerings;
};
```

#### Check Store Product Configuration

```bash
# Check if products exist in App Store Connect
# 1. Log in to App Store Connect
# 2. Navigate to your app → Features → Subscriptions
# 3. Verify products are in "Ready to Submit" or "Approved" status

# Check if products exist in Google Play Console
# 1. Log in to Google Play Console
# 2. Navigate to your app → Products → Subscriptions
# 3. Verify products are "Active" status
```

#### Fallback Strategy

```typescript
const getOfferingsWithFallback = async () => {
  try {
    // Attempt to fetch offerings
    const offerings = await Purchases.getOfferings();
    
    if (offerings.current && offerings.current.availablePackages.length > 0) {
      return offerings.current;
    }
    
    // Fallback 1: Try to get any available offering
    const allOfferings = Object.values(offerings.all);
    for (const offering of allOfferings) {
      if (offering.availablePackages.length > 0) {
        console.warn('Using fallback offering:', offering.identifier);
        return offering;
      }
    }
    
    // Fallback 2: Fetch products by ID directly
    const productIds = [
      'com.yourcompany.fittrackpro.monthly',
      'com.yourcompany.fittrackpro.annual'
    ];
    const products = await Purchases.getProducts(productIds, 'subscription');
    
    if (products.length > 0) {
      // Manually construct packages
      // Note: This is less flexible but works as a last resort
      console.warn('Using fallback products');
      return {
        availablePackages: products.map(p => ({
          identifier: p.productIdentifier,
          product: p,
          // ... other package properties
        })),
        // ... other offering properties
      };
    }
    
    // No offerings or products available
    console.error('No offerings or products available');
    return null;
    
  } catch (error) {
    console.error('Error fetching offerings:', error);
    return null;
  }
};
```

### Prevention

1. **Dashboard Verification**: Regularly check RevenueCat dashboard
2. **Monitoring**: Set up alerts for offering fetch failures
3. **Caching**: Maintain fallback cache of last known offerings
4. **Testing**: Test with both sandbox and production configurations
5. **Documentation**: Document all product IDs and configurations

---

## Issue 3: Purchases Not Completing

### Symptoms
- User cancels and error is not handled
- Purchase succeeds but entitlements not granted
- Transaction stuck in pending state
- "Product not available" error
- User charged but no subscription

### Root Causes

| Cause | Description |
|-------|-------------|
| **Sandbox vs Production** | Mixing sandbox and production environments |
| **Missing Receipt** | Receipt validation failure |
| **Product ID Mismatch** | Product IDs don't match RevenueCat configuration |
| **Network Issues** | Network failure during purchase flow |
| **Pending Transactions** | Previous transaction not completed |

### Solutions

#### Purchase Error Handling

```typescript
const handlePurchase = async (packageToPurchase: Package) => {
  try {
    const result = await Purchases.purchasePackage(packageToPurchase);
    return result;
    
  } catch (error) {
    // Specific error handling
    switch (error.code) {
      case 'PURCHASE_CANCELLED':
        // User cancelled - don't show error dialog
        console.log('Purchase cancelled by user');
        break;
        
      case 'PRODUCT_NOT_AVAILABLE':
        // Product not available
        showUserError('This product is not currently available');
        break;
        
      case 'PURCHASE_NOT_ALLOWED':
        // In-app purchases not allowed
        showUserError('In-app purchases are not allowed on this device');
        break;
        
      case 'NETWORK_ERROR':
        // Network issue
        showUserError('Network error. Please check your connection.');
        break;
        
      default:
        // Unknown error
        showUserError('Purchase failed. Please try again.');
        break;
    }
    
    // Log error for monitoring
    logError(error, { context: 'purchase' });
  }
};
```

#### Transaction Verification

```typescript
// Verify transaction after purchase
const verifyPurchase = async (transactionId: string) => {
  try {
    // Call your backend to verify receipt
    const response = await fetch('/api/verify-purchase', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ transactionId }),
    });
    
    const result = await response.json();
    
    if (result.verified) {
      // Grant entitlements
      await grantEntitlements(result.userId, result.entitlements);
      return true;
    } else {
      console.error('Purchase verification failed:', result.error);
      return false;
    }
    
  } catch (error) {
    console.error('Verification error:', error);
    return false;
  }
};
```

#### Debugging Pending Transactions

```typescript
// iOS only - handle pending transactions
const checkPendingTransactions = () => {
  // Check if there are any pending transactions
  Purchases.getCustomerInfo().then(customerInfo => {
    // Check if user has pending purchases
    // This is platform-specific
  });
};
```

#### Sandbox Account Setup

```bash
# iOS Sandbox Testing
# 1. Create sandbox tester in App Store Connect
# 2. Use sandbox tester account on device
# 3. Clear sandbox purchases before testing
# 4. Use StoreKit Configuration file

# Android Internal Testing
# 1. Create test account in Google Play Console
# 2. Add test account to internal testing track
# 3. Install app from internal testing URL
# 4. Use test credit card for purchases
```

### Prevention

1. **Test Thoroughly**: Test all purchase scenarios in sandbox
2. **Error Handling**: Implement comprehensive error handling
3. **Transaction Management**: Handle all transaction states
4. **Receipt Validation**: Always validate receipts server-side
5. **User Communication**: Clearly communicate purchase status

---

## Issue 4: Entitlements Not Granted

### Symptoms
- User purchases but features remain locked
- Entitlements not appearing in CustomerInfo
- Active entitlements list is empty
- Feature gating not working

### Root Causes

| Cause | Description |
|-------|-------------|
| **Configuration Issues** | Products not linked to entitlements in RevenueCat |
| **Cache Issues** | CustomerInfo cache not updated |
| **Refresh Delay** | Entitlements not immediately available |
| **Platform Issues** | Store-specific issues |

### Solutions

#### Verify Configuration

```typescript
// Check entitlement configuration
const checkEntitlementConfig = async (entitlementId: string) => {
  const customerInfo = await Purchases.getCustomerInfo();
  const entitlement = customerInfo.entitlements.active[entitlementId];
  
  if (entitlement) {
    console.log('✅ Entitlement active:', {
      id: entitlementId,
      productId: entitlement.productIdentifier,
      expirationDate: entitlement.expirationDate,
      willRenew: entitlement.willRenew,
    });
    return true;
  } else {
    console.warn('❌ Entitlement not active:', entitlementId);
    return false;
  }
};
```

#### Force Refresh CustomerInfo

```typescript
const refreshEntitlements = async () => {
  // Invalidate cache
  Purchases.invalidateCustomerInfoCache();
  
  // Fetch fresh data
  const customerInfo = await Purchases.getCustomerInfo();
  
  // Check active entitlements
  const activeEntitlements = Object.keys(customerInfo.entitlements.active);
  console.log('Active entitlements:', activeEntitlements);
  
  return customerInfo;
};
```

#### Entitlement Listener

```typescript
// Set up listener for real-time updates
const setupEntitlementListener = () => {
  const listener = Purchases.addCustomerInfoUpdateListener((customerInfo) => {
    const activeEntitlements = Object.keys(customerInfo.entitlements.active);
    
    if (activeEntitlements.length > 0) {
      console.log('🎉 Entitlements granted:', activeEntitlements);
      
      // Update UI / Unlock features
      unlockPremiumFeatures(activeEntitlements);
    } else {
      console.log('No active entitlements');
      
      // Lock premium features
      lockPremiumFeatures();
    }
  });
  
  return listener;
};
```

#### Manual Restoration

```typescript
// Allow users to manually restore entitlements
const restoreEntitlements = async () => {
  try {
    const customerInfo = await Purchases.restorePurchases();
    const activeEntitlements = Object.keys(customerInfo.entitlements.active);
    
    if (activeEntitlements.length > 0) {
      showSuccess(`Restored: ${activeEntitlements.join(', ')}`);
    } else {
      showInfo('No purchases found to restore');
    }
    
    return customerInfo;
    
  } catch (error) {
    showError('Failed to restore purchases');
    console.error('Restore error:', error);
  }
};
```

### Prevention

1. **Dashboard Verification**: Check RevenueCat dashboard for entitlement mapping
2. **Testing**: Test entitlement granting in sandbox
3. **Listener Setup**: Always set up CustomerInfo listeners
4. **Restore Option**: Always provide restore option
5. **Fallback UI**: Show appropriate UI when no entitlements

---

## Issue 5: Webhook Integration Issues

### Symptoms
- Webhooks not received
- Signature verification fails
- Duplicate events
- Missing events

### Root Causes

| Cause | Description |
|-------|-------------|
| **URL Misconfiguration** | Webhook URL not set correctly |
| **Signature Issues** | Signature verification failing |
| **Network Issues** | Firewall blocking requests |
| **Duplicate Processing** | Idempotency not implemented |
| **Timeouts** | Webhook endpoint taking too long |

### Solutions

#### Test Webhook Endpoint

```typescript
// Test endpoint with sample webhook
const testWebhookEndpoint = async () => {
  const testPayload = {
    type: 'INITIAL_PURCHASE',
    id: 'test-event-123',
    subscriber_id: 'test-user-123',
    product_id: 'com.test.product',
    // ... other required fields
  };
  
  try {
    const response = await fetch('https://api.fittrackpro.com/webhook/revenuecat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Webhook-Signature': generateTestSignature(testPayload),
      },
      body: JSON.stringify(testPayload),
    });
    
    const result = await response.json();
    console.log('Webhook test result:', result);
    return response.status === 200;
    
  } catch (error) {
    console.error('Webhook test failed:', error);
    return false;
  }
};
```

#### Signature Verification

```typescript
// Verify webhook signature
const verifyWebhookSignature = (body: any, signature: string): boolean => {
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
  if (!secret) {
    console.error('Webhook secret not configured');
    return false;
  }
  
  try {
    const bodyString = JSON.stringify(body);
    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(bodyString)
      .digest('hex');
    
    // Constant-time comparison to prevent timing attacks
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expectedSignature)
    );
    
  } catch (error) {
    console.error('Signature verification error:', error);
    return false;
  }
};
```

#### Idempotency Implementation

```typescript
// Database with idempotency key
interface WebhookEvent {
  id: string;
  eventId: string;
  type: string;
  processed: boolean;
  processedAt?: Date;
  attempts: number;
  data: any;
}

// Process webhook with idempotency
const processWebhook = async (event: RevenueCatEvent) => {
  // Check if event already processed
  const existing = await db.webhookEvents.findOne({ eventId: event.id });
  
  if (existing && existing.processed) {
    console.log('Duplicate webhook event, skipping:', event.id);
    return { processed: true, duplicate: true };
  }
  
  if (existing) {
    // Update attempts
    await db.webhookEvents.updateOne(
      { eventId: event.id },
      { $inc: { attempts: 1 } }
    );
  } else {
    // Store new event
    await db.webhookEvents.insertOne({
      eventId: event.id,
      type: event.type,
      processed: false,
      attempts: 1,
      data: event,
      createdAt: new Date(),
    });
  }
  
  // Process event
  try {
    await processEvent(event);
    
    // Mark as processed
    await db.webhookEvents.updateOne(
      { eventId: event.id },
      { 
        $set: { 
          processed: true, 
          processedAt: new Date() 
        } 
      }
    );
    
    return { processed: true, duplicate: false };
    
  } catch (error) {
    console.error('Event processing failed:', error);
    
    // Retry logic will handle it
    throw error;
  }
};
```

#### Webhook Retry Logic

```typescript
// Implement retry with exponential backoff
const processWithRetry = async (
  event: RevenueCatEvent,
  maxRetries: number = 5
) => {
  let attempts = 0;
  let delay = 1000; // Start with 1 second
  
  while (attempts < maxRetries) {
    try {
      await processWebhook(event);
      return;
      
    } catch (error) {
      attempts++;
      
      if (attempts >= maxRetries) {
        console.error('Max retries reached, giving up:', event.id);
        // Alert team
        await alertTeam('Webhook processing failed', { eventId: event.id });
        return;
      }
      
      console.log(`Retry ${attempts}/${maxRetries}, waiting ${delay}ms`);
      await new Promise(resolve => setTimeout(resolve, delay));
      delay *= 2; // Exponential backoff
    }
  }
};
```

### Prevention

1. **Logging**: Log all webhook events for debugging
2. **Monitoring**: Alert on webhook failures
3. **Testing**: Test webhook endpoints thoroughly
4. **Idempotency**: Always implement idempotency
5. **Documentation**: Document webhook configuration

---

## Issue 6: Performance Issues

### Symptoms
- Slow app launch
- UI stuttering
- Memory leaks
- Battery drain
- Network usage high

### Root Causes

| Cause | Description |
|-------|-------------|
| **Excessive Calls** | Too many RevenueCat API calls |
| **Caching Issues** | Not using cached data properly |
| **Memory Leaks** | Listener not removed |
| **Large Bundles** | Unoptimized bundle size |

### Solutions

#### Optimize API Calls

```typescript
// Batch RevenueCat calls
const getBatchData = async () => {
  // Call once and reuse
  const customerInfo = await Purchases.getCustomerInfo();
  const offerings = await Purchases.getOfferings();
  
  // Use cached data where possible
  // Only refresh when needed
};

// Use caching
const getCachedCustomerInfo = async () => {
  // Try cache first
  const cached = await getFromCache('customer_info');
  if (cached && !isStale(cached)) {
    return cached;
  }
  
  // Fetch fresh
  const fresh = await Purchases.getCustomerInfo();
  await saveToCache('customer_info', fresh);
  return fresh;
};
```

#### Remove Listeners Properly

```typescript
// React Native - proper listener cleanup
useEffect(() => {
  const listener = Purchases.addCustomerInfoUpdateListener((info) => {
    // Update state
  });
  
  // Cleanup on unmount
  return () => {
    listener.remove();
  };
}, []);
```

#### Optimize Bundle Size

```typescript
// Use lazy loading for screens
const LazyPaywall = React.lazy(() => import('./PaywallScreen'));
const LazyMainApp = React.lazy(() => import('./MainAppScreen'));

// Use minified production builds
// Remove unused dependencies
// Use tree shaking
```

#### Performance Monitoring

```typescript
// Track performance metrics
const trackPerformance = () => {
  // App startup time
  performance.mark('appStart');
  
  // Paywall load time
  const paywallLoadStart = Date.now();
  // ... load paywall
  const paywallLoadTime = Date.now() - paywallLoadStart;
  
  // Log metrics
  console.log('Paywall load time:', paywallLoadTime, 'ms');
  
  // Send to analytics
  analytics.track('performance_metric', {
    name: 'paywall_load_time',
    value: paywallLoadTime,
  });
};
```

### Prevention

1. **Optimize Caching**: Use cached data effectively
2. **Listener Management**: Always remove listeners
3. **Bundle Optimization**: Use code splitting
4. **Performance Testing**: Regularly test performance
5. **Monitoring**: Track performance metrics

---

## Issue 7: Platform-Specific Issues

### iOS-Specific

#### Issue: App Store Sandbox Not Working

**Symptoms**: Sandbox purchases fail, sandbox accounts not recognized

**Solutions**:

```bash
# Clear sandbox cache
# 1. Delete app from device
# 2. Go to Settings → iTunes & App Stores → Apple ID → Sign Out
# 3. Reset device or wait 24 hours
# 4. Reinstall app and sign in with sandbox account
```

```swift
// Check sandbox environment
if Purchases.isSandbox {
    print("Running in sandbox environment")
} else {
    print("Running in production environment")
}
```

#### Issue: StoreKit Configuration Not Working

**Solutions**:

1. Verify `.storekit` file is in project
2. Check configuration target membership
3. Use correct scheme for testing
4. Enable StoreKit in capabilities

### Android-Specific

#### Issue: Google Play Billing Not Working

**Solutions**:

```bash
# Check billing permission in manifest
# <uses-permission android:name="com.android.vending.BILLING" />

# Check Google Play Services
# Ensure Google Play Services are up to date

# Test with internal testing track
# Use test accounts for purchase testing
```

```kotlin
// Force refresh of Google Play Billing
Purchases.sharedInstance.setUpdatedCustomerInfoListener { customerInfo ->
    // Update UI
}
```

---

## Issue 8: User Identity & Migration Issues

### Symptoms
- Purchases not following user across devices
- Account migration fails
- Duplicate accounts
- Anonymous purchases not transferring

### Root Causes

| Cause | Description |
|-------|-------------|
| **Wrong AppUserID** | User ID not set or mismatched |
| **Timing Issues** | AppUserID set after purchases |
| **Multiple Users** | Multiple users on same device |
| **Cache Issues** | Identity cache not updated |

### Solutions

#### Proper AppUserID Management

```typescript
// Set AppUserID on login
const handleLogin = async (userId: string) => {
  try {
    await Purchases.setAppUserID(userId);
    const customerInfo = await Purchases.getCustomerInfo();
    
    // Check if user has active subscriptions
    const hasSubscriptions = Object.keys(customerInfo.entitlements.active).length > 0;
    
    if (hasSubscriptions) {
      console.log('User has active subscriptions:', userId);
    }
    
  } catch (error) {
    console.error('Failed to set AppUserID:', error);
  }
};
```

#### Anonymous to Authenticated Migration

```typescript
// Handle migration from anonymous to authenticated
const handleUserMigration = async (newUserId: string) => {
  try {
    // Get current anonymous user info
    const anonymousInfo = await Purchases.getCustomerInfo();
    const hasAnonymousPurchases = Object.keys(anonymousInfo.entitlements.active).length > 0;
    
    if (hasAnonymousPurchases) {
      // Store anonymous user ID before switching
      const anonymousId = anonymousInfo.originalAppUserId;
      console.log('Migrating from anonymous user:', anonymousId);
      
      // Set new user ID - purchases will transfer
      await Purchases.setAppUserID(newUserId);
      
      // Verify migration
      const newInfo = await Purchases.getCustomerInfo();
      const hasMigratedPurchases = Object.keys(newInfo.entitlements.active).length > 0;
      
      if (hasMigratedPurchases) {
        console.log('✅ Migration successful');
        return true;
      } else {
        console.warn('Migration might have failed, purchases not found');
        // Show restore option to user
        return false;
      }
    } else {
      // No anonymous purchases, just set the user ID
      await Purchases.setAppUserID(newUserId);
      return true;
    }
    
  } catch (error) {
    console.error('Migration failed:', error);
    throw error;
  }
};
```

### Prevention

1. **Consistent IDs**: Use consistent AppUserID format
2. **Migration Flow**: Implement proper migration flow
3. **Restore Option**: Always provide restore option
4. **Testing**: Test migration scenarios
5. **Logging**: Log identity changes

---

## Quick Reference: Error Codes

### RevenueCat SDK Error Codes

| Code | Description | Action |
|------|-------------|--------|
| `PURCHASE_CANCELLED` | User cancelled | Show message, no retry |
| `PRODUCT_NOT_AVAILABLE` | Product unavailable | Show message |
| `PURCHASE_NOT_ALLOWED` | IAP disabled | Show settings message |
| `NETWORK_ERROR` | Network issue | Retry with backoff |
| `INVALID_CREDENTIALS` | API key invalid | Check configuration |
| `RECEIPT_ALREADY_IN_USE` | Receipt used | Show message |
| `UNKNOWN` | Unknown error | Show generic message |

### HTTP Status Codes

| Code | Description | Action |
|------|-------------|--------|
| 200 | OK | Success |
| 400 | Bad Request | Check request format |
| 401 | Unauthorized | Check API key |
| 403 | Forbidden | Check permissions |
| 404 | Not Found | Check endpoint |
| 429 | Too Many Requests | Implement rate limiting |
| 500 | Internal Server Error | Contact support |

---

## Summary

This troubleshooting guide covers the most common issues encountered when working with RevenueCat:

1. **SDK Initialization**: API keys, configuration, platform issues
2. **Offerings**: Product configuration, caching, fallbacks
3. **Purchases**: Error handling, sandbox issues, pending transactions
4. **Entitlements**: Granting issues, refreshing, restoration
5. **Webhooks**: Configuration, signatures, idempotency
6. **Performance**: Optimization, caching, memory management
7. **Platform-Specific**: iOS and Android unique issues
8. **User Identity**: Migration, AppUserID management

### Troubleshooting Best Practices

1. **Enable Debug Logging**: Use `Purchases.setLogLevel(LOG_LEVEL.DEBUG)`
2. **Check Dashboard**: Verify configuration in RevenueCat dashboard
3. **Test Thoroughly**: Test in sandbox before production
4. **Monitor**: Set up monitoring and alerts
5. **Document**: Document known issues and solutions
