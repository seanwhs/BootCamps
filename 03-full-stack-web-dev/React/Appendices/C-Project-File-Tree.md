# Appendix C: Final Project File Tree

## Why this appendix exists

Across nine phases, files were created, modified, refactored, and occasionally deleted (`sampleData.js`, `Dashboard.jsx`, and every temporary experiment file). This appendix shows the **complete, final state** of the project exactly as it stands at the end of Phase 9, Part 2 — every file that should exist in your project folder right now, with a one-line description of its job. Use this to double-check your own project structure matches, or to get your bearings before diving back into any specific area of the code.

---

## The complete tree

```
task-habit-tracker/
│
├── api/                                  # Vercel Serverless Functions (Phase 9, Part 2)
│   ├── data-store.js                     # Shared in-memory demo data (habits, tasks, quote)
│   ├── quote.js                          # GET /api/quote
│   ├── habits/
│   │   ├── index.js                      # GET/POST /api/habits
│   │   └── [id].js                       # PATCH /api/habits/:id
│   └── tasks/
│       ├── index.js                      # GET/POST /api/tasks
│       └── [id].js                       # PATCH /api/tasks/:id
│
├── public/
│   └── vite.svg                          # Default static favicon asset from Vite's scaffold
│
├── src/
│   ├── main.jsx                          # App entry point: mounts React, wraps Router + Providers
│   ├── App.jsx                           # Root component: data/state orchestration + route definitions
│   ├── index.css                         # Global stylesheet, including theme CSS variables
│   │
│   ├── api/                              # Frontend networking layer (talks to /api or json-server)
│   │   ├── config.js                     # Exports API_BASE_URL from environment variables
│   │   ├── habitsApi.js                  # fetchHabits, updateHabit, createHabit
│   │   ├── tasksApi.js                   # fetchTasks, updateTask, createTask
│   │   ├── tasksApi.test.js              # Unit tests for tasksApi, with mocked fetch (Phase 8)
│   │   ├── quoteApi.js                   # fetchQuote (with artificial delay/failure, for teaching)
│   │   └── quoteCache.js                 # Module-level Promise cache, required for use() + Suspense
│   │
│   ├── components/                       # Reusable UI building blocks
│   │   ├── Navbar.jsx                    # Top bar: title, theme toggle, nav links
│   │   ├── Badge.jsx                     # Generic reusable "pill" component (children-based)
│   │   ├── Badge.test.jsx                # Unit tests for Badge (Phase 8)
│   │   ├── HabitCard.jsx                 # One habit's row; memoized (Phase 9)
│   │   ├── HabitCard.test.jsx            # Unit tests for HabitCard, incl. stopPropagation (Phase 8)
│   │   ├── TaskCard.jsx                  # One task's row; memoized (Phase 9)
│   │   ├── HabitsSection.jsx             # Habit list + add form + remaining count (useMemo, Phase 9)
│   │   ├── TasksSection.jsx              # Task list + filters + add form + keyboard shortcut
│   │   ├── FilterTabs.jsx                # Generic "All/Active/Completed" tab control
│   │   ├── HabitForm.jsx                 # Action-based habit creation form
│   │   ├── TaskForm.jsx                  # Action-based task creation form, with ref-based shake
│   │   ├── TaskForm.test.jsx             # Unit tests for TaskForm, with mocked onAddTask (Phase 8)
│   │   ├── FormTextInput.jsx             # Reusable input; reads useFormStatus; ref-as-prop + shake handle
│   │   ├── SubmitButton.jsx              # Reusable submit button; reads useFormStatus
│   │   ├── CancelButton.jsx              # Reusable cancel button; reads useFormStatus
│   │   ├── QuoteOfTheDay.jsx             # Reads a Promise via use(); pairs with Suspense
│   │   ├── ErrorBoundary.jsx             # The series' one class component; catches render errors
│   │   ├── ProtectedRoute.jsx            # Redirects to /login when not authenticated
│   │   ├── Toast.jsx                     # Bottom-of-screen notification for failed saves
│   │   └── Footer.jsx                    # Small footer credit (added during Phase 9, Part 2 demo)
│   │
│   ├── pages/                            # Route-level components
│   │   ├── DashboardPage.jsx             # Overview: quote widget + summary cards
│   │   ├── TasksPage.jsx                 # Full Tasks page (wraps TasksSection)
│   │   ├── HabitsLayout.jsx              # Nested-route parent; provides Outlet context
│   │   ├── HabitsPage.jsx                # Full Habits page (index route under /habits)
│   │   ├── HabitDetailPage.jsx           # Single habit detail view (/habits/:habitId)
│   │   ├── SettingsPage.jsx              # Theme toggle, logged-in user info, logout, about
│   │   ├── LoginPage.jsx                 # Simulated login form (Action-based)
│   │   └── NotFoundPage.jsx              # Catch-all 404 page
│   │
│   ├── context/                          # App-wide state via the three-file Context pattern
│   │   ├── ThemeContext.js               # createContext() only
│   │   ├── ThemeProvider.jsx             # Owns theme state (via useLocalStorage), applies data-theme
│   │   ├── useTheme.js                   # useContext wrapper with a "missing Provider" safety check
│   │   ├── AuthContext.js                # createContext() only
│   │   ├── AuthProvider.jsx              # Owns simulated user state (via useLocalStorage)
│   │   └── useAuth.js                    # useContext wrapper with a "missing Provider" safety check
│   │
│   ├── hooks/                            # Custom, reusable hooks
│   │   ├── useLocalStorage.js            # Generic localStorage-backed useState replacement
│   │   ├── useToggle.js                  # Generic boolean toggle (value + toggle/setTrue/setFalse)
│   │   ├── useToggle.test.js             # Unit tests for useToggle via renderHook (Phase 8)
│   │   └── useKeyboardShortcut.js        # Generic window keydown listener with cleanup
│   │
│   ├── reducers/
│   │   └── dataReducer.js                # Consolidated habits/tasks/isLoading/loadError reducer
│   │
│   └── tests/
│       └── setup.js                      # Vitest setup file; wires up @testing-library/jest-dom
│
├── db.json                               # Local mock database, served by json-server (dev only)
├── vercel.json                           # SPA rewrite rule for client-side routing on Vercel
├── vite.config.js                        # Vite + Vitest configuration (plugins, test environment)
├── package.json                          # Dependencies and npm scripts
├── package-lock.json                     # Exact locked dependency versions (auto-generated)
├── .env                                  # Universal environment variables (currently empty/placeholder)
├── .env.example                          # Committed template showing required variable names
├── .env.development                      # VITE_API_URL for local dev (gitignored)
├── .env.production                       # VITE_API_URL for production (gitignored)
├── .gitignore                            # Excludes node_modules, dist, and all .env* files
└── README.md                             # Project overview and local setup instructions
```

---

## Files that existed temporarily, and were deliberately deleted

Across this series, several files were created purely as disposable, hands-on experiments — each one proved a specific concept, then was removed so it wouldn't linger in the final project. If you're comparing your own project against the tree above and don't see these, that's correct:

| File | Purpose it served | Phase |
|---|---|---|
| `src/KeyExperiment.jsx` | Proved why array-index keys cause state to attach to the wrong list item | Phase 2, Part 2 |
| `src/CleanupExperiment.jsx` | Proved why `useEffect` cleanup functions prevent memory leaks | Phase 4, Part 1 |
| `src/RefExperiment.jsx` | Proved that refs don't trigger re-renders, unlike state | Phase 7, Part 1 |
| `src/HookIsolationExperiment.jsx` | Proved that two components calling the same custom hook get independent state | Phase 7, Part 2 |
| `src/data/sampleData.js` | Original hardcoded sample data; replaced entirely once real API fetching was introduced | Removed in Phase 4, Part 1 |
| `src/components/Dashboard.jsx` | Original single-screen layout component; replaced by the `pages/` structure once routing was introduced | Removed in Phase 6, Part 1 |

---

## Files that changed shape significantly across the series

A few files were rewritten substantially enough, across multiple phases, that it's worth knowing their evolution at a glance:

* **`src/App.jsx`** — started as a two-line static heading (Phase 1), grew to own `useState`-based data (Phase 2–3), then `useEffect`-based fetching (Phase 4), then `useReducer` (Phase 5), then route definitions (Phase 6), then `useCallback`-wrapped handlers and `React.lazy` page imports (Phase 9).
* **`src/index.css`** — grew from a five-line reset (Phase 1) to a full stylesheet with CSS custom properties driving dark mode (Phase 5), plus dozens of component-specific rules added incrementally throughout.
* **`src/components/HabitCard.jsx`** — went from fully static (Phase 1), to self-managing state (Phase 2), to fully props-driven/"dumb" (Phase 2, after lifting state up), to including a Link and stopPropagation logic (Phase 6–7), to finally being wrapped in `memo()` (Phase 9).
