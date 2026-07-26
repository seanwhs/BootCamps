# Mastering TypeScript: Student Workbook

## From JavaScript Habits to Production-Grade React and Next.js Architecture

---

# Table of Contents

**Part 1: Core Mental Model and Foundations**
- Exercise 1.1: Setting Up Your TypeScript Project
- Exercise 1.2: Basic Types and Type Inference
- Exercise 1.3: Functions and Objects
- Exercise 1.4: Union Types and Narrowing
- Exercise 1.5: any vs. unknown vs. never
- Exercise 1.6: Building TaskFlow Core Types
- Practice Problems

**Part 2: Objects, Reuse, and Utility Types**
- Exercise 2.1: Interfaces vs. Type Aliases
- Exercise 2.2: Generics
- Exercise 2.3: Utility Types
- Exercise 2.4: Advanced tsconfig.json
- Exercise 2.5: Building TaskFlow Data Layer
- Practice Problems

**Part 3: Advanced Types and Type-Level Programming**
- Exercise 3.1: Conditional Types
- Exercise 3.2: Mapped Types
- Exercise 3.3: Template Literal Types
- Exercise 3.4: The infer Keyword
- Exercise 3.5: Form Validation System
- Practice Problems

**Part 4: TypeScript in React**
- Exercise 4.1: Typing Components
- Exercise 4.2: Custom Hooks
- Exercise 4.3: Context and State
- Exercise 4.4: Forms with React Hook Form
- Exercise 4.5: TaskFlow React Components
- Practice Problems

**Part 5: TypeScript in Next.js**
- Exercise 5.1: Next.js Setup with TypeScript
- Exercise 5.2: Server Actions
- Exercise 5.3: API Routes
- Exercise 5.4: Environment Variables
- Exercise 5.5: TaskFlow Next.js Implementation
- Practice Problems

**Part 6: Architecture, Testing, and Debugging**
- Exercise 6.1: Unit Testing
- Exercise 6.2: Component Testing
- Exercise 6.3: Integration Testing
- Exercise 6.4: Debugging
- Exercise 6.5: Architecture Patterns
- Exercise 6.6: Production Readiness
- Practice Problems

**Final Capstone Project**
- Project: Complete TaskFlow Application

**Answer Key**
- Solutions to all exercises

---

# Part 1: Core Mental Model and Foundations

## Exercise 1.1: Setting Up Your TypeScript Project

### Objective
Set up a TypeScript project with proper configuration.

### Instructions
1. Create a new directory called `typescript-practice`
2. Initialize npm and install TypeScript
3. Create a `tsconfig.json` with strict mode enabled
4. Create a basic project structure

### Steps

**Step 1: Initialize the Project**

```bash
mkdir typescript-practice
cd typescript-practice
npm init -y
npm install --save-dev typescript @types/node
npx tsc --init
```

**Step 2: Configure tsconfig.json**

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Step 3: Create Project Structure**

```bash
mkdir src
mkdir src/types
touch src/index.ts
```

**Step 4: Add NPM Scripts**

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsc --watch & nodemon dist/index.js"
  }
}
```

### Verification
Run `npm run build` and verify no errors.

---

## Exercise 1.2: Basic Types and Type Inference

### Objective
Practice using basic TypeScript types and understanding type inference.

### Instructions
Complete the following code with proper type annotations.

### Code

```typescript
// File: src/exercise-1-2.ts

// 1. Type Inference
// What type does TypeScript infer for each variable?

let firstName = "Alice";      // Type: _________
let age = 30;                 // Type: _________
let isActive = true;          // Type: _________
let scores = [98, 87, 92];    // Type: _________
let mixed = ["hello", 42];    // Type: _________

// 2. Explicit Types
// Add explicit type annotations

let projectName: string = "TaskFlow";
let versionNumber: number = 1.0;
let isProduction: boolean = false;

// 3. Arrays
// Create arrays of different types

// Array of strings
const tasks: ________________ = ["Write code", "Test", "Deploy"];

// Array of numbers
const taskIds: ________________ = [1, 2, 3, 4, 5];

// Array of mixed types (string or number)
const mixedArray: ________________ = ["task_1", 2, "task_3", 4];

// 4. Functions
// Add proper types to these functions

function greet(name: ________): ________ {
    return `Hello, ${name}!`;
}

function calculateTotal(items: ________): ________ {
    return items.length * 10;
}

function processInput(input: ________): ________ {
    if (typeof input === 'string') {
        return input.toUpperCase();
    } else {
        return input * 2;
    }
}

// 5. Objects
// Define a typed object

const project = {
    id: "proj_123",
    name: "TaskFlow",
    tasks: ["Task 1", "Task 2"],
    members: 5
};
// Add type annotation for this object:
// const project: ________________ = { ... }

// 6. Optional Properties
// Create a type with optional properties

type Product = {
    id: string;
    name: string;
    price: number;
    description?: string;  // Optional
    category?: string;     // Optional
};

const product1: Product = {
    id: "p1",
    name: "Laptop",
    price: 999
};

const product2: Product = {
    id: "p2",
    name: "Mouse",
    price: 25,
    description: "Wireless mouse"
};

// 7. Your Turn
// Create a type called "Book" with:
// - title (string, required)
// - author (string, required)
// - pages (number, required)
// - publishedYear (number, optional)
// - genres (array of strings, optional)

type Book = {
    // Your code here
};

// Create two books, one with all properties and one with optional ones
```

---

## Exercise 1.3: Functions and Objects

### Objective
Practice typing functions that work with objects.

### Instructions
Complete the following code with proper types.

### Code

```typescript
// File: src/exercise-1-3.ts

// 1. Define Types
type User = {
    id: string;
    name: string;
    email: string;
    age: number;
    isAdmin: boolean;
};

type Task = {
    id: string;
    title: string;
    completed: boolean;
    assignedTo: string;
    dueDate?: Date;
};

// 2. Function: Create User
function createUser(name: string, email: string, age: number): User {
    return {
        id: `user_${Date.now()}`,
        name,
        email,
        age,
        isAdmin: false
    };
}

// 3. Function: Update User
function updateUser(user: User, updates: Partial<User>): User {
    return {
        ...user,
        ...updates
    };
}

// 4. Function: Create Task
function createTask(title: string, assignedTo: string): Task {
    return {
        id: `task_${Date.now()}`,
        title,
        completed: false,
        assignedTo
    };
}

// 5. Function: Complete Task
function completeTask(task: Task): Task {
    return {
        ...task,
        completed: true
    };
}

// 6. Function: Get User Tasks
function getUserTasks(tasks: Task[], userId: string): Task[] {
    return tasks.filter(task => task.assignedTo === userId);
}

// 7. Function: Sort Tasks
function sortTasksByDueDate(tasks: Task[]): Task[] {
    return [...tasks].sort((a, b) => {
        // Tasks without due date should come last
        if (!a.dueDate) return 1;
        if (!b.dueDate) return -1;
        return a.dueDate.getTime() - b.dueDate.getTime();
    });
}

// 8. Your Turn: Create a function that:
// - Takes an array of tasks
// - Returns the count of completed tasks
function countCompletedTasks(tasks: Task[]): number {
    // Your code here
}

// 9. Your Turn: Create a function that:
// - Takes an array of users
// - Returns only admin users
function getAdminUsers(users: User[]): User[] {
    // Your code here
}

// 10. Test Your Functions
const user1 = createUser("Alice", "alice@example.com", 30);
const user2 = createUser("Bob", "bob@example.com", 25);

const task1 = createTask("Write code", user1.id);
const task2 = createTask("Review PR", user2.id);
const task3 = createTask("Deploy", user1.id);

const tasks = [task1, task2, task3];

console.log("Users:", [user1, user2]);
console.log("Tasks:", tasks);
console.log("User's tasks:", getUserTasks(tasks, user1.id));
console.log("Completed tasks:", countCompletedTasks(tasks));
```

---

## Exercise 1.4: Union Types and Narrowing

### Objective
Practice using union types and type narrowing techniques.

### Instructions
Complete the following code with proper union types and type guards.

### Code

```typescript
// File: src/exercise-1-4.ts

// 1. Define Types
type StringOrNumber = string | number;
type Status = 'pending' | 'active' | 'completed' | 'archived';
type Value = string | number | boolean | null | undefined;

// 2. Process Value with Type Narrowing
function processValue(value: Value): string {
    // Use typeof narrowing
    // Your code here
    return "";
}

// 3. Process Status with Equality Narrowing
function getStatusMessage(status: Status): string {
    // Use equality checks
    // Your code here
    return "";
}

// 4. Process Task with Truthiness Narrowing
type Task = {
    id: string;
    title: string;
    description?: string;
    dueDate?: Date;
};

function getTaskDescription(task: Task | null): string {
    // Use truthiness narrowing
    // Your code here
    return "";
}

// 5. Discriminated Union
type Event =
    | { type: 'click'; x: number; y: number }
    | { type: 'keypress'; key: string; shiftKey: boolean }
    | { type: 'submit'; formId: string; data: Record<string, string> };

function handleEvent(event: Event): string {
    // Use discriminated union narrowing
    // Your code here
    return "";
}

// 6. Type Predicates
function isTask(value: any): value is Task {
    // Create a type predicate
    // Your code here
    return false;
}

// 7. Your Turn: Create a function that accepts a string or number
// and returns a formatted string
function formatValue(value: StringOrNumber): string {
    // Your code here
    return "";
}

// 8. Your Turn: Create a function that accepts an array of mixed types
// and returns only the strings
function extractStrings(values: (string | number | boolean)[]): string[] {
    // Your code here
    return [];
}

// 9. Test Your Functions
console.log("Process Value:", processValue("Hello"));
console.log("Process Value:", processValue(42));
console.log("Process Value:", processValue(true));
console.log("Process Value:", processValue(null));

console.log("Status Message:", getStatusMessage('pending'));
console.log("Status Message:", getStatusMessage('completed'));

const task: Task = {
    id: "1",
    title: "Test Task",
    description: "This is a test"
};
console.log("Task Description:", getTaskDescription(task));
console.log("Task Description:", getTaskDescription(null));

const clickEvent: Event = { type: 'click', x: 100, y: 200 };
console.log("Event:", handleEvent(clickEvent));

console.log("Format Value:", formatValue("123"));
console.log("Format Value:", formatValue(456));

console.log("Extract Strings:", extractStrings(["a", 1, "b", 2, true, "c"]));
```

---

## Exercise 1.5: any vs. unknown vs. never

### Objective
Practice using `any`, `unknown`, and `never` appropriately.

### Instructions
Complete the following code demonstrating the differences.

### Code

```typescript
// File: src/exercise-1-5.ts

// 1. any - Use Sparingly
let anyValue: any = "Hello";
anyValue = 42;              // ✓ Valid
anyValue = true;            // ✓ Valid
anyValue = [1, 2, 3];       // ✓ Valid

// With any, you can do anything (unsafe)
anyValue.toUpperCase();     // ✓ Compiles (may fail at runtime)
anyValue.notExist();        // ✓ Compiles (may fail at runtime)

// 2. unknown - Safe Alternative
let unknownValue: unknown = "Hello";
unknownValue = 42;          // ✓ Valid
unknownValue = true;        // ✓ Valid

// With unknown, you must narrow first
// unknownValue.toUpperCase();  // ✗ Error: Object is of type 'unknown'

// Narrowing unknown
if (typeof unknownValue === 'string') {
    console.log(unknownValue.toUpperCase());  // ✓ Safe
}

// 3. never - Values That Never Occur
function throwError(message: string): never {
    throw new Error(message);
}

function infiniteLoop(): never {
    while (true) {
        // Never returns
    }
}

// 4. Your Turn: Exhaustive Checking with never
type Priority = 'low' | 'medium' | 'high';

function getPriorityLabel(priority: Priority): string {
    switch (priority) {
        case 'low':
            return 'Low';
        case 'medium':
            return 'Medium';
        case 'high':
            return 'High';
        default:
            // This ensures all cases are handled
            const exhaustiveCheck: never = priority;
            return exhaustiveCheck;
    }
}

// 5. Your Turn: Safe JSON Parse with unknown
function safeJSONParse(data: string): unknown {
    try {
        return JSON.parse(data);
    } catch {
        return null;
    }
}

// 6. Your Turn: Process Unknown Data
function processUnknownData(data: unknown): string {
    // Your code here: Narrow unknown to a safe type
    return "";
}

// 7. Practice: Identify the Correct Type
// For each scenario, choose: any, unknown, or never

// Scenario 1: A user-provided value from an API
const apiData: _______ = fetchSomeData();

// Scenario 2: A function that always throws an error
function fail(): _______ {
    throw new Error("Failed!");
}

// Scenario 3: A callback with dynamic arguments
function dynamicCallback(callback: (data: _______) => void) {
    // Callback can receive anything
}

// 8. Test Your Code
const jsonData = safeJSONParse('{"name": "TaskFlow"}');
console.log("Parsed data:", jsonData);

// Safely access parsed data
if (jsonData && typeof jsonData === 'object' && 'name' in jsonData) {
    console.log("Name:", (jsonData as { name: string }).name);
}

console.log("Priority label:", getPriorityLabel('high'));
```

---

## Exercise 1.6: Building TaskFlow Core Types

### Objective
Build the core types for the TaskFlow application.

### Instructions
Create a file with all the core types for TaskFlow.

### Code

```typescript
// File: src/types/taskflow.ts

// 1. User Types
export type UserId = string;
export type Email = string;

export interface User {
    id: UserId;
    email: Email;
    name: string;
    avatarUrl?: string;
    createdAt: Date;
    updatedAt: Date;
}

// 2. Project Types
export type ProjectId = string;
export type ProjectStatus = 'active' | 'archived' | 'completed';

export interface Project {
    id: ProjectId;
    name: string;
    description?: string;
    status: ProjectStatus;
    ownerId: UserId;
    memberIds: UserId[];
    createdAt: Date;
    updatedAt: Date;
}

// 3. Task Types
export type TaskId = string;
export type TaskPriority = 'low' | 'medium' | 'high' | 'urgent';
export type TaskStatus = 'todo' | 'in-progress' | 'review' | 'done';

export interface Task {
    id: TaskId;
    title: string;
    description?: string;
    status: TaskStatus;
    priority: TaskPriority;
    projectId: ProjectId;
    assigneeId?: UserId;
    createdBy: UserId;
    dueDate?: Date;
    tags: string[];
    createdAt: Date;
    updatedAt: Date;
}

// 4. Comment Types
export type CommentId = string;

export interface Comment {
    id: CommentId;
    content: string;
    taskId: TaskId;
    userId: UserId;
    createdAt: Date;
    updatedAt: Date;
}

// 5. Activity Types
export type ActivityType =
    | 'task_created'
    | 'task_updated'
    | 'task_completed'
    | 'comment_added'
    | 'user_assigned'
    | 'project_created';

export interface ActivityLog {
    id: string;
    type: ActivityType;
    userId: UserId;
    taskId?: TaskId;
    projectId: ProjectId;
    metadata: Record<string, any>;
    createdAt: Date;
}

// 6. API Response Types
export type ApiResponse<T> = {
    success: boolean;
    data?: T;
    error?: string;
    timestamp: string;
};

export type PaginatedResponse<T> = {
    data: T[];
    pagination: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
};

// 7. Form Types
export type CreateTaskInput = Omit<Task, 'id' | 'createdAt' | 'updatedAt'>;
export type UpdateTaskInput = Partial<Omit<Task, 'id' | 'createdAt' | 'updatedAt'>> & {
    id: TaskId;
};

// 8. Type Guards
export function isTaskPriority(value: any): value is TaskPriority {
    return ['low', 'medium', 'high', 'urgent'].includes(value);
}

export function isTaskStatus(value: any): value is TaskStatus {
    return ['todo', 'in-progress', 'review', 'done'].includes(value);
}

// 9. Your Turn: Create a type for Team
// A Team has:
// - id (string)
// - name (string)
// - members (array of UserId)
// - createdAt (Date)
// - updatedAt (Date)
// - leadId (UserId, required)

export type TeamId = string;

export interface Team {
    // Your code here
}

// 10. Your Turn: Create a type for Board
// A Board is like a project but with:
// - columns (array of { id, name, taskIds })
// - isArchived (boolean)

export interface Board {
    // Your code here
}
```

---

## Practice Problems - Part 1

### Problem 1: Type Inference
What type does TypeScript infer for each variable?

```typescript
let name = "TypeScript";
let count = 100;
let items = ["a", "b", "c"];
let data = { id: 1, name: "Task" };
let mixed = [1, "two", 3];
```

### Problem 2: Function Types
Write the type for a function that:
- Takes two numbers
- Returns their sum

```typescript
type AddFunction = // Your code here
```

### Problem 3: Union Types
Create a type that can be either a string or an array of strings.

```typescript
type StringOrStringArray = // Your code here
```

### Problem 4: Type Narrowing
Write a function that accepts a string or number and returns a formatted string.

```typescript
function formatValue(value: string | number): string {
    // Your code here
}
```

### Problem 5: Optional Properties
Create a type for a configuration object with required and optional properties.

```typescript
type Config = {
    // Required: apiUrl
    // Required: timeout
    // Optional: retryCount
    // Optional: headers (record of string to string)
};
```

---

# Part 2: Objects, Reuse, and Utility Types

## Exercise 2.1: Interfaces vs. Type Aliases

### Objective
Practice using interfaces and type aliases appropriately.

### Instructions
Complete the following code using interfaces and type aliases.

### Code

```typescript
// File: src/exercise-2-1.ts

// 1. Interface - Basic
interface Person {
    name: string;
    age: number;
    email: string;
}

// 2. Interface Extension
interface Employee extends Person {
    employeeId: string;
    department: string;
    salary: number;
}

// 3. Interface with Methods
interface Calculator {
    add(a: number, b: number): number;
    subtract(a: number, b: number): number;
    multiply(a: number, b: number): number;
    divide(a: number, b: number): number;
}

// 4. Type Alias - Primitive
type ID = string | number;

// 5. Type Alias - Union
type Status = 'pending' | 'approved' | 'rejected';

// 6. Type Alias - Intersection
type Product = {
    id: ID;
    name: string;
    price: number;
};

type Inventory = {
    quantity: number;
    location: string;
};

type ProductWithInventory = Product & Inventory;

// 7. Type Alias - Function
type ValidationFn = (value: any) => boolean;

// 8. Your Turn: Create an interface for a Book
// - title (string)
// - author (string)
// - pages (number)
// - publishedYear (number, optional)

interface Book {
    // Your code here
}

// 9. Your Turn: Create a type for a Student that extends Person
// Student has: grade (number), courses (array of string)

type Student = Person & {
    // Your code here
};

// 10. Your Turn: Create a type for a Response
// Response has: status (number), data (any), message (string, optional)

type Response<T> = {
    // Your code here
};

// 11. Practice: When to use Interface vs. Type
// For each scenario, choose interface or type:

// Scenario 1: Library API that will be extended
// Answer: _________

// Scenario 2: Union of string literals
// Answer: _________

// Scenario 3: A class implementation
// Answer: _________

// Scenario 4: Mapped type
// Answer: _________

// Scenario 5: Declaration merging needed
// Answer: _________
```

---

## Exercise 2.2: Generics

### Objective
Practice creating and using generic functions and classes.

### Instructions
Complete the following code with generics.

### Code

```typescript
// File: src/exercise-2-2.ts

// 1. Generic Identity Function
function identity<T>(value: T): T {
    return value;
}

// 2. Generic Array Utilities
function first<T>(items: T[]): T | undefined {
    return items[0];
}

function last<T>(items: T[]): T | undefined {
    return items[items.length - 1];
}

function getRandomElement<T>(items: T[]): T | undefined {
    if (items.length === 0) return undefined;
    const randomIndex = Math.floor(Math.random() * items.length);
    return items[randomIndex];
}

// 3. Generic Function with Constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

// 4. Generic Class
class Stack<T> {
    private items: T[] = [];

    push(item: T): void {
        this.items.push(item);
    }

    pop(): T | undefined {
        return this.items.pop();
    }

    peek(): T | undefined {
        return this.items[this.items.length - 1];
    }

    size(): number {
        return this.items.length;
    }

    isEmpty(): boolean {
        return this.items.length === 0;
    }
}

// 5. Generic with Multiple Types
function zip<T, U>(first: T[], second: U[]): (T | U)[][] {
    const result: (T | U)[][] = [];
    const length = Math.min(first.length, second.length);
    
    for (let i = 0; i < length; i++) {
        result.push([first[i], second[i]]);
    }
    
    return result;
}

// 6. Your Turn: Generic Filter Function
function filter<T>(items: T[], predicate: (item: T) => boolean): T[] {
    // Your code here
    return [];
}

// 7. Your Turn: Generic Map Function
function map<T, U>(items: T[], transform: (item: T) => U): U[] {
    // Your code here
    return [];
}

// 8. Your Turn: Generic Repository
class Repository<T extends { id: string }> {
    private items: T[] = [];

    add(item: T): void {
        this.items.push(item);
    }

    findById(id: string): T | undefined {
        // Your code here
        return undefined;
    }

    findAll(): T[] {
        // Your code here
        return [];
    }

    delete(id: string): boolean {
        // Your code here
        return false;
    }

    update(id: string, updates: Partial<T>): T | undefined {
        // Your code here
        return undefined;
    }
}

// 9. Test Your Code
console.log("Identity:", identity("Hello"));
console.log("First:", first([1, 2, 3]));
console.log("Last:", last([1, 2, 3]));

const stack = new Stack<string>();
stack.push("a");
stack.push("b");
stack.push("c");
console.log("Stack size:", stack.size());
console.log("Stack pop:", stack.pop());

const numbers = [1, 2, 3, 4, 5];
const doubled = map(numbers, n => n * 2);
console.log("Doubled:", doubled);

const evenNumbers = filter(numbers, n => n % 2 === 0);
console.log("Even numbers:", evenNumbers);

// Test Repository
interface Task {
    id: string;
    title: string;
}

const taskRepo = new Repository<Task>();
taskRepo.add({ id: "1", title: "Task 1" });
taskRepo.add({ id: "2", title: "Task 2" });
console.log("All tasks:", taskRepo.findAll());
console.log("Find task 1:", taskRepo.findById("1"));
```

---

## Exercise 2.3: Utility Types

### Objective
Practice using TypeScript's built-in utility types.

### Instructions
Complete the following code using utility types.

### Code

```typescript
// File: src/exercise-2-3.ts

// 1. Define Base Type
type Task = {
    id: string;
    title: string;
    description?: string;
    completed: boolean;
    priority: 'low' | 'medium' | 'high';
    dueDate?: Date;
    tags: string[];
};

// 2. Partial - Make all properties optional
type PartialTask = Partial<Task>;

// 3. Required - Make all properties required
type RequiredTask = Required<PartialTask>;

// 4. Readonly - Make all properties read-only
type ImmutableTask = Readonly<Task>;

// 5. Pick - Select specific properties
type TaskSummary = Pick<Task, 'id' | 'title' | 'priority'>;

// 6. Omit - Exclude specific properties
type TaskWithoutId = Omit<Task, 'id'>;

// 7. Record - Create a key-value map
type PriorityColors = Record<'low' | 'medium' | 'high', string>;

// 8. Exclude - Remove union members
type NonCompletedStatus = Exclude<"low" | "medium" | "high", "high">;

// 9. Extract - Keep only specified union members
type HighPriority = Extract<"low" | "medium" | "high", "high">;

// 10. NonNullable - Remove null and undefined
type MaybeString = string | null | undefined;
type DefinitelyString = NonNullable<MaybeString>;

// 11. ReturnType - Get function return type
function createTask(title: string): Task {
    return {
        id: `task_${Date.now()}`,
        title,
        completed: false,
        priority: 'medium',
        tags: []
    };
}

type CreateTaskResult = ReturnType<typeof createTask>;

// 12. Parameters - Get function parameters
type CreateTaskParams = Parameters<typeof createTask>;

// 13. Your Turn: Create a utility type that makes all properties optional
// and read-only
type PartialReadonly<T> = {
    // Your code here
};

// 14. Your Turn: Create a utility type that extracts only string properties
type StringProperties<T> = {
    // Your code here
};

// 15. Your Turn: Create a utility type that makes selected properties required
type WithRequired<T, K extends keyof T> = {
    // Your code here
};

// 16. Test Your Code
const partialTask: PartialTask = {
    title: "Write documentation",
    priority: "high"
};

const summary: TaskSummary = {
    id: "task_1",
    title: "Complete project",
    priority: "high"
};

const priorityColors: PriorityColors = {
    low: "green",
    medium: "yellow",
    high: "red"
};

const taskResult: CreateTaskResult = createTask("New Task");
console.log("Task result:", taskResult);
```

---

## Exercise 2.4: Advanced tsconfig.json

### Objective
Configure a production-ready tsconfig.json with advanced options.

### Instructions
Create a tsconfig.json with strict mode and path aliases.

### Code

```json
// File: tsconfig.json

{
  "compilerOptions": {
    // --- Type Checking ---
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "useUnknownInCatchVariables": true,
    
    // --- Module Resolution ---
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "target": "ES2022",
    "lib": ["ES2022"],
    
    // --- Output ---
    "outDir": "./dist",
    "rootDir": "./src",
    "sourceMap": true,
    
    // --- Interoperability ---
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    
    // --- Path Aliases ---
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@types/*": ["./src/types/*"],
      "@utils/*": ["./src/utils/*"],
      "@data/*": ["./src/data/*"]
    },
    
    // --- Additional ---
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noUncheckedIndexedAccess": true,
    "noFallthroughCasesInSwitch": true,
    "noPropertyAccessFromIndexSignature": true,
    "exactOptionalPropertyTypes": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Verification

Create a test file to verify path aliases work:

```typescript
// File: src/index.ts

import { User } from '@/types/taskflow';
import { formatDate } from '@utils/date';

console.log("Path aliases working!");
```

---

## Exercise 2.5: Building TaskFlow Data Layer

### Objective
Build the data layer for TaskFlow using generics and utility types.

### Instructions
Create a generic repository and specific repositories for TaskFlow.

### Code

```typescript
// File: src/data/taskflow-data.ts

import type { Task, Project, User, Comment, CreateTaskInput, UpdateTaskInput, PaginatedResponse } from '@/types/taskflow';

// 1. Generic Repository
export class Repository<T extends { id: string }> {
    protected items: Map<string, T> = new Map();

    create(item: Omit<T, 'id'>): T {
        // Your code here
        const id = this.generateId();
        const newItem = { ...item, id } as T;
        this.items.set(id, newItem);
        return newItem;
    }

    findById(id: string): T | undefined {
        // Your code here
        return undefined;
    }

    findAll(): T[] {
        // Your code here
        return [];
    }

    update(id: string, updates: Partial<Omit<T, 'id'>>): T | undefined {
        // Your code here
        return undefined;
    }

    delete(id: string): boolean {
        // Your code here
        return false;
    }

    find(predicate: (item: T) => boolean): T[] {
        // Your code here
        return [];
    }

    findPaginated(
        predicate: (item: T) => boolean,
        page: number = 1,
        limit: number = 10
    ): PaginatedResponse<T> {
        // Your code here
        return {
            data: [],
            pagination: {
                page,
                limit,
                total: 0,
                totalPages: 0
            }
        };
    }

    private generateId(): string {
        return `item_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
}

// 2. Task Repository
export class TaskRepository extends Repository<Task> {
    findByProject(projectId: string): Task[] {
        // Your code here
        return [];
    }

    findByAssignee(userId: string): Task[] {
        // Your code here
        return [];
    }

    findByStatus(status: Task['status']): Task[] {
        // Your code here
        return [];
    }

    getOverdueTasks(): Task[] {
        // Your code here
        return [];
    }
}

// 3. Project Repository
export class ProjectRepository extends Repository<Project> {
    findByOwner(ownerId: string): Project[] {
        // Your code here
        return [];
    }

    findMemberProjects(userId: string): Project[] {
        // Your code here
        return [];
    }
}

// 4. Service Layer
export class Service<T extends { id: string }> {
    constructor(private repository: Repository<T>) {}

    create(item: Omit<T, 'id'>): T {
        this.validate(item);
        return this.repository.create(item);
    }

    update(id: string, updates: Partial<Omit<T, 'id'>>): T | undefined {
        this.validate(updates);
        return this.repository.update(id, updates);
    }

    protected validate(item: any): void {
        // Your code here
        if (!item) {
            throw new Error('Invalid item provided');
        }
    }
}

// 5. Task Service
export class TaskService extends Service<Task> {
    private taskRepo: TaskRepository;

    constructor(repository: TaskRepository) {
        super(repository);
        this.taskRepo = repository;
    }

    assignTask(taskId: string, assigneeId: string): Task | undefined {
        // Your code here
        return undefined;
    }

    completeTask(taskId: string): Task | undefined {
        // Your code here
        return undefined;
    }

    protected validate(item: any): void {
        super.validate(item);
        // Additional validation
        if (item.title !== undefined && item.title.trim().length === 0) {
            throw new Error('Task title cannot be empty');
        }
    }
}

// 6. Test Your Code
export function testDataLayer() {
    const taskRepo = new TaskRepository();
    const taskService = new TaskService(taskRepo);

    // Create a task
    const task = taskService.create({
        title: 'Setup TypeScript',
        status: 'todo',
        priority: 'high',
        projectId: 'project_1',
        createdBy: 'user_1',
        tags: ['setup'],
        createdAt: new Date(),
        updatedAt: new Date()
    });

    console.log('Task created:', task);

    // Find all tasks
    const allTasks = taskRepo.findAll();
    console.log('All tasks:', allTasks);

    // Update task
    const updated = taskService.update(task.id, { title: 'Updated Title' });
    console.log('Updated task:', updated);

    return { taskRepo, taskService };
}
```

---

## Practice Problems - Part 2

### Problem 1: Interface vs. Type
When would you use an interface over a type alias?

### Problem 2: Generic Function
Write a generic function that returns the first element of an array.

```typescript
function first<T>(items: T[]): T | undefined {
    // Your code here
}
```

### Problem 3: Utility Types
Use utility types to create a type that:
- Makes all properties of `User` optional
- Makes all properties of `User` read-only
- Picks only `id` and `name` from `User`

```typescript
type User = {
    id: string;
    name: string;
    email: string;
    age: number;
};

type OptionalUser = // Your code here
type ReadonlyUser = // Your code here
type UserSummary = // Your code here
```

### Problem 4: Repository Pattern
Implement a generic repository that works with any entity type.

### Problem 5: Path Aliases
Configure path aliases in tsconfig.json for:
- `@/*` -> `src/*`
- `@components/*` -> `src/components/*`
- `@utils/*` -> `src/utils/*`

---

# Part 3: Advanced Types and Type-Level Programming

## Exercise 3.1: Conditional Types

### Objective
Practice using conditional types for type-level logic.

### Instructions
Complete the following code with conditional types.

### Code

```typescript
// File: src/exercise-3-1.ts

// 1. Basic Conditional Types
type IsString<T> = T extends string ? true : false;

// 2. Type Name with Conditional
type TypeName<T> =
    T extends string ? 'string' :
    T extends number ? 'number' :
    T extends boolean ? 'boolean' :
    T extends undefined ? 'undefined' :
    T extends null ? 'null' :
    T extends Array<any> ? 'array' :
    T extends Function ? 'function' :
    T extends object ? 'object' :
    'unknown';

// 3. Extract with Conditional
type ExtractStrings<T> = T extends string ? T : never;

// 4. Exclude with Conditional
type ExcludeStrings<T> = T extends string ? never : T;

// 5. Conditional with infer
type ElementType<T> = T extends (infer U)[] ? U : never;

type ReturnTypeOf<T> = T extends (...args: any[]) => infer R ? R : never;

// 6. Your Turn: Create a type that checks if a type is an array
type IsArray<T> = // Your code here

// 7. Your Turn: Create a type that extracts the first element of a tuple
type First<T extends any[]> = // Your code here

// 8. Your Turn: Create a type that gets the last element of a tuple
type Last<T extends any[]> = // Your code here

// 9. Your Turn: Create a type that flattens nested arrays
type Flatten<T> = // Your code here

// 10. Test Your Code
type Test1 = IsString<string>;   // true
type Test2 = IsString<number>;   // false
type Test3 = TypeName<string[]>; // 'array'
type Test4 = First<[1, 2, 3]>;   // 1
type Test5 = Last<[1, 2, 3]>;    // 3
type Test6 = Flatten<number[][]>; // number
```

---

## Exercise 3.2: Mapped Types

### Objective
Practice using mapped types to transform object types.

### Instructions
Complete the following code with mapped types.

### Code

```typescript
// File: src/exercise-3-2.ts

// 1. Basic Mapped Type
type MakeOptional<T> = {
    [P in keyof T]?: T[P];
};

type MakeReadonly<T> = {
    readonly [P in keyof T]: T[P];
};

// 2. Filter Properties
type KeepStringProperties<T> = {
    [P in keyof T as T[P] extends string ? P : never]: T[P];
};

type KeepNumberProperties<T> = {
    [P in keyof T as T[P] extends number ? P : never]: T[P];
};

// 3. Transform Properties
type UppercaseProperties<T> = {
    [P in keyof T]: T[P] extends string ? Uppercase<T[P]> : T[P];
};

type NullableProperties<T> = {
    [P in keyof T]: T[P] | null;
};

// 4. Add Timestamp
type AddTimestamp<T> = T & {
    createdAt: Date;
    updatedAt: Date;
};

// 5. Deep Partial
type DeepPartial<T> = {
    [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// 6. Your Turn: Create a type that makes all properties required
// But leaves optional properties as optional
type RequiredExceptOptional<T> = {
    // Your code here
};

// 7. Your Turn: Create a type that maps all properties to functions
// Example: { name: string } -> { getName: () => string }
type ToGetters<T> = {
    // Your code here
};

// 8. Your Turn: Create a type that selects only properties
// That are of a specific type
type SelectProperties<T, U> = {
    // Your code here
};

// 9. Test Your Code
type Task = {
    id: string;
    title: string;
    completed: boolean;
    priority: 'low' | 'medium' | 'high';
};

type OptionalTask = MakeOptional<Task>;
type ReadonlyTask = MakeReadonly<Task>;
type StringProps = KeepStringProperties<Task>;
type TimestampedTask = AddTimestamp<Task>;

console.log("Mapped types created successfully!");
```

---

## Exercise 3.3: Template Literal Types

### Objective
Practice using template literal types for string manipulation.

### Instructions
Complete the following code with template literal types.

### Code

```typescript
// File: src/exercise-3-3.ts

// 1. Basic Template Literal
type ApiEndpoint = `/api/${string}`;

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type ApiRoute = `${HttpMethod} /${string}`;

// 2. String Manipulation
type ToCamelCase<S extends string> =
    S extends `${infer First}_${infer Rest}`
        ? `${Lowercase<First>}${Capitalize<ToCamelCase<Rest>>}`
        : Lowercase<S>;

type ToKebabCase<S extends string> =
    S extends `${infer First}${infer Rest}`
        ? First extends Uppercase<First>
            ? `-${Lowercase<First>}${ToKebabCase<Rest>}`
            : `${First}${ToKebabCase<Rest>}`
        : S;

// 3. URL Parameter Extraction
type UrlParams<T extends string> =
    T extends `${string}:${infer Param}/${infer Rest}`
        ? { [K in Param | keyof UrlParams<Rest>]: string }
        : T extends `${string}:${infer Param}`
            ? { [K in Param]: string }
            : {};

// 4. Your Turn: Create a type for API paths
// Example: "/api/users/:id/posts/:postId"
// Should extract { id: string, postId: string }

type ExtractPathParams<T extends string> = // Your code here

// 5. Your Turn: Create a type that generates GET, POST, PUT, DELETE
// endpoints for a resource
type ResourceEndpoints<T extends string> = {
    // Your code here
};

// 6. Your Turn: Create a type that converts snake_case to camelCase
// Example: "user_first_name" -> "userFirstName"
type SnakeToCamel<T extends string> = // Your code here

// 7. Test Your Code
type Route1 = ApiRoute; // "GET /" | "POST /" | ...
type CamelCase1 = ToCamelCase<'user_first_name'>; // "userFirstName"
type CamelCase2 = ToCamelCase<'project_task_status'>; // "projectTaskStatus"

type Params1 = UrlParams<'/api/users/:id'>; // { id: string }
type Params2 = UrlParams<'/api/users/:id/posts/:postId'>; // { id: string, postId: string }

console.log("Template literal types created successfully!");
```

---

## Exercise 3.4: The infer Keyword

### Objective
Practice using the infer keyword for type extraction.

### Instructions
Complete the following code with the infer keyword.

### Code

```typescript
// File: src/exercise-3-4.ts

// 1. Extracting Array Elements
type ArrayElementType<T> = T extends (infer U)[] ? U : never;

// 2. Extracting Return Types
type MyReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

// 3. Extracting Parameters
type MyParameters<T> = T extends (...args: infer P) => any ? P : never;

// 4. Extracting Promise Values
type Awaited<T> = T extends Promise<infer U> ? U : T;

// 5. Extracting from Functions
type FunctionArgs<T> = T extends (...args: infer A) => any ? A : never;

// 6. Your Turn: Extract the element type from a Set
type SetElementType<T> = // Your code here

// 7. Your Turn: Extract the type from a Map
type MapKeyType<T> = // Your code here
type MapValueType<T> = // Your code here

// 8. Your Turn: Extract the data type from an API response
type ApiResponse<T> = {
    success: boolean;
    data: T;
    message?: string;
};

type ExtractData<T> = // Your code here

// 9. Your Turn: Extract the first argument type from a function
type FirstArgument<T> = // Your code here

// 10. Test Your Code
type ArrayElement = ArrayElementType<string[]>; // string
type ReturnType = MyReturnType<() => number>; // number
type Params = MyParameters<(a: string, b: number) => void>; // [string, number]
type PromiseType = Awaited<Promise<string>>; // string

const fn = (x: number, y: string) => true;
type FirstArg = FirstArgument<typeof fn>; // number

console.log("Infer types created successfully!");
```

---

## Exercise 3.5: Form Validation System

### Objective
Build a type-safe form validation system.

### Instructions
Create a complete form validation system using advanced TypeScript features.

### Code

```typescript
// File: src/validation/validator.ts

// 1. Core Types
type ValidationResult<T> =
    | { valid: true; value: T }
    | { valid: false; errors: string[] };

type Validator<T> = (value: unknown) => ValidationResult<T>;

// 2. Built-in Validators
function isString(value: unknown): ValidationResult<string> {
    if (typeof value !== 'string') {
        return { valid: false, errors: ['Must be a string'] };
    }
    return { valid: true, value };
}

function minLength(min: number): Validator<string> {
    return (value) => {
        const result = isString(value);
        if (!result.valid) return result;
        
        if (result.value.length < min) {
            return { valid: false, errors: [`Must be at least ${min} characters`] };
        }
        return { valid: true, value: result.value };
    };
}

function maxLength(max: number): Validator<string> {
    return (value) => {
        const result = isString(value);
        if (!result.valid) return result;
        
        if (result.value.length > max) {
            return { valid: false, errors: [`Must be at most ${max} characters`] };
        }
        return { valid: true, value: result.value };
    };
}

function isEmail(value: unknown): ValidationResult<string> {
    const result = isString(value);
    if (!result.valid) return result;
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(result.value)) {
        return { valid: false, errors: ['Must be a valid email'] };
    }
    return { valid: true, value: result.value };
}

function isNumber(value: unknown): ValidationResult<number> {
    if (typeof value !== 'number' || isNaN(value)) {
        return { valid: false, errors: ['Must be a number'] };
    }
    return { valid: true, value };
}

function minNumber(min: number): Validator<number> {
    return (value) => {
        const result = isNumber(value);
        if (!result.valid) return result;
        
        if (result.value < min) {
            return { valid: false, errors: [`Must be at least ${min}`] };
        }
        return { valid: true, value: result.value };
    };
}

function isBoolean(value: unknown): ValidationResult<boolean> {
    if (typeof value !== 'boolean') {
        return { valid: false, errors: ['Must be a boolean'] };
    }
    return { valid: true, value };
}

// 3. Object Validator
function objectValidator<T extends Record<string, any>>(
    shape: {
        [K in keyof T]: Validator<T[K]>;
    }
): Validator<T> {
    return (value): ValidationResult<T> => {
        if (typeof value !== 'object' || value === null) {
            return { valid: false, errors: ['Must be an object'] };
        }
        
        const errors: string[] = [];
        const result: any = {};
        
        for (const [key, validator] of Object.entries(shape)) {
            const fieldResult = validator((value as any)[key]);
            
            if (!fieldResult.valid) {
                errors.push(`${key}: ${fieldResult.errors.join(', ')}`);
            } else {
                result[key] = fieldResult.value;
            }
        }
        
        if (errors.length > 0) {
            return { valid: false, errors };
        }
        
        return { valid: true, value: result };
    };
}

// 4. Your Turn: Create a union validator
function unionValidator<T extends Validator<any>[]>(
    ...validators: T
): Validator<T[number] extends Validator<infer U> ? U : never> {
    // Your code here
    return (value): any => {
        return { valid: false, errors: ['Not implemented'] };
    };
}

// 5. Your Turn: Create an optional validator
function optionalValidator<T>(
    validator: Validator<T>
): Validator<T | undefined> {
    // Your code here
    return (value) => {
        return { valid: false, errors: ['Not implemented'] };
    };
}

// 6. User Registration Validator
type RegistrationData = {
    email: string;
    password: string;
    confirmPassword: string;
    age?: number;
    termsAccepted: boolean;
};

const registrationValidator = objectValidator<RegistrationData>({
    email: isEmail,
    password: minLength(8),
    confirmPassword: (value) => {
        // Your code here: Must match password
        return { valid: false, errors: ['Not implemented'] };
    },
    age: optionalValidator(minNumber(13)),
    termsAccepted: isBoolean
});

// 7. Test Your Code
function testValidator() {
    const validData = {
        email: 'user@example.com',
        password: 'securepassword',
        confirmPassword: 'securepassword',
        age: 25,
        termsAccepted: true
    };

    const invalidData = {
        email: 'not-an-email',
        password: 'short',
        confirmPassword: 'different',
        age: 12,
        termsAccepted: 'yes'
    };

    console.log('Valid data:', registrationValidator(validData));
    console.log('Invalid data:', registrationValidator(invalidData));
}

testValidator();
```

---

## Practice Problems - Part 3

### Problem 1: Conditional Type
Create a conditional type that checks if a type is a function.

```typescript
type IsFunction<T> = // Your code here
```

### Problem 2: Mapped Type
Create a mapped type that makes all properties of an object required and non-nullable.

```typescript
type RequiredNonNullable<T> = // Your code here
```

### Problem 3: Template Literal
Create a type that converts a string to uppercase with underscores.

```typescript
type ToUpperCase<T extends string> = // Your code here
```

### Problem 4: Infer
Use infer to extract the type from a Promise.

```typescript
type ExtractPromise<T> = // Your code here
```

### Problem 5: Form Validation
Create a validator for a login form with:
- email (required, valid email)
- password (required, at least 8 characters)

---

# Part 4: TypeScript in React

## Exercise 4.1: Typing Components

### Objective
Practice typing React components with TypeScript.

### Instructions
Complete the following React components with proper types.

### Code

```tsx
// File: src/components/exercise-4-1.tsx

import React, { ReactNode, ButtonHTMLAttributes, forwardRef } from 'react';

// 1. Basic Component Props
interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    children: ReactNode;
    variant?: 'primary' | 'secondary' | 'danger';
    size?: 'sm' | 'md' | 'lg';
    isLoading?: boolean;
    fullWidth?: boolean;
}

export function Button({
    children,
    variant = 'primary',
    size = 'md',
    isLoading = false,
    fullWidth = false,
    disabled,
    className = '',
    ...props
}: ButtonProps) {
    // Your component implementation here
    return (
        <button
            className={`px-4 py-2 rounded ${fullWidth ? 'w-full' : ''}`}
            disabled={disabled || isLoading}
            {...props}
        >
            {isLoading ? 'Loading...' : children}
        </button>
    );
}

// 2. Input Component with ForwardRef
interface InputProps {
    label?: string;
    error?: string;
    helper?: string;
    id?: string;
    fullWidth?: boolean;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
    ({ label, error, helper, id, fullWidth = false, ...props }, ref) => {
        const inputId = id || `input-${Math.random().toString(36).substr(2, 9)}`;
        
        // Your component implementation here
        return (
            <div className={fullWidth ? 'w-full' : ''}>
                {label && <label htmlFor={inputId}>{label}</label>}
                <input ref={ref} id={inputId} {...props} />
                {helper && !error && <p>{helper}</p>}
                {error && <p className="text-red-600">{error}</p>}
            </div>
        );
    }
);

Input.displayName = 'Input';

// 3. Your Turn: Create a Card Component
interface CardProps {
    // Your code here
}

export function Card({ children, title, subtitle, className = '' }: CardProps) {
    // Your code here
    return (
        <div className="bg-white rounded-lg shadow-sm p-6">
            {/* Your implementation */}
        </div>
    );
}

// 4. Your Turn: Create a List Component
interface ListProps<T> {
    items: T[];
    renderItem: (item: T, index: number) => ReactNode;
    keyExtractor: (item: T) => string;
    emptyMessage?: string;
}

export function List<T>({
    items,
    renderItem,
    keyExtractor,
    emptyMessage = 'No items'
}: ListProps<T>) {
    // Your code here
    return null;
}

// 5. Test the Components
export function TestComponents() {
    return (
        <div>
            <Button variant="primary">Click Me</Button>
            <Input label="Email" placeholder="Enter email" />
            <Card title="Test Card">
                <p>Card content</p>
            </Card>
            <List
                items={['Item 1', 'Item 2', 'Item 3']}
                renderItem={(item) => <span>{item}</span>}
                keyExtractor={(item) => item}
            />
        </div>
    );
}
```

---

## Exercise 4.2: Custom Hooks

### Objective
Practice creating type-safe custom hooks.

### Instructions
Complete the following custom hooks with proper types.

### Code

```typescript
// File: src/hooks/exercise-4-2.ts

import { useState, useEffect, useCallback } from 'react';

// 1. useLocalStorage Hook
export function useLocalStorage<T>(
    key: string,
    initialValue: T
): [T, (value: T | ((val: T) => T)) => void, () => void] {
    // Read stored value
    const readStoredValue = useCallback((): T => {
        if (typeof window === 'undefined') {
            return initialValue;
        }

        try {
            const item = window.localStorage.getItem(key);
            if (item) {
                return JSON.parse(item) as T;
            }
        } catch (error) {
            console.warn(`Error reading localStorage key "${key}":`, error);
        }

        return initialValue;
    }, [key, initialValue]);

    const [storedValue, setStoredValue] = useState<T>(readStoredValue);

    const setValue = useCallback(
        (value: T | ((val: T) => T)) => {
            // Your code here
        },
        [key, storedValue]
    );

    const removeValue = useCallback(() => {
        // Your code here
    }, [key, initialValue]);

    // Listen for changes from other tabs
    useEffect(() => {
        // Your code here
    }, [key]);

    return [storedValue, setValue, removeValue];
}

// 2. useFetch Hook
type FetchStatus = 'idle' | 'loading' | 'success' | 'error';

interface FetchState<T> {
    data: T | null;
    error: Error | null;
    status: FetchStatus;
}

interface FetchOptions {
    autoFetch?: boolean;
    headers?: HeadersInit;
    onSuccess?: (data: any) => void;
    onError?: (error: Error) => void;
}

export function useFetch<T>(
    url: string,
    options: FetchOptions = {}
): FetchState<T> & { refetch: () => Promise<void> } {
    const { autoFetch = true, headers = {}, onSuccess, onError } = options;

    const [state, setState] = useState<FetchState<T>>({
        data: null,
        error: null,
        status: 'idle'
    });

    const fetchData = useCallback(async () => {
        // Your code here
    }, [url, headers, onSuccess, onError]);

    useEffect(() => {
        if (autoFetch) {
            fetchData();
        }
    }, [autoFetch, fetchData]);

    return {
        ...state,
        refetch: fetchData
    };
}

// 3. useDebounce Hook
export function useDebounce<T>(
    value: T,
    delay: number = 500
): T {
    const [debouncedValue, setDebouncedValue] = useState<T>(value);

    useEffect(() => {
        // Your code here
    }, [value, delay]);

    return debouncedValue;
}

// 4. Your Turn: useToggle Hook
// Returns a boolean value and a function to toggle it
export function useToggle(initialValue: boolean = false): [boolean, () => void] {
    // Your code here
    return [false, () => {}];
}

// 5. Your Turn: usePrevious Hook
// Returns the previous value of a state
export function usePrevious<T>(value: T): T | undefined {
    // Your code here
    return undefined;
}

// 6. Test Your Hooks
export function TestHooks() {
    const [count, setCount] = useState(0);
    const debouncedCount = useDebounce(count, 500);
    const [isOn, toggle] = useToggle(false);
    const previousCount = usePrevious(count);

    return (
        <div>
            <p>Count: {count}</p>
            <p>Debounced: {debouncedCount}</p>
            <p>Previous: {previousCount}</p>
            <p>Toggle: {isOn ? 'ON' : 'OFF'}</p>
            <button onClick={() => setCount(c => c + 1)}>Increment</button>
            <button onClick={toggle}>Toggle</button>
        </div>
    );
}
```

---

## Exercise 4.3: Context and State

### Objective
Practice creating type-safe context and state management.

### Instructions
Complete the following code with type-safe context.

### Code

```tsx
// File: src/context/exercise-4-3.tsx

import React, { createContext, useContext, useReducer, useMemo, ReactNode } from 'react';

// 1. Define State
type Task = {
    id: string;
    title: string;
    completed: boolean;
    priority: 'low' | 'medium' | 'high';
};

interface TaskState {
    tasks: Task[];
    selectedTaskId: string | null;
    isLoading: boolean;
    error: string | null;
    filter: {
        status?: 'completed' | 'active';
        priority?: Task['priority'];
        search?: string;
    };
}

// 2. Define Actions
type TaskAction =
    | { type: 'SET_TASKS'; payload: Task[] }
    | { type: 'ADD_TASK'; payload: Task }
    | { type: 'UPDATE_TASK'; payload: Task }
    | { type: 'DELETE_TASK'; payload: string }
    | { type: 'SELECT_TASK'; payload: string | null }
    | { type: 'SET_LOADING'; payload: boolean }
    | { type: 'SET_ERROR'; payload: string | null }
    | { type: 'SET_FILTER'; payload: Partial<TaskState['filter']> };

// 3. Create Reducer
function taskReducer(state: TaskState, action: TaskAction): TaskState {
    // Your code here
    return state;
}

// 4. Create Context Type
interface TaskContextType {
    state: TaskState;
    dispatch: React.Dispatch<TaskAction>;
    // Convenience methods
    setTasks: (tasks: Task[]) => void;
    addTask: (task: Task) => void;
    updateTask: (task: Task) => void;
    deleteTask: (id: string) => void;
    selectTask: (id: string | null) => void;
    setFilter: (filter: Partial<TaskState['filter']>) => void;
}

// 5. Create Context
const TaskContext = createContext<TaskContextType | undefined>(undefined);

// 6. Create Provider
interface TaskProviderProps {
    children: ReactNode;
    initialTasks?: Task[];
}

export function TaskProvider({ children, initialTasks = [] }: TaskProviderProps) {
    const initialState: TaskState = {
        tasks: initialTasks,
        selectedTaskId: null,
        isLoading: false,
        error: null,
        filter: {}
    };

    const [state, dispatch] = useReducer(taskReducer, initialState);

    const contextValue = useMemo((): TaskContextType => ({
        state,
        dispatch,
        setTasks: (tasks) => dispatch({ type: 'SET_TASKS', payload: tasks }),
        addTask: (task) => dispatch({ type: 'ADD_TASK', payload: task }),
        updateTask: (task) => dispatch({ type: 'UPDATE_TASK', payload: task }),
        deleteTask: (id) => dispatch({ type: 'DELETE_TASK', payload: id }),
        selectTask: (id) => dispatch({ type: 'SELECT_TASK', payload: id }),
        setFilter: (filter) => dispatch({ type: 'SET_FILTER', payload: filter })
    }), [state]);

    return (
        <TaskContext.Provider value={contextValue}>
            {children}
        </TaskContext.Provider>
    );
}

// 7. Create Custom Hook
export function useTasks(): TaskContextType {
    const context = useContext(TaskContext);
    if (context === undefined) {
        throw new Error('useTasks must be used within a TaskProvider');
    }
    return context;
}

// 8. Your Turn: Create a TaskList component that uses the context
export function TaskList() {
    const { state, setFilter } = useTasks();
    
    // Your code here
    return (
        <div>
            {/* List tasks */}
            {/* Add filters */}
        </div>
    );
}

// 9. Test Your Code
export function TestContext() {
    return (
        <TaskProvider initialTasks={[
            { id: '1', title: 'Task 1', completed: false, priority: 'high' },
            { id: '2', title: 'Task 2', completed: true, priority: 'medium' }
        ]}>
            <TaskList />
        </TaskProvider>
    );
}
```

---

## Exercise 4.4: Forms with React Hook Form

### Objective
Practice building type-safe forms with React Hook Form and Zod.

### Instructions
Complete the following form components with proper types.

### Code

```tsx
// File: src/components/exercise-4-4.tsx

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// 1. Create Zod Schema
const TaskSchema = z.object({
    title: z.string()
        .min(3, 'Title must be at least 3 characters')
        .max(100, 'Title must be at most 100 characters'),
    description: z.string()
        .max(500, 'Description must be at most 500 characters')
        .optional(),
    priority: z.enum(['low', 'medium', 'high']),
    status: z.enum(['todo', 'in-progress', 'done']),
    dueDate: z.coerce.date()
        .optional()
        .refine(
            (date) => !date || date > new Date(),
            'Due date must be in the future'
        ),
    tags: z.array(z.string()).default([])
});

// 2. Infer Type
type TaskFormData = z.infer<typeof TaskSchema>;

// 3. Create Form Component
interface TaskFormProps {
    initialData?: Partial<TaskFormData>;
    onSubmit: (data: TaskFormData) => Promise<void> | void;
    onCancel?: () => void;
    isLoading?: boolean;
}

export function TaskForm({
    initialData,
    onSubmit,
    onCancel,
    isLoading = false
}: TaskFormProps) {
    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
        watch,
        setValue
    } = useForm<TaskFormData>({
        resolver: zodResolver(TaskSchema),
        defaultValues: {
            title: initialData?.title || '',
            description: initialData?.description || '',
            priority: initialData?.priority || 'medium',
            status: initialData?.status || 'todo',
            dueDate: initialData?.dueDate || undefined,
            tags: initialData?.tags || []
        }
    });

    const handleFormSubmit = async (data: TaskFormData) => {
        // Your code here
        await onSubmit(data);
    };

    // 4. Your Turn: Add form fields
    return (
        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
            {/* Title Input */}
            <div>
                <label>Title</label>
                <input
                    type="text"
                    {...register('title')}
                    className="w-full px-3 py-2 border rounded"
                />
                {errors.title && (
                    <p className="text-red-600">{errors.title.message}</p>
                )}
            </div>

            {/* Add other fields: description, priority, status, dueDate, tags */}

            {/* Submit and Cancel buttons */}
            <div className="flex gap-2">
                <button
                    type="submit"
                    disabled={isSubmitting || isLoading}
                    className="px-4 py-2 bg-blue-600 text-white rounded"
                >
                    {isSubmitting || isLoading ? 'Saving...' : 'Save'}
                </button>
                {onCancel && (
                    <button
                        type="button"
                        onClick={onCancel}
                        className="px-4 py-2 bg-gray-200 rounded"
                    >
                        Cancel
                    </button>
                )}
            </div>
        </form>
    );
}

// 5. Your Turn: Create a Login Form
type LoginFormData = {
    email: string;
    password: string;
    rememberMe?: boolean;
};

export function LoginForm({
    onLogin,
    isLoading = false
}: {
    onLogin: (data: LoginFormData) => Promise<void>;
    isLoading?: boolean;
}) {
    // Your code here
    return null;
}

// 6. Test Your Code
export function TestForm() {
    const handleSubmit = async (data: TaskFormData) => {
        console.log('Form submitted:', data);
    };

    return (
        <TaskForm
            onSubmit={handleSubmit}
            initialData={{ priority: 'high' }}
        />
    );
}
```

---

## Exercise 4.5: TaskFlow React Components

### Objective
Build the complete TaskFlow React components.

### Instructions
Create a complete set of React components for TaskFlow.

### Code

```tsx
// File: src/components/tasks/TaskList.tsx

import React, { useState } from 'react';
import { useTasks } from '@/context/TaskContext';
import { Button } from '@/components/common/Button';
import { Card } from '@/components/common/Card';
import { TaskForm } from './TaskForm';
import type { Task, TaskStatus } from '@/types/taskflow';

// 1. TaskItem Component
interface TaskItemProps {
    task: Task;
    onSelect: (id: string) => void;
    onDelete: (id: string) => void;
    onStatusChange: (id: string, status: TaskStatus) => void;
}

function TaskItem({ task, onSelect, onDelete, onStatusChange }: TaskItemProps) {
    const [isExpanded, setIsExpanded] = useState(false);

    // Priority colors
    const priorityColors = {
        low: 'bg-green-100 text-green-800',
        medium: 'bg-yellow-100 text-yellow-800',
        high: 'bg-red-100 text-red-800',
        urgent: 'bg-purple-100 text-purple-800'
    };

    // Status emojis
    const statusEmojis = {
        todo: '📝',
        'in-progress': '🔄',
        review: '🔍',
        done: '✅'
    };

    return (
        <div className="border rounded-lg p-4 hover:shadow-md transition-shadow">
            <div className="flex items-center gap-3">
                {/* Status Button */}
                <button
                    onClick={() => {
                        const nextStatus: Record<TaskStatus, TaskStatus> = {
                            todo: 'in-progress',
                            'in-progress': 'review',
                            review: 'done',
                            done: 'todo'
                        };
                        onStatusChange(task.id, nextStatus[task.status]);
                    }}
                    className="text-2xl"
                >
                    {statusEmojis[task.status]}
                </button>

                {/* Title */}
                <div
                    className="flex-1 cursor-pointer"
                    onClick={() => setIsExpanded(!isExpanded)}
                >
                    <h4 className={task.status === 'done' ? 'line-through text-gray-400' : ''}>
                        {task.title}
                    </h4>
                    <div className="flex gap-2 text-sm">
                        <span className={`px-2 py-0.5 rounded-full text-xs ${priorityColors[task.priority]}`}>
                            {task.priority}
                        </span>
                        {task.dueDate && (
                            <span>
                                Due: {new Date(task.dueDate).toLocaleDateString()}
                            </span>
                        )}
                    </div>
                </div>

                {/* Actions */}
                <div className="flex gap-2">
                    <Button size="sm" variant="ghost" onClick={() => onSelect(task.id)}>
                        Edit
                    </Button>
                    <Button size="sm" variant="danger" onClick={() => onDelete(task.id)}>
                        Delete
                    </Button>
                </div>
            </div>

            {/* Expanded Details */}
            {isExpanded && task.description && (
                <div className="mt-3 pt-3 border-t">
                    <p className="text-gray-700">{task.description}</p>
                    {task.tags && task.tags.length > 0 && (
                        <div className="flex gap-1 mt-2">
                            {task.tags.map((tag, i) => (
                                <span key={i} className="px-2 py-0.5 bg-blue-100 text-blue-800 text-xs rounded-full">
                                    #{tag}
                                </span>
                            ))}
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}

// 2. TaskList Component
interface TaskListProps {
    onEditTask: (task: Task) => void;
}

export function TaskList({ onEditTask }: TaskListProps) {
    const { state, setFilter, selectTask, deleteTask, updateTask } = useTasks();
    const [showCreateForm, setShowCreateForm] = useState(false);
    const [filterStatus, setFilterStatus] = useState<TaskStatus | 'all'>('all');
    const [searchTerm, setSearchTerm] = useState('');

    // Filter and sort tasks
    const filteredTasks = state.tasks.filter(task => {
        // Your code here
        return true;
    });

    const sortedTasks = [...filteredTasks].sort((a, b) => {
        // Your code here
        return 0;
    });

    const handleCreateTask = async (data: any) => {
        // Your code here
        setShowCreateForm(false);
    };

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex justify-between">
                <h2 className="text-2xl font-bold">Tasks</h2>
                <Button onClick={() => setShowCreateForm(true)}>
                    + New Task
                </Button>
            </div>

            {/* Filters */}
            <div className="flex gap-3">
                {/* Your code here */}
            </div>

            {/* Create Form */}
            {showCreateForm && (
                <TaskForm
                    projectId="default-project"
                    onSubmit={handleCreateTask}
                    onCancel={() => setShowCreateForm(false)}
                />
            )}

            {/* Task List */}
            <div className="space-y-2">
                {sortedTasks.length === 0 ? (
                    <Card>
                        <div className="text-center py-8 text-gray-500">
                            <p>No tasks found</p>
                        </div>
                    </Card>
                ) : (
                    sortedTasks.map(task => (
                        <TaskItem
                            key={task.id}
                            task={task}
                            onSelect={(id) => {
                                const task = state.tasks.find(t => t.id === id);
                                if (task) onEditTask(task);
                            }}
                            onDelete={(id) => {
                                if (window.confirm('Delete this task?')) {
                                    deleteTask(id);
                                }
                            }}
                            onStatusChange={(id, status) => {
                                const task = state.tasks.find(t => t.id === id);
                                if (task) {
                                    updateTask({ ...task, status });
                                }
                            }}
                        />
                    ))
                )}
            </div>
        </div>
    );
}
```

---

## Practice Problems - Part 4

### Problem 1: Component Props
Create a type for a component that accepts:
- `children` (ReactNode)
- `className` (string, optional)
- `onClick` (function, optional)
- `disabled` (boolean, optional)

### Problem 2: Custom Hook
Create a `useCounter` hook that:
- Accepts an initial value (number, default 0)
- Returns value, increment, decrement, and reset functions

### Problem 3: Context
Create a context for a theme that has:
- `mode`: 'light' | 'dark'
- `toggle`: function

### Problem 4: Form
Create a Zod schema and form for a user profile with:
- `name` (string, required, min 2 chars)
- `email` (string, required, valid email)
- `bio` (string, optional, max 200 chars)
- `age` (number, optional, min 13)

### Problem 5: TaskFlow
Implement the complete TaskFlow components with:
- Task creation
- Task editing
- Task deletion
- Status updates
- Filtering and searching

---

# Part 5: TypeScript in Next.js

## Exercise 5.1: Next.js Setup with TypeScript

### Objective
Set up a Next.js project with TypeScript and configure the App Router.

### Instructions
Create a Next.js project with proper TypeScript configuration.

### Steps

**Step 1: Create the Project**

```bash
npx create-next-app@latest taskflow-next --typescript --tailwind --eslint --app
cd taskflow-next
```

**Step 2: Configure tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@types/*": ["./src/types/*"],
      "@lib/*": ["./src/lib/*"],
      "@server/*": ["./src/server/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@utils/*": ["./src/utils/*"],
      "@validations/*": ["./src/validations/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

**Step 3: Create Project Structure**

```bash
mkdir -p src/app
mkdir -p src/components
mkdir -p src/lib
mkdir -p src/server
mkdir -p src/validations
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/types
```

**Step 4: Create a Type-Safe Page**

```tsx
// File: src/app/page.tsx

import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'TaskFlow',
    description: 'Task management application',
};

export default function HomePage() {
    return (
        <main className="container mx-auto px-4 py-8">
            <h1 className="text-3xl font-bold">Welcome to TaskFlow</h1>
            <p className="mt-4 text-gray-600">
                A type-safe task management application
            </p>
        </main>
    );
}
```

**Step 5: Your Turn: Create a Dashboard Page**

```tsx
// File: src/app/dashboard/page.tsx

// Your code here
```

---

## Exercise 5.2: Server Actions

### Objective
Create type-safe server actions for TaskFlow.

### Instructions
Complete the following server actions with proper types.

### Code

```typescript
// File: src/server/actions/taskActions.ts

'use server';

import { prisma } from '@/lib/prisma';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import { TaskSchema } from '@/validations/taskValidation';

// 1. Get All Tasks
export async function getTasks(projectId?: string) {
    try {
        const tasks = await prisma.task.findMany({
            where: projectId ? { projectId } : undefined,
            include: {
                assignee: {
                    select: { id: true, name: true, email: true }
                },
                creator: {
                    select: { id: true, name: true, email: true }
                }
            },
            orderBy: { updatedAt: 'desc' }
        });

        return { success: true, data: tasks };
    } catch (error) {
        console.error('Error fetching tasks:', error);
        return { success: false, error: 'Failed to fetch tasks' };
    }
}

// 2. Create Task
export async function createTask(input: z.infer<typeof TaskSchema>) {
    try {
        const validation = TaskSchema.safeParse(input);
        if (!validation.success) {
            return {
                success: false,
                error: 'Validation failed',
                details: validation.error.errors
            };
        }

        const task = await prisma.task.create({
            data: {
                title: validation.data.title,
                description: validation.data.description,
                status: validation.data.status,
                priority: validation.data.priority,
                projectId: validation.data.projectId,
                createdBy: validation.data.createdBy,
                assigneeId: validation.data.assigneeId,
                dueDate: validation.data.dueDate,
                tags: validation.data.tags || []
            }
        });

        revalidatePath('/tasks');
        return { success: true, data: task };
    } catch (error) {
        console.error('Error creating task:', error);
        return { success: false, error: 'Failed to create task' };
    }
}

// 3. Your Turn: Update Task
export async function updateTask(
    id: string,
    input: Partial<z.infer<typeof TaskSchema>>
) {
    // Your code here
    return { success: false, error: 'Not implemented' };
}

// 4. Your Turn: Delete Task
export async function deleteTask(id: string) {
    // Your code here
    return { success: false, error: 'Not implemented' };
}

// 5. Your Turn: Update Task Status
export async function updateTaskStatus(
    id: string,
    status: 'todo' | 'in-progress' | 'review' | 'done'
) {
    // Your code here
    return { success: false, error: 'Not implemented' };
}

// 6. Your Turn: Add Comment
export async function addComment(
    taskId: string,
    userId: string,
    content: string
) {
    // Your code here
    return { success: false, error: 'Not implemented' };
}

// 7. Test Your Code
// Create a client component that uses these server actions
// Example:
// const result = await createTask({ title: 'Test Task', ... });
// if (result.success) {
//     console.log('Task created:', result.data);
// }
```

---

## Exercise 5.3: API Routes

### Objective
Create type-safe API routes for TaskFlow.

### Instructions
Complete the following API routes with proper types.

### Code

```typescript
// File: src/app/api/tasks/route.ts

import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaskSchema } from '@/validations/taskValidation';

// 1. GET /api/tasks
export async function GET(request: Request) {
    try {
        const { searchParams } = new URL(request.url);
        const projectId = searchParams.get('projectId');
        const status = searchParams.get('status');
        const priority = searchParams.get('priority');

        const where: any = {};
        if (projectId) where.projectId = projectId;
        if (status) where.status = status;
        if (priority) where.priority = priority;

        const tasks = await prisma.task.findMany({
            where,
            include: {
                assignee: {
                    select: { id: true, name: true, email: true }
                },
                creator: {
                    select: { id: true, name: true, email: true }
                }
            },
            orderBy: { updatedAt: 'desc' }
        });

        return NextResponse.json({
            success: true,
            data: tasks,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('GET /api/tasks error:', error);
        return NextResponse.json(
            {
                success: false,
                error: 'Failed to fetch tasks',
                timestamp: new Date().toISOString()
            },
            { status: 500 }
        );
    }
}

// 2. POST /api/tasks
export async function POST(request: Request) {
    try {
        const body = await request.json();
        const validation = TaskSchema.safeParse(body);

        if (!validation.success) {
            return NextResponse.json(
                {
                    success: false,
                    error: 'Validation failed',
                    details: validation.error.errors,
                    timestamp: new Date().toISOString()
                },
                { status: 400 }
            );
        }

        const task = await prisma.task.create({
            data: {
                title: validation.data.title,
                description: validation.data.description,
                status: validation.data.status,
                priority: validation.data.priority,
                projectId: validation.data.projectId,
                createdBy: validation.data.createdBy,
                assigneeId: validation.data.assigneeId,
                dueDate: validation.data.dueDate,
                tags: validation.data.tags || []
            }
        });

        return NextResponse.json({
            success: true,
            data: task,
            timestamp: new Date().toISOString()
        }, { status: 201 });
    } catch (error) {
        console.error('POST /api/tasks error:', error);
        return NextResponse.json(
            {
                success: false,
                error: 'Failed to create task',
                timestamp: new Date().toISOString()
            },
            { status: 500 }
        );
    }
}

// 3. Your Turn: GET /api/tasks/[id]
// File: src/app/api/tasks/[id]/route.ts
export async function GET(
    request: Request,
    { params }: { params: { id: string } }
) {
    // Your code here
}

// 4. Your Turn: PUT /api/tasks/[id]
export async function PUT(
    request: Request,
    { params }: { params: { id: string } }
) {
    // Your code here
}

// 5. Your Turn: DELETE /api/tasks/[id]
export async function DELETE(
    request: Request,
    { params }: { params: { id: string } }
) {
    // Your code here
}
```

---

## Exercise 5.4: Environment Variables

### Objective
Create type-safe environment variables for Next.js.

### Instructions
Complete the following environment variable configuration.

### Code

```typescript
// File: src/lib/env.ts

import { z } from 'zod';

// 1. Define Environment Schema
const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'production', 'test']),
    DATABASE_URL: z.string().min(1),
    JWT_SECRET: z.string().min(32),
    NEXT_PUBLIC_API_URL: z.string().url().optional(),
    NEXT_PUBLIC_APP_NAME: z.string().default('TaskFlow'),
    // Your Turn: Add more environment variables
    // DATABASE_CONNECTION_LIMIT: z.string().optional().default('10'),
    // REDIS_URL: z.string().optional(),
    // SENTRY_DSN: z.string().url().optional(),
});

// 2. Validate Environment
const env = envSchema.safeParse(process.env);

if (!env.success) {
    console.error('❌ Invalid environment variables:', env.error.format());
    throw new Error('Invalid environment variables');
}

// 3. Export Type-Safe Variables
export const env = env.data;

// 4. Export Type
export type Env = z.infer<typeof envSchema>;

// 5. Your Turn: Create a Prisma client with environment variables
// File: src/lib/prisma.ts

import { PrismaClient } from '@prisma/client';
import { env } from './env';

declare global {
    var prisma: PrismaClient | undefined;
}

export const prisma = global.prisma || new PrismaClient({
    log: env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

if (env.NODE_ENV !== 'production') {
    global.prisma = prisma;
}

// 6. Your Turn: Create a validation script
// File: scripts/validate-env.ts
// Run this during CI/CD
```

---

## Exercise 5.5: TaskFlow Next.js Implementation

### Objective
Build the complete TaskFlow application with Next.js.

### Instructions
Create the full Next.js implementation of TaskFlow.

### Code

```tsx
// File: src/app/tasks/page.tsx

import { prisma } from '@/lib/prisma';
import { TaskList } from '@/components/tasks/TaskList';
import { CreateTaskButton } from '@/components/tasks/CreateTaskButton';
import type { Task } from '@prisma/client';

// Server Component
export default async function TasksPage() {
    // Fetch tasks on the server
    const tasks = await prisma.task.findMany({
        include: {
            assignee: {
                select: {
                    id: true,
                    name: true,
                    email: true,
                    avatarUrl: true
                }
            },
            creator: {
                select: {
                    id: true,
                    name: true,
                    email: true
                }
            }
        },
        orderBy: { updatedAt: 'desc' }
    });

    const projects = await prisma.project.findMany({
        select: { id: true, name: true }
    });

    return (
        <div className="container mx-auto px-4 py-8">
            <div className="flex justify-between items-center mb-8">
                <div>
                    <h1 className="text-3xl font-bold">Tasks</h1>
                    <p className="text-gray-600">Manage and track your tasks</p>
                </div>
                <CreateTaskButton projects={projects} />
            </div>

            <TaskList initialTasks={tasks as Task[]} projects={projects} />
        </div>
    );
}

// Your Turn: Create a task detail page
// File: src/app/tasks/[id]/page.tsx

// Your Turn: Create a project page
// File: src/app/projects/page.tsx

// Your Turn: Create a project detail page
// File: src/app/projects/[id]/page.tsx

// Your Turn: Create an API health check
// File: src/app/api/health/route.ts
```

---

## Practice Problems - Part 5

### Problem 1: Server Action
Create a server action that:
- Accepts a project ID
- Returns all tasks for that project
- Includes assignee and creator information

### Problem 2: API Route
Create an API route that:
- GET /api/projects
- Returns all projects with task counts

### Problem 3: Environment Variable
Add a new environment variable:
- `NEXT_PUBLIC_APP_URL` (string, URL, optional)

### Problem 4: Page
Create a Next.js page that:
- Uses server-side rendering
- Fetches data from the database
- Displays a list of projects

### Problem 5: Complete Feature
Implement the complete task assignment feature with:
- Server action for assignment
- API route for assignment
- UI component for assignment
- Type-safe environment variables

---

# Part 6: Architecture, Testing, and Debugging

## Exercise 6.1: Unit Testing

### Objective
Practice writing type-safe unit tests with Vitest.

### Instructions
Complete the following unit tests.

### Code

```typescript
// File: src/lib/validation.test.ts

import { describe, it, expect } from 'vitest';
import { TaskSchema, ProjectSchema } from '@/validations/taskValidation';

describe('TaskSchema', () => {
    const validTask = {
        title: 'Test Task',
        status: 'todo',
        priority: 'medium',
        projectId: 'proj_123',
        createdBy: 'user_123',
        tags: ['test', 'validation']
    };

    it('should validate a valid task', () => {
        const result = TaskSchema.safeParse(validTask);
        expect(result.success).toBe(true);
        if (result.success) {
            expect(result.data.title).toBe('Test Task');
            expect(result.data.status).toBe('todo');
        }
    });

    it('should reject a task with short title', () => {
        const invalidTask = { ...validTask, title: 'Hi' };
        const result = TaskSchema.safeParse(invalidTask);
        expect(result.success).toBe(false);
        if (!result.success) {
            expect(result.error.issues[0].message).toContain('at least 3');
        }
    });

    // Your Turn: Test that description is optional
    it('should accept tasks without description', () => {
        // Your code here
    });

    // Your Turn: Test that due date must be in the future
    it('should reject past due dates', () => {
        // Your code here
    });

    // Your Turn: Test valid priority values
    it('should only accept valid priorities', () => {
        // Your code here
    });
});

describe('ProjectSchema', () => {
    // Your Turn: Write tests for ProjectSchema
    // Test: Valid project
    // Test: Name required and min length
    // Test: MemberIds optional
    
    it('should validate a valid project', () => {
        // Your code here
    });
});

// Your Turn: Test utility functions
describe('Utility Functions', () => {
    it('should format dates correctly', () => {
        // Your code here
    });

    it('should validate email addresses', () => {
        // Your code here
    });
});
```

---

## Exercise 6.2: Component Testing

### Objective
Practice writing type-safe component tests.

### Instructions
Complete the following component tests.

### Code

```tsx
// File: src/components/tasks/TaskList.test.tsx

import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TaskList } from './TaskList';

// Mock server actions
vi.mock('@/server/actions/taskActions', () => ({
    updateTaskStatus: vi.fn().mockResolvedValue({ success: true }),
    deleteTask: vi.fn().mockResolvedValue({ success: true }),
}));

describe('TaskList', () => {
    const mockTasks = [
        {
            id: '1',
            title: 'Task 1',
            status: 'todo',
            priority: 'high',
            projectId: 'proj_1',
            createdBy: 'user_1',
            tags: ['test'],
            description: 'Test description',
            dueDate: new Date('2026-02-01'),
            createdAt: new Date(),
            updatedAt: new Date(),
            assigneeId: null,
        },
        {
            id: '2',
            title: 'Task 2',
            status: 'done',
            priority: 'low',
            projectId: 'proj_1',
            createdBy: 'user_1',
            tags: [],
            description: null,
            dueDate: null,
            createdAt: new Date(),
            updatedAt: new Date(),
            assigneeId: null,
        },
    ];

    const mockProjects = [{ id: 'proj_1', name: 'Project 1' }];

    // Your Turn: Test that tasks render
    it('should render tasks', () => {
        render(<TaskList initialTasks={mockTasks} projects={mockProjects} />);
        expect(screen.getByText('Task 1')).toBeInTheDocument();
        expect(screen.getByText('Task 2')).toBeInTheDocument();
    });

    // Your Turn: Test filtering
    it('should filter tasks by status', async () => {
        // Your code here
    });

    // Your Turn: Test searching
    it('should search tasks by title', async () => {
        // Your code here
    });

    // Your Turn: Test expanding
    it('should expand to show description', async () => {
        // Your code here
    });

    // Your Turn: Test status change
    it('should handle status change', async () => {
        // Your code here
    });

    // Your Turn: Test deletion
    it('should handle task deletion', async () => {
        // Your code here
    });

    // Your Turn: Test empty state
    it('should show empty state when no tasks', () => {
        // Your code here
    });
});
```

---

## Exercise 6.3: Integration Testing

### Objective
Practice writing type-safe integration tests.

### Instructions
Complete the following integration tests.

### Code

```typescript
// File: src/app/api/tasks/route.test.ts

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { GET, POST } from './route';
import { prisma } from '@/lib/prisma';

vi.mock('@/lib/prisma', () => ({
    prisma: {
        task: {
            findMany: vi.fn(),
            create: vi.fn(),
        },
    },
}));

describe('Tasks API', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('GET /api/tasks', () => {
        // Your Turn: Test successful fetch
        it('should return tasks', async () => {
            const mockTasks = [{ id: '1', title: 'Task 1' }];
            (prisma.task.findMany as any).mockResolvedValue(mockTasks);

            const request = new Request('http://localhost:3000/api/tasks');
            const response = await GET(request);
            const data = await response.json();

            expect(response.status).toBe(200);
            expect(data.success).toBe(true);
            expect(data.data).toEqual(mockTasks);
        });

        // Your Turn: Test filtering
        it('should filter tasks by projectId', async () => {
            // Your code here
        });

        // Your Turn: Test error handling
        it('should handle errors gracefully', async () => {
            (prisma.task.findMany as any).mockRejectedValue(new Error('Database error'));

            const request = new Request('http://localhost:3000/api/tasks');
            const response = await GET(request);
            const data = await response.json();

            expect(response.status).toBe(500);
            expect(data.success).toBe(false);
        });
    });

    describe('POST /api/tasks', () => {
        const validTask = {
            title: 'New Task',
            status: 'todo',
            priority: 'medium',
            projectId: 'proj_1',
            createdBy: 'user_1',
            tags: ['test'],
        };

        // Your Turn: Test successful creation
        it('should create a task', async () => {
            // Your code here
        });

        // Your Turn: Test validation
        it('should reject invalid task data', async () => {
            const invalidTask = { ...validTask, title: 'Hi' };
            // Your code here
        });

        // Your Turn: Test missing fields
        it('should handle missing fields', async () => {
            const invalidTask = { title: 'Test' };
            // Your code here
        });
    });
});

// Your Turn: Test server actions
// File: src/server/actions/taskActions.test.ts

describe('Task Actions', () => {
    // Test: createTask
    // Test: getTasks
    // Test: updateTask
    // Test: deleteTask
    // Test: error handling
});
```

---

## Exercise 6.4: Debugging

### Objective
Practice debugging TypeScript applications.

### Instructions
Complete the following debugging exercises.

### Code

```typescript
// File: src/utils/debugging.ts

// 1. Create a Logger class
class Logger {
    constructor(private context: Record<string, any> = {}) {}

    log(level: 'debug' | 'info' | 'warn' | 'error', message: string, meta?: any) {
        const timestamp = new Date().toISOString();
        const logEntry = {
            timestamp,
            level,
            message,
            context: this.context,
            meta,
        };

        // Your code here: Format and output the log
        console.log(`[${timestamp}] ${level.toUpperCase()}:`, {
            ...logEntry,
        });
    }

    debug(message: string, meta?: any) {
        this.log('debug', message, meta);
    }

    info(message: string, meta?: any) {
        this.log('info', message, meta);
    }

    warn(message: string, meta?: any) {
        this.log('warn', message, meta);
    }

    error(message: string, meta?: any) {
        this.log('error', message, meta);
    }

    child(newContext: Record<string, any>) {
        return new Logger({
            ...this.context,
            ...newContext,
        });
    }
}

// 2. Create an assertion utility
function assertNonNull<T>(
    value: T | null | undefined,
    message?: string
): asserts value is T {
    if (value === null || value === undefined) {
        throw new Error(message || 'Value is null or undefined');
    }
}

// 3. Create a performance measurement utility
function measurePerformance<T>(
    fn: () => T,
    label: string
): T {
    if (process.env.NODE_ENV === 'development') {
        console.time(label);
        try {
            return fn();
        } finally {
            console.timeEnd(label);
        }
    }
    return fn();
}

// 4. Your Turn: Create an error formatting utility
function formatError(error: unknown): string {
    // Your code here
    return '';
}

// 5. Your Turn: Create a type debugger
type Debug<T> = T extends any ? { [K in keyof T]: T[K] } : never;

// 6. Test Your Code
export function testDebugging() {
    const logger = new Logger({ component: 'TestComponent' });
    
    logger.info('Test message', { data: 'test' });
    logger.error('Error message', { error: 'Test error' });

    const childLogger = logger.child({ action: 'test_action' });
    childLogger.debug('Child log', { details: 'Testing' });

    const value: string | undefined = 'hello';
    assertNonNull(value, 'Value must exist');
    console.log(value.toUpperCase());

    const result = measurePerformance(() => {
        return Array.from({ length: 1000 }, (_, i) => i);
    }, 'Array creation');

    console.log('Performance result:', result.length);
}
```

---

## Exercise 6.5: Architecture Patterns

### Objective
Implement clean architecture patterns with TypeScript.

### Instructions
Complete the following architecture implementation.

### Code

```typescript
// File: src/lib/architecture.ts

// 1. Domain Layer (Entities)
interface DomainTask {
    id: string;
    title: string;
    status: 'todo' | 'in-progress' | 'done';
    priority: 'low' | 'medium' | 'high';
}

// 2. Domain Service
class TaskDomainService {
    canCompleteTask(task: DomainTask): boolean {
        // Your code here
        return false;
    }

    estimateTime(task: DomainTask): number {
        // Your code here
        return 0;
    }
}

// 3. Application Layer (Use Cases)
interface CreateTaskDTO {
    title: string;
    priority: 'low' | 'medium' | 'high';
}

interface ITaskUseCases {
    createTask(dto: CreateTaskDTO): Promise<DomainTask>;
    getTask(id: string): Promise<DomainTask>;
    getTasks(): Promise<DomainTask[]>;
    completeTask(id: string): Promise<DomainTask>;
}

// 4. Infrastructure Layer (Repository)
interface ITaskRepository {
    create(task: Omit<DomainTask, 'id'>): Promise<DomainTask>;
    findById(id: string): Promise<DomainTask | null>;
    findMany(): Promise<DomainTask[]>;
    update(id: string, task: Partial<DomainTask>): Promise<DomainTask>;
    delete(id: string): Promise<void>;
}

// 5. Your Turn: Implement the repository with Prisma
class PrismaTaskRepository implements ITaskRepository {
    constructor(private prisma: any) {}

    async create(task: Omit<DomainTask, 'id'>): Promise<DomainTask> {
        // Your code here
        throw new Error('Not implemented');
    }

    async findById(id: string): Promise<DomainTask | null> {
        // Your code here
        return null;
    }

    async findMany(): Promise<DomainTask[]> {
        // Your code here
        return [];
    }

    async update(id: string, task: Partial<DomainTask>): Promise<DomainTask> {
        // Your code here
        throw new Error('Not implemented');
    }

    async delete(id: string): Promise<void> {
        // Your code here
    }
}

// 6. Your Turn: Implement the use cases
class TaskUseCases implements ITaskUseCases {
    constructor(
        private taskRepo: ITaskRepository,
        private domainService: TaskDomainService
    ) {}

    async createTask(dto: CreateTaskDTO): Promise<DomainTask> {
        // Your code here
        throw new Error('Not implemented');
    }

    async getTask(id: string): Promise<DomainTask> {
        // Your code here
        throw new Error('Not implemented');
    }

    async getTasks(): Promise<DomainTask[]> {
        // Your code here
        return [];
    }

    async completeTask(id: string): Promise<DomainTask> {
        // Your code here
        throw new Error('Not implemented');
    }
}

// 7. Dependency Injection Container
class Container {
    private static instance: Container;
    private services = new Map<string, any>();

    private constructor() {}

    static getInstance(): Container {
        if (!Container.instance) {
            Container.instance = new Container();
        }
        return Container.instance;
    }

    register<T>(key: string, instance: T): void {
        this.services.set(key, instance);
    }

    get<T>(key: string): T {
        const service = this.services.get(key);
        if (!service) {
            throw new Error(`Service ${key} not found`);
        }
        return service;
    }
}

// 8. Your Turn: Configure the container
Container.configure = function() {
    const container = Container.getInstance();
    // Your code here: Register all services
};

// 9. Test Your Code
export function testArchitecture() {
    // Your code here: Demonstrate the architecture
    console.log('Architecture test completed');
}
```

---

## Exercise 6.6: Production Readiness

### Objective
Prepare a TypeScript application for production.

### Instructions
Complete the following production readiness checklist.

### Code

```typescript
// File: scripts/check-production.ts

// 1. Environment Validation
function validateEnvironment() {
    // Your code here
    console.log('✅ Environment validated');
}

// 2. Type Checking
function checkTypes() {
    // Your code here
    console.log('✅ Types checked');
}

// 3. Test Run
function runTests() {
    // Your code here
    console.log('✅ Tests passed');
}

// 4. Lint Check
function runLint() {
    // Your code here
    console.log('✅ Lint passed');
}

// 5. Bundle Size Check
function checkBundleSize() {
    // Your code here
    console.log('✅ Bundle size OK');
}

// 6. Run All Checks
async function runProductionChecks() {
    console.log('🔍 Running production checks...');
    
    validateEnvironment();
    checkTypes();
    runTests();
    runLint();
    checkBundleSize();
    
    console.log('✅ All checks passed!');
}

// 7. Your Turn: Health Check Endpoint
// File: src/app/api/health/route.ts

// 8. Your Turn: Performance Monitoring
// File: src/lib/monitoring.ts

// 9. Your Turn: Error Tracking
// File: src/lib/sentry.ts

// 10. Your Turn: Security Headers
// File: next.config.js
```

---

## Practice Problems - Part 6

### Problem 1: Unit Test
Write a unit test for a function that validates email addresses.

### Problem 2: Component Test
Write a component test for a login form that:
- Renders the form
- Handles input changes
- Submits the form

### Problem 3: Integration Test
Write an integration test for the task creation API endpoint.

### Problem 4: Debugging
Write a utility that formats API errors for display.

### Problem 5: Architecture
Implement the repository pattern for a User entity.

### Problem 6: Production
Create a health check endpoint that verifies:
- Database connection
- API status
- Memory usage

---

# Final Capstone Project

## Complete TaskFlow Application

### Objective
Build the complete TaskFlow application from end-to-end.

### Requirements

**Backend (Next.js)**
- [ ] Type-safe API routes
- [ ] Server actions
- [ ] Database with Prisma
- [ ] Environment validation
- [ ] Authentication (optional)

**Frontend (React)**
- [ ] Type-safe components
- [ ] Custom hooks
- [ ] Context for state
- [ ] Forms with validation
- [ ] Responsive UI

**Testing**
- [ ] Unit tests
- [ ] Component tests
- [ ] Integration tests
- [ ] E2E tests (optional)

**Production**
- [ ] Build optimization
- [ ] Error tracking
- [ ] Performance monitoring
- [ ] Health checks
- [ ] Documentation

### Deliverables

1. Complete source code with TypeScript
2. Tests with Vitest
3. Documentation (README)
4. Deployment script

### Checklist

```
☐ Project Setup
☐ Database Schema
☐ Core Types
☐ API Routes
☐ Server Actions
☐ UI Components
☐ State Management
☐ Forms
☐ Testing
☐ Production Ready
☐ Documentation
☐ Deployment
```

---

# Answer Key

## Part 1 Answers

### Exercise 1.2
```
1. Type Inference:
   firstName = string
   age = number
   isActive = boolean
   scores = number[]
   mixed = (string | number)[]

3. Arrays:
   const tasks: string[] = ["Write code", "Test", "Deploy"];
   const taskIds: number[] = [1, 2, 3, 4, 5];
   const mixedArray: (string | number)[] = ["task_1", 2, "task_3", 4];

4. Functions:
   function greet(name: string): string
   function calculateTotal(items: any[]): number
   function processInput(input: string | number): string | number
```

### Exercise 1.4
```typescript
function processValue(value: Value): string {
    if (typeof value === 'string') {
        return `String: ${value.toUpperCase()}`;
    }
    if (typeof value === 'number') {
        return `Number: ${value.toFixed(2)}`;
    }
    if (typeof value === 'boolean') {
        return `Boolean: ${value ? 'true' : 'false'}`;
    }
    return `Nullish: ${String(value)}`;
}

function getStatusMessage(status: Status): string {
    if (status === 'pending') return '⏳ Pending...';
    if (status === 'active') return '✅ Active';
    if (status === 'completed') return '🎯 Completed';
    return '📦 Archived';
}

function handleEvent(event: Event): string {
    switch (event.type) {
        case 'click':
            return `Click at (${event.x}, ${event.y})`;
        case 'keypress':
            return `Key: ${event.key}`;
        case 'submit':
            return `Form ${event.formId} submitted`;
        default:
            const exhaustiveCheck: never = event;
            return exhaustiveCheck;
    }
}
```

## Part 2 Answers

### Exercise 2.2
```typescript
function filter<T>(items: T[], predicate: (item: T) => boolean): T[] {
    const result: T[] = [];
    for (const item of items) {
        if (predicate(item)) {
            result.push(item);
        }
    }
    return result;
}

function map<T, U>(items: T[], transform: (item: T) => U): U[] {
    const result: U[] = [];
    for (const item of items) {
        result.push(transform(item));
    }
    return result;
}

class Repository<T extends { id: string }> {
    private items: T[] = [];

    add(item: T): void {
        this.items.push(item);
    }

    findById(id: string): T | undefined {
        return this.items.find(item => item.id === id);
    }

    findAll(): T[] {
        return [...this.items];
    }

    delete(id: string): boolean {
        const index = this.items.findIndex(item => item.id === id);
        if (index === -1) return false;
        this.items.splice(index, 1);
        return true;
    }

    update(id: string, updates: Partial<T>): T | undefined {
        const item = this.findById(id);
        if (!item) return undefined;
        Object.assign(item, updates);
        return item;
    }
}
```

## Part 3 Answers

### Exercise 3.1
```typescript
type IsArray<T> = T extends any[] ? true : false;
type First<T extends any[]> = T extends [infer First, ...any[]] ? First : never;
type Last<T extends any[]> = T extends [...any[], infer Last] ? Last : never;
type Flatten<T> = T extends any[] ? T[number] : T;
```

## Part 4 Answers

### Exercise 4.1
```typescript
interface CardProps {
    children: ReactNode;
    title?: string;
    subtitle?: string;
    className?: string;
    headerActions?: ReactNode;
    footer?: ReactNode;
}

export function Card({ children, title, subtitle, className = '' }: CardProps) {
    return (
        <div className={`bg-white rounded-lg shadow-sm ${className}`}>
            {title && <div className="px-6 py-4 border-b">
                <h3 className="text-lg font-semibold">{title}</h3>
                {subtitle && <p className="text-sm text-gray-500">{subtitle}</p>}
            </div>}
            <div className="px-6 py-4">{children}</div>
        </div>
    );
}

export function List<T>({
    items,
    renderItem,
    keyExtractor,
    emptyMessage = 'No items'
}: ListProps<T>) {
    if (items.length === 0) {
        return <p className="text-gray-500">{emptyMessage}</p>;
    }
    return (
        <div className="space-y-2">
            {items.map((item, index) => (
                <div key={keyExtractor(item)}>
                    {renderItem(item, index)}
                </div>
            ))}
        </div>
    );
}
```

## Part 5 Answers

### Exercise 5.2
```typescript
export async function updateTask(
    id: string,
    input: Partial<z.infer<typeof TaskSchema>>
) {
    try {
        const validation = TaskSchema.partial().safeParse(input);
        if (!validation.success) {
            return {
                success: false,
                error: 'Validation failed',
                details: validation.error.errors
            };
        }

        const task = await prisma.task.update({
            where: { id },
            data: {
                ...validation.data,
                updatedAt: new Date()
            }
        });

        revalidatePath('/tasks');
        revalidatePath(`/tasks/${id}`);
        return { success: true, data: task };
    } catch (error) {
        console.error('Error updating task:', error);
        return { success: false, error: 'Failed to update task' };
    }
}

export async function deleteTask(id: string) {
    try {
        await prisma.task.delete({ where: { id } });
        revalidatePath('/tasks');
        return { success: true };
    } catch (error) {
        console.error('Error deleting task:', error);
        return { success: false, error: 'Failed to delete task' };
    }
}
```

## Part 6 Answers

### Exercise 6.3
```typescript
it('should filter tasks by projectId', async () => {
    const request = new Request(
        'http://localhost:3000/api/tasks?projectId=proj_1'
    );
    await GET(request);

    expect(prisma.task.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
            where: expect.objectContaining({
                projectId: 'proj_1',
            }),
        })
    );
});

it('should create a task', async () => {
    const createdTask = { 
        ...validTask, 
        id: 'new_1', 
        createdAt: new Date(), 
        updatedAt: new Date() 
    };
    (prisma.task.create as any).mockResolvedValue(createdTask);

    const request = new Request('http://localhost:3000/api/tasks', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(validTask),
    });

    const response = await POST(request);
    const data = await response.json();

    expect(response.status).toBe(201);
    expect(data.success).toBe(true);
    expect(data.data).toEqual(createdTask);
});
```

---

# Final Notes

Congratulations on completing the Mastering TypeScript Student Workbook!

## Next Steps

1. **Build Your Own Project**: Apply what you've learned to build a personal project
2. **Contribute to Open Source**: Find TypeScript projects on GitHub
3. **Share Your Knowledge**: Write blog posts or create tutorials
4. **Continue Learning**: Explore advanced TypeScript topics

## Additional Resources

- TypeScript Handbook: typescriptlang.org/docs
- React TypeScript Cheatsheet: github.com/typescript-cheatsheets/react
- Next.js TypeScript: nextjs.org/docs/app/building-your-application/configuring/typescript
- Zod Documentation: zod.dev
- Vitest Documentation: vitest.dev

---

**End of Workbook**
