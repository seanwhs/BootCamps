# Primer 2: Understanding Hexagonal Architecture (Ports & Adapters)

## A Deep Dive into Clean Architecture

Welcome to the second primer! This is a comprehensive deep dive into Hexagonal Architecture - also known as Ports & Adapters. This architectural pattern is the foundation for building maintainable, testable, and flexible applications.

### 1. The Big Picture

Hexagonal Architecture is about isolating your business logic from external concerns. Think of it like the core of an onion - the business logic is at the center, and everything else wraps around it.

#### The Hexagonal Architecture Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    HEXAGONAL ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                    ┌─────────────────────────────────┐                     │
│                    │      EXTERNAL WORLD             │                     │
│                    │  (HTTP, Database, Queues, etc.) │                     │
│                    └─────────────────────────────────┘                     │
│                            │           │                                   │
│                            ▼           ▼                                   │
│                   ┌─────────────────────────────┐                        │
│                   │      ADAPTERS               │                        │
│                   │  (Controllers, Repositories, │                        │
│                   │   Clients, etc.)            │                        │
│                   └─────────────────────────────┘                        │
│                            │           │                                   │
│                            ▼           ▼                                   │
│                   ┌─────────────────────────────┐                        │
│                   │         PORTS               │                        │
│                   │  (Interfaces/Contracts)     │                        │
│                   └─────────────────────────────┘                        │
│                            │           │                                   │
│                            ▼           ▼                                   │
│          ┌─────────────────────────────────────────────────┐              │
│          │                APPLICATION CORE                 │              │
│          │  ┌───────────────────────────────────────────┐  │              │
│          │  │          DOMAIN LAYER                    │  │              │
│          │  │  (Entities, Business Logic, Rules)       │  │              │
│          │  └───────────────────────────────────────────┘  │              │
│          │  ┌───────────────────────────────────────────┐  │              │
│          │  │       APPLICATION LAYER                  │  │              │
│          │  │  (Use Cases, Commands, Queries)          │  │              │
│          │  └───────────────────────────────────────────┘  │              │
│          └─────────────────────────────────────────────────┘              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. The Core Concept: Dependency Inversion

The most important principle in Hexagonal Architecture is Dependency Inversion.

#### Dependency Inversion Principle (DIP)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DEPENDENCY INVERSION                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Traditional Layered Architecture:                                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│  │   UI Layer  │───▶│ Business    │───▶│  Data       │                    │
│  │             │    │  Layer      │    │  Layer      │                    │
│  └─────────────┘    └─────────────┘    └─────────────┘                    │
│        │                   │                  │                            │
│        │                   │                  │                            │
│        ▼                   ▼                  ▼                            │
│  ┌─────────────────────────────────────────────────────────────────┐      │
│  │  HIGH-LEVEL MODULES DEPEND ON LOW-LEVEL MODULES                │      │
│  │  (Business Logic depends on Database - BAD!)                   │      │
│  └─────────────────────────────────────────────────────────────────┘      │
│                                                                             │
│  Hexagonal Architecture (Dependency Inversion):                            │
│  ┌─────────────┐         ┌─────────────┐         ┌─────────────┐         │
│  │   UI        │◀────────│   Ports     │◀────────│   Domain    │         │
│  │  Adapter    │         │  (Abstract) │         │   Core      │         │
│  └─────────────┘         └─────────────┘         └─────────────┘         │
│        │                       ▲                        ▲                  │
│        │                       │                        │                  │
│        ▼                       │                        │                  │
│  ┌─────────────┐         ┌─────────────┐         ┌─────────────┐         │
│  │  Database   │─────────│   Ports     │─────────│   Domain    │         │
│  │  Adapter    │         │  (Abstract) │         │   Core      │         │
│  └─────────────┘         └─────────────┘         └─────────────┘         │
│                                                                             │
│  DEPENDENCIES POINT INWARD                                                  │
│  (Everything depends on abstractions, not concrete implementations)       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3. The Three Layers

#### Domain Layer (The Core)

**What it contains:**
- Business entities
- Business rules and logic
- Domain services
- Value objects

**Characteristics:**
- Pure business logic
- No external dependencies
- No infrastructure concerns
- Should be easy to unit test

```typescript
// Example: Domain Entity
export class User {
    private _email: string;
    private _name: string;
    private _isActive: boolean;

    constructor(email: string, name: string) {
        this.setEmail(email);
        this._name = name;
        this._isActive = true;
    }

    // Business rule: Email must be valid
    private setEmail(email: string): void {
        if (!this.isValidEmail(email)) {
            throw new Error('Invalid email format');
        }
        this._email = email;
    }

    // Business rule: Only active users can update their name
    updateName(newName: string): void {
        if (!this._isActive) {
            throw new Error('Cannot update inactive user');
        }
        this._name = newName;
    }

    deactivate(): void {
        this._isActive = false;
    }

    // Business rule: User must be active to perform operations
    get email(): string {
        if (!this._isActive) {
            throw new Error('Inactive user');
        }
        return this._email;
    }

    private isValidEmail(email: string): boolean {
        // Business validation
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }
}
```

#### Application Layer (Use Cases)

**What it contains:**
- Commands (write operations)
- Queries (read operations)
- Handlers (orchestrate domain)
- DTOs (Data Transfer Objects)

**Characteristics:**
- Orchestrates domain objects
- Contains application-specific logic
- Doesn't contain business rules
- Coordinates between domain and infrastructure

```typescript
// Example: Command
export class CreateUserCommand {
    public readonly email: string;
    public readonly name: string;

    private constructor(email: string, name: string) {
        this.email = email;
        this.name = name;
    }

    static create(data: any): CreateUserCommand {
        // Validate input
        const schema = z.object({
            email: z.string().email(),
            name: z.string().min(1).max(100),
        });
        
        const validated = schema.parse(data);
        return new CreateUserCommand(validated.email, validated.name);
    }
}

// Example: Command Handler
export class UserCommandHandler {
    constructor(
        private readonly userService: UserDomainService,
        private readonly userRepository: IUserRepository
    ) {}

    async handleCreateUser(command: CreateUserCommand): Promise<User> {
        // Check business rules via domain service
        const userExists = await this.userRepository.findByEmail(command.email);
        if (userExists) {
            throw new Error('User already exists');
        }

        // Create user via domain service
        const user = await this.userService.registerUser({
            email: command.email,
            name: command.name,
        });

        return user;
    }
}
```

### 4. Ports (Interfaces)

Ports define the boundaries of your application. They are the abstract interfaces that your core depends on.

#### Primary Ports (Driving)

**Purpose:** Define how the outside world interacts with your application.

```typescript
// Example: Primary Port - User Service Interface
export interface IUserService {
    registerUser(userData: UserData): Promise<User>;
    getUserById(id: string): Promise<User | null>;
    updateUser(id: string, data: UserData): Promise<User>;
    deleteUser(id: string): Promise<boolean>;
}

// Example: Primary Port - Task Service Interface
export interface ITaskService {
    createTask(taskData: TaskData): Promise<Task>;
    getTaskById(id: string): Promise<Task | null>;
    completeTask(id: string): Promise<Task>;
    assignTask(id: string, userId: string): Promise<Task>;
}
```

#### Secondary Ports (Driven)

**Purpose:** Define how your application interacts with external systems.

```typescript
// Example: Secondary Port - Repository Interface
export interface IUserRepository {
    save(user: User): Promise<User>;
    findById(id: string): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    delete(id: string): Promise<boolean>;
}

// Example: Secondary Port - Event Publisher
export interface IEventPublisher {
    publish(event: DomainEvent): Promise<void>;
    publishAll(events: DomainEvent[]): Promise<void>;
}

// Example: Secondary Port - Cache Service
export interface ICacheService {
    get<T>(key: string): Promise<T | null>;
    set<T>(key: string, value: T, ttl: number): Promise<void>;
    delete(key: string): Promise<void>;
}
```

### 5. Adapters (Implementations)

Adapters are concrete implementations of ports. They translate between the outside world and your application.

#### Primary Adapters (Driving)

**Purpose:** Handle input from the outside world (HTTP, CLI, etc.).

```typescript
// Example: Primary Adapter - HTTP Controller
export class UserController {
    constructor(
        private readonly userService: IUserService
    ) {}

    registerRoutes(server: FastifyInstance): void {
        server.post('/api/users', this.createUser.bind(this));
        server.get('/api/users/:id', this.getUser.bind(this));
        server.put('/api/users/:id', this.updateUser.bind(this));
        server.delete('/api/users/:id', this.deleteUser.bind(this));
    }

    private async createUser(
        request: FastifyRequest,
        reply: FastifyReply
    ): Promise<void> {
        try {
            const user = await this.userService.registerUser(request.body);
            reply.code(201).send({ data: user });
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // ... other methods
}
```

#### Secondary Adapters (Driven)

**Purpose:** Communicate with external systems (databases, APIs, etc.).

```typescript
// Example: Secondary Adapter - PostgreSQL Repository
export class PostgresUserRepository implements IUserRepository {
    async save(user: User): Promise<User> {
        const query = `
            INSERT INTO users (id, email, name, is_active)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT (id) DO UPDATE
            SET email = $2, name = $3, is_active = $4
            RETURNING *
        `;
        
        const result = await this.db.query(query, [
            user.id,
            user.email,
            user.name,
            user.isActive,
        ]);
        
        return this.mapRowToUser(result.rows[0]);
    }

    async findById(id: string): Promise<User | null> {
        const result = await this.db.query(
            'SELECT * FROM users WHERE id = $1',
            [id]
        );
        return result.rows[0] 
            ? this.mapRowToUser(result.rows[0])
            : null;
    }

    private mapRowToUser(row: any): User {
        const user = new User(row.email, row.name);
        // Map other properties
        return user;
    }
}
```

### 6. Dependency Injection

Dependency Injection is how we wire everything together.

```typescript
// Example: Simple DI Container
export class Container {
    private static instance: Container;
    private services: Map<string, any> = new Map();

    static getInstance(): Container {
        if (!Container.instance) {
            Container.instance = new Container();
        }
        return Container.instance;
    }

    register<T>(key: string, implementation: T): void {
        this.services.set(key, implementation);
    }

    resolve<T>(key: string): T {
        const service = this.services.get(key);
        if (!service) {
            throw new Error(`Service ${key} not found`);
        }
        return service as T;
    }

    // Configure dependencies
    configure(): void {
        // Repositories (Secondary Adapters)
        this.register('UserRepository', new PostgresUserRepository());
        this.register('EventPublisher', new PostgresEventPublisher());

        // Domain Services
        this.register('UserDomainService', new UserDomainService(
            this.resolve('UserRepository')
        ));

        // Application Services
        this.register('UserCommandHandler', new UserCommandHandler(
            this.resolve('UserDomainService'),
            this.resolve('UserRepository')
        ));

        // Controllers (Primary Adapters)
        this.register('UserController', new UserController(
            this.resolve('UserCommandHandler')
        ));
    }
}
```

### 7. Testing in Hexagonal Architecture

The architecture makes testing extremely easy.

#### Unit Testing Domain

```typescript
describe('User Domain Entity', () => {
    it('should create a valid user', () => {
        const user = new User('test@example.com', 'Test User');
        expect(user.email).toBe('test@example.com');
        expect(user.name).toBe('Test User');
    });

    it('should validate email format', () => {
        expect(() => {
            new User('invalid-email', 'Test User');
        }).toThrow('Invalid email format');
    });

    it('should not allow updates to inactive user', () => {
        const user = new User('test@example.com', 'Test User');
        user.deactivate();
        expect(() => {
            user.updateName('New Name');
        }).toThrow('Cannot update inactive user');
    });
});
```

#### Testing Application Layer

```typescript
describe('UserCommandHandler', () => {
    let handler: UserCommandHandler;
    let mockRepository: jest.Mocked<IUserRepository>;

    beforeEach(() => {
        mockRepository = {
            save: jest.fn(),
            findById: jest.fn(),
            findByEmail: jest.fn(),
            delete: jest.fn(),
        };
        
        const mockService = new UserDomainService(mockRepository);
        handler = new UserCommandHandler(mockService, mockRepository);
    });

    it('should create a new user', async () => {
        const command = CreateUserCommand.create({
            email: 'test@example.com',
            name: 'Test User',
        });

        mockRepository.findByEmail.mockResolvedValue(null);
        mockRepository.save.mockResolvedValue(/* user */);

        const user = await handler.handleCreateUser(command);
        expect(user).toBeDefined();
        expect(mockRepository.save).toHaveBeenCalled();
    });

    it('should throw if user already exists', async () => {
        const command = CreateUserCommand.create({
            email: 'test@example.com',
            name: 'Test User',
        });

        mockRepository.findByEmail.mockResolvedValue({} as any);

        await expect(handler.handleCreateUser(command))
            .rejects
            .toThrow('User already exists');
    });
});
```

#### Testing Adapters

```typescript
describe('PostgresUserRepository', () => {
    let repository: PostgresUserRepository;
    let mockDb: any;

    beforeEach(() => {
        mockDb = {
            query: jest.fn(),
        };
        repository = new PostgresUserRepository(mockDb);
    });

    it('should save a user', async () => {
        const user = new User('test@example.com', 'Test User');
        mockDb.query.mockResolvedValue({
            rows: [{ id: '1', email: 'test@example.com', name: 'Test User' }],
        });

        const saved = await repository.save(user);
        expect(saved).toBeDefined();
        expect(mockDb.query).toHaveBeenCalled();
    });
});
```

### 8. Benefits and Trade-offs

#### Benefits

1. **Testability:** Each layer can be tested in isolation
2. **Flexibility:** Swap implementations without changing core logic
3. **Maintainability:** Clear separation of concerns
4. **Domain Focus:** Business logic isn't diluted by infrastructure
5. **Framework Independence:** The core doesn't depend on frameworks

#### Trade-offs

1. **Complexity:** More moving parts than simpler architectures
2. **Overhead:** More code to write initially
3. **Learning Curve:** Requires understanding of patterns
4. **Indirection:** More levels of abstraction

### 9. Common Mistakes

#### Business Logic in Adapters

```typescript
// ❌ BAD: Business logic in controller
class UserController {
    async createUser(request, reply) {
        const { email, name } = request.body;
        
        // Business logic mixed with HTTP concerns
        if (!email.includes('@')) {
            return reply.code(400).send({ error: 'Invalid email' });
        }
        
        // Database logic in controller
        const existing = await db.query('SELECT * FROM users WHERE email = $1', [email]);
        if (existing.rows[0]) {
            return reply.code(409).send({ error: 'User exists' });
        }
        
        await db.query('INSERT INTO users (email, name) VALUES ($1, $2)', [email, name]);
        return reply.code(201).send({ success: true });
    }
}

// ✅ GOOD: Business logic in domain
class UserController {
    constructor(private readonly userService: IUserService) {}
    
    async createUser(request, reply) {
        try {
            const user = await this.userService.registerUser(request.body);
            return reply.code(201).send({ data: user });
        } catch (error) {
            return reply.code(400).send({ error: error.message });
        }
    }
}
```

#### Direct Dependencies on Infrastructure

```typescript
// ❌ BAD: Core depends on infrastructure
class UserService {
    constructor(private readonly db: PostgresDB) {}
    // Core depends on concrete database implementation
}

// ✅ GOOD: Core depends on abstraction
class UserService {
    constructor(private readonly repository: IUserRepository) {}
    // Core depends on interface
}
```

### 10. Real-World Example

Here's a complete example of a hexagonal architecture implementation:

```typescript
// 1. Domain Entity
export class Task {
    constructor(
        private readonly _id: string,
        private _title: string,
        private _status: TaskStatus,
        private readonly _userId: string
    ) {}

    complete(): void {
        if (this._status === TaskStatus.COMPLETED) {
            throw new Error('Task already completed');
        }
        this._status = TaskStatus.COMPLETED;
    }

    get id(): string { return this._id; }
    get title(): string { return this._title; }
    get status(): TaskStatus { return this._status; }
}

// 2. Domain Service
export class TaskDomainService {
    constructor(private readonly repository: ITaskRepository) {}

    async createTask(data: TaskData): Promise<Task> {
        const task = new Task(
            randomUUID(),
            data.title,
            TaskStatus.PENDING,
            data.userId
        );
        await this.repository.save(task);
        return task;
    }

    async completeTask(id: string): Promise<Task> {
        const task = await this.repository.findById(id);
        if (!task) {
            throw new Error('Task not found');
        }
        task.complete();
        await this.repository.save(task);
        return task;
    }
}

// 3. Port (Repository Interface)
export interface ITaskRepository {
    save(task: Task): Promise<void>;
    findById(id: string): Promise<Task | null>;
    findAllByUser(userId: string): Promise<Task[]>;
}

// 4. Adapter (PostgreSQL)
export class PostgresTaskRepository implements ITaskRepository {
    async save(task: Task): Promise<void> {
        await this.db.query(
            'INSERT INTO tasks (id, title, status, user_id) VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO UPDATE SET title = $2, status = $3',
            [task.id, task.title, task.status, task.userId]
        );
    }

    async findById(id: string): Promise<Task | null> {
        const result = await this.db.query(
            'SELECT * FROM tasks WHERE id = $1',
            [id]
        );
        if (result.rows.length === 0) return null;
        const row = result.rows[0];
        return new Task(row.id, row.title, row.status, row.user_id);
    }
}

// 5. Application Layer
export class TaskCommandHandler {
    constructor(private readonly taskService: TaskDomainService) {}

    async handleCreateTask(command: CreateTaskCommand): Promise<Task> {
        return this.taskService.createTask(command.toObject());
    }

    async handleCompleteTask(taskId: string, userId: string): Promise<Task> {
        // Verify ownership
        const task = await this.taskService.getTask(taskId);
        if (task.userId !== userId) {
            throw new Error('Task belongs to different user');
        }
        return this.taskService.completeTask(taskId);
    }
}

// 6. Primary Adapter (Controller)
export class TaskController {
    constructor(private readonly handler: TaskCommandHandler) {}

    registerRoutes(server: FastifyInstance): void {
        server.post('/api/tasks', this.createTask.bind(this));
        server.post('/api/tasks/:id/complete', this.completeTask.bind(this));
    }

    async createTask(request, reply) {
        const command = CreateTaskCommand.create(request.body);
        const task = await this.handler.handleCreateTask(command);
        return reply.code(201).send({ data: task });
    }

    async completeTask(request, reply) {
        const { id } = request.params;
        const { userId } = request.body;
        const task = await this.handler.handleCompleteTask(id, userId);
        return reply.code(200).send({ data: task });
    }
}

// 7. DI Container
const container = new Container();
container.register('ITaskRepository', new PostgresTaskRepository());
container.register('TaskDomainService', new TaskDomainService(
    container.resolve('ITaskRepository')
));
container.register('TaskCommandHandler', new TaskCommandHandler(
    container.resolve('TaskDomainService')
));
container.register('TaskController', new TaskController(
    container.resolve('TaskCommandHandler')
));
```

### 11. Key Takeaways

1. **Core is King:** The domain layer is the most important part
2. **Depend on Abstractions:** Never depend on concrete implementations
3. **Ports Define Boundaries:** Interfaces define how the core interacts
4. **Adapters Are Plugins:** Infrastructure components are replaceable
5. **Test the Core:** Unit test your business logic
6. **Keep Adapters Thin:** Adapters should only translate, not contain logic
7. **DI is the Glue:** Use dependency injection to wire everything together

---

This primer provides a comprehensive understanding of Hexagonal Architecture. It's the foundation for building maintainable, testable applications that can adapt to changing requirements.
