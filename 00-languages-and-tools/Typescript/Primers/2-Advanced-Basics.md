# TypeScript Primer 2: Advanced Basics

## Going Deeper with TypeScript Fundamentals

---

# Introduction

## What This Primer Covers

This primer builds on the first primer, diving deeper into TypeScript's type system and practical patterns. It's designed for developers who have completed the first primer or have basic TypeScript experience.

**By the end of this primer, you will:**
- Master type narrowing techniques
- Work confidently with interfaces and type aliases
- Understand and use key utility types
- Write type-safe code with generics
- Handle errors and edge cases properly

**Time to complete:** 35 minutes

---

# Section 1: Advanced Type Narrowing

## What is Type Narrowing?

Type narrowing is TypeScript's ability to understand what type a value is based on how you check it. When you check a value's type, TypeScript "narrows" the possible types.

## `typeof` Type Guards

```typescript
function processValue(value: string | number | boolean): string {
    // TypeScript doesn't know what type value is yet
    
    if (typeof value === 'string') {
        // TypeScript KNOWS value is a string here
        return value.toUpperCase();
    }
    
    if (typeof value === 'number') {
        // TypeScript KNOWS value is a number here
        return value.toFixed(2);
    }
    
    // TypeScript KNOWS value is a boolean here
    return value ? 'true' : 'false';
}

// Usage
console.log(processValue("hello"));   // "HELLO"
console.log(processValue(42.123));    // "42.12"
console.log(processValue(true));      // "true"
```

## Equality Narrowing

```typescript
type Status = 'pending' | 'active' | 'completed' | 'archived';

function getStatusMessage(status: Status): string {
    if (status === 'pending') {
        return '⏳ Waiting for approval...';
    }
    
    if (status === 'active') {
        return '✅ Currently active';
    }
    
    if (status === 'completed') {
        return '🎯 Completed successfully';
    }
    
    // TypeScript knows status must be 'archived' here
    return '📦 Archived';
}
```

## Truthiness Narrowing

```typescript
interface Task {
    id: string;
    title: string;
    description?: string;
    dueDate?: Date;
}

function getTaskDescription(task: Task | null): string {
    // If task is null or undefined, handle it
    if (!task) {
        return 'No task provided';
    }
    
    // TypeScript KNOWS task exists here
    if (!task.description) {
        return 'No description available';
    }
    
    // TypeScript KNOWS description exists here
    return task.description.toUpperCase();
}

// Usage
const task: Task = {
    id: '1',
    title: 'Test Task',
    description: 'This is a test'
};

console.log(getTaskDescription(task));         // "THIS IS A TEST"
console.log(getTaskDescription(null));         // "No task provided"
console.log(getTaskDescription({ ...task, description: undefined })); // "No description available"
```

## `in` Operator Narrowing

```typescript
interface TaskWithPriority {
    id: string;
    title: string;
    priority: 'low' | 'medium' | 'high';
}

interface TaskWithDueDate {
    id: string;
    title: string;
    dueDate: Date;
}

// Type predicate - tells TypeScript the type after checking
function hasPriority(task: TaskWithPriority | TaskWithDueDate): task is TaskWithPriority {
    return 'priority' in task;
}

function processTask(task: TaskWithPriority | TaskWithDueDate): string {
    if (hasPriority(task)) {
        // TypeScript knows this is TaskWithPriority
        return `Priority: ${task.priority}`;
    } else {
        // TypeScript knows this is TaskWithDueDate
        return `Due: ${task.dueDate.toDateString()}`;
    }
}
```

## `instanceof` Narrowing

```typescript
class Project {
    constructor(public name: string, public id: string) {}
}

class Team {
    constructor(public name: string, public members: string[]) {}
}

function processEntity(entity: Project | Team): string {
    if (entity instanceof Project) {
        // TypeScript knows this is a Project
        return `Project: ${entity.name} (${entity.id})`;
    }
    
    // TypeScript knows this is a Team
    return `Team: ${entity.name} (${entity.members.join(', ')})`;
}
```

## Discriminated Unions

This is a powerful pattern using a common property to distinguish between types:

```typescript
type TaskEvent =
    | { type: 'created'; taskId: string; timestamp: Date }
    | { type: 'completed'; taskId: string; completedAt: Date }
    | { type: 'deleted'; taskId: string; reason?: string };

function handleTaskEvent(event: TaskEvent): string {
    switch (event.type) {
        case 'created':
            // TypeScript knows this has taskId and timestamp
            return `Task ${event.taskId} created at ${event.timestamp.toLocaleString()}`;
            
        case 'completed':
            // TypeScript knows this has taskId and completedAt
            return `Task ${event.taskId} completed at ${event.completedAt.toLocaleString()}`;
            
        case 'deleted':
            // TypeScript knows this has taskId and optional reason
            return `Task ${event.taskId} deleted${event.reason ? `: ${event.reason}` : ''}`;
            
        default:
            // This ensures all cases are handled
            const exhaustiveCheck: never = event;
            return exhaustiveCheck;
    }
}

// Usage
const event: TaskEvent = {
    type: 'created',
    taskId: 'task_123',
    timestamp: new Date()
};

console.log(handleTaskEvent(event));
// "Task task_123 created at 1/27/2026, 12:00:00 PM"
```

---

# Section 2: Interfaces vs. Type Aliases

## The Short Answer

- Use **interface** when you need to extend or implement
- Use **type** for everything else

## Interfaces in Depth

### Extending Interfaces

```typescript
// Base interface
interface Animal {
    name: string;
    age: number;
}

// Extending
interface Dog extends Animal {
    breed: string;
    bark(): void;
}

// Multiple inheritance
interface Pet {
    owner: string;
}

interface DogWithOwner extends Dog, Pet {
    // Combines everything from Dog and Pet
}

// Usage
const myDog: DogWithOwner = {
    name: 'Rex',
    age: 3,
    breed: 'German Shepherd',
    owner: 'Alice',
    bark() {
        console.log('Woof!');
    }
};
```

### Declaration Merging

```typescript
// First declaration
interface Task {
    id: string;
    title: string;
}

// Second declaration (adds to the interface)
interface Task {
    description?: string;
    createdAt: Date;
}

// Now Task has: id, title, description, createdAt
const task: Task = {
    id: '1',
    title: 'Test',
    description: 'Optional',
    createdAt: new Date()
};
```

### Classes Implementing Interfaces

```typescript
interface Printable {
    print(): void;
}

interface Savable {
    save(): Promise<void>;
}

class Document implements Printable, Savable {
    constructor(public content: string) {}
    
    print(): void {
        console.log(this.content);
    }
    
    async save(): Promise<void> {
        // Save to database
        console.log('Saving document...');
    }
}
```

## Type Aliases in Depth

### Union Types

```typescript
type Status = 'draft' | 'published' | 'archived';
type ID = string | number;
type Value = string | number | boolean | null | undefined;
```

### Intersection Types

```typescript
type WithTimestamps = {
    createdAt: Date;
    updatedAt: Date;
};

type WithId = {
    id: string;
};

type Entity = WithId & WithTimestamps;

// Equivalent to:
// type Entity = {
//     id: string;
//     createdAt: Date;
//     updatedAt: Date;
// };
```

### Conditional Types with Type Aliases

```typescript
type TypeName<T> =
    T extends string ? 'string' :
    T extends number ? 'number' :
    T extends boolean ? 'boolean' :
    T extends undefined ? 'undefined' :
    T extends null ? 'null' :
    T extends Array<any> ? 'array' :
    T extends Function ? 'function' :
    'object';

type Test1 = TypeName<string>;  // 'string'
type Test2 = TypeName<number[]>; // 'array'
type Test3 = TypeName<() => void>; // 'function'
```

## When to Use Which

| Scenario | Use Interface | Use Type |
|----------|---------------|----------|
| Object shape | ✅ Yes | ✅ Yes |
| Extending/implementing | ✅ Yes | ⚠️ Limited |
| Declaration merging | ✅ Yes | ❌ No |
| Union types | ❌ No | ✅ Yes |
| Mapped types | ❌ No | ✅ Yes |
| Conditional types | ❌ No | ✅ Yes |
| Primitive types | ❌ No | ✅ Yes |

---

# Section 3: Key Utility Types

## `Partial<T>` - Make All Properties Optional

```typescript
interface Task {
    id: string;
    title: string;
    description: string;
    completed: boolean;
}

// All properties become optional
type PartialTask = Partial<Task>;

// Now you can create a task with only some properties
const updateData: PartialTask = {
    title: 'Updated title',
    completed: true
    // id, description are optional
};
```

## `Required<T>` - Make All Properties Required

```typescript
interface OptionalTask {
    id?: string;
    title?: string;
    description?: string;
}

// All properties become required
type RequiredTask = Required<OptionalTask>;
// Now id, title, and description must exist
```

## `Readonly<T>` - Make All Properties Read-Only

```typescript
interface Config {
    apiUrl: string;
    timeout: number;
}

// All properties become read-only
type ReadonlyConfig = Readonly<Config>;

const config: ReadonlyConfig = {
    apiUrl: 'https://api.example.com',
    timeout: 5000
};

// config.apiUrl = 'new-url'; // ❌ Error: Cannot assign to read-only property
```

## `Pick<T, K>` - Select Specific Properties

```typescript
interface User {
    id: string;
    name: string;
    email: string;
    password: string;
    age: number;
    role: 'admin' | 'user';
}

// Pick only the properties you want
type PublicUser = Pick<User, 'id' | 'name' | 'email' | 'role'>;

const publicUser: PublicUser = {
    id: 'user_123',
    name: 'Alice',
    email: 'alice@example.com',
    role: 'user'
    // password and age are not included
};
```

## `Omit<T, K>` - Exclude Specific Properties

```typescript
interface User {
    id: string;
    name: string;
    email: string;
    password: string;
    age: number;
    role: 'admin' | 'user';
}

// Omit sensitive properties
type SafeUser = Omit<User, 'password' | 'age'>;

const safeUser: SafeUser = {
    id: 'user_123',
    name: 'Alice',
    email: 'alice@example.com',
    role: 'user'
    // password and age are excluded
};
```

## `Record<K, T>` - Create Key-Value Maps

```typescript
// A map from user IDs to user names
type UserMap = Record<string, string>;

const userNames: UserMap = {
    'user_1': 'Alice',
    'user_2': 'Bob',
    'user_3': 'Charlie'
};

// A map with specific keys
type StatusColors = Record<'pending' | 'active' | 'completed', string>;

const statusColors: StatusColors = {
    pending: 'yellow',
    active: 'green',
    completed: 'blue'
    // No other keys allowed
};
```

## `Exclude<T, U>` - Remove Union Members

```typescript
type AllStatus = 'pending' | 'active' | 'completed' | 'archived';

// Exclude 'archived' from the union
type ActiveStatus = Exclude<AllStatus, 'archived'>;
// ActiveStatus is 'pending' | 'active' | 'completed'

// Exclude multiple
type InProgressStatus = Exclude<AllStatus, 'completed' | 'archived'>;
// InProgressStatus is 'pending' | 'active'
```

## `Extract<T, U>` - Keep Only Specified Union Members

```typescript
type AllStatus = 'pending' | 'active' | 'completed' | 'archived';

// Keep only 'active' and 'completed'
type FinishedStatus = Extract<AllStatus, 'active' | 'completed'>;
// FinishedStatus is 'active' | 'completed'
```

## `ReturnType<T>` - Get Function Return Type

```typescript
function createTask(title: string): { id: string; title: string; createdAt: Date } {
    return {
        id: `task_${Date.now()}`,
        title,
        createdAt: new Date()
    };
}

type TaskResult = ReturnType<typeof createTask>;
// TaskResult is { id: string; title: string; createdAt: Date }

// Usage
const task: TaskResult = createTask('Write code');
```

## `Parameters<T>` - Get Function Parameters

```typescript
function createTask(title: string, priority: 'low' | 'medium' | 'high' = 'medium'): void {
    // ...
}

type CreateTaskParams = Parameters<typeof createTask>;
// CreateTaskParams is [string, ('low' | 'medium' | 'high')?]
```

## `NonNullable<T>` - Remove null and undefined

```typescript
type MaybeString = string | null | undefined;
type DefinitelyString = NonNullable<MaybeString>;
// DefinitelyString is string

type MaybeUser = User | null;
type UserNonNullable = NonNullable<MaybeUser>;
// UserNonNullable is User
```

---

# Section 4: Advanced Generics

## Generic Constraints

Sometimes you need to restrict what types can be used with a generic:

```typescript
// Only allow types that have a 'name' property
function getName<T extends { name: string }>(item: T): string {
    return item.name;
}

// Works with any object that has 'name'
const task = { name: 'Task 1', id: '1' };
console.log(getName(task)); // "Task 1"

// ❌ Error: number doesn't have a 'name' property
// console.log(getName(42));

// Only allow types that have an 'id' property
function getItemId<T extends { id: string | number }>(item: T): string {
    return String(item.id);
}
```

## Generic Default Types

```typescript
// Default to string if no type is specified
function createArray<T = string>(length: number, value: T): T[] {
    return Array(length).fill(value);
}

// Uses the default (string)
const strings = createArray(3, 'hello'); // string[]

// Override the default
const numbers = createArray<number>(3, 42); // number[]
```

## Multiple Generic Types

```typescript
// Multiple type parameters
function zip<T, U>(first: T[], second: U[]): [T, U][] {
    const result: [T, U][] = [];
    const length = Math.min(first.length, second.length);
    
    for (let i = 0; i < length; i++) {
        result.push([first[i], second[i]]);
    }
    
    return result;
}

const zipped = zip([1, 2, 3], ['a', 'b', 'c']);
// zipped is [number, string][]
```

## Generic with `keyof`

```typescript
// Type-safe property access
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

const user = {
    id: '1',
    name: 'Alice',
    age: 30
};

const name = getProperty(user, 'name'); // TypeScript knows this is string
const age = getProperty(user, 'age');   // TypeScript knows this is number
// getProperty(user, 'email'); // ❌ Error: email does not exist on user
```

---

# Section 5: Error Handling with TypeScript

## Union Type for Error Handling

```typescript
type Result<T> = 
    | { success: true; data: T }
    | { success: false; error: string };

function fetchData(id: string): Result<{ name: string; age: number }> {
    try {
        // Simulate API call
        if (!id) {
            return { success: false, error: 'ID is required' };
        }
        
        // Mock data
        return {
            success: true,
            data: { name: 'Alice', age: 30 }
        };
    } catch (error) {
        return {
            success: false,
            error: error instanceof Error ? error.message : 'Unknown error'
        };
    }
}

// Usage
const result = fetchData('user_123');

if (result.success) {
    console.log(`Name: ${result.data.name}, Age: ${result.data.age}`);
} else {
    console.error(`Error: ${result.error}`);
}
```

## Custom Error Class

```typescript
class AppError extends Error {
    constructor(
        public code: string,
        message: string,
        public statusCode: number = 500,
        public details?: any
    ) {
        super(message);
        this.name = 'AppError';
    }
}

// Usage
function validateTask(data: any): void {
    if (!data.title) {
        throw new AppError(
            'VALIDATION_ERROR',
            'Title is required',
            400,
            { field: 'title' }
        );
    }
}
```

## Zod for Runtime Validation

```typescript
import { z } from 'zod';

// Define schema
const TaskSchema = z.object({
    id: z.string(),
    title: z.string().min(3).max(100),
    description: z.string().optional(),
    priority: z.enum(['low', 'medium', 'high']),
    dueDate: z.coerce.date().optional()
});

// Infer type from schema
type Task = z.infer<typeof TaskSchema>;

// Validate data
function createTask(data: unknown): Result<Task> {
    const validation = TaskSchema.safeParse(data);
    
    if (!validation.success) {
        return {
            success: false,
            error: validation.error.errors.map(e => e.message).join(', ')
        };
    }
    
    return {
        success: true,
        data: validation.data
    };
}

// Usage
const result = createTask({
    id: '1',
    title: 'Test Task',
    priority: 'high'
});

if (result.success) {
    console.log('Task created:', result.data);
} else {
    console.error('Validation failed:', result.error);
}
```

---

# Section 6: Practical Patterns

## Pattern 1: Type-Safe Event Handlers

```typescript
type EventMap = {
    click: { x: number; y: number };
    keydown: { key: string; code: string };
    resize: { width: number; height: number };
};

type EventHandler<K extends keyof EventMap> = (data: EventMap[K]) => void;

class EventBus {
    private handlers = new Map<keyof EventMap, Set<EventHandler<any>>>();
    
    subscribe<K extends keyof EventMap>(
        event: K,
        handler: EventHandler<K>
    ): () => void {
        if (!this.handlers.has(event)) {
            this.handlers.set(event, new Set());
        }
        
        const handlers = this.handlers.get(event)!;
        handlers.add(handler);
        
        return () => {
            handlers.delete(handler);
        };
    }
    
    emit<K extends keyof EventMap>(event: K, data: EventMap[K]): void {
        const handlers = this.handlers.get(event);
        if (!handlers) return;
        
        for (const handler of handlers) {
            handler(data);
        }
    }
}

// Usage
const bus = new EventBus();

bus.subscribe('click', (data) => {
    console.log(`Clicked at (${data.x}, ${data.y})`);
});

bus.emit('click', { x: 100, y: 200 });
```

## Pattern 2: Type-Safe Repository

```typescript
interface Entity {
    id: string;
}

class Repository<T extends Entity> {
    private items: Map<string, T> = new Map();
    
    create(item: Omit<T, 'id'>): T {
        const id = `item_${Date.now()}`;
        const newItem = { ...item, id } as T;
        this.items.set(id, newItem);
        return newItem;
    }
    
    findById(id: string): T | undefined {
        return this.items.get(id);
    }
    
    findAll(): T[] {
        return Array.from(this.items.values());
    }
    
    update(id: string, updates: Partial<Omit<T, 'id'>>): T | undefined {
        const existing = this.items.get(id);
        if (!existing) return undefined;
        
        const updated = { ...existing, ...updates };
        this.items.set(id, updated);
        return updated;
    }
    
    delete(id: string): boolean {
        return this.items.delete(id);
    }
    
    find(predicate: (item: T) => boolean): T[] {
        const result: T[] = [];
        for (const item of this.items.values()) {
            if (predicate(item)) {
                result.push(item);
            }
        }
        return result;
    }
}

// Usage
interface Task extends Entity {
    title: string;
    completed: boolean;
}

const taskRepo = new Repository<Task>();

const task = taskRepo.create({
    title: 'Write TypeScript primer',
    completed: false
});

const found = taskRepo.findById(task.id);
console.log(found?.title); // "Write TypeScript primer"

const tasks = taskRepo.find(t => t.completed === false);
console.log(tasks.length); // 1
```

## Pattern 3: Type-Safe API Client

```typescript
interface ApiResponse<T> {
    data: T;
    status: number;
    timestamp: string;
}

class ApiClient {
    constructor(private baseUrl: string) {}
    
    async get<T>(path: string): Promise<ApiResponse<T>> {
        const response = await fetch(`${this.baseUrl}${path}`);
        const data = await response.json();
        
        return {
            data: data as T,
            status: response.status,
            timestamp: new Date().toISOString()
        };
    }
    
    async post<T, V>(path: string, body: V): Promise<ApiResponse<T>> {
        const response = await fetch(`${this.baseUrl}${path}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(body)
        });
        
        const data = await response.json();
        
        return {
            data: data as T,
            status: response.status,
            timestamp: new Date().toISOString()
        };
    }
}

// Usage
const client = new ApiClient('https://api.example.com');

// Type-safe API call
interface User {
    id: string;
    name: string;
    email: string;
}

const user = await client.get<User>('/users/123');
console.log(user.data.name); // TypeScript knows this is string
```

---

# Practice Exercises

## Exercise 1: Type Narrowing

Write a function that processes different types of tasks:

```typescript
type Task = {
    id: string;
    title: string;
    status: 'todo' | 'in-progress' | 'done';
};

type Project = {
    id: string;
    name: string;
    status: 'active' | 'archived' | 'completed';
};

function processItem(item: Task | Project): string {
    // Your code here: Use type narrowing to process differently
}

// Should work for both:
processItem({ id: '1', title: 'Task', status: 'todo' });
processItem({ id: '1', name: 'Project', status: 'active' });
```

## Exercise 2: Utility Types

Create transformed types from this base type:

```typescript
type User = {
    id: string;
    name: string;
    email: string;
    password: string;
    age: number;
    role: 'admin' | 'user' | 'guest';
    createdAt: Date;
};

// Create these types:
// 1. PublicUser - id, name, email, role
// 2. UpdateUser - all fields optional except id
// 3. NewUser - all fields except id, createdAt
// 4. UserWithoutPassword - all fields except password
```

## Exercise 3: Generic Repository

Extend the Repository class to add:
- `findByProperty` - Find items by a property value
- `count` - Get total count
- `exists` - Check if an item exists

## Exercise 4: Error Handling

Create a type-safe error handling system with:
- Custom error types
- Result type pattern
- Error logging

## Exercise 5: Discriminated Union

Create a discriminated union for API responses:

```typescript
// Define types for:
// - Loading state
// - Success state (with data)
// - Error state (with error message)

// Then create a function that handles all states
```

---

# Solutions

## Exercise 1: Type Narrowing

```typescript
function processItem(item: Task | Project): string {
    if ('title' in item) {
        // This is a Task
        return `Task: ${item.title} (${item.status})`;
    } else {
        // This is a Project
        return `Project: ${item.name} (${item.status})`;
    }
}
```

## Exercise 2: Utility Types

```typescript
type PublicUser = Pick<User, 'id' | 'name' | 'email' | 'role'>;
type UpdateUser = Partial<Omit<User, 'id'>> & { id: string };
type NewUser = Omit<User, 'id' | 'createdAt'>;
type UserWithoutPassword = Omit<User, 'password'>;
```

## Exercise 3: Generic Repository

```typescript
class Repository<T extends Entity> {
    // ... existing methods ...
    
    findByProperty<K extends keyof T>(key: K, value: T[K]): T[] {
        return this.find(item => item[key] === value);
    }
    
    count(): number {
        return this.items.size;
    }
    
    exists(id: string): boolean {
        return this.items.has(id);
    }
}
```

## Exercise 4: Error Handling

```typescript
type Result<T> = 
    | { success: true; data: T }
    | { success: false; error: string };

class AppError extends Error {
    constructor(
        public code: string,
        message: string,
        public statusCode: number = 500
    ) {
        super(message);
        this.name = 'AppError';
    }
}

function handleError(error: unknown): string {
    if (error instanceof AppError) {
        return `[${error.code}] ${error.message}`;
    }
    if (error instanceof Error) {
        return error.message;
    }
    return String(error);
}
```

## Exercise 5: Discriminated Union

```typescript
type ApiState<T> = 
    | { status: 'loading' }
    | { status: 'success'; data: T }
    | { status: 'error'; error: string };

function handleApiState<T>(state: ApiState<T>): string {
    switch (state.status) {
        case 'loading':
            return 'Loading...';
        case 'success':
            return `Data: ${JSON.stringify(state.data)}`;
        case 'error':
            return `Error: ${state.error}`;
        default:
            const exhaustive: never = state;
            return exhaustive;
    }
}
```

---

## What's Next?

This primer covered:
- Advanced type narrowing
- Interfaces vs. type aliases
- Key utility types
- Advanced generics
- Error handling patterns
- Practical TypeScript patterns

**Ready for more?** Proceed to the TypeScript Master Series for comprehensive coverage of:
- Advanced types and type-level programming
- React + TypeScript
- Next.js + TypeScript
- Testing and debugging
- Architecture patterns
