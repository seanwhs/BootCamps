# Phase 2, Part 1: Hexagonal Architecture Foundations

## Building Modular, Testable Systems

Welcome to Phase 2! We're moving from a functional HTTP service to a well-architected system. Think of this like organizing a kitchen: instead of having all your tools scattered around, you organize them into stations (prep, cooking, plating) with clear boundaries between them.

### 1. The Target

**What we're building:** A refactored gateway service using Hexagonal Architecture (Ports & Adapters) that:
- Separates business logic from infrastructure
- Makes dependencies explicit and invertible
- Enables testing in isolation
- Prepares the codebase for future microservices

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── index.ts
│   ├── config.ts
│   ├── logger.ts
│   │
│   ├── core/                        # Domain Layer (Business Logic)
│   │   ├── domain/
│   │   │   ├── entities/           # Business entities
│   │   │   │   ├── user.entity.ts
│   │   │   │   └── task.entity.ts
│   │   │   ├── repositories/       # Ports (interfaces)
│   │   │   │   ├── user.repository.port.ts
│   │   │   │   └── task.repository.port.ts
│   │   │   └── services/           # Domain services
│   │   │       ├── user.service.ts
│   │   │       └── task.service.ts
│   │   │
│   │   └── application/            # Application Layer (Use Cases)
│   │       ├── commands/
│   │       │   ├── create-user.command.ts
│   │       │   └── create-task.command.ts
│   │       ├── queries/
│   │       │   ├── get-user.query.ts
│   │       │   └── get-tasks.query.ts
│   │       └── handlers/
│   │           ├── user.handlers.ts
│   │           └── task.handlers.ts
│   │
│   ├── infrastructure/             # Infrastructure Layer (Adapters)
│   │   ├── adapters/
│   │   │   ├── http/              # HTTP Adapters
│   │   │   │   ├── user.controller.ts
│   │   │   │   ├── task.controller.ts
│   │   │   │   └── validation/
│   │   │   │       ├── user.schemas.ts
│   │   │   │       └── task.schemas.ts
│   │   │   ├── persistence/       # Database Adapters
│   │   │   │   ├── postgres/
│   │   │   │   │   ├── user.repository.ts
│   │   │   │   │   └── task.repository.ts
│   │   │   │   └── in-memory/
│   │   │   │       ├── user.repository.ts
│   │   │   │       └── task.repository.ts
│   │   │   └── messaging/         # Message Queue Adapters
│   │   │       ├── event.publisher.ts
│   │   │       └── event.consumer.ts
│   │   │
│   │   └── di/                    # Dependency Injection
│   │       └── container.ts
│   │
│   ├── shared/                    # Shared Utilities
│   │   ├── errors/
│   │   │   └── app-error.ts
│   │   ├── types/
│   │   │   └── index.ts
│   │   └── utils/
│   │       ├── id-generator.ts
│   │       └── date-utils.ts
│   │
│   └── server.ts
│
└── tests/
    ├── unit/                      # Unit Tests (Domain)
    ├── integration/               # Integration Tests (Application)
    └── e2e/                       # End-to-End Tests (HTTP)
```

### 2. The Concept: Hexagonal Architecture Explained

Imagine you're building a house. The **core** of the house is where you live (business logic). The **ports** are like the doors and windows (interfaces). The **adapters** are like the people and utilities that come through those doors (HTTP clients, databases, external services).

#### The Three Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│                     INFRASTRUCTURE LAYER                          │
│  (Adapters - Everything that connects to the outside world)       │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐             │
│  │  HTTP   │  │Database │  │  Redis  │  │  Queue  │             │
│  │ Controller│ │Repository│ │  Cache  │  │ Producer│             │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘             │
│       │            │            │            │                   │
│       └────────────┴────────────┴────────────┘                   │
│                    │                                             │
│                    ▼                                             │
│           ┌─────────────────┐                                   │
│           │    PORTS        │  (Interfaces/Contracts)            │
│           │   (Interfaces)  │                                   │
│           └─────────────────┘                                   │
│                    │                                             │
│                    ▼                                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                   │
│                     APPLICATION LAYER                            │
│  (Use Cases - Orchestrates the domain)                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Commands   │  │   Queries   │  │  Handlers   │             │
│  │ (Write)     │  │  (Read)     │  │             │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                    │                                             │
│                    ▼                                             │
│                                                                   │
│                     DOMAIN LAYER                                 │
│  (Business Logic - The heart of the application)                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Entities   │  │  Services   │  │ Value       │             │
│  │  (Models)   │  │  (Logic)    │  │ Objects     │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                   │
└─────────────────────────────────────────────────────────────────────┘
```

**The Key Principle: Dependency Inversion**
- The Domain knows NOTHING about the outside world
- The Application knows about the Domain but NOT about Infrastructure
- The Infrastructure knows about BOTH (it implements the ports)

### 3. The Implementation

Let's build our hexagonal architecture step by step.

#### Step 1: Core Domain Entities

**File:** `packages/gateway/src/core/domain/entities/user.entity.ts`

```typescript
import { randomUUID } from 'crypto';

/**
 * User Entity
 * 
 * This is a core business entity representing a user in our system.
 * It contains only business logic - no infrastructure concerns.
 * 
 * An entity is defined by its identity (id) and its lifecycle.
 */
export interface UserProps {
  id?: string;
  email: string;
  username: string;
  firstName: string;
  lastName: string;
  passwordHash: string;
  createdAt?: Date;
  updatedAt?: Date;
  isActive?: boolean;
  lastLoginAt?: Date;
}

export class User {
  private readonly _id: string;
  private _email: string;
  private _username: string;
  private _firstName: string;
  private _lastName: string;
  private _passwordHash: string;
  private _createdAt: Date;
  private _updatedAt: Date;
  private _isActive: boolean;
  private _lastLoginAt: Date | null;

  /**
   * Create a new User entity
   * 
   * Business rules enforced in the constructor:
   * - Email must be valid format
   * - Username must be at least 3 characters
   * - Password hash must be provided
   */
  constructor(props: UserProps) {
    // Validate required fields
    if (!props.email) {
      throw new Error('Email is required');
    }
    if (!this.isValidEmail(props.email)) {
      throw new Error('Invalid email format');
    }
    if (!props.username || props.username.length < 3) {
      throw new Error('Username must be at least 3 characters');
    }
    if (!props.passwordHash) {
      throw new Error('Password hash is required');
    }

    // Set properties with validation
    this._id = props.id || randomUUID();
    this._email = props.email.toLowerCase();
    this._username = props.username;
    this._firstName = props.firstName || '';
    this._lastName = props.lastName || '';
    this._passwordHash = props.passwordHash;
    this._createdAt = props.createdAt || new Date();
    this._updatedAt = props.updatedAt || new Date();
    this._isActive = props.isActive !== undefined ? props.isActive : true;
    this._lastLoginAt = props.lastLoginAt || null;
  }

  // Getters
  get id(): string { return this._id; }
  get email(): string { return this._email; }
  get username(): string { return this._username; }
  get firstName(): string { return this._firstName; }
  get lastName(): string { return this._lastName; }
  get fullName(): string { return `${this._firstName} ${this._lastName}`.trim(); }
  get passwordHash(): string { return this._passwordHash; }
  get createdAt(): Date { return this._createdAt; }
  get updatedAt(): Date { return this._updatedAt; }
  get isActive(): boolean { return this._isActive; }
  get lastLoginAt(): Date | null { return this._lastLoginAt; }

  // Business methods
  /**
   * Update user profile
   */
  updateProfile(firstName: string, lastName: string): void {
    if (firstName && firstName.length < 1) {
      throw new Error('First name must be at least 1 character');
    }
    if (lastName && lastName.length < 1) {
      throw new Error('Last name must be at least 1 character');
    }
    
    this._firstName = firstName;
    this._lastName = lastName;
    this._updatedAt = new Date();
  }

  /**
   * Change email address
   */
  changeEmail(newEmail: string): void {
    if (!this.isValidEmail(newEmail)) {
      throw new Error('Invalid email format');
    }
    this._email = newEmail.toLowerCase();
    this._updatedAt = new Date();
  }

  /**
   * Record a login event
   */
  recordLogin(): void {
    this._lastLoginAt = new Date();
    this._updatedAt = new Date();
  }

  /**
   * Deactivate user account
   */
  deactivate(): void {
    if (!this._isActive) {
      throw new Error('User is already deactivated');
    }
    this._isActive = false;
    this._updatedAt = new Date();
  }

  /**
   * Reactivate user account
   */
  reactivate(): void {
    if (this._isActive) {
      throw new Error('User is already active');
    }
    this._isActive = true;
    this._updatedAt = new Date();
  }

  /**
   * Update password hash
   */
  updatePasswordHash(newHash: string): void {
    if (!newHash || newHash.length < 60) {
      throw new Error('Invalid password hash format');
    }
    this._passwordHash = newHash;
    this._updatedAt = new Date();
  }

  // Utility methods
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Convert to plain object (for serialization)
   */
  toJSON(): Omit<UserProps, 'passwordHash'> & { fullName: string } {
    return {
      id: this._id,
      email: this._email,
      username: this._username,
      firstName: this._firstName,
      lastName: this._lastName,
      fullName: this.fullName,
      createdAt: this._createdAt,
      updatedAt: this._updatedAt,
      isActive: this._isActive,
      lastLoginAt: this._lastLoginAt,
    };
  }
}
```

**File:** `packages/gateway/src/core/domain/entities/task.entity.ts`

```typescript
import { randomUUID } from 'crypto';

/**
 * Task Entity
 * 
 * Represents a task in our system with its own business rules.
 * Shows how entities can have complex state machines.
 */
export enum TaskStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

export enum TaskPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

export interface TaskProps {
  id?: string;
  title: string;
  description: string;
  userId: string;
  status?: TaskStatus;
  priority?: TaskPriority;
  dueDate?: Date;
  createdAt?: Date;
  updatedAt?: Date;
  completedAt?: Date;
  metadata?: Record<string, unknown>;
}

export class Task {
  private readonly _id: string;
  private _title: string;
  private _description: string;
  private _userId: string;
  private _status: TaskStatus;
  private _priority: TaskPriority;
  private _dueDate: Date | null;
  private _createdAt: Date;
  private _updatedAt: Date;
  private _completedAt: Date | null;
  private _metadata: Record<string, unknown>;

  constructor(props: TaskProps) {
    // Validation
    if (!props.title || props.title.length < 3) {
      throw new Error('Title must be at least 3 characters');
    }
    if (!props.description || props.description.length < 10) {
      throw new Error('Description must be at least 10 characters');
    }
    if (!props.userId) {
      throw new Error('User ID is required');
    }

    this._id = props.id || randomUUID();
    this._title = props.title;
    this._description = props.description;
    this._userId = props.userId;
    this._status = props.status || TaskStatus.PENDING;
    this._priority = props.priority || TaskPriority.MEDIUM;
    this._dueDate = props.dueDate || null;
    this._createdAt = props.createdAt || new Date();
    this._updatedAt = props.updatedAt || new Date();
    this._completedAt = props.completedAt || null;
    this._metadata = props.metadata || {};
  }

  // Getters
  get id(): string { return this._id; }
  get title(): string { return this._title; }
  get description(): string { return this._description; }
  get userId(): string { return this._userId; }
  get status(): TaskStatus { return this._status; }
  get priority(): TaskPriority { return this._priority; }
  get dueDate(): Date | null { return this._dueDate; }
  get createdAt(): Date { return this._createdAt; }
  get updatedAt(): Date { return this._updatedAt; }
  get completedAt(): Date | null { return this._completedAt; }
  get metadata(): Record<string, unknown> { return { ...this._metadata }; }
  get isOverdue(): boolean {
    if (!this._dueDate) return false;
    return this._dueDate < new Date() && this._status !== TaskStatus.COMPLETED;
  }

  // Business methods
  /**
   * Start working on a task
   */
  start(): void {
    if (this._status === TaskStatus.COMPLETED) {
      throw new Error('Cannot start a completed task');
    }
    if (this._status === TaskStatus.CANCELLED) {
      throw new Error('Cannot start a cancelled task');
    }
    this._status = TaskStatus.IN_PROGRESS;
    this._updatedAt = new Date();
  }

  /**
   * Complete a task
   */
  complete(): void {
    if (this._status === TaskStatus.COMPLETED) {
      throw new Error('Task is already completed');
    }
    if (this._status === TaskStatus.CANCELLED) {
      throw new Error('Cannot complete a cancelled task');
    }
    this._status = TaskStatus.COMPLETED;
    this._completedAt = new Date();
    this._updatedAt = new Date();
  }

  /**
   * Fail a task
   */
  fail(reason?: string): void {
    if (this._status === TaskStatus.COMPLETED) {
      throw new Error('Cannot fail a completed task');
    }
    if (this._status === TaskStatus.CANCELLED) {
      throw new Error('Cannot fail a cancelled task');
    }
    this._status = TaskStatus.FAILED;
    this._updatedAt = new Date();
    if (reason) {
      this._metadata = { ...this._metadata, failureReason: reason };
    }
  }

  /**
   * Cancel a task
   */
  cancel(reason?: string): void {
    if (this._status === TaskStatus.COMPLETED) {
      throw new Error('Cannot cancel a completed task');
    }
    this._status = TaskStatus.CANCELLED;
    this._updatedAt = new Date();
    if (reason) {
      this._metadata = { ...this._metadata, cancellationReason: reason };
    }
  }

  /**
   * Update task priority
   */
  updatePriority(newPriority: TaskPriority): void {
    if (this._status === TaskStatus.COMPLETED) {
      throw new Error('Cannot update priority of completed task');
    }
    this._priority = newPriority;
    this._updatedAt = new Date();
  }

  /**
   * Update task due date
   */
  updateDueDate(newDueDate: Date): void {
    if (this._status === TaskStatus.COMPLETED) {
      throw new Error('Cannot update due date of completed task');
    }
    if (newDueDate < new Date()) {
      throw new Error('Due date cannot be in the past');
    }
    this._dueDate = newDueDate;
    this._updatedAt = new Date();
  }

  /**
   * Update task details
   */
  updateDetails(title: string, description: string): void {
    if (this._status === TaskStatus.COMPLETED) {
      throw new Error('Cannot update a completed task');
    }
    if (title && title.length < 3) {
      throw new Error('Title must be at least 3 characters');
    }
    if (description && description.length < 10) {
      throw new Error('Description must be at least 10 characters');
    }
    this._title = title;
    this._description = description;
    this._updatedAt = new Date();
  }

  /**
   * Add metadata to task
   */
  addMetadata(key: string, value: unknown): void {
    this._metadata = { ...this._metadata, [key]: value };
    this._updatedAt = new Date();
  }

  /**
   * Remove metadata from task
   */
  removeMetadata(key: string): void {
    const { [key]: _, ...rest } = this._metadata;
    this._metadata = rest;
    this._updatedAt = new Date();
  }

  /**
   * Convert to plain object (for serialization)
   */
  toJSON(): TaskProps {
    return {
      id: this._id,
      title: this._title,
      description: this._description,
      userId: this._userId,
      status: this._status,
      priority: this._priority,
      dueDate: this._dueDate,
      createdAt: this._createdAt,
      updatedAt: this._updatedAt,
      completedAt: this._completedAt,
      metadata: this._metadata,
    };
  }
}
```

#### Step 2: Repository Ports (Interfaces)

**File:** `packages/gateway/src/core/domain/repositories/user.repository.port.ts`

```typescript
import { User, UserProps } from '../entities/user.entity.js';

/**
 * User Repository Port
 * 
 * This defines the contract for how the domain interacts with user storage.
 * The domain depends on this interface, not on the implementation.
 * 
 * This is Dependency Inversion in action:
 * High-level modules (domain) should not depend on low-level modules (infrastructure).
 * Both should depend on abstractions (this interface).
 */
export interface IUserRepository {
  /**
   * Save a user to the repository
   * @returns The saved user with any generated fields
   */
  save(user: User): Promise<User>;
  
  /**
   * Find a user by their ID
   * @returns The user if found, null otherwise
   */
  findById(id: string): Promise<User | null>;
  
  /**
   * Find a user by their email
   * @returns The user if found, null otherwise
   */
  findByEmail(email: string): Promise<User | null>;
  
  /**
   * Find a user by their username
   * @returns The user if found, null otherwise
   */
  findByUsername(username: string): Promise<User | null>;
  
  /**
   * Find all users matching criteria
   * @param criteria - Search criteria
   * @param limit - Maximum number of results
   * @param offset - Number of results to skip
   * @returns Array of users
   */
  findAll(criteria: Partial<UserProps>, limit?: number, offset?: number): Promise<User[]>;
  
  /**
   * Delete a user by their ID
   * @returns True if deleted, false if not found
   */
  delete(id: string): Promise<boolean>;
  
  /**
   * Check if a user exists by email
   */
  existsByEmail(email: string): Promise<boolean>;
  
  /**
   * Check if a user exists by username
   */
  existsByUsername(username: string): Promise<boolean>;
  
  /**
   * Count users matching criteria
   */
  count(criteria: Partial<UserProps>): Promise<number>;
}

// Symbol for dependency injection
export const USER_REPOSITORY = Symbol('USER_REPOSITORY');
```

**File:** `packages/gateway/src/core/domain/repositories/task.repository.port.ts`

```typescript
import { Task, TaskProps, TaskStatus, TaskPriority } from '../entities/task.entity.js';

/**
 * Task Repository Port
 * 
 * Interface for task storage operations.
 * The domain depends on this abstraction, not concrete database implementations.
 */
export interface ITaskRepository {
  /**
   * Save a task to the repository
   */
  save(task: Task): Promise<Task>;
  
  /**
   * Find a task by ID
   */
  findById(id: string): Promise<Task | null>;
  
  /**
   * Find all tasks for a user
   */
  findByUserId(userId: string): Promise<Task[]>;
  
  /**
   * Find tasks by user and status
   */
  findByUserAndStatus(userId: string, status: TaskStatus): Promise<Task[]>;
  
  /**
   * Find tasks by user and priority
   */
  findByUserAndPriority(userId: string, priority: TaskPriority): Promise<Task[]>;
  
  /**
   * Find overdue tasks for a user
   */
  findOverdueByUser(userId: string): Promise<Task[]>;
  
  /**
   * Find all tasks matching criteria
   */
  findAll(criteria: Partial<TaskProps>, limit?: number, offset?: number): Promise<Task[]>;
  
  /**
   * Delete a task by ID
   */
  delete(id: string): Promise<boolean>;
  
  /**
   * Count tasks for a user
   */
  countByUser(userId: string, status?: TaskStatus): Promise<number>;
}

export const TASK_REPOSITORY = Symbol('TASK_REPOSITORY');
```

#### Step 3: Domain Services

**File:** `packages/gateway/src/core/domain/services/user.service.ts`

```typescript
import { User, UserProps } from '../entities/user.entity.js';
import { IUserRepository } from '../repositories/user.repository.port.js';

/**
 * User Domain Service
 * 
 * Contains business logic that doesn't naturally belong to a single entity.
 * These are operations that involve multiple entities or complex workflows.
 * 
 * Domain services are stateless and focused on business rules.
 */
export class UserDomainService {
  constructor(private readonly userRepository: IUserRepository) {}

  /**
   * Register a new user
   * 
   * Business rules:
   * 1. Email must be unique
   * 2. Username must be unique
   * 3. User must be at least 18 years old (if age provided)
   */
  async registerUser(props: Omit<UserProps, 'id' | 'createdAt' | 'updatedAt'>): Promise<User> {
    // Check email uniqueness
    const emailExists = await this.userRepository.existsByEmail(props.email);
    if (emailExists) {
      throw new Error('Email is already registered');
    }

    // Check username uniqueness
    const usernameExists = await this.userRepository.existsByUsername(props.username);
    if (usernameExists) {
      throw new Error('Username is already taken');
    }

    // Create the user entity
    const user = new User(props);

    // Save the user
    return await this.userRepository.save(user);
  }

  /**
   * Authenticate a user
   * 
   * Business rules:
   * 1. User must exist
   * 2. User must be active
   * 3. Password must match (handled by auth service)
   */
  async authenticateUser(email: string): Promise<User> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new Error('User not found');
    }

    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }

    // Record login
    user.recordLogin();
    await this.userRepository.save(user);

    return user;
  }

  /**
   * Update user profile
   * 
   * Business rules:
   * 1. User must exist and be active
   * 2. New username must be unique (if changed)
   */
  async updateProfile(
    userId: string,
    updates: Partial<Pick<User, 'firstName' | 'lastName'>>
  ): Promise<User> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    if (!user.isActive) {
      throw new Error('Cannot update a deactivated user');
    }

    // Update profile
    if (updates.firstName || updates.lastName) {
      user.updateProfile(
        updates.firstName || user.firstName,
        updates.lastName || user.lastName
      );
    }

    return await this.userRepository.save(user);
  }

  /**
   * Deactivate a user account
   * 
   * Business rules:
   * 1. User must exist
   * 2. Cannot deactivate already deactivated user
   */
  async deactivateUser(userId: string): Promise<void> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    user.deactivate();
    await this.userRepository.save(user);
  }

  /**
   * Reactivate a user account
   */
  async reactivateUser(userId: string): Promise<void> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    user.reactivate();
    await this.userRepository.save(user);
  }

  /**
   * Get user by email (for login flows)
   */
  async getUserByEmail(email: string): Promise<User | null> {
    return await this.userRepository.findByEmail(email);
  }

  /**
   * Get user by ID
   */
  async getUserById(id: string): Promise<User | null> {
    return await this.userRepository.findById(id);
  }

  /**
   * Check if a user exists by email
   */
  async userExistsByEmail(email: string): Promise<boolean> {
    return await this.userRepository.existsByEmail(email);
  }

  /**
   * Check if a user exists by username
   */
  async userExistsByUsername(username: string): Promise<boolean> {
    return await this.userRepository.existsByUsername(username);
  }
}
```

**File:** `packages/gateway/src/core/domain/services/task.service.ts`

```typescript
import { Task, TaskProps, TaskStatus, TaskPriority } from '../entities/task.entity.js';
import { ITaskRepository } from '../repositories/task.repository.port.js';
import { IUserRepository } from '../repositories/user.repository.port.js';

/**
 * Task Domain Service
 * 
 * Orchestrates task-related business logic involving multiple entities.
 */
export class TaskDomainService {
  constructor(
    private readonly taskRepository: ITaskRepository,
    private readonly userRepository: IUserRepository
  ) {}

  /**
   * Create a new task
   * 
   * Business rules:
   * 1. User must exist and be active
   * 2. Title must be unique per user (optional business rule)
   */
  async createTask(
    props: Omit<TaskProps, 'id' | 'createdAt' | 'updatedAt' | 'completedAt'>
  ): Promise<Task> {
    // Verify user exists
    const user = await this.userRepository.findById(props.userId);
    if (!user) {
      throw new Error('User not found');
    }
    if (!user.isActive) {
      throw new Error('Cannot create task for deactivated user');
    }

    // Create the task entity
    const task = new Task(props);

    // Save the task
    return await this.taskRepository.save(task);
  }

  /**
   * Start a task
   */
  async startTask(taskId: string, userId: string): Promise<Task> {
    // Verify user exists
    const user = await this.userRepository.findById(userId);
    if (!user || !user.isActive) {
      throw new Error('Invalid user');
    }

    const task = await this.taskRepository.findById(taskId);
    if (!task) {
      throw new Error('Task not found');
    }

    // Verify task belongs to user
    if (task.userId !== userId) {
      throw new Error('Task does not belong to this user');
    }

    task.start();
    return await this.taskRepository.save(task);
  }

  /**
   * Complete a task
   */
  async completeTask(taskId: string, userId: string): Promise<Task> {
    const task = await this.validateTaskOwnership(taskId, userId);
    task.complete();
    return await this.taskRepository.save(task);
  }

  /**
   * Fail a task
   */
  async failTask(taskId: string, userId: string, reason?: string): Promise<Task> {
    const task = await this.validateTaskOwnership(taskId, userId);
    task.fail(reason);
    return await this.taskRepository.save(task);
  }

  /**
   * Cancel a task
   */
  async cancelTask(taskId: string, userId: string, reason?: string): Promise<Task> {
    const task = await this.validateTaskOwnership(taskId, userId);
    task.cancel(reason);
    return await this.taskRepository.save(task);
  }

  /**
   * Update task priority
   */
  async updateTaskPriority(
    taskId: string,
    userId: string,
    priority: TaskPriority
  ): Promise<Task> {
    const task = await this.validateTaskOwnership(taskId, userId);
    task.updatePriority(priority);
    return await this.taskRepository.save(task);
  }

  /**
   * Update task due date
   */
  async updateTaskDueDate(
    taskId: string,
    userId: string,
    dueDate: Date
  ): Promise<Task> {
    const task = await this.validateTaskOwnership(taskId, userId);
    task.updateDueDate(dueDate);
    return await this.taskRepository.save(task);
  }

  /**
   * Update task details
   */
  async updateTaskDetails(
    taskId: string,
    userId: string,
    title: string,
    description: string
  ): Promise<Task> {
    const task = await this.validateTaskOwnership(taskId, userId);
    task.updateDetails(title, description);
    return await this.taskRepository.save(task);
  }

  /**
   * Get tasks for a user
   */
  async getUserTasks(userId: string): Promise<Task[]> {
    // Verify user exists
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    return await this.taskRepository.findByUserId(userId);
  }

  /**
   * Get overdue tasks for a user
   */
  async getOverdueTasks(userId: string): Promise<Task[]> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    return await this.taskRepository.findOverdueByUser(userId);
  }

  /**
   * Get task by ID with ownership validation
   */
  private async validateTaskOwnership(
    taskId: string,
    userId: string
  ): Promise<Task> {
    // Verify user exists
    const user = await this.userRepository.findById(userId);
    if (!user || !user.isActive) {
      throw new Error('Invalid user');
    }

    const task = await this.taskRepository.findById(taskId);
    if (!task) {
      throw new Error('Task not found');
    }

    if (task.userId !== userId) {
      throw new Error('Task does not belong to this user');
    }

    return task;
  }
}
```

#### Step 4: Application Layer - Commands and Queries

**File:** `packages/gateway/src/core/application/commands/create-user.command.ts`

```typescript
import { z } from 'zod';

/**
 * Create User Command
 * 
 * Commands represent write operations in CQRS.
 * They contain data needed to perform an operation.
 * 
 * Using Zod for validation ensures commands are valid before
 * they reach the domain layer.
 */
export class CreateUserCommand {
  // Command properties
  public readonly email: string;
  public readonly username: string;
  public readonly password: string;
  public readonly firstName: string;
  public readonly lastName: string;

  private constructor(props: {
    email: string;
    username: string;
    password: string;
    firstName: string;
    lastName: string;
  }) {
    this.email = props.email;
    this.username = props.username;
    this.password = props.password;
    this.firstName = props.firstName;
    this.lastName = props.lastName;
  }

  /**
   * Create a validated CreateUserCommand
   * 
   * Validation ensures:
   * - Email is valid format
   * - Username is 3-30 characters
   * - Password is at least 8 characters
   * - First name and last name are optional but valid
   */
  static create(data: unknown): CreateUserCommand {
    const schema = z.object({
      email: z.string()
        .email('Invalid email format')
        .min(3, 'Email is too short')
        .max(255, 'Email is too long')
        .toLowerCase(),
      
      username: z.string()
        .min(3, 'Username must be at least 3 characters')
        .max(30, 'Username must be at most 30 characters')
        .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'),
      
      password: z.string()
        .min(8, 'Password must be at least 8 characters')
        .max(100, 'Password is too long'),
      
      firstName: z.string()
        .min(1, 'First name is required')
        .max(50, 'First name is too long')
        .optional()
        .default(''),
      
      lastName: z.string()
        .min(1, 'Last name is required')
        .max(50, 'Last name is too long')
        .optional()
        .default(''),
    });

    const validated = schema.parse(data);
    
    return new CreateUserCommand({
      email: validated.email,
      username: validated.username,
      password: validated.password,
      firstName: validated.firstName || '',
      lastName: validated.lastName || '',
    });
  }

  /**
   * Convert to plain object for use in handlers
   */
  toObject() {
    return {
      email: this.email,
      username: this.username,
      password: this.password,
      firstName: this.firstName,
      lastName: this.lastName,
    };
  }
}
```

**File:** `packages/gateway/src/core/application/queries/get-user.query.ts`

```typescript
import { z } from 'zod';

/**
 * Get User Query
 * 
 * Queries represent read operations.
 * They are immutable and don't modify state.
 */
export class GetUserQuery {
  public readonly userId: string;

  private constructor(userId: string) {
    this.userId = userId;
  }

  /**
   * Create a validated GetUserQuery
   */
  static create(data: unknown): GetUserQuery {
    const schema = z.object({
      userId: z.string()
        .uuid('Invalid user ID format')
        .min(1, 'User ID is required'),
    });

    const validated = schema.parse(data);
    return new GetUserQuery(validated.userId);
  }
}

/**
 * User Response DTO
 * 
 * Data Transfer Object for API responses
 * Ensures we don't expose internal domain details
 */
export interface UserResponse {
  id: string;
  email: string;
  username: string;
  firstName: string;
  lastName: string;
  fullName: string;
  createdAt: Date;
  updatedAt: Date;
  isActive: boolean;
  lastLoginAt: Date | null;
}
```

#### Step 5: Application Handlers

**File:** `packages/gateway/src/core/application/handlers/user.handlers.ts`

```typescript
import { User } from '../../domain/entities/user.entity.js';
import { UserDomainService } from '../../domain/services/user.service.js';
import { CreateUserCommand } from '../commands/create-user.command.js';
import { GetUserQuery, UserResponse } from '../queries/get-user.query.js';
import { createChildLogger } from '../../../logger.js';

/**
 * User Command Handler
 * 
 * Handles commands (write operations) for users.
 * The handler orchestrates the domain service and translates
 * between the application and domain layers.
 */
export class UserCommandHandler {
  private readonly logger = createChildLogger({ module: 'UserCommandHandler' });

  constructor(private readonly userService: UserDomainService) {}

  /**
   * Handle CreateUserCommand
   */
  async handleCreateUser(command: CreateUserCommand): Promise<User> {
    this.logger.info({ command }, 'Handling CreateUserCommand');
    
    const { email, username, password, firstName, lastName } = command.toObject();
    
    // In a real system, password would be hashed here
    // For now, we'll simulate hashing
    const passwordHash = `hash_${password}_${Date.now()}`;
    
    const user = await this.userService.registerUser({
      email,
      username,
      firstName,
      lastName,
      passwordHash,
    });
    
    this.logger.info({ userId: user.id }, 'User created successfully');
    return user;
  }

  /**
   * Deactivate a user
   */
  async handleDeactivateUser(userId: string): Promise<void> {
    this.logger.info({ userId }, 'Handling deactivate user');
    await this.userService.deactivateUser(userId);
    this.logger.info({ userId }, 'User deactivated successfully');
  }

  /**
   * Reactivate a user
   */
  async handleReactivateUser(userId: string): Promise<void> {
    this.logger.info({ userId }, 'Handling reactivate user');
    await this.userService.reactivateUser(userId);
    this.logger.info({ userId }, 'User reactivated successfully');
  }

  /**
   * Update user profile
   */
  async handleUpdateProfile(
    userId: string,
    firstName: string,
    lastName: string
  ): Promise<User> {
    this.logger.info({ userId, firstName, lastName }, 'Handling update profile');
    return await this.userService.updateProfile(userId, { firstName, lastName });
  }
}

/**
 * User Query Handler
 * 
 * Handles queries (read operations) for users.
 * Queries should be fast and not modify state.
 */
export class UserQueryHandler {
  private readonly logger = createChildLogger({ module: 'UserQueryHandler' });

  constructor(private readonly userService: UserDomainService) {}

  /**
   * Handle GetUserQuery
   */
  async handleGetUser(query: GetUserQuery): Promise<UserResponse | null> {
    this.logger.debug({ userId: query.userId }, 'Handling GetUserQuery');
    
    const user = await this.userService.getUserById(query.userId);
    
    if (!user) {
      this.logger.debug({ userId: query.userId }, 'User not found');
      return null;
    }
    
    return this.mapToResponse(user);
  }

  /**
   * Get user by email
   */
  async handleGetUserByEmail(email: string): Promise<UserResponse | null> {
    this.logger.debug({ email }, 'Handling GetUserByEmail');
    
    const user = await this.userService.getUserByEmail(email);
    
    if (!user) {
      return null;
    }
    
    return this.mapToResponse(user);
  }

  /**
   * Map domain entity to response DTO
   * 
   * This ensures we don't leak domain internals to the API layer.
   * Password hashes and other internal data are excluded.
   */
  private mapToResponse(user: User): UserResponse {
    return {
      id: user.id,
      email: user.email,
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.fullName,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
      lastLoginAt: user.lastLoginAt,
    };
  }
}
```

#### Step 6: Infrastructure - In-Memory Repository (For Testing)

**File:** `packages/gateway/src/infrastructure/adapters/persistence/in-memory/user.repository.ts`

```typescript
import { User } from '../../../../core/domain/entities/user.entity.js';
import { IUserRepository } from '../../../../core/domain/repositories/user.repository.port.js';
import { UserProps } from '../../../../core/domain/entities/user.entity.js';

/**
 * In-Memory User Repository
 * 
 * Implements IUserRepository using an in-memory store.
 * Useful for:
 * - Testing (fast, isolated)
 * - Development (no database needed)
 * - Demos (self-contained)
 */
export class InMemoryUserRepository implements IUserRepository {
  private users: Map<string, User> = new Map();

  async save(user: User): Promise<User> {
    this.users.set(user.id, user);
    return user;
  }

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) || null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const normalizedEmail = email.toLowerCase();
    for (const user of this.users.values()) {
      if (user.email.toLowerCase() === normalizedEmail) {
        return user;
      }
    }
    return null;
  }

  async findByUsername(username: string): Promise<User | null> {
    const normalizedUsername = username.toLowerCase();
    for (const user of this.users.values()) {
      if (user.username.toLowerCase() === normalizedUsername) {
        return user;
      }
    }
    return null;
  }

  async findAll(
    criteria: Partial<UserProps>,
    limit?: number,
    offset?: number
  ): Promise<User[]> {
    let results: User[] = [];
    
    // Filter by criteria
    for (const user of this.users.values()) {
      let matches = true;
      
      for (const [key, value] of Object.entries(criteria)) {
        if (value !== undefined && (user as any)[key] !== value) {
          matches = false;
          break;
        }
      }
      
      if (matches) {
        results.push(user);
      }
    }
    
    // Apply pagination
    if (offset !== undefined) {
      results = results.slice(offset);
    }
    if (limit !== undefined) {
      results = results.slice(0, limit);
    }
    
    return results;
  }

  async delete(id: string): Promise<boolean> {
    return this.users.delete(id);
  }

  async existsByEmail(email: string): Promise<boolean> {
    const user = await this.findByEmail(email);
    return user !== null;
  }

  async existsByUsername(username: string): Promise<boolean> {
    const user = await this.findByUsername(username);
    return user !== null;
  }

  async count(criteria: Partial<UserProps>): Promise<number> {
    const results = await this.findAll(criteria);
    return results.length;
  }

  /**
   * Clear the repository (for testing)
   */
  clear(): void {
    this.users.clear();
  }

  /**
   * Get total count of users (for testing)
   */
  size(): number {
    return this.users.size;
  }
}
```

#### Step 7: HTTP Adapter (Controller)

**File:** `packages/gateway/src/infrastructure/adapters/http/user.controller.ts`

```typescript
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { UserCommandHandler, UserQueryHandler } from '../../../core/application/handlers/user.handlers.js';
import { CreateUserCommand } from '../../../core/application/commands/create-user.command.js';
import { GetUserQuery } from '../../../core/application/queries/get-user.query.js';
import { createChildLogger } from '../../../logger.js';

/**
 * User HTTP Controller
 * 
 * This is an adapter that translates HTTP requests into application commands/queries.
 * It knows about HTTP but doesn't contain business logic.
 * It delegates to the application layer for actual work.
 */
export class UserController {
  private readonly logger = createChildLogger({ module: 'UserController' });

  constructor(
    private readonly commandHandler: UserCommandHandler,
    private readonly queryHandler: UserQueryHandler
  ) {}

  /**
   * Register routes with Fastify
   */
  registerRoutes(server: FastifyInstance): void {
    server.post('/api/users', this.createUser.bind(this));
    server.get('/api/users/:userId', this.getUser.bind(this));
    server.put('/api/users/:userId', this.updateUser.bind(this));
    server.delete('/api/users/:userId', this.deactivateUser.bind(this));
    server.post('/api/users/:userId/reactivate', this.reactivateUser.bind(this));
  }

  /**
   * POST /api/users - Create a new user
   */
  private async createUser(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    try {
      this.logger.debug({ body: request.body }, 'Creating user');
      
      // Validate and create command
      const command = CreateUserCommand.create(request.body);
      
      // Execute command
      const user = await this.commandHandler.handleCreateUser(command);
      
      // Return response
      reply.code(201).send({
        success: true,
        data: user.toJSON(),
        message: 'User created successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to create user');
      throw error; // Let global error handler deal with it
    }
  }

  /**
   * GET /api/users/:userId - Get a user by ID
   */
  private async getUser(
    request: FastifyRequest<{ Params: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { userId } = request.params;
      this.logger.debug({ userId }, 'Getting user');
      
      // Create query
      const query = GetUserQuery.create({ userId });
      
      // Execute query
      const user = await this.queryHandler.handleGetUser(query);
      
      if (!user) {
        reply.code(404).send({
          success: false,
          message: 'User not found',
        });
        return;
      }
      
      reply.code(200).send({
        success: true,
        data: user,
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to get user');
      throw error;
    }
  }

  /**
   * PUT /api/users/:userId - Update user profile
   */
  private async updateUser(
    request: FastifyRequest<{ Params: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { userId } = request.params;
      const { firstName, lastName } = request.body as { firstName: string; lastName: string };
      
      this.logger.debug({ userId, firstName, lastName }, 'Updating user');
      
      const user = await this.commandHandler.handleUpdateProfile(
        userId,
        firstName,
        lastName
      );
      
      reply.code(200).send({
        success: true,
        data: user.toJSON(),
        message: 'User updated successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to update user');
      throw error;
    }
  }

  /**
   * DELETE /api/users/:userId - Deactivate user
   */
  private async deactivateUser(
    request: FastifyRequest<{ Params: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { userId } = request.params;
      this.logger.debug({ userId }, 'Deactivating user');
      
      await this.commandHandler.handleDeactivateUser(userId);
      
      reply.code(200).send({
        success: true,
        message: 'User deactivated successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to deactivate user');
      throw error;
    }
  }

  /**
   * POST /api/users/:userId/reactivate - Reactivate user
   */
  private async reactivateUser(
    request: FastifyRequest<{ Params: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { userId } = request.params;
      this.logger.debug({ userId }, 'Reactivating user');
      
      await this.commandHandler.handleReactivateUser(userId);
      
      reply.code(200).send({
        success: true,
        message: 'User reactivated successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to reactivate user');
      throw error;
    }
  }
}
```

#### Step 8: Dependency Injection Container

**File:** `packages/gateway/src/infrastructure/di/container.ts`

```typescript
import { UserDomainService } from '../../core/domain/services/user.service.js';
import { TaskDomainService } from '../../core/domain/services/task.service.js';
import { UserCommandHandler, UserQueryHandler } from '../../core/application/handlers/user.handlers.js';
import { UserController } from '../adapters/http/user.controller.js';
import { InMemoryUserRepository } from '../adapters/persistence/in-memory/user.repository.js';
import { IUserRepository, USER_REPOSITORY } from '../../core/domain/repositories/user.repository.port.js';
import { ITaskRepository, TASK_REPOSITORY } from '../../core/domain/repositories/task.repository.port.js';
import { InMemoryTaskRepository } from '../adapters/persistence/in-memory/task.repository.js';

/**
 * Dependency Injection Container
 * 
 * This is a simple DI container that manages the dependencies.
 * In a real application, you might use a library like InversifyJS or TypeDI.
 * 
 * The container follows the Dependency Inversion Principle:
 * - High-level modules (domain) depend on abstractions (ports)
 * - Low-level modules (infrastructure) depend on the same abstractions
 * - The container wires everything together
 */
export class Container {
  private static instance: Container;
  
  // Dependencies
  private userRepository!: IUserRepository;
  private taskRepository!: ITaskRepository;
  private userDomainService!: UserDomainService;
  private taskDomainService!: TaskDomainService;
  private userCommandHandler!: UserCommandHandler;
  private userQueryHandler!: UserQueryHandler;
  private userController!: UserController;

  private constructor() {
    this.build();
  }

  /**
   * Get singleton instance
   */
  static getInstance(): Container {
    if (!Container.instance) {
      Container.instance = new Container();
    }
    return Container.instance;
  }

  /**
   * Build all dependencies
   * 
   * This follows the composition root pattern:
   * All dependencies are wired up in one place.
   */
  private build(): void {
    // Repositories (Infrastructure)
    // For development, we use in-memory repositories
    // In production, these would be swapped for PostgreSQL/Redis implementations
    this.userRepository = new InMemoryUserRepository();
    this.taskRepository = new InMemoryTaskRepository();

    // Domain Services (Domain Layer)
    this.userDomainService = new UserDomainService(this.userRepository);
    this.taskDomainService = new TaskDomainService(this.taskRepository, this.userRepository);

    // Application Handlers (Application Layer)
    this.userCommandHandler = new UserCommandHandler(this.userDomainService);
    this.userQueryHandler = new UserQueryHandler(this.userDomainService);

    // HTTP Controllers (Infrastructure - Adapters)
    this.userController = new UserController(
      this.userCommandHandler,
      this.userQueryHandler
    );
  }

  /**
   * Get a dependency from the container
   * 
   * Using symbols for dependency injection provides
   * type safety and avoids string-based lookups.
   */
  get<T>(token: symbol): T {
    switch (token) {
      case USER_REPOSITORY:
        return this.userRepository as T;
      case TASK_REPOSITORY:
        return this.taskRepository as T;
      default:
        throw new Error(`No dependency found for token: ${token.toString()}`);
    }
  }

  /**
   * Get the user controller
   */
  getUserController(): UserController {
    return this.userController;
  }

  /**
   * Get the user command handler (for testing)
   */
  getUserCommandHandler(): UserCommandHandler {
    return this.userCommandHandler;
  }

  /**
   * Get the user query handler (for testing)
   */
  getUserQueryHandler(): UserQueryHandler {
    return this.userQueryHandler;
  }

  /**
   * Reset the container (for testing)
   */
  reset(): void {
    if (this.userRepository instanceof InMemoryUserRepository) {
      this.userRepository.clear();
    }
    if (this.taskRepository instanceof InMemoryTaskRepository) {
      this.taskRepository.clear();
    }
  }
}
```

#### Step 9: Update Server to Use Container

**File:** `packages/gateway/src/server.ts` (Updated sections)

```typescript
// Add these imports at the top
import { Container } from './infrastructure/di/container.js';
import { UserController } from './infrastructure/adapters/http/user.controller.js';

// In the constructor, after setupMiddleware()
private setupControllers(): void {
  this.logger.info('Setting up controllers...');
  
  const container = Container.getInstance();
  
  // Register user controller
  const userController = container.getUserController();
  userController.registerRoutes(this.app);
  
  this.logger.info('Controllers registered');
}

// Call setupControllers() in constructor after registerRoutes()
```

### 4. The Verification

Let's test our Hexagonal Architecture implementation.

#### Step 1: Install Dependencies

```bash
cd packages/gateway
npm install
```

#### Step 2: Run Tests

Create a simple test file:

**File:** `packages/gateway/tests/unit/user.entity.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { User } from '../../src/core/domain/entities/user.entity.js';

describe('User Entity', () => {
  it('should create a valid user', () => {
    const user = new User({
      email: 'test@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      passwordHash: 'hashed_password_123',
    });

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
    const user = new User({
      email: 'test@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      passwordHash: 'hash',
    });

    user.updateProfile('John', 'Doe');
    expect(user.firstName).toBe('John');
    expect(user.lastName).toBe('Doe');
    expect(user.fullName).toBe('John Doe');
  });

  it('should deactivate and reactivate', () => {
    const user = new User({
      email: 'test@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      passwordHash: 'hash',
    });

    expect(user.isActive).toBe(true);
    
    user.deactivate();
    expect(user.isActive).toBe(false);
    
    user.reactivate();
    expect(user.isActive).toBe(true);
  });
});
```

Run the tests:

```bash
npm test
```

Expected output:
```
✓ User Entity (4 tests) 4ms
```

#### Step 3: Test the API

Start the server:

```bash
npm run dev
```

**Create a User (POST /api/users):**

```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "username": "john_doe",
    "password": "SecurePass123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

Expected response:
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john@example.com",
    "username": "john_doe",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "createdAt": "2024-01-15T10:30:50.123Z",
    "updatedAt": "2024-01-15T10:30:50.123Z",
    "isActive": true,
    "lastLoginAt": null
  },
  "message": "User created successfully"
}
```

**Get User (GET /api/users/:id):**

```bash
# Replace {userId} with the ID from the previous response
curl http://localhost:3000/api/users/{userId}
```

Expected response:
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john@example.com",
    "username": "john_doe",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "createdAt": "2024-01-15T10:30:50.123Z",
    "updatedAt": "2024-01-15T10:30:50.123Z",
    "isActive": true,
    "lastLoginAt": null
  }
}
```

**Test Validation:**

```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "username": "j",
    "password": "short",
    "firstName": "",
    "lastName": ""
  }'
```

Expected response (400 Bad Request):
```json
{
  "statusCode": 400,
  "error": "Validation Error",
  "message": "Invalid request data",
  "errors": [
    {
      "path": "email",
      "message": "Invalid email format",
      "code": "invalid_string"
    },
    {
      "path": "username",
      "message": "Username must be at least 3 characters",
      "code": "too_small"
    },
    {
      "path": "password",
      "message": "Password must be at least 8 characters",
      "code": "too_small"
    }
  ]
}
```

### 5. Deep Dive: Hexagonal Architecture Principles

#### The Dependency Rule

The Dependency Rule states that source code dependencies can only point inward. This is the heart of Hexagonal Architecture:

```
OUTER LAYER (Infrastructure)
    ↓ depends on
MIDDLE LAYER (Application)
    ↓ depends on
INNER LAYER (Domain)
```

**Why This Matters:**

1. **Testability:** You can test the domain without any infrastructure
2. **Flexibility:** You can swap out database, cache, or HTTP framework easily
3. **Clarity:** Business logic is isolated from technical concerns
4. **Maintainability:** Changes in one layer don't affect others

#### Ports vs Adapters

**Ports (Interfaces):**
- Define what the core expects from the outside world
- Are part of the domain language
- Example: `IUserRepository` interface

**Adapters (Implementations):**
- Implement the ports for specific technologies
- Convert between the outside world and the domain
- Example: `InMemoryUserRepository`, `PostgresUserRepository`

#### Command Query Responsibility Segregation (CQRS)

We've implemented a simple form of CQRS:
- **Commands:** Write operations (`CreateUserCommand`)
- **Queries:** Read operations (`GetUserQuery`)
- **Handlers:** Process commands and queries

This separation allows:
- Different models for reads and writes (optimized for each)
- Independent scaling
- Clearer code organization

### 6. Summary

**What We Built:**
- ✅ Domain entities with business logic
- ✅ Repository ports (interfaces)
- ✅ Domain services for complex business logic
- ✅ Application layer with commands, queries, and handlers
- ✅ Infrastructure adapters (in-memory repositories, HTTP controllers)
- ✅ Dependency injection container
- ✅ Complete API endpoints for user management

**Key Concepts Learned:**
- Hexagonal Architecture (Ports & Adapters)
- Dependency Inversion Principle
- Domain-Driven Design concepts
- CQRS (Commands and Queries)
- Clean separation of concerns
- Testability through abstraction

**What's Next:**
In Part 2 of Phase 2, we'll add PostgreSQL persistence, implement real database repositories, and add integration tests to verify our architecture works with actual infrastructure.

**Verification Checklist:**
- [ ] User entity passes all tests
- [ ] In-memory repository works
- [ ] User API endpoints work
- [ ] Validation catches invalid input
- [ ] Error handling returns proper responses
- [ ] Dependencies are properly inverted

