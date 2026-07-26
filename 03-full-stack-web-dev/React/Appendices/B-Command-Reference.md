# Appendix B: Complete Command Reference

## Why this appendix exists

Across nine phases, we ran dozens of terminal commands — some once (project setup), some constantly (starting the dev server), some only during specific, occasional tasks (deployment, testing a production build). This appendix collects every one of them into a single lookup table, organized by when and why you'd actually reach for it, so you never have to scroll back through an entire phase just to remember one flag.

---

## 1. Project setup (run once, at the very start)

| Command | What it does | First appeared |
|---|---|---|
| `node --version` | Confirms Node.js is installed and shows its version (need 18+) | Phase 1, Part 1 |
| `npm --version` | Confirms npm is installed | Phase 1, Part 1 |
| `npm create vite@latest task-habit-tracker -- --template react` | Scaffolds a new Vite + React project into a new folder | Phase 1, Part 1 |
| `cd task-habit-tracker` | Moves your terminal into the new project folder | Phase 1, Part 1 |
| `npm install` | Downloads every dependency listed in `package.json` into `node_modules/` | Phase 1, Part 1 |

## 2. Daily development

| Command | What it does | First appeared |
|---|---|---|
| `npm run dev` | Starts the Vite development server (default: `http://localhost:5173`), with Hot Module Replacement | Phase 1, Part 1 |
| `npm run server` | Starts the local mock backend (`json-server`, on `http://localhost:4000`) | Phase 4, Part 1 |
| `npm test` | Starts Vitest in watch mode, automatically re-running tests on file changes | Phase 8, Part 1 |

> 💡 From Phase 4 onward, a full local development session requires **two terminals running simultaneously**: one for `npm run dev`, one for `npm run server`. From Phase 8 onward, a third terminal running `npm test` is useful (though optional) while actively writing code.

## 3. Installing packages

| Command | What it does | First appeared |
|---|---|---|
| `npm install <package>` | Installs a package as a regular (production) dependency | — |
| `npm install -D <package>` | Installs a package as a **development-only** dependency (won't ship to production) | Phase 4, Part 1 (`json-server`) |
| `npm list <package>` | Confirms exactly which version of a package is installed | Phase 1, Part 1 |

**Every package installed across this series, in the order we installed them:**

```bash
# Phase 1, Part 1 — created automatically by `npm create vite@latest`
# (react, react-dom, vite, @vitejs/plugin-react, eslint, and related tooling)

# Phase 4, Part 1
npm install -D json-server@0.17.4

# Phase 6, Part 1
npm install react-router-dom@6.28.1

# Phase 8, Part 1
npm install -D vitest@2.1.8 jsdom@25.0.1 @testing-library/react@16.1.0 @testing-library/jest-dom@6.6.3 @testing-library/user-event@14.5.2
```

## 4. Production builds and preview

| Command | What it does | First appeared |
|---|---|---|
| `npm run build` | Creates an optimized production build in the `dist/` folder | Phase 9, Part 1 |
| `npm run preview` | Serves the built `dist/` folder locally (default: `http://localhost:4173`), as a dress rehearsal before deploying | Phase 9, Part 1 |
| `ls dist` | Lists the contents of the build output folder | Phase 9, Part 1 |

## 5. Verifying API endpoints directly

| Command | What it does | First appeared |
|---|---|---|
| `curl http://localhost:4000/habits` | Sends a raw HTTP GET request and prints the response — useful for confirming a backend endpoint works, independent of the React app | Phase 4, Part 1 |

## 6. Git and GitHub (Phase 9, Part 2)

| Command | What it does |
|---|---|
| `git init` | Initializes a new Git repository in the current folder |
| `git add .` | Stages every changed/new file for the next commit |
| `git commit -m "message"` | Saves a snapshot of all staged changes with a descriptive message |
| `git remote add origin <url>` | Links your local repository to a GitHub repository |
| `git branch -M main` | Renames the current branch to `main` |
| `git push -u origin main` | Uploads your commits to GitHub, and remembers this as the default push target going forward |
| `git checkout -b <branch-name>` | Creates and switches to a new branch (used for the Preview Deployment demonstration) |
| `git push -u origin <branch-name>` | Pushes a new branch to GitHub for the first time |

## 7. File/folder management commands used throughout the series

| Command | What it does |
|---|---|
| `mkdir <folder>` | Creates a new folder (`mkdir -p api/habits api/tasks` creates nested folders in one step) |
| `rm <file>` | Deletes a file (macOS/Linux) |
| `del <file>` | Deletes a file (Windows Command Prompt equivalent of `rm`) |
| `code .` | Opens the current folder in VS Code |

---

## A typical full local development session, start to finish

For quick reference, here's the complete sequence of terminal windows/tabs you'd have open during active development from Phase 8 onward:

```bash
# Terminal 1 — frontend dev server
npm run dev

# Terminal 2 — mock backend
npm run server

# Terminal 3 — test runner (optional, but useful while coding)
npm test
```

And the sequence for validating a production build before deploying (Phase 9, Part 1):

```bash
npm run build      # creates dist/
npm run preview    # serves dist/ locally for a final check
# ...verify in browser...
# Ctrl+C to stop the preview server once satisfied
```

And the sequence for shipping a change to production (Phase 9, Part 2):

```bash
git checkout -b my-change
# ...edit files...
git add .
git commit -m "Describe the change"
git push -u origin my-change
# ...open a pull request on GitHub, review the automatic Vercel Preview
#    Deployment, then merge — production redeploys automatically...
```
