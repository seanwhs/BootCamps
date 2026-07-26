# TypeScript Master Series: Appendix B

## Common TypeScript Errors & Solutions

---

# Table of Contents

1. **Error Categories Overview**
2. **Type System Errors**
3. **Module & Import Errors**
4. **Function & Class Errors**
5. **Generic Errors**
6. **React & JSX Errors**
7. **Next.js Errors**
8. **Configuration Errors**
9. **Runtime vs Compile-Time Errors**
10. **Debugging Strategies**

---

# 1. Error Categories Overview

## Error Severity Levels

| Level | Description | Impact |
|-------|-------------|--------|
| **Error** | Prevents compilation | Code won't build |
| **Warning** | Potential issue | Code builds but may have issues |
| **Suggestion** | Improvement opportunity | Code builds, optional fix |

## Error Types by Category

| Category | Common Errors | Difficulty |
|----------|---------------|------------|
| **Type System** | TS2322, TS2339, TS2345 | Medium |
| **Module** | TS2307, TS2724, TS2614 | Medium |
| **Function/Class** | TS7006, TS2554, TS7030 | Easy |
| **Generics** | TS2314, TS2322 | Hard |
| **React/JSX** | TS17002, TS2786 | Medium |
| **Next.js** | Server/Client component errors | Medium |
| **Configuration** | TS5023, TS5055 | Easy |

---

# 2. Type System Errors

## TS2322: Type 'X' is not assignable to type 'Y'

### Description
You're trying to assign a value of one type to a variable, parameter, or property that expects a different type.

### Common Causes
- Assigning wrong type to a variable
- Function parameter type mismatch
- Object property type mismatch
- Array element type mismatch

### Examples

```typescript
// ❌ Error: Type 'string' is not assignable to type 'number'
let count: number = "42";

// ❌ Error: Type 'number' is not assignable to type 'string'
function greet(name: string) { ... }
greet(42);

// ❌ Error: Type 'string' is not assignable to type 'number'
interface User {
    id: number;
}
const user: User = { id: "123" };

// ❌ Error: Type 'string' is not assignable to type 'number'
const numbers: number[] = ["1", "2", "3"];
```

### Solutions

```typescript
// ✅ Solution 1: Correct the assignment
let count: number = 42;

// ✅ Solution 2: Type conversion
function greet(name: string) { ... }
greet(String(42));
// or
greet("42");

// ✅ Solution 3: Update the type
interface User {
    id: string;
}
const user: User = { id: "123" };

// ✅ Solution 4: Type assertion (use cautiously)
const numbers = ["1", "2", "3"] as number[]; // ⚠️ Dangerous!

// ✅ Solution 5: Use a type guard
function isString(value: any): value is string {
    return typeof value === 'string';
}
```

## TS2339: Property 'X' does not exist on type 'Y'

### Description
You're trying to access a property that TypeScript doesn't recognize on a type.

### Common Causes
- Typo in property name
- Property doesn't exist on the type
- Type is narrowed incorrectly
- Missing optional property
- Using an object that's been unioned with another type

### Examples

```typescript
// ❌ Error: Property 'age' does not exist on type 'User'
interface User {
    name: string;
}
const user: User = { name: "Alice" };
console.log(user.age);

// ❌ Error: Property 'toUpperCase' does not exist on type 'number'
function process(value: string | number) {
    return value.toUpperCase(); // Error on number
}

// ❌ Error: Property 'id' does not exist on type 'unknown'
const data: unknown = JSON.parse('{"id": "123"}');
console.log(data.id);
```

### Solutions

```typescript
// ✅ Solution 1: Add the property to the type
interface User {
    name: string;
    age: number;
}
const user: User = { name: "Alice", age: 30 };

// ✅ Solution 2: Use type narrowing
function process(value: string | number) {
    if (typeof value === 'string') {
        return value.toUpperCase();
    }
    return value.toString();
}

// ✅ Solution 3: Type guard
function hasId(obj: any): obj is { id: string } {
    return obj && typeof obj.id === 'string';
}

// ✅ Solution 4: Optional chaining
console.log(user?.age); // Returns undefined if age doesn't exist

// ✅ Solution 5: Type assertion
const data = JSON.parse('{"id": "123"}') as { id: string };
console.log(data.id);
```

## TS2345: Argument of type 'X' is not assignable to parameter of type 'Y'

### Description
You're passing an argument of the wrong type to a function or constructor.

### Common Causes
- Function expects different type
- Callback type mismatch
- Generic type mismatch
- Passing wrong object shape

### Examples

```typescript
// ❌ Error: Argument of type 'number' is not assignable to parameter of type 'string'
function repeat(str: string, times: number): string {
    return str.repeat(times);
}
repeat(42, 3);

// ❌ Error: Argument of type 'User' is not assignable to parameter of type 'Admin'
interface User { name: string; }
interface Admin extends User { role: 'admin'; }

function checkAdmin(admin: Admin) { ... }
const user: User = { name: "Alice" };
checkAdmin(user);

// ❌ Error: Type 'string' is not assignable to type 'number[]'
function sum(numbers: number[]): number {
    return numbers.reduce((a, b) => a + b, 0);
}
sum("1,2,3");
```

### Solutions

```typescript
// ✅ Solution 1: Correct the argument type
repeat("42", 3);

// ✅ Solution 2: Use type assertion
checkAdmin(user as Admin);

// ✅ Solution 3: Convert the value
const numbers = "1,2,3".split(',').map(Number);
sum(numbers);

// ✅ Solution 4: Update function signature
function repeat(str: string | number, times: number): string {
    return String(str).repeat(times);
}

// ✅ Solution 5: Use a type guard
function isAdmin(user: User): user is Admin {
    return (user as Admin).role === 'admin';
}
```

## TS2531: Object is possibly 'null' or 'undefined'

### Description
You're trying to access a property on a value that might be null or undefined.

### Common Causes
- Accessing property on optional value
- DOM element might not exist
- API response might be incomplete
- Array access might be out of bounds

### Examples

```typescript
// ❌ Error: Object is possibly 'null'
const element = document.getElementById('app');
element.innerHTML = 'Hello';

// ❌ Error: Object is possibly 'undefined'
interface User {
    name?: string;
}
const user: User = {};
console.log(user.name.toUpperCase());

// ❌ Error: Object is possibly 'undefined'
const numbers = [1, 2, 3];
console.log(numbers[3].toString());
```

### Solutions

```typescript
// ✅ Solution 1: Use optional chaining
const element = document.getElementById('app');
element?.innerHTML = 'Hello';

// ✅ Solution 2: Check for null/undefined
if (element) {
    element.innerHTML = 'Hello';
}

// ✅ Solution 3: Use nullish coalescing
console.log(user.name?.toUpperCase() ?? 'No name');

// ✅ Solution 4: Use non-null assertion (careful!)
element!.innerHTML = 'Hello'; // Only if you're sure it exists

// ✅ Solution 5: Use a type guard
function isUser(value: any): value is { name: string } {
    return value && typeof value.name === 'string';
}
```

## TS2454: Variable 'X' is used before being assigned

### Description
You're using a variable that hasn't been assigned a value yet.

### Common Causes
- Variable declared but not initialized
- Variable only assigned in some code paths
- Missing initial value
- Complex control flow

### Examples

```typescript
// ❌ Error: Variable 'x' is used before being assigned
let x: number;
console.log(x);

// ❌ Error: Variable 'result' is used before being assigned
let result: string;
if (condition) {
    result = 'Hello';
}
console.log(result); // Error if condition is false

// ❌ Error: Variable 'task' is used before being assigned
let task: Task;
if (getTask()) {
    task = getTask();
}
console.log(task.title);
```

### Solutions

```typescript
// ✅ Solution 1: Initialize when declaring
let x: number = 0;
console.log(x);

// ✅ Solution 2: Ensure all code paths assign
let result: string;
if (condition) {
    result = 'Hello';
} else {
    result = 'World';
}
console.log(result);

// ✅ Solution 3: Initialize with default
let task: Task | null = null;
if (getTask()) {
    task = getTask();
}
console.log(task?.title ?? 'No task');

// ✅ Solution 4: Use definite assignment assertion
let task!: Task; // Tells TypeScript it will be assigned
// ... assign it later
console.log(task.title);
```

---

# 3. Module & Import Errors

## TS2307: Cannot find module 'X' or its corresponding type declarations

### Description
TypeScript can't find a module you're trying to import.

### Common Causes
- Module not installed
- Incorrect path
- Missing type definitions
- Module not exported properly

### Examples

```typescript
// ❌ Error: Cannot find module 'lodash'
import _ from 'lodash';

// ❌ Error: Cannot find module './utils'
import { formatDate } from './utils';

// ❌ Error: Cannot find module '@components/Button'
import Button from '@/components/Button';
```

### Solutions

```typescript
// ✅ Solution 1: Install the module
npm install lodash
npm install --save-dev @types/lodash

// ✅ Solution 2: Check the path
import { formatDate } from './utils.js'; // Include .js extension

// ✅ Solution 3: Create a type declaration
// In a .d.ts file:
declare module 'my-module' {
    export function myFunction(): void;
}

// ✅ Solution 4: Use require (if needed)
const _ = require('lodash');

// ✅ Solution 5: Configure path aliases
// In tsconfig.json:
{
    "compilerOptions": {
        "paths": {
            "@/*": ["./src/*"],
            "@components/*": ["./src/components/*"]
        }
    }
}
```

## TS2724: Module 'X' has no exported member 'Y'

### Description
You're trying to import a member that doesn't exist in the module.

### Common Causes
- Member not exported
- Typo in member name
- Wrong import syntax
- Default vs named import confusion

### Examples

```typescript
// ❌ Error: Module './utils' has no exported member 'formatDate'
import { formatDate } from './utils';

// ❌ Error: Module 'react' has no exported member 'ComponentX'
import { ComponentX } from 'react';

// ❌ Error: Module 'lodash' has no exported member 'capitalize'
import { capitalize } from 'lodash';
```

### Solutions

```typescript
// ✅ Solution 1: Check if member is exported
// In utils.ts:
export function formatDate(date: Date): string { ... }

// ✅ Solution 2: Use correct import syntax
import * as React from 'react';
// or
import React from 'react';

// ✅ Solution 3: Check member name
// lodash has _.capitalize, not capitalize
import { capitalize } from 'lodash-es'; // Or
import _ from 'lodash'; // _.capitalize()

// ✅ Solution 4: Create a type declaration
declare module './utils' {
    export function formatDate(date: Date): string;
}
```

## TS7016: Could not find a declaration file for module 'X'

### Description
TypeScript can't find type definitions for a JavaScript module.

### Common Causes
- Using a JavaScript module without types
- Types not installed
- Module doesn't include types
- TypeScript can't locate types

### Examples

```typescript
// ❌ Error: Could not find declaration file for module 'my-package'
import { something } from 'my-package';

// ❌ Error: Could not find declaration file for module '@my/package'
import { something } from '@my/package';
```

### Solutions

```typescript
// ✅ Solution 1: Install type definitions
npm install --save-dev @types/my-package

// ✅ Solution 2: Create a declaration file
// In src/types/my-package.d.ts:
declare module 'my-package' {
    export function something(): void;
}

// ✅ Solution 3: Use a triple-slash reference
/// <reference path="./my-package.d.ts" />

// ✅ Solution 4: Skip type checking
// In tsconfig.json:
{
    "compilerOptions": {
        "skipLibCheck": true
    }
}
```

---

# 4. Function & Class Errors

## TS7006: Parameter 'X' implicitly has 'any' type

### Description
A function parameter doesn't have a type annotation, and TypeScript can't infer its type.

### Common Causes
- Missing type annotation on parameter
- Function is a callback with no types
- TypeScript can't infer the type

### Examples

```typescript
// ❌ Error: Parameter 'x' implicitly has 'any' type
function add(x, y) {
    return x + y;
}

// ❌ Error: Parameter 'item' implicitly has 'any' type
const result = items.map(item => item * 2);

// ❌ Error: Parameter 'callback' implicitly has 'any' type
function execute(callback) {
    callback();
}
```

### Solutions

```typescript
// ✅ Solution 1: Add explicit type annotations
function add(x: number, y: number): number {
    return x + y;
}

// ✅ Solution 2: Use a type guard
const result = items.map((item: number) => item * 2);

// ✅ Solution 3: Define callback type
function execute(callback: () => void): void {
    callback();
}

// ✅ Solution 4: Use noImplicitAny in tsconfig.json
{
    "compilerOptions": {
        "noImplicitAny": true  // Already default with strict: true
    }
}

// ✅ Solution 5: Use any (not recommended)
function execute(callback: any) { ... }
```

## TS2554: Expected X arguments, but got Y

### Description
You're calling a function with the wrong number of arguments.

### Common Causes
- Missing required arguments
- Extra arguments passed
- Function signature changed
- Optional vs required parameters

### Examples

```typescript
// ❌ Error: Expected 2 arguments, but got 1
function greet(name: string, greeting: string): string {
    return `${greeting}, ${name}`;
}
greet('Alice');

// ❌ Error: Expected 1 argument, but got 2
function log(message: string): void {
    console.log(message);
}
log('Hello', 'World');

// ❌ Error: Expected at least 1 argument, but got 0
function repeat(str: string, times: number = 3): string {
    return str.repeat(times);
}
repeat();
```

### Solutions

```typescript
// ✅ Solution 1: Make the parameter optional
function greet(name: string, greeting?: string): string {
    if (greeting) {
        return `${greeting}, ${name}`;
    }
    return `Hello, ${name}`;
}
greet('Alice');

// ✅ Solution 2: Use default value
function greet(name: string, greeting: string = 'Hello'): string {
    return `${greeting}, ${name}`;
}
greet('Alice');

// ✅ Solution 3: Use rest parameters
function log(...messages: string[]): void {
    console.log(messages.join(' '));
}
log('Hello', 'World');

// ✅ Solution 4: Use an object parameter
function greet(options: { name: string; greeting?: string }): string {
    const greeting = options.greeting || 'Hello';
    return `${greeting}, ${options.name}`;
}
greet({ name: 'Alice' });
```

## TS7030: Not all code paths return a value

### Description
A function doesn't return a value in all possible execution paths.

### Common Causes
- Missing return statement in some branches
- Conditional logic missing a return
- Infinite loop detection
- Missing default return

### Examples

```typescript
// ❌ Error: Not all code paths return a value
function getValue(flag: boolean): string {
    if (flag) {
        return 'Yes';
    }
    // No return for false case
}

// ❌ Error: Not all code paths return a value
function process(value: string | number): string {
    if (typeof value === 'string') {
        return value.toUpperCase();
    }
    // Missing return for number
}

// ❌ Error: Not all code paths return a value
function findUser(id: string): User {
    const user = users.find(u => u.id === id);
    if (user) {
        return user;
    }
    // No return if user not found
}
```

### Solutions

```typescript
// ✅ Solution 1: Add return for all branches
function getValue(flag: boolean): string {
    if (flag) {
        return 'Yes';
    }
    return 'No';
}

// ✅ Solution 2: Use throw for invalid paths
function process(value: string | number): string {
    if (typeof value === 'string') {
        return value.toUpperCase();
    }
    throw new Error('Invalid type');
}

// ✅ Solution 3: Return default value
function findUser(id: string): User | null {
    const user = users.find(u => u.id === id);
    return user || null;
}

// ✅ Solution 4: Use never for unreachable code
function assertNever(value: never): never {
    throw new Error(`Unexpected value: ${value}`);
}
```

## TS2339 (Class): Property 'X' does not exist on type 'Y'

### Description
Trying to access a property or method that doesn't exist on a class.

### Common Causes
- Property not declared
- Access modifier issue
- Missing inheritance
- Typo in method name

### Examples

```typescript
// ❌ Error: Property 'email' does not exist on type 'User'
class User {
    name: string;
}
const user = new User();
user.email = 'alice@example.com';

// ❌ Error: Method 'greet' does not exist on type 'User'
class User {
    constructor(public name: string) {}
}
const user = new User('Alice');
user.greet();
```

### Solutions

```typescript
// ✅ Solution 1: Declare the property
class User {
    name: string;
    email: string;
    constructor(name: string, email: string) {
        this.name = name;
        this.email = email;
    }
}

// ✅ Solution 2: Use property shorthand
class User {
    constructor(public name: string, public email: string) {}
}

// ✅ Solution 3: Add the method
class User {
    constructor(public name: string) {}
    
    greet(): string {
        return `Hello, ${this.name}`;
    }
}

// ✅ Solution 4: Use index signature for dynamic properties
class User {
    name: string;
    [key: string]: any;
}
const user = new User();
user.email = 'alice@example.com';
```

---

# 5. Generic Errors

## TS2314: Generic type 'X' requires Y type argument(s)

### Description
You're using a generic type without providing all required type arguments.

### Common Causes
- Missing type parameters
- Generic constraint missing
- Incorrect number of type arguments

### Examples

```typescript
// ❌ Error: Generic type 'Box<T>' requires 1 type argument(s)
class Box<T> {
    contents: T;
}
const box: Box = { contents: 'hello' };

// ❌ Error: Generic type 'Pair<T, U>' requires 2 type arguments
interface Pair<T, U> {
    first: T;
    second: U;
}
const pair: Pair = { first: 1, second: 'a' };

// ❌ Error: Generic type 'Repository<T>' requires 1 type argument(s)
class Repository<T extends Entity> { ... }
const repo: Repository = new Repository();
```

### Solutions

```typescript
// ✅ Solution 1: Provide the type argument
const box: Box<string> = { contents: 'hello' };
// Or
const box = new Box<string>('hello');

// ✅ Solution 2: Let TypeScript infer the type
const box = { contents: 'hello' }; // Box<string> inferred

// ✅ Solution 3: Provide all type arguments
const pair: Pair<number, string> = { first: 1, second: 'a' };

// ✅ Solution 4: Use default type arguments
class Box<T = string> {
    contents: T;
}
const box: Box = { contents: 'hello' }; // Box<string>

// ✅ Solution 5: Provide entity type
class Repository<T extends Entity> { ... }
const repo = new Repository<Entity>();
```

## TS2322 (Generic): Type 'X' does not satisfy the constraint 'Y'

### Description
A generic type doesn't satisfy the constraint placed on it.

### Common Causes
- Missing required properties
- Incorrect type used
- Constraint not met
- Type doesn't extend required type

### Examples

```typescript
// ❌ Error: Type 'number' does not satisfy the constraint '{ id: string }'
function getItem<T extends { id: string }>(item: T): string {
    return item.id;
}
getItem<number>(42);

// ❌ Error: Type 'User' does not satisfy the constraint 'Entity'
interface Entity {
    id: string;
}
interface User {
    name: string;
}
class Repository<T extends Entity> { ... }
const repo = new Repository<User>(); // Error

// ❌ Error: Type 'string' does not satisfy the constraint '() => void'
function execute<T extends () => void>(fn: T) {
    fn();
}
execute<string>('hello');
```

### Solutions

```typescript
// ✅ Solution 1: Use a type that satisfies the constraint
const item = { id: '123', name: 'test' };
getItem(item);

// ✅ Solution 2: Make User extend Entity
interface Entity {
    id: string;
}
interface User extends Entity {
    name: string;
}
const repo = new Repository<User>();

// ✅ Solution 3: Add missing properties
const item = { id: '123', name: 'test' };
getItem(item);

// ✅ Solution 4: Use type assertion (careful!)
getItem(42 as any); // ⚠️ Dangerous

// ✅ Solution 5: Adjust the constraint
function getItem<T extends { id: string | number }>(item: T): string {
    return String(item.id);
}
```

---

# 6. React & JSX Errors

## TS17002: JSX element implicitly has type 'any'

### Description
TypeScript can't determine the type of a JSX element.

### Common Causes
- Missing type definitions for React
- Incorrect import
- Component not properly typed

### Examples

```typescript
// ❌ Error: JSX element implicitly has type 'any'
const MyComponent = () => {
    return <div>Hello</div>;
};

// ❌ Error: JSX element implicitly has type 'any'
import { MyComponent } from './MyComponent';
const element = <MyComponent />;
```

### Solutions

```typescript
// ✅ Solution 1: Install React types
npm install --save-dev @types/react @types/react-dom

// ✅ Solution 2: Type the component
const MyComponent: React.FC = () => {
    return <div>Hello</div>;
};

// ✅ Solution 3: Use explicit type
const MyComponent = (): JSX.Element => {
    return <div>Hello</div>;
};

// ✅ Solution 4: Check tsconfig.json
{
    "compilerOptions": {
        "jsx": "react-jsx" // or "react"
    }
}
```

## TS2786: 'X' cannot be used as a JSX component

### Description
A value that's not a valid React component is being used as a JSX component.

### Common Causes
- Component not exported correctly
- Function returns invalid type
- Missing React import
- Component returns null

### Examples

```typescript
// ❌ Error: 'MyComponent' cannot be used as a JSX component
function MyComponent() {
    return "Hello"; // String not valid JSX
}

// ❌ Error: 'MyComponent' cannot be used as a JSX component
const MyComponent = 42;

// ❌ Error: 'MyComponent' cannot be used as a JSX component
function MyComponent() {
    // No return
}
```

### Solutions

```typescript
// ✅ Solution 1: Return valid JSX
function MyComponent() {
    return <div>Hello</div>;
}

// ✅ Solution 2: React component must be a function or class
const MyComponent: React.FC = () => {
    return <div>Hello</div>;
};

// ✅ Solution 3: Use proper export
export function MyComponent() {
    return <div>Hello</div>;
}

// ✅ Solution 4: Import React
import React from 'react';
function MyComponent() {
    return <div>Hello</div>;
}

// ✅ Solution 5: Return null if needed
function MyComponent() {
    return null;
}
```

## TS2322: Type 'X' is not assignable to type 'Y' (React Props)

### Description
Passing the wrong type of prop to a React component.

### Common Causes
- Wrong prop type
- Missing required prop
- Incorrect event handler type
- Wrong children type

### Examples

```typescript
// ❌ Error: Type 'string' is not assignable to type 'number'
interface Props {
    count: number;
}
const Component: React.FC<Props> = ({ count }) => <div>{count}</div>;
<Component count="42" />;

// ❌ Error: Type 'string' is not assignable to type 'ReactNode'
interface Props {
    children: React.ReactNode;
}
<Component>Hello</Component>; // Works
<Component>{42}</Component>; // Works
<Component>{null}</Component>; // Works

// ❌ Error: Type '{ onChange: () => void; }' is not assignable
interface InputProps {
    onChange: (value: string) => void;
}
const Input = ({ onChange }: InputProps) => <input onChange={(e) => onChange(e.target.value)} />;
<Input onChange={() => {}} />; // Error
```

### Solutions

```typescript
// ✅ Solution 1: Use correct type
<Component count={42} />;

// ✅ Solution 2: Convert the value
<Component count={Number("42")} />;

// ✅ Solution 3: Update interface
interface Props {
    count: number | string;
}

// ✅ Solution 4: Use correct event handler
<Input onChange={(value: string) => {}} />;

// ✅ Solution 5: Use React's built-in types
interface InputProps {
    onChange: React.ChangeEventHandler<HTMLInputElement>;
}
```

## TS2604: JSX element type 'X' does not have any construct or call signatures

### Description
The JSX element type is invalid.

### Common Causes
- Wrong component name
- Component not imported
- Component returns invalid type
- Component is a type, not a value

### Examples

```typescript
// ❌ Error: JSX element type 'MyComponent' does not have any construct or call signatures
import { MyComponent } from './types';

// ❌ Error: JSX element type 'Button' does not have any construct or call signatures
import Button from './components';

// ❌ Error: JSX element type 'MyComponent' does not have any construct or call signatures
type MyComponent = React.FC<Props>;
const element = <MyComponent />; // Type used as value
```

### Solutions

```typescript
// ✅ Solution 1: Import the component correctly
import { MyComponent } from './components';

// ✅ Solution 2: Use default import correctly
import Button from './components';

// ✅ Solution 3: Check export syntax
// In components.tsx:
export const MyComponent = () => <div>Hello</div>;
// Then:
import { MyComponent } from './components';

// ✅ Solution 4: Don't use type as value
const MyComponent: React.FC<Props> = (props) => <div>Hello</div>;
const element = <MyComponent />; // Uses value, not type
```

---

# 7. Next.js Errors

## Server vs Client Component Errors

### Problem
Using client-only features in server components, or server-only features in client components.

### Common Causes
- Using hooks in server component
- Using `'use client'` incorrectly
- Importing server-only code in client component
- Using `useState`, `useEffect` without `'use client'`

### Examples

```typescript
// ❌ Error: Cannot use useState in Server Component
export default function ServerComponent() {
    const [state, setState] = useState(false); // Error
    return <div>{state}</div>;
}

// ❌ Error: Cannot use event handlers in Server Component
export default function ServerComponent() {
    const handleClick = () => { console.log('clicked'); };
    return <button onClick={handleClick}>Click</button>; // Error
}

// ❌ Error: Cannot import client component without 'use client'
// In Server Component:
import { ClientComponent } from './ClientComponent'; // Error if ClientComponent uses client features
```

### Solutions

```typescript
// ✅ Solution 1: Add 'use client' directive
'use client';
export default function ClientComponent() {
    const [state, setState] = useState(false);
    return <div>{state}</div>;
}

// ✅ Solution 2: Pass client code to child component
export default function ServerComponent() {
    return <ClientComponent />;
}

// ✅ Solution 3: Use async component for server fetching
export default async function ServerComponent() {
    const data = await fetch('...');
    return <div>{data}</div>;
}

// ✅ Solution 4: Use 'use client' at the top of file
'use client';
// Now can use hooks, events, etc.
```

## Metadata Type Errors

### Problem
Incorrectly typed or missing metadata.

### Common Causes
- Wrong metadata type
- Missing required metadata
- Incorrect property names
- Async metadata function

### Examples

```typescript
// ❌ Error: Property 'title' does not exist on type 'Metadata'
export const metadata = {
    title: 'My Page',
    description: 'Page description'
}; // Missing 'description' property type

// ❌ Error: Type '{ title: string; }' is not assignable to type 'Metadata'
export const metadata = {
    title: 'My Page'
}; // Missing required property

// ❌ Error: Type 'Promise<{ title: string; }>' is not assignable to type 'Metadata'
export async function generateMetadata() {
    return { title: 'My Page' };
} // Async not allowed for metadata
```

### Solutions

```typescript
// ✅ Solution 1: Import Metadata type
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'My Page',
    description: 'Page description'
};

// ✅ Solution 2: Include all required properties
export const metadata: Metadata = {
    title: 'My Page',
    description: 'Page description',
    // Additional optional metadata
    keywords: ['nextjs', 'typescript'],
    authors: [{ name: 'My Team' }]
};

// ✅ Solution 3: Use generateMetadata for dynamic pages
import { Metadata } from 'next';

export async function generateMetadata(): Promise<Metadata> {
    return {
        title: 'My Page',
        description: 'Page description'
    };
}
```

## Route Handler Errors

### Problem
Type errors in API route handlers.

### Common Causes
- Wrong request type
- Incorrect response type
- Missing params type
- Error handling type issues

### Examples

```typescript
// ❌ Error: Parameter 'request' implicitly has 'any' type
export async function GET(request) {
    return Response.json({ data: 'Hello' });
}

// ❌ Error: Property 'id' does not exist on type '{ params: any }'
export async function GET(request: Request, { params }: { params: any }) {
    const { id } = params; // Error
    return Response.json({ data: id });
}

// ❌ Error: Type 'unknown' is not assignable to type 'string'
export async function POST(request: Request) {
    const body = await request.json();
    const { id } = body; // Error if id doesn't exist
    return Response.json({ data: id });
}
```

### Solutions

```typescript
// ✅ Solution 1: Type the request
export async function GET(request: Request) {
    return Response.json({ data: 'Hello' });
}

// ✅ Solution 2: Type the params
export async function GET(
    request: Request,
    { params }: { params: { id: string } }
) {
    const { id } = params;
    return Response.json({ data: id });
}

// ✅ Solution 3: Validate request body
export async function POST(request: Request) {
    const body = await request.json();
    const { id } = body as { id: string };
    return Response.json({ data: id });
}

// ✅ Solution 4: Use NextResponse
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
    return NextResponse.json({ data: 'Hello' });
}
```

---

# 8. Configuration Errors

## TS5023: Unknown compiler option 'X'

### Description
tsconfig.json contains an unknown compiler option.

### Common Causes
- Typo in option name
- Option not supported in current TypeScript version
- Option moved to different location

### Examples

```json
{
    "compilerOptions": {
        "strictNullCheck": true, // Should be "strictNullChecks"
        "noImplicitAny": true,
        "unkownOption": true
    }
}
```

### Solutions

```json
{
    "compilerOptions": {
        "strictNullChecks": true,
        "noImplicitAny": true,
        // Remove unknown options
    }
}
```

## TS5055: Cannot write file 'X' because it would overwrite input file

### Description
Output file would overwrite the input file.

### Common Causes
- `outDir` is same as `rootDir`
- Source and output directories conflict
- File naming conflict

### Solutions

```json
{
    "compilerOptions": {
        "outDir": "./dist",
        "rootDir": "./src",
        // Make sure outDir is different from rootDir
    }
}
```

## TS2688: Cannot find type definition file for 'X'

### Description
TypeScript can't find the type definitions for a package.

### Common Causes
- Missing @types package
- Incorrect types location
- Package doesn't include types

### Solutions

```bash
# Install type definitions
npm install --save-dev @types/package-name

# Or if package includes types, ensure it's installed
npm install package-name
```

---

# 9. Runtime vs Compile-Time Errors

## Understanding the Difference

| Aspect | Compile-Time Errors | Runtime Errors |
|--------|-------------------|----------------|
| **When** | During development | During execution |
| **Caught by** | TypeScript compiler | JavaScript runtime |
| **Examples** | Type mismatches, missing imports | Cannot read property of undefined |
| **Prevention** | Type checking | Testing, error handling |

## Common Runtime Errors from TypeScript Code

### Error: Cannot read property 'X' of undefined

```typescript
// Compile-time: No error (if type says it's required)
// Runtime: Error if data is undefined
interface User {
    name: string;
}
const user = getUser(); // Might return undefined at runtime
console.log(user.name); // Runtime error
```

### Solution

```typescript
// Use optional chaining
console.log(user?.name);

// Use nullish coalescing
console.log(user?.name ?? 'No name');

// Use type guard
if (user) {
    console.log(user.name);
}
```

### Error: X is not a function

```typescript
// Compile-time: No error if type says it's a function
// Runtime: Error if it's not actually a function
const callbacks = getCallbacks(); // Might return something else
callbacks.onSuccess(); // Runtime error if not a function```

### Solution

```typescript
// Type guard
if (typeof callbacks.onSuccess === 'function') {
    callbacks.onSuccess();
}

// Optional chaining with function call
callbacks.onSuccess?.();

// Default value
(callbacks.onSuccess || (() => {}))();
```

---

# 10. Debugging Strategies

## Strategy 1: Read the Error Message

```typescript
// Error: Type 'string' is not assignable to type 'number'
// This tells you exactly what's wrong
```

## Strategy 2: Check the Type

```typescript
// Use type checking to see what TypeScript thinks
type Debug<T> = T extends any ? { [K in keyof T]: T[K] } : never;

// Or use hover in VS Code
```

## Strategy 3: Use Type Guards

```typescript
function isString(value: unknown): value is string {
    return typeof value === 'string';
}
```

## Strategy 4: Test with Simple Values

```typescript
// Start with simple types
let test: string = "test";
// Then add complexity
```

## Strategy 5: Use `any` Temporarily (But Remove)

```typescript
// Only for debugging
let value: any = getValue();
// Figure out the type, then replace any
```

## Strategy 6: Check tsconfig.json

```typescript
// Ensure strict mode is working
{
    "compilerOptions": {
        "strict": true
    }
}
```

## Strategy 7: Use TypeScript Playground

```
https://www.typescriptlang.org/play
```

## Strategy 8: Use the TypeScript Compiler API

```bash
# Get more detailed errors
tsc --traceResolution
tsc --listFiles
tsc --explainFiles
```

## Strategy 9: Check Your Imports

```typescript
// Make sure imports are correct
// Check export/import syntax
// Verify paths
```

## Strategy 10: Use ESLint with TypeScript

```json
{
    "extends": [
        "plugin:@typescript-eslint/recommended"
    ]
}
```

---

# Quick Troubleshooting Guide

## The Error Triangle

```
                ┌─────────────┐
                │  TS2322     │
                │  Type Error │
                └──────┬──────┘
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼
    ┌─────────┐  ┌─────────┐  ┌─────────┐
    │  Check  │  │  Check  │  │  Check  │
    │  Value  │  │  Type   │  │  Context│
    └─────────┘  └─────────┘  └─────────┘
```

## Quick Fix Reference

| Error Code | Quick Fix |
|------------|-----------|
| TS2322 | Check value type vs expected type |
| TS2339 | Check if property exists |
| TS2345 | Check argument type |
| TS2531 | Use optional chaining |
| TS2307 | Install module or check path |
| TS7006 | Add type annotation |
| TS2554 | Check function parameters |
| TS7030 | Add missing return |
