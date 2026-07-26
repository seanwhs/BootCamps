# Phase 7: Advanced Patterns
# Part 2: Custom Hooks — Extracting Reusable Logic

## Introduction: What we're doing in this part

Look across our codebase at three patterns we've now written **more than once**, nearly identically each time:

1. **`localStorage`-backed state** — `ThemeProvider` (Phase 5) and `AuthProvider` (Phase 6) each independently implement "read from `localStorage` on startup, write to `localStorage` whenever the value changes."
2. **A boolean "is this form open?" toggle** — `HabitsSection` and `TasksSection` each independently manage `isAdding` with near-identical `useState` and toggle logic.
3. **A global keyboard listener with cleanup** — so far only in `TasksSection`, but written in a way that's clearly generalizable.

Whenever you notice yourself copying the *shape* of some stateful logic between components, that's the signal to extract a **custom hook**. In this part, you will:

1. Understand precisely what a custom hook is — and, just as importantly, what it *isn't*.
2. Build `useLocalStorage`, and refactor both `ThemeProvider` and `AuthProvider` to use it, deleting duplicated logic from both.
3. Build `useToggle`, and refactor both section components to use it.
4. Build `useKeyboardShortcut`, generalizing the keyboard-handling logic from Phase 7, Part 1 into a reusable form.
5. Learn the critical rule that custom hooks share **logic**, never **state** — each call gets its own completely independent copy — via a hands-on demonstration.

---

## 🎯 The Target: Understanding what a custom hook actually is

### 🧠 The Concept: A custom hook is a recipe card for stateful logic, not a shared pot of soup

A **custom hook** is simply a JavaScript function that: (a) has a name starting with `use`, and (b) calls one or more other hooks inside it. That's the entire definition — there's no special syntax, no registration step, no new concept beyond composing hooks you already know into a reusable function.

The critical thing to understand is what gets shared when multiple components use the same custom hook: it's the **logic** (the recipe — "here's how to read from localStorage, here's how to write to it, here's how to sync them") — **never the state itself**. Every component that calls `useLocalStorage(...)` gets its own, completely independent `useState` under the hood, exactly as if each had hand-written that logic separately. Think of a custom hook like a recipe card for a soup: two different cooks (components) can both follow the exact same recipe card, but each ends up with their own separate pot of soup — not one shared pot that both are somehow stirring at once. We'll prove this explicitly with an experiment shortly.

---

## 🎯 The Target: Building `useLocalStorage`

### 🧠 The Concept: Extract the pattern you've now written twice, and let the two real usages guide the API

Looking back at `ThemeProvider` and `AuthProvider`, both do the same three things: (1) read an initial value from `localStorage`, falling back to a default if absent; (2) keep that value in `useState`; (3) write it back to `localStorage` in a `useEffect` whenever it changes. The only real differences are the storage key, the default value, and — for `AuthProvider` — the need to `JSON.parse`/`stringify` an object rather than a plain string. We'll design `useLocalStorage` to handle both cases uniformly, by always storing values as JSON (which works transparently for plain strings too).

### 🛠️ The Implementation

```bash
mkdir src/hooks
```

**File: `src/hooks/useLocalStorage.js`**

```javascript
import { useState, useEffect } from 'react'

// A general-purpose hook: behaves just like useState, but automatically
// persists its value to localStorage under `key`, and reads it back on
// startup. Every component/provider that calls this gets its OWN
// independent piece of state — nothing is shared between callers except
// the logic itself (see this part's Reference Section for a hands-on
// demonstration of exactly this).
export function useLocalStorage(key, defaultValue) {
  const [value, setValue] = useState(() => {
    // Lazy initializer (Phase 2, Part 1) — this read only ever happens
    // once, on the very first render, not on every re-render.
    try {
      const storedValue = localStorage.getItem(key)
      return storedValue !== null ? JSON.parse(storedValue) : defaultValue
    } catch (error) {
      // A real browser environment can throw here (corrupted JSON,
      // localStorage disabled entirely in some privacy modes) — falling
      // back to defaultValue keeps the app usable rather than crashing.
      console.warn(`useLocalStorage: failed to read key "${key}"`, error)
      return defaultValue
    }
  })

  useEffect(() => {
    try {
      localStorage.setItem(key, JSON.stringify(value))
    } catch (error) {
      console.warn(`useLocalStorage: failed to write key "${key}"`, error)
    }
  }, [key, value])

  // Returned in the exact same [value, setValue] shape as useState itself
  // — this is a deliberate design choice, so useLocalStorage is a drop-in
  // replacement anywhere a plain useState was previously used.
  return [value, setValue]
}
```

### 🛠️ The Implementation: Refactoring `ThemeProvider`

**File: `src/context/ThemeProvider.jsx`**

```jsx
import { useEffect } from 'react'
import { ThemeContext } from './ThemeContext.js'
import { useLocalStorage } from '../hooks/useLocalStorage.js'

const STORAGE_KEY = 'task-habit-tracker-theme'

function getSystemDefaultTheme() {
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  return prefersDark ? 'dark' : 'light'
}

function ThemeProvider({ children }) {
  // All the localStorage read/write logic that used to live directly in
  // this file is now handled entirely by useLocalStorage — this component
  // only needs to know ITS OWN concern: what key to use, and what the
  // theme-specific default should be.
  const [theme, setTheme] = useLocalStorage(STORAGE_KEY, getSystemDefaultTheme())

  // Applying the theme to the real DOM is specific to THIS provider's job
  // (useLocalStorage doesn't know or care about data-theme attributes),
  // so this effect stays here, separate from the persistence concern.
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
  }, [theme])

  function toggleTheme() {
    setTheme((currentTheme) => (currentTheme === 'light' ? 'dark' : 'light'))
  }

  const contextValue = { theme, toggleTheme }

  return <ThemeContext.Provider value={contextValue}>{children}</ThemeContext.Provider>
}

export default ThemeProvider
```

### 🛠️ The Implementation: Refactoring `AuthProvider`

**File: `src/context/AuthProvider.jsx`**

```jsx
import { AuthContext } from './AuthContext.js'
import { useLocalStorage } from '../hooks/useLocalStorage.js'

const STORAGE_KEY = 'task-habit-tracker-auth'

function AuthProvider({ children }) {
  // Notice: our old getInitialUser/JSON.parse/JSON.stringify/removeItem
  // dance is entirely gone. useLocalStorage handles all of it uniformly —
  // it works just as well for `null` (logged out) as it does for a real
  // user object (logged in).
  const [user, setUser] = useLocalStorage(STORAGE_KEY, null)

  function login(username) {
    setUser({ username })
  }

  function logout() {
    setUser(null)
  }

  const contextValue = { user, isAuthenticated: user !== null, login, logout }

  return <AuthContext.Provider value={contextValue}>{children}</AuthContext.Provider>
}

export default AuthProvider
```

### ✅ The Verification

Save all three files. Confirm both `npm run dev` and `npm run server` are running.

1. Go to **Settings**, toggle dark mode. Confirm it applies exactly as it did in Phase 5. Refresh the page — confirm dark mode persists.
2. Open DevTools → Application/Storage → Local Storage. Confirm `task-habit-tracker-theme` still exists with a plain value like `"dark"` (quoted, since we now always JSON-encode — this is a harmless, expected format change from before).
3. Log out if currently logged in, then log back in with any username. Confirm login/logout and redirect-to-`/login` behavior all work exactly as they did in Phase 6.
4. Confirm `task-habit-tracker-auth` in Local Storage now shows a JSON object like `{"username":"alex"}`.

This is the payoff of extraction done well: **zero visible behavior changed**, but two files each got meaningfully shorter and simpler, and any *future* piece of state we want to persist (there will be several more opportunities across the rest of this series) can now reuse this exact hook in one line.

---

## 🎯 The Target: Building `useToggle`

### 🧠 The Concept: The smallest possible custom hook, extracted from a pattern used twice

### 🛠️ The Implementation

**File: `src/hooks/useToggle.js`**

```javascript
import { useState, useCallback } from 'react'

// useCallback (new territory, briefly): it memoizes a FUNCTION itself
// across re-renders, so `toggle`, `setTrue`, and `setFalse` remain the
// exact same function reference every render, rather than being recreated
// fresh each time. This matters here specifically because these functions
// often end up in OTHER hooks' dependency arrays (e.g., a useEffect that
// depends on `setFalse`) — without useCallback, such an effect would
// think its dependency "changed" on every single render, and re-run
// needlessly. We cover useCallback more formally in Phase 9's performance
// material; for now, treat it as "useMemo, but for functions."
export function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue)

  const toggle = useCallback(() => setValue((current) => !current), [])
  const setTrue = useCallback(() => setValue(true), [])
  const setFalse = useCallback(() => setValue(false), [])

  return [value, { toggle, setTrue, setFalse }]
}
```

### 🛠️ The Implementation: Refactoring `TasksSection` and `HabitsSection`

**File: `src/components/TasksSection.jsx`**

```jsx
import { useState, useRef, useEffect } from 'react'
import TaskCard from './TaskCard.jsx'
import FilterTabs from './FilterTabs.jsx'
import TaskForm from './TaskForm.jsx'
import { useToggle } from '../hooks/useToggle.js'

const FILTER_OPTIONS = [
  { value: 'all', label: 'All' },
  { value: 'active', label: 'Active' },
  { value: 'completed', label: 'Completed' },
]

function TasksSection({ tasks, savingTaskIds, onToggleTask, onAddTask }) {
  const [filter, setFilter] = useState('all')
  // Replaces the old `const [isAdding, setIsAdding] = useState(false)` plus
  // every manual `setIsAdding(true)`/`setIsAdding(false)` call site below.
  const [isAdding, { setTrue: openAddForm, setFalse: closeAddForm }] = useToggle(false)
  const taskFormRef = useRef(null)

  const filteredTasks = tasks.filter((task) => {
    if (filter === 'active') return !task.isComplete
    if (filter === 'completed') return task.isComplete
    return true
  })

  const existingLabels = tasks.map((task) => task.label.toLowerCase())

  async function handleAddTask(label) {
    await onAddTask(label)
    closeAddForm()
  }

  useEffect(() => {
    if (isAdding) {
      taskFormRef.current?.focus()
    }
  }, [isAdding])

  useEffect(() => {
    function handleKeyDown(event) {
      const isTypingElsewhere =
        event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA'

      if (event.key === '/' && !isTypingElsewhere) {
        event.preventDefault()
        openAddForm()
      }

      if (event.key === 'Escape') {
        closeAddForm()
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [openAddForm, closeAddForm])

  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Tasks</h2>
        {!isAdding && (
          <button type="button" className="add-button" onClick={openAddForm}>
            + New Task <span className="shortcut-hint">/</span>
          </button>
        )}
      </div>

      {isAdding && (
        <TaskForm
          ref={taskFormRef}
          onAddTask={handleAddTask}
          onCancel={closeAddForm}
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

**File: `src/components/HabitsSection.jsx`**

```jsx
import HabitCard from './HabitCard.jsx'
import HabitForm from './HabitForm.jsx'
import { useToggle } from '../hooks/useToggle.js'

function HabitsSection({ habits, savingHabitIds, onToggleHabit, onAddHabit }) {
  const [isAdding, { setTrue: openAddForm, setFalse: closeAddForm }] = useToggle(false)
  const remainingCount = habits.filter((habit) => !habit.isComplete).length
  const existingLabels = habits.map((habit) => habit.label.toLowerCase())

  async function handleAddHabit(label) {
    await onAddHabit(label)
    closeAddForm()
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
          onCancel={closeAddForm}
          existingLabels={existingLabels}
        />
      )}

      <div className="card-list">
        {habits.map((habit) => (
          <HabitCard
            key={habit.id}
            id={habit.id}
            label={habit.label}
            streak={habit.streak}
            isComplete={habit.isComplete}
            isSaving={savingHabitIds.has(habit.id)}
            onToggle={() => onToggleHabit(habit.id)}
          />
        ))}
      </div>

      {!isAdding && (
        <button type="button" className="add-button add-button-block" onClick={openAddForm}>
          + New Habit
        </button>
      )}
    </section>
  )
}

export default HabitsSection
```

### ✅ The Verification

Save all files. Go to `localhost:5173/tasks` and `localhost:5173/habits`.

1. Click **"+ New Task"** — confirm the form opens exactly as before. Click **"Cancel"** — confirm it closes.
2. Press **`/`** — confirm the form opens and focuses, exactly as in Phase 7, Part 1. Press **`Escape`** — confirm it closes.
3. Repeat for **"+ New Habit"** on the Habits page — confirm open/close behavior is unchanged.
4. Everything should behave **identically** to before this refactor — confirming `useToggle` is a correct, behavior-preserving extraction.

---

## 🎯 The Target: Building `useKeyboardShortcut`

### 🧠 The Concept: Generalize "listen for a key, clean up on unmount" into a reusable, declarative hook

Our current keyboard-handling `useEffect` inside `TasksSection` mixes two concerns: the *generic* mechanics of attaching/detaching a `window` keydown listener, and the *specific* task-related logic of what `/` and `Escape` should do. Let's separate those, so the generic part becomes reusable for any future keyboard shortcut we might add anywhere else in the app.

### 🛠️ The Implementation

**File: `src/hooks/useKeyboardShortcut.js`**

```javascript
import { useEffect } from 'react'

// keyHandlers is an object like { '/': fn, 'Escape': fn2 } — this hook
// handles ALL the generic plumbing (attaching, cleaning up, ignoring
// keystrokes while the user is typing in a real input), so callers only
// need to describe WHICH keys they care about and WHAT should happen.
export function useKeyboardShortcut(keyHandlers) {
  useEffect(() => {
    function handleKeyDown(event) {
      const handler = keyHandlers[event.key]
      if (!handler) return

      const isTypingElsewhere =
        event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA'

      // Escape is deliberately allowed to fire even while typing (dismissing
      // a form while focused inside it is expected, universal behavior) —
      // every OTHER shortcut is suppressed while typing, so single-character
      // shortcuts like "/" don't hijack normal typing in any input, anywhere.
      if (isTypingElsewhere && event.key !== 'Escape') return

      if (event.key !== 'Escape') {
        event.preventDefault()
      }

      handler()
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [keyHandlers])
}
```

> ⚠️ A subtle, honest caveat, worth calling out rather than hiding: this effect's dependency array is `[keyHandlers]` — but if a caller passes a brand-new object literal (`{ '/': openAddForm }`) inline on every render, this effect will tear down and re-attach its listener on every single render, since a new object is `!==` the previous one every time, even with identical contents. This is harmless *functionally* here (the cleanup/re-attach is cheap), but it's exactly the kind of subtlety `useCallback`/`useMemo` (covered properly in Phase 9) exist to address in performance-sensitive cases. We call this out explicitly rather than papering over it, since pretending every hook is perfectly frictionless would do you a disservice as you write your own hooks later.

### 🛠️ The Implementation: Simplifying `TasksSection`'s keyboard logic

**File: `src/components/TasksSection.jsx`** *(only the keyboard-related portion changes)*

```jsx
import { useState, useRef, useEffect } from 'react'
import TaskCard from './TaskCard.jsx'
import FilterTabs from './FilterTabs.jsx'
import TaskForm from './TaskForm.jsx'
import { useToggle } from '../hooks/useToggle.js'
import { useKeyboardShortcut } from '../hooks/useKeyboardShortcut.js'

const FILTER_OPTIONS = [
  { value: 'all', label: 'All' },
  { value: 'active', label: 'Active' },
  { value: 'completed', label: 'Completed' },
]

function TasksSection({ tasks, savingTaskIds, onToggleTask, onAddTask }) {
  const [filter, setFilter] = useState('all')
  const [isAdding, { setTrue: openAddForm, setFalse: closeAddForm }] = useToggle(false)
  const taskFormRef = useRef(null)

  const filteredTasks = tasks.filter((task) => {
    if (filter === 'active') return !task.isComplete
    if (filter === 'completed') return task.isComplete
    return true
  })

  const existingLabels = tasks.map((task) => task.label.toLowerCase())

  async function handleAddTask(label) {
    await onAddTask(label)
    closeAddForm()
  }

  useEffect(() => {
    if (isAdding) {
      taskFormRef.current?.focus()
    }
  }, [isAdding])

  // The generic "attach/detach a window keydown listener" plumbing is now
  // entirely someone else's problem (useKeyboardShortcut's). This component
  // only states its OWN specific intent: what "/" and "Escape" should do.
  useKeyboardShortcut({ '/': openAddForm, Escape: closeAddForm })

  return (
    <section className="dashboard-section">
      <div className="section-header">
        <h2>Tasks</h2>
        {!isAdding && (
          <button type="button" className="add-button" onClick={openAddForm}>
            + New Task <span className="shortcut-hint">/</span>
          </button>
        )}
      </div>

      {isAdding && (
        <TaskForm
          ref={taskFormRef}
          onAddTask={handleAddTask}
          onCancel={closeAddForm}
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

### ✅ The Verification

Save every file. Repeat the exact keyboard-shortcut verification from Phase 7, Part 1: `/` opens and focuses the form, `Escape` closes it, navigating away and back cleans up correctly (no lingering listener), and typing `/` while genuinely focused in an input types the character normally rather than triggering the shortcut.

---

## 🎯 The Target: Proving custom hooks don't share state between callers

### 🧠 The Concept: Two components calling the same custom hook are like two students following the same recipe — with two separate pots

### 🛠️ The Implementation: A temporary, disposable experiment

**File: `src/HookIsolationExperiment.jsx`** *(temporary — we delete this at the end)*

```jsx
import { useToggle } from './hooks/useToggle.js'

function Switch({ label }) {
  // Each <Switch> instance calls useToggle independently. If custom hooks
  // somehow shared state across callers, clicking one switch would also
  // flip the other — let's actually check.
  const [isOn, { toggle }] = useToggle(false)

  return (
    <button onClick={toggle} style={{ display: 'block', margin: '0.5rem 0' }}>
      {label}: {isOn ? 'ON' : 'OFF'}
    </button>
  )
}

function HookIsolationExperiment() {
  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <Switch label="Switch A" />
      <Switch label="Switch B" />
    </div>
  )
}

export default HookIsolationExperiment
```

Temporarily point `main.jsx` at this experiment (following the same pattern as every prior experiment in this series):

**File: `src/main.jsx`** *(temporary edit)*

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import './index.css'
// import App from './App.jsx'
import HookIsolationExperiment from './HookIsolationExperiment.jsx'
import ThemeProvider from './context/ThemeProvider.jsx'
import AuthProvider from './context/AuthProvider.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <ThemeProvider>
        <AuthProvider>
          <HookIsolationExperiment />
        </AuthProvider>
      </ThemeProvider>
    </BrowserRouter>
  </StrictMode>,
)
```

### ✅ The Verification

Save both files, open `localhost:5173`.

1. Click **"Switch A."** Confirm only Switch A flips to `ON` — Switch B remains `OFF`.
2. Click **"Switch B."** Confirm only Switch B flips — Switch A's state is untouched.

This confirms, concretely: even though both `<Switch>` instances call the **exact same** `useToggle` function, each one received its own entirely independent `useState` under the hood. The hook is a shared *recipe*; the resulting state is never a shared *pot*.

### 🛠️ Cleanup

```bash
rm src/HookIsolationExperiment.jsx
```

**File: `src/main.jsx`** *(restored)*

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import './index.css'
import App from './App.jsx'
import ThemeProvider from './context/ThemeProvider.jsx'
import AuthProvider from './context/AuthProvider.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <ThemeProvider>
        <AuthProvider>
          <App />
        </AuthProvider>
      </ThemeProvider>
    </BrowserRouter>
  </StrictMode>,
)
```

### ✅ The Verification

Save. Confirm `localhost:5173` shows our real Task & Habit Tracker again, fully functional.

---

## 📚 Reference Section: Phase 7, Part 2

### The rules for writing a custom hook

1. **Name it starting with `use`.** This isn't just convention — React's linter (`eslint-plugin-react-hooks`, included in our project since Phase 1) specifically uses this naming pattern to know which functions to apply the Rules of Hooks checks to. A function that calls hooks internally but *doesn't* start with `use` will not be checked correctly, and may hide real bugs.
2. **Follow the Rules of Hooks internally**, exactly as any component would (Phase 2, Part 1): hooks called unconditionally, at the top level, in the same order every time.
3. **Return whatever shape makes sense for your use case** — an array (mimicking `useState`'s `[value, setValue]` convention, as we did for both `useLocalStorage` and `useToggle`), or an object (often clearer once you're returning three or more things, since callers can destructure by name rather than remembering position).
4. **A custom hook shares logic, not state.** Internalize this from the experiment above — every call site gets its own independent state, refs, and effects.

### When should you extract a custom hook? A practical checklist

* You've now written the **same stateful pattern** (not just similar-looking JSX, but genuinely similar `useState`/`useEffect` logic) in two or more places.
* A single component's logic section has grown long enough that a *self-contained sub-problem* (like "sync this value to localStorage," or "listen for this keyboard shortcut") could be described, tested, and understood entirely on its own, separate from the rest of the component's concerns.
* You want to make a piece of logic **independently testable** — a well-extracted custom hook can often be tested in isolation far more easily than testing it indirectly through a full component (a technique we'll use directly in Phase 8's testing material).

Avoid extracting a custom hook purely to reduce line count with no real shared logic or independent concern behind it — an over-eager extraction that's only ever called from one place, with no clear separate responsibility, usually just adds a layer of indirection without a real benefit.

### `useCallback` — a focused preview

We used `useCallback` inside `useToggle` without fully unpacking it, since a complete treatment belongs in Phase 9's performance material. For now, the essential mental model: `useState`/`useMemo` (a hook we haven't formally met yet, also arriving in Phase 9) let you preserve a **value** across renders unless its dependencies change; `useCallback` does the same thing specifically for a **function**. Without it, `function toggle() { ... }` would be a genuinely brand-new function object on every single render — usually harmless, but occasionally a real problem when that function is used as a dependency in another hook's dependency array (as `openAddForm`/`closeAddForm` are, inside `useKeyboardShortcut`'s effect) or passed to a heavily-optimized child component (Phase 9 territory).

### Common errors & fixes when writing custom hooks

| Symptom | Likely cache | Fix |
|---|---|---|
| ESLint doesn't warn about a broken Rules-of-Hooks violation inside your new function | Function name doesn't start with `use` | Rename it so the linter recognizes it as a hook |
| Two components using the same custom hook seem to affect each other | This should never actually happen with correctly-written hooks — if observed, the state is likely being stored somewhere shared outside the hook (e.g., a module-level variable instead of `useState`) | Move any shared mutable value into `useState`/`useRef` *inside* the hook function itself |
| `useLocalStorage`-backed value briefly flashes the wrong value on page load | The lazy initializer isn't actually reading from `localStorage` correctly, or `JSON.parse` is failing silently | Confirm the `try/catch` and `JSON.parse`/`JSON.stringify` pairing matches exactly, and check the console for a logged warning |
| A `useEffect` depending on a function returned from a custom hook re-runs on every render, even though "nothing changed" | The function wasn't wrapped in `useCallback` inside the hook, so a new reference is created every render | Wrap the returned function(s) in `useCallback` with an appropriate (often empty) dependency array |
| Custom hook throws `Invalid hook call` | It was called from a plain JavaScript function (not a component or another hook), or from inside a conditional/loop | Confirm it's called unconditionally, at the top level, from within a real component or another custom hook |
