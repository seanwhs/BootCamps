# Part 2: File and Directory Management Operations

Part 1 taught you how to navigate and inspect the filesystem. Part 2 turns those read-only skills into controlled changes.

You will learn how to:

- Create individual and nested directories
- Create empty and populated files
- Copy files and directory trees
- Rename files and directories
- Move resources between directories
- Inspect and modify file attributes
- Preview destructive operations with `-WhatIf`
- Delete files safely
- Delete non-empty directories with `-Recurse`
- Handle hidden and read-only resources with `-Force`
- Build a reusable cleanup script with native `-WhatIf` support

The safety rule for this part is:

> Validate the location, preview the operation, perform the change, and verify the result.

---

## 2.1 Prepare an Isolated File-Management Laboratory

### The Target

Create a disposable directory for Part 2 at:

```text
$HOME\cli-developer-environment-series\filesystem-lab\file-operations-lab
```

The initial structure will be:

```text
file-operations-lab/
├── archive/
├── incoming/
├── output/
├── source/
└── staging/
```

### The Concept

File-management commands can rename, overwrite, or delete resources quickly. We therefore need an isolated workbench.

This is like practicing carpentry on spare wood instead of cutting into finished furniture.

The setup deliberately refuses to reset any path outside the expected tutorial directory.

### The Implementation

Run the complete setup block:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$filesystemLab = Join-Path `
    -Path $seriesRoot `
    -ChildPath "filesystem-lab"

$operationsLab = Join-Path `
    -Path $filesystemLab `
    -ChildPath "file-operations-lab"

$expectedOperationsLab = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series\filesystem-lab\file-operations-lab"

if ($operationsLab -ne $expectedOperationsLab) {
    throw "Safety check failed. Refusing to modify an unexpected path: $operationsLab"
}

if (-not (Test-Path -LiteralPath $filesystemLab -PathType Container)) {
    throw "The Part 1 filesystem laboratory is missing: $filesystemLab"
}

if (Test-Path -LiteralPath $operationsLab) {
    Remove-Item `
        -LiteralPath $operationsLab `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

$null = New-Item `
    -Path $operationsLab `
    -ItemType Directory `
    -ErrorAction Stop

$initialDirectories = @(
    "archive"
    "incoming"
    "output"
    "source"
    "staging"
)

foreach ($directoryName in $initialDirectories) {
    $directoryPath = Join-Path `
        -Path $operationsLab `
        -ChildPath $directoryName

    $null = New-Item `
        -Path $directoryPath `
        -ItemType Directory `
        -ErrorAction Stop
}

Set-Location -LiteralPath $operationsLab

Write-Host "Part 2 laboratory is ready." -ForegroundColor Green
Write-Host "Location: $operationsLab"
```

### The Verification

Confirm the current location:

```powershell
(Get-Location).Path -eq $operationsLab
```

Expected result:

```text
True
```

List the initial directories:

```powershell
Get-ChildItem `
    -LiteralPath $operationsLab `
    -Directory |
    Sort-Object Name |
    Select-Object -ExpandProperty Name
```

Expected output:

```text
archive
incoming
output
source
staging
```

Confirm that exactly five directories exist:

```powershell
(
    Get-ChildItem `
        -LiteralPath $operationsLab `
        -Directory
).Count
```

Expected result:

```text
5
```

---

## 2.2 Create a Single Directory with `New-Item`

### The Target

Create this directory:

```text
file-operations-lab\reports
```

### The Concept

A directory is a container for files and other directories.

PowerShell creates filesystem resources with `New-Item`. The `-ItemType` parameter tells PowerShell what kind of resource to create:

```text
Directory
File
```

This is similar to ordering an empty storage container: you specify both its location and its type.

### The Implementation

Create the `reports` directory:

```powershell
$reportsDirectory = Join-Path `
    -Path $operationsLab `
    -ChildPath "reports"

$null = New-Item `
    -Path $reportsDirectory `
    -ItemType Directory `
    -ErrorAction Stop
```

Inspect the new directory:

```powershell
Get-Item -LiteralPath $reportsDirectory |
    Select-Object Name, FullName, Attributes, CreationTime
```

The familiar command:

```powershell
mkdir reports
```

usually resolves to functionality that creates a directory, but explicit `New-Item` syntax is clearer in scripts:

```powershell
New-Item -Path .\reports -ItemType Directory
```

### The Verification

Confirm that the path exists and is a directory:

```powershell
Test-Path `
    -LiteralPath $reportsDirectory `
    -PathType Container
```

Expected result:

```text
True
```

Confirm that it is not a file:

```powershell
Test-Path `
    -LiteralPath $reportsDirectory `
    -PathType Leaf
```

Expected result:

```text
False
```

---

## 2.3 Create Nested Directory Structures

### The Target

Create these nested directories:

```text
source/
├── assets/
│   ├── images/
│   └── styles/
├── config/
└── data/
    ├── processed/
    └── raw/
```

### The Concept

A nested directory has one or more parent directories.

Some tools require every parent to exist before creating a child. PowerShell’s filesystem provider can create missing parent directories when `New-Item` receives a nested directory path.

For several branches, an array and loop make the operation consistent and repeatable.

### The Implementation

Define the required relative paths:

```powershell
$nestedDirectoryNames = @(
    "source\assets\images"
    "source\assets\styles"
    "source\config"
    "source\data\processed"
    "source\data\raw"
)
```

Create each nested path:

```powershell
foreach ($relativeDirectory in $nestedDirectoryNames) {
    $fullDirectoryPath = Join-Path `
        -Path $operationsLab `
        -ChildPath $relativeDirectory

    if (-not (
        Test-Path `
            -LiteralPath $fullDirectoryPath `
            -PathType Container
    )) {
        $null = New-Item `
            -Path $fullDirectoryPath `
            -ItemType Directory `
            -Force `
            -ErrorAction Stop
    }
}
```

`-Force` allows `New-Item` to construct missing parent directories and tolerate already existing directory paths. It does not override filesystem access-control permissions.

Display the resulting directory tree:

```powershell
Get-ChildItem `
    -LiteralPath "$operationsLab\source" `
    -Directory `
    -Recurse |
    Sort-Object FullName |
    Select-Object -ExpandProperty FullName
```

### The Verification

Check every required directory:

```powershell
$nestedDirectoryChecks = foreach ($relativeDirectory in $nestedDirectoryNames) {
    $fullDirectoryPath = Join-Path `
        -Path $operationsLab `
        -ChildPath $relativeDirectory

    [PSCustomObject]@{
        Directory = $relativeDirectory
        Exists = Test-Path `
            -LiteralPath $fullDirectoryPath `
            -PathType Container
    }
}

$nestedDirectoryChecks |
    Format-Table -AutoSize
```

Confirm that none failed:

```powershell
(
    $nestedDirectoryChecks |
        Where-Object { -not $_.Exists }
).Count -eq 0
```

Expected result:

```text
True
```

---

## 2.4 Create Empty Files

### The Target

Create these empty files:

```text
source/
├── README.md
├── app.js
└── config/
    └── settings.json
```

### The Concept

An empty file is like a newly purchased notebook: the container exists, but no content has been written into it.

Use:

```powershell
New-Item -ItemType File
```

Without `-Force`, `New-Item` reports an error if the file already exists. That default behavior helps prevent accidental replacement.

### The Implementation

Define the empty files:

```powershell
$emptyFileNames = @(
    "source\README.md"
    "source\app.js"
    "source\config\settings.json"
)
```

Create them:

```powershell
foreach ($relativeFile in $emptyFileNames) {
    $fullFilePath = Join-Path `
        -Path $operationsLab `
        -ChildPath $relativeFile

    if (Test-Path -LiteralPath $fullFilePath) {
        throw "Refusing to replace an existing item: $fullFilePath"
    }

    $null = New-Item `
        -Path $fullFilePath `
        -ItemType File `
        -ErrorAction Stop
}
```

Inspect their sizes:

```powershell
Get-ChildItem `
    -LiteralPath "$operationsLab\source" `
    -File `
    -Recurse |
    Sort-Object FullName |
    Select-Object Name, Length, FullName
```

### The Verification

Confirm that all three paths are files:

```powershell
$emptyFileChecks = foreach ($relativeFile in $emptyFileNames) {
    $fullFilePath = Join-Path `
        -Path $operationsLab `
        -ChildPath $relativeFile

    $item = Get-Item `
        -LiteralPath $fullFilePath `
        -ErrorAction Stop

    [PSCustomObject]@{
        File = $relativeFile
        Exists = Test-Path `
            -LiteralPath $fullFilePath `
            -PathType Leaf
        IsEmpty = $item.Length -eq 0
    }
}

$emptyFileChecks |
    Format-Table -AutoSize
```

Every `Exists` and `IsEmpty` value should be `True`.

---

## 2.5 Create Files with Content

### The Target

Populate the empty files and create sample data files.

The resulting source tree will include:

```text
source/
├── README.md
├── app.js
├── config/
│   └── settings.json
└── data/
    └── raw/
        ├── customers.csv
        └── orders.csv
```

### The Concept

`New-Item` creates the container. `Set-Content` writes or replaces its content.

Think of `Set-Content` as replacing every page in a notebook with a new prepared document. By contrast, `Add-Content` adds new material to the end.

For structured or multiline content, a PowerShell **here-string** is convenient. A here-string preserves a block of text between its opening and closing markers.

### The Implementation

Populate `README.md`:

```powershell
$readmePath = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\README.md"

$readmeContent = @'
# File Operations Laboratory

This directory contains disposable files used to practice PowerShell.

## Safety

All destructive exercises must remain inside file-operations-lab.
'@

Set-Content `
    -LiteralPath $readmePath `
    -Value $readmeContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Populate `app.js`:

```powershell
$appPath = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\app.js"

$appContent = @'
"use strict";

const applicationName = "File Operations Laboratory";

console.log(`${applicationName} is ready.`);
'@

Set-Content `
    -LiteralPath $appPath `
    -Value $appContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Create a PowerShell object and convert it to valid JSON:

```powershell
$settingsPath = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\config\settings.json"

$settings = [ordered]@{
    applicationName = "File Operations Laboratory"
    environment = "development"
    logging = [ordered]@{
        level = "debug"
        destination = "console"
    }
}

$settings |
    ConvertTo-Json -Depth 4 |
    Set-Content `
        -LiteralPath $settingsPath `
        -Encoding UTF8 `
        -ErrorAction Stop
```

Create `customers.csv`:

```powershell
$customersPath = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\data\raw\customers.csv"

$customersContent = @'
id,name,status
1,Ada,active
2,Grace,active
3,Linus,inactive
'@

Set-Content `
    -LiteralPath $customersPath `
    -Value $customersContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Create `orders.csv`:

```powershell
$ordersPath = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\data\raw\orders.csv"

$ordersContent = @'
orderId,customerId,total
1001,1,49.95
1002,2,125.00
1003,1,15.50
'@

Set-Content `
    -LiteralPath $ordersPath `
    -Value $ordersContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Append one line to the README without replacing its existing content:

```powershell
Add-Content `
    -LiteralPath $readmePath `
    -Value "`nGenerated for Part 2 of the PowerShell tutorial." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Read the README:

```powershell
Get-Content -LiteralPath $readmePath
```

Parse the JSON file:

```powershell
$parsedSettings = Get-Content `
    -LiteralPath $settingsPath `
    -Raw |
    ConvertFrom-Json

$parsedSettings |
    Format-List
```

Verify selected JSON properties:

```powershell
[PSCustomObject]@{
    ApplicationNameCorrect = (
        $parsedSettings.applicationName -eq
        "File Operations Laboratory"
    )
    EnvironmentCorrect = (
        $parsedSettings.environment -eq
        "development"
    )
    LogLevelCorrect = (
        $parsedSettings.logging.level -eq
        "debug"
    )
}
```

Every value should be `True`.

Import the customer CSV as structured objects:

```powershell
$customers = Import-Csv -LiteralPath $customersPath

$customers |
    Format-Table -AutoSize
```

Confirm the record count:

```powershell
$customers.Count
```

Expected result:

```text
3
```

---

## 2.6 Copy a Single File

### The Target

Copy:

```text
source\config\settings.json
```

to:

```text
staging\settings.json
```

### The Concept

Copying creates another item while preserving the original.

It is like photocopying a document: the original stays in its cabinet, and a separate document appears at the destination.

The native command is:

```powershell
Copy-Item
```

Common aliases include:

```powershell
cp
copy
```

Native command names remain preferable in scripts.

### The Implementation

Define the source and destination:

```powershell
$settingsSource = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\config\settings.json"

$settingsCopy = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\settings.json"
```

Refuse to overwrite an unexpected existing destination:

```powershell
if (Test-Path -LiteralPath $settingsCopy) {
    throw "The copy destination already exists: $settingsCopy"
}
```

Copy the file:

```powershell
Copy-Item `
    -LiteralPath $settingsSource `
    -Destination $settingsCopy `
    -ErrorAction Stop
```

### The Verification

Confirm that both files exist:

```powershell
[PSCustomObject]@{
    SourceExists = Test-Path `
        -LiteralPath $settingsSource `
        -PathType Leaf
    CopyExists = Test-Path `
        -LiteralPath $settingsCopy `
        -PathType Leaf
}
```

Both values should be `True`.

Compare cryptographic hashes:

```powershell
$sourceHash = (
    Get-FileHash `
        -LiteralPath $settingsSource `
        -Algorithm SHA256
).Hash

$copyHash = (
    Get-FileHash `
        -LiteralPath $settingsCopy `
        -Algorithm SHA256
).Hash

$sourceHash -eq $copyHash
```

Expected result:

```text
True
```

A hash is a content fingerprint. Equal SHA-256 hashes provide strong evidence that the copied bytes match the original.

---

## 2.7 Copy and Rename in One Operation

### The Target

Copy:

```text
source\README.md
```

to:

```text
staging\SOURCE-NOTES.md
```

### The Concept

A copy destination may include a new filename.

This is like photocopying a document and placing the copy into a folder under a different label. The source keeps its original name.

### The Implementation

Define both paths:

```powershell
$readmeSource = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\README.md"

$renamedCopy = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\SOURCE-NOTES.md"
```

Copy with the new name:

```powershell
Copy-Item `
    -LiteralPath $readmeSource `
    -Destination $renamedCopy `
    -ErrorAction Stop
```

### The Verification

Confirm that the source and renamed copy exist:

```powershell
Get-Item `
    -LiteralPath $readmeSource, $renamedCopy |
    Select-Object Name, Length, FullName
```

Compare their contents:

```powershell
$sourceReadmeHash = (
    Get-FileHash -LiteralPath $readmeSource -Algorithm SHA256
).Hash

$renamedCopyHash = (
    Get-FileHash -LiteralPath $renamedCopy -Algorithm SHA256
).Hash

$sourceReadmeHash -eq $renamedCopyHash
```

Expected result:

```text
True
```

---

## 2.8 Copy a Complete Directory Tree

### The Target

Copy:

```text
source\data
```

to:

```text
staging\data-snapshot
```

including all nested files and directories.

### The Concept

A directory is a container. Copying only the container does not always imply copying everything inside it.

`-Recurse` tells PowerShell to descend into the source and duplicate its complete tree.

### The Implementation

Define the paths:

```powershell
$dataSource = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\data"

$dataSnapshot = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\data-snapshot"
```

Copy the directory and all descendants:

```powershell
Copy-Item `
    -LiteralPath $dataSource `
    -Destination $dataSnapshot `
    -Recurse `
    -ErrorAction Stop
```

Inspect the copied tree:

```powershell
Get-ChildItem `
    -LiteralPath $dataSnapshot `
    -Recurse |
    Sort-Object FullName |
    Select-Object FullName
```

### The Verification

Confirm that the expected files were copied:

```powershell
$snapshotCustomers = Join-Path `
    -Path $dataSnapshot `
    -ChildPath "raw\customers.csv"

$snapshotOrders = Join-Path `
    -Path $dataSnapshot `
    -ChildPath "raw\orders.csv"

[PSCustomObject]@{
    SnapshotDirectoryExists = Test-Path `
        -LiteralPath $dataSnapshot `
        -PathType Container
    CustomersCopied = Test-Path `
        -LiteralPath $snapshotCustomers `
        -PathType Leaf
    OrdersCopied = Test-Path `
        -LiteralPath $snapshotOrders `
        -PathType Leaf
}
```

Every value should be `True`.

Compare the source and copied file counts:

```powershell
$sourceDataFileCount = (
    Get-ChildItem `
        -LiteralPath $dataSource `
        -File `
        -Recurse
).Count

$snapshotFileCount = (
    Get-ChildItem `
        -LiteralPath $dataSnapshot `
        -File `
        -Recurse
).Count

[PSCustomObject]@{
    SourceCount = $sourceDataFileCount
    SnapshotCount = $snapshotFileCount
    CountsMatch = $sourceDataFileCount -eq $snapshotFileCount
}
```

Expected counts:

```text
SourceCount   : 2
SnapshotCount : 2
CountsMatch   : True
```

---

## 2.9 Copy Multiple Matching Files

### The Target

Copy every CSV file from:

```text
source\data\raw
```

to:

```text
incoming
```

### The Concept

When a source contains a wildcard, PowerShell can select several items in one operation.

The pattern:

```text
*.csv
```

means “every filename ending in `.csv`.”

Use `-Path`, not `-LiteralPath`, when wildcard interpretation is intentional.

### The Implementation

Define the wildcard source and destination directory:

```powershell
$csvPattern = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\data\raw\*.csv"

$incomingDirectory = Join-Path `
    -Path $operationsLab `
    -ChildPath "incoming"
```

Preview the selected source files:

```powershell
Get-ChildItem `
    -Path $csvPattern `
    -File |
    Select-Object Name, FullName
```

Copy the matching files:

```powershell
Copy-Item `
    -Path $csvPattern `
    -Destination $incomingDirectory `
    -ErrorAction Stop
```

### The Verification

List the destination:

```powershell
Get-ChildItem `
    -LiteralPath $incomingDirectory `
    -File |
    Sort-Object Name |
    Select-Object Name, Length
```

Expected files:

```text
customers.csv
orders.csv
```

Confirm the count:

```powershell
(
    Get-ChildItem `
        -LiteralPath $incomingDirectory `
        -Filter "*.csv" `
        -File
).Count
```

Expected result:

```text
2
```

---

## 2.10 Rename a File with `Rename-Item`

### The Target

Rename:

```text
staging\settings.json
```

to:

```text
staging\settings.staged.json
```

### The Concept

Renaming changes an item’s label without changing its parent directory.

It is like replacing the label on a folder while leaving the folder in the same cabinet.

`Rename-Item` is the clearest command when only the name changes. `Move-Item` can also rename an item, but its broader purpose is relocation.

### The Implementation

Define the old and new paths:

```powershell
$oldSettingsName = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\settings.json"

$newSettingsName = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\settings.staged.json"
```

Rename the file:

```powershell
Rename-Item `
    -LiteralPath $oldSettingsName `
    -NewName "settings.staged.json" `
    -ErrorAction Stop
```

`-NewName` accepts the new name, not a destination directory path.

### The Verification

Confirm that the old path is gone and the new path exists:

```powershell
[PSCustomObject]@{
    OldPathExists = Test-Path `
        -LiteralPath $oldSettingsName
    NewPathExists = Test-Path `
        -LiteralPath $newSettingsName `
        -PathType Leaf
}
```

Expected result:

```text
OldPathExists : False
NewPathExists : True
```

---

## 2.11 Rename a Directory

### The Target

Rename:

```text
staging\data-snapshot
```

to:

```text
staging\data-backup
```

### The Concept

Directories can be renamed using the same command as files. Their children remain inside the renamed container.

Imagine changing the label on a storage box. The documents inside do not need to be individually renamed or recreated.

### The Implementation

Define the old and new paths:

```powershell
$oldSnapshotDirectory = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\data-snapshot"

$newBackupDirectory = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\data-backup"
```

Rename the directory:

```powershell
Rename-Item `
    -LiteralPath $oldSnapshotDirectory `
    -NewName "data-backup" `
    -ErrorAction Stop
```

### The Verification

Confirm the directory was renamed and its files remain:

```powershell
[PSCustomObject]@{
    OldDirectoryExists = Test-Path `
        -LiteralPath $oldSnapshotDirectory
    NewDirectoryExists = Test-Path `
        -LiteralPath $newBackupDirectory `
        -PathType Container
    CustomerFileStillExists = Test-Path `
        -LiteralPath "$newBackupDirectory\raw\customers.csv" `
        -PathType Leaf
    OrderFileStillExists = Test-Path `
        -LiteralPath "$newBackupDirectory\raw\orders.csv" `
        -PathType Leaf
}
```

Expected values:

```text
OldDirectoryExists    : False
NewDirectoryExists    : True
CustomerFileStillExists : True
OrderFileStillExists    : True
```

---

## 2.12 Move a File with `Move-Item`

### The Target

Move:

```text
incoming\customers.csv
```

to:

```text
archive\customers.csv
```

### The Concept

Moving relocates an existing item. Unlike copying, the original path no longer contains the item afterward.

It is the difference between photocopying a document and physically transferring the document to another cabinet.

The native command is:

```powershell
Move-Item
```

A common alias is:

```powershell
mv
```

### The Implementation

Define the source and destination:

```powershell
$customerIncoming = Join-Path `
    -Path $operationsLab `
    -ChildPath "incoming\customers.csv"

$customerArchived = Join-Path `
    -Path $operationsLab `
    -ChildPath "archive\customers.csv"
```

Confirm that the destination does not already exist:

```powershell
if (Test-Path -LiteralPath $customerArchived) {
    throw "Refusing to overwrite the existing destination: $customerArchived"
}
```

Move the file:

```powershell
Move-Item `
    -LiteralPath $customerIncoming `
    -Destination $customerArchived `
    -ErrorAction Stop
```

### The Verification

Confirm the source disappeared and the destination appeared:

```powershell
[PSCustomObject]@{
    SourceStillExists = Test-Path `
        -LiteralPath $customerIncoming
    DestinationExists = Test-Path `
        -LiteralPath $customerArchived `
        -PathType Leaf
}
```

Expected result:

```text
SourceStillExists : False
DestinationExists : True
```

Confirm that `orders.csv` remains in `incoming`:

```powershell
Test-Path `
    -LiteralPath "$incomingDirectory\orders.csv" `
    -PathType Leaf
```

Expected result:

```text
True
```

---

## 2.13 Move and Rename in One Operation

### The Target

Move:

```text
incoming\orders.csv
```

to:

```text
archive\orders-processed.csv
```

### The Concept

A destination can provide both a new parent directory and a new filename.

This is like transferring a document to another cabinet and replacing its label during the transfer.

### The Implementation

Define the paths:

```powershell
$orderIncoming = Join-Path `
    -Path $operationsLab `
    -ChildPath "incoming\orders.csv"

$orderArchived = Join-Path `
    -Path $operationsLab `
    -ChildPath "archive\orders-processed.csv"
```

Move and rename the file:

```powershell
Move-Item `
    -LiteralPath $orderIncoming `
    -Destination $orderArchived `
    -ErrorAction Stop
```

### The Verification

Confirm the final state:

```powershell
[PSCustomObject]@{
    OldPathExists = Test-Path `
        -LiteralPath $orderIncoming
    NewPathExists = Test-Path `
        -LiteralPath $orderArchived `
        -PathType Leaf
    IncomingIsEmpty = (
        Get-ChildItem `
            -LiteralPath $incomingDirectory `
            -Force
    ).Count -eq 0
}
```

Every result should indicate:

```text
OldPathExists   : False
NewPathExists   : True
IncomingIsEmpty : True
```

---

## 2.14 Understand Overwrite Protection and `-Force`

### The Target

Safely replace a disposable destination copy while preserving the source.

### The Concept

Many file operations protect existing destinations by default. This is useful because silent replacement can destroy data.

`-Force` asks PowerShell to proceed through certain ordinary restrictions, such as replacing an existing writable destination. It does not grant permission denied by Windows access-control rules.

Use `-Force` only after deliberately verifying both paths.

### The Implementation

Create an intentionally outdated destination:

```powershell
$replaceSource = Join-Path `
    -Path $operationsLab `
    -ChildPath "source\config\settings.json"

$replaceDestination = Join-Path `
    -Path $operationsLab `
    -ChildPath "output\settings.json"

Set-Content `
    -LiteralPath $replaceDestination `
    -Value '{ "outdated": true }' `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Inspect the destination before replacement:

```powershell
Get-Content -LiteralPath $replaceDestination
```

Confirm that the source and destination are both inside the laboratory:

```powershell
$operationsLabPrefix = $operationsLab.TrimEnd("\") + "\"

if (-not $replaceSource.StartsWith(
    $operationsLabPrefix,
    [System.StringComparison]::OrdinalIgnoreCase
)) {
    throw "Source is outside the laboratory: $replaceSource"
}

if (-not $replaceDestination.StartsWith(
    $operationsLabPrefix,
    [System.StringComparison]::OrdinalIgnoreCase
)) {
    throw "Destination is outside the laboratory: $replaceDestination"
}
```

Replace the disposable destination:

```powershell
Copy-Item `
    -LiteralPath $replaceSource `
    -Destination $replaceDestination `
    -Force `
    -ErrorAction Stop
```

### The Verification

Parse the replaced destination:

```powershell
$replacedSettings = Get-Content `
    -LiteralPath $replaceDestination `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    OutdatedPropertyRemoved = $null -eq $replacedSettings.outdated
    ApplicationNameCorrect = (
        $replacedSettings.applicationName -eq
        "File Operations Laboratory"
    )
    EnvironmentCorrect = (
        $replacedSettings.environment -eq
        "development"
    )
}
```

Every value should be `True`.

Compare file hashes:

```powershell
(
    Get-FileHash -LiteralPath $replaceSource -Algorithm SHA256
).Hash -eq (
    Get-FileHash -LiteralPath $replaceDestination -Algorithm SHA256
).Hash
```

Expected result:

```text
True
```

---

## 2.15 Preview Changes with `-WhatIf`

### The Target

Preview a copy, move, rename, and deletion without changing the filesystem.

### The Concept

`-WhatIf` asks:

> What would this command do if I allowed it to run?

It is a rehearsal. Actors walk through a scene without opening night’s consequences; PowerShell reports the intended operation without performing it.

Many commands that change state support `-WhatIf`, including:

- `New-Item`
- `Copy-Item`
- `Move-Item`
- `Rename-Item`
- `Remove-Item`
- `Set-ItemProperty`

### The Implementation

Create a disposable preview file:

```powershell
$previewFile = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\preview.txt"

Set-Content `
    -LiteralPath $previewFile `
    -Value "This file is used to demonstrate -WhatIf." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview copying it:

```powershell
$previewCopy = Join-Path `
    -Path $operationsLab `
    -ChildPath "output\preview-copy.txt"

Copy-Item `
    -LiteralPath $previewFile `
    -Destination $previewCopy `
    -WhatIf
```

Preview moving it:

```powershell
$previewMove = Join-Path `
    -Path $operationsLab `
    -ChildPath "archive\preview.txt"

Move-Item `
    -LiteralPath $previewFile `
    -Destination $previewMove `
    -WhatIf
```

Preview renaming it:

```powershell
Rename-Item `
    -LiteralPath $previewFile `
    -NewName "renamed-preview.txt" `
    -WhatIf
```

Preview deleting it:

```powershell
Remove-Item `
    -LiteralPath $previewFile `
    -WhatIf
```

The terminal should display messages beginning with text similar to:

```text
What if:
```

### The Verification

Confirm that none of the previewed changes happened:

```powershell
[PSCustomObject]@{
    OriginalStillExists = Test-Path `
        -LiteralPath $previewFile `
        -PathType Leaf
    CopyWasNotCreated = -not (
        Test-Path -LiteralPath $previewCopy
    )
    MoveDidNotOccur = -not (
        Test-Path -LiteralPath $previewMove
    )
    RenameDidNotOccur = -not (
        Test-Path `
            -LiteralPath "$operationsLab\staging\renamed-preview.txt"
    )
}
```

Every value should be `True`.

---

## 2.16 Delete a Single File Safely

### The Target

Delete:

```text
staging\preview.txt
```

after previewing the operation.

### The Concept

`Remove-Item` permanently removes filesystem resources. It does not normally place them in the Windows Recycle Bin.

That makes command-line deletion more like shredding a document than moving it to a wastebasket.

Always verify the exact target before deleting it.

### The Implementation

Define and validate the target:

```powershell
$deleteTarget = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\preview.txt"

if (-not (
    Test-Path `
        -LiteralPath $deleteTarget `
        -PathType Leaf
)) {
    throw "The expected deletion target does not exist: $deleteTarget"
}
```

Display exactly what will be deleted:

```powershell
Get-Item -LiteralPath $deleteTarget |
    Select-Object Name, FullName, Length, Attributes
```

Preview the deletion:

```powershell
Remove-Item `
    -LiteralPath $deleteTarget `
    -WhatIf
```

Confirm that the preview preserved the file:

```powershell
Test-Path -LiteralPath $deleteTarget
```

Expected result:

```text
True
```

Perform the deletion:

```powershell
Remove-Item `
    -LiteralPath $deleteTarget `
    -ErrorAction Stop
```

### The Verification

Confirm that the file no longer exists:

```powershell
Test-Path -LiteralPath $deleteTarget
```

Expected result:

```text
False
```

---

## 2.17 Delete Multiple Files Selected by a Pattern

### The Target

Create disposable `.tmp` files and then delete only those files.

### The Concept

Wildcard deletion is powerful because one command can match many resources. That same power makes it dangerous.

The safe workflow is:

1. Retrieve the matches.
2. Inspect the exact objects.
3. Preview deletion.
4. Delete those already-inspected objects.
5. Verify that unrelated files remain.

Passing retrieved file objects into `Remove-Item` is safer than casually repeating a broad wildcard.

### The Implementation

Create three temporary files:

```powershell
$temporaryFiles = @(
    "cache-01.tmp"
    "cache-02.tmp"
    "cache-03.tmp"
)

foreach ($temporaryFileName in $temporaryFiles) {
    $temporaryFilePath = Join-Path `
        -Path "$operationsLab\output" `
        -ChildPath $temporaryFileName

    Set-Content `
        -LiteralPath $temporaryFilePath `
        -Value "Disposable temporary content." `
        -Encoding UTF8 `
        -ErrorAction Stop
}
```

Select the exact matches:

```powershell
$tmpFilesToDelete = @(
    Get-ChildItem `
        -LiteralPath "$operationsLab\output" `
        -Filter "*.tmp" `
        -File
)
```

Inspect them:

```powershell
$tmpFilesToDelete |
    Select-Object Name, FullName, Length
```

Preview deletion:

```powershell
$tmpFilesToDelete |
    Remove-Item -WhatIf
```

Perform the deletion:

```powershell
$tmpFilesToDelete |
    Remove-Item -ErrorAction Stop
```

### The Verification

Confirm that no `.tmp` files remain:

```powershell
(
    Get-ChildItem `
        -LiteralPath "$operationsLab\output" `
        -Filter "*.tmp" `
        -File
).Count
```

Expected result:

```text
0
```

Confirm that the unrelated settings file remains:

```powershell
Test-Path `
    -LiteralPath "$operationsLab\output\settings.json" `
    -PathType Leaf
```

Expected result:

```text
True
```

---

## 2.18 Understand Why Non-Empty Directories Require `-Recurse`

### The Target

Attempt to remove a non-empty directory safely, observe the protection, and then preview its recursive deletion.

The target is:

```text
staging\data-backup
```

### The Concept

A directory may contain files and additional directories. PowerShell does not ordinarily remove the complete tree unless you explicitly request recursion.

`-Recurse` means:

> Process the target and all descendants beneath it.

This requirement is a safety barrier. Removing a labeled storage box is one action; destroying the box and everything inside it is a much broader action.

### The Implementation

Inspect the target before doing anything destructive:

```powershell
$dataBackupDirectory = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\data-backup"

Get-ChildItem `
    -LiteralPath $dataBackupDirectory `
    -Recurse |
    Select-Object FullName
```

Confirm that it is not empty:

```powershell
(
    Get-ChildItem `
        -LiteralPath $dataBackupDirectory `
        -Recurse `
        -Force
).Count -gt 0
```

Expected result:

```text
True
```

Attempt removal without `-Recurse`, but catch the expected error:

```powershell
try {
    Remove-Item `
        -LiteralPath $dataBackupDirectory `
        -ErrorAction Stop

    Write-Host "The directory was unexpectedly removed." -ForegroundColor Red
}
catch {
    Write-Host "PowerShell protected the non-empty directory." -ForegroundColor Yellow
    Write-Host "Message: $($_.Exception.Message)"
}
```

Preview recursive removal:

```powershell
Remove-Item `
    -LiteralPath $dataBackupDirectory `
    -Recurse `
    -WhatIf
```

Do not perform the deletion yet. The directory will be used in the next step.

### The Verification

Confirm that the directory and its files remain after the failed and previewed operations:

```powershell
[PSCustomObject]@{
    DirectoryStillExists = Test-Path `
        -LiteralPath $dataBackupDirectory `
        -PathType Container
    CustomersStillExist = Test-Path `
        -LiteralPath "$dataBackupDirectory\raw\customers.csv" `
        -PathType Leaf
    OrdersStillExist = Test-Path `
        -LiteralPath "$dataBackupDirectory\raw\orders.csv" `
        -PathType Leaf
}
```

Every value should be `True`.

---

## 2.19 Delete a Non-Empty Directory with `-Recurse`

### The Target

Delete:

```text
staging\data-backup
```

and all of its descendants.

### The Concept

Recursive deletion removes the entire tree rooted at the target.

Before approving it, inspect both:

- The root path
- Every descendant selected beneath it

Once the command completes, normal `Remove-Item` behavior does not provide an undo operation.

### The Implementation

Revalidate the exact path:

```powershell
$expectedDataBackupDirectory = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\data-backup"

if ($dataBackupDirectory -ne $expectedDataBackupDirectory) {
    throw "Safety check failed. Unexpected deletion target: $dataBackupDirectory"
}

if (-not (
    Test-Path `
        -LiteralPath $dataBackupDirectory `
        -PathType Container
)) {
    throw "The expected backup directory is missing: $dataBackupDirectory"
}
```

Display the complete deletion inventory:

```powershell
$deletionInventory = @(
    Get-Item `
        -LiteralPath $dataBackupDirectory `
        -Force

    Get-ChildItem `
        -LiteralPath $dataBackupDirectory `
        -Recurse `
        -Force
)

$deletionInventory |
    Sort-Object FullName |
    Select-Object FullName, Attributes
```

Preview once more:

```powershell
Remove-Item `
    -LiteralPath $dataBackupDirectory `
    -Recurse `
    -WhatIf
```

Perform the recursive deletion:

```powershell
Remove-Item `
    -LiteralPath $dataBackupDirectory `
    -Recurse `
    -ErrorAction Stop
```

### The Verification

Confirm that the root no longer exists:

```powershell
Test-Path -LiteralPath $dataBackupDirectory
```

Expected result:

```text
False
```

Confirm that the sibling file remains:

```powershell
Test-Path `
    -LiteralPath "$operationsLab\staging\SOURCE-NOTES.md" `
    -PathType Leaf
```

Expected result:

```text
True
```

This proves the command deleted only the intended subtree.

---

## 2.20 Create Hidden and Read-Only Test Files

### The Target

Create two disposable protected files:

```text
staging\.hidden-training-file
staging\read-only-training.txt
```

### The Concept

Windows files can carry **attributes**, which are metadata flags describing special handling.

Two common attributes are:

- `Hidden`: ordinary listings may omit the item.
- `ReadOnly`: applications should resist modifying the file.

Attributes are not security boundaries. A user with sufficient permissions can change them. They are closer to warning labels than locked vaults.

### The Implementation

Create the hidden file:

```powershell
$hiddenTrainingFile = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\.hidden-training-file"

Set-Content `
    -LiteralPath $hiddenTrainingFile `
    -Value "Disposable hidden training content." `
    -Encoding UTF8 `
    -ErrorAction Stop

$hiddenItem = Get-Item `
    -LiteralPath $hiddenTrainingFile `
    -Force `
    -ErrorAction Stop

$hiddenItem.Attributes = (
    $hiddenItem.Attributes -bor
    [System.IO.FileAttributes]::Hidden
)
```

The `-bor` operator performs a bitwise OR. Here, it adds the `Hidden` flag while preserving existing attributes.

Create the read-only file:

```powershell
$readOnlyTrainingFile = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\read-only-training.txt"

Set-Content `
    -LiteralPath $readOnlyTrainingFile `
    -Value "Disposable read-only training content." `
    -Encoding UTF8 `
    -ErrorAction Stop

$readOnlyItem = Get-Item `
    -LiteralPath $readOnlyTrainingFile `
    -Force `
    -ErrorAction Stop

$readOnlyItem.Attributes = (
    $readOnlyItem.Attributes -bor
    [System.IO.FileAttributes]::ReadOnly
)
```

Inspect the staging directory normally:

```powershell
Get-ChildItem `
    -LiteralPath "$operationsLab\staging"
```

Inspect it with hidden items included:

```powershell
Get-ChildItem `
    -LiteralPath "$operationsLab\staging" `
    -Force |
    Select-Object Name, Attributes
```

### The Verification

Confirm both attributes programmatically:

```powershell
$hiddenItem = Get-Item `
    -LiteralPath $hiddenTrainingFile `
    -Force

$readOnlyItem = Get-Item `
    -LiteralPath $readOnlyTrainingFile `
    -Force

[PSCustomObject]@{
    HiddenFileExists = Test-Path `
        -LiteralPath $hiddenTrainingFile `
        -PathType Leaf
    HiddenAttributeSet = [bool](
        $hiddenItem.Attributes -band
        [System.IO.FileAttributes]::Hidden
    )
    ReadOnlyFileExists = Test-Path `
        -LiteralPath $readOnlyTrainingFile `
        -PathType Leaf
    ReadOnlyAttributeSet = [bool](
        $readOnlyItem.Attributes -band
        [System.IO.FileAttributes]::ReadOnly
    )
}
```

Every value should be `True`.

---

## 2.21 Remove Hidden and Read-Only Files with `-Force`

### The Target

Safely delete the two protected training files.

### The Concept

`-Force` tells `Remove-Item` to process resources despite ordinary hidden or read-only attributes.

It does **not** bypass Windows access-control lists, take ownership, or grant administrator privileges. It only handles restrictions that the provider recognizes as forceable.

The safe sequence remains:

1. Retrieve the exact items with `-Force`.
2. Inspect their full paths and attributes.
3. Preview removal.
4. Perform removal with `-Force`.
5. Verify absence.

### The Implementation

Retrieve the exact items:

```powershell
$protectedTrainingFiles = @(
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

Inspect them:

```powershell
$protectedTrainingFiles |
    Select-Object Name, FullName, Attributes, Length
```

Preview their deletion:

```powershell
$protectedTrainingFiles |
    Remove-Item -Force -WhatIf
```

Confirm that the preview changed nothing:

```powershell
[PSCustomObject]@{
    HiddenStillExists = Test-Path `
        -LiteralPath $hiddenTrainingFile
    ReadOnlyStillExists = Test-Path `
        -LiteralPath $readOnlyTrainingFile
}
```

Both values should be `True`.

Perform deletion:

```powershell
$protectedTrainingFiles |
    Remove-Item `
        -Force `
        -ErrorAction Stop
```

### The Verification

Confirm that both files are gone:

```powershell
[PSCustomObject]@{
    HiddenWasRemoved = -not (
        Test-Path -LiteralPath $hiddenTrainingFile
    )
    ReadOnlyWasRemoved = -not (
        Test-Path -LiteralPath $readOnlyTrainingFile
    )
}
```

Both values should be `True`.

List staging with `-Force` to confirm no protected training files remain:

```powershell
Get-ChildItem `
    -LiteralPath "$operationsLab\staging" `
    -Force |
    Select-Object Name, Attributes
```

---

## 2.22 Clear Attributes Without Deleting the File

### The Target

Create a read-only file, remove only its `ReadOnly` attribute, and preserve its content.

### The Concept

Sometimes the problem is not that a file exists; the problem is that an attribute prevents modification.

Removing an attribute is like taking a “do not edit” label off a document without destroying the document itself.

A bitwise AND with the inverted flag removes one attribute while retaining other flags.

### The Implementation

Create a disposable file:

```powershell
$attributeDemoFile = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\attribute-demo.txt"

Set-Content `
    -LiteralPath $attributeDemoFile `
    -Value "Original content." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Set the `ReadOnly` attribute:

```powershell
$attributeDemoItem = Get-Item `
    -LiteralPath $attributeDemoFile `
    -Force

$attributeDemoItem.Attributes = (
    $attributeDemoItem.Attributes -bor
    [System.IO.FileAttributes]::ReadOnly
)
```

Confirm the attribute:

```powershell
$attributeDemoItem = Get-Item `
    -LiteralPath $attributeDemoFile `
    -Force

[bool](
    $attributeDemoItem.Attributes -band
    [System.IO.FileAttributes]::ReadOnly
)
```

Expected result:

```text
True
```

Remove only the `ReadOnly` flag:

```powershell
$attributeDemoItem.Attributes = (
    $attributeDemoItem.Attributes -band
    (-bnot [System.IO.FileAttributes]::ReadOnly)
)
```

Replace the content now that the flag has been cleared:

```powershell
Set-Content `
    -LiteralPath $attributeDemoFile `
    -Value "Updated after clearing the read-only attribute." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Retrieve the updated item:

```powershell
$updatedAttributeDemo = Get-Item `
    -LiteralPath $attributeDemoFile `
    -Force

$readOnlyStillSet = [bool](
    $updatedAttributeDemo.Attributes -band
    [System.IO.FileAttributes]::ReadOnly
)

[PSCustomObject]@{
    FileStillExists = Test-Path `
        -LiteralPath $attributeDemoFile `
        -PathType Leaf
    ReadOnlyWasCleared = -not $readOnlyStillSet
    ContentWasUpdated = (
        Get-Content `
            -LiteralPath $attributeDemoFile `
            -Raw
    ).Trim() -eq "Updated after clearing the read-only attribute."
}
```

Every value should be `True`.

---

## 2.23 Use `ShouldProcess` to Add `-WhatIf` to Your Own Function

### The Target

Create a reusable function named `Remove-LabItemSafely` that:

- Accepts one exact path
- Refuses paths outside `file-operations-lab`
- Supports `-WhatIf`
- Supports `-Confirm`
- Requires `-Recurse` for non-empty directories
- Supports `-Force`
- Produces a clear error when validation fails

### The Concept

Built-in commands support `-WhatIf` because they participate in PowerShell’s **ShouldProcess** framework.

A custom function can do the same by declaring:

```powershell
[CmdletBinding(SupportsShouldProcess)]
```

and asking:

```powershell
$PSCmdlet.ShouldProcess($target, $action)
```

Think of `ShouldProcess` as a safety officer. The function describes the intended action, and PowerShell decides whether to:

- Execute it
- Preview it because of `-WhatIf`
- Ask for approval because of `-Confirm`

### The Implementation

Define the function in the current PowerShell session:

```powershell
function Remove-LabItemSafely {
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
        [string] $LabRoot,

        [switch] $Recurse,

        [switch] $Force
    )

    $resolvedLabRoot = (
        Resolve-Path `
            -LiteralPath $LabRoot `
            -ErrorAction Stop
    ).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )

    $resolvedTarget = (
        Resolve-Path `
            -LiteralPath $LiteralPath `
            -ErrorAction Stop
    ).Path

    $rootPrefix = (
        $resolvedLabRoot +
        [System.IO.Path]::DirectorySeparatorChar
    )

    $targetIsLabRoot = $resolvedTarget.Equals(
        $resolvedLabRoot,
        [System.StringComparison]::OrdinalIgnoreCase
    )

    $targetIsInsideLab = $resolvedTarget.StartsWith(
        $rootPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )

    if ($targetIsLabRoot) {
        throw "Refusing to remove the laboratory root itself: $resolvedTarget"
    }

    if (-not $targetIsInsideLab) {
        throw "Refusing to remove a path outside the laboratory: $resolvedTarget"
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
                "The directory is not empty. " +
                "Specify -Recurse only after inspecting its contents: " +
                $resolvedTarget
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

Create a disposable directory tree for testing:

```powershell
$safeRemovalDemo = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\safe-removal-demo"

$null = New-Item `
    -Path "$safeRemovalDemo\nested" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$safeRemovalDemo\nested\demo.txt" `
    -Value "Disposable content." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview removal with the custom function:

```powershell
Remove-LabItemSafely `
    -LiteralPath $safeRemovalDemo `
    -LabRoot $operationsLab `
    -Recurse `
    -WhatIf
```

Because `ConfirmImpact` is `High`, a real call may prompt for confirmation. To execute non-interactively after you have inspected the target, pass `-Confirm:$false`:

```powershell
Remove-LabItemSafely `
    -LiteralPath $safeRemovalDemo `
    -LabRoot $operationsLab `
    -Recurse `
    -Confirm:$false
```

### The Verification

Confirm that `-WhatIf` preserved the directory before the real call:

```powershell
# Recreate the test if you already completed the real removal.
if (-not (Test-Path -LiteralPath $safeRemovalDemo)) {
    $null = New-Item `
        -Path "$safeRemovalDemo\nested" `
        -ItemType Directory `
        -Force

    Set-Content `
        -LiteralPath "$safeRemovalDemo\nested\demo.txt" `
        -Value "Disposable content." `
        -Encoding UTF8
}

Remove-LabItemSafely `
    -LiteralPath $safeRemovalDemo `
    -LabRoot $operationsLab `
    -Recurse `
    -WhatIf

$preservedByWhatIf = Test-Path `
    -LiteralPath $safeRemovalDemo `
    -PathType Container

Remove-LabItemSafely `
    -LiteralPath $safeRemovalDemo `
    -LabRoot $operationsLab `
    -Recurse `
    -Confirm:$false

$removedByRealCall = -not (
    Test-Path -LiteralPath $safeRemovalDemo
)

[PSCustomObject]@{
    WhatIfPreservedTarget = $preservedByWhatIf
    RealCallRemovedTarget = $removedByRealCall
}
```

Expected result:

```text
WhatIfPreservedTarget : True
RealCallRemovedTarget : True
```

Test the boundary protection with a path outside the laboratory:

```powershell
$outsideTestPath = Join-Path `
    -Path $env:TEMP `
    -ChildPath "outside-lab-safety-test.txt"

Set-Content `
    -LiteralPath $outsideTestPath `
    -Value "This file must not be removed by the lab function." `
    -Encoding UTF8

try {
    Remove-LabItemSafely `
        -LiteralPath $outsideTestPath `
        -LabRoot $operationsLab `
        -Confirm:$false
}
catch {
    Write-Host "Boundary protection worked." -ForegroundColor Green
    Write-Host $_.Exception.Message
}
```

Confirm that the outside file survived:

```powershell
Test-Path `
    -LiteralPath $outsideTestPath `
    -PathType Leaf
```

Expected result:

```text
True
```

Clean up that isolated test file directly:

```powershell
Remove-Item `
    -LiteralPath $outsideTestPath `
    -Force `
    -ErrorAction Stop
```

---

## 2.24 Persist the Safe Removal Function in a Script

### The Target

Create this reusable script:

```text
$HOME\cli-developer-environment-series\part-2-scripts\Remove-LabItemSafely.ps1
```

The script will preserve the same safety controls as the function while making them available in future terminal sessions.

### The Concept

A function defined interactively disappears when the current PowerShell session closes. A `.ps1` file stores the logic on disk so it can be executed repeatedly.

The script must be self-contained: it cannot assume the interactive function still exists.

### The Implementation

Create the scripts directory:

```powershell
$partTwoScripts = Join-Path `
    -Path $seriesRoot `
    -ChildPath "part-2-scripts"

if (-not (
    Test-Path `
        -LiteralPath $partTwoScripts `
        -PathType Container
)) {
    $null = New-Item `
        -Path $partTwoScripts `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Create the script with complete contents.

### File: `cli-developer-environment-series/part-2-scripts/Remove-LabItemSafely.ps1`

```powershell
$safeRemovalScript = Join-Path `
    -Path $partTwoScripts `
    -ChildPath "Remove-LabItemSafely.ps1"

$safeRemovalScriptContent = @'
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
    [string] $LabRoot,

    [switch] $Recurse,

    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedLabRoot = (
    Resolve-Path -LiteralPath $LabRoot
).Path.TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
)

$resolvedTarget = (
    Resolve-Path -LiteralPath $LiteralPath
).Path

$rootPrefix = (
    $resolvedLabRoot +
    [System.IO.Path]::DirectorySeparatorChar
)

$targetIsLabRoot = $resolvedTarget.Equals(
    $resolvedLabRoot,
    [System.StringComparison]::OrdinalIgnoreCase
)

$targetIsInsideLab = $resolvedTarget.StartsWith(
    $rootPrefix,
    [System.StringComparison]::OrdinalIgnoreCase
)

if ($targetIsLabRoot) {
    throw "Refusing to remove the laboratory root itself: $resolvedTarget"
}

if (-not $targetIsInsideLab) {
    throw "Refusing to remove a path outside the laboratory: $resolvedTarget"
}

$targetItem = Get-Item `
    -LiteralPath $resolvedTarget `
    -Force

if ($targetItem.PSIsContainer -and -not $Recurse) {
    $children = @(
        Get-ChildItem `
            -LiteralPath $resolvedTarget `
            -Force
    )

    if ($children.Count -gt 0) {
        throw (
            "The directory is not empty. " +
            "Inspect it and explicitly specify -Recurse: " +
            $resolvedTarget
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
'@

Set-Content `
    -LiteralPath $safeRemovalScript `
    -Value $safeRemovalScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Create a script test target:

```powershell
$scriptRemovalDemo = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\script-removal-demo"

$null = New-Item `
    -Path "$scriptRemovalDemo\child" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$scriptRemovalDemo\child\sample.txt" `
    -Value "Disposable script test." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview the script:

```powershell
& $safeRemovalScript `
    -LiteralPath $scriptRemovalDemo `
    -LabRoot $operationsLab `
    -Recurse `
    -WhatIf
```

Perform the deletion:

```powershell
& $safeRemovalScript `
    -LiteralPath $scriptRemovalDemo `
    -LabRoot $operationsLab `
    -Recurse `
    -Confirm:$false
```

### The Verification

Confirm the script exists:

```powershell
Test-Path `
    -LiteralPath $safeRemovalScript `
    -PathType Leaf
```

Expected result:

```text
True
```

Confirm the target was removed:

```powershell
Test-Path -LiteralPath $scriptRemovalDemo
```

Expected result:

```text
False
```

Review the saved script:

```powershell
Get-Content -LiteralPath $safeRemovalScript
```

If execution policy blocks the script, retain it for Part 3, where execution policy is explained and diagnosed properly. You may inspect its syntax without executing it:

```powershell
$tokens = $null
$parseErrors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $safeRemovalScript,
    [ref] $tokens,
    [ref] $parseErrors
) | Out-Null

$parseErrors
```

No output means no PowerShell parser errors were found.

---

## 2.25 Build a Repeatable Copy-and-Archive Workflow

### The Target

Create a complete script that:

1. Accepts a source directory.
2. Accepts an archive root.
3. Creates a timestamped archive directory.
4. Copies the source tree recursively.
5. Verifies source and destination file counts.
6. Verifies every copied file with SHA-256.
7. Supports `-WhatIf`.
8. Removes an incomplete archive if verification fails.

The script path will be:

```text
$HOME\cli-developer-environment-series\part-2-scripts\New-VerifiedArchive.ps1
```

### The Concept

A reliable file operation is more than “the command did not show an error.”

A verified archive checks that:

- The expected number of files arrived.
- Every destination file exists.
- Every destination file has the same content fingerprint as its source.

This is like moving valuable inventory between warehouses and reconciling both the item count and serial numbers afterward.

### The Implementation

Create the complete script.

### File: `cli-developer-environment-series/part-2-scripts/New-VerifiedArchive.ps1`

```powershell
$archiveScript = Join-Path `
    -Path $partTwoScripts `
    -ChildPath "New-VerifiedArchive.ps1"

$archiveScriptContent = @'
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $SourceDirectory,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ArchiveRoot,

    [ValidateNotNullOrEmpty()]
    [string] $ArchiveName = (
        "archive-" +
        (Get-Date -Format "yyyyMMdd-HHmmss-fff")
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedSource = (
    Resolve-Path -LiteralPath $SourceDirectory
).Path

$sourceItem = Get-Item `
    -LiteralPath $resolvedSource `
    -Force

if (-not $sourceItem.PSIsContainer) {
    throw "SourceDirectory must be a directory: $resolvedSource"
}

if (-not (
    Test-Path `
        -LiteralPath $ArchiveRoot `
        -PathType Container
)) {
    if ($PSCmdlet.ShouldProcess(
        $ArchiveRoot,
        "Create archive root directory"
    )) {
        $null = New-Item `
            -Path $ArchiveRoot `
            -ItemType Directory `
            -Force
    }
}

if ($WhatIfPreference) {
    $archiveDestination = Join-Path `
        -Path $ArchiveRoot `
        -ChildPath $ArchiveName
}
else {
    $resolvedArchiveRoot = (
        Resolve-Path -LiteralPath $ArchiveRoot
    ).Path

    $archiveDestination = Join-Path `
        -Path $resolvedArchiveRoot `
        -ChildPath $ArchiveName
}

if (Test-Path -LiteralPath $archiveDestination) {
    throw "Archive destination already exists: $archiveDestination"
}

if (-not $PSCmdlet.ShouldProcess(
    $resolvedSource,
    "Copy directory to $archiveDestination and verify every file"
)) {
    return
}

$null = New-Item `
    -Path $archiveDestination `
    -ItemType Directory

try {
    Get-ChildItem `
        -LiteralPath $resolvedSource `
        -Force |
        Copy-Item `
            -Destination $archiveDestination `
            -Recurse `
            -Force

    $sourceFiles = @(
        Get-ChildItem `
            -LiteralPath $resolvedSource `
            -File `
            -Recurse `
            -Force
    )

    $verificationResults = foreach ($sourceFile in $sourceFiles) {
        $relativePath = [System.IO.Path]::GetRelativePath(
            $resolvedSource,
            $sourceFile.FullName
        )

        $destinationFile = Join-Path `
            -Path $archiveDestination `
            -ChildPath $relativePath

        if (-not (
            Test-Path `
                -LiteralPath $destinationFile `
                -PathType Leaf
        )) {
            [PSCustomObject]@{
                RelativePath = $relativePath
                DestinationExists = $false
                HashMatches = $false
            }

            continue
        }

        $sourceHash = (
            Get-FileHash `
                -LiteralPath $sourceFile.FullName `
                -Algorithm SHA256
        ).Hash

        $destinationHash = (
            Get-FileHash `
                -LiteralPath $destinationFile `
                -Algorithm SHA256
        ).Hash

        [PSCustomObject]@{
            RelativePath = $relativePath
            DestinationExists = $true
            HashMatches = $sourceHash -eq $destinationHash
        }
    }

    $destinationFiles = @(
        Get-ChildItem `
            -LiteralPath $archiveDestination `
            -File `
            -Recurse `
            -Force
    )

    $failedFiles = @(
        $verificationResults |
            Where-Object {
                -not $_.DestinationExists -or
                -not $_.HashMatches
            }
    )

    $countsMatch = (
        $sourceFiles.Count -eq
        $destinationFiles.Count
    )

    if (-not $countsMatch -or $failedFiles.Count -gt 0) {
        throw (
            "Archive verification failed. " +
            "Source files: $($sourceFiles.Count). " +
            "Destination files: $($destinationFiles.Count). " +
            "Failed file checks: $($failedFiles.Count)."
        )
    }

    [PSCustomObject]@{
        SourceDirectory = $resolvedSource
        ArchiveDirectory = $archiveDestination
        SourceFileCount = $sourceFiles.Count
        ArchiveFileCount = $destinationFiles.Count
        AllHashesMatch = $true
        VerificationResults = @($verificationResults)
    }
}
catch {
    if (Test-Path -LiteralPath $archiveDestination) {
        Remove-Item `
            -LiteralPath $archiveDestination `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }

    throw
}
'@

Set-Content `
    -LiteralPath $archiveScript `
    -Value $archiveScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

> `[System.IO.Path]::GetRelativePath` is available in PowerShell 7 and in modern .NET. The next verification begins by checking the current runtime.

Check support:

```powershell
$getRelativePathMethod = [System.IO.Path].GetMethod(
    "GetRelativePath",
    [type[]]@([string], [string])
)

if ($null -eq $getRelativePathMethod) {
    throw (
        "This archive exercise requires PowerShell 7 or a runtime " +
        "that provides System.IO.Path.GetRelativePath."
    )
}
```

Preview archive creation:

```powershell
$archiveSource = Join-Path `
    -Path $operationsLab `
    -ChildPath "source"

$archiveRoot = Join-Path `
    -Path $operationsLab `
    -ChildPath "archive"

& $archiveScript `
    -SourceDirectory $archiveSource `
    -ArchiveRoot $archiveRoot `
    -ArchiveName "source-preview" `
    -WhatIf
```

Confirm that preview mode created nothing:

```powershell
Test-Path `
    -LiteralPath "$archiveRoot\source-preview"
```

Expected result:

```text
False
```

Create a real verified archive:

```powershell
$archiveResult = & $archiveScript `
    -SourceDirectory $archiveSource `
    -ArchiveRoot $archiveRoot `
    -ArchiveName "source-verified"
```

Display the summary:

```powershell
$archiveResult |
    Select-Object `
        SourceDirectory,
        ArchiveDirectory,
        SourceFileCount,
        ArchiveFileCount,
        AllHashesMatch
```

### The Verification

Confirm all summary values:

```powershell
[PSCustomObject]@{
    ArchiveExists = Test-Path `
        -LiteralPath $archiveResult.ArchiveDirectory `
        -PathType Container
    CountsMatch = (
        $archiveResult.SourceFileCount -eq
        $archiveResult.ArchiveFileCount
    )
    EveryHashMatched = $archiveResult.AllHashesMatch
    NoFailedFiles = @(
        $archiveResult.VerificationResults |
            Where-Object { -not $_.HashMatches }
    ).Count -eq 0
}
```

Every value should be `True`.

Inspect the per-file verification:

```powershell
$archiveResult.VerificationResults |
    Sort-Object RelativePath |
    Format-Table `
        RelativePath,
        DestinationExists,
        HashMatches `
        -AutoSize
```

Every file should report:

```text
DestinationExists : True
HashMatches        : True
```

---

## 2.26 Complete the File-Management Challenge

### The Target

Perform a complete workflow that:

1. Creates a project handoff directory.
2. Copies selected source files into it.
3. Renames one file.
4. Moves the handoff into `output`.
5. Creates an extra disposable file.
6. Previews deletion of the disposable file.
7. Deletes only that file.
8. Verifies the final handoff.

The final structure will be:

```text
output/
└── project-handoff/
    ├── APPLICATION.md
    ├── app.js
    └── config/
        └── settings.json
```

### The Concept

This challenge combines creation, copying, renaming, moving, deletion, and verification.

It models a common developer task: assembling a clean handoff package from a larger source tree.

### The Implementation

Define all paths:

```powershell
$handoffStaging = Join-Path `
    -Path $operationsLab `
    -ChildPath "staging\project-handoff"

$handoffOutput = Join-Path `
    -Path $operationsLab `
    -ChildPath "output\project-handoff"
```

Ensure a clean challenge start:

```powershell
foreach ($existingHandoff in @(
    $handoffStaging,
    $handoffOutput
)) {
    if (Test-Path -LiteralPath $existingHandoff) {
        Remove-Item `
            -LiteralPath $existingHandoff `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }
}
```

Create the staging structure:

```powershell
$null = New-Item `
    -Path "$handoffStaging\config" `
    -ItemType Directory `
    -Force `
    -ErrorAction Stop
```

Copy the application file:

```powershell
Copy-Item `
    -LiteralPath "$operationsLab\source\app.js" `
    -Destination "$handoffStaging\app.js" `
    -ErrorAction Stop
```

Copy the README:

```powershell
Copy-Item `
    -LiteralPath "$operationsLab\source\README.md" `
    -Destination "$handoffStaging\README.md" `
    -ErrorAction Stop
```

Copy the configuration:

```powershell
Copy-Item `
    -LiteralPath "$operationsLab\source\config\settings.json" `
    -Destination "$handoffStaging\config\settings.json" `
    -ErrorAction Stop
```

Rename the README:

```powershell
Rename-Item `
    -LiteralPath "$handoffStaging\README.md" `
    -NewName "APPLICATION.md" `
    -ErrorAction Stop
```

Create a disposable note:

```powershell
$disposableNote = Join-Path `
    -Path $handoffStaging `
    -ChildPath "remove-before-handoff.tmp"

Set-Content `
    -LiteralPath $disposableNote `
    -Value "This file must not appear in the final handoff." `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Preview deletion:

```powershell
Remove-Item `
    -LiteralPath $disposableNote `
    -WhatIf
```

Confirm preview preservation:

```powershell
Test-Path `
    -LiteralPath $disposableNote `
    -PathType Leaf
```

Expected result:

```text
True
```

Delete the disposable note:

```powershell
Remove-Item `
    -LiteralPath $disposableNote `
    -ErrorAction Stop
```

Move the complete handoff into `output`:

```powershell
Move-Item `
    -LiteralPath $handoffStaging `
    -Destination $handoffOutput `
    -ErrorAction Stop
```

### The Verification

Verify the expected files and absence of the temporary file:

```powershell
$handoffChecks = @(
    [PSCustomObject]@{
        Check = "Staging path was moved"
        Passed = -not (
            Test-Path -LiteralPath $handoffStaging
        )
    }

    [PSCustomObject]@{
        Check = "Output directory exists"
        Passed = Test-Path `
            -LiteralPath $handoffOutput `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "APPLICATION.md exists"
        Passed = Test-Path `
            -LiteralPath "$handoffOutput\APPLICATION.md" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "app.js exists"
        Passed = Test-Path `
            -LiteralPath "$handoffOutput\app.js" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "settings.json exists"
        Passed = Test-Path `
            -LiteralPath "$handoffOutput\config\settings.json" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Temporary file was removed"
        Passed = -not (
            Test-Path `
                -LiteralPath "$handoffOutput\remove-before-handoff.tmp"
        )
    }

    [PSCustomObject]@{
        Check = "Exactly three files remain"
        Passed = (
            Get-ChildItem `
                -LiteralPath $handoffOutput `
                -File `
                -Recurse
        ).Count -eq 3
    }
)

$handoffChecks |
    Format-Table -AutoSize
```

Confirm every check passed:

```powershell
$failedHandoffChecks = @(
    $handoffChecks |
        Where-Object { -not $_.Passed }
)

if ($failedHandoffChecks.Count -eq 0) {
    Write-Host "Part 2 challenge passed." -ForegroundColor Green
}
else {
    $failedHandoffChecks |
        Format-Table -AutoSize

    throw "Part 2 challenge failed."
}
```

Expected message:

```text
Part 2 challenge passed.
```

---

# Part 2 Reference A: Core File-Management Commands

| Purpose | Native PowerShell command | Common alias |
|---|---|---|
| Create a resource | `New-Item` | `ni`; `mkdir` for directory creation |
| Copy a resource | `Copy-Item` | `cp`, `copy`, `cpi` |
| Move a resource | `Move-Item` | `mv`, `move`, `mi` |
| Rename a resource | `Rename-Item` | `ren`, `rni` |
| Delete a resource | `Remove-Item` | `rm`, `del`, `erase`, `ri` |
| Read file content | `Get-Content` | `gc`, `cat`, `type` |
| Replace file content | `Set-Content` | `sc` |
| Append file content | `Add-Content` | `ac` |
| Clear file content | `Clear-Content` | `clc` |
| Inspect one item | `Get-Item` | `gi` |
| List children | `Get-ChildItem` | `gci`, `dir`, `ls` |
| Test existence | `Test-Path` | None by default |
| Calculate a file hash | `Get-FileHash` | None by default |

Inspect alias mappings on your computer:

```powershell
Get-Alias `
    -Name ni, cp, copy, cpi, mv, move, mi, ren, rni, rm, del, erase, ri |
    Sort-Object Name |
    Format-Table Name, Definition -AutoSize
```

Profiles and modules can alter aliases, so use `Get-Alias` to inspect the current session.

---

# Part 2 Reference B: `New-Item`

## Create a directory

```powershell
New-Item `
    -Path .\example `
    -ItemType Directory
```

## Create nested directories

```powershell
New-Item `
    -Path .\parent\child\grandchild `
    -ItemType Directory `
    -Force
```

## Create an empty file

```powershell
New-Item `
    -Path .\example.txt `
    -ItemType File
```

## Create a file with initial content

```powershell
New-Item `
    -Path .\example.txt `
    -ItemType File `
    -Value "Initial content"
```

## Create only when missing

```powershell
$path = ".\example"

if (-not (
    Test-Path `
        -LiteralPath $path `
        -PathType Container
)) {
    $null = New-Item `
        -Path $path `
        -ItemType Directory
}
```

This conditional approach makes intent explicit and avoids relying on `-Force` when replacement behavior is undesirable.

---

# Part 2 Reference C: Copy, Move, and Rename Semantics

## Copy a file into a directory

```powershell
Copy-Item `
    -LiteralPath .\source\report.txt `
    -Destination .\archive
```

The destination filename remains `report.txt`.

## Copy and change the filename

```powershell
Copy-Item `
    -LiteralPath .\source\report.txt `
    -Destination .\archive\report-copy.txt
```

## Copy a complete directory tree

```powershell
Copy-Item `
    -LiteralPath .\source `
    -Destination .\backup `
    -Recurse
```

Be careful when the destination already exists. Depending on the source and destination shapes, the resulting nesting can differ from what you intended. Inspect both locations first.

## Move a file into a directory

```powershell
Move-Item `
    -LiteralPath .\incoming\report.txt `
    -Destination .\archive
```

## Move and rename

```powershell
Move-Item `
    -LiteralPath .\incoming\report.txt `
    -Destination .\archive\report-processed.txt
```

## Rename without changing the parent directory

```powershell
Rename-Item `
    -LiteralPath .\archive\report.txt `
    -NewName "final-report.txt"
```

`Rename-Item -NewName` should receive a name, not a path to another directory. Use `Move-Item` when the parent directory must change.

---

# Part 2 Reference D: Content Commands

## Read a file as lines

```powershell
Get-Content -LiteralPath .\example.txt
```

The result is normally a collection containing one string per line.

## Read the complete file as one string

```powershell
Get-Content `
    -LiteralPath .\example.txt `
    -Raw
```

## Replace the complete content

```powershell
Set-Content `
    -LiteralPath .\example.txt `
    -Value "Replacement content" `
    -Encoding UTF8
```

## Append content

```powershell
Add-Content `
    -LiteralPath .\example.txt `
    -Value "Additional line" `
    -Encoding UTF8
```

## Empty a file without deleting it

```powershell
Clear-Content `
    -LiteralPath .\example.txt
```

## Write structured JSON

```powershell
$data = [ordered]@{
    name = "example"
    enabled = $true
}

$data |
    ConvertTo-Json -Depth 4 |
    Set-Content `
        -LiteralPath .\example.json `
        -Encoding UTF8
```

## Write structured CSV

```powershell
$records = @(
    [PSCustomObject]@{
        Id = 1
        Name = "Alpha"
    }

    [PSCustomObject]@{
        Id = 2
        Name = "Beta"
    }
)

$records |
    Export-Csv `
        -LiteralPath .\example.csv `
        -NoTypeInformation `
        -Encoding UTF8
```

---

# Part 2 Reference E: Deletion Safety

## Delete one exact file

```powershell
Remove-Item `
    -LiteralPath .\disposable.txt
```

## Preview first

```powershell
Remove-Item `
    -LiteralPath .\disposable.txt `
    -WhatIf
```

## Delete a non-empty directory

```powershell
Remove-Item `
    -LiteralPath .\disposable-directory `
    -Recurse
```

## Delete hidden or read-only resources

```powershell
Remove-Item `
    -LiteralPath .\protected-item `
    -Force
```

## Delete a protected directory tree

```powershell
Remove-Item `
    -LiteralPath .\disposable-directory `
    -Recurse `
    -Force
```

## Inspect wildcard matches before deletion

```powershell
$targets = @(
    Get-ChildItem `
        -LiteralPath .\output `
        -Filter "*.tmp" `
        -File
)

$targets |
    Select-Object Name, FullName, Length

$targets |
    Remove-Item -WhatIf
```

After inspection and preview:

```powershell
$targets |
    Remove-Item -ErrorAction Stop
```

## Never casually run broad commands

Commands such as these can be catastrophic when executed from the wrong location:

```text
Remove-Item * -Recurse -Force
Remove-Item C:\ -Recurse -Force
```

Do not experiment with broad deletion patterns. Use a specific, validated laboratory path.

---

# Part 2 Reference F: `-WhatIf`, `-Confirm`, and `ShouldProcess`

## `-WhatIf`

Preview an operation:

```powershell
Remove-Item `
    -LiteralPath .\target `
    -Recurse `
    -WhatIf
```

No change should occur.

## `-Confirm`

Ask for interactive confirmation:

```powershell
Remove-Item `
    -LiteralPath .\target `
    -Confirm
```

## Suppress a confirmation prompt deliberately

Some custom functions use a high confirmation impact. After validation and preview, automation may use:

```powershell
Remove-LabItemSafely `
    -LiteralPath $target `
    -LabRoot $operationsLab `
    -Recurse `
    -Confirm:$false
```

`-Confirm:$false` should not replace validation. It is appropriate only when the calling code has already decided that execution is safe.

## Add support to a custom function

```powershell
function Remove-ExampleItem {
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
Remove-ExampleItem `
    -LiteralPath .\example.txt `
    -WhatIf
```

---

# Part 2 Reference G: File Attributes

## Inspect attributes

```powershell
Get-Item `
    -LiteralPath .\example.txt `
    -Force |
    Select-Object Name, Attributes
```

## Test the hidden flag

```powershell
$item = Get-Item `
    -LiteralPath .\example.txt `
    -Force

[bool](
    $item.Attributes -band
    [System.IO.FileAttributes]::Hidden
)
```

## Add the hidden flag

```powershell
$item.Attributes = (
    $item.Attributes -bor
    [System.IO.FileAttributes]::Hidden
)
```

## Remove the hidden flag

```powershell
$item.Attributes = (
    $item.Attributes -band
    (-bnot [System.IO.FileAttributes]::Hidden)
)
```

## Add the read-only flag

```powershell
$item.Attributes = (
    $item.Attributes -bor
    [System.IO.FileAttributes]::ReadOnly
)
```

## Remove the read-only flag

```powershell
$item.Attributes = (
    $item.Attributes -band
    (-bnot [System.IO.FileAttributes]::ReadOnly)
)
```

The operators are:

| Operator | Purpose |
|---|---|
| `-band` | Bitwise AND |
| `-bor` | Bitwise OR |
| `-bnot` | Bitwise NOT |

You do not need to memorize their binary mathematics to use these patterns safely. The key rule is to preserve unrelated flags instead of replacing the complete `Attributes` value carelessly.

---

# Part 2 Reference H: `-Force` Does Not Mean “Ignore All Security”

`-Force` is commonly misunderstood.

It can help PowerShell:

- Include hidden items
- Modify or remove read-only items
- Replace certain existing destinations
- Create missing parent directories in supported operations

It does not automatically:

- Grant administrator privileges
- Bypass NTFS access-control lists
- Decrypt protected files
- Take ownership of resources
- Override security software
- Unlock files held exclusively by another process
- Bypass organizational policy

For example:

```powershell
Remove-Item `
    -LiteralPath "C:\Protected\Resource" `
    -Force
```

can still fail with an access-denied error.

Treat `-Force` as:

> Proceed through ordinary provider safeguards where permitted.

Do not interpret it as:

> Defeat the operating system’s security model.

---

# Part 2 Reference I: Error Handling for File Operations

## Stop on command failure

```powershell
Copy-Item `
    -LiteralPath $source `
    -Destination $destination `
    -ErrorAction Stop
```

## Handle failure

```powershell
try {
    Copy-Item `
        -LiteralPath $source `
        -Destination $destination `
        -ErrorAction Stop
}
catch {
    Write-Error (
        "Copy failed from '$source' to '$destination': " +
        $_.Exception.Message
    )
}
```

## Clean up incomplete output

```powershell
try {
    $null = New-Item `
        -Path $destination `
        -ItemType Directory `
        -ErrorAction Stop

    Copy-Item `
        -LiteralPath $source `
        -Destination $destination `
        -Recurse `
        -ErrorAction Stop
}
catch {
    if (Test-Path -LiteralPath $destination) {
        Remove-Item `
            -LiteralPath $destination `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }

    throw
}
```

`throw` reissues the current error so the caller knows the operation failed.

## Prefer exact paths for mutations

When one precise item is intended:

```powershell
Remove-Item -LiteralPath $exactPath
```

When matching several items is intentional:

```powershell
$matches = Get-ChildItem `
    -Path "$directory\*.tmp" `
    -File
```

Inspect `$matches` before removing them.

---

# Part 2 Reference J: Idempotent File Operations

An operation is **idempotent** when repeating it leads to the same intended state rather than duplicating or corrupting resources.

## Ensure a directory exists

```powershell
if (-not (
    Test-Path `
        -LiteralPath $directory `
        -PathType Container
)) {
    $null = New-Item `
        -Path $directory `
        -ItemType Directory
}
```

## Ensure exact file content

```powershell
Set-Content `
    -LiteralPath $file `
    -Value $expectedContent `
    -Encoding UTF8
```

Repeated execution replaces the content with the same expected value.

## Ensure an item is absent

```powershell
if (Test-Path -LiteralPath $disposablePath) {
    Remove-Item `
        -LiteralPath $disposablePath `
        -Recurse `
        -Force
}
```

## Avoid duplicate appends

This is not idempotent:

```powershell
Add-Content `
    -LiteralPath $file `
    -Value "Repeated line"
```

Every execution adds another copy.

Use `Set-Content` when the whole file should have a known state, or test before appending:

```powershell
$line = "Add this line once."
$currentContent = @(
    Get-Content `
        -LiteralPath $file `
        -ErrorAction SilentlyContinue
)

if ($line -notin $currentContent) {
    Add-Content `
        -LiteralPath $file `
        -Value $line `
        -Encoding UTF8
}
```

---

# Part 2 Reference K: Copy Verification Techniques

A successful command invocation does not always prove that the resulting data is correct. Verification can occur at several levels.

## Existence check

```powershell
Test-Path `
    -LiteralPath $destination `
    -PathType Leaf
```

This proves only that an item exists at the destination.

## Size comparison

```powershell
$sourceItem = Get-Item -LiteralPath $source
$destinationItem = Get-Item -LiteralPath $destination

$sourceItem.Length -eq $destinationItem.Length
```

Equal sizes are useful but do not prove identical content.

## Hash comparison

```powershell
$sourceHash = (
    Get-FileHash `
        -LiteralPath $source `
        -Algorithm SHA256
).Hash

$destinationHash = (
    Get-FileHash `
        -LiteralPath $destination `
        -Algorithm SHA256
).Hash

$sourceHash -eq $destinationHash
```

Hash comparison is much stronger.

## Directory file-count comparison

```powershell
$sourceCount = (
    Get-ChildItem `
        -LiteralPath $sourceDirectory `
        -File `
        -Recurse `
        -Force
).Count

$destinationCount = (
    Get-ChildItem `
        -LiteralPath $destinationDirectory `
        -File `
        -Recurse `
        -Force
).Count

$sourceCount -eq $destinationCount
```

Use both count and per-file hash checks for stronger directory verification.

---

# Part 2 Reference L: Common File-Management Mistakes

## Mistake 1: Deleting from an unknown location

Risky:

```powershell
Remove-Item .\archive -Recurse
```

Safer:

```powershell
Get-Location
Resolve-Path -LiteralPath .\archive
Remove-Item -LiteralPath .\archive -Recurse -WhatIf
```

## Mistake 2: Using `-Force` by habit

Risky:

```powershell
Copy-Item $source $destination -Force
```

Safer:

```powershell
if (Test-Path -LiteralPath $destination) {
    throw "Destination already exists: $destination"
}

Copy-Item `
    -LiteralPath $source `
    -Destination $destination
```

Use `-Force` only when replacement is explicitly intended.

## Mistake 3: Deleting wildcard matches without inspection

Risky:

```powershell
Remove-Item -Path *.log
```

Safer:

```powershell
$logs = @(
    Get-ChildItem `
        -Path . `
        -Filter "*.log" `
        -File
)

$logs | Select-Object FullName
$logs | Remove-Item -WhatIf
```

## Mistake 4: Confusing copy with move

After copying, the source remains:

```powershell
Copy-Item `
    -LiteralPath $source `
    -Destination $destination
```

After moving, the original path normally disappears:

```powershell
Move-Item `
    -LiteralPath $source `
    -Destination $destination
```

## Mistake 5: Using `Rename-Item` to change parent directories

Incorrect intent:

```powershell
Rename-Item `
    -LiteralPath .\source\file.txt `
    -NewName .\archive\file.txt
```

Use:

```powershell
Move-Item `
    -LiteralPath .\source\file.txt `
    -Destination .\archive\file.txt
```

## Mistake 6: Assuming hidden means secure

A hidden file can be displayed with:

```powershell
Get-ChildItem -Force
```

Do not store secrets securely merely by hiding a file.

## Mistake 7: Assuming `Remove-Item` uses the Recycle Bin

It generally does not. Treat deletion as permanent.

## Mistake 8: Verifying only command output

Silence is not proof. Use:

```powershell
Test-Path
Get-Item
Get-ChildItem
Get-FileHash
```

to inspect the resulting state.

---

# Part 2 Reference M: Compact Command Cookbook

## Create a directory

```powershell
New-Item `
    -Path .\example `
    -ItemType Directory
```

## Create nested directories

```powershell
New-Item `
    -Path .\parent\child `
    -ItemType Directory `
    -Force
```

## Create an empty file

```powershell
New-Item `
    -Path .\example.txt `
    -ItemType File
```

## Write a file

```powershell
Set-Content `
    -LiteralPath .\example.txt `
    -Value "Hello" `
    -Encoding UTF8
```

## Append a line

```powershell
Add-Content `
    -LiteralPath .\example.txt `
    -Value "Another line" `
    -Encoding UTF8
```

## Copy a file

```powershell
Copy-Item `
    -LiteralPath .\example.txt `
    -Destination .\backup\example.txt
```

## Copy a directory tree

```powershell
Copy-Item `
    -LiteralPath .\source `
    -Destination .\backup `
    -Recurse
```

## Rename a file

```powershell
Rename-Item `
    -LiteralPath .\old-name.txt `
    -NewName "new-name.txt"
```

## Move and rename a file

```powershell
Move-Item `
    -LiteralPath .\incoming\file.txt `
    -Destination .\archive\processed-file.txt
```

## Preview deletion

```powershell
Remove-Item `
    -LiteralPath .\target `
    -Recurse `
    -WhatIf
```

## Delete a file

```powershell
Remove-Item `
    -LiteralPath .\target.txt
```

## Delete a directory tree

```powershell
Remove-Item `
    -LiteralPath .\target-directory `
    -Recurse
```

## Delete a hidden or read-only tree

```powershell
Remove-Item `
    -LiteralPath .\target-directory `
    -Recurse `
    -Force
```

## Compare hashes

```powershell
(
    Get-FileHash `
        -LiteralPath $source `
        -Algorithm SHA256
).Hash -eq (
    Get-FileHash `
        -LiteralPath $destination `
        -Algorithm SHA256
).Hash
```

---

# Part 2 Final Verification

## The Target

Verify that all critical Part 2 resources exist and that destructive exercises affected only their intended targets.

### The Concept

A phase-ending verification converts assumptions into explicit checks.

The final state should prove that you can:

- Create and populate files
- Copy verified content
- Move and rename resources
- Delete selected temporary content
- Preserve unrelated files
- Create reusable automation scripts
- Produce a verified archive
- Assemble the final handoff directory

### The Implementation

Reconstruct the principal paths so this check does not depend on earlier transient variables:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$operationsLab = Join-Path `
    -Path $seriesRoot `
    -ChildPath "filesystem-lab\file-operations-lab"

$partTwoScripts = Join-Path `
    -Path $seriesRoot `
    -ChildPath "part-2-scripts"

$safeRemovalScript = Join-Path `
    -Path $partTwoScripts `
    -ChildPath "Remove-LabItemSafely.ps1"

$archiveScript = Join-Path `
    -Path $partTwoScripts `
    -ChildPath "New-VerifiedArchive.ps1"

$sourceDirectory = Join-Path `
    -Path $operationsLab `
    -ChildPath "source"

$verifiedArchive = Join-Path `
    -Path $operationsLab `
    -ChildPath "archive\source-verified"

$handoffOutput = Join-Path `
    -Path $operationsLab `
    -ChildPath "output\project-handoff"
```

Create the complete check list:

```powershell
$partTwoChecks = @(
    [PSCustomObject]@{
        Check = "Operations laboratory exists"
        Passed = Test-Path `
            -LiteralPath $operationsLab `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "Source README exists"
        Passed = Test-Path `
            -LiteralPath "$sourceDirectory\README.md" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Source application exists"
        Passed = Test-Path `
            -LiteralPath "$sourceDirectory\app.js" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Source settings exist"
        Passed = Test-Path `
            -LiteralPath "$sourceDirectory\config\settings.json" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Source customer data exists"
        Passed = Test-Path `
            -LiteralPath "$sourceDirectory\data\raw\customers.csv" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Source order data exists"
        Passed = Test-Path `
            -LiteralPath "$sourceDirectory\data\raw\orders.csv" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Moved customer file exists"
        Passed = Test-Path `
            -LiteralPath "$operationsLab\archive\customers.csv" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Moved and renamed order file exists"
        Passed = Test-Path `
            -LiteralPath "$operationsLab\archive\orders-processed.csv" `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Incoming directory is empty"
        Passed = @(
            Get-ChildItem `
                -LiteralPath "$operationsLab\incoming" `
                -Force
        ).Count -eq 0
    }

    [PSCustomObject]@{
        Check = "Recursive deletion target is absent"
        Passed = -not (
            Test-Path `
                -LiteralPath "$operationsLab\staging\data-backup"
        )
    }

    [PSCustomObject]@{
        Check = "Temporary output files are absent"
        Passed = @(
            Get-ChildItem `
                -LiteralPath "$operationsLab\output" `
                -Filter "*.tmp" `
                -File `
                -Recurse
        ).Count -eq 0
    }

    [PSCustomObject]@{
        Check = "Safe removal script exists"
        Passed = Test-Path `
          -LiteralPath $safeRemovalScript `
          -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Verified archive script exists"
        Passed = Test-Path `
            -LiteralPath $archiveScript `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "Verified archive exists"
        Passed = Test-Path `
            -LiteralPath $verifiedArchive `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "Final handoff directory exists"
        Passed = Test-Path `
            -LiteralPath $handoffOutput `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "Final handoff contains three files"
        Passed = @(
            Get-ChildItem `
                -LiteralPath $handoffOutput `
                -File `
                -Recurse
        ).Count -eq 3
    }

    [PSCustomObject]@{
        Check = "Final handoff contains no temporary files"
        Passed = @(
            Get-ChildItem `
                -LiteralPath $handoffOutput `
                -Filter "*.tmp" `
                -File `
                -Recurse
        ).Count -eq 0
    }
)

$partTwoChecks |
    Format-Table Check, Passed -AutoSize
```

Verify that the source and archived file counts match:

```powershell
$sourceFiles = @(
    Get-ChildItem `
        -LiteralPath $sourceDirectory `
        -File `
        -Recurse `
        -Force
)

$archivedFiles = @(
    Get-ChildItem `
        -LiteralPath $verifiedArchive `
        -File `
        -Recurse `
        -Force
)

$archiveCountCheck = [PSCustomObject]@{
    Check = "Source and verified archive file counts match"
    Passed = $sourceFiles.Count -eq $archivedFiles.Count
}

$archiveCountCheck |
    Format-Table Check, Passed -AutoSize
```

Verify every archived file by relative path and SHA-256 hash:

```powershell
$getRelativePathMethod = [System.IO.Path].GetMethod(
    "GetRelativePath",
    [type[]]@([string], [string])
)

if ($null -eq $getRelativePathMethod) {
    throw (
        "Final hash verification requires PowerShell 7 or a runtime " +
        "that provides System.IO.Path.GetRelativePath."
    )
}

$archiveHashChecks = foreach ($sourceFile in $sourceFiles) {
    $relativePath = [System.IO.Path]::GetRelativePath(
        $sourceDirectory,
        $sourceFile.FullName
    )

    $archivedFilePath = Join-Path `
        -Path $verifiedArchive `
        -ChildPath $relativePath

    $archivedFileExists = Test-Path `
        -LiteralPath $archivedFilePath `
        -PathType Leaf

    $hashMatches = $false

    if ($archivedFileExists) {
        $sourceHash = (
            Get-FileHash `
                -LiteralPath $sourceFile.FullName `
                -Algorithm SHA256
        ).Hash

        $archivedHash = (
            Get-FileHash `
                -LiteralPath $archivedFilePath `
                -Algorithm SHA256
        ).Hash

        $hashMatches = $sourceHash -eq $archivedHash
    }

    [PSCustomObject]@{
        RelativePath = $relativePath
        DestinationExists = $archivedFileExists
        HashMatches = $hashMatches
    }
}

$archiveHashChecks |
    Sort-Object RelativePath |
    Format-Table `
        RelativePath,
        DestinationExists,
        HashMatches `
        -AutoSize
```

### The Verification

Combine the checks:

```powershell
$allPartTwoChecks = @(
    $partTwoChecks
    $archiveCountCheck

    foreach ($hashCheck in $archiveHashChecks) {
        [PSCustomObject]@{
            Check = "Archived hash matches: $($hashCheck.RelativePath)"
            Passed = (
                $hashCheck.DestinationExists -and
                $hashCheck.HashMatches
            )
        }
    }
)
```

Find any failures:

```powershell
$failedPartTwoChecks = @(
    $allPartTwoChecks |
        Where-Object { -not $_.Passed }
)
```

Display the final result:

```powershell
if ($failedPartTwoChecks.Count -eq 0) {
    Write-Host "Part 2 final verification passed." -ForegroundColor Green
}
else {
    Write-Host "Part 2 final verification failed." -ForegroundColor Red

    $failedPartTwoChecks |
        Format-Table Check, Passed -AutoSize

    throw "Repair the failed Part 2 checks before continuing."
}
```

Expected message:

```text
Part 2 final verification passed.
```

Return to the series root so Part 3 begins from a predictable location:

```powershell
Set-Location -LiteralPath $seriesRoot
Get-Location
```

The displayed path should end with:

```text
cli-developer-environment-series
```

---

# Part 2 Key Takeaways

You can now manipulate files and directories using explicit, verifiable PowerShell operations.

## Creating resources

You learned to create directories with:

```powershell
New-Item `
    -Path .\reports `
    -ItemType Directory
```

You created nested directory structures with:

```powershell
New-Item `
    -Path .\source\data\raw `
    -ItemType Directory `
    -Force
```

You created empty files with:

```powershell
New-Item `
    -Path .\source\app.js `
    -ItemType File
```

You wrote complete file contents with:

```powershell
Set-Content `
    -LiteralPath .\source\app.js `
    -Value $content `
    -Encoding UTF8
```

## Copying resources

You copied individual files:

```powershell
Copy-Item `
    -LiteralPath $source `
    -Destination $destination
```

You copied and renamed in one operation by supplying a destination filename.

You copied complete directory trees with:

```powershell
Copy-Item `
    -LiteralPath $sourceDirectory `
    -Destination $destinationDirectory `
    -Recurse
```

You also verified copied content using SHA-256 hashes rather than assuming that an error-free command guaranteed a correct result.

## Moving and renaming resources

You used `Rename-Item` when only an item’s name changed:

```powershell
Rename-Item `
    -LiteralPath $oldPath `
    -NewName "new-name.txt"
```

You used `Move-Item` when the parent directory changed:

```powershell
Move-Item `
    -LiteralPath $source `
    -Destination $destination
```

You also moved and renamed a file in one operation.

## Deleting safely

You learned that `Remove-Item` generally does not use the Recycle Bin.

You previewed destructive operations with:

```powershell
Remove-Item `
    -LiteralPath $target `
    -WhatIf
```

You removed non-empty directories only after explicit recursive approval:

```powershell
Remove-Item `
    -LiteralPath $targetDirectory `
    -Recurse
```

You handled hidden and read-only items with:

```powershell
Remove-Item `
    -LiteralPath $target `
    -Force
```

Most importantly, you learned that `-Force` does not bypass Windows security permissions.

## Building safer automation

You created a reusable function and script with native `-WhatIf` and `-Confirm` support:

```powershell
[CmdletBinding(SupportsShouldProcess)]
```

You protected the laboratory boundary by resolving paths and refusing to remove:

- The laboratory root itself
- Any path outside the laboratory

You also created a verified archive workflow that:

- Copied an entire directory tree
- Compared source and destination file counts
- Compared every copied file by SHA-256 hash
- Removed incomplete output after failed verification

---

## Part 2 Completion Checklist

Before continuing, confirm that you can perform each task:

- [ ] Create one directory with `New-Item`
- [ ] Create nested directories
- [ ] Create an empty file
- [ ] Write complete file content with `Set-Content`
- [ ] Append content with `Add-Content`
- [ ] Copy one file with `Copy-Item`
- [ ] Copy and rename in one operation
- [ ] Copy a directory tree with `-Recurse`
- [ ] Copy several files using an intentional wildcard
- [ ] Rename a file with `Rename-Item`
- [ ] Rename a directory
- [ ] Move a file with `Move-Item`
- [ ] Move and rename in one operation
- [ ] Inspect an existing destination before using `-Force`
- [ ] Preview a filesystem mutation with `-WhatIf`
- [ ] Delete one exact file
- [ ] Inspect wildcard matches before deleting them
- [ ] Explain why non-empty directories require `-Recurse`
- [ ] Remove a non-empty directory after previewing it
- [ ] Identify hidden and read-only attributes
- [ ] Remove hidden and read-only resources with `-Force`
- [ ] Clear a file attribute without deleting the file
- [ ] Add `-WhatIf` support to a custom function
- [ ] Verify copied files with `Get-FileHash`
- [ ] Handle file-operation failures with `try` and `catch`

---

## What Comes Next

Part 3 moves from filesystem management into the Node.js development ecosystem.

You will:

- Install or verify Node.js
- Distinguish `node`, `npm`, `npx`, and `pnpm`
- Initialize the `developer-service` project
- Read and validate `package.json`
- Understand `package-lock.json`
- Examine the purpose and cost of `node_modules`
- Install production and development dependencies
- Execute package binaries with `npx`
- Define development, build, start, clean, lint, and test scripts
- Diagnose PowerShell `.ps1` execution-policy errors
- Apply narrow, security-conscious execution-policy remedies
- Build a working HTTP service
- Produce and run generated output

Part 4 will then move runtime configuration and secrets outside the source code.

