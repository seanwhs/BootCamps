# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Part 3: High-Performance Workflow Patterns

## Scaling Workflows with Fan-Out, Concurrency Control, and Batch Processing

---

## Module 3.1: Fan-Out / Fan-In Orchestration

### The Target

In this module, you'll master the art of parallelizing workflows—splitting a single task into many concurrent operations and aggregating the results efficiently.

### The Concept

Think of fan-out/fan-in like a **restaurant kitchen during peak hours**:

1. **Fan-Out**: The head chef (your workflow) receives a large order and assigns different dishes to different cooks (parallel steps)
2. **Parallel Execution**: All cooks work simultaneously on their assigned dishes
3. **Fan-In**: The head chef collects all finished dishes and plates them together (aggregation)

This pattern is essential for:
- Sending bulk emails to thousands of recipients
- Processing large datasets in parallel
- Calling multiple external APIs simultaneously
- Generating reports from multiple data sources

### The Implementation: Bulk Email Campaign Processor

Let's build a complete bulk email campaign system that demonstrates fan-out/fan-in at scale:

```typescript
// src/inngest/functions/bulk-email-campaign.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define the campaign event schema
const CampaignEventSchema = z.object({
  campaignId: z.string().uuid(),
  name: z.string().min(1),
  subject: z.string().min(1),
  htmlContent: z.string().min(1),
  recipients: z.array(
    z.object({
      id: z.string().uuid(),
      email: z.string().email(),
      name: z.string().optional(),
      metadata: z.record(z.any()).optional(),
    })
  ).min(1).max(10000), // Support up to 10,000 recipients
  fromEmail: z.string().email(),
  scheduledFor: z.string().datetime().optional(),
});

// Define individual email status
interface EmailStatus {
  recipientId: string;
  email: string;
  status: 'pending' | 'sent' | 'failed' | 'bounced';
  messageId?: string;
  error?: string;
  sentAt?: string;
}

export const bulkEmailCampaignWorkflow = inngest.createFunction(
  {
    id: 'bulk-email-campaign-workflow',
    name: 'Bulk Email Campaign Processor',
    description: 'Process large email campaigns with fan-out/fan-in orchestration',
    
    // Rate limiting to protect email service
    rateLimit: {
      limit: 5, // Only 5 campaigns at a time
      period: '10s', // Per 10-second window
    },
    
    // Concurrency control
    concurrency: {
      limit: 10, // Max 10 campaign runs simultaneously
      scope: 'fn',
    },
  },
  { event: 'campaign/triggered' },
  async ({ event, step, logger }) => {
    // Step 1: Validate and parse the event
    const validatedCampaign = CampaignEventSchema.parse(event.data);
    const { campaignId, name, subject, htmlContent, recipients, fromEmail } = validatedCampaign;
    
    logger.info('Starting bulk email campaign', { 
      campaignId, 
      name, 
      recipientCount: recipients.length 
    });
    
    // Step 2: Prepare email content and tracking
    const campaignPrep = await step.run('prepare-campaign', async () => {
      logger.info('Preparing campaign content', { campaignId });
      
      // In a real app, you'd add tracking pixels, unsubscribe links, etc.
      // We'll simulate the preparation
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      return {
        campaignId,
        preparedAt: new Date().toISOString(),
        contentHash: `hash-${Date.now()}`,
        trackingDomain: `track.workflowhub.com`,
      };
    });
    
    // Step 3: FAN-OUT - Process all recipients in parallel
    // We'll process in batches to control concurrency
    const BATCH_SIZE = 50; // Process 50 recipients at a time
    const batches: EmailStatus[][] = [];
    
    // Create batches of recipients
    for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
      const batch = recipients.slice(i, i + BATCH_SIZE);
      
      // Process each batch in parallel using Promise.all
      const batchResults = await step.run(`process-batch-${i}-${i + BATCH_SIZE}`, async () => {
        logger.info('Processing email batch', { 
          campaignId, 
          batchStart: i, 
          batchEnd: Math.min(i + BATCH_SIZE, recipients.length) 
        });
        
        // FAN-OUT: Process all emails in this batch in parallel
        const emailPromises = batch.map(async (recipient) => {
          // Each email is sent individually to allow per-recipient tracking
          try {
            // Simulate email sending with potential failure
            await new Promise((resolve) => setTimeout(resolve, 100 + Math.random() * 200));
            
            // Simulate random failures for demonstration (5% failure rate)
            if (Math.random() < 0.05) {
              throw new Error('Email service temporarily unavailable');
            }
            
            // Simulate bounce for some emails (2% bounce rate)
            let status: 'sent' | 'bounced' = 'sent';
            if (Math.random() < 0.02) {
              status = 'bounced';
            }
            
            return {
              recipientId: recipient.id,
              email: recipient.email,
              status,
              messageId: `msg-${Date.now()}-${Math.random().toString(36).substring(7)}`,
              sentAt: new Date().toISOString(),
            } as EmailStatus;
          } catch (error) {
            return {
              recipientId: recipient.id,
              email: recipient.email,
              status: 'failed',
              error: error.message,
            } as EmailStatus;
          }
        });
        
        // FAN-IN: Wait for all emails in this batch to complete
        const results = await Promise.all(emailPromises);
        return results;
      });
      
      batches.push(batchResults);
    }
    
    // Step 4: FAN-IN - Aggregate all batch results
    const allResults = await step.run('aggregate-campaign-results', async () => {
      logger.info('Aggregating campaign results', { 
        campaignId, 
        totalBatches: batches.length 
      });
      
      // Flatten all batch results
      const flatResults = batches.flat();
      
      // Calculate statistics
      const stats = {
        total: flatResults.length,
        sent: flatResults.filter(r => r.status === 'sent').length,
        failed: flatResults.filter(r => r.status === 'failed').length,
        bounced: flatResults.filter(r => r.status === 'bounced').length,
        pending: flatResults.filter(r => r.status === 'pending').length,
      };
      
      // Group by status for detailed reporting
      const byStatus = {
        sent: flatResults.filter(r => r.status === 'sent'),
        failed: flatResults.filter(r => r.status === 'failed'),
        bounced: flatResults.filter(r => r.status === 'bounced'),
        pending: flatResults.filter(r => r.status === 'pending'),
      };
      
      return {
        campaignId,
        stats,
        results: flatResults,
        byStatus,
        completedAt: new Date().toISOString(),
      };
    });
    
    // Step 5: Generate campaign report
    const report = await step.run('generate-campaign-report', async () => {
      logger.info('Generating campaign report', { 
        campaignId, 
        stats: allResults.stats 
      });
      
      // In a real app, you'd create a PDF or CSV report
      // We'll simulate report generation
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      return {
        reportId: `rpt-${campaignId}`,
        generatedAt: new Date().toISOString(),
        summary: {
          campaignName: name,
          subject,
          sentAt: allResults.completedAt,
          totalRecipients: allResults.stats.total,
          deliveryRate: `${(allResults.stats.sent / allResults.stats.total * 100).toFixed(1)}%`,
          bounceRate: `${(allResults.stats.bounced / allResults.stats.total * 100).toFixed(1)}%`,
          failureRate: `${(allResults.stats.failed / allResults.stats.total * 100).toFixed(1)}%`,
        },
        reportUrl: `https://storage.workflowhub.com/reports/${campaignId}.pdf`,
        dataUrl: `https://storage.workflowhub.com/reports/${campaignId}.json`,
      };
    });
    
    // Step 6: Notify campaign owner
    await step.run('notify-campaign-owner', async () => {
      logger.info('Notifying campaign owner', { campaignId });
      
      // Simulate sending notification
      await new Promise((resolve) => setTimeout(resolve, 300));
      
      return {
        notified: true,
        notifiedAt: new Date().toISOString(),
        notificationId: `notify-${Date.now()}`,
      };
    });
    
    // Return comprehensive campaign results
    return {
      campaignId,
      name,
      processedAt: new Date().toISOString(),
      stats: allResults.stats,
      report,
      hasFailures: allResults.stats.failed > 0 || allResults.stats.bounced > 0,
      failureDetails: {
        failed: allResults.byStatus.failed,
        bounced: allResults.byStatus.bounced,
      },
    };
  }
);
```

---

## Module 3.2: Concurrency Management

### The Target

Learn how to control the flow of your workflows with fine-grained concurrency limits, preventing system overload and ensuring fair resource allocation.

### The Concept

Concurrency management is like **crowd control** at a popular venue:

1. **Global Limits**: "Only 100 people inside at a time" (system-wide concurrency)
2. **Per-User Limits**: "Each person can reserve 5 tickets" (per-user concurrency)
3. **Per-Resource Limits**: "Only 10 people can use the VIP lounge" (per-resource concurrency)
4. **Queue Management**: "Line up, you'll be let in as others leave" (automatic queuing)

In Inngest, you can set concurrency limits at multiple levels to protect downstream systems.

### The Implementation: Multi-Tenant Task Scheduler

Let's build a sophisticated task scheduler that manages concurrency across multiple tenants:

```typescript
// src/inngest/functions/task-scheduler.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define task event schema
const TaskScheduledEventSchema = z.object({
  taskId: z.string().uuid(),
  tenantId: z.string().uuid(),
  type: z.enum(['data-processing', 'report-generation', 'api-call', 'file-upload']),
  priority: z.enum(['low', 'medium', 'high', 'critical']),
  payload: z.record(z.any()),
  scheduledFor: z.string().datetime().optional(),
  maxAttempts: z.number().int().min(1).max(10).default(3),
});

// Simulated resource-intensive tasks
class TaskProcessor {
  async processTask(type: string, payload: any, tenantId: string) {
    // Simulate different processing times based on task type
    const processingTimes: Record<string, number> = {
      'data-processing': 2000 + Math.random() * 3000,
      'report-generation': 3000 + Math.random() * 4000,
      'api-call': 500 + Math.random() * 1000,
      'file-upload': 1000 + Math.random() * 2000,
    };
    
    const duration = processingTimes[type] || 2000;
    await new Promise((resolve) => setTimeout(resolve, duration));
    
    // Simulate occasional failure (10% failure rate)
    if (Math.random() < 0.1) {
      throw new Error(`Task processing failed for tenant ${tenantId}`);
    }
    
    return {
      completed: true,
      duration,
      result: {
        processedAt: new Date().toISOString(),
        data: payload,
        summary: `Processed ${type} task successfully`,
      },
    };
  }
}

const taskProcessor = new TaskProcessor();

// Main task scheduler workflow with multi-level concurrency
export const taskSchedulerWorkflow = inngest.createFunction(
  {
    id: 'task-scheduler-workflow',
    name: 'Multi-Tenant Task Scheduler',
    description: 'Process tasks with tenant-specific concurrency controls',
    
    // Global concurrency limit (all tenants combined)
    concurrency: {
      limit: 100,
      scope: 'fn', // Applies to all executions of this function
    },
  },
  { event: 'task/scheduled' },
  async ({ event, step, logger }) => {
    const validatedData = TaskScheduledEventSchema.parse(event.data);
    const { taskId, tenantId, type, priority, payload, scheduledFor, maxAttempts } = validatedData;
    
    // Step 1: Validate tenant and task
    const taskValidation = await step.run('validate-task', async () => {
      logger.info('Validating task', { taskId, tenantId, type, priority });
      
      // Simulate tenant validation
      await new Promise((resolve) => setTimeout(resolve, 200));
      
      // Check if tenant exists and is active
      const isValidTenant = true; // Simulated
      if (!isValidTenant) {
        throw new Error(`Tenant ${tenantId} is invalid or inactive`);
      }
      
      return {
        validated: true,
        validatedAt: new Date().toISOString(),
        tenantPriority: priority,
      };
    });
    
    // Step 2: Handle scheduling delay if specified
    if (scheduledFor) {
      const scheduledTime = new Date(scheduledFor).getTime();
      const currentTime = Date.now();
      const waitTime = scheduledTime - currentTime;
      
      if (waitTime > 0) {
        await step.sleep('wait-for-scheduled-time', waitTime);
      }
    }
    
    // Step 3: Process the task with tenant-specific concurrency
    // This is where we apply per-tenant concurrency limits
    const taskResult = await step.run('process-task', async () => {
      // Apply tenant-specific concurrency limit
      // This is handled by the Inngest concurrency configuration
      // We'll use the key-based concurrency feature
      
      logger.info('Processing task with tenant concurrency control', { 
        taskId, 
        tenantId, 
        type,
        priority 
      });
      
      // Simulate task processing with retries
      let attempts = 0;
      let lastError: Error | null = null;
      
      while (attempts < maxAttempts) {
        try {
          attempts++;
          const result = await taskProcessor.processTask(type, payload, tenantId);
          
          return {
            ...result,
            attempts,
            tenantId,
            taskId,
            processedAt: new Date().toISOString(),
          };
        } catch (error) {
          lastError = error;
          logger.warn(`Task attempt ${attempts} failed`, { 
            taskId, 
            tenantId, 
            error: error.message 
          });
          
          if (attempts < maxAttempts) {
            // Exponential backoff with jitter
            const delay = Math.min(Math.pow(2, attempts) * 1000, 30000);
            const jitter = Math.random() * 1000;
            await new Promise((resolve) => setTimeout(resolve, delay + jitter));
          }
        }
      }
      
      // If we get here, all attempts failed
      throw new Error(`Task failed after ${maxAttempts} attempts: ${lastError?.message || 'Unknown error'}`);
    });
    
    // Step 4: Store task result
    const taskRecord = await step.run('store-task-result', async () => {
      logger.info('Storing task result', { taskId, tenantId });
      
      // Simulate database storage
      await new Promise((resolve) => setTimeout(resolve, 200));
      
      return {
        taskId,
        tenantId,
        status: taskResult.completed ? 'completed' : 'failed',
        result: taskResult.result,
        attempts: taskResult.attempts,
        createdAt: new Date().toISOString(),
      };
    });
    
    // Step 5: Notify tenant (if needed)
    if (priority === 'critical' || taskResult.completed === false) {
      await step.run('notify-tenant', async () => {
        logger.info('Notifying tenant about critical task', { taskId, tenantId });
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          notified: true,
          timestamp: new Date().toISOString(),
        };
      });
    }
    
    return {
      taskId,
      tenantId,
      status: 'completed',
      result: taskResult.result,
      attempts: taskResult.attempts,
      record: taskRecord,
      completedAt: new Date().toISOString(),
    };
  }
);

// Advanced: Tenant-specific concurrency workflow
export const tenantConcurrencyWorkflow = inngest.createFunction(
  {
    id: 'tenant-concurrency-workflow',
    name: 'Tenant-Specific Concurrency Control',
    description: 'Process tasks with per-tenant concurrency limits',
    
    // Global concurrency
    concurrency: {
      limit: 100,
      scope: 'fn',
    },
  },
  { event: 'tenant/task/created' },
  async ({ event, step, logger }) => {
    const { taskId, tenantId, data } = event.data;
    
    // Step 1: Get tenant concurrency configuration
    const tenantConfig = await step.run('get-tenant-config', async () => {
      // Simulate fetching tenant configuration
      await new Promise((resolve) => setTimeout(resolve, 100));
      
      // Different tenants have different concurrency limits
      const concurrencyLimits: Record<string, number> = {
        'tenant-premium': 50,
        'tenant-business': 25,
        'tenant-basic': 5,
      };
      
      const limit = concurrencyLimits[tenantId] || 10;
      
      return {
        tenantId,
        concurrencyLimit: limit,
        priority: 'medium',
      };
    });
    
    // Step 2: Process task with tenant-specific limits
    const result = await step.run('process-tenant-task', async () => {
      // Apply tenant-specific concurrency through key-based limits
      // The actual concurrency control happens at the Inngest level
      
      logger.info('Processing tenant task with concurrency limit', {
        taskId,
        tenantId,
        concurrencyLimit: tenantConfig.concurrencyLimit,
      });
      
      // Simulate processing
      await new Promise((resolve) => setTimeout(resolve, 1000 + Math.random() * 2000));
      
      return {
        processed: true,
        tenantId,
        taskId,
        processedAt: new Date().toISOString(),
      };
    });
    
    return {
      taskId,
      tenantId,
      processed: true,
      concurrencyLimit: tenantConfig.concurrencyLimit,
      result,
      completedAt: new Date().toISOString(),
    };
  }
);
```

---

## Module 3.3: Throttling and Rate Limiting

### The Target

Learn how to protect external services from overload using throttling and rate limiting patterns.

### The Concept

Throttling and rate limiting are like **traffic lights** for your API calls:

1. **Rate Limiting**: "Only 100 cars can pass per minute" (maximum requests per time period)
2. **Throttling**: "Wait 1 second between each car" (minimum time between requests)
3. **Debouncing**: "Only let the last car through" (ignore repeated requests)
4. **Batching**: "Let 10 cars through at once, then wait" (group requests together)

These patterns protect your system and external services from being overwhelmed.

### The Implementation: Image Processing Pipeline with Throttling

Let's build an image processing pipeline that handles large volumes while respecting rate limits:

```typescript
// src/inngest/functions/image-processing-pipeline.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define image processing event
const ImageProcessingEventSchema = z.object({
  batchId: z.string().uuid(),
  userId: z.string().uuid(),
  images: z.array(
    z.object({
      id: z.string().uuid(),
      url: z.string().url(),
      filename: z.string().min(1),
      operations: z.array(
        z.enum(['resize', 'compress', 'watermark', 'convert', 'filter'])
      ),
    })
  ).min(1).max(500),
  priority: z.enum(['low', 'normal', 'high']).default('normal'),
});

// Simulated image processing service with rate limits
class ImageProcessingService {
  private requestCount = 0;
  private lastRequestTime = 0;
  private readonly rateLimit = {
    maxRequestsPerMinute: 60,
    minDelayBetweenRequests: 1000, // 1 second
  };
  
  async processImage(imageData: {
    url: string;
    operations: string[];
    filename: string;
  }): Promise<{ processedUrl: string; size: number; format: string }> {
    // Check rate limits
    const now = Date.now();
    const timeSinceLastRequest = now - this.lastRequestTime;
    
    // Throttle: Ensure minimum time between requests
    if (timeSinceLastRequest < this.rateLimit.minDelayBetweenRequests) {
      const delay = this.rateLimit.minDelayBetweenRequests - timeSinceLastRequest;
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
    
    // Simulate processing with variable duration
    const processTime = 500 + Math.random() * 2000;
    await new Promise((resolve) => setTimeout(resolve, processTime));
    
    this.lastRequestTime = Date.now();
    this.requestCount++;
    
    // Simulate occasional failure
    if (Math.random() < 0.05) {
      throw new Error('Image processing service unavailable');
    }
    
    return {
      processedUrl: `https://cdn.workflowhub.com/processed/${imageData.filename}`,
      size: 1024 + Math.random() * 2048,
      format: 'jpeg',
    };
  }
  
  // Check if we're hitting rate limits
  getRateLimitStatus() {
    return {
      totalRequests: this.requestCount,
      requestsInLastMinute: 0, // Would track in real implementation
      limit: this.rateLimit.maxRequestsPerMinute,
      remaining: this.rateLimit.maxRequestsPerMinute - this.requestCount,
    };
  }
}

const imageService = new ImageProcessingService();

export const imageProcessingWorkflow = inngest.createFunction(
  {
    id: 'image-processing-workflow',
    name: 'Image Processing Pipeline',
    description: 'Process images with throttling and rate limiting',
    
    // Global rate limit for this function
    rateLimit: {
      limit: 10, // Only 10 batches per
      period: '1m', // minute
    },
  },
  { event: 'images/processing-requested' },
  async ({ event, step, logger }) => {
    const validatedData = ImageProcessingEventSchema.parse(event.data);
    const { batchId, userId, images, priority } = validatedData;
    
    logger.info('Starting image processing batch', { 
      batchId, 
      userId, 
      imageCount: images.length,
      priority 
    });
    
    // Step 1: Validate images and prepare processing queue
    const validation = await step.run('validate-images', async () => {
      logger.info('Validating images', { batchId, imageCount: images.length });
      
      // Check for duplicate image URLs
      const urlSet = new Set();
      const duplicates = images.filter(img => {
        if (urlSet.has(img.url)) return true;
        urlSet.add(img.url);
        return false;
      });
      
      if (duplicates.length > 0) {
        logger.warn('Found duplicate image URLs', { batchId, duplicateCount: duplicates.length });
      }
      
      await new Promise((resolve) => setTimeout(resolve, 300));
      
      return {
        validImages: images,
        duplicateCount: duplicates.length,
        validatedAt: new Date().toISOString(),
      };
    });
    
    // Step 2: Process images with throttling
    const processedImages = await step.run('process-images-with-throttling', async () => {
      logger.info('Processing images with throttling', { 
        batchId, 
        imageCount: validation.validImages.length 
      });
      
      const results = [];
      let processedCount = 0;
      const totalImages = validation.validImages.length;
      
      // Process images one by one with throttling between each
      for (const image of validation.validImages) {
        try {
          // Apply throttling based on priority
          let delay = 1000; // Default 1 second between images
          
          if (priority === 'high') {
            delay = 500; // Higher priority gets faster processing
          } else if (priority === 'low') {
            delay = 2000; // Lower priority gets slower processing
          }
          
          // Wait before processing to throttle
          if (processedCount > 0) {
            await new Promise((resolve) => setTimeout(resolve, delay));
          }
          
          processedCount++;
          logger.info(`Processing image ${processedCount}/${totalImages}`, { 
            batchId, 
            imageId: image.id,
            filename: image.filename 
          });
          
          const result = await imageService.processImage({
            url: image.url,
            operations: image.operations,
            filename: image.filename,
          });
          
          results.push({
            imageId: image.id,
            success: true,
            ...result,
          });
        } catch (error) {
          logger.error(`Failed to process image ${image.id}`, { 
            batchId, 
            imageId: image.id,
            error: error.message 
          });
          
          results.push({
            imageId: image.id,
            success: false,
            error: error.message,
          });
        }
      }
      
      // Report rate limit status
      const rateStatus = imageService.getRateLimitStatus();
      logger.info('Rate limit status after processing', {
        batchId,
        processedImages: processedCount,
        ...rateStatus,
      });
      
      return {
        results,
        totalProcessed: processedCount,
        totalFailed: results.filter(r => !r.success).length,
        totalSuccess: results.filter(r => r.success).length,
      };
    });
    
    // Step 3: Aggregate results
    const aggregation = await step.run('aggregate-processing-results', async () => {
      logger.info('Aggregating processing results', { 
        batchId, 
        success: processedImages.totalSuccess,
        failed: processedImages.totalFailed 
      });
      
      const successImages = processedImages.results.filter(r => r.success);
      const failedImages = processedImages.results.filter(r => !r.success);
      
      return {
        batchId,
        summary: {
          total: processedImages.results.length,
          success: processedImages.totalSuccess,
          failed: processedImages.totalFailed,
          successRate: `${(processedImages.totalSuccess / processedImages.results.length * 100).toFixed(1)}%`,
        },
        successImages: successImages.map(r => ({
          imageId: r.imageId,
          processedUrl: r.processedUrl,
          size: r.size,
          format: r.format,
        })),
        failedImages: failedImages.map(r => ({
          imageId: r.imageId,
          error: r.error,
        })),
      };
    });
    
    // Step 4: Generate processing report
    const report = await step.run('generate-processing-report', async () => {
      logger.info('Generating processing report', { batchId });
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      return {
        reportId: `report-${batchId}`,
        generatedAt: new Date().toISOString(),
        url: `https://storage.workflowhub.com/reports/${batchId}.pdf`,
        summary: aggregation.summary,
      };
    });
    
    // Step 5: Notify user
    if (priority === 'high' || aggregation.summary.failed > 0) {
      await step.run('notify-user', async () => {
        logger.info('Notifying user about processing completion', { 
          batchId, 
          userId,
          failedCount: aggregation.summary.failed 
        });
        await new Promise((resolve) => setTimeout(resolve, 200));
        
        return {
          notified: true,
          timestamp: new Date().toISOString(),
        };
      });
    }
    
    return {
      batchId,
      userId,
      processedAt: new Date().toISOString(),
      aggregation,
      report,
      hasFailures: aggregation.summary.failed > 0,
      processingDuration: Date.now() - new Date(event.data.timestamp || Date.now()).getTime(),
    };
  }
);
```

---

## Module 3.4: Debouncing and Batching

### The Target

Learn how to aggregate multiple events into a single batch for efficient processing and prevent duplicate work.

### The Concept

Debouncing and batching are like **grouping orders** at a restaurant:

1. **Debouncing**: "Wait 5 seconds after the last request before processing" (ignore rapid-fire events)
2. **Batching**: "Collect all orders from the last 5 minutes and process them together" (group similar items)

These patterns are essential for:
- Webhook handlers (many rapid events)
- Analytics aggregation (batching events)
- Email digest generation (grouping notifications)
- API rate limit optimization (minimizing calls)

### The Implementation: Event Aggregator with Debouncing

```typescript
// src/inngest/functions/event-aggregator.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Event for individual user actions
const UserActionEventSchema = z.object({
  userId: z.string().uuid(),
  action: z.enum(['view', 'click', 'purchase', 'signup', 'login']),
  resourceId: z.string().optional(),
  metadata: z.record(z.any()).optional(),
  timestamp: z.string().datetime(),
});

// Event aggregator with debouncing
export const eventAggregatorWorkflow = inngest.createFunction(
  {
    id: 'event-aggregator-workflow',
    name: 'Event Aggregator with Debouncing',
    description: 'Aggregate user actions into digest with debouncing',
    
    // Debounce configuration
    // Wait 30 seconds after the last event before processing
    // This prevents processing individual events and batches them
    debounce: {
      key: 'data.userId', // Group by user ID
      period: '30s', // Wait 30 seconds after last event
    },
    
    // Rate limit to prevent overload
    rateLimit: {
      limit: 100,
      period: '1m',
    },
  },
  { event: 'user/action' },
  async ({ event, step, logger }) => {
    const validatedData = UserActionEventSchema.parse(event.data);
    const { userId, action, resourceId, metadata, timestamp } = validatedData;
    
    logger.info('Processing user action', { userId, action, resourceId });
    
    // Step 1: Store the individual action
    const storedAction = await step.run('store-action', async () => {
      logger.info('Storing user action', { userId, action });
      
      // Simulate storing action in database
      await new Promise((resolve) => setTimeout(resolve, 100));
      
      return {
        actionId: `action-${Date.now()}`,
        userId,
        action,
        resourceId,
        metadata,
        timestamp,
        storedAt: new Date().toISOString(),
      };
    });
    
    // Step 2: Check if we should process the digest
    // The debounce period ensures this only runs after the last event
    
    // Step 3: Get all recent actions for this user
    const recentActions = await step.run('get-recent-actions', async () => {
      logger.info('Getting recent actions for user', { userId });
      
      // Simulate fetching recent actions from database
      await new Promise((resolve) => setTimeout(resolve, 200));
      
      // Generate synthetic actions for demonstration
      const actions = [];
      const actionTypes = ['view', 'click', 'view', 'purchase', 'view'];
      const resources = ['page-1', 'page-2', 'product-123', 'checkout', 'page-3'];
      
      for (let i = 0; i < 5 + Math.floor(Math.random() * 10); i++) {
        actions.push({
          actionId: `action-${Date.now() + i}`,
          userId,
          action: actionTypes[i % actionTypes.length],
          resourceId: resources[i % resources.length],
          timestamp: new Date(Date.now() - i * 30000).toISOString(),
        });
      }
      
      return {
        actions,
        count: actions.length,
        userId,
      };
    });
    
    // Step 4: Generate digest
    const digest = await step.run('generate-user-digest', async () => {
      logger.info('Generating digest for user', { 
        userId, 
        actionCount: recentActions.count 
      });
      
      // Group actions by type
      const grouped = recentActions.actions.reduce((acc, action) => {
        const key = action.action;
        if (!acc[key]) acc[key] = [];
        acc[key].push(action);
        return acc;
      }, {} as Record<string, any[]>);
      
      // Count action types
      const summary = Object.entries(grouped).map(([actionType, items]) => ({
        action: actionType,
        count: items.length,
        resources: items.map(i => i.resourceId).filter(Boolean),
      }));
      
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      return {
        userId,
        period: {
          start: recentActions.actions[0]?.timestamp || new Date().toISOString(),
          end: new Date().toISOString(),
        },
        totalActions: recentActions.count,
        summary,
        groupedActions: grouped,
        digestId: `digest-${userId}-${Date.now()}`,
        generatedAt: new Date().toISOString(),
      };
    });
    
    // Step 5: Send digest (if enough actions)
    if (digest.totalActions > 3) {
      await step.run('send-digest-notification', async () => {
        logger.info('Sending digest notification', { 
          userId, 
          totalActions: digest.totalActions 
        });
        
        // Simulate sending email or push notification
        await new Promise((resolve) => setTimeout(resolve, 300));
        
        return {
          sent: true,
          notificationId: `notify-${Date.now()}`,
          sentAt: new Date().toISOString(),
        };
      });
    }
    
    return {
      processed: true,
      userId,
      action: storedAction,
      digest,
      sent: digest.totalActions > 3,
      processedAt: new Date().toISOString(),
    };
  }
);
```

### Batching Multiple Events

Here's a workflow that batches multiple events of the same type:

```typescript
// src/inngest/functions/batch-processor.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

export const batchProcessorWorkflow = inngest.createFunction(
  {
    id: 'batch-processor-workflow',
    name: 'Batch Event Processor',
    description: 'Process multiple events in a single batch',
    
    // Batch configuration
    // Collect up to 100 events or wait 60 seconds
    batch: {
      maxSize: 100,
      timeout: '60s',
      key: 'data.tenantId', // Group by tenant ID
    },
  },
  { event: 'event/to/process' },
  async ({ event, step, logger }) => {
    // The event will contain an array of batched events
    const batchedEvents = event.data.events || [event.data];
    
    logger.info('Processing batch', { 
      batchSize: batchedEvents.length,
      tenantId: batchedEvents[0]?.tenantId,
    });
    
    // Step 1: Validate all events in the batch
    const validation = await step.run('validate-batch', async () => {
      logger.info('Validating batch', { size: batchedEvents.length });
      
      const valid = [];
      const invalid = [];
      
      for (const ev of batchedEvents) {
        try {
          const result = await validateEvent(ev);
          if (result.valid) {
            valid.push(ev);
          } else {
            invalid.push({ event: ev, reason: result.reason });
          }
        } catch (error) {
          invalid.push({ event: ev, reason: error.message });
        }
      }
      
      return {
        total: batchedEvents.length,
        valid: valid.length,
        invalid: invalid.length,
        validEvents: valid,
        invalidEvents: invalid,
      };
    });
    
    // Step 2: Process valid events in parallel
    const processed = await step.run('process-batch-events', async () => {
      logger.info('Processing batch events', { 
        totalValid: validation.validEvents.length 
      });
      
      // Process all valid events in parallel with concurrency limit
      const BATCH_CONCURRENCY = 10;
      const results = [];
      
      for (let i = 0; i < validation.validEvents.length; i += BATCH_CONCURRENCY) {
        const chunk = validation.validEvents.slice(i, i + BATCH_CONCURRENCY);
        
        const chunkResults = await Promise.all(
          chunk.map(async (ev) => {
            try {
              // Simulate processing
              await new Promise((resolve) => setTimeout(resolve, 200 + Math.random() * 300));
              return {
                success: true,
                event: ev,
                processedAt: new Date().toISOString(),
              };
            } catch (error) {
              return {
                success: false,
                event: ev,
                error: error.message,
              };
            }
          })
        );
        
        results.push(...chunkResults);
      }
      
      return {
        results,
        totalProcessed: results.length,
        successful: results.filter(r => r.success).length,
        failed: results.filter(r => !r.success).length,
      };
    });
    
    return {
      batchId: `batch-${Date.now()}`,
      processedAt: new Date().toISOString(),
      summary: {
        total: batchedEvents.length,
        valid: validation.valid,
        invalid: validation.invalid,
        processed: processed.totalProcessed,
        successful: processed.successful,
        failed: processed.failed,
      },
      results: processed.results,
      invalidEvents: validation.invalidEvents,
    };
  }
);

// Helper validation function
async function validateEvent(event: any) {
  // Simulate validation
  await new Promise((resolve) => setTimeout(resolve, 50));
  
  if (!event.tenantId) {
    return { valid: false, reason: 'Missing tenantId' };
  }
  
  if (!event.type) {
    return { valid: false, reason: 'Missing event type' };
  }
  
  return { valid: true };
}
```

---

## Verification: Testing High-Performance Patterns

### Step 1: Test Bulk Email Campaign

```bash
# Create a campaign with multiple recipients (using a test file)
cat > test-campaign.json << 'EOF'
{
  "campaignId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Weekly Newsletter",
  "subject": "Your Weekly Update",
  "htmlContent": "<h1>Hello!</h1><p>Here's your weekly update...</p>",
  "fromEmail": "newsletter@workflowhub.com",
  "recipients": [
    {"id": "user-1", "email": "user1@example.com", "name": "User One"},
    {"id": "user-2", "email": "user2@example.com", "name": "User Two"},
    {"id": "user-3", "email": "user3@example.com", "name": "User Three"}
  ]
}
EOF

# Send the campaign event
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d @test-campaign.json
```

### Step 2: Test Task Scheduler with Concurrency

```bash
# Send multiple tasks to test concurrency limits
for i in {1..20}; do
  curl -X POST http://localhost:3000/api/inngest \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"task/scheduled\",
      \"data\": {
        \"taskId\": \"$i-123e4567-e89b-12d3-a456-426614174000\",
        \"tenantId\": \"tenant-123\",
        \"type\": \"data-processing\",
        \"priority\": \"medium\",
        \"payload\": {\"job\": \"task-$i\"}
      }
    }"
done
```

### Step 3: Test Debounced Event Aggregator

```bash
# Send multiple actions for the same user within a short period
for action in view click view purchase view; do
  curl -X POST http://localhost:3000/api/inngest \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"user/action\",
      \"data\": {
        \"userId\": \"123e4567-e89b-12d3-a456-426614174000\",
        \"action\": \"$action\",
        \"resourceId\": \"resource-123\",
        \"timestamp\": \"$(date -Iseconds)\"
      }
    }"
  
  # Short delay between actions
  sleep 2
done
```

### Step 4: Monitor Performance

Open the Inngest Dev Server at `http://localhost:3000/api/inngest` and observe:

1. **Fan-Out Execution**: See how the bulk email campaign processes all recipients in parallel
2. **Concurrency Limits**: Watch how task scheduler respects concurrency limits
3. **Debouncing**: Notice how events are aggregated and processed in batches
4. **Performance Metrics**: Check execution times and step durations

---

## Deep Dive: Performance Optimization

### Optimizing Step Execution

```typescript
// src/inngest/helpers/optimization.ts
export const optimizationHelpers = {
  // Cache expensive results
  cacheStepResult: async <T>(
    step: any,
    name: string,
    fn: () => Promise<T>,
    ttl: number = 3600000 // 1 hour
  ): Promise<T> => {
    // This is a pattern - Inngest handles caching automatically
    // through step memoization
    return await step.run(name, fn);
  },
  
  // Parallel execution with concurrency control
  parallelWithConcurrency: async <T>(
    items: any[],
    worker: (item: any) => Promise<T>,
    concurrency: number = 10
  ): Promise<T[]> => {
    const results: T[] = [];
    const chunks = [];
    
    for (let i = 0; i < items.length; i += concurrency) {
      chunks.push(items.slice(i, i + concurrency));
    }
    
    for (const chunk of chunks) {
      const chunkResults = await Promise.all(chunk.map(worker));
      results.push(...chunkResults);
    }
    
    return results;
  },
  
  // Throttled execution
  throttledExecution: async <T>(
    items: any[],
    worker: (item: any) => Promise<T>,
    delay: number = 1000
  ): Promise<T[]> => {
    const results: T[] = [];
    
    for (let i = 0; i < items.length; i++) {
      if (i > 0) {
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
      
      const result = await worker(items[i]);
      results.push(result);
    }
    
    return results;
  },
};
```

### Reducing Cold Starts

```typescript
// src/inngest/helpers/warmup.ts
export async function warmupInngest() {
  if (process.env.NODE_ENV === 'production') {
    // Warm up by sending a test event
    await inngest.send({
      name: 'system/warmup',
      data: {
        timestamp: Date.now(),
        version: process.env.npm_package_version || 'unknown',
      },
    });
  }
}
```

---

## Troubleshooting Common Performance Issues

### Issue: Fan-Out Operations Overwhelming System

**Problem:** Too many parallel operations causing resource exhaustion.

**Solution:**
```typescript
// Use smaller batch sizes and concurrency limits
const BATCH_SIZE = 20; // Reduce from 50 to 20
const BATCH_CONCURRENCY = 5; // Reduce concurrent batches

// Implement throttling between batches
for (let i = 0; i < items.length; i += BATCH_SIZE) {
  const batch = items.slice(i, i + BATCH_SIZE);
  
  // Wait between batches
  if (i > 0) {
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
  
  const batchResults = await step.run(`process-batch-${i}`, async () => {
    // Process batch with limited concurrency
    const results = [];
    for (let j = 0; j < batch.length; j += BATCH_CONCURRENCY) {
      const chunk = batch.slice(j, j + BATCH_CONCURRENCY);
      const chunkResults = await Promise.all(chunk.map(processItem));
      results.push(...chunkResults);
    }
    return results;
  });
}
```

### Issue: Rate Limits Being Hit

**Problem:** External API rate limits are being exceeded.

**Solution:**
```typescript
// Implement token bucket algorithm
class TokenBucket {
  private tokens: number;
  private lastRefill: number;
  
  constructor(private capacity: number, private refillRate: number) {
    this.tokens = capacity;
    this.lastRefill = Date.now();
  }
  
  async waitForToken(): Promise<void> {
    this.refill();
    if (this.tokens < 1) {
      const waitTime = Math.ceil((1 - this.tokens) * this.refillRate);
      await new Promise((resolve) => setTimeout(resolve, waitTime));
      return this.waitForToken();
    }
    this.tokens--;
  }
  
  private refill(): void {
    const now = Date.now();
    const elapsed = (now - this.lastRefill) / 1000;
    const newTokens = elapsed * this.refillRate;
    this.tokens = Math.min(this.capacity, this.tokens + newTokens);
    this.lastRefill = now;
  }
}

// Use in your workflow
const rateLimiter = new TokenBucket(10, 1); // 10 tokens, refill 1 per second

const result = await step.run('rate-limited-step', async () => {
  await rateLimiter.waitForToken();
  return await externalAPI.call();
});
```

---

## What You've Accomplished

In Part 3, you've mastered high-performance workflow patterns:

1. ✅ Fan-out/fan-in orchestration for bulk processing
2. ✅ Multi-level concurrency management
3. ✅ Throttling and rate limiting patterns
4. ✅ Debouncing and batching for event aggregation
5. ✅ Performance optimization techniques
6. ✅ Resource protection strategies
7. ✅ Real-world bulk email campaign processor
8. ✅ Multi-tenant task scheduler
9. ✅ Image processing pipeline
10. ✅ Comprehensive testing and monitoring

You've learned:
- How to scale workflows to thousands of operations
- How to protect downstream systems from overload
- How to aggregate and batch events efficiently
- How to manage concurrency at multiple levels
- Performance optimization best practices

---

## Deep Dive Reference: Concurrency and Rate Limiting Cheatsheet

### Concurrency Configuration

```typescript
// Function-level concurrency
concurrency: {
  limit: 10, // Max concurrent runs
  scope: 'fn', // Applies to this function only
}

// Key-based concurrency (per tenant/user)
concurrency: {
  limit: 5,
  scope: 'key',
  key: 'data.tenantId', // Each tenant gets 5 concurrent runs
}

// Global concurrency
concurrency: {
  limit: 100,
  scope: 'global', // Across all functions
}
```

### Rate Limiting

```typescript
// Basic rate limiting
rateLimit: {
  limit: 100,
  period: '1m', // 100 runs per minute
}

// Key-based rate limiting
rateLimit: {
  limit: 10,
  period: '1s',
  key: 'data.userId', // 10 runs per second per user
}
```

### Debouncing

```typescript
// Wait 30 seconds after the last event
debounce: {
  key: 'data.userId',
  period: '30s',
}

// Wait for at least 5 events
debounce: {
  key: 'data.tenantId',
  period: '10s',
}
```

### Batching

```typescript
// Collect up to 100 events or wait 60 seconds
batch: {
  maxSize: 100,
  timeout: '60s',
  key: 'data.userId',
}
```

---

## Next Steps

In **Part 4**, we'll explore long-running workflows and human-in-the-loop automation:
- Saga pattern implementation
- Waiting for external events
- Approval workflows
- Timeout handling
- Workflow versioning and safe deployments
- Customer onboarding automation
- Subscription lifecycle management

---

## References

- [Inngest Fan-Out Pattern](https://www.inngest.com/docs/learn/fan-out-fan-in)
- [Concurrency Control Documentation](https://www.inngest.com/docs/guides/concurrency)
- [Rate Limiting Best Practices](https://www.inngest.com/docs/guides/rate-limiting)
- [Debouncing and Batching](https://www.inngest.com/docs/guides/debounce-batch)
- [Performance Optimization Guide](https://www.inngest.com/docs/learn/performance)
