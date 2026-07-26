# TypeScript Primer: JavaScript to TypeScript in 30 Minutes

## A Quick-Start Guide for JavaScript Developers

---

# Introduction

## What This Primer Covers

This primer is designed for JavaScript developers who want to get up and running with TypeScript quickly. It assumes you know JavaScript but have little or no TypeScript experience.

**By the end of this primer, you will:**
- Understand what TypeScript is and why it's useful
- Write basic TypeScript code
- Add types to functions and variables
- Work with interfaces and types
- Set up a simple TypeScript project

**Time to complete:** 30 minutes

---

# Section 1: What TypeScript Adds to JavaScript

## The Short Answer

TypeScript = JavaScript + Types

## The Long Answer

TypeScript adds a **type system** on top of JavaScript. This means:

✅ **You catch errors before your code runs**
```javascript
// JavaScript - This will crash at runtime
function greet(name) {
    return name.toUpperCase();
}
greet(42); // 💥 TypeError: name.toUpperCase is not a function
```

```typescript
// TypeScript - This catches the error at compile time
function greet(name: string) {
    return name.toUpperCase();
}
greet(42); // ❌ TypeScript Error: Argument of type 'number' is not assignable to parameter of type 'string'
```

✅ **Your editor provides better autocomplete**

✅ **Your code becomes self-documenting**

✅ **Refactoring becomes safer and easier**

## The Most Important Thing to Remember

**TypeScript types are removed when your code runs.** They exist only during development to help you catch errors.

```typescript
// Your TypeScript code:
function greet(name: string): string {
    return `Hello, ${name}`;
}

// What actually runs (JavaScript):
function greet(name) {
    return `Hello, ${name}`;
}
// The types are gone!
```

---

# Section 2: Basic Type Annotations

## Variables

TypeScript can infer types automatically, but you can also add explicit types:

```typescript
// Type inference (TypeScript figures it out)
let name = "TypeScript";     // TypeScript knows this is a string
let count = 42;              // TypeScript knows this is a number

// Explicit type annotations (you tell TypeScript)
let projectId: string = "proj_123";
let version: number = 1.0;
let isComplete: boolean = true;
let nothing: null = null;
let notDefined: undefined = undefined;
```

## Arrays

There are two ways to write array types:

```typescript
// Method 1: Type[]
let tasks: string[] = ["Write code", "Review PR", "Deploy"];

// Method 2: Array<Type>
let scores: Array<number> = [98, 87, 92];

// Mixed types
let mixed: (string | number)[] = ["hello", 42, "world", 100];
```

## Functions

Add types to parameters and return values:

```typescript
// Basic function
function add(a: number, b: number): number {
    return a + b;
}

// Void return (no return value)
function log(message: string): void {
    console.log(message);
}

// Optional parameters
function greet(name: string, greeting?: string): string {
    if (greeting) {
        return `${greeting}, ${name}`;
    }
    return `Hello, ${name}`;
}

// Default parameters
function createUser(name: string, age: number = 18): object {
    return { name, age };
}
```

## Objects

Define the shape of an object:

```typescript
// Inline type
let user: { name: string; age: number; email?: string } = {
    name: "Alice",
    age: 30,
    email: "alice@example.com"
};

// Using a type alias
type User = {
    name: string;
    age: number;
    email?: string; // Optional property
};

let alice: User = {
    name: "Alice",
    age: 30
};

let bob: User = {
    name: "Bob",
    age: 25,
    email: "bob@example.com"
};
```

---

# Section 3: Working with Types

## Union Types

A value that can be one of several types:

```typescript
// A variable that can be string OR number
let id: string | number = "abc123";
id = 12345; // This is fine

// A function that accepts string OR number
function format(value: string | number): string {
    if (typeof value === 'string') {
        return value.toUpperCase(); // TypeScript knows it's a string here
    } else {
        return value.toString();    // TypeScript knows it's a number here
    }
}
```

## Literal Types

Specific values as types:

```typescript
type Status = 'pending' | 'active' | 'completed';

let taskStatus: Status = 'pending';
taskStatus = 'active';  // ✓ Fine
taskStatus = 'done';    // ❌ Error: Type '"done"' is not assignable to type 'Status'
```

## Type Aliases

Give types a name:

```typescript
// Define a type
type UserId = string;
type Age = number;

// Use the type
let userId: UserId = "user_123";
let age: Age = 30;

// Combine types
type User = {
    id: UserId;
    name: string;
    age: Age;
    isActive: boolean;
};
```

## Interfaces

Another way to define object types:

```typescript
interface User {
    id: string;
    name: string;
    age: number;
    email?: string;
}

// Can be extended
interface Admin extends User {
    role: 'admin';
    permissions: string[];
}

// Can be implemented by classes
class UserClass implements User {
    id: string;
    name: string;
    age: number;
    email?: string;
    
    constructor(id: string, name: string, age: number) {
        this.id = id;
        this.name = name;
        this.age = age;
    }
}
```

---

# Section 4: Generics (Basic)

Generics let you write code that works with any type while keeping type safety:

```typescript
// A generic function
function identity<T>(value: T): T {
    return value;
}

// Usage
const stringResult = identity<string>("hello");  // Returns string
const numberResult = identity(42);               // Returns number (inferred)

// Generic array function
function first<T>(items: T[]): T | undefined {
    return items[0];
}

const numbers = [1, 2, 3];
const firstNumber = first(numbers);  // TypeScript knows this is number | undefined

const strings = ["a", "b", "c"];
const firstString = first(strings);  // TypeScript knows this is string | undefined

// Generic class
class Box<T> {
    private contents: T;
    
    constructor(initial: T) {
        this.contents = initial;
    }
    
    getContents(): T {
        return this.contents;
    }
    
    setContents(newContents: T): void {
        this.contents = newContents;
    }
}

// Usage
const stringBox = new Box<string>("Hello");
console.log(stringBox.getContents().toUpperCase()); // "HELLO"

const numberBox = new Box(42); // TypeScript infers the type
console.log(numberBox.getContents() * 2); // 84
```

---

# Section 5: Practical Examples

## Example 1: User Management

```typescript
type User = {
    id: string;
    name: string;
    email: string;
    age: number;
    isAdmin: boolean;
};

type NewUser = Omit<User, 'id'>; // User without id

function createUser(userData: NewUser): User {
    return {
        id: `user_${Date.now()}`,
        ...userData
    };
}

function isAdmin(user: User): boolean {
    return user.isAdmin;
}

function getUserDisplayName(user: User): string {
    return `${user.name} (${user.email})`;
}

// Usage
const alice = createUser({
    name: "Alice",
    email: "alice@example.com",
    age: 30,
    isAdmin: true
});

console.log(getUserDisplayName(alice)); // "Alice (alice@example.com)"
console.log(isAdmin(alice)); // true
```

## Example 2: Task Management

```typescript
type TaskStatus = 'todo' | 'in-progress' | 'done';
type TaskPriority = 'low' | 'medium' | 'high';

type Task = {
    id: string;
    title: string;
    description?: string;
    status: TaskStatus;
    priority: TaskPriority;
    createdAt: Date;
    assignedTo?: string;
};

function createTask(title: string, priority: TaskPriority = 'medium'): Task {
    return {
        id: `task_${Date.now()}`,
        title,
        status: 'todo',
        priority,
        createdAt: new Date()
    };
}

function completeTask(task: Task): Task {
    return {
        ...task,
        status: 'done'
    };
}

function getTasksByStatus(tasks: Task[], status: TaskStatus): Task[] {
    return tasks.filter(task => task.status === status);
}

// Usage
const task1 = createTask("Write TypeScript primer", 'high');
const task2 = createTask("Review code", 'medium');

const tasks = [task1, task2];
const todoTasks = getTasksByStatus(tasks, 'todo');
console.log(`Todo tasks: ${todoTasks.length}`);

const completedTask = completeTask(task1);
console.log(`Task "${completedTask.title}" is ${completedTask.status}`);
```

---

# Section 6: Setting Up a TypeScript Project

## Quick Setup

```bash
# Initialize a new project
mkdir my-ts-project
cd my-ts-project
npm init -y

# Install TypeScript
npm install --save-dev typescript

# Create TypeScript configuration
npx tsc --init

# Create your first TypeScript file
echo 'const greeting: string = "Hello, TypeScript!"; console.log(greeting);' > index.ts

# Compile and run
npx tsc
node index.js
```

## Minimal tsconfig.json

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
  "exclude": ["node_modules"]
}
```

## Recommended VS Code Extensions

1. **TypeScript and JavaScript Language Features** (built-in)
2. **ESLint** for code quality
3. **Prettier** for code formatting

---

# Section 7: What's Next?

## Where to Go From Here

### 1. **Complete the TypeScript Master Series**
This primer is a warm-up. The full series covers everything in depth.

### 2. **Practice, Practice, Practice**
The best way to learn TypeScript is to use it. Convert a small JavaScript project to TypeScript.

### 3. **Explore Advanced Topics**
- Conditional types
- Mapped types
- Template literal types
- The `infer` keyword
- Utility types

### 4. **Learn the React + TypeScript Patterns**
- Typing props and state
- Custom hooks
- Context
- Forms with React Hook Form + Zod

### 5. **Apply to Next.js**
- App Router with TypeScript
- Server actions
- API routes
- Environment variables

## Quick Reference Card

```typescript
// Types
string, number, boolean, null, undefined
Array<T> or T[]
{ property: Type }

// Union
Type1 | Type2

// Optional
property?: Type

// Function
(param: Type) => ReturnType

// Type Alias
type Name = Type

// Interface
interface Name { property: Type }

// Generic
function name<T>(param: T): T
class Name<T> { contents: T }

// Utility Types
Partial<T>, Required<T>, Pick<T, K>, Omit<T, K>
Record<K, T>, ReturnType<T>, Parameters<T>
```

---

# Practice Exercises

## Exercise 1: Basic Types

Add proper type annotations to the following code:

```typescript
// 1. Variables
let name = "TypeScript";
let version = 5.0;
let isStable = true;

// 2. Arrays
let languages = ["TypeScript", "JavaScript", "Python"];

// 3. Function
function greet(name) {
    return `Hello, ${name}`;
}

// 4. Object
const config = {
    apiUrl: "https://api.example.com",
    timeout: 5000,
    retries: 3
};
```

## Exercise 2: Union Types

Create a function that formats a value that can be either a string or a number:

```typescript
function formatValue(value: string | number): string {
    // Your code here
}

// Should work for both:
formatValue("hello"); // "HELLO"
formatValue(42);      // "42"
```

## Exercise 3: Interfaces

Define an interface for a Book with:
- title (string)
- author (string)
- pages (number)
- publishedYear (number, optional)

Then create a function that displays book information.

## Exercise 4: Generics

Create a generic function that returns the last element of an array:

```typescript
function last<T>(items: T[]): T | undefined {
    // Your code here
}
```

## Exercise 5: Type Aliases

Create a type alias for a User with the following properties:
- id (string)
- name (string)
- email (string)
- role: 'admin' | 'user' | 'guest'

Then create functions to create and update users.

---

# Solutions

## Exercise 1: Basic Types

```typescript
let name: string = "TypeScript";
let version: number = 5.0;
let isStable: boolean = true;

let languages: string[] = ["TypeScript", "JavaScript", "Python"];

function greet(name: string): string {
    return `Hello, ${name}`;
}

const config: { apiUrl: string; timeout: number; retries: number } = {
    apiUrl: "https://api.example.com",
    timeout: 5000,
    retries: 3
};
```

## Exercise 2: Union Types

```typescript
function formatValue(value: string | number): string {
    if (typeof value === 'string') {
        return value.toUpperCase();
    } else {
        return value.toString();
    }
}
```

## Exercise 3: Interfaces

```typescript
interface Book {
    title: string;
    author: string;
    pages: number;
    publishedYear?: number;
}

function displayBook(book: Book): string {
    let info = `"${book.title}" by ${book.author} (${book.pages} pages)`;
    if (book.publishedYear) {
        info += `, published in ${book.publishedYear}`;
    }
    return info;
}
```

## Exercise 4: Generics

```typescript
function last<T>(items: T[]): T | undefined {
    if (items.length === 0) return undefined;
    return items[items.length - 1];
}
```

## Exercise 5: Type Aliases

```typescript
type Role = 'admin' | 'user' | 'guest';

type User = {
    id: string;
    name: string;
    email: string;
    role: Role;
};

function createUser(name: string, email: string, role: Role = 'user'): User {
    return {
        id: `user_${Date.now()}`,
        name,
        email,
        role
    };
}

function updateUser(user: User, updates: Partial<Omit<User, 'id'>>): User {
    return {
        ...user,
        ...updates
    };
}
```

---

## Congratulations!

You've completed the TypeScript primer. You now have a solid foundation in TypeScript and can start applying it to your projects.

**Next Steps:**
1. Complete the full TypeScript Master Series
2. Convert a small project to TypeScript
3. Explore more TypeScript features
4. Build a complete application with TypeScript
