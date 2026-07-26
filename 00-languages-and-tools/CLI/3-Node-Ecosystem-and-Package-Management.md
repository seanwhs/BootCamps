# Part 3: Node Ecosystem and Package Management

Parts 1 and 2 established control over the filesystem. You can navigate, create, copy, move, verify, and safely delete resources.

Now we will create the JavaScript project introduced in Part 0:

```text
$HOME/
└── cli-developer-environment-series/
    └── developer-service/
        ├── scripts/
        │   ├── build.js
        │   └── clean.js
        ├── src/
        │   └── index.js
        ├── test/
        │   └── server.test.js
        ├── .gitignore
        ├── eslint.config.js
        ├── package.json
        └── package-lock.json
```

By the end of Part 3, the project will provide:

- A working Node.js HTTP service
- A production dependency
- A development dependency
- Automated tests
- Linting
- Build and cleanup scripts
- npm lifecycle commands
- Reproducible dependency installation
- Graceful process shutdown
- A health-check endpoint

Part 4 will add environment variables, `.env` files, configuration validation, and secret management.

---

## 3.1 Understand the Node.js Toolchain

### The Target

Understand the distinct responsibilities of:

- `node`
- `npm`
- `npx`
- `pnpm`

### The Concept

Think of a workshop:

- **Node.js** is the machine that executes JavaScript.
- **npm** is the inventory manager that installs tools and materials.
- **npx** temporarily locates and runs a tool.
- **pnpm** is an alternative inventory manager that stores shared materials efficiently.

These programs are related, but they are not interchangeable.

### Node.js

Node.js is a JavaScript runtime. A **runtime** is the software environment that executes a program.

Browsers execute JavaScript in web pages. Node.js executes JavaScript outside the browser:

```powershell
node .\src\index.js
```

### npm

npm originally stood for Node Package Manager. It manages:

- Project metadata
- Dependencies
- Lockfiles
- Package installation
- Project scripts
- Package publication

Common commands include:

```powershell
npm install
npm run build
npm test
npm start
```

### npx

`npx` runs command-line programs supplied by npm packages.

It can execute:

- A binary installed in the current project
- A package downloaded temporarily
- A specific package version

Examples:

```powershell
npx eslint .
npx --yes cowsay "Hello from PowerShell"
```

### pnpm

pnpm is an alternative package manager. npm commonly places separate package files into each project’s `node_modules`. pnpm stores package contents in a shared content-addressable store and links projects to that content.

This can reduce disk duplication across projects.

Typical pnpm commands include:

```powershell
pnpm install
pnpm add express
pnpm run build
```

Do not mix npm and pnpm casually in one project. They use different lockfiles:

```text
npm  → package-lock.json
pnpm → pnpm-lock.yaml
```

This tutorial uses npm for the application so its installation is predictable.

### The Implementation

No files change in this conceptual step. Ask PowerShell whether the commands are currently available:

```powershell
$toolNames = @(
    "node"
    "npm"
    "npx"
    "pnpm"
)

$toolDiscovery = foreach ($toolName in $toolNames) {
    $command = Get-Command `
        -Name $toolName `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    [PSCustomObject]@{
        Tool = $toolName
        Available = $null -ne $command
        CommandType = if ($null -ne $command) {
            $command.CommandType
        }
        Source = if ($null -ne $command) {
            $command.Source
        }
    }
}

$toolDiscovery |
    Format-Table -AutoSize
```

It is acceptable for `pnpm` to be unavailable. We will inspect an optional installation route later.

### The Verification

Confirm whether Node.js is ready:

```powershell
$nodeCommand = Get-Command `
    -Name node `
    -ErrorAction SilentlyContinue

if ($null -eq $nodeCommand) {
    Write-Host "Node.js must be installed before continuing." -ForegroundColor Yellow
}
else {
    Write-Host "Node.js was found at: $($nodeCommand.Source)" -ForegroundColor Green
}
```

If Node.js was not found, continue to the next step.

---

## 3.2 Install or Verify Node.js LTS

### The Target

Install a supported Node.js Long-Term Support release or verify the existing installation.

### The Concept

Node.js publishes several release lines. **LTS** means Long-Term Support: a release line intended for stability and extended maintenance.

For a production application, an active or maintenance LTS release is generally preferable to an experimental or short-lived release.

A version typically looks like:

```text
v22.14.0
```

The first number is the **major version**. Major releases can introduce changes that require application updates.

### The Implementation

First, check whether Node.js already exists:

```powershell
Get-Command node -ErrorAction SilentlyContinue
```

If the command is unavailable, check for Windows Package Manager:

```powershell
Get-Command winget -ErrorAction SilentlyContinue
```

If `winget` is available, install Node.js LTS:

```powershell
winget install `
    --id OpenJS.NodeJS.LTS `
    --source winget `
    --accept-package-agreements `
    --accept-source-agreements
```

Close every existing terminal after installation and open a new PowerShell session. This allows the new process to receive the updated `PATH`.

Then run:

```powershell
node --version
npm --version
npx --version
```

If `winget` is unavailable, download the current LTS installer from the official Node.js website:

```text
https://nodejs.org/
```

Use the official installer and retain the option that adds Node.js to `PATH`.

### The Verification

Run:

```powershell
$requiredNodeTools = @(
    "node"
    "npm"
    "npx"
)

$missingNodeTools = @(
    $requiredNodeTools |
        Where-Object {
            $null -eq (
                Get-Command `
                    -Name $_ `
                    -ErrorAction SilentlyContinue
            )
        }
)

if ($missingNodeTools.Count -gt 0) {
    throw "Missing required tools: $($missingNodeTools -join ', ')"
}

[PSCustomObject]@{
    NodeVersion = node --version
    NpmVersion = npm --version
    NpxVersion = npx --version
    NodeExecutable = (Get-Command node).Source
}
```

You should see version strings for all three tools.

Test the runtime directly:

```powershell
node -e 'console.log("Node.js is executing JavaScript successfully.");'
```

Expected output:

```text
Node.js is executing JavaScript successfully.
```

---

## 3.3 Diagnose PowerShell Script-Restriction Errors

### The Target

Understand why PowerShell may block `npm.ps1` or `npx.ps1`, and identify the effective policy before changing anything.

### The Concept

On Windows, a Node.js installation commonly provides several command wrappers:

```text
npm
npm.cmd
npm.ps1
```

PowerShell’s command-resolution rules may choose `npm.ps1`. A PowerShell **execution policy** determines when `.ps1` scripts are allowed to execute.

An execution policy is a safety feature that helps prevent accidental script execution. It is not a complete security boundary, and it should not be disabled globally without understanding the consequences.

A common error resembles:

```text
npm.ps1 cannot be loaded because running scripts is disabled on this system
```

Policies can be configured at several scopes. Higher-precedence organizational policy can override personal settings.

### The Implementation

Inspect every policy scope:

```powershell
Get-ExecutionPolicy -List
```

Typical scopes include:

| Scope | Meaning |
|---|---|
| `MachinePolicy` | Group Policy for the computer |
| `UserPolicy` | Group Policy for the user |
| `Process` | Current PowerShell process only |
| `CurrentUser` | Current Windows user |
| `LocalMachine` | Every user on the machine |

Inspect the effective policy:

```powershell
Get-ExecutionPolicy
```

Inspect every `npm` command PowerShell can resolve:

```powershell
Get-Command npm -All |
    Select-Object Name, CommandType, Source, Definition
```

Inspect `npx`:

```powershell
Get-Command npx -All |
    Select-Object Name, CommandType, Source, Definition
```

If `npm --version` works, no correction is necessary.

If `npm` is blocked because PowerShell selects `npm.ps1`, the narrowest immediate workaround is to call the Windows command wrapper explicitly:

```powershell
npm.cmd --version
npx.cmd --version
```

This does not change the execution policy.

For a temporary policy applicable only to the current PowerShell process, you may use:

```powershell
Set-ExecutionPolicy `
    -Scope Process `
    -ExecutionPolicy Bypass
```

Inspect the effective process policy:

```powershell
Get-ExecutionPolicy -List
```

The setting disappears when that PowerShell process closes.

For a persistent user-level development configuration, `RemoteSigned` is commonly used:

```powershell
Set-ExecutionPolicy `
    -Scope CurrentUser `
    -ExecutionPolicy RemoteSigned
```

`RemoteSigned` allows local scripts to run while requiring downloaded scripts to carry a trusted signature unless they are explicitly unblocked.

Do not use this merely because a tutorial says so. First inspect:

- The effective policy
- Your organization’s requirements
- Whether `npm.cmd` already solves the problem

Do not run this broad configuration:

```text
Set-ExecutionPolicy Unrestricted -Scope LocalMachine
```

It is unnecessary for this tutorial.

### The Verification

Run whichever command is appropriate for your environment:

```powershell
npm --version
```

or:

```powershell
npm.cmd --version
```

Verify that the command returns a version:

```powershell
$npmVersion = npm.cmd --version

if ([string]::IsNullOrWhiteSpace($npmVersion)) {
    throw "npm did not return a version."
}

Write-Host "npm is ready: $npmVersion" -ForegroundColor Green
```

If `MachinePolicy` or `UserPolicy` controls your environment, do not attempt to circumvent organizational policy. Use approved tooling or contact your administrator.

---

## 3.4 Create the Node.js Project Directory

### The Target

Create and enter:

```text
$HOME\cli-developer-environment-series\developer-service
```

### The Concept

A Node.js project is anchored by a `package.json` file. Before creating it, we need a dedicated project directory.

A project directory is like a labeled workshop bay: source code, dependencies, scripts, and generated output remain associated with one application.

### The Implementation

Construct the paths:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$projectRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "developer-service"
```

Confirm the series directory exists:

```powershell
if (-not (
    Test-Path `
        -LiteralPath $seriesRoot `
        -PathType Container
)) {
    $null = New-Item `
        -Path $seriesRoot `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Create the project directory only if it is missing:

```powershell
if (-not (
    Test-Path `
        -LiteralPath $projectRoot `
        -PathType Container
)) {
    $null = New-Item `
        -Path $projectRoot `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Enter it:

```powershell
Set-Location -LiteralPath $projectRoot
```

Confirm it is empty before initialization:

```powershell
Get-ChildItem -Force
```

If you previously created unrelated files in this directory, move them elsewhere before continuing. Do not delete files without identifying them.

### The Verification

Run:

```powershell
[PSCustomObject]@{
    ProjectExists = Test-Path `
        -LiteralPath $projectRoot `
        -PathType Container
    CurrentLocationMatches = (
        (Get-Location).Path -eq $projectRoot
    )
}
```

Both values should be `True`.

---

## 3.5 Initialize `package.json`

### The Target

Create the project manifest:

```text
developer-service\package.json
```

### The Concept

`package.json` is the project’s identity card and control panel.

It records information such as:

- Project name
- Version
- Entry point
- Supported Node.js version
- npm scripts
- Runtime dependencies
- Development dependencies

The command:

```powershell
npm init -y
```

creates a manifest using defaults. The `-y` means “accept the default answers.”

### The Implementation

Ensure you are at the project root:

```powershell
Set-Location -LiteralPath $projectRoot
```

Initialize the project:

```powershell
npm.cmd init -y
```

Using `npm.cmd` works whether or not PowerShell permits `npm.ps1`.

Inspect the generated file:

```powershell
Get-Content `
    -LiteralPath .\package.json `
    -Raw
```

Parse it as JSON:

```powershell
$initialPackage = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$initialPackage |
    Format-List
```

### The Verification

Confirm that the file exists and contains valid JSON:

```powershell
$packagePath = Join-Path $projectRoot "package.json"

if (-not (
    Test-Path `
        -LiteralPath $packagePath `
        -PathType Leaf
)) {
    throw "package.json was not created."
}

$packageData = Get-Content `
    -LiteralPath $packagePath `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    PackageExists = $true
    Name = $packageData.name
    Version = $packageData.version
    JsonParsedSuccessfully = $null -ne $packageData
}
```

Expected project name:

```text
developer-service
```

---

## 3.6 Replace `package.json` with an Explicit Project Manifest

### The Target

Replace the generated defaults with a complete manifest containing project metadata, runtime requirements, and planned scripts.

### The Concept

Generated defaults are useful for starting, but production-conscious projects should declare their intent explicitly.

The scripts are named commands. Instead of requiring every developer to remember:

```powershell
node .\scripts\build.js
```

the project offers:

```powershell
npm run build
```

That makes the project itself the source of truth.

### The Implementation

First, find your installed Node.js major version:

```powershell
$nodeMajorVersion = [int](
    (node --version).TrimStart("v").Split(".")[0]
)

$nodeMajorVersion
```

This tutorial requires Node.js 20 or later because it uses the built-in test runner and modern APIs:

```powershell
if ($nodeMajorVersion -lt 20) {
    throw "Node.js 20 or later is required. Installed: $(node --version)"
}
```

Replace `package.json`.

### File: `developer-service/package.json`

```powershell
$packageJsonContent = @'
{
  "name": "developer-service",
  "version": "1.0.0",
  "description": "A production-conscious Node.js service built from PowerShell.",
  "private": true,
  "main": "dist/index.js",
  "type": "commonjs",
  "engines": {
    "node": ">=20"
  },
  "scripts": {
    "clean": "node scripts/clean.js",
    "lint": "eslint .",
    "test": "node --test",
    "build": "node scripts/build.js",
    "prestart": "npm run build",
    "start": "node dist/index.js",
    "dev": "node --watch src/index.js",
    "check": "npm run lint && npm test && npm run build"
  },
  "keywords": [
    "node",
    "powershell",
    "http-service"
  ],
  "author": "",
  "license": "MIT"
}
'@

Set-Content `
    -LiteralPath "$projectRoot\package.json" `
    -Value $packageJsonContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

The important properties are:

- `"private": true` prevents accidental publication to npm.
- `"main"` identifies the generated entry point.
- `"type": "commonjs"` makes `.js` files use CommonJS module syntax.
- `"engines"` documents the supported Node.js runtime.
- `"scripts"` defines repeatable project commands.
- `prestart` is an npm lifecycle hook automatically executed before `start`.

Some scripts reference files not yet created. We will create them before running those scripts.

### The Verification

Parse the file:

```powershell
$packageData = Get-Content `
    -LiteralPath "$projectRoot\package.json" `
    -Raw |
    ConvertFrom-Json
```

Inspect its scripts:

```powershell
$packageData.scripts |
    Format-List
```

Validate critical properties:

```powershell
[PSCustomObject]@{
    CorrectName = $packageData.name -eq "developer-service"
    IsPrivate = $packageData.private -eq $true
    UsesCommonJs = $packageData.type -eq "commonjs"
    RequiresModernNode = $packageData.engines.node -eq ">=20"
    HasStartScript = $null -ne $packageData.scripts.start
    HasBuildScript = $null -ne $packageData.scripts.build
    HasTestScript = $null -ne $packageData.scripts.test
}
```

Every value should be `True`.

List scripts through npm:

```powershell
npm.cmd run
```

---

## 3.7 Install a Production Dependency

### The Target

Install Express as a runtime dependency.

### The Concept

A **dependency** is code the application needs in order to run.

Express is a Node.js web framework. A framework provides reusable structures for receiving HTTP requests and sending responses.

Installing it with:

```powershell
npm install express
```

changes three things:

1. Adds Express to `dependencies` in `package.json`
2. Creates or updates `package-lock.json`
3. Places installed package files under `node_modules`

### The Implementation

Install Express:

```powershell
Set-Location -LiteralPath $projectRoot

npm.cmd install express
```

Inspect the dependency declaration:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$packageData.dependencies |
    Format-List
```

Ask npm for the installed version:

```powershell
npm.cmd list express --depth=0
```

### The Verification

Confirm all three installation artifacts:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    ExpressDeclared = $null -ne $packageData.dependencies.express
    LockfileExists = Test-Path `
        -LiteralPath .\package-lock.json `
        -PathType Leaf
    NodeModulesExists = Test-Path `
        -LiteralPath .\node_modules `
        -PathType Container
    ExpressDirectoryExists = Test-Path `
        -LiteralPath .\node_modules\express `
        -PathType Container
}
```

Every value should be `True`.

Test module loading:

```powershell
node -e 'const express = require("express"); console.log(typeof express);'
```

Expected output:

```text
function
```

---

## 3.8 Install a Development Dependency

### The Target

Install ESLint as a development-only dependency.

### The Concept

A **development dependency** is needed while developing, testing, linting, or building the project, but it is not required by the running application.

ESLint examines JavaScript for suspicious patterns and style violations.

The distinction is:

```text
dependencies    → needed at runtime
devDependencies → needed to develop or validate the project
```

### The Implementation

Install ESLint:

```powershell
npm.cmd install --save-dev eslint
```

The shorter equivalent is:

```text
npm install -D eslint
```

Inspect the manifest:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$packageData.devDependencies |
    Format-List
```

Inspect the installed top-level package:

```powershell
npm.cmd list eslint --depth=0
```

### The Verification

Run the locally installed binary through `npx.cmd`:

```powershell
npx.cmd eslint --version
```

Confirm the declaration:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$eslintDeclared = $null -ne $packageData.devDependencies.eslint

if (-not $eslintDeclared) {
    throw "ESLint was not added to devDependencies."
}

Write-Host "ESLint is installed as a development dependency." -ForegroundColor Green
```

---

## 3.9 Understand `package-lock.json`

### The Target

Inspect the npm lockfile and understand why it should normally be committed to Git.

### The Concept

`package.json` often allows a range of acceptable package versions. The lockfile records the exact dependency tree selected by npm.

Think of:

- `package.json` as a shopping list saying “compatible coffee beans”
- `package-lock.json` as the exact receipt listing brand, package, and supplier

The lockfile improves reproducibility across developers, CI systems, and deployment environments.

### The Implementation

Confirm the lockfile exists:

```powershell
Get-Item `
    -LiteralPath .\package-lock.json |
    Select-Object Name, Length, LastWriteTime
```

Parse selected properties:

```powershell
$lockData = Get-Content `
    -LiteralPath .\package-lock.json `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    Name = $lockData.name
    Version = $lockData.version
    LockfileVersion = $lockData.lockfileVersion
    HasPackages = $null -ne $lockData.packages
}
```

Inspect npm’s dependency tree:

```powershell
npm.cmd list --depth=0
```

### The Verification

Ask npm to validate the installed dependency tree:

```powershell
npm.cmd ls
```

A successful command should complete without dependency errors.

Verify that the lockfile is valid JSON:

```powershell
try {
    $null = Get-Content `
        -LiteralPath .\package-lock.json `
        -Raw |
        ConvertFrom-Json

    Write-Host "package-lock.json contains valid JSON." -ForegroundColor Green
}
catch {
    throw "package-lock.json is invalid: $($_.Exception.Message)"
}
```

---

## 3.10 Understand and Measure `node_modules`

### The Target

Inspect the installed dependency directory without manually modifying it.

### The Concept

`node_modules` contains the packages required by the project and their transitive dependencies.

A **transitive dependency** is a dependency of another dependency. Your application requested Express, but Express itself relies on other packages.

Treat `node_modules` as generated output. Do not hand-edit it. npm can reconstruct it from:

```text
package.json
package-lock.json
```

### The Implementation

Count package directories:

```powershell
$nodeModulesPath = Join-Path $projectRoot "node_modules"

$topLevelPackageDirectories = @(
    Get-ChildItem `
        -LiteralPath $nodeModulesPath `
        -Directory `
        -Force
)

$topLevelPackageDirectories.Count
```

Calculate approximate disk usage:

```powershell
$nodeModulesFiles = @(
    Get-ChildItem `
        -LiteralPath $nodeModulesPath `
        -File `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
)

$totalNodeModulesBytes = (
    $nodeModulesFiles |
        Measure-Object -Property Length -Sum
).Sum

if ($null -eq $totalNodeModulesBytes) {
    $totalNodeModulesBytes = 0
}

[PSCustomObject]@{
    FileCount = $nodeModulesFiles.Count
    TotalBytes = [long] $totalNodeModulesBytes
    ApproximateMegabytes = [math]::Round(
        $totalNodeModulesBytes / 1MB,
        2
    )
}
```

### The Verification

Ask npm where the local modules directory is:

```powershell
npm.cmd root
```

Resolve and compare it:

```powershell
$npmRoot = (npm.cmd root).Trim()
$resolvedNodeModules = (
    Resolve-Path -LiteralPath $nodeModulesPath
).Path

$npmRoot -eq $resolvedNodeModules
```

Expected result:

```text
True
```

Do not commit `node_modules`. We will create `.gitignore` next.

---

## 3.11 Create `.gitignore`

### The Target

Create:

```text
developer-service\.gitignore
```

to exclude generated, local, and secret-bearing files.

### The Concept

Git tracks source history. Generated dependencies and private configuration should not be treated as source code.

A `.gitignore` file tells Git which untracked paths it should ordinarily ignore.

It is like a packing checklist that says:

> Include the plans, but do not pack the temporary workshop, private credentials, or generated output.

### The Implementation

Create the file.

### File: `developer-service/.gitignore`

```powershell
$gitIgnoreContent = @'
# Installed dependencies can be reconstructed from package-lock.json.
node_modules/

# Generated build output is recreated by npm run build.
dist/

# Local runtime configuration may contain secrets.
.env
.env.*
!.env.example

# Logs and diagnostic output.
*.log
npm-debug.log*
yarn-debug.log*
pnpm-debug.log*

# Test coverage output.
coverage/

# Editor and operating-system metadata.
.vscode/
.idea/
.DS_Store
Thumbs.db
'@

Set-Content `
    -LiteralPath "$projectRoot\.gitignore" `
    -Value $gitIgnoreContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

The exception:

```text
!.env.example
```

allows a safe configuration template to be tracked later, even though other `.env.*` files are ignored.

### The Verification

Read the file:

```powershell
Get-Content -LiteralPath .\.gitignore
```

If Git is installed, verify ignore behavior:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    if (-not (Test-Path -LiteralPath .\.git)) {
        git init
    }

    git check-ignore -v node_modules
    git check-ignore -v dist
}
else {
    Write-Host "Git is unavailable; manual .gitignore verification completed." -ForegroundColor Yellow
}
```

Expected matching rules identify `node_modules/` and `dist/`.

---

## 3.12 Create the Application Module

### The Target

Create:

```text
developer-service\src\app.js
```

This module will construct the Express application without opening a network port.

### The Concept

Separating application construction from server startup improves testability.

Think of:

- `app.js` as assembling a car
- `index.js` as starting its engine

Tests can examine the assembled application without starting a permanent production process.

### The Implementation

Create `src`:

```powershell
$srcDirectory = Join-Path $projectRoot "src"

if (-not (
    Test-Path `
        -LiteralPath $srcDirectory `
        -PathType Container
)) {
    $null = New-Item `
        -Path $srcDirectory `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Create the application module.

### File: `developer-service/src/app.js`

```powershell
$appSourceContent = @'
"use strict";

const express = require("express");

function createApp() {
  const app = express();

  // Disable a response header that unnecessarily reveals the framework.
  app.disable("x-powered-by");

  // Parse JSON request bodies while limiting their size to reduce accidental
  // memory pressure from unexpectedly large requests.
  app.use(express.json({ limit: "16kb" }));

  app.get("/", (request, response) => {
    response.status(200).json({
      service: "developer-service",
      message: "The Node.js service is running.",
    });
  });

  app.get("/health", (request, response) => {
    response.status(200).json({
      status: "ok",
      uptimeSeconds: Math.floor(process.uptime()),
      timestamp: new Date().toISOString(),
    });
  });

  app.post("/echo", (request, response) => {
    response.status(200).json({
      received: request.body,
    });
  });

  // A final route handles requests that matched no earlier endpoint.
  app.use((request, response) => {
    response.status(404).json({
      error: "Not Found",
      method: request.method,
      path: request.originalUrl,
    });
  });

  // Express recognizes an error-handling middleware function by its four
  // parameters. Keep this after every ordinary route and middleware.
  app.use((error, request, response, next) => {
    // The variable is intentionally referenced so static analysis can verify
    // that the middleware has the required four-argument signature.
    void next;

    console.error("Unhandled request error:", error);

    if (response.headersSent) {
      return;
    }

    response.status(500).json({
      error: "Internal Server Error",
    });
  });

  return app;
}

module.exports = {
  createApp,
};
'@

Set-Content `
    -LiteralPath "$srcDirectory\app.js" `
    -Value $appSourceContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check JavaScript syntax:

```powershell
node --check .\src\app.js
```

Load and create the application:

```powershell
node -e 'const { createApp } = require("./src/app"); const app = createApp(); console.log(typeof app);'
```

Expected output:

```text
function
```

---

## 3.13 Create the Server Entry Point

### The Target

Create:

```text
developer-service\src\index.js
```

The entry point will:

- Open the HTTP server
- Use a temporary fixed development port
- Log startup
- Handle startup errors
- Handle termination signals
- Close gracefully

Part 4 will replace the fixed configuration with validated environment variables.

### The Concept

A server listens for requests until it is asked to stop.

A **graceful shutdown** stops accepting new work, allows the server to close, and then exits. This resembles closing a shop by locking the entrance and finishing current transactions instead of switching off the electricity immediately.

### The Implementation

Create the entry point.

### File: `developer-service/src/index.js`

```powershell
$indexSourceContent = @'
"use strict";

const http = require("node:http");
const { createApp } = require("./app");

const HOST = "127.0.0.1";
const PORT = 3000;
const SHUTDOWN_TIMEOUT_MS = 10_000;

const app = createApp();
const server = http.createServer(app);

let shutdownStarted = false;

function shutdown(signal) {
  if (shutdownStarted) {
    return;
  }

  shutdownStarted = true;
  console.log(`Received ${signal}. Closing the HTTP server.`);

  const forcedShutdownTimer = setTimeout(() => {
    console.error("Graceful shutdown timed out. Forcing process exit.");
    process.exit(1);
  }, SHUTDOWN_TIMEOUT_MS);

  // The timeout should not keep the process alive after every other handle
  // has closed successfully.
  forcedShutdownTimer.unref();

  server.close((error) => {
    clearTimeout(forcedShutdownTimer);

    if (error) {
      console.error("The HTTP server failed to close cleanly:", error);
      process.exit(1);
    }

    console.log("HTTP server closed.");
    process.exit(0);
  });
}

server.on("error", (error) => {
  console.error("HTTP server error:", error);
  process.exitCode = 1;
});

server.listen(PORT, HOST, () => {
  console.log(`developer-service listening at http://${HOST}:${PORT}`);
});

process.on("SIGINT", () => {
  shutdown("SIGINT");
});

process.on("SIGTERM", () => {
  shutdown("SIGTERM");
});

process.on("uncaughtException", (error) => {
  console.error("Uncaught exception:", error);
  shutdown("uncaughtException");
});

process.on("unhandledRejection", (reason) => {
  console.error("Unhandled promise rejection:", reason);
  shutdown("unhandledRejection");
});
'@

Set-Content `
    -LiteralPath "$srcDirectory\index.js" `
    -Value $indexSourceContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
node --check .\src\index.js
```

Start the service:

```powershell
node .\src\index.js
```

Expected log:

```text
developer-service listening at http://127.0.0.1:3000
```

Leave that terminal running. Open a second PowerShell terminal and run:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get
```

Expected properties include:

```text
status        : ok
uptimeSeconds : ...
timestamp     : ...
```

Return to the server terminal and press `Ctrl+C`.

Expected shutdown logs include:

```text
Received SIGINT. Closing the HTTP server.
HTTP server closed.
```

---

## 3.14 Create Automated Tests

### The Target

Create:

```text
developer-service\test\server.test.js
```

using Node.js’s built-in test runner.

### The Concept

An automated test is a repeatable claim about program behavior.

Instead of manually checking each route after every change, the test suite:

1. Starts the application on an automatically selected free port.
2. Sends real HTTP requests.
3. Checks status codes and response bodies.
4. Closes the server after each test.

Using port `0` asks Windows to assign an available temporary port, preventing conflicts with the development server.

### The Implementation

Create the test directory:

```powershell
$testDirectory = Join-Path $projectRoot "test"

if (-not (
    Test-Path `
        -LiteralPath $testDirectory `
        -PathType Container
)) {
    $null = New-Item `
        -Path $testDirectory `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Create the test file.

### File: `developer-service/test/server.test.js`

```powershell
$testContent = @'
"use strict";

const assert = require("node:assert/strict");
const http = require("node:http");
const { afterEach, test } = require("node:test");
const { createApp } = require("../src/app");

const activeServers = new Set();

async function startTestServer() {
  const app = createApp();
  const server = http.createServer(app);

  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });

  activeServers.add(server);

  const address = server.address();

  if (address === null || typeof address === "string") {
    throw new Error("The test server did not expose a TCP address.");
  }

  return {
    baseUrl: `http://127.0.0.1:${address.port}`,
    server,
  };
}

async function closeServer(server) {
  if (!activeServers.has(server)) {
    return;
  }

  await new Promise((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });

  activeServers.delete(server);
}

afterEach(async () => {
  await Promise.all(
    [...activeServers].map((server) => closeServer(server)),
  );
});

test("GET / returns service information", async () => {
  const { baseUrl, server } = await startTestServer();

  const response = await fetch(`${baseUrl}/`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.service, "developer-service");
  assert.equal(body.message, "The Node.js service is running.");

  await closeServer(server);
});

test("GET /health returns a healthy response", async () => {
  const { baseUrl, server } = await startTestServer();

  const response = await fetch(`${baseUrl}/health`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.status, "ok");
  assert.equal(typeof body.uptimeSeconds, "number");
  assert.match(body.timestamp, /^\d{4}-\d{2}-\d{2}T/);

  await closeServer(server);
});

test("POST /echo returns the parsed JSON body", async () => {
  const { baseUrl, server } = await startTestServer();

  const requestBody = {
    message: "Hello from the test suite",
    ready: true,
  };

  const response = await fetch(`${baseUrl}/echo`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(requestBody),
  });

  const body = await response.json();

  assert.equal(response.status, 200);
  assert.deepEqual(body.received, requestBody);

  await closeServer(server);
});

test("an unknown route returns JSON with status 404", async () => {
  const { baseUrl, server } = await startTestServer();

  const response = await fetch(`${baseUrl}/missing`);
  const body = await response.json();

  assert.equal(response.status, 404);
  assert.equal(body.error, "Not Found");
  assert.equal(body.method, "GET");
  assert.equal(body.path, "/missing");

  await closeServer(server);
});
'@

Set-Content `
    -LiteralPath "$testDirectory\server.test.js" `
    -Value $testContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check the test file’s syntax:

```powershell
node --check .\test\server.test.js
```

Run the test script declared in `package.json`:

```powershell
npm.cmd test
```

Expected summary resembles:

```text
tests 4
pass 4
fail 0
```

A nonzero failure count must be repaired before continuing.

---

## 3.15 Configure ESLint

### The Target

Create:

```text
developer-service\eslint.config.js
```

and run static analysis across the project.

### The Concept

A test checks behaviors you explicitly described. A linter searches source code for patterns that may indicate defects or inconsistency.

It is like a spell-checker combined with a mechanical safety inspector.

Modern ESLint versions use a flat configuration exported from `eslint.config.js`.

### The Implementation

Create the configuration.

### File: `developer-service/eslint.config.js`

```powershell
$eslintConfigContent = @'
"use strict";

module.exports = [
  {
    ignores: [
      "dist/**",
      "node_modules/**",
      "coverage/**",
    ],
  },
  {
    files: [
      "**/*.js",
    ],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "commonjs",
      globals: {
        console: "readonly",
        fetch: "readonly",
        process: "readonly",
        setTimeout: "readonly",
        clearTimeout: "readonly",
      },
    },
    rules: {
      "array-callback-return": "error",
      "eqeqeq": [
        "error",
        "always",
      ],
      "no-constant-condition": "error",
      "no-duplicate-imports": "error",
      "no-else-return": "error",
      "no-shadow": "error",
      "no-undef": "error",
      "no-unreachable": "error",
      "no-unused-vars": [
        "error",
        {
          "args": "all",
          "argsIgnorePattern": "^_",
          "caughtErrors": "all",
        },
      ],
      "prefer-const": "error",
    },
  },
];
'@

Set-Content `
    -LiteralPath "$projectRoot\eslint.config.js" `
    -Value $eslintConfigContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Run the npm script:

```powershell
npm.cmd run lint
```

npm automatically adds:

```text
node_modules\.bin
```

to the command search path while executing scripts. Therefore, `"lint": "eslint ."` can use the project-local ESLint binary without a global installation.

### The Verification

A successful lint run exits without errors.

Inspect the exit code immediately:

```powershell
npm.cmd run lint
$LASTEXITCODE
```

Expected result:

```text
0
```

You can also run the local package binary through npx:

```powershell
npx.cmd eslint .
```

---

## 3.16 Create the Cleanup Script

### The Target

Create:

```text
developer-service\scripts\clean.js
```

The script will remove generated `dist` output without touching source files.

### The Concept

Generated output should be replaceable. A clean command removes yesterday’s build so today’s build cannot accidentally contain stale files.

The script validates the target path before deleting it. This is the Node.js equivalent of guarding a PowerShell `Remove-Item` command.

### The Implementation

Create the scripts directory:

```powershell
$scriptsDirectory = Join-Path $projectRoot "scripts"

if (-not (
    Test-Path `
        -LiteralPath $scriptsDirectory `
        -PathType Container
)) {
    $null = New-Item `
        -Path $scriptsDirectory `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Create the cleanup script.

### File: `developer-service/scripts/clean.js`

```powershell
$cleanScriptContent = @'
"use strict";

const path = require("node:path");
const { rm } = require("node:fs/promises");

async function main() {
  const projectRoot = path.resolve(__dirname, "..");
  const distDirectory = path.resolve(projectRoot, "dist");
  const expectedDistDirectory = path.join(projectRoot, "dist");

  if (distDirectory !== expectedDistDirectory) {
    throw new Error(`Refusing to clean an unexpected path: ${distDirectory}`);
  }

  if (path.dirname(distDirectory) !== projectRoot) {
    throw new Error(`The dist directory escaped the project root: ${distDirectory}`);
  }

  await rm(distDirectory, {
    recursive: true,
    force: true,
  });

  console.log(`Cleaned generated output: ${distDirectory}`);
}

main().catch((error) => {
  console.error("Clean failed:", error);
  process.exitCode = 1;
});
'@

Set-Content `
    -LiteralPath "$scriptsDirectory\clean.js" `
    -Value $cleanScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
node --check .\scripts\clean.js
```

Run the npm script:

```powershell
npm.cmd run clean
```

Expected log resembles:

```text
Cleaned generated output: ...\developer-service\dist
```

Confirm that source remains:

```powershell
[PSCustomObject]@{
    DistIsAbsent = -not (
        Test-Path -LiteralPath .\dist
    )
    SourceAppStillExists = Test-Path `
        -LiteralPath .\src\app.js `
        -PathType Leaf
    SourceIndexStillExists = Test-Path `
        -LiteralPath .\src\index.js `
        -PathType Leaf
}
```

Every value should be `True`.

---

## 3.17 Create the Build Script

### The Target

Create:

```text
developer-service\scripts\build.js
```

The build process will:

1. Remove old generated output.
2. Create a temporary build directory.
3. Copy source files.
4. Validate copied JavaScript syntax.
5. Atomically rename the temporary directory to `dist`.
6. Remove temporary output if the build fails.

### The Concept

Although plain JavaScript does not require compilation here, a build step still creates a clean deployment artifact.

Building into a temporary directory prevents a failed build from leaving a partially updated `dist`.

It is like packing a shipment on a separate table, inspecting it, and only then moving the completed box to the shipping area.

### The Implementation

Create the build script.

### File: `developer-service/scripts/build.js`

```powershell
$buildScriptContent = @'
"use strict";

const path = require("node:path");
const {
  cp,
  mkdir,
  readdir,
  rename,
  rm,
} = require("node:fs/promises");
const { spawn } = require("node:child_process");

function runNodeSyntaxCheck(filePath) {
  return new Promise((resolve, reject) => {
    const child = spawn(
      process.execPath,
      ["--check", filePath],
      {
        stdio: "inherit",
        windowsHide: true,
      },
    );

    child.once("error", reject);

    child.once("exit", (code, signal) => {
      if (signal !== null) {
        reject(
          new Error(`Syntax check was terminated by signal ${signal}: ${filePath}`),
        );
        return;
      }

      if (code !== 0) {
        reject(
          new Error(`Syntax check failed with exit code ${code}: ${filePath}`),
        );
        return;
      }

      resolve();
    });
  });
}

async function findJavaScriptFiles(directory) {
  const entries = await readdir(directory, {
    withFileTypes: true,
  });

  const nestedResults = await Promise.all(
    entries.map(async (entry) => {
      const fullPath = path.join(directory, entry.name);

      if (entry.isDirectory()) {
        return findJavaScriptFiles(fullPath);
      }

      if (entry.isFile() && entry.name.endsWith(".js")) {
        return [fullPath];
      }

      return [];
    }),
  );

  return nestedResults.flat();
}

async function main() {
  const projectRoot = path.resolve(__dirname, "..");
  const sourceDirectory = path.join(projectRoot, "src");
  const distDirectory = path.join(projectRoot, "dist");
  const temporaryDirectory = path.join(projectRoot, ".dist-building");

  for (const target of [distDirectory, temporaryDirectory]) {
    if (path.dirname(target) !== projectRoot) {
      throw new Error(`Build target escaped the project root: ${target}`);
    }
  }

  await rm(temporaryDirectory, {
    recursive: true,
    force: true,
  });

  await rm(distDirectory, {
    recursive: true,
    force: true,
  });

  try {
    await mkdir(temporaryDirectory, {
      recursive: false,
    });

    await cp(sourceDirectory, temporaryDirectory, {
      recursive: true,
      force: false,
      errorOnExist: true,
    });

    const JavaScriptFiles = await findJavaScriptFiles(temporaryDirectory);

    if (JavaScriptFiles.length === 0) {
      throw new Error("The build produced no JavaScript files.");
    }

    for (const filePath of JavaScriptFiles) {
      await runNodeSyntaxCheck(filePath);
    }

    await rename(temporaryDirectory, distDirectory);

    console.log(
      `Build completed with ${JavaScriptFiles.length} JavaScript files.`,
    );
    console.log(`Generated output: ${distDirectory}`);
  } catch (error) {
    await rm(temporaryDirectory, {
      recursive: true,
      force: true,
    });

    throw error;
  }
}

main().catch((error) => {
  console.error("Build failed:", error);
  process.exitCode = 1;
});
'@

Set-Content `
    -LiteralPath "$scriptsDirectory\build.js" `
    -Value $buildScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

> JavaScript convention normally uses lower-camel-case local variable names. The variable `JavaScriptFiles` is valid but unconventional. Correct it before verification:

```powershell
$buildPath = Join-Path $scriptsDirectory "build.js"

$buildText = Get-Content `
    -LiteralPath $buildPath `
    -Raw

$buildText = $buildText.Replace(
    "const JavaScriptFiles =",
    "const javaScriptFiles ="
).Replace(
    "JavaScriptFiles.length",
    "javaScriptFiles.length"
).Replace(
    "for (const filePath of JavaScriptFiles)",
    "for (const filePath of javaScriptFiles)"
)

Set-Content `
    -LiteralPath $buildPath `
    -Value $buildText `
    -Encoding UTF8
```

The complete resulting file now uses `javaScriptFiles` consistently.

Run the build:

```powershell
npm.cmd run build
```

### The Verification

Confirm generated output:

```powershell
$buildChecks = @(
    [PSCustomObject]@{
        File = "dist\app.js"
        Exists = Test-Path `
            -LiteralPath .\dist\app.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        File = "dist\index.js"
        Exists = Test-Path `
            -LiteralPath .\dist\index.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        File = ".dist-building"
        Exists = Test-Path `
            -LiteralPath .\.dist-building
    }
)

$buildChecks |
    Format-Table -AutoSize
```

Expected:

- `dist\app.js`: `True`
- `dist\index.js`: `True`
- `.dist-building`: `False`

Compare source and generated hashes:

```powershell
$sourceAppHash = (
    Get-FileHash `
        -LiteralPath .\src\app.js `
        -Algorithm SHA256
).Hash

$distAppHash = (
    Get-FileHash `
        -LiteralPath .\dist\app.js `
        -Algorithm SHA256
).Hash

$sourceIndexHash = (
    Get-FileHash `
        -LiteralPath .\src\index.js `
        -Algorithm SHA256
).Hash

$distIndexHash = (
    Get-FileHash `
        -LiteralPath .\dist\index.js `
        -Algorithm SHA256
).Hash

[PSCustomObject]@{
    AppMatches = $sourceAppHash -eq $distAppHash
    IndexMatches = $sourceIndexHash -eq $distIndexHash
}
```

Both values should be `True`.

---

## 3.18 Run the Development Script

### The Target

Start the source application with Node.js watch mode:

```powershell
npm run dev
```

### The Concept

Watch mode monitors source files. When a source file changes, Node.js restarts the process.

It is like a stage crew automatically resetting the performance whenever the script is revised.

Watch mode is for development. Production should run stable generated output without automatically restarting because a file changed.

### The Implementation

Run:

```powershell
npm.cmd run dev
```

Expected startup output includes:

```text
developer-service listening at http://127.0.0.1:3000
```

In a second PowerShell terminal, test the root route:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/" `
    -Method Get
```

Test the echo route:

```powershell
$echoBody = @{
    message = "Hello from PowerShell"
    count = 3
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $echoBody
```

Test a missing route while preserving the response details:

```powershell
try {
    Invoke-RestMethod `
        -Uri "http://127.0.0.1:3000/missing" `
        -Method Get `
        -ErrorAction Stop
}
catch {
    Write-Host "The missing route correctly returned an HTTP error." -ForegroundColor Green
    Write-Host $_.Exception.Message
}
```

Stop the development server with `Ctrl+C`.

### The Verification

Start it again and request the health endpoint:

```powershell
npm.cmd run dev
```

From a second terminal:

```powershell
$health = Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get

[PSCustomObject]@{
    StatusIsOk = $health.status -eq "ok"
    UptimeIsNumeric = $health.uptimeSeconds -is [int]
    TimestampExists = -not [string]::IsNullOrWhiteSpace(
        $health.timestamp
    )
}
```

Every value should be `True`.

Stop the server with `Ctrl+C`.

---

## 3.19 Run the Production Start Lifecycle

### The Target

Execute:

```powershell
npm start
```

and observe npm’s automatic `prestart` behavior.

### The Concept

npm recognizes lifecycle script names.

When `npm start` runs, npm automatically executes:

```text
prestart → start → poststart
```

if those scripts exist.

Our manifest defines:

```json
"prestart": "npm run build",
"start": "node dist/index.js"
```

Therefore, `npm start` rebuilds the application before starting generated output.

### The Implementation

Clean generated output:

```powershell
npm.cmd run clean
```

Confirm `dist` is absent:

```powershell
Test-Path -LiteralPath .\dist
```

Expected result:

```text
False
```

Start the production lifecycle:

```powershell
npm.cmd start
```

You should observe:

1. `prestart`
2. `npm run build`
3. `start`
4. The generated server starting from `dist/index.js`

In another terminal, run:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health"
```

Stop the service with `Ctrl+C`.

### The Verification

Confirm that `prestart` recreated the build:

```powershell
[PSCustomObject]@{
    DistExists = Test-Path `
        -LiteralPath .\dist `
        -PathType Container
    GeneratedEntryExists = Test-Path `
        -LiteralPath .\dist\index.js `
        -PathType Leaf
    GeneratedAppExists = Test-Path `
        -LiteralPath .\dist\app.js `
        -PathType Leaf
}
```

Every value should be `True`.

---

## 3.20 Run the Complete Quality Gate

### The Target

Execute linting, tests, and building through one npm script:

```powershell
npm run check
```

### The Concept

A quality gate is a set of checks that must all pass before code is considered ready.

The script uses:

```text
&&
```

which means “run the next command only if the previous command succeeded.”

The sequence is:

```text
lint → test → build
```

If linting fails, tests and the build do not continue. If tests fail, the build does not continue.

### The Implementation

Run:

```powershell
npm.cmd run check
```

The underlying manifest entry is:

```json
"check": "npm run lint && npm test && npm run build"
```

Because npm scripts invoke other npm scripts, npm handles locating its executable and local package binaries.

### The Verification

Inspect the exit code immediately:

```powershell
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host "The complete quality gate passed." -ForegroundColor Green
}
else {
    throw "The quality gate failed with exit code $exitCode."
}
```

Confirm generated output remains available:

```powershell
Test-Path `
    -LiteralPath .\dist\index.js `
    -PathType Leaf
```

Expected result:

```text
True
```

---

## 3.21 Execute a Package with `npx`

### The Target

Use `npx` in both local-binary and temporary-package modes.

### The Concept

`npx` follows a useful search pattern:

1. Look for a matching executable in the current project.
2. If permitted, acquire a package temporarily.
3. Execute its command.

Use npx when you need to run a package binary—not when you need to import the package into application code.

### The Implementation

Run the locally installed ESLint binary:

```powershell
npx.cmd eslint --version
```

Run linting:

```powershell
npx.cmd eslint .
```

Now run a temporary demonstration package without adding it to `package.json`:

```powershell
npx.cmd --yes cowsay "npx can run a temporary package"
```

The `--yes` option accepts the package-execution prompt non-interactively.

Confirm that `cowsay` was not added as an application dependency:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    InDependencies = $null -ne $packageData.dependencies.cowsay
    InDevDependencies = $null -ne $packageData.devDependencies.cowsay
}
```

Both values should be `False`.

### The Verification

Confirm ESLint still resolves from the project:

```powershell
$eslintBinary = Join-Path `
    -Path $projectRoot `
    -ChildPath "node_modules\.bin\eslint.cmd"

Test-Path `
    -LiteralPath $eslintBinary `
    -PathType Leaf
```

Expected result on Windows:

```text
True
```

Confirm the manifest does not contain `cowsay`:

```powershell
Select-String `
    -LiteralPath .\package.json `
    -Pattern '"cowsay"' `
    -SimpleMatch
```

Expected result: no match.

> Temporary npx execution still downloads and executes third-party code. Review package identity and provenance before running unfamiliar tools.

---

## 3.22 Compare npm and pnpm Safely

### The Target

Inspect pnpm availability and learn its installation route without converting the current project.

### The Concept

npm and pnpm solve the same broad problem but arrange installed dependencies differently.

npm generally creates a conventional dependency tree under each project’s `node_modules`.

pnpm stores package contents in a shared content-addressable store and links projects to those contents. “Content-addressable” means files are identified by a fingerprint of their content.

Do not run `pnpm install` inside this npm-managed project. Doing so can create competing lockfiles and confuse the source of truth.

### The Implementation

Check whether pnpm is available:

```powershell
$pnpmCommand = Get-Command `
    -Name pnpm `
    -ErrorAction SilentlyContinue

if ($null -ne $pnpmCommand) {
    pnpm --version
}
else {
    Write-Host "pnpm is not currently installed." -ForegroundColor Yellow
}
```

Modern Node.js installations may include Corepack, which can manage package-manager shims:

```powershell
Get-Command corepack -ErrorAction SilentlyContinue
```

If your organization permits Corepack, a version can be activated explicitly. Because package-manager versions change over time, consult the pnpm project’s current installation guidance rather than selecting an arbitrary global version.

An alternative installation is:

```powershell
npm.cmd install --global pnpm
```

A global installation makes the command available beyond one project. It is not required to complete this tutorial.

If pnpm is installed, inspect its shared store:

```powershell
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    pnpm store path
}
```

### The Verification

Confirm this project remains npm-managed:

```powershell
[PSCustomObject]@{
    NpmLockExists = Test-Path `
        -LiteralPath .\package-lock.json `
        -PathType Leaf
    PnpmLockAbsent = -not (
        Test-Path -LiteralPath .\pnpm-lock.yaml
    )
}
```

Both values should be `True`.

---

## 3.23 Reproduce Dependencies with `npm ci`

### The Target

Delete generated dependencies and reconstruct them exactly from `package-lock.json`.

### The Concept

`npm install` resolves dependencies and may update the lockfile when necessary.

`npm ci` means “clean install.” It is designed for reproducible automated environments:

- Requires a lockfile
- Removes existing `node_modules`
- Installs the locked dependency tree
- Fails if `package.json` and the lockfile disagree
- Does not rewrite dependency declarations

It is like rebuilding a machine from an exact parts manifest instead of shopping from flexible requirements.

### The Implementation

First, ensure the project passes:

```powershell
npm.cmd run check
```

Remove `node_modules` using PowerShell’s safe, exact path:

```powershell
$nodeModulesPath = Join-Path $projectRoot "node_modules"

Remove-Item `
    -LiteralPath $nodeModulesPath `
    -Recurse `
    -Force `
    -ErrorAction Stop
```

Confirm removal:

```powershell
Test-Path -LiteralPath $nodeModulesPath
```

Expected result:

```text
False
```

Reinstall exactly from the lockfile:

```powershell
npm.cmd ci
```

### The Verification

Confirm dependencies were reconstructed:

```powershell
[PSCustomObject]@{
    NodeModulesRestored = Test-Path `
        -LiteralPath $nodeModulesPath `
        -PathType Container
    ExpressRestored = Test-Path `
        -LiteralPath "$nodeModulesPath\express" `
        -PathType Container
    EslintBinaryRestored = Test-Path `
        -LiteralPath "$nodeModulesPath\.bin\eslint.cmd" `
        -PathType Leaf
}
```

Every value should be `True`.

Run the quality gate again:

```powershell
npm.cmd run check
```

Expected result: linting, all four tests, and the build pass.

---

# Part 3 Reference A: npm Dependency Commands

## Install all declared dependencies

```powershell
npm.cmd install
```

Common shorthand:

```powershell
npm.cmd i
```

## Install a runtime dependency

```powershell
npm.cmd install express
```

This updates:

```text
dependencies
```

## Install a development dependency

```powershell
npm.cmd install --save-dev eslint
```

Shorthand:

```powershell
npm.cmd install -D eslint
```

This updates:

```text
devDependencies
```

## Remove a dependency

```powershell
npm.cmd uninstall express
```

This updates the manifest, lockfile, and installed dependency tree.

Do not run that command in this project because Express is required.

## Inspect top-level dependencies

```powershell
npm.cmd list --depth=0
```

## Inspect one package

```powershell
npm.cmd list express --depth=0
```

## Find outdated packages

```powershell
npm.cmd outdated
```

An outdated report is not permission to upgrade blindly. Review release notes and test changes.

## Audit known vulnerabilities

```powershell
npm.cmd audit
```

Use caution with automated remediation:

```text
npm audit fix --force
```

Forced remediation can introduce breaking major-version changes. Review the proposed dependency changes first.

---

# Part 3 Reference B: Version Ranges

A dependency entry may resemble:

```json
{
  "dependencies": {
    "express": "^5.1.0"
  }
}
```

The exact version will depend on what npm installs at the time you follow the tutorial.

Common range syntax includes:

| Range | General meaning |
|---|---|
| `1.2.3` | Exactly version 1.2.3 |
| `^1.2.3` | Compatible updates that do not change the major version |
| `~1.2.3` | Patch-level updates within the minor version |
| `>=1.2.3` | Version 1.2.3 or later |
| `*` | Any version |

Semantic versions use:

```text
major.minor.patch
```

For example:

```text
5.2.1
```

- **Major**: potentially incompatible changes
- **Minor**: backward-compatible features
- **Patch**: backward-compatible fixes

The lockfile records the exact installed result even when `package.json` permits a range.

---

# Part 3 Reference C: npm Scripts

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

Run custom scripts with:

```powershell
npm.cmd run lint
npm.cmd run build
```

Some conventional scripts omit `run`:

```powershell
npm.cmd test
npm.cmd start
```

List available scripts:

```powershell
npm.cmd run
```

## Lifecycle hooks

npm automatically recognizes prefixes:

```text
pre<script>
<script>
post<script>
```

For example:

```json
{
  "scripts": {
    "prestart": "npm run build",
    "start": "node dist/index.js",
    "poststart": "node scripts/report-stop.js"
  }
}
```

Running:

```powershell
npm.cmd start
```

executes them in order.

## Local executable resolution

During npm scripts, this directory is added to `PATH`:

```text
node_modules\.bin
```

Therefore:

```json
"lint": "eslint ."
```

uses the project-local ESLint version.

---

# Part 3 Reference D: `npm install` Versus `npm ci`

| Behavior | `npm install` | `npm ci` |
|---|---|---|
| Requires lockfile | No | Yes |
| May update lockfile | Yes | No |
| Removes existing `node_modules` first | Not necessarily | Yes |
| Intended for adding packages | Yes | No |
| Intended for CI and reproducible setup | Sometimes | Yes |
| Fails on manifest/lock mismatch | May reconcile | Yes |

Use:

```powershell
npm.cmd install
```

during normal dependency development.

Use:

```powershell
npm.cmd ci
```

for clean automated installations and reproducibility checks.

---

# Part 3 Reference E: npx Safety and Resolution

## Run a local binary

```powershell
npx.cmd eslint .
```

## Run a temporary package

```powershell
npx.cmd --yes cowsay "Hello"
```

## Run a specifically named package

When command and package names differ:

```powershell
npx.cmd --package some-package some-command
```

## Security principle

Running an npm package executes code on your computer with your user’s permissions.

Before running an unfamiliar package:

- Check the exact package name
- Check the publisher
- Check the repository
- Check recent maintenance
- Check known security advisories
- Prefer an explicit version for sensitive workflows
- Avoid confusingly similar package names

Do not treat `npx` as a safe sandbox. It is an execution mechanism.

---

# Part 3 Reference F: PowerShell Execution Policies

Inspect all scopes:

```powershell
Get-ExecutionPolicy -List
```

Inspect the effective policy:

```powershell
Get-ExecutionPolicy
```

## No-policy-change workaround

Use the command wrapper:

```powershell
npm.cmd --version
npx.cmd --version
```

This is often the narrowest solution.

## Process-only setting

```powershell
Set-ExecutionPolicy `
    -Scope Process `
    -ExecutionPolicy Bypass
```

This expires when the process exits.

## User-level setting

```powershell
Set-ExecutionPolicy `
    -Scope CurrentUser `
    -ExecutionPolicy RemoteSigned
```

This persists for the current user.

## Unblock a trusted downloaded script

After inspecting a script and confirming its origin:

```powershell
Unblock-File `
    -LiteralPath .\trusted-script.ps1
```

Do not unblock scripts indiscriminately.

## Organizational policy

If these scopes are set:

```text
MachinePolicy
UserPolicy
```

they may be controlled by Group Policy. Do not bypass organization-managed restrictions.

---

# Part 3 Reference G: Local, Global, and Temporary Packages

## Local package

Installed in the current project:

```powershell
npm.cmd install --save-dev eslint
```

Stored under:

```text
developer-service\node_modules
```

Declared in:

```text
developer-service\package.json
```

Preferred for project tools because every developer receives the declared version.

## Global package

Installed for broader command-line use:

```powershell
npm.cmd install --global some-tool
```

Inspect the global package root:

```powershell
npm.cmd root --global
```

Global tools are convenient but can create version differences between machines.

## Temporary npx package

Executed without adding it to the project manifest:

```powershell
npx.cmd --yes cowsay "Temporary execution"
```

Useful for one-time tools, but still executes third-party code.

---

# Part 3 Reference H: Common Node.js Project Mistakes

## Mistake 1: Committing `node_modules`

Commit:

```text
package.json
package-lock.json
```

Ignore:

```text
node_modules/
```

## Mistake 2: Deleting the lockfile casually

The lockfile preserves the exact dependency tree. Deleting it can produce different transitive versions.

## Mistake 3: Installing every tool globally

A global ESLint can differ from the version expected by the project.

Prefer:

```powershell
npm.cmd install --save-dev eslint
npm.cmd run lint
```

## Mistake 4: Using `npx` without checking the package name

Typographical package-name attacks exist. Review unfamiliar packages before executing them.

## Mistake 5: Mixing package managers

Avoid maintaining both:

```text
package-lock.json
pnpm-lock.yaml
```

unless the project deliberately supports that arrangement.

## Mistake 6: Weakening execution policy globally

Do not apply a machine-wide unrestricted policy merely to run npm.

Try:

```powershell
npm.cmd
```

first.

## Mistake 7: Running source and generated output inconsistently

Use explicit scripts:

```powershell
npm.cmd run dev
npm.cmd start
```

The first runs source with watch mode. The second builds and runs generated output.

## Mistake 8: Assuming installation success proves application quality

Run:

```powershell
npm.cmd run check
```

Installation, linting, testing, and building prove different things.

---

# Part 3 Final Verification

## The Target

Verify the complete Node.js project before introducing environment configuration in Part 4.

### The Concept

This checkpoint validates four layers:

1. Runtime tools
2. Dependency state
3. Source code
4. Generated output

A single successful server request would not prove that linting and tests pass. A successful build would not prove that dependencies can be reconstructed. Each layer receives its own check.

### The Implementation

Reconstruct project paths:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$projectRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "developer-service"

Set-Location -LiteralPath $projectRoot
```

Run the clean dependency installation:

```powershell
npm.cmd ci
```

Run the quality gate:

```powershell
npm.cmd run check
```

Build the verification list:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$partThreeChecks = @(
    [PSCustomObject]@{
        Check = "Node.js is available"
        Passed = $null -ne (
            Get-Command node -ErrorAction SilentlyContinue
        )
    }

    [PSCustomObject]@{
        Check = "npm command wrapper is available"
        Passed = $null -ne (
            Get-Command npm.cmd -ErrorAction SilentlyContinue
        )
    }

    [PSCustomObject]@{
        Check = "package.json exists"
        Passed = Test-Path `
            -LiteralPath .\package.json `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "package-lock.json exists"
        Passed = Test-Path `
            -LiteralPath .\package-lock.json `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "node_modules exists"
        Passed = Test-Path `
            -LiteralPath .\node_modules `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "Express is a runtime dependency"
        Passed = $null -ne $packageData.dependencies.express
    }

    [PSCustomObject]@{
        Check = "ESLint is a development dependency"
        Passed = $null -ne $packageData.devDependencies.eslint
    }

    [PSCustomObject]@{
        Check = "Source app exists"
        Passed = Test-Path `
            -LiteralPath .\src\app.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Source entry point exists"
        Passed = Test-Path `
            -LiteralPath .\src\index.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Automated tests exist"
        Passed = Test-Path `
            -LiteralPath .\test\server.test.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "ESLint configuration exists"
        Passed = Test-Path `
            -LiteralPath .\eslint.config.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Clean script exists"
        Passed = Test-Path `
            -LiteralPath .\scripts\clean.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Build script exists"
        Passed = Test-Path `
            -LiteralPath .\scripts\build.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Generated app exists"
        Passed = Test-Path `
            -LiteralPath .\dist\app.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Generated entry point exists"
        Passed = Test-Path `
            -LiteralPath .\dist\index.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Temporary build directory is absent"
        Passed = -not (
            Test-Path -LiteralPath .\.dist-building
        )
    }

    [PSCustomObject]@{
        Check = "npm lockfile is selected"
        Passed = -not (
            Test-Path -LiteralPath .\pnpm-lock.yaml
        )
    }

    [PSCustomObject]@{
        Check = "Project is private"
        Passed = $packageData.private -eq $true
    }
)

$partThreeChecks |
    Format-Table Check, Passed -AutoSize
```

Compare source and generated output:

```powershell
$buildHashChecks = @(
    [PSCustomObject]@{
        File = "app.js"
        Matches = (
            Get-FileHash `
                -LiteralPath .\src\app.js `
                -Algorithm SHA256
        ).Hash -eq (
            Get-FileHash `
                -LiteralPath .\dist\app.js `
                -Algorithm SHA256
        ).Hash
    }

    [PSCustomObject]@{
        File = "index.js"
        Matches = (
            Get-FileHash `
                -LiteralPath .\src\index.js `
                -Algorithm SHA256
        ).Hash -eq (
            Get-FileHash `
                -LiteralPath .\dist\index.js `
                -Algorithm SHA256
        ).Hash
    }
)

$buildHashChecks |
    Format-Table -AutoSize
```

### The Verification

Combine all checks:

```powershell
$failedPartThreeChecks = @(
    $partThreeChecks |
        Where-Object { -not $_.Passed }

    $buildHashChecks |
        Where-Object { -not $_.Matches } |
        ForEach-Object {
            [PSCustomObject]@{
                Check = "Build hash matches: $($_.File)"
                Passed = $false
            }
        }
)
```

Report the result:

```powershell
if ($failedPartThreeChecks.Count -eq 0) {
    Write-Host "Part 3 final verification passed." -ForegroundColor Green
}
else {
    Write-Host "Part 3 final verification failed." -ForegroundColor Red

    $failedPartThreeChecks |
        Format-Table -AutoSize

    throw "Repair the failed Part 3 checks before continuing."
}
```

Expected message:

```text
Part 3 final verification passed.
```

Perform one final live service check.

Start the generated application in a background process:

```powershell
$serviceProcess = Start-Process `
    -FilePath (Get-Command node).Source `
    -ArgumentList @(
        "$projectRoot\dist\index.js"
    ) `
    -WorkingDirectory $projectRoot `
    -PassThru `
    -WindowStyle Hidden
```

Wait briefly for startup:

```powershell
$serviceReady = $false

for ($attempt = 1; $attempt -le 20; $attempt++) {
    try {
        $health = Invoke-RestMethod `
            -Uri "http://127.0.0.1:3000/health" `
            -TimeoutSec 1 `
            -ErrorAction Stop

        if ($health.status -eq "ok") {
            $serviceReady = $true
            break
        }
    }
    catch {
        Start-Sleep -Milliseconds 250
    }
}
```

Verify and stop it:

```powershell
try {
    if (-not $serviceReady) {
        throw "The generated service did not become healthy."
    }

    $rootResponse = Invoke-RestMethod `
        -Uri "http://127.0.0.1:3000/" `
        -Method Get

    [PSCustomObject]@{
        HealthStatus = $health.status
        ServiceName = $rootResponse.service
        Message = $rootResponse.message
    }
}
finally {
    if (
        $null -ne $serviceProcess -and
        -not $serviceProcess.HasExited
    ) {
        Stop-Process `
            -Id $serviceProcess.Id `
            -ErrorAction SilentlyContinue

        $serviceProcess.WaitForExit(5000)
    }
}
```

Expected values include:

```text
HealthStatus : ok
ServiceName  : developer-service
```

---

# Part 3 Key Takeaways

You now have a complete Node.js project lifecycle.

## Runtime and package tools

You learned the difference between:

```text
node → executes JavaScript
npm  → manages project packages
npx  → runs package-provided executables
pnpm → alternative package manager with a shared content-addressable store
```

These tools cooperate, but they serve different roles.

## Project initialization

You initialized a project with:

```powershell
npm.cmd init -y
```

You then replaced the generated defaults with an explicit `package.json` that declares:

- Project identity
- A minimum Node.js version
- Runtime dependencies
- Development dependencies
- Repeatable project scripts
- A production entry point
- Protection against accidental npm publication

## Runtime and development dependencies

You installed Express as a runtime dependency:

```powershell
npm.cmd install express
```

You installed ESLint as a development dependency:

```powershell
npm.cmd install --save-dev eslint
```

The resulting distinction is:

```text
dependencies    → packages needed by the running service
devDependencies → packages needed to develop, test, lint, or build it
```

## Dependency metadata

You learned the separate roles of:

```text
package.json      → declared project requirements and scripts
package-lock.json → exact resolved dependency tree
node_modules      → locally installed package files
```

`package.json` and `package-lock.json` should normally be committed to Git.

`node_modules` should normally be ignored because npm can reconstruct it.

## Reproducible installation

You used:

```powershell
npm.cmd install
```

while actively adding and updating dependencies.

You used:

```powershell
npm.cmd ci
```

to reconstruct an exact dependency tree from `package-lock.json`.

A clean `npm ci` followed by a passing quality gate provides stronger evidence that another development or CI machine can reproduce the project.

## Project scripts

You created these commands:

```powershell
npm.cmd run clean
npm.cmd run lint
npm.cmd test
npm.cmd run build
npm.cmd run dev
npm.cmd start
npm.cmd run check
```

The project now documents its normal operations through `package.json` instead of requiring every developer to memorize low-level commands.

## npm lifecycle hooks

You configured:

```json
{
  "prestart": "npm run build",
  "start": "node dist/index.js"
}
```

Running:

```powershell
npm.cmd start
```

automatically builds the service before starting generated output.

## Package execution with npx

You used npx to execute a locally installed binary:

```powershell
npx.cmd eslint .
```

You also used it to execute a temporary package:

```powershell
npx.cmd --yes cowsay "npx can run a temporary package"
```

You verified that temporary execution did not add the demonstration package to `package.json`.

You also learned that npx is not a security sandbox. A package executed through npx runs code with your user account’s permissions.

## PowerShell execution policy

You inspected policy scopes with:

```powershell
Get-ExecutionPolicy -List
```

You learned that a common npm error occurs because PowerShell selects:

```text
npm.ps1
```

and the effective execution policy blocks PowerShell scripts.

The narrowest workaround is often:

```powershell
npm.cmd
npx.cmd
```

This avoids changing execution policy.

When a policy change is justified, process scope is temporary:

```powershell
Set-ExecutionPolicy `
    -Scope Process `
    -ExecutionPolicy Bypass
```

A commonly used persistent user-level policy is:

```powershell
Set-ExecutionPolicy `
    -Scope CurrentUser `
    -ExecutionPolicy RemoteSigned
```

Organization-managed `MachinePolicy` or `UserPolicy` settings should not be circumvented.

## Application architecture

You separated the service into:

```text
src/app.js   → constructs and configures the Express application
src/index.js → opens the network port and controls process lifecycle
```

That separation allowed automated tests to create the application without launching a permanent production process.

## HTTP behavior

The service now exposes:

```text
GET  /        → service information
GET  /health  → health and uptime information
POST /echo    → echoes a parsed JSON request body
*    unknown  → structured 404 response
```

It also includes:

- A JSON body-size limit
- A disabled `X-Powered-By` header
- Central Express error handling
- Startup error handling
- Signal handling
- A graceful shutdown timeout
- Uncaught exception and unhandled rejection handling

## Automated quality checks

The complete quality gate is:

```powershell
npm.cmd run check
```

It executes:

```text
lint → test → build
```

The build does not proceed unless linting and tests succeed.

## Generated output

The build process:

1. Removes stale output.
2. Copies source into a temporary directory.
3. checks JavaScript syntax.
4. Renames the completed temporary directory to `dist`.
5. Removes temporary output after a failure.

The final generated entry point is:

```text
dist/index.js
```

---

## Part 3 Completion Checklist

Before moving to runtime configuration, confirm that you can perform and explain each task:

- [ ] Run JavaScript with `node`
- [ ] Display the Node.js version
- [ ] Display the npm and npx versions
- [ ] Explain the difference between Node.js, npm, npx, and pnpm
- [ ] Inspect all PowerShell execution-policy scopes
- [ ] Explain why `npm.ps1` may be blocked
- [ ] Use `npm.cmd` without weakening execution policy
- [ ] Initialize a project with `npm init -y`
- [ ] Read and parse `package.json`
- [ ] Install a runtime dependency
- [ ] Install a development dependency
- [ ] Explain the purpose of `package-lock.json`
- [ ] Explain why `node_modules` should not be committed
- [ ] Reconstruct dependencies with `npm ci`
- [ ] List installed top-level packages
- [ ] Run a project-local binary with npx
- [ ] Execute an intentionally selected temporary package with npx
- [ ] Define and execute npm scripts
- [ ] Explain npm lifecycle hooks such as `prestart`
- [ ] Run source code in watch mode
- [ ] Build generated output
- [ ] Run the generated service
- [ ] Test an HTTP endpoint from PowerShell
- [ ] Execute automated tests
- [ ] Run ESLint
- [ ] Run the complete quality gate
- [ ] Explain the difference between development and production commands
- [ ] Explain why npm and pnpm lockfiles should not be mixed casually

---

## Current Project Architecture

At the end of Part 3, the project should resemble:

```text
developer-service/
├── dist/
│   ├── app.js
│   └── index.js
├── node_modules/
│   └── ...
├── scripts/
│   ├── build.js
│   └── clean.js
├── src/
│   ├── app.js
│   └── index.js
├── test/
│   └── server.test.js
├── .gitignore
├── eslint.config.js
├── package-lock.json
└── package.json
```

The generated and installed directories have different purposes:

```text
node_modules/ → installed third-party packages
dist/         → generated application output
src/          → application source code
scripts/      → project automation
test/         → automated behavioral tests
```

Both `node_modules` and `dist` are reproducible and excluded from Git. Source, tests, scripts, the manifest, and the lockfile belong in version control.

---

## What Comes Next

The service currently contains fixed runtime values:

```javascript
const HOST = "127.0.0.1";
const PORT = 3000;
```

That is sufficient for proving the Node.js lifecycle, but it is not flexible enough for real deployment.

Part 4 will move runtime settings outside source code.

You will:

- Inspect PowerShell’s environment provider
- Read variables through `$env:`
- Create session-scoped environment variables
- Remove temporary variables
- Compare process, user, and machine scopes
- Persist user-level variables with `[System.Environment]`
- Understand why existing processes do not automatically receive later changes
- Install and configure `dotenv`
- Create a secret-bearing `.env` file
- Create a safe `.env.example` template
- Verify that Git ignores `.env`
- Build a typed, validated configuration module
- Reject missing secrets and invalid ports during startup
- Configure development and production modes
- Update tests for environment-based behavior
- Add safe startup and smoke-test scripts
- Customize `$PROFILE`
- Add reusable PowerShell functions for project navigation and quality checks
- Keep project-specific secrets out of the PowerShell profile
- Produce and verify the final production-ready local architecture

The final configuration flow will be:

```text
PowerShell session variables
            │
            ▼
      Node.js process
            │
            ├── existing environment variables
            │
            └── missing values loaded from .env
                         │
                         ▼
                validation and typing
                         │
                         ▼
              application configuration
```

A value supplied by the operating environment will take precedence over the corresponding `.env` value. This enables local convenience without preventing deployment systems from injecting secure production configuration.
