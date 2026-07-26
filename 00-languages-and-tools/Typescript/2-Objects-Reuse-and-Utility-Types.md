# Part 2: Objects, Reuse, and Utility Types

## 2.1 Understanding Interfaces vs. Type Aliases

TypeScript gives us two main ways to define object shapes: `interface` and `type`. They're similar but have important differences. Let's explore when to use each.

### The Interface: A Contract That Can Be Extended

Think of an interface like a contract that says "any object implementing this will have these properties." Interfaces are designed to be extended and augmented.

```typescript
// An interface defines a contract
interface Task {
    id: string;
    title: string;
    completed: boolean;
}

// You can extend an interface (like inheritance)
interface PriorityTask extends Task {
    priority: 'low' | 'medium' | 'high';
}

// You can also add to an existing interface (declaration merging)
interface Task {
    createdAt: Date; // Now Task has id, title, completed, AND createdAt
}
```

### The Type Alias: A Name for Any Type

Type aliases can name any type, not just objects. They're more flexible but don't support extension in the same way.

```typescript
// Type alias for a primitive
type TaskId = string;

// Type alias for an object
type Task = {
    id: TaskId;
    title: string;
    completed: boolean;
};

// Type alias for a union
type TaskStatus = 'todo' | 'in-progress' | 'done';

// Type alias for a function
type TaskHandler = (task: Task) => void;

// Type alias can combine types with intersections
type DetailedTask = Task & {
    description: string;
    dueDate: Date;
};
```

### When to Use Each

**Use `interface` when:**
- You're defining an object that will be extended (like a library API)
- You want declaration merging (adding to the same interface in multiple places)
- You're working with classes that implement an interface

**Use `type` when:**
- You're defining a union or intersection
- You need to use mapped types or conditional types
- You're creating a utility type
- You're defining a primitive or function type

💡 **Pro Tip:** In modern TypeScript, the differences are subtle. Many teams use `type` for everything except when they need specific `interface` features. We'll follow this pattern in TaskFlow.

## 2.2 Generics: Reusable, Type-Safe Code

Generics are like templates for types. They let you write code that works with any type while maintaining type safety.

### The Concept: A Container That Remembers What's Inside

Imagine a box that can hold anything. A generic box works the same regardless of what's inside, but it remembers the type of the item it contains.

```typescript
// A generic box that can hold any type
class Box<T> {
    private contents: T;
    
    constructor(initialContents: T) {
        this.contents = initialContents;
    }
    
    getContents(): T {
        return this.contents;
    }
    
    setContents(newContents: T): void {
        this.contents = newContents;
    }
}

// Use with different types
const stringBox = new Box<string>("Hello");
console.log(stringBox.getContents().toUpperCase()); // "HELLO"

const numberBox = new Box<number>(42);
console.log(numberBox.getContents() * 2); // 84

// TypeScript infers the type
const inferredBox = new Box("TypeScript"); // Box<string>
```

### Generic Functions

Functions can also use generics to create flexible, type-safe APIs.

**File:** `src/utils/generics.ts`

```typescript
/**
 * Generic function examples for TaskFlow
 */

// --- Basic Generic Function ---

/**
 * A generic function that returns the same type it receives
 */
function identity<T>(value: T): T {
    return value;
}

// TypeScript infers the type
const id = identity("TaskFlow"); // const id: string

// Or explicitly specify the type
const id2 = identity<number>(123); // const id2: number

// --- Generic Array Operations ---

/**
 * Get the first item from an array
 */
function first<T>(items: T[]): T | undefined {
    return items[0];
}

const numbers = [1, 2, 3];
const firstNumber = first(numbers); // number | undefined

const strings = ["a", "b", "c"];
const firstString = first(strings); // string | undefined

/**
 * A generic filter that works with any type
 */
function filterItems<T>(items: T[], predicate: (item: T) => boolean): T[] {
    const result: T[] = [];
    for (const item of items) {
        if (predicate(item)) {
            result.push(item);
        }
    }
    return result;
}

const tasks = [
    { id: '1', title: 'Task 1', completed: false },
    { id: '2', title: 'Task 2', completed: true },
    { id: '3', title: 'Task 3', completed: false }
];

const incompleteTasks = filterItems(tasks, task => !task.completed);
// TypeScript knows incompleteTasks is of type { id: string, title: string, completed: boolean }[]

// --- Multiple Type Parameters ---

/**
 * A function that maps a key from one object to another
 */
function mapKey<T, K extends keyof T, U>(
    obj: T,
    key: K,
    mapFn: (value: T[K]) => U
): Record<K, U> {
    return { [key]: mapFn(obj[key]) } as Record<K, U>;
}

interface Task {
    id: string;
    title: string;
    priority: 'low' | 'medium' | 'high';
}

const task: Task = {
    id: 'task_1',
    title: 'Write documentation',
    priority: 'high'
};

// Map the priority to a number
const mapped = mapKey(task, 'priority', (p) => {
    const priorities = { low: 1, medium: 2, high: 3 };
    return priorities[p];
});
console.log(mapped); // { priority: 3 }

// --- Generic Constraints ---

/**
 * A function that works with any object that has a 'name' property
 */
function getName<T extends { name: string }>(item: T): string {
    return item.name;
}

// Works with any object that has 'name'
const taskWithName = { name: 'Task 1', id: '1' };
console.log(getName(taskWithName)); // "Task 1"

// ❌ Would error: 'number' doesn't have a 'name' property
// const x = getName(42);

// --- Generic with Default Type ---

function createArray<T = string>(length: number, value: T): T[] {
    return Array(length).fill(value);
}

const strings = createArray(3, 'hello'); // string[]
const numbers = createArray<number>(3, 42); // number[]

// --- Using Generics with Async/Await ---

/**
 * A generic wrapper for API responses
 */
interface ApiResponse<T> {
    data: T;
    status: number;
    timestamp: string;
}

async function fetchData<T>(url: string): Promise<ApiResponse<T>> {
    const response = await fetch(url);
    const data = await response.json();
    
    return {
        data: data as T,
        status: response.status,
        timestamp: new Date().toISOString()
    };
}

// Usage (when we later add real API calls)
// const result = await fetchData<Task[]>('/api/tasks');
// result.data // TypeScript knows this is Task[]

// --- Generic Classes ---

class TaskRepository<T> {
    private items: T[] = [];
    
    add(item: T): void {
        this.items.push(item);
    }
    
    getAll(): T[] {
        return this.items;
    }
    
    find(predicate: (item: T) => boolean): T | undefined {
        return this.items.find(predicate);
    }
}

// Usage with different types
interface Task {
    id: string;
    title: string;
}

const taskRepo = new TaskRepository<Task>();
taskRepo.add({ id: '1', title: 'Task 1' });
taskRepo.add({ id: '2', title: 'Task 2' });

const found = taskRepo.find(task => task.id === '1');
if (found) {
    console.log(found.title); // TypeScript knows found is Task
}

// --- Verification ---

console.log('\n=== Generics Demo ===\n');

console.log('Identity:', identity('Hello'));
console.log('Identity:', identity(42));

console.log('First number:', first(numbers));
console.log('First string:', first(strings));

console.log('Incomplete tasks:', incompleteTasks);

console.log('Mapped priority:', mapped);

console.log('Name:', getName({ name: 'Project 1', id: 'p1' }));

console.log('Array creation:', createArray(3, 'test'));
console.log('Number array:', createArray<number>(3, 42));
```

## 2.3 Built-in Utility Types

TypeScript provides utility types that transform existing types. These are incredibly useful in real applications.

### The Concept: Type Transformers

Think of utility types like tools in a workshop. Each one does a specific transformation on a type.

**File:** `src/types/utilities.ts`

```typescript
/**
 * TypeScript Utility Types in Action
 * These are built-in types that transform other types
 */

// --- Partial: Make all properties optional ---

type Task = {
    id: string;
    title: string;
    description: string;
    completed: boolean;
    priority: 'low' | 'medium' | 'high';
};

// Creates a type where every property is optional
type PartialTask = Partial<Task>;

// Now we can create a task with only some properties
const partialTask: PartialTask = {
    title: 'Update docs',
    completed: true
    // description, id, priority are optional
};

// --- Required: Make all properties required ---

type OptionalTask = {
    id?: string;
    title?: string;
    description?: string;
};

// Makes all optional properties required
type RequiredTask = Required<OptionalTask>;
// Now id, title, and description must exist

// --- Readonly: Make all properties read-only ---

type ImmutableTask = Readonly<Task>;
// const task: ImmutableTask = { ... };
// task.title = "New title"; // ❌ Error: Cannot assign to read-only property

// --- Pick: Select specific properties ---

// Create a type with only the specified properties
type TaskSummary = Pick<Task, 'id' | 'title' | 'priority'>;

const summary: TaskSummary = {
    id: 'task_1',
    title: 'Complete project',
    priority: 'high'
    // description and completed are not included
};

// --- Omit: Exclude specific properties ---

// Create a type without the specified properties
type TaskWithoutId = Omit<Task, 'id' | 'priority'>;

const taskWithoutId: TaskWithoutId = {
    title: 'Write tests',
    description: 'Write unit tests for all components',
    completed: false
    // id and priority are not included
};

// --- Record: Create a type with keys and values ---

// A map from user IDs to user names
type UserMap = Record<string, string>;

const userNames: UserMap = {
    'user_1': 'Alice',
    'user_2': 'Bob',
    'user_3': 'Charlie'
};

// A map from priority to color
type PriorityColors = Record<'low' | 'medium' | 'high', string>;

const priorityColors: PriorityColors = {
    low: 'green',
    medium: 'yellow',
    high: 'red'
};

// --- Exclude: Remove union members ---

type TaskStatus = 'todo' | 'in-progress' | 'review' | 'done';

// Exclude 'done' from the union
type IncompleteStatus = Exclude<TaskStatus, 'done'>;
// Now IncompleteStatus is 'todo' | 'in-progress' | 'review'

// Exclude multiple
type ActiveStatus = Exclude<TaskStatus, 'done' | 'review'>;
// ActiveStatus is 'todo' | 'in-progress'

// --- Extract: Keep only specified union members ---

type StatusWithProgress = Extract<TaskStatus, 'in-progress' | 'review'>;
// StatusWithProgress is 'in-progress' | 'review'

// --- NonNullable: Remove null and undefined ---

type MaybeString = string | null | undefined;
type DefinitelyString = NonNullable<MaybeString>;
// DefinitelyString is string

// --- ReturnType: Get the return type of a function ---

function createTask(title: string): Task {
    return {
        id: 'new_task',
        title: title,
        description: '',
        completed: false,
        priority: 'medium'
    };
}

type CreateTaskResult = ReturnType<typeof createTask>;
// CreateTaskResult is Task

// --- Parameters: Get the parameters of a function as a tuple ---

type CreateTaskParams = Parameters<typeof createTask>;
// CreateTaskParams is [string] (tuple with one string)

// --- Custom Utility Type: DeepReadonly ---

// We can create our own utility types
type DeepReadonly<T> = {
    readonly [P in keyof T]: T[P] extends Record<string, any>
        ? DeepReadonly<T[P]>
        : T[P];
};

interface User {
    id: string;
    profile: {
        name: string;
        email: string;
    };
}

type ImmutableUser = DeepReadonly<User>;
// Everything is readonly, including nested objects

// --- Verification ---

console.log('\n=== Utility Types Demo ===\n');

console.log('PartialTask:', partialTask);
console.log('TaskSummary:', summary);
console.log('TaskWithoutId:', taskWithoutId);
console.log('UserMap:', userNames);
console.log('PriorityColors:', priorityColors);

// Type checking examples
console.log('Immutability test:');
const immutableTask: ImmutableTask = {
    id: 't1',
    title: 'Test',
    description: 'Testing',
    completed: false,
    priority: 'low'
};
// immutableTask.title = "New"; // ❌ Would error if uncommented

console.log('ReturnType example:', {} as CreateTaskResult);
```

## 2.4 Practical Application: Building TaskFlow's Data Layer

Now let's use everything we've learned to build TaskFlow's data management layer.

**File:** `src/data/taskflow-data.ts`

```typescript
/**
 * TaskFlow Data Layer
 * Fully typed data management using generics and utility types
 */

import type {
    Task,
    Project,
    User,
    Comment,
    CreateTaskInput,
    UpdateTaskInput,
    PaginatedResponse
} from '../types/taskflow.js';

// --- Generic Repository Implementation ---

/**
 * A generic repository that provides CRUD operations for any entity
 */
export class Repository<T extends { id: string }> {
    protected items: Map<string, T> = new Map();
    
    // Create: Add a new item
    create(item: Omit<T, 'id'>): T {
        const id = this.generateId();
        const newItem = { ...item, id } as T;
        this.items.set(id, newItem);
        return newItem;
    }
    
    // Read: Get by ID
    findById(id: string): T | undefined {
        return this.items.get(id);
    }
    
    // Read: Get all items
    findAll(): T[] {
        return Array.from(this.items.values());
    }
    
    // Update: Replace an existing item
    update(id: string, updates: Partial<Omit<T, 'id'>>): T | undefined {
        const existing = this.items.get(id);
        if (!existing) return undefined;
        
        const updated = { ...existing, ...updates };
        this.items.set(id, updated);
        return updated;
    }
    
    // Delete: Remove an item
    delete(id: string): boolean {
        return this.items.delete(id);
    }
    
    // Search with generic predicate
    find(predicate: (item: T) => boolean): T[] {
        const result: T[] = [];
        for (const item of this.items.values()) {
            if (predicate(item)) {
                result.push(item);
            }
        }
        return result;
    }
    
    // Pagination support
    findPaginated(
        predicate: (item: T) => boolean,
        page: number = 1,
        limit: number = 10
    ): PaginatedResponse<T> {
        const filtered = this.find(predicate);
        const start = (page - 1) * limit;
        const end = start + limit;
        const paginatedItems = filtered.slice(start, end);
        const totalPages = Math.ceil(filtered.length / limit);
        
        return {
            data: paginatedItems,
            pagination: {
                page,
                limit,
                total: filtered.length,
                totalPages
            }
        };
    }
    
    private generateId(): string {
        return `item_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
}

// --- Specific Repositories for TaskFlow Entities ---

export class TaskRepository extends Repository<Task> {
    // Task-specific methods
    
    findByProject(projectId: string): Task[] {
        return this.find(task => task.projectId === projectId);
    }
    
    findByAssignee(userId: string): Task[] {
        return this.find(task => task.assigneeId === userId);
    }
    
    findByStatus(status: Task['status']): Task[] {
        return this.find(task => task.status === status);
    }
    
    getOverdueTasks(): Task[] {
        const now = new Date();
        return this.find(task => 
            task.dueDate && 
            task.dueDate < now && 
            task.status !== 'done'
        );
    }
    
    // Override update with type safety for Task-specific fields
    update(id: string, updates: UpdateTaskInput): Task | undefined {
        // Remove id from updates if present (should match the id parameter)
        const { id: _, ...cleanUpdates } = updates;
        return super.update(id, cleanUpdates);
    }
}

export class ProjectRepository extends Repository<Project> {
    findByOwner(ownerId: string): Project[] {
        return this.find(project => project.ownerId === ownerId);
    }
    
    findMemberProjects(userId: string): Project[] {
        return this.find(project => project.memberIds.includes(userId));
    }
}

// --- Service Layer with Generics ---

/**
 * A generic service that adds business logic to repositories
 */
export class Service<T extends { id: string }> {
    constructor(private repository: Repository<T>) {}
    
    // Validate before creating
    create(item: Omit<T, 'id'>): T {
        this.validate(item);
        return this.repository.create(item);
    }
    
    // Update with validation
    update(id: string, updates: Partial<Omit<T, 'id'>>): T | undefined {
        this.validate(updates);
        return this.repository.update(id, updates);
    }
    
    // Override for validation
    protected validate(item: any): void {
        // Base validation - override in child classes
        if (!item) {
            throw new Error('Invalid item provided');
        }
    }
}

export class TaskService extends Service<Task> {
    private taskRepo: TaskRepository;
    
    constructor(repository: TaskRepository) {
        super(repository);
        this.taskRepo = repository;
    }
    
    // Task-specific business logic
    assignTask(taskId: string, assigneeId: string): Task | undefined {
        const task = this.taskRepo.findById(taskId);
        if (!task) {
            throw new Error(`Task with ID ${taskId} not found`);
        }
        
        return this.taskRepo.update(taskId, { assigneeId });
    }
    
    completeTask(taskId: string): Task | undefined {
        const task = this.taskRepo.findById(taskId);
        if (!task) {
            throw new Error(`Task with ID ${taskId} not found`);
        }
        
        if (task.status === 'done') {
            throw new Error('Task is already completed');
        }
        
        return this.taskRepo.update(taskId, {
            status: 'done',
            updatedAt: new Date()
        });
    }
    
    // Override validation with Task-specific rules
    protected validate(item: any): void {
        super.validate(item);
        
        // Additional validation for tasks
        if (item.title !== undefined && item.title.trim().length === 0) {
            throw new Error('Task title cannot be empty');
        }
    }
}

// --- Usage and Demonstration ---

export function demonstrateDataLayer(): void {
    console.log('\n=== TaskFlow Data Layer Demo ===\n');
    
    // Create repositories
    const taskRepo = new TaskRepository();
    const projectRepo = new ProjectRepository();
    const taskService = new TaskService(taskRepo);
    
    // Create sample data
    console.log('📝 Creating sample data...\n');
    
    const project = projectRepo.create({
        name: 'TaskFlow Development',
        status: 'active',
        ownerId: 'user_1',
        memberIds: ['user_1', 'user_2'],
        description: 'Building the next generation task manager',
        createdAt: new Date(),
        updatedAt: new Date()
    });
    console.log('✅ Project created:', project.name);
    
    const task1 = taskService.create({
        title: 'Setup TypeScript',
        status: 'todo',
        priority: 'high',
        projectId: project.id,
        createdBy: 'user_1',
        tags: ['setup', 'typescript'],
        description: 'Initialize project and configure tsconfig.json',
        createdAt: new Date(),
        updatedAt: new Date()
    });
    console.log('✅ Task created:', task1.title);
    
    const task2 = taskService.create({
        title: 'Write Documentation',
        status: 'todo',
        priority: 'medium',
        projectId: project.id,
        createdBy: 'user_1',
        tags: ['docs', 'tutorial'],
        description: 'Write comprehensive documentation for the API',
        createdAt: new Date(),
        updatedAt: new Date()
    });
    console.log('✅ Task created:', task2.title);
    
    // Demonstrate operations
    console.log('\n🔍 Finding tasks...\n');
    
    const projectTasks = taskRepo.findByProject(project.id);
    console.log(`Found ${projectTasks.length} tasks for project "${project.name}"`);
    
    const highPriorityTasks = taskRepo.find(task => task.priority === 'high');
    console.log(`Found ${highPriorityTasks.length} high-priority tasks`);
    
    // Update a task
    console.log('\n🔄 Updating task...');
    const updatedTask = taskService.assignTask(task1.id, 'user_2');
    console.log(`✅ Task "${updatedTask?.title}" assigned to user_2`);
    
    // Complete a task
    console.log('\n✅ Completing task...');
    const completedTask = taskService.completeTask(task1.id);
    console.log(`✅ Task "${completedTask?.title}" marked as done`);
    
    // Pagination demonstration
    console.log('\n📊 Pagination...');
    const paginated = taskRepo.findPaginated(
        task => task.projectId === project.id,
        1, // page 1
        10 // 10 items per page
    );
    console.log(`Total tasks: ${paginated.pagination.total}`);
    console.log(`Page ${paginated.pagination.page} of ${paginated.pagination.totalPages}`);
    console.log(`Items on this page: ${paginated.data.length}`);
}

// Export for use in other files
export const createRepositories = () => ({
    taskRepo: new TaskRepository(),
    projectRepo: new ProjectRepository(),
    taskService: new TaskService(new TaskRepository())
});
```

## 2.5 Advanced tsconfig.json: Path Aliases and Type Root Directories

Let's configure our TypeScript project for better development experience.

### Path Aliases

Path aliases let you use clean imports instead of relative paths.

**File:** `tsconfig.json` (add to compilerOptions)

```json
{
  "compilerOptions": {
    // ... existing settings ...
    "paths": {
      "@/*": ["./src/*"],
      "@types/*": ["./src/types/*"],
      "@utils/*": ["./src/utils/*"],
      "@data/*": ["./src/data/*"]
    }
  }
}
```

Now you can import like this:
```typescript
// Instead of:
// import { Task } from '../types/taskflow.js';
// import { TaskRepository } from '../data/taskflow-data.js';

// You can use:
import { Task } from '@/types/taskflow.js';
import { TaskRepository } from '@/data/taskflow-data.js';
```

### Creating a Custom Type Declaration File

Sometimes you need to declare types for third-party libraries or add custom types.

**File:** `src/types/global.d.ts`

```typescript
/**
 * Global Type Declarations
 * These are available throughout the project
 */

// Add types to the global namespace
declare global {
    // Our custom environment variables
    namespace NodeJS {
        interface ProcessEnv {
            NODE_ENV: 'development' | 'production' | 'test';
            DATABASE_URL: string;
            API_KEY?: string;
        }
    }
}

// Declare CSS modules if using CSS
declare module '*.module.css' {
    const classes: { [key: string]: string };
    export default classes;
}

// Declare image modules
declare module '*.png' {
    const value: string;
    export default value;
}

declare module '*.jpg' {
    const value: string;
    export default value;
}

// Type for JSON imports
declare module '*.json' {
    const value: any;
    export default value;
}

// Custom utility type available globally
type DeepPartial<T> = {
    [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// Type for any function
type AnyFunction = (...args: any[]) => any;

// Make these available throughout the project
export {};
```

## 2.6 Testing Our Types

Let's create a test file to verify our data layer works correctly.

**File:** `src/test-data-layer.ts`

```typescript
/**
 * Testing the TaskFlow Data Layer
 */

import { demonstrateDataLayer, createRepositories } from './data/taskflow-data.js';

// --- Run the demonstration ---
console.log('🧪 Testing TaskFlow Data Layer\n');
demonstrateDataLayer();

// --- Additional tests with specific checks ---

console.log('\n🧪 Additional Tests\n');

// Test type safety
import type { Task, CreateTaskInput } from './types/taskflow.js';

// This should compile without errors
const testCreate: CreateTaskInput = {
    title: 'Test Task',
    status: 'todo',
    priority: 'medium',
    projectId: 'test-project',
    createdBy: 'test-user',
    tags: ['test']
};

console.log('✅ CreateTaskInput type is correct');

const { taskRepo, taskService } = createRepositories();

// Create a test task with the service
const task = taskService.create(testCreate);
console.log('✅ Task created with service:', task.title);

// Test finding
const found = taskRepo.findById(task.id);
console.log('✅ Task found:', found?.title === task.title);

// Test updating
const updated = taskService.update(task.id, { title: 'Updated Task' });
console.log('✅ Task updated:', updated?.title === 'Updated Task');

// Test deletion
const deleted = taskRepo.delete(task.id);
console.log('✅ Task deleted:', deleted);

// Test pagination
const paginated = taskRepo.findPaginated(() => true, 1, 5);
console.log(`✅ Pagination: ${paginated.data.length} items, total: ${paginated.pagination.total}`);

console.log('\n✅ All tests passed!');
```

### The Verification

```bash
# First, compile everything
npm run build

# Run the data layer tests
node dist/test-data-layer.js

# Expected output:
# 🧪 Testing TaskFlow Data Layer
# 
# === TaskFlow Data Layer Demo ===
# 📝 Creating sample data...
# ✅ Project created: TaskFlow Development
# ✅ Task created: Setup TypeScript
# ✅ Task created: Write Documentation
# 
# 🔍 Finding tasks...
# Found 2 tasks for project "TaskFlow Development"
# Found 1 high-priority tasks
# 
# 🔄 Updating task...
# ✅ Task "Setup TypeScript" assigned to user_2
# 
# ✅ Completing task...
# ✅ Task "Setup TypeScript" marked as done
# 
# 📊 Pagination...
# Total tasks: 2
# Page 1 of 1
# Items on this page: 2
# 
# 🧪 Additional Tests
# ✅ CreateTaskInput type is correct
# ✅ Task created with service: Test Task
# ✅ Task found: true
# ✅ Task updated: true
# ✅ Task deleted: true
# ✅ Pagination: 0 items, total: 0
# ✅ All tests passed!
```

## 2.7 Summary: Part 2

You've completed Part 2! Here's what you've learned:

### Interfaces vs. Type Aliases
- **Interfaces:** Extendable, support declaration merging, good for libraries
- **Types:** More flexible, support unions and mapped types, good for utilities

### Generics
- Create reusable, type-safe functions and classes
- Use constraints to restrict generic types
- Combine generics with utility types for powerful abstractions

### Utility Types
- `Partial`, `Required`, `Readonly`: Transform properties
- `Pick`, `Omit`: Select or exclude properties
- `Record`: Create key-value maps
- `Exclude`, `Extract`: Work with unions
- `ReturnType`, `Parameters`: Work with functions
- `NonNullable`: Remove null/undefined

### Practical Application
- Built a generic repository with CRUD operations
- Created specific repositories for TaskFlow entities
- Added a service layer with business logic
- Implemented pagination and filtering

### Development Setup
- Configured path aliases for clean imports
- Created global type declarations
- Set up testing infrastructure

### What's Next: Preview of Part 3

In Part 3, we'll dive into advanced TypeScript features:
- **Conditional Types:** Types that depend on other types
- **Mapped Types:** Transform properties of types
- **Indexed Access Types:** Access properties by index
- **Template Literal Types:** Create string literal types
- **The `infer` Keyword:** Extract types from other types
- **Practical Application:** Build a complete type-safe form validation system

## Verification Checklist

Before moving to Part 3, ensure:

- [ ] `npm run build` compiles without errors
- [ ] `node dist/test-data-layer.js` runs and shows all tests passing
- [ ] You understand when to use `interface` vs. `type`
- [ ] You can explain generics in your own words
- [ ] You've used at least 3 utility types in your code
- [ ] Path aliases work (try importing with `@/` syntax)
- [ ] Your TaskFlow types are complete
