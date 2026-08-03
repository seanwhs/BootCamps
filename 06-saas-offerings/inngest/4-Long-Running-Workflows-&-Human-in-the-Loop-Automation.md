# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Part 4: Long-Running Workflows & Human-in-the-Loop Automation

## Building Business Processes That Span Days, Weeks, or Months

---

## Module 4.1: Long-Running Workflow Architecture

### The Target

In this module, you'll master the art of building workflows that pause and resume over extended periods—waiting for human decisions, external systems, or scheduled times.

### The Concept

Long-running workflows are like **orchestrating a complex real-world process**:

Imagine you're planning a wedding (your workflow):

1. **Book venue** → Wait for confirmation (could take days)
2. **Hire caterer** → Wait for contract signing (could take weeks)
3. **Send invitations** → Wait for RSVPs (could take months)
4. **Coordinate vendors** → Wait for delivery confirmations (day of event)
5. **Execute the wedding** → All pieces come together

Each step involves waiting for external inputs or human decisions. The workflow might take months to complete, and it needs to survive server restarts, deployments, and failures.

In Inngest, long-running workflows are built using:
- **`step.waitForEvent()`**: Pause and wait for external events
- **`step.sleep()`**: Wait for specific durations
- **`step.sleepUntil()`**: Wait until a specific time
- **Durable state**: Everything is persisted, so the workflow can run for months

### The Implementation: Purchase Approval System

Let's build a comprehensive purchase approval system that demonstrates long-running workflow patterns:

```typescript
// src/inngest/functions/purchase-approval.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define purchase request event
const PurchaseRequestEventSchema = z.object({
  purchaseId: z.string().uuid(),
  userId: z.string().uuid(),
  department: z.string().min(1),
  amount: z.number().positive(),
  description: z.string().min(1),
  vendor: z.string().min(1),
  items: z.array(
    z.object({
      name: z.string(),
      quantity: z.number().int().positive(),
      unitPrice: z.number().positive(),
    })
  ).min(1),
  urgency: z.enum(['low', 'medium', 'high', 'critical']).default('medium'),
  requesterEmail: z.string().email(),
  approverEmail: z.string().email(),
});

// Approval decision event
const ApprovalDecisionEventSchema = z.object({
  purchaseId: z.string().uuid(),
  approved: z.boolean(),
  approver: z.string().email(),
  comments: z.string().optional(),
  timestamp: z.string().datetime(),
});

// Main purchase approval workflow
export const purchaseApprovalWorkflow = inngest.createFunction(
  {
    id: 'purchase-approval-workflow',
    name: 'Purchase Approval System',
    description: 'Coordinate purchase requests with multi-level approval and human-in-the-loop',
    
    // Retry configuration for long-running workflows
    retries: 3,
    retryDelay: '5s',
    
    // Rate limiting
    rateLimit: {
      limit: 10,
      period: '1m',
    },
  },
  { event: 'purchase/requested' },
  async ({ event, step, logger }) => {
    // Step 1: Validate and parse the request
    const validatedRequest = PurchaseRequestEventSchema.parse(event.data);
    const { 
      purchaseId, 
      userId, 
      department, 
      amount, 
      description, 
      vendor, 
      items, 
      urgency,
      requesterEmail,
      approverEmail 
    } = validatedRequest;
    
    logger.info('Processing purchase request', { 
      purchaseId, 
      amount, 
      department, 
      urgency 
    });
    
    // Step 2: Initial validation and risk assessment
    const riskAssessment = await step.run('assess-purchase-risk', async () => {
      logger.info('Assessing purchase risk', { purchaseId, amount });
      
      // Simulate risk assessment
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      // Risk factors: amount, urgency, department
      let riskLevel = 'low';
      let requiresAdditionalApproval = false;
      
      if (amount > 10000) {
        riskLevel = 'high';
        requiresAdditionalApproval = true;
      } else if (amount > 5000) {
        riskLevel = 'medium';
        if (urgency === 'critical') {
          requiresAdditionalApproval = true;
        }
      }
      
      return {
        riskLevel,
        requiresAdditionalApproval,
        assessmentId: `risk-${purchaseId}`,
        assessedAt: new Date().toISOString(),
      };
    });
    
    // Step 3: Send initial approval request to approver
    await step.run('send-approval-request', async () => {
      logger.info('Sending approval request', { 
        purchaseId, 
        approverEmail, 
        amount 
      });
      
      // Simulate sending email
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      // In a real app, you'd send an email with a link to approve/deny
      // The link would trigger an event with the decision
      
      return {
        sent: true,
        sentAt: new Date().toISOString(),
        messageId: `approval-${purchaseId}`,
        approveLink: `https://workflowhub.com/approve/${purchaseId}`,
        denyLink: `https://workflowhub.com/deny/${purchaseId}`,
      };
    });
    
    // Step 4: WAIT FOR APPROVAL DECISION
    // This is the critical part - the workflow pauses and waits
    // The `step.waitForEvent()` function pauses execution until
    // the specified event is received or timeout occurs
    
    let approvalDecision: any;
    let decisionTimeout = false;
    
    try {
      // Calculate timeout based on urgency
      const timeoutMap = {
        critical: '1h',
        high: '4h',
        medium: '24h',
        low: '72h',
      };
      
      const timeout = timeoutMap[urgency] || '24h';
      
      logger.info('Waiting for approval decision', { 
        purchaseId, 
        timeout,
        expiresAt: new Date(Date.now() + parseDuration(timeout)).toISOString()
      });
      
      // Wait for the approval decision event
      // This workflow will pause here until:
      // 1. The approval decision event is received
      // 2. The timeout is reached
      // 3. The workflow is cancelled
      approvalDecision = await step.waitForEvent('wait-for-approval', {
        event: 'purchase/approved', // The event to wait for
        timeout, // How long to wait
        match: 'data.purchaseId', // Match on purchaseId
        match: (data: any) => data.purchaseId === purchaseId, // Alternative matching
      });
      
      logger.info('Received approval decision', { 
        purchaseId, 
        approved: approvalDecision?.data?.approved 
      });
      
    } catch (error) {
      // If the wait times out, an error is thrown
      logger.warn('Approval decision timeout', { purchaseId, timeout: timeoutMap[urgency] });
      decisionTimeout = true;
    }
    
    // Step 5: Process decision or timeout
    if (decisionTimeout) {
      // Handle timeout based on urgency
      if (urgency === 'critical' || urgency === 'high') {
        // Escalate for critical/high urgency
        const escalation = await step.run('escalate-approval', async () => {
          logger.info('Escalating approval', { purchaseId, urgency });
          
          // In a real app, you'd notify a manager or escalate to a higher authority
          await new Promise((resolve) => setTimeout(resolve, 500));
          
          return {
            escalated: true,
            escalatedTo: 'management@workflowhub.com',
            escalatedAt: new Date().toISOString(),
            reason: 'Approval timeout exceeded urgency threshold',
          };
        });
        
        // Wait for escalation decision
        try {
          const escalationDecision = await step.waitForEvent('wait-for-escalation', {
            event: 'purchase/escalated-approved',
            timeout: '2h',
            match: `data.purchaseId == "${purchaseId}"`,
          });
          
          return {
            purchaseId,
            status: 'approved',
            approval: escalationDecision.data,
            escalation,
            processedAt: new Date().toISOString(),
          };
        } catch {
          // If escalation times out too, auto-deny
          return {
            purchaseId,
            status: 'denied',
            reason: 'Approval and escalation timed out',
            processedAt: new Date().toISOString(),
          };
        }
      } else {
        // Auto-deny for low/medium urgency
        return {
          purchaseId,
          status: 'denied',
          reason: 'Approval request timed out',
          processedAt: new Date().toISOString(),
        };
      }
    }
    
    // Step 6: Process approval decision
    if (approvalDecision && approvalDecision.data.approved === true) {
      // Purchase was approved!
      
      // Step 6a: Additional approval for high-risk purchases
      if (riskAssessment.requiresAdditionalApproval) {
        const secondaryApproval = await step.run('request-secondary-approval', async () => {
          logger.info('Requesting secondary approval for high-risk purchase', { 
            purchaseId, 
            riskLevel: riskAssessment.riskLevel 
          });
          
          // In a real app, you'd get a second approver
          await new Promise((resolve) => setTimeout(resolve, 500));
          
          return {
            required: true,
            approver: 'finance@workflowhub.com',
            requestedAt: new Date().toISOString(),
          };
        });
        
        // Wait for secondary approval
        try {
          const secondaryDecision = await step.waitForEvent('wait-for-secondary-approval', {
            event: 'purchase/secondary-approved',
            timeout: '24h',
            match: `data.purchaseId == "${purchaseId}"`,
          });
          
          if (!secondaryDecision.data.approved) {
            return {
              purchaseId,
              status: 'denied',
              reason: 'Secondary approval denied',
              processedAt: new Date().toISOString(),
            };
          }
        } catch {
          return {
            purchaseId,
            status: 'denied',
            reason: 'Secondary approval timeout',
            processedAt: new Date().toISOString(),
          };
        }
      }
      
      // Step 6b: Execute purchase (create PO, order items, etc.)
      const execution = await step.run('execute-purchase', async () => {
        logger.info('Executing purchase order', { 
          purchaseId, 
          vendor, 
          totalAmount: amount 
        });
        
        // Simulate purchase execution
        await new Promise((resolve) => setTimeout(resolve, 1500));
        
        const poNumber = `PO-${new Date().getFullYear()}-${String(Math.floor(Math.random() * 10000)).padStart(4, '0')}`;
        
        return {
          poNumber,
          orderDate: new Date().toISOString(),
          estimatedDelivery: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
          status: 'processing',
          items: items.map(item => ({
            ...item,
            status: 'ordered',
          })),
        };
      });
      
      // Step 6c: Notify requester
      await step.run('notify-requester-approved', async () => {
        logger.info('Notifying requester of approval', { 
          purchaseId, 
          requesterEmail 
        });
        
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          notified: true,
          notifiedAt: new Date().toISOString(),
        };
      });
      
      // Return successful approval result
      return {
        purchaseId,
        status: 'approved',
        approval: approvalDecision.data,
        execution,
        processedAt: new Date().toISOString(),
      };
      
    } else {
      // Purchase was denied
      
      // Notify requester
      await step.run('notify-requester-denied', async () => {
        logger.info('Notifying requester of denial', { 
          purchaseId, 
          requesterEmail 
        });
        
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          notified: true,
          notifiedAt: new Date().toISOString(),
        };
      });
      
      return {
        purchaseId,
        status: 'denied',
        decision: approvalDecision?.data,
        processedAt: new Date().toISOString(),
      };
    }
  }
);

// Helper: Parse duration string to milliseconds
function parseDuration(duration: string): number {
  const units: Record<string, number> = {
    s: 1000,
    m: 60 * 1000,
    h: 60 * 60 * 1000,
    d: 24 * 60 * 60 * 1000,
  };
  
  const match = duration.match(/^(\d+)([smhd])$/);
  if (!match) return 24 * 60 * 60 * 1000; // Default to 24 hours
  
  const value = parseInt(match[1]);
  const unit = match[2];
  
  return value * units[unit];
}
```

---

## Module 4.2: Saga Pattern Implementation

### The Target

Learn how to implement the Saga pattern for distributed transactions that require compensating actions across multiple services.

### The Concept

The Saga pattern is like **orchestrating a multi-vendor event**:

Imagine you're planning a conference with multiple vendors:

1. **Book venue** → Venue confirmed
2. **Hire catering** → Catering confirmed  
3. **Book speakers** → Speakers confirmed

If speakers cancel, you need to compensate:
3. **Find replacement speakers** → New speakers confirmed
OR
2. **Cancel catering** → Catering refunded
1. **Cancel venue** → Venue refunded

The Saga pattern provides a way to manage these long-running distributed transactions with compensating actions for each step.

### The Implementation: Customer Onboarding Saga

```typescript
// src/inngest/functions/customer-onboarding-saga.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define customer onboarding event
const CustomerOnboardingEventSchema = z.object({
  customerId: z.string().uuid(),
  email: z.string().email(),
  companyName: z.string().min(1),
  plan: z.enum(['starter', 'professional', 'enterprise']),
  billingAddress: z.object({
    street: z.string(),
    city: z.string(),
    state: z.string(),
    postalCode: z.string(),
    country: z.string(),
  }),
  contactName: z.string().min(1),
  contactPhone: z.string().optional(),
});

// Define compensation types
interface CompensationAction {
  step: string;
  action: () => Promise<any>;
}

// Main onboarding saga workflow
export const customerOnboardingSaga = inngest.createFunction(
  {
    id: 'customer-onboarding-saga',
    name: 'Customer Onboarding Saga',
    description: 'Orchestrate customer onboarding with compensating actions',
    
    retries: 3,
    retryDelay: '5s',
  },
  { event: 'customer/onboarding-requested' },
  async ({ event, step, logger }) => {
    const validatedData = CustomerOnboardingEventSchema.parse(event.data);
    const { customerId, email, companyName, plan, billingAddress, contactName, contactPhone } = validatedData;
    
    logger.info('Starting customer onboarding saga', { 
      customerId, 
      companyName, 
      plan 
    });
    
    // Track all successful steps for compensation
    const completedSteps: { name: string; result: any }[] = [];
    const compensationQueue: CompensationAction[] = [];
    
    // Helper to add compensation actions
    const addCompensation = (stepName: string, action: () => Promise<any>) => {
      compensationQueue.push({ step: stepName, action });
    };
    
    try {
      // Step 1: Create CRM account
      const crmAccount = await step.run('create-crm-account', async () => {
        logger.info('Creating CRM account', { customerId, companyName });
        await new Promise((resolve) => setTimeout(resolve, 1000));
        
        const result = {
          crmId: `crm-${customerId.slice(0, 8)}`,
          companyName,
          createdAt: new Date().toISOString(),
          status: 'active',
        };
        
        // Register compensation: delete CRM account
        addCompensation('create-crm-account', async () => {
          logger.info('Compensating: Deleting CRM account', { customerId });
          await new Promise((resolve) => setTimeout(resolve, 500));
          return { compensation: 'crm-account-deleted' };
        });
        
        return result;
      });
      completedSteps.push({ name: 'create-crm-account', result: crmAccount });
      
      // Step 2: Create billing account
      const billingAccount = await step.run('create-billing-account', async () => {
        logger.info('Creating billing account', { customerId, plan });
        await new Promise((resolve) => setTimeout(resolve, 1200));
        
        // Simulate billing service integration
        const result = {
          billingId: `bill-${customerId.slice(0, 8)}`,
          plan,
          status: 'active',
          billingAddress,
          createdAt: new Date().toISOString(),
        };
        
        // Register compensation: suspend billing account
        addCompensation('create-billing-account', async () => {
          logger.info('Compensating: Suspending billing account', { customerId });
          await new Promise((resolve) => setTimeout(resolve, 500));
          return { compensation: 'billing-account-suspended' };
        });
        
        return result;
      });
      completedSteps.push({ name: 'create-billing-account', result: billingAccount });
      
      // Step 3: Send welcome email (this might fail, requiring compensation)
      const welcomeEmail = await step.run('send-welcome-email', async () => {
        logger.info('Sending welcome email', { customerId, email });
        await new Promise((resolve) => setTimeout(resolve, 800));
        
        // Simulate random failure for demonstration
        if (Math.random() < 0.2) {
          throw new Error('Email service temporarily unavailable');
        }
        
        const result = {
          messageId: `welcome-${customerId}`,
          sentAt: new Date().toISOString(),
          recipient: email,
        };
        
        // Compensation for welcome email: send apology email
        addCompensation('send-welcome-email', async () => {
          logger.info('Compensating: Sending apology email', { customerId });
          await new Promise((resolve) => setTimeout(resolve, 300));
          return { compensation: 'apology-email-sent' };
        });
        
        return result;
      });
      completedSteps.push({ name: 'send-welcome-email', result: welcomeEmail });
      
      // Step 4: Provision resources based on plan
      const resources = await step.run('provision-resources', async () => {
        logger.info('Provisioning resources', { customerId, plan });
        await new Promise((resolve) => setTimeout(resolve, 1500));
        
        const result = {
          resources: {
            storage: plan === 'enterprise' ? '1TB' : '100GB',
            apiRequests: plan === 'enterprise' ? 'Unlimited' : '10,000/month',
            features: plan === 'enterprise' 
              ? ['sso', 'audit-logs', 'custom-domains', 'advanced-analytics']
              : ['basic-analytics', 'api-access'],
          },
          provisionedAt: new Date().toISOString(),
          status: 'active',
        };
        
        // Register compensation: deprovision resources
        addCompensation('provision-resources', async () => {
          logger.info('Compensating: Deprovisioning resources', { customerId });
          await new Promise((resolve) => setTimeout(resolve, 500));
          return { compensation: 'resources-deprovisioned' };
        });
        
        return result;
      });
      completedSteps.push({ name: 'provision-resources', result: resources });
      
      // Step 5: Create user account
      const userAccount = await step.run('create-user-account', async () => {
        logger.info('Creating user account', { customerId, contactName });
        await new Promise((resolve) => setTimeout(resolve, 600));
        
        const result = {
          userId: `user-${customerId.slice(0, 8)}`,
          username: contactName.toLowerCase().replace(/\s/g, '.'),
          email,
          role: 'admin',
          createdAt: new Date().toISOString(),
        };
        
        // Register compensation: deactivate user
        addCompensation('create-user-account', async () => {
          logger.info('Compensating: Deactivating user account', { customerId });
          await new Promise((resolve) => setTimeout(resolve, 300));
          return { compensation: 'user-account-deactivated' };
        });
        
        return result;
      });
      completedSteps.push({ name: 'create-user-account', result: userAccount });
      
      // Step 6: Send onboarding survey (optional, can fail without compensation)
      try {
        await step.run('send-onboarding-survey', async () => {
          logger.info('Sending onboarding survey', { customerId, email });
          await new Promise((resolve) => setTimeout(resolve, 400));
          
          // This can fail without affecting the overall process
          return {
            sent: true,
            surveyId: `survey-${customerId}`,
            sentAt: new Date().toISOString(),
          };
        });
      } catch (error) {
        logger.warn('Onboarding survey failed, continuing anyway', { 
          customerId, 
          error: error.message 
        });
      }
      
      // Step 7: Complete onboarding
      const completion = await step.run('complete-onboarding', async () => {
        logger.info('Completing onboarding', { customerId });
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          completed: true,
          completedAt: new Date().toISOString(),
          onboardingId: `onboard-${customerId}`,
          status: 'success',
        };
      });
      
      // Success! Return all results
      return {
        success: true,
        customerId,
        companyName,
        plan,
        crmAccount,
        billingAccount,
        welcomeEmail,
        resources,
        userAccount,
        completion,
        completedSteps: completedSteps.map(s => s.name),
        processedAt: new Date().toISOString(),
      };
      
    } catch (error) {
      // If any step fails, execute compensation actions in reverse order
      logger.error('Onboarding failed, executing compensation', { 
        customerId, 
        error: error.message,
        completedSteps: completedSteps.map(s => s.name),
        compensationSteps: compensationQueue.map(s => s.step),
      });
      
      // Execute compensation in reverse order (LIFO)
      const compensationResults = [];
      for (let i = compensationQueue.length - 1; i >= 0; i--) {
        const compensation = compensationQueue[i];
        try {
          const result = await step.run(`compensate-${compensation.step}`, async () => {
            logger.info('Executing compensation', { 
              customerId, 
              step: compensation.step 
            });
            return await compensation.action();
          });
          compensationResults.push({
            step: compensation.step,
            status: 'success',
            result,
          });
        } catch (compensationError) {
          logger.error('Compensation failed', { 
            customerId, 
            step: compensation.step,
            error: compensationError.message 
          });
          compensationResults.push({
            step: compensation.step,
            status: 'failed',
            error: compensationError.message,
          });
        }
      }
      
      // Return failure result with compensation details
      return {
        success: false,
        customerId,
        companyName,
        plan,
        error: error.message,
        compensation: compensationResults,
        completedSteps: completedSteps.map(s => s.name),
        processedAt: new Date().toISOString(),
      };
    }
  }
);
```

---

## Module 4.3: Workflow Versioning and Safe Deployments

### The Target

Learn how to safely evolve your workflows over time without disrupting running executions.

### The Concept

Workflow versioning is like **updating the software on a fleet of airplanes**:

1. **Planes in flight** (running workflows) continue with their current version
2. **New flights** (new workflows) use the updated version
3. **Flight plan updates** (workflow changes) are applied to new executions only

This approach ensures you don't disrupt running workflows while still deploying improvements.

### The Implementation: Subscription Lifecycle Management with Versioning

```typescript
// src/inngest/functions/subscription-lifecycle.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Event for subscription creation
const SubscriptionCreatedEventSchema = z.object({
  subscriptionId: z.string().uuid(),
  userId: z.string().uuid(),
  planId: z.string(),
  trialEndsAt: z.string().datetime(),
  billingInterval: z.enum(['monthly', 'annual']),
  features: z.array(z.string()),
});

// Helper to get workflow version
const WORKFLOW_VERSION = '2.0.0';
const WORKFLOW_NAME = 'subscription-lifecycle-workflow';

// Main subscription lifecycle workflow with versioning
export const subscriptionLifecycleWorkflow = inngest.createFunction(
  {
    id: WORKFLOW_NAME,
    name: `Subscription Lifecycle Management v${WORKFLOW_VERSION}`,
    description: 'Manage subscription lifecycle with versioned workflows',
    
    // Version information
    version: WORKFLOW_VERSION,
    
    // Ensure idempotency across versions
    idempotency: {
      key: 'data.subscriptionId',
      ttl: '30d', // Prevent duplicate processing for 30 days
    },
    
    // Retry configuration
    retries: 3,
    retryDelay: '5s',
  },
  { event: 'subscription/created' },
  async ({ event, step, logger }) => {
    // Step 0: Log the version for debugging
    logger.info('Executing workflow version', { 
      version: WORKFLOW_VERSION, 
      workflow: WORKFLOW_NAME,
      subscriptionId: event.data.subscriptionId 
    });
    
    const validatedData = SubscriptionCreatedEventSchema.parse(event.data);
    const { subscriptionId, userId, planId, trialEndsAt, billingInterval, features } = validatedData;
    
    logger.info('Processing subscription lifecycle', { 
      subscriptionId, 
      userId, 
      planId, 
      version: WORKFLOW_VERSION 
    });
    
    // Step 1: Create subscription record
    const subscription = await step.run('create-subscription-record', async () => {
      logger.info('Creating subscription record', { subscriptionId, planId });
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      return {
        subscriptionId,
        userId,
        planId,
        status: 'trial',
        trialEndsAt,
        billingInterval,
        features,
        createdAt: new Date().toISOString(),
      };
    });
    
    // Step 2: Wait for trial period to end
    // This demonstrates a long-running workflow that survives deployments
    const trialEndTime = new Date(trialEndsAt).getTime();
    const currentTime = Date.now();
    const trialDuration = trialEndTime - currentTime;
    
    if (trialDuration > 0) {
      logger.info('Waiting for trial to end', { 
        subscriptionId, 
        trialEndsAt, 
        duration: trialDuration 
      });
      
      await step.sleep('wait-for-trial-end', trialDuration);
    }
    
    // Step 3: Process trial end
    // This is where version changes might affect running workflows
    const trialResult = await step.run('process-trial-end', async () => {
      logger.info('Processing trial end', { subscriptionId });
      
      // Check if user has usage data (for trial evaluation)
      // Version 2.0.0 adds more sophisticated trial evaluation
      await new Promise((resolve) => setTimeout(resolve, 800));
      
      // Simulate evaluating trial
      const trialUsage = {
        activeUsers: Math.floor(Math.random() * 10) + 1,
        apiCalls: Math.floor(Math.random() * 1000),
        featuresUsed: features.slice(0, Math.floor(Math.random() * features.length) + 1),
      };
      
      // Version-specific logic
      let shouldAutoConvert = false;
      let conversionReason = '';
      
      if (WORKFLOW_VERSION === '2.0.0') {
        // In version 2.0.0, we auto-convert based on usage
        if (trialUsage.activeUsers > 5 && trialUsage.apiCalls > 100) {
          shouldAutoConvert = true;
          conversionReason = 'High usage during trial';
        }
      } else {
        // In earlier versions, we required manual conversion
        shouldAutoConvert = false;
        conversionReason = 'Manual conversion required in this version';
      }
      
      return {
        subscriptionId,
        trialUsage,
        shouldAutoConvert,
        conversionReason,
        processedAt: new Date().toISOString(),
      };
    });
    
    // Step 4: Convert or prompt for conversion
    let conversionResult: any;
    
    if (trialResult.shouldAutoConvert) {
      // Auto-convert to paid plan
      conversionResult = await step.run('auto-convert-to-paid', async () => {
        logger.info('Auto-converting to paid plan', { 
          subscriptionId, 
          reason: trialResult.conversionReason 
        });
        await new Promise((resolve) => setTimeout(resolve, 1000));
        
        return {
          converted: true,
          planId,
          billingInterval,
          convertedAt: new Date().toISOString(),
          status: 'active',
        };
      });
    } else {
      // Wait for user to convert manually
      try {
        const conversionDecision = await step.waitForEvent('wait-for-conversion-decision', {
          event: 'subscription/conversion-decision',
          timeout: '7d',
          match: `data.subscriptionId == "${subscriptionId}"`,
        });
        
        if (conversionDecision.data.convert) {
          conversionResult = await step.run('convert-subscription', async () => {
            logger.info('Converting subscription based on user decision', { subscriptionId });
            await new Promise((resolve) => setTimeout(resolve, 1000));
            
            return {
              converted: true,
              planId: conversionDecision.data.planId || planId,
              billingInterval: conversionDecision.data.billingInterval || billingInterval,
              convertedAt: new Date().toISOString(),
              status: 'active',
            };
          });
        } else {
          // User decided not to convert
          conversionResult = {
            converted: false,
            status: 'cancelled',
            reason: 'User declined conversion',
          };
        }
      } catch {
        // Timeout - user didn't respond
        conversionResult = {
          converted: false,
          status: 'expired',
          reason: 'Conversion decision timed out',
        };
      }
    }
    
    // Step 5: Send notification based on result
    await step.run('send-subscription-notification', async () => {
      logger.info('Sending subscription notification', { 
        subscriptionId, 
        converted: conversionResult.converted 
      });
      await new Promise((resolve) => setTimeout(resolve, 300));
      
      return {
        sent: true,
        sentAt: new Date().toISOString(),
      };
    });
    
    // Return final result
    return {
      subscriptionId,
      userId,
      planId,
      workflowVersion: WORKFLOW_VERSION,
      trial: {
        ended: true,
        usage: trialResult.trialUsage,
        autoConverted: trialResult.shouldAutoConvert,
      },
      conversion: conversionResult,
      processedAt: new Date().toISOString(),
    };
  }
);

// Version 1.0.0 of the same workflow (legacy)
export const subscriptionLifecycleWorkflowV1 = inngest.createFunction(
  {
    id: 'subscription-lifecycle-workflow',
    name: 'Subscription Lifecycle Management v1.0.0',
    description: 'Legacy subscription workflow - will be phased out',
    version: '1.0.0',
    
    // Deprecation flag - new executions should use v2
    // This is a custom flag, but demonstrates the concept
    retries: 3,
    retryDelay: '5s',
  },
  { event: 'subscription/created' },
  async ({ event, step, logger }) => {
    // Version 1.0.0 logic - simpler, fewer features
    logger.info('Running legacy subscription workflow', { 
      subscriptionId: event.data.subscriptionId 
    });
    
    // Simplified implementation (kept for backward compatibility)
    const subscription = await step.run('create-subscription', async () => {
      await new Promise((resolve) => setTimeout(resolve, 300));
      return { ...event.data, status: 'active' };
    });
    
    // Wait for trial
    const trialEnd = new Date(event.data.trialEndsAt).getTime();
    if (trialEnd > Date.now()) {
      await step.sleep('wait-for-trial', trialEnd - Date.now());
    }
    
    // Simple conversion - manual only
    const conversion = await step.run('check-conversion', async () => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return { status: 'needs-conversion' };
    });
    
    return {
      ...subscription,
      legacy: true,
      conversion,
    };
  }
);
```

### Safe Deployment Strategy

When deploying new versions of your workflows:

1. **Add the new version**: Deploy with a new version number
2. **Test the new version**: Send test events to verify
3. **Gradual rollout**: Start routing some events to the new version
4. **Monitor**: Check for errors and performance issues
5. **Complete rollout**: Route all events to the new version
6. **Deprecate old version**: Remove after all running executions complete

```typescript
// src/inngest/version-router.ts
// Helper to route events to different versions based on configuration

export const versionConfig = {
  'subscription/created': {
    defaultVersion: '2.0.0',
    versions: {
      '1.0.0': {
        enabled: false, // Legacy version, disabled
        percentage: 0,
      },
      '2.0.0': {
        enabled: true,
        percentage: 100, // 100% of traffic
      },
    },
  },
};

// Middleware to log version usage
export const versionTrackingMiddleware = new InngestMiddleware({
  name: 'Version Tracking',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => {
      console.log(`[Version] Executing ${fn.id} version ${fn.version || 'unknown'}`);
      
      // Track version usage for monitoring
      // In a real app, you'd send this to your metrics system
    },
  }),
});
```

---

## Module 4.4: Advanced Human-in-the-Loop Patterns

### The Target

Implement complex human-in-the-loop workflows with escalations, reminders, and multi-level approvals.

### The Concept

Human-in-the-loop workflows are like **customer support ticket systems**:

1. **Ticket Created** → Assigned to agent
2. **Agent Responds** → Wait for customer reply
3. **Customer Replies** → Back to agent
4. **Resolution** → Ticket closed

Each step might take hours or days, and the system needs to handle escalations, reminders, and timeouts.

### The Implementation: Multi-Level Approval with Escalation

```typescript
// src/inngest/functions/multi-level-approval.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define multi-level approval request
const MultiLevelApprovalEventSchema = z.object({
  requestId: z.string().uuid(),
  requesterId: z.string().uuid(),
  title: z.string().min(1),
  description: z.string().min(1),
  type: z.enum(['expense', 'project', 'hire', 'policy-change']),
  amount: z.number().optional(),
  urgency: z.enum(['low', 'medium', 'high', 'emergency']),
  approvals: z.array(
    z.object({
      level: z.number().int().positive(),
      approverId: z.string().uuid(),
      approverEmail: z.string().email(),
      required: z.boolean().default(true),
      timeout: z.string().default('24h'),
    })
  ),
});

// Define approval response
const ApprovalResponseEventSchema = z.object({
  requestId: z.string().uuid(),
  level: z.number().int().positive(),
  approverId: z.string().uuid(),
  approved: z.boolean(),
  comments: z.string().optional(),
  timestamp: z.string().datetime(),
});

// Main multi-level approval workflow
export const multiLevelApprovalWorkflow = inngest.createFunction(
  {
    id: 'multi-level-approval-workflow',
    name: 'Multi-Level Approval System',
    description: 'Orchestrate complex approval processes with escalation',
    
    retries: 3,
    retryDelay: '5s',
  },
  { event: 'request/approval-requested' },
  async ({ event, step, logger }) => {
    const validatedData = MultiLevelApprovalEventSchema.parse(event.data);
    const { requestId, requesterId, title, description, type, amount, urgency, approvals } = validatedData;
    
    logger.info('Starting multi-level approval process', { 
      requestId, 
      title, 
      approvalLevels: approvals.length,
      urgency 
    });
    
    // Track approval results
    const approvalResults: any[] = [];
    let approved = true;
    let rejectionReason: string | null = null;
    
    // Step 1: Send request to all approvers
    await step.run('notify-approvers', async () => {
      logger.info('Notifying approvers', { 
        requestId, 
        approvers: approvals.map(a => a.approverEmail) 
      });
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      return {
        notified: true,
        notifiedAt: new Date().toISOString(),
      };
    });
    
    // Step 2: Process each approval level sequentially
    // Each level must approve before the next level is notified
    for (const [index, approval] of approvals.entries()) {
      const level = approval.level;
      const approverId = approval.approverId;
      const approverEmail = approval.approverEmail;
      const timeout = approval.timeout;
      
      // Notify this level's approver
      await step.run(`notify-approver-level-${level}`, async () => {
        logger.info(`Notifying approver level ${level}`, { 
          requestId, 
          approverEmail 
        });
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          level,
          notified: true,
          notifiedAt: new Date().toISOString(),
        };
      });
      
      // Wait for this level's approval
      let levelApproved = false;
      let levelRejected = false;
      let levelTimeout = false;
      
      try {
        // Wait for approval decision for this level
        // We use a unique event pattern to match this specific level
        const decision = await step.waitForEvent(`wait-for-approval-level-${level}`, {
          event: 'request/approval-response',
          timeout,
          match: (data: any) => 
            data.requestId === requestId && 
            data.level === level,
        });
        
        if (decision.data && decision.data.approved) {
          levelApproved = true;
          logger.info(`Level ${level} approved`, { requestId, approverEmail });
        } else {
          levelRejected = true;
          rejectionReason = decision.data?.comments || `Level ${level} denied the request`;
          logger.warn(`Level ${level} rejected`, { requestId, approverEmail });
        }
        
      } catch {
        // Timeout - escalate based on urgency
        levelTimeout = true;
        logger.warn(`Level ${level} timeout`, { requestId, approverEmail, timeout });
        
        // Handle timeout based on urgency
        if (urgency === 'emergency' || urgency === 'high') {
          // Auto-approve for emergency with higher authority
          if (urgency === 'emergency') {
            levelApproved = true;
            logger.info(`Emergency override - auto-approving level ${level}`, { requestId });
          } else {
            // For high urgency, try to escalate
            const escalation = await step.run(`escalate-level-${level}`, async () => {
              logger.info(`Escalating level ${level} due to timeout`, { requestId });
              await new Promise((resolve) => setTimeout(resolve, 500));
              
              return {
                escalated: true,
                escalatedTo: 'escalation@workflowhub.com',
                timestamp: new Date().toISOString(),
              };
            });
            
            // Wait for escalation decision
            try {
              const escalationDecision = await step.waitForEvent(`wait-for-escalation-level-${level}`, {
                event: 'request/escalation-response',
                timeout: '12h',
                match: `data.requestId == "${requestId}" && data.level == ${level}`,
              });
              
              if (escalationDecision.data && escalationDecision.data.approved) {
                levelApproved = true;
              } else {
                levelRejected = true;
                rejectionReason = 'Escalation decision denied';
              }
            } catch {
              // Escalation timeout - auto-deny
              levelRejected = true;
              rejectionReason = 'Escalation timeout - request denied';
            }
          }
        } else {
          // For lower urgency, auto-deny on timeout
          levelRejected = true;
          rejectionReason = `Level ${level} approval timed out after ${timeout}`;
        }
      }
      
      // Store result for this level
      approvalResults.push({
        level,
        approverId,
        approverEmail,
        approved: levelApproved,
        rejected: levelRejected,
        timedOut: levelTimeout,
        reason: rejectionReason,
        processedAt: new Date().toISOString(),
      });
      
      // If this level rejected, stop the approval process
      if (levelRejected || (levelTimeout && urgency !== 'emergency')) {
        approved = false;
        break;
      }
      
      // If this is an emergency and we auto-approved, continue
      if (levelTimeout && urgency === 'emergency') {
        logger.info('Emergency auto-approval continued', { requestId, level });
      }
    }
    
    // Step 3: Process final decision
    if (approved) {
      // All levels approved (or emergency auto-approved)
      
      // Execute the request
      const execution = await step.run('execute-approved-request', async () => {
        logger.info('Executing approved request', { requestId, type });
        await new Promise((resolve) => setTimeout(resolve, 1000));
        
        return {
          executed: true,
          requestId,
          type,
          executedAt: new Date().toISOString(),
          status: 'completed',
        };
      });
      
      // Notify requester of approval
      await step.run('notify-requester-approved', async () => {
        logger.info('Notifying requester of approval', { requestId });
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          notified: true,
          notifiedAt: new Date().toISOString(),
        };
      });
      
      return {
        success: true,
        requestId,
        title,
        approvals: approvalResults,
        execution,
        processedAt: new Date().toISOString(),
      };
      
    } else {
      // Request was rejected
      
      // Notify requester of rejection
      await step.run('notify-requester-rejected', async () => {
        logger.info('Notifying requester of rejection', { requestId });
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          notified: true,
          notifiedAt: new Date().toISOString(),
          reason: rejectionReason,
        };
      });
      
      return {
        success: false,
        requestId,
        title,
        approvals: approvalResults,
        rejectionReason,
        processedAt: new Date().toISOString(),
      };
    }
  }
);
```

---

## Verification: Testing Long-Running Workflows

### Step 1: Create Purchase Approval Request

```bash
# Create a purchase request
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "purchase/requested",
    "data": {
      "purchaseId": "123e4567-e89b-12d3-a456-426614174000",
      "userId": "223e4567-e89b-12d3-a456-426614174000",
      "department": "Engineering",
      "amount": 7500,
      "description": "New developer workstations",
      "vendor": "TechWorks Inc",
      "items": [
        {"name": "MacBook Pro", "quantity": 5, "unitPrice": 2499},
        {"name": "External Monitor", "quantity": 5, "unitPrice": 499}
      ],
      "urgency": "high",
      "requesterEmail": "requester@workflowhub.com",
      "approverEmail": "approver@workflowhub.com"
    }
  }'
```

### Step 2: Send Approval Decision

```bash
# Approve the purchase
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "purchase/approved",
    "data": {
      "purchaseId": "123e4567-e89b-12d3-a456-426614174000",
      "approved": true,
      "approver": "approver@workflowhub.com",
      "comments": "Approved - essential equipment for the team",
      "timestamp": "'$(date -Iseconds)'"
    }
  }'

# Deny the purchase
# curl -X POST http://localhost:3000/api/inngest \
#   -H "Content-Type: application/json" \
#   -d '{
#     "name": "purchase/approved",
#     "data": {
#       "purchaseId": "123e4567-e89b-12d3-a456-426614174000",
#       "approved": false,
#       "approver": "approver@workflowhub.com",
#       "comments": "Budget constraints - please reduce amount",
#       "timestamp": "'$(date -Iseconds)'"
#     }
#   }'
```

### Step 3: Test Customer Onboarding with Saga

```bash
# Start customer onboarding
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "customer/onboarding-requested",
    "data": {
      "customerId": "123e4567-e89b-12d3-a456-426614174001",
      "email": "customer@example.com",
      "companyName": "Acme Corp",
      "plan": "professional",
      "billingAddress": {
        "street": "123 Business St",
        "city": "Enterprise City",
        "state": "CA",
        "postalCode": "90210",
        "country": "USA"
      },
      "contactName": "John Smith",
      "contactPhone": "+1-555-123-4567"
    }
  }'

# Monitor the saga in the Dev Server
# Watch for compensation actions if steps fail
```

### Step 4: Test Multi-Level Approval

```bash
# Create a multi-level approval request
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "request/approval-requested",
    "data": {
      "requestId": "123e4567-e89b-12d3-a456-426614174002",
      "requesterId": "223e4567-e89b-12d3-a456-426614174000",
      "title": "New Server Infrastructure",
      "description": "Upgrade to cloud infrastructure for scalability",
      "type": "project",
      "amount": 50000,
      "urgency": "high",
      "approvals": [
        {
          "level": 1,
          "approverId": "team-lead-id",
          "approverEmail": "team-lead@workflowhub.com",
          "required": true,
          "timeout": "1h"
        },
        {
          "level": 2,
          "approverId": "manager-id",
          "approverEmail": "manager@workflowhub.com",
          "required": true,
          "timeout": "2h"
        }
      ]
    }
  }'
```

### Step 5: Monitor in Dev Server

Open `http://localhost:3000/api/inngest` and:

1. **Find the running workflows**: Look for workflows in "running" state
2. **Examine the state**: Click on a run to see the current state
3. **Check waiting events**: See which events the workflow is waiting for
4. **View execution history**: See all steps and their results

---

## Deep Dive: Long-Running Workflow Best Practices

### Managing Workflow State

```typescript
// Best practice: Store workflow state externally for complex workflows
export async function storeWorkflowState(
  workflowId: string,
  state: any
): Promise<void> {
  // In a real app, you'd use Redis or a database
  console.log(`[State] Storing state for ${workflowId}`, state);
}

export async function loadWorkflowState(
  workflowId: string
): Promise<any> {
  // Load state from external storage
  console.log(`[State] Loading state for ${workflowId}`);
  return {};
}
```

### Handling Workflow Cancellation

```typescript
// Add cancellation support to your workflows
export const cancellableWorkflow = inngest.createFunction(
  {
    id: 'cancellable-workflow',
    name: 'Cancellable Workflow',
  },
  { event: 'workflow/start' },
  async ({ event, step, logger }) => {
    const workflowId = event.data.workflowId;
    
    // Register for cancellation events
    try {
      // Check for cancellation at key points
      const cancellationCheck = await step.run('check-cancellation', async () => {
        // In a real app, check a cancellation flag in your database
        return { cancelled: false };
      });
      
      if (cancellationCheck.cancelled) {
        return {
          status: 'cancelled',
          workflowId,
          cancelledAt: new Date().toISOString(),
        };
      }
      
      // Continue with workflow logic
      // ... 
      
    } catch (error) {
      // Handle cancellation errors
      logger.info('Workflow cancelled', { workflowId });
      return {
        status: 'cancelled',
        workflowId,
        error: error.message,
      };
    }
  }
);
```

### Monitoring Long-Running Workflows

```typescript
// src/inngest/monitoring/workflow-monitor.ts
export class WorkflowMonitor {
  // Track workflow progress
  trackProgress(workflowId: string, step: string, progress: number) {
    console.log(`[Monitor] ${workflowId} - ${step}: ${progress}%`);
    // In a real app, send to monitoring service
  }
  
  // Alert on stuck workflows
  checkStuckWorkflows(workflows: any[]) {
    const stuck = workflows.filter(w => {
      const duration = Date.now() - new Date(w.startedAt).getTime();
      return duration > 24 * 60 * 60 * 1000 && w.status === 'running';
    });
    
    if (stuck.length > 0) {
      console.warn(`[Monitor] Found ${stuck.length} stuck workflows`);
      // Send alert
    }
  }
}
```

---

## Troubleshooting Common Long-Running Workflow Issues

### Issue: Workflow Not Resuming After External Event

**Problem:** `step.waitForEvent()` times out or doesn't receive the event.

**Solution:**
```typescript
// Ensure event matching is correct
const decision = await step.waitForEvent('wait-for-event', {
  event: 'purchase/approved',
  timeout: '24h',
  match: (data: any) => {
    // Log the matching attempt for debugging
    console.log('Matching event:', { 
      receivedId: data.purchaseId, 
      expectedId: purchaseId,
      match: data.purchaseId === purchaseId 
    });
    
    return data.purchaseId === purchaseId;
  },
});
```

### Issue: Long-Running Workflow Memory Usage

**Problem:** Workflows accumulate too much state over long periods.

**Solution:**
```typescript
// Store large data externally
const largeDataId = await step.run('store-data', async () => {
  const data = generateLargeData();
  await storeInRedis(data);
  return { dataId: data.id };
});

// Retrieve only when needed
const data = await step.run('retrieve-data', async () => {
  return await getFromRedis(largeDataId.dataId);
});
```

### Issue: Timeout Not Working as Expected

**Problem:** Workflow times out too early or too late.

**Solution:**
```typescript
// Use clear timeouts with logging
const timeout = '24h';
const timeoutMs = parseDuration(timeout);

logger.info('Setting timeout', { 
  timeout, 
  timeoutMs,
  willTimeoutAt: new Date(Date.now() + timeoutMs).toISOString() 
});

const decision = await step.waitForEvent('wait-for-event', {
  event: 'decision/made',
  timeout,
});
```

---

## What You've Accomplished

In Part 4, you've mastered long-running workflows:

1. ✅ Purchase approval system with human-in-the-loop
2. ✅ Saga pattern for distributed transactions
3. ✅ Workflow versioning and safe deployments
4. ✅ Multi-level approval with escalation
5. ✅ Customer onboarding with compensation
6. ✅ Subscription lifecycle management
7. ✅ Timeout handling and auto-decisions
8. ✅ Workflow monitoring and alerting
9. ✅ Cancellation support
10. ✅ Best practices for long-running workflows

You've learned:
- How to pause workflows for days or weeks
- How to handle human decisions safely
- How to implement compensating actions
- How to evolve workflows without breaking running executions
- How to handle escalations and timeouts
- How to monitor long-running workflows

---

## Deep Dive Reference: Event Waiting Cheatsheet

### `step.waitForEvent()` Configuration

```typescript
// Basic wait
await step.waitForEvent('wait-name', {
  event: 'event/name',
  timeout: '1h',
});

// With matching
await step.waitForEvent('wait-name', {
  event: 'event/name',
  timeout: '1d',
  match: 'data.orderId', // String path match
  // OR
  match: (data: any) => data.orderId === expectedId, // Function match
});

// With multiple events
await step.waitForEvent('wait-name', {
  event: ['event/approved', 'event/denied'],
  timeout: '24h',
});

// With data transformation
const result = await step.waitForEvent('wait-name', {
  event: 'event/name',
  timeout: '1h',
  if: 'data.valid === true', // Only accept if condition is met
});
```

### Timeout Handling Patterns

```typescript
// Pattern 1: Try-catch timeout
try {
  const decision = await step.waitForEvent('wait-for-decision', {
    event: 'decision/made',
    timeout: '24h',
  });
  // Handle decision
} catch {
  // Handle timeout
  await step.run('handle-timeout', async () => {
    // Escalate or auto-deny
  });
}

// Pattern 2: Check for timeout explicitly
const decision = await step.waitForEvent('wait-for-decision', {
  event: 'decision/made',
  timeout: '24h',
});

if (!decision) {
  // Handle timeout
}

// Pattern 3: Multiple waiting periods
try {
  const firstDecision = await step.waitForEvent('wait-first', {
    event: 'decision/made',
    timeout: '1h',
  });
  // Handle first decision
} catch {
  // First timeout - send reminder
  await sendReminder();
  
  try {
    const secondDecision = await step.waitForEvent('wait-second', {
      event: 'decision/made',
      timeout: '23h',
    });
    // Handle second decision
  } catch {
    // Final timeout - escalate
    await escalate();
  }
}
```

---

## Next Steps

In **Part 5**, we'll integrate everything with modern React 19 and Next.js 16:
- Triggering workflows from the UI
- Real-time status updates with Server-Sent Events
- React 19 Action APIs and `useActionState`
- Optimistic updates for workflows
- Full-stack integration patterns
- AI content generation dashboard with live updates
- Background file processing with UI feedback

---

## References

- [Inngest Wait for Event Documentation](https://www.inngest.com/docs/reference/step#wait-for-event)
- [Saga Pattern](https://www.inngest.com/docs/learn/saga-pattern)
- [Workflow Versioning Best Practices](https://www.inngest.com/docs/guides/versioning)
- [Human-in-the-Loop Patterns](https://www.inngest.com/docs/learn/human-in-the-loop)
- [Long-Running Workflows](https://www.inngest.com/docs/learn/long-running-workflows)
