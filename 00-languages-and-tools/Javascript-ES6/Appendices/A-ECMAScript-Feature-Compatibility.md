# Appendix A: ECMAScript Feature Compatibility

Modern JavaScript is standardized under the name **ECMAScript**. JavaScript engines—such as the one in Node.js, Chrome, Firefox, Safari, Deno, and Bun—implement that standard over time.

This appendix helps you answer practical questions such as:

- “Will this feature work in my Node.js application?”
- “Can I use this syntax in browsers?”
- “Do I need Babel, a polyfill, or neither?”
- “Why does code work on my laptop but fail in production?”
- “How should I support older environments without giving up modern coding practices?”

The examples in the main tutorial assume **Node.js 22 or newer**, which supports all features used in the series.

---

## A.1: Understand the Three Compatibility Layers

### The Target

Learn to distinguish JavaScript **syntax**, built-in **APIs**, and **runtime environments**.

### The Concept

Compatibility is like shipping a recipe to different kitchens.

- **Syntax** is the recipe’s written language.
- **APIs** are the appliances required to prepare it.
- **Runtime environments** are the actual kitchens: Node.js, browsers, Deno, Bun, and so on.

A kitchen may understand the recipe but not own a required appliance.

For example, an older runtime might understand arrow functions:

```js
const double = (value) => value * 2;
```

…but not provide the newer immutable array method:

```js
const sortedValues = values.toSorted();
```

The first is syntax. The second depends on a built-in API existing at runtime.

### The Implementation

The following table classifies the features used in this series.

| Feature | Category | Example |
|---|---|---|
| `const`, `let` | Syntax | `const name = 'Ava';` |
| Destructuring | Syntax | `const { name } = user;` |
| Rest and spread | Syntax | `const copy = [...items];` |
| Arrow functions | Syntax | `const add = (a, b) => a + b;` |
| Template literals | Syntax | `` `Hello, ${name}` `` |
| Optional chaining | Syntax | `user?.profile?.name` |
| Nullish coalescing | Syntax | `value ?? 'fallback'` |
| Logical assignment | Syntax | `value ??= 'fallback'` |
| Async generators | Syntax | `async function* stream() {}` |
| `Set`, `Map`, `WeakSet`, `WeakMap` | Built-in APIs | `new Map()` |
| `structuredClone()` | Built-in API | `structuredClone(value)` |
| `.at()` | Built-in API | `items.at(-1)` |
| `.toSorted()` | Built-in API | `items.toSorted()` |
| `.toSpliced()` | Built-in API | `items.toSpliced(1, 1)` |
| `.with()` | Built-in API | `items.with(0, 'updated')` |

Create a temporary compatibility-check file.

### `src/appendices/appendix-a-compatibility-check.js`

```js
/**
 * Appendix A: Runtime feature compatibility check.
 *
 * Run with:
 * node src/appendices/appendix-a-compatibility-check.js
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

/**
 * Reports whether a feature is available.
 *
 * @param {string} name - Human-readable feature name.
 * @param {boolean} isAvailable - Whether the feature exists.
 * @returns {void}
 */
function reportFeature(name, isAvailable) {
  const status = isAvailable ? 'available' : 'missing';

  console.log(`${name}: ${status}`);
}

printSection('Runtime information');

console.log({
  nodeVersion: process.version,
  platform: process.platform,
  architecture: process.arch
});

printSection('Modern built-in API support');

reportFeature(
  'structuredClone()',
  typeof globalThis.structuredClone === 'function'
);

reportFeature(
  'Array.prototype.at()',
  typeof Array.prototype.at === 'function'
);

reportFeature(
  'Array.prototype.toSorted()',
  typeof Array.prototype.toSorted === 'function'
);

reportFeature(
  'Array.prototype.toSpliced()',
  typeof Array.prototype.toSpliced === 'function'
);

reportFeature(
  'Array.prototype.with()',
  typeof Array.prototype.with === 'function'
);

reportFeature(
  'Set',
  typeof globalThis.Set === 'function'
);

reportFeature(
  'Map',
  typeof globalThis.Map === 'function'
);

reportFeature(
  'WeakSet',
  typeof globalThis.WeakSet === 'function'
);

reportFeature(
  'WeakMap',
  typeof globalThis.WeakMap === 'function'
);

printSection('Behavior verification');

const values = [30, 10, 20];

console.log({
  lastValue: values.at(-1),
  sortedValues: values.toSorted((firstValue, secondValue) => {
    return firstValue - secondValue;
  }),
  originalValuesAfterToSorted: values,
  replacedValues: values.with(1, 99),
  originalValuesAfterWith: values
});

const originalRecord = {
  metadata: {
    status: 'active'
  }
};

const clonedRecord = structuredClone(originalRecord);

clonedRecord.metadata.status = 'archived';

console.log({
  originalStatus: originalRecord.metadata.status,
  clonedStatus: clonedRecord.metadata.status,
  nestedObjectsAreIndependent:
    originalRecord.metadata !== clonedRecord.metadata
});

console.log('\nCompatibility check completed successfully.');
```

Before creating the file, make its parent directory:

```bash
mkdir -p src/appendices
```

> On Windows PowerShell:

```powershell
mkdir src\appendices
```

### The Verification

Run:

```bash
node src/appendices/appendix-a-compatibility-check.js
```

On Node.js 22 or newer, expected output includes:

```text
--- Modern built-in API support ---
structuredClone(): available
Array.prototype.at(): available
Array.prototype.toSorted(): available
Array.prototype.toSpliced(): available
Array.prototype.with(): available
Set: available
Map: available
WeakSet: available
WeakMap: available
```

If a required feature reports `missing`, upgrade the runtime or apply the compatibility strategy described later in this appendix.

---

## A.2: Node.js Compatibility

### The Target

Identify which Node.js versions are appropriate for the tutorial’s features.

### The Concept

Node.js packages a JavaScript engine called **V8**. When Node.js upgrades V8, it gains support for more ECMAScript features.

A newer Node.js version is like a newer workshop with additional tools. Writing code for a newer workshop is straightforward. Writing code for an older workshop may require different tools, extra adapters, or a changed process.

### The Implementation

Use this practical support guide.

| Feature group | Node.js 18 LTS | Node.js 20 LTS | Node.js 22 LTS+ | Recommendation |
|---|---:|---:|---:|---|
| ES6 fundamentals: `const`, destructuring, arrow functions, templates, `Set`, `Map` | Yes | Yes | Yes | Safe in currently supported Node versions |
| Optional chaining `?.` | Yes | Yes | Yes | Safe |
| Nullish coalescing `??` | Yes | Yes | Yes | Safe |
| Logical assignment (`??=`, `&&=`, `||=`) | Yes | Yes | Yes | Safe |
| Async generators and `for await...of` | Yes | Yes | Yes | Safe |
| `structuredClone()` | Yes | Yes | Yes | Safe |
| `Array.prototype.at()` | Yes | Yes | Yes | Safe |
| `Array.prototype.toSorted()` | Usually unavailable or not a safe baseline | Yes | Yes | Use Node 20+ |
| `Array.prototype.toSpliced()` | Usually unavailable or not a safe baseline | Yes | Yes | Use Node 20+ |
| `Array.prototype.with()` | Usually unavailable or not a safe baseline | Yes | Yes | Use Node 20+ |

For the complete tutorial project, use Node.js 22 or newer:

```bash
node --version
```

If you use a Node version manager, install and activate Node.js 22. The exact command depends on the version manager.

For `nvm` on macOS or Linux:

```bash
nvm install 22
nvm use 22
node --version
```

For Windows users with **nvm-windows**:

```powershell
nvm install 22
nvm use 22
node --version
```

You can make the project requirement visible to package managers by retaining this section in `package.json`:

### `package.json`

```json
{
  "engines": {
    "node": ">=22.0.0"
  }
}
```

### The Verification

Run:

```bash
node --version
npm --version
```

Expected example output:

```text
v22.0.0
10.x.x
```

Then run the final toolkit:

```bash
npm start
```

If it completes with:

```text
Parts 1 through 4 are running successfully.
```

your Node.js runtime supports the tutorial application.

---

## A.3: Browser Compatibility

### The Target

Understand which features work in modern browsers and how to define a browser support policy.

### The Concept

Browsers are independent JavaScript runtimes. Chrome, Edge, Firefox, and Safari may implement a feature at different times.

A browser support policy is a written decision about which browsers your application promises to support. It is like deciding which sizes of charging cable your product will include.

Without a policy, developers may unknowingly use a feature that works in their own browser but fails for users on an older one.

### The Implementation

For applications targeting modern evergreen browsers, this is a reasonable baseline:

| Feature | Chrome / Edge | Firefox | Safari | Practical browser baseline |
|---|---:|---:|---:|---|
| `const`, `let`, destructuring, arrow functions | Modern versions | Modern versions | Modern versions | Safe for current browsers |
| Template literals | Modern versions | Modern versions | Modern versions | Safe for current browsers |
| `Set`, `Map`, weak collections | Modern versions | Modern versions | Modern versions | Safe for current browsers |
| Optional chaining `?.` | Modern versions | Modern versions | Modern versions | Safe for current browsers |
| Nullish coalescing `??` | Modern versions | Modern versions | Modern versions | Safe for current browsers |
| Logical assignment | Modern versions | Modern versions | Modern versions | Safe for current browsers |
| `structuredClone()` | Modern versions | Modern versions | Modern versions | Check legacy Safari or embedded webviews |
| `.at()` | Modern versions | Modern versions | Modern versions | Safe in current evergreen browsers |
| `.toSorted()` | Modern versions | Modern versions | Modern versions | Check older browser fleets |
| `.toSpliced()` | Modern versions | Modern versions | Modern versions | Check older browser fleets |
| `.with()` | Modern versions | Modern versions | Modern versions | Check older browser fleets |
| Async generators / `for await...of` | Modern versions | Modern versions | Modern versions | Verify if supporting old Safari or webviews |

For a current public web application, a common policy is:

> Support the latest two stable versions of Chrome, Edge, Firefox, and Safari, plus currently supported mobile equivalents.

If your organization must support old browsers, embedded devices, enterprise-managed browsers, or old mobile webviews, record those exact targets and test them explicitly.

Create a small browser verification page.

### `src/appendices/appendix-a-browser-check.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    >
    <title>Modern JavaScript Compatibility Check</title>
    <style>
      :root {
        color-scheme: light dark;
        font-family: system-ui, sans-serif;
      }

      body {
        margin: 2rem;
        max-width: 50rem;
      }

      table {
        border-collapse: collapse;
        width: 100%;
      }

      th,
      td {
        border: 1px solid currentColor;
        padding: 0.75rem;
        text-align: left;
      }

      .available {
        color: #0a7a2f;
        font-weight: 700;
      }

      .missing {
        color: #b42318;
        font-weight: 700;
      }
    </style>
  </head>
  <body>
    <h1>Modern JavaScript Compatibility Check</h1>

    <p>
      This page checks runtime APIs used by the tutorial. Open it directly
      in every browser your application supports.
    </p>

    <table>
      <thead>
        <tr>
          <th>Feature</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody id="feature-results"></tbody>
    </table>

    <script type="module">
      /**
       * Returns feature availability data.
       *
       * Syntax features are not checked here because an unsupported syntax
       * feature would prevent this script from loading in the first place.
       *
       * @returns {Array<{ name: string, available: boolean }>}
       */
      function getFeatureResults() {
        return [
          {
            name: 'structuredClone()',
            available: typeof globalThis.structuredClone === 'function'
          },
          {
            name: 'Array.prototype.at()',
            available: typeof Array.prototype.at === 'function'
          },
          {
            name: 'Array.prototype.toSorted()',
            available: typeof Array.prototype.toSorted === 'function'
          },
          {
            name: 'Array.prototype.toSpliced()',
            available: typeof Array.prototype.toSpliced === 'function'
          },
          {
            name: 'Array.prototype.with()',
            available: typeof Array.prototype.with === 'function'
          },
          {
            name: 'Set',
            available: typeof globalThis.Set === 'function'
          },
          {
            name: 'Map',
            available: typeof globalThis.Map === 'function'
          },
          {
            name: 'WeakSet',
            available: typeof globalThis.WeakSet === 'function'
          },
          {
            name: 'WeakMap',
            available: typeof globalThis.WeakMap === 'function'
          }
        ];
      }

      /**
       * Adds the compatibility results to the table.
       *
       * @param {HTMLElement} tableBody - Element receiving result rows.
       * @param {Array<{ name: string, available: boolean }>} results - Feature results.
       * @returns {void}
       */
      function renderResults(tableBody, results) {
        for (const { name, available } of results) {
          const row = document.createElement('tr');
          const nameCell = document.createElement('td');
          const statusCell = document.createElement('td');

          nameCell.textContent = name;
          statusCell.textContent = available ? 'Available' : 'Missing';
          statusCell.className = available ? 'available' : 'missing';

          row.append(nameCell, statusCell);
          tableBody.append(statusCell);
          tableBody.append(row);
        }
      }

      const featureResultsElement = document.querySelector('#feature-results');

      renderResults(featureResultsElement, getFeatureResults());
    </script>
  </body>
</html>
```

There is one intentional correction needed before testing: the `renderResults` function must append the completed row to the table body. Replace the function with the following complete corrected implementation.

### `src/appendices/appendix-a-browser-check.html` — corrected `renderResults` function

```js
/**
 * Adds the compatibility results to the table.
 *
 * @param {HTMLElement} tableBody - Element receiving result rows.
 * @param {Array<{ name: string, available: boolean }>} results - Feature results.
 * @returns {void}
 */
function renderResults(tableBody, results) {
  for (const { name, available } of results) {
    const row = document.createElement('tr');
    const nameCell = document.createElement('td');
    const statusCell = document.createElement('td');

    nameCell.textContent = name;
    statusCell.textContent = available ? 'Available' : 'Missing';
    statusCell.className = available ? 'available' : 'missing';

    row.append(nameCell, statusCell);
    tableBody.append(row);
  }
}
```

> In a real project, always use the corrected complete file below. The separated correction above illustrates why verification matters: a small DOM operation mistake can prevent a page from rendering correctly.

### `src/appendices/appendix-a-browser-check.html` — final complete file

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    >
    <title>Modern JavaScript Compatibility Check</title>
    <style>
      :root {
        color-scheme: light dark;
        font-family: system-ui, sans-serif;
      }

      body {
        margin: 2rem;
        max-width: 50rem;
      }

      table {
        border-collapse: collapse;
        width: 100%;
      }

      th,
      td {
        border: 1px solid currentColor;
        padding: 0.75rem;
        text-align: left;
      }

      .available {
        color: #0a7a2f;
        font-weight: 700;
      }

      .missing {
        color: #b42318;
        font-weight: 700;
      }
    </style>
  </head>
  <body>
    <h1>Modern JavaScript Compatibility Check</h1>

    <p>
      This page checks runtime APIs used by the tutorial. Open it directly
      in every browser your application supports.
    </p>

    <table>
      <thead>
        <tr>
          <th>Feature</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody id="feature-results"></tbody>
    </table>

    <script type="module">
      /**
       * Returns feature availability data.
       *
       * Syntax features are not checked here because an unsupported syntax
       * feature would prevent this script from loading in the first place.
       *
       * @returns {Array<{ name: string, available: boolean }>}
       */
      function getFeatureResults() {
        return [
          {
            name: 'structuredClone()',
            available: typeof globalThis.structuredClone === 'function'
          },
          {
            name: 'Array.prototype.at()',
            available: typeof Array.prototype.at === 'function'
          },
          {
            name: 'Array.prototype.toSorted()',
            available: typeof Array.prototype.toSorted === 'function'
          },
          {
            name: 'Array.prototype.toSpliced()',
            available: typeof Array.prototype.toSpliced === 'function'
          },
          {
            name: 'Array.prototype.with()',
            available: typeof Array.prototype.with === 'function'
          },
          {
            name: 'Set',
            available: typeof globalThis.Set === 'function'
          },
          {
            name: 'Map',
            available: typeof globalThis.Map === 'function'
          },
          {
            name: 'WeakSet',
            available: typeof globalThis.WeakSet === 'function'
          },
          {
            name: 'WeakMap',
            available: typeof globalThis.WeakMap === 'function'
          }
        ];
      }

      /**
       * Adds the compatibility results to the table.
       *
       * @param {HTMLElement} tableBody - Element receiving result rows.
       * @param {Array<{ name: string, available: boolean }>} results - Feature results.
       * @returns {void}
       */
      function renderResults(tableBody, results) {
        for (const { name, available } of results) {
          const row = document.createElement('tr');
          const nameCell = document.createElement('td');
          const statusCell = document.createElement('td');

          nameCell.textContent = name;
          statusCell.textContent = available ? 'Available' : 'Missing';
          statusCell.className = available ? 'available' : 'missing';

          row.append(nameCell, statusCell);
          tableBody.append(row);
        }
      }

      const featureResultsElement = document.querySelector('#feature-results');

      renderResults(featureResultsElement, getFeatureResults());
    </script>
  </body>
</html>
```

### The Verification

Open the HTML file in a browser.

On macOS:

```bash
open src/appendices/appendix-a-browser-check.html
```

On Linux:

```bash
xdg-open src/appendices/appendix-a-browser-check.html
```

On Windows PowerShell:

```powershell
Start-Process src\appendices\appendix-a-browser-check.html
```

Expected result:

- A page titled **Modern JavaScript Compatibility Check**
- A table listing each checked API
- Each API marked **Available** in a modern supported browser

For browser testing in a deployed application, verify the same features in your real application bundle—not only in this standalone page.

---

## A.4: Transpilation vs. Polyfills

### The Target

Learn when to use a transpiler, when to use a polyfill, and why they solve different problems.

### The Concept

A **transpiler** rewrites newer JavaScript syntax into older syntax.

For example, it can transform:

```js
const getName = (user) => user?.name ?? 'Anonymous';
```

into older JavaScript that legacy engines can parse.

A **polyfill** adds a missing built-in API implementation.

For example, it can provide `.toSorted()` in an environment that does not natively implement it.

Think of the difference this way:

- A transpiler translates the written recipe into an older language.
- A polyfill installs a missing appliance in the kitchen.

A transpiler cannot fully recreate every missing runtime feature. `structuredClone()`, `Map`, `Set`, and modern Array methods are runtime behavior, so they may need polyfills, alternative implementations, or a newer supported runtime.

### The Implementation

Use this decision table.

| Your problem | Appropriate solution |
|---|---|
| An old runtime cannot parse arrow functions, optional chaining, or `async function*` | Transpile syntax |
| A runtime parses code but lacks `.toSorted()` | Polyfill or use a compatible alternative |
| A runtime lacks `structuredClone()` | Polyfill only if its behavior is sufficient for your required data types; otherwise use a targeted cloning strategy |
| You control the server runtime | Upgrade Node.js instead of adding unnecessary transforms |
| You target current browsers only | Often no transpilation/polyfills are necessary, depending on your browser policy |
| You support legacy browsers | Use a build pipeline plus carefully selected polyfills |

A minimal Babel setup for legacy syntax support could use these development dependencies:

```bash
npm install --save-dev @babel/cli @babel/core @babel/preset-env
```

Create the Babel configuration.

### `babel.config.json`

```json
{
  "presets": [
    [
      "@babel/preset-env",
      {
        "targets": {
          "defaults": "and not dead"
        }
      }
    ]
  ]
}
```

Update `package.json` with build scripts.

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
    "compatibility:node": "node src/appendices/appendix-a-compatibility-check.js",
    "build:legacy": "babel src --out-dir dist --extensions .js --copy-files"
  },
  "engines": {
    "node": ">=22.0.0"
  },
  "devDependencies": {
    "@babel/cli": "^7.26.4",
    "@babel/core": "^7.26.10",
    "@babel/preset-env": "^7.26.9"
  }
}
```

> This `package.json` is intentionally focused on the appendix build demonstration. If you are adding it to the full tutorial project, preserve all existing `part:*` scripts and add only `compatibility:node` and `build:legacy`.

For a focused `.toSorted()` fallback, use a helper rather than silently mutating the original array.

### `src/appendices/array-compatibility.js`

```js
/**
 * Provides a non-mutating sorted array in environments with or without
 * Array.prototype.toSorted().
 *
 * @template T
 * @param {T[]} values - Source array.
 * @param {(firstValue: T, secondValue: T) => number} [compareFunction]
 * Optional comparison function.
 * @returns {T[]} A sorted new array.
 */
export function toSortedCompat(values, compareFunction) {
  if (typeof values.toSorted === 'function') {
    return values.toSorted(compareFunction);
  }

  // [...values] creates a copy before sort() mutates that copy.
  return [...values].sort(compareFunction);
}
```

### `src/appendices/array-compatibility-demo.js`

```js
import { toSortedCompat } from './array-compatibility.js';

const responseTimes = [250, 18, 100, 4, 75];

const sortedResponseTimes = toSortedCompat(
  responseTimes,
  (firstTime, secondTime) => firstTime - secondTime
);

console.log({
  responseTimes,
  sortedResponseTimes,
  originalArrayWasPreserved:
    responseTimes.join(',') === '250,18,100,4,75'
});
```

### The Verification

First, run the compatibility helper demonstration:

```bash
node src/appendices/array-compatibility-demo.js
```

Expected output:

```text
{
  responseTimes: [ 250, 18, 100, 4, 75 ],
  sortedResponseTimes: [ 4, 18, 75, 100, 250 ],
  originalArrayWasPreserved: true
}
```

If you installed Babel dependencies, run:

```bash
npm run build:legacy
```

Expected output includes a message similar to:

```text
Successfully compiled ... files with Babel
```

Then inspect the generated `dist` directory:

```bash
find dist -maxdepth 2 -type f
```

> On Windows PowerShell:

```powershell
Get-ChildItem -Path dist -Recurse -File
```

Remember: Babel may transform syntax, but it does not automatically make every modern built-in API available in old runtimes.

---

## A.5: Feature Detection Instead of User-Agent Detection

### The Target

Write compatibility checks based on actual feature availability.

### The Concept

A **user agent** is a browser-identification string. It tries to describe which browser and operating system is running.

Avoid making important compatibility decisions from user-agent strings. They are unreliable, can be modified, and do not prove whether a specific feature exists.

Instead, ask the environment directly:

```js
if (typeof Array.prototype.toSorted === 'function') {
  // The feature exists.
}
```

This is like checking whether a kitchen has an oven by looking in the kitchen—not by guessing based on the building’s address.

### The Implementation

Create a feature-detection utility.

### `src/appendices/feature-detection.js`

```js
/**
 * Determines whether this runtime supports the modern APIs used in Part 4.
 *
 * @returns {{
 *   structuredClone: boolean,
 *   arrayAt: boolean,
 *   arrayToSorted: boolean,
 *   arrayToSpliced: boolean,
 *   arrayWith: boolean
 * }} Feature availability values.
 */
export function getModernApiSupport() {
  return {
    structuredClone: typeof globalThis.structuredClone === 'function',
    arrayAt: typeof Array.prototype.at === 'function',
    arrayToSorted: typeof Array.prototype.toSorted === 'function',
    arrayToSpliced: typeof Array.prototype.toSpliced === 'function',
    arrayWith: typeof Array.prototype.with === 'function'
  };
}

/**
 * Throws an informative error when one or more required APIs are unavailable.
 *
 * @param {ReturnType<typeof getModernApiSupport>} support - Support information.
 * @returns {void}
 * @throws {Error} When a required feature is missing.
 */
export function assertModernApiSupport(support) {
  const missingFeatures = [];

  if (!support.structuredClone) {
    missingFeatures.push('structuredClone()');
  }

  if (!support.arrayAt) {
    missingFeatures.push('Array.prototype.at()');
  }

  if (!support.arrayToSorted) {
    missingFeatures.push('Array.prototype.toSorted()');
  }

  if (!support.arrayToSpliced) {
    missingFeatures.push('Array.prototype.toSpliced()');
  }

  if (!support.arrayWith) {
    missingFeatures.push('Array.prototype.with()');
  }

  if (missingFeatures.length > 0) {
    throw new Error(
      `This application requires unsupported JavaScript features: ${missingFeatures.join(', ')}. ` +
        'Upgrade the runtime or load tested compatibility implementations.'
    );
  }
}
```

### `src/appendices/feature-detection-demo.js`

```js
import {
  assertModernApiSupport,
  getModernApiSupport
} from './feature-detection.js';

const support = getModernApiSupport();

console.log('Detected modern API support:');
console.table(support);

try {
  assertModernApiSupport(support);

  console.log('All required modern APIs are available.');
} catch (error) {
  console.error(error.message);

  process.exitCode = 1;
}
```

### The Verification

Run:

```bash
node src/appendices/feature-detection-demo.js
```

Expected output on Node.js 22 or newer:

```text
Detected modern API support:
┌─────────────────┬────────┐
│ (index)         │ Values │
├─────────────────┼────────┤
│ structuredClone │ true   │
│ arrayAt         │ true   │
│ arrayToSorted   │ true   │
│ arrayToSpliced  │ true   │
│ arrayWith       │ true   │
└─────────────────┴────────┘
All required modern APIs are available.
```

---

## A.6: Production Compatibility Checklist

### The Target

Create a repeatable process for deciding whether a modern JavaScript feature is safe to ship.

### The Concept

Compatibility should be an engineering decision, not a guess.

Before shipping a feature, answer:

1. Which runtimes must support it?
2. Does each runtime parse the syntax?
3. Does each runtime provide the required API?
4. Does your build process transform syntax?
5. Does your build process add only the polyfills you actually need?
6. Do automated tests run in representative environments?

This is similar to checking a bridge before opening it to traffic: materials, weight limits, and real-world conditions all matter.

### The Implementation

Add this compatibility policy template to your project documentation.

### `COMPATIBILITY.md`

```md
# JavaScript Compatibility Policy

## Supported runtimes

This project supports:

- Node.js 22 LTS and newer for server-side execution and development.
- The latest two stable versions of Chrome, Edge, Firefox, and Safari.
- Current stable mobile Safari and Chrome for Android.

## Required JavaScript capabilities

The application requires support for:

- ES modules
- Optional chaining
- Nullish coalescing
- Logical assignment operators
- Async iteration
- Set, Map, WeakSet, and WeakMap
- structuredClone()
- Array.prototype.at()
- Array.prototype.toSorted()
- Array.prototype.toSpliced()
- Array.prototype.with()

## Compatibility approach

- Server-side environments must meet the declared Node.js engine requirement.
- Browser builds are tested against the supported browser policy.
- Feature detection is preferred over user-agent detection.
- Polyfills are added only after confirming that a supported target lacks a required API.
- Any polyfill must be tested for behavioral compatibility, bundle-size impact, and security implications.
- New language features must be checked against the supported runtime matrix before adoption.

## Verification commands

```bash
node src/appendices/appendix-a-compatibility-check.js
node src/appendices/feature-detection-demo.js
npm start
```
```

### The Verification

Run:

```bash
node src/appendices/appendix-a-compatibility-check.js
node src/appendices/feature-detection-demo.js
npm start
```

All three commands should complete successfully on Node.js 22 or newer.

---

## Appendix A Quick Reference

### Safest baseline for this tutorial

```text
Node.js: 22 LTS or newer
Browsers: Current evergreen Chrome, Edge, Firefox, Safari
Module system: Native ES modules
```

### Use a transpiler when

- Your target environments cannot parse the syntax you write.
- You must support older browsers or JavaScript engines.

### Use a polyfill or compatibility helper when

- The runtime parses your code but lacks a built-in API.
- You have tested that the fallback matches your application’s required behavior.

### Prefer runtime upgrades when

- You control the runtime, such as Node.js in a backend service.
- Updating is safer and simpler than maintaining compatibility code.

### Always use feature detection for API availability

```js
const supportsToSorted = typeof Array.prototype.toSorted === 'function';
```

### Do not assume syntax transforms provide API support

```js
// Babel can transform syntax in some targets,
// but it cannot automatically make every missing runtime API exist.
const copied = structuredClone(original);
const sorted = values.toSorted();
```
