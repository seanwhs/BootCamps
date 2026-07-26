# Appendix A: Installation and Tooling

This appendix explains how to prepare your computer for the JavaScript Foundations series.

You will install or verify:

- A modern web browser.
- A code editor.
- A terminal.
- Optional local development tools.
- A project directory.
- Browser developer tools.

The goal is simple: by the end, you should be able to open the task application in a browser, edit a JavaScript file, refresh the page, and inspect errors in the console.

---

## A.1 Required Tools

You need three essential tools.

### 1. A modern browser

Recommended browsers:

- Google Chrome.
- Mozilla Firefox.
- Microsoft Edge.
- Safari on macOS.

The browser runs your HTML, CSS, and JavaScript. It also provides Developer Tools for inspecting pages and debugging code.

### 2. A code editor

Recommended editor:

- Visual Studio Code.

Alternatives include:

- Sublime Text.
- WebStorm.
- Notepad++.
- Any editor that saves plain-text files.

Avoid writing JavaScript in a word processor such as Microsoft Word. Word processors may insert formatting characters that do not belong in source code.

### 3. A terminal

A terminal lets you run commands that create directories, inspect files, and start local development servers.

Common terminal applications:

| Operating system | Common terminal |
|---|---|
| Windows | PowerShell or Windows Terminal |
| macOS | Terminal |
| Linux | Terminal |

You do not need advanced terminal knowledge for this series.

---

# A.2 Install a Browser

## Target

Install or verify a modern browser.

## Concept

The browser is the runtime environment for this series. A runtime environment is the software that executes your code.

Your JavaScript file does not run by itself. The browser loads it through HTML:

```html
<script src="./src/part-4.js" defer></script>
```

## Implementation

Download a browser from an official source:

- Chrome: `https://www.google.com/chrome/`
- Firefox: `https://www.mozilla.org/firefox/`
- Edge: `https://www.microsoft.com/edge`
- Safari: included with macOS and updated through system updates.

Choose one browser as your primary development browser. Chrome, Firefox, and Edge all provide the tools required by this series.

## Verification

Open your browser and visit:

```text
https://example.com
```

Then open Developer Tools:

### Chrome or Edge

Windows/Linux:

```text
F12
```

or:

```text
Ctrl + Shift + J
```

macOS:

```text
Cmd + Option + J
```

### Firefox

Windows/Linux:

```text
F12
```

or:

```text
Ctrl + Shift + K
```

macOS:

```text
Cmd + Option + K
```

You should see a panel containing a **Console** tab.

Test the console by entering:

```js
2 + 3
```

Press Enter.

Expected result:

```text
5
```

If you see `5`, your browser can execute JavaScript.

[COMPLETED: Browser installation verified]  
[NEXT: Install a code editor]

---

# A.3 Install Visual Studio Code

## Target

Install Visual Studio Code and use it to open the tutorial project.

## Concept

A code editor is designed to work with source files. It provides:

- Syntax highlighting.
- Indentation.
- Search.
- File navigation.
- Error highlighting.
- Integrated terminal support.

Syntax highlighting colors different parts of code so that strings, numbers, keywords, and comments are easier to recognize.

## Implementation

Download Visual Studio Code from:

```text
https://code.visualstudio.com/
```

Install it using the default options.

After installation, open Visual Studio Code.

You should see a welcome screen or an empty editor window.

### Recommended extensions

Extensions are optional add-ons for Visual Studio Code.

Open the Extensions panel:

- Click the square-shaped Extensions icon.
- Or use:

```text
Ctrl + Shift + X
```

on Windows/Linux, or:

```text
Cmd + Shift + X
```

on macOS.

Useful extensions include:

- **Live Server** by Ritwick Dey.
- **Prettier - Code formatter**.
- **ESLint**.

For this introductory series, only Live Server is immediately useful. Prettier and ESLint become more valuable as the project grows.

### Install Live Server

Search for:

```text
Live Server
```

Install the extension published by:

```text
Ritwick Dey
```

Verify that the publisher name is correct before installing extensions.

## Verification

Create a temporary file:

### `hello.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Tooling Test</title>
  </head>

  <body>
    <h1>Tooling works</h1>
  </body>
</html>
```

Save the file.

Right-click inside the editor and choose:

```text
Open with Live Server
```

A browser window should open with a local address similar to:

```text
http://127.0.0.1:5500/hello.html
```

or:

```text
http://localhost:5500/hello.html
```

The page should display:

```text
Tooling works
```

Delete `hello.html` after the test.

[COMPLETED: Code editor and Live Server verified]  
[NEXT: Create the project directory]

---

# A.4 Create the Project Directory

## Target

Create the project directory:

```text
javascript-foundations
```

Inside it, create:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
```

## Concept

A project directory is a dedicated container for related files.

Keeping project files together makes paths predictable:

```text
index.html
```

can load:

```text
./styles.css
```

and:

```text
./src/part-4.js
```

The `./` means:

> Start from the current directory.

## Implementation: Windows PowerShell

Open PowerShell and run:

```powershell
New-Item -ItemType Directory -Path javascript-foundations
Set-Location javascript-foundations
New-Item -ItemType Directory -Path src
New-Item -ItemType File -Path index.html
New-Item -ItemType File -Path styles.css
```

Verify the structure:

```powershell
Get-ChildItem
Get-ChildItem .\src
```

Expected output should include:

```text
index.html
styles.css
src
```

The `src` directory should be empty at this point.

## Implementation: macOS or Linux

Open Terminal and run:

```bash
mkdir -p javascript-foundations/src
cd javascript-foundations
touch index.html
touch styles.css
```

Verify the structure:

```bash
ls
ls src
```

Expected output should include:

```text
index.html
styles.css
src
```

## Open the Project in Visual Studio Code

From inside the `javascript-foundations` directory, run:

```bash
code .
```

On Windows PowerShell:

```powershell
code .
```

If the `code` command is unavailable:

1. Open Visual Studio Code manually.
2. Choose **File**.
3. Choose **Open Folder**.
4. Select the `javascript-foundations` directory.

The Explorer panel should show:

```text
javascript-foundations
├── index.html
├── styles.css
└── src
```

[COMPLETED: Project directory created]  
[NEXT: Add a minimal browser test]

---

# A.5 Run a Minimal Browser Test

## Target

Confirm that HTML, CSS, and JavaScript are connected correctly.

## Concept

Before building the full application, test the three layers separately:

```text
HTML       → page structure
CSS        → appearance
JavaScript → behavior
```

This small test prevents you from debugging several missing pieces at once.

## Implementation

### `index.html`

Replace the empty file with:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Tooling Test</title>

    <link rel="stylesheet" href="./styles.css" />
  </head>

  <body>
    <main>
      <h1 id="heading">Tooling test</h1>

      <p id="message">
        JavaScript has not run yet.
      </p>
    </main>

    <script src="./src/tooling-test.js" defer></script>
  </body>
</html>
```

### `styles.css`

Replace the empty file with:

```css
body {
  margin: 2rem;
  color: #172033;
  background: #eef2f7;
  font-family: system-ui, sans-serif;
}

h1 {
  color: #2457a6;
}
```

### `src/tooling-test.js`

Create this file:

```js
"use strict";

const headingElement = document.querySelector("#heading");
const messageElement = document.querySelector("#message");

if (headingElement === null) {
  throw new Error("Could not find the #heading element.");
}

if (messageElement === null) {
  throw new Error("Could not find the #message element.");
}

headingElement.textContent = "Tooling test passed";
messageElement.textContent =
  "HTML, CSS, and JavaScript are connected.";
```

Your project should now look like this:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
    └── tooling-test.js
```

## Verification

Open `index.html` with Live Server.

The page should display:

```text
Tooling test passed
HTML, CSS, and JavaScript are connected.
```

The heading should be blue, confirming that CSS loaded.

Open the browser console. It should contain no red errors.

[COMPLETED: Minimal HTML, CSS, and JavaScript test passed]  
[NEXT: Understand local development URLs]

---

# A.6 Understand Local Development URLs

## Target

Learn to recognize local development addresses.

## Concept

A local development server serves files from your own computer. It is not the same as publishing the application to the internet.

Common local addresses include:

```text
http://localhost:5500
```

and:

```text
http://127.0.0.1:5500
```

Both usually refer to your own computer.

### `localhost`

`localhost` is a readable name for the current computer.

### `127.0.0.1`

`127.0.0.1` is the IPv4 loopback address. It also points back to the current computer.

### Port numbers

The number after the colon is a port:

```text
:5500
```

A port identifies a specific network service running on your computer.

For example:

```text
http://localhost:5500/index.html
```

means:

```text
protocol: http
host:     localhost
port:     5500
file:     index.html
```

## Verification

While Live Server is running, inspect the browser address bar.

You should see a URL resembling:

```text
http://127.0.0.1:5500/index.html
```

or:

```text
http://localhost:5500/index.html
```

Stop Live Server by:

- Closing the browser tab and choosing **Stop Live Server** from the VS Code status bar, or
- Right-clicking the page and selecting **Stop Live Server**.

Refresh the page.

It may no longer load. That is expected because the local server has stopped.

Start Live Server again and verify that the page returns.

[COMPLETED: Local development URL understood]  
[NEXT: Optional terminal-based server]

---

# A.7 Optional: Run a Server with Python

Live Server is convenient, but an additional option is Python’s built-in HTTP server.

This is useful when:

- Live Server is unavailable.
- You want to understand how a local server works.
- You prefer using the terminal.

## Target

Serve the project directory using Python.

## Concept

A static server sends files to the browser without running backend application logic.

The browser requests:

```text
/index.html
```

The server responds with the contents of:

```text
index.html
```

## Verification: Check Python

Run:

```bash
python --version
```

If that command does not work, try:

```bash
python3 --version
```

On Windows, also try:

```powershell
py --version
```

A successful result resembles:

```text
Python 3.12.0
```

## Implementation: macOS/Linux

From the project directory, run:

```bash
python3 -m http.server 8000
```

## Implementation: Windows

From the project directory, run:

```powershell
py -m http.server 8000
```

If `py` is unavailable, try:

```powershell
python -m http.server 8000
```

## Verification

Open:

```text
http://localhost:8000
```

The browser should display the project’s `index.html`.

Stop the server with:

```text
Ctrl + C
```

The terminal should return to the command prompt.

[COMPLETED: Optional Python development server documented]  
[NEXT: Learn browser Developer Tools]

---

# A.8 Browser Developer Tools

## Target

Learn the main Developer Tools panels used throughout the series.

## Concept

Developer Tools are the browser’s inspection and debugging workspace.

The most important panels are:

- Console.
- Elements or Inspector.
- Sources or Debugger.
- Network.
- Application or Storage.

## Console

The Console displays:

- `console.log` output.
- Warnings.
- Errors.
- Values you inspect manually.

Example:

```js
console.log("Application started.");
```

The console displays:

```text
Application started.
```

### Console error example

Add this temporarily to `src/tooling-test.js`:

```js
const missingValue = unknownVariable;
```

Refresh the page.

You should see an error similar to:

```text
ReferenceError: unknownVariable is not defined
```

This means JavaScript tried to use a name that does not exist in the accessible scope.

Remove the temporary line.

## Elements or Inspector

This panel shows the current DOM, including changes made by JavaScript.

If JavaScript creates:

```js
const item = document.createElement("li");
```

and appends it to the page, the element appears in the Elements panel.

Use this panel to inspect:

- Text content.
- Attributes.
- Classes.
- `data-*` attributes.
- Parent and child relationships.

## Sources or Debugger

This panel shows loaded source files.

You can:

- Open `part-4.js`.
- Add breakpoints.
- Pause execution.
- Inspect variables.
- Step through code.

A **breakpoint** pauses the program at a selected line. It is useful when you want to inspect the program’s state during an event.

## Network

This panel displays files requested by the browser.

Use it to diagnose:

- Missing JavaScript files.
- Missing CSS files.
- Incorrect paths.
- HTTP errors.
- Slow requests.

A missing file commonly produces:

```text
404 Not Found
```

## Application or Storage

This panel can inspect browser storage, including `localStorage`.

The current series does not yet persist data, but this panel will become useful when the application adds storage.

[COMPLETED: Developer Tools overview completed]  
[NEXT: Common setup problems]

---

# A.9 Common Setup Problems

## Problem 1: The JavaScript file does not run

Check the script path:

```html
<script src="./src/tooling-test.js" defer></script>
```

Confirm the file is exactly:

```text
src/tooling-test.js
```

Common mistakes:

```text
src/tooling-test .js
src/Tooling-test.js
src/tooling-test.jsx
src/tooling-test.js.txt
```

File names and paths may be case-sensitive.

---

## Problem 2: The browser shows a blank page

Inspect the console.

A syntax error may prevent the entire script from running:

```text
SyntaxError: missing ) after argument list
```

Check:

- Parentheses.
- Braces.
- Square brackets.
- Quotation marks.
- Commas.
- Backticks.

Example of incorrect code:

```js
console.log("Hello";
```

Correct version:

```js
console.log("Hello");
```

---

## Problem 3: `document.querySelector()` returns `null`

Example:

```js
const buttonElement =
  document.querySelector("#submit-button");

buttonElement.textContent = "Submit";
```

If the HTML does not contain:

```html
<button id="submit-button"></button>
```

then `buttonElement` is `null`.

The selector and HTML ID must match exactly:

```html
<button id="submit-button">Submit</button>
```

```js
document.querySelector("#submit-button");
```

---

## Problem 4: CSS does not load

Check the HTML link:

```html
<link rel="stylesheet" href="./styles.css" />
```

Confirm that `styles.css` is next to `index.html`:

```text
javascript-foundations/
├── index.html
└── styles.css
```

This path would be incorrect if the file is in the project root:

```html
<link rel="stylesheet" href="./src/styles.css" />
```

---

## Problem 5: Changes do not appear

Try a normal refresh:

```text
Ctrl + R
```

or:

```text
Cmd + R
```

If the browser appears to use an old version:

- Open Developer Tools.
- Hold the reload button.
- Choose **Empty Cache and Hard Reload**, if available.

Also verify that you edited the file being served by Live Server.

---

## Problem 6: Live Server does not open the correct file

Make sure you opened the project folder, not an unrelated parent directory.

Correct:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
```

Then right-click the correct `index.html` and select:

```text
Open with Live Server
```

---

## Problem 7: The file is accidentally saved as `.txt`

Some operating systems hide file extensions.

A file that appears to be:

```text
part-4.js
```

may actually be:

```text
part-4.js.txt
```

Check the full file name in Visual Studio Code’s Explorer or your operating system’s file manager.

---

## Problem 8: `code .` does not work

If the terminal says that `code` is not recognized:

1. Open Visual Studio Code manually.
2. Select **File → Open Folder**.
3. Choose `javascript-foundations`.

You can configure the terminal command later. It is not required for this series.

---

# A.10 Recommended Editor Settings

These settings make source code easier to read.

Open Visual Studio Code settings and enable:

- Format On Save.
- Render Whitespace.
- Word Wrap.
- Auto Save, if preferred.
- Insert Spaces.
- Tab Size: `2`.

A project-level configuration can be stored in:

```text
.vscode/settings.json
```

Create the `.vscode` directory and file:

### `.vscode/settings.json`

```json
{
  "editor.formatOnSave": true,
  "editor.wordWrap": "on",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
```

These settings do not change how JavaScript executes. They make the files more consistent and readable.

## Verification

Save a JavaScript file with inconsistent spacing:

```js
const message="Hello";
console.log(message);
```

If a formatter is installed and configured, saving may produce:

```js
const message = "Hello";

console.log(message);
```

Do not install a formatter you do not trust. Use well-known extensions from verified publishers.

[COMPLETED: Editor settings documented]  
[NEXT: Final tooling verification]

---

# A.11 Final Tooling Verification

Run through this checklist before starting Part 1.

## Project structure

Confirm:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
    └── tooling-test.js
```

## Browser

Confirm that:

- The page opens in a modern browser.
- Developer Tools open.
- The Console tab is visible.
- Entering `2 + 3` produces `5`.

## HTML

Confirm that:

- The page displays the test heading.
- The page displays the test message.

## CSS

Confirm that:

- The heading is blue.
- The page has a light background.
- The page has spacing around the content.

## JavaScript

Confirm that:

- The text changes from “Tooling test” to “Tooling test passed.”
- The console has no red errors.

## Local server

Confirm that the page opens at an address resembling:

```text
http://localhost:5500/index.html
```

or:

```text
http://localhost:8000/index.html
```

## Cleanup

Once the test succeeds, delete:

```text
src/tooling-test.js
```

The final project will then be ready for the series:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
```

The tutorial parts will provide the appropriate JavaScript file as needed.

---

# Appendix A Summary

You now know how to:

- Install a modern browser.
- Open browser Developer Tools.
- Install Visual Studio Code.
- Create a project directory.
- Open a project in the editor.
- Run the project with Live Server.
- Run an optional Python local server.
- Inspect the DOM.
- Read console errors.
- Diagnose missing files.
- Verify HTML, CSS, and JavaScript connections.
