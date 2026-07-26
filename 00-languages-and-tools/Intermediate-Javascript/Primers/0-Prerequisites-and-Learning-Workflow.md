# Primer 0: Prerequisites and Learning Workflow

This primer explains how to prepare for the tutorial series, install the required tools, organize the project, and work through each implementation step successfully.

It does not teach the main JavaScript concepts yet. Instead, it establishes the workshop where those concepts will be practiced.

---

# 1. What This Series Assumes

You should have basic familiarity with:

- Variables.
- Strings and numbers.
- Arrays.
- Objects.
- Functions.
- `if` statements.
- Loops.
- Basic HTML.
- Basic CSS.
- Selecting DOM elements.
- Handling browser events.

You should be able to understand code such as:

```javascript
const button = document.querySelector("#save-button");

button.addEventListener("click", () => {
  console.log("The button was clicked.");
});
```

You do not need to know:

- Promises.
- `async`/`await`.
- Prototypes.
- Classes.
- ES modules.
- Browser storage.
- TypeScript.
- React or another framework.
- Backend development.
- Databases.

Those concepts are the purpose of the main series.

---

# 2. What You Will Build

The series builds a browser application called **Async Task Manager**.

The completed application will allow users to:

- Add tasks.
- Complete and reopen tasks.
- Delete tasks.
- Filter tasks.
- Load example tasks asynchronously.
- Display loading and error states.
- Save tasks in browser storage.
- Organize code into separate modules.
- Reconstruct task objects from JSON.
- Handle malformed data safely.

The project will begin simply and become more organized over time.

The progression is intentional:

```text
Simple script
    ↓
Asynchronous behavior
    ↓
Promise-based behavior
    ↓
Task classes
    ↓
Separate modules
    ↓
Persistent browser storage
```

You should not create the final directory structure before the tutorial asks you to. Building it gradually helps you understand why each file exists.

---

# 3. Required Tools

You need four basic tools.

## 3.1 A Modern Browser

Use one of the following:

- Google Chrome.
- Microsoft Edge.
- Mozilla Firefox.
- Safari.

The browser must support:

- Modern JavaScript.
- ES modules.
- Promises.
- `async`/`await`.
- `localStorage`.
- `sessionStorage`.
- Developer Tools.

Use an up-to-date browser version.

## 3.2 A Code Editor

Visual Studio Code is recommended, but alternatives include:

- Sublime Text.
- WebStorm.
- Vim or Neovim.
- Notepad++.
- Any editor that can save plain text files.

Avoid word processors such as Microsoft Word because they may insert formatting characters into source files.

## 3.3 A Terminal

You will use the terminal to:

- Create directories.
- Create files.
- Start a local development server.
- Inspect project contents.

Available terminals include:

- macOS Terminal.
- Windows PowerShell.
- Windows Terminal.
- Linux shell.
- Visual Studio Code’s integrated terminal.

## 3.4 Python or Another Local Server

The final application uses browser modules.

Modules should be loaded through a local HTTP server rather than opening the HTML file directly with a `file://` URL.

Python provides a simple local server:

```bash
python3 -m http.server 8000
```

On some Windows installations:

```powershell
python -m http.server 8000
```

You can use another local server if you already have one.

---

# 4. Check Your Tools

Before creating the project, verify that your tools work.

## Check the Browser

Open your browser and visit:

```text
https://example.com
```

If the page loads, the browser can access websites normally.

## Check Visual Studio Code

If using Visual Studio Code, open it from your applications menu.

You can also check whether the command-line launcher is available:

```bash
code --version
```

If the command is unavailable, you can still open Visual Studio Code normally.

## Check Python

Run:

```bash
python3 --version
```

You should see a version number such as:

```text
Python 3.12.0
```

On Windows, try:

```powershell
python --version
```

If neither command works, install Python from:

```text
https://www.python.org/downloads/
```

During Windows installation, enable the option similar to:

```text
Add Python to PATH
```

---

# 5. Understand the Terminal

A terminal is a text-based way to communicate with your operating system.

Instead of clicking folders, you type commands.

The terminal always operates from a current directory.

## Show the Current Directory

### macOS or Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

Example output:

```text
/Users/your-name/projects
```

or:

```text
C:\Users\your-name\projects
```

## List Files

### macOS or Linux

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

## Move into a Directory

```bash
cd async-task-manager
```

The `cd` command means “change directory.”

## Move to the Parent Directory

```bash
cd ..
```

The two dots mean the directory above the current directory.

## Create a Directory

### macOS or Linux

```bash
mkdir example-directory
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path example-directory
```

## Create a File

### macOS or Linux

```bash
touch example.js
```

### Windows PowerShell

```powershell
New-Item -ItemType File -Path example.js
```

You can also create files directly in your editor.

---

# 6. Choose a Workspace Directory

Create a parent directory for coding projects.

## macOS or Linux

```bash
mkdir -p ~/projects
cd ~/projects
```

## Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\projects"
Set-Location "$HOME\projects"
```

Verify your location.

### macOS or Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

You should now be inside a projects directory.

---

# 7. Create the Project Directory

Create the project directory:

```text
async-task-manager
```

## macOS or Linux

```bash
mkdir async-task-manager
cd async-task-manager
```

## Windows PowerShell

```powershell
New-Item -ItemType Directory -Path async-task-manager
Set-Location async-task-manager
```

Verify:

```bash
pwd
```

or:

```powershell
Get-Location
```

Your current directory should end with:

```text
async-task-manager
```

---

# 8. Open the Project in Your Editor

If the `code` command is available:

```bash
code .
```

The period means:

> Open the current directory.

If that command is unavailable:

1. Open Visual Studio Code.
2. Choose **File**.
3. Choose **Open Folder**.
4. Select the `async-task-manager` directory.

The editor’s file explorer should show the project directory.

---

# 9. Create a First Test File

Before starting the main project, verify that the browser can run JavaScript.

Create a file named:

```text
hello.html
```

Add:

### `hello.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>JavaScript Environment Test</title>
  </head>

  <body>
    <h1>JavaScript Environment Test</h1>

    <p id="message">Waiting for JavaScript...</p>

    <script>
      "use strict";

      const messageElement =
        document.querySelector("#message");

      messageElement.textContent =
        "JavaScript is running correctly.";
    </script>
  </body>
</html>
```

## Verification

Open `hello.html` in your browser.

You should see:

```text
JavaScript Environment Test
JavaScript is running correctly.
```

Open Developer Tools:

```text
Windows/Linux: F12 or Ctrl + Shift + I
macOS: Cmd + Option + I
```

Open the **Console** tab.

Run:

```javascript
console.log("The browser console is working.");
```

You should see:

```text
The browser console is working.
```

Delete `hello.html` after verifying the environment.

[COMPLETED: Tool verification — Browser and editor environment confirmed]  
[STARTING: Project workflow and verification conventions]

---

# 10. Understand Relative Paths

The project will contain files in different directories.

Suppose the structure is:

```text
async-task-manager/
├── index.html
└── js/
    ├── main.js
    └── models/
        └── task.js
```

From `index.html` to `main.js`:

```html
<script type="module" src="./js/main.js"></script>
```

From `main.js` to `task.js`:

```javascript
import { Task } from "./models/task.js";
```

From a file inside `js/services/` to a file inside `js/models/`:

```text
js/services/storage-service.js
js/models/task.js
```

The import is:

```javascript
import { Task } from "../models/task.js";
```

The `..` means:

> Move up one directory.

The path is always relative to the file containing the import, not relative to `index.html`.

---

# 11. Save Files Before Testing

A common beginner problem is testing an old version of a file.

Before refreshing the browser:

1. Save the file.
2. Confirm the filename is correct.
3. Confirm the file is in the expected directory.
4. Refresh the browser.
5. Read the console.

In Visual Studio Code:

```text
Ctrl + S
```

on Windows/Linux, or:

```text
Cmd + S
```

on macOS.

---

# 12. Use a Local Server

The project will eventually contain module imports such as:

```javascript
import { Task } from "./models/task.js";
```

Opening the application directly may cause browser restrictions.

Start a local server from the project root:

```bash
python3 -m http.server 8000
```

Or:

```powershell
python -m http.server 8000
```

The terminal should display something similar to:

```text
Serving HTTP on 0.0.0.0 port 8000
```

Open:

```text
http://localhost:8000
```

To stop the server, press:

```text
Ctrl + C
```

---

# 13. Confirm the Server Is Serving the Correct Directory

The server serves the directory where the command was run.

If you accidentally start it from the wrong directory, the browser may show the wrong files.

Check the terminal location first:

### macOS or Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

You should be inside:

```text
async-task-manager
```

Then start:

```bash
python3 -m http.server 8000
```

Open:

```text
http://localhost:8000
```

You should see the project’s `index.html` when it exists.

---

# 14. Understand Browser Refreshing

Browsers may cache files.

When debugging a changed file, use a normal refresh first:

```text
Windows/Linux: Ctrl + R
macOS: Cmd + R
```

If the browser appears to use an old file, perform a hard refresh:

```text
Windows/Linux: Ctrl + Shift + R
macOS: Cmd + Shift + R
```

You can also use Developer Tools:

1. Open Developer Tools.
2. Hold the refresh button.
3. Choose **Empty Cache and Hard Reload** if available.

Do not assume caching is the problem until you inspect the console and network panel.

---

# 15. Read Errors Before Changing Code

When the application does not work, do not immediately rewrite files.

First:

1. Open Developer Tools.
2. Select **Console**.
3. Read the first error.
4. Click the file and line number.
5. Inspect the surrounding code.

Example:

```text
Uncaught TypeError:
Cannot read properties of null
```

This usually means a DOM selector did not find an element.

Example:

```text
Failed to resolve module specifier
```

This usually means an import path is incorrect.

Example:

```text
Unexpected token '<'
```

This may mean the browser expected JavaScript or JSON but received an HTML error page.

---

# 16. Use the Browser Console for Small Experiments

You do not need to edit the project for every experiment.

Test a language feature directly:

```javascript
const values = [1, 2, 3];

values.map((value) => value * 2);
```

Expected result:

```javascript
[2, 4, 6]
```

Test a Promise:

```javascript
Promise.resolve("Success").then(console.log);
```

Test browser storage:

```javascript
localStorage.setItem("test-key", "test-value");

localStorage.getItem("test-key");
```

Clean up:

```javascript
localStorage.removeItem("test-key");
```

Small experiments help isolate a question before changing the full application.

---

# 17. Keep the Application State Understandable

The application will have state such as:

```javascript
tasks
currentFilter
isLoading
```

When debugging, inspect the state together:

```javascript
console.log({
  tasks,
  currentFilter,
  isLoading,
});
```

Ask:

- Is the data correct?
- Is the UI displaying the correct data?
- Did the state change?
- Did the application render after the state changed?
- Was the new state saved?

A useful mental model is:

```text
State → Persistence → Rendering
```

After a user action:

```text
1. Update state.
2. Save state if necessary.
3. Render the visible state.
```

---

# 18. Do Not Skip Verification Steps

Every technical step will include a verification section.

Treat verification like checking a bridge before driving the next vehicle across it.

If the current step does not work, later steps may produce confusing errors.

For each step, confirm:

- The expected file exists.
- The browser output is correct.
- The console is free of unexpected errors.
- The expected state change occurred.
- The relevant storage value was written when applicable.

---

# 19. Keep Temporary Experiments Separate

Temporary files should have names that make their purpose obvious:

```text
promise-demo.html
prototype-demo.html
storage-test.html
```

Do not mix temporary test code into production files unless the tutorial explicitly asks you to.

After an experiment:

- Remove the temporary file.
- Restore the correct script entry point.
- Clear test storage.
- Refresh the application.

---

# 20. Reset Browser Storage

When old data interferes with testing, reset the application’s storage.

Run:

```javascript
localStorage.removeItem(
  "async-task-manager.tasks.v1"
);

sessionStorage.removeItem(
  "async-task-manager.filter.v1"
);

location.reload();
```

To inspect storage first:

```javascript
Object.keys(localStorage);
Object.keys(sessionStorage);
```

Avoid using this unless necessary:

```javascript
localStorage.clear();
```

It removes every local-storage value for the current origin, not only the task manager’s data.

---

# 21. Understand the Current Origin

Storage belongs to the browser origin.

These addresses may use separate storage:

```text
http://localhost:8000
http://127.0.0.1:8000
http://localhost:3000
```

Check the current origin:

```javascript
location.origin;
```

Use the same address consistently during development:

```text
http://localhost:8000
```

---

# 22. Recommended Learning Workflow

For each tutorial step, follow this order:

## 1. Read the Target

Understand which file or feature is being created.

## 2. Read the Concept

Make sure you understand why the feature is needed.

## 3. Create or Replace the File

Use the complete code block provided.

## 4. Save the File

Do not test an unsaved version.

## 5. Run the Verification

Use the exact commands and browser actions.

## 6. Compare Expected and Actual Results

If they match, continue.

## 7. If They Do Not Match, Debug Immediately

Do not continue while the application is already broken.

---

# 23. Recommended Note-Taking Format

Keep a short development journal.

For each step, record:

```text
Step:
What I changed:
What I expected:
What happened:
What I learned:
```

Example:

```text
Step: Promise-based task loading
What I changed: Replaced the callback loader with a Promise
What I expected: Three tasks after 1.5 seconds
What happened: Three tasks appeared and the button re-enabled
What I learned: finally() runs after success and failure
```

This makes the series more effective than passively copying code.

---

# 24. Use Version Control if Possible

Git is optional, but strongly recommended.

Initialize a repository:

```bash
git init
```

Check the status:

```bash
git status
```

Add files:

```bash
git add .
```

Create a commit:

```bash
git commit -m "Create initial task manager structure"
```

After a successful tutorial milestone:

```bash
git add .
git commit -m "Add Promise-based task loading"
```

A commit creates a checkpoint you can return to if a later change causes problems.

---

# 25. Suggested Git Checkpoints

Useful checkpoints include:

```text
01-initial-html-and-css
02-synchronous-task-rendering
03-callback-based-loading
04-promise-based-loading
05-async-await-loading
06-task-class
07-modular-architecture
08-browser-storage
09-final-application
```

Create a commit after each major checkpoint:

```bash
git add .
git commit -m "Complete callback-based loading"
```

---

# 26. Do Not Commit Unnecessary Files

A simple `.gitignore` file can exclude operating-system files and editor metadata.

### `.gitignore`

```gitignore
.DS_Store
Thumbs.db
.vscode/
*.log
node_modules/
dist/
coverage/
```

If you use a local server, it does not usually create files that need to be ignored.

---

# 27. Expected Final Environment

At the beginning, the project may contain only:

```text
async-task-manager/
├── index.html
├── styles.css
└── js/
    └── main.js
```

By the end, it will contain:

```text
async-task-manager/
├── index.html
├── styles.css
└── js/
    ├── main.js
    ├── app.js
    ├── api/
    ├── models/
    ├── services/
    ├── ui/
    └── utils/
```

Do not worry if your directory is small at the beginning. It is supposed to grow.

---

# 28. Common Setup Problems

## Python Command Not Found

Try:

```bash
python --version
```

instead of:

```bash
python3 --version
```

If neither works, install Python or use another local server.

## Port Already in Use

If port `8000` is occupied, use another port:

```bash
python3 -m http.server 8080
```

Open:

```text
http://localhost:8080
```

## Port Permission Error

Choose a higher port:

```bash
python3 -m http.server 3000
```

## Browser Shows a Directory Listing

This means the server is running, but no `index.html` exists in the current directory.

Confirm:

```bash
ls
```

or:

```powershell
Get-ChildItem
```

## Browser Shows the Wrong Project

The server may have been started from the wrong directory.

Stop it:

```text
Ctrl + C
```

Move to the correct project directory:

```bash
cd async-task-manager
```

Start the server again.

## Changes Do Not Appear

Check:

1. The file was saved.
2. The browser URL points to the correct server.
3. The correct file was edited.
4. The console does not show an earlier error.
5. A hard refresh was attempted.

---

# 29. Learning Expectations

You are not expected to understand every line immediately.

When you encounter unfamiliar code:

1. Identify the function name.
2. Identify its parameters.
3. Identify its return value.
4. Identify which values it changes.
5. Identify which module owns it.
6. Run the verification.
7. Change one small value and observe the result.

For example:

```javascript
async function loadTasks() {
  const tasks = await fetchTasks();
  renderTasks(tasks);
}
```

Ask:

- What does `async` do?
- What does `await` wait for?
- What does `fetchTasks()` return?
- What type is `tasks`?
- What happens if `fetchTasks()` fails?
- Which function updates the page?

These questions turn unfamiliar syntax into a sequence of smaller ideas.

---

# 30. What “Copy-Pasteable” Means in This Series

The tutorial uses complete file contents whenever a file is created or substantially changed.

When a section says:

```text
Replace the complete file with:
```

delete the old contents and paste the entire new file.

When a section says:

```text
Add this function below...
```

keep the existing file and insert the new function at the described location.

Do not paste a complete replacement file into the middle of another file.

Read whether the instructions say:

- Create.
- Replace.
- Add.
- Remove.
- Temporarily change.
- Restore.

---

# 31. Primer 0 Completion Checklist

Before beginning Part 0, verify:

- [ ] A modern browser is installed.
- [ ] A code editor is available.
- [ ] A terminal is available.
- [ ] Python or another local server is available.
- [ ] A projects directory exists.
- [ ] The `async-task-manager` directory exists.
- [ ] You can create and save a file.
- [ ] You can open a local HTML file.
- [ ] You can open Developer Tools.
- [ ] You can read the browser console.
- [ ] You understand the current-directory concept.
- [ ] You understand relative file paths.
- [ ] You know how to start and stop the local server.
- [ ] You know how to reset browser storage.
- [ ] You understand the tutorial’s target/concept/implementation/verification workflow.
