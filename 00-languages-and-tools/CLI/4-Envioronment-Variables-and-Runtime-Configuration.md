[STARTING: Part 4: Environment Variables and Runtime Configuration]

# Part 4: Environment Variables and Runtime Configuration

The service currently hardcodes its network settings:

```javascript
const HOST = "127.0.0.1";
const PORT = 3000;
```

Hardcoded values make an application difficult to operate in different environments. A developer’s laptop, a test runner, and a production server may all need different settings.

This part will replace hardcoded runtime values with a secure configuration pipeline:

```text
PowerShell environment variables
                │
                ▼
         Node.js process
                │
                ├── values already supplied by the environment
                │
                └── missing local values loaded from .env
                                │
                                ▼
                    validation and conversion
                                │
                                ▼
                      immutable configuration
                                │
                                ▼
                         HTTP service
```

By the end of Part 4, you will have:

- Session-scoped PowerShell environment variables
- Persistent user-scoped environment variables
- A local `.env` file excluded from Git
- A safe `.env.example` template
- Runtime configuration validation
- Typed configuration values
- Development and production modes
- A production-specific secret requirement
- Environment-aware logs and HTTP responses
- Configuration tests
- A startup smoke test
- A customized PowerShell profile
- Reusable project-navigation and quality-check functions

---

## 4.1 Inspect PowerShell’s Environment Provider

### The Target

Inspect environment variables available to the current PowerShell process.

### The Concept

An **environment variable** is a named string supplied to a process by its operating environment.

Think of a process as an employee beginning a work shift. Environment variables are instructions placed on the employee’s desk before work begins:

```text
NODE_ENV=development
PORT=3000
```

PowerShell exposes environment variables through the `Env:` provider. A **provider** presents a data store using drive-like syntax.

You previously saw filesystem drives such as:

```text
C:
D:
```

PowerShell also provides:

```text
Env:
```

### The Implementation

List PowerShell providers:

```powershell
Get-PSProvider
```

List PowerShell drives:

```powershell
Get-PSDrive
```

Inspect the environment drive:

```powershell
Get-PSDrive -Name Env
```

List all environment variables:

```powershell
Get-ChildItem Env:
```

Sort them by name:

```powershell
Get-ChildItem Env: |
    Sort-Object Name |
    Format-Table Name, Value -AutoSize
```

Inspect one common variable:

```powershell
Get-Item Env:PATH
```

Read the same value through PowerShell’s `$env:` syntax:

```powershell
$env:PATH
```

Because `PATH` contains several directories separated by semicolons on Windows, display one entry per line:

```powershell
$env:PATH -split ";" |
    Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    }
```

### The Verification

Confirm that `PATH` is available through both interfaces:

```powershell
$pathFromProvider = (
    Get-Item Env:PATH
).Value

$pathFromVariableSyntax = $env:PATH

[PSCustomObject]@{
    ProviderValueExists = -not [string]::IsNullOrWhiteSpace(
        $pathFromProvider
    )
    VariableValueExists = -not [string]::IsNullOrWhiteSpace(
        $pathFromVariableSyntax
    )
    ValuesMatch = $pathFromProvider -eq $pathFromVariableSyntax
}
```

Every value should be `True`.

---

## 4.2 Create Session-Scoped Environment Variables

### The Target

Create temporary variables for the current PowerShell session:

```text
NODE_ENV=development
HOST=127.0.0.1
PORT=3100
```

### The Concept

A session-scoped variable belongs to the current PowerShell process and processes launched from it.

It is like writing instructions on a temporary whiteboard:

- Programs started from this terminal can see the instructions.
- A separate terminal does not automatically see them.
- Closing the terminal erases them.

### The Implementation

Set the variables:

```powershell
$env:NODE_ENV = "development"
$env:HOST = "127.0.0.1"
$env:PORT = "3100"
```

Read them:

```powershell
[PSCustomObject]@{
    NODE_ENV = $env:NODE_ENV
    HOST = $env:HOST
    PORT = $env:PORT
}
```

Inspect them through the environment provider:

```powershell
Get-Item Env:NODE_ENV
Get-Item Env:HOST
Get-Item Env:PORT
```

Start a child Node.js process and inspect what it inherited:

```powershell
node -e 'console.log({
  NODE_ENV: process.env.NODE_ENV,
  HOST: process.env.HOST,
  PORT: process.env.PORT
});'
```

Expected output resembles:

```text
{
  NODE_ENV: 'development',
  HOST: '127.0.0.1',
  PORT: '3100'
}
```

### The Verification

Ask Node.js to fail if inheritance did not work:

```powershell
node -e '
const expected = {
  NODE_ENV: "development",
  HOST: "127.0.0.1",
  PORT: "3100",
};

for (const [name, value] of Object.entries(expected)) {
  if (process.env[name] !== value) {
    throw new Error(
      `${name} should be ${value}, received ${process.env[name]}`,
    );
  }
}

console.log("Child-process environment inheritance passed.");
'
```

Expected output:

```text
Child-process environment inheritance passed.
```

---

## 4.3 Remove Session Variables

### The Target

Remove the temporary values so they do not override the `.env` file created later.

### The Concept

An existing operating-system environment value should normally take precedence over a local `.env` value.

That is useful in deployment, but it can be confusing during development. If `$env:PORT` remains set, changing `PORT` inside `.env` may appear to have no effect.

Removing a variable is like erasing one instruction from the temporary whiteboard.

### The Implementation

Remove the variables with PowerShell variable syntax:

```powershell
$env:NODE_ENV = $null
$env:HOST = $null
$env:PORT = $null
```

You can also use the provider:

```powershell
Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
Remove-Item Env:HOST -ErrorAction SilentlyContinue
Remove-Item Env:PORT -ErrorAction SilentlyContinue
```

These forms affect only the current process environment.

### The Verification

Confirm that the variables are absent:

```powershell
[PSCustomObject]@{
    NODE_ENVIsAbsent = -not (
        Test-Path Env:NODE_ENV
    )
    HOSTIsAbsent = -not (
        Test-Path Env:HOST
    )
    PORTIsAbsent = -not (
        Test-Path Env:PORT
    )
}
```

Every value should be `True`.

Confirm that a new child process does not receive them:

```powershell
node -e '
console.log({
  NODE_ENV: process.env.NODE_ENV ?? "[not set]",
  HOST: process.env.HOST ?? "[not set]",
  PORT: process.env.PORT ?? "[not set]",
});
'
```

---

## 4.4 Understand Process, User, and Machine Scope

### The Target

Distinguish temporary process variables from persistent Windows environment variables.

### The Concept

Windows supports three important scopes:

| Scope | Availability |
|---|---|
| Process | Current process and future child processes |
| User | New processes started by the current Windows user |
| Machine | New processes started by any user, subject to permissions |

The inheritance direction is important:

```text
Windows user or machine environment
                │
                ▼
       newly started PowerShell
                │
                ▼
       child Node.js process
```

Changes do not normally travel backward into an already running parent process.

If you persist a user variable while PowerShell is open, the current terminal does not automatically refresh its `$env:` value.

### The Implementation

Read a variable at each scope:

```powershell
$variableName = "DEVELOPER_SERIES_EXAMPLE"

[PSCustomObject]@{
    Process = [System.Environment]::GetEnvironmentVariable(
        $variableName,
        [System.EnvironmentVariableTarget]::Process
    )
    User = [System.Environment]::GetEnvironmentVariable(
        $variableName,
        [System.EnvironmentVariableTarget]::User
    )
    Machine = [System.Environment]::GetEnvironmentVariable(
        $variableName,
        [System.EnvironmentVariableTarget]::Machine
    )
}
```

Create a harmless user-scoped demonstration variable:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "DEVELOPER_SERIES_EXAMPLE",
    "persistent-user-value",
    [System.EnvironmentVariableTarget]::User
)
```

Read the persistent user value directly:

```powershell
[System.Environment]::GetEnvironmentVariable(
    "DEVELOPER_SERIES_EXAMPLE",
    [System.EnvironmentVariableTarget]::User
)
```

Now inspect the current process:

```powershell
$env:DEVELOPER_SERIES_EXAMPLE
```

It may remain empty because this PowerShell process started before the user-level variable was created.

Copy the persistent value into the current process explicitly:

```powershell
$env:DEVELOPER_SERIES_EXAMPLE = (
    [System.Environment]::GetEnvironmentVariable(
        "DEVELOPER_SERIES_EXAMPLE",
        [System.EnvironmentVariableTarget]::User
    )
)
```

### The Verification

Verify both scopes:

```powershell
$userValue = [System.Environment]::GetEnvironmentVariable(
    "DEVELOPER_SERIES_EXAMPLE",
    [System.EnvironmentVariableTarget]::User
)

[PSCustomObject]@{
    PersistentUserValueCorrect = (
        $userValue -eq "persistent-user-value"
    )
    CurrentProcessValueCorrect = (
        $env:DEVELOPER_SERIES_EXAMPLE -eq
        "persistent-user-value"
    )
}
```

Both values should be `True`.

Clean up the demonstration variable from both scopes:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "DEVELOPER_SERIES_EXAMPLE",
    $null,
    [System.EnvironmentVariableTarget]::User
)

Remove-Item `
    Env:DEVELOPER_SERIES_EXAMPLE `
    -ErrorAction SilentlyContinue
```

Verify cleanup:

```powershell
[System.Environment]::GetEnvironmentVariable(
    "DEVELOPER_SERIES_EXAMPLE",
    [System.EnvironmentVariableTarget]::User
) -eq $null
```

Expected result:

```text
True
```

> Do not persist application secrets as tutorial exercises. Windows environment variables are configuration mechanisms, not dedicated secret vaults.

---

## 4.5 Return to the Node.js Project

### The Target

Enter the project created in Part 3 and verify its current state.

### The Concept

Configuration changes will modify the working service. Before changing it, confirm that its existing foundation is intact.

### The Implementation

Construct and enter the project path:

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
```

Inspect the project:

```powershell
Get-ChildItem -Force
```

Run the existing quality gate:

```powershell
npm.cmd run check
```

### The Verification

Confirm the critical files:

```powershell
$preConfigurationChecks = @(
    ".\package.json"
    ".\package-lock.json"
    ".\src\app.js"
    ".\src\index.js"
    ".\scripts\build.js"
    ".\scripts\clean.js"
    ".\test\server.test.js"
)

$preConfigurationResults = foreach ($path in $preConfigurationChecks) {
    [PSCustomObject]@{
        Path = $path
        Exists = Test-Path `
            -LiteralPath $path `
            -PathType Leaf
    }
}

$preConfigurationResults |
    Format-Table -AutoSize
```

Every `Exists` value should be `True`.

---

## 4.6 Install `dotenv`

### The Target

Install `dotenv` as a production dependency.

### The Concept

Node.js reads operating-system environment variables through:

```javascript
process.env
```

A `.env` file is an ordinary text file containing name-value pairs:

```text
PORT=3000
NODE_ENV=development
```

Node.js does not automatically load that file. The `dotenv` package reads it and adds missing values to `process.env`.

By default, dotenv does not replace environment variables that already exist. This gives us the desired precedence:

```text
operating-system environment
             │
             ├── value exists → retain it
             │
             └── value missing → load it from .env
```

### The Implementation

Install the package:

```powershell
npm.cmd install dotenv
```

Inspect the installed dependency:

```powershell
npm.cmd list dotenv --depth=0
```

Inspect `package.json`:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$packageData.dependencies |
    Format-List
```

### The Verification

Load the package:

```powershell
node -e 'const dotenv = require("dotenv"); console.log(typeof dotenv.config);'
```

Expected output:

```text
function
```

Confirm that it is a runtime dependency:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

$null -ne $packageData.dependencies.dotenv
```

Expected result:

```text
True
```

---

## 4.7 Create a Safe `.env.example` Template

### The Target

Create:

```text
developer-service\.env.example
```

This file documents required configuration without containing a real secret.

### The Concept

A `.env.example` file is an empty application form. It shows which fields must be completed but does not contain private answers.

It should be safe to commit to Git.

Secret values must not appear in it.

### The Implementation

Create the template.

### File: `developer-service/.env.example`

```powershell
$envExampleContent = @'
# Runtime mode: development, test, or production.
NODE_ENV=development

# Address on which the HTTP server listens.
HOST=127.0.0.1

# TCP port. Valid values are 1 through 65535.
PORT=3000

# Set this to a unique secret.
# Development and test require at least 16 characters.
# Production requires at least 32 characters.
APP_SECRET=replace-with-a-unique-secret
'@

Set-Content `
    -LiteralPath "$projectRoot\.env.example" `
    -Value $envExampleContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Read it:

```powershell
Get-Content -LiteralPath .\.env.example
```

Confirm that the template contains all required names:

```powershell
$requiredVariableNames = @(
    "NODE_ENV"
    "HOST"
    "PORT"
    "APP_SECRET"
)

$exampleText = Get-Content `
    -LiteralPath .\.env.example `
    -Raw

$exampleChecks = foreach ($variableName in $requiredVariableNames) {
    [PSCustomObject]@{
        Variable = $variableName
        Documented = $exampleText -match (
            "(?m)^" +
            [regex]::Escape($variableName) +
            "="
        )
    }
}

$exampleChecks |
    Format-Table -AutoSize
```

Every `Documented` value should be `True`.

---

## 4.8 Create the Local `.env` File

### The Target

Create:

```text
developer-service\.env
```

with local development settings and a randomly generated development secret.

### The Concept

`.env` is a local configuration file. It may contain private values and therefore must not be committed.

A development secret should not be copied from a production environment. Even local secrets should be generated rather than using obvious values such as:

```text
password
secret
123456
```

The secret generated here is for local development only.

### The Implementation

Generate 32 random bytes and encode them as hexadecimal:

```powershell
$randomBytes = New-Object byte[] 32

[System.Security.Cryptography.RandomNumberGenerator]::Fill(
    $randomBytes
)

$developmentSecret = [System.Convert]::ToHexString(
    $randomBytes
).ToLowerInvariant()
```

> `[System.Convert]::ToHexString` requires a modern .NET runtime and is available in PowerShell 7. If you use Windows PowerShell 5.1, generate the string with:

```powershell
if (-not (
    [System.Convert].GetMethod(
        "ToHexString",
        [type[]]@([byte[]])
    )
)) {
    $developmentSecret = (
        $randomBytes |
            ForEach-Object {
                $_.ToString("x2")
            }
    ) -join ""
}
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
    -LiteralPath "$projectRoot\.env" `
    -Value $envContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Clear the PowerShell variable after writing it:

```powershell
$developmentSecret = $null
$randomBytes = $null
```

Clearing the variable reduces accidental reuse, but it cannot guarantee that previous memory contents have been erased immediately.

### The Verification

Do not print the complete `.env` file in screenshots or shared logs.

Inspect only the variable names:

```powershell
Get-Content -LiteralPath .\.env |
    Where-Object {
        $_ -match "^[A-Za-z_][A-Za-z0-9_]*="
    } |
    ForEach-Object {
        ($_ -split "=", 2)[0]
    }
```

Expected output:

```text
NODE_ENV
HOST
PORT
APP_SECRET
```

Confirm the secret exists without displaying it:

```powershell
$secretLine = Get-Content `
    -LiteralPath .\.env |
    Where-Object {
        $_ -match "^APP_SECRET="
    }

$secretValue = (
    $secretLine -split "=", 2
)[1]

[PSCustomObject]@{
    EnvFileExists = Test-Path `
        -LiteralPath .\.env `
        -PathType Leaf
    SecretExists = -not [string]::IsNullOrWhiteSpace(
        $secretValue
    )
    SecretHasAtLeast32Characters = $secretValue.Length -ge 32
}
```

Every value should be `True`.

Remove the verification copy from the session:

```powershell
$secretLine = $null
$secretValue = $null
```

---

## 4.9 Verify That Git Excludes `.env`

### The Target

Prove that `.env` is ignored while `.env.example` remains trackable.

### The Concept

`.gitignore` prevents untracked local files from being included by ordinary Git commands. It is an important guardrail, but it does not erase a secret that has already been committed.

If a secret ever enters Git history:

1. Treat it as compromised.
2. Revoke or rotate it.
3. Remove it from current files.
4. Follow your organization’s history-rewriting procedure if necessary.

### The Implementation

Inspect the existing rules:

```powershell
Get-Content -LiteralPath .\.gitignore
```

Confirm these lines exist:

```text
.env
.env.*
!.env.example
```

If Git is installed, initialize the repository if necessary:

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

Ask Git which rule ignores `.env`:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    git check-ignore -v .env
}
```

Ask whether `.env.example` is ignored:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    git check-ignore .env.example
    $exampleIgnoreExitCode = $LASTEXITCODE
}
```

For `git check-ignore`, an exit code of `1` means the path is not ignored.

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
    Write-Host "Git is unavailable; inspect .gitignore manually." -ForegroundColor Yellow
}
```

Expected result when Git is available:

```text
EnvIsIgnored       : True
ExampleIsTrackable : True
```

---

## 4.10 Build the Configuration Module

### The Target

Create:

```text
developer-service\src\config.js
```

The module will:

- Load `.env`
- Preserve environment values that already exist
- Validate `NODE_ENV`
- Validate `HOST`
- Convert `PORT` from a string into an integer
- Validate `APP_SECRET`
- Apply a stricter production secret rule
- Return an immutable configuration object
- Avoid printing the secret

### The Concept

Environment variables are always strings when supplied to Node.js:

```javascript
process.env.PORT === "3000"
```

The application needs a number:

```javascript
3000
```

A configuration module acts like an airport security checkpoint. Raw values enter from the outside, but only validated, correctly shaped values pass into the application.

Failing during startup is safer than discovering malformed configuration after the service begins handling requests.

### The Implementation

Create the complete module.

### File: `developer-service/src/config.js`

```powershell
$configSourceContent = @'
"use strict";

const path = require("node:path");
const dotenv = require("dotenv");

const ALLOWED_ENVIRONMENTS = new Set([
  "development",
  "test",
  "production",
]);

function requireNonEmptyString(environment, name) {
  const value = environment[name];

  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Configuration variable ${name} is required and cannot be empty.`,
    );
  }

  return value.trim();
}

function parseEnvironmentName(environment) {
  const value = requireNonEmptyString(environment, "NODE_ENV").toLowerCase();

  if (!ALLOWED_ENVIRONMENTS.has(value)) {
    throw new Error(
      "NODE_ENV must be one of: development, test, production.",
    );
  }

  return value;
}

function parseHost(environment) {
  const value = requireNonEmptyString(environment, "HOST");

  if (value.length > 253) {
    throw new Error("HOST cannot exceed 253 characters.");
  }

  if (/\s/.test(value)) {
    throw new Error("HOST cannot contain whitespace.");
  }

  return value;
}

function parsePort(environment) {
  const rawValue = requireNonEmptyString(environment, "PORT");

  if (!/^\d+$/.test(rawValue)) {
    throw new Error("PORT must contain only decimal digits.");
  }

  const value = Number(rawValue);

  if (!Number.isSafeInteger(value) || value < 1 || value > 65_535) {
    throw new Error("PORT must be an integer from 1 through 65535.");
  }

  return value;
}

function parseSecret(environment, environmentName) {
  const value = requireNonEmptyString(environment, "APP_SECRET");
  const minimumLength = environmentName === "production" ? 32 : 16;

  if (value.length < minimumLength) {
    throw new Error(
      `APP_SECRET must contain at least ${minimumLength} characters ` +
        `when NODE_ENV is ${environmentName}.`,
    );
  }

  const knownPlaceholderValues = new Set([
    "change-me",
    "replace-me",
    "replace-with-a-unique-secret",
    "secret",
    "password",
  ]);

  if (knownPlaceholderValues.has(value.toLowerCase())) {
    throw new Error("APP_SECRET cannot use a documented placeholder value.");
  }

  return value;
}

function parseConfiguration(environment) {
  const environmentName = parseEnvironmentName(environment);
  const host = parseHost(environment);
  const port = parsePort(environment);
  const appSecret = parseSecret(environment, environmentName);

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
  const envFile = options.envFile ?? path.resolve(__dirname, "..", ".env");

  const dotenvResult = dotenv.config({
    path: envFile,
    override: false,
    processEnv: environment,
    quiet: true,
  });

  if (dotenvResult.error) {
    const errorCode = dotenvResult.error.code;

    // A deployment may inject every value directly and intentionally omit
    // .env. Missing .env is therefore allowed; malformed or unreadable files
    // still fail startup.
    if (errorCode !== "ENOENT") {
      throw new Error(
        `Unable to load environment file ${envFile}: ` +
          dotenvResult.error.message,
      );
    }
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
    -LiteralPath "$projectRoot\src\config.js" `
    -Value $configSourceContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
node --check .\src\config.js
```

Load the local configuration without displaying the secret:

```powershell
node -e '
const {
  loadConfiguration,
  publicConfiguration,
} = require("./src/config");

const configuration = loadConfiguration();

console.log(publicConfiguration(configuration));
console.log({
  secretLoaded: typeof configuration.appSecret === "string",
  secretLength: configuration.appSecret.length,
  frozen: Object.isFrozen(configuration),
});
'
```

Expected output includes:

```text
environment: 'development'
host: '127.0.0.1'
port: 3000
secretLoaded: true
frozen: true
```

The actual secret must not be printed.

---

## 4.11 Prove Environment Variables Override `.env`

### The Target

Run the configuration loader with a session-scoped port that overrides `.env`.

### The Concept

`.env` is a local fallback, not the highest authority.

A production platform, CI system, container, or PowerShell session must be able to supply a value without editing application files.

The precedence is:

```text
existing process environment > .env fallback
```

### The Implementation

Set a temporary port:

```powershell
$env:PORT = "3200"
```

Load the configuration:

```powershell
node -e '
const {
  loadConfiguration,
  publicConfiguration,
} = require("./src/config");

console.log(publicConfiguration(loadConfiguration()));
'
```

Expected output includes:

```text
port: 3200
```

Remove the override:

```powershell
Remove-Item Env:PORT -ErrorAction SilentlyContinue
```

Load it again:

```powershell
node -e '
const {
  loadConfiguration,
  publicConfiguration,
} = require("./src/config");

console.log(publicConfiguration(loadConfiguration()));
'
```

Expected output includes the `.env` value:

```text
port: 3000
```

### The Verification

Automate the precedence check:

```powershell
$env:PORT = "3201"

try {
    $resolvedPort = node -e '
const { loadConfiguration } = require("./src/config");
process.stdout.write(String(loadConfiguration().port));
'

    if ($resolvedPort -ne "3201") {
        throw "Expected port 3201, received $resolvedPort"
    }

    Write-Host "Environment precedence passed." -ForegroundColor Green
}
finally {
    Remove-Item Env:PORT -ErrorAction SilentlyContinue
}
```

Expected message:

```text
Environment precedence passed.
```

---

## 4.12 Update the Express Application

### The Target

Update:

```text
developer-service\src\app.js
```

so the application receives validated configuration without exposing its secret.

### The Concept

Configuration should enter the application through an explicit boundary.

Passing configuration into `createApp` is called **dependency injection**. Despite the complicated name, the idea is simple: instead of making the application search globally for what it needs, the caller hands it the required values.

This makes tests easier and keeps secret handling centralized.

### The Implementation

Replace the complete file.

### File: `developer-service/src/app.js`

```powershell
$appSourceContent = @'
"use strict";

const express = require("express");

function createApp(options = {}) {
  const environment = options.environment ?? "development";

  const app = express();

  app.disable("x-powered-by");

  app.use(express.json({
    limit: "16kb",
  }));

  app.get("/", (request, response) => {
    response.status(200).json({
      service: "developer-service",
      environment,
      message: "The Node.js service is running.",
    });
  });

  app.get("/health", (request, response) => {
    response.status(200).json({
      status: "ok",
      environment,
      uptimeSeconds: Math.floor(process.uptime()),
      timestamp: new Date().toISOString(),
    });
  });

  app.post("/echo", (request, response) => {
    response.status(200).json({
      received: request.body,
    });
  });

  app.use((request, response) => {
    response.status(404).json({
      error: "Not Found",
      method: request.method,
      path: request.originalUrl,
    });
  });

  app.use((error, request, response, next) => {
    void request;
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
    -LiteralPath "$projectRoot\src\app.js" `
    -Value $appSourceContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
node --check .\src\app.js
```

Create an application with explicit test configuration:

```powershell
node -e '
const { createApp } = require("./src/app");

const app = createApp({
  environment: "test",
});

console.log({
  applicationCreated: typeof app === "function",
});
'
```

Expected output:

```text
applicationCreated: true
```

---

## 4.13 Update the Server Entry Point

### The Target

Replace hardcoded host and port values in:

```text
developer-service\src\index.js
```

with validated configuration.

### The Concept

The entry point is the application’s composition root—the place where major pieces are assembled.

It will:

1. Load raw environment values.
2. Validate them.
3. Construct the application.
4. Open the server.
5. Log only public configuration.
6. Never print `APP_SECRET`.

### The Implementation

Replace the file.

### File: `developer-service/src/index.js`

```powershell
$indexSourceContent = @'
"use strict";

const http = require("node:http");
const { createApp } = require("./app");
const {
  loadConfiguration,
  publicConfiguration,
} = require("./config");

const SHUTDOWN_TIMEOUT_MS = 10_000;

let configuration;

try {
  configuration = loadConfiguration();
} catch (error) {
  console.error("Configuration error:", error.message);
  process.exit(1);
}

const app = createApp({
  environment: configuration.environment,
});

const server = http.createServer(app);

let shutdownStarted = false;

function shutdown(signal, exitCode = 0) {
  if (shutdownStarted) {
    return;
  }

  shutdownStarted = true;
  console.log(`Received ${signal}. Closing the HTTP server.`);

  const forcedShutdownTimer = setTimeout(() => {
    console.error("Graceful shutdown timed out. Forcing process exit.");
    process.exit(1);
  }, SHUTDOWN_TIMEOUT_MS);

  forcedShutdownTimer.unref();

  server.close((error) => {
    clearTimeout(forcedShutdownTimer);

    if (error) {
      console.error("The HTTP server failed to close cleanly:", error);
      process.exit(1);
    }

    console.log("HTTP server closed.");
    process.exit(exitCode);
  });
}

server.on("error", (error) => {
  console.error("HTTP server error:", error);
  process.exitCode = 1;
});

server.listen(configuration.port, configuration.host, () => {
  const publicConfig = publicConfiguration(configuration);
  const address = `http://${publicConfig.host}:${publicConfig.port}`;

  console.log("developer-service started", {
    address,
    environment: publicConfig.environment,
    processId: process.pid,
  });
});

process.on("SIGINT", () => {
  shutdown("SIGINT");
});

process.on("SIGTERM", () => {
  shutdown("SIGTERM");
});

process.on("uncaughtException", (error) => {
  console.error("Uncaught exception:", error);
  shutdown("uncaughtException", 1);
});

process.on("unhandledRejection", (reason) => {
  console.error("Unhandled promise rejection:", reason);
  shutdown("unhandledRejection", 1);
});
'@

Set-Content `
    -LiteralPath "$projectRoot\src\index.js" `
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
npm.cmd run dev
```

Expected startup information includes:

```text
address: 'http://127.0.0.1:3000'
environment: 'development'
```

In another PowerShell terminal:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/"
```

Expected properties include:

```text
service     : developer-service
environment : development
message     : The Node.js service is running.
```

Stop the server with `Ctrl+C`.

---

## 4.14 Add Configuration Tests

### The Target

Create:

```text
developer-service\test\config.test.js
```

to verify valid and invalid configuration independently.

### The Concept

Configuration validation is application behavior and should be tested.

Each test constructs a plain object instead of changing global `process.env`. This keeps tests isolated and prevents one test’s values from leaking into another.

### The Implementation

Create the complete test file.

### File: `developer-service/test/config.test.js`

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

test("parseConfiguration converts and freezes valid values", () => {
  const configuration = parseConfiguration(validEnvironment());

  assert.equal(configuration.environment, "development");
  assert.equal(configuration.host, "127.0.0.1");
  assert.equal(configuration.port, 3000);
  assert.equal(configuration.appSecret, "development-secret-value");
  assert.equal(configuration.isProduction, false);
  assert.equal(Object.isFrozen(configuration), true);
});

test("production mode is identified", () => {
  const configuration = parseConfiguration(
    validEnvironment({
      NODE_ENV: "production",
      APP_SECRET: "a-production-secret-with-32-characters",
    }),
  );

  assert.equal(configuration.environment, "production");
  assert.equal(configuration.isProduction, true);
});

test("an unsupported NODE_ENV is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        NODE_ENV: "preview",
      }),
    ),
    /NODE_ENV must be one of/,
  );
});

test("a nonnumeric port is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        PORT: "three-thousand",
      }),
    ),
    /PORT must contain only decimal digits/,
  );
});

test("a port outside the TCP range is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        PORT: "70000",
      }),
    ),
    /PORT must be an integer from 1 through 65535/,
  );
});

test("a missing secret is rejected", () => {
  const environment = validEnvironment();
  delete environment.APP_SECRET;

  assert.throws(
    () => parseConfiguration(environment),
    /APP_SECRET is required/,
  );
});

test("a short development secret is rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        APP_SECRET: "too-short",
      }),
    ),
    /at least 16 characters/,
  );
});

test("production requires a longer secret", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        NODE_ENV: "production",
        APP_SECRET: "only-sixteen-char",
      }),
    ),
    /at least 32 characters/,
  );
});

test("documented placeholder secrets are rejected", () => {
  assert.throws(
    () => parseConfiguration(
      validEnvironment({
        APP_SECRET: "replace-with-a-unique-secret",
      }),
    ),
    /placeholder value/,
  );
});

test("publicConfiguration excludes APP_SECRET", () => {
  const configuration = parseConfiguration(validEnvironment());
  const publicConfig = publicConfiguration(configuration);

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
    -LiteralPath "$projectRoot\test\config.test.js" `
    -Value $configTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
node --check .\test\config.test.js
```

Run all tests:

```powershell
npm.cmd test
```

The project should now report fourteen passing tests:

```text
tests 14
pass 14
fail 0
```

The exact display format may vary by Node.js version, but no tests should fail.

---

## 4.15 Update Server Tests for Environment Metadata

### The Target

Update:

```text
developer-service\test\server.test.js
```

so test applications explicitly run in the `test` environment.

### The Concept

Tests should declare their context instead of relying on application defaults.

This makes the expected environment visible in the setup and allows route responses to verify it.

### The Implementation

Replace the complete test file.

### File: `developer-service/test/server.test.js`

```powershell
$serverTestContent = @'
"use strict";

const assert = require("node:assert/strict");
const http = require("node:http");
const { afterEach, test } = require("node:test");
const { createApp } = require("../src/app");

const activeServers = new Set();

async function startTestServer() {
  const app = createApp({
    environment: "test",
  });

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
  assert.equal(body.environment, "test");
  assert.equal(body.message, "The Node.js service is running.");

  await closeServer(server);
});

test("GET /health returns a healthy response", async () => {
  const { baseUrl, server } = await startTestServer();

  const response = await fetch(`${baseUrl}/health`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.status, "ok");
  assert.equal(body.environment, "test");
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
    -LiteralPath "$projectRoot\test\server.test.js" `
    -Value $serverTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Run linting and tests:

```powershell
npm.cmd run lint
npm.cmd test
```

Both commands should exit successfully.

Inspect the last exit code:

```powershell
$LASTEXITCODE
```

Expected result:

```text
0
```

---

## 4.16 Verify Invalid Configuration Fails Fast

### The Target

Prove that the service refuses to start with an invalid port or insufficient production secret.

### The Concept

A service with invalid configuration should fail immediately and clearly.

This is called **fail-fast behavior**. It is safer to reject an invalid port at startup than to continue in an uncertain state.

### The Implementation

Test an invalid port in a child process:

```powershell
$env:PORT = "invalid-port"

try {
    node .\src\index.js
    $invalidPortExitCode = $LASTEXITCODE
}
finally {
    Remove-Item Env:PORT -ErrorAction SilentlyContinue
}
```

Expected error includes:

```text
Configuration error: PORT must contain only decimal digits.
```

The process should exit immediately.

Test production mode with a secret that is valid for development but too short for production:

```powershell
$env:NODE_ENV = "production"
$env:APP_SECRET = "sixteen-char-key"

try {
    node .\src\index.js
    $shortProductionSecretExitCode = $LASTEXITCODE
}
finally {
    Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
    Remove-Item Env:APP_SECRET -ErrorAction SilentlyContinue
}
```

Expected error explains that production requires at least 32 characters.

### The Verification

Check both exit codes:

```powershell
[PSCustomObject]@{
    InvalidPortWasRejected = $invalidPortExitCode -ne 0
    ShortProductionSecretWasRejected = (
        $shortProductionSecretExitCode -ne 0
    )
}
```

Both values should be `True`.

Confirm that normal local configuration still loads:

```powershell
node -e '
const { loadConfiguration } = require("./src/config");
const configuration = loadConfiguration();

console.log({
  valid: true,
  environment: configuration.environment,
  port: configuration.port,
});
'
```

---

## 4.17 Add a Configuration Inspection Script

### The Target

Create:

```text
developer-service\scripts\show-config.js
```

and expose it through:

```powershell
npm run config
```

The script will display only public configuration.

### The Concept

Operators often need to answer:

> Which host, port, and environment did the application resolve?

A diagnostic command is useful, but it must never print secrets.

### The Implementation

Create the script.

### File: `developer-service/scripts/show-config.js`

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
    -LiteralPath "$projectRoot\scripts\show-config.js" `
    -Value $showConfigContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Add the script to `package.json` without manually reconstructing dependency versions:

```powershell
npm.cmd pkg set "scripts.config=node scripts/show-config.js"
```

Inspect the result:

```powershell
npm.cmd pkg get scripts.config
```

### The Verification

Run:

```powershell
npm.cmd run config
```

Expected JSON resembles:

```json
{
  "environment": "development",
  "host": "127.0.0.1",
  "port": 3000,
  "isProduction": false
}
```

Confirm the output does not contain the secret property name:

```powershell
$configOutput = npm.cmd run config --silent

$containsSecretName = (
    $configOutput -join "`n"
) -match "appSecret|APP_SECRET"

if ($containsSecretName) {
    throw "Public configuration output exposed a secret field."
}

Write-Host "Configuration output contains no secret field." -ForegroundColor Green
```

---

## 4.18 Add a Production Configuration Check

### The Target

Create an npm script that validates production configuration without starting the server.

### The Concept

Deployment systems should be able to validate configuration before opening a network port.

The existing configuration inspection script already loads and validates all values. Supplying production variables to it provides a lightweight deployment check.

We will not place the production secret in `package.json`.

### The Implementation

Add a general validation alias:

```powershell
npm.cmd pkg set "scripts.validate-config=node scripts/show-config.js"
```

Generate a temporary production secret in the current PowerShell session:

```powershell
$productionBytes = New-Object byte[] 32

[System.Security.Cryptography.RandomNumberGenerator]::Fill(
    $productionBytes
)

if ([System.Convert].GetMethod(
    "ToHexString",
    [type[]]@([byte[]])
)) {
    $temporaryProductionSecret = (
        [System.Convert]::ToHexString($productionBytes)
    ).ToLowerInvariant()
}
else {
    $temporaryProductionSecret = (
        $productionBytes |
            ForEach-Object {
                $_.ToString("x2")
            }
    ) -join ""
}
```

Supply production configuration for one session:

```powershell
$env:NODE_ENV = "production"
$env:HOST = "127.0.0.1"
$env:PORT = "8080"
$env:APP_SECRET = $temporaryProductionSecret
```

Validate it:

```powershell
npm.cmd run validate-config
```

Clean up immediately:

```powershell
Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
Remove-Item Env:HOST -ErrorAction SilentlyContinue
Remove-Item Env:PORT -ErrorAction SilentlyContinue
Remove-Item Env:APP_SECRET -ErrorAction SilentlyContinue

$temporaryProductionSecret = $null
$productionBytes = $null
```

### The Verification

Repeat the check with cleanup guaranteed by `finally`:

```powershell
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)

$secret = (
    $bytes |
        ForEach-Object {
            $_.ToString("x2")
        }
) -join ""

try {
    $env:NODE_ENV = "production"
    $env:HOST = "127.0.0.1"
    $env:PORT = "8080"
    $env:APP_SECRET = $secret

    npm.cmd run validate-config
    $validationExitCode = $LASTEXITCODE
}
finally {
    Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
    Remove-Item Env:HOST -ErrorAction SilentlyContinue
    Remove-Item Env:PORT -ErrorAction SilentlyContinue
    Remove-Item Env:APP_SECRET -ErrorAction SilentlyContinue

    $secret = $null
    $bytes = $null
}

if ($validationExitCode -ne 0) {
    throw "Production configuration validation failed."
}

Write-Host "Production configuration validation passed." -ForegroundColor Green
```

---

## 4.19 Create an Automated Smoke Test

### The Target

Create:

```text
developer-service\scripts\smoke-test.js
```

The script will:

1. Build the service.
2. Start `dist/index.js` as a child process.
3. Inject isolated test configuration.
4. Poll `/health`.
5. Verify the response.
6. Shut down the child process.
7. Fail if startup or health verification fails.

### The Concept

A unit or integration test may construct the application without executing the real entry point.

A **smoke test** starts the actual built service and checks one critical path. The name comes from hardware testing: if powering on a device produces smoke, deeper testing is unnecessary.

### The Implementation

Create the script.

### File: `developer-service/scripts/smoke-test.js`

```powershell
$smokeTestContent = @'
"use strict";

const path = require("node:path");
const { spawn } = require("node:child_process");
const { randomBytes } = require("node:crypto");

const HOST = "127.0.0.1";
const PORT = 43127;
const STARTUP_TIMEOUT_MS = 10_000;
const POLL_INTERVAL_MS = 200;

function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function waitForHealth(baseUrl, child) {
  const deadline = Date.now() + STARTUP_TIMEOUT_MS;
  let lastError;

  while (Date.now() < deadline) {
    if (child.exitCode !== null) {
      throw new Error(
        `Service exited before becoming healthy with code ${child.exitCode}.`,
      );
    }

    try {
      const response = await fetch(`${baseUrl}/health`);

      if (response.status === 200) {
        const body = await response.json();

        if (
          body.status === "ok" &&
          body.environment === "test"
        ) {
          return body;
        }
      }
    } catch (error) {
      lastError = error;
    }

    await delay(POLL_INTERVAL_MS);
  }

  throw new Error(
    "Service did not become healthy before the startup timeout." +
      (lastError ? ` Last error: ${lastError.message}` : ""),
  );
}

async function stopChild(child) {
  if (child.exitCode !== null) {
    return;
  }

  child.kill("SIGTERM");

  const exited = await Promise.race([
    new Promise((resolve) => {
      child.once("exit", () => resolve(true));
    }),
    delay(5_000).then(() => false),
  ]);

  if (!exited && child.exitCode === null) {
    child.kill("SIGKILL");
  }
}

async function main() {
  const projectRoot = path.resolve(__dirname, "..");
  const entryPoint = path.join(projectRoot, "dist", "index.js");
  const baseUrl = `http://${HOST}:${PORT}`;

  const child = spawn(
    process.execPath,
    [entryPoint],
    {
      cwd: projectRoot,
      env: {
        ...process.env,
        NODE_ENV: "test",
        HOST,
        PORT: String(PORT),
        APP_SECRET: randomBytes(32).toString("hex"),
      },
      stdio: [
        "ignore",
        "pipe",
        "pipe",
      ],
      windowsHide: true,
    },
  );

  child.stdout.on("data", (data) => {
    process.stdout.write(`[service] ${data}`);
  });

  child.stderr.on("data", (data) => {
    process.stderr.write(`[service] ${data}`);
  });

  try {
    const health = await waitForHealth(baseUrl, child);

    console.log("Smoke test passed:", {
      status: health.status,
      environment: health.environment,
    });
  } finally {
    await stopChild(child);
  }
}

main().catch((error) => {
  console.error("Smoke test failed:", error);
  process.exitCode = 1;
});
'@

Set-Content `
    -LiteralPath "$projectRoot\scripts\smoke-test.js" `
    -Value $smokeTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Add the npm script:

```powershell
npm.cmd pkg set "scripts.smoke=node scripts/smoke-test.js"
```

Update `check` so the smoke test runs after the build:

```powershell
npm.cmd pkg set "scripts.check=npm run lint && npm test && npm run build && npm run smoke"
```

### The Verification

Check syntax:

```powershell
node --check .\scripts\smoke-test.js
```

Run the smoke test after building:

```powershell
npm.cmd run build
npm.cmd run smoke
```

Expected output includes:

```text
Smoke test passed
```

Run the complete quality gate:

```powershell
npm.cmd run check
```

The sequence is now:

```text
lint → tests → build → smoke test
```

---

## 4.20 Verify the Production Start Path

### The Target

Run the built service with production variables supplied by PowerShell.

### The Concept

Production deployment should not depend on a secret stored in `.env`.

The deployment environment should inject the production secret. Because existing environment variables outrank `.env`, production values override local development values without modifying source files.

### The Implementation

Generate a temporary production secret:

```powershell
$productionBytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill(
    $productionBytes
)

$productionSecret = (
    $productionBytes |
        ForEach-Object {
            $_.ToString("x2")
        }
) -join ""
```

Set production variables:

```powershell
$env:NODE_ENV = "production"
$env:HOST = "127.0.0.1"
$env:PORT = "8080"
$env:APP_SECRET = $productionSecret
```

Start the service:

```powershell
npm.cmd start
```

The `prestart` lifecycle builds the application first.

In a second PowerShell terminal, run:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:8080/health"
```

Expected response includes:

```text
status      : ok
environment : production
```

Stop the service with `Ctrl+C`.

Clean the current terminal environment:

```powershell
Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
Remove-Item Env:HOST -ErrorAction SilentlyContinue
Remove-Item Env:PORT -ErrorAction SilentlyContinue
Remove-Item Env:APP_SECRET -ErrorAction SilentlyContinue

$productionSecret = $null
$productionBytes = $null
```

### The Verification

Confirm cleanup:

```powershell
[PSCustomObject]@{
    NODE_ENVRemoved = -not (Test-Path Env:NODE_ENV)
    HOSTRemoved = -not (Test-Path Env:HOST)
    PORTRemoved = -not (Test-Path Env:PORT)
    APP_SECRETRemoved = -not (Test-Path Env:APP_SECRET)
}
```

Every value should be `True`.

---

## 4.21 Discover the PowerShell Profile

### The Target

Locate the profile script for the current PowerShell host.

### The Concept

A PowerShell profile is a script that runs when a PowerShell session starts.

It is like preparing a workbench before beginning work. Frequently used tools and shortcuts can be made available automatically.

The profile should contain:

- Reusable functions
- General aliases
- Prompt customization
- Developer convenience settings

It should not contain:

- Project secrets
- Production credentials
- Tokens
- Passwords
- Private keys

### The Implementation

Display the profile path:

```powershell
$PROFILE
```

Inspect all profile paths:

```powershell
$PROFILE |
    Format-List *
```

Common profile variants include:

- Current user, current host
- Current user, all hosts
- All users, current host
- All users, all hosts

This tutorial modifies only:

```powershell
$PROFILE.CurrentUserCurrentHost
```

Store the path:

```powershell
$profilePath = $PROFILE.CurrentUserCurrentHost
```

Check whether it exists:

```powershell
Test-Path `
    -LiteralPath $profilePath `
    -PathType Leaf
```

### The Verification

Confirm that the profile path is absolute:

```powershell
[System.IO.Path]::IsPathRooted($profilePath)
```

Expected result:

```text
True
```

Display its parent directory:

```powershell
Split-Path -Path $profilePath -Parent
```

---

## 4.22 Back Up and Create the PowerShell Profile

### The Target

Create the profile if it is missing and back up any existing content before modification.

### The Concept

A profile may already contain important personal configuration. Replacing it without inspection would be unsafe.

The correct workflow is:

1. Locate it.
2. Back it up.
3. Create its parent directory if necessary.
4. Append a clearly marked tutorial section.

### The Implementation

Create the parent directory:

```powershell
$profileDirectory = Split-Path `
    -Path $profilePath `
    -Parent

if (-not (
    Test-Path `
        -LiteralPath $profileDirectory `
        -PathType Container
)) {
    $null = New-Item `
        -Path $profileDirectory `
        -ItemType Directory `
        -Force `
        -ErrorAction Stop
}
```

Back up an existing profile:

```powershell
if (Test-Path -LiteralPath $profilePath -PathType Leaf) {
    $backupPath = (
        $profilePath +
        "." +
        (Get-Date -Format "yyyyMMdd-HHmmss") +
        ".backup"
    )

    Copy-Item `
        -LiteralPath $profilePath `
        -Destination $backupPath `
        -ErrorAction Stop

    Write-Host "Profile backup: $backupPath" -ForegroundColor Green
}
else {
    $null = New-Item `
        -Path $profilePath `
        -ItemType File `
        -ErrorAction Stop
}
```

Open it in Visual Studio Code if available:

```powershell
if (Get-Command code -ErrorAction SilentlyContinue) {
    code $profilePath
}
else {
    notepad.exe $profilePath
}
```

### The Verification

Confirm the file exists:

```powershell
Test-Path `
    -LiteralPath $profilePath `
    -PathType Leaf
```

Expected result:

```text
True
```

Check its syntax before making changes:

```powershell
$tokens = $null
$parseErrors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $profilePath,
    [ref] $tokens,
    [ref] $parseErrors
) | Out-Null

$parseErrors
```

No output means the current profile contains no parser errors.

---

## 4.23 Add Safe Developer Functions to the Profile

### The Target

Add reusable functions for:

- Navigating to the series root
- Navigating to the service
- Running the quality gate
- Displaying public configuration
- Starting development mode

### The Concept

A function is safer than a fragile alias when an operation needs validation or multiple commands.

For example, an alias can shorten one command name, but a function can:

1. Construct a portable path.
2. Verify that the directory exists.
3. Navigate there.
4. Throw a useful error if setup is incomplete.

The profile functions will not store or load `APP_SECRET`. The application’s `.env` file remains responsible for local project configuration.

### The Implementation

First, define the exact profile block in the current session:

```powershell
$profileBlockStart = "# BEGIN CLI DEVELOPER ENVIRONMENT SERIES"
$profileBlockEnd = "# END CLI DEVELOPER ENVIRONMENT SERIES"
```

Create the complete block:

```powershell
$profileBlock = @'
# BEGIN CLI DEVELOPER ENVIRONMENT SERIES

function Enter-CliDeveloperSeries {
    [CmdletBinding()]
    param()

    $seriesRoot = Join-Path `
        -Path $HOME `
        -ChildPath "cli-developer-environment-series"

    if (-not (
        Test-Path `
            -LiteralPath $seriesRoot `
            -PathType Container
    )) {
        throw "Series directory does not exist: $seriesRoot"
    }

    Set-Location -LiteralPath $seriesRoot
}

function Enter-DeveloperService {
    [CmdletBinding()]
    param()

    $projectRoot = Join-Path `
        -Path $HOME `
        -ChildPath "cli-developer-environment-series\developer-service"

    if (-not (
        Test-Path `
            -LiteralPath $projectRoot `
            -PathType Container
    )) {
        throw "Developer service does not exist: $projectRoot"
    }

    Set-Location -LiteralPath $projectRoot
}

function Invoke-DeveloperServiceCheck {
    [CmdletBinding()]
    param()

    Enter-DeveloperService

    if (-not (
        Test-Path `
            -LiteralPath .\package.json `
            -PathType Leaf
    )) {
        throw "package.json is missing from the developer service."
    }

    npm.cmd run check

    if ($LASTEXITCODE -ne 0) {
        throw "The developer-service quality gate failed."
    }
}

function Show-DeveloperServiceConfig {
    [CmdletBinding()]
    param()

    Enter-DeveloperService

    npm.cmd run config

    if ($LASTEXITCODE -ne 0) {
        throw "Configuration validation failed."
    }
}

function Start-DeveloperService {
    [CmdletBinding()]
    param()

    Enter-DeveloperService

    npm.cmd run dev

    if ($LASTEXITCODE -ne 0) {
        throw "The development service exited with an error."
    }
}

Set-Alias `
    -Name cds `
    -Value Enter-CliDeveloperSeries

Set-Alias `
    -Name devservice `
    -Value Enter-DeveloperService

# END CLI DEVELOPER ENVIRONMENT SERIES
'@
```

Prevent duplicate blocks:

```powershell
$currentProfileContent = Get-Content `
    -LiteralPath $profilePath `
    -Raw `
    -ErrorAction SilentlyContinue

if ($null -eq $currentProfileContent) {
    $currentProfileContent = ""
}

if ($currentProfileContent.Contains($profileBlockStart)) {
    throw (
        "The tutorial profile block already exists. " +
        "Edit the existing block instead of appending a duplicate."
    )
}
```

Append the block:

```powershell
Add-Content `
    -LiteralPath $profilePath `
    -Value "`n$profileBlock" `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Parse the updated profile:

```powershell
$tokens = $null
$parseErrors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $profilePath,
    [ref] $tokens,
    [ref] $parseErrors
) | Out-Null

$parseErrors |
    Format-List
```

No output means no parser errors were found.

Load the profile into the current session:

```powershell
. $profilePath
```

The leading dot is the **dot-sourcing operator**. It executes the script in the current scope so its functions remain available afterward.

Confirm the functions and aliases:

```powershell
Get-Command `
    Enter-CliDeveloperSeries,
    Enter-DeveloperService,
    Invoke-DeveloperServiceCheck,
    Show-DeveloperServiceConfig,
    Start-DeveloperService,
    cds,
    devservice |
    Select-Object Name, CommandType, Definition
```

---

## 4.24 Use the New Profile Functions

### The Target

Verify that profile commands work in the current session and a new PowerShell session.

### The Concept

A profile is useful only if new sessions can load it successfully.

A syntax error in a profile can affect every future terminal, so both parser validation and real-session testing matter.

### The Implementation

Navigate to the series root:

```powershell
Enter-CliDeveloperSeries
Get-Location
```

Navigate to the service:

```powershell
Enter-DeveloperService
Get-Location
```

Use the aliases:

```powershell
cds
devservice
```

Display public configuration:

```powershell
Show-DeveloperServiceConfig
```

Run the quality gate:

```powershell
Invoke-DeveloperServiceCheck
```

Start a clean PowerShell child process and verify function availability.

For PowerShell 7:

```powershell
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    pwsh `
        -Command @'
$commands = @(
    "Enter-CliDeveloperSeries"
    "Enter-DeveloperService"
    "Invoke-DeveloperServiceCheck"
    "Show-DeveloperServiceConfig"
    "Start-DeveloperService"
)

foreach ($commandName in $commands) {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Command = $commandName
        Loaded = $null -ne $command
    }
}
'@
}
```

For Windows PowerShell:

```powershell
powershell.exe `
    -Command "Get-Command Enter-DeveloperService"
```

### The Verification

Confirm the aliases:

```powershell
[PSCustomObject]@{
    CdsTarget = (Get-Alias cds).Definition
    DevServiceTarget = (Get-Alias devservice).Definition
}
```

Expected result:

```text
CdsTarget        : Enter-CliDeveloperSeries
DevServiceTarget : Enter-DeveloperService
```

Confirm that the profile contains no secret names or values:

```powershell
$profileText = Get-Content `
    -LiteralPath $profilePath `
    -Raw

$profileContainsSecretVariable = $profileText -match "(?i)APP_SECRET"

if ($profileContainsSecretVariable) {
    throw "The profile must not contain APP_SECRET."
}

Write-Host "The profile contains no APP_SECRET reference." -ForegroundColor Green
```

> The profile deliberately does not set `NODE_ENV`, `HOST`, `PORT`, or `APP_SECRET`. Global profile values can leak into unrelated Node.js projects and unexpectedly override their local configuration.

---

## 4.25 Make Profile Updates Idempotent

### The Target

Create a reusable script that safely installs or replaces the tutorial’s marked profile block without duplicating it.

The script will be stored at:

```text
developer-service\scripts\Install-DeveloperProfile.ps1
```

### The Concept

The previous step refused to append a duplicate block. That protected the profile, but a reusable installer should also support updating the existing block.

The marked lines act like fences:

```text
# BEGIN CLI DEVELOPER ENVIRONMENT SERIES
...
# END CLI DEVELOPER ENVIRONMENT SERIES
```

The installer can replace only the content between those fences while preserving everything else in the user’s profile.

An operation that produces the same result when repeated is called **idempotent**.

### The Implementation

Create the complete installer.

### File: `developer-service/scripts/Install-DeveloperProfile.ps1`

```powershell
$profileInstallerPath = Join-Path `
    -Path $projectRoot `
    -ChildPath "scripts\Install-DeveloperProfile.ps1"

$profileInstallerContent = @'
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $ProfilePath = $PROFILE.CurrentUserCurrentHost
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$blockStart = "# BEGIN CLI DEVELOPER ENVIRONMENT SERIES"
$blockEnd = "# END CLI DEVELOPER ENVIRONMENT SERIES"

$profileBlock = @'
# BEGIN CLI DEVELOPER ENVIRONMENT SERIES

function Enter-CliDeveloperSeries {
    [CmdletBinding()]
    param()

    $seriesRoot = Join-Path `
        -Path $HOME `
        -ChildPath "cli-developer-environment-series"

    if (-not (
        Test-Path `
            -LiteralPath $seriesRoot `
            -PathType Container
    )) {
        throw "Series directory does not exist: $seriesRoot"
    }

    Set-Location -LiteralPath $seriesRoot
}

function Enter-DeveloperService {
    [CmdletBinding()]
    param()

    $projectRoot = Join-Path `
        -Path $HOME `
        -ChildPath "cli-developer-environment-series\developer-service"

    if (-not (
        Test-Path `
            -LiteralPath $projectRoot `
            -PathType Container
    )) {
        throw "Developer service does not exist: $projectRoot"
    }

    Set-Location -LiteralPath $projectRoot
}

function Invoke-DeveloperServiceCheck {
    [CmdletBinding()]
    param()

    Enter-DeveloperService

    if (-not (
        Test-Path `
            -LiteralPath .\package.json `
            -PathType Leaf
    )) {
        throw "package.json is missing from the developer service."
    }

    npm.cmd run check

    if ($LASTEXITCODE -ne 0) {
        throw "The developer-service quality gate failed."
    }
}

function Show-DeveloperServiceConfig {
    [CmdletBinding()]
    param()

    Enter-DeveloperService

    npm.cmd run config

    if ($LASTEXITCODE -ne 0) {
        throw "Configuration validation failed."
    }
}

function Start-DeveloperService {
    [CmdletBinding()]
    param()

    Enter-DeveloperService

    npm.cmd run dev

    if ($LASTEXITCODE -ne 0) {
        throw "The development service exited with an error."
    }
}

Set-Alias `
    -Name cds `
    -Value Enter-CliDeveloperSeries

Set-Alias `
    -Name devservice `
    -Value Enter-DeveloperService

# END CLI DEVELOPER ENVIRONMENT SERIES
'@

$profileDirectory = Split-Path `
    -Path $ProfilePath `
    -Parent

if (-not (
    Test-Path `
        -LiteralPath $profileDirectory `
        -PathType Container
)) {
    if ($PSCmdlet.ShouldProcess(
        $profileDirectory,
        "Create PowerShell profile directory"
    )) {
        $null = New-Item `
            -Path $profileDirectory `
            -ItemType Directory `
            -Force
    }
}

$currentContent = ""

if (Test-Path -LiteralPath $ProfilePath -PathType Leaf) {
    $currentContent = Get-Content `
        -LiteralPath $ProfilePath `
        -Raw
}

$escapedStart = [regex]::Escape($blockStart)
$escapedEnd = [regex]::Escape($blockEnd)

$blockPattern = (
    "(?ms)^" +
    $escapedStart +
    ".*?^" +
    $escapedEnd +
    "\s*"
)

if ($currentContent -match $blockPattern) {
    $updatedContent = [regex]::Replace(
        $currentContent,
        $blockPattern,
        $profileBlock + [Environment]::NewLine
    )
}
else {
    $separator = if (
        [string]::IsNullOrWhiteSpace($currentContent)
    ) {
        ""
    }
    else {
        [Environment]::NewLine +
        [Environment]::NewLine
    }

    $updatedContent = (
        $currentContent.TrimEnd() +
        $separator +
        $profileBlock +
        [Environment]::NewLine
    )
}

$tokens = $null
$parseErrors = $null

[System.Management.Automation.Language.Parser]::ParseInput(
    $updatedContent,
    [ref] $tokens,
    [ref] $parseErrors
) | Out-Null

if ($parseErrors.Count -gt 0) {
    $messages = (
        $parseErrors |
            ForEach-Object {
                $_.Message
            }
    ) -join [Environment]::NewLine

    throw "The generated profile content is invalid:$([Environment]::NewLine)$messages"
}

if (-not $PSCmdlet.ShouldProcess(
    $ProfilePath,
    "Install developer profile functions"
)) {
    return
}

if (Test-Path -LiteralPath $ProfilePath -PathType Leaf) {
    $backupPath = (
        $ProfilePath +
        "." +
        (Get-Date -Format "yyyyMMdd-HHmmss-fff") +
        ".backup"
    )

    Copy-Item `
        -LiteralPath $ProfilePath `
        -Destination $backupPath

    Write-Host "Created profile backup: $backupPath"
}

Set-Content `
    -LiteralPath $ProfilePath `
    -Value $updatedContent `
    -Encoding UTF8

Write-Host "Installed developer profile block: $ProfilePath"
'@

Set-Content `
    -LiteralPath $profileInstallerPath `
    -Value $profileInstallerContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

The outer here-string uses `@" ... "@`, while the script embedded inside it uses `@' ... '@`. Using different delimiter styles allows the profile block to remain intact.

Preview the installer:

```powershell
& $profileInstallerPath -WhatIf
```

Run it:

```powershell
& $profileInstallerPath
```

Run it a second time:

```powershell
& $profileInstallerPath
```

The second execution should replace the marked block rather than append another copy.

### The Verification

Count the opening and closing markers:

```powershell
$profileText = Get-Content `
    -LiteralPath $profilePath `
    -Raw

$startMarkerCount = (
    [regex]::Matches(
        $profileText,
        [regex]::Escape(
            "# BEGIN CLI DEVELOPER ENVIRONMENT SERIES"
        )
    )
).Count

$endMarkerCount = (
    [regex]::Matches(
        $profileText,
        [regex]::Escape(
            "# END CLI DEVELOPER ENVIRONMENT SERIES"
        )
    )
).Count

[PSCustomObject]@{
    OneStartMarker = $startMarkerCount -eq 1
    OneEndMarker = $endMarkerCount -eq 1
}
```

Both values should be `True`.

Parse the installed profile:

```powershell
$tokens = $null
$parseErrors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $profilePath,
    [ref] $tokens,
    [ref] $parseErrors
) | Out-Null

if ($parseErrors.Count -gt 0) {
    $parseErrors |
        Format-List

    throw "The installed profile contains parser errors."
}

Write-Host "The installed profile parsed successfully." -ForegroundColor Green
```

Reload it:

```powershell
. $profilePath
```

---

## 4.26 Create a PowerShell Production Smoke-Test Wrapper

### The Target

Create:

```text
developer-service\scripts\Test-ProductionService.ps1
```

The script will:

- Generate a temporary production secret
- Start the built service with isolated process variables
- Poll its health endpoint
- Validate production mode
- Stop the process
- Avoid modifying the caller’s environment

### The Concept

Setting `$env:` changes the current PowerShell process and affects later child processes. For reusable automation, it is often safer to build an environment map for one child process only.

This is like handing one employee a sealed instruction packet instead of writing production credentials on the shared office whiteboard.

### The Implementation

Create the complete script.

### File: `developer-service/scripts/Test-ProductionService.ps1`

```powershell
$productionTestScriptPath = Join-Path `
    -Path $projectRoot `
    -ChildPath "scripts\Test-ProductionService.ps1"

$productionTestScriptContent = @'
[CmdletBinding()]
param(
    [ValidateRange(1, 65535)]
    [int] $Port = 43128,

    [ValidateRange(1, 60)]
    [int] $TimeoutSeconds = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = Split-Path `
    -Path $PSScriptRoot `
    -Parent

$entryPoint = Join-Path `
    -Path $projectRoot `
    -ChildPath "dist\index.js"

if (-not (
    Test-Path `
        -LiteralPath $entryPoint `
        -PathType Leaf
)) {
    throw "Build output is missing. Run npm.cmd run build first."
}

$nodePath = (
    Get-Command node -ErrorAction Stop
).Source

$secretBytes = New-Object byte[] 32

[System.Security.Cryptography.RandomNumberGenerator]::Fill(
    $secretBytes
)

$temporarySecret = (
    $secretBytes |
        ForEach-Object {
            $_.ToString("x2")
        }
) -join ""

$processStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
$processStartInfo.FileName = $nodePath
$processStartInfo.WorkingDirectory = $projectRoot
$processStartInfo.UseShellExecute = $false
$processStartInfo.RedirectStandardOutput = $true
$processStartInfo.RedirectStandardError = $true
$processStartInfo.CreateNoWindow = $true
$processStartInfo.ArgumentList.Add($entryPoint)

$processStartInfo.Environment["NODE_ENV"] = "production"
$processStartInfo.Environment["HOST"] = "127.0.0.1"
$processStartInfo.Environment["PORT"] = [string] $Port
$processStartInfo.Environment["APP_SECRET"] = $temporarySecret

$serviceProcess = [System.Diagnostics.Process]::new()
$serviceProcess.StartInfo = $processStartInfo

try {
    if (-not $serviceProcess.Start()) {
        throw "The Node.js service process could not be started."
    }

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $health = $null

    while ((Get-Date) -lt $deadline) {
        if ($serviceProcess.HasExited) {
            $standardError = $serviceProcess.StandardError.ReadToEnd()

            throw (
                "The service exited before becoming healthy. " +
                "Exit code: $($serviceProcess.ExitCode). " +
                "Error: $standardError"
            )
        }

        try {
            $health = Invoke-RestMethod `
                -Uri "http://127.0.0.1:$Port/health" `
                -Method Get `
                -TimeoutSec 1 `
                -ErrorAction Stop

            if (
                $health.status -eq "ok" -and
                $health.environment -eq "production"
            ) {
                break
            }
        }
        catch {
            Start-Sleep -Milliseconds 250
        }
    }

    if (
        $null -eq $health -or
        $health.status -ne "ok" -or
        $health.environment -ne "production"
    ) {
        throw "The production service did not become healthy."
    }

    [PSCustomObject]@{
        Status = $health.status
        Environment = $health.environment
        Port = $Port
        ProcessId = $serviceProcess.Id
        Passed = $true
    }
}
finally {
    $temporarySecret = $null
    $secretBytes = $null

    if (
        $null -ne $serviceProcess -and
        -not $serviceProcess.HasExited
    ) {
        $serviceProcess.Kill($true)
        $serviceProcess.WaitForExit(5000)
    }

    $serviceProcess.Dispose()
}
'@

Set-Content `
    -LiteralPath $productionTestScriptPath `
    -Value $productionTestScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Build the service:

```powershell
npm.cmd run build
```

Run the PowerShell smoke test:

```powershell
& $productionTestScriptPath
```

### The Verification

Capture and inspect the result:

```powershell
$productionSmokeResult = & $productionTestScriptPath `
    -Port 43129

$productionSmokeResult |
    Format-List
```

Expected properties include:

```text
Status      : ok
Environment : production
Port        : 43129
Passed      : True
```

Confirm the script did not populate the caller’s environment:

```powershell
[PSCustomObject]@{
    NODE_ENVUnaffected = -not (Test-Path Env:NODE_ENV)
    HOSTUnaffected = -not (Test-Path Env:HOST)
    PORTUnaffected = -not (Test-Path Env:PORT)
    APP_SECRETUnaffected = -not (Test-Path Env:APP_SECRET)
}
```

Every value should be `True`, assuming those variables were absent before the test.

---

# Part 4 Reference A: Environment Variable Operations

## List all process environment variables

```powershell
Get-ChildItem Env:
```

## Read one variable

```powershell
$env:NODE_ENV
```

or:

```powershell
Get-Item Env:NODE_ENV
```

## Set a process-scoped variable

```powershell
$env:NODE_ENV = "development"
```

## Remove a process-scoped variable

```powershell
Remove-Item `
    Env:NODE_ENV `
    -ErrorAction SilentlyContinue
```

or:

```powershell
$env:NODE_ENV = $null
```

## Read a persistent user variable

```powershell
[System.Environment]::GetEnvironmentVariable(
    "EXAMPLE_NAME",
    [System.EnvironmentVariableTarget]::User
)
```

## Set a persistent user variable

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "example-value",
    [System.EnvironmentVariableTarget]::User
)
```

## Remove a persistent user variable

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    $null,
    [System.EnvironmentVariableTarget]::User
)
```

## Machine-scoped variables

Machine scope typically requires administrative permission:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "example-value",
    [System.EnvironmentVariableTarget]::Machine
)
```

Do not use machine scope when process or user scope is sufficient.

---

# Part 4 Reference B: Environment Inheritance

When PowerShell starts, it receives an environment from its parent process. When PowerShell starts Node.js, Node.js receives a copy of PowerShell’s current environment.

```text
Windows environment
        │
        ▼
PowerShell process
        │
        ▼
Node.js child process
```

A child cannot normally modify its parent’s environment.

For example:

```powershell
node -e 'process.env.CHILD_ONLY = "value";'
$env:CHILD_ONLY
```

The PowerShell variable remains absent because the child’s environment change disappears with the child process.

Similarly, changing a persistent user variable does not automatically alter already-running processes. Open a new terminal or explicitly copy the persistent value into the current process.

---

# Part 4 Reference C: `.env` Syntax

A `.env` file commonly contains:

```dotenv
NODE_ENV=development
HOST=127.0.0.1
PORT=3000
APP_SECRET=a-long-random-development-secret
```

## Comments

```dotenv
# This is a comment.
PORT=3000
```

## Quoted values

```dotenv
MESSAGE="A value containing spaces"
```

## Empty values

```dotenv
OPTIONAL_VALUE=
```

An empty value is still a value. The configuration module rejects empty required variables.

## Avoid unnecessary quoting

For simple hostnames, ports, and random alphanumeric secrets:

```dotenv
HOST=127.0.0.1
PORT=3000
```

is clear and sufficient.

## Do not use PowerShell syntax inside `.env`

Incorrect:

```text
$env:PORT = "3000"
```

Correct:

```dotenv
PORT=3000
```

A `.env` file is not a PowerShell script.

---

# Part 4 Reference D: Configuration Precedence

The project uses:

```javascript
dotenv.config({
  override: false,
});
```

Therefore:

```text
1. Existing process environment value
2. .env value when the process value is missing
3. Validation error when neither supplies a required value
```

Example:

```dotenv
# .env
PORT=3000
```

PowerShell override:

```powershell
$env:PORT = "3200"
node .\src\index.js
```

The application uses `3200`.

After removal:

```powershell
Remove-Item Env:PORT
node .\src\index.js
```

The application uses `3000`.

This arrangement allows local convenience while preserving deployment control.

---

# Part 4 Reference E: Secrets and `.gitignore`

## Files to commit

```text
.env.example
.gitignore
src/config.js
```

## File not to commit

```text
.env
```

## A safe `.env.example`

```dotenv
APP_SECRET=replace-with-a-unique-secret
```

## An unsafe `.env.example`

```dotenv
APP_SECRET=actual-production-value
```

## If a secret is committed

Ignoring it later is not enough. Git history may still contain it.

Treat the secret as compromised:

1. Revoke or rotate it.
2. Replace it in active environments.
3. Remove it from current files.
4. Follow an approved history-cleanup process.
5. Notify the appropriate security or operations team.

## Better production secret sources

A production system may use:

- Azure Key Vault
- AWS Secrets Manager
- Google Cloud Secret Manager
- HashiCorp Vault
- Kubernetes Secrets with appropriate encryption controls
- A CI/CD platform’s protected secret store

A local `.env` file is a developer convenience—not an enterprise secret-management system.

---

# Part 4 Reference F: Configuration Validation Principles

A strong configuration boundary should:

- Require mandatory variables
- Reject empty strings
- Convert types explicitly
- Enforce numeric ranges
- Restrict enumerated values
- Reject documented placeholders
- Apply stricter production rules where appropriate
- Return immutable configuration
- Avoid exposing secrets in logs
- Fail before opening network listeners

This project converts:

```text
PORT="3000"
```

into:

```javascript
port: 3000
```

It restricts:

```text
NODE_ENV
```

to:

```text
development
test
production
```

It also removes `appSecret` from public diagnostic output.

---

# Part 4 Reference G: PowerShell Profile Scope

Inspect profile paths:

```powershell
$PROFILE |
    Format-List *
```

Common properties include:

```text
CurrentUserCurrentHost
CurrentUserAllHosts
AllUsersCurrentHost
AllUsersAllHosts
```

## Current user, current host

```powershell
$PROFILE.CurrentUserCurrentHost
```

Applies to the current user and current PowerShell host.

## Current user, all hosts

```powershell
$PROFILE.CurrentUserAllHosts
```

May be loaded by several hosts for the current user.

## All users

All-user profiles may require administrator privileges and affect other accounts. They are not appropriate for ordinary personal shortcuts.

## Reload the profile

```powershell
. $PROFILE
```

## Start without profiles

Useful for troubleshooting:

```powershell
pwsh -NoProfile
```

or:

```powershell
powershell.exe -NoProfile
```

---

# Part 4 Reference H: Aliases Versus Functions

Use an alias when shortening one command name:

```powershell
Set-Alias `
    -Name cds `
    -Value Enter-CliDeveloperSeries
```

Use a function when logic is required:

```powershell
function Enter-DeveloperService {
    $projectRoot = Join-Path `
        -Path $HOME `
        -ChildPath "cli-developer-environment-series\developer-service"

    if (-not (
        Test-Path `
            -LiteralPath $projectRoot `
            -PathType Container
    )) {
        throw "Project not found: $projectRoot"
    }

    Set-Location -LiteralPath $projectRoot
}
```

PowerShell aliases point to command names, not arbitrary command strings. This is not a reliable alias definition:

```text
Set-Alias build "npm run build"
```

Instead, define a function:

```powershell
function Invoke-ProjectBuild {
    npm.cmd run build
}
```

---

# Part 4 Reference I: Common Configuration Mistakes

## Mistake 1: Hardcoding secrets

Unsafe:

```javascript
const secret = "production-secret";
```

Use validated external configuration:

```javascript
const secret = process.env.APP_SECRET;
```

## Mistake 2: Committing `.env`

Ensure `.gitignore` contains:

```gitignore
.env
.env.*
!.env.example
```

## Mistake 3: Printing the complete configuration

Unsafe:

```javascript
console.log(process.env);
```

This can expose credentials.

Use a public projection:

```javascript
console.log({
  environment: configuration.environment,
  host: configuration.host,
  port: configuration.port,
});
```

## Mistake 4: Treating `process.env.PORT` as a number

It is a string:

```javascript
typeof process.env.PORT === "string"
```

Validate and convert it before use.

## Mistake 5: Silently accepting invalid values

Avoid accidental fallback patterns such as:

```javascript
const port = Number(process.env.PORT) || 3000;
```

This hides invalid values such as `"not-a-port"`.

Reject malformed values explicitly.

## Mistake 6: Setting project variables globally in `$PROFILE`

Avoid:

```powershell
$env:NODE_ENV = "production"
$env:APP_SECRET = "..."
```

Those values affect unrelated child processes and can override `.env` unexpectedly.

## Mistake 7: Assuming hidden files are secure

A `.env` file may be hidden by convention, but it is ordinary plaintext. File visibility is not encryption.

## Mistake 8: Persisting secrets as ordinary user variables unnecessarily

Persistent environment variables are visible to processes running as that user. Use an approved secret manager for sensitive production credentials.

---

# Part 4 Reference J: Compact Command Cookbook

## Inspect environment variables

```powershell
Get-ChildItem Env:
```

## Set a temporary variable

```powershell
$env:PORT = "3000"
```

## Remove it

```powershell
Remove-Item Env:PORT
```

## Read a user-scoped variable

```powershell
[System.Environment]::GetEnvironmentVariable(
    "PORT",
    [System.EnvironmentVariableTarget]::User
)
```

## Set a user-scoped variable

```powershell
[System.Environment]::SetEnvironmentVariable(
    "PORT",
    "3000",
    [System.EnvironmentVariableTarget]::User
)
```

## Install dotenv

```powershell
npm.cmd install dotenv
```

## Show public configuration

```powershell
npm.cmd run config
```

## Validate all project behavior

```powershell
npm.cmd run check
```

## Run local development mode

```powershell
npm.cmd run dev
```

## Run production mode with session variables

```powershell
$env:NODE_ENV = "production"
$env:HOST = "127.0.0.1"
$env:PORT = "8080"
$env:APP_SECRET = "supply-a-random-secret-of-at-least-32-characters"

npm.cmd start
```

Remove the values afterward:

```powershell
Remove-Item Env:NODE_ENV, Env:HOST, Env:PORT, Env:APP_SECRET
```

## Find the PowerShell profile

```powershell
$PROFILE.CurrentUserCurrentHost
```

## Reload it

```powershell
. $PROFILE.CurrentUserCurrentHost
```

---

# Part 4 Final Verification

## The Target

Verify the complete developer environment and production-conscious local service.

### The Concept

The final checkpoint verifies the full architecture rather than one isolated command.

It checks:

- Project files
- Runtime dependencies
- Secret exclusion
- Configuration behavior
- Tests and linting
- Build output
- Smoke tests
- Profile installation
- Absence of leaked session variables

### The Implementation

Reconstruct important paths:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$projectRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "developer-service"

$profilePath = $PROFILE.CurrentUserCurrentHost

Set-Location -LiteralPath $projectRoot
```

Install dependencies exactly from the lockfile:

```powershell
npm.cmd ci
```

Run the complete quality gate:

```powershell
npm.cmd run check
```

Capture its result immediately:

```powershell
$qualityGatePassed = $LASTEXITCODE -eq 0
```

Run the production PowerShell smoke test:

```powershell
$productionSmokeResult = & .\scripts\Test-ProductionService.ps1 `
    -Port 43130
```

Parse the manifest:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json
```

Check Git behavior when available:

```powershell
$envIsIgnored = $false
$exampleIsTrackable = $false

if (Get-Command git -ErrorAction SilentlyContinue) {
    git check-ignore -q .env
    $envIsIgnored = $LASTEXITCODE -eq 0

    git check-ignore -q .env.example
    $exampleIsTrackable = $LASTEXITCODE -ne 0
}
else {
    $gitIgnoreText = Get-Content `
        -LiteralPath .\.gitignore `
        -Raw

    $envIsIgnored = $gitIgnoreText -match "(?m)^\.env$"
    $exampleIsTrackable = (
        $gitIgnoreText -match "(?m)^!\.env\.example$"
    )
}
```

Build the final checks:

```powershell
$finalChecks = @(
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
        Check = "dotenv is a runtime dependency"
        Passed = $null -ne $packageData.dependencies.dotenv
    }

    [PSCustomObject]@{
        Check = "Express is a runtime dependency"
        Passed = $null -ne $packageData.dependencies.express
    }

    [PSCustomObject]@{
        Check = ".env exists locally"
        Passed = Test-Path `
            -LiteralPath .\.env `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = ".env.example exists"
        Passed = Test-Path `
            -LiteralPath .\.env.example `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = ".env is ignored"
        Passed = $envIsIgnored
    }

    [PSCustomObject]@{
        Check = ".env.example is trackable"
        Passed = $exampleIsTrackable
    }

    [PSCustomObject]@{
        Check = "Configuration module exists"
        Passed = Test-Path `
            -LiteralPath .\src\config.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Configuration tests exist"
        Passed = Test-Path `
            -LiteralPath .\test\config.test.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Configuration inspection script exists"
        Passed = Test-Path `
            -LiteralPath .\scripts\show-config.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Node.js smoke test exists"
        Passed = Test-Path `
            -LiteralPath .\scripts\smoke-test.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "PowerShell production test exists"
        Passed = Test-Path `
            -LiteralPath .\scripts\Test-ProductionService.ps1 `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Profile installer exists"
        Passed = Test-Path `
            -LiteralPath .\scripts\Install-DeveloperProfile.ps1 `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Generated configuration exists"
        Passed = Test-Path `
            -LiteralPath .\dist\config.js `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Generated application exists"
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
        Check = "Quality gate passed"
        Passed = $qualityGatePassed
    }

    [PSCustomObject]@{
        Check = "Production smoke test passed"
        Passed = $productionSmokeResult.Passed -eq $true
    }

    [PSCustomObject]@{
        Check = "PowerShell profile exists"
        Passed = Test-Path `
            -LiteralPath $profilePath `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "No APP_SECRET remains in this session"
        Passed = -not (
            Test-Path Env:APP_SECRET
        )
    }
)

$finalChecks |
    Format-Table Check, Passed -AutoSize
```

Validate that public configuration does not reveal the secret:

```powershell
$publicConfigurationOutput = npm.cmd run config --silent

$publicConfigurationIsSafe = -not (
    ($publicConfigurationOutput -join "`n") -match
    "(?i)APP_SECRET|appSecret"
)

[PSCustomObject]@{
    Check = "Public configuration excludes secret fields"
    Passed = $publicConfigurationIsSafe
} |
    Format-Table -AutoSize
```

Validate the profile markers and syntax:

```powershell
$profileContent = Get-Content `
    -LiteralPath $profilePath `
    -Raw

$profileMarkerCheck = (
    $profileContent -match
    [regex]::Escape(
        "# BEGIN CLI DEVELOPER ENVIRONMENT SERIES"
    )
) -and (
    $profileContent -match
    [regex]::Escape(
        "# END CLI DEVELOPER ENVIRONMENT SERIES"
    )
)

$profileTokens = $null
$profileParseErrors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $profilePath,
    [ref] $profileTokens,
    [ref] $profileParseErrors
) | Out-Null

$profileSyntaxCheck = $profileParseErrors.Count -eq 0
```

### The Verification

Combine every result:

```powershell
$allFinalChecks = @(
    $finalChecks

    [PSCustomObject]@{
        Check = "Public configuration excludes secret fields"
        Passed = $publicConfigurationIsSafe
    }

    [PSCustomObject]@{
        Check = "Profile contains tutorial markers"
        Passed = $profileMarkerCheck
    }

    [PSCustomObject]@{
        Check = "Profile syntax is valid"
        Passed = $profileSyntaxCheck
    }

    [PSCustomObject]@{
        Check = "Profile does not contain APP_SECRET"
        Passed = -not (
            $profileContent -match "(?i)APP_SECRET"
        )
    }
)
```

Find failures:

```powershell
$failedFinalChecks = @(
    $allFinalChecks |
        Where-Object {
            -not $_.Passed
        }
)
```

Report the final result:

```powershell
$allFinalChecks |
    Format-Table Check, Passed -AutoSize

if ($failedFinalChecks.Count -eq 0) {
    Write-Host (
        "Part 4 final verification passed. " +
        "The complete developer environment is ready."
    ) -ForegroundColor Green
}
else {
    Write-Host "Part 4 final verification failed." -ForegroundColor Red

    $failedFinalChecks |
        Format-Table Check, Passed -AutoSize

    throw "Repair the failed checks before considering the build complete."
}
```

Expected final message:

```text
Part 4 final verification passed. The complete developer environment is ready.
```

---

# Part 4 Key Takeaways

## PowerShell environment variables

You can inspect environment variables through the provider:

```powershell
Get-ChildItem Env:
```

You can create a session-scoped variable:

```powershell
$env:NODE_ENV = "development"
```

You can remove it:

```powershell
Remove-Item Env:NODE_ENV
```

Values in the current PowerShell environment are inherited by child processes such as Node.js.

## Persistent Windows variables

You can persist a user-level value with:

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    "example-value",
    [System.EnvironmentVariableTarget]::User
)
```

Existing processes do not automatically receive later persistent changes. A new terminal receives the updated environment, or the current process must be updated explicitly.

## Local application configuration

The service loads local values from:

```text
.env
```

The safe documentation template is:

```text
.env.example
```

The precedence rule is:

```text
existing process variable > .env fallback
```

## Secret handling

You kept `.env` out of Git and verified that `.env.example` remains trackable.

The application:

- Requires `APP_SECRET`
- Rejects empty values
- Rejects documented placeholders
- Requires a longer secret in production
- Never includes the secret in public configuration
- Does not store the secret in the PowerShell profile

A local `.env` file is convenient, but a production secret manager is preferable for deployed systems.

## Runtime validation

The configuration module converts untrusted strings into validated application values.

It rejects:

- Missing variables
- Unsupported runtime modes
- Empty hosts
- Hosts containing whitespace
- Nonnumeric ports
- Ports outside `1` through `65535`
- Missing or short secrets
- Placeholder secrets

The service fails before opening its network port when configuration is invalid.

## Application composition

The final startup sequence is:

```text
load .env fallback
        ↓
read process environment
        ↓
validate and convert
        ↓
create immutable configuration
        ↓
construct Express application
        ↓
open HTTP server
```

## Quality and production checks

The final quality gate runs:

```text
lint → automated tests → build → smoke test
```

Execute it with:

```powershell
npm.cmd run check
```

The separate PowerShell smoke test confirms that the built service can start in production mode with isolated environment variables.

## PowerShell profile customization

You added reusable functions for:

- Entering the series directory
- Entering the service directory
- Running the quality gate
- Displaying public configuration
- Starting development mode

You also created an idempotent installer that updates one marked profile block while preserving unrelated profile content.

---

## Part 4 Completion Checklist

- [ ] Inspect variables with `Get-ChildItem Env:`
- [ ] Read variables with `$env:NAME`
- [ ] Set a session-scoped variable
- [ ] Remove a session-scoped variable
- [ ] Explain process, user, and machine scope
- [ ] Set and remove a persistent user variable
- [ ] Explain environment inheritance
- [ ] Install `dotenv`
- [ ] Create `.env.example` without real secrets
- [ ] Create a random local development secret
- [ ] Exclude `.env` from Git
- [ ] Verify `.env.example` remains trackable
- [ ] Validate `NODE_ENV`
- [ ] Validate and convert `PORT`
- [ ] Validate `HOST`
- [ ] Require `APP_SECRET`
- [ ] Apply stricter production secret rules
- [ ] Preserve environment-over-`.env` precedence
- [ ] Avoid printing secrets
- [ ] Test invalid configuration
- [ ] Run the service in development mode
- [ ] Run it with production variables
- [ ] Execute the full quality gate
- [ ] Run an actual built-service smoke test
- [ ] Locate and back up `$PROFILE`
- [ ] Add reusable profile functions
- [ ] Keep project secrets out of the profile
- [ ] Validate profile syntax
- [ ] Load and use profile functions
- [ ] Install profile updates idempotently

---

# Final Production-Conscious Architecture

The completed project now resembles:

```text
$HOME/
└── cli-developer-environment-series/
    ├── filesystem-lab/
    │   ├── archive/
    │   ├── documents/
    │   ├── incoming/
    │   ├── workspace/
    │   └── file-operations-lab/
    │
    ├── part-1-scripts/
    │   └── Get-DirectoryReport.ps1
    │
    ├── part-2-scripts/
    │   ├── New-VerifiedArchive.ps1
    │   └── Remove-LabItemSafely.ps1
    │
    └── developer-service/
        ├── dist/
        │   ├── app.js
        │   ├── config.js
        │   └── index.js
        │
        ├── node_modules/
        │   └── ...
        │
        ├── scripts/
        │   ├── build.js
        │   ├── clean.js
        │   ├── Install-DeveloperProfile.ps1
        │   ├── show-config.js
        │   ├── smoke-test.js
        │   └── Test-ProductionService.ps1
        │
        ├── src/
        │   ├── app.js
        │   ├── config.js
        │   └── index.js
        │
        ├── test/
        │   ├── config.test.js
        │   └── server.test.js
        │
        ├── .env
        ├── .env.example
        ├── .gitignore
        ├── eslint.config.js
        ├── package-lock.json
        └── package.json
```

The PowerShell profile additionally provides:

```text
Enter-CliDeveloperSeries
Enter-DeveloperService
Invoke-DeveloperServiceCheck
Show-DeveloperServiceConfig
Start-DeveloperService
cds
devservice
```

The final local workflow is:

```powershell
devservice
Show-DeveloperServiceConfig
Invoke-DeveloperServiceCheck
Start-DeveloperService
```

The final production-style validation workflow is:

```powershell
devservice
npm.cmd ci
npm.cmd run check
& .\scripts\Test-ProductionService.ps1
```

This architecture is production-conscious because it separates:

- Source code from generated output
- Runtime dependencies from development tools
- Public configuration from secrets
- Local `.env` convenience from deployment-injected values
- Application construction from network startup
- Interactive shortcuts from project-specific credentials
- Fast development startup from production verification

It also verifies behavior at multiple levels:

```text
static analysis
      ↓
configuration tests
      ↓
HTTP integration tests
      ↓
build validation
      ↓
built-service smoke test
      ↓
production-mode process test
```

[GENERATED: Part 4: Environment Variables and Runtime Configuration] [GENERATED: Final Production-Conscious Architecture] [SERIES COMPLETE]


