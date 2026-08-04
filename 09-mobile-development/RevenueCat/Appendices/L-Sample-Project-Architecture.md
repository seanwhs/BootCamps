# Appendix L: Sample Project Architecture

## Overview

This appendix provides a complete reference architecture for a production-grade subscription application built with RevenueCat. It covers the entire system from mobile app to backend infrastructure, including deployment considerations and scaling strategies.

Think of this as your "blueprint" – a comprehensive guide to building a scalable, maintainable subscription application architecture.

---

## 1. System Architecture Overview

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           USER DEVICES                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                       │
│  │   iOS App   │  │ Android App │  │   Web App   │                       │
│  │  (Revenue-  │  │  (Revenue-  │  │  (Revenue-  │                       │
│  │   Cat SDK)  │  │   Cat SDK)  │  │  Cat SDK)   │                       │
│  └─────────────┘  └─────────────┘  └─────────────┘                       │
│         │                │                │                               │
│         └────────────────┼────────────────┘                               │
│                          │                                                │
└──────────────────────────┼────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CDN / API Gateway                                     │
│              (Cloudflare, AWS CloudFront, etc.)                           │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     REVENUECAT PLATFORM                                    │
│                                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                    │
│  │   SDK API    │  │   REST API   │  │   Webhooks   │                    │
│  └──────────────┘  └──────────────┘  └──────────────┘                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                    │
│  │ Entitlements │  │  Offerings   │  │  Analytics   │                    │
│  └──────────────┘  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BACKEND SERVICES                                   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                     API Gateway / Load Balancer                  │      │
│  │                         (AWS ALB / Nginx)                       │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                           │                                                │
│  ┌───────────────────────┼────────────────────────────────────────┐      │
│  │                       │                                        │      │
│  ▼                       ▼                                        ▼      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐         │
│  │   Webhook       │  │   Auth          │  │   Analytics     │         │
│  │   Service       │  │   Service       │  │   Service       │         │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐         │
│  │   User          │  │   Subscription  │  │   Email         │         │
│  │   Service       │  │   Service       │  │   Service       │         │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘         │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      Primary Database                           │      │
│  │                  (PostgreSQL / Amazon RDS)                      │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                           │                                                │
│  ┌───────────────────────┼────────────────────────────────────────┐      │
│  │                       │                                        │      │
│  ▼                       ▼                                        ▼      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐         │
│  │   Users         │  │   Subscriptions │  │   Analytics     │         │
│  │   Table         │  │   Table         │  │   Events        │         │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐         │
│  │   Payments      │  │   Features      │  │   Audit         │         │
│  │   Table         │  │   Table         │  │   Logs          │         │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘         │
│                           │                                                │
│                           ▼                                                │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Cache Layer (Redis)                          │      │
│  │                    Elasticache / Redis Cloud                    │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                           │                                                │
│                           ▼                                                │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Message Queue (SQS / RabbitMQ)               │      │
│  └─────────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EXTERNAL SERVICES                                  │
│                                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                    │
│  │   Auth0 /    │  │   SendGrid   │  │   Mixpanel   │                    │
│  │   Firebase   │  │   Email      │  │   Analytics  │                    │
│  └──────────────┘  └──────────────┘  └──────────────┘                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                    │
│  │   Sentry     │  │   DataDog    │  │   AWS S3     │                    │
│  │   Errors     │  │   Monitoring │  │   Storage    │                    │
│  └──────────────┘  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Mobile Application Architecture

### React Native Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     REACT NATIVE APP STRUCTURE                             │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                       UI Layer                                   │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │   Screens    │  │  Components  │  │  Navigation  │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                     State Management                            │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │    Context   │  │   Redux /   │  │   React     │         │      │
│  │  │    API       │  │   Zustand   │  │   Query     │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      Service Layer                              │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  RevenueCat  │  │  Auth       │  │  API        │         │      │
│  │  │  Service     │  │  Service    │  │  Client     │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      Storage Layer                              │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  Async       │  │  Secure      │  │   MMKV      │         │      │
│  │  │  Storage     │  │  Storage     │  │   Cache     │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### iOS Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      iOS APP STRUCTURE                                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      UI Layer                                    │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │   SwiftUI/   │  │   View       │  │   Storyboard │         │      │
│  │  │   UIKit      │  │   Controllers│  │   Views      │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Business Logic                               │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  RevenueCat  │  │  Auth       │  │  Network    │         │      │
│  │  │  Manager     │  │  Manager    │  │  Manager   │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      Data Layer                                 │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  UserDefaults│  │  Keychain    │  │  CoreData   │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Android Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ANDROID APP STRUCTURE                                   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      UI Layer                                    │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │   Compose/   │  │   Activity/  │  │   View      │         │      │
│  │  │   XML        │  │   Fragment   │  │   Models    │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Business Logic                               │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  RevenueCat  │  │  Auth       │  │  Repository │         │      │
│  │  │  Manager     │  │  Manager    │  │  Pattern   │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      Data Layer                                 │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  SharedPrefs │  │  Room        │  │  DataStore  │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Backend Architecture

### Microservices Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     API GATEWAY / LOAD BALANCER                            │
│                          (Nginx / ALB / Kong)                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
         ▼                          ▼                          ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Auth Service  │    │  Subscription   │    │  Webhook        │
│                 │    │  Service        │    │  Service        │
│ - Login/Signup  │    │  - Sync with RC │    │  - Process RC   │
│ - JWT tokens    │    │  - Entitlements │    │  - Handle       │
│ - User profiles │    │  - History      │    │    events       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                          │                          │
         └──────────────────────────┼──────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MESSAGE QUEUE                                      │
│                         (RabbitMQ / SQS)                                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
         ▼                          ▼                          ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Analytics     │    │   Email         │    │   Notification  │
│   Service       │    │   Service       │    │   Service       │
│ - Track events  │    │  - Welcome      │    │  - Push         │
│ - Revenue       │    │  - Cancellation │    │  - SMS          │
│ - Churn         │    │  - Win-back     │    │  - In-app       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Server-Side SDK Integration

```typescript
// Backend - RevenueCat Integration Service
class RevenueCatBackendService {
  private readonly apiKey: string;
  private readonly baseUrl = 'https://api.revenuecat.com/v1';

  constructor() {
    this.apiKey = process.env.REVENUECAT_SECRET_API_KEY!;
  }

  /**
   * Get subscriber information
   */
  async getSubscriber(userId: string): Promise<any> {
    const response = await fetch(
      `${this.baseUrl}/subscribers/${userId}`,
      {
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
      }
    );

    if (!response.ok) {
      throw new Error(`RevenueCat API error: ${response.statusText}`);
    }

    return response.json();
  }

  /**
   * Update subscriber attributes
   */
  async updateSubscriberAttributes(
    userId: string,
    attributes: Record<string, any>
  ): Promise<void> {
    const response = await fetch(
      `${this.baseUrl}/subscribers/${userId}`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ attributes }),
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to update subscriber: ${response.statusText}`);
    }
  }

  /**
   * Grant entitlement
   */
  async grantEntitlement(
    userId: string,
    entitlementId: string,
    durationDays: number
  ): Promise<void> {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + durationDays);

    const response = await fetch(
      `${this.baseUrl}/subscribers/${userId}/entitlements/${entitlementId}`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          start_date: startDate.toISOString(),
          end_date: endDate.toISOString(),
        }),
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to grant entitlement: ${response.statusText}`);
    }
  }

  /**
   * Revoke entitlement
   */
  async revokeEntitlement(
    userId: string,
    entitlementId: string
  ): Promise<void> {
    const response = await fetch(
      `${this.baseUrl}/subscribers/${userId}/entitlements/${entitlementId}`,
      {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
        },
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to revoke entitlement: ${response.statusText}`);
    }
  }
}
```

---

## 4. Database Schema

### PostgreSQL Schema

```sql
-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    revenuecat_user_id VARCHAR(255) UNIQUE NOT NULL,
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_revenuecat_user_id ON users(revenuecat_user_id);

-- Subscriptions Table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    product_id VARCHAR(255) NOT NULL,
    entitlement_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL, -- 'active', 'cancelled', 'expired', 'refunded'
    start_date TIMESTAMP WITH TIME ZONE,
    expiration_date TIMESTAMP WITH TIME ZONE,
    cancellation_date TIMESTAMP WITH TIME ZONE,
    cancellation_reason VARCHAR(255),
    last_renewal_date TIMESTAMP WITH TIME ZONE,
    transaction_id VARCHAR(255),
    platform VARCHAR(50), -- 'ios', 'android'
    is_sandbox BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_expiration_date ON subscriptions(expiration_date);
CREATE INDEX idx_subscriptions_user_status ON subscriptions(user_id, status);

-- Subscription History Table
CREATE TABLE subscription_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id),
    user_id UUID NOT NULL REFERENCES users(id),
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscription_history_subscription_id ON subscription_history(subscription_id);
CREATE INDEX idx_subscription_history_user_id ON subscription_history(user_id);
CREATE INDEX idx_subscription_history_created_at ON subscription_history(created_at);

-- Entitlements Table
CREATE TABLE entitlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entitlement_id VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_entitlements_entitlement_id ON entitlements(entitlement_id);

-- Audit Logs Table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id VARCHAR(255),
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);

-- Analytics Events Table
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    event_name VARCHAR(100) NOT NULL,
    event_properties JSONB,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_event_name ON analytics_events(event_name);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);
```

---

## 5. Infrastructure & Deployment

### AWS Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS CLOUD ARCHITECTURE                             │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      Route 53 (DNS)                             │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                   CloudFront (CDN)                              │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                      AWS WAF / Shield                          │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                 Application Load Balancer                       │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│         ┌──────────────────────────┼──────────────────────────┐           │
│         │                          │                          │           │
│         ▼                          ▼                          ▼           │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐      │
│  │   EC2 Auto      │    │   ECS / EKS     │    │   Lambda        │      │
│  │   Scaling       │    │   (Containers)  │    │   (Serverless)  │      │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘      │
│         │                          │                          │           │
│         └──────────────────────────┼──────────────────────────┘           │
│                                    │                                       │
│         ┌──────────────────────────┼──────────────────────────┐           │
│         │                          │                          │           │
│         ▼                          ▼                          ▼           │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐      │
│  │   RDS           │    │   Elasticache   │    │   S3            │      │
│  │   (PostgreSQL)  │    │   (Redis)       │    │   (Storage)     │      │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘      │
│         │                          │                          │           │
│         └──────────────────────────┼──────────────────────────┘           │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    SQS (Message Queue)                         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    CloudWatch (Monitoring)                     │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    SNS (Notifications)                         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Kubernetes (EKS) Architecture

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fittrackpro-backend
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fittrackpro-backend
  template:
    metadata:
      labels:
        app: fittrackpro-backend
    spec:
      containers:
      - name: backend
        image: fittrackpro/backend:latest
        ports:
        - containerPort: 3000
        env:
        - name: REVENUECAT_SECRET_API_KEY
          valueFrom:
            secretKeyRef:
              name: revenuecat-secrets
              key: api-key
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-secrets
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secrets
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: fittrackpro-backend-service
  namespace: production
spec:
  selector:
    app: fittrackpro-backend
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: fittrackpro-backend-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: fittrackpro-backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

## 6. CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
        env:
          REVENUECAT_SECRET_API_KEY: ${{ secrets.REVENUECAT_SECRET_API_KEY }}
      
      - name: Run linting
        run: npm run lint
      
      - name: Run type checking
        run: npm run type-check

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
        env:
          REVENUECAT_SECRET_API_KEY: ${{ secrets.REVENUECAT_SECRET_API_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          REDIS_URL: ${{ secrets.REDIS_URL }}
      
      - name: Build Docker image
        run: |
          docker build -t fittrackpro/backend:${{ github.sha }} .
          docker tag fittrackpro/backend:${{ github.sha }} fittrackpro/backend:latest
      
      - name: Push to ECR
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
        run: |
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${{ secrets.ECR_REPOSITORY }}
          docker tag fittrackpro/backend:${{ github.sha }} ${{ secrets.ECR_REPOSITORY }}:latest
          docker push ${{ secrets.ECR_REPOSITORY }}:latest
      
      - name: Deploy to ECS/EKS
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
        run: |
          aws eks update-kubeconfig --region $AWS_REGION --name fittrackpro-cluster
          kubectl set image deployment/fittrackpro-backend backend=${{ secrets.ECR_REPOSITORY }}:latest
          kubectl rollout status deployment/fittrackpro-backend
      
      - name: Run database migrations
        run: npm run migrate
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
      
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          fields: repo,message,commit,author,action,eventName,ref,workflow
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}

  rollback:
    needs: build-and-deploy
    runs-on: ubuntu-latest
    if: failure()
    steps:
      - name: Rollback deployment
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
        run: |
          aws eks update-kubeconfig --region $AWS_REGION --name fittrackpro-cluster
          kubectl rollout undo deployment/fittrackpro-backend
```

---

## 7. Monitoring & Observability

### Monitoring Stack

```typescript
// Monitoring Configuration
interface MonitoringConfig {
  metrics: {
    prometheus: {
      endpoint: string;
      port: number;
    };
    datadog: {
      apiKey: string;
      site: string;
    };
  };
  logging: {
    level: 'debug' | 'info' | 'warn' | 'error';
    elasticsearch: {
      hosts: string[];
      index: string;
    };
  };
  tracing: {
    jaeger: {
      endpoint: string;
      serviceName: string;
    };
  };
  alerting: {
    pagerduty: {
      integrationKey: string;
    };
    slack: {
      webhookUrl: string;
      channel: string;
    };
  };
}

// Metrics Collector
class MetricsCollector {
  private metrics: Record<string, number[]> = {};
  
  trackMetric(name: string, value: number, labels?: Record<string, string>): void {
    // Track metric with labels
    if (!this.metrics[name]) {
      this.metrics[name] = [];
    }
    this.metrics[name].push(value);
    
    // Keep only last 1000 data points
    if (this.metrics[name].length > 1000) {
      this.metrics[name].shift();
    }
    
    // Send to monitoring service
    this.sendToMonitoring(name, value, labels);
  }
  
  private sendToMonitoring(name: string, value: number, labels?: Record<string, string>): void {
    // Send to Prometheus
    // Send to DataDog
    // Send to CloudWatch
  }
  
  getMetric(name: string, statistic: 'avg' | 'max' | 'min' | 'p95'): number | null {
    const values = this.metrics[name];
    if (!values || values.length === 0) return null;
    
    switch (statistic) {
      case 'avg':
        return values.reduce((a, b) => a + b, 0) / values.length;
      case 'max':
        return Math.max(...values);
      case 'min':
        return Math.min(...values);
      case 'p95':
        const sorted = [...values].sort((a, b) => a - b);
        const index = Math.floor(sorted.length * 0.95);
        return sorted[index] || sorted[sorted.length - 1];
      default:
        return null;
    }
  }
}
```

### Key Metrics to Monitor

| Category | Metric | Target | Alert Threshold |
|----------|--------|--------|-----------------|
| **Revenue** | MRR (Monthly Recurring Revenue) | Growing | Drop > 10% |
| **Revenue** | ARPU (Average Revenue Per User) | Increasing | Drop > 15% |
| **Revenue** | LTV (Lifetime Value) | Increasing | Drop > 20% |
| **Subscriptions** | Active Subscribers | Growing | Drop > 5% |
| **Subscriptions** | Churn Rate | < 5% | > 8% |
| **Subscriptions** | Trial Conversion | > 25% | < 20% |
| **Performance** | API Response Time | < 200ms | > 500ms |
| **Performance** | SDK Init Time | < 500ms | > 1s |
| **Performance** | Purchase Time | < 3s | > 5s |
| **Errors** | Purchase Fail Rate | < 1% | > 3% |
| **Errors** | API Error Rate | < 0.5% | > 2% |
| **Errors** | Webhook Fail Rate | < 1% | > 5% |

---

## 8. Security Architecture

### Security Layers

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SECURITY ARCHITECTURE                                 │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Application Security                         │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  API Keys    │  │  JWT Auth    │  │  Rate       │         │      │
│  │  │  Rotation    │  │  Tokens      │  │  Limiting   │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Data Security                                │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  Encryption  │  │  Audit       │  │  Backup     │         │      │
│  │  │  at Rest     │  │  Logs        │  │  Encryption │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Network Security                             │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  WAF         │  │  SSL/TLS     │  │  VPC         │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │                    Compliance                                   │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │      │
│  │  │  GDPR        │  │  CCPA        │  │  PCI DSS    │         │      │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │      │
│  └─────────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Scaling Strategy

### Scaling Guidelines

| Component | Scaling Strategy | Max Scale | 
|-----------|------------------|-----------|
| **Application Servers** | Horizontal (Auto Scaling) | 10 nodes |
| **Database** | Vertical (Read Replicas) | 5 replicas |
| **Cache (Redis)** | Horizontal (Cluster) | 6 nodes |
| **Queue** | Horizontal (Partitions) | Unlimited |
| **CDN** | Global (Edge locations) | Unlimited |
| **RevenueCat SDK** | Automatic (Managed) | Unlimited |

### Performance Optimization Checklist

- [ ] **API Response Times** < 200ms
- [ ] **Database Query Optimization** with indexes
- [ ] **Redis Caching** for frequently accessed data
- [ ] **CDN** for static assets
- [ ] **Rate Limiting** to prevent abuse
- [ ] **Connection Pooling** for database
- [ ] **Compression** for API responses
- [ ] **Websocket** for real-time updates
- [ ] **Batch Processing** for webhooks
- [ ] **Load Testing** before scaling

---

## Summary

This sample architecture provides a comprehensive blueprint for building a production-grade subscription application with RevenueCat. Key components include:

1. **Mobile Apps**: React Native, iOS, Android with RevenueCat SDK
2. **Backend**: Microservices architecture with API gateway
3. **Data**: PostgreSQL with proper indexing and caching
4. **Infrastructure**: AWS cloud with auto-scaling
5. **CI/CD**: Automated testing and deployment
6. **Monitoring**: Comprehensive metrics and alerting
7. **Security**: Multi-layer security architecture
8. **Scaling**: Horizontal and vertical scaling strategies

### Quick Reference

| Component | Technology |
|-----------|------------|
| Mobile Framework | React Native (with Expo) |
| Backend Framework | Node.js/Express or NestJS |
| Database | PostgreSQL (RDS) |
| Cache | Redis (Elasticache) |
| Message Queue | SQS / RabbitMQ |
| Container | Docker / Kubernetes (EKS) |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus + Grafana |
| Logging | ELK Stack / Datadog |
| Security | WAF, SSL/TLS, JWT |
