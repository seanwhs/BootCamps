# Part 4: Webhooks, Analytics & Revenue Optimization

## Module Overview

Welcome to Part 4! Now that you have a fully functional subscription app with state management and feature gating, it's time to build the backend infrastructure that makes this production-ready. This is where we connect everything to your servers, track revenue, and optimize for growth.

By the end of this module, you'll have:

- ✅ A RevenueCat webhook endpoint that receives subscription events
- ✅ Complete event handling for all subscription lifecycle events
- ✅ Analytics integration for tracking revenue metrics
- ✅ Churn reduction strategies (grace periods, win-back campaigns)
- ✅ RevenueCat Experiments for A/B testing
- ✅ A comprehensive monitoring and alerting system

Think of this as building the "engine room" of your subscription business – the part that keeps everything running smoothly behind the scenes.

---

## Phase 1: Webhook Configuration & Setup

### The Target

Set up a secure webhook endpoint that receives and processes subscription events from RevenueCat.

### The Concept

Webhooks are HTTP callbacks that RevenueCat makes to your server when subscription events occur. They're like push notifications for your backend:

1. **Event Occurs**: User subscribes, cancels, renews, etc.
2. **RevenueCat Sends**: POST request to your webhook URL with event data
3. **Your Server Processes**: Updates your database, sends emails, syncs data

This is crucial for:
- Keeping your database in sync with RevenueCat
- Triggering automated actions (welcome emails, access changes)
- Building your own analytics dashboards
- Preventing fraud and verifying receipts

### Implementation

#### Step 1.1: Create the Backend Project

**File: `FitTrackPro/backend/package.json`**

```json
{
  "name": "fittrackpro-backend",
  "version": "1.0.0",
  "description": "Backend server for FitTrack Pro subscription management",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "nodemon src/index.ts",
    "test": "jest",
    "lint": "eslint src/**/*.ts"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "body-parser": "^1.20.2",
    "typescript": "^5.2.2",
    "@types/node": "^20.8.10",
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.15",
    "jsonwebtoken": "^9.0.2",
    "crypto": "^1.0.1",
    "winston": "^3.11.0",
    "postgres": "^3.4.3",
    "redis": "^4.6.10"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "ts-node": "^10.9.1",
    "@types/jsonwebtoken": "^9.0.5"
  }
}
```

#### Step 1.2: Set Up Environment Variables

**File: `FitTrackPro/backend/.env.example`**

```bash
# Server Configuration
PORT=3000
NODE_ENV=development

# RevenueCat Configuration
REVENUECAT_WEBHOOK_SECRET=wh_1234567890abcdef
REVENUECAT_API_KEY=sk_1234567890abcdef
REVENUECAT_PROJECT_ID=your_project_id

# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/fittrackpro
DATABASE_SSL=false

# Redis Configuration (for caching)
REDIS_URL=redis://localhost:6379

# JWT Configuration
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
EMAIL_FROM=noreply@fittrackpro.com

# Analytics
MIXPANEL_TOKEN=your_mixpanel_token
AMPLITUDE_API_KEY=your_amplitude_key
POSTHOG_API_KEY=your_posthog_key

# Logging
LOG_LEVEL=info
LOG_FILE_PATH=./logs/app.log

# Security
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

#### Step 1.3: Create the Webhook Server

**File: `FitTrackPro/backend/src/index.ts`**

```typescript
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { webhookRouter } from './routes/webhook';
import { healthRouter } from './routes/health';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

/**
 * Middleware Configuration
 */
// Enable CORS
app.use(cors());

// Parse JSON bodies with size limit
app.use(express.json({ limit: '10mb' }));

// Parse URL-encoded bodies
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint (unprotected)
app.use('/health', healthRouter);

// Rate limiting for all webhook routes
app.use('/webhook', rateLimiter);

// Webhook routes
app.use('/webhook', webhookRouter);

// Error handling middleware (must be last)
app.use(errorHandler);

/**
 * Start the server
 */
app.listen(PORT, () => {
  logger.info(`🚀 Server running on http://localhost:${PORT}`);
  logger.info(`📡 Webhook endpoint: http://localhost:${PORT}/webhook/revenuecat`);
  logger.info(`🔍 Health check: http://localhost:${PORT}/health`);
});

export default app;
```

#### Step 1.4: Create the Webhook Router

**File: `FitTrackPro/backend/src/routes/webhook.ts`**

```typescript
import { Router, Request, Response } from 'express';
import { RevenueCatWebhookHandler } from '../webhooks/revenueCatHandler';
import { logger } from '../utils/logger';

const router = Router();
const webhookHandler = new RevenueCatWebhookHandler();

/**
 * RevenueCat Webhook Endpoint
 * 
 * Receives webhook events from RevenueCat and processes them.
 * 
 * Security:
 * - Verifies the webhook signature
 * - Validates the event type
 * - Processes the event asynchronously
 * 
 * 📡 This is the main entry point for all subscription events.
 */
router.post('/revenuecat', async (req: Request, res: Response) => {
  try {
    // Log the incoming webhook (sanitized)
    logger.info(`📨 Received RevenueCat webhook`, {
      eventType: req.body.type,
      eventId: req.body.id,
    });

    // Process the webhook event
    const result = await webhookHandler.handleWebhook(req.body, req.headers);

    // Respond with success
    res.status(200).json({
      success: true,
      message: 'Webhook processed successfully',
      eventId: req.body.id,
    });

    // Log successful processing
    logger.info(`✅ Webhook processed successfully`, {
      eventType: req.body.type,
      eventId: req.body.id,
    });

  } catch (error) {
    // Log the error
    logger.error(`❌ Webhook processing failed`, {
      error: error instanceof Error ? error.message : 'Unknown error',
      body: req.body,
    });

    // Always return 200 to RevenueCat to prevent retries
    // We'll handle errors internally and alert our team
    res.status(200).json({
      success: false,
      message: 'Webhook processing failed, but we\'ll handle it internally',
    });
  }
});

/**
 * Test webhook endpoint (for development only)
 */
if (process.env.NODE_ENV === 'development') {
  router.post('/test', async (req: Request, res: Response) => {
    logger.info('🧪 Test webhook received', { body: req.body });
    res.status(200).json({ success: true, message: 'Test webhook received' });
  });
}

export { router as webhookRouter };
```

#### Step 1.5: Create the Webhook Handler

**File: `FitTrackPro/backend/src/webhooks/revenueCatHandler.ts`**

```typescript
import { RevenueCatEvent, EventType } from '../types/revenueCat';
import { verifyWebhookSignature } from '../utils/security';
import { logger } from '../utils/logger';
import { EventProcessor } from '../services/eventProcessor';
import { DatabaseService } from '../services/databaseService';
import { AnalyticsService } from '../services/analyticsService';
import { NotificationService } from '../services/notificationService';

/**
 * RevenueCat Webhook Handler
 * 
 * Handles all webhook events from RevenueCat.
 * 
 * Event Types:
 * - INITIAL_PURCHASE: First purchase of a subscription
 * - RENEWAL: Successful renewal of a subscription
 * - CANCELLATION: User cancelled their subscription
 * - EXPIRATION: Subscription expired without renewal
 * - REFUND: User received a refund
 * - BILLING_ISSUE: Failed payment
 * - GRACE_PERIOD: Subscription entered grace period
 * - PRODUCT_CHANGE: User changed their subscription tier
 * 
 * 🎯 Each event type triggers specific business logic.
 */
export class RevenueCatWebhookHandler {
  private eventProcessor: EventProcessor;
  private database: DatabaseService;
  private analytics: AnalyticsService;
  private notifications: NotificationService;

  constructor() {
    this.eventProcessor = new EventProcessor();
    this.database = new DatabaseService();
    this.analytics = new AnalyticsService();
    this.notifications = new NotificationService();
  }

  /**
   * Main webhook handler
   */
  public async handleWebhook(
    body: any,
    headers: any
  ): Promise<{ success: boolean; eventType: string }> {
    // 1. Verify webhook signature
    if (!verifyWebhookSignature(body, headers)) {
      throw new Error('Invalid webhook signature');
    }

    // 2. Parse the event
    const event = body as RevenueCatEvent;
    const eventType = event.type as EventType;

    logger.info(`📦 Processing webhook event: ${eventType}`, {
      eventId: event.id,
      productId: event.product_id,
      subscriberId: event.subscriber_id,
    });

    // 3. Process the event based on type
    let result: any;

    switch (eventType) {
      case EventType.INITIAL_PURCHASE:
        result = await this.handleInitialPurchase(event);
        break;
      
      case EventType.RENEWAL:
        result = await this.handleRenewal(event);
        break;
      
      case EventType.CANCELLATION:
        result = await this.handleCancellation(event);
        break;
      
      case EventType.EXPIRATION:
        result = await this.handleExpiration(event);
        break;
      
      case EventType.REFUND:
        result = await this.handleRefund(event);
        break;
      
      case EventType.BILLING_ISSUE:
        result = await this.handleBillingIssue(event);
        break;
      
      case EventType.GRACE_PERIOD:
        result = await this.handleGracePeriod(event);
        break;
      
      case EventType.PRODUCT_CHANGE:
        result = await this.handleProductChange(event);
        break;
      
      default:
        logger.warn(`⚠️ Unknown webhook event type: ${eventType}`);
        return { success: true, eventType };
    }

    return { success: true, eventType };
  }

  /**
   * Handle initial purchase
   */
  private async handleInitialPurchase(event: RevenueCatEvent): Promise<void> {
    logger.info(`🎉 New subscription purchased`, {
      subscriberId: event.subscriber_id,
      productId: event.product_id,
      price: event.price,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'active',
      startDate: new Date(event.purchase_date),
      expirationDate: new Date(event.expiration_date),
      transactionId: event.transaction_id,
    });

    // Send welcome email
    await this.notifications.sendWelcomeEmail(event.subscriber_id, {
      productId: event.product_id,
      expirationDate: new Date(event.expiration_date),
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'subscription_purchase',
      productId: event.product_id,
      price: event.price,
      currency: event.currency,
    });

    // Update user's premium status in your auth system
    await this.updatePremiumStatus(event.subscriber_id, true);
  }

  /**
   * Handle successful renewal
   */
  private async handleRenewal(event: RevenueCatEvent): Promise<void> {
    logger.info(`🔄 Subscription renewed`, {
      subscriberId: event.subscriber_id,
      productId: event.product_id,
      newExpiration: event.expiration_date,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'active',
      expirationDate: new Date(event.expiration_date),
      lastRenewalDate: new Date(event.renewal_date || Date.now()),
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'subscription_renewal',
      productId: event.product_id,
    });

    // Ensure premium status is still active
    await this.updatePremiumStatus(event.subscriber_id, true);
  }

  /**
   * Handle cancellation
   */
  private async handleCancellation(event: RevenueCatEvent): Promise<void> {
    logger.info(`📝 Subscription cancelled`, {
      subscriberId: event.subscriber_id,
      productId: event.product_id,
      cancellationReason: event.cancellation_reason,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'cancelled',
      cancellationDate: new Date(event.cancellation_date || Date.now()),
      cancellationReason: event.cancellation_reason,
    });

    // Send cancellation confirmation
    await this.notifications.sendCancellationEmail(event.subscriber_id, {
      productId: event.product_id,
      expirationDate: new Date(event.expiration_date),
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'subscription_cancelled',
      productId: event.product_id,
      reason: event.cancellation_reason,
    });

    // Don't revoke access immediately - they still have access until expiration
  }

  /**
   * Handle expiration
   */
  private async handleExpiration(event: RevenueCatEvent): Promise<void> {
    logger.info(`⏰ Subscription expired`, {
      subscriberId: event.subscriber_id,
      productId: event.product_id,
      expirationDate: event.expiration_date,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'expired',
      expirationDate: new Date(event.expiration_date),
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'subscription_expired',
      productId: event.product_id,
    });

    // Revoke premium status
    await this.updatePremiumStatus(event.subscriber_id, false);

    // Check if user is eligible for win-back campaign
    await this.checkWinBackEligibility(event.subscriber_id);
  }

  /**
   * Handle refund
   */
  private async handleRefund(event: RevenueCatEvent): Promise<void> {
    logger.info(`💰 Refund processed`, {
      subscriberId: event.subscriber_id,
      productId: event.product_id,
      refundAmount: event.refund_amount,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'refunded',
      refundAmount: event.refund_amount,
      refundDate: new Date(event.refund_date || Date.now()),
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'subscription_refunded',
      productId: event.product_id,
      refundAmount: event.refund_amount,
    });

    // Revoke premium status
    await this.updatePremiumStatus(event.subscriber_id, false);

    // Send refund confirmation
    await this.notifications.sendRefundEmail(event.subscriber_id, {
      productId: event.product_id,
      refundAmount: event.refund_amount,
    });
  }

  /**
   * Handle billing issue
   */
  private async handleBillingIssue(event: RevenueCatEvent): Promise<void> {
    logger.info(`💳 Billing issue detected`, {
      subscriberId: event.subscriber_id,
      productId: event.product_id,
      issueType: event.billing_issue_type,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'billing_issue',
      billingIssueType: event.billing_issue_type,
      billingIssueDate: new Date(event.billing_issue_date || Date.now()),
    });

    // Send billing issue email
    await this.notifications.sendBillingIssueEmail(event.subscriber_id, {
      productId: event.product_id,
      issueType: event.billing_issue_type,
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'billing_issue',
      productId: event.product_id,
      issueType: event.billing_issue_type,
    });
  }

  /**
   * Handle grace period
   */
  private async handleGracePeriod(event: RevenueCatEvent): Promise<void> {
    logger.info(`⏳ Grace period started`, {
      subscriberId: event.subscriber_id,
      productId: event.product_id,
      gracePeriodEnd: event.grace_period_end,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      status: 'grace_period',
      gracePeriodEnd: new Date(event.grace_period_end || Date.now()),
    });

    // Send grace period notification
    await this.notifications.sendGracePeriodEmail(event.subscriber_id, {
      productId: event.product_id,
      gracePeriodEnd: new Date(event.grace_period_end || Date.now()),
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'grace_period_started',
      productId: event.product_id,
    });
  }

  /**
   * Handle product change
   */
  private async handleProductChange(event: RevenueCatEvent): Promise<void> {
    logger.info(`🔄 Product changed`, {
      subscriberId: event.subscriber_id,
      oldProductId: event.old_product_id,
      newProductId: event.product_id,
    });

    // Update database
    await this.database.updateUserSubscription({
      userId: event.subscriber_id,
      productId: event.product_id,
      previousProductId: event.old_product_id,
      status: 'active',
      productChangeDate: new Date(event.product_change_date || Date.now()),
    });

    // Track analytics
    await this.analytics.trackSubscriptionEvent({
      userId: event.subscriber_id,
      event: 'product_changed',
      oldProductId: event.old_product_id,
      newProductId: event.product_id,
    });
  }

  /**
   * Update user's premium status in your auth system
   */
  private async updatePremiumStatus(userId: string, isPremium: boolean): Promise<void> {
    try {
      // In production, this would update your auth system (Firebase, Auth0, etc.)
      logger.info(`👤 Updating premium status for user ${userId} to ${isPremium}`);
      
      // Example: Update Firebase Auth custom claims
      // await firebaseAdmin.auth().setCustomUserClaims(userId, {
      //   premium: isPremium,
      //   updatedAt: new Date().toISOString(),
      // });
      
    } catch (error) {
      logger.error('Failed to update premium status', { error, userId });
      // Alert your team - this is critical
    }
  }

  /**
   * Check if user is eligible for win-back campaign
   */
  private async checkWinBackEligibility(userId: string): Promise<void> {
    try {
      // Check if user has been expired for less than 30 days
      // and hasn't been sent a win-back offer recently
      
      const userData = await this.database.getUser(userId);
      if (userData && userData.subscriptionStatus === 'expired') {
        const daysSinceExpiration = Math.floor(
          (Date.now() - new Date(userData.expirationDate).getTime()) / (1000 * 60 * 60 * 24)
        );
        
        if (daysSinceExpiration < 30) {
          logger.info(`🎯 User ${userId} is eligible for win-back campaign`);
          
          // Send win-back offer
          await this.notifications.sendWinBackEmail(userId, {
            daysSinceExpiration,
            offer: '30% off first month',
          });
        }
      }
    } catch (error) {
      logger.error('Failed to check win-back eligibility', { error, userId });
    }
  }
}
```

#### Step 1.6: Security Utilities

**File: `FitTrackPro/backend/src/utils/security.ts`**

```typescript
import crypto from 'crypto';
import * as jwt from 'jsonwebtoken';

/**
 * Security Utilities
 * 
 * Handles webhook verification, JWT authentication, and encryption.
 */

/**
 * Verify RevenueCat webhook signature
 * 
 * RevenueCat signs all webhook requests with a secret key.
 * We verify the signature to ensure the request is legitimate.
 */
export function verifyWebhookSignature(body: any, headers: any): boolean {
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
  if (!secret) {
    console.error('Webhook secret not configured');
    return false;
  }

  try {
    // RevenueCat sends the signature in the X-Webhook-Signature header
    const signature = headers['x-webhook-signature'];
    if (!signature) {
      console.error('No webhook signature found');
      return false;
    }

    // Create the expected signature
    const bodyString = JSON.stringify(body);
    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(bodyString)
      .digest('hex');

    // Compare signatures (constant time comparison)
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expectedSignature)
    );
  } catch (error) {
    console.error('Webhook signature verification failed:', error);
    return false;
  }
}

/**
 * Generate JWT token
 */
export function generateToken(payload: any, expiresIn?: string): string {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error('JWT secret not configured');
  }

  return jwt.sign(payload, secret, {
    expiresIn: expiresIn || process.env.JWT_EXPIRES_IN || '7d',
  });
}

/**
 * Verify JWT token
 */
export function verifyToken(token: string): any {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error('JWT secret not configured');
  }

  try {
    return jwt.verify(token, secret);
  } catch (error) {
    throw new Error('Invalid token');
  }
}

/**
 * Hash data
 */
export function hashData(data: string): string {
  return crypto.createHash('sha256').update(data).digest('hex');
}

/**
 * Encrypt data
 */
export function encryptData(text: string): string {
  const algorithm = 'aes-256-cbc';
  const key = process.env.ENCRYPTION_KEY || 'default-encryption-key';
  const iv = crypto.randomBytes(16);

  const cipher = crypto.createCipheriv(algorithm, Buffer.from(key), iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  return `${iv.toString('hex')}:${encrypted}`;
}

/**
 * Decrypt data
 */
export function decryptData(encryptedText: string): string {
  const algorithm = 'aes-256-cbc';
  const key = process.env.ENCRYPTION_KEY || 'default-encryption-key';

  const parts = encryptedText.split(':');
  const iv = Buffer.from(parts[0], 'hex');
  const encrypted = parts[1];

  const decipher = crypto.createDecipheriv(algorithm, Buffer.from(key), iv);
  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}
```

#### Step 1.7: Create Database Service

**File: `FitTrackPro/backend/src/services/databaseService.ts`**

```typescript
import { logger } from '../utils/logger';

/**
 * Database Service
 * 
 * Handles all database operations for subscription data.
 * This is a mock implementation - in production, you'd use
 * a real database like PostgreSQL, MySQL, or MongoDB.
 */

interface UserSubscription {
  userId: string;
  productId: string;
  status: 'active' | 'cancelled' | 'expired' | 'refunded' | 'billing_issue' | 'grace_period';
  startDate?: Date;
  expirationDate?: Date;
  cancellationDate?: Date;
  cancellationReason?: string;
  lastRenewalDate?: Date;
  previousProductId?: string;
  productChangeDate?: Date;
  transactionId?: string;
  refundAmount?: number;
  refundDate?: Date;
  billingIssueType?: string;
  billingIssueDate?: Date;
  gracePeriodEnd?: Date;
}

interface User {
  id: string;
  email: string;
  displayName: string;
  subscriptionStatus: string;
  expirationDate?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export class DatabaseService {
  // Mock database
  private users: Map<string, User> = new Map();
  private subscriptions: Map<string, UserSubscription[]> = new Map();

  constructor() {
    this.initializeMockData();
  }

  private initializeMockData(): void {
    // Pre-populate with some mock data for testing
    logger.info('📦 Initializing mock database');
  }

  /**
   * Update user subscription
   */
  public async updateUserSubscription(data: Partial<UserSubscription>): Promise<void> {
    if (!data.userId) {
      throw new Error('User ID is required');
    }

    const userId = data.userId;
    const existingSubscriptions = this.subscriptions.get(userId) || [];
    
    // Find existing subscription for this product
    const existingIndex = existingSubscriptions.findIndex(
      sub => sub.productId === data.productId
    );

    if (existingIndex >= 0) {
      // Update existing subscription
      existingSubscriptions[existingIndex] = {
        ...existingSubscriptions[existingIndex],
        ...data,
      };
      this.subscriptions.set(userId, existingSubscriptions);
    } else {
      // Create new subscription
      existingSubscriptions.push(data as UserSubscription);
      this.subscriptions.set(userId, existingSubscriptions);
    }

    // Update user record
    await this.updateUserStatus(userId);
  }

  /**
   * Get user by ID
   */
  public async getUser(userId: string): Promise<User | null> {
    return this.users.get(userId) || null;
  }

  /**
   * Get user by email
   */
  public async getUserByEmail(email: string): Promise<User | null> {
    for (const user of this.users.values()) {
      if (user.email === email) {
        return user;
      }
    }
    return null;
  }

  /**
   * Create or update user
   */
  public async upsertUser(userData: Partial<User>): Promise<User> {
    const existing = await this.getUser(userData.id!);
    
    const user: User = {
      id: userData.id!,
      email: userData.email || '',
      displayName: userData.displayName || '',
      subscriptionStatus: userData.subscriptionStatus || 'inactive',
      expirationDate: userData.expirationDate,
      createdAt: existing?.createdAt || new Date(),
      updatedAt: new Date(),
    };

    this.users.set(user.id, user);
    return user;
  }

  /**
   * Update user status based on subscription data
   */
  private async updateUserStatus(userId: string): Promise<void> {
    const user = this.users.get(userId);
    if (!user) return;

    const subscriptions = this.subscriptions.get(userId) || [];
    const activeSubscription = subscriptions.find(
      sub => sub.status === 'active' || sub.status === 'grace_period'
    );

    user.subscriptionStatus = activeSubscription ? 'premium' : 'free';
    user.expirationDate = activeSubscription?.expirationDate;
    user.updatedAt = new Date();

    this.users.set(userId, user);
  }

  /**
   * Get all active subscriptions (for monitoring)
   */
  public async getActiveSubscriptions(): Promise<UserSubscription[]> {
    const allSubscriptions: UserSubscription[] = [];
    for (const subArray of this.subscriptions.values()) {
      allSubscriptions.push(...subArray);
    }
    return allSubscriptions.filter(sub => sub.status === 'active');
  }

  /**
   * Get subscription metrics
   */
  public async getSubscriptionMetrics(): Promise<any> {
    const activeSubscriptions = await this.getActiveSubscriptions();
    const totalSubscribers = this.users.size;
    const premiumSubscribers = this.users.values().filter(
      u => u.subscriptionStatus === 'premium'
    ).length;

    return {
      totalSubscribers,
      premiumSubscribers,
      conversionRate: totalSubscribers > 0 ? (premiumSubscribers / totalSubscribers) * 100 : 0,
      activeSubscriptions: activeSubscriptions.length,
      byProduct: this.getProductBreakdown(activeSubscriptions),
    };
  }

  /**
   * Get product breakdown
   */
  private getProductBreakdown(subscriptions: UserSubscription[]): Record<string, number> {
    const breakdown: Record<string, number> = {};
    for (const sub of subscriptions) {
      breakdown[sub.productId] = (breakdown[sub.productId] || 0) + 1;
    }
    return breakdown;
  }
}
```

---

## Phase 2: Analytics Integration

### The Target

Integrate analytics platforms to track revenue metrics and user behavior.

### The Concept

Analytics is crucial for understanding your subscription business. You need to track:

1. **Revenue Metrics**: MRR, ARR, ARPU, LTV
2. **Conversion Metrics**: Trial conversion rate, purchase conversion
3. **Retention Metrics**: Churn rate, retention rate
4. **User Metrics**: Active users, new users, returning users

We'll integrate with multiple analytics platforms to show how to send data to your preferred provider.

### Implementation

**File: `FitTrackPro/backend/src/services/analyticsService.ts`**

```typescript
import { logger } from '../utils/logger';
import * as crypto from 'crypto';

/**
 * Analytics Service
 * 
 * Handles analytics tracking across multiple platforms.
 * Currently supports:
 * - Mixpanel
 * - Amplitude
 * - PostHog
 * - Custom analytics (your own database)
 * 
 * 📊 This service is the central hub for all analytics tracking.
 */

interface AnalyticsEvent {
  userId: string;
  event: string;
  properties?: Record<string, any>;
  timestamp?: Date;
}

export class AnalyticsService {
  private isEnabled: boolean = true;

  constructor() {
    this.isEnabled = process.env.ENABLE_ANALYTICS !== 'false';
    logger.info(`📊 Analytics service initialized (enabled: ${this.isEnabled})`);
  }

  /**
   * Track a subscription event
   */
  public async trackSubscriptionEvent(data: {
    userId: string;
    event: string;
    productId?: string;
    price?: number;
    currency?: string;
    reason?: string;
    refundAmount?: number;
    oldProductId?: string;
    newProductId?: string;
    issueType?: string;
  }): Promise<void> {
    if (!this.isEnabled) return;

    const event: AnalyticsEvent = {
      userId: data.userId,
      event: data.event,
      properties: {
        productId: data.productId,
        price: data.price,
        currency: data.currency,
        reason: data.reason,
        refundAmount: data.refundAmount,
        oldProductId: data.oldProductId,
        newProductId: data.newProductId,
        issueType: data.issueType,
        timestamp: new Date().toISOString(),
        platform: 'revenuecat',
      },
    };

    // Track to all configured analytics platforms
    await Promise.all([
      this.trackMixpanel(event),
      this.trackAmplitude(event),
      this.trackPostHog(event),
      this.trackCustomAnalytics(event),
    ]);

    logger.debug(`📊 Tracked analytics event: ${data.event}`, data);
  }

  /**
   * Track to Mixpanel
   */
  private async trackMixpanel(event: AnalyticsEvent): Promise<void> {
    const token = process.env.MIXPANEL_TOKEN;
    if (!token) return;

    try {
      // In production, use the Mixpanel SDK
      // For this tutorial, we'll simulate the call
      logger.debug(`📊 Mixpanel: ${event.event}`, {
        token,
        distinct_id: event.userId,
        properties: event.properties,
      });

      // Simulated Mixpanel API call
      // await mixpanel.track(event.event, {
      //   distinct_id: event.userId,
      //   ...event.properties,
      // });
    } catch (error) {
      logger.error('Failed to track to Mixpanel', { error, event });
    }
  }

  /**
   * Track to Amplitude
   */
  private async trackAmplitude(event: AnalyticsEvent): Promise<void> {
    const apiKey = process.env.AMPLITUDE_API_KEY;
    if (!apiKey) return;

    try {
      // In production, use the Amplitude SDK
      logger.debug(`📊 Amplitude: ${event.event}`, {
        apiKey,
        user_id: event.userId,
        event_type: event.event,
        event_properties: event.properties,
      });

      // Simulated Amplitude API call
      // await amplitude.track(event.event, {
      //   user_id: event.userId,
      //   event_properties: event.properties,
      // });
    } catch (error) {
      logger.error('Failed to track to Amplitude', { error, event });
    }
  }

  /**
   * Track to PostHog
   */
  private async trackPostHog(event: AnalyticsEvent): Promise<void> {
    const apiKey = process.env.POSTHOG_API_KEY;
    if (!apiKey) return;

    try {
      // In production, use the PostHog SDK
      logger.debug(`📊 PostHog: ${event.event}`, {
        apiKey,
        distinct_id: event.userId,
        event: event.event,
        properties: event.properties,
      });

      // Simulated PostHog API call
      // await posthog.capture(event.event, {
      //   distinctId: event.userId,
      //   properties: event.properties,
      // });
    } catch (error) {
      logger.error('Failed to track to PostHog', { error, event });
    }
  }

  /**
   * Track to custom analytics (your own database)
   */
  private async trackCustomAnalytics(event: AnalyticsEvent): Promise<void> {
    try {
      // In production, you'd store this in your database
      // for custom reporting and dashboards
      
      const analyticsEvent = {
        id: crypto.randomUUID(),
        ...event,
        timestamp: event.timestamp || new Date(),
        createdAt: new Date(),
      };

      logger.debug(`📊 Custom analytics: ${event.event}`, analyticsEvent);

      // Store in database
      // await db.collection('analytics_events').insertOne(analyticsEvent);

    } catch (error) {
      logger.error('Failed to track custom analytics', { error, event });
    }
  }

  /**
   * Track user signup
   */
  public async trackUserSignup(userId: string, userData: any): Promise<void> {
    await this.trackSubscriptionEvent({
      userId,
      event: 'user_signup',
      ...userData,
    });
  }

  /**
   * Track paywall view
   */
  public async trackPaywallView(userId: string, properties?: any): Promise<void> {
    await this.trackSubscriptionEvent({
      userId,
      event: 'paywall_viewed',
      ...properties,
    });
  }

  /**
   * Track offer presentation
   */
  public async trackOfferPresented(userId: string, offerId: string, properties?: any): Promise<void> {
    await this.trackSubscriptionEvent({
      userId,
      event: 'offer_presented',
      properties: {
        offerId,
        ...properties,
      },
    });
  }

  /**
   * Track conversion metrics
   */
  public async trackConversion(
    userId: string,
    conversionType: 'free_to_premium' | 'trial_to_premium' | 'reactivation',
    properties?: any
  ): Promise<void> {
    await this.trackSubscriptionEvent({
      userId,
      event: 'conversion',
      properties: {
        conversionType,
        ...properties,
      },
    });
  }

  /**
   * Get analytics dashboard data (for API)
   */
  public async getDashboardData(startDate: Date, endDate: Date): Promise<any> {
    // In production, this would query your analytics database
    // For this tutorial, we'll return mock data
    
    return {
      period: {
        start: startDate.toISOString(),
        end: endDate.toISOString(),
      },
      metrics: {
        mrr: 12500,
        arr: 150000,
        arpu: 25,
        ltv: 120,
        conversionRate: 15.5,
        churnRate: 3.2,
        subscribers: {
          total: 500,
          new: 45,
          lost: 16,
        },
        revenue: {
          total: 12500,
          byProduct: {
            'monthly': 5000,
            'annual': 7500,
          },
        },
      },
      trends: {
        subscriptions: [
          { date: '2026-01-01', value: 450 },
          { date: '2026-01-02', value: 460 },
          { date: '2026-01-03', value: 470 },
          { date: '2026-01-04', value: 480 },
          { date: '2026-01-05', value: 490 },
          { date: '2026-01-06', value: 500 },
        ],
        revenue: [
          { date: '2026-01-01', value: 11000 },
          { date: '2026-01-02', value: 11500 },
          { date: '2026-01-03', value: 11800 },
          { date: '2026-01-04', value: 12000 },
          { date: '2026-01-05', value: 12200 },
          { date: '2026-01-06', value: 12500 },
        ],
      },
    };
  }
}
```

---

## Phase 3: Churn Reduction Strategies

### The Target

Implement strategies to reduce churn and improve retention.

### The Concept

Churn reduction is about keeping your subscribers happy and preventing them from leaving. Key strategies include:

1. **Grace Periods**: Give users extra time to update payment information
2. **Win-Back Campaigns**: Offer incentives to return after cancelling
3. **Smart Notifications**: Send timely, relevant messages
4. **Usage-Based Retention**: Encourage engagement to build habit

### Implementation

**File: `FitTrackPro/backend/src/services/notificationService.ts`**

```typescript
import { logger } from '../utils/logger';
import { DatabaseService } from './databaseService';

/**
 * Notification Service
 * 
 * Handles all notifications related to subscriptions.
 * This is the backbone of your retention strategy.
 * 
 * 📨 Each notification type is designed to:
 * 1. Provide value to the user
 * 2. Address a specific pain point
 * 3. Encourage continued engagement
 * 
 * Types of notifications:
 * - Welcome: Onboarding and getting started
 * - Engagement: Usage tips and progress updates
 * - Billing: Payment issues and upcoming renewals
 * - Win-Back: Offers to re-subscribe
 */

interface EmailOptions {
  userId: string;
  template: string;
  data: Record<string, any>;
  priority?: 'high' | 'normal' | 'low';
}

export class NotificationService {
  private database: DatabaseService;

  constructor() {
    this.database = new DatabaseService();
  }

  /**
   * Send welcome email
   */
  public async sendWelcomeEmail(
    userId: string,
    data: { productId: string; expirationDate: Date }
  ): Promise<void> {
    logger.info(`📧 Sending welcome email to user ${userId}`);

    const user = await this.database.getUser(userId);
    if (!user) {
      logger.warn(`User ${userId} not found for welcome email`);
      return;
    }

    const emailData = {
      to: user.email,
      subject: 'Welcome to FitTrack Pro! 🎉',
      template: 'welcome',
      data: {
        displayName: user.displayName,
        productId: data.productId,
        expirationDate: data.expirationDate.toLocaleDateString(),
        features: [
          'Access to 500+ premium workouts',
          'Personalized nutrition tracking',
          'Direct chat with certified trainers',
          'Progress tracking and analytics',
          'Custom workout plans',
        ],
        supportEmail: process.env.EMAIL_FROM || 'support@fittrackpro.com',
      },
    };

    await this.sendEmail(emailData);
  }

  /**
   * Send cancellation confirmation email
   */
  public async sendCancellationEmail(
    userId: string,
    data: { productId: string; expirationDate: Date }
  ): Promise<void> {
    logger.info(`📧 Sending cancellation confirmation to user ${userId}`);

    const user = await this.database.getUser(userId);
    if (!user) return;

    const emailData = {
      to: user.email,
      subject: 'Your subscription has been cancelled',
      template: 'cancellation',
      data: {
        displayName: user.displayName,
        productId: data.productId,
        expirationDate: data.expirationDate.toLocaleDateString(),
        reactivationUrl: 'https://fittrackpro.com/reactivate',
        supportEmail: process.env.EMAIL_FROM || 'support@fittrackpro.com',
      },
    };

    await this.sendEmail(emailData);
  }

  /**
   * Send refund confirmation email
   */
  public async sendRefundEmail(
    userId: string,
    data: { productId: string; refundAmount: number }
  ): Promise<void> {
    logger.info(`📧 Sending refund confirmation to user ${userId}`);

    const user = await this.database.getUser(userId);
    if (!user) return;

    const emailData = {
      to: user.email,
      subject: 'Your refund has been processed',
      template: 'refund',
      data: {
        displayName: user.displayName,
        productId: data.productId,
        refundAmount: data.refundAmount.toFixed(2),
        supportEmail: process.env.EMAIL_FROM || 'support@fittrackpro.com',
      },
    };

    await this.sendEmail(emailData);
  }

  /**
   * Send billing issue email
   */
  public async sendBillingIssueEmail(
    userId: string,
    data: { productId: string; issueType: string }
  ): Promise<void> {
    logger.info(`📧 Sending billing issue email to user ${userId}`);

    const user = await this.database.getUser(userId);
    if (!user) return;

    const emailData = {
      to: user.email,
      subject: '⚠️ Payment issue with your subscription',
      template: 'billing_issue',
      data: {
        displayName: user.displayName,
        productId: data.productId,
        issueType: data.issueType,
        updatePaymentUrl: 'https://fittrackpro.com/update-payment',
        supportEmail: process.env.EMAIL_FROM || 'support@fittrackpro.com',
      },
      priority: 'high',
    };

    await this.sendEmail(emailData);
  }

  /**
   * Send grace period notification
   */
  public async sendGracePeriodEmail(
    userId: string,
    data: { productId: string; gracePeriodEnd: Date }
  ): Promise<void> {
    logger.info(`📧 Sending grace period email to user ${userId}`);

    const user = await this.database.getUser(userId);
    if (!user) return;

    const daysLeft = Math.ceil(
      (data.gracePeriodEnd.getTime() - Date.now()) / (1000 * 60 * 60 * 24)
    );

    const emailData = {
      to: user.email,
      subject: `⏰ Your subscription will end in ${daysLeft} days`,
      template: 'grace_period',
      data: {
        displayName: user.displayName,
        productId: data.productId,
        daysLeft,
        gracePeriodEnd: data.gracePeriodEnd.toLocaleDateString(),
        updatePaymentUrl: 'https://fittrackpro.com/update-payment',
        supportEmail: process.env.EMAIL_FROM || 'support@fittrackpro.com',
      },
      priority: 'high',
    };

    await this.sendEmail(emailData);
  }

  /**
   * Send win-back email
   */
  public async sendWinBackEmail(
    userId: string,
    data: { daysSinceExpiration: number; offer: string }
  ): Promise<void> {
    logger.info(`📧 Sending win-back email to user ${userId}`);

    const user = await this.database.getUser(userId);
    if (!user) return;

    const emailData = {
      to: user.email,
      subject: "We miss you! Come back to FitTrack Pro 💪",
      template: 'win_back',
      data: {
        displayName: user.displayName,
        daysSinceExpiration: data.daysSinceExpiration,
        offer: data.offer,
        reactivationUrl: 'https://fittrackpro.com/reactivate?offer=winback',
        features: [
          'All your workout history is saved',
          'New features added since you left',
          'Special discount just for you',
        ],
        supportEmail: process.env.EMAIL_FROM || 'support@fittrackpro.com',
      },
    };

    await this.sendEmail(emailData);
  }

  /**
   * Send push notification
   */
  public async sendPushNotification(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, any>
  ): Promise<void> {
    logger.info(`📱 Sending push notification to user ${userId}`, {
      title,
      body,
      data,
    });

    // In production, this would use FCM or APNS
    // For this tutorial, we'll log it
  }

  /**
   * Send email (mock implementation)
   */
  private async sendEmail(options: EmailOptions): Promise<void> {
    // In production, this would use a service like SendGrid, Postmark, or AWS SES
    // For this tutorial, we'll just log it

    const priority = options.priority || 'normal';
    
    logger.info(`📧 Sending ${priority} priority email`, {
      to: options.to,
      template: options.template,
      data: options.data,
    });

    // Simulate email sending
    await new Promise(resolve => setTimeout(resolve, 100));

    // In a real implementation, you'd integrate with an email service:
    // const response = await sendgrid.send({
    //   to: options.to,
    //   template: options.template,
    //   data: options.data,
    // });

    // Track email analytics
    await this.trackEmailSent(options);
  }

  /**
   * Track email sending (for analytics)
   */
  private async trackEmailSent(options: EmailOptions): Promise<void> {
    try {
      // In production, you'd send this to your analytics platform
      logger.debug(`📊 Tracked email sent: ${options.template}`, {
        to: options.to,
        priority: options.priority,
      });
    } catch (error) {
      logger.error('Failed to track email', { error });
    }
  }
}
```

---

## Phase 4: RevenueCat Experiments Integration

### The Target

Set up RevenueCat Experiments for A/B testing paywalls and offers.

### The Concept

RevenueCat Experiments allows you to:

1. **A/B Test Paywalls**: Test different designs and pricing
2. **Test Offers**: Compare different promotional offers
3. **Optimize Conversion**: Find what works best for your audience
4. **Measure Impact**: See how changes affect revenue

### Implementation

**File: `FitTrackPro/backend/src/services/experimentService.ts`**

```typescript
import { logger } from '../utils/logger';
import { DatabaseService } from './databaseService';
import { AnalyticsService } from './analyticsService';

/**
 * Experiment Service
 * 
 * Manages A/B testing experiments using RevenueCat Experiments.
 * 
 * 🧪 This service:
 * 1. Tracks which experiment users are in
 * 2. Records experiment events
 * 3. Analyzes experiment results
 * 4. Helps you make data-driven decisions
 */

interface Experiment {
  id: string;
  name: string;
  description: string;
  startDate: Date;
  endDate?: Date;
  status: 'active' | 'completed' | 'paused';
  metrics: string[];
  variants: ExperimentVariant[];
}

interface ExperimentVariant {
  id: string;
  name: string;
  weight: number; // 0-1 percentage of users
  configuration: Record<string, any>;
  performance: ExperimentPerformance;
}

interface ExperimentPerformance {
  impressions: number;
  conversions: number;
  revenue: number;
  conversionRate: number;
  uplift: number; // percentage improvement over control
}

export class ExperimentService {
  private database: DatabaseService;
  private analytics: AnalyticsService;
  private experiments: Map<string, Experiment> = new Map();

  constructor() {
    this.database = new DatabaseService();
    this.analytics = new AnalyticsService();
    this.initializeExperiments();
  }

  private initializeExperiments(): void {
    // Load experiments from database or configuration
    // For this tutorial, we'll create some mock experiments
    this.loadMockExperiments();
  }

  private loadMockExperiments(): void {
    const experiment: Experiment = {
      id: 'paywall_design_001',
      name: 'Paywall Design Test',
      description: 'Testing different paywall layouts and messaging',
      startDate: new Date('2026-01-01'),
      status: 'active',
      metrics: ['conversion_rate', 'average_revenue_per_user'],
      variants: [
        {
          id: 'control',
          name: 'Control',
          weight: 0.5,
          configuration: {
            layout: 'standard',
            priceDisplay: 'emphasis',
            features: ['all'],
          },
          performance: {
            impressions: 10000,
            conversions: 1500,
            revenue: 25000,
            conversionRate: 0.15,
            uplift: 0,
          },
        },
        {
          id: 'variant_a',
          name: 'Variant A - Simplified',
          weight: 0.25,
          configuration: {
            layout: 'simplified',
            priceDisplay: 'minimal',
            features: ['highlighted'],
          },
          performance: {
            impressions: 5000,
            conversions: 900,
            revenue: 15000,
            conversionRate: 0.18,
            uplift: 20,
          },
        },
        {
          id: 'variant_b',
          name: 'Variant B - Premium',
          weight: 0.25,
          configuration: {
            layout: 'premium',
            priceDisplay: 'detailed',
            features: ['all', 'bonus'],
          },
          performance: {
            impressions: 5000,
            conversions: 1000,
            revenue: 18000,
            conversionRate: 0.20,
            uplift: 33.3,
          },
        },
      ],
    };

    this.experiments.set(experiment.id, experiment);
  }

  /**
   * Get active experiment for a user
   * 
   * Uses consistent hashing to assign users to variants
   */
  public async getExperimentForUser(
    userId: string,
    experimentId: string
  ): Promise<ExperimentVariant | null> {
    const experiment = this.experiments.get(experimentId);
    if (!experiment || experiment.status !== 'active') {
      return null;
    }

    // Use consistent hashing to assign user to variant
    const hash = this.hashUserId(userId, experimentId);
    const totalWeight = experiment.variants.reduce((sum, v) => sum + v.weight, 0);
    let cumulative = 0;

    for (const variant of experiment.variants) {
      cumulative += variant.weight / totalWeight;
      if (hash < cumulative) {
        return variant;
      }
    }

    // Fallback to the last variant
    return experiment.variants[experiment.variants.length - 1];
  }

  /**
   * Track experiment impression
   */
  public async trackImpression(
    userId: string,
    experimentId: string,
    variantId: string
  ): Promise<void> {
    const experiment = this.experiments.get(experimentId);
    if (!experiment) return;

    const variant = experiment.variants.find(v => v.id === variantId);
    if (!variant) return;

    variant.performance.impressions++;

    await this.analytics.trackSubscriptionEvent({
      userId,
      event: 'experiment_impression',
      properties: {
        experimentId,
        variantId,
      },
    });

    logger.debug(`🧪 Tracked experiment impression`, {
      experimentId,
      variantId,
      userId,
    });
  }

  /**
   * Track experiment conversion
   */
  public async trackConversion(
    userId: string,
    experimentId: string,
    variantId: string,
    revenue: number
  ): Promise<void> {
    const experiment = this.experiments.get(experimentId);
    if (!experiment) return;

    const variant = experiment.variants.find(v => v.id === variantId);
    if (!variant) return;

    variant.performance.conversions++;
    variant.performance.revenue += revenue;
    variant.performance.conversionRate =
      variant.performance.conversions / variant.performance.impressions;

    await this.analytics.trackSubscriptionEvent({
      userId,
      event: 'experiment_conversion',
      properties: {
        experimentId,
        variantId,
        revenue,
      },
    });

    logger.debug(`🧪 Tracked experiment conversion`, {
      experimentId,
      variantId,
      revenue,
      userId,
    });
  }

  /**
   * Get experiment results
   */
  public async getExperimentResults(experimentId: string): Promise<any> {
    const experiment = this.experiments.get(experimentId);
    if (!experiment) return null;

    const results = {
      experimentId: experiment.id,
      name: experiment.name,
      status: experiment.status,
      startDate: experiment.startDate,
      endDate: experiment.endDate,
      variants: experiment.variants.map(v => ({
        id: v.id,
        name: v.name,
        impressions: v.performance.impressions,
        conversions: v.performance.conversions,
        revenue: v.performance.revenue,
        conversionRate: (v.performance.conversionRate * 100).toFixed(2) + '%',
        uplift: v.performance.uplift.toFixed(1) + '%',
        isWinner: this.isVariantWinner(v, experiment.variants),
      })),
    };

    return results;
  }

  /**
   * Determine if a variant is a statistical winner
   */
  private isVariantWinner(
    variant: ExperimentVariant,
    allVariants: ExperimentVariant[]
  ): boolean {
    if (variant.performance.conversions === 0) return false;

    // Simple check - in production, use statistical significance testing
    // (e.g., Chi-square test, t-test)
    const control = allVariants.find(v => v.id === 'control');
    if (!control || control.id === variant.id) return false;

    return variant.performance.conversionRate > control.performance.conversionRate;
  }

  /**
   * Hash user ID for consistent assignment
   */
  private hashUserId(userId: string, experimentId: string): number {
    const combined = userId + ':' + experimentId;
    let hash = 0;
    for (let i = 0; i < combined.length; i++) {
      const char = combined.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash) / 2147483647; // Normalize to 0-1
  }

  /**
   * Get all active experiments
   */
  public async getActiveExperiments(): Promise<Experiment[]> {
    return Array.from(this.experiments.values()).filter(
      e => e.status === 'active'
    );
  }

  /**
   * Create a new experiment
   */
  public async createExperiment(data: Partial<Experiment>): Promise<Experiment> {
    const experiment: Experiment = {
      id: `experiment_${Date.now()}`,
      name: data.name || 'New Experiment',
      description: data.description || '',
      startDate: data.startDate || new Date(),
      status: 'active',
      metrics: data.metrics || ['conversion_rate'],
      variants: data.variants || [],
    };

    this.experiments.set(experiment.id, experiment);
    logger.info(`🧪 Created new experiment: ${experiment.id}`);

    return experiment;
  }

  /**
   * Update experiment status
   */
  public async updateExperimentStatus(
    experimentId: string,
    status: 'active' | 'completed' | 'paused'
  ): Promise<void> {
    const experiment = this.experiments.get(experimentId);
    if (!experiment) {
      throw new Error(`Experiment ${experimentId} not found`);
    }

    experiment.status = status;
    if (status === 'completed') {
      experiment.endDate = new Date();
    }

    logger.info(`🧪 Updated experiment status: ${experimentId} -> ${status}`);
  }
}
```

---

## Phase 5: Monitoring & Alerting

### The Target

Implement monitoring and alerting to proactively catch issues.

### The Concept

Monitoring is essential for production apps. You need to know when:

1. **Revenue Drops**: Unexpected drop in subscriptions
2. **Errors Spike**: Webhook failures or API errors
3. **Churn Increases**: Higher than normal cancellation rate
4. **Billing Issues**: Many failed payments

### Implementation

**File: `FitTrackPro/backend/src/services/monitoringService.ts`**

```typescript
import { logger } from '../utils/logger';
import { DatabaseService } from './databaseService';
import { AnalyticsService } from './analyticsService';

/**
 * Monitoring Service
 * 
 * Tracks key metrics and alerts on anomalies.
 * 
 * 🚨 This service monitors:
 * - Revenue metrics (MRR, ARPU)
 * - Subscription metrics (activations, cancellations, churn)
 * - Error rates
 * - Performance metrics
 * 
 * When anomalies are detected, it triggers alerts.
 */

interface Metric {
  name: string;
  value: number;
  timestamp: Date;
  threshold?: number;
  alert?: boolean;
}

interface Alert {
  id: string;
  type: 'warning' | 'critical' | 'info';
  message: string;
  metric: string;
  value: number;
  threshold: number;
  timestamp: Date;
  acknowledged: boolean;
  resolved: boolean;
}

export class MonitoringService {
  private database: DatabaseService;
  private analytics: AnalyticsService;
  private metrics: Metric[] = [];
  private alerts: Alert[] = [];
  private alertHandlers: ((alert: Alert) => void)[] = [];

  constructor() {
    this.database = new DatabaseService();
    this.analytics = new AnalyticsService();
    this.startMonitoring();
  }

  private startMonitoring(): void {
    // Check metrics every 5 minutes
    setInterval(() => {
      this.checkMetrics();
    }, 5 * 60 * 1000);
  }

  /**
   * Track a metric
   */
  public trackMetric(name: string, value: number): void {
    const metric: Metric = {
      name,
      value,
      timestamp: new Date(),
    };

    this.metrics.push(metric);

    // Keep only last 1000 metrics
    if (this.metrics.length > 1000) {
      this.metrics.shift();
    }

    logger.debug(`📊 Tracked metric: ${name} = ${value}`);
  }

  /**
   * Check metrics for anomalies
   */
  private async checkMetrics(): Promise<void> {
    // Check revenue metrics
    await this.checkRevenueMetrics();

    // Check subscription metrics
    await this.checkSubscriptionMetrics();

    // Check error rates
    await this.checkErrorRates();

    // Check churn rate
    await this.checkChurnRate();
  }

  /**
   * Check revenue metrics
   */
  private async checkRevenueMetrics(): Promise<void> {
    // In production, this would pull from your analytics database
    // For this tutorial, we'll use mock data
    
    const mockMetrics = {
      mrr: 12500,
      arpu: 25,
      conversionRate: 0.15,
    };

    // Check if metrics are within expected ranges
    if (mockMetrics.mrr < 10000) {
      this.createAlert({
        type: 'warning',
        message: 'MRR dropped below $10,000',
        metric: 'mrr',
        value: mockMetrics.mrr,
        threshold: 10000,
      });
    }

    if (mockMetrics.conversionRate < 0.10) {
      this.createAlert({
        type: 'critical',
        message: 'Conversion rate dropped below 10%',
        metric: 'conversion_rate',
        value: mockMetrics.conversionRate,
        threshold: 0.10,
      });
    }
  }

  /**
   * Check subscription metrics
   */
  private async checkSubscriptionMetrics(): Promise<void> {
    // Get active subscriptions from database
    const subscriptions = await this.database.getActiveSubscriptions();
    const activeCount = subscriptions.length;

    // Check if subscriptions are growing
    if (activeCount < 400) {
      this.createAlert({
        type: 'warning',
        message: `Active subscriptions dropped to ${activeCount}`,
        metric: 'active_subscriptions',
        value: activeCount,
        threshold: 400,
      });
    }
  }

  /**
   * Check error rates
   */
  private async checkErrorRates(): Promise<void> {
    // In production, this would track error rates from logs
    // For this tutorial, we'll check if error rate is high
    
    const errorRate = 0.02; // 2% error rate
    
    if (errorRate > 0.05) {
      this.createAlert({
        type: 'critical',
        message: `Error rate is ${(errorRate * 100).toFixed(1)}%`,
        metric: 'error_rate',
        value: errorRate,
        threshold: 0.05,
      });
    }
  }

  /**
   * Check churn rate
   */
  private async checkChurnRate(): Promise<void> {
    // In production, this would calculate churn from historical data
    const churnRate = 0.03; // 3% churn rate
    
    if (churnRate > 0.05) {
      this.createAlert({
        type: 'critical',
        message: `Churn rate is ${(churnRate * 100).toFixed(1)}%`,
        metric: 'churn_rate',
        value: churnRate,
        threshold: 0.05,
      });
    }
  }

  /**
   * Create an alert
   */
  private createAlert(data: {
    type: 'warning' | 'critical' | 'info';
    message: string;
    metric: string;
    value: number;
    threshold: number;
  }): void {
    const alert: Alert = {
      id: `alert_${Date.now()}`,
      type: data.type,
      message: data.message,
      metric: data.metric,
      value: data.value,
      threshold: data.threshold,
      timestamp: new Date(),
      acknowledged: false,
      resolved: false,
    };

    // Check if similar alert already exists and is not resolved
    const existingAlert = this.alerts.find(
      a => a.metric === alert.metric && !a.resolved
    );

    if (existingAlert) {
      // Update existing alert with new data
      existingAlert.value = alert.value;
      existingAlert.timestamp = alert.timestamp;
      return;
    }

    this.alerts.push(alert);
    this.notifyAlert(alert);

    logger.warn(`🚨 Alert created: ${alert.message}`, alert);
  }

  /**
   * Notify alert handlers
   */
  private notifyAlert(alert: Alert): void {
    // In production, this would send to Slack, PagerDuty, etc.
    
    // Log the alert
    logger.error(`🚨 ${alert.type.toUpperCase()}: ${alert.message}`, {
      metric: alert.metric,
      value: alert.value,
      threshold: alert.threshold,
      timestamp: alert.timestamp,
    });

    // Call all registered alert handlers
    for (const handler of this.alertHandlers) {
      try {
        handler(alert);
      } catch (error) {
        logger.error('Error in alert handler:', error);
      }
    }
  }

  /**
   * Register an alert handler
   */
  public onAlert(handler: (alert: Alert) => void): void {
    this.alertHandlers.push(handler);
  }

  /**
   * Acknowledge an alert
   */
  public acknowledgeAlert(alertId: string): void {
    const alert = this.alerts.find(a => a.id === alertId);
    if (alert) {
      alert.acknowledged = true;
      logger.info(`✅ Alert acknowledged: ${alertId}`);
    }
  }

  /**
   * Resolve an alert
   */
  public resolveAlert(alertId: string): void {
    const alert = this.alerts.find(a => a.id === alertId);
    if (alert) {
      alert.resolved = true;
      logger.info(`✅ Alert resolved: ${alertId}`);
    }
  }

  /**
   * Get all alerts
   */
  public getAlerts(filters?: {
    type?: string;
    resolved?: boolean;
    acknowledged?: boolean;
  }): Alert[] {
    let alerts = this.alerts;

    if (filters?.type) {
      alerts = alerts.filter(a => a.type === filters.type);
    }

    if (filters?.resolved !== undefined) {
      alerts = alerts.filter(a => a.resolved === filters.resolved);
    }

    if (filters?.acknowledged !== undefined) {
      alerts = alerts.filter(a => a.acknowledged === filters.acknowledged);
    }

    return alerts;
  }

  /**
   * Get metrics summary
   */
  public getMetricsSummary(): any {
    const recentMetrics = this.metrics.slice(-100);
    
    const summary: Record<string, { latest: number; avg: number; max: number; min: number }> = {};

    for (const metric of recentMetrics) {
      if (!summary[metric.name]) {
        summary[metric.name] = {
          latest: metric.value,
          avg: metric.value,
          max: metric.value,
          min: metric.value,
        };
      } else {
        const stats = summary[metric.name];
        stats.latest = metric.value;
        stats.avg = (stats.avg + metric.value) / 2;
        stats.max = Math.max(stats.max, metric.value);
        stats.min = Math.min(stats.min, metric.value);
      }
    }

    return summary;
  }
}
```

---

## Verification

### Test Webhook Integration

1. **Local Testing**:
   ```bash
   # Start the backend server
   cd backend
   npm run dev

   # Use ngrok to expose local server
   ngrok http 3000

   # In RevenueCat dashboard, configure webhook URL:
   # https://your-ngrok-url/webhook/revenuecat
   ```

2. **Test Webhook Events**:
   ```bash
   # Use curl to simulate a webhook
   curl -X POST http://localhost:3000/webhook/revenuecat \
     -H "Content-Type: application/json" \
     -H "X-Webhook-Signature: test_signature" \
     -d '{
       "type": "INITIAL_PURCHASE",
       "id": "test_event_123",
       "subscriber_id": "user_123",
       "product_id": "com.yourcompany.fittrackpro.monthly",
       "price": 9.99,
       "currency": "USD"
     }'
   ```

3. **Trigger Real Purchase**:
   - Make a purchase in your app
   - Check that webhook is received
   - Verify database is updated

### Test Analytics Integration

1. **Check Analytics Events**:
   - View logs for analytics events
   - Verify events are being sent to configured platforms

2. **Test Dashboard**:
   ```bash
   curl http://localhost:3000/api/analytics/dashboard?start=2026-01-01&end=2026-01-31
   ```

### Test Monitoring

1. **Check Alerts**:
   - View alerts in logs
   - Test alert triggering

2. **Verify Metrics**:
   ```bash
   curl http://localhost:3000/api/monitoring/metrics
   ```

---

## Module Summary

Congratulations! You've completed Part 4 of the RevenueCat tutorial series. Here's what you've accomplished:

✅ **Built Webhook Infrastructure**: Secure webhook endpoint with signature verification
✅ **Implemented Event Processing**: Handling all subscription lifecycle events
✅ **Integrated Analytics**: Tracking revenue and user metrics
✅ **Added Churn Reduction**: Grace periods, win-back campaigns, smart notifications
✅ **Set Up A/B Testing**: RevenueCat Experiments integration
✅ **Built Monitoring System**: Proactive alerting for issues

### What You Can Do Now

Your backend can:
- Process subscription events in real-time
- Keep your database in sync with RevenueCat
- Track revenue and user metrics
- Reduce churn with targeted campaigns
- Run A/B tests to optimize conversion
- Monitor and alert on critical metrics

### Next Steps

In **Part 5: Integrating RevenueCat with React Native**, we'll:
- Bring everything together in the complete app
- Add navigation between screens
- Implement the full user flow
- Build the final production-ready app

---

You now have a complete backend infrastructure for your subscription business. In Part 5, we'll integrate everything into the final React Native application and prepare for production.
