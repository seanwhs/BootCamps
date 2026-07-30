# Primer 3: Understanding Distributed Systems Patterns

## A Deep Dive into Distributed System Design

Welcome to the third primer! This is a comprehensive deep dive into distributed systems patterns - the fundamental concepts and patterns for building systems that span multiple services and servers. Think of this like learning how to coordinate multiple restaurants in a chain - each location works independently but must coordinate for the business to succeed.

### 1. The Big Picture

Distributed systems are about multiple computers working together to achieve a common goal. They're harder than single-node systems but offer benefits like scalability, fault tolerance, and geographical distribution.

#### Distributed System Characteristics

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DISTRIBUTED SYSTEM CHARACTERISTICS                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       SCALABILITY                                   │   │
│  │  • Horizontal scaling: Add more nodes                              │   │
│  │  • Vertical scaling: Add more power to existing nodes              │   │
│  │  • Elastic scaling: Scale up/down based on demand                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     FAULT TOLERANCE                                 │   │
│  │  • Redundancy: Multiple copies of services                         │   │
│  │  • Failover: Automatic recovery from failures                      │   │
│  │  • Replication: Data duplicated across nodes                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    CONCURRENCY                                      │   │
│  │  • Multiple requests simultaneously                                │   │
│  │  • Race conditions and consistency                                 │   │
│  │  • Distributed locking and coordination                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                  NETWORK PARTITIONS                                │   │
│  │  • Partial failures: Some nodes fail                               │   │
│  │  • Network delays: Communication takes time                        │   │
│  │  • Partition tolerance: Systems must handle splits                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Communication Patterns

#### Synchronous Communication (Request-Response)

```typescript
// Example: HTTP/REST communication
class UserServiceClient {
    async getUser(userId: string): Promise<User> {
        const response = await fetch(`https://user-service/users/${userId}`);
        return response.json();
    }

    async updateUser(userId: string, data: UserData): Promise<User> {
        const response = await fetch(`https://user-service/users/${userId}`, {
            method: 'PUT',
            body: JSON.stringify(data),
            headers: { 'Content-Type': 'application/json' },
        });
        return response.json();
    }
}
```

**Characteristics:**
- Client waits for response (blocking)
- Simple to implement
- Client and service need to be available
- Tight coupling between services

#### Asynchronous Communication (Message-Driven)

```typescript
// Example: Message Queue communication
class TaskQueueProducer {
    async createTask(taskData: TaskData): Promise<void> {
        await this.queue.publish('tasks', {
            type: 'create_task',
            data: taskData,
            timestamp: new Date(),
        });
        // Returns immediately - doesn't wait for processing
    }
}

class TaskQueueConsumer {
    async start(): Promise<void> {
        await this.queue.consume('tasks', async (message) => {
            // Process task asynchronously
            await this.processTask(message);
        });
    }
}
```

**Characteristics:**
- Decoupled services
- Better fault tolerance
- Eventual consistency
- More complex to implement

### 3. Distributed Data Patterns

#### CAP Theorem

The CAP Theorem states that a distributed system can only provide two of three guarantees:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CAP THEOREM                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                      ┌─────────────┐                                        │
│                      │             │                                        │
│                      │    CONSISTENCY                                       │
│                      │   (All nodes │                                        │
│                      │    see same  │                                        │
│                      │    data)    │                                        │
│                      │             │                                        │
│                      └──────┬──────┘                                        │
│                             │                                               │
│            ┌────────────────┼────────────────┐                              │
│            │                │                │                              │
│            │                │                │                              │
│            ▼                ▼                ▼                              │
│  ┌─────────────────┐  ┌─────────────┐  ┌─────────────────┐                 │
│  │                 │  │             │  │                 │                 │
│  │   AVAILABILITY  │──│   PARTITION │──│   CONSISTENCY   │                 │
│  │   (Every node   │  │   TOLERANCE │  │   +             │                 │
│  │    responds)    │  │   (System   │  │   AVAILABILITY  │                 │
│  │                 │  │   works     │  │   (BUT not      │                 │
│  │                 │  │   despite   │  │    partition    │                 │
│  │                 │  │   network   │  │    tolerant)    │                 │
│  │                 │  │   splits)   │  │                 │                 │
│  └─────────────────┘  └─────────────┘  └─────────────────┘                 │
│                                                                             │
│  Choose 2:                                                                  │
│  • CP (Consistency + Partition Tolerance) - Strong consistency              │
│  • AP (Availability + Partition Tolerance) - Eventual consistency           │
│  • CA (Consistency + Availability) - Not possible in distributed systems   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Consistency Patterns

**Strong Consistency (CP)**

```typescript
// Example: Distributed locking for strong consistency
class DistributedLock {
    async acquire(lockName: string, ttl: number): Promise<boolean> {
        // Redis SET NX with TTL
        const result = await redis.set(lockName, process.pid, {
            nx: true,
            px: ttl,
        });
        return result !== null;
    }

    async release(lockName: string): Promise<void> {
        await redis.del(lockName);
    }
}

// Usage
class AccountService {
    async transfer(from: string, to: string, amount: number): Promise<void> {
        const lock = new DistributedLock();
        const lockKey = `account:${Math.min(from, to)}:${Math.max(from, to)}`;
        
        if (await lock.acquire(lockKey, 5000)) {
            try {
                // Critical section
                await this.db.transaction(async (trx) => {
                    await this.debitAccount(from, amount, trx);
                    await this.creditAccount(to, amount, trx);
                });
            } finally {
                await lock.release(lockKey);
            }
        }
    }
}
```

**Eventual Consistency (AP)**

```typescript
// Example: Event sourcing for eventual consistency
class EventSourcedService {
    async createOrder(orderData: OrderData): Promise<string> {
        const orderId = randomUUID();
        
        // Record the event
        await this.eventStore.append({
            aggregateId: orderId,
            eventType: 'ORDER_CREATED',
            data: orderData,
            version: 1,
        });
        
        // Return immediately (eventual consistency)
        return orderId;
    }
}

// Background processor eventually updates read models
class OrderProjector {
    async processEvents(): Promise<void> {
        const events = await this.eventStore.getUnprocessedEvents();
        
        for (const event of events) {
            // Update read model
            await this.updateReadModel(event);
            // Mark as processed
            await this.eventStore.markProcessed(event.id);
        }
    }
}
```

### 4. Distributed Transaction Patterns

#### Saga Pattern

```typescript
// Saga: Distributed transaction across multiple services
class OrderSaga {
    private steps: SagaStep[] = [];
    private compensations: SagaStep[] = [];

    constructor() {
        this.registerSteps();
    }

    private registerSteps(): void {
        // Step 1: Reserve inventory
        this.steps.push({
            name: 'reserve_inventory',
            execute: async (ctx) => {
                await inventoryService.reserve(ctx.items);
            },
            compensate: async (ctx) => {
                await inventoryService.release(ctx.items);
            },
        });

        // Step 2: Process payment
        this.steps.push({
            name: 'process_payment',
            execute: async (ctx) => {
                await paymentService.charge(ctx.amount);
            },
            compensate: async (ctx) => {
                await paymentService.refund(ctx.amount);
            },
        });

        // Step 3: Create order
        this.steps.push({
            name: 'create_order',
            execute: async (ctx) => {
                ctx.orderId = await orderService.create(ctx);
            },
            compensate: async (ctx) => {
                await orderService.cancel(ctx.orderId);
            },
        });
    }

    async execute(context: any): Promise<void> {
        let stepIndex = 0;
        
        try {
            // Execute steps sequentially
            for (stepIndex = 0; stepIndex < this.steps.length; stepIndex++) {
                await this.steps[stepIndex].execute(context);
            }
        } catch (error) {
            // Compensate in reverse order
            for (let i = stepIndex - 1; i >= 0; i--) {
                await this.steps[i].compensate(context);
            }
            throw error;
        }
    }
}
```

#### Two-Phase Commit (2PC) Pattern

```typescript
class TwoPhaseCommit {
    private participants: Participant[] = [];

    constructor(participants: Participant[]) {
        this.participants = participants;
    }

    async commit(transactionId: string): Promise<void> {
        // Phase 1: Prepare
        const prepared = await this.prepare(transactionId);
        
        if (prepared) {
            // Phase 2: Commit
            await this.commitTransaction(transactionId);
        } else {
            // Rollback
            await this.rollback(transactionId);
        }
    }

    private async prepare(transactionId: string): Promise<boolean> {
        const results = await Promise.all(
            this.participants.map(p => p.prepare(transactionId))
        );
        
        return results.every(r => r === true);
    }

    private async commitTransaction(transactionId: string): Promise<void> {
        await Promise.all(
            this.participants.map(p => p.commit(transactionId))
        );
    }

    private async rollback(transactionId: string): Promise<void> {
        await Promise.all(
            this.participants.map(p => p.rollback(transactionId))
        );
    }
}
```

### 5. Fault Tolerance Patterns

#### Circuit Breaker

```typescript
class CircuitBreaker {
    private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
    private failureCount = 0;
    private lastFailureTime: number = 0;
    
    constructor(
        private readonly failureThreshold: number = 5,
        private readonly resetTimeout: number = 60000,
        private readonly halfOpenTimeout: number = 10000
    ) {}

    async execute<T>(
        operation: () => Promise<T>,
        fallback?: () => Promise<T>
    ): Promise<T> {
        // Check current state
        if (this.state === 'OPEN') {
            // Check if we should transition to half-open
            if (Date.now() - this.lastFailureTime > this.resetTimeout) {
                this.state = 'HALF_OPEN';
                return this.executeWithProtection(operation, fallback);
            }
            // Circuit is open - fail fast
            throw new Error('Circuit breaker is OPEN');
        }

        return this.executeWithProtection(operation, fallback);
    }

    private async executeWithProtection<T>(
        operation: () => Promise<T>,
        fallback?: () => Promise<T>
    ): Promise<T> {
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
        // Reset failure count gradually
        this.failureCount = Math.max(0, this.failureCount - 1);
    }

    private onFailure(): void {
        this.failureCount++;
        this.lastFailureTime = Date.now();
        
        if (this.failureCount >= this.failureThreshold) {
            this.state = 'OPEN';
        }
    }
}
```

#### Retry with Exponential Backoff

```typescript
class RetryManager {
    constructor(
        private readonly maxRetries: number = 3,
        private readonly initialDelay: number = 1000,
        private readonly maxDelay: number = 30000,
        private readonly backoffMultiplier: number = 2
    ) {}

    async execute<T>(
        operation: () => Promise<T>,
        shouldRetry: (error: Error) => boolean = () => true
    ): Promise<T> {
        let lastError: Error | null = null;
        let delay = this.initialDelay;

        for (let attempt = 0; attempt < this.maxRetries; attempt++) {
            try {
                return await operation();
            } catch (error) {
                lastError = error;
                
                // Check if we should retry
                if (!shouldRetry(error)) {
                    throw error;
                }
                
                // Check if this was the last attempt
                if (attempt === this.maxRetries - 1) {
                    throw error;
                }
                
                // Wait with jitter
                const jitter = 0.8 + Math.random() * 0.4;
                const waitTime = Math.min(delay * jitter, this.maxDelay);
                
                await this.sleep(waitTime);
                delay *= this.backoffMultiplier;
            }
        }
        
        throw lastError;
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

### 6. Distributed Locking Patterns

#### Redis Distributed Lock

```typescript
class RedisDistributedLock {
    private readonly client: Redis;
    
    constructor(client: Redis) {
        this.client = client;
    }

    async acquire(
        lockName: string,
        ttl: number = 10000,
        retryTimes: number = 3,
        retryDelay: number = 100
    ): Promise<Lock | null> {
        const lockKey = `lock:${lockName}`;
        const lockValue = `${process.pid}:${Date.now()}:${Math.random()}`;

        for (let attempt = 0; attempt < retryTimes; attempt++) {
            // Try to acquire lock
            const result = await this.client.set(lockKey, lockValue, {
                nx: true,
                px: ttl,
            });

            if (result) {
                return new Lock(lockKey, lockValue, this.client);
            }

            await this.sleep(retryDelay);
        }

        return null;
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

class Lock {
    constructor(
        private readonly key: string,
        private readonly value: string,
        private readonly client: Redis
    ) {}

    async release(): Promise<void> {
        // Use Lua script for atomic operation
        const script = `
            if redis.call("get", KEYS[1]) == ARGV[1] then
                return redis.call("del", KEYS[1])
            else
                return 0
            end
        `;
        await this.client.eval(script, 1, this.key, this.value);
    }
}
```

### 7. Consistency and Consensus

#### Distributed Consensus (Raft/Paxos)

Consensus algorithms ensure that multiple nodes agree on a single value.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CONSENSUS ALGORITHM (Raft)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                     ┌─────────────────────┐                                │
│                     │    Leader           │                                │
│                     │   (Elected)         │                                │
│                     └─────────────────────┘                                │
│                              │                                              │
│              ┌───────────────┼───────────────┐                              │
│              │               │               │                              │
│              ▼               ▼               ▼                              │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐               │
│  │   Follower      │ │   Follower      │ │   Follower      │               │
│  │   (Replica)     │ │   (Replica)     │ │   (Replica)     │               │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘               │
│                                                                             │
│  State Machine:                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Request → Log → Replicate → Commit → Apply to State Machine       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8. Common Distributed System Pitfalls

#### Network Failures

```typescript
// ❌ BAD: Assuming network is always available
async function callService(): Promise<void> {
    const response = await fetch('http://service/api');
    // No error handling - will crash on network issues
}

// ✅ GOOD: Handle network failures
async function callService(): Promise<void> {
    try {
        const response = await fetch('http://service/api', {
            timeout: 3000,
        });
        return response.json();
    } catch (error) {
        if (error.code === 'ECONNABORTED') {
            // Timeout - retry later
            await this.retryLater();
        } else if (error.code === 'ECONNREFUSED') {
            // Service unavailable - circuit breaker
            throw new ServiceUnavailableError(error);
        }
        throw error;
    }
}
```

#### Race Conditions

```typescript
// ❌ BAD: Race condition
class Counter {
    private count = 0;
    
    async increment(): Promise<void> {
        const current = await this.getCount();
        await this.setCount(current + 1);
        // Two requests could get the same current value
        // Loss of updates!
    }
}

// ✅ GOOD: Use distributed lock
class Counter {
    async increment(): Promise<void> {
        const lock = await this.lockManager.acquire('counter');
        try {
            const current = await this.getCount();
            await this.setCount(current + 1);
        } finally {
            await lock.release();
        }
    }
}
```

#### Clock Drift

```typescript
// ❌ BAD: Using system time for ordering
const timestamp = Date.now();
// Different nodes could have different times

// ✅ GOOD: Use sequence numbers or logical clocks
class LogicalClock {
    private vector: Map<string, number> = new Map();
    private nodeId: string;

    constructor(nodeId: string) {
        this.nodeId = nodeId;
        this.vector.set(nodeId, 0);
    }

    increment(): void {
        const current = this.vector.get(this.nodeId) || 0;
        this.vector.set(this.nodeId, current + 1);
    }

    merge(other: LogicalClock): void {
        for (const [nodeId, time] of other.vector) {
            const current = this.vector.get(nodeId) || 0;
            if (time > current) {
                this.vector.set(nodeId, time);
            }
        }
    }

    compare(other: LogicalClock): number {
        // Compare vector clocks
        // Returns -1, 0, or 1 for ordering
    }
}
```

### 9. Key Takeaways

1. **Fallacies of Distributed Computing:**
   - The network is reliable
   - Latency is zero
   - Bandwidth is infinite
   - The network is secure
   - Topology doesn't change
   - There is one administrator
   - Transport cost is zero
   - The network is homogeneous

2. **Design for Failure:**
   - Expect network failures
   - Handle partial failures
   - Implement retries with backoff
   - Use circuit breakers
   - Have graceful degradation

3. **Choose the Right Patterns:**
   - Synchronous communication for critical operations
   - Asynchronous communication for decoupling
   - Strong consistency for financial transactions
   - Eventual consistency for less critical data

4. **Monitor Everything:**
   - Distributed tracing
   - Metrics collection
   - Log aggregation
   - Health checks

5. **Think About Data:**
   - Where is the data located?
   - How is it replicated?
   - What consistency guarantees do you need?
   - How do you handle conflicts?

---

This primer provides a comprehensive understanding of distributed systems patterns. These concepts are essential for building robust, scalable, and fault-tolerant distributed applications.
