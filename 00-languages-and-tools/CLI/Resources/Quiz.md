# Quiz and Answer-Key Pack

These quizzes cover:

1. Reading PowerShell commands
2. Navigation and filesystem safety
3. File and directory management
4. Node.js, npm, packages, and HTTP
5. Environment variables, configuration, and secrets
6. Final cumulative assessment

## Suggested Scoring

For each quiz:

- Multiple choice or true/false: **1 point**
- Code-reading questions: **2 points**
- Scenario or implementation questions: **3 points**

Suggested interpretation:

| Score | Interpretation |
|---:|---|
| 90–100% | Ready to apply the material independently |
| 75–89% | Strong understanding; review missed topics |
| 60–74% | Developing understanding; revisit relevant sections |
| Below 60% | Repeat the related primer or part before proceeding |

---

# Quiz 1: Reading PowerShell Commands

## Questions

### 1. Multiple Choice

What naming pattern do native PowerShell cmdlets normally follow?

A. `Noun_Verb`  
B. `Verb-Noun`  
C. `verbNoun`  
D. `noun.verb`

---

### 2. Multiple Choice

In this command, what is `-LiteralPath`?

```powershell
Get-Item -LiteralPath .\settings.json
```

A. An alias  
B. A parameter  
C. A variable  
D. A pipeline operator

---

### 3. Multiple Choice

In the same command, what is `.\settings.json`?

A. The command name  
B. A switch  
C. A parameter value  
D. A comment

---

### 4. True or False

`-Recurse` is normally a switch parameter, so it can be enabled simply by including it:

```powershell
Get-ChildItem -Recurse
```

---

### 5. Multiple Choice

What does this symbol do?

```text
|
```

A. Separates a drive letter  
B. Passes output objects to another command  
C. Starts a comment  
D. Declares a variable

---

### 6. Multiple Choice

Inside this script block, what does `$_` represent?

```powershell
Where-Object {
    $_.Length -gt 100
}
```

A. The current PowerShell process  
B. The current pipeline object  
C. The current directory  
D. The previous command’s exit code

---

### 7. Code Reading

Explain this command in plain language:

```powershell
Get-ChildItem `
    -LiteralPath .\documents `
    -File |
    Sort-Object `
        -Property Length `
        -Descending |
    Select-Object `
        -Property Name, Length
```

---

### 8. Multiple Choice

What is the difference between these strings?

```powershell
"Project: $projectName"
'Project: $projectName'
```

A. There is no difference  
B. Only the single-quoted string expands the variable  
C. Only the double-quoted string expands the variable  
D. Neither string expands the variable

---

### 9. Multiple Choice

What does this expression return?

```powershell
(Get-Location).Path
```

A. The complete location object  
B. The `Path` property of the location object  
C. Every child path  
D. A Boolean indicating whether the path exists

---

### 10. Code Reading

What does this command select?

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Extension -in @(".json", ".md")
    }
```

---

### 11. Multiple Choice

Which command helps discover the properties and methods available on an object?

A. `Get-Help`  
B. `Get-Member`  
C. `Get-Command`  
D. `Resolve-Path`

---

### 12. True or False

In a normal PowerShell session, `ls` commonly resolves to the native UNIX `ls` executable.

---

### 13. Multiple Choice

What kind of structure is this?

```powershell
@{
    LiteralPath = ".\documents"
    File = $true
}
```

A. Array  
B. Hashtable  
C. Script block  
D. Custom class

---

### 14. Code Reading

What does this syntax do?

```powershell
Get-ChildItem @parameters
```

Assume `$parameters` contains a hashtable of parameter names and values.

---

### 15. Short Answer

Name the three built-in commands primarily used to:

1. Discover commands
2. Read command documentation
3. Inspect returned objects

---

# Quiz 1 Answer Key

### 1.

**B — `Verb-Noun`**

Examples include:

```powershell
Get-Item
Set-Location
Remove-Item
```

### 2.

**B — A parameter**

`-LiteralPath` identifies the exact path that `Get-Item` should inspect.

### 3.

**C — A parameter value**

It is the value supplied to `-LiteralPath`.

### 4.

**True**

The presence of `-Recurse` enables recursive traversal.

### 5.

**B — Passes output objects to another command**

The pipeline transfers structured PowerShell objects between commands.

### 6.

**B — The current pipeline object**

`$_.Length` reads the `Length` property of each current object.

### 7.

It:

1. Retrieves files directly inside `.\documents`.
2. Sorts them by size from largest to smallest.
3. Produces output containing only each file’s `Name` and `Length`.

### 8.

**C — Only the double-quoted string expands the variable**

The single-quoted form preserves `$projectName` literally.

### 9.

**B — The `Path` property of the location object**

Parentheses run `Get-Location` first, after which `.Path` accesses its property.

### 10.

It selects files whose extensions are either:

```text
.json
.md
```

### 11.

**B — `Get-Member`**

Example:

```powershell
Get-Item .\package.json |
    Get-Member
```

### 12.

**False**

In PowerShell, `ls` normally aliases `Get-ChildItem`.

### 13.

**B — Hashtable**

It stores named key-value pairs.

### 14.

It uses **splatting** to pass the hashtable’s keys and values as named parameters to `Get-ChildItem`.

### 15.

1. `Get-Command`
2. `Get-Help`
3. `Get-Member`

---

# Quiz 2: Navigation and Paths

## Questions

### 1. Multiple Choice

Which command displays the current PowerShell location?

A. `Set-Location`  
B. `Get-Location`  
C. `Resolve-Path`  
D. `Get-Item`

---

### 2. Multiple Choice

What does this path mean?

```text
.
```

A. The user’s home directory  
B. The filesystem root  
C. The current directory  
D. The parent directory

---

### 3. Multiple Choice

What does this path mean?

```text
..
```

A. The parent directory  
B. The current directory  
C. The home directory  
D. A hidden directory

---

### 4. Multiple Choice

Which path is absolute?

A. `.\src\index.js`  
B. `..\archive`  
C. `C:\Projects\service`  
D. `src\config.js`

---

### 5. True or False

A relative path has the same meaning regardless of the current location.

---

### 6. Multiple Choice

What does `$HOME` normally represent?

A. The current application directory  
B. The current user’s home directory  
C. The root of the `C:` drive  
D. The PowerShell installation directory

---

### 7. Code Reading

If the current location is:

```text
C:\Projects\service\src
```

where does this command navigate?

```powershell
Set-Location -Path ..\test
```

---

### 8. Multiple Choice

Why should a path containing spaces normally be quoted?

A. Quotation marks make it absolute  
B. Spaces otherwise separate command arguments  
C. Quotation marks grant access permission  
D. PowerShell prohibits unquoted drive letters

---

### 9. Multiple Choice

Which command checks whether a path exists?

A. `Test-Path`  
B. `Resolve-Path`  
C. `Get-Location`  
D. `Push-Location`

---

### 10. Multiple Choice

Which `Test-Path` option confirms that a target is a directory?

A. `-PathType Leaf`  
B. `-PathType Container`  
C. `-ItemType Directory`  
D. `-DirectoryOnly`

---

### 11. Multiple Choice

What is the primary purpose of `Resolve-Path`?

A. Create a missing directory  
B. Convert an existing path into its resolved location  
C. Remove relative path symbols from source code  
D. Search file contents

---

### 12. True or False

Every Windows computer has a `D:` drive.

---

### 13. Multiple Choice

Which command lists filesystem drives known to PowerShell?

A. `Get-Volume` only  
B. `Get-PSDrive -PSProvider FileSystem`  
C. `Get-Location -Drives`  
D. `Get-Item Env:`

---

### 14. Code Reading

What do these commands accomplish?

```powershell
Push-Location -LiteralPath .\documents
Pop-Location
```

---

### 15. Scenario

You are about to run:

```powershell
Remove-Item -LiteralPath .\archive -Recurse
```

What should you inspect before executing it?

---

# Quiz 2 Answer Key

### 1.

**B — `Get-Location`**

### 2.

**C — The current directory**

### 3.

**A — The parent directory**

### 4.

**C — `C:\Projects\service`**

It includes the drive and complete path from its root.

### 5.

**False**

A relative path is interpreted from the current location.

### 6.

**B — The current user’s home directory**

### 7.

It navigates to:

```text
C:\Projects\service\test
```

`..` first moves from `src` to `service`; `test` then enters the sibling directory.

### 8.

**B — Spaces otherwise separate command arguments**

### 9.

**A — `Test-Path`**

### 10.

**B — `-PathType Container`**

A file is normally checked with:

```powershell
-PathType Leaf
```

### 11.

**B — Convert an existing path into its resolved location**

### 12.

**False**

Available drive letters differ among computers.

### 13.

**B — `Get-PSDrive -PSProvider FileSystem`**

### 14.

`Push-Location` saves the current location and enters `documents`. `Pop-Location` restores the saved location.

### 15.

At minimum:

1. Run `Get-Location`.
2. Resolve `.\archive`.
3. Confirm it is the intended directory.
4. Inspect its descendants, including hidden items.
5. Preview deletion with `-WhatIf`.
6. Verify that the target lies inside an approved workspace.

---

# Quiz 3: Filesystem Safety and Management

## Questions

### 1. Ordering

Put these safety stages in the correct order:

- Execute
- Inspect
- Locate
- Verify
- Resolve
- Preview

---

### 2. Multiple Choice

Which parameter treats a path exactly as supplied rather than expanding wildcards?

A. `-Path`  
B. `-LiteralPath`  
C. `-Exact`  
D. `-Force`

---

### 3. Multiple Choice

What does `-WhatIf` do?

A. Creates a backup  
B. Sends deleted files to the Recycle Bin  
C. Describes a supported operation without executing it  
D. Automatically reverses a failed operation

---

### 4. True or False

`-WhatIf` guarantees that the later real operation will succeed.

---

### 5. Multiple Choice

What does `-Recurse` do in this command?

```powershell
Remove-Item -LiteralPath $target -Recurse
```

A. Retries the operation  
B. Includes descendants in the directory tree  
C. Grants administrator access  
D. Sends the target to quarantine

---

### 6. Multiple Choice

Which statement about `-Force` is correct?

A. It bypasses all Windows security  
B. It grants administrator privileges  
C. It can handle some hidden or read-only restrictions  
D. It guarantees access to locked files

---

### 7. True or False

`Remove-Item` normally sends files to the Windows Recycle Bin.

---

### 8. Multiple Choice

Which command creates a directory?

A. `New-Item -ItemType Directory`  
B. `Set-Content -ItemType Directory`  
C. `Get-Item -Directory`  
D. `Copy-Item -Create`

---

### 9. Multiple Choice

Which command replaces a file’s complete content?

A. `Add-Content`  
B. `Set-Content`  
C. `Get-Content`  
D. `Copy-Item`

---

### 10. Multiple Choice

Which command appends content to an existing file?

A. `Add-Content`  
B. `Set-Content`  
C. `Move-Item`  
D. `New-Item`

---

### 11. Code Reading

What is safer about this pattern?

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

---

### 12. Scenario

A directory is non-empty. Which option is necessary to remove the complete tree?

A. `-File`  
B. `-Recurse`  
C. `-Hidden`  
D. `-Append`

---

### 13. Multiple Choice

Which command can strongly verify that a copied file’s bytes match the source?

A. `Get-Location`  
B. `Get-FileHash`  
C. `Get-Alias`  
D. `Get-Help`

---

### 14. True or False

After moving a file successfully, the original path should normally no longer contain it.

---

### 15. Scenario

Why might moving a deletion candidate to a quarantine directory be safer than immediately removing it?

---

### 16. Multiple Choice

What does this declaration give a custom PowerShell function?

```powershell
[CmdletBinding(SupportsShouldProcess)]
```

A. Automatic administrator access  
B. Support for standard `-WhatIf` and `-Confirm` behavior  
C. Automatic filesystem backups  
D. Guaranteed rollback

---

### 17. Multiple Choice

What is a reparse point risk?

A. It can redirect a path to another filesystem location  
B. It always corrupts JSON files  
C. It disables tab completion  
D. It turns files into environment variables

---

### 18. True or False

A string prefix check alone creates a complete filesystem security sandbox.

---

### 19. Implementation

Write a safe preview command for recursively removing an exact directory stored in `$target`.

---

### 20. Implementation

Write a command that verifies the target no longer exists after deletion.

---

# Quiz 3 Answer Key

### 1.

Correct order:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

### 2.

**B — `-LiteralPath`**

### 3.

**C — Describes a supported operation without executing it**

### 4.

**False**

Permissions, locks, concurrent changes, or other conditions may still cause the real operation to fail.

### 5.

**B — Includes descendants in the directory tree**

### 6.

**C — It can handle some hidden or read-only restrictions**

It does not bypass all security controls.

### 7.

**False**

Treat `Remove-Item` as permanent.

### 8.

**A — `New-Item -ItemType Directory`**

Example:

```powershell
New-Item `
    -Path .\archive `
    -ItemType Directory
```

### 9.

**B — `Set-Content`**

### 10.

**A — `Add-Content`**

### 11.

It:

1. Selects a fixed set of matching file objects.
2. Limits selection to files.
3. Displays their exact full paths.
4. Previews deletion of those same objects.

This is safer than sending an uninspected broad wildcard directly to `Remove-Item`.

### 12.

**B — `-Recurse`**

### 13.

**B — `Get-FileHash`**

Comparing SHA-256 hashes provides strong content verification.

### 14.

**True**

A move relocates the item rather than retaining an original copy.

### 15.

Quarantine:

- Preserves the item temporarily
- Allows review
- Makes restoration possible through another move
- Delays permanent removal until intent is confirmed

### 16.

**B — Support for standard `-WhatIf` and `-Confirm` behavior**

The function must still call `$PSCmdlet.ShouldProcess(...)` around its mutation.

### 17.

**A — It can redirect a path to another filesystem location**

A visible child path may point outside the approved root.

### 18.

**False**

Reparse points, concurrent changes, permissions, and unusual filesystem behavior still require consideration.

### 19.

```powershell
Remove-Item `
    -LiteralPath $target `
    -Recurse `
    -WhatIf
```

Add `-Force` only when an understood requirement justifies it.

### 20.

```powershell
Test-Path -LiteralPath $target
```

After successful deletion, the expected result is:

```text
False
```

---

# Quiz 4: JavaScript and Node.js Fundamentals

## Questions

### 1. Multiple Choice

What is Node.js?

A. A JavaScript package manager only  
B. A JavaScript runtime  
C. A PowerShell module  
D. A database engine

---

### 2. Multiple Choice

Which declaration should normally be preferred when a variable will not be reassigned?

A. `var`  
B. `const`  
C. `dynamic`  
D. `fixed`

---

### 3. True or False

`const` deeply freezes every object assigned to it.

---

### 4. Multiple Choice

Which expression uses strict equality?

A. `left = right`  
B. `left == right`  
C. `left === right`  
D. `left -eq right`

---

### 5. Code Reading

What does this function return?

```javascript
function buildAddress(host, port) {
  return `http://${host}:${port}`;
}
```

Called as:

```javascript
buildAddress("127.0.0.1", 3000);
```

---

### 6. Multiple Choice

What does this syntax create?

```javascript
const routes = ["/", "/health"];
```

A. Object  
B. Array  
C. Function  
D. Promise

---

### 7. Multiple Choice

Which expression reads the `port` property?

```javascript
const configuration = {
  port: 3000,
};
```

A. `configuration(port)`  
B. `configuration->port`  
C. `configuration.port`  
D. `$configuration.port`

---

### 8. Multiple Choice

What does `JSON.stringify(value)` do?

A. Parses JSON into an object  
B. Converts a JavaScript value into JSON text  
C. Encrypts the value  
D. Validates HTTP headers

---

### 9. Multiple Choice

What does `JSON.parse(text)` do?

A. Converts JSON text into a JavaScript value  
B. Converts a number into a string  
C. Imports a Node.js package  
D. Writes an HTTP response

---

### 10. Code Reading

What is exported by this module?

```javascript
module.exports = {
  add,
  multiply,
};
```

---

### 11. Multiple Choice

How is a nearby CommonJS module usually imported?

A. `require("math")`  
B. `require("./math")`  
C. `include("./math")`  
D. `using math`

---

### 12. Multiple Choice

What does an `async` function always return?

A. An array  
B. A PowerShell object  
C. A Promise  
D. A process

---

### 13. Multiple Choice

Where can `await` ordinarily be used in the CommonJS patterns from the tutorial?

A. Inside an `async` function  
B. Inside JSON text  
C. Inside `package-lock.json`  
D. Only inside PowerShell

---

### 14. Code Reading

What happens here?

```javascript
try {
  throw new Error("Invalid configuration.");
} catch (error) {
  console.error(error.message);
}
```

---

### 15. Multiple Choice

What does a process exit code of `0` conventionally mean?

A. Failure  
B. Success  
C. Restart required  
D. Administrator privileges are active

---

### 16. Multiple Choice

What does this return?

```javascript
process.argv.slice(2)
```

A. Environment variables  
B. User-supplied command-line arguments  
C. The first two files in the project  
D. HTTP response headers

---

### 17. True or False

`process.cwd()` always returns the directory containing the current script file.

---

### 18. Multiple Choice

Which CommonJS value identifies the directory containing the current module?

A. `process.cwd()`  
B. `__dirname`  
C. `process.env`  
D. `module.pathRoot`

---

### 19. Code Reading

Why is this check useful?

```javascript
if (require.main === module) {
  startServer();
}
```

---

### 20. Short Answer

What is the difference between synchronous and asynchronous work?

---

# Quiz 4 Answer Key

### 1.

**B — A JavaScript runtime**

### 2.

**B — `const`**

Use `let` when reassignment is intentional.

### 3.

**False**

`const` prevents variable reassignment but does not deeply freeze an object.

### 4.

**C — `left === right`**

### 5.

It returns:

```text
http://127.0.0.1:3000
```

### 6.

**B — Array**

### 7.

**C — `configuration.port`**

### 8.

**B — Converts a JavaScript value into JSON text**

### 9.

**A — Converts JSON text into a JavaScript value**

### 10.

An object exposing the `add` and `multiply` functions as the module’s public interface.

### 11.

**B — `require("./math")`**

The `./` marks it as a nearby file rather than an installed package.

### 12.

**C — A Promise**

### 13.

**A — Inside an `async` function**

### 14.

The code throws an error, catches it, and writes:

```text
Invalid configuration.
```

to the error stream.

### 15.

**B — Success**

Nonzero normally indicates failure.

### 16.

**B — User-supplied command-line arguments**

The first two `process.argv` entries ordinarily identify Node.js and the script.

### 17.

**False**

It returns the process’s current working directory, which may differ from the script directory.

### 18.

**B — `__dirname`**

### 19.

It starts the server only when the file is executed directly. Importing the module for testing does not automatically open a network port.

### 20.

Synchronous work completes in sequence before the next statement proceeds. Asynchronous work may finish later and is commonly represented by callbacks or Promises.

---

# Quiz 5: npm, Packages, and Project Lifecycle

## Questions

### 1. Multiple Choice

What is the primary role of `package.json`?

A. Store installed package source code  
B. Declare project metadata, dependencies, and scripts  
C. Store Windows user passwords  
D. Replace JavaScript source files

---

### 2. Multiple Choice

What is the primary role of `package-lock.json`?

A. Prevent all package updates permanently  
B. Record the exact dependency tree selected by npm  
C. Store HTTP routes  
D. Configure PowerShell execution policy

---

### 3. Multiple Choice

What is `node_modules`?

A. The JavaScript language specification  
B. Installed package files  
C. The Node.js executable  
D. The npm lockfile

---

### 4. True or False

`node_modules` should normally be committed to Git.

---

### 5. Multiple Choice

Which command initializes a project using default answers?

A. `node init`  
B. `npm.cmd init -y`  
C. `npx.cmd create package-lock`  
D. `npm.cmd start -y`

---

### 6. Multiple Choice

Which command adds a runtime dependency?

A. `npm.cmd install express`  
B. `node install express`  
C. `npm.cmd run express`  
D. `npx.cmd lock express`

---

### 7. Multiple Choice

Which command adds a development dependency?

A. `npm.cmd install eslint --runtime`  
B. `npm.cmd install --save-dev eslint`  
C. `node --dev eslint`  
D. `npm.cmd ci eslint`

---

### 8. Multiple Choice

What is a transitive dependency?

A. A dependency that is always global  
B. A dependency required by another dependency  
C. A dependency written in PowerShell  
D. An uninstalled package

---

### 9. Multiple Choice

Which command is intended for a clean, lockfile-based installation?

A. `npm.cmd ci`  
B. `npm.cmd run clean`  
C. `npx.cmd install`  
D. `node package-lock.json`

---

### 10. True or False

`npm ci` may be used to add a new dependency to `package.json`.

---

### 11. Multiple Choice

What does `npx` primarily do?

A. Executes package-provided command-line programs  
B. Replaces Node.js  
C. Encrypts npm packages  
D. Hosts production websites

---

### 12. True or False

A package executed through `npx` runs in a secure sandbox with no access to your files.

---

### 13. Multiple Choice

Which lockfile belongs to pnpm?

A. `package-lock.json`  
B. `pnpm-lock.yaml`  
C. `node-lock.json`  
D. `packages.xml`

---

### 14. Multiple Choice

What does this script mean?

```json
{
  "scripts": {
    "test": "node --test"
  }
}
```

A. npm installs a package named `test`  
B. `npm test` runs Node.js’s test runner  
C. Node.js automatically tests every file at startup  
D. PowerShell executes `package.json`

---

### 15. Code Reading

Given:

```json
{
  "scripts": {
    "prestart": "npm run build",
    "start": "node dist/index.js"
  }
}
```

What happens when `npm start` runs?

---

### 16. Multiple Choice

Why can this npm script find a locally installed ESLint binary?

```json
"lint": "eslint ."
```

A. Every machine includes ESLint  
B. npm adds `node_modules/.bin` to the script’s command search path  
C. PowerShell aliases `eslint` to Node.js  
D. The lockfile executes ESLint

---

### 17. Scenario

PowerShell reports that `npm.ps1` cannot run because scripts are disabled. What is the narrowest common workaround?

---

### 18. True or False

Changing execution policy to `Unrestricted` at machine scope is required to use npm.

---

### 19. Multiple Choice

Which command lists top-level installed packages?

A. `npm.cmd list --depth=0`  
B. `node --packages`  
C. `npx.cmd list`  
D. `Get-ChildItem package.json`

---

### 20. Short Answer

Why should npm and pnpm lockfiles not be mixed casually in one project?

---

# Quiz 5 Answer Key

### 1.

**B — Declare project metadata, dependencies, and scripts**

### 2.

**B — Record the exact dependency tree selected by npm**

### 3.

**B — Installed package files**

### 4.

**False**

It should normally be regenerated from the manifest and lockfile.

### 5.

**B — `npm.cmd init -y`**

### 6.

**A — `npm.cmd install express`**

### 7.

**B — `npm.cmd install --save-dev eslint`**

### 8.

**B — A dependency required by another dependency**

### 9.

**A — `npm.cmd ci`**

### 10.

**False**

Use `npm install package-name` to add dependencies.

### 11.

**A — Executes package-provided command-line programs**

### 12.

**False**

It executes with the current user’s permissions.

### 13.

**B — `pnpm-lock.yaml`**

### 14.

**B — `npm test` runs Node.js’s test runner**

### 15.

npm automatically runs `prestart` first, which builds the project. It then runs `start`, which executes:

```text
dist/index.js
```

### 16.

**B — npm adds `node_modules/.bin` to the script’s command search path**

### 17.

Use the Windows command wrapper explicitly:

```powershell
npm.cmd
```

Likewise:

```powershell
npx.cmd
```

This avoids changing execution policy.

### 18.

**False**

A global unrestricted policy is unnecessary and unsafe.

### 19.

**A — `npm.cmd list --depth=0`**

### 20.

They represent dependency state for different package managers. Mixing them can create competing sources of truth and inconsistent installations.

---

# Quiz 6: HTTP and Service Fundamentals

## Questions

### 1. Multiple Choice

In this URI, what is `127.0.0.1`?

```text
http://127.0.0.1:3000/health
```

A. Method  
B. Host  
C. Port  
D. Route

---

### 2. Multiple Choice

In the same URI, what is `3000`?

A. Host  
B. Status code  
C. Port  
D. Request body

---

### 3. Multiple Choice

In the same URI, what is `/health`?

A. Path or route  
B. Header  
C. Scheme  
D. Process ID

---

### 4. Multiple Choice

What does `GET` commonly indicate?

A. Retrieve information  
B. Delete a process  
C. Install a package  
D. Encrypt a response

---

### 5. Multiple Choice

What does `POST` commonly indicate?

A. Retrieve a static file only  
B. Submit data or request creation  
C. Stop the server  
D. Resolve a path

---

### 6. Multiple Choice

What does HTTP status `200` indicate?

A. Success  
B. Not found  
C. Internal server error  
D. Authentication required

---

### 7. Multiple Choice

What does HTTP status `404` indicate?

A. Success with no body  
B. Resource not found  
C. Request body too large  
D. Resource created

---

### 8. Multiple Choice

What does HTTP status `400` indicate?

A. Bad request  
B. Successful request  
C. Server startup  
D. Permanent redirect

---

### 9. Multiple Choice

What does HTTP status `413` indicate?

A. Resource conflict  
B. Request body too large  
C. Unsupported runtime  
D. Service healthy

---

### 10. Multiple Choice

Which response header identifies JSON content?

A. `Host: json`  
B. `Content-Type: application/json`  
C. `Port: json`  
D. `Method: POST`

---

### 11. Code Reading

What does this route test assert?

```javascript
assert.equal(response.status, 200);
assert.equal(body.status, "ok");
```

---

### 12. Multiple Choice

Why might a test server listen on port `0`?

A. Port `0` disables HTTP  
B. It asks the operating system to select an available port  
C. It grants administrator privileges  
D. It forces production mode

---

### 13. True or False

Request bodies may arrive in several data chunks.

---

### 14. Scenario

Why should a server enforce a maximum request-body size?

---

### 15. Multiple Choice

What is graceful shutdown?

A. Deleting the application before exit  
B. Closing the server and completing cleanup before process exit  
C. Immediately killing the operating system  
D. Returning status `404`

---

### 16. Multiple Choice

Which signal is commonly produced when a user presses `Ctrl+C`?

A. `SIGINT`  
B. `SIGPORT`  
C. `SIGJSON`  
D. `SIGHTTP`

---

### 17. Multiple Choice

Which PowerShell command parses a JSON HTTP response into an object?

A. `Invoke-RestMethod`  
B. `Get-Content`  
C. `Resolve-Path`  
D. `Get-Alias`

---

### 18. Implementation

Write a PowerShell request to:

```text
GET http://127.0.0.1:3000/health
```

---

### 19. Implementation

Write a PowerShell JSON `POST` request to `/echo` with:

```json
{
  "message": "Hello"
}
```

---

### 20. Short Answer

Why should a server return after sending a response for a matched route?

---

# Quiz 6 Answer Key

### 1.

**B — Host**

### 2.

**C — Port**

### 3.

**A — Path or route**

### 4.

**A — Retrieve information**

### 5.

**B — Submit data or request creation**

### 6.

**A — Success**

### 7.

**B — Resource not found**

### 8.

**A — Bad request**

### 9.

**B — Request body too large**

### 10.

**B — `Content-Type: application/json`**

### 11.

It asserts that:

- The request succeeded with status `200`.
- The JSON response body reports `status: "ok"`.

### 12.

**B — It asks the operating system to select an available port**

### 13.

**True**

HTTP request bodies are streams.

### 14.

To prevent unexpectedly large or malicious requests from consuming excessive memory or other resources.

### 15.

**B — Closing the server and completing cleanup before process exit**

### 16.

**A — `SIGINT`**

### 17.

**A — `Invoke-RestMethod`**

### 18.

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get
```

### 19.

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

### 20.

Without `return`, execution may continue and attempt to send another response, causing incorrect behavior or an error such as “headers already sent.”

---

# Quiz 7: Environment Variables and Process Scope

## Questions

### 1. Multiple Choice

What is a process?

A. A source-code file  
B. A running instance of a program  
C. A package lockfile  
D. A PowerShell alias

---

### 2. Multiple Choice

How does a child process receive environment variables?

A. It normally receives a copy of its parent’s environment at startup  
B. It reads every variable from Git  
C. It edits the parent’s memory directly  
D. It receives only machine-level variables

---

### 3. True or False

A Node.js child process can normally update the environment of the PowerShell parent that launched it.

---

### 4. Multiple Choice

Which syntax reads a process-scoped environment variable in PowerShell?

A. `$PORT`  
B. `$env:PORT`  
C. `process.env.PORT`  
D. `Env.PORT`

---

### 5. Multiple Choice

Which syntax reads an environment variable in Node.js?

A. `$env:PORT`  
B. `environment.PORT()`  
C. `process.env.PORT`  
D. `node.PORT`

---

### 6. Multiple Choice

What does this command do?

```powershell
$env:PORT = "3000"
```

A. Creates a permanent machine-level variable  
B. Sets `PORT` in the current PowerShell process  
C. Writes `PORT` into `.env`  
D. Converts `PORT` to a number

---

### 7. Multiple Choice

How can you remove a process-scoped environment variable in PowerShell?

A. `Delete-Variable PORT`  
B. `Remove-Item Env:PORT`  
C. `npm uninstall PORT`  
D. `Clear-Host PORT`

---

### 8. True or False

A variable set through `$env:` is automatically available in PowerShell terminals that were already open before it was set.

---

### 9. Multiple Choice

Which scope persists for new processes launched by the current Windows user?

A. Process  
B. User  
C. Function  
D. Pipeline

---

### 10. Multiple Choice

Which scope normally affects new processes for users across the computer and may require administrator permission?

A. Process  
B. User  
C. Machine  
D. Script

---

### 11. Code Reading

What does this retrieve?

```powershell
[System.Environment]::GetEnvironmentVariable(
    "EXAMPLE_NAME",
    [System.EnvironmentVariableTarget]::User
)
```

---

### 12. Code Reading

What does this do?

```powershell
[System.Environment]::SetEnvironmentVariable(
    "EXAMPLE_NAME",
    $null,
    [System.EnvironmentVariableTarget]::User
)
```

---

### 13. True or False

An already-running PowerShell process automatically refreshes its environment whenever a user-scoped variable changes.

---

### 14. Multiple Choice

What type does Node.js normally receive for a defined environment variable?

A. Number  
B. Boolean  
C. String  
D. Array

---

### 15. Code Reading

What is the result of this JavaScript expression?

```javascript
Boolean("false")
```

A. `false`  
B. `true`  
C. `undefined`  
D. It throws an error

---

### 16. Short Answer

Why is this configuration code unsafe?

```javascript
const enabled = Boolean(process.env.FEATURE_ENABLED);
```

---

### 17. Implementation

Write PowerShell commands that:

1. Set `NODE_ENV` to `test`
2. Start Node.js and print that value
3. Remove the variable afterward, even if Node.js fails

---

### 18. Scenario

You need to supply `PORT=8080` to only one child process without changing the current PowerShell environment. What general approach should you use?

---

### 19. True or False

Process-scoped environment variables are an appropriate mechanism for temporarily overriding local `.env` values.

---

### 20. Short Answer

Explain the direction of environment inheritance between PowerShell and Node.js.

---

# Quiz 7 Answer Key

### 1.

**B — A running instance of a program**

### 2.

**A — It normally receives a copy of its parent’s environment at startup**

### 3.

**False**

A child can change its own environment, but it cannot normally modify its parent process’s environment.

### 4.

**B — `$env:PORT`**

### 5.

**C — `process.env.PORT`**

### 6.

**B — Sets `PORT` in the current PowerShell process**

Future child processes launched from that shell inherit the value.

### 7.

**B — `Remove-Item Env:PORT`**

You can also use:

```powershell
$env:PORT = $null
```

### 8.

**False**

Unrelated existing processes do not automatically receive the change.

### 9.

**B — User**

### 10.

**C — Machine**

Use machine scope only when its broader effect is necessary.

### 11.

It reads the persistent user-scoped value named `EXAMPLE_NAME`.

It does not merely read the current process’s `$env:EXAMPLE_NAME` copy.

### 12.

It removes the persistent user-scoped value named `EXAMPLE_NAME`.

Passing `$null` deletes the value at that scope.

### 13.

**False**

Open a new terminal or update the current process explicitly.

### 14.

**C — String**

A defined value such as:

```text
PORT=3000
```

is received as:

```javascript
"3000"
```

### 15.

**B — `true`**

Every nonempty string is truthy, including `"false"`.

### 16.

The string `"false"` is nonempty, so `Boolean("false")` evaluates to `true`. The code should parse an explicit allowed vocabulary:

```javascript
function parseBoolean(value) {
  if (value === "true") {
    return true;
  }

  if (value === "false") {
    return false;
  }

  throw new Error("FEATURE_ENABLED must be true or false.");
}
```

### 17.

```powershell
$env:NODE_ENV = "test"

try {
    node -e 'console.log(process.env.NODE_ENV);'
}
finally {
    Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
}
```

### 18.

Create a child process with its own environment map—for example, through:

```powershell
[System.Diagnostics.ProcessStartInfo]
```

Then set:

```powershell
$startInfo.Environment["PORT"] = "8080"
```

This confines the value to that child process.

### 19.

**True**

With normal `dotenv` precedence, an existing process value can override the corresponding `.env` fallback.

### 20.

PowerShell prepares an environment and launches Node.js. Node.js receives a copy at startup. Changes made later inside Node.js do not travel back into the PowerShell parent.

---

# Quiz 8: `.env`, Validation, and Secret Handling

## Questions

### 1. Multiple Choice

What is the intended role of `.env.example`?

A. Store production credentials  
B. Document required variables with safe placeholders  
C. Replace `package.json`  
D. Encrypt local configuration

---

### 2. Multiple Choice

Which file may contain private local development values and should normally be ignored by Git?

A. `.env`  
B. `.env.example`  
C. `.gitignore`  
D. `package-lock.json`

---

### 3. True or False

A filename beginning with a dot is automatically encrypted.

---

### 4. Multiple Choice

What does `dotenv` commonly do?

A. Encrypts every environment variable  
B. Loads values from a `.env` file into an environment object  
C. Uploads secrets to Git  
D. Converts every value into the correct application type

---

### 5. Multiple Choice

Given:

```javascript
dotenv.config({
  override: false,
});
```

which value wins when both the process environment and `.env` define `PORT`?

A. `.env`  
B. Existing process environment  
C. The numerically larger value  
D. Whichever is read last in source code

---

### 6. True or False

`dotenv` automatically proves that a port is numeric and within the valid TCP range.

---

### 7. Multiple Choice

Why is a validation module necessary?

A. Environment values should be treated as untrusted strings  
B. JSON cannot contain numbers  
C. PowerShell cannot start Node.js  
D. npm scripts do not support variables

---

### 8. Code Reading

What problem exists here?

```javascript
const port = Number(process.env.PORT) || 3000;
```

---

### 9. Multiple Choice

Which port value should be rejected?

A. `"3000"`  
B. `"8080"`  
C. `"not-a-port"`  
D. `"443"`

---

### 10. Multiple Choice

Which range represents valid TCP port numbers in the tutorial?

A. `0` through `100`  
B. `1` through `65535`  
C. `3000` through `8080` only  
D. Any JavaScript number

---

### 11. Multiple Choice

Which value is normally safe to include in public diagnostic output?

A. `APP_SECRET`  
B. Database password  
C. `PORT`  
D. Private key

---

### 12. Multiple Choice

Which approach is safer for public configuration output?

A. Copy every property and attempt to remove known secrets  
B. Explicitly include only approved public fields  
C. Print `process.env`  
D. Base64-encode every value

---

### 13. True or False

Base64 encoding turns a secret into securely encrypted data.

---

### 14. Multiple Choice

Where should production secrets ideally come from?

A. Hardcoded JavaScript constants  
B. `.env.example` committed to Git  
C. An approved secret-management or deployment system  
D. A public PowerShell profile

---

### 15. Scenario

A real API token was accidentally committed to Git. Is adding `.env` to `.gitignore` sufficient remediation? Explain.

---

### 16. Multiple Choice

Why should production mode require a stronger secret than a disposable development environment?

A. Production credentials protect real operations and data  
B. JavaScript cannot read short strings  
C. npm refuses short values  
D. PowerShell automatically deletes them

---

### 17. Code Reading

What does this function accomplish?

```javascript
function publicConfiguration(configuration) {
  return Object.freeze({
    environment: configuration.environment,
    host: configuration.host,
    port: configuration.port,
    isProduction: configuration.isProduction,
  });
}
```

---

### 18. Implementation

Write `.gitignore` rules that:

- Ignore `.env`
- Ignore `.env.*`
- Keep `.env.example` trackable

---

### 19. Implementation

Write JavaScript that rejects a missing or blank `APP_SECRET`.

---

### 20. Short Answer

Why should project secrets not be stored in the PowerShell profile?

---

# Quiz 8 Answer Key

### 1.

**B — Document required variables with safe placeholders**

### 2.

**A — `.env`**

### 3.

**False**

A dot-prefixed filename is ordinarily still plaintext.

### 4.

**B — Loads values from a `.env` file into an environment object**

It does not automatically validate application-specific requirements.

### 5.

**B — Existing process environment**

`override: false` preserves existing values.

### 6.

**False**

The application must validate and convert values explicitly.

### 7.

**A — Environment values should be treated as untrusted strings**

### 8.

It silently substitutes `3000` for several invalid inputs.

For example:

```javascript
Number("not-a-port")
```

produces `NaN`, which is falsy, so the invalid configuration is hidden by the fallback.

It can also mishandle `"0"` by silently choosing `3000`.

A safer implementation rejects invalid input explicitly.

### 9.

**C — `"not-a-port"`**

### 10.

**B — `1` through `65535`**

### 11.

**C — `PORT`**

Whether any field is safe to log still depends on application policy, but a listening port is ordinarily public operational configuration.

### 12.

**B — Explicitly include only approved public fields**

This is an allowlist approach.

### 13.

**False**

Base64 is reversible encoding, not encryption.

### 14.

**C — An approved secret-management or deployment system**

Examples include a cloud secret manager, Vault, or a protected CI/CD secret store.

### 15.

No. The token may remain in Git history and should be treated as compromised.

Required actions generally include:

1. Revoke or rotate the token.
2. Replace it in active environments.
3. Remove it from current files.
4. Follow approved Git-history cleanup procedures.
5. Inspect logs, artifacts, backups, and forks as appropriate.

### 16.

**A — Production credentials protect real operations and data**

### 17.

It creates an immutable public projection containing only approved nonsecret fields. It omits `appSecret`.

### 18.

```gitignore
.env
.env.*
!.env.example
```

### 19.

```javascript
function requireSecret(environment) {
  const value = environment.APP_SECRET;

  if (
    typeof value !== "string" ||
    value.trim().length === 0
  ) {
    throw new Error(
      "APP_SECRET is required and cannot be empty.",
    );
  }

  return value.trim();
}
```

### 20.

A profile runs for many shell sessions and can:

- Leak the secret into unrelated child processes
- Override unrelated projects
- Be copied into backups or dotfile repositories
- Keep credentials active longer than intended
- Expose them through diagnostics

Profiles should hold general functions and aliases, not project credentials.

---

# Quiz 9: PowerShell Profiles and Developer Workflow

## Questions

### 1. Multiple Choice

What is a PowerShell profile?

A. A script loaded when an associated PowerShell session starts  
B. A Node.js lockfile  
C. An encrypted Windows password database  
D. An HTTP health endpoint

---

### 2. Multiple Choice

Which variable identifies PowerShell profile paths?

A. `$HOME`  
B. `$PROFILE`  
C. `$PATH`  
D. `$SHELL_CONFIG`

---

### 3. True or False

The all-users profile is always the best place for personal project shortcuts.

---

### 4. Multiple Choice

Why should an existing profile be backed up before modification?

A. PowerShell requires two profiles  
B. It may contain valuable personal configuration  
C. npm deletes profiles during installation  
D. Profiles cannot be edited directly

---

### 5. Multiple Choice

What does dot-sourcing do here?

```powershell
. $PROFILE.CurrentUserCurrentHost
```

A. Deletes the profile  
B. Executes the profile in the current scope  
C. Opens it in Notepad  
D. Creates a child process

---

### 6. Multiple Choice

When should a function be preferred over an alias?

A. When the shortcut needs validation or several commands  
B. When storing a password  
C. Only for single-letter names  
D. Never

---

### 7. True or False

This reliably creates an alias for a complete command string:

```powershell
Set-Alias build "npm.cmd run build"
```

---

### 8. Implementation

Write a function named `Enter-ExampleProject` that:

- Constructs `$HOME\example-project`
- Verifies that it exists as a directory
- Navigates to it
- Throws a clear error if it is missing

---

### 9. Multiple Choice

What is the purpose of marked profile-block comments such as:

```text
# BEGIN EXAMPLE
# END EXAMPLE
```

A. Encrypt the enclosed code  
B. Make a managed section identifiable for safe replacement  
C. Disable execution policy  
D. Install npm

---

### 10. Multiple Choice

What does idempotent profile installation mean?

A. Every run appends another duplicate block  
B. Repeated runs produce the same intended profile state  
C. The profile runs only once  
D. The profile requires administrator rights

---

### 11. True or False

A profile installer should preserve unrelated content outside its managed markers.

---

### 12. Multiple Choice

Which command starts PowerShell without loading profiles?

A. `pwsh -NoProfile`  
B. `pwsh -NoGit`  
C. `node -NoProfile`  
D. `npm.cmd --clean`

---

### 13. Scenario

A profile syntax error causes startup errors. What is a useful first troubleshooting action?

---

### 14. Multiple Choice

Which content is appropriate for a profile?

A. A production database password  
B. A reusable project-navigation function  
C. A private cloud key  
D. A hardcoded access token

---

### 15. Short Answer

Why might setting `$env:NODE_ENV = "production"` globally in a profile be dangerous?

---

# Quiz 9 Answer Key

### 1.

**A — A script loaded when an associated PowerShell session starts**

### 2.

**B — `$PROFILE`**

### 3.

**False**

Use the narrowest appropriate profile scope. Personal shortcuts ordinarily belong in a current-user profile.

### 4.

**B — It may contain valuable personal configuration**

### 5.

**B — Executes the profile in the current scope**

Functions and aliases defined by it become available in the existing session.

### 6.

**A — When the shortcut needs validation or several commands**

### 7.

**False**

PowerShell aliases point to command names, not arbitrary command strings. Use a function:

```powershell
function Invoke-ProjectBuild {
    npm.cmd run build
}
```

### 8.

```powershell
function Enter-ExampleProject {
    [CmdletBinding()]
    param()

    $projectRoot = Join-Path `
        -Path $HOME `
        -ChildPath "example-project"

    if (-not (
        Test-Path `
            -LiteralPath $projectRoot `
            -PathType Container
    )) {
        throw "Example project does not exist: $projectRoot"
    }

    Set-Location -LiteralPath $projectRoot
}
```

### 9.

**B — Make a managed section identifiable for safe replacement**

### 10.

**B — Repeated runs produce the same intended profile state**

### 11.

**True**

### 12.

**A — `pwsh -NoProfile`**

For Windows PowerShell:

```powershell
powershell.exe -NoProfile
```

### 13.

Start a clean session without profiles:

```powershell
pwsh -NoProfile
```

Then inspect or parse the profile file and correct the syntax error.

### 14.

**B — A reusable project-navigation function**

### 15.

It can:

- Affect unrelated Node.js projects
- Override local `.env` development settings
- Cause commands to run in production mode unexpectedly
- Persist across every child process started from that shell

Project-specific runtime modes should be supplied intentionally.

---

# Quiz 10: Cumulative Final Assessment

## Questions

### 1. Multiple Choice

Which command displays the current directory?

A. `Get-Location`  
B. `Get-ChildItem`  
C. `Get-Item`  
D. `Test-Path`

---

### 2. Multiple Choice

Which command lists hidden files as well as ordinary files?

A. `Get-ChildItem -Force`  
B. `Get-ChildItem -HiddenOnly`  
C. `Get-Location -Force`  
D. `Resolve-Path -All`

---

### 3. Multiple Choice

Which command finds JSON files recursively beneath the current directory?

A.

```powershell
Get-ChildItem `
    -Path . `
    -Filter "*.json" `
    -File `
    -Recurse
```

B.

```powershell
Get-Location "*.json"
```

C.

```powershell
Set-Content -Recurse "*.json"
```

D.

```powershell
Remove-Item "*.json"
```

---

### 4. Scenario

You need to remove a non-empty disposable directory. List the six safety stages in order.

---

### 5. Code Review

Identify at least three risks in this command:

```powershell
Remove-Item * -Recurse -Force
```

---

### 6. Implementation

Write PowerShell that creates:

```text
.\workspace\data\raw
```

including missing parent directories.

---

### 7. Implementation

Write PowerShell that creates an empty file:

```text
.\workspace\README.md
```

---

### 8. Implementation

Write PowerShell that copies:

```text
.\workspace\README.md
```

to:

```text
.\archive\README-copy.md
```

using exact paths.

---

### 9. Multiple Choice

Which artifact records exact npm dependency resolution?

A. `.env`  
B. `package-lock.json`  
C. `node_modules`  
D. `$PROFILE`

---

### 10. Multiple Choice

Which command reconstructs dependencies from the npm lockfile in a clean installation?

A. `npm.cmd ci`  
B. `npm.cmd start`  
C. `node package.json`  
D. `npx.cmd ci`

---

### 11. Code Review

Explain the purpose of each script:

```json
{
  "scripts": {
    "dev": "node --watch src/index.js",
    "build": "node scripts/build.js",
    "start": "node dist/index.js",
    "check": "npm run lint && npm test && npm run build"
  }
}
```

---

### 12. Multiple Choice

Which command should commonly be tried first when `npm.ps1` is blocked by execution policy?

A. `npm.cmd`  
B. Disable all Windows security  
C. Run every terminal as administrator  
D. Delete PowerShell

---

### 13. Code Reading

What does this JavaScript accomplish?

```javascript
const {
  createApp,
} = require("./app");
```

---

### 14. Code Reading

Why is this testable architecture useful?

```javascript
const app = createApp();
const server = http.createServer(app);
```

---

### 15. Multiple Choice

Which route is commonly used to report whether a service is operational?

A. `/delete-all`  
B. `/health`  
C. `/password`  
D. `/node_modules`

---

### 16. Implementation

Write a PowerShell request that sends this object to `POST /echo`:

```json
{
  "message": "Assessment",
  "passed": true
}
```

Use port `3000`.

---

### 17. Multiple Choice

What is the correct configuration precedence for the project?

A. `.env` always overwrites the process environment  
B. Existing process environment, then `.env` fallback  
C. `package-lock.json`, then `.env`  
D. PowerShell profile, then source-code constants

---

### 18. Code Review

Why is this dangerous?

```javascript
console.log(process.env);
```

---

### 19. Implementation

Write JavaScript that converts and validates a raw `PORT` string. It must:

- Contain only decimal digits
- Convert to a number
- Be a safe integer
- Be between `1` and `65535`

---

### 20. Multiple Choice

Which file should contain safe placeholders rather than live credentials?

A. `.env`  
B. `.env.example`  
C. `node_modules/.env`  
D. `package-lock.json`

---

### 21. Scenario

A production system supplies:

```text
PORT=8080
```

while local `.env` contains:

```text
PORT=3000
```

Which port should the application use, and why?

---

### 22. Code Reading

What security property does this function provide?

```javascript
function publicConfiguration(configuration) {
  return {
    environment: configuration.environment,
    host: configuration.host,
    port: configuration.port,
  };
}
```

---

### 23. True or False

A local `.env` file is equivalent to a managed production secret vault.

---

### 24. Scenario

The quality-gate script is:

```json
"check": "npm run lint && npm test && npm run build && npm run smoke"
```

What happens if the tests fail?

---

### 25. Multiple Choice

What is a smoke test?

A. A test that checks one critical real startup path  
B. A command that deletes build output  
C. A package installation mode  
D. A PowerShell execution policy

---

### 26. Scenario

Why should `src` and `dist` be separate directories?

---

### 27. Scenario

Why should the project test source behavior and also start the built service in a smoke test?

---

### 28. Implementation

Write PowerShell that temporarily sets:

```text
NODE_ENV=production
PORT=8080
```

runs:

```powershell
npm.cmd run config
```

and restores the previous values afterward.

Do not hardcode or print a secret in this answer.

---

### 29. Scenario

A developer adds this to `$PROFILE`:

```powershell
$env:APP_SECRET = "actual-production-secret"
```

List four problems with this design.

---

### 30. Architecture

Place these layers in the correct order from lowest-level foundation to highest-level convenience:

- npm scripts and build automation
- PowerShell filesystem operations
- PowerShell profile shortcuts
- Node.js and package tools
- Runtime environment configuration

---

# Quiz 10 Answer Key

### 1.

**A — `Get-Location`**

### 2.

**A — `Get-ChildItem -Force`**

### 3.

**A**

```powershell
Get-ChildItem `
    -Path . `
    -Filter "*.json" `
    -File `
    -Recurse
```

### 4.

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

### 5.

Possible risks include:

1. `*` is a broad wildcard.
2. Its meaning depends on the current location.
3. `-Recurse` expands the operation through directory trees.
4. `-Force` reduces ordinary hidden/read-only safeguards.
5. No explicit target boundary is visible.
6. No `-WhatIf` preview is used.
7. The command may permanently remove many unrelated items.

### 6.

```powershell
New-Item `
    -Path .\workspace\data\raw `
    -ItemType Directory `
    -Force
```

### 7.

```powershell
New-Item `
    -Path .\workspace\README.md `
    -ItemType File
```

### 8.

```powershell
Copy-Item `
    -LiteralPath .\workspace\README.md `
    -Destination .\archive\README-copy.md `
    -ErrorAction Stop
```

The destination parent must already exist.

### 9.

**B — `package-lock.json`**

### 10.

**A — `npm.cmd ci`**

### 11.

- `dev`: runs source directly and restarts when source changes.
- `build`: creates generated application output.
- `start`: runs the generated entry point.
- `check`: runs linting, then tests, then a build; each later command runs only if the previous one succeeds.

### 12.

**A — `npm.cmd`**

### 13.

It imports the `createApp` export from the nearby CommonJS module `app.js`.

### 14.

Application construction is separate from network startup. Tests can create the application without launching a permanent server process.

### 15.

**B — `/health`**

### 16.

```powershell
$body = @{
    message = "Assessment"
    passed = $true
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

### 17.

**B — Existing process environment, then `.env` fallback**

### 18.

The environment may contain:

- Passwords
- Tokens
- Connection strings
- Cloud credentials
- Secrets unrelated to the current application

Printing it can leak sensitive information into logs.

### 19.

```javascript
function parsePort(rawValue) {
  if (
    typeof rawValue !== "string" ||
    !/^\d+$/.test(rawValue)
  ) {
    throw new Error(
      "PORT must contain only decimal digits.",
    );
  }

  const port = Number(rawValue);

  if (
    !Number.isSafeInteger(port) ||
    port < 1 ||
    port > 65_535
  ) {
    throw new Error(
      "PORT must be an integer from 1 through 65535.",
    );
  }

  return port;
}
```

### 20.

**B — `.env.example`**

### 21.

The application should use:

```text
8080
```

The existing process environment has higher precedence than the `.env` fallback when `override` is disabled.

### 22.

It creates an allowlisted public view that omits private fields such as `appSecret`. This reduces the risk of secret disclosure in diagnostics.

### 23.

**False**

`.env` is normally plaintext local configuration.

### 24.

The command chain stops at the failed test command. The build and smoke test do not run because `&&` requires the previous command to succeed.

### 25.

**A — A test that checks one critical real startup path**

For this project, it starts the built service and calls a health endpoint.

### 26.

`src` contains human-maintained source code. `dist` contains reproducible generated output. Separating them:

- Prevents generated files from being mistaken for source
- Makes cleanup safe
- Supports deployment packaging
- Allows `dist` to be ignored and rebuilt

### 27.

Source-level tests verify application behavior in an isolated, efficient form. A built-service smoke test additionally verifies that:

- The build output exists
- The real entry point starts
- Runtime configuration works
- The listener opens
- A real HTTP request succeeds

They detect different failure classes.

### 28.

```powershell
$previousNodeEnvironment = $env:NODE_ENV
$previousPort = $env:PORT

try {
    $env:NODE_ENV = "production"
    $env:PORT = "8080"

    # APP_SECRET must already be supplied securely by the approved
    # environment or isolated child-process mechanism.
    npm.cmd run config

    if ($LASTEXITCODE -ne 0) {
        throw "Configuration validation failed."
    }
}
finally {
    if ($null -eq $previousNodeEnvironment) {
        Remove-Item Env:NODE_ENV -ErrorAction SilentlyContinue
    }
    else {
        $env:NODE_ENV = $previousNodeEnvironment
    }

    if ($null -eq $previousPort) {
        Remove-Item Env:PORT -ErrorAction SilentlyContinue
    }
    else {
        $env:PORT = $previousPort
    }
}
```

### 29.

Problems include:

1. The secret enters every child process started from the shell.
2. It can affect unrelated projects.
3. It may be copied into profile backups.
4. It may enter a dotfiles repository.
5. It persists longer than necessary.
6. It may appear in diagnostics.
7. Changing projects does not remove it.
8. Rotation becomes harder to manage.
9. A production credential is exposed as plaintext.

### 30.

Correct order:

```text
1. PowerShell filesystem operations
2. Node.js and package tools
3. npm scripts and build automation
4. Runtime environment configuration
5. PowerShell profile shortcuts
```

---

# Practical Lab Quiz

This section requires the learner to perform commands rather than select answers.

Use a disposable workspace:

```powershell
$assessmentRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-series-assessment"
```

Create it:

```powershell
if (Test-Path -LiteralPath $assessmentRoot) {
    Remove-Item `
        -LiteralPath $assessmentRoot `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

$null = New-Item `
    -Path $assessmentRoot `
    -ItemType Directory `
    -ErrorAction Stop

Set-Location -LiteralPath $assessmentRoot
```

## Tasks

### Task 1: Directory Creation

Create:

```text
cli-series-assessment/
├── archive/
├── incoming/
└── workspace/
    ├── config/
    └── src/
```

---

### Task 2: File Creation

Create:

```text
workspace/config/app.json
workspace/src/index.js
incoming/records.csv
```

Use these exact contents.

#### `workspace/config/app.json`

```json
{
  "environment": "development",
  "port": 3000
}
```

#### `workspace/src/index.js`

```javascript
"use strict";

console.log("Assessment application");
```

#### `incoming/records.csv`

```csv
id,name
1,Ada
2,Grace
```

---

### Task 3: Inspection

Produce a recursive report containing:

- Name
- Extension
- Length
- Full path

Include files only.

---

### Task 4: Copy and Verification

Copy:

```text
incoming/records.csv
```

to:

```text
archive/records.backup.csv
```

Verify the copy with SHA-256.

---

### Task 5: Move and Rename

Move:

```text
workspace/config/app.json
```

to:

```text
archive/application-config.json
```

Verify that the old path is absent and the new path exists.

---

### Task 6: Safe Deletion

Select only `.csv` files from `incoming`.

1. Display their full paths.
2. Preview deletion.
3. Delete them.
4. Verify that no `.csv` files remain in `incoming`.
5. Verify that the archived backup remains.

---

### Task 7: Environment Inheritance

Set:

```text
ASSESSMENT_MODE=test
```

in the current PowerShell process.

Start Node.js and verify that it receives the value. Remove the variable afterward.

---

### Task 8: Cleanup Preview

Preview removal of the complete assessment workspace, but do not execute it until all prior tasks are graded.

---

# Practical Lab Answer Key

## Task 1

```powershell
$directories = @(
    "$assessmentRoot\archive"
    "$assessmentRoot\incoming"
    "$assessmentRoot\workspace\config"
    "$assessmentRoot\workspace\src"
)

foreach ($directory in $directories) {
    $null = New-Item `
        -Path $directory `
        -ItemType Directory `
        -Force `
        -ErrorAction Stop
}
```

Verification:

```powershell
$directories |
    ForEach-Object {
        [PSCustomObject]@{
            Path = $_
            Exists = Test-Path `
                -LiteralPath $_ `
                -PathType Container
        }
    }
```

---

## Task 2

```powershell
Set-Content `
    -LiteralPath "$assessmentRoot\workspace\config\app.json" `
    -Value @'
{
  "environment": "development",
  "port": 3000
}
'@ `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$assessmentRoot\workspace\src\index.js" `
    -Value @'
"use strict";

console.log("Assessment application");
'@ `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$assessmentRoot\incoming\records.csv" `
    -Value @'
id,name
1,Ada
2,Grace
'@ `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Verification:

```powershell
Get-ChildItem `
    -LiteralPath $assessmentRoot `
    -File `
    -Recurse |
    Select-Object Name, Length, FullName
```

---

## Task 3

```powershell
Get-ChildItem `
    -LiteralPath $assessmentRoot `
    -File `
    -Recurse |
    Sort-Object FullName |
    Select-Object Name, Extension, Length, FullName
```

---

## Task 4

```powershell
$copySource = Join-Path `
    -Path $assessmentRoot `
    -ChildPath "incoming\records.csv"

$copyDestination = Join-Path `
    -Path $assessmentRoot `
    -ChildPath "archive\records.backup.csv"

Copy-Item `
    -LiteralPath $copySource `
    -Destination $copyDestination `
    -ErrorAction Stop
```

Verification:

```powershell
$sourceHash = (
    Get-FileHash `
        -LiteralPath $copySource `
        -Algorithm SHA256
).Hash

$destinationHash = (
    Get-FileHash `
        -LiteralPath $copyDestination `
        -Algorithm SHA256
).Hash

$sourceHash -eq $destinationHash
```

Expected result:

```text
True
```

---

## Task 5

```powershell
$oldConfigPath = Join-Path `
    -Path $assessmentRoot `
    -ChildPath "workspace\config\app.json"

$newConfigPath = Join-Path `
    -Path $assessmentRoot `
    -ChildPath "archive\application-config.json"

Move-Item `
    -LiteralPath $oldConfigPath `
    -Destination $newConfigPath `
    -ErrorAction Stop
```

Verification:

```powershell
[PSCustomObject]@{
    OldPathIsAbsent = -not (
        Test-Path -LiteralPath $oldConfigPath
    )
    NewPathExists = Test-Path `
        -LiteralPath $newConfigPath `
        -PathType Leaf
}
```

Both values should be `True`.

---

## Task 6

Select:

```powershell
$csvTargets = @(
    Get-ChildItem `
        -LiteralPath "$assessmentRoot\incoming" `
        -Filter "*.csv" `
        -File
)
```

Inspect:

```powershell
$csvTargets |
    Select-Object FullName
```

Preview:

```powershell
$csvTargets |
    Remove-Item -WhatIf
```

Execute:

```powershell
$csvTargets |
    Remove-Item -ErrorAction Stop
```

Verify:

```powershell
[PSCustomObject]@{
    IncomingCsvCount = @(
        Get-ChildItem `
            -LiteralPath "$assessmentRoot\incoming" `
            -Filter "*.csv" `
            -File
    ).Count
    ArchivedBackupExists = Test-Path `
        -LiteralPath "$assessmentRoot\archive\records.backup.csv" `
        -PathType Leaf
}
```

Expected result:

```text
IncomingCsvCount    : 0
ArchivedBackupExists: True
```

---

## Task 7

```powershell
$env:ASSESSMENT_MODE = "test"

try {
    $receivedMode = node -e '
process.stdout.write(process.env.ASSESSMENT_MODE ?? "");
'

    if ($receivedMode -ne "test") {
        throw "Node.js did not receive ASSESSMENT_MODE."
    }
}
finally {
    Remove-Item `
        Env:ASSESSMENT_MODE `
        -ErrorAction SilentlyContinue
}
```

Verification:

```powershell
[PSCustomObject]@{
    ChildReceivedTest = $receivedMode -eq "test"
    ParentVariableRemoved = -not (
        Test-Path Env:ASSESSMENT_MODE
    )
}
```

Both values should be `True`.

---

## Task 8

Leave the directory first:

```powershell
Set-Location -LiteralPath $HOME
```

Inspect:

```powershell
Get-ChildItem `
    -LiteralPath $assessmentRoot `
    -Recurse `
    -Force |
    Select-Object FullName
```

Preview:

```powershell
Remove-Item `
    -LiteralPath $assessmentRoot `
    -Recurse `
    -Force `
    -WhatIf
```

The assessment remains after preview:

```powershell
Test-Path `
    -LiteralPath $assessmentRoot `
    -PathType Container
```

Expected result:

```text
True
```

After grading, optional real cleanup is:

```powershell
Remove-Item `
    -LiteralPath $assessmentRoot `
    -Recurse `
    -Force `
    -Confirm
```

---

# Final Assessment Rubric

## Knowledge Quizzes

| Quiz | Topic | Suggested points |
|---|---|---:|
| Quiz 1 | Reading PowerShell | 18 |
| Quiz 2 | Navigation and paths | 17 |
| Quiz 3 | Filesystem safety | 31 |
| Quiz 4 | JavaScript and Node.js | 24 |
| Quiz 5 | npm and packages | 22 |
| Quiz 6 | HTTP | 23 |
| Quiz 7 | Environment and processes | 24 |
| Quiz 8 | Configuration and secrets | 25 |
| Quiz 9 | PowerShell profiles | 18 |
| Quiz 10 | Cumulative assessment | 48 |

## Practical Lab

Suggested scoring:

| Task | Points |
|---|---:|
| Directory creation | 5 |
| File creation | 8 |
| Recursive inspection | 4 |
| Copy and hash verification | 7 |
| Move and rename verification | 6 |
| Safe deletion workflow | 10 |
| Environment inheritance and cleanup | 7 |
| Cleanup preview | 3 |
| **Total** | **50** |

## Practical Evaluation Criteria

Award full credit when the learner:

- Uses exact paths for mutations
- Checks item types
- Uses `-WhatIf` before deletion
- Verifies the result
- Preserves unrelated files
- Uses `try`/`finally` for temporary environment state
- Checks command failures
- Avoids unnecessary `-Force`
- Does not expose secrets
- Uses native PowerShell cmdlet names in reusable code

Deduct points when the learner:

- Uses an uninspected broad wildcard
- Deletes without previewing
- Assumes the current directory
- Leaves temporary environment variables set
- Verifies only command output instead of filesystem state
- Prints sensitive values
- Uses administrator access without justification

---

# Recommended Quiz Placement

Use the quizzes in this order:

```text
Primer 1
  → Quiz 1

Primer 2 and Part 1
  → Quiz 2
  → Quiz 3

Part 2
  → Practical Lab Tasks 1–6

Primer 3 and Part 3
  → Quiz 4
  → Quiz 5
  → Quiz 6

Primer 4 and Part 4
  → Quiz 7
  → Quiz 8
  → Quiz 9

Part 5
  → Quiz 10
  → Complete Practical Lab
```

For a closed-book assessment, present only the question sections. For guided study, allow learners to run commands and consult built-in help:

```powershell
Get-Command
Get-Help
Get-Member
```


