# Primer 3: Terminal, Files, and Local Development

This primer prepares you to work with project files from the terminal and run the application through a local development server.

You will learn how to:

- Navigate directories.
- Create files and folders.
- Inspect project contents.
- Open a project in an editor.
- Start and stop a local server.
- Understand ports and URLs.
- Use relative paths.
- Avoid common file and server mistakes.
- Create a repeatable development workflow.

You do not need advanced command-line knowledge. The commands in this primer are small and practical.

---

# 1. Understand the Terminal

## The Target

Understand what the terminal does.

## The Concept

A terminal is a text-based interface for controlling your computer.

A graphical file manager lets you:

- Open folders.
- Create directories.
- Rename files.
- Move between locations.

The terminal performs the same tasks with commands.

The terminal always has a **current directory**. Commands that create or inspect files usually operate relative to that directory.

## The Implementation

Open a terminal:

- macOS: Terminal.
- Windows: PowerShell or Windows Terminal.
- Linux: Terminal.

Display the current directory.

### macOS or Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

## The Verification

The terminal should print a directory path similar to:

```text
/Users/your-name
```

or:

```text
C:\Users\your-name
```

This confirms that the terminal is responding.

[COMPLETED: Step 1 — Terminal opened and current directory inspected]  
[STARTING: Step 2 — List and navigate directories]

---

# 2. List Directory Contents

## The Target

View files and folders in the current directory.

## The Concept

Listing a directory is like looking inside a folder before deciding what to open.

## The Implementation

### macOS or Linux

```bash
ls
```

For more detail:

```bash
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem
```

For hidden files as well:

```powershell
Get-ChildItem -Force
```

## The Verification

You should see the files and folders located in the current directory.

If the directory is empty, that is acceptable. You will create the project in the next step.

[COMPLETED: Step 2 — Directory contents listed]  
[STARTING: Step 3 — Create and enter a project directory]

---

# 3. Create the Project Directory

## The Target

Create a directory named:

```text
async-task-manager
```

## The Concept

A project directory keeps all files for one application together.

This is similar to giving a project its own workshop. It prevents files from unrelated projects from being mixed together.

## The Implementation

Choose a location such as your home directory or a `projects` directory.

### macOS or Linux

```bash
mkdir -p ~/projects
cd ~/projects
mkdir async-task-manager
cd async-task-manager
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\projects"
Set-Location "$HOME\projects"
New-Item -ItemType Directory -Path "async-task-manager"
Set-Location "async-task-manager"
```

## The Verification

Display the current directory.

### macOS or Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

The path should end with:

```text
async-task-manager
```

[COMPLETED: Step 3 — Project directory created and selected]  
[STARTING: Step 4 — Create files and directories]

---

# 4. Create Files and Directories

## The Target

Create a small project structure from the terminal.

## The Concept

Directories organize related responsibilities.

The final project will eventually contain:

```text
async-task-manager/
├── index.html
├── styles.css
└── js/
    ├── main.js
    ├── models/
    ├── services/
    └── ui/
```

We will create a smaller test structure first.

## The Implementation

### macOS or Linux

```bash
mkdir -p js/models js/services js/ui
touch index.html styles.css
touch js/main.js
touch js/models/task.js
touch js/services/storage-service.js
touch js/ui/task-list.js
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path js/models
New-Item -ItemType Directory -Force -Path js/services
New-Item -ItemType Directory -Force -Path js/ui

New-Item -ItemType File -Path index.html
New-Item -ItemType File -Path styles.css
New-Item -ItemType File -Path js/main.js
New-Item -ItemType File -Path js/models/task.js
New-Item -ItemType File -Path js/services/storage-service.js
New-Item -ItemType File -Path js/ui/task-list.js
```

## The Verification

### macOS or Linux

```bash
find . -maxdepth 4 -type f
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File
```

Expected structure:

```text
index.html
styles.css
js/main.js
js/models/task.js
js/services/storage-service.js
js/ui/task-list.js
```

[COMPLETED: Step 4 — Initial project files and directories created]  
[STARTING: Step 5 — Open the project in an editor]

---

# 5. Open the Project in Visual Studio Code

## The Target

Open the project directory in a code editor.

## The Concept

A code editor lets you view and modify project files as plain text.

Opening the entire project directory is better than opening individual files because the editor can show:

- The directory structure.
- Related files.
- Relative paths.
- Search results across the project.
- Version-control changes.

## The Implementation

If the Visual Studio Code command is installed:

```bash
code .
```

The period means:

> Open the current directory.

If the command is unavailable:

1. Open Visual Studio Code.
2. Select **File**.
3. Select **Open Folder**.
4. Choose `async-task-manager`.

## The Verification

The editor’s file explorer should show:

```text
async-task-manager
├── index.html
├── styles.css
└── js
    ├── main.js
    ├── models
    ├── services
    └── ui
```

[COMPLETED: Step 5 — Project opened in an editor]  
[STARTING: Step 6 — Write and inspect a first file]

---

# 6. Write a First HTML File

## The Target

Add a minimal page to `index.html`.

## The Concept

The terminal creates and locates files, but the editor is usually more convenient for writing substantial code.

## The Implementation

### `index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>Local Development Test</title>
  </head>

  <body>
    <main>
      <h1>Local development is working.</h1>

      <p>
        This page is being served from the project directory.
      </p>
    </main>
  </body>
</html>
```

Save the file.

## The Verification

Confirm the file contains the new content.

### macOS or Linux

```bash
cat index.html
```

### Windows PowerShell

```powershell
Get-Content index.html
```

The terminal should print the complete HTML file.

[COMPLETED: Step 6 — First project file written]  
[STARTING: Step 7 — Start a local development server]

---

# 7. Start a Local Development Server

## The Target

Serve the project through HTTP.

## The Concept

Opening a page directly from the filesystem uses a URL like:

```text
file:///Users/your-name/async-task-manager/index.html
```

A local development server uses an HTTP URL such as:

```text
http://localhost:8000
```

This matters because browser modules, network requests, and other web features behave more like they will in a deployed application when served through HTTP.

## The Implementation

From the project root, run:

### macOS or Linux

```bash
python3 -m http.server 8000
```

### Windows PowerShell

```powershell
python -m http.server 8000
```

Keep the terminal running.

Open your browser at:

```text
http://localhost:8000
```

## The Verification

You should see:

```text
Local development is working.
This page is being served from the project directory.
```

The terminal may log a request similar to:

```text
"GET / HTTP/1.1" 200 -
```

This confirms that the browser requested the page from the local server.

[COMPLETED: Step 7 — Local HTTP server started]  
[STARTING: Step 8 — Understand hostnames and ports]

---

# 8. Understand `localhost` and Ports

## The Target

Understand the development URL.

## The Concept

A URL such as:

```text
http://localhost:8000
```

has several parts:

```text
http://     scheme
localhost   host
8000        port
```

### `http`

The communication protocol.

### `localhost`

The current computer.

### `8000`

The port where the server is listening.

A port is like a numbered entrance to a computer. Multiple development servers can run simultaneously if they use different ports.

## The Implementation

Stop the current server by pressing:

```text
Ctrl + C
```

Start it on another port:

```bash
python3 -m http.server 8080
```

On Windows:

```powershell
python -m http.server 8080
```

Open:

```text
http://localhost:8080
```

## The Verification

The same page should load at port `8080`.

Now stop the server and try to refresh the browser.

The page should fail to load because no server is listening on that port.

Restart the server:

```bash
python3 -m http.server 8080
```

Refresh the browser.

The page should load again.

[COMPLETED: Step 8 — Hostnames and ports understood]  
[STARTING: Step 9 — Stop and restart the server]

---

# 9. Stop and Restart the Server

## The Target

Learn how to control the local server process.

## The Concept

The server is a running process attached to the terminal.

While the process is running:

- The terminal displays requests.
- The browser can access the project.
- The terminal cannot normally accept unrelated commands.

## The Implementation

Stop the server:

```text
Ctrl + C
```

Start it again:

```bash
python3 -m http.server 8000
```

## The Verification

After pressing `Ctrl + C`, the terminal should return to a normal command prompt.

After restarting, open:

```text
http://localhost:8000
```

The page should load again.

[COMPLETED: Step 9 — Server lifecycle practiced]  
[STARTING: Step 10 — Understand relative and absolute paths]

---

# 10. Relative and Absolute Paths

## The Target

Understand how files refer to one another.

## The Concept

A relative path starts from the current file’s location.

Suppose the project contains:

```text
async-task-manager/
├── index.html
└── js/
    └── main.js
```

From `index.html`, the path to `main.js` is:

```text
./js/main.js
```

The `./` means:

> Start in the current directory.

If a file is inside `js/services/` and needs a file inside `js/models/`:

```text
js/services/storage-service.js
js/models/task.js
```

the path is:

```text
../models/task.js
```

The `..` means:

> Move up one directory.

## The Implementation

Add content to:

### `js/main.js`

```javascript
"use strict";

console.log("main.js loaded successfully.");
```

Update `index.html` before `</body>`:

```html
<script src="./js/main.js"></script>
```

The complete file should be:

### `index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>Local Development Test</title>
  </head>

  <body>
    <main>
      <h1>Local development is working.</h1>

      <p>
        This page is being served from the project directory.
      </p>
    </main>

    <script src="./js/main.js"></script>
  </body>
</html>
```

## The Verification

Open the browser console.

You should see:

```text
main.js loaded successfully.
```

Now temporarily change the script path to:

```html
<script src="./missing/main.js"></script>
```

Refresh the page.

The console should report a failed resource request.

Restore:

```html
<script src="./js/main.js"></script>
```

[COMPLETED: Step 10 — Relative file paths verified]  
[STARTING: Step 11 — Use browser modules with a local server]

---

# 11. Load an ES Module

## The Target

Use `import` and `export` between files.

## The Concept

A module is a JavaScript file with an explicit public interface.

One file exports a value:

```javascript
export function getMessage() {
  return "Hello from a module.";
}
```

Another file imports it:

```javascript
import { getMessage } from "./message.js";
```

Browser modules require:

```html
<script type="module" src="./js/main.js"></script>
```

## The Implementation

Create:

### `js/message.js`

```javascript
"use strict";

export function getMessage() {
  return "Hello from a module.";
}
```

Replace `js/main.js`:

### `js/main.js`

```javascript
"use strict";

import { getMessage } from "./message.js";

console.log(getMessage());
```

Update the script tag in `index.html`:

```html
<script type="module" src="./js/main.js"></script>
```

## The Verification

Refresh:

```text
http://localhost:8000
```

The console should show:

```text
Hello from a module.
```

Now open the page directly from the filesystem if you can, using a `file://` URL.

The module may fail because browser security rules restrict local module loading.

Return to:

```text
http://localhost:8000
```

Delete `js/message.js` after testing, and restore `js/main.js` when the main series begins.

[COMPLETED: Step 11 — Browser ES module loading verified]  
[STARTING: Step 12 — Inspect project files from the terminal]

---

# 12. Inspect Files from the Terminal

## The Target

Use terminal commands to inspect the project without opening each file manually.

## The Concept

Terminal inspection is useful when:

- You need to confirm a file exists.
- You need to search a directory.
- You need to verify a path.
- You need to compare expected and actual structure.
- You are troubleshooting a module import.

## The Implementation

### macOS or Linux

List all project files:

```bash
find . -maxdepth 4 -type f
```

Search for a string:

```bash
grep -R "main.js" .
```

Display a file:

```bash
cat index.html
```

### Windows PowerShell

List all project files:

```powershell
Get-ChildItem -Recurse -File
```

Search for a string:

```powershell
Select-String -Path .\* -Pattern "main.js" -Recurse
```

Display a file:

```powershell
Get-Content index.html
```

## The Verification

Confirm that:

- `index.html` exists.
- `styles.css` exists.
- `js/main.js` exists.
- Any temporary module file has been removed.

[COMPLETED: Step 12 — Project inspected from the terminal]  
[STARTING: Step 13 — Use a reliable save, serve, and verify cycle]

---

# 13. The Development Cycle

## The Target

Practice the cycle used throughout the series.

## The Concept

A reliable development cycle is:

```text
Edit
  ↓
Save
  ↓
Serve
  ↓
Open or refresh
  ↓
Inspect
  ↓
Verify
```

This prevents confusion between:

- Code that was not saved.
- Code that was not loaded.
- Code that ran but produced the wrong result.
- Code that failed before reaching the expected line.

## The Implementation

Change `js/main.js`:

```javascript
"use strict";

console.log("Development cycle test: version 1.");
```

Save it.

Refresh the browser.

Change it to:

```javascript
"use strict";

console.log("Development cycle test: version 2.");
```

Save it.

Refresh again.

## The Verification

The console should first show:

```text
Development cycle test: version 1.
```

After the second save and refresh, it should show:

```text
Development cycle test: version 2.
```

If it does not:

1. Confirm the file was saved.
2. Confirm the browser URL is correct.
3. Confirm the server is running from the correct directory.
4. Check the Network panel.
5. Perform a hard refresh.

[COMPLETED: Step 13 — Edit, save, serve, and verify cycle practiced]  
[STARTING: Step 14 — Diagnose common local-server problems]

---

# 14. Diagnose Common Server Problems

## The Target

Recognize and fix common local-development failures.

## Problem: Port Already in Use

You may see an error indicating that port `8000` is already occupied.

Use another port:

```bash
python3 -m http.server 8080
```

Open:

```text
http://localhost:8080
```

## Problem: The Wrong Page Appears

The server serves the directory where it was started.

Stop it:

```text
Ctrl + C
```

Move into the project:

```bash
cd path/to/async-task-manager
```

Start again:

```bash
python3 -m http.server 8000
```

## Problem: Directory Listing Appears

A directory listing means the server is running but the current directory may not contain the expected `index.html`.

Check:

```bash
ls
```

or:

```powershell
Get-ChildItem
```

## Problem: Module Import Fails

Check:

```html
<script type="module" src="./js/main.js"></script>
```

Then inspect the import:

```javascript
import { Task } from "./models/task.js";
```

Confirm that:

- The file exists.
- The path is relative to the importing file.
- The `.js` extension is included.
- Capitalization matches exactly.

## Problem: Changes Do Not Appear

Try:

```text
Ctrl + Shift + R
```

or:

```text
Cmd + Shift + R
```

Also verify that the Network panel is not serving an unexpected cached file.

[COMPLETED: Step 14 — Local-server troubleshooting practiced]  
[STARTING: Step 15 — Optional Git checkpoint]

---

# 15. Create a Git Checkpoint

## The Target

Save the current project state in version control.

## The Concept

Git records changes to files over time.

A commit is a checkpoint. If a later tutorial step breaks the application, you can compare or restore an earlier checkpoint.

Git is optional for following the series, but useful for real development.

## The Implementation

From the project root:

```bash
git init
```

Create a `.gitignore` file:

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

Check the repository:

```bash
git status
```

Add the project files:

```bash
git add .
```

Create a commit:

```bash
git commit -m "Prepare local development project"
```

## The Verification

Run:

```bash
git status
```

You should see a clean working tree similar to:

```text
nothing to commit, working tree clean
```

If Git asks for your identity, configure it:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Only use an email address you are comfortable associating with your commits.

[COMPLETED: Step 15 — Optional Git checkpoint created]  
[STARTING: Primer 3 Reference — Command and workflow quick reference]

---

# Terminal Quick Reference

## Current Directory

### macOS/Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

## List Files

### macOS/Linux

```bash
ls
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem
Get-ChildItem -Force
```

## Change Directory

```bash
cd directory-name
cd ..
```

## Create Directory

### macOS/Linux

```bash
mkdir directory-name
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path directory-name
```

## Create File

### macOS/Linux

```bash
touch filename.js
```

### Windows PowerShell

```powershell
New-Item -ItemType File -Path filename.js
```

## Display File Contents

### macOS/Linux

```bash
cat filename.js
```

### Windows PowerShell

```powershell
Get-Content filename.js
```

## Start Local Server

### macOS/Linux

```bash
python3 -m http.server 8000
```

### Windows PowerShell

```powershell
python -m http.server 8000
```

## Stop Local Server

```text
Ctrl + C
```

## Open Project in VS Code

```bash
code .
```

## Git Checkpoint

```bash
git init
git add .
git commit -m "Describe the checkpoint"
git status
```

---

# Recommended Project Workflow

Use this routine whenever you work on the application:

```text
1. Open a terminal.
2. Navigate to the project directory.
3. Confirm the current directory.
4. Open the project in the editor.
5. Start the local server.
6. Open the localhost URL.
7. Make one focused change.
8. Save the file.
9. Refresh the browser.
10. Read the console.
11. Verify the expected behavior.
12. Commit a checkpoint when stable.
```

Example:

```bash
cd ~/projects/async-task-manager
code .
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

---

# Primer 3 Completion Checklist

Before beginning Part 0, confirm that you can:

- [ ] Open a terminal.
- [ ] Display the current directory.
- [ ] List directory contents.
- [ ] Create directories.
- [ ] Create files.
- [ ] Move between directories.
- [ ] Open the project in an editor.
- [ ] Read a file from the terminal.
- [ ] Start a local HTTP server.
- [ ] Stop a local server.
- [ ] Change the server port.
- [ ] Explain `localhost`.
- [ ] Explain a port number.
- [ ] Use relative file paths.
- [ ] Load an ES module through HTTP.
- [ ] Inspect project files from the terminal.
- [ ] Diagnose a wrong-directory server problem.
- [ ] Diagnose a missing-file problem.
- [ ] Diagnose a module-path problem.
- [ ] Use a save, serve, refresh, and verify cycle.
- [ ] Create an optional Git checkpoint.
