# Primer 20: Understanding System Architecture & Design Patterns

## A Comprehensive Guide to Architectural Decision-Making

Welcome to the twentieth and final primer! This is a comprehensive deep dive into system architecture and design patterns - the culmination of everything we've learned. Think of this like being the master architect for a city - you need to understand all the building blocks, how they fit together, and make decisions that will serve the city for decades to come.

### 1. The Big Picture

#### Architectural Decision Framework

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURAL DECISION FRAMEWORK                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    BUSINESS REQUIREMENTS                             │   │
│  │  • Scalability • Performance • Reliability • Security • Cost        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    ARCHITECTURAL STYLES                             │   │
│  │  • Monolithic • Microservices • Event-Driven • Serverless           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DESIGN PATTERNS                                  │   │
│  │  • Creational • Structural • Behavioral • Architectural             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    IMPLEMENTATION                                    │   │
│  │  • Technology Stack • Deployment • Monitoring • Evolution           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Architectural Styles Comparison

#### Monolithic Architecture

```typescript
// Monolithic Application Structure
class MonolithicApplication {
    // All components in one codebase
    private userModule: UserModule;
    private taskModule: TaskModule;
    private authModule: AuthModule;
    private analyticsModule: AnalyticsModule;
    private database: DatabaseConnection;

    constructor() {
        // All modules share the same database
        this.database = new DatabaseConnection();
        this.userModule = new UserModule(this.database);
        this.taskModule = new TaskModule(this.database);
        this.authModule = new AuthModule(this.database);
        this.analyticsModule = new AnalyticsModule(this.database);
    }

    // Single deployment unit
    start() {
        this.database.connect();
        this.userModule.initialize();
        this.taskModule.initialize();
        this.authModule.initialize();
        this.analyticsModule.initialize();
        console.log('Monolith started');
    }
}

// Pros: Simple, easy to develop, easy to deploy
// Cons: Scaling challenges, technology lock-in, slow to build
```

#### Microservices Architecture

```typescript
// Microservices Structure
interface Service {
    name: string;
    port: number;
    dependencies: string[];
}

class MicroservicesOrchestrator {
    private services: Map<string, ServiceInstance> = new Map();
    private serviceRegistry: ServiceRegistry;

    constructor() {
        this.serviceRegistry = new ServiceRegistry();
    }

    async deployService(service: Service): Promise<void> {
        // Each service has its own database
        const db = new DatabaseService({
            database: `${service.name}_db`,
        });

        // Deploy service independently
        const instance = new ServiceInstance(service, db);
        await instance.start();

        // Register with service registry
        this.serviceRegistry.register({
            name: service.name,
            host: 'localhost',
            port: service.port,
            healthy: true,
        });

        this.services.set(service.name, instance);
    }

    async callService(serviceName: string, payload: any): Promise<any> {
        // Service discovery
        const instance = this.serviceRegistry.getInstance(serviceName);
        if (!instance) {
            throw new Error(`Service ${serviceName} not available`);
        }

        // Make request to service
        const response = await fetch(`http://${instance.host}:${instance.port}`, {
            method: 'POST',
            body: JSON.stringify(payload),
        });

        return response.json();
    }
}

// Pros: Independent scaling, technology diversity, team autonomy
// Cons: Distributed complexity, network latency, data consistency
```

#### Event-Driven Architecture

```typescript
// Event-Driven Structure
class EventDrivenSystem {
    private eventBus: EventBus;
    private eventStore: EventStore;
    private subscribers: Map<string, EventHandler[]> = new Map();

    constructor() {
        this.eventBus = new EventBus();
        this.eventStore = new EventStore();
    }

    // Publish event to entire system
    async publishEvent(event: DomainEvent): Promise<void> {
        // Store event
        await this.eventStore.append(event);

        // Publish to all subscribers
        const handlers = this.subscribers.get(event.type) || [];
        for (const handler of handlers) {
            await handler.handle(event);
        }
    }

    // Subscribe to events
    subscribe(eventType: string, handler: EventHandler): void {
        if (!this.subscribers.has(eventType)) {
            this.subscribers.set(eventType, []);
        }
        this.subscribers.get(eventType)!.push(handler);
    }

    // Replay events to rebuild state
    async replayEvents(aggregateId: string): Promise<Aggregate> {
        const events = await this.eventStore.getEvents(aggregateId);
        const aggregate = new Aggregate(aggregateId);
        
        for (const event of events) {
            aggregate.applyEvent(event);
        }
        
        return aggregate;
    }
}

// Pros: Loose coupling, scalability, audit trail
// Cons: Eventual consistency, complexity, debugging challenges
```

### 3. Key Architectural Patterns

#### Circuit Breaker Pattern

```typescript
class CircuitBreakerPattern {
    private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
    private failureCount = 0;
    private lastFailureTime = 0;
    private readonly failureThreshold = 5;
    private readonly resetTimeout = 60000;

    async execute<T>(
        operation: () => Promise<T>,
        fallback?: () => Promise<T>
    ): Promise<T> {
        // Check state
        if (this.state === 'OPEN') {
            if (Date.now() - this.lastFailureTime > this.resetTimeout) {
                this.state = 'HALF_OPEN';
            } else {
                if (fallback) {
                    return await fallback();
                }
                throw new Error('Circuit breaker open');
            }
        }

        try {
            const result = await operation();
            this.onSuccess();
            return result;
        } catch (error) {
            this.onFailure();
            if (fallback) {
                return await fallback();
            }
            throw error;
        }
    }

    private onSuccess(): void {
        if (this.state === 'HALF_OPEN') {
            this.state = 'CLOSED';
            this.failureCount = 0;
        }
        this.failureCount = Math.max(0, this.failureCount - 1);
    }

    private onFailure(): void {
        this.failureCount++;
        this.lastFailureTime = Date.now();

        if (this.state === 'HALF_OPEN') {
            this.state = 'OPEN';
            return;
        }

        if (this.failureCount >= this.failureThreshold) {
            this.state = 'OPEN';
        }
    }
}
```

#### Saga Pattern

```typescript
class SagaOrchestrator {
    private steps: SagaStep[] = [];
    private compensationIndex: number = -1;

    addStep(step: SagaStep): void {
        this.steps.push(step);
    }

    async execute(context: SagaContext): Promise<void> {
        for (let i = 0; i < this.steps.length; i++) {
            const step = this.steps[i];
            try {
                await step.execute(context);
                this.compensationIndex = i;
            } catch (error) {
                // Compensate previous steps
                for (let j = this.compensationIndex; j >= 0; j--) {
                    await this.steps[j].compensate(context);
                }
                throw error;
            }
        }
    }
}

// Example Saga
class OrderSaga {
    static create(): SagaOrchestrator {
        const saga = new SagaOrchestrator();

        // Step 1: Reserve inventory
        saga.addStep({
            execute: async (ctx) => {
                ctx.inventoryReserved = await inventoryService.reserve(ctx.items);
            },
            compensate: async (ctx) => {
                await inventoryService.release(ctx.inventoryReserved);
            },
        });

        // Step 2: Process payment
        saga.addStep({
            execute: async (ctx) => {
                ctx.paymentId = await paymentService.charge(ctx.amount);
            },
            compensate: async (ctx) => {
                await paymentService.refund(ctx.paymentId);
            },
        });

        // Step 3: Create order
        saga.addStep({
            execute: async (ctx) => {
                ctx.orderId = await orderService.create(ctx);
            },
            compensate: async (ctx) => {
                await orderService.cancel(ctx.orderId);
            },
        });

        return saga;
    }
}
```

#### Strangler Fig Pattern

```typescript
// Strangler Fig Pattern - Incrementally replace legacy system
class StranglerFigApplication {
    private legacy: LegacySystem;
    private newServices: Map<string, Service> = new Map();
    private router: APIGateway;

    constructor() {
        this.legacy = new LegacySystem();
        this.router = new APIGateway();
        this.setupRouting();
    }

    private setupRouting(): void {
        // Route requests based on feature availability
        this.router.addRoute('/users', {
            // New service first, fallback to legacy
            handler: async (request) => {
                try {
                    return await this.newServices.get('user')?.getUser(request);
                } catch (error) {
                    return await this.legacy.handleRequest(request);
                }
            },
        });

        this.router.addRoute('/tasks', {
            // New service only (fully migrated)
            handler: async (request) => {
                return await this.newServices.get('task')?.getTask(request);
            },
        });

        this.router.addRoute('/legacy', {
            // Legacy only (not yet migrated)
            handler: async (request) => {
                return await this.legacy.handleRequest(request);
            },
        });
    }

    // Gradually add new services
    addService(name: string, service: Service): void {
        this.newServices.set(name, service);
        console.log(`Service ${name} added - ${this.newServices.size}/${3} migrated`);
    }
}
```

### 4. System Quality Attributes

#### Performance & Scalability

```typescript
class PerformanceRequirements {
    // Define SLOs (Service Level Objectives)
    readonly slos = {
        latency: {
            p95: 100, // ms
            p99: 200, // ms
        },
        throughput: {
            requestsPerSecond: 1000,
            concurrentUsers: 10000,
        },
        availability: {
            uptime: 99.99, // percentage
        },
    };

    // Scalability strategies
    async scaleStrategy(): Promise<void> {
        // Vertical scaling: Add more resources
        if (this.isCPUExhausted()) {
            this.scaleUpCPU();
        }

        // Horizontal scaling: Add more instances
        if (this.isMemoryExhausted()) {
            this.scaleOutInstances();
        }

        // Database scaling
        if (this.isDatabaseExhausted()) {
            this.shardDatabase();
        }

        // Cache scaling
        if (this.isCacheExhausted()) {
            this.addCacheNodes();
        }
    }
}
```

#### Reliability & Resilience

```typescript
class ReliabilityRequirements {
    // Resilience patterns
    private circuitBreaker: CircuitBreakerPattern;
    private retryPolicy: RetryPolicy;
    private bulkhead: BulkheadPattern;

    constructor() {
        this.circuitBreaker = new CircuitBreakerPattern();
        this.retryPolicy = new RetryPolicy({
            maxAttempts: 3,
            initialDelay: 1000,
            maxDelay: 30000,
        });
        this.bulkhead = new BulkheadPattern(10);
    }

    async handleRequest(request: any): Promise<any> {
        // Apply resilience patterns
        return this.bulkhead.execute(async () => {
            return this.circuitBreaker.execute(async () => {
                return this.retryPolicy.execute(async () => {
                    return await this.processRequest(request);
                });
            });
        });
    }

    // Disaster recovery
    async disasterRecovery(): Promise<void> {
        // 1. Detect disaster
        await this.detectDisaster();

        // 2. Activate backup
        await this.activateBackup();

        // 3. Verify recovery
        await this.verifyRecovery();

        // 4. Log incident
        await this.logIncident();
    }
}
```

#### Security & Compliance

```typescript
class SecurityRequirements {
    // Security layers
    private authentication: AuthenticationService;
    private authorization: AuthorizationService;
    private encryption: EncryptionService;
    private audit: AuditService;

    // Compliance requirements
    private compliance: {
        gdpr: boolean;
        hipaa: boolean;
        soc2: boolean;
        pci: boolean;
    };

    async securityCheck(request: any): Promise<boolean> {
        // 1. Authenticate
        const user = await this.authentication.authenticate(request);
        if (!user) {
            throw new Error('Authentication failed');
        }

        // 2. Authorize
        const authorized = await this.authorization.authorize(user, request);
        if (!authorized) {
            throw new Error('Authorization failed');
        }

        // 3. Encrypt sensitive data
        if (this.containsSensitiveData(request)) {
            request.data = this.encryption.encrypt(request.data);
        }

        // 4. Audit
        await this.audit.log({
            userId: user.id,
            action: request.action,
            timestamp: new Date(),
        });

        return true;
    }
}
```

### 5. Architectural Decision Records

```typescript
// ADR (Architecture Decision Record) Template
interface ArchitecturalDecision {
    id: string;
    title: string;
    status: 'PROPOSED' | 'ACCEPTED' | 'SUPERSEDED' | 'DEPRECATED';
    context: string;
    decision: string;
    consequences: {
        positive: string[];
        negative: string[];
        neutral: string[];
    };
    alternatives: Array<{
        description: string;
        pros: string[];
        cons: string[];
    }>;
    date: Date;
    author: string;
}

class ADRManager {
    private decisions: ArchitecturalDecision[] = [];

    // Example ADR
    static createDatabaseSelectionADR(): ArchitecturalDecision {
        return {
            id: 'ADR-001',
            title: 'Database Selection',
            status: 'ACCEPTED',
            context: 'We need to choose a database for our microservices architecture',
            decision: 'Use PostgreSQL for transactional data and Elasticsearch for search',
            consequences: {
                positive: [
                    'ACID compliance',
                    'Mature ecosystem',
                    'Strong community support',
                ],
                negative: [
                    'Need to manage replication',
                    'Complex sharding',
                ],
                neutral: [
                    'Will use ORM for development',
                ],
            },
            alternatives: [
                {
                    description: 'Use MongoDB',
                    pros: ['Schema flexibility', 'Easy scaling'],
                    cons: ['Eventual consistency', 'Complex transactions'],
                },
            ],
            date: new Date('2024-01-01'),
            author: 'Architecture Team',
        };
    }

    addDecision(decision: ArchitecturalDecision): void {
        this.decisions.push(decision);
    }

    getDecision(id: string): ArchitecturalDecision | undefined {
        return this.decisions.find(d => d.id === id);
    }

    getAllDecisions(): ArchitecturalDecision[] {
        return this.decisions;
    }
}
```

### 6. Technology Stack Selection

```typescript
class TechnologySelector {
    // Decision matrix for technology selection
    evaluateTechnology(options: TechnologyOption[]): TechnologyOption {
        const weights = {
            performance: 0.25,
            scalability: 0.20,
            maintainability: 0.15,
            cost: 0.15,
            community: 0.10,
            learningCurve: 0.10,
            ecosystem: 0.05,
        };

        let bestOption: TechnologyOption | null = null;
        let bestScore = -Infinity;

        for (const option of options) {
            let score = 0;
            for (const [criteria, weight] of Object.entries(weights)) {
                score += (option.scores[criteria] || 0) * weight;
            }
            if (score > bestScore) {
                bestScore = score;
                bestOption = option;
            }
        }

        return bestOption!;
    }

    // Example technology evaluation
    static evaluateDatabaseOptions(): TechnologyOption[] {
        return [
            {
                name: 'PostgreSQL',
                scores: {
                    performance: 8,
                    scalability: 7,
                    maintainability: 9,
                    cost: 9,
                    community: 10,
                    learningCurve: 7,
                    ecosystem: 9,
                },
            },
            {
                name: 'MongoDB',
                scores: {
                    performance: 9,
                    scalability: 9,
                    maintainability: 7,
                    cost: 8,
                    community: 9,
                    learningCurve: 6,
                    ecosystem: 8,
                },
            },
            {
                name: 'DynamoDB',
                scores: {
                    performance: 10,
                    scalability: 10,
                    maintainability: 7,
                    cost: 6,
                    community: 8,
                    learningCurve: 5,
                    ecosystem: 7,
                },
            },
        ];
    }
}

interface TechnologyOption {
    name: string;
    scores: {
        performance: number;
        scalability: number;
        maintainability: number;
        cost: number;
        community: number;
        learningCurve: number;
        ecosystem: number;
    };
}
```

### 7. Evolution & Migration

```typescript
class SystemEvolution {
    private currentState: SystemState;
    private targetState: SystemState;

    // Migration strategy
    async migrateToTargetState(): Promise<void> {
        // Phase 1: Analysis
        await this.analyzeCurrentState();

        // Phase 2: Plan migration
        const migrationPlan = this.createMigrationPlan();

        // Phase 3: Execute migration
        for (const phase of migrationPlan.phases) {
            await this.executePhase(phase);
            await this.verifyPhase(phase);
        }

        // Phase 4: Decommission legacy
        await this.decommissionLegacy();
    }

    private createMigrationPlan(): MigrationPlan {
        return {
            phases: [
                {
                    name: 'Phase 1: New Service Addition',
                    actions: ['Add new service', 'Route 10% traffic'],
                    expectedDuration: '1 week',
                },
                {
                    name: 'Phase 2: Gradual Migration',
                    actions: ['Migrate data', 'Increase traffic to 50%'],
                    expectedDuration: '2 weeks',
                },
                {
                    name: 'Phase 3: Complete Migration',
                    actions: ['Route 100% traffic', 'Decommission legacy'],
                    expectedDuration: '1 week',
                },
            ],
            rollbackStrategy: 'Blue-Green deployment',
            validation: 'Integration tests and monitoring',
        };
    }
}
```

### 8. Key Takeaways

1. **Architecture is About Trade-offs:**
   - No perfect solution
   - Balance competing requirements
   - Document decisions

2. **Start Simple, Evolve:**
   - Monolith first
   - Extract services as needed
   - Use strangler fig pattern

3. **Patterns are Solutions:**
   - Learn patterns
   - Apply appropriately
   - Avoid over-engineering

4. **Quality Attributes Matter:**
   - Performance
   - Scalability
   - Reliability
   - Security

5. **Communication is Key:**
   - Document decisions
   - Share with team
   - Explain trade-offs

6. **Technology is Tool:**
   - Choose based on requirements
   - Consider team skills
   - Evaluate ecosystem

7. **Continuous Improvement:**
   - Review architecture
   - Evolve with requirements
   - Learn from feedback

---

This primer provides an understanding of system architecture and design patterns. Architecture is the foundation of successful software systems - understanding these principles and patterns will help you make better decisions and build more robust, scalable, and maintainable systems.

