# Phase 4, Part 1: Cloud-Native Architecture & Serverless

## Taking Your Architecture to the Cloud

Welcome to Phase 4! We're moving from running services on servers to cloud-native architecture. Think of this like moving from owning your own restaurant buildings to using a flexible kitchen-as-a-service platform - you can scale up during dinner rush and scale down during slow hours, paying only for what you use.

### 1. The Target

**What we're building:** Cloud-native deployment for our gateway service:
- Serverless function deployment (AWS Lambda, Cloudflare Workers)
- Cold start optimization strategies
- V8 isolate memory management
- Edge-friendly caching
- Distributed observability for serverless
- Infrastructure as Code (IaC) with Terraform

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── core/
│   ├── infrastructure/
│   ├── server.ts
│   ├── lambda.ts                        # NEW: AWS Lambda entry point
│   └── worker.ts                        # NEW: Cloudflare Worker entry point
│
├── infrastructure/
│   ├── terraform/                       # NEW: Infrastructure as Code
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── lambda.tf
│   │   ├── api-gateway.tf
│   │   └── cloudfront.tf
│   ├── cloudformation/                  # NEW: CloudFormation templates
│   │   └── serverless.yaml
│   └── configs/
│       ├── lambda-environment.json
│       └── worker-environment.json
│
├── scripts/
│   ├── deploy-lambda.sh                # NEW: Lambda deployment script
│   ├── deploy-worker.sh               # NEW: Worker deployment script
│   └── optimize-bundle.js              # NEW: Bundle optimization script
│
├── serverless.yml                       # NEW: Serverless Framework config
├── wrangler.toml                        # NEW: Cloudflare Workers config
└── package.json (updated)
```

### 2. The Concept: Cloud-Native Patterns

**Serverless Architecture:**
Like a restaurant where the kitchen staff appears magically when orders come in and disappears when idle - you only pay for the time they're cooking.

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVERLESS PLATFORM                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐     ┌──────────────┐     ┌───────────┐  │
│  │   Cold       │     │   Warm       │     │   Warm    │  │
│  │   Start      │────▶│   Instance   │────▶│  Instance │  │
│  │   (Slow)     │     │   (Fast)     │     │  (Fast)   │  │
│  └──────────────┘     └──────────────┘     └───────────┘  │
│         │                     │                   │         │
│         ▼                     ▼                   ▼         │
│  ┌──────────────┐     ┌──────────────┐     ┌───────────┐  │
│  │   V8         │     │   V8         │     │   V8      │  │
│  │   Isolate    │     │   Isolate    │     │   Isolate │  │
│  │   (Cold)     │     │   (Warm)     │     │  (Warm)   │  │
│  └──────────────┘     └──────────────┘     └───────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Cold Start:**
The delay when a function is invoked for the first time after being idle. Like a chef who needs to get all their tools out before starting to cook.

**V8 Isolates:**
Lightweight execution environments in Cloudflare Workers - like individual chef stations that are isolated from each other but share a common kitchen.

### 3. The Implementation

#### Step 1: Serverless Dependencies

Update `packages/gateway/package.json`:

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc && npm run build:serverless",
    "build:serverless": "npm run build:lambda && npm run build:worker",
    "build:lambda": "esbuild src/lambda.ts --bundle --platform=node --target=node18 --outfile=dist/lambda.js",
    "build:worker": "esbuild src/worker.ts --bundle --platform=browser --target=es2020 --outfile=dist/worker.js",
    "build:optimize": "node scripts/optimize-bundle.js",
    "deploy:lambda": "bash scripts/deploy-lambda.sh",
    "deploy:worker": "bash scripts/deploy-worker.sh",
    "deploy:terraform": "cd infrastructure/terraform && terraform apply",
    "start": "node dist/index.js",
    "test": "vitest",
    "type-check": "tsc --noEmit",
    "lint": "eslint src/**/*.ts"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/aws-lambda": "^8.10.130",
    "esbuild": "^0.19.11",
    "tsx": "^4.6.0",
    "typescript": "^5.3.0",
    "vitest": "^1.0.0",
    "eslint": "^8.55.0",
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0"
  }
}
```

#### Step 2: AWS Lambda Entry Point

**File:** `packages/gateway/src/lambda.ts`

```typescript
import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';
import { Server } from './server.js';
import { createChildLogger } from './logger.js';
import { postgresConnection } from './infrastructure/adapters/persistence/postgres/connection.js';
import { redisConnection } from './infrastructure/adapters/cache/redis/connection.js';
import { RequestContextManager } from './infrastructure/adapters/distributed/request-context.js';
import { CancellationManager } from './infrastructure/adapters/distributed/cancellation-manager.js';

/**
 * AWS Lambda Handler
 * 
 * This is the entry point for AWS Lambda.
 * 
 * Lambda cold start optimization strategies:
 * 1. Initialize connections lazily
 * 2. Use connection pooling outside the handler
 * 3. Minimize initialization code
 * 4. Use provisioned concurrency for production
 * 5. Keep the handler thin
 */
let server: Server | null = null;
let initializing = false;
let initPromise: Promise<void> | null = null;

const logger = createChildLogger({ module: 'LambdaHandler' });

/**
 * Initialize the server (lazy loading)
 * 
 * This runs outside the handler to reuse connections across invocations
 */
async function initialize(): Promise<void> {
  // If already initialized, skip
  if (server) return;

  // If initializing, wait for it to complete
  if (initializing && initPromise) {
    return initPromise;
  }

  initializing = true;
  initPromise = (async () => {
    try {
      logger.info('Initializing Lambda handler...');

      // Create server instance
      server = new Server();

      // Connect to database (lazy)
      await postgresConnection.connect().catch((error) => {
        logger.error({ error }, 'Failed to connect to PostgreSQL in Lambda');
        // Don't fail the initialization - we can retry per request
      });

      // Connect to Redis (lazy)
      await redisConnection.connect().catch((error) => {
        logger.warn({ error }, 'Failed to connect to Redis in Lambda');
      });

      logger.info('Lambda handler initialized successfully');
    } catch (error) {
      logger.error({ error }, 'Failed to initialize Lambda handler');
      throw error;
    } finally {
      initializing = false;
    }
  })();

  return initPromise;
}

/**
 * Lambda handler function
 * 
 * This is what AWS Lambda invokes
 * 
 * Performance optimizations:
 * - Reuse server instance across invocations
 * - Parse request body only when needed
 * - Use context for timing information
 */
export async function handler(
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> {
  const startTime = Date.now();
  const requestId = event.headers['x-request-id'] || context.awsRequestId;
  const correlationId = event.headers['x-correlation-id'] || requestId;

  logger.info({
    requestId,
    correlationId,
    path: event.path,
    method: event.httpMethod,
    awsRequestId: context.awsRequestId,
    invokedFunctionArn: context.invokedFunctionArn,
  }, 'Lambda invocation started');

  try {
    // Ensure server is initialized
    await initialize();

    if (!server) {
      throw new Error('Server initialization failed');
    }

    // Create request context
    const contextManager = RequestContextManager.createContext({
      requestId,
      correlationId,
      startTime,
      timeout: parseInt(event.headers['x-timeout'] || '30000', 10),
      headers: event.headers as Record<string, string>,
      userId: event.headers['x-user-id'],
    });

    // Create cancellation group
    const cancellationManager = CancellationManager.getInstance();
    const group = cancellationManager.createGroup(requestId, contextManager.timeout);

    // Execute the request in context
    const result = await RequestContextManager.runWithCancellation(
      contextManager,
      async (signal) => {
        // Create a request object for Fastify
        const request = {
          method: event.httpMethod,
          url: event.path,
          headers: event.headers,
          query: event.queryStringParameters || {},
          body: event.body ? JSON.parse(event.body) : undefined,
          id: requestId,
          requestContext: contextManager,
        };

        // Create a reply object
        const reply: any = {
          statusCode: 200,
          headers: {},
          send: (data: any) => data,
        };

        // Get the Fastify app and handle the request
        const app = server.getApp();
        
        // We need to simulate the request through Fastify
        // In production, you'd use a Lambda adapter like aws-lambda-fastify
        // This is simplified for the tutorial
        const response = await app.inject({
          method: event.httpMethod,
          url: event.path,
          headers: event.headers,
          payload: event.body,
          query: event.queryStringParameters || {},
        });

        // Clean up
        group.complete();

        // Build Lambda response
        return {
          statusCode: response.statusCode,
          headers: {
            'content-type': 'application/json',
            'x-request-id': requestId,
            'x-correlation-id': correlationId,
            ...response.headers,
          },
          body: response.body,
          isBase64Encoded: false,
        };
      }
    );

    const duration = Date.now() - startTime;
    logger.info({
      requestId,
      duration,
      statusCode: result.statusCode,
    }, 'Lambda invocation completed');

    return result;

  } catch (error) {
    const err = error instanceof Error ? error : new Error(String(error));
    const duration = Date.now() - startTime;

    logger.error({
      requestId,
      error: err.message,
      duration,
      stack: err.stack,
    }, 'Lambda invocation failed');

    return {
      statusCode: 500,
      headers: {
        'content-type': 'application/json',
        'x-request-id': requestId,
        'x-correlation-id': correlationId,
      },
      body: JSON.stringify({
        success: false,
        error: err.message,
        requestId,
      }),
      isBase64Encoded: false,
    };
  }
}

/**
 * Lambda warmup handler
 * 
 * Called to keep the Lambda warm and reduce cold starts
 */
export async function warmup(): Promise<{ status: string }> {
  await initialize();
  return { status: 'warm' };
}

/**
 * Graceful shutdown for Lambda
 */
export async function shutdown(): Promise<void> {
  logger.info('Shutting down Lambda...');
  
  if (server) {
    await postgresConnection.disconnect().catch(() => {});
    await redisConnection.disconnect().catch(() => {});
  }
  
  logger.info('Lambda shutdown complete');
}
```

#### Step 3: Cloudflare Worker Entry Point

**File:** `packages/gateway/src/worker.ts`

```typescript
import { Server } from './server.js';
import { createChildLogger } from './logger.js';
import { postgresConnection } from './infrastructure/adapters/persistence/postgres/connection.js';
import { redisConnection } from './infrastructure/adapters/cache/redis/connection.js';
import { RequestContextManager } from './infrastructure/adapters/distributed/request-context.js';

/**
 * Cloudflare Worker
 * 
 * This is the entry point for Cloudflare Workers.
 * 
 * V8 Isolate Optimizations:
 * 1. Keep initialization outside the handler
 * 2. Use Web APIs (Fetch, etc.) instead of Node.js APIs
 * 3. Minimize heap usage
 * 4. Use Edge caching for static responses
 * 5. Leverage Cloudflare's global network
 */
let server: Server | null = null;
let initialized = false;

const logger = createChildLogger({ module: 'WorkerHandler' });

/**
 * Initialize the worker (lazy loading)
 */
async function initialize(): Promise<void> {
  if (initialized && server) return;

  try {
    logger.info('Initializing Cloudflare Worker...');

    server = new Server();

    // Connect to services (lazy)
    await Promise.allSettled([
      postgresConnection.connect(),
      redisConnection.connect(),
    ]);

    initialized = true;
    logger.info('Cloudflare Worker initialized successfully');
  } catch (error) {
    logger.error({ error }, 'Failed to initialize Cloudflare Worker');
    throw error;
  }
}

/**
 * Cloudflare Worker handler
 * 
 * This is what Cloudflare invokes for each request
 */
export default {
  async fetch(request: Request, env: any, ctx: any): Promise<Response> {
    const startTime = Date.now();
    const url = new URL(request.url);
    const requestId = request.headers.get('x-request-id') || crypto.randomUUID();
    const correlationId = request.headers.get('x-correlation-id') || requestId;

    // Log request (but don't use console.log in production)
    logger.debug({
      requestId,
      correlationId,
      path: url.pathname,
      method: request.method,
      headers: Object.fromEntries(request.headers),
    }, 'Worker request started');

    try {
      // Ensure worker is initialized
      await initialize();

      if (!server) {
        throw new Error('Server initialization failed');
      }

      // Create request context
      const contextManager = RequestContextManager.createContext({
        requestId,
        correlationId,
        startTime,
        timeout: parseInt(request.headers.get('x-timeout') || '30000', 10),
        headers: Object.fromEntries(request.headers),
        userId: request.headers.get('x-user-id') || undefined,
      });

      // Execute the request in context
      const response = await RequestContextManager.runWithCancellation(
        contextManager,
        async (signal) => {
          // Get the Fastify app
          const app = server!.getApp();

          // Parse body if present
          let body: any;
          const contentType = request.headers.get('content-type');
          if (contentType?.includes('application/json')) {
            body = await request.json().catch(() => undefined);
          } else if (contentType?.includes('text/plain')) {
            body = await request.text().catch(() => undefined);
          }

          // Build query params
          const query: Record<string, string> = {};
          for (const [key, value] of url.searchParams) {
            query[key] = value;
          }

          // Inject the request into Fastify
          const result = await app.inject({
            method: request.method,
            url: url.pathname,
            headers: Object.fromEntries(request.headers),
            payload: body,
            query,
          });

          // Build the response
          const responseHeaders = new Headers();
          responseHeaders.set('x-request-id', requestId);
          responseHeaders.set('x-correlation-id', correlationId);

          // Add other headers
          if (result.headers) {
            for (const [key, value] of Object.entries(result.headers)) {
              if (value) {
                responseHeaders.set(key, value);
              }
            }
          }

          return new Response(result.body, {
            status: result.statusCode,
            headers: responseHeaders,
          });
        }
      );

      const duration = Date.now() - startTime;
      logger.debug({
        requestId,
        duration,
        status: response.status,
      }, 'Worker request completed');

      return response;

    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      const duration = Date.now() - startTime;

      logger.error({
        requestId,
        error: err.message,
        duration,
        stack: err.stack,
      }, 'Worker request failed');

      return new Response(
        JSON.stringify({
          success: false,
          error: err.message,
          requestId,
        }),
        {
          status: 500,
          headers: {
            'content-type': 'application/json',
            'x-request-id': requestId,
            'x-correlation-id': correlationId,
          },
        }
      );
    }
  },
};

/**
 * Worker health check
 */
export async function healthCheck(): Promise<{ status: string; healthy: boolean }> {
  try {
    await initialize();
    return { status: 'ok', healthy: true };
  } catch (error) {
    return { status: 'error', healthy: false };
  }
}
```

#### Step 4: Bundle Optimization

**File:** `packages/gateway/scripts/optimize-bundle.js`

```javascript
import { exec } from 'child_process';
import { promises as fs } from 'fs';
import { promisify } from 'util';
import path from 'path';

const execPromise = promisify(exec);
const __dirname = path.dirname(new URL(import.meta.url).pathname);

/**
 * Bundle Optimization Script
 * 
 * Optimizes the serverless bundle for cold start performance:
 * 1. Tree shaking to remove unused code
 * 2. Code splitting for faster loading
 * 3. Minification for smaller bundle size
 * 4. Compression for faster transfer
 */
async function optimizeBundle() {
  console.log('🔧 Optimizing serverless bundle...');

  const distDir = path.join(__dirname, '../dist');
  
  try {
    // 1. Build the bundles
    console.log('📦 Building Lambda bundle...');
    await execPromise('npm run build:lambda', { cwd: path.join(__dirname, '..') });

    console.log('📦 Building Worker bundle...');
    await execPromise('npm run build:worker', { cwd: path.join(__dirname, '..') });

    // 2. Minify the bundles
    console.log('🔨 Minifying bundles...');
    
    const lambdaPath = path.join(distDir, 'lambda.js');
    const workerPath = path.join(distDir, 'worker.js');
    
    // Use esbuild to minify
    await execPromise(
      `esbuild ${lambdaPath} --minify --outfile=${lambdaPath}`,
      { cwd: path.join(__dirname, '..') }
    );
    
    await execPromise(
      `esbuild ${workerPath} --minify --outfile=${workerPath}`,
      { cwd: path.join(__dirname, '..') }
    );

    // 3. Check sizes
    const lambdaSize = (await fs.stat(lambdaPath)).size;
    const workerSize = (await fs.stat(workerPath)).size;

    console.log(`✅ Lambda bundle size: ${(lambdaSize / 1024).toFixed(2)} KB`);
    console.log(`✅ Worker bundle size: ${(workerSize / 1024).toFixed(2)} KB`);

    // 4. Create gzip versions
    console.log('📦 Creating gzip versions...');
    await execPromise(`gzip -k ${lambdaPath}`, { cwd: path.join(__dirname, '..') });
    await execPromise(`gzip -k ${workerPath}`, { cwd: path.join(__dirname, '..') });

    const lambdaGzipSize = (await fs.stat(`${lambdaPath}.gz`)).size;
    const workerGzipSize = (await fs.stat(`${workerPath}.gz`)).size;

    console.log(`✅ Lambda gzip size: ${(lambdaGzipSize / 1024).toFixed(2)} KB`);
    console.log(`✅ Worker gzip size: ${(workerGzipSize / 1024).toFixed(2)} KB`);

    console.log('✅ Bundle optimization complete!');
    
    // 5. Generate bundle report
    const report = {
      timestamp: new Date().toISOString(),
      bundles: {
        lambda: {
          size: lambdaSize,
          gzip: lambdaGzipSize,
          sizeKB: (lambdaSize / 1024).toFixed(2),
          gzipKB: (lambdaGzipSize / 1024).toFixed(2),
        },
        worker: {
          size: workerSize,
          gzip: workerGzipSize,
          sizeKB: (workerSize / 1024).toFixed(2),
          gzipKB: (workerGzipSize / 1024).toFixed(2),
        },
      },
    };

    await fs.writeFile(
      path.join(distDir, 'bundle-report.json'),
      JSON.stringify(report, null, 2)
    );

    console.log('📊 Bundle report saved to dist/bundle-report.json');

  } catch (error) {
    console.error('❌ Bundle optimization failed:', error);
    process.exit(1);
  }
}

// Run the optimization
optimizeBundle().catch(console.error);
```

#### Step 5: Lambda Deployment Script

**File:** `packages/gateway/scripts/deploy-lambda.sh`

```bash
#!/bin/bash

# Lambda Deployment Script
# Deploys the service to AWS Lambda with optimal configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "${GREEN}🚀 Deploying to AWS Lambda...${NC}"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration
FUNCTION_NAME="${FUNCTION_NAME:-orchestrator-gateway}"
REGION="${REGION:-us-east-1}"
RUNTIME="${RUNTIME:-nodejs18.x}"
HANDLER="${HANDLER:-dist/lambda.handler}"
MEMORY_SIZE="${MEMORY_SIZE:-512}"
TIMEOUT="${TIMEOUT:-30}"
LAMBDA_ROLE="${LAMBDA_ROLE:-arn:aws:iam::${AWS_ACCOUNT_ID}:role/lambda-execution-role}"

echo "${YELLOW}Configuration:${NC}"
echo "  Function Name: $FUNCTION_NAME"
echo "  Region: $REGION"
echo "  Runtime: $RUNTIME"
echo "  Memory: ${MEMORY_SIZE}MB"
echo "  Timeout: ${TIMEOUT}s"

# 1. Build the bundle
echo "${YELLOW}📦 Building Lambda bundle...${NC}"
npm run build:lambda

# 2. Optimize the bundle
echo "${YELLOW}🔧 Optimizing bundle...${NC}"
node scripts/optimize-bundle.js

# 3. Package the deployment
echo "${YELLOW}📦 Packaging deployment...${NC}"
zip -j dist/lambda.zip dist/lambda.js

# 4. Check if function exists
if aws lambda get-function --function-name "$FUNCTION_NAME" --region "$REGION" &>/dev/null; then
    echo "${YELLOW}Function exists, updating...${NC}"
    
    # Update function code
    aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file fileb://dist/lambda.zip \
        --region "$REGION"

    # Update function configuration
    aws lambda update-function-configuration \
        --function-name "$FUNCTION_NAME" \
        --runtime "$RUNTIME" \
        --handler "$HANDLER" \
        --memory-size "$MEMORY_SIZE" \
        --timeout "$TIMEOUT" \
        --role "$LAMBDA_ROLE" \
        --region "$REGION"
else
    echo "${YELLOW}Function doesn't exist, creating...${NC}"
    
    # Create function
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime "$RUNTIME" \
        --handler "$HANDLER" \
        --zip-file fileb://dist/lambda.zip \
        --memory-size "$MEMORY_SIZE" \
        --timeout "$TIMEOUT" \
        --role "$LAMBDA_ROLE" \
        --region "$REGION"
fi

# 5. Configure environment variables
echo "${YELLOW}📝 Configuring environment variables...${NC}"

# Create environment variables file
cat > dist/env-vars.json << EOF
{
  "Variables": {
    "NODE_ENV": "production",
    "LOG_LEVEL": "${LOG_LEVEL:-info}",
    "DATABASE_URL": "$DATABASE_URL",
    "REDIS_URL": "$REDIS_URL",
    "JWT_SECRET": "$JWT_SECRET",
    "SERVICE_NAME": "gateway",
    "SERVICE_VERSION": "${SERVICE_VERSION:-1.0.0}"
  }
}
EOF

aws lambda update-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --environment file://dist/env-vars.json \
    --region "$REGION"

# 6. Create or update alias
echo "${YELLOW}🏷️ Creating alias...${NC}"
VERSION=$(aws lambda publish-version --function-name "$FUNCTION_NAME" --region "$REGION" --query '{Version:Version}' --output text)
aws lambda create-alias \
    --function-name "$FUNCTION_NAME" \
    --name "production" \
    --function-version "$VERSION" \
    --region "$REGION" 2>/dev/null || \
aws lambda update-alias \
    --function-name "$FUNCTION_NAME" \
    --name "production" \
    --function-version "$VERSION" \
    --region "$REGION"

# 7. Test the function
echo "${YELLOW}🧪 Testing Lambda function...${NC}"
aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload '{"httpMethod":"GET","path":"/health"}' \
    --region "$REGION" \
    dist/lambda-test-response.json

TEST_RESPONSE=$(cat dist/lambda-test-response.json)
if echo "$TEST_RESPONSE" | grep -q '"statusCode":200'; then
    echo "${GREEN}✅ Lambda deployed and tested successfully!${NC}"
else
    echo "${RED}❌ Lambda test failed${NC}"
    echo "Response: $TEST_RESPONSE"
    exit 1
fi

# 8. Configure CloudWatch alarms
echo "${YELLOW}📊 Configuring CloudWatch alarms...${NC}"

aws cloudwatch put-metric-alarm \
    --alarm-name "${FUNCTION_NAME}-errors" \
    --alarm-description "Alarm when Lambda function errors exceed threshold" \
    --metric-name Errors \
    --namespace AWS/Lambda \
    --statistic Sum \
    --period 300 \
    --threshold 5 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 1 \
    --alarm-actions "${SNS_TOPIC_ARN}" \
    --dimensions Name=FunctionName,Value="$FUNCTION_NAME" \
    --region "$REGION" 2>/dev/null || true

echo "${GREEN}✅ Lambda deployment complete!${NC}"
echo "${YELLOW}📝 Function ARN: arn:aws:lambda:${REGION}:${AWS_ACCOUNT_ID}:function:${FUNCTION_NAME}${NC}"
echo "${YELLOW}📝 Function URL: https://${AWS_ACCOUNT_ID}.execute-api.${REGION}.amazonaws.com/prod${NC}"
```

#### Step 6: Cloudflare Worker Deployment Script

**File:** `packages/gateway/scripts/deploy-worker.sh`

```bash
#!/bin/bash

# Cloudflare Worker Deployment Script
# Deploys the service to Cloudflare Workers with optimal configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "${GREEN}🚀 Deploying to Cloudflare Workers...${NC}"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration
WORKER_NAME="${WORKER_NAME:-orchestrator-gateway}"
ENVIRONMENT="${ENVIRONMENT:-production}"
DEPLOYMENT_ENV="${DEPLOYMENT_ENV:-production}"

echo "${YELLOW}Configuration:${NC}"
echo "  Worker Name: $WORKER_NAME"
echo "  Environment: $ENVIRONMENT"

# 1. Build the worker bundle
echo "${YELLOW}📦 Building Worker bundle...${NC}"
npm run build:worker

# 2. Optimize the bundle
echo "${YELLOW}🔧 Optimizing bundle...${NC}"
node scripts/optimize-bundle.js

# 3. Create wrangler configuration
echo "${YELLOW}📝 Creating wrangler configuration...${NC}"

cat > wrangler.toml << EOF
name = "$WORKER_NAME"
main = "dist/worker.js"
compatibility_date = "2024-01-01"
minify = true
logpush = true

[vars]
NODE_ENV = "production"
LOG_LEVEL = "${LOG_LEVEL:-info}"
DATABASE_URL = "$DATABASE_URL"
REDIS_URL = "$REDIS_URL"
JWT_SECRET = "$JWT_SECRET"
SERVICE_NAME = "gateway"
SERVICE_VERSION = "${SERVICE_VERSION:-1.0.0}"

[[env.${DEPLOYMENT_ENV}.vars]]
NODE_ENV = "production"
LOG_LEVEL = "info"

# Edge caching
[[env.${DEPLOYMENT_ENV}.durable_objects.bindings]]
name = "CACHE"
class_name = "Cache"

# Secrets (would be set via wrangler secret)
# [secrets]
# DATABASE_URL
# REDIS_URL
# JWT_SECRET
EOF

# 4. Deploy the worker
echo "${YELLOW}🚀 Deploying worker...${NC}"

if command -v wrangler &> /dev/null; then
    # Deploy with environment
    wrangler deploy --env "$ENVIRONMENT" --env-var "NODE_ENV=production"
    
    # Set secrets (prompt for values)
    echo "${YELLOW}🔐 Setting secrets...${NC}"
    wrangler secret put DATABASE_URL --env "$ENVIRONMENT"
    wrangler secret put REDIS_URL --env "$ENVIRONMENT"
    wrangler secret put JWT_SECRET --env "$ENVIRONMENT"
else
    echo "${RED}❌ wrangler not found. Please install: npm install -g wrangler${NC}"
    exit 1
fi

# 5. Test the deployment
echo "${YELLOW}🧪 Testing Cloudflare Worker...${NC}"

# Get worker URL
WORKER_URL=$(wrangler whoami --json | jq -r '.result.workers[].url' | grep "$WORKER_NAME" || echo "https://${WORKER_NAME}.workers.dev")

# Test health endpoint
if curl -s -f "$WORKER_URL/health" > /dev/null; then
    echo "${GREEN}✅ Worker deployed and tested successfully!${NC}"
    echo "${YELLOW}📝 Worker URL: $WORKER_URL${NC}"
else
    echo "${RED}❌ Worker test failed${NC}"
    exit 1
fi

# 6. Create cache rule
echo "${YELLOW}📝 Creating cache rules...${NC}"

wrangler cache rules create \
    --env "$ENVIRONMENT" \
    --path "/health" \
    --ttl 60 2>/dev/null || true

wrangler cache rules create \
    --env "$ENVIRONMENT" \
    --path "/api/tasks*" \
    --ttl 300 2>/dev/null || true

echo "${GREEN}✅ Cloudflare Worker deployment complete!${NC}"
```

#### Step 7: Infrastructure as Code (Terraform)

**File:** `packages/gateway/infrastructure/terraform/main.tf`

```hcl
# Infrastructure as Code with Terraform
# Defines all cloud infrastructure for the gateway service

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# ============================================
# VPC & Networking
# ============================================

# VPC for the application
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================
# Lambda Function
# ============================================

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role"
    Environment = var.environment
  }
}

# IAM Policy for Lambda
resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "gateway" {
  filename         = "${path.module}/../../dist/lambda.zip"
  function_name    = "${var.project_name}-${var.environment}"
  role            = aws_iam_role.lambda.arn
  handler         = "lambda.handler"
  runtime         = "nodejs18.x"
  memory_size     = 512
  timeout         = 30
  publish         = true

  environment {
    variables = {
      NODE_ENV        = var.environment
      LOG_LEVEL       = "info"
      DATABASE_URL    = var.database_url
      REDIS_URL       = var.redis_url
      JWT_SECRET      = var.jwt_secret
      SERVICE_NAME    = var.project_name
      SERVICE_VERSION = var.service_version
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.public[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name        = "${var.project_name}-lambda"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda
  ]
}

# Lambda Security Group
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-lambda-sg"
    Environment = var.environment
  }
}

# ============================================
# API Gateway
# ============================================

# API Gateway
resource "aws_apigatewayv2_api" "gateway" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.gateway.invoke_arn
}

# API Gateway Route
resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      ip                      = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      protocol                = "$context.protocol"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Name        = "${var.project_name}-api-stage"
    Environment = var.environment
  }
}

# API Gateway CloudWatch Logs
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api_gateway/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-api-logs"
    Environment = var.environment
  }
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gateway.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*"
}

# ============================================
# CloudFront Distribution (Optional)
# ============================================

# CloudFront Distribution for edge caching
resource "aws_cloudfront_distribution" "gateway" {
  enabled = true

  origin {
    domain_name = aws_apigatewayv2_api.gateway.api_endpoint
    origin_id   = "api-gateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "api-gateway"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-cf"
    Environment = var.environment
  }
}

# ============================================
# CloudWatch Alarms
# ============================================

# Lambda Error Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda function errors exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.gateway.function_name
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

# Lambda Duration Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 25000 // 25 seconds
  alarm_description   = "Lambda function duration exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.gateway.function_name
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}
```

### 4. The Verification

#### Step 1: Local Testing

Test Lambda locally:

```bash
# Install dependencies
cd packages/gateway
npm install

# Build the Lambda bundle
npm run build:lambda

# Test locally using a Lambda emulator
npx lambda-local -l dist/lambda.js -h handler -e '{"httpMethod":"GET","path":"/health"}'
```

Expected output:
```json
{
  "statusCode": 200,
  "headers": {
    "content-type": "application/json",
    "x-request-id": "..."
  },
  "body": "{\"status\":\"ok\",\"service\":\"gateway\",...}"
}
```

#### Step 2: Deploy to AWS Lambda

```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_REGION=us-east-1

# Deploy
./scripts/deploy-lambda.sh
```

#### Step 3: Deploy to Cloudflare Workers

```bash
# Install wrangler
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Deploy
./scripts/deploy-worker.sh
```

#### Step 4: Test Production Deployment

After deployment, test the production endpoints:

```bash
# Lambda API
curl https://your-api-id.execute-api.region.amazonaws.com/prod/health

# Cloudflare Worker
curl https://your-worker.workers.dev/health

# CloudFront (if configured)
curl https://your-distribution.cloudfront.net/health
```

#### Step 5: Cold Start Performance Test

Test cold start performance:

```bash
# Test Lambda cold start
echo "Testing Lambda cold start..."
time curl -s -o /dev/null https://your-api-id.execute-api.region.amazonaws.com/prod/health

# Warm up the function
curl -s https://your-api-id.execute-api.region.amazonaws.com/prod/health

# Test warm start
time curl -s -o /dev/null https://your-api-id.execute-api.region.amazonaws.com/prod/health
```

#### Step 6: Monitor Performance

Check CloudWatch metrics:

```bash
# Get Lambda metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Duration \
    --dimensions Name=FunctionName,Value=orchestrator-gateway \
    --start-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)" \
    --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --period 60 \
    --statistics Average p95
```

### 5. Deep Dive: Cloud-Native Optimization

#### Cold Start Optimization Strategies

**1. Keep It Small:**
```typescript
// ❌ BAD: Large imports
import * as allUtils from './utils/all';

// ✅ GOOD: Import only what you need
import { specificUtil } from './utils/specific';
```

**2. Lazy Loading:**
```typescript
// ❌ BAD: Initialize everything at startup
const db = new Database();
const cache = new Cache();

// ✅ GOOD: Initialize only when needed
let db: Database | null = null;
const getDb = () => db || (db = new Database());
```

**3. Connection Reuse:**
```typescript
// ❌ BAD: Create new connection per request
function handler(event) {
  const db = new Database();
  return db.query();
}

// ✅ GOOD: Reuse connections across requests
const db = new Database();
function handler(event) {
  return db.query();
}
```

#### V8 Isolate Memory Management

**Memory Limit: 128MB (Cloudflare Workers)**

Best practices for memory management:
1. Use `Buffer.alloc` instead of `new Buffer`
2. Avoid large objects in global scope
3. Use `WeakMap` for caching
4. Clean up event listeners
5. Limit closure sizes

```typescript
// ❌ BAD: Large global object
const globalCache = new Map();

// ✅ GOOD: Use WeakMap for automatic cleanup
const weakCache = new WeakMap();

// ✅ GOOD: Implement LRU cache
class LRUCache {
  constructor(private maxSize: number) {}
  // ...
}
```

#### Edge Computing Benefits

**Advantages of Edge Computing:**
1. **Reduced Latency:** Requests handled at nearest edge location
2. **Global Distribution:** Deploy to hundreds of locations worldwide
3. **DDoS Protection:** Cloudflare's network absorbs attacks
4. **Cost Efficiency:** Pay only for requests, not servers

**Edge-Friendly Patterns:**
```typescript
// Cache static responses at the edge
const cacheControl = {
  'Cache-Control': 'public, max-age=3600',
};

// Use Edge caching for API responses
if (request.method === 'GET') {
  // Cache GET responses
  const cached = await cache.get(request.url);
  if (cached) return new Response(cached, cacheControl);
}

// Geo-aware routing
const location = request.cf?.country;
if (location === 'US') {
  // US-specific logic
}
```

### 6. Summary

**What We Built:**
- ✅ AWS Lambda entry point with optimization
- ✅ Cloudflare Worker entry point
- ✅ Bundle optimization for cold starts
- ✅ Deployment scripts for both platforms
- ✅ Infrastructure as Code with Terraform
- ✅ Monitoring and observability setup

**Key Concepts Learned:**
- Serverless architecture patterns
- Cold start optimization strategies
- V8 isolate memory management
- Edge computing benefits
- Infrastructure as Code
- Deployment automation

**What's Next:**
In Part 2 of Phase 4, we'll implement edge-friendly caching strategies, CDN integration, and build out the full production deployment pipeline with CI/CD.

**Verification Checklist:**
- [ ] Lambda function deploys successfully
- [ ] Worker function deploys successfully
- [ ] Health check works on both platforms
- [ ] Cold start performance is acceptable
- [ ] Bundle size is optimized
- [ ] Terraform configuration is valid
- [ ] CloudWatch alarms are configured

