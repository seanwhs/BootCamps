# React 19 Tutorial Series: Zero to Production
## Student Workbook

---

## How to Use This Workbook

This workbook is your **active companion** to the written tutorial series — not a replacement for it. Read each Part in the main series first, build the code, verify it in your browser. *Then* come here.

Each section below follows the same rhythm:

- **🎯 Learning Objectives** — what you should be able to *do* after this section, not just recognize.
- **📖 Key Vocabulary** — fill-in-the-blank definitions, using terms straight from the series. Try to answer from memory before peeking back at the text.
- **⌨️ Guided Code Exercise** — a code snippet from the series with strategic blanks (`____`). Fill them in by hand, on paper or in your editor, *before* checking your original file.
- **🧠 Check Your Understanding** — short-answer and multiple-choice questions testing the *why*, not just the *what*.
- **🐛 Debug It** — a deliberately broken snippet. Find the bug and explain it in one sentence, the way you'd explain it to a teammate.
- **🚀 Stretch Challenge** — an open-ended task extending the app slightly beyond what the series explicitly built. No single correct answer.
- **✅ Self-Check** — a short checklist. If you can't check every box, go back and re-read before moving on.

A full **Answer Key** for every fill-in-blank, multiple-choice, and Debug It exercise appears at the very end of the workbook. Stretch Challenges have no fixed answer key — they're meant to be judged by whether your app still works and your code follows the immutability/component patterns taught in the series.

**Recommended rhythm:** Read → Build → Verify (in the main series) → then complete that Part's workbook section *before* moving to the next Part. Don't batch multiple Parts' workbook sections together — the retrieval practice works best close to when you learned the material.

---

# PRIMER 1: How the Web Actually Works

### 🎯 Learning Objectives
- Explain the client-server model using your own words
- Name the three core web languages and what each is responsible for
- Trace the full request/response journey from typing a URL to seeing a page

### 📖 Key Vocabulary

Fill in each blank:

1. A ____________ is the one making a request (in web contexts, your browser).
2. A ____________ is the one responding to requests — a computer, elsewhere, usually always on.
3. ____________ is the shared "language" / rules for how requests and responses are structured.
4. ____________ is the system that translates human-friendly domain names into numeric IP addresses.
5. A ____________ is a number in an HTTP response summarizing what happened (e.g., 200, 404, 500).
6. ____________ describes structure/content — what's on the page.
7. ____________ describes appearance — how it looks.
8. ____________ describes behavior — what happens when something occurs.
9. Code that runs in the user's browser is called the ____________.
10. Code that runs on a server, handling data storage and real security, is called the ____________.

### 🧠 Check Your Understanding

1. In your own words, explain the "library window" analogy for the client-server model.
2. Put these five steps in the correct order: (a) Browser renders the response, (b) Server sends an HTTP response, (c) DNS lookup, (d) Browser sends an HTTP request, (e) Browser connects to the server.
3. True or False: JavaScript can change what a webpage *looks like*, but only CSS can make it *do* something when clicked.
4. Why is React described as "a JavaScript library" rather than "a new language"?

### 🐛 Debug It

A friend says: *"The internet and the web are the same thing — I use those words interchangeably and it's always been fine."* What's technically imprecise about this statement? Write a one-sentence correction.

### 🚀 Stretch Challenge

Open your browser's DevTools → Network tab, visit any real website, and find one actual request/response pair. Write down: the URL requested, the HTTP method, and the status code returned.

### ✅ Self-Check

- [ ] I can explain what HTTP is without looking it up
- [ ] I can list HTML/CSS/JS's three distinct jobs from memory
- [ ] I understand why "frontend" and "backend" are separate concepts

---

# PRIMER 2: Command Line Crash Course

### 🎯 Learning Objectives
- Open a terminal on your own operating system
- Navigate between folders using only typed commands
- Recover calmly from a typo or a stuck/long-running command

### 📖 Key Vocabulary

1. A ____________ (also called a command line, console, or shell) is a window where you type instructions as text.
2. "Directory" is simply the command-line word for ____________.
3. The folder your terminal is currently "located" in is called your ____________.
4. `cd` stands for ____________.
5. `____________` lists files and folders in the current directory (macOS/Linux).
6. `____________` moves you up one level to the parent folder.
7. The key combination ____________ stops a long-running command and returns your prompt.

### ⌨️ Guided Code Exercise

Fill in the blanks to complete this sequence of commands, which should: check your current folder, move into a folder called `Projects`, list what's inside it, then create a new folder called `my-app`.

```bash
____        # print working directory (Mac/Linux)
cd ____     # move into the Projects folder
____        # list contents (Mac/Linux)
mkdir ____  # create a new folder named my-app
```

### 🧠 Check Your Understanding

1. What does `~` mean when used with `cd`?
2. You run `cd Documents` and get an error: `no such file or directory: Documents`. Name two possible reasons this could happen.
3. Why is it normal — not a sign of a frozen computer — for a terminal to show no new prompt after running `npm run dev`?
4. What is the difference between `mkdir foldername` and `mkdir -p a/b/c`?

### 🐛 Debug It

A student runs:
```bash
rm my-project-folder
```
...expecting the entire folder to be deleted, but instead gets an error. What likely went wrong, and what command should they have used instead?

### 🚀 Stretch Challenge

Using only terminal commands (no file explorer/Finder), create a folder structure three levels deep (e.g., `practice/level2/level3`) in a single `mkdir` command, then navigate all the way into the deepest folder in a single `cd` command.

### ✅ Self-Check

- [ ] I can open a terminal without looking up how
- [ ] I know what to do when I mistype a command
- [ ] I'm comfortable with Ctrl+C stopping a running process

---

# PRIMER 3: Setting Up Your Code Editor

### 🎯 Learning Objectives
- Install VS Code and open a project folder from the terminal
- Identify the five core areas of the VS Code layout
- Configure format-on-save with Prettier

### 📖 Key Vocabulary

1. ____________ highlights different parts of your code in different colors based on their meaning.
2. Red or yellow underlines that appear *while you type*, flagging likely mistakes, are called ____________.
3. The terminal command `____________` opens the current folder directly in VS Code.
4. ____________ are add-ons that give VS Code new capabilities beyond what it ships with by default.
5. ____________ is an extension that checks your code's logic/patterns for likely mistakes.
6. ____________ is an extension that automatically rewrites your code's formatting, consistently, on every save.

### 🧠 Check Your Understanding

1. Name the five core areas of VS Code's layout described in the primer.
2. What is the difference between what ESLint checks and what Prettier checks?
3. What two settings do you need to change (and to what) to enable "format on save" with Prettier?
4. What keyboard shortcut lets you jump to any file in your project by typing part of its name?

### 🐛 Debug It

A student installs the Prettier extension, but their code never reformats itself when they save a file. List two possible settings they might be missing.

### 🚀 Stretch Challenge

Open VS Code's Command Palette (`Ctrl/Cmd+Shift+P`) and find three commands you've never used before by browsing the list. Write down what each one does.

### ✅ Self-Check

- [ ] VS Code is installed and the `code` command works from my terminal
- [ ] ESLint and Prettier extensions are installed
- [ ] Format-on-save is configured and verified working

---

# PRIMER 4: Git & Version Control Basics

### 🎯 Learning Objectives
- Explain the difference between Git and GitHub
- Perform the core init → add → commit workflow
- Create a branch and understand why it's isolated from `main`

### 📖 Key Vocabulary

1. ____________ is a version control system that keeps a complete, permanent history of every change made to a project.
2. ____________ is a website that hosts a copy of your Git history online.
3. A permanent snapshot of your project at a specific moment is called a ____________.
4. Choosing which changed files will be included in the next snapshot is called ____________.
5. `____________` is the command that starts tracking a project with Git.
6. A file listing what Git should never track is called ____________.
7. An independent line of history, letting you work on a change in isolation, is called a ____________.

### ⌨️ Guided Code Exercise

Fill in the blanks to complete a full first-time Git workflow:

```bash
git ____                                   # start tracking this project
git config --global user.name "____"       # your name, once per machine
git add ____                                 # stage every changed file
git ____ -m "Initial commit"                 # take the snapshot
git remote add origin ____                   # link to a GitHub repo URL
git push -u origin ____                       # upload to GitHub
```

### 🧠 Check Your Understanding

1. Explain the "photo album" analogy for how Git stores history.
2. What is the purpose of the `-m` flag on `git commit`?
3. Why does `.gitignore` typically include `node_modules`, even though that folder contains real files that exist on disk?
4. What does `git checkout -b add-footer-credit` do, in one sentence?
5. Why is `git status` described as "the command you'll run constantly"?

### 🐛 Debug It

A student runs `git commit -m "fixed stuff"` immediately after `git init`, with no `git add` step in between, and is confused why `git log` shows no commits. What step did they skip, and why does it matter?

### 🚀 Stretch Challenge

Practice the full branch workflow on a throwaway test folder: initialize a repo, make a commit on `main`, create and switch to a new branch, make a *different* change and commit it there, then switch back to `main` and confirm that change is gone from `main` (but still exists on the other branch).

### ✅ Self-Check

- [ ] I can explain Git vs. GitHub to someone else
- [ ] I've successfully run init → add → commit at least once
- [ ] I understand what a branch isolates you from

---

```
```
[GENERATED: Workbook Batch 1 — Front Matter + Primers 1–4]
[STARTING: Workbook Batch 2 — Part 0 + Phase 1 (Parts 1–3)]
```

# PART 0: Introduction

### 🎯 Learning Objectives
- Describe the scope and final architecture of the Task & Habit Tracker
- Identify the full technology stack used across the series and why each tool was chosen
- Recognize the four-beat lesson structure used in every Part going forward

### 📖 Key Vocabulary

1. A ____________ is data that a component "remembers" between renders.
2. ____________ are information passed into a component from its parent.
3. A ____________ is a reusable, self-contained "recipe" for a piece of UI.
4. The process of React figuring out what the screen should look like is called ____________.
5. A ____________ is a special React function, always starting with `use`, that lets a component tap into React features.

### 🧠 Check Your Understanding

1. Name the four things every hands-on step in this series features (the "four-beat rhythm").
2. List the six main technologies in the stack, and give a one-phrase reason each was chosen.
3. Why does the series build ONE continuously-growing app instead of many small, disconnected demos?
4. What does the 🆕 "New in React 19" callout box signal, and name three specific features it covers?

### 🚀 Stretch Challenge

Before starting Phase 1, sketch (on paper) your own prediction of the component tree for the Dashboard screen, based only on the feature list in Part 0. Compare it against the actual tree once you reach Phase 1, Part 2.

### ✅ Self-Check

- [ ] I understand what app I'm building and why it stays the same across all 9 phases
- [ ] I know what tools I'll need before Phase 1 (and that most setup happens IN Phase 1, not before)
- [ ] I know what "done" looks like at the end of the series

---

# PHASE 1: Foundations
## Part 1: Why React Exists & Setting Up Vite

### 🎯 Learning Objectives
- Explain the difference between imperative and declarative UI code
- Install Node.js and scaffold a new Vite + React project from scratch
- Identify the purpose of every file Vite generates

### 📖 Key Vocabulary

1. ____________ is a program that lets JavaScript run directly on a computer, outside a browser.
2. ____________ is a build tool and development server, providing fast Hot Module Replacement.
3. A development server feature that updates your browser instantly when you save a file, without a full reload, is called ____________.
4. Describing WHAT the UI should look like, and letting React figure out HOW, is called a ____________ approach.
5. Manually specifying every step to update the screen is called an ____________ approach.
6. `____________` is the one and only real HTML element that our entire React app gets injected into.

### ⌨️ Guided Code Exercise

Fill in the blanks in this `main.jsx`, based on what you built in Phase 1, Part 1:

```jsx
import { ____ } from 'react'
import { ____ } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

____(document.getElementById('____')).render(
  <StrictMode>
    <____ />
  </StrictMode>,
)
```

### 🧠 Check Your Understanding

1. Rewrite this imperative counter snippet's *intent* in one sentence of plain English:
   ```javascript
   count = count + 1
   countEl.textContent = "Count: " + count
   ```
2. What command scaffolds a new Vite + React project? What does the `-- --template react` part specifically do?
3. What is the difference between `package.json` and `package-lock.json`?
4. Why should `node_modules` never be committed to Git?
5. What does `StrictMode` actually do visually on the page? What does it do behind the scenes?

### 🐛 Debug It

A student runs `npm run dev` and gets `Error: Cannot find module 'react'`. They insist they definitely created the project correctly. What command did they most likely forget to run right after scaffolding?

### 🚀 Stretch Challenge

Without looking back at the tutorial text, from memory, write out the complete minimal `App.jsx` that just renders a heading and a paragraph. Then compare it against your actual file.

### ✅ Self-Check

- [ ] `npm run dev` runs successfully and shows my app at localhost:5173
- [ ] I can explain what each file in the generated project structure does
- [ ] I've confirmed Hot Module Replacement works by editing text and watching it update live

---

## Part 2: JSX Syntax & Your First Components

### 🎯 Learning Objectives
- State all four JSX rules and why each one exists
- Build a multi-component tree with correctly nested, capitalized components
- Explain the difference between an expression and a statement in the context of JSX

### 📖 Key Vocabulary

1. ____________ is a syntax extension letting you write HTML-looking markup directly inside JavaScript.
2. A ____________ groups multiple elements together without adding an extra element to the rendered HTML.
3. In JSX, you must use ____________ instead of `class`, since the latter is a reserved JavaScript word.
4. A component function's name must start with a ____________ letter.
5. Something that PRODUCES A VALUE (like `2 + 2` or a ternary) is called an ____________; something that is an instruction (like `if`) is called a ____________.

### ⌨️ Guided Code Exercise

Fill in the blanks to fix this broken component so it satisfies all four JSX rules:

```jsx
function Broken() {
  return (
    <h1>Title</h1>
    <img src="logo.png">
    <p class="subtitle">Subtitle</p>
  )
}
```

Corrected version:

```jsx
function Fixed() {
  return (
    ____
      <h1>Title</h1>
      <img src="logo.png" ____ />
      <p ____="subtitle">Subtitle</p>
    ____
  )
}
```

### 🧠 Check Your Understanding

1. What does this JSX actually compile down to? `<div><h1>Hi</h1></div>`
2. Why does React distinguish `<div>` (lowercase) from `<Navbar />` (capitalized) at the COMPILER level, not just as a style preference?
3. Sketch the component tree taught in this Part: App → ? → ? → ?
4. What's the difference between a Fragment (`<>...</>`) and wrapping elements in a `<div>`? When would you specifically prefer a Fragment?

### 🐛 Debug It

A student writes a component called `habitCard` (lowercase h) and uses it as `<habitCard />`. Nothing crashes, but nothing they expect shows up either. What's actually happening, and how do they fix it?

### 🚀 Stretch Challenge

Build one additional small presentational component NOT covered in the series (e.g., a `Footer` or a `Tooltip`), following the exact same one-component-per-file convention, and wire it into the App tree.

### ✅ Self-Check

- [ ] I can list all four JSX rules from memory
- [ ] My component tree (App → Navbar/Dashboard → Sections → Cards) renders correctly in DevTools
- [ ] I understand why component names MUST be capitalized

---

## Part 3: Props — Passing Data Into Components

### 🎯 Learning Objectives
- Pass data into a component via props and destructure it correctly
- Explain why props must never be mutated
- Use the `children` prop to build a generic, reusable wrapper component

### 📖 Key Vocabulary

1. ____________ are information passed into a component from its parent, bundled into a single object.
2. The rule that props must never be directly changed by the component receiving them is sometimes summarized as "____________."
3. ____________ is a special, automatically-provided prop capturing whatever JSX is placed BETWEEN a component's opening and closing tags.
4. Manually passing data down through several layers of components, even when intermediate layers don't use it, is called ____________.
5. `____________` in a function's parameter list lets you supply a fallback value when a prop is missing.

### ⌨️ Guided Code Exercise

Fill in the blanks based on your `HabitCard.jsx`:

```jsx
function HabitCard({ label, streak = ____, isComplete = ____ }) {
  return (
    <div className="card habit-card">
      <span className="card-checkbox">{isComplete ? '____' : '____'}</span>
      <span className={`card-label ${isComplete ? '____' : ''}`}>
        {____}
      </span>
      <span className="card-streak">🔥 {____}</span>
    </div>
  )
}
```

### 🧠 Check Your Understanding

1. Explain, in one sentence, why props are like "a sealed parcel handed to you by a courier."
2. What happens, precisely, if `HabitCard` is rendered without a `streak` prop and no default value is set?
3. Write the JSX for a `Badge` component usage that would result in `props.children` equal to the string `"🔥 5"`.
4. Why is `tone="streak"` on a `<Badge>` a useful pattern instead of writing many nearly-identical Badge components?
5. Name two real solutions to the "prop drilling" pain this Part deliberately made you feel, and note which Phase actually implements each.

### 🐛 Debug It

Inside a component, a student writes:
```jsx
function HabitCard({ label }) {
  label = label.toUpperCase() // "just cleaning it up a bit"
  return <p>{label}</p>
}
```
What rule does this break, and what's the safe alternative if the label genuinely needs transforming before display?

### 🚀 Stretch Challenge

Extend `Badge` to support a third `tone`, e.g., `"danger"`, with its own distinct CSS styling, and use it somewhere meaningful in the app (e.g., flagging an overdue task).

### ✅ Self-Check

- [ ] I can explain the difference between a prop and state, even though state isn't introduced until Phase 2
- [ ] My data flows correctly through App → Dashboard → Section → Card, all via props
- [ ] I've built and used the `children`-based `Badge` component successfully

---
```
[GENERATED: Workbook Batch 2 — Part 0 + Phase 1]
[STARTING: Workbook Batch 3 — Phase 2: Interactivity (Parts 1–3)]
```

# PHASE 2: Interactivity
## Part 1: State with useState

### 🎯 Learning Objectives
- Explain why a plain JavaScript variable cannot "remember" anything across renders
- Use `useState` to make a component interactive
- Correctly decide when state should be lifted up to a shared parent

### 📖 Key Vocabulary

1. `useState` returns an array of exactly ____________ items: the current value and an updater function.
2. Calling the updater function does two things: updates React's stored value, and schedules a ____________.
3. Moving state to the closest common parent so multiple components can share it is called ____________.
4. The two Rules of Hooks are: only call hooks at the ____________ level, and only call them from ____________ or other custom hooks.
5. Passing a function to a state setter (e.g., `setValue((prev) => !prev)`) rather than a plain value is called the ____________ pattern.

### ⌨️ Guided Code Exercise

Fill in the blanks in this immutable state update, from `App.jsx`:

```jsx
function handleToggleHabit(habitId) {
  setHabits((currentHabits) =>
    currentHabits.____((habit) =>
      habit.id === ____
        ? { ____habit, isComplete: !habit.isComplete }
        : habit
    )
  )
}
```

### 🧠 Check Your Understanding

1. Why does `let isComplete = false` inside a component function fail to act as "memory" across renders?
2. What are the two things `useState`'s initial value argument is used for, and when is it ignored?
3. Why is `setIsComplete((current) => !current)` generally safer than `setIsComplete(!isComplete)`?
4. Explain WHY React might fail to detect a change if you mutate an object directly instead of using spread + `.map()`.
5. What specific new feature (the "N remaining" count) motivated lifting state up out of individual `HabitCard`s?

### 🐛 Debug It

A student writes:
```jsx
function handleToggle() {
  habit.isComplete = !habit.isComplete   // "quick fix"
  setHabits(habits)
}
```
The checkbox visually never updates, even though `console.log(habits)` shows the correct new value. Explain exactly why React fails to re-render here.

### 🚀 Stretch Challenge

Add a new piece of state-driven feature: a "Clear All Completed" button for the Tasks list, using the exact same immutable `.filter()` pattern taught in this Part (removing all tasks where `isComplete === true`).

### ✅ Self-Check

- [ ] I can explain the Rules of Hooks and WHY they exist (call-order tracking)
- [ ] My habit/task toggling works, and the "N remaining" count updates correctly
- [ ] I understand the difference between state that should stay local vs. state that needs lifting up

---

## Part 2: Rendering Lists with .map()

### 🎯 Learning Objectives
- Replace manually-indexed rendering with `.map()`
- Explain what the `key` prop is for, and prove it with a real example
- Choose an appropriate key strategy for any given list

### 📖 Key Vocabulary

1. `.map()` builds a ____________ array by running a function on every item of the original array, without modifying it.
2. The `key` prop helps React tell list items apart, like a ____________, not a "seat number."
3. Using `Math.random()` as a key is ____________ than having no key at all, because it changes on every single render.
4. Array index as `key` is acceptable only when the list is never ____________, and has no per-item local state that must survive reordering.

### ⌨️ Guided Code Exercise

Fill in the blanks to convert manual indexing into a `.map()`-based render:

```jsx
// Before:
<HabitCard label={habits[0].label} isComplete={habits[0].isComplete} />
<HabitCard label={habits[1].label} isComplete={habits[1].isComplete} />

// After:
{habits.____((habit) => (
  <HabitCard
    ____={habit.id}
    label={habit.____}
    isComplete={habit.____}
  />
))}
```

### 🧠 Check Your Understanding

1. What are the two problems with manually indexing an array (`habits[0]`, `habits[1]`, ...) that `.map()` solves?
2. Describe, step by step, what happened in the Key Experiment when using array index as key vs. `person.id` as key.
3. Why does React never actually DISPLAY the `key` prop's value anywhere on screen?
4. List three other array methods covered in this Part's Reference Section (besides `.map()` and `.filter()`), and what each returns.

### 🐛 Debug It

A student's todo list has a bug: typing into an "edit" input for one task sometimes causes the WRONG task's edit field to show the typed text, but only after deleting an item from the middle of the list. What key strategy are they almost certainly using, and what should they switch to?

### 🚀 Stretch Challenge

Add a 5th and 6th habit directly to `sampleData.js` / `db.json` and confirm — without touching any component code — that they appear correctly in the UI, each independently toggleable.

### ✅ Self-Check

- [ ] I've personally reproduced the Key Experiment bug and watched it happen
- [ ] Every list in my app uses `habit.id`/`task.id` as its key, never array index
- [ ] I can explain `.map()` vs `.filter()` vs `.find()` without checking notes

---

## Part 3: Event Handling & Conditional Rendering

### 🎯 Learning Objectives
- Explain event bubbling and stop it with `stopPropagation()`
- Choose the correct conditional rendering pattern (ternary, `&&`, early return) for a given situation
- Build a reusable, generic filter control backed by local state

### 📖 Key Vocabulary

1. ____________ is the way a DOM event ripples outward through every ancestor element, like a pebble dropped in a pond.
2. `event.____________()` stops an event from bubbling up to parent element handlers.
3. A ____________ expression always produces exactly one of two values: `condition ? a : b`.
4. `condition && <Something />` renders "something, or ____________."
5. Setting `type="____________"` on a non-submit `<button>` inside a `<form>` prevents it from accidentally submitting the form.

### ⌨️ Guided Code Exercise

Fill in the blanks to correctly isolate a nested badge's click from its parent card's click:

```jsx
function handleStreakClick(event) {
  event.____________()
  window.alert(`🔥 ${streak}-day streak!`)
}

return (
  <div className="card habit-card" onClick={onToggle}>
    {/* ... */}
    <Badge tone="streak" onClick={____________}>
      🔥 {streak}
    </Badge>
  </div>
)
```

### 🧠 Check Your Understanding

1. Why does clicking the streak Badge, without `stopPropagation()`, ALSO toggle the habit's completion?
2. What is the well-known trap with using `count && <Something />` when `count` might legitimately be `0`? What's the fix?
3. When should you reach for an early `return` inside a component instead of a ternary or `&&`?
4. Why does `FilterTabs`' filter state live locally inside `TasksSection`, rather than being lifted up to `App`, unlike habit/task data itself?

### 🐛 Debug It

A student builds a "like counter" badge showing `{count && <span>{count} likes</span>}`. When there are zero likes, the badge shows the literal text `0` instead of nothing. What's wrong, and what's the one-word fix to the condition?

### 🚀 Stretch Challenge

Add a new filter option to `FilterTabs` for Habits (not just Tasks): "All / Complete Today / Incomplete Today", following the exact same local-state, non-lifted pattern used for Tasks.

### ✅ Self-Check

- [ ] I've deliberately removed `stopPropagation()` once and watched the bug happen, then restored it
- [ ] I can pick the right conditional rendering pattern for a new situation without hesitating
- [ ] My Tasks page correctly filters by All/Active/Completed, with a working empty state

---
```
[GENERATED: Workbook Batch 3 — Phase 2: Interactivity]
[STARTING: Workbook Batch 4 — Phase 3: Forms & Data (Parts 1–3)]
```

# PHASE 3: Forms & Data
## Part 1: Controlled Forms

### 🎯 Learning Objectives
- Build a controlled form input backed by React state
- Validate input and conditionally disable a submit button
- Generate safe, unique IDs for newly created items

### 📖 Key Vocabulary

1. A ____________ input has its `value` explicitly set from React state, with every keystroke captured via `onChange`.
2. `event.____________()` stops a form's default full-page-reload submission behavior.
3. `.____________()` removes leading/trailing whitespace, preventing a "just spaces" submission from being accepted.
4. `crypto.____________()` generates a long, essentially-guaranteed-unique string for new item IDs.
5. Building a brand-new array containing every existing item plus one new item at the end, without mutating the original, uses the ____________ operator.

### ⌨️ Guided Code Exercise

Fill in the blanks in this controlled `TaskForm`:

```jsx
function TaskForm({ onAddTask, onCancel }) {
  const [label, setLabel] = useState(____)
  const trimmedLabel = label.____()
  const isValid = trimmedLabel.length ____ 0

  function handleSubmit(event) {
    event.____________()
    if (!isValid) return
    onAddTask(trimmedLabel)
    setLabel(____)
  }

  return (
    <form onSubmit={____________}>
      <input
        value={____}
        onChange={(event) => setLabel(event.target.____)}
      />
      <button type="submit" disabled={____________}>Add</button>
    </form>
  )
}
```

### 🧠 Check Your Understanding

1. Why is `onSubmit` attached to the `<form>` element rather than directly to the submit button?
2. What specific bug would `tasks.length + 1` introduce as an ID-generation strategy, after items can be deleted?
3. Explain, in your own words, why a controlled input is described as "a puppet, with React holding the strings."
4. Why does the tutorial validate using the TRIMMED label's length, rather than the raw label's length?

### 🐛 Debug It

A student's "Add Task" button never becomes enabled, no matter what they type. Their code reads:
```jsx
const isValid = label.trim().length > 0
// ...later...
<button disabled={isValid}>Add</button>
```
What's the exact bug, in one sentence?

### 🚀 Stretch Challenge

Add a maximum length validation (e.g., 100 characters) to `TaskForm`, showing a distinct error message when exceeded, following the multi-rule validation pattern shown in this Part's Reference Section.

### ✅ Self-Check

- [ ] I can explain controlled vs. uncontrolled inputs without checking notes
- [ ] My forms correctly reject empty/whitespace-only submissions
- [ ] I understand why `crypto.randomUUID()` is safer than array-length-based IDs

---

## Part 2: 🆕 Actions & useActionState

### 🎯 Learning Objectives
- Explain what a React 19 Action is and what problem it removes
- Rebuild a form using `useActionState` instead of manual `useState`/`onSubmit`
- Read field values via `FormData` instead of controlled state

### 📖 Key Vocabulary

1. Passing a function (instead of a URL string) to a `<form>`'s `action` prop makes it a React 19 ____________.
2. `useActionState` returns three things: `state`, `____________`, and `isPending`.
3. An Action function passed to `useActionState` receives two arguments: the ____________ state, and the form's ____________.
4. `formData.____()` reads one field's value by its `name` attribute, always returning a ____________ (never a number directly).
5. 🆕 In React 19, you never need to manually call `setIsSubmitting(true)`/`(false)` because ____________ is tracked automatically.

### ⌨️ Guided Code Exercise

Fill in the blanks in this Action-based form:

```jsx
async function addTaskAction(previousState, formData) {
  const rawLabel = formData.____('label')
  const label = rawLabel.trim()

  if (label.length === 0) {
    return { error: '____________' }
  }

  await onAddTask(label)
  return { error: ____ }
}

const [state, formAction, isPending] = ____________(addTaskAction, { error: null })

return (
  <form action={____________}>
    <input name="____" disabled={isPending} />
    <button type="submit" disabled={isPending}>
      {isPending ? '____________' : 'Add'}
    </button>
  </form>
)
```

### 🧠 Check Your Understanding

1. List three specific things React automatically does when you pass a function to a form's `action` prop.
2. Why does the input in the Action-based `TaskForm` no longer have a `value` or `onChange` prop at all?
3. What's the trade-off mentioned in the Reference Section for going fully uncontrolled vs. keeping a controlled input alongside an Action?
4. What was `useActionState` briefly called during React's canary/experimental releases, and from which package did it originally come?

### 🐛 Debug It

A student writes an Action function that is NOT marked `async`, and notices `isPending` never becomes `true`, even with a real delay inside it. What's the fix?

### 🚀 Stretch Challenge

Add a second field to `TaskForm` (e.g., an optional "notes" field) and read both fields out of the same `formData` object inside one Action function.

### ✅ Self-Check

- [ ] I can explain what problem Actions solve compared to Phase 3, Part 1's approach
- [ ] My form correctly shows a duplicate-name error and a pending state
- [ ] I understand why the input is now uncontrolled, and what trade-off that involves

---

## Part 3: 🆕 useFormStatus

### 🎯 Learning Objectives
- Explain the one critical rule about where `useFormStatus` can be called
- Extract reusable form pieces (input, submit button, cancel button) that independently know their form's pending state
- Demonstrate, with a deliberate experiment, exactly why the descendant rule matters

### 📖 Key Vocabulary

1. `useFormStatus` is imported from `____________`, NOT from `'react'`.
2. The component calling `useFormStatus` must be a ____________ of the `<form>` — never the same component rendering the form itself.
3. `useFormStatus()` returns an object including `pending`, `data`, `method`, and ____________.
4. The analogy used for `useFormStatus` in this Part is an ____________ built into the walls of the form.

### ⌨️ Guided Code Exercise

Fill in the blanks in this extracted, reusable component:

```jsx
import { useFormStatus } from '____________'

function SubmitButton({ idleLabel, pendingLabel }) {
  const { ____ } = useFormStatus()

  return (
    <button type="submit" disabled={____}>
      {pending ? ____________ : idleLabel}
    </button>
  )
}
```

### 🧠 Check Your Understanding

1. Why did the experiment in this Part show `false` forever when `useFormStatus` was called in the SAME component that renders the `<form>`?
2. Name the three components extracted in this Part, and what each one independently reads via `useFormStatus`.
3. Compare `useActionState`'s pending value vs. `useFormStatus`'s `pending` — when would you reach for each?
4. Why does extracting `SubmitButton` and `CancelButton` reduce prop drilling specifically, and not some other problem?

### 🐛 Debug It

A student builds a `<SaveIndicator>` component, renders it OUTSIDE the `<form>` element entirely (as a sibling, not a child), and calls `useFormStatus` inside it, expecting it to reflect that form's pending state. It doesn't work. Why not?

### 🚀 Stretch Challenge

Build one more reusable form-status-aware component: a `<CharacterCount>` that reads `data` from `useFormStatus` (not `pending`) to show how many characters have been typed into a specific field while a submission is in flight.

### ✅ Self-Check

- [ ] I've personally broken the descendant rule and watched it fail, then fixed it
- [ ] My SubmitButton, CancelButton, and FormTextInput are fully reusable across both forms
- [ ] I can explain the difference between useActionState's pending and useFormStatus's pending

---
```
[GENERATED: Workbook Batch 5 — Phase 4: Data Fetching]
[STARTING: Workbook Batch 6 — Phase 5: App-Wide State (Parts 1–2)]
```

# PHASE 5: App-Wide State
## Part 1: The Context API

### 🎯 Learning Objectives
- Explain what Context solves that props alone cannot
- Build the three-file Context pattern from scratch
- Identify Context's re-render behavior and when it's the wrong tool

### 📖 Key Vocabulary

1. ____________ is described as a "public bulletin board" rather than a private note passed hand-to-hand.
2. The three pieces of Context are: `createContext()`, a ____________, and `useContext()`.
3. Context is only readable by components that are ____________ of the Provider in the actual rendered tree.
4. `____________` (CSS custom properties) let one attribute change (`data-theme`) repaint an entire themed app.
5. A custom hook wrapping `useContext` with a "missing Provider" safety check, by convention, is named `use____`.

### ⌨️ Guided Code Exercise

Fill in the blanks across these three files:

```javascript
// ThemeContext.js
import { ____________ } from 'react'
export const ThemeContext = ____________(null)
```

```jsx
// ThemeProvider.jsx
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(getInitialTheme)
  const contextValue = { theme, toggleTheme }

  return (
    <ThemeContext.____________ value={contextValue}>
      {children}
    </ThemeContext.____________>
  )
}
```

```javascript
// useTheme.js
export function useTheme() {
  const context = ____________(ThemeContext)
  if (context === ____) {
    throw new Error('useTheme must be called from within a <ThemeProvider>.')
  }
  return context
}
```

### 🧠 Check Your Understanding

1. Why is Context described as a poor fit for "the text currently being typed into one specific input"?
2. What did the Re-render Experiment prove, using `HabitCard` (a component that doesn't even use `useTheme`)?
3. Why is `ThemeContext.js` a plain `.js` file, while `ThemeProvider.jsx` uses the `.jsx` extension?
4. What does the safety-check `if (context === null) throw ...` inside `useTheme` actually protect against?

### 🐛 Debug It

A student wraps only `<Dashboard />` in `<ThemeProvider>`, but not `<Navbar />`, in their `main.jsx`. Clicking the theme toggle inside `Navbar` throws an error. Why?

### 🚀 Stretch Challenge

Build a second, independent Context following the exact same three-file pattern — e.g., a `LanguageContext` for a simple English/Spanish label-switching feature — without looking back at `ThemeContext`'s code while writing it.

### ✅ Self-Check

- [ ] I can build the three-file Context pattern from memory
- [ ] My dark mode toggle works from any component, at any depth, with zero props passed for it
- [ ] I've personally observed Context's broad re-render behavior via the logging experiment

---

## Part 2: useReducer for Complex State Logic

### 🎯 Learning Objectives
- Identify when several `useState` calls should be consolidated into a `useReducer`
- Write a pure reducer function covering every valid state transition
- Explain why reducers must never contain side effects

### 📖 Key Vocabulary

1. `useReducer` is compared to a ____________ machine: you press a labeled button, and one internal rulebook decides the result.
2. A reducer function has the shape: `(state, action) => ____________`.
3. An action object conventionally has a `type` field and, optionally, a ____________ field carrying extra data.
4. A reducer function must be ____________ — no fetch calls, no `setTimeout`, nothing reaching outside itself.
5. Throwing an error in a reducer's `default` case turns a typo'd action type into an immediate, loud ____________ instead of a silently ignored action.

### ⌨️ Guided Code Exercise

Fill in the blanks in this reducer:

```javascript
export function dataReducer(state, action) {
  switch (action.____) {
    case 'FETCH_START':
      return { ...state, isLoading: ____, loadError: ____ }
    case 'FETCH_SUCCESS':
      return { ____state, habits: action.payload.habits, isLoading: false }
    case 'TOGGLE_HABIT':
      return {
        ...state,
        habits: state.habits.____((habit) =>
          habit.id === action.payload.id ? action.payload : habit
        ),
      }
    default:
      throw new Error(`Unknown action type: ${action.type}`)
  }
}
```

### 🧠 Check Your Understanding

1. List the four pieces of state that got consolidated from separate `useState` calls into `dataReducer`.
2. Why did `retryCount`, `toastMessage`, `savingHabitIds`, and `savingTaskIds` deliberately stay as SEPARATE `useState` calls, rather than joining the reducer?
3. What genuinely practical benefit did the one-line action-logging wrapper demonstrate?
4. When would you prefer plain `useState` over `useReducer`, even for two related values?

### 🐛 Debug It

A student's reducer case reads:
```javascript
case 'ADD_TASK':
  return { tasks: [...state.tasks, action.payload] }
```
After dispatching `ADD_TASK`, every other piece of state (`habits`, `isLoading`, etc.) disappears from the app. What's the exact bug?

### 🚀 Stretch Challenge

Add a new action type to `dataReducer`, e.g., `'DELETE_TASK'`, implementing full delete functionality for tasks, following the same immutable, pure-reducer pattern.

### ✅ Self-Check

- [ ] I can explain why a reducer must be pure, with a concrete reason (not just "the rules say so")
- [ ] My refactor from useState to useReducer changed zero visible behavior, verified by rerunning Phase 4's full checklist
- [ ] I've used the temporary action-logging technique to see my own app's full data history

---
```
[GENERATED: Workbook Batch 6 — Phase 5: App-Wide State]
[STARTING: Workbook Batch 7 — Phase 6: Navigation (Parts 1–2)]
```

# PHASE 6: Navigation
## Part 1: React Router — Multi-Page Navigation

### 🎯 Learning Objectives
- Explain client-side routing without using the word "React"
- Build multiple pages using `Routes`/`Route`, `Link`, and `NavLink`
- Correctly configure a catch-all 404 route and an exact-matching root link

### 📖 Key Vocabulary

1. ____________ routing swaps which components are displayed based on the URL, without requesting a new HTML document from the server.
2. `<____________>` must wrap anything in your app that uses routing features, using the browser's History API.
3. `<____>` is React Router's replacement for a plain `<a>` tag, avoiding a full page reload.
4. `<____________>` is a specialized link that automatically knows whether its own destination matches the current URL.
5. The `____` prop on a root-level `NavLink` prevents it from being treated as "active" on every single page.
6. A `<Route path="____" element={<NotFoundPage />} />` must be listed LAST, since it matches any unmatched URL.

### ⌨️ Guided Code Exercise

Fill in the blanks in this route configuration:

```jsx
<____________>
  <Route path="/" element={<DashboardPage />} />
  <Route path="/tasks" element={<TasksPage />} />
  <Route path="____" element={<NotFoundPage />} />
</____________>
```

```jsx
<NavLink
  to="/"
  ____________
  className={({ ____________ }) => (isActive ? 'nav-link-active' : 'nav-link')}
>
  Dashboard
</NavLink>
```

### 🧠 Check Your Understanding

1. Explain the "receptionist swapping the display, not rebuilding the hotel" analogy for client-side routing.
2. Why does refreshing directly on `/tasks` work fine under `npm run dev` but potentially fail on a naive static production host?
3. What would happen, precisely, if the wildcard `*` route were listed FIRST instead of last?
4. Why does the Dashboard's `NavLink` need `end`, but `/tasks`'s `NavLink` does not?

### 🐛 Debug It

A student's Dashboard nav link stays highlighted no matter which page they're on. What's the single missing prop, and why does its absence cause this specific symptom?

### 🚀 Stretch Challenge

Add a brand new top-level page not covered in the series — e.g., an "Archive" page showing only completed tasks/habits — complete with its own route and a working NavLink.

### ✅ Self-Check

- [ ] My four main pages (Dashboard, Tasks, Habits, Settings) all navigate correctly with no full reload
- [ ] My 404 page correctly catches unmatched URLs
- [ ] I understand why "end" matters specifically for the root route's NavLink

---

## Part 2: Nested Routes, URL Params, Protected Routes

### 🎯 Learning Objectives
- Build a nested route structure using `<Outlet>`
- Read and safely compare a dynamic URL parameter
- Build client-side route protection and explain its real security limits

### 📖 Key Vocabulary

1. `<____________>` is a placeholder marking exactly where a matched CHILD route's content should render inside a parent layout.
2. A route segment written as `:habitId` is called a URL ____________.
3. `useParams()` ALWAYS returns its values as ____________, never numbers, even if the underlying data uses numeric IDs.
4. `use____________()` reads whatever value a parent `<Outlet context={...}>` provided, without prop drilling through route definitions.
5. Client-side route protection like `ProtectedRoute` controls ____________/UI visibility only — it is NOT a substitute for real, server-side ____________.

### ⌨️ Guided Code Exercise

Fill in the blanks in this dynamic route and its detail page:

```jsx
<Route path="/habits" element={<HabitsLayout ____________ />}>
  <Route index element={<HabitsPage />} />
  <Route path="____________" element={<HabitDetailPage />} />
</Route>
```

```jsx
function HabitDetailPage() {
  const { habitId } = ____________()
  const { habits } = ____________()
  const habit = habits.find((h) => ____________(h.id) === habitId)
  // ...
}
```

```jsx
function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth()
  const location = ____________()

  if (!isAuthenticated) {
    return <____________ to="/login" replace state={{ from: location }} />
  }
  return children
}
```

### 🧠 Check Your Understanding

1. Explain the "picture frame with a swappable photo" analogy for nested routes.
2. Why does `habit.id === habitId` (without `String()`) silently always evaluate to `false`, even for a habit that clearly exists?
3. Trace the full round-trip: a logged-out user clicks Settings, logs in, and lands back on Settings. What role does `location.state` play in making this work?
4. Why does this Part insist, explicitly, that client-side route protection provides "zero real security"?

### 🐛 Debug It

A student's `HabitDetailPage` always shows "habit not found," even for habits that definitely exist in the data. Their comparison reads `habit.id === habitId`. What's the bug?

### 🚀 Stretch Challenge

Add a second protected route (e.g., a hypothetical "Admin" page) reusing the exact same `ProtectedRoute` wrapper, and confirm the redirect-then-return-to-origin flow works correctly for it too.

### ✅ Self-Check

- [ ] My /habits/:habitId detail page correctly finds and displays the right habit
- [ ] I've tested the "not found" fallback with a deliberately invalid habit ID in the URL
- [ ] I can explain exactly why our login system provides no real security, in specific terms

---
```
[GENERATED: Workbook Batch 7 — Phase 6: Navigation]
[STARTING: Workbook Batch 8 — Phase 7: Advanced Patterns (Parts 1–2)]
```

# PHASE 7: Advanced Patterns
## Part 1: Refs & 🆕 ref-as-a-Prop

### 🎯 Learning Objectives
- Explain why refs don't trigger re-renders, with proof
- Use `useRef` to directly command a DOM element (focus)
- Use `useImperativeHandle` to expose a limited, deliberate API via a ref

### 📖 Key Vocabulary

1. A ____________ is described as "a sticky note on your fridge," persisting across renders but invisible to React's re-render logic.
2. `useRef(null)` returns an object of the shape `{ ____________: null }`.
3. 🆕 In React 19, `ref` can be received as an ordinary destructured ____________, without wrapping the component in `forwardRef`.
4. `____________` lets a component control exactly what object a parent receives when it holds a `ref`, instead of exposing the raw DOM node.
5. Refs should never be read or written to directly during ____________ — only inside event handlers or `useEffect`.

### ⌨️ Guided Code Exercise

Fill in the blanks in this ref-exposing component:

```jsx
function FormTextInput({ name, ____ }) {
  const inputRef = ____________(null)

  ____________(ref, () => ({
    focus() {
      inputRef.____?.focus()
    },
    shake() {
      setIsShaking(true)
    },
  }))

  return <input ____={inputRef} name={name} />
}
```

### 🧠 Check Your Understanding

1. In the Ref Experiment, why did clicking "Increment Ref" change the underlying value but NOT update anything visible on screen?
2. What did clicking "Increment State" immediately afterward reveal about the ref's value?
3. Why does `useImperativeHandle` expose `{ focus, shake }` instead of the raw DOM node directly? What's the benefit?
4. Compare the old `forwardRef` pattern to React 19's ref-as-a-prop pattern — what specifically got simpler?

### 🐛 Debug It

A student writes `inputRef.current.focus()` directly in the main body of a component (not inside a handler or effect), and gets a crash on the very first render. What's the likely error, and why does it happen at that specific moment?

### 🚀 Stretch Challenge

Add a new keyboard shortcut (e.g., `g` then `h` for "go to habits") using the same ref + keyboard-listener pattern, navigating via `useNavigate()` from React Router.

### ✅ Self-Check

- [ ] I've personally run the Ref Experiment and confirmed refs don't trigger re-renders
- [ ] My "/" shortcut correctly opens AND focuses the quick-add form
- [ ] I can explain useImperativeHandle's purpose without checking notes

---

## Part 2: Custom Hooks

### 🎯 Learning Objectives
- Identify when duplicated logic should become a custom hook
- Build a custom hook that shares logic but not state across callers
- Extract a generic keyboard-shortcut hook from component-specific code

### 📖 Key Vocabulary

1. A custom hook is simply a function whose name starts with `____`, that calls one or more other ____________ internally.
2. Custom hooks share ____________, but never ____________ — every call gets a completely independent copy.
3. The analogy used is a ____________ card: two cooks can follow the same one, but end up with separate pots of soup.
4. `____________` memoizes a FUNCTION itself across re-renders, analogous to how `useMemo` memoizes a value.

### ⌨️ Guided Code Exercise

Fill in the blanks in this custom hook:

```javascript
export function useToggle(initialValue = ____) {
  const [value, setValue] = ____________(initialValue)

  const toggle = useCallback(() => setValue((current) => !current), [____])
  const setTrue = useCallback(() => setValue(____), [])
  const setFalse = useCallback(() => setValue(____), [])

  return [value, { toggle, setTrue, setFalse }]
}
```

### 🧠 Check Your Understanding

1. What three duplicated patterns motivated extracting custom hooks in this Part?
2. Explain what the Hook Isolation Experiment (two `<Switch>` components) proved, specifically.
3. Give the practical checklist from the Reference Section for deciding WHEN to extract a custom hook.
4. Why must a custom hook's name start with `use`, beyond just being a naming convention?

### 🐛 Debug It

A student writes a function called `toggleLogic()` (no `use` prefix) that internally calls `useState`. ESLint doesn't flag any Rules of Hooks violations even when they call it conditionally. Why not?

### 🚀 Stretch Challenge

Extract one more custom hook not built in the series — e.g., a `useDebounce` hook for delaying a search input's effect — and use it somewhere meaningful in the Tracker.

### ✅ Self-Check

- [ ] I've personally run the Hook Isolation Experiment and confirmed independent state per caller
- [ ] My useLocalStorage, useToggle, and useKeyboardShortcut hooks all work identically to the pre-refactor code
- [ ] I can explain why hook names must start with "use," beyond convention

---
```
[GENERATED: Workbook Batch 8 — Phase 7: Advanced Patterns]
[STARTING: Workbook Batch 9 — Phase 8: Quality + Phase 9: Production]
```

# PHASE 8: Quality
## Part 1: Testing with Vitest & React Testing Library

### 🎯 Learning Objectives
- Explain the "test like a user" testing philosophy
- Write component tests covering rendering, interaction, and conditional behavior
- Mock functions and modules so tests run fast and deterministically

### 📖 Key Vocabulary

1. The guiding testing principle: "the more your tests resemble the way your software is ____________, the more confidence they can give you."
2. `render()` mounts a component into a simulated DOM; `____________` provides query functions to find elements on it.
3. `____________` simulates realistic user interactions (typing, clicking) far more accurately than firing raw DOM events by hand.
4. `getBy...` throws immediately if not found; `queryBy...` returns ____________ instead; `findBy...` returns a ____________ that retries until found.
5. `vi.____()` creates a mock function that records every call it receives.
6. `renderHook()` gives a custom hook a ____________ "host" component to live in, since hooks can't be called directly in test code.

### ⌨️ Guided Code Exercise

Fill in the blanks in this component test:

```jsx
describe('HabitCard', () => {
  it('calls onToggle when the card is clicked', async () => {
    const user = ____________.setup()
    const handleToggle = vi.____()

    render(<HabitCard label="Drink water" onToggle={handleToggle} />)

    await user.____(screen.getByText('Drink water'))

    expect(handleToggle).____________(1)
  })
})
```

### 🧠 Check Your Understanding

1. Why does React Testing Library discourage asserting on a component's internal state variables directly?
2. Explain the query priority order — why is `getByRole` preferred over `getByText`?
3. What did deliberately removing `stopPropagation()` and re-running the test suite prove?
4. Why does `TaskForm.test.jsx` never need to mock `tasksApi.js`, even though the real app eventually calls it?

### 🐛 Debug It

A student writes:
```jsx
expect(screen.queryByText('Loading...')).toBeInTheDocument()
```
...to assert something is present, and it fails confusingly. What query should they have used instead, and why does mixing up `getBy`/`queryBy` matter here?

### 🚀 Stretch Challenge

Write a new test file for a component not tested in the series (e.g., `FilterTabs.test.jsx`), covering: initial render, clicking a tab, and the active tab's class name changing correctly.

### ✅ Self-Check

- [ ] `npm test` runs and all tests pass, with json-server NOT running
- [ ] I've deliberately broken a component and watched its corresponding test fail
- [ ] I can explain getBy vs queryBy vs findBy without checking notes

---

# PHASE 9: Production
## Part 1: Builds, Env Vars, Performance

### 🎯 Learning Objectives
- Run and verify a production build locally before deploying
- Apply `React.memo`, `useCallback`, and `useMemo` correctly, and prove their effect via profiling
- Apply `React.lazy` + `Suspense` to code-split the app by route

### 📖 Key Vocabulary

1. `npm run ____________` creates an optimized build in the `dist/` folder.
2. `npm run ____________` serves the built `dist/` folder locally, as a dress rehearsal before deploying.
3. `.env.development` and `.env.production` are examples of Vite's ____________ environment variable convention.
4. `React.____()` wraps a component so React skips re-rendering it if its props are shallow-equal to before.
5. The golden rule of performance work: ____________ before optimizing.
6. `React.____()` paired with `<Suspense>` defers downloading a component's code until it's actually needed.

### ⌨️ Guided Code Exercise

Fill in the blanks in this memoization fix:

```jsx
const handleToggleHabit = ____________((habitId) => {
  // ... implementation ...
}, [habits, applyOptimisticHabit])

// HabitCard.jsx
function HabitCard({ id, onToggle, ...rest }) {
  function handleCardClick() {
    onToggle(____)
  }
  return <div onClick={handleCardClick}>{/* ... */}</div>
}

export default ____(HabitCard)
```

### 🧠 Check Your Understanding

1. Why did wrapping `HabitCard` in `React.memo` alone NOT stop unnecessary re-renders at first?
2. Explain the exact fix: what TWO changes were needed together (in `App.jsx` and in `HabitsSection.jsx`/`HabitCard.jsx`) to make memoization actually work?
3. Why is `useMemo` on a 3-4 item array's `.filter()` described as "genuinely negligible" real-world benefit, despite being used as a teaching example?
4. What must ALWAYS wrap a `React.lazy()` component, and what happens if you forget it?

### 🐛 Debug It

A student wraps `TaskCard` in `React.memo`, but the Profiler still shows every card re-rendering on every toggle. Their `TasksSection` still writes:
```jsx
<TaskCard onToggle={() => onToggleTask(task.id)} />
```
What's the bug, and what's the fix?

### 🚀 Stretch Challenge

Apply `React.memo` to one additional component not covered in the series (e.g., `Badge`), profile it before and after, and document whether it made any measurable difference — and explain why or why not.

### ✅ Self-Check

- [ ] I've run the Profiler before AND after the memo/useCallback fix and seen the difference
- [ ] My production build shows multiple separate JS chunks after adding React.lazy
- [ ] I can explain why premature optimization is a real cost, not just a cliché

---

## Part 2: Deploying to Vercel

### 🎯 Learning Objectives
- Convert a local mock backend into deployable serverless functions
- Push a project to GitHub and connect it to Vercel
- Trigger and verify a Preview Deployment before merging to production

### 📖 Key Vocabulary

1. A ____________ function runs on demand, for a single request, rather than as a continuously-running process.
2. The `api/` folder's file and folder structure IS the ____________ — no separate router configuration needed.
3. `vercel.json`'s rewrite rule solves the "____________" problem — refreshing on a non-root URL like `/tasks`.
4. Since `.env.production` is gitignored, its values must instead be entered directly in ____________'s dashboard.
5. Every branch and pull request automatically gets its own ____________ — a full, live, isolated copy of the app.
6. Continuous Integration / Continuous Deployment is together known as ____________.

### ⌨️ Guided Code Exercise

Fill in the blanks in this deployment sequence:

```bash
git ____
git add .
git ____ -m "Initial commit"
git remote add origin ____________
git branch -M main
git push -u origin ____
```

```json
{
  "rewrites": [
    { "source": "/((?!api/).*)", "destination": "/____________" }
  ]
}
```

### 🧠 Check Your Understanding

1. Explain the explicit, honest limitation of the in-memory serverless data store used in this Part.
2. Walk through, step by step, what happens from `git push` on a new branch to seeing a working Preview Deployment URL.
3. Why does merging a pull request automatically trigger a NEW production deployment, with no manual "deploy" button pressed?
4. Why must `VITE_API_URL` be manually re-entered in Vercel's dashboard, even though it already exists in a local `.env.production` file?

### 🐛 Debug It

A student deploys successfully, but every page except the homepage shows a 404 when they refresh directly on it (e.g., visiting `mysite.vercel.app/tasks` directly). What file is likely missing or misconfigured?

### 🚀 Stretch Challenge

Following this Part's Reference Section, research and write a short plan (no need to implement) for replacing the in-memory data store with a real, persistent free-tier database (e.g., Supabase or Neon) — noting exactly which files would change and which would stay identical.

### ✅ Self-Check

- [ ] My app is live on a real HTTPS Vercel URL
- [ ] I've created a branch, seen its Preview Deployment, and merged it into production
- [ ] I can explain, precisely, why our backend's data doesn't reliably persist, and what a real fix would involve

---
```
[GENERATED: Workbook Batch 9 — Phase 8 + Phase 9]
[STARTING: Workbook Batch 10 (FINAL) — Complete Answer Key]
```

# Answer Key

This key covers every **Key Vocabulary** fill-in-blank, **Guided Code Exercise** blank, and **Debug It** exercise from the workbook. Check Your Understanding and Stretch Challenge answers are intentionally open-ended and not keyed here — discuss those with a peer, mentor, or by comparing your reasoning against the original tutorial text.

---

## Primer 1: How the Web Actually Works
**Vocabulary:** 1. client 2. server 3. HTTP 4. DNS 5. status code 6. HTML 7. CSS 8. JavaScript 9. frontend 10. backend
**Debug It:** The internet is the underlying physical/logical infrastructure; the web (HTTP, HTML, URLs, browsers) is one system built on top of it — they are related but not identical.

## Primer 2: Command Line Crash Course
**Vocabulary:** 1. terminal 2. folder 3. working directory 4. Change Directory 5. `ls` 6. `cd ..` 7. Ctrl+C
**Guided Code:** `pwd` / `cd Projects` / `ls` / `mkdir my-app`
**Debug It:** `rm` alone doesn't delete non-empty folders on most systems; they needed `rm -rf my-project-folder` (or their OS's folder-deletion equivalent).

## Primer 3: Setting Up Your Code Editor
**Vocabulary:** 1. Syntax highlighting 2. error/warning squiggles 3. `code .` 4. Extensions 5. ESLint 6. Prettier
**Debug It:** Missing "Format On Save" enabled, and/or Prettier not selected as the "Default Formatter."

## Primer 4: Git & Version Control Basics
**Vocabulary:** 1. Git 2. GitHub 3. commit 4. staging 5. `git init` 6. `.gitignore` 7. branch
**Guided Code:** `init` / "Your Name" / `.` / `commit` / `<github-repo-url>` / `main`
**Debug It:** They skipped `git add` — nothing was staged, so `git commit` had nothing to snapshot (or committed an empty snapshot).

---

## Part 0: Introduction
**Vocabulary:** 1. state 2. Props 3. component 4. render 5. Hook

## Phase 1, Part 1
**Vocabulary:** 1. Node.js 2. Vite 3. Hot Module Replacement 4. declarative 5. imperative 6. `<div id="root"></div>`
**Guided Code:** `StrictMode` / `createRoot` / `createRoot` / `root` / `App`
**Debug It:** They forgot to run `npm install` after scaffolding the project.

## Phase 1, Part 2
**Vocabulary:** 1. JSX 2. Fragment 3. `className` 4. capital 5. expression / statement
**Guided Code:** `<>` / `/` / `className` / `</>`
**Debug It:** React treats lowercase tags as literal HTML elements; `<habitCard />` is interpreted as an unknown HTML tag, not their component. Fix: rename to `HabitCard` (capitalized) and use `<HabitCard />`.

## Phase 1, Part 3
**Vocabulary:** 1. Props 2. props are read-only 3. `children` 4. prop drilling 5. Default values
**Guided Code:** `0` / `false` / `☑` / `☐` / `card-label-done` / `label` / `streak`
**Debug It:** Breaks the "props are read-only" rule by reassigning `label` directly. Safe alternative: compute a new variable, e.g. `const displayLabel = label.toUpperCase()`, and render that instead.

---

## Phase 2, Part 1
**Vocabulary:** 1. two 2. re-render 3. lifting state up 4. top / components 5. updater function
**Guided Code:** `.map` / `habitId` / `...`
**Debug It:** Mutating `habit.isComplete` directly changes the existing object in place; calling `setHabits(habits)` passes the SAME array reference back, so React's reference-equality check sees "no change" and skips re-rendering.

## Phase 2, Part 2
**Vocabulary:** 1. new 2. name tag 3. worse 4. reordered/filtered/inserted-into-the-middle
**Guided Code:** `.map` / `key` / `label` / `isComplete`
**Debug It:** Likely using array index (or no key) as the list's key; should switch to a stable, unique field like `task.id`.

## Phase 2, Part 3
**Vocabulary:** 1. Event bubbling 2. `stopPropagation` 3. ternary 4. nothing at all 5. `button`
**Guided Code:** `stopPropagation` / `handleStreakClick`
**Debug It:** `0` is falsy, so `{count && ...}` renders the literal `0`. Fix: change to `count > 0 && ...`.

---

## Phase 3, Part 1
**Vocabulary:** 1. controlled 2. `preventDefault` 3. `trim` 4. `randomUUID` 5. spread
**Guided Code:** `''` / `trim` / `>` / `preventDefault` / `''` / `handleSubmit` / `label` / `value` / `!isValid`
**Debug It:** The `disabled` attribute is inverted — it should read `disabled={!isValid}`, not `disabled={isValid}`.

## Phase 3, Part 2
**Vocabulary:** 1. Action 2. `formAction` 3. previous / FormData 4. `get` / string 5. `isPending`
**Guided Code:** `get` / "Please enter a task before adding it." / `null` / `useActionState` / `formAction` / `label` / "Adding…"
**Debug It:** The function isn't marked `async`; mark it `async function addTaskAction(...)` so it genuinely returns a Promise.

## Phase 3, Part 3
**Vocabulary:** 1. `react-dom` 2. descendant 3. `action` 4. intercom
**Guided Code:** `react-dom` / `pending` / `pending` / `pendingLabel`
**Debug It:** `useFormStatus` only reports the status of the nearest ANCESTOR `<form>` in the rendered tree; a sibling (not a descendant) of the form has no such ancestor to read.

---

## Phase 4, Part 1
**Vocabulary:** 1. side effect 2. dependency array 3. cleanup 4. `json-server` 5. `ok` 6. `all`
**Guided Code:** `isCancelled` / `all` / `isCancelled` / `isCancelled` / `[]`
**Debug It:** Missing dependency array entirely — the effect re-runs after every render, and since it also triggers a state update (which causes a re-render), it loops forever.

## Phase 4, Part 2
**Vocabulary:** 1. success / error 2. Error Boundary 3. class 4. `use` 5. throws 6. Error Boundary
**Guided Code:** `use` / `ErrorBoundary` / `Suspense` / `Suspense` / `ErrorBoundary`
**Debug It:** Calling `fetchQuote()` directly in the component body creates a brand-new Promise on every render, causing an infinite request loop; it must be created once, outside render (e.g., module-level cache).

## Phase 4, Part 3
**Vocabulary:** 1. Optimistic 2. optimistic 3. transition 4. partial / create 5. reverts
**Guided Code:** `startTransition` / `applyOptimisticHabit`
**Debug It:** Console warning: "An optimistic state update occurred outside a transition or action." It tells them to wrap the call in `startTransition(...)` or move it into a form Action.

---

## Phase 5, Part 1
**Vocabulary:** 1. Context 2. Provider 3. descendants 4. CSS custom properties 5. `useTheme`
**Guided Code:** `createContext` / `createContext` / `Provider` / `Provider` / `useContext` / `null`
**Debug It:** `Navbar` is rendered outside `<ThemeProvider>`'s subtree, so `useTheme()` can't find any Context value above it and throws the "must be called from within a Provider" error.

## Phase 5, Part 2
**Vocabulary:** 1. vending 2. newState 3. payload 4. pure 5. crash
**Guided Code:** `type` / `true` / `null` / `...` / `map`
**Debug It:** Forgot to spread `...state` first — the returned object only contains `tasks`, discarding every other field (`habits`, `isLoading`, etc.) entirely.

---

## Phase 6, Part 1
**Vocabulary:** 1. Client-side 2. BrowserRouter 3. Link 4. NavLink 5. `end` 6. `*`
**Guided Code:** `Routes` / `*` / `Routes` / `end` / `isActive`
**Debug It:** Missing the `end` prop; without it, `NavLink` treats `"/"` as a prefix match, matching every route.

## Phase 6, Part 2
**Vocabulary:** 1. Outlet 2. parameter 3. strings 4. `useOutletContext` 5. navigation / authorization
**Guided Code:** `habits={habits} ...` (props) / `:habitId` / `useParams` / `useOutletContext` / `String` / `useLocation` / `Navigate`
**Debug It:** Comparing a number (`habit.id`) directly against a string (`habitId` from `useParams()`); fix with `String(habit.id) === habitId`.

---

## Phase 7, Part 1
**Vocabulary:** 1. ref 2. current 3. prop 4. `useImperativeHandle` 5. render
**Guided Code:** `ref` / `useRef` / `useImperativeHandle` / `current` / `ref`
**Debug It:** `ref.current` is still `null` on the very first render (the element hasn't mounted yet), causing `Cannot read properties of null (reading 'focus')`. Fix: only call it inside `useEffect` or an event handler, and use optional chaining.

## Phase 7, Part 2
**Vocabulary:** 1. `use` / hooks 2. logic / state 3. recipe 4. `useCallback`
**Guided Code:** `false` / `useState` / `[]` / `true` / `false`
**Debug It:** ESLint's Rules-of-Hooks checking specifically looks for function names starting with `use` to know which functions to analyze; `toggleLogic` isn't recognized as a hook at all, so no violation is ever flagged, even though it internally misuses `useState`.

---

## Phase 8, Part 1
**Vocabulary:** 1. used 2. `screen` 3. `user-event` 4. `null` / Promise 5. `fn` 6. minimal
**Guided Code:** `userEvent` / `fn` / `click` / `toHaveBeenCalledTimes`
**Debug It:** Should use `getByText` (which throws with a clear error if missing) instead of `queryByText` combined with `.toBeInTheDocument()`; `queryBy` returning `null` and then calling `.toBeInTheDocument()` on `null` produces a confusing failure rather than a clear "element not found" message. (Note: this specific mix-up is more commonly framed as: use `getBy` to assert PRESENCE, `queryBy` to assert ABSENCE.)

---

## Phase 9, Part 1
**Vocabulary:** 1. `build` 2. `preview` 3. layered 4. `memo` 5. Measure 6. `lazy`
**Guided Code:** `useCallback` / `id` / `memo`
**Debug It:** `TasksSection` still creates a brand-new inline arrow function on every render (`() => onToggleTask(task.id)`), defeating `memo`'s shallow prop comparison. Fix: pass `task.id` as a prop and have `TaskCard` call a stable `onToggle(id)` directly, as shown in the tutorial.

## Phase 9, Part 2
**Vocabulary:** 1. serverless 2. routing 3. SPA refresh 4. Vercel 5. Preview Deployment 6. CI/CD
**Guided Code:** `init` / `commit` / `<github-repo-url>` / `main` / `index.html`
**Debug It:** Missing or misconfigured `vercel.json` rewrite rule — without it, the static host looks for a literal file named `tasks` and returns a real 404 instead of serving `index.html` for the client-side router to handle.
