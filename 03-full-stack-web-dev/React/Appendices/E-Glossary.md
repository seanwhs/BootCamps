# Appendix E: Glossary of Terms

## Why this appendix exists

Throughout this series, we followed one strict rule: define every technical term in plain English, inline, the first time it appeared — never assume prior knowledge. That approach works wonderfully while reading linearly, but it means a term defined casually in Phase 2 might be hard to relocate later, once you actually need it in Phase 7. This glossary collects every term from across the entire series, alphabetically, each with its plain-English definition and a pointer to where it was first properly introduced.

---

**Action** — In React 19, a function passed to a `<form>`'s `action` prop (or used with `useActionState`/`startTransition`) that handles form submission or an async state transition, automatically managing pending state and preventing default page-reload behavior. *(Phase 3, Part 2)*

**API / Endpoint** — A URL that a server exposes so other programs (like our app) can ask it for data or tell it to save something. *(Phase 0)*

**`async`/`await`** — JavaScript syntax for working with Promises without chaining `.then()` calls; `await` pauses execution inside an `async` function until a Promise settles. *(Phase 4, Part 1)*

**Bubbling (event bubbling)** — The way a DOM event, once triggered on an element, "ripples" outward through every ancestor element, like a pebble dropped in a pond, unless explicitly stopped. *(Phase 2, Part 3)*

**Client-side routing** — Swapping which components are displayed based on the browser's URL, without ever requesting a new HTML document from the server. *(Phase 6, Part 1)*

**Code-splitting** — Breaking a JavaScript bundle into smaller chunks that load on demand, rather than all at once, to reduce initial load size. *(Phase 9, Part 1)*

**Component** — A reusable, self-contained "recipe" for a piece of UI, written as a JavaScript function that returns JSX. *(Phase 0; Phase 1, Part 2)*

**Container component** (vs. presentational) — A component responsible for managing state/logic and handing data down to simpler, display-focused child components. *(Phase 2, Part 1)*

**Context (Context API)** — A mechanism for sharing values across a component tree without passing them explicitly through every intermediate component's props ("prop drilling"). *(Phase 5, Part 1)*

**Controlled input** — A form input whose displayed value is explicitly set from React state and updated via `onChange`, rather than letting the browser manage it internally. *(Phase 3, Part 1)*

**CORS (Cross-Origin Resource Sharing)** — A browser security mechanism that restricts web pages from making requests to a different origin (domain/port) than the one that served them, unless the server explicitly allows it. *(Phase 4, Part 1, Reference Section)*

**CSS custom property (CSS variable)** — A reusable value defined once (e.g., `--color-bg`) and referenced throughout a stylesheet via `var(--color-bg)`, enabling theme-wide changes from a single source. *(Phase 5, Part 1)*

**Custom hook** — A JavaScript function, named starting with `use`, that calls one or more other hooks internally, packaging up reusable stateful logic. *(Phase 7, Part 2)*

**Declarative (vs. imperative)** — Describing *what* the result should look like, and letting a tool (like React) figure out *how* to achieve it, rather than manually specifying every step. *(Phase 1, Part 1)*

**Dependency array** — The optional array argument to `useEffect`, `useMemo`, `useCallback`, etc., controlling when the hook re-runs based on which listed values have changed since the last render. *(Phase 4, Part 1)*

**Descendant** — Any component nested inside another, at any depth (a child, a child's child, and so on) — as opposed to a direct child specifically. *(Phase 3, Part 3)*

**Destructuring** — A JavaScript syntax for unpacking specific values out of an object or array directly into named variables. *(Phase 1, Part 3)*

**DOM (Document Object Model)** — The browser's live, in-memory, tree-like representation of a webpage's HTML, which JavaScript can read and manipulate. *(Phase 1, Part 1)*

**Environment variable** — A configuration value that lives outside your source code, allowing the same code to behave differently (e.g., point at a different server) depending on where it runs. *(Phase 4, Part 1)*

**ESLint** — A tool that analyzes your code for likely mistakes and style issues without running it, included by default in our Vite-scaffolded project. *(Phase 1, Part 1)*

**Error Boundary** — A component (in React, currently only implementable as a class component) that catches JavaScript errors thrown by its descendants during rendering, showing fallback UI instead of crashing the whole app. *(Phase 4, Part 2)*

**ES Modules** — JavaScript's standardized system for splitting code across files using `import` and `export`. *(Phase 1, Part 1)*

**Event object** — The argument automatically passed to an event handler function, carrying details about what happened (e.g., `event.target`, `event.key`). *(Phase 2, Part 3)*

**Expression (vs. statement)** — Any piece of code that produces a value (like `2 + 2` or a ternary), as opposed to an instruction like `if` or `for` that does not itself produce a value — only expressions are valid directly inside JSX's `{ }`. *(Phase 1, Part 2)*

**Fragment** — A JSX element (`<>...</>`) that groups multiple children together without adding an actual extra element to the rendered HTML. *(Phase 1, Part 2)*

**`FormData`** — A standard browser API representing a form's field values as key/value pairs, read via `.get(name)`. *(Phase 3, Part 2)*

**Hook** — A special React function, always starting with `use`, that lets a component "hook into" React features such as state (`useState`) or side effects (`useEffect`). *(Phase 0; Phase 2, Part 1)*

**Hot Module Replacement (HMR)** — A development server feature (provided by Vite) that updates your running app in the browser instantly when you save a file, without a full page reload. *(Phase 1, Part 1)*

**Immutability / Immutable update** — The practice of never directly changing (mutating) existing data, and instead always creating new copies with the desired changes applied. *(Phase 0; Phase 2, Part 1)*

**Index route** — In React Router, the child route that renders when a parent route's URL matches exactly, with no further path segments. *(Phase 6, Part 2)*

**JSX (JavaScript XML)** — A syntax extension that lets you write HTML-looking markup directly inside JavaScript files, compiled down to plain function calls before running in the browser. *(Phase 0; Phase 1, Part 2)*

**`key` (prop)** — A special, React-reserved prop given to each item in a rendered list, letting React correctly track which item is which across re-renders, reorders, insertions, and deletions. *(Phase 2, Part 2)*

**Lazy loading** — Deferring the download of a piece of code (typically a page/component) until it's actually needed, implemented via `React.lazy()` paired with `Suspense`. *(Phase 9, Part 1)*

**Library** — A toolbox of pre-written code that you call into your own code to save yourself from writing it from scratch. *(Phase 0)*

**Lifting state up** — Moving a piece of state from a child component up to its closest common parent, so that multiple components can share and react to it. *(Phase 2, Part 1)*

**Memoization** — Caching the result of a computation (or a function/component's output) so it isn't unnecessarily redone when nothing relevant has changed; implemented in React via `useMemo`, `useCallback`, and `React.memo`. *(Phase 9, Part 1)*

**Mock (mocking)** — In testing, replacing a real function, module, or API call with a fake, controllable stand-in, so tests run quickly and deterministically without depending on real external systems. *(Phase 8, Part 1)*

**Mutation** — Directly changing an existing object or array in place, rather than creating a new one — something React's rendering model requires you to avoid for state and props. *(Phase 2, Part 1)*

**Nested route** — A route rendered inside a parent route's own layout, via an `<Outlet>` placeholder. *(Phase 6, Part 2)*

**npm (Node Package Manager)** — A tool, bundled with Node.js, for downloading code packages from the internet into your project and for running project scripts. *(Phase 1, Part 1)*

**Node.js** — A program that allows JavaScript to run directly on a computer, outside of a web browser, enabling our build tools and command-line scripts. *(Phase 1, Part 1)*

**Optimistic UI** — Showing the anticipated (hoped-for) result of an action immediately, before a server confirms it, and automatically reverting if the action ultimately fails. *(Phase 4, Part 3)*

**`Outlet`** — A React Router component acting as a placeholder inside a parent route's layout, marking exactly where the currently-matched child route's content should render. *(Phase 6, Part 2)*

**Presentational component** (vs. container) — A component whose job is purely to display data it's given via props, without managing significant logic or state of its own. *(Phase 2, Part 1)*

**Production build** — An optimized, minified, bundled version of an app intended for real users, as opposed to a development build optimized for fast iteration and debugging. *(Phase 9, Part 1)*

**Prop drilling** — Manually passing a piece of data down through several layers of components via props, even when intermediate components don't use that data themselves. *(Phase 1, Part 3)*

**Props (properties)** — Information passed into a component from its parent, bundled into a single object and received as the component function's argument. *(Phase 0; Phase 1, Part 3)*

**Provider** — The component (e.g., `<ThemeContext.Provider>`) that "publishes" a Context's current value to any descendant components that read it. *(Phase 5, Part 1)*

**Pure function / Purity** — A function that, given the same inputs, always produces the same output and has no observable effect outside of its own return value — the ideal React aims for in component rendering and reducer functions. *(Phase 4, Part 1; Phase 5, Part 2)*

**Ref** — A React object (`useRef`) that holds a value persisting across renders, but whose changes never trigger a re-render — commonly used for direct access to a DOM element. *(Phase 7, Part 1)*

**Ref-as-a-prop** — React 19's simplified pattern allowing function components to accept `ref` as an ordinary destructured prop, without requiring the older `forwardRef` wrapper. *(Phase 7, Part 1)*

**Render** — The process by which React determines what a component's UI should look like, based on its current props and state. *(Phase 0)*

**Reducer** — A pure function of the shape `(state, action) => newState`, describing every possible state transition for a piece of state in one centralized place, used with `useReducer`. *(Phase 5, Part 2)*

**Rest syntax** — The `...` syntax used within a destructuring pattern to gather remaining properties/items into a new object or array (the counterpart to the spread operator). *(Phase 2, Part 1, Reference; Appendix A)*

**Rules of Hooks** — The two core constraints on hook usage: only call hooks at the top level (never conditionally or in loops), and only call them from React components or other custom hooks. *(Phase 2, Part 1)*

**Serverless function** — A small backend function that a hosting platform runs on demand for a single request, rather than as a continuously running server process. *(Phase 9, Part 2)*

**Side effect** — Anything a piece of code does that reaches outside a pure, self-contained calculation — such as a network request, a timer, or direct DOM manipulation — handled in React via `useEffect`. *(Phase 4, Part 1)*

**Single Page Application (SPA)** — A web application that loads a single HTML page and dynamically updates its content via JavaScript, rather than requesting new HTML pages from the server for each "page" the user visits. *(Phase 1, Part 1)*

**Spread operator** — The `...` syntax used to copy the contents of an object or array into a new one, optionally overriding specific properties. *(Phase 2, Part 1)*

**State** — Data that a component "remembers" between renders, managed via hooks like `useState` or `useReducer`, and which triggers a re-render whenever it changes. *(Phase 0; Phase 2, Part 1)*

**`StrictMode`** — A React component that enables extra development-only checks (like deliberately double-invoking certain functions) to help surface bugs early; produces no visible UI itself and has no effect in production builds. *(Phase 1, Part 1)*

**Suspense** — A React component that displays fallback UI for its descendants while they're not yet ready to render (e.g., an unresolved Promise passed to `use`, or a still-loading lazy component). *(Phase 4, Part 2)*

**Template literal** — A JavaScript string syntax using backticks that allows embedded expressions via `${...}` and supports multi-line strings. *(Phase 1, Part 2, Reference; Appendix A)*

**Ternary expression** — A compact conditional expression of the form `condition ? valueIfTrue : valueIfFalse`, valid directly inside JSX curly braces since it produces a value. *(Phase 1, Part 3)*

**Transition** — Code marked via `startTransition` (or automatically, within a form Action) as non-urgent, giving React the information it needs to manage optimistic updates and lower-priority UI work correctly. *(Phase 4, Part 3)*

**Tree-shaking** — A build-time optimization that removes unused code from your final bundle by analyzing actual `import` usage. *(Phase 9, Part 1)*

**UUID (Universally Unique Identifier)** — A long, essentially-guaranteed-unique string, generated in this series via `crypto.randomUUID()`, used to assign unique ids to newly created items. *(Phase 3, Part 1)*

**Uncontrolled input** — A form input whose value is managed internally by the browser's DOM rather than by React state, typically read only at the moment it's needed (e.g., via `FormData` in an Action). *(Phase 3, Part 1; Phase 3, Part 2)*

**Vite** — The build tool and development server used throughout this series, providing fast Hot Module Replacement and an optimized production build process. *(Phase 1, Part 1)*

**Vitest** — The test runner used in this series, built by the Vite team to share Vite's configuration and transformation pipeline. *(Phase 8, Part 1)*

---

### React Hooks quick-index (where each one was introduced)

| Hook | First introduced |
|---|---|
| `useState` | Phase 2, Part 1 |
| `useEffect` | Phase 4, Part 1 |
| `useActionState` | Phase 3, Part 2 |
| `useFormStatus` | Phase 3, Part 3 |
| `use` | Phase 4, Part 2 |
| `useOptimistic` | Phase 4, Part 3 |
| `useContext` | Phase 5, Part 1 |
| `useReducer` | Phase 5, Part 2 |
| `useRef` | Phase 7, Part 1 |
| `useImperativeHandle` | Phase 7, Part 1 |
| `useCallback` | Phase 7, Part 2 (introduced); Phase 9, Part 1 (explained fully) |
| `useMemo` | Phase 9, Part 1 |
| `useParams`, `useOutletContext`, `useNavigate`, `useLocation` (React Router) | Phase 6, Part 2 |
