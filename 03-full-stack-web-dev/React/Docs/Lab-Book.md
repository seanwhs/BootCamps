# React 19 Tutorial Series: Zero to Production
## Official Lab Book

> **What this is:** a formal, procedural companion to the tutorial series, structured the way an engineering or CS lab manual is structured — each **Lab** has stated objectives, prerequisites, required materials, a concise procedure (referencing the full tutorial for complete code rather than reproducing every line), expected results, in-lab exercises, post-lab report questions, a deliverables checklist, and a grading rubric. This is NOT a replacement for the tutorial text — it assumes the tutorial (or an equivalent lecture) has already been read, and focuses on **doing, verifying, and reporting**, exactly as a real engineering lab would.

---

## How to Use This Lab Book

- Complete labs **in order** — this curriculum is strictly cumulative; Lab 4.2 assumes Lab 4.1's code exists and works.
- Each lab produces a **Lab Report** — answers to the Post-Lab Questions, plus screenshots/terminal output where indicated. A template appears in the Appendix.
- **Do not skip the Pre-Lab Checklist.** If you can't check every box, you are not ready to start that lab — go back to the corresponding tutorial Part first.
- **Verification steps are graded, not optional.** A lab is not "done" when the code is typed — it's done when the stated Expected Result has been personally observed and can be demonstrated.
- Keep a running Git commit history throughout — many labs' deliverables reference "your most recent commit" directly.

---

## Lab Conduct & Best Practices

Just as a chemistry lab has safety rules, this lab book has a small set of non-negotiable practices:

1. **Never skip the Verification step to save time.** An unverified change is an unfinished lab, full stop.
2. **Commit after every completed lab**, with a message naming what was built (e.g., `git commit -m "Lab 2.1: useState toggling complete"`).
3. **Keep both required terminals visible at all times from Lab 4.1 onward** (`npm run dev` and `npm run server`) — an astonishing fraction of "my code doesn't work" reports trace back to one of these not running.
4. **Read error messages fully before asking for help.** Most errors in this course name the exact file, line, and problem.
5. **Do not delete disposable experiment files until their lab's Post-Lab Questions are answered** — you may need to re-run or re-check them.

---

## Grading Rubric Template (used for every lab)

| Component | Weight |
|---|---|
| Code builds and runs without errors | 25% |
| Expected Result personally verified and demonstrable | 25% |
| In-Lab Exercises completed | 20% |
| Post-Lab Questions answered completely and correctly | 20% |
| Code follows immutability/component conventions taught to date | 10% |

A lab scoring below 70% should be repeated before proceeding to the next lab — this curriculum does not tolerate gaps, since every lab builds directly on the previous one's working code.

---

# LAB 0: Environment Setup

**Estimated Duration:** 60–90 minutes
**Corresponds to:** Primers 1–4

## Learning Objectives
By the end of this lab, you will be able to:
- Operate a terminal to navigate folders and run commands
- Explain the client-server model in your own words
- Have a fully configured code editor with linting and auto-formatting
- Perform the core Git workflow: init, add, commit, branch, push

## Prerequisites
None — this is the entry point of the entire course.

## Materials/Tools Required
- A computer running Windows, macOS, or Linux, with administrator/install rights
- An internet connection
- A free GitHub account (create one now if you don't have one: github.com)

## Pre-Lab Checklist
- [ ] I have read Primers 1 through 4
- [ ] I understand, roughly, what "client," "server," and "HTTP" mean
- [ ] I understand what a "working directory" is

## Lab Procedure

**Step 1 — Install Node.js.** Download the LTS version from nodejs.org. Verify:
```bash
node --version   # must show v18 or higher
npm --version
```

**Step 2 — Install VS Code.** Download from code.visualstudio.com. Enable the `code` command in your PATH (see Primer 3 for OS-specific steps). Verify:
```bash
code --version
```

**Step 3 — Install and configure ESLint and Prettier extensions** inside VS Code. Enable "Format On Save," set Prettier as the Default Formatter.

**Step 4 — Install Git.** Verify:
```bash
git --version
```
Configure your identity, once, permanently:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Step 5 — Practice the core terminal commands** in a scratch folder:
```bash
mkdir lab-practice
cd lab-practice
mkdir a b c
ls          # or dir on Windows
cd a
cd ..
```

**Step 6 — Practice the core Git workflow** in the same scratch folder:
```bash
git init
echo "test file" > test.txt
git add .
git commit -m "First test commit"
git status
git checkout -b test-branch
echo "branch change" > test.txt
git add .
git commit -m "Branch-only change"
git checkout main
cat test.txt   # confirm it shows "test file", NOT "branch change"
```

## Expected Result
- `node`, `npm`, `code`, and `git` all report valid version numbers with no errors
- VS Code auto-formats a deliberately messy line of code on save
- Your scratch folder's `main` branch shows the original file content, unaffected by the branch-only commit

## In-Lab Exercises
1. Deliberately mistype a command (e.g., `gti status`) and read the resulting error message aloud/write it down.
2. Create a nested folder structure 3 levels deep using a single `mkdir -p` command, then `cd` into the deepest level using a single command.
3. Create a second branch, make a distinct change, and confirm switching between all three states (`main`, `test-branch`, your new branch) shows three genuinely different file contents.

## Post-Lab Questions (Lab Report)
1. In your own words, explain the client-server model using an analogy NOT taken directly from the primer text.
2. What is the difference between `git add` and `git commit`? What is the difference between `git commit` and `git push`?
3. Why does this course recommend "one tab per long-running process" rather than reusing a single terminal tab?
4. Delete your `lab-practice` scratch folder now that this lab is complete — confirm you know the correct command to do so on your OS.

## Deliverables Checklist
- [ ] Screenshot of `node --version`, `npm --version`, `git --version` all succeeding
- [ ] Screenshot of Prettier auto-formatting a messy line
- [ ] Screenshot of `git log` showing at least 2 commits from the branch exercise
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| `command not found` | Reinstall the tool; fully restart your terminal afterward |
| `EACCES` permission errors during npm install | Avoid `sudo npm install`; reinstall Node via official installer |
| Prettier doesn't format on save | Check "Format On Save" is enabled AND Prettier is the Default Formatter |
| Git commit says "nothing to commit" | You forgot `git add .` first |

---

# LAB 0.5: Orientation — The Project & Architecture

**Estimated Duration:** 30–45 minutes
**Corresponds to:** Part 0

## Learning Objectives
- State the full feature scope of the Task & Habit Tracker
- Identify every tool in the technology stack and its purpose
- Recognize the four-beat lesson structure used throughout the course

## Prerequisites
- Lab 0 complete

## Materials/Tools Required
- None beyond Lab 0's setup

## Pre-Lab Checklist
- [ ] I have read Part 0 in full

## Lab Procedure

**Step 1 — Sketch the architecture from memory.** Without looking at the tutorial, draw (on paper or in a text file) your best guess at the final folder structure of the app, based only on the feature list described in Part 0.

**Step 2 — Compare your sketch against the real architecture diagram** in Part 0. Note every folder you missed or mis-guessed.

**Step 3 — List the six core technologies** in the stack and write one sentence for each explaining why it was chosen over an alternative.

**Step 4 — Locate and read, out loud to yourself or a study partner,** the exact wording of the "🆕 New in React 19" callout description.

## Expected Result
You can explain, without notes, what app you're building, why it's built as one continuous project instead of isolated demos, and what the six flagged "New in React 19" features are (by name, not yet by implementation detail).

## In-Lab Exercises
1. Write a one-paragraph "elevator pitch" for the Task & Habit Tracker, as if describing it to a non-technical friend.
2. For each of the 9 Phases listed in the roadmap, write ONE guess about what specific feature might require it (you will check these guesses again at the end of the course).

## Post-Lab Questions (Lab Report)
1. Why does the series build one continuously-growing app rather than separate small demos?
2. Name all six "New in React 19" features flagged in Part 0.
3. What are the four beats every hands-on step in this course follows?
4. What is explicitly stated as NOT required before starting this course?

## Deliverables Checklist
- [ ] Your hand-drawn/typed architecture sketch, alongside the real diagram, with differences noted
- [ ] Your one-paragraph elevator pitch
- [ ] Your 9 per-Phase guesses (to be revisited in the Final Capstone Lab)
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
Not applicable — this lab involves no code.

---
```
[GENERATED: Lab Book Batch 1 — Front Matter + Lab 0 + Lab 0.5]
[STARTING: Lab Book Batch 2 — Labs 1.1, 1.2, 1.3 (Phase 1: Foundations)]
```

# LAB 1.1: Project Scaffolding with Vite

**Estimated Duration:** 45–60 minutes
**Corresponds to:** Phase 1, Part 1

## Learning Objectives
- Scaffold a new Vite + React 19 project from the command line
- Identify the purpose of every file Vite generates
- Explain the declarative vs. imperative distinction with a concrete code example

## Prerequisites
- Lab 0 and Lab 0.5 complete

## Materials/Tools Required
- A designated project directory on your machine

## Pre-Lab Checklist
- [ ] Node 18+, npm, VS Code, and Git are all confirmed working (Lab 0)
- [ ] I have read Phase 1, Part 1 of the tutorial

## Lab Procedure

**Step 1 — Scaffold the project:**
```bash
npm create vite@latest task-habit-tracker -- --template react
cd task-habit-tracker
npm install
```

**Step 2 — Run the dev server:**
```bash
npm run dev
```
Visit `localhost:5173` and confirm the default Vite + React demo loads.

**Step 3 — Inspect the generated file structure.** Open the project in VS Code (`code .`) and locate: `index.html`, `src/main.jsx`, `src/App.jsx`, `package.json`, `vite.config.js`.

**Step 4 — Verify React 19 specifically:**
```bash
npm list react
```

**Step 5 — Clear the demo slate.** Following the tutorial exactly, delete `App.css` and the demo assets, then replace `App.jsx` and `index.css` with the minimal versions shown in Phase 1, Part 1.

**Step 6 — Verify Hot Module Replacement.** With the dev server running, change the heading text in `App.jsx`, save, and observe the browser update without a manual refresh.

**Step 7 — Commit your work:**
```bash
git init
git add .
git commit -m "Lab 1.1: Vite project scaffolded and cleared"
```

## Expected Result
- `localhost:5173` shows only the plain "Task & Habit Tracker" heading and welcome text
- `npm list react` reports version 19.x.x
- Editing and saving `App.jsx` updates the browser within a fraction of a second, with no manual reload

## In-Lab Exercises
1. Deliberately stop `npm run dev` (Ctrl+C), then try loading `localhost:5173` again in your browser. Record what you observe.
2. Temporarily rename `src/App.jsx` to `src/App.jsx.bak` while the dev server is running. Record the exact error shown in the browser and terminal, then rename it back.
3. Run `npm run build` (a preview of Phase 9) just to observe that it works — do not worry about understanding the output yet. Record the names of the files created in the resulting `dist/` folder.

## Post-Lab Questions (Lab Report)
1. In your own words, explain why raw DOM manipulation becomes unwieldy at scale, using the "repaint the whole wall" framing or your own equivalent.
2. What is the one and only real HTML element your entire application will ever inject content into? Where is it defined?
3. What is the difference between `package.json` and `package-lock.json`?
4. Based on Exercise 2 above, what specific error message did removing `App.jsx` produce, and what does that tell you about how `main.jsx` depends on it?

## Deliverables Checklist
- [ ] Screenshot of `localhost:5173` showing the cleared-slate heading
- [ ] Screenshot/output of `npm list react` showing version 19
- [ ] Terminal output from Exercise 2 (the renamed-file error)
- [ ] Written answers to all 4 Post-Lab Questions
- [ ] A Git commit recorded for this lab

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| `npm create vite@latest` hangs or fails | Check internet connection; try again |
| Port 5173 already in use | Use the alternate port Vite suggests, or stop the conflicting process |
| Blank page, no visible error | Open DevTools Console (F12) and read the red error message |

---

# LAB 1.2: JSX & Your First Component Tree

**Estimated Duration:** 60–75 minutes
**Corresponds to:** Phase 1, Part 2

## Learning Objectives
- Apply all four JSX syntax rules correctly
- Build a multi-file component tree with proper capitalization and exports
- Distinguish an expression from a statement in the context of JSX

## Prerequisites
- Lab 1.1 complete, project running

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] `npm run dev` runs with no errors
- [ ] I have read Phase 1, Part 2 of the tutorial

## Lab Procedure

**Step 1 — Build the component tree**, one file at a time, exactly as specified in Phase 1, Part 2: `src/components/Navbar.jsx`, `HabitCard.jsx`, `TaskCard.jsx`, `HabitsSection.jsx`, `TasksSection.jsx`, `Dashboard.jsx`.

**Step 2 — Update `App.jsx`** to assemble the full tree.

**Step 3 — Verify in DevTools.** Open the Elements/Inspector tab and confirm the real DOM structure matches your planned component tree.

**Step 4 — Deliberately break each of the four JSX rules, one at a time,** observe the error or incorrect behavior, then fix it:
   - Remove a self-closing slash from an `<img />` tag
   - Return two sibling elements with no wrapping Fragment/div
   - Use `class` instead of `className`
   - Lowercase a component's function name and its usage tag

**Step 5 — Add styling** per the tutorial's CSS additions.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 1.2: Component tree built with JSX"
```

## Expected Result
- The browser shows a styled Navbar, HabitsSection (2 cards), and TasksSection (3 cards)
- Each of the four deliberately-broken rules produces the exact error/symptom described in the tutorial, and is successfully fixed

## In-Lab Exercises
1. Temporarily delete a `<HabitCard />` line from `HabitsSection.jsx`. Confirm exactly one card disappears, with no other side effects. Restore the line.
2. Build one additional small presentational component NOT explicitly covered in the tutorial (e.g., a `Footer`), following the one-component-per-file convention, and render it somewhere in the tree.
3. Convert one `<div>` wrapper somewhere in your tree into a Fragment (`<>...</>`) and confirm, via DevTools, that one fewer real DOM element now exists at that point.

## Post-Lab Questions (Lab Report)
1. What does the JSX `<div><h1>Hi</h1></div>` actually compile down to?
2. Draw your final component tree (App → ? → ? → ?) as built in this lab.
3. For each of the four deliberately-broken rules in Step 4, describe the EXACT symptom you observed (error text or visual result).
4. Why must component function names be capitalized — what specifically would break at the compiler level if they weren't?

## Deliverables Checklist
- [ ] Screenshot of the fully rendered, styled app
- [ ] Screenshot of the DevTools Elements tree matching your component tree
- [ ] Written descriptions of all four deliberate rule-breaking symptoms from Step 4
- [ ] Your additional custom component's file, committed
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Component name shows as literal text on screen | Capitalize both the function definition and its JSX usage |
| "Adjacent JSX elements must be wrapped" | Add a Fragment `<>` or wrapping `<div>` |
| Nothing renders, no error | Check for a missing `export default` |

---

# LAB 1.3: Props — Passing Data Into Components

**Estimated Duration:** 60–75 minutes
**Corresponds to:** Phase 1, Part 3

## Learning Objectives
- Pass and destructure props, including default values
- Explain and demonstrate why props must never be mutated
- Build a `children`-based reusable wrapper component

## Prerequisites
- Lab 1.2 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Component tree from Lab 1.2 renders correctly
- [ ] I have read Phase 1, Part 3 of the tutorial

## Lab Procedure

**Step 1 — Create `src/data/sampleData.js`** with `sampleHabits` and `sampleTasks` arrays, each item including a unique `id`.

**Step 2 — Rewrite `HabitCard`/`TaskCard`** to accept props with destructuring and default values.

**Step 3 — Wire prop drilling through the full chain**: `App.jsx` → `Dashboard.jsx` → `HabitsSection.jsx`/`TasksSection.jsx` → `HabitCard`/`TaskCard`, using manual array indexing (`habits[0]`, `habits[1]`) exactly as instructed — do NOT use `.map()` yet.

**Step 4 — Build `Badge.jsx`** using the `children` prop, and use it inside `HabitCard` for the streak indicator.

**Step 5 — Verify the full data flow** by editing `sampleData.js` values and confirming the UI updates with zero component file changes.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 1.3: Props and prop drilling implemented"
```

## Expected Result
- Distinct, correct data renders for each habit/task, entirely driven by `sampleData.js`
- Editing `sampleData.js` alone updates the UI, with no component edits required
- `Badge` correctly displays its `children` content with the appropriate `tone` styling

## In-Lab Exercises
1. Deliberately introduce a typo in a prop name on one side only (e.g., `label` in the parent, `lable` in the child's destructuring). Observe and record the resulting blank/undefined display.
2. Deliberately attempt to reassign a prop directly inside a component (e.g., `label = label.toUpperCase()`), and record what React does or doesn't do about it (note: this may not throw an error — document the actual observed behavior, including any console warnings).
3. Add a third `tone` option to `Badge` (e.g., `"danger"`) with its own CSS styling, and use it somewhere meaningful.

## Post-Lab Questions (Lab Report)
1. Explain the "sealed parcel from a courier" analogy for why props must be read-only.
2. Trace, by hand, every component `habits` data passes through from `App.jsx` to `HabitCard.jsx`. Which of these components actually USE the data directly, and which only forward it?
3. What did Exercise 1 reveal about how React handles a prop-name mismatch — does it throw an error, or fail silently?
4. Name two real solutions to prop drilling mentioned in the tutorial's Reference Section, and state which later Phase implements one of them.

## Deliverables Checklist
- [ ] Screenshot of correctly-rendered, distinct habit/task data
- [ ] Screenshot/description of the typo-induced blank display from Exercise 1
- [ ] Your added third `Badge` tone, with a screenshot
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Prop shows blank/undefined | Check spelling matches exactly on both parent and child |
| `Cannot read properties of undefined` | Check the array index actually exists (e.g., `habits[3]` on a 3-item array) |
| `children` is undefined in Badge | Confirm the component isn't self-closed (`<Badge />` instead of `<Badge>...</Badge>`) |

---
```
[GENERATED: Lab Book Batch 2 — Phase 1: Foundations Labs]
[STARTING: Lab Book Batch 3 — Labs 2.1, 2.2, 2.3 (Phase 2: Interactivity)]
```

# LAB 2.1: State with useState

**Estimated Duration:** 75–90 minutes
**Corresponds to:** Phase 2, Part 1

## Learning Objectives
- Explain why a plain variable cannot serve as component memory
- Implement interactive toggling using `useState`
- Correctly decide when state must be lifted to a shared parent
- Apply the immutable update pattern (spread + `.map()`) correctly

## Prerequisites
- Lab 1.3 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Props-driven `HabitCard`/`TaskCard` from Lab 1.3 render correctly
- [ ] I have read Phase 2, Part 1 of the tutorial

## Lab Procedure

**Step 1 — Reproduce the broken "plain variable" demo.** Temporarily write a `HabitCard` version using `let isComplete = false` with a click handler that flips it. Click it and observe the console log changes while the screen does not.

**Step 2 — Implement self-toggling state** in `HabitCard` using `useState`, verify each card toggles independently.

**Step 3 — Lift state up.** Move `isComplete` state to `App.jsx`; make `HabitCard` fully props-driven again, receiving `onToggle` as a prop.

**Step 4 — Implement the immutable update pattern** for `handleToggleHabit`/`handleToggleTask` using spread + `.map()`.

**Step 5 — Add the "N remaining" count** to `HabitsSection`, confirming it only works now that state is lifted.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 2.1: useState and lifted state implemented"
```

## Expected Result
- Each habit/task card toggles its checkbox and strikethrough state independently, with no page reload
- The "N remaining" count updates correctly and instantly whenever any habit is toggled
- The plain-variable demo from Step 1 visibly fails to update the screen, despite the console showing correct values

## In-Lab Exercises
1. Deliberately mutate state directly (`habit.isComplete = !habit.isComplete; setHabits(habits)`) instead of using the immutable pattern. Click a checkbox and record what happens on screen vs. in `console.log(habits)`.
2. Deliberately call a setter function directly during render (e.g., `onClick={setIsComplete(true)}` instead of a function reference) and record the exact error message that results.
3. Attempt to call a hook conditionally (e.g., wrap a `useState` call in an `if` block). Record what ESLint or the browser reports.

## Post-Lab Questions (Lab Report)
1. Why does `let isComplete = false` fail to act as memory across renders? Be specific about WHEN and WHY it resets.
2. What two things does calling a state setter function actually do?
3. Based on Exercise 1, explain precisely why React failed to detect the mutation-based change, referencing reference equality.
4. What specific new feature (the "N remaining" count) required lifting state up, and why couldn't per-card private state provide it?

## Deliverables Checklist
- [ ] Screenshot/description of the broken plain-variable demo from Step 1
- [ ] Screenshot of correctly toggling, independent habit/task cards with working remaining count
- [ ] Terminal/console output from all three In-Lab Exercises
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| "Too many re-renders" | Change `onClick={setX(true)}` to `onClick={() => setX(true)}` |
| Checkbox doesn't visually update despite correct console values | Check for direct mutation instead of spread/`.map()` |
| Clicking one card toggles a different one | Confirm the `.map()` comparison uses `habit.id`, not array index |

---

# LAB 2.2: Rendering Lists with .map()

**Estimated Duration:** 60–75 minutes
**Corresponds to:** Phase 2, Part 2

## Learning Objectives
- Replace manual array indexing with `.map()`
- Correctly explain and demonstrate the purpose of the `key` prop
- Choose an appropriate key strategy for a given list scenario

## Prerequisites
- Lab 2.1 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Lifted-state toggling from Lab 2.1 works correctly
- [ ] I have read Phase 2, Part 2 of the tutorial

## Lab Procedure

**Step 1 — Add 1–2 additional habits/tasks** to `sampleData.js` to make manual indexing visibly break (crash on missing index) or fail to display (new items don't show).

**Step 2 — Convert `HabitsSection`/`TasksSection`** to use `.map()` instead of manual indexing.

**Step 3 — Verify scaling.** Add another new habit directly to the data file and confirm it appears automatically with zero component changes.

**Step 4 — Build and run the Key Experiment** exactly as specified in the tutorial: two lists, one keyed by index, one by `person.id`. Type into each, then shuffle, and record what happens to the typed text in each list.

**Step 5 — Clean up.** Delete the Key Experiment scratch file and restore `main.jsx` to point at the real `App`.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 2.2: .map() rendering and key experiment complete"
```

## Expected Result
- All lists render dynamically via `.map()`, scaling correctly with any number of items
- The index-keyed experiment list shows typed text sticking to the wrong person after shuffling; the id-keyed list correctly follows the right person

## In-Lab Exercises
1. Deliberately set `key={Math.random()}` on a list item and describe, in writing, what console warnings or behavior anomalies (if any) you observe, and why this is considered worse than no key at all.
2. Deliberately place `key` on a nested child element instead of the outermost element returned by `.map()`. Record what React reports.
3. Write a short function using `.find()` to look up a single habit by `id` from the `habits` array, and log the result to the console.

## Post-Lab Questions (Lab Report)
1. What two problems does manual array indexing have that `.map()` solves?
2. Describe, step by step, exactly what you observed in the Key Experiment for BOTH the index-keyed and id-keyed lists.
3. Why does React never display the `key` prop's value visibly on screen?
4. Name three array methods (besides `.map()`/`.filter()`) and what each returns, demonstrated via Exercise 3 or otherwise.

## Deliverables Checklist
- [ ] Screenshot of the scaled-up habit/task lists rendered via `.map()`
- [ ] Screenshots/recording of both Key Experiment outcomes (index-keyed vs id-keyed)
- [ ] Console output from Exercise 3's `.find()` demonstration
- [ ] Written answers to all 4 Post-Lab Questions
- [ ] Confirmation that Key Experiment files were removed and `main.jsx` restored

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| "Each child in a list should have a unique key" warning | Add `key={item.id}` to the outermost mapped element |
| Typed text jumps to the wrong item after list changes | Switch from array index to a stable, unique `id` as key |
| `.map is not a function` | Confirm the data has actually loaded and is genuinely an array |

---

# LAB 2.3: Event Handling & Conditional Rendering

**Estimated Duration:** 60–75 minutes
**Corresponds to:** Phase 2, Part 3

## Learning Objectives
- Correctly use `event.stopPropagation()` to isolate nested click behavior
- Select the appropriate conditional rendering pattern (ternary / `&&` / early return) for a given scenario
- Build a reusable, generically-designed filter control with correctly-scoped local state

## Prerequisites
- Lab 2.2 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] `.map()`-based rendering from Lab 2.2 works correctly
- [ ] I have read Phase 2, Part 3 of the tutorial

## Lab Procedure

**Step 1 — Add the streak Badge click handler** with `stopPropagation()` to `HabitCard`.

**Step 2 — Deliberately remove `stopPropagation()`**, click the badge, and record both the alert AND the unintended card toggle. Restore the fix.

**Step 3 — Add the "On fire!" conditional indicator** using `&&`, and the "All done!" celebration message using a ternary.

**Step 4 — Build `FilterTabs.jsx`** as a generic, reusable component, and wire it into `TasksSection` with correctly-scoped LOCAL state.

**Step 5 — Verify the empty state** by filtering to a category with zero matching items.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 2.3: Event bubbling and conditional rendering complete"
```

## Expected Result
- Clicking the streak badge shows an alert WITHOUT toggling the card; clicking elsewhere on the card still toggles it correctly
- The "On fire!" indicator appears only for habits with streak > 7; the "All done!" message appears only when all habits are complete
- Filter tabs correctly narrow the task list and show a friendly empty-state message when no tasks match

## In-Lab Exercises
1. Reproduce the `count && <Something />` trap deliberately: create a temporary badge showing `{someCount && <span>{someCount} items</span>}` where `someCount` can be `0`. Record the literal "0" rendering on screen, then fix it with `someCount > 0 && ...`.
2. Remove `type="button"` from a non-submit button inside a temporary test `<form>` and observe what happens on click (this may require building a minimal scratch form, since Phase 2 doesn't yet have real forms — note this is a preview of a Phase 3 concern).
3. Write, on paper or in comments, which conditional rendering pattern (ternary / && / early return) you'd use for three NEW scenarios of your own invention.

## Post-Lab Questions (Lab Report)
1. Explain, step by step, what would happen when clicking the streak badge if `stopPropagation()` were never added — trace the event's bubbling path.
2. What is the well-known "trap" with `count && <Something />`? Show your own reproduction from Exercise 1.
3. When should you reach for an early `return` rather than a ternary or `&&`?
4. Why does `FilterTabs`' active filter state live locally in `TasksSection`, rather than being lifted to `App` like habit/task data was in Lab 2.1?

## Deliverables Checklist
- [ ] Before/after screenshots of the stopPropagation fix (badge alone vs. badge + unintended toggle)
- [ ] Screenshot/description of the reproduced "renders 0" trap and its fix
- [ ] Screenshot of the working filter tabs, including the empty state
- [ ] Your three invented conditional-rendering scenarios with chosen patterns
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Clicking a nested element also triggers the parent's handler | Add `event.stopPropagation()` in the nested element's handler |
| The number 0 appears unexpectedly on screen | Use `count > 0 && ...` instead of `count && ...` |
| Filter buttons submit/reload a form unexpectedly | Add `type="button"` explicitly |

---
```
[GENERATED: Lab Book Batch 3 — Phase 2: Interactivity Labs]
[STARTING: Lab Book Batch 4 — Labs 3.1, 3.2, 3.3 (Phase 3: Forms & Data)]
```

# LAB 3.1: Controlled Forms

**Estimated Duration:** 75–90 minutes
**Corresponds to:** Phase 3, Part 1

## Learning Objectives
- Build a controlled form input backed by React state
- Implement validation with conditional button disabling
- Generate safe, unique IDs and immutably add items to a list

## Prerequisites
- Lab 2.3 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Filter tabs and event handling from Lab 2.3 work correctly
- [ ] I have read Phase 3, Part 1 of the tutorial

## Lab Procedure

**Step 1 — Build `TaskForm.jsx`** as a controlled input, with `useState` for the value, `onChange` writing back to it, and `.trim()`-based validation.

**Step 2 — Build `HabitForm.jsx`** following the identical pattern.

**Step 3 — Wire "add" handlers** through `App.jsx` down to `HabitsSection`/`TasksSection`, using `crypto.randomUUID()` for new item IDs and immutable array spreading.

**Step 4 — Add toggle-visibility state** (`isAdding`) to show/hide each form via a "+ New Task"/"+ New Habit" button.

**Step 5 — Verify validation** by attempting to submit empty and whitespace-only input.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 3.1: Controlled forms implemented"
```

## Expected Result
- Both forms reject empty/whitespace-only submissions (button stays disabled)
- Valid submissions add a new item to the correct list and clear the input
- Pressing Enter (not just clicking Add) submits the form correctly

## In-Lab Exercises
1. Run `crypto.randomUUID()` five times in your browser's console and record the five different outputs, confirming genuine randomness.
2. Deliberately implement ID generation as `tasks.length + 1` instead of `crypto.randomUUID()`. Add three tasks, delete the middle one, add a new one, and check for duplicate IDs (may require temporarily disabling the `key` warning suppression to observe, or manually inspecting the array in console). Record your findings, then revert to `crypto.randomUUID()`.
3. Deliberately invert the `disabled` logic (`disabled={isValid}` instead of `disabled={!isValid}`) and record the resulting (backwards) button behavior.

## Post-Lab Questions (Lab Report)
1. Explain the "puppet, with React holding the strings" analogy for controlled inputs, in your own words.
2. Based on Exercise 2, describe specifically what went wrong with the `tasks.length + 1` ID strategy, and why `crypto.randomUUID()` avoids this problem.
3. Why is `event.preventDefault()` necessary in the submit handler? What would the page do without it?
4. List three separate pieces of state/logic your `TaskForm` needed just to handle one text field (value state, onChange, validation calculation, preventDefault, manual clearing) — count them explicitly.

## Deliverables Checklist
- [ ] Console output from Exercise 1 (five different UUIDs)
- [ ] Written findings from Exercise 2's duplicate-ID reproduction
- [ ] Screenshot of the backwards-disabled-logic bug from Exercise 3
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Add button never becomes enabled | Check `disabled={!isValid}`, not `disabled={isValid}` |
| Page reloads/flashes on submit | Add `event.preventDefault()` as the first line of the handler |
| New items overwrite existing ones | Check ID generation strategy — switch to `crypto.randomUUID()` |

---

# LAB 3.2: 🆕 Actions & useActionState

**Estimated Duration:** 75–90 minutes
**Corresponds to:** Phase 3, Part 2

## Learning Objectives
- Rebuild a form using React 19 Actions and `useActionState`
- Read field values via `FormData` instead of controlled state
- Explain and demonstrate the automatic pending-state tracking Actions provide

## Prerequisites
- Lab 3.1 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Controlled forms from Lab 3.1 work correctly
- [ ] I have read Phase 3, Part 2 of the tutorial

## Lab Procedure

**Step 1 — Rewrite `TaskForm`/`HabitForm`** to use `useActionState` and an Action function, removing the `useState`-based controlled input entirely.

**Step 2 — Add the duplicate-name check** and artificial network delay inside the Action function.

**Step 3 — Verify the pending state** by watching the button text change to "Adding…" during the artificial delay.

**Step 4 — Verify the duplicate check** by submitting an existing task/habit label (case-insensitively).

**Step 5 — Commit:**
```bash
git add .
git commit -m "Lab 3.2: Actions and useActionState implemented"
```

## Expected Result
- Submitting empty input shows a validation error after a brief pending state
- Submitting a duplicate label (case-insensitive) shows a distinct error, with the typed text still present
- Submitting a new, valid label successfully adds the item after a visible pending delay

## In-Lab Exercises
1. Temporarily remove the `async` keyword from your Action function (while leaving an `await` inside it, if present, to observe the resulting syntax error) OR, if no `await` is used, observe that `isPending` never becomes `true`. Record your findings, then restore `async`.
2. Add a `console.log(formData.get('label'), typeof formData.get('label'))` inside your Action function, submit the form, and confirm the logged type is always `"string"`, never `"number"`, even if you type only digits.
3. Deliberately import `useActionState` from `'react-dom'` instead of `'react'` and record the exact resulting error.

## Post-Lab Questions (Lab Report)
1. List three specific things React automatically does when you pass a function to a form's `action` prop.
2. Why does the input in your Action-based form no longer have a `value` or `onChange` prop? What trade-off does this involve?
3. Based on Exercise 2, confirm and explain: what type does `formData.get()` always return, regardless of what the field "looks like"?
4. What is `useActionState`'s correct import source, and what happened in Exercise 3 when you used the wrong one?

## Deliverables Checklist
- [ ] Screenshot/recording of the visible "Adding…" pending state
- [ ] Screenshot of the duplicate-name error with typed text still present
- [ ] Console output from Exercise 2 confirming `formData.get()` always returns a string
- [ ] Exact error message from Exercise 3
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| `formData.get('label')` returns null | Confirm the `<input>` has a matching `name` attribute |
| isPending never becomes true | Confirm the Action function is marked `async` |
| Import error for `useActionState` | Import from `'react'`, not `'react-dom'` |

---

# LAB 3.3: 🆕 useFormStatus

**Estimated Duration:** 60–75 minutes
**Corresponds to:** Phase 3, Part 3

## Learning Objectives
- Extract reusable form components that independently read pending status
- Demonstrate, via a deliberate experiment, the descendant-only rule for `useFormStatus`
- Explain the distinction between `useActionState`'s pending value and `useFormStatus`'s `pending`

## Prerequisites
- Lab 3.2 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Action-based forms from Lab 3.2 work correctly
- [ ] I have read Phase 3, Part 3 of the tutorial

## Lab Procedure

**Step 1 — Extract `FormTextInput.jsx`, `SubmitButton.jsx`, `CancelButton.jsx`**, each independently calling `useFormStatus`.

**Step 2 — Rewire `TaskForm`/`HabitForm`** to use these three extracted components, removing all direct `isPending` usage from the form components themselves.

**Step 3 — Run the deliberate-failure experiment**: temporarily call `useFormStatus` directly inside `TaskForm` (the form-rendering component itself, not a nested child), log the result, and confirm it always reports `false` even during genuine submission. Revert afterward.

**Step 4 — Commit:**
```bash
git add .
git commit -m "Lab 3.3: useFormStatus extraction complete"
```

## Expected Result
- All three extracted components correctly and independently reflect pending state with zero props passed for that purpose
- The deliberate-failure experiment logs `false` consistently, confirming the descendant-only rule

## In-Lab Exercises
1. Confirm, by reading the file, that `TaskForm.jsx` no longer contains the word "pending" or "isPending" anywhere.
2. Deliberately import `useFormStatus` from `'react'` instead of `'react-dom'` and record the exact resulting error.
3. Build one additional `useFormStatus`-aware component of your own design (e.g., a live character counter using the `data` property) and integrate it into one of your forms.

## Post-Lab Questions (Lab Report)
1. Why did calling `useFormStatus` in the SAME component that renders the `<form>` always report `false`, even during genuine submission?
2. List the three components extracted in this lab, and state what each independently reads via `useFormStatus`.
3. Compare `useActionState`'s pending value vs. `useFormStatus`'s `pending` — when would you reach for each?
4. Describe your Exercise 3 component and what specific problem it solves.

## Deliverables Checklist
- [ ] Confirmation (via Exercise 1) that no pending-tracking code remains in the form components themselves
- [ ] Console/screenshot output from the deliberate-failure experiment
- [ ] Exact error message from Exercise 2
- [ ] Your Exercise 3 custom component's code and a working screenshot
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| `pending` always false | Confirm `useFormStatus` is called in a genuine DESCENDANT of the form, not the form-rendering component itself |
| Import error for `useFormStatus` | Import from `'react-dom'`, not `'react'` |

---
```
[GENERATED: Lab Book Batch 4 — Phase 3: Forms & Data Labs]
[STARTING: Lab Book Batch 5 — Labs 4.1, 4.2, 4.3 (Phase 4: Data Fetching)]
```

# LAB 4.1: useEffect & Fetching Real Data

**Estimated Duration:** 90–105 minutes
**Corresponds to:** Phase 4, Part 1

## Learning Objectives
- Explain what a side effect is and why it requires `useEffect`
- Stand up and fetch from a real local backend (`json-server`)
- Write a correct effect cleanup function and demonstrate what breaks without one
- Configure and use environment variables correctly in Vite

## Prerequisites
- Lab 3.3 complete

## Materials/Tools Required
- A second terminal window/tab (required from this lab forward)

## Pre-Lab Checklist
- [ ] All forms from Phase 3 work correctly
- [ ] I have read Phase 4, Part 1 of the tutorial
- [ ] I have a second terminal available and know how to open one

## Lab Procedure

**Step 1 — Run the Cleanup Experiment.** Build the `Ticker` component exactly as specified, mount/unmount it repeatedly WITH a cleanup function (count ticks stopping cleanly), then WITHOUT one (count ticks accelerating). Clean up the experiment files afterward.

**Step 2 — Install and configure `json-server`:**
```bash
npm install -D json-server@0.17.4
```
Create `db.json` with `habits`, `tasks` arrays.

**Step 3 — Add the `server` script** to `package.json` and run it in your SECOND terminal:
```bash
npm run server
```
Verify with `curl http://localhost:4000/habits` or a browser visit.

**Step 4 — Configure environment variables** (`.env.development` with `VITE_API_URL=http://localhost:4000`), restart `npm run dev` to pick up the change.

**Step 5 — Build the `api/` layer** (`fetchHabits`, `fetchTasks`) with manual `response.ok` checking.

**Step 6 — Wire `useEffect` into `App.jsx`** with `Promise.all`, `isCancelled` guard, and cleanup function.

**Step 7 — Delete `sampleData.js`** now that real data fetching is in place.

**Step 8 — Commit:**
```bash
git add .
git commit -m "Lab 4.1: useEffect and real data fetching implemented"
```

## Expected Result
- Both terminals (`npm run dev` and `npm run server`) run simultaneously without conflict
- The app loads real habit/task data from `json-server`, confirmed via the Network tab
- Stopping `json-server` and reloading logs an error to console (full error UI arrives in Lab 4.2)

## In-Lab Exercises
1. Open DevTools → Network tab, filter to Fetch/XHR, reload the page, and screenshot the two real GET requests with their 200 status codes.
2. Stop `npm run server`, reload the app, and record the exact console error message produced.
3. Deliberately remove the `[]` dependency array from your data-fetching `useEffect` entirely, observe the resulting infinite loop of requests in the Network tab, then restore the correct dependency array.

## Post-Lab Questions (Lab Report)
1. Explain the "chef plating a dish, then phoning in tomorrow's order" analogy for pure rendering vs. side effects.
2. What specifically went wrong in your Cleanup Experiment when the cleanup function was removed? Describe the console output pattern you observed.
3. Why must `response.ok` be checked manually rather than relying on `fetch()` to throw automatically?
4. What real race condition does the `isCancelled` flag guard against?

## Deliverables Checklist
- [ ] Screenshot of both terminals running simultaneously
- [ ] Network tab screenshot showing successful GET requests to `/habits` and `/tasks`
- [ ] Console error output from Exercise 2 (server stopped)
- [ ] Description/screenshot of the infinite-loop reproduction from Exercise 3
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| `Failed to fetch` forever | Confirm `npm run server` is actually running in a separate terminal |
| `import.meta.env.VITE_API_URL` is undefined | Confirm exact filename `.env.development` and restart `npm run dev` |
| Infinite request loop | Confirm the `useEffect` has a `[]` dependency array |

---

# LAB 4.2: Loading/Error States & use + Suspense

**Estimated Duration:** 90–105 minutes
**Corresponds to:** Phase 4, Part 2

## Learning Objectives
- Build genuine loading, success, and error states for a data fetch
- Implement and explain the one class-component Error Boundary in this course
- Use `use()` paired with `Suspense` to read a cached Promise during render

## Prerequisites
- Lab 4.1 complete, both terminals running

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Real data fetching from Lab 4.1 works correctly
- [ ] I have read Phase 4, Part 2 of the tutorial

## Lab Procedure

**Step 1 — Add `loadError` state and a retry button** to `App.jsx`, driven by a `retryCount` dependency in the fetch effect.

**Step 2 — Build `ErrorBoundary.jsx`** as a class component, using `getDerivedStateFromError` and `componentDidCatch`.

**Step 3 — Add the `quote` resource** to `db.json` and restart `json-server`.

**Step 4 — Build `quoteApi.js`** with the artificial 40% failure rate, and `quoteCache.js` for Promise caching.

**Step 5 — Build `QuoteOfTheDay.jsx`** using `use()`, and wire it into `Dashboard`/`App` wrapped in both `<ErrorBoundary>` and `<Suspense>`.

**Step 6 — Verify both outcomes** by refreshing the page multiple times (4–5 refreshes should show both success and failure, given the 40% rate).

**Step 7 — Commit:**
```bash
git add .
git commit -m "Lab 4.2: Error boundaries and use+Suspense implemented"
```

## Expected Result
- Stopping `json-server` now shows a genuine, styled error screen with a working "Try Again" button
- The Quote widget shows a loading fallback, then either the real quote or a graceful error card, roughly 60/40 across repeated refreshes

## In-Lab Exercises
1. Refresh the page 6 times in a row and record how many times you observed success vs. failure for the Quote widget, confirming both are genuinely reachable.
2. Deliberately create the quote Promise INLINE inside the `QuoteOfTheDay` component body (rather than using the cached `quoteCache.js` version) and observe the resulting infinite-request behavior in the Network tab. Revert to the cached version.
3. Deliberately remove the `<ErrorBoundary>` wrapper (keep `<Suspense>`) and refresh until you hit the artificial failure. Record what happens to the rest of the app.

## Post-Lab Questions (Lab Report)
1. Why must Error Boundaries currently be implemented as class components? Name the two lifecycle methods involved.
2. Draw the nesting relationship between `ErrorBoundary` and `Suspense`, and explain which one catches a pending Promise vs. a rejected one.
3. Based on Exercise 2, explain precisely why creating the Promise inline caused a request loop.
4. Based on Exercise 3, what happened to the rest of the app when an uncaught error occurred with no Error Boundary present?

## Deliverables Checklist
- [ ] Screenshot of the genuine error screen (server stopped) with working retry
- [ ] Tally/screenshots from Exercise 1's 6 refreshes showing both outcomes
- [ ] Network tab screenshot from Exercise 2's infinite-loop reproduction
- [ ] Screenshot/description of Exercise 3's uncaught-error consequence
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Suspense fallback never disappears | Confirm the underlying Promise genuinely settles |
| Infinite request loop for the quote | Confirm the Promise is cached (module-level), not created inline during render |
| App crashes with a blank screen | Confirm an `ErrorBoundary` wraps the relevant Suspense-guarded section |

---

# LAB 4.3: 🆕 useOptimistic

**Estimated Duration:** 90–105 minutes
**Corresponds to:** Phase 4, Part 3

## Learning Objectives
- Implement optimistic UI updates using `useOptimistic`
- Correctly pair `useOptimistic` with `startTransition`
- Build real `PATCH`/`POST` persistence with graceful failure handling

## Prerequisites
- Lab 4.2 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Error boundaries and Quote widget from Lab 4.2 work correctly
- [ ] I have read Phase 4, Part 3 of the tutorial

## Lab Procedure

**Step 1 — Add `updateHabit`/`createHabit`/`updateTask`/`createTask`** to the `api/` layer with real `PATCH`/`POST` requests, artificial delay, and 30% artificial failure rate.

**Step 2 — Wire `useOptimistic`** into `App.jsx` for both habits and tasks.

**Step 3 — Wrap toggle handlers in `startTransition`**, applying the optimistic update before the real API call, and dispatching the real reducer update only on success.

**Step 4 — Add `Toast.jsx`** for failure notifications, and `savingHabitIds`/`savingTaskIds` for the visual "saving" dimming effect.

**Step 5 — Verify persistence** by toggling a habit, waiting for success, then refreshing the page to confirm the change survived.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 4.3: useOptimistic implemented"
```

## Expected Result
- Toggling a checkbox flips it instantly, dims briefly, and either persists (confirmed by refresh) or reverts with a toast, roughly 70/30 across repeated attempts
- Rapidly clicking the same card while a save is in-flight has no effect (blocked by `.is-saving`'s `pointer-events: none`)

## In-Lab Exercises
1. Toggle the same habit 10 times in a row (waiting for each to settle), and tally how many succeeded vs. failed, confirming the roughly 30% failure rate.
2. Deliberately call `applyOptimisticHabit(...)` directly inside an `onClick` handler with NO `startTransition` wrapper. Record the exact console warning, then restore the correct wrapping.
3. Deliberately update the REAL state (not just showing a toast) inside the `catch` block, using the optimistic (failed) value. Observe that the optimistic-revert mechanism is now defeated. Restore the correct code.

## Post-Lab Questions (Lab Report)
1. Explain the "liking a social media post" analogy for optimistic UI.
2. Based on Exercise 1, report your actual observed success/failure tally and compare it to the expected ~70/30 split.
3. What is the exact console warning from Exercise 2, and what two fixes does it suggest?
4. Based on Exercise 3, explain precisely why touching real state in the catch block defeats the automatic-revert mechanism.

## Deliverables Checklist
- [ ] Tally/screenshots from Exercise 1's 10-toggle test
- [ ] Exact console warning text from Exercise 2
- [ ] Before/after description of Exercise 3's defeated-revert bug
- [ ] Screenshot confirming a successful toggle survived a page refresh
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| "Optimistic state update occurred outside a transition" warning | Wrap the call in `startTransition(async () => { ... })` |
| Optimistic value never reverts after failure | Confirm real state setter is NOT called in the catch block |
| Duplicate saves fire from rapid clicking | Confirm `.is-saving` with `pointer-events: none` is correctly applied |

---
```
[GENERATED: Lab Book Batch 5 — Phase 4: Data Fetching Labs]
[STARTING: Lab Book Batch 6 — Labs 5.1, 5.2 (Phase 5: App-Wide State)]
```

# LAB 5.1: The Context API

**Estimated Duration:** 75–90 minutes
**Corresponds to:** Phase 5, Part 1

## Learning Objectives
- Build the three-file Context pattern from scratch
- Implement a working, persisted dark mode feature reachable from any component depth
- Demonstrate and explain Context's broad re-render behavior

## Prerequisites
- Lab 4.3 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Optimistic updates from Lab 4.3 work correctly
- [ ] I have read Phase 5, Part 1 of the tutorial

## Lab Procedure

**Step 1 — Build the three-file Context pattern**: `ThemeContext.js`, `ThemeProvider.jsx`, `useTheme.js`.

**Step 2 — Wrap `<App />`** in `<ThemeProvider>` inside `main.jsx`.

**Step 3 — Add CSS custom properties** (`:root` / `[data-theme='dark']`) and update existing styles to reference them via `var(--color-*)`.

**Step 4 — Add the theme toggle button** to `Navbar.jsx`, calling `useTheme()`.

**Step 5 — Verify persistence** across a page refresh, and correct application of `data-theme` on `<html>` via DevTools.

**Step 6 — Run the Re-render Experiment**: temporarily add a `console.log` inside `HabitCard` (which doesn't use `useTheme`), toggle the theme, and confirm it logs anyway. Remove the log afterward.

**Step 7 — Commit:**
```bash
git add .
git commit -m "Lab 5.1: Context API and dark mode implemented"
```

## Expected Result
- Clicking the theme toggle instantly repaints the entire app; the choice persists across a refresh
- `HabitCard` (a non-theme-consuming component) is confirmed, via the logging experiment, to re-render anyway when the theme changes

## In-Lab Exercises
1. Deliberately wrap only `<Dashboard />` (not `<Navbar />`) in `<ThemeProvider>` in `main.jsx`. Click the theme toggle and record the exact error message. Restore the correct wrapping.
2. Inspect `localStorage` via DevTools → Application/Storage and confirm the exact key and value used to persist the theme choice.
3. Build a second, independent Context from scratch (e.g., a simple `LanguageContext` for an English/Spanish label toggle), following the three-file pattern without referencing `ThemeContext`'s code while writing it.

## Post-Lab Questions (Lab Report)
1. Explain the "public bulletin board" analogy for Context, contrasted against the "private note" analogy for props.
2. Based on Exercise 1, what exact error message appeared, and why?
3. What did the Re-render Experiment demonstrate about Context's performance characteristics? Is this a flaw, or an expected trade-off?
4. Describe your Exercise 3 second Context implementation — what value does it share, and how does its structure compare to `ThemeContext`'s?

## Deliverables Checklist
- [ ] Screenshot of working, persisted dark mode
- [ ] Exact error message from Exercise 1
- [ ] Screenshot of the localStorage key/value from Exercise 2
- [ ] Your Exercise 3 second Context's three files, committed
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| "useTheme must be called from within a Provider" error | Confirm `<ThemeProvider>` wraps the ENTIRE app in `main.jsx` |
| Theme resets on refresh | Confirm `localStorage` read/write logic is correctly implemented |
| Some UI doesn't change with the theme | Confirm hardcoded hex colors were replaced with `var(--color-*)` |

---

# LAB 5.2: useReducer for Complex State Logic

**Estimated Duration:** 75–90 minutes
**Corresponds to:** Phase 5, Part 2

## Learning Objectives
- Consolidate multiple related `useState` calls into a single `useReducer`
- Write a pure reducer function covering every valid state transition
- Demonstrate the practical debugging payoff of centralized state transitions

## Prerequisites
- Lab 5.1 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Dark mode from Lab 5.1 works correctly
- [ ] I have read Phase 5, Part 2 of the tutorial

## Lab Procedure

**Step 1 — Count your current `App.jsx` state**: list every `useState` call and every handler function that touches more than one of them.

**Step 2 — Build `dataReducer.js`**, consolidating `habits`, `tasks`, `isLoading`, `loadError` into one reducer with actions: `FETCH_START`, `FETCH_SUCCESS`, `FETCH_ERROR`, `TOGGLE_HABIT`, `TOGGLE_TASK`, `ADD_HABIT`, `ADD_TASK`.

**Step 3 — Refactor `App.jsx`** to use `useReducer(dataReducer, initialDataState)`, replacing individual setters with `dispatch(...)` calls.

**Step 4 — Re-run the FULL functional checklist from Phase 4** (fetch on load, error/retry, optimistic toggle, quote widget, forms) to confirm ZERO behavior changed.

**Step 5 — Add the temporary action-logging wrapper**, interact with the app for a few minutes, and review the complete logged history of state transitions. Remove the logging wrapper afterward.

**Step 6 — Commit:**
```bash
git add .
git commit -m "Lab 5.2: useReducer refactor complete"
```

## Expected Result
- The app behaves IDENTICALLY to its pre-refactor state across every Phase 4 verification check
- The temporary action log shows a complete, readable, chronological history of every dispatched action and resulting state

## In-Lab Exercises
1. Deliberately omit `...state` from one `case` block (e.g., `ADD_TASK`), dispatch that action, and record exactly which other pieces of state disappeared as a result. Restore the correct spread.
2. Deliberately dispatch a typo'd action type (e.g., `'TOGLE_HABIT'`) and record the exact thrown error message.
3. Add ONE new action type to `dataReducer` not covered in the tutorial (e.g., `'DELETE_TASK'`), implement full delete functionality for tasks using it, and verify it works correctly.

## Post-Lab Questions (Lab Report)
1. List, from your Step 1 count, exactly how many separate `useState` calls and handler functions existed before this refactor.
2. Based on Exercise 1, describe precisely what happened to your app's state when `...state` was omitted from one case.
3. Why must a reducer function be pure — no fetch calls, no `setTimeout`? Give a concrete reason, not just "the rules say so."
4. Describe your Exercise 3 new action type and confirm it correctly follows the immutable update pattern.

## Deliverables Checklist
- [ ] Your Step 1 count (list of pre-refactor useState calls/handlers)
- [ ] Screenshot/description of Exercise 1's missing-spread bug
- [ ] Exact error message from Exercise 2
- [ ] Your Exercise 3 new action's code and a working demonstration
- [ ] Complete action log output from Step 5
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Other state fields disappear after a dispatch | Add `...state` at the start of the returned object in that case |
| "Unknown action type" error | Check exact spelling of the dispatched `action.type` string |
| App behavior changed after the refactor | This should NEVER happen — re-check every case against the original handler logic |

---
```
[GENERATED: Lab Book Batch 6 — Phase 5: App-Wide State Labs]
[STARTING: Lab Book Batch 7 — Labs 6.1, 6.2 (Phase 6: Navigation)]
```

# LAB 6.1: React Router — Multi-Page Navigation

**Estimated Duration:** 90–105 minutes
**Corresponds to:** Phase 6, Part 1

## Learning Objectives
- Configure client-side routing with `BrowserRouter`, `Routes`, and `Route`
- Build multiple pages with correct `Link`/`NavLink` navigation
- Correctly configure a catch-all 404 route and exact-matching root navigation

## Prerequisites
- Lab 5.2 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] `useReducer` refactor from Lab 5.2 works correctly
- [ ] I have read Phase 6, Part 1 of the tutorial

## Lab Procedure

**Step 1 — Install React Router:**
```bash
npm install react-router-dom@6.28.1
```

**Step 2 — Wrap `<App />`** in `<BrowserRouter>` inside `main.jsx`.

**Step 3 — Build the page components**: `DashboardPage`, `TasksPage`, `HabitsPage`, `SettingsPage`, `NotFoundPage`.

**Step 4 — Delete `Dashboard.jsx`** and redistribute its responsibilities into the new page components.

**Step 5 — Configure `<Routes>`** in `App.jsx`, with the wildcard route listed LAST.

**Step 6 — Build `Navbar`'s nav links** using `NavLink` with the correctly-applied `end` prop on the root route.

**Step 7 — Verify full navigation**, including browser Back/Forward, and the Network tab showing no full-document reloads.

**Step 8 — Commit:**
```bash
git add .
git commit -m "Lab 6.1: React Router navigation implemented"
```

## Expected Result
- All four pages navigate correctly with active-link highlighting and zero full-page reloads
- Visiting an undefined URL shows the 404 page with a working "back to Dashboard" link
- Browser Back/Forward buttons correctly step through navigation history

## In-Lab Exercises
1. Deliberately move the wildcard `<Route path="*">` to be FIRST in your `<Routes>` list. Navigate to `/tasks` and record what you see. Restore the correct (last) position.
2. Deliberately remove the `end` prop from the Dashboard's `NavLink`. Navigate to `/tasks` and record whether the Dashboard link incorrectly appears "active." Restore `end`.
3. Open DevTools → Network tab, clear it, and click through all four pages. Confirm and screenshot that no full HTML document requests appear — only the initial page load.

## Post-Lab Questions (Lab Report)
1. Explain the "receptionist swapping the display, not rebuilding the hotel" analogy for client-side routing.
2. Based on Exercise 1, what exactly happened when the wildcard route was placed first? Why does route order matter here?
3. Based on Exercise 2, describe the exact (incorrect) behavior observed without the `end` prop, and explain the underlying prefix-matching mechanism causing it.
4. Why does refreshing directly on `/tasks` work fine right now, but the tutorial warns this could break later in production?

## Deliverables Checklist
- [ ] Screenshot of all four pages navigating correctly with active-link highlighting
- [ ] Screenshot/description of Exercise 1's wildcard-ordering bug
- [ ] Screenshot/description of Exercise 2's missing-`end` bug
- [ ] Network tab screenshot from Exercise 3 confirming no full reloads
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| 404 page shows for routes that ARE defined | Move the wildcard `<Route path="*">` to be listed LAST |
| Root nav link stays highlighted everywhere | Add the `end` prop to that specific `NavLink` |
| Clicking a link causes a full page reload | Confirm you're using `Link`/`NavLink`, not a plain `<a>` tag |

---

# LAB 6.2: Nested Routes, URL Params, Protected Routes

**Estimated Duration:** 90–120 minutes
**Corresponds to:** Phase 6, Part 2

## Learning Objectives
- Build nested routes using `<Outlet>` and pass data via `useOutletContext`
- Read and safely compare a dynamic URL parameter
- Build client-side route protection while correctly understanding its real security limits

## Prerequisites
- Lab 6.1 complete

## Materials/Tools Required
- None beyond the existing project

## Pre-Lab Checklist
- [ ] Multi-page navigation from Lab 6.1 works correctly
- [ ] I have read Phase 6, Part 2 of the tutorial

## Lab Procedure

**Step 1 — Build `HabitsLayout.jsx`** using `<Outlet context={{...}}>`, and restructure the `/habits` route into a parent + two nested child routes (`index` and `:habitId`).

**Step 2 — Build `HabitDetailPage.jsx`** using `useParams()` and `useOutletContext()`, with a correct `String(habit.id) === habitId` comparison.

**Step 3 — Add a "Details" link** to each `HabitCard`, with `stopPropagation()` to avoid triggering the card's own toggle.

**Step 4 — Build the three-file Auth Context** (`AuthContext.js`, `AuthProvider.jsx`, `useAuth.js`) and wrap `<App />` in `<AuthProvider>`.

**Step 5 — Build `ProtectedRoute.jsx`** and `LoginPage.jsx`, wiring the `/settings` route to require authentication.

**Step 6 — Perform the security demonstration**: log in, open DevTools → Application/Storage, and manually edit or delete the `localStorage` auth key to bypass your own login. Record what happens.

**Step 7 — Commit:**
```bash
git add .
git commit -m "Lab 6.2: Nested routes and protected routes implemented"
```

## Expected Result
- `/habits/:habitId` correctly shows the right habit's detail page, or a graceful "not found" message for invalid IDs
- Visiting `/settings` while logged out redirects to `/login`; logging in redirects back to `/settings` specifically
- Manually editing `localStorage` genuinely bypasses the login, confirming the client-side-only security limitation

## In-Lab Exercises
1. Run `console.log(typeof habit.id, typeof habitId)` inside `HabitDetailPage` and record the two different types, confirming why a naive `===` comparison fails.
2. Deliberately remove the `replace` option from your `<Navigate to="/login" replace .../>` redirect. Log out, get redirected to `/login`, log back in, then press the browser's Back button. Record what happens differently compared to having `replace` present.
3. Visit `/habits/999999` (a non-existent ID) and confirm the graceful "not found" fallback, with a screenshot.

## Post-Lab Questions (Lab Report)
1. Explain the "picture frame with a swappable photo" analogy for nested routes.
2. Based on Exercise 1, confirm the exact types logged, and explain why `String(habit.id) === habitId` is required instead of a direct comparison.
3. Trace the full round-trip: a logged-out user clicks Settings, logs in, and lands back on Settings. What role does `location.state` play, specifically?
4. Based on Step 6's security demonstration, explain in your own words exactly what real security this Phase's authentication implementation does and does NOT provide.

## Deliverables Checklist
- [ ] Screenshot of the working habit detail page and its "not found" fallback (Exercise 3)
- [ ] Console output from Exercise 1 confirming the type mismatch
- [ ] Description of the Back-button behavior difference from Exercise 2, with and without `replace`
- [ ] Screenshot/description of the Step 6 localStorage-editing security bypass
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Habit detail always shows "not found" for real habits | Use `String(habit.id) === habitId` instead of a direct `===` comparison |
| `useOutletContext()` returns undefined | Confirm the component is a genuine nested CHILD route, not rendered directly |
| Login doesn't return the user to their original page | Confirm `state={{ from: location }}` is passed, and read correctly on the LoginPage side |

---
```
[GENERATED: Lab Book Batch 8 — Phase 7: Advanced Patterns Labs]
[STARTING: Lab Book Batch 9 — Lab 8.1 (Phase 8: Quality)]
```

# LAB 8.1: Testing with Vitest & React Testing Library

**Estimated Duration:** 120–150 minutes (this lab is intentionally longer — consider splitting into two sessions)
**Corresponds to:** Phase 8, Part 1

## Learning Objectives
- Configure Vitest and React Testing Library for a Vite project
- Write component tests covering rendering, user interaction, and conditional behavior
- Mock functions and modules to achieve fast, deterministic, backend-independent tests
- Test a custom hook in isolation using `renderHook`

## Prerequisites
- Lab 7.2 complete

## Materials/Tools Required
- A third terminal (optional but recommended, for running `npm test` in watch mode)

## Pre-Lab Checklist
- [ ] Custom hooks from Lab 7.2 work correctly
- [ ] I have read Phase 8, Part 1 of the tutorial

## Lab Procedure

**Step 1 — Install the testing toolchain:**
```bash
npm install -D vitest@2.1.8 jsdom@25.0.1 @testing-library/react@16.1.0 @testing-library/jest-dom@6.6.3 @testing-library/user-event@14.5.2
```

**Step 2 — Configure `vite.config.js`'s `test` block** and create `src/tests/setup.js`.

**Step 3 — Add the `test` script** to `package.json` and run `npm test` to confirm it starts (expect "No test files found" at this point).

**Step 4 — Write `Badge.test.jsx`.** Run it, confirm it passes. Deliberately break one assertion (`'🔥 6'` instead of `'🔥 5'`), observe the failure output, then fix it.

**Step 5 — Write `HabitCard.test.jsx`**, including the `MemoryRouter` wrapper and the `stopPropagation()` verification test.

**Step 6 — Write `useToggle.test.js`** using `renderHook` and `act`.

**Step 7 — Write `TaskForm.test.jsx`** using `vi.fn()` for mocked callback props.

**Step 8 — Write `tasksApi.test.js`**, mocking `global.fetch` and `vi.mock()`-ing `config.js`.

**Step 9 — Run the FULL test suite with `npm run server` explicitly STOPPED**, confirming all tests pass without any backend running.

**Step 10 — Commit:**
```bash
git add .
git commit -m "Lab 8.1: Test suite implemented"
```

## Expected Result
- `npm test` reports all test files passing
- The full suite passes with `json-server` explicitly not running, proving proper mocking
- Deliberately breaking `stopPropagation()` in `HabitCard.jsx` causes the corresponding test to correctly fail

## In-Lab Exercises
1. Deliberately remove `event.stopPropagation()` from `HabitCard.jsx`. Run the test suite and record which specific test fails and what error message it produces. Restore the fix and confirm the suite passes again.
2. Deliberately use `getByText` instead of `queryByText` when asserting something is ABSENT (e.g., `expect(screen.getByText('On fire!')).not.toBeInTheDocument()` on a low-streak habit where the text genuinely isn't rendered). Record the resulting confusing error, then fix it using the correct `queryBy` pattern.
3. Write one additional test file for a component NOT tested in the tutorial (e.g., `FilterTabs.test.jsx`), covering initial render, clicking a tab, and the active tab's class changing correctly.

## Post-Lab Questions (Lab Report)
1. Explain the "test like a curious user, not a suspicious inspector" philosophy in your own words, with a concrete example of what NOT to assert on.
2. Based on Exercise 1, report the exact failing test name and error message, and explain what this demonstrates about the value of the test suite.
3. Explain the difference between `getBy`, `queryBy`, and `findBy`, using Exercise 2's outcome as a concrete illustration.
4. Why does `TaskForm.test.jsx` never need to mock `tasksApi.js` directly, even though the real app eventually calls it?

## Deliverables Checklist
- [ ] Full `npm test` output showing all tests passing, with `json-server` confirmed stopped
- [ ] Exact failing-test output from Exercise 1
- [ ] Exact error output from Exercise 2's `getBy`/`queryBy` mix-up, and the corrected version
- [ ] Your Exercise 3 new test file, committed, passing
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| "Unable to find an element with the text" | Confirm the exact rendered text matches your query, or use a regex matcher for partial/case-insensitive matches |
| `act()` warning in hook tests | Wrap direct hook-function calls in `act(() => { ... })` |
| Router-related errors during a component test | Wrap the render in `<MemoryRouter>` |
| Mocked module isn't taking effect | Confirm `vi.mock()` is called at the TOP LEVEL of the file, not inside a test or `describe` block |

---
```
[GENERATED: Lab Book Batch 9 — Phase 8: Quality Lab]
[STARTING: Lab Book Batch 10 (FINAL) — Labs 9.1, 9.2 + Capstone Lab + Appendix]
```

# LAB 9.1: Production Builds, Environment Variables, Performance

**Estimated Duration:** 105–120 minutes
**Corresponds to:** Phase 9, Part 1

## Learning Objectives
- Produce and locally verify an optimized production build
- Correctly configure layered environment variables for development vs. production
- Apply and MEASURE the effect of `React.memo`, `useCallback`, and code-splitting

## Prerequisites
- Lab 8.1 complete

## Materials/Tools Required
- React Developer Tools browser extension (install now if not already present)

## Pre-Lab Checklist
- [ ] Full test suite from Lab 8.1 passes
- [ ] I have read Phase 9, Part 1 of the tutorial
- [ ] React DevTools extension is installed

## Lab Procedure

**Step 1 — Run and inspect a production build:**
```bash
npm run build
```
Inspect the `dist/` folder and the reported file sizes.

**Step 2 — Verify locally with `npm run preview`**, confirming hashed asset filenames via the Network tab.

**Step 3 — Configure `.env.development`/`.env.production`** with different `VITE_API_URL` values; verify the correct one is baked into each respective build/dev mode.

**Step 4 — Open the React DevTools Profiler.** Record a BEFORE session: navigate to Habits, toggle a habit, stop recording. Screenshot the flame graph showing ALL cards re-rendering.

**Step 5 — Apply `React.memo`** to `HabitCard`/`TaskCard` alone. Re-profile. Confirm (surprisingly) that all cards STILL re-render.

**Step 6 — Apply the full two-part fix**: `useCallback` on the handler in `App.jsx`, plus passing `id` as a prop and calling `onToggle(id)` inside `HabitCard`/`TaskCard` directly. Re-profile. Confirm ONLY the toggled card now re-renders.

**Step 7 — Apply `React.lazy()`** to all page components, wrap `<Routes>` in `<Suspense>`. Rebuild and confirm multiple separate chunk files in the output.

**Step 8 — Commit:**
```bash
git add .
git commit -m "Lab 9.1: Production build, memoization, and code-splitting complete"
```

## Expected Result
- `npm run build` succeeds; `npm run preview` runs the real built output correctly
- The BEFORE Profiler recording shows every card re-rendering on a single toggle; the AFTER recording shows only the toggled card
- The build output lists multiple separate page-specific JS chunks after applying `React.lazy()`

## In-Lab Exercises
1. Search the built `dist/assets/*.js` file for your production API URL string, confirming it was correctly baked in from `.env.production`.
2. Apply `React.memo` to ONE additional component of your choice not covered in the tutorial (e.g., `Badge`), profile before and after, and document whether it made any measurable difference — explain why or why not.
3. Deliberately forget the `<Suspense>` wrapper around your lazy-loaded routes, navigate to a lazy page, and record the exact error. Restore the wrapper.

## Post-Lab Questions (Lab Report)
1. Why did applying `React.memo` to `HabitCard` ALONE (Step 5) fail to prevent unnecessary re-renders? Be specific about the inline-function mechanism.
2. Describe the exact two-part fix from Step 6 and why BOTH parts were necessary together.
3. Based on Exercise 2, was `React.memo` worth applying to your chosen additional component? Justify your answer using actual Profiler measurements, not assumption.
4. What is the "golden rule of performance work" demonstrated throughout this lab, and how did Steps 4–6 model it in practice?

## Deliverables Checklist
- [ ] `npm run build` output showing file sizes
- [ ] BEFORE and AFTER Profiler screenshots (Steps 4 and 6)
- [ ] Confirmation from Exercise 1 that the correct production URL was baked into the build
- [ ] Profiler screenshots and written justification from Exercise 2
- [ ] Exact error message from Exercise 3
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| `memo`-wrapped component still re-renders every time | Confirm function props are wrapped in `useCallback`, and inline arrow functions were eliminated at the call site |
| Wrong environment variable baked into a build | Confirm exact filenames `.env.development`/`.env.production`; rebuild after any changes |
| "Suspended by an uncached promise" error | Wrap the lazy component in a `<Suspense fallback={...}>` boundary |

---

# LAB 9.2: Deploying to Vercel

**Estimated Duration:** 120–150 minutes (budget extra time for external service dependencies)
**Corresponds to:** Phase 9, Part 2

## Learning Objectives
- Convert a local mock backend into deployable serverless functions
- Push a complete project to GitHub and deploy it live via Vercel
- Create and verify a Preview Deployment before merging to production

## Prerequisites
- Lab 9.1 complete
- A free GitHub account (created in Lab 0)
- A free Vercel account (create now if not already done)

## Materials/Tools Required
- GitHub and Vercel accounts, both accessible

## Pre-Lab Checklist
- [ ] Production build and performance work from Lab 9.1 complete
- [ ] I have read Phase 9, Part 2 of the tutorial
- [ ] I have a GitHub account ready

## Lab Procedure

**Step 1 — Build the `api/` folder** with serverless functions (`data-store.js`, `habits/index.js`, `habits/[id].js`, `tasks/index.js`, `tasks/[id].js`, `quote.js`).

**Step 2 — Update `.env.production`** to `VITE_API_URL=/api`.

**Step 3 — Add `vercel.json`** with the SPA rewrite rule.

**Step 4 — Complete the full Git workflow:**
```bash
git init  # if not already done
git add .
git commit -m "Complete project, ready for deployment"
git remote add origin <your-github-repo-url>
git branch -M main
git push -u origin main
```

**Step 5 — Create a Vercel project**, importing your GitHub repository, confirming Vite auto-detection.

**Step 6 — Manually set `VITE_API_URL=/api`** under Vercel's Environment Variables (all three environments checked). Deploy.

**Step 7 — Verify the live deployment** end-to-end: all pages, toggling, forms, dark mode, login.

**Step 8 — Create a Preview Deployment**: new branch, small visible change (e.g., the footer credit from the tutorial), push, open a pull request, verify the automatic preview URL, confirm production is unaffected, then merge and confirm production updates.

**Step 9 — Final commit:**
```bash
git add .
git commit -m "Lab 9.2: Deployed to Vercel with working Preview Deployments"
```

## Expected Result
- A live, public, HTTPS URL serves your fully functional Task & Habit Tracker
- A Preview Deployment, created automatically from a pushed branch, shows the proposed change in isolation from production
- Merging the pull request automatically triggers a new production deployment

## In-Lab Exercises
1. Visit your deployed app directly at a non-root URL (e.g., `yoursite.vercel.app/tasks`) and refresh the page. Confirm it loads correctly (rather than 404ing), proving your `vercel.json` rewrite rule works.
2. Stop and restart your browser, revisit your live URL after some time has passed, and check whether any previously-added tasks/habits persisted. Record and explain your observation in light of the in-memory data store's known limitation.
3. Deliberately remove `VITE_API_URL` from Vercel's Environment Variables settings temporarily, trigger a redeploy, and observe the resulting broken data-loading behavior. Restore the variable and redeploy.

## Post-Lab Questions (Lab Report)
1. Explain why `json-server` could not simply be "deployed" as-is, and what serverless functions provide instead.
2. Based on Exercise 1, confirm that the SPA rewrite rule works correctly on your live deployment, and explain what `vercel.json`'s rule specifically does.
3. Based on Exercise 2, describe what you observed about data persistence, and explain why this is an expected, deliberately-flagged limitation rather than a bug.
4. Walk through, step by step, exactly what happened from pushing your branch to seeing a working Preview Deployment URL, and then from merging to production updating.

## Deliverables Checklist
- [ ] Your live, public Vercel URL
- [ ] Screenshot of a working Preview Deployment URL, distinct from production
- [ ] Screenshot confirming production updated after merging
- [ ] Confirmation/description from Exercise 1 (non-root refresh working correctly)
- [ ] Written observation from Exercise 2 (persistence behavior)
- [ ] Screenshot of the broken state from Exercise 3, and confirmation of the restored fix
- [ ] Written answers to all 4 Post-Lab Questions

## Troubleshooting Quick Reference
| Symptom | Fix |
|---|---|
| Refreshing on a non-root URL shows a 404 | Confirm `vercel.json`'s rewrite rule exists and excludes `/api/` correctly |
| Deployed app can't load any data | Confirm `VITE_API_URL=/api` is set in Vercel's dashboard, not just locally |
| Preview Deployment doesn't appear on a PR | Confirm the branch was genuinely pushed to GitHub, and Vercel's GitHub integration has proper repository access |

---

# CAPSTONE LAB: Full-Stack Review & Extension

**Estimated Duration:** 3–5 hours (self-paced, no fixed session length)
**Corresponds to:** Entire course, cumulative

## Learning Objectives
- Demonstrate mastery across all nine Phases in a single, cumulative exercise
- Extend the finished application with an original feature, applying every convention taught
- Produce a complete, professional project retrospective

## Prerequisites
- All prior labs (0 through 9.2) complete, with a fully deployed live application

## Materials/Tools Required
- Your completed, deployed project repository
- Access to Appendix F (Further Reading) for extension ideas

## Lab Procedure

**Step 1 — Revisit Lab 0.5's per-Phase guesses.** Compare your original guesses about what each Phase might be needed for against what actually happened. Note how accurate or inaccurate your intuitions were.

**Step 2 — Trace one piece of data across the entire app's history.** Pick `habits` (or `tasks`) and write a document tracing its exact journey: hardcoded array (Phase 1) → lifted `useState` (Phase 2) → real API-fetched (Phase 4) → optimistically updated (Phase 4) → consolidated into a reducer (Phase 5) → passed through nested routes (Phase 6) → tested (Phase 8) → deployed via serverless functions (Phase 9).

**Step 3 — Choose ONE Stretch Challenge** from any Phase you did not complete during the original labs, and implement it now, to full working and tested completion.

**Step 4 — Choose ONE Further Reading direction** from Appendix F (TypeScript, a real database, deeper E2E testing, etc.) and write a one-to-two-page plan for how you would extend this project in that direction — specific files that would change, specific files that would NOT need to change, and why.

**Step 5 — Conduct a full, final verification pass** of the entire deployed application: every feature, from Dashboard to Settings, on the live production URL.

**Step 6 — Final commit and tag:**
```bash
git add .
git commit -m "Capstone: final extension and full verification complete"
git tag v1.0-capstone
git push --tags
```

## Expected Result
A live, fully-verified, professionally extended version of the Task & Habit Tracker, accompanied by a written retrospective demonstrating cumulative understanding across the entire course.

## Post-Lab Questions (Final Lab Report)
1. Present your Step 2 data-journey trace in full.
2. Present your Step 3 Stretch Challenge implementation, with a working demonstration link/screenshot.
3. Present your Step 4 extension plan in full.
4. Reflecting on the entire course: which single Phase changed your understanding of React the most, and why?
5. What is the ONE mental model or analogy from this entire course you expect to remember years from now?

## Deliverables Checklist
- [ ] Written comparison of Lab 0.5 guesses vs. actual outcomes
- [ ] Complete Step 2 data-journey document
- [ ] Working Step 3 Stretch Challenge, deployed and verified live
- [ ] Complete Step 4 extension plan
- [ ] Final, fully-verified live production URL
- [ ] Git tag `v1.0-capstone` pushed
- [ ] Written answers to all 5 Final Post-Lab Questions

---

# APPENDIX: Lab Report Template

*(Copy this template for each lab's written submission)*

```
LAB REPORT
Lab Number & Title: _______________________________
Date Completed: _______________________________
Time Spent: _______________________________

PRE-LAB CHECKLIST STATUS: [ ] All items confirmed

PROCEDURE COMPLETION:
Step 1: [ ] Complete   Notes: _______________________
Step 2: [ ] Complete   Notes: _______________________
(...repeat for all steps...)

EXPECTED RESULT ACHIEVED: [ ] Yes  [ ] No — explain: ___________

IN-LAB EXERCISES:
Exercise 1 — Observation/Result: _______________________
Exercise 2 — Observation/Result: _______________________
Exercise 3 — Observation/Result: _______________________

POST-LAB QUESTIONS:
1. _______________________
2. _______________________
3. _______________________
4. _______________________

DELIVERABLES ATTACHED: [ ] All items from checklist attached

SELF-ASSESSED GRADE (per rubric): _____ %

REFLECTION (optional): What was the hardest part of this lab, and why?
_______________________
```
