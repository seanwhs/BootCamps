# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Appendix C: Troubleshooting Common Issues

This appendix provides a comprehensive guide to diagnosing and resolving the most common issues encountered when building and deploying Inngest workflows. Each issue includes symptoms, causes, solutions, and prevention strategies.

---

## C.1 Installation and Setup Issues

### Issue: Inngest Package Installation Fails

**Symptoms:**
- `pnpm add inngest` or `npm install inngest` fails
- Peer dependency conflicts
- "Cannot find module 'inngest'" errors

**Causes:**
- Node.js version incompatibility
- Conflicting peer dependencies
- Network issues or registry problems

**Solutions:**

```bash
# Check Node.js version (requires 18+)
node --version

# Clear npm cache and retry
npm cache clean --force
pnpm install --force

# Install with legacy peer deps
npm install inngest --legacy-peer-deps

# Use specific version if latest is unstable
pnpm add inngest@4.0.0
```

**Prevention:**
- Use Node.js 20 LTS for development
- Use `pnpm` for better dependency management
- Lock versions in `package.json`

---

### Issue: Dev Server Not Starting

**Symptoms:**
- `pnpm dev` starts but Inngest Dev Server doesn't load
- "Could not start Inngest dev server" error
- Dashboard at `/api/inngest` returns 404

**Causes:**
- Missing `INNGEST_DEV` environment variable
- Incorrect API route configuration
- Port conflicts
- Node.js memory limitations

**Solutions:**

```typescript
// Check your API route configuration
// src/app/api/inngest/route.ts
import { serve } from "inngest/next";
import { inngest } from "@/inngest/client";

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    // Ensure you're exporting functions here
  ],
});

// Don't forget to disable body parser
export const config = {
  api: {
    bodyParser: false,
  },
};
```

```bash
# Set environment variable
echo "INNGEST_DEV=true" >> .env.local

# Check if port 3000 is available
lsof -i :3000
kill -9 <PID>  # Kill process using port

# Increase memory limit
NODE_OPTIONS="--max-old-space-size=4096" pnpm dev
```

**Prevention:**
- Always set `INNGEST_DEV=true` in `.env.local`
- Include all functions in the serve handler
- Use `pnpm dev` with the `--inspect` flag for debugging

---

## C.2 Event Issues

### Issue: Events Not Triggering Workflows

**Symptoms:**
- Events sent successfully but workflows don't execute
- "No matching function found" errors
- Events appear in dev server but no runs created

**Causes:**
- Event name mismatch (typo or case sensitivity)
- Function not registered in route handler
- Event schema validation failure
- Incorrect event data structure

**Solutions:**

```typescript
// Check event name matches exactly
// ✅ Correct
{ event: 'user/registered' }

// ❌ Wrong (typo)
{ event: 'user/registred' }

// ❌ Wrong (different naming)
{ event: 'user.registered' }

// Verify function registration
// src/app/api/inngest/route.ts
import { userRegistrationWorkflow } from '@/inngest/functions/user-registration';

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    userRegistrationWorkflow, // Must be included
    // ... other functions
  ],
});
```

```bash
# Test event with curl
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "user/registered",
    "data": {
      "userId": "123e4567-e89b-12d3-a456-426614174000",
      "email": "test@example.com",
      "name": "Test User",
      "plan": "pro"
    }
  }'

# Check dev server logs for matching
# Look for: "Received event: user/registered"
# Look for: "Matched function: user-registration-workflow"
```

**Prevention:**
- Use TypeScript for type safety
- Define event types using `eventType()` helper
- Validate event data with Zod schemas
- Log event names in middleware for debugging

---

### Issue: Invalid Event Data

**Symptoms:**
- "Zod validation error" in logs
- "Invalid UUID" or "Invalid email" errors
- Workflow fails immediately after starting

**Causes:**
- Event data missing required fields
- Data doesn't match expected format
- Data types are incorrect (string vs number)

**Solutions:**

```typescript
// Use Zod schemas with detailed error messages
import { z } from 'zod';

const UserRegistrationEventSchema = z.object({
  userId: z.string().uuid({ message: 'userId must be a valid UUID' }),
  email: z.string().email({ message: 'email must be a valid email address' }),
  name: z.string().min(2).max(100),
  plan: z.enum(['free', 'pro', 'enterprise']),
});

// Validate and parse with error handling
try {
  const validated = UserRegistrationEventSchema.parse(event.data);
  // ... workflow logic
} catch (error) {
  if (error instanceof z.ZodError) {
    logger.error('Validation failed', {
      errors: error.errors.map(e => ({
        path: e.path.join('.'),
        message: e.message,
      })),
    });
    throw new Error(`Invalid event data: ${error.message}`);
  }
  throw error;
}
```

**Prevention:**
- Always validate event data with Zod
- Provide helpful error messages
- Test with invalid data during development
- Use TypeScript for compile-time checking

---

## C.3 Step Execution Issues

### Issue: Steps Failing with "Maximum retries exceeded"

**Symptoms:**
- Step fails repeatedly
- "Max retries exceeded" error
- Workflow never completes

**Causes:**
- External service unavailable
- Network timeouts
- Step logic has bugs
- Rate limiting from external APIs

**Solutions:**

```typescript
// Increase retry attempts for specific steps
export const paymentRetryWorkflow = inngest.createFunction(
  {
    id: 'payment-retry-workflow',
    retries: 5, // 5 attempts for the entire function
    retryDelay: '10s', // Wait 10 seconds between retries
  },
  { event: 'payment/initiated' },
  async ({ event, step, logger }) => {
    // Step with its own retry logic
    const result = await step.run('process-payment', async () => {
      // Implement custom retry logic
      for (let attempt = 0; attempt < 3; attempt++) {
        try {
          return await processPayment();
        } catch (error) {
          if (attempt === 2) throw error;
          await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
        }
      }
    });
  }
);

// Use circuit breaker pattern
class CircuitBreaker {
  private failures = 0;
  private state: 'closed' | 'open' = 'closed';
  
  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      throw new Error('Circuit breaker is open');
    }
    
    try {
      const result = await fn();
      this.failures = 0;
      return result;
    } catch (error) {
      this.failures++;
      if (this.failures >= 5) {
        this.state = 'open';
        // Reset after 60 seconds
        setTimeout(() => { this.state = 'closed'; }, 60000);
      }
      throw error;
    }
  }
}

const breaker = new CircuitBreaker();
const result = await breaker.execute(() => externalService.call());
```

**Prevention:**
- Implement retry logic with exponential backoff
- Use circuit breaker patterns for external services
- Monitor external service health
- Set realistic timeout values

---

### Issue: Sleep Not Working

**Symptoms:**
- `step.sleep()` returns immediately
- Workflow doesn't wait the expected duration
- Timeout errors in long-running workflows

**Causes:**
- Negative wait time calculation
- Date/time parsing issues
- Timezone confusion
- Wait time exceeds maximum duration

**Solutions:**

```typescript
// Log wait time for debugging
const scheduledTime = new Date(scheduledFor).getTime();
const currentTime = Date.now();
const waitTime = scheduledTime - currentTime;

logger.info('Sleep timing', {
  scheduledFor,
  scheduledTime: new Date(scheduledTime).toISOString(),
  currentTime: new Date(currentTime).toISOString(),
  waitTime,
  waitTimeSeconds: Math.floor(waitTime / 1000),
});

// Ensure positive wait time
if (waitTime > 0) {
  // Use step.sleep with duration in milliseconds
  await step.sleep('wait-for-schedule', waitTime);
} else {
  logger.warn('Wait time is negative, continuing immediately');
}

// Use step.sleepUntil for absolute dates
await step.sleepUntil('wait-for-schedule', new Date(scheduledFor));

// Handle timezone issues
import { zonedTimeToUtc } from 'date-fns-tz';
const utcTime = zonedTimeToUtc(scheduledFor, 'America/New_York');
await step.sleepUntil('wait-for-schedule', utcTime);
```

**Prevention:**
- Always use ISO datetime strings (YYYY-MM-DDTHH:mm:ssZ)
- Store times in UTC in the database
- Use `step.sleepUntil` for absolute times
- Add logging before and after sleep

---

### Issue: waitForEvent Timeouts

**Symptoms:**
- `step.waitForEvent()` always times out
- Workflow never receives expected event
- "Timeout" error in logs

**Causes:**
- Event name mismatch
- Matching condition doesn't match
- Timeout too short
- Event never sent

**Solutions:**

```typescript
// Debug waitForEvent matching
const decision = await step.waitForEvent('wait-for-approval', {
  event: 'purchase/approved',
  timeout: '24h',
  match: (data: any) => {
    // Log the matching attempt
    logger.info('Matching approval event', {
      receivedId: data.purchaseId,
      expectedId: purchaseId,
      match: data.purchaseId === purchaseId,
    });
    return data.purchaseId === purchaseId;
  },
});

// Send the event correctly
await inngest.send({
  name: 'purchase/approved',
  data: {
    purchaseId: '123e4567-e89b-12d3-a456-426614174000', // Must match
    approved: true,
  },
});

// Increase timeout for long-running processes
const decision = await step.waitForEvent('wait-for-approval', {
  event: 'purchase/approved',
  timeout: '7d', // Wait up to 7 days
});

// Use a default value if timeout
try {
  const decision = await step.waitForEvent('wait-for-approval', {
    event: 'purchase/approved',
    timeout: '24h',
  });
  // Handle decision
} catch {
  // Timeout - use default
  logger.warn('Approval timed out, using default');
  const defaultDecision = { approved: false, reason: 'Timeout' };
  // Handle default
}
```

**Prevention:**
- Test matching logic thoroughly
- Use unique identifiers for matching
- Set appropriate timeouts
- Implement timeout handlers with defaults

---

## C.4 Performance Issues

### Issue: Slow Workflow Execution

**Symptoms:**
- Workflows take longer than expected
- Steps appear to hang
- High latency in event processing

**Causes:**
- External API delays
- Database query performance issues
- Large data serialization/deserialization
- Sequential steps that could be parallel

**Solutions:**

```typescript
// Parallelize independent steps
const [user, orders, profile] = await Promise.all([
  step.run('get-user', () => db.user.findUnique({ where: { id: userId } })),
  step.run('get-orders', () => db.order.findMany({ where: { userId } })),
  step.run('get-profile', () => db.profile.findUnique({ where: { userId } })),
]);

// Batch database queries
const users = await step.run('get-users', () => 
  db.user.findMany({
    where: { id: { in: userIds } },
  })
);

// Use pagination for large datasets
const allOrders = [];
let cursor = undefined;
do {
  const page = await step.run(`get-orders-page-${allOrders.length}`, () =>
    db.order.findMany({
      take: 100,
      cursor,
      where: { userId },
    })
  );
  allOrders.push(...page);
  cursor = page.length > 0 ? { id: page[page.length - 1].id } : undefined;
} while (cursor);

// Add caching for expensive operations
const cachedResult = await step.run('get-cached-data', async () => {
  const cacheKey = `data:${userId}`;
  const cached = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);
  
  const data = await expensiveOperation();
  await redis.setex(cacheKey, 3600, JSON.stringify(data));
  return data;
});
```

**Prevention:**
- Profile step execution times
- Use connection pooling for databases
- Implement caching for repeated queries
- Monitor external API performance

---

### Issue: Memory Issues in Large Batches

**Symptoms:**
- Out of memory errors
- Workflow fails with "heap out of memory"
- Slow processing of large datasets

**Causes:**
- Loading too much data into memory at once
- Memory leaks in step functions
- Large event payloads

**Solutions:**

```typescript
// Process large batches in chunks
const CHUNK_SIZE = 50;

for (let i = 0; i < items.length; i += CHUNK_SIZE) {
  const chunk = items.slice(i, i + CHUNK_SIZE);
  
  const results = await step.run(`process-chunk-${i}`, async () => {
    // Process chunk
    const chunkResults = await Promise.all(
      chunk.map(item => processItem(item))
    );
    
    // Clear memory by not storing all results
    // Store results directly to database
    await storeResults(chunkResults);
    
    return { processed: chunkResults.length };
  });
  
  // Log progress
  logger.info(`Processed ${i + chunk.length} of ${items.length}`);
}

// Use streams for large data
import { createReadStream } from 'fs';
import { pipeline } from 'stream/promises';

const results = await step.run('process-large-file', async () => {
  const processed = [];
  const stream = createReadStream('./large-file.csv');
  
  await pipeline(
    stream,
    // Transform stream that processes each line
    new Transform({
      objectMode: true,
      transform(chunk, encoding, callback) {
        const line = chunk.toString();
        const processed = processLine(line);
        callback(null, processed);
      },
    }),
    // Write processed data
    new Writable({
      objectMode: true,
      write(chunk, encoding, callback) {
        processed.push(chunk);
        callback();
      },
    })
  );
  
  return processed;
});
```

**Prevention:**
- Limit batch size in workflows
- Use pagination for large datasets
- Process data in streams when possible
- Monitor memory usage in production

---

## C.5 Concurrency and Rate Limit Issues

### Issue: Rate Limit Exceeded

**Symptoms:**
- "Rate limit exceeded" errors
- Events being rejected
- 429 status codes

**Causes:**
- Too many events in a short period
- Concurrency limits too low
- External API rate limits

**Solutions:**

```typescript
// Implement rate limiting in workflow
export const rateLimitedWorkflow = inngest.createFunction(
  {
    id: 'rate-limited-workflow',
    rateLimit: {
      limit: 100,
      period: '1m',
      key: 'data.tenantId',
    },
  },
  { event: 'task/process' },
  async ({ event, step, logger }) => {
    // ... workflow logic
  }
);

// Use token bucket for external APIs
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

// Use in step
const rateLimiter = new TokenBucket(10, 1); // 10 tokens, refill 1 per second

const result = await step.run('rate-limited-api-call', async () => {
  await rateLimiter.waitForToken();
  return await externalApi.call();
});
```

**Prevention:**
- Configure rate limits based on external service capacity
- Use debouncing for high-frequency events
- Monitor rate limit usage in production

---

### Issue: Thundering Herd on Cron Jobs

**Symptoms:**
- System overload at cron boundaries
- All workflows start simultaneously
- Resource exhaustion

**Causes:**
- Many workflows scheduled at the same time
- No jitter in cron triggers

**Solutions:**

```typescript
// Add jitter to cron triggers
inngest.createFunction(
  {
    id: 'cron-with-jitter',
    triggers: [{
      cron: '0 * * * *', // Every hour
      jitter: '5m', // Random delay up to 5 minutes
    }],
  },
  async ({ step, logger }) => {
    // This will start at a random time within 5 minutes
    // of the hour boundary
  }
);

// Use internal queue with concurrency limits
export const queuedWorkflow = inngest.createFunction(
  {
    id: 'queued-workflow',
    concurrency: {
      limit: 10,
      scope: 'fn',
    },
  },
  { event: 'batch/process' },
  async ({ event, step, logger }) => {
    // Only 10 concurrent executions at a time
  }
);

// Staggered scheduling
const staggerDelay = (index: number) => index * 1000; // 1 second between each

for (let i = 0; i < items.length; i++) {
  await inngest.send({
    name: 'item/process',
    data: { item: items[i], index: i },
  });
  
  if (i < items.length - 1) {
    await new Promise(resolve => setTimeout(resolve, staggerDelay(i)));
  }
}
```

**Prevention:**
- Always use jitter with cron triggers
- Implement queuing for high-volume events
- Monitor system resources during peak times

---

## C.6 Deployment Issues

### Issue: Functions Not Registering in Production

**Symptoms:**
- Functions work locally but not in production
- "No functions registered" in Inngest dashboard
- 404 errors on /api/inngest endpoint

**Causes:**
- Functions not exported correctly
- Build optimization removing functions
- Incorrect path resolution
- Missing environment variables

**Solutions:**

```typescript
// Ensure functions are exported correctly
// src/app/api/inngest/route.ts
import { serve } from 'inngest/next';
import { inngest } from '@/inngest/client';
import { userRegistrationWorkflow } from '@/inngest/functions/user-registration';
// Make sure all functions are imported

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    userRegistrationWorkflow,
    // Include all functions here
  ],
});

// For Vercel: Check your next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Ensure functions aren't tree-shaken
  webpack: (config, { isServer }) => {
    if (isServer) {
      // Keep all function imports
      config.optimization.minimize = true;
      config.optimization.moduleIds = 'deterministic';
    }
    return config;
  },
};

// Check environment variables
// .env.production
INNGEST_EVENT_KEY=ev_prod_xxxxxxxxxxxxxxxx
INNGEST_SIGNING_KEY=sign_prod_xxxxxxxxxxxxxxxx
NEXT_PUBLIC_APP_URL=https://your-app.com

// Test endpoint in production
curl -X GET https://your-app.com/api/inngest
// Should return the dev server page with functions listed
```

**Prevention:**
- Test production build locally
- Use environment variables consistently
- Include all functions in serve handler

---

### Issue: Cold Starts in Serverless Environments

**Symptoms:**
- First execution is slow
- Timeouts on initial requests
- Inconsistent performance

**Causes:**
- Serverless function cold starts
- Large dependency size
- Database connection initialization

**Solutions:**

```typescript
// Implement warmup endpoint
// src/app/api/warmup/route.ts
export async function GET() {
  // Lightweight check
  const health = await checkInngestHealth();
  return NextResponse.json({ warmup: true, ...health });
}

// Use connection pooling
// src/lib/db.ts
import { PrismaClient } from '@prisma/client';

// Global singleton for Prisma
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

// Optimize bundle size
// next.config.js
const nextConfig = {
  experimental: {
    optimizeServerReact: true,
    optimizePackageImports: ['inngest', '@prisma/client'],
  },
};

// Use smaller function size in AWS Lambda
// serverless.yml
functions:
  api:
    handler: lambda.handler
    memorySize: 1024 # Increase memory for better performance
    timeout: 60
```

**Prevention:**
- Use connection pooling
- Minimize dependency size
- Implement warmup endpoints
- Monitor cold start times

---

## C.7 State and Data Issues

### Issue: Data Not Persisting Between Steps

**Symptoms:**
- Data from previous steps unavailable
- "undefined" errors in later steps
- State appears to reset

**Causes:**
- Returning data incorrectly from steps
- Mutating step results
- Not handling async data correctly

**Solutions:**

```typescript
// ✅ Correct: Return data from steps
const user = await step.run('get-user', async () => {
  // Return the data explicitly
  return await db.user.findUnique({ where: { id: userId } });
});

// Later steps can use user
const orders = await step.run('get-orders', async () => {
  // user is available here
  return await db.order.findMany({ where: { userId: user.id } });
});

// ❌ Wrong: Mutating external state
let externalUser; // Don't do this

await step.run('get-user', async () => {
  externalUser = await getUser(); // Won't persist
});

await step.run('process-user', async () => {
  // externalUser may be undefined
});

// ✅ Correct: Pass data explicitly
const user = await step.run('get-user', async () => {
  return await getUser();
});

await step.run('process-user', async () => {
  return await processUser(user);
});

// Handle complex state objects
const state = await step.run('get-state', async () => {
  return {
    user: await getUser(),
    orders: await getOrders(),
    profile: await getProfile(),
  };
});

// Use all parts of state
const summary = await step.run('create-summary', async () => {
  return {
    userName: state.user.name,
    orderCount: state.orders.length,
    profileComplete: !!state.profile,
  };
});
```

**Prevention:**
- Always return data from steps
- Use immutable data patterns
- Log step outputs for debugging
- Use TypeScript for type safety

---

### Issue: Duplicate Events or Steps

**Symptoms:**
- Same workflow running multiple times for one event
- Duplicate side effects (emails sent twice)
- Records with duplicate keys

**Causes:**
- Event sent multiple times
- Idempotency not implemented
- Retry causing step replay

**Solutions:**

```typescript
// Implement idempotency in workflow
export const idempotentWorkflow = inngest.createFunction(
  {
    id: 'idempotent-workflow',
    idempotency: {
      key: 'data.orderId',
      ttl: '30d',
    },
  },
  { event: 'order/processed' },
  async ({ event, step, logger }) => {
    const { orderId } = event.data;
    
    // Check if already processed
    const existing = await step.run('check-existing', async () => {
      return await db.processing.findUnique({
        where: { orderId },
      });
    });
    
    if (existing) {
      logger.info('Order already processed, skipping', { orderId });
      return { skipped: true, processedAt: existing.processedAt };
    }
    
    // Process the order
    const result = await step.run('process-order', async () => {
      // Idempotent operation
      const idempotencyKey = `order-${orderId}`;
      // Check again at the operation level
      const existingOp = await db.operations.findUnique({
        where: { idempotencyKey },
      });
      if (existingOp) return existingOp;
      
      const processed = await processOrder(orderId);
      await db.operations.create({
        data: {
          idempotencyKey,
          result: processed,
        },
      });
      return processed;
    });
    
    return { processed: true, result };
  }
);

// Use unique constraints in database
// schema.prisma
model OrderProcessing {
  id          String   @id @default(cuid())
  orderId     String   @unique
  processedAt DateTime @default(now())
  status      String
  result      Json?
}
```

**Prevention:**
- Always implement idempotency
- Use database unique constraints
- Test duplicate scenarios
- Log duplicate detection

---

## C.8 Security Issues

### Issue: Insecure Event Signing

**Symptoms:**
- "Invalid signature" errors
- Events being rejected
- Security warnings in logs

**Causes:**
- Missing signing key
- Incorrect signing configuration
- Signature verification failing

**Solutions:**

```typescript
// Ensure signing keys are set
export const inngest = new Inngest({
  id: 'workflowhub',
  eventKey: process.env.INNGEST_EVENT_KEY,
  signingKey: process.env.INNGEST_SIGNING_KEY,
});

// Verify signatures in middleware
export const authMiddleware = new InngestMiddleware({
  name: 'Authentication',
  init: () => ({
    onFunctionRun: ({ ctx }) => {
      const signature = ctx.headers['x-inngest-signature'];
      
      if (!signature && process.env.NODE_ENV === 'production') {
        throw new Error('Missing signature');
      }
      
      // Signature verification is handled by Inngest SDK
      // But we can add additional checks
    },
  }),
});

// Generate secure signing keys
// Use: openssl rand -base64 32
// Store in environment variables
```

**Prevention:**
- Always use signing keys in production
- Rotate keys regularly
- Never commit keys to version control

---

## C.9 Quick Diagnostic Commands

```bash
# Check Inngest Dev Server status
curl -I http://localhost:3000/api/inngest

# List registered functions
curl http://localhost:3000/api/inngest | jq '.functions[].id'

# Get workflow run status
curl http://localhost:3000/api/workflows/status/run_123

# Test event sending
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{"name":"test/event","data":{}}'

# Check environment variables
env | grep INNGEST

# View logs
pnpm dev 2>&1 | grep -i "inngest\|error\|warn"

# Check for port conflicts
lsof -i :3000

# Validate package versions
pnpm list inngest
```

---

## C.10 Common Error Messages and Resolutions

| Error Message | Probable Cause | Resolution |
|---------------|---------------|------------|
| `No matching function found for event` | Event name mismatch | Check event name and function registration |
| `Maximum retries exceeded` | Step failing repeatedly | Check external dependencies, increase retries |
| `Invalid signature` | Missing or incorrect signing key | Set INNGEST_SIGNING_KEY |
| `Rate limit exceeded` | Too many events | Implement rate limiting, increase limit |
| `Validation error` | Invalid event data | Check Zod schema, validate data |
| `Connection refused` | Service unavailable | Check network, restart services |
| `ETIMEDOUT` | Network timeout | Increase timeout, check connectivity |
| `ENOENT` | File not found | Check file paths, ensure files exist |
| `Cannot find module` | Missing dependency | Install missing package |
| `heap out of memory` | Memory exhaustion | Increase memory, optimize data handling |

---

This troubleshooting appendix provides solutions to the most common issues encountered when building and deploying Inngest workflows. Refer to the specific sections based on your problem type for detailed solutions and prevention strategies.
