# Phase 1: Foundations
# Part 3: Props — Passing Data Into Components

## Introduction: What we're doing in this part

Look closely at `HabitsSection.jsx` from last part:

```jsx
<HabitCard />
<HabitCard />
```

Both of these render **the exact same text** — "Drink 8 glasses of water," streak "🔥 5" — because `HabitCard` has that content hardcoded inside it. That's obviously wrong for a real app: two different habits need to show two different labels. We need a way to say "use the `HabitCard` cookie cutter, but stamp *this* specific data into it this time."

That mechanism is called **props** (short for "properties"), and it's the subject of this entire part. By the end, you will:

1. Understand props as simply "function arguments, but for components."
2. Rewrite `HabitCard` and `TaskCard` to receive their content from outside, instead of hardcoding it.
3. Learn the critical rule that **props are read-only**.
4. Learn default prop values, for when a prop isn't provided.
5. Learn the **`children` prop** — a special prop that lets components wrap other content, and use it to build a reusable `Badge` component.
6. Experience **prop drilling** firsthand — passing data down through several layers of components — and understand why this becomes a real problem worth solving later.

---

## 🎯 The Target: Understanding props as "component arguments"

### 🧠 The Concept: A component is a function; props are its arguments

Remember from Part 2: a component is just a JavaScript function. Ordinary functions take arguments so they can behave differently each time you call them:

```javascript
function greet(name) {
  return "Hello, " + name + "!"
}

greet("Alex")  // "Hello, Alex!"
greet("Sam")   // "Hello, Sam!"
```

One `greet` function, reused with different input, producing different output. **Props work exactly the same way for components.** Instead of calling a component like a normal function (`HabitCard(...)`), you "call" it through JSX syntax, and any attributes you write on the tag become that one single argument object:

```jsx
<HabitCard label="Drink water" streak={5} />
```

is equivalent, once compiled, to something like:

```javascript
HabitCard({ label: "Drink water", streak: 5 })
```

Notice: no matter how many attributes you write on the JSX tag, React always bundles them into **one single object** and passes that one object as the component function's one argument. This is why, inside the component, you'll always see props received as a single parameter — usually immediately unpacked with **destructuring** (a JavaScript feature for pulling specific properties out of an object into their own named variables), which we'll do below.

---

## 🎯 The Target: Creating a shared data source for our sample content

### 🧠 The Concept: Separate your data from your display logic

Right now, our habit and task text is buried inside component files. Before we can pass data *as props*, we need somewhere for that data to actually live. In a real app, this data would eventually come from a server (Phase 4 territory) — but for now, we'll centralize it in one plain JavaScript file, so it's obvious that "data" and "how data is displayed" are two separate concerns.

### 🛠️ The Implementation

Create a new folder and file for sample data:

```bash
mkdir src/data
```

**File: `src/data/sampleData.js`**

```javascript
// This file simulates data that will eventually come from a real backend
// (Phase 4 of this series). For now, it's just plain JavaScript objects,
// each with a unique `id` — a convention we'll rely on heavily once we
// start rendering lists with .map() in Phase 2.

export const sampleHabits = [
  { id: 1, label: 'Drink 8 glasses of water', streak: 5, isComplete: false },
  { id: 2, label: 'Read for 10 minutes', streak: 12, isComplete: true },
]

export const sampleTasks = [
  { id: 1, label: 'Finish React tutorial', isComplete: false },
  { id: 2, label: 'Buy groceries', isComplete: true },
  { id: 3, label: 'Clean the kitchen', isComplete: false },
]
```

Each object is a little "record" describing one habit or task. Notice `sampleHabits` and `sampleTasks` are both **named exports** (using `export const`, no `default`) — this file exports multiple distinct things, so whoever imports from it must ask for each by exact name, using curly braces, just like we did with `{ StrictMode }` back in Part 1.

### ✅ The Verification

This file has no visual output on its own — it's just data. We'll verify it's wired correctly once we consume it in the next step. For now, just confirm there are no red squiggly errors in your editor and the file saved without issue.

---

## 🎯 The Target: Rewriting `HabitCard` and `TaskCard` to accept props

### 🧠 The Concept: Props are received via destructuring, and they are read-only

We're going to change `HabitCard`'s function signature from taking no arguments to taking one props object, and immediately destructuring the specific fields we care about:

```jsx
// Before: no input, hardcoded output
function HabitCard() { ... }

// After: receives a props object, destructured into named variables
function HabitCard({ label, streak, isComplete }) { ... }
```

That `{ label, streak, isComplete }` in the function parameters is **object destructuring** — instead of writing `function HabitCard(props) { const label = props.label; const streak = props.streak; ... }`, we do it all in one step, right in the parameter list. It's shorthand, nothing more — but it's the shorthand you'll see in essentially every React codebase, including the rest of this series.

There's one crucial rule to internalize right now, because violating it is the single most common beginner mistake: **props are read-only. A component must never modify the props object it receives.** Think of props like a sealed parcel handed to you by a delivery courier (the parent component) — you're welcome to look inside and use what's there, but you don't get to reach into the courier's van and rearrange their other packages, and you don't repack this box and claim it's still the "original." If a component needs to change over time, that requires **state** — which is precisely the subject of Phase 2. For now, our components are still "read-only display," and that's fine.

### 🛠️ The Implementation

**File: `src/components/HabitCard.jsx`**

```jsx
// HabitCard now receives its content as props instead of hardcoding it.
// The `= false` after `isComplete` is a DEFAULT VALUE — plain JavaScript
// default parameter syntax. If the caller doesn't pass `isComplete` at all,
// it will quietly default to `false` instead of being `undefined`.
function HabitCard({ label, streak = 0, isComplete = false }) {
  return (
    <div className="card habit-card">
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      <span className="card-streak">🔥 {streak}</span>
    </div>
  )
}

export default HabitCard
```

Notice the checkbox glyph: `{isComplete ? '☑' : '☐'}` is a **ternary expression** — a compact `if/else` that produces a value. Read it as: "if `isComplete` is true, use `'☑'`; otherwise, use `'☐'`." This is valid directly inside `{ }` because, as we covered in Part 2, ternaries are expressions (they produce a value), unlike a full `if` statement.

Similarly, `className={\`card-label ${isComplete ? 'card-label-done' : ''}\`}` uses a **template literal** (backticks, with `${...}` for embedding values) to conditionally add an extra CSS class only when the habit is complete. This lets us style completed habits differently (we'll add the actual strikethrough CSS below).

**File: `src/components/TaskCard.jsx`**

```jsx
function TaskCard({ label, isComplete = false }) {
  return (
    <div className="card task-card">
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
    </div>
  )
}

export default TaskCard
```

Add the corresponding CSS for the "done" state. Append this to the bottom of your existing stylesheet:

**File: `src/index.css`** *(append this block to the end of the file)*

```css
/* --- Completed state --- */

.card-label-done {
  text-decoration: line-through;
  color: #9a9a9a;
}
```

### ✅ The Verification

We haven't updated the components that *use* `HabitCard`/`TaskCard` yet, so if you check the browser right now, the cards will render with **blank labels** — because `HabitsSection` and `TasksSection` are still writing `<HabitCard />` with no props at all, so `label` is `undefined`. That's expected and actually a useful thing to see once:

Open `localhost:5173` now and confirm the cards show empty labels and (for habits) "🔥 0" — proof that our default value (`streak = 0`) kicked in correctly, while `label` (which has no default) shows nothing since we didn't supply one. This confirms our destructuring and defaults are wired correctly, ahead of the next step where we actually supply real data.

---

## 🎯 The Target: Passing data down through the component tree (prop drilling)

### 🧠 The Concept: Data flows down, one layer at a time — like passing a note through a line of people

React data flow is famously described as **"one-way" / "top-down."** A parent component can pass data to its children via props, but a child can never reach back up and hand data to its parent directly. Our tree from Part 2 looks like this:

```
App  →  Dashboard  →  HabitsSection  →  HabitCard
                  →  TasksSection   →  TaskCard
```

If `App` is the one that "owns" the sample data (which makes sense — it's the root, and eventually it'll be the one fetching real data from a server), then that data has to be explicitly handed from `App` to `Dashboard`, then from `Dashboard` down to `HabitsSection`/`TasksSection`, then finally from those down to each individual `HabitCard`/`TaskCard`. Every intermediate component has to accept the data as a prop and explicitly forward it, even if it doesn't use the data itself — like passing a note hand-to-hand down a line of people, where everyone in the middle has to actually touch and pass along the note, even if the note isn't for them.

This pattern is called **prop drilling**, and you're about to feel exactly why it can get tedious. We're doing it deliberately, by hand, right now — so that when we introduce the Context API in Phase 5 as a *fix* for exactly this pain, you'll deeply understand the problem it solves, instead of taking it on faith.

### 🛠️ The Implementation

Update `App.jsx` to own the data and pass it down:

**File: `src/App.jsx`**

```jsx
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'
import { sampleHabits, sampleTasks } from './data/sampleData.js'

function App() {
  return (
    <div className="app">
      <Navbar />
      {/* App owns the data and hands it down to Dashboard as props. */}
      <Dashboard habits={sampleHabits} tasks={sampleTasks} />
    </div>
  )
}

export default App
```

Update `Dashboard.jsx` to receive that data and forward it further down:

**File: `src/components/Dashboard.jsx`**

```jsx
import HabitsSection from './HabitsSection.jsx'
import TasksSection from './TasksSection.jsx'

// Dashboard doesn't actually USE `habits` or `tasks` itself —
// it just receives them and forwards them further down the tree.
// This forwarding-without-using is the essence of "prop drilling."
function Dashboard({ habits, tasks }) {
  return (
    <main className="dashboard">
      <HabitsSection habits={habits} />
      <TasksSection tasks={tasks} />
    </main>
  )
}

export default Dashboard
```

Update `HabitsSection.jsx` to receive the `habits` array and pass each individual habit's fields down to a `HabitCard`. Note: we still don't have `.map()` yet (that's next phase), so we're manually indexing into the array with `habits[0]`, `habits[1]` — intentionally tedious, to set up the motivation for looping:

**File: `src/components/HabitsSection.jsx`**

```jsx
import HabitCard from './HabitCard.jsx'

function HabitsSection({ habits }) {
  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Today's Habits</h2>
      </div>
      <div className="card-list">
        {/*
          Manually indexing into the array like this works, but it's
          fragile (what if there are 20 habits? Or 0?) and repetitive.
          In Phase 2, Part 2, we'll replace this entirely with habits.map(...).
        */}
        <HabitCard
          label={habits[0].label}
          streak={habits[0].streak}
          isComplete={habits[0].isComplete}
        />
        <HabitCard
          label={habits[1].label}
          streak={habits[1].streak}
          isComplete={habits[1].isComplete}
        />
      </div>
    </section>
  )
}

export default HabitsSection
```

**File: `src/components/TasksSection.jsx`**

```jsx
import TaskCard from './TaskCard.jsx'

function TasksSection({ tasks }) {
  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Tasks</h2>
      </div>
      <div className="card-list">
        <TaskCard label={tasks[0].label} isComplete={tasks[0].isComplete} />
        <TaskCard label={tasks[1].label} isComplete={tasks[1].isComplete} />
        <TaskCard label={tasks[2].label} isComplete={tasks[2].isComplete} />
      </div>
    </section>
  )
}

export default TasksSection
```

### ✅ The Verification

Save every file. `localhost:5173` should now show real, distinct data flowing all the way from `App.jsx` down through four layers of components:

```
Today's Habits
☐ Drink 8 glasses of water          🔥 5
☑ Read for 10 minutes  (strikethrough)   🔥 12

Tasks
☐ Finish React tutorial
☑ Buy groceries  (strikethrough)
☐ Clean the kitchen
```

Confirm the second habit and second task show **strikethrough text**, proving `isComplete` correctly reached all the way down to `HabitCard`/`TaskCard` and drove the ternary/className logic we wrote.

**Try this experiment** to feel the full power of props: open `src/data/sampleData.js`, change `streak: 12` to `streak: 100`, and change `'Buy groceries'` to `'Buy groceries and cook dinner'`. Save. Watch the browser update instantly — **without touching a single component file.** This is the entire point of separating data from display: the same components now render whatever data you hand them.

---

## 🎯 The Target: The `children` prop — building a reusable `Badge` component

### 🧠 The Concept: `children` is what goes *between* your tags

Every prop so far has been passed as an explicit attribute (`label="..."`, `streak={5}`). But there's one special, automatically-provided prop: **`children`**. It captures whatever JSX you put *between* a component's opening and closing tags:

```jsx
<Badge>🔥 5</Badge>
```

Inside `Badge`, the text `🔥 5` is automatically available as `props.children`. This is exactly how native HTML elements work too — `<button>Click me</button>` has "Click me" as its content — and React lets your own custom components work the same way. It's the mechanism that lets you build generic "wrapper" or "container" components that don't need to know in advance exactly what will be inside them.

Let's extract our streak indicator into a reusable `Badge` component, since "a small pill-shaped label with a colored background" is a pattern we'll likely reuse later (e.g., for task priority, or status labels).

### 🛠️ The Implementation

**File: `src/components/Badge.jsx`**

```jsx
// Badge is a generic, reusable "pill" component. It doesn't know or care
// WHAT content it wraps — that's the power of the `children` prop.
// The `tone` prop lets callers pick a color scheme without duplicating CSS.
function Badge({ children, tone = 'neutral' }) {
  return <span className={`badge badge-${tone}`}>{children}</span>
}

export default Badge
```

Notice `tone` gets interpolated directly into the class name (`badge-${tone}`), so passing `tone="warning"` produces `className="badge badge-warning"`. This is a common, lightweight pattern for letting a prop control which CSS rules apply, without writing a big if/else chain.

Now update `HabitCard` to use `Badge` instead of a plain `<span>`:

**File: `src/components/HabitCard.jsx`**

```jsx
import Badge from './Badge.jsx'

function HabitCard({ label, streak = 0, isComplete = false }) {
  return (
    <div className="card habit-card">
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      {/* Everything between <Badge> and </Badge> becomes Badge's `children` prop */}
      <Badge tone="streak">🔥 {streak}</Badge>
    </div>
  )
}

export default HabitCard
```

Add the CSS for our new `Badge` component. Append to the bottom of your stylesheet:

**File: `src/index.css`** *(append this block)*

```css
/* --- Badge --- */

.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.2rem 0.55rem;
  border-radius: 999px; /* fully rounded "pill" shape */
  font-size: 0.85rem;
  font-weight: 600;
  white-space: nowrap; /* keeps "🔥 5" from wrapping onto two lines */
}

.badge-neutral {
  background-color: #eeeeee;
  color: #444444;
}

.badge-streak {
  background-color: #fff1e0;
  color: #a45c00;
}
```

Since `card-streak` is no longer used (we replaced that `<span>` with `<Badge>`), you can safely remove the old `.card-streak` rule from your stylesheet — search for it and delete that block to keep things tidy.

### ✅ The Verification

Save everything. `localhost:5173` should look **visually identical** to before for the streak indicator, except now it's rendered as a soft-orange rounded pill rather than plain text — confirming `Badge` correctly received and displayed its `children`.

**Try this:** In `HabitCard.jsx`, temporarily change `<Badge tone="streak">🔥 {streak}</Badge>` to `<Badge>🔥 {streak}</Badge>` (removing the `tone` prop entirely). Save, and confirm the badge switches to the plain gray "neutral" style — this proves the `tone = 'neutral'` default parameter we wrote is working exactly like `isComplete = false` did earlier. Afterward, put `tone="streak"` back.

---

## 📚 Reference Section: Phase 1, Part 3

### The full mental model of props, in one diagram

```
 Parent Component                    Child Component
┌──────────────────────┐            ┌───────────────────────┐
│ <HabitCard            │  props →   │ function HabitCard(   │
│   label="Drink water" │───────────▶│   { label, streak }   │
│   streak={5}          │            │ ) {                    │
│ />                     │            │   // read-only use     │
└──────────────────────┘            └───────────────────────┘
```

The parent decides *what* to pass; the child decides *how* to display it. Neither one should reach into the other's job — the child never invents its own data, and the parent never dictates the child's internal markup.

### Destructuring & default parameters — a focused JavaScript primer

Since this part leaned heavily on these two JavaScript features, here they are in isolation, outside of any React context:

```javascript
// --- Object destructuring ---
const user = { name: "Alex", age: 30 }

// Without destructuring:
const name1 = user.name
const age1 = user.age

// With destructuring (identical result, less repetition):
const { name, age } = user

// --- Default values during destructuring ---
const settings = { theme: "dark" }
const { theme, fontSize = 16 } = settings
// theme === "dark" (present in the object)
// fontSize === 16   (absent from the object, so the default kicks in)
```

Function parameter destructuring (what we used for props) is the exact same mechanism, just applied to the incoming argument object directly in the parameter list:

```javascript
function printUser({ name, age = 18 }) {
  console.log(name, age)
}

printUser({ name: "Sam" }) // "Sam 18" — age defaulted
```

### Should I validate my props? (PropTypes and TypeScript, briefly)

Right now, if you forget to pass `label` to `HabitCard`, nothing crashes — you just silently get a blank label, which can be confusing to debug in a larger app. Two common solutions exist in the wider React ecosystem, neither of which we adopt in this series (to keep things beginner-focused), but worth knowing about:

* **`prop-types`** — an official, separate npm package that lets you declare the expected type/shape of each prop and logs a console warning during development if they don't match.
* **TypeScript** — a superset of JavaScript that adds static typing to your entire codebase, including props, catching mismatches before you even run the app. Many production React codebases use TypeScript today; we deliberately stick to plain JavaScript in this series so you can focus on React concepts first, but everything you're learning transfers directly if you adopt TypeScript later.

### Why prop drilling is a real, recognized problem (and what fixes it)

The tedious, manual `habits[0]`, `habits[1]` forwarding you did in this part is a **small-scale, deliberately visible version** of a problem that gets much worse as apps grow: imagine 10 layers of nested components, where only the very bottom one actually needs a piece of data, but all 9 layers above it must accept and forward that prop anyway. Two techniques fix this, both covered later in this series:

* **Component composition** (passing components as `children` or other props, rearranging your tree so data doesn't need to travel through as many layers) — a technique you already got a small taste of with `Badge`.
* **The Context API** (Phase 5 of this series) — lets a deeply nested component reach up and grab shared data directly, without every intermediate component needing to know about it.

### Common errors & fixes when working with props

| Symptom | Likely cause | Fix |
|---|---|---|
| Prop shows as blank / `undefined` on screen | Typo in the prop name between parent and child (e.g., `lable` vs `label`) | Double-check spelling matches exactly on both sides |
| `Cannot read properties of undefined (reading 'label')` | Trying to access `habits[5]` when the array only has 2 items | Check your array indices match the actual data length |
| Changing a prop inside a component has no visible effect, or causes a warning | Attempting to mutate a prop directly (e.g., `label = "new"` inside the component) | Never reassign props; if the UI needs to change over time, that requires state (Phase 2) |
| `children` is `undefined` inside a custom component | Component was self-closed (`<Badge />`) instead of given content between tags (`<Badge>...</Badge>`) | Add content between the opening and closing tags |
| Whole app crashes with a red error overlay after editing props | A required value like `.label` was accessed on `undefined` (e.g., array index out of range) | Read the error's file/line reference; verify the data array actually has an item at that index |

That completes **Phase 1: Foundations**. Say **"next"** and I'll generate **Phase 2, Part 1: State with `useState` — Making Tasks and Habits Interactive**.
