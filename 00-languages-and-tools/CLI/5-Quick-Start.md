# Part 5: The Entire Series in One Practical Quickstart

This part compresses the complete series into one streamlined workflow. It is designed as:

- A refresher after completing Parts 1–4
- A day-to-day command reference
- A shortened setup guide for a second Windows computer
- A practical explanation of how PowerShell, Node.js, npm, and environment variables work together

It does not replace the deeper explanations and safety exercises in the earlier parts. Instead, it collects the most important commands, patterns, and verification checks in one place.

The final workflow is:

```text
Navigate with PowerShell
        ↓
Create and manage files
        ↓
Initialize a Node.js project
        ↓
Install dependencies
        ↓
Run npm scripts
        ↓
Load and validate configuration
        ↓
Build and test the service
        ↓
Use PowerShell profile shortcuts
```

---

## 5.1 Verify the Developer Toolchain

### The Target

Confirm that PowerShell, Node.js, npm, and npx are available.

### The Concept

Before repairing an application, first check whether the tools needed to build it are present. This is like checking that a workshop has electricity before diagnosing a power tool.

### The Implementation

Display the PowerShell version:

```powershell
$PSVersionTable.PSVersion
```

Check the required commands:

```powershell
$requiredCommands = @(
    "node"
    "npm.cmd"
    "npx.cmd"
)

$toolChecks = foreach ($commandName in $requiredCommands) {
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

$toolChecks |
    Format-Table -AutoSize
```

Display versions:

```powershell
node --version
npm.cmd --version
npx.cmd --version
```

If Node.js is missing and Windows Package Manager is available, install the LTS release:

```powershell
winget install `
    --id OpenJS.NodeJS.LTS `
    --source winget `
    --accept-package-agreements `
    --accept-source-agreements
```

Close the terminal, open a new PowerShell session, and rerun the version commands.

### The Verification

Run:

```powershell
$missingTools = @(
    $requiredCommands |
        Where-Object {
            $null -eq (
                Get-Command `
                    -Name $_ `
                    -ErrorAction SilentlyContinue
            )
        }
)

if ($missingTools.Count -gt 0) {
    throw "Missing developer tools: $($missingTools -join ', ')"
}

node -e 'console.log("The Node.js toolchain is ready.");'
```

Expected result:

```text
The Node.js toolchain is ready.
```

---

## 5.2 Navigate the Filesystem

### The Target

Navigate between your home directory, series root, and Node.js project.

### The Concept

PowerShell always has a current location. Relative paths begin there, while absolute paths provide the complete destination.

The essential path symbols are:

| Symbol | Meaning |
|---|---|
| `.` | Current directory |
| `..` | Parent directory |
| `~` | Home directory |
| `$HOME` | Home-directory path |
| `.\name` | Child item in the current directory |

### The Implementation

Display your current location:

```powershell
Get-Location
```

Return home:

```powershell
Set-Location -Path $HOME
```

Construct the series and project paths:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$projectRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "developer-service"
```

Enter the series:

```powershell
Set-Location -LiteralPath $seriesRoot
```

Enter the project with a relative path:

```powershell
Set-Location -Path .\developer-service
```

Move to the parent:

```powershell
Set-Location -Path ..
```

Return to the project:

```powershell
Set-Location -LiteralPath $projectRoot
```

Use tab completion by typing part of a path and pressing `Tab`:

```text
Set-Location .\dev
```

PowerShell should complete the matching directory name.

### The Verification

Confirm the current directory:

```powershell
if ((Get-Location).Path -ne $projectRoot) {
    throw "Expected to be in $projectRoot"
}

Write-Host "Project navigation passed." -ForegroundColor Green
```

---

## 5.3 Understand Native Commands and Aliases

### The Target

Identify the native PowerShell commands behind familiar short names.

### The Concept

An alias is a nickname. For example, `ls` is not necessarily the UNIX program when entered in PowerShell. It is normally an alias for `Get-ChildItem`.

Use aliases for fast interactive work and native command names for readable scripts.

### The Implementation

Inspect the common aliases:

```powershell
Get-Alias -Name pwd, cd, dir, ls, cp, mv, rm |
    Sort-Object Name |
    Select-Object Name, Definition
```

The important mappings are:

```text
pwd → Get-Location
cd  → Set-Location
dir → Get-ChildItem
ls  → Get-ChildItem
cp  → Copy-Item
mv  → Move-Item
rm  → Remove-Item
```

Interactive form:

```powershell
cd $HOME
ls
pwd
```

Clear script-oriented form:

```powershell
Set-Location -Path $HOME
Get-ChildItem
Get-Location
```

### The Verification

Run:

```powershell
$expectedAliases = @{
    pwd = "Get-Location"
    cd  = "Set-Location"
    dir = "Get-ChildItem"
    ls  = "Get-ChildItem"
    cp  = "Copy-Item"
    mv  = "Move-Item"
    rm  = "Remove-Item"
}

$aliasChecks = foreach ($entry in $expectedAliases.GetEnumerator()) {
    $alias = Get-Alias `
        -Name $entry.Key `
        -ErrorAction Stop

    [PSCustomObject]@{
        Alias = $entry.Key
        Expected = $entry.Value
        Actual = $alias.Definition
        Passed = $alias.Definition -eq $entry.Value
    }
}

$aliasChecks |
    Format-Table -AutoSize
```

Every `Passed` value should be `True`.

---

## 5.4 Inspect Files and Directories

### The Target

List, filter, and recursively inspect project files.

### The Concept

`Get-ChildItem` retrieves structured file and directory objects. You can filter their properties instead of parsing display text.

### The Implementation

Enter the project:

```powershell
Set-Location -LiteralPath $projectRoot
```

List immediate contents:

```powershell
Get-ChildItem
```

Include hidden files:

```powershell
Get-ChildItem -Force
```

List only directories:

```powershell
Get-ChildItem -Directory
```

List only files:

```powershell
Get-ChildItem -File
```

Find JavaScript files recursively:

```powershell
Get-ChildItem `
    -Path $projectRoot `
    -Filter "*.js" `
    -File `
    -Recurse
```

Exclude generated and dependency directories for a cleaner source-oriented report:

```powershell
Get-ChildItem `
    -LiteralPath $projectRoot `
    -File `
    -Recurse `
    -Force |
    Where-Object {
        $_.FullName -notlike "$projectRoot\node_modules\*" -and
        $_.FullName -notlike "$projectRoot\dist\*"
    } |
    Sort-Object FullName |
    Select-Object Name, Extension, Length, FullName
```

Inspect one file:

```powershell
Get-Item -LiteralPath .\package.json |
    Select-Object Name, Length, LastWriteTime, FullName
```

Check whether a path exists:

```powershell
Test-Path `
    -LiteralPath .\package.json `
    -PathType Leaf
```

### The Verification

Confirm the principal directories exist:

```powershell
$requiredDirectories = @(
    "src"
    "scripts"
    "test"
)

$directoryChecks = foreach ($directoryName in $requiredDirectories) {
    $directoryPath = Join-Path `
        -Path $projectRoot `
        -ChildPath $directoryName

    [PSCustomObject]@{
        Directory = $directoryName
        Exists = Test-Path `
            -LiteralPath $directoryPath `
            -PathType Container
    }
}

$directoryChecks |
    Format-Table -AutoSize
```

Every `Exists` value should be `True`.

---

## 5.5 Create, Copy, Move, and Delete Safely

### The Target

Perform the core filesystem operations inside a disposable quickstart directory.

### The Concept

File commands can change many resources quickly. Use a dedicated laboratory and preview destructive operations with `-WhatIf`.

The safe sequence is:

```text
Inspect → Preview → Execute → Verify
```

### The Implementation

Create a disposable laboratory:

```powershell
$quickstartLab = Join-Path `
    -Path $seriesRoot `
    -ChildPath "quickstart-lab"

if (Test-Path -LiteralPath $quickstartLab) {
    Remove-Item `
        -LiteralPath $quickstartLab `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

$null = New-Item `
    -Path "$quickstartLab\source" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop

$null = New-Item `
    -Path "$quickstartLab\archive" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop
```

Create a file:

```powershell
$sourceFile = Join-Path `
    -Path $quickstartLab `
    -ChildPath "source\example.txt"

Set-Content `
    -LiteralPath $sourceFile `
    -Value "PowerShell quickstart file." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Copy it:

```powershell
$copiedFile = Join-Path `
    -Path $quickstartLab `
    -ChildPath "archive\example-copy.txt"

Copy-Item `
    -LiteralPath $sourceFile `
    -Destination $copiedFile `
    -ErrorAction Stop
```

Rename the copy:

```powershell
$renamedFile = Join-Path `
    -Path $quickstartLab `
    -ChildPath "archive\example-archived.txt"

Rename-Item `
    -LiteralPath $copiedFile `
    -NewName "example-archived.txt" `
    -ErrorAction Stop
```

Preview deletion:

```powershell
Remove-Item `
    -LiteralPath $renamedFile `
    -WhatIf
```

Confirm that `-WhatIf` preserved it:

```powershell
Test-Path -LiteralPath $renamedFile
```

Delete it:

```powershell
Remove-Item `
    -LiteralPath $renamedFile `
    -ErrorAction Stop
```

Preview removal of the complete laboratory:

```powershell
Remove-Item `
    -LiteralPath $quickstartLab `
    -Recurse `
    -WhatIf
```

Remove it:

```powershell
Remove-Item `
    -LiteralPath $quickstartLab `
    -Recurse `
    -Force `
    -ErrorAction Stop
```

### The Verification

Confirm the complete laboratory is gone:

```powershell
if (Test-Path -LiteralPath $quickstartLab) {
    throw "The quickstart laboratory was not removed."
}

Write-Host "File-management quickstart passed." -ForegroundColor Green
```

Remember:

- `-Recurse` processes nested children.
- `-Force` handles ordinary hidden or read-only restrictions.
- `-Force` does not bypass Windows permissions.
- `Remove-Item` generally does not use the Recycle Bin.

---

## 5.6 Understand the Node.js Project Files

### The Target

Recognize the role of each major Node.js project resource.

### The Concept

A Node.js project separates declared requirements, exact installations, source code, generated output, and local configuration.

### The Implementation

The project’s core structure is:

```text
developer-service/
├── dist/                 # Generated application output
├── node_modules/         # Installed third-party packages
├── scripts/              # Build and operational automation
├── src/                  # Application source code
├── test/                 # Automated tests
├── .env                  # Private local configuration
├── .env.example          # Safe configuration template
├── .gitignore            # Files Git should ignore
├── eslint.config.js      # Static-analysis configuration
├── package-lock.json     # Exact dependency tree
└── package.json          # Metadata, dependencies, and scripts
```

Inspect the project manifest:

```powershell
Set-Location -LiteralPath $projectRoot

$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$packageData |
    Select-Object Name, Version, Description, Private
```

Inspect runtime dependencies:

```powershell
$packageData.dependencies |
    Format-List
```

Inspect development dependencies:

```powershell
$packageData.devDependencies |
    Format-List
```

Inspect project scripts:

```powershell
$packageData.scripts |
    Format-List
```

### The Verification

Confirm the project is private and has required dependencies:

```powershell
[PSCustomObject]@{
    CorrectName = $packageData.name -eq "developer-service"
    IsPrivate = $packageData.private -eq $true
    ExpressDeclared = $null -ne $packageData.dependencies.express
    DotenvDeclared = $null -ne $packageData.dependencies.dotenv
    EslintDeclared = $null -ne $packageData.devDependencies.eslint
}
```

Every value should be `True`.

---

## 5.7 Use npm for the Project Lifecycle

### The Target

Install dependencies and run every major project command.

### The Concept

npm has two major jobs:

1. Manage dependencies
2. Run commands declared by the project

The distinction among the principal tools is:

```text
node → executes JavaScript
npm  → installs dependencies and runs project scripts
npx  → runs package-provided command-line tools
pnpm → alternative package manager
```

This project uses npm and `package-lock.json`.

### The Implementation

Install the exact locked dependency tree:

```powershell
Set-Location -LiteralPath $projectRoot

npm.cmd ci
```

List top-level packages:

```powershell
npm.cmd list --depth=0
```

List available scripts:

```powershell
npm.cmd run
```

Run linting:

```powershell
npm.cmd run lint
```

Run tests:

```powershell
npm.cmd test
```

Build generated output:

```powershell
npm.cmd run build
```

Display public configuration:

```powershell
npm.cmd run config
```

Run the complete quality gate:

```powershell
npm.cmd run check
```

Use npx to invoke the project-local ESLint binary:

```powershell
npx.cmd eslint .
```

### The Verification

Run:

```powershell
npm.cmd run check
$qualityGateExitCode = $LASTEXITCODE

if ($qualityGateExitCode -ne 0) {
    throw "The quality gate failed with exit code $qualityGateExitCode."
}

Write-Host "Node.js project lifecycle passed." -ForegroundColor Green
```

---

## 5.8 Handle PowerShell Execution-Policy Errors

### The Target

Diagnose a blocked `npm.ps1` or `npx.ps1` command without unnecessarily weakening security.

### The Concept

PowerShell may resolve `npm` to `npm.ps1`. Execution policy can prevent that script from running.

The narrowest workaround is usually to call:

```powershell
npm.cmd
npx.cmd
```

These Windows command wrappers do not require changing PowerShell’s script-execution policy.

### The Implementation

Inspect policy scopes:

```powershell
Get-ExecutionPolicy -List
```

Inspect every npm command PowerShell can resolve:

```powershell
Get-Command npm -All |
    Select-Object Name, CommandType, Source
```

Use the command wrapper:

```powershell
npm.cmd --version
npx.cmd --version
```

If a temporary process-level policy is genuinely required:

```powershell
Set-ExecutionPolicy `
    -Scope Process `
    -ExecutionPolicy Bypass
```

This expires when the current PowerShell process closes.

A commonly used persistent user-level setting is:

```powershell
Set-ExecutionPolicy `
    -Scope CurrentUser `
    -ExecutionPolicy RemoteSigned
```

Do not change organization-controlled `MachinePolicy` or `UserPolicy` settings.

### The Verification

Run:

```powershell
$npmVersion = npm.cmd --version

if ([string]::IsNullOrWhiteSpace($npmVersion)) {
    throw "npm.cmd did not return a version."
}

Write-Host "npm is available: $npmVersion" -ForegroundColor Green
```

---

## 5.9 Manage Session Environment Variables

### The Target

Set, inspect, inherit, and remove temporary runtime configuration.

### The Concept

Environment variables are strings supplied to a process.

Variables assigned through `$env:` affect:

- The current PowerShell process
- Child processes started afterward

They do not automatically affect:

- An already running process
- An unrelated terminal
- A parent process

### The Implementation

Set temporary values:

```powershell
$env:NODE_ENV = "development"
$env:HOST = "127.0.0.1"
$env:PORT = "3200"
```

Inspect them:

```powershell
Get-Item Env:NODE_ENV
Get-Item Env:HOST
Get-Item Env:PORT
```

Verify child-process inheritance:

```powershell
node -e '
console.log({
  NODE_ENV: process.env.NODE_ENV,
  HOST: process.env.HOST,
  PORT: process.env.PORT,
});
'
```

Remove them:

```powershell
Remove-Item `
    Env:NODE_ENV,
    Env:HOST,
    Env:PORT `
    -ErrorAction SilentlyContinue
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    NODE_ENVRemoved = -not (Test-Path Env:NODE_ENV)
    HOSTRemoved = -not (Test-Path Env:HOST)
    PORTRemoved = -not (Test-Path Env:PORT)
}
```

Every value should be `True`.

---

## 5.10 Understand Persistent Environment Variables

### The Target

Create, inspect, and remove one harmless user-scoped variable.

### The Concept

Process variables disappear when the terminal closes. User-scoped variables are saved for new processes started by the current Windows user.

An existing terminal does not automatically receive a persistent value created after that terminal started.

### The Implementation

Create a demonstration variable:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "DEVELOPER_SERIES_DEMO",
    "user-scoped-value",
    [System.EnvironmentVariableTarget]::User
)
```

Read it directly from user scope:

```powershell
[System.Environment]::GetEnvironmentVariable(
    "DEVELOPER_SERIES_DEMO",
    [System.EnvironmentVariableTarget]::User
)
```

Copy it into the current process if needed:

```powershell
$env:DEVELOPER_SERIES_DEMO = (
    [System.Environment]::GetEnvironmentVariable(
        "DEVELOPER_SERIES_DEMO",
        [System.EnvironmentVariableTarget]::User
    )
)
```

Remove it from user scope:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "DEVELOPER_SERIES_DEMO",
    $null,
    [System.EnvironmentVariableTarget]::User
)
```

Remove it from the current process:

```powershell
Remove-Item `
    Env:DEVELOPER_SERIES_DEMO `
    -ErrorAction SilentlyContinue
```

### The Verification

Confirm both values are absent:

```powershell
$userValue = [System.Environment]::GetEnvironmentVariable(
    "DEVELOPER_SERIES_DEMO",
    [System.EnvironmentVariableTarget]::User
)

[PSCustomObject]@{
    UserValueRemoved = $null -eq $userValue
    ProcessValueRemoved = -not (
        Test-Path Env:DEVELOPER_SERIES_DEMO
    )
}
```

Both values should be `True`.

Do not use this mechanism as a production secret vault.

---

## 5.11 Understand `.env` and Configuration Precedence

### The Target

Verify the service’s local runtime configuration without displaying its secret.

### The Concept

The project uses two configuration sources:

1. Existing process environment variables
2. `.env` values used as fallbacks

The precedence is:

```text
process environment > .env
```

The `.env` file is local and private:

```text
.env
```

The safe documentation template is:

```text
.env.example
```

### The Implementation

Confirm both files exist:

```powershell
Set-Location -LiteralPath $projectRoot

[PSCustomObject]@{
    LocalEnvironmentExists = Test-Path `
        -LiteralPath .\.env `
        -PathType Leaf
    ExampleExists = Test-Path `
        -LiteralPath .\.env.example `
        -PathType Leaf
}
```

Display only `.env` variable names:

```powershell
Get-Content -LiteralPath .\.env |
    Where-Object {
        $_ -match "^[A-Za-z_][A-Za-z0-9_]*="
    } |
    ForEach-Object {
        ($_ -split "=", 2)[0]
    }
```

Display public resolved configuration:

```powershell
npm.cmd run config
```

Temporarily override the port:

```powershell
$env:PORT = "3201"

try {
    npm.cmd run config
}
finally {
    Remove-Item Env:PORT -ErrorAction SilentlyContinue
}
```

### The Verification

Confirm that public output does not reveal a secret field:

```powershell
$publicConfiguration = npm.cmd run config --silent

$publicText = $publicConfiguration -join "`n"

if ($publicText -match "(?i)APP_SECRET|appSecret") {
    throw "Public configuration exposed a secret field."
}

Write-Host "Public configuration is safe." -ForegroundColor Green
```

---

## 5.12 Verify Git Secret Protection

### The Target

Confirm that `.env` is ignored while `.env.example` remains trackable.

### The Concept

`.gitignore` is a guardrail. It prevents ordinary Git operations from adding an untracked local secret file.

It does not remove secrets already committed to Git history.

### The Implementation

Inspect the relevant rules:

```powershell
Select-String `
    -LiteralPath .\.gitignore `
    -Pattern "^\.env$|^\.env\.\*$|^!\.env\.example$"
```

If Git is installed:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    if (-not (Test-Path -LiteralPath .\.git)) {
        git init
    }

    git check-ignore -v .env
    git check-ignore .env.example
}
```

### The Verification

Run:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    git check-ignore -q .env
    $envIsIgnored = $LASTEXITCODE -eq 0

    git check-ignore -q .env.example
    $exampleIsIgnored = $LASTEXITCODE -eq 0

    [PSCustomObject]@{
        EnvIsIgnored = $envIsIgnored
        ExampleIsTrackable = -not $exampleIsIgnored
    }
}
else {
    $ignoreText = Get-Content `
        -LiteralPath .\.gitignore `
        -Raw

    [PSCustomObject]@{
        EnvRuleExists = $ignoreText -match "(?m)^\.env$"
        ExampleExceptionExists = (
            $ignoreText -match "(?m)^!\.env\.example$"
        )
    }
}
```

Every displayed check should be `True`.

---

## 5.13 Run the Service in Development Mode

### The Target

Start the source application with local `.env` configuration and watch mode.

### The Concept

Development mode runs source code directly and restarts when files change.

Production mode runs generated output after a successful build.

### The Implementation

Enter the project:

```powershell
Set-Location -LiteralPath $projectRoot
```

Start development mode:

```powershell
npm.cmd run dev
```

Expected startup information includes:

```text
http://127.0.0.1:3000
development
```

Open another PowerShell terminal.

Test the root route:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/" `
    -Method Get
```

Test the health route:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get
```

Test the echo route:

```powershell
$requestBody = @{
    message = "Hello from PowerShell"
    ready = $true
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $requestBody
```

Return to the server terminal and press `Ctrl+C`.

### The Verification

The health response should contain:

```text
status      : ok
environment : development
```

The server should shut down cleanly after `Ctrl+C`.

---

## 5.14 Run the Production Quality Workflow

### The Target

Perform a clean installation, complete quality gate, and production-mode smoke test.

### The Concept

A production-conscious workflow verifies more than “the server started.”

It validates:

```text
dependencies
    ↓
linting
    ↓
automated tests
    ↓
build
    ↓
built-service smoke test
    ↓
production-mode process test
```

### The Implementation

Enter the project:

```powershell
Set-Location -LiteralPath $projectRoot
```

Install locked dependencies:

```powershell
npm.cmd ci
```

Run the complete quality gate:

```powershell
npm.cmd run check
```

Run the PowerShell production smoke test:

```powershell
$productionResult = & .\scripts\Test-ProductionService.ps1 `
    -Port 43131

$productionResult |
    Format-List
```

### The Verification

Run:

```powershell
if ($LASTEXITCODE -ne 0) {
    throw "A Node.js command failed."
}

if ($productionResult.Passed -ne $true) {
    throw "The production service smoke test failed."
}

[PSCustomObject]@{
    Status = $productionResult.Status
    Environment = $productionResult.Environment
    Port = $productionResult.Port
    Passed = $productionResult.Passed
}
```

Expected result includes:

```text
Status      : ok
Environment : production
Passed      : True
```

---

## 5.15 Use PowerShell Profile Shortcuts

### The Target

Load and use the profile functions created in Part 4.

### The Concept

A PowerShell profile prepares reusable commands whenever a new terminal starts.

The profile contains navigation and project-operation functions, but it must not contain secrets.

### The Implementation

Display the profile path:

```powershell
$PROFILE.CurrentUserCurrentHost
```

Load it into the current session:

```powershell
. $PROFILE.CurrentUserCurrentHost
```

Inspect the project functions:

```powershell
Get-Command `
    Enter-CliDeveloperSeries,
    Enter-DeveloperService,
    Invoke-DeveloperServiceCheck,
    Show-DeveloperServiceConfig,
    Start-DeveloperService |
    Select-Object Name, CommandType
```

Use the navigation shortcuts:

```powershell
cds
devservice
```

Display public configuration:

```powershell
Show-DeveloperServiceConfig
```

Run the complete quality gate:

```powershell
Invoke-DeveloperServiceCheck
```

Start development mode:

```powershell
Start-DeveloperService
```

Stop it with `Ctrl+C`.

### The Verification

Confirm that the aliases point to the expected functions:

```powershell
[PSCustomObject]@{
    CdsTarget = (Get-Alias cds).Definition
    DevServiceTarget = (Get-Alias devservice).Definition
}
```

Expected output:

```text
CdsTarget        : Enter-CliDeveloperSeries
DevServiceTarget : Enter-DeveloperService
```

Confirm that the profile contains no project secret:

```powershell
$profileText = Get-Content `
    -LiteralPath $PROFILE.CurrentUserCurrentHost `
    -Raw

if ($profileText -match "(?i)APP_SECRET") {
    throw "APP_SECRET must not be stored in the PowerShell profile."
}

Write-Host "Profile secret check passed." -ForegroundColor Green
```

---

# Part 5 Compressed Command Reference

## Navigation

```powershell
Get-Location
Set-Location -Path $HOME
Set-Location -Path ..
Set-Location -LiteralPath $projectRoot
```

## Inspection

```powershell
Get-ChildItem
Get-ChildItem -Force
Get-ChildItem -File
Get-ChildItem -Directory
Get-ChildItem -File -Recurse
Get-Item -LiteralPath .\package.json
Test-Path -LiteralPath .\package.json -PathType Leaf
```

## Creation

```powershell
New-Item `
    -Path .\example `
    -ItemType Directory
```

```powershell
New-Item `
    -Path .\example.txt `
    -ItemType File
```

```powershell
Set-Content `
    -LiteralPath .\example.txt `
    -Value "Example content" `
    -Encoding UTF8
```

## Copying and moving

```powershell
Copy-Item `
    -LiteralPath .\example.txt `
    -Destination .\example-copy.txt
```

```powershell
Move-Item `
    -LiteralPath .\example-copy.txt `
    -Destination .\archive\example.txt
```

```powershell
Rename-Item `
    -LiteralPath .\archive\example.txt `
    -NewName "example-archived.txt"
```

## Deletion

```powershell
Remove-Item `
    -LiteralPath .\example.txt `
    -WhatIf
```

```powershell
Remove-Item `
    -LiteralPath .\example.txt
```

```powershell
Remove-Item `
    -LiteralPath .\disposable-directory `
    -Recurse `
    -Force `
    -WhatIf
```

## Node.js and npm

```powershell
node --version
npm.cmd --version
npx.cmd --version
npm.cmd ci
npm.cmd list --depth=0
npm.cmd run
npm.cmd run lint
npm.cmd test
npm.cmd run build
npm.cmd run config
npm.cmd run check
npm.cmd run dev
npm.cmd start
```

## Environment variables

```powershell
Get-ChildItem Env:
$env:NODE_ENV = "development"
$env:PORT = "3200"
Remove-Item Env:NODE_ENV, Env:PORT
```

## Persistent user variable

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "example-value",
    [System.EnvironmentVariableTarget]::User
)
```

Remove it:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    $null,
    [System.EnvironmentVariableTarget]::User
)
```

## Project shortcuts

```powershell
devservice
Show-DeveloperServiceConfig
Invoke-DeveloperServiceCheck
Start-DeveloperService
```

---

# Part 5 Final Verification

## The Target

Run one compressed health check across the complete series.

### The Concept

This check verifies the important final state without repeating every individual exercise.

### The Implementation

Run:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$projectRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "developer-service"

if (-not (
    Test-Path `
        -LiteralPath $projectRoot `
        -PathType Container
)) {
    throw "The developer-service project is missing: $projectRoot"
}

Set-Location -LiteralPath $projectRoot

npm.cmd ci

if ($LASTEXITCODE -ne 0) {
    throw "npm ci failed."
}

npm.cmd run check

$qualityGatePassed = $LASTEXITCODE -eq 0

$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$compressedChecks = @(
    [PSCustomObject]@{
        Check = "Node.js is available"
        Passed = $null -ne (
            Get-Command node -ErrorAction SilentlyContinue
        )
    }

    [PSCustomObject]@{
        Check = "npm.cmd is available"
        Passed = $null -ne (
            Get-Command npm.cmd -ErrorAction SilentlyContinue
        )
    }

    [PSCustomObject]@{
        Check = "Project directory exists"
        Passed = Test-Path `
            -LiteralPath $projectRoot `
            -PathType Container
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
        Check = "Express is declared"
        Passed = $null -ne $packageData.dependencies.express
    }

    [PSCustomObject]@{
        Check = "dotenv is declared"
        Passed = $null -ne $packageData.dependencies.dotenv
    }

    [PSCustomObject]@{
        Check = "ESLint is declared"
        Passed = $null -ne $packageData.devDependencies.eslint
    }

    [PSCustomObject]@{
        Check = "Local .env exists"
        Passed = Test-Path `
            -LiteralPath .\.env `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Safe .env.example exists"
        Passed = Test-Path `
            -LiteralPath .\.env.example `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Configuration module exists"
        Passed = Test-Path `
            -LiteralPath .\src\config.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Generated entry point exists"
        Passed = Test-Path `
            -LiteralPath .\dist\index.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Quality gate passed"
        Passed = $qualityGatePassed
    }

    [PSCustomObject]@{
        Check = "No APP_SECRET remains in session"
        Passed = -not (
            Test-Path Env:APP_SECRET
        )
    }
)

$compressedChecks |
    Format-Table Check, Passed -AutoSize
```

Run the production process check:

```powershell
$productionResult = & .\scripts\Test-ProductionService.ps1 `
    -Port 43132

$productionCheck = [PSCustomObject]@{
    Check = "Production service became healthy"
    Passed = (
        $productionResult.Passed -eq $true -and
        $productionResult.Environment -eq "production" -and
        $productionResult.Status -eq "ok"
    )
}

$productionCheck |
    Format-Table -AutoSize
```

### The Verification

Combine the results:

```powershell
$allCompressedChecks = @(
    $compressedChecks
    $productionCheck
)

$failedCompressedChecks = @(
    $allCompressedChecks |
        Where-Object {
            -not $_.Passed
        }
)

if ($failedCompressedChecks.Count -eq 0) {
    Write-Host (
        "Part 5 verification passed. " +
        "The complete PowerShell and Node.js workflow is operational."
    ) -ForegroundColor Green
}
else {
    Write-Host "Part 5 verification failed." -ForegroundColor Red

    $failedCompressedChecks |
        Format-Table Check, Passed -AutoSize

    throw "Repair the failed checks before continuing."
}
```

Expected message:

```text
Part 5 verification passed. The complete PowerShell and Node.js workflow is operational.
```

---

# Part 5 Key Takeaways

The complete series can be reduced to five core abilities.

## 1. Navigate and inspect

```powershell
Get-Location
Set-Location
Get-ChildItem
Get-Item
Test-Path
```

## 2. Manage filesystem resources

```powershell
New-Item
Set-Content
Copy-Item
Move-Item
Rename-Item
Remove-Item
```

For destructive work:

```powershell
Remove-Item -WhatIf
```

## 3. Operate the Node.js project

```powershell
npm.cmd ci
npm.cmd run check
npm.cmd run dev
npm.cmd start
```

## 4. Configure the runtime safely

```text
PowerShell environment variables
        ↓
.env fallback
        ↓
validation and type conversion
        ↓
immutable application configuration
```

Never expose or commit:

```text
.env
APP_SECRET
```

## 5. Automate repeated work

```powershell
devservice
Show-DeveloperServiceConfig
Invoke-DeveloperServiceCheck
Start-DeveloperService
```

The shortest reliable daily workflow is:

```powershell
devservice
npm.cmd ci
npm.cmd run check
npm.cmd run dev
```

The shortened production-style verification workflow is:

```powershell
devservice
npm.cmd ci
npm.cmd run check
& .\scripts\Test-ProductionService.ps1
```
