# Part 1: Navigating the File System like a Native

A command-line shell always operates from a current location. Before you can create applications, install packages, or execute scripts, you must be able to answer three questions:

1. Where am I?
2. What is here?
3. How do I get somewhere else?

In this part, you will learn to navigate Windows without relying on File Explorer. You will also discover that familiar commands such as `cd`, `dir`, `ls`, and `pwd` are aliases—short names that point to native PowerShell commands.

By the end of Part 1, you will be able to:

- Identify your current directory
- Navigate with absolute and relative paths
- Move between Windows drives
- Return to your home directory
- Handle paths containing spaces
- Use tab completion
- List files and directories
- Filter by name, extension, or item type
- Include hidden files
- inspect nested directory trees recursively
- Distinguish aliases from native PowerShell cmdlets

---

## 1.1 Create a Safe Navigation Laboratory

Before learning navigation, we need a predictable directory tree to explore.

This one-time setup creates the practice environment introduced in Part 0. File creation will be covered thoroughly in Part 2; for now, run the setup as a complete block.

### The Target

Create this directory tree under your home directory:

```text
$HOME/
└── cli-developer-environment-series/
    └── filesystem-lab/
        ├── archive/
        │   ├── 2024/
        │   │   └── old-notes.txt
        │   └── 2025/
        │       └── previous-report.txt
        ├── documents/
        │   ├── guides/
        │   │   ├── powershell-basics.md
        │   │   └── node-setup.md
        │   ├── notes.txt
        │   └── project-plan.md
        ├── incoming/
        │   ├── data.csv
        │   └── raw-data.json
        └── workspace/
            ├── config/
            │   ├── app.development.json
            │   └── app.production.json
            ├── logs/
            │   ├── application.log
            │   └── debug.log
            └── src/
                ├── index.js
                └── server.js
```

The setup also creates one hidden file:

```text
filesystem-lab/.navigation-secret
```

This is not a real secret. It exists only to demonstrate hidden-file discovery.

### The Concept

A laboratory is a controlled place where experiments are safe. We will practice inside a dedicated directory instead of navigating through or modifying important personal files.

The script is **idempotent**, meaning it can be run repeatedly without producing duplicate directories or failing merely because an item already exists.

### The Implementation

Copy and run the entire block:

```powershell
$seriesRoot = Join-Path -Path $HOME -ChildPath "cli-developer-environment-series"
$labRoot = Join-Path -Path $seriesRoot -ChildPath "filesystem-lab"

$directories = @(
    $seriesRoot
    $labRoot
    (Join-Path $labRoot "archive")
    (Join-Path $labRoot "archive\2024")
    (Join-Path $labRoot "archive\2025")
    (Join-Path $labRoot "documents")
    (Join-Path $labRoot "documents\guides")
    (Join-Path $labRoot "incoming")
    (Join-Path $labRoot "workspace")
    (Join-Path $labRoot "workspace\config")
    (Join-Path $labRoot "workspace\logs")
    (Join-Path $labRoot "workspace\src")
)

foreach ($directory in $directories) {
    if (-not (Test-Path -LiteralPath $directory)) {
        $null = New-Item -Path $directory -ItemType Directory
    }
}

$files = @{
    (Join-Path $labRoot "archive\2024\old-notes.txt") = @"
Archived notes from 2024.
This file exists for recursive navigation practice.
"@

    (Join-Path $labRoot "archive\2025\previous-report.txt") = @"
Previous annual report.
Status: archived
"@

    (Join-Path $labRoot "documents\guides\powershell-basics.md") = @"
# PowerShell Basics

PowerShell commands normally use a Verb-Noun naming pattern.
"@

    (Join-Path $labRoot "documents\guides\node-setup.md") = @"
# Node.js Setup

Node.js installation will be covered in Part 3.
"@

    (Join-Path $labRoot "documents\notes.txt") = @"
Navigation laboratory notes.
Use this file when practicing filters.
"@

    (Join-Path $labRoot "documents\project-plan.md") = @"
# Project Plan

1. Learn navigation.
2. Learn file management.
3. Build a Node.js service.
"@

    (Join-Path $labRoot "incoming\data.csv") = @"
id,name,status
1,alpha,ready
2,beta,pending
"@

    (Join-Path $labRoot "incoming\raw-data.json") = @"
{
  "source": "navigation-lab",
  "ready": true
}
"@

    (Join-Path $labRoot "workspace\config\app.development.json") = @"
{
  "environment": "development",
  "logLevel": "debug"
}
"@

    (Join-Path $labRoot "workspace\config\app.production.json") = @"
{
  "environment": "production",
  "logLevel": "info"
}
"@

    (Join-Path $labRoot "workspace\logs\application.log") = @"
2026-01-01T09:00:00Z INFO Application started
"@

    (Join-Path $labRoot "workspace\logs\debug.log") = @"
2026-01-01T09:00:01Z DEBUG Navigation laboratory initialized
"@

    (Join-Path $labRoot "workspace\src\index.js") = @"
"use strict";

console.log("Navigation laboratory");
"@

    (Join-Path $labRoot "workspace\src\server.js") = @"
"use strict";

console.log("Example server entry point");
"@
}

foreach ($file in $files.GetEnumerator()) {
    Set-Content -LiteralPath $file.Key -Value $file.Value -Encoding UTF8
}

$hiddenFile = Join-Path $labRoot ".navigation-secret"

Set-Content `
    -LiteralPath $hiddenFile `
    -Value "Training value only. This is not a real secret." `
    -Encoding UTF8

$hiddenItem = Get-Item -LiteralPath $hiddenFile -Force
$hiddenItem.Attributes = $hiddenItem.Attributes -bor [System.IO.FileAttributes]::Hidden

Write-Host "Navigation laboratory created successfully." -ForegroundColor Green
Write-Host "Location: $labRoot"
```

Important commands in this setup include:

- `Join-Path`: safely combines path segments.
- `Test-Path`: determines whether a path exists.
- `New-Item`: creates a file or directory.
- `Set-Content`: writes content into a file.
- `Get-Item`: retrieves one specific item.
- `-LiteralPath`: treats the supplied path exactly as written.
- `$null = ...`: suppresses output we do not need to display.

You will use these commands directly in Part 2.

### The Verification

Confirm that the laboratory exists:

```powershell
$labRoot = Join-Path $HOME "cli-developer-environment-series\filesystem-lab"

Test-Path -LiteralPath $labRoot
```

Expected result:

```text
True
```

Count all files, including the hidden training file:

```powershell
(
    Get-ChildItem `
        -LiteralPath $labRoot `
        -File `
        -Recurse `
        -Force
).Count
```

Expected result:

```text
15
```

Inspect the top-level folders:

```powershell
Get-ChildItem -LiteralPath $labRoot -Directory
```

You should see:

```text
archive
documents
incoming
workspace
```

---

## 1.2 Find Your Current Location

### The Target

Display the directory in which PowerShell is currently operating.

### The Concept

Your current directory is like your current room inside a building. A command using a relative path starts looking from that room.

PowerShell calls the current directory the **current location**.

The native command is:

```powershell
Get-Location
```

The familiar alias is:

```powershell
pwd
```

The letters `pwd` come from the UNIX phrase “print working directory.”

### The Implementation

Run the native command:

```powershell
Get-Location
```

The output resembles:

```text
Path
----
C:\Users\YourName
```

Run the alias:

```powershell
pwd
```

Both commands return the same kind of location object.

To display only the path string, access the object’s `Path` property:

```powershell
(Get-Location).Path
```

Store the current location in a variable:

```powershell
$startingLocation = Get-Location
```

Inspect the saved location:

```powershell
$startingLocation
```

Inspect its path property:

```powershell
$startingLocation.Path
```

### The Verification

Confirm that `pwd` is an alias for `Get-Location`:

```powershell
Get-Alias -Name pwd
```

Expected output includes:

```text
CommandType     Name     Version    Source
-----------     ----     -------    ------
Alias           pwd -> Get-Location
```

Confirm that both commands report the same path:

```powershell
(Get-Location).Path -eq (pwd).Path
```

Expected result:

```text
True
```

---

## 1.3 Move to Your Home Directory

### The Target

Navigate to your Windows user home directory without hardcoding your username.

### The Concept

The home directory is your personal starting point. On Windows, it is commonly:

```text
C:\Users\YourName
```

Hardcoding that path makes commands specific to one computer or user. PowerShell provides two portable representations:

```powershell
$HOME
```

and:

```powershell
~
```

The tilde `~` is shorthand for the current user’s home directory when PowerShell interprets it as a path.

The native navigation command is:

```powershell
Set-Location
```

Its familiar alias is:

```powershell
cd
```

### The Implementation

Inspect the value of `$HOME`:

```powershell
$HOME
```

Navigate home with the native command:

```powershell
Set-Location -Path $HOME
```

Check the result:

```powershell
Get-Location
```

Now navigate home using the tilde shorthand:

```powershell
Set-Location -Path ~
```

You can also use the alias:

```powershell
cd ~
```

### The Verification

Compare the current path with `$HOME`:

```powershell
(Get-Location).Path -eq $HOME
```

Expected result:

```text
True
```

Confirm the alias mapping:

```powershell
Get-Alias -Name cd
```

Expected output identifies `Set-Location` as the underlying command.

---

## 1.4 Navigate with an Absolute Path

### The Target

Move directly to the navigation laboratory using its complete address.

### The Concept

An **absolute path** gives the complete location of an item, including its drive and all parent directories.

It is like a complete postal address:

```text
C:\Users\YourName\cli-developer-environment-series\filesystem-lab
```

An absolute path does not depend on your current location.

Using `$HOME` to construct a path is portable, but after PowerShell evaluates `$HOME`, the resulting value is still a full path.

### The Implementation

Construct the laboratory path:

```powershell
$labRoot = Join-Path -Path $HOME -ChildPath "cli-developer-environment-series\filesystem-lab"
```

Display it:

```powershell
$labRoot
```

Navigate to it:

```powershell
Set-Location -Path $labRoot
```

Check your location:

```powershell
Get-Location
```

You may also write a full literal path if you substitute your actual username:

```powershell
Set-Location -Path "C:\Users\YourName\cli-developer-environment-series\filesystem-lab"
```

Using `$HOME` is preferable because it avoids embedding a machine-specific username.

### The Verification

Confirm the current location:

```powershell
(Get-Location).Path -eq $labRoot
```

Expected result:

```text
True
```

Resolve the path to its canonical location:

```powershell
Resolve-Path -LiteralPath $labRoot
```

`Resolve-Path` verifies that the location exists and returns its resolved path.

---

## 1.5 Navigate with Relative Paths

### The Target

Move between laboratory directories without repeating the complete path.

### The Concept

A **relative path** describes a destination from your current location.

If an absolute path is a complete street address, a relative path is a direction such as:

> Go into the room named `documents`, then enter `guides`.

PowerShell uses these symbols:

| Symbol | Meaning |
|---|---|
| `.` | Current location |
| `..` | Parent of the current location |
| `.\name` | An item named `name` in the current location |
| `..\name` | An item named `name` beside the current directory |
| `\` | Separates Windows path segments |

### The Implementation

Begin at the laboratory root:

```powershell
$labRoot = Join-Path $HOME "cli-developer-environment-series\filesystem-lab"
Set-Location -Path $labRoot
```

Move into `documents`:

```powershell
Set-Location -Path .\documents
```

Move into `guides`:

```powershell
Set-Location -Path .\guides
```

Inspect the current path:

```powershell
Get-Location
```

Move back one level:

```powershell
Set-Location -Path ..
```

You are now in `documents`.

Move back another level:

```powershell
Set-Location -Path ..
```

You are now at `filesystem-lab`.

Navigate through several levels in one command:

```powershell
Set-Location -Path .\workspace\src
```

Move from `workspace\src` to its sibling directory, `workspace\config`:

```powershell
Set-Location -Path ..\config
```

Here is how PowerShell interprets that path:

1. `..` moves from `workspace\src` to `workspace`.
2. `config` enters `workspace\config`.

### The Verification

Confirm that you reached the configuration directory:

```powershell
(Get-Location).Path
```

The path should end with:

```text
filesystem-lab\workspace\config
```

Use a programmatic check:

```powershell
(Get-Location).Path.EndsWith("filesystem-lab\workspace\config")
```

Expected result:

```text
True
```

Return to the laboratory root:

```powershell
Set-Location -Path $labRoot
```

---

## 1.6 Understand `.` and `..`

### The Target

Use the current-directory and parent-directory path symbols accurately.

### The Concept

The symbols `.` and `..` are entries understood by the filesystem:

- `.` means “right here.”
- `..` means “one level above here.”

They can be chained:

```powershell
..\..
```

That means “move up two levels.”

These symbols can also be combined with child paths:

```powershell
..\..\incoming
```

### The Implementation

Navigate to the deepest guide directory:

```powershell
$labRoot = Join-Path $HOME "cli-developer-environment-series\filesystem-lab"
Set-Location -Path "$labRoot\documents\guides"
```

Resolve the current-directory symbol:

```powershell
Resolve-Path -Path .
```

Resolve the parent:

```powershell
Resolve-Path -Path ..
```

Resolve the grandparent:

```powershell
Resolve-Path -Path ..\..
```

Navigate from `documents\guides` to `incoming`:

```powershell
Set-Location -Path ..\..\incoming
```

### The Verification

Check the final directory name:

```powershell
Split-Path -Path (Get-Location).Path -Leaf
```

Expected result:

```text
incoming
```

`Split-Path -Leaf` returns the final segment—or “leaf”—of a path.

Return to the laboratory root:

```powershell
Set-Location -Path $labRoot
```

---

## 1.7 Navigate Paths Containing Spaces

### The Target

Safely navigate to directories whose names contain spaces.

### The Concept

PowerShell normally uses spaces to separate a command from its arguments. Consider:

```powershell
Set-Location C:\Example Folder
```

Without quotation marks, PowerShell may treat `C:\Example` and `Folder` as separate arguments.

Quotation marks package the entire path as one value:

```powershell
Set-Location "C:\Example Folder"
```

### The Implementation

To demonstrate the rule without permanently expanding the laboratory, create a temporary directory in Windows’ temporary storage:

```powershell
$spacePath = Join-Path -Path $env:TEMP -ChildPath "PowerShell Navigation Lab"

if (-not (Test-Path -LiteralPath $spacePath)) {
    $null = New-Item -Path $spacePath -ItemType Directory
}
```

Navigate using the variable:

```powershell
Set-Location -LiteralPath $spacePath
```

Return home:

```powershell
Set-Location -Path $HOME
```

Navigate using a quoted path:

```powershell
Set-Location -Path "$env:TEMP\PowerShell Navigation Lab"
```

Return to the main laboratory:

```powershell
$labRoot = Join-Path $HOME "cli-developer-environment-series\filesystem-lab"
Set-Location -LiteralPath $labRoot
```

Clean up the temporary demonstration directory safely:

```powershell
Remove-Item -LiteralPath $spacePath -Recurse -Force
```

### The Verification

Confirm that you returned to the laboratory:

```powershell
(Get-Location).Path -eq $labRoot
```

Expected result:

```text
True
```

Confirm that the temporary example was removed:

```powershell
Test-Path -LiteralPath $spacePath
```

Expected result:

```text
False
```

> The difference between `-Path` and `-LiteralPath` is covered in the reference section at the end of Part 1.

---

## 1.8 Use Tab Completion

### The Target

Complete path and command names without typing every character.

### The Concept

Tab completion is like autocomplete in a phone keyboard, except it discovers actual commands and filesystem entries.

Instead of typing:

```powershell
Set-Location .\documents\guides
```

you can type part of each name and ask PowerShell to complete it.

This improves speed and reduces spelling errors.

### The Implementation

Return to the laboratory root:

```powershell
$labRoot = Join-Path $HOME "cli-developer-environment-series\filesystem-lab"
Set-Location -LiteralPath $labRoot
```

Now type the following, but do **not** press Enter yet:

```powershell
Set-Loc
```

Press `Tab`. PowerShell should complete the command:

```powershell
Set-Location
```

Next, type:

```powershell
Set-Location .\doc
```

Press `Tab`. It should complete to something similar to:

```powershell
Set-Location .\documents
```

Press Enter.

Now type:

```powershell
Set-Location .\g
```

Press `Tab`, then press Enter.

You should reach:

```text
filesystem-lab\documents\guides
```

When several items match:

- Press `Tab` to move forward through candidates.
- Press `Shift+Tab` to move backward.
- In some terminal configurations, completion may display a selectable menu.

Return to the laboratory root:

```powershell
Set-Location -LiteralPath $labRoot
```

### The Verification

Check the final location:

```powershell
(Get-Location).Path -eq $labRoot
```

Expected result:

```text
True
```

Confirm the completed command exists:

```powershell
Get-Command -Name Set-Location
```

---

## 1.9 Inspect Directory Contents

### The Target

List the immediate files and directories inside the current location.

### The Concept

Navigating tells PowerShell where you are. Listing tells you what is around you.

The native command is:

```powershell
Get-ChildItem
```

A **child item** is an item directly contained by another location. In a filesystem directory, child items are files and subdirectories.

The familiar aliases are:

```powershell
dir
ls
gci
```

All three normally point to `Get-ChildItem` in PowerShell.

### The Implementation

Navigate to the laboratory root:

```powershell
$labRoot = Join-Path $HOME "cli-developer-environment-series\filesystem-lab"
Set-Location -LiteralPath $labRoot
```

List its immediate contents:

```powershell
Get-ChildItem
```

List an explicit path without navigating there:

```powershell
Get-ChildItem -LiteralPath .\documents
```

Use the `dir` alias:

```powershell
dir
```

Use the `ls` alias:

```powershell
ls
```

Use the `gci` alias:

```powershell
gci
```

### The Verification

Confirm that all relevant aliases resolve to `Get-ChildItem`:

```powershell
Get-Alias -Name dir, ls, gci |
    Select-Object Name, Definition
```

Expected definitions:

```text
Name Definition
---- ----------
dir  Get-ChildItem
ls   Get-ChildItem
gci  Get-ChildItem
```

Count the top-level directories:

```powershell
(Get-ChildItem -LiteralPath $labRoot -Directory).Count
```

Expected result:

```text
4
```

---

## 1.10 List Only Files or Only Directories

### The Target

Separate files from directories when listing contents.

### The Concept

A filing cabinet can contain folders and loose documents. Sometimes you need only the folders; sometimes you need only the documents.

`Get-ChildItem` provides two switches:

```powershell
-File
-Directory
```

A **switch parameter** is an option whose presence enables a behavior. It does not need a separate `True` value.

### The Implementation

List only top-level directories:

```powershell
Get-ChildItem -LiteralPath $labRoot -Directory
```

List only files in `documents`:

```powershell
Get-ChildItem -LiteralPath "$labRoot\documents" -File
```

Display selected properties:

```powershell
Get-ChildItem -LiteralPath "$labRoot\documents" -File |
    Select-Object Name, Extension, Length, LastWriteTime
```

List only directories inside `workspace`:

```powershell
Get-ChildItem -LiteralPath "$labRoot\workspace" -Directory
```

### The Verification

Confirm the names of the top-level directories:

```powershell
Get-ChildItem -LiteralPath $labRoot -Directory |
    Select-Object -ExpandProperty Name
```

Expected names:

```text
archive
documents
incoming
workspace
```

Confirm the number of immediate files in `documents`:

```powershell
(
    Get-ChildItem `
        -LiteralPath "$labRoot\documents" `
        -File
).Count
```

Expected result:

```text
2
```

Those files are:

```text
notes.txt
project-plan.md
```

The `guides` directory is excluded because it is not a file.

---

## 1.11 Filter Files by Name Pattern

### The Target

List only files whose names match a wildcard pattern.

### The Concept

A **wildcard** is a special character that stands in for unknown text.

The two most common PowerShell wildcards are:

| Wildcard | Meaning |
|---|---|
| `*` | Zero or more characters |
| `?` | Exactly one character |

For example:

```text
*.json
```

means:

> Any name ending in `.json`.

And:

```text
app.*.json
```

means:

> A name beginning with `app.`, followed by any characters, and ending in `.json`.

### The Implementation

List Markdown files in `documents`:

```powershell
Get-ChildItem `
    -Path "$labRoot\documents" `
    -Filter "*.md" `
    -File
```

List JSON files in `incoming`:

```powershell
Get-ChildItem `
    -Path "$labRoot\incoming" `
    -Filter "*.json" `
    -File
```

List application configuration files:

```powershell
Get-ChildItem `
    -Path "$labRoot\workspace\config" `
    -Filter "app.*.json" `
    -File
```

List files beginning with `d`:

```powershell
Get-ChildItem `
    -Path "$labRoot\workspace\logs" `
    -Filter "d*" `
    -File
```

### The Verification

Extract only the matching names:

```powershell
Get-ChildItem `
    -Path "$labRoot\workspace\config" `
    -Filter "app.*.json" `
    -File |
    Select-Object -ExpandProperty Name
```

Expected output:

```text
app.development.json
app.production.json
```

Confirm the count:

```powershell
(
    Get-ChildItem `
        -Path "$labRoot\workspace\config" `
        -Filter "app.*.json" `
        -File
).Count
```

Expected result:

```text
2
```

---

## 1.12 Filter by Object Properties

### The Target

Use file metadata—such as extension or size—to select items.

### The Concept

PowerShell returns objects rather than plain text.

A file object has properties including:

```text
Name
Extension
Length
FullName
CreationTime
LastWriteTime
Attributes
```

The pipeline operator `|` passes objects from the command on its left to the command on its right.

Think of a pipeline as a conveyor belt:

1. `Get-ChildItem` places file objects on the belt.
2. `Where-Object` keeps only objects that satisfy a condition.
3. `Select-Object` chooses which properties to display.

### The Implementation

Find JSON files recursively by inspecting the `Extension` property:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Extension -eq ".json" }
```

Inside a `Where-Object` script block, `$_` means “the current object moving through the pipeline.”

Display only useful properties:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Extension -eq ".json" } |
    Select-Object Name, Length, FullName
```

Find non-empty files:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Length -gt 0 } |
    Select-Object Name, Length
```

Find Markdown or text files:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object {
        $_.Extension -in @(".md", ".txt")
    } |
    Select-Object Name, Extension, FullName
```

### The Verification

Count all JSON files:

```powershell
$jsonFiles = Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Extension -eq ".json" }

$jsonFiles.Count
```

Expected result:

```text
3
```

Display their names:

```powershell
$jsonFiles.Name
```

Expected names:

```text
raw-data.json
app.development.json
app.production.json
```

---

## 1.13 Display Hidden Files with `-Force`

### The Target

Find items that are normally omitted from directory listings.

### The Concept

Some files are hidden to reduce clutter or discourage casual modification. Hidden does not mean encrypted or secure—it only affects normal visibility.

PowerShell’s `-Force` switch tells commands to include items that would ordinarily be hidden.

It is similar to opening a cabinet’s secondary compartment: the compartment was always there, but the ordinary view did not show it.

### The Implementation

Return to the laboratory root:

```powershell
Set-Location -LiteralPath $labRoot
```

Run a normal listing:

```powershell
Get-ChildItem
```

The `.navigation-secret` file should not normally appear because the setup assigned it the Windows `Hidden` attribute.

Now include hidden items:

```powershell
Get-ChildItem -Force
```

Display names and attributes:

```powershell
Get-ChildItem -Force |
    Select-Object Name, Attributes
```

Retrieve the hidden file directly:

```powershell
Get-Item -LiteralPath .\.navigation-secret -Force |
    Select-Object Name, FullName, Attributes
```

### The Verification

Test whether the file has the `Hidden` attribute:

```powershell
$hiddenFile = Get-Item -LiteralPath "$labRoot\.navigation-secret" -Force

[bool]($hiddenFile.Attributes -band [System.IO.FileAttributes]::Hidden)
```

Expected result:

```text
True
```

Confirm that `-Force` includes exactly one immediate file at the laboratory root:

```powershell
(
    Get-ChildItem `
        -LiteralPath $labRoot `
        -File `
        -Force
).Count
```

Expected result:

```text
1
```

> A name beginning with `.` is conventionally hidden on UNIX-like systems. On Windows, the filesystem’s `Hidden` attribute controls ordinary visibility. The setup applied both the dotted naming convention and the Windows attribute.

---

## 1.14 List Directory Trees Recursively

### The Target

Inspect files inside the laboratory and all nested directories.

### The Concept

A **recursive** operation repeats itself inside each child directory.

Imagine inspecting a set of nested boxes. A normal listing opens only the outer box. A recursive listing opens the outer box, then every box inside it, then every box inside those boxes.

PowerShell enables recursive listing with:

```powershell
-Recurse
```

### The Implementation

List every visible item below the laboratory:

```powershell
Get-ChildItem -LiteralPath $labRoot -Recurse
```

List only files recursively:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse
```

Include hidden files:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse -Force
```

Display a compact list of full paths:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse -Force |
    Select-Object -ExpandProperty FullName
```

List only directories recursively:

```powershell
Get-ChildItem -LiteralPath $labRoot -Directory -Recurse |
    Select-Object -ExpandProperty FullName
```

Filter recursively for JavaScript files:

```powershell
Get-ChildItem `
    -Path $labRoot `
    -Filter "*.js" `
    -File `
    -Recurse
```

### The Verification

Count visible files:

```powershell
(
    Get-ChildItem `
        -LiteralPath $labRoot `
        -File `
        -Recurse
).Count
```

Expected result:

```text
14
```

Count all files, including the hidden training file:

```powershell
(
    Get-ChildItem `
        -LiteralPath $labRoot `
        -File `
        -Recurse `
        -Force
).Count
```

Expected result:

```text
15
```

Confirm the two JavaScript files:

```powershell
Get-ChildItem `
    -Path $labRoot `
    -Filter "*.js" `
    -File `
    -Recurse |
    Select-Object -ExpandProperty Name
```

Expected output:

```text
index.js
server.js
```

---

## 1.15 Limit Recursive Depth

### The Target

Inspect only a limited number of directory levels.

### The Concept

Sometimes full recursion produces too much information. The `-Depth` parameter limits how far `Get-ChildItem` descends.

Think of the directory tree as a family tree. Full recursion displays every known generation; a limited depth displays only nearby generations.

### The Implementation

List the laboratory while limiting recursion:

```powershell
Get-ChildItem `
    -LiteralPath $labRoot `
    -Recurse `
    -Depth 1
```

Compare that with unrestricted recursion:

```powershell
Get-ChildItem `
    -LiteralPath $labRoot `
    -Recurse
```

Display only directories within the limited traversal:

```powershell
Get-ChildItem `
    -LiteralPath $labRoot `
    -Directory `
    -Recurse `
    -Depth 1 |
    Select-Object -ExpandProperty FullName
```

### The Verification

Store the limited and complete results:

```powershell
$limitedItems = Get-ChildItem `
    -LiteralPath $labRoot `
    -Recurse `
    -Depth 1

$allItems = Get-ChildItem `
    -LiteralPath $labRoot `
    -Recurse

[PSCustomObject]@{
    LimitedCount = $limitedItems.Count
    CompleteCount = $allItems.Count
    CompleteIsLarger = $allItems.Count -gt $limitedItems.Count
}
```

The `CompleteIsLarger` property should be:

```text
True
```

> Depth semantics can feel unintuitive at first because the starting directory is not returned as its own child. Use `-Depth` when you want bounded exploration, and verify the results before relying on an assumed level count.

---

## 1.16 Sort and Format Directory Results

### The Target

Make large directory listings easier to read.

### The Concept

Listing retrieves the data. Sorting and formatting decide how that data is presented.

This is similar to retrieving books from a shelf and then arranging them by title, publication date, or size.

Useful commands include:

- `Sort-Object`: orders objects by one or more properties.
- `Select-Object`: chooses properties or a subset of objects.
- `Format-Table`: produces a table for human-readable terminal output.

### The Implementation

Sort all files by name:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse -Force |
    Sort-Object -Property Name |
    Select-Object Name, Extension, Length
```

Sort files from largest to smallest:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse -Force |
    Sort-Object -Property Length -Descending |
    Select-Object Name, Length, FullName
```

Display the five most recently modified files:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse -Force |
    Sort-Object -Property LastWriteTime -Descending |
    Select-Object -First 5 Name, LastWriteTime, FullName
```

Format selected properties as a table:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse -Force |
    Sort-Object -Property Extension, Name |
    Format-Table Name, Extension, Length -AutoSize
```

### The Verification

Find the largest file object:

```powershell
$largestFile = Get-ChildItem `
    -LiteralPath $labRoot `
    -File `
    -Recurse `
    -Force |
    Sort-Object -Property Length -Descending |
    Select-Object -First 1

$largestFile |
    Select-Object Name, Length, FullName
```

Confirm that one object was selected:

```powershell
$null -ne $largestFile
```

Expected result:

```text
True
```

> Use `Format-Table` only near the end of a command intended for display. Formatting commands create presentation instructions rather than ordinary file objects, making later filtering or property access difficult.

---

## 1.17 Inspect a Single Item

### The Target

Retrieve metadata for one known file or directory.

### The Concept

`Get-ChildItem` asks:

> What is inside this directory?

`Get-Item` asks:

> Tell me about this exact item.

It is the difference between listing everything inside a drawer and examining one specific document.

### The Implementation

Inspect the `documents` directory:

```powershell
Get-Item -LiteralPath "$labRoot\documents"
```

Inspect a particular file:

```powershell
Get-Item -LiteralPath "$labRoot\documents\project-plan.md"
```

Display selected properties:

```powershell
Get-Item -LiteralPath "$labRoot\documents\project-plan.md" |
    Select-Object Name, FullName, Length, Extension, LastWriteTime
```

Display every available property:

```powershell
Get-Item -LiteralPath "$labRoot\documents\project-plan.md" |
    Format-List *
```

### The Verification

Store the file object:

```powershell
$planFile = Get-Item -LiteralPath "$labRoot\documents\project-plan.md"
```

Verify its properties:

```powershell
[PSCustomObject]@{
    Exists = $null -ne $planFile
    IsMarkdown = $planFile.Extension -eq ".md"
    HasContent = $planFile.Length -gt 0
    FullPath = $planFile.FullName
}
```

Expected values:

```text
Exists      : True
IsMarkdown  : True
HasContent  : True
```

---

## 1.18 Test and Resolve Paths Before Navigating

### The Target

Check whether a destination exists before attempting to use it.

### The Concept

Before driving somewhere, you might verify that the address is valid. PowerShell provides two useful commands:

- `Test-Path` returns `True` or `False`.
- `Resolve-Path` returns an existing path’s resolved location.

This is especially useful in scripts, where an invalid path should produce a controlled error rather than an unpredictable failure later.

### The Implementation

Test an existing directory:

```powershell
Test-Path -LiteralPath "$labRoot\workspace"
```

Test an existing file:

```powershell
Test-Path -LiteralPath "$labRoot\workspace\src\index.js"
```

Test a missing path:

```powershell
Test-Path -LiteralPath "$labRoot\does-not-exist"
```

Require a specific path type:

```powershell
Test-Path `
    -LiteralPath "$labRoot\workspace" `
    -PathType Container
```

`Container` means a directory-like item.

Check for a file:

```powershell
Test-Path `
    -LiteralPath "$labRoot\workspace\src\index.js" `
    -PathType Leaf
```

`Leaf` means a non-container item, commonly a file.

Resolve a relative path:

```powershell
Set-Location -LiteralPath $labRoot

Resolve-Path -Path .\workspace\src
```

Use a defensive navigation pattern:

```powershell
$destination = Join-Path $labRoot "workspace\src"

if (Test-Path -LiteralPath $destination -PathType Container) {
    Set-Location -LiteralPath $destination
    Write-Host "Moved to: $destination" -ForegroundColor Green
}
else {
    throw "The destination directory does not exist: $destination"
}
```

### The Verification

Confirm the destination:

```powershell
(Get-Location).Path -eq $destination
```

Expected result:

```text
True
```

Return to the laboratory root:

```powershell
Set-Location -LiteralPath $labRoot
```

---

## 1.19 Move Between Windows Drives

### The Target

Navigate between filesystem drives without opening File Explorer.

### The Concept

PowerShell represents navigable data stores as **PowerShell drives**. Traditional Windows drives such as `C:` and `D:` are filesystem drives, but PowerShell can also expose other stores with drive-like syntax.

Examples may include:

```text
C:
Env:
Alias:
Variable:
Function:
```

A PowerShell drive is therefore broader than a physical disk.

Not every computer has a `D:` drive, so the commands must first check whether it exists.

### The Implementation

List all available PowerShell drives:

```powershell
Get-PSDrive
```

List only filesystem drives:

```powershell
Get-PSDrive -PSProvider FileSystem
```

Display the drive containing your home directory:

```powershell
$homeDriveName = (Split-Path -Path $HOME -Qualifier).TrimEnd(":")
$homeDrive = Get-PSDrive -Name $homeDriveName

$homeDrive |
    Select-Object Name, Root, CurrentLocation, Used, Free
```

Check for a `D:` drive:

```powershell
$dDrive = Get-PSDrive -Name D -ErrorAction SilentlyContinue

if ($null -ne $dDrive) {
    Set-Location -Path "D:\"
    Write-Host "Moved to D:\" -ForegroundColor Green
}
else {
    Write-Host "No D: filesystem drive is available on this computer." -ForegroundColor Yellow
}
```

Return to the laboratory regardless of whether `D:` exists:

```powershell
$labRoot = Join-Path $HOME "cli-developer-environment-series\filesystem-lab"
Set-Location -LiteralPath $labRoot
```

PowerShell also supports the familiar interactive drive shorthand:

```powershell
C:
```

However, the explicit form is clearer in scripts:

```powershell
Set-Location -Path "C:\"
```

### The Verification

Confirm that your current location is back inside the laboratory:

```powershell
(Get-Location).Path -eq $labRoot
```

Expected result:

```text
True
```

Confirm that the home filesystem drive exists:

```powershell
Test-Path -LiteralPath "$($homeDrive.Root)"
```

Expected result:

```text
True
```

---

## 1.20 Save and Restore Locations

### The Target

Temporarily visit another directory and return without manually reconstructing the original path.

### The Concept

`Push-Location` and `Pop-Location` behave like placing a bookmark.

- `Push-Location` saves the current location and moves elsewhere.
- `Pop-Location` returns to the most recently saved location.

PowerShell stores these bookmarks in a location stack. A **stack** is a last-in, first-out structure, like a stack of plates: the most recently placed plate is removed first.

### The Implementation

Begin at the laboratory root:

```powershell
Set-Location -LiteralPath $labRoot
```

Save the current location and move to `documents`:

```powershell
Push-Location -LiteralPath "$labRoot\documents"
```

Check the location:

```powershell
Get-Location
```

Save that location and move to the logs directory:

```powershell
Push-Location -LiteralPath "$labRoot\workspace\logs"
```

Inspect the location stack:

```powershell
Get-Location -Stack
```

Return to `documents`:

```powershell
Pop-Location
```

Return to the laboratory root:

```powershell
Pop-Location
```

### The Verification

Confirm that the original location was restored:

```powershell
(Get-Location).Path -eq $labRoot
```

Expected result:

```text
True
```

Check the default stack:

```powershell
Get-Location -Stack
```

If the default stack was empty before this exercise, it should now be empty again.

---

## 1.21 Read Directory Results as Objects

### The Target

Prove that `Get-ChildItem` returns structured objects rather than formatted text.

### The Concept

Suppose a paper list says:

```text
project-plan.md  82
```

A human may infer that `82` is a file size, but a computer only sees characters unless the format is parsed.

PowerShell instead returns an object with named properties:

```text
Name   = project-plan.md
Length = 82
```

Commands can access those properties directly.

### The Implementation

Retrieve one file:

```powershell
$file = Get-Item -LiteralPath "$labRoot\documents\project-plan.md"
```

Inspect its .NET type:

```powershell
$file.GetType().FullName
```

Expected type:

```text
System.IO.FileInfo
```

Access individual properties:

```powershell
$file.Name
$file.Extension
$file.Length
$file.FullName
$file.LastWriteTime
```

Discover all members—properties and methods—available on the object:

```powershell
$file | Get-Member
```

Display only properties:

```powershell
$file |
    Get-Member -MemberType Property
```

Create a custom summary from the file object:

```powershell
[PSCustomObject]@{
    FileName = $file.Name
    Extension = $file.Extension
    SizeInBytes = $file.Length
    ParentDirectory = $file.DirectoryName
    ModifiedAt = $file.LastWriteTime
}
```

`[PSCustomObject]` creates a new object with properties chosen by you. It is useful when building reports or returning structured information from scripts.

### The Verification

Verify that the object has the expected type and properties:

```powershell
[PSCustomObject]@{
    IsFileInfo = $file -is [System.IO.FileInfo]
    HasName = -not [string]::IsNullOrWhiteSpace($file.Name)
    HasFullPath = [System.IO.Path]::IsPathRooted($file.FullName)
    IsMarkdown = $file.Extension -eq ".md"
}
```

Expected result:

```text
IsFileInfo  : True
HasName     : True
HasFullPath : True
IsMarkdown  : True
```

Compare this with a directory object:

```powershell
$directory = Get-Item -LiteralPath "$labRoot\documents"

$directory.GetType().FullName
```

Expected type:

```text
System.IO.DirectoryInfo
```

This distinction enables PowerShell to treat files and directories appropriately without parsing display text.

---

## 1.22 Understand Aliases Without Confusing PowerShell with UNIX

### The Target

Identify what familiar commands such as `cd`, `dir`, `ls`, and `pwd` actually mean in PowerShell.

### The Concept

Two people may share a nickname without being the same person. In the same way, `ls` in PowerShell resembles the UNIX command name, but it is not necessarily the UNIX `ls` program.

In a standard PowerShell session:

```text
ls → Get-ChildItem
```

PowerShell receives `ls`, resolves the alias, and invokes the PowerShell cmdlet `Get-ChildItem`.

A **cmdlet**, pronounced “command-let,” is a lightweight PowerShell command that normally accepts and returns structured objects.

This distinction matters because flags copied from Bash tutorials may not work in PowerShell. For example, a Bash command such as:

```text
ls -la
```

should not be assumed to have the same meaning in PowerShell. The clear PowerShell equivalent is:

```powershell
Get-ChildItem -Force
```

### The Implementation

Inspect the four principal navigation aliases:

```powershell
Get-Alias -Name cd, dir, ls, pwd |
    Sort-Object -Property Name |
    Select-Object Name, Definition
```

Inspect one alias in detail:

```powershell
Get-Command -Name ls |
    Format-List Name, CommandType, Definition
```

Inspect the native cmdlet:

```powershell
Get-Command -Name Get-ChildItem |
    Format-List Name, CommandType, ModuleName, Version
```

Display every alias that points to `Get-ChildItem`:

```powershell
Get-Alias -Definition Get-ChildItem |
    Sort-Object -Property Name |
    Select-Object Name, Definition
```

Display every alias that points to `Set-Location`:

```powershell
Get-Alias -Definition Set-Location |
    Sort-Object -Property Name |
    Select-Object Name, Definition
```

### The Verification

Create a small alias map and test its definitions:

```powershell
$expectedAliases = @{
    cd  = "Set-Location"
    dir = "Get-ChildItem"
    ls  = "Get-ChildItem"
    pwd = "Get-Location"
}

$aliasResults = foreach ($aliasName in $expectedAliases.Keys) {
    $alias = Get-Alias -Name $aliasName

    [PSCustomObject]@{
        Alias = $aliasName
        ExpectedCommand = $expectedAliases[$aliasName]
        ActualCommand = $alias.Definition
        Matches = $alias.Definition -eq $expectedAliases[$aliasName]
    }
}

$aliasResults |
    Sort-Object -Property Alias |
    Format-Table -AutoSize
```

Every row’s `Matches` value should be:

```text
True
```

For interactive typing, aliases are convenient:

```powershell
cd $HOME
ls
pwd
```

For scripts and shared documentation, use native names:

```powershell
Set-Location -Path $HOME
Get-ChildItem
Get-Location
```

Native names make intent clearer and behave as searchable documentation.

---

## 1.23 Use Command Discovery and Built-In Help

### The Target

Discover PowerShell commands and obtain usage examples without leaving the terminal.

### The Concept

Memorizing every command is unnecessary. PowerShell includes a searchable catalog and built-in manual.

Think of:

- `Get-Command` as a library catalog.
- `Get-Help` as the manual for a selected book.
- `Get-Member` as an inventory of the information carried by an object.

### The Implementation

Search for commands that operate on locations:

```powershell
Get-Command -Noun Location
```

Search for commands whose names begin with `Get-Child`:

```powershell
Get-Command -Name "Get-Child*"
```

Display concise help:

```powershell
Get-Help -Name Get-ChildItem
```

Display examples:

```powershell
Get-Help -Name Get-ChildItem -Examples
```

Display detailed help:

```powershell
Get-Help -Name Set-Location -Detailed
```

Display help for a particular parameter:

```powershell
Get-Help -Name Get-ChildItem -Parameter Recurse
```

If local help content is incomplete, PowerShell may show abbreviated information. Current help can normally be opened in a browser:

```powershell
Get-Help -Name Get-ChildItem -Online
```

Updating local help may require internet access and, for some modules, an elevated session:

```powershell
Update-Help -ErrorAction Continue
```

Do not run PowerShell as administrator solely for ordinary navigation. If `Update-Help` reports permission errors, online help remains a safe alternative.

### The Verification

Verify that the principal navigation commands are available:

```powershell
$requiredCommands = @(
    "Get-Location"
    "Set-Location"
    "Get-ChildItem"
    "Get-Item"
    "Test-Path"
    "Resolve-Path"
    "Push-Location"
    "Pop-Location"
)

$commandChecks = foreach ($commandName in $requiredCommands) {
    [PSCustomObject]@{
        Command = $commandName
        Available = $null -ne (
            Get-Command -Name $commandName -ErrorAction SilentlyContinue
        )
    }
}

$commandChecks |
    Format-Table -AutoSize
```

Every `Available` value should be:

```text
True
```

---

## 1.24 Handle Missing Paths Deliberately

### The Target

Respond predictably when a requested path does not exist.

### The Concept

Commands can fail. Production-quality scripts do not pretend otherwise.

PowerShell distinguishes between:

- **Non-terminating errors**, which are reported while the command may continue
- **Terminating errors**, which stop the current operation and can be caught with `try`/`catch`

The `-ErrorAction Stop` parameter converts many non-terminating command errors into terminating errors. This allows the script to handle them in one controlled place.

It is similar to requiring a delivery driver to return to the office when an address is invalid rather than silently moving to the next task.

### The Implementation

Create the path of a directory that intentionally does not exist:

```powershell
$missingPath = Join-Path -Path $labRoot -ChildPath "missing-directory"
```

Test first when a missing path is an expected possibility:

```powershell
if (Test-Path -LiteralPath $missingPath -PathType Container) {
    Set-Location -LiteralPath $missingPath
}
else {
    Write-Warning "Directory not found: $missingPath"
}
```

Use `try`/`catch` when the operation itself must succeed:

```powershell
try {
    Set-Location -LiteralPath $missingPath -ErrorAction Stop
    Write-Host "Navigation succeeded." -ForegroundColor Green
}
catch {
    Write-Host "Navigation failed safely." -ForegroundColor Yellow
    Write-Host "Requested path: $missingPath"
    Write-Host "PowerShell message: $($_.Exception.Message)"
}
finally {
    Set-Location -LiteralPath $labRoot
}
```

The `finally` block runs whether the attempt succeeds or fails. Here, it ensures that the exercise finishes at the known laboratory root.

You can also validate a path and deliberately stop with a clear message:

```powershell
$destination = Join-Path -Path $labRoot -ChildPath "workspace\src"

if (-not (Test-Path -LiteralPath $destination -PathType Container)) {
    throw "Required source directory does not exist: $destination"
}

Set-Location -LiteralPath $destination
```

Return to the laboratory root:

```powershell
Set-Location -LiteralPath $labRoot
```

### The Verification

Confirm that the missing path is still absent:

```powershell
Test-Path -LiteralPath $missingPath
```

Expected result:

```text
False
```

Confirm that the failed navigation did not leave you in an unknown location:

```powershell
(Get-Location).Path -eq $labRoot
```

Expected result:

```text
True
```

---

## 1.25 Build a Reusable Navigation Report

### The Target

Combine navigation and inspection skills into a complete script that reports the contents of any directory.

### The Concept

Individual commands are like individual hand tools. A script assembles them into a repeatable machine.

The report will:

1. Accept a directory path.
2. Validate that the directory exists.
3. Retrieve files recursively.
4. Optionally include hidden files.
5. Group files by extension.
6. Calculate the total number and size of files.
7. Return structured objects.

This introduces scripting without changing the laboratory.

### The Implementation

First, create a directory for reusable scripts:

```powershell
$seriesRoot = Join-Path -Path $HOME -ChildPath "cli-developer-environment-series"
$partOneScripts = Join-Path -Path $seriesRoot -ChildPath "part-1-scripts"

if (-not (Test-Path -LiteralPath $partOneScripts -PathType Container)) {
    $null = New-Item -Path $partOneScripts -ItemType Directory
}
```

Create the report script with complete contents.

### File: `cli-developer-environment-series/part-1-scripts/Get-DirectoryReport.ps1`

```powershell
$reportScriptPath = Join-Path `
    -Path $partOneScripts `
    -ChildPath "Get-DirectoryReport.ps1"

$reportScriptContent = @'
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Path,

    [switch] $IncludeHidden
)

$resolvedDirectory = Resolve-Path `
    -LiteralPath $Path `
    -ErrorAction Stop

$directoryItem = Get-Item `
    -LiteralPath $resolvedDirectory.Path `
    -Force `
    -ErrorAction Stop

if (-not $directoryItem.PSIsContainer) {
    throw "The supplied path is not a directory: $Path"
}

$childItemParameters = @{
    LiteralPath = $directoryItem.FullName
    File = $true
    Recurse = $true
    ErrorAction = "Stop"
}

if ($IncludeHidden) {
    $childItemParameters.Force = $true
}

$files = @(
    Get-ChildItem @childItemParameters
)

$totalBytes = (
    $files |
        Measure-Object -Property Length -Sum
).Sum

if ($null -eq $totalBytes) {
    $totalBytes = 0
}

$extensionGroups = @(
    $files |
        Group-Object -Property Extension |
        Sort-Object -Property Name |
        ForEach-Object {
            $extensionName = $_.Name

            if ([string]::IsNullOrWhiteSpace($extensionName)) {
                $extensionName = "[no extension]"
            }

            $groupBytes = (
                $_.Group |
                    Measure-Object -Property Length -Sum
            ).Sum

            if ($null -eq $groupBytes) {
                $groupBytes = 0
            }

            [PSCustomObject]@{
                Extension = $extensionName
                FileCount = $_.Count
                TotalBytes = [long] $groupBytes
            }
        }
)

[PSCustomObject]@{
    Directory = $directoryItem.FullName
    IncludedHiddenItems = [bool] $IncludeHidden
    FileCount = $files.Count
    TotalBytes = [long] $totalBytes
    ExtensionGroups = $extensionGroups
    Files = $files
}
'@

Set-Content `
    -LiteralPath $reportScriptPath `
    -Value $reportScriptContent `
    -Encoding UTF8
```

The script uses several important PowerShell features:

- `[CmdletBinding()]` gives the script cmdlet-like behavior.
- `param(...)` declares accepted input.
- `[Parameter(Mandatory)]` requires `-Path`.
- `[switch]` creates an on/off parameter.
- A **splat**, such as `@childItemParameters`, passes a hashtable of named parameters into a command.
- `Measure-Object` calculates the combined file size.
- `Group-Object` groups files by extension.
- `[PSCustomObject]` returns structured report data.

Run the script:

```powershell
$report = & $reportScriptPath `
    -Path $labRoot `
    -IncludeHidden
```

The call operator `&` executes a path stored in a variable.

Display the summary:

```powershell
$report |
    Select-Object `
        Directory,
        IncludedHiddenItems,
        FileCount,
        TotalBytes
```

Display the extension breakdown:

```powershell
$report.ExtensionGroups |
    Format-Table -AutoSize
```

Display the files:

```powershell
$report.Files |
    Sort-Object -Property FullName |
    Select-Object Name, Extension, Length, FullName
```

### The Verification

Confirm that the script file exists:

```powershell
Test-Path -LiteralPath $reportScriptPath -PathType Leaf
```

Expected result:

```text
True
```

Verify the report values:

```powershell
[PSCustomObject]@{
    DirectoryMatches = $report.Directory -eq $labRoot
    HiddenItemsIncluded = $report.IncludedHiddenItems
    ExpectedFileCount = $report.FileCount -eq 15
    HasExtensionGroups = $report.ExtensionGroups.Count -gt 0
    HasFileObjects = $report.Files.Count -eq 15
}
```

Expected result:

```text
DirectoryMatches    : True
HiddenItemsIncluded : True
ExpectedFileCount   : True
HasExtensionGroups  : True
HasFileObjects      : True
```

Compare a report that excludes hidden files:

```powershell
$visibleReport = & $reportScriptPath -Path $labRoot

[PSCustomObject]@{
    VisibleFileCount = $visibleReport.FileCount
    CompleteFileCount = $report.FileCount
    Difference = $report.FileCount - $visibleReport.FileCount
}
```

Expected values:

```text
VisibleFileCount  : 14
CompleteFileCount : 15
Difference        : 1
```

If script execution is blocked by an execution-policy message, do not weaken system security globally. Part 3 explains execution policies in depth. For this local exercise, you can invoke the file in a child PowerShell process with a process-scoped bypass:

```powershell
powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File $reportScriptPath `
    -Path $labRoot `
    -IncludeHidden
```

If you are using PowerShell 7:

```powershell
pwsh `
    -NoProfile `
    -File $reportScriptPath `
    -Path $labRoot `
    -IncludeHidden
```

A process-scoped setting affects only that newly started process; it does not permanently alter the machine policy.

---

## 1.26 Complete the Part 1 Navigation Challenge

### The Target

Prove that you can navigate and inspect the laboratory by completing a single practical exercise.

### The Concept

A verification challenge combines several skills without introducing new concepts. It is comparable to driving a complete route after practicing steering, braking, and parking separately.

The challenge will:

- Start from your home directory
- Navigate with a relative path
- Save and restore a location
- Find configuration files
- Include a hidden file
- Return structured results
- Restore the starting location

### The Implementation

Run this complete block:

```powershell
$expectedLabRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series\filesystem-lab"

if (-not (Test-Path -LiteralPath $expectedLabRoot -PathType Container)) {
    throw "The navigation laboratory is missing: $expectedLabRoot"
}

$originalLocation = Get-Location

try {
    Set-Location -LiteralPath $HOME

    Set-Location `
        -Path ".\cli-developer-environment-series\filesystem-lab"

    Push-Location -LiteralPath .\workspace\config

    try {
        $configurationFiles = @(
            Get-ChildItem `
                -Path . `
                -Filter "app.*.json" `
                -File |
                Sort-Object -Property Name
        )
    }
    finally {
        Pop-Location
    }

    $hiddenTrainingFiles = @(
        Get-ChildItem `
            -LiteralPath . `
            -File `
            -Force |
            Where-Object {
                [bool](
                    $_.Attributes -band
                    [System.IO.FileAttributes]::Hidden
                )
            }
    )

    $allJavaScriptFiles = @(
        Get-ChildItem `
            -Path . `
            -Filter "*.js" `
            -File `
            -Recurse |
            Sort-Object -Property Name
    )

    $challengeResult = [PSCustomObject]@{
        CurrentDirectory = (Get-Location).Path
        ConfigurationFileCount = $configurationFiles.Count
        ConfigurationFiles = $configurationFiles.Name -join ", "
        HiddenFileCount = $hiddenTrainingFiles.Count
        HiddenFiles = $hiddenTrainingFiles.Name -join ", "
        JavaScriptFileCount = $allJavaScriptFiles.Count
        JavaScriptFiles = $allJavaScriptFiles.Name -join ", "
    }

    $challengeResult |
        Format-List
}
finally {
    Set-Location -LiteralPath $originalLocation.Path
}
```

### The Verification

Inspect the challenge result:

```powershell
$challengePassed = (
    $challengeResult.CurrentDirectory -eq $expectedLabRoot -and
    $challengeResult.ConfigurationFileCount -eq 2 -and
    $challengeResult.HiddenFileCount -eq 1 -and
    $challengeResult.JavaScriptFileCount -eq 2 -and
    (Get-Location).Path -eq $originalLocation.Path
)

if ($challengePassed) {
    Write-Host "Part 1 navigation challenge passed." -ForegroundColor Green
}
else {
    Write-Host "Part 1 navigation challenge failed." -ForegroundColor Red
    $challengeResult | Format-List
}
```

Expected message:

```text
Part 1 navigation challenge passed.
```

---

# Part 1 Reference A: Native Cmdlets and Aliases

This reference consolidates the commands introduced throughout Part 1.

## Navigation commands

| Purpose | Native PowerShell command | Common alias |
|---|---|---|
| Show current location | `Get-Location` | `pwd`, `gl` |
| Change location | `Set-Location` | `cd`, `chdir`, `sl` |
| Save and change location | `Push-Location` | `pushd` |
| Restore saved location | `Pop-Location` | `popd` |
| Resolve an existing path | `Resolve-Path` | `rvpa` |
| Check whether a path exists | `Test-Path` | None by default |

## Inspection commands

| Purpose | Native PowerShell command | Common alias |
|---|---|---|
| List child items | `Get-ChildItem` | `dir`, `ls`, `gci` |
| Inspect one item | `Get-Item` | `gi` |
| Filter objects | `Where-Object` | `where`, `?` |
| Select properties | `Select-Object` | `select` |
| Sort objects | `Sort-Object` | `sort` |
| Group objects | `Group-Object` | `group` |
| Inspect object members | `Get-Member` | `gm` |
| Measure values | `Measure-Object` | `measure` |

View the alias definitions on your computer:

```powershell
Get-Alias -Name pwd, gl, cd, chdir, sl, pushd, popd, dir, ls, gci, gi |
    Sort-Object -Property Name |
    Format-Table Name, Definition -AutoSize
```

Aliases can differ by PowerShell version, installed modules, or user profile customizations. `Get-Alias` reports the truth for the current session.

---

# Part 1 Reference B: PowerShell Path Vocabulary

## Absolute path

A complete filesystem location:

```text
C:\Users\YourName\cli-developer-environment-series
```

Check whether a path is rooted:

```powershell
[System.IO.Path]::IsPathRooted(
    "C:\Users\YourName\cli-developer-environment-series"
)
```

Expected result:

```text
True
```

## Relative path

A location interpreted from the current directory:

```text
.\workspace\src
```

Check whether it is rooted:

```powershell
[System.IO.Path]::IsPathRooted(".\workspace\src")
```

Expected result:

```text
False
```

## Current directory

```text
.
```

Example:

```powershell
Get-ChildItem -Path .
```

## Parent directory

```text
..
```

Example:

```powershell
Set-Location -Path ..
```

## Home directory

```text
~
```

or:

```powershell
$HOME
```

Example:

```powershell
Set-Location -Path $HOME
```

## Root of a drive

```text
C:\
```

Example:

```powershell
Set-Location -Path "C:\"
```

## Path separator

Windows commonly uses the backslash:

```text
\
```

Example:

```text
workspace\src\index.js
```

PowerShell and modern .NET APIs can often accept `/` in filesystem paths, but backslashes remain the conventional form in Windows documentation.

## Provider-qualified path

A path can explicitly name its PowerShell provider:

```powershell
Get-ChildItem -Path "FileSystem::$HOME"
```

This is usually unnecessary for everyday filesystem navigation, but it illustrates that PowerShell paths belong to providers rather than exclusively to physical disks.

---

# Part 1 Reference C: `-Path` Versus `-LiteralPath`

Both parameters identify an item, but they interpret special characters differently.

## `-Path`

`-Path` supports wildcards:

```powershell
Get-ChildItem `
    -Path "$labRoot\workspace\config\*.json" `
    -File
```

The `*` is interpreted as a wildcard.

## `-LiteralPath`

`-LiteralPath` treats the path exactly as supplied:

```powershell
Get-Item `
    -LiteralPath "$labRoot\documents\project-plan.md"
```

This is safer when the exact path is already known or comes from a variable.

Characters such as these may have wildcard meaning:

```text
*
?
[
]
```

If a real filename contains such characters, `-LiteralPath` avoids accidental wildcard interpretation.

## Practical rule

Use:

- `-Path` when you intentionally need wildcard expansion.
- `-LiteralPath` when you mean one exact path.

Examples:

```powershell
# Intentionally find every Markdown file.
Get-ChildItem `
    -Path "$labRoot\documents\*.md" `
    -File

# Retrieve one exact Markdown file.
Get-Item `
    -LiteralPath "$labRoot\documents\project-plan.md"
```

---

# Part 1 Reference D: `Get-ChildItem` Parameters

## `-File`

Returns only files:

```powershell
Get-ChildItem -LiteralPath $labRoot -File
```

## `-Directory`

Returns only directories:

```powershell
Get-ChildItem -LiteralPath $labRoot -Directory
```

## `-Force`

Includes hidden items:

```powershell
Get-ChildItem -LiteralPath $labRoot -Force
```

`-Force` does not magically grant operating-system permissions. It requests inclusion of normally hidden items and permits certain operations that ordinary invocation excludes, but access-control rules still apply.

## `-Recurse`

Descends into child directories:

```powershell
Get-ChildItem -LiteralPath $labRoot -Recurse
```

## `-Depth`

Limits recursive descent:

```powershell
Get-ChildItem `
    -LiteralPath $labRoot `
    -Recurse `
    -Depth 1
```

## `-Filter`

Applies a provider-level name filter:

```powershell
Get-ChildItem `
    -Path $labRoot `
    -Filter "*.json" `
    -File `
    -Recurse
```

For filesystem searches, `-Filter` can be more efficient than retrieving every item and filtering afterward.

## `-Include`

Includes matching items. It is most predictable when the path includes a wildcard or when used with `-Recurse`:

```powershell
Get-ChildItem `
    -Path "$labRoot\*" `
    -Include "*.json", "*.md" `
    -File `
    -Recurse
```

## `-Exclude`

Excludes matching names:

```powershell
Get-ChildItem `
    -Path "$labRoot\*" `
    -Exclude "*.log" `
    -File `
    -Recurse
```

## `-Name`

Returns names rather than full file objects:

```powershell
Get-ChildItem `
    -LiteralPath "$labRoot\documents" `
    -Name
```

Use `-Name` for concise output. Omit it when later pipeline commands need properties such as `Length`, `Extension`, or `LastWriteTime`.

---

# Part 1 Reference E: Wildcards and Comparison Operators

## Wildcards

| Pattern | Meaning |
|---|---|
| `*.json` | Any name ending in `.json` |
| `app.*` | Any name beginning with `app.` |
| `?.txt` | A one-character base name ending in `.txt` |
| `[ab]*` | A name beginning with `a` or `b` |

Examples:

```powershell
Get-ChildItem `
    -Path "$labRoot\workspace\config" `
    -Filter "*.json"
```

```powershell
Get-ChildItem `
    -Path "$labRoot\workspace\logs" `
    -Filter "a*"
```

## Common comparison operators

| Operator | Meaning |
|---|---|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-gt` | Greater than |
| `-ge` | Greater than or equal |
| `-lt` | Less than |
| `-le` | Less than or equal |
| `-like` | Matches a wildcard pattern |
| `-notlike` | Does not match a wildcard pattern |
| `-match` | Matches a regular expression |
| `-in` | Value appears in a collection |
| `-contains` | Collection contains a value |

Examples:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Extension -eq ".json" }
```

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Name -like "app.*" }
```

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Length -gt 50 }
```

PowerShell’s standard string comparisons are case-insensitive by default:

```powershell
"FILE.JSON" -eq "file.json"
```

Expected result:

```text
True
```

Use the case-sensitive form when needed:

```powershell
"FILE.JSON" -ceq "file.json"
```

Expected result:

```text
False
```

The `c` prefix makes a comparison operator case-sensitive. Examples include `-ceq`, `-clike`, and `-cmatch`.

---

# Part 1 Reference F: Pipeline Fundamentals

The pipeline character is:

```text
|
```

It passes output objects from one command to the next.

Consider:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Extension -eq ".json" } |
    Sort-Object -Property Name |
    Select-Object Name, Length, FullName
```

The stages are:

1. `Get-ChildItem` retrieves file objects.
2. `Where-Object` keeps JSON files.
3. `Sort-Object` orders them by name.
4. `Select-Object` creates objects containing only the selected properties.

Store pipeline results before formatting when you need to reuse them:

```powershell
$jsonReport = Get-ChildItem `
    -LiteralPath $labRoot `
    -File `
    -Recurse |
    Where-Object { $_.Extension -eq ".json" } |
    Sort-Object -Property Name |
    Select-Object Name, Length, FullName
```

You can then inspect or export the data:

```powershell
$jsonReport
```

```powershell
$jsonReport.Count
```

```powershell
$jsonReport.FullName
```

Formatting should usually be the final display operation:

```powershell
$jsonReport |
    Format-Table -AutoSize
```

Avoid assigning formatted output when you need ordinary data objects:

```powershell
# This is display output, not a reusable file report.
$formattedOutput = $jsonReport | Format-Table
```

---

# Part 1 Reference G: Common Navigation Mistakes

## Mistake 1: Assuming `ls` is the UNIX executable

Do not assume Bash flags apply:

```text
ls -la
```

Use the native PowerShell form:

```powershell
Get-ChildItem -Force
```

## Mistake 2: Forgetting quotation marks around paths with spaces

Risky:

```text
Set-Location C:\Development Projects
```

Correct:

```powershell
Set-Location -Path "C:\Development Projects"
```

Even better when stored in a variable:

```powershell
$projectsPath = "C:\Development Projects"
Set-Location -LiteralPath $projectsPath
```

## Mistake 3: Confusing the current directory with the home directory

These are not necessarily the same:

```powershell
Get-Location
$HOME
```

Return home explicitly:

```powershell
Set-Location -Path $HOME
```

## Mistake 4: Expecting a normal listing to include hidden files

Normal listing:

```powershell
Get-ChildItem
```

Include hidden items:

```powershell
Get-ChildItem -Force
```

## Mistake 5: Using recursion on a huge directory without narrowing the search

This may be slow:

```powershell
Get-ChildItem -Path "C:\" -Recurse
```

Prefer a narrow starting path and filter:

```powershell
Get-ChildItem `
    -Path "$HOME\cli-developer-environment-series" `
    -Filter "*.json" `
    -File `
    -Recurse
```

## Mistake 6: Formatting too early

This makes subsequent data processing difficult:

```powershell
Get-ChildItem |
    Format-Table |
    Where-Object { $_.Length -gt 100 }
```

Filter first and format last:

```powershell
Get-ChildItem -File |
    Where-Object { $_.Length -gt 100 } |
    Format-Table Name, Length -AutoSize
```

## Mistake 7: Navigating before verifying user-provided paths

Risky:

```powershell
Set-Location -LiteralPath $userSuppliedPath
```

Defensive:

```powershell
if (Test-Path -LiteralPath $userSuppliedPath -PathType Container) {
    Set-Location -LiteralPath $userSuppliedPath
}
else {
    throw "Directory does not exist: $userSuppliedPath"
}
```

## Mistake 8: Assuming every Windows computer has a `D:` drive

Check first:

```powershell
if (Get-PSDrive -Name D -ErrorAction SilentlyContinue) {
    Set-Location -Path "D:\"
}
else {
    Write-Warning "D: is not available."
}
```

---

# Part 1 Reference H: Compact Command Cookbook

## Show the current location

```powershell
Get-Location
```

## Go home

```powershell
Set-Location -Path $HOME
```

## Enter a child directory

```powershell
Set-Location -Path .\documents
```

## Go up one level

```powershell
Set-Location -Path ..
```

## Go up two levels

```powershell
Set-Location -Path ..\..
```

## List current contents

```powershell
Get-ChildItem
```

## List only files

```powershell
Get-ChildItem -File
```

## List only directories

```powershell
Get-ChildItem -Directory
```

## Include hidden items

```powershell
Get-ChildItem -Force
```

## Search recursively

```powershell
Get-ChildItem -File -Recurse
```

## Find all JSON files

```powershell
Get-ChildItem -Path . -Filter "*.json" -File -Recurse
```

## Check whether a directory exists

```powershell
Test-Path -LiteralPath .\workspace -PathType Container
```

## Resolve a relative path

```powershell
Resolve-Path -Path .\workspace\src
```

## Temporarily visit a directory

```powershell
Push-Location -LiteralPath .\workspace
```

## Return from the temporary visit

```powershell
Pop-Location
```

## List filesystem drives

```powershell
Get-PSDrive -PSProvider FileSystem
```

## Inspect one file

```powershell
Get-Item -LiteralPath .\documents\project-plan.md
```

## Discover an object’s properties and methods

```powershell
Get-Item -LiteralPath .\documents\project-plan.md |
    Get-Member
```

---

# Part 1 Final Verification

## The Target

Perform one final health check to ensure the laboratory and Part 1 script are ready for Part 2.

## The Concept

A phase boundary is a checkpoint. Before building on top of earlier work, we confirm that its foundation is intact.

The check will not modify files. It reads the current state and reports whether each requirement is satisfied.

## The Implementation

Run:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$labRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "filesystem-lab"

$reportScriptPath = Join-Path `
    -Path $seriesRoot `
    -ChildPath "part-1-scripts\Get-DirectoryReport.ps1"

$visibleFiles = @(
    Get-ChildItem `
        -LiteralPath $labRoot `
        -File `
        -Recurse `
        -ErrorAction Stop
)

$allFiles = @(
    Get-ChildItem `
        -LiteralPath $labRoot `
        -File `
        -Recurse `
        -Force `
        -ErrorAction Stop
)

$topLevelDirectories = @(
    Get-ChildItem `
        -LiteralPath $labRoot `
        -Directory `
        -ErrorAction Stop
)

$requiredTopLevelDirectories = @(
    "archive"
    "documents"
    "incoming"
    "workspace"
)

$actualDirectoryNames = @(
    $topLevelDirectories.Name
)

$missingDirectoryNames = @(
    $requiredTopLevelDirectories |
        Where-Object {
            $_ -notin $actualDirectoryNames
        }
)

$finalChecks = @(
    [PSCustomObject]@{
        Check = "Series root exists"
        Passed = Test-Path `
            -LiteralPath $seriesRoot `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "Laboratory exists"
        Passed = Test-Path `
            -LiteralPath $labRoot `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "All top-level directories exist"
        Passed = $missingDirectoryNames.Count -eq 0
    }

    [PSCustomObject]@{
        Check = "Visible file count is 14"
        Passed = $visibleFiles.Count -eq 14
    }

    [PSCustomObject]@{
        Check = "Complete file count is 15"
        Passed = $allFiles.Count -eq 15
    }

    [PSCustomObject]@{
        Check = "Hidden training file exists"
        Passed = Test-Path `
            -LiteralPath "$labRoot\.navigation-secret" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Directory report script exists"
        Passed = Test-Path `
            -LiteralPath $reportScriptPath `
            -PathType Leaf
    }
)

$finalChecks |
    Format-Table Check, Passed -AutoSize
```

### The Verification

Determine whether every check passed:

```powershell
$failedChecks = @(
    $finalChecks |
        Where-Object {
            -not $_.Passed
        }
)

if ($failedChecks.Count -eq 0) {
    Write-Host "Part 1 final verification passed." -ForegroundColor Green
}
else {
    Write-Host "Part 1 final verification failed." -ForegroundColor Red

    $failedChecks |
        Format-Table Check, Passed -AutoSize

    throw "Repair the failed Part 1 checks before continuing."
}
```

Expected output:

```text
Check                                  Passed
-----                                  ------
Series root exists                       True
Laboratory exists                        True
All top-level directories exist          True
Visible file count is 14                 True
Complete file count is 15                True
Hidden training file exists              True
Directory report script exists           True
```

The final message should be:

```text
Part 1 final verification passed.
```

Return to the laboratory root so the next part begins from a predictable location:

```powershell
Set-Location -LiteralPath $labRoot
Get-Location
```

The displayed path should end with:

```text
cli-developer-environment-series\filesystem-lab
```

---

# Part 1 Key Takeaways

You can now navigate the Windows filesystem using native PowerShell commands rather than relying on File Explorer.

## Native commands and aliases

You learned that these familiar commands are aliases:

```text
pwd → Get-Location
cd  → Set-Location
dir → Get-ChildItem
ls  → Get-ChildItem
```

Aliases are useful for interactive work, but complete cmdlet names are usually clearer in scripts and shared documentation.

## Path types

You can distinguish between:

- An **absolute path**, which supplies a complete address
- A **relative path**, which begins from the current location
- `.`, which refers to the current location
- `..`, which refers to the parent location
- `~` and `$HOME`, which refer to your home directory

## Safe navigation

You can validate destinations before using them:

```powershell
Test-Path -LiteralPath $destination -PathType Container
```

You can resolve existing paths:

```powershell
Resolve-Path -LiteralPath $destination
```

You can handle navigation failures deliberately:

```powershell
try {
    Set-Location -LiteralPath $destination -ErrorAction Stop
}
catch {
    Write-Error "Could not navigate to the destination: $($_.Exception.Message)"
}
```

## Directory inspection

You can inspect:

- Immediate children with `Get-ChildItem`
- Files with `-File`
- Directories with `-Directory`
- Hidden items with `-Force`
- Nested trees with `-Recurse`
- Bounded directory levels with `-Depth`
- Matching filenames with `-Filter`

## Object-based processing

You learned that PowerShell returns structured objects. This allows reliable operations such as:

```powershell
Get-ChildItem -LiteralPath $labRoot -File -Recurse |
    Where-Object { $_.Extension -eq ".json" } |
    Sort-Object -Property Name |
    Select-Object Name, Length, FullName
```

This pipeline filters actual file properties instead of attempting to parse visually formatted text.

## Location history

You can temporarily visit another directory and return:

```powershell
Push-Location -LiteralPath .\workspace
Pop-Location
```

## Windows drive navigation

You can discover filesystem drives:

```powershell
Get-PSDrive -PSProvider FileSystem
```

You can move explicitly between available drives:

```powershell
Set-Location -Path "D:\"
```

And you now know not to assume that every computer has the same drive letters.

## Command discovery

You can learn PowerShell from inside PowerShell:

```powershell
Get-Command -Noun Location
Get-Help Get-ChildItem -Examples
Get-Member
```

These tools are more dependable than guessing command names or copying syntax written for another shell.

---

## Part 1 Completion Checklist

Before moving forward, confirm that you can perform each task without relying on File Explorer:

- [ ] Display the current location with `Get-Location`
- [ ] Return home with `Set-Location -Path $HOME`
- [ ] Navigate using an absolute path
- [ ] Navigate using `.` and `..`
- [ ] quote a path containing spaces
- [ ] Complete commands and paths with `Tab`
- [ ] List files and directories with `Get-ChildItem`
- [ ] List only files with `-File`
- [ ] List only directories with `-Directory`
- [ ] Find files using `-Filter`
- [ ] Filter objects using `Where-Object`
- [ ] Include hidden files with `-Force`
- [ ] Search nested directories with `-Recurse`
- [ ] Check destinations with `Test-Path`
- [ ] Move between available drive letters
- [ ] Save and restore locations with `Push-Location` and `Pop-Location`
- [ ] Identify aliases with `Get-Alias`
- [ ] Discover commands using `Get-Command`
- [ ] Read built-in documentation using `Get-Help`
- [ ] Inspect object members using `Get-Member`

---

## What Comes Next

Part 1 treated the filesystem primarily as something to navigate and inspect. Part 2 will begin changing it.

You will use PowerShell to:

- Create individual and nested directories
- Create blank and populated files
- Copy files and complete directory trees
- Rename resources
- Move resources between directories
- Work with read-only and hidden attributes
- Preview destructive operations with `-WhatIf`
- Remove files and non-empty directories safely
- Build reusable file-management functions
- Verify every mutation before proceeding

The central safety principle will be simple:

> Inspect first, preview second, modify third, and verify last.
