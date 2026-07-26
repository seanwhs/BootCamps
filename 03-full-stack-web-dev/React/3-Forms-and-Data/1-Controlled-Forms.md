# Phase 3: Forms & Data
# Part 1: Controlled Forms — Adding New Tasks and Habits

## Introduction: What we're doing in this part

Our Tracker can toggle and filter tasks and habits, but it can't actually grow — the list is frozen at whatever's in `sampleData.js`. A task tracker that can't add tasks isn't much of a tracker. In this part, you will:

1. Learn what a **controlled input** is, and why React wants you to manage form values through state rather than letting the browser manage them.
2. Build a reusable `TaskForm` and `HabitForm`, each with proper validation (no empty submissions).
3. Learn how to safely generate unique IDs for new items.
4. Wire "add" handlers all the way up to `App`, following the exact same lifting-state-up pattern from Phase 2.
5. Add a toggleable "New Task" / "New Habit" button so the forms only appear when needed.

This part deliberately uses the **traditional** way of handling forms in React — manual `useState` per field, manual `onSubmit`. In the very next part, we introduce React 19's **Actions**, and you'll directly feel how much boilerplate they remove — but you can only appreciate that contrast by first building the "hard way" here, so keep this part's code in mind going forward.

---

## 🎯 The Target: Understanding controlled inputs

### 🧠 The Concept: A controlled input is a puppet; React holds the strings

In plain HTML, an `<input>` manages its own value internally — you type, the browser updates what's displayed, and you only find out the current value when you go ask for it (e.g., `document.querySelector('input').value`). This is sometimes called an **uncontrolled** input, because nothing outside the input itself is "in control" of its value.

React's preferred pattern flips this around entirely: a **controlled input** has its `value` explicitly set from React state, and *every* keystroke is captured via `onChange` and written back into that same state. The input becomes a puppet, and a piece of React state holds the strings — the displayed value is never something the input "just remembers" on its own; it's always a direct reflection of state, re-supplied on every render.

```jsx
function ControlledExample() {
  const [text, setText] = useState('')

  return (
    <input
      value={text}                                    // React dictates what's shown
      onChange={(event) => setText(event.target.value)} // every keystroke updates state
    />
  )
}
```

Why go to this trouble? Because once the input's value lives in state, you gain the ability to: validate it as the user types, disable a submit button until it's non-empty, clear it programmatically after submission, or even transform it (e.g., auto-capitalize) — all using the same `useState` tools you already know, rather than reaching for imperative DOM APIs. This is the same "declarative over imperative" philosophy from Phase 1, Part 1, now applied to form inputs specifically.

---

## 🎯 The Target: Building a reusable `TaskForm`

### 🧠 The Concept: A form component's job is to collect input and hand off a clean result

`TaskForm` doesn't need to know *how* a new task gets added to the list, or where that list lives. Its only responsibility is: collect a valid label from the user, and when submitted, report that single clean string upward via a prop — exactly the same "report upward via a function prop" pattern we used for `onToggle` in Phase 2.

### 🛠️ The Implementation

**File: `src/components/TaskForm.jsx`**

```jsx
import { useState } from 'react'

// TaskForm only knows how to collect ONE thing: a task label. It reports
// the finished result upward via onAddTask, and knows nothing about arrays,
// ids, or where the task list actually lives — that's App's responsibility.
function TaskForm({ onAddTask, onCancel }) {
  const [label, setLabel] = useState('')

  // .trim() removes leading/trailing whitespace — this stops a user from
  // submitting a "task" that's just spaces, which would look like an
  // empty, broken row in the list.
  const trimmedLabel = label.trim()
  const isValid = trimmedLabel.length > 0

  function handleSubmit(event) {
    // Forms reload the whole page by default when submitted — a behavior
    // left over from the era before JavaScript handled form submissions.
    // preventDefault() stops that, so we can handle the submission ourselves.
    event.preventDefault()

    if (!isValid) return // extra safety net, even though the button will be disabled

    onAddTask(trimmedLabel)
    setLabel('') // clear the input, ready for the next task
  }

  return (
    <form className="inline-form" onSubmit={handleSubmit}>
      <input
        type="text"
        className="inline-form-input"
        placeholder="What do you need to do?"
        value={label}
        onChange={(event) => setLabel(event.target.value)}
        autoFocus
      />
      <button type="submit" className="inline-form-submit" disabled={!isValid}>
        Add
      </button>
      <button type="button" className="inline-form-cancel" onClick={onCancel}>
        Cancel
      </button>
    </form>
  )
}

export default TaskForm
```

A few details worth calling out explicitly:

* `onSubmit={handleSubmit}` is placed on the `<form>` element itself, **not** on the button. This means pressing **Enter** while focused in the input also submits the form — matching how users expect forms to behave everywhere on the web, not just when clicking "Add" directly.
* `disabled={!isValid}` — the submit button's `disabled` attribute is itself driven by state (derived from `label`, which is state). This is a controlled input's superpower in action: validation logic lives in plain JavaScript, not scattered HTML attributes.
* `autoFocus` is a plain HTML attribute (React supports it directly) that focuses the input as soon as it mounts — a small but meaningful UX touch, since the user just clicked "New Task" specifically to start typing.

### 🛠️ The Implementation: `HabitForm`, following the identical pattern

**File: `src/components/HabitForm.jsx`**

```jsx
import { useState } from 'react'

function HabitForm({ onAddHabit, onCancel }) {
  const [label, setLabel] = useState('')

  const trimmedLabel = label.trim()
  const isValid = trimmedLabel.length > 0

  function handleSubmit(event) {
    event.preventDefault()
    if (!isValid) return

    onAddHabit(trimmedLabel)
    setLabel('')
  }

  return (
    <form className="inline-form" onSubmit={handleSubmit}>
      <input
        type="text"
        className="inline-form-input"
        placeholder="What habit do you want to build?"
        value={label}
        onChange={(event) => setLabel(event.target.value)}
        autoFocus
      />
      <button type="submit" className="inline-form-submit" disabled={!isValid}>
        Add
      </button>
      <button type="button" className="inline-form-cancel" onClick={onCancel}>
        Cancel
      </button>
    </form>
  )
}

export default HabitForm
```

### ✅ The Verification

No visual output yet — these components aren't rendered anywhere until we wire them into the sections below. Just confirm both files save with no red squiggly errors in your editor before continuing.

---

## 🎯 The Target: Generating unique IDs for new items

### 🧠 The Concept: Every item needs a permanent, unique name tag the moment it's born

Recall from Phase 2, Part 2 that `key` (and our toggle-matching logic) depends entirely on every item having a stable, unique `id`. Our sample data had IDs handed to us already (`1`, `2`, `3`...), but new tasks created by the user don't come with one built in — we have to generate one ourselves, at the exact moment the item is created.

The modern, built-in browser tool for this is `crypto.randomUUID()` — a function available in all modern browsers (and Node.js) that generates a **UUID** (Universally Unique Identifier): a long, essentially-guaranteed-unique string like `"3f7b1c9e-4a2d-4e5f-9c3a-8b2e1d4f6a7c"`. We don't need to fully understand the math behind it — just that calling it gives us an id so statistically unlikely to collide with any other id, ever, that we can treat it as guaranteed-unique for our purposes.

```javascript
crypto.randomUUID() // "3f7b1c9e-4a2d-4e5f-9c3a-8b2e1d4f6a7c"
```

### ✅ The Verification (a quick sanity check before we build further)

Open your browser DevTools Console (F12 → Console tab) on any page and type:

```javascript
crypto.randomUUID()
```

**Expected output:** a long string in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`. Run it again — you'll get a *different* string each time, confirming its randomness.

---

## 🎯 The Target: Wiring "add" handlers up through the component tree

### 🧠 The Concept: Adding to a list is just another immutable state update

Adding a new item follows the exact same immutability discipline from Phase 2, Part 1 — we never push directly onto the existing array (`tasks.push(...)` would mutate it in place). Instead, we build a **brand new array** that contains everything from before, plus one new item at the end, using the spread operator.

### 🛠️ The Implementation

**File: `src/App.jsx`**

```jsx
import { useState } from 'react'
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'
import { sampleHabits, sampleTasks } from './data/sampleData.js'

function App() {
  const [habits, setHabits] = useState(sampleHabits)
  const [tasks, setTasks] = useState(sampleTasks)

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

  // Builds a brand new task object with a fresh, guaranteed-unique id,
  // then builds a brand new array containing every existing task PLUS
  // this one new task at the end — never mutating the original array.
  function handleAddTask(label) {
    const newTask = {
      id: crypto.randomUUID(),
      label,
      isComplete: false,
    }
    setTasks((currentTasks) => [...currentTasks, newTask])
  }

  function handleAddHabit(label) {
    const newHabit = {
      id: crypto.randomUUID(),
      label,
      streak: 0,
      isComplete: false,
    }
    setHabits((currentHabits) => [...currentHabits, newHabit])
  }

  return (
    <div className="app">
      <Navbar />
      <Dashboard
        habits={habits}
        tasks={tasks}
        onToggleHabit={handleToggleHabit}
        onToggleTask={handleToggleTask}
        onAddHabit={handleAddHabit}
        onAddTask={handleAddTask}
      />
    </div>
  )
}

export default App
```

**File: `src/components/Dashboard.jsx`**

```jsx
import HabitsSection from './HabitsSection.jsx'
import TasksSection from './TasksSection.jsx'

function Dashboard({
  habits,
  tasks,
  onToggleHabit,
  onToggleTask,
  onAddHabit,
  onAddTask,
}) {
  return (
    <main className="dashboard">
      <HabitsSection habits={habits} onToggleHabit={onToggleHabit} onAddHabit={onAddHabit} />
      <TasksSection tasks={tasks} onToggleTask={onToggleTask} onAddTask={onAddTask} />
    </main>
  )
}

export default Dashboard
```

Now, `TasksSection` needs its own small piece of **local** state: whether the "add" form is currently visible. This follows the same "keep state as local as possible" principle from Phase 2, Part 3 — no other component needs to know whether the form is open.

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

  // Wraps onAddTask so we can also close the form immediately after a
  // successful submission — a small orchestration detail that belongs
  // here, not inside the generic TaskForm component.
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
        <TaskForm onAddTask={handleAddTask} onCancel={() => setIsAdding(false)} />
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
        <HabitForm onAddHabit={handleAddHabit} onCancel={() => setIsAdding(false)} />
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
        <button type="button" className="add-button add-button-block" onClick={() => setIsAdding(true)}>
          + New Habit
        </button>
      )}
    </section>
  )
}

export default HabitsSection
```

Finally, add the CSS for the new form and buttons:

**File: `src/index.css`** *(append this block)*

```css
/* --- Add buttons --- */

.add-button {
  border: none;
  background: none;
  color: #2f6fed;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0.2rem 0.4rem;
}

.add-button:hover {
  text-decoration: underline;
}

.add-button-block {
  display: block;
  width: 100%;
  text-align: center;
  margin-top: 0.75rem;
  padding: 0.5rem;
  border: 1px dashed #cccccc;
  border-radius: 8px;
}

/* --- Inline forms --- */

.inline-form {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.inline-form-input {
  flex: 1;
  padding: 0.5rem 0.65rem;
  border: 1px solid #cccccc;
  border-radius: 8px;
  font-size: 0.95rem;
}

.inline-form-input:focus {
  outline: 2px solid #2f6fed;
  outline-offset: 1px;
}

.inline-form-submit {
  padding: 0.5rem 0.9rem;
  border: none;
  border-radius: 8px;
  background-color: #2f6fed;
  color: white;
  font-weight: 600;
  cursor: pointer;
}

.inline-form-submit:disabled {
  background-color: #b7c8f5;
  cursor: not-allowed;
}

.inline-form-cancel {
  padding: 0.5rem 0.75rem;
  border: 1px solid #dddddd;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  color: #555555;
}
```

### ✅ The Verification

Save every file. Go to `localhost:5173`.

1. Click **"+ New Task"** — an inline form should appear with a text input (already focused — you can start typing immediately without clicking into it), an "Add" button, and a "Cancel" button.
2. Notice the **"Add" button is visibly disabled** (lighter blue, unclickable) while the input is empty.
3. Type only spaces (e.g., hit the spacebar three times) — confirm "Add" stays disabled, proving the `.trim()` validation is working, not just a raw length check.
4. Type `"Write unit tests"` and press **Enter** (not clicking the button) — confirm a new task card appears instantly in the list, the form closes automatically, and the input is cleared (verify by reopening the form).
5. Click **"+ New Habit"** at the bottom of the habits card, add `"Journal before bed"`, and confirm it appears as a new, unchecked habit card with a `🔥 0` streak badge.
6. Click **"Cancel"** on either form without typing anything — confirm the form disappears and nothing was added.

---

## 📚 Reference Section: Phase 3, Part 1

### Controlled vs. uncontrolled inputs — when would you ever use uncontrolled?

We've championed controlled inputs throughout this part, but it's worth knowing **uncontrolled inputs** (where the DOM manages the value, and you only read it out when needed, typically via a `ref` — a tool we cover properly in Phase 7) still have legitimate, if narrower, uses:

* Extremely simple forms where you truly only need the value once, at submit time, and never need to validate, transform, or react to it as the user types.
* File inputs (`<input type="file">`) are effectively always uncontrolled — you cannot set their `value` programmatically for security reasons (a webpage isn't allowed to pre-fill what looks like a real file picker with a fake file path).
* Integrating with non-React code/libraries that expect to manage their own DOM state directly.

For this series, and for the vast majority of real-world React forms, controlled inputs are the right default — the benefits (live validation, conditional disabling, clearing, formatting) far outweigh the very slight extra code.

### Why not just use the array's length as the new item's id?

A tempting shortcut: `id: tasks.length + 1`. This breaks in a way that's easy to miss until it bites you: if you delete a task from the middle of the list (a feature we'll add soon), and then add a new one, `tasks.length + 1` can produce an id that **already exists** on a remaining item, causing duplicate-key bugs identical to the ones we deliberately triggered in Phase 2, Part 2. Always generate ids independently of the array's current size — `crypto.randomUUID()` (client-generated) or a real database's auto-incrementing primary key (server-generated, covered in Phase 4) are both safe because neither depends on how many items currently happen to exist.

### Form validation patterns worth knowing (beyond "is it empty")

Our forms only check "is the trimmed label non-empty." Real apps often layer on more:

```jsx
const trimmedLabel = label.trim()
const errors = []

if (trimmedLabel.length === 0) errors.push('This field is required.')
if (trimmedLabel.length > 100) errors.push('Please keep it under 100 characters.')

const isValid = errors.length === 0
```

Displaying `errors` conditionally (using the `&&` pattern from Phase 2, Part 3) directly under the input is the standard approach. We keep our validation minimal in this series to stay focused on core React concepts, but this pattern scales cleanly to as many rules as a real form needs.

### Common errors & fixes when building controlled forms

| Symptom | Likely cause | Fix |
|---|---|---|
| Console warning: `You provided a value prop to a form field without an onChange handler` | Set `value` on an input but forgot `onChange` | Add the `onChange` handler that updates the corresponding state |
| Typing in the input does nothing visually | `onChange` handler doesn't actually call the state setter, or calls it with the wrong value | Confirm `onChange={(event) => setLabel(event.target.value)}` exactly |
| Page reloads / URL changes weirdly when submitting | Forgot `event.preventDefault()` inside the submit handler | Add it as the very first line of the handler |
| New item appears then instantly seems to "vanish" or duplicate oddly | Using an unstable/non-unique id generation strategy | Use `crypto.randomUUID()` or another guaranteed-unique strategy |
| Submit button never becomes enabled even with real text typed | Validation checks the wrong variable (e.g., checks `label` state directly instead of the trimmed version, or a stale closure) | Confirm `isValid` is computed from `trimmedLabel`, recalculated fresh on every render |
| Pressing Enter doesn't submit the form | `onSubmit` was attached to the button instead of the `<form>` element | Move the handler to `<form onSubmit={...}>` |
