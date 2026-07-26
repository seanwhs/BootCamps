# Phase 2: Interactivity
# Part 3: Event Handling & Conditional Rendering

## Introduction: What we're doing in this part

So far, our event handling has been simple: click a card, toggle a boolean. But real interfaces need more nuance — sometimes a click on one part of a card shouldn't trigger the action bound to the whole card, and sometimes we need to show *entirely different UI* depending on the current state of things (an empty list, a fully-completed habit list, a filtered view with no matches).

In this part, you will:

1. Learn what the **event object** actually is, and use it to stop a click from "bubbling" where we don't want it to.
2. Learn the three core conditional rendering patterns in JSX — ternary, `&&`, and early return — and when to reach for each.
3. Build a set of **Filter Tabs** ("All / Active / Completed") for the Tasks section, backed by local component state.
4. Add proper **empty-state messaging** so the UI never looks broken when a filter matches nothing.
5. Add a small "all done!" celebration state and an "on fire" streak indicator, as focused, practical conditional-rendering exercises.

---

## 🎯 The Target: Understanding the event object and event bubbling

### 🧠 The Concept: Events ripple outward, like a dropped pebble in a pond

Every event handler function React calls (`onClick`, `onChange`, etc.) automatically receives one argument: the **event object**, conventionally named `event` or abbreviated `e`. It carries details about what happened — which element triggered it, what key was pressed, what the new input value is, and so on.

There's a second, subtler behavior worth understanding: **event bubbling.** When you click an element nested inside other elements, the click event doesn't just fire on the exact element you clicked — it "bubbles" outward, firing on every ancestor element too, all the way up to the document root, like ripples spreading outward from a pebble dropped in a pond. This is why our `HabitCard`'s outer `<div onClick={onToggle}>` fires when you click *anywhere* inside it, including on its child `<span>` elements — the click event bubbles up from whatever you directly clicked, through every ancestor, until something handles it.

This becomes a real problem the moment you want a *specific piece* inside a clickable card to do something *different* from the card's main action. We're about to hit exactly that case: clicking the streak badge should show streak info, **not** toggle the habit's completion — but without intervention, clicking the badge would bubble up and trigger the card's `onClick` too.

### 🛠️ The Implementation: Stopping propagation on the streak badge

First, let's make `Badge` accept an optional `onClick`, so it can remain a generic, reusable component (it shouldn't need to know *why* someone wants to handle its clicks):

**File: `src/components/Badge.jsx`**

```jsx
// Badge remains generic and reusable — it simply forwards an optional
// onClick prop to its underlying <span>, without knowing or caring what
// that click handler actually does.
function Badge({ children, tone = 'neutral', onClick }) {
  return (
    <span className={`badge badge-${tone}`} onClick={onClick}>
      {children}
    </span>
  )
}

export default Badge
```

Now update `HabitCard` to pass a click handler into `Badge` that stops the event from bubbling up to the card's own `onClick`:

**File: `src/components/HabitCard.jsx`**

```jsx
import Badge from './Badge.jsx'

function HabitCard({ label, streak = 0, isComplete = false, onToggle }) {
  // This handler runs when the streak Badge is clicked. `event.stopPropagation()`
  // tells the browser: "do not let this click event bubble up to any parent
  // element's handlers" — specifically, this prevents the card's own onToggle
  // from also firing just because the badge happens to sit inside the card.
  function handleStreakClick(event) {
    event.stopPropagation()
    window.alert(`🔥 ${streak}-day streak! Keep it up.`)
  }

  return (
    <div className="card habit-card" onClick={onToggle}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      {/* Without stopPropagation, clicking this badge would ALSO toggle the habit,
          because the click event would bubble up to the surrounding <div onClick={onToggle}>. */}
      <Badge tone="streak" onClick={handleStreakClick}>
        🔥 {streak}
      </Badge>
    </div>
  )
}

export default HabitCard
```

Add a small style so the badge visually signals it has its own distinct interaction:

**File: `src/index.css`** *(append this block)*

```css
/* --- Streak badge is independently clickable --- */

.badge-streak {
  cursor: pointer;
}
```

### ✅ The Verification

Save all three files. Go to `localhost:5173`.

1. Click directly on the **🔥 streak badge** of "Drink 8 glasses of water." You should see a browser alert popup: `🔥 5-day streak! Keep it up.` — and, critically, **the checkbox should NOT toggle** when you dismiss the alert.
2. Click anywhere else on that same card (the label, the checkbox glyph, the empty space) — this should toggle completion as normal, exactly like before.

This confirms `stopPropagation()` correctly isolated the badge's click from the card's click, even though the badge lives physically inside the card in the DOM.

**Try this:** Temporarily delete the `event.stopPropagation()` line, save, and click the badge again. Notice the alert now pops up **and** the card toggles once you dismiss it — proving the bubbling behavior was real, and that our fix was doing genuine work. Put the line back afterward.

---

## 🎯 The Target: The three conditional rendering patterns

### 🧠 The Concept: Three tools for "show this, or show that, or show nothing"

You've already used a **ternary** (`isComplete ? '☑' : '☐'`) since Phase 1. JSX supports exactly three idiomatic ways to conditionally render content, and picking the right one for the situation makes your code much easier to read:

**1. Ternary (`condition ? A : B`)** — use when you need to render **exactly one of two alternatives**, always:

```jsx
{isComplete ? <span>Done!</span> : <span>Pending</span>}
```

**2. Logical AND (`condition && A`)** — use when you want to render **something, or absolutely nothing** (no alternative needed):

```jsx
{streak > 7 && <span className="fire-indicator">🔥 On fire!</span>}
```

This works because of how JavaScript's `&&` operator evaluates: if the left side (`streak > 7`) is `false`, the entire expression short-circuits to `false` — and React simply renders nothing for a value of `false` (or `null`, or `undefined`). If the left side is `true`, the expression evaluates to (and JSX renders) whatever is on the right side.

> ⚠️ **A well-known trap:** if the left side of `&&` is the *number* `0` (not the boolean `false`), React will actually render the literal text `0` on the screen, because `0` is falsy but JSX still renders numbers as text. A common defensive habit is to write `condition > 0 && (...)` rather than `count && (...)` when `count` might legitimately be zero. We deliberately wrote `streak > 7` above (a boolean-producing comparison), not `streak && (...)`, specifically to sidestep this trap.

**3. Early return** — use when an entire component should render something completely different (or nothing at all) based on a condition, checked *before* the main return statement:

```jsx
function HabitList({ habits }) {
  if (habits.length === 0) {
    return <p>No habits yet — add one to get started!</p>
  }

  return (
    <div>
      {habits.map((habit) => (/* ... */))}
    </div>
  )
}
```

### 🛠️ The Implementation: Applying `&&` and ternary to `HabitsSection`

Let's use the "on fire" indicator (`&&`) inside `HabitCard`, and switch the "remaining" label to a celebratory message (ternary) once everything is complete.

**File: `src/components/HabitCard.jsx`**

```jsx
import Badge from './Badge.jsx'

function HabitCard({ label, streak = 0, isComplete = false, onToggle }) {
  function handleStreakClick(event) {
    event.stopPropagation()
    window.alert(`🔥 ${streak}-day streak! Keep it up.`)
  }

  return (
    <div className="card habit-card" onClick={onToggle}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      {/* Renders nothing at all unless the streak exceeds 7 — a clean use of && */}
      {streak > 7 && <span className="fire-indicator">On fire!</span>}
      <Badge tone="streak" onClick={handleStreakClick}>
        🔥 {streak}
      </Badge>
    </div>
  )
}

export default HabitCard
```

**File: `src/components/HabitsSection.jsx`**

```jsx
import HabitCard from './HabitCard.jsx'

function HabitsSection({ habits, onToggleHabit }) {
  const remainingCount = habits.filter((habit) => !habit.isComplete).length

  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Today's Habits</h2>
        {/* A two-way choice — always shows exactly one of these two things — so a ternary fits perfectly. */}
        {remainingCount === 0 ? (
          <span className="remaining-count remaining-count-done">🎉 All done!</span>
        ) : (
          <span className="remaining-count">{remainingCount} remaining</span>
        )}
      </div>
      <div className="card-list">
        {habits.map((habit) => (
          <HabitCard
            key={habit.id}
            label={habit.label}
            streak={habit.streak}
            isComplete={habit.isComplete}
            onToggle={() => onToggleHabit(habit.id)}
          />
        ))}
      </div>
    </section>
  )
}

export default HabitsSection
```

Add supporting CSS:

**File: `src/index.css`** *(append this block)*

```css
/* --- Conditional indicators --- */

.fire-indicator {
  font-size: 0.8rem;
  font-weight: 600;
  color: #d9480f;
  white-space: nowrap;
}

.remaining-count-done {
  color: #2b8a3e;
  font-weight: 600;
}
```

### ✅ The Verification

Save everything. Go to `localhost:5173`.

1. "Read for 10 minutes" has `streak: 12`, which is greater than 7 — confirm you see the text **"On fire!"** next to it, in orange, between the label and the badge.
2. "Drink 8 glasses of water" (`streak: 5`) and "Stretch for 5 minutes" (`streak: 1`) should **not** show that text at all — confirming `&&` correctly rendered nothing when the condition was false.
3. Click to check off every remaining habit one by one. Once all habits are complete, the header should switch from `"N remaining"` to **"🎉 All done!"** in green — confirming the ternary is correctly evaluating `remainingCount === 0`.
4. Uncheck one habit — the header should immediately revert to showing a numeric "remaining" count.

---

## 🎯 The Target: Building Filter Tabs for the Tasks section

### 🧠 The Concept: Some state should stay local, even in a well-architected app

Back in Phase 2, Part 1, we deliberately *lifted* `isComplete` state up to `App`, because multiple components (the count in `HabitsSection`, individual `HabitCard`s) needed to share and react to it. Filtering is different: **only `TasksSection` itself** needs to know "which filter is currently active." No sibling, no parent, nothing else in the app needs to see this value. This is the other half of the lesson from Part 1: **lift state up only as far as it needs to go — no further.** Keeping filter state local to `TasksSection` keeps `App` simpler and keeps this feature fully self-contained and easy to reason about.

### 🛠️ The Implementation

First, a small, generic, reusable `FilterTabs` component — notice it knows nothing about tasks specifically, so it could be reused for filtering habits, or anything else, later:

**File: `src/components/FilterTabs.jsx`**

```jsx
// FilterTabs is fully generic: it just renders a row of buttons based on
// whatever `options` it's given, highlights whichever matches `activeValue`,
// and reports clicks upward via `onChange`. It has zero knowledge of
// "tasks" or "habits" — that's what makes it reusable.
function FilterTabs({ options, activeValue, onChange }) {
  return (
    <div className="filter-tabs">
      {options.map((option) => (
        <button
          key={option.value}
          type="button"
          className={`filter-tab ${option.value === activeValue ? 'filter-tab-active' : ''}`}
          onClick={() => onChange(option.value)}
        >
          {option.label}
        </button>
      ))}
    </div>
  )
}

export default FilterTabs
```

Note `type="button"` on the `<button>` element — this is a genuinely important, easy-to-forget detail. Without it, a `<button>` inside a `<form>` (which we'll introduce in Phase 3) defaults to `type="submit"`, which would trigger an unwanted form submission. Setting it explicitly now builds the right habit early.

Now wire filtering logic into `TasksSection`, using local state:

**File: `src/components/TasksSection.jsx`**

```jsx
import { useState } from 'react'
import TaskCard from './TaskCard.jsx'
import FilterTabs from './FilterTabs.jsx'

// Defined outside the component since it never changes — no reason to
// recreate this array on every single render.
const FILTER_OPTIONS = [
  { value: 'all', label: 'All' },
  { value: 'active', label: 'Active' },
  { value: 'completed', label: 'Completed' },
]

function TasksSection({ tasks, onToggleTask }) {
  // This state is entirely local — App has no idea this filter even exists,
  // and doesn't need to.
  const [filter, setFilter] = useState('all')

  const filteredTasks = tasks.filter((task) => {
    if (filter === 'active') return !task.isComplete
    if (filter === 'completed') return task.isComplete
    return true // 'all' — keep every task
  })

  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Tasks</h2>
      </div>

      {/* setFilter is passed directly as the onChange handler — FilterTabs
          calls onChange(value), which is exactly the shape setFilter expects. */}
      <FilterTabs options={FILTER_OPTIONS} activeValue={filter} onChange={setFilter} />

      <div className="card-list">
        {filteredTasks.length === 0 ? (
          <p className="empty-state">No tasks match this filter.</p>
        ) : (
          filteredTasks.map((task) => (
            <TaskCard
              key={task.id}
              label={task.label}
              isComplete={task.isComplete}
              onToggle={() => onToggleTask(task.id)}
            />
          ))
        )}
      </div>
    </section>
  )
}

export default TasksSection
```

This is our **early return-adjacent pattern in action** (technically a ternary here, since we're still inside JSX, not a full early `return` from the component) — either we show the empty-state paragraph, or we show the mapped list, never both, and never neither.

Add CSS for the tabs and the empty state:

**File: `src/index.css`** *(append this block)*

```css
/* --- Filter tabs --- */

.filter-tabs {
  display: flex;
  gap: 0.4rem;
  margin-bottom: 0.75rem;
}

.filter-tab {
  border: 1px solid #dddddd;
  background: white;
  border-radius: 999px;
  padding: 0.3rem 0.75rem;
  font-size: 0.85rem;
  cursor: pointer;
  color: #444444;
}

.filter-tab:hover {
  background-color: #f2f2f2;
}

.filter-tab-active {
  background-color: #1a1a1a;
  color: white;
  border-color: #1a1a1a;
}

/* --- Empty state --- */

.empty-state {
  color: #999999;
  font-size: 0.9rem;
  text-align: center;
  padding: 1rem 0;
  margin: 0;
}
```

### ✅ The Verification

Save all files. Go to `localhost:5173`.

1. You should see three pill-shaped buttons above the task list: **All**, **Active**, **Completed** — with **All** highlighted dark by default.
2. Click **Active** — the list should immediately narrow to only tasks that are *not* complete. The tab itself should now be the highlighted (dark) one.
3. Click **Completed** — the list should show only "Buy groceries" (the one sample task that starts checked).
4. Click **Completed** again while it's already active, then, before clicking anything else, check off a currently-*incomplete* task from a different filter view (switch to "Active" or "All" first) — switch back to "Completed" and confirm it now appears in that filtered view too, proving the filter re-evaluates live against current state, not a snapshot.
5. Switch to a filter with zero matches — for instance, uncheck every task, then click **Completed**. You should see the message **"No tasks match this filter."** instead of a blank, empty-looking box.

---

## 📚 Reference Section: Phase 2, Part 3

### The full event object reference (the properties you'll actually use)

React's event objects (technically called **SyntheticEvents** — a thin, consistent wrapper React puts around the browser's native event, so behavior is identical across all browsers) behave almost identically to native DOM events. Here are the members you'll reach for constantly across this series:

| Property / Method | What it does | Where you'll use it |
|---|---|---|
| `event.target` | The actual DOM element the event originated from | Reading `event.target.value` from a text input (Phase 3) |
| `event.target.value` | The current value of an input/textarea/select | Controlled form inputs (Phase 3) |
| `event.target.checked` | The current boolean state of a checkbox/radio | Checkbox-driven toggles |
| `event.preventDefault()` | Stops the browser's default behavior for this event | Preventing a form's default full-page-reload submission (Phase 3) |
| `event.stopPropagation()` | Stops the event from bubbling up to parent element handlers | Isolating a nested clickable element's behavior, as we did with the streak badge |
| `event.key` | Which keyboard key was pressed (for `onKeyDown`/`onKeyUp`) | Detecting "Enter" key presses in a text input |
| `event.currentTarget` | The element the handler is actually attached to (vs. `target`, which may be a descendant) | Useful when a handler is shared across multiple nested elements |

> 🆕 **New in React 19 (historical note):** Older React versions (16 and earlier) used to "pool" event objects for performance — reusing and immediately clearing them after each event, which caused a confusing gotcha where accessing `event.target.value` *asynchronously* (e.g., inside a `setTimeout`) would return `null`. This pooling behavior was removed starting in React 17, and remains gone in React 19 — so accessing event properties asynchronously now works exactly as you'd naturally expect, with no special workaround needed.

### Choosing the right conditional rendering pattern — a decision guide

| Situation | Pattern to use |
|---|---|
| Exactly two mutually exclusive outcomes, always show one | Ternary: `condition ? A : B` |
| Show something, or show nothing at all | `&&`: `condition && <Something />` |
| An entire component's output should differ dramatically, or bail out immediately, based on a condition (e.g., "haven't loaded yet," "no permission") | Early return: `if (condition) return <X />` before the main `return` |
| Many possible discrete outcomes (3+) based on one value | A lookup object or a small helper function, rather than nesting ternaries (nested ternaries quickly become unreadable) |

Here's the "many outcomes" case, shown for reference, since it'll become relevant once we add task priorities or statuses in later phases:

```jsx
const STATUS_LABELS = {
  todo: 'To Do',
  inProgress: 'In Progress',
  done: 'Done',
}

function StatusLabel({ status }) {
  return <span>{STATUS_LABELS[status] ?? 'Unknown'}</span>
}
```

(The `??` above is the **nullish coalescing operator** — "use the left side, unless it's `null` or `undefined`, in which case use the right side." We'll use this again in later parts.)

### Common errors & fixes when handling events and conditions

| Symptom | Likely cause | Fix |
|---|---|---|
| Clicking a nested element also triggers the parent's click handler unexpectedly | Event bubbling — the click ripples up to the ancestor's `onClick` | Call `event.stopPropagation()` inside the nested element's own handler |
| The number `0` appears unexpectedly on screen | Used `count && <Something />` where `count` can legitimately be `0` | Use an explicit comparison instead: `count > 0 && <Something />` |
| `Cannot read properties of undefined (reading 'value')` inside an event handler | Trying to access `event.target.value` on an element that doesn't have a `value` (e.g., a `<div>`) | Confirm the handler is attached to the correct element type, typically an `<input>`/`<textarea>`/`<select>` |
| Filter buttons submit a form and reload the page unexpectedly | Forgot `type="button"` on a `<button>` inside a `<form>` | Always explicitly set `type="button"` for non-submit buttons |
| Empty state and list both appear to briefly render, or neither renders | Ternary condition written incorrectly, or `.length` check placed on the wrong variable | Double check you're checking `filteredTasks.length`, not `tasks.length` |
