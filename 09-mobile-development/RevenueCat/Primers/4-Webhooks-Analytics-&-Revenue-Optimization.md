# RevenueCat Primer 4: Webhooks, Analytics & Revenue Optimization

## Your Quick Guide to Backend Integration & Growing Your Subscription Revenue

In the first three primers, we covered the basics, paywall, and state management. Now let's go beyond the app and build the backend infrastructure that makes your subscription business truly production-ready.

---

## Why You Need a Backend

Your app handles purchases, but your backend needs to know about them too:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHY YOU NEED WEBHOOKS                           │
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

---

## The Webhook Flow

### Complete Event Processing

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WEBHOOK EVENT FLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. EVENT OCCURS                                                   │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ User subscribes in app                              │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  2. REVENUECAT SENDS WEBHOOK                                       │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ POST https://your-api.com/webhook/revenuecat       │        │
│     │ Headers: X-Webhook-Signature: [signed_hash]        │        │
│     │ Body: { type: 'INITIAL_PURCHASE', ... }            │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  3. YOUR BACKEND VERIFIES                                          │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ 1. Verify signature (prevent fakes)                 │        │
│     │ 2. Parse event type                                 │        │
│     │ 3. Validate event data                              │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  4. YOUR BACKEND PROCESSES                                         │
│     ┌─────────────────────────────────────────────────────┐        │
│     │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │        │
│     │  │ Database    │  │ Analytics   │  │ Email       │ │        │
│     │  │ Update      │  │ Track Event │  │ Send        │ │        │
│     │  └─────────────┘  └─────────────┘  └─────────────┘ │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  5. RESPONSE                                                       │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ 200 OK (RevenueCat stops retrying)                  │        │
│     └─────────────────────────────────────────────────────┘        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Key Backend Components

### 1. Webhook Handler

The entry point for all subscription events:

```typescript
// Webhook endpoint
app.post('/webhook/revenuecat', async (req, res) => {
  try {
    // 1. Verify signature
    const isValid = verifyWebhookSignature(req.body, req.headers);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid signature' });
    }
    
    // 2. Process event
    const event = req.body;
    await processSubscriptionEvent(event);
    
    // 3. Always return 200 (RevenueCat retries on failure)
    res.status(200).json({ received: true });
  } catch (error) {
    // Log but always return 200 to prevent retries
    console.error('Webhook error:', error);
    res.status(200).json({ received: true, error: 'Handled internally' });
  }
});
```

### 2. Event Processor

Handles each event type:

```typescript
const processSubscriptionEvent = async (event) => {
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
    // ... etc
  }
};
```

### 3. Database Service

Keeps your user data in sync:

```typescript
const handleNewSubscription = async (event) => {
  const { subscriber_id, product_id, expiration_date } = event;
  
  // Update database
  await db.users.update({
    where: { id: subscriber_id },
    data: {
      subscriptionStatus: 'active',
      productId: product_id,
      expirationDate: new Date(expiration_date),
    }
  });
  
  // Send welcome email
  await emailService.sendWelcome(subscriber_id);
  
  // Track analytics
  await analytics.track('subscription_purchase', {
    userId: subscriber_id,
    productId: product_id,
  });
};
```

---

## Analytics: Tracking What Matters

### Key Revenue Metrics

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CRITICAL REVENUE METRICS                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  📊 MRR (Monthly Recurring Revenue)                                │
│     → Predictable monthly revenue from subscriptions              │
│     → Formula: Sum of all monthly subscription payments           │
│                                                                     │
│  📈 ARPU (Average Revenue Per User)                                │
│     → Revenue divided by active users                             │
│     → Formula: MRR / Total Active Users                           │
│                                                                     │
│  💰 LTV (Lifetime Value)                                           │
│     → Total revenue from a user over their lifetime               │
│     → Formula: ARPU × Average Customer Lifetime                   │
│                                                                     │
│  📉 Churn Rate                                                     │
│     → Percentage of subscribers who cancel                        │
│     → Formula: Cancelled / Total Subscribers × 100                │
│                                                                     │
│  🔄 Conversion Rate                                                │
│     → Percentage of free users who subscribe                      │
│     → Formula: New Subscribers / Free Users × 100                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Analytics Events to Track

```typescript
// Track these events for full visibility
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

### The Churn Prevention Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CHURN PREVENTION PIPELINE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. BILLING ISSUE DETECTED                                         │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ User's payment fails                                │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  2. GRACE PERIOD STARTS (3-7 days)                                 │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ User keeps access while we try to fix payment       │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  3. NOTIFICATIONS SENT                                            │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ • Day 1: "Payment failed, update your card"        │        │
│     │ • Day 3: "Your access expires in 2 days"           │        │
│     │ • Day 5: "Last chance to update payment"           │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  4. SUBSCRIPTION EXPIRES                                           │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ User loses access                                   │        │
│     └─────────────────────────────────────────────────────┘        │
│                          │                                         │
│                          ▼                                         │
│  5. WIN-BACK CAMPAIGN STARTS                                      │
│     ┌─────────────────────────────────────────────────────┐        │
│     │ • Day 7: "We miss you! Come back"                  │        │
│     │ • Day 14: "30% off your first month"               │        │
│     │ • Day 30: "Your workout data is waiting"           │        │
│     └─────────────────────────────────────────────────────┘        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Win-Back Campaign Implementation

```typescript
const checkWinBackEligibility = async (userId) => {
  const user = await db.users.findById(userId);
  
  // Check if expired within last 30 days
  const daysSinceExpiration = Math.floor(
    (Date.now() - user.expirationDate.getTime()) / (1000 * 60 * 60 * 24)
  );
  
  // Send win-back offers based on time
  if (daysSinceExpiration === 7) {
    await sendWinBackEmail(user, {
      offer: '30% off your first month',
      message: 'We miss you! Come back and continue your fitness journey.'
    });
  } else if (daysSinceExpiration === 14) {
    await sendWinBackEmail(user, {
      offer: '50% off your first month',
      message: 'Special offer just for you! Don\'t let your progress go to waste.'
    });
  } else if (daysSinceExpiration === 30) {
    await sendWinBackEmail(user, {
      offer: 'First month free',
      message: 'Your workout data is still here. Come back and start where you left off!'
    });
  }
};
```

---

## RevenueCat Experiments (A/B Testing)

### Why Experiment?

> "You can't optimize what you don't test."

RevenueCat Experiments let you test:

| Experiment Type | What to Test | Example |
|-----------------|--------------|---------|
| **Pricing** | Price points | $9.99 vs $12.99/month |
| **Messaging** | Value proposition | "Save 20%" vs "Unlock All Features" |
| **Layout** | Design | 2 cards vs 3 cards |
| **Offers** | Trial length | 7-day vs 14-day trial |
| **Timing** | When to show | Immediate vs after 3 workouts |

### Setting Up an Experiment

```typescript
// 1. Create experiment in RevenueCat dashboard
// 2. Assign users to variants
const experiment = await getExperimentForUser(userId, 'paywall_design_001');

// 3. Track which variant the user sees
await trackImpression(userId, experiment.id, experiment.variant.id);

// 4. Track conversion
await trackConversion(userId, experiment.id, experiment.variant.id);

// 5. Analyze results in RevenueCat dashboard
// → Compare conversion rates between variants
```

---

## Monitoring & Alerting

### What to Monitor

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CRITICAL MONITORING METRICS                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  🚨 Revenue Alerts                                                 │
│     • MRR drops below $10,000/month                                │
│     • Conversion rate drops below 10%                              │
│     • Churn rate above 5%                                          │
│                                                                     │
│  🔧 Technical Alerts                                               │
│     • Webhook error rate > 5%                                      │
│     • SDK initialization failures                                  │
│     • Purchase failures > 2%                                       │
│                                                                     │
│  📊 Growth Alerts                                                  │
│     • New subscriber count drops                                   │
│     • Trial conversion drops                                       │
│     • Refund rate spikes                                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Alert Implementation

```typescript
const checkMetrics = async () => {
  const metrics = await getRecentMetrics();
  
  // Revenue alert
  if (metrics.mrr < 10000) {
    sendAlert({
      type: 'warning',
      message: `MRR dropped to $${metrics.mrr}`,
      action: 'Investigate revenue drop'
    });
  }
  
  // Churn alert
  if (metrics.churnRate > 0.05) {
    sendAlert({
      type: 'critical',
      message: `Churn rate is ${metrics.churnRate * 100}%`,
      action: 'Review churn reasons and retention strategy'
    });
  }
  
  // Technical alert
  if (metrics.webhookErrorRate > 0.05) {
    sendAlert({
      type: 'critical',
      message: `Webhook error rate is ${metrics.webhookErrorRate * 100}%`,
      action: 'Check webhook endpoint and server logs'
    });
  }
};
```

---

## Quick Reference: Backend Setup Checklist

```
✅ Webhook endpoint created
✅ Signature verification implemented
✅ All event types handled
✅ Database updated on events
✅ Analytics events tracked
✅ Email notifications set up
✅ Churn reduction strategies in place
✅ Monitoring and alerts configured
✅ Experiments ready (A/B testing)
✅ Error handling and retry logic
✅ Environment variables set up
✅ Deployment configured
```

---

## Common Backend Patterns

### 1. Idempotent Processing

```typescript
// Prevent duplicate processing
const processEvent = async (event) => {
  // Check if already processed
  const existing = await db.processedEvents.findById(event.id);
  if (existing) {
    return { processed: true, already: true };
  }
  
  // Process the event
  await processSubscriptionEvent(event);
  
  // Mark as processed
  await db.processedEvents.create({
    id: event.id,
    timestamp: new Date(),
    type: event.type,
  });
};
```

### 2. Rate Limiting

```typescript
// Prevent abuse
const rateLimiter = {
  windowMs: 900000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  
  async isLimited(ip: string): Promise<boolean> {
    const count = await redis.incr(`rate:${ip}`);
    if (count === 1) {
      await redis.expire(`rate:${ip}`, this.windowMs / 1000);
    }
    return count > this.max;
  }
};
```

### 3. Retry with Exponential Backoff

```typescript
const retryWithBackoff = async (fn, retries = 3) => {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === retries - 1) throw error;
      const delay = Math.pow(2, i) * 1000; // 1s, 2s, 4s
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
};
```

---

## Key Takeaway

> **Your backend is the brain of your subscription business:**
> - **Webhooks** keep your data in sync
> - **Analytics** tell you what's working
> - **Churn reduction** keeps revenue growing
> - **Monitoring** catches problems early
> - **Experiments** help you optimize

Build this infrastructure, and your subscription business will run itself.

---

## Next Steps

Now that you understand the backend infrastructure:

**Continue to Part 5**: [Full React Native App Integration] – See everything working together in a complete production app

**Or jump back to**: [Part 1: Foundations] – Review the basics of RevenueCat setup
