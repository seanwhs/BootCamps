# Part 1: Syntax Ergonomics & Destructuring

This part establishes the habits and syntax patterns you will use throughout the rest of the series:

- Safer variable declarations with `const` and `let`
- Block scope
- Array destructuring
- Object destructuring
- Default values and renamed variables
- Nested destructuring
- Rest syntax
- Spread syntax for arrays, objects, and function arguments

We will begin by creating the project workspace. Then, each feature will be demonstrated in a separate runnable module.

---

## Step 1: Create the Modern JavaScript Toolkit Workspace

### The Target

Create a Node.js project configured to run modern JavaScript using **ES modules**.

An ES module is a JavaScript file that can explicitly share code with `export` and use code from another file with `import`.

### The Concept

Think of a project as a workshop:

- `package.json` is the workshop inventory and instruction sheet.
- The `src` directory holds the tools you are building.
- The `type: "module"` setting tells Node.js to treat `.js` files as modern ES modules instead of older CommonJS files.

Without that setting, Node.js will reject `import` and `export` syntax in normal `.js` files.

### The Implementation

Create the following directory structure:

```text
modern-javascript-toolkit/
├── package.json
└── src/
    ├── index.js
    └── part-1-syntax-ergonomics/
        ├── variables.js
        ├── destructuring.js
        └── rest-spread.js
```

Run these commands in your terminal:

```bash
mkdir modern-javascript-toolkit
cd modern-javascript-toolkit
mkdir -p src/part-1-syntax-ergonomics
```

> On Windows PowerShell, use these commands instead:

```powershell
mkdir modern-javascript-toolkit
cd modern-javascript-toolkit
mkdir src
mkdir src\part-1-syntax-ergonomics
```

Now create this file.

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
    "part:1:rest-spread": "node src/part-1-syntax-ergonomics/rest-spread.js"
  },
  "engines": {
    "node": ">=22.0.0"
  }
}
```

### The Verification

Run:

```bash
node --version
```

Confirm that your installed Node.js version is `v22.0.0` or newer.

Then verify that Node.js can read the project metadata:

```bash
node -e "console.log(require('./package.json').name)"
```

Expected output:

```text
modern-javascript-toolkit
```

At this point, the scripts refer to files that do not exist yet. That is expected; we will create them next.

---

## Step 2: Use `const` and `let` for Safer Variables

### The Target

Create `variables.js`, a runnable module that demonstrates:

- Why modern JavaScript avoids `var`
- When to use `const`
- When to use `let`
- How block scope prevents accidental access and reassignment mistakes

### The Concept

A variable is like a labeled storage box.

- Use `const` when the **label must always point to the same box**.
- Use `let` when you intentionally need to replace what the label points to.
- Avoid `var` in modern application code because its scope rules are less predictable.

A key detail: `const` prevents **reassignment**, but it does not automatically make an object completely unchangeable.

For example:

```js
const user = { name: 'Ava' };

user.name = 'Mina'; // Allowed: changing a property inside the object.
// user = { name: 'Mina' }; // Not allowed: replacing the variable binding.
```

### The Implementation

Create the following file.

### `src/part-1-syntax-ergonomics/variables.js`

```js
/**
 * Part 1: Modern variable declarations and block scope.
 *
 * Run directly:
 * node src/part-1-syntax-ergonomics/variables.js
 */

/**
 * Formats a section heading so console output is easy to scan.
 *
 * @param {string} title - The section name to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('const: stable variable bindings');

const applicationName = 'Modern JavaScript Toolkit';
const supportedNodeMajorVersion = 22;

console.log({
  applicationName,
  supportedNodeMajorVersion
});

// The following reassignment would throw a TypeError if uncommented:
// applicationName = 'Different Name';

printSection('const does not freeze an object');

const currentUser = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  role: 'reader'
};

// This is allowed because we are changing a property on the same object.
currentUser.role = 'editor';

console.log(currentUser);

// The following replacement would throw a TypeError if uncommented:
// currentUser = { id: 'user_1002', displayName: 'Noah Kim', role: 'admin' };

printSection('let: intentional reassignment');

let completedLessons = 0;

completedLessons += 1;
completedLessons += 1;

console.log(`Completed lessons: ${completedLessons}`);

printSection('block scope with let and const');

const isFeatureEnabled = true;

if (isFeatureEnabled) {
  const featureName = 'Destructuring';
  let activationMessage = `${featureName} is enabled.`;

  activationMessage = `${activationMessage} Ready to use.`;

  console.log(activationMessage);
}

// featureName and activationMessage are not available here because they
// were created inside the if block. This is called block scope.
//
// console.log(featureName); // ReferenceError if uncommented.
// console.log(activationMessage); // ReferenceError if uncommented.

printSection('why var can create surprising behavior');

for (var legacyIndex = 0; legacyIndex < 3; legacyIndex += 1) {
  // var is function-scoped, not block-scoped.
}

console.log(`legacyIndex remains available outside the loop: ${legacyIndex}`);

for (let modernIndex = 0; modernIndex < 3; modernIndex += 1) {
  console.log(`modernIndex inside loop: ${modernIndex}`);
}

// modernIndex is unavailable here because let respects the loop block.
//
// console.log(modernIndex); // ReferenceError if uncommented.

printSection('practical default');

const accountId = 'acct_9001';
let retryCount = 0;

retryCount += 1;

console.log({
  accountId,
  retryCount
});

console.log('\nVariable declaration examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:1:variables
```

Expected output includes:

```text
--- const: stable variable bindings ---
{
  applicationName: 'Modern JavaScript Toolkit',
  supportedNodeMajorVersion: 22
}

--- let: intentional reassignment ---
Completed lessons: 2

--- why var can create surprising behavior ---
legacyIndex remains available outside the loop: 3

Variable declaration examples completed successfully.
```

Your exact object formatting may differ slightly by terminal, but the values should match.

---

## Step 3: Extract Data with Array and Object Destructuring

### The Target

Create `destructuring.js`, a module that extracts values from arrays and objects without repetitive property-access code.

### The Concept

**Destructuring** is a way to unpack values from a container.

Imagine receiving a delivery box containing labeled items:

```js
const user = {
  name: 'Ava',
  role: 'editor'
};
```

Without destructuring, you manually reach into the box each time:

```js
const name = user.name;
const role = user.role;
```

With destructuring, you write the labels you want directly:

```js
const { name, role } = user;
```

Arrays use position, while objects use property names:

```js
const colors = ['red', 'green', 'blue'];
const [firstColor] = colors;

const settings = { theme: 'dark' };
const { theme } = settings;
```

### The Implementation

Create the following file.

### `src/part-1-syntax-ergonomics/destructuring.js`

```js
/**
 * Part 1: Array and object destructuring.
 *
 * Run directly:
 * node src/part-1-syntax-ergonomics/destructuring.js
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

printSection('array destructuring by position');

const lessonTitles = [
  'Modern Variables',
  'Destructuring',
  'Rest and Spread'
];

const [firstLesson, secondLesson, thirdLesson] = lessonTitles;

console.log({
  firstLesson,
  secondLesson,
  thirdLesson
});

printSection('skipping unwanted array values');

const rgbColor = [34, 139, 34];

// The empty position skips the green value without creating a variable for it.
const [red, , blue] = rgbColor;

console.log({
  red,
  blue
});

printSection('array destructuring with default values');

const partialCoordinates = [48.8566];

const [latitude, longitude = 0] = partialCoordinates;

console.log({
  latitude,
  longitude
});

printSection('swapping values without a temporary variable');

let activeTheme = 'light';
let savedTheme = 'dark';

[activeTheme, savedTheme] = [savedTheme, activeTheme];

console.log({
  activeTheme,
  savedTheme
});

printSection('basic object destructuring');

const userProfile = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  role: 'editor',
  isVerified: true
};

const { displayName, role, isVerified } = userProfile;

console.log({
  displayName,
  role,
  isVerified
});

printSection('renaming destructured object properties');

const apiResponse = {
  request_id: 'req_456',
  created_at: '2026-07-24T10:30:00.000Z',
  status: 'success'
};

// request_id is the source property.
// requestId is the local variable name used by this program.
const {
  request_id: requestId,
  created_at: createdAt,
  status
} = apiResponse;

console.log({
  requestId,
  createdAt,
  status
});

printSection('object destructuring with defaults');

const accountPreferences = {
  colorScheme: 'dark',
  compactMode: true
};

// emailNotifications does not exist, so the default value is used.
const {
  colorScheme,
  compactMode,
  emailNotifications = false
} = accountPreferences;

console.log({
  colorScheme,
  compactMode,
  emailNotifications
});

printSection('nested object destructuring');

const order = {
  id: 'order_7001',
  totalCents: 4999,
  shippingAddress: {
    city: 'Lisbon',
    country: 'Portugal',
    postalCode: '1100-148'
  }
};

const {
  id: orderId,
  shippingAddress: {
    city,
    country,
    postalCode
  }
} = order;

console.log({
  orderId,
  city,
  country,
  postalCode
});

printSection('nested destructuring with resilient defaults');

const guestOrder = {
  id: 'order_7002',
  shippingAddress: {
    country: 'Canada'
  }
};

/**
 * Reads shipping details safely from an order-like object.
 *
 * The default empty object means this function can also accept an object
 * with no shippingAddress property without throwing an error.
 *
 * @param {object} orderRecord - An order record to inspect.
 * @returns {{ city: string, country: string, postalCode: string }}
 */
function getShippingSummary({
  shippingAddress: {
    city: shippingCity = 'Not provided',
    country: shippingCountry = 'Not provided',
    postalCode: shippingPostalCode = 'Not provided'
  } = {}
}) {
  return {
    city: shippingCity,
    country: shippingCountry,
    postalCode: shippingPostalCode
  };
}

console.log(getShippingSummary(guestOrder));

printSection('destructuring function parameters');

/**
 * Builds a readable user greeting from selected profile properties.
 *
 * @param {{ displayName: string, role?: string }} profile - A user profile.
 * @returns {string} A greeting for the user.
 */
function createGreeting({ displayName, role = 'member' }) {
  return `Welcome, ${displayName}. Your role is ${role}.`;
}

console.log(createGreeting(userProfile));

console.log('\nDestructuring examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:1:destructuring
```

Expected output includes:

```text
--- array destructuring by position ---
{
  firstLesson: 'Modern Variables',
  secondLesson: 'Destructuring',
  thirdLesson: 'Rest and Spread'
}

--- swapping values without a temporary variable ---
{ activeTheme: 'dark', savedTheme: 'light' }

--- object destructuring with defaults ---
{
  colorScheme: 'dark',
  compactMode: true,
  emailNotifications: false
}

--- destructuring function parameters ---
Welcome, Ava Patel. Your role is editor.

Destructuring examples completed successfully.
```

---

## Step 4: Use Rest and Spread Syntax

### The Target

Create `rest-spread.js`, a module that demonstrates the `...` operator in its two roles:

- **Rest syntax:** gathers remaining values into an array or object.
- **Spread syntax:** expands an iterable or object into individual values.

### The Concept

The same `...` notation has two opposite jobs depending on where it appears.

Think of it as packing or unpacking luggage:

- **Rest** packs remaining items into one bag.
- **Spread** unpacks items from a bag.

Rest example:

```js
const [first, ...remaining] = ['a', 'b', 'c'];
```

Here, `remaining` becomes:

```js
['b', 'c']
```

Spread example:

```js
const allItems = ['a', ...['b', 'c']];
```

Here, the inner array is unpacked into the new array.

### The Implementation

Create the following file.

### `src/part-1-syntax-ergonomics/rest-spread.js`

```js
/**
 * Part 1: Rest and spread syntax.
 *
 * Run directly:
 * node src/part-1-syntax-ergonomics/rest-spread.js
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

printSection('array rest syntax');

const availableRoles = ['admin', 'editor', 'reader', 'guest'];

const [primaryRole, secondaryRole, ...remainingRoles] = availableRoles;

console.log({
  primaryRole,
  secondaryRole,
  remainingRoles
});

printSection('object rest syntax');

const userRecord = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  email: 'ava@example.com',
  role: 'editor',
  passwordHash: 'sensitive-value-that-must-not-be-returned'
};

// This extracts passwordHash and gathers every other enumerable property
// into publicUserRecord.
const {
  passwordHash,
  ...publicUserRecord
} = userRecord;

console.log({
  passwordHashWasExtracted: Boolean(passwordHash),
  publicUserRecord
});

printSection('rest parameters in functions');

/**
 * Calculates the total of any number of numeric values.
 *
 * A rest parameter gathers all arguments after the function name into
 * a real Array, allowing us to use Array methods such as reduce().
 *
 * @param {...number} values - Values to add together.
 * @returns {number} The calculated total.
 */
function sum(...values) {
  return values.reduce((total, value) => total + value, 0);
}

console.log({
  noValues: sum(),
  oneValue: sum(10),
  severalValues: sum(10, 20, 30, 40)
});

printSection('spread syntax to copy arrays');

const defaultPermissions = ['read', 'comment'];
const editorPermissions = [...defaultPermissions, 'write'];

// Modifying the new array does not modify defaultPermissions.
editorPermissions.push('publish');

console.log({
  defaultPermissions,
  editorPermissions
});

printSection('spread syntax to merge arrays');

const morningTasks = ['Review pull request', 'Plan sprint'];
const afternoonTasks = ['Implement feature', 'Write documentation'];

const dailyTasks = [
  ...morningTasks,
  'Lunch break',
  ...afternoonTasks
];

console.log(dailyTasks);

printSection('spread syntax for function arguments');

/**
 * Returns the smallest number in a non-empty collection.
 *
 * @param {...number} values - Numeric values to compare.
 * @returns {number} The smallest supplied value.
 * @throws {TypeError} When no values are supplied.
 */
function getMinimum(...values) {
  if (values.length === 0) {
    throw new TypeError('getMinimum requires at least one numeric value.');
  }

  return Math.min(...values);
}

const responseTimesInMilliseconds = [240, 125, 310, 180];

console.log({
  responseTimesInMilliseconds,
  fastestResponse: getMinimum(...responseTimesInMilliseconds)
});

printSection('spread syntax to copy and update objects');

const baseUserSettings = {
  colorScheme: 'light',
  fontSize: 'medium',
  emailNotifications: true
};

const updatedUserSettings = {
  ...baseUserSettings,
  colorScheme: 'dark',
  fontSize: 'large'
};

console.log({
  baseUserSettings,
  updatedUserSettings
});

printSection('object merge order matters');

const defaultRequestOptions = {
  method: 'GET',
  headers: {
    accept: 'application/json'
  },
  timeoutMilliseconds: 5_000
};

const requestSpecificOptions = {
  method: 'POST',
  timeoutMilliseconds: 10_000
};

// Properties later in the object override earlier properties with the same key.
const finalRequestOptions = {
  ...defaultRequestOptions,
  ...requestSpecificOptions
};

console.log(finalRequestOptions);

printSection('important: spread copies only one level deep');

const originalProject = {
  name: 'Documentation refresh',
  metadata: {
    owner: 'Ava Patel',
    priority: 'high'
  }
};

const copiedProject = {
  ...originalProject
};

// The top-level object is new, but the nested metadata object is shared.
copiedProject.metadata.priority = 'urgent';

console.log({
  originalProject,
  copiedProject,
  metadataObjectsAreSameReference:
    originalProject.metadata === copiedProject.metadata
});

printSection('practical immutable update');

/**
 * Adds a permission only when it is not already present.
 *
 * @param {{ id: string, permissions: string[] }} user - User to update.
 * @param {string} permission - Permission to add.
 * @returns {{ id: string, permissions: string[] }} A new user object.
 */
function addPermission(user, permission) {
  if (user.permissions.includes(permission)) {
    return user;
  }

  return {
    ...user,
    permissions: [...user.permissions, permission]
  };
}

const readerUser = {
  id: 'user_2002',
  permissions: ['read']
};

const updatedReaderUser = addPermission(readerUser, 'comment');

console.log({
  readerUser,
  updatedReaderUser,
  objectsAreDifferentReferences: readerUser !== updatedReaderUser,
  permissionArraysAreDifferentReferences:
    readerUser.permissions !== updatedReaderUser.permissions
});

console.log('\nRest and spread examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:1:rest-spread
```

Expected output includes:

```text
--- array rest syntax ---
{
  primaryRole: 'admin',
  secondaryRole: 'editor',
  remainingRoles: [ 'reader', 'guest' ]
}

--- spread syntax to copy arrays ---
{
  defaultPermissions: [ 'read', 'comment' ],
  editorPermissions: [ 'read', 'comment', 'write', 'publish' ]
}

--- important: spread copies only one level deep ---
{
  originalProject: {
    name: 'Documentation refresh',
    metadata: { owner: 'Ava Patel', priority: 'urgent' }
  },
  copiedProject: {
    name: 'Documentation refresh',
    metadata: { owner: 'Ava Patel', priority: 'urgent' }
  },
  metadataObjectsAreSameReference: true
}

Rest and spread examples completed successfully.
```

The shared nested object in the shallow-copy example is intentional. In Part 4, you will learn how `structuredClone()` creates a deeper independent copy.

---

## Step 5: Create a Part 1 Runner

### The Target

Create the project entry point, `src/index.js`, to run a small practical workflow using the Part 1 concepts together.

### The Concept

Individual examples are useful for learning one tool at a time. An entry point is where the tools start working together.

Think of this file as a conductor: it coordinates several musicians—variables, destructuring, rest, and spread—into one piece of music.

For now, the entry point will use self-contained examples. In later parts, it will expand into the central runner for the complete toolkit.

### The Implementation

Create the following file.

### `src/index.js`

```js
/**
 * Modern JavaScript Toolkit entry point.
 *
 * Run with:
 * npm start
 */

/**
 * Builds a safe summary for a project workspace.
 *
 * @param {{
 *   project: {
 *     id: string,
 *     name: string,
 *     owner: { displayName: string },
 *     tags?: string[]
 *   },
 *   additionalTags?: string[]
 * }} input - Project data to summarize.
 * @returns {{
 *   id: string,
 *   name: string,
 *   ownerName: string,
 *   tags: string[],
 *   label: string
 * }} A normalized project summary.
 */
function createProjectSummary({
  project: {
    id,
    name,
    owner: { displayName: ownerName },
    tags = []
  },
  additionalTags = []
}) {
  const mergedTags = [...new Set([...tags, ...additionalTags])];

  return {
    id,
    name,
    ownerName,
    tags: mergedTags,
    label: `${name} — owned by ${ownerName}`
  };
}

/**
 * Returns a new project object with an added tag.
 *
 * @param {{ id: string, name: string, tags: string[] }} project - Project to update.
 * @param {string} tag - Tag to add.
 * @returns {{ id: string, name: string, tags: string[] }} Updated project data.
 */
function addProjectTag(project, tag) {
  if (project.tags.includes(tag)) {
    return project;
  }

  return {
    ...project,
    tags: [...project.tags, tag]
  };
}

const projectInput = {
  project: {
    id: 'project_3001',
    name: 'Modern JavaScript Toolkit',
    owner: {
      displayName: 'Ava Patel'
    },
    tags: ['javascript', 'learning']
  },
  additionalTags: ['es2024', 'javascript']
};

const summary = createProjectSummary(projectInput);

const taggedProject = addProjectTag(
  {
    id: summary.id,
    name: summary.name,
    tags: summary.tags
  },
  'beginner-friendly'
);

console.log('\n=== Modern JavaScript Toolkit ===\n');

console.log('Project summary:');
console.log(summary);

console.log('\nImmutable tag update:');
console.log(taggedProject);

console.log('\nPart 1 workspace is running successfully.');
```

### The Verification

Run:

```bash
npm start
```

Expected output:

```text
=== Modern JavaScript Toolkit ===

Project summary:
{
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  ownerName: 'Ava Patel',
  tags: [ 'javascript', 'learning', 'es2024' ],
  label: 'Modern JavaScript Toolkit — owned by Ava Patel'
}

Immutable tag update:
{
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  tags: [ 'javascript', 'learning', 'es2024', 'beginner-friendly' ]
}

Part 1 workspace is running successfully.
```

---

# Part 1 Reference: Syntax Ergonomics & Destructuring

This reference section gathers the key rules from Part 1 in one place.

## `const` vs. `let`

Use `const` by default:

```js
const taxRate = 0.2;
```

Use `let` only when the binding must be reassigned:

```js
let pageNumber = 1;
pageNumber += 1;
```

Avoid `var` in new code:

```js
var legacyValue = 'Avoid in modern application code';
```

### Important `const` Rule

This is not allowed:

```js
const user = { name: 'Ava' };
user = { name: 'Mina' };
```

But this is allowed:

```js
const user = { name: 'Ava' };
user.name = 'Mina';
```

`const` protects the variable binding, not every nested value.

---

## Array Destructuring

Extract by position:

```js
const coordinates = [40.7128, -74.006];

const [latitude, longitude] = coordinates;
```

Skip values:

```js
const rgb = [255, 165, 0];

const [red, , blue] = rgb;
```

Set defaults:

```js
const values = [10];

const [first, second = 20] = values;
```

Gather remaining items:

```js
const letters = ['a', 'b', 'c', 'd'];

const [first, ...remaining] = letters;
```

---

## Object Destructuring

Extract properties by name:

```js
const user = {
  name: 'Ava',
  role: 'editor'
};

const { name, role } = user;
```

Rename local variables:

```js
const response = {
  request_id: 'req_1'
};

const { request_id: requestId } = response;
```

Provide defaults:

```js
const settings = {
  theme: 'dark'
};

const { theme, language = 'en' } = settings;
```

Extract nested properties:

```js
const order = {
  shippingAddress: {
    city: 'Lisbon'
  }
};

const {
  shippingAddress: { city }
} = order;
```

Use a nested default if the parent object may be missing:

```js
const order = {};

const {
  shippingAddress: {
    city = 'Not provided'
  } = {}
} = order;
```

---

## Rest Syntax

Rest gathers values.

In arrays:

```js
const [first, ...remaining] = [1, 2, 3];
```

In objects:

```js
const { passwordHash, ...safeUser } = user;
```

In function parameters:

```js
function sum(...numbers) {
  return numbers.reduce((total, number) => total + number, 0);
}
```

A rest parameter must be the final parameter:

```js
function valid(firstValue, ...remainingValues) {
  return [firstValue, remainingValues];
}
```

This is invalid:

```js
// function invalid(...values, finalValue) {}
```

---

## Spread Syntax

Spread expands values.

Copy and extend an array:

```js
const original = ['read'];
const updated = [...original, 'write'];
```

Merge arrays:

```js
const combined = [...firstArray, ...secondArray];
```

Pass an array to a function as separate arguments:

```js
const numbers = [4, 2, 9];

const smallest = Math.min(...numbers);
```

Copy and update an object:

```js
const originalUser = {
  name: 'Ava',
  role: 'reader'
};

const updatedUser = {
  ...originalUser,
  role: 'editor'
};
```

Later properties overwrite earlier matching properties:

```js
const defaults = {
  timeout: 5_000,
  retries: 2
};

const customOptions = {
  timeout: 10_000
};

const finalOptions = {
  ...defaults,
  ...customOptions
};

// { timeout: 10000, retries: 2 }
```

---

## Shallow Copy Warning

Object and array spread create **shallow copies**.

That means the first container is copied, but nested objects and arrays are still shared:

```js
const original = {
  metadata: {
    priority: 'high'
  }
};

const copied = {
  ...original
};

copied.metadata.priority = 'urgent';

console.log(original.metadata.priority);
// 'urgent'
```

This is not a spread bug. It is the defined behavior of shallow copying. Part 4 will cover `structuredClone()` for appropriate deep-copy use cases.
