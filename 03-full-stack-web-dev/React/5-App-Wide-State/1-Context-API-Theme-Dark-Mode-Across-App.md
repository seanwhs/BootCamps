# Phase 5: App-Wide State
# Part 1: The Context API — Theme/Dark Mode Across the App

## Introduction: What we're doing in this part

Back in Phase 1, Part 3, we deliberately felt the pain of **prop drilling** — manually forwarding `habits`/`tasks` data through `App → Dashboard → HabitsSection/TasksSection → HabitCard/TaskCard`, even though `Dashboard` itself never used that data directly. We accepted that pain then, because the alternative (Context) needed a real motivating use case to make sense.

Now we have one: **dark mode**. A theme toggle needs to be readable from practically *everywhere* — the navbar (to render the toggle button itself), every card, every form, every badge — potentially dozens of components, many nested many layers deep. Threading a `theme` prop and a `toggleTheme` function through every single one of them, at every level, purely so a few of them can use it, is exactly the tedious, brittle pattern Context exists to eliminate.

In this part, you will:

1. Understand precisely what Context solves, and what it *doesn't* solve (it's not a replacement for all state management).
2. Create a Context, a Provider, and a custom hook to consume it — the three-piece pattern used in essentially every real React codebase.
3. Add a working dark mode toggle to the Navbar, with the theme readable from any component, at any depth, without a single prop passed for it.
4. Persist the chosen theme to `localStorage`, so it survives a page refresh.
5. Learn about **Context's re-render behavior** — a subtlety that matters once your app grows — via a hands-on demonstration.

---

## 🎯 The Target: Understanding what Context actually is

### 🧠 The Concept: Context is a public bulletin board, not a private note passed hand-to-hand

Recall the "note passed hand-to-hand down a line of people" analogy from Phase 1, Part 3 — that's props, and prop drilling. **Context** is a fundamentally different delivery mechanism: instead of a private note that has to physically pass through every person in the line, imagine a **public bulletin board** pinned up in a shared hallway. Anyone in the building — no matter how many floors up or down — can walk up and read what's posted, directly, without anyone standing between the board and the reader needing to relay anything.

Concretely, Context involves three pieces working together:

1. **`createContext()`** — creates the "bulletin board" itself (an empty structure, initially).
2. **A Provider** (`<SomeContext.Provider value={...}>`) — wraps a part of your tree and "pins a value to the board" for any descendant to read. Whatever you pass as `value` is what gets published.
3. **`useContext(SomeContext)`** — called by any descendant component, at any depth, to "read what's currently pinned to the board."

One critical scoping detail: Context is only readable by components that are **descendants of the Provider** in the actual rendered tree — not by every component in the entire app automatically. This is why we'll wrap our Provider around the whole `<App>` tree in a moment: we want the theme to be readable from genuinely anywhere in our application.

> ⚠️ **A word of caution, stated up front:** Context is excellent for genuinely global, infrequently-changing values — a theme, a logged-in user's identity, a language/locale preference. It is a poor fit for frequently-changing, localized state (like the text currently being typed into one specific form field) — using Context for *everything* just trades "tedious but clear" prop drilling for "invisible and harder to trace" data flow, and can cause unnecessary re-renders across your whole app, as we'll demonstrate at the end of this part.

---

## 🎯 The Target: Creating the Theme Context

### 🧠 The Concept: Separate the "board" from the "sign-up desk" that manages it

We'll build this in three files, each with a distinct, single responsibility — a structure you'll reuse for any future Context you add to a real project:

1. `ThemeContext.js` — just the bulletin board itself (the `createContext()` call).
2. `ThemeProvider.jsx` — the component that manages the actual theme state and "pins" it to the board.
3. `useTheme.js` — a small custom hook (our first genuinely custom hook in this series — we'll cover custom hooks formally in Phase 7, but this is a light, natural introduction) that wraps `useContext`, adding a helpful safety check.

### 🛠️ The Implementation

```bash
mkdir src/context
```

**File: `src/context/ThemeContext.js`**

```javascript
import { createContext } from 'react'

// This file exports ONLY the context object itself — no state, no logic.
// Keeping this separate from ThemeProvider.jsx is a deliberate convention:
// it lets us export just the "shape" of what's shared, independent of HOW
// it's managed, which becomes useful once we discuss fast-refresh caveats
// in the Reference Section below.
//
// We seed it with `null` as a default — this default value is ONLY ever
// used if a component tries to read this context with no Provider above
// it in the tree at all, which our useTheme hook will explicitly guard against.
export const ThemeContext = createContext(null)
```

**File: `src/context/ThemeProvider.jsx`**

```jsx
import { useState, useEffect } from 'react'
import { ThemeContext } from './ThemeContext.js'

const STORAGE_KEY = 'task-habit-tracker-theme'

function getInitialTheme() {
  // Lazy initializer (recall from Phase 2, Part 1's reference section) —
  // this function only runs ONCE, on first render, rather than reading
  // localStorage on every single re-render.
  const storedTheme = localStorage.getItem(STORAGE_KEY)
  if (storedTheme === 'light' || storedTheme === 'dark') {
    return storedTheme
  }

  // Fall back to the user's operating system preference if we've never
  // saved a choice before — a small but genuinely thoughtful UX touch.
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  return prefersDark ? 'dark' : 'light'
}

// ThemeProvider owns the actual theme STATE, and is responsible for
// "publishing" it via <ThemeContext.Provider>. Any component wrapped by
// this (which, once we wire it up, will be our entire app) can read it.
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(getInitialTheme)

  // Whenever theme changes, persist it AND apply it to the real DOM, so
  // our CSS (written in the next step) can react to it globally.
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, theme)
    document.documentElement.setAttribute('data-theme', theme)
  }, [theme])

  function toggleTheme() {
    setTheme((currentTheme) => (currentTheme === 'light' ? 'dark' : 'light'))
  }

  // This object is what every consuming component receives back from
  // useContext(ThemeContext) / our useTheme() hook.
  const contextValue = { theme, toggleTheme }

  return (
    <ThemeContext.Provider value={contextValue}>
      {children}
    </ThemeContext.Provider>
  )
}

export default ThemeProvider
```

**File: `src/context/useTheme.js`**

```javascript
import { useContext } from 'react'
import { ThemeContext } from './ThemeContext.js'

// A small wrapper hook, rather than having every component call
// useContext(ThemeContext) directly. This buys us one real benefit:
// a clear, actionable error if someone forgets to wrap their tree in
// <ThemeProvider>, instead of a confusing crash deep inside some
// unrelated component that tries to destructure `null`.
export function useTheme() {
  const context = useContext(ThemeContext)

  if (context === null) {
    throw new Error('useTheme must be called from within a <ThemeProvider>.')
  }

  return context
}
```

### ✅ The Verification

No visible output yet — we haven't wired the Provider into our tree. Confirm all three files save without errors before continuing.

---

## 🎯 The Target: Wrapping the app in `ThemeProvider`

### 🧠 The Concept: The Provider must sit above everything that needs to read from it

### 🛠️ The Implementation

**File: `src/main.jsx`**

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import ThemeProvider from './context/ThemeProvider.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    {/* ThemeProvider wraps the ENTIRE app, so useTheme() works from
        literally any component anywhere in our tree, at any depth. */}
    <ThemeProvider>
      <App />
    </ThemeProvider>
  </StrictMode>,
)
```

### ✅ The Verification

Save the file. Confirm `localhost:5173` still loads exactly as before — `ThemeProvider` doesn't change any visible output yet on its own; it just makes theme data available. Open DevTools → Elements tab, and confirm the `<html>` tag now has a `data-theme="light"` (or `"dark"`, depending on your OS setting) attribute on it — proof our `useEffect` inside `ThemeProvider` ran and applied it to the real DOM.

---

## 🎯 The Target: Adding the toggle button and dark mode CSS

### 🧠 The Concept: CSS custom properties let one attribute change repaint the entire app

Rather than manually writing two full sets of colors and conditionally applying `className`s everywhere (which would reintroduce exactly the prop-drilling-style tedium we're trying to escape), we'll use **CSS custom properties** (also called CSS variables) — defined once, referenced everywhere, and swapped entirely based on the single `data-theme` attribute our `ThemeProvider` already sets on `<html>`.

### 🛠️ The Implementation

**File: `src/components/Navbar.jsx`**

```jsx
import { useTheme } from '../context/useTheme.js'

function Navbar() {
  // No props needed at all — Navbar reaches directly into the "bulletin
  // board" via our custom hook, regardless of how deep it sits in the tree.
  const { theme, toggleTheme } = useTheme()

  return (
    <nav className="navbar">
      <h1 className="navbar-title">📝 Task & Habit Tracker</h1>
      <button type="button" className="theme-toggle" onClick={toggleTheme}>
        {theme === 'light' ? '🌙 Dark Mode' : '☀️ Light Mode'}
      </button>
    </nav>
  )
}

export default Navbar
```

Now, restructure the top of `index.css` to define color variables for both themes, and update the rest of the file to reference them instead of hardcoded colors:

**File: `src/index.css`** *(replace the entire top portion — from the start of the file through the `body` rule — with this; keep everything below it unchanged)*

```css
/* --- Theme variables --- */
/* :root applies always; [data-theme="dark"] OVERRIDES these variables
   only when that attribute is present on <html>, which ThemeProvider
   controls entirely on its own. No component needs to know these
   variables exist — they just use the color values, and the values
   themselves change meaning based on the current theme. */

:root {
  --color-bg: #f7f7f8;
  --color-surface: #ffffff;
  --color-text: #1a1a1a;
  --color-text-muted: #6b6b6b;
  --color-border: #ececec;
  --color-accent: #2f6fed;
}

[data-theme='dark'] {
  --color-bg: #16171a;
  --color-surface: #232428;
  --color-text: #f2f2f2;
  --color-text-muted: #a0a0a0;
  --color-border: #34363b;
  --color-accent: #6f9bff;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  background-color: var(--color-bg);
  color: var(--color-text);
  transition: background-color 0.2s ease, color 0.2s ease;
}
```

Now update the remaining rules throughout the rest of the file to use these variables instead of their hardcoded hex values. Find and replace each of the following (the surrounding rule structure stays identical — only the color values change):

**File: `src/index.css`** *(apply these targeted replacements throughout the rest of the file)*

```css
.navbar {
  padding: 1.25rem 0;
  border-bottom: 1px solid var(--color-border);
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.dashboard-section {
  background: var(--color-surface);
  border-radius: 12px;
  padding: 1rem 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.card {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.65rem 0.85rem;
  border: 1px solid var(--color-border);
  border-radius: 8px;
}

.card-label-done {
  text-decoration: line-through;
  color: var(--color-text-muted);
}

.remaining-count {
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

.inline-form-input {
  flex: 1;
  padding: 0.5rem 0.65rem;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  font-size: 0.95rem;
  background-color: var(--color-surface);
  color: var(--color-text);
}

.inline-form-cancel {
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-surface);
  cursor: pointer;
  color: var(--color-text-muted);
}

.filter-tab {
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  border-radius: 999px;
  padding: 0.3rem 0.75rem;
  font-size: 0.85rem;
  cursor: pointer;
  color: var(--color-text);
}

.empty-state {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  text-align: center;
  padding: 1rem 0;
  margin: 0;
}

.quote-author {
  margin: 0;
  font-size: 0.85rem;
  color: var(--color-text-muted);
  font-style: normal;
}
```

Finally, add the toggle button's own styling:

**File: `src/index.css`** *(append this block)*

```css
/* --- Theme toggle button --- */

.theme-toggle {
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  color: var(--color-text);
  padding: 0.4rem 0.8rem;
  border-radius: 999px;
  font-size: 0.85rem;
  cursor: pointer;
}

.theme-toggle:hover {
  border-color: var(--color-accent);
}
```

### ✅ The Verification

Save every file. Go to `localhost:5173`.

1. Confirm the navbar now shows a pill button on the right reading **"🌙 Dark Mode"**.
2. Click it. Confirm the **entire page** — background, cards, borders, text, badges — instantly switches to a dark color scheme, and the button now reads **"☀️ Light Mode."**
3. Open DevTools → Elements, and confirm `<html data-theme="dark">` — this single attribute is driving every visual change, via the CSS variables.
4. **Refresh the page.** Confirm it loads directly in dark mode — proving our `localStorage` persistence (read by `getInitialTheme`) survived the reload.
5. Open DevTools → Application tab (Chrome) or Storage tab (Firefox) → Local Storage → `http://localhost:5173`. Confirm a key `task-habit-tracker-theme` exists with value `"dark"`.
6. Click the toggle again to switch back to light mode, and confirm every part of the UI — including deeply nested pieces like the streak Badge and the filter tabs — updates correctly, all without any of those components ever receiving a `theme` prop directly.

---

## 🎯 The Target: Understanding Context's re-render behavior

### 🧠 The Concept: Every consumer of a Context re-renders when its value changes — no matter how deep

Here's a subtlety worth understanding deliberately, since it's a common source of confusion (and occasionally, real performance problems) in larger apps: **when a Context Provider's `value` changes, every single descendant component that calls `useContext` on it re-renders — regardless of how deeply nested it is, and regardless of whether that specific component cares about the part of the value that changed.**

Let's prove this concretely with a small, temporary logging experiment.

### 🛠️ The Implementation: A temporary logging experiment

Temporarily add a console log to `HabitCard.jsx` (a component that, notably, does **not** currently use `useTheme` at all):

**File: `src/components/HabitCard.jsx`** *(temporary logging added — remove after the experiment)*

```jsx
import Badge from './Badge.jsx'

function HabitCard({ label, streak = 0, isComplete = false, isSaving = false, onToggle }) {
  console.log(`HabitCard "${label}" rendered`) // TEMPORARY — remove after experiment

  function handleStreakClick(event) {
    event.stopPropagation()
    window.alert(`🔥 ${streak}-day streak! Keep it up.`)
  }

  return (
    <div className={`card habit-card ${isSaving ? 'is-saving' : ''}`} onClick={onToggle}>
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

### ✅ The Verification

Save the file, open your browser DevTools Console, and clear it. Click the theme toggle button once.

**Expected result:** You'll see `HabitCard "..." rendered` logged once for **every single habit card currently displayed** — even though `HabitCard` never reads `theme` and its own props (`label`, `streak`, `isComplete`) didn't change at all. This is the direct, observable proof of the rule stated above: toggling the theme changed the value published by `ThemeProvider`, and every component *anywhere in ThemeProvider's subtree* that participates in a re-render cascade from its parent re-renders too — in this case, ultimately because `App` itself re-renders as part of this interaction and its entire tree re-renders along with it by default (a behavior we'll address directly with `React.memo` in a later phase, once performance optimization is formally introduced).

To be precise: in this particular case, the re-render is actually happening because `App` (which is *also* wrapped by `ThemeProvider`) re-renders and cascades down, not purely because of Context's own propagation rules — but the underlying lesson holds either way, and is worth internalizing now: **Context is not free, and re-renders it triggers are broad by default.** This is precisely why Context is best reserved for values that are genuinely global and don't change on every keystroke — exactly the "theme" use case we chose for this part, and precisely the wrong fit for something like "the current text typed into a specific input," which changes on every single keystroke.

### 🛠️ Cleanup

Remove the temporary `console.log` line from `HabitCard.jsx`, restoring it to the clean version without that line.

### ✅ The Verification

Save. Confirm the app still functions identically, with no console spam when toggling the theme.

---

## 📚 Reference Section: Phase 5, Part 1

### The three-file Context pattern, summarized

| File | Responsibility |
|---|---|
| `XContext.js` | Just the `createContext()` call — the "empty bulletin board" |
| `XProvider.jsx` | Owns the actual state/logic, and renders `<XContext.Provider value={...}>` |
| `useX.js` | A thin wrapper around `useContext(XContext)`, typically adding a "did you forget the Provider?" error check |

This exact structure — with minor naming variations — is what you'll find in the vast majority of production React codebases using Context, for themes, authentication, feature flags, and more.

### Why is `ThemeContext.js` a plain `.js` file, not `.jsx`?

Recall from Phase 1, Part 2: we use `.jsx` specifically for files containing JSX syntax. `ThemeContext.js` contains no JSX at all — just a single `createContext()` call — so a plain `.js` extension is correct and conventional. `ThemeProvider.jsx`, on the other hand, returns JSX (`<ThemeContext.Provider>...</ThemeContext.Provider>`), so it correctly keeps the `.jsx` extension.

### `useContext` vs. the new `use` function, for reading Context

Back in Phase 4, Part 2, we mentioned that `use` can read Context as well as Promises. For our `useTheme` hook, we could have written:

```javascript
import { use } from 'react'
import { ThemeContext } from './ThemeContext.js'

export function useTheme() {
  const context = use(ThemeContext) // works identically to useContext here
  if (context === null) {
    throw new Error('useTheme must be called from within a <ThemeProvider>.')
  }
  return context
}
```

Both work identically for this straightforward case. The genuine advantage of `use` over `useContext` for reading Context specifically shows up when you need to read a Context **conditionally** (inside an `if`, after an early return, or inside a loop) — something `useContext` cannot do, per the Rules of Hooks from Phase 2, Part 1, but `use` explicitly can, per Phase 4, Part 2's discussion. Since our `useTheme` hook always reads it unconditionally, we've kept `useContext` in our actual implementation — it's the more established, widely-recognized convention for this simple case, though both are equally correct going forward.

### When to reach for Context vs. lifting state vs. a state management library

| Situation | Best tool |
|---|---|
| A few closely related components need shared state | Lift state up to their common parent (Phase 2, Part 1) |
| Truly global, infrequently-changing values (theme, current user, locale) | Context |
| Frequently-changing, localized state (one input's live value) | Local `useState`, kept as close to where it's used as possible |
| Extremely large apps with complex, interdependent global state and frequent updates across many unrelated component subtrees | A dedicated state management library (e.g., Redux, Zustand, Jotai) — genuinely outside this series' scope, but worth knowing these exist for when an app outgrows Context's simplicity |

### Common errors & fixes when working with Context

| Symptom | Likely cause | Fix |
|---|---|---|
| `useTheme must be called from within a <ThemeProvider>` error | A component using `useTheme` is rendered outside `<ThemeProvider>` in the tree, or the Provider was forgotten in `main.jsx` | Confirm `<ThemeProvider>` wraps `<App />` in `main.jsx` |
| Theme toggles correctly but resets on every page refresh | `localStorage` read/write logic missing or broken | Confirm `getInitialTheme` and the persistence `useEffect` are both present and correctly reference `STORAGE_KEY` |
| Some components update on theme toggle, others don't | CSS still uses hardcoded hex colors instead of `var(--color-*)` | Audit remaining hardcoded colors in `index.css` and replace with the appropriate variable |
| Whole app performance noticeably degrades on frequent Context value changes | Using Context for rapidly-changing state (e.g., mouse position, live keystrokes) | Move that specific state back to local `useState`, reserving Context for genuinely global, infrequent values |
| `createContext is not defined` | Missing `import { createContext } from 'react'` | Add the import at the top of the Context file |
