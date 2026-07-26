# Phase 5: App-Wide State
# Part 2: `useReducer` for Complex State Logic

## Introduction: What we're doing in this part

Open `src/App.jsx` and take stock of what's accumulated there since Phase 4: `habits`, `tasks`, `isLoading`, `loadError`, `retryCount`, `toastMessage`, `savingHabitIds`, `savingTaskIds` — eight separate pieces of state, plus six handler functions, several of which update more than one of these pieces in response to the same event (a successful fetch sets both `habits` *and* `tasks` *and* `isLoading`, all at once, in three separate `setX` calls). This works, but it's starting to show a specific kind of strain: the logic for "what happens when data loads successfully" is now split across multiple `set` calls that all have to be remembered and kept in sync by hand, scattered through a growing function.

In this part, you will:

1. Understand what `useReducer` is, and the specific kind of problem it solves that `useState` starts to struggle with.
2. Learn the vocabulary of reducers: **actions**, **dispatch**, and the **reducer function** itself.
3. Consolidate our habit/task data logic (`habits`, `tasks`, `isLoading`, `loadError`) into a single, well-organized reducer.
4. See, concretely, how this makes adding a debugging "action log" trivially easy — a genuine practical payoff, not just a theoretical one.

---

## 🎯 The Target: Understanding the problem `useReducer` solves

### 🧠 The Concept: A reducer is a vending machine; `useState` calls are loose coins scattered on a table

Picture our current `App.jsx` as a table with eight separate piles of coins on it (`habits`, `tasks`, `isLoading`, etc.), and six different people (our handler functions) who each walk up and rearrange *several* piles at once, according to rules that live only in their own heads. It works, but there's no single place you could point to and say "this is the complete rulebook for how our data state changes."

A **reducer** replaces this with something more like a vending machine. You don't reach in and rearrange the snacks yourself — you press a specific, labeled button (this is called **dispatching an action**), and the machine's *single, internal rulebook* (the **reducer function**) decides exactly what the new arrangement of snacks should be, based on the button you pressed and what was in the machine before. Every possible state transition is described in exactly one place, making the *entire* set of "what can happen to this data" rules readable top-to-bottom in one function.

```javascript
const [state, dispatch] = useReducer(reducerFunction, initialState)

// Instead of calling several individual setters...
// setHabits(newHabits); setTasks(newTasks); setIsLoading(false)

// ...you dispatch ONE descriptive action...
dispatch({ type: 'FETCH_SUCCESS', payload: { habits: newHabits, tasks: newTasks } })

// ...and the reducer function is the ONLY place that decides how state responds:
function reducerFunction(state, action) {
  switch (action.type) {
    case 'FETCH_SUCCESS':
      return { ...state, habits: action.payload.habits, tasks: action.payload.tasks, isLoading: false }
    // ...other cases...
  }
}
```

`useReducer` is genuinely not a *different* tool from `useState` under the hood — in fact, `useState` is arguably a simplified special case built on the same underlying idea. Reach for `useReducer` specifically when: (a) several pieces of state tend to change together, in response to the same events, or (b) the "next state" logic is complex enough that describing it as a named, isolated function (rather than several scattered `setX` calls) makes it meaningfully easier to read, test, and reason about.

---

## 🎯 The Target: Building the reducer for our habit/task data

### 🧠 The Concept: One function, one job — deciding the next state, given the current state and an action

Every reducer function has the exact same shape: `(state, action) => newState`. It receives the *current* state and a plain object describing *what happened* (conventionally with a `type` field, and often a `payload` field carrying any relevant data), and must return the *complete new state* — never mutate the existing one, following the exact same immutability discipline from Phase 2, Part 1.

There's one strict rule worth stating clearly: **a reducer function must be pure** — no `fetch` calls, no `setTimeout`, no reading `Date.now()`, nothing that reaches outside itself or produces different output for the same input. All of our actual async work (the `fetch` calls, the artificial delays) stays exactly where it already lives — in `App.jsx`'s handler functions — and those functions `dispatch` a plain action only *after* the async work resolves, carrying whatever data the reducer needs to compute the next state.

### 🛠️ The Implementation

```bash
mkdir src/reducers
```

**File: `src/reducers/dataReducer.js`**

```javascript
// initialDataState describes the shape of everything this reducer manages.
// Notice this consolidates exactly what used to be FOUR separate useState
// calls in App.jsx: habits, tasks, isLoading, and loadError.
export const initialDataState = {
  habits: [],
  tasks: [],
  isLoading: true,
  loadError: null,
}

// dataReducer is the ENTIRE rulebook for how this data can change. Every
// possible transition our app's data can go through is described here,
// in one place — instead of scattered across six different handler
// functions, each calling multiple individual setters.
export function dataReducer(state, action) {
  switch (action.type) {
    case 'FETCH_START':
      // A fresh attempt (including retries) resets any previous error
      // and shows the loading state again.
      return { ...state, isLoading: true, loadError: null }

    case 'FETCH_SUCCESS':
      return {
        ...state,
        habits: action.payload.habits,
        tasks: action.payload.tasks,
        isLoading: false,
      }

    case 'FETCH_ERROR':
      return { ...state, loadError: action.payload, isLoading: false }

    case 'TOGGLE_HABIT':
      // action.payload is the full, server-confirmed habit object,
      // already updated — this mirrors exactly what our old
      // setHabits(currentHabits => currentHabits.map(...)) call did.
      return {
        ...state,
        habits: state.habits.map((habit) =>
          habit.id === action.payload.id ? action.payload : habit
        ),
      }

    case 'TOGGLE_TASK':
      return {
        ...state,
        tasks: state.tasks.map((task) =>
          task.id === action.payload.id ? action.payload : task
        ),
      }

    case 'ADD_HABIT':
      return { ...state, habits: [...state.habits, action.payload] }

    case 'ADD_TASK':
      return { ...state, tasks: [...state.tasks, action.payload] }

    default:
      // Throwing here is a deliberate, valuable safety net: it turns a
      // typo'd action.type (e.g., dispatching 'TOGGLE_HABBIT' by mistake)
      // into an immediate, loud crash during development, instead of a
      // silently ignored action that leaves you confused about why
      // nothing happened.
      throw new Error(`Unknown action type: ${action.type}`)
  }
}
```

### ✅ The Verification

This file has no visible output on its own. Confirm it saves with no errors before continuing to wire it into `App.jsx` next.

---

## 🎯 The Target: Refactoring `App.jsx` to use `useReducer`

### 🧠 The Concept: `dispatch` replaces every individual setter for this consolidated data

### 🛠️ The Implementation

**File: `src/App.jsx`**

```jsx
import { useReducer, useState, useEffect, useOptimistic, startTransition } from 'react'
import Navbar from './components/Navbar.jsx'
import Dashboard from './components/Dashboard.jsx'
import Toast from './components/Toast.jsx'
import { fetchHabits, updateHabit, createHabit } from './api/habitsApi.js'
import { fetchTasks, updateTask, createTask } from './api/tasksApi.js'
import { dataReducer, initialDataState } from './reducers/dataReducer.js'

function App() {
  // ONE useReducer call now replaces what used to be four separate
  // useState calls (habits, tasks, isLoading, loadError).
  const [state, dispatch] = useReducer(dataReducer, initialDataState)
  const { habits, tasks, isLoading, loadError } = state

  // These three remain plain useState — they don't belong in dataReducer
  // because they aren't really "data" in the same sense; they're
  // transient UI/orchestration concerns (a retry trigger, saving-in-flight
  // tracking, and a toast message) that don't share transitions with
  // habits/tasks. This is a deliberate judgment call, not a hard rule —
  // see the Reference Section for more on where to draw this line.
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
        if (!isCancelled) {
          dispatch({ type: 'FETCH_ERROR', payload: error })
        }
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
        // A single dispatch replaces the old setHabits(currentHabits => ...) call.
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

### ✅ The Verification

Save both files. Confirm both `npm run dev` and `npm run server` are running. Refresh `localhost:5173`, and re-run through the **exact same checks from Phase 4, Part 3** — everything should behave identically, since this refactor changes *how* state is organized internally, not *what* the app does:

1. Habits and tasks load correctly on startup.
2. Toggling a checkbox flips it instantly (optimistic), settles after ~700ms, and either persists (survives a refresh) or reverts with a toast (our artificial 30% failure rate).
3. Adding a new task/habit via the forms works, including duplicate-name validation and the pending "Adding…" state.
4. Stopping `npm run server` and refreshing shows the error screen; clicking "Try Again" (after restarting the server) recovers correctly.

Everything should look and behave **exactly as before** — which is precisely the point of a good refactor: the external behavior is unchanged, but the internal organization is now considerably clearer.

---

## 🎯 The Target: Seeing the practical payoff — a one-line action log

### 🧠 The Concept: Because every state change flows through one function, logging *all* of them costs almost nothing

This is the concrete, practical benefit worth experiencing directly: with all our data transitions funneled through one reducer function, we can observe the *entire history* of what happened to our app's data with a single, temporary line of code — something that would have required scattering `console.log` calls across six different handler functions in the old `useState`-per-piece approach.

### 🛠️ The Implementation: A temporary logging wrapper

**File: `src/reducers/dataReducer.js`** *(temporarily add this logging wrapper — remove after the experiment)*

```javascript
export const initialDataState = {
  habits: [],
  tasks: [],
  isLoading: true,
  loadError: null,
}

function dataReducerCore(state, action) {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, isLoading: true, loadError: null }
    case 'FETCH_SUCCESS':
      return { ...state, habits: action.payload.habits, tasks: action.payload.tasks, isLoading: false }
    case 'FETCH_ERROR':
      return { ...state, loadError: action.payload, isLoading: false }
    case 'TOGGLE_HABIT':
      return {
        ...state,
        habits: state.habits.map((habit) => (habit.id === action.payload.id ? action.payload : habit)),
      }
    case 'TOGGLE_TASK':
      return {
        ...state,
        tasks: state.tasks.map((task) => (task.id === action.payload.id ? action.payload : task)),
      }
    case 'ADD_HABIT':
      return { ...state, habits: [...state.habits, action.payload] }
    case 'ADD_TASK':
      return { ...state, tasks: [...state.tasks, action.payload] }
    default:
      throw new Error(`Unknown action type: ${action.type}`)
  }
}

// TEMPORARY — logs every single dispatched action alongside the state
// it produced, giving us a complete, readable history of every data
// change in the app, in the exact order it happened.
export function dataReducer(state, action) {
  const nextState = dataReducerCore(state, action)
  console.log('%cACTION', 'color: #2f6fed; font-weight: bold;', action)
  console.log('  → next state:', nextState)
  return nextState
}
```

### ✅ The Verification

Save the file, open your browser DevTools Console, and clear it. Refresh the page, then toggle a couple of habits and add one new task.

**Expected result:** you should see a clean, chronological log of every single data transition your app went through — `FETCH_START`, `FETCH_SUCCESS` (with the full loaded arrays), `TOGGLE_HABIT` (with the specific saved habit), `ADD_TASK` (with the specific new task) — each paired with the resulting state immediately after. Scroll back through this log and confirm it reads like a complete, ordered story of everything that happened to your data since the page loaded.

This pattern — a single choke point where every state transition can be observed — is precisely the underlying idea behind larger, dedicated tools like Redux DevTools, which do this same thing with a polished visual interface, time-travel debugging, and more. You've just built the essential core of that idea yourself, in about five lines.

### 🛠️ Cleanup

Remove the temporary logging wrapper, restoring `dataReducer.js` to the clean version from the previous step (a single, directly-exported `dataReducer` function, no `dataReducerCore` split, no `console.log` calls).

### ✅ The Verification

Save. Confirm the app still works exactly as expected, with a quiet console during normal use.

---

## 📚 Reference Section: Phase 5, Part 2

### `useReducer` — full API reference

```javascript
const [state, dispatch] = useReducer(reducerFunction, initialArg, init?)
```

* **`reducerFunction(state, action)`** — a pure function returning the next state. Called automatically by React every time `dispatch` is invoked.
* **`initialArg`** — the initial state, *or* the initial argument passed to `init` if provided.
* **`init(initialArg)`** *(optional)* — a function to lazily compute the actual initial state, analogous to `useState`'s lazy initializer from Phase 2, Part 1. Useful when computing the initial state is expensive.
* **`state`** — the current state, exactly as returned by the reducer.
* **`dispatch(action)`** — triggers a re-run of the reducer with the current state and this action, and re-renders the component with whatever it returns.

### Action object conventions

There's no single mandatory shape for an action object, but the overwhelming convention — used across this series and most real codebases — is:

```javascript
{ type: 'SOME_DESCRIPTIVE_NAME', payload: /* whatever data this action needs */ }
```

* `type` should be a string, uppercase-with-underscores by strong convention, describing *what happened* (`'TOGGLE_HABIT'`), not *what to do* (avoid naming it `'SET_HABITS'` if it's really describing a user's toggle action — name actions after real-world events, not implementation details).
* `payload` carries whatever data the reducer needs to compute the next state — it can be omitted entirely for actions that need no extra data (like our `'FETCH_START'`).

### `useState` vs. `useReducer` — a decision guide

| Situation | Prefer |
|---|---|
| A single, independent value (a boolean flag, a string, a number) | `useState` |
| Several values that always change together, in response to the same events | `useReducer` |
| The "next state" logic involves multiple conditions/branches that are hard to express cleanly across several `setX` calls | `useReducer` |
| You want a single, inspectable place that fully describes every possible state transition | `useReducer` |
| The state and its transitions are genuinely simple | `useState` — don't reach for `useReducer` reflexively; it adds a layer of indirection that isn't always worth it for trivial state |

Note that `useReducer` and `useState` are **not** mutually exclusive within one component — as our `App.jsx` demonstrates, it's entirely normal and often the clearest design to use `useReducer` for one cohesive slice of state (our fetched data) while keeping other, less-related pieces (`retryCount`, `toastMessage`) as separate, simple `useState` calls.

### Combining `useReducer` with Context — a preview of a common, larger pattern

A very common pattern in medium-to-large React apps — worth knowing about even though we don't need it for our Tracker — is pairing `useReducer` with the Context API from Part 1: a Provider component calls `useReducer` internally, then publishes both `state` and `dispatch` via Context, letting *any* descendant component read the current data **and** dispatch actions to change it, without prop drilling either direction. This combination is often reached for as a lightweight, no-extra-library alternative to dedicated state management tools like Redux, for apps that have outgrown simple prop passing but don't yet need a full external library.

### Common errors & fixes when working with `useReducer`

| Symptom | Likely cause | Fix |
|---|---|---|
| `Unknown action type: undefined` (or similar) thrown | Dispatched an action object without a `type` field, or with a typo'd field name | Confirm every `dispatch(...)` call includes a correctly-spelled `type` |
| App crashes immediately after a dispatch | The `default` case's `throw` caught a genuine typo in an action's `type` string | Check the exact spelling of the dispatched `type` against the `case` statements in the reducer |
| State doesn't seem to update after dispatching | A `case` block forgot to `return` the new state (falls through, or returns `undefined`) | Ensure every `case` explicitly returns a complete new state object |
| Reducer causes a "Cannot update a component while rendering a different component" warning | Something impure snuck into the reducer (e.g., calling `dispatch` again directly inside the reducer function itself) | Keep reducers pure; perform any follow-up dispatching from `useEffect` or event handlers instead |
| Existing fields disappear from state after a dispatch | Forgot to spread `...state` before overriding specific fields in a `case` | Always start each `case`'s return value with `...state`, then override only what changed |
