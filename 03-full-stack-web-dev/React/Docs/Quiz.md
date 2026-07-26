# React 19 Tutorial Series: Zero to Production
## Extensive Quiz Bank with Answer Keys

## How This Quiz Bank Is Organized

Each section (Primer, Part 0, and every Phase/Part) contains six question types, immediately followed by its own **Answer Key** — so each batch is fully self-contained:

- **MC** — Multiple Choice (one correct answer unless noted)
- **TF** — True / False
- **FB** — Fill in the Blank
- **CO** — Code Output / Behavior Prediction (read code, predict what happens)
- **DBG** — Debug It (spot the bug, explain the fix)
- **SA** — Short Answer

A cumulative **Final Exam** section, mixing questions across every phase, appears at the very end of the last batch. Question numbering resets per section for easy reference (e.g., `P1-MC-3` = Primer 1, Multiple Choice, Question 3).

---

# PRIMER 1 QUIZ: How the Web Actually Works

## Multiple Choice

**P1-MC-1.** In the client-server model, your web browser is:
A) The server
B) The client
C) DNS
D) HTTP

**P1-MC-2.** What does DNS actually do?
A) Renders HTML into pixels
B) Translates a domain name into a numeric IP address
C) Compresses images for faster loading
D) Runs JavaScript on the server

**P1-MC-3.** Which status code indicates a successful HTTP response?
A) 404
B) 500
C) 200
D) 301

**P1-MC-4.** Which of the three core web languages is responsible for *behavior* (what happens when you click something)?
A) HTML
B) CSS
C) JavaScript
D) DNS

**P1-MC-5.** What is the correct order of events after pressing Enter on a URL?
A) Request → DNS lookup → Response → Render
B) DNS lookup → Connect → Request → Response → Render
C) Render → Request → Response
D) Response → Request → DNS lookup

**P1-MC-6.** Which of these best describes "the web" vs. "the internet"?
A) They are exactly the same thing
B) The web is the physical wiring; the internet is built on top of it
C) The internet is the underlying infrastructure; the web is one system (HTML/HTTP/browsers) built on top of it
D) The internet only refers to email

**P1-MC-7.** A status code in the 500 range generally means:
A) The page was found successfully
B) The resource was redirected
C) The server encountered an error
D) The client made a malformed request

**P1-MC-8.** Which statement about CSS is correct?
A) CSS can make decisions and react to clicks
B) CSS describes structure, not appearance
C) CSS describes appearance and is attached to HTML elements via selectors
D) CSS replaces the need for JavaScript entirely

**P1-MC-9.** React is best described as:
A) A brand-new programming language
B) A JavaScript library
C) A replacement for HTML
D) A type of web server

**P1-MC-10.** "Frontend" code runs:
A) Only on the server
B) In the user's own browser
C) Inside the DNS system
D) Inside the HTTP protocol itself

## True / False

**P1-TF-1.** A browser and a server communicate using a shared set of rules called HTTP. (True/False)

**P1-TF-2.** Every time you click a traditional (non-SPA) link, an entirely new request/response cycle occurs. (True/False)

**P1-TF-3.** HTML is responsible for how a page looks (colors, spacing). (True/False)

**P1-TF-4.** The backend is responsible for storing and protecting the actual data. (True/False)

**P1-TF-5.** A 404 status code means the server encountered an internal error. (True/False)

**P1-TF-6.** JavaScript is the only one of the three core web languages that can make decisions and remember things. (True/False)

**P1-TF-7.** DNS lookups happen after the HTTP request is sent, not before. (True/False)

## Fill in the Blank

**P1-FB-1.** A ____________ is a computer, elsewhere, that responds to requests — often described as a librarian handing you a book.

**P1-FB-2.** ____________ describes structure and content — what's actually on the page.

**P1-FB-3.** A number in an HTTP response summarizing what happened (e.g., 200, 404) is called a ____________.

**P1-FB-4.** Code that runs on a server, handling data storage and real security, is called the ____________.

**P1-FB-5.** The system that translates a human-friendly domain name into a numeric IP address is called ____________.

## Code/Behavior Prediction

**P1-CO-1.** You type `example.com` into your browser and press Enter. List, in the correct order, the five steps that occur before you see the page.

**P1-CO-2.** A server responds to a request with status code 500. What broad category of problem does this indicate — a mistake by the browser/user, or a problem on the server's side?

## Debug It

**P1-DBG-1.** A junior developer says: "CSS handles what happens when a user clicks a button." What is wrong with this statement, and which language actually handles that?

**P1-DBG-2.** A student says "the frontend is where all my data is safely stored, since that's where the UI lives." Explain the flaw in this reasoning.

## Short Answer

**P1-SA-1.** Explain the "library window" analogy for the client-server model in 2–3 sentences.

**P1-SA-2.** Why is React described as "a JavaScript library" rather than "a new language"?

---

## PRIMER 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-C, 4-C, 5-B, 6-C, 7-C, 8-C, 9-B, 10-B

**TF:** 1-True, 2-True, 3-False (HTML = structure; CSS = appearance), 4-True, 5-False (404 = not found; 500 = server error), 6-True, 7-False (DNS lookup happens BEFORE the request is sent)

**FB:** 1. server 2. HTML 3. status code 4. backend 5. DNS

**CO-1:** (1) DNS lookup translates the name to an IP address, (2) browser connects to that address, (3) browser sends an HTTP request, (4) server sends an HTTP response, (5) browser renders the response.
**CO-2:** A problem on the server's side (5xx codes indicate server errors, as opposed to 4xx codes which indicate client/request problems).

**DBG-1:** CSS only controls appearance; it cannot react to events like clicks. JavaScript is the language responsible for behavior/interactivity.
**DBG-2:** The frontend runs entirely in the user's own browser, which the user fully controls — it is not a secure place to "store" data. Real, protected data storage and security must live on the backend/server.

**SA-1:** *(Sample answer)* You (the client) stand at a window and ask a librarian (the server) for a specific book (a URL). You can't go get it yourself — you can only request it and wait for the librarian to hand it back through the window, exactly like a browser requesting a page from a server.
**SA-2:** *(Sample answer)* React doesn't introduce new syntax outside of JavaScript (aside from JSX, which compiles down to JavaScript) — it's a toolbox of pre-written JavaScript code you import and call into your own JavaScript, not a separate language with its own compiler/runtime.

---

# PRIMER 2 QUIZ: Command Line Crash Course

## Multiple Choice

**P2-MC-1.** What does `pwd` do on macOS/Linux?
A) Deletes the current folder
B) Prints the current working directory
C) Lists all files
D) Opens a new terminal

**P2-MC-2.** Which command moves you UP one folder level?
A) `cd .`
B) `cd ~`
C) `cd ..`
D) `cd /`

**P2-MC-3.** What does `mkdir -p a/b/c` do?
A) Deletes folders a, b, and c
B) Creates nested folders, including any missing parent folders
C) Lists the contents of folder a
D) Renames folder a to c

**P2-MC-4.** What is the Windows equivalent of macOS/Linux's `ls`?
A) `cd`
B) `dir`
C) `pwd`
D) `mkdir`

**P2-MC-5.** What should you do if a terminal appears to be "stuck" running `npm run dev` forever?
A) Force-restart your computer
B) This is normal — it's a long-running dev server; leave it running or press Ctrl+C to stop it
C) Reinstall Node.js immediately
D) Close the terminal window without saving

**P2-MC-6.** `cd ~` does what?
A) Moves up exactly one directory
B) Jumps to your home folder from anywhere
C) Lists hidden files
D) Deletes the current directory

**P2-MC-7.** What does the error `command not found: nppm` most likely indicate?
A) A broken operating system
B) A typo in the command name
C) A missing internet connection
D) A corrupted hard drive

## True / False

**P2-TF-1.** "Directory" and "folder" mean the same thing. (True/False)

**P2-TF-2.** `rm` on macOS/Linux typically sends deleted files to a Recycle Bin/Trash, so deletions are always recoverable. (True/False)

**P2-TF-3.** Ctrl+C stops a currently running terminal command. (True/False)

**P2-TF-4.** It's abnormal to have more than one terminal tab open at the same time. (True/False)

**P2-TF-5.** `ls` and `dir` serve the same basic purpose, just on different operating systems. (True/False)

## Fill in the Blank

**P2-FB-1.** A ____________ (also called a command line, console, or shell) is a window where you type instructions as text.

**P2-FB-2.** The folder a terminal is currently "located" in is called the ____________.

**P2-FB-3.** `____________` creates a new folder inside your current location.

**P2-FB-4.** The keyboard shortcut ____________ stops a long-running command.

## Debug It

**P2-DBG-1.** A student runs `cd Dcouments` and gets `cd: no such file or directory: Dcouments`. What is the most likely cause, and how should they fix it?

**P2-DBG-2.** A student is worried their computer has "frozen" because after running `npm run dev`, the terminal never returns to a normal prompt. Explain why this is expected behavior.

## Short Answer

**P2-SA-1.** Why does this series recommend "one tab per long-running process" starting around Phase 4?

**P2-SA-2.** Explain, in your own words, why terminal deletions (`rm`/`del`) deserve more caution than deleting a file via a graphical file explorer.

---

## PRIMER 2 ANSWER KEY

**MC:** 1-B, 2-C, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-True, 2-False (no Recycle Bin/Trash safety net by default — deletions are typically immediate and permanent), 3-True, 4-False (multiple tabs is completely normal, especially from Phase 4 onward), 5-True

**FB:** 1. terminal 2. working directory 3. `mkdir` 4. Ctrl+C (or Cmd+C context aside, but Ctrl+C is standard across all)

**DBG-1:** Likely a typo (`Dcouments` instead of `Documents`). Fix: run `ls`/`dir` to see the exact correct spelling of what's actually there, then retry `cd` with the correct name.
**DBG-2:** Many development tools (dev servers, watchers) are designed to run indefinitely, actively watching for changes — this is not a freeze. The terminal returns to a normal prompt only after the process is stopped (e.g., via Ctrl+C).

**SA-1:** *(Sample answer)* From Phase 4 onward, multiple long-running processes (frontend dev server, mock backend, later the test runner) must all run simultaneously; keeping each in its own dedicated tab avoids confusion about which output belongs to which process and lets you stop/restart one without affecting the others.
**SA-2:** *(Sample answer)* Terminal deletions are typically immediate and permanent, with no Recycle Bin/Trash safety net by default — unlike a graphical file explorer, there's no easy "undo" once you press Enter on an `rm`/`del` command.

---

# PRIMER 3 QUIZ: Setting Up Your Code Editor

## Multiple Choice

**P3-MC-1.** What does ESLint primarily do?
A) Automatically reformats your code's spacing
B) Flags likely logic/pattern mistakes as you type
C) Compiles JSX into JavaScript
D) Runs your test suite

**P3-MC-2.** What does Prettier primarily do?
A) Checks your code's logic for mistakes
B) Automatically and consistently reformats your code's style
C) Installs new npm packages
D) Manages Git commits

**P3-MC-3.** Which terminal command opens the current folder directly in VS Code?
A) `vscode .`
B) `code .`
C) `open .`
D) `editor .`

**P3-MC-4.** Which VS Code area shows your project's folder/file tree?
A) The Status Bar
B) The Activity Bar
C) The Explorer
D) The Integrated Terminal

**P3-MC-5.** To enable automatic formatting on save, which two settings must you configure?
A) "Auto Save" and "Tab Size"
B) "Format On Save" (enabled) and "Default Formatter" (set to Prettier)
C) "Font Size" and "Bracket Pair Colorization"
D) "ESLint: Enable" and "Git: Auto Fetch"

**P3-MC-6.** What keyboard shortcut opens VS Code's Command Palette?
A) Ctrl/Cmd+S
B) Ctrl/Cmd+P
C) Ctrl/Cmd+Shift+P
D) Ctrl/Cmd+F

## True / False

**P3-TF-1.** ESLint and Prettier do the exact same job, so installing both is redundant. (True/False)

**P3-TF-2.** The integrated terminal in VS Code runs the exact same shell you'd use in a separate terminal application. (True/False)

**P3-TF-3.** Ctrl/Cmd+P is used to search text within the currently open file. (True/False)

**P3-TF-4.** You must use VS Code specifically to follow this tutorial series; no other editor will work. (True/False)

## Fill in the Blank

**P3-FB-1.** ____________ colors different parts of your code differently based on their meaning.

**P3-FB-2.** ____________ are add-ons that give VS Code new capabilities beyond what it ships with by default.

**P3-FB-3.** The keyboard shortcut ____________ toggles the Integrated Terminal open and closed.

## Debug It

**P3-DBG-1.** A student installed the Prettier extension, confirmed it shows as "Installed," but their files still never reformat automatically on save. Name two settings they might still need to check.

## Short Answer

**P3-SA-1.** Explain the difference in *job* between ESLint and Prettier — what does each one actually check?

---

## PRIMER 3 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-C, 5-B, 6-C

**TF:** 1-False (they do different jobs — logic/mistakes vs. formatting), 2-True, 3-False (Ctrl/Cmd+P jumps to a file by name; Ctrl/Cmd+F searches within the current file), 4-False (any code editor works technically, though the series is written assuming VS Code)

**FB:** 1. Syntax highlighting 2. Extensions 3. `` Ctrl+` `` / `` Cmd+` ``

**DBG-1:** (1) "Editor: Format On Save" may not be enabled, and/or (2) "Editor: Default Formatter" may not be set to "Prettier - Code formatter."

**SA-1:** *(Sample answer)* ESLint checks your code's *logic and patterns* (e.g., Rules of Hooks violations, likely mistakes) and surfaces them as warnings/errors. Prettier only checks and enforces *formatting/style* (indentation, quote style, spacing) — it has no opinion on whether your code's logic is correct.

---

# PRIMER 4 QUIZ: Git & Version Control Basics

## Multiple Choice

**P4-MC-1.** What is the correct three-step core Git workflow, in order?
A) commit → add → init
B) init → add → commit
C) add → init → commit
D) push → add → commit

**P4-MC-2.** What is the primary difference between Git and GitHub?
A) They are identical products from different companies
B) Git is the tool tracking history locally; GitHub is a website hosting a copy of that history online
C) GitHub replaces the need for Git entirely
D) Git only works with GitHub, never independently

**P4-MC-3.** What does `git status` do?
A) Permanently deletes uncommitted changes
B) Shows what's changed, staged, and untracked since the last commit
C) Uploads your commits to GitHub
D) Creates a new branch

**P4-MC-4.** What is the purpose of a `.gitignore` file?
A) To list files that should always be committed first
B) To list files/folders Git should never track
C) To rename files before committing
D) To automatically write commit messages

**P4-MC-5.** What does `git checkout -b my-feature` do?
A) Deletes the `my-feature` branch
B) Creates a new branch called `my-feature` and switches to it
C) Merges `my-feature` into `main`
D) Pushes `my-feature` to GitHub

**P4-MC-6.** Which of the following is typically included in `.gitignore` for a Vite/React project?
A) `App.jsx`
B) `node_modules`
C) `package.json`
D) `README.md`

**P4-MC-7.** What must you run once, per machine, before your very first commit ever?
A) `git push`
B) `git config --global user.name` and `user.email`
C) `git branch`
D) `git clone`

## True / False

**P4-TF-1.** Once something is committed in Git, it is essentially never truly lost, even much later. (True/False)

**P4-TF-2.** `git add .` immediately uploads your changes to GitHub. (True/False)

**P4-TF-3.** Branches let you work on a change in isolation without affecting the main, working version of the project. (True/False)

**P4-TF-4.** `git init` should typically be run many times throughout a single project's life. (True/False)

**P4-TF-5.** `node_modules` should typically be committed to Git so collaborators don't need to run `npm install`. (True/False)

## Fill in the Blank

**P4-FB-1.** Git's core mental model is often compared to a ____________, where every page is a complete snapshot of the project at a specific moment.

**P4-FB-2.** Choosing which changed files will be included in the next snapshot is called ____________.

**P4-FB-3.** `git ____________ -m "message"` takes the actual permanent snapshot.

**P4-FB-4.** `git remote add origin <url>` registers a saved reference to a repository hosted elsewhere, conventionally named ____________.

## Debug It

**P4-DBG-1.** A student runs `git init`, then immediately `git commit -m "first commit"`, and is confused that `git log` shows no commits at all. What step did they skip?

**P4-DBG-2.** A student's GitHub repository shows a `node_modules` folder with thousands of files after their first push. What's misconfigured?

## Short Answer

**P4-SA-1.** Explain, in your own words, why branches are compared to "alternate timelines in a choose-your-own-adventure book."

**P4-SA-2.** Why is writing a clear, specific commit message (rather than "updates" or "fix") described as a genuinely valuable habit?

---

## PRIMER 4 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-True, 2-False (`git add .` only stages changes locally; `git push` is what uploads to GitHub), 3-True, 4-False (`git init` is run only ONCE, at the very start of a project), 5-False (it should be gitignored — it's regeneratable via `npm install` and shouldn't be committed)

**FB:** 1. photo album 2. staging 3. `commit` 4. `origin`

**DBG-1:** They skipped `git add` — nothing was staged before the commit, so there was nothing to snapshot.
**DBG-2:** Missing or incomplete `.gitignore` — it should list `node_modules` so Git never tracks or commits it.

**SA-1:** *(Sample answer)* Just like exploring one path in a choose-your-own-adventure book doesn't erase or affect the other paths, working on a branch lets you fully explore a change (or abandon it if it doesn't work out) without ever affecting `main` — the "main timeline" — until you deliberately choose to merge it back in.
**SA-2:** *(Sample answer)* Months later, scrolling back through `git log`, a specific message like "Add task toggle functionality" instantly tells future-you (or a teammate) exactly what changed and why, whereas "updates" or "fix" provides no useful information at all.

---

# PART 0 QUIZ: Introduction

## Multiple Choice

**P0-MC-1.** What single app is built continuously across the entire series?
A) A weather dashboard
B) A Task & Habit Tracker
C) A blog platform
D) An e-commerce store

**P0-MC-2.** Which build tool does this series use?
A) Webpack
B) Create React App
C) Vite
D) Parcel

**P0-MC-3.** Which testing tools are introduced in Phase 8?
A) Jest and Enzyme
B) Vitest and React Testing Library
C) Mocha and Chai
D) Cypress and Playwright

**P0-MC-4.** Where is the app ultimately deployed?
A) AWS EC2
B) Vercel's free Hobby plan
C) A self-hosted VPS
D) Netlify's paid tier

**P0-MC-5.** Which of these is NOT one of the six "New in React 19" features explicitly flagged in Part 0?
A) `useActionState`
B) `useOptimistic`
C) `useMemo`
D) `ref` as a regular prop

**P0-MC-6.** What are the four beats every hands-on step in this series follows?
A) Plan, Code, Test, Ship
B) The Target, The Concept, The Implementation, The Verification
C) Read, Write, Run, Debug
D) Design, Build, Review, Deploy

## True / False

**P0-TF-1.** The series assumes readers have significant prior React experience. (True/False)

**P0-TF-2.** Deep conceptual dives and full library API breakdowns are placed in end-of-phase Reference Sections rather than mid-lesson. (True/False)

**P0-TF-3.** Every part of the series builds a separate, disconnected demo app. (True/False)

**P0-TF-4.** Vercel's Hobby plan, as described in this series, includes automatic HTTPS and Git-based deploys for personal projects. (True/False)

## Fill in the Blank

**P0-FB-1.** ____________ is data that a component "remembers" between renders.

**P0-FB-2.** ____________ are information passed into a component from its parent.

**P0-FB-3.** The recurring callout box used to flag React 19-specific features is styled as "🆕 ____________."

## Short Answer

**P0-SA-1.** List the nine Phases of this series in order, by name only (no need to list every Part).

**P0-SA-2.** Explain why the series intentionally builds ONE continuously-growing app instead of many small, isolated demos.

---

## PART 0 ANSWER KEY

**MC:** 1-B, 2-C, 3-B, 4-B, 5-C (useMemo is a Phase 9 performance tool, not one of the six flagged React 19 features — those are Actions, useActionState, useFormStatus, useOptimistic, use, and ref-as-a-prop), 6-B

**TF:** 1-False (assumes NO prior React experience), 2-True, 3-False (one continuously-growing app, not disconnected demos), 4-True

**FB:** 1. State 2. Props 3. New in React 19

**SA-1:** Phase 1: Foundations, Phase 2: Interactivity, Phase 3: Forms & Data, Phase 4: Data Fetching, Phase 5: App-Wide State, Phase 6: Navigation, Phase 7: Advanced Patterns, Phase 8: Quality, Phase 9: Production.
**SA-2:** *(Sample answer)* Building one continuous app lets learners see how components, state, forms, data fetching, routing, and modern React features genuinely fit together in a real product — rather than learning isolated tricks with no sense of how they combine into an actual working application.

---
```
[GENERATED: Quiz Bank Batch 1 — Primers 1–4 + Part 0]
[STARTING: Quiz Bank Batch 2 — Phase 1: Foundations (Parts 1–3)]
```

# PHASE 1, PART 1 QUIZ: Why React Exists & Setting Up Vite

## Multiple Choice

**1.1-MC-1.** What core philosophy does React's rendering model embody?
A) Imperative — manually specify every DOM change
B) Declarative — describe the desired result, let React handle updates
C) Procedural — write step-by-step scripts for the server
D) Object-oriented — model the DOM as classes

**1.1-MC-2.** What command scaffolds a new Vite + React project?
A) `npm install react`
B) `npm create vite@latest task-habit-tracker -- --template react`
C) `npx create-react-app task-habit-tracker`
D) `npm init vite-react`

**1.1-MC-3.** What is Hot Module Replacement (HMR)?
A) A server-side caching technique
B) A feature that updates the browser instantly on file save, without a full reload
C) A way to hot-swap physical server hardware
D) A CSS animation technique

**1.1-MC-4.** In `index.html`, what is the purpose of `<div id="root"></div>`?
A) It displays a loading spinner
B) It's the single container that React injects the entire app into
C) It's a leftover unused element
D) It stores environment variables

**1.1-MC-5.** What does `createRoot(document.getElementById('root')).render(<App />)` do?
A) Deletes the root element
B) Claims the root DOM element and renders the App component tree into it
C) Creates a new HTML file
D) Installs React as a dependency

**1.1-MC-6.** Which file should NEVER be manually edited?
A) `App.jsx`
B) `package.json`
C) `package-lock.json`
D) `index.css`

**1.1-MC-7.** Why does this series use Vite instead of Create React App?
A) Vite is older and more stable
B) Create React App is no longer actively maintained; Vite is the current recommended approach and is faster
C) Vite doesn't support React
D) Create React App requires a paid license

**1.1-MC-8.** What does `npm install` actually do?
A) Starts the development server
B) Downloads every dependency listed in package.json into node_modules
C) Builds the app for production
D) Runs the test suite

## True / False

**1.1-TF-1.** `node_modules` should be committed to Git so the exact dependency versions are preserved. (True/False)

**1.1-TF-2.** `StrictMode` renders visible UI on the page. (True/False)

**1.1-TF-3.** `package-lock.json` is auto-generated and records the exact version of every installed package. (True/False)

**1.1-TF-4.** React apps are called Single Page Applications because there is genuinely only one real HTML page, with React swapping content in and out of it. (True/False)

**1.1-TF-5.** A production-ready web page requires HTML, CSS, and JavaScript to all work together for full functionality. (True/False)

## Fill in the Blank

**1.1-FB-1.** ____________ is a program that lets JavaScript run directly on a computer, outside a browser.

**1.1-FB-2.** ____________ comes bundled with Node.js and fetches packages from the internet into your project.

**1.1-FB-3.** The command ____________ starts Vite's local development server.

**1.1-FB-4.** `react-dom` is specifically responsible for putting React content into a real browser ____________.

## Code Output / Behavior Prediction

**1.1-CO-1.** Given this snippet, what will the browser display?
```jsx
function App() {
  return (
    <div>
      <h1>Hello</h1>
    </div>
  )
}
export default App
```

**1.1-CO-2.** A student runs `npm run dev`, then edits `App.jsx`'s heading text and saves, WITHOUT manually refreshing the browser. What should happen?

## Debug It

**1.1-DBG-1.** A student runs `npm run dev` immediately after `npm create vite@latest`, but skips `npm install` entirely, and sees `Error: Cannot find module 'react'`. What's the fix?

**1.1-DBG-2.** A student's browser shows a completely blank white page with no visible content, and no console errors are checked. What's the very first troubleshooting step recommended by this Part?

## Short Answer

**1.1-SA-1.** Explain the "repaint the whole wall" analogy for why raw DOM manipulation becomes unwieldy at scale.

**1.1-SA-2.** Why does the tutorial say React "earns its keep" specifically when a UI has to change over time in response to data?

---

## PHASE 1, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-C, 7-B, 8-B

**TF:** 1-False (never commit node_modules; package-lock.json handles version pinning), 2-False (StrictMode renders no visible UI at all), 3-True, 4-True, 5-True

**FB:** 1. Node.js 2. npm 3. `npm run dev` 4. DOM

**CO-1:** A page showing "Hello" as a top-level heading, nothing else.
**CO-2:** The browser should update automatically, near-instantly, showing the new heading text — this is Vite's Hot Module Replacement, requiring no manual refresh.

**DBG-1:** Run `npm install` to download React and all other listed dependencies into `node_modules` before attempting to run the dev server.
**DBG-2:** Open browser DevTools (F12) → Console tab and read the error message — it typically names the exact file and line where a JavaScript error was thrown during render.

**SA-1:** *(Sample answer)* Manually keeping a UI in sync with changing data using raw DOM manipulation is like scraping off and re-sticking every sticky note on a wall just to update one word on one note — inefficient and error-prone as the number of "notes" (UI elements) grows. React instead finds and updates just the one thing that changed.
**SA-2:** *(Sample answer)* For static content that never changes, React's overhead (a library to load, concepts to learn) isn't worth it. React's value comes specifically from automating the "keep the screen in sync with the data" problem, which only exists when the UI actually needs to update in response to changing data over time.

---

# PHASE 1, PART 2 QUIZ: JSX Syntax & Your First Components

## Multiple Choice

**1.2-MC-1.** What does JSX actually compile down to?
A) Raw HTML strings
B) `React.createElement()` function calls
C) CSS stylesheets
D) A separate templating language's syntax

**1.2-MC-2.** Which of the following is valid JSX?
A) `<img src="pic.png">`
B) `<img src="pic.png" />`
C) `<br>`
D) `<div class="card">`

**1.2-MC-3.** Why must JSX use `className` instead of `class`?
A) `className` is shorter to type
B) `class` is a reserved word in JavaScript (used for class declarations)
C) `className` is required by CSS
D) There is no actual reason; it's arbitrary

**1.2-MC-4.** What is a Fragment (`<>...</>`) used for?
A) Adding extra styling to a group of elements
B) Grouping elements without adding an extra DOM node
C) Creating a new component
D) Importing external libraries

**1.2-MC-5.** Why must component function names be capitalized?
A) It's purely a stylistic convention with no functional effect
B) The JSX compiler uses capitalization to distinguish real HTML tags from custom components
C) Lowercase function names cause syntax errors
D) It makes autocomplete faster

**1.2-MC-6.** Which of these is a valid expression, usable directly inside JSX `{ }`?
A) `if (x) { return y }`
B) `for (let i = 0; i < 5; i++) {}`
C) `x > 5 ? 'big' : 'small'`
D) `const x = 5`

## True / False

**1.2-TF-1.** A component can return multiple sibling elements with no shared parent wrapper. (True/False)

**1.2-TF-2.** `React.createElement(type, props, ...children)` builds a plain JavaScript object describing what should be rendered — it does not directly touch the real DOM. (True/False)

**1.2-TF-3.** Statements like `if` and `for` can be used directly inside JSX curly braces `{ }`. (True/False)

**1.2-TF-4.** `<Navbar />` and `<navbar />` behave identically in JSX. (True/False)

## Fill in the Blank

**1.2-FB-1.** ____________ is a syntax extension that lets you write HTML-looking markup directly inside JavaScript.

**1.2-FB-2.** Inside JSX, `{ }` drops back into plain JavaScript ____________ mode.

**1.2-FB-3.** A component is just a JavaScript function that returns ____________.

## Code Output / Behavior Prediction

**1.2-CO-1.** What will this component render on screen?
```jsx
function Greeting() {
  const name = "Alex"
  return <p>Hello, {name}! 2 + 2 = {2 + 2}</p>
}
```

**1.2-CO-2.** What error would this cause, and why?
```jsx
function Broken() {
  return (
    <h1>Title</h1>
    <p>Subtitle</p>
  )
}
```

## Debug It

**1.2-DBG-1.** A student writes a component: `function navbar() { return <nav>Hi</nav> }` and uses it as `<navbar />`. Nothing crashes, but the navbar content never appears. What's wrong?

**1.2-DBG-2.** A student writes `<div class="card">` inside a `.jsx` file and gets a console warning. What's the fix?

## Short Answer

**1.2-SA-1.** Explain, using the "blueprint vs. built house" analogy, the relationship between `React.createElement` and the actual DOM.

**1.2-SA-2.** Sketch (in text form, using arrows/indentation) the component tree built in this Part.

---

## PHASE 1, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-C

**TF:** 1-False (must be wrapped in a single parent or Fragment), 2-True, 3-False (only expressions are valid; statements are not), 4-False (lowercase is treated as a real/unknown HTML tag, not the custom component)

**FB:** 1. JSX 2. expression 3. JSX

**CO-1:** "Hello, Alex! 2 + 2 = 4"
**CO-2:** `Adjacent JSX elements must be wrapped in an enclosing tag` — because two sibling elements are returned with no shared parent element or Fragment wrapping them.

**DBG-1:** The component name isn't capitalized, so `<navbar />` is interpreted as an unrecognized real HTML tag rather than a reference to the `navbar` function. Fix: rename the function to `Navbar` and use `<Navbar />`.
**DBG-2:** Change `class="card"` to `className="card"` — `class` is a reserved JavaScript keyword.

**SA-1:** *(Sample answer)* `React.createElement` produces a description (the blueprint) of what should exist — it doesn't build anything real yet. React itself is the construction crew that reads that blueprint and actually builds/updates the real DOM (the house) to match it.
**SA-2:** 
```
App
├── Navbar
└── Dashboard
    ├── HabitsSection → HabitCard (×2)
    └── TasksSection → TaskCard (×3)
```

---

# PHASE 1, PART 3 QUIZ: Props — Passing Data Into Components

## Multiple Choice

**1.3-MC-1.** What are props, fundamentally?
A) A component's internal, private variables
B) Function arguments, bundled into a single object
C) CSS class names
D) Global variables shared across the whole app

**1.3-MC-2.** What is the golden rule about props stated in this Part?
A) Props can be freely reassigned inside the receiving component
B) Props are read-only; a component must never modify the props object it receives
C) Props must always be numbers
D) Props are optional and rarely used in real apps

**1.3-MC-3.** What does the `children` prop capture?
A) Only text content, never other components
B) Whatever JSX is placed between a component's opening and closing tags
C) The component's internal state
D) A list of all sibling components

**1.3-MC-4.** In `function HabitCard({ streak = 0 })`, when is the default value `0` actually used?
A) Always, regardless of what's passed
B) Only when the `streak` prop is missing/undefined
C) Only when `streak` is explicitly set to `0`
D) Never — defaults don't work this way in JSX

**1.3-MC-5.** What problem does "prop drilling" refer to?
A) Props being deleted accidentally
B) Manually passing data down through several layers of components, even when intermediate layers don't use it
C) A security vulnerability in React
D) CSS styles conflicting between components

**1.3-MC-6.** Which JavaScript feature is used to pull specific properties out of a props object into named variables?
A) Spread operator
B) Destructuring
C) Template literals
D) Array.prototype.map

## True / False

**1.3-TF-1.** A parent component decides WHAT data to pass; a child decides HOW to display it. (True/False)

**1.3-TF-2.** If a required prop is missing and has no default value, accessing it typically results in `undefined`. (True/False)

**1.3-TF-3.** `Badge` needed to know exactly what kind of content it would wrap in order to function correctly. (True/False)

**1.3-TF-4.** Prop drilling is described as a real, recognized problem that gets worse as component trees grow deeper. (True/False)

## Fill in the Blank

**1.3-FB-1.** ____________ are information passed into a component from its parent, bundled into a single object argument.

**1.3-FB-2.** `{ isComplete: initialIsComplete = false }` is an example of destructuring with ____________.

**1.3-FB-3.** The special, automatically-provided prop that captures content between a component's tags is called ____________.

## Code Output / Behavior Prediction

**1.3-CO-1.** Given:
```jsx
function HabitCard({ label, streak = 0 }) {
  return <p>{label}: {streak}</p>
}
// Used as: <HabitCard label="Drink water" />
```
What text renders?

**1.3-CO-2.** Given:
```jsx
<Badge tone="streak">🔥 5</Badge>
```
What is the value of `props.children` inside `Badge`?

## Debug It

**1.3-DBG-1.** Inside a component, a student writes:
```jsx
function HabitCard({ label }) {
  label = label.toUpperCase()
  return <p>{label}</p>
}
```
What rule does this violate, and what's the safe fix?

**1.3-DBG-2.** A student renders `<Badge />` with no content between opening/closing tags (self-closed), then tries to read `props.children` inside `Badge`, expecting text. What will `props.children` actually be, and why?

## Short Answer

**1.3-SA-1.** Explain why props are compared to "a sealed parcel handed to you by a courier."

**1.3-SA-2.** Name two real solutions to prop drilling mentioned in this Part's Reference Section, and which later Phase actually implements one of them.

---

## PHASE 1, PART 3 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B

**TF:** 1-True, 2-True, 3-False (Badge is generic and doesn't need to know what it wraps — that's the whole point of `children`), 4-True

**FB:** 1. Props 2. renaming (with a default value) 3. `children`

**CO-1:** "Drink water: 0" (streak defaults to 0 since it wasn't passed)
**CO-2:** `"🔥 5"` (the string/content between the opening and closing tags)

**DBG-1:** Violates "props are read-only" — never reassign a prop directly. Safe fix: compute a new local variable instead, e.g. `const displayLabel = label.toUpperCase()`, and render `{displayLabel}`.
**DBG-2:** `props.children` will be `undefined`, because self-closing a component (`<Badge />`) means nothing was placed between opening and closing tags — there is no content to capture.

**SA-1:** *(Sample answer)* Just as you're welcome to look inside a sealed parcel a courier hands you but shouldn't rearrange the courier's other packages or repack the box and call it "the original," a component can read and use its props but should never modify the props object itself — that data belongs to the parent.
**SA-2:** *(Sample answer)* (1) Component composition (passing components as `children` or other props to reduce how many layers data must travel through) and (2) the Context API — implemented later in Phase 5, Part 1.

---
```
[GENERATED: Quiz Bank Batch 2 — Phase 1: Foundations]
[STARTING: Quiz Bank Batch 3 — Phase 2: Interactivity (Parts 1–3)]
```

# PHASE 2, PART 1 QUIZ: State with useState

## Multiple Choice

**2.1-MC-1.** Why does a plain `let` variable fail to act as "memory" inside a component?
A) `let` variables are read-only
B) The component function re-runs from scratch every render, resetting the variable
C) `let` variables can't hold booleans
D) React deletes `let` variables automatically

**2.1-MC-2.** What does `useState` return?
A) A single value
B) An array of exactly two items: the current value and an updater function
C) An object with ten properties
D) A Promise

**2.1-MC-3.** What are the two things calling a state setter function actually does?
A) Deletes the component and recreates it
B) Updates React's stored value AND schedules a re-render
C) Only logs the new value to the console
D) Only updates the DOM directly, bypassing React

**2.1-MC-4.** Which of the following correctly triggers an event handler on click, WITHOUT calling it immediately during render?
A) `onClick={handleClick()}`
B) `onClick={handleClick}`
C) `onClick="handleClick()"`
D) `onClick={handleClick;}`

**2.1-MC-5.** Why is `setValue((prev) => !prev)` often preferred over `setValue(!value)`?
A) It's shorter to type
B) It guarantees React always uses the most current value, safe against batched updates
C) `setValue(!value)` causes a syntax error
D) There's no actual difference; both are always identical in every case

**2.1-MC-6.** What motivated "lifting state up" in this Part?
A) A desire to make the code longer
B) A feature (remaining count) needed data from ALL habits at once, which no single card's private state could provide
C) React requires all state to live in the root component
D) Local state caused a compiler error

**2.1-MC-7.** Which of the following is a correct immutable update to toggle one habit's completion?
A) `habit.isComplete = !habit.isComplete; setHabits(habits)`
B) `setHabits(habits.map((h) => h.id === id ? { ...h, isComplete: !h.isComplete } : h))`
C) `habits[0].isComplete = true`
D) `setHabits(habits); habits.isComplete = true`

## True / False

**2.1-TF-1.** React tracks hooks by their variable name, not their call order. (True/False)

**2.1-TF-2.** Hooks may be called conditionally, as long as they're inside a component. (True/False)

**2.1-TF-3.** Mutating an object directly and then passing that same object reference to a state setter can cause React to skip re-rendering, since it may see "no change" via reference comparison. (True/False)

**2.1-TF-4.** Once state is lifted up to a parent, the child component becomes purely props-driven and no longer manages that piece of state itself. (True/False)

## Fill in the Blank

**2.1-FB-1.** Moving state to the closest common parent so multiple components can share it is called ____________.

**2.1-FB-2.** The two Rules of Hooks are: only call hooks at the ____________ level, and only call them from ____________ or other custom hooks.

**2.1-FB-3.** `const [value, setValue] = useState(initial)` — this is an example of array ____________.

## Code Output / Behavior Prediction

**2.1-CO-1.** Given:
```jsx
function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```
If a user clicks the button three times quickly, what number is eventually displayed (assuming no batching issues)?

**2.1-CO-2.** Predict what happens with this code:
```jsx
function Broken({ showExtra }) {
  if (showExtra) {
    const [extra, setExtra] = useState(0)
  }
  return <div>{showExtra ? extra : null}</div>
}
```

## Debug It

**2.1-DBG-1.**
```jsx
function handleToggle() {
  habit.isComplete = !habit.isComplete
  setHabits(habits)
}
```
The checkbox never visually updates, even though `console.log(habits)` shows the corrected value. Explain exactly why.

**2.1-DBG-2.**
```jsx
<button onClick={setCount(count + 1)}>Increment</button>
```
What React error does this cause, and why?

## Short Answer

**2.1-SA-1.** Explain why React's hook-tracking-by-call-order makes conditional hook calls dangerous.

**2.1-SA-2.** Describe, in your own words, the difference between a component that's "dumb"/props-driven vs. one that manages its own local state.

---

## PHASE 2, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-False (React tracks hooks by CALL ORDER, not name), 2-False (hooks must be called unconditionally, at the top level), 3-True, 4-True

**FB:** 1. lifting state up 2. top / components 3. destructuring

**CO-1:** 3 (assuming each click properly triggers a separate render with the correctly updated value)
**CO-2:** This violates the Rules of Hooks (conditional hook call) — React will likely throw an error or produce inconsistent/corrupted state, because the hook call order shifts depending on whether `showExtra` is true or false between renders.

**DBG-1:** Directly mutating `habit.isComplete` changes the existing object in place. Calling `setHabits(habits)` passes back the exact same array reference that was already there — React compares by reference, sees no change, and skips re-rendering entirely.
**DBG-2:** `Too many re-renders` error — `setCount(count + 1)` is being CALLED immediately during render (because of the parentheses), not passed as a function reference, causing an infinite loop of state updates during rendering itself.

**SA-1:** *(Sample answer)* React associates each `useState`/`useEffect`/etc. call with its position in the sequence of hook calls, not by any name. If a hook is sometimes skipped (e.g., inside an `if`), that sequence shifts between renders, so React can attach the wrong stored value to the wrong hook call, causing corrupted state or crashes.
**SA-2:** *(Sample answer)* A "dumb"/props-driven component receives everything it needs (data + callback functions) via props and has no internal state of its own — it just displays what it's told and reports events upward. A component managing its own local state has internal memory (via `useState`) that only it can see and control, appropriate when no sibling/parent needs to know about that value.

---

# PHASE 2, PART 2 QUIZ: Rendering Lists with .map()

## Multiple Choice

**2.2-MC-1.** What two problems does manually writing `habits[0]`, `habits[1]`, `habits[2]` have?
A) It's too fast and causes race conditions
B) It doesn't scale up (new items don't show) or down (crashes on shorter arrays)
C) It requires too much CSS
D) It only works with strings, not objects

**2.2-MC-2.** What does `.map()` return?
A) The original array, modified in place
B) A brand new array, same length as the original, with each item transformed
C) A single value
D) `undefined`

**2.2-MC-3.** What is the `key` prop used for?
A) Encrypting component data
B) Helping React track which item is which across re-renders, reorders, and changes
C) Displaying a label on screen
D) Setting a component's CSS class

**2.2-MC-4.** Why is `key={Math.random()}` worse than having no key at all?
A) `Math.random()` is too slow
B) It generates a NEW value every render, telling React every item is "different" every single time
C) `Math.random()` isn't a valid JavaScript function
D) It causes a syntax error

**2.2-MC-5.** In the Key Experiment, what happened when using array index as key and then reordering the list?
A) Nothing — the app crashed
B) Typed text stayed attached to the visual POSITION, not the actual person, causing it to appear next to the wrong name after reordering
C) The list disappeared entirely
D) All items merged into one

**2.2-MC-6.** Which array method returns the FIRST matching item itself (not a new array)?
A) `.map()`
B) `.filter()`
C) `.find()`
D) `.forEach()`

**2.2-MC-7.** When is using array index as `key` considered acceptable?
A) Always, in every situation
B) Only when the list is never reordered/filtered/inserted-into-the-middle and has no per-item local state
C) Never, under any circumstances
D) Only for lists longer than 100 items

## True / False

**2.2-TF-1.** `.filter()` can return a shorter array than the original. (True/False)

**2.2-TF-2.** React displays the `key` prop's value visibly on screen, similar to a label. (True/False)

**2.2-TF-3.** `.map()`, `.filter()`, and `.find()` all mutate (change) the original array. (True/False)

**2.2-TF-4.** `key` must be placed on the outermost element returned directly inside the `.map()` callback. (True/False)

## Fill in the Blank

**2.2-FB-1.** `.map()` is compared to an ____________ line: raw material goes in, a machine processes each item the same way, finished products come out.

**2.2-FB-2.** The `key` prop is compared to a "____________," not a "seat number."

**2.2-FB-3.** `.____()` returns `true` if AT LEAST ONE item in the array matches a condition.

**2.2-FB-4.** `.____()` returns `true` only if ALL items in the array match a condition.

## Code Output / Behavior Prediction

**2.2-CO-1.** Given:
```javascript
const tasks = [{ id: 1, done: false }, { id: 2, done: true }]
const result = tasks.filter((t) => t.done)
```
What is the length of `result`?

**2.2-CO-2.** Given:
```javascript
const numbers = [1, 2, 3]
const doubled = numbers.map((n) => n * 2)
console.log(numbers)
```
What does `console.log(numbers)` print — the original array, or the doubled one?

## Debug It

**2.2-DBG-1.** A student's todo list has a bug: after deleting an item from the middle of the list, editing a DIFFERENT task's text field sometimes shows the wrong task's text. Their code uses `key={index}` inside `.map()`. What's the fix?

**2.2-DBG-2.**
```jsx
{habits.map((habit) => (
  <div>
    <HabitCard key={habit.id} label={habit.label} />
  </div>
))}
```
Where should the `key` prop actually be placed here, and why is its current placement a problem?

## Short Answer

**2.2-SA-1.** Explain the classroom "seat number vs. name tag" analogy for the `key` prop.

**2.2-SA-2.** List three array methods, besides `.map()` and `.filter()`, covered in this Part's Reference Section, and briefly describe what each returns.

---

## PHASE 2, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-C, 7-B

**TF:** 1-True, 2-False (key is never displayed; it's purely internal bookkeeping), 3-False (none of them mutate the original array — all return something new), 4-True

**FB:** 1. assembly 2. name tag 3. `.some()` 4. `.every()`

**CO-1:** 1 (only the task with `done: true` passes the filter)
**CO-2:** The original array `[1, 2, 3]` — `.map()` never mutates the original array; `doubled` is an entirely separate new array `[2, 4, 6]`.

**DBG-1:** Switch from `key={index}` to a stable, unique identifier from the actual data, e.g. `key={task.id}`.
**DBG-2:** The `key` should be placed on the `<div>` (the outermost element returned directly inside the `.map()` callback), not on the nested `<HabitCard>`. React reads `key` off the element it's given directly in the list, not off something nested further inside.

**SA-1:** *(Sample answer)* If a teacher only tracks students by "row 2, seat 3" (a seat number/array index), then when students swap seats, the teacher's notes now incorrectly describe whoever is CURRENTLY in that seat, not the original student. If the teacher instead uses each student's actual name tag (a stable, unique id), the notes correctly follow the right student no matter where they sit — exactly how `key` should track the actual data item, not its position in the list.
**SA-2:** *(Sample answer)* `.find()` — returns the first matching item itself, or `undefined` if none match. `.some()` — returns `true` if at least one item matches. `.every()` — returns `true` only if every item matches. (`.reduce()` also acceptable — folds the array into a single accumulated value.)

---

# PHASE 2, PART 3 QUIZ: Event Handling & Conditional Rendering

## Multiple Choice

**2.3-MC-1.** What is "event bubbling"?
A) A CSS animation effect
B) A click event rippling outward through every ancestor element after being triggered
C) A way to delete event listeners
D) A performance optimization technique

**2.3-MC-2.** What does `event.stopPropagation()` do?
A) Prevents the default browser behavior for an event (like form submission)
B) Stops an event from bubbling up to parent element handlers
C) Deletes the event object entirely
D) Cancels a network request

**2.3-MC-3.** Which conditional rendering pattern should you use when you need to render EXACTLY one of two alternatives, always?
A) `condition && <A />`
B) `condition ? <A /> : <B />`
C) An early `return null`
D) A `for` loop

**2.3-MC-4.** What is the well-known "trap" with `count && <Something />`?
A) It always throws a syntax error
B) If `count` is `0`, React renders the literal text "0" instead of nothing
C) It never works with numbers at all
D) It requires `count` to be a string

**2.3-MC-5.** Why should `type="button"` be explicitly set on non-submit buttons inside a `<form>`?
A) It's purely cosmetic
B) Without it, a button defaults to `type="submit"`, potentially triggering unwanted form submission
C) It's required for CSS styling to apply
D) It makes the button run faster

**2.3-MC-6.** Why did `FilterTabs`' active filter state stay LOCAL to `TasksSection` rather than being lifted to `App`?
A) React doesn't allow filter state to be lifted
B) No sibling or parent component needed to know about or react to that specific value
C) It was a mistake that should be fixed later
D) Local state is always faster than lifted state

## True / False

**2.3-TF-1.** Clicking a nested element's `onClick` handler will also trigger any ancestor elements' `onClick` handlers, unless bubbling is stopped. (True/False)

**2.3-TF-2.** `event.preventDefault()` and `event.stopPropagation()` do the exact same thing. (True/False)

**2.3-TF-3.** An early `return` inside a component is best used when the component's ENTIRE output should differ dramatically based on a condition. (True/False)

**2.3-TF-4.** `condition > 0 && <Something />` avoids the "renders 0" trap that `condition && <Something />` can hit. (True/False)

## Fill in the Blank

**2.3-FB-1.** ____________ is compared to a pebble dropped in a pond, rippling outward through ancestor elements.

**2.3-FB-2.** `event.____________()` stops an event from bubbling further up the DOM tree.

**2.3-FB-3.** A ____________ expression always produces exactly one of two values.

## Code Output / Behavior Prediction

**2.3-CO-1.** Given:
```jsx
const streak = 0
return <p>{streak && <span>On fire!</span>}</p>
```
What does this render on screen?

**2.3-CO-2.** Given:
```jsx
<div onClick={handleCardClick}>
  <span onClick={(e) => { e.stopPropagation(); handleBadgeClick() }}>Badge</span>
</div>
```
If a user clicks the `<span>` (Badge), which handler(s) fire?

## Debug It

**2.3-DBG-1.** A student's "like count" badge shows the literal text `0` when there are no likes, instead of nothing. Their code: `{likeCount && <span>{likeCount} likes</span>}`. What's the one-word category of fix needed?

**2.3-DBG-2.** A `<button>` inside a `<form>`, intended only to open a modal, is instead submitting the form and reloading the page. What attribute is likely missing?

## Short Answer

**2.3-SA-1.** Give an example (not from the tutorial) of a situation where you'd use an early `return` rather than a ternary or `&&`.

**2.3-SA-2.** Explain why `HabitCard`'s streak Badge needed `stopPropagation()` specifically, tracing through what would happen without it.

---

## PHASE 2, PART 3 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B

**TF:** 1-True, 2-False (preventDefault stops default browser behavior; stopPropagation stops event bubbling — different jobs), 3-True, 4-True

**FB:** 1. Event bubbling (bubbling) 2. `stopPropagation` 3. ternary

**CO-1:** Nothing visible — `streak && ...` evaluates to `0` (falsy), but note: since `0` is a number, React actually WOULD render the literal text "0" here, not nothing. *(This is the exact trap covered in this Part — correct answer: it renders the text "0")*
**CO-2:** Only `handleBadgeClick()` fires — `stopPropagation()` inside the span's handler prevents the click from bubbling up to the outer div's `handleCardClick`.

**DBG-1:** Use an explicit comparison instead of relying on truthiness: change to `{likeCount > 0 && <span>{likeCount} likes</span>}`.
**DBG-2:** Missing `type="button"` on the button — without it, the button defaults to `type="submit"`.

**SA-1:** *(Sample answer)* A component showing "haven't loaded yet" vs. a fully rendered UI — e.g., `if (!user) return <LoginPrompt />` before the component's main return statement, entirely replacing the rest of its output.
**SA-2:** *(Sample answer)* Without `stopPropagation()`, clicking the Badge would trigger its own `onClick` (showing the streak alert) AND then bubble up to the surrounding card's `onClick`, which would ALSO toggle the habit's completion — an unintended side effect of a click that was only meant to show streak info.

---
```
[GENERATED: Quiz Bank Batch 3 — Phase 2: Interactivity]
[STARTING: Quiz Bank Batch 4 — Phase 3: Forms & Data (Parts 1–3)]
```

# PHASE 3, PART 1 QUIZ: Controlled Forms

## Multiple Choice

**3.1-MC-1.** What defines a "controlled" input?
A) It has no `value` attribute at all
B) Its `value` is explicitly set from React state, updated via `onChange` on every keystroke
C) It can only be controlled by a mouse, not a keyboard
D) It automatically validates itself without any code

**3.1-MC-2.** What does `event.preventDefault()` do inside a form's submit handler?
A) Deletes the form entirely
B) Stops the browser's default full-page-reload submission behavior
C) Prevents the user from typing
D) Cancels all future form submissions permanently

**3.1-MC-3.** Why is `.trim()` applied to a form label before checking validity?
A) To make the text shorter for storage
B) To prevent a submission of only whitespace from being treated as valid
C) It's required by JSX syntax
D) To convert the text to uppercase

**3.1-MC-4.** What does `crypto.randomUUID()` provide?
A) A way to encrypt form data
B) A long, essentially-guaranteed-unique string, suitable for new item IDs
C) A password hashing function
D) A CSS class generator

**3.1-MC-5.** Why is `tasks.length + 1` a bad strategy for generating new item IDs?
A) It's too slow to compute
B) It can produce a duplicate ID once items have been deleted from the middle of a list
C) JavaScript doesn't support addition on array lengths
D) It only works for arrays with fewer than 10 items

**3.1-MC-6.** What is the correct way to add a new item to a list immutably?
A) `tasks.push(newTask)`
B) `setTasks([...tasks, newTask])`
C) `tasks[tasks.length] = newTask`
D) `tasks.newTask = true`

## True / False

**3.1-TF-1.** In a controlled input, the browser's DOM manages the current value internally, independent of React. (True/False)

**3.1-TF-2.** `onSubmit` should typically be attached to the `<form>` element itself, not just the submit button, so pressing Enter also submits. (True/False)

**3.1-TF-3.** File inputs (`<input type="file">`) can be fully controlled by React, with their value set programmatically. (True/False)

**3.1-TF-4.** `disabled={!isValid}` on a submit button is an example of validation logic living in plain JavaScript rather than scattered HTML attributes. (True/False)

## Fill in the Blank

**3.1-FB-1.** A ____________ input has its value explicitly set from React state, with every keystroke captured via `onChange`.

**3.1-FB-2.** `event.____________()` stops a form's default full-page-reload submission behavior.

**3.1-FB-3.** `.____________()` removes leading/trailing whitespace from a string.

## Code Output / Behavior Prediction

**3.1-CO-1.** Given:
```jsx
const [label, setLabel] = useState('')
const isValid = label.trim().length > 0
// User types three spacebar presses only
```
What is the value of `isValid`?

**3.1-CO-2.** Given:
```jsx
function handleSubmit(event) {
  onAddTask(trimmedLabel)
  setLabel('')
}
```
If this handler is missing `event.preventDefault()` at the top, what will likely happen when the form is submitted?

## Debug It

**3.1-DBG-1.**
```jsx
const isValid = label.trim().length > 0
<button disabled={isValid}>Add</button>
```
The Add button never becomes clickable, no matter what is typed. What's the exact bug?

**3.1-DBG-2.** A student generates new task IDs using `id: tasks.length + 1`. After adding and then deleting several tasks in various orders, they start seeing duplicate-key warnings in the console. Explain why.

## Short Answer

**3.1-SA-1.** Explain the "puppet, with React holding the strings" analogy for controlled inputs.

**3.1-SA-2.** List three specific benefits of using controlled inputs mentioned in this Part (beyond "just reading the value").

---

## PHASE 3, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B

**TF:** 1-False (in a CONTROLLED input, React state manages the value, not the DOM independently — that's an UNCONTROLLED input), 2-True, 3-False (file inputs cannot have their value set programmatically, for security reasons — they're effectively always uncontrolled), 4-True

**FB:** 1. controlled 2. `preventDefault` 3. `trim`

**CO-1:** `false` — `.trim()` removes the spaces, leaving an empty string of length 0.
**CO-2:** The page will fully reload, since the browser's default form submission behavior (a full page reload) was never prevented.

**DBG-1:** The `disabled` condition is inverted — it should read `disabled={!isValid}` (disable when NOT valid), not `disabled={isValid}` (which disables when it IS valid).
**DBG-2:** `tasks.length + 1` doesn't guarantee uniqueness once items have been deleted — the count-based ID can collide with an ID that already exists among the remaining items, since it depends only on the CURRENT array length, not on which IDs have already been used.

**SA-1:** *(Sample answer)* Just as a puppet's movements are entirely controlled by the puppeteer holding its strings, a controlled input's displayed value is entirely dictated by React state — the input doesn't "decide" anything on its own; it just reflects whatever value React currently holds, updated via onChange with every keystroke.
**SA-2:** *(Sample answer)* (1) Live validation as the user types, (2) conditionally disabling a submit button based on current input validity, (3) programmatically clearing the input after successful submission.

---

# PHASE 3, PART 2 QUIZ: 🆕 Actions & useActionState

## Multiple Choice

**3.2-MC-1.** What makes a function passed to a `<form>`'s `action` prop a React 19 "Action"?
A) It must be named `action`
B) React automatically prevents default reload, collects fields into FormData, and tracks pending state
C) It must return a string
D) It only works with class components

**3.2-MC-2.** What does `useActionState` return?
A) A single value
B) `[state, formAction, isPending]`
C) `[value, setValue]`
D) A Promise directly

**3.2-MC-3.** What are the two arguments an Action function passed to `useActionState` receives?
A) `(event, formData)`
B) `(previousState, formData)`
C) `(props, ref)`
D) `(state, dispatch)`

**3.2-MC-4.** What does `formData.get('label')` always return (assuming the field exists)?
A) A number
B) A string (or a File object for file inputs)
C) A boolean
D) An array

**3.2-MC-5.** Why does the input in an Action-based form typically have no `value` or `onChange`?
A) It's a mistake that should be fixed
B) It's intentionally uncontrolled — React only reads it once, at submission time, via FormData
C) React 19 removed support for controlled inputs
D) `value` is not a valid HTML attribute

**3.2-MC-6.** What package is `useActionState` imported from?
A) `react-dom`
B) `react`
C) `react-router-dom`
D) `react-actions`

## True / False

**3.2-TF-1.** You must manually call `setIsSubmitting(true)` and `setIsSubmitting(false)` when using `useActionState`. (True/False)

**3.2-TF-2.** `useActionState`'s Action function can be synchronous or `async`. (True/False)

**3.2-TF-3.** Controlled inputs and Actions are mutually exclusive — you can never combine them. (True/False)

**3.2-TF-4.** `useActionState` was briefly called `useFormState` during React's experimental/canary releases. (True/False)

## Fill in the Blank

**3.2-FB-1.** Passing a function (instead of a URL string) to a `<form>`'s `action` prop makes it a React 19 ____________.

**3.2-FB-2.** `formData.____()` reads one field's value by its `name` attribute.

**3.2-FB-3.** 🆕 In React 19, submission pending state is tracked ____________ — you never manually call a setter for it.

## Code Output / Behavior Prediction

**3.2-CO-1.** Given:
```jsx
async function addTaskAction(previousState, formData) {
  const label = formData.get('label').trim()
  if (label.length === 0) return { error: 'Required' }
  await onAddTask(label)
  return { error: null }
}
```
If the input is submitted completely empty, what does `state.error` equal after submission?

**3.2-CO-2.** If the Action function above is NOT marked `async` but genuinely contains an `await` inside it, what happens?

## Debug It

**3.2-DBG-1.** A student's form's `isPending` value never becomes `true`, even though there's a genuine 2-second delay inside their Action function. Their function signature: `function addTaskAction(previousState, formData) { ... }`. What's missing?

**3.2-DBG-2.** A student writes `<input value={label} name="label" />` alongside an Action-based form, but never adds an `onChange` handler. What warning will they likely see, and why?

## Short Answer

**3.2-SA-1.** Compare the amount of manual boilerplate needed in Phase 3, Part 1's approach vs. this Part's Action-based approach, for handling form submission pending state.

**3.2-SA-2.** Explain the "job ticket" analogy for what an Action does.

---

## PHASE 3, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B

**TF:** 1-False (isPending is tracked automatically — no manual setter calls needed), 2-False (must be async, or otherwise return a Promise, for isPending to reflect it correctly — actually: it CAN be synchronous, but isPending will only meaningfully reflect pending time if it's async/returns a Promise), 3-False (they can be combined — a controlled input can coexist with an Action, useful for live-typing features), 4-True

**FB:** 1. Action 2. `get` 3. automatically

**CO-1:** `'Required'`
**CO-2:** This would actually be a syntax error — `await` can only be used inside a function explicitly marked `async` (or at the top level of a module). Without `async`, using `await` inside the function body is invalid.

**DBG-1:** The function isn't marked `async` — mark it `async function addTaskAction(...)` so it genuinely returns a Promise, letting `useActionState` correctly track its pending state.
**DBG-2:** Console warning: "You provided a `value` prop to a form field without an `onChange` handler." Because `value` is set but nothing ever updates it, the input becomes effectively read-only from the user's perspective, which React flags as likely unintentional.

**SA-1:** *(Sample answer)* Phase 3, Part 1 required manually declaring `useState` for the input value, an `onChange` handler, `event.preventDefault()`, and (if async work were added) a manually-tracked `isSubmitting` boolean plus `try/catch` around it. This Part's Action-based approach removes ALL of that — `useActionState` handles pending tracking automatically, `FormData` reads the value once at submission, and default page-reload prevention happens automatically.
**SA-2:** *(Sample answer)* Instead of personally supervising every step of a form submission (like preventing reload, collecting field values, tracking whether it's still processing), you write down what needs to happen and hand this "job ticket" (the Action function) to the `<form>` element, and React's machinery handles delivering the raw materials (FormData) and tracking whether the job is still in progress.

---

# PHASE 3, PART 3 QUIZ: 🆕 useFormStatus

## Multiple Choice

**3.3-MC-1.** Which package is `useFormStatus` imported from?
A) `react`
B) `react-dom`
C) `react-router-dom`
D) `react-hooks`

**3.3-MC-2.** What is the one critical, non-negotiable rule about `useFormStatus`?
A) It must be called at the very top of `main.jsx`
B) It must be called from a component that is a DESCENDANT of the `<form>`, never the same component rendering the form
C) It can only be called inside a class component
D) It requires a special Babel plugin to work

**3.3-MC-3.** What analogy is used to describe `useFormStatus`?
A) A locked door with no key
B) An intercom built into the walls of the form, letting any descendant ask "are we busy?"
C) A vending machine
D) A sealed parcel

**3.3-MC-4.** What properties does `useFormStatus()` return?
A) `{ value, onChange }`
B) `{ pending, data, method, action }`
C) `{ error, isLoading }`
D) `{ ref, current }`

**3.3-MC-5.** What problem specifically does extracting `SubmitButton`/`CancelButton`/`FormTextInput` solve?
A) CSS styling conflicts
B) Prop drilling of pending state through every nested piece of a form
C) Slow network requests
D) Memory leaks

**3.3-MC-6.** In the Part's experiment, what did calling `useFormStatus` in the SAME component that renders the `<form>` produce?
A) A crash
B) `pending` always logged as `false`, since it looks for an ANCESTOR form, and there is none at that level
C) `pending` correctly tracked the form's status
D) An infinite loop

## True / False

**3.3-TF-1.** `useFormStatus`'s `pending` and `useActionState`'s `isPending` are read from the exact same location in the component tree. (True/False)

**3.3-TF-2.** After extracting `SubmitButton`, `CancelButton`, and `FormTextInput`, the parent `TaskForm` component no longer needs to track or pass down pending state at all. (True/False)

**3.3-TF-3.** `useFormStatus`'s `data` property can be used to access the FormData currently being submitted. (True/False)

## Fill in the Blank

**3.3-FB-1.** `useFormStatus` must be called from a ____________ of the `<form>`.

**3.3-FB-2.** The analogy used for `useFormStatus` in this Part is an ____________ built into the walls of the form.

## Code Output / Behavior Prediction

**3.3-CO-1.** Given a component that renders `<form>` directly AND calls `useFormStatus` inside that same top-level function (not a nested child), what will `pending` show during a real submission?

## Debug It

**3.3-DBG-1.** A `<SaveIndicator>` component is rendered as a SIBLING of a `<form>` (not nested inside it), and calls `useFormStatus`, expecting to reflect that form's status. It never works. Why not?

**3.3-DBG-2.** A student imports `useFormStatus` from `'react'` instead of `'react-dom'`. What happens?

## Short Answer

**3.3-SA-1.** Compare `useActionState`'s pending value vs. `useFormStatus`'s `pending` — when would you reach for each?

---

## PHASE 3, PART 3 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B

**TF:** 1-False (useActionState is read at the form-OWNING level; useFormStatus is read at any NESTED descendant level — different locations), 2-True, 3-True

**FB:** 1. descendant 2. intercom

**CO-1:** `pending` will remain `false` the entire time — it's looking for an ancestor `<form>`, and since this component IS the one rendering the form (not nested inside it), there is no qualifying ancestor to detect.

**DBG-1:** `useFormStatus` only detects the status of the NEAREST ANCESTOR `<form>` in the actual rendered component tree. A sibling element (not a descendant) has no such ancestor relationship to that form, so it can never reflect its status.
**DBG-2:** An import error — `useFormStatus is not a function` (or similar) — because it doesn't exist in the `'react'` package; it must be imported from `'react-dom'`.

**SA-1:** *(Sample answer)* `useActionState`'s pending value is read at the level that owns/calls the Action itself — useful for logic living alongside the Action. `useFormStatus`'s `pending` can be read from ANY descendant nested inside the form, regardless of depth — ideal for UI pieces nested arbitrarily deep without needing prop drilling.

---
```
[GENERATED: Quiz Bank Batch 4 — Phase 3: Forms & Data]
[STARTING: Quiz Bank Batch 5 — Phase 4: Data Fetching (Parts 1–3)]
```

# PHASE 4, PART 1 QUIZ: useEffect & Fetching Real Data

## Multiple Choice

**4.1-MC-1.** What is a "side effect" in React?
A) A bug caused by incorrect state updates
B) Anything a piece of code does that reaches OUTSIDE a pure, self-contained calculation
C) A CSS animation
D) A type of prop

**4.1-MC-2.** What does an effect's cleanup function do?
A) Deletes the component permanently
B) Runs before the effect re-runs, or when the component unmounts, undoing whatever the effect started
C) Clears the browser's cache
D) Formats the code automatically

**4.1-MC-3.** In the Cleanup Experiment, what happened when the cleanup function was removed?
A) Nothing changed at all
B) Ticks got progressively faster, since old intervals were never cancelled, causing a memory leak
C) The component immediately crashed
D) The console stopped logging entirely

**4.1-MC-4.** What does `json-server` provide?
A) A production-grade, scalable database
B) A tool that serves a plain JSON file as a real, working REST API for local development
C) A CSS preprocessor
D) A testing framework

**4.1-MC-5.** Why must `response.ok` be checked manually after a `fetch()` call?
A) `fetch()` always throws on any error
B) `fetch()` only rejects on true network failures, not on HTTP error statuses like 404/500
C) It's not actually necessary; response.ok is deprecated
D) `response.ok` is only available in Node.js, not browsers

**4.1-MC-6.** What does `Promise.all([fetchHabits(), fetchTasks()])` provide over sequential awaits?
A) It guarantees no errors will ever occur
B) It runs both requests concurrently, so total wait time is roughly the slower one, not the sum
C) It automatically retries failed requests
D) It caches the results permanently

**4.1-MC-7.** Which environment variable prefix does Vite require for a variable to be exposed to browser code?
A) `REACT_APP_`
B) `VITE_`
C) `PUBLIC_`
D) `ENV_`

**4.1-MC-8.** What does the `[]` dependency array on `useEffect` mean?
A) Run on every render
B) Run once, after the initial render
C) Never run at all
D) Run only when the component unmounts

## True / False

**4.1-TF-1.** `fetch()` rejects its Promise whenever the server responds with a 404 or 500 status. (True/False)

**4.1-TF-2.** An effect that starts something "ongoing" (a timer, subscription, or listener) needs a matching cleanup function. (True/False)

**4.1-TF-3.** `isCancelled` flags guard against a real race condition: a late-arriving response updating state after a component has already moved on. (True/False)

**4.1-TF-4.** `.env` files without the `VITE_` prefix are still exposed directly to browser JavaScript code. (True/False)

## Fill in the Blank

**4.1-FB-1.** A ____________ is anything code does that reaches outside a pure calculation.

**4.1-FB-2.** `useEffect`'s ____________ argument controls whether the effect runs once, every render, or when specific values change.

**4.1-FB-3.** `response.____` must be checked manually since `fetch()` doesn't throw on HTTP error statuses.

## Code Output / Behavior Prediction

**4.1-CO-1.** Given:
```jsx
useEffect(() => {
  console.log('mounted')
  return () => console.log('cleanup')
}, [])
```
If this component mounts once and never unmounts, how many times does "mounted" log? How many times does "cleanup" log?

**4.1-CO-2.** A developer stops the `json-server` process while the app is running, then reloads the page. What should happen, based on this Part's error handling (assuming a `try/catch` around the fetch)?

## Debug It

**4.1-DBG-1.**
```jsx
useEffect(() => {
  fetchHabits().then((data) => setHabits(data))
}) // no dependency array at all
```
This causes an infinite loop of requests. Explain exactly why.

**4.1-DBG-2.** A student's `.env` file contains `API_URL=http://localhost:4000` (no `VITE_` prefix). Their code reads `import.meta.env.API_URL` and always gets `undefined`. What's the fix?

## Short Answer

**4.1-SA-1.** Explain the "chef plating a dish, then phoning in tomorrow's order" analogy for pure rendering vs. side effects.

**4.1-SA-2.** Why is the `VITE_` prefix requirement described as "a genuine security boundary," not just a naming convention?

---

## PHASE 4, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B, 8-B

**TF:** 1-False (fetch only rejects on true NETWORK failures, not HTTP error statuses), 2-True, 3-True, 4-False (variables WITHOUT the VITE_ prefix stay invisible to browser code — only VITE_-prefixed ones are exposed)

**FB:** 1. side effect 2. dependency array 3. `ok`

**CO-1:** "mounted" logs once; "cleanup" never logs (only logs on unmount or before the effect re-runs, neither of which occurs here).
**CO-2:** The fetch should fail (a network error, since nothing is listening on that port), the `catch` block should catch it, and — depending on which Part's code is running — either just log it to console (Part 1) or, once Part 2's error state is added, show a genuine user-facing error screen.

**DBG-1:** With no dependency array at all, the effect runs after EVERY render. Since it also calls `setHabits`, which triggers a new render, that new render causes the effect to run again, causing another `setHabits` call, and so on — an infinite loop.
**DBG-2:** The variable must be renamed to include the `VITE_` prefix (e.g., `VITE_API_URL=http://localhost:4000`) — Vite only exposes prefixed variables to browser-side code; everything else stays invisible to `import.meta.env`.

**SA-1:** *(Sample answer)* Plating a dish (the pure render — same ingredients always produce the same plated dish) is separate from the chef stepping away afterward to phone in tomorrow's ingredient order (a side effect — reaching outside the immediate task, happening after the "presentable" result is already done). `useEffect` is where that "stepping away" work belongs, not in the render itself.
**SA-2:** *(Sample answer)* Without this rule, a developer could accidentally put a genuinely secret value (like a database password) in a plain `.env` variable, and it would silently get bundled into code shipped to every visitor's browser, where anyone could read it. Requiring an explicit `VITE_` prefix forces a deliberate choice about what's safe to expose publicly.

---

# PHASE 4, PART 2 QUIZ: Loading/Error States & use + Suspense

## Multiple Choice

**4.2-MC-1.** What are the three outcomes every network request should plan for?
A) Fast, slow, and cached
B) Loading, success, and error
C) Local, remote, and hybrid
D) Sync, async, and deferred

**4.2-MC-2.** What is an Error Boundary?
A) A CSS border style
B) A component that catches JavaScript errors thrown by its descendants during rendering, showing a fallback instead of crashing the whole app
C) A network firewall
D) A type of state management library

**4.2-MC-3.** Why must Error Boundaries currently be implemented as class components?
A) Class components are faster
B) Catching render errors requires specific class-only lifecycle methods (`getDerivedStateFromError`, `componentDidCatch`) with no current hook equivalent
C) It's an arbitrary historical choice with no real reason
D) Function components cannot return JSX

**4.2-MC-4.** What does `use()` do when passed a Promise that hasn't resolved yet?
A) Returns `undefined` immediately
B) Throws the Promise itself, which React catches via the nearest Suspense boundary
C) Blocks the entire browser until it resolves
D) Automatically retries the Promise three times

**4.2-MC-5.** What happens if a Promise passed to `use()` REJECTS?
A) `use()` returns `null`
B) `use()` re-throws the actual error, caught by the nearest Error Boundary
C) The component silently renders nothing
D) The whole page reloads

**4.2-MC-6.** What is the critical rule about the Promise passed to `use()`?
A) It must be created fresh, inline, on every render
B) It must be the SAME Promise reference across renders (cached, not recreated inline)
C) It must always resolve within 100ms
D) It must be wrapped in `JSON.stringify()`

**4.2-MC-7.** When should you prefer `useEffect` + `useState` over `use()` + `Suspense` for fetching data?
A) Never — use() + Suspense is always superior
B) When the data will be mutated locally afterward (toggling, adding), not just displayed once
C) Only for images, never for JSON data
D) Only when using TypeScript

## True / False

**4.2-TF-1.** `use()` follows the exact same Rules of Hooks as `useState` and `useEffect` — it can never be called conditionally. (True/False)

**4.2-TF-2.** `Suspense` and Error Boundaries are typically used together, with Suspense catching the "still loading" case and the Error Boundary catching the "it failed" case. (True/False)

**4.2-TF-3.** Creating a new Promise directly inside a component's render body and passing it straight to `use()` is a safe, recommended pattern. (True/False)

**4.2-TF-4.** An Error Boundary can catch errors from ANY component anywhere in the entire app, even ones not rendered as its descendants. (True/False)

## Fill in the Blank

**4.2-FB-1.** Every network request should plan for three outcomes: loading, success, and ____________.

**4.2-FB-2.** 🆕 `____()` lets a component read the value of a Promise (or Context) directly during render.

**4.2-FB-3.** As of React 19, Error Boundaries can only be implemented as ____________ components.

## Code Output / Behavior Prediction

**4.2-CO-1.** Given:
```jsx
let quotePromise = fetchQuote() // created once, at module scope

function QuoteWidget() {
  const quote = use(quotePromise)
  return <p>{quote.text}</p>
}
```
If `QuoteWidget` re-renders multiple times, how many times does `fetchQuote()` actually get called?

**4.2-CO-2.** If the Promise passed to `use()` ultimately rejects, and there is NO Error Boundary anywhere above the component in the tree, what happens?

## Debug It

**4.2-DBG-1.**
```jsx
function QuoteWidget() {
  const quote = use(fetchQuote()) // called directly here, inline
  return <p>{quote.text}</p>
}
```
What's wrong with calling `fetchQuote()` directly inside the component body like this?

**4.2-DBG-2.** A student wraps a `use()`-powered component in `<Suspense>` but forgets to wrap it in an `<ErrorBoundary>` as well. The underlying Promise sometimes rejects. What will the user see when that happens?

## Short Answer

**4.2-SA-1.** Explain, in your own words, why `use()` is exempt from the traditional Rules of Hooks.

**4.2-SA-2.** Draw or describe the nesting relationship between `ErrorBoundary` and `Suspense`, and explain what each one catches.

---

## PHASE 4, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-False (use() is explicitly EXEMPT from traditional Rules of Hooks — can be called conditionally), 2-True, 3-False (this is a documented anti-pattern — causes an infinite request loop), 4-False (only catches errors from its own DESCENDANTS, not the whole app)

**FB:** 1. error 2. `use` 3. class

**CO-1:** Once — since `quotePromise` is created ONCE at module scope, not recreated on each render, `use()` reuses the same reference every time.
**CO-2:** The error propagates up the component tree until it either hits an Error Boundary (which would catch it) or, if none exists, crashes the entire application (a blank white screen with a console error).

**DBG-1:** Creating a new Promise directly during render means a BRAND NEW Promise is created on every single re-render, causing an infinite loop of new network requests, since `use()` would suspend/refetch fresh every time.
**DBG-2:** The error would propagate up with no Error Boundary to catch it, likely crashing the entire application (or at least a large portion of it) with a blank screen, rather than gracefully showing a fallback UI for just that section.

**SA-1:** *(Sample answer)* Traditional hooks like `useState` rely on React tracking their CALL ORDER to correctly persist state across renders. `use()` doesn't maintain any of its own persistent, order-dependent state — it's fundamentally just "synchronously unwrap this value, or suspend/throw while I can't yet" — so it has no order-dependent bookkeeping to protect, letting React's team safely allow it to be called conditionally.
**SA-2:** *(Sample answer)*
```
<ErrorBoundary>       ← catches thrown ERRORS (rejected promises)
  <Suspense fallback={...}>  ← catches thrown PROMISES (still pending)
    <ComponentUsingUse />
  </Suspense>
</ErrorBoundary>
```
Suspense catches the Promise itself while it's still pending; the Error Boundary catches the actual error if that Promise ultimately rejects.

---

# PHASE 4, PART 3 QUIZ: 🆕 useOptimistic

## Multiple Choice

**4.3-MC-1.** What is "optimistic UI"?
A) UI that always shows a happy face emoji
B) Showing the anticipated (hoped-for) result of an action immediately, before the server confirms it
C) A UI design style using bright colors
D) A form of lazy loading

**4.3-MC-2.** What does `useOptimistic` return?
A) `[value, setValue]`
B) `[optimisticValue, addOptimistic]`
C) A single boolean
D) `[state, dispatch]`

**4.3-MC-3.** From where can `addOptimistic(...)` be called?
A) Anywhere at all, with no restrictions
B) Only from within a transition (`startTransition`, or a form Action)
C) Only from inside a `useEffect`
D) Only from a class component

**4.3-MC-4.** What HTTP method is used for a PARTIAL update to an existing resource?
A) `GET`
B) `POST`
C) `PATCH`
D) `DELETE`

**4.3-MC-5.** What HTTP method is used to CREATE a new resource?
A) `GET`
B) `POST`
C) `PATCH`
D) `HEAD`

**4.3-MC-6.** Why does the optimistic value automatically revert after a failure, with no manual "undo" code?
A) React automatically detects and reverts all failed network calls
B) The optimistic value is derived fresh from the real state every render; if the real update never happened, it reflects the unaffected real state again
C) `useOptimistic` calls `window.location.reload()` automatically
D) It doesn't actually revert automatically — manual code is always required

**4.3-MC-7.** What warning appears if `addOptimistic` is called WITHOUT wrapping it in `startTransition`?
A) No warning — it works silently
B) "An optimistic state update occurred outside a transition or action"
C) "Cannot read properties of undefined"
D) "Maximum update depth exceeded"

## True / False

**4.3-TF-1.** `useOptimistic`'s update function may run outside of any transition, as long as the app is in development mode. (True/False)

**4.3-TF-2.** On a failed optimistic update, the tutorial's code deliberately does NOT update the real state (`habits`/`tasks`), letting the optimistic value revert naturally. (True/False)

**4.3-TF-3.** `startTransition` marks a block of code as non-urgent, giving React the information it needs to manage optimistic updates correctly. (True/False)

**4.3-TF-4.** Manually snapshotting "previous state" and rolling it back in a `.catch()` block is described as strictly safer than `useOptimistic` in all cases. (True/False)

## Fill in the Blank

**4.3-FB-1.** ____________ UI shows the anticipated result of an action immediately, before the server confirms it.

**4.3-FB-2.** `addOptimistic(...)` may only be called from within a ____________.

**4.3-FB-3.** `PATCH` is used for a ____________ update; `POST` is used to ____________ a new resource.

## Code Output / Behavior Prediction

**4.3-CO-1.** Given this handler, if `updateHabit(...)` ultimately throws an error, what does the UI show immediately after the catch block runs (assuming the real state was never touched)?
```jsx
startTransition(async () => {
  applyOptimisticHabit(optimisticHabit)
  try {
    const saved = await updateHabit(id, {...})
    setHabits((current) => current.map((h) => h.id === id ? saved : h))
  } catch (error) {
    showToast('Failed to save.')
  }
})
```

**4.3-CO-2.** If `applyOptimisticHabit(optimisticHabit)` is called directly inside an `onClick` handler with NO `startTransition` wrapper, what happens in the console?

## Debug It

**4.3-DBG-1.** A student's optimistic UI never reverts after a failure — the checkbox stays checked even when the save genuinely failed. Their `catch` block reads:
```jsx
catch (error) {
  setHabits((current) => current.map((h) => h.id === id ? optimisticHabit : h))
  showToast('Failed.')
}
```
What's the bug?

**4.3-DBG-2.** A student calls `useOptimistic`'s update function directly in a plain event handler, no `startTransition` anywhere. What specific warning appears, and what two fixes does it suggest?

## Short Answer

**4.3-SA-1.** Explain the "liking a social media post" analogy for optimistic UI.

**4.3-SA-2.** Why is `useOptimistic` considered safer than manually snapshotting and rolling back state when MULTIPLE overlapping updates happen in quick succession?

---

## PHASE 4, PART 3 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-C, 5-B, 6-B, 7-B

**TF:** 1-False (this rule applies in ALL modes, not just development — it's a hard requirement, not a dev-only check), 2-True, 3-True, 4-False (useOptimistic is described as SAFER specifically for overlapping updates, since manual snapshots can capture stale state)

**FB:** 1. Optimistic 2. transition 3. partial / create

**CO-1:** The checkbox visually reverts back to its previous (pre-toggle) state, since the real state was never updated, and the optimistic value is derived fresh from that unaffected real state. A toast notification also appears.
**CO-2:** A console warning: "An optimistic state update occurred outside a transition or action. To fix, move the update to an action, or wrap with startTransition."

**DBG-1:** The `catch` block incorrectly sets the REAL state to the OPTIMISTIC (failed) value, instead of leaving real state untouched. This defeats the automatic-revert mechanism, since now the "real" state itself reflects the failed change.
**DBG-2:** Warning: "An optimistic state update occurred outside a transition or action." Suggested fixes: (1) move the update into an Action, or (2) wrap it with `startTransition`.

**SA-1:** *(Sample answer)* Tapping "like" on a post fills the heart icon in INSTANTLY — the app doesn't make you wait for server confirmation before showing the result. It assumes success (since it usually succeeds) and only reverts, quietly, in the rare case of failure — exactly the trade-off `useOptimistic` formalizes.
**SA-2:** *(Sample answer)* A manually-captured "previous state" snapshot can become stale if a second overlapping update starts before the first one resolves — rolling back to that stale snapshot could incorrectly undo the second update too. `useOptimistic`'s value is always properly derived relative to the true, current source of state, avoiding this class of bug by design.

---
```
[GENERATED: Quiz Bank Batch 5 — Phase 4: Data Fetching]
[STARTING: Quiz Bank Batch 6 — Phase 5: App-Wide State (Parts 1–2)]
```

# PHASE 5, PART 1 QUIZ: The Context API

## Multiple Choice

**5.1-MC-1.** What is Context compared to, as opposed to props' "note passed hand-to-hand"?
A) A locked safe
B) A public bulletin board anyone can read directly
C) A private diary
D) A telephone call

**5.1-MC-2.** What are the three pieces of the Context pattern?
A) `useState`, `useEffect`, `useContext`
B) `createContext()`, a Provider, and `useContext()`
C) `useReducer`, `dispatch`, `action`
D) `props`, `state`, `ref`

**5.1-MC-3.** Which components can read a Context's value?
A) Every component in the entire app, automatically
B) Only components that are DESCENDANTS of the Provider in the rendered tree
C) Only the component that created the Context
D) Only class components

**5.1-MC-4.** Why is Context described as a poor fit for "text currently being typed into one specific input"?
A) Context cannot hold string values
B) That kind of rapidly-changing, localized state doesn't benefit from Context's broad re-render behavior, and is better as local useState
C) Context only works with numbers
D) Inputs cannot be wrapped in a Provider

**5.1-MC-5.** What mechanism allows one `data-theme` attribute change to repaint an entire themed app?
A) Inline styles on every element
B) CSS custom properties (variables), overridden based on the attribute
C) A separate stylesheet loaded via JavaScript
D) SVG filters

**5.1-MC-6.** What did the Re-render Experiment (logging inside `HabitCard`, which doesn't use `useTheme`) demonstrate?
A) Context updates never cause any re-renders at all
B) Toggling the theme caused HabitCard to re-render too, proving Context's re-renders cascade broadly
C) HabitCard crashed when the theme changed
D) Only components that explicitly call useTheme ever re-render

**5.1-MC-7.** Why does `useTheme()` throw an error if `context === null`?
A) To intentionally break the app
B) To give a clear, actionable error if a component using it isn't wrapped in `<ThemeProvider>`, rather than a confusing downstream crash
C) `null` is not a valid JavaScript value
D) It's a required step for all custom hooks by law

## True / False

**5.1-TF-1.** `ThemeContext.js` typically contains JSX and uses the `.jsx` extension. (True/False)

**5.1-TF-2.** A Provider "publishes" a value to any descendant component that reads it via `useContext`. (True/False)

**5.1-TF-3.** Context is best reserved for genuinely global, infrequently-changing values. (True/False)

**5.1-TF-4.** The default value passed to `createContext(null)` is used every single time a component reads the Context, regardless of whether a Provider exists above it. (True/False)

## Fill in the Blank

**5.1-FB-1.** ____________ is described as a "public bulletin board" rather than a private note passed hand-to-hand.

**5.1-FB-2.** Context is only readable by components that are ____________ of the Provider in the actual rendered tree.

**5.1-FB-3.** A custom hook wrapping `useContext` with a "missing Provider" safety check is, by convention, named `use____`.

## Code Output / Behavior Prediction

**5.1-CO-1.** Given:
```jsx
export const ThemeContext = createContext(null)

function SomeComponent() {
  const context = useContext(ThemeContext)
  // this component is rendered OUTSIDE any <ThemeContext.Provider>
}
```
What is the value of `context` inside `SomeComponent`?

**5.1-CO-2.** If `ThemeProvider` wraps only `<Dashboard />` but NOT `<Navbar />` in `main.jsx`, and `Navbar` calls `useTheme()`, what happens?

## Debug It

**5.1-DBG-1.** A student wraps `<ThemeProvider>` around only `<Dashboard />`, not `<Navbar />`. Clicking a theme toggle button inside `Navbar` throws an error: "useTheme must be called from within a `<ThemeProvider>`." What's the fix?

**5.1-DBG-2.** A student notices their entire app's performance degrades noticeably after adding a Context that updates on every keystroke of a search input. What's the architectural mistake here?

## Short Answer

**5.1-SA-1.** Explain why `ThemeContext.js` is a plain `.js` file, while `ThemeProvider.jsx` uses the `.jsx` extension.

**5.1-SA-2.** Describe the three-file Context pattern's file responsibilities in your own words.

---

## PHASE 5, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-False (ThemeContext.js contains only `createContext()`, no JSX — it's a plain .js file), 2-True, 3-True, 4-False (the default value is ONLY used when no Provider exists above the component at all)

**FB:** 1. Context 2. descendants 3. `useTheme`

**CO-1:** `null` (the default value passed to `createContext(null)`, since there's no Provider above it to override it)
**CO-2:** `Navbar` would throw the "must be called from within a Provider" error, since it's rendered outside `ThemeProvider`'s subtree.

**DBG-1:** Move `<ThemeProvider>` to wrap BOTH `<Navbar />` and `<Dashboard />` (i.e., wrap the entire app, typically in `main.jsx`), so both are descendants of the Provider.
**DBG-2:** Using Context for rapidly-changing, localized state (search input keystrokes) — this causes broad re-render cascades across every consumer. This state should instead be local `useState`, not shared via Context.

**SA-1:** *(Sample answer)* `ThemeContext.js` contains only a `createContext()` call — no JSX syntax at all — so a plain `.js` extension is correct. `ThemeProvider.jsx` returns actual JSX (`<ThemeContext.Provider>...</ThemeContext.Provider>`), so it needs the `.jsx` extension, following the convention established back in Phase 1, Part 2.
**SA-2:** *(Sample answer)* `XContext.js` just creates the empty "bulletin board." `XProvider.jsx` owns the actual state/logic and "pins" the current value to that board via `<XContext.Provider value={...}>`. `useX.js` is a thin, safety-checked wrapper around `useContext(XContext)` that any component can call to "read the board."

---

# PHASE 5, PART 2 QUIZ: useReducer for Complex State Logic

## Multiple Choice

**5.2-MC-1.** What analogy is used for `useReducer` vs. scattered `useState` calls?
A) A library card catalog
B) A vending machine — press a labeled button, one rulebook decides the result
C) A recipe card
D) A telephone directory

**5.2-MC-2.** What is the shape of a reducer function?
A) `(props) => JSX`
B) `(state, action) => newState`
C) `(event) => void`
D) `(value) => Promise`

**5.2-MC-3.** What two fields does an action object conventionally have?
A) `name` and `value`
B) `type` and (optionally) `payload`
C) `event` and `handler`
D) `key` and `ref`

**5.2-MC-4.** Why must a reducer function be pure?
A) Impure functions cause syntax errors
B) React may call the reducer multiple times or at unpredictable moments; side effects there would be unreliable and hard to reason about
C) Pure functions run faster on all hardware
D) It's only a stylistic preference with no real consequence

**5.2-MC-5.** What did the temporary action-logging wrapper in this Part demonstrate?
A) That reducers are slower than useState
B) A complete, chronological history of every state transition, from a single wrapping point — the essential idea behind tools like Redux DevTools
C) That actions must always be asynchronous
D) That useReducer cannot coexist with useState

**5.2-MC-6.** Which pieces of state were consolidated into `dataReducer` in this Part?
A) `theme`, `isAuthenticated`
B) `habits`, `tasks`, `isLoading`, `loadError`
C) `retryCount`, `toastMessage`
D) `savingHabitIds`, `savingTaskIds`

**5.2-MC-7.** Why did `retryCount`, `toastMessage`, `savingHabitIds`, and `savingTaskIds` stay as separate `useState` calls?
A) They can never work inside a reducer at all
B) They're genuinely independent, transient UI concerns not sharing transitions with the core data
C) `useReducer` has a maximum of four fields
D) They needed to be class-based state

## True / False

**5.2-TF-1.** A reducer's `default` case throwing an error for an unrecognized action type is considered a valuable safety net, not a mistake. (True/False)

**5.2-TF-2.** `useReducer` and `useState` can be used together within the same component. (True/False)

**5.2-TF-3.** Refactoring from several `useState` calls to a single `useReducer` should change the app's visible behavior for end users. (True/False)

**5.2-TF-4.** A reducer case that forgets to spread `...state` before overriding fields will cause every OTHER field to disappear from state. (True/False)

## Fill in the Blank

**5.2-FB-1.** `useReducer` is compared to a ____________ machine.

**5.2-FB-2.** An action object conventionally has a `type` field and, optionally, a ____________ field.

**5.2-FB-3.** A reducer function must be ____________ — no fetch calls, no `setTimeout`, nothing reaching outside itself.

## Code Output / Behavior Prediction

**5.2-CO-1.** Given:
```javascript
function reducer(state, action) {
  switch (action.type) {
    case 'ADD_TASK':
      return { tasks: [...state.tasks, action.payload] }
    default:
      throw new Error('Unknown action')
  }
}
// initial state: { tasks: [], habits: [], isLoading: true }
```
After dispatching `ADD_TASK`, what happens to `habits` and `isLoading` in the resulting state?

**5.2-CO-2.** If a reducer's `default` case does NOT throw an error, and a typo'd action type like `'TOGLE_HABIT'` is dispatched, what happens?

## Debug It

**5.2-DBG-1.**
```javascript
case 'ADD_TASK':
  return { tasks: [...state.tasks, action.payload] }
```
After dispatching this action, the entire app breaks because `habits` and `isLoading` are suddenly `undefined`. What's the exact bug, and the one-line fix?

**5.2-DBG-2.** A student's reducer calls `fetch()` directly inside a `case` block, to "save time." What's wrong with this, according to the rule stated in this Part?

## Short Answer

**5.2-SA-1.** Explain, using a concrete reason (not just "the rules say so"), why a reducer function must be pure.

**5.2-SA-2.** Describe the practical benefit demonstrated by the one-line action-logging technique in this Part.

---

## PHASE 5, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-True, 2-True, 3-False (refactoring should NOT change visible behavior — same external behavior, cleaner internals), 4-True

**FB:** 1. vending 2. payload 3. pure

**CO-1:** They disappear entirely — the returned object only contains `{ tasks: [...] }`, discarding `habits` and `isLoading` since `...state` was never spread first.
**CO-2:** The action would be silently ignored (or fall into some unintended default behavior) with no warning at all, making the bug much harder to notice and debug, compared to an explicit thrown error.

**DBG-1:** Missing `...state` at the start of the returned object. Fix: `return { ...state, tasks: [...state.tasks, action.payload] }`.
**DBG-2:** Reducers must be pure — no side effects like network calls. Async work (like `fetch`) must happen in the calling handler function (e.g., inside `App.jsx`), which then `dispatch`es a plain action only AFTER the async work resolves, carrying whatever data the reducer needs.

**SA-1:** *(Sample answer)* React may call a reducer function multiple times, at various points, including in ways not directly tied to a single user action (e.g., during certain re-render strategies). If the reducer performed a side effect like a network call, it could run at unpredictable times or multiple times unexpectedly, making behavior unreliable and very hard to reason about or test.
**SA-2:** *(Sample answer)* Wrapping the reducer with a single `console.log` of every dispatched action alongside the resulting state gave a complete, ordered, readable history of every single data change in the app — from ONE choke point — demonstrating the essential idea behind more elaborate tools like Redux DevTools, achievable in just a few lines.

---
```
[GENERATED: Quiz Bank Batch 6 — Phase 5: App-Wide State]
[STARTING: Quiz Bank Batch 7 — Phase 6: Navigation (Parts 1–2)]
```

# PHASE 6, PART 1 QUIZ: React Router — Multi-Page Navigation

## Multiple Choice

**6.1-MC-1.** What is client-side routing?
A) Requesting a brand new HTML document from the server for every "page"
B) Swapping which components are displayed based on the URL, without requesting a new HTML document
C) A server-side caching technique
D) A CSS layout system

**6.1-MC-2.** What must wrap anything in your app that uses routing features?
A) `<Routes>`
B) `<BrowserRouter>`
C) `<Link>`
D) `<Suspense>`

**6.1-MC-3.** What is the key difference between `<Link>` and a plain `<a href="...">`?
A) `<Link>` requires a paid license
B) `<Link>` navigates without a full page reload; a plain `<a>` would cause one
C) `<Link>` only works with images
D) There is no real difference

**6.1-MC-4.** What does `<NavLink>` add on top of `<Link>`?
A) Automatic form validation
B) Automatic detection of whether its own destination matches the current URL, for active-state styling
C) Built-in analytics tracking
D) Automatic image lazy-loading

**6.1-MC-5.** Why does a root-level `NavLink` need the `end` prop?
A) It's required syntax with no functional purpose
B) Without it, since every route starts with "/", the root link would be treated as "active" on every single page
C) `end` makes the link open in a new tab
D) `end` is required for accessibility compliance

**6.1-MC-6.** Where must a wildcard `<Route path="*">` be placed in a list of routes?
A) First
B) Last
C) It doesn't matter
D) Exactly in the middle

**6.1-MC-7.** Why might refreshing directly on `/tasks` work in `npm run dev` but fail (404) on a naive static production host?
A) Vite's dev server intelligently serves index.html for unrecognized URLs; a naive static host looks for a literal file named "tasks"
B) React Router only works during development
C) Production builds delete all routes automatically
D) `/tasks` is a reserved URL in all browsers

## True / False

**6.1-TF-1.** `<Routes>` renders the FIRST `<Route>` child whose path matches the current URL. (True/False)

**6.1-TF-2.** Clicking a `<Link>` triggers the exact same full browser reload as clicking a plain `<a>` tag. (True/False)

**6.1-TF-3.** `NavLink`'s `className` prop can be passed as a function receiving `{ isActive }`. (True/False)

**6.1-TF-4.** The catch-all 404 route uses `path="*"` as its URL pattern. (True/False)

## Fill in the Blank

**6.1-FB-1.** ____________ routing swaps displayed components based on the URL, without a full page reload.

**6.1-FB-2.** `<____________>` must wrap anything using routing features, using the browser's History API.

**6.1-FB-3.** The `____` prop on a root-level `NavLink` forces an exact match, rather than a prefix match.

## Code Output / Behavior Prediction

**6.1-CO-1.** Given:
```jsx
<Routes>
  <Route path="*" element={<NotFoundPage />} />
  <Route path="/tasks" element={<TasksPage />} />
</Routes>
```
What happens if a user navigates to `/tasks`? Explain why, given the route ORDER shown here.

**6.1-CO-2.** Given a `NavLink` for `"/"` WITHOUT the `end` prop, what happens to its active-styling while viewing `/tasks`?

## Debug It

**6.1-DBG-1.** A student's Dashboard nav link stays highlighted no matter which page is currently active. What's the missing prop, and why does its absence cause exactly this symptom?

**6.1-DBG-2.** A student's 404 page shows up even when visiting `/tasks`, a route they definitely defined. What's the likely ordering mistake in their `<Routes>` list?

## Short Answer

**6.1-SA-1.** Explain the "receptionist swapping the display, not rebuilding the hotel" analogy for client-side routing.

**6.1-SA-2.** Why is this Part's "SPA refresh problem" explicitly described as something addressed later, in Phase 9, rather than fixed immediately?

---

## PHASE 6, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-A

**TF:** 1-True, 2-False (Link avoids the full reload; a plain `<a>` WOULD cause one — that's the whole difference), 3-True, 4-True

**FB:** 1. Client-side 2. BrowserRouter 3. `end`

**CO-1:** Since `<Route path="*">` is listed FIRST, it matches EVERY URL (including `/tasks`) before React Router ever considers the more specific `/tasks` route beneath it — the user would incorrectly see `NotFoundPage` instead of `TasksPage`. Order matters; the wildcard must be listed last.
**CO-2:** It would incorrectly show as "active" (highlighted), since `"/"` is treated as a prefix match by default, and `/tasks` technically starts with `/`.

**DBG-1:** Missing the `end` prop on that specific NavLink — without it, `"/"` matches as a prefix on every route (since every route starts with `/`), causing it to always appear active.
**DBG-2:** Their wildcard `<Route path="*">` is almost certainly listed BEFORE the `/tasks` route in their `<Routes>` list — it needs to be moved to be the LAST route listed.

**SA-1:** *(Sample answer)* A hotel receptionist, asked for "the conference room," doesn't rebuild the entire hotel — she just directs you to a different room within the same building and updates the directory sign (the URL) to reflect it. Client-side routing similarly swaps which components render within the same single HTML page, rather than requesting/rebuilding an entirely new page from the server.
**SA-2:** *(Sample answer)* Vite's development server is specifically smart enough to fake this correctly during local development (serving `index.html` for any unrecognized URL), so the problem isn't visible until deploying to a real static host that doesn't automatically do this — Phase 9 is where a real production deployment target (Vercel) needs this explicitly configured via a rewrite rule.

---

# PHASE 6, PART 2 QUIZ: Nested Routes, URL Params, Protected Routes

## Multiple Choice

**6.2-MC-1.** What does `<Outlet>` do?
A) Deletes a route
B) Marks exactly where a matched CHILD route's content should render inside a parent layout
C) Redirects to a different URL
D) Renders a 404 page automatically

**6.2-MC-2.** What data type does `useParams()` ALWAYS return its values as?
A) Numbers
B) Strings
C) Booleans
D) Objects

**6.2-MC-3.** Why does `habit.id === habitId` (without converting types) often silently fail, even for a genuinely matching habit?
A) `habit.id` is always undefined
B) `habit.id` is typically a number, while `habitId` from `useParams()` is always a string — a strict equality check between them fails
C) React doesn't support the `===` operator
D) `habitId` is always null

**6.2-MC-4.** What does `useOutletContext()` provide?
A) The current URL's query string only
B) Whatever value the nearest ancestor `<Outlet context={...}>` provided
C) A list of all defined routes in the app
D) The user's browser history

**6.2-MC-5.** What does `ProtectedRoute` actually protect, according to this Part's explicit caveat?
A) The server's actual data, with full security
B) Navigation/UI visibility only — NOT a substitute for real, server-side authorization
C) Nothing at all; it's purely decorative
D) The user's password, via encryption

**6.2-MC-6.** What is the purpose of `state={{ from: location }}` passed to `<Navigate>`?
A) To permanently delete the original location from history
B) To remember where the user was headed, so they can be redirected back there after logging in
C) To disable the browser's back button
D) To log the user out automatically

**6.2-MC-7.** What is the key difference between `<Navigate>` and `useNavigate()`?
A) They are identical in every way
B) `<Navigate>` is declarative (returned from render); `useNavigate()` is imperative (called in a handler/effect)
C) `<Navigate>` only works for external URLs
D) `useNavigate()` cannot redirect to protected routes

## True / False

**6.2-TF-1.** An `index` route renders when a parent route's URL matches exactly, with no further path segments. (True/False)

**6.2-TF-2.** `useParams()` can return numbers directly if the underlying data uses numeric IDs. (True/False)

**6.2-TF-3.** Client-side route protection alone is sufficient to fully secure a real application's sensitive data. (True/False)

**6.2-TF-4.** `replace` in `<Navigate to="/login" replace />` prevents this redirect from adding a new entry to browser history. (True/False)

## Fill in the Blank

**6.2-FB-1.** `<____________>` is a placeholder marking exactly where a matched CHILD route's content should render.

**6.2-FB-2.** `useParams()` ALWAYS returns its values as ____________.

**6.2-FB-3.** Client-side route protection like `ProtectedRoute` controls navigation/UI visibility only — it is NOT a substitute for real, server-side ____________.

## Code Output / Behavior Prediction

**6.2-CO-1.** Given:
```jsx
const { habitId } = useParams() // habitId === "3" (a string)
const habits = [{ id: 3, label: "Drink water" }]
const habit = habits.find((h) => h.id === habitId)
```
What is the value of `habit`? Why?

**6.2-CO-2.** A logged-out user visits `/settings`. `ProtectedRoute` wraps `SettingsPage`. What URL do they end up at, and what data is attached to that navigation?

## Debug It

**6.2-DBG-1.** A student's `HabitDetailPage` always shows "habit not found," even for habits that clearly exist in the data array. Their comparison: `habit.id === habitId`. What's the exact bug, and the one-line fix?

**6.2-DBG-2.** A student's `useOutletContext()` call returns `undefined`, causing a crash when destructured. What's the most likely structural mistake in their route definitions?

## Short Answer

**6.2-SA-1.** Explain the "picture frame with a swappable photo" analogy for nested routes.

**6.2-SA-2.** Trace the full round-trip: a logged-out user clicks Settings, logs in, and lands back on Settings (not the homepage). What role does `location.state` play?

---

## PHASE 6, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-True, 2-False (ALWAYS strings, regardless of the underlying data type), 3-False (explicitly stated as insufficient — real security requires server-side verification), 4-True

**FB:** 1. Outlet 2. strings 3. authorization

**CO-1:** `undefined` (or effectively "not found") — `h.id` (a number, `3`) is being compared with `===` against `habitId` (a string, `"3"`), and strict equality between different types always returns `false`, so `.find()` never matches.
**CO-2:** They end up at `/login`, with `location.state` containing `{ from: <the original /settings location object> }`, so that after a successful login, they can be redirected back to `/settings` specifically rather than the homepage.

**DBG-1:** Type mismatch — `habit.id` is a number, `habitId` (from `useParams()`) is always a string. Fix: `String(habit.id) === habitId`.
**DBG-2:** The component calling `useOutletContext()` almost certainly isn't rendered as a genuine CHILD route of the layout providing that context — it needs to be nested properly inside the parent `<Route>` in `App.jsx`'s route definitions.

**SA-1:** *(Sample answer)* A parent route provides a shared, unchanging "frame" (a consistent layout — like a picture frame hanging on a wall), while `<Outlet>` marks exactly where the currently-matched child route's content ("the photo currently displayed inside the frame") should render — swappable without altering the frame itself.
**SA-2:** *(Sample answer)* When `ProtectedRoute` redirects the logged-out user to `/login`, it attaches `state={{ from: location }}` — capturing the ORIGINAL `/settings` location. `LoginPage` reads `location.state?.from?.pathname` after a successful login and calls `navigate(from, { replace: true })`, sending the user back to that exact original destination instead of a generic homepage redirect.

---
```
[GENERATED: Quiz Bank Batch 7 — Phase 6: Navigation]
[STARTING: Quiz Bank Batch 8 — Phase 7: Advanced Patterns (Parts 1–2)]
```

# PHASE 7, PART 1 QUIZ: Refs & 🆕 ref-as-a-Prop

## Multiple Choice

**7.1-MC-1.** What is the key difference between state and a ref?
A) There is no meaningful difference at all
B) Changing state triggers a re-render; changing a ref never does
C) Refs can only hold numbers; state can hold any type
D) State persists across renders; refs do not

**7.1-MC-2.** What does `useRef(null)` return?
A) `null` directly
B) An object of the shape `{ current: null }`
C) An array `[null, setNull]`
D) A Promise resolving to `null`

**7.1-MC-3.** In the Ref Experiment, why did the on-screen "ref count" text fail to update immediately after clicking "Increment Ref"?
A) There was a bug in the experiment
B) Changing `ref.current` never triggers a re-render, so the screen isn't redrawn to reflect it
C) The button was disabled
D) refs can only be read, never written

**7.1-MC-4.** 🆕 What changed in React 19 regarding `ref`?
A) Refs were removed entirely
B) `ref` can be received as an ordinary destructured prop, without wrapping the component in `forwardRef`
C) Refs now trigger re-renders automatically
D) `ref` must now be a string, not an object

**7.1-MC-5.** What does `useImperativeHandle` let a component do?
A) Automatically validate all its props
B) Control exactly what object a parent receives when it holds a `ref` to this component, rather than exposing the raw DOM node
C) Prevent the component from ever re-rendering
D) Access Context values directly

**7.1-MC-6.** Which of the following is a correct use of `useImperativeHandle`?
A) `useImperativeHandle(props, () => ({}))`
B) `useImperativeHandle(ref, () => ({ focus() { ... }, shake() { ... } }))`
C) `useImperativeHandle(() => ref)`
D) `useImperativeHandle(state, dispatch)`

**7.1-MC-7.** What is the old pre-React-19 pattern for accepting a ref in a function component?
A) `useRef()`
B) `forwardRef()`
C) `useContext()`
D) `useImperativeHandle()` alone, with no other wrapper

## True / False

**7.1-TF-1.** Refs are appropriate for values that should ever appear directly on screen. (True/False)

**7.1-TF-2.** `ref.current` should generally be read or written directly during a component's render body (not inside handlers or effects). (True/False)

**7.1-TF-3.** `forwardRef` is now deprecated and no longer works at all in React 19. (True/False)

**7.1-TF-4.** `useImperativeHandle` is typically used alongside `useRef` and `ref`-as-a-prop together. (True/False)

## Fill in the Blank

**7.1-FB-1.** A ref is described as "a sticky note on your ____________," persisting across renders but invisible to React's re-render logic.

**7.1-FB-2.** 🆕 In React 19, `ref` can be received as an ordinary destructured ____________.

**7.1-FB-3.** Refs should never be read or written to directly during ____________ — only inside event handlers or `useEffect`.

## Code Output / Behavior Prediction

**7.1-CO-1.** Given:
```jsx
const countRef = useRef(0)
function increment() {
  countRef.current = countRef.current + 1
  console.log(countRef.current)
}
```
If `increment()` is called three times via a button click, does the button's visible text (assuming it displays `{countRef.current}`) update on screen after each click, without any other state change?

**7.1-CO-2.** Given `useImperativeHandle(ref, () => ({ focus() { inputRef.current?.focus() } }))`, what happens if a parent calls `someRef.current.blur()` (a method NOT exposed in the handle)?

## Debug It

**7.1-DBG-1.** A student writes `inputRef.current.focus()` directly in the main body of a component function (not inside a handler or `useEffect`), and it crashes on the very first render with "Cannot read properties of null." Why does this happen at that specific moment?

**7.1-DBG-2.** A student uses a ref to track a "click count" they want to DISPLAY on screen, expecting the number shown to update live as the user clicks. It never updates visually. What's the architectural mistake?

## Short Answer

**7.1-SA-1.** Explain the "sticky note on your fridge" vs. "sign in the front window" analogy comparing refs and state.

**7.1-SA-2.** Why does `useImperativeHandle` expose `{ focus, shake }` instead of the raw DOM node directly? What's the benefit?

---

## PHASE 7, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B

**TF:** 1-False (if a value should appear on screen, it belongs in STATE, not a ref), 2-False (never read/write during render — only in handlers/effects), 3-False (forwardRef still fully works in React 19; it's just no longer NECESSARY for new code), 4-True

**FB:** 1. fridge 2. prop 3. rendering

**CO-1:** No — the button's displayed text will NOT update on screen after each click, since changing `countRef.current` never triggers a re-render. The console.log correctly shows the incrementing value, but the screen stays frozen at whatever it last showed.
**CO-2:** It would throw an error, since `blur` isn't part of the object returned by `useImperativeHandle` — only the methods explicitly exposed (`focus`, in this example) are accessible via the ref; the raw DOM node's other methods are not exposed.

**DBG-1:** On the very first render, the element hasn't been attached to the DOM yet, so `inputRef.current` is still `null` at that exact moment — calling `.focus()` on `null` throws. This only works safely inside `useEffect` (which runs AFTER the DOM has been updated) or inside an event handler (triggered after mount).
**DBG-2:** Using a ref for state that needs to be VISIBLE/reactive is the wrong tool — changing a ref never triggers a re-render, so the screen never reflects the new value until some OTHER state change happens to cause a re-render. This should be `useState`, not `useRef`.

**SA-1:** *(Sample answer)* State is like a sign hanging in the front window — the whole world (React) is watching it, and any change is immediately noticed and reacted to. A ref is more like a sticky note stuck inside the fridge — it's still there and still remembers what's written on it, but nobody outside is watching it or reacting when it changes.
**SA-2:** *(Sample answer)* Exposing only a deliberate, limited set of methods (like `focus` and `shake`) rather than the entire raw DOM node prevents a parent from doing ANYTHING it wants to the underlying element (changing its value directly, removing it, etc.) — the same "controlled surface area" principle behind props in general, now applied to imperative access via refs.

---

# PHASE 7, PART 2 QUIZ: Custom Hooks

## Multiple Choice

**7.2-MC-1.** What defines a custom hook?
A) Any function that returns JSX
B) A JavaScript function whose name starts with `use` and calls one or more other hooks internally
C) A function decorated with a special `@hook` annotation
D) Any function longer than 10 lines

**7.2-MC-2.** What does the "recipe card" analogy explain about custom hooks?
A) Custom hooks must be written on physical paper first
B) Custom hooks share LOGIC, never STATE — every call gets its own independent copy
C) Custom hooks are always slower than inline code
D) Custom hooks can only be used once per app

**7.2-MC-3.** What did the Hook Isolation Experiment (two `<Switch>` components using `useToggle`) prove?
A) Clicking one switch also flips the other, since they share the same hook
B) Clicking one switch only flips that one — each call gets independent state
C) `useToggle` doesn't actually work with multiple components
D) Switches must be rendered inside a special wrapper to work correctly

**7.2-MC-4.** Why must a custom hook's name start with `use`?
A) It's purely stylistic with zero functional impact
B) ESLint's Rules-of-Hooks checking specifically looks for this prefix to know which functions to analyze for violations
C) React throws a runtime error otherwise
D) JavaScript reserves the word "use" for hooks specifically

**7.2-MC-5.** What does `useCallback` memoize?
A) A calculated value
B) A function itself, so it isn't recreated on every render unless its dependencies change
C) An entire component's rendered output
D) A CSS class name

**7.2-MC-6.** Which of the following is a valid reason to extract a custom hook?
A) You want to reduce line count with no real shared logic at all
B) You've written the same stateful pattern in two or more places
C) You want to rename a variable
D) The component has fewer than five lines

## True / False

**7.2-TF-1.** Two components calling the same custom hook share the exact same underlying state. (True/False)

**7.2-TF-2.** Custom hooks must follow the same Rules of Hooks internally as any component would. (True/False)

**7.2-TF-3.** A function that internally calls `useState` but is named `toggleLogic` (no `use` prefix) will still be correctly flagged by ESLint if used with a Rules of Hooks violation. (True/False)

**7.2-TF-4.** `useLocalStorage` in this Part is designed to be a drop-in replacement anywhere a plain `useState` was previously used. (True/False)

## Fill in the Blank

**7.2-FB-1.** A custom hook is simply a function whose name starts with ____, that calls one or more other ____________ internally.

**7.2-FB-2.** Custom hooks share ____________, but never ____________.

**7.2-FB-3.** `____________` memoizes a FUNCTION itself across re-renders.

## Code Output / Behavior Prediction

**7.2-CO-1.** Given:
```jsx
function Switch() {
  const [isOn, { toggle }] = useToggle(false)
  return <button onClick={toggle}>{isOn ? 'ON' : 'OFF'}</button>
}

function App() {
  return (
    <>
      <Switch />
      <Switch />
    </>
  )
}
```
If a user clicks the first `<Switch>`, what happens to the second one?

**7.2-CO-2.** Given a custom hook `useDouble(x)` that returns `x * 2`, is this hook doing anything meaningfully different from just writing `const doubled = x * 2` directly in a component? Explain.

## Debug It

**7.2-DBG-1.** A student writes `function toggleLogic() { const [v, setV] = useState(false); ... }` and uses it conditionally inside an `if` block. ESLint doesn't flag any violation. Why not?

**7.2-DBG-2.** A student's `useEffect` that depends on a function returned from a custom hook (e.g., `openForm`) re-runs on every single render, even though nothing seems to have changed. What's the likely missing piece inside the custom hook?

## Short Answer

**7.2-SA-1.** Give the practical checklist from this Part for deciding WHEN to extract a custom hook.

**7.2-SA-2.** Explain, using the two `<Switch>` components example, exactly what "shares logic, not state" means in concrete terms.

---

## PHASE 7, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B

**TF:** 1-False (each call gets its own INDEPENDENT state — this is the core lesson of this Part), 2-True, 3-False (ESLint's Rules-of-Hooks checking relies on the `use` naming prefix — a function without it won't be checked at all), 4-True

**FB:** 1. `use` / hooks 2. logic / state 3. `useCallback`

**CO-1:** Nothing — the second `<Switch>` remains completely unaffected, since each `<Switch>` instance's call to `useToggle` creates its own entirely independent `useState` under the hood.
**CO-2:** Not meaningfully different in this trivial example — this specific case doesn't justify extraction (no real shared, reusable, or independently-testable logic beyond a single multiplication). A custom hook is genuinely useful when it encapsulates real stateful logic (like localStorage syncing or event listener management), not a one-line calculation.

**DBG-1:** ESLint's hooks-checking specifically looks for the `use` naming prefix to identify functions it should analyze for Rules of Hooks violations. Since `toggleLogic` doesn't start with `use`, it's never checked at all, even though it genuinely misuses `useState` conditionally.
**DBG-2:** The custom hook's returned function likely isn't wrapped in `useCallback` — without it, a brand-new function reference is created on every render of the hook's caller, making any effect depending on it think its dependency "changed" every time, causing unnecessary re-runs.

**SA-1:** *(Sample answer)* Extract a custom hook when: (1) you've written the same stateful pattern in two or more places, (2) a component's logic section has grown large enough that a self-contained sub-problem could be understood entirely on its own, or (3) you want the logic to be independently testable, separate from a full component.
**SA-2:** *(Sample answer)* Both `<Switch>` components call the exact same `useToggle` FUNCTION (the shared "recipe"), but each one gets its own separate `useState` call under the hood when `useToggle` runs for that specific instance — so clicking one switch's button only updates that instance's own private state variable, leaving the other switch's separate state completely untouched, exactly like two cooks following the same recipe card but ending up with two separate pots of soup.

---
```
[GENERATED: Quiz Bank Batch 8 — Phase 7: Advanced Patterns]
[STARTING: Quiz Bank Batch 9 (FINAL) — Phase 8, Phase 9 + Cumulative Final Exam]
```

# PHASE 8, PART 1 QUIZ: Testing with Vitest & React Testing Library

## Multiple Choice

**8.1-MC-1.** What is the core testing philosophy taught in this Part?
A) Test internal state variables directly for maximum precision
B) Test like a curious user — interact with the component the way a real person would, and assert on observable behavior
C) Only test functions that return numbers
D) Avoid testing forms entirely, since they're too complex

**8.1-MC-2.** Why does React Testing Library discourage asserting on internal state directly?
A) It's technically impossible to access state in tests
B) Implementation-detail tests break on harmless refactors, even when real user-facing behavior hasn't changed
C) State can only be tested using Redux
D) Vitest doesn't support reading state variables

**8.1-MC-3.** What does `render()` do?
A) Sends the component to a real browser for viewing
B) Mounts a component into a simulated DOM (via jsdom)
C) Compiles JSX into HTML permanently
D) Starts the Vite dev server

**8.1-MC-4.** What does `screen.getByText(...)` do if no matching element is found?
A) Returns `null` silently
B) Throws an error immediately, describing exactly what it was looking for
C) Waits indefinitely
D) Automatically creates the missing element

**8.1-MC-5.** What is `@testing-library/user-event` used for?
A) Managing global application state
B) Simulating realistic user interactions (typing, clicking) more accurately than firing raw DOM events by hand
C) Compiling TypeScript
D) Generating test data automatically

**8.1-MC-6.** What does `vi.fn()` create?
A) A real API endpoint
B) A mock function that records every call it receives
C) A new React component
D) A CSS selector

**8.1-MC-7.** Why is `MemoryRouter` used instead of `BrowserRouter` in component tests?
A) `MemoryRouter` is faster to type
B) It tracks a simulated URL entirely in memory, with no real browser address bar needed — ideal for test environments
C) `BrowserRouter` doesn't exist in test files
D) `MemoryRouter` automatically mocks all API calls

**8.1-MC-8.** What is the correct choice for asserting that something is ABSENT from the screen?
A) `getByText(...)` combined with `.not.toBeInTheDocument()`
B) `queryByText(...)` combined with `.not.toBeInTheDocument()`
C) `findByText(...)` combined with `.toBeInTheDocument()`
D) There is no way to test for absence

**8.1-MC-9.** What does `renderHook()` provide?
A) A way to render a full page in a real browser
B) A minimal, invisible wrapper component that hosts a custom hook call, since hooks can't be called directly in test code
C) A way to skip writing tests entirely
D) Automatic mocking of all imported modules

**8.1-MC-10.** What does `act()` do in hook tests?
A) Deletes the test after it runs
B) Ensures all state updates triggered inside it are fully flushed before the next line of test code runs
C) Automatically writes assertions for you
D) Prevents any React warnings from ever appearing

## True / False

**8.1-TF-1.** `getBy...` queries throw immediately if nothing matches; `queryBy...` queries return `null` instead. (True/False)

**8.1-TF-2.** `findBy...` queries return a Promise that automatically retries until the element is found or a timeout occurs. (True/False)

**8.1-TF-3.** Testing Library's query priority list places `getByTestId` as the FIRST, most preferred choice. (True/False)

**8.1-TF-4.** `vi.mock()` calls must be placed at the top level of a test file, not inside a test function or `beforeEach`. (True/False)

**8.1-TF-5.** A test suite built using the mocking techniques in this Part requires `json-server` to be running in order to pass. (True/False)

## Fill in the Blank

**8.1-FB-1.** The guiding testing principle: "the more your tests resemble the way your software is ____________, the more confidence they can give you."

**8.1-FB-2.** `____________` provides query functions to find elements on the simulated screen after `render()`.

**8.1-FB-3.** `vi.____()` creates a mock function that records every call it receives.

**8.1-FB-4.** `renderHook()` gives a custom hook a ____________ "host" component to live in.

## Code Output / Behavior Prediction

**8.1-CO-1.** Given:
```jsx
render(<Badge>🔥 5</Badge>)
expect(screen.getByText('🔥 6')).toBeInTheDocument()
```
What happens when this test runs, assuming `Badge`'s children render exactly as passed?

**8.1-CO-2.** Given:
```javascript
const handleToggle = vi.fn()
render(<HabitCard onToggle={handleToggle} label="Drink water" />)
await user.click(screen.getByText('Drink water'))
expect(handleToggle).toHaveBeenCalledTimes(1)
```
If `HabitCard`'s `onClick` handler was accidentally removed from its outer `<div>`, what would this test report?

## Debug It

**8.1-DBG-1.** A student writes:
```jsx
expect(screen.queryByText('Loading...')).toBeInTheDocument()
```
...to assert that "Loading..." IS currently present, but the assertion behaves confusingly when it fails. What query should they have used instead, and why?

**8.1-DBG-2.** A student's mocked module isn't taking effect — the real implementation still runs during tests. Their `vi.mock(...)` call is placed inside a `describe()` block, after several `import` statements. What's the likely issue?

## Short Answer

**8.1-SA-1.** Explain why deliberately removing `stopPropagation()` from `HabitCard` and re-running the test suite is a valuable exercise, even though it temporarily "breaks" the app.

**8.1-SA-2.** List, in order, Testing Library's query priority — from most to least preferred — and explain why `getByRole` sits at the top.

---

## PHASE 8, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B, 8-B, 9-B, 10-B

**TF:** 1-True, 2-True, 3-False (getByTestId is the LAST RESORT, least preferred), 4-True, 5-False (the test suite is specifically designed to run fast and deterministically WITHOUT json-server, via mocking)

**FB:** 1. used 2. `screen` 3. `fn` 4. minimal

**CO-1:** The test fails with a clear error like `Unable to find an element with the text: 🔥 6`, since the actual rendered text is `🔥 5`, not `🔥 6`.
**CO-2:** The test would FAIL — `handleToggle` would never be called, so `expect(handleToggle).toHaveBeenCalledTimes(1)` would report a failure (received 0 calls instead of 1) — correctly catching the regression.

**DBG-1:** Should use `getByText` (which throws immediately with a clear "couldn't find" error if missing) rather than `queryByText` (which quietly returns `null`) when asserting PRESENCE. `queryBy` is the right choice specifically for asserting ABSENCE (paired with `.not.toBeInTheDocument()`).
**DBG-2:** `vi.mock()` calls must be at the TOP LEVEL of the file, before/alongside other imports — not nested inside a `describe()` block or any function. Vitest hoists `vi.mock()` calls specially, and they must be positioned correctly for this hoisting to work.

**SA-1:** *(Sample answer)* It proves the test is genuinely exercising real, meaningful behavior rather than trivially passing regardless of the underlying implementation. If a test still passes after a real behavior regression is introduced, that test isn't actually providing useful protection — deliberately breaking the code and confirming the test correctly fails validates that the test is doing its job.
**SA-2:** *(Sample answer)* Priority order: `getByRole` > `getByLabelText` > `getByPlaceholderText` > `getByText` > `getByTestId` (last resort). `getByRole` is preferred because it reflects how assistive technology (like screen readers) actually perceives the page — finding an element by its accessible role and name is strong evidence it's genuinely usable by everyone, not just sighted mouse users.

---

# PHASE 9, PART 1 QUIZ: Builds, Env Vars, Performance

## Multiple Choice

**9.1-MC-1.** What does `npm run build` produce?
A) A folder called `src`
B) An optimized, minified production build in a `dist/` folder
C) A new Git repository
D) A test report

**9.1-MC-2.** What does `npm run preview` do?
A) Starts the development server with HMR
B) Serves the actual built `dist/` folder locally, as a dress rehearsal before deploying
C) Deploys the app directly to Vercel
D) Runs the test suite in watch mode

**9.1-MC-3.** Which environment file is used ONLY when running `vite build`?
A) `.env`
B) `.env.development`
C) `.env.production`
D) `.env.local`

**9.1-MC-4.** What is the "golden rule of performance work" stated in this Part?
A) Always apply memo, useMemo, and useCallback to every component
B) Measure/profile first, before optimizing anything
C) Never use React DevTools
D) Optimization should always happen before writing any functionality

**9.1-MC-5.** What does `React.memo(Component)` do?
A) Deletes the component if unused
B) Skips re-rendering the component if its props are shallow-equal to the previous render
C) Automatically fixes all bugs in the component
D) Converts a function component into a class component

**9.1-MC-6.** Why did wrapping `HabitCard` in `React.memo` alone NOT initially stop unnecessary re-renders?
A) `memo` doesn't actually work in React 19
B) A new inline arrow function (`onToggle={() => onToggleHabit(habit.id)}`) was created on every parent render, defeating memo's shallow prop comparison
C) HabitCard had no props at all
D) The Profiler was misconfigured

**9.1-MC-7.** What does `useCallback` memoize?
A) A component's rendered JSX
B) A function reference, recreated only when its dependencies change
C) A CSS class
D) An entire array of data

**9.1-MC-8.** What must always wrap a `React.lazy()` component?
A) `React.memo`
B) `<Suspense>`
C) `<ErrorBoundary>` exclusively, with nothing else
D) `useEffect`

**9.1-MC-9.** What does code-splitting via `React.lazy` achieve?
A) It makes all code run faster on the server
B) It defers downloading a component's code until it's actually needed, reducing initial bundle size
C) It automatically deletes unused CSS
D) It converts JSX into plain HTML at build time

**9.1-MC-10.** Why is applying `useMemo` to a 3-4 item array's `.filter()` described as having "genuinely negligible" real-world benefit?
A) `.filter()` doesn't work on small arrays
B) Filtering a handful of items is computationally cheap regardless — useMemo's overhead isn't justified by the tiny savings
C) useMemo only works on arrays larger than 100 items
D) It was a mistake that should be removed entirely

## True / False

**9.1-TF-1.** Vite only picks up changes to `.env` files while the dev server is already running, with no restart needed. (True/False)

**9.1-TF-2.** `React.memo`, `useMemo`, and `useCallback` should be applied to every component and value reflexively, as a general best practice. (True/False)

**9.1-TF-3.** Applying or removing memoization tools should never change WHAT a user sees, only HOW OFTEN certain work is repeated. (True/False)

**9.1-TF-4.** A lazy-loaded component, once downloaded once in a session, loads instantly on subsequent renders without a repeated network request. (True/False)

## Fill in the Blank

**9.1-FB-1.** `npm run ____________` creates an optimized build in the `dist/` folder.

**9.1-FB-2.** The golden rule of performance work: ____________ before optimizing.

**9.1-FB-3.** `React.____()` paired with `<Suspense>` defers downloading a component's code until it's actually needed.

## Code Output / Behavior Prediction

**9.1-CO-1.** Given:
```jsx
<HabitCard onToggle={() => onToggleHabit(habit.id)} />
```
Even if `HabitCard` is wrapped in `React.memo`, will it still re-render every time its parent re-renders? Why?

**9.1-CO-2.** After applying `React.lazy()` to five different page components and building the app, what should you observe in the build output compared to before?

## Debug It

**9.1-DBG-1.** A student wraps `TaskCard` in `React.memo`, but the Profiler still shows every card re-rendering on every toggle. Their `TasksSection` still writes `<TaskCard onToggle={() => onToggleTask(task.id)} />`. What's the bug, and what two changes fix it?

**9.1-DBG-2.** A student adds `React.lazy()` to a component but forgets to wrap it in `<Suspense>` anywhere. What error occurs?

## Short Answer

**9.1-SA-1.** Explain why premature optimization is described as a real, ongoing cost, not just a cliché.

**9.1-SA-2.** Describe the two-part fix required to make `React.memo` genuinely effective for `HabitCard`, referencing both `App.jsx` and `HabitCard.jsx`/`HabitsSection.jsx`.

---

## PHASE 9, PART 1 ANSWER KEY

**MC:** 1-B, 2-B, 3-C, 4-B, 5-B, 6-B, 7-B, 8-B, 9-B, 10-B

**TF:** 1-False (Vite only picks up .env changes on a FRESH START — requires restarting the dev server), 2-False (explicitly warned against — apply only after measuring a real bottleneck), 3-True, 4-True

**FB:** 1. `build` 2. Measure 3. `lazy`

**CO-1:** Yes, it will still re-render every time — the inline arrow function creates a BRAND NEW function reference on every render of the parent, and `memo`'s shallow comparison sees this as a "changed" prop regardless of the component being wrapped in `memo`.
**CO-2:** Multiple smaller, separate JS chunk files listed in the build output (one per lazy-loaded page, roughly), instead of one single large bundle file containing everything.

**DBG-1:** The inline arrow function defeats `memo`'s shallow comparison. Fix: (1) wrap `handleToggleTask` in `useCallback` in the parent component that owns it, and (2) pass `task.id` as a prop to `TaskCard` and have it call a stable `onToggle(id)` directly, rather than the parent creating a new closure per render.
**DBG-2:** An error such as "A component was suspended by an uncached promise" (or similar) — React requires a `<Suspense>` boundary somewhere above any lazily-loaded component to know what fallback to show while its code downloads.

**SA-1:** *(Sample answer)* Every memoization tool added must be correctly read, understood, and maintained by every future person working in that file — an incorrect or stale dependency array can introduce genuinely hard-to-spot "stale closure" bugs. This ongoing maintenance burden is a real cost that must be weighed against actual, measured performance benefit — not applied reflexively "just in case."
**SA-2:** *(Sample answer)* In `App.jsx`, `handleToggleHabit` must be wrapped in `useCallback` so it has a stable identity across renders. In `HabitsSection.jsx`, instead of writing `onToggle={() => onToggleHabit(habit.id)}` (a new function every render), pass `habit.id` directly as a prop and have `onToggle={onToggleHabit}`; then in `HabitCard.jsx`, a `handleCardClick` function calls `onToggle(id)` internally — eliminating the per-render wrapper closure entirely, which is what finally lets `React.memo`'s shallow comparison correctly skip unchanged cards.

---

# PHASE 9, PART 2 QUIZ: Deploying to Vercel

## Multiple Choice

**9.2-MC-1.** What is a serverless function?
A) A function with no name
B) A small backend function that runs on-demand, for a single request, rather than as a continuously-running process
C) A function that never returns any value
D) A client-side-only function with no backend involvement

**9.2-MC-2.** What determines a Vercel serverless function's URL route?
A) A separate router configuration file
B) The file and folder structure inside the `api/` folder itself
C) The function's variable name
D) A manually-written `routes.json` file

**9.2-MC-3.** What is the explicitly stated limitation of the in-memory data store built in this Part?
A) It's actually fully persistent and production-ready
B) It resets across deployments and cold starts — a deliberate, clearly-flagged simplification
C) It can only store numbers, not text
D) It requires a paid Vercel plan to function at all

**9.2-MC-4.** What problem does `vercel.json`'s rewrite rule solve?
A) CSS specificity conflicts
B) The "SPA refresh" problem — refreshing directly on a non-root URL like `/tasks` returning a real 404 on a naive static host
C) Slow database queries
D) Broken image links

**9.2-MC-5.** Why must `VITE_API_URL` be manually re-entered in Vercel's dashboard, even though it exists in `.env.production` locally?
A) Vercel doesn't support environment variables at all
B) `.env.production` is gitignored, so Vercel never sees its contents automatically
C) Vercel only reads variables named exactly `API_URL`
D) It's a bug in Vercel that requires a workaround

**9.2-MC-6.** What is a Preview Deployment?
A) A local-only build with no real URL
B) A full, live, isolated deployment automatically created for every branch/pull request, separate from production
C) A downgraded, feature-limited version of the app
D) A screenshot of the app, not an actual running deployment

**9.2-MC-7.** What triggers a new PRODUCTION deployment on Vercel, following this Part's setup?
A) Manually clicking a "Deploy" button every time
B) Merging a pull request into the configured Production Branch (typically `main`)
C) Refreshing the Vercel dashboard
D) Running `npm run build` locally

**9.2-MC-8.** What does CI/CD stand for?
A) Code Integration / Code Delivery
B) Continuous Integration / Continuous Deployment
C) Client Interface / Client Data
D) Continuous Improvement / Continuous Debugging

## True / False

**9.2-TF-1.** The frontend `fetch`-based API code (e.g., `habitsApi.js`) would need significant changes if the backend were later swapped for a real, persistent database. (True/False)

**9.2-TF-2.** Vercel's rewrite rule in `vercel.json` should also apply to `/api/...` routes, redirecting them to `index.html`. (True/False)

**9.2-TF-3.** Every deployment Vercel ever creates remains listed under the "Deployments" tab, allowing rollback to any previous version. (True/False)

**9.2-TF-4.** Preview Deployments and the production deployment are genuinely separate, isolated builds. (True/False)

## Fill in the Blank

**9.2-FB-1.** A ____________ function runs on demand, for a single request, rather than as a continuously-running process.

**9.2-FB-2.** Since `.env.production` is gitignored, its values must instead be entered directly in ____________'s dashboard.

**9.2-FB-3.** Continuous Integration / Continuous Deployment is together known as ____________.

## Code Output / Behavior Prediction

**9.2-CO-1.** Given this `vercel.json` rewrite rule:
```json
{ "rewrites": [{ "source": "/((?!api/).*)", "destination": "/index.html" }] }
```
If a user visits `/api/habits` directly, is this request rewritten to `index.html`, or left alone? Why?

**9.2-CO-2.** A developer merges a pull request into `main`. What should happen automatically on Vercel, with no manual action taken?

## Debug It

**9.2-DBG-1.** A student deploys successfully, but every page except the homepage shows a 404 when refreshed directly (e.g., visiting `mysite.vercel.app/tasks` and pressing refresh). What file is likely missing or misconfigured?

**9.2-DBG-2.** A student's deployed app fails to load any data — the Network tab shows requests going to `undefined/habits`. What setting did they most likely forget to configure in Vercel's dashboard?

## Short Answer

**9.2-SA-1.** Explain, step by step, what happens from `git push` on a new branch to seeing a working Preview Deployment URL on a pull request.

**9.2-SA-2.** Describe what a genuinely production-ready backend would need to add, beyond what this Part's serverless functions provide, and explain why the frontend code wouldn't need to change.

---

## PHASE 9, PART 2 ANSWER KEY

**MC:** 1-B, 2-B, 3-B, 4-B, 5-B, 6-B, 7-B, 8-B

**TF:** 1-False (would need ZERO changes — the frontend only talks to `/api/...` URLs and has no idea what's actually powering them), 2-False (the rule specifically EXCLUDES `/api/` routes via the negative lookahead, leaving them untouched), 3-True, 4-True

**FB:** 1. serverless 2. Vercel 3. CI/CD

**CO-1:** Left alone — the rewrite rule uses a negative lookahead `(?!api/)` specifically excluding any path starting with `api/`, so requests to `/api/habits` are NOT rewritten to `index.html` and instead correctly reach the actual serverless function.
**CO-2:** Vercel automatically detects the merge and begins a new Production deployment build, with no manual "Deploy" button pressed — this is the core of the CI/CD workflow demonstrated in this Part.

**DBG-1:** Missing or incorrectly configured `vercel.json` — specifically its rewrite rule that serves `index.html` for any non-`/api/` URL, letting the client-side router take over.
**DBG-2:** They forgot to set `VITE_API_URL` (e.g., to `/api`) under Project → Settings → Environment Variables in Vercel's dashboard — since `.env.production` is gitignored, Vercel has no automatic way to know this value.

**SA-1:** *(Sample answer)* (1) `git checkout -b my-change`, make edits, commit, and `git push -u origin my-change`. (2) Open a pull request on GitHub for that branch. (3) Vercel's GitHub integration automatically detects the new branch/PR and builds a full, separate deployment for it. (4) A bot comment appears on the PR with a unique preview URL. (5) Visiting that URL shows the complete, live, isolated version of the app with the proposed change — separate from production until merged.
**SA-2:** *(Sample answer)* A real production backend would replace the in-memory arrays in `data-store.js` with actual queries against a persistent database (e.g., Supabase, Neon, Vercel Postgres). The frontend's `fetch`-based API layer (`habitsApi.js`, etc.) wouldn't need to change at all, because it only ever calls `/api/...` URLs and has no knowledge of what's actually powering them on the other end — exactly the payoff of the clean frontend/backend separation established back in Phase 4.

---

# CUMULATIVE FINAL EXAM

*A mixed-topic exam spanning the entire series. Recommended: attempt without notes, then check against the key.*

## Section A: Multiple Choice (20 Questions)

**FE-1.** Which hook was introduced specifically to eliminate manually-tracked `isSubmitting` state?
A) `useEffect`
B) `useActionState`
C) `useReducer`
D) `useRef`

**FE-2.** What is the primary reason React requires immutable state updates?
A) Mutability is slower on all hardware
B) React detects changes via reference comparison; mutating in place can cause it to miss the change
C) JavaScript doesn't support mutable objects
D) It's a stylistic preference with no functional consequence

**FE-3.** Which of these is imported from `react-dom`, not `react`?
A) `useState`
B) `useActionState`
C) `useFormStatus`
D) `useOptimistic`

**FE-4.** What does `key` help React do?
A) Encrypt component props
B) Track which list item is which across re-renders and reorders
C) Apply CSS styles
D) Manage global state

**FE-5.** Why is `crypto.randomUUID()` preferred over `array.length + 1` for generating IDs?
A) It's faster to compute
B) It avoids duplicate IDs after items are deleted from the middle of a list
C) `array.length + 1` isn't valid JavaScript
D) UUIDs are required by React internally

**FE-6.** What must wrap components using React Router features?
A) `<Suspense>`
B) `<BrowserRouter>`
C) `<ErrorBoundary>`
D) `<StrictMode>` alone

**FE-7.** What does `use()` do if given a still-pending Promise?
A) Returns `undefined`
B) Throws the Promise, caught by the nearest Suspense boundary
C) Blocks the browser thread
D) Automatically retries after 1 second

**FE-8.** Which hook lets a nested descendant know its ancestor form's submission status, with zero props passed for that purpose?
A) `useActionState`
B) `useFormStatus`
C) `useContext`
D) `useReducer`

**FE-9.** What is the one non-negotiable requirement for calling `useOptimistic`'s update function?
A) It must run inside a `useEffect`
B) It must run inside a transition (`startTransition` or a form Action)
C) It must be called before any other hook
D) It must be wrapped in `try/catch`

**FE-10.** Error Boundaries must currently be implemented as:
A) Function components using `useError`
B) Class components
C) Custom hooks
D) Context Providers

**FE-11.** What is the correct three-file pattern for Context?
A) Context.js, Hook.js, Component.jsx
B) XContext.js, XProvider.jsx, useX.js
C) Provider.js, Consumer.js, Context.js
D) Store.js, Actions.js, Reducers.js

**FE-12.** In React 19, how does a function component accept a `ref`?
A) Only via `forwardRef`
B) As an ordinary destructured prop
C) Refs cannot be passed to function components at all
D) Only via `useContext`

**FE-13.** What analogy describes `useReducer` vs. multiple `useState` calls?
A) A recipe card
B) A vending machine
C) A sticky note
D) A public bulletin board

**FE-14.** Which array method returns `true` if AT LEAST ONE item matches a condition?
A) `.every()`
B) `.some()`
C) `.map()`
D) `.reduce()`

**FE-15.** What HTTP method is conventionally used to PARTIALLY update an existing resource?
A) `GET`
B) `POST`
C) `PATCH`
D) `HEAD`

**FE-16.** What does `React.memo` require to work effectively when a component receives function props?
A) Nothing extra — it works automatically regardless
B) Those function props should be stabilized via `useCallback`, or memo's shallow comparison will see them as always "changed"
C) The component must be a class component
D) The parent component must never re-render

**FE-17.** Why is client-side route protection (like `ProtectedRoute`) insufficient as real security?
A) It only works in Chrome
B) It doesn't affect the actual server-side data endpoints, which remain accessible regardless of the client-side check
C) It requires a paid React license
D) It only works with class components

**FE-18.** What is the correct npm script to verify a production build locally before deploying?
A) `npm run dev`
B) `npm run preview`
C) `npm test`
D) `npm run lint`

**FE-19.** What does `.gitignore` typically include for a Vite + React project by the end of the series?
A) `src/App.jsx`
B) `node_modules`, `dist`, and `.env` variants
C) `package.json`
D) `README.md`

**FE-20.** What is the fundamental unit that lets a single branch/pull request get its own live, isolated deployment on Vercel?
A) A Serverless Function
B) A Preview Deployment
C) A Custom Domain
D) An Environment Variable

## Section B: True/False (10 Questions)

**FE-21.** Props can be freely reassigned inside the component that receives them. (True/False)

**FE-22.** `useEffect`'s cleanup function runs before the effect re-runs, or when the component unmounts. (True/False)

**FE-23.** `formData.get(name)` can return a real JavaScript number directly. (True/False)

**FE-24.** Every hook in React must be called unconditionally, at the top level of a component — with no exceptions. (True/False)

**FE-25.** Custom hooks share both logic AND state across every component that calls them. (True/False)

**FE-26.** `useOptimistic`'s value automatically reverts to the real state if the underlying update fails, with no manual rollback code required. (True/False)

**FE-27.** Vitest and React Testing Library require a real, running backend server to pass their tests, as configured in this series. (True/False)

**FE-28.** `vercel.json`'s SPA rewrite rule should apply to `/api/...` routes as well as every other route. (True/False)

**FE-29.** Context should generally be used for rapidly-changing, per-keystroke state. (True/False)

**FE-30.** `React.lazy()` components must always be wrapped in a `<Suspense>` boundary somewhere above them.

## Section C: Short Answer (5 Questions)

**FE-31.** Trace the full lifecycle of a single "toggle habit" click, from the moment the user clicks, through the optimistic UI update, to the eventual real state update or rollback — naming every hook/mechanism involved (useOptimistic, startTransition, the API call, the reducer dispatch).

**FE-32.** Explain why this series introduces `useEffect` + `useState` (Phase 4, Part 1) for fetching habits/tasks, but `use()` + `Suspense` (Phase 4, Part 2) for the quote widget — what's the deciding factor?

**FE-33.** Describe the full "prop drilling → Context" arc across the series: where was the pain first felt (which Phase/Part), and where was it actually solved (which Phase/Part)?

**FE-34.** Explain why `React.memo` alone was insufficient to fix `HabitCard`'s unnecessary re-renders, and the two-part fix that resolved it.

**FE-35.** Describe the complete deployment pipeline built in Phase 9: from local production build verification, through pushing to GitHub, to a live Vercel deployment with working Preview Deployments.

---

## CUMULATIVE FINAL EXAM — ANSWER KEY

**Section A (MC):**
1-B, 2-B, 3-C, 4-B, 5-B, 6-B, 7-B, 8-B, 9-B, 10-B, 11-B, 12-B, 13-B, 14-B, 15-C, 16-B, 17-B, 18-B, 19-B, 20-B

**Section B (TF):**
21-False (props are read-only — never reassign them), 22-True, 23-False (always returns a string, or a File — never a number directly), 24-False (`use()` is the explicit exception — can be called conditionally), 25-False (share LOGIC only — every call gets independent state), 26-True, 27-False (specifically designed and demonstrated to run WITHOUT the backend, via mocking), 28-False (the rule specifically EXCLUDES `/api/` routes), 29-False (Context is a poor fit for rapidly-changing state — best for infrequent, global values), 30-True

**Section C (Short Answer, sample answers):**

**FE-31:** *(Sample answer)* User clicks a habit card → `handleToggleHabit(habitId)` runs in `App.jsx` → finds the target habit, computes `optimisticHabit` → calls `setSavingHabitIds` to mark it as saving → wraps the rest in `startTransition(async () => { ... })` → inside the transition, `applyOptimisticHabit(optimisticHabit)` is called, instantly updating what the UI displays (via `useOptimistic`) → `await updateHabit(...)` sends a real PATCH request → on success, `dispatch({ type: 'TOGGLE_HABIT', payload: savedHabit })` updates the REAL reducer state, which the optimistic value then reflects going forward → on failure, the catch block shows a toast and deliberately leaves real state untouched, causing the optimistic value to automatically revert to the last confirmed state once the transition ends.

**FE-32:** *(Sample answer)* Habits/tasks need to be MUTATED LOCALLY afterward (toggled, added to) — a poor fit for `use()`, which is best suited to data fetched once and then just displayed. The quote widget is read-only, fetched once, and never mutated afterward — a textbook fit for `use()` + `Suspense`, which handles loading/error states automatically via Suspense/Error Boundary rather than manually-tracked booleans.

**FE-33:** *(Sample answer)* Prop drilling pain was first deliberately felt in Phase 1, Part 3, manually forwarding `habits`/`tasks` through `App → Dashboard → HabitsSection/TasksSection → HabitCard/TaskCard`, with intermediate components not even using the data themselves. It was actually solved in Phase 5, Part 1, where the Context API let deeply nested components (like `Navbar`'s theme toggle, and later `SettingsPage`) read shared values directly, without any intermediate component needing to know about or forward them.

**FE-34:** *(Sample answer)* `React.memo` alone wasn't enough because `HabitsSection` was still creating a BRAND NEW inline arrow function (`onToggle={() => onToggleHabit(habit.id)}`) on every render, and `memo`'s shallow prop comparison saw this as a "changed" prop every time, regardless of memo being applied. The two-part fix: (1) wrap `handleToggleHabit` itself in `useCallback` in `App.jsx` so it has a stable identity, and (2) pass `habit.id` as a plain prop and have `HabitCard` call `onToggle(id)` directly inside its own handler, eliminating the per-render wrapper closure in `HabitsSection` entirely.

**FE-35:** *(Sample answer)* (1) Run `npm run build` to produce an optimized `dist/` folder; verify it locally with `npm run preview`. (2) Convert the local `json-server` backend into Vercel Serverless Functions under an `api/` folder. (3) Add `vercel.json` with a rewrite rule solving the SPA-refresh 404 problem. (4) Run `git init`, commit, and push the project to a new GitHub repository. (5) Create a Vercel account, import the GitHub repo (auto-detected as a Vite project), and manually set `VITE_API_URL=/api` in Vercel's dashboard (since `.env.production` is gitignored). (6) Deploy — verify the live HTTPS URL works end-to-end. (7) Create a new branch, push a small change, open a pull request, and confirm Vercel automatically builds a separate Preview Deployment, distinct from production. (8) Merge the pull request — production automatically redeploys with no manual action, completing the CI/CD loop.
