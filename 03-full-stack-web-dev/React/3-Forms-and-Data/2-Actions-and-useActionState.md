# Phase 3: Forms & Data
# Part 2: 🆕 Actions & `useActionState` — Modern Form Submission

## Introduction: What we're doing in this part

Look back at `TaskForm.jsx` from the last part. To handle one text field, we needed: a `useState` for the value, an `onChange` handler, a `.trim()`/validation calculation on every render, an `event.preventDefault()`, and manual clearing of the input after submit. And that form doesn't even talk to a real server yet — once it does (Phase 4), we'd *also* need a `isSubmitting` state, a `try/catch` block, and an `error` state, all wired up by hand.

React 19 introduces **Actions** specifically to eliminate this exact pile of boilerplate. In this part, you will:

1. Understand what an Action is, and how it changes the relationship between a `<form>` and the function that handles it.
2. Learn `useActionState` — the hook that gives you submission state (result, pending status) for free.
3. Rebuild `TaskForm` and `HabitForm` using Actions, and directly compare the resulting code to what we wrote last part.
4. Simulate a realistic async validation scenario (a "duplicate task" check with a fake network delay) to see pending and error states genuinely in action.

> 🆕 **New in React 19:** Everything in this part — Actions, `useActionState` — did not exist in this form before React 19. If you've seen older tutorials manually wiring `isSubmitting`/`error` state around a `fetch` call inside a form's `onSubmit`, that entire pattern is exactly what this part replaces. (Trivia: during React's experimental "canary" releases, this hook was briefly called `useFormState` and lived in `react-dom` — it was renamed to `useActionState` and moved to the main `react` package before the stable React 19 release. If you see `useFormState` in older blog posts, know that it's the same idea under its old, pre-release name.)

---

## 🎯 The Target: Understanding what an "Action" actually is

### 🧠 The Concept: A form Action is a job ticket, not a step-by-step instruction sheet

In the traditional pattern from last part, *you* were responsible for every step: intercept the submit event, prevent the default page reload, read each field's value out of state, validate, and decide what happens next. React 19 lets you instead hand the `<form>` element a single function — called an **Action** — and pass it directly to the form's `action` prop:

```jsx
<form action={myAction}>
```

This is a genuinely new capability, not just sugar over `onSubmit`. When you pass a function (rather than a URL string, which is what `action` traditionally expected in plain HTML) to a `<form>`'s `action` prop, React automatically:

* Prevents the default full-page-reload submission behavior — **you never need to call `event.preventDefault()` yourself.**
* Collects all the form's field values for you into a single **`FormData`** object (a built-in browser API representing a form's fields as key/value pairs, read by each input's `name` attribute) and passes it as an argument to your function.
* Understands if your function is `async` (returns a Promise) and automatically tracks whether that submission is still "in flight."

Think of it like handing a job ticket to a work crew instead of supervising every step yourself: you write down what needs to happen ("add this task"), hand the ticket to the `<form>`, and React's machinery handles collecting the raw materials (the field values) and delivering them to your function, tracking whether the job is still in progress.

---

## 🎯 The Target: Understanding `useActionState`

### 🧠 The Concept: `useActionState` is a receipt printer for your Action

A plain Action function is useful on its own, but most real forms need to know **what happened** after submission — did it succeed? What error message should we show? Is it still working? `useActionState` wraps your Action function and hands you back exactly that information, bundled together:

```jsx
const [state, formAction, isPending] = useActionState(myActionFunction, initialState)
```

* **`state`** — whatever your Action function most recently `return`ed (starts as `initialState` before the first submission).
* **`formAction`** — a new, *wrapped* version of your function that you pass to `<form action={formAction}>` instead of your raw function directly. This wrapping is what lets React thread the `state` value through correctly.
* **`isPending`** — a boolean, automatically `true` while your Action's returned Promise hasn't resolved yet, `false` otherwise. **You never write `setIsPending(true)`/`setIsPending(false)` yourself — this replaces that entire manual pattern.**

Your Action function itself now needs to accept **two** arguments instead of one, when wrapped this way: the *previous* state, followed by the `FormData`:

```jsx
async function myActionFunction(previousState, formData) {
  // ... do work ...
  return newState
}
```

The `previousState` parameter exists for cases where a new submission's result logically depends on the last one (for example, a multi-step wizard, or counting consecutive failed attempts) — we won't need it for our simple forms, but it's always there, always passed as the first argument.

---

## 🎯 The Target: Rebuilding `TaskForm` with Actions

### 🧠 The Concept: Simulating a real server check, so pending/error states have something genuine to show

To make this lesson concrete rather than abstract, we're going to give our Action a realistic job: check whether the submitted task label already exists (case-insensitively) among current tasks, and reject it if so — plus a short artificial delay, so you can actually *see* the pending state, the same way you would while waiting on a real network request in Phase 4.

### 🛠️ The Implementation

**File: `src/components/TaskForm.jsx`**

```jsx
import { useActionState } from 'react'

// TaskForm now receives `existingLabels` — a plain array of lowercase
// strings — so its Action can perform a realistic "duplicate" check,
// the same way a real backend might reject a duplicate entry.
function TaskForm({ onAddTask, onCancel, existingLabels }) {
  // This is our Action function. It receives the PREVIOUS state first,
  // then the form's FormData, and must return the NEW state.
  async function addTaskAction(previousState, formData) {
    // formData.get(name) reads a field's value by its `name` attribute —
    // notice there's no React state and no onChange handler involved at all.
    const rawLabel = formData.get('label')
    const label = typeof rawLabel === 'string' ? rawLabel.trim() : ''

    if (label.length === 0) {
      return { error: 'Please enter a task before adding it.' }
    }

    if (existingLabels.includes(label.toLowerCase())) {
      return { error: 'That task already exists.' }
    }

    // Simulate a brief network delay, exactly like a real API call would
    // have in Phase 4 — this is what makes `isPending` visibly meaningful.
    await new Promise((resolve) => setTimeout(resolve, 600))

    onAddTask(label)
    return { error: null }
  }

  const [state, formAction, isPending] = useActionState(addTaskAction, { error: null })

  return (
    <form className="inline-form-group" action={formAction}>
      <div className="inline-form">
        {/*
          Notice: no `value`, no `onChange`. This input is UNCONTROLLED —
          the browser manages its text as the user types, and React only
          reads it once, at submission time, via FormData. The `name`
          attribute is what connects this field to formData.get('label').
        */}
        <input
          type="text"
          name="label"
          className="inline-form-input"
          placeholder="What do you need to do?"
          autoFocus
          disabled={isPending}
        />
        <button type="submit" className="inline-form-submit" disabled={isPending}>
          {isPending ? 'Adding…' : 'Add'}
        </button>
        <button
          type="button"
          className="inline-form-cancel"
          onClick={onCancel}
          disabled={isPending}
        >
          Cancel
        </button>
      </div>
      {state.error && <p className="form-error">{state.error}</p>}
    </form>
  )
}

export default TaskForm
```

Compare this mentally to last part's version: there is **no `useState` for the input value**, **no `event.preventDefault()`**, and **no manually-managed `isSubmitting` state** — `isPending` is handed to us automatically by `useActionState`, driven entirely by whether our `async` function's Promise has resolved yet.

### 🛠️ The Implementation: `HabitForm`, following the identical pattern

**File: `src/components/HabitForm.jsx`**

```jsx
import { useActionState } from 'react'

function HabitForm({ onAddHabit, onCancel, existingLabels }) {
  async function addHabitAction(previousState, formData) {
    const rawLabel = formData.get('label')
    const label = typeof rawLabel === 'string' ? rawLabel.trim() : ''

    if (label.length === 0) {
      return { error: 'Please enter a habit before adding it.' }
    }

    if (existingLabels.includes(label.toLowerCase())) {
      return { error: 'That habit already exists.' }
    }

    await new Promise((resolve) => setTimeout(resolve, 600))

    onAddHabit(label)
    return { error: null }
  }

  const [state, formAction, isPending] = useActionState(addHabitAction, { error: null })

  return (
    <form className="inline-form-group" action={formAction}>
      <div className="inline-form">
        <input
          type="text"
          name="label"
          className="inline-form-input"
          placeholder="What habit do you want to build?"
          autoFocus
          disabled={isPending}
        />
        <button type="submit" className="inline-form-submit" disabled={isPending}>
          {isPending ? 'Adding…' : 'Add'}
        </button>
        <button
          type="button"
          className="inline-form-cancel"
          onClick={onCancel}
          disabled={isPending}
        >
          Cancel
        </button>
      </div>
      {state.error && <p className="form-error">{state.error}</p>}
    </form>
  )
}

export default HabitForm
```

### 🛠️ The Implementation: Passing `existingLabels` from each section

**File: `src/components/TasksSection.jsx`**

```jsx
import { useState } from 'react'
import TaskCard from './TaskCard.jsx'
import FilterTabs from './FilterTabs.jsx'
import TaskForm from './TaskForm.jsx'

const FILTER_OPTIONS = [
  { value: 'all', label: 'All' },
  { value: 'active', label: 'Active' },
  { value: 'completed', label: 'Completed' },
]

function TasksSection({ tasks, onToggleTask, onAddTask }) {
  const [filter, setFilter] = useState('all')
  const [isAdding, setIsAdding] = useState(false)

  const filteredTasks = tasks.filter((task) => {
    if (filter === 'active') return !task.isComplete
    if (filter === 'completed') return task.isComplete
    return true
  })

  // Computed fresh on every render directly from current task data —
  // always accurate, never a separately-tracked, potentially-stale copy.
  const existingLabels = tasks.map((task) => task.label.toLowerCase())

  function handleAddTask(label) {
    onAddTask(label)
    setIsAdding(false)
  }

  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Tasks</h2>
        {!isAdding && (
          <button type="button" className="add-button" onClick={() => setIsAdding(true)}>
            + New Task
          </button>
        )}
      </div>

      {isAdding && (
        <TaskForm
          onAddTask={handleAddTask}
          onCancel={() => setIsAdding(false)}
          existingLabels={existingLabels}
        />
      )}

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

**File: `src/components/HabitsSection.jsx`**

```jsx
import { useState } from 'react'
import HabitCard from './HabitCard.jsx'
import HabitForm from './HabitForm.jsx'

function HabitsSection({ habits, onToggleHabit, onAddHabit }) {
  const [isAdding, setIsAdding] = useState(false)
  const remainingCount = habits.filter((habit) => !habit.isComplete).length
  const existingLabels = habits.map((habit) => habit.label.toLowerCase())

  function handleAddHabit(label) {
    onAddHabit(label)
    setIsAdding(false)
  }

  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Today's Habits</h2>
        {remainingCount === 0 ? (
          <span className="remaining-count remaining-count-done">🎉 All done!</span>
        ) : (
          <span className="remaining-count">{remainingCount} remaining</span>
        )}
      </div>

      {isAdding && (
        <HabitForm
          onAddHabit={handleAddHabit}
          onCancel={() => setIsAdding(false)}
          existingLabels={existingLabels}
        />
      )}

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

      {!isAdding && (
        <button
          type="button"
          className="add-button add-button-block"
          onClick={() => setIsAdding(true)}
        >
          + New Habit
        </button>
      )}
    </section>
  )
}

export default HabitsSection
```

Add CSS for the error message and slightly restructure the form's vertical spacing:

**File: `src/index.css`** *(append this block)*

```css
/* --- Form error messaging --- */

.inline-form-group {
  margin-bottom: 0.75rem;
}

.form-error {
  color: #c92a2a;
  font-size: 0.85rem;
  margin: 0.35rem 0 0;
}
```

### ✅ The Verification

Save every file. Go to `localhost:5173`.

1. Click **"+ New Task"**, leave the input empty, and click **"Add"** (or press Enter). After a brief moment, notice the button read **"Adding…"** and became disabled during that time — this is `isPending`, working automatically, with zero manual state code on your part. Then confirm the message **"Please enter a task before adding it."** appears below the form.
2. Now type **`Buy groceries`** exactly (matching an existing sample task, case-insensitively) and submit. After the same brief pending delay, confirm you see **"That task already exists."** — and notice **your typed text is still sitting in the input** afterward. This is a natural side effect of the input being uncontrolled: the browser never cleared it, since nothing told it to.
3. Now type a genuinely new task, like `"Walk the dog"`, and submit. Confirm the "Adding…" pending state briefly appears, then the form closes and the new task shows up in the list.
4. Repeat all three checks with **"+ New Habit"**, substituting an existing habit label (e.g., `"Read for 10 minutes"`) for the duplicate check.

**Try this:** While a submission is pending (you have about 600ms — try clicking quickly after submitting), attempt to click **"Cancel"** or type in the disabled input. Confirm both are unresponsive until the pending state finishes — this is exactly why we bound `disabled={isPending}` to the inputs and buttons: it prevents a user from firing a second, overlapping submission or backing out mid-request.

---

## 📚 Reference Section: Phase 3, Part 2

### `useActionState` — full API reference

```javascript
const [state, formAction, isPending] = useActionState(actionFn, initialState, permalink?)
```

* **`actionFn(previousState, formData)`** — your function. May be `async` or synchronous. Whatever it `return`s becomes the new `state`.
* **`initialState`** — the value `state` holds before the very first submission ever happens.
* **`permalink`** *(optional, rarely needed)* — a URL string used specifically for progressive enhancement in server-rendered frameworks (like Next.js) so a form can still function via a real page navigation if JavaScript hasn't loaded yet. Not relevant to our fully client-rendered Vite app, but worth knowing it exists if you move to a server-rendering framework later.
* **`state`** — the current result, starting as `initialState`.
* **`formAction`** — pass this (not your raw function) to `<form action={formAction}>`.
* **`isPending`** — `true` from the moment of submission until your function's returned Promise settles.

### The `FormData` API, briefly

`FormData` is a standard browser API, not a React invention — this is genuinely useful knowledge outside of React too:

```javascript
// Given: <input name="label" /> and <input name="priority" />
function myAction(previousState, formData) {
  const label = formData.get('label')       // returns a string, or null if absent
  const priority = formData.get('priority') // same
  const allTags = formData.getAll('tags')   // returns an ARRAY — useful if multiple fields share one `name`
  const hasNewsletter = formData.has('newsletter') // true/false — common for checkboxes
}
```

Every value read via `.get()` is a **string** (or a `File` object, for `<input type="file">`) — even a number-looking input (`<input type="number" name="age" />`) gives you back the string `"25"`, not the number `25`. Always convert explicitly (`Number(formData.get('age'))`) when you need a real number.

### Actions outside of `<form>`: a preview

Actions aren't exclusively a `<form>` feature. A single button can trigger its own Action via the `formAction` prop (useful for forms with multiple possible submit buttons, e.g., "Save Draft" vs. "Publish"), and Actions can also be triggered imperatively via `startTransition` from inside event handlers, entirely outside of any form. We won't need these variants for our Tracker, but know they exist if you encounter them in other codebases.

### Why didn't we just keep `onChange`-driven controlled inputs and merely swap in `useActionState` for the submit logic?

You technically can mix the two — nothing stops you from having a controlled input *and* using an Action. We deliberately went fully uncontrolled here (no `value`/`onChange` on the text input at all) specifically to demonstrate the **complete** boilerplate reduction Actions unlock: an entire class of "track this input's live value" code disappears when you only need the value once, at submission time, via `FormData`. If a future field genuinely needs live validation *as the user types* (character counters, live-formatting, etc.), pairing a controlled input with an Action is perfectly valid — the two patterns are not mutually exclusive.

### Is it safe for an Action to update state in a component that's about to unmount?

In both `TaskForm` and `HabitForm`, our Action calls `onAddTask`/`onAddHabit` (which closes the form, unmounting it) and *then* returns its final state. You might worry this causes a "set state on unmounted component" warning, common in older React patterns. It doesn't — React 19's Action-handling machinery is specifically designed to resolve this safely and silently, unlike the manual `useState`-inside-a-`.then()` pattern from pre-Actions code, which genuinely could trigger that warning if a component unmounted before a Promise resolved.

### Common errors & fixes when working with Actions

| Symptom | Likely cause | Fix |
|---|---|---|
| `formData.get('label')` returns `null` | The `<input>` is missing a `name` attribute, or the name doesn't match exactly | Add/correct the `name="label"` attribute |
| Form still reloads the page on submit | Passed the raw action function directly to `action`, but something else on the page still calls `preventDefault` incorrectly, or `action` was set to a string URL by mistake | Confirm `action={formAction}` (the wrapped function from `useActionState`), not a string |
| `isPending` never becomes `true`, even with an artificial delay | Action function isn't actually `async` / doesn't return a Promise | Mark the function `async` and/or ensure it truly awaits something |
| Error message from a previous failed submission "flashes" briefly before a new one replaces it | Expected behavior — `state` only updates once the new submission resolves | Optionally clear/hide old errors immediately on new submission using `isPending` in your JSX condition |
| `useActionState is not a function` / import error | Imported from `react-dom` instead of `react`, following an outdated pre-release tutorial | Import from `'react'`: `import { useActionState } from 'react'` |
