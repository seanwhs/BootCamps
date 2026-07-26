# Trainer Guide  
## PowerShell CLI, Node.js, and Developer Environment

**Course title:** PowerShell CLI and Developer Environment  
**Delivery mode:** Instructor-led, workshop, classroom, virtual, or blended  
**Primary platform:** Windows with PowerShell  
**Recommended runtime:** PowerShell 7 and Node.js 20 or later  
**Audience:** Beginners through early-career developers  
**Suggested duration:** 18–24 instructional hours  
**Assessment materials:** Quiz Pack, Practical Lab, and Student Workbook

---

# 1. Purpose of This Guide

This guide helps trainers deliver the tutorial series as a structured learning program.

It includes:

- Learning outcomes
- Recommended schedules
- Environment-preparation instructions
- Lesson plans
- Demonstration guidance
- Discussion prompts
- Common misconceptions
- Troubleshooting strategies
- Safety controls
- Assessment recommendations
- Practical evaluation rubrics
- Differentiation strategies
- Completion criteria

The trainer should not simply read the tutorial aloud. The course works best when learners repeatedly follow this cycle:

```text
Explain
   ↓
Predict
   ↓
Demonstrate
   ↓
Practice
   ↓
Verify
   ↓
Reflect
```

---

# 2. Course Outcomes

By the end of the course, learners should be able to:

## PowerShell fundamentals

- Read PowerShell command syntax
- Recognize cmdlets, aliases, parameters, values, and switches
- Use variables, arrays, hashtables, objects, and pipelines
- Discover commands with `Get-Command`
- Read documentation with `Get-Help`
- Inspect objects with `Get-Member`

## Filesystem navigation

- Identify the current location
- Navigate with absolute and relative paths
- Use `.`, `..`, `~`, and `$HOME`
- Navigate across available Windows drives
- List files and directories
- Include hidden items
- Search directory trees recursively
- Validate and resolve paths

## File management and safety

- Create files and nested directories
- Write and append file content
- Copy, move, and rename resources
- Verify copies with SHA-256 hashes
- Preview mutations with `-WhatIf`
- Explain `-Recurse` and `-Force`
- Remove exact files and non-empty directories safely
- Enforce an approved-root boundary
- Verify both intended changes and unrelated survivors

## Node.js and package management

- Explain JavaScript versus Node.js
- Initialize an npm project
- Explain `package.json`, `package-lock.json`, and `node_modules`
- Distinguish runtime and development dependencies
- Use npm scripts
- Use `npm ci`
- Explain npm, npx, and pnpm
- Diagnose common PowerShell execution-policy errors

## HTTP services

- Explain clients, servers, hosts, ports, routes, methods, and status codes
- Start a Node.js service
- Send HTTP requests from PowerShell
- Test JSON request and response bodies
- Explain health checks
- Run automated tests
- Explain graceful shutdown

## Runtime configuration and secrets

- Inspect and manage process environment variables
- Explain process, user, and machine scopes
- Explain parent-to-child environment inheritance
- Load local values from `.env`
- Apply environment-over-`.env` precedence
- Validate and convert raw configuration
- Distinguish public configuration from secrets
- Keep secrets out of source control and public logs
- Customize a PowerShell profile without storing credentials

---

# 3. Intended Audience

The course is suitable for:

- Windows users new to terminals
- Developers transitioning from File Explorer
- JavaScript beginners
- Bash users moving to PowerShell
- Support engineers moving into development
- QA engineers learning local service workflows
- Junior developers learning environment configuration
- Teams standardizing Windows setup instructions

## Assumed knowledge

Learners should be able to:

- Use Windows
- Open a terminal
- Use a text editor
- Understand files and folders at a basic level
- Follow step-by-step instructions

Do not assume that learners already understand:

- Absolute and relative paths
- Shell processes
- Pipelines
- Package managers
- HTTP
- JSON
- Environment variables
- Source control exclusions
- Runtime configuration

Define each term before relying on it.

---

# 4. Course Materials

The complete learning package consists of:

```text
Part 0: Introduction

Primer 1:
How to Read PowerShell Commands

Primer 2:
Filesystem Safety and Destructive Operations

Part 1:
Navigating the File System like a Native

Part 2:
File and Directory Management Operations

Primer 3:
JavaScript, Node.js, Packages, and HTTP

Part 3:
Node Ecosystem and Package Management

Primer 4:
Processes, Environment Variables, Configuration, and Secrets

Part 4:
Environment Variables and Runtime Configuration

Part 5:
Simplified and Compressed Series

Quiz and Answer-Key Pack

Student Workbook

Trainer Guide
```

## Trainer preparation materials

Before delivery, the trainer should have:

- A clean Windows test account
- PowerShell 7
- Node.js 20 or later
- npm and npx
- Git, if Git exercises will be demonstrated
- Visual Studio Code or another editor
- A copy of the tutorial materials
- A clean copy of the student workbook
- A separate copy of the quiz answer keys
- A screen-sharing or projection setup
- A backup plan for restricted corporate devices

---

# 5. Recommended Delivery Models

## Option A: Three full workshop days

### Day 1: PowerShell and the filesystem

| Module | Suggested time |
|---|---:|
| Introduction and environment check | 45 minutes |
| Primer 1 | 90 minutes |
| Part 1 | 120 minutes |
| Primer 2 | 90 minutes |
| Part 2 introduction and practice | 120 minutes |
| Review and quiz | 45 minutes |

### Day 2: Node.js and HTTP

| Module | Suggested time |
|---|---:|
| Day 1 review | 30 minutes |
| Primer 3 | 150 minutes |
| Part 3 project setup | 150 minutes |
| HTTP service and testing | 120 minutes |
| npm workflow and execution policy | 60 minutes |
| Review and quizzes | 45 minutes |

### Day 3: Configuration and production workflow

| Module | Suggested time |
|---|---:|
| Review | 30 minutes |
| Primer 4 | 120 minutes |
| Part 4 implementation | 180 minutes |
| Profile customization | 60 minutes |
| Production smoke test | 60 minutes |
| Capstone assessment | 120 minutes |
| Final review | 30 minutes |

---

## Option B: Six half-day sessions

| Session | Content |
|---|---|
| 1 | Part 0 and Primer 1 |
| 2 | Part 1 and navigation practice |
| 3 | Primer 2 and Part 2 |
| 4 | Primer 3 and early Part 3 |
| 5 | Complete Part 3 and begin Primer 4 |
| 6 | Part 4, capstone, and review |

This model gives beginners more time between sessions to practice.

---

## Option C: Ten short modules

Use one module for each quiz topic:

1. PowerShell command syntax
2. Navigation and paths
3. Filesystem safety
4. File management
5. JavaScript and Node.js
6. npm and packages
7. HTTP services
8. Environment variables
9. Secrets and profiles
10. Capstone and practical assessment

Suggested module duration:

```text
90–120 minutes each
```

---

# 6. Environment Preparation

## 6.1 Trainer preflight check

Run:

```powershell
$PSVersionTable.PSEdition
$PSVersionTable.PSVersion

node --version
npm.cmd --version
npx.cmd --version

Get-Command git -ErrorAction SilentlyContinue
Get-ExecutionPolicy -List
```

Recommended baseline:

```text
PowerShell 7+
Node.js 20+
npm included with Node.js
```

Windows PowerShell 5.1 can perform many exercises, but some modern APIs and examples are smoother in PowerShell 7.

## 6.2 Confirm write access

Run:

```powershell
$trainerTestPath = Join-Path `
    -Path $HOME `
    -ChildPath "trainer-preflight-test.txt"

try {
    Set-Content `
        -LiteralPath $trainerTestPath `
        -Value "Trainer preflight test." `
        -Encoding UTF8 `
        -ErrorAction Stop

    if (-not (
        Test-Path `
            -LiteralPath $trainerTestPath `
            -PathType Leaf
    )) {
        throw "The preflight file was not created."
    }

    Write-Host "Home-directory write access passed." `
        -ForegroundColor Green
}
finally {
    Remove-Item `
        -LiteralPath $trainerTestPath `
        -Force `
        -ErrorAction SilentlyContinue
}
```

## 6.3 Check network access

npm exercises require access to the package registry.

Run:

```powershell
npm.cmd view express version
```

If this fails, investigate:

- Proxy requirements
- TLS interception
- Private npm registry settings
- Firewall restrictions
- Offline classroom conditions

Do not spend workshop time diagnosing organizational network controls if they can be identified before delivery.

## 6.4 Prepare an offline fallback

For restricted environments, prepare:

- A preinstalled Node.js runtime
- A prepopulated npm cache if organizationally permitted
- A zipped project after dependency installation
- Printed or local copies of documentation
- An alternative built-in Node.js HTTP lab that does not require Express

Clearly tell learners when an offline fallback differs from the standard workflow.

---

# 7. Classroom Safety Controls

## Required rule

All destructive exercises must remain inside named tutorial laboratories.

Approved examples include:

```text
$HOME\powershell-safety-primer
$HOME\cli-developer-environment-series\filesystem-lab
$HOME\cli-series-assessment
```

Never instruct learners to practice deletion in:

```text
$HOME
C:\
Documents
Desktop
A real repository
A synchronized company folder
A production directory
```

## Trainer safety announcement

Read or paraphrase this before the first mutation exercise:

> PowerShell can change many files quickly. During this course, every destructive command must target a named disposable laboratory. Before deletion, we will locate, resolve, inspect, preview, execute, and verify. Do not substitute personal or company directories.

## Trainer screen-sharing practice

Before displaying any destructive command:

1. Display `Get-Location`.
2. Display the resolved target.
3. Display its contents.
4. Run the `-WhatIf` version.
5. Pause and ask learners what will happen.
6. Run the real operation only after confirming the target.
7. Verify the outcome.

Do not normalize unsafe habits by saying:

> It is only a demo, so I will skip `-WhatIf`.

The demonstration is where learners acquire the habit.

---

# 8. Facilitation Principles

## 8.1 Explain before typing

Before introducing a command, explain:

- Why it is needed
- Whether it reads or changes state
- What input it accepts
- What output to expect
- How success will be verified

## 8.2 Ask learners to predict outcomes

Examples:

- “Which directory will this relative path reach?”
- “Will this include hidden files?”
- “What type will Node.js receive for `PORT`?”
- “Which value wins: `$env:PORT` or `.env`?”
- “Does `-WhatIf` create a backup?”

Prediction reveals misconceptions before the learner executes a command.

## 8.3 Prefer native cmdlet names

Use:

```powershell
Get-ChildItem
Set-Location
Copy-Item
Remove-Item
```

Explain aliases, but use full names in reusable examples.

## 8.4 Verify every mutation

After:

```powershell
Copy-Item
```

verify source, destination, and content.

After:

```powershell
Move-Item
```

verify source absence and destination presence.

After:

```powershell
Remove-Item
```

verify target absence and unrelated-item survival.

## 8.5 Separate conceptual depth from implementation flow

Teach only enough theory to support the immediate exercise. Reserve deeper comparisons for review and reference periods.

---

# 9. Lesson Plan: Part 0 and Course Orientation

## Duration

```text
30–45 minutes
```

## Learning outcomes

Learners should be able to:

- Describe the course architecture
- Identify the final project
- Explain why PowerShell skills precede Node.js tooling
- State the safety rules
- Verify their development environment

## Opening prompt

Ask:

> Which developer tasks do you currently perform with File Explorer or by copying commands without understanding them?

Record responses such as:

- Finding project folders
- Renaming files
- Installing packages
- Starting services
- Setting environment variables
- Cleaning generated output

Connect those tasks to the course.

## Demonstration

Run:

```powershell
$PSVersionTable
node --version
npm.cmd --version
```

Explain why `npm.cmd` appears in the course:

- It is a Windows command wrapper.
- It avoids a common `npm.ps1` execution-policy issue.
- It does not require weakening policy.

## Formative questions

1. What is a shell?
2. Why is a dedicated laboratory important?
3. What final service will we build?
4. What should never be pasted into a classroom answer?

## Completion evidence

Learners complete the Student Workbook’s environment-readiness record.

---

# 10. Lesson Plan: Primer 1

## Topic

How to Read PowerShell Commands

## Duration

```text
90–120 minutes
```

## Learning outcomes

Learners can identify:

- Command
- Parameter
- Parameter value
- Switch
- Variable
- Pipeline
- Current pipeline object
- Property
- Script block
- Alias

## Recommended teaching sequence

### 1. Begin with one simple command

```powershell
Get-Location
```

### 2. Add one parameter

```powershell
Get-Date -Format "yyyy-MM-dd"
```

### 3. Add a variable

```powershell
$homePath = $HOME
```

### 4. Add a pipeline

```powershell
Get-ChildItem -File |
    Select-Object Name, Length
```

### 5. Add filtering

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 0
    }
```

Do not begin with a five-stage pipeline before learners understand each component.

## Whiteboard decomposition

Write:

```powershell
Get-ChildItem -LiteralPath $documentsPath -File |
    Where-Object {
        $_.Extension -eq ".json"
    } |
    Select-Object Name, Length
```

Ask learners to label every element.

Expected decomposition:

| Element | Meaning |
|---|---|
| `Get-ChildItem` | Cmdlet |
| `-LiteralPath` | Named parameter |
| `$documentsPath` | Variable used as parameter value |
| `-File` | Switch |
| `\|` | Pipeline |
| `Where-Object` | Filtering command |
| `{...}` | Script block |
| `$_` | Current pipeline object |
| `.Extension` | Object property |
| `-eq` | Equality operator |
| `Select-Object` | Property projection |

## Common misconceptions

### Misconception: `ls` is the Unix executable

Correction:

```powershell
Get-Command ls
Get-Alias ls
```

### Misconception: PowerShell pipelines pass only text

Correction:

```powershell
Get-Item .\example.txt |
    Get-Member
```

### Misconception: `$_` means the current directory

Correction:

- `.` as a path means current directory.
- `$_` in a processing block means current pipeline object.

### Misconception: single and double quotes are interchangeable

Demonstrate:

```powershell
$name = "Ada"

"Hello, $name"
'Hello, $name'
```

## Guided practice

Use Student Workbook Unit 1, Exercises 1.1–1.6.

## Assessment

Use Quiz 1.

Suggested threshold before continuing:

```text
75%
```

Learners below the threshold should repeat the command-deconstruction exercise.

---

# 11. Lesson Plan: Part 1

## Topic

Navigation and Inspection

## Duration

```text
120–150 minutes
```

## Learning outcomes

Learners can:

- Identify current location
- Navigate using absolute and relative paths
- Return home
- Move to parent directories
- Use tab completion
- List files and directories
- Filter by extension
- Include hidden items
- Recurse safely
- Discover available filesystem drives

## Demonstration sequence

### Current location

```powershell
Get-Location
```

### Home

```powershell
Set-Location -Path $HOME
```

### Absolute path

```powershell
Set-Location `
    -LiteralPath "$HOME\cli-developer-environment-series"
```

### Relative path

```powershell
Set-Location -Path .\filesystem-lab
```

### Parent

```powershell
Set-Location -Path ..
```

### Listing

```powershell
Get-ChildItem
Get-ChildItem -File
Get-ChildItem -Directory
Get-ChildItem -Force
```

### Recursive filtering

```powershell
Get-ChildItem `
    -Path . `
    -Filter "*.json" `
    -File `
    -Recurse
```

## Teaching analogy

Use postal directions:

- Absolute path: full street address
- Relative path: instructions from the current room
- `$HOME`: the user’s default residence
- `..`: one level up
- `.`: here

## Formative checks

Ask learners:

1. If the current directory changes, does `.\src` still identify the same path?
2. Does `Get-ChildItem -Force` grant additional NTFS permission?
3. Why might recursion from `C:\` be a poor idea?
4. What does `Test-Path -PathType Container` prove?

## Common problems

### Path contains spaces

Use:

```powershell
Set-Location `
    -LiteralPath "C:\Development Projects"
```

### Learner is in the wrong drive

Use:

```powershell
Get-PSDrive -PSProvider FileSystem
Set-Location -Path "D:\"
```

only when `D:` exists.

### Hidden file is missing

Use:

```powershell
Get-ChildItem -Force
```

## Assessment

Use Quiz 2 and Student Workbook Unit 2.

---

# 12. Lesson Plan: Primer 2 and Part 2

## Topic

Filesystem Safety and Management

## Duration

```text
180–240 minutes
```

## Critical outcome

Learners must consistently apply:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

Do not pass learners who can type deletion commands but cannot explain and apply the safety sequence.

## Demonstration: exact deletion workflow

```powershell
Get-Location

$target = Join-Path `
    -Path $approvedRoot `
    -ChildPath "disposable-tree"

$resolvedTarget = (
    Resolve-Path `
        -LiteralPath $target `
        -ErrorAction Stop
).Path

Get-Item `
    -LiteralPath $resolvedTarget `
    -Force

Get-ChildItem `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -Force

Remove-Item `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -WhatIf

Remove-Item `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -ErrorAction Stop

Test-Path -LiteralPath $resolvedTarget
```

## Pause points

Before the real deletion, ask:

- Is the target absolute?
- Does it exist?
- Is it a directory?
- Is it inside the approved root?
- What descendants will be removed?
- Does the preview match the intended target?
- Which unrelated item will we verify afterward?

## Teach `-Force` carefully

Required language:

> `-Force` can handle some ordinary provider restrictions, such as hidden or read-only attributes. It does not grant administrator rights or bypass all Windows security.

Avoid saying:

> `-Force` makes PowerShell do it no matter what.

## Teach wildcard materialization

Preferred:

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

Explain that the learner is inspecting a fixed collection.

## Reparse points

For beginners, teach the practical rule:

> A path can redirect elsewhere. An approved path prefix is a useful guardrail, not a complete security sandbox.

Do not turn the session into a full NTFS internals lecture unless the audience needs it.

## Common misconceptions

- `-WhatIf` creates a backup.
- `Remove-Item` uses the Recycle Bin.
- `-Force` bypasses permissions.
- Copy operations are always harmless.
- An error-free copy proves identical content.
- A target inside the current directory is automatically safe.

## Guided practice

Use Student Workbook Units 3 and 4.

## Assessment

Use Quiz 3 and Practical Lab Tasks 1–6.

## Mandatory practical evidence

Learner must demonstrate:

- Exact path construction
- Type check
- Inventory
- `-WhatIf`
- Real mutation
- Verification
- Preservation of an unrelated item

---

# 13. Lesson Plan: Primer 3

## Topic

JavaScript, Node.js, Packages, and HTTP

## Duration

```text
150–180 minutes
```

## Learning outcomes

Learners can explain:

- JavaScript versus Node.js
- Values and variables
- Arrays and objects
- Functions
- CommonJS modules
- JSON
- Promises and `async`/`await`
- Processes and exit codes
- Packages and dependencies
- HTTP request-response flow

## Scope control

Do not attempt to teach the entire JavaScript language.

Focus on constructs directly used by the service:

```javascript
const
let
objects
arrays
functions
require
module.exports
async
await
try
catch
JSON.parse
JSON.stringify
```

## Demonstration progression

### Runtime

```powershell
node -e 'console.log(process.version);'
```

### Values

```javascript
const host = "127.0.0.1";
const port = 3000;
const ready = true;
```

### Object

```javascript
const configuration = {
  host,
  port,
  ready,
};
```

### Function

```javascript
function buildAddress(host, port) {
  return `http://${host}:${port}`;
}
```

### Module

```javascript
module.exports = {
  buildAddress,
};
```

### Asynchronous operation

```javascript
async function main() {
  const value = await Promise.resolve("ready");
  console.log(value);
}
```

### Error handling

```javascript
try {
  throw new Error("Controlled failure.");
} catch (error) {
  console.error(error.message);
}
```

## HTTP teaching diagram

```text
PowerShell client
      │
      │ GET /health
      ▼
Node.js HTTP server
      │
      │ 200 + JSON
      ▼
PowerShell object
```

## Common misconceptions

- Node.js and JavaScript are the same thing.
- JSON is a JavaScript program.
- `const` deeply freezes an object.
- `async` means multiple CPU threads.
- `await` blocks the entire computer.
- Port `0` means the test server is disabled.
- A method such as `DELETE` provides authorization.
- Sending a response does not require returning from the route.

## Assessment

Use Quizzes 4 and 6.

---

# 14. Lesson Plan: Part 3

## Topic

Node.js Project Lifecycle

## Duration

```text
180–240 minutes
```

## Learning outcomes

Learners can:

- Initialize a project
- Read the manifest
- Install dependencies
- Explain lockfiles
- Run npm scripts
- Use local package binaries
- Build and test the service
- Diagnose PowerShell wrapper errors

## Demonstration: project resources

Draw:

```text
package.json
      │ declares
      ▼
package-lock.json
      │ resolves exactly
      ▼
npm ci
      │ installs
      ▼
node_modules
```

Explain:

- `package.json` is the declared requirement.
- `package-lock.json` is the exact resolution.
- `node_modules` is generated installation output.

## Dependency installation

```powershell
npm.cmd install express
npm.cmd install --save-dev eslint
```

Immediately inspect:

```powershell
npm.cmd list --depth=0

Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json
```

## npm script progression

```powershell
npm.cmd run lint
npm.cmd test
npm.cmd run build
npm.cmd run check
npm.cmd run dev
npm.cmd start
```

Ask learners to explain each command before running it.

## Execution-policy teaching order

1. Inspect:

   ```powershell
   Get-ExecutionPolicy -List
   Get-Command npm -All
   ```

2. Try the narrow workaround:

   ```powershell
   npm.cmd --version
   ```

3. Discuss process scope only if needed:

   ```powershell
   Set-ExecutionPolicy `
       -Scope Process `
       -ExecutionPolicy Bypass
   ```

4. Discuss `CurrentUser RemoteSigned` as an informed, policy-dependent choice.

Never lead with a machine-wide policy change.

## Common npm problems

### `npm` command not found

- Restart terminal after Node.js installation.
- Check `PATH`.
- Run `Get-Command node`, `Get-Command npm.cmd`.

### `npm.ps1` blocked

Use:

```powershell
npm.cmd
```

### `npm ci` fails

Check:

- `package-lock.json` exists.
- Manifest and lockfile agree.
- Network or registry is accessible.
- The working directory is correct.

### Port already in use

Use:

```powershell
Get-NetTCPConnection `
    -LocalPort 3000 `
    -ErrorAction SilentlyContinue
```

or temporarily choose another validated port.

## Assessment

Use Quiz 5 and the project lifecycle portions of Quiz 10.

---

# 15. Lesson Plan: Primer 4

## Topic

Processes, Environment Variables, Configuration, and Secrets

## Duration

```text
120–150 minutes
```

## Learning outcomes

Learners can:

- Explain process inheritance
- Use `Env:`
- Manage temporary variables
- Compare process, user, and machine scope
- Explain why values are strings
- Classify secrets
- Explain `.env` precedence
- Avoid secret disclosure

## Core demonstration: inheritance

```powershell
$env:PRIMER_MODE = "training"

try {
    node -e '
console.log(process.env.PRIMER_MODE);
'
}
finally {
    Remove-Item Env:PRIMER_MODE `
        -ErrorAction SilentlyContinue
}
```

Ask:

- Who created the value?
- Which process inherited it?
- Does Node.js changing its copy modify PowerShell?

## Demonstrate string behavior

```powershell
$env:FEATURE_ENABLED = "false"

try {
    node -e '
console.log({
  raw: process.env.FEATURE_ENABLED,
  type: typeof process.env.FEATURE_ENABLED,
  unsafeBoolean: Boolean(process.env.FEATURE_ENABLED)
});
'
}
finally {
    Remove-Item Env:FEATURE_ENABLED `
        -ErrorAction SilentlyContinue
}
```

Expected surprise:

```text
Boolean("false") === true
```

Use this to justify explicit validation.

## Secret classification activity

Give groups these names:

```text
NODE_ENV
PORT
LOG_LEVEL
APP_SECRET
API_TOKEN
DATABASE_PASSWORD
PRIVATE_KEY
```

Ask them to classify each and identify what may be logged.

## Required statement

> `.env` separates local configuration from source code, but it is normally plaintext and is not a production secret vault.

## Assessment

Use Quizzes 7 and 8.

---

# 16. Lesson Plan: Part 4

## Topic

Validated Runtime Configuration and Profiles

## Duration

```text
180–240 minutes
```

## Learning outcomes

Learners can:

- Install and configure `dotenv`
- Create `.env` and `.env.example`
- Verify Git exclusions
- Build a validation module
- Apply precedence correctly
- Test invalid configuration
- Create public configuration output
- Customize a profile safely
- Run production-style smoke tests

## Teach configuration as a boundary

Draw:

```text
Untrusted strings
      │
      ▼
Validation and conversion
      │
      ▼
Immutable application configuration
```

Use examples:

```text
"3000"       → 3000
"preview"    → error
"70000"      → error
missing key  → error
placeholder  → error
```

## Demonstrate precedence

Local `.env`:

```dotenv
PORT=3000
```

Temporary override:

```powershell
$env:PORT = "3200"

try {
    npm.cmd run config
}
finally {
    Remove-Item Env:PORT `
        -ErrorAction SilentlyContinue
}
```

Ask:

> Why did the application choose 3200?

Expected answer:

> Existing process environment values outrank `.env` fallback values because `override` is false.

## Teach public projection

Unsafe:

```javascript
console.log(configuration);
```

Safe:

```javascript
console.log({
  environment: configuration.environment,
  host: configuration.host,
  port: configuration.port,
});
```

Emphasize omission rather than redaction.

## Profile teaching

Appropriate:

- Navigation functions
- Quality-check function
- General aliases

Inappropriate:

- `APP_SECRET`
- Production mode
- Database passwords
- API tokens

## Assessment

Use Quiz 9 and the configuration portions of Quiz 10.

---

# 17. Part 5 and Review Session

## Purpose

Part 5 is a refresher and operational quickstart. It should not be the learner’s first exposure to the concepts unless the audience already has foundational experience.

## Recommended activities

- Ask learners to reconstruct the architecture from memory.
- Have learners explain the daily workflow.
- Run the compressed final verification.
- Assign Quiz 10.
- Complete the capstone workbook.
- Conduct a learner-led demonstration.

## Learner-led demonstration prompt

Each learner or pair should demonstrate:

1. Navigate to the project.
2. Inspect `package.json`.
3. Run `npm ci`.
4. Run the quality gate.
5. Display public configuration.
6. Start the development service.
7. Call `/health`.
8. Stop the service.
9. Explain why no secret was displayed.

---

# 18. Assessment Strategy

Use three forms of assessment.

## 18.1 Formative assessment

Occurs during instruction.

Examples:

- Prediction questions
- Command decomposition
- Peer explanations
- Quick checks
- Workbook evidence
- Instructor observation

Do not grade every formative activity. Its purpose is to expose misconceptions early.

## 18.2 Knowledge assessment

Use the quiz pack.

Recommended mapping:

| Content | Assessment |
|---|---|
| Primer 1 | Quiz 1 |
| Part 1 | Quiz 2 |
| Primer 2 and Part 2 | Quiz 3 |
| Primer 3 | Quiz 4 |
| Part 3 | Quiz 5 |
| HTTP | Quiz 6 |
| Primer 4 | Quizzes 7–8 |
| Profiles | Quiz 9 |
| Complete series | Quiz 10 |

## 18.3 Performance assessment

Use:

- Practical Lab
- Capstone Workbook
- Live learner demonstration

A learner should not pass solely through multiple-choice performance. The course teaches operational skills that require demonstration.

---

# 19. Practical Assessment Rubric

Suggested total:

```text
100 points
```

## A. PowerShell command use — 15 points

| Criterion | Points |
|---|---:|
| Uses native cmdlet names in reusable work | 3 |
| Uses correct parameters and values | 3 |
| Uses variables appropriately | 3 |
| Reads and uses object properties | 3 |
| Handles errors deliberately | 3 |

## B. Navigation and inspection — 15 points

| Criterion | Points |
|---|---:|
| Confirms current location | 3 |
| Uses absolute and relative paths correctly | 3 |
| Uses `Test-Path` with correct type | 3 |
| Resolves paths | 3 |
| Lists hidden and recursive content appropriately | 3 |

## C. Filesystem safety — 20 points

| Criterion | Points |
|---|---:|
| Works inside approved laboratory | 4 |
| Inspects exact targets | 4 |
| Uses `-WhatIf` | 4 |
| Understands `-Recurse` and `-Force` | 4 |
| Verifies intended and unrelated results | 4 |

## D. Node.js and npm — 15 points

| Criterion | Points |
|---|---:|
| Explains project resources | 3 |
| Installs dependencies correctly | 3 |
| Uses npm scripts | 3 |
| Uses `npm ci` | 3 |
| Diagnoses command-wrapper issues safely | 3 |

## E. HTTP service — 15 points

| Criterion | Points |
|---|---:|
| Starts the service successfully | 3 |
| Calls the health endpoint | 3 |
| Sends a JSON POST request | 3 |
| Interprets status codes correctly | 3 |
| Stops the service cleanly | 3 |

## F. Configuration and secrets — 20 points

| Criterion | Points |
|---|---:|
| Manages temporary variables safely | 4 |
| Explains environment inheritance | 4 |
| Validates and converts configuration | 4 |
| Protects `.env` and tracks `.env.example` | 4 |
| Omits secrets from output and profiles | 4 |

## Performance levels

| Score | Level |
|---:|---|
| 90–100 | Independent |
| 80–89 | Proficient |
| 70–79 | Developing |
| 60–69 | Needs guided remediation |
| Below 60 | Not yet competent |

## Automatic remediation triggers

Require remediation regardless of total score if the learner:

- Runs broad deletion outside the laboratory
- Skips `-WhatIf` after being instructed to preview
- Prints a real secret
- Places a secret in Git or `$PROFILE`
- Applies a machine-wide unrestricted execution policy without authorization
- Cannot explain the target of a destructive command
- Cannot verify whether a deletion preserved unrelated data

Safety failures should not be averaged away by strong multiple-choice scores.

---

# 20. Observation Checklist

Use this during hands-on work.

## PowerShell behavior

- [ ] Reads the command before executing it
- [ ] Checks current location
- [ ] Uses tab completion
- [ ] Uses full cmdlet names in scripts
- [ ] Uses `-LiteralPath` for exact mutations
- [ ] Checks errors instead of ignoring them
- [ ] Verifies results

## Filesystem safety

- [ ] Uses the approved laboratory
- [ ] Resolves the target
- [ ] Inspects descendants
- [ ] Uses `-WhatIf`
- [ ] Does not add `-Force` automatically
- [ ] Verifies unrelated files survived

## Node.js and npm

- [ ] Runs commands from the project root
- [ ] Distinguishes `node`, `npm`, and `npx`
- [ ] Understands the lockfile
- [ ] Uses `npm ci` appropriately
- [ ] Uses project scripts rather than memorized low-level commands

## HTTP

- [ ] Identifies the correct host and port
- [ ] Uses the correct HTTP method
- [ ] Converts PowerShell objects to JSON
- [ ] Interprets status codes
- [ ] Stops server processes after testing

## Configuration

- [ ] Removes temporary environment variables
- [ ] Understands string conversion
- [ ] Rejects invalid values
- [ ] Does not display secrets
- [ ] Keeps secrets out of the profile

---

# 21. Feedback Templates

## Effective positive feedback

> You resolved the target, inspected its descendants, previewed the operation, and verified both the deletion and the survival of the sibling file. That is the complete safety workflow.

> You used `npm.cmd` to solve the wrapper issue without changing execution policy. That was the narrowest appropriate response.

> Your public configuration output used an allowlist and omitted the secret entirely. That is safer than copying the whole configuration and redacting known fields.

## Corrective feedback

> You ran the correct deletion command, but you did not first prove which directory the relative path identified. Repeat the exercise using `Get-Location`, `Resolve-Path`, and `-WhatIf`.

> Your application accepted an invalid port by silently falling back to 3000. Replace the fallback with explicit validation and a startup error.

> The HTTP request was correct, but the server process remained running after the test. Add cleanup using `finally` or stop the process explicitly.

## Safety intervention

> Stop here. Do not execute that command. The target is outside the approved laboratory. Reconstruct the intended path from `$HOME`, resolve it, and show the complete inventory before continuing.

---

# 22. Common Misconceptions and Corrections

## PowerShell

### “PowerShell is just Command Prompt with different colors.”

Correction:

PowerShell uses cmdlets, providers, structured objects, pipelines, scripting, modules, and .NET APIs.

### “`ls` proves PowerShell is Bash.”

Correction:

```powershell
Get-Alias ls
```

normally shows:

```text
ls → Get-ChildItem
```

### “The pipeline passes displayed text.”

Correction:

Use:

```powershell
Get-Item .\package.json |
    Get-Member
```

to show structured object members.

---

## Filesystem

### “A relative path is safe because it is short.”

Correction:

Its meaning depends on the current location.

### “`-WhatIf` creates an undo point.”

Correction:

It only previews supported behavior.

### “`-Force` means PowerShell can override anything.”

Correction:

It does not grant permission, take ownership, or defeat security policy.

### “Deleting a directory sends it to the Recycle Bin.”

Correction:

Treat `Remove-Item` as direct deletion.

---

## Node.js

### “Node.js is a programming language.”

Correction:

JavaScript is the language; Node.js is a runtime.

### “`const` makes an object immutable.”

Correction:

It prevents variable reassignment. Use `Object.freeze` for shallow object immutability.

### “Every asynchronous function runs on another thread.”

Correction:

Promises and `async`/`await` express future outcomes; they do not imply a dedicated thread per function.

---

## npm

### “`package.json` records exact installed versions.”

Correction:

The manifest may allow ranges. `package-lock.json` records exact resolution.

### “`node_modules` is source code that should be committed.”

Correction:

It is generated installation output.

### “npx is safe because the package is temporary.”

Correction:

Temporary code still executes with the user’s permissions.

---

## HTTP

### “A route named `/health` makes a service healthy.”

Correction:

The route must perform or report meaningful checks appropriate to the system.

### “HTTP `DELETE` automatically authorizes deletion.”

Correction:

Methods express intent; authorization remains an application responsibility.

### “A JSON error body with HTTP 200 is acceptable for every failure.”

Correction:

Status codes should accurately represent outcomes.

---

## Configuration

### “Environment variables have types.”

Correction:

Operating-system environment values are strings or absent.

### “`Boolean("false")` is false.”

Correction:

It is true because the string is nonempty.

### “`.env` is secure because it is hidden.”

Correction:

It is normally plaintext.

### “Deleting a secret from the latest Git revision fixes exposure.”

Correction:

Rotate it and investigate history, logs, artifacts, and backups.

---

# 23. Troubleshooting Guide

## `node` is not recognized

Check:

```powershell
Get-Command node -ErrorAction SilentlyContinue
$env:PATH -split ";"
```

Actions:

1. Confirm Node.js installation.
2. Close and reopen the terminal.
3. Verify the installer added Node.js to `PATH`.
4. Use the official LTS installer or approved package manager.

---

## `npm.ps1` is blocked

Inspect:

```powershell
Get-ExecutionPolicy -List
Get-Command npm -All
```

Try:

```powershell
npm.cmd --version
```

Do not automatically change machine-wide policy.

---

## `npm ci` fails because manifest and lockfile differ

Use during development:

```powershell
npm.cmd install
```

Review changes to:

```text
package.json
package-lock.json
```

Then retry:

```powershell
npm.cmd ci
```

Do not delete the lockfile reflexively.

---

## Package installation fails

Check:

```powershell
npm.cmd config get registry
npm.cmd ping
```

Possible causes:

- Proxy
- Private registry
- Certificate interception
- Firewall
- Network outage
- Invalid package version

Follow organizational network guidance.

---

## Port is already in use

Check:

```powershell
Get-NetTCPConnection `
    -LocalPort 3000 `
    -ErrorAction SilentlyContinue
```

Inspect the owning process:

```powershell
$connection = Get-NetTCPConnection `
    -LocalPort 3000 `
    -ErrorAction SilentlyContinue |
    Select-Object -First 1

if ($null -ne $connection) {
    Get-Process -Id $connection.OwningProcess
}
```

Do not kill an unfamiliar process without identifying it. Use another valid development port when appropriate.

---

## Service starts but requests fail

Check:

- Correct host
- Correct port
- Correct route
- Server terminal for startup errors
- Environment overrides
- Firewall behavior
- Whether the process exited

Run:

```powershell
npm.cmd run config
```

Then:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -TimeoutSec 2
```

---

## Tests remain running

Likely causes:

- An HTTP server was not closed
- A timer remains referenced
- A child process remains alive
- A network connection remains open

Check cleanup hooks and `finally` blocks.

---

## `.env` changes appear to have no effect

Check for a higher-precedence process value:

```powershell
Get-Item Env:PORT -ErrorAction SilentlyContinue
```

Remove it if appropriate:

```powershell
Remove-Item Env:PORT
```

Then rerun configuration inspection.

---

## Git does not ignore `.env`

Check:

```powershell
git check-ignore -v .env
```

If `.env` is already tracked, `.gitignore` will not untrack it automatically.

Use an approved process to remove it from tracking, and rotate any exposed secret.

Do not teach history-rewriting commands casually in a beginner class without backups and organizational approval.

---

## Profile causes startup errors

Start without the profile:

```powershell
pwsh -NoProfile
```

Parse it:

```powershell
$tokens = $null
$errors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $PROFILE.CurrentUserCurrentHost,
    [ref] $tokens,
    [ref] $errors
) | Out-Null

$errors
```

Restore a backup if necessary.

---

# 24. Differentiation Strategies

## For learners who need more support

- Provide preconstructed path variables.
- Use pair programming.
- Reduce command length through splatting.
- Ask learners to annotate commands before execution.
- Repeat the same safety sequence across several examples.
- Use diagrams for process inheritance.
- Delay profile customization until core tasks are stable.
- Allow built-in help during assessments.

## For experienced learners

Offer extensions:

- Convert repeated PowerShell commands into advanced functions.
- Add `SupportsShouldProcess`.
- Add Pester tests for PowerShell scripts.
- Compare CommonJS with ES modules.
- Add structured logging.
- Add signal-aware child-process smoke tests.
- Containerize the Node.js service.
- Use a managed secret provider.
- Add CI with `npm ci` and `npm run check`.
- Add dependency and secret scanning.

Extensions should preserve the course’s safety and secret-handling principles.

## For Bash-experienced learners

Explicitly compare concepts:

| Bash-like concept | PowerShell model |
|---|---|
| Text pipeline | Object pipeline |
| `pwd` | Alias to `Get-Location` |
| `ls` | Alias to `Get-ChildItem` |
| `export NAME=value` | `$env:NAME = "value"` |
| `.bashrc` | PowerShell profile |
| `which` | `Get-Command` |

Warn against copying Bash flags into PowerShell aliases.

---

# 25. Virtual Delivery Guidance

## Before the session

Ask learners to:

- Install required tools
- Run the preflight commands
- Send only version information—not environment dumps
- Confirm they can open two terminals
- Download local materials

## During demonstrations

- Increase terminal font size.
- Use a visible prompt.
- Avoid showing real personal environment variables.
- Clear unrelated terminal history.
- Explain which terminal is server and which is client.
- Pause after each state-changing command.
- Paste commands in complete logical blocks.

## Breakout activities

Use pairs:

- Driver: types and executes
- Navigator: reads, predicts, and checks safety
- Swap roles after each exercise

For destructive exercises, require the navigator to verbally confirm:

```text
location
target
inventory
preview
verification plan
```

---

# 26. Accessibility and Inclusion

Use:

- High-contrast terminal themes
- Large fonts
- Text descriptions in addition to color
- Explicit success and failure wording
- Keyboard-accessible workflows
- Copiable code blocks
- Frequent pauses
- Written definitions of new terminology

Do not rely only on:

```text
green = success
red = failure
```

Always include words such as:

```text
PASSED
FAILED
WARNING
```

Allow additional time for learners using assistive technologies or alternative input methods.

---

# 27. Academic Integrity and AI Assistance

If learners may use AI tools, establish rules before assessment.

Suggested policy:

## Allowed during practice

- Asking for explanations
- Asking for error interpretation
- Generating additional examples
- Reviewing code after the learner attempts it

## Restricted during assessment

- Generating complete assessment solutions
- Copying commands without explanation
- Submitting code the learner cannot explain
- Sharing real secrets in prompts

Require learners to explain:

- Every state-changing command
- Every path target
- Every configuration precedence decision
- Every secret-handling control

Operational understanding matters more than command memorization.

---

# 28. Suggested Homework

## After PowerShell syntax

Create a one-page command anatomy sheet containing:

- Cmdlet
- Parameter
- Switch
- Variable
- Pipeline
- Property
- Script block
- `$_`

## After navigation

Create a report listing:

- Current location
- Home directory
- Filesystem drives
- Five largest files inside a disposable laboratory

## After file management

Create a verified archive script supporting:

```text
-Source
-Destination
-WhatIf
```

## After Node.js

Add one read-only route to the service and one automated test.

## After configuration

Add one validated Boolean feature flag using the explicit values:

```text
true
false
```

Reject every other value.

## Final extension

Create a CI workflow that runs:

```powershell
npm ci
npm run check
```

Do not include `.env` or secrets in the workflow file.

---

# 29. Model Boolean Feature-Flag Extension

Use this only after learners attempt the homework.

```javascript
function parseBoolean(environment, name) {
  const rawValue = environment[name];

  if (rawValue === "true") {
    return true;
  }

  if (rawValue === "false") {
    return false;
  }

  throw new Error(
    `${name} must be either true or false.`,
  );
}
```

Test cases:

```javascript
test("true is parsed", () => {
  assert.equal(
    parseBoolean({
      FEATURE_ENABLED: "true",
    }, "FEATURE_ENABLED"),
    true,
  );
});

test("false is parsed", () => {
  assert.equal(
    parseBoolean({
      FEATURE_ENABLED: "false",
    }, "FEATURE_ENABLED"),
    false,
  );
});

test("other values are rejected", () => {
  assert.throws(
    () => parseBoolean({
      FEATURE_ENABLED: "yes",
    }, "FEATURE_ENABLED"),
    /must be either true or false/,
  );
});
```

Teaching point:

```javascript
Boolean("false") === true
```

Therefore, explicit parsing is required.

---

# 30. Trainer Demonstration Checklist

Before each live demonstration:

- [ ] The current directory is visible.
- [ ] The target is inside a disposable laboratory.
- [ ] No real secret is visible.
- [ ] The expected output is known.
- [ ] The recovery plan is known.
- [ ] The terminal font is readable.
- [ ] The command has been tested on the trainer’s environment.

During each demonstration:

- [ ] Explain the target.
- [ ] Explain the concept.
- [ ] Ask for a prediction.
- [ ] Run the implementation.
- [ ] Verify the result.
- [ ] Invite questions.
- [ ] Record unexpected platform differences.

After each demonstration:

- [ ] Reset variables.
- [ ] Stop server processes.
- [ ] Remove temporary files if appropriate.
- [ ] Return to a predictable directory.
- [ ] Confirm no secret appeared in output.

---

# 31. End-of-Course Capstone Procedure

## Phase 1: Briefing

Give learners the Student Workbook capstone and Practical Lab without the answer key.

Explain that they may use:

```powershell
Get-Command
Get-Help
Get-Member
```

Decide whether they may consult prior tutorial material.

## Phase 2: Safety confirmation

Before learners begin, require them to state:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

## Phase 3: Independent work

Observe without immediately correcting minor mistakes.

Intervene immediately for:

- Unsafe deletion targets
- Secret disclosure
- Unauthorized policy changes
- Attempts to kill unidentified processes
- Work outside the laboratory

## Phase 4: Oral defense

Ask each learner three questions:

1. Why did you use `-LiteralPath` here?
2. Which configuration source has precedence?
3. How did you prove the secret was not exposed?

Optional questions:

- Why did you use `npm ci`?
- Why is `dist` separate from `src`?
- Why does the smoke test add value beyond unit tests?
- Why is the profile not a secret store?

## Phase 5: Final scoring

Combine:

- Knowledge quiz score
- Practical rubric score
- Safety performance
- Oral explanation

---

# 32. Completion Criteria

A learner completes the course successfully when they can independently:

1. Navigate to the project.
2. Inspect files and directories.
3. Create and manipulate resources safely.
4. Preview and verify destructive operations.
5. Reproduce dependencies with `npm ci`.
6. Run the quality gate.
7. Start and test the service.
8. Explain HTTP request-response flow.
9. Apply temporary environment overrides.
10. Explain process inheritance.
11. Validate configuration.
12. Keep secrets out of Git, logs, source, and profiles.
13. Run the production-style smoke test.
14. Explain the architecture in their own words.

Recommended minimums:

```text
Knowledge assessments: 75%
Practical assessment: 80%
Safety-critical criteria: all passed
```

---

# 33. Trainer Post-Course Review

After delivery, record:

## Cohort information

| Item | Record |
|---|---|
| Number enrolled | |
| Number completed | |
| Average quiz score | |
| Average practical score | |
| Most difficult module | |
| Most common technical issue | |
| Most common misconception | |
| Environment restrictions encountered | |

## Reflection prompts

1. Which demonstration produced the clearest understanding?

   ```text
   __________________________________________________________
   ```

2. Where did learners need additional time?

   ```text
   __________________________________________________________
   ```

3. Which instructions should be revised?

   ```text
   __________________________________________________________
   ```

4. Were any commands version-sensitive?

   ```text
   __________________________________________________________
   ```

5. Did any exercise create a safety concern?

   ```text
   __________________________________________________________
   ```

6. What should change before the next delivery?

   ```text
   __________________________________________________________
   ```

---

# 34. Quick Trainer Reference

## Essential PowerShell commands

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

## Essential npm commands

```powershell
npm.cmd init -y
npm.cmd install
npm.cmd ci
npm.cmd list --depth=0
npm.cmd run
npm.cmd test
npm.cmd run check
npm.cmd run dev
npm.cmd start
```

## Essential environment commands

```powershell
Get-ChildItem Env:
$env:PORT = "3000"
Remove-Item Env:PORT
Get-ExecutionPolicy -List
```

## Essential HTTP checks

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get
```

```powershell
$body = @{
    message = "Hello"
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

## Essential safety sequence

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

## Essential secret rule

```text
Do not place real secrets in:
- source code
- .env.example
- Git
- public logs
- PowerShell profiles
- screenshots
- training submissions
```

---

# 35. Final Trainer Checklist

## Before delivery

- [ ] Verified PowerShell and Node.js versions
- [ ] Tested every demonstration
- [ ] Confirmed npm network access
- [ ] Prepared offline fallback
- [ ] Created clean laboratory directories
- [ ] Removed personal secrets from the demo environment
- [ ] Prepared student workbooks
- [ ] Separated answer keys
- [ ] Prepared assessment rubric

## During delivery

- [ ] Defined terminology before use
- [ ] Asked learners to predict commands
- [ ] Demonstrated safe deletion habits
- [ ] Avoided unnecessary elevation
- [ ] Used `npm.cmd` where appropriate
- [ ] Stopped orphan server processes
- [ ] Kept secrets out of output
- [ ] Used frequent verification checkpoints

## After delivery

- [ ] Collected workbook evidence
- [ ] Scored quizzes
- [ ] Scored practical work
- [ ] Reviewed safety-critical performance
- [ ] Completed learner feedback
- [ ] Removed temporary laboratories where appropriate
- [ ] Rotated any credential accidentally exposed
- [ ] Recorded course improvements

---

# Trainer Closing Script

A trainer may close the course with:

> You have built more than a collection of commands. You now have a repeatable developer workflow. You can navigate and modify the Windows filesystem, manage Node.js dependencies, run and test an HTTP service, validate runtime configuration, protect secrets, and automate common tasks. Continue using the same engineering habit throughout your work: understand the target, make the smallest intentional change, and verify the result.

