# References and Resources  
## PowerShell CLI, Node.js, HTTP, Configuration, and Security

This guide prioritizes primary sources maintained by Microsoft, Node.js, npm, Git, MDN, OWASP, and the relevant library authors.

> Software commands, supported versions, and installation procedures change over time. Check release and support pages before selecting versions for a new project. Prefer supported LTS releases for training and production work.

---

# 1. PowerShell

## Official documentation

### PowerShell documentation home

- [Microsoft Learn: PowerShell Documentation](https://learn.microsoft.com/powershell/)

Use this as the main entry point for:

- Installation
- Language syntax
- Cmdlet reference
- Scripting
- Security
- Modules
- Version-specific behavior

### Installing PowerShell on Windows

- [Installing PowerShell on Windows](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows)

### PowerShell release information

- [PowerShell releases on GitHub](https://github.com/PowerShell/PowerShell/releases)
- [PowerShell support lifecycle](https://learn.microsoft.com/powershell/scripting/install/powershell-support-lifecycle)

---

## Essential PowerShell concepts

### About topics

PowerShell’s conceptual documentation uses names beginning with `about_`.

- [About topics index](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/)
- [`about_PowerShell_Editions`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_powershell_editions)
- [`about_Command_Syntax`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_command_syntax)
- [`about_Parameters`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parameters)
- [`about_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_variables)
- [`about_Arrays`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_arrays)
- [`about_Hash_Tables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_hash_tables)
- [`about_Objects`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_objects)
- [`about_Properties`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_properties)
- [`about_Methods`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_methods)
- [`about_Operators`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_operators)
- [`about_Comparison_Operators`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators)
- [`about_Logical_Operators`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_logical_operators)
- [`about_Quoting_Rules`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_quoting_rules)
- [`about_Special_Characters`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_special_characters)
- [`about_Comments`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comments)

---

## Pipelines and object processing

- [`about_Pipelines`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines)
- [`about_Automatic_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables)
- [`Where-Object`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/where-object)
- [`ForEach-Object`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/foreach-object)
- [`Select-Object`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/select-object)
- [`Sort-Object`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/sort-object)
- [`Group-Object`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/group-object)
- [`Measure-Object`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/measure-object)
- [`Get-Member`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-member)

Useful interactive pattern:

```powershell
Get-Item -LiteralPath .\package.json |
    Get-Member
```

---

## Command discovery and help

- [`Get-Command`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-command)
- [`Get-Help`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/get-help)
- [`Update-Help`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/update-help)
- [`Get-Alias`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-alias)
- [`about_Aliases`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_aliases)

Essential commands:

```powershell
Get-Command -Name Get-ChildItem
Get-Help -Name Get-ChildItem -Examples
Get-Help -Name Get-ChildItem -Parameter Recurse
Get-Member
```

---

# 2. PowerShell Filesystem and Path Operations

## Navigation

- [`Get-Location`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-location)
- [`Set-Location`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/set-location)
- [`Push-Location`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/push-location)
- [`Pop-Location`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/pop-location)
- [`Resolve-Path`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/resolve-path)
- [`Test-Path`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/test-path)
- [`Join-Path`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/join-path)
- [`Split-Path`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/split-path)
- [`Get-PSDrive`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-psdrive)
- [`about_Path_Syntax`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_path_syntax)
- [`about_Locations`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_locations)
- [`about_Providers`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_providers)

## File inspection

- [`Get-ChildItem`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem)
- [`Get-Item`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-item)
- [`Get-Content`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-content)

## File mutation

- [`New-Item`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/new-item)
- [`Set-Content`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/set-content)
- [`Add-Content`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/add-content)
- [`Clear-Content`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/clear-content)
- [`Copy-Item`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/copy-item)
- [`Move-Item`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/move-item)
- [`Rename-Item`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/rename-item)
- [`Remove-Item`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/remove-item)
- [`Get-FileHash`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)

## Wildcards

- [`about_Wildcards`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_wildcards)

## `-Path` versus `-LiteralPath`

Consult the parameter documentation for each filesystem cmdlet. The practical rule is:

```text
-Path        → allow wildcard interpretation
-LiteralPath → treat the supplied path exactly
```

Use `-LiteralPath` for one exact mutation whenever practical.

---

# 3. PowerShell Safety, Confirmation, and Error Handling

## `-WhatIf`, `-Confirm`, and common parameters

- [`about_CommonParameters`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_commonparameters)
- [`about_ShouldProcess`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_shouldprocess)
- [`about_Functions_CmdletBindingAttribute`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute)
- [`about_Functions_Advanced`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced)

Custom-function pattern:

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

Preview:

```powershell
Remove-ExampleItem `
    -LiteralPath .\example.txt `
    -WhatIf
```

## Error handling

- [`about_Try_Catch_Finally`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_try_catch_finally)
- [`about_Throw`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_throw)
- [`about_Preference_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables)

Recommended pattern:

```powershell
try {
    Copy-Item `
        -LiteralPath $source `
        -Destination $destination `
        -ErrorAction Stop
}
catch {
    Write-Error "Copy failed: $($_.Exception.Message)"
}
finally {
    # Restore temporary state or remove partial output.
}
```

## File attributes and reparse points

- [.NET `FileAttributes` enumeration](https://learn.microsoft.com/dotnet/api/system.io.fileattributes)
- [.NET `FileSystemInfo.Attributes`](https://learn.microsoft.com/dotnet/api/system.io.filesysteminfo.attributes)
- [Windows reparse points](https://learn.microsoft.com/windows/win32/fileio/reparse-points)

Remember that path-prefix checking is a guardrail, not a complete security sandbox. Symbolic links, junctions, reparse points, permissions, and concurrent filesystem changes require additional consideration.

---

# 4. PowerShell Scripting and Profiles

## Functions and scripts

- [`about_Functions`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions)
- [`about_Functions_Advanced`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced)
- [`about_Scripts`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_scripts)
- [`about_Splatting`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_splatting)
- [`about_Scopes`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_scopes)
- [`about_Parsing`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing)

## Profiles

- [`about_Profiles`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles)

Inspect profile paths:

```powershell
$PROFILE |
    Format-List *
```

Start without a profile:

```powershell
pwsh -NoProfile
```

Reload the current profile:

```powershell
. $PROFILE.CurrentUserCurrentHost
```

## Execution policies

- [`about_Execution_Policies`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- [`Get-ExecutionPolicy`](https://learn.microsoft.com/powershell/module/microsoft.powershell.security/get-executionpolicy)
- [`Set-ExecutionPolicy`](https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy)
- [`Unblock-File`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/unblock-file)

Inspect before changing anything:

```powershell
Get-ExecutionPolicy -List
Get-Command npm -All
```

Try the narrow Windows wrapper first:

```powershell
npm.cmd --version
npx.cmd --version
```

> An execution policy is a safety feature, not a full security boundary. Do not change organization-managed policy or apply a machine-wide unrestricted policy merely to run npm.

---

# 5. PowerShell Testing and Code Quality

## Pester

Pester is the primary PowerShell testing framework.

- [Pester documentation](https://pester.dev/)
- [Pester on GitHub](https://github.com/pester/Pester)
- [Pester on PowerShell Gallery](https://www.powershellgallery.com/packages/Pester)

Example:

```powershell
Describe "Path validation" {
    It "recognizes an existing file" {
        Test-Path `
            -LiteralPath $TestDrive\example.txt `
            -PathType Leaf |
            Should -BeTrue
    }
}
```

## PSScriptAnalyzer

PSScriptAnalyzer performs static analysis on PowerShell code.

- [PSScriptAnalyzer documentation](https://learn.microsoft.com/powershell/utility-modules/psscriptanalyzer/overview)
- [PSScriptAnalyzer on GitHub](https://github.com/PowerShell/PSScriptAnalyzer)
- [PSScriptAnalyzer on PowerShell Gallery](https://www.powershellgallery.com/packages/PSScriptAnalyzer)

Example:

```powershell
Invoke-ScriptAnalyzer `
    -Path .\scripts `
    -Recurse
```

## PowerShell Gallery

- [PowerShell Gallery](https://www.powershellgallery.com/)

Review module provenance, maintenance, documentation, and source before installation.

---

# 6. Node.js

## Official Node.js resources

- [Node.js documentation](https://nodejs.org/docs/latest/api/)
- [Node.js download page](https://nodejs.org/en/download)
- [Node.js release schedule](https://github.com/nodejs/Release)
- [Node.js releases](https://nodejs.org/en/about/previous-releases)
- [Node.js security releases](https://nodejs.org/en/blog/vulnerability/)

Use a supported LTS line for training and production unless a project has a specific requirement.

## Important Node.js API references

- [HTTP module](https://nodejs.org/api/http.html)
- [File system module](https://nodejs.org/api/fs.html)
- [File system promises API](https://nodejs.org/api/fs.html#promises-api)
- [Path module](https://nodejs.org/api/path.html)
- [Process object](https://nodejs.org/api/process.html)
- [Child processes](https://nodejs.org/api/child_process.html)
- [Crypto module](https://nodejs.org/api/crypto.html)
- [Buffer](https://nodejs.org/api/buffer.html)
- [URL API](https://nodejs.org/api/url.html)
- [CommonJS modules](https://nodejs.org/api/modules.html)
- [ECMAScript modules](https://nodejs.org/api/esm.html)
- [Environment variables](https://nodejs.org/api/environment_variables.html)
- [Node.js test runner](https://nodejs.org/api/test.html)
- [Assertions](https://nodejs.org/api/assert.html)
- [Command-line options](https://nodejs.org/api/cli.html)
- [Global `fetch`](https://nodejs.org/api/globals.html#fetch)

## Useful Node.js commands

```powershell
node --version
node --check .\src\index.js
node --test
node --watch .\src\index.js
```

---

# 7. JavaScript Language References

## MDN JavaScript Guide

- [MDN JavaScript Guide](https://developer.mozilla.org/docs/Web/JavaScript/Guide)
- [JavaScript reference](https://developer.mozilla.org/docs/Web/JavaScript/Reference)

## Essential topics

- [`const`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Statements/const)
- [`let`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Statements/let)
- [Data types](https://developer.mozilla.org/docs/Web/JavaScript/Guide/Data_structures)
- [Arrays](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Array)
- [Object basics](https://developer.mozilla.org/docs/Learn_web_development/Core/Scripting/Object_basics)
- [Functions](https://developer.mozilla.org/docs/Web/JavaScript/Guide/Functions)
- [Template literals](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Template_literals)
- [Strict equality](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Operators/Strict_equality)
- [Promises](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Promise)
- [`async function`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Statements/async_function)
- [`await`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Operators/await)
- [`try...catch`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Statements/try...catch)
- [`JSON.parse`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse)
- [`JSON.stringify`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify)
- [`Object.freeze`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Object/freeze)

## JavaScript specification

For language-level authority:

- [ECMAScript language specification](https://tc39.es/ecma262/)
- [TC39 proposals](https://github.com/tc39/proposals)

The specification is precise but not beginner-oriented. Start with MDN.

---

# 8. npm and Package Management

## Official npm documentation

- [npm documentation](https://docs.npmjs.com/)
- [`package.json`](https://docs.npmjs.com/cli/configuring-npm/package-json)
- [`package-lock.json`](https://docs.npmjs.com/cli/configuring-npm/package-lock-json)
- [`node_modules`](https://docs.npmjs.com/cli/configuring-npm/folders)
- [`npm install`](https://docs.npmjs.com/cli/commands/npm-install)
- [`npm ci`](https://docs.npmjs.com/cli/commands/npm-ci)
- [`npm run-script`](https://docs.npmjs.com/cli/commands/npm-run-script)
- [`npm init`](https://docs.npmjs.com/cli/commands/npm-init)
- [`npm exec` and npx](https://docs.npmjs.com/cli/commands/npm-exec)
- [`npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)
- [`npm outdated`](https://docs.npmjs.com/cli/commands/npm-outdated)
- [Dependency specification](https://docs.npmjs.com/specifying-dependencies-and-devdependencies-in-a-package-json-file)
- [Semantic versioning with npm](https://docs.npmjs.com/about-semantic-versioning)

## npm registry

- [npm package registry](https://www.npmjs.com/)

Before running or installing an unfamiliar package, review:

- Exact package name
- Publisher
- Repository
- Release history
- Maintenance activity
- Security advisories
- Download source
- Required permissions and lifecycle scripts

## npm security

- [npm package security guidance](https://docs.npmjs.com/packages-and-modules/securing-your-code)
- [Reporting malware in npm packages](https://docs.npmjs.com/reporting-a-vulnerability-in-an-npm-package)

Do not treat `npx` as a sandbox.

---

# 9. pnpm and Corepack

## pnpm

- [pnpm documentation](https://pnpm.io/)
- [pnpm installation](https://pnpm.io/installation)
- [pnpm CLI](https://pnpm.io/pnpm-cli)
- [pnpm workspace documentation](https://pnpm.io/workspaces)

## Corepack

- [Node.js Corepack documentation](https://nodejs.org/api/corepack.html)

Check availability:

```powershell
Get-Command corepack `
    -ErrorAction SilentlyContinue
```

Do not casually mix:

```text
package-lock.json
pnpm-lock.yaml
```

Select one package manager and lockfile as the project’s source of truth unless multi-manager support is deliberate.

---

# 10. Express

## Official Express resources

- [Express website](https://expressjs.com/)
- [Express getting started](https://expressjs.com/en/starter/installing.html)
- [Express API reference](https://expressjs.com/en/api.html)
- [Express routing](https://expressjs.com/en/guide/routing.html)
- [Express middleware](https://expressjs.com/en/guide/using-middleware.html)
- [Express error handling](https://expressjs.com/en/guide/error-handling.html)
- [Express production best practices: security](https://expressjs.com/en/advanced/best-practice-security.html)
- [Express production best practices: performance](https://expressjs.com/en/advanced/best-practice-performance.html)
- [Express on GitHub](https://github.com/expressjs/express)

Important topics for this series:

```javascript
express()
express.json()
app.disable("x-powered-by")
app.get()
app.post()
app.use()
response.status()
response.json()
```

Express does not automatically provide:

- Authentication
- Authorization
- Rate limiting
- TLS
- Secure secret storage
- Complete production observability

Those are separate architectural concerns.

---

# 11. dotenv

## Primary resources

- [dotenv on npm](https://www.npmjs.com/package/dotenv)
- [dotenv on GitHub](https://github.com/motdotla/dotenv)

Typical usage:

```javascript
const dotenv = require("dotenv");

dotenv.config({
  path: ".env",
  override: false,
});
```

Verify options against the documentation for the installed version.

Important principle:

```text
existing process environment > .env fallback
```

when override is disabled.

`dotenv` loads values; it does not replace application-specific validation.

---

# 12. ESLint

## Official resources

- [ESLint documentation](https://eslint.org/docs/latest/)
- [Getting started](https://eslint.org/docs/latest/use/getting-started)
- [Configure ESLint](https://eslint.org/docs/latest/use/configure/)
- [Configuration files](https://eslint.org/docs/latest/use/configure/configuration-files)
- [Rules reference](https://eslint.org/docs/latest/rules/)
- [ESLint on GitHub](https://github.com/eslint/eslint)

Current ESLint versions use flat configuration through files such as:

```text
eslint.config.js
```

Check the documentation for the installed major version because configuration formats and defaults can change.

---

# 13. HTTP and Web Protocols

## Beginner-friendly HTTP reference

- [MDN HTTP overview](https://developer.mozilla.org/docs/Web/HTTP/Overview)
- [HTTP methods](https://developer.mozilla.org/docs/Web/HTTP/Reference/Methods)
- [HTTP status codes](https://developer.mozilla.org/docs/Web/HTTP/Reference/Status)
- [HTTP headers](https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers)
- [`Content-Type`](https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/Content-Type)
- [HTTP messages](https://developer.mozilla.org/docs/Web/HTTP/Guides/Messages)

## HTTP standards

The current core HTTP specifications include:

- [RFC 9110: HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110)
- [RFC 9111: HTTP Caching](https://www.rfc-editor.org/rfc/rfc9111)
- [RFC 9112: HTTP/1.1](https://www.rfc-editor.org/rfc/rfc9112)
- [RFC 9113: HTTP/2](https://www.rfc-editor.org/rfc/rfc9113)

Start with MDN. Use the RFCs when exact protocol behavior matters.

## JSON standard

- [RFC 8259: The JavaScript Object Notation Data Interchange Format](https://www.rfc-editor.org/rfc/rfc8259)
- [MDN: Working with JSON](https://developer.mozilla.org/docs/Learn_web_development/Core/Scripting/JSON)

---

# 14. PowerShell HTTP Clients

## `Invoke-RestMethod`

- [`Invoke-RestMethod`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod)

Use when JSON should be converted into PowerShell objects:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get
```

## `Invoke-WebRequest`

- [`Invoke-WebRequest`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest)

Use when you need lower-level response information:

```powershell
$response = Invoke-WebRequest `
    -Uri "http://127.0.0.1:3000/health"

$response.StatusCode
$response.Headers
$response.Content
```

---

# 15. Environment Variables and .NET APIs

## PowerShell environment provider

- [`about_Environment_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_environment_variables)
- [`about_Environment_Provider`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_environment_provider)

## .NET environment APIs

- [`Environment.GetEnvironmentVariable`](https://learn.microsoft.com/dotnet/api/system.environment.getenvironmentvariable)
- [`Environment.SetEnvironmentVariable`](https://learn.microsoft.com/dotnet/api/system.environment.setenvironmentvariable)
- [`EnvironmentVariableTarget`](https://learn.microsoft.com/dotnet/api/system.environmentvariabletarget)

Examples:

```powershell
[System.Environment]::GetEnvironmentVariable(
    "EXAMPLE_NAME",
    [System.EnvironmentVariableTarget]::User
)
```

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

---

# 16. Git and `.gitignore`

## Official Git resources

- [Git documentation](https://git-scm.com/doc)
- [Pro Git book](https://git-scm.com/book/en/v2)
- [`gitignore` documentation](https://git-scm.com/docs/gitignore)
- [`git check-ignore`](https://git-scm.com/docs/git-check-ignore)
- [`git status`](https://git-scm.com/docs/git-status)
- [`git add`](https://git-scm.com/docs/git-add)
- [`git commit`](https://git-scm.com/docs/git-commit)

## GitHub `.gitignore` templates

- [GitHub `.gitignore` collection](https://github.com/github/gitignore)
- [Node `.gitignore` template](https://github.com/github/gitignore/blob/main/Node.gitignore)

## Useful checks

```powershell
git check-ignore -v .env
git check-ignore -v node_modules
git status
```

Remember:

- `.gitignore` affects untracked paths.
- It does not erase secrets already committed.
- A committed secret must be rotated.
- History cleanup requires planning, backups, and organizational coordination.

---

# 17. Secrets and Application Security

## OWASP guidance

- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
- [OWASP Node.js Docker Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/NodeJS_Docker_Cheat_Sheet.html)
- [OWASP REST Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html)
- [OWASP Input Validation Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html)
- [OWASP Error Handling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## Twelve-Factor App configuration principle

- [The Twelve-Factor App: Config](https://12factor.net/config)

This is an influential configuration principle, not a complete secret-management architecture.

## Production secret-management examples

- [Azure Key Vault documentation](https://learn.microsoft.com/azure/key-vault/)
- [AWS Secrets Manager documentation](https://docs.aws.amazon.com/secretsmanager/)
- [Google Cloud Secret Manager documentation](https://cloud.google.com/secret-manager/docs)
- [HashiCorp Vault documentation](https://developer.hashicorp.com/vault/docs)
- [GitHub Actions encrypted secrets](https://docs.github.com/actions/security-guides/using-secrets-in-github-actions)

Use the provider approved by your organization and deployment platform.

---

# 18. Windows Developer Tooling

## Windows Package Manager

- [WinGet documentation](https://learn.microsoft.com/windows/package-manager/winget/)
- [`winget install`](https://learn.microsoft.com/windows/package-manager/winget/install)

Examples:

```powershell
winget install `
    --id Microsoft.PowerShell `
    --source winget
```

```powershell
winget install `
    --id OpenJS.NodeJS.LTS `
    --source winget
```

Confirm package identifiers through:

```powershell
winget search PowerShell
winget search Node.js
```

Package identifiers and available versions can change.

## Windows Terminal

- [Windows Terminal documentation](https://learn.microsoft.com/windows/terminal/)
- [Windows Terminal settings](https://learn.microsoft.com/windows/terminal/customize-settings/startup)

## Visual Studio Code

- [Visual Studio Code documentation](https://code.visualstudio.com/docs)
- [VS Code PowerShell documentation](https://code.visualstudio.com/docs/languages/powershell)
- [PowerShell extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [JavaScript in VS Code](https://code.visualstudio.com/docs/languages/javascript)
- [Node.js debugging in VS Code](https://code.visualstudio.com/docs/nodejs/nodejs-debugging)

---

# 19. Testing and CI/CD

## Node.js test runner

- [Node.js test runner](https://nodejs.org/api/test.html)
- [Node.js assertions](https://nodejs.org/api/assert.html)

## GitHub Actions

- [GitHub Actions documentation](https://docs.github.com/actions)
- [Building and testing Node.js](https://docs.github.com/actions/automating-builds-and-tests/building-and-testing-nodejs)

Typical CI commands:

```yaml
- run: npm ci
- run: npm run check
```

Do not place live secrets directly in workflow source.

## Azure Pipelines

- [Azure Pipelines documentation](https://learn.microsoft.com/azure/devops/pipelines/)
- [Build JavaScript and Node.js apps](https://learn.microsoft.com/azure/devops/pipelines/ecosystems/javascript)

## npm provenance and supply-chain information

- [npm package provenance](https://docs.npmjs.com/generating-provenance-statements)
- [npm dependency selectors and package querying](https://docs.npmjs.com/cli/commands/npm-query)

---

# 20. Observability and Production Operations

The tutorial’s health endpoint and console logging are introductory. Production systems often need more.

## OpenTelemetry

- [OpenTelemetry documentation](https://opentelemetry.io/docs/)
- [OpenTelemetry JavaScript](https://opentelemetry.io/docs/languages/js/)

## Health checks

- [Kubernetes liveness, readiness, and startup probes](https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/)

Important distinction:

```text
Liveness  → should the process be restarted?
Readiness → should traffic be sent to it?
Startup   → has slow initialization completed?
```

A single `/health` endpoint may be insufficient for a larger deployed system.

## Structured logging

When adding logging:

- Prefer structured fields
- Avoid credentials and request secrets
- Define retention rules
- Prevent log injection
- Use correlation identifiers where appropriate
- Follow the OWASP Logging Cheat Sheet

---

# 21. Recommended Books

Check for the latest available edition before purchasing.

## PowerShell

### *Learn PowerShell in a Month of Lunches*

Authors have included Don Jones, Travis Plunk, James Petty, Tyler Leonhardt, and Jeff Hicks across editions.

Useful for:

- Beginners
- Command discovery
- Pipelines
- Objects
- Practical shell habits

Publisher:

- [Manning Publications](https://www.manning.com/)

### *PowerShell in Action*

Author: Bruce Payette, with later editions involving Richard Siddaway.

Useful for:

- Deeper language understanding
- Runtime behavior
- Advanced scripting
- PowerShell architecture

### *The PowerShell Scripting and Toolmaking Book*

Authors: Don Jones and Jeffery Hicks.

Useful for:

- Reusable tools
- Advanced functions
- Error handling
- Production-quality scripts

## JavaScript

### *Eloquent JavaScript*

Author: Marijn Haverbeke

- [Free online edition](https://eloquentjavascript.net/)

Useful for:

- JavaScript fundamentals
- Functions
- Objects
- Asynchronous programming

### *You Don’t Know JS Yet*

Author: Kyle Simpson

- [GitHub repository](https://github.com/getify/You-Dont-Know-JS)

Useful for deeper JavaScript language understanding.

### *JavaScript: The Definitive Guide*

Author: David Flanagan

Useful as a broad language and platform reference.

## Node.js

For Node.js, prioritize the official API documentation because runtime APIs and support status evolve quickly. Supplement with a current book whose examples match the Node.js major version used by the course.

## Git

### *Pro Git*

Authors: Scott Chacon and Ben Straub

- [Free online book](https://git-scm.com/book/en/v2)

---

# 22. Interactive Learning Resources

## Microsoft Learn

- [Browse PowerShell learning content](https://learn.microsoft.com/training/browse/?terms=PowerShell)
- [Browse Node.js learning content](https://learn.microsoft.com/training/browse/?terms=Node.js)
- [Browse Git learning content](https://learn.microsoft.com/training/browse/?terms=Git)

## MDN Learn Web Development

- [MDN Learn Web Development](https://developer.mozilla.org/docs/Learn_web_development)

## NodeSchool

- [NodeSchool](https://nodeschool.io/)

Review workshop maintenance and Node.js version compatibility before assigning a specific workshop.

## Exercism

- [PowerShell track](https://exercism.org/tracks/powershell)
- [JavaScript track](https://exercism.org/tracks/javascript)

## Microsoft PowerShell learning repository

- [PowerShell documentation repository](https://github.com/MicrosoftDocs/PowerShell-Docs)

This is useful for reporting documentation issues and examining source content.

---

# 23. Community Resources

Community material is valuable, but confirm advice against official documentation before applying security-sensitive or destructive commands.

## PowerShell

- [PowerShell GitHub organization](https://github.com/PowerShell)
- [PowerShell repository](https://github.com/PowerShell/PowerShell)
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [PowerShell.org](https://powershell.org/)
- [PowerShell subreddit](https://www.reddit.com/r/PowerShell/)
- [Stack Overflow: PowerShell](https://stackoverflow.com/questions/tagged/powershell)

## Node.js

- [Node.js GitHub organization](https://github.com/nodejs)
- [Node.js project repository](https://github.com/nodejs/node)
- [Node.js community resources](https://nodejs.org/en/about/get-involved)
- [Stack Overflow: Node.js](https://stackoverflow.com/questions/tagged/node.js)

## JavaScript

- [TC39](https://tc39.es/)
- [Stack Overflow: JavaScript](https://stackoverflow.com/questions/tagged/javascript)

When asking for help, provide:

- Tool version
- Operating system
- Minimal reproducible example
- Exact error text
- Expected behavior
- Actual behavior

Never include:

- Tokens
- Passwords
- Private keys
- Complete environment dumps
- Proprietary source code without permission

---

# 24. Version and Compatibility Checklist

Before beginning a new cohort or project, record:

| Component | Selected version | Support status checked? |
|---|---|---:|
| Windows | | |
| PowerShell | | |
| Node.js | | |
| npm | | |
| Express | | |
| dotenv | | |
| ESLint | | |
| Git | | |

Useful commands:

```powershell
$PSVersionTable.PSVersion
node --version
npm.cmd --version
git --version

npm.cmd list express dotenv eslint --depth=0
```

Check for outdated dependencies:

```powershell
npm.cmd outdated
```

Audit known package issues:

```powershell
npm.cmd audit
```

Do not apply:

```text
npm audit fix --force
```

blindly. Forced remediation may introduce breaking changes. Review the dependency change and rerun the complete quality gate.

---

# 25. Source-Evaluation Checklist

Before trusting a tutorial, answer:

- [ ] Is it official documentation or a primary source?
- [ ] Does it identify the relevant software version?
- [ ] Is the publication date visible?
- [ ] Is the project actively maintained?
- [ ] Does the example use supported APIs?
- [ ] Does it explain security implications?
- [ ] Does it avoid broad destructive commands?
- [ ] Does it avoid disabling protections globally?
- [ ] Does it keep secrets out of source and logs?
- [ ] Can its claims be verified against official documentation?

## Warning signs

Be cautious when a source recommends:

```text
Run everything as administrator
Disable execution policy globally
Use -Force on every command
Delete the lockfile whenever npm fails
Commit .env for convenience
Print process.env for debugging
Paste a production token into source code
Run an unknown npx package without review
Use a broad recursive deletion without -WhatIf
```

---

# 26. Resources by Course Module

## Primer 1: Reading PowerShell

Start with:

1. [`about_Command_Syntax`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_command_syntax)
2. [`about_Parameters`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parameters)
3. [`about_Pipelines`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines)
4. [`about_Objects`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_objects)
5. [`Get-Member`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-member)

## Primer 2 and Parts 1–2: Filesystem

Start with:

1. [`about_Path_Syntax`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_path_syntax)
2. [`Get-ChildItem`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem)
3. [`Test-Path`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/test-path)
4. [`Resolve-Path`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/resolve-path)
5. [`Remove-Item`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/remove-item)
6. [`about_ShouldProcess`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_shouldprocess)

## Primer 3 and Part 3: Node.js and HTTP

Start with:

1. [Node.js API](https://nodejs.org/docs/latest/api/)
2. [CommonJS modules](https://nodejs.org/api/modules.html)
3. [Node.js HTTP](https://nodejs.org/api/http.html)
4. [Node.js test runner](https://nodejs.org/api/test.html)
5. [npm documentation](https://docs.npmjs.com/)
6. [MDN HTTP overview](https://developer.mozilla.org/docs/Web/HTTP/Overview)
7. [Express documentation](https://expressjs.com/)

## Primer 4 and Part 4: Configuration and Secrets

Start with:

1. [`about_Environment_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_environment_variables)
2. [Node.js environment variables](https://nodejs.org/api/environment_variables.html)
3. [dotenv](https://github.com/motdotla/dotenv)
4. [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
5. [Git ignore documentation](https://git-scm.com/docs/gitignore)
6. [`about_Profiles`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles)

---

# 27. Minimal Reference Shelf

If learners bookmark only ten resources, use these:

1. [PowerShell documentation](https://learn.microsoft.com/powershell/)
2. [PowerShell about topics](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/)
3. [`Get-ChildItem`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem)
4. [`about_ShouldProcess`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_shouldprocess)
5. [Node.js API](https://nodejs.org/docs/latest/api/)
6. [npm documentation](https://docs.npmjs.com/)
7. [MDN JavaScript Guide](https://developer.mozilla.org/docs/Web/JavaScript/Guide)
8. [MDN HTTP overview](https://developer.mozilla.org/docs/Web/HTTP/Overview)
9. [Git documentation](https://git-scm.com/doc)
10. [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

# 28. Recommended Learning Path After the Series

## Stage 1: Strengthen PowerShell

Study:

- Advanced functions
- Modules
- Pester
- PSScriptAnalyzer
- Remoting
- Jobs and parallel work
- Secure credential handling

Recommended sequence:

```text
Advanced functions
        ↓
Modules
        ↓
Pester tests
        ↓
PSScriptAnalyzer
        ↓
CI automation
```

## Stage 2: Strengthen Node.js

Study:

- ES modules
- Streams
- Event loop behavior
- Dependency security
- Structured logging
- Database access
- Authentication and authorization
- Observability
- Worker threads where appropriate

## Stage 3: Strengthen HTTP and APIs

Study:

- REST constraints
- Idempotency
- Authentication
- Authorization
- CORS
- Rate limiting
- Pagination
- Validation
- API versioning
- OpenAPI
- Error contracts

OpenAPI resources:

- [OpenAPI Initiative](https://www.openapis.org/)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)

## Stage 4: Strengthen deployment

Study:

- CI/CD
- Containers
- Secret injection
- Health probes
- Logging and metrics
- Dependency scanning
- Least privilege
- Backups and recovery
- Infrastructure as code

---

# 29. Citation Guidance

When citing technical documentation, record:

- Organization or author
- Page title
- Software version when applicable
- URL
- Access date

Example:

```text
Microsoft. “about_Execution_Policies.”
PowerShell Documentation.
https://learn.microsoft.com/powershell/module/
microsoft.powershell.core/about/about_execution_policies
Accessed YYYY-MM-DD.
```

For API behavior, prefer:

1. Official versioned documentation
2. Language or protocol specifications
3. Maintainer repositories
4. Reputable educational sources
5. Community answers only as supplemental evidence

---

# 30. Final Resource Principles

Use official documentation as the primary authority:

```text
Microsoft Learn → PowerShell and Windows
Node.js docs    → Node.js APIs
npm docs        → package management
MDN and RFCs    → JavaScript and HTTP
Git docs        → version control
OWASP           → application-security guidance
Library docs    → Express, dotenv, ESLint
```

When documentation and a tutorial disagree:

1. Check the installed software version.
2. Read the documentation for that version.
3. Reduce the issue to a minimal example.
4. Verify behavior in a disposable laboratory.
5. Avoid changing security settings merely to force an old example to work.
6. Update the implementation and tests together.

The essential habits are:

```text
Prefer primary sources
Verify version compatibility
Test in a disposable environment
Protect secrets
Preview destructive operations
Validate external input
Confirm results independently
```
