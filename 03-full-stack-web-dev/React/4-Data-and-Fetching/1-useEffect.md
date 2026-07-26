# Phase 4: Data Fetching
# Part 1: `useEffect` & Fetching Real Data from an API

## Introduction: What we're doing in this part

Every task and habit in our app so far has come from `sampleData.js` — a file that ships inside our app's own code. That's not how real apps work. A real Task & Habit Tracker needs its data to live somewhere else — a **server** — so it can persist between browser sessions, sync across devices, and be shared with a backend team's own tools.

In this part, you will:

1. Understand what a **side effect** is, and why React needs a special hook (`useEffect`) specifically to handle things that reach *outside* the normal render process.
2. Run a hands-on experiment that shows exactly why **cleanup functions** exist, by deliberately causing (and then fixing) a bug.
3. Stand up a real, local backend server — using a tool called `json-server` — so we have genuine HTTP endpoints to talk to, without writing backend code ourselves.
4. Learn how environment variables work in Vite, and use one to configure our API's URL.
5. Build a small `api/` layer with dedicated fetch functions, and wire `useEffect` into `App.jsx` to load real data on startup.

By the end, refreshing the browser will pull live data from an actual running server process — a genuine client/server split, just like a production app.

---

## 🎯 The Target: Understanding what a "side effect" is

### 🧠 The Concept: Rendering should be a pure calculation; anything else is a side effect

Every component function we've written so far has had one job: take some props/state, and calculate what JSX to return. Given the same inputs, it always produces the same output — no surprises, no reaching outside itself. This property is called being **pure**, and React leans on it heavily (it's part of why React can safely re-run your component functions as often as it needs to, including twice in `StrictMode` during development, specifically to help you notice when this purity has been violated).

A **side effect** is anything a piece of code does that reaches *outside* this pure calculation — talking to a server over the network, starting a timer, manually reading/writing to `localStorage`, directly manipulating a DOM element React doesn't know about. None of these things belong directly inside a component's render logic, because they don't fit the "same input, same output, no external interaction" model.

`useEffect` is React's designated doorway for this: a way to say "after you've finished rendering and updating the screen, go do this side-effecting thing." Think of a component's render as a chef plating a dish — that's the pure, repeatable part. `useEffect` is like the chef stepping away from the plate afterward to phone in tomorrow's ingredient order — a necessary task, but distinctly separate from the act of plating itself, and one that happens *after* the plate is already presentable.

---

## 🎯 The Target: Seeing exactly why cleanup functions exist

### 🧠 The Concept: An effect that starts something ongoing must also know how to stop it

Before touching our real app, let's run a focused, disposable experiment — the same technique we used in Phase 2, Part 2 — to *feel* a bug happen, rather than just read a warning about it.

### 🛠️ The Implementation: A leaking timer

**File: `src/CleanupExperiment.jsx`** *(temporary — we delete this at the end)*

```jsx
import { useState, useEffect } from 'react'

// Ticker starts a repeating timer the moment it mounts, logging every second.
function Ticker() {
  useEffect(() => {
    console.log('Ticker mounted — starting an interval')

    const intervalId = setInterval(() => {
      console.log('tick')
    }, 1000)

    // ⚠️ Try commenting out this return statement (the "cleanup function")
    // to see the bug this part is all about.
    return () => {
      console.log('Ticker unmounting — clearing its interval')
      clearInterval(intervalId)
    }
  }, []) // empty dependency array = run once, when this component first mounts

  return <p>Watch the console — a tick should log every second.</p>
}

function CleanupExperiment() {
  const [showTicker, setShowTicker] = useState(true)

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <button onClick={() => setShowTicker((current) => !current)}>
        {showTicker ? 'Unmount Ticker' : 'Mount Ticker'}
      </button>
      {showTicker && <Ticker />}
    </div>
  )
}

export default CleanupExperiment
```

Temporarily point `main.jsx` at this experiment:

**File: `src/main.jsx`** *(temporary edit)*

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
// import App from './App.jsx'
import CleanupExperiment from './CleanupExperiment.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <CleanupExperiment />
  </StrictMode>,
)
```

### ✅ The Verification

Save both files, open `localhost:5173`, and open your browser DevTools Console.

1. Watch the console — you should see `tick` logged roughly once per second.
2. Click **"Unmount Ticker."** You should immediately see `Ticker unmounting — clearing its interval`, and the ticks should **stop completely**.
3. Click **"Mount Ticker"** again, then **"Unmount Ticker"** several times in a row. Each mount logs one "starting an interval," each unmount logs one "clearing its interval," and ticking always fully stops after unmounting.

Now, remove the `return () => { ... }` cleanup block from inside the effect (leave the `setInterval` call itself in place) and repeat step 3 — mount and unmount the ticker three or four times in a row.

**Expected (buggy) result:** Ticks keep logging **faster and faster** — because every mount starts a brand new interval, but with the cleanup gone, none of the old intervals ever get cancelled when the component unmounts. You now have several invisible, un-stoppable timers all running simultaneously in the background, silently consuming resources — a real, common category of bug called a **memory leak**. This is precisely why an effect that starts anything ongoing (a timer, a subscription, an event listener, or — as we're about to see — an in-flight network request) needs a matching cleanup function that undoes it.

### 🛠️ Cleanup: Revert to our real app

Restore the `return () => { ... }` block in your experiment file (or simply delete the file, since we're done with it), then revert `main.jsx`:

```bash
rm src/CleanupExperiment.jsx
```

**File: `src/main.jsx`** *(restored)*

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

### ✅ The Verification

Save `main.jsx`. Confirm `localhost:5173` shows our real Task & Habit Tracker again, unaffected by the detour.

---

## 🎯 The Target: Standing up a real backend with `json-server`

### 🧠 The Concept: `json-server` turns a JSON file into a real, working REST API

Building a full backend (a database, a server framework, authentication) is an entire skillset of its own — genuinely outside the scope of a React series. **`json-server`** is a small tool that solves this for learning purposes: point it at a plain JSON file, and it instantly serves that file's contents as a real, working REST API over HTTP, complete with support for `GET`, `POST`, `PATCH`, and `DELETE` requests. It's not what you'd run in production, but the `fetch` calls our React app makes to it are **completely real HTTP requests** — indistinguishable, from React's point of view, from talking to a production backend. This lets us learn genuine client/server data fetching without a backend-engineering detour.

### 🛠️ The Implementation: Installing and seeding the server

Install `json-server` as a development dependency (a package only needed while building the app, never shipped to production users — hence `-D`):

```bash
npm install -D json-server@0.17.4
```

We pin the exact version `0.17.4` deliberately — newer major versions of `json-server` changed some behaviors, and this version is the one this tutorial's instructions are verified against.

Now create the data file that `json-server` will serve. This replaces `sampleData.js` as our source of truth — data now lives outside our app's own code, exactly like a real backend's database would:

**File: `db.json`** *(project root — same folder as `package.json`)*

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
  ]
}
```

`json-server` uses each **top-level key** in this file (`habits`, `tasks`) to automatically create a matching REST endpoint — `habits` becomes `/habits`, `tasks` becomes `/tasks`. This is the entire "setup" required.

Add a script to run it conveniently:

**File: `package.json`** *(add this line inside the existing `"scripts"` object)*

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint .",
    "preview": "vite preview",
    "server": "json-server --watch db.json --port 4000"
  }
}
```

### ✅ The Verification

Open a **new terminal tab** (keep your existing `npm run dev` tab running — you now need both processes running side-by-side) and run:

```bash
npm run server
```

**Expected output:**
```
  \{^_^}/ hi!

  Loading db.json
  Done

  Resources
  http://localhost:4000/habits
  http://localhost:4000/tasks

  Home
  http://localhost:4000
```

Now, in a **third terminal tab** (or your browser directly), verify the endpoint works:

```bash
curl http://localhost:4000/habits
```

**Expected output:** a JSON array containing our three habit objects, e.g.:
```json
[
  { "id": 1, "label": "Drink 8 glasses of water", "streak": 5, "isComplete": false },
  { "id": 2, "label": "Read for 10 minutes", "streak": 12, "isComplete": true },
  { "id": 3, "label": "Stretch for 5 minutes", "streak": 1, "isComplete": false }
]
```

You can also simply visit `http://localhost:4000/habits` and `http://localhost:4000/tasks` directly in your browser — you should see the same JSON printed on the page. **Leave this `npm run server` terminal running** for the rest of this series; our app now genuinely depends on it.

---

## 🎯 The Target: Configuring the API URL with environment variables

### 🧠 The Concept: Environment variables let the same code point at different servers, without editing code

Our app currently would need to hardcode `"http://localhost:4000"` directly into its source code to know where to send requests. That's a problem the moment this app needs to run somewhere else — for instance, once we deploy to Vercel in Phase 9, the real backend URL will almost certainly be different. **Environment variables** solve this: they're configuration values that live *outside* your source code, in a file that changes per environment (your laptop vs. a live production server), while the code itself stays identical everywhere.

Vite has one important, deliberate rule here: **only variables prefixed with `VITE_` are exposed to your browser-side code.** Anything in a `.env` file *without* that prefix stays invisible to the client bundle. This is a genuine security boundary — it prevents you from accidentally leaking a server-only secret (like a database password) into code that ships to every visitor's browser. We'll rely on this same rule again in Phase 9 when handling real deployment secrets.

### 🛠️ The Implementation

**File: `.env`** *(project root)*

```
VITE_API_URL=http://localhost:4000
```

Add this to your `.gitignore` — even though this particular value isn't sensitive, building the habit now matters, since later, real secrets will live in files following this same pattern:

**File: `.gitignore`** *(append this line)*

```
.env
```

Since `.env` itself won't be committed to version control, anyone else setting up this project needs to know what variables to create. The convention is an `.env.example` file — committed to the repo — showing the *shape* of what's needed, without real values:

**File: `.env.example`**

```
VITE_API_URL=http://localhost:4000
```

Now create a small config module that reads this value, so the rest of our code never touches `import.meta.env` directly:

**File: `src/api/config.js`**

```javascript
// Vite exposes any environment variable prefixed with VITE_ to browser code
// via the special `import.meta.env` object. Centralizing this one read here
// means the rest of our app just imports API_BASE_URL — if we ever change
// HOW we configure this (a different env var name, a build-time default),
// we only need to update this single file.
export const API_BASE_URL = import.meta.env.VITE_API_URL
```

### ✅ The Verification

Vite only picks up `.env` changes when its process starts — **stop and restart** your `npm run dev` terminal now (Ctrl+C, then `npm run dev` again) so it picks up the new `.env` file.

Add a temporary line to confirm the value is actually reaching your code — open `src/main.jsx` and temporarily add, near the top:

```javascript
console.log('API base URL is:', import.meta.env.VITE_API_URL)
```

Save, check your browser console for `API base URL is: http://localhost:4000`, then remove that temporary line.

---

## 🎯 The Target: Building the `api/` layer

### 🧠 The Concept: Keep "how we talk to the server" separate from "how we display things"

Just like we separated data from display back in Phase 1 (`sampleData.js` vs. components), we now separate *network communication* from *components* entirely. Every component that needs habits or tasks should call a clearly-named function like `fetchHabits()` — it shouldn't need to know or care that this involves `fetch`, URLs, or JSON parsing. This mirrors the `api/` folder we sketched all the way back in Part 0's architecture diagram.

### 🛠️ The Implementation

**File: `src/api/habitsApi.js`**

```javascript
import { API_BASE_URL } from './config.js'

// fetchHabits() hides ALL the networking detail behind one clean function
// name. Any component that calls this doesn't need to know a URL, a fetch
// call, or a status code check are involved at all.
export async function fetchHabits() {
  const response = await fetch(`${API_BASE_URL}/habits`)

  // fetch() only rejects (throws) on true network failures (e.g., no
  // internet connection) — it does NOT throw for HTTP error statuses like
  // 404 or 500. We have to check `response.ok` ourselves and throw
  // manually if something went wrong, so calling code can rely on
  // "if this doesn't throw, the data is good."
  if (!response.ok) {
    throw new Error(`Failed to fetch habits (status ${response.status})`)
  }

  return response.json() // parses the response body as JSON, returns a Promise
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
```

### ✅ The Verification

These functions aren't called by any component yet. Confirm both files save without errors, then continue immediately to the next step, where we actually use them.

---

## 🎯 The Target: Wiring `useEffect` into `App.jsx` to fetch real data

### 🧠 The Concept: "Run this once, right after the component first appears"

We want `App` to fetch habits and tasks from our new API **exactly once** — right when the app first loads — and store the results in state, replacing our old hardcoded imports. This is the single most common `useEffect` pattern in all of React, and it hinges entirely on the **dependency array** (the `[]` at the end of the `useEffect` call):

```jsx
useEffect(() => {
  // this code runs after the component's first render
}, []) // empty array = "this effect depends on nothing, so only run it once"
```

If we omitted the array entirely, the effect would re-run after **every single render** — almost never what you want for a data fetch, since it would trigger an endless cycle of "fetch data → re-render → fetch again → re-render again." If we included variables inside the array (e.g., `[habitId]`), the effect would re-run only when one of those specific values changes between renders — a pattern we'll use for more targeted fetches later in this series.

### 🛠️ The Implementation

**File: `src/App.jsx`**

```jsx
import { useState, useEffect } from 'react'
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'
import { fetchHabits } from './api/habitsApi.js'
import { fetchTasks } from './api/tasksApi.js'

function App() {
  // Both start as empty arrays — before the fetch completes, there's
  // simply nothing to show yet. This also means our existing .map()/
  // .filter() calls in child components never crash on `undefined`.
  const [habits, setHabits] = useState([])
  const [tasks, setTasks] = useState([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // `isCancelled` is our cleanup mechanism for this effect. If App were
    // to unmount (or this effect were to re-run) before the fetch finishes,
    // we don't want a "late" response updating state on a component that's
    // no longer relevant — this flag guards against exactly that race.
    let isCancelled = false

    async function loadData() {
      try {
        // Promise.all runs both requests CONCURRENTLY rather than one
        // after the other, so we wait only as long as the SLOWER of the
        // two requests, not the sum of both.
        const [habitsData, tasksData] = await Promise.all([
          fetchHabits(),
          fetchTasks(),
        ])

        if (!isCancelled) {
          setHabits(habitsData)
          setTasks(tasksData)
        }
      } catch (error) {
        // Full user-facing error handling arrives in the next part —
        // for now, we at least log it so failures aren't silent.
        console.error('Failed to load data:', error)
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    loadData()

    // Cleanup function: runs if App unmounts before loadData finishes.
    return () => {
      isCancelled = true
    }
  }, []) // empty array — this effect runs exactly once, after the first render

  function handleToggleHabit(habitId) {
    // NOTE: this still only updates LOCAL state — it does not yet persist
    // to the server. Refreshing the page will currently reset any toggles.
    // We fix this properly in Phase 4, Part 3, using useOptimistic.
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

Notice the **early return** (from Phase 2, Part 3's toolkit) handling the loading state: while `isLoading` is `true`, `App` returns a completely different, minimal tree — it never even attempts to render `Dashboard` with empty arrays, avoiding a confusing "flash of empty content" before real data arrives.

Add a small style for the loading message:

**File: `src/index.css`** *(append this block)*

```css
/* --- Loading state --- */

.loading-message {
  text-align: center;
  color: #888888;
  padding: 3rem 0;
}
```

Finally, since our data now comes from the server rather than a bundled file, remove the now-unused sample data file:

```bash
rm src/data/sampleData.js
```

### ✅ The Verification

Confirm **both** terminals are running: `npm run dev` (Vite, port 5173) and `npm run server` (json-server, port 4000). Go to `localhost:5173`.

1. On page load, you should briefly see **"Loading your tasks and habits…"** — if your machine is fast, this may only flash for a fraction of a second. To see it more clearly, open DevTools → **Network** tab → set throttling to **"Slow 3G"**, then hard-refresh (Ctrl+Shift+R / Cmd+Shift+R) — you should now see the loading message for a noticeably longer moment before the real dashboard appears.
2. Once loaded, confirm you see the exact same three habits and four tasks as before — except now they're arriving from `db.json` via a real HTTP request, not a bundled JavaScript file.
3. Open DevTools → **Network** tab, filter by "Fetch/XHR," and reload the page. Confirm you see two real network requests: `GET http://localhost:4000/habits` and `GET http://localhost:4000/tasks`, each returning a `200` status.
4. Stop the `npm run server` process (Ctrl+C in that terminal) and reload `localhost:5173`. Confirm the page gets stuck showing **"Loading your tasks and habits…"** forever, and check the browser console — you should see our logged error: `Failed to load data: TypeError: Failed to fetch` (or similar). This confirms our `try/catch` correctly caught the failure rather than crashing the whole app, even though we don't yet show the user anything helpful about it — exactly the gap Part 2 closes next. Restart `npm run server` before continuing.

---

## 📚 Reference Section: Phase 4, Part 1

### `useEffect` — full API reference

```javascript
useEffect(setupFunction, dependencies?)
```

* **`setupFunction`** — runs after the browser has painted the updated screen. May optionally `return` a **cleanup function**.
* **`dependencies`** *(optional array)* — controls when the effect re-runs:
  * **Omitted entirely** — runs after *every* render. Rarely what you want; easy to accidentally create infinite loops if the effect itself triggers a re-render.
  * **`[]` (empty array)** — runs only once, after the initial render ("on mount").
  * **`[a, b]`** — runs after the initial render, and again after any render where `a` or `b` is different from its previous value.
* **The cleanup function** — if returned, React calls it right before the effect runs again (if dependencies changed), and when the component unmounts entirely. Essential for anything "ongoing": timers, subscriptions, event listeners, and (as a defensive pattern) in-flight async operations.

### Why `fetch` needs a manual `response.ok` check

Unlike many other languages' HTTP clients, the browser's built-in `fetch()` function has a specific, easy-to-misunderstand design: it only rejects its Promise (triggering a `catch`) for genuine network-level failures (no connection, DNS failure, CORS block). A `404 Not Found` or `500 Internal Server Error` is still considered a "successful" fetch as far as the Promise is concerned — the request *did* complete, it just came back with a bad status. This is exactly why our `habitsApi.js`/`tasksApi.js` functions manually check `response.ok` (`true` for status codes 200–299) and `throw` ourselves when it's `false` — without this check, a `500` error page's HTML/JSON body would silently be treated as if it were valid habit/task data.

### `AbortController` — a more thorough cancellation tool

Our `isCancelled` flag prevents *state updates* after a component unmounts, but it doesn't actually stop the underlying network request from completing in the background. For a truly thorough cleanup, browsers provide `AbortController`:

```javascript
useEffect(() => {
  const controller = new AbortController()

  fetch(`${API_BASE_URL}/habits`, { signal: controller.signal })
    .then((response) => response.json())
    .then((data) => setHabits(data))
    .catch((error) => {
      if (error.name !== 'AbortError') {
        console.error(error)
      }
    })

  return () => controller.abort() // actually cancels the in-flight request
}, [])
```

We didn't use this in our main implementation to keep the concept count manageable for this part, but it's worth knowing this tool exists — especially for fetches triggered by rapidly-changing inputs (like a search box), where cancelling truly stale requests (not just ignoring their results) meaningfully improves performance.

### `Promise.all` vs. sequential `await`

```javascript
// Sequential — tasksData fetch doesn't even START until habitsData finishes.
// Total time ≈ habits time + tasks time.
const habitsData = await fetchHabits()
const tasksData = await fetchTasks()

// Concurrent — both requests fire at the same time.
// Total time ≈ whichever ONE of the two takes longer.
const [habitsData, tasksData] = await Promise.all([fetchHabits(), fetchTasks()])
```

Use `Promise.all` whenever multiple requests don't depend on each other's results — exactly our case, since habits and tasks are entirely independent resources. One important caveat: `Promise.all` rejects (fails) immediately if **any single one** of its promises rejects, even if the others would have succeeded — a nuance `Promise.allSettled` addresses instead, useful when partial success is acceptable.

### Common errors & fixes when fetching data

| Symptom | Likely cause | Fix |
|---|---|---|
| `Failed to fetch` in console, page stuck loading forever | `json-server` isn't running, or is running on a different port than `.env` specifies | Confirm `npm run server` is running and the port matches `VITE_API_URL` |
| `import.meta.env.VITE_API_URL` is `undefined` | `.env` file missing, misnamed, or dev server wasn't restarted after creating/editing it | Confirm the file is named exactly `.env` in the project root, and restart `npm run dev` |
| CORS error in console (`blocked by CORS policy`) | Rare with `json-server` (it allows all origins by default), but common with real backends | Confirm the backend explicitly allows requests from `http://localhost:5173`; not an issue for our local setup |
| Data loads once, but never updates after editing `db.json` while the app is running | Effect only runs once (`[]` dependency array) — by design, it won't automatically re-fetch | Reload the browser page manually, or wait for Phase 4 Part 3's mutation-based approach |
| `useEffect` runs twice in development, even with `[]` | This is expected under `<StrictMode>` — React intentionally mounts, unmounts, and remounts once in development to help surface missing cleanup functions | Ensure your cleanup function correctly handles being called; this doubling does not happen in production builds |
| `SyntaxError: Unexpected token < in JSON` when parsing a response | The URL pointed at an HTML error page (e.g., a typo'd endpoint) instead of the real JSON API | Double-check the URL, and confirm `response.ok` is being checked before calling `.json()` |
Say **"next"** and I'll generate **Phase 4, Part 2: Loading/Error States & the `use` Hook with Suspense**.
