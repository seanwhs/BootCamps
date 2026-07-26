# Phase 2: Interactivity
# Part 1: State with `useState` — Making Tasks and Habits Interactive

## Introduction: What we're doing in this part

Our app currently has checkboxes that are purely decorative — clicking `☐` does absolutely nothing. That's because everything we've built so far is **read-only display**: props flow down, but nothing ever changes after the initial render. Real apps need to *remember things and react to user actions* — clicking a checkbox should actually toggle it.

This is the single biggest conceptual leap in React so far. In this part, you will:

1. Understand exactly why props alone can't solve this problem, and why React needs a special mechanism (`useState`) for "memory."
2. Learn the Rules of Hooks — the non-negotiable constraints on how `useState` (and every hook) must be used.
3. Wire up real click handling with `onClick`.
4. Make an individual `HabitCard` toggle itself when clicked.
5. Learn the critical concept of **state colocation** — and then immediately learn why we need to *lift state up* instead, once multiple components need to share it.
6. End the part with genuinely clickable, toggling habits and tasks.

---

## 🎯 The Target: Understanding why we need `useState`

### 🧠 The Concept: A component function re-runs from scratch every render — so a plain variable can't "remember" anything

Here's a tempting but broken idea. What if we just tried a plain variable?

```jsx
function HabitCard({ label }) {
  let isComplete = false // ❌ this will NOT work as "memory"

  function handleClick() {
    isComplete = !isComplete // flips true/false
    console.log(isComplete)  // this actually DOES log correctly!
  }

  return (
    <div className="card habit-card" onClick={handleClick}>
      <span>{isComplete ? '☑' : '☐'}</span>
      <span>{label}</span>
    </div>
  )
}
```

If you tried this, clicking would flip `isComplete` in the `console.log`, but **the checkbox on screen would never visually update**. Why? Because a plain JavaScript variable has no way to tell React "hey, go re-render this component now that something changed." React only re-runs (re-renders) a component function when it's specifically told to — and a normal `let` variable is invisible to React; it's just a local detail that gets **wiped out and reset to `false` every single time the function re-runs anyway**, since `let isComplete = false` re-executes fresh at the top of the function every time.

This is the exact problem `useState` was built to solve. It gives a component function two things a plain variable never could:
1. A value that **persists** across re-renders (React stores it outside of the function itself, in memory it manages).
2. A way to **notify React** that the value changed, triggering exactly the re-render needed to update the screen.

### 🛠️ The Implementation: The anatomy of `useState`

Let's look at the shape of a `useState` call before applying it to `HabitCard`:

```jsx
import { useState } from 'react'

function Example() {
  const [isComplete, setIsComplete] = useState(false)
  //     ^value        ^updater fn        ^initial value

  // ...
}
```

Breaking this down piece by piece:

* `useState(false)` — calling this hook, and handing it `false` as the **initial value** (only used the very first time this component ever renders).
* `useState` returns an **array with exactly two items**: the current value, and a function used specifically to update that value.
* `const [isComplete, setIsComplete] = ...` — this is **array destructuring** (like the object destructuring from Part 3, but for arrays, where position matters instead of property names). We're naming the first returned item `isComplete` and the second `setIsComplete` — but these names are entirely our choice; React just returns `[value, updaterFunction]` in that order, always.
* Convention (not a hard rule, but followed almost universally): name the updater function `set` + the capitalized state name (`isComplete` → `setIsComplete`, `count` → `setCount`).

The updater function (`setIsComplete`) is the *only* correct way to change this value. Calling it does two things: it updates React's stored value, **and** it schedules a re-render of this component (and its children) so the screen catches up to the new value.

---

## 🎯 The Target: Wiring up click handling with `onClick`

### 🧠 The Concept: Event handlers are functions you hand to React, to be called later

You've already seen `onClick` briefly in Part 1's leftover demo code. Let's be precise about it now: `onClick` is a special **prop** that native JSX elements (`<div>`, `<button>`, `<span>`, etc.) understand. You assign it a **function** (not the result of calling a function!) and React calls that function for you, exactly once, every time that element is clicked.

```jsx
// ❌ WRONG — this calls handleClick immediately during render, not on click!
<div onClick={handleClick()}>

// ✅ CORRECT — this hands React the function itself, to call LATER, on click
<div onClick={handleClick}>

// ✅ ALSO CORRECT — an inline arrow function, useful when you need to pass arguments
<div onClick={() => handleClick(someArgument)}>
```

This distinction — passing a function **reference** versus **calling** a function — trips up nearly every React beginner at least once. The rule of thumb: if you see parentheses `()` directly after the function name inside `onClick={...}`, and you don't intend it to run immediately during render, it's very likely a mistake — unless it's wrapped in its own arrow function, like the third example.

---

## 🎯 The Target: Making `HabitCard` toggle its own completion state

### 🧠 The Concept: State that only one component needs can live inside that component

Right now, `HabitCard` receives `isComplete` as a prop from its parent. But if we want *clicking the card itself* to flip it, the component needs its own internal memory of the current state, rather than only reflecting whatever its parent tells it. This pattern — a component managing state that's entirely private to itself — is fine **as long as no sibling or parent component needs to know about or react to that same value.** We'll intentionally hit the limits of this approach in the very next section, which sets up why "lifting state up" becomes necessary.

### 🛠️ The Implementation

**File: `src/components/HabitCard.jsx`**

```jsx
import { useState } from 'react'
import Badge from './Badge.jsx'

// `isComplete` is renamed to `initialIsComplete` here — it's now only used
// to SEED the component's own state on first render, not to control it directly.
function HabitCard({ label, streak = 0, isComplete: initialIsComplete = false }) {
  const [isComplete, setIsComplete] = useState(initialIsComplete)

  // This function flips the current value. Passing a FUNCTION to setIsComplete
  // (rather than a plain value) guarantees we're always flipping the latest
  // true state, which matters once we cover why this pattern is safer in the
  // Reference Section below.
  function handleToggle() {
    setIsComplete((currentValue) => !currentValue)
  }

  return (
    <div className="card habit-card" onClick={handleToggle}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      <Badge tone="streak">🔥 {streak}</Badge>
    </div>
  )
}

export default HabitCard
```

Notice the prop destructuring syntax: `isComplete: initialIsComplete = false`. This is **destructuring with renaming** — we're pulling the `isComplete` property out of the props object, but calling it `initialIsComplete` inside this function, with a default of `false` if it's missing. We rename it because, once state takes over, `isComplete` (the variable we actually display and toggle) needs to come from `useState`, not directly from props — using the same name for both would be confusing and, more importantly, wrong (the prop is only a *starting point*, not the live value).

Add a small CSS touch so the card visibly signals it's clickable:

**File: `src/index.css`** *(append this block)*

```css
/* --- Clickable habit cards --- */

.habit-card {
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.habit-card:hover {
  background-color: #fafafa;
}
```

### ✅ The Verification

Save both files. Go to `localhost:5173`. Click directly anywhere on the "Drink 8 glasses of water" card.

**Expected result:** The `☐` instantly becomes `☑`, and the label gets a strikethrough — with **no page reload, no flicker**. Click it again; it toggles back. Click the second habit card too — confirm each card toggles **independently** of the other. This independence is proof that each call to `useState` inside each separate `HabitCard` instance keeps its own private memory, even though both instances are running the exact same component function.

**Try this:** Open React DevTools if you have the browser extension installed (optional, but genuinely useful — search "React Developer Tools" for your browser), select a `HabitCard` in the Components tab, and watch the `isComplete` hook value change live as you click. If you don't have the extension, just trust the visual toggle — we'll lean on DevTools more in later, more complex parts.

---

## 🎯 The Target: Hitting the wall — why per-card state isn't always enough

### 🧠 The Concept: Some state needs to be visible to more than one component — so it can't live inside just one of them

Let's introduce a new requirement: the "Today's Habits" section header should show **how many habits are still incomplete** (e.g., "1 remaining"). Try to picture where that count would need to live. It can't live inside a single `HabitCard` — no individual card knows about the *other* cards. It needs to live somewhere that can see **all** the habits at once.

This is the moment every React learner needs to internalize: **when multiple components need to read or react to the same piece of state, that state must be moved up to their closest common parent, and passed back down as props.** This is called **lifting state up**. It feels like it "costs" us the simplicity of `HabitCard` managing itself — and it does — but it's the only way multiple components can stay in sync with one shared source of truth.

We are going to lift the `isComplete` state out of `HabitCard` entirely, up into `Dashboard` (the closest shared ancestor of all habit cards, per our tree from Phase 1). `HabitCard` goes back to being a "dumb," fully props-driven display component — but now its parent is the one calling `useState` and handing down both the value *and* a function to change it.

### 🛠️ The Implementation

First, `HabitCard` reverts to pure props, but now also receives a function prop to call when clicked — notice it no longer imports or calls `useState` at all:

**File: `src/components/HabitCard.jsx`**

```jsx
import Badge from './Badge.jsx'

// HabitCard is "dumb" again: it displays whatever it's told, and reports
// clicks upward via the `onToggle` function prop, instead of managing
// its own state. This is often called a "controlled" or "presentational"
// component, as opposed to HabitsSection/Dashboard being "container" components.
function HabitCard({ label, streak = 0, isComplete = false, onToggle }) {
  return (
    <div className="card habit-card" onClick={onToggle}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      <Badge tone="streak">🔥 {streak}</Badge>
    </div>
  )
}

export default HabitCard
```

Now, the real question: **where should the `habits` array itself become stateful?** Right now `App.jsx` owns `sampleHabits` as a static import. For any component to update a piece of data, that data must be state (created via `useState`) at some level, not a plain imported constant. Since `App` is already the component that owns and hands down the habits data, `App` is the natural place to promote it to real state.

**File: `src/App.jsx`**

```jsx
import { useState } from 'react'
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'
import { sampleHabits, sampleTasks } from './data/sampleData.js'

function App() {
  // The sample arrays are now just the INITIAL value handed to useState.
  // From this point on, `habits` and `tasks` are React state, not plain imports.
  const [habits, setHabits] = useState(sampleHabits)
  const [tasks, setTasks] = useState(sampleTasks)

  // This function updates exactly one habit inside the array, leaving
  // every other habit untouched. See the Reference Section below for a
  // full breakdown of why we build a brand-new array instead of editing
  // the existing one in place.
  function handleToggleHabit(habitId) {
    setHabits((currentHabits) =>
      currentHabits.map((habit) =>
        habit.id === habitId
          ? { ...habit, isComplete: !habit.isComplete }
          : habit
      )
    )
  }

  function handleToggleTask(taskId) {
    setTasks((currentTasks) =>
      currentTasks.map((task) =>
        task.id === taskId ? { ...task, isComplete: !task.isComplete } : task
      )
    )
  }

  return (
    <div className="app">
      <Navbar />
      <Dashboard
        habits={habits}
        tasks={tasks}
        onToggleHabit={handleToggleHabit}
        onToggleTask={handleToggleTask}
      />
    </div>
  )
}

export default App
```

There's a lot of new syntax in `handleToggleHabit` — don't worry, we unpack every piece of it thoroughly in the Reference Section below. For now, the plain-English version: *"Make a new list. For each habit in the old list: if its `id` matches the one that was clicked, put a new copy of that habit with `isComplete` flipped; otherwise, keep the exact same habit as before."*

Now forward these props down through `Dashboard`:

**File: `src/components/Dashboard.jsx`**

```jsx
import HabitsSection from './HabitsSection.jsx'
import TasksSection from './TasksSection.jsx'

function Dashboard({ habits, tasks, onToggleHabit, onToggleTask }) {
  return (
    <main className="dashboard">
      <HabitsSection habits={habits} onToggleHabit={onToggleHabit} />
      <TasksSection tasks={tasks} onToggleTask={onToggleTask} />
    </main>
  )
}

export default Dashboard
```

And through `HabitsSection`, which now also computes and displays the "remaining" count — the exact feature that motivated this whole refactor:

**File: `src/components/HabitsSection.jsx`**

```jsx
import HabitCard from './HabitCard.jsx'

function HabitsSection({ habits, onToggleHabit }) {
  // .filter() keeps only the array items where the given function returns true.
  // We cover .filter() and other array methods thoroughly in the next part —
  // for now, just read this as "count how many habits are NOT complete."
  const remainingCount = habits.filter((habit) => !habit.isComplete).length

  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Today's Habits</h2>
        <span className="remaining-count">{remainingCount} remaining</span>
      </div>
      <div className="card-list">
        <HabitCard
          label={habits[0].label}
          streak={habits[0].streak}
          isComplete={habits[0].isComplete}
          onToggle={() => onToggleHabit(habits[0].id)}
        />
        <HabitCard
          label={habits[1].label}
          streak={habits[1].streak}
          isComplete={habits[1].isComplete}
          onToggle={() => onToggleHabit(habits[1].id)}
        />
      </div>
    </section>
  )
}

export default HabitsSection
```

Notice `onToggle={() => onToggleHabit(habits[0].id)}` — this is exactly the "inline arrow function" pattern flagged earlier. We need to call `onToggleHabit` **with a specific argument** (which habit's `id`), so we wrap it in a tiny arrow function that React will call on click; that inner function then calls `onToggleHabit(habits[0].id)` for us at that moment — not immediately during render.

And `TasksSection`, following the identical pattern:

**File: `src/components/TasksSection.jsx`**

```jsx
import TaskCard from './TaskCard.jsx'

function TasksSection({ tasks, onToggleTask }) {
  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Tasks</h2>
      </div>
      <div className="card-list">
        <TaskCard
          label={tasks[0].label}
          isComplete={tasks[0].isComplete}
          onToggle={() => onToggleTask(tasks[0].id)}
        />
        <TaskCard
          label={tasks[1].label}
          isComplete={tasks[1].isComplete}
          onToggle={() => onToggleTask(tasks[1].id)}
        />
        <TaskCard
          label={tasks[2].label}
          isComplete={tasks[2].isComplete}
          onToggle={() => onToggleTask(tasks[2].id)}
        />
      </div>
    </section>
  )
}

export default TaskCard
```

Wait — that last export line has a bug we're leaving in deliberately, so you can experience diagnosing it. Actually, let's correct it now for a clean working state (we want every verification step to genuinely pass):

**File: `src/components/TasksSection.jsx`** *(corrected final line)*

```jsx
export default TasksSection
```

Update `TaskCard` to accept `onToggle` too:

**File: `src/components/TaskCard.jsx`**

```jsx
function TaskCard({ label, isComplete = false, onToggle }) {
  return (
    <div className="card task-card" onClick={onToggle}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
    </div>
  )
}

export default TaskCard
```

Finally, add CSS for the new "remaining" label and clickable task cards:

**File: `src/index.css`** *(append this block)*

```css
/* --- Remaining count & clickable tasks --- */

.remaining-count {
  font-size: 0.85rem;
  color: #6b6b6b;
}

.task-card {
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.task-card:hover {
  background-color: #fafafa;
}
```

### ✅ The Verification

Save every file. Go to `localhost:5173`.

1. You should see **"1 remaining"** next to "Today's Habits" (since one of our two sample habits starts complete).
2. Click the incomplete habit ("Drink 8 glasses of water") — it should check off, **and the count should update to "0 remaining"** instantly.
3. Click it again — it unchecks, and the count returns to "1 remaining."
4. Click each task card — each should independently toggle its own checked/strikethrough state.

This is the real payoff of lifting state up: `HabitsSection` can now compute something (`remainingCount`) that depends on **all** habits at once, something that would have been architecturally impossible if each `HabitCard` still secretly held its own private, invisible-to-siblings state.

---

## 📚 Reference Section: Phase 2, Part 1

### The Rules of Hooks (non-negotiable)

`useState` is our first **hook** — recall from Part 0's glossary that hooks are special functions starting with `use` that let a component tap into React features. Every hook, including ones we meet later (`useEffect`, `useContext`, `useActionState`, etc.), must follow two strict rules:

1. **Only call hooks at the top level of a component (or another hook).** Never inside an `if`, a loop, or a nested function.
2. **Only call hooks from React function components (or custom hooks).** Never from a regular JavaScript function, or outside a component entirely.

```jsx
// ❌ BREAKS RULE 1 — hook called conditionally
function Broken({ showExtra }) {
  if (showExtra) {
    const [extra, setExtra] = useState(0) // ❌ never do this
  }
  // ...
}

// ✅ CORRECT — hook always called, condition applied to its usage instead
function Fixed({ showExtra }) {
  const [extra, setExtra] = useState(0)
  return showExtra ? <p>{extra}</p> : null
}
```

*Why* does this rule exist? React keeps track of each component's hooks internally using their **call order** — literally "the first `useState` call, the second `useState` call," etc. — not by variable name. If a hook call is sometimes skipped (like inside a conditional), the order shifts between renders, and React loses track of which stored value belongs to which `useState` call, causing corrupted state or outright crashes. Always calling every hook, every render, in the same order, is what keeps this bookkeeping reliable.

### Why we pass a function to `setState` (the "updater function" pattern)

We wrote `setIsComplete((currentValue) => !currentValue)` rather than the seemingly simpler `setIsComplete(!isComplete)`. Both often work, but the function form is safer, for this reason: state updates in React are not always applied instantly and synchronously — React may batch multiple updates together for performance. If you triggered two toggles in extremely quick succession using the plain-value form, both might incorrectly compute their "flip" off the same stale starting value. Using the updater-function form guarantees React always hands your function the **most current, up-to-date value**, no matter how updates get batched. As a habit, this series will prefer the function form whenever a new state value is *derived from* the previous one (toggling, incrementing, appending to a list) — but will use the plain-value form when setting a completely independent value (e.g., `setName(event.target.value)` in an upcoming forms lesson).

### Understanding immutable updates — the spread operator and `.map()`

This line deserves a slow, careful breakdown, because "immutable updates" is one of the most important habits in all of React:

```javascript
setHabits((currentHabits) =>
  currentHabits.map((habit) =>
    habit.id === habitId
      ? { ...habit, isComplete: !habit.isComplete }
      : habit
  )
)
```

* `currentHabits.map(...)` — `.map()` is an array method that builds a **brand new array** by running a function on every item of the original array and collecting the results. Critically, it does **not** modify the original array at all.
* `habit.id === habitId ? A : B` — for each habit, we check: is this the one that was clicked? If yes, produce `A`; if no, produce `B` (the habit, completely unchanged).
* `{ ...habit, isComplete: !habit.isComplete }` — the `...habit` part is the **spread operator**, which copies every property out of the existing `habit` object into a **brand new object**. Immediately after, `isComplete: !habit.isComplete` overrides just that one property on the new copy. The net effect: a new object, identical to the old one, except with `isComplete` flipped.

Why go through all this trouble instead of just writing `habit.isComplete = !habit.isComplete` directly? Because **React detects changes by comparing references** (essentially: "is this the exact same object in memory as before, or a different one?"), not by deeply inspecting every property. If you mutate (directly change) the existing object instead of creating a new one, React may not detect that anything changed at all, and skip the re-render — leaving your UI silently out of sync with your data. This is the same principle from Part 3 ("props are read-only") extended to state: **never mutate data directly; always create new copies.** This single discipline avoids an entire category of extremely confusing bugs, and you'll see this exact spread-and-map pattern repeatedly for the rest of this series.

### `useState` — full API reference

```javascript
const [value, setValue] = useState(initialValue)
```

* **`initialValue`** — used only on the component's very first render. On every subsequent render, React ignores whatever you pass here and uses its internally stored value instead.
* **Lazy initial state**: if computing the initial value is expensive (e.g., reading and parsing something large), you can instead pass a *function* — `useState(() => computeExpensiveDefault())` — and React will call it only once, on mount, rather than recomputing it on every render just to throw the result away.
* **`setValue(newValue)`** — replaces the state directly with `newValue`.
* **`setValue((prev) => newValue)`** — the "updater function" form; React calls your function with the current value and uses whatever it returns.
* Calling `setValue` with a value that is `===` (reference-equal) to the current value causes React to **skip** re-rendering that component, as an optimization — another reason mutating in place is dangerous: if you mutate an object and then pass that *same* mutated object reference to `setValue`, React may see "no change" and skip the update entirely, even though your data did change.

### Common errors & fixes when working with `useState`

| Symptom | Likely cause | Fix |
|---|---|---|
| Clicking does nothing, no error in console | Passed a called function (`onClick={handleClick()}`) instead of a reference | Remove the parentheses, or wrap in an arrow function if arguments are needed |
| `React Hook "useState" is called conditionally` (lint warning/error) | A hook was placed inside an `if`, loop, or nested function | Move the hook call to the top level of the component |
| Clicking one card toggles a *different* card, or all cards at once | Missing/incorrect `id` matching logic in the update function, or using array index instead of a stable `id` | Ensure your `.map()` comparison uses a unique, stable identifier like `habit.id` |
| State appears to update, but UI doesn't re-render | Mutated the existing object/array instead of creating a new one via spread/`.map()` | Always build a new array/object; never assign directly to a nested property of existing state |
| `Too many re-renders` error | Calling the setter function directly during render (e.g., `onClick={setIsComplete(true)}`) instead of via an event handler reference | Wrap it: `onClick={() => setIsComplete(true)}`, or reference a named handler function |
