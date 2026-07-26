# Phase 6: Navigation
# Part 2: Nested Routes, URL Params, and Protected Routes

## Introduction: What we're doing in this part

Our routing so far only handles flat, static URLs — `/tasks`, `/habits`, `/settings`. Real apps need two more capabilities: **dynamic URLs** that reference a specific item (like `/habits/3` for one particular habit), and **access control**, where certain pages should only be reachable by users in a particular state (like being logged in).

In this part, you will:

1. Build a dedicated **habit detail page**, reachable at a dynamic URL like `/habits/3`, using **URL parameters**.
2. Learn **nested routes** — routes rendered *inside* a shared parent layout — and the `<Outlet>` component that makes it possible.
3. Learn `useOutletContext`, a clean way to hand data down through a nested route structure without prop drilling through route definitions.
4. Build a simple, simulated authentication system with the three-file Context pattern from Phase 5, and use it to **protect** the Settings page behind a login screen.
5. Understand — clearly and explicitly — what "protecting a route" like this actually secures, and what it emphatically does not.

---

## 🎯 The Target: Understanding nested routes and `<Outlet>`

### 🧠 The Concept: A nested route is a picture frame with a swappable photo inside it

Imagine the Habits section of our app as a picture frame hanging on a wall. The frame itself — its border, its mounting on the wall — stays exactly the same no matter what. But the *photo inside it* can be swapped: sometimes it shows the full gallery (our habit list), sometimes it shows one specific enlarged photo (a single habit's detail view). **Nested routes** let you declare this exact relationship: a parent route renders the shared "frame," and a special placeholder component called `<Outlet>` marks exactly where the currently-matched child route's content should appear inside that frame.

```jsx
<Route path="/habits" element={<HabitsLayout />}>
  <Route index element={<HabitsPage />} />       {/* matches exactly "/habits" */}
  <Route path=":habitId" element={<HabitDetailPage />} /> {/* matches "/habits/3", "/habits/7", etc. */}
</Route>
```

The `index` route is what renders when the URL matches the parent path *exactly*, with nothing further after it. The `:habitId` segment is a **URL parameter** — the colon tells React Router "this piece of the URL is a variable, not a literal word; whatever text actually appears here, capture it and make it available under the name `habitId`."

---

## 🎯 The Target: Building the Habits nested routes and detail page

### 🛠️ The Implementation

**File: `src/pages/HabitsLayout.jsx`**

```jsx
import { Outlet } from 'react-router-dom'

// HabitsLayout is the "picture frame": it receives all the habit-related
// data and handlers ONCE from App.jsx, and hands them down to WHICHEVER
// nested route currently matches, via Outlet's `context` prop — rather
// than App.jsx needing to know or care whether the list or the detail
// page is currently showing.
function HabitsLayout({ habits, savingHabitIds, onToggleHabit, onAddHabit }) {
  return (
    <div className="page">
      <Outlet context={{ habits, savingHabitIds, onToggleHabit, onAddHabit }} />
    </div>
  )
}

export default HabitsLayout
```

**File: `src/pages/HabitsPage.jsx`**

```jsx
import { useOutletContext } from 'react-router-dom'
import HabitsSection from '../components/HabitsSection.jsx'

// useOutletContext() reads whatever value HabitsLayout passed to its
// <Outlet context={...}>. This is how this component gets its data
// without App.jsx needing to pass props directly to IT specifically —
// only to the shared parent layout, one level up.
function HabitsPage() {
  const { habits, savingHabitIds, onToggleHabit, onAddHabit } = useOutletContext()

  return (
    <HabitsSection
      habits={habits}
      savingHabitIds={savingHabitIds}
      onToggleHabit={onToggleHabit}
      onAddHabit={onAddHabit}
    />
  )
}

export default HabitsPage
```

**File: `src/pages/HabitDetailPage.jsx`**

```jsx
import { useParams, useOutletContext, Link } from 'react-router-dom'

function HabitDetailPage() {
  // useParams() reads dynamic segments out of the CURRENT matched URL.
  // Its keys match whatever names you used in the route's path definition
  // (":habitId" in App.jsx becomes { habitId } here).
  const { habitId } = useParams()
  const { habits, onToggleHabit } = useOutletContext()

  // ⚠️ IMPORTANT GOTCHA: useParams() ALWAYS returns strings, no matter
  // what type the value "looks like." Our habit ids are numbers (assigned
  // by json-server), so a strict `habit.id === habitId` comparison would
  // ALWAYS be false (number !== string). We convert explicitly with
  // String(habit.id) to compare safely.
  const habit = habits.find((currentHabit) => String(currentHabit.id) === habitId)

  if (!habit) {
    return (
      <div className="dashboard-section">
        <p>We couldn't find that habit. It may have been removed.</p>
        <Link to="/habits" className="add-button">
          ← Back to Habits
        </Link>
      </div>
    )
  }

  return (
    <div className="dashboard-section habit-detail">
      <Link to="/habits" className="breadcrumb-link">
        ← Back to Habits
      </Link>
      <h2>{habit.label}</h2>
      <p className="habit-detail-streak">🔥 {habit.streak}-day streak</p>
      <p>
        Status:{' '}
        <strong>{habit.isComplete ? 'Completed today' : 'Not yet completed today'}</strong>
      </p>
      <button type="button" className="retry-button" onClick={() => onToggleHabit(habit.id)}>
        {habit.isComplete ? 'Mark as Not Done' : 'Mark as Done'}
      </button>
    </div>
  )
}

export default HabitDetailPage
```

Now give each `HabitCard` a link to its own detail page. This requires passing the habit's `id` down as a prop, and adding a "Details" link that stops its click from bubbling up to the card's own toggle behavior — exactly the `stopPropagation` technique from Phase 2, Part 3:

**File: `src/components/HabitCard.jsx`**

```jsx
import { Link } from 'react-router-dom'
import Badge from './Badge.jsx'

function HabitCard({ id, label, streak = 0, isComplete = false, isSaving = false, onToggle }) {
  function handleStreakClick(event) {
    event.stopPropagation()
    window.alert(`🔥 ${streak}-day streak! Keep it up.`)
  }

  function handleDetailsClick(event) {
    // Without this, clicking "Details" would ALSO toggle the habit,
    // since this link lives inside the card's own onClick={onToggle} area.
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

export default HabitCard
```

**File: `src/components/HabitsSection.jsx`** *(only the `<HabitCard>` usage changes — add the `id` prop)*

```jsx
import { useState } from 'react'
import HabitCard from './HabitCard.jsx'
import HabitForm from './HabitForm.jsx'

function HabitsSection({ habits, savingHabitIds, onToggleHabit, onAddHabit }) {
  const [isAdding, setIsAdding] = useState(false)
  const remainingCount = habits.filter((habit) => !habit.isComplete).length
  const existingLabels = habits.map((habit) => habit.label.toLowerCase())

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

### 🛠️ Registering the nested routes in `App.jsx`

We'll wire this in alongside the protected-route changes in a moment — first, let's build authentication.

---

## 🎯 The Target: Building a simulated authentication Context

### 🧠 The Concept: Same three-file pattern as Theme — a different bulletin board, same design

We follow the exact same structure from Phase 5, Part 1 (`XContext.js` / `XProvider.jsx` / `useX.js`), because this pattern generalizes cleanly to any kind of shared, app-wide state — not just themes.

> ⚠️ **A critical, expert-level caveat, stated plainly up front:** everything we're about to build is a **simulated, client-side-only** login, suitable for learning routing concepts. It provides zero real security. Any determined user can open DevTools and directly flip our stored `isAuthenticated` value, bypassing this "login" entirely — because **all of our JavaScript, including this exact check, is delivered to and runs inside the user's own browser, which they fully control.** Genuine security requires the *server* to independently verify every sensitive request (typically via a securely-stored session token or cookie), regardless of what the client-side UI does or doesn't show. What we're building here controls **navigation/UI visibility only** — a legitimate and common pattern (e.g., "don't show the admin panel link to non-admins"), but never a substitute for real server-side authorization.

### 🛠️ The Implementation

**File: `src/context/AuthContext.js`**

```javascript
import { createContext } from 'react'

export const AuthContext = createContext(null)
```

**File: `src/context/AuthProvider.jsx`**

```jsx
import { useState, useEffect } from 'react'
import { AuthContext } from './AuthContext.js'

const STORAGE_KEY = 'task-habit-tracker-auth'

function getInitialUser() {
  const stored = localStorage.getItem(STORAGE_KEY)
  return stored ? JSON.parse(stored) : null
}

function AuthProvider({ children }) {
  const [user, setUser] = useState(getInitialUser)

  useEffect(() => {
    if (user) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(user))
    } else {
      localStorage.removeItem(STORAGE_KEY)
    }
  }, [user])

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

**File: `src/context/useAuth.js`**

```javascript
import { useContext } from 'react'
import { AuthContext } from './AuthContext.js'

export function useAuth() {
  const context = useContext(AuthContext)

  if (context === null) {
    throw new Error('useAuth must be called from within an <AuthProvider>.')
  }

  return context
}
```

**File: `src/main.jsx`**

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

---

## 🎯 The Target: Building the `ProtectedRoute` wrapper and `LoginPage`

### 🧠 The Concept: A bouncer at the door, and a sign-in desk that remembers where you were headed

`ProtectedRoute` acts as a bouncer standing in front of a specific route: if you're not authenticated, it redirects you to `/login` *instead of* rendering the protected content — using React Router's `<Navigate>` component, which is the declarative, component-based way to redirect (as opposed to imperatively calling a "navigate" function). Critically, it also remembers **where you were trying to go**, stored in the navigation state, so that after a successful login, we can send you directly back there instead of dumping you on the homepage.

### 🛠️ The Implementation

**File: `src/components/ProtectedRoute.jsx`**

```jsx
import { Navigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/useAuth.js'

function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth()
  const location = useLocation() // the URL the user was AT when this rendered

  if (!isAuthenticated) {
    // `replace` means this redirect doesn't add a new entry to browser
    // history — pressing Back from /login won't bounce the user right
    // back to the protected page they were just denied.
    // `state` attaches extra data to this navigation, retrievable on the
    // other end via useLocation().state — this is how LoginPage will know
    // where to send the user back to after they log in.
    return <Navigate to="/login" replace state={{ from: location }} />
  }

  return children
}

export default ProtectedRoute
```

**File: `src/pages/LoginPage.jsx`**

```jsx
import { useActionState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/useAuth.js'
import FormTextInput from '../components/FormTextInput.jsx'
import SubmitButton from '../components/SubmitButton.jsx'

function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate() // returns a function for PROGRAMMATIC navigation
  const location = useLocation()

  // Read back whatever ProtectedRoute stashed in navigation state. Falls
  // back to "/" for the case where someone visits /login directly, with
  // no prior redirect having happened.
  const from = location.state?.from?.pathname || '/'

  async function loginAction(previousState, formData) {
    const rawUsername = formData.get('username')
    const username = typeof rawUsername === 'string' ? rawUsername.trim() : ''

    if (username.length === 0) {
      return { error: 'Please enter a username.' }
    }

    // Simulated auth delay — a real app would call a real backend here.
    await new Promise((resolve) => setTimeout(resolve, 500))

    login(username)
    navigate(from, { replace: true }) // send the user right back where they were headed
    return { error: null }
  }

  const [state, formAction] = useActionState(loginAction, { error: null })

  return (
    <div className="page login-page">
      <section className="dashboard-section login-card">
        <h2>Log In</h2>
        <p className="settings-description">
          This is a simulated login for demonstrating protected routes — any
          non-empty username works. It is not real authentication.
        </p>
        <form action={formAction} className="inline-form-group">
          <div className="inline-form">
            <FormTextInput name="username" placeholder="Enter any username" />
            <SubmitButton idleLabel="Log In" pendingLabel="Logging in…" />
          </div>
          {state.error && <p className="form-error">{state.error}</p>}
        </form>
      </section>
    </div>
  )
}

export default LoginPage
```

Update `SettingsPage` to display the logged-in user and add a logout button — safe to assume `user` is non-null here, since this component only ever renders while wrapped by `ProtectedRoute`:

**File: `src/pages/SettingsPage.jsx`**

```jsx
import { useTheme } from '../context/useTheme.js'
import { useAuth } from '../context/useAuth.js'

function SettingsPage() {
  const { theme, toggleTheme } = useTheme()
  const { user, logout } = useAuth()

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
        <h2>Account</h2>
        <p className="settings-description">
          Logged in as <strong>{user.username}</strong>. This page is
          protected — visiting it while logged out redirects to a login screen.
        </p>
        <button type="button" className="retry-button" onClick={logout}>
          Log Out
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

### 🛠️ The Implementation: Wiring nested routes, `/login`, and `ProtectedRoute` into `App.jsx`

**File: `src/App.jsx`** *(only the imports and the `<Routes>` block change — everything above it, all the state/handlers, stays exactly as it was at the end of Phase 6, Part 1)*

```jsx
import { useReducer, useState, useEffect, useOptimistic, startTransition } from 'react'
import { Routes, Route } from 'react-router-dom'
import Navbar from './components/Navbar.jsx'
import Toast from './components/Toast.jsx'
import ProtectedRoute from './components/ProtectedRoute.jsx'
import DashboardPage from './pages/DashboardPage.jsx'
import TasksPage from './pages/TasksPage.jsx'
import HabitsLayout from './pages/HabitsLayout.jsx'
import HabitsPage from './pages/HabitsPage.jsx'
import HabitDetailPage from './pages/HabitDetailPage.jsx'
import SettingsPage from './pages/SettingsPage.jsx'
import LoginPage from './pages/LoginPage.jsx'
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

        {/* Nested routes: HabitsLayout renders the shared "frame" and
            receives the data ONCE; its two children share it via Outlet
            context, without App.jsx needing to know which one is active. */}
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

        {/* Settings is now gated: ProtectedRoute decides, on every render,
            whether to actually show SettingsPage or redirect to /login. */}
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
      <Toast message={toastMessage} />
    </div>
  )
}

export default App
```

Add CSS for all the new pieces:

**File: `src/index.css`** *(append this block)*

```css
/* --- Habit card details link --- */

.details-link {
  font-size: 0.8rem;
  color: var(--color-accent);
  text-decoration: none;
  white-space: nowrap;
}

.details-link:hover {
  text-decoration: underline;
}

/* --- Habit detail page --- */

.breadcrumb-link {
  display: inline-block;
  margin-bottom: 0.75rem;
  font-size: 0.85rem;
  color: var(--color-accent);
  text-decoration: none;
}

.breadcrumb-link:hover {
  text-decoration: underline;
}

.habit-detail-streak {
  font-size: 1.1rem;
  color: #a45c00;
}

/* --- Login page --- */

.login-page {
  max-width: 420px;
  margin: 2rem auto 0;
}

.login-card h2 {
  margin-top: 0;
}
```

### ✅ The Verification

Save every file. Confirm both `npm run dev` and `npm run server` are running.

**Testing nested routes and URL params:**

1. Go to `localhost:5173/habits`. Confirm the full habit list still renders exactly as before (this is the `index` route matching).
2. Click **"Details"** on any habit card. Confirm the URL updates to something like `localhost:5173/habits/3`, and the page swaps to show that habit's name, streak, completion status, and a "Mark as Done"/"Mark as Not Done" button.
3. Click **"Mark as Done"** (or "Not Done"). Confirm the status text updates, and — since this calls the exact same `onToggleHabit` used everywhere else — it genuinely persists via our optimistic-update + server-save pipeline from Phase 4.
4. Click **"← Back to Habits"**. Confirm you return to the full list, and the habit you just toggled reflects its new state there too.
5. Manually navigate to `localhost:5173/habits/999999` (an id that doesn't exist). Confirm you see **"We couldn't find that habit"** with a working back link, rather than a crash.

**Testing protected routes:**

6. If you're currently logged in from earlier testing, click **"Log Out"** on the Settings page first (or open DevTools → Application/Storage → Local Storage → delete the `task-habit-tracker-auth` key, then refresh).
7. Click **Settings** in the Navbar. Confirm you're immediately redirected to `/login`, showing our login form — you never see the Settings page content at all.
8. Type any username (e.g., `"alex"`) and click **"Log In"**. After the brief simulated delay, confirm you're redirected **directly back to `/settings`** (not to the homepage) — proof that `location.state.from` correctly round-tripped through the redirect.
9. Confirm the Account section now shows **"Logged in as alex."**
10. Click **"Log Out."** Confirm you're **immediately** redirected to `/login` again — notice we never called `navigate()` inside the `logout` function itself; this redirect happens purely because `ProtectedRoute` re-evaluates `isAuthenticated` (via Context) on every render, and reacts the instant that value changes to `false`. This is the same declarative philosophy from Phase 1, Part 1, now applied to access control.
11. Refresh the browser entirely while logged in (log in again if needed first). Confirm you remain logged in after the refresh — proof our `localStorage` persistence in `AuthProvider` is working, exactly like `ThemeProvider`'s did in Phase 5.

---

## 📚 Reference Section: Phase 6, Part 2

### `useParams`, `useOutletContext`, `useNavigate`, `useLocation` — full quick reference

| Hook | Returns | Used for |
|---|---|---|
| `useParams()` | An object of `{ paramName: "value" }` pairs, always strings | Reading dynamic URL segments like `:habitId` |
| `useOutletContext()` | Whatever value the nearest ancestor `<Outlet context={...}>` provided | Passing data down through nested routes without prop drilling |
| `useNavigate()` | A function: `navigate(path, options?)` | Redirecting programmatically (e.g., after a login Action completes) |
| `useLocation()` | An object describing the current URL (`pathname`, `search`, `state`, etc.) | Reading where the user currently is, or data attached via a previous `<Navigate state={...}>` |

### `<Navigate>` vs. `useNavigate()` — declarative vs. imperative redirects

* **`<Navigate to="..." />`** — a component you `return` directly from your render logic (as `ProtectedRoute` does). Use this when "should we redirect?" is a direct function of the current render — a pure, declarative check.
* **`navigate(path)`** (from `useNavigate()`) — a function you *call*, typically inside an event handler or after an async operation completes (as `LoginPage` does, after a successful login). Use this when the redirect is a *response to an action*, not something decidable purely from render-time conditions.

### Why client-side route protection is a UI convenience, not real security (worth repeating)

This bears repeating clearly, since it's a genuinely common point of real-world confusion: our `ProtectedRoute` prevents the *React component* for Settings from ever rendering when logged out — but it does **nothing** to protect the underlying data. In our app, habits/tasks aren't behind any login at all (by design, to keep this exercise focused specifically on routing) — but even if they were, merely hiding a page's *UI* client-side would not stop someone from directly calling our API endpoints (`fetch('http://localhost:4000/habits')`) with no login step involved whatsoever, since nothing on the `json-server` side checks for authentication at all. A production app needs the **server** to reject unauthorized requests, regardless of what any particular client happens to show or hide. Treat client-side route protection purely as a UX tool — showing the right screens to the right users — never as your actual security boundary.

### Common errors & fixes when working with nested routes and protected routes

| Symptom | Likely cause | Fix |
|---|---|---|
| `useOutletContext` returns `undefined`, causing a destructuring crash | The component isn't actually rendered as a *child route* of the layout providing the context (e.g., rendered directly instead of via nested `<Route>`) | Confirm the route hierarchy in `App.jsx` genuinely nests the child routes inside the parent `<Route>` |
| Clicking "Details" navigates, but the detail page shows "couldn't find that habit" for a habit that clearly exists | Comparing `habit.id === habitId` directly (number vs. string mismatch) | Compare with `String(habit.id) === habitId` |
| Visiting `/habits` shows nothing at all | Forgot the `index` prop on the list route, or mismatched `path` | Confirm `<Route index element={<HabitsPage />} />` is written exactly this way, nested inside the `/habits` parent `<Route>` |
| Redirect to `/login` works, but after logging in you land on `/` instead of the original page | `location.state` wasn't passed through `<Navigate>`, or `LoginPage` isn't reading `location.state?.from?.pathname` correctly | Confirm `ProtectedRoute` passes `state={{ from: location }}`, and `LoginPage` reads `location.state?.from?.pathname` |
| Staying logged in after refresh doesn't work | `AuthProvider`'s `localStorage` read/write logic missing, or `AuthProvider` not wrapping `<App />` in `main.jsx` | Confirm `AuthProvider` is present in `main.jsx` and its `useEffect`/`getInitialUser` logic matches `ThemeProvider`'s pattern |
| `useAuth must be called from within an <AuthProvider>` | A component using `useAuth` renders outside `<AuthProvider>` | Confirm `<AuthProvider>` wraps `<App />` in `main.jsx` |
