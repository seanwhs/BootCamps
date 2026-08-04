# Appendix E: RevenueCat API Reference

## Overview

This appendix provides a comprehensive reference for the RevenueCat REST API. While the SDK handles most interactions, there are scenarios where you need to call the API directly from your backend server.

Think of this as your "API handbook" – a reference for all endpoints, request/response formats, and common operations you'll need when building server-side integrations.

---

## API Basics

### Base URL

```
https://api.revenuecat.com/v1
```

### Authentication

All API requests require authentication using your **Secret API Key** (starts with `sk_`). Never use your Public API Key (starts with `app_`) for server-side requests.

```bash
# Example request with authentication
curl -X GET "https://api.revenuecat.com/v1/subscribers/user_123" \
  -H "Authorization: Bearer sk_your_secret_api_key"
```

```typescript
// TypeScript example
const fetchSubscriber = async (userId: string) => {
  const response = await fetch(`https://api.revenuecat.com/v1/subscribers/${userId}`, {
    headers: {
      'Authorization': `Bearer ${process.env.REVENUECAT_SECRET_API_KEY}`,
      'Content-Type': 'application/json',
    },
  });
  
  return response.json();
};
```

### Rate Limiting

RevenueCat API has rate limits to ensure service stability:

| Domain | Limit (requests/minute) |
|--------|-------------------------|
| Customer Information (GET) | 480 |
| Customer Information (POST) | 120 |
| Charts & Metrics | 25 |
| Project Configuration | 60 |

**Rate Limit Headers:**
- `RevenueCat-Rate-Limit-Current-Usage`: Current request count
- `RevenueCat-Rate-Limit-Current-Limit`: Limit per minute
- `Retry-After`: Seconds to wait when rate limited

```typescript
// Handle rate limiting
const apiRequest = async (url: string, options: RequestInit) => {
  try {
    const response = await fetch(url, options);
    
    if (response.status === 429) {
      const retryAfter = parseInt(response.headers.get('Retry-After') || '60');
      console.log(`Rate limited. Retry after ${retryAfter} seconds`);
      
      // Wait and retry
      await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
      return apiRequest(url, options);
    }
    
    return response;
    
  } catch (error) {
    console.error('API request failed:', error);
    throw error;
  }
};
```

---

## Subscribers API

### Get Subscriber

Retrieve all information about a specific subscriber.

**Endpoint:**
```
GET /subscribers/{app_user_id}
```

**Parameters:**
- `app_user_id` (path, required): The RevenueCat App User ID

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "subscriber": {
    "original_app_user_id": "user_123",
    "original_application_version": "1.0.0",
    "first_seen": "2026-01-01T00:00:00Z",
    "entitlements": {
      "premium_workouts": {
        "expires_date": "2026-09-04T00:00:00Z",
        "grace_period_expires_date": null,
        "purchase_date": "2026-08-04T00:00:00Z",
        "product_identifier": "com.fittrackpro.annual",
        "is_sandbox": false,
        "unsubscribe_detected_at": null,
        "billing_issue_detected_at": null,
        "period_type": "normal",
        "ownership_type": "purchased",
        "store": "app_store",
        "will_renew": true
      }
    },
    "subscriptions": {
      "com.fittrackpro.annual": {
        "billing_issues_detected_at": null,
        "expires_date": "2026-09-04T00:00:00Z",
        "grace_period_expires_date": null,
        "is_sandbox": false,
        "original_purchase_date": "2026-08-04T00:00:00Z",
        "ownership_type": "purchased",
        "period_type": "normal",
        "purchase_date": "2026-08-04T00:00:00Z",
        "store": "app_store",
        "unsubscribe_detected_at": null,
        "will_renew": true
      }
    },
    "non_subscriptions": {},
    "management_url": "https://apps.apple.com/account/subscriptions",
    "management_url_sandbox": "https://sandbox.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"
  }
}
```

**TypeScript Interface:**
```typescript
interface SubscriberResponse {
  request_date: string;
  subscriber: {
    original_app_user_id: string;
    original_application_version: string;
    first_seen: string;
    entitlements: Record<string, Entitlement>;
    subscriptions: Record<string, Subscription>;
    non_subscriptions: Record<string, any>;
    management_url: string | null;
    management_url_sandbox: string | null;
  };
}

interface Entitlement {
  expires_date: string | null;
  grace_period_expires_date: string | null;
  purchase_date: string;
  product_identifier: string;
  is_sandbox: boolean;
  unsubscribe_detected_at: string | null;
  billing_issue_detected_at: string | null;
  period_type: 'normal' | 'intro' | 'trial';
  ownership_type: 'purchased' | 'family_shared';
  store: 'app_store' | 'play_store' | 'amazon';
  will_renew: boolean;
}

interface Subscription {
  billing_issues_detected_at: string | null;
  expires_date: string | null;
  grace_period_expires_date: string | null;
  is_sandbox: boolean;
  original_purchase_date: string;
  ownership_type: 'purchased' | 'family_shared';
  period_type: 'normal' | 'intro' | 'trial';
  purchase_date: string;
  store: 'app_store' | 'play_store' | 'amazon';
  unsubscribe_detected_at: string | null;
  will_renew: boolean;
}
```

### Update Subscriber

Update attributes for a specific subscriber.

**Endpoint:**
```
POST /subscribers/{app_user_id}
```

**Parameters:**
- `app_user_id` (path, required): The RevenueCat App User ID

**Request Body:**
```json
{
  "attributes": {
    "$email": "user@example.com",
    "$displayName": "John Doe",
    "user_level": "premium",
    "country": "US",
    "custom_attribute": "custom_value"
  }
}
```

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "attributes": {
    "$email": "user@example.com",
    "$displayName": "John Doe",
    "user_level": "premium",
    "country": "US",
    "custom_attribute": "custom_value"
  }
}
```

**TypeScript:**
```typescript
interface UpdateSubscriberRequest {
  attributes: {
    $email?: string;
    $displayName?: string;
    $phoneNumber?: string;
    $ipAddress?: string;
    $country?: string;
    [key: string]: string | number | boolean | undefined;
  };
}

const updateSubscriber = async (
  userId: string,
  attributes: UpdateSubscriberRequest['attributes']
) => {
  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${userId}`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.REVENUECAT_SECRET_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ attributes }),
    }
  );
  
  return response.json();
};
```

---

## Entitlements API

### Grant Entitlement

Grant an entitlement to a subscriber (useful for testing or when a user should receive a promotional entitlement).

**Endpoint:**
```
POST /subscribers/{app_user_id}/entitlements/{entitlement_id}
```

**Parameters:**
- `app_user_id` (path, required): The RevenueCat App User ID
- `entitlement_id` (path, required): The entitlement identifier

**Request Body:**
```json
{
  "start_date": "2026-08-04T00:00:00Z",
  "end_date": "2026-09-04T00:00:00Z"
}
```

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "subscriber": {
    "entitlements": {
      "premium_workouts": {
        "expires_date": "2026-09-04T00:00:00Z",
        "purchase_date": "2026-08-04T00:00:00Z",
        "product_identifier": "promotional",
        "is_sandbox": false,
        "store": "promotional",
        "will_renew": false
      }
    }
  }
}
```

### Revoke Entitlement

Revoke an entitlement from a subscriber (if they should no longer have access).

**Endpoint:**
```
DELETE /subscribers/{app_user_id}/entitlements/{entitlement_id}
```

**Parameters:**
- `app_user_id` (path, required): The RevenueCat App User ID
- `entitlement_id` (path, required): The entitlement identifier

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "subscriber": {
    "entitlements": {}
  }
}
```

**TypeScript:**
```typescript
const grantEntitlement = async (
  userId: string,
  entitlementId: string,
  durationDays: number
) => {
  const startDate = new Date();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + durationDays);
  
  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${userId}/entitlements/${entitlementId}`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.REVENUECAT_SECRET_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        start_date: startDate.toISOString(),
        end_date: endDate.toISOString(),
      }),
    }
  );
  
  return response.json();
};

const revokeEntitlement = async (
  userId: string,
  entitlementId: string
) => {
  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${userId}/entitlements/${entitlementId}`,
    {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${process.env.REVENUECAT_SECRET_API_KEY}`,
      },
    }
  );
  
  return response.json();
};
```

---

## Products API

### Get Products

Retrieve all products for your project.

**Endpoint:**
```
GET /products
```

**Parameters:**
- `platform` (query, optional): Filter by platform (`ios`, `android`, `amazon`)

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "products": [
    {
      "id": "com.fittrackpro.monthly",
      "platform": "ios",
      "type": "subscription",
      "duration": "P1M",
      "duration_unit": "month",
      "duration_count": 1,
      "entitlements": [
        "premium_workouts",
        "nutrition_tracking",
        "personal_trainer"
      ],
      "name": "Monthly",
      "description": "Monthly subscription",
      "price": 9.99,
      "currency": "USD"
    },
    {
      "id": "com.fittrackpro.annual",
      "platform": "ios",
      "type": "subscription",
      "duration": "P1Y",
      "duration_unit": "year",
      "duration_count": 1,
      "entitlements": [
        "premium_workouts",
        "nutrition_tracking",
        "personal_trainer"
      ],
      "name": "Annual",
      "description": "Annual subscription",
      "price": 99.99,
      "currency": "USD"
    }
  ]
}
```

### Get Product Details

Retrieve details for a specific product.

**Endpoint:**
```
GET /products/{product_id}
```

**Parameters:**
- `product_id` (path, required): The product identifier

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "product": {
    "id": "com.fittrackpro.annual",
    "platform": "ios",
    "type": "subscription",
    "duration": "P1Y",
    "duration_unit": "year",
    "duration_count": 1,
    "entitlements": [
      "premium_workouts",
      "nutrition_tracking",
      "personal_trainer"
    ],
    "name": "Annual",
    "description": "Annual subscription",
    "price": 99.99,
    "currency": "USD",
    "promotional_offers": [
      {
        "id": "introductory",
        "type": "free_trial",
        "duration": "P7D",
        "price": 0,
        "currency": "USD"
      }
    ]
  }
}
```

---

## Offerings API

### Get Offerings

Retrieve all offerings for your project.

**Endpoint:**
```
GET /offerings
```

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "offerings": [
    {
      "id": "default",
      "name": "Default Offering",
      "description": "Standard subscription options",
      "packages": [
        {
          "id": "monthly",
          "name": "Monthly",
          "product_id": "com.fittrackpro.monthly",
          "type": "subscription",
          "price": 9.99,
          "currency": "USD"
        },
        {
          "id": "annual",
          "name": "Annual",
          "product_id": "com.fittrackpro.annual",
          "type": "subscription",
          "price": 99.99,
          "currency": "USD"
        }
      ]
    }
  ]
}
```

### Create/Update Offering

Create or update an offering.

**Endpoint:**
```
PUT /offerings/{offering_id}
```

**Parameters:**
- `offering_id` (path, required): The offering identifier

**Request Body:**
```json
{
  "name": "New Offering",
  "description": "Description of the offering",
  "packages": [
    {
      "id": "monthly",
      "name": "Monthly",
      "product_id": "com.fittrackpro.monthly",
      "type": "subscription"
    },
    {
      "id": "annual",
      "name": "Annual",
      "product_id": "com.fittrackpro.annual",
      "type": "subscription"
    }
  ]
}
```

---

## Webhooks API

### Configure Webhook

Set up a webhook endpoint for receiving subscription events.

**Endpoint:**
```
PUT /webhooks
```

**Request Body:**
```json
{
  "url": "https://api.fittrackpro.com/webhook/revenuecat",
  "events": [
    "INITIAL_PURCHASE",
    "RENEWAL",
    "CANCELLATION",
    "EXPIRATION",
    "REFUND",
    "BILLING_ISSUE",
    "GRACE_PERIOD",
    "PRODUCT_CHANGE",
    "UNSUBSCRIBE",
    "RESUBSCRIBE"
  ],
  "secret": "your_webhook_secret" // Will be generated if omitted
}
```

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "webhook": {
    "id": "wh_1234567890",
    "url": "https://api.fittrackpro.com/webhook/revenuecat",
    "events": ["INITIAL_PURCHASE", "RENEWAL", "CANCELLATION"],
    "secret": "wh_secret_1234567890",
    "created_at": "2026-08-04T00:00:00Z",
    "updated_at": "2026-08-04T00:00:00Z"
  }
}
```

### Get Webhook Configuration

Retrieve the current webhook configuration.

**Endpoint:**
```
GET /webhooks
```

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "webhook": {
    "id": "wh_1234567890",
    "url": "https://api.fittrackpro.com/webhook/revenuecat",
    "events": ["INITIAL_PURCHASE", "RENEWAL", "CANCELLATION"],
    "secret": "wh_secret_1234567890",
    "created_at": "2026-08-04T00:00:00Z",
    "updated_at": "2026-08-04T00:00:00Z"
  }
}
```

---

## Analytics API

### Get Revenue Metrics

Retrieve revenue metrics for your project.

**Endpoint:**
```
GET /analytics/revenue
```

**Parameters:**
- `start_date` (query, required): ISO date string (YYYY-MM-DD)
- `end_date` (query, required): ISO date string (YYYY-MM-DD)
- `granularity` (query, optional): `day`, `week`, `month`
- `platform` (query, optional): Filter by platform

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "metrics": {
    "mrr": 12500.00,
    "arr": 150000.00,
    "arpu": 25.00,
    "ltv": 120.00,
    "conversion_rate": 15.5,
    "churn_rate": 3.2
  },
  "timeseries": [
    {
      "date": "2026-08-01",
      "mrr": 12000.00,
      "subscribers": 480,
      "new_subscribers": 12,
      "lost_subscribers": 8
    },
    {
      "date": "2026-08-02",
      "mrr": 12250.00,
      "subscribers": 490,
      "new_subscribers": 15,
      "lost_subscribers": 5
    },
    {
      "date": "2026-08-03",
      "mrr": 12500.00,
      "subscribers": 500,
      "new_subscribers": 18,
      "lost_subscribers": 8
    }
  ]
}
```

### Get Subscription Metrics

Retrieve detailed subscription metrics.

**Endpoint:**
```
GET /analytics/subscriptions
```

**Parameters:**
- `start_date` (query, required): ISO date string
- `end_date` (query, required): ISO date string
- `granularity` (query, optional): `day`, `week`, `month`

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "metrics": {
    "active_subscriptions": 500,
    "new_subscriptions": 45,
    "cancellations": 16,
    "net_growth": 29,
    "trial_conversion_rate": 25.5,
    "retention_rate": 92.4,
    "average_lifetime": 12.5
  },
  "by_product": {
    "com.fittrackpro.monthly": {
      "active": 200,
      "revenue": 1998.00,
      "churn_rate": 4.2
    },
    "com.fittrackpro.annual": {
      "active": 300,
      "revenue": 29997.00,
      "churn_rate": 2.5
    }
  }
}
```

---

## Experiments API

### Get Experiments

Retrieve all experiments for your project.

**Endpoint:**
```
GET /experiments
```

**Response:**
```json
{
  "request_date": "2026-08-04T00:00:00Z",
  "experiments": [
    {
      "id": "exp_1234567890",
      "name": "Paywall A/B Test",
      "description": "Testing different paywall designs",
      "status": "active",
      "start_date": "2026-08-01T00:00:00Z",
      "end_date": null,
      "variants": [
        {
          "id": "control",
          "name": "Control",
          "weight": 0.5,
          "conversion_rate": 15.2,
          "revenue": 12500.00
        },
        {
          "id": "variant_a",
          "name": "Variant A",
          "weight": 0.25,
          "conversion_rate": 18.3,
          "revenue": 15000.00
        },
        {
          "id": "variant_b",
          "name": "Variant B",
          "weight": 0.25,
          "conversion_rate": 20.1,
          "revenue": 16500.00
        }
      ]
    }
  ]
}
```

### Create Experiment

Create a new A/B test experiment.

**Endpoint:**
```
POST /experiments
```

**Request Body:**
```json
{
  "name": "New Experiment",
  "description": "Testing pricing changes",
  "variants": [
    {
      "name": "Control",
      "weight": 0.5,
      "configuration": {
        "price": 9.99,
        "discount": 0
      }
    },
    {
      "name": "Variant A",
      "weight": 0.25,
      "configuration": {
        "price": 7.99,
        "discount": 20
      }
    },
    {
      "name": "Variant B",
      "weight": 0.25,
      "configuration": {
        "price": 8.99,
        "discount": 10
      }
    }
  ],
  "start_date": "2026-08-04T00:00:00Z"
}
```

---

## API Best Practices

### Error Handling

```typescript
class RevenueCatAPIError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public code?: string,
    public details?: any
  ) {
    super(message);
    this.name = 'RevenueCatAPIError';
  }
}

const handleAPIResponse = async (response: Response) => {
  if (response.ok) {
    return response.json();
  }
  
  const errorData = await response.json().catch(() => ({}));
  
  switch (response.status) {
    case 400:
      throw new RevenueCatAPIError(400, 'Bad request', errorData.code, errorData);
    case 401:
      throw new RevenueCatAPIError(401, 'Unauthorized - Check your API key');
    case 403:
      throw new RevenueCatAPIError(403, 'Forbidden - Insufficient permissions');
    case 404:
      throw new RevenueCatAPIError(404, 'Not found', errorData.code);
    case 429:
      throw new RevenueCatAPIError(429, 'Rate limited', errorData.code, {
        retryAfter: response.headers.get('Retry-After'),
      });
    case 500:
      throw new RevenueCatAPIError(500, 'Server error - Please try again later');
    default:
      throw new RevenueCatAPIError(
        response.status,
        errorData.message || 'Unknown error'
      );
  }
};
```

### Retry Logic

```typescript
const apiRequestWithRetry = async <T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  delay = 1000
): Promise<T> => {
  let lastError: Error;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      
      // Don't retry certain errors
      if (error instanceof RevenueCatAPIError) {
        if (error.statusCode === 401 || error.statusCode === 403) {
          throw error;
        }
      }
      
      if (attempt === maxRetries) {
        throw lastError;
      }
      
      // Exponential backoff
      const waitTime = delay * Math.pow(2, attempt - 1);
      console.log(`Request failed, retrying in ${waitTime}ms...`);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
  
  throw lastError!;
};

// Usage
const getSubscriber = async (userId: string) => {
  return apiRequestWithRetry(async () => {
    const response = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${userId}`,
      {
        headers: {
          'Authorization': `Bearer ${process.env.REVENUECAT_SECRET_API_KEY}`,
        },
      }
    );
    
    return handleAPIResponse(response);
  });
};
```

### Batching Requests

```typescript
// Batch multiple subscriber requests
const getMultipleSubscribers = async (userIds: string[]) => {
  // RevenueCat doesn't support batch requests
  // Use Promise.all but handle rate limits
  const batchSize = 10;
  const results = [];
  
  for (let i = 0; i < userIds.length; i += batchSize) {
    const batch = userIds.slice(i, i + batchSize);
    const promises = batch.map(userId => getSubscriber(userId));
    
    const batchResults = await Promise.allSettled(promises);
    results.push(...batchResults);
    
    // Wait between batches to avoid rate limiting
    if (i + batchSize < userIds.length) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
  
  return results;
};
```

---

## Webhook Event Types

### Full Event Reference

```typescript
enum WebhookEventType {
  INITIAL_PURCHASE = 'INITIAL_PURCHASE',
  RENEWAL = 'RENEWAL',
  CANCELLATION = 'CANCELLATION',
  EXPIRATION = 'EXPIRATION',
  REFUND = 'REFUND',
  BILLING_ISSUE = 'BILLING_ISSUE',
  GRACE_PERIOD = 'GRACE_PERIOD',
  PRODUCT_CHANGE = 'PRODUCT_CHANGE',
  UNSUBSCRIBE = 'UNSUBSCRIBE',
  RESUBSCRIBE = 'RESUBSCRIBE',
}
```

### Event Payload Structure

```typescript
interface WebhookEvent {
  type: WebhookEventType;
  id: string;
  subscriber_id: string;
  product_id: string;
  price: number;
  currency: string;
  purchase_date: string;
  expiration_date: string;
  transaction_id: string;
  store: 'app_store' | 'play_store' | 'amazon';
  is_sandbox: boolean;
  entitlement_ids: string[];
  // Additional fields based on event type
  cancellation_reason?: string;
  cancellation_date?: string;
  refund_amount?: number;
  refund_date?: string;
  billing_issue_type?: string;
  grace_period_end?: string;
  old_product_id?: string;
}
```

---

## Summary

This API reference covers the essential RevenueCat REST API endpoints you'll need for server-side integrations:

1. **Subscribers API**: Get and update subscriber information
2. **Entitlements API**: Grant and revoke entitlements programmatically
3. **Products API**: Retrieve product configuration
4. **Offerings API**: Manage offerings
5. **Webhooks API**: Configure webhook endpoints
6. **Analytics API**: Retrieve revenue and subscription metrics
7. **Experiments API**: Manage A/B testing

### Key Takeaways

1. **Always use Secret API Keys** for server-side requests
2. **Implement proper error handling** including rate limiting
3. **Use idempotency** when processing webhooks
4. **Cache responses** to reduce API calls
5. **Monitor rate limits** and implement backoff
