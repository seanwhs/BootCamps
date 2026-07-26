# Phase 1: Foundations
# Part 2: JSX Syntax & Your First Components

## Introduction: What we're doing in this part

Right now, our entire app is one function in one file, printing two lines of static text. That's a fine "hello world," but our Task & Habit Tracker will eventually have a navbar, task cards, habit cards, buttons, and forms — dozens of pieces. In this part, you'll learn:

1. What JSX actually is under the hood, and the strict rules it enforces.
2. How to embed real JavaScript values inside your markup.
3. What a **component** is, and why splitting an app into many small components is the single most important organizational habit in React.
4. How to build the first real, multi-component, static shell of our Tracker's UI — a header, a dashboard section, and placeholder cards — all wired together.

By the end, clicking around at `localhost:5173` will show an actual (if still non-interactive) skeleton of the real app you're building for the rest of this series.

---

## 🎯 The Target: Understanding what JSX really is

### 🧠 The Concept: JSX is a translator, not a new language

Look again at what we wrote in `App.jsx` last part:

```jsx
return (
  <div>
    <h1>Task & Habit Tracker</h1>
  </div>
)
```

That `<div>` and `<h1>` are **not** HTML, and this is **not** a template language bolted onto JavaScript. This is **JSX** (JavaScript XML) — a syntax extension that lets you write HTML-*looking* markup directly inside a `.jsx` JavaScript file. A build-time tool (Vite uses a plugin, `@vitejs/plugin-react`, powered by a compiler called Babel/SWC) transforms this markup before your browser ever sees it.

Here's the important reveal: the JSX above literally **becomes** this plain JavaScript function call:

```javascript
return React.createElement(
  'div',
  null,
  React.createElement('h1', null, 'Task & Habit Tracker')
)
```

`React.createElement(type, props, ...children)` just builds a plain JavaScript object describing "I want an element of this type, with these properties, containing these children" — it does **not** touch the real screen yet. Think of it like an architect's blueprint versus the actual built house: `React.createElement` produces the blueprint (a description), and React itself is the construction crew that reads the blueprint and builds/updates the real DOM to match.

You will never write `React.createElement` by hand in this series — JSX exists specifically so you don't have to. But understanding that JSX is "just JavaScript function calls wearing an HTML costume" demystifies a lot of what's coming, especially the rules below.

### 🛠️ The Implementation: Seeing the transformation live

No new file needed for this — just an observation exercise. Open your browser's DevTools (F12 or right-click → Inspect) while `localhost:5173` is open, go to the **Sources** tab, and look for `src/App.jsx` under `localhost:5173`. Vite serves your original JSX source there (for debugging), but if you check the **Network** tab and look at what's actually requested, you'll see Vite is transforming it on the fly before delivery. We won't dig deeper into the compiler internals — just know this translation step is happening automatically, every single save.

### ✅ The Verification

No code changes yet — this was purely conceptual. Confirm your dev server from Part 1 is still running and showing the Task & Habit Tracker heading before continuing.

---

## 🎯 The Target: Learning JSX's strict rules

### 🧠 The Concept: JSX is pickier than HTML on purpose

Browsers are famously forgiving of sloppy HTML (an unclosed `<img>` tag usually still renders fine). JSX, because it's actually compiling down to JavaScript function calls, cannot afford to guess — a function call needs unambiguous syntax. So JSX enforces a few strict rules that HTML doesn't.

### 🛠️ The Implementation: The four rules, demonstrated

**Rule 1 — Every element must be closed.**

```jsx
// ❌ Invalid JSX — HTML allows this, JSX does not
<img src="/logo.png">
<br>

// ✅ Valid JSX — self-closing tags need the trailing slash
<img src="/logo.png" />
<br />
```

**Rule 2 — A component can only return one root element.**

```jsx
// ❌ Invalid — two sibling elements with nothing wrapping them
function Broken() {
  return (
    <h1>Title</h1>
    <p>Paragraph</p>
  )
}

// ✅ Valid — wrapped in a single parent <div>
function Fixed() {
  return (
    <div>
      <h1>Title</h1>
      <p>Paragraph</p>
    </div>
  )
}

// ✅ Also valid — a "Fragment" (<>...</>) groups elements
// WITHOUT adding an extra real HTML element to the page.
function AlsoFixed() {
  return (
    <>
      <h1>Title</h1>
      <p>Paragraph</p>
    </>
  )
}
```

The Fragment (`<>` and `</>`) exists because sometimes you genuinely don't want an extra wrapping `<div>` cluttering your HTML output (e.g., it might break CSS grid/flex layouts that expect direct children). We'll use Fragments a few times in this series.

**Rule 3 — Use `className`, not `class`.**

`class` is a reserved word in JavaScript (used for defining classes, a different concept entirely), so JSX uses `className` for the HTML `class` attribute instead:

```jsx
// ❌ Will cause a React warning, and styles won't reliably apply
<div class="card">...</div>

// ✅ Correct
<div className="card">...</div>
```

**Rule 4 — Embed JavaScript expressions with single curly braces `{ }`.**

This is the most powerful rule: anywhere inside JSX, wrapping something in `{ }` drops back into plain JavaScript "expression mode." An **expression** is anything that produces a value (like `2 + 2`, or a variable, or a function call) — as opposed to a **statement**, which is an instruction (like `if` or `for`), which JSX curly braces do *not* directly support.

```jsx
function Greeting() {
  const userName = "Alex" // a plain JavaScript variable
  const taskCount = 3

  return (
    <div>
      {/* This is how you write a comment inside JSX, by the way! */}
      <h1>Hello, {userName}!</h1>
      <p>You have {taskCount} tasks remaining.</p>
      <p>Math also works: 2 + 2 = {2 + 2}</p>
    </div>
  )
}
```

### ✅ The Verification

Temporarily paste the `Greeting` function above into your `App.jsx` (replacing the current `App` function), rename it to `App`, and view the browser. You should see:

```
Hello, Alex!
You have 3 tasks remaining.
Math also works: 2 + 2 = 4
```

Once you've confirmed this works, don't worry about keeping this file — we're about to replace it properly in the next step.

---

## 🎯 The Target: Understanding components — the core unit of React

### 🧠 The Concept: Components are reusable cookie cutters

A **component** is just a JavaScript function that returns JSX (describing what a piece of UI should look like), following one strict naming convention: **component function names must start with a capital letter** (e.g., `App`, `Navbar`, `TaskCard` — not `navbar` or `taskCard`). This isn't just a style preference — it's how React tells the difference between "this is a real HTML tag" (`<div>`, lowercase) versus "this is one of my custom components" (`<Navbar />`, capitalized) when compiling JSX.

Think of a component like a cookie cutter. You design the cutter once (the component function), and then you can stamp out as many cookies (instances on the screen) as you want, each one identical in shape but potentially decorated differently (we'll cover that "decorating differently" part — called **props** — in Part 3).

The entire discipline of good React code comes down to one habit: **when a piece of UI does one clear job, give it its own component, in its own file.** This makes each piece easy to find, easy to reason about in isolation, and easy to reuse.

### 🛠️ The Implementation: Planning our component tree

Before writing code, let's sketch what components our Tracker's main screen actually needs. This is a skill worth practicing deliberately: look at a design, and mentally draw boxes around distinct, reusable chunks.

```
App
├── Navbar                (top bar with app name)
└── Dashboard
    ├── HabitsSection
    │   └── HabitCard      (repeated for each habit — static for now)
    └── TasksSection
        └── TaskCard       (repeated for each task — static for now)
```

This tree is our plan for this part. We will not yet make the cards dynamic/repeated from real data (that requires state and `.map()`, arriving in Phase 2) — instead we'll hardcode two or three example cards directly, so we can focus purely on component structure and JSX right now.

### 🛠️ The Implementation: Creating the `components` folder

Following the project structure we previewed in Part 0, create a new folder for our reusable UI pieces:

```bash
mkdir src/components
```

**File: `src/components/Navbar.jsx`**

```jsx
// Navbar is a "presentational" component — it only displays things,
// it doesn't manage any data yet. That will change in later parts.
function Navbar() {
  return (
    <nav className="navbar">
      <h1 className="navbar-title">📝 Task & Habit Tracker</h1>
    </nav>
  )
}

export default Navbar
```

**File: `src/components/HabitCard.jsx`**

```jsx
// A single habit's card. For now, the content is hardcoded (static).
// In Phase 2, this component will receive its data as props instead.
function HabitCard() {
  return (
    <div className="card habit-card">
      <span className="card-checkbox">☐</span>
      <span className="card-label">Drink 8 glasses of water</span>
      <span className="card-streak">🔥 5</span>
    </div>
  )
}

export default HabitCard
```

**File: `src/components/TaskCard.jsx`**

```jsx
// A single task's card. Also hardcoded/static for now.
function TaskCard() {
  return (
    <div className="card task-card">
      <span className="card-checkbox">☐</span>
      <span className="card-label">Finish React tutorial</span>
    </div>
  )
}

export default TaskCard
```

Now let's build the two "section" components that group these cards together, plus headings and (soon) an "add new" affordance:

**File: `src/components/HabitsSection.jsx`**

```jsx
import HabitCard from './HabitCard.jsx'

// This section renders the habits area of the dashboard.
// Right now it renders a fixed number of HabitCards by hand;
// in Phase 2 Part 2 we'll replace this with a real, dynamic list.
function HabitsSection() {
  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Today's Habits</h2>
      </div>
      <div className="card-list">
        <HabitCard />
        <HabitCard />
      </div>
    </section>
  )
}

export default HabitsSection
```

**File: `src/components/TasksSection.jsx`**

```jsx
import TaskCard from './TaskCard.jsx'

function TasksSection() {
  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Tasks</h2>
      </div>
      <div className="card-list">
        <TaskCard />
        <TaskCard />
        <TaskCard />
      </div>
    </section>
  )
}

export default TasksSection
```

Now, a `Dashboard` component that combines both sections — this maps directly to the "Dashboard" box in our tree above:

**File: `src/components/Dashboard.jsx`**

```jsx
import HabitsSection from './HabitsSection.jsx'
import TasksSection from './TasksSection.jsx'

// Dashboard is a "layout" component — its only job is to arrange
// other components together. It holds no content of its own.
function Dashboard() {
  return (
    <main className="dashboard">
      <HabitsSection />
      <TasksSection />
    </main>
  )
}

export default Dashboard
```

Finally, update `App.jsx` to assemble the whole tree, exactly matching our plan:

**File: `src/App.jsx`**

```jsx
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'

// App is the root of our component tree. Its job, from now on,
// is purely to lay out the top-level pieces of the whole application.
function App() {
  return (
    <div className="app">
      <Navbar />
      <Dashboard />
    </div>
  )
}

export default App
```

### ✅ The Verification

Save every file above. Look at `localhost:5173` in your browser. You should now see (unstyled, plain-looking, but structurally correct):

```
📝 Task & Habit Tracker

Today's Habits
☐ Drink 8 glasses of water 🔥 5
☐ Drink 8 glasses of water 🔥 5

Tasks
☐ Finish React tutorial
☐ Finish React tutorial
☐ Finish React tutorial
```

Open DevTools → **Elements** tab (or **Inspector** in Firefox), and expand the DOM tree. Confirm you can see real `<nav class="navbar">`, `<section class="dashboard-section">`, and `<div class="card habit-card">` elements — proof that each of your components rendered its JSX into genuine DOM nodes, nested exactly the way our component tree diagram predicted.

**Try this:** Temporarily delete the second `<HabitCard />` line from `HabitsSection.jsx` and save. Watch the browser instantly show only one habit card. This confirms components truly are reusable, independent building blocks — removing or adding one instance doesn't affect the others. Afterward, put the line back so we have two habit cards again.

---

## 🎯 The Target: Adding real (if temporary) styling

### 🧠 The Concept: CSS classes as "costumes," not structure

Our HTML structure is correct, but it looks like a bare, unstyled document. We're not doing a deep CSS lesson in this series (any CSS knowledge you already have transfers directly), but we do want our app to look presentable as we go, so verification steps feel like a real app rather than a wall of text. We'll steadily grow this stylesheet across the series.

### 🛠️ The Implementation

Replace `src/index.css` with this expanded version, which styles every class name we just used above:

**File: `src/index.css`**

```css
/* A minimal, sane baseline. We'll expand this significantly over the series. */

* {
  box-sizing: border-box; /* Makes width/height calculations include padding & border, avoiding surprise overflow */
}

body {
  margin: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  background-color: #f7f7f8;
  color: #1a1a1a;
}

.app {
  max-width: 720px;
  margin: 0 auto; /* centers the app horizontally on wide screens */
  padding: 0 1rem 3rem;
}

/* --- Navbar --- */

.navbar {
  padding: 1.25rem 0;
  border-bottom: 1px solid #e0e0e0;
  margin-bottom: 1.5rem;
}

.navbar-title {
  margin: 0;
  font-size: 1.4rem;
}

/* --- Dashboard layout --- */

.dashboard {
  display: flex;
  flex-direction: column;
  gap: 2rem; /* vertical space between HabitsSection and TasksSection */
}

.dashboard-section {
  background: white;
  border-radius: 12px;
  padding: 1rem 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.section-header h2 {
  margin: 0;
  font-size: 1.1rem;
}

/* --- Cards --- */

.card-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.card {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.65rem 0.85rem;
  border: 1px solid #ececec;
  border-radius: 8px;
}

.card-checkbox {
  font-size: 1.1rem;
  cursor: pointer; /* signals interactivity, even though it doesn't do anything yet */
}

.card-label {
  flex: 1; /* takes up remaining horizontal space, pushing streak to the right */
}

.card-streak {
  font-size: 0.9rem;
  color: #a45c00;
}
```

### ✅ The Verification

Save the file. `localhost:5173` should now show a centered, card-based layout: a bordered navbar, two white rounded panels ("Today's Habits" and "Tasks") each with a soft shadow, and individual bordered rows for each card with a checkbox glyph on the left and (for habits) a streak count on the right.

Resize your browser window narrower and wider — the `.app` container should stay centered and capped at `720px` wide, confirming the layout rule is working.

---

## 📚 Reference Section: Phase 1, Part 2

### JSX curly-brace rules, more precisely

Inside `{ }` in JSX, you can put **any valid JavaScript expression**: variables, arithmetic, function calls, ternary expressions (`condition ? a : b`), template literals, etc. You **cannot** put statements like `if`, `for`, or variable declarations (`const x = 5`) directly inside `{ }` — those need to happen *before* the `return`, as regular lines of the function body. This distinction (expression vs. statement) will matter a lot once we reach conditional rendering in Phase 2, Part 3.

```jsx
function Example({ isDone }) {
  // ✅ Statements go here, above the return
  const label = isDone ? "Complete" : "Pending"

  return (
    <p>
      {/* ✅ Expressions go inside curly braces in the JSX itself */}
      Status: {label}
    </p>
  )
}
```

(Don't worry about the `{ isDone }` syntax in the function parameters yet — that's destructuring props, the entire subject of Part 3.)

### Why capitalize component names?

When the JSX compiler sees `<div>`, it compiles to `React.createElement('div', ...)` — a plain string naming a real HTML tag. When it sees `<Navbar />`, capitalized, it compiles to `React.createElement(Navbar, ...)` — a reference to your actual JavaScript function. If you name a component `navbar` (lowercase) and write `<navbar />`, React will try (and fail) to treat it as an unknown HTML tag instead of your component. This is a compiler rule, not a stylistic suggestion — lowercase component names will silently break.

### File organization conventions used in this series

* One component per file, and the file name matches the component name exactly (`Navbar.jsx` exports `Navbar`). This makes searching your codebase trivial as it grows.
* We use the `.jsx` extension (rather than plain `.js`) for any file containing JSX syntax — this isn't just convention, Vite's tooling specifically expects it to know how to parse the file correctly.
* Imports of local files always include the file extension (`./HabitCard.jsx`) in this series for absolute clarity, even though some setups allow omitting it.

### Common errors & fixes when building component trees

| Symptom | Likely cause | Fix |
|---|---|---|
| `Adjacent JSX elements must be wrapped in an enclosing tag` | You returned two sibling elements with no shared parent/Fragment | Wrap them in a `<div>` or a Fragment `<>...</>` |
| `X is not defined` in console | Forgot to `import` a component before using it in JSX | Add the missing `import ComponentName from './ComponentName.jsx'` line |
| Component renders as literal text, e.g. the word "Navbar" appears on screen instead of your UI | You wrote `<navbar />` lowercase instead of `<Navbar />` | Capitalize the tag to match the function name |
| Nothing renders, no error shown | Forgot the `export default ComponentName` line at the bottom of the file | Add the export line; every component file needs one |
| `Unexpected token` pointing at a `<` in a `.js` file | JSX syntax used inside a plain `.js` file instead of `.jsx` | Rename the file extension to `.jsx` |

### A note on `React.createElement` (for the curious)

You will never need to call `React.createElement` directly in this series — but it's worth knowing it still exists under the JSX, because it explains *why* the rules above are non-negotiable. JSX is sugar (a friendlier syntax) for ordinary function calls; the JavaScript language itself has no idea what `<div>` means without the compilation step. This is also why a `.jsx`/`.tsx` file extension (or equivalent build configuration) is mandatory — the browser itself never runs JSX; it only ever runs the compiled JavaScript output.
Ready when you are — say **"next"** and I'll generate **Phase 1, Part 3: Props — Passing Data Into Components**.
