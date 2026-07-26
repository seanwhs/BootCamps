# TypeScript Master Series: Appendix A

## TypeScript Cheat Sheet & Quick Reference

---

# Table of Contents

1. **Type System Overview**
2. **Basic Types**
3. **Type Annotations & Inference**
4. **Advanced Types**
5. **Utility Types**
6. **Type Narrowing**
7. **Generics**
8. **Interfaces & Type Aliases**
9. **Functions**
10. **Classes**
11. **Modules & Imports**
12. **React TypeScript Patterns**
13. **Next.js TypeScript Patterns**
14. **Common TypeScript Errors**
15. **tsconfig.json Reference**
16. **Command Reference**
17. **Code Snippets Library**

---

# 1. Type System Overview

## The Type Hierarchy

```
┌──────────────────────────────────────────────┐
│                     any                       │
├──────────────────────────────────────────────┤
│                    unknown                     │
├──────────────────────────────────────────────┤
│                   primitive                    │
│     ┌─────┬─────┬─────┬─────┬─────┬─────┐   │
│     │string│number│boolean│null│undefined│symbol│   │
│     └─────┴─────┴─────┴─────┴─────┴─────┘   │
├──────────────────────────────────────────────┤
│                   object                       │
│     ┌──────────┬──────────┬──────────┐       │
│     │  array   │ function │  class   │       │
│     └──────────┴──────────┴──────────┘       │
├──────────────────────────────────────────────┤
│                   never                        │
└──────────────────────────────────────────────┘
```

## Type Categories

| Category | Types | Description |
|----------|-------|-------------|
| **Primitive** | `string`, `number`, `boolean`, `null`, `undefined`, `symbol` | Basic JavaScript types |
| **Object** | `object`, `Array`, `Function`, `class` | Complex types |
| **Union** | `T \| U` | Either T or U |
| **Intersection** | `T & U` | Both T and U |
| **Literal** | `'hello'`, `42`, `true` | Specific values |
| **Utility** | `Partial<T>`, `Pick<T, K>`, etc. | Built-in type transforms |
| **Advanced** | `Conditional`, `Mapped`, `Template Literal` | Type-level programming |

---

# 2. Basic Types

## Primitive Types

```typescript
// String
let name: string = "TypeScript";
let template: string = `Hello, ${name}`;

// Number
let count: number = 42;
let pi: number = 3.14159;
let binary: number = 0b1010;
let hex: number = 0xff;

// Boolean
let isActive: boolean = true;
let isComplete: boolean = false;

// Null & Undefined
let empty: null = null;
let notDefined: undefined = undefined;

// Symbol
let sym: symbol = Symbol('key');
```

## Array Types

```typescript
// Two ways to write arrays
let strings: string[] = ['a', 'b', 'c'];
let numbers: Array<number> = [1, 2, 3];

// Mixed type array
let mixed: (string | number)[] = ['hello', 42];

// Tuple (fixed length with known types)
let pair: [string, number] = ['hello', 42];
let triple: [string, number, boolean] = ['hello', 42, true];

// Readonly array
let readonly: readonly string[] = ['a', 'b', 'c'];
```

## Object Types

```typescript
// Inline object type
let user: { name: string; age: number } = {
    name: 'Alice',
    age: 30
};

// Optional properties
let config: { apiUrl: string; timeout?: number } = {
    apiUrl: 'https://api.example.com'
    // timeout is optional
};

// Index signature
let dictionary: { [key: string]: number } = {
    'one': 1,
    'two': 2
};

// Readonly properties
let immutable: { readonly id: string; name: string } = {
    id: '123',
    name: 'Alice'
};
// immutable.id = '456'; // ❌ Error
```

---

# 3. Type Annotations & Inference

## Type Inference

TypeScript automatically infers types when possible:

```typescript
// Inferred types
let name = "TypeScript";        // string
let count = 42;                 // number
let isActive = true;           // boolean
let items = ['a', 'b', 'c'];   // string[]
let mixed = ['a', 42];         // (string | number)[]
let obj = { id: 1, name: 'a' }; // { id: number; name: string }

// Function return type inference
function add(a: number, b: number) {
    return a + b;              // Inferred: number
}

function greet(name: string) {
    return `Hello, ${name}`;   // Inferred: string
}
```

## Explicit Type Annotations

When to use explicit annotations:

```typescript
// Function parameters (always needed)
function greet(name: string): string {
    return `Hello, ${name}`;
}

// Variables with complex types
let config: ApiConfig = { ... };

// Variables with no initial value
let task: Task;
task = getTask();

// When TypeScript can't infer correctly
let data: unknown = JSON.parse(response);
```

## Type Assertions

```typescript
// Using 'as'
let element = document.getElementById('app') as HTMLElement;
let data = JSON.parse(response) as User;

// Using angle brackets (not in TSX)
let element = <HTMLElement>document.getElementById('app');

// Non-null assertion (when you're sure it's not null)
let element = document.getElementById('app')!;
```

---

# 4. Advanced Types

## Union Types

```typescript
// Basic union
type Status = 'pending' | 'active' | 'completed';
let status: Status = 'pending';

// Union of primitives
type ID = string | number;
let id: ID = 'abc123';
id = 12345;

// Union of objects
type Response = 
    | { success: true; data: any }
    | { success: false; error: string };
```

## Intersection Types

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

## Literal Types

```typescript
// String literals
let direction: 'up' | 'down' | 'left' | 'right' = 'up';
let status: 'pending' | 'approved' = 'pending';

// Number literals
let dice: 1 | 2 | 3 | 4 | 5 | 6 = 3;

// Boolean literals
let success: true | false = true;
```

## Discriminated Unions

```typescript
type Shape = 
    | { kind: 'circle'; radius: number }
    | { kind: 'square'; side: number }
    | { kind: 'rectangle'; width: number; height: number };

function getArea(shape: Shape): number {
    switch (shape.kind) {
        case 'circle':
            return Math.PI * shape.radius ** 2;
        case 'square':
            return shape.side ** 2;
        case 'rectangle':
            return shape.width * shape.height;
        default:
            const exhaustive: never = shape;
            return exhaustive;
    }
}
```

## Conditional Types

```typescript
// Basic conditional
type IsString<T> = T extends string ? true : false;
type Test1 = IsString<string>;  // true
type Test2 = IsString<number>;  // false

// Type filtering
type ExtractStrings<T> = T extends string ? T : never;
type StringsOnly = ExtractStrings<string | number | boolean>; // string

// Type name
type TypeName<T> =
    T extends string ? 'string' :
    T extends number ? 'number' :
    T extends boolean ? 'boolean' :
    T extends undefined ? 'undefined' :
    T extends null ? 'null' :
    T extends Array<any> ? 'array' :
    T extends Function ? 'function' :
    'object';
```

## Mapped Types

```typescript
// Basic mapped type
type Optional<T> = {
    [P in keyof T]?: T[P];
};

// Readonly
type Readonly<T> = {
    readonly [P in keyof T]: T[P];
};

// Filter properties
type StringProperties<T> = {
    [P in keyof T as T[P] extends string ? P : never]: T[P];
};

// Transform properties
type UppercaseProps<T> = {
    [P in keyof T]: T[P] extends string ? Uppercase<T[P]> : T[P];
};

// Deep partial
type DeepPartial<T> = {
    [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};
```

## Template Literal Types

```typescript
// Basic template literal
type ApiEndpoint = `/api/${string}`;
type Route = `${'GET' | 'POST'} /${string}`;

// String manipulation
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

// URL parameter extraction
type UrlParams<T extends string> =
    T extends `${string}:${infer Param}/${infer Rest}`
        ? { [K in Param | keyof UrlParams<Rest>]: string }
        : T extends `${string}:${infer Param}`
            ? { [K in Param]: string }
            : {};
```

## The `infer` Keyword

```typescript
// Extract array element type
type ElementType<T> = T extends (infer U)[] ? U : never;

// Extract return type
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

// Extract parameters
type Parameters<T> = T extends (...args: infer P) => any ? P : never;

// Extract Promise value
type Awaited<T> = T extends Promise<infer U> ? U : T;

// Extract from object
type NestedType<T> = T extends { data: infer U } ? U : never;
```

---

# 5. Utility Types

## Complete Utility Types Reference

| Utility Type | Purpose | Example |
|--------------|---------|---------|
| `Partial<T>` | All optional | `Partial<Task>` |
| `Required<T>` | All required | `Required<Task>` |
| `Readonly<T>` | All read-only | `Readonly<Task>` |
| `Pick<T, K>` | Select properties | `Pick<Task, 'id' | 'title'>` |
| `Omit<T, K>` | Exclude properties | `Omit<Task, 'id'>` |
| `Record<K, T>` | Key-value map | `Record<'status', string>` |
| `Exclude<T, U>` | Remove union members | `Exclude<Status, 'done'>` |
| `Extract<T, U>` | Keep union members | `Extract<Status, 'pending'>` |
| `NonNullable<T>` | Remove null/undefined | `NonNullable<MaybeString>` |
| `ReturnType<T>` | Function return type | `ReturnType<typeof fn>` |
| `Parameters<T>` | Function parameters | `Parameters<typeof fn>` |
| `InstanceType<T>` | Class instance type | `InstanceType<typeof MyClass>` |
| `ThisType<T>` | Contextual this type | `ThisType<MyContext>` |
| `OmitThisParameter<T>` | Remove this parameter | `OmitThisParameter<typeof fn>` |
| `ThisParameterType<T>` | Extract this parameter | `ThisParameterType<typeof fn>` |

## Examples

```typescript
// Base type
type Task = {
    id: string;
    title: string;
    description?: string;
    completed: boolean;
    priority: 'low' | 'medium' | 'high';
    createdAt: Date;
    updatedAt: Date;
};

// Partial - all optional
type PartialTask = Partial<Task>;

// Required - all required
type RequiredTask = Required<PartialTask>;

// Pick - select properties
type TaskSummary = Pick<Task, 'id' | 'title' | 'priority' | 'completed'>;

// Omit - exclude properties
type CreateTaskInput = Omit<Task, 'id' | 'createdAt' | 'updatedAt'>;
type UpdateTaskInput = Partial<Omit<Task, 'id' | 'createdAt' | 'updatedAt'>>;

// Record - key-value map
type PriorityColors = Record<'low' | 'medium' | 'high', string>;
const colors: PriorityColors = {
    low: 'green',
    medium: 'yellow',
    high: 'red'
};

// Exclude & Extract
type Status = 'pending' | 'active' | 'completed' | 'archived';
type ActiveStatus = Exclude<Status, 'archived' | 'completed'>; // 'pending' | 'active'
type FinishedStatus = Extract<Status, 'completed' | 'archived'>; // 'completed' | 'archived'

// NonNullable
type MaybeString = string | null | undefined;
type DefinitelyString = NonNullable<MaybeString>; // string

// ReturnType
function createTask(title: string): Task {
    // ...
}
type TaskResult = ReturnType<typeof createTask>; // Task

// Parameters
type CreateTaskParams = Parameters<typeof createTask>; // [string]
```

---

# 6. Type Narrowing

## Type Guard Techniques

### `typeof` Type Guard

```typescript
function process(value: string | number | boolean): string {
    if (typeof value === 'string') {
        return value.toUpperCase();
    }
    if (typeof value === 'number') {
        return value.toFixed(2);
    }
    return value ? 'true' : 'false';
}
```

### Equality Narrowing

```typescript
type Status = 'pending' | 'active' | 'completed';

function getMessage(status: Status): string {
    if (status === 'pending') return '⏳ Pending';
    if (status === 'active') return '✅ Active';
    return '🎯 Completed';
}
```

### Truthiness Narrowing

```typescript
function getLength(value: string | null | undefined): number {
    if (!value) return 0;
    return value.length; // TypeScript knows value is string
}
```

### `in` Operator Narrowing

```typescript
interface Dog { bark(): void; }
interface Cat { meow(): void; }

function makeSound(animal: Dog | Cat): void {
    if ('bark' in animal) {
        animal.bark(); // TypeScript knows it's Dog
    } else {
        animal.meow(); // TypeScript knows it's Cat
    }
}
```

### `instanceof` Narrowing

```typescript
class Dog { bark() { console.log('Woof'); } }
class Cat { meow() { console.log('Meow'); } }

function makeSound(animal: Dog | Cat): void {
    if (animal instanceof Dog) {
        animal.bark();
    } else {
        animal.meow();
    }
}
```

### User-Defined Type Guards

```typescript
type Task = { id: string; title: string; completed: boolean };

function isTask(value: any): value is Task {
    return value && 
           typeof value.id === 'string' &&
           typeof value.title === 'string' &&
           typeof value.completed === 'boolean';
}

function process(value: Task | string): string {
    if (isTask(value)) {
        return value.title; // TypeScript knows it's Task
    }
    return value.toUpperCase(); // TypeScript knows it's string
}
```

### Discriminated Union Narrowing

```typescript
type Shape =
    | { kind: 'circle'; radius: number }
    | { kind: 'square'; side: number };

function getArea(shape: Shape): number {
    switch (shape.kind) {
        case 'circle':
            return Math.PI * shape.radius ** 2;
        case 'square':
            return shape.side ** 2;
        default:
            const exhaustive: never = shape;
            return exhaustive;
    }
}
```

---

# 7. Generics

## Generic Functions

```typescript
// Basic generic
function identity<T>(value: T): T {
    return value;
}

// Multiple generics
function pair<T, U>(first: T, second: U): [T, U] {
    return [first, second];
}

// Generic with constraints
function getName<T extends { name: string }>(item: T): string {
    return item.name;
}

// Generic with default
function createArray<T = string>(length: number, value: T): T[] {
    return Array(length).fill(value);
}
```

## Generic Classes

```typescript
class Box<T> {
    private contents: T;
    
    constructor(initial: T) {
        this.contents = initial;
    }
    
    get(): T {
        return this.contents;
    }
    
    set(value: T): void {
        this.contents = value;
    }
}

// Usage
const stringBox = new Box<string>('hello');
const numberBox = new Box(42); // Inferred
```

## Generic Interfaces

```typescript
interface Repository<T extends { id: string }> {
    findById(id: string): T | undefined;
    findAll(): T[];
    create(item: Omit<T, 'id'>): T;
    update(id: string, updates: Partial<T>): T | undefined;
    delete(id: string): boolean;
}
```

## Generic Constraints

```typescript
// Constraint with extends
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

// Constraint with object
function clone<T extends object>(obj: T): T {
    return { ...obj };
}

// Constraint with constructor
function create<T>(ctor: new (...args: any[]) => T, ...args: any[]): T {
    return new ctor(...args);
}
```

## Generic Utility Types

```typescript
// Extracting element type from array
type ElementType<T> = T extends (infer U)[] ? U : never;

// Extracting return type
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

// Extracting from Promise
type Awaited<T> = T extends Promise<infer U> ? U : T;

// Extracting from function parameters
type Parameters<T> = T extends (...args: infer P) => any ? P : never;
```

---

# 8. Interfaces & Type Aliases

## Interface Syntax

```typescript
// Basic interface
interface User {
    id: string;
    name: string;
    email: string;
    age?: number; // Optional
    readonly createdAt: Date; // Read-only
}

// Extending interfaces
interface Admin extends User {
    role: 'admin';
    permissions: string[];
}

// Multiple inheritance
interface Employee extends User, Admin {
    department: string;
}

// Index signature
interface StringDictionary {
    [key: string]: string;
}

// Method signatures
interface Greetable {
    greet(): string;
    greetWithName(name: string): string;
}
```

## Type Alias Syntax

```typescript
// Type alias for primitive
type UserId = string;

// Type alias for union
type Status = 'pending' | 'active' | 'completed';

// Type alias for object
type User = {
    id: string;
    name: string;
    email: string;
};

// Type alias for function
type UserHandler = (user: User) => void;

// Type alias for tuple
type UserTuple = [string, string, number];

// Type alias with intersection
type Entity = { id: string } & { createdAt: Date };
```

## Interface vs Type Comparison

```typescript
// Interface (extendable)
interface Animal {
    name: string;
}
interface Dog extends Animal {
    bark(): void;
}

// Type (union)
type Animal = { name: string };
type Dog = Animal & { bark(): void };

// Interface (declaration merging)
interface User {
    id: string;
}
interface User {
    name: string;
}
// User now has id and name

// Type (no declaration merging)
type User = { id: string };
// ❌ Cannot redeclare type User
```

---

# 9. Functions

## Function Type Annotations

```typescript
// Function declaration
function add(a: number, b: number): number {
    return a + b;
}

// Arrow function
const add = (a: number, b: number): number => a + b;

// Function type
type AddFunction = (a: number, b: number) => number;

// Function interface
interface AddFunction {
    (a: number, b: number): number;
}
```

## Optional Parameters

```typescript
function greet(name: string, greeting?: string): string {
    if (greeting) {
        return `${greeting}, ${name}`;
    }
    return `Hello, ${name}`;
}

greet('Alice'); // "Hello, Alice"
greet('Bob', 'Hi'); // "Hi, Bob"
```

## Default Parameters

```typescript
function createUser(name: string, age: number = 18): User {
    return { id: generateId(), name, age };
}
```

## Rest Parameters

```typescript
function sum(...numbers: number[]): number {
    return numbers.reduce((a, b) => a + b, 0);
}

sum(1, 2, 3); // 6
sum(1, 2, 3, 4, 5); // 15
```

## Function Overloads

```typescript
function process(value: string): string;
function process(value: number): number;
function process(value: any): any {
    if (typeof value === 'string') {
        return value.toUpperCase();
    }
    if (typeof value === 'number') {
        return value * 2;
    }
}

process('hello'); // "HELLO"
process(21); // 42
```

## `this` Parameter

```typescript
interface User {
    name: string;
    greet(this: User): string;
}

const user: User = {
    name: 'Alice',
    greet() {
        return `Hello, ${this.name}`;
    }
};
```

---

# 10. Classes

## Class Syntax

```typescript
class Task {
    // Properties
    id: string;
    title: string;
    completed: boolean;
    private createdAt: Date; // Private
    protected updatedAt: Date; // Protected
    
    // Constructor
    constructor(title: string) {
        this.id = `task_${Date.now()}`;
        this.title = title;
        this.completed = false;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
    
    // Methods
    complete(): void {
        this.completed = true;
        this.updatedAt = new Date();
    }
    
    getInfo(): string {
        return `${this.title} (${this.completed ? '✅' : '⬜'})`;
    }
}
```

## Inheritance

```typescript
class User {
    constructor(public name: string, protected age: number) {}
    
    greet(): string {
        return `Hello, ${this.name}`;
    }
}

class Admin extends User {
    private role: 'admin' = 'admin';
    
    constructor(name: string, age: number, private permissions: string[]) {
        super(name, age);
    }
    
    // Override method
    greet(): string {
        return `Hello, Administrator ${this.name}`;
    }
    
    hasPermission(permission: string): boolean {
        return this.permissions.includes(permission);
    }
}
```

## Abstract Classes

```typescript
abstract class Repository<T> {
    abstract findById(id: string): T | undefined;
    abstract findAll(): T[];
    abstract create(item: Omit<T, 'id'>): T;
    
    // Concrete method
    exists(id: string): boolean {
        return this.findById(id) !== undefined;
    }
}

class TaskRepository extends Repository<Task> {
    // Must implement abstract methods
    findById(id: string): Task | undefined {
        // Implementation
    }
    
    findAll(): Task[] {
        // Implementation
    }
    
    create(item: Omit<Task, 'id'>): Task {
        // Implementation
    }
}
```

## Implement Interface

```typescript
interface Printable {
    print(): void;
}

interface Savable {
    save(): Promise<void>;
}

class Document implements Printable, Savable {
    constructor(private content: string) {}
    
    print(): void {
        console.log(this.content);
    }
    
    async save(): Promise<void> {
        // Save to database
    }
}
```

---

# 11. Modules & Imports

## ES Modules

```typescript
// Exporting
export interface User {
    id: string;
    name: string;
}

export function createUser(name: string): User {
    return { id: generateId(), name };
}

export const DEFAULT_USER: User = {
    id: 'default',
    name: 'Guest'
};

// Default export
export default class Task {
    // ...
}

// Importing
import Task, { User, createUser, DEFAULT_USER } from './types';
```

## Namespace Export

```typescript
// Re-export
export * from './user';
export { User as ApiUser } from './api';
```

## Type-Only Imports

```typescript
// Import types only (for performance)
import type { User, Task } from './types';
import { createUser } from './utils'; // Runtime import
```

## Path Aliases (tsconfig.json)

```typescript
// Configure in tsconfig.json
{
    "compilerOptions": {
        "paths": {
            "@/*": ["./src/*"],
            "@types/*": ["./src/types/*"],
            "@utils/*": ["./src/utils/*"]
        }
    }
}

// Use in code
import { User } from '@types/user';
import { formatDate } from '@utils/date';
```

---

# 12. React TypeScript Patterns

## Component Props

```typescript
// Basic props
interface ButtonProps {
    children: React.ReactNode;
    variant?: 'primary' | 'secondary' | 'danger';
    size?: 'sm' | 'md' | 'lg';
    onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
    isLoading?: boolean;
    disabled?: boolean;
}

// Extend native element props
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label?: string;
    error?: string;
    helper?: string;
}
```

## Function Components

```typescript
// With interface
const Button: React.FC<ButtonProps> = ({
    children,
    variant = 'primary',
    isLoading = false,
    ...props
}) => {
    return (
        <button className={`btn btn-${variant}`} {...props}>
            {isLoading ? 'Loading...' : children}
        </button>
    );
};

// With explicit return type
const Button = ({ children, variant = 'primary', ...props }: ButtonProps): JSX.Element => {
    return <button className={`btn btn-${variant}`} {...props}>{children}</button>;
};
```

## Forward Refs

```typescript
interface InputProps {
    label?: string;
    error?: string;
}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
    ({ label, error, ...props }, ref) => {
        return (
            <div>
                {label && <label>{label}</label>}
                <input ref={ref} {...props} />
                {error && <span className="error">{error}</span>}
            </div>
        );
    }
);

Input.displayName = 'Input';
```

## Generic Components

```typescript
interface ListProps<T> {
    items: T[];
    renderItem: (item: T, index: number) => React.ReactNode;
    keyExtractor: (item: T) => string;
    emptyMessage?: string;
}

function List<T>({
    items,
    renderItem,
    keyExtractor,
    emptyMessage = 'No items'
}: ListProps<T>) {
    if (items.length === 0) {
        return <p>{emptyMessage}</p>;
    }
    
    return (
        <div>
            {items.map((item, index) => (
                <div key={keyExtractor(item)}>
                    {renderItem(item, index)}
                </div>
            ))}
        </div>
    );
}

// Usage
<List
    items={tasks}
    renderItem={(task) => <TaskCard task={task} />}
    keyExtractor={(task) => task.id}
/>
```

## Custom Hooks

```typescript
// useLocalStorage
function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
    const [value, setValue] = useState<T>(() => {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : initialValue;
        } catch {
            return initialValue;
        }
    });
    
    useEffect(() => {
        localStorage.setItem(key, JSON.stringify(value));
    }, [key, value]);
    
    return [value, setValue];
}

// useFetch
function useFetch<T>(url: string): {
    data: T | null;
    loading: boolean;
    error: Error | null;
    refetch: () => Promise<void>;
} {
    const [data, setData] = useState<T | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<Error | null>(null);
    
    const fetchData = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await fetch(url);
            const data = await response.json();
            setData(data);
        } catch (err) {
            setError(err instanceof Error ? err : new Error('Unknown error'));
        } finally {
            setLoading(false);
        }
    }, [url]);
    
    useEffect(() => {
        fetchData();
    }, [fetchData]);
    
    return { data, loading, error, refetch: fetchData };
}
```

## Context

```typescript
// Define context type
interface ThemeContextType {
    theme: 'light' | 'dark';
    toggleTheme: () => void;
}

// Create context
const ThemeContext = React.createContext<ThemeContextType | undefined>(undefined);

// Provider
export function ThemeProvider({ children }: { children: React.ReactNode }) {
    const [theme, setTheme] = useState<'light' | 'dark'>('light');
    
    const toggleTheme = useCallback(() => {
        setTheme(t => t === 'light' ? 'dark' : 'light');
    }, []);
    
    const value = useMemo(() => ({ theme, toggleTheme }), [theme, toggleTheme]);
    
    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    );
}

// Custom hook
export function useTheme(): ThemeContextType {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
}

// Usage
function App() {
    return (
        <ThemeProvider>
            <Component />
        </ThemeProvider>
    );
}

function Component() {
    const { theme, toggleTheme } = useTheme();
    return (
        <div className={theme}>
            <button onClick={toggleTheme}>Toggle Theme</button>
        </div>
    );
}
```

## Forms with React Hook Form + Zod

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Zod schema
const TaskSchema = z.object({
    title: z.string().min(3, 'Title must be at least 3 characters'),
    description: z.string().max(500).optional(),
    priority: z.enum(['low', 'medium', 'high']),
    dueDate: z.coerce.date().optional().refine(
        date => !date || date > new Date(),
        'Due date must be in the future'
    )
});

type TaskFormData = z.infer<typeof TaskSchema>;

// Form component
function TaskForm({ onSubmit }: { onSubmit: (data: TaskFormData) => void }) {
    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting }
    } = useForm<TaskFormData>({
        resolver: zodResolver(TaskSchema),
        defaultValues: {
            title: '',
            priority: 'medium'
        }
    });
    
    return (
        <form onSubmit={handleSubmit(onSubmit)}>
            <div>
                <label>Title</label>
                <input {...register('title')} />
                {errors.title && <p className="error">{errors.title.message}</p>}
            </div>
            
            <div>
                <label>Priority</label>
                <select {...register('priority')}>
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                </select>
            </div>
            
            <button type="submit" disabled={isSubmitting}>
                {isSubmitting ? 'Saving...' : 'Save'}
            </button>
        </form>
    );
}
```

---

# 13. Next.js TypeScript Patterns

## Server Components

```typescript
// app/page.tsx (Server Component)
import { prisma } from '@/lib/prisma';
import { TaskList } from '@/components/TaskList';

export default async function HomePage() {
    const tasks = await prisma.task.findMany({
        include: {
            assignee: {
                select: {
                    id: true,
                    name: true
                }
            }
        },
        orderBy: { createdAt: 'desc' }
    });
    
    return <TaskList initialTasks={tasks} />;
}
```

## Client Components

```typescript
// components/TaskList.tsx
'use client';

import { useState } from 'react';
import { updateTaskStatus, deleteTask } from '@/server/actions/taskActions';
import type { Task } from '@prisma/client';

interface TaskListProps {
    initialTasks: Task[];
}

export function TaskList({ initialTasks }: TaskListProps) {
    const [tasks, setTasks] = useState(initialTasks);
    
    const handleStatusChange = async (id: string, status: Task['status']) => {
        // Optimistic update
        setTasks(tasks.map(task =>
            task.id === id ? { ...task, status } : task
        ));
        
        const result = await updateTaskStatus(id, status);
        if (!result.success) {
            // Revert on error
            setTasks(initialTasks);
            console.error(result.error);
        }
    };
    
    // ...
}
```

## Page Props

```typescript
// app/tasks/[id]/page.tsx
interface PageProps {
    params: { id: string };
    searchParams: { [key: string]: string | string[] | undefined };
}

export default async function TaskPage({ params, searchParams }: PageProps) {
    const task = await getTask(params.id);
    const view = searchParams.view || 'details';
    
    return <TaskView task={task} view={view as 'details' | 'comments'} />;
}
```

## Server Actions

```typescript
// server/actions/taskActions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import { prisma } from '@/lib/prisma';

const TaskSchema = z.object({
    title: z.string().min(3),
    description: z.string().optional(),
    priority: z.enum(['low', 'medium', 'high']),
    projectId: z.string()
});

type CreateTaskInput = z.infer<typeof TaskSchema>;

export async function createTask(data: CreateTaskInput) {
    const validation = TaskSchema.safeParse(data);
    
    if (!validation.success) {
        return {
            success: false,
            error: validation.error.errors[0].message
        };
    }
    
    try {
        const task = await prisma.task.create({
            data: validation.data
        });
        
        revalidatePath('/tasks');
        revalidatePath(`/projects/${task.projectId}`);
        
        return { success: true, data: task };
    } catch (error) {
        return {
            success: false,
            error: error instanceof Error ? error.message : 'Unknown error'
        };
    }
}
```

## API Routes

```typescript
// app/api/tasks/route.ts
import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaskSchema } from '@/validations/taskValidation';

export async function GET(request: Request) {
    const { searchParams } = new URL(request.url);
    const projectId = searchParams.get('projectId');
    const status = searchParams.get('status');
    
    const where: any = {};
    if (projectId) where.projectId = projectId;
    if (status) where.status = status;
    
    try {
        const tasks = await prisma.task.findMany({
            where,
            include: {
                assignee: true,
                creator: true
            }
        });
        
        return NextResponse.json({
            success: true,
            data: tasks,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        return NextResponse.json(
            { success: false, error: 'Failed to fetch tasks' },
            { status: 500 }
        );
    }
}

export async function POST(request: Request) {
    const body = await request.json();
    const validation = TaskSchema.safeParse(body);
    
    if (!validation.success) {
        return NextResponse.json(
            { success: false, error: 'Validation failed' },
            { status: 400 }
        );
    }
    
    try {
        const task = await prisma.task.create({
            data: validation.data
        });
        
        return NextResponse.json(
            { success: true, data: task },
            { status: 201 }
        );
    } catch (error) {
        return NextResponse.json(
            { success: false, error: 'Failed to create task' },
            { status: 500 }
        );
    }
}
```

## Environment Variables

```typescript
// lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'production', 'test']),
    DATABASE_URL: z.string().min(1),
    JWT_SECRET: z.string().min(32),
    NEXT_PUBLIC_API_URL: z.string().url().optional(),
    NEXT_PUBLIC_APP_NAME: z.string().default('TaskFlow')
});

const env = envSchema.safeParse(process.env);

if (!env.success) {
    console.error('❌ Invalid environment variables:', env.error.format());
    throw new Error('Invalid environment variables');
}

export const env = env.data;
export type Env = z.infer<typeof envSchema>;
```

---

# 14. Common TypeScript Errors

## Error Reference

| Error Code | Error Message | Solution |
|------------|---------------|----------|
| TS2322 | Type 'X' is not assignable to type 'Y' | Check type compatibility |
| TS2339 | Property 'x' does not exist on type 'Y' | Add property or use type guard |
| TS2345 | Argument of type 'X' is not assignable to parameter of type 'Y' | Convert or cast the value |
| TS2531 | Object is possibly 'null' or 'undefined' | Use optional chaining or check |
| TS2304 | Cannot find name 'x' | Import or declare the variable |
| TS2554 | Expected X arguments, but got Y | Check function signature |
| TS2454 | Variable 'x' is used before being assigned | Initialize the variable |
| TS7006 | Parameter 'x' implicitly has 'any' type | Add type annotation |
| TS7030 | Not all code paths return a value | Add a return statement |
| TS7005 | Variable 'x' implicitly has 'any' type | Add type annotation |

## Common Solutions

```typescript
// Error: Property does not exist
// Solution: Add property or use type guard
interface User {
    name: string;
    // age?: number; // Add optional property
}

// Error: Object is possibly null
// Solution: Use optional chaining
const name = user?.name;

// Error: Argument type mismatch
// Solution: Convert or cast
const num = Number(stringValue);
const str = String(numberValue);

// Error: Not all code paths return value
// Solution: Add return for all paths
function getValue(value: string): string {
    if (value) {
        return value.toUpperCase();
    }
    return 'default'; // Add this
}

// Error: Implicit any
// Solution: Add type annotation
function greet(name: string): string {
    return `Hello, ${name}`;
}
```

---

# 15. tsconfig.json Reference

## Common Options

```json
{
  "compilerOptions": {
    // Type Checking
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "useUnknownInCatchVariables": true,
    
    // Module Resolution
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    
    // Output
    "outDir": "./dist",
    "rootDir": "./src",
    "sourceMap": true,
    "declaration": true,
    "declarationMap": true,
    
    // Interoperability
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    
    // Path Aliases
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@types/*": ["./src/types/*"],
      "@utils/*": ["./src/utils/*"]
    },
    
    // Additional
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noUncheckedIndexedAccess": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true
  },
  "include": ["src/**/*", "src/**/*.tsx"],
  "exclude": ["node_modules", "dist", "coverage"]
}
```

## Preset Configurations

### React Project

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  }
}
```

### Next.js Project

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
      "@/*": ["./src/*"]
    }
  }
}
```

### Node.js Project

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "sourceMap": true
  }
}
```

---

# 16. Command Reference

## TypeScript Commands

```bash
# Install TypeScript
npm install -g typescript
npm install --save-dev typescript

# Compile TypeScript
tsc
tsc --watch
tsc --noEmit

# Initialize tsconfig.json
tsc --init

# Check types only
tsc --noEmit --skipLibCheck

# Run TypeScript with node (ts-node)
npx ts-node file.ts

# TypeScript ESLint
npx eslint --ext .ts,.tsx .

# Generate declaration files
tsc --declaration

# Generate source maps
tsc --sourceMap
```

## Package.json Scripts

```json
{
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "dev": "tsc --watch & nodemon dist/index.js",
    "start": "node dist/index.js",
    "type-check": "tsc --noEmit",
    "type-check:watch": "tsc --noEmit --watch"
  }
}
```

## Testing Commands (Vitest)

```bash
# Run tests
npm run test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch

# Run tests once (CI)
npm run test:run

# Run tests with UI
npm run test:ui
```

---

# 17. Code Snippets Library

## Type Guard Functions

```typescript
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

function isNumber(value: unknown): value is number {
    return typeof value === 'number' && !isNaN(value);
}

function isArray<T>(value: unknown, typeGuard: (v: unknown) => v is T): value is T[] {
    return Array.isArray(value) && value.every(typeGuard);
}

function isObject(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null;
}

function isUUID(value: string): boolean {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    return uuidRegex.test(value);
}

function isDate(value: unknown): value is Date {
    return value instanceof Date && !isNaN(value.getTime());
}
```

## Validation Utilities

```typescript
// Result type
type Result<T> = 
    | { success: true; data: T }
    | { success: false; error: string };

function validate<T>(value: unknown, check: (value: unknown) => value is T): Result<T> {
    if (check(value)) {
        return { success: true, data: value };
    }
    return { success: false, error: 'Validation failed' };
}

// With Zod
import { z } from 'zod';

function validateWithZod<T>(schema: z.ZodSchema<T>, data: unknown): Result<T> {
    const result = schema.safeParse(data);
    if (result.success) {
        return { success: true, data: result.data };
    }
    return { 
        success: false, 
        error: result.error.errors.map(e => e.message).join(', ') 
    };
}
```

## API Client

```typescript
interface ApiResponse<T> {
    data: T;
    status: number;
    message: string;
    timestamp: string;
}

class ApiClient {
    private baseUrl: string;
    private headers: Record<string, string>;
    
    constructor(baseUrl: string, headers: Record<string, string> = {}) {
        this.baseUrl = baseUrl;
        this.headers = {
            'Content-Type': 'application/json',
            ...headers
        };
    }
    
    async get<T>(endpoint: string): Promise<ApiResponse<T>> {
        const response = await fetch(`${this.baseUrl}${endpoint}`, {
            headers: this.headers
        });
        return this.handleResponse<T>(response);
    }
    
    async post<T, D = any>(endpoint: string, data: D): Promise<ApiResponse<T>> {
        const response = await fetch(`${this.baseUrl}${endpoint}`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify(data)
        });
        return this.handleResponse<T>(response);
    }
    
    async put<T, D = any>(endpoint: string, data: D): Promise<ApiResponse<T>> {
        const response = await fetch(`${this.baseUrl}${endpoint}`, {
            method: 'PUT',
            headers: this.headers,
            body: JSON.stringify(data)
        });
        return this.handleResponse<T>(response);
    }
    
    async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
        const response = await fetch(`${this.baseUrl}${endpoint}`, {
            method: 'DELETE',
            headers: this.headers
        });
        return this.handleResponse<T>(response);
    }
    
    private async handleResponse<T>(response: Response): Promise<ApiResponse<T>> {
        const data = await response.json();
        return {
            data: data as T,
            status: response.status,
            message: data.message || 'OK',
            timestamp: new Date().toISOString()
        };
    }
}
```

## Logger Utility

```typescript
type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LoggerOptions {
    level: LogLevel;
    context?: Record<string, any>;
}

class Logger {
    private level: LogLevel;
    private context: Record<string, any>;
    private levels: Record<LogLevel, number> = {
        debug: 0,
        info: 1,
        warn: 2,
        error: 3
    };
    
    constructor(options: LoggerOptions) {
        this.level = options.level;
        this.context = options.context || {};
    }
    
    private shouldLog(level: LogLevel): boolean {
        return this.levels[level] >= this.levels[this.level];
    }
    
    private log(level: LogLevel, message: string, data?: any) {
        if (!this.shouldLog(level)) return;
        
        const timestamp = new Date().toISOString();
        const logEntry = {
            timestamp,
            level,
            message,
            context: this.context,
            data
        };
        
        console.log(JSON.stringify(logEntry));
    }
    
    debug(message: string, data?: any) {
        this.log('debug', message, data);
    }
    
    info(message: string, data?: any) {
        this.log('info', message, data);
    }
    
    warn(message: string, data?: any) {
        this.log('warn', message, data);
    }
    
    error(message: string, data?: any) {
        this.log('error', message, data);
    }
    
    child(newContext: Record<string, any>): Logger {
        return new Logger({
            level: this.level,
            context: { ...this.context, ...newContext }
        });
    }
}
```

## Repository Pattern

```typescript
interface Entity {
    id: string;
}

class Repository<T extends Entity> {
    private items: Map<string, T> = new Map();
    
    create(data: Omit<T, 'id'>): T {
        const id = `item_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const item = { ...data, id } as T;
        this.items.set(id, item);
        return item;
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
    
    count(): number {
        return this.items.size;
    }
    
    exists(id: string): boolean {
        return this.items.has(id);
    }
}
```

---

## Quick Reference Card

```typescript
// Types
type T = string | number | boolean | null | undefined;
type T = { property: Type };
type T = Array<Type> | Type[];
type T = [Type1, Type2]; // Tuple

// Functions
function fn(param: Type): ReturnType { ... }
const fn = (param: Type): ReturnType => { ... };

// Generics
function fn<T>(param: T): T { ... }
class Box<T> { contents: T; }

// Utility Types
Partial<T>     // All optional
Required<T>    // All required
Readonly<T>    // All read-only
Pick<T, K>     // Select properties
Omit<T, K>     // Exclude properties
Record<K, T>   // Key-value map
Exclude<T, U>  // Remove union members
Extract<T, U>  // Keep union members
ReturnType<T>  // Function return type

// React
type Props = { children: ReactNode; }
const Component: React.FC<Props> = (props) => { ... }
const ref = React.forwardRef<HTMLElement, Props>((props, ref) => { ... })

// Next.js
'use client';  // Client component
export default async function Page() { ... } // Server component
'use server';  // Server action

// Testing
describe('suite', () => {
    it('test', () => {
        expect(value).toBe(expected);
    });
});
```

---
