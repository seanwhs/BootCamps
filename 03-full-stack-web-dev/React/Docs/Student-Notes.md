# React 19 Tutorial Series: Zero to Production
## Student Notes

> **What these notes are:** a condensed, readable companion to the full tutorial — written the way a diligent student would summarize each Part after building it. Not exercises (that's the Workbook), not slides (that's the Deck) — just clear explanations, the key code patterns worth remembering, and the gotchas that trip people up. Read these *after* building each Part, as a way to consolidate what just happened.

---

## PRIMER 1 — How the Web Actually Works

**Big picture:** Every website is a conversation between two computers. Your browser (the **client**) asks; a **server** answers. They speak a shared language called **HTTP**. This request/response dance happens every time you click a normal link — a completely fresh round trip, every time.

**The journey when you hit Enter on a URL:**
1. DNS translates the domain name → an IP address
2. Browser connects and sends an HTTP **request** (a `GET`, usually)
3. Server sends back an HTTP **response** — a **status code** (200 = ok, 404 = not found, 500 = server broke) plus a body
4. Browser renders that body

**The three web languages, and what NOT to confuse them for:**
- **HTML** = structure ("what's here") — headings, paragraphs, buttons
- **CSS** = appearance ("how it looks") — colors, spacing, layout
- **JavaScript** = behavior ("what happens when...") — the only one of the three that can react, decide, remember

React is **just JavaScript**, organized in a particular style. It's not a fourth language.

**Frontend vs. Backend** — this split matters for the whole series:
- Frontend = runs in the user's browser (our entire `src/` folder)
- Backend = runs on a server, handles real data + real security (our `api/` folder, later)

> 🔑 **Remember:** "the internet" and "the web" aren't quite the same thing. The internet is the wiring; the web is HTML+HTTP+browsers running on top of it.

---

## PRIMER 2 — Command Line Crash Course

**Big picture:** A terminal is just a text-based way to give your computer instructions instead of clicking icons. It's not scary — it's precise. Every terminal is always "standing" inside one folder, called your **working directory**.

**The core moves:**
```bash
pwd            # (Mac/Linux) where am I?
cd foldername  # move into a folder
cd ..          # move up one level
cd ~           # jump home from anywhere
ls             # (Mac/Linux) what's here?
mkdir name     # make a new folder
```

**Reading errors calmly:**
- `command not found` → you typed the command name wrong
- `no such file or directory` → the folder/file doesn't exist there, or you mis-typed it
- Neither of these means anything is broken — they're just accurate reports

> 🔑 **Remember:** Many commands in this series (`npm run dev`, `npm run server`, `npm test`) are *supposed* to run forever, watching for changes. That's not a freeze. `Ctrl+C` stops it and gives your prompt back. By Phase 4 you'll routinely have 2–3 terminal tabs open at once, each running one long-lived process.

---

## PRIMER 3 — Setting Up Your Code Editor

**Big picture:** VS Code is the editor this whole series assumes. Get the `code .` command working (opens the current folder in VS Code straight from the terminal) — it's used constantly from Phase 1 onward.

**Layout vocabulary you'll hear repeatedly:**
- **Activity Bar** — thin icon strip, far left
- **Explorer** — the file tree sidebar
- **Editor area** — where open files actually show
- **Integrated Terminal** — toggle with `` Ctrl+` `` / `` Cmd+` ``

**Two extensions to install before Phase 1:**
- **ESLint** — flags likely *logic* mistakes as you type (Rules of Hooks violations, etc.)
- **Prettier** — auto-fixes *formatting* on save (spacing, quote style)

**Turn on format-on-save:** Settings → "Format On Save" ✅ → Default Formatter → Prettier. Test it by typing something ugly like `const x = {a:1,b:2}` and saving — it should snap into clean formatting instantly.

> 🔑 **Remember:** ESLint checks logic. Prettier checks formatting. They're not competing tools — they do two different jobs.

---

## PRIMER 4 — Git & Version Control Basics

**Big picture:** Git takes permanent **snapshots** (commits) of your whole project. Nothing is silently lost once committed. Think of it as a photo album, not a "save over" system.

**Git vs. GitHub:** Git is the tool on your computer. GitHub is a website hosting a copy of your history online — it's what Vercel reads from in Phase 9 to auto-deploy.

**The core rhythm, forever:**
```bash
git init                        # once, at project start
git add .                       # stage what should be in the next snapshot
git commit -m "clear message"   # take the snapshot, permanently
git status                      # run this ALL the time — see what's changed
```

**.gitignore** tells Git what to never track — `node_modules`, `dist`, `.env` files. These are either regeneratable or secret; neither belongs in permanent history.

**Branches** = alternate timelines. `git checkout -b my-feature` lets you experiment without touching `main` at all. If it works, merge it back in. If it doesn't, just abandon it.

**Connecting to GitHub, once per project:**
```bash
git remote add origin <url>
git push -u origin main
```

> 🔑 **Remember:** Good habit to start immediately — commit after finishing each Part of this series, with a message naming what you built (`"Complete Phase 2, Part 1: useState toggling"`). By Phase 9 you'll have a genuinely meaningful history ready to push.

---

## PART 0 — Introduction

**The one app, built the whole way through:** a **Task & Habit Tracker**. Every Phase adds to the *same* app — no throwaway demos.

**Full feature set by the end:** create/toggle/filter tasks and habits, real backend persistence, instant optimistic UI, dark mode, multi-page routing with protected routes, an automated test suite, and a live public deployment.

**The stack, and why each piece:**
| Tool | Job |
|---|---|
| React 19 | The UI library itself |
| Vite | Build tool + dev server, fast HMR |
| React Router | Multiple "pages" in one HTML file |
| Plain CSS → CSS Modules | No framework buy-in required |
| Vitest + Testing Library | Pairs naturally with Vite |
| Vercel | Free Hobby tier, Git-based auto-deploy |

**The "New in React 19" callout** flags six things that didn't exist (in this form) before December 2024: **Actions, useActionState, useFormStatus, useOptimistic, use, ref-as-a-prop**. Each gets introduced exactly when the app needs it — never as abstract trivia.

**Every hands-on step follows the same four beats:**
1. 🎯 The Target — what file/feature
2. 🧠 The Concept — a plain-English analogy first
3. 🛠️ The Implementation — full, real code
4. ✅ The Verification — a concrete way to prove it worked

> 🔑 **Remember:** Deep theory and full API breakdowns are pushed to end-of-phase Reference Sections on purpose — so the hands-on momentum never stalls mid-build.

---
```
[GENERATED: Notes Batch 1 — Primers + Part 0]
[STARTING: Notes Batch 2 — Phase 1: Foundations]
```

## PHASE 1 — Foundations

### Part 1: Why React Exists & Setting Up Vite

**The core problem, before any code:** Manually keeping a screen in sync with changing data — the "repaint the whole wall" problem. Raw DOM manipulation (`document.getElementById(...)`, `.innerHTML = ...`) becomes a tangled mess as an app grows, because *you* have to remember every place the screen needs updating.

**Imperative vs. Declarative — the whole philosophy in one contrast:**
```javascript
// Imperative: YOU manage every step
countEl.textContent = "Count: " + count

// Declarative: describe the result, React syncs the screen
<button onClick={...}>Count: {count}</button>
```
React's core idea: **UI is a function of state.** You describe what the screen should show for the current data; React figures out the minimal DOM changes to get there.

**Setup sequence, memorized:**
```bash
npm create vite@latest task-habit-tracker -- --template react
cd task-habit-tracker
npm install
npm run dev
```

**What each generated file does:**
- `index.html` — the ONE real page; `<div id="root">` is where everything gets injected
- `main.jsx` — entry point; `createRoot(...).render(<App />)` boots React
- `App.jsx` — the root component
- `package.json` — dependency list + npm scripts (`dev`, `build`, `lint`, `preview`)

> 🔑 **Remember:** `node_modules/` is regenerated by `npm install` any time — never commit it. `package-lock.json` is auto-generated and pins *exact* versions — never hand-edit it.

**HMR (Hot Module Replacement):** save a file, browser updates instantly, no manual refresh. This is Vite's headline feature and the reason development feels fast throughout this whole series.

---

### Part 2: JSX Syntax & Your First Components

**The big reveal:** JSX isn't HTML and isn't a template language — it's sugar for plain function calls.
```jsx
<div><h1>Hi</h1></div>
// compiles to:
React.createElement('div', null, React.createElement('h1', null, 'Hi'))
```
You never write `createElement` by hand — but knowing it's there explains *why* JSX has strict rules a browser's forgiving HTML doesn't.

**The four JSX rules, memorized:**
1. Every element must be closed — `<img />`, not `<img>`
2. Exactly one root element per return — wrap siblings in a `<div>` or a Fragment `<>...</>`
3. `className`, not `class` (`class` is a reserved JS word)
4. `{ }` drops into JS **expression** mode — ternaries and function calls are fine; `if`/`for` statements are not

**What a component actually is:** a JS function returning JSX, name **capitalized**. This isn't style — it's how the compiler tells `<div>` (real HTML tag) apart from `<Navbar />` (your function).

**Our first real component tree:**
```
App
├── Navbar
└── Dashboard
    ├── HabitsSection → HabitCard (×N)
    └── TasksSection → TaskCard (×N)
```

> 🔑 **Remember:** One component per file, file name matches component name exactly. This convention pays off hugely once the project reaches dozens of files by Phase 6.

---

### Part 3: Props — Passing Data Into Components

**The problem props solve:** two `<HabitCard />`s were rendering *identical* hardcoded text. Props let a parent "stamp" different data into the same component — literally just function arguments, bundled into one object.

```jsx
<HabitCard label="Drink water" streak={5} />
// compiles conceptually to:
HabitCard({ label: "Drink water", streak: 5 })
```

**Destructuring props, with defaults:**
```jsx
function HabitCard({ label, streak = 0, isComplete = false }) { ... }
```

**The one rule that matters more than any other in this Part: props are read-only.** Never reassign a prop inside the component that received it. If something needs to change over time, that's **state** — the entire subject of Phase 2.

**Prop drilling, felt on purpose:** `App → Dashboard → HabitsSection → HabitCard`. `Dashboard` doesn't even use the data — it just forwards it. Tedious, and deliberately so, to set up why Context (Phase 5) exists.

**The `children` prop** — content written *between* a component's tags:
```jsx
<Badge tone="streak">🔥 {streak}</Badge>
// inside Badge: props.children === "🔥 5"
```
`Badge` doesn't know or care what it wraps — that's the whole point of a generic, reusable wrapper component.

> 🔑 **Remember:** Separating *data* (`sampleData.js`) from *display* (components) means changing the data file alone updates the whole UI — zero component edits required. This pattern recurs for the rest of the series.

---
```
[GENERATED: Notes Batch 2 — Phase 1: Foundations]
[STARTING: Notes Batch 3 — Phase 2: Interactivity]
```

## PHASE 2 — Interactivity

### Part 1: State with useState

**Why a plain variable fails:** a component function re-runs from scratch every render. `let isComplete = false` resets to `false` every single time, no matter how many times you "changed" it — because the whole function body executes fresh. There's no memory without a dedicated tool.

**What useState actually provides — two things a plain variable can't:**
1. A value that **persists** across renders (React stores it outside the function)
2. A way to **notify** React that it changed, triggering exactly the needed re-render

```jsx
const [isComplete, setIsComplete] = useState(false)
```
This is array destructuring — position matters, not names. `useState` always returns `[currentValue, updaterFunction]`, in that order.

**Event handlers: pass the reference, not the call.**
```jsx
onClick={handleClick}     // ✅ correct
onClick={handleClick()}   // ❌ runs immediately during render
onClick={() => handleClick(x)} // ✅ correct, when args are needed
```

**Lifting state up — the single most important architectural lesson of this Part.** A feature (habits remaining count) needed data from *all* cards at once — something no individual `HabitCard`'s private state could provide. Solution: move the state to the closest common parent (`App`), pass the value AND an updater function back down as props. `HabitCard` goes back to being fully "dumb" — pure props in, `onToggle` reported out.

**The immutable update pattern — memorize this shape, you'll type it dozens of times:**
```jsx
setHabits((current) =>
  current.map((habit) =>
    habit.id === habitId
      ? { ...habit, isComplete: !habit.isComplete }
      : habit
  )
)
```
`.map()` builds a *new* array. `{ ...habit, isComplete: ... }` builds a *new* object with one field overridden. Never mutate in place — React detects changes by **reference**, and a mutated-in-place object can silently fail to trigger a re-render.

**Rules of Hooks:** always call at the top level, never conditionally/in loops, only from components or other hooks. Why: React tracks hooks by **call order**, not name. Skipping a hook conditionally shifts every subsequent hook's bookkeeping, causing corrupted state.

> 🔑 **Remember:** Prefer the updater-function form (`setX((prev) => ...)`) whenever the new value depends on the old one — it's safe against React batching multiple updates together.

---

### Part 2: Rendering Lists with .map()

**The problem:** manually writing `habits[0]`, `habits[1]`, `habits[2]` doesn't scale up (new items never show) or down (crashes on missing indices).

**.map() as an assembly line:**
```jsx
{habits.map((habit) => (
  <HabitCard key={habit.id} label={habit.label} ... />
))}
```
One habit in, one `<HabitCard>` out, automatically, for any array length.

**The key prop — a name tag, not a seat number.** React uses `key` to track *which item is which* across re-renders, reorders, insertions, and deletions — never displayed on screen, purely internal bookkeeping.

**The Key Experiment, remembered:** two lists, one keyed by array index, one keyed by `person.id`. Type into an input, then shuffle the list order.
- **Index key:** typed text sticks to the *position* — ends up attached to the wrong person after shuffling
- **id key:** typed text correctly *follows* the right person

This is a real, observable bug — not theoretical. Rule of thumb: use a stable, unique data field (`item.id`) as key whenever a list can reorder, filter, or have items inserted/removed anywhere but the very end.

**Array methods worth having memorized:**
```javascript
arr.map(fn)     // transform every item, same length out
arr.filter(fn)  // keep matching items, may shrink
arr.find(fn)    // first match itself, or undefined
arr.some(fn)    // true if ANY match
arr.every(fn)   // true if ALL match
```
None of these mutate the original array — exactly why they pair so naturally with React's immutability rule.

---

### Part 3: Event Handling & Conditional Rendering

**Event bubbling:** a click ripples outward through every ancestor element, like a pebble in a pond. This is why clicking the streak Badge (nested inside the card) ALSO toggled the whole card — the click bubbled up to the card's own `onClick`.

**The fix:**
```jsx
function handleStreakClick(event) {
  event.stopPropagation() // stops the ripple right here
  window.alert(...)
}
```

**Three conditional rendering patterns, and when to reach for each:**
| Pattern | Use when |
|---|---|
| `condition ? a : b` | Exactly one of two outcomes, always |
| `condition && <X />` | Show something, or nothing at all |
| Early `return` | Bail out entirely / show something completely different |

**The && trap:** `count && <Something />` renders the literal `0` if `count` is `0` (falsy, but React still renders numbers as text). Fix: use a comparison that produces a real boolean — `count > 0 && <Something />`.

**FilterTabs — local state, deliberately not lifted:** only `TasksSection` cares which filter tab is active. Lifting it to `App` would add complexity with zero benefit — the other half of Phase 2 Part 1's lesson: lift state up only as far as it needs to go, no further.

> 🔑 **Remember:** `type="button"` on any non-submit button inside a `<form>` — otherwise it defaults to `type="submit"` and triggers unwanted form submissions. Small detail, easy to forget, causes confusing bugs later in Phase 3.

---
```
[GENERATED: Notes Batch 3 — Phase 2: Interactivity]
[STARTING: Notes Batch 4 — Phase 3: Forms & Data]
```

## PHASE 3 — Forms & Data

### Part 1: Controlled Forms

**Controlled input — the puppet analogy:** the input's `value` comes FROM state; every keystroke writes BACK into that state via `onChange`. React holds the strings; the input just displays what it's told.
```jsx
<input
  value={label}
  onChange={(e) => setLabel(e.target.value)}
/>
```
This unlocks live validation, conditional disabling, and programmatic clearing — all using tools you already know (`useState`).

**Why forms need `preventDefault()`:** a `<form>` reloads the whole page by default on submit — a holdover from before JS handled submissions. `event.preventDefault()` as the very first line of the submit handler stops that.

**Validation pattern, worth memorizing:**
```jsx
const trimmedLabel = label.trim()
const isValid = trimmedLabel.length > 0
// ...
<button disabled={!isValid}>Add</button>
```
`.trim()` matters — without it, three spacebar presses would count as "valid" text.

**Generating IDs for new items:** `crypto.randomUUID()` — a built-in browser function producing a long, essentially-guaranteed-unique string. Never use `array.length + 1` — it produces duplicate IDs once items can be deleted from the middle of a list.

**Adding to a list, immutably:**
```jsx
setTasks((current) => [...current, newTask])
```
Same spread discipline as toggling — never `.push()` directly onto existing state.

---

### Part 2: 🆕 Actions & useActionState

> 🆕 **NEW IN REACT 19.** This whole Part exists to strip out a pile of manual boilerplate: no more hand-wired `isSubmitting` state, no more manual `preventDefault`, no more `onChange` tracking just to read one value at submit time.

**What an Action actually is:** pass a *function* (not a URL string) to a form's `action` prop, and React automatically:
- Prevents default page-reload submission
- Collects every field into a `FormData` object, handed to your function
- Tracks whether that function's Promise is still resolving

**useActionState's shape — memorize this:**
```jsx
const [state, formAction, isPending] = useActionState(actionFn, initialState)

async function actionFn(previousState, formData) {
  const label = formData.get('label').trim()
  if (!label) return { error: 'Required' }
  await doSomething(label)
  return { error: null }
}
```
Note the Action function's signature: **two** arguments now — previous state first, then FormData.

**The input becomes uncontrolled:** no `value`, no `onChange` at all.
```jsx
<input name="label" /> // React reads it once, via formData.get('label'), at submit time
```
Trade-off: if a field genuinely needs live-as-you-type behavior (character counters, live formatting), pair a controlled input WITH an Action — they're not mutually exclusive.

> 🔑 **Remember:** `formData.get(name)` always returns a **string** (or `File`), even for number-looking fields. Convert explicitly (`Number(...)`) when you need a real number.

---

### Part 3: 🆕 useFormStatus

> 🆕 **NEW IN REACT 19.**

**The problem it solves:** `isPending` from Part 2 had to be threaded through as a prop to every nested piece (input, submit button, cancel button) that cared about it — exactly the prop-drilling pain from Phase 1, Part 3, just for pending state instead of data.

**The intercom analogy:** a form is a room with an intercom built into every wall. Any component genuinely *inside* it can ask "are we busy?" without anyone relaying that answer to them.

```jsx
import { useFormStatus } from 'react-dom' // NOTE: react-dom, not react!

function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>{pending ? 'Saving…' : 'Save'}</button>
}
```

**The one non-negotiable rule:** the component calling `useFormStatus` must be a **descendant** of the `<form>` — never the same component that renders the `<form>` element itself. Calling it at the form-rendering level always reports the resting/default state, because it's looking for an *ancestor* form, and there isn't one there.

**Result of extracting FormTextInput, SubmitButton, CancelButton:** `TaskForm.jsx` no longer contains the word "pending" anywhere — all three pieces independently, correctly reflect submission status with zero props passed for that specific purpose.

> 🔑 **Remember, the two-hook comparison:**
> - `useActionState`'s `isPending` — read at the level that OWNS the Action
> - `useFormStatus`'s `pending` — read anywhere NESTED inside the form
> Both reflect the same underlying fact; different access points for different tree depths.

---
```
[GENERATED: Notes Batch 4 — Phase 3: Forms & Data]
[STARTING: Notes Batch 5 — Phase 4: Data Fetching]
```

## PHASE 4 — Data Fetching

### Part 1: useEffect & Fetching Real Data

**Side effects, defined:** anything a piece of code does that reaches OUTSIDE a pure calculation — network calls, timers, direct DOM access, localStorage. Rendering should be pure (same input → same output, no external interaction); `useEffect` is React's designated doorway for the "after render, go do this external thing" work.

**The chef analogy:** plating a dish = pure render. Phoning in tomorrow's ingredient order afterward = a side effect. Related to the render, but distinctly separate from it.

**The Cleanup Experiment, remembered:** a `Ticker` component starts a `setInterval` on mount.
- **With a cleanup function returned** — mount/unmount repeatedly, ticking always fully stops each time. Correct.
- **Without cleanup** — mount/unmount repeatedly, ticks get faster and faster. Every old interval keeps running invisibly in the background. A real **memory leak**.

**Rule:** any effect that starts something *ongoing* (timer, subscription, listener, in-flight request) needs a matching `return () => { /* undo it */ }`.

**json-server** turns a plain `db.json` file into a real REST API (`GET`, `POST`, `PATCH`, `DELETE`) — genuinely real HTTP requests, with zero backend engineering required. `npm run server` runs it on port 4000, alongside `npm run dev` on 5173 — **two terminals, from this Part onward.**

**Environment variables in Vite:** only `VITE_`-prefixed vars reach browser code — a real security boundary preventing accidental secret leakage. `.env` → committed shape only via `.env.example`; the real `.env` (or `.env.development`/`.env.production`) is gitignored.

**The `api/` layer pattern:** components never see `fetch` or URLs directly.
```javascript
export async function fetchHabits() {
  const response = await fetch(`${API_BASE_URL}/habits`)
  if (!response.ok) throw new Error(`Failed to fetch habits (status ${response.status})`)
  return response.json()
}
```
`fetch()` only rejects on true network failure — a 404/500 still "succeeds" as a fetch. You must check `response.ok` yourself and throw.

**The dependency array, memorized:**
- `[]` — run once, on mount
- omitted entirely — runs every render (usually a mistake / infinite loop risk)
- `[x, y]` — reruns when `x` or `y` changes

**Promise.all runs requests concurrently** — total wait time ≈ the slower of the two, not the sum. `isCancelled` flag guards against a real race: a late-arriving response updating state after the component has already moved on.

---

### Part 2: Loading/Error States & use + Suspense

**Plan for three outcomes, always:** loading, success, error. "Not loading anymore" does NOT mean "succeeded."

**Error Boundary — a circuit breaker for a section of UI.** Catches render-time errors in descendants, shows a fallback instead of crashing the whole app. **The one class component in this whole series** — no hook equivalent exists yet for catching render errors (`getDerivedStateFromError` / `componentDidCatch` are class-only lifecycle methods).

> 🆕 **NEW IN REACT 19 — `use()`.** Unwraps a Promise (or Context) directly during render.
```jsx
function QuoteOfTheDay({ quotePromise }) {
  const quote = use(quotePromise)
  return <p>{quote.text}</p>
}
```
- Pending Promise → `use` throws the Promise itself → nearest `<Suspense>` shows its fallback
- Rejected Promise → `use` re-throws the real error → nearest Error Boundary catches it
- Resolved Promise → returns the value directly

**Critical rule:** the Promise passed to `use()` must be the SAME reference across renders — never create a new one inline in the component body (that would refetch on every render, forever). Cache it once, at module scope or in state.

**use + Effect — when to use which:**
- `useEffect` + `useState`: data that gets **mutated locally afterward** (our habits/tasks — toggling, adding)
- `use` + `Suspense`: **read-only, fetched-once** data (our quote widget)

---

### Part 3: 🆕 useOptimistic

> 🆕 **NEW IN REACT 19.**

**Optimistic UI, in one sentence:** show the *hoped-for* result instantly, before the server confirms it — like a "like" button filling in immediately — and roll back automatically if it fails.

```jsx
const [optimisticHabits, applyOptimisticHabit] = useOptimistic(
  habits,
  (current, updated) => current.map((h) => (h.id === updated.id ? updated : h))
)
```
`optimisticHabits` = `habits` (real state) plus anything currently in flight. The instant the transition ends, it reflects real state again — automatically, with **no manual rollback code**, because it's derived fresh every render.

**The non-negotiable requirement:** `applyOptimisticHabit(...)` can ONLY be called inside a **transition**.
```jsx
startTransition(async () => {
  applyOptimisticHabit(optimisticHabit)
  try {
    const saved = await updateHabit(id, { isComplete: ... })
    setHabits((current) => current.map((h) => (h.id === id ? saved : h)))
  } catch (error) {
    showToast('Failed to save.') // deliberately do NOT touch real state here
  }
})
```
Skip the `startTransition` wrapper → a real console warning fires immediately: *"An optimistic state update occurred outside a transition or action."* — proof this requirement is enforced, not decorative.

> 🔑 **Remember:** on failure, never touch the real `habits`/`tasks` state — leaving it untouched is exactly what makes the optimistic value automatically snap back to the last confirmed state.

---
```
[GENERATED: Notes Batch 5 — Phase 4: Data Fetching]
[STARTING: Notes Batch 6 — Phase 5: App-Wide State]
```

## PHASE 5 — App-Wide State

### Part 1: The Context API

**Revisiting the pain, on purpose:** Phase 1's prop drilling was deliberately tedious to set up this exact payoff. Dark mode needs to reach dozens of components at every depth — threading it through every layer manually isn't sustainable.

**The bulletin board analogy:** not a private note passed hand-to-hand (props); a public board anyone can walk up and read directly, no relaying required.

**Three pieces, always built together — memorize this pattern, you'll reuse it forever:**
```javascript
// 1. ThemeContext.js — just the empty board
export const ThemeContext = createContext(null)
```
```jsx
// 2. ThemeProvider.jsx — owns state, publishes it
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(...)
  return <ThemeContext.Provider value={{ theme, toggleTheme }}>{children}</ThemeContext.Provider>
}
```
```javascript
// 3. useTheme.js — a safe wrapper around useContext
export function useTheme() {
  const context = useContext(ThemeContext)
  if (context === null) throw new Error('useTheme must be called from within a <ThemeProvider>.')
  return context
}
```

**Scoping rule:** Context is only readable by DESCENDANTS of the Provider in the actual rendered tree. Wrap it high enough — `main.jsx`, around `<App />`.

**CSS custom properties power the actual theming:**
```css
:root { --color-bg: #f7f7f8; }
[data-theme='dark'] { --color-bg: #16171a; }
```
One `data-theme` attribute change on `<html>` repaints the entire app — no per-component style logic needed.

**The Re-render Experiment, remembered:** logged inside `HabitCard` — a component that doesn't even use `useTheme`. Toggling the theme still caused it to re-render. **Context's re-renders cascade broadly** — not free, and not scoped only to "components that actually care."

> 🔑 **Remember the honest caveat:** Context is a great fit for genuinely global, infrequently-changing values (theme, current user, locale). It's a poor fit for rapidly-changing, localized state (a single input's live keystrokes) — that should stay as local `useState`.

---

### Part 2: useReducer for Complex State Logic

**The sprawl problem:** `App.jsx` had grown to 8 separate `useState` calls and 6 handler functions, several updating multiple pieces of state at once with no single place describing the full rulebook.

**The vending machine analogy:** you don't rearrange the snacks yourself — you press a labeled button (**dispatch an action**), and one internal rulebook (the **reducer**) decides the result.

```javascript
function dataReducer(state, action) {
  switch (action.type) {
    case 'FETCH_SUCCESS':
      return { ...state, habits: action.payload.habits, isLoading: false }
    case 'TOGGLE_HABIT':
      return { ...state, habits: state.habits.map((h) => h.id === action.payload.id ? action.payload : h) }
    default:
      throw new Error(`Unknown action type: ${action.type}`)
  }
}
```

**Consolidated:** `habits`, `tasks`, `isLoading`, `loadError` — four pieces of state that always changed together in response to the same events.

**Stayed as separate useState calls, deliberately:** `retryCount`, `toastMessage`, `savingHabitIds`, `savingTaskIds` — genuinely independent, transient UI concerns, not sharing transitions with the main data.

**Rule:** a reducer must be **pure** — no `fetch`, no `setTimeout`, nothing reaching outside itself. All async work stays in the calling handler function; the handler `dispatch`s a plain action only *after* the async work resolves.

**The practical payoff:** wrap the reducer in one temporary logging line, and you get a complete, chronological history of every single state transition in the app — the essential core idea behind Redux DevTools, built in about five lines.

> 🔑 **Remember:** `useState` and `useReducer` aren't mutually exclusive within one component. Use `useReducer` for one cohesive slice of state that changes together; keep unrelated pieces as plain `useState`.

---
```
[GENERATED: Notes Batch 6 — Phase 5: App-Wide State]
[STARTING: Notes Batch 7 — Phase 6: Navigation]
```

## PHASE 6 — Navigation

### Part 1: React Router — Multi-Page Navigation

**Client-side routing, in one sentence:** a library watches the URL and swaps which components render *without* asking the server for a new HTML document — the receptionist-swapping-the-display analogy, not rebuilding the whole hotel.

**Install and wrap:**
```bash
npm install react-router-dom
```
```jsx
<BrowserRouter>
  <App />
</BrowserRouter>
```
`BrowserRouter` must sit above anything using routing features — it's what actually watches/updates the URL via the browser's History API.

**Routes/Route — a big switch statement for URLs:**
```jsx
<Routes>
  <Route path="/" element={<DashboardPage />} />
  <Route path="/tasks" element={<TasksPage />} />
  <Route path="*" element={<NotFoundPage />} /> {/* MUST be last */}
</Routes>
```

**Link vs. NavLink:**
- `<Link to="/tasks">` — navigates without a full reload
- `<NavLink to="/tasks">` — same, but knows if it's currently "active," for menu highlighting via a function `className`:
```jsx
<NavLink to="/" end className={({ isActive }) => isActive ? 'active' : ''}>Dashboard</NavLink>
```

> 🔑 **Remember the `end` gotcha:** every route starts with `/`, so without `end`, the root NavLink is treated as a prefix match and stays "active" on every page. `end` forces an exact match — needed ONLY on the root-level link.

**Foreshadowed problem, solved properly in Phase 9:** refreshing directly on `/tasks` works in dev (Vite fakes it correctly) but 404s on a naive static production host, since no literal file named `tasks` exists on disk.

---

### Part 2: Nested Routes, URL Params, Protected Routes

**Nested routes — the picture frame analogy:** a parent route renders a shared "frame" that never changes; `<Outlet>` marks exactly where the matched child route's content ("the photo") swaps in.

```jsx
<Route path="/habits" element={<HabitsLayout {...sharedProps} />}>
  <Route index element={<HabitsPage />} />           {/* exact match on /habits */}
  <Route path=":habitId" element={<HabitDetailPage />} /> {/* dynamic segment */}
</Route>
```

**URL params — the string gotcha, memorize this:**
```jsx
const { habitId } = useParams() // ALWAYS a string
const habit = habits.find((h) => String(h.id) === habitId) // must convert!
```
Comparing `h.id === habitId` directly silently always fails — `number !== string`, even for genuinely matching data.

**useOutletContext** — passes data through nested routes without prop drilling through the route definitions themselves:
```jsx
// HabitsLayout:
<Outlet context={{ habits, onToggleHabit }} />
// HabitsPage / HabitDetailPage:
const { habits, onToggleHabit } = useOutletContext()
```

**Simulated authentication — same three-file Context pattern as Theme.** `AuthContext`, `AuthProvider` (owns `user`, `login()`, `logout()`), `useAuth()`.

> ⚠️ **The honest, important caveat:** this is client-side only, zero real security. Anyone can bypass it via DevTools. It controls **navigation/UI visibility only** — never a substitute for real server-side authorization, since our actual data endpoints remain completely open regardless of login state.

**ProtectedRoute — a bouncer that remembers where you were headed:**
```jsx
function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth()
  const location = useLocation()
  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location }} />
  }
  return children
}
```
`LoginPage` reads `location.state?.from?.pathname` after a successful login and calls `navigate(from, { replace: true })` — round-tripping the user back to their original destination, not just the homepage.

**`<Navigate>` vs. `useNavigate()`:**
- `<Navigate>` — declarative, returned directly from render logic (a pure "should we redirect?" check)
- `navigate(path)` — imperative, called in response to an action (like after a successful login)

---
```
[GENERATED: Notes Batch 7 — Phase 6: Navigation]
[STARTING: Notes Batch 8 — Phase 7: Advanced Patterns]
```

## PHASE 7 — Advanced Patterns

### Part 1: Refs & 🆕 ref-as-a-Prop

**The problem:** sometimes you need to reach past React's render cycle and talk directly to a real DOM node (focusing an input isn't a "state" concept — there's no data value that, when set, magically focuses something).

**The sticky-note analogy:** state = a sign in the front window, everyone watches it. A ref = a sticky note inside the fridge — persists, but changing it never triggers a re-render, and React never inspects it to decide what to draw.

```jsx
const inputRef = useRef(null) // { current: null } initially
inputRef.current.focus()       // .current holds the real DOM node once attached
```

**The Ref Experiment, remembered:** state count and ref count side by side. Clicking "Increment Ref" changes the value (confirmed via console.log) but the screen text **never updates** — until a LATER state-driven re-render happens, at which point it suddenly shows the correct, up-to-date total. Proof: refs persist, but don't drive rendering.

> 🆕 **NEW IN REACT 19 — ref as a plain prop.**
```jsx
// OLD (pre-19): required wrapping in forwardRef
const Input = forwardRef(function Input(props, ref) { return <input ref={ref} {...props} /> })

// NEW (19+): just destructure it like any other prop
function Input({ name, ref }) { return <input ref={ref} name={name} /> }
```
Genuine simplification — no extra wrapper, no split-argument awkwardness.

**useImperativeHandle — controlling exactly what a parent sees via a ref:**
```jsx
useImperativeHandle(ref, () => ({
  focus() { inputRef.current?.focus() },
  shake() { setIsShaking(true) },
}))
```
Exposes a small, deliberate `{ focus, shake }` API instead of handing out the raw DOM node — same "controlled surface area" principle as props in general.

**Built in this Part:** a "/" keyboard shortcut opens + focuses the quick-add form; `Escape` closes it; invalid submission triggers a `.shake()` call reaching from the Action all the way down into the input's animation state.

> 🔑 **The Rules of Refs:** never read/write `.current` during render (only in handlers/effects); never use a ref as a substitute for state — if a value should ever appear on screen, it belongs in state, not a ref.

---

### Part 2: Custom Hooks

**The signal to extract:** the exact same stateful *pattern* written more than once. This Part had three: localStorage-backed state (Theme + Auth Providers), a boolean open/close toggle (Habits + Tasks sections), and a keyboard listener with cleanup.

**What a custom hook actually is:** a function named starting with `use`, calling other hooks internally. No special syntax beyond that.

**The recipe card analogy — the single most important idea in this Part:** a custom hook shares LOGIC, never STATE. Two components calling the same hook are two cooks following the same recipe card, each ending up with their own separate pot of soup.

```javascript
export function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue)
  const toggle = useCallback(() => setValue((c) => !c), [])
  const setTrue = useCallback(() => setValue(true), [])
  const setFalse = useCallback(() => setValue(false), [])
  return [value, { toggle, setTrue, setFalse }]
}
```

**The Hook Isolation Experiment, remembered:** two `<Switch>` components, both calling `useToggle`. Clicking one flips only that one — the other stays completely untouched. Direct proof the logic is shared, but the state is not.

**When to actually extract one — the practical checklist:**
- Same stateful pattern written 2+ times
- A self-contained sub-problem worth naming on its own
- Would benefit from being independently testable (pays off directly in Phase 8)

> 🔑 **Remember:** the `use` prefix isn't just style — ESLint's Rules-of-Hooks linting specifically looks for it to know which functions to check. A function that internally calls hooks but doesn't start with `use` won't get flagged for violations, hiding real bugs.

---
```
[GENERATED: Notes Batch 8 — Phase 7: Advanced Patterns]
[STARTING: Notes Batch 9 (FINAL) — Phase 8: Quality + Phase 9: Production]
```

## PHASE 8 — Quality

### Part 1: Testing with Vitest & React Testing Library

**The testing philosophy, in one line:** test like a curious user, not like an inspector reading blueprints. Never assert on internal state variables directly — assert on what's actually visible/clickable on screen.

**Why this matters practically:** implementation-detail tests break on harmless refactors (exactly what we did throughout Phase 7). Behavior-based tests only break on genuine regressions — the only kind of test failure that's actually useful.

**The toolchain, and each piece's one job:**
- **Vitest** — the test runner, shares Vite's config
- **@testing-library/react** — `render()` + `screen` queries
- **@testing-library/jest-dom** — extra matchers (`.toBeInTheDocument()`, `.toBeDisabled()`)
- **@testing-library/user-event** — realistic simulated typing/clicking
- **jsdom** — a simulated browser environment, running inside Node

**Every test follows the same three beats:**
```jsx
render(<Badge>🔥 5</Badge>)              // 1. render
const el = screen.getByText('🔥 5')       // 2. query
expect(el).toBeInTheDocument()            // 3. assert
```

**Mock functions track calls without doing real work:**
```javascript
const handleToggle = vi.fn()
// ...after interaction...
expect(handleToggle).toHaveBeenCalledTimes(1)
```

**Testing a custom hook in isolation:**
```javascript
const { result } = renderHook(() => useToggle(false))
act(() => { result.current[1].toggle() })
expect(result.current[0]).toBe(true)
```
`act()` ensures state updates fully flush before the next assertion — needed here because we're calling hook functions directly, outside Testing Library's usual auto-wrapping.

**Mocking modules for speed and determinism:**
```javascript
vi.mock('./config.js', () => ({ API_BASE_URL: 'http://mock-api.test' }))
```
Whole test suite runs in ~1–2 seconds, with `json-server` not even running — proof of zero real dependency on the actual backend.

> 🔑 **Remember the query priority:** `getByRole` > `getByLabelText` > `getByPlaceholderText` > `getByText` > `getByTestId` (last resort). Prefer queries that reflect how a real user (or screen reader) perceives the page.

> 🔑 **`getBy` vs `queryBy` vs `findBy`:** `getBy` throws immediately (use for "is present"); `queryBy` returns `null` (use for "is absent," combined with `.not.toBeInTheDocument()`); `findBy` returns a Promise that retries (use for "will eventually appear," e.g. after an async Action resolves).

---

## PHASE 9 — Production

### Part 1: Builds, Env Vars, Performance

**Dev mode vs. production build — the workshop vs. the finished chair.** `npm run build` minifies, tree-shakes, bundles, and hash-names assets into `dist/`. `npm run preview` serves that exact `dist/` folder locally — a genuine dress rehearsal before deploying.

**Layered env files:** `.env` (always) → `.env.development` (dev server only) → `.env.production` (build only). Confirmed by searching the built JS for the production URL string.

**The golden rule: measure before optimizing.** Use the React DevTools Profiler — record, interact, stop, read the flame graph — BEFORE reaching for `memo`/`useMemo`/`useCallback`. Every one of these tools has a real cost (extra comparisons, more code to maintain).

**React.memo alone often isn't enough — the inline function gotcha:**
```jsx
// This defeats memo every time, even with memo applied to HabitCard:
<HabitCard onToggle={() => onToggleHabit(habit.id)} />
```
A brand-new arrow function is created every render, and `memo`'s shallow comparison sees it as "different" regardless of identical behavior inside.

**The real fix requires TWO changes together:**
1. `useCallback` around the handler in `App.jsx`, so it has a stable identity
2. Pass `habit.id` as a prop and let `HabitCard` itself call `onToggle(id)` — eliminating the per-render wrapper closure entirely

```jsx
const handleToggleHabit = useCallback((habitId) => { ... }, [habits, applyOptimisticHabit])
// HabitCard.jsx:
function handleCardClick() { onToggle(id) }
export default memo(HabitCard)
```

**Verified via the Profiler:** only the actually-toggled card re-renders now — proof, not assumption.

**React.lazy + Suspense — code-splitting by route:**
```jsx
const SettingsPage = lazy(() => import('./pages/SettingsPage.jsx'))
// must be wrapped:
<Suspense fallback={<p>Loading page…</p>}>
  <Routes>...</Routes>
</Suspense>
```
Build output shows multiple separate JS chunks instead of one giant bundle; each downloads only when its route is actually visited.

> 🔑 **Remember the honest caveat:** premature optimization has a real, ongoing maintenance cost — stale-closure bugs from wrong dependency arrays are a genuinely common class of bug. Profile first, optimize the measured bottleneck, re-verify behavior is unchanged.

---

### Part 2: Deploying to Vercel

**The backend problem, finally solved:** `json-server` only ever ran locally. **Serverless functions** — small backend functions that run on-demand, per request — deploy alongside the frontend on the same platform, for free.

**The `api/` folder's structure IS the routing:**
```
api/habits/index.js   → GET/POST /api/habits
api/habits/[id].js    → PATCH /api/habits/:id
```

> ⚠️ **The honest limitation:** the demo data store is in-memory — resets across deployments/cold starts. A real production version would connect to a real database (Supabase, Neon, Vercel Postgres) — and critically, the frontend `fetch` code wouldn't need to change at all.

**vercel.json solves the SPA-refresh 404 problem, foreshadowed back in Phase 6:**
```json
{ "rewrites": [{ "source": "/((?!api/).*)", "destination": "/index.html" }] }
```

**The deployment sequence:**
```bash
git init && git add . && git commit -m "..."
git remote add origin <github-url>
git push -u origin main
# then: import the repo on vercel.com, set VITE_API_URL=/api in the dashboard, Deploy
```

> 🔑 **Remember why env vars must be re-entered in Vercel's dashboard:** `.env.production` is gitignored on purpose (never commit secrets/config), so Vercel genuinely cannot see it unless you type the value directly into Project Settings → Environment Variables.

**Preview Deployments — the CI/CD payoff, watched with your own eyes:**
1. `git checkout -b my-change`, commit, push
2. Open a pull request on GitHub → Vercel bot auto-comments a unique preview URL
3. Preview shows the change; production does NOT show it yet — genuinely isolated
4. Merge → production automatically redeploys, no manual "Deploy" button ever pressed

This entire cycle — auto-build every change, auto-ship on merge — is what "CI/CD" means in practice, not just in theory.

---

## Final Takeaway

Every phase built on the last, in strict dependency order: props → state → forms → real data → app-wide state → routing → refs/hooks → tests → production. Nothing introduced was ever abstract — every concept solved a concrete problem the app had just hit. The architecture that remains is intentionally clean and extensible: a real database, real auth, and deeper testing are the natural next steps, each one building directly on a pattern you already know from this series.
