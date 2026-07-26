# Phase 6: Navigation
# Part 1: React Router — Multi-Page Navigation

## Introduction: What we're doing in this part

Every feature we've built so far lives crammed onto one single screen. That's fine for a small demo, but real apps organize related features into distinct "pages" — a Dashboard, a Tasks page, a Habits page, a Settings page — each with its own shareable, bookmarkable web address. Our app currently has none of that: there's exactly one URL, `localhost:5173/`, no matter what you're looking at.

In this part, you will:

1. Understand what client-side routing actually is, and why a Single Page Application needs a dedicated library to do it properly.
2. Install and configure **React Router**, the standard routing library for React apps.
3. Split our cluttered single-screen `Dashboard` into four genuine pages: Dashboard (an overview), Tasks, Habits, and Settings.
4. Build real, working navigation links in the Navbar, including correct "active page" highlighting.
5. Add a catch-all 404 page for unmatched URLs.

By the end, you'll have distinct, shareable URLs for every section of the app, full browser back/forward support, and a Navbar that always tells you exactly where you are.

---

## 🎯 The Target: Understanding client-side routing

### 🧠 The Concept: A receptionist who swaps out the display, without ever calling for a whole new building

Recall from Phase 1, Part 1 that our entire app lives inside a single, real HTML page — `<div id="root">` — and React just swaps content in and out of it. This is what makes it a **Single Page Application (SPA)**. Traditionally, going from "page" to "page" on the web meant the browser threw away everything and requested an entirely new HTML document from the server — a full reload, with a visible flash and a noticeable delay.

**Client-side routing** keeps the SPA illusion intact while still giving you the *feel* of multiple pages: a library watches the browser's address bar, and whenever it changes (either because the user clicked a specially-marked link, or typed a URL directly, or used the browser's Back/Forward buttons), it swaps out *which components* are currently rendered inside our one real page — without ever asking the server for a new HTML document. Think of it like a hotel receptionist who, when you ask for "the conference room," doesn't rebuild the entire hotel — she just directs you to a different room within the same building, updating the directory sign at the front desk (the URL) to reflect where you now are.

**React Router** is the library that implements this for React apps. It gives us:
* A way to declare "when the URL looks like *this*, show *that* component."
* Special link components that update the URL and swap content *without* a full page reload.
* Hooks to read the current URL, navigate programmatically, and extract dynamic pieces of a URL (like an item's ID) — the last of which we'll use heavily in the next part.

---

## 🎯 The Target: Installing React Router

### 🛠️ The Implementation

```bash
npm install react-router-dom@6.28.1
```

We pin this exact version deliberately, matching the rest of this series' approach — it's a current, stable release fully compatible with React 19. (You may also encounter React Router v7 in the wild, released shortly after; its core routing API used in this series — `BrowserRouter`, `Routes`, `Route`, `Link`, `NavLink` — is unchanged, so everything you learn here transfers directly.)

### ✅ The Verification

```bash
npm list react-router-dom
```

**Expected output:**
```
task-habit-tracker@0.0.0 /Users/you/Documents/Code/task-habit-tracker
└── react-router-dom@6.28.1
```

---

## 🎯 The Target: Wrapping the app in `BrowserRouter`

### 🧠 The Concept: `BrowserRouter` is the receptionist herself — she has to be on duty before anyone can ask her for a room

`BrowserRouter` is a component that must wrap any part of your app that wants to use routing features. It uses the browser's built-in **History API** (the same underlying mechanism that powers the Back/Forward buttons) to watch and update the URL without triggering a real page reload.

### 🛠️ The Implementation

**File: `src/main.jsx`**

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import './index.css'
import App from './App.jsx'
import ThemeProvider from './context/ThemeProvider.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    {/* BrowserRouter must wrap anything that needs routing features —
        we put it OUTSIDE ThemeProvider here, though the order between
        these two providers doesn't functionally matter, since neither
        depends on the other. */}
    <BrowserRouter>
      <ThemeProvider>
        <App />
      </ThemeProvider>
    </BrowserRouter>
  </StrictMode>,
)
```

### ✅ The Verification

Save the file. Confirm `localhost:5173` still loads exactly as before — `BrowserRouter` alone doesn't change any visible behavior yet; it just makes routing features available to everything inside it.

---

## 🎯 The Target: Building our four page components

### 🧠 The Concept: A "page" is just a component whose job is to compose smaller components for one URL

There's no special syntax that makes something a "page" — it's purely a naming and organizational convention. A page component sits in `src/pages/`, corresponds to exactly one route, and is typically composed almost entirely of smaller, already-built components (`TasksSection`, `HabitsSection`, `QuoteOfTheDay`) rather than containing much markup of its own. This mirrors the `pages/` folder we sketched all the way back in Part 0's architecture diagram.

We're also going to retire `Dashboard.jsx` — its responsibilities get redistributed: the "everything on one screen" layout it used to provide no longer makes sense once each section has its own dedicated page.

### 🛠️ The Implementation

```bash
mkdir src/pages
rm src/components/Dashboard.jsx
```

**File: `src/pages/DashboardPage.jsx`**

```jsx
import { Suspense, useState } from 'react'
import { Link } from 'react-router-dom'
import QuoteOfTheDay from '../components/QuoteOfTheDay.jsx'
import ErrorBoundary from '../components/ErrorBoundary.jsx'
import { getQuotePromise, resetQuotePromise } from '../api/quoteCache.js'

// DashboardPage is an OVERVIEW — it shows a taste of each area (today's
// quote, and how many habits/tasks remain) with links to the full pages,
// rather than duplicating the entire Tasks/Habits UI here.
function DashboardPage({ habits, tasks }) {
  const [quotePromise, setQuotePromise] = useState(getQuotePromise)

  function handleQuoteRetry() {
    setQuotePromise(resetQuotePromise())
  }

  const remainingHabits = habits.filter((habit) => !habit.isComplete).length
  const remainingTasks = tasks.filter((task) => !task.isComplete).length

  return (
    <div className="page">
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

      <div className="summary-grid">
        {/* Link renders a real <a> tag under the hood, but intercepts the
            click to perform client-side navigation instead of a full reload. */}
        <Link to="/habits" className="summary-card">
          <span className="summary-count">{remainingHabits}</span>
          <span className="summary-label">Habits remaining today</span>
        </Link>
        <Link to="/tasks" className="summary-card">
          <span className="summary-count">{remainingTasks}</span>
          <span className="summary-label">Tasks remaining</span>
        </Link>
      </div>
    </div>
  )
}

export default DashboardPage
```

**File: `src/pages/TasksPage.jsx`**

```jsx
import TasksSection from '../components/TasksSection.jsx'

function TasksPage({ tasks, savingTaskIds, onToggleTask, onAddTask }) {
  return (
    <div className="page">
      <TasksSection
        tasks={tasks}
        savingTaskIds={savingTaskIds}
        onToggleTask={onToggleTask}
        onAddTask={onAddTask}
      />
    </div>
  )
}

export default TasksPage
```

**File: `src/pages/HabitsPage.jsx`**

```jsx
import HabitsSection from '../components/HabitsSection.jsx'

function HabitsPage({ habits, savingHabitIds, onToggleHabit, onAddHabit }) {
  return (
    <div className="page">
      <HabitsSection
        habits={habits}
        savingHabitIds={savingHabitIds}
        onToggleHabit={onToggleHabit}
        onAddHabit={onAddHabit}
      />
    </div>
  )
}

export default HabitsPage
```

**File: `src/pages/SettingsPage.jsx`**

```jsx
import { useTheme } from '../context/useTheme.js'

// Notice: useTheme() works here exactly as it did in Navbar, even though
// SettingsPage sits in a totally different part of the component tree.
// This is Context, from Phase 5, paying off exactly as promised.
function SettingsPage() {
  const { theme, toggleTheme } = useTheme()

  return (
    <div className="page">
      <section className="dashboard-section">
        <h2>Appearance</h2>
        <p className="settings-description">
          Choose how the Task &amp; Habit Tracker looks on this device. Your
          preference is saved automatically and remembered next time you visit.
        </p>
        <button type="button" className="theme-toggle" onClick={toggleTheme}>
          {theme === 'light' ? '🌙 Switch to Dark Mode' : '☀️ Switch to Light Mode'}
        </button>
      </section>

      <section className="dashboard-section">
        <h2>About</h2>
        <p className="settings-description">
          Task &amp; Habit Tracker — built step by step across the "React 19
          Tutorial Series: Zero to Production." Data is currently served by a
          local json-server instance for development purposes.
        </p>
      </section>
    </div>
  )
}

export default SettingsPage
```

**File: `src/pages/NotFoundPage.jsx`**

```jsx
import { Link } from 'react-router-dom'

function NotFoundPage() {
  return (
    <div className="page not-found-page">
      <h2>404 — Page Not Found</h2>
      <p>We couldn't find the page you were looking for.</p>
      <Link to="/" className="add-button add-button-block">
        ← Back to Dashboard
      </Link>
    </div>
  )
}

export default NotFoundPage
```

### ✅ The Verification

No visible output yet — these pages aren't wired into any routes. Confirm all five files save without errors before continuing.

---

## 🎯 The Target: Defining routes in `App.jsx`

### 🧠 The Concept: `Routes`/`Route` is a big `switch` statement for URLs

`<Routes>` scans through its `<Route>` children and renders the **first one** whose `path` matches the current URL. Each `<Route>` pairs a `path` (a URL pattern) with an `element` (the component tree to render when that pattern matches). This should feel familiar — it's conceptually identical to the ternary/conditional rendering patterns from Phase 2, Part 3, just operating on the URL instead of a piece of state.

### 🛠️ The Implementation

**File: `src/App.jsx`**

```jsx
import { useReducer, useState, useEffect, useOptimistic, startTransition } from 'react'
import { Routes, Route } from 'react-router-dom'
import Navbar from './components/Navbar.jsx'
import Toast from './components/Toast.jsx'
import DashboardPage from './pages/DashboardPage.jsx'
import TasksPage from './pages/TasksPage.jsx'
import HabitsPage from './pages/HabitsPage.jsx'
import SettingsPage from './pages/SettingsPage.jsx'
import NotFoundPage from './pages/NotFoundPage.jsx'
import { fetchHabits, updateHabit, createHabit } from './api/habitsApi.js'
import { fetchTasks, updateTask, createTask } from './api/tasksApi.js'
import { dataReducer, initialDataState } from './reducers/dataReducer.js'

function App() {
  const [state, dispatch] = useReducer(dataReducer, initialDataState)
  const { habits, tasks, isLoading, loadError } = state

  const [retryCount, setRetryCount] = useState(0)
  const [toastMessage, setToastMessage] = useState(null)
  const [savingHabitIds, setSavingHabitIds] = useState(() => new Set())
  const [savingTaskIds, setSavingTaskIds] = useState(() => new Set())

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
      dispatch({ type: 'FETCH_START' })
      try {
        const [habitsData, tasksData] = await Promise.all([fetchHabits(), fetchTasks()])
        if (!isCancelled) {
          dispatch({ type: 'FETCH_SUCCESS', payload: { habits: habitsData, tasks: tasksData } })
        }
      } catch (error) {
        if (!isCancelled) dispatch({ type: 'FETCH_ERROR', payload: error })
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
  }

  async function handleAddTask(label) {
    const savedTask = await createTask({ label, isComplete: false })
    dispatch({ type: 'ADD_TASK', payload: savedTask })
  }

  async function handleAddHabit(label) {
    const savedHabit = await createHabit({ label, streak: 0, isComplete: false })
    dispatch({ type: 'ADD_HABIT', payload: savedHabit })
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
      {/* Navbar is rendered ONCE, outside <Routes>, so it appears on
          every page — only the content below it swaps per route. */}
      <Navbar />
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
            <HabitsPage
              habits={optimisticHabits}
              savingHabitIds={savingHabitIds}
              onToggleHabit={handleToggleHabit}
              onAddHabit={handleAddHabit}
            />
          }
        />
        <Route path="/settings" element={<SettingsPage />} />
        {/* The "*" wildcard path matches any URL that didn't match one of
            the routes above — our catch-all 404 page. Order matters:
            this must be listed LAST. */}
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
      <Toast message={toastMessage} />
    </div>
  )
}

export default App
```

### ✅ The Verification

Save the file. Confirm both `npm run dev` and `npm run server` are running. Go to `localhost:5173`.

1. You should see the **Dashboard page**: the quote widget, plus two clickable summary cards ("N Habits remaining today," "N Tasks remaining").
2. Manually type `localhost:5173/tasks` into your browser's address bar and press Enter. Confirm you land directly on the full Tasks page — filter tabs, "+ New Task," everything from before.
3. Manually navigate to `localhost:5173/nonsense-page`. Confirm you see our **404 page** with a "← Back to Dashboard" link, and clicking it takes you home.

We haven't wired up clickable Navbar links yet — that's next — so for now, confirm navigation via the address bar works correctly before proceeding.

---

## 🎯 The Target: Building Navbar links with `NavLink`

### 🧠 The Concept: `NavLink` is a `Link` that knows whether it's "home"

`Link` is React Router's replacement for a plain `<a href="...">` — clicking one updates the URL and swaps content **without** a full page reload (a real `<a>` tag would trigger one). `NavLink` is a specialized version of `Link` built specifically for navigation menus: it automatically knows whether *its own* destination matches the current URL, and lets you style it differently when it does — exactly the "you are here" highlighting every navigation bar needs.

### 🛠️ The Implementation

**File: `src/components/Navbar.jsx`**

```jsx
import { NavLink } from 'react-router-dom'
import { useTheme } from '../context/useTheme.js'

// Defined outside the component — this array never changes, so there's
// no reason to recreate it on every render (the same reasoning we used
// for FILTER_OPTIONS back in Phase 2, Part 3).
const NAV_LINKS = [
  { to: '/', label: 'Dashboard', end: true },
  { to: '/tasks', label: 'Tasks' },
  { to: '/habits', label: 'Habits' },
  { to: '/settings', label: 'Settings' },
]

function Navbar() {
  const { theme, toggleTheme } = useTheme()

  return (
    <nav className="navbar">
      <div className="navbar-top">
        <h1 className="navbar-title">📝 Task & Habit Tracker</h1>
        <button type="button" className="theme-toggle" onClick={toggleTheme}>
          {theme === 'light' ? '🌙 Dark Mode' : '☀️ Light Mode'}
        </button>
      </div>
      <div className="navbar-links">
        {NAV_LINKS.map((link) => (
          <NavLink
            key={link.to}
            to={link.to}
            // `end` matters specifically for the "/" route: WITHOUT it,
            // NavLink treats "/" as a PREFIX match, meaning it would count
            // as "active" on every single page (since "/tasks" also starts
            // with "/"). `end` forces an exact match instead.
            end={link.end}
            className={({ isActive }) => `nav-link ${isActive ? 'nav-link-active' : ''}`}
          >
            {link.label}
          </NavLink>
        ))}
      </div>
    </nav>
  )
}

export default Navbar
```

Notice `className` is passed as a **function** here (`({ isActive }) => ...`), not a plain string — this is a feature specific to `NavLink`: React Router calls this function for you on every render, handing you `isActive` (and a couple of other flags we'll cover in the Reference Section), so you can compute the class name dynamically based on whether this specific link matches the current URL.

Now update our CSS to style the Navbar's new two-row structure, the nav links, the summary cards, and the 404 page:

**File: `src/index.css`** *(replace the existing `.navbar` and `.navbar-title` rules with this expanded set)*

```css
.navbar {
  padding: 1.25rem 0 0.75rem;
  border-bottom: 1px solid var(--color-border);
  margin-bottom: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

.navbar-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.navbar-title {
  margin: 0;
  font-size: 1.4rem;
}

.navbar-links {
  display: flex;
  gap: 1.25rem;
}

.nav-link {
  text-decoration: none;
  color: var(--color-text-muted);
  font-size: 0.9rem;
  font-weight: 600;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid transparent;
}

.nav-link:hover {
  color: var(--color-text);
}

.nav-link-active {
  color: var(--color-accent);
  border-bottom-color: var(--color-accent);
}
```

**File: `src/index.css`** *(append this block)*

```css
/* --- Page container --- */

.page {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

/* --- Dashboard summary cards --- */

.summary-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.summary-card {
  background: var(--color-surface);
  border-radius: 12px;
  padding: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  text-decoration: none;
  color: var(--color-text);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  transition: transform 0.15s ease;
}

.summary-card:hover {
  transform: translateY(-2px);
}

.summary-count {
  font-size: 2rem;
  font-weight: 700;
  color: var(--color-accent);
}

.summary-label {
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

/* --- Settings page --- */

.settings-description {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  line-height: 1.5;
}

/* --- 404 page --- */

.not-found-page {
  text-align: center;
  padding: 3rem 1rem;
}
```

### ✅ The Verification

Save every file. Go to `localhost:5173`.

1. Confirm the Navbar now shows a row of four links below the title: **Dashboard**, **Tasks**, **Habits**, **Settings** — with **Dashboard** highlighted (colored text, colored underline) since that's the current page.
2. Click **Tasks**. Confirm: the URL bar updates to `localhost:5173/tasks`, the content below the Navbar swaps to the full Tasks page, **there is no full-page flash/reload**, and the **Tasks** link is now the highlighted one instead of Dashboard.
3. Click **Habits**, then **Settings** — confirm each swaps correctly and highlights correctly.
4. On the **Settings** page, click the theme toggle. Confirm dark mode applies across the whole app exactly as it did in Phase 5 — proving Context still works correctly through routing changes.
5. Click your browser's **Back** button several times. Confirm it correctly steps back through Dashboard → Tasks → Habits → Settings in reverse, updating both the URL and the highlighted nav link each time — genuine browser history integration, not something we wrote any code for ourselves.
6. On the Dashboard page, click one of the summary cards (e.g., "N Tasks remaining"). Confirm it navigates directly to the Tasks page — proving `Link` works identically to `NavLink` for plain navigation, just without the active-highlighting behavior.

---

## 📚 Reference Section: Phase 6, Part 1

### React Router's core building blocks — full reference

| Component/Hook | Purpose |
|---|---|
| `<BrowserRouter>` | Enables routing for everything inside it, using the browser's History API |
| `<Routes>` | Scans its `<Route>` children and renders the first one matching the current URL |
| `<Route path="..." element={...} />` | Pairs a URL pattern with the component tree to render for it |
| `<Link to="...">` | A navigable link that updates the URL without a full page reload |
| `<NavLink to="...">` | A `Link` that knows if it's currently "active," for menu-style highlighting |
| `useNavigate()` | A hook returning a function to navigate **programmatically** (e.g., redirect after a form submits) — not used yet in this series, but coming in the next part |
| `useParams()` | A hook to read dynamic segments out of the current URL (e.g., the `:habitId` in `/habits/:habitId`) — the entire subject of the next part |
| `useLocation()` | A hook returning the current URL's details (pathname, search params, etc.) |

### `NavLink`'s `className` function — the full set of flags

```jsx
<NavLink
  to="/tasks"
  className={({ isActive, isPending, isTransitioning }) => /* ... */}
>
```

* **`isActive`** — `true` when the current URL matches this link's destination (the one we used).
* **`isPending`** — relevant only in data-loading-aware routing setups (like React Router's "loader" APIs, which are outside this series' scope); generally `false` in our simple setup.
* **`isTransitioning`** — relevant to View Transitions API integration, an advanced/optional feature not covered in this series.

### Why does `end` matter so much for the root `"/"` link?

By default, React Router treats route/link matching as a **prefix** match for `NavLink`'s active-detection — this is intentional and useful for nested routes (covered next part), where you often *want* a parent link to stay highlighted while viewing any of its child pages. But it creates one specific gotcha: since **every** URL in our app starts with `/` (e.g., `/tasks` starts with `/`), the Dashboard link would incorrectly show as "active" on every single page unless we tell it to require an **exact** match via the `end` prop. This is one of the most common points of confusion for React Router beginners — if you ever see a root nav link stuck permanently "active," this is almost always the cause.

### Static hosting and the SPA "refresh" problem (a preview of Phase 9)

Right now, refreshing the browser directly on `localhost:5173/tasks` works fine, because Vite's development server is smart enough to serve `index.html` for any URL it doesn't otherwise recognize as a real file — letting our client-side JavaScript take over and render the correct page based on the URL. Production static hosts don't all do this automatically — if configured naively, requesting `/tasks` directly from a plain static file server would return a genuine 404, because no literal file named `tasks` exists on disk. We'll explicitly configure this "SPA fallback" behavior for our chosen host (Vercel) in Phase 9, but it's worth flagging now so the concept isn't a surprise later.

### Common errors & fixes when working with React Router

| Symptom | Likely cause | Fix |
|---|---|---|
| `useTheme must be called from within a <ThemeProvider>` (or similar routing-related hook errors) appears after adding routing | A component using a Router hook (`useNavigate`, `NavLink`, etc.) is rendered outside `<BrowserRouter>` | Confirm `<BrowserRouter>` wraps everything in `main.jsx`, above `<App />` |
| Clicking a `Link`/`NavLink` causes a full page reload/flash | Accidentally used a plain `<a href="...">` instead of `<Link to="...">` | Replace with `Link`/`NavLink` from `react-router-dom` |
| The Dashboard nav link stays highlighted on every page | Missing the `end` prop on that specific `NavLink` | Add `end` (or `end={true}`) to the root route's link only |
| 404 page shows even for a route you defined | The wildcard `<Route path="*">` was listed **before** your real routes in the `<Routes>` list | Move the wildcard route to be the last `<Route>` listed |
| Typing a URL directly (e.g., `/tasks`) and refreshing shows a real 404 from the server | Expected in a naive production static-hosting setup (see above) — not an issue in Vite's dev server | Configure SPA fallback rewrites at deployment time (Phase 9) |
| `Cannot find module 'react-router-dom'` | Package not installed, or dev server wasn't restarted after installing | Confirm `npm install react-router-dom@6.28.1` succeeded; restart `npm run dev` |
