# Primer 2: Filesystem Safety and Destructive Operations

PowerShell can create, copy, move, rename, and delete thousands of files in seconds. That speed is useful—but it also means a small mistake can have a large effect.

Consider this command:

```powershell
Remove-Item -Path * -Recurse -Force
```

Its impact depends entirely on the current location. Inside a disposable laboratory, it removes test data. Inside an important project or home directory, it can destroy valuable files.

This primer teaches a repeatable safety method:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

You will learn how to:

- Confirm your current location
- Use a dedicated disposable laboratory
- Distinguish exact paths from wildcard paths
- Validate whether a target is a file or directory
- Resolve relative paths before modifying anything
- Detect targets outside an approved directory
- Inspect a complete deletion inventory
- Preview operations with `-WhatIf`
- Understand `-Recurse` and `-Force`
- Avoid broad wildcard deletions
- Handle errors deliberately
- Add `-WhatIf` and `-Confirm` to your own functions
- Understand what PowerShell cannot automatically undo

> **Important:** Perform every exercise inside the laboratory created in this primer. Do not substitute your home directory, Documents folder, project repository, cloud-synchronized folder, or a drive root.

---

## The Safety Model

Use this sequence before every significant filesystem change:

### 1. Locate

Confirm where PowerShell is operating:

```powershell
Get-Location
```

### 2. Resolve

Convert the intended target into an unambiguous existing path:

```powershell
Resolve-Path -LiteralPath $target
```

### 3. Inspect

Display the target and, for a directory, its descendants:

```powershell
Get-Item -LiteralPath $target -Force
Get-ChildItem -LiteralPath $target -Recurse -Force
```

### 4. Preview

Ask PowerShell what it would change:

```powershell
Remove-Item -LiteralPath $target -Recurse -WhatIf
```

### 5. Execute

Run the operation only after the first four stages confirm your intent:

```powershell
Remove-Item -LiteralPath $target -Recurse
```

### 6. Verify

Inspect the resulting state:

```powershell
Test-Path -LiteralPath $target
```

This workflow is deliberately slower than blindly running a deletion. The few extra seconds are cheaper than recovering lost work.

---

# P2.1 Classify Read-Only and State-Changing Commands

## The Target

Learn which common commands inspect state and which commands modify it.

## The Concept

Commands can be divided into two broad categories:

- **Read-only commands** observe the filesystem.
- **State-changing commands** create, alter, move, or remove resources.

Think of read-only commands as looking at a warehouse inventory. State-changing commands unload, relabel, transfer, or destroy the inventory.

PowerShell’s verb usually provides a clue.

### Common read-only commands

```text
Get-Location
Get-ChildItem
Get-Item
Get-Content
Test-Path
Resolve-Path
Get-FileHash
```

### Common state-changing commands

```text
New-Item
Set-Content
Add-Content
Clear-Content
Copy-Item
Move-Item
Rename-Item
Remove-Item
Set-ItemProperty
```

Copying is state-changing even though it preserves the source, because it creates a new destination.

## The Implementation

Create a simple command-classification report:

```powershell
$commandClassifications = @(
    [PSCustomObject]@{
        Command = "Get-ChildItem"
        Category = "Read-only"
        TypicalEffect = "Lists child items"
    }

    [PSCustomObject]@{
        Command = "Test-Path"
        Category = "Read-only"
        TypicalEffect = "Checks whether a path exists"
    }

    [PSCustomObject]@{
        Command = "Resolve-Path"
        Category = "Read-only"
        TypicalEffect = "Resolves an existing path"
    }

    [PSCustomObject]@{
        Command = "New-Item"
        Category = "State-changing"
        TypicalEffect = "Creates a resource"
    }

    [PSCustomObject]@{
        Command = "Copy-Item"
        Category = "State-changing"
        TypicalEffect = "Creates a copy"
    }

    [PSCustomObject]@{
        Command = "Move-Item"
        Category = "State-changing"
        TypicalEffect = "Relocates a resource"
    }

    [PSCustomObject]@{
        Command = "Remove-Item"
        Category = "Destructive"
        TypicalEffect = "Permanently removes a resource"
    }
)

$commandClassifications |
    Format-Table -AutoSize
```

Inspect which commands advertise `-WhatIf`:

```powershell
$stateChangingCommands = @(
    "New-Item"
    "Copy-Item"
    "Move-Item"
    "Rename-Item"
    "Remove-Item"
)

foreach ($commandName in $stateChangingCommands) {
    $command = Get-Command -Name $commandName

    [PSCustomObject]@{
        Command = $commandName
        SupportsWhatIf = $command.Parameters.ContainsKey("WhatIf")
        SupportsConfirm = $command.Parameters.ContainsKey("Confirm")
    }
}
```

## The Verification

Confirm that `Remove-Item` supports safety parameters:

```powershell
$removeCommand = Get-Command -Name Remove-Item

[PSCustomObject]@{
    SupportsWhatIf = $removeCommand.Parameters.ContainsKey("WhatIf")
    SupportsConfirm = $removeCommand.Parameters.ContainsKey("Confirm")
    SupportsLiteralPath = $removeCommand.Parameters.ContainsKey("LiteralPath")
    SupportsRecurse = $removeCommand.Parameters.ContainsKey("Recurse")
    SupportsForce = $removeCommand.Parameters.ContainsKey("Force")
}
```

Every value should be `True`.

---

# P2.2 Create an Isolated Safety Laboratory

## The Target

Create this disposable structure:

```text
$HOME/
└── powershell-safety-primer/
    ├── approved-workspace/
    │   ├── archive/
    │   ├── incoming/
    │   │   ├── customer-01.csv
    │   │   ├── customer-02.csv
    │   │   └── preserve-me.md
    │   ├── protected/
    │   │   ├── .hidden-training.txt
    │   │   └── read-only-training.txt
    │   └── removable-tree/
    │       ├── level-1.txt
    │       └── nested/
    │           └── level-2.txt
    └── outside-boundary/
        └── must-survive.txt
```

## The Concept

A safety boundary is an approved root directory inside which destructive exercises may occur.

The `outside-boundary` directory is intentionally outside the approved workspace. It will prove that our boundary checks reject paths that must not be touched.

The laboratory root itself is disposable, but during the exercises we will treat this path as protected:

```text
powershell-safety-primer\outside-boundary
```

## The Implementation

Construct exact paths:

```powershell
$primerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "powershell-safety-primer"

$approvedRoot = Join-Path `
    -Path $primerRoot `
    -ChildPath "approved-workspace"

$outsideRoot = Join-Path `
    -Path $primerRoot `
    -ChildPath "outside-boundary"
```

Apply a strict setup-path check:

```powershell
$expectedPrimerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "powershell-safety-primer"

if ($primerRoot -ne $expectedPrimerRoot) {
    throw "Safety check failed. Unexpected laboratory path: $primerRoot"
}
```

Reset only the exact laboratory:

```powershell
if (Test-Path -LiteralPath $primerRoot) {
    Remove-Item `
        -LiteralPath $primerRoot `
        -Recurse `
        -Force `
        -ErrorAction Stop
}
```

Create the directory tree:

```powershell
$directories = @(
    "$approvedRoot\archive"
    "$approvedRoot\incoming"
    "$approvedRoot\protected"
    "$approvedRoot\removable-tree\nested"
    $outsideRoot
)

foreach ($directory in $directories) {
    $null = New-Item `
        -Path $directory `
        -ItemType Directory `
        -Force `
        -ErrorAction Stop
}
```

Create incoming files:

```powershell
Set-Content `
    -LiteralPath "$approvedRoot\incoming\customer-01.csv" `
    -Value @'
id,name,status
1,Ada,active
'@ `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$approvedRoot\incoming\customer-02.csv" `
    -Value @'
id,name,status
2,Grace,active
'@ `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$approvedRoot\incoming\preserve-me.md" `
    -Value "# This file must survive the CSV cleanup." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Create the removable directory tree:

```powershell
Set-Content `
    -LiteralPath "$approvedRoot\removable-tree\level-1.txt" `
    -Value "Level one disposable content." `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$approvedRoot\removable-tree\nested\level-2.txt" `
    -Value "Level two disposable content." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Create the boundary-protection file:

```powershell
Set-Content `
    -LiteralPath "$outsideRoot\must-survive.txt" `
    -Value "Boundary test: this file must survive." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Create protected training files:

```powershell
$hiddenTrainingFile = Join-Path `
    -Path $approvedRoot `
    -ChildPath "protected\.hidden-training.txt"

$readOnlyTrainingFile = Join-Path `
    -Path $approvedRoot `
    -ChildPath "protected\read-only-training.txt"

Set-Content `
    -LiteralPath $hiddenTrainingFile `
    -Value "Hidden training content." `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath $readOnlyTrainingFile `
    -Value "Read-only training content." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Assign Windows file attributes:

```powershell
$hiddenItem = Get-Item `
    -LiteralPath $hiddenTrainingFile `
    -Force

$hiddenItem.Attributes = (
    $hiddenItem.Attributes -bor
    [System.IO.FileAttributes]::Hidden
)

$readOnlyItem = Get-Item `
    -LiteralPath $readOnlyTrainingFile `
    -Force

$readOnlyItem.Attributes = (
    $readOnlyItem.Attributes -bor
    [System.IO.FileAttributes]::ReadOnly
)
```

Enter the approved workspace:

```powershell
Set-Location -LiteralPath $approvedRoot
```

## The Verification

Confirm the exact current location:

```powershell
(Get-Location).Path -eq $approvedRoot
```

Expected result:

```text
True
```

Display the complete laboratory, including hidden items:

```powershell
Get-ChildItem `
    -LiteralPath $primerRoot `
    -Recurse `
    -Force |
    Sort-Object FullName |
    Select-Object FullName, Attributes
```

Confirm the expected counts:

```powershell
$directoryCount = @(
    Get-ChildItem `
        -LiteralPath $primerRoot `
        -Directory `
        -Recurse `
        -Force
).Count

$fileCount = @(
    Get-ChildItem `
        -LiteralPath $primerRoot `
        -File `
        -Recurse `
        -Force
).Count

[PSCustomObject]@{
    DirectoryCount = $directoryCount
    FileCount = $fileCount
    OutsideFileExists = Test-Path `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -PathType Leaf
}
```

Expected values:

```text
DirectoryCount     : 7
FileCount          : 8
OutsideFileExists  : True
```

---

# P2.3 Confirm Your Location Before Modifying Files

## The Target

Develop the habit of checking the current directory before using relative paths.

## The Concept

A relative path changes meaning according to your current location.

This command:

```powershell
Remove-Item -LiteralPath .\archive
```

does not mean “remove the tutorial archive.” It means:

> Remove the item named `archive` beneath wherever PowerShell currently is.

Your location is therefore part of the command, even though it is not written on the same line.

## The Implementation

Display the current location:

```powershell
Get-Location
```

Display only its path:

```powershell
$currentPath = (Get-Location).Path
$currentPath
```

Compare it with the approved workspace:

```powershell
$currentPath -eq $approvedRoot
```

Build an explicit location guard:

```powershell
if ((Get-Location).Path -ne $approvedRoot) {
    throw (
        "Unexpected current location. " +
        "Expected '$approvedRoot', received '$((Get-Location).Path)'."
    )
}

Write-Host "Current location is the approved workspace." `
    -ForegroundColor Green
```

Even when using exact absolute paths, confirming your location is useful context:

```powershell
Get-ChildItem `
    -LiteralPath $approvedRoot `
    -Force
```

## The Verification

Temporarily visit another directory and prove the guard detects it:

```powershell
Push-Location -LiteralPath $HOME

try {
    $guardDetectedMismatch = $false

    try {
        if ((Get-Location).Path -ne $approvedRoot) {
            throw "Current location is outside the approved workspace."
        }
    }
    catch {
        $guardDetectedMismatch = $true
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }

    $guardDetectedMismatch
}
finally {
    Pop-Location
}
```

Expected result:

```text
True
```

Confirm that you returned:

```powershell
(Get-Location).Path -eq $approvedRoot
```

Expected result:

```text
True
```

---

# P2.4 Distinguish `-Path` from `-LiteralPath`

## The Target

Understand when PowerShell should interpret wildcard characters and when it should treat a path exactly as written.

## The Concept

`-Path` supports wildcard expansion. `-LiteralPath` treats its value literally.

Common wildcard characters include:

| Character | Meaning |
|---|---|
| `*` | Zero or more characters |
| `?` | Exactly one character |
| `[ab]` | One listed character |

Use `-Path` when matching several items is intentional:

```powershell
Get-ChildItem -Path .\incoming\*.csv
```

Use `-LiteralPath` when identifying one exact item:

```powershell
Get-Item -LiteralPath .\incoming\customer-01.csv
```

For state-changing commands, exact paths are usually safer.

## The Implementation

Use an intentional wildcard to inspect CSV files:

```powershell
Get-ChildItem `
    -Path "$approvedRoot\incoming\*.csv" `
    -File |
    Select-Object Name, FullName
```

Retrieve one exact file:

```powershell
Get-Item `
    -LiteralPath "$approvedRoot\incoming\customer-01.csv" |
    Select-Object Name, FullName, Length
```

Store wildcard matches as exact file objects:

```powershell
$csvFiles = @(
    Get-ChildItem `
        -LiteralPath "$approvedRoot\incoming" `
        -Filter "*.csv" `
        -File
)

$csvFiles |
    Select-Object Name, FullName, Length
```

This is safer than repeatedly passing a wildcard into a destructive command. You inspect the selected objects first and then operate on that fixed collection.

## The Verification

Confirm exactly two CSV files were selected:

```powershell
[PSCustomObject]@{
    CsvCount = $csvFiles.Count
    FirstFileIncluded = (
        "customer-01.csv" -in $csvFiles.Name
    )
    SecondFileIncluded = (
        "customer-02.csv" -in $csvFiles.Name
    )
    MarkdownExcluded = (
        "preserve-me.md" -notin $csvFiles.Name
    )
}
```

Expected values:

```text
CsvCount           : 2
FirstFileIncluded  : True
SecondFileIncluded : True
MarkdownExcluded   : True
```

---

# P2.5 Validate the Target Type

## The Target

Confirm whether a target is a file, directory, or missing path.

## The Concept

A path may refer to:

- A **leaf**, usually a file
- A **container**, usually a directory
- Nothing, if the path is missing

A command intended for one file should reject a directory. A recursive directory operation should reject an unexpected file.

This is like confirming whether a shipping label identifies one package or an entire warehouse before authorizing disposal.

## The Implementation

Test a file:

```powershell
Test-Path `
    -LiteralPath "$approvedRoot\incoming\preserve-me.md" `
    -PathType Leaf
```

Test a directory:

```powershell
Test-Path `
    -LiteralPath "$approvedRoot\incoming" `
    -PathType Container
```

Test a missing path:

```powershell
Test-Path `
    -LiteralPath "$approvedRoot\missing-item"
```

Create an explicit file guard:

```powershell
$expectedFile = Join-Path `
    -Path $approvedRoot `
    -ChildPath "incoming\preserve-me.md"

if (-not (
    Test-Path `
        -LiteralPath $expectedFile `
        -PathType Leaf
)) {
    throw "Expected a file but did not find one: $expectedFile"
}
```

Create an explicit directory guard:

```powershell
$expectedDirectory = Join-Path `
    -Path $approvedRoot `
    -ChildPath "removable-tree"

if (-not (
    Test-Path `
        -LiteralPath $expectedDirectory `
        -PathType Container
)) {
    throw "Expected a directory but did not find one: $expectedDirectory"
}
```

Inspect the exact item:

```powershell
Get-Item `
    -LiteralPath $expectedDirectory `
    -Force |
    Select-Object Name, FullName, PSIsContainer, Attributes
```

## The Verification

Run:

```powershell
$fileItem = Get-Item `
    -LiteralPath $expectedFile `
    -Force

$directoryItem = Get-Item `
    -LiteralPath $expectedDirectory `
    -Force

[PSCustomObject]@{
    FileIsLeaf = -not $fileItem.PSIsContainer
    DirectoryIsContainer = $directoryItem.PSIsContainer
    MissingPathIsAbsent = -not (
        Test-Path `
            -LiteralPath "$approvedRoot\missing-item"
    )
}
```

Every value should be `True`.

---

# P2.6 Resolve Paths Before Acting

## The Target

Convert a relative path into an existing absolute path before modifying it.

## The Concept

`Resolve-Path` answers:

> Which existing item does this path actually identify?

A relative path may look harmless:

```text
.\removable-tree
```

The resolved result is explicit:

```text
C:\Users\YourName\powershell-safety-primer\approved-workspace\removable-tree
```

Resolution makes hidden assumptions visible.

## The Implementation

Ensure you are in the approved root:

```powershell
Set-Location -LiteralPath $approvedRoot
```

Resolve a relative directory:

```powershell
$resolvedTree = Resolve-Path `
    -LiteralPath .\removable-tree `
    -ErrorAction Stop

$resolvedTree
```

Read its absolute path:

```powershell
$resolvedTree.Path
```

Resolve a file:

```powershell
$resolvedFile = Resolve-Path `
    -LiteralPath .\incoming\preserve-me.md `
    -ErrorAction Stop

$resolvedFile.Path
```

Attempt to resolve a missing item safely:

```powershell
try {
    Resolve-Path `
        -LiteralPath .\missing-item `
        -ErrorAction Stop
}
catch {
    Write-Host "Missing path was rejected." -ForegroundColor Yellow
    Write-Host $_.Exception.Message
}
```

`Resolve-Path` works only for existing paths. For a destination that does not exist yet, resolve its existing parent and construct the child path from that trusted parent.

Example:

```powershell
$resolvedArchive = (
    Resolve-Path `
        -LiteralPath "$approvedRoot\archive" `
        -ErrorAction Stop
).Path

$newDestination = Join-Path `
    -Path $resolvedArchive `
    -ChildPath "future-file.txt"

$newDestination
```

## The Verification

Confirm the resolved paths are absolute:

```powershell
[PSCustomObject]@{
    TreePathIsAbsolute = [System.IO.Path]::IsPathRooted(
        $resolvedTree.Path
    )
    FilePathIsAbsolute = [System.IO.Path]::IsPathRooted(
        $resolvedFile.Path
    )
    TreeExists = Test-Path `
        -LiteralPath $resolvedTree.Path `
        -PathType Container
    FileExists = Test-Path `
        -LiteralPath $resolvedFile.Path `
        -PathType Leaf
}
```

Every value should be `True`.

---

# P2.7 Enforce an Approved Root Boundary

## The Target

Determine whether a target is safely inside the approved workspace.

## The Concept

Checking that a path merely *contains* the approved root’s text is unreliable.

For example, if the approved root were:

```text
C:\Labs\Safe
```

this different directory begins with similar characters:

```text
C:\Labs\Safety-Copy
```

A correct boundary check:

1. Resolves both paths.
2. Normalizes the approved root.
3. Appends a directory separator.
4. Checks whether the target begins with that complete prefix.
5. Separately decides whether the root itself may be modified.

## The Implementation

Resolve and normalize the approved root:

```powershell
$resolvedApprovedRoot = (
    Resolve-Path `
        -LiteralPath $approvedRoot `
        -ErrorAction Stop
).Path.TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
)

$approvedPrefix = (
    $resolvedApprovedRoot +
    [System.IO.Path]::DirectorySeparatorChar
)
```

Create a reusable boundary-test function:

```powershell
function Test-PathInsideApprovedRoot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $LiteralPath,

        [Parameter(Mandatory)]
        [string] $ApprovedRoot,

        [switch] $AllowRoot
    )

    $resolvedRoot = (
        Resolve-Path `
            -LiteralPath $ApprovedRoot `
            -ErrorAction Stop
    ).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    $resolvedTarget = (
        Resolve-Path `
            -LiteralPath $LiteralPath `
            -ErrorAction Stop
    ).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    $targetIsRoot = $resolvedTarget.Equals(
        $resolvedRoot,
        [System.StringComparison]::OrdinalIgnoreCase
    )

    if ($targetIsRoot) {
        return [bool] $AllowRoot
    }

    $rootPrefix = (
        $resolvedRoot +
        [System.IO.Path]::DirectorySeparatorChar
    )

    return $resolvedTarget.StartsWith(
        $rootPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )
}
```

Test a path inside the boundary:

```powershell
Test-PathInsideApprovedRoot `
    -LiteralPath "$approvedRoot\incoming" `
    -ApprovedRoot $approvedRoot
```

Expected result:

```text
True
```

Test the outside directory:

```powershell
Test-PathInsideApprovedRoot `
    -LiteralPath $outsideRoot `
    -ApprovedRoot $approvedRoot
```

Expected result:

```text
False
```

Test the approved root itself:

```powershell
Test-PathInsideApprovedRoot `
    -LiteralPath $approvedRoot `
    -ApprovedRoot $approvedRoot
```

Expected result:

```text
False
```

The root is rejected by default because deleting the complete safety boundary should require a separate decision.

## The Verification

Run all boundary cases:

```powershell
$boundaryChecks = @(
    [PSCustomObject]@{
        Case = "Child directory"
        Expected = $true
        Actual = Test-PathInsideApprovedRoot `
            -LiteralPath "$approvedRoot\removable-tree" `
            -ApprovedRoot $approvedRoot
    }

    [PSCustomObject]@{
        Case = "Child file"
        Expected = $true
        Actual = Test-PathInsideApprovedRoot `
            -LiteralPath "$approvedRoot\incoming\preserve-me.md" `
            -ApprovedRoot $approvedRoot
    }

    [PSCustomObject]@{
        Case = "Outside directory"
        Expected = $false
        Actual = Test-PathInsideApprovedRoot `
            -LiteralPath $outsideRoot `
            -ApprovedRoot $approvedRoot
    }

    [PSCustomObject]@{
        Case = "Approved root itself"
        Expected = $false
        Actual = Test-PathInsideApprovedRoot `
            -LiteralPath $approvedRoot `
            -ApprovedRoot $approvedRoot
    }
)

$boundaryChecks |
    ForEach-Object {
        $_ | Add-Member `
            -NotePropertyName Passed `
            -NotePropertyValue ($_.Expected -eq $_.Actual) `
            -PassThru
    } |
    Format-Table -AutoSize
```

Every `Passed` value should be `True`.

---

# P2.8 Build a Deletion Inventory

## The Target

Display the exact root and descendants that a recursive deletion would affect.

## The Concept

`-Recurse` broadens an operation from one container to its entire tree.

Before deleting a directory recursively, build an inventory containing:

- The directory itself
- Immediate files
- Nested directories
- Nested files
- Hidden items

This turns an abstract command into a concrete list.

## The Implementation

Select the removable tree:

```powershell
$treeTarget = Join-Path `
    -Path $approvedRoot `
    -ChildPath "removable-tree"
```

Validate it:

```powershell
if (-not (
    Test-Path `
        -LiteralPath $treeTarget `
        -PathType Container
)) {
    throw "Expected removable directory was not found: $treeTarget"
}

if (-not (
    Test-PathInsideApprovedRoot `
        -LiteralPath $treeTarget `
        -ApprovedRoot $approvedRoot
)) {
    throw "Target is outside the approved root: $treeTarget"
}
```

Build the complete inventory:

```powershell
$deletionInventory = @(
    Get-Item `
        -LiteralPath $treeTarget `
        -Force `
        -ErrorAction Stop

    Get-ChildItem `
        -LiteralPath $treeTarget `
        -Recurse `
        -Force `
        -ErrorAction Stop
)

$deletionInventory |
    Sort-Object FullName |
    Select-Object `
        FullName,
        PSIsContainer,
        Length,
        Attributes
```

Generate a summary:

```powershell
$inventorySummary = [PSCustomObject]@{
    Target = $treeTarget
    TotalItems = $deletionInventory.Count
    DirectoryCount = @(
        $deletionInventory |
            Where-Object {
                $_.PSIsContainer
            }
    ).Count
    FileCount = @(
        $deletionInventory |
            Where-Object {
                -not $_.PSIsContainer
            }
    ).Count
}

$inventorySummary |
    Format-List
```

## The Verification

Expected inventory:

- `removable-tree`
- `removable-tree\nested`
- `removable-tree\level-1.txt`
- `removable-tree\nested\level-2.txt`

Verify it:

```powershell
[PSCustomObject]@{
    TotalItemsIsFour = $deletionInventory.Count -eq 4
    DirectoryCountIsTwo = @(
        $deletionInventory |
            Where-Object {
                $_.PSIsContainer
            }
    ).Count -eq 2
    FileCountIsTwo = @(
        $deletionInventory |
            Where-Object {
                -not $_.PSIsContainer
            }
    ).Count -eq 2
}
```

Every value should be `True`.

---

# P2.9 Preview with `-WhatIf`

## The Target

Preview creation, copying, moving, renaming, and deletion without changing the filesystem.

## The Concept

`-WhatIf` asks a state-changing command to describe its intended action rather than perform it.

It is a rehearsal—not a transaction or backup.

`-WhatIf` is valuable because it helps reveal:

- The exact source
- The exact destination
- Whether recursion is involved
- Whether a command targets more items than expected

However, preview output does not guarantee that a later real operation will succeed. Permissions, file locks, or concurrent changes can still affect execution.

## The Implementation

Create a preview source file:

```powershell
$previewSource = Join-Path `
    -Path $approvedRoot `
    -ChildPath "incoming\preview-source.txt"

Set-Content `
    -LiteralPath $previewSource `
    -Value "Preview training content." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview a new directory:

```powershell
$previewDirectory = Join-Path `
    -Path $approvedRoot `
    -ChildPath "preview-directory"

New-Item `
    -Path $previewDirectory `
    -ItemType Directory `
    -WhatIf
```

Preview copying:

```powershell
$previewCopy = Join-Path `
    -Path $approvedRoot `
    -ChildPath "archive\preview-copy.txt"

Copy-Item `
    -LiteralPath $previewSource `
    -Destination $previewCopy `
    -WhatIf
```

Preview moving:

```powershell
$previewMove = Join-Path `
    -Path $approvedRoot `
    -ChildPath "archive\preview-moved.txt"

Move-Item `
    -LiteralPath $previewSource `
    -Destination $previewMove `
    -WhatIf
```

Preview renaming:

```powershell
Rename-Item `
    -LiteralPath $previewSource `
    -NewName "preview-renamed.txt" `
    -WhatIf
```

Preview recursive deletion:

```powershell
Remove-Item `
    -LiteralPath $treeTarget `
    -Recurse `
    -WhatIf
```

## The Verification

Confirm that none of the previewed changes occurred:

```powershell
[PSCustomObject]@{
    NewDirectoryWasNotCreated = -not (
        Test-Path -LiteralPath $previewDirectory
    )
    CopyWasNotCreated = -not (
        Test-Path -LiteralPath $previewCopy
    )
    SourceWasNotMoved = Test-Path `
        -LiteralPath $previewSource `
        -PathType Leaf
    MoveDestinationWasNotCreated = -not (
        Test-Path -LiteralPath $previewMove
    )
    RenamedPathWasNotCreated = -not (
        Test-Path `
            -LiteralPath "$approvedRoot\incoming\preview-renamed.txt"
    )
    TreeWasNotDeleted = Test-Path `
        -LiteralPath $treeTarget `
        -PathType Container
}
```

Every value should be `True`.

---

# P2.10 Understand `-Recurse`

## The Target

Understand why non-empty directory removal requires an explicit recursive operation.

## The Concept

Without `-Recurse`, a command targets the selected directory itself. With `-Recurse`, it processes descendants beneath that directory.

Think of the difference as:

- Remove one empty filing cabinet
- Remove the cabinet and every drawer and document inside it

`-Recurse` dramatically increases the scope of an operation.

## The Implementation

Attempt to remove the non-empty tree without `-Recurse`:

```powershell
$nonRecursiveRemovalFailed = $false

try {
    Remove-Item `
        -LiteralPath $treeTarget `
        -ErrorAction Stop
}
catch {
    $nonRecursiveRemovalFailed = $true

    Write-Host (
        "PowerShell refused to remove the non-empty directory " +
        "without recursive processing."
    ) -ForegroundColor Yellow

    Write-Host $_.Exception.Message
}
```

Confirm the directory remains:

```powershell
Test-Path `
    -LiteralPath $treeTarget `
    -PathType Container
```

Preview the recursive operation:

```powershell
Remove-Item `
    -LiteralPath $treeTarget `
    -Recurse `
    -WhatIf
```

Do not execute it yet.

## The Verification

Run:

```powershell
[PSCustomObject]@{
    NonRecursiveOperationFailed = $nonRecursiveRemovalFailed
    RootStillExists = Test-Path `
        -LiteralPath $treeTarget `
        -PathType Container
    NestedFileStillExists = Test-Path `
        -LiteralPath "$treeTarget\nested\level-2.txt" `
        -PathType Leaf
}
```

Every value should be `True`.

---

# P2.11 Understand `-Force`

## The Target

Understand what `-Force` can and cannot do.

## The Concept

`-Force` requests that a command proceed through certain ordinary provider restrictions.

For filesystem work, it may help with:

- Including hidden items in a listing
- Removing hidden files
- Removing read-only files
- Replacing an existing writable destination
- Creating missing parent directories in supported operations

It does not automatically:

- Grant administrator access
- Bypass NTFS access-control permissions
- Take ownership of files
- Decrypt protected data
- Unlock files exclusively held by another process
- Bypass security software
- Override organizational policy

`-Force` means “proceed where the provider permits,” not “defeat all security.”

## The Implementation

List protected files without `-Force`:

```powershell
Get-ChildItem `
    -LiteralPath "$approvedRoot\protected"
```

List them with `-Force`:

```powershell
Get-ChildItem `
    -LiteralPath "$approvedRoot\protected" `
    -Force |
    Select-Object Name, Attributes
```

Confirm their attributes:

```powershell
$hiddenItem = Get-Item `
    -LiteralPath $hiddenTrainingFile `
    -Force

$readOnlyItem = Get-Item `
    -LiteralPath $readOnlyTrainingFile `
    -Force

[PSCustomObject]@{
    HiddenAttribute = [bool](
        $hiddenItem.Attributes -band
        [System.IO.FileAttributes]::Hidden
    )
    ReadOnlyAttribute = [bool](
        $readOnlyItem.Attributes -band
        [System.IO.FileAttributes]::ReadOnly
    )
}
```

Preview deletion of both exact items:

```powershell
Get-Item `
    -LiteralPath @(
        $hiddenTrainingFile
        $readOnlyTrainingFile
    ) `
    -Force |
    Remove-Item `
        -Force `
        -WhatIf
```

Do not remove them yet.

## The Verification

Confirm both protected files still exist:

```powershell
[PSCustomObject]@{
    HiddenFileStillExists = Test-Path `
        -LiteralPath $hiddenTrainingFile `
        -PathType Leaf
    ReadOnlyFileStillExists = Test-Path `
        -LiteralPath $readOnlyTrainingFile `
        -PathType Leaf
}
```

Both values should be `True`.

---

# P2.12 Safely Remove a Fixed Collection of Wildcard Matches

## The Target

Remove only the two CSV files from `incoming`, while preserving `preserve-me.md`.

## The Concept

Avoid sending a broad wildcard directly into a destructive command when you can first materialize and inspect the matches.

Safer workflow:

```text
Select matches
     ↓
Store exact objects
     ↓
Inspect full paths
     ↓
Preview those objects
     ↓
Delete those same objects
     ↓
Verify unrelated items
```

The collection is fixed at selection time. You know which objects will enter `Remove-Item`.

## The Implementation

Select the matching files:

```powershell
$csvTargets = @(
    Get-ChildItem `
        -LiteralPath "$approvedRoot\incoming" `
        -Filter "*.csv" `
        -File `
        -ErrorAction Stop
)
```

Require exactly two matches:

```powershell
if ($csvTargets.Count -ne 2) {
    throw (
        "Expected exactly two CSV files, but selected " +
        "$($csvTargets.Count). Refusing deletion."
    )
}
```

Verify every selected path is inside the approved root:

```powershell
foreach ($target in $csvTargets) {
    $insideBoundary = Test-PathInsideApprovedRoot `
        -LiteralPath $target.FullName `
        -ApprovedRoot $approvedRoot

    if (-not $insideBoundary) {
        throw "Selected target is outside the approved root: $($target.FullName)"
    }
}
```

Inspect the fixed collection:

```powershell
$csvTargets |
    Sort-Object FullName |
    Select-Object Name, Length, FullName
```

Preview deletion:

```powershell
$csvTargets |
    Remove-Item -WhatIf
```

Verify preview preservation:

```powershell
@(
    $csvTargets |
        Where-Object {
            -not (
                Test-Path `
                    -LiteralPath $_.FullName `
                    -PathType Leaf
            )
        }
).Count -eq 0
```

Expected result:

```text
True
```

Execute the removal:

```powershell
$csvTargets |
    Remove-Item -ErrorAction Stop
```

## The Verification

Confirm that the CSV files are gone and the Markdown file remains:

```powershell
[PSCustomObject]@{
    CsvFilesRemaining = @(
        Get-ChildItem `
            -LiteralPath "$approvedRoot\incoming" `
            -Filter "*.csv" `
            -File
    ).Count
    MarkdownFileSurvived = Test-Path `
        -LiteralPath "$approvedRoot\incoming\preserve-me.md" `
        -PathType Leaf
    PreviewSourceSurvived = Test-Path `
        -LiteralPath $previewSource `
        -PathType Leaf
}
```

Expected result:

```text
CsvFilesRemaining   : 0
MarkdownFileSurvived: True
PreviewSourceSurvived: True
```

---

# P2.13 Execute a Validated Recursive Deletion

## The Target

Remove only:

```text
approved-workspace\removable-tree
```

after validating, inventorying, and previewing it.

## The Concept

A recursive deletion should not be one impulsive command. It should be the final action in a chain of checks.

The intended operation is:

```text
exact target
+ expected item type
+ approved boundary
+ known inventory
+ successful preview
= authorized execution
```

## The Implementation

Reconstruct the target rather than trusting a stale variable:

```powershell
$recursiveTarget = Join-Path `
    -Path $approvedRoot `
    -ChildPath "removable-tree"
```

Validate its type:

```powershell
if (-not (
    Test-Path `
        -LiteralPath $recursiveTarget `
        -PathType Container
)) {
    throw "Recursive target is missing or is not a directory: $recursiveTarget"
}
```

Resolve it:

```powershell
$resolvedRecursiveTarget = (
    Resolve-Path `
        -LiteralPath $recursiveTarget `
        -ErrorAction Stop
).Path
```

Validate its boundary:

```powershell
if (-not (
    Test-PathInsideApprovedRoot `
        -LiteralPath $resolvedRecursiveTarget `
        -ApprovedRoot $approvedRoot
)) {
    throw "Refusing recursive deletion outside the approved root."
}
```

Rebuild and inspect the inventory:

```powershell
$recursiveInventory = @(
    Get-Item `
        -LiteralPath $resolvedRecursiveTarget `
        -Force

    Get-ChildItem `
        -LiteralPath $resolvedRecursiveTarget `
        -Recurse `
        -Force
)

$recursiveInventory |
    Sort-Object FullName |
    Select-Object FullName, PSIsContainer, Length, Attributes
```

Require the expected inventory size:

```powershell
if ($recursiveInventory.Count -ne 4) {
    throw (
        "Expected four items in the recursive inventory, found " +
        "$($recursiveInventory.Count). Refusing deletion."
    )
}
```

Preview:

```powershell
Remove-Item `
    -LiteralPath $resolvedRecursiveTarget `
    -Recurse `
    -WhatIf
```

Execute:

```powershell
Remove-Item `
    -LiteralPath $resolvedRecursiveTarget `
    -Recurse `
    -ErrorAction Stop
```

## The Verification

Confirm the intended tree disappeared:

```powershell
$targetWasRemoved = -not (
    Test-Path -LiteralPath $resolvedRecursiveTarget
)
```

Confirm unrelated resources survived:

```powershell
$unrelatedItemsSurvived = (
    Test-Path `
        -LiteralPath "$approvedRoot\incoming\preserve-me.md" `
        -PathType Leaf
) -and (
    Test-Path `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -PathType Leaf
)

[PSCustomObject]@{
    TargetWasRemoved = $targetWasRemoved
    UnrelatedItemsSurvived = $unrelatedItemsSurvived
}
```

Both values should be `True`.

---

# P2.14 Remove Hidden and Read-Only Files Safely

## The Target

Remove the two protected training files using exact paths and `-Force`.

## The Concept

Hidden and read-only attributes may require `-Force`, but they do not change the safety sequence.

We still:

1. Resolve exact paths.
2. Validate the boundary.
3. Inspect attributes.
4. Preview.
5. Execute.
6. Verify.

## The Implementation

Retrieve the exact protected files:

```powershell
$protectedTargets = @(
    Get-Item `
        -LiteralPath $hiddenTrainingFile `
        -Force `
        -ErrorAction Stop

    Get-Item `
        -LiteralPath $readOnlyTrainingFile `
        -Force `
        -ErrorAction Stop
)
```

Validate every target:

```powershell
foreach ($target in $protectedTargets) {
    if (-not (
        Test-PathInsideApprovedRoot `
            -LiteralPath $target.FullName `
            -ApprovedRoot $approvedRoot
    )) {
        throw "Protected target escaped the approved root: $($target.FullName)"
    }

    if ($target.PSIsContainer) {
        throw "Expected a file but found a directory: $($target.FullName)"
    }
}
```

Inspect them:

```powershell
$protectedTargets |
    Select-Object Name, FullName, Attributes, Length
```

Preview:

```powershell
$protectedTargets |
    Remove-Item `
        -Force `
        -WhatIf
```

Execute:

```powershell
$protectedTargets |
    Remove-Item `
        -Force `
        -ErrorAction Stop
```

## The Verification

Confirm both files were removed:

```powershell
[PSCustomObject]@{
    HiddenFileWasRemoved = -not (
        Test-Path -LiteralPath $hiddenTrainingFile
    )
    ReadOnlyFileWasRemoved = -not (
        Test-Path -LiteralPath $readOnlyTrainingFile
    )
    ProtectedDirectorySurvived = Test-Path `
        -LiteralPath "$approvedRoot\protected" `
        -PathType Container
    OutsideFileSurvived = Test-Path `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -PathType Leaf
}
```

Every value should be `True`.

---

# P2.15 Understand `-Confirm`

## The Target

Understand the difference between previewing an operation and requesting interactive approval.

## The Concept

`-WhatIf` reports what would happen and performs no change.

`-Confirm` asks whether the command should proceed:

```text
[Y] Yes
[A] Yes to All
[N] No
[L] No to All
[S] Suspend
[?] Help
```

The exact prompt can vary by PowerShell version and command.

Use `-Confirm` when a human should approve an operation interactively. Do not depend on an interactive prompt inside unattended automation.

## The Implementation

Create a disposable confirmation file:

```powershell
$confirmationFile = Join-Path `
    -Path $approvedRoot `
    -ChildPath "archive\confirmation-demo.txt"

Set-Content `
    -LiteralPath $confirmationFile `
    -Value "Confirmation demonstration." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview it first:

```powershell
Remove-Item `
    -LiteralPath $confirmationFile `
    -WhatIf
```

Now request confirmation:

```powershell
Remove-Item `
    -LiteralPath $confirmationFile `
    -Confirm
```

At the prompt, enter:

```text
N
```

The file should remain.

Run it again:

```powershell
Remove-Item `
    -LiteralPath $confirmationFile `
    -Confirm
```

This time, enter:

```text
Y
```

The file should be removed.

## The Verification

Confirm the final state:

```powershell
Test-Path -LiteralPath $confirmationFile
```

Expected result:

```text
False
```

> In automation, `-Confirm:$false` can suppress a prompt, but it must not replace target validation. It should be used only when the calling code has already authorized the exact operation.

---

# P2.16 Handle Errors Deliberately

## The Target

Catch a failed file operation and leave the workspace in a predictable state.

## The Concept

Many PowerShell errors are non-terminating by default. They report a problem but may allow subsequent commands to continue.

`-ErrorAction Stop` converts many command errors into terminating errors that `try` and `catch` can handle.

A robust operation commonly uses:

```powershell
try {
    # Operation that must succeed.
}
catch {
    # Report or recover from failure.
}
finally {
    # Cleanup that must always occur.
}
```

## The Implementation

Define a missing source:

```powershell
$missingSource = Join-Path `
    -Path $approvedRoot `
    -ChildPath "incoming\does-not-exist.txt"

$unexpectedDestination = Join-Path `
    -Path $approvedRoot `
    -ChildPath "archive\unexpected-copy.txt"
```

Attempt the copy:

```powershell
$copyFailureWasCaught = $false

try {
    Copy-Item `
        -LiteralPath $missingSource `
        -Destination $unexpectedDestination `
        -ErrorAction Stop
}
catch {
    $copyFailureWasCaught = $true

    Write-Host "The failed copy was handled." `
        -ForegroundColor Yellow

    Write-Host "Message: $($_.Exception.Message)"
}
finally {
    if (Test-Path -LiteralPath $unexpectedDestination) {
        Remove-Item `
            -LiteralPath $unexpectedDestination `
            -Force `
            -ErrorAction SilentlyContinue
    }
}
```

## The Verification

Run:

```powershell
[PSCustomObject]@{
    FailureWasCaught = $copyFailureWasCaught
    MissingSourceIsStillAbsent = -not (
        Test-Path -LiteralPath $missingSource
    )
    PartialDestinationIsAbsent = -not (
        Test-Path -LiteralPath $unexpectedDestination
    )
}
```

Every value should be `True`.

---

# P2.17 Understand That `Remove-Item` Is Not the Recycle Bin

## The Target

Set correct expectations about command-line deletion and recovery.

## The Concept

`Remove-Item` generally removes filesystem items directly. It does not ordinarily send them to the Windows Recycle Bin.

You should treat this command:

```powershell
Remove-Item -LiteralPath $target
```

as permanent.

Recovery may depend on:

- A backup
- Version control
- Cloud-storage history
- Filesystem snapshots
- Specialized recovery tools
- Whether the deleted storage blocks have been overwritten

None of those is an automatic PowerShell undo mechanism.

### Safer strategies

Before deleting important data:

- Commit source code to Git
- Create a verified backup
- Copy data to an archive
- Use `-WhatIf`
- Inspect exact full paths
- Require confirmation
- Prefer moving to a quarantine directory before permanent deletion

A **quarantine directory** is a temporary holding area. Moving data there allows a later review before final removal.

## The Implementation

Create a quarantine directory:

```powershell
$quarantineRoot = Join-Path `
    -Path $approvedRoot `
    -ChildPath "quarantine"

if (-not (
    Test-Path `
        -LiteralPath $quarantineRoot `
        -PathType Container
)) {
    $null = New-Item `
        -Path $quarantineRoot `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Create a disposable candidate:

```powershell
$quarantineCandidate = Join-Path `
    -Path $approvedRoot `
    -ChildPath "incoming\quarantine-candidate.txt"

Set-Content `
    -LiteralPath $quarantineCandidate `
    -Value "Review this file before permanent deletion." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Define the destination:

```powershell
$quarantinedFile = Join-Path `
    -Path $quarantineRoot `
    -ChildPath "quarantine-candidate.txt"
```

Preview the move:

```powershell
Move-Item `
    -LiteralPath $quarantineCandidate `
    -Destination $quarantinedFile `
    -WhatIf
```

Perform the move:

```powershell
Move-Item `
    -LiteralPath $quarantineCandidate `
    -Destination $quarantinedFile `
    -ErrorAction Stop
```

Inspect the quarantine:

```powershell
Get-ChildItem `
    -LiteralPath $quarantineRoot `
    -Force |
    Select-Object Name, FullName, Length
```

The file can now be restored by moving it back or permanently removed after review.

## The Verification

Confirm it moved instead of being deleted:

```powershell
[PSCustomObject]@{
    OriginalPathIsAbsent = -not (
        Test-Path -LiteralPath $quarantineCandidate
    )
    QuarantinedCopyExists = Test-Path `
        -LiteralPath $quarantinedFile `
        -PathType Leaf
}
```

Both values should be `True`.

---

# P2.18 Add `-WhatIf` to a Custom Safety Function

## The Target

Create `Remove-ApprovedItem`, a reusable function that:

- Accepts one exact existing path
- Accepts one approved root
- Resolves both paths
- Rejects the approved root itself
- Rejects outside paths
- Requires `-Recurse` for non-empty directories
- Supports `-Force`
- Supports `-WhatIf`
- Supports `-Confirm`

## The Concept

PowerShell’s `ShouldProcess` framework enables custom commands to participate in standard safety behavior.

Declare:

```powershell
[CmdletBinding(SupportsShouldProcess)]
```

Then guard the mutation:

```powershell
if ($PSCmdlet.ShouldProcess($target, $action)) {
    # Perform the change.
}
```

When the caller supplies `-WhatIf`, PowerShell describes the action and `ShouldProcess` returns false.

## The Implementation

Define the complete function:

```powershell
function Remove-ApprovedItem {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = "High"
    )]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApprovedRoot,

        [switch] $Recurse,

        [switch] $Force
    )

    $resolvedRoot = (
        Resolve-Path `
            -LiteralPath $ApprovedRoot `
            -ErrorAction Stop
    ).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    $resolvedTarget = (
        Resolve-Path `
            -LiteralPath $LiteralPath `
            -ErrorAction Stop
    ).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    $targetIsRoot = $resolvedTarget.Equals(
        $resolvedRoot,
        [System.StringComparison]::OrdinalIgnoreCase
    )

    if ($targetIsRoot) {
        throw "Refusing to remove the approved root itself: $resolvedTarget"
    }

    $rootPrefix = (
        $resolvedRoot +
        [System.IO.Path]::DirectorySeparatorChar
    )

    $targetIsInsideRoot = $resolvedTarget.StartsWith(
        $rootPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )

    if (-not $targetIsInsideRoot) {
        throw "Refusing to remove a path outside the approved root: $resolvedTarget"
    }

    $targetItem = Get-Item `
        -LiteralPath $resolvedTarget `
        -Force `
        -ErrorAction Stop

    if ($targetItem.PSIsContainer -and -not $Recurse) {
        $children = @(
            Get-ChildItem `
                -LiteralPath $resolvedTarget `
                -Force `
                -ErrorAction Stop
        )

        if ($children.Count -gt 0) {
            throw (
                "The directory is not empty. Inspect it and " +
                "explicitly supply -Recurse: $resolvedTarget"
            )
        }
    }

    $removeParameters = @{
        LiteralPath = $resolvedTarget
        ErrorAction = "Stop"
    }

    if ($Recurse) {
        $removeParameters.Recurse = $true
    }

    if ($Force) {
        $removeParameters.Force = $true
    }

    if ($PSCmdlet.ShouldProcess(
        $resolvedTarget,
        "Permanently remove filesystem item"
    )) {
        Remove-Item @removeParameters
    }
}
```

Create a disposable function target:

```powershell
$functionDemo = Join-Path `
    -Path $approvedRoot `
    -ChildPath "function-demo"

$null = New-Item `
    -Path "$functionDemo\nested" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$functionDemo\nested\demo.txt" `
    -Value "Disposable function demonstration." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview the custom operation:

```powershell
Remove-ApprovedItem `
    -LiteralPath $functionDemo `
    -ApprovedRoot $approvedRoot `
    -Recurse `
    -WhatIf
```

Confirm preview preservation:

```powershell
Test-Path `
    -LiteralPath $functionDemo `
    -PathType Container
```

Expected result:

```text
True
```

Execute after inspection:

```powershell
Remove-ApprovedItem `
    -LiteralPath $functionDemo `
    -ApprovedRoot $approvedRoot `
    -Recurse `
    -Confirm:$false
```

## The Verification

Confirm the target was removed:

```powershell
$functionTargetWasRemoved = -not (
    Test-Path -LiteralPath $functionDemo
)
```

Confirm an outside target is rejected:

```powershell
$outsideTargetWasRejected = $false

try {
    Remove-ApprovedItem `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -ApprovedRoot $approvedRoot `
        -Confirm:$false
}
catch {
    $outsideTargetWasRejected = $true
    Write-Host "Outside target was rejected." -ForegroundColor Green
    Write-Host $_.Exception.Message
}
```

Confirm the protected outside file survived:

```powershell
[PSCustomObject]@{
    FunctionTargetWasRemoved = $functionTargetWasRemoved
    OutsideTargetWasRejected = $outsideTargetWasRejected
    OutsideFileSurvived = Test-Path `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -PathType Leaf
}
```

Every value should be `True`.

---

# P2.19 Understand Boundary-Check Limitations

## The Target

Understand what string-based path boundaries protect against and what additional risks remain.

## The Concept

The function above is appropriate for ordinary tutorial directories, but production-grade deletion tools must consider additional filesystem behavior.

A path can contain a **symbolic link**, **junction**, or another **reparse point**. These are filesystem objects that redirect access to another location.

For example:

```text
approved-workspace\linked-data
```

might point to:

```text
C:\ImportantData
```

The visible link is inside the approved root, but its destination may be outside it.

Other risks include:

- A target changing between validation and execution
- Another process creating new files after inventory
- Network paths behaving differently from local NTFS paths
- Case-sensitivity differences
- Filesystem permissions changing
- Hard links allowing multiple names to reference file content
- Mounted paths or provider-specific behavior

The period between checking a target and using it is sometimes called a **time-of-check to time-of-use**, or **TOCTOU**, window.

The key lesson is:

> A path-prefix boundary is a useful guardrail, but it is not a complete security sandbox.

## The Implementation

Inspect the approved workspace for reparse points:

```powershell
$reparsePoints = @(
    Get-ChildItem `
        -LiteralPath $approvedRoot `
        -Recurse `
        -Force `
        -ErrorAction Stop |
        Where-Object {
            [bool](
                $_.Attributes -band
                [System.IO.FileAttributes]::ReparsePoint
            )
        }
)

$reparsePoints |
    Select-Object Name, FullName, LinkType, Target, Attributes
```

For this tutorial laboratory, no reparse points should exist.

Create a reusable reparse-point check:

```powershell
function Test-TreeContainsReparsePoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $LiteralPath
    )

    $rootItem = Get-Item `
        -LiteralPath $LiteralPath `
        -Force `
        -ErrorAction Stop

    $items = @(
        $rootItem

        if ($rootItem.PSIsContainer) {
            Get-ChildItem `
                -LiteralPath $rootItem.FullName `
                -Recurse `
                -Force `
                -ErrorAction Stop
        }
    )

    $matchingItems = @(
        $items |
            Where-Object {
                [bool](
                    $_.Attributes -band
                    [System.IO.FileAttributes]::ReparsePoint
                )
            }
    )

    return $matchingItems.Count -gt 0
}
```

Check the approved workspace:

```powershell
Test-TreeContainsReparsePoint `
    -LiteralPath $approvedRoot
```

Expected result:

```text
False
```

Add a defensive rejection before recursively deleting an untrusted tree:

```powershell
$targetToValidate = Join-Path `
    -Path $approvedRoot `
    -ChildPath "quarantine"

if (
    Test-TreeContainsReparsePoint `
        -LiteralPath $targetToValidate
) {
    throw (
        "The target contains a reparse point. " +
        "Refusing recursive modification: $targetToValidate"
    )
}

Write-Host "No reparse points were found." `
    -ForegroundColor Green
```

## The Verification

Confirm that the laboratory contains no reparse points:

```powershell
[PSCustomObject]@{
    ReparsePointCount = $reparsePoints.Count
    ApprovedRootIsClear = -not (
        Test-TreeContainsReparsePoint `
            -LiteralPath $approvedRoot
    )
}
```

Expected result:

```text
ReparsePointCount : 0
ApprovedRootIsClear : True
```

> Do not create a symbolic link merely for this exercise. Creating links can require additional Windows privileges or Developer Mode, and careless link exercises can point at important data.

---

# P2.20 Improve the Custom Function with Reparse-Point Protection

## The Target

Create a stricter version of the deletion function that refuses:

- The approved root itself
- Paths outside the approved root
- Non-empty directories without `-Recurse`
- Recursive trees containing reparse points

## The Concept

Safety controls should be layered.

No single check is perfect, but several independent checks make accidental misuse less likely:

```text
Exact existing path
        +
Approved-root boundary
        +
Root-self protection
        +
Directory-content inspection
        +
Reparse-point rejection
        +
ShouldProcess
        =
Stronger defensive operation
```

## The Implementation

Define the complete stricter function:

```powershell
function Remove-ApprovedItemStrict {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = "High"
    )]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApprovedRoot,

        [switch] $Recurse,

        [switch] $Force
    )

    $resolvedRoot = (
        Resolve-Path `
            -LiteralPath $ApprovedRoot `
            -ErrorAction Stop
    ).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    $resolvedTarget = (
        Resolve-Path `
            -LiteralPath $LiteralPath `
            -ErrorAction Stop
    ).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    if ($resolvedTarget.Equals(
        $resolvedRoot,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "Refusing to remove the approved root itself: $resolvedTarget"
    }

    $rootPrefix = (
        $resolvedRoot +
        [System.IO.Path]::DirectorySeparatorChar
    )

    if (-not $resolvedTarget.StartsWith(
        $rootPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "Target is outside the approved root: $resolvedTarget"
    }

    $targetItem = Get-Item `
        -LiteralPath $resolvedTarget `
        -Force `
        -ErrorAction Stop

    $targetHasReparseAttribute = [bool](
        $targetItem.Attributes -band
        [System.IO.FileAttributes]::ReparsePoint
    )

    if ($targetHasReparseAttribute) {
        throw "The target itself is a reparse point: $resolvedTarget"
    }

    if ($targetItem.PSIsContainer) {
        $immediateChildren = @(
            Get-ChildItem `
                -LiteralPath $resolvedTarget `
                -Force `
                -ErrorAction Stop
        )

        if (
            $immediateChildren.Count -gt 0 -and
            -not $Recurse
        ) {
            throw (
                "The directory is not empty. " +
                "Inspect it and explicitly specify -Recurse: " +
                $resolvedTarget
            )
        }

        if ($Recurse) {
            $reparsePoints = @(
                Get-ChildItem `
                    -LiteralPath $resolvedTarget `
                    -Recurse `
                    -Force `
                    -ErrorAction Stop |
                    Where-Object {
                        [bool](
                            $_.Attributes -band
                            [System.IO.FileAttributes]::ReparsePoint
                        )
                    }
            )

            if ($reparsePoints.Count -gt 0) {
                $reparsePathList = (
                    $reparsePoints.FullName |
                        Sort-Object
                ) -join [Environment]::NewLine

                throw (
                    "Recursive deletion was refused because the tree " +
                    "contains reparse points:" +
                    [Environment]::NewLine +
                    $reparsePathList
                )
            }
        }
    }

    $removeParameters = @{
        LiteralPath = $resolvedTarget
        ErrorAction = "Stop"
    }

    if ($Recurse) {
        $removeParameters.Recurse = $true
    }

    if ($Force) {
        $removeParameters.Force = $true
    }

    if ($PSCmdlet.ShouldProcess(
        $resolvedTarget,
        "Permanently remove validated filesystem item"
    )) {
        Remove-Item @removeParameters
    }
}
```

Create a disposable test tree:

```powershell
$strictFunctionDemo = Join-Path `
    -Path $approvedRoot `
    -ChildPath "strict-function-demo"

$null = New-Item `
    -Path "$strictFunctionDemo\nested" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$strictFunctionDemo\nested\sample.txt" `
    -Value "Strict-function disposable content." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview:

```powershell
Remove-ApprovedItemStrict `
    -LiteralPath $strictFunctionDemo `
    -ApprovedRoot $approvedRoot `
    -Recurse `
    -WhatIf
```

Confirm it remains:

```powershell
Test-Path `
    -LiteralPath $strictFunctionDemo `
    -PathType Container
```

Execute:

```powershell
Remove-ApprovedItemStrict `
    -LiteralPath $strictFunctionDemo `
    -ApprovedRoot $approvedRoot `
    -Recurse `
    -Confirm:$false
```

## The Verification

Confirm the test tree was removed:

```powershell
$strictTargetRemoved = -not (
    Test-Path -LiteralPath $strictFunctionDemo
)
```

Prove that the approved root is rejected:

```powershell
$rootWasRejected = $false

try {
    Remove-ApprovedItemStrict `
        -LiteralPath $approvedRoot `
        -ApprovedRoot $approvedRoot `
        -Recurse `
        -Confirm:$false
}
catch {
    $rootWasRejected = $true
    Write-Host "Approved-root protection worked." `
        -ForegroundColor Green
}
```

Prove that the outside path is rejected:

```powershell
$outsideWasRejected = $false

try {
    Remove-ApprovedItemStrict `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -ApprovedRoot $approvedRoot `
        -Confirm:$false
}
catch {
    $outsideWasRejected = $true
    Write-Host "Outside-path protection worked." `
        -ForegroundColor Green
}
```

Inspect the result:

```powershell
[PSCustomObject]@{
    StrictTargetRemoved = $strictTargetRemoved
    ApprovedRootRejected = $rootWasRejected
    OutsidePathRejected = $outsideWasRejected
    ApprovedRootSurvived = Test-Path `
        -LiteralPath $approvedRoot `
        -PathType Container
    OutsideFileSurvived = Test-Path `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -PathType Leaf
}
```

Every value should be `True`.

---

# P2.21 Verify Source and Destination Before Copying

## The Target

Safely copy one file into the archive and verify that its contents match the source.

## The Concept

Copying is less destructive than deleting, but it can still:

- Replace an existing destination
- Put data in the wrong directory
- Duplicate sensitive material
- Consume storage
- Create a misleading or incomplete backup

A safe copy validates both ends:

```text
Validate source
      ↓
Resolve destination parent
      ↓
Reject unexpected existing destination
      ↓
Preview
      ↓
Copy
      ↓
Verify content
```

A cryptographic hash is a content fingerprint. Matching SHA-256 hashes strongly indicate that two files contain identical bytes.

## The Implementation

Use the surviving Markdown file as the source:

```powershell
$copySource = Join-Path `
    -Path $approvedRoot `
    -ChildPath "incoming\preserve-me.md"

$archiveDirectory = Join-Path `
    -Path $approvedRoot `
    -ChildPath "archive"

$copyDestination = Join-Path `
    -Path $archiveDirectory `
    -ChildPath "preserve-me.copy.md"
```

Validate the source:

```powershell
if (-not (
    Test-Path `
        -LiteralPath $copySource `
        -PathType Leaf
)) {
    throw "Copy source does not exist: $copySource"
}
```

Resolve and validate the destination parent:

```powershell
$resolvedArchiveDirectory = (
    Resolve-Path `
        -LiteralPath $archiveDirectory `
        -ErrorAction Stop
).Path

if (-not (
    Test-PathInsideApprovedRoot `
        -LiteralPath $resolvedArchiveDirectory `
        -ApprovedRoot $approvedRoot
)) {
    throw "Destination parent is outside the approved root."
}
```

Refuse an unexpected existing destination:

```powershell
if (Test-Path -LiteralPath $copyDestination) {
    throw "Destination already exists: $copyDestination"
}
```

Inspect source and destination:

```powershell
Get-Item `
    -LiteralPath $copySource |
    Select-Object Name, FullName, Length

[PSCustomObject]@{
    Destination = $copyDestination
    DestinationCurrentlyExists = Test-Path `
        -LiteralPath $copyDestination
}
```

Preview:

```powershell
Copy-Item `
    -LiteralPath $copySource `
    -Destination $copyDestination `
    -WhatIf
```

Execute:

```powershell
Copy-Item `
    -LiteralPath $copySource `
    -Destination $copyDestination `
    -ErrorAction Stop
```

## The Verification

Calculate hashes:

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
```

Verify:

```powershell
[PSCustomObject]@{
    SourceStillExists = Test-Path `
        -LiteralPath $copySource `
        -PathType Leaf
    DestinationExists = Test-Path `
        -LiteralPath $copyDestination `
        -PathType Leaf
    HashesMatch = $sourceHash -eq $destinationHash
}
```

Every value should be `True`.

---

# P2.22 Verify Both Ends Before Moving

## The Target

Move `preview-source.txt` into the archive under a new name.

## The Concept

A move changes two locations:

- The source should disappear.
- The destination should appear.

Moving across different volumes can internally behave more like copying followed by deletion, so verify the final state rather than assuming one mechanism.

## The Implementation

Define exact paths:

```powershell
$moveSource = Join-Path `
    -Path $approvedRoot `
    -ChildPath "incoming\preview-source.txt"

$moveDestination = Join-Path `
    -Path $approvedRoot `
    -ChildPath "archive\preview-archived.txt"
```

Validate the source:

```powershell
if (-not (
    Test-Path `
        -LiteralPath $moveSource `
        -PathType Leaf
)) {
    throw "Move source is missing: $moveSource"
}
```

Reject an existing destination:

```powershell
if (Test-Path -LiteralPath $moveDestination) {
    throw "Move destination already exists: $moveDestination"
}
```

Validate both parent directories:

```powershell
$sourceParent = Split-Path `
    -Path $moveSource `
    -Parent

$destinationParent = Split-Path `
    -Path $moveDestination `
    -Parent

foreach ($parent in @(
    $sourceParent
    $destinationParent
)) {
    if (-not (
        Test-PathInsideApprovedRoot `
            -LiteralPath $parent `
            -ApprovedRoot $approvedRoot
    )) {
        throw "Move parent is outside the approved root: $parent"
    }
}
```

Record the source hash:

```powershell
$preMoveHash = (
    Get-FileHash `
        -LiteralPath $moveSource `
        -Algorithm SHA256
).Hash
```

Preview:

```powershell
Move-Item `
    -LiteralPath $moveSource `
    -Destination $moveDestination `
    -WhatIf
```

Execute:

```powershell
Move-Item `
    -LiteralPath $moveSource `
    -Destination $moveDestination `
    -ErrorAction Stop
```

## The Verification

Calculate the destination hash:

```powershell
$postMoveHash = (
    Get-FileHash `
        -LiteralPath $moveDestination `
        -Algorithm SHA256
).Hash
```

Verify both ends:

```powershell
[PSCustomObject]@{
    SourceIsAbsent = -not (
        Test-Path -LiteralPath $moveSource
    )
    DestinationExists = Test-Path `
        -LiteralPath $moveDestination `
        -PathType Leaf
    ContentWasPreserved = $preMoveHash -eq $postMoveHash
}
```

Every value should be `True`.

---

# P2.23 Avoid Unnecessary Administrator Sessions

## The Target

Understand why ordinary development work should use a normal user session.

## The Concept

An elevated PowerShell session has administrator privileges. Those privileges can expand the damage caused by a mistaken command.

The principle of **least privilege** means:

> Use only the permissions required for the current task.

The exercises in this primer need access only to your home directory. Administrator rights are unnecessary.

## The Implementation

Inspect the current Windows identity:

```powershell
$currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()

$currentPrincipal = [System.Security.Principal.WindowsPrincipal]::new(
    $currentIdentity
)

$isAdministrator = $currentPrincipal.IsInRole(
    [System.Security.Principal.WindowsBuiltInRole]::Administrator
)

[PSCustomObject]@{
    UserName = $currentIdentity.Name
    IsAdministrator = $isAdministrator
}
```

If `IsAdministrator` is `True`, do not panic or terminate an active task abruptly. For future ordinary tutorial work, open a normal terminal without choosing **Run as administrator**.

## The Verification

Confirm that the laboratory is writable without modifying a protected system location:

```powershell
$permissionTestFile = Join-Path `
    -Path $approvedRoot `
    -ChildPath "permission-test.txt"

try {
    Set-Content `
        -LiteralPath $permissionTestFile `
        -Value "Normal user write test." `
        -Encoding UTF8 `
        -ErrorAction Stop

    $writeSucceeded = Test-Path `
        -LiteralPath $permissionTestFile `
        -PathType Leaf
}
finally {
    if (Test-Path -LiteralPath $permissionTestFile) {
        Remove-Item `
            -LiteralPath $permissionTestFile `
            -ErrorAction SilentlyContinue
    }
}

$writeSucceeded
```

Expected result:

```text
True
```

---

# P2.24 Clean Up the Remaining Approved Workspace Safely

## The Target

Remove disposable resources from the approved workspace while preserving the outside-boundary file for final verification.

## The Concept

Even laboratory cleanup should use the safety process. Practicing careful deletion only for important data defeats the purpose; safe habits become reliable through repetition.

At this point, the approved workspace contains resources such as:

```text
archive/
incoming/
protected/
quarantine/
```

We will remove only selected child items—not the approved root or primer root yet.

## The Implementation

Inspect the current approved workspace:

```powershell
Get-ChildItem `
    -LiteralPath $approvedRoot `
    -Recurse `
    -Force |
    Sort-Object FullName |
    Select-Object FullName, PSIsContainer, Attributes
```

Select the exact child directories:

```powershell
$cleanupTargets = @(
    Get-Item `
        -LiteralPath "$approvedRoot\archive" `
        -Force

    Get-Item `
        -LiteralPath "$approvedRoot\incoming" `
        -Force

    Get-Item `
        -LiteralPath "$approvedRoot\protected" `
        -Force

    Get-Item `
        -LiteralPath "$approvedRoot\quarantine" `
        -Force
)
```

Validate every target:

```powershell
foreach ($target in $cleanupTargets) {
    if (-not (
        Test-PathInsideApprovedRoot `
            -LiteralPath $target.FullName `
            -ApprovedRoot $approvedRoot
    )) {
        throw "Cleanup target failed boundary validation: $($target.FullName)"
    }

    if (
        Test-TreeContainsReparsePoint `
            -LiteralPath $target.FullName
    ) {
        throw "Cleanup target contains a reparse point: $($target.FullName)"
    }
}
```

Inspect the exact selected roots:

```powershell
$cleanupTargets |
    Select-Object Name, FullName, PSIsContainer, Attributes
```

Preview each recursive deletion:

```powershell
foreach ($target in $cleanupTargets) {
    Remove-ApprovedItemStrict `
        -LiteralPath $target.FullName `
        -ApprovedRoot $approvedRoot `
        -Recurse `
        -Force `
        -WhatIf
}
```

Execute after review:

```powershell
foreach ($target in $cleanupTargets) {
    Remove-ApprovedItemStrict `
        -LiteralPath $target.FullName `
        -ApprovedRoot $approvedRoot `
        -Recurse `
        -Force `
        -Confirm:$false
}
```

## The Verification

Confirm the approved root remains but its selected children do not:

```powershell
[PSCustomObject]@{
    ApprovedRootSurvived = Test-Path `
        -LiteralPath $approvedRoot `
        -PathType Container
    ArchiveWasRemoved = -not (
        Test-Path -LiteralPath "$approvedRoot\archive"
    )
    IncomingWasRemoved = -not (
        Test-Path -LiteralPath "$approvedRoot\incoming"
    )
    ProtectedWasRemoved = -not (
        Test-Path -LiteralPath "$approvedRoot\protected"
    )
    QuarantineWasRemoved = -not (
        Test-Path -LiteralPath "$approvedRoot\quarantine"
    )
    OutsideFileSurvived = Test-Path `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -PathType Leaf
}
```

Every value should be `True`.

---

# Primer 2 Reference A: The Six-Step Safety Checklist

## 1. Locate

```powershell
Get-Location
```

Ask:

- Which directory am I in?
- Does the command use a relative path?
- Could the same relative path exist somewhere else?

## 2. Resolve

```powershell
$resolvedTarget = (
    Resolve-Path `
        -LiteralPath $target `
        -ErrorAction Stop
).Path
```

Ask:

- What is the complete target path?
- Does it exist?
- Is it the path I expected?

## 3. Inspect

```powershell
Get-Item `
    -LiteralPath $resolvedTarget `
    -Force

Get-ChildItem `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -Force
```

Ask:

- Is it a file or directory?
- Is it empty?
- Does it contain hidden items?
- Does it contain reparse points?
- How many descendants are involved?

## 4. Preview

```powershell
Remove-Item `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -WhatIf
```

Ask:

- Does the preview describe the intended target?
- Did recursion include more than expected?
- Is another operation safer, such as moving to quarantine?

## 5. Execute

```powershell
Remove-Item `
    -LiteralPath $resolvedTarget `
    -Recurse `
    -ErrorAction Stop
```

Execute only after the prior checks pass.

## 6. Verify

```powershell
Test-Path -LiteralPath $resolvedTarget
```

Also verify that unrelated items survived.

---

# Primer 2 Reference B: Mutation Command Risk Guide

| Command | Typical risk | Primary checks |
|---|---|---|
| `New-Item` | Creates in wrong location | Validate parent and destination |
| `Set-Content` | Replaces existing content | Inspect target; back up if needed |
| `Add-Content` | Duplicates or corrupts content | Inspect current content |
| `Clear-Content` | Empties a file | Back up and preview if supported |
| `Copy-Item` | Overwrites destination | Validate both paths |
| `Move-Item` | Source disappears | Validate and verify both ends |
| `Rename-Item` | Breaks references | Verify old and new names |
| `Remove-Item` | Permanent data loss | Resolve, inventory, preview, verify |
| `Set-ItemProperty` | Changes metadata/attributes | Inspect current property value |

No command should be considered safe merely because it is not named `Remove-Item`.

For example:

```powershell
Set-Content `
    -LiteralPath .\important.txt `
    -Value ""
```

can destroy the previous content without deleting the file itself.

---

# Primer 2 Reference C: Exact Paths and Wildcards

## Exact item

```powershell
Get-Item `
    -LiteralPath .\archive\report.txt
```

## Intentional wildcard selection

```powershell
Get-ChildItem `
    -LiteralPath .\archive `
    -Filter "*.tmp" `
    -File
```

## Safe wildcard deletion pattern

```powershell
$targets = @(
    Get-ChildItem `
        -LiteralPath .\archive `
        -Filter "*.tmp" `
        -File
)

$targets |
    Select-Object Name, FullName, Length

$targets |
    Remove-Item -WhatIf
```

After inspection:

```powershell
$targets |
    Remove-Item -ErrorAction Stop
```

## Dangerous broad pattern

Do not casually run:

```text
Remove-Item -Path * -Recurse -Force
```

Its meaning depends on the current location and its wildcard may select every visible child item.

---

# Primer 2 Reference D: `-WhatIf` and `-Confirm`

## Preview

```powershell
Remove-Item `
    -LiteralPath $target `
    -Recurse `
    -WhatIf
```

This should make no change.

## Interactive approval

```powershell
Remove-Item `
    -LiteralPath $target `
    -Recurse `
    -Confirm
```

This prompts the user.

## Custom-command support

```powershell
function Remove-Example {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string] $LiteralPath
    )

    if ($PSCmdlet.ShouldProcess(
        $LiteralPath,
        "Remove example item"
    )) {
        Remove-Item `
            -LiteralPath $LiteralPath `
            -ErrorAction Stop
    }
}
```

Preview it:

```powershell
Remove-Example `
    -LiteralPath .\example.txt `
    -WhatIf
```

`-WhatIf` is a planning aid. It is not:

- A backup
- An undo facility
- A permission test
- A guarantee against concurrent changes
- A substitute for validating the target

---

# Primer 2 Reference E: `-Recurse` and `-Force`

## `-Recurse`

Processes descendants:

```powershell
Remove-Item `
    -LiteralPath $directory `
    -Recurse
```

Risk:

- A single root selection expands to an entire directory tree.

Before using it:

```powershell
Get-ChildItem `
    -LiteralPath $directory `
    -Recurse `
    -Force
```

## `-Force`

Handles certain ordinary provider restrictions:

```powershell
Remove-Item `
    -LiteralPath $target `
    -Force
```

It may process hidden or read-only items, but it does not grant permissions.

## Combined usage

```powershell
Remove-Item `
    -LiteralPath $directory `
    -Recurse `
    -Force
```

This combination is powerful because it broadens scope and reduces ordinary safeguards. Always validate, inventory, and preview first.

---

# Primer 2 Reference F: Safer Alternatives to Immediate Deletion

## Move to quarantine

```powershell
Move-Item `
    -LiteralPath $candidate `
    -Destination $quarantine
```

Review later, then remove if appropriate.

## Create a backup

```powershell
Copy-Item `
    -LiteralPath $source `
    -Destination $backup `
    -Recurse
```

Verify file counts and hashes before trusting the backup.

## Use version control

For source code:

```powershell
git status
git add .
git commit -m "Save work before cleanup"
```

Do not assume Git protects ignored, untracked, or never-committed files.

## Use storage history

Cloud-sync history and filesystem snapshots may help, but they must be configured before data loss and should not replace careful operation.

---

# Primer 2 Reference G: Common Safety Mistakes

## Mistake 1: Trusting the current directory from memory

Check it:

```powershell
Get-Location
```

## Mistake 2: Using a broad wildcard directly

Risky:

```powershell
Remove-Item -Path *.csv
```

Safer:

```powershell
$targets = Get-ChildItem `
    -LiteralPath $directory `
    -Filter "*.csv" `
    -File

$targets |
    Select-Object FullName

$targets |
    Remove-Item -WhatIf
```

## Mistake 3: Assuming `-WhatIf` creates an undo point

It does not. It only previews supported operations.

## Mistake 4: Using `-Force` by habit

Do not add `-Force` until you understand which restriction requires it.

## Mistake 5: Checking only that a path exists

Also check its type:

```powershell
Test-Path `
    -LiteralPath $path `
    -PathType Leaf
```

or:

```powershell
Test-Path `
    -LiteralPath $path `
    -PathType Container
```

## Mistake 6: Validating only the source of a copy or move

The destination matters equally. An incorrect destination can overwrite data or place sensitive data in an unsafe location.

## Mistake 7: Assuming deletion uses the Recycle Bin

`Remove-Item` generally does not.

## Mistake 8: Running ordinary work as administrator

Elevated privileges increase the possible impact of mistakes.

## Mistake 9: Treating a string prefix as a complete security boundary

Reparse points, concurrent changes, and unusual filesystem behavior require additional controls.

## Mistake 10: Verifying only the target’s removal

Also verify unrelated resources survived.

---

# Primer 2 Readiness Challenge

## The Target

Complete a safe deletion workflow that:

1. Recreates a disposable nested tree.
2. Resolves the target.
3. Confirms its type.
4. Confirms it lies inside the approved root.
5. Rejects reparse points.
6. Inventories every item.
7. Previews deletion.
8. Confirms preview preservation.
9. Executes through the strict custom function.
10. Verifies the target disappeared.
11. Verifies the outside-boundary file survived.

## The Concept

The challenge tests the safety method as one complete operation:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

## The Implementation

Recreate the challenge tree:

```powershell
$challengeRoot = Join-Path `
    -Path $approvedRoot `
    -ChildPath "readiness-challenge"

$null = New-Item `
    -Path "$challengeRoot\alpha\beta" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$challengeRoot\root.txt" `
    -Value "Challenge root file." `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$challengeRoot\alpha\alpha.txt" `
    -Value "Challenge alpha file." `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$challengeRoot\alpha\beta\beta.txt" `
    -Value "Challenge beta file." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### Locate

```powershell
Set-Location -LiteralPath $approvedRoot

$currentLocationIsApproved = (
    (Get-Location).Path -eq
    $approvedRoot
)
```

### Resolve

```powershell
$resolvedChallengeRoot = (
    Resolve-Path `
        -LiteralPath $challengeRoot `
        -ErrorAction Stop
).Path
```

### Validate

```powershell
$challengeIsDirectory = Test-Path `
    -LiteralPath $resolvedChallengeRoot `
    -PathType Container

$challengeIsInsideBoundary = Test-PathInsideApprovedRoot `
    -LiteralPath $resolvedChallengeRoot `
    -ApprovedRoot $approvedRoot

$challengeContainsReparsePoint = Test-TreeContainsReparsePoint `
    -LiteralPath $resolvedChallengeRoot

if (-not $currentLocationIsApproved) {
    throw "The challenge is running from an unexpected location."
}

if (-not $challengeIsDirectory) {
    throw "The challenge target is not a directory."
}

if (-not $challengeIsInsideBoundary) {
    throw "The challenge target is outside the approved root."
}

if ($challengeContainsReparsePoint) {
    throw "The challenge target contains a reparse point."
}
```

### Inspect

```powershell
$challengeInventory = @(
    Get-Item `
        -LiteralPath $resolvedChallengeRoot `
        -Force

    Get-ChildItem `
        -LiteralPath $resolvedChallengeRoot `
        -Recurse `
        -Force
)

$challengeInventory |
    Sort-Object FullName |
    Select-Object FullName, PSIsContainer, Length, Attributes
```

Require the expected inventory:

```powershell
if ($challengeInventory.Count -ne 6) {
    throw (
        "Expected six challenge items, found " +
        "$($challengeInventory.Count)."
    )
}
```

The six items are:

1. `readiness-challenge`
2. `alpha`
3. `beta`
4. `root.txt`
5. `alpha.txt`
6. `beta.txt`

### Preview

```powershell
Remove-ApprovedItemStrict `
    -LiteralPath $resolvedChallengeRoot `
    -ApprovedRoot $approvedRoot `
    -Recurse `
    -WhatIf
```

Record preview preservation:

```powershell
$previewPreservedChallenge = Test-Path `
    -LiteralPath $resolvedChallengeRoot `
    -PathType Container

$previewPreservedNestedFile = Test-Path `
    -LiteralPath "$resolvedChallengeRoot\alpha\beta\beta.txt" `
    -PathType Leaf
```

### Execute

```powershell
Remove-ApprovedItemStrict `
    -LiteralPath $resolvedChallengeRoot `
    -ApprovedRoot $approvedRoot `
    -Recurse `
    -Confirm:$false
```

### Verify

```powershell
$readinessResults = [PSCustomObject]@{
    CurrentLocationWasApproved = $currentLocationIsApproved
    TargetWasDirectory = $challengeIsDirectory
    TargetWasInsideBoundary = $challengeIsInsideBoundary
    NoReparsePointsFound = -not $challengeContainsReparsePoint
    InventoryCountWasSix = $challengeInventory.Count -eq 6
    PreviewPreservedRoot = $previewPreservedChallenge
    PreviewPreservedNestedFile = $previewPreservedNestedFile
    RealOperationRemovedTarget = -not (
        Test-Path -LiteralPath $resolvedChallengeRoot
    )
    ApprovedRootSurvived = Test-Path `
        -LiteralPath $approvedRoot `
        -PathType Container
    OutsideFileSurvived = Test-Path `
        -LiteralPath "$outsideRoot\must-survive.txt" `
        -PathType Leaf
}

$readinessResults |
    Format-List
```

## The Verification

Find failed properties:

```powershell
$failedReadinessChecks = @(
    $readinessResults.PSObject.Properties |
        Where-Object {
            $_.Value -ne $true
        }
)

if ($failedReadinessChecks.Count -eq 0) {
    Write-Host "Primer 2 readiness check passed." `
        -ForegroundColor Green
}
else {
    $failedReadinessChecks |
        Select-Object Name, Value |
        Format-Table -AutoSize

    throw "Primer 2 readiness check failed."
}
```

Expected message:

```text
Primer 2 readiness check passed.
```

---

# Primer 2 Optional Final Laboratory Cleanup

## The Target

Remove the complete primer laboratory after confirming that no further exercises require it.

## The Concept

The strict safety function intentionally refuses to remove the approved root itself. Complete laboratory cleanup is a separate operation performed from its trusted parent.

This separation prevents a child-item cleanup function from unexpectedly destroying its entire safety boundary.

## The Implementation

First return home so the current location is not inside the tree being removed:

```powershell
Set-Location -LiteralPath $HOME
```

Reconstruct the exact expected laboratory path:

```powershell
$cleanupPrimerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "powershell-safety-primer"

$expectedCleanupRoot = Join-Path `
    -Path $HOME `
    -ChildPath "powershell-safety-primer"
```

Require an exact path match:

```powershell
if ($cleanupPrimerRoot -ne $expectedCleanupRoot) {
    throw "Unexpected cleanup path: $cleanupPrimerRoot"
}
```

Require the expected child structure:

```powershell
$expectedApprovedRoot = Join-Path `
    -Path $cleanupPrimerRoot `
    -ChildPath "approved-workspace"

$expectedOutsideRoot = Join-Path `
    -Path $cleanupPrimerRoot `
    -ChildPath "outside-boundary"

if (-not (
    Test-Path `
        -LiteralPath $expectedApprovedRoot `
        -PathType Container
)) {
    throw "Expected approved workspace is missing."
}

if (-not (
    Test-Path `
        -LiteralPath "$expectedOutsideRoot\must-survive.txt" `
        -PathType Leaf
)) {
    throw "Expected boundary-verification file is missing."
}
```

Reject reparse points:

```powershell
if (
    Test-TreeContainsReparsePoint `
        -LiteralPath $cleanupPrimerRoot
) {
    throw "The primer laboratory contains a reparse point."
}
```

Build the final cleanup inventory:

```powershell
$finalCleanupInventory = @(
    Get-Item `
        -LiteralPath $cleanupPrimerRoot `
        -Force

    Get-ChildItem `
        -LiteralPath $cleanupPrimerRoot `
        -Recurse `
        -Force
)

$finalCleanupInventory |
    Sort-Object FullName |
    Select-Object FullName, PSIsContainer, Attributes
```

Preview:

```powershell
Remove-Item `
    -LiteralPath $cleanupPrimerRoot `
    -Recurse `
    -Force `
    -WhatIf
```

If you want to retain the laboratory for review, stop here.

To remove it:

```powershell
Remove-Item `
    -LiteralPath $cleanupPrimerRoot `
    -Recurse `
    -Force `
    -Confirm
```

Review the prompt and enter `Y` only if the exact displayed target is the tutorial laboratory.

## The Verification

If you performed the final cleanup:

```powershell
Test-Path -LiteralPath $cleanupPrimerRoot
```

Expected result:

```text
False
```

If you chose to retain it:

```powershell
Test-Path `
    -LiteralPath $cleanupPrimerRoot `
    -PathType Container
```

Expected result:

```text
True
```

---

# Primer 2 Key Takeaways

PowerShell filesystem safety is a process, not one parameter:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

## Locate

Relative paths depend on the current location:

```powershell
Get-Location
```

## Resolve

Turn assumptions into complete existing paths:

```powershell
Resolve-Path -LiteralPath $target
```

## Inspect

Check the target type and descendants:

```powershell
Test-Path `
    -LiteralPath $target `
    -PathType Container

Get-ChildItem `
    -LiteralPath $target `
    -Recurse `
    -Force
```

## Preview

Use standard safety behavior where supported:

```powershell
Remove-Item `
    -LiteralPath $target `
    -Recurse `
    -WhatIf
```

## Execute

Use exact validated paths:

```powershell
Remove-Item `
    -LiteralPath $target `
    -Recurse `
    -ErrorAction Stop
```

## Verify

Confirm the intended result and the survival of unrelated data:

```powershell
Test-Path -LiteralPath $target
Test-Path -LiteralPath $unrelatedItem
```

Remember:

- Prefer `-LiteralPath` for exact mutations.
- Materialize wildcard matches before deleting them.
- `-Recurse` expands an operation through a tree.
- `-Force` does not grant permissions.
- `-WhatIf` is a preview, not a backup or undo mechanism.
- `-Confirm` requests human approval.
- `Remove-Item` generally bypasses the Recycle Bin.
- Avoid unnecessary administrator sessions.
- Reject the approved root itself in child-item deletion tools.
- Inspect for reparse points before recursively changing untrusted trees.
- Verify sources and destinations after copy or move operations.
- Use quarantine when immediate permanent deletion is unnecessary.
- Path checks reduce accidental risk but do not create a complete security sandbox.


