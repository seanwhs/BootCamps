# ES6+ Modern JavaScript  
## References and Resources Guide

This guide supports the full **Modern JavaScript Toolkit** series. It prioritizes primary specifications, official runtime documentation, trustworthy compatibility references, and practical learning resources.

Use these resources in this order:

1. **Primary reference:** ECMAScript specification  
2. **Practical API reference:** MDN Web Docs  
3. **Runtime reference:** Node.js documentation  
4. **Compatibility reference:** MDN Browser Compatibility Data and Can I use  
5. **Practice:** Node.js exercises, tests, and small projects  

---

# 1. Essential Reference Sites

## ECMAScript Language Specification

**Use for:** Precise language behavior, syntax rules, algorithms, and standards terminology.

- ECMAScript specification:  
  https://tc39.es/ecma262/

- TC39, the committee responsible for evolving ECMAScript:  
  https://tc39.es/

- TC39 proposal process and proposal status:  
  https://github.com/tc39/proposals

### Best use cases

Consult the specification when you need to answer questions such as:

- What exactly does optional chaining do?
- How does destructuring evaluate defaults?
- How are `Map` keys compared?
- What values can `structuredClone()` clone in a particular runtime?
- What stage is a proposed JavaScript feature in?

> The specification is authoritative but dense. For everyday development, start with MDN and use the specification when exact behavior matters.

---

## MDN Web Docs

**Use for:** Practical explanations, examples, syntax references, browser compatibility, and related API links.

- JavaScript Guide:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide

- JavaScript Reference:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference

- ECMAScript language overview:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Grammar_and_types

### Core language features

| Topic | Reference |
|---|---|
| `const` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/const |
| `let` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let |
| Destructuring | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring |
| Rest parameters | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters |
| Spread syntax | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax |
| Arrow functions | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions |
| Template literals | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals |
| Object initializer | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Object_initializer |
| Optional chaining | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining |
| Nullish coalescing | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing |
| Logical assignment | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Logical_assignment |

### Collections and iteration

| Topic | Reference |
|---|---|
| `Set` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set |
| `Map` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map |
| `WeakSet` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet |
| `WeakMap` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap |
| Iteration protocols | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols |
| Generators | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Generator |
| `function*` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function* |
| `for...of` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of |
| `for await...of` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for-await...of |

### Modern defensive APIs

| Topic | Reference |
|---|---|
| `structuredClone()` | https://developer.mozilla.org/en-US/docs/Web/API/Window/structuredClone |
| `Array.prototype.at()` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/at |
| `Array.prototype.toSorted()` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toSorted |
| `Array.prototype.toSpliced()` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toSpliced |
| `Array.prototype.with()` | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/with |

---

# 2. Node.js Resources

## Official Node.js Documentation

**Use for:** Node.js runtime behavior, ES modules, `process`, environment variables, CLI usage, debugging, and built-in APIs.

- Node.js documentation:  
  https://nodejs.org/docs/latest/api/

- Node.js downloads and release information:  
  https://nodejs.org/

- Node.js release schedule:  
  https://github.com/nodejs/release#release-schedule

### Important Node.js Documentation Pages

| Topic | Reference |
|---|---|
| ES modules | https://nodejs.org/api/esm.html |
| CommonJS modules | https://nodejs.org/api/modules.html |
| `process` | https://nodejs.org/api/process.html |
| Environment variables | https://nodejs.org/api/environment_variables.html |
| Command-line options | https://nodejs.org/api/cli.html |
| Debugger | https://nodejs.org/api/debugger.html |
| Inspector | https://nodejs.org/api/inspector.html |
| Node.js REPL | https://nodejs.org/api/repl.html |
| `node:assert` | https://nodejs.org/api/assert.html |
| Test runner | https://nodejs.org/api/test.html |

### Recommended Runtime Policy

For the tutorial project:

```json
{
  "engines": {
    "node": ">=22.0.0"
  }
}
```

Use a currently supported Node.js LTS release for production applications whenever possible.

Check your version:

```bash
node --version
```

---

# 3. Browser Compatibility Resources

## MDN Browser Compatibility Data

**Use for:** Feature support details across Chrome, Edge, Firefox, Safari, mobile browsers, and browser versions.

- MDN Browser Compatibility Data repository:  
  https://github.com/mdn/browser-compat-data

MDN feature pages usually include a **Browser compatibility** section near the bottom.

For example, inspect compatibility for:

- Optional chaining
- `structuredClone()`
- `.toSorted()`
- `.toSpliced()`
- `.with()`
- Async generators

---

## Can I use

**Use for:** Quick visual browser-support checks.

- Can I use:  
  https://caniuse.com/

Useful searches:

- Optional chaining
- Nullish coalescing operator
- `structuredClone`
- ES modules
- Async functions
- JavaScript built-in APIs

> Use Can I use for quick planning. Use MDN and real-device/browser testing for implementation decisions.

---

## Feature Detection

Do not rely on browser names or user-agent strings for API availability. Detect the feature directly.

```js
const supportsStructuredClone =
  typeof globalThis.structuredClone === 'function';

const supportsToSorted =
  typeof Array.prototype.toSorted === 'function';

const supportsArrayWith =
  typeof Array.prototype.with === 'function';
```

Useful references:

- Feature detection overview on MDN:  
  https://developer.mozilla.org/en-US/docs/Learn/Tools_and_testing/Cross_browser_testing/Feature_detection

- Modernizr feature detection library:  
  https://modernizr.com/

---

# 4. JavaScript Style, Quality, and Formatting Resources

## ESLint

**Use for:** Detecting likely JavaScript mistakes and enforcing selected coding rules.

- ESLint documentation:  
  https://eslint.org/docs/latest/

- ESLint rule reference:  
  https://eslint.org/docs/latest/rules/

Useful rules for this series:

```js
'no-var': 'error',
'prefer-const': 'error',
'object-shorthand': ['error', 'always'],
'prefer-template': 'error'
```

---

## Prettier

**Use for:** Automatic formatting.

- Prettier documentation:  
  https://prettier.io/docs/

- Prettier options:  
  https://prettier.io/docs/options

Recommended workflow:

```bash
npm run lint
npm run format:check
npm run format
```

---

## JavaScript Standard Style

**Use for:** An opinionated, simple JavaScript style convention.

- JavaScript Standard Style:  
  https://standardjs.com/

This is optional. The course uses its own conventions, but learners may find Standard useful when joining projects that use it.

---

# 5. Testing Resources

## Node.js Built-In Test Runner

**Use for:** Testing Node.js projects without adding a third-party test framework.

- Node.js test module:  
  https://nodejs.org/api/test.html

Example:

```js
import assert from 'node:assert/strict';
import test from 'node:test';

test('adds two numbers', () => {
  const total = 2 + 3;

  assert.equal(total, 5);
});
```

Run:

```bash
node --test
```

---

## Vitest

**Use for:** Fast unit testing in modern JavaScript and TypeScript projects.

- Vitest:  
  https://vitest.dev/

Recommended for learners moving into frontend frameworks, Vite projects, or larger test suites.

---

## Jest

**Use for:** A widely used JavaScript testing framework.

- Jest:  
  https://jestjs.io/

Jest remains common in existing projects. New projects should choose tools based on their ecosystem rather than popularity alone.

---

# 6. Package and Dependency Resources

## npm Documentation

**Use for:** Packages, scripts, package configuration, semantic versioning, and dependency management.

- npm documentation:  
  https://docs.npmjs.com/

- `package.json` reference:  
  https://docs.npmjs.com/cli/configuring-npm/package-json

- npm scripts reference:  
  https://docs.npmjs.com/cli/using-npm/scripts

Useful commands:

```bash
npm run
npm install
npm install --save-dev eslint prettier
npm outdated
npm audit
```

> Treat `npm audit` as one signal, not an automatic instruction to upgrade everything. Review dependency compatibility and test changes before shipping.

---

# 7. Secure JavaScript Development Resources

## OWASP

**Use for:** Secure application-development practices.

- OWASP:  
  https://owasp.org/

- OWASP Top 10:  
  https://owasp.org/www-project-top-ten/

- OWASP Cheat Sheet Series:  
  https://cheatsheetseries.owasp.org/

Recommended cheat sheets:

- Input Validation:  
  https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html

- Node.js Security:  
  https://cheatsheetseries.owasp.org/cheatsheets/Nodejs_Security_Cheat_Sheet.html

- Cross Site Scripting Prevention:  
  https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html

## Security Reminders from This Series

- Validate external input.
- Do not log passwords, tokens, private keys, or secrets.
- Do not hard-code secrets in source files.
- Use environment variables for environment-specific configuration.
- Do not assume basic HTML escaping is sufficient for every output context.
- Avoid using untrusted strings with dangerous browser APIs such as `innerHTML`.
- Treat dependency updates as tested changes, not automatic fixes.

---

# 8. Learning and Practice Resources

## JavaScript.info

**Use for:** Structured explanations, practical examples, and exercises.

- JavaScript.info:  
  https://javascript.info/

Useful sections:

- JavaScript fundamentals
- Objects
- Data types
- Promises and async/await
- Modules
- Generators and advanced iteration

---

## MDN Learning Area

**Use for:** Beginner-friendly browser and web-development lessons.

- MDN Learn Web Development:  
  https://developer.mozilla.org/en-US/docs/Learn

Useful for learners who want to continue from Node.js fundamentals into browser programming.

---

## Exercism JavaScript Track

**Use for:** Small exercises with community mentoring options.

- Exercism JavaScript track:  
  https://exercism.org/tracks/javascript

Practice suggestions:

- Complete one exercise after each course part.
- Rewrite the solution after receiving feedback.
- Compare solutions only after attempting the problem independently.

---

## Codewars

**Use for:** Short algorithm and syntax practice challenges.

- Codewars JavaScript challenges:  
  https://www.codewars.com/

Use carefully. Codewars can encourage very short “clever” solutions. In this series, prioritize readable and maintainable code over minimizing line count.

---

## LeetCode

**Use for:** Data structures, algorithms, and interview-style practice.

- LeetCode:  
  https://leetcode.com/

Recommended after learners are comfortable with:

- Arrays
- Objects
- Maps
- Sets
- Iteration
- Functions
- Error handling

---

# 9. Recommended Books

## *Eloquent JavaScript* — Marijn Haverbeke

- Official website:  
  https://eloquentjavascript.net/

Best for:

- Learners who want a free, structured JavaScript book
- Functions, objects, higher-order functions, and asynchronous programming
- Building deeper programming intuition

---

## *You Don’t Know JS Yet* — Kyle Simpson

- Official GitHub repository:  
  https://github.com/getify/You-Dont-Know-JS

Best for:

- Understanding JavaScript deeply
- Scope, closures, `this`, objects, prototypes, and async behavior
- Intermediate learners who want more than surface syntax

---

## *JavaScript: The Definitive Guide* — David Flanagan

Best for:

- Comprehensive desk reference
- More advanced learners
- Detailed language and platform coverage

---

## *Effective JavaScript* — David Herman

Best for:

- Understanding robust JavaScript practices
- Intermediate developers
- Reasoning about language behavior and design choices

> Check publication dates and language coverage when buying JavaScript books. Modern APIs such as `.toSorted()` and `.with()` may not appear in older editions.

---

# 10. Recommended Video and Conference Resources

## JSConf

- JSConf:  
  https://jsconf.com/

Useful for:

- JavaScript ecosystem perspectives
- Language design discussions
- Advanced practices

---

## Node.js YouTube Channel

- Node.js YouTube:  
  https://www.youtube.com/@nodejs

Useful for:

- Node.js ecosystem updates
- Runtime talks
- Community and release information

---

## TC39 Meeting Notes and Proposals

- TC39 GitHub organization:  
  https://github.com/tc39

Useful for:

- Understanding where future JavaScript features originate
- Tracking proposal maturity
- Learning the difference between proposal stages and standardized language features

> Do not adopt a proposal in production merely because it is discussed publicly. Check its stage, runtime support, and organizational compatibility policy.

---

# 11. Tooling Resources for Continued Growth

## TypeScript

**Use for:** Static type checking in larger JavaScript applications.

- TypeScript handbook:  
  https://www.typescriptlang.org/docs/handbook/intro.html

Recommended next step after learners are comfortable with:

- Objects and arrays
- Functions
- Modules
- Optional values
- Runtime validation
- JavaScript debugging

Important note:

> TypeScript improves development-time feedback, but it does not validate unknown runtime input by itself. External data still needs validation.

---

## Vite

**Use for:** Modern frontend tooling and development servers.

- Vite:  
  https://vite.dev/

Recommended after learners want to build browser applications with modern ES modules.

---

## React

- React documentation:  
  https://react.dev/

Useful after learners understand:

- Functions
- Arrays
- Immutable updates
- Object spread
- `.map()`
- `.filter()`
- Async data handling

---

## Vue

- Vue documentation:  
  https://vuejs.org/

Useful for learners interested in a progressive frontend framework with a gentler initial learning curve.

---

## Svelte

- Svelte documentation:  
  https://svelte.dev/docs

Useful for learners who want a compiler-oriented frontend framework with concise component syntax.

---

# 12. Reference by Tutorial Module

## Primer 0: Setup and Workflow

- Node.js downloads:  
  https://nodejs.org/

- npm documentation:  
  https://docs.npmjs.com/

- `package.json` reference:  
  https://docs.npmjs.com/cli/configuring-npm/package-json

---

## Primer 1: Runtime and Tooling

- Node.js `process`:  
  https://nodejs.org/api/process.html

- Node.js command-line options:  
  https://nodejs.org/api/cli.html

- Node.js REPL:  
  https://nodejs.org/api/repl.html

- Environment variables:  
  https://nodejs.org/api/environment_variables.html

---

## Primer 2: Values, Objects, and Arrays

- JavaScript data types:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Data_structures

- Objects:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Working_with_objects

- Arrays:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array

- `structuredClone()`:  
  https://developer.mozilla.org/en-US/docs/Web/API/Window/structuredClone

---

## Primer 3: Functions and Iteration

- Functions:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Functions

- Control flow:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Control_flow_and_error_handling

- `for...of`:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of

- Array methods:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array

---

## Primer 4: Modules and Debugging

- JavaScript modules guide:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules

- Node.js ES modules:  
  https://nodejs.org/api/esm.html

- Node.js debugger:  
  https://nodejs.org/api/debugger.html

- Node.js inspector:  
  https://nodejs.org/api/inspector.html

---

## Part 1: Syntax Ergonomics and Destructuring

- `const`:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/const

- `let`:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let

- Destructuring:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring

- Spread syntax:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax

- Rest parameters:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters

---

## Part 2: Expressive Syntax

- Arrow functions:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions

- Template literals:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals

- Object initializer:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Object_initializer

---

## Part 3: Collections and Iteration

- `Set`:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set

- `Map`:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map

- `WeakSet`:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet

- `WeakMap`:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap

- Iteration protocols:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols

- Generators:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Generator

---

## Part 4: Defensive Coding and Modern APIs

- Optional chaining:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining

- Nullish coalescing:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing

- Logical assignment:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Logical_assignment

- `structuredClone()`:  
  https://developer.mozilla.org/en-US/docs/Web/API/Window/structuredClone

- Immutable array copying methods:  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array#copying_methods_and_mutating_methods

---

# 13. Suggested Reference Workflow

When learners encounter a JavaScript question, use this sequence.

## Step 1: Reproduce the behavior

Create the smallest runnable example.

```js
const pageSize = 0;

console.log(pageSize || 25);
console.log(pageSize ?? 25);
```

## Step 2: Read MDN

Look up the syntax or API on MDN.

## Step 3: Check runtime support

Use Node.js version checks or browser compatibility data.

```bash
node --version
```

```js
console.log(
  typeof Array.prototype.toSorted === 'function'
);
```

## Step 4: Read the specification only if needed

Use the ECMAScript specification for exact details, edge cases, or standards-level behavior.

## Step 5: Add a test

Turn the discovery into a repeatable check.

```js
import assert from 'node:assert/strict';

assert.equal(0 ?? 25, 0);
```

---

# 14. Recommended Next Learning Paths

After completing the series, choose a direction.

| Goal | Recommended next topic |
|---|---|
| Build web interfaces | React, Vue, Svelte, or Angular |
| Build backend APIs | Node.js HTTP, Express, Fastify, or NestJS |
| Improve large-project safety | TypeScript |
| Improve quality | Unit testing, integration testing, test-driven development |
| Work with databases | PostgreSQL, SQL, Prisma, Drizzle, MongoDB |
| Build secure systems | OWASP, authentication, authorization, input validation |
| Prepare for interviews | Data structures, algorithms, LeetCode |
| Improve deployment skills | Docker, CI/CD, cloud platforms |
| Learn browser APIs | DOM, Fetch API, Web Storage, Web Workers |
| Improve architecture | Clean architecture, domain modeling, API design |

---

# 15. Final Resource Checklist

## Essential Bookmarks

- [ ] MDN JavaScript Reference  
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference

- [ ] ECMAScript Specification  
  https://tc39.es/ecma262/

- [ ] Node.js Documentation  
  https://nodejs.org/docs/latest/api/

- [ ] npm Documentation  
  https://docs.npmjs.com/

- [ ] MDN Browser Compatibility Data  
  https://github.com/mdn/browser-compat-data

- [ ] Can I use  
  https://caniuse.com/

- [ ] ESLint  
  https://eslint.org/

- [ ] Prettier  
  https://prettier.io/

- [ ] OWASP Cheat Sheet Series  
  https://cheatsheetseries.owasp.org/

- [ ] JavaScript.info  
  https://javascript.info/

- [ ] Exercism JavaScript Track  
  https://exercism.org/tracks/javascript
