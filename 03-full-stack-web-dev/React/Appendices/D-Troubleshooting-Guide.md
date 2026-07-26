# Appendix D: Master Troubleshooting Guide

## Why this appendix exists

Every phase in this series ended with a "Common Errors & Fixes" table scoped to that phase's specific topic. That's useful while you're actively working through a given part, but it means a single symptom — say, "my component won't re-render" — might have contributing causes spread across four different phases' tables. This appendix consolidates **every** troubleshooting entry from the entire series into one master reference, organized by **symptom category** rather than by phase, so you can jump straight to the kind of problem you're seeing, regardless of which part introduced it.

Each entry lists which Phase/Part originally covered it, in case you want the full context and explanation.

---

## 1. Setup & environment problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `npm: command not found` | Node.js not installed, or terminal not restarted after installing | Reinstall Node.js from nodejs.org; fully restart your terminal | 1.1 |
| `EACCES` permission errors during install | npm trying to write to a protected system folder | Avoid `sudo npm install`; reinstall Node via the official installer or a version manager like `nvm` | 1.1 |
| Port 5173 already in use | Another Vite server is already running | Stop the other process, or use the alternate port Vite automatically offers | 1.1 |
| `import.meta.env.VITE_API_URL` is `undefined` | `.env` file missing/misnamed, or dev server wasn't restarted after editing it | Confirm exact filename (`.env.development`, not `.env`); restart `npm run dev` | 4.1, 9.1 |
| Production build shows the wrong (dev) API URL | `.env.production` missing, misnamed, or build wasn't re-run after editing it | Confirm exact filename; re-run `npm run build` | 9.1 |

## 2. Blank screen / app won't render at all

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Blank white page, no visible error | JavaScript error thrown during render | Open DevTools Console (F12) — the red error names the exact file/line | 1.1 |
| `X is not defined` in console | Forgot to `import` a component before using it in JSX | Add the missing `import ComponentName from './ComponentName.jsx'` | 1.2 |
| Component renders as literal text (e.g., word "Navbar" on screen) | Wrote `<navbar />` lowercase instead of `<Navbar />` | Capitalize the JSX tag to match the function name exactly | 1.2 |
| Nothing renders, no error at all | Missing `export default ComponentName` at the bottom of the file | Add the export line | 1.2 |
| Whole app goes blank/white with a console error, instead of showing a graceful fallback | No Error Boundary anywhere above the failing component | Wrap the relevant section in an `ErrorBoundary` | 4.2 |

## 3. JSX syntax errors

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `Adjacent JSX elements must be wrapped in an enclosing tag` | Returned two sibling elements with no shared parent/Fragment | Wrap in a `<div>` or a Fragment `<>...</>` | 1.2 |
| `Unexpected token` pointing at a `<` in a `.js` file | JSX syntax used inside a plain `.js` file instead of `.jsx` | Rename the file extension to `.jsx` | 1.2 |

## 4. Props issues

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Prop shows blank/`undefined` on screen | Typo in the prop name between parent and child | Double-check exact spelling on both sides | 1.3 |
| `Cannot read properties of undefined (reading 'label')` | Accessing an array index that doesn't exist (e.g., `habits[5]` on a 2-item array) | Check indices against actual array length; prefer `.map()` over manual indexing | 1.3, 2.2 |
| Changing a prop inside a component has no effect, or warns | Attempting to mutate a prop directly | Never reassign props; use state instead if something needs to change | 1.3 |
| `children` is `undefined` inside a custom component | Component was self-closed (`<Badge />`) instead of given content between tags | Use `<Badge>...</Badge>` | 1.3 |

## 5. State & re-rendering problems (`useState`, immutability)

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Clicking does nothing, no error | Passed a *called* function (`onClick={handleClick()}`) instead of a reference | Remove the parentheses, or wrap in an arrow function if arguments are needed | 2.1 |
| `React Hook "useState" is called conditionally` | Hook placed inside an `if`, loop, or nested function | Move the hook call to the top level of the component | 2.1 |
| Clicking one item toggles a *different* item, or all items at once | Missing/incorrect `id` matching, or using array index instead of a stable id | Use `.map()` with a unique, stable identifier for comparison | 2.1, 2.2 |
| State appears to update, but the UI doesn't re-render | Mutated the existing object/array instead of creating a new one | Always build a new array/object via spread/`.map()`; never mutate directly | 2.1 |
| `Too many re-renders` error | Calling the setter function directly during render (e.g. `onClick={setX(true)}`) | Wrap it: `onClick={() => setX(true)}` | 2.1 |
| Console warning: `You provided a value prop to a form field without an onChange handler` | Set `value` on an input but forgot `onChange` | Add the corresponding `onChange` handler | 3.1 |
| Typing in a controlled input does nothing visually | `onChange` doesn't call the state setter, or calls it incorrectly | Confirm `onChange={(e) => setValue(e.target.value)}` exactly | 3.1 |
| Existing fields disappear from state after a reducer dispatch | Forgot to spread `...state` before overriding specific fields | Always start each `case`'s return with `...state` | 5.2 |

## 6. Lists and `key` problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Console warning: `Each child in a list should have a unique "key" prop` | `key` omitted from the outermost element inside `.map()` | Add `key={item.id}` (or another stable unique value) | 2.2 |
| Typed input text or checkbox state "jumps" to the wrong item after reordering/deleting | Using array index (or no key) on a list with per-item local state | Switch to a stable, unique data field (like `id`) | 2.2 |
| `.map is not a function` | The value isn't actually an array yet (e.g., still `undefined` while loading) | Guard with a default empty array, or confirm data has loaded first | 2.2, 4.1 |
| Duplicate key warning | Two or more items share the same `id` | Fix the underlying data so every item has a truly unique identifier | 2.2 |

## 7. Event handling problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Clicking a nested element also triggers its parent's click handler | Event bubbling — the click ripples up through ancestors | Call `event.stopPropagation()` inside the nested element's own handler | 2.3, 7.1 |
| The number `0` appears unexpectedly on screen | Used `count && <Something />` where `count` can legitimately be `0` | Use an explicit comparison instead: `count > 0 && <Something />` | 2.3 |
| `Cannot read properties of undefined (reading 'value')` in an event handler | `event.target` doesn't have a `.value` (wrong element type) | Confirm the handler is on an `<input>`/`<textarea>`/`<select>` | 2.3 |
| A button inside a form submits/reloads the page unexpectedly | Forgot `type="button"` on a non-submit `<button>` | Always explicitly set `type="button"` | 2.3 |

## 8. Forms & Actions problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `formData.get('label')` returns `null` | `<input>` is missing a `name` attribute, or it doesn't match exactly | Add/correct the `name` attribute | 3.2 |
| Form still reloads the page on submit | Passed the wrong thing to `action` (not the wrapped function from `useActionState`) | Confirm `action={formAction}`, not a string URL or the raw function | 3.2 |
| `isPending` never becomes `true` | Action function isn't actually `async`/doesn't return a Promise | Mark it `async`; ensure it genuinely awaits something | 3.2 |
| `useActionState is not a function` | Imported from `react-dom` instead of `react` | `import { useActionState } from 'react'` | 3.2 |
| `pending` from `useFormStatus` is always `false` | Called in the same component that renders the `<form>`, not a descendant | Move the call into a genuinely nested child component | 3.3 |
| `useFormStatus is not a function` | Imported from `'react'` instead of `'react-dom'` | `import { useFormStatus } from 'react-dom'` | 3.3 |
| Submit button never becomes enabled despite valid text | Validation checks the wrong/stale variable | Confirm `isValid` is derived from the trimmed value, recalculated fresh each render | 3.1 |
| Pressing Enter doesn't submit a form | `onSubmit`/Action attached to the button instead of the `<form>` element | Move it to the `<form>` itself | 3.1 |

## 9. Data fetching problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `Failed to fetch`, page stuck loading forever | Backend (`json-server`) isn't running, or port mismatch with `.env` | Confirm `npm run server` is running and ports match | 4.1 |
| CORS error in console | Frontend and backend on different origins without permissive CORS | Not an issue for our local `json-server` setup (allows all origins); for real backends, configure CORS explicitly | 4.1 |
| `SyntaxError: Unexpected token < in JSON` | URL pointed at an HTML error page instead of real JSON | Double-check the URL; confirm `response.ok` is checked before `.json()` | 4.1 |
| `useEffect` runs twice in development, even with `[]` | Expected under `<StrictMode>` — a deliberate double-mount check | No fix needed; doesn't happen in production builds | 4.1 |
| Console warning: `An optimistic state update occurred outside a transition or action` | `addOptimistic(...)` called outside `startTransition`/a form Action | Wrap the entire async operation in `startTransition(async () => { ... })` | 4.3 |
| Optimistic value never reverts after a failure | Real state setter accidentally still called on the failure path | Ensure the real `setX` call only happens on the success path | 4.3 |
| Data loads on the deployed site fails; requests go to `undefined/habits` | `VITE_API_URL` not set in Vercel's dashboard (recall `.env.production` is gitignored) | Add `VITE_API_URL=/api` under Vercel Project → Settings → Environment Variables, then redeploy | 9.2 |

## 10. `use` / Suspense / Error Boundary problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Infinite loop of network requests | A new Promise was created directly during render and passed straight to `use` | Create the Promise once (module scope or cached state), never inline during render | 4.2 |
| `Suspense` fallback never disappears | The underlying Promise never resolves or rejects | Confirm it genuinely settles; check the Network tab | 4.2 |
| Error Boundary's "Try Again" doesn't actually retry | Only reset `hasError`, without supplying a genuinely new Promise/data | Ensure `onRetry` provides a fresh Promise | 4.2 |
| `use is not a function` | Imported from `react-dom`, or on a React version below 19 | Import from `'react'`; confirm `react@19` via `npm list react` | 4.2 |

## 11. Context problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `useTheme`/`useAuth` "must be called from within a Provider" error | Component rendered outside the relevant Provider, or Provider missing from `main.jsx` | Confirm the Provider wraps the component tree in `main.jsx` | 5.1, 6.2 |
| Persisted value (theme/auth) resets on every page refresh | localStorage read/write logic missing or broken | Confirm `useLocalStorage` usage and storage key match | 5.1, 7.2 |
| Whole app performance degrades on frequent Context changes | Context used for rapidly-changing state (e.g., keystrokes) | Move that state back to local `useState`; reserve Context for infrequent, global values | 5.1 |

## 12. Routing problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Router-related hook errors (`useNavigate`, etc.) after adding routing | Component rendered outside `<BrowserRouter>` | Confirm `<BrowserRouter>` wraps everything in `main.jsx` | 6.1 |
| Clicking a link causes a full page reload | Used a plain `<a href>` instead of `<Link>`/`<NavLink>` | Replace with React Router's `Link`/`NavLink` | 6.1 |
| The root nav link stays highlighted on every page | Missing `end` prop on that specific `NavLink` | Add `end` to the root route's link only | 6.1 |
| 404 page shows for a route you did define | Wildcard `<Route path="*">` listed before real routes | Move the wildcard route to be listed last | 6.1 |
| Refreshing on a non-root URL (e.g. `/tasks`) shows a real 404 | Static host lacks an SPA fallback rule | Configure rewrites (`vercel.json`) at deployment time | 6.1, 9.2 |
| `useOutletContext` returns `undefined`, crashes on destructure | Component isn't rendered as a genuine child route of the layout providing context | Confirm nested `<Route>` structure in `App.jsx` | 6.2 |
| Detail page shows "not found" for an item that clearly exists | Comparing `item.id === urlParam` directly (number vs. string mismatch) | Compare with `String(item.id) === urlParam` | 6.2 |
| After login, user lands on `/` instead of the original page | `location.state` not passed through `<Navigate>`, or not read correctly on the other end | Confirm `state={{ from: location }}` and `location.state?.from?.pathname` | 6.2 |

## 13. Refs problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `Cannot read properties of null (reading 'focus')` | Called `.current.focus()` before the element/handle was attached | Use optional chaining (`ref.current?.focus()`); only call inside `useEffect`/handlers | 7.1 |
| Changing a ref's value doesn't update the screen | Expected — this is the defining property of refs, not a bug | Use `useState` instead if the value should be visible | 7.1 |
| `ref` prop is `undefined` inside a custom component | Not using the React 19 ref-as-a-prop pattern correctly, or React version below 19 | Confirm `react@19`; destructure `ref` directly from the props parameter | 7.1 |
| Keyboard shortcut fires while typing in an unrelated input | Missing/incorrect guard against `event.target` being an input/textarea | Confirm the "is typing elsewhere" check examines `event.target.tagName` | 7.1, 7.2 |

## 14. Custom hooks problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| ESLint doesn't flag a Rules-of-Hooks violation in your new function | Function name doesn't start with `use` | Rename it so the linter recognizes it as a hook | 7.2 |
| A `useEffect` depending on a hook's returned function re-runs every render | The function wasn't wrapped in `useCallback` inside the custom hook | Wrap the returned function(s) in `useCallback` | 7.2, 9.1 |
| `Invalid hook call` | Called from a plain function, or from inside a conditional/loop | Call unconditionally, at the top level, from a component or another hook | 7.2 |

## 15. Testing problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `Unable to find an element with the text: ...` | Text genuinely isn't rendered, or split across multiple nodes | Confirm actual rendered output; try a regex matcher for partial matches | 8.1 |
| `Warning: An update to X was not wrapped in act(...)` | A state update happened outside Testing Library's automatic wrapping | Wrap the call in `act(() => { ... })` | 8.1 |
| Router errors during a test | Component uses Router hooks/components without a Router context | Wrap the render in `<MemoryRouter>` | 8.1 |
| A test passes even though the behavior seems broken | Test isn't asserting what you think it is | Deliberately break the real component temporarily and confirm the test fails | 8.1 |
| Mocked `fetch`/module isn't taking effect | `vi.mock()` called somewhere other than the top level of the file | Move `vi.mock(...)` calls to the top of the file | 8.1 |

## 16. Performance problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| `memo`-wrapped component still re-renders every time its parent does | A non-memoized prop (often an inline function/object) is passed, defeating shallow comparison | Wrap the relevant function in `useCallback`, or object/array in `useMemo` | 9.1 |
| Component uses stale data after adding `useCallback`/`useMemo` | A dependency was omitted from the dependency array | Add the missing dependency | 9.1 |
| `A component was suspended by an uncached promise` with `React.lazy` | Lazy component rendered without a `<Suspense>` boundary above it | Wrap the relevant routes/component in `<Suspense fallback={...}>` | 9.1 |
| Bundle size didn't shrink much after adding `lazy()` | Shared dependencies still bundled together, limiting the split | Inspect build output chunk sizes; this is expected for genuinely shared code | 9.1 |

## 17. Deployment problems

| Symptom | Likely cause | Fix | Origin |
|---|---|---|---|
| Build fails with `Cannot find module` on Vercel | Stale/incorrect `package.json`/lockfile, or accidentally committed `node_modules` | Confirm `package.json`/`package-lock.json` are correct and committed | 9.2 |
| Preview deployment doesn't appear on a pull request | GitHub repo not properly connected to Vercel, or push didn't reach GitHub | Confirm the branch was genuinely pushed; check Vercel's GitHub integration permissions | 9.2 |
| Serverless function returns a 500 error | Uncaught exception inside the handler (e.g., missing request body) | Check the deployment's "Functions" tab in Vercel's dashboard for the exact stack trace | 9.2 |
| Changes on `main` don't appear on the production URL | Vercel's configured Production Branch was changed from `main` | Check Project → Settings → Git → Production Branch | 9.2 |

---

## The single most common root cause across this entire series

If you only remember one thing from this guide: **the overwhelming majority of "weird" React bugs trace back to either (a) mutating state/props directly instead of creating new objects/arrays, or (b) a missing/unstable `key` on a list item.** When something behaves strangely and none of the specific entries above match, check these two things first.
