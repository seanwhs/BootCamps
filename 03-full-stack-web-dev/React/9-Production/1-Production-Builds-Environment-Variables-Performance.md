# Phase 9: Production
# Part 1: Production Builds, Environment Variables, and Performance

## Introduction: What we're doing in this part

Every command we've run so far (`npm run dev`) starts a **development server** — optimized for fast feedback (instant Hot Module Replacement, unminified code with readable stack traces), not for actual users. Before this app can go live on the internet, it needs to be transformed into a **production build**: a small, fast, minified bundle of static files that any web server can serve.

In this part, you will:

1. Understand exactly what a production build is, and run one for the first time.
2. Learn `npm run preview`, and use it to verify the production build works correctly, locally, before ever deploying it.
3. Formalize how environment variables should differ between development and production, and prepare our app to point at a real, deployed backend.
4. Learn and apply React's three core performance-optimization tools — `React.memo`, `useMemo`, and `useCallback` — with hands-on, *measured* proof of their effect, not just theoretical explanation.
5. Understand code-splitting via `React.lazy` and `Suspense`, and apply it to reduce our app's initial load size.

---

## 🎯 The Target: Understanding and running a production build

### 🧠 The Concept: Development mode is a workshop full of tools and labels; production mode is the finished, shipped product

Think of development mode as a woodworking workshop: every tool is out, every piece of scrap wood is labeled with notes, and there's a big helpful sign explaining what went wrong the moment you make a mistake (React's detailed error overlays, unminified code, `StrictMode`'s extra double-rendering checks from Phase 1). A **production build** is the finished chair you actually ship to a customer: every scrap and label is cleared away, the wood is sanded and compressed, and everything unnecessary for the *end user's* experience is stripped out — leaving something dramatically smaller and faster, at the cost of no longer being convenient to *modify* by hand.

Concretely, Vite's production build (`vite build`, which our existing `npm run build` script already runs — recall this from `package.json` in Phase 1, Part 1) performs several transformations automatically:

* **Minification** — removing whitespace, shortening variable names, and stripping comments, to reduce file size.
* **Tree-shaking** — analyzing your actual `import` usage and removing any code from your dependencies (like unused parts of `react-router-dom`) that your app never actually calls.
* **Bundling** — combining our dozens of separate `.jsx` files into a small number of optimized files, reducing the number of separate network requests a browser needs to make.
* **Asset hashing** — renaming output files with a content-based hash (e.g., `index-a1b2c3d4.js`) so browsers can cache them aggressively and safely — a new hash only appears when the actual content changes.

### 🛠️ The Implementation: Running the build

```bash
npm run build
```

**Expected output:**

```
vite v6.0.1 building for production...
✓ 142 modules transformed.
dist/index.html                   0.46 kB │ gzip:  0.30 kB
dist/assets/index-a1b2c3d4.css     4.21 kB │ gzip:  1.35 kB
dist/assets/index-e5f6g7h8.js    187.32 kB │ gzip: 61.04 kB
✓ built in 1.34s
```

A new `dist/` folder now exists in your project root, containing the entire, finished, deployable application — plain HTML, CSS, and JavaScript files, with zero dependency on Node.js, Vite, or any of our development tooling to actually run.

### ✅ The Verification

```bash
ls dist
```

**Expected output:** an `index.html` file and an `assets/` folder containing hashed `.js` and `.css` files.

Open `dist/index.html` in your editor and glance at it — notice it references the hashed asset filenames directly (e.g., `<script src="/assets/index-e5f6g7h8.js">`), a stark contrast to our development `index.html` from Phase 1, which referenced `/src/main.jsx` directly.

Also add `dist/` to our `.gitignore`, since this is a *generated* folder that should never be committed — Vercel will run this exact build step itself during deployment, in Phase 9, Part 2:

**File: `.gitignore`** *(append this line)*

```
dist
```

---

## 🎯 The Target: Verifying the build locally with `npm run preview`

### 🧠 The Concept: A dress rehearsal before opening night

`npm run dev` and a real production environment are different enough (unminified vs. minified code, different environment variable handling, no HMR) that you should never assume "it worked in dev" automatically means "it'll work in production." `vite preview` (our existing `npm run preview` script) starts a small local static file server serving exactly the contents of `dist/` — the closest thing to a true dress rehearsal you can run on your own machine before actually deploying.

### 🛠️ The Implementation

```bash
npm run preview
```

**Expected output:**

```
  ➜  Local:   http://localhost:4173/
  ➜  Network: use --host to expose
```

### ✅ The Verification

Make sure `npm run server` (our json-server backend) is still running, then open `localhost:4173`.

1. Confirm the app loads and functions — Dashboard, navigation, toggling, adding, dark mode, login — exactly as it does under `npm run dev`.
2. Open DevTools → Network tab, reload, and confirm the loaded `.js`/`.css` files have hashed names like `index-e5f6g7h8.js` — proof you're genuinely running the built `dist/` output, not the dev server.
3. Stop this preview server (Ctrl+C) once you've confirmed it works — we don't need it running continuously.

---

## 🎯 The Target: Preparing environment variables for production

### 🧠 The Concept: The same code, pointed at a different address depending on where it's running

Recall from Phase 4, Part 1: our `.env` file currently contains `VITE_API_URL=http://localhost:4000` — perfect for local development, but `localhost` refers to *your own computer*, which will be meaningless once real users load our app from a public URL. Vite has a specific, layered convention for handling exactly this:

| File | When it's used |
|---|---|
| `.env` | Always loaded, in every mode |
| `.env.local` | Always loaded, in every mode — **ignored by git**, for genuinely secret/personal local values |
| `.env.development` | Only loaded when running `vite` (dev server) |
| `.env.production` | Only loaded when running `vite build` |

### 🛠️ The Implementation

Let's formalize this layering. First, remove the environment-specific value from the general `.env`, keeping only things that are genuinely identical everywhere (we don't have any such values yet, but the file remains valid, and this establishes the correct habit):

**File: `.env`**

```
# Values here apply to EVERY environment (development and production).
# We don't have any truly universal values yet — this file is kept as a
# placeholder for that purpose, following Vite's conventions.
```

**File: `.env.development`** *(new file — used only by `npm run dev`)*

```
VITE_API_URL=http://localhost:4000
```

**File: `.env.production`** *(new file — used only by `npm run build`)*

```
VITE_API_URL=https://api.example.com
```

> ⚠️ We're using a placeholder URL (`https://api.example.com`) here deliberately — we don't yet have a real, publicly-deployed backend (our `json-server` only runs locally, which is a genuine and expected limitation of the "no backend expertise required" approach from Phase 4's introduction). In Phase 9, Part 2, we'll revisit this exact value and point it at a real, deployed API alternative suitable for a static Vercel deployment.

Update `.env.example` and `.gitignore` accordingly:

**File: `.env.example`**

```
# Copy this file to .env.development (for local dev) and/or
# .env.production (for production builds), and fill in real values.
VITE_API_URL=http://localhost:4000
```

**File: `.gitignore`** *(replace the single `.env` line with these)*

```
.env
.env.local
.env.development
.env.production
```

### ✅ The Verification

```bash
npm run build
```

Open `dist/assets/index-*.js` in your editor (it will be minified/hard to read, but usable for this check) and search (Ctrl+F) for `api.example.com`. Confirm it's present in the built output — proof Vite correctly baked in the **production** environment variable during the build step, rather than the development one.

Now run `npm run dev` again and confirm — via the `console.log` technique from Phase 4, Part 1, or simply by confirming the app still successfully loads real data from `localhost:4000` — that development mode continues to use `http://localhost:4000` as expected. This confirms both environment files are being correctly, separately applied depending on which command you run.

---

## 🎯 The Target: Measuring before optimizing — the golden rule of performance work

### 🧠 The Concept: Never medicate a symptom you haven't actually diagnosed

Before touching `useMemo`, `useCallback`, or `React.memo`, it's essential to establish the right mindset: **performance optimization applied without measurement is, at best, a coin flip, and at worst, actively harmful** — every one of these tools has a real cost (extra memory to store cached results, extra comparison logic on every render), and applying them reflexively to components that render cheaply and infrequently can make code harder to read for zero actual benefit. React's own official documentation explicitly recommends profiling first.

### 🛠️ The Implementation: Using the React DevTools Profiler

If you haven't already, install the **React Developer Tools** browser extension (search for it by name for Chrome or Firefox). With `npm run dev` and `npm run server` running, open `localhost:5173`, open DevTools, and find the **"⚛️ Profiler"** tab (alongside the "⚛️ Components" tab it also adds).

1. Click the circular **record** button in the Profiler tab.
2. In the app, navigate to the **Habits** page and toggle a couple of habits.
3. Click **record** again to stop.
4. Examine the resulting flame graph — each bar represents a component that rendered during that recording, and its width represents how long that render took.

**Expected observation:** you'll likely see that toggling one specific habit causes **every** `HabitCard` in the list to show up in the render pass for that commit — even the ones whose props didn't change at all. This is the concrete, measured evidence — not a theoretical claim — that motivates the optimization we're about to apply.

---

## 🎯 The Target: Applying `React.memo` to `HabitCard` and `TaskCard`

### 🧠 The Concept: `React.memo` is a bouncer who only lets a component re-render if its props actually changed

By default, when a parent component re-renders, **every one of its children re-renders too** — regardless of whether that specific child's props actually changed. This is a deliberate, sensible default (checking "did anything change?" has its own cost, and for most cheap components, it's not worth it) — but for a list of many cards, where toggling *one* card currently causes React to re-examine *all* of them, it's worth addressing directly. `React.memo(Component)` wraps a component so that React will **skip** re-rendering it if its props are shallow-equal (`===`, the same reference-comparison logic from Phase 2, Part 1's immutability discussion) to what they were on the previous render.

### 🛠️ The Implementation

**File: `src/components/HabitCard.jsx`**

```jsx
import { memo } from 'react'
import { Link } from 'react-router-dom'
import Badge from './Badge.jsx'

function HabitCard({ id, label, streak = 0, isComplete = false, isSaving = false, onToggle }) {
  function handleStreakClick(event) {
    event.stopPropagation()
    window.alert(`🔥 ${streak}-day streak! Keep it up.`)
  }

  function handleDetailsClick(event) {
    event.stopPropagation()
  }

  return (
    <div className={`card habit-card ${isSaving ? 'is-saving' : ''}`} onClick={onToggle}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      {streak > 7 && <span className="fire-indicator">On fire!</span>}
      <Link to={`/habits/${id}`} className="details-link" onClick={handleDetailsClick}>
        Details
      </Link>
      <Badge tone="streak" onClick={handleStreakClick}>
        🔥 {streak}
      </Badge>
    </div>
  )
}

// memo() wraps the finished component. React now shallow-compares every
// individual prop (id, label, streak, isComplete, isSaving, onToggle)
// against their previous values before deciding whether to re-render
// this specific card at all.
export default memo(HabitCard)
```

**File: `src/components/TaskCard.jsx`**

```jsx
import { memo } from 'react'

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

export default memo(TaskCard)
```

### ✅ The Verification: Proving it *doesn't* work yet (on purpose)

Re-run the exact same Profiler recording from before (record → toggle a habit → stop). **Expected (surprising) result:** every `HabitCard` in the list **still** re-renders — `memo` doesn't seem to have helped at all. This is not a mistake in `memo` — it's revealing a real, extremely common gotcha, which we fix in the next step.

---

## 🎯 The Target: Understanding *why* `memo` alone didn't work — the inline function problem

### 🧠 The Concept: A shallow comparison fails if you hand out a brand new box every time, even with identical contents inside

Look at how `HabitsSection` renders each card:

```jsx
<HabitCard
  key={habit.id}
  /* ...other props... */
  onToggle={() => onToggleHabit(habit.id)}
/>
```

That `onToggle={() => onToggleHabit(habit.id)}` creates a **brand new arrow function** on every single render of `HabitsSection` — even if `habit.id` and `onToggleHabit` themselves haven't changed at all. `memo`'s shallow comparison checks `===` (reference equality) — and two different function objects, even if they'd behave identically, are never `===` to each other. So from `memo`'s perspective, the `onToggle` prop looks "different" on every render, which alone is enough to force a re-render, regardless of whether every *other* prop stayed identical.

### 🛠️ The Implementation: Stabilizing the toggle functions with `useCallback`

The fix has two parts: first, `useCallback` in `App.jsx` to give `handleToggleHabit`/`handleToggleTask` themselves stable identities; second, restructuring `HabitsSection`/`TasksSection` to avoid re-creating a *new* inline arrow function per card on every render.

**File: `src/App.jsx`** *(add `useCallback` to the import, and wrap the two toggle handlers)*

```jsx
import { useReducer, useState, useEffect, useOptimistic, useCallback, startTransition } from 'react'
// ...(all other imports unchanged from Phase 6, Part 2)...

function App() {
  // ...(all state/reducer declarations unchanged)...

  // useCallback memoizes this FUNCTION itself. Its dependency array lists
  // everything the function's body actually reads from the outside scope —
  // `habits` (to find the target) — so a new version is only created when
  // that genuinely changes, not on every unrelated re-render of App.
  const handleToggleHabit = useCallback((habitId) => {
    const targetHabit = habits.find((habit) => habit.id === habitId)
    if (!targetHabit) return

    const optimisticHabit = { ...targetHabit, isComplete: !targetHabit.isComplete }
    setSavingHabitIds((current) => new Set(current).add(habitId))

    startTransition(async () => {
      applyOptimisticHabit(optimisticHabit)
      try {
        const savedHabit = await updateHabit(habitId, { isComplete: optimisticHabit.isComplete })
        dispatch({ type: 'TOGGLE_HABIT', payload: savedHabit })
      } catch (error) {
        showToast(`Couldn't save "${targetHabit.label}" — please try again.`)
      } finally {
        setSavingHabitIds((current) => {
          const next = new Set(current)
          next.delete(habitId)
          return next
        })
      }
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [habits, applyOptimisticHabit])

  const handleToggleTask = useCallback((taskId) => {
    const targetTask = tasks.find((task) => task.id === taskId)
    if (!targetTask) return

    const optimisticTask = { ...targetTask, isComplete: !targetTask.isComplete }
    setSavingTaskIds((current) => new Set(current).add(taskId))

    startTransition(async () => {
      applyOptimisticTask(optimisticTask)
      try {
        const savedTask = await updateTask(taskId, { isComplete: optimisticTask.isComplete })
        dispatch({ type: 'TOGGLE_TASK', payload: savedTask })
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
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tasks, applyOptimisticTask])

  // ...(handleRetry, showToast, handleAddTask, handleAddHabit, loading/error
  //     returns, and the final <Routes> JSX all remain EXACTLY as they were
  //     at the end of Phase 6, Part 2 — only the two functions above changed)
```

Now, the second half of the fix: even with `handleToggleHabit` itself stable, `HabitsSection` was still creating a *new* wrapper arrow function per card (`() => onToggleHabit(habit.id)`) on every render, since that specific line runs fresh every time `.map()` runs. We fix this by passing `habit.id` down as a prop and letting `HabitCard` call `onToggle(id)` itself — eliminating the wrapper closure entirely:

**File: `src/components/HabitsSection.jsx`** *(only the `.map()` block changes)*

```jsx
      <div className="card-list">
        {habits.map((habit) => (
          <HabitCard
            key={habit.id}
            id={habit.id}
            label={habit.label}
            streak={habit.streak}
            isComplete={habit.isComplete}
            isSaving={savingHabitIds.has(habit.id)}
            onToggle={onToggleHabit}
          />
        ))}
      </div>
```

**File: `src/components/HabitCard.jsx`** *(the click handler now calls `onToggle(id)` directly)*

```jsx
import { memo } from 'react'
import { Link } from 'react-router-dom'
import Badge from './Badge.jsx'

function HabitCard({ id, label, streak = 0, isComplete = false, isSaving = false, onToggle }) {
  function handleStreakClick(event) {
    event.stopPropagation()
    window.alert(`🔥 ${streak}-day streak! Keep it up.`)
  }

  function handleDetailsClick(event) {
    event.stopPropagation()
  }

  // handleCardClick is a STABLE reference across renders as long as `id`
  // and `onToggle` don't change — unlike the old inline
  // `onClick={() => onToggle(habit.id)}` pattern, which recreated a new
  // function on every single render of the PARENT list.
  function handleCardClick() {
    onToggle(id)
  }

  return (
    <div className={`card habit-card ${isSaving ? 'is-saving' : ''}`} onClick={handleCardClick}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
      {streak > 7 && <span className="fire-indicator">On fire!</span>}
      <Link to={`/habits/${id}`} className="details-link" onClick={handleDetailsClick}>
        Details
      </Link>
      <Badge tone="streak" onClick={handleStreakClick}>
        🔥 {streak}
      </Badge>
    </div>
  )
}

export default memo(HabitCard)
```

Apply the identical pattern to `TasksSection`/`TaskCard`:

**File: `src/components/TasksSection.jsx`** *(only the `.map()` block changes)*

```jsx
      <div className="card-list">
        {filteredTasks.length === 0 ? (
          <p className="empty-state">No tasks match this filter.</p>
        ) : (
          filteredTasks.map((task) => (
            <TaskCard
              key={task.id}
              id={task.id}
              label={task.label}
              isComplete={task.isComplete}
              isSaving={savingTaskIds.has(task.id)}
              onToggle={onToggleTask}
            />
          ))
        )}
      </div>
```

**File: `src/components/TaskCard.jsx`**

```jsx
import { memo } from 'react'

function TaskCard({ id, label, isComplete = false, isSaving = false, onToggle }) {
  function handleCardClick() {
    onToggle(id)
  }

  return (
    <div className={`card task-card ${isSaving ? 'is-saving' : ''}`} onClick={handleCardClick}>
      <span className="card-checkbox">{isComplete ? '☑' : '☐'}</span>
      <span className={`card-label ${isComplete ? 'card-label-done' : ''}`}>
        {label}
      </span>
    </div>
  )
}

export default memo(TaskCard)
```

### ✅ The Verification

Save every file. Confirm both `npm run dev` and `npm run server` are running. Open DevTools → Profiler.

1. Record → navigate to Habits, toggle one habit → stop. Examine the flame graph.
2. **Expected result this time:** only the **one** `HabitCard` you actually toggled appears in the committed render — the others are absent from this commit entirely (or shown grayed-out/marked as "did not render," depending on your React DevTools version), proving `memo` is now correctly skipping the untouched cards.
3. Run the full functional verification from Phase 4, Part 3 one more time (toggle habits/tasks, confirm optimistic updates, confirm persistence, confirm the failure/toast path) to confirm this optimization introduced **zero behavior changes** — exactly the standard we've held every refactor to throughout this series.
4. Update the existing `HabitCard.test.jsx` and `TaskCard`-adjacent tests if needed — since `memo()` only changes *when* a component re-renders, not what it renders given a set of props, our existing tests from Phase 8 should continue to pass unmodified. Run `npm test` to confirm.

---

## 🎯 The Target: `useMemo` for expensive derived calculations

### 🧠 The Concept: A cache slip pinned to a receipt, so you don't redo the math unless the receipt actually changed

`useMemo` is `useCallback`'s sibling — instead of memoizing a *function*, it memoizes the **result of a calculation**, recomputing it only when its listed dependencies change. Let's apply it to `HabitsSection`'s `remainingCount` calculation — a small one today, but a genuine, illustrative candidate, since `.filter()` re-scans the entire array on every render regardless of whether `habits` actually changed.

### 🛠️ The Implementation

**File: `src/components/HabitsSection.jsx`** *(add `useMemo`, and wrap the derived calculations)*

```jsx
import { useMemo } from 'react'
import HabitCard from './HabitCard.jsx'
import HabitForm from './HabitForm.jsx'
import { useToggle } from '../hooks/useToggle.js'

function HabitsSection({ habits, savingHabitIds, onToggleHabit, onAddHabit }) {
  const [isAdding, { setTrue: openAddForm, setFalse: closeAddForm }] = useToggle(false)

  // Recomputed ONLY when `habits` itself changes — not on every render
  // triggered by unrelated state elsewhere in the app (a toast appearing,
  // a theme toggle, etc.).
  const remainingCount = useMemo(
    () => habits.filter((habit) => !habit.isComplete).length,
    [habits]
  )

  const existingLabels = useMemo(
    () => habits.map((habit) => habit.label.toLowerCase()),
    [habits]
  )

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
            onToggle={onToggleHabit}
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

Go to the Habits page. Confirm the "N remaining" count and the "All done!" celebration state still behave **exactly** as they did back in Phase 2, Part 3 and Phase 3 — toggling habits updates the count correctly, and completing every habit shows the celebration message. This confirms `useMemo` changed nothing about *behavior*, only *when the calculation re-runs*.

> ⚠️ **An honest, important caveat:** for an array of 3–4 habits, `useMemo` here provides genuinely negligible real-world benefit — `.filter()` over a handful of items is essentially free. We applied it here specifically as a **clear, safe teaching example**, precisely because its correctness is easy to verify. In a real app, you'd reserve `useMemo` for calculations that are either genuinely expensive (sorting/filtering thousands of items, complex derived aggregations) or that must remain **reference-stable** because they're passed as a prop to a `memo`-wrapped child (exactly why we needed `useCallback` for our toggle handlers above) — not applied reflexively to every derived value in every component, which the "measure first" principle at the start of this part explicitly warns against.

---

## 🎯 The Target: Code-splitting with `React.lazy` and `Suspense`

### 🧠 The Concept: Don't ship the whole furniture catalog if the customer only asked for a chair

Right now, our single production JavaScript bundle contains the code for **every** page — Dashboard, Tasks, Habits, Habit Detail, Settings, Login, 404 — even though a user visiting the Dashboard for the first time doesn't need the Settings page's code yet. **Code-splitting** breaks your bundle into smaller chunks that load **on demand** — specifically, only when the user actually navigates to the route that needs them — reducing the amount of JavaScript a new visitor has to download before your app becomes interactive.

### 🛠️ The Implementation

`React.lazy(loader)` takes a function that dynamically `import()`s a component, and returns a special component that — the *first* time it's actually rendered — triggers that import and suspends (using the exact same Suspense mechanism from Phase 4, Part 2's `use`-based quote widget) until the corresponding chunk finishes downloading.

**File: `src/App.jsx`** *(update the page imports; the rest of the file is unchanged from the `useCallback` version above)*

```jsx
import { useReducer, useState, useEffect, useOptimistic, useCallback, startTransition, lazy, Suspense } from 'react'
import { Routes, Route } from 'react-router-dom'
import Navbar from './components/Navbar.jsx'
import Toast from './components/Toast.jsx'
import ProtectedRoute from './components/ProtectedRoute.jsx'
// Only the pages needed IMMEDIATELY, for the very first paint of the most
// common entry point (the Dashboard), are imported eagerly, up front.
import DashboardPage from './pages/DashboardPage.jsx'
import { fetchHabits, updateHabit, createHabit } from './api/habitsApi.js'
import { fetchTasks, updateTask, createTask } from './api/tasksApi.js'
import { dataReducer, initialDataState } from './reducers/dataReducer.js'

// Every OTHER page is now lazy-loaded: its code is only downloaded the
// first time a user actually navigates to a route that needs it.
const TasksPage = lazy(() => import('./pages/TasksPage.jsx'))
const HabitsLayout = lazy(() => import('./pages/HabitsLayout.jsx'))
const HabitsPage = lazy(() => import('./pages/HabitsPage.jsx'))
const HabitDetailPage = lazy(() => import('./pages/HabitDetailPage.jsx'))
const SettingsPage = lazy(() => import('./pages/SettingsPage.jsx'))
const LoginPage = lazy(() => import('./pages/LoginPage.jsx'))
const NotFoundPage = lazy(() => import('./pages/NotFoundPage.jsx'))

function App() {
  // ...(every single state declaration, effect, and handler function is
  //     UNCHANGED from the useCallback version earlier in this part)...

  return (
    <div className="app">
      <Navbar />
      {/* A single Suspense boundary wraps ALL our routes — while any lazy
          page's code is still downloading, this fallback shows briefly
          in its place, then the real page renders once the chunk arrives. */}
      <Suspense fallback={<p className="loading-message">Loading page…</p>}>
        <Routes>
          <Route path="/" element={<DashboardPage habits={optimisticHabits} tasks={optimisticTasks} />} />

          <Route
            path="/tasks"
            element={
              <TasksPage
                tasks={optimisticTasks}
                savingTaskIds={savingTaskIds}
                onToggleTask={handleToggleTask}
                onAddTask={handleAddTask}
              />
            }
          />

          <Route
            path="/habits"
            element={
              <HabitsLayout
                habits={optimisticHabits}
                savingHabitIds={savingHabitIds}
                onToggleHabit={handleToggleHabit}
                onAddHabit={handleAddHabit}
              />
            }
          >
            <Route index element={<HabitsPage />} />
            <Route path=":habitId" element={<HabitDetailPage />} />
          </Route>

          <Route path="/login" element={<LoginPage />} />

          <Route
            path="/settings"
            element={
              <ProtectedRoute>
                <SettingsPage />
              </ProtectedRoute>
            }
          />

          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </Suspense>
      <Toast message={toastMessage} />
    </div>
  )
}

export default App
```

> ⚠️ **A worth-noting subtlety:** we import `HabitsPage` **twice** conceptually here — once eagerly-adjacent as a lazy top-level route reference, and it's also referenced as the `index` route inside `/habits`. Since we declared `const HabitsPage = lazy(...)` exactly once at the top of the file, both usages correctly point at the same lazily-loaded module — there's no duplication or conflict, just two `<Route>` entries referencing the same lazy component.

### ✅ The Verification

```bash
npm run build
```

**Expected output:** instead of one single large JS file, you should now see **multiple** smaller files listed, roughly one per lazy-loaded page:

```
dist/assets/index-a1b2c3d4.js         98.10 kB │ gzip: 32.15 kB
dist/assets/TasksPage-b2c3d4e5.js      4.82 kB │ gzip:  1.90 kB
dist/assets/HabitsLayout-c3d4e5f6.js   3.14 kB │ gzip:  1.20 kB
dist/assets/HabitsPage-d4e5f6g7.js     2.05 kB │ gzip:  0.95 kB
dist/assets/HabitDetailPage-...js      2.40 kB │ gzip:  1.05 kB
dist/assets/SettingsPage-...js         2.88 kB │ gzip:  1.15 kB
dist/assets/LoginPage-...js            2.20 kB │ gzip:  0.98 kB
dist/assets/NotFoundPage-...js         0.90 kB │ gzip:  0.55 kB
```

Run `npm run preview`, open `localhost:4173`, and open DevTools → Network tab (with a filter for "JS"), then reload the page while sitting on the Dashboard.

1. Confirm only the main `index-*.js` chunk loads initially — none of the page-specific chunks appear yet.
2. Click **"Tasks"** in the Navbar. Confirm you now see a brief flash of **"Loading page…"** (our Suspense fallback), followed immediately by a new network request for `TasksPage-*.js`, after which the real page renders.
3. Click **"Habits"**, then **"Settings"** (logging in if prompted). Confirm each triggers its own distinct, on-demand chunk download the first time you visit it, and does **not** re-download on subsequent visits within the same session (React caches the already-loaded module).
4. Run through the full functional verification checklist one final time — every feature built across this entire series — confirming code-splitting introduced zero behavioral regressions, only a smaller initial bundle.

Stop the preview server once confirmed.

---

## 📚 Reference Section: Phase 9, Part 1

### `React.memo`, `useMemo`, `useCallback` — a unified decision guide

| Tool | Memoizes | Use when |
|---|---|---|
| `React.memo(Component)` | An entire component's render output | The component re-renders often with unchanged props, and its own render work is non-trivial |
| `useMemo(fn, deps)` | The **result** of a calculation | The calculation is expensive, or its result must remain reference-stable for a `memo`-wrapped child or another hook's dependency array |
| `useCallback(fn, deps)` | A **function** itself | The function is passed to a `memo`-wrapped child, or used in another hook's dependency array, and would otherwise be recreated every render |

All three exist to answer one question: **"can we safely skip redoing this work, because nothing relevant has actually changed?"** None of them change *what* your app renders — only *how often* the underlying work is repeated. This is precisely why applying (or removing) them should never be observable by a user or by your test suite — a genuinely reassuring property, and the reason we re-ran our full functional and automated test checklist after every optimization in this part.

### Why "premature optimization" is a real risk, not just a cliché

Every `memo`/`useMemo`/`useCallback` you add has to be **read, understood, and correctly maintained** by every future person (including future-you) working in that file — dependency arrays must stay accurate, or you risk the opposite problem: a **stale closure** bug, where a memoized function or value silently keeps referencing outdated data because a dependency was forgotten. This is a genuinely common, hard-to-spot class of bug in real codebases. The discipline this part modeled — profile first, optimize the specific, measured bottleneck, then verify behavior is unchanged — is the responsible default; reflexively wrapping *everything* in these tools "just in case" trades a hypothetical performance gain for a very real, ongoing maintenance cost.

### `React.lazy` — full API reference

```javascript
const LazyComponent = lazy(() => import('./LazyComponent.jsx'))
```

* The loader function must return a Promise resolving to a module with a **default export** — this is why every one of our page components uses `export default PageName`, established all the way back in Phase 1, Part 2.
* A lazy component **must** be rendered somewhere inside a `<Suspense>` boundary — without one, React has no fallback to show while the chunk downloads, and will throw an error.
* Once a given chunk has been downloaded once in a session, subsequent renders of that same lazy component are instant — no repeated network request.

### When *not* to lazy-load

Lazy-loading has a real cost: an extra network round-trip the *first* time a user visits that specific route, which can introduce a visible flash of loading state for very small components. It's most worth applying to routes/components that are: (a) not needed for the initial, most common page a user lands on, and (b) large enough that splitting them out meaningfully reduces the initial bundle. Lazy-loading something tiny (like our `Badge` component) would add loading overhead for essentially zero bundle-size benefit — reserve it for page-level or otherwise substantial component boundaries, exactly as we applied it here.

### Common errors & fixes when working with production builds and performance tools

| Symptom | Likely cause | Fix |
|---|---|---|
| Production build shows old/wrong API URL | `.env.production` missing or misnamed, or build wasn't re-run after editing it | Confirm the exact filename `.env.production`, and re-run `npm run build` |
| `memo`-wrapped component still re-renders on every parent update | A non-memoized prop (often an inline function or object literal) is still being passed, defeating the shallow comparison | Wrap the relevant function in `useCallback`, or the relevant object/array in `useMemo`, at its source |
| Component using stale data after adding `useCallback`/`useMemo` | A dependency was omitted from the dependency array | Add the missing dependency; consider enabling the `react-hooks/exhaustive-deps` ESLint rule's warnings rather than suppressing them, except in deliberate, well-understood cases |
| `A component was suspended by an uncached promise` or similar error with `React.lazy` | A lazy component was rendered without any `<Suspense>` boundary above it | Wrap the relevant `<Routes>` (or the specific lazy component) in `<Suspense fallback={...}>` |
| Bundle size didn't meaningfully shrink after adding `lazy()` | The lazy-loaded component still imports something enormous shared with the main bundle, limiting how much can actually be split out | Inspect the build output's chunk sizes; shared dependencies will always remain in a common chunk regardless of splitting |
