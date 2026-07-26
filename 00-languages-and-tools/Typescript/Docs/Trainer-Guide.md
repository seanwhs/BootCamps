# Mastering TypeScript: Trainer Guide

## Complete Instructor's Guide for the 6-Part Series

---

# Table of Contents

**Course Overview**
- Course Description
- Learning Objectives
- Target Audience
- Prerequisites
- Course Structure
- Materials and Setup

**Part 1: Core Mental Model and Foundations**
- Session Overview
- Key Teaching Points
- Common Pitfalls
- Activities and Exercises
- Discussion Questions
- Assessment

**Part 2: Objects, Reuse, and Utility Types**
- Session Overview
- Key Teaching Points
- Common Pitfalls
- Activities and Exercises
- Discussion Questions
- Assessment

**Part 3: Advanced Types and Type-Level Programming**
- Session Overview
- Key Teaching Points
- Common Pitfalls
- Activities and Exercises
- Discussion Questions
- Assessment

**Part 4: TypeScript in React**
- Session Overview
- Key Teaching Points
- Common Pitfalls
- Activities and Exercises
- Discussion Questions
- Assessment

**Part 5: TypeScript in Next.js**
- Session Overview
- Key Teaching Points
- Common Pitfalls
- Activities and Exercises
- Discussion Questions
- Assessment

**Part 6: Architecture, Testing, and Debugging**
- Session Overview
- Key Teaching Points
- Common Pitfalls
- Activities and Exercises
- Discussion Questions
- Assessment

**Appendices**
- Appendix A: Sample Syllabus
- Appendix B: Assessment Rubrics
- Appendix C: Troubleshooting Guide
- Appendix D: Additional Resources
- Appendix E: Trainer Notes

---

# Course Overview

## Course Description

**Mastering TypeScript: From JavaScript Habits to Production-Grade React and Next.js Architecture** is a comprehensive 6-part training program designed for developers who want to move beyond basic TypeScript usage and master it as a practical design tool for building safer, cleaner, and more maintainable applications.

This course bridges the gap between understanding TypeScript syntax and applying it effectively in real-world React and Next.js projects. Students will progress from fundamental concepts through advanced type-level programming, culminating in building a complete production-ready application.

## Learning Objectives

Upon completion of this course, students will be able to:

1. **Fundamentals** - Explain TypeScript's role as a compile-time type checker and apply basic types, inference, unions, and narrowing

2. **Reusability** - Create type-safe, reusable code using interfaces, type aliases, generics, and utility types

3. **Advanced Patterns** - Leverage conditional types, mapped types, template literal types, and the `infer` keyword

4. **React Integration** - Build fully typed React components, custom hooks, context, and forms

5. **Next.js Integration** - Implement type-safe Next.js applications with App Router, server actions, and API routes

6. **Production Readiness** - Write type-safe tests, debug effectively, and apply clean architecture patterns

## Target Audience

This course is designed for:

- **Frontend Developers** - React developers wanting to improve code quality
- **Full-Stack Developers** - Builders of modern web applications
- **Technical Leads** - Those responsible for code quality and team standards
- **Bootcamp Graduates** - Developers with JavaScript experience moving to TypeScript
- **Backend Developers** - Transitioning to TypeScript/JavaScript ecosystems

## Prerequisites

Required knowledge:
- JavaScript fundamentals (functions, objects, arrays, async/await)
- Basic React experience (components, props, state)
- npm/Node.js familiarity
- Terminal/command line basics

Not required:
- Previous TypeScript experience
- Deep type theory understanding
- Advanced React patterns
- Next.js experience

## Course Structure

The course consists of 6 parts, each designed for approximately 3-4 hours of instruction time:

| Part | Title | Focus Area | Duration |
|------|-------|------------|----------|
| 1 | Core Mental Model and Foundations | Fundamentals | 3 hours |
| 2 | Objects, Reuse, and Utility Types | Building Blocks | 3.5 hours |
| 3 | Advanced Types and Type-Level Programming | Advanced Concepts | 3.5 hours |
| 4 | TypeScript in React | React Integration | 4 hours |
| 5 | TypeScript in Next.js | Next.js Integration | 4 hours |
| 6 | Architecture, Testing, and Debugging | Production Readiness | 4 hours |

## Materials and Setup

### Required Software
- Node.js 18.0.0 or higher
- VS Code (recommended) or TypeScript-compatible editor
- Modern web browser
- Git (optional but recommended)

### Student Materials
- Student Workbook (provided)
- Student Notes (provided)
- Code repository with starter files
- Sample solutions

### Trainer Materials
- This Trainer Guide
- Presentation slides (provided separately)
- Code solutions
- Assessment materials

### Environment Setup Checklist
```bash
# Students should verify before starting
node --version  # v18.0.0+
npm --version   # 9.0.0+

# Project structure for the course
taskflow-tutorial/
├── frontend/      # React/Next.js projects
├── src/           # TypeScript source
└── docs/          # Course materials
```

---

# Part 1: Core Mental Model and Foundations

## Session Overview

**Duration:** 3 hours  
**Learning Focus:** Understanding TypeScript's role and mastering essential types

### Session Outline

| Time | Topic | Activity |
|------|-------|----------|
| 0:00-0:15 | Introduction & Setup | Course overview, environment check |
| 0:15-0:45 | What TypeScript Is | Lecture + discussion |
| 0:45-1:30 | Basic Types & Inference | Live coding + exercise |
| 1:30-1:45 | Break | - |
| 1:45-2:15 | Functions & Objects | Live coding + exercise |
| 2:15-2:45 | Unions & Narrowing | Demonstration + exercise |
| 2:45-3:00 | Q&A and Summary | Review, Q&A |

## Key Teaching Points

### 1. The Mental Model (15 minutes)

**Core Concept:** TypeScript is a compile-time type checker, not a runtime system.

**Teaching Strategy:**
1. Start with the "Proofreader" analogy:
   - Write content → Proofreader checks → Fix mistakes → Submit
   - Write code → TypeScript checks → Fix types → Run code

2. Emphasize the "compile-time vs. runtime" distinction:
   ```
   JavaScript: Write → Run → Hit Error → Fix → Repeat
   TypeScript: Write → Type Check → Fix → Run → Fewer Errors
   ```

3. Clarify what TypeScript is NOT:
   - Not a different language (it's a superset)
   - Not a runtime type system (types don't exist at runtime)
   - Not a performance tool (it adds development overhead)

**Key Terms to Define:**
- Compile-time: When the code is being checked/transpiled
- Runtime: When the code is executing
- Type checker: The tool that analyzes types
- Superset: Everything in JavaScript works in TypeScript

### 2. Basic Types and Inference (30 minutes)

**Core Concept:** TypeScript can infer types automatically, but annotations provide explicit contracts.

**Teaching Strategy:**
1. Start with inference examples:
   ```typescript
   let name = "TaskFlow";    // string
   let version = 1.0;        // number
   ```
   - Ask: "What type does TypeScript think this is?"

2. Introduce annotations gradually:
   - Start with functions (parameters need types)
   - Then complex objects
   - Finally custom types

3. Show the progression:
   ```typescript
   // Step 1: Let inference work
   const tasks = ["Write", "Review", "Deploy"];
   
   // Step 2: Add annotations where needed
   function processTasks(tasks: string[]): void { ... }
   
   // Step 3: Create reusable types
   type TaskList = string[];
   ```

**Common Student Questions:**
- "When should I use explicit types?" - When inference isn't enough, especially for function boundaries
- "Why can't TypeScript always infer the type?" - Inference has limits; complex objects need help

### 3. Functions and Objects (30 minutes)

**Core Concept:** Functions and objects are the building blocks of TypeScript applications.

**Teaching Strategy:**
1. Show complete function patterns:
   ```typescript
   // Parameter types
   // Return types
   // Optional parameters
   // Default values
   ```

2. Demonstrate object typing with real examples:
   - User profiles
   - API responses
   - Configuration objects

3. Emphasize the "call signature" pattern for callbacks

**Key Patterns to Cover:**
- Function type annotations: `(param: Type) => ReturnType`
- Optional parameters: `param?: type`
- Object shapes: `{ prop: type; prop2?: type }`

### 4. Unions and Narrowing (30 minutes)

**Core Concept:** Union types allow flexibility; narrowing makes them safe.

**Teaching Strategy:**
1. Start with a real-world example:
   - "A task ID can be a string OR a number"
   - "An API response can be success OR error"

2. Show the problem before the solution:
   ```typescript
   // ❌ What happens without narrowing?
   function process(id: string | number) {
       // Can't call string methods or number methods safely
   }
   ```

3. Introduce each narrowing technique with examples:
   - `typeof` for primitives
   - `in` for objects
   - `instanceof` for classes
   - Equality checks for constants

4. Demonstrating discriminated unions as the "practical solution" to union type challenges

**Common Student Questions:**
- "Why can't I just use `any`?" - It disables type checking; unions keep safety
- "What's the difference between `|` and `&`?" - Union vs. intersection

### 5. any vs. unknown vs. never (15 minutes)

**Core Concept:** These three types serve different purposes in TypeScript's type system.

**Teaching Strategy:**
1. Create a comparison table on the board:

| Type | Purpose | When to Use |
|------|---------|-------------|
| `any` | Disable checking | Last resort, migration |
| `unknown` | Safe alternative | Truly unknown values |
| `never` | Values that never occur | Exhaustive checking |

2. Demonstrate with a real scenario:
   ```typescript
   // ❌ Unsafe: any
   let data: any = JSON.parse(response);
   data.title.toUpperCase(); // May crash
   
   // ✅ Safe: unknown
   let data: unknown = JSON.parse(response);
   if (typeof data === 'object' && data && 'title' in data) {
       // Safe to use
   }
   ```

3. Show `never` in action with exhaustive checking:
   ```typescript
   switch (status) {
       case 'active': // ...
       case 'inactive': // ...
       default:
           const exhaustive: never = status;
   }
   ```

## Common Pitfalls

### Pitfall 1: Using `any` as a Crutch
**Problem:** Students reach for `any` when they don't know the type.  
**Solution:** Teach them to use `unknown` or Google the type.  
**Encourage:** "If you're tempted to use `any`, ask yourself: 'Do I really need to disable all checking here?'"

### Pitfall 2: Over-annotating Everything
**Problem:** Students add types everywhere, making code verbose.  
**Solution:** Show when inference is sufficient.  
**Rule:** "Use annotations for function boundaries; let inference work inside functions."

### Pitfall 3: Not Narrowing Union Types
**Problem:** Students try to use union types without checking first.  
**Solution:** Always check before using.  
**Rule:** "If a value can be more than one type, check which one it is before using it."

### Pitfall 4: Confusing `|` and `&`
**Problem:** Students use `|` when they need `&` and vice versa.  
**Solution:** Use real-world analogies:
- `|` (Union): "Either A OR B" (one or the other)
- `&` (Intersection): "Both A AND B" (combines both)

## Activities and Exercises

### Activity 1: Type Inference Challenge (15 minutes)

**Objective:** Practice reading and predicting TypeScript's type inference.

**Instructions:**
1. Show code with inferred types
2. Ask students to predict the type
3. Reveal the actual type
4. Discuss any surprises

**Code Example:**
```typescript
const x = 42;
const y = "hello";
const z = true;
const arr = [1, 2, 3];
const mixed = ["hello", 42];
const obj = { id: 1, name: "Task" };
```

### Activity 2: Union Type Exercise (15 minutes)

**Objective:** Practice using union types with type narrowing.

**Instructions:**
1. Provide a type with a union
2. Ask students to write a function that handles both cases
3. Review and discuss different approaches

**Code Example:**
```typescript
type User = { id: string; name: string; role: 'admin' | 'user' };

function getUserDisplayName(user: User): string {
    // Your code here: return name with role prefix
}
```

### Activity 3: Type Guard Practice (15 minutes)

**Objective:** Create type guards for custom types.

**Instructions:**
1. Define a custom type
2. Ask students to create a type guard
3. Test with different values

**Code Example:**
```typescript
type Task = { id: string; title: string; completed: boolean };

function isTask(value: any): value is Task {
    // Your code here
}
```

## Discussion Questions

1. "When would you choose TypeScript over plain JavaScript for a project?"

2. "What's the most common type-related bug you've encountered in JavaScript?"

3. "How does thinking about types change the way you write code?"

4. "What do you think is the biggest benefit of type safety?"

5. "What challenges do you anticipate in adopting TypeScript?"

## Assessment

### Formative Assessment (During Session)

**Check for Understanding:**
- "What type does TypeScript infer for `const x = [1, 2, 3]`?"
- "How do you make a property optional in a type?"
- "What's the difference between `any` and `unknown`?"
- "How do you narrow a union type?"

### Summative Assessment (End of Session)

**Part 1 Quiz:**

1. What is TypeScript primarily used for?
   a) Runtime type checking
   b) Compile-time type checking ✓
   c) Code minification
   d) Performance optimization

2. What type does TypeScript infer for `const items = ["a", "b", "c"]`?
   a) string ✓
   b) string[]
   c) any[]
   d) tuple

3. Which of these is NOT a valid way to narrow a union type?
   a) `typeof`
   b) `in`
   c) `instanceof`
   d) `as` ✓

4. When should you use `unknown` instead of `any`?
   a) Never
   b) When you need to disable type checking
   c) When you need type safety but the type is unknown ✓
   d) For primitive types only

5. What does the `never` type represent?
   a) Any value
   b) Values that never occur ✓
   c) Null values
   d) Unknown values

6. What's the difference between `|` and `&`?
   a) `|` is union, `&` is intersection ✓
   b) `|` is intersection, `&` is union
   c) They're the same
   d) `|` is for numbers, `&` is for strings

7. Type narrowing is:
   a) Making types smaller
   b) Using TypeScript's type checker to refine types ✓
   c) Removing types from code
   d) Converting JavaScript to TypeScript

8. Which of these is a correct way to define an optional property?
   a) `name: string?`
   b) `name?: string` ✓
   c) `name: string | null`
   d) `name: string | undefined`

---

# Part 2: Objects, Reuse, and Utility Types

## Session Overview

**Duration:** 3.5 hours  
**Learning Focus:** Building reusable, type-safe code with interfaces, generics, and utility types

### Session Outline

| Time | Topic | Activity |
|------|-------|----------|
| 0:00-0:15 | Review & Introduction | Recap Part 1, Preview Part 2 |
| 0:15-0:45 | Interfaces vs. Type Aliases | Lecture + comparison |
| 0:45-1:30 | Generics | Live coding + exercise |
| 1:30-1:45 | Break | - |
| 1:45-2:15 | Utility Types | Demonstration + exercise |
| 2:15-2:45 | Advanced tsconfig.json | Walkthrough + setup |
| 2:45-3:15 | Data Layer Implementation | Live coding |
| 3:15-3:30 | Q&A and Summary | Review, Q&A |

## Key Teaching Points

### 1. Interfaces vs. Type Aliases (30 minutes)

**Core Concept:** Both define types but serve different purposes.

**Teaching Strategy:**
1. Present a comparison table:

| Aspect | Interface | Type Alias |
|--------|-----------|------------|
| Extends | Yes | Yes (with &) |
| Declaration Merging | Yes | No |
| Classes implement | Yes | Yes |
| Union types | No | Yes |
| Mapped types | No | Yes |
| Primitive types | No | Yes |

2. Show practical examples:
   ```typescript
   // Interface: For extending/implementing
   interface Animal { name: string }
   interface Dog extends Animal { bark(): void }
   
   // Type: For unions and utilities
   type Status = 'pending' | 'approved' | 'rejected';
   type AnimalOrStatus = Animal | Status;
   ```

3. Provide clear guidance:
   - Use `interface` for object definitions that might be extended
   - Use `type` for everything else

**Key Terms to Define:**
- Declaration merging: Adding to an existing interface
- Mapped types: Transforming property types
- Intersection: Combining types with `&`

### 2. Generics (45 minutes)

**Core Concept:** Generics create reusable code that works with any type while maintaining type safety.

**Teaching Strategy:**
1. Start with a real-world analogy:
   - "A box that can hold anything, but remembers what's inside"
   - "A function that works with any type, but keeps type safety"

2. Progressive examples:
   ```typescript
   // Step 1: Basic generic
   function identity<T>(value: T): T { return value; }
   
   // Step 2: Generic with arrays
   function first<T>(items: T[]): T | undefined {
       return items[0];
   }
   
   // Step 3: Generic with constraints
   function getName<T extends { name: string }>(item: T): string {
       return item.name;
   }
   
   // Step 4: Multiple generics
   function mapKey<T, K extends keyof T, U>(
       obj: T,
       key: K,
       mapFn: (value: T[K]) => U
   ): Record<K, U> { ... }
   
   // Step 5: Generic class
   class Repository<T extends { id: string }> { ... }
   ```

3. Emphasize where generics shine:
   - Data fetching hooks
   - Repository patterns
   - Utility functions
   - React components

**Common Student Questions:**
- "Why use generics instead of `any`?" - Generics maintain type safety
- "When do I need constraints?" - When you need to access specific properties
- "How many generics is too many?" - Keep it to 2-3 unless necessary

### 3. Utility Types (30 minutes)

**Core Concept:** Built-in types that transform existing types.

**Teaching Strategy:**
1. Organize by purpose:

**For Modifying Properties:**
- `Partial<T>` - All optional
- `Required<T>` - All required
- `Readonly<T>` - All read-only

**For Selecting/Omitting:**
- `Pick<T, K>` - Keep specific properties
- `Omit<T, K>` - Remove specific properties

**For Combining:**
- `Record<K, T>` - Key-value map
- `Exclude<T, U>` - Remove union members
- `Extract<T, U>` - Keep union members

**For Functions:**
- `ReturnType<T>` - Return type
- `Parameters<T>` - Parameter types

2. Show practical examples with the same base type:
   ```typescript
   type Task = { id: string; title: string; completed: boolean };
   
   type PartialTask = Partial<Task>;
   type TaskSummary = Pick<Task, 'id' | 'title'>;
   type TaskWithoutId = Omit<Task, 'id'>;
   ```

3. Demonstrate combining utilities:
   ```typescript
   type TaskUpdates = Partial<Omit<Task, 'id'>>;
   ```

### 4. Advanced tsconfig.json (30 minutes)

**Core Concept:** Configuration options that enable strict type checking and better development experience.

**Teaching Strategy:**
1. Focus on the most important options first:

**Strict Mode Family:**
- `strict: true` - Enables everything
- `noImplicitAny` - Don't allow implied `any`
- `strictNullChecks` - Handle null/undefined explicitly
- `strictFunctionTypes` - Check function compatibility
- `strictPropertyInitialization` - Class properties initialized

**Module Resolution:**
- `module` - Module system (NodeNext, ESNext)
- `moduleResolution` - Resolution strategy
- `target` - JavaScript version output
- `lib` - Which JS features to include

**Path Aliases:**
- Cleaner imports
- Easier refactoring
- Better organization

2. Show the progression:
   ```json
   {
     "compilerOptions": {
       "strict": true,
       "paths": {
         "@/*": ["./src/*"],
         "@types/*": ["./src/types/*"]
       }
     }
   }
   ```

3. Explain why each option matters in production

## Common Pitfalls

### Pitfall 1: Overusing `any` with Generics
**Problem:** Using `any` instead of generics.  
**Solution:** Always use generics for type-safe reusability.  
**Rule:** "If the type is variable but should be tracked, use a generic."

### Pitfall 2: Not Constraining Generics
**Problem:** Not using `extends` to constrain generic types.  
**Solution:** Always constrain when you need specific properties.  
**Rule:** "If you access properties of a generic type, constrain it."

### Pitfall 3: Confusing Utility Types
**Problem:** Mixing up `Pick` and `Omit`.  
**Solution:** Remember: Pick keeps, Omit removes.  
**Memory Aid:** "Pick the ones you want, Omit the ones you don't."

### Pitfall 4: Not Using Path Aliases
**Problem:** Long, messy relative imports.  
**Solution:** Configure `paths` in tsconfig.json.  
**Rule:** "If your imports have `../../../../`, use path aliases."

## Activities and Exercises

### Activity 1: Generics Practice (20 minutes)

**Objective:** Create reusable generic functions.

**Instructions:**
1. Write a generic `filter` function
2. Write a generic `map` function
3. Write a generic `reduce` function
4. Test with different types

**Solution Template:**
```typescript
function filter<T>(items: T[], predicate: (item: T) => boolean): T[] {
    // Your code here
}

function map<T, U>(items: T[], transform: (item: T) => U): U[] {
    // Your code here
}

function reduce<T, U>(items: T[], reducer: (acc: U, item: T) => U, initial: U): U {
    // Your code here
}
```

### Activity 2: Utility Type Exercise (15 minutes)

**Objective:** Use built-in utility types to transform types.

**Instructions:**
1. Define a `User` type
2. Create various transformed types:
   - `PublicUser` (only id, name, email)
   - `UserUpdate` (optional fields except id)
   - `UserView` (read-only version)
3. Show how these would be used in a real app

**Solution:**
```typescript
type User = {
    id: string;
    name: string;
    email: string;
    password: string;
    role: 'admin' | 'user';
    createdAt: Date;
};

type PublicUser = Pick<User, 'id' | 'name' | 'email' | 'role'>;
type UserUpdate = Partial<Omit<User, 'id' | 'createdAt'>> & { id: string };
type UserView = Readonly<PublicUser>;
```

### Activity 3: Data Layer Implementation (30 minutes)

**Objective:** Build a generic repository and specific implementations.

**Instructions:**
1. Create a generic `Repository` class
2. Create a `TaskRepository` that extends it
3. Add task-specific methods
4. Create a service layer

**Solution Outline:**
```typescript
class Repository<T extends { id: string }> {
    protected items: T[] = [];
    
    add(item: T): void { /* ... */ }
    findById(id: string): T | undefined { /* ... */ }
    findAll(): T[] { /* ... */ }
    update(id: string, updates: Partial<T>): T | undefined { /* ... */ }
    delete(id: string): boolean { /* ... */ }
}

class TaskRepository extends Repository<Task> {
    findByStatus(status: Task['status']): Task[] { /* ... */ }
    getOverdueTasks(): Task[] { /* ... */ }
}
```

## Discussion Questions

1. "When would you choose an interface over a type alias?"

2. "What's the most common use case for generics in your experience?"

3. "Which utility type do you think is most useful and why?"

4. "How does strict mode change the way you write code?"

5. "What benefits do path aliases provide in large codebases?"

## Assessment

### Formative Assessment (During Session)

**Check for Understanding:**
- "When do you use `interface` vs. `type`?"
- "What does `T extends { id: string }` mean in a generic?"
- "How do you make all properties optional in a type?"
- "What's the benefit of path aliases?"

### Summative Assessment (End of Session)

**Part 2 Quiz:**

1. Which of the following is NOT true about interfaces?
   a) They support declaration merging
   b) They can be extended
   c) They can represent primitive types ✓
   d) Classes can implement them

2. What does `T extends { id: string }` mean in a generic?
   a) T must have an id property of type string ✓
   b) T must extend the string type
   c) T is a string
   d) T is optional

3. Which utility type makes all properties of a type optional?
   a) Required
   b) Partial ✓
   c) Pick
   d) Omit

4. How do you select only specific properties from a type?
   a) Omit
   b) Pick ✓
   c) Partial
   d) Record

5. Which of these is a valid way to use a generic constraint?
   a) `function fn<T>(item: T)` ✓
   b) `function fn<T extends string>(item: T)`
   c) `function fn<T: string>(item: T)`
   d) `function fn<T = string>(item: T)`

6. Path aliases in tsconfig.json are used to:
   a) Rename files
   b) Create cleaner import paths ✓
   c) Change file extensions
   d) Move files to different directories

7. Which of these is a valid generic class?
   a) `class Box<T> { contents: T }` ✓
   b) `class Box { contents: T }`
   c) `class Box<T extends any> { contents: any }`
   d) `class Box<T> { contents: any }`

8. What is declaration merging?
   a) Combining two types
   b) Adding to an existing interface ✓
   c) Merging two interfaces
   d) Combining type aliases

---

# Part 3: Advanced Types and Type-Level Programming

## Session Overview

**Duration:** 3.5 hours  
**Learning Focus:** Mastering advanced TypeScript features for type-level programming

### Session Outline

| Time | Topic | Activity |
|------|-------|----------|
| 0:00-0:15 | Review & Introduction | Recap Part 2, Preview Part 3 |
| 0:15-0:45 | Conditional Types | Lecture + examples |
| 0:45-1:15 | Mapped Types | Live coding + exercise |
| 1:15-1:30 | Break | - |
| 1:30-2:00 | Template Literal Types | Demonstration + exercise |
| 2:00-2:30 | The infer Keyword | Deep dive + exercise |
| 2:30-3:00 | Form Validation System | Live coding |
| 3:00-3:15 | Q&A and Summary | Review, Q&A |

## Key Teaching Points

### 1. Conditional Types (30 minutes)

**Core Concept:** Types that choose between options based on conditions.

**Teaching Strategy:**
1. Present the basic syntax:
   ```typescript
   T extends U ? X : Y
   // If T extends U, result is X, otherwise Y
   ```

2. Show progressive examples:
   ```typescript
   // Simple
   type IsString<T> = T extends string ? true : false;
   
   // With filtering
   type ExtractStrings<T> = T extends string ? T : never;
   
   // Nested
   type TypeName<T> =
       T extends string ? 'string' :
       T extends number ? 'number' :
       T extends boolean ? 'boolean' :
       'unknown';
   ```

3. Explain distribution over unions:
   - Conditional types distribute over unions automatically
   - Example: `ToArray<string | number>` → `string[] | number[]`
   - Can be disabled by wrapping in a tuple

4. Show practical applications:
   - Event systems
   - API response handling
   - Type filtering

### 2. Mapped Types (30 minutes)

**Core Concept:** Types that transform properties of an existing type.

**Teaching Strategy:**
1. Present the basic syntax:
   ```typescript
   type Transform<T> = {
       [P in keyof T]: NewType<T[P]>;
   };
   ```

2. Show progressive examples:
   ```typescript
   // Make all optional
   type MakeOptional<T> = {
       [P in keyof T]?: T[P];
   };
   
   // Filter properties
   type KeepStringProperties<T> = {
       [P in keyof T as T[P] extends string ? P : never]: T[P];
   };
   
   // Transform properties
   type UppercaseProperties<T> = {
       [P in keyof T]: T[P] extends string ? Uppercase<T[P]> : T[P];
   };
   ```

3. Combine with conditional types:
   ```typescript
   type DeepPartial<T> = {
       [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
   };
   ```

### 3. Template Literal Types (30 minutes)

**Core Concept:** Types that manipulate strings at the type level.

**Teaching Strategy:**
1. Present the syntax:
   ```typescript
   type StringType = `${prefix}${string}`;
   ```

2. Show progressive examples:
   ```typescript
   // Basic
   type ApiEndpoint = `/api/${string}`;
   
   // With union types
   type ApiRoute = `${'GET' | 'POST'} /${string}`;
   
   // String manipulation
   type ToCamelCase<S extends string> =
       S extends `${infer First}_${infer Rest}`
           ? `${Lowercase<First>}${Capitalize<ToCamelCase<Rest>>}`
           : Lowercase<S>;
   ```

3. Demonstrate URL parameter extraction:
   ```typescript
   type UrlParams<T extends string> =
       T extends `${string}:${infer Param}/${infer Rest}`
           ? { [K in Param | keyof UrlParams<Rest>]: string }
           : T extends `${string}:${infer Param}`
               ? { [K in Param]: string }
               : {};
   ```

### 4. The infer Keyword (30 minutes)

**Core Concept:** Extracting types from other types using pattern matching.

**Teaching Strategy:**
1. Present the concept:
   - `infer` is like pattern matching for types
   - Extract a type from a larger type

2. Show progressive examples:
   ```typescript
   // Extract array element type
   type ElementType<T> = T extends (infer U)[] ? U : never;
   
   // Extract function return type
   type ReturnTypeOf<T> = T extends (...args: any[]) => infer R ? R : never;
   
   // Extract function parameters
   type ParametersOf<T> = T extends (...args: infer P) => any ? P : never;
   
   // Extract Promise value
   type Awaited<T> = T extends Promise<infer U> ? U : T;
   ```

3. Show practical applications:
   - Event data extraction
   - API response parsing
   - Component prop extraction

### 5. Form Validation System (30 minutes)

**Core Concept:** Building a practical type-safe validation system combining all advanced features.

**Teaching Strategy:**
1. Present the architecture:
   ```typescript
   type ValidationResult<T> = 
       | { valid: true; value: T }
       | { valid: false; errors: string[] };
   
   type Validator<T> = (value: unknown) => ValidationResult<T>;
   ```

2. Build built-in validators:
   ```typescript
   function isString(value: unknown): ValidationResult<string> { ... }
   function minLength(min: number): Validator<string> { ... }
   function isEmail(value: unknown): ValidationResult<string> { ... }
   ```

3. Create the object validator:
   ```typescript
   function objectValidator<T extends Record<string, any>>(
       shape: { [K in keyof T]: Validator<T[K]> }
   ): Validator<T> {
       // Implementation
   }
   ```

4. Demonstrate usage:
   ```typescript
   type User = { email: string; password: string };
   const userValidator = objectValidator<User>({
       email: isEmail,
       password: minLength(8)
   });
   ```

## Common Pitfalls

### Pitfall 1: Infinite Recursion in Conditional Types
**Problem:** Recursive types that don't terminate.  
**Solution:** Add a base case or use a depth limit.  
**Rule:** "Always have a base case that returns a concrete type."

### Pitfall 2: Overly Complex Types
**Problem:** Types that are hard to understand and debug.  
**Solution:** Break into smaller, named types.  
**Rule:** "If a type is hard to read, it's probably too complex."

### Pitfall 3: Misunderstanding Distributive Behavior
**Problem:** Not knowing when conditional types distribute.  
**Solution:** Use tuple wrapping to prevent distribution.  
**Rule:** `[T] extends [U]` prevents distribution.

### Pitfall 4: Unconstrained Template Literals
**Problem:** Creating overly broad string types.  
**Solution:** Use specific patterns and constraints.  
**Rule:** "Be as specific as possible with string patterns."

## Activities and Exercises

### Activity 1: Conditional Types (15 minutes)

**Objective:** Create conditional types for common scenarios.

**Instructions:**
1. Create a type that extracts only arrays from a union
2. Create a type that removes null and undefined
3. Create a type that converts any type to an array

### Activity 2: Mapped Types (15 minutes)

**Objective:** Create mapped types for data transformation.

**Instructions:**
1. Create a type that makes all properties nullable
2. Create a type that adds a prefix to all property names
3. Create a type that recursively makes all properties optional

### Activity 3: Template Literal Types (15 minutes)

**Objective:** Create string manipulation types.

**Instructions:**
1. Create a type that converts camelCase to snake_case
2. Create a type that extracts parameters from a URL
3. Create a type that generates API endpoints

### Activity 4: Validation System (30 minutes)

**Objective:** Build a complete validation system.

**Instructions:**
1. Create basic validators (string, number, email)
2. Create combinators (optional, union)
3. Create an object validator
4. Test with a real form

## Discussion Questions

1. "When would you use conditional types in a real application?"

2. "What are the benefits and drawbacks of type-level programming?"

3. "How does the `infer` keyword change the way you think about types?"

4. "What are the limits of TypeScript's type system?"

5. "When should you avoid advanced types?"

## Assessment

### Formative Assessment (During Session)

**Check for Understanding:**
- "What does `T extends U ? X : Y` mean?"
- "How do you transform all properties of a type?"
- "What is the `infer` keyword used for?"
- "When would you use template literal types?"

### Summative Assessment (End of Session)

**Part 3 Quiz:**

1. What does `T extends U ? X : Y` represent?
   a) A mapped type
   b) A conditional type ✓
   c) A utility type
   d) A generic type

2. Which syntax is used for mapped types?
   a) `T extends U ? X : Y`
   b) `[P in keyof T]: U` ✓
   c) `T extends infer U ? U : never`
   d) `${string}${string}`

3. What is the `infer` keyword used for?
   a) Inferring types automatically
   b) Extracting types from other types ✓
   c) Creating conditional types
   d) Defining generic types

4. Which of these is a valid template literal type?
   a) `type Api = 'api/' + string`
   b) `type Api = \`/api/${string}\`` ✓
   c) `type Api = '/api/:string'`
   d) `type Api = '/api/' + T`

5. How do you prevent distribution in a conditional type?
   a) Use `any`
   b) Wrap in a tuple ✓
   c) Use `unknown`
   d) Use `never`

6. Which of these is a valid use of mapped types?
   a) `type Options = { [P in keyof T]?: T[P] }` ✓
   b) `type Options = T extends U ? X : Y`
   c) `type Options = T extends infer U ? U : never`
   d) `type Options = \`${T}\``

7. What is a practical use case for template literal types?
   a) URL path parameters ✓
   b) Function return types
   c) Array elements
   d) Object properties

8. Which of these statements about advanced types is true?
   a) Advanced types should always be used
   b) Advanced types can make code harder to understand ✓
   c) Advanced types are faster at runtime
   d) Advanced types are always necessary

---

# Part 4: TypeScript in React

## Session Overview

**Duration:** 4 hours  
**Learning Focus:** Applying TypeScript to React components, hooks, context, and forms

### Session Outline

| Time | Topic | Activity |
|------|-------|----------|
| 0:00-0:15 | Review & Introduction | Recap Part 3, Preview Part 4 |
| 0:15-0:45 | Typing React Components | Lecture + demo |
| 0:45-1:30 | Component Exercises | Hands-on practice |
| 1:30-1:45 | Break | - |
| 1:45-2:15 | Custom Hooks | Live coding + exercise |
| 2:15-2:45 | Context & State | Demonstration + exercise |
| 2:45-3:15 | Forms with React Hook Form | Live coding |
| 3:15-3:45 | TaskFlow Components | Build practice |
| 3:45-4:00 | Q&A and Summary | Review, Q&A |

## Key Teaching Points

### 1. Typing React Components (30 minutes)

**Core Concept:** TypeScript makes React components safer and more maintainable.

**Teaching Strategy:**
1. Start with component props:
   ```typescript
   interface ButtonProps {
       children: React.ReactNode;
       variant?: 'primary' | 'secondary';
       onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
   }
   ```

2. Extend native element props:
   ```typescript
   interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
       label?: string;
       error?: string;
   }
   ```

3. Use `forwardRef`:
   ```typescript
   export const Input = React.forwardRef<HTMLInputElement, InputProps>(
       (props, ref) => {
           return <input ref={ref} {...props} />;
       }
   );
   ```

4. Create generic components:
   ```typescript
   function List<T>({ items, renderItem }: ListProps<T>) {
       // Generic list component
   }
   ```

### 2. Custom Hooks (30 minutes)

**Core Concept:** Hooks encapsulate stateful logic with type safety.

**Teaching Strategy:**
1. Type `useState`:
   ```typescript
   const [tasks, setTasks] = useState<Task[]>([]);
   ```

2. Type `useReducer`:
   ```typescript
   type Action = { type: 'ADD'; payload: Task } | { type: 'DELETE'; id: string };
   function reducer(state: Task[], action: Action): Task[] { ... }
   ```

3. Create generic hooks:
   ```typescript
   function useLocalStorage<T>(key: string, initial: T): [T, (value: T) => void] {
       // Generic hook
   }
   ```

4. Demonstrate data fetching:
   ```typescript
   function useFetch<T>(url: string): {
       data: T | null;
       loading: boolean;
       error: Error | null;
       refetch: () => Promise<void>;
   } {
       // Generic fetching hook
   }
   ```

### 3. Context and State (30 minutes)

**Core Concept:** Type-safe context for global state management.

**Teaching Strategy:**
1. Define context type:
   ```typescript
   interface TaskContextType {
       tasks: Task[];
       addTask: (task: Task) => void;
       deleteTask: (id: string) => void;
   }
   ```

2. Create context:
   ```typescript
   const TaskContext = React.createContext<TaskContextType | undefined>(undefined);
   ```

3. Implement provider:
   ```typescript
   export function TaskProvider({ children }: { children: React.ReactNode }) {
       const [tasks, setTasks] = useState<Task[]>([]);
       
       const value = useMemo(() => ({
           tasks,
           addTask: (task) => setTasks(t => [...t, task]),
           deleteTask: (id) => setTasks(t => t.filter(task => task.id !== id))
       }), [tasks]);
       
       return <TaskContext.Provider value={value}>{children}</TaskContext.Provider>;
   }
   ```

4. Create custom hook:
   ```typescript
   export function useTasks(): TaskContextType {
       const context = useContext(TaskContext);
       if (!context) {
           throw new Error('useTasks must be used within a TaskProvider');
       }
       return context;
   }
   ```

### 4. Forms with React Hook Form (30 minutes)

**Core Concept:** Type-safe forms with Zod validation.

**Teaching Strategy:**
1. Define Zod schema:
   ```typescript
   const TaskSchema = z.object({
       title: z.string().min(3).max(100),
       priority: z.enum(['low', 'medium', 'high']),
       dueDate: z.coerce.date().optional()
   });
   
   type TaskFormData = z.infer<typeof TaskSchema>;
   ```

2. Set up React Hook Form:
   ```typescript
   const {
       register,
       handleSubmit,
       formState: { errors }
   } = useForm<TaskFormData>({
       resolver: zodResolver(TaskSchema)
   });
   ```

3. Connect fields:
   ```typescript
   <input {...register('title')} />
   {errors.title && <p>{errors.title.message}</p>}
   ```

### 5. TaskFlow Components (30 minutes)

**Core Concept:** Building a complete typed React application.

**Teaching Strategy:**
1. Build from bottom-up:
   - Small reusable components first
   - Then larger composite components
   - Finally connected components

2. Emphasize prop types:
   ```typescript
   interface TaskItemProps {
       task: Task;
       onUpdate: (task: Task) => void;
       onDelete: (id: string) => void;
       onSelect: (id: string) => void;
   }
   ```

3. Show state management:
   - Local state for UI
   - Context for global state
   - Props for component communication

## Common Pitfalls

### Pitfall 1: `React.FC` and Its Drawbacks
**Problem:** Using `React.FC` can cause issues with `children` typing.  
**Solution:** Use explicit prop interfaces.  
**Rule:** "Avoid `React.FC`; define props explicitly."

### Pitfall 2: Event Handler Types
**Problem:** Not knowing the correct event type.  
**Solution:** Use `React.ChangeEvent<HTMLInputElement>`, `React.MouseEvent<HTMLButtonElement>`.  
**Rule:** "Always check the element type for events."

### Pitfall 3: Context Type Safety
**Problem:** Context value might be undefined.  
**Solution:** Create a custom hook that checks.  
**Rule:** "Always check that context exists in the consuming hook."

### Pitfall 4: Form Validation
**Problem:** Validation and types out of sync.  
**Solution:** Use Zod to generate types from schemas.  
**Rule:** "Let Zod define your types; infer from schemas."

## Activities and Exercises

### Activity 1: Typing Components (20 minutes)

**Objective:** Create typed React components.

**Instructions:**
1. Create a Card component with:
   - `children`, `title`, `className`
2. Create a Button with:
   - `variant`, `size`, `isLoading`
3. Use `forwardRef` for an Input

### Activity 2: Custom Hooks (20 minutes)

**Objective:** Create typed custom hooks.

**Instructions:**
1. Create `useLocalStorage`
2. Create `useFetch`
3. Create `useDebounce`

### Activity 3: Context (20 minutes)

**Objective:** Build type-safe context.

**Instructions:**
1. Define a `ThemeContext` with:
   - `mode: 'light' | 'dark'`
   - `toggle: () => void`
2. Create Provider and custom hook
3. Use in multiple components

### Activity 4: Forms (30 minutes)

**Objective:** Build typed forms.

**Instructions:**
1. Define Zod schema for login form
2. Set up React Hook Form
3. Connect fields
4. Handle submission
5. Display errors

## Discussion Questions

1. "What are the benefits of typing React components?"

2. "When would you use a custom hook vs. a component?"

3. "How does type-safe context improve application architecture?"

4. "What are the challenges of typed forms?"

5. "How can you share types between frontend and backend?"

## Assessment

### Formative Assessment (During Session)

**Check for Understanding:**
- "How do you type component props?"
- "What is `forwardRef` used for?"
- "How do you create a custom hook?"
- "How does Zod help with form validation?"

### Summative Assessment (End of Session)

**Part 4 Quiz:**

1. Which of these is the correct way to type a component's props?
   a) `type Props = { ... }` ✓
   b) `interface Props extends React.FC`
   c) `function Component(props: any)`
   d) `const Component = ({ ... }) => ...`

2. How do you forward a ref in a typed React component?
   a) `React.forwardRef<T, P>(...)` ✓
   b) `React.forwardRef(...)`
   c) `React.forwardRef<HTMLInputElement>(...)`
   d) `React.forwardRef({ ... })`

3. What is the correct type for an input change event?
   a) `React.ChangeEvent`
   b) `React.ChangeEvent<HTMLInputElement>` ✓
   c) `React.Event`
   d) `ChangeEvent<HTMLInputElement>`

4. How do you type a custom hook?
   a) `function useHook<T>(...): T` ✓
   b) `function useHook(...): any`
   c) `const useHook = (...): T => ...`
   d) `function useHook<T>(...): T[]`

5. What is the benefit of using Zod with React Hook Form?
   a) It's faster
   b) It generates types from schemas ✓
   c) It's required
   d) It's easier

6. Which of these is a valid way to type context?
   a) `const Context = createContext<T | undefined>(undefined)` ✓
   b) `const Context = createContext<T>`
   c) `const Context = createContext({})`
   d) `const Context = createContext<any>`

7. How do you access context safely?
   a) `useContext(Context)` directly
   b) Through a custom hook ✓
   c) With `React.useContext`
   d) With `useContext<ContextType>`

8. When should you use `React.FC`?
   a) Always
   b) Never ✓
   c) Only for simple components
   d) Only for class components

---

# Part 5: TypeScript in Next.js

## Session Overview

**Duration:** 4 hours  
**Learning Focus:** Building type-safe Next.js applications with App Router

### Session Outline

| Time | Topic | Activity |
|------|-------|----------|
| 0:00-0:15 | Review & Introduction | Recap Part 4, Preview Part 5 |
| 0:15-0:45 | Next.js + TypeScript Setup | Live setup + configuration |
| 0:45-1:15 | App Router Pages | Lecture + demo |
| 1:15-1:30 | Break | - |
| 1:30-2:00 | Server Actions | Live coding + exercise |
| 2:00-2:30 | API Routes | Demonstration + exercise |
| 2:30-3:00 | Environment Variables | Setup + validation |
| 3:00-3:30 | TaskFlow Implementation | Build practice |
| 3:30-4:00 | Q&A and Summary | Review, Q&A |

## Key Teaching Points

### 1. Next.js + TypeScript Setup (30 minutes)

**Core Concept:** Next.js provides built-in TypeScript support.

**Teaching Strategy:**
1. Show the setup command:
   ```bash
   npx create-next-app@latest my-app --typescript --app
   ```

2. Explain the TypeScript configuration:
   ```json
   {
     "compilerOptions": {
       "strict": true,
       "paths": {
         "@/*": ["./src/*"]
       }
     }
   }
   ```

3. Discuss the built-in types:
   - `PageProps`, `LayoutProps`
   - `Metadata` type
   - `RouteSegmentConfig`

### 2. App Router Pages (30 minutes)

**Core Concept:** Typed pages with server-side data fetching.

**Teaching Strategy:**
1. Show server components:
   ```typescript
   export default async function Page() {
       const data = await fetchData();
       return <Component data={data} />;
   }
   ```

2. Type page props:
   ```typescript
   interface PageProps {
       params: { id: string };
       searchParams: { [key: string]: string | string[] };
   }
   ```

3. Demonstrate data fetching:
   ```typescript
   async function fetchData() {
       const res = await fetch('...');
       return res.json();
   }
   ```

4. Show client components:
   ```typescript
   'use client';
   export function InteractiveComponent() { ... }
   ```

### 3. Server Actions (30 minutes)

**Core Concept:** Server-side mutations with type safety.

**Teaching Strategy:**
1. Define server actions:
   ```typescript
   'use server';
   export async function createTask(data: FormData) {
       const validation = TaskSchema.safeParse(data);
       if (!validation.success) {
           return { error: 'Validation failed' };
       }
       await db.task.create({ data: validation.data });
       revalidatePath('/tasks');
       return { success: true };
   }
   ```

2. Use in components:
   ```typescript
   const result = await createTask(data);
   if (result.success) {
       router.refresh();
   }
   ```

3. Handle errors:
   ```typescript
   try {
       await createTask(data);
   } catch (error) {
       // Handle error
   }
   ```

### 4. API Routes (30 minutes)

**Core Concept:** Type-safe REST API endpoints.

**Teaching Strategy:**
1. Define route handlers:
   ```typescript
   export async function GET(request: Request) {
       const { searchParams } = new URL(request.url);
       const id = searchParams.get('id');
       // Implementation
   }
   ```

2. Handle POST with validation:
   ```typescript
   export async function POST(request: Request) {
       const body = await request.json();
       const validation = TaskSchema.safeParse(body);
       // Implementation
   }
   ```

3. Return typed responses:
   ```typescript
   return NextResponse.json({
       success: true,
       data: task,
       timestamp: new Date().toISOString()
   });
   ```

### 5. Environment Variables (30 minutes)

**Core Concept:** Type-safe environment variable validation.

**Teaching Strategy:**
1. Create schema:
   ```typescript
   import { z } from 'zod';
   
   const envSchema = z.object({
       DATABASE_URL: z.string().min(1),
       JWT_SECRET: z.string().min(32),
       NEXT_PUBLIC_API_URL: z.string().url().optional(),
   });
   ```

2. Validate and export:
   ```typescript
   const env = envSchema.safeParse(process.env);
   if (!env.success) {
       console.error('Invalid environment variables');
       throw new Error('Invalid environment');
   }
   export const env = env.data;
   ```

3. Use in application:
   ```typescript
   const dbUrl = env.DATABASE_URL;
   ```

### 6. TaskFlow Implementation (30 minutes)

**Core Concept:** Building a complete Next.js application.

**Teaching Strategy:**
1. Build the data layer:
   - Prisma schema
   - Type-safe queries
   - Server actions

2. Build the UI:
   - Server components for data
   - Client components for interactivity
   - Forms with validation

3. Connect everything:
   - API routes
   - Server actions
   - Client components

## Common Pitfalls

### Pitfall 1: Confusing Server and Client Components
**Problem:** Using server-only code in client components.  
**Solution:** Add `'use client'` directive.  
**Rule:** "Server components can't use hooks or event handlers."

### Pitfall 2: Server Action Type Errors
**Problem:** Incorrect types in server actions.  
**Solution:** Validate input with Zod.  
**Rule:** "Always validate server action input."

### Pitfall 3: Environment Variable Access
**Problem:** Trying to access server-only env vars on the client.  
**Solution:** Prefix with `NEXT_PUBLIC_`.  
**Rule:** "Only `NEXT_PUBLIC_*` variables are accessible on the client."

### Pitfall 4: Revalidation Issues
**Problem:** Data not updating after mutations.  
**Solution:** Use `revalidatePath` or `revalidateTag`.  
**Rule:** "Always revalidate after mutations."

## Activities and Exercises

### Activity 1: Next.js Setup (15 minutes)

**Objective:** Create a Next.js project with TypeScript.

**Instructions:**
1. Create a new Next.js project
2. Configure TypeScript
3. Set up path aliases
4. Create a server component page

### Activity 2: Server Actions (20 minutes)

**Objective:** Create typed server actions.

**Instructions:**
1. Define a Zod schema
2. Create a server action
3. Handle validation
4. Revalidate paths
5. Use in a form

### Activity 3: API Routes (20 minutes)

**Objective:** Build typed API routes.

**Instructions:**
1. Create GET endpoint
2. Create POST endpoint with validation
3. Create PUT endpoint
4. Create DELETE endpoint
5. Return typed responses

### Activity 4: Environment Variables (15 minutes)

**Objective:** Set up type-safe environment variables.

**Instructions:**
1. Define schema
2. Validate environment
3. Export typed variables
4. Use in application

### Activity 5: Complete Feature (30 minutes)

**Objective:** Build a complete feature from end-to-end.

**Instructions:**
1. Define database schema
2. Create server actions
3. Build API routes
4. Create UI components
5. Connect everything
6. Add validation

## Discussion Questions

1. "What are the benefits of server components?"

2. "When would you use a server action vs. an API route?"

3. "How does TypeScript improve the Next.js developer experience?"

4. "What are the challenges of type-safe environment variables?"

5. "How can you share types between frontend and backend?"

## Assessment

### Formative Assessment (During Session)

**Check for Understanding:**
- "How do you create a server component?"
- "What is a server action?"
- "How do you validate environment variables?"
- "When do you use revalidatePath?"

### Summative Assessment (End of Session)

**Part 5 Quiz:**

1. Which of these is a server component?
   a) `'use client'` component
   b) `export default async function Page()` ✓
   c) `function Component() { useState }`
   d) `React.FC`

2. What is a server action?
   a) An API route
   b) A function marked with `'use server'` ✓
   c) A database query
   d) A client component

3. How do you create a type-safe environment variable?
   a) Use `typeof process.env`
   b) Validate with Zod ✓
   c) Use `any`
   d) Use `unknown`

4. Which is true about `revalidatePath`?
   a) It revalidates the entire app
   b) It revalidates a specific path ✓
   c) It's only for API routes
   d) It's for client-side only

5. How do you type an API route parameter?
   a) `{ params: { id: string } }` ✓
   b) `{ params: any }`
   c) `{ params: unknown }`
   d) `{ params: string }`

6. What is the correct way to validate environment variables?
   a) `process.env.DATABASE_URL`
   b) `z.object({ ... }).parse(process.env)` ✓
   c) `env.DATABASE_URL`
   d) `process.env['DATABASE_URL']`

7. Which of these is a valid server action?
   a) `async function create() { 'use server' }`
   b) `'use server' async function create()` ✓
   c) `function create() { 'use server' }`
   d) `function create() { }`

8. When should you use `'use client'`?
   a) Always
   b) When using hooks or event handlers ✓
   c) For server components
   d) For API routes

---

# Part 6: Architecture, Testing, and Debugging

## Session Overview

**Duration:** 4 hours  
**Learning Focus:** Production-ready TypeScript with testing, debugging, and architecture

### Session Outline

| Time | Topic | Activity |
|------|-------|----------|
| 0:00-0:15 | Review & Introduction | Recap Part 5, Preview Part 6 |
| 0:15-0:45 | Testing with Vitest | Lecture + live coding |
| 0:45-1:15 | Component Testing | Demonstration + exercise |
| 1:15-1:30 | Break | - |
| 1:30-2:00 | Debugging Techniques | Lecture + exercise |
| 2:00-2:30 | Architecture Patterns | Lecture + live coding |
| 2:30-3:00 | Production Readiness | Checklist + walkthrough |
| 3:00-3:30 | Capstone: Complete Feature | Live coding |
| 3:30-4:00 | Q&A and Summary | Review, Q&A |

## Key Teaching Points

### 1. Testing with Vitest (30 minutes)

**Core Concept:** Type-safe testing for TypeScript applications.

**Teaching Strategy:**
1. Set up Vitest:
   ```typescript
   // vitest.config.ts
   import { defineConfig } from 'vitest/config';
   export default defineConfig({
       test: {
           environment: 'jsdom',
           globals: true,
           setupFiles: ['./test/setup.ts']
       }
   });
   ```

2. Write unit tests:
   ```typescript
   describe('TaskSchema', () => {
       it('should validate a valid task', () => {
           const result = TaskSchema.safeParse(validTask);
           expect(result.success).toBe(true);
       });
   });
   ```

3. Test with async:
   ```typescript
   it('should fetch data', async () => {
       const result = await fetchData();
       expect(result).toEqual(expected);
   });
   ```

4. Mock dependencies:
   ```typescript
   vi.mock('@/lib/prisma', () => ({
       prisma: { task: { findMany: vi.fn() } }
   }));
   ```

### 2. Component Testing (30 minutes)

**Core Concept:** Testing React components with TypeScript.

**Teaching Strategy:**
1. Set up testing library:
   ```typescript
   import { render, screen } from '@testing-library/react';
   import userEvent from '@testing-library/user-event';
   ```

2. Render and query:
   ```typescript
   it('should render tasks', () => {
       render(<TaskList initialTasks={mockTasks} />);
       expect(screen.getByText('Task 1')).toBeInTheDocument();
   });
   ```

3. Test interactions:
   ```typescript
   it('should handle click', async () => {
       render(<Button onClick={mockClick}>Click</Button>);
       await userEvent.click(screen.getByText('Click'));
       expect(mockClick).toHaveBeenCalled();
   });
   ```

4. Test async interactions:
   ```typescript
   it('should fetch data on mount', async () => {
       render(<TaskList />);
       await waitFor(() => {
           expect(screen.getByText('Task 1')).toBeInTheDocument();
       });
   });
   ```

### 3. Debugging Techniques (30 minutes)

**Core Concept:** Effective debugging strategies for TypeScript.

**Teaching Strategy:**
1. Create a logger:
   ```typescript
   class Logger {
       log(level: string, message: string, meta?: any) {
           const timestamp = new Date().toISOString();
           console.log(`[${timestamp}] ${level}:`, { message, meta });
       }
   }
   ```

2. Use type debugging:
   ```typescript
   type Debug<T> = T extends any ? { [K in keyof T]: T[K] } : never;
   ```

3. Create assertions:
   ```typescript
   function assertNonNull<T>(value: T | null | undefined): asserts value is T {
       if (value === null || value === undefined) {
           throw new Error('Value is null or undefined');
       }
   }
   ```

4. Measure performance:
   ```typescript
   function measure<T>(fn: () => T, label: string): T {
       console.time(label);
       try { return fn(); }
       finally { console.timeEnd(label); }
   }
   ```

### 4. Architecture Patterns (30 minutes)

**Core Concept:** Clean architecture for TypeScript applications.

**Teaching Strategy:**
1. Present the layers:

| Layer | Purpose | Examples |
|-------|---------|----------|
| Domain | Business entities | Task, Project, User |
| Application | Use cases | CreateTask, GetTasks |
| Infrastructure | Implementation | Prisma, API, Database |
| Presentation | UI | Components, Pages |

2. Show domain layer:
   ```typescript
   interface DomainTask {
       id: string;
       title: string;
       status: 'todo' | 'done';
   }
   ```

3. Show application layer:
   ```typescript
   interface ITaskUseCases {
       createTask(dto: CreateTaskDTO): Promise<DomainTask>;
       getTasks(): Promise<DomainTask[]>;
   }
   ```

4. Show infrastructure layer:
   ```typescript
   interface ITaskRepository {
       create(task: Omit<DomainTask, 'id'>): Promise<DomainTask>;
       findById(id: string): Promise<DomainTask | null>;
   }
   ```

5. Implement dependency injection

### 5. Production Readiness (30 minutes)

**Core Concept:** Checklist for shipping production TypeScript.

**Teaching Strategy:**
1. Type Safety:
   - [ ] `strict: true` in tsconfig.json
   - [ ] No `any` usage
   - [ ] All API boundaries typed
   - [ ] Environment variables validated

2. Testing:
   - [ ] Unit tests for utilities
   - [ ] Component tests
   - [ ] Integration tests
   - [ ] Test coverage > 80%

3. Performance:
   - [ ] Bundle optimization
   - [ ] Code splitting
   - [ ] Image optimization
   - [ ] Caching strategy

4. Monitoring:
   - [ ] Error tracking (Sentry)
   - [ ] Performance metrics
   - [ ] Health checks
   - [ ] Structured logging

5. Security:
   - [ ] Input validation
   - [ ] CSRF protection
   - [ ] Rate limiting
   - [ ] Security headers

### 6. Capstone: Complete Feature (30 minutes)

**Core Concept:** Building a complete feature from end-to-end.

**Teaching Strategy:**
1. Design the feature:
   - Task assignment with notifications

2. Build the data layer:
   - Database schema
   - Domain types
   - Repository

3. Build the application:
   - Server actions
   - API routes
   - Business logic

4. Build the UI:
   - Components
   - Forms
   - Context

5. Add testing:
   - Unit tests
   - Integration tests
   - Component tests

6. Make it production-ready:
   - Error handling
   - Monitoring
   - Performance

## Common Pitfalls

### Pitfall 1: Not Testing Type Guards
**Problem:** Type guards work at compile-time, but runtime behavior matters.  
**Solution:** Test both types and runtime behavior.  
**Rule:** "Test type guards with both valid and invalid values."

### Pitfall 2: Over-Engineering Architecture
**Problem:** Adding unnecessary abstraction layers.  
**Solution:** Start simple; add complexity when needed.  
**Rule:** "Make it work, make it right, make it fast."

### Pitfall 3: Ignoring Performance
**Problem:** Type safety can impact build performance.  
**Solution:** Use incremental builds and skip type checking in dev.  
**Rule:** "Balance type safety with build speed."

### Pitfall 4: Missing Error Boundaries
**Problem:** Errors in one component can break the whole app.  
**Solution:** Add error boundaries at key points.  
**Rule:** "Always handle errors gracefully."

## Activities and Exercises

### Activity 1: Unit Testing (20 minutes)

**Objective:** Write type-safe unit tests.

**Instructions:**
1. Write tests for validation functions
2. Write tests for utility functions
3. Write tests for type guards

### Activity 2: Component Testing (20 minutes)

**Objective:** Write type-safe component tests.

**Instructions:**
1. Test a form component
2. Test a list component
3. Test error handling
4. Test loading states

### Activity 3: Architecture (20 minutes)

**Objective:** Implement clean architecture.

**Instructions:**
1. Create domain types
2. Create application use cases
3. Create infrastructure layer
4. Implement dependency injection

### Activity 4: Production Readiness (20 minutes)

**Objective:** Prepare an application for production.

**Instructions:**
1. Validate environment variables
2. Add health checks
3. Set up logging
4. Configure monitoring

### Activity 5: Capstone Feature (30 minutes)

**Objective:** Build a complete feature.

**Instructions:**
1. Design the feature
2. Build all layers
3. Add tests
4. Make it production-ready

## Discussion Questions

1. "What are the challenges of testing TypeScript applications?"

2. "How do you debug type errors effectively?"

3. "When should you use advanced architecture patterns?"

4. "What are the most important production readiness checks?"

5. "How can you ensure type safety across a large team?"

## Assessment

### Formative Assessment (During Session)

**Check for Understanding:**
- "How do you test a Zod schema?"
- "What is a type guard?"
- "What are the layers of clean architecture?"
- "What's in a production readiness checklist?"

### Summative Assessment (End of Session)

**Part 6 Quiz:**

1. Which of these is NOT a valid test approach?
   a) Unit tests for utilities
   b) Component tests
   c) Type tests (runtime) ✓
   d) Integration tests

2. What is the purpose of a type guard?
   a) To check types at compile time
   b) To narrow types at runtime ✓
   c) To convert types
   d) To create types

3. Which layer of clean architecture contains business logic?
   a) Domain ✓
   b) Application
   c) Infrastructure
   d) Presentation

4. What is dependency injection used for?
   a) Creating dependencies
   b) Decoupling components ✓
   c) Testing
   d) Configuration

5. Which of these is part of production readiness?
   a) Type checking ✓
   b) Color schemes
   c) Font selection
   d) Layout design

6. What is a health check?
   a) A code review
   b) An endpoint that verifies system status ✓
   c) A test suite
   d) A build step

7. How do you test a React component?
   a) With unit tests
   b) With component tests ✓
   c) With integration tests
   d) With E2E tests

8. When should you use advanced architecture patterns?
   a) Always
   b) Never
   c) When the project size warrants it ✓
   d) Only for enterprises

---

# Appendices

## Appendix A: Sample Syllabus

### 5-Day Intensive Training

**Day 1: Foundations**
- AM: Part 1 - Core Mental Model
- PM: Part 1 - Foundations (continued)

**Day 2: Reusability**
- AM: Part 2 - Objects and Generics
- PM: Part 2 - Utility Types and Configuration

**Day 3: Advanced**
- AM: Part 3 - Advanced Types
- PM: Part 3 - Type-Level Programming

**Day 4: React & Next.js**
- AM: Part 4 - React Integration
- PM: Part 5 - Next.js Integration

**Day 5: Production**
- AM: Part 6 - Testing and Debugging
- PM: Part 6 - Architecture and Capstone

### 8-Week Evening Course

**Week 1:** Part 1 - Core Mental Model
**Week 2:** Part 1 - Foundations (continued)
**Week 3:** Part 2 - Objects and Interfaces
**Week 4:** Part 2 - Generics and Utility Types
**Week 5:** Part 3 - Advanced Types
**Week 6:** Part 4 - React Integration
**Week 7:** Part 5 - Next.js Integration
**Week 8:** Part 6 - Production Ready

---

## Appendix B: Assessment Rubrics

### Code Quality Rubric

| Criteria | Excellent | Good | Needs Improvement |
|----------|-----------|------|-------------------|
| Types | All types explicit and correct | Most types explicit | Types missing or incorrect |
| Generics | Properly used and constrained | Used but may be unconstrained | Misused or missing |
| Narrowing | All cases handled | Most cases handled | Cases missed |
| Testing | Comprehensive tests | Good test coverage | Limited or no tests |
| Architecture | Clean separation | Mostly separated | Mixed concerns |

### Project Rubric

| Criteria | Excellent | Good | Needs Improvement |
|----------|-----------|------|-------------------|
| Implementation | Complete and correct | Mostly complete | Partial implementation |
| Type Safety | Fully typed, no `any` | Mostly typed | Many `any` usage |
| Testing | Tests for all features | Tests for core features | Limited tests |
| Performance | Optimized | Acceptable | Needs optimization |
| Documentation | Comprehensive | Adequate | Limited or missing |

---

## Appendix C: Troubleshooting Guide

### Common TypeScript Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `property does not exist` | Accessing property that doesn't exist | Check type definition, use type guard |
| `Argument of type X not assignable` | Wrong type passed to function | Convert or cast the value |
| `Object is possibly null/undefined` | Accessing property on nullable value | Use optional chaining or check |
| `Variable is used before assignment` | Using variable before initialized | Initialize it first |
| `This condition will always return true` | Impossible condition | Remove or fix the condition |

### Testing Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| `not in document` | Query not finding element | Check rendering, use correct query |
| `async tests` | Not waiting for updates | Use `waitFor` or `findBy` |
| `mock not called` | Mock not properly set up | Check mock implementation |
| `act warnings` | State updates not wrapped | Use `act` or `fireEvent` |

### Next.js Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| `Server Component error` | Using client-only code | Add `'use client'` |
| `Build fails` | TypeScript errors | Fix type errors |
| `Environment variable missing` | Not set in .env.local | Add to environment |
| `Page not found` | Wrong file path | Check file naming and location |

---

## Appendix D: Additional Resources

### Official Documentation

- **TypeScript:** https://www.typescriptlang.org/docs/
- **React TypeScript:** https://react.dev/learn/typescript
- **Next.js TypeScript:** https://nextjs.org/docs/app/building-your-application/configuring/typescript
- **Prisma TypeScript:** https://www.prisma.io/docs/concepts/components/prisma-client/type-safety

### Books

- "Programming TypeScript" - Boris Cherny
- "Effective TypeScript" - Dan Vanderkam
- "TypeScript Design Patterns" - Vilic Vane

### Tools

- **VS Code:** Best TypeScript editor
- **TypeScript Playground:** Try TypeScript online
- **ESLint with TypeScript:** Code quality
- **Prettier:** Code formatting

### Communities

- **TypeScript Discord:** https://discord.gg/typescript
- **React Discord:** https://discord.gg/reactjs
- **Stack Overflow:** #typescript
- **Reddit:** r/typescript

---

## Appendix E: Trainer Notes

### Before the Course

1. **Prepare the Environment:**
   - Set up the sample project
   - Test all code examples
   - Verify student setup instructions

2. **Know Your Students:**
   - Review their experience levels
   - Adjust pace accordingly
   - Prepare extra examples for slower students

3. **Prepare Materials:**
   - Slides
   - Code examples
   - Exercise solutions
   - Assessment materials

### During the Course

1. **Encourage Questions:**
   - Create a safe learning environment
   - Address misconceptions early
   - Use "I don't know, let's find out together"

2. **Keep Engagement High:**
   - Mix lecture with exercises
   - Use real-world examples
   - Connect to student experiences

3. **Check Understanding:**
   - Ask clarifying questions
   - Use "teach me" exercises
   - Watch for confusion cues

### After the Course

1. **Provide Resources:**
   - Slides and code examples
   - Additional reading
   - Practice problems

2. **Follow Up:**
   - Send a recap email
   - Share additional resources
   - Offer office hours

3. **Collect Feedback:**
   - What was most helpful?
   - What was least helpful?
   - What should be added or removed?

### Pro Tips

1. **Start With Why:** Always explain why a concept matters before teaching it.

2. **Use Analogies:** Complex concepts become simple with good analogies.

3. **Code Live:** Writing code live shows your thought process.

4. **Make Mistakes On Purpose:** Show how to debug and fix errors.

5. **Connect to Real World:** Relate concepts to actual development scenarios.

6. **Let Students Drive:** Have students solve problems while you guide.

7. **Pace Yourself:** Watch for signs of fatigue and adjust accordingly.

---

**End of Trainer Guide**

---

*This trainer guide provides everything you need to deliver the Mastering TypeScript course. Use it alongside the student workbook, student notes, and presentation slides for a complete teaching package.*
