# Phase 8: Quality
# Part 1: Testing Components with Vitest & React Testing Library

## Introduction: What we're doing in this part

Every verification step in this entire series so far has required *you* — a human — to open a browser, click things, and visually confirm the result. That's how you learn, but it doesn't scale: imagine making one small change to `HabitCard` next month and needing to manually re-click through every single feature in this app to confirm nothing broke. In this part, you will:

1. Understand the philosophy behind modern React testing — testing *behavior*, not *implementation*.
2. Install and configure **Vitest** (a test runner) and **React Testing Library** (a toolkit for testing components the way a real user experiences them).
3. Write your first tests for simple, presentational components (`Badge`, `HabitCard`).
4. Test user interactions — clicks, typing, form submission — using `@testing-library/user-event`.
5. Test a custom hook in isolation (`useToggle`), without needing a full component wrapped around it.
6. **Mock** our API layer, so tests run instantly and deterministically, without ever touching our real `json-server`.
7. Add an `npm test` script and understand how to read a failing test's output.

By the end, you'll have a genuine automated safety net — one command that verifies dozens of behaviors across the app in a couple of seconds, without opening a browser at all.

---

## 🎯 The Target: Understanding the testing philosophy

### 🧠 The Concept: Test like a curious user, not like a suspicious inspector reading blueprints

There are two fundamentally different ways to test a component. You could inspect its **internals** — "does this component's internal state variable equal `true`?" — or you could interact with it exactly as a **real user** would: "if I click this checkbox, does the text 'Completed' actually appear on the screen?"

React Testing Library (built on top of a more general tool called `@testing-library/dom`) is opinionated, deliberately and famously, toward the second approach. Its guiding principle, stated directly in its own documentation, is: *"the more your tests resemble the way your software is used, the more confidence they can give you."* This matters practically: if you test internal implementation details (a specific state variable's name, a specific internal function being called), your tests break every time you *refactor* — even when you haven't changed any actual user-facing behavior, exactly like the refactors we did in Phase 7, Part 2. If you test observable behavior instead (what text appears, what happens when you click), your tests only break when real behavior actually changes — which is exactly when you *want* to know.

This is why, throughout this part, you'll never see a test that reaches into a component's `useState` value directly. Every test will instead render the component, interact with it the way a user would (clicking, typing), and assert on what's visible on screen afterward.

---

## 🎯 The Target: Installing and configuring the testing toolchain

### 🧠 The Concept: Four tools, four distinct jobs

* **Vitest** — the **test runner**: it finds test files, runs them, and reports pass/fail. It's built by the Vite team specifically to share Vite's configuration and transformation pipeline, so it understands our JSX/ES modules setup with zero extra configuration — a major reason it's the natural choice for a Vite-based project like ours.
* **`@testing-library/react`** — provides `render()` (mounts a component into a simulated DOM) and `screen` (a set of query functions for finding elements on that simulated screen).
* **`@testing-library/jest-dom`** — adds extra, readable assertions (`.toBeInTheDocument()`, `.toBeDisabled()`) on top of Vitest's built-in ones, specifically designed for asserting on DOM elements.
* **`@testing-library/user-event`** — simulates *real* user interactions (clicking, typing, tabbing) far more realistically than firing raw DOM events by hand — for instance, typing a full string character-by-character, exactly as a real keyboard would.
* **`jsdom`** — a JavaScript implementation of browser APIs (the DOM, `window`, etc.) that runs inside Node.js, giving our tests a simulated browser to render into, without ever launching an actual browser.

### 🛠️ The Implementation: Installation

```bash
npm install -D vitest@2.1.8 jsdom@25.0.1 @testing-library/react@16.1.0 @testing-library/jest-dom@6.6.3 @testing-library/user-event@14.5.2
```

### 🛠️ The Implementation: Configuring Vite/Vitest

Vitest reads configuration from the same `vite.config.js` file Vite itself uses — one config file, understood by both tools.

**File: `vite.config.js`**

```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    // Use jsdom instead of Node's default environment, so our tests have
    // access to `document`, `window`, and other browser-like APIs that
    // React needs in order to render anything at all.
    environment: 'jsdom',
    // Runs before every single test FILE — this is where we'll wire up
    // jest-dom's extra matchers globally, so every test file gets them
    // without needing to import them individually.
    setupFiles: './src/tests/setup.js',
    // Lets us use `describe`, `it`, `expect` etc. as GLOBALS, without an
    // explicit import in every test file — purely a convenience matching
    // what most React testing tutorials and existing codebases expect.
    globals: true,
  },
})
```

**File: `src/tests/setup.js`**

```javascript
// Extends Vitest's `expect` with jest-dom's DOM-specific matchers, like
// .toBeInTheDocument() and .toBeDisabled() — used across every test file
// in this project, without needing to import this in each one individually.
import '@testing-library/jest-dom'
```

Add a dedicated test script to `package.json`:

**File: `package.json`** *(add this line inside the existing `"scripts"` object)*

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint .",
    "preview": "vite preview",
    "server": "json-server --watch db.json --port 4000",
    "test": "vitest"
  }
}
```

### ✅ The Verification

Run:

```bash
npm test
```

**Expected output:** Vitest starts up in **watch mode** (it stays running, automatically re-running tests whenever you save a file) and reports:

```
 No test files found, exiting with code 1
```

This is expected and correct — we haven't written any test files yet. Press `Ctrl+C` to exit for now; we'll return to this command once we have real tests to run.

---

## 🎯 The Target: Writing your first test — `Badge`

### 🧠 The Concept: `render` + `screen` + `expect` — the three-step shape of every test

Every React Testing Library test follows the same three-beat structure: **render** the component into a simulated DOM, **query** for something on the (simulated) screen, and **assert** on what you find. Test files conventionally live directly alongside the file they test, named `ComponentName.test.jsx`.

### 🛠️ The Implementation

**File: `src/components/Badge.test.jsx`**

```jsx
import { render, screen } from '@testing-library/react'
import Badge from './Badge.jsx'

// `describe` groups related tests together under a shared label — purely
// organizational, showing up in the test output as a heading.
describe('Badge', () => {
  // `it` (or its alias `test`) defines one individual test case. Its
  // string argument should read like a sentence describing the expected
  // behavior — a well-named test doubles as documentation.
  it('renders its children text', () => {
    render(<Badge>🔥 5</Badge>)

    // screen.getByText searches the simulated DOM for an element whose
    // text content matches exactly. If nothing matches, this THROWS
    // immediately, failing the test with a helpful error.
    expect(screen.getByText('🔥 5')).toBeInTheDocument()
  })

  it('applies the neutral tone class by default', () => {
    render(<Badge>Test</Badge>)

    const badgeElement = screen.getByText('Test')
    expect(badgeElement).toHaveClass('badge-neutral')
  })

  it('applies a custom tone class when provided', () => {
    render(<Badge tone="streak">🔥 5</Badge>)

    const badgeElement = screen.getByText('🔥 5')
    expect(badgeElement).toHaveClass('badge-streak')
    expect(badgeElement).not.toHaveClass('badge-neutral')
  })
})
```

### ✅ The Verification

```bash
npm test
```

**Expected output:**

```
 ✓ src/components/Badge.test.jsx (3)
   ✓ Badge (3)
     ✓ renders its children text
     ✓ applies the neutral tone class by default
     ✓ applies a custom tone class when provided

 Test Files  1 passed (1)
      Tests  3 passed (3)
```

Now, deliberately break something to see a **failing** test's output — this is a genuinely valuable skill, since you'll read failure output far more often than success output while actually developing. Temporarily change the assertion in the first test to expect the wrong text:

```jsx
expect(screen.getByText('🔥 6')).toBeInTheDocument() // deliberately wrong
```

Save, and look at the Vitest output (still running in watch mode — it re-ran automatically):

```
 ✗ src/components/Badge.test.jsx (3)
   ✗ Badge > renders its children text
     TestingLibraryElementError: Unable to find an element with the text: 🔥 6.
```

Notice the error tells you **exactly** what it was looking for and that it couldn't find it — this is Testing Library's `getByText` deliberately throwing a descriptive error rather than silently returning `null`, so failures are immediately actionable. Revert the change back to `'🔥 5'` and confirm the test passes again.

---

## 🎯 The Target: Testing user interactions — `HabitCard`

### 🧠 The Concept: `user-event` simulates a real person, not a robot dispatching raw events

### 🛠️ The Implementation

**File: `src/components/HabitCard.test.jsx`**

```jsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { vi } from 'vitest'
import HabitCard from './HabitCard.jsx'
import { MemoryRouter } from 'react-router-dom'

// HabitCard renders a <Link> internally (the "Details" link, from Phase 7),
// which requires a Router context to exist above it, or React Router
// throws an error. MemoryRouter is the standard, test-friendly substitute
// for BrowserRouter — it tracks a simulated URL history entirely in
// memory, with no real browser address bar involved.
function renderHabitCard(props) {
  return render(
    <MemoryRouter>
      <HabitCard {...props} />
    </MemoryRouter>
  )
}

describe('HabitCard', () => {
  it('shows an empty checkbox and normal text when incomplete', () => {
    renderHabitCard({ id: 1, label: 'Drink water', streak: 3, isComplete: false, onToggle: vi.fn() })

    expect(screen.getByText('☐')).toBeInTheDocument()
    expect(screen.getByText('Drink water')).not.toHaveClass('card-label-done')
  })

  it('shows a checked box and strikethrough text when complete', () => {
    renderHabitCard({ id: 1, label: 'Drink water', streak: 3, isComplete: true, onToggle: vi.fn() })

    expect(screen.getByText('☑')).toBeInTheDocument()
    expect(screen.getByText('Drink water')).toHaveClass('card-label-done')
  })

  it('shows the "On fire!" indicator only when streak exceeds 7', () => {
    const { rerender } = renderHabitCard({ id: 1, label: 'X', streak: 3, isComplete: false, onToggle: vi.fn() })
    expect(screen.queryByText('On fire!')).not.toBeInTheDocument()

    // rerender lets us re-render the SAME mounted component with new
    // props, exactly like a real prop update would — more realistic
    // than mounting a second, entirely separate instance.
    rerender(
      <MemoryRouter>
        <HabitCard id={1} label="X" streak={12} isComplete={false} onToggle={vi.fn()} />
      </MemoryRouter>
    )
    expect(screen.getByText('On fire!')).toBeInTheDocument()
  })

  it('calls onToggle when the card is clicked', async () => {
    // userEvent.setup() must be called once per test, before rendering —
    // it returns a `user` object whose methods simulate realistic input.
    const user = userEvent.setup()
    const handleToggle = vi.fn() // a "mock function" — records every call it receives

    renderHabitCard({ id: 1, label: 'Drink water', streak: 3, isComplete: false, onToggle: handleToggle })

    // Clicking the label text bubbles up to the card's own onClick,
    // exactly as we deliberately designed and tested manually back in
    // Phase 2, Part 3 — now verified automatically instead of by hand.
    await user.click(screen.getByText('Drink water'))

    expect(handleToggle).toHaveBeenCalledTimes(1)
  })

  it('does NOT call onToggle when the streak badge is clicked', async () => {
    const user = userEvent.setup()
    const handleToggle = vi.fn()

    // window.alert would otherwise pop a real (test-breaking) dialog —
    // we replace it with a harmless mock for the duration of this test.
    window.alert = vi.fn()

    renderHabitCard({ id: 1, label: 'Drink water', streak: 3, isComplete: false, onToggle: handleToggle })

    await user.click(screen.getByText('🔥 3'))

    // This directly verifies the event.stopPropagation() behavior we
    // built and manually tested in Phase 2, Part 3 — now automated.
    expect(handleToggle).not.toHaveBeenCalled()
    expect(window.alert).toHaveBeenCalledWith('🔥 3-day streak! Keep it up.')
  })
})
```

### ✅ The Verification

```bash
npm test
```

**Expected output:** all 5 tests under `HabitCard` pass. Try temporarily removing the `event.stopPropagation()` call from `HabitCard.jsx` (from Phase 2, Part 3) and re-save — confirm the **"does NOT call onToggle when the streak badge is clicked"** test now correctly **fails**, proving this test genuinely exercises real behavior rather than trivially passing regardless. Restore the `stopPropagation()` call afterward and confirm the test passes again.

---

## 🎯 The Target: Testing a custom hook in isolation — `useToggle`

### 🧠 The Concept: `renderHook` gives a hook a "minimal host" to live in, without needing a full component

Hooks can only be called from within a component (recall the Rules of Hooks, Phase 2, Part 1) — so you can't just call `useToggle()` directly inside a test function. `renderHook`, from `@testing-library/react`, solves this by creating an invisible, minimal wrapper component behind the scenes purely to host your hook call, then hands you back the hook's return value for direct assertions.

### 🛠️ The Implementation

**File: `src/hooks/useToggle.test.js`**

```javascript
import { renderHook, act } from '@testing-library/react'
import { useToggle } from './useToggle.js'

describe('useToggle', () => {
  it('defaults to false when no initial value is given', () => {
    const { result } = renderHook(() => useToggle())

    // result.current always reflects the hook's LATEST return value —
    // result.current[0] is `value`, result.current[1] is the handlers object.
    expect(result.current[0]).toBe(false)
  })

  it('respects a custom initial value', () => {
    const { result } = renderHook(() => useToggle(true))
    expect(result.current[0]).toBe(true)
  })

  it('flips the value when toggle() is called', () => {
    const { result } = renderHook(() => useToggle(false))

    // `act` tells React "a state update is about to happen here — please
    // process it fully, synchronously, before I make any assertions."
    // Without it, React may warn that an update happened "outside of act,"
    // and your assertion could run before the re-render actually completes.
    act(() => {
      result.current[1].toggle()
    })

    expect(result.current[0]).toBe(true)
  })

  it('setTrue always sets the value to true, regardless of current state', () => {
    const { result } = renderHook(() => useToggle(false))

    act(() => {
      result.current[1].setTrue()
    })
    expect(result.current[0]).toBe(true)

    act(() => {
      result.current[1].setTrue() // calling it again while already true
    })
    expect(result.current[0]).toBe(true)
  })

  it('setFalse always sets the value to false', () => {
    const { result } = renderHook(() => useToggle(true))

    act(() => {
      result.current[1].setFalse()
    })
    expect(result.current[0]).toBe(false)
  })
})
```

### ✅ The Verification

```bash
npm test
```

**Expected output:** all 5 `useToggle` tests pass. This demonstrates a genuinely valuable testing capability: we verified this hook's entire behavior **without rendering a single piece of UI** — proof that well-extracted custom hooks (Phase 7, Part 2's core lesson) are also independently, cleanly testable, exactly as promised in that part's Reference Section.

---

## 🎯 The Target: Mocking the API layer to test `TaskForm`

### 🧠 The Concept: A mock is a stunt double — convincing enough for the scene, without any real risk

`TaskForm` (Phase 3–4) calls `onAddTask`, which — in our real app — eventually reaches `createTask` in `src/api/tasksApi.js`, which performs a genuine `fetch` call to `json-server`. We do **not** want our tests depending on a real, running server: tests should be fast, reliable, and runnable anywhere (including in an automated CI pipeline, which we'll set up in Phase 9), with zero external dependencies. Vitest's `vi.fn()` (which we've already used for simple callback tracking above) can also fully **replace** an entire imported module's functions with fake, controllable versions — this is called **mocking**.

### 🛠️ The Implementation

**File: `src/components/TaskForm.test.jsx`**

```jsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { vi } from 'vitest'
import TaskForm from './TaskForm.jsx'

describe('TaskForm', () => {
  it('shows a validation error when submitted empty', async () => {
    const user = userEvent.setup()
    const onAddTask = vi.fn()

    render(<TaskForm onAddTask={onAddTask} onCancel={vi.fn()} existingLabels={[]} />)

    await user.click(screen.getByRole('button', { name: /add/i }))

    expect(await screen.findByText('Please enter a task before adding it.')).toBeInTheDocument()
    expect(onAddTask).not.toHaveBeenCalled()
  })

  it('shows a duplicate error for an existing label (case-insensitive)', async () => {
    const user = userEvent.setup()
    const onAddTask = vi.fn()

    render(
      <TaskForm onAddTask={onAddTask} onCancel={vi.fn()} existingLabels={['buy groceries']} />
    )

    // getByPlaceholderText finds our uncontrolled <input> by its
    // placeholder attribute — user.type simulates realistic, one
    // character-at-a-time typing, exactly like a real keyboard.
    await user.type(screen.getByPlaceholderText('What do you need to do?'), 'BUY GROCERIES')
    await user.click(screen.getByRole('button', { name: /add/i }))

    expect(await screen.findByText('That task already exists.')).toBeInTheDocument()
    expect(onAddTask).not.toHaveBeenCalled()
  })

  it('calls onAddTask with the trimmed label for a valid submission', async () => {
    const user = userEvent.setup()
    // onAddTask resolves successfully — mimicking what App.jsx's real
    // handleAddTask does once the (mocked, in real usage) API call succeeds.
    const onAddTask = vi.fn().mockResolvedValue(undefined)

    render(<TaskForm onAddTask={onAddTask} onCancel={vi.fn()} existingLabels={[]} />)

    await user.type(screen.getByPlaceholderText('What do you need to do?'), '  Walk the dog  ')
    await user.click(screen.getByRole('button', { name: /add/i }))

    // waitFor / findBy* both handle the async nature of our Action — the
    // assertion is retried automatically for a short window until it
    // passes or a timeout is reached, since onAddTask resolves asynchronously.
    await vi.waitFor(() => {
      expect(onAddTask).toHaveBeenCalledWith('Walk the dog') // confirms .trim() worked
    })
  })

  it('calls onCancel when the Cancel button is clicked', async () => {
    const user = userEvent.setup()
    const onCancel = vi.fn()

    render(<TaskForm onAddTask={vi.fn()} onCancel={onCancel} existingLabels={[]} />)

    await user.click(screen.getByRole('button', { name: /cancel/i }))

    expect(onCancel).toHaveBeenCalledTimes(1)
  })
})
```

Notice this test file never imports or mocks `tasksApi.js` at all — because `TaskForm` itself doesn't call it directly; it only calls whatever `onAddTask` function its parent hands it, and we simply hand it a `vi.fn()` stand-in. This is a direct, practical payoff of the "container vs. presentational component" separation we established all the way back in Phase 2, Part 1: presentational components (or in this case, a form that only knows about its *reporting* function, not the network) are dramatically easier to test in isolation.

For completeness, let's also demonstrate mocking a real module directly — useful when a component *does* import and call an API function itself.

**File: `src/api/tasksApi.test.js`**

```javascript
import { vi } from 'vitest'

// vi.mock intercepts every import of 'react-dom' — no wait, of THIS
// module path — anywhere it's imported during this test file's run, and
// replaces its exports with fake versions we control below. This must be
// called with a string path (not a variable) due to how Vitest hoists
// this call above all imports internally.
vi.mock('./config.js', () => ({
  API_BASE_URL: 'http://mock-api.test',
}))

describe('tasksApi', () => {
  beforeEach(() => {
    // Replace the real global fetch with a fresh mock before every test,
    // so no test's fetch call leaks into another test's expectations.
    global.fetch = vi.fn()
  })

  it('fetchTasks returns parsed JSON on a successful response', async () => {
    global.fetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve([{ id: 1, label: 'Test task', isComplete: false }]),
    })

    const { fetchTasks } = await import('./tasksApi.js')
    const tasks = await fetchTasks()

    expect(global.fetch).toHaveBeenCalledWith('http://mock-api.test/tasks')
    expect(tasks).toEqual([{ id: 1, label: 'Test task', isComplete: false }])
  })

  it('fetchTasks throws a descriptive error on a failed response', async () => {
    global.fetch.mockResolvedValue({ ok: false, status: 500 })

    const { fetchTasks } = await import('./tasksApi.js')

    // Asserting that an async function REJECTS requires this specific
    // `.rejects` form, rather than a plain try/catch.
    await expect(fetchTasks()).rejects.toThrow('Failed to fetch tasks (status 500)')
  })
})
```

### ✅ The Verification

```bash
npm test
```

**Expected output:** all tests across all four files (`Badge`, `HabitCard`, `useToggle`, `TaskForm`, `tasksApi`) pass — a full summary similar to:

```
 ✓ src/components/Badge.test.jsx (3)
 ✓ src/components/HabitCard.test.jsx (5)
 ✓ src/hooks/useToggle.test.js (5)
 ✓ src/components/TaskForm.test.jsx (4)
 ✓ src/api/tasksApi.test.js (2)

 Test Files  5 passed (5)
      Tests  19 passed (19)
```

Confirm this entire run completes in roughly a second or two, with **`npm run server` not even running** — stop it if it's currently running, and re-run `npm test` to confirm every test still passes, proving our test suite has zero dependency on the real backend.

---

## 📚 Reference Section: Phase 8, Part 1

### The Testing Library query priority — how to pick the right query

Testing Library documents a deliberate **priority order** for how you should look up elements, favoring queries that reflect how real users and assistive technology (like screen readers) actually perceive a page:

| Priority | Query | Example |
|---|---|---|
| 1 (preferred) | `getByRole` | `getByRole('button', { name: /add/i })` |
| 2 | `getByLabelText` | For form fields with associated `<label>` elements |
| 3 | `getByPlaceholderText` | `getByPlaceholderText('What do you need to do?')` |
| 4 | `getByText` | `getByText('Drink water')` |
| Last resort | `getByTestId` | `getByTestId('habit-card-3')` — requires adding a `data-testid` attribute purely for testing, with no real semantic meaning |

`getByRole` is preferred because it tests your app the way assistive technology "sees" it — a button found by its **accessible role and name** is strong evidence it's genuinely usable by everyone, not just sighted mouse users. We reached for `getByText`/`getByPlaceholderText` in several tests above for simplicity and clarity given this series' scope, but real production test suites generally lean more heavily on `getByRole`.

### `getBy*` vs. `queryBy*` vs. `findBy*` — when to use each

| Prefix | Behavior when not found | Behavior with async content | Use for |
|---|---|---|---|
| `getBy...` | Throws immediately | N/A | Asserting something **is** present right now |
| `queryBy...` | Returns `null` (doesn't throw) | N/A | Asserting something is **absent** (`expect(screen.queryByText(...)).not.toBeInTheDocument()`) |
| `findBy...` | Returns a Promise, rejects after a timeout if never found | Automatically retries until found or timeout | Asserting something **will eventually appear** (e.g., after an async Action resolves) |

Using `getBy...` to check for absence is a common mistake — it throws before your `.not.toBeInTheDocument()` assertion even runs, producing a confusing error instead of a clean test failure. Always reach for `queryBy...` specifically when testing that something is *not* there.

### `vi.fn()` and `vi.mock()` — a focused reference

```javascript
const mockFn = vi.fn()               // a bare mock function, records calls
const mockFn2 = vi.fn(() => 42)      // a mock with a fixed return value
const mockFn3 = vi.fn().mockResolvedValue('done')  // resolves as a Promise (for async functions)
const mockFn4 = vi.fn().mockRejectedValue(new Error('fail')) // rejects as a Promise

expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledTimes(2)
expect(mockFn).toHaveBeenCalledWith('exact', 'arguments')

// Replaces an ENTIRE module's exports for the duration of the test file
vi.mock('./someModule.js', () => ({
  someExportedFunction: vi.fn(),
}))
```

### `act()` — why it exists, briefly

`act()` (used in our `useToggle` hook tests) ensures that all of React's state updates, effects, and re-renders triggered by whatever code runs inside it are fully finished and flushed **before** your next line of test code runs. `render()` and `user-event`'s methods already wrap their own internals in `act()` for you automatically — which is why our component tests never needed to call it explicitly. It only needed to appear explicitly in the `useToggle` hook tests, because we were calling the hook's returned functions **directly**, completely outside of any Testing-Library-managed interaction.

### What we deliberately did *not* cover in this part

Testing is a deep field, and a full production test suite for this app would also include: **snapshot testing** (capturing a component's rendered output and flagging any future unintended change), **end-to-end testing** with a tool like Playwright or Cypress (driving an actual real browser through entire user flows, across real page navigations), and **accessibility testing** with tools like `jest-axe`. These are genuinely valuable, and worth exploring once you're comfortable with the fundamentals covered here — but they're deliberately out of scope for this introductory testing part, so the core skills (rendering, querying, interacting, mocking) stay the clear focus.

### Common errors & fixes when testing React components

| Symptom | Likely cause | Fix |
|---|---|---|
| `Unable to find an element with the text: ...` | The text genuinely isn't rendered, or is split across multiple elements/nodes | Confirm the component actually renders that exact text; consider a regex matcher (`getByText(/drink water/i)`) for partial/case-insensitive matches |
| `Warning: An update to X was not wrapped in act(...)` | A state update happened outside of Testing Library's automatic `act()` wrapping (common with hook tests calling functions directly) | Wrap the call in `act(() => { ... })`, as we did throughout `useToggle.test.js` |
| `useNavigate() may be used only in the context of a <Router> component` (or similar Router errors) during a test | The component under test uses a React Router hook/component, but wasn't wrapped in `MemoryRouter` in the test | Wrap the render call in `<MemoryRouter>...</MemoryRouter>`, as we did for `HabitCard` |
| A test passes even though you're sure the underlying behavior is broken | The test isn't actually asserting the thing you think it is (a common risk with overly loose queries) | Deliberately break the real component temporarily (as we did with `stopPropagation`) and confirm the test correctly fails — a valuable habit for validating any new test |
| Mocked `fetch`/module isn't taking effect | `vi.mock()` calls must be at the top level of the file (not inside a test or `beforeEach`), and reference the module by its exact relative path | Move `vi.mock(...)` calls to the top of the file, matching the exact import path used elsewhere |
