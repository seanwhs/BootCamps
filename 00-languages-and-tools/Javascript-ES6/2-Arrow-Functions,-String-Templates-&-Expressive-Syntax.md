# Part 2: Arrow Functions, String Templates & Expressive Syntax

Part 1 focused on safely storing and extracting data. In this part, you will make that code more expressive and readable.

You will build and run examples for:

- Arrow functions
- Implicit returns
- Lexical `this`
- Template literals
- Multiline strings
- Tagged template literals
- Enhanced object literals
- Shorthand properties
- Computed property names
- Concise object methods

---

## Step 1: Extend the Project Scripts

### The Target

Update `package.json` so you can run each Part 2 module independently.

### The Concept

A script in `package.json` is a named terminal shortcut. Instead of remembering a long `node` command, you give the command a clear name such as:

```bash
npm run part:2:arrows
```

Think of scripts as labeled buttons on a control panel: each button runs one predictable task.

### The Implementation

Replace your existing `package.json` with the following complete version.

### `package.json`

```json
{
  "name": "modern-javascript-toolkit",
  "version": "1.0.0",
  "private": true,
  "description": "Runnable examples for learning modern ECMAScript features.",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "part:1:variables": "node src/part-1-syntax-ergonomics/variables.js",
    "part:1:destructuring": "node src/part-1-syntax-ergonomics/destructuring.js",
    "part:1:rest-spread": "node src/part-1-syntax-ergonomics/rest-spread.js",
    "part:2:arrows": "node src/part-2-expressive-syntax/arrow-functions.js",
    "part:2:templates": "node src/part-2-expressive-syntax/template-literals.js",
    "part:2:objects": "node src/part-2-expressive-syntax/enhanced-objects.js"
  },
  "engines": {
    "node": ">=22.0.0"
  }
}
```

Now create the directory for this part:

```bash
mkdir -p src/part-2-expressive-syntax
```

> On Windows PowerShell:

```powershell
mkdir src\part-2-expressive-syntax
```

### The Verification

Run:

```bash
npm run
```

Confirm the output lists these new scripts:

```text
part:2:arrows
part:2:templates
part:2:objects
```

The scripts will not run successfully until you create their corresponding files in the next steps.

---

## Step 2: Write Functions with Arrow Syntax

### The Target

Create `arrow-functions.js` to learn arrow function syntax, implicit returns, and the critical difference between arrow functions and traditional functions when using `this`.

### The Concept

A function is a reusable instruction card. An arrow function is a more compact way to write many instruction cards.

Traditional function:

```js
function double(value) {
  return value * 2;
}
```

Arrow function:

```js
const double = (value) => {
  return value * 2;
};
```

When the function body contains only one expression, you can use an **implicit return**. This means JavaScript automatically returns the expression:

```js
const double = (value) => value * 2;
```

Arrow functions also handle `this` differently.

`this` usually means “the object currently responsible for this function call.” Traditional functions determine `this` at call time. Arrow functions do not create their own `this`; instead, they keep the `this` value from the place where they were created. This is called **lexical `this`**.

Think of lexical `this` like a child carrying their home address with them. No matter where they go, they still know the address where they were created.

### The Implementation

Create this file.

### `src/part-2-expressive-syntax/arrow-functions.js`

```js
/**
 * Part 2: Arrow functions, implicit returns, and lexical this.
 *
 * Run directly:
 * node src/part-2-expressive-syntax/arrow-functions.js
 */

/**
 * Prints a readable console section heading.
 *
 * @param {string} title - The heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('traditional functions and arrow functions');

/**
 * Returns a normalized display name.
 *
 * @param {string} name - A raw user-provided name.
 * @returns {string} A trimmed name.
 */
function normalizeNameTraditional(name) {
  return name.trim();
}

const normalizeNameArrow = (name) => {
  return name.trim();
};

const normalizeNameImplicit = (name) => name.trim();

console.log({
  traditional: normalizeNameTraditional('  Ava Patel  '),
  arrowWithBlock: normalizeNameArrow('  Mina Chen  '),
  arrowWithImplicitReturn: normalizeNameImplicit('  Noah Kim  ')
});

printSection('single parameter parentheses are optional');

const squareWithParentheses = (value) => value ** 2;
const squareWithoutParentheses = value => value ** 2;

console.log({
  squareWithParentheses: squareWithParentheses(5),
  squareWithoutParentheses: squareWithoutParentheses(5)
});

printSection('zero or multiple parameters need parentheses');

const createAnonymousUser = () => ({
  id: crypto.randomUUID(),
  role: 'guest'
});

const add = (firstValue, secondValue) => firstValue + secondValue;

console.log({
  anonymousUser: createAnonymousUser(),
  sum: add(12, 8)
});

printSection('returning object literals with implicit returns');

/**
 * Builds a compact public user profile.
 *
 * Parentheses are required around the object literal. Without them,
 * JavaScript would interpret the braces as a function body instead.
 *
 * @param {{ id: string, displayName: string, role: string }} user - Source user.
 * @returns {{ id: string, label: string }} Public profile data.
 */
const createPublicProfile = ({ id, displayName, role }) => ({
  id,
  label: `${displayName} (${role})`
});

console.log(
  createPublicProfile({
    id: 'user_1001',
    displayName: 'Ava Patel',
    role: 'editor'
  })
);

printSection('array methods commonly use arrow callbacks');

const tasks = [
  {
    id: 'task_1',
    title: 'Review pull request',
    completed: true
  },
  {
    id: 'task_2',
    title: 'Write release notes',
    completed: false
  },
  {
    id: 'task_3',
    title: 'Deploy application',
    completed: true
  }
];

const completedTaskTitles = tasks
  .filter((task) => task.completed)
  .map((task) => task.title);

console.log(completedTaskTitles);

printSection('lexical this with an asynchronous callback');

class ProgressTracker {
  /**
   * @param {string} projectName - The project being tracked.
   */
  constructor(projectName) {
    this.projectName = projectName;
    this.completedSteps = 0;
  }

  /**
   * Schedules an update and safely uses this from the class instance.
   *
   * The arrow callback inherits this from recordCompletedStep, where this
   * correctly refers to the ProgressTracker instance.
   *
   * @returns {Promise<string>} A message describing the update.
   */
  recordCompletedStep() {
    return new Promise((resolve) => {
      setTimeout(() => {
        this.completedSteps += 1;

        resolve(
          `${this.projectName}: completed steps = ${this.completedSteps}`
        );
      }, 10);
    });
  }
}

const tracker = new ProgressTracker('Modern JavaScript Toolkit');

console.log(await tracker.recordCompletedStep());

printSection('why regular callbacks can lose this');

class NotificationCenter {
  /**
   * @param {string} channelName - A human-readable channel label.
   */
  constructor(channelName) {
    this.channelName = channelName;
  }

  /**
   * Creates a callback that retains access to this.channelName.
   *
   * @returns {(message: string) => string} A formatter callback.
   */
  createSafeFormatter() {
    return (message) => `[${this.channelName}] ${message}`;
  }
}

const notificationCenter = new NotificationCenter('deployments');
const formatNotification = notificationCenter.createSafeFormatter();

console.log(formatNotification('Release version 2.4.0 is ready.'));

printSection('when not to use arrow functions as object methods');

const project = {
  name: 'Modern JavaScript Toolkit',

  // Concise method syntax gives this the object that received the method call.
  getLabel() {
    return `Project: ${this.name}`;
  },

  // Arrow functions inherit this from their surrounding module scope.
  // They should not normally be used when a method needs the object as this.
  getIncorrectArrowLabel: () => `Project: ${this?.name ?? 'unknown'}`
};

console.log({
  correctMethodResult: project.getLabel(),
  incorrectArrowMethodResult: project.getIncorrectArrowLabel()
});

console.log('\nArrow function examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:2:arrows
```

Expected output includes:

```text
--- traditional functions and arrow functions ---
{
  traditional: 'Ava Patel',
  arrowWithBlock: 'Mina Chen',
  arrowWithImplicitReturn: 'Noah Kim'
}

--- returning object literals with implicit returns ---
{ id: 'user_1001', label: 'Ava Patel (editor)' }

--- lexical this with an asynchronous callback ---
Modern JavaScript Toolkit: completed steps = 1

--- when not to use arrow functions as object methods ---
{
  correctMethodResult: 'Project: Modern JavaScript Toolkit',
  incorrectArrowMethodResult: 'Project: unknown'
}

Arrow function examples completed successfully.
```

The exact UUID in the anonymous-user output will differ every time. That is expected.

---

## Step 3: Build Readable Strings with Template Literals

### The Target

Create `template-literals.js` to use template literals for interpolation, multiline text, and safe tagged-template processing.

### The Concept

A **template literal** is a string surrounded by backticks instead of single or double quotes:

```js
const message = `Welcome, Ava!`;
```

It can insert JavaScript values with `${...}`:

```js
const name = 'Ava';
const message = `Welcome, ${name}!`;
```

This is easier to read than older string concatenation:

```js
const message = 'Welcome, ' + name + '!';
```

A **tagged template literal** passes the static portions and inserted values to a function. This lets you standardize formatting, escaping, or validation.

Think of a tagged template as a quality-control worker standing beside a label printer: every label is inspected and formatted before it leaves the factory.

### The Implementation

Create this file.

### `src/part-2-expressive-syntax/template-literals.js`

```js
/**
 * Part 2: Template literals and tagged template literals.
 *
 * Run directly:
 * node src/part-2-expressive-syntax/template-literals.js
 */

/**
 * Prints a readable console section heading.
 *
 * @param {string} title - The heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('basic interpolation');

const displayName = 'Ava Patel';
const activeProjects = 3;

const dashboardMessage = `Welcome back, ${displayName}. You have ${activeProjects} active projects.`;

console.log(dashboardMessage);

printSection('expressions inside template literals');

const subtotalCents = 4_999;
const taxRate = 0.2;
const taxCents = Math.round(subtotalCents * taxRate);
const totalCents = subtotalCents + taxCents;

const orderSummary = `Subtotal: $${(subtotalCents / 100).toFixed(2)}
Tax: $${(taxCents / 100).toFixed(2)}
Total: $${(totalCents / 100).toFixed(2)}`;

console.log(orderSummary);

printSection('multiline strings');

const releaseNotes = `
Release 2.4.0

Highlights:
- Added modern array utilities.
- Improved error messages.
- Updated dependency documentation.
`.trim();

console.log(releaseNotes);

printSection('conditional text inside a template literal');

const isVerified = true;

const verificationMessage = `Account status: ${
  isVerified ? 'Verified' : 'Verification required'
}.`;

console.log(verificationMessage);

printSection('escaping HTML for text contexts');

/**
 * Escapes characters that could be interpreted as HTML markup.
 *
 * This function is appropriate when inserting untrusted text into an HTML
 * text context. It is not a complete security solution for every HTML,
 * URL, CSS, or JavaScript context; each context has different rules.
 *
 * @param {unknown} value - Value to convert into safe HTML text.
 * @returns {string} Escaped text.
 */
function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

/**
 * Formats a template literal while escaping every interpolated value.
 *
 * @param {TemplateStringsArray} strings - Static literal segments.
 * @param {...unknown} values - Interpolated values.
 * @returns {string} A safely assembled HTML-text string.
 */
function htmlText(strings, ...values) {
  return strings.reduce((result, stringSegment, index) => {
    const interpolatedValue =
      index < values.length ? escapeHtml(values[index]) : '';

    return `${result}${stringSegment}${interpolatedValue}`;
  }, '');
}

const untrustedDisplayName = '<img src=x onerror="alert(\'unsafe\')">';
const escapedGreeting = htmlText`<p>Welcome, ${untrustedDisplayName}.</p>`;

console.log(escapedGreeting);

printSection('a tagged template for readable log labels');

/**
 * Converts values into displayable log text.
 *
 * @param {unknown} value - Value to format.
 * @returns {string} Stable text for logging.
 */
function formatLogValue(value) {
  if (typeof value === 'string') {
    return `"${value}"`;
  }

  return JSON.stringify(value);
}

/**
 * Creates structured, readable messages from a template literal.
 *
 * @param {TemplateStringsArray} strings - Static literal segments.
 * @param {...unknown} values - Interpolated values.
 * @returns {string} A formatted diagnostic message.
 */
function diagnostic(strings, ...values) {
  return strings.reduce((result, stringSegment, index) => {
    const formattedValue =
      index < values.length ? formatLogValue(values[index]) : '';

    return `${result}${stringSegment}${formattedValue}`;
  }, '[diagnostic] ');
}

const projectId = 'project_3001';
const taskCount = 12;
const isDeploymentReady = false;

console.log(
  diagnostic`Project ${projectId} contains ${taskCount} tasks. Deployment ready: ${isDeploymentReady}.`
);

printSection('String.raw preserves backslashes');

/**
 * String.raw is useful when representing paths, regular expressions, or
 * documentation where backslash characters should remain visible.
 */
const windowsExamplePath = String.raw`C:\projects\modern-javascript-toolkit\src`;

console.log(windowsExamplePath);

console.log('\nTemplate literal examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:2:templates
```

Expected output includes:

```text
--- basic interpolation ---
Welcome back, Ava Patel. You have 3 active projects.

--- expressions inside template literals ---
Subtotal: $49.99
Tax: $10.00
Total: $59.99

--- escaping HTML for text contexts ---
<p>Welcome, &lt;img src=x onerror=&quot;alert(&#39;unsafe&#39;)&quot;&gt;.</p>

--- a tagged template for readable log labels ---
[diagnostic] Project "project_3001" contains 12 tasks. Deployment ready: false.

Template literal examples completed successfully.
```

---

## Step 4: Create Flexible Objects with Enhanced Object Literals

### The Target

Create `enhanced-objects.js` to use property shorthand, computed property names, concise methods, and object composition.

### The Concept

An object literal is a convenient way to build an object:

```js
const user = {
  name: 'Ava',
  role: 'editor'
};
```

Modern JavaScript lets you write these objects with less repeated text.

### Property shorthand

When a variable name and property name match:

```js
const name = 'Ava';

const user = { name };
```

This is equivalent to:

```js
const user = { name: name };
```

### Computed property names

A computed property name uses brackets:

```js
const fieldName = 'email';

const user = {
  [fieldName]: 'ava@example.com'
};
```

This is useful when a property name is determined at runtime.

### Concise methods

Instead of:

```js
const user = {
  greet: function greet() {
    return 'Hello';
  }
};
```

Use:

```js
const user = {
  greet() {
    return 'Hello';
  }
};
```

### The Implementation

Create this file.

### `src/part-2-expressive-syntax/enhanced-objects.js`

```js
/**
 * Part 2: Enhanced object literals.
 *
 * Run directly:
 * node src/part-2-expressive-syntax/enhanced-objects.js
 */

/**
 * Prints a readable console section heading.
 *
 * @param {string} title - The heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('shorthand properties');

const id = 'user_1001';
const displayName = 'Ava Patel';
const role = 'editor';

// The property names match the variable names, so each can use shorthand.
const user = {
  id,
  displayName,
  role
};

console.log(user);

printSection('shorthand properties in factory functions');

/**
 * Creates a project record.
 *
 * @param {string} id - Stable project identifier.
 * @param {string} name - Project name.
 * @param {string} ownerId - Identifier of the project owner.
 * @returns {{ id: string, name: string, ownerId: string, createdAt: string }}
 */
function createProject(id, name, ownerId) {
  const createdAt = new Date().toISOString();

  return {
    id,
    name,
    ownerId,
    createdAt
  };
}

console.log(
  createProject(
    'project_3001',
    'Modern JavaScript Toolkit',
    'user_1001'
  )
);

printSection('computed property names');

const preferenceKey = 'colorScheme';
const preferenceValue = 'dark';

const preferences = {
  [preferenceKey]: preferenceValue,
  compactMode: true
};

console.log(preferences);

printSection('computed names with dynamic metrics');

const metricPrefix = 'request';
const statusCode = 200;

const metrics = {
  [`${metricPrefix}Count`]: 42,
  [`${metricPrefix}Status_${statusCode}`]: 'success',
  [`${metricPrefix}DurationMilliseconds`]: 183
};

console.log(metrics);

printSection('concise object methods');

const task = {
  id: 'task_1',
  title: 'Review pull request',
  completed: false,

  complete() {
    this.completed = true;

    return `${this.title} is complete.`;
  },

  getSummary() {
    const status = this.completed ? 'completed' : 'pending';

    return `[${this.id}] ${this.title} (${status})`;
  }
};

console.log(task.getSummary());
console.log(task.complete());
console.log(task.getSummary());

printSection('computed method names');

const actionName = 'archive';

const documentRecord = {
  id: 'doc_9001',
  title: 'Engineering Handbook',
  isArchived: false,

  [actionName]() {
    this.isArchived = true;

    return `${this.title} was archived.`;
  }
};

console.log(documentRecord.archive());
console.log(documentRecord);

printSection('object composition with spread');

const auditFields = {
  createdAt: '2026-07-24T10:00:00.000Z',
  updatedAt: '2026-07-24T10:30:00.000Z'
};

const projectFields = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit'
};

const completeProject = {
  ...projectFields,
  ...auditFields,

  getAuditSummary() {
    return `${this.name} was last updated at ${this.updatedAt}.`;
  }
};

console.log(completeProject);
console.log(completeProject.getAuditSummary());

printSection('a practical immutable record update');

/**
 * Updates one field in a user preferences object.
 *
 * The computed property name allows callers to select the field at runtime.
 * The object spread keeps existing fields while returning a new object.
 *
 * @param {Record<string, unknown>} currentPreferences - Existing preferences.
 * @param {string} key - Preference key to change.
 * @param {unknown} value - Replacement preference value.
 * @returns {Record<string, unknown>} Updated preferences.
 */
function updatePreference(currentPreferences, key, value) {
  return {
    ...currentPreferences,
    [key]: value,
    updatedAt: new Date().toISOString()
  };
}

const initialPreferences = {
  colorScheme: 'light',
  fontSize: 'medium',
  emailNotifications: true
};

const revisedPreferences = updatePreference(
  initialPreferences,
  'colorScheme',
  'dark'
);

console.log({
  initialPreferences,
  revisedPreferences,
  areDifferentObjects: initialPreferences !== revisedPreferences
});

console.log('\nEnhanced object literal examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:2:objects
```

Expected output includes:

```text
--- shorthand properties ---
{ id: 'user_1001', displayName: 'Ava Patel', role: 'editor' }

--- computed property names ---
{ colorScheme: 'dark', compactMode: true }

--- concise object methods ---
[task_1] Review pull request (pending)
Review pull request is complete.
[task_1] Review pull request (completed)

--- a practical immutable record update ---
{
  initialPreferences: {
    colorScheme: 'light',
    fontSize: 'medium',
    emailNotifications: true
  },
  revisedPreferences: {
    colorScheme: 'dark',
    fontSize: 'medium',
    emailNotifications: true,
    updatedAt: '...'
  },
  areDifferentObjects: true
}

Enhanced object literal examples completed successfully.
```

The `updatedAt` timestamp will differ on your machine.

---

## Step 5: Integrate Part 2 Concepts into the Toolkit Entry Point

### The Target

Update `src/index.js` so the central program uses Part 1 data techniques together with Part 2 expressive syntax.

### The Concept

This step combines the tools you have learned:

- Destructuring extracts input data.
- Arrow functions transform collections.
- Template literals create readable labels.
- Enhanced object literals build clean result objects.
- Spread syntax produces immutable updates.

Think of the program as an assembly line: each feature does one clear job, and the complete line turns raw project data into a useful dashboard summary.

### The Implementation

Replace the contents of `src/index.js`.

### `src/index.js`

```js
/**
 * Modern JavaScript Toolkit entry point.
 *
 * Run with:
 * npm start
 */

/**
 * Creates a project dashboard model from raw project information.
 *
 * @param {{
 *   project: {
 *     id: string,
 *     name: string,
 *     owner: { displayName: string },
 *     tags?: string[],
 *     tasks?: Array<{
 *       id: string,
 *       title: string,
 *       completed: boolean
 *     }>
 *   },
 *   additionalTags?: string[]
 * }} input - Raw project input.
 * @returns {{
 *   id: string,
 *   name: string,
 *   ownerName: string,
 *   tags: string[],
 *   completedTaskCount: number,
 *   pendingTaskTitles: string[],
 *   label: string,
 *   getStatusMessage: () => string
 * }} Dashboard-ready project data.
 */
const createProjectDashboard = ({
  project: {
    id,
    name,
    owner: { displayName: ownerName },
    tags = [],
    tasks = []
  },
  additionalTags = []
}) => {
  const mergedTags = [...new Set([...tags, ...additionalTags])];

  const completedTaskCount = tasks.filter((task) => task.completed).length;

  const pendingTaskTitles = tasks
    .filter((task) => !task.completed)
    .map((task) => task.title);

  return {
    id,
    name,
    ownerName,
    tags: mergedTags,
    completedTaskCount,
    pendingTaskTitles,
    label: `${name} — owned by ${ownerName}`,

    getStatusMessage() {
      const pendingCount = this.pendingTaskTitles.length;
      const taskWord = pendingCount === 1 ? 'task' : 'tasks';

      return `${this.name}: ${this.completedTaskCount} completed, ${pendingCount} ${taskWord} remaining.`;
    }
  };
};

/**
 * Returns a new dashboard model with one additional tag.
 *
 * @param {{
 *   tags: string[]
 * }} dashboard - Existing dashboard data.
 * @param {string} tag - Tag to add.
 * @returns {object} Updated dashboard data.
 */
const addDashboardTag = (dashboard, tag) => {
  if (dashboard.tags.includes(tag)) {
    return dashboard;
  }

  return {
    ...dashboard,
    tags: [...dashboard.tags, tag]
  };
};

const projectInput = {
  project: {
    id: 'project_3001',
    name: 'Modern JavaScript Toolkit',
    owner: {
      displayName: 'Ava Patel'
    },
    tags: ['javascript', 'learning'],
    tasks: [
      {
        id: 'task_1',
        title: 'Create Part 1 examples',
        completed: true
      },
      {
        id: 'task_2',
        title: 'Create Part 2 examples',
        completed: true
      },
      {
        id: 'task_3',
        title: 'Document collection types',
        completed: false
      }
    ]
  },
  additionalTags: ['es2024', 'javascript']
};

const dashboard = createProjectDashboard(projectInput);
const taggedDashboard = addDashboardTag(dashboard, 'beginner-friendly');

console.log('\n=== Modern JavaScript Toolkit ===\n');

console.log('Project dashboard:');
console.log({
  id: dashboard.id,
  label: dashboard.label,
  tags: dashboard.tags,
  pendingTaskTitles: dashboard.pendingTaskTitles
});

console.log(`\nStatus: ${dashboard.getStatusMessage()}`);

console.log('\nImmutable tag update:');
console.log({
  originalTags: dashboard.tags,
  updatedTags: taggedDashboard.tags,
  isNewObject: dashboard !== taggedDashboard
});

console.log('\nParts 1 and 2 are running successfully.');
```

### The Verification

Run:

```bash
npm start
```

Expected output:

```text
=== Modern JavaScript Toolkit ===

Project dashboard:
{
  id: 'project_3001',
  label: 'Modern JavaScript Toolkit — owned by Ava Patel',
  tags: [ 'javascript', 'learning', 'es2024' ],
  pendingTaskTitles: [ 'Document collection types' ]
}

Status: Modern JavaScript Toolkit: 2 completed, 1 task remaining.

Immutable tag update:
{
  originalTags: [ 'javascript', 'learning', 'es2024' ],
  updatedTags: [ 'javascript', 'learning', 'es2024', 'beginner-friendly' ],
  isNewObject: true
}

Parts 1 and 2 are running successfully.
```

---

# Part 2 Reference: Expressive Syntax

## Arrow Function Forms

### One parameter with implicit return

```js
const double = value => value * 2;
```

### One parameter with parentheses

```js
const double = (value) => value * 2;
```

### Multiple parameters

```js
const add = (firstValue, secondValue) => firstValue + secondValue;
```

### No parameters

```js
const createId = () => crypto.randomUUID();
```

### Multiple statements

Use braces and an explicit `return` when necessary:

```js
const calculateTotal = (price, quantity) => {
  const subtotal = price * quantity;
  const tax = subtotal * 0.2;

  return subtotal + tax;
};
```

### Returning an object implicitly

Wrap the object in parentheses:

```js
const createUser = (name) => ({
  id: crypto.randomUUID(),
  name
});
```

Without parentheses, JavaScript interprets `{}` as a function body:

```js
// This returns undefined, not an object:
// const createUser = (name) => { id: crypto.randomUUID(), name };
```

---

## Arrow Functions and `this`

Arrow functions inherit `this` from their surrounding scope.

This makes them useful for callbacks:

```js
class Counter {
  constructor() {
    this.value = 0;
  }

  incrementLater() {
    setTimeout(() => {
      this.value += 1;
    }, 100);
  }
}
```

Do not use an arrow function as an object method when the method needs `this` to refer to the object:

```js
const user = {
  name: 'Ava',

  getName() {
    return this.name;
  }
};
```

Avoid:

```js
const user = {
  name: 'Ava',

  getName: () => this.name
};
```

Use arrow functions mainly for:

- Short transformations such as `.map()` and `.filter()`
- Callbacks
- Functions that intentionally inherit surrounding `this`
- Small utility functions

Use normal or concise method syntax for:

- Object methods that rely on `this`
- Class prototype methods
- Constructor functions
- Generator functions

Arrow functions cannot be constructors and cannot be called with `new`.

---

## Template Literals

Use backticks:

```js
const name = 'Ava';
const message = `Hello, ${name}!`;
```

Expressions can be any valid JavaScript expression:

```js
const quantity = 3;
const price = 19.99;

const total = `Total: $${(quantity * price).toFixed(2)}`;
```

Multiline text works naturally:

```js
const message = `
First line
Second line
`.trim();
```

---

## Tagged Template Literals

A tag function receives:

1. The static string segments.
2. Each interpolated value as a separate argument.

```js
function inspect(strings, ...values) {
  return {
    strings,
    values
  };
}

const result = inspect`Hello, ${'Ava'}!`;
```

Use tags when you need centralized handling for:

- Formatting
- Validation
- Escaping values for a specific output context
- Localization
- Logging
- Building domain-specific languages

Security note: escaping HTML text is context-specific. A basic HTML text escaper does not make arbitrary HTML, URLs, CSS, or JavaScript safe. Prefer well-maintained rendering systems and avoid injecting untrusted strings through unsafe browser APIs such as `innerHTML`.

---

## Enhanced Object Literals

### Shorthand properties

```js
const id = 'user_1';
const name = 'Ava';

const user = { id, name };
```

### Computed property names

```js
const key = 'theme';

const settings = {
  [key]: 'dark'
};
```

### Concise methods

```js
const calculator = {
  add(firstValue, secondValue) {
    return firstValue + secondValue;
  }
};
```

### Computed methods

```js
const action = 'archive';

const documentRecord = {
  [action]() {
    return 'Archived.';
  }
};
```

### Immutable object update

```js
const original = {
  theme: 'light',
  compactMode: false
};

const updated = {
  ...original,
  theme: 'dark'
};
```
