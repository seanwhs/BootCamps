# Part 3: Advanced Types and Type-Level Programming

## 3.1 Understanding Type-Level Programming

Type-Level Programming is the ability to compute, transform, and manipulate types at compile time using TypeScript's type system. Think of it as writing programs that run on your types before your code runs.

### The Concept: Types as a Language

Just as JavaScript operates on values (strings, numbers, objects), TypeScript's type system operates on types. You can:
- Compute new types from existing ones
- Apply conditions to types
- Transform structures of types
- Extract information from complex types

```
JavaScript: Values → Operations → New Values
TypeScript: Types → Type Operations → New Types
```

### The Execution Model

Type-level operations happen at compile time, not runtime:

```typescript
// Runtime (JavaScript) - executes when your code runs
function add(a: number, b: number): number {
    return a + b; // This runs at runtime
}

// Type-level (TypeScript) - executes during compilation
type Add<T extends number, U extends number> = 
    T extends 0 ? U : 
    U extends 0 ? T : 
    never; // This is computed during compilation
```

## 3.2 Conditional Types

Conditional types allow us to choose between types based on a condition.

### The Concept: If-Else for Types

Conditional types work like an if-statement: `If (condition) then TypeA else TypeB`.

**File:** `src/types/conditional.ts`

```typescript
/**
 * Conditional Types in TypeScript
 * Types that depend on other types
 */

// --- Basic Conditional Types ---

type IsString<T> = T extends string ? true : false;

type Test1 = IsString<string>; // true
type Test2 = IsString<number>; // false
type Test3 = IsString<"hello">; // true

// --- Filtering Types ---

// Extract only string types from a union
type ExtractStrings<T> = T extends string ? T : never;

type Mixed = string | number | boolean | null;
type OnlyStrings = ExtractStrings<Mixed>; // string

// --- Conditional with Union Types ---

type IsArray<T> = T extends any[] ? true : false;

type TestArray1 = IsArray<string[]>; // true
type TestArray2 = IsArray<number>; // false

// --- Nested Conditional Types ---

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

type TestName1 = TypeName<string>; // 'string'
type TestName2 = TypeName<number[]>; // 'array'
type TestName3 = TypeName<() => void>; // 'function'

// --- Conditional with infer Keyword ---

// Extract the element type from an array
type ElementType<T> = T extends (infer U)[] ? U : never;

type ElementOfStringArray = ElementType<string[]>; // string
type ElementOfNumberArray = ElementType<number[]>; // number

// Extract return type of a function
type ReturnTypeOf<T> = T extends (...args: any[]) => infer R ? R : never;

type Fn = (x: number) => string;
type Result = ReturnTypeOf<Fn>; // string

// --- Practical: Type-safe Event Handlers ---

type EventMap = {
    click: { x: number; y: number };
    keydown: { key: string; code: string };
    resize: { width: number; height: number };
};

// Extract the event data type from a event name
type EventData<K extends keyof EventMap> = EventMap[K];

type ClickData = EventData<'click'>; // { x: number; y: number }
type KeyData = EventData<'keydown'>; // { key: string; code: string }

// A type-safe event handler
type EventHandler<K extends keyof EventMap> = (data: EventData<K>) => void;

function registerEventListener<K extends keyof EventMap>(
    eventName: K,
    handler: EventHandler<K>
): void {
    // Implementation would go here
    console.log(`Registered handler for ${String(eventName)}`);
}

// Usage - TypeScript ensures the handler receives the correct data
registerEventListener('click', (data) => {
    console.log(`Clicked at (${data.x}, ${data.y})`);
    // TypeScript knows data has x and y
});

// registerEventListener('click', (data) => {
//     console.log(data.key); // ❌ Error: 'key' doesn't exist on click data
// });

// --- Conditional Types with Union Distributivity ---

// Conditional types distribute over unions
type ToArray<T> = T extends any ? T[] : never;

type ResultUnion = ToArray<string | number>; // string[] | number[]
// This is the same as: ToArray<string> | ToArray<number>

// To prevent distributivity, wrap in a tuple
type ToArrayNonDistributive<T> = [T] extends [any] ? T[] : never;

type NonDistributiveResult = ToArrayNonDistributive<string | number>; // (string | number)[]

// --- Verification ---

console.log('\n=== Conditional Types Demo ===\n');

// Runtime verification
function testConditionalTypes() {
    // TypeScript types are compile-time only, so we test via examples
    
    const mixed: Mixed = "hello";
    console.log('Mixed type:', typeof mixed);
    
    // Event handler test
    registerEventListener('click', (data) => {
        console.log(`Event click: (${data.x}, ${data.y})`);
    });
    
    registerEventListener('resize', (data) => {
        console.log(`Event resize: ${data.width}x${data.height}`);
    });
    
    // Type guards using conditional types
    const value: string | number = Math.random() > 0.5 ? "hello" : 42;
    
    if (typeof value === 'string') {
        console.log('Value is a string:', value.toUpperCase());
    } else {
        console.log('Value is a number:', value.toFixed(2));
    }
}

testConditionalTypes();
```

## 3.3 Mapped Types

Mapped types transform the properties of an existing type, creating a new type by iterating over keys.

### The Concept: Map Function for Types

Just as JavaScript's `map()` transforms arrays, mapped types transform object types.

**File:** `src/types/mapped.ts`

```typescript
/**
 * Mapped Types in TypeScript
 * Transforming object types by iterating over properties
 */

// --- Basic Mapped Types ---

// Make all properties optional
type MakeOptional<T> = {
    [P in keyof T]?: T[P];
};

// Make all properties readonly
type MakeReadonly<T> = {
    readonly [P in keyof T]: T[P];
};

// --- Using Built-in Utility Types (which use mapped types) ---

// Let's see what Partial looks like under the hood
// type Partial<T> = {
//     [P in keyof T]?: T[P];
// };

// --- Custom Mapped Type: Add 'get' prefix ---

type WithGetAccessors<T> = {
    [P in keyof T as `get${Capitalize<string & P>}`]: () => T[P];
};

interface Task {
    id: string;
    title: string;
    completed: boolean;
}

type TaskAccessors = WithGetAccessors<Task>;
// {
//     getId: () => string;
//     getTitle: () => string;
//     getCompleted: () => boolean;
// }

// --- Filtering Properties by Value Type ---

// Only keep properties that are strings
type KeepStringProperties<T> = {
    [P in keyof T as T[P] extends string ? P : never]: T[P];
};

interface MixedProperties {
    id: string;
    title: string;
    count: number;
    active: boolean;
}

type StringOnly = KeepStringProperties<MixedProperties>;
// { id: string; title: string; }

// --- Transforming Property Types ---

// Convert all string properties to uppercase
type UppercaseProperties<T> = {
    [P in keyof T]: T[P] extends string ? Uppercase<T[P]> : T[P];
};

interface User {
    name: string;
    email: string;
    age: number;
}

type UppercaseUser = UppercaseProperties<User>;
// { name: Uppercase<string>; email: Uppercase<string>; age: number; }

// --- Adding New Properties ---

type AddTimestamp<T> = T & {
    createdAt: Date;
    updatedAt: Date;
};

interface Post {
    id: string;
    content: string;
}

type TimestampedPost = AddTimestamp<Post>;
// { id: string; content: string; createdAt: Date; updatedAt: Date; }

// --- Making Properties Nullable or Optional ---

type Nullable<T> = {
    [P in keyof T]: T[P] | null;
};

type Optional<T> = {
    [P in keyof T]?: T[P];
};

type DeepPartial<T> = {
    [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// --- Practical: API Response Mapper ---

type ApiResponse<T> = {
    data: T;
    status: number;
    message: string;
    timestamp: string;
};

// Transform API response to frontend-friendly format
type FrontendResponse<T> = {
    result: T;
    statusCode: number;
    statusText: string;
    receivedAt: Date;
};

// Map from ApiResponse to FrontendResponse
type MapApiToFrontend<T> = {
    [P in keyof FrontendResponse<never>]: 
        P extends 'result' ? T :
        P extends 'statusCode' ? number :
        P extends 'statusText' ? string :
        Date;
};

// Better: Use mapping with key remapping
type BetterMapApiToFrontend<T> = {
    result: T;
    statusCode: ApiResponse<T>['status'];
    statusText: ApiResponse<T>['message'];
    receivedAt: Date;
};

// --- Combining Mapped Types with Conditional Types ---

type ExtractProperties<T, U> = {
    [P in keyof T as T[P] extends U ? P : never]: T[P];
};

interface BlogPost {
    id: string;
    title: string;
    content: string;
    views: number;
    likes: number;
    published: boolean;
}

type StringProperties = ExtractProperties<BlogPost, string>;
// { id: string; title: string; content: string; }

type NumberProperties = ExtractProperties<BlogPost, number>;
// { views: number; likes: number; }

// --- Verification ---

console.log('\n=== Mapped Types Demo ===\n');

// Demonstrate mapped types in action
function testMappedTypes() {
    // Create an object of type UppercaseUser
    const user: UppercaseUser = {
        name: 'Alice' as Uppercase<string>, // We need to cast here for demonstration
        email: 'ALICE@EXAMPLE.COM' as Uppercase<string>,
        age: 30
    };
    
    console.log('User:', user);
    
    // Create a timestamped post
    const post: TimestampedPost = {
        id: 'post_1',
        content: 'Hello, World!',
        createdAt: new Date(),
        updatedAt: new Date()
    };
    
    console.log('Post:', post);
    
    // Blog post with extracted properties
    const blogPost: BlogPost = {
        id: 'blog_1',
        title: 'Advanced TypeScript',
        content: 'Learning mapped types...',
        views: 100,
        likes: 10,
        published: true
    };
    
    console.log('Blog post:', blogPost);
    console.log('String properties:', 
        Object.keys(blogPost).filter(key => typeof blogPost[key as keyof BlogPost] === 'string')
    );
}

testMappedTypes();
```

## 3.4 Indexed Access Types and Template Literal Types

Indexed access types let you look up specific properties, and template literal types allow you to build string types.

### The Concept: Looking Up Types and Building Strings

**File:** `src/types/advanced.ts`

```typescript
/**
 * Indexed Access Types and Template Literal Types
 */

// --- Indexed Access Types ---

// Access the type of a specific property
interface Project {
    id: string;
    name: string;
    tasks: Task[];
}

type ProjectIdType = Project['id']; // string
type TasksType = Project['tasks']; // Task[]

// Access nested properties
type TaskType = Project['tasks'][0]; // Task (first element of array)

// Using union types for property lookup
type ProjectKeys = keyof Project; // 'id' | 'name' | 'tasks'
type ProjectValueTypes = Project[ProjectKeys]; // string | Task[]

// --- Indexed Access with Generic Types ---

function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

const project: Project = {
    id: 'p1',
    name: 'TaskFlow',
    tasks: []
};

const projectId = getProperty(project, 'id'); // string
const projectName = getProperty(project, 'name'); // string

// --- Template Literal Types ---

type ApiEndpoint = `/api/${string}`;

// String manipulation types
type UserPermissions = 'read' | 'write' | 'delete';
type PermissionString = `${UserPermissions}:${string}`;

const readPermission: PermissionString = 'read:document';
const writePermission: PermissionString = 'write:document';
// const invalid: PermissionString = 'unknown:document'; // ❌ Error

// --- Building URL Types ---

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';

type ApiRoute<Method extends HttpMethod, Path extends string> = 
    `${Method} /${Path}`;

type GetTasksRoute = ApiRoute<'GET', 'api/tasks'>; // "GET /api/tasks"
type CreateTaskRoute = ApiRoute<'POST', 'api/tasks'>; // "POST /api/tasks"

// --- Transforming String Literals ---

type ToCamelCase<S extends string> = 
    S extends `${infer First}_${infer Rest}` 
        ? `${Lowercase<First>}${Capitalize<ToCamelCase<Rest>>}` 
        : Lowercase<S>;

type CamelCaseTest = ToCamelCase<'user_first_name'>; // "userFirstName"
type CamelCaseTest2 = ToCamelCase<'project_task_status'>; // "projectTaskStatus"

// --- Practical: Type-safe URL Builder ---

type UrlParams = Record<string, string | number | boolean>;

function buildUrl<T extends string>(
    path: T,
    params?: Record<string, string>
): string {
    if (!params) return path;
    
    const queryString = Object.entries(params)
        .map(([key, value]) => `${key}=${encodeURIComponent(value)}`)
        .join('&');
    
    return `${path}?${queryString}`;
}

// Type-safe endpoint definitions
const API = {
    tasks: {
        list: '/api/tasks' as const,
        detail: '/api/tasks/:id' as const,
        create: '/api/tasks' as const
    }
};

// --- Combining Indexed Access and Template Literals ---

type ApiPathParams<T extends string> = 
    T extends `${string}:${infer Param}/${infer Rest}`
        ? { [K in Param | keyof ApiPathParams<Rest>]: string }
        : T extends `${string}:${infer Param}`
            ? { [K in Param]: string }
            : {};

type TaskDetailParams = ApiPathParams<'/api/tasks/:id'>; // { id: string }

// Generic function to replace path parameters
function interpolatePath<T extends string>(
    path: T,
    params: ApiPathParams<T>
): string {
    let result = path as string;
    for (const [key, value] of Object.entries(params)) {
        result = result.replace(`:${key}`, String(value));
    }
    return result;
}

// Usage
const taskPath = interpolatePath('/api/tasks/:id', { id: 'task_123' });
console.log('Interpolated path:', taskPath); // "/api/tasks/task_123"

// --- Verification ---

console.log('\n=== Advanced Types Demo ===\n');

function testAdvancedTypes() {
    // Indexed access example
    const project: Project = {
        id: 'p1',
        name: 'Test Project',
        tasks: [
            { id: 't1', title: 'Task 1', status: 'todo', priority: 'high', 
              projectId: 'p1', createdBy: 'u1', tags: [], createdAt: new Date(), updatedAt: new Date() }
        ]
    };
    
    const task = getProperty(project, 'tasks')[0];
    console.log('Task from project:', task?.title);
    
    // Template literal examples
    const endpoint: ApiEndpoint = '/api/tasks';
    console.log('API endpoint:', endpoint);
    
    const permission: PermissionString = 'read:project_1';
    console.log('Permission:', permission);
    
    const route: GetTasksRoute = 'GET /api/tasks';
    console.log('Route:', route);
    
    // URL builder
    const url = buildUrl('/api/tasks', { status: 'active', page: '1' });
    console.log('Built URL:', url);
    
    // Interpolated path
    console.log('Interpolated path:', taskPath);
}

testAdvancedTypes();
```

## 3.5 The `infer` Keyword

The `infer` keyword allows you to extract type information from other types.

### The Concept: Pattern Matching for Types

`infer` is like destructuring for types—it lets you pull out specific parts of a type.

**File:** `src/types/infer.ts`

```typescript
/**
 * The infer Keyword: Extracting Types from Other Types
 */

// --- Basic Usage: Extracting Array Elements ---

// Extract the element type from an array
type ArrayElementType<T> = T extends (infer U)[] ? U : never;

type NumberArrayType = ArrayElementType<number[]>; // number
type StringArrayType = ArrayElementType<string[]>; // string
type MixedArrayType = ArrayElementType<(string | number)[]>; // string | number

// --- Extracting Return Types ---

// Similar to ReturnType<T>
type MyReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

function getTask(id: string): { id: string; title: string } {
    return { id, title: 'Task' };
}

type TaskResult = MyReturnType<typeof getTask>; // { id: string; title: string }

// --- Extracting Function Parameters ---

type MyParameters<T> = T extends (...args: infer P) => any ? P : never;

type GetTaskParams = MyParameters<typeof getTask>; // [string]

// --- Extracting Promise Values ---

type Awaited<T> = T extends Promise<infer U> ? U : T;

type PromiseTask = Promise<{ id: string; title: string }>;
type ResolvedTask = Awaited<PromiseTask>; // { id: string; title: string }

// --- Complex: Extracting from Object Keys ---

type ExtractKeysWithType<T, U> = {
    [K in keyof T]: T[K] extends U ? K : never;
}[keyof T];

interface Blog {
    id: string;
    title: string;
    views: number;
    likes: number;
    published: boolean;
}

type StringKeys = ExtractKeysWithType<Blog, string>; // 'id' | 'title'
type NumberKeys = ExtractKeysWithType<Blog, number>; // 'views' | 'likes'

// --- Practical: Type-safe Event System ---

type EventHandler<T> = (data: T) => void;

// Extract the event data type from a handler
type EventDataFromHandler<T> = T extends EventHandler<infer U> ? U : never;

type ClickHandler = EventHandler<{ x: number; y: number }>;
type KeyHandler = EventHandler<{ key: string }>;

type ClickData = EventDataFromHandler<ClickHandler>; // { x: number; y: number }
type KeyData = EventDataFromHandler<KeyHandler>; // { key: string }

// --- Pattern Matching with Recursive Types ---

// Extract the deepest nested type
type DeepestType<T> = 
    T extends (infer U)[] ? DeepestType<U> :
    T extends Record<string, any> ? DeepestType<T[keyof T]> :
    T;

type NestedArray = number[][][];
type Deepest = DeepestType<NestedArray>; // number

// --- Getting the First and Last of a Tuple ---

type First<T extends any[]> = T extends [infer First, ...any[]] ? First : never;
type Last<T extends any[]> = T extends [...any[], infer Last] ? Last : never;

type Tuple = [string, number, boolean];
type FirstElement = First<Tuple>; // string
type LastElement = Last<Tuple>; // boolean

// --- Extracting Function Overloads ---

function overloaded(value: string): string;
function overloaded(value: number): number;
function overloaded(value: any): any {
    return value;
}

// Get the overloaded return type for a specific parameter
type OverloadReturn<T, P> = 
    T extends { (...args: infer A): infer R; } 
        ? P extends A[0] ? R : never 
        : never;

// --- Verification ---

console.log('\n=== Infer Keyword Demo ===\n');

function testInfer() {
    // Test array element extraction
    const numbers: number[] = [1, 2, 3];
    const firstNumber: ArrayElementType<typeof numbers> = numbers[0];
    console.log('First number:', firstNumber);
    
    // Test return type extraction
    const result = getTask('task_1');
    const title: TaskResult['title'] = result.title;
    console.log('Task title:', title);
    
    // Test event system
    const clickHandler: ClickHandler = (data) => {
        console.log(`Clicked at (${data.x}, ${data.y})`);
    };
    clickHandler({ x: 100, y: 200 });
    
    // Test tuple extraction
    const tuple: Tuple = ['hello', 42, true];
    const first: First<Tuple> = tuple[0];
    const last: Last<Tuple> = tuple[tuple.length - 1];
    console.log('First element:', first);
    console.log('Last element:', last);
    
    // Test overloads
    const stringResult = overloaded('test');
    const numberResult = overloaded(42);
    console.log('Overload test:', stringResult, numberResult);
}

testInfer();
```

## 3.6 Practical Application: Type-Safe Form Validation

Now we'll build a complete form validation system that combines everything we've learned.

**File:** `src/validation/validator.ts`

```typescript
/**
 * Type-Safe Form Validation System
 * Using advanced TypeScript features for robust runtime validation
 */

// --- Core Types ---

// Validation result types
type ValidationResult<T> = 
    | { valid: true; value: T }
    | { valid: false; errors: string[] };

// Validator function type
type Validator<T> = (value: unknown) => ValidationResult<T>;

// --- Built-in Validators ---

// String validators
const isString: Validator<string> = (value): ValidationResult<string> => {
    if (typeof value !== 'string') {
        return { valid: false, errors: ['Value must be a string'] };
    }
    return { valid: true, value };
};

const minLength = (min: number): Validator<string> => 
    (value): ValidationResult<string> => {
        const result = isString(value);
        if (!result.valid) return result;
        
        if (result.value.length < min) {
            return { valid: false, errors: [`Must be at least ${min} characters`] };
        }
        return { valid: true, value: result.value };
    };

const maxLength = (max: number): Validator<string> => 
    (value): ValidationResult<string> => {
        const result = isString(value);
        if (!result.valid) return result;
        
        if (result.value.length > max) {
            return { valid: false, errors: [`Must be at most ${max} characters`] };
        }
        return { valid: true, value: result.value };
    };

// Email validator
const isEmail: Validator<string> = (value): ValidationResult<string> => {
    const result = isString(value);
    if (!result.valid) return result;
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(result.value)) {
        return { valid: false, errors: ['Must be a valid email address'] };
    }
    return { valid: true, value: result.value };
};

// Number validators
const isNumber: Validator<number> = (value): ValidationResult<number> => {
    if (typeof value !== 'number' || isNaN(value)) {
        return { valid: false, errors: ['Must be a number'] };
    }
    return { valid: true, value };
};

const minNumber = (min: number): Validator<number> => 
    (value): ValidationResult<number> => {
        const result = isNumber(value);
        if (!result.valid) return result;
        
        if (result.value < min) {
            return { valid: false, errors: [`Must be at least ${min}`] };
        }
        return { valid: true, value: result.value };
    };

// Boolean validator
const isBoolean: Validator<boolean> = (value): ValidationResult<boolean> => {
    if (typeof value !== 'boolean') {
        return { valid: false, errors: ['Must be a boolean'] };
    }
    return { valid: true, value };
};

// Object validator with type inference
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

// Union type validator
function unionValidator<T extends Validator<any>[]>(
    ...validators: T
): Validator<T[number] extends Validator<infer U> ? U : never> {
    return (value): any => {
        for (const validator of validators) {
            const result = validator(value);
            if (result.valid) {
                return result;
            }
        }
        return { valid: false, errors: ['Value does not match any allowed type'] };
    };
}

// Optional validator
function optionalValidator<T>(
    validator: Validator<T>
): Validator<T | undefined> {
    return (value): ValidationResult<T | undefined> => {
        if (value === undefined || value === null) {
            return { valid: true, value: undefined };
        }
        return validator(value);
    };
}

// --- TaskFlow Form Validators ---

// Task form validation
type TaskFormData = {
    title: string;
    description?: string;
    priority: 'low' | 'medium' | 'high' | 'urgent';
    status: 'todo' | 'in-progress' | 'review' | 'done';
    dueDate?: Date;
};

const priorityValidator: Validator<TaskFormData['priority']> = (value): any => {
    const result = isString(value);
    if (!result.valid) return result;
    
    const priorities = ['low', 'medium', 'high', 'urgent'] as const;
    if (!priorities.includes(result.value as any)) {
        return { valid: false, errors: ['Invalid priority'] };
    }
    return { valid: true, value: result.value as TaskFormData['priority'] };
};

const statusValidator: Validator<TaskFormData['status']> = (value): any => {
    const result = isString(value);
    if (!result.valid) return result;
    
    const statuses = ['todo', 'in-progress', 'review', 'done'] as const;
    if (!statuses.includes(result.value as any)) {
        return { valid: false, errors: ['Invalid status'] };
    }
    return { valid: true, value: result.value as TaskFormData['status'] };
};

const dateValidator: Validator<Date> = (value): ValidationResult<Date> => {
    if (value instanceof Date && !isNaN(value.getTime())) {
        return { valid: true, value };
    }
    return { valid: false, errors: ['Must be a valid date'] };
};

// Create the full task form validator
const taskFormValidator = objectValidator<TaskFormData>({
    title: minLength(3)(maxLength(100)),
    description: optionalValidator(minLength(0)(maxLength(500))),
    priority: priorityValidator,
    status: statusValidator,
    dueDate: optionalValidator(dateValidator)
});

// User registration form validator
type RegistrationFormData = {
    email: string;
    password: string;
    confirmPassword: string;
    age?: number;
    termsAccepted: boolean;
};

const registrationValidator = objectValidator<RegistrationFormData>({
    email: isEmail,
    password: minLength(8)(maxLength(64)),
    confirmPassword: (value): ValidationResult<string> => {
        const result = minLength(8)(maxLength(64))(value);
        if (!result.valid) return result;
        return result;
    },
    age: optionalValidator(minNumber(13)),
    termsAccepted: isBoolean
});

// --- Validation Helper Functions ---

function validate<T>(
    validator: Validator<T>,
    data: unknown
): ValidationResult<T> {
    return validator(data);
}

function getFirstError<T>(result: ValidationResult<T>): string | undefined {
    if (result.valid) return undefined;
    return result.errors[0];
}

function formatErrors(result: ValidationResult<any>): string {
    if (result.valid) return 'Validation passed';
    return `Validation failed:\n${result.errors.map(e => `  - ${e}`).join('\n')}`;
}

// --- Type-safe Form Validation Function ---

type FormErrors<T> = {
    [K in keyof T]?: string[];
};

function validateForm<T>(
    validator: Validator<T>,
    formData: unknown
): { isValid: true; data: T } | { isValid: false; errors: FormErrors<T> } {
    const result = validator(formData);
    
    if (result.valid) {
        return { isValid: true, data: result.value };
    }
    
    // Parse errors into field-specific format
    const errors: FormErrors<T> = {};
    for (const error of result.errors) {
        const [field, ...messageParts] = error.split(': ');
        const message = messageParts.join(': ');
        if (field) {
            if (!errors[field as keyof T]) {
                errors[field as keyof T] = [];
            }
            errors[field as keyof T]!.push(message);
        }
    }
    
    return { isValid: false, errors };
}

// --- Verification ---

console.log('\n=== Form Validation Demo ===\n');

function testValidation() {
    // Test valid task
    const validTask = {
        title: 'Write documentation',
        priority: 'high',
        status: 'todo',
        dueDate: new Date('2026-02-01')
    };
    
    console.log('Testing valid task:');
    const taskResult = validateForm(taskFormValidator, validTask);
    if (taskResult.isValid) {
        console.log('✅ Task validation passed');
        console.log('  Title:', taskResult.data.title);
        console.log('  Priority:', taskResult.data.priority);
        console.log('  Status:', taskResult.data.status);
    }
    
    // Test invalid task
    const invalidTask = {
        title: 'Hi', // Too short
        priority: 'super-high', // Invalid priority
        status: 'unknown', // Invalid status
    };
    
    console.log('\nTesting invalid task:');
    const invalidResult = validateForm(taskFormValidator, invalidTask);
    if (!invalidResult.isValid) {
        console.log('❌ Validation failed:');
        for (const [field, errors] of Object.entries(invalidResult.errors)) {
            console.log(`  ${field}: ${errors.join(', ')}`);
        }
    }
    
    // Test registration
    console.log('\nTesting registration form:');
    const validRegistration = {
        email: 'user@example.com',
        password: 'securepassword123',
        confirmPassword: 'securepassword123',
        age: 25,
        termsAccepted: true
    };
    
    const regResult = validateForm(registrationValidator, validRegistration);
    if (regResult.isValid) {
        console.log('✅ Registration validated:', regResult.data.email);
    }
    
    // Test invalid registration
    const invalidRegistration = {
        email: 'not-an-email',
        password: 'short',
        confirmPassword: 'different',
        age: 12,
        termsAccepted: 'yes' // Should be boolean
    };
    
    const invalidRegResult = validateForm(registrationValidator, invalidRegistration);
    if (!invalidRegResult.isValid) {
        console.log('❌ Registration validation failed:');
        for (const [field, errors] of Object.entries(invalidRegResult.errors)) {
            console.log(`  ${field}: ${errors.join(', ')}`);
        }
    }
}

testValidation();
```

## 3.7 Summary: Part 3

You've completed Part 3! Here's what you've learned:

### Conditional Types
- Choose between types based on conditions
- Use `extends` to test type relationships
- Leverage conditional types for type-level logic

### Mapped Types
- Transform object types by iterating over properties
- Filter properties based on their types
- Add, remove, or modify property modifiers
- Combine with conditional types for powerful transformations

### Indexed Access Types
- Access property types using bracket notation
- Use with generics for type-safe property access
- Combine with union types for flexible lookups

### Template Literal Types
- Build string types using template syntax
- Create type-safe string manipulations
- Build URL patterns and API route definitions

### The `infer` Keyword
- Extract types from complex type structures
- Use pattern matching for type extraction
- Build recursive type transformations

### Practical Application
- Built a complete form validation system
- Combined all advanced TypeScript features
- Created type-safe validators
- Implemented field-specific error reporting

### What's Next: Preview of Part 4

In Part 4, we'll apply all our TypeScript knowledge to React:
- Typing React components and props
- State management with type safety
- Custom hooks with generics
- Context with type-safe providers
- Event handlers and forms
- **Practical Application:** Build TaskFlow's React frontend

## Verification Checklist

Before moving to Part 4, ensure:

- [ ] `npm run build` compiles without errors
- [ ] Understanding of conditional types and when to use them
- [ ] Ability to create custom mapped types
- [ ] Familiarity with the `infer` keyword
- [ ] Form validation system works correctly
- [ ] All advanced types are used in TaskFlow codebase

*Ready to apply TypeScript to React? Proceed to Part 4 where we'll build a type-safe React frontend for TaskFlow, with fully typed components, hooks, state management, and forms!*
