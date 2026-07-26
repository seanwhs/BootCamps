# Student Notes  
## PowerShell, Node.js, Runtime Configuration, and Python CLI Development

**Student:** ___________________________________________

**Course dates:** ______________________________________

**Instructor:** ________________________________________

---

# How to Use These Notes

These notes accompany the tutorial series and slide deck. They are a concise study reference rather than a replacement for the hands-on exercises.

Use them to:

- Review terminology
- Annotate demonstrations
- Record commands
- Prepare for quizzes
- Troubleshoot laboratories
- Review the final architecture

The most important course habit is:

```text
Understand → Execute → Verify
```

For potentially destructive filesystem work, use:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

---

# Part 0: Series Orientation

## What This Series Builds

The series develops two practical projects:

1. A Node.js HTTP service
2. A Python command-line task manager

PowerShell provides the developer workflow around both projects.

## Architectural Layers

```text
PowerShell filesystem operations
                ↓
Runtime and package tools
                ↓
Project automation and tests
                ↓
Runtime configuration
                ↓
Developer profile conveniences
```

Each layer depends on the layer beneath it.

## Learning Method

Every technical exercise follows four stages:

### The Target

What file, configuration, or feature is being created?

### The Concept

Why does it exist, and how does it work?

### The Implementation

What complete commands or files create it?

### The Verification

How can we prove that it worked?

## Key Expectations

- Use normal user privileges unless elevation is specifically required.
- Run commands inside named tutorial laboratories.
- Never use real production secrets in examples.
- Read commands before executing them.
- Verify every significant change.
- Use official documentation for version-specific behavior.

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Primer 1: Reading PowerShell Commands

## Cmdlet Naming

Native PowerShell commands normally use:

```text
Verb-Noun
```

Examples:

```powershell
Get-Location
Set-Location
Get-ChildItem
New-Item
Copy-Item
Move-Item
Remove-Item
```

The verb describes the action. The noun describes the resource.

## Command Anatomy

```powershell
Get-ChildItem -Path .\src -File -Recurse
```

| Component | Meaning |
|---|---|
| `Get-ChildItem` | Command |
| `-Path` | Named parameter |
| `.\src` | Parameter value |
| `-File` | Switch parameter |
| `-Recurse` | Switch parameter |

A switch is enabled by being present.

## Aliases

Aliases are short names for commands.

| Alias | Native command |
|---|---|
| `pwd` | `Get-Location` |
| `cd` | `Set-Location` |
| `dir` | `Get-ChildItem` |
| `ls` | `Get-ChildItem` |
| `cp` | `Copy-Item` |
| `mv` | `Move-Item` |
| `rm` | `Remove-Item` |

Inspect an alias:

```powershell
Get-Alias -Name ls
Get-Command -Name ls
```

Use aliases interactively if desired. Prefer native names in scripts and documentation.

## Variables

PowerShell variables begin with `$`:

```powershell
$projectRoot = Join-Path `
    -Path $HOME `
    -ChildPath "example-project"
```

Variables can contain:

- Strings
- Numbers
- Booleans
- Arrays
- Hashtables
- File objects
- Command results

## Strings

Double quotes expand variables:

```powershell
$name = "Ada"
"Hello, $name"
```

Result:

```text
Hello, Ada
```

Single quotes preserve text literally:

```powershell
'Hello, $name'
```

Result:

```text
Hello, $name
```

## Arrays

```powershell
$extensions = @(
    ".txt"
    ".json"
    ".md"
)
```

Read an element:

```powershell
$extensions[0]
```

Count elements:

```powershell
$extensions.Count
```

## Hashtables

```powershell
$parameters = @{
    LiteralPath = ".\src"
    File = $true
    Recurse = $true
}
```

Use the hashtable as command parameters through **splatting**:

```powershell
Get-ChildItem @parameters
```

## Objects and Properties

PowerShell normally returns structured objects.

```powershell
$file = Get-Item -LiteralPath .\package.json
```

Read properties:

```powershell
$file.Name
$file.Length
$file.Extension
$file.FullName
```

Inspect all available properties and methods:

```powershell
$file | Get-Member
```

## Pipelines

The pipeline operator is:

```text
|
```

It passes objects from one command to another:

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 100
    } |
    Sort-Object -Property Length -Descending |
    Select-Object Name, Length
```

Pipeline stages:

1. Retrieve file objects.
2. Keep files larger than 100 bytes.
3. Sort by size.
4. Return selected properties.

Inside a pipeline script block:

```powershell
$_
```

means the current object.

## Common Operators

| Operator | Meaning |
|---|---|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-gt` | Greater than |
| `-ge` | Greater than or equal |
| `-lt` | Less than |
| `-le` | Less than or equal |
| `-like` | Wildcard match |
| `-match` | Regular-expression match |
| `-in` | Value appears in collection |
| `-and` | Both conditions are true |
| `-or` | At least one condition is true |
| `-not` | Negation |

## Discovery Commands

```powershell
Get-Command -Name Get-ChildItem
Get-Help -Name Get-ChildItem
Get-Help -Name Get-ChildItem -Examples
Get-Help -Name Get-ChildItem -Parameter Recurse
Get-Member
```

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Primer 2: Filesystem Safety

## The Safety Sequence

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

## 1. Locate

```powershell
Get-Location
```

Relative paths depend on the current location.

## 2. Resolve

```powershell
$resolvedTarget = (
    Resolve-Path `
        -LiteralPath $target `
        -ErrorAction Stop
).Path
```

Resolution converts an existing path into an explicit location.

## 3. Inspect

```powershell
Get-Item `
    -LiteralPath $resolvedTarget `
    -Force

Get-ChildItem `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -Force
```

Check:

- Exact path
- File or directory
- Hidden items
- Number of descendants
- Reparse points or links
- Whether unrelated resources are nearby

## 4. Preview

```powershell
Remove-Item `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -WhatIf
```

`-WhatIf`:

- Describes a supported change
- Does not execute it
- Does not create a backup
- Does not guarantee later success
- Does not provide an undo operation

## 5. Execute

```powershell
Remove-Item `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -ErrorAction Stop
```

## 6. Verify

```powershell
Test-Path -LiteralPath $resolvedTarget
```

Also verify that unrelated resources survived.

## `-Path` Versus `-LiteralPath`

Use `-Path` when wildcards are intentional:

```powershell
Get-ChildItem `
    -Path .\incoming\*.csv
```

Use `-LiteralPath` for one exact target:

```powershell
Get-Item `
    -LiteralPath .\incoming\records.csv
```

## `-Recurse`

`-Recurse` processes descendants.

```powershell
Remove-Item `
    -LiteralPath $directory `
    -Recurse
```

It substantially increases the scope of an operation.

## `-Force`

`-Force` may help with:

- Hidden items
- Read-only items
- Some destination replacement behavior

It does not:

- Grant administrator rights
- Bypass all permissions
- Take ownership
- Unlock every file
- Create an undo point

## Wildcard Safety

Risky:

```powershell
Remove-Item -Path *.tmp
```

Safer:

```powershell
$targets = @(
    Get-ChildItem `
        -LiteralPath $directory `
        -Filter "*.tmp" `
        -File
)

$targets |
    Select-Object FullName

$targets |
    Remove-Item -WhatIf
```

After inspection:

```powershell
$targets |
    Remove-Item -ErrorAction Stop
```

## Destructive Command Warning

Treat this as dangerous:

```powershell
Remove-Item * -Recurse -Force
```

Risks:

- Broad wildcard
- Current-location dependency
- Recursive scope
- Hidden and read-only processing
- No visible approved boundary
- No preview
- Potentially permanent deletion

## Important Rule

`Remove-Item` generally does not send files to the Windows Recycle Bin.

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 1: Filesystem Navigation

## Path Vocabulary

| Syntax | Meaning |
|---|---|
| `.` | Current directory |
| `..` | Parent directory |
| `~` | Home directory |
| `$HOME` | Current user’s home path |
| `.\src` | `src` under the current directory |
| `C:\` | Root of the `C:` drive |

## Current Location

```powershell
Get-Location
```

Only the path string:

```powershell
(Get-Location).Path
```

## Navigate Home

```powershell
Set-Location -Path $HOME
```

Alias:

```powershell
cd ~
```

## Absolute Path

```powershell
Set-Location `
    -LiteralPath "C:\Projects\service"
```

An absolute path does not depend on current location.

## Relative Path

```powershell
Set-Location -Path .\src
Set-Location -Path ..
Set-Location -Path ..\test
```

## Paths with Spaces

```powershell
Set-Location `
    -LiteralPath "C:\Development Projects"
```

## Tab Completion

- `Tab`: move forward through candidates
- `Shift+Tab`: move backward

Use completion to reduce spelling errors.

## List Contents

```powershell
Get-ChildItem
```

Only files:

```powershell
Get-ChildItem -File
```

Only directories:

```powershell
Get-ChildItem -Directory
```

Include hidden items:

```powershell
Get-ChildItem -Force
```

## Recursive Listing

```powershell
Get-ChildItem `
    -LiteralPath $labRoot `
    -File `
    -Recurse
```

## Filtering

Provider-level filename filter:

```powershell
Get-ChildItem `
    -Path $labRoot `
    -Filter "*.json" `
    -File `
    -Recurse
```

Property-based filter:

```powershell
Get-ChildItem `
    -LiteralPath $labRoot `
    -File `
    -Recurse |
    Where-Object {
        $_.Extension -eq ".json"
    }
```

## Test Paths

Existing file:

```powershell
Test-Path `
    -LiteralPath .\package.json `
    -PathType Leaf
```

Existing directory:

```powershell
Test-Path `
    -LiteralPath .\src `
    -PathType Container
```

## Resolve Paths

```powershell
Resolve-Path `
    -LiteralPath .\src
```

## Location Stack

```powershell
Push-Location `
    -LiteralPath .\documents

Pop-Location
```

## Filesystem Drives

```powershell
Get-PSDrive -PSProvider FileSystem
```

Do not assume every computer has a `D:` drive.

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 2: File and Directory Management

## Create a Directory

```powershell
New-Item `
    -Path .\reports `
    -ItemType Directory
```

## Create Nested Directories

```powershell
New-Item `
    -Path .\workspace\data\raw `
    -ItemType Directory `
    -Force
```

## Create an Empty File

```powershell
New-Item `
    -Path .\README.md `
    -ItemType File
```

## Write Content

```powershell
Set-Content `
    -LiteralPath .\README.md `
    -Value "# Example Project" `
    -Encoding UTF8
```

`Set-Content` replaces existing content.

## Append Content

```powershell
Add-Content `
    -LiteralPath .\README.md `
    -Value "Additional information." `
    -Encoding UTF8
```

## Read Content

As lines:

```powershell
Get-Content `
    -LiteralPath .\README.md
```

As one string:

```powershell
Get-Content `
    -LiteralPath .\README.md `
    -Raw
```

## Copy a File

```powershell
Copy-Item `
    -LiteralPath .\source\report.txt `
    -Destination .\archive\report-copy.txt
```

The source remains.

## Copy a Directory Tree

```powershell
Copy-Item `
    -LiteralPath .\source `
    -Destination .\backup `
    -Recurse
```

## Rename

```powershell
Rename-Item `
    -LiteralPath .\old-name.txt `
    -NewName "new-name.txt"
```

`Rename-Item` changes the name within the same parent directory.

## Move

```powershell
Move-Item `
    -LiteralPath .\incoming\report.txt `
    -Destination .\archive\report.txt
```

## Move and Rename

```powershell
Move-Item `
    -LiteralPath .\incoming\report.txt `
    -Destination .\archive\report-processed.txt
```

## Delete a File

Preview:

```powershell
Remove-Item `
    -LiteralPath .\disposable.txt `
    -WhatIf
```

Execute:

```powershell
Remove-Item `
    -LiteralPath .\disposable.txt `
    -ErrorAction Stop
```

## Delete a Directory Tree

```powershell
Remove-Item `
    -LiteralPath .\disposable-directory `
    -Recurse `
    -WhatIf
```

After review:

```powershell
Remove-Item `
    -LiteralPath .\disposable-directory `
    -Recurse `
    -ErrorAction Stop
```

## Verify a Copy with SHA-256

```powershell
$sourceHash = (
    Get-FileHash `
        -LiteralPath $source `
        -Algorithm SHA256
).Hash

$destinationHash = (
    Get-FileHash `
        -LiteralPath $destination `
        -Algorithm SHA256
).Hash

$sourceHash -eq $destinationHash
```

## Error Handling

```powershell
try {
    Copy-Item `
        -LiteralPath $source `
        -Destination $destination `
        -ErrorAction Stop
}
catch {
    Write-Error (
        "Copy failed: " +
        $_.Exception.Message
    )
}
```

## Custom `-WhatIf` Support

```powershell
function Remove-ExampleItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string] $LiteralPath
    )

    if ($PSCmdlet.ShouldProcess(
        $LiteralPath,
        "Remove filesystem item"
    )) {
        Remove-Item `
            -LiteralPath $LiteralPath `
            -ErrorAction Stop
    }
}
```

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Primer 3: JavaScript and Node.js

## JavaScript Versus Node.js

- JavaScript is a programming language.
- Node.js is a runtime that executes JavaScript outside browsers.

Run JavaScript:

```powershell
node -e 'console.log("Hello");'
```

Run a file:

```powershell
node .\src\index.js
```

## Common Values

```javascript
const environment = "development";
const port = 3000;
const ready = true;
const missing = undefined;
const empty = null;
```

## `const` and `let`

Use `const` by default:

```javascript
const host = "127.0.0.1";
```

Use `let` for intentional reassignment:

```javascript
let count = 0;
count += 1;
```

`const` prevents reassignment. It does not deeply freeze an object.

## Arrays

```javascript
const environments = [
  "development",
  "test",
  "production",
];
```

## Objects

```javascript
const configuration = {
  environment: "development",
  host: "127.0.0.1",
  port: 3000,
};
```

Read properties:

```javascript
configuration.port
configuration["port"]
```

## Strict Equality

Use:

```javascript
===
```

Example:

```javascript
"3000" === 3000 // false
```

Avoid relying on loose conversion through `==`.

## Functions

```javascript
function buildAddress(host, port) {
  return `http://${host}:${port}`;
}
```

## CommonJS Modules

Export:

```javascript
module.exports = {
  buildAddress,
};
```

Import:

```javascript
const {
  buildAddress,
} = require("./address");
```

Use `./` for a nearby module.

## JSON

Convert an object into JSON text:

```javascript
const text = JSON.stringify(value);
```

Convert JSON text into a value:

```javascript
const value = JSON.parse(text);
```

JSON is data, not executable JavaScript.

## Promises

A Promise represents a future result.

```javascript
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}
```

## `async` and `await`

```javascript
async function main() {
  await delay(100);
  console.log("Finished");
}
```

An `async` function returns a Promise.

## Error Handling

```javascript
try {
  throw new Error("Invalid configuration.");
} catch (error) {
  console.error(error.message);
}
```

## Process Information

```javascript
process.pid
process.argv
process.env
process.cwd()
process.exitCode
```

Conventional exit codes:

```text
0       → success
nonzero → failure
```

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 3: npm and the Node.js Project Lifecycle

## Tool Responsibilities

| Tool | Responsibility |
|---|---|
| `node` | Executes JavaScript |
| `npm` | Manages packages and scripts |
| `npx` | Runs package executables |
| `pnpm` | Alternative package manager |

## Initialize a Project

```powershell
npm.cmd init -y
```

## `package.json`

Declares:

- Name and version
- Runtime requirements
- Dependencies
- Development dependencies
- Scripts
- Entry point

Example:

```json
{
  "name": "developer-service",
  "private": true,
  "scripts": {
    "test": "node --test",
    "build": "node scripts/build.js",
    "start": "node dist/index.js"
  }
}
```

## `package-lock.json`

Records the exact dependency tree selected by npm.

Normally commit:

```text
package.json
package-lock.json
```

## `node_modules`

Contains installed packages and transitive dependencies.

Normally ignore:

```text
node_modules/
```

## Runtime Dependency

```powershell
npm.cmd install express
```

Appears under:

```json
"dependencies"
```

## Development Dependency

```powershell
npm.cmd install --save-dev eslint
```

Appears under:

```json
"devDependencies"
```

## `npm install` Versus `npm ci`

| Behavior | `npm install` | `npm ci` |
|---|---:|---:|
| Add dependencies | Yes | No |
| Requires lockfile | No | Yes |
| May update lockfile | Yes | No |
| Clean reproducible install | Not necessarily | Yes |
| Removes existing `node_modules` first | Not necessarily | Yes |

## npm Scripts

```powershell
npm.cmd run lint
npm.cmd test
npm.cmd run build
npm.cmd start
npm.cmd run check
```

During scripts, npm adds:

```text
node_modules\.bin
```

to command resolution.

## Lifecycle Hooks

Given:

```json
{
  "scripts": {
    "prestart": "npm run build",
    "start": "node dist/index.js"
  }
}
```

Running:

```powershell
npm.cmd start
```

runs `prestart` before `start`.

## npx

Run a local package binary:

```powershell
npx.cmd eslint .
```

Temporary packages still execute with the current user’s permissions.

## PowerShell Execution Policy

Inspect:

```powershell
Get-ExecutionPolicy -List
Get-Command npm -All
```

If `npm.ps1` is blocked, try:

```powershell
npm.cmd --version
```

Do not weaken policy globally without justification.

## Quality Gate

```powershell
npm.cmd run check
```

Typical sequence:

```text
lint → tests → build → smoke test
```

With `&&`, a later stage runs only if the previous stage succeeds.

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# HTTP Service Notes

## Request Anatomy

```text
GET http://127.0.0.1:3000/health
│   │         │      │
│   │         │      └─ route
│   │         └──────── port
│   └────────────────── host
└────────────────────── method
```

## Common Methods

| Method | Typical purpose |
|---|---|
| `GET` | Retrieve |
| `POST` | Submit or create |
| `PUT` | Replace |
| `PATCH` | Partially update |
| `DELETE` | Remove |

Methods communicate intent. They do not provide authentication or authorization.

## Common Status Codes

| Status | Meaning |
|---:|---|
| `200` | Success |
| `201` | Created |
| `204` | Success with no body |
| `400` | Bad request |
| `401` | Authentication required or failed |
| `403` | Forbidden |
| `404` | Not found |
| `409` | Conflict |
| `413` | Request body too large |
| `500` | Internal server error |
| `503` | Service unavailable |

## Project Routes

```text
GET  /        → service information
GET  /health  → health information
POST /echo    → echoed JSON
*    unknown  → structured 404
```

## GET Request from PowerShell

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get
```

## POST JSON from PowerShell

```powershell
$body = @{
    message = "Hello"
    ready = $true
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

## Test Port `0`

A test server can use:

```javascript
server.listen(0, "127.0.0.1");
```

Port `0` asks the operating system to choose an available port.

## Graceful Shutdown

Common signals:

| Signal | Meaning |
|---|---|
| `SIGINT` | Interactive interruption, often `Ctrl+C` |
| `SIGTERM` | Termination request |

Graceful shutdown:

1. Stop accepting new work.
2. Close the server.
3. Finish cleanup.
4. Exit with the correct status.

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Primer 4: Processes and Environment Variables

## Process Model

```text
Windows environment
        ↓
PowerShell process
        ↓
Node.js or Python child process
```

The child receives a copy of its parent’s environment at startup.

A child cannot normally change its parent’s environment.

## Environment Provider

List variables:

```powershell
Get-ChildItem Env:
```

Read one:

```powershell
$env:PATH
Get-Item Env:PATH
```

## Set a Temporary Variable

```powershell
$env:PORT = "3000"
```

## Remove It

```powershell
Remove-Item `
    Env:PORT `
    -ErrorAction SilentlyContinue
```

Equivalent:

```powershell
$env:PORT = $null
```

## Process Scope

- Current process
- Future child processes
- Removed when the process exits

## User Scope

Persistent for newly created processes belonging to the user.

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "example-value",
    [System.EnvironmentVariableTarget]::User
)
```

Remove:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    $null,
    [System.EnvironmentVariableTarget]::User
)
```

Existing terminals do not automatically refresh.

## Machine Scope

- Broad persistent scope
- Often requires administrator access
- Avoid when process or user scope is sufficient

## Environment Values Are Strings

```javascript
process.env.PORT === "3000"
```

This is a common mistake:

```javascript
Boolean("false") === true
```

Explicit parsing is required.

## Configuration Versus Secrets

### Usually public operational configuration

```text
NODE_ENV
HOST
PORT
LOG_LEVEL
```

### Secrets

```text
APP_SECRET
API_TOKEN
DATABASE_PASSWORD
PRIVATE_KEY
```

Do not print secrets.

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 4: Runtime Configuration and Secrets

## `.env`

A local `.env` file may contain:

```dotenv
NODE_ENV=development
HOST=127.0.0.1
PORT=3000
APP_SECRET=a-random-local-secret
```

It is normally plaintext.

## `.env.example`

A safe template:

```dotenv
NODE_ENV=development
HOST=127.0.0.1
PORT=3000
APP_SECRET=replace-with-a-unique-secret
```

Never place a real secret in `.env.example`.

## Git Rules

```gitignore
.env
.env.*
!.env.example
```

`.gitignore` does not erase secrets already committed.

If a secret enters Git:

1. Treat it as compromised.
2. Revoke or rotate it.
3. Replace it in active systems.
4. Remove it from current files.
5. Follow approved history-cleanup procedures.
6. Inspect logs, artifacts, and backups.

## Configuration Precedence

With:

```javascript
dotenv.config({
  override: false,
});
```

priority is:

```text
1. Existing process environment
2. .env fallback
3. Validation failure if required data remains missing
```

## Validation Boundary

Raw external input:

```text
PORT="3000"
```

Validated application value:

```javascript
port: 3000
```

The application should reject:

- Missing required values
- Empty values
- Invalid runtime modes
- Nonnumeric ports
- Ports outside `1`–`65535`
- Missing secrets
- Short production secrets
- Placeholder secrets

## Unsafe Fallback

Avoid:

```javascript
const port = Number(process.env.PORT) || 3000;
```

This hides invalid input.

## Public Configuration

Private configuration:

```javascript
{
  environment,
  host,
  port,
  appSecret,
  isProduction
}
```

Public projection:

```javascript
{
  environment,
  host,
  port,
  isProduction
}
```

Omit the secret instead of printing it or copying the entire environment.

## PowerShell Profile

Inspect profile paths:

```powershell
$PROFILE |
    Format-List *
```

Reload:

```powershell
. $PROFILE.CurrentUserCurrentHost
```

Start without profiles:

```powershell
pwsh -NoProfile
```

Appropriate profile content:

- Navigation functions
- Quality-check functions
- General aliases
- Prompt preferences

Inappropriate profile content:

- Passwords
- Tokens
- Private keys
- `APP_SECRET`
- Global project runtime mode

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 5: Compressed Daily Workflow

## Node.js Project

Enter the project:

```powershell
devservice
```

Install exact dependencies:

```powershell
npm.cmd ci
```

Run all checks:

```powershell
npm.cmd run check
```

Display public configuration:

```powershell
npm.cmd run config
```

Start development mode:

```powershell
npm.cmd run dev
```

Run the production-style test:

```powershell
& .\scripts\Test-ProductionService.ps1
```

## Filesystem Safety Reminder

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

## Temporary Configuration Pattern

```powershell
$previousPort = $env:PORT

try {
    $env:PORT = "3200"

    npm.cmd run config
}
finally {
    if ($null -eq $previousPort) {
        Remove-Item `
            Env:PORT `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:PORT = $previousPort
    }
}
```

## Minimal Health Check

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health"
```

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 6: Python Runtime and Virtual Environments

## Discover Python

```powershell
Get-Command python, py -All `
    -ErrorAction SilentlyContinue

py --list
py -3 --version
```

## `py`, `python`, and `pip`

| Command | Role |
|---|---|
| `py` | Windows Python launcher |
| `python` | Resolved interpreter |
| `pip` | Resolved pip executable |
| `python -m pip` | pip belonging to a specific interpreter |

Prefer:

```powershell
python -m pip
```

over an ambiguous bare `pip`.

## Inspect the Interpreter

```powershell
python -c "import sys; print(sys.executable)"
```

## Create a Virtual Environment

```powershell
py -3 -m venv .venv
```

## Activate It

```powershell
.\.venv\Scripts\Activate.ps1
```

Activation primarily:

- Adds `.venv\Scripts` to `PATH`
- Sets `VIRTUAL_ENV`
- Updates the prompt

Activation is optional.

## Run Without Activation

```powershell
.\.venv\Scripts\python.exe --version

.\.venv\Scripts\python.exe `
    -m pip --version
```

## Install Development Tools

```powershell
python -m pip install --upgrade pip
python -m pip install build ruff
```

## Deactivate

```powershell
deactivate
```

## Execution-Policy Issue

If `Activate.ps1` is blocked:

- Use `.venv\Scripts\python.exe` directly.
- Inspect execution policy.
- Use a process-scoped change only when approved.
- Do not weaken machine policy globally.

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 6: Python Project Packaging

## Project Structure

```text
python-developer-cli/
├── .venv/
├── dist/
├── scripts/
├── src/
│   └── devtasks/
├── tests/
├── .gitignore
├── pyproject.toml
└── README.md
```

## `pyproject.toml`

Declares:

- Build system
- Package metadata
- Supported Python version
- Dependencies
- Console commands
- Package discovery
- Tool settings

## Build System

```toml
[build-system]
requires = ["setuptools>=69", "wheel"]
build-backend = "setuptools.build_meta"
```

## Project Metadata

```toml
[project]
name = "devtasks-cli"
version = "1.0.0"
requires-python = ">=3.11"
dependencies = []
```

## Console Command

```toml
[project.scripts]
devtasks = "devtasks.cli:main"
```

This maps:

```text
devtasks
```

to:

```text
devtasks.cli:main
```

## `src` Layout

```text
src/
└── devtasks/
    ├── __init__.py
    ├── __main__.py
    ├── cli.py
    ├── models.py
    └── storage.py
```

Benefits:

- Clear package boundary
- Tests use installed code
- Reduced accidental current-directory imports

## Editable Installation

```powershell
python -m pip install --editable .
```

Useful during development.

## Build Distributions

```powershell
python -m build
```

Expected artifacts:

```text
dist/
├── devtasks_cli-1.0.0-py3-none-any.whl
└── devtasks_cli-1.0.0.tar.gz
```

## Wheel Test

A clean wheel test verifies the built artifact rather than the editable source.

```text
editable install
      ↓
development and tests
      ↓
build wheel
      ↓
clean-environment install
      ↓
smoke test
```

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 6: Python CLI Architecture

## CLI Commands

```text
devtasks add "Write documentation"
devtasks list
devtasks list --status open
devtasks list --status completed
devtasks list --json
devtasks complete 1
devtasks remove 1
devtasks clear --completed
devtasks config
```

## `argparse`

Provides:

- Help text
- Positional arguments
- Optional arguments
- Subcommands
- Choices
- Type conversion
- Usage errors

## Data Model

Each task contains:

```text
id
title
completed
created_at
completed_at
```

## Validation

The model validates:

- Positive integer ID
- Nonempty title
- Title length
- Completion Boolean
- Timestamp fields

Type hints document expected types, but external input still requires runtime validation.

## JSON Storage

Document shape:

```json
{
  "schema_version": 1,
  "tasks": []
}
```

The storage layer validates:

- Document type
- Schema version
- Task list
- Task field types
- Duplicate IDs

## Atomic Replacement

```text
Serialize complete document
        ↓
Write temporary file
        ↓
Flush and close
        ↓
Replace destination
```

This reduces partial-write risk.

It is not a substitute for:

- Database transactions
- Multi-process locking
- Backups
- Encryption

## Runtime Data Location

Default:

```text
$HOME\.devtasks\tasks.json
```

Temporary override:

```powershell
$env:DEVTASKS_DATA_DIR = "$env:TEMP\devtasks-demo"
```

Restore or remove it afterward.

## CLI Exit Codes

| Code | Meaning |
|---:|---|
| `0` | Success |
| `1` | Storage or runtime failure |
| `2` | Input, usage, or missing-task error |

Inspect immediately:

```powershell
devtasks remove 999
$LASTEXITCODE
```

## Machine-Readable Output

```powershell
$taskJson = devtasks list --json

$tasks = $taskJson -join "`n" |
    ConvertFrom-Json
```

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 6: Python Testing and Quality

## Ruff Formatting

Check:

```powershell
python -m ruff format --check .
```

Preview changes:

```powershell
python -m ruff format --diff .
```

Apply formatting:

```powershell
python -m ruff format .
```

## Ruff Linting

```powershell
python -m ruff check .
```

Apply reviewed fixes:

```powershell
python -m ruff check --fix .
```

Rerun tests after automated changes.

## Compile All Source

```powershell
python -m compileall `
    -q `
    src `
    tests
```

Compilation checks syntax. It does not prove correct behavior.

## Unit Tests

```powershell
python -m unittest `
    discover `
    -s tests `
    -v
```

## Temporary Test Data

```python
with TemporaryDirectory() as directory:
    path = Path(directory) / "tasks.json"
```

Tests should not modify:

```text
$HOME\.devtasks\tasks.json
```

## Capture CLI Output

```python
with (
    redirect_stdout(standard_output),
    redirect_stderr(standard_error),
):
    exit_code = run(
        ["list"],
        data_file=test_path,
    )
```

## Quality Gate

```powershell
& .\scripts\Invoke-PythonQualityGate.ps1
```

Sequence:

```text
Format check
    ↓
Lint
    ↓
Compile
    ↓
Unit tests
    ↓
Package build
```

## Smoke Test

```powershell
& .\scripts\Test-PythonCli.ps1
```

The smoke test:

- Runs the installed command
- Uses temporary data
- Verifies JSON output
- Checks task changes
- Restores environment state
- Removes temporary data

## Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Assessment Notes

## Knowledge Assessments

Topics include:

- PowerShell syntax
- Paths and navigation
- Filesystem safety
- Node.js fundamentals
- npm and package management
- HTTP
- Environment variables
- Secrets and configuration
- PowerShell profiles
- Python CLI development

## Practical Assessment

You may be asked to:

- Create nested directories
- Create JSON, CSV, or source files
- Copy and hash-verify a file
- Move and rename a file
- Preview and execute deletion
- Set and restore environment variables
- Run a quality gate
- Start and test a service
- Build and test a Python wheel

## Safety-Critical Requirements

A learner should not pass a practical assessment while:

- Running broad deletion outside a laboratory
- Skipping required previews
- Printing a real secret
- Putting a secret in Git or a profile
- Weakening execution policy without authorization
- Killing unidentified processes
- Failing to verify unrelated resources

## Recommended Minimums

```text
Knowledge assessment: 75%
Practical assessment: 80%
Safety-critical checks: all passed
```

## Assessment Preparation

Be able to explain:

1. Why `-LiteralPath` is useful
2. Why `-WhatIf` is not an undo mechanism
3. Why `npm ci` uses the lockfile
4. Why environment variables require conversion
5. Why `.env` is not a vault
6. Why public configuration omits secrets
7. Why Python uses a virtual environment
8. Why a clean wheel test matters

---

# Common Misconceptions

## PowerShell

### Incorrect

> `ls` means PowerShell is Bash.

### Correct

`ls` normally aliases `Get-ChildItem`.

---

### Incorrect

> PowerShell pipelines pass only text.

### Correct

PowerShell normally passes structured objects.

---

## Filesystem

### Incorrect

> `-WhatIf` creates a backup.

### Correct

It previews supported changes.

---

### Incorrect

> `-Force` bypasses all security.

### Correct

It handles some provider restrictions but does not grant permission.

---

### Incorrect

> `Remove-Item` uses the Recycle Bin.

### Correct

Treat it as direct deletion.

---

## JavaScript and Node.js

### Incorrect

> Node.js is a programming language.

### Correct

JavaScript is the language; Node.js is the runtime.

---

### Incorrect

> `const` makes an object fully immutable.

### Correct

It prevents variable reassignment. `Object.freeze` provides shallow object freezing.

---

## npm

### Incorrect

> `package.json` always records exact installed versions.

### Correct

It may allow ranges. The lockfile records exact resolution.

---

### Incorrect

> npx is a sandbox.

### Correct

It executes package code with the user’s permissions.

---

## Environment Variables

### Incorrect

```javascript
Boolean("false") === false
```

### Correct

```javascript
Boolean("false") === true
```

Explicit parsing is required.

---

### Incorrect

> `.env` is encrypted because it is hidden.

### Correct

It is normally plaintext.

---

## Python

### Incorrect

> A bare `pip` always belongs to the active project.

### Correct

Use:

```powershell
python -m pip
```

to bind pip to a known interpreter.

---

### Incorrect

> Activation is required to use a virtual environment.

### Correct

You can call:

```powershell
.\.venv\Scripts\python.exe
```

directly.

---

### Incorrect

> Type hints validate decoded JSON.

### Correct

Runtime validation remains required.

---

# Troubleshooting Quick Reference

## Node.js Command Not Found

```powershell
Get-Command node `
    -ErrorAction SilentlyContinue
```

Restart the terminal after installation.

## npm PowerShell Script Blocked

```powershell
Get-ExecutionPolicy -List
Get-Command npm -All
npm.cmd --version
```

## Python Command Not Found

```powershell
Get-Command python, py -All `
    -ErrorAction SilentlyContinue

py --list
```

## Python Activation Blocked

Use:

```powershell
.\.venv\Scripts\python.exe
```

directly.

## Port Already in Use

```powershell
Get-NetTCPConnection `
    -LocalPort 3000 `
    -ErrorAction SilentlyContinue
```

Identify the process before stopping it.

## `.env` Change Has No Effect

Check for a process override:

```powershell
Get-Item Env:PORT `
    -ErrorAction SilentlyContinue
```

## Tests Do Not Exit

Look for:

- Unclosed HTTP servers
- Child processes
- Referenced timers
- Open handles
- Missing `finally` cleanup

## Python Import Fails

Check:

```powershell
python -c "import sys; print(sys.executable)"
python -m pip show devtasks-cli
python -c "import devtasks; print(devtasks.__file__)"
```

Avoid persistent global `PYTHONPATH`.

---

# Essential Command Reference

## PowerShell

```powershell
Get-Location
Set-Location
Get-ChildItem
Get-Item
Test-Path
Resolve-Path
New-Item
Set-Content
Copy-Item
Move-Item
Rename-Item
Remove-Item
Get-FileHash
Get-Command
Get-Help
Get-Member
```

## Node.js and npm

```powershell
node --version
node --check .\src\index.js
npm.cmd ci
npm.cmd run check
npm.cmd run dev
npm.cmd start
npx.cmd eslint .
```

## HTTP

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health"
```

## Environment

```powershell
Get-ChildItem Env:
$env:PORT = "3000"
Remove-Item Env:PORT
```

## Python

```powershell
py --list
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --editable .
python -m ruff format --check .
python -m ruff check .
python -m unittest discover -s tests -v
python -m build
```

## Python CLI

```powershell
devtasks add "Write documentation"
devtasks list
devtasks complete 1
devtasks list --json
```

---

# Final Architecture Review

## Node.js Project

```text
developer-service/
├── dist/
├── node_modules/
├── scripts/
├── src/
├── test/
├── .env
├── .env.example
├── .gitignore
├── eslint.config.js
├── package-lock.json
└── package.json
```

## Python Project

```text
python-developer-cli/
├── .venv/
├── dist/
├── scripts/
├── src/
│   └── devtasks/
├── tests/
├── .gitignore
├── pyproject.toml
└── README.md
```

## Runtime Data

```text
$HOME\.devtasks\tasks.json
```

## Complete Engineering Flow

```text
Select the correct location and runtime
                ↓
Create isolated dependency state
                ↓
Validate external input
                ↓
Run automated quality checks
                ↓
Build reproducible artifacts
                ↓
Smoke-test real entry points
                ↓
Inject runtime configuration safely
                ↓
Verify output, exit codes, and cleanup
```

---

# Personal Command Notes

| Purpose | Command |
|---|---|
| Enter series root | |
| Enter Node.js service | |
| Run Node quality gate | |
| Start Node development mode | |
| Display public Node configuration | |
| Enter Python project | |
| Activate Python environment | |
| Run Python quality gate | |
| Run Python smoke test | |
| Display Python CLI help | |

---

# Personal Troubleshooting Notes

| Date | Problem | Cause | Fix | Verification |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |

---

# Final Review Questions

## 1. What does a PowerShell pipeline transfer?

```text
____________________________________________________________
```

## 2. Why is a relative path context-dependent?

```text
____________________________________________________________
```

## 3. What are the six filesystem safety stages?

```text
____________________________________________________________
```

## 4. What is the difference between copy and move?

```text
____________________________________________________________
```

## 5. What does `package-lock.json` provide?

```text
____________________________________________________________
```

## 6. Why is `npm.cmd` useful in PowerShell?

```text
____________________________________________________________
```

## 7. What is the difference between JavaScript and Node.js?

```text
____________________________________________________________
```

## 8. Why are environment variables untrusted strings?

```text
____________________________________________________________
```

## 9. Why must secrets be omitted from public configuration?

```text
____________________________________________________________
```

## 10. What does a Python virtual environment isolate?

```text
____________________________________________________________
```

## 11. Why prefer `python -m pip`?

```text
____________________________________________________________
```

## 12. Why test a built wheel in a clean environment?

```text
____________________________________________________________
```

---

# Final Student Checklist

- [ ] I can read PowerShell command syntax.
- [ ] I can navigate using absolute and relative paths.
- [ ] I can inspect hidden and recursive content.
- [ ] I follow the six-stage filesystem safety process.
- [ ] I can create, copy, move, rename, and verify resources.
- [ ] I understand JavaScript and Node.js roles.
- [ ] I can manage npm dependencies and scripts.
- [ ] I can call and test HTTP endpoints.
- [ ] I understand process environment inheritance.
- [ ] I can validate runtime configuration.
- [ ] I keep secrets out of source, Git, logs, and profiles.
- [ ] I can create and use a Python virtual environment.
- [ ] I can install a Python project in editable mode.
- [ ] I can operate the `devtasks` CLI.
- [ ] I can run Python formatting, linting, tests, and builds.
- [ ] I can test a built wheel.
- [ ] I can explain the complete architecture in my own words.
