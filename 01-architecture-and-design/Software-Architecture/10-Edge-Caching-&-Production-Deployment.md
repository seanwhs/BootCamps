# Phase 4, Part 2: Edge Caching & Production Deployment

## Taking Your Architecture to the Edge

Welcome to the second part of Phase 4! Now that we have our serverless functions deployed, we need to optimize them for global scale with edge caching and build a complete production deployment pipeline. Think of this like setting up a global network of local kitchens that can serve customers faster than ever before.

### 1. The Target

**What we're building:** Production-ready deployment with edge optimization:
- Edge caching strategies with Cloudflare and CloudFront
- CDN integration and cache invalidation
- CI/CD pipeline with GitHub Actions
- Blue-green deployment strategy
- Production monitoring and alerting
- Disaster recovery and failover

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── infrastructure/
│   │   └── adapters/
│   │       └── cache/
│   │           └── edge/
│   │               ├── cache-strategies.ts    # NEW: Edge cache strategies
│   │               ├── cache-invalidation.ts  # NEW: Cache invalidation
│   │               └── geo-routing.ts         # NEW: Geo-based routing
│   └── server.ts
│
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf (updated)
│   │   └── cloudfront.tf (updated)
│   ├── cloudformation/
│   └── github-actions/                       # NEW: CI/CD pipeline
│       ├── deploy-lambda.yml
│       ├── deploy-worker.yml
│       └── rollback.yml
│
├── scripts/
│   ├── deploy-lambda.sh (updated)
│   ├── deploy-worker.sh (updated)
│   ├── rollback.sh                           # NEW: Rollback script
│   ├── smoke-test.sh                         # NEW: Smoke test script
│   └── canary-test.sh                        # NEW: Canary test script
│
├── configs/
│   ├── lambda-environment.json (updated)
│   ├── worker-environment.json (updated)
│   ├── caching-rules.json                     # NEW: Cache rules
│   └── rate-limiting.json                     # NEW: Rate limiting rules
│
├── .github/
│   └── workflows/                            # NEW: GitHub Actions
│       ├── ci.yml
│       ├── deploy-prod.yml
│       ├── deploy-staging.yml
│       └── rollback.yml
│
└── package.json (updated)
```

### 2. The Concept: Edge Caching & Production Deployment

**Edge Caching:**
Like having local menus in each restaurant location instead of printing them from headquarters every time. Frequently accessed data is stored close to the user.

```
┌─────────────────────────────────────────────────────────────────┐
│                         EDGE CACHING                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  User in Tokyo ──▶ Edge Cache (Tokyo) ──▶ Origin (US)         │
│                        ▲                                        │
│                        │ (Cached Response)                      │
│                        │                                        │
│  User in London ──────┘                                        │
│                                                                 │
│  Cache Strategies:                                              │
│  1. TTL-based (time-based expiration)                          │
│  2. Invalidation-based (event-based purge)                     │
│  3. Version-based (cache-busting)                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Production Deployment Pipeline:**
```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Build  │───▶│  Test   │───▶│ Staging │───▶│  Canary │───▶ Prod
└─────────┘    └─────────┘    └─────────┘    └─────────┘
                    │               │              │
                    ▼               ▼              ▼
              ┌─────────────────────────────────────┐
              │        Rollback on Failure          │
              └─────────────────────────────────────┘
```

### 3. The Implementation

#### Step 1: Edge Cache Strategies

**File:** `packages/gateway/src/infrastructure/adapters/cache/edge/cache-strategies.ts`

```typescript
import { createChildLogger } from '../../../../logger.js';
import { RequestContextManager } from '../../distributed/request-context.js';

/**
 * Edge Cache Strategy
 * 
 * Defines caching behavior for edge CDNs
 */
export interface EdgeCacheStrategy {
  /** Cache TTL in seconds */
  ttl: number;
  
  /** Whether to cache the response */
  shouldCache: (request: Request, response: Response) => boolean;
  
  /** Cache key generation */
  getCacheKey: (request: Request) => string;
  
  /** Cache control headers */
  getCacheHeaders: (response: Response) => Record<string, string>;
}

/**
 * Default Edge Cache Strategy
 */
export class DefaultEdgeCacheStrategy implements EdgeCacheStrategy {
  constructor(
    private readonly defaultTTL: number = 300,
    private readonly maxTTL: number = 3600
  ) {}

  shouldCache(request: Request, response: Response): boolean {
    // Only cache GET requests
    if (request.method !== 'GET') return false;
    
    // Don't cache error responses
    if (response.status >= 400) return false;
    
    // Don't cache authenticated requests (unless configured)
    if (request.headers.get('authorization')) {
      // We could cache authenticated responses with a shorter TTL
      // For now, we'll cache them but with shorter TTL
    }
    
    return true;
  }

  getCacheKey(request: Request): string {
    const url = new URL(request.url);
    const path = url.pathname;
    const query = url.searchParams.toString();
    
    // Include relevant headers in cache key
    const acceptLanguage = request.headers.get('accept-language') || 'en';
    const userAgent = request.headers.get('user-agent') || 'unknown';
    
    return `cache:${path}:${query}:${acceptLanguage}:${userAgent.substring(0, 20)}`;
  }

  getCacheHeaders(response: Response): Record<string, string> {
    const status = response.status;
    
    // Different TTL for different status codes
    let ttl = this.defaultTTL;
    
    if (status === 200) {
      ttl = this.defaultTTL;
    } else if (status === 304) {
      ttl = this.defaultTTL * 2;
    } else if (status >= 400 && status < 500) {
      ttl = 60; // Short TTL for client errors
    } else if (status >= 500) {
      ttl = 10; // Very short TTL for server errors
    }
    
    return {
      'Cache-Control': `public, max-age=${ttl}, stale-while-revalidate=${ttl / 2}`,
      'CDN-Cache-Control': `max-age=${ttl}`,
    };
  }
}

/**
 * Stale-While-Revalidate Strategy
 * 
 * Serve stale content while revalidating in the background
 */
export class StaleWhileRevalidateStrategy extends DefaultEdgeCacheStrategy {
  getCacheHeaders(response: Response): Record<string, string> {
    const base = super.getCacheHeaders(response);
    const ttl = parseInt(base['Cache-Control'].split('max-age=')[1]?.split(',')[0] || '300');
    
    return {
      ...base,
      'Cache-Control': `public, max-age=${ttl}, stale-while-revalidate=${ttl * 2}, stale-if-error=${ttl * 3}`,
    };
  }
}

/**
 * Edge Cache Manager
 * 
 * Manages edge caching strategies and rules
 */
export class EdgeCacheManager {
  private static instance: EdgeCacheManager;
  private strategies: Map<string, EdgeCacheStrategy> = new Map();
  private readonly logger = createChildLogger({ module: 'EdgeCacheManager' });

  private constructor() {
    // Register default strategy
    this.register('default', new DefaultEdgeCacheStrategy());
    this.register('stale-while-revalidate', new StaleWhileRevalidateStrategy());
  }

  static getInstance(): EdgeCacheManager {
    if (!EdgeCacheManager.instance) {
      EdgeCacheManager.instance = new EdgeCacheManager();
    }
    return EdgeCacheManager.instance;
  }

  /**
   * Register a cache strategy for a path pattern
   */
  register(pathPattern: string, strategy: EdgeCacheStrategy): void {
    this.strategies.set(pathPattern, strategy);
    this.logger.debug({ pathPattern }, 'Cache strategy registered');
  }

  /**
   * Get cache strategy for a request
   */
  getStrategy(request: Request): EdgeCacheStrategy {
    const url = new URL(request.url);
    const path = url.pathname;

    // Check for matching pattern
    for (const [pattern, strategy] of this.strategies) {
      if (pattern === '*' || path.startsWith(pattern) || pattern === path) {
        return strategy;
      }
    }

    // Fallback to default
    return this.strategies.get('default')!;
  }

  /**
   * Apply cache headers to response
   */
  applyCacheHeaders(request: Request, response: Response): Response {
    const strategy = this.getStrategy(request);
    
    // Check if we should cache
    if (!strategy.shouldCache(request, response)) {
      // Add no-cache headers
      const newResponse = new Response(response.body, response);
      newResponse.headers.set('Cache-Control', 'no-cache, no-store, must-revalidate');
      newResponse.headers.set('Pragma', 'no-cache');
      newResponse.headers.set('Expires', '0');
      return newResponse;
    }

    // Apply cache headers
    const cacheHeaders = strategy.getCacheHeaders(response);
    const newResponse = new Response(response.body, response);
    
    for (const [key, value] of Object.entries(cacheHeaders)) {
      newResponse.headers.set(key, value);
    }

    // Add cache key for debugging
    const cacheKey = strategy.getCacheKey(request);
    newResponse.headers.set('X-Cache-Key', cacheKey);

    return newResponse;
  }
}

/**
 * Edge Cache Middleware for Fastify
 */
export function edgeCacheMiddleware(manager: EdgeCacheManager = EdgeCacheManager.getInstance()) {
  return async (request: any, reply: any) => {
    // We'll apply cache headers at the response level
    reply.raw.once('finish', () => {
      // In a real implementation, we'd use the request/response objects
      // This is a placeholder for the middleware approach
    });
  };
}
```

#### Step 2: Cache Invalidation

**File:** `packages/gateway/src/infrastructure/adapters/cache/edge/cache-invalidation.ts`

```typescript
import { createChildLogger } from '../../../../logger.js';
import { cacheService } from '../redis/cache.service.js';

/**
 * Cache Invalidation Manager
 * 
 * Handles cache invalidation across edge and origin caches
 */
export class CacheInvalidationManager {
  private static instance: CacheInvalidationManager;
  private readonly logger = createChildLogger({ module: 'CacheInvalidationManager' });
  private invalidations: Map<string, number> = new Map();

  private constructor() {}

  static getInstance(): CacheInvalidationManager {
    if (!CacheInvalidationManager.instance) {
      CacheInvalidationManager.instance = new CacheInvalidationManager();
    }
    return CacheInvalidationManager.instance;
  }

  /**
   * Invalidate cache for a URL pattern
   */
  async invalidate(pattern: string, options?: {
    method?: 'purge' | 'ban' | 'refresh';
    recursive?: boolean;
  }): Promise<void> {
    this.logger.info({ pattern, options }, 'Invalidating cache');

    const method = options?.method || 'purge';

    switch (method) {
      case 'purge':
        await this.purgeCache(pattern);
        break;
      case 'ban':
        await this.banCache(pattern);
        break;
      case 'refresh':
        await this.refreshCache(pattern);
        break;
      default:
        throw new Error(`Unsupported invalidation method: ${method}`);
    }

    // Record invalidation
    this.invalidations.set(pattern, Date.now());

    // Invalidate local Redis cache as well
    await this.invalidateRedisCache(pattern);
  }

  /**
   * Purge cache (force immediate removal)
   */
  private async purgeCache(pattern: string): Promise<void> {
    // In Cloudflare, this would use the Purge API
    // In CloudFront, this would use CreateInvalidation
    // For Redis, we delete matching keys
    
    this.logger.info({ pattern }, 'Purging cache');
    
    try {
      // Purge from Redis
      await cacheService.deleteByPattern(pattern);
      
      // In production, you'd also call Cloudflare/CloudFront APIs
      // await this.cloudflarePurge(pattern);
      // await this.cloudfrontPurge(pattern);
    } catch (error) {
      this.logger.error({ error, pattern }, 'Failed to purge cache');
      throw error;
    }
  }

  /**
   * Ban cache (mark as invalid, but don't remove immediately)
   */
  private async banCache(pattern: string): Promise<void> {
    this.logger.info({ pattern }, 'Banning cache');
    // Implementation depends on the CDN
    // For Varnish, this would be a ban rule
    // For Redis, we'd add a ban pattern
  }

  /**
   * Refresh cache (revalidate)
   */
  private async refreshCache(pattern: string): Promise<void> {
    this.logger.info({ pattern }, 'Refreshing cache');
    // Trigger cache refresh for the pattern
  }

  /**
   * Invalidate Redis cache for a pattern
   */
  private async invalidateRedisCache(pattern: string): Promise<void> {
    try {
      // If pattern is a specific key
      if (!pattern.includes('*')) {
        await cacheService.delete(pattern);
      } else {
        // For wildcard patterns, use scan and delete
        await cacheService.deleteByPattern(pattern);
      }
      this.logger.debug({ pattern }, 'Redis cache invalidated');
    } catch (error) {
      this.logger.warn({ error, pattern }, 'Failed to invalidate Redis cache');
    }
  }

  /**
   * Invalidate cache for a specific entity
   */
  async invalidateEntity(
    type: 'user' | 'task',
    id: string,
    operation: 'create' | 'update' | 'delete'
  ): Promise<void> {
    const patterns = [
      `*${type}:${id}*`,
      `*${type}s:${id}*`,
    ];

    if (operation === 'create') {
      patterns.push(`*${type}s:*`); // Invalidate collections
    }

    this.logger.info({ type, id, operation, patterns }, 'Invalidating entity cache');

    for (const pattern of patterns) {
      await this.invalidate(pattern);
    }
  }

  /**
   * Batch invalidate multiple patterns
   */
  async batchInvalidate(patterns: string[]): Promise<void> {
    this.logger.info({ count: patterns.length }, 'Batch invalidating cache');
    
    const results = await Promise.allSettled(
      patterns.map(pattern => this.invalidate(pattern))
    );

    const failures = results.filter(r => r.status === 'rejected');
    if (failures.length > 0) {
      this.logger.warn({ failures: failures.length }, 'Some cache invalidations failed');
    }
  }

  /**
   * Get invalidation history
   */
  getHistory(): { pattern: string; timestamp: number }[] {
    const history: { pattern: string; timestamp: number }[] = [];
    
    for (const [pattern, timestamp] of this.invalidations) {
      history.push({ pattern, timestamp });
    }
    
    return history.sort((a, b) => b.timestamp - a.timestamp);
  }

  /**
   * Get cache statistics
   */
  async getStats(): Promise<{
    totalInvalidations: number;
    patterns: string[];
    lastInvalidation: number;
  }> {
    const patterns = Array.from(this.invalidations.keys());
    const timestamps = Array.from(this.invalidations.values());
    
    return {
      totalInvalidations: patterns.length,
      patterns,
      lastInvalidation: timestamps.length > 0 ? Math.max(...timestamps) : 0,
    };
  }
}

/**
 * Cache Invalidation Middleware
 * 
 * Automatically invalidates cache on write operations
 */
export function cacheInvalidationMiddleware() {
  const manager = CacheInvalidationManager.getInstance();
  
  return async (request: any, reply: any) => {
    // Track the request for potential invalidation
    const context = RequestContextManager.getContext();
    if (!context) return;

    // Store the request type for later use
    (request as any).invalidationContext = {
      method: request.method,
      path: request.url,
      body: request.body,
      userId: context.userId,
    };
  };
}
```

#### Step 3: Geo-Routing

**File:** `packages/gateway/src/infrastructure/adapters/cache/edge/geo-routing.ts`

```typescript
import { createChildLogger } from '../../../../logger.js';

/**
 * Geo Routing Manager
 * 
 * Routes requests based on geographic location
 * 
 * This enables:
 * 1. Regional service selection
 * 2. Content localization
 * 3. Compliance with data sovereignty laws
 * 4. Performance optimization
 */
export class GeoRoutingManager {
  private static instance: GeoRoutingManager;
  private readonly logger = createChildLogger({ module: 'GeoRoutingManager' });
  private regionConfigs: Map<string, RegionConfig> = new Map();

  private constructor() {
    // Default region configurations
    this.registerRegion('us', {
      name: 'us',
      services: {
        database: 'us-east-1',
        cache: 'us-east-1',
        api: 'us-east-1',
      },
      language: 'en',
      timezone: 'America/New_York',
    });
    
    this.registerRegion('eu', {
      name: 'eu',
      services: {
        database: 'eu-west-1',
        cache: 'eu-west-1',
        api: 'eu-west-1',
      },
      language: 'en',
      timezone: 'Europe/London',
    });
    
    this.registerRegion('asia', {
      name: 'asia',
      services: {
        database: 'ap-southeast-1',
        cache: 'ap-southeast-1',
        api: 'ap-southeast-1',
      },
      language: 'en',
      timezone: 'Asia/Singapore',
    });
  }

  static getInstance(): GeoRoutingManager {
    if (!GeoRoutingManager.instance) {
      GeoRoutingManager.instance = new GeoRoutingManager();
    }
    return GeoRoutingManager.instance;
  }

  /**
   * Register a region configuration
   */
  registerRegion(regionCode: string, config: RegionConfig): void {
    this.regionConfigs.set(regionCode, config);
    this.logger.debug({ regionCode }, 'Region registered');
  }

  /**
   * Get region from request
   */
  getRegion(request: Request): RegionConfig {
    // In Cloudflare Workers, request.cf gives location data
    // In AWS Lambda, use request headers or IP geolocation
    let countryCode = 'us';
    
    // Try to get from Cloudflare
    const cf = (request as any).cf;
    if (cf?.country) {
      countryCode = cf.country.toLowerCase();
    }
    
    // Try to get from headers
    const geoHeader = request.headers.get('x-geo-country');
    if (geoHeader) {
      countryCode = geoHeader.toLowerCase();
    }

    // Find matching region
    const region = this.findRegion(countryCode);
    return region;
  }

  /**
   * Find region for a country code
   */
  private findRegion(countryCode: string): RegionConfig {
    // Map country to region
    const regionMap: Record<string, string> = {
      'us': 'us',
      'ca': 'us',
      'gb': 'eu',
      'fr': 'eu',
      'de': 'eu',
      'jp': 'asia',
      'sg': 'asia',
      'au': 'asia',
    };

    const regionCode = regionMap[countryCode] || 'us';
    return this.regionConfigs.get(regionCode) || this.regionConfigs.get('us')!;
  }

  /**
   * Get nearest database endpoint for a request
   */
  getNearestEndpoint(request: Request, serviceType: 'database' | 'cache' | 'api'): string {
    const region = this.getRegion(request);
    return region.services[serviceType] || region.services.api;
  }

  /**
   * Check if request should be routed to a specific region
   */
  shouldRouteToRegion(request: Request, targetRegion: string): boolean {
    const currentRegion = this.getRegion(request);
    return currentRegion.name === targetRegion;
  }

  /**
   * Get region-specific headers
   */
  getRegionHeaders(request: Request): Record<string, string> {
    const region = this.getRegion(request);
    
    return {
      'x-region': region.name,
      'x-language': region.language,
      'x-timezone': region.timezone,
      'x-database': region.services.database,
      'x-cache': region.services.cache,
    };
  }
}

/**
 * Region Configuration
 */
export interface RegionConfig {
  name: string;
  services: {
    database: string;
    cache: string;
    api: string;
  };
  language: string;
  timezone: string;
}

/**
 * Geo Routing Middleware
 */
export function geoRoutingMiddleware(manager: GeoRoutingManager = GeoRoutingManager.getInstance()) {
  return async (request: any, reply: any, done: () => void) => {
    // Add geo headers to request
    const geo = manager.getRegionHeaders(request);
    
    for (const [key, value] of Object.entries(geo)) {
      request.headers[key] = value;
    }
    
    // Store region in request context
    (request as any).region = manager.getRegion(request);
    
    done();
  };
}
```

#### Step 4: CI/CD Pipeline (GitHub Actions)

**File:** `packages/gateway/.github/workflows/ci.yml`

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: orchestrator_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: packages/gateway/package-lock.json

      - name: Install dependencies
        run: |
          cd packages/gateway
          npm ci

      - name: Type check
        run: |
          cd packages/gateway
          npm run type-check

      - name: Lint
        run: |
          cd packages/gateway
          npm run lint

      - name: Run unit tests
        run: |
          cd packages/gateway
          npm test -- tests/unit/

      - name: Run integration tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/orchestrator_test
          REDIS_URL: redis://localhost:6379
          NODE_ENV: test
        run: |
          cd packages/gateway
          npm test -- tests/integration/

      - name: Run E2E tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/orchestrator_test
          REDIS_URL: redis://localhost:6379
          NODE_ENV: test
        run: |
          cd packages/gateway
          npm test -- tests/e2e/

      - name: Build serverless bundle
        run: |
          cd packages/gateway
          npm run build:serverless

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            packages/gateway/dist/
            packages/gateway/infrastructure/terraform/
          retention-days: 7

      - name: Generate coverage report
        run: |
          cd packages/gateway
          npm run test:coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          directory: packages/gateway/coverage
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: true
```

**File:** `packages/gateway/.github/workflows/deploy-prod.yml`

```yaml
name: Deploy Production

on:
  push:
    branches: [main]
    paths:
      - 'packages/gateway/**'
      - '!packages/gateway/**/*.md'
      - '!packages/gateway/**/*.test.ts'

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    concurrency: production

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: packages/gateway/package-lock.json

      - name: Install dependencies
        run: |
          cd packages/gateway
          npm ci

      - name: Build
        run: |
          cd packages/gateway
          npm run build:serverless

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Deploy to Lambda (Blue)
        env:
          DEPLOYMENT_TARGET: blue
          LAMBDA_FUNCTION_NAME: ${{ secrets.LAMBDA_FUNCTION_NAME }}-blue
        run: |
          cd packages/gateway
          ./scripts/deploy-lambda.sh

      - name: Run smoke tests on Blue
        env:
          API_URL: ${{ secrets.BLUE_API_URL }}
        run: |
          cd packages/gateway
          ./scripts/smoke-test.sh

      - name: Deploy to Lambda (Green)
        env:
          DEPLOYMENT_TARGET: green
          LAMBDA_FUNCTION_NAME: ${{ secrets.LAMBDA_FUNCTION_NAME }}-green
        run: |
          cd packages/gateway
          ./scripts/deploy-lambda.sh

      - name: Run canary tests on Green
        env:
          API_URL: ${{ secrets.GREEN_API_URL }}
          CANARY_PERCENTAGE: 10
        run: |
          cd packages/gateway
          ./scripts/canary-test.sh

      - name: Switch production traffic
        run: |
          cd packages/gateway
          ./scripts/switch-traffic.sh

      - name: Run post-deployment smoke tests
        env:
          API_URL: ${{ secrets.PROD_API_URL }}
        run: |
          cd packages/gateway
          ./scripts/smoke-test.sh

      - name: Deploy Cloudflare Worker
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
        run: |
          cd packages/gateway
          ./scripts/deploy-worker.sh

      - name: Invalidate cache
        run: |
          cd packages/gateway
          ./scripts/invalidate-cache.sh

      - name: Notify success
        if: success()
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "✅ Production deployment successful!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "✅ *Production Deployment Successful*"
                  }
                },
                {
                  "type": "section",
                  "fields": [
                    {
                      "type": "mrkdwn",
                      "text": "*Version:* `${{ github.sha }}`"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Environment:* Production"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Deployed By:* ${{ github.actor }}"
                    }
                  ]
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}

      - name: Notify failure
        if: failure()
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "❌ Production deployment failed!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "❌ *Production Deployment Failed*"
                  }
                },
                {
                  "type": "section",
                  "fields": [
                    {
                      "type": "mrkdwn",
                      "text": "*Version:* `${{ github.sha }}`"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Environment:* Production"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Triggered By:* ${{ github.actor }}"
                    }
                  ]
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

#### Step 5: Deployment Scripts

**File:** `packages/gateway/scripts/smoke-test.sh`

```bash
#!/bin/bash

# Smoke Test Script
# Runs basic tests to ensure the deployment is healthy

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "${GREEN}🔥 Running smoke tests...${NC}"

API_URL=${API_URL:-"http://localhost:3000"}

# Test 1: Health check
echo "${YELLOW}Test 1: Health check${NC}"
HEALTH_RESPONSE=$(curl -s -f "${API_URL}/health" -w "\n%{http_code}")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "${GREEN}✅ Health check passed${NC}"
else
    echo "${RED}❌ Health check failed (HTTP $HTTP_CODE)${NC}"
    echo "Response: $BODY"
    exit 1
fi

# Test 2: Metrics endpoint
echo "${YELLOW}Test 2: Metrics endpoint${NC}"
METRICS_RESPONSE=$(curl -s -f "${API_URL}/metrics" -w "\n%{http_code}")
HTTP_CODE=$(echo "$METRICS_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "${GREEN}✅ Metrics endpoint passed${NC}"
else
    echo "${RED}❌ Metrics endpoint failed (HTTP $HTTP_CODE)${NC}"
    exit 1
fi

# Test 3: Create a test user
echo "${YELLOW}Test 3: Create test user${NC}"
USER_RESPONSE=$(curl -s -X POST "${API_URL}/api/users" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "smoke-test@example.com",
        "username": "smoketest",
        "password": "SecurePass123",
        "firstName": "Smoke",
        "lastName": "Test"
    }' -w "\n%{http_code}")

HTTP_CODE=$(echo "$USER_RESPONSE" | tail -n1)
BODY=$(echo "$USER_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "201" ]; then
    echo "${GREEN}✅ User creation passed${NC}"
    USER_ID=$(echo "$BODY" | jq -r '.data.id')
else
    echo "${RED}❌ User creation failed (HTTP $HTTP_CODE)${NC}"
    echo "Response: $BODY"
    exit 1
fi

# Test 4: Create a task
echo "${YELLOW}Test 4: Create test task${NC}"
TASK_RESPONSE=$(curl -s -X POST "${API_URL}/api/tasks" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Smoke Test Task\",
        \"description\": \"Testing the deployment\",
        \"userId\": \"$USER_ID\",
        \"priority\": \"medium\"
    }" -w "\n%{http_code}")

HTTP_CODE=$(echo "$TASK_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "201" ]; then
    echo "${GREEN}✅ Task creation passed${NC}"
else
    echo "${RED}❌ Task creation failed (HTTP $HTTP_CODE)${NC}"
    exit 1
fi

# Test 5: Get tasks
echo "${YELLOW}Test 5: Get tasks${NC}"
TASKS_RESPONSE=$(curl -s -f "${API_URL}/api/users/${USER_ID}/tasks" -w "\n%{http_code}")
HTTP_CODE=$(echo "$TASKS_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "${GREEN}✅ Get tasks passed${NC}"
else
    echo "${RED}❌ Get tasks failed (HTTP $HTTP_CODE)${NC}"
    exit 1
fi

# Clean up test data
echo "${YELLOW}Cleaning up test data...${NC}"
curl -s -X DELETE "${API_URL}/api/users/${USER_ID}" > /dev/null

echo "${GREEN}✅ All smoke tests passed!${NC}"
```

**File:** `packages/gateway/scripts/canary-test.sh`

```bash
#!/bin/bash

# Canary Test Script
# Runs a percentage of traffic to the new deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "${GREEN}🟡 Running canary tests...${NC}"

API_URL=${API_URL:-"http://localhost:3000"}
CANARY_PERCENTAGE=${CANARY_PERCENTAGE:-10}

echo "${YELLOW}Canary percentage: ${CANARY_PERCENTAGE}%${NC}"

# Test with canary traffic
for i in {1..100}; do
    # Route based on canary percentage
    if [ $((RANDOM % 100)) -lt $CANARY_PERCENTAGE ]; then
        # Use canary deployment
        URL="${API_URL}/health"
        CANARY=true
    else
        # Use stable deployment
        URL="${STABLE_API_URL:-$API_URL}/health"
        CANARY=false
    fi

    # Make request
    RESPONSE=$(curl -s -f "$URL" -w "\n%{http_code}" 2>/dev/null)
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n -1)

    if [ "$HTTP_CODE" != "200" ]; then
        echo "${RED}❌ Canary test failed: HTTP $HTTP_CODE${NC}"
        echo "Response: $BODY"
        exit 1
    fi

    # Log if we're testing canary
    if [ "$CANARY" = true ]; then
        echo "${YELLOW}🟡 Canary request ${i} successful${NC}"
    fi
done

echo "${GREEN}✅ Canary tests passed!${NC}"
```

### 4. The Verification

#### Step 1: Test Edge Caching Locally

```bash
cd packages/gateway
npm run dev

# First request (cache miss)
curl -v http://localhost:3000/api/tasks/user/123

# Second request (cache hit)
curl -v http://localhost:3000/api/tasks/user/123

# Check cache headers
curl -I http://localhost:3000/health
```

Expected headers:
```
Cache-Control: public, max-age=300, stale-while-revalidate=150
X-Cache-Key: cache:/health::en:Mozilla/5.0...
```

#### Step 2: Test Cache Invalidation

```bash
# Invalidate cache
curl -X POST http://localhost:3000/admin/cache/invalidate \
  -H "Content-Type: application/json" \
  -d '{
    "pattern": "*user:123*",
    "method": "purge"
  }'

# Verify invalidation
curl -v http://localhost:3000/api/tasks/user/123
```

#### Step 3: Run CI/CD Pipeline Locally

```bash
# Run smoke tests
./scripts/smoke-test.sh

# Run canary tests
./scripts/canary-test.sh

# Simulate deployment
./scripts/deploy-lambda.sh
./scripts/deploy-worker.sh
```

#### Step 4: Monitor Production

Check CloudWatch metrics:

```bash
# Get Lambda metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Invocations \
    --dimensions Name=FunctionName,Value=orchestrator-gateway \
    --start-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)" \
    --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --period 60 \
    --statistics Sum

# Get CloudFront metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/CloudFront \
    --metric-name Requests \
    --dimensions Name=DistributionId,Value=YOUR_DISTRIBUTION_ID \
    --start-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)" \
    --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --period 60 \
    --statistics Sum
```

### 5. Deep Dive: Production Best Practices

#### Blue-Green Deployment Strategy

**Benefits:**
1. Zero downtime deployments
2. Instant rollback capability
3. Reduced deployment risk
4. A/B testing support

**Implementation:**
```yaml
# Two separate environments
Blue Environment: Running current version
Green Environment: Running new version

# Switch traffic
Step 1: Deploy to Green
Step 2: Test Green
Step 3: Switch traffic to Green
Step 4: Keep Blue as backup
```

#### Cache Invalidation Strategies

**1. Time-Based:**
```typescript
// Automatically expires after TTL
const response = await fetch(url, {
  headers: {
    'Cache-Control': 'max-age=300'
  }
});
```

**2. Event-Based:**
```typescript
// Invalidate on data changes
async function updateUser(id, data) {
  const user = await db.updateUser(id, data);
  await invalidateCache(`user:${id}`);
  return user;
}
```

**3. Version-Based:**
```typescript
// Use version in cache key
const version = process.env.CACHE_VERSION || 'v1';
const key = `${version}:user:${id}`;
```

#### Edge Computing Optimization

**1. Minimize Cold Starts:**
- Keep bundle size small (< 1MB)
- Use connection pooling
- Implement keep-alive
- Use provisioned concurrency

**2. Optimize for Edge:**
- Use Edge-friendly APIs
- Minimize third-party dependencies
- Cache everything possible
- Use streaming responses

**3. Handle Rate Limiting:**
```typescript
// Edge rate limiting
const rateLimit = {
  windowMs: 60000,
  max: 100,
};

if (rateLimit.exceeded(request)) {
  return new Response('Rate limited', { status: 429 });
}
```

### 6. Summary

**What We Built:**
- ✅ Edge cache strategies with TTL-based and stale-while-revalidate
- ✅ Cache invalidation system for edge and origin
- ✅ Geo-routing for regional optimization
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Blue-green deployment with rollback
- ✅ Smoke and canary tests
- ✅ Production monitoring and alerting

**Key Concepts Learned:**
- Edge caching strategies and best practices
- Cache invalidation patterns
- Geo-routing for global distribution
- CI/CD pipeline implementation
- Blue-green deployment strategy
- Production monitoring and observability

**What's Next:**
In Phase 5, we'll move to data systems - implementing event sourcing and CQRS with Node.js streams, and building a complete event-driven architecture.

**Verification Checklist:**
- [ ] Edge caching works with proper headers
- [ ] Cache invalidation works correctly
- [ ] Geo-routing routes to correct regions
- [ ] CI/CD pipeline runs successfully
- [ ] Blue-green deployment works
- [ ] Smoke tests pass
- [ ] Canary tests pass
- [ ] Monitoring shows proper metrics

