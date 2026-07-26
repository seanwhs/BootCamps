# Student Workbook  
## PowerShell CLI, Node.js, and Developer Environment

**Student name:** ______________________________________

**Instructor or reviewer:** _____________________________

**Start date:** ________________________________________

**Completion date:** ___________________________________

---

## How to Use This Workbook

This workbook accompanies:

- Primer 1: How to Read PowerShell Commands
- Primer 2: Filesystem Safety and Destructive Operations
- Part 1: Navigating the File System
- Part 2: File and Directory Management
- Primer 3: JavaScript, Node.js, Packages, and HTTP
- Part 3: Node Ecosystem and Package Management
- Primer 4: Processes, Environment Variables, Configuration, and Secrets
- Part 4: Runtime Configuration
- Part 5: Compressed Quickstart

The workbook does not repeat the complete tutorials. Instead, it gives you structured practice, spaces to record results, troubleshooting prompts, and completion checkpoints.

For each exercise:

1. Read the target.
2. Predict what will happen.
3. Run or write the command.
4. Record the evidence.
5. Explain the result in your own words.
6. Complete the checkpoint before continuing.

---

# Workbook Safety Agreement

Before beginning, read and initial each statement.

- [ ] I will perform destructive exercises only inside the tutorial laboratories.  
  **Initials:** __________

- [ ] I will run `Get-Location` before commands that use destructive relative paths.  
  **Initials:** __________

- [ ] I will inspect exact targets before deleting them.  
  **Initials:** __________

- [ ] I will use `-WhatIf` before supported destructive operations.  
  **Initials:** __________

- [ ] I understand that `Remove-Item` generally does not use the Windows Recycle Bin.  
  **Initials:** __________

- [ ] I will not substitute my home directory, Documents folder, drive root, or an important project for a disposable laboratory.  
  **Initials:** __________

- [ ] I will not paste real passwords, tokens, private keys, or production secrets into workbook answers.  
  **Initials:** __________

- [ ] I will not weaken PowerShell execution policy globally merely to complete an exercise.  
  **Initials:** __________

The safety sequence used throughout the workbook is:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

Write the sequence from memory:

```text
____________________________________________________________

____________________________________________________________
```

---

# Environment Readiness Record

## Workstation Information

Record the operating environment you are using.

| Item | Your result |
|---|---|
| Windows version | |
| PowerShell edition | |
| PowerShell version | |
| Node.js version | |
| npm version | |
| npx version | |
| Git version, if installed | |
| Preferred editor | |

Run these commands to collect the information:

```powershell
$PSVersionTable.PSEdition
$PSVersionTable.PSVersion

node --version
npm.cmd --version
npx.cmd --version

git --version
```

## Tool Availability Check

Run:

```powershell
$requiredCommands = @(
    "node"
    "npm.cmd"
    "npx.cmd"
)

foreach ($commandName in $requiredCommands) {
    $command = Get-Command `
        -Name $commandName `
        -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Command = $commandName
        Available = $null -ne $command
        Location = if ($null -ne $command) {
            $command.Source
        }
        else {
            "[not found]"
        }
    }
}
```

Record any missing tools:

```text
____________________________________________________________

____________________________________________________________
```

### Readiness Checkpoint

- [ ] PowerShell is available.
- [ ] Node.js is available.
- [ ] `npm.cmd` is available.
- [ ] `npx.cmd` is available.
- [ ] I can create files under `$HOME`.
- [ ] I know how to open a second PowerShell terminal.
- [ ] I understand that administrator access is unnecessary for ordinary exercises.

---

# Unit 1 Workbook: Reading PowerShell Commands

## Learning Objectives

By the end of this unit, you should be able to:

- Identify commands, parameters, values, and switches
- Recognize aliases
- Read pipelines from left to right
- Explain variables, objects, and properties
- Use built-in discovery and help commands

---

## Exercise 1.1: Command Anatomy

Study:

```powershell
Get-ChildItem -Path .\documents -File -Recurse
```

Label each component.

| Component | Your answer |
|---|---|
| Command name | |
| Named parameter | |
| Parameter value | |
| First switch | |
| Second switch | |

Rewrite it vertically:

```powershell
# Write your command here:




```

Explain the command in one sentence:

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 1.2: Native Commands and Aliases

Run:

```powershell
Get-Alias -Name pwd, cd, dir, ls, cp, mv, rm |
    Sort-Object Name |
    Select-Object Name, Definition
```

Complete the table:

| Alias | Native command | Purpose |
|---|---|---|
| `pwd` | | |
| `cd` | | |
| `dir` | | |
| `ls` | | |
| `cp` | | |
| `mv` | | |
| `rm` | | |

Why are native command names usually better in shared scripts?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 1.3: Variables and Properties

Create a variable containing your home path:

```powershell
# Write your command:

```

Retrieve your current location and save the result:

```powershell
# Write your command:

```

Read the saved object’s `Path` property:

```powershell
# Write your command:

```

Record the result:

```text
____________________________________________________________
```

What is the difference between a variable and a property?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 1.4: Quotation Marks

Predict the output:

```powershell
$tool = "PowerShell"

"Learning $tool"
'Learning $tool'
```

| Expression | Predicted output | Actual output |
|---|---|---|
| Double-quoted string | | |
| Single-quoted string | | |

Explain the difference:

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 1.5: Pipeline Reading

Study:

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 100
    } |
    Sort-Object -Property Length -Descending |
    Select-Object Name, Length
```

Complete the flow:

```text
Get-ChildItem
    retrieves _______________________________________________

Where-Object
    keeps ___________________________________________________

Sort-Object
    orders __________________________________________________

Select-Object
    returns properties ______________________________________
```

What does `$_` mean?

```text
____________________________________________________________
```

What does `-gt` mean?

```text
____________________________________________________________
```

---

## Exercise 1.6: Command Discovery

Use built-in help to investigate `Get-ChildItem`.

Run:

```powershell
Get-Command -Name Get-ChildItem
Get-Help -Name Get-ChildItem
Get-Help -Name Get-ChildItem -Examples
Get-Help -Name Get-ChildItem -Parameter Recurse
```

Record one example discovered through help:

```powershell
# Example:




```

Explain what that example does:

```text
____________________________________________________________

____________________________________________________________
```

---

## Unit 1 Reflection

Answer without copying the tutorial.

1. What is a cmdlet?

   ```text
   __________________________________________________________
   ```

2. What is a switch parameter?

   ```text
   __________________________________________________________
   ```

3. What does a pipeline transfer between PowerShell commands?

   ```text
   __________________________________________________________
   ```

4. How do you inspect an object’s properties and methods?

   ```text
   __________________________________________________________
   ```

### Unit 1 Checkpoint

- [ ] I can identify a command name.
- [ ] I can identify named parameters.
- [ ] I can identify parameter values.
- [ ] I can recognize switch parameters.
- [ ] I can explain `$_`.
- [ ] I can explain `|`.
- [ ] I can distinguish single and double quotes.
- [ ] I can use `Get-Command`.
- [ ] I can use `Get-Help`.
- [ ] I can use `Get-Member`.

**Instructor/reviewer initials:** __________

---

# Unit 2 Workbook: Navigation and Paths

## Learning Objectives

You will practice:

- Current, parent, and home locations
- Absolute and relative paths
- Paths containing spaces
- Drive navigation
- Directory inspection
- Hidden and recursive listings

---

## Exercise 2.1: Current Location

Run:

```powershell
Get-Location
```

Record the complete path:

```text
____________________________________________________________
```

Run the alias:

```powershell
pwd
```

Did it report the same location?

- [ ] Yes
- [ ] No

Explain why:

```text
____________________________________________________________
```

---

## Exercise 2.2: Path Vocabulary

Complete the table:

| Syntax | Meaning |
|---|---|
| `.` | |
| `..` | |
| `~` | |
| `$HOME` | |
| `.\src` | |
| `C:\` | |

Classify each path:

| Path | Absolute or relative? |
|---|---|
| `C:\Projects\service` | |
| `.\src\index.js` | |
| `..\archive` | |
| `$HOME\Documents` after evaluation | |

---

## Exercise 2.3: Navigation Prediction

Assume the current location is:

```text
C:\Projects\service\src
```

Predict the destination:

```powershell
Set-Location -Path ..
```

```text
____________________________________________________________
```

Predict:

```powershell
Set-Location -Path ..\test
```

```text
____________________________________________________________
```

Predict:

```powershell
Set-Location -Path $HOME
```

```text
____________________________________________________________
```

---

## Exercise 2.4: Build the Navigation Path

Construct the tutorial paths:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$labRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "filesystem-lab"
```

Record both resolved values:

| Variable | Value |
|---|---|
| `$seriesRoot` | |
| `$labRoot` | |

Verify:

```powershell
Test-Path `
    -LiteralPath $labRoot `
    -PathType Container
```

Result:

```text
____________________________________________________________
```

---

## Exercise 2.5: Directory Inspection

Write commands that perform each task.

### List immediate contents

```powershell
# Your command:

```

### List only files

```powershell
# Your command:

```

### List only directories

```powershell
# Your command:

```

### Include hidden items

```powershell
# Your command:

```

### List files recursively

```powershell
# Your command:

```

### Find JSON files recursively

```powershell
# Your command:




```

---

## Exercise 2.6: `Test-Path` and `Resolve-Path`

Choose one existing file and one existing directory.

| Target | Complete path |
|---|---|
| File | |
| Directory | |

Verify the file:

```powershell
# Your command using -PathType Leaf:




```

Verify the directory:

```powershell
# Your command using -PathType Container:




```

Resolve one relative path:

```powershell
# Your command:




```

Record the result:

```text
____________________________________________________________
```

---

## Exercise 2.7: Location Stack

Write commands that:

1. Start at `$labRoot`
2. Save that location and enter `documents`
3. Return to the saved location

```powershell
# Your commands:






```

Why is a location stack useful?

```text
____________________________________________________________

____________________________________________________________
```

---

## Unit 2 Troubleshooting Log

| Problem | Command used | Error message | Cause | Correction |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |

### Unit 2 Checkpoint

- [ ] I can display my current location.
- [ ] I can return home.
- [ ] I can use absolute paths.
- [ ] I can use relative paths.
- [ ] I can move to a parent directory.
- [ ] I can quote paths containing spaces.
- [ ] I can list only files.
- [ ] I can list only directories.
- [ ] I can include hidden items.
- [ ] I can search recursively.
- [ ] I can test and resolve paths.
- [ ] I can save and restore a location.

**Instructor/reviewer initials:** __________

---

# Unit 3 Workbook: Filesystem Safety

## Learning Objectives

You will practice:

- Approved-root boundaries
- Exact target inspection
- `-Path` versus `-LiteralPath`
- `-WhatIf`
- `-Recurse`
- `-Force`
- Post-operation verification

---

## Exercise 3.1: Safety Sequence

Complete the missing stages:

```text
Locate → __________ → Inspect → __________ → Execute → __________
```

Explain each stage:

| Stage | Purpose |
|---|---|
| Locate | |
| Resolve | |
| Inspect | |
| Preview | |
| Execute | |
| Verify | |

---

## Exercise 3.2: Read-Only or State-Changing?

Classify each command.

| Command | Read-only or state-changing? |
|---|---|
| `Get-ChildItem` | |
| `Test-Path` | |
| `Resolve-Path` | |
| `New-Item` | |
| `Set-Content` | |
| `Copy-Item` | |
| `Move-Item` | |
| `Remove-Item` | |
| `Get-FileHash` | |

Which command carries the greatest obvious data-loss risk?

```text
____________________________________________________________
```

Can `Set-Content` also destroy data? Explain.

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 3.3: Inspect Before Deletion

Choose a disposable directory inside the tutorial laboratory.

**Target:** ________________________________________________

Run and record:

```powershell
Get-Location
```

**Current location:** ______________________________________

Resolve the target:

```powershell
# Your command:




```

**Resolved target:** _______________________________________

Confirm its type:

```powershell
# Your Test-Path command:




```

Inventory its descendants:

```powershell
# Your command:




```

**Number of descendants:** _________________________________

---

## Exercise 3.4: Preview

Write the exact preview command:

```powershell
# Must use -LiteralPath, -Recurse, and -WhatIf:




```

Copy the significant preview output:

```text
____________________________________________________________

____________________________________________________________
```

Verify that the preview did not delete the target:

```powershell
# Your verification:




```

Result: __________________

---

## Exercise 3.5: Wildcard Safety

Study these two approaches.

### Approach A

```powershell
Remove-Item -Path *.tmp
```

### Approach B

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

List three reasons Approach B is safer:

1. ________________________________________________________
2. ________________________________________________________
3. ________________________________________________________

---

## Exercise 3.6: Explain `-Force`

Complete:

```text
-Force may help PowerShell process __________________________

and ________________________________________________________

but it does not _____________________________________________

or _________________________________________________________
```

Would you add `-Force` to every deletion command?

- [ ] Yes
- [ ] No

Why?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 3.7: Verify Unrelated Data

After one safe deletion exercise, identify:

| Item | Expected final state | Actual final state |
|---|---|---|
| Intended target | Absent | |
| Approved root | Present | |
| Unrelated sibling | Present | |
| Outside-boundary test item | Present | |

Write the commands used to verify these states:

```powershell
# Commands:








```

---

## Unit 3 Scenario Review

A colleague proposes:

```powershell
Remove-Item * -Recurse -Force
```

List at least five risks:

1. ________________________________________________________
2. ________________________________________________________
3. ________________________________________________________
4. ________________________________________________________
5. ________________________________________________________

Rewrite the workflow as a safer sequence of commands or pseudocode:

```powershell
# Your safer workflow:












```

### Unit 3 Checkpoint

- [ ] I check my location before destructive work.
- [ ] I resolve exact paths.
- [ ] I distinguish files from directories.
- [ ] I inspect descendants.
- [ ] I preview with `-WhatIf`.
- [ ] I understand that `-WhatIf` is not a backup.
- [ ] I understand `-Recurse`.
- [ ] I understand the limits of `-Force`.
- [ ] I verify unrelated data after mutation.
- [ ] I understand that deletion may be permanent.

**Instructor/reviewer initials:** __________

---

# Unit 4 Workbook: File and Directory Management

## Exercise 4.1: Create a Practice Tree

Inside a disposable laboratory, create:

```text
workbook-lab/
├── archive/
├── incoming/
└── workspace/
    ├── config/
    ├── data/
    │   └── raw/
    └── src/
```

Record your root:

```powershell
$workbookLab = # Complete this assignment
```

Write the complete creation commands:

```powershell
# Your implementation:












```

Verification command:

```powershell
# Your verification:




```

---

## Exercise 4.2: Create Files

Create:

```text
workspace/README.md
workspace/src/index.js
workspace/config/settings.json
workspace/data/raw/records.csv
```

Use complete, valid content.

### `README.md`

```markdown
# Workbook Laboratory

This project is used for PowerShell practice.
```

### `index.js`

```javascript
"use strict";

console.log("Workbook laboratory");
```

### `settings.json`

```json
{
  "environment": "development",
  "enabled": true
}
```

### `records.csv`

```csv
id,name
1,Ada
2,Grace
```

Write your PowerShell implementation:

```powershell
# Your implementation:






















```

---

## Exercise 4.3: Validate Structured Files

Parse the JSON:

```powershell
# Your command:




```

Import the CSV:

```powershell
# Your command:




```

Record:

| Check | Result |
|---|---|
| JSON environment | |
| JSON enabled | |
| CSV record count | |
| First CSV name | |
| Second CSV name | |

---

## Exercise 4.4: Copy and Hash

Copy `records.csv` to:

```text
archive\records.backup.csv
```

Write your implementation:

```powershell
# Copy:




```

Calculate both hashes:

```powershell
# Hash commands:






```

| Hash | Value |
|---|---|
| Source SHA-256 | |
| Destination SHA-256 | |

Do they match?

- [ ] Yes
- [ ] No

---

## Exercise 4.5: Move and Rename

Move:

```text
workspace\config\settings.json
```

to:

```text
archive\application-settings.json
```

Write the command:

```powershell
# Your command:




```

Verification:

```powershell
# Verify old path absent and new path present:






```

---

## Exercise 4.6: Safe Cleanup

Create three `.tmp` files under `incoming`.

```powershell
# Your implementation:






```

Select the exact objects:

```powershell
# Your selection:




```

Inspect:

```powershell
# Your inspection:




```

Preview:

```powershell
# Your preview:




```

Execute:

```powershell
# Your execution:




```

Verify:

```powershell
# Your verification:




```

---

## Unit 4 Evidence Record

List the final paths and states:

| Path | Should exist? | Actual |
|---|---:|---:|
| `workspace\README.md` | Yes | |
| `workspace\src\index.js` | Yes | |
| `workspace\data\raw\records.csv` | Yes | |
| `workspace\config\settings.json` | No | |
| `archive\application-settings.json` | Yes | |
| `archive\records.backup.csv` | Yes | |
| `incoming\*.tmp` | No | |

### Unit 4 Checkpoint

- [ ] I can create nested directories.
- [ ] I can create an empty file.
- [ ] I can write complete file content.
- [ ] I can append content.
- [ ] I can parse JSON.
- [ ] I can import CSV.
- [ ] I can copy a file.
- [ ] I can verify a copy by hash.
- [ ] I can rename an item.
- [ ] I can move and rename together.
- [ ] I can safely delete selected matches.

**Instructor/reviewer initials:** __________

---

# Unit 5 Workbook: JavaScript and Node.js Foundations

## Exercise 5.1: Runtime Inspection

Run:

```powershell
node -e 'console.log({
  version: process.version,
  platform: process.platform,
  architecture: process.arch,
  processId: process.pid,
  workingDirectory: process.cwd()
});'
```

Record:

| Property | Value |
|---|---|
| Node.js version | |
| Platform | |
| Architecture | |
| Process ID | |
| Working directory | |

What is the difference between JavaScript and Node.js?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 5.2: Values and Variables

Complete the JavaScript:

```javascript
const serviceName = ________________________________;
const port = ______________________________________;
const enabled = ___________________________________;

let requestCount = 0;
requestCount ______________________________________;

console.log({
  serviceName,
  port,
  enabled,
  requestCount,
});
```

Run it through Node.js or save it to a disposable file.

Record the output:

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 5.3: Function Practice

Write a JavaScript function that returns:

```text
http://127.0.0.1:3000
```

when called with host `127.0.0.1` and port `3000`.

```javascript
// Your function:







```

Write one verification condition:

```javascript
// Your check:




```

---

## Exercise 5.4: Module Practice

Create a module exporting:

- `add`
- `multiply`

### `src/math.js`

```javascript
// Your complete file:














```

Write import and verification code:

```javascript
// Your importing code:








```

---

## Exercise 5.5: JSON Round Trip

Create this JavaScript object:

```javascript
{
  service: "workbook-service",
  status: "ok",
  ready: true
}
```

Serialize it:

```javascript
// Your code:




```

Parse it:

```javascript
// Your code:




```

Verify `status`:

```javascript
// Your code:




```

Explain the difference between an object and JSON text:

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 5.6: Asynchronous Behavior

Predict the output order:

```javascript
console.log("A");

setTimeout(() => {
  console.log("B");
}, 100);

console.log("C");
```

Prediction:

```text
1. __________
2. __________
3. __________
```

Actual result:

```text
1. __________
2. __________
3. __________
```

Explain why:

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 5.7: Error Handling

Complete:

```javascript
function parsePort(rawValue) {
  if (!/^\d+$/.test(rawValue)) {
    ________________________________________________;
  }

  const port = ____________________________________;

  if (
    !Number.isSafeInteger(port) ||
    port < 1 ||
    port > 65_535
  ) {
    ________________________________________________;
  }

  return port;
}
```

Test valid and invalid inputs:

| Input | Expected | Actual |
|---|---|---|
| `"3000"` | `3000` | |
| `"443"` | `443` | |
| `"invalid"` | Error | |
| `"70000"` | Error | |

---

## Unit 5 Checkpoint

- [ ] I can explain JavaScript versus Node.js.
- [ ] I can use `const` and `let`.
- [ ] I can create arrays and objects.
- [ ] I can write functions.
- [ ] I can return values.
- [ ] I can export and import CommonJS modules.
- [ ] I can serialize and parse JSON.
- [ ] I understand Promises conceptually.
- [ ] I can use `async` and `await`.
- [ ] I can throw and catch errors.
- [ ] I understand process exit codes.

**Instructor/reviewer initials:** __________

---

# Unit 6 Workbook: npm and Package Management

## Exercise 6.1: Project Resource Map

Complete the purpose column:

| Resource | Purpose |
|---|---|
| `package.json` | |
| `package-lock.json` | |
| `node_modules` | |
| `src` | |
| `dist` | |
| `test` | |
| `scripts` | |

Which resources should normally be committed?

```text
____________________________________________________________
```

Which resources should normally be regenerated?

```text
____________________________________________________________
```

---

## Exercise 6.2: Tool Comparison

Complete:

| Tool | Responsibility |
|---|---|
| `node` | |
| `npm` | |
| `npx` | |
| `pnpm` | |

Which package manager does the tutorial project use?

```text
____________________________________________________________
```

Which lockfile confirms that choice?

```text
____________________________________________________________
```

---

## Exercise 6.3: Initialize a Project

Create a disposable npm project and run:

```powershell
npm.cmd init -y
```

Record the generated fields:

| Field | Value |
|---|---|
| `name` | |
| `version` | |
| `main` | |
| `license` | |

Why might a private application declare:

```json
"private": true
```

```text
____________________________________________________________
```

---

## Exercise 6.4: Install Dependencies

Write the commands for:

### Runtime dependency: Express

```powershell
# Your command:

```

### Development dependency: ESLint

```powershell
# Your command:

```

Verify both:

```powershell
# Your verification commands:






```

Where should each appear in `package.json`?

| Package | Manifest property |
|---|---|
| Express | |
| ESLint | |

---

## Exercise 6.5: npm Scripts

Given:

```json
{
  "scripts": {
    "lint": "eslint .",
    "test": "node --test",
    "build": "node scripts/build.js",
    "start": "node dist/index.js"
  }
}
```

Write the command for each:

| Task | Command |
|---|---|
| Lint | |
| Test | |
| Build | |
| Start | |

Why can the lint script find the project-local ESLint executable?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 6.6: `npm install` Versus `npm ci`

Complete the comparison:

| Behavior | `npm install` | `npm ci` |
|---|---|---|
| Requires lockfile | | |
| May update lockfile | | |
| Used to add dependencies | | |
| Clean reproducible installation | | |
| Removes existing `node_modules` first | | |

Which should a CI pipeline commonly use?

```text
____________________________________________________________
```

---

## Exercise 6.7: Execution Policy Diagnosis

Run:

```powershell
Get-ExecutionPolicy -List
Get-Command npm -All
```

Record the effective policy:

```text
____________________________________________________________
```

Record the command PowerShell selects for `npm`:

```text
____________________________________________________________
```

What is the narrow workaround if `npm.ps1` is blocked?

```text
____________________________________________________________
```

Why is a machine-wide unrestricted policy inappropriate?

```text
____________________________________________________________

____________________________________________________________
```

---

## Unit 6 Checkpoint

- [ ] I can initialize an npm project.
- [ ] I can read `package.json`.
- [ ] I can explain `package-lock.json`.
- [ ] I can explain `node_modules`.
- [ ] I can install runtime dependencies.
- [ ] I can install development dependencies.
- [ ] I can run npm scripts.
- [ ] I can use `npx`.
- [ ] I understand `npm install` versus `npm ci`.
- [ ] I can diagnose `npm.ps1` policy errors.
- [ ] I know why package managers should not be mixed casually.

**Instructor/reviewer initials:** __________

---

# Unit 7 Workbook: HTTP and Services

## Exercise 7.1: URI Anatomy

Label:

```text
GET http://127.0.0.1:3000/health
```

| Component | Value |
|---|---|
| Method | |
| Scheme | |
| Host | |
| Port | |
| Route | |

---

## Exercise 7.2: HTTP Methods

Complete:

| Method | Typical purpose |
|---|---|
| `GET` | |
| `POST` | |
| `PUT` | |
| `PATCH` | |
| `DELETE` | |

Do HTTP methods provide authorization by themselves?

- [ ] Yes
- [ ] No

Explain:

```text
____________________________________________________________
```

---

## Exercise 7.3: Status Codes

Complete:

| Status | Meaning |
|---:|---|
| `200` | |
| `201` | |
| `204` | |
| `400` | |
| `401` | |
| `403` | |
| `404` | |
| `413` | |
| `500` | |
| `503` | |

---

## Exercise 7.4: Call the Service

Start the tutorial service in one terminal:

```powershell
npm.cmd run dev
```

In another terminal, request `/health`:

```powershell
# Your command:




```

Record the result:

| Property | Value |
|---|---|
| Status | |
| Environment | |
| Uptime | |
| Timestamp | |

---

## Exercise 7.5: POST JSON

Send:

```json
{
  "message": "Workbook request",
  "ready": true
}
```

Write the PowerShell implementation:

```powershell
# Body creation:






# Request:








```

Record the returned object:

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 7.6: Missing Route

Request:

```text
GET /does-not-exist
```

Expected status: __________

Expected JSON error: _______________________________________

Write the request and error-handling code:

```powershell
# Your implementation:












```

---

## Exercise 7.7: Graceful Shutdown

Start the service and press `Ctrl+C`.

Record the shutdown log:

```text
____________________________________________________________

____________________________________________________________
```

What signal is commonly associated with `Ctrl+C`?

```text
____________________________________________________________
```

Why is graceful shutdown preferable to abrupt termination?

```text
____________________________________________________________

____________________________________________________________
```

---

## Unit 7 Checkpoint

- [ ] I can identify URI components.
- [ ] I understand common HTTP methods.
- [ ] I understand common status codes.
- [ ] I can call a GET endpoint.
- [ ] I can send a JSON POST request.
- [ ] I can handle a non-success response.
- [ ] I can explain a health endpoint.
- [ ] I understand request-body limits.
- [ ] I understand graceful shutdown.
- [ ] I understand why tests use port `0`.

**Instructor/reviewer initials:** __________

---

# Unit 8 Workbook: Environment Variables and Secrets

## Exercise 8.1: Process Environment

List the environment provider:

```powershell
# Your command:

```

Read `PATH` using both approaches:

```powershell
# Provider approach:


# Variable approach:

```

Do the values match?

- [ ] Yes
- [ ] No

---

## Exercise 8.2: Parent-to-Child Inheritance

Set:

```text
WORKBOOK_MODE=training
```

Run Node.js and display it. Ensure cleanup with `finally`.

```powershell
# Your complete implementation:












```

Record the child value:

```text
____________________________________________________________
```

Confirm the parent variable was removed:

```powershell
# Your command:

```

---

## Exercise 8.3: Scope Comparison

Complete:

| Scope | Lifetime and reach |
|---|---|
| Process | |
| User | |
| Machine | |

Why does an already-open terminal not automatically receive a newly persisted user variable?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 8.4: Strings and Conversion

Assume:

```text
PORT=3000
FEATURE_ENABLED=false
```

What types does Node.js receive?

| Variable | Node.js type |
|---|---|
| `PORT` | |
| `FEATURE_ENABLED` | |

What is the result of:

```javascript
Boolean("false")
```

```text
____________________________________________________________
```

Write a safe Boolean parser:

```javascript
// Your implementation:












```

---

## Exercise 8.5: Configuration Versus Secrets

Classify:

| Name | Public configuration or secret? |
|---|---|
| `NODE_ENV` | |
| `HOST` | |
| `PORT` | |
| `LOG_LEVEL` | |
| `APP_SECRET` | |
| `API_TOKEN` | |
| `DATABASE_PASSWORD` | |
| `PRIVATE_KEY` | |

Which fields would you permit in public diagnostics?

```text
____________________________________________________________
```

---

## Exercise 8.6: `.env` Protection

Write the required `.gitignore` rules:

```gitignore
# Your rules:



```

Explain the role of each file:

| File | Role |
|---|---|
| `.env` | |
| `.env.example` | |
| `.gitignore` | |

Why is `.env` not a secret vault?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 8.7: Precedence

Local `.env`:

```dotenv
PORT=3000
```

PowerShell:

```powershell
$env:PORT = "3200"
```

The application uses: __________________

Why?

```text
____________________________________________________________
```

What should happen after removing `$env:PORT`?

```text
____________________________________________________________
```

---

## Exercise 8.8: Validation Boundary

Write expected outcomes:

| Input | Expected result |
|---|---|
| `NODE_ENV=development` | |
| `NODE_ENV=preview` | |
| `PORT=3000` | |
| `PORT=invalid` | |
| `PORT=70000` | |
| Missing `APP_SECRET` | |
| Placeholder secret | |
| Valid production secret | |

Why is startup failure safer than silently accepting invalid configuration?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 8.9: Public Projection

Given a private configuration object containing:

```javascript
{
  environment,
  host,
  port,
  appSecret,
  isProduction
}
```

Write a function returning only public values:

```javascript
// Your function:









```

Why is an allowlist safer than copying every field and removing known secrets?

```text
____________________________________________________________

____________________________________________________________
```

---

## Unit 8 Checkpoint

- [ ] I can inspect `Env:`.
- [ ] I can set temporary variables.
- [ ] I can remove temporary variables.
- [ ] I understand environment inheritance.
- [ ] I understand process, user, and machine scope.
- [ ] I know environment values are strings.
- [ ] I can explain `.env` precedence.
- [ ] I can distinguish configuration from secrets.
- [ ] I can explain why `.env` is not a vault.
- [ ] I can validate ports and modes.
- [ ] I can omit secrets from public output.
- [ ] I know how to respond to an exposed secret.

**Instructor/reviewer initials:** __________

---

# Unit 9 Workbook: PowerShell Profile

## Exercise 9.1: Discover the Profile

Run:

```powershell
$PROFILE |
    Format-List *
```

Record:

| Profile | Path |
|---|---|
| Current user, current host | |
| Current user, all hosts | |
| All users, current host | |
| All users, all hosts | |

Which profile does the tutorial modify?

```text
____________________________________________________________
```

---

## Exercise 9.2: Back Up the Profile

Write a backup command that adds a timestamp:

```powershell
# Your implementation:









```

Why is a backup required?

```text
____________________________________________________________
```

---

## Exercise 9.3: Navigation Function

Write a profile function that:

- Builds the project path from `$HOME`
- Checks that it is a directory
- Navigates to it
- Throws a useful error otherwise

```powershell
function Enter-WorkbookProject {
    [CmdletBinding()]
    param()

    # Your complete implementation:














}
```

---

## Exercise 9.4: Function Versus Alias

Why is this invalid or misleading?

```powershell
Set-Alias build "npm.cmd run build"
```

```text
____________________________________________________________
```

Write the correct function:

```powershell
function Invoke-WorkbookBuild {
    # Your implementation:




}
```

---

## Exercise 9.5: Profile Security Review

Mark each item appropriate or inappropriate.

| Profile content | Appropriate? |
|---|---:|
| Navigation function | |
| Formatting preference | |
| Project alias | |
| `APP_SECRET` value | |
| Database password | |
| Quality-check function | |
| Production private key | |

Why should project secrets stay out of `$PROFILE`?

```text
____________________________________________________________

____________________________________________________________
```

---

## Exercise 9.6: Syntax Validation

Write PowerShell that parses the profile and reports parser errors:

```powershell
# Your implementation:














```

What command starts PowerShell without profiles?

```text
____________________________________________________________
```

---

## Unit 9 Checkpoint

- [ ] I can locate my profile.
- [ ] I can back it up.
- [ ] I can create reusable functions.
- [ ] I understand aliases versus functions.
- [ ] I can reload a profile.
- [ ] I can validate profile syntax.
- [ ] I understand idempotent profile updates.
- [ ] I keep project secrets out of the profile.
- [ ] I can start PowerShell without a profile for troubleshooting.

**Instructor/reviewer initials:** __________

---

# Capstone Workbook

## Capstone Goal

Demonstrate the complete workflow:

```text
PowerShell filesystem
        ↓
Node.js project
        ↓
npm automation
        ↓
HTTP service
        ↓
validated configuration
        ↓
safe developer shortcuts
```

---

## Capstone Phase 1: Architecture Audit

Confirm the project contains:

```text
developer-service/
├── dist/
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

Record:

| Resource | Exists? | Purpose |
|---|---:|---|
| `src/app.js` | | |
| `src/config.js` | | |
| `src/index.js` | | |
| `dist/index.js` | | |
| `scripts/build.js` | | |
| `scripts/clean.js` | | |
| `scripts/smoke-test.js` | | |
| `test/config.test.js` | | |
| `test/server.test.js` | | |
| `.env` | | |
| `.env.example` | | |
| `package.json` | | |
| `package-lock.json` | | |

---

## Capstone Phase 2: Dependency Reproduction

Run:

```powershell
npm.cmd ci
```

Record:

- Exit code: __________
- Installation duration: __________
- Top-level dependencies:

```text
____________________________________________________________

____________________________________________________________
```

Run:

```powershell
npm.cmd list --depth=0
```

Did npm report errors?

- [ ] No
- [ ] Yes

If yes, record them:

```text
____________________________________________________________

____________________________________________________________
```

---

## Capstone Phase 3: Quality Gate

Run:

```powershell
npm.cmd run check
```

Record:

| Stage | Passed? | Evidence |
|---|---:|---|
| Lint | | |
| Tests | | |
| Build | | |
| Smoke test | | |

Final exit code: __________

If a stage failed, complete:

| Failure | Root cause | Correction | Retest result |
|---|---|---|---|
| | | | |
| | | | |

---

## Capstone Phase 4: Development Service

Start:

```powershell
npm.cmd run dev
```

Test:

| Request | Expected | Actual |
|---|---|---|
| `GET /` | `200` and service info | |
| `GET /health` | `200` and `status=ok` | |
| `POST /echo` | `200` and echoed JSON | |
| `GET /missing` | `404` | |

Record the startup log without secrets:

```text
____________________________________________________________

____________________________________________________________
```

Record the shutdown log:

```text
____________________________________________________________

____________________________________________________________
```

---

## Capstone Phase 5: Configuration Tests

### Local fallback

Run:

```powershell
npm.cmd run config
```

Record:

| Property | Value |
|---|---|
| Environment | |
| Host | |
| Port | |
| Production flag | |

Was a secret displayed?

- [ ] No
- [ ] Yes

### Temporary override

Set a temporary port:

```powershell
$env:PORT = "3205"
```

Run configuration inspection and clean up in `finally`.

```powershell
# Your implementation:












```

Resolved port: __________

After cleanup, does `Env:PORT` exist?

- [ ] No
- [ ] Yes

---

## Capstone Phase 6: Invalid Configuration

Test each case using temporary or isolated child-process values.

| Case | Expected outcome | Exit code | Error safely worded? |
|---|---|---:|---:|
| `PORT=invalid` | Failure | | |
| `PORT=70000` | Failure | | |
| `NODE_ENV=preview` | Failure | | |
| Missing `APP_SECRET` | Failure | | |
| Short production secret | Failure | | |

Did any error print a secret?

- [ ] No
- [ ] Yes

---

## Capstone Phase 7: Production Smoke Test

Run:

```powershell
& .\scripts\Test-ProductionService.ps1
```

Record:

| Property | Value |
|---|---|
| Status | |
| Environment | |
| Port | |
| Process ID | |
| Passed | |

Afterward, verify:

| Parent environment variable | Absent? |
|---|---:|
| `NODE_ENV` | |
| `HOST` | |
| `PORT` | |
| `APP_SECRET` | |

---

## Capstone Phase 8: Git Safety

If Git is available, run:

```powershell
git check-ignore -v .env
git check-ignore .env.example
```

Record:

| File | Ignored? | Correct state? |
|---|---:|---:|
| `.env` | | |
| `.env.example` | | |
| `node_modules` | | |
| `dist` | | |

Why should `package-lock.json` remain trackable?

```text
____________________________________________________________

____________________________________________________________
```

---

## Capstone Phase 9: Profile Verification

Load the profile:

```powershell
. $PROFILE.CurrentUserCurrentHost
```

Verify:

| Command | Available? |
|---|---:|
| `Enter-CliDeveloperSeries` | |
| `Enter-DeveloperService` | |
| `Invoke-DeveloperServiceCheck` | |
| `Show-DeveloperServiceConfig` | |
| `Start-DeveloperService` | |
| `cds` | |
| `devservice` | |

Does the profile assign `APP_SECRET`?

- [ ] No
- [ ] Yes

Does the profile parse successfully?

- [ ] Yes
- [ ] No

---

# Capstone Final Reflection

Answer in complete sentences.

## 1. Why is PowerShell more than a command launcher?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## 2. Why are full cmdlet names useful in scripts?

```text
____________________________________________________________

____________________________________________________________
```

## 3. Describe your filesystem safety method.

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## 4. Explain the relationship among `package.json`, `package-lock.json`, and `node_modules`.

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## 5. Explain the difference between development and production startup.

```text
____________________________________________________________

____________________________________________________________
```

## 6. Explain the configuration precedence model.

```text
____________________________________________________________

____________________________________________________________
```

## 7. Why is `.env` not sufficient as a production secret-management system?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## 8. Why does the project have both automated tests and a smoke test?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## 9. What is one workflow you will automate next?

```text
____________________________________________________________

____________________________________________________________
```

## 10. What safety habit from this course is most valuable to you?

```text
____________________________________________________________

____________________________________________________________
```

---

# Final Skills Checklist

## PowerShell Language

- [ ] I understand `Verb-Noun` cmdlet names.
- [ ] I can distinguish commands, parameters, values, and switches.
- [ ] I can use variables.
- [ ] I can read object properties.
- [ ] I can read pipelines.
- [ ] I understand `$_`.
- [ ] I can use arrays and hashtables.
- [ ] I can use splatting.
- [ ] I can use `try`, `catch`, and `finally`.

## Navigation

- [ ] I can identify my current location.
- [ ] I can navigate with absolute paths.
- [ ] I can navigate with relative paths.
- [ ] I can move between drives.
- [ ] I can inspect hidden items.
- [ ] I can search recursively.
- [ ] I can test and resolve paths.

## Filesystem Management

- [ ] I can create files and directories.
- [ ] I can copy and verify files.
- [ ] I can move and rename items.
- [ ] I can inspect wildcard matches before mutation.
- [ ] I can use `-WhatIf`.
- [ ] I can explain `-Recurse`.
- [ ] I can explain `-Force`.
- [ ] I can verify unrelated data survived.

## Node.js and npm

- [ ] I can run JavaScript with Node.js.
- [ ] I can explain CommonJS modules.
- [ ] I can initialize an npm project.
- [ ] I can install runtime dependencies.
- [ ] I can install development dependencies.
- [ ] I can explain the lockfile.
- [ ] I can use npm scripts.
- [ ] I can use `npm ci`.
- [ ] I can diagnose execution-policy wrapper errors.

## HTTP Services

- [ ] I can identify a host, port, method, and route.
- [ ] I understand common HTTP status codes.
- [ ] I can send GET and POST requests from PowerShell.
- [ ] I can test JSON responses.
- [ ] I understand body-size limits.
- [ ] I understand graceful shutdown.
- [ ] I understand health endpoints.

## Runtime Configuration

- [ ] I can inspect environment variables.
- [ ] I can set and remove process variables.
- [ ] I understand process inheritance.
- [ ] I understand process, user, and machine scope.
- [ ] I know environment values are strings.
- [ ] I can explain `.env` loading.
- [ ] I can explain configuration precedence.
- [ ] I can validate ports and runtime modes.
- [ ] I can distinguish public configuration from secrets.
- [ ] I can prevent secrets from entering public output.

## Developer Workflow

- [ ] I can run the quality gate.
- [ ] I can build generated output.
- [ ] I can run development mode.
- [ ] I can run a production smoke test.
- [ ] I can safely customize my profile.
- [ ] I can install profile updates idempotently.
- [ ] I keep secrets out of profiles and source control.

---

# Troubleshooting Journal

Use one row for each significant issue.

| Date | Context | Command | Error | Cause | Fix | Verification |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |

---

# Command Journal

Record commands that you want to remember.

| Purpose | Command |
|---|---|
| Show current location | |
| Go home | |
| List hidden files | |
| Find JSON files recursively | |
| Test a directory | |
| Resolve a path | |
| Preview deletion | |
| Calculate a hash | |
| Install dependencies exactly | |
| Run the quality gate | |
| Start development mode | |
| Show public configuration | |
| Inspect environment variables | |
| Reload the PowerShell profile | |

---

# Instructor or Reviewer Sign-Off

## Knowledge Demonstration

- [ ] Student can explain PowerShell command anatomy.
- [ ] Student can navigate without File Explorer.
- [ ] Student uses safe filesystem practices.
- [ ] Student understands npm project resources.
- [ ] Student can operate the HTTP service.
- [ ] Student can explain environment inheritance.
- [ ] Student can distinguish secrets from public configuration.
- [ ] Student can run and interpret the quality gate.

## Practical Demonstration

- [ ] Created a nested directory tree
- [ ] Created valid JSON, CSV, and JavaScript files
- [ ] Copied and hash-verified a file
- [ ] Moved and renamed a file
- [ ] Previewed a deletion
- [ ] Verified deletion and preservation
- [ ] Installed dependencies with `npm ci`
- [ ] Passed linting and tests
- [ ] Built generated output
- [ ] Called service endpoints
- [ ] Validated runtime configuration
- [ ] Passed production smoke test
- [ ] Verified `.env` protection
- [ ] Verified profile safety

## Final Evaluation

**Knowledge score:** __________ / __________

**Practical score:** __________ / __________

**Overall result:**

- [ ] Complete
- [ ] Complete with recommended review
- [ ] Additional practice required

**Reviewer comments:**

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

**Reviewer signature:** ____________________________________

**Date:** __________________________________________________

---

# Student Completion Statement

I completed the exercises in this workbook and understand that command-line operations can modify or permanently remove data. I will continue to inspect targets, preview destructive operations, protect secrets, and verify results.

**Student signature:** _____________________________________

**Date:** __________________________________________________
