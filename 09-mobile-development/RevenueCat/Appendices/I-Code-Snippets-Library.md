# Appendix I: Code Snippets Library

## Overview

This appendix provides a comprehensive library of reusable code snippets for common RevenueCat operations. These snippets are organized by use case and include examples for React Native, iOS (Swift), Android (Kotlin), and Flutter.

Think of this as your "code cookbook" – when you need to perform a specific task, reference these battle-tested snippets.

---

## 1. Initialization & Configuration

### React Native

```typescript
import Purchases, { LOG_LEVEL, PurchasesConfiguration } from 'react-native-purchases';
import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Initialize RevenueCat SDK
 */
export const initializeRevenueCat = async (): Promise<void> => {
  try {
    // Set log level based on environment
    const logLevel = __DEV__ ? LOG_LEVEL.DEBUG : LOG_LEVEL.INFO;
    Purchases.setLogLevel(logLevel);
    
    // Get platform-specific API key
    const apiKey = Platform.select({
      ios: process.env.REVENUECAT_IOS_PUBLIC_API_KEY,
      android: process.env.REVENUECAT_ANDROID_PUBLIC_API_KEY,
    });
    
    if (!apiKey) {
      throw new Error('RevenueCat API key not configured');
    }
    
    // Check for stored user ID
    const storedUserId = await AsyncStorage.getItem('@app_user_id');
    
    // Configure SDK
    const config: PurchasesConfiguration = {
      apiKey,
      appUserID: storedUserId || undefined,
      verboseLogs: __DEV__,
      logLevel,
    };
    
    await Purchases.configure(config);
    
    console.log('✅ RevenueCat initialized successfully');
    
  } catch (error) {
    console.error('❌ RevenueCat initialization failed:', error);
    throw error;
  }
};

/**
 * Set up CustomerInfo listener
 */
export const setupCustomerInfoListener = (
  callback: (info: CustomerInfo) => void
): () => void => {
  const listener = Purchases.addCustomerInfoUpdateListener(callback);
  return listener.remove;
};
```

### iOS (Swift)

```swift
import RevenueCat

class RevenueCatManager {
    static let shared = RevenueCatManager()
    
    private init() {}
    
    func configure() {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .info
        #endif
        
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String ?? ""
        
        Purchases.configure(
            withAPIKey: apiKey,
            appUserID: UserDefaults.standard.string(forKey: "user_id")
        )
        
        print("✅ RevenueCat configured")
    }
    
    func setCustomerInfoListener() {
        Purchases.shared.delegate = self
    }
}

extension RevenueCatManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        NotificationCenter.default.post(
            name: .customerInfoUpdated,
            object: customerInfo
        )
    }
}

extension Notification.Name {
    static let customerInfoUpdated = Notification.Name("customerInfoUpdated")
}
```

### Android (Kotlin)

```kotlin
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.LogLevel
import com.revenuecat.purchases.PurchasesConfiguration
import android.content.Context
import android.content.SharedPreferences

object RevenueCatManager {
    private const val PREF_NAME = "revenuecat_prefs"
    private const val KEY_USER_ID = "user_id"
    
    fun configure(context: Context) {
        val logLevel = if (BuildConfig.DEBUG) LogLevel.DEBUG else LogLevel.INFO
        Purchases.logLevel = logLevel
        
        val apiKey = context.getString(R.string.revenuecat_api_key)
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val userId = prefs.getString(KEY_USER_ID, null)
        
        val config = PurchasesConfiguration.Builder(context, apiKey)
            .appUserID(userId)
            .build()
        
        Purchases.configure(config)
        
        println("✅ RevenueCat configured")
    }
    
    fun setCustomerInfoListener(context: Context) {
        Purchases.sharedInstance.setUpdatedCustomerInfoListener { customerInfo ->
            // Handle customer info update
            val intent = Intent(ACTION_CUSTOMER_INFO_UPDATED)
            intent.putExtra(EXTRA_CUSTOMER_INFO, customerInfo)
            context.sendBroadcast(intent)
        }
    }
}

const val ACTION_CUSTOMER_INFO_UPDATED = "com.example.ACTION_CUSTOMER_INFO_UPDATED"
const val EXTRA_CUSTOMER_INFO = "customer_info"
```

### Flutter (Dart)

```dart
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  Future<void> initialize() async {
    try {
      // Set log level
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.info
      );
      
      // Get API key from environment
      final apiKey = const String.fromEnvironment('REVENUECAT_API_KEY');
      
      // Check for stored user ID
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      // Configure
      final config = PurchasesConfiguration(apiKey)
        ..appUserId = userId;
      
      await Purchases.configure(config);
      
      print('✅ RevenueCat initialized');
      
    } catch (e) {
      print('❌ RevenueCat initialization failed: $e');
      rethrow;
    }
  }

  void setupCustomerInfoListener(Function(CustomerInfo) callback) {
    Purchases.addCustomerInfoUpdateListener(callback);
  }
}
```

---

## 2. Offerings & Products

### React Native

```typescript
import Purchases, { Offering, Package } from 'react-native-purchases';

/**
 * Fetch offerings with fallback
 */
export const fetchOfferings = async (): Promise<Offering | null> => {
  try {
    const offerings = await Purchases.getOfferings();
    const offering = offerings.current;
    
    if (offering && offering.availablePackages.length > 0) {
      console.log(`✅ Found ${offering.availablePackages.length} packages`);
      return offering;
    }
    
    // Fallback: try to find any offering
    const allOfferings = Object.values(offerings.all);
    for (const off of allOfferings) {
      if (off.availablePackages.length > 0) {
        console.log(`⚠️ Using fallback offering: ${off.identifier}`);
        return off;
      }
    }
    
    console.warn('❌ No offerings available');
    return null;
    
  } catch (error) {
    console.error('❌ Failed to fetch offerings:', error);
    return null;
  }
};

/**
 * Get package by identifier
 */
export const getPackageByIdentifier = (
  offering: Offering,
  identifier: string
): Package | undefined => {
  return offering.availablePackages.find(pkg => pkg.identifier === identifier);
};

/**
 * Get package by product ID
 */
export const getPackageByProductId = (
  offering: Offering,
  productId: string
): Package | undefined => {
  return offering.availablePackages.find(
    pkg => pkg.productIdentifier === productId
  );
};

/**
 * Get monthly and annual packages
 */
export const getSubscriptionPackages = (offering: Offering): {
  monthly: Package | null;
  annual: Package | null;
} => {
  const monthly = offering.availablePackages.find(
    pkg => pkg.packageType === 'MONTHLY' || pkg.identifier === 'monthly'
  );
  
  const annual = offering.availablePackages.find(
    pkg => pkg.packageType === 'ANNUAL' || pkg.identifier === 'annual'
  );
  
  return { monthly: monthly || null, annual: annual || null };
};
```

### iOS (Swift)

```swift
import RevenueCat

class OfferingsManager {
    static let shared = OfferingsManager()
    
    private var currentOffering: Offering?
    
    func fetchOfferings(completion: @escaping (Offering?) -> Void) {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print("❌ Failed to fetch offerings: \(error)")
                completion(nil)
                return
            }
            
            let offering = offerings?.current
            
            // Fallback to any offering if current is nil
            if offering == nil, let firstOffering = offerings?.all.first?.value {
                print("⚠️ Using fallback offering: \(firstOffering.identifier)")
                self.currentOffering = firstOffering
                completion(firstOffering)
                return
            }
            
            self.currentOffering = offering
            print("✅ Found \(offering?.availablePackages.count ?? 0) packages")
            completion(offering)
        }
    }
    
    func getPackage(for identifier: String) -> Package? {
        return currentOffering?.package(identifier: identifier)
    }
    
    func getMonthlyPackage() -> Package? {
        return currentOffering?.monthly
    }
    
    func getAnnualPackage() -> Package? {
        return currentOffering?.annual
    }
}
```

### Android (Kotlin)

```kotlin
import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.models.Offering

class OfferingsManager {
    private var currentOffering: Offering? = null
    
    fun fetchOfferings(callback: (Offering?) -> Unit) {
        Purchases.sharedInstance.getOfferingsWith { offerings, error ->
            if (error != null) {
                println("❌ Failed to fetch offerings: ${error.message}")
                callback(null)
                return@getOfferingsWith
            }
            
            var offering = offerings?.current
            
            // Fallback to any offering if current is null
            if (offering == null && offerings != null) {
                offering = offerings.all.values.firstOrNull()
                println("⚠️ Using fallback offering: ${offering?.identifier}")
            }
            
            currentOffering = offering
            println("✅ Found ${offering?.availablePackages?.size ?: 0} packages")
            callback(offering)
        }
    }
    
    fun getPackage(identifier: String): Package? {
        return currentOffering?.availablePackages?.find { it.identifier == identifier }
    }
    
    fun getMonthlyPackage(): Package? {
        return currentOffering?.availablePackages?.find { 
            it.packageType == Package.PackageType.MONTHLY 
        }
    }
    
    fun getAnnualPackage(): Package? {
        return currentOffering?.availablePackages?.find { 
            it.packageType == Package.PackageType.ANNUAL 
        }
    }
}
```

---

## 3. Purchases

### React Native

```typescript
import Purchases, { Package, CustomerInfo } from 'react-native-purchases';

/**
 * Purchase a package with error handling
 */
export const purchasePackage = async (
  packageToPurchase: Package
): Promise<{ customerInfo: CustomerInfo; success: boolean }> => {
  try {
    console.log(`🛒 Purchasing package: ${packageToPurchase.identifier}`);
    
    const { customerInfo } = await Purchases.purchasePackage(packageToPurchase);
    
    // Check if entitlements were granted
    const activeEntitlements = Object.keys(customerInfo.entitlements.active);
    
    if (activeEntitlements.length > 0) {
      console.log(`✅ Purchase successful! Entitlements: ${activeEntitlements.join(', ')}`);
      return { customerInfo, success: true };
    } else {
      console.warn('⚠️ Purchase completed but no entitlements granted');
      return { customerInfo, success: false };
    }
    
  } catch (error: any) {
    // Check if user cancelled
    if (error.code === 'PURCHASE_CANCELLED' || error.code === 'USER_CANCELLED') {
      console.log('🛑 Purchase cancelled by user');
      throw new Error('Purchase cancelled');
    }
    
    // Handle other errors
    console.error('❌ Purchase failed:', error);
    throw new Error(getUserFriendlyErrorMessage(error));
  }
};

/**
 * Restore purchases
 */
export const restorePurchases = async (): Promise<CustomerInfo> => {
  try {
    console.log('🔄 Restoring purchases...');
    const customerInfo = await Purchases.restorePurchases();
    
    const activeEntitlements = Object.keys(customerInfo.entitlements.active);
    
    if (activeEntitlements.length > 0) {
      console.log(`✅ Restored: ${activeEntitlements.join(', ')}`);
    } else {
      console.log('ℹ️ No purchases to restore');
    }
    
    return customerInfo;
    
  } catch (error) {
    console.error('❌ Restore failed:', error);
    throw new Error('Failed to restore purchases');
  }
};

/**
 * Get user-friendly error message
 */
const getUserFriendlyErrorMessage = (error: any): string => {
  const errorMessages: Record<string, string> = {
    'PURCHASE_CANCELLED': 'Purchase was cancelled',
    'PRODUCT_NOT_AVAILABLE': 'Product is not available',
    'PURCHASE_NOT_ALLOWED': 'In-app purchases not allowed',
    'NETWORK_ERROR': 'Please check your internet connection',
    'INVALID_CREDENTIALS': 'Configuration error',
    'RECEIPT_ALREADY_IN_USE': 'Purchase already used',
  };
  
  return errorMessages[error.code] || 'Purchase failed. Please try again.';
};
```

### iOS (Swift)

```swift
import RevenueCat

class PurchaseManager {
    static let shared = PurchaseManager()
    
    var purchaseCompletion: ((CustomerInfo?, Error?) -> Void)?
    
    func purchase(package: Package, completion: @escaping (CustomerInfo?, Error?) -> Void) {
        print("🛒 Purchasing package: \(package.identifier)")
        
        Purchases.shared.purchase(package: package) { transaction, customerInfo, error, userCancelled in
            if userCancelled {
                print("🛑 Purchase cancelled by user")
                completion(nil, NSError(domain: "PurchaseError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Purchase cancelled"
                ]))
                return
            }
            
            if let error = error {
                print("❌ Purchase failed: \(error)")
                completion(nil, error)
                return
            }
            
            guard let customerInfo = customerInfo else {
                completion(nil, nil)
                return
            }
            
            let activeEntitlements = customerInfo.entitlements.active.keys
            if !activeEntitlements.isEmpty {
                print("✅ Purchase successful! Entitlements: \(activeEntitlements)")
            }
            
            completion(customerInfo, nil)
        }
    }
    
    func restorePurchases(completion: @escaping (CustomerInfo?, Error?) -> Void) {
        print("🔄 Restoring purchases...")
        
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                print("❌ Restore failed: \(error)")
                completion(nil, error)
                return
            }
            
            guard let customerInfo = customerInfo else {
                completion(nil, nil)
                return
            }
            
            let activeEntitlements = customerInfo.entitlements.active.keys
            if !activeEntitlements.isEmpty {
                print("✅ Restored: \(activeEntitlements)")
            } else {
                print("ℹ️ No purchases to restore")
            }
            
            completion(customerInfo, nil)
        }
    }
}
```

---

## 4. Entitlements & Access

### React Native

```typescript
import Purchases, { CustomerInfo } from 'react-native-purchases';

/**
 * Check if user has a specific entitlement
 */
export const hasEntitlement = async (
  entitlementId: string,
  customerInfo?: CustomerInfo
): Promise<boolean> => {
  try {
    let info = customerInfo;
    
    if (!info) {
      info = await Purchases.getCustomerInfo();
    }
    
    const isActive = info.entitlements.active[entitlementId] !== undefined;
    console.log(`🔑 Entitlement ${entitlementId}: ${isActive ? '✅' : '❌'}`);
    return isActive;
    
  } catch (error) {
    console.error(`Failed to check entitlement ${entitlementId}:`, error);
    return false;
  }
};

/**
 * Get all active entitlements
 */
export const getActiveEntitlements = async (): Promise<Record<string, any>> => {
  try {
    const customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active;
  } catch (error) {
    console.error('Failed to get active entitlements:', error);
    return {};
  }
};

/**
 * Get entitlement expiration date
 */
export const getEntitlementExpiration = async (
  entitlementId: string
): Promise<string | null> => {
  try {
    const customerInfo = await Purchases.getCustomerInfo();
    const entitlement = customerInfo.entitlements.active[entitlementId];
    return entitlement?.expirationDate || null;
  } catch (error) {
    console.error('Failed to get entitlement expiration:', error);
    return null;
  }
};

/**
 * Check if user is subscribed
 */
export const isUserSubscribed = async (): Promise<boolean> => {
  try {
    const customerInfo = await Purchases.getCustomerInfo();
    const activeEntitlements = Object.keys(customerInfo.entitlements.active);
    return activeEntitlements.length > 0;
  } catch (error) {
    console.error('Failed to check subscription status:', error);
    return false;
  }
};

/**
 * React Hook for entitlement checking
 */
export const useEntitlement = (entitlementId: string) => {
  const [hasAccess, setHasAccess] = useState<boolean>(false);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  
  useEffect(() => {
    const checkAccess = async () => {
      setIsLoading(true);
      const access = await hasEntitlement(entitlementId);
      setHasAccess(access);
      setIsLoading(false);
    };
    
    checkAccess();
    
    // Setup listener for real-time updates
    const listener = Purchases.addCustomerInfoUpdateListener((customerInfo) => {
      const access = customerInfo.entitlements.active[entitlementId] !== undefined;
      setHasAccess(access);
    });
    
    return () => listener.remove();
  }, [entitlementId]);
  
  return { hasAccess, isLoading };
};
```

### iOS (Swift)

```swift
import RevenueCat

class EntitlementManager {
    static let shared = EntitlementManager()
    
    func hasEntitlement(_ entitlementId: String, customerInfo: CustomerInfo? = nil) -> Bool {
        guard let info = customerInfo ?? Purchases.shared.customerInfo else {
            return false
        }
        
        return info.entitlements.active[entitlementId] != nil
    }
    
    func getActiveEntitlements(completion: @escaping ([String: EntitlementInfo]) -> Void) {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                print("❌ Failed to get entitlements: \(error)")
                completion([:])
                return
            }
            
            completion(customerInfo?.entitlements.active ?? [:])
        }
    }
    
    func isUserSubscribed(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                print("❌ Failed to check subscription: \(error)")
                completion(false)
                return
            }
            
            let subscribed = !(customerInfo?.entitlements.active.isEmpty ?? true)
            completion(subscribed)
        }
    }
}
```

---

## 5. User Identity

### React Native

```typescript
import Purchases from 'react-native-purchases';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Set user ID (for authenticated users)
 */
export const setUserId = async (userId: string): Promise<void> => {
  try {
    await Purchases.setAppUserID(userId);
    await AsyncStorage.setItem('@app_user_id', userId);
    console.log(`👤 User ID set: ${userId}`);
  } catch (error) {
    console.error('Failed to set user ID:', error);
    throw error;
  }
};

/**
 * Reset to anonymous user
 */
export const resetToAnonymous = async (): Promise<void> => {
  try {
    await Purchasures.resetAppUserID();
    await AsyncStorage.removeItem('@app_user_id');
    console.log('👤 Reset to anonymous user');
  } catch (error) {
    console.error('Failed to reset user ID:', error);
    throw error;
  }
};

/**
 * Get current user ID
 */
export const getUserId = async (): Promise<string | null> => {
  try {
    const customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.originalAppUserId;
  } catch (error) {
    console.error('Failed to get user ID:', error);
    return null;
  }
};

/**
 * Transfer anonymous subscription to authenticated user
 */
export const transferAnonymousSubscription = async (userId: string): Promise<void> => {
  try {
    // Get anonymous user info first
    const anonymousInfo = await Purchases.getCustomerInfo();
    const hasAnonymousPurchases = Object.keys(anonymousInfo.entitlements.active).length > 0;
    
    if (hasAnonymousPurchases) {
      console.log('🔄 Transferring anonymous subscription...');
      
      // Set the new user ID - subscription will transfer
      await setUserId(userId);
      
      // Verify transfer
      const newInfo = await Purchases.getCustomerInfo();
      const hasTransferred = Object.keys(newInfo.entitlements.active).length > 0;
      
      if (hasTransferred) {
        console.log('✅ Subscription transferred successfully');
      } else {
        console.warn('⚠️ Subscription transfer may have failed');
      }
    } else {
      // Just set the user ID
      await setUserId(userId);
    }
    
  } catch (error) {
    console.error('Failed to transfer subscription:', error);
    throw error;
  }
};
```

---

## 6. Webhook Processing

### Node.js / Express

```typescript
import express, { Request, Response } from 'express';
import crypto from 'crypto';
import { RevenueCatEvent } from '../types/revenueCat';

const router = express.Router();

/**
 * Verify webhook signature
 */
const verifyWebhookSignature = (body: any, signature: string): boolean => {
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
  if (!secret) {
    console.error('Webhook secret not configured');
    return false;
  }
  
  const bodyString = JSON.stringify(body);
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(bodyString)
    .digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  );
};

/**
 * Process webhook event
 */
const processWebhookEvent = async (event: RevenueCatEvent): Promise<void> => {
  console.log(`📦 Processing event: ${event.type}`, {
    eventId: event.id,
    subscriberId: event.subscriber_id,
    productId: event.product_id,
  });
  
  switch (event.type) {
    case 'INITIAL_PURCHASE':
      await handleInitialPurchase(event);
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
    case 'GRACE_PERIOD':
      await handleGracePeriod(event);
      break;
    case 'PRODUCT_CHANGE':
      await handleProductChange(event);
      break;
    default:
      console.warn(`⚠️ Unknown event type: ${event.type}`);
  }
};

/**
 * Webhook endpoint
 */
router.post('/revenuecat', async (req: Request, res: Response) => {
  try {
    // 1. Verify signature
    const signature = req.headers['x-webhook-signature'] as string;
    if (!verifyWebhookSignature(req.body, signature)) {
      console.error('❌ Invalid webhook signature');
      return res.status(401).json({ error: 'Invalid signature' });
    }
    
    // 2. Process event (non-blocking)
    processWebhookEvent(req.body).catch(error => {
      console.error('❌ Event processing failed:', error);
      // We'll handle errors asynchronously
    });
    
    // 3. Return success immediately
    res.status(200).json({ received: true });
    
  } catch (error) {
    console.error('❌ Webhook handler error:', error);
    res.status(200).json({ received: true }); // Always return 200 to prevent retries
  }
});

export { router as webhookRouter };
```

---

## 7. Analytics Integration

### React Native

```typescript
import Purchases from 'react-native-purchases';

/**
 * Track purchase event for analytics
 */
export const trackPurchaseEvent = async (productId: string, success: boolean) => {
  try {
    const customerInfo = await Purchases.getCustomerInfo();
    
    // Send to analytics
    analytics.track('purchase_completed', {
      userId: customerInfo.originalAppUserId,
      productId,
      success,
      timestamp: new Date().toISOString(),
    });
    
  } catch (error) {
    console.error('Failed to track purchase event:', error);
  }
};

/**
 * Track subscription event
 */
export const trackSubscriptionEvent = async (
  eventName: string,
  properties?: Record<string, any>
) => {
  try {
    const customerInfo = await Purchases.getCustomerInfo();
    
    analytics.track(eventName, {
      userId: customerInfo.originalAppUserId,
      isSubscribed: Object.keys(customerInfo.entitlements.active).length > 0,
      activeEntitlements: Object.keys(customerInfo.entitlements.active),
      ...properties,
      timestamp: new Date().toISOString(),
    });
    
  } catch (error) {
    console.error('Failed to track subscription event:', error);
  }
};
```

---

## Summary

This code snippets library provides ready-to-use implementations for common RevenueCat operations:

1. **Initialization**: Setup for all platforms
2. **Offerings**: Fetching and accessing packages
3. **Purchases**: Complete purchase flow
4. **Entitlements**: Access control and checking
5. **User Identity**: User management
6. **Webhooks**: Event processing
7. **Analytics**: Event tracking

### Quick Reference

| Operation | Function | Platform |
|-----------|----------|----------|
| Initialize | `initializeRevenueCat()` | All |
| Fetch Offerings | `fetchOfferings()` | All |
| Purchase | `purchasePackage()` | All |
| Restore | `restorePurchases()` | All |
| Check Entitlement | `hasEntitlement()` | All |
| Set User ID | `setUserId()` | All |
| Process Webhook | `processWebhookEvent()` | Backend |
