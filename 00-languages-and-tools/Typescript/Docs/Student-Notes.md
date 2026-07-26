# Mastering TypeScript: Student Notes

## Complete Study Notes for the Entire Series

---

# Part 1: Core Mental Model and Foundations

## 1.1 What TypeScript Really Is

### Key Concepts
- **TypeScript is a compile-time type checker** - It analyzes your code before it runs
- **TypeScript is a superset of JavaScript** - All valid JS is valid TS
- **Types don't exist at runtime** - They're stripped away during compilation
- **TypeScript is a development tool** - It helps you write better code, but doesn't make it faster

### Mental Model Shift
```
JavaScript: Write → Run → Hit Error → Fix → Repeat
TypeScript: Write → Type Check → Fix → Run → Fewer Errors
```

### Core Truths to Remember
1. TypeScript prevents many bugs, but not all (logic errors still happen)
2. TypeScript types are compile-time only
3. TypeScript doesn't change how your code runs
4. TypeScript is optional - you can gradually adopt it

---

## 1.2 Basic Types and Type Inference

### Primitive Types
```typescript
string      // "hello"
number      // 42, 3.14
boolean     // true, false
null        // null
undefined   // undefined
```

### Type Inference
```typescript
let name = "TaskFlow";        // TypeScript infers: string
let version = 1.0;            // TypeScript infers: number
let isActive = true;          // TypeScript infers: boolean
```

### Explicit Type Annotations
```typescript
let projectId: string = "proj_123";
let taskCount: number = 0;
const isPublic: boolean = true;
```

### Arrays
```typescript
// Two ways to write array types
let taskNames: string[] = ["Write docs", "Review code"];
let projectIds: Array<string> = ["proj_123", "proj_456"];
```

### Functions
```typescript
function greet(name: string): string {
    return `Hello, ${name}`;
}
// Parameter types: name: string
// Return type: : string
```

### Objects
```typescript
// Inline type annotation
let task: { id: string; title: string; completed: boolean } = {
    id: "task_123",
    title: "Complete onboarding",
    completed: false
};
```

---

## 1.3 Type Aliases and Unions

### Type Aliases
```typescript
type Task = {
    id: string;
    title: string;
    description?: string;    // Optional property
    completed: boolean;
    priority: 'low' | 'medium' | 'high';  // Union of string literals
};

// Using the alias
const myTask: Task = {
    id: "task_001",
    title: "Set up TypeScript",
    completed: false,
    priority: "high"
};
```

### Union Types
```typescript
let projectId: string | number = "PROJ-123";
projectId = 12345;  // Also valid
```

### Type Narrowing
```typescript
function formatIdentifier(id: string | number): string {
    if (typeof id === 'string') {
        return id.toUpperCase();     // TypeScript knows id is string
    } else {
        return id.toString();         // TypeScript knows id is number
    }
}
```

### Key Narrowing Techniques
| Technique | When to Use | Example |
|-----------|-------------|---------|
| `typeof` | Checking primitive types | `typeof value === 'string'` |
| Equality | Comparing values | `status === 'pending'` |
| Truthiness | Checking existence | `if (!task) { ... }` |
| `in` operator | Checking properties | `'priority' in task` |
| `instanceof` | Checking classes | `task instanceof Task` |

### Discriminated Unions
```typescript
type TaskEvent = 
    | { type: 'created'; taskId: string; timestamp: Date }
    | { type: 'completed'; taskId: string; completedAt: Date };

function handleEvent(event: TaskEvent) {
    switch (event.type) {
        case 'created':
            // TypeScript knows this has taskId and timestamp
            console.log(event.taskId, event.timestamp);
            break;
        case 'completed':
            // TypeScript knows this has taskId and completedAt
            console.log(event.taskId, event.completedAt);
            break;
    }
}
```

---

## 1.4 any, unknown, and never

### Comparison Table

| Type | What It Is | When to Use |
|------|------------|-------------|
| **any** | Disables type checking | Last resort, gradual migration |
| **unknown** | Safe alternative to any | When type is truly unknown |
| **never** | Values that never occur | Exhaustive checking, error functions |

### unknown Example
```typescript
let userInput: unknown = "Hello";
// userInput.toUpperCase();  // ❌ Error!
if (typeof userInput === 'string') {
    console.log(userInput.toUpperCase());  // ✅ Safe
}
```

### never Example
```typescript
function throwError(message: string): never {
    throw new Error(message);
}

function handlePriority(priority: 'low' | 'medium' | 'high'): string {
    switch (priority) {
        case 'low': return 'Low';
        case 'medium': return 'Medium';
        case 'high': return 'High';
        default:
            const exhaustiveCheck: never = priority;
            return exhaustiveCheck;
    }
}
```

---

# Part 2: Objects, Reuse, and Utility Types

## 2.1 Interfaces vs. Type Aliases

### Interface
```typescript
// Contract that can be extended
interface Task {
    id: string;
    title: string;
    completed: boolean;
}

// Extension
interface PriorityTask extends Task {
    priority: 'low' | 'medium' | 'high';
}

// Declaration merging (adds to existing interface)
interface Task {
    createdAt: Date;
}
```

### Type Alias
```typescript
// Can name any type
type TaskId = string;
type TaskStatus = 'todo' | 'in-progress' | 'done';
type TaskHandler = (task: Task) => void;

// Type alias for object
type Task = {
    id: TaskId;
    title: string;
    completed: boolean;
};

// Intersection
type DetailedTask = Task & {
    description: string;
    dueDate: Date;
};
```

### When to Use Each

| Interface | Type Alias |
|-----------|------------|
| Extending objects | Union types |
| Declaration merging | Mapped types |
| Classes implementing | Primitive types |
| Library APIs | Conditional types |

---

## 2.2 Generics

### What Are Generics?
Generics are like templates that work with any type while maintaining type safety.

### Generic Functions
```typescript
// Basic generic
function identity<T>(value: T): T {
    return value;
}

// With array
function first<T>(items: T[]): T | undefined {
    return items[0];
}

// With constraints
function getName<T extends { name: string }>(item: T): string {
    return item.name;
}

// Multiple types
function mapKey<T, K extends keyof T, U>(
    obj: T,
    key: K,
    mapFn: (value: T[K]) => U
): Record<K, U> {
    return { [key]: mapFn(obj[key]) } as Record<K, U>;
}
```

### Generic Classes
```typescript
class Box<T> {
    private contents: T;
    
    constructor(initial: T) {
        this.contents = initial;
    }
    
    getContents(): T {
        return this.contents;
    }
}

const stringBox = new Box<string>("Hello");
const numberBox = new Box<number>(42);
```

### Generic Repositories
```typescript
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
}
```

---

## 2.3 Utility Types

### Quick Reference

| Utility Type | Purpose | Example |
|--------------|---------|---------|
| `Partial<T>` | All properties optional | `Partial<Task>` |
| `Required<T>` | All properties required | `Required<OptionalTask>` |
| `Readonly<T>` | All properties read-only | `Readonly<Task>` |
| `Pick<T, K>` | Select specific properties | `Pick<Task, 'id' | 'title'>` |
| `Omit<T, K>` | Exclude specific properties | `Omit<Task, 'id'>` |
| `Record<K, T>` | Key-value map | `Record<'status', string>` |
| `Exclude<T, U>` | Remove union members | `Exclude<Status, 'done'>` |
| `Extract<T, U>` | Keep union members | `Extract<Status, 'pending'>` |
| `NonNullable<T>` | Remove null/undefined | `NonNullable<MaybeString>` |
| `ReturnType<T>` | Function return type | `ReturnType<typeof fn>` |
| `Parameters<T>` | Function parameters | `Parameters<typeof fn>` |

### Examples
```typescript
type Task = {
    id: string;
    title: string;
    description?: string;
    completed: boolean;
};

// Partial: All optional
type PartialTask = Partial<Task>;

// Pick: Select properties
type TaskSummary = Pick<Task, 'id' | 'title'>;

// Omit: Exclude properties
type TaskWithoutId = Omit<Task, 'id'>;

// Record: Key-value map
type PriorityColors = Record<'low' | 'medium' | 'high', string>;
```

---

## 2.4 Advanced tsconfig.json

### Essential Strict Mode Options

| Option | What It Does |
|--------|--------------|
| `strict: true` | Enables all strict options |
| `noImplicitAny` | Error on implied any type |
| `strictNullChecks` | Require handling of null/undefined |
| `strictFunctionTypes` | Strict function parameter checking |
| `strictPropertyInitialization` | Ensure class properties initialized |
| `noImplicitThis` | Error when 'this' has type 'any' |
| `useUnknownInCatchVariables` | Use 'unknown' in catch blocks |

### Path Aliases
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@types/*": ["./src/types/*"],
      "@utils/*": ["./src/utils/*"],
      "@data/*": ["./src/data/*"]
    }
  }
}
```

---

# Part 3: Advanced Types and Type-Level Programming

## 3.1 Conditional Types

### Basic Syntax
```typescript
type IsString<T> = T extends string ? true : false;
// If T is a string, result is true, otherwise false
```

### Common Patterns

**Type Filtering:**
```typescript
type ExtractStrings<T> = T extends string ? T : never;
// Only keeps string types from a union
```

**Type Name:**
```typescript
type TypeName<T> =
    T extends string ? 'string' :
    T extends number ? 'number' :
    T extends boolean ? 'boolean' :
    'unknown';
```

**With infer:**
```typescript
type ElementType<T> = T extends (infer U)[] ? U : never;
// Extracts the element type from an array
```

### Distribution Over Unions
```typescript
// Conditional types distribute over unions
type ToArray<T> = T extends any ? T[] : never;
type Result = ToArray<string | number>;  // string[] | number[]
```

---

## 3.2 Mapped Types

### Basic Syntax
```typescript
type MakeOptional<T> = {
    [P in keyof T]?: T[P];
};

type MakeReadonly<T> = {
    readonly [P in keyof T]: T[P];
};
```

### Filtering Properties
```typescript
type KeepStringProperties<T> = {
    [P in keyof T as T[P] extends string ? P : never]: T[P];
};

type KeepNumberProperties<T> = {
    [P in keyof T as T[P] extends number ? P : never]: T[P];
};
```

### Transforming Properties
```typescript
type UppercaseProperties<T> = {
    [P in keyof T]: T[P] extends string ? Uppercase<T[P]> : T[P];
};

type Nullable<T> = {
    [P in keyof T]: T[P] | null;
};
```

### Deep Partial
```typescript
type DeepPartial<T> = {
    [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};
```

---

## 3.3 Template Literal Types

### Basic Usage
```typescript
type ApiEndpoint = `/api/${string}`;
type ApiRoute = `${'GET' | 'POST'} /${string}`;
```

### String Manipulation
```typescript
type ToCamelCase<S extends string> =
    S extends `${infer First}_${infer Rest}`
        ? `${Lowercase<First>}${Capitalize<ToCamelCase<Rest>>}`
        : Lowercase<S>;

// Example: "user_first_name" -> "userFirstName"
```

### URL Parameter Extraction
```typescript
type UrlParams<T extends string> =
    T extends `${string}:${infer Param}/${infer Rest}`
        ? { [K in Param | keyof UrlParams<Rest>]: string }
        : T extends `${string}:${infer Param}`
            ? { [K in Param]: string }
            : {};

// Example: "/api/users/:id/posts/:postId"
// Extracts: { id: string, postId: string }
```

---

## 3.4 The infer Keyword

### What is infer?
`infer` extracts a type from another type using pattern matching.

### Common Uses

**Extract Array Element:**
```typescript
type ElementType<T> = T extends (infer U)[] ? U : never;
```

**Extract Return Type:**
```typescript
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;
```

**Extract Parameters:**
```typescript
type Parameters<T> = T extends (...args: infer P) => any ? P : never;
```

**Extract Promise Value:**
```typescript
type Awaited<T> = T extends Promise<infer U> ? U : T;
```

---

# Part 4: TypeScript in React

## 4.1 Typing Components

### Props Types
```typescript
interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    children: ReactNode;
    variant?: 'primary' | 'secondary' | 'danger';
    size?: 'sm' | 'md' | 'lg';
    isLoading?: boolean;
}

export function Button({ children, variant = 'primary', ...props }: ButtonProps) {
    // Component implementation
}
```

### ForwardRef
```typescript
export const Input = forwardRef<HTMLInputElement, InputProps>(
    ({ label, error, ...props }, ref) => {
        return <input ref={ref} {...props} />;
    }
);
```

### Generic Components
```typescript
interface ListProps<T> {
    items: T[];
    renderItem: (item: T) => ReactNode;
    keyExtractor: (item: T) => string;
}

export function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
    return (
        <div>
            {items.map(item => (
                <div key={keyExtractor(item)}>
                    {renderItem(item)}
                </div>
            ))}
        </div>
    );
}
```

---

## 4.2 Custom Hooks

### useState with Type Inference
```typescript
const [tasks, setTasks] = useState<Task[]>([]);
// TypeScript infers Task[] from the generic
```

### useReducer with Actions
```typescript
type TaskAction = 
    | { type: 'ADD_TASK'; payload: Task }
    | { type: 'DELETE_TASK'; payload: string };

function taskReducer(state: Task[], action: TaskAction): Task[] {
    // Type-safe reducer implementation
}

const [tasks, dispatch] = useReducer(taskReducer, []);
```

### Generic Custom Hook
```typescript
function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
    const [storedValue, setStoredValue] = useState<T>(() => {
        // Read from localStorage
    });

    return [storedValue, setStoredValue];
}

// Usage
const [user, setUser] = useLocalStorage<User>('user', null);
```

### Data Fetching Hook
```typescript
function useFetch<T>(url: string): {
    data: T | null;
    loading: boolean;
    error: Error | null;
    refetch: () => Promise<void>;
} {
    // Generic data fetching hook
}
```

---

## 4.3 Context with Type Safety

### Defining Context Type
```typescript
interface TaskContextType {
    tasks: Task[];
    addTask: (task: Task) => void;
    deleteTask: (id: string) => void;
    updateTask: (task: Task) => void;
}

const TaskContext = createContext<TaskContextType | undefined>(undefined);
```

### Provider Component
```typescript
export function TaskProvider({ children }: { children: ReactNode }) {
    const [tasks, setTasks] = useState<Task[]>([]);
    
    const value = useMemo(() => ({
        tasks,
        addTask: (task) => setTasks(t => [...t, task]),
        deleteTask: (id) => setTasks(t => t.filter(task => task.id !== id)),
        updateTask: (task) => setTasks(t => 
            t.map(t => t.id === task.id ? task : t)
        ),
    }), [tasks]);

    return <TaskContext.Provider value={value}>{children}</TaskContext.Provider>;
}
```

### Custom Hook for Context
```typescript
export function useTasks(): TaskContextType {
    const context = useContext(TaskContext);
    if (context === undefined) {
        throw new Error('useTasks must be used within a TaskProvider');
    }
    return context;
}
```

---

## 4.4 Forms with React Hook Form + Zod

### Zod Schema
```typescript
const TaskSchema = z.object({
    title: z.string().min(3).max(100),
    description: z.string().max(500).optional(),
    priority: z.enum(['low', 'medium', 'high']),
    dueDate: z.coerce.date().optional(),
});

type TaskFormData = z.infer<typeof TaskSchema>;
```

### Form Component
```typescript
const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
} = useForm<TaskFormData>({
    resolver: zodResolver(TaskSchema),
    defaultValues: {
        title: '',
        priority: 'medium',
    }
});

const onSubmit = async (data: TaskFormData) => {
    // Data is fully typed
    await createTask(data);
};
```

### Field Integration
```typescript
<input
    type="text"
    {...register('title')}
    className={errors.title ? 'border-red-500' : ''}
/>
{errors.title && <p className="text-red-600">{errors.title.message}</p>}
```

---

# Part 5: TypeScript in Next.js

## 5.1 App Router with TypeScript

### Server Components
```typescript
// Server Component - Runs on the server
export default async function TasksPage() {
    const tasks = await prisma.task.findMany();
    return <TaskList initialTasks={tasks} />;
}
```

### Client Components
```typescript
'use client';  // Required for client components

export function TaskList({ initialTasks }: { initialTasks: Task[] }) {
    const [tasks, setTasks] = useState(initialTasks);
    // Interactive functionality
}
```

### Page Props
```typescript
interface PageProps {
    params: { id: string };
    searchParams: { [key: string]: string | string[] | undefined };
}

export default async function TaskPage({ params }: PageProps) {
    const task = await prisma.task.findUnique({
        where: { id: params.id }
    });
}
```

---

## 5.2 Server Actions

### Defining Server Actions
```typescript
'use server';  // Must be at the top

import { revalidatePath } from 'next/cache';
import { TaskSchema } from '@/validations/taskValidation';

export async function createTask(data: unknown) {
    const validation = TaskSchema.safeParse(data);
    
    if (!validation.success) {
        return { 
            success: false, 
            error: validation.error 
        };
    }

    const task = await prisma.task.create({
        data: validation.data
    });

    revalidatePath('/tasks');
    return { success: true, data: task };
}
```

### Using Server Actions in Components
```typescript
'use client';

const handleSubmit = async (data: TaskFormData) => {
    const result = await createTask(data);
    if (result.success) {
        router.refresh();
    } else {
        setError(result.error.message);
    }
};
```

---

## 5.3 API Routes

### GET Route
```typescript
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');
    
    const task = await prisma.task.findUnique({
        where: { id }
    });

    return NextResponse.json({
        success: true,
        data: task
    });
}
```

### POST Route with Validation
```typescript
export async function POST(request: Request) {
    const body = await request.json();
    const validation = TaskSchema.safeParse(body);

    if (!validation.success) {
        return NextResponse.json(
            { success: false, error: 'Validation failed' },
            { status: 400 }
        );
    }

    const task = await prisma.task.create({
        data: validation.data
    });

    return NextResponse.json({ success: true, data: task });
}
```

### Route with Parameters
```typescript
export async function GET(
    request: Request,
    { params }: { params: { id: string } }
) {
    const task = await prisma.task.findUnique({
        where: { id: params.id }
    });

    if (!task) {
        return NextResponse.json(
            { error: 'Task not found' },
            { status: 404 }
        );
    }

    return NextResponse.json({ data: task });
}
```

---

## 5.4 Environment Variables

### Defining Schema
```typescript
import { z } from 'zod';

const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'production', 'test']),
    DATABASE_URL: z.string().min(1),
    JWT_SECRET: z.string().min(32),
    NEXT_PUBLIC_API_URL: z.string().url().optional(),
});

const env = envSchema.safeParse(process.env);
if (!env.success) {
    console.error('Invalid environment variables:', env.error.format());
    throw new Error('Invalid environment variables');
}

export const env = env.data;
```

### Using Environment Variables
```typescript
// Server-side (always available)
const dbUrl = env.DATABASE_URL;
const secret = env.JWT_SECRET;

// Client-side (must start with NEXT_PUBLIC_)
const apiUrl = env.NEXT_PUBLIC_API_URL;
```

---

# Part 6: Architecture, Testing, and Debugging

## 6.1 Testing with Vitest

### Unit Test
```typescript
import { describe, it, expect } from 'vitest';

describe('TaskSchema', () => {
    it('should validate a valid task', () => {
        const result = TaskSchema.safeParse(validTask);
        expect(result.success).toBe(true);
    });

    it('should reject a task with short title', () => {
        const invalidTask = { ...validTask, title: 'Hi' };
        const result = TaskSchema.safeParse(invalidTask);
        expect(result.success).toBe(false);
    });
});
```

### Component Test
```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

it('should render tasks', () => {
    render(<TaskList initialTasks={mockTasks} />);
    expect(screen.getByText('Task 1')).toBeInTheDocument();
});

it('should handle task deletion', async () => {
    window.confirm = vi.fn(() => true);
    render(<TaskList initialTasks={mockTasks} />);
    await userEvent.click(screen.getByText('Delete'));
    expect(deleteTask).toHaveBeenCalledWith('1');
});
```

### Integration Test
```typescript
it('should return tasks', async () => {
    const mockTasks = [{ id: '1', title: 'Task 1' }];
    (prisma.task.findMany as any).mockResolvedValue(mockTasks);

    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.data).toEqual(mockTasks);
});
```

---

## 6.2 Debugging

### Logger Utility
```typescript
class Logger {
    log(level: string, message: string, meta?: any) {
        const timestamp = new Date().toISOString();
        console.log(`[${timestamp}] ${level}:`, { message, meta });
    }
}
```

### Type Debugging
```typescript
// Reveals the actual type
type Debug<T> = T extends any ? { [K in keyof T]: T[K] } : never;
```

### Assertion Utilities
```typescript
function assertNonNull<T>(
    value: T | null | undefined,
    message?: string
): asserts value is T {
    if (value === null || value === undefined) {
        throw new Error(message || 'Value is null or undefined');
    }
}
```

### Performance Measurement
```typescript
function measurePerformance<T>(fn: () => T, label: string): T {
    console.time(label);
    try {
        return fn();
    } finally {
        console.timeEnd(label);
    }
}
```

---

## 6.3 Architecture Patterns

### Clean Architecture Layers

1. **Domain Layer** (Entities)
   ```typescript
   interface DomainTask {
       id: string;
       title: string;
       status: 'todo' | 'in-progress' | 'done';
   }
   ```

2. **Application Layer** (Use Cases)
   ```typescript
   interface ITaskUseCases {
       createTask(dto: CreateTaskDTO): Promise<DomainTask>;
       getTasks(): Promise<DomainTask[]>;
   }
   ```

3. **Infrastructure Layer** (Repositories)
   ```typescript
   interface ITaskRepository {
       create(task: Omit<DomainTask, 'id'>): Promise<DomainTask>;
       findById(id: string): Promise<DomainTask | null>;
   }
   ```

### Dependency Injection
```typescript
class Container {
    private services = new Map<string, any>();

    register<T>(key: string, instance: T): void {
        this.services.set(key, instance);
    }

    get<T>(key: string): T {
        return this.services.get(key);
    }
}
```

---

## 6.4 Production Readiness

### Checklist

**Type Safety:**
- [ ] `strict: true` in tsconfig.json
- [ ] No `any` usage
- [ ] All API boundaries typed
- [ ] Environment variables validated

**Testing:**
- [ ] Unit tests for utilities
- [ ] Component tests
- [ ] Integration tests for API
- [ ] Test coverage > 80%

**Performance:**
- [ ] Bundle optimization
- [ ] Code splitting
- [ ] Image optimization
- [ ] Caching strategy

**Monitoring:**
- [ ] Error tracking (Sentry)
- [ ] Performance metrics
- [ ] Health checks
- [ ] Structured logging

**Security:**
- [ ] Input validation
- [ ] CSRF protection
- [ ] Rate limiting
- [ ] Security headers

---

# Quick Reference Cards

## Type Inference
```
let x = 42;          // number
let y = "hello";     // string
let z = true;        // boolean
let arr = [1, 2, 3]; // number[]
```

## Common Type Annotations
```
string, number, boolean, null, undefined
Array<T> or T[]
[T, U] (tuple)
{ prop: T } (object)
T | U (union)
T & U (intersection)
```

## Utility Types Cheat Sheet
```
Partial<T>    - All optional
Required<T>   - All required
Readonly<T>   - All read-only
Pick<T, K>    - Select properties
Omit<T, K>    - Exclude properties
Record<K, T>  - Key-value map
Exclude<T, U> - Remove union members
Extract<T, U> - Keep union members
ReturnType<T> - Function return type
```

## Generic Syntax
```
function identity<T>(value: T): T
interface Box<T> { contents: T }
class Repository<T extends { id: string }>
```

## React Hook Types
```
useState<T>      - Returns [T, (value: T) => void]
useReducer       - Returns [T, (action: Action) => void]
useContext       - Returns T
useRef<T>        - Returns { current: T | null }
useCallback      - Returns T
useMemo          - Returns T
```

## Next.js Types
```
PageProps        - { params, searchParams }
LayoutProps      - { children, params }
Metadata         - Page metadata
RouteSegmentConfig - Route configuration
```

---

**End of Student Notes**

---

*These notes are designed to be a quick reference for the entire TypeScript Master Series. Review them regularly and refer to the full workbook for detailed exercises and examples.*
