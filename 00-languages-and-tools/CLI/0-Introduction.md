# Part 0: Introduction

Modern software development involves more than writing application code. Developers constantly move between folders, create and reorganize files, install packages, run scripts, configure environment variables, protect secrets, and automate repetitive commands.

On Windows, all of these tasks can be performed from PowerShell.

PowerShell is not merely a black window into which installation commands are pasted. It is a full command-line shell and scripting environment. A **shell** is a program that accepts commands and uses them to interact with the operating system. PowerShell gives developers a consistent, programmable way to control files, processes, applications, and Windows itself.

This series will take you from basic directory navigation to a practical Node.js development environment with secure runtime configuration and reusable PowerShell shortcuts.

---

## 0.1 Scope of the Series

The series is organized into four hands-on parts:

### Part 1: Navigating the File System like a Native

You will learn how to:

- Display your current location
- Navigate with absolute and relative paths
- Move between Windows drives
- Return to your home directory
- Use tab completion
- Inspect folder contents
- Find files by extension
- Display hidden files
- Search directory trees recursively
- Understand PowerShell aliases such as `cd`, `dir`, `ls`, and `pwd`

Most importantly, you will learn the native PowerShell commands behind those aliases:

```powershell
Set-Location
Get-ChildItem
Get-Location
```

### Part 2: File and Directory Management

You will build a safe practice workspace and use PowerShell to:

- Create files and directories
- Construct nested directory trees
- Copy files and folders
- Rename and move resources
- Remove individual files
- Remove non-empty directories
- Work with hidden or read-only resources
- Preview destructive operations with `-WhatIf`

The `-WhatIf` parameter will be treated as a critical safety tool. It tells PowerShell to describe what a command *would* do without actually making the change.

### Part 3: The Node.js Ecosystem and Package Management

You will create a real Node.js project and learn the different roles of:

- `node`
- `npm`
- `npx`
- `pnpm`
- `package.json`
- `package-lock.json`
- `node_modules`
- npm scripts

You will also learn how PowerShell execution policies affect locally installed JavaScript tools and how to diagnose common errors such as:

```text
npm.ps1 cannot be loaded because running scripts is disabled on this system
```

The goal is not to disable security indiscriminately. Instead, you will learn what the policy controls and apply the narrowest reasonable solution.

### Part 4: Environment Variables and Runtime Configuration

You will configure applications without embedding secrets directly in source code.

You will learn how to:

- Read PowerShell environment variables
- Set temporary session variables
- create persistent user-level variables
- Load application settings from a `.env` file
- Validate runtime configuration
- Prevent `.env` files from entering Git
- Create a safe `.env.example` template
- Customize your PowerShell profile
- Define reusable functions and aliases

By the end, you will have a developer environment that is practical, repeatable, and safer than a collection of manually typed commands.

---

## 0.2 The Final Architecture

This series builds two connected things:

1. A **PowerShell developer workflow**
2. A **Node.js project used to exercise that workflow**

The final workspace will resemble the following structure:

```text
$HOME/
└── cli-developer-environment-series/
    ├── filesystem-lab/
    │   ├── archive/
    │   ├── documents/
    │   ├── incoming/
    │   └── workspace/
    │
    └── developer-service/
        ├── scripts/
        │   ├── build.js
        │   └── clean.js
        │
        ├── src/
        │   ├── config.js
        │   └── index.js
        │
        ├── dist/
        │   ├── config.js
        │   └── index.js
        │
        ├── .env
        ├── .env.example
        ├── .gitignore
        ├── package.json
        └── package-lock.json
```

The exact contents will be introduced progressively. No directory, dependency, variable, or configuration file will appear without first explaining why it exists.

### The filesystem laboratory

The `filesystem-lab` directory will provide a safe place to practice:

- Navigation
- Directory listing
- Filtering
- File creation
- Copying
- Moving
- Renaming
- Deletion

It is deliberately separate from personal documents and real application code. Mistakes made while learning should happen inside a disposable laboratory—not inside an important project.

### The Node.js service

The `developer-service` directory will contain a small Node.js HTTP service.

It will demonstrate:

- Project initialization with npm
- Dependency installation
- Custom npm scripts
- Development and production runtime modes
- Configuration through environment variables
- Secret management through `.env`
- Runtime configuration validation
- Build and cleanup scripts
- Graceful process shutdown

The service itself is intentionally small. Its purpose is to expose the developer-environment concerns that exist in larger applications without burying those lessons beneath a complex framework.

### The PowerShell profile

Outside the project, you will also update your PowerShell profile:

```powershell
$PROFILE
```

A PowerShell profile is a script that runs when a new PowerShell session starts. It is similar to a workshop being prepared before a craftsperson arrives: frequently used tools can already be placed where they are easy to reach.

The profile will eventually hold carefully chosen shortcuts and helper functions. Project-specific secrets will **not** be placed there.

---

## 0.3 Architectural Layers

The final environment can be understood as five layers:

```text
┌──────────────────────────────────────────────┐
│ 5. Developer convenience                    │
│    PowerShell profile, functions, shortcuts │
├──────────────────────────────────────────────┤
│ 4. Application configuration                │
│    Environment variables and .env           │
├──────────────────────────────────────────────┤
│ 3. Project automation                       │
│    npm scripts, build scripts, clean scripts│
├──────────────────────────────────────────────┤
│ 2. JavaScript runtime and package tools     │
│    Node.js, npm, npx, and pnpm              │
├──────────────────────────────────────────────┤
│ 1. Operating-system interaction             │
│    PowerShell paths, files, and directories │
└──────────────────────────────────────────────┘
```

Each layer depends on the one below it.

For example:

1. PowerShell navigates to a project directory.
2. Node.js executes JavaScript inside that directory.
3. npm runs project scripts.
4. Environment variables configure those scripts.
5. PowerShell profile functions make frequent operations faster.

This dependency order determines the order of the series. We will not attempt to automate a project before learning how to navigate to it, and we will not introduce application secrets before understanding how processes receive environment variables.

---

## 0.4 Who This Series Is For

This series is designed for:

- Windows developers new to command-line tools
- Beginners learning Node.js
- Developers accustomed to File Explorer who want faster workflows
- macOS or Linux users moving to Windows
- Bash users who want to understand PowerShell rather than merely imitate Bash
- Developers who know individual commands but lack a coherent workflow
- Teams that need safer and more reproducible local setup instructions

You do not need prior PowerShell expertise.

Basic familiarity with files and folders is helpful, but concepts such as absolute paths, recursive operations, package managers, execution policies, and environment variables will be defined when they first appear.

---

## 0.5 What Makes PowerShell Different?

PowerShell may look similar to Bash, but it uses a different model.

Traditional command-line programs commonly pass plain text from one command to another. PowerShell commands usually pass structured **objects**. An object is a value that contains both data and named properties describing that data.

For example:

```powershell
Get-ChildItem
```

This command displays files and directories. Internally, however, it produces objects with properties such as:

- `Name`
- `Length`
- `Extension`
- `CreationTime`
- `LastWriteTime`
- `FullName`

That makes structured filtering possible:

```powershell
Get-ChildItem -File |
    Where-Object Extension -eq ".json"
```

This command does not search visually formatted text for the characters `.json`. It asks each file object for its `Extension` property and retains objects whose extension equals `.json`.

Do not worry if the pipeline syntax is unfamiliar. It will be introduced gradually.

---

## 0.6 Native Commands and Familiar Aliases

PowerShell command names generally follow a `Verb-Noun` pattern:

```text
Get-Location
Set-Location
Get-ChildItem
New-Item
Copy-Item
Move-Item
Remove-Item
```

The verb states the action. The noun states the resource receiving that action.

PowerShell also supplies aliases for commonly used commands:

| Familiar command | Native PowerShell command | Purpose |
|---|---|---|
| `pwd` | `Get-Location` | Display the current location |
| `cd` | `Set-Location` | Change the current location |
| `dir` | `Get-ChildItem` | List child items |
| `ls` | `Get-ChildItem` | List child items |
| `mkdir` | `New-Item` | Create a directory |
| `cp` | `Copy-Item` | Copy an item |
| `mv` | `Move-Item` | Move an item |
| `rm` | `Remove-Item` | Remove an item |

Aliases are convenient when working interactively. Native command names are normally preferable in scripts and documentation because they communicate their purpose more clearly.

You will learn both forms, but the tutorial will emphasize native PowerShell commands.

---

## 0.7 The Hands-On Learning Method

This is not a command-reference series. You will create and modify a real workspace.

Every implementation step will use the same four-part structure.

### 1. The Target

This identifies exactly what will be created or changed.

Examples include:

- A directory
- A file
- A PowerShell variable
- A `package.json` script
- A `.gitignore` rule
- A PowerShell profile function

### 2. The Concept

This explains why the step exists before presenting the commands.

For example, a relative path may be compared to giving directions from your current room, while an absolute path is comparable to providing a complete street address.

### 3. The Implementation

This provides complete commands or complete file contents.

The series will not use omissions such as:

```javascript
// Implement the rest here.
```

When a file must be created, its complete contents will be shown.

### 4. The Verification

Every step will include a concrete way to confirm that it worked, such as:

```powershell
Test-Path .\some-file.txt
```

or:

```powershell
npm test
```

or:

```powershell
Invoke-RestMethod http://localhost:3000/health
```

Verification is part of implementation—not an optional activity after it.

---

## 0.8 Command Conventions

Commands intended for PowerShell will appear in blocks marked `powershell`:

```powershell
Get-Location
```

Run the command itself. Do not type decorative prompt text such as `PS C:\>` if it appears in terminal output elsewhere.

Commands may span multiple lines using normal PowerShell syntax:

```powershell
Get-ChildItem `
    -Path . `
    -File `
    -Recurse
```

The backtick character at the end of a line is PowerShell’s line-continuation character:

```text
`
```

It must be the final character on the line. A trailing space after it can break the command. Where practical, this series will avoid unnecessary backticks and use simpler formatting.

Paths beginning with `.\` are relative to the current directory:

```powershell
.\developer-service
```

Paths beginning with `$HOME` start from your user home directory:

```powershell
$HOME\cli-developer-environment-series
```

Using `$HOME` makes commands portable across Windows accounts because it avoids hardcoding a username such as `C:\Users\Alice`.

---

## 0.9 Safety Conventions

Command-line tools can modify many files quickly. That speed is valuable, but it means destructive commands require care.

This series follows several safety rules.

### Work inside the laboratory

File operations will use a dedicated practice directory:

```text
$HOME\cli-developer-environment-series\filesystem-lab
```

Do not substitute an important directory such as:

- Your home directory
- `Documents`
- A production project
- The root of `C:\`
- A synchronized company folder

### Inspect your location first

Before a destructive operation, check the current location:

```powershell
Get-Location
```

### Preview destructive operations

PowerShell supports the common parameter `-WhatIf` on many commands that change state:

```powershell
Remove-Item -Path .\archive -Recurse -WhatIf
```

This previews the operation without deleting the target.

### Avoid unnecessary administrator sessions

Most tutorial commands should be run as your normal user. An elevated terminal—one started with **Run as administrator**—has broader permissions and can therefore cause broader damage.

If administrator access is required, the relevant step will explain why.

### Never publish real secrets

Example secrets in the series will be artificial. Never paste real passwords, private keys, production tokens, or cloud credentials into tutorial files, screenshots, commits, or chat messages.

---

## 0.10 Prerequisites

You need:

- Windows 10 or Windows 11
- PowerShell 5.1 or PowerShell 7+
- Permission to create files inside your home directory
- Internet access for installing Node.js packages
- A text editor

Visual Studio Code is recommended, but it is not mandatory.

### Check your PowerShell version

#### The Target

Confirm that PowerShell is available and identify its version.

#### The Concept

Software versions are like editions of a reference book. The main subject may be the same, but newer editions can contain additional features and corrections. Knowing the version makes troubleshooting more precise.

#### The Implementation

Run:

```powershell
$PSVersionTable
```

For a more focused result, run:

```powershell
$PSVersionTable.PSVersion
```

To identify the PowerShell edition, run:

```powershell
$PSVersionTable.PSEdition
```

Typical edition values are:

```text
Desktop
```

for Windows PowerShell 5.1, or:

```text
Core
```

for PowerShell 7 and later.

#### The Verification

Run this complete check:

```powershell
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Host "PowerShell 7 or later is ready." -ForegroundColor Green
}
elseif ($PSVersionTable.PSVersion.Major -eq 5) {
    Write-Host "Windows PowerShell 5.1 is ready." -ForegroundColor Yellow
}
else {
    Write-Host "This PowerShell version is older than the supported tutorial baseline." -ForegroundColor Red
}
```

You should see a green or yellow readiness message.

---

## 0.11 PowerShell 7 Recommendation

Windows PowerShell 5.1 can complete the core exercises, but PowerShell 7 is recommended for modern development.

Check whether the `pwsh` executable is installed:

```powershell
Get-Command pwsh -ErrorAction SilentlyContinue
```

If no result appears, PowerShell 7 may not be installed or may not be available through the system `PATH`.

The **PATH environment variable** is a list of directories Windows searches when you enter a command without supplying the executable’s complete location.

If Windows Package Manager is available, PowerShell 7 can be installed with:

```powershell
winget install --id Microsoft.PowerShell --source winget
```

Close the existing terminal after installation, open a new terminal, and run:

```powershell
pwsh
```

Verify the new session:

```powershell
$PSVersionTable.PSEdition
$PSVersionTable.PSVersion
```

A PowerShell 7 session should report the `Core` edition and a major version of at least `7`.

Installing PowerShell 7 does not remove Windows PowerShell 5.1. They can exist side by side.

---

## 0.12 Node.js Expectations

Node.js will not be required for the initial filesystem lessons. It becomes necessary in Part 3.

Later, you will verify the Node.js toolchain with:

```powershell
node --version
npm --version
npx --version
```

You will also learn why these are separate commands:

- `node` executes JavaScript outside a browser.
- `npm` installs dependencies and runs project scripts.
- `npx` executes package-provided command-line tools.
- `pnpm` is an alternative package manager designed to reuse dependency files efficiently.

You do not need to understand or install all of them before Part 3. Their installation, purpose, and verification belong to that phase.

---

## 0.13 What “Production-Grade” Means Here

The tutorial’s final service is deliberately small, but its engineering practices will be realistic.

“Production-grade” in this series means that the project will:

- Keep configuration outside source code
- Validate required configuration during startup
- Reject invalid port values and runtime modes
- Avoid committing secrets
- Use explicit package scripts
- Handle unexpected application errors
- Respond to process shutdown signals
- Provide a health endpoint
- Separate source and generated output
- Use reproducible dependency metadata
- Fail clearly instead of silently using unsafe values

It does **not** mean the example automatically includes every requirement of a large internet-facing system. A real deployment might additionally require:

- HTTPS termination
- Authentication and authorization
- Rate limiting
- Centralized logging
- Metrics and tracing
- Containerization
- Automated deployment
- Dependency scanning
- Backups
- Load balancing
- A managed secret store

The final application is a strong local foundation, not a substitute for a complete organizational production platform.

---

## 0.14 Expected Outcomes

After completing the series, you should be able to open PowerShell and confidently answer questions such as:

- Where am I in the filesystem?
- How do I navigate to another directory or drive?
- What does `ls` execute in PowerShell?
- How do I list only JSON files?
- How do I include hidden files?
- How do I recursively inspect a directory?
- How can I create a nested folder structure?
- How can I preview a deletion safely?
- What is the difference between npm, npx, and pnpm?
- What does `package.json` control?
- Why does `node_modules` exist?
- How do npm scripts work?
- Why can PowerShell block an `npm.ps1` script?
- How do I inspect the effective execution policy?
- How do I set an environment variable for one session?
- How do I persist a user-level environment variable?
- Why should `.env` be excluded from Git?
- How does a Node.js application read configuration?
- How do I customize my PowerShell profile safely?

More importantly, you should understand the reasoning behind the answers rather than relying on memorized command fragments.

---

## 0.15 The Journey Ahead

The series follows a deliberate progression:

```text
Navigate
   ↓
Inspect
   ↓
Create
   ↓
Copy and move
   ↓
Delete safely
   ↓
Initialize a Node.js project
   ↓
Install and execute packages
   ↓
Automate work with scripts
   ↓
Configure the runtime
   ↓
Protect secrets
   ↓
Customize the shell
```

Each stage depends on the previous one. By the time the final developer environment is complete, every major command and file will have been introduced in context, implemented completely, and verified independently.

The first technical phase begins with the most fundamental command-line skill: knowing where you are and moving confidently through the filesystem.
