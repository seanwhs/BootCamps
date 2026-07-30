# Primer 8: Understanding Testing Strategies in Distributed Systems

## A Deep Dive into Testing Complex Architectures

Welcome to the eighth primer! This is a comprehensive deep dive into testing strategies for distributed systems. Think of this like having a rigorous quality assurance process for your restaurant chain - you need to test every component individually, how they work together, and how the entire system performs under real-world conditions.

### 1. The Big Picture

#### Testing Pyramid for Distributed Systems

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TESTING PYRAMID                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                           ┌─────────────┐                                   │
│                          /   E2E Tests   \                                  │
│                         /   (Few)         \                                 │
│                        /───────────────────\                                │
│                       /  Integration Tests  \                               │
│                      /    (Some)              \                             │
│                     /───────────────────────────\                          │
│                    /      Unit Tests             \                         │
│                   /         (Many)                 \                        │
│                  ┌─────────────────────────────────────┐                    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                          ADDITIONAL TEST TYPES                      │   │
│  │  • Contract Tests   • Performance Tests   • Security Tests         │   │
│  │  • Chaos Tests      • Smoke Tests         • Canary Tests          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Unit Testing

Unit tests verify individual components in isolation.

#### Testing Domain Entities

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { User } from '../src/core/domain/entities/user.entity.js';

describe('User Entity', () => {
    let user: User;

    beforeEach(() => {
        user = new User({
            email: 'test@example.com',
            username: 'testuser',
            firstName: 'Test',
            lastName: 'User',
            passwordHash: 'hashed_password',
        });
    });

    it('should create a valid user', () => {
        expect(user.id).toBeDefined();
        expect(user.email).toBe('test@example.com');
        expect(user.username).toBe('testuser');
        expect(user.fullName).toBe('Test User');
        expect(user.isActive).toBe(true);
    });

    it('should validate email format', () => {
        expect(() => {
            new User({
                email: 'invalid-email',
                username: 'testuser',
                firstName: 'Test',
                lastName: 'User',
                passwordHash: 'hash',
            });
        }).toThrow('Invalid email format');
    });

    it('should update profile', () => {
        user.updateProfile('John', 'Doe');
        expect(user.firstName).toBe('John');
        expect(user.lastName).toBe('Doe');
        expect(user.fullName).toBe('John Doe');
    });

    it('should deactivate and reactivate', () => {
        expect(user.isActive).toBe(true);
        
        user.deactivate();
        expect(user.isActive).toBe(false);
        
        user.reactivate();
        expect(user.isActive).toBe(true);
    });

    it('should record login', () => {
        expect(user.lastLoginAt).toBeNull();
        
        user.recordLogin();
        expect(user.lastLoginAt).toBeDefined();
        expect(user.lastLoginAt).toBeInstanceOf(Date);
    });
});
```

#### Testing Domain Services

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { UserDomainService } from '../src/core/domain/services/user.service.js';
import { IUserRepository } from '../src/core/domain/repositories/user.repository.port.js';

describe('UserDomainService', () => {
    let userService: UserDomainService;
    let mockRepository: IUserRepository;

    beforeEach(() => {
        mockRepository = {
            save: vi.fn(),
            findById: vi.fn(),
            findByEmail: vi.fn(),
            findByUsername: vi.fn(),
            existsByEmail: vi.fn(),
            existsByUsername: vi.fn(),
            delete: vi.fn(),
            findAll: vi.fn(),
            count: vi.fn(),
        };

        userService = new UserDomainService(mockRepository);
    });

    it('should register a new user', async () => {
        const userData = {
            email: 'new@example.com',
            username: 'newuser',
            firstName: 'New',
            lastName: 'User',
            passwordHash: 'hashed_password',
        };

        // Mock repository responses
        mockRepository.existsByEmail.mockResolvedValue(false);
        mockRepository.existsByUsername.mockResolvedValue(false);
        mockRepository.save.mockImplementation(async (user) => user);

        const user = await userService.registerUser(userData);

        expect(user).toBeDefined();
        expect(user.email).toBe('new@example.com');
        expect(user.username).toBe('newuser');
        expect(mockRepository.save).toHaveBeenCalledWith(user);
    });

    it('should throw if email already exists', async () => {
        const userData = {
            email: 'existing@example.com',
            username: 'newuser',
            firstName: 'New',
            lastName: 'User',
            passwordHash: 'hashed_password',
        };

        mockRepository.existsByEmail.mockResolvedValue(true);

        await expect(userService.registerUser(userData))
            .rejects
            .toThrow('Email is already registered');
    });

    it('should throw if username already exists', async () => {
        const userData = {
            email: 'new@example.com',
            username: 'existinguser',
            firstName: 'New',
            lastName: 'User',
            passwordHash: 'hashed_password',
        };

        mockRepository.existsByEmail.mockResolvedValue(false);
        mockRepository.existsByUsername.mockResolvedValue(true);

        await expect(userService.registerUser(userData))
            .rejects
            .toThrow('Username is already taken');
    });

    it('should authenticate a user', async () => {
        const user = new User({
            email: 'test@example.com',
            username: 'testuser',
            firstName: 'Test',
            lastName: 'User',
            passwordHash: 'hashed_password',
        });

        mockRepository.findByEmail.mockResolvedValue(user);
        mockRepository.save.mockResolvedValue(user);

        const authenticated = await userService.authenticateUser('test@example.com');

        expect(authenticated).toBe(user);
        expect(authenticated.lastLoginAt).toBeDefined();
        expect(mockRepository.save).toHaveBeenCalled();
    });

    it('should throw if user not found on authenticate', async () => {
        mockRepository.findByEmail.mockResolvedValue(null);

        await expect(userService.authenticateUser('nonexistent@example.com'))
            .rejects
            .toThrow('User not found');
    });
});
```

#### Testing Event Handlers

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { UserCreatedEvent } from '../src/core/domain/events/user-events.js';
import { NotificationHandler } from '../src/core/application/handlers/notification-handler.js';

describe('NotificationHandler', () => {
    let notificationHandler: NotificationHandler;
    let mockEmailService: any;

    beforeEach(() => {
        mockEmailService = {
            sendWelcomeEmail: vi.fn().mockResolvedValue(true),
            sendLoginNotification: vi.fn().mockResolvedValue(true),
        };

        notificationHandler = new NotificationHandler(mockEmailService);
    });

    it('should send welcome email on user created', async () => {
        const event = new UserCreatedEvent(
            'user-123',
            'test@example.com',
            'testuser',
            'Test',
            'User',
            'hashed_password'
        );

        await notificationHandler.handleUserEvents(event);

        expect(mockEmailService.sendWelcomeEmail).toHaveBeenCalledWith(
            'test@example.com',
            'testuser'
        );
    });

    it('should handle email service failure gracefully', async () => {
        mockEmailService.sendWelcomeEmail.mockRejectedValue(new Error('Email service down'));

        const event = new UserCreatedEvent(
            'user-123',
            'test@example.com',
            'testuser',
            'Test',
            'User',
            'hashed_password'
        );

        // Should not throw
        await expect(notificationHandler.handleUserEvents(event))
            .resolves
            .toBeUndefined();

        // Error should be logged
        // In a real test, you'd check the logger
    });
});
```

### 3. Integration Testing

Integration tests verify that components work together correctly.

#### Testing Repositories

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { PostgresUserRepository } from '../src/infrastructure/adapters/persistence/postgres/user.repository.js';
import { postgresConnection } from '../src/infrastructure/adapters/persistence/postgres/connection.js';
import { User } from '../src/core/domain/entities/user.entity.js';

describe('PostgresUserRepository Integration Tests', () => {
    let repository: PostgresUserRepository;

    beforeAll(async () => {
        await postgresConnection.connect();
        repository = new PostgresUserRepository();
        
        // Clean up test data
        await postgresConnection.query('DELETE FROM users WHERE email LIKE $1', ['%test%']);
    });

    afterAll(async () => {
        await postgresConnection.query('DELETE FROM users WHERE email LIKE $1', ['%test%']);
        await postgresConnection.disconnect();
    });

    it('should save and find a user', async () => {
        const user = new User({
            email: 'integration-test@example.com',
            username: 'integrationtest',
            firstName: 'Integration',
            lastName: 'Test',
            passwordHash: 'hashed_password',
        });

        await repository.save(user);
        const found = await repository.findById(user.id);

        expect(found).toBeDefined();
        expect(found?.id).toBe(user.id);
        expect(found?.email).toBe('integration-test@example.com');
        expect(found?.username).toBe('integrationtest');
    });

    it('should find user by email', async () => {
        const user = new User({
            email: 'find-by-email@example.com',
            username: 'findbyemail',
            firstName: 'Find',
            lastName: 'ByEmail',
            passwordHash: 'hashed_password',
        });

        await repository.save(user);
        const found = await repository.findByEmail('find-by-email@example.com');

        expect(found).toBeDefined();
        expect(found?.id).toBe(user.id);
    });

    it('should update a user', async () => {
        const user = new User({
            email: 'update-test@example.com',
            username: 'updatetest',
            firstName: 'Original',
            lastName: 'User',
            passwordHash: 'hashed_password',
        });

        await repository.save(user);

        user.updateProfile('Updated', 'Name');
        await repository.save(user);

        const found = await repository.findById(user.id);
        expect(found?.firstName).toBe('Updated');
        expect(found?.lastName).toBe('Name');
    });

    it('should handle duplicate email errors', async () => {
        const user1 = new User({
            email: 'duplicate@example.com',
            username: 'user1',
            firstName: 'User',
            lastName: 'One',
            passwordHash: 'hashed_password',
        });

        await repository.save(user1);

        const user2 = new User({
            email: 'duplicate@example.com',
            username: 'user2',
            firstName: 'User',
            lastName: 'Two',
            passwordHash: 'hashed_password',
        });

        await expect(repository.save(user2))
            .rejects
            .toThrow('A user with this email or username already exists');
    });
});
```

#### Testing Event Store

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { PostgresEventStore } from '../src/infrastructure/adapters/event-store/postgres/event-store.js';
import { UserCreatedEvent, UserProfileUpdatedEvent } from '../src/core/domain/events/user-events.js';

describe('PostgresEventStore Integration Tests', () => {
    let eventStore: PostgresEventStore;

    beforeAll(async () => {
        eventStore = new PostgresEventStore();
    });

    afterAll(async () => {
        await postgresConnection.query('DELETE FROM events WHERE aggregate_id LIKE $1', ['test-%']);
    });

    it('should store and retrieve events', async () => {
        const userId = `test-${Date.now()}`;
        
        const events = [
            new UserCreatedEvent(
                userId,
                'test@example.com',
                'testuser',
                'Test',
                'User',
                'hashed_password'
            ),
            new UserProfileUpdatedEvent(
                userId,
                'Updated',
                'Name',
                2
            ),
        ];

        await eventStore.appendEvents(userId, events);

        const retrieved = await eventStore.getEvents(userId);
        expect(retrieved).toHaveLength(2);
        expect(retrieved[0].eventType).toBe('UserCreated');
        expect(retrieved[1].eventType).toBe('UserProfileUpdated');
    });

    it('should handle concurrency conflicts', async () => {
        const userId = `test-conflict-${Date.now()}`;
        
        const event1 = new UserCreatedEvent(
            userId,
            'conflict@example.com',
            'conflictuser',
            'Conflict',
            'User',
            'hashed_password'
        );

        await eventStore.appendEvents(userId, [event1]);

        // Try to append with wrong version
        const event2 = new UserProfileUpdatedEvent(
            userId,
            'Duplicate',
            'User',
            1 // Should be 2
        );

        await expect(eventStore.appendEvents(userId, [event2]))
            .rejects
            .toThrow('Concurrency conflict');
    });
});
```

### 4. Contract Testing

Contract tests ensure services communicate correctly.

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { ServiceClient } from '../src/infrastructure/services/service-client.js';

describe('Service Contract Tests', () => {
    let client: ServiceClient;

    beforeAll(() => {
        client = new ServiceClient({
            baseUrl: 'http://user-service:3001',
            serviceName: 'user-service',
        });
    });

    it('should match the expected API contract', async () => {
        // Test the service responds with expected structure
        const health = await client.get('/health');
        
        expect(health).toHaveProperty('status');
        expect(health).toHaveProperty('service');
        expect(health).toHaveProperty('version');
        expect(health.status).toBe('ok');
    });

    it('should handle user creation', async () => {
        const userData = {
            email: 'contract-test@example.com',
            username: 'contracttest',
            firstName: 'Contract',
            lastName: 'Test',
        };

        const response = await client.post('/api/users', userData);
        
        expect(response).toHaveProperty('id');
        expect(response.email).toBe(userData.email);
        expect(response.username).toBe(userData.username);
    });

    it('should handle errors consistently', async () => {
        try {
            await client.get('/api/users/nonexistent');
        } catch (error) {
            expect(error).toBeInstanceOf(ServiceError);
            expect(error.statusCode).toBe(404);
            expect(error.message).toContain('User not found');
        }
    });
});
```

### 5. End-to-End (E2E) Testing

E2E tests verify the entire system works together.

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { Server } from '../src/server.js';
import { postgresConnection } from '../src/infrastructure/adapters/persistence/postgres/connection.js';
import { redisConnection } from '../src/infrastructure/adapters/cache/redis/connection.js';

describe('Complete Flow E2E Tests', () => {
    let server: Server;
    let app: any;
    let userId: string;
    let taskId: string;

    beforeAll(async () => {
        server = new Server();
        app = server.getApp();
        await server.start();

        // Clean up test data
        await postgresConnection.query('DELETE FROM users WHERE email LIKE $1', ['%test%']);
    });

    afterAll(async () => {
        await postgresConnection.query('DELETE FROM users WHERE email LIKE $1', ['%test%']);
        await postgresConnection.disconnect();
        await redisConnection.disconnect();
    });

    it('should complete the entire user → task flow', async () => {
        // 1. Create a user
        const userResponse = await request(app)
            .post('/api/users')
            .send({
                email: 'e2e-test@example.com',
                username: 'e2etest',
                password: 'SecurePass123',
                firstName: 'E2E',
                lastName: 'Test',
            });

        expect(userResponse.status).toBe(201);
        expect(userResponse.body.success).toBe(true);
        userId = userResponse.body.data.id;

        // 2. Create a task
        const taskResponse = await request(app)
            .post('/api/tasks')
            .send({
                title: 'E2E Test Task',
                description: 'Testing the complete flow',
                userId,
                priority: 'high',
            });

        expect(taskResponse.status).toBe(201);
        expect(taskResponse.body.success).toBe(true);
        taskId = taskResponse.body.data.id;

        // 3. Get the task
        const getResponse = await request(app)
            .get(`/api/tasks/${taskId}`)
            .query({ userId });

        expect(getResponse.status).toBe(200);
        expect(getResponse.body.data.status).toBe('pending');
        expect(getResponse.body.data.title).toBe('E2E Test Task');

        // 4. Start the task
        const startResponse = await request(app)
            .post(`/api/tasks/${taskId}/start`)
            .send({ userId });

        expect(startResponse.status).toBe(200);
        expect(startResponse.body.data.status).toBe('in_progress');

        // 5. Complete the task
        const completeResponse = await request(app)
            .post(`/api/tasks/${taskId}/complete`)
            .send({ userId });

        expect(completeResponse.status).toBe(200);
        expect(completeResponse.body.data.status).toBe('completed');

        // 6. Get all user tasks
        const tasksResponse = await request(app)
            .get(`/api/users/${userId}/tasks`);

        expect(tasksResponse.status).toBe(200);
        expect(tasksResponse.body.count).toBeGreaterThan(0);
        expect(tasksResponse.body.data[0].status).toBe('completed');
    });

    it('should handle validation errors', async () => {
        const response = await request(app)
            .post('/api/users')
            .send({
                email: 'invalid-email',
                username: 'a', // Too short
                password: 'short', // Too short
            });

        expect(response.status).toBe(400);
        expect(response.body.error).toBe('Validation Error');
    });

    it('should handle rate limiting', async () => {
        // Make many requests quickly
        const requests = Array.from({ length: 10 }, () => {
            return request(app)
                .get('/health')
                .set('x-user-id', 'rate-limit-test');
        });

        const responses = await Promise.all(requests);
        const rateLimited = responses.filter(r => r.status === 429);
        
        // Should see some rate limiting
        expect(rateLimited.length).toBeGreaterThan(0);
    });

    it('should handle not found errors', async () => {
        const response = await request(app)
            .get('/api/users/nonexistent-id');

        expect(response.status).toBe(404);
        expect(response.body.success).toBe(false);
        expect(response.body.message).toBe('User not found');
    });
});
```

### 6. Performance Testing

#### Load Testing

```typescript
import { describe, it, beforeAll } from 'vitest';
import { createDefaultOrchestrator } from '../src/core/application/orchestration/orchestrator.js';

describe('Performance Tests', () => {
    let orchestrator: any;

    beforeAll(() => {
        orchestrator = createDefaultOrchestrator();
    });

    it('should handle high concurrency', async () => {
        const concurrent = 100;
        const requests = Array.from({ length: concurrent }, (_, i) => {
            return orchestrator.execute(
                async () => {
                    // Simulate work
                    await new Promise(resolve => setTimeout(resolve, Math.random() * 10));
                    return i;
                },
                { priority: 2 }
            );
        });

        const start = Date.now();
        const results = await Promise.all(requests);
        const duration = Date.now() - start;

        console.log(`Processed ${concurrent} requests in ${duration}ms`);
        console.log(`Throughput: ${(concurrent / (duration / 1000)).toFixed(2)} req/s`);

        expect(results).toHaveLength(concurrent);
    });

    it('should handle sustained load', async () => {
        const duration = 10000; // 10 seconds
        const requestsPerSecond = 50;
        const start = Date.now();
        let processed = 0;

        while (Date.now() - start < duration) {
            const batch = Array.from({ length: requestsPerSecond }, (_, i) => {
                return orchestrator.execute(
                    async () => {
                        processed++;
                        return processed;
                    },
                    { priority: 3 }
                );
            });

            await Promise.all(batch);
            
            // Wait for next second
            await new Promise(resolve => setTimeout(resolve, 1000));
        }

        const actualDuration = Date.now() - start;
        console.log(`Processed ${processed} requests in ${actualDuration}ms`);
        console.log(`Average throughput: ${(processed / (actualDuration / 1000)).toFixed(2)} req/s`);

        expect(processed).toBeGreaterThan(0);
    });
});
```

#### Benchmarking

```typescript
import { performance } from 'perf_hooks';

class Benchmark {
    static async measure<T>(
        name: string,
        fn: () => Promise<T>,
        iterations: number = 100
    ): Promise<{ average: number; min: number; max: number; p95: number }> {
        const times: number[] = [];

        // Warm up
        for (let i = 0; i < 10; i++) {
            await fn();
        }

        // Measure
        for (let i = 0; i < iterations; i++) {
            const start = performance.now();
            await fn();
            const end = performance.now();
            times.push(end - start);
        }

        const sorted = times.sort((a, b) => a - b);
        const sum = times.reduce((a, b) => a + b, 0);
        const average = sum / times.length;
        const min = sorted[0];
        const max = sorted[times.length - 1];
        const p95Index = Math.floor(times.length * 0.95);
        const p95 = sorted[p95Index];

        console.log(`Benchmark: ${name}`);
        console.log(`  Average: ${average.toFixed(2)}ms`);
        console.log(`  Min: ${min.toFixed(2)}ms`);
        console.log(`  Max: ${max.toFixed(2)}ms`);
        console.log(`  95th percentile: ${p95.toFixed(2)}ms`);

        return { average, min, max, p95 };
    }
}

// Usage
describe('Benchmark Tests', () => {
    it('should benchmark user creation', async () => {
        const orchestrator = createDefaultOrchestrator();
        
        await Benchmark.measure('User Creation', async () => {
            await orchestrator.execute(
                async () => {
                    // Simulate user creation
                    await new Promise(resolve => setTimeout(resolve, 10));
                    return { id: 'user-123' };
                },
                { priority: 1 }
            );
        }, 100);
    });
});
```

### 7. Chaos Testing

Chaos testing verifies system resilience.

```typescript
class ChaosTester {
    private errors: Error[] = [];

    async testResilience(
        operation: () => Promise<any>,
        failureRate: number = 0.1,
        iterations: number = 100
    ): Promise<{
        successRate: number;
        errors: Error[];
        recoveryTime: number;
    }> {
        let successes = 0;
        let failures = 0;
        const recoveryTimes: number[] = [];

        for (let i = 0; i < iterations; i++) {
            try {
                const start = Date.now();
                
                // Randomly inject failure
                if (Math.random() < failureRate) {
                    throw new Error('Chaos injected failure');
                }

                await operation();
                successes++;
                recoveryTimes.push(Date.now() - start);
            } catch (error) {
                failures++;
                this.errors.push(error instanceof Error ? error : new Error(String(error)));
                
                // Measure recovery time
                const recoveryStart = Date.now();
                // Retry with backoff
                let retried = false;
                for (let retry = 0; retry < 3; retry++) {
                    try {
                        await operation();
                        retried = true;
                        break;
                    } catch {
                        await this.sleep(100 * Math.pow(2, retry));
                    }
                }
                
                if (retried) {
                    recoveryTimes.push(Date.now() - recoveryStart);
                }
            }
        }

        return {
            successRate: successes / iterations,
            errors: this.errors,
            recoveryTime: recoveryTimes.reduce((a, b) => a + b, 0) / recoveryTimes.length,
        };
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Usage in tests
describe('Chaos Tests', () => {
    it('should handle failures gracefully', async () => {
        const chaos = new ChaosTester();
        const result = await chaos.testResilience(
            async () => {
                // Simulate an operation that might fail
                const orchestrator = createDefaultOrchestrator();
                await orchestrator.execute(
                    async () => {
                        // Simulate work
                        await new Promise(resolve => setTimeout(resolve, 50));
                        return { success: true };
                    },
                    { priority: 1 }
                );
            },
            0.2, // 20% failure rate
            50
        );

        console.log('Chaos Test Results:');
        console.log(`  Success Rate: ${(result.successRate * 100).toFixed(2)}%`);
        console.log(`  Average Recovery Time: ${result.recoveryTime.toFixed(2)}ms`);
        console.log(`  Total Errors: ${result.errors.length}`);

        // Should recover from most failures
        expect(result.successRate).toBeGreaterThan(0.7);
    });
});
```

### 8. Testing Best Practices

#### Test Fixtures

```typescript
// Test fixtures for reusable test data
class TestFixtures {
    static async createUser(data?: Partial<User>): Promise<User> {
        const user = new User({
            email: data?.email || `test-${Date.now()}@example.com`,
            username: data?.username || `testuser-${Date.now()}`,
            firstName: data?.firstName || 'Test',
            lastName: data?.lastName || 'User',
            passwordHash: data?.passwordHash || 'hashed_password',
        });
        return user;
    }

    static async createTask(data?: Partial<Task>): Promise<Task> {
        const user = await this.createUser();
        return new Task({
            title: data?.title || 'Test Task',
            description: data?.description || 'A test task',
            userId: data?.userId || user.id,
            priority: data?.priority || 'medium',
            dueDate: data?.dueDate,
        });
    }

    static async createEvent<T extends DomainEvent>(
        eventType: new (...args: any[]) => T,
        data: any
    ): Promise<T> {
        return new eventType(
            data.id || `test-${Date.now()}`,
            ...Object.values(data)
        );
    }
}
```

#### Test Helpers

```typescript
// Test helpers for common operations
class TestHelpers {
    static async waitForCondition(
        condition: () => Promise<boolean>,
        timeout: number = 5000,
        interval: number = 100
    ): Promise<void> {
        const start = Date.now();
        
        while (Date.now() - start < timeout) {
            if (await condition()) {
                return;
            }
            await new Promise(resolve => setTimeout(resolve, interval));
        }
        
        throw new Error('Condition not met within timeout');
    }

    static async retryOperation<T>(
        operation: () => Promise<T>,
        maxAttempts: number = 3,
        delay: number = 100
    ): Promise<T> {
        let lastError: Error | null = null;
        
        for (let attempt = 0; attempt < maxAttempts; attempt++) {
            try {
                return await operation();
            } catch (error) {
                lastError = error instanceof Error ? error : new Error(String(error));
                if (attempt < maxAttempts - 1) {
                    await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, attempt)));
                }
            }
        }
        
        throw lastError;
    }
}

// Usage in tests
describe('Helper Tests', () => {
    it('should wait for condition', async () => {
        let conditionMet = false;
        
        setTimeout(() => {
            conditionMet = true;
        }, 2000);
        
        await TestHelpers.waitForCondition(async () => conditionMet);
        expect(conditionMet).toBe(true);
    });
});
```

### 9. Key Takeaways

1. **Test Pyramid is a Guide:**
   - Many unit tests
   - Some integration tests
   - Few E2E tests

2. **Mock External Dependencies:**
   - Use mocks for unit tests
   - Use test doubles for integration tests
   - Use real dependencies only when necessary

3. **Test Edge Cases:**
   - Validation errors
   - Concurrent operations
   - Network failures
   - Timeouts

4. **Performance Testing is Important:**
   - Load testing for capacity planning
   - Stress testing for breaking points
   - Benchmarking for performance regression

5. **Chaos Testing Builds Confidence:**
   - Tests resilience
   - Uncovers hidden dependencies
   - Validates recovery mechanisms

6. **Test Data Management:**
   - Use fixtures for reusable test data
   - Clean up after tests
   - Isolate test environments

7. **Continuous Testing:**
   - Run tests in CI/CD pipeline
   - Fail fast with unit tests
   - Complete pipeline with E2E tests

---

This primer provides a comprehensive understanding of testing strategies for distributed systems. A well-tested system is reliable, maintainable, and inspires confidence in production deployments.
