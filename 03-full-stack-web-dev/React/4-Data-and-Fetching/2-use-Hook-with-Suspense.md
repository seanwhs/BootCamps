# Phase 4: Data Fetching
# Part 2: Loading/Error States & the `use` Hook with Suspense

## Introduction: What we're doing in this part

At the end of the last part, we deliberately stopped the `json-server` process and watched our app get stuck forever on "Loading your tasks and habits…" — with the actual error only visible if you happened to have DevTools open. That's not acceptable for real users. In this part, you will:

1. Add a genuine, user-facing **error state** with a **retry button** to our existing fetch logic.
2. Learn what an **Error Boundary** is, and why — uniquely among everything in this React 19 series — it's still built using a **class component**, because no hook equivalent exists yet.
3. Learn React 19's **`use`** function: a new way to read the value of a Promise (or Context) directly during render, and how it fundamentally differs from every other hook you've learned so far.
4. Pair `use` with **`Suspense`** — a component that shows fallback UI while something is still loading — to build a self-contained "Quote of the Day" widget.
5. Compare, side by side, the `useEffect`-driven pattern from Part 1 against the `use`+`Suspense` pattern from this part, and understand when each one fits best.

---

## 🎯 The Target: Adding a real error state and retry button to `App.jsx`

### 🧠 The Concept: Every network request has three possible outcomes, and your UI needs to handle all three

So far our `isLoading` state only accounts for two states: loading, or done. But "done" secretly hid a third possibility: done-but-failed. Any UI driven by a network request should explicitly plan for **three** states — loading, success, and error — rather than treating "not loading anymore" as automatically meaning "succeeded."

### 🛠️ The Implementation

**File: `src/App.jsx`**

```jsx
import { useState, useEffect } from 'react'
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'
import { fetchHabits } from './api/habitsApi.js'
import { fetchTasks } from './api/tasksApi.js'

function App() {
  const [habits, setHabits] = useState([])
  const [tasks, setTasks] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [loadError, setLoadError] = useState(null)
  // Bumping this number is our "please try again" signal — it's listed
  // in the effect's dependency array below, so changing it re-runs the fetch.
  const [retryCount, setRetryCount] = useState(0)

  useEffect(() => {
    let isCancelled = false

    async function loadData() {
      // Reset to a clean loading state on every attempt, including retries —
      // otherwise a retry after a failure would show stale error text
      // alongside the loading message.
      setIsLoading(true)
      setLoadError(null)

      try {
        const [habitsData, tasksData] = await Promise.all([
          fetchHabits(),
          fetchTasks(),
        ])

        if (!isCancelled) {
          setHabits(habitsData)
          setTasks(tasksData)
        }
      } catch (error) {
        if (!isCancelled) {
          setLoadError(error)
        }
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    loadData()

    return () => {
      isCancelled = true
    }
  }, [retryCount]) // re-running this effect is now driven by retryCount changing

  function handleRetry() {
    setRetryCount((current) => current + 1)
  }

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

  function handleAddTask(label) {
    const newTask = { id: crypto.randomUUID(), label, isComplete: false }
    setTasks((currentTasks) => [...currentTasks, newTask])
  }

  function handleAddHabit(label) {
    const newHabit = { id: crypto.randomUUID(), label, streak: 0, isComplete: false }
    setHabits((currentHabits) => [...currentHabits, newHabit])
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

Add supporting CSS:

**File: `src/index.css`** *(append this block)*

```css
/* --- Error state --- */

.error-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #444444;
}

.error-detail {
  font-size: 0.85rem;
  color: #999999;
  font-family: monospace;
  margin: 0.5rem 0 1.25rem;
}

.retry-button {
  padding: 0.5rem 1.25rem;
  border: none;
  border-radius: 8px;
  background-color: #1a1a1a;
  color: white;
  font-weight: 600;
  cursor: pointer;
}

.retry-button:hover {
  background-color: #333333;
}
```

### ✅ The Verification

Stop your `npm run server` terminal (Ctrl+C) to simulate an outage, then reload `localhost:5173`.

1. Confirm you now see a genuine, styled error screen: **"😕 We couldn't load your data,"** a monospaced error detail line (something like `TypeError: Failed to fetch`), and a **"Try Again"** button — no more infinite silent loading spinner.
2. Click **"Try Again"** while the server is still stopped. Confirm you briefly see **"Loading your tasks and habits…"** again before returning to the error screen — proving `retryCount` incrementing correctly re-triggered the effect.
3. Now restart the server (`npm run server` in that terminal), and click **"Try Again"** once more. Confirm the dashboard now loads correctly, proving recovery works end-to-end without a full page reload.

---

## 🎯 The Target: Understanding Error Boundaries

### 🧠 The Concept: An Error Boundary is a circuit breaker for a section of your UI

The error handling we just built is manual — we, the developers, wrote explicit `try/catch` logic around one specific fetch. But what about errors we *didn't* anticipate — a bug in a component's render logic that throws an exception? By default, an uncaught error during rendering crashes React's **entire** component tree, leaving a blank white screen for the whole app, no matter how small or unrelated the failing component was.

An **Error Boundary** is a special component that "catches" JavaScript errors thrown anywhere in its descendant tree during rendering, and displays fallback UI instead of letting the crash propagate further up and take down the whole app — exactly like a circuit breaker in a building's electrical panel trips to protect the rest of the house when one specific circuit has a fault, rather than cutting power to the entire building.

Here's the one genuinely unusual fact worth calling out clearly, since this entire series has been function-component-first: **as of React 19, Error Boundaries can only be implemented as class components.** There is currently no hook (`useErrorBoundary` does not exist) that provides this capability. This isn't an oversight — catching errors during rendering requires hooking into specific class-component lifecycle methods (`static getDerivedStateFromError`, `componentDidCatch`) that have no function-component equivalent yet. In practice, nearly every real-world codebase either writes this one small class component from scratch (as we're about to) or imports a tiny, well-tested package like `react-error-boundary` that wraps this exact pattern — you will essentially never need to write a *second* class component anywhere else in modern React.

### 🛠️ The Implementation

**File: `src/components/ErrorBoundary.jsx`**

```jsx
import { Component } from 'react'

// This is the one and only class component in our entire series.
// It exists purely because catching render errors currently requires
// class-component-only lifecycle methods.
class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false }
  }

  // React calls this automatically if any descendant throws during render.
  static getDerivedStateFromError() {
    return { hasError: true }
  }

  handleRetry = () => {
    // Resetting hasError lets React attempt to render the children again —
    // paired with the `resetKey` prop below to force a truly fresh attempt.
    this.setState({ hasError: false })
    this.props.onRetry?.()
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-state error-state-compact">
          <p>😕 Something went wrong loading this section.</p>
          <button type="button" className="retry-button" onClick={this.handleRetry}>
            Try Again
          </button>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
```

Add a small style variant for this more compact, section-scoped error card:

**File: `src/index.css`** *(append this block)*

```css
/* --- Compact error boundary state --- */

.error-state-compact {
  padding: 1.5rem 1rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}
```

### ✅ The Verification

This component isn't used by anything yet — we'll wire it in shortly, alongside `use` and `Suspense`, where its retry behavior will make complete sense in context.

---

## 🎯 The Target: Understanding the `use` function

### 🧠 The Concept: `use` lets a component "unwrap" a Promise directly while rendering — and, unusually, it can be called conditionally

Every hook we've learned so far (`useState`, `useEffect`, `useActionState`) obeys the strict Rules of Hooks from Phase 2, Part 1: always called at the top level, never inside an `if` or a loop. `use` is different — and deliberately so, which is why React's team gave it a lowercase, non-"hook-shaped" name rather than calling it `useValue` or similar. **`use` can be called conditionally, inside loops, or after early returns** — something no other hook permits.

```jsx
import { use } from 'react'

function QuoteDisplay({ quotePromise }) {
  // `use` suspends this component's rendering until quotePromise resolves,
  // then returns the resolved value directly — no useEffect, no useState
  // needed just to "wait" for this value.
  const quote = use(quotePromise)

  return <p>"{quote.text}" — {quote.author}</p>
}
```

Here's the critical mechanical detail: if the Promise passed to `use` hasn't resolved yet, `use` doesn't return `undefined` or `null` — it **throws** the Promise itself (a special, intentional mechanism, not an error). React catches that thrown Promise and looks upward in the tree for the nearest `<Suspense>` boundary, rendering its `fallback` instead, and automatically retrying once the Promise resolves. If the Promise instead *rejects* (an error), `use` re-throws that actual error, and React looks upward for the nearest **Error Boundary** to catch it. This is exactly why `use`, `Suspense`, and Error Boundaries are designed to be used together — each handles one specific outcome of the underlying Promise.

> 🆕 **New in React 19:** `use` is a brand-new function, not available in any earlier React version. It's also unusual in that it works with two very different things — Promises (what we're using it for here) and Context (which we'll revisit in Phase 5 as an alternative to `useContext`).

> ⚠️ **A critical rule:** never create a brand-new Promise directly inside a component's render logic and immediately pass it to `use` (e.g., `use(fetch(...))` written directly in the component body). Since components can re-render often, this would kick off a brand new network request on every single render, forever. The Promise passed to `use` must be created **once** and remain the *same* Promise reference across re-renders — typically by creating it outside the component (as we're about to do), or via a caching mechanism.

---

## 🎯 The Target: Building the "Quote of the Day" widget with `use` + `Suspense`

### 🧠 The Concept: Suspense is a waiting room with a sign on the door

`<Suspense fallback={<Loading />}>` wraps a part of your tree and says: "if anything inside here isn't ready yet, show this fallback sign instead, and swap in the real content the moment it's ready." It's the declarative, built-in alternative to manually tracking an `isLoading` boolean with `useState` — which is exactly the pattern we hand-rolled for the entire dashboard in Part 1.

We'll build a small, self-contained, read-only feature — a daily inspirational quote — specifically because it's a clean example of data that's fetched once and displayed, with no interactive mutation afterward. This is deliberately the sweet spot for `use` + `Suspense`; our habit/task toggling logic remains on the `useEffect` + `useState` pattern from Part 1, and the Reference Section below explains exactly why.

### 🛠️ The Implementation

First, add a quote resource to our backend data:

**File: `db.json`** *(add this key alongside the existing `habits` and `tasks` keys)*

```json
{
  "habits": [
    { "id": 1, "label": "Drink 8 glasses of water", "streak": 5, "isComplete": false },
    { "id": 2, "label": "Read for 10 minutes", "streak": 12, "isComplete": true },
    { "id": 3, "label": "Stretch for 5 minutes", "streak": 1, "isComplete": false }
  ],
  "tasks": [
    { "id": 1, "label": "Finish React tutorial", "isComplete": false },
    { "id": 2, "label": "Buy groceries", "isComplete": true },
    { "id": 3, "label": "Clean the kitchen", "isComplete": false },
    { "id": 4, "label": "Reply to emails", "isComplete": false }
  ],
  "quote": {
    "id": 1,
    "text": "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
    "author": "Will Durant"
  }
}
```

Restart `npm run server` (json-server needs a restart to pick up new top-level keys) and confirm `http://localhost:4000/quote` returns that object directly (not wrapped in an array — json-server treats a top-level object, rather than an array, as a "singular resource").

Now, the fetch function itself. We're deliberately adding an **artificial random failure**, clearly commented as a teaching device, so you can reliably witness the Error Boundary catching something without needing to stop the whole server:

**File: `src/api/quoteApi.js`**

```javascript
import { API_BASE_URL } from './config.js'

// FOR TEACHING PURPOSES ONLY: this function has a 40% chance of throwing,
// purely so you can reliably witness our Error Boundary catching a real
// failure without needing to manually stop the server each time. A real
// app would never inject artificial randomness like this.
const ARTIFICIAL_FAILURE_RATE = 0.4

export async function fetchQuote() {
  const response = await fetch(`${API_BASE_URL}/quote`)

  if (!response.ok) {
    throw new Error(`Failed to fetch quote (status ${response.status})`)
  }

  // Simulate a bit of network latency so the Suspense fallback is visible.
  await new Promise((resolve) => setTimeout(resolve, 800))

  if (Math.random() < ARTIFICIAL_FAILURE_RATE) {
    throw new Error('Simulated failure: the quote service hiccuped.')
  }

  return response.json()
}
```

Next, the caching module. This is what guarantees `use` always receives the *same* Promise across re-renders, per the critical rule above — it creates the Promise exactly once, and only creates a new one when we explicitly ask it to (on retry):

**File: `src/api/quoteCache.js`**

```javascript
import { fetchQuote } from './quoteApi.js'

// Module-level variable — created once when this file is first imported,
// and reused across every component render, everywhere in the app, until
// we explicitly reset it. This is what makes it safe to pass to `use`.
let quotePromise = fetchQuote()

export function getQuotePromise() {
  return quotePromise
}

// Called when the user wants to retry after a failure — creates a
// genuinely NEW Promise, so `use` will suspend again and try fresh.
export function resetQuotePromise() {
  quotePromise = fetchQuote()
  return quotePromise
}
```

Now the component that actually consumes this Promise via `use`:

**File: `src/components/QuoteOfTheDay.jsx`**

```jsx
import { use } from 'react'

// QuoteOfTheDay receives the PROMISE itself as a prop, not the resolved
// data — `use` is what performs the "unwrapping." This keeps the caching/
// retry logic (quoteCache.js) fully separate from this component's job,
// which is purely to display a quote once it's available.
function QuoteOfTheDay({ quotePromise }) {
  const quote = use(quotePromise)

  return (
    <section className="dashboard-section quote-section">
      <p className="quote-text">"{quote.text}"</p>
      <p className="quote-author">— {quote.author}</p>
    </section>
  )
}

export default QuoteOfTheDay
```

Finally, wire everything together with `Suspense` and our `ErrorBoundary` inside `Dashboard`:

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
  onToggleHabit,
  onToggleTask,
  onAddHabit,
  onAddTask,
}) {
  // Storing the promise in state means calling resetQuotePromise() and
  // then updating this state is what triggers React to re-render
  // QuoteOfTheDay with a fresh promise, restarting the Suspense cycle.
  const [quotePromise, setQuotePromise] = useState(getQuotePromise)

  function handleQuoteRetry() {
    setQuotePromise(resetQuotePromise())
  }

  return (
    <main className="dashboard">
      {/*
        ErrorBoundary sits OUTSIDE Suspense: Suspense catches the "still
        loading" case (a thrown Promise), while ErrorBoundary catches the
        "it failed" case (a thrown real Error) that `use` re-throws once
        a rejected Promise settles.
      */}
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

      <HabitsSection habits={habits} onToggleHabit={onToggleHabit} onAddHabit={onAddHabit} />
      <TasksSection tasks={tasks} onToggleTask={onToggleTask} onAddTask={onAddTask} />
    </main>
  )
}

export default Dashboard
```

Add styling for the quote widget:

**File: `src/index.css`** *(append this block)*

```css
/* --- Quote of the Day --- */

.quote-section {
  text-align: center;
  font-style: italic;
}

.quote-section-loading {
  color: #999999;
  font-style: normal;
}

.quote-text {
  margin: 0 0 0.4rem;
  font-size: 1.05rem;
}

.quote-author {
  margin: 0;
  font-size: 0.85rem;
  color: #777777;
  font-style: normal;
}
```

### ✅ The Verification

Save every file, and make sure both `npm run dev` and `npm run server` are running (remember to restart `npm run server` after editing `db.json`). Refresh `localhost:5173`.

1. On load, you should briefly see **"Fetching today's quote…"** at the very top of the dashboard — this is our `Suspense` `fallback`, shown automatically while the Promise `use` received is still pending.
2. After roughly 800ms, one of two things happens, essentially at random (our artificial 40% failure rate):
   * **Success:** the fallback is replaced by the real quote: *"We are what we repeatedly do..." — Will Durant*.
   * **Failure:** the fallback is replaced by our `ErrorBoundary`'s fallback UI: **"😕 Something went wrong loading this section"** with a **"Try Again"** button.
3. If you land on the error state, click **"Try Again."** Confirm the loading fallback reappears briefly, followed once again by either the quote or another error — proving the full retry cycle (`ErrorBoundary` → `resetQuotePromise` → new state → `Suspense` fallback → `use` resolving again) works end-to-end.
4. Refresh the page 4–5 times in a row. Because of the random failure rate, you should observe **both** outcomes across your refreshes, confirming the Error Boundary and the happy path are both genuinely reachable, not just theoretical.
5. Confirm the rest of the dashboard (habits, tasks) continues to load and function completely normally regardless of whether the quote widget succeeds or fails — proving the Error Boundary successfully contained the failure to just its own section, exactly like a circuit breaker protecting the rest of the house.

---

## 📚 Reference Section: Phase 4, Part 2

### `use` vs. `useEffect` + `useState` — when to reach for which

| | `useEffect` + `useState` (Part 1's pattern) | `use` + `Suspense` (this part's pattern) |
|---|---|---|
| **Best for** | Data that will be mutated locally afterward (toggling, adding, editing) | Read-only data, fetched once and displayed |
| **Loading UI** | Manually tracked boolean, checked with an early return | Automatic, via the nearest `<Suspense fallback>` |
| **Error UI** | Manually tracked error state, checked with an early return | Automatic, via the nearest Error Boundary |
| **Can be called conditionally?** | No — must follow the Rules of Hooks | Yes — `use` is explicitly exempt from this rule |
| **Re-fetching on demand** | Re-run the effect (e.g., via a dependency like `retryCount`) | Create a brand-new Promise and feed it in as a new prop/state value |
| **Composability across the tree** | Requires prop drilling loading/error booleans to wherever they're needed | Any descendant component can independently `use()` the same Promise; loading/error bubble up automatically |

Our habits/tasks data needed local toggling and adding — a poor fit for a single "resolve once" Promise — so `useEffect` + `useState` remains the right tool there. Our quote widget needed none of that — a textbook fit for `use` + `Suspense`.

### The full mental model of `use` + Suspense + Error Boundary

```
<ErrorBoundary>                          ← catches thrown ERRORS (rejected promises)
  <Suspense fallback={<Loading />}>      ← catches thrown PROMISES (still pending)
    <ComponentThatCallsUse />            ← use(promise) may throw either one
  </Suspense>
</ErrorBoundary>
```

1. `use(promise)` is called during render.
2. If `promise` is still pending, `use` throws the Promise itself → the nearest `Suspense` catches it, shows `fallback`, and automatically re-renders `ComponentThatCallsUse` once the Promise settles.
3. If `promise` eventually **rejects**, `use` re-throws the actual rejection error → the nearest Error Boundary catches it, shows its own fallback.
4. If `promise` **resolves**, `use` simply returns the resolved value, and the component renders normally.

### Why does `use` get to break the Rules of Hooks?

The traditional Rules of Hooks exist because React tracks hook state by **call order**, as covered in Phase 2, Part 1. `use` doesn't store any of its own persistent state between renders the way `useState` does — it's fundamentally just "synchronously unwrap this thing I was handed, or suspend/throw while I can't yet." Because it has no order-dependent bookkeeping of its own to protect, React's team was able to specifically design it to tolerate conditional and loop-based usage — but note this flexibility applies to `use` alone, not to any hook you write yourself.

### Common errors & fixes when working with `use` and Suspense

| Symptom | Likely cause | Fix |
|---|---|---|
| Infinite loop of network requests | A new Promise was created directly during render and passed straight to `use` | Create the Promise once (module scope, or cached in state), never inline during render |
| `Suspense` fallback never disappears | The Promise passed to `use` never resolves or rejects (e.g., a bug in the fetch logic) | Confirm the underlying Promise genuinely settles; check DevTools Network tab |
| Whole app goes blank/white with a console error instead of showing the Error Boundary's fallback | No Error Boundary present anywhere above the failing component | Wrap the relevant section in an `ErrorBoundary`, as we did around `QuoteOfTheDay` |
| Error Boundary fallback shows, but "Try Again" doesn't actually retry | Only reset the boundary's internal `hasError` state, without also supplying a genuinely new Promise/data | Ensure `onRetry` provides a fresh Promise (as `resetQuotePromise` does), not just re-rendering the same failed one |
| `use is not a function` / import error | Imported from `react-dom` instead of `react`, or using a React version below 19 | Import `use` from `'react'`; confirm `react@19` via `npm list react` |
