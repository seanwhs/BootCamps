# Primer 1: JavaScript, TypeScript, and React Foundations

This primer prepares you for the code used throughout the LaunchPad series.

You do not need to memorize every syntax rule before beginning Next.js. The goal is to recognize the building blocks you will see repeatedly:

- Variables
- Functions
- Objects and arrays
- Modules and imports
- Async code
- TypeScript types
- React components
- JSX
- Props
- Rendering lists
- Events and state

---

## 1. Variables

A variable gives a name to a value.

```ts
const projectName = "Website redesign";
```

Use `const` when the variable reference should not be reassigned.

```ts
const taskCount = 4;
```

This is invalid:

```ts
const taskCount = 4;

taskCount = 5;
```

Use `let` only when a variable must be reassigned.

```ts
let completedTaskCount = 0;

completedTaskCount = 1;
```

In LaunchPad, prefer `const` by default.

---

## 2. Strings, Numbers, and Booleans

### String

Text values use quotes:

```ts
const projectName = "LaunchPad";
const description = "A project management application.";
```

### Number

Numbers do not use quotes:

```ts
const taskCount = 12;
const completionPercentage = 50;
```

### Boolean

A boolean is either `true` or `false`.

```ts
const isAuthenticated = true;
const isArchived = false;
```

---

## 3. Template Strings

A template string lets you insert values into text.

```ts
const projectName = "Website redesign";
const message = `Welcome to ${projectName}.`;

console.log(message);
```

Output:

```text
Welcome to Website redesign.
```

LaunchPad uses template strings for values such as project URLs:

```ts
const projectId = "10000000-0000-4000-8000-000000000001";

const projectUrl = `/projects/${projectId}`;
```

Result:

```text
/projects/10000000-0000-4000-8000-000000000001
```

---

## 4. Objects

An object groups related values.

```ts
const project = {
  id: "project-1",
  name: "Website redesign",
  status: "ACTIVE",
  taskCount: 4,
};
```

Read an object property with dot notation:

```ts
console.log(project.name);
```

Output:

```text
Website redesign
```

You can also use bracket notation:

```ts
console.log(project["status"]);
```

Usually, dot notation is easier to read:

```ts
project.status;
```

---

## 5. Arrays

An array stores an ordered collection of values.

```ts
const projectNames = [
  "Website redesign",
  "Mobile application",
  "Documentation hub",
];
```

Read the first item:

```ts
console.log(projectNames[0]);
```

Output:

```text
Website redesign
```

Arrays can contain objects:

```ts
const projects = [
  {
    id: "project-1",
    name: "Website redesign",
    status: "ACTIVE",
  },
  {
    id: "project-2",
    name: "Mobile application",
    status: "PLANNED",
  },
];
```

Read one project:

```ts
console.log(projects[1].name);
```

Output:

```text
Mobile application
```

---

## 6. Functions

A function groups reusable instructions.

```ts
function formatProjectName(name: string): string {
  return name.trim();
}
```

Call it:

```ts
const formattedName = formatProjectName("  Website redesign  ");

console.log(formattedName);
```

Output:

```text
Website redesign
```

This function:

1. Receives a `name`.
2. Removes extra whitespace with `.trim()`.
3. Returns the cleaned result.

---

## 7. Arrow Functions

Arrow functions are another way to write functions.

```ts
const formatProjectName = (name: string): string => {
  return name.trim();
};
```

For short functions, the return can be implicit:

```ts
const formatProjectName = (name: string): string =>
  name.trim();
```

You will often see arrow functions inside array methods and event handlers.

Example:

```ts
const projectNames = [
  "Website redesign",
  "Mobile application",
];

const uppercaseNames = projectNames.map((name) =>
  name.toUpperCase(),
);
```

Result:

```ts
[
  "WEBSITE REDESIGN",
  "MOBILE APPLICATION",
]
```

---

## 8. Array Methods

### `map`

`map` transforms every item into a new array.

```ts
const projects = [
  {
    name: "Website redesign",
    status: "ACTIVE",
  },
  {
    name: "Mobile application",
    status: "PLANNED",
  },
];

const projectNames = projects.map((project) => project.name);

console.log(projectNames);
```

Output:

```ts
[
  "Website redesign",
  "Mobile application",
]
```

React commonly uses `map` to render lists.

---

### `filter`

`filter` keeps only items that match a condition.

```ts
const activeProjects = projects.filter(
  (project) => project.status === "ACTIVE",
);

console.log(activeProjects);
```

Output:

```ts
[
  {
    name: "Website redesign",
    status: "ACTIVE",
  },
]
```

LaunchPad uses this idea for client-side text filtering.

---

### `find`

`find` returns the first item matching a condition.

```ts
const project = projects.find(
  (candidate) => candidate.name === "Mobile application",
);

console.log(project);
```

Output:

```ts
{
  name: "Mobile application",
  status: "PLANNED",
}
```

If no match exists, `find` returns:

```ts
undefined
```

That is why production code checks for missing values.

```ts
if (!project) {
  throw new Error("Project not found.");
}
```

---

### `reduce`

`reduce` combines an array into one value.

```ts
const taskCounts = [4, 2, 3];

const totalTaskCount = taskCounts.reduce(
  (total, taskCount) => total + taskCount,
  0,
);

console.log(totalTaskCount);
```

Output:

```text
9
```

LaunchPad uses `reduce` to calculate dashboard totals.

---

## 9. Conditions

An `if` statement chooses behavior based on a condition.

```ts
const status = "ACTIVE";

if (status === "ACTIVE") {
  console.log("This project is in progress.");
} else {
  console.log("This project is not active.");
}
```

Output:

```text
This project is in progress.
```

The triple equals operator:

```ts
===
```

checks both value and type.

Use it instead of loose equality:

```ts
==
```

---

## 10. Optional Values and `null`

Some values may be absent.

```ts
type Task = {
  title: string;
  dueDate: string | null;
};

const task: Task = {
  title: "Review accessibility",
  dueDate: null,
};
```

This type means:

```ts
string | null
```

The due date may be a string or `null`.

Check before using it:

```ts
if (task.dueDate) {
  console.log(`Due on ${task.dueDate}`);
} else {
  console.log("No due date.");
}
```

Output:

```text
No due date.
```

---

## 11. TypeScript Types

TypeScript adds type information to JavaScript.

A type describes the allowed shape of a value.

```ts
type Project = {
  id: string;
  name: string;
  description: string;
  status: "PLANNED" | "ACTIVE" | "COMPLETED";
  taskCount: number;
  completedTaskCount: number;
};
```

Create a value matching that type:

```ts
const project: Project = {
  id: "project-1",
  name: "Website redesign",
  description: "Improve website performance and accessibility.",
  status: "ACTIVE",
  taskCount: 4,
  completedTaskCount: 2,
};
```

This is invalid:

```ts
const invalidProject: Project = {
  id: "project-2",
  name: "Broken project",
  description: "This has an invalid status.",
  status: "STARTED",
  taskCount: 0,
  completedTaskCount: 0,
};
```

TypeScript reports an error because:

```text
STARTED
```

is not one of the allowed statuses.

---

## 12. Union Types

A union type allows one of several values.

```ts
type ProjectStatus =
  | "PLANNED"
  | "ACTIVE"
  | "COMPLETED";
```

This is useful when values must come from a controlled set.

```ts
const status: ProjectStatus = "ACTIVE";
```

LaunchPad uses this approach for project statuses, task statuses, priorities, form states, and API error codes.

---

## 13. Type Inference

TypeScript can often infer a type automatically.

```ts
const projectName = "Website redesign";
```

TypeScript knows this is a string.

```ts
const taskCount = 4;
```

TypeScript knows this is a number.

You do not need to annotate every local variable.

Add explicit types where they clarify a contract:

```ts
function calculateProgress(
  completedTaskCount: number,
  taskCount: number,
): number {
  if (taskCount === 0) {
    return 0;
  }

  return Math.round(
    (completedTaskCount / taskCount) * 100,
  );
}
```

---

## 14. `type` Versus `interface`

Both can describe object shapes.

Using `type`:

```ts
type User = {
  id: string;
  name: string;
  email: string;
};
```

Using `interface`:

```ts
interface User {
  id: string;
  name: string;
  email: string;
}
```

Both are valid.

LaunchPad primarily uses `type` because it also works naturally with unions and derived types:

```ts
type ActionStatus =
  | "idle"
  | "success"
  | "error";
```

Consistency matters more than treating one option as universally superior.

---

## 15. Modules: `export` and `import`

A module is a file that exports values for other files to use.

### Export a function

```ts
export function formatProjectStatus(
  status: string,
): string {
  return status.toLowerCase();
}
```

### Import the function

```ts
import { formatProjectStatus } from "@/lib/project-types";
```

Then use it:

```ts
const label = formatProjectStatus("ACTIVE");

console.log(label);
```

Output:

```text
active
```

### Default exports

A file can also have one default export.

```ts
export default function HomePage() {
  return <main>Home</main>;
}
```

Import it without braces:

```ts
import HomePage from "./page";
```

Next.js page and layout files commonly use default exports.

---

## 16. Async Functions and Promises

An async operation takes time to finish.

Examples:

- Querying a database
- Calling an API
- Reading a file
- Verifying a session

An `async` function returns a Promise.

```ts
async function getProjectName(): Promise<string> {
  return "Website redesign";
}
```

Use `await` to wait for the result:

```ts
const projectName = await getProjectName();

console.log(projectName);
```

In Next.js Server Components, this is common:

```tsx
export default async function ProjectsPage() {
  const user = await requireUser();
  const projects = await getProjects(user.id);

  return (
    <main>
      <h1>Projects</h1>
      <p>{projects.length} projects found.</p>
    </main>
  );
}
```

---

## 17. Parallel Async Work

Independent operations can begin together.

Sequential version:

```ts
const project = await getProjectById(
  userId,
  projectId,
);

const tasks = await getTasksForProject(
  userId,
  projectId,
);
```

Parallel version:

```ts
const projectPromise = getProjectById(
  userId,
  projectId,
);

const tasksPromise = getTasksForProject(
  userId,
  projectId,
);

const [project, tasks] = await Promise.all([
  projectPromise,
  tasksPromise,
]);
```

Use parallel work only when neither operation depends on the other.

---

# 18. React Components

A React component is a function that returns user interface markup.

```tsx
export function WelcomeMessage() {
  return <h1>Welcome to LaunchPad</h1>;
}
```

Use it inside another component:

```tsx
export function HomePage() {
  return (
    <main>
      <WelcomeMessage />
    </main>
  );
}
```

Components begin with uppercase letters:

```tsx
WelcomeMessage
ProjectCard
TaskList
```

Lowercase names are interpreted as HTML elements:

```tsx
<div />
<button />
<main />
```

---

## 19. JSX

JSX is syntax that looks like HTML inside TypeScript.

```tsx
const heading = <h1>LaunchPad</h1>;
```

It becomes React element instructions during the build.

JSX rules include:

### Return one parent element

Correct:

```tsx
return (
  <main>
    <h1>Projects</h1>
    <p>Manage your work.</p>
  </main>
);
```

Incorrect:

```tsx
return (
  <h1>Projects</h1>
  <p>Manage your work.</p>
);
```

If you do not need an actual wrapper element, use a fragment:

```tsx
return (
  <>
    <h1>Projects</h1>
    <p>Manage your work.</p>
  </>
);
```

### Use `className`, not `class`

```tsx
<div className="project-card">
  Project content
</div>
```

### JavaScript expressions use braces

```tsx
const projectName = "Website redesign";

return <h1>{projectName}</h1>;
```

---

## 20. Component Props

Props are inputs passed into a component.

```tsx
type ProjectHeadingProps = {
  name: string;
};

export function ProjectHeading({
  name,
}: ProjectHeadingProps) {
  return <h1>{name}</h1>;
}
```

Use it:

```tsx
<ProjectHeading name="Website redesign" />
```

The component receives:

```ts
{
  name: "Website redesign",
}
```

Props should be treated as read-only input.

---

## 21. The `children` Prop

`children` represents content placed between a component’s opening and closing tags.

```tsx
import type { ReactNode } from "react";

type PanelProps = {
  children: ReactNode;
};

export function Panel({
  children,
}: PanelProps) {
  return (
    <section className="panel">
      {children}
    </section>
  );
}
```

Use it:

```tsx
<Panel>
  <h2>Project summary</h2>
  <p>Four tasks remain.</p>
</Panel>
```

Layouts use `children` to render their nested pages.

---

## 22. Rendering Lists in React

Use `map` to render one component for each item.

```tsx
type Project = {
  id: string;
  name: string;
};

type ProjectListProps = {
  projects: readonly Project[];
};

export function ProjectList({
  projects,
}: ProjectListProps) {
  return (
    <ul>
      {projects.map((project) => (
        <li key={project.id}>
          {project.name}
        </li>
      ))}
    </ul>
  );
}
```

The `key` helps React track each item across updates.

Use stable identifiers:

```tsx
key={project.id}
```

Avoid array indexes when items can be added, removed, reordered, or filtered:

```tsx
key={index}
```

---

## 23. Conditional Rendering

Conditional rendering displays different UI based on a condition.

```tsx
type ProjectStatusProps = {
  isComplete: boolean;
};

export function ProjectStatus({
  isComplete,
}: ProjectStatusProps) {
  if (isComplete) {
    return <p>Project complete.</p>;
  }

  return <p>Project still has work remaining.</p>;
}
```

You can also use a ternary:

```tsx
<p>
  {isComplete
    ? "Project complete."
    : "Project still has work remaining."}
</p>
```

For optional content:

```tsx
{errorMessage ? (
  <p role="alert">{errorMessage}</p>
) : null}
```

---

## 24. Client Component State

Browser interaction often uses `useState`.

```tsx
"use client";

import { useState } from "react";

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button
      type="button"
      onClick={() => {
        setCount((currentCount) => currentCount + 1);
      }}
    >
      Count: {count}
    </button>
  );
}
```

This component needs `"use client"` because it uses:

```tsx
useState
onClick
```

State updates cause React to render the component again with the new value.

---

## 25. Event Handlers

An event handler runs after user interaction.

```tsx
<button
  type="button"
  onClick={() => {
    console.log("Button selected.");
  }}
>
  Select
</button>
```

Form input example:

```tsx
<input
  value={query}
  onChange={(event) => {
    setQuery(event.target.value);
  }}
/>
```

Event handlers require Client Components.

---

## 26. Server Components and Client Components Summary

| Requirement | Server Component | Client Component |
|---|---:|---:|
| Database query | Yes | No |
| Read environment secret | Yes | No |
| Read session cookie | Yes | No |
| Render static content | Yes | Yes |
| `useState` | No | Yes |
| `onClick` | No | Yes |
| Clipboard API | No | Yes |
| Browser URL hook | No | Yes |
| Server Action call through form | Yes | Yes |
| Private authorization logic | Yes | No |

A good default:

```text
Start with a Server Component.
Add a small Client Component only for required browser behavior.
```

---

## 27. Primer Verification Exercises

Create a temporary file outside your LaunchPad source tree.

### `primer-exercise.ts`

```ts
type ProjectStatus =
  | "PLANNED"
  | "ACTIVE"
  | "COMPLETED";

type Project = {
  id: string;
  name: string;
  status: ProjectStatus;
  taskCount: number;
  completedTaskCount: number;
};

function calculateProgress(
  project: Project,
): number {
  if (project.taskCount === 0) {
    return 0;
  }

  return Math.round(
    (project.completedTaskCount / project.taskCount) * 100,
  );
}

const projects: Project[] = [
  {
    id: "project-1",
    name: "Website redesign",
    status: "ACTIVE",
    taskCount: 4,
    completedTaskCount: 2,
  },
  {
    id: "project-2",
    name: "Documentation hub",
    status: "COMPLETED",
    taskCount: 3,
    completedTaskCount: 3,
  },
  {
    id: "project-3",
    name: "Mobile application",
    status: "PLANNED",
    taskCount: 2,
    completedTaskCount: 0,
  },
];

const activeProjects = projects.filter(
  (project) => project.status === "ACTIVE",
);

const projectSummaries = projects.map((project) => {
  const progress = calculateProgress(project);

  return `${project.name}: ${progress}% complete`;
});

console.log("Active projects:", activeProjects);
console.log("Project summaries:", projectSummaries);
```

Run it with a TypeScript runner if you have one installed, or copy it into a small TypeScript playground.

Expected summary output includes:

```text
Website redesign: 50% complete
Documentation hub: 100% complete
Mobile application: 0% complete
```

---

## 28. Primer Completion Checklist

Before returning to the main series, you should recognize:

- [ ] `const` and `let`
- [ ] Strings, numbers, and booleans
- [ ] Objects and arrays
- [ ] Functions and arrow functions
- [ ] `map`, `filter`, `find`, and `reduce`
- [ ] `if` statements and conditional rendering
- [ ] TypeScript object types
- [ ] Union types
- [ ] `import` and `export`
- [ ] Async functions and `await`
- [ ] React components
- [ ] JSX
- [ ] Props and `children`
- [ ] Rendering lists with stable `key` values
- [ ] Client-side state with `useState`
- [ ] Why Server Components are the default in Next.js
