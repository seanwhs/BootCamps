# Phase 1: Foundations
# Part 1: Why React Exists & Setting Up Your Project with Vite

## Introduction: What we're doing in this part

Before we write a single line of React, we need to answer a question a lot of tutorials skip: **why does React exist at all?** If you don't understand the problem, the solution just looks like arbitrary rules to memorize.

By the end of this part, you will:
1. Understand the specific problem React was built to solve.
2. Have Node.js installed on your machine.
3. Have a real, running React 19 project — created with Vite — that you can view in your browser.
4. Understand every file that Vite generated for you, instead of treating it as magic.

---

## 🎯 The Target: Understanding the problem before the tool

### 🧠 The Concept: The "repaint the whole wall" problem

Imagine you have a wall covered in sticky notes representing information on a webpage — a to-do list. Every time one item gets checked off, imagine your only tool for updating the wall is to **scrape off every single sticky note and re-write/re-stick all of them from scratch**, just to change one word on one note.

That's roughly what raw JavaScript DOM manipulation felt like at scale, before tools like React. The **DOM** (Document Object Model — the browser's live, in-memory representation of your HTML) is powerful, but manually finding the right element, updating it, and keeping it in sync with your actual data becomes a tangled mess as an app grows. You end up with code littered with `document.getElementById(...)`, `.innerHTML = ...`, and a constant, manual struggle to remember "what does the screen currently show, and does it still match my data?"

React's core idea: **you describe what the UI should look like for a given set of data, and React figures out the minimal changes needed to make the real screen match that description.** You stop manually touching the wall. You just say "here's what the wall should say now," and React quietly finds the one sticky note that changed and updates just that one.

This is called a **declarative** approach (you declare/describe the end result) as opposed to an **imperative** approach (you give step-by-step instructions for how to change things). Here's a tiny illustration — no need to run this, just read it:

**Imperative (plain JavaScript) — you manage every step:**
```javascript
// You have to manually find the element, then manually change its content.
// If the count changes elsewhere, you must remember to update this again.
const countEl = document.getElementById("count");
let count = 0;

function increment() {
  count = count + 1;
  countEl.textContent = "Count: " + count; // manual sync step — easy to forget!
}
```

**Declarative (React) — you describe the result, React handles the sync:**
```jsx
// You just describe: "the screen should show Count: {count}".
// Whenever `count` changes, React re-runs this and updates the screen for you.
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>Count: {count}</button>;
}
```

Don't worry — `useState`, the curly braces, and `onClick` will all be explained thoroughly starting in Phase 2. Right now, just notice the *shape* of the difference: one version manually pushes updates to the screen; the other just describes the current truth and lets React do the pushing.

This single idea — **UI as a function of state** (the screen is always just a reflection of your current data) — is the foundation everything else in this series builds on.

---

## 🎯 The Target: Installing Node.js and npm

### 🧠 The Concept: Node.js is the engine; npm is the delivery truck

React code, and the tools that build it, are written in JavaScript. But JavaScript traditionally only ran *inside a browser*. **Node.js** is a program that lets JavaScript run directly on your computer, outside a browser — like giving a fish (JavaScript) the ability to breathe on land. This is what lets our build tools (Vite) run from a terminal.

**npm** (Node Package Manager) comes bundled with Node.js. It's the "delivery truck" that fetches other people's pre-written code packages (like React itself) from the internet and drops them into your project, and it also lets you run project scripts (like "start the dev server").

### 🛠️ The Implementation: Install Node.js

1. Go to [https://nodejs.org](https://nodejs.org) and download the **LTS** (Long Term Support) version — this means the most stable, well-tested release, as opposed to the bleeding-edge "Current" version.
2. Run the installer for your operating system, accepting the defaults.

### ✅ The Verification

Open your terminal (on Windows: **Command Prompt** or **PowerShell**; on macOS: **Terminal**; on Linux: your shell of choice) and run:

```bash
node --version
```

```bash
npm --version
```

**Expected output** (your exact numbers may differ slightly, but you need Node 18 or higher):

```
v20.11.1
```
```
10.2.4
```

If you see `command not found` or `'node' is not recognized`, close and reopen your terminal (installers sometimes require this to refresh your system's PATH), and try again.

---

## 🎯 The Target: Scaffolding the project with Vite

### 🧠 The Concept: Vite is your project's "kitchen setup," not the meal itself

Writing modern JavaScript involves syntax (like JSX, which we'll meet in Part 2) that browsers can't read directly. You need a **build tool** to translate your source code into plain JavaScript/HTML/CSS a browser understands, and to serve it to you locally while you work, refreshing the browser automatically as you save changes.

**Vite** (French for "fast", pronounced "veet") is that build tool. Think of it like a professional kitchen setup: it doesn't cook the specific meal (that's your React code), but it gives you the stove, the prepped ingredients, and — critically — instant feedback (Vite updates your browser in milliseconds when you save a file, a feature called **Hot Module Replacement**, or HMR).

We use Vite instead of older tools like Create React App because Create React App is no longer actively maintained, whereas Vite is the current, officially recommended way to start a new React project — it's dramatically faster and simpler.

### 🛠️ The Implementation: Create the project

In your terminal, navigate to wherever you keep your coding projects (e.g., `cd Documents/Code`), then run:

```bash
npm create vite@latest task-habit-tracker -- --template react
```

Let's break down this command since it looks dense:
* `npm create vite@latest` — fetch and run the latest version of Vite's project-creation tool.
* `task-habit-tracker` — the name of the folder Vite will create for our project.
* `-- --template react` — tells Vite: "skip the interactive questions, I want the plain **React** template" (as opposed to Vue, Svelte, or other frameworks Vite also supports).

You should see output like:

```
Scaffolding project in /Users/you/Documents/Code/task-habit-tracker...

Done. Now run:

  cd task-habit-tracker
  npm install
  npm run dev
```

Now follow those exact instructions:

```bash
cd task-habit-tracker
npm install
```

`npm install` reads a file called `package.json` (which Vite just generated) and downloads every package your project depends on — including React itself — into a folder called `node_modules`. This may take 10–60 seconds depending on your internet connection.

**Expected output** (abbreviated):
```
added 150 packages, and audited 151 packages in 8s

25 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

### ✅ The Verification: Run the dev server

```bash
npm run dev
```

**Expected output:**
```
  VITE v5.4.10  ready in 320 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

Open your browser and go to **http://localhost:5173/**. You should see the default Vite + React starter page: a React and Vite logo, a heading "Vite + React," and a button reading "count is 0" that increments each time you click it.

**Try it:** click the button a few times. Notice the number changes instantly, with no page reload/flash. That's React managing the DOM update for you, and Vite serving it near-instantly — the exact "repaint just the sticky note that changed" behavior we discussed above, already happening in code you didn't even write yet.

Leave this terminal window running (`npm run dev` stays active, watching for file changes) and open a **second terminal tab** for the rest of this part, or press `Ctrl+C` to stop it whenever you need your terminal back.

---

## 🎯 The Target: Understanding what Vite generated

### 🧠 The Concept: Reading the blueprint of an unfamiliar house

You wouldn't move into a house without knowing where the fuse box and water shutoff are. Similarly, before we touch this project, let's understand every file Vite handed us — because we'll be modifying nearly all of them by the end of the series.

### 🛠️ The Implementation: The project structure

Open the `task-habit-tracker` folder in VS Code (`code .` from the terminal, or File → Open Folder). You should see:

```
task-habit-tracker/
├── node_modules/          # Downloaded packages (never edit; not shown in git)
├── public/
│   └── vite.svg           # Static assets served exactly as-is
├── src/
│   ├── assets/
│   │   └── react.svg
│   ├── App.css             # Styles for the App component
│   ├── App.jsx              # The root/main component
│   ├── index.css            # Global page styles
│   └── main.jsx              # The entry point — boots React
├── .gitignore
├── index.html                # The one real HTML file for the whole app
├── package.json               # Project metadata & dependency list
├── package-lock.json           # Exact locked dependency versions
└── vite.config.js               # Vite's own configuration
```

Let's look at the three files that matter most right now, in the order the browser actually processes them.

**File: `index.html`** (project root)

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + React</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

Notice `<div id="root"></div>`. This is the single, empty container in the entire page. Everything you will ever see in this app — every task, every button, every page — gets injected inside this one `<div>` by React. This is why React apps are called **Single Page Applications**: there's genuinely only one HTML page; React swaps content in and out of it.

The `<script type="module" src="/src/main.jsx">` line is what kicks things off — it tells the browser to run our JavaScript entry file.

**File: `src/main.jsx`**

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

Line-by-line, in plain English:
* `import { StrictMode } from 'react'` — pulls in a special "development helper" component from the React library. `StrictMode` doesn't render any visible UI; it just makes React double-check your components during development to help catch mistakes early (we'll see it in action later).
* `import { createRoot } from 'react-dom/client'` — `react-dom` is a companion library to `react` specifically responsible for putting React content into a real browser DOM. `createRoot` is the function that "claims" a DOM element for React to control.
* `import './index.css'` — plain CSS import; Vite understands this and includes the styles.
* `import App from './App.jsx'` — brings in our root component, defined in another file (more on `import`/`export` below).
* `createRoot(document.getElementById('root'))` — finds that empty `<div id="root">` from `index.html` and hands control of it to React.
* `.render(<StrictMode><App /></StrictMode>)` — tells React: "render the `App` component (wrapped in StrictMode) into that root element."

You'll notice something unusual: `<StrictMode>` and `<App />` look like HTML tags, but they're sitting inside a `.jsx` file, directly as arguments to a JavaScript function call. This is **JSX**, and it's the entire subject of the next part — we're deliberately not explaining it fully yet, just flagging that it exists.

**File: `src/App.jsx`**

```jsx
import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <div>
        <a href="https://vite.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.jsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-doc">
        Click on the logo to learn more
      </p>
    </>
  )
}

export default App
```

This is the exact code powering the counter button you clicked earlier. We are going to delete almost all of it in a moment and replace it with the start of our real project — but first, one more file matters:

**File: `package.json`**

```json
{
  "name": "task-habit-tracker",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint .",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@eslint/js": "^9.15.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "@vitejs/plugin-react": "^4.3.4",
    "eslint": "^9.15.0",
    "eslint-plugin-react-hooks": "^5.0.0",
    "eslint-plugin-react-refresh": "^15.2.0",
    "globals": "^9.15.0",
    "vite": "^6.0.1"
  }
}
```

Confirm you see `"react": "^19.0.0"` (or higher) under `dependencies` — this confirms you're on React 19, which this whole series is built around. The `scripts` section defines the shortcuts we've been using: `npm run dev` literally just runs the `vite` command.

> 🆕 **New in React 19:** Nothing to see yet in this file specifically — but note that `@types/react` is included even though we're writing plain JavaScript (`.jsx`), not TypeScript. VS Code uses these type definitions in the background to give you better autocomplete and inline warnings, even in `.jsx` files. We're not writing TypeScript in this series, but we get some of its editor benefits for free.

### ✅ The Verification

Run this in your terminal to double-check your exact installed React version matches:

```bash
npm list react
```

**Expected output:**
```
task-habit-tracker@0.0.0 /Users/you/Documents/Code/task-habit-tracker
└── react@19.0.0
```

---

## 🎯 The Target: Clearing the slate for our real project

### 🧠 The Concept: Starting from a clean foundation

The default counter demo was great for proving your setup works, but it's not part of our Task & Habit Tracker. We're going to strip it down to the smallest possible "hello world" so that the next part starts from a clean, understood baseline — rather than layering our app on top of unexplained demo code.

### 🛠️ The Implementation

First, delete the CSS files we won't need yet and the demo assets:

```bash
rm src/App.css
rm src/assets/react.svg
```

*(On Windows Command Prompt, use `del src\App.css` and `del src\assets\react.svg` instead.)*

Now replace `src/App.jsx` entirely with this minimal placeholder:

**`src/App.jsx`**
```jsx
// This is our root component. Every part of this series builds on top of it.
// For now, it just renders a simple heading to confirm our setup works.
function App() {
  return (
    <div>
      <h1>Task & Habit Tracker</h1>
      <p>Welcome! We're about to build this app together.</p>
    </div>
  )
}

export default App
```

Next, replace `src/index.css` with a small, clean baseline instead of Vite's default demo styling:

**`src/index.css`**
```css
/* A minimal, sane baseline. We'll expand this significantly over the series. */

* {
  box-sizing: border-box; /* Makes width/height calculations include padding & border, avoiding surprise overflow */
}

body {
  margin: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  background-color: #f7f7f8;
  color: #1a1a1a;
}
```

Finally, confirm `src/main.jsx` reads cleanly (this file is actually unchanged from what Vite generated — we're just double-checking it deliberately):

**`src/main.jsx`**
```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

// This is the one and only place in our whole app where we "start" React.
createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

### ✅ The Verification

Make sure your dev server is still running (`npm run dev` in your terminal — if you stopped it, start it again). Go to **http://localhost:5173/**.

**Expected result:** The browser now shows only:

```
Task & Habit Tracker
Welcome! We're about to build this app together.
```

Plain black text, no logos, no counter button, light gray page background.

**Try this:** With the dev server still running, change the text inside the `<h1>` in `App.jsx` to `"Task & Habit Tracker 🚀"`, save the file, and glance at your browser **without reloading it manually**. It should update within a fraction of a second, on its own. This is Vite's Hot Module Replacement in action — you'll rely on this instant feedback loop for the rest of the series.

---

## 📚 Reference Section: Phase 1, Part 1

### Why not just use plain JavaScript forever?

For tiny pages, you shouldn't! React adds real overhead (a library to load, concepts to learn) that isn't worth it for a static "About Us" page. React earns its keep specifically when your UI has to **change over time in response to data** — toggling tasks, filtering lists, showing/hiding forms — because that's exactly the "keep everything in sync" problem it automates for you. As our Task & Habit Tracker grows across this series, you'll feel this benefit compound with every new feature.

### Understanding `npm install` and `node_modules`

* `package.json` is the **source of truth** — a human-edited list of what your project depends on and at what version ranges (e.g., `^19.0.0` means "19.0.0 or any compatible newer 19.x version").
* `package-lock.json` is auto-generated and records the **exact** version of every package (including packages-of-packages) that got installed, so that anyone else running `npm install` on your project gets byte-for-byte the same dependency tree. Never edit this file by hand.
* `node_modules/` is where the actual downloaded code lives. It can contain thousands of files even for small projects (because packages depend on other packages). It should **never** be committed to Git — notice it's already listed in `.gitignore`, which we'll examine properly in a later part when we introduce version control.

### Common setup errors & fixes

| Symptom | Likely cause | Fix |
|---|---|---|
| `npm: command not found` | Node.js not installed or terminal not restarted | Reinstall Node.js from nodejs.org, fully restart your terminal |
| `EACCES` permission errors during install | npm trying to write to a protected system folder | Avoid using `sudo npm install`; instead reinstall Node via the official installer or use a version manager like `nvm` |
| Blank white page in browser | JavaScript error thrown during render | Open browser DevTools (F12) → Console tab, read the red error message — it usually names the exact file and line |
| Port 5173 already in use | Another Vite server already running elsewhere | Stop the other process, or Vite will automatically offer port 5174 instead — just use the URL shown in your terminal |
| Changes not showing up in browser | Dev server was stopped, or wrong file saved | Confirm terminal still shows `VITE ... ready`; re-run `npm run dev` if needed |

### What `import`/`export` actually do (a JavaScript primer)

Since `App.jsx` and `main.jsx` use `import`/`export`, and we'll use these constantly:

* `export default App` at the bottom of a file means: "if another file imports from *this* file without using `{ curly braces }`, give them this specific thing."
* `import App from './App.jsx'` in another file means: "grab whatever that file exported as its `default`, and let me refer to it locally as `App`" (you could actually name it anything, e.g. `import Whatever from './App.jsx'` — the name is your choice for default exports).
* `import { StrictMode } from 'react'` uses curly braces because `react` exports *multiple* named things, and we're asking for one specific one by its exact name (a **named export**, as opposed to a **default export**).

This module system is how we'll split our growing app across dozens of small files instead of one giant unmanageable one — a pattern that becomes essential starting next part, when we build our first real, separate components.

Ready whenever you are — just say **"next"** and I'll generate **Phase 1, Part 2: JSX Syntax & Your First Components**.
