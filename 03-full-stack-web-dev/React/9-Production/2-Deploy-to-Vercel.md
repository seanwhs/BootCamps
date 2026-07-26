# Phase 9: Production
# Part 2: Deploying to Vercel's Free Hobby Plan, CI/CD & Preview Deployments

## Introduction: What we're doing in this part

Everything we've built so far only exists on your own computer. This final part takes the Task & Habit Tracker from `localhost` to a real, public URL, anyone in the world can visit. Along the way, we have to solve one honest, real problem we've been carrying since Phase 4: **our backend, `json-server`, only ever runs locally** — it isn't something we can "deploy" as-is. In this part, you will:

1. Solve the production backend problem using **Vercel Serverless Functions** — small, focused backend functions that deploy alongside our frontend, on the same platform, for free — with an honest, explicit discussion of their real limitations.
2. Initialize Git and push our project to GitHub.
3. Create a Vercel account and connect it to our GitHub repository.
4. Configure production environment variables directly in Vercel's dashboard.
5. Deploy the app live, and verify it end-to-end on its real public URL.
6. Make a small code change on a separate Git branch and watch Vercel automatically build a **Preview Deployment** — a complete, isolated, shareable copy of the app for that exact change — before it ever touches production.
7. Understand what "CI/CD" actually means, having now built and watched one with your own hands.

By the end of this part, the Task & Habit Tracker you've built line-by-line across this entire series will be live on the internet, with a real HTTPS address, automatically redeploying every time you push new code.

---

## 🎯 The Target: Solving the production backend problem with Vercel Serverless Functions

### 🧠 The Concept: A tiny, on-demand kitchen that only runs when someone orders food

`json-server` was a deliberate teaching shortcut from Phase 4 — a way to get real HTTP requests flowing without a backend-engineering detour. It works beautifully on your own machine because it's a long-running process you start yourself. A public website can't depend on a process running on *your* laptop; it needs code running on infrastructure that's always available.

**Serverless functions** are small, individual backend functions that a hosting platform (Vercel, in our case) runs **on demand** — spinning up just long enough to handle one incoming request, then shutting back down. Think of it like a tiny kitchen that stays dark and powered-off until an order comes in, cooks exactly that one dish, and then powers back down — rather than a full restaurant kitchen staffed and running 24/7 whether or not anyone's ordering. Vercel deploys these functions automatically for any file you place in a special `/api` folder at your project's root — no separate server, no separate hosting account, all within the same free deployment.

> ⚠️ **An important, honest limitation, stated clearly up front:** the data store we're about to build is **in-memory** — it lives only in a JavaScript variable inside the function. Serverless functions are **stateless between invocations**: the platform may run your function in a fresh instance for each request, and *will* completely wipe this in-memory data on every new deployment. This means our deployed app's "database" will often reset, and writes may not reliably appear across different requests. This is a deliberate, clearly-flagged trade-off to keep this final deployment step free, dependency-free, and achievable entirely within this series' scope — a genuinely production-ready backend would connect to a real, persistent database (we cover exactly what that would involve in this part's Reference Section). Everything else about our app — the UI, the routing, the optimistic updates, the build pipeline — remains fully production-grade; only this one piece is a deliberately simplified stand-in.

### 🛠️ The Implementation

```bash
mkdir -p api/habits api/tasks
```

**File: `api/data-store.js`**

```javascript
// ⚠️ TEACHING-ONLY IN-MEMORY DATA STORE — see this part's introduction and
// Reference Section for a full explanation of why this doesn't reliably
// persist in a real serverless deployment, and what to use instead in a
// genuine production app.

export let habits = [
  { id: 1, label: 'Drink 8 glasses of water', streak: 5, isComplete: false },
  { id: 2, label: 'Read for 10 minutes', streak: 12, isComplete: true },
  { id: 3, label: 'Stretch for 5 minutes', streak: 1, isComplete: false },
]

export let tasks = [
  { id: 1, label: 'Finish React tutorial', isComplete: false },
  { id: 2, label: 'Buy groceries', isComplete: true },
  { id: 3, label: 'Clean the kitchen', isComplete: false },
  { id: 4, label: 'Reply to emails', isComplete: false },
]

export const quote = {
  id: 1,
  text: 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
  author: 'Will Durant',
}

// These setters exist because ES module bindings declared with `export let`
// can be reassigned from WITHIN this file, but importers only ever get a
// read-only view — this is the cleanest way to let other files in this
// folder request an update to the shared in-memory array.
export function setHabits(next) {
  habits = next
}

export function setTasks(next) {
  tasks = next
}
```

**File: `api/habits/index.js`**

```javascript
import { habits, setHabits } from '../data-store.js'

// Vercel automatically deploys this file as a serverless function reachable
// at the URL path /api/habits — the folder/file structure under /api IS
// the routing, no separate router configuration required.
export default function handler(req, res) {
  if (req.method === 'GET') {
    res.status(200).json(habits)
    return
  }

  if (req.method === 'POST') {
    // Vercel's Node runtime automatically parses a JSON request body into
    // req.body for us, exactly like json-server did — no manual parsing needed.
    const newHabit = {
      id: Date.now(), // simple, sufficiently-unique id for this demo data store
      label: req.body.label,
      streak: req.body.streak ?? 0,
      isComplete: req.body.isComplete ?? false,
    }
    setHabits([...habits, newHabit])
    res.status(201).json(newHabit)
    return
  }

  res.status(405).json({ error: `Method ${req.method} not allowed` })
}
```

**File: `api/habits/[id].js`**

```javascript
import { habits, setHabits } from '../data-store.js'

// The square-bracket filename [id] is Vercel's convention for a DYNAMIC
// route segment — this file handles /api/habits/1, /api/habits/2, etc.
export default function handler(req, res) {
  const { id } = req.query // dynamic segments are exposed here, as strings
  const habitId = Number(id)

  if (req.method === 'PATCH') {
    const existingHabit = habits.find((habit) => habit.id === habitId)

    if (!existingHabit) {
      res.status(404).json({ error: 'Habit not found' })
      return
    }

    const updatedHabit = { ...existingHabit, ...req.body }
    setHabits(habits.map((habit) => (habit.id === habitId ? updatedHabit : habit)))
    res.status(200).json(updatedHabit)
    return
  }

  res.status(405).json({ error: `Method ${req.method} not allowed` })
}
```

**File: `api/tasks/index.js`**

```javascript
import { tasks, setTasks } from '../data-store.js'

export default function handler(req, res) {
  if (req.method === 'GET') {
    res.status(200).json(tasks)
    return
  }

  if (req.method === 'POST') {
    const newTask = {
      id: Date.now(),
      label: req.body.label,
      isComplete: req.body.isComplete ?? false,
    }
    setTasks([...tasks, newTask])
    res.status(201).json(newTask)
    return
  }

  res.status(405).json({ error: `Method ${req.method} not allowed` })
}
```

**File: `api/tasks/[id].js`**

```javascript
import { tasks, setTasks } from '../data-store.js'

export default function handler(req, res) {
  const { id } = req.query
  const taskId = Number(id)

  if (req.method === 'PATCH') {
    const existingTask = tasks.find((task) => task.id === taskId)

    if (!existingTask) {
      res.status(404).json({ error: 'Task not found' })
      return
    }

    const updatedTask = { ...existingTask, ...req.body }
    setTasks(tasks.map((task) => (task.id === taskId ? updatedTask : task)))
    res.status(200).json(updatedTask)
    return
  }

  res.status(405).json({ error: `Method ${req.method} not allowed` })
}
```

**File: `api/quote.js`**

```javascript
import { quote } from './data-store.js'

export default function handler(req, res) {
  if (req.method === 'GET') {
    res.status(200).json(quote)
    return
  }

  res.status(405).json({ error: `Method ${req.method} not allowed` })
}
```

Notice we did **not** need to change a single line inside `src/api/habitsApi.js`, `src/api/tasksApi.js`, or `src/api/quoteApi.js` — they already call `fetch` against `${API_BASE_URL}/habits`, `${API_BASE_URL}/habits/${id}`, etc., using the `API_BASE_URL` constant from `src/api/config.js`. All we need to do is point that constant at our new serverless endpoints for production, via the environment variable layering we already built in Part 1.

**File: `.env.production`** *(update the value)*

```
VITE_API_URL=/api
```

Since our deployed frontend and these serverless functions live on the **exact same domain** once deployed to Vercel, a relative path (`/api`) is all we need — no separate URL, and critically, **no CORS configuration at all**, since same-origin requests never trigger CORS in the first place.

### ✅ The Verification

We'll fully verify this once it's actually deployed later in this part — Vercel's serverless functions don't run under `npm run dev` the way our frontend does. For now, confirm all six files save without errors, and double-check every filename and folder path matches exactly what's shown above — Vercel's routing depends entirely on this exact file structure.

---

## 🎯 The Target: Adding `vercel.json` for correct client-side routing

### 🧠 The Concept: Recall the "SPA refresh problem" flagged back in Phase 6

We explicitly called this out as a "preview of Phase 9" in Phase 6, Part 1's Reference Section: a plain static file host, asked directly for `/tasks`, will look for a literal file named `tasks` and fail with a real 404, since our router only ever creates that illusion of a page client-side, after `index.html` has already loaded. We need to tell Vercel: "for any URL that isn't a real file or an `/api/...` route, just serve `index.html`, and let our client-side React Router take over from there."

### 🛠️ The Implementation

**File: `vercel.json`** *(project root)*

```json
{
  "rewrites": [
    {
      "source": "/((?!api/).*)",
      "destination": "/index.html"
    }
  ]
}
```

This single rewrite rule reads as: "for any request path that does **not** start with `api/` (the negative lookahead `(?!api/)` excludes it), serve `index.html` instead." This correctly leaves our serverless function routes (`/api/habits`, `/api/tasks/3`, etc.) untouched, while making every other URL — `/tasks`, `/habits/3`, `/settings`, even a typo'd `/nonsense` — resolve to our single HTML entry point, letting React Router's own logic (including our 404 page from Phase 6) take over exactly as it does in local development.

### ✅ The Verification

Confirm the file saved at the project root (same folder as `package.json` and `vercel.json`'s sibling files like `vite.config.js`). We'll verify its actual effect once deployed.

---

## 🎯 The Target: Initializing Git and pushing to GitHub

### 🧠 The Concept: Git is the project's memory; GitHub is where Vercel comes to read it

Vercel's entire deployment model is **Git-based**: you don't manually upload files — you push code to a Git repository, and Vercel watches that repository, automatically building and deploying whenever it changes. If you haven't used Git before, think of it as a detailed, permanent history of every change ever made to your project, and **GitHub** as a website that hosts a copy of that history so other services (like Vercel) can access it.

### 🛠️ The Implementation

If you don't already have a Git repository for this project, initialize one:

```bash
git init
```

Create a `README.md` describing the project (good practice, and the first thing visitors to your GitHub repo will see):

**File: `README.md`**

```markdown
# Task & Habit Tracker

A full-featured task and habit tracking app built step-by-step across the
"React 19 Tutorial Series: Zero to Production."

## Features

- Task and habit management with optimistic UI updates
- Client-side routing with protected routes
- Dark mode with persisted preferences
- Form handling using React 19 Actions, `useActionState`, and `useFormStatus`
- Automated test suite (Vitest + React Testing Library)

## Local development

1. `npm install`
2. Copy `.env.example` to `.env.development` and adjust values if needed
3. `npm run server` (starts the local mock API on port 4000)
4. `npm run dev` (starts the Vite dev server on port 5173)

## Testing

```bash
npm test
```

## Building for production

```bash
npm run build
npm run preview
```
```

Confirm your `.gitignore` is complete and correct before your first commit — this determines exactly what does and doesn't get pushed to GitHub:

**File: `.gitignore`** *(final, complete version)*

```
node_modules
dist
.env
.env.local
.env.development
.env.production
```

Now stage and commit everything:

```bash
git add .
git commit -m "Initial commit: Task & Habit Tracker, complete through Phase 9"
```

Go to [github.com](https://github.com), sign in (or create a free account), and create a **new, empty repository** — do **not** initialize it with a README, `.gitignore`, or license, since our local project already has these; adding them on GitHub's side would create conflicting files. Name it `task-habit-tracker`.

GitHub will show you a page with setup commands. Use the "push an existing repository" section, which looks like this (replace `your-username` with your actual GitHub username):

```bash
git remote add origin https://github.com/your-username/task-habit-tracker.git
git branch -M main
git push -u origin main
```

### ✅ The Verification

Refresh your repository's page on GitHub. Confirm you see every file and folder from our project — `src/`, `api/`, `package.json`, `vercel.json`, `README.md`, and so on. Critically, confirm `node_modules/`, `dist/`, and every `.env*` file are **absent** — proof our `.gitignore` correctly excluded them. Click into `src/App.jsx` on GitHub and confirm it shows the real, current contents of your file — proof the push genuinely succeeded.

---

## 🎯 The Target: Creating a Vercel account and importing the project

### 🧠 The Concept: Vercel is a factory that watches your GitHub repo and builds a fresh product every time it changes

### 🛠️ The Implementation

1. Go to [vercel.com](https://vercel.com) and sign up — choose **"Continue with GitHub"**, which is the simplest path and what enables the automatic Git integration this entire part depends on.
2. Once signed in, click **"Add New..." → "Project"**.
3. Vercel will show a list of your GitHub repositories — find `task-habit-tracker` and click **"Import"**.
4. On the configuration screen, Vercel should **automatically detect** this as a Vite project (via `vite.config.js` and `package.json`), pre-filling:
   * **Framework Preset:** Vite
   * **Build Command:** `vite build` (equivalent to our `npm run build`)
   * **Output Directory:** `dist`

These defaults match our project exactly, since we've been following Vite's conventions throughout this entire series — no changes needed here.

### 🎯 The Target: Configuring production environment variables in Vercel

### 🧠 The Concept: Since `.env.production` is gitignored, Vercel never sees it — you must tell Vercel these values directly

This is a genuinely important, easy-to-miss detail: we deliberately added `.env.production` to `.gitignore` back in Phase 9, Part 1, following the correct security practice of never committing environment-specific configuration to version control. This means **Vercel has no way to know `VITE_API_URL=/api`** unless we tell it directly, through Vercel's own interface.

### 🛠️ The Implementation

Still on the import/configuration screen (or, if you've already clicked past it, via **Project → Settings → Environment Variables** after creating the project), add:

| Key | Value | Environments |
|---|---|---|
| `VITE_API_URL` | `/api` | Production, Preview, Development |

Check all three environment checkboxes (Production, Preview, Development) — this ensures every kind of deployment Vercel creates (the live production site, and every preview deployment we'll create shortly) has this value available.

Click **"Deploy."**

### ✅ The Verification

Vercel will show a real-time build log. **Expected output** (abbreviated):

```
Cloning github.com/your-username/task-habit-tracker...
Running "vite build"
vite v6.0.1 building for production...
✓ 148 modules transformed.
dist/index.html                       0.48 kB
dist/assets/index-a1b2c3d4.js        98.20 kB
dist/assets/TasksPage-b2c3d4e5.js     4.85 kB
...
Build Completed
Deploying outputs...
Deployment Completed
```

Once finished, Vercel shows a **"Congratulations!"** screen with a live preview and a real URL, something like `https://task-habit-tracker-yourname.vercel.app`. Click it.

1. Confirm the Dashboard page loads — the quote widget, summary cards, everything.
2. Confirm the URL bar shows `https://...` (a padlock icon) — **automatic HTTPS**, provided entirely by Vercel, with zero certificate configuration on your part.
3. Click through **Tasks**, **Habits**, **Settings** in the Navbar. Confirm each loads correctly and the URL updates — this specifically confirms our `vercel.json` rewrite rule is working; without it, refreshing directly on `/tasks` (try it!) would 404.
4. Toggle a habit or task. Confirm the optimistic instant-update behavior from Phase 4 still works, and check DevTools → Network tab to confirm the request goes to `/api/habits/...` on the **same domain** as the page itself — proof our serverless functions are live and responding.
5. Try adding a new task. Confirm it appears in the list.
6. Navigate to **Settings** while logged out — confirm the redirect to `/login` still works, log in with any username, and confirm you land back on Settings.
7. Toggle dark mode — confirm it applies and persists across a refresh.

**A note on the "resets sometimes" caveat:** if you refresh the page a few minutes later, or after Vercel's infrastructure cycles your function to a fresh instance, you may see the habits/tasks list revert to its original seeded state, even if you'd added or toggled something. This is the expected, explicitly-flagged behavior of our in-memory demo data store, not a bug in anything we've built — it's the direct, honest consequence of the trade-off described at the start of this part.

---

## 🎯 The Target: Understanding and triggering a Preview Deployment

### 🧠 The Concept: A complete, disposable copy of your app for every single proposed change

This is the feature that makes Vercel's Git integration genuinely special, beyond just "auto-deploy on push": **every branch and every pull request automatically gets its own full, live, shareable deployment** — entirely separate from your production site — the moment you push it. This lets you (or teammates, or reviewers) click around a *fully working, real, live version* of a proposed change before ever merging it into production.

### 🛠️ The Implementation

Create a new branch for a small, real change:

```bash
git checkout -b add-footer-credit
```

Let's make a genuine, visible change — adding a small footer to the app:

**File: `src/components/Footer.jsx`**

```jsx
function Footer() {
  return (
    <footer className="app-footer">
      Built with React 19 · Task & Habit Tracker
    </footer>
  )
}

export default Footer
```

**File: `src/App.jsx`** *(add the import and render it at the bottom of the returned tree, just before the closing `</div>`)*

```jsx
// ...(add this import alongside the other component imports)...
import Footer from './components/Footer.jsx'

// ...(inside the final return statement, add <Footer /> as the very last
//     element, immediately before the closing </div> of className="app")...
```

**File: `src/index.css`** *(append this block)*

```css
/* --- Footer --- */

.app-footer {
  text-align: center;
  padding: 1.5rem 0;
  margin-top: 1rem;
  font-size: 0.8rem;
  color: var(--color-text-muted);
}
```

Commit and push this branch:

```bash
git add .
git commit -m "Add footer credit"
git push -u origin add-footer-credit
```

### ✅ The Verification

1. Go to your repository on GitHub. You should see a prompt to **"Compare & pull request"** for the branch you just pushed — click it, and create the pull request (you can merge it later; don't merge it yet).
2. Within a few seconds to a couple of minutes, look at the pull request page on GitHub. Confirm a **Vercel bot comment** appears automatically, showing a **"Preview"** link with its own unique URL (something like `https://task-habit-tracker-git-add-footer-credit-yourname.vercel.app`).
3. Click that preview URL. Confirm you see the **entire app, fully functional**, with your new footer visible at the bottom — and confirm your **production URL** (the one from the previous step) does **not** yet show the footer, proving these are genuinely separate, independent deployments.
4. Back on GitHub, click **"Merge pull request"** to merge `add-footer-credit` into `main`.
5. Return to your Vercel dashboard. Confirm a **new Production deployment** automatically begins the moment the merge completes — no manual redeploy button needed.
6. Once it finishes, refresh your actual production URL. Confirm the footer now appears there too — production has caught up to what the preview showed you in advance.

This preview-then-promote workflow — verify a real, live, isolated deployment of a change *before* it reaches production — is exactly what most professional teams mean by **CI/CD** (Continuous Integration / Continuous Deployment): every change is automatically built and made available for verification, and merging to the main branch automatically ships it live, with no manual server access or deployment steps ever required.

---

## 📚 Reference Section: Phase 9, Part 2

### What a genuinely production-ready backend would add

We were explicit throughout this part that our serverless data store is a teaching simplification. A real production version of this app would replace `api/data-store.js` with a connection to an actual persistent database. Popular options that pair naturally with a Vercel deployment, worth knowing by name even though implementing them is outside this series' scope:

* **Vercel Postgres** or **Vercel KV** — managed database products integrated directly into the Vercel platform, configurable from the same dashboard we just used for environment variables.
* **Supabase** or **Neon** — popular, generous free-tier hosted Postgres databases, framework-agnostic.
* **MongoDB Atlas** — a popular free-tier hosted NoSQL database, if a document-based data model is preferred over relational tables.

Any of these would replace the in-memory arrays in `data-store.js` with real database queries inside each `api/*.js` handler — the *shape* of our `fetch`-based frontend code (`habitsApi.js`, `tasksApi.js`) would need **zero changes** at all, since it only ever talks to `/api/...` URLs and has no idea what's actually powering them on the other end. This is precisely the payoff of the clean separation between frontend and API layer we established all the way back in Phase 4.

### Vercel's free Hobby plan — what's included

* Unlimited personal projects, with automatic HTTPS on every deployment.
* Automatic Git-based deployments for unlimited pushes to any branch.
* Automatic Preview Deployments for every branch and pull request, exactly as demonstrated above.
* A generous monthly allowance of serverless function execution time and bandwidth, suitable for personal projects and portfolios (specific numeric limits are best checked directly on Vercel's current pricing page, since they're periodically adjusted).
* One production custom domain connectable for free (e.g., `yourname.com` instead of `yourname.vercel.app`), configurable under **Project → Settings → Domains**.

The Hobby plan is explicitly intended for personal, non-commercial projects — exactly the kind of project this series has built.

### Rolling back a bad deployment

Every deployment Vercel ever creates for your project remains listed under the **"Deployments"** tab, indefinitely. If a production deploy ever introduces a bug, you can click any previous, known-good deployment in that list and select **"Promote to Production"** — instantly reverting the live site to that exact prior build, without needing to revert any Git commits first. This is a genuinely valuable safety net worth knowing about before you ever need it.

### Environment variables per-environment, revisited

Recall we checked all three boxes (Production, Preview, Development) when adding `VITE_API_URL` in Vercel's dashboard. This mirrors the exact `.env.development`/`.env.production` layering we built locally in Phase 9, Part 1 — Vercel lets you additionally set **different values per environment** directly in its UI (for instance, a Preview environment could point at a separate staging database, distinct from both your local dev setup and your live production database) — a capability worth remembering as this project (or your next one) grows beyond what a single shared value can support.

### Common errors & fixes when deploying to Vercel

| Symptom | Likely cause | Fix |
|---|---|---|
| Build fails with `Cannot find module` | A dependency is listed only in `devDependencies` but is actually needed at build time in a way Vercel's install step doesn't cover, or `node_modules` was accidentally committed and is stale | Confirm `package.json`/`package-lock.json` are correct and committed; Vercel always runs a fresh `npm install` |
| Site loads, but refreshing on `/tasks` (or any non-root URL) shows a 404 | Missing or incorrect `vercel.json` rewrite rule | Confirm `vercel.json` exists at the project root with the exact rewrite rule shown above |
| Data never loads on the deployed site; DevTools shows failed requests to `undefined/habits` | `VITE_API_URL` environment variable wasn't set in Vercel's dashboard (recall: `.env.production` is gitignored, so Vercel never sees it automatically) | Add `VITE_API_URL=/api` under Project → Settings → Environment Variables, then redeploy |
| Preview deployment doesn't appear on a pull request | The GitHub repository wasn't properly connected/authorized to Vercel, or the push didn't actually reach GitHub | Confirm the branch was genuinely pushed (`git push -u origin branch-name`) and that Vercel's GitHub integration has access to the repository under Vercel's account settings |
| Serverless function returns a 500 error | An uncaught exception inside the handler (e.g., `req.body` was `undefined` because the request didn't send a JSON body/content-type) | Check the function's logs under the deployment's "Functions" tab in Vercel's dashboard for the exact error and stack trace |
| Changes pushed to `main` don't appear on the production URL | Vercel's production deployment is tied to whichever branch is configured as the **Production Branch** (default: `main`) — confirm this wasn't changed | Check Project → Settings → Git → Production Branch |
