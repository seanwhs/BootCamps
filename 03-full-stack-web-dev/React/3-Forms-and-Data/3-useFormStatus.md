# Phase 3: Forms & Data
# Part 3: 🆕 `useFormStatus` — Pending UI States

## Introduction: What we're doing in this part

Look closely at `TaskForm.jsx` from the last part. We destructure `isPending` from `useActionState`, and then manually pass its value down into three different places: the `<input disabled={isPending}>`, the submit `<button disabled={isPending}>`, and the cancel `<button disabled={isPending}>`. That's not *terrible* — it's only three usages, in one file — but picture what happens once a form grows more complex: a character counter, a formatting hint, a secondary "save as draft" button, all nested a few components deep. Every single one of those would need `isPending` threaded down to it as a prop, layer after layer — exactly the "prop drilling" pain we first identified back in Phase 1, Part 3.

React 19's `useFormStatus` solves this directly. In this part, you will:

1. Understand what `useFormStatus` does and the one crucial rule about *where* it can be called.
2. Extract `SubmitButton`, `CancelButton`, and `FormTextInput` into small, genuinely reusable components that each independently know whether their form is submitting — with zero props passed for that purpose.
3. Run a hands-on experiment proving exactly where the "must be a descendant of the form" rule bites you, so it's a lesson you've *seen fail*, not just read about.

> 🆕 **New in React 19:** `useFormStatus` is a genuinely new hook. Before Actions existed, there was no equivalent — pending state had to be hand-rolled with `useState` and manually threaded through props exactly like `isPending` was in the previous part, no matter how deep the component tree got.

---

## 🎯 The Target: Understanding `useFormStatus` and its one critical rule

### 🧠 The Concept: An intercom built into the walls of the form

Picture a `<form>` as a room with an intercom system wired into every wall. Any component rendered *inside* that room can pick up a nearby intercom handset and ask, "Hey, are we currently busy submitting something?" — without anyone needing to personally walk over and tell them. That's `useFormStatus`: any component nested inside a `<form>` can call it and immediately know that form's current submission status, with no props passed down at all.

```jsx
import { useFormStatus } from 'react-dom'

function SomeNestedComponent() {
  const { pending } = useFormStatus()
  return <p>{pending ? 'Submitting…' : 'Idle'}</p>
}
```

Two details are easy to trip over, so let's be explicit about both right away:

**1. It's imported from `react-dom`, not `react`.** This is different from `useActionState`, which we imported from `react` in the last part. The reasoning: `useFormStatus` is inherently tied to the browser's `<form>` DOM element — it's a DOM-specific concept, so it lives in the DOM-specific package. `useActionState` is more general-purpose (Actions aren't exclusively a form/DOM concept), so it lives in the core `react` package. Mixing these imports up is a common, easy-to-make mistake.

**2. The component calling `useFormStatus` must be a *descendant* of the `<form>` — never the same component that renders the `<form>` element itself.** This is the "intercom in the walls" analogy taken literally: you have to actually be *inside the room* to use its intercom. A component that renders `<form>...</form>` is standing at the doorway, building the room — it is not yet inside it. We're about to prove this concretely, because it's the single most common point of confusion with this hook.

---

## 🎯 The Target: Extracting `FormTextInput`, `SubmitButton`, and `CancelButton`

### 🧠 The Concept: Small, self-sufficient components instead of prop relay stations

We're going to pull three pieces out of `TaskForm`/`HabitForm` into their own dedicated, genuinely reusable files. Each one will independently ask `useFormStatus` for the current pending state, rather than receiving it as a prop. This means `TaskForm` and `HabitForm` themselves get simpler — they no longer need to compute or forward `isPending` to their children at all.

### 🛠️ The Implementation

**File: `src/components/FormTextInput.jsx`**

```jsx
import { useFormStatus } from 'react-dom'

// This component is a DESCENDANT of whatever <form> it's rendered inside —
// that's what makes useFormStatus() here actually work. It independently
// discovers whether ITS form is submitting, with no prop passed for it.
function FormTextInput({ name, placeholder }) {
  const { pending } = useFormStatus()

  return (
    <input
      type="text"
      name={name}
      className="inline-form-input"
      placeholder={placeholder}
      autoFocus
      disabled={pending}
    />
  )
}

export default FormTextInput
```

**File: `src/components/SubmitButton.jsx`**

```jsx
import { useFormStatus } from 'react-dom'

// A fully generic submit button, reusable across ANY form in this app.
// It never needs to be told whether it's pending — it asks the form itself.
function SubmitButton({ idleLabel, pendingLabel }) {
  const { pending } = useFormStatus()

  return (
    <button type="submit" className="inline-form-submit" disabled={pending}>
      {pending ? pendingLabel : idleLabel}
    </button>
  )
}

export default SubmitButton
```

**File: `src/components/CancelButton.jsx`**

```jsx
import { useFormStatus } from 'react-dom'

// Even the Cancel button independently disables itself while submitting,
// preventing a user from backing out mid-request — without TaskForm or
// HabitForm needing to pass it any pending-related prop whatsoever.
function CancelButton({ onCancel }) {
  const { pending } = useFormStatus()

  return (
    <button
      type="button"
      className="inline-form-cancel"
      onClick={onCancel}
      disabled={pending}
    >
      Cancel
    </button>
  )
}

export default CancelButton
```

Now simplify `TaskForm` to use these three pieces:

**File: `src/components/TaskForm.jsx`**

```jsx
import { useActionState } from 'react'
import FormTextInput from './FormTextInput.jsx'
import SubmitButton from './SubmitButton.jsx'
import CancelButton from './CancelButton.jsx'

function TaskForm({ onAddTask, onCancel, existingLabels }) {
  async function addTaskAction(previousState, formData) {
    const rawLabel = formData.get('label')
    const label = typeof rawLabel === 'string' ? rawLabel.trim() : ''

    if (label.length === 0) {
      return { error: 'Please enter a task before adding it.' }
    }

    if (existingLabels.includes(label.toLowerCase())) {
      return { error: 'That task already exists.' }
    }

    await new Promise((resolve) => setTimeout(resolve, 600))

    onAddTask(label)
    return { error: null }
  }

  // Notice: we no longer destructure a third `isPending` value here at all.
  // Nothing in THIS component needs it anymore — FormTextInput, SubmitButton,
  // and CancelButton each independently discover it via useFormStatus.
  const [state, formAction] = useActionState(addTaskAction, { error: null })

  return (
    <form className="inline-form-group" action={formAction}>
      <div className="inline-form">
        <FormTextInput name="label" placeholder="What do you need to do?" />
        <SubmitButton idleLabel="Add" pendingLabel="Adding…" />
        <CancelButton onCancel={onCancel} />
      </div>
      {state.error && <p className="form-error">{state.error}</p>}
    </form>
  )
}

export default TaskForm
```

**File: `src/components/HabitForm.jsx`**

```jsx
import { useActionState } from 'react'
import FormTextInput from './FormTextInput.jsx'
import SubmitButton from './SubmitButton.jsx'
import CancelButton from './CancelButton.jsx'

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

  const [state, formAction] = useActionState(addHabitAction, { error: null })

  return (
    <form className="inline-form-group" action={formAction}>
      <div className="inline-form">
        <FormTextInput name="label" placeholder="What habit do you want to build?" />
        <SubmitButton idleLabel="Add" pendingLabel="Adding…" />
        <CancelButton onCancel={onCancel} />
      </div>
      {state.error && <p className="form-error">{state.error}</p>}
    </form>
  )
}

export default HabitForm
```

### ✅ The Verification

Save every file. Go to `localhost:5173`.

1. Click **"+ New Task"**, type `"Walk the dog"`, and submit. During the ~600ms delay, confirm: the input becomes visibly disabled, the submit button reads **"Adding…"** and is disabled, and the **Cancel** button is also disabled — all three, correctly synchronized, despite `TaskForm` never explicitly telling any of them "you are now pending."
2. Repeat with `HabitForm` for a new habit like `"Stretch after waking up"`, confirming identical behavior.
3. Open `src/components/TaskForm.jsx` in your editor and confirm — just by reading it — that the word `isPending` (or `pending`) does not appear anywhere in this file at all. All pending-related behavior is now fully encapsulated inside the three extracted components.

---

## 🎯 The Target: Proving the "must be a descendant" rule, live

### 🧠 The Concept: Standing at the doorway vs. standing inside the room

Let's deliberately break the rule, on purpose, in a disposable experiment, so you've genuinely seen the failure mode with your own eyes — not just read a warning about it.

### 🛠️ The Implementation: A temporary, broken version

Temporarily edit `TaskForm.jsx` to call `useFormStatus` directly inside the same function that renders the `<form>` element:

**File: `src/components/TaskForm.jsx`** *(temporary, broken experiment — do not keep this)*

```jsx
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom' // added temporarily for this experiment
import FormTextInput from './FormTextInput.jsx'
import SubmitButton from './SubmitButton.jsx'
import CancelButton from './CancelButton.jsx'

function TaskForm({ onAddTask, onCancel, existingLabels }) {
  async function addTaskAction(previousState, formData) {
    const rawLabel = formData.get('label')
    const label = typeof rawLabel === 'string' ? rawLabel.trim() : ''

    if (label.length === 0) {
      return { error: 'Please enter a task before adding it.' }
    }
    if (existingLabels.includes(label.toLowerCase())) {
      return { error: 'That task already exists.' }
    }

    await new Promise((resolve) => setTimeout(resolve, 600))
    onAddTask(label)
    return { error: null }
  }

  const [state, formAction] = useActionState(addTaskAction, { error: null })

  // ❌ Calling useFormStatus HERE, in the component that RENDERS the <form>
  // element itself, rather than inside a descendant of it.
  const { pending } = useFormStatus()
  console.log('Pending, measured at the form-rendering level:', pending)

  return (
    <form className="inline-form-group" action={formAction}>
      <div className="inline-form">
        <FormTextInput name="label" placeholder="What do you need to do?" />
        <SubmitButton idleLabel="Add" pendingLabel="Adding…" />
        <CancelButton onCancel={onCancel} />
      </div>
      {state.error && <p className="form-error">{state.error}</p>}
    </form>
  )
}

export default TaskForm
```

### ✅ The Verification

Save this temporarily broken version. Open your browser DevTools Console (F12). Click **"+ New Task"**, type `"Test the bug"`, and submit.

**Expected (broken) result:** Watch the console log. Even while the `SubmitButton` inside the form correctly shows "Adding…", the `console.log` at the `TaskForm` level logs **`false`** the entire time — it never observes `true`, because `useFormStatus`, called at this level, is measuring the status of any `<form>` that might be an *ancestor* of `TaskForm` itself (in our case, there is none — `TaskForm` is rendering the form, not sitting inside one), so it always reports the default, resting state.

This is the exact failure mode the "must be a descendant" rule warns about: `useFormStatus` doesn't magically know about the `<form>` your component happens to be *returning* in its JSX — it only sees forms that are genuine ancestors in the actual rendered component tree.

### 🛠️ Cleanup: Revert to the correct version

Remove the `useFormStatus` import and the two experimental lines from `TaskForm.jsx`, restoring it exactly to the clean version from the previous step (no `useFormStatus` import, no `console.log`, no `pending` variable at that level).

Confirm your restored file matches this exactly:

**File: `src/components/TaskForm.jsx`** *(confirmed restored state)*

```jsx
import { useActionState } from 'react'
import FormTextInput from './FormTextInput.jsx'
import SubmitButton from './SubmitButton.jsx'
import CancelButton from './CancelButton.jsx'

function TaskForm({ onAddTask, onCancel, existingLabels }) {
  async function addTaskAction(previousState, formData) {
    const rawLabel = formData.get('label')
    const label = typeof rawLabel === 'string' ? rawLabel.trim() : ''

    if (label.length === 0) {
      return { error: 'Please enter a task before adding it.' }
    }

    if (existingLabels.includes(label.toLowerCase())) {
      return { error: 'That task already exists.' }
    }

    await new Promise((resolve) => setTimeout(resolve, 600))

    onAddTask(label)
    return { error: null }
  }

  const [state, formAction] = useActionState(addTaskAction, { error: null })

  return (
    <form className="inline-form-group" action={formAction}>
      <div className="inline-form">
        <FormTextInput name="label" placeholder="What do you need to do?" />
        <SubmitButton idleLabel="Add" pendingLabel="Adding…" />
        <CancelButton onCancel={onCancel} />
      </div>
      {state.error && <p className="form-error">{state.error}</p>}
    </form>
  )
}

export default TaskForm
```

### ✅ The Verification

Save. Repeat the earlier verification (submit a new task, watch the three extracted components correctly reflect pending state) to confirm everything still works after cleanup.

---

## 📚 Reference Section: Phase 3, Part 3

### `useFormStatus` — full API reference

```javascript
const { pending, data, method, action } = useFormStatus()
```

| Property | Type | Description |
|---|---|---|
| `pending` | `boolean` | `true` while the nearest ancestor `<form>`'s submission is in flight |
| `data` | `FormData \| null` | The `FormData` currently being submitted, or `null` if idle — useful for optimistically displaying submitted values before the server confirms them |
| `method` | `string` | The HTTP method of the submission (typically `"get"` or `"post"`) |
| `action` | `function \| string \| null` | A reference to the function (or URL string) passed to the form's `action` prop |

We only used `pending` in this part, but `data` becomes genuinely useful in more advanced patterns — for example, showing "Adding 'Walk the dog'…" (reading the label directly out of `data`) rather than a generic "Adding…" message, without needing any additional state.

### `useActionState`'s `isPending` vs. `useFormStatus`'s `pending` — which should you use?

Both ultimately reflect the same underlying fact — "is this Action currently running?" — but they're accessed differently, and each fits a different situation:

| | `useActionState`'s third return value | `useFormStatus`'s `pending` |
|---|---|---|
| **Where you call it** | In the same component that calls `useActionState` (often the one rendering the `<form>`) | In any descendant component nested inside the `<form>` |
| **Best for** | Logic that lives alongside the Action itself (e.g., deciding what `state` to show) | UI pieces nested arbitrarily deep inside the form, without prop drilling |
| **Requires** | Direct access to the hook call itself | Only being rendered somewhere inside the relevant `<form>` |

In our case, since `TaskForm`/`HabitForm` render the `<form>` directly, either approach could have worked for *this specific tree depth*. We chose `useFormStatus` for the nested buttons/input specifically to demonstrate the pattern that pays off enormously once a form's internals grow deeper or get reused across genuinely different parent contexts — exactly the situation prop drilling makes painful.

### Common errors & fixes when working with `useFormStatus`

| Symptom | Likely cause | Fix |
|---|---|---|
| `pending` is always `false`, even during a real submission | `useFormStatus` was called in the same component that renders the `<form>` element, not a descendant of it | Move the call into a genuinely nested child component |
| `useFormStatus is not a function` / import error | Imported from `'react'` instead of `'react-dom'` | Change the import to `import { useFormStatus } from 'react-dom'` |
| A button disables correctly but doesn't visually indicate why | No pending-specific label/style applied | Use `pending` to conditionally change text/styling, as done with `idleLabel`/`pendingLabel` |
| Multiple forms on the same page seem to interfere with each other's pending status | Rare in practice — `useFormStatus` correctly scopes to its *nearest* ancestor form; this usually indicates unexpectedly nested `<form>` elements (which HTML itself disallows) | Ensure forms are siblings, not nested inside one another |
