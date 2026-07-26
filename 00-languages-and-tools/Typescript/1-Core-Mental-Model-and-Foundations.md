# Part 1: Core Mental Model and Foundations

## 1.1 What TypeScript Really Is (And Isn't)

Before we write a single line of TypeScript, let's understand what we're working with.

### The Mental Shift: Compile-Time vs. Runtime

When you write JavaScript, you're writing code that runs in a browser or Node.js environment. If you make a mistake—like calling a method that doesn't exist—you won't know until you run the code and hit that specific line.

**JavaScript Runtime Model:**
```
Write Code → Run Code → Hit Error → Fix Error → Repeat
```

TypeScript adds a step before running: **compile-time checking**. It reads your code, analyzes it, and catches mistakes before your code ever runs.

**TypeScript Compile-Time Model:**
```
Write Code → Type Check → Fix Errors → Run Code → 🎉 Fewer Runtime Errors
```

### The "TypeScript Is a Layer" Analogy

Think of TypeScript like a proofreader for your code. When you write an essay, you might:
1. Write the content (JavaScript runtime logic)
2. Have a proofreader check it (TypeScript compiler)
3. Fix any grammar/spelling mistakes (type errors)
4. Submit the essay (run the code)

The proofreader doesn't change your essay's content—it just ensures it's correctly written. TypeScript does the same: it checks your code's structure without changing how it runs.

### Important Truths About TypeScript

1. **TypeScript is a superset of JavaScript:** All valid JavaScript is valid TypeScript. You can take any `.js` file, rename it to `.ts`, and it will compile (though you might get type warnings).

2. **TypeScript types don't exist at runtime:** This is crucial. When your code runs, TypeScript types have been stripped away. There's no `string` or `number` type checking at runtime—TypeScript only checks during compilation.

3. **TypeScript is a development tool:** It helps you write better code, but it doesn't make your code faster or more efficient. It's about developer experience and code quality.

4. **TypeScript prevents many (but not all) bugs:** It won't catch logic errors or business rule violations, but it will catch type-related errors like passing a string where a number is expected.

## 1.2 Setting Up Your First TypeScript Project

Let's create our TaskFlow project with TypeScript support.

### Step 1: Initialize the Project

Open your terminal and navigate to your project folder:

```bash
cd ~/taskflow-tutorial  # or wherever you created it
npm init -y
```

This creates a `package.json` file with default values.

### Step 2: Install TypeScript and Node Types

```bash
npm install --save-dev typescript @types/node
```

Here's what each package does:
- `typescript`: The TypeScript compiler and language services
- `@types/node`: Type definitions for Node.js built-in modules (like `fs`, `path`, etc.)

### Step 3: Initialize TypeScript Configuration

```bash
npx tsc --init
```

This creates a `tsconfig.json` file with default settings. We'll customize it heavily.

### Step 4: Configure TypeScript for Production

**File:** `tsconfig.json`

```json
{
  "compilerOptions": {
    // --- Type Checking Settings ---
    "strict": true,                      // Enable all strict type-checking options
    "noImplicitAny": true,               // Raise error on any expression/declaration with an implied 'any'
    "strictNullChecks": true,            // Ensure null and undefined are handled explicitly
    "strictFunctionTypes": true,         // Ensure function parameter types are checked strictly
    "strictBindCallApply": true,         // Check that bind/call/apply use correct argument types
    "strictPropertyInitialization": true, // Ensure class properties are initialized
    "noImplicitThis": true,              // Raise error when 'this' has type 'any'
    "useUnknownInCatchVariables": true,  // Make catch clause variables 'unknown' instead of 'any'

    // --- Module Resolution Settings ---
    "module": "NodeNext",                // Use Node.js module resolution (ES modules)
    "moduleResolution": "NodeNext",      // Resolve modules using Node.js algorithm
    "target": "ES2022",                  // Compile to modern JavaScript (supports async/await, etc.)
    "lib": ["ES2022", "DOM"],            // Include type definitions for these environments

    // --- Output Settings ---
    "outDir": "./dist",                  // Place compiled JavaScript here
    "rootDir": "./src",                  // Look for TypeScript files here
    "sourceMap": true,                   // Generate source maps for debugging

    // --- Interoperability ---
    "esModuleInterop": true,             // Enable default imports from CommonJS modules
    "allowSyntheticDefaultImports": true, // Allow default imports from modules without default export
    "forceConsistentCasingInFileNames": true, // Ensure file names are case-sensitive

    // --- Additional Settings ---
    "skipLibCheck": true,                // Skip type checking of declaration files (faster builds)
    "resolveJsonModule": true,           // Allow importing JSON files
    "isolatedModules": true,             // Ensures each file can be transpiled independently
    "noUncheckedIndexedAccess": true,    // Ensure array/object access returns possibly undefined
    "noFallthroughCasesInSwitch": true,  // Prevent fall-through in switch statements
    "noPropertyAccessFromIndexSignature": true, // Require using .get() for dynamic properties
    "exactOptionalPropertyTypes": true   // Treat optional properties as exactly that—optional
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"], // Which files to compile
  "exclude": ["node_modules", "dist"]          // Which files to ignore
}
```

💡 **Pro Tip:** `"strict": true` is TypeScript's recommended setting for new projects. It enables a set of strict type-checking options that catch many common errors. We'll keep these settings throughout the series.

### Step 5: Create the Project Structure

```bash
mkdir src
mkdir src/types
touch src/index.ts
```

Your project should now look like:

```
taskflow-tutorial/
├── node_modules/
├── src/
│   ├── types/
│   └── index.ts
├── package.json
└── tsconfig.json
```

### Step 6: Add NPM Scripts

**File:** `package.json` (add these to the "scripts" section)

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsc --watch & nodemon dist/index.js"
  }
}
```

Wait—we need `nodemon` for development. Let's install it:

```bash
npm install --save-dev nodemon
```

## 1.3 Your First TypeScript Code

### The Target

**File:** `src/index.ts`  
**Concept:** Writing type-safe code from the start

### The Implementation

**File:** `src/index.ts`

```typescript
/**
 * Our first TypeScript file for TaskFlow.
 * This demonstrates basic types and the "strict" mode benefits.
 */

// --- Basic Types ---

// Type inference: TypeScript automatically determines the type
let name = "TaskFlow";          // TypeScript infers `name: string`
let version = 1.0;              // TypeScript infers `version: number`
let isActive = true;            // TypeScript infers `isActive: boolean`

// Explicit type annotations: When you want to be explicit
let projectId: string = "proj_123";
let taskCount: number = 0;
const isPublic: boolean = true; // const with explicit type (rarely needed)

// Arrays: Two ways to write them
let taskNames: string[] = ["Write docs", "Review code", "Fix bugs"];
let projectIds: Array<string> = ["proj_123", "proj_456"]; // Alternative syntax

// --- Functions with Types ---

/**
 * Calculate the duration between two dates in days
 * @param startDate - The start date
 * @param endDate - The end date
 * @returns The number of days between dates
 */
function calculateDuration(startDate: Date, endDate: Date): number {
    const diffTime = endDate.getTime() - startDate.getTime();
    const diffDays = diffTime / (1000 * 60 * 60 * 24);
    return Math.round(diffDays);
}

// Type inference on function returns
function formatTaskTitle(title: string, projectName: string) {
    // TypeScript infers the return type as string
    return `[${projectName}] ${title}`;
}

// --- Objects ---

// Inline type annotation for an object
let task: { id: string; title: string; completed: boolean } = {
    id: "task_123",
    title: "Complete onboarding",
    completed: false
};

// ✅ This works: all properties match
task.completed = true;

// ❌ This would cause a type error: 'date' doesn't exist on the object
// task.date = new Date();

// --- Type Aliases: Reusable Object Shapes ---

// Create a reusable type for Task
type Task = {
    id: string;
    title: string;
    description?: string; // Optional property (can be undefined)
    completed: boolean;
    createdAt: Date;
    updatedAt?: Date; // Optional
    priority: 'low' | 'medium' | 'high'; // Union of string literals
};

// Now we can use Task anywhere
const myFirstTask: Task = {
    id: "task_001",
    title: "Set up TypeScript project",
    description: "Initialize project and configure tsconfig.json", // Optional
    completed: false,
    createdAt: new Date(),
    priority: "high"
};

// --- Functions with Objects ---

function printTask(task: Task): string {
    const status = task.completed ? '✅' : '⬜';
    const priorityEmoji = task.priority === 'high' ? '🔴' : 
                         task.priority === 'medium' ? '🟡' : '🟢';
    return `${status} ${priorityEmoji} ${task.title} (ID: ${task.id})`;
}

// --- Union Types ---

// A variable that can be either a string OR a number
let projectIdentifier: string | number = "PROJ-123"; // Valid
projectIdentifier = 12345; // Also valid
// projectIdentifier = true; // ❌ TypeScript error: boolean not allowed

// Union in functions
function formatIdentifier(id: string | number): string {
    if (typeof id === 'string') {
        return id.toUpperCase(); // TypeScript knows id is string here
    } else {
        return id.toString().padStart(6, '0'); // TypeScript knows id is number here
    }
}

console.log(formatIdentifier("abc")); // "ABC"
console.log(formatIdentifier(123)); // "000123"

// --- Optional and Nullable Types ---

// Use null to represent an intentionally missing value
function getTaskDescription(task: Task): string {
    // Check if description exists using optional chaining and nullish coalescing
    return task.description?.toUpperCase() ?? "No description provided";
    //   ^ Optional chaining: returns undefined if description is undefined
    //                              ^ Nullish coalescing: returns right side if left is null/undefined
}

// --- The `unknown` Type ---

// unknown is a safe alternative to any
let userInput: unknown = "Hello, world";

// ❌ Cannot use unknown without narrowing
// console.log(userInput.toUpperCase()); // Error: userInput is unknown

// ✅ Narrow first
if (typeof userInput === 'string') {
    console.log(userInput.toUpperCase()); // Now safe
}

// Parse JSON safely with unknown
function safeJSONParse(data: string): unknown {
    try {
        return JSON.parse(data);
    } catch {
        return null;
    }
}

const parsedData = safeJSONParse('{"name": "TaskFlow"}');
// We need to check before using
if (parsedData && typeof parsedData === 'object' && 'name' in parsedData) {
    console.log((parsedData as { name: string }).name);
    //                 ^ Type assertion: we're telling TypeScript to trust us
    //                 (Use cautiously!)
}

// --- The `never` Type ---

// never represents values that never occur
function throwError(message: string): never {
    throw new Error(message);
    // This function never returns
}

function infiniteLoop(): never {
    while (true) {
        // This function never returns
    }
}

// never is useful for exhaustive checking
function handlePriority(priority: Task['priority']): string {
    switch (priority) {
        case 'low':
            return 'Low priority 🟢';
        case 'medium':
            return 'Medium priority 🟡';
        case 'high':
            return 'High priority 🔴';
        default:
            // This ensures we've handled all cases
            // TypeScript will error if we add a new priority and don't handle it
            const exhaustiveCheck: never = priority;
            return exhaustiveCheck;
    }
}

// --- Console Logs for Verification ---

console.log('=== TaskFlow TypeScript Demo ===\n');

// Basic demo
console.log(`Project: ${name} v${version}`);
console.log(`Active: ${isActive}\n`);

// Task demo
console.log('Task:');
console.log(myFirstTask);
console.log(`\nFormatted: ${printTask(myFirstTask)}\n`);

// Duration calculation
const startDate = new Date('2026-01-01');
const endDate = new Date('2026-01-27');
console.log(`Duration: ${calculateDuration(startDate, endDate)} days\n`);

// Formatting
console.log(`Formatted ID: ${formatIdentifier('PROJ-123')}`);
console.log(`Padded ID: ${formatIdentifier(123)}\n`);

// Description
console.log(`Description: ${getTaskDescription(myFirstTask)}`);

// Creating a task without description
const taskWithoutDesc = { ...myFirstTask, description: undefined };
console.log(`Description (missing): ${getTaskDescription(taskWithoutDesc)}\n`);

// Handle priority
console.log(`Priority handling: ${handlePriority('high')}`);
```

### The Verification

Let's build and run our TypeScript code:

```bash
# Build the TypeScript code (compiles to JavaScript in /dist)
npm run build

# You should see no errors, and a /dist folder should appear with index.js

# Run the compiled JavaScript
npm start

# Expected output (approximate):
# === TaskFlow TypeScript Demo ===
# Project: TaskFlow v1
# Active: true
# 
# Task:
# {
#   id: 'task_001',
#   title: 'Set up TypeScript project',
#   description: 'Initialize project and configure tsconfig.json',
#   completed: false,
#   createdAt: 2026-01-27T...,
#   priority: 'high'
# }
# Formatted: ⬜ 🔴 Set up TypeScript project (ID: task_001)
# Duration: 26 days
# Formatted ID: PROJ-123
# Padded ID: 000123
# Description: INITIALIZE PROJECT AND CONFIGURE TSCONFIG.JSON
# Description (missing): No description provided
# Priority handling: High priority 🔴
```

### Running in Development Mode

```bash
npm run dev
# This watches for changes and automatically rebuilds/restarts
```

## 1.4 Understanding Type Narrowing

Type narrowing is TypeScript's ability to understand what type a value is based on your code's flow. Let's explore this crucial concept.

**File:** `src/types/narrowing.ts`

```typescript
/**
 * Understanding Type Narrowing
 * TypeScript analyzes your code to narrow types based on checks
 */

// --- Typeof Type Guards ---

type Value = string | number | boolean | null | undefined;

function processValue(value: Value): string {
    // TypeScript doesn't know what type 'value' is yet
    
    if (typeof value === 'string') {
        // In this block, TypeScript KNOWS value is a string
        return `String: ${value.toUpperCase()}`;
    }
    
    if (typeof value === 'number') {
        // Here, TypeScript KNOWS value is a number
        return `Number: ${value.toFixed(2)}`;
    }
    
    if (typeof value === 'boolean') {
        // Here, TypeScript KNOWS value is a boolean
        return `Boolean: ${value ? 'true' : 'false'}`;
    }
    
    // After all checks, TypeScript knows value is null or undefined
    // This is called the "exhaustive" state
    return `Nullish: ${String(value)}`;
}

// --- Equality Narrowing ---

type Status = 'pending' | 'complete' | 'archived';

function getStatusAction(status: Status): string {
    if (status === 'pending') {
        return '⏳ Processing...';
    }
    
    if (status === 'complete') {
        return '✅ Done';
    }
    
    // TypeScript knows status must be 'archived' here
    return '📦 Archived';
}

// --- Truthiness Narrowing ---

function getTaskData(task: Task | null): string {
    // If task is null or undefined, we handle it
    if (!task) {
        return 'No task provided';
    }
    
    // TypeScript KNOWS task exists here
    return `Task: ${task.title} (${task.id})`;
}

// --- In Operator Narrowing ---

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

function isPriorityTask(task: TaskWithPriority | TaskWithDueDate): task is TaskWithPriority {
    // This is a type predicate: tells TypeScript the type after checking
    return 'priority' in task;
}

function handleTask(task: TaskWithPriority | TaskWithDueDate): string {
    if (isPriorityTask(task)) {
        // TypeScript knows this is TaskWithPriority
        return `Priority: ${task.priority}`;
    } else {
        // TypeScript knows this is TaskWithDueDate
        return `Due: ${task.dueDate.toDateString()}`;
    }
}

// --- Instanceof Narrowing ---

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
    
    if (entity instanceof Team) {
        // TypeScript knows this is a Team
        return `Team: ${entity.name} (${entity.members.join(', ')})`;
    }
    
    return 'Unknown entity';
}

// --- Discriminated Unions ---

// A powerful pattern using a common property to discriminate types

type TaskEvent = 
    | { type: 'created'; taskId: string; timestamp: Date }
    | { type: 'completed'; taskId: string; completedAt: Date }
    | { type: 'deleted'; taskId: string; reason?: string };

function handleTaskEvent(event: TaskEvent): string {
    switch (event.type) {
        case 'created':
            // TypeScript knows this has taskId and timestamp
            return `Task ${event.taskId} created at ${event.timestamp}`;
        case 'completed':
            // TypeScript knows this has taskId and completedAt
            return `Task ${event.taskId} completed at ${event.completedAt}`;
        case 'deleted':
            // TypeScript knows this has taskId and optional reason
            return `Task ${event.taskId} deleted${event.reason ? `: ${event.reason}` : ''}`;
        default:
            const exhaustiveCheck: never = event;
            return exhaustiveCheck;
    }
}

// --- Type Assertions (When You Know Better) ---

// Use type assertions carefully—only when you know more than TypeScript

const element = document.getElementById('app') as HTMLElement;
//                          ^ TypeScript thinks this could be null
//                          We're telling it "trust me, it exists"

// Better: Use a type guard instead
function getElement(id: string): HTMLElement | null {
    return document.getElementById(id);
}

const app = getElement('app');
if (app) {
    app.innerHTML = 'Hello, TypeScript!';
    // TypeScript knows app is HTMLElement here
}

// --- Verification ---

console.log('\n=== Type Narrowing Demo ===\n');

// Typeof narrowing
console.log(processValue("Hello"));        // String: HELLO
console.log(processValue(42.123));         // Number: 42.12
console.log(processValue(true));           // Boolean: true
console.log(processValue(null));           // Nullish: null

// Equality narrowing
console.log(getStatusAction('pending'));   // ⏳ Processing...
console.log(getStatusAction('complete'));  // ✅ Done

// Discriminated unions
const event1: TaskEvent = {
    type: 'created',
    taskId: 'task_123',
    timestamp: new Date()
};
console.log(handleTaskEvent(event1));
```

## 1.5 Common TypeScript Errors and How to Fix Them

Let's look at common TypeScript errors you'll encounter and how to fix them.

### Error 1: "Property 'x' does not exist on type 'y'"

```typescript
// ❌ Error: Property 'description' does not exist on type 'Task'
const task: Task = { /* ... */ };
// console.log(task.description); // Error if description is optional

// ✅ Fix: Use optional chaining or check the property
console.log(task.description ?? 'No description');
```

### Error 2: "Argument of type 'x' is not assignable to parameter of type 'y'"

```typescript
// ❌ Error: Argument of type 'string' is not assignable to parameter of type 'number'
function add(a: number, b: number): number {
    return a + b;
}
// add("1", "2"); // Error

// ✅ Fix: Convert or use correct type
add(Number("1"), Number("2")); // 3
```

### Error 3: "Object is possibly 'null' or 'undefined'"

```typescript
// ❌ Error: Object is possibly 'null'
function getTaskTitle(task: Task | null): string {
    return task.title; // Error: task might be null
}

// ✅ Fix: Check for null or use optional chaining
function getTaskTitle(task: Task | null): string {
    return task?.title ?? 'Unknown task';
}
```

### Error 4: "Variable 'x' is used before being assigned"

```typescript
// ❌ Error: Variable 'task' is used before being assigned
let task: Task;
// console.log(task); // Error: task might be undefined

// ✅ Fix: Initialize it
let task: Task = {
    id: "task_001",
    title: "Default title",
    completed: false,
    createdAt: new Date(),
    priority: "medium"
};
```

### Error 5: "This condition will always return true since the types have no overlap"

```typescript
// ❌ Error: This condition will always return false
const num: number = 42;
// if (typeof num === 'string') { // Error: TypeScript knows this can't happen

// ✅ Fix: Remove the impossible condition
if (num === 42) { /* ... */ }
```

## 1.6 Building TaskFlow's First Types

Now let's start building the actual types for our TaskFlow application.

**File:** `src/types/taskflow.ts`

```typescript
/**
 * TaskFlow Core Types
 * These are the foundational types for our application
 */

// --- User Types ---

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

// --- Project Types ---

export type ProjectId = string;
export type ProjectStatus = 'active' | 'archived' | 'completed';

export interface Project {
    id: ProjectId;
    name: string;
    description?: string;
    status: ProjectStatus;
    ownerId: UserId;
    memberIds: UserId[]; // Array of user IDs who are members of this project
    createdAt: Date;
    updatedAt: Date;
}

// --- Task Types ---

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
    assigneeId?: UserId; // Optional assignee
    createdBy: UserId;
    dueDate?: Date; // Optional due date
    tags: string[]; // Array of tag strings
    createdAt: Date;
    updatedAt: Date;
}

// --- Comment Types ---

export type CommentId = string;

export interface Comment {
    id: CommentId;
    content: string;
    taskId: TaskId;
    userId: UserId;
    createdAt: Date;
    updatedAt: Date;
}

// --- Activity Log Types ---

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
    taskId?: TaskId; // Optional: might be project-level activity
    projectId: ProjectId;
    metadata: Record<string, any>; // Flexible metadata for different activity types
    createdAt: Date;
}

// --- API Response Types ---

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

// --- Form Types (for validation) ---

export type CreateTaskInput = Omit<Task, 'id' | 'createdAt' | 'updatedAt'> & {
    // Omit removes these properties, then we add them back as optional or required
    // We need all fields except id, createdAt, updatedAt
};

export type UpdateTaskInput = Partial<Omit<Task, 'id' | 'createdAt' | 'updatedAt'>> & {
    id: TaskId; // Must provide ID to update
};

// --- Type Guards for Runtime Checks ---

export function isTaskPriority(value: any): value is TaskPriority {
    return ['low', 'medium', 'high', 'urgent'].includes(value);
}

export function isTaskStatus(value: any): value is TaskStatus {
    return ['todo', 'in-progress', 'review', 'done'].includes(value);
}

export function isProjectStatus(value: any): value is ProjectStatus {
    return ['active', 'archived', 'completed'].includes(value);
}

// --- Utility Types for the Application ---

// A type that makes all properties optional except those specified
export type WithRequired<T, K extends keyof T> = T & {
    [P in K]-?: T[P]; // Make specified properties required
};

// A type that ensures we have at least one property from a set
export type AtLeastOne<T, K extends keyof T> = {
    [P in K]-?: Required<Pick<T, P>>; // At least one property
} & Omit<T, K>;
```

### Verification for TaskFlow Types

Let's test our types to make sure they work as expected.

**File:** `src/test-types.ts`

```typescript
import type {
    User,
    Project,
    Task,
    Comment,
    CreateTaskInput,
    UpdateTaskInput,
    isTaskPriority,
    isTaskStatus
} from './types/taskflow.js';

// --- Test User ---
const user: User = {
    id: 'user_1',
    email: 'alice@example.com',
    name: 'Alice',
    createdAt: new Date(),
    updatedAt: new Date()
};

// --- Test Project ---
const project: Project = {
    id: 'project_1',
    name: 'TaskFlow Development',
    status: 'active',
    ownerId: 'user_1',
    memberIds: ['user_1', 'user_2'],
    createdAt: new Date(),
    updatedAt: new Date()
};

// --- Test Task ---
const task: Task = {
    id: 'task_1',
    title: 'Setup TypeScript',
    status: 'todo',
    priority: 'high',
    projectId: 'project_1',
    createdBy: 'user_1',
    tags: ['setup', 'typescript'],
    createdAt: new Date(),
    updatedAt: new Date()
};

// --- Test Create Task Input ---
const newTask: CreateTaskInput = {
    title: 'Write documentation',
    status: 'todo',
    priority: 'medium',
    projectId: 'project_1',
    createdBy: 'user_1',
    tags: ['docs'],
    // description, assigneeId, dueDate are optional
};

// --- Test Update Task Input ---
const taskUpdate: UpdateTaskInput = {
    id: 'task_1',
    status: 'in-progress',
    priority: 'urgent'
};

// --- Test Type Guards ---
console.log('Testing type guards:');
console.log(isTaskPriority('high'));   // true
console.log(isTaskPriority('urgent')); // true
console.log(isTaskPriority('maybe'));  // false
console.log(isTaskStatus('todo'));     // true
console.log(isTaskStatus('done'));     // true

// --- Verification ---
console.log('\n=== TaskFlow Types Test ===');
console.log('✅ User:', user.name);
console.log('✅ Project:', project.name);
console.log('✅ Task:', task.title);
console.log('✅ New task created:', newTask.title);
console.log('✅ Task updated:', taskUpdate.status);
console.log('✅ All types verified successfully!');
```

### The Verification

```bash
# Run the type tests (this checks our types without compiling)
npx tsc --noEmit

# Or compile and run the test file
npm run build
node dist/test-types.js
```

## 1.7 Summary: What You've Learned

Congratulations! You've completed Part 1. Let's recap what you've learned:

### Core Concepts
- **TypeScript vs. JavaScript:** TypeScript adds compile-time type checking to JavaScript
- **Types don't exist at runtime:** TypeScript is a development tool that gets stripped away
- **Compile-time vs. Runtime:** Types are checked before your code runs

### Basic TypeScript Syntax
- **Primitive types:** `string`, `number`, `boolean`, `null`, `undefined`
- **Arrays:** `string[]` or `Array<string>`
- **Objects:** Inline types and interfaces
- **Functions:** Parameter types and return types
- **Union types:** `string | number`
- **Optional properties:** `property?: type`
- **The `unknown` type:** Safe alternative to `any`
- **The `never` type:** Values that never occur

### Type Narrowing
- **`typeof` type guards:** Check primitive types
- **Equality narrowing:** Compare values
- **Truthiness narrowing:** Check for existence
- **`in` operator narrowing:** Check for properties
- **`instanceof` narrowing:** Check for classes
- **Discriminated unions:** Use a common property to differentiate types

### Common Error Handling
- Property does not exist on type
- Argument not assignable to parameter
- Object possibly null or undefined
- Variable used before assignment
- Impossible conditions

### Practical Application
- Set up a TypeScript project with proper `tsconfig.json`
- Build core types for TaskFlow application
- Use type guards for runtime type checking
- Test your types with `tsc --noEmit`

## What's Next: Preview of Part 2

In Part 2, we'll dive deeper into:
- **Interfaces vs. Type Aliases:** When to use each
- **Generics:** Creating reusable, type-safe components
- **Utility Types:** Built-in types like `Partial`, `Pick`, `Omit`, `Record`, and more
- **Advanced `tsconfig.json`:** Path aliases, strict mode options, and performance
- **Practical Application:** Build TaskFlow's data layer with fully typed functions

## Verification Checklist

Before moving to Part 2, ensure:

- [ ] `tsc --version` shows TypeScript 4.9+ installed
- [ ] `npm run build` compiles without errors
- [ ] `npm start` runs and shows the demo output
- [ ] `npx tsc --noEmit` runs without errors (type checking only)
- [ ] You understand the difference between `any`, `unknown`, and `never`
- [ ] You can explain type narrowing in your own words
- [ ] You've created the TaskFlow types in `src/types/taskflow.ts`
