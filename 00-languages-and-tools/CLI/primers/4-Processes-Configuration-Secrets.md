# Primer 4: Processes, Environment Variables, Configuration, and Secrets

Applications need values that can change without rewriting source code.

A developer’s computer might use:

```text
HOST=127.0.0.1
PORT=3000
NODE_ENV=development
```

A production environment might use:

```text
HOST=0.0.0.0
PORT=8080
NODE_ENV=production
```

Some values are ordinary configuration:

```text
PORT=3000
LOG_LEVEL=debug
```

Other values are secrets:

```text
DATABASE_PASSWORD=...
API_TOKEN=...
APP_SECRET=...
```

These categories overlap in how applications receive them, but they must not be treated identically. A port may be safe to print in logs. A password is not.

This primer establishes the mental model required by Part 4:

```text
Persistent Windows environment
              │
              ▼
       PowerShell process
              │
              ▼
         Node.js process
              │
              ├── existing environment values
              │
              └── local .env fallback
                          │
                          ▼
                  validation boundary
                          │
                          ▼
                application configuration
```

You will learn:

- What a process is
- How parent and child processes inherit environment variables
- Why child processes cannot normally modify their parent’s environment
- How PowerShell exposes environment variables
- Process, user, and machine scopes
- Why environment variables are strings
- Configuration versus secrets
- How `.env` files work
- Configuration precedence
- Why `.env` is not a secret vault
- How to validate and convert runtime configuration
- How to prevent secrets from appearing in logs
- How to create public configuration projections
- How to test configuration without contaminating global process state
- Why PowerShell profiles should not contain project secrets

---

# Primer Architecture

You will build this disposable laboratory:

```text
$HOME/
└── environment-config-primer/
    ├── scripts/
    │   ├── inspect-environment.js
    │   └── show-config.js
    ├── src/
    │   └── config.js
    ├── test/
    │   └── config.test.js
    ├── .env
    ├── .env.example
    ├── .gitignore
    ├── package-lock.json
    └── package.json
```

The final configuration flow will be:

```text
PowerShell process variables
           │
           │ take precedence
           ▼
       process.env
           ▲
           │ supplies missing values
           │
          .env
           │
           ▼
 validation and conversion
           │
           ▼
{
  environment: "development",
  host: "127.0.0.1",
  port: 3000,
  appSecret: "[private]"
}
```

---

# P4.1 Understand Processes and Inheritance

## The Target

Understand the relationship between PowerShell and a Node.js process started from it.

## The Concept

A **process** is a running instance of a program.

When you open PowerShell, Windows creates a PowerShell process. When that shell runs:

```powershell
node .\script.js
```

PowerShell creates a child Node.js process.

The relationship is:

```text
Windows Terminal or Explorer
              │
              ▼
       PowerShell process
              │
              ▼
         Node.js process
```

The child receives a copy of its parent’s current environment.

The word **copy** matters:

- A parent can prepare variables for a future child.
- A child can change its own environment.
- A child cannot normally rewrite its parent’s environment.
- Changes in one unrelated terminal do not automatically appear in another.

Think of a parent process handing a child a photocopy of an instruction sheet. The child can write on its copy, but the original sheet does not change.

## The Implementation

Inspect the current PowerShell process:

```powershell
[PSCustomObject]@{
    ProcessId = $PID
    ProcessName = (
        Get-Process -Id $PID
    ).ProcessName
    PowerShellVersion = $PSVersionTable.PSVersion.ToString()
}
```

Start Node.js and inspect its process:

```powershell
node -e '
console.log({
  processId: process.pid,
  parentProcessId: process.ppid,
  executable: process.execPath,
  platform: process.platform,
});
'
```

Compare PowerShell’s process ID with Node.js’s reported parent process ID:

```powershell
$nodeParentProcessId = node -e '
process.stdout.write(String(process.ppid));
'

[PSCustomObject]@{
    PowerShellProcessId = $PID
    NodeParentProcessId = [int] $nodeParentProcessId
    ParentMatches = $PID -eq [int] $nodeParentProcessId
}
```

Depending on terminal wrappers or command shims, the immediate process relationship can occasionally include another intermediary process. The important principle remains that child processes inherit their startup environment from the process that launches them.

## The Verification

Confirm that Node.js runs in a separate process:

```powershell
$nodeProcessId = node -e '
process.stdout.write(String(process.pid));
'

[PSCustomObject]@{
    PowerShellProcessId = $PID
    NodeProcessId = [int] $nodeProcessId
    DifferentProcesses = $PID -ne [int] $nodeProcessId
}
```

`DifferentProcesses` should be `True`.

---

# P4.2 Inspect PowerShell’s Environment Provider

## The Target

Read environment variables through PowerShell’s `Env:` provider and `$env:` syntax.

## The Concept

PowerShell presents environment variables as a drive named:

```text
Env:
```

This is not a physical disk. It is a PowerShell provider—a component that exposes a data store using familiar item and path commands.

You can therefore use:

```powershell
Get-ChildItem Env:
Get-Item Env:PATH
Test-Path Env:PATH
```

PowerShell also offers variable syntax:

```powershell
$env:PATH
```

Both interfaces read the current process environment.

## The Implementation

Inspect the environment drive:

```powershell
Get-PSDrive -Name Env
```

List environment variables:

```powershell
Get-ChildItem Env: |
    Sort-Object Name |
    Select-Object Name, Value
```

Read `PATH` through the provider:

```powershell
Get-Item Env:PATH
```

Read it through variable syntax:

```powershell
$env:PATH
```

Display one Windows `PATH` entry per line:

```powershell
$env:PATH -split ";" |
    Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    }
```

Check whether a variable exists:

```powershell
Test-Path Env:PATH
```

## The Verification

Compare the two access methods:

```powershell
$providerPath = (
    Get-Item Env:PATH
).Value

$variablePath = $env:PATH

[PSCustomObject]@{
    ProviderValueExists = -not [string]::IsNullOrWhiteSpace(
        $providerPath
    )
    VariableValueExists = -not [string]::IsNullOrWhiteSpace(
        $variablePath
    )
    ValuesMatch = $providerPath -eq $variablePath
}
```

Every value should be `True`.

---

# P4.3 Set and Remove Process-Scoped Variables

## The Target

Create temporary variables in the current PowerShell process and pass them to Node.js.

## The Concept

A process-scoped environment variable lasts only as long as the current process.

It is useful for:

- One development session
- One test run
- One child process
- Temporary overrides

It disappears when the PowerShell process closes.

## The Implementation

Set temporary values:

```powershell
$env:PRIMER_ENVIRONMENT = "development"
$env:PRIMER_PORT = "3100"
```

Read them:

```powershell
[PSCustomObject]@{
    Environment = $env:PRIMER_ENVIRONMENT
    Port = $env:PRIMER_PORT
}
```

Inspect them through the provider:

```powershell
Get-Item Env:PRIMER_ENVIRONMENT
Get-Item Env:PRIMER_PORT
```

Start a child process:

```powershell
node -e '
console.log({
  environment: process.env.PRIMER_ENVIRONMENT,
  port: process.env.PRIMER_PORT,
});
'
```

Remove them:

```powershell
Remove-Item `
    Env:PRIMER_ENVIRONMENT,
    Env:PRIMER_PORT `
    -ErrorAction SilentlyContinue
```

An equivalent removal syntax is:

```powershell
$env:PRIMER_ENVIRONMENT = $null
$env:PRIMER_PORT = $null
```

## The Verification

Confirm they are absent from PowerShell:

```powershell
[PSCustomObject]@{
    EnvironmentRemoved = -not (
        Test-Path Env:PRIMER_ENVIRONMENT
    )
    PortRemoved = -not (
        Test-Path Env:PRIMER_PORT
    )
}
```

Confirm a new child does not receive them:

```powershell
node -e '
const checks = {
  environmentAbsent:
    process.env.PRIMER_ENVIRONMENT === undefined,
  portAbsent:
    process.env.PRIMER_PORT === undefined,
};

if (!Object.values(checks).every(Boolean)) {
  throw new Error(JSON.stringify(checks));
}

console.log("Temporary variables were removed.");
'
```

---

# P4.4 Prove That Children Cannot Modify Their Parent

## The Target

Demonstrate that a Node.js child process cannot normally change the environment of the PowerShell process that launched it.

## The Concept

Environment inheritance travels from parent to newly created child:

```text
parent state at launch
          │
          ▼
       child copy
```

It does not travel automatically in reverse.

If Node.js runs:

```javascript
process.env.CHILD_ONLY = "set-by-node";
```

that change belongs to the Node.js process and disappears when it exits.

## The Implementation

Ensure the variable is absent in PowerShell:

```powershell
Remove-Item Env:CHILD_ONLY -ErrorAction SilentlyContinue
```

Run Node.js:

```powershell
node -e '
process.env.CHILD_ONLY = "set-by-node";

console.log({
  childValue: process.env.CHILD_ONLY,
});
'
```

Check the parent afterward:

```powershell
$env:CHILD_ONLY
```

No value should appear.

## The Verification

Run:

```powershell
[PSCustomObject]@{
    ParentVariableIsAbsent = -not (
        Test-Path Env:CHILD_ONLY
    )
}
```

Expected result:

```text
ParentVariableIsAbsent : True
```

A child can communicate with a parent through output, files, sockets, or other explicit mechanisms—but not by directly updating the parent’s process environment.

---

# P4.5 Understand Process, User, and Machine Scope

## The Target

Distinguish temporary process values from persistent Windows environment values.

## The Concept

Windows environment variables can be discussed at three common scopes:

| Scope | Availability |
|---|---|
| Process | Current process and future children |
| User | New processes for the current Windows user |
| Machine | New processes for users of the machine |

User- and machine-level values are stored persistently. Existing processes generally do not refresh automatically after those values change.

Machine-level changes often require administrator permission. Use the narrowest sufficient scope.

## The Implementation

Use a harmless demonstration name:

```powershell
$demoVariableName = "POWERSHELL_PRIMER_DEMO"
```

Read every scope:

```powershell
[PSCustomObject]@{
    Process = [System.Environment]::GetEnvironmentVariable(
        $demoVariableName,
        [System.EnvironmentVariableTarget]::Process
    )
    User = [System.Environment]::GetEnvironmentVariable(
        $demoVariableName,
        [System.EnvironmentVariableTarget]::User
    )
    Machine = [System.Environment]::GetEnvironmentVariable(
        $demoVariableName,
        [System.EnvironmentVariableTarget]::Machine
    )
}
```

Set a user-scoped value:

```powershell
[System.Environment]::SetEnvironmentVariable(
    $demoVariableName,
    "persistent-training-value",
    [System.EnvironmentVariableTarget]::User
)
```

Read it directly:

```powershell
$userScopedValue = [System.Environment]::GetEnvironmentVariable(
    $demoVariableName,
    [System.EnvironmentVariableTarget]::User
)

$userScopedValue
```

Inspect the current process:

```powershell
$env:POWERSHELL_PRIMER_DEMO
```

It may still be empty because the current PowerShell process began before the persistent value was created.

Copy it into the current process explicitly:

```powershell
$env:POWERSHELL_PRIMER_DEMO = $userScopedValue
```

Remove it from both scopes:

```powershell
[System.Environment]::SetEnvironmentVariable(
    $demoVariableName,
    $null,
    [System.EnvironmentVariableTarget]::User
)

Remove-Item `
    Env:POWERSHELL_PRIMER_DEMO `
    -ErrorAction SilentlyContinue
```

## The Verification

Confirm cleanup:

```powershell
$remainingUserValue = [System.Environment]::GetEnvironmentVariable(
    $demoVariableName,
    [System.EnvironmentVariableTarget]::User
)

[PSCustomObject]@{
    UserValueRemoved = $null -eq $remainingUserValue
    ProcessValueRemoved = -not (
        Test-Path Env:POWERSHELL_PRIMER_DEMO
    )
}
```

Both values should be `True`.

---

# P4.6 Distinguish Configuration from Secrets

## The Target

Classify runtime values according to their sensitivity.

## The Concept

**Configuration** controls application behavior.

Examples include:

```text
NODE_ENV
HOST
PORT
LOG_LEVEL
FEATURE_ENABLED
```

A **secret** is a value whose disclosure could allow unauthorized access, forgery, impersonation, or data exposure.

Examples include:

```text
PASSWORD
API_TOKEN
PRIVATE_KEY
DATABASE_URL containing credentials
APP_SECRET
```

All secrets are configuration inputs, but not all configuration inputs are secrets.

The distinction affects how values should be:

- Stored
- Logged
- Shared
- Rotated
- Audited
- Committed to version control

## The Implementation

Create a classification report:

```powershell
$configurationClassification = @(
    [PSCustomObject]@{
        Name = "NODE_ENV"
        Category = "Public configuration"
        SafeToLog = $true
    }

    [PSCustomObject]@{
        Name = "PORT"
        Category = "Public configuration"
        SafeToLog = $true
    }

    [PSCustomObject]@{
        Name = "LOG_LEVEL"
        Category = "Public configuration"
        SafeToLog = $true
    }

    [PSCustomObject]@{
        Name = "APP_SECRET"
        Category = "Secret"
        SafeToLog = $false
    }

    [PSCustomObject]@{
        Name = "DATABASE_PASSWORD"
        Category = "Secret"
        SafeToLog = $false
    }

    [PSCustomObject]@{
        Name = "API_TOKEN"
        Category = "Secret"
        SafeToLog = $false
    }
)

$configurationClassification |
    Format-Table -AutoSize
```

Use a redacted diagnostic pattern:

```powershell
$diagnosticConfiguration = [PSCustomObject]@{
    NODE_ENV = "development"
    HOST = "127.0.0.1"
    PORT = "3000"
    APP_SECRET = "[REDACTED]"
}

$diagnosticConfiguration |
    Format-List
```

## The Verification

Confirm that every secret is marked unsafe to log:

```powershell
$unsafeClassificationCount = @(
    $configurationClassification |
        Where-Object {
            $_.Category -eq "Secret" -and
            $_.SafeToLog -ne $false
        }
).Count

$unsafeClassificationCount -eq 0
```

Expected result:

```text
True
```

---

# P4.7 Create the Configuration Laboratory

## The Target

Initialize the disposable Node.js project used for the remaining exercises.

## The Concept

A dedicated project keeps configuration examples separate from real applications and secrets.

The project will use `dotenv` to load local `.env` values. `dotenv` is a package that parses a text file and adds missing values to a chosen environment object.

## The Implementation

Create the project:

```powershell
$primerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "environment-config-primer"

$expectedPrimerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "environment-config-primer"

if ($primerRoot -ne $expectedPrimerRoot) {
    throw "Unexpected primer path: $primerRoot"
}

if (Test-Path -LiteralPath $primerRoot) {
    Remove-Item `
        -LiteralPath $primerRoot `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

$null = New-Item `
    -Path $primerRoot `
    -ItemType Directory `
    -ErrorAction Stop

foreach ($directoryName in @(
    "scripts"
    "src"
    "test"
)) {
    $null = New-Item `
        -Path (Join-Path $primerRoot $directoryName) `
        -ItemType Directory `
        -ErrorAction Stop
}

Set-Location -LiteralPath $primerRoot
```

Initialize npm:

```powershell
npm.cmd init -y
```

Install `dotenv`:

```powershell
npm.cmd install dotenv
```

Replace the generated manifest.

### File: `environment-config-primer/package.json`

```powershell
$packageJsonContent = @'
{
  "name": "environment-config-primer",
  "version": "1.0.0",
  "description": "A process, environment-variable, configuration, and secret-handling primer.",
  "private": true,
  "main": "src/config.js",
  "type": "commonjs",
  "engines": {
    "node": ">=20"
  },
  "scripts": {
    "inspect": "node scripts/inspect-environment.js",
    "config": "node scripts/show-config.js",
    "test": "node --test",
    "check:syntax": "node --check src/config.js && node --check scripts/inspect-environment.js && node --check scripts/show-config.js && node --check test/config.test.js",
    "check": "npm run check:syntax && npm test"
  },
  "license": "MIT",
  "dependencies": {
    "dotenv": "^16.0.0"
  }
}
'@

Set-Content `
    -LiteralPath "$primerRoot\package.json" `
    -Value $packageJsonContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Let npm normalize the declared dependency and synchronize the lockfile:

```powershell
npm.cmd install
```

> npm may retain or update the exact compatible `dotenv` version. The lockfile records the selected result.

## The Verification

Run:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    ManifestExists = Test-Path `
        -LiteralPath .\package.json `
        -PathType Leaf
    LockfileExists = Test-Path `
        -LiteralPath .\package-lock.json `
        -PathType Leaf
    DotenvDeclared = $null -ne $packageData.dependencies.dotenv
    DotenvInstalled = Test-Path `
        -LiteralPath .\node_modules\dotenv `
        -PathType Container
}
```

Every value should be `True`.

---

# P4.8 Prove That Environment Variables Are Strings

## The Target

Observe how Node.js represents environment values.

## The Concept

Operating-system environment variables are string-based.

If PowerShell sets:

```powershell
$env:PRIMER_PORT = "3000"
```

Node.js receives:

```javascript
process.env.PRIMER_PORT === "3000"
```

It does not receive the number:

```javascript
3000
```

Similarly:

```text
"false"
```

is a nonempty string. It does not automatically become the Boolean value `false`.

This is a common source of configuration bugs.

## The Implementation

Set values:

```powershell
$env:PRIMER_PORT = "3000"
$env:PRIMER_ENABLED = "false"
```

Inspect them in Node.js:

```powershell
try {
    node -e '
const rawPort = process.env.PRIMER_PORT;
const rawEnabled = process.env.PRIMER_ENABLED;

console.log({
  rawPort,
  rawPortType: typeof rawPort,
  rawEnabled,
  rawEnabledType: typeof rawEnabled,
  booleanConversion: Boolean(rawEnabled),
});
'
}
finally {
    Remove-Item Env:PRIMER_PORT -ErrorAction SilentlyContinue
    Remove-Item Env:PRIMER_ENABLED -ErrorAction SilentlyContinue
}
```

The surprising result is:

```text
Boolean("false") === true
```

because every nonempty string is truthy.

Explicit Boolean parsing should instead compare known values:

```javascript
const enabled = rawEnabled === "true";
```

## The Verification

Run:

```powershell
$env:PRIMER_ENABLED = "false"

try {
    node -e '
const rawValue = process.env.PRIMER_ENABLED;
const parsedValue = rawValue === "true";

if (typeof rawValue !== "string") {
  throw new Error("Environment value was not a string.");
}

if (parsedValue !== false) {
  throw new Error("Boolean parsing failed.");
}

console.log("Environment string verification passed.");
'
}
finally {
    Remove-Item Env:PRIMER_ENABLED -ErrorAction SilentlyContinue
}
```

---

# P4.9 Create `.env.example` and `.gitignore`

## The Target

Create a safe configuration template and Git exclusion rules.

## The Concept

`.env.example` documents required variables without containing live credentials.

`.env` contains local values and must ordinarily remain untracked.

Use this relationship:

```text
.env.example → safe template committed to Git
.env         → local values excluded from Git
```

The template may contain obvious placeholders, but the application should reject those placeholders if someone tries to run with them unchanged.

## The Implementation

Create the template.

### File: `environment-config-primer/.env.example`

```powershell
$envExampleContent = @'
# Allowed values: development, test, production
NODE_ENV=development

# Server bind address
HOST=127.0.0.1

# Integer from 1 through 65535
PORT=3000

# Replace locally. Do not commit a real value.
APP_SECRET=replace-with-a-unique-secret
'@

Set-Content `
    -LiteralPath "$primerRoot\.env.example" `
    -Value $envExampleContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Create `.gitignore`.

### File: `environment-config-primer/.gitignore`

```powershell
$gitIgnoreContent = @'
node_modules/

.env
.env.*
!.env.example

*.log
coverage/
'@

Set-Content `
    -LiteralPath "$primerRoot\.gitignore" `
    -Value $gitIgnoreContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

## The Verification

Confirm the required template names:

```powershell
$exampleText = Get-Content `
    -LiteralPath .\.env.example `
    -Raw

$requiredNames = @(
    "NODE_ENV"
    "HOST"
    "PORT"
    "APP_SECRET"
)

$templateChecks = foreach ($name in $requiredNames) {
    [PSCustomObject]@{
        Name = $name
        Documented = $exampleText -match (
            "(?m)^" +
            [regex]::Escape($name) +
            "="
        )
    }
}

$templateChecks |
    Format-Table -AutoSize
```

Every `Documented` value should be `True`.

---

# P4.10 Create a Random Local Secret

## The Target

Create `.env` with local development configuration and a generated secret.

## The Concept

A secret should be:

- Difficult to guess
- Generated using a cryptographically secure random source
- Different between environments
- Rotatable
- Excluded from source control

A secret is not made secure merely because its filename begins with a dot.

The `.env` file remains plaintext on disk.

## The Implementation

Generate 32 random bytes:

```powershell
$secretBytes = New-Object byte[] 32

[System.Security.Cryptography.RandomNumberGenerator]::Fill(
    $secretBytes
)
```

Convert them to hexadecimal:

```powershell
$developmentSecret = (
    $secretBytes |
        ForEach-Object {
            $_.ToString("x2")
        }
) -join ""
```

Create `.env`:

```powershell
$envContent = @"
NODE_ENV=development
HOST=127.0.0.1
PORT=3000
APP_SECRET=$developmentSecret
"@

Set-Content `
    -LiteralPath "$primerRoot\.env" `
    -Value $envContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Clear the PowerShell variables:

```powershell
$developmentSecret = $null
$secretBytes = $null
$envContent = $null
```

This reduces accidental later display, although it does not guarantee immediate erasure of every memory copy.

## The Verification

Display names only:

```powershell
$envNames = Get-Content `
    -LiteralPath .\.env |
    Where-Object {
        $_ -match "^[A-Za-z_][A-Za-z0-9_]*="
    } |
    ForEach-Object {
        ($_ -split "=", 2)[0]
    }

$envNames
```

Confirm all expected names:

```powershell
[PSCustomObject]@{
    EnvFileExists = Test-Path `
        -LiteralPath .\.env `
        -PathType Leaf
    HasNodeEnvironment = "NODE_ENV" -in $envNames
    HasHost = "HOST" -in $envNames
    HasPort = "PORT" -in $envNames
    HasAppSecret = "APP_SECRET" -in $envNames
}
```

Every value should be `True`.

Do not display the full `.env` file in shared logs, screenshots, or support messages.

---

# P4.11 Understand `.env` Loading and Precedence

## The Target

Understand how `dotenv` combines a local file with an existing environment.

## The Concept

A deployment environment must be able to override local defaults.

The desired precedence is:

```text
existing process environment
             │
             ├── value exists → keep it
             │
             └── value absent → load from .env
```

With `dotenv`, this behavior is selected by:

```javascript
override: false
```

The `.env` file is a fallback, not the highest authority.

## The Implementation

Create an inspection script.

### File: `environment-config-primer/scripts/inspect-environment.js`

```powershell
$inspectionScriptContent = @'
"use strict";

const path = require("node:path");
const dotenv = require("dotenv");

const envFile = path.resolve(__dirname, "..", ".env");

const result = dotenv.config({
  path: envFile,
  override: false,
  quiet: true,
});

if (result.error) {
  console.error("Unable to load .env:", result.error.message);
  process.exitCode = 1;
} else {
  console.log({
    environment: process.env.NODE_ENV,
    host: process.env.HOST,
    port: process.env.PORT,
    portType: typeof process.env.PORT,
    secretLoaded: typeof process.env.APP_SECRET === "string",
    secretLength: process.env.APP_SECRET?.length ?? 0,
  });
}
'@

Set-Content `
    -LiteralPath "$primerRoot\scripts\inspect-environment.js" `
    -Value $inspectionScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Run with `.env` fallback:

```powershell
npm.cmd run inspect
```

Override the port:

```powershell
$env:PORT = "3200"

try {
    npm.cmd run inspect
}
finally {
    Remove-Item Env:PORT -ErrorAction SilentlyContinue
}
```

The second run should report port `3200`, not the `.env` value `3000`.

## The Verification

Capture the resolved port without printing the secret:

```powershell
$env:PORT = "3201"

try {
    $resolvedPort = node -e '
const path = require("node:path");
const dotenv = require("dotenv");

dotenv.config({
  path: path.resolve(".env"),
  override: false,
  quiet: true,
});

process.stdout.write(process.env.PORT);
'
}
finally {
    Remove-Item Env:PORT -ErrorAction SilentlyContinue
}

[PSCustomObject]@{
    OverrideWon = $resolvedPort -eq "3201"
    PortWasStillAString = $resolvedPort -is [string]
}
```

Both values should be `True`.

---

# P4.12 Build a Validation Boundary

## The Target

Create a complete configuration module that validates and converts raw environment values.

## The Concept

`process.env` is untrusted external input.

Even if you control `.env`, a deployment platform or shell can supply:

- Missing values
- Empty strings
- Invalid numbers
- Unsupported environment names
- Placeholder secrets

The validation boundary converts raw strings into application-ready values:

```text
raw input                validated output

"3000"            →      3000
"development"     →      "development"
missing secret    →      startup error
"not-a-port"      →      startup error
```

Failing at startup is safer than running with uncertain configuration.

## The Implementation

Create the module.

### File: `environment-config-primer/src/config.js`

```powershell
$configModuleContent = @'
"use strict";

const path = require("node:path");
const dotenv = require("dotenv");

const ALLOWED_ENVIRONMENTS = new Set([
  "development",
  "test",
  "production",
]);

function requireString(environment, name) {
  const rawValue = environment[name];

  if (
    typeof rawValue !== "string" ||
    rawValue.trim().length === 0
  ) {
    throw new Error(
      `${name} is required and cannot be empty.`,
    );
  }

  return rawValue.trim();
}

function parseEnvironment(environment) {
  const value = requireString(
    environment,
    "NODE_ENV",
  ).toLowerCase();

  if (!ALLOWED_ENVIRONMENTS.has(value)) {
    throw new Error(
      "NODE_ENV must be development, test, or production.",
    );
  }

  return value;
}

function parseHost(environment) {
  const value = requireString(environment, "HOST");

  if (value.length > 253) {
    throw new Error("HOST cannot exceed 253 characters.");
  }

  if (/\s/.test(value)) {
    throw new Error("HOST cannot contain whitespace.");
  }

  return value;
}

function parsePort(environment) {
  const rawValue = requireString(environment, "PORT");

  if (!/^\d+$/.test(rawValue)) {
    throw new Error("PORT must contain only decimal digits.");
  }

  const value = Number(rawValue);

  if (
    !Number.isSafeInteger(value) ||
    value < 1 ||
    value > 65_535
  ) {
    throw new Error(
      "PORT must be an integer from 1 through 65535.",
    );
  }

  return value;
}

function parseSecret(environment, environmentName) {
  const value = requireString(environment, "APP_SECRET");
  const minimumLength =
    environmentName === "production" ? 32 : 16;

  if (value.length < minimumLength) {
    throw new Error(
      `APP_SECRET must contain at least ${minimumLength} ` +
        `characters in ${environmentName}.`,
    );
  }

  const placeholders = new Set([
    "change-me",
    "replace-me",
    "replace-with-a-unique-secret",
    "password",
    "secret",
  ]);

  if (placeholders.has(value.toLowerCase())) {
    throw new Error(
      "APP_SECRET cannot use a documented placeholder.",
    );
  }

  return value;
}

function parseConfiguration(environment) {
  const environmentName = parseEnvironment(environment);
  const host = parseHost(environment);
  const port = parsePort(environment);
  const appSecret = parseSecret(
    environment,
    environmentName,
  );

  return Object.freeze({
    environment: environmentName,
    host,
    port,
    appSecret,
    isProduction: environmentName === "production",
  });
}

function loadConfiguration(options = {}) {
  const environment = options.environment ?? process.env;
  const envFile =
    options.envFile ??
    path.resolve(__dirname, "..", ".env");

  const result = dotenv.config({
    path: envFile,
    override: false,
    processEnv: environment,
    quiet: true,
  });

  if (
    result.error &&
    result.error.code !== "ENOENT"
  ) {
    throw new Error(
      `Unable to load ${envFile}: ${result.error.message}`,
    );
  }

  return parseConfiguration(environment);
}

function publicConfiguration(configuration) {
  return Object.freeze({
    environment: configuration.environment,
    host: configuration.host,
    port: configuration.port,
    isProduction: configuration.isProduction,
  });
}

module.exports = {
  loadConfiguration,
  parseConfiguration,
  publicConfiguration,
};
'@

Set-Content `
    -LiteralPath "$primerRoot\src\config.js" `
    -Value $configModuleContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

## The Verification

Check syntax:

```powershell
node --check .\src\config.js
```

Load local configuration safely:

```powershell
node -e '
const {
  loadConfiguration,
  publicConfiguration,
} = require("./src/config");

const configuration = loadConfiguration();

console.log(publicConfiguration(configuration));
console.log({
  portType: typeof configuration.port,
  secretLoaded: typeof configuration.appSecret === "string",
  secretLength: configuration.appSecret.length,
  frozen: Object.isFrozen(configuration),
});
'
```

Expected properties include:

```text
environment : development
host        : 127.0.0.1
port        : 3000
portType    : number
secretLoaded: true
frozen      : true
```

The secret value itself should not appear.

---

# P4.13 Create a Public Configuration Projection

## The Target

Expose operational configuration without exposing secrets.

## The Concept

A common mistake is to log the complete configuration object:

```javascript
console.log(configuration);
```

If that object includes `appSecret`, the secret enters logs.

Redaction is useful, but omission is safer. A **public projection** constructs a new object containing only approved fields:

```javascript
{
  environment,
  host,
  port,
  isProduction
}
```

This follows an allowlist approach:

> Include only fields explicitly approved for disclosure.

## The Implementation

Create the display script.

### File: `environment-config-primer/scripts/show-config.js`

```powershell
$showConfigContent = @'
"use strict";

const {
  loadConfiguration,
  publicConfiguration,
} = require("../src/config");

function main() {
  const configuration = loadConfiguration();
  const publicConfig = publicConfiguration(configuration);

  console.log(JSON.stringify(publicConfig, null, 2));
}

try {
  main();
} catch (error) {
  console.error("Configuration error:", error.message);
  process.exitCode = 1;
}
'@

Set-Content `
    -LiteralPath "$primerRoot\scripts\show-config.js" `
    -Value $showConfigContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Run:

```powershell
npm.cmd run config
```

Expected output resembles:

```json
{
  "environment": "development",
  "host": "127.0.0.1",
  "port": 3000,
  "isProduction": false
}
```

## The Verification

Capture and inspect the output:

```powershell
$configOutput = npm.cmd run config --silent
$configText = $configOutput -join "`n"

$containsSecretField = (
    $configText -match "(?i)APP_SECRET|appSecret"
)

[PSCustomObject]@{
    OutputExists = -not [string]::IsNullOrWhiteSpace(
        $configText
    )
    SecretFieldIsAbsent = -not $containsSecretField
    ContainsEnvironment = $configText -match '"environment"'
    ContainsPort = $configText -match '"port"'
}
```

Every value should be `True`.

---

# P4.14 Test Configuration Without Mutating `process.env`

## The Target

Create isolated tests that pass plain environment objects into the parser.

## The Concept

Tests should not depend on the developer’s current shell environment.

Risky test pattern:

```javascript
process.env.PORT = "invalid";
```

That global mutation can leak into another test.

Safer pattern:

```javascript
parseConfiguration({
  NODE_ENV: "test",
  HOST: "127.0.0.1",
  PORT: "3000",
  APP_SECRET: "long-enough-test-secret",
});
```

Each test receives its own object.

## The Implementation

Create the test suite.

### File: `environment-config-primer/test/config.test.js`

```powershell
$configTestContent = @'
"use strict";

const assert = require("node:assert/strict");
const { test } = require("node:test");
const {
  parseConfiguration,
  publicConfiguration,
} = require("../src/config");

function validEnvironment(overrides = {}) {
  return {
    NODE_ENV: "development",
    HOST: "127.0.0.1",
    PORT: "3000",
    APP_SECRET: "development-secret-value",
    ...overrides,
  };
}

test("valid values are converted and frozen", () => {
  const configuration = parseConfiguration(
    validEnvironment(),
  );

  assert.equal(configuration.environment, "development");
  assert.equal(configuration.host, "127.0.0.1");
  assert.equal(configuration.port, 3000);
  assert.equal(typeof configuration.port, "number");
  assert.equal(configuration.isProduction, false);
  assert.equal(Object.isFrozen(configuration), true);
});

test("production mode is identified", () => {
  const configuration = parseConfiguration(
    validEnvironment({
      NODE_ENV: "production",
      APP_SECRET:
        "a-production-secret-that-is-long-enough",
    }),
  );

  assert.equal(configuration.isProduction, true);
});

test("unsupported NODE_ENV is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        NODE_ENV: "preview",
      }),
    ),
    /NODE_ENV must be/,
  );
});

test("nonnumeric PORT is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        PORT: "three-thousand",
      }),
    ),
    /decimal digits/,
  );
});

test("out-of-range PORT is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        PORT: "70000",
      }),
    ),
    /1 through 65535/,
  );
});

test("missing APP_SECRET is rejected", () => {
  const environment = validEnvironment();
  delete environment.APP_SECRET;

  assert.throws(
    () => parseConfiguration(environment),
    /APP_SECRET is required/,
  );
});

test("short production secret is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        NODE_ENV: "production",
        APP_SECRET: "too-short-for-production",
      }),
    ),
    /at least 32/,
  );
});

test("placeholder secret is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        APP_SECRET: "replace-with-a-unique-secret",
      }),
    ),
    /placeholder/,
  );
});

test("public configuration omits the secret", () => {
  const configuration = parseConfiguration(
    validEnvironment(),
  );

  const publicConfig = publicConfiguration(
    configuration,
  );

  assert.deepEqual(publicConfig, {
    environment: "development",
    host: "127.0.0.1",
    port: 3000,
    isProduction: false,
  });

  assert.equal(
    Object.hasOwn(publicConfig, "appSecret"),
    false,
  );
});
'@

Set-Content `
    -LiteralPath "$primerRoot\test\config.test.js" `
    -Value $configTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

## The Verification

Run:

```powershell
npm.cmd run check
```

Expected summary includes:

```text
tests 9
pass 9
fail 0
```

Confirm success:

```powershell
if ($LASTEXITCODE -ne 0) {
    throw "Configuration checks failed."
}

Write-Host "Configuration tests passed." `
    -ForegroundColor Green
```

---

# P4.15 Prove Fail-Fast Behavior

## The Target

Show that invalid runtime values produce an immediate nonzero result.

## The Concept

**Fail-fast** means rejecting invalid configuration at startup rather than silently substituting an unexpected value.

Avoid code such as:

```javascript
const port = Number(process.env.PORT) || 3000;
```

If `PORT` is:

```text
not-a-number
```

that expression silently chooses `3000`, hiding a deployment error.

The safer approach is:

```text
invalid input → explicit startup failure
```

## The Implementation

Override the port with an invalid value:

```powershell
$env:PORT = "invalid"

try {
    npm.cmd run config
    $invalidPortExitCode = $LASTEXITCODE
}
finally {
    Remove-Item Env:PORT -ErrorAction SilentlyContinue
}
```

Expected output includes:

```text
Configuration error: PORT must contain only decimal digits.
```

Test an invalid environment name:

```powershell
$env:NODE_ENV = "preview"

try {
    npm.cmd run config
    $invalidEnvironmentExitCode = $LASTEXITCODE
}
finally {
    Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
}
```

## The Verification

Run:

```powershell
[PSCustomObject]@{
    InvalidPortFailed = $invalidPortExitCode -ne 0
    InvalidEnvironmentFailed = (
        $invalidEnvironmentExitCode -ne 0
    )
}
```

Both values should be `True`.

Confirm local valid configuration still works:

```powershell
npm.cmd run config

if ($LASTEXITCODE -ne 0) {
    throw "Valid local configuration unexpectedly failed."
}
```

---

# P4.16 Verify Git Secret Protection

## The Target

Confirm that `.env` is ignored and `.env.example` remains trackable.

## The Concept

`.gitignore` helps prevent an untracked local secret file from entering ordinary commits.

It does not protect a secret that has already been committed. If a secret reaches Git history, assume it is compromised and rotate it.

## The Implementation

If Git is available, initialize the disposable repository:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    if (-not (
        Test-Path `
            -LiteralPath .\.git `
            -PathType Container
    )) {
        git init
    }
}
```

Inspect the rule matching `.env`:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    git check-ignore -v .env
}
```

Check `.env.example`:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    git check-ignore .env.example
    $exampleIgnoreExitCode = $LASTEXITCODE
}
```

Exit code `1` means `.env.example` is not ignored.

## The Verification

Run:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    git check-ignore -q .env
    $envIsIgnored = $LASTEXITCODE -eq 0

    git check-ignore -q .env.example
    $exampleIsIgnored = $LASTEXITCODE -eq 0
}
else {
    $ignoreText = Get-Content `
        -LiteralPath .\.gitignore `
        -Raw

    $envIsIgnored = (
        $ignoreText -match "(?m)^\.env$"
    )

    $exampleIsIgnored = -not (
        $ignoreText -match "(?m)^!\.env\.example$"
    )
}

[PSCustomObject]@{
    EnvIsIgnored = $envIsIgnored
    ExampleIsTrackable = -not $exampleIsIgnored
}
```

Both values should be `True`.

---

# P4.17 Understand Why `.env` Is Not a Secret Vault

## The Target

Set realistic security expectations for local environment files.

## The Concept

A `.env` file is usually plaintext.

It protects against hardcoding and helps separate configuration from source, but it does not automatically provide:

- Encryption
- Access auditing
- Rotation
- Expiration
- Approval workflows
- Hardware-backed protection
- Protection from processes running as your user
- Protection from backups or accidental copies

It is best understood as:

> A convenient local configuration source that may contain sensitive data.

Production systems should prefer an approved secret-management service, such as:

- Azure Key Vault
- AWS Secrets Manager
- Google Cloud Secret Manager
- HashiCorp Vault
- A CI/CD platform’s protected secret store
- An organization-approved operating-system credential mechanism

## The Implementation

Inspect the `.env` file’s metadata without displaying its contents:

```powershell
Get-Item `
    -LiteralPath .\.env `
    -Force |
    Select-Object Name, FullName, Length, Attributes, LastWriteTime
```

Inspect Windows access-control information:

```powershell
Get-Acl `
    -LiteralPath .\.env |
    Format-List Owner, AccessToString
```

This shows filesystem permissions, not encryption or secret-manager capabilities.

Create a safe summary:

```powershell
$envMetadata = Get-Item `
    -LiteralPath .\.env `
    -Force

[PSCustomObject]@{
    Exists = $true
    Length = $envMetadata.Length
    IsPlainFile = -not $envMetadata.PSIsContainer
    ContentDisplayed = $false
}
```

## The Verification

Confirm that the secret file is treated as local configuration rather than source:

```powershell
[PSCustomObject]@{
    EnvExists = Test-Path `
        -LiteralPath .\.env `
        -PathType Leaf
    EnvIsIgnored = $envIsIgnored
    ExampleExists = Test-Path `
        -LiteralPath .\.env.example `
        -PathType Leaf
}
```

Every value should be `True`.

---

# P4.18 Keep Secrets Out of the PowerShell Profile

## The Target

Understand why project credentials do not belong in `$PROFILE`.

## The Concept

A PowerShell profile executes whenever its associated shell starts.

Storing this in the profile is dangerous:

```powershell
$env:APP_SECRET = "production-secret"
```

It can cause the secret to:

- Enter every child process
- Override unrelated projects
- Appear in diagnostic output
- Persist far longer than intended
- Be copied with profile backups
- Be synchronized through dotfile repositories

Profiles should contain general conveniences, such as navigation functions—not project secrets.

## The Implementation

Display the profile path:

```powershell
$profilePath = $PROFILE.CurrentUserCurrentHost
$profilePath
```

If the profile exists, inspect whether it mentions common secret names without printing matched values:

```powershell
if (
    Test-Path `
        -LiteralPath $profilePath `
        -PathType Leaf
) {
    $profileText = Get-Content `
        -LiteralPath $profilePath `
        -Raw

    $secretNamePatterns = @(
        "APP_SECRET"
        "DATABASE_PASSWORD"
        "API_TOKEN"
        "PRIVATE_KEY"
    )

    $profileSecretNameMatches = foreach (
        $pattern in $secretNamePatterns
    ) {
        [PSCustomObject]@{
            Name = $pattern
            Mentioned = $profileText -match (
                [regex]::Escape($pattern)
            )
        }
    }

    $profileSecretNameMatches |
        Format-Table -AutoSize
}
else {
    Write-Host "No current-user profile exists." `
        -ForegroundColor Yellow
}
```

If a real secret is found, do not print it. Remove the assignment, rotate the credential, and inspect profile backups or dotfile history.

## The Verification

For the primer project itself, confirm no secret assignment was added to the profile:

```powershell
if (
    Test-Path `
        -LiteralPath $profilePath `
        -PathType Leaf
) {
    $profileContainsPrimerSecret = (
        Get-Content `
            -LiteralPath $profilePath `
            -Raw
    ) -match "(?m)^\s*\`$env:APP_SECRET\s*="
}
else {
    $profileContainsPrimerSecret = $false
}

[PSCustomObject]@{
    ProfileDoesNotAssignAppSecret = -not (
        $profileContainsPrimerSecret
    )
}
```

Expected result:

```text
ProfileDoesNotAssignAppSecret : True
```

---

# P4.19 Pass Configuration to One Child Process Only

## The Target

Launch Node.js with isolated environment values without modifying the caller’s `$env:` state.

## The Concept

Setting:

```powershell
$env:PORT = "3200"
```

changes the current PowerShell process and every later child until the value is removed.

For reusable automation, it is often safer to create a child process with a dedicated environment map.

This gives one process a private instruction sheet without writing those instructions onto the shared terminal session.

## The Implementation

Create process-start information:

```powershell
$nodePath = (
    Get-Command node -ErrorAction Stop
).Source

$startInfo = [System.Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $nodePath
$startInfo.WorkingDirectory = $primerRoot
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.CreateNoWindow = $true
```

Add a JavaScript expression:

```powershell
$startInfo.ArgumentList.Add("-e")

$startInfo.ArgumentList.Add(@'
console.log(JSON.stringify({
  environment: process.env.NODE_ENV,
  host: process.env.HOST,
  port: process.env.PORT,
  secretPresent: typeof process.env.APP_SECRET === "string"
}));
'@)
```

Assign values only to the child’s environment:

```powershell
$startInfo.Environment["NODE_ENV"] = "test"
$startInfo.Environment["HOST"] = "127.0.0.1"
$startInfo.Environment["PORT"] = "3300"
$startInfo.Environment["APP_SECRET"] = (
    "isolated-child-secret-value"
)
```

Start and read the process:

```powershell
$child = [System.Diagnostics.Process]::new()
$child.StartInfo = $startInfo

try {
    if (-not $child.Start()) {
        throw "The child process did not start."
    }

    $standardOutput = $child.StandardOutput.ReadToEnd()
    $standardError = $child.StandardError.ReadToEnd()

    $child.WaitForExit()

    if ($child.ExitCode -ne 0) {
        throw "Child process failed: $standardError"
    }

    $childReport = $standardOutput |
        ConvertFrom-Json

    $childReport |
        Format-List
}
finally {
    $child.Dispose()
}
```

## The Verification

Confirm the child received its values and the parent did not:

```powershell
[PSCustomObject]@{
    ChildEnvironmentCorrect = (
        $childReport.environment -eq "test"
    )
    ChildPortCorrect = (
        $childReport.port -eq "3300"
    )
    ChildSecretWasPresent = (
        $childReport.secretPresent -eq $true
    )
    ParentNodeEnvironmentUnaffected = -not (
        Test-Path Env:NODE_ENV
    )
    ParentPortUnaffected = -not (
        Test-Path Env:PORT
    )
    ParentSecretUnaffected = -not (
        Test-Path Env:APP_SECRET
    )
}
```

Every value should be `True`, assuming those variables were absent before this exercise.

---

# Primer 4 Reference A: Environment Scope

## Process scope

Set:

```powershell
$env:EXAMPLE_NAME = "value"
```

Read:

```powershell
$env:EXAMPLE_NAME
```

Remove:

```powershell
Remove-Item Env:EXAMPLE_NAME
```

Lifetime:

```text
Current process and future child processes
```

## User scope

Set:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "value",
    [System.EnvironmentVariableTarget]::User
)
```

Read:

```powershell
[System.Environment]::GetEnvironmentVariable(
    "EXAMPLE_NAME",
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

Lifetime:

```text
Persistent; available to newly started processes for the user
```

## Machine scope

Set:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "value",
    [System.EnvironmentVariableTarget]::Machine
)
```

Machine scope often requires administrator permission and affects a broader audience. Do not use it when process or user scope is sufficient.

---

# Primer 4 Reference B: `.env` Syntax

## Basic values

```dotenv
NODE_ENV=development
HOST=127.0.0.1
PORT=3000
```

## Comments

```dotenv
# Local development port
PORT=3000
```

## Quoted values

```dotenv
MESSAGE="A value containing spaces"
```

## Empty values

```dotenv
APP_SECRET=
```

An empty value remains a value. Required configuration should reject it.

## Incorrect PowerShell syntax

Do not write this inside `.env`:

```text
$env:PORT = "3000"
```

Use:

```dotenv
PORT=3000
```

A `.env` file is a data file, not a PowerShell script.

---

# Primer 4 Reference C: Configuration Precedence

The primer uses:

```javascript
dotenv.config({
  override: false,
});
```

The resulting priority is:

```text
1. Existing child-process environment
2. .env value when the variable is absent
3. Validation failure if the required value remains absent
```

Example:

```dotenv
PORT=3000
```

Override for one PowerShell session:

```powershell
$env:PORT = "3200"
npm.cmd run config
```

Result:

```text
port = 3200
```

Remove the override:

```powershell
Remove-Item Env:PORT
npm.cmd run config
```

Result:

```text
port = 3000
```

---

# Primer 4 Reference D: Safe Configuration Design

A strong configuration module should:

- Treat external values as untrusted strings
- Require mandatory variables
- Trim surrounding whitespace where appropriate
- Reject empty values
- Convert numbers explicitly
- Validate numeric ranges
- Restrict enumerated values
- Reject known placeholders
- Apply stronger production requirements where needed
- Return immutable configuration
- Avoid logging secrets
- Fail before starting the application
- Permit direct environment injection when `.env` is absent

Example output:

```javascript
Object.freeze({
  environment: "production",
  host: "0.0.0.0",
  port: 8080,
  appSecret: "[private]",
  isProduction: true,
});
```

Do not replace validation with silent fallbacks:

```javascript
const port = Number(process.env.PORT) || 3000;
```

That pattern hides invalid input.

---

# Primer 4 Reference E: Secret Handling Rules

## Do

- Generate secrets securely
- Keep different values per environment
- Rotate compromised credentials
- Restrict access
- Use an approved production secret manager
- Exclude local secret files from Git
- Log only public configuration
- Test that public output omits secret fields

## Do not

- Hardcode secrets in source
- Put secrets in `.env.example`
- Put project secrets in `$PROFILE`
- Print all of `process.env`
- Paste secrets into issue trackers or chats
- Include secrets in command history unnecessarily
- Reuse production secrets in development
- Assume base64 encoding is encryption
- Assume a dot-prefixed filename is secure
- Assume deleting a secret from the latest Git commit removes it from history

## If a secret is exposed

1. Treat it as compromised.
2. Revoke or rotate it immediately.
3. Replace it in every active environment.
4. Remove it from current files.
5. Inspect logs, build artifacts, backups, and Git history.
6. Follow the organization’s incident-response procedure.

Removing the text is not enough. The credential itself must be replaced.

---

# Primer 4 Reference F: Redaction Versus Omission

## Redaction

```javascript
const diagnostic = {
  host: configuration.host,
  port: configuration.port,
  appSecret: "[REDACTED]",
};
```

Redaction is better than displaying the value, but the presence of the property can still reveal information about internal configuration.

## Omission

```javascript
const publicConfig = {
  host: configuration.host,
  port: configuration.port,
};
```

Omission is generally safer for public diagnostics.

## Allowlist approach

Construct a new object from explicitly approved fields:

```javascript
function publicConfiguration(configuration) {
  return {
    environment: configuration.environment,
    host: configuration.host,
    port: configuration.port,
  };
}
```

Avoid denylist approaches that copy everything and attempt to remove known secret names. A newly added secret property might be forgotten.

---

# Primer 4 Reference G: Common Configuration Mistakes

## Mistake 1: Treating environment values as typed

This is a string:

```javascript
process.env.PORT
```

Validate and convert it:

```javascript
const port = Number(process.env.PORT);
```

Then verify it is a safe integer in the valid range.

## Mistake 2: Converting `"false"` with `Boolean`

This produces `true`:

```javascript
Boolean("false")
```

Parse an explicit vocabulary:

```javascript
function parseBoolean(value) {
  if (value === "true") {
    return true;
  }

  if (value === "false") {
    return false;
  }

  throw new Error("Value must be true or false.");
}
```

## Mistake 3: Using a silent port fallback

Risky:

```javascript
const port = Number(process.env.PORT) || 3000;
```

Safer:

```javascript
if (!/^\d+$/.test(process.env.PORT)) {
  throw new Error("PORT must contain only digits.");
}
```

## Mistake 4: Logging the entire environment

Unsafe:

```javascript
console.log(process.env);
```

The environment may contain credentials unrelated to the current application.

## Mistake 5: Treating `.env` as encrypted storage

`.env` is normally plaintext.

## Mistake 6: Committing `.env`

Ignore:

```gitignore
.env
.env.*
!.env.example
```

## Mistake 7: Putting a real secret in `.env.example`

Templates belong in Git. Use placeholders only.

## Mistake 8: Setting production mode in `$PROFILE`

Avoid:

```powershell
$env:NODE_ENV = "production"
```

It can unexpectedly affect every Node.js child process launched from that shell.

## Mistake 9: Mutating `process.env` across tests

Pass explicit objects into parser functions instead.

## Mistake 10: Assuming an existing terminal receives persistent changes

Open a new terminal or copy the persistent value into the current process explicitly.

## Mistake 11: Using machine scope unnecessarily

Machine scope has broader impact and may require elevation.

## Mistake 12: Exposing a secret through error context

Avoid:

```javascript
throw new Error(`Invalid secret: ${secret}`);
```

Use:

```javascript
throw new Error("APP_SECRET is invalid.");
```

---

# P4.20 Run a Production-Style Configuration Check

## The Target

Validate production configuration using environment variables supplied to one isolated child process.

## The Concept

A production deployment should not need to edit `.env`.

The deployment environment supplies values directly:

```text
NODE_ENV=production
HOST=127.0.0.1
PORT=8080
APP_SECRET=<injected securely>
```

Because existing environment values take precedence over `.env`, the child process uses production values.

## The Implementation

Generate an ephemeral secret:

```powershell
$productionBytes = New-Object byte[] 32

[System.Security.Cryptography.RandomNumberGenerator]::Fill(
    $productionBytes
)

$temporaryProductionSecret = (
    $productionBytes |
        ForEach-Object {
            $_.ToString("x2")
        }
) -join ""
```

Prepare an isolated child:

```powershell
$nodePath = (
    Get-Command node -ErrorAction Stop
).Source

$startInfo = [System.Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $nodePath
$startInfo.WorkingDirectory = $primerRoot
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.CreateNoWindow = $true

$startInfo.ArgumentList.Add(
    "$primerRoot\scripts\show-config.js"
)

$startInfo.Environment["NODE_ENV"] = "production"
$startInfo.Environment["HOST"] = "127.0.0.1"
$startInfo.Environment["PORT"] = "8080"
$startInfo.Environment["APP_SECRET"] = (
    $temporaryProductionSecret
)
```

Execute:

```powershell
$productionProcess = [System.Diagnostics.Process]::new()
$productionProcess.StartInfo = $startInfo

try {
    if (-not $productionProcess.Start()) {
        throw "Production configuration process failed to start."
    }

    $productionOutput = (
        $productionProcess.StandardOutput.ReadToEnd()
    )

    $productionError = (
        $productionProcess.StandardError.ReadToEnd()
    )

    $productionProcess.WaitForExit()

    if ($productionProcess.ExitCode -ne 0) {
        throw (
            "Production validation failed: " +
            $productionError
        )
    }

    $productionPublicConfig = (
        $productionOutput |
            ConvertFrom-Json
    )
}
finally {
    $temporaryProductionSecret = $null
    $productionBytes = $null
    $productionProcess.Dispose()
}
```

Display only public configuration:

```powershell
$productionPublicConfig |
    Format-List
```

## The Verification

Run:

```powershell
[PSCustomObject]@{
    EnvironmentIsProduction = (
        $productionPublicConfig.environment -eq
        "production"
    )
    HostIsCorrect = (
        $productionPublicConfig.host -eq
        "127.0.0.1"
    )
    PortIsNumeric = (
        $productionPublicConfig.port -is [int]
    )
    PortIsCorrect = (
        $productionPublicConfig.port -eq 8080
    )
    ProductionFlagIsTrue = (
        $productionPublicConfig.isProduction -eq $true
    )
    SecretPropertyIsAbsent = -not (
        $productionPublicConfig.PSObject.Properties.Name -contains
        "appSecret"
    )
    ParentEnvironmentIsClean = -not (
        Test-Path Env:APP_SECRET
    )
}
```

Every value should be `True`.

---

# P4.21 Run the Complete Quality Check

## The Target

Verify syntax, tests, dependencies, and safe public output.

## The Concept

Configuration correctness includes several independent concerns:

```text
package installation
        ↓
syntax
        ↓
validation tests
        ↓
local .env loading
        ↓
public output safety
        ↓
production injection
```

## The Implementation

Return to the project:

```powershell
Set-Location -LiteralPath $primerRoot
```

Install from the lockfile:

```powershell
npm.cmd ci
```

Run the project check:

```powershell
npm.cmd run check
```

Capture the result:

```powershell
$qualityExitCode = $LASTEXITCODE
```

Display public configuration:

```powershell
$publicOutput = npm.cmd run config --silent
$publicText = $publicOutput -join "`n"
```

## The Verification

Run:

```powershell
$qualityChecks = [PSCustomObject]@{
    DependencyInstallSucceeded = (
        Test-Path `
            -LiteralPath .\node_modules\dotenv `
            -PathType Container
    )
    QualityCommandSucceeded = (
        $qualityExitCode -eq 0
    )
    PublicOutputExists = -not (
        [string]::IsNullOrWhiteSpace($publicText)
    )
    PublicOutputOmitsSecret = -not (
        $publicText -match "(?i)APP_SECRET|appSecret"
    )
    LocalSecretVariableNotInSession = -not (
        Test-Path Env:APP_SECRET
    )
}

$qualityChecks |
    Format-List
```

Find failures:

```powershell
$failedQualityChecks = @(
    $qualityChecks.PSObject.Properties |
        Where-Object {
            $_.Value -ne $true
        }
)

if ($failedQualityChecks.Count -eq 0) {
    Write-Host "Primer 4 quality check passed." `
        -ForegroundColor Green
}
else {
    $failedQualityChecks |
        Select-Object Name, Value |
        Format-Table -AutoSize

    throw "Primer 4 quality check failed."
}
```

---

# Primer 4 Readiness Challenge

## The Target

Complete a full configuration workflow that:

1. Confirms local files exist.
2. Confirms `.env` contains required names without printing values.
3. Verifies `.env` is ignored.
4. Runs syntax checks and tests.
5. Confirms `.env` fallback produces development configuration.
6. Confirms an isolated child environment overrides `.env`.
7. Confirms the production secret is never printed.
8. Confirms the parent PowerShell session remains clean.
9. Confirms invalid configuration fails.

## The Concept

The challenge verifies the entire boundary:

```text
persistent or injected values
           ↓
child-process environment
           ↓
dotenv fallback
           ↓
validation and conversion
           ↓
private configuration
           ↓
public projection
```

## The Implementation

Reconstruct the project path:

```powershell
$primerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "environment-config-primer"

Set-Location -LiteralPath $primerRoot
```

Confirm required files:

```powershell
$requiredFiles = @(
    ".\package.json"
    ".\package-lock.json"
    ".\.gitignore"
    ".\.env"
    ".\.env.example"
    ".\src\config.js"
    ".\scripts\inspect-environment.js"
    ".\scripts\show-config.js"
    ".\test\config.test.js"
)

$missingFiles = @(
    $requiredFiles |
        Where-Object {
            -not (
                Test-Path `
                    -LiteralPath $_ `
                    -PathType Leaf
            )
        }
)

if ($missingFiles.Count -gt 0) {
    throw "Missing files: $($missingFiles -join ', ')"
}
```

Inspect `.env` names only:

```powershell
$localVariableNames = @(
    Get-Content `
        -LiteralPath .\.env |
        Where-Object {
            $_ -match "^[A-Za-z_][A-Za-z0-9_]*="
        } |
        ForEach-Object {
            ($_ -split "=", 2)[0]
        }
)

$requiredVariableNames = @(
    "NODE_ENV"
    "HOST"
    "PORT"
    "APP_SECRET"
)

$missingVariableNames = @(
    $requiredVariableNames |
        Where-Object {
            $_ -notin $localVariableNames
        }
)

if ($missingVariableNames.Count -gt 0) {
    throw (
        "Missing .env variable names: " +
        ($missingVariableNames -join ", ")
    )
}
```

Verify ignore behavior:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    if (-not (Test-Path -LiteralPath .\.git)) {
        git init
    }

    git check-ignore -q .env
    $envIsIgnored = $LASTEXITCODE -eq 0

    git check-ignore -q .env.example
    $exampleIsTrackable = $LASTEXITCODE -ne 0
}
else {
    $ignoreText = Get-Content `
        -LiteralPath .\.gitignore `
        -Raw

    $envIsIgnored = (
        $ignoreText -match "(?m)^\.env$"
    )

    $exampleIsTrackable = (
        $ignoreText -match "(?m)^!\.env\.example$"
    )
}
```

Run dependency and quality checks:

```powershell
npm.cmd ci

if ($LASTEXITCODE -ne 0) {
    throw "npm ci failed."
}

npm.cmd run check

$qualityPassed = $LASTEXITCODE -eq 0
```

Capture development fallback configuration:

```powershell
$developmentOutput = npm.cmd run config --silent

if ($LASTEXITCODE -ne 0) {
    throw "Development configuration failed."
}

$developmentText = $developmentOutput -join "`n"
$developmentConfig = $developmentText |
    ConvertFrom-Json
```

Create an isolated production child:

```powershell
$secretBytes = New-Object byte[] 32

[System.Security.Cryptography.RandomNumberGenerator]::Fill(
    $secretBytes
)

$ephemeralSecret = (
    $secretBytes |
        ForEach-Object {
            $_.ToString("x2")
        }
) -join ""

$nodePath = (
    Get-Command node -ErrorAction Stop
).Source

$productionStartInfo = (
    [System.Diagnostics.ProcessStartInfo]::new()
)

$productionStartInfo.FileName = $nodePath
$productionStartInfo.WorkingDirectory = $primerRoot
$productionStartInfo.UseShellExecute = $false
$productionStartInfo.RedirectStandardOutput = $true
$productionStartInfo.RedirectStandardError = $true
$productionStartInfo.CreateNoWindow = $true

$productionStartInfo.ArgumentList.Add(
    "$primerRoot\scripts\show-config.js"
)

$productionStartInfo.Environment["NODE_ENV"] = "production"
$productionStartInfo.Environment["HOST"] = "127.0.0.1"
$productionStartInfo.Environment["PORT"] = "8080"
$productionStartInfo.Environment["APP_SECRET"] = $ephemeralSecret

$productionChild = [System.Diagnostics.Process]::new()
$productionChild.StartInfo = $productionStartInfo

try {
    if (-not $productionChild.Start()) {
        throw "The production child did not start."
    }

    $productionOutputText = (
        $productionChild.StandardOutput.ReadToEnd()
    )

    $productionErrorText = (
        $productionChild.StandardError.ReadToEnd()
    )

    $productionChild.WaitForExit()

    $productionExitCode = $productionChild.ExitCode

    if ($productionExitCode -eq 0) {
        $productionConfig = (
            $productionOutputText |
                ConvertFrom-Json
        )
    }
    else {
        $productionConfig = $null
    }
}
finally {
    $ephemeralSecret = $null
    $secretBytes = $null
    $productionChild.Dispose()
}
```

Create an isolated invalid child:

```powershell
$invalidStartInfo = (
    [System.Diagnostics.ProcessStartInfo]::new()
)

$invalidStartInfo.FileName = $nodePath
$invalidStartInfo.WorkingDirectory = $primerRoot
$invalidStartInfo.UseShellExecute = $false
$invalidStartInfo.RedirectStandardOutput = $true
$invalidStartInfo.RedirectStandardError = $true
$invalidStartInfo.CreateNoWindow = $true

$invalidStartInfo.ArgumentList.Add(
    "$primerRoot\scripts\show-config.js"
)

$invalidStartInfo.Environment["NODE_ENV"] = "development"
$invalidStartInfo.Environment["HOST"] = "127.0.0.1"
$invalidStartInfo.Environment["PORT"] = "not-a-port"
$invalidStartInfo.Environment["APP_SECRET"] = (
    "valid-development-secret"
)

$invalidChild = [System.Diagnostics.Process]::new()
$invalidChild.StartInfo = $invalidStartInfo

try {
    if (-not $invalidChild.Start()) {
        throw "The invalid child did not start."
    }

    $invalidStandardOutput = (
        $invalidChild.StandardOutput.ReadToEnd()
    )

    $invalidStandardError = (
        $invalidChild.StandardError.ReadToEnd()
    )

    $invalidChild.WaitForExit()

    $invalidExitCode = $invalidChild.ExitCode
}
finally {
    $invalidChild.Dispose()
}
```

Build the readiness result:

```powershell
$readinessResult = [PSCustomObject]@{
    RequiredFilesExist = $missingFiles.Count -eq 0
    RequiredVariableNamesExist = (
        $missingVariableNames.Count -eq 0
    )
    EnvIsIgnored = $envIsIgnored
    ExampleIsTrackable = $exampleIsTrackable
    QualityCheckPassed = $qualityPassed
    DevelopmentEnvironmentLoaded = (
        $developmentConfig.environment -eq
        "development"
    )
    DevelopmentPortWasConverted = (
        $developmentConfig.port -eq 3000
    )
    DevelopmentOutputOmittedSecret = -not (
        $developmentText -match
        "(?i)APP_SECRET|appSecret"
    )
    ProductionChildSucceeded = (
        $productionExitCode -eq 0
    )
    ProductionOverrideWon = (
        $null -ne $productionConfig -and
        $productionConfig.environment -eq "production" -and
        $productionConfig.port -eq 8080
    )
    ProductionOutputOmittedSecret = -not (
        $productionOutputText -match
        "(?i)APP_SECRET|appSecret"
    )
    InvalidPortWasRejected = (
        $invalidExitCode -ne 0
    )
    InvalidErrorDidNotExposeSecretName = -not (
        $invalidStandardError -match
        "(?i)APP_SECRET|appSecret"
    )
    ParentSessionHasNoAppSecret = -not (
        Test-Path Env:APP_SECRET
    )
}
```

Display it:

```powershell
$readinessResult |
    Format-List
```

## The Verification

Find failures:

```powershell
$failedReadinessChecks = @(
    $readinessResult.PSObject.Properties |
        Where-Object {
            $_.Value -ne $true
        }
)

if ($failedReadinessChecks.Count -eq 0) {
    Write-Host "Primer 4 readiness check passed." `
        -ForegroundColor Green
}
else {
    $failedReadinessChecks |
        Select-Object Name, Value |
        Format-Table -AutoSize

    throw "Primer 4 readiness check failed."
}
```

Expected message:

```text
Primer 4 readiness check passed.
```

---

# Primer 4 Optional Cleanup

## The Target

Remove the disposable configuration primer after review.

## The Concept

The project’s `.env` contains a generated local secret. Even though it is disposable, remove the laboratory deliberately using Primer 2’s safety workflow.

## The Implementation

Leave the project:

```powershell
Set-Location -LiteralPath $HOME
```

Reconstruct the exact target:

```powershell
$cleanupTarget = Join-Path `
    -Path $HOME `
    -ChildPath "environment-config-primer"

$expectedCleanupTarget = Join-Path `
    -Path $HOME `
    -ChildPath "environment-config-primer"

if ($cleanupTarget -ne $expectedCleanupTarget) {
    throw "Unexpected cleanup target: $cleanupTarget"
}
```

Resolve and inspect it:

```powershell
$resolvedCleanupTarget = (
    Resolve-Path `
        -LiteralPath $cleanupTarget `
        -ErrorAction Stop
).Path

Get-ChildItem `
    -LiteralPath $resolvedCleanupTarget `
    -Recurse `
    -Force |
    Select-Object FullName, Attributes
```

Preview:

```powershell
Remove-Item `
    -LiteralPath $resolvedCleanupTarget `
    -Recurse `
    -Force `
    -WhatIf
```

If you want to keep the laboratory, stop here.

Otherwise, remove it:

```powershell
Remove-Item `
    -LiteralPath $resolvedCleanupTarget `
    -Recurse `
    -Force `
    -Confirm
```

Enter `Y` only after checking the displayed target.

## The Verification

If removed:

```powershell
Test-Path -LiteralPath $resolvedCleanupTarget
```

Expected result:

```text
False
```

If retained:

```powershell
Test-Path `
    -LiteralPath $resolvedCleanupTarget `
    -PathType Container
```

Expected result:

```text
True
```

---

# Primer 4 Key Takeaways

## Processes receive environment copies

```text
PowerShell parent
       │
       ▼
Node.js child
```

A child inherits values available when it starts. It cannot normally update its parent’s environment.

## PowerShell exposes the current environment through `Env:`

```powershell
Get-ChildItem Env:
$env:PORT
```

## Session variables are temporary

```powershell
$env:PORT = "3000"
Remove-Item Env:PORT
```

They affect the current process and future children.

## Persistent variables affect new processes

User scope:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "value",
    [System.EnvironmentVariableTarget]::User
)
```

Existing terminals generally do not refresh automatically.

## Environment values are strings

```javascript
process.env.PORT === "3000"
```

Validate and convert them:

```javascript
const port = Number(process.env.PORT);
```

Then enforce type and range requirements.

## Configuration and secrets are different categories

Safe public configuration may include:

```text
NODE_ENV
HOST
PORT
```

Secrets include:

```text
APP_SECRET
API_TOKEN
DATABASE_PASSWORD
PRIVATE_KEY
```

Do not log secrets.

## `.env` is a fallback, not the highest authority

```text
existing process environment > .env
```

This lets deployment systems override local defaults.

## `.env.example` documents requirements

Commit:

```text
.env.example
```

Do not commit:

```text
.env
```

## `.env` is plaintext convenience

It is not an enterprise secret vault.

Production systems should use an approved secret-management service.

## Validate configuration at startup

Reject:

- Missing values
- Empty strings
- Invalid environment names
- Nonnumeric ports
- Out-of-range ports
- Short secrets
- Placeholder secrets

## Convert raw input into immutable configuration

```javascript
Object.freeze({
  environment,
  host,
  port,
  appSecret,
  isProduction,
});
```

## Expose only a public projection

```javascript
{
  environment,
  host,
  port,
  isProduction
}
```

Omit secret properties entirely.

## Keep project secrets out of `$PROFILE`

Profiles are suitable for reusable functions and aliases—not project credentials.

## Prefer isolated child environments in automation

A child-specific environment avoids contaminating the caller’s shell:

```powershell
$startInfo.Environment["PORT"] = "8080"
```
