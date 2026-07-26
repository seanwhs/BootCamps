# References  
## Intermediate JavaScript: Asynchronous Flow & Code Organization

This reference list supports the tutorial series, student notes, workbook, trainer guide, and final application.

The sources are grouped by subject so readers can use them for further study without searching randomly.

---

# 1. JavaScript Language Reference

## MDN JavaScript Guide

Primary practical reference for JavaScript syntax and language behavior.

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide
```

Useful sections:

- Grammar and types.
- Control flow.
- Functions.
- Expressions and operators.
- Objects.
- Classes.
- Promises.
- Iterators and generators.
- Modules.
- Meta programming.

## MDN JavaScript Reference

Detailed API and syntax reference.

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference
```

Use this when you need exact information about:

- A method.
- A property.
- A constructor.
- A language operator.
- Browser support.
- Exceptions.
- Examples.

## ECMAScript Language Specification

The official JavaScript language specification maintained through Ecma International and TC39.

```text
https://tc39.es/ecma262/
```

This is authoritative but more formal than beginner-oriented documentation.

Use it when researching:

- Language semantics.
- Execution contexts.
- Objects.
- Prototypes.
- Classes.
- Promises.
- Modules.
- Built-in objects.

## TC39 Proposals

Tracks proposed and emerging JavaScript features.

```text
https://github.com/tc39/proposals
```

Use this to determine whether a feature is:

- Stage 0.
- Stage 1.
- Stage 2.
- Stage 3.
- Finished and standardized.

Do not teach experimental syntax as if it were universally supported.

---

# 2. Asynchronous JavaScript

## MDN: Asynchronous JavaScript

```text
https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous
```

Covers:

- Asynchronous programming.
- Events.
- Callbacks.
- Promises.
- `async`/`await`.
- Timeouts.
- Network requests.

## MDN: Promises

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
```

Important topics:

- Promise states.
- `then()`.
- `catch()`.
- `finally()`.
- `Promise.all()`.
- `Promise.allSettled()`.
- `Promise.race()`.
- `Promise.any()`.

## MDN: `async` Function

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function
```

## MDN: `await` Operator

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await
```

## MDN: Event Loop

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Execution_model
```

## JavaScript.info: Promises, Async/Await

Practical explanations with progressive examples.

```text
https://javascript.info/async
```

Useful chapters include:

```text
https://javascript.info/callbacks
https://javascript.info/promise-basics
https://javascript.info/promise-chaining
https://javascript.info/async-await
```

## Jake Archibald: Tasks, Microtasks, Queues and Schedules

A detailed explanation of browser scheduling.

```text
https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/
```

This is particularly useful for explaining why Promise callbacks and timer callbacks may run in different orders.

## HTML Standard: Event Loops

Formal browser event-loop specification.

```text
https://html.spec.whatwg.org/multipage/webappapis.html#event-loops
```

This is an advanced reference for trainers and experienced developers.

---

# 3. Fetch, HTTP, and APIs

## MDN: Fetch API

```text
https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
```

## MDN: `fetch()`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch
```

Important topics:

- Request creation.
- Response handling.
- Headers.
- Request bodies.
- `response.ok`.
- `response.json()`.
- Abort signals.

## MDN: Using Fetch

```text
https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
```

## MDN: Response

```text
https://developer.mozilla.org/en-US/docs/Web/API/Response
```

## MDN: Request

```text
https://developer.mozilla.org/en-US/docs/Web/API/Request
```

## MDN: Headers

```text
https://developer.mozilla.org/en-US/docs/Web/API/Headers
```

## MDN: AbortController

```text
https://developer.mozilla.org/en-US/docs/Web/API/AbortController
```

## MDN: AbortSignal

```text
https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal
```

## HTTP Semantics

Current HTTP semantics are documented by the IETF HTTP Working Group.

```text
https://httpwg.org/specs/
```

Useful specifications include:

```text
https://httpwg.org/specs/rfc9110.html
https://httpwg.org/specs/rfc9111.html
https://httpwg.org/specs/rfc9112.html
```

## HTTP Status Codes

MDN reference:

```text
https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
```

Use this for:

- `2xx` success statuses.
- `3xx` redirects.
- `4xx` client errors.
- `5xx` server errors.

## HTTP Methods

MDN reference:

```text
https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
```

## HTTP Headers

```text
https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers
```

## HTTP Cats

A memorable reference for HTTP status codes:

```text
https://http.cat/
```

This is useful for classroom demonstrations, but use MDN or the HTTP specifications for authoritative technical explanations.

---

# 4. JSON and Data Serialization

## MDN: JSON

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON
```

## `JSON.stringify()`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify
```

## `JSON.parse()`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse
```

## JSON Specification

```text
https://www.json.org/
```

## RFC 8259: JSON Data Interchange Format

```text
https://www.rfc-editor.org/rfc/rfc8259
```

Important JSON reminders:

- JSON is text.
- JSON does not preserve class prototypes.
- JSON does not preserve methods.
- JSON does not directly preserve `Date` objects.
- JSON does not support functions.
- JSON parsing can throw.

---

# 5. Prototypes, Objects, and Classes

## MDN: Inheritance and the Prototype Chain

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Inheritance_and_the_prototype_chain
```

## MDN: Classes

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes
```

## MDN: `extends`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes/extends
```

## MDN: `super`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super
```

## MDN: `new`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/new
```

## MDN: `instanceof`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/instanceof
```

## MDN: Object Prototypes

```text
https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Objects/Object_prototypes
```

## JavaScript.info: Prototypes

```text
https://javascript.info/prototypes
```

Useful chapters include:

```text
https://javascript.info/prototype-inheritance
https://javascript.info/function-prototype
https://javascript.info/native-prototypes
https://javascript.info/class
```

## ECMAScript Classes

Formal specification:

```text
https://tc39.es/ecma262/#sec-class-definitions
```

---

# 6. ES Modules

## MDN: JavaScript Modules

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
```

## MDN: `import`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import
```

## MDN: `export`

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export
```

## MDN: `<script type="module">`

```text
https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#module
```

## Node.js: ECMAScript Modules

Useful when the browser project later moves into a Node.js environment.

```text
https://nodejs.org/api/esm.html
```

Important module concepts:

- Module scope.
- Named exports.
- Default exports.
- Relative paths.
- Dependency direction.
- Circular dependencies.
- Browser loading behavior.
- Static imports.
- Dynamic imports.

---

# 7. DOM and Browser APIs

## MDN: Document Object Model

```text
https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model
```

## MDN: `querySelector()`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector
```

## MDN: `createElement()`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Document/createElement
```

## MDN: `textContent`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent
```

## MDN: `classList`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Element/classList
```

## MDN: `addEventListener()`

```text
https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
```

## MDN: Events

```text
https://developer.mozilla.org/en-US/docs/Web/Events
```

## MDN: Forms

```text
https://developer.mozilla.org/en-US/docs/Learn/Forms
```

## MDN: Form Submission

```text
https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/submit_event
```

## MDN: `preventDefault()`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault
```

---

# 8. Browser Storage

## MDN: Web Storage API

```text
https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API
```

## MDN: `localStorage`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
```

## MDN: `sessionStorage`

```text
https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage
```

## MDN: Storage Interface

```text
https://developer.mozilla.org/en-US/docs/Web/API/Storage
```

## MDN: IndexedDB

```text
https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
```

## IndexedDB Guide

```text
https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Using_IndexedDB
```

## Storage Standard

```text
https://storage.spec.whatwg.org/
```

Important storage topics:

- Origin scope.
- Quotas.
- Synchronous access.
- Storage exceptions.
- Cross-tab `storage` events.
- Data migration.
- Privacy.
- Security limitations.

---

# 9. Browser Origins and CORS

## MDN: Same-Origin Policy

```text
https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy
```

## MDN: CORS

```text
https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
```

## Fetch Standard

```text
https://fetch.spec.whatwg.org/
```

## URL Standard

```text
https://url.spec.whatwg.org/
```

## MDN: URL

```text
https://developer.mozilla.org/en-US/docs/Web/API/URL
```

## MDN: URLSearchParams

```text
https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams
```

Important CORS reminders:

- CORS is enforced by browsers.
- The server sends CORS response headers.
- Adding `Access-Control-Allow-Origin` to a browser request does not solve CORS.
- CORS is not authentication.
- CORS is not authorization.
- Same-origin requests do not normally need CORS permission.

---

# 10. Accessibility

## MDN: Accessibility

```text
https://developer.mozilla.org/en-US/docs/Web/Accessibility
```

## MDN: ARIA

```text
https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA
```

## WAI-ARIA Authoring Practices Guide

```text
https://www.w3.org/WAI/ARIA/apg/
```

Useful patterns:

- Buttons.
- Dialogs.
- Menus.
- Tabs.
- Alerts.
- Status messages.
- Keyboard interaction.

## W3C Web Accessibility Initiative

```text
https://www.w3.org/WAI/
```

## Web Content Accessibility Guidelines

```text
https://www.w3.org/TR/WCAG22/
```

## WebAIM

Practical accessibility explanations and testing guidance.

```text
https://webaim.org/
```

## Accessibility Testing Tools

### axe

```text
https://www.deque.com/axe/
```

### Lighthouse

```text
https://developer.chrome.com/docs/lighthouse
```

### Accessibility Insights

```text
https://accessibilityinsights.io/
```

Important accessibility topics:

- Semantic HTML.
- Labels.
- Keyboard navigation.
- Visible focus.
- Color contrast.
- Live regions.
- Error messaging.
- Reduced motion.
- Responsive layout.
- Screen-reader testing.

---

# 11. Web Security

## OWASP Top 10

```text
https://owasp.org/www-project-top-ten/
```

## OWASP Cheat Sheet Series

```text
https://cheatsheetseries.owasp.org/
```

Useful cheat sheets:

### Cross-Site Scripting Prevention

```text
https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html
```

### Content Security Policy

```text
https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html
```

### Cross-Site Request Forgery Prevention

```text
https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html
```

### DOM-Based XSS Prevention

```text
https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html
```

### Input Validation

```text
https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html
```

### HTTP Headers

```text
https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html
```

### Transport Layer Security

```text
https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html
```

## MDN: Web Security

```text
https://developer.mozilla.org/en-US/docs/Web/Security
```

## MDN: Content Security Policy

```text
https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
```

## MDN: Secure Contexts

```text
https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts
```

Important security principles:

- Treat external data as untrusted.
- Prefer `textContent` for plain text.
- Do not store secrets in browser storage.
- Use HTTPS in production.
- Validate on the server.
- Do not confuse authentication with authorization.
- Use security headers as defense in depth.

---

# 12. Git and Version Control

## Git Documentation

```text
https://git-scm.com/doc
```

## Git Reference

```text
https://git-scm.com/docs
```

## Git Book

```text
https://git-scm.com/book/en/v2
```

Recommended chapters:

```text
https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control
https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository
https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository
https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell
https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging
```

## GitHub Documentation

```text
https://docs.github.com/en/get-started
```

Useful topics:

- Repositories.
- Branches.
- Pull requests.
- Issues.
- Actions.
- Secret scanning.

---

# 13. Terminal and Local Development

## Python HTTP Server

```text
https://docs.python.org/3/library/http.server.html
```

Command used in the series:

```bash
python3 -m http.server 8000
```

## Visual Studio Code Documentation

```text
https://code.visualstudio.com/docs
```

## Chrome DevTools

```text
https://developer.chrome.com/docs/devtools
```

## Firefox Developer Tools

```text
https://firefox-source-docs.mozilla.org/devtools-user/
```

## Microsoft Edge DevTools

```text
https://learn.microsoft.com/en-us/microsoft-edge/devtools-guide-chromium/
```

## Safari Web Inspector

```text
https://developer.apple.com/documentation/safari-developer-tools
```

---

# 14. Testing

## MDN: Testing

```text
https://developer.mozilla.org/en-US/docs/Learn/Tools_and_testing
```

## Web Platform Tests

```text
https://web-platform-tests.org/
```

Useful for understanding how browser standards are tested.

## Vitest

A modern JavaScript testing framework.

```text
https://vitest.dev/
```

## Jest

A widely used JavaScript testing framework.

```text
https://jestjs.io/
```

## Playwright

Browser automation and end-to-end testing.

```text
https://playwright.dev/
```

## Cypress

End-to-end and component testing.

```text
https://www.cypress.io/
```

## Testing Library

```text
https://testing-library.com/
```

Important testing principles:

- Test behavior rather than implementation details.
- Keep tests isolated.
- Test success and failure paths.
- Test asynchronous cleanup.
- Test invalid and malicious input.
- Keep test names descriptive.
- Use deterministic test data.

---

# 15. TypeScript

TypeScript is an optional next step after completing the JavaScript series.

## TypeScript Handbook

```text
https://www.typescriptlang.org/docs/handbook/intro.html
```

## TypeScript for JavaScript Programmers

```text
https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html
```

## TypeScript Configuration

```text
https://www.typescriptlang.org/tsconfig/
```

Important topics:

- Interfaces.
- Type aliases.
- Union types.
- Generics.
- Narrowing.
- Strict mode.
- Compiler configuration.
- Runtime validation limitations.

TypeScript checks source code before execution. It does not validate unknown API or storage data at runtime automatically.

---

# 16. Architecture and Design

## MDN: JavaScript Modules

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
```

## Martin Fowler: Refactoring

```text
https://martinfowler.com/books/refactoring.html
```

## Martin Fowler: Inversion of Control Containers and the Dependency Injection Pattern

```text
https://martinfowler.com/articles/injection.html
```

## Martin Fowler: Patterns of Enterprise Application Architecture

```text
https://martinfowler.com/books/eaa.html
```

## Robert C. Martin: Clean Code

Book reference:

```text
https://www.oreilly.com/library/view/clean-code-a/9780136083238/
```

Use architecture references thoughtfully. The task manager is intentionally small; do not add layers merely to imitate a large enterprise system.

---

# 17. Recommended Books

## Eloquent JavaScript

Free online book:

```text
https://eloquentjavascript.net/
```

Useful for:

- JavaScript fundamentals.
- Functions.
- Objects.
- Higher-order functions.
- Asynchronous programming.
- Browser programming.

## You Don't Know JS Yet

Free online series:

```text
https://github.com/getify/You-Dont-Know-JS
```

Useful for deeper understanding of:

- Scope.
- Closures.
- Objects.
- Types.
- Asynchronous behavior.
- Classes.
- Modules.

## JavaScript: The Definitive Guide

Publisher page:

```text
https://www.oreilly.com/library/view/javascript-the-definitive/9781491952016/
```

Useful as a broad language and browser reference.

## Effective JavaScript

Publisher page:

```text
https://effectivejs.com/
```

Useful for patterns, pitfalls, and language behavior.

## Refactoring

Martin Fowler:

```text
https://martinfowler.com/books/refactoring.html
```

Useful for improving code structure safely.

---

# 18. Recommended Online Learning Resources

## JavaScript.info

```text
https://javascript.info/
```

Strong coverage of:

- Language fundamentals.
- Objects.
- Classes.
- Promises.
- Async/await.
- Modules.
- Browser APIs.

## web.dev

```text
https://web.dev/
```

Useful for:

- Performance.
- Accessibility.
- Security.
- Web APIs.
- Progressive web applications.

## MDN Learn Web Development

```text
https://developer.mozilla.org/en-US/docs/Learn
```

Useful for:

- HTML.
- CSS.
- JavaScript.
- Accessibility.
- Web forms.
- Browser APIs.

## Frontend Mentor

```text
https://www.frontendmentor.io/
```

Useful for practicing frontend interface implementation after completing the course.

---

# 19. Recommended Reference Order

Students should not attempt to read every reference at once.

Use this order.

## While Learning Asynchrony

1. MDN Asynchronous JavaScript.
2. MDN Promise.
3. MDN `async` function.
4. MDN `await`.
5. Jake Archibald’s event-loop article.

## While Learning Classes

1. MDN Objects and Prototypes.
2. MDN Classes.
3. MDN `extends`.
4. MDN `super`.
5. ECMAScript class definitions.

## While Learning Modules

1. MDN JavaScript Modules.
2. MDN `import`.
3. MDN `export`.
4. Node.js ECMAScript Modules if moving beyond browsers.

## While Learning Storage

1. MDN Web Storage API.
2. MDN `localStorage`.
3. MDN `sessionStorage`.
4. MDN IndexedDB.

## While Preparing for Production

1. MDN Web Security.
2. OWASP Top 10.
3. OWASP XSS Prevention.
4. OWASP Content Security Policy.
5. WCAG.
6. WebAIM.

---

# 20. Reference Evaluation Checklist

When selecting a technical source, ask:

- Is it maintained?
- Is it from a standards organization or reputable documentation project?
- Does it identify browser compatibility?
- Does it distinguish normative behavior from advice?
- Does it show error handling?
- Does it explain security implications?
- Does it avoid outdated syntax?
- Does it provide runnable examples?
- Does it clearly state assumptions?
- Does it match the environment being used?

Prefer:

```text
MDN
WHATWG
W3C
TC39
IETF
OWASP
Official tool documentation
```

Use blogs and videos for alternate explanations, but verify important claims against authoritative documentation.

---

# 21. Source-Selection Notes for Trainers

When presenting a claim, distinguish among:

## Standard

What the platform specification defines.

Examples:

- ECMAScript.
- HTML.
- Fetch.
- URL.
- HTTP.

## Browser Behavior

What browsers commonly implement.

Examples:

- Developer Tools behavior.
- Cache behavior.
- Storage limits.
- Background-tab throttling.

## Engineering Recommendation

A maintainability or security practice.

Examples:

- Prefer `const`.
- Use `textContent`.
- Keep API modules separate.
- Put cleanup in `finally`.

Students benefit from knowing whether a statement is:

```text
Required by the language
Common browser behavior
Recommended engineering practice
```

---

# 22. Final Reference Map

```text
JavaScript language
  → MDN JavaScript Guide
  → ECMAScript specification
  → JavaScript.info

Asynchrony
  → MDN Asynchronous JavaScript
  → Promise reference
  → Event-loop explanations
  → HTML Standard

HTTP and APIs
  → Fetch Standard
  → MDN Fetch
  → HTTP specifications
  → MDN status codes

DOM and browser APIs
  → MDN Web APIs
  → DOM documentation

Storage
  → Web Storage API
  → IndexedDB documentation
  → Storage Standard

Accessibility
  → WCAG
  → WAI-ARIA APG
  → WebAIM
  → Accessibility testing tools

Security
  → OWASP Top 10
  → OWASP Cheat Sheets
  → MDN Web Security

Testing
  → Testing Library
  → Playwright
  → Vitest
  → Web Platform Tests

Version control
  → Git documentation
  → Git Book
  → Hosting-service documentation
```

---

# 23. Essential Reference List

If students only bookmark a small set of pages, use these:

```text
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function
https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API
https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
https://developer.mozilla.org/en-US/docs/Web/Accessibility
https://owasp.org/www-project-top-ten/
https://git-scm.com/book/en/v2
https://playwright.dev/
https://www.w3.org/TR/WCAG22/
```

