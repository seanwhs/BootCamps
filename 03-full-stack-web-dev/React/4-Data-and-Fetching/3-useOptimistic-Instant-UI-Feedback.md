# Phase 4: Data Fetching
# Part 3: 🆕 `useOptimistic` — Instant UI Feedback

## Introduction: What we're doing in this part

Right now, toggling a habit or task only updates our **local** React state — it never actually reaches the server. Refresh the page, and every checkbox silently resets to whatever `db.json` originally said. That's the first problem we fix in this part: real persistence, via `PATCH` requests to our `json-server` backend.

But persisting to a server introduces a new UX problem: a real network request takes time — even 200–700ms feels sluggish if the user has to *wait* to see their checkbox flip. In this part, you will:

1. Add real `PATCH` (update) and `POST` (create) endpoints to our API layer, so toggling and adding genuinely persist.
2. Learn what "optimistic UI" means, and understand `useOptimistic` — a hook that shows the *hoped-for* result instantly, before the server confirms it.
3. Learn `startTransition`, and exactly why `useOptimistic` requires it.
4. Add a subtle "saving" indicator and a toast notification, so failures are visible and understandable rather than silently confusing.
5. Run a deliberate experiment showing what happens if you forget to wrap an optimistic update in a transition.

> 🆕 **New in React 19:** `useOptimistic` is a brand-new hook. Before React 19, achieving this "show the hoped-for result now, roll back automatically if it fails" pattern required manually managing a separate piece of state, tracking in-flight requests yourself, and writing your own rollback logic in every `catch` block — easy to get subtly wrong. `useOptimistic` formalizes this into one purpose-built tool.

---

## 🎯 The Target: Understanding optimistic UI

### 🧠 The Concept: Assume success, and prepare to gracefully admit you were wrong

Think about tapping "like" on a social media post. The heart icon fills in **instantly** — the app doesn't make you wait a second or two staring at a spinner while it confirms with the server that your like was recorded. It assumes the request will succeed (because, statistically, it almost always does), shows you the result immediately, and only in the rare case of a failure does it quietly revert the heart and perhaps show a small error. This is **optimistic UI**: showing the *anticipated* outcome of an action before you have confirmation, trading a small risk of a brief visual "correction" for a UI that feels instant.

`useOptimistic` formalizes exactly this pattern:

```jsx
const [optimisticValue, addOptimistic] = useOptimistic(realValue, updateFn)
```

* **`realValue`** — your actual, server-confirmed state (what we've been calling `habits`/`tasks`).
* **`updateFn(currentValue, optimisticUpdate)`** — describes how to merge an optimistic update into the current value, returning what should be displayed *right now*.
* **`optimisticValue`** — what your JSX should actually render. It reflects `realValue`, plus any optimistic update currently "in flight."
* **`addOptimistic(update)`** — call this to apply an optimistic update. Critically, this can **only** be called from inside a **transition** (either a form Action, or code wrapped in `startTransition`) — we'll see exactly why, and what happens if you don't, later in this part.

The rollback happens *automatically*, almost like magic the first time you see it: `optimisticValue` is *derived fresh* from `realValue` on every render. The instant the transition finishes (success or failure) and no optimistic update is pending anymore, `optimisticValue` simply reflects `realValue` again. If the real update never actually happened (because it failed), `realValue` was never changed in the first place — so the optimistic value quietly reverts to match it, with no manual "undo" code required.

---

## 🎯 The Target: Adding real update & create endpoints to our API layer

### 🧠 The Concept: `PATCH` for partial updates, `POST` for new resources

We've only used `GET` requests so far (reading data). Persisting a toggle requires **`PATCH`** — an HTTP method meaning "update part of an existing resource" (as opposed to `PUT`, which conventionally means "replace the entire resource"). Creating a new task/habit requires **`POST`** — "create a new resource here." Both require a `body` (the data we're sending) and a header telling the server what format that body is in (`Content-Type: application/json`).

### 🛠️ The Implementation

**File: `src/api/habitsApi.js`**

```javascript
import { API_BASE_URL } from './config.js'

export async function fetchHabits() {
  const response = await fetch(`${API_BASE_URL}/habits`)
  if (!response.ok) {
    throw new Error(`Failed to fetch habits (status ${response.status})`)
  }
  return response.json()
}

// FOR TEACHING PURPOSES ONLY: this constant controls how often updateHabit
// randomly fails, so you can reliably witness useOptimistic's automatic
// rollback behavior without needing to manually break anything yourself.
const ARTIFICIAL_FAILURE_RATE = 0.3

export async function updateHabit(habitId, updates) {
  // A short artificial delay so the optimistic UI is visibly "ahead of"
  // the real, confirmed state for a moment — exactly like a genuine
  // network round-trip would cause.
  await new Promise((resolve) => setTimeout(resolve, 700))

  if (Math.random() < ARTIFICIAL_FAILURE_RATE) {
    throw new Error('Simulated failure: the server rejected this update.')
  }

  // PATCH sends only the fields we want changed, not the whole object —
  // json-server (and most real APIs) merge this into the existing record,
  // leaving every other field untouched.
  const response = await fetch(`${API_BASE_URL}/habits/${habitId}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updates),
  })

  if (!response.ok) {
    throw new Error(`Failed to update habit (status ${response.status})`)
  }

  return response.json()
}

export async function createHabit(newHabit) {
  await new Promise((resolve) => setTimeout(resolve, 400))

  const response = await fetch(`${API_BASE_URL}/habits`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(newHabit),
  })

  if (!response.ok) {
    throw new Error(`Failed to create habit (status ${response.status})`)
  }

  // json-server assigns a real, permanent id and returns the full saved
  // record — this is what lets us retire crypto.randomUUID() entirely;
  // the SERVER is now the single source of truth for ids.
  return response.json()
}
```

**File: `src/api/tasksApi.js`**

```javascript
import { API_BASE_URL } from './config.js'

export async function fetchTasks() {
  const response = await fetch(`${API_BASE_URL}/tasks`)
  if (!response.ok) {
    throw new Error(`Failed to fetch tasks (status ${response.status})`)
  }
  return response.json()
}

const ARTIFICIAL_FAILURE_RATE = 0.3

export async function updateTask(taskId, updates) {
  await new Promise((resolve) => setTimeout(resolve, 700))

  if (Math.random() < ARTIFICIAL_FAILURE_RATE) {
    throw new Error('Simulated failure: the server rejected this update.')
  }

  const response = await fetch(`${API_BASE_URL}/tasks/${taskId}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updates),
  })

  if (!response.ok) {
    throw new Error(`Failed to update task (status ${response.status})`)
  }

  return response.json()
}

export async function createTask(newTask) {
  await new Promise((resolve) => setTimeout(resolve, 400))

  const response = await fetch(`${API_BASE_URL}/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(newTask),
  })

  if (!response.ok) {
    throw new Error(`Failed to create task (status ${response.status})`)
  }

  return response.json()
}
```

### ✅ The Verification

We'll verify these once they're wired into the UI in the next step — for now, confirm both files save with no errors.

---

## 🎯 The Target: Wiring `useOptimistic` + `startTransition` into `App.jsx`

### 🧠 The Concept: `startTransition` marks a block of code as "this can happen in the background, not urgently"

`useOptimistic`'s update function is only allowed to run inside a **transition** — code wrapped in React's `startTransition`, or the internals of a form Action (which is automatically a transition). A transition tells React: "the state changes inside this block are allowed to be applied, tracked, and — if needed — automatically cleaned up as a cohesive unit, rather than as an isolated, disconnected update." This is precisely the bookkeeping `useOptimistic` relies on to know when its "in flight" optimistic value should stop being displayed and defer back to the real value.

### 🛠️ The Implementation

**File: `src/App.jsx`**

```jsx
import { useState, useEffect, useOptimistic, startTransition } from 'react'
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'
import Toast from './components/Toast.jsx'
import { fetchHabits, updateHabit, createHabit } from './api/habitsApi.js'
import { fetchTasks, updateTask, createTask } from './api/tasksApi.js'

function App() {
  const [habits, setHabits] = useState([])
  const [tasks, setTasks] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [loadError, setLoadError] = useState(null)
  const [retryCount, setRetryCount] = useState(0)
  const [toastMessage, setToastMessage] = useState(null)

  // Tracks which specific habit/task ids currently have a save in flight —
  // purely for a subtle "syncing" visual, separate from the optimistic
  // VALUE itself, which useOptimistic manages below.
  const [savingHabitIds, setSavingHabitIds] = useState(() => new Set())
  const [savingTaskIds, setSavingTaskIds] = useState(() => new Set())

  // optimisticHabits is DERIVED from `habits` (the real, server-confirmed
  // state) plus whatever optimistic update is currently in flight. Once a
  // transition finishes, this automatically reflects `habits` again.
  const [optimisticHabits, applyOptimisticHabit] = useOptimistic(
    habits,
    (currentHabits, updatedHabit) =>
      currentHabits.map((habit) => (habit.id === updatedHabit.id ? updatedHabit : habit))
  )

  const [optimisticTasks, applyOptimisticTask] = useOptimistic(
    tasks,
    (currentTasks, updatedTask) =>
      currentTasks.map((task) => (task.id === updatedTask.id ? updatedTask : task))
  )

  useEffect(() => {
    let isCancelled = false

    async function loadData() {
      setIsLoading(true)
      setLoadError(null)

      try {
        const [habitsData, tasksData] = await Promise.all([fetchHabits(), fetchTasks()])
        if (!isCancelled) {
          setHabits(habitsData)
          setTasks(tasksData)
        }
      } catch (error) {
        if (!isCancelled) setLoadError(error)
      } finally {
        if (!isCancelled) setIsLoading(false)
      }
    }

    loadData()
    return () => {
      isCancelled = true
    }
  }, [retryCount])

  function handleRetry() {
    setRetryCount((current) => current + 1)
  }

  function showToast(message) {
    setToastMessage(message)
    setTimeout(() => setToastMessage(null), 3000)
  }

  function handleToggleHabit(habitId) {
    const targetHabit = habits.find((habit) => habit.id === habitId)
    if (!targetHabit) return

    const optimisticHabit = { ...targetHabit, isComplete: !targetHabit.isComplete }

    setSavingHabitIds((current) => new Set(current).add(habitId))

    // startTransition marks everything inside as a transition, which is
    // what makes it valid to call applyOptimisticHabit here — without it,
    // React has no defined way to know when to stop showing this optimistic
    // value and defer back to the real one.
    startTransition(async () => {
      applyOptimisticHabit(optimisticHabit)

      try {
        const savedHabit = await updateHabit(habitId, { isComplete: optimisticHabit.isComplete })
        setHabits((currentHabits) =>
          currentHabits.map((habit) => (habit.id === habitId ? savedHabit : habit))
        )
      } catch (error) {
        // We deliberately do NOT touch `habits` here. Since optimisticHabits
        // is derived from `habits`, leaving it untouched means the optimistic
        // value automatically disappears once this transition ends — the
        // checkbox visibly "snaps back" to its last confirmed state.
        showToast(`Couldn't save "${targetHabit.label}" — please try again.`)
      } finally {
        setSavingHabitIds((current) => {
          const next = new Set(current)
          next.delete(habitId)
          return next
        })
      }
    })
  }

  function handleToggleTask(taskId) {
    const targetTask = tasks.find((task) => task.id === taskId)
    if (!targetTask) return

    const optimisticTask = { ...targetTask, isComplete: !targetTask.isComplete }

    setSavingTaskIds((current) => new Set(current).add(taskId))

    startTransition(async () => {
      applyOptimisticTask(optimisticTask)

      try {
        const savedTask = await updateTask(taskId, { isComplete: optimisticTask.isComplete })
        setTasks((currentTasks) =>
          currentTasks.map((task) => (task.id === taskId ? savedTask : task))
        )
      } catch (error) {
        showToast(`Couldn't save "${targetTask.label}" — please try again.`)
      } finally {
        setSavingTaskIds((current) => {
          const next = new Set(current)
          next.delete(taskId)
          return next
        })
      }
    })
  }

  // These now perform REAL network requests. They're awaited by the forms
  // that call them (TaskForm/HabitForm), so submission errors surface as
  // real, visible form errors instead of failing silently.
  async function handleAddTask(label) {
    const savedTask = await createTask({ label, isComplete: false })
    setTasks((currentTasks) => [...currentTasks, savedTask])
  }

  async function handleAddHabit(label) {
    const savedHabit = await createHabit({ label, streak: 0, isComplete: false })
    setHabits((currentHabits) => [...currentHabits, savedHabit])
  }

  if (isLoading) {
    return (
      <div className="app">
        <Navbar />
        <p className="loading-message">Loading your tasks and habits…</p>
      </div>
    )
  }

  if (loadError) {
    return (
      <div className="app">
        <Navbar />
        <div className="error-state">
          <p>😕 We couldn't load your data.</p>
          <p className="error-detail">{loadError.message}</p>
          <button type="button" className="retry-button" onClick={handleRetry}>
            Try Again
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="app">
      <Navbar />
      <Dashboard
        habits={optimisticHabits}
        tasks={optimisticTasks}
        savingHabitIds={savingHabitIds}
        savingTaskIds={savingTaskIds}
        onToggleHabit={handleToggleHabit}
        onToggleTask={handleToggleTask}
        onAddHabit={handleAddHabit}
        onAddTask={handleAddTask}
      />
      <Toast message={toastMessage} />
    </div>
  )
}

export default App
```

Notice we pass `optimisticHabits`/`optimisticTasks` down to `Dashboard` — **not** `habits`/`tasks` directly. Every component below `App` renders whatever it's told, with no idea whether what it's displaying is "real, confirmed" data or "optimistic, still-in-flight" data. That distinction is fully contained at the `App` level, exactly where the data-fetching logic already lives.

### 🛠️ The Implementation: Forwarding `savingHabitIds`/`savingTaskIds` and updating create handlers

**File: `src/components/Dashboard.jsx`**

```jsx
import { Suspense, useState } from 'react'
import HabitsSection from './HabitsSection.jsx'
import TasksSection from './TasksSection.jsx'
import QuoteOfTheDay from './QuoteOfTheDay.jsx'
import ErrorBoundary from './ErrorBoundary.jsx'
import { getQuotePromise, resetQuotePromise } from '../api/quoteCache.js'

function Dashboard({
  habits,
  tasks,
  savingHabitIds,
  savingTaskIds,
  onToggleHabit,
  onToggleTask,
  onAddHabit,
  onAddTask,
}) {
  const [quotePromise, setQuotePromise] = useState(getQuotePromise)

  function handleQuoteRetry() {
    setQuotePromise(resetQuotePromise())
  }

  return (
    <main className="dashboard">
      <ErrorBoundary onRetry={handleQuoteRetry}>
        <Suspense
          fallback={
            <section className="dashboard-section quote-section quote-section-loading">
              <p>Fetching today's quote…</p>
            </section>
          }
        >
          <QuoteOfTheDay quotePromise={quotePromise} />
        </Suspense>
      </ErrorBoundary>

      <HabitsSection
        habits={habits}
        savingHabitIds={savingHabitIds}
        onToggleHabit={onToggleHabit}
        onAddHabit={onAddHabit}
      />
      <TasksSection
        tasks={tasks}
        savingTaskIds={savingTaskIds}
        onToggleTask={onToggleTask}
        onAddTask={onAddTask}
      />
    </main>
  )
}

export default Dashboard
```

**File: `src/components/HabitsSection.jsx`**

```jsx
import { useState } from 'react'
import HabitCard from './HabitCard.jsx'
import HabitForm from './HabitForm.jsx'

function HabitsSection({ habits, savingHabitIds, onToggleHabit, onAddHabit }) {
  const [isAdding, setIsAdding] = useState(false)
  const remainingCount = habits.filter((habit) => !habit.isComplete).length
  const existingLabels = habits.map((habit) => habit.label.toLowerCase())

  // Now async: only closes the form once the real save (awaited inside
  // HabitForm's Action) has genuinely succeeded.
  async function handleAddHabit(label) {
    await onAddHabit(label)
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
            isSaving={savingHabitIds.has(habit.id)}
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

function TasksSection({ tasks, savingTaskIds, onToggleTask, onAddTask }) {
  const [filter, setFilter] = useState('all')
  const [isAdding, setIsAdding] = useState(false)

  const filteredTasks = tasks.filter((task) => {
    if (filter === 'active') return !task.isComplete
    if (filter === 'completed') return task.isComplete
    return true
  })

  const existingLabels = tasks.map((task) => task.label.toLowerCase())

  async function handleAddTask(label) {
    await onAddTask(label)
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
              isSaving={savingTaskIds.has(task.id)}
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

**File: `src/components/HabitCard.jsx`**

```jsx
import Badge from './Badge.jsx'

function HabitCard({ label, streak = 0, isComplete = false, isSaving = false, onToggle }) {
  function handleStreakClick(event) {
    event.stopPropagation()
    window.alert(`🔥 ${streak}-day streak! Keep it up.`)
  }

  return (
    <div
      className={`card habit-card ${isSaving ? 'is-saving' : ''}`}
      onClick={onToggle}
    >
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      {streak > 7 && <span className="fire-indicator">On fire!</span>}
      <Badge tone="streak" onClick={handleStreakClick}>
        🔥 {streak}
      </Badge>
    </div>
  )
}

export default HabitCard
```

**File: `src/components/TaskCard.jsx`**

```jsx
function TaskCard({ label, isComplete = false, isSaving = false, onToggle }) {
  return (
    <div className={`card task-card ${isSaving ? 'is-saving' : ''}`} onClick={onToggle}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
    </div>
  )
}

export default TaskCard
```

**File: `src/components/Toast.jsx`**

```jsx
// Toast renders nothing at all when there's no message — a clean early
// return, since this component's entire job is inherently conditional.
function Toast({ message }) {
  if (!message) return null

  return (
    <div className="toast" role="status">
      {message}
    </div>
  )
}

export default Toast
```

### 🛠️ Updating `TaskForm` and `HabitForm` to await real saves

Since `onAddTask`/`onAddHabit` now perform genuine network requests and can genuinely fail, our forms should await them and surface real errors — plus we can remove the old artificial `setTimeout`, since the real network request now provides authentic latency for `useFormStatus`'s pending state to reflect.

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

    try {
      // onAddTask now performs a REAL network request (via App -> createTask)
      // and only resolves once the server has genuinely confirmed the save.
      await onAddTask(label)
      return { error: null }
    } catch (error) {
      return { error: 'Something went wrong saving this task. Please try again.' }
    }
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

    try {
      await onAddHabit(label)
      return { error: null }
    } catch (error) {
      return { error: 'Something went wrong saving this habit. Please try again.' }
    }
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

Add CSS for the saving indicator and toast:

**File: `src/index.css`** *(append this block)*

```css
/* --- Optimistic "saving" indicator --- */

.is-saving {
  opacity: 0.55;
  /* Prevents a second click from firing a duplicate save while one is
     already in flight for this exact card. */
  pointer-events: none;
}

/* --- Toast notifications --- */

.toast {
  position: fixed;
  bottom: 1.5rem;
  left: 50%;
  transform: translateX(-50%);
  background-color: #1a1a1a;
  color: white;
  padding: 0.65rem 1.1rem;
  border-radius: 8px;
  font-size: 0.9rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  z-index: 100;
}
```

### ✅ The Verification

Save every file. Confirm both `npm run dev` and `npm run server` are running. Refresh `localhost:5173`.

1. Click a habit or task checkbox. Confirm it **flips instantly** — no waiting — and the card briefly dims (our `.is-saving` opacity) for about 700ms.
2. After that ~700ms, one of two things happens (our artificial 30% failure rate):
   * **Success (~70% of the time):** the card returns to full opacity, the checkbox state stays exactly as you set it. Refresh the entire page — confirm the change genuinely persisted (it's now really saved in `db.json` via `json-server`).
   * **Failure (~30% of the time):** the card returns to full opacity, but the checkbox **visibly snaps back** to its previous state, and a black toast notification appears at the bottom of the screen reading something like *"Couldn't save 'Drink 8 glasses of water' — please try again."* — disappearing after 3 seconds.
3. Click the same checkbox rapidly 5–6 times in a row to trigger several toggles. Because of `.is-saving`'s `pointer-events: none`, confirm you cannot fire a second toggle on a card while its previous one is still resolving — clicks are simply ignored until the dim/disabled state clears.
4. Add a new task via **"+ New Task."** Confirm the "Adding…" pending state (from `useFormStatus`, Phase 3) appears for a real ~400ms this time — genuine network latency now, not an artificial delay — and the new task appears with a real, server-assigned numeric `id` once saved. Refresh the page and confirm it's still there.

---

## 🎯 The Target: Seeing what happens without `startTransition`

### 🧠 The Concept: `useOptimistic` needs a transition to know when its work is "done"

Let's deliberately break this, briefly, to see the actual guardrail React provides.

### 🛠️ The Implementation: A temporary, broken version

In `src/App.jsx`, temporarily change `handleToggleHabit` to call `applyOptimisticHabit` **without** wrapping the rest of the logic in `startTransition`:

```jsx
// ❌ TEMPORARY, BROKEN VERSION — for the experiment only
function handleToggleHabit(habitId) {
  const targetHabit = habits.find((habit) => habit.id === habitId)
  if (!targetHabit) return

  const optimisticHabit = { ...targetHabit, isComplete: !targetHabit.isComplete }

  applyOptimisticHabit(optimisticHabit) // called directly — no startTransition wrapping it

  updateHabit(habitId, { isComplete: optimisticHabit.isComplete })
    .then((savedHabit) => {
      setHabits((currentHabits) =>
        currentHabits.map((habit) => (habit.id === habitId ? savedHabit : habit))
      )
    })
    .catch(() => {
      showToast(`Couldn't save "${targetHabit.label}" — please try again.`)
    })
}
```

### ✅ The Verification

Save the file, open your browser DevTools Console, and click any habit checkbox.

**Expected result:** Look at your console. You should see a warning/error similar to:

```
An optimistic state update occurred outside a transition or action. To fix,
move the update to an action, or wrap with startTransition.
```

This is React directly confirming the rule we described: `useOptimistic`'s update function must run inside a transition, because that's the exact mechanism React uses to know when the optimistic value's "in-flight" period has ended.

### 🛠️ Cleanup: Restore the correct, working version

Revert `handleToggleHabit` in `src/App.jsx` back to the `startTransition`-wrapped version from the main implementation above.

### ✅ The Verification

Save. Toggle a habit again — confirm the console warning is gone, and toggling behaves exactly as it did during our earlier, full verification pass.

---

## 📚 Reference Section: Phase 4, Part 3

### `useOptimistic` — full API reference

```javascript
const [optimisticState, addOptimistic] = useOptimistic(state, updateFn)
```

* **`state`** — the real, authoritative value (in our case, `habits`/`tasks` as confirmed by the server).
* **`updateFn(currentState, optimisticValue)`** — called with the *current* optimistic state and whatever you passed to `addOptimistic(...)`; must return the new value to display immediately.
* **`optimisticState`** — what you should render in your JSX. Equals `state` whenever nothing is in flight; reflects the merged optimistic result while something is.
* **`addOptimistic(value)`** — triggers an optimistic update. **Must** be called from within a transition (`startTransition(...)`, or inside a form Action, which is automatically a transition).

### `startTransition` — what a "transition" actually means

`startTransition(callback)` tells React: "the state updates that happen inside this callback are not urgent — they can be interrupted, and the UI can show a hoped-for/pending state around them." It was originally introduced (in React 18) for marking expensive UI updates as lower-priority than things like typing responsiveness. `useOptimistic` builds directly on top of this same transition machinery, using it to know precisely when to stop displaying an optimistic value and defer back to real state — the boundary of the transition **is** the boundary of "how long the optimistic value is allowed to live."

### Why not just update `habits` state immediately, then roll it back manually in the `catch`?

You technically could — this is exactly what developers did before `useOptimistic` existed:

```jsx
// The "old way" — manually done, without useOptimistic
function handleToggleHabit(habitId) {
  const previousHabits = habits // manually remember the old state for rollback
  setHabits((current) =>
    current.map((h) => (h.id === habitId ? { ...h, isComplete: !h.isComplete } : h))
  )

  updateHabit(habitId, { isComplete: /* ... */ }).catch(() => {
    setHabits(previousHabits) // manually roll back on failure
    showToast('Failed to save.')
  })
}
```

This works, but has a subtle flaw `useOptimistic` avoids: if the user triggers *multiple* overlapping optimistic updates in quick succession (toggling two different habits before the first request finishes), naively storing "the previous state" as a single snapshot can produce incorrect rollbacks — the "previous state" you captured might already be stale by the time a failure occurs. `useOptimistic` handles this correctly by design, since each optimistic value is properly derived and tracked relative to the true source of truth, not a manually-captured snapshot.

### Common errors & fixes when working with `useOptimistic`

| Symptom | Likely cause | Fix |
|---|---|---|
| Console warning: `An optimistic state update occurred outside a transition or action` | `addOptimistic`/`applyOptimisticX` was called outside `startTransition` or a form Action | Wrap the entire async operation in `startTransition(async () => { ... })` |
| Optimistic value never reverts after a failure | The real `setHabits`/`setTasks` call was accidentally still made even on failure (e.g., outside the `catch`, or in a `finally` that unconditionally applies it) | Ensure the real state setter is only called on the success path |
| UI flickers oddly between optimistic and real values | Rendering `habits`/`tasks` (the real state) somewhere instead of consistently using `optimisticHabits`/`optimisticTasks` | Audit every component for which prop it renders; always use the optimistic version at the top of the tree |
| Toast never disappears | Multiple toasts triggered in quick succession, each with their own `setTimeout`, stepping on each other | For production use, consider a small toast queue/id system; acceptable for our single-toast use case here |
| Clicking a card twice in a row causes duplicate/conflicting requests | `.is-saving`'s `pointer-events: none` wasn't applied correctly, or `isSaving` prop wasn't wired through | Confirm `savingHabitIds`/`savingTaskIds` are correctly passed all the way down to the card component |
