# Primer 1: How to Read PowerShell Commands

PowerShell commands can look dense when several symbols appear on one line:

```powershell
Get-ChildItem -Path .\src -File -Recurse |
    Sort-Object -Property Name |
    Select-Object Name, Length
```

You do not need to memorize this line as one large instruction. PowerShell commands are assembled from smaller, predictable pieces.

In this primer, you will learn how to recognize:

- Cmdlets
- Aliases
- Parameters
- Parameter values
- Switch parameters
- Positional arguments
- Variables
- Strings and quotation marks
- Arrays
- Script blocks
- Pipelines
- Properties
- Operators
- Comments
- Multiline commands
- Command output and errors
- Built-in help

By the end, you should be able to look at an unfamiliar PowerShell command, separate it into parts, and explain what each part does.

---

## Primer Laboratory

The examples use a small, disposable directory:

```text
$HOME/
└── powershell-reading-primer/
    ├── archive/
    └── documents/
        ├── notes.txt
        ├── project-plan.md
        └── settings.json
```

This primer does not delete personal files or require administrator access.

---

## P1.1 Understand the Shape of a PowerShell Command

### The Target

Learn to separate a command into its command name, parameters, and values.

### The Concept

A PowerShell command is like a structured request at a service desk:

> Retrieve the child items from the `documents` directory, but return only files.

That request becomes:

```powershell
Get-ChildItem -Path .\documents -File
```

Its parts are:

```text
Get-ChildItem   -Path       .\documents       -File
└─ command     └─ parameter └─ parameter value └─ switch
```

### The Implementation

Run a simple command:

```powershell
Get-Date
```

Now add a parameter:

```powershell
Get-Date -Format "yyyy-MM-dd"
```

Read it from left to right:

```text
Get-Date       → execute the Get-Date command
-Format        → configure its output format
"yyyy-MM-dd"   → supply the requested format
```

Display the current location:

```powershell
Get-Location
```

Inspect an explicit path:

```powershell
Get-ChildItem -Path $HOME
```

This has three parts:

```text
Get-ChildItem → command
-Path         → parameter
$HOME         → parameter value
```

### The Verification

Ask PowerShell to identify the commands:

```powershell
Get-Command -Name Get-Date
Get-Command -Name Get-Location
Get-Command -Name Get-ChildItem
```

Confirm that they are available:

```powershell
$requiredCommands = @(
    "Get-Date"
    "Get-Location"
    "Get-ChildItem"
)

$commandChecks = foreach ($commandName in $requiredCommands) {
    [PSCustomObject]@{
        Command = $commandName
        Available = $null -ne (
            Get-Command `
                -Name $commandName `
                -ErrorAction SilentlyContinue
        )
    }
}

$commandChecks |
    Format-Table -AutoSize
```

Every `Available` value should be `True`.

---

## P1.2 Recognize Cmdlets and the `Verb-Noun` Pattern

### The Target

Understand the naming convention used by native PowerShell commands.

### The Concept

A **cmdlet**, pronounced “command-let,” is a lightweight PowerShell command.

Cmdlet names normally follow this pattern:

```text
Verb-Noun
```

The verb describes the action:

```text
Get
Set
New
Copy
Move
Remove
```

The noun identifies the resource:

```text
Item
ChildItem
Location
Content
Process
```

Examples include:

```text
Get-Location
Set-Location
New-Item
Copy-Item
Move-Item
Remove-Item
```

This is similar to labeling tools with both their action and purpose:

```text
Cut-Paper
Measure-Wood
Open-Door
```

PowerShell uses an approved list of verbs so command names remain consistent.

### The Implementation

Find commands that use the noun `Location`:

```powershell
Get-Command -Noun Location
```

Find commands that use the noun `Item`:

```powershell
Get-Command -Noun Item
```

Find commands using the verb `Get`:

```powershell
Get-Command -Verb Get |
    Select-Object -First 10 Name, CommandType
```

Inspect PowerShell’s approved verbs:

```powershell
Get-Verb |
    Sort-Object Verb |
    Select-Object Verb, Group, Description
```

### The Verification

Split several command names into their verbs and nouns:

```powershell
$commandNames = @(
    "Get-Location"
    "Set-Location"
    "Get-ChildItem"
    "New-Item"
    "Remove-Item"
)

$commandParts = foreach ($commandName in $commandNames) {
    $parts = $commandName -split "-", 2

    [PSCustomObject]@{
        Command = $commandName
        Verb = $parts[0]
        Noun = $parts[1]
    }
}

$commandParts |
    Format-Table -AutoSize
```

Expected output resembles:

```text
Command        Verb    Noun
-------        ----    ----
Get-Location   Get     Location
Set-Location   Set     Location
Get-ChildItem  Get     ChildItem
New-Item       New     Item
Remove-Item    Remove  Item
```

---

## P1.3 Understand Aliases

### The Target

Distinguish short aliases from native PowerShell command names.

### The Concept

An **alias** is a nickname for another command.

For example:

```text
pwd → Get-Location
cd  → Set-Location
dir → Get-ChildItem
ls  → Get-ChildItem
```

Typing an alias does not transform PowerShell into Bash or Command Prompt. In a standard PowerShell session, `ls` invokes the PowerShell cmdlet `Get-ChildItem`.

Aliases are convenient during interactive work. Full command names are clearer in scripts and tutorials.

### The Implementation

Inspect common aliases:

```powershell
Get-Alias -Name pwd, cd, dir, ls |
    Select-Object Name, Definition
```

Compare the alias and native command:

```powershell
pwd
Get-Location
```

Compare these listings:

```powershell
ls
Get-ChildItem
```

Ask PowerShell how it resolves `ls`:

```powershell
Get-Command -Name ls |
    Format-List Name, CommandType, Definition
```

### The Verification

Verify the expected definitions:

```powershell
$expectedAliases = @{
    pwd = "Get-Location"
    cd  = "Set-Location"
    dir = "Get-ChildItem"
    ls  = "Get-ChildItem"
}

$aliasChecks = foreach ($aliasName in $expectedAliases.Keys) {
    $alias = Get-Alias -Name $aliasName

    [PSCustomObject]@{
        Alias = $aliasName
        NativeCommand = $alias.Definition
        Expected = $expectedAliases[$aliasName]
        Matches = (
            $alias.Definition -eq
            $expectedAliases[$aliasName]
        )
    }
}

$aliasChecks |
    Sort-Object Alias |
    Format-Table -AutoSize
```

Every `Matches` value should be `True`.

---

## P1.4 Create the Primer Laboratory

### The Target

Create a predictable set of directories and files for the remaining examples.

### The Concept

Learning commands is easier when every example operates on known data. A dedicated laboratory also prevents accidental changes to important files.

You do not need to understand every setup command yet. Each important piece will be explained later in the series.

### The Implementation

Run the complete block:

```powershell
$primerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "powershell-reading-primer"

$documentsPath = Join-Path `
    -Path $primerRoot `
    -ChildPath "documents"

$archivePath = Join-Path `
    -Path $primerRoot `
    -ChildPath "archive"

foreach ($directory in @(
    $primerRoot
    $documentsPath
    $archivePath
)) {
    if (-not (
        Test-Path `
            -LiteralPath $directory `
            -PathType Container
    )) {
        $null = New-Item `
            -Path $directory `
            -ItemType Directory `
            -Force `
            -ErrorAction Stop
    }
}

Set-Content `
    -LiteralPath "$documentsPath\notes.txt" `
    -Value "PowerShell primer notes." `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$documentsPath\project-plan.md" `
    -Value @'
# Project Plan

1. Read PowerShell commands.
2. Run PowerShell commands.
3. Verify the result.
'@ `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Content `
    -LiteralPath "$documentsPath\settings.json" `
    -Value @'
{
  "environment": "development",
  "enabled": true
}
'@ `
    -Encoding UTF8 `
    -ErrorAction Stop

Set-Location -LiteralPath $primerRoot
```

### The Verification

Confirm the laboratory structure:

```powershell
Get-ChildItem `
    -LiteralPath $primerRoot `
    -Recurse |
    Select-Object FullName
```

Confirm the expected item counts:

```powershell
[PSCustomObject]@{
    DirectoryCount = (
        Get-ChildItem `
            -LiteralPath $primerRoot `
            -Directory `
            -Recurse
    ).Count
    FileCount = (
        Get-ChildItem `
            -LiteralPath $primerRoot `
            -File `
            -Recurse
    ).Count
}
```

Expected values:

```text
DirectoryCount : 2
FileCount      : 3
```

---

## P1.5 Understand Parameters and Parameter Values

### The Target

Recognize named parameters and the values supplied to them.

### The Concept

A **parameter** is a named setting accepted by a command. PowerShell parameter names begin with a hyphen:

```text
-Path
-Filter
-Property
-ErrorAction
```

Some parameters require a value:

```powershell
-Path .\documents
```

Others behave as on/off switches:

```powershell
-File
```

Named parameters make commands readable because they explain the purpose of each value.

### The Implementation

Run:

```powershell
Get-ChildItem `
    -Path .\documents `
    -Filter "*.json"
```

Read it as:

```text
Get-ChildItem  → retrieve child items
-Path          → choose the location
.\documents    → use this location
-Filter        → choose a filename pattern
"*.json"       → names ending in .json
```

Display selected file properties:

```powershell
Get-ChildItem `
    -Path .\documents `
    -File |
    Select-Object `
        -Property Name, Length
```

Here, `-Property` receives two values:

```text
Name
Length
```

### The Verification

Ask for help about one parameter:

```powershell
Get-Help `
    -Name Get-ChildItem `
    -Parameter Path
```

Inspect all accepted parameter sets:

```powershell
Get-Command -Name Get-ChildItem |
    Select-Object -ExpandProperty ParameterSets |
    Select-Object Name, ToString
```

Confirm the JSON filter returns one file:

```powershell
$jsonFiles = @(
    Get-ChildItem `
        -Path .\documents `
        -Filter "*.json" `
        -File
)

[PSCustomObject]@{
    MatchCount = $jsonFiles.Count
    MatchedName = $jsonFiles.Name
    Passed = (
        $jsonFiles.Count -eq 1 -and
        $jsonFiles.Name -eq "settings.json"
    )
}
```

`Passed` should be `True`.

---

## P1.6 Understand Switch Parameters

### The Target

Recognize parameters that enable behavior without requiring a separate value.

### The Concept

A **switch parameter** is like a light switch. Its presence turns a feature on:

```powershell
-Recurse
```

Its absence leaves that feature off.

Common switches include:

```text
-File
-Directory
-Recurse
-Force
-WhatIf
```

You normally do not write:

```text
-Recurse true
```

You simply include:

```powershell
-Recurse
```

### The Implementation

List immediate files at the primer root:

```powershell
Get-ChildItem `
    -LiteralPath $primerRoot `
    -File
```

This returns no files because the files are inside `documents`.

Enable recursion:

```powershell
Get-ChildItem `
    -LiteralPath $primerRoot `
    -File `
    -Recurse
```

Now all three files appear.

Explicitly disable a switch when passing it through reusable code:

```powershell
$shouldRecurse = $false

Get-ChildItem `
    -LiteralPath $primerRoot `
    -File `
    -Recurse:$shouldRecurse
```

This form is useful in functions and scripts where a Boolean variable controls the switch.

### The Verification

Compare the counts:

```powershell
$immediateFileCount = @(
    Get-ChildItem `
        -LiteralPath $primerRoot `
        -File
).Count

$recursiveFileCount = @(
    Get-ChildItem `
        -LiteralPath $primerRoot `
        -File `
        -Recurse
).Count

[PSCustomObject]@{
    ImmediateFiles = $immediateFileCount
    RecursiveFiles = $recursiveFileCount
    RecurseFoundMore = (
        $recursiveFileCount -gt
        $immediateFileCount
    )
}
```

Expected result:

```text
ImmediateFiles  : 0
RecursiveFiles  : 3
RecurseFoundMore: True
```

---

## P1.7 Understand Positional Arguments

### The Target

Recognize when PowerShell accepts a value without an explicitly named parameter.

### The Concept

Some parameters have positions. This allows a shorter command:

```powershell
Set-Location $HOME
```

PowerShell knows that the first unnamed value belongs to `-Path`.

The explicit equivalent is:

```powershell
Set-Location -Path $HOME
```

Positional arguments are convenient but can become difficult to read when a command has several values. Named parameters are generally clearer for beginners and shared scripts.

### The Implementation

Run the positional form:

```powershell
Set-Location $primerRoot
```

Run the named form:

```powershell
Set-Location -LiteralPath $primerRoot
```

These two content commands also demonstrate positional and named styles:

```powershell
Get-Content .\documents\notes.txt
```

```powershell
Get-Content `
    -LiteralPath .\documents\notes.txt
```

Prefer the second form in scripts because its intent is explicit.

### The Verification

Confirm that both content calls return the same value:

```powershell
$positionalContent = Get-Content `
    .\documents\notes.txt `
    -Raw

$namedContent = Get-Content `
    -LiteralPath .\documents\notes.txt `
    -Raw

$positionalContent -eq $namedContent
```

Expected result:

```text
True
```

---

## P1.8 Understand Variables

### The Target

Store and reuse values with PowerShell variables.

### The Concept

A variable is a labeled container for a value.

PowerShell variable names begin with `$`:

```powershell
$primerRoot
$fileName
$fileCount
```

The equals sign assigns a value:

```powershell
$fileName = "notes.txt"
```

After assignment, `$fileName` retrieves that value.

### The Implementation

Store a string:

```powershell
$fileName = "notes.txt"
```

Display it:

```powershell
$fileName
```

Construct a path:

```powershell
$filePath = Join-Path `
    -Path $documentsPath `
    -ChildPath $fileName
```

Display the path:

```powershell
$filePath
```

Store a file object:

```powershell
$file = Get-Item -LiteralPath $filePath
```

Read its properties:

```powershell
$file.Name
$file.Length
$file.FullName
```

Variables can hold different kinds of values:

```powershell
$textValue = "PowerShell"
$numberValue = 42
$booleanValue = $true
$fileObject = Get-Item -LiteralPath $filePath
```

Inspect their types:

```powershell
$textValue.GetType().FullName
$numberValue.GetType().FullName
$booleanValue.GetType().FullName
$fileObject.GetType().FullName
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    FileNameCorrect = $fileName -eq "notes.txt"
    PathExists = Test-Path `
        -LiteralPath $filePath `
        -PathType Leaf
    ObjectNameCorrect = $file.Name -eq "notes.txt"
    ObjectHasContent = $file.Length -gt 0
}
```

Every value should be `True`.

---

## P1.9 Understand Strings and Quotation Marks

### The Target

Distinguish single-quoted and double-quoted strings.

### The Concept

A **string** is text.

PowerShell supports both:

```powershell
"double-quoted text"
'single-quoted text'
```

The important difference is variable expansion.

Double quotes evaluate variables:

```powershell
$name = "Ada"
"Hello, $name"
```

Result:

```text
Hello, Ada
```

Single quotes preserve the text literally:

```powershell
'Hello, $name'
```

Result:

```text
Hello, $name
```

Use double quotes when PowerShell should insert values. Use single quotes when text should remain literal.

### The Implementation

Run:

```powershell
$language = "PowerShell"

$expandedString = "I am learning $language."
$literalString = 'I am learning $language.'

$expandedString
$literalString
```

Use a subexpression when inserting a property or calculation:

```powershell
$file = Get-Item `
    -LiteralPath "$documentsPath\notes.txt"

"The file is named $($file.Name)."
"The file contains $($file.Length) bytes."
```

Quote paths containing spaces:

```powershell
$pathWithSpaces = Join-Path `
    -Path $primerRoot `
    -ChildPath "example folder"

"$pathWithSpaces"
```

Without quotation marks, spaces can separate command arguments.

### The Verification

Run:

```powershell
[PSCustomObject]@{
    DoubleQuotesExpanded = (
        $expandedString -eq
        "I am learning PowerShell."
    )
    SingleQuotesStayedLiteral = (
        $literalString -eq
        'I am learning $language.'
    )
}
```

Both values should be `True`.

---

## P1.10 Understand Escape Characters

### The Target

Recognize PowerShell’s escape character and common escaped sequences.

### The Concept

PowerShell uses the backtick as its escape character:

```text
`
```

An escape sequence gives the next character a special meaning.

Common examples include:

| Sequence | Meaning |
|---|---|
| `` `n `` | New line |
| `` `t `` | Tab |
| `` `" `` | Literal double quote |
| `` `` ` `` | Literal backtick |

The backtick is easy to overlook, so use it only when necessary.

### The Implementation

Create a string with a new line:

```powershell
"First line`nSecond line"
```

Create tab-separated text:

```powershell
"Name`tLength"
```

Include quotation marks:

```powershell
"He said, `"PowerShell is ready.`""
```

A cleaner alternative is often to switch quote styles:

```powershell
'He said, "PowerShell is ready."'
```

### The Verification

Store and inspect an escaped string:

```powershell
$twoLines = "Alpha`nBeta"

$lines = $twoLines -split "`n"

[PSCustomObject]@{
    LineCount = $lines.Count
    FirstLine = $lines[0]
    SecondLine = $lines[1]
    Passed = (
        $lines.Count -eq 2 -and
        $lines[0] -eq "Alpha" -and
        $lines[1] -eq "Beta"
    )
}
```

`Passed` should be `True`.

---

## P1.11 Understand Arrays and Commas

### The Target

Recognize collections containing several values.

### The Concept

An **array** is an ordered collection.

It is like a tray containing several labeled items:

```powershell
$fileExtensions = @(
    ".txt"
    ".md"
    ".json"
)
```

The `@(...)` syntax explicitly collects output into an array.

Array indexes begin at zero:

```powershell
$fileExtensions[0]
```

returns:

```text
.txt
```

### The Implementation

Create an array:

```powershell
$fileExtensions = @(
    ".txt"
    ".md"
    ".json"
)
```

Display it:

```powershell
$fileExtensions
```

Read individual values:

```powershell
$fileExtensions[0]
$fileExtensions[1]
$fileExtensions[2]
```

Count its values:

```powershell
$fileExtensions.Count
```

Use an array as a parameter value:

```powershell
Get-Item `
    -LiteralPath @(
        "$documentsPath\notes.txt"
        "$documentsPath\project-plan.md"
        "$documentsPath\settings.json"
    ) |
    Select-Object Name, Length
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    CountIsThree = $fileExtensions.Count -eq 3
    FirstIsText = $fileExtensions[0] -eq ".txt"
    LastIsJson = $fileExtensions[-1] -eq ".json"
    ContainsMarkdown = ".md" -in $fileExtensions
}
```

Every value should be `True`.

A negative index counts backward, so:

```powershell
$fileExtensions[-1]
```

returns the final value.

---

## P1.12 Understand Objects and Properties

### The Target

Recognize that PowerShell commands return structured objects.

### The Concept

PowerShell usually passes objects rather than plain text.

A file object can carry properties such as:

```text
Name
Length
Extension
FullName
LastWriteTime
```

A property is a named piece of information attached to an object.

Access a property with a dot:

```powershell
$file.Name
```

This asks the file object for its `Name` property.

### The Implementation

Retrieve one file object:

```powershell
$file = Get-Item `
    -LiteralPath "$documentsPath\settings.json"
```

Display the whole object:

```powershell
$file
```

Read selected properties:

```powershell
$file.Name
$file.Extension
$file.Length
$file.FullName
$file.LastWriteTime
```

Discover the object’s type:

```powershell
$file.GetType().FullName
```

Discover its available members:

```powershell
$file | Get-Member
```

A **member** is a property or method attached to an object.

### The Verification

Run:

```powershell
[PSCustomObject]@{
    IsFileObject = $file -is [System.IO.FileInfo]
    NameIsCorrect = $file.Name -eq "settings.json"
    ExtensionIsJson = $file.Extension -eq ".json"
    HasFullPath = [System.IO.Path]::IsPathRooted(
        $file.FullName
    )
}
```

Every value should be `True`.

---

## P1.13 Understand the Pipeline

### The Target

Read a multi-command pipeline from left to right.

### The Concept

The pipeline operator is:

```text
|
```

It passes output from the command on the left to the command on the right.

Think of a conveyor belt:

```text
Retrieve files
      ↓
Keep JSON files
      ↓
Sort by name
      ↓
Display selected properties
```

In PowerShell:

```powershell
Get-ChildItem -File |
    Where-Object Extension -eq ".json" |
    Sort-Object Name |
    Select-Object Name, Length
```

Objects move through the pipeline—not merely their displayed text.

### The Implementation

Start with all files:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File
```

Send them to `Sort-Object`:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    Sort-Object `
        -Property Name
```

Select only useful properties:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    Sort-Object `
        -Property Name |
    Select-Object `
        -Property Name, Extension, Length
```

Filter before sorting:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    Where-Object {
        $_.Extension -eq ".json"
    } |
    Sort-Object `
        -Property Name |
    Select-Object `
        -Property Name, Length
```

Read the pipeline in stages:

1. `Get-ChildItem` creates file objects.
2. `Where-Object` retains JSON files.
3. `Sort-Object` orders them.
4. `Select-Object` chooses displayed properties.

### The Verification

Store the pipeline result:

```powershell
$jsonReport = @(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File |
        Where-Object {
            $_.Extension -eq ".json"
        } |
        Select-Object Name, Length, FullName
)

[PSCustomObject]@{
    ResultCount = $jsonReport.Count
    CorrectName = $jsonReport.Name -eq "settings.json"
    HasLength = $jsonReport.Length -gt 0
    HasFullPath = -not [string]::IsNullOrWhiteSpace(
        $jsonReport.FullName
    )
}
```

Every check should pass.

---

## P1.14 Understand `$_` and Script Blocks

### The Target

Understand the current pipeline object and brace-delimited script blocks.

### The Concept

A **script block** is PowerShell code enclosed in braces:

```powershell
{
    # Commands go here.
}
```

Many commands accept a script block describing work to perform.

Inside a pipeline-processing script block, `$_` means:

> The current object moving through the pipeline.

For example:

```powershell
Where-Object {
    $_.Length -gt 20
}
```

This means:

> Keep the current object when its `Length` property is greater than 20.

### The Implementation

Find files larger than 20 bytes:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    Where-Object {
        $_.Length -gt 20
    } |
    Select-Object Name, Length
```

Find Markdown or JSON files:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    Where-Object {
        $_.Extension -in @(
            ".md"
            ".json"
        )
    } |
    Select-Object Name, Extension
```

Use `ForEach-Object` to produce a sentence for each file:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    ForEach-Object {
        "File $($_.Name) contains $($_.Length) bytes."
    }
```

### The Verification

Run:

```powershell
$selectedFiles = @(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File |
        Where-Object {
            $_.Extension -in @(
                ".md"
                ".json"
            )
        }
)

[PSCustomObject]@{
    SelectedCount = $selectedFiles.Count
    ContainsMarkdown = (
        ".md" -in $selectedFiles.Extension
    )
    ContainsJson = (
        ".json" -in $selectedFiles.Extension
    )
    ExcludesText = (
        ".txt" -notin $selectedFiles.Extension
    )
}
```

Expected count:

```text
2
```

All Boolean values should be `True`.

---

## P1.15 Understand Comparison and Logical Operators

### The Target

Read conditions used for filtering and decisions.

### The Concept

An **operator** compares or combines values.

Common comparison operators include:

| Operator | Meaning |
|---|---|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-gt` | Greater than |
| `-ge` | Greater than or equal |
| `-lt` | Less than |
| `-le` | Less than or equal |
| `-like` | Matches a wildcard pattern |
| `-match` | Matches a regular expression |
| `-in` | Value appears in a collection |
| `-contains` | Collection contains a value |

Logical operators combine conditions:

| Operator | Meaning |
|---|---|
| `-and` | Both conditions must be true |
| `-or` | At least one condition must be true |
| `-not` | Reverse true and false |
| `!` | Short form of `-not` |

PowerShell uses `-eq`, not `==`, for ordinary equality comparisons.

### The Implementation

Compare strings:

```powershell
"PowerShell" -eq "powershell"
```

PowerShell string comparisons are case-insensitive by default, so the result is:

```text
True
```

Use a case-sensitive comparison:

```powershell
"PowerShell" -ceq "powershell"
```

Expected result:

```text
False
```

Combine conditions:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    Where-Object {
        $_.Length -gt 20 -and
        $_.Extension -ne ".txt"
    } |
    Select-Object Name, Extension, Length
```

Match a wildcard pattern:

```powershell
Get-ChildItem `
    -LiteralPath $documentsPath `
    -File |
    Where-Object {
        $_.Name -like "*.json"
    }
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    EqualityWorks = 5 -eq 5
    InequalityWorks = 5 -ne 6
    GreaterThanWorks = 10 -gt 5
    WildcardWorks = "settings.json" -like "*.json"
    MembershipWorks = ".json" -in @(
        ".txt"
        ".md"
        ".json"
    )
    LogicalAndWorks = (
        10 -gt 5 -and
        10 -lt 20
    )
}
```

Every value should be `True`.

---

## P1.16 Understand Command Grouping with Parentheses

### The Target

Use parentheses to execute an expression first and access its result.

### The Concept

Parentheses control evaluation order:

```powershell
(Get-Location).Path
```

PowerShell:

1. Runs `Get-Location`.
2. Takes the resulting object.
3. Reads its `Path` property.

This resembles ordinary mathematics, where parentheses identify what should be evaluated first.

### The Implementation

Display the current path string:

```powershell
(Get-Location).Path
```

Count files:

```powershell
(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File
).Count
```

Retrieve a file and immediately read its extension:

```powershell
(
    Get-Item `
        -LiteralPath "$documentsPath\settings.json"
).Extension
```

Compare a command result directly:

```powershell
(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File
).Count -eq 3
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    CurrentPathIsString = (
        (Get-Location).Path -is [string]
    )
    FileCountIsThree = (
        Get-ChildItem `
            -LiteralPath $documentsPath `
            -File
    ).Count -eq 3
    JsonExtensionCorrect = (
        Get-Item `
            -LiteralPath "$documentsPath\settings.json"
    ).Extension -eq ".json"
}
```

Every value should be `True`.

---

## P1.17 Understand Hashtables and Custom Objects

### The Target

Recognize key-value collections and structured report objects.

### The Concept

A **hashtable** stores values under named keys:

```powershell
$configuration = @{
    Environment = "development"
    Port = 3000
}
```

Retrieve a value with:

```powershell
$configuration["Port"]
```

A custom object provides named properties:

```powershell
[PSCustomObject]@{
    Environment = "development"
    Port = 3000
}
```

Retrieve a property with:

```powershell
$object.Port
```

Hashtables are useful for lookups and command parameters. Custom objects are useful for reports and pipeline output.

### The Implementation

Create a hashtable:

```powershell
$configuration = @{
    Environment = "development"
    Host = "127.0.0.1"
    Port = 3000
}
```

Read its values:

```powershell
$configuration["Environment"]
$configuration["Port"]
```

Create a custom object:

```powershell
$configurationReport = [PSCustomObject]@{
    Environment = $configuration["Environment"]
    Host = $configuration["Host"]
    Port = $configuration["Port"]
    Ready = $true
}
```

Display it:

```powershell
$configurationReport |
    Format-List
```

Read a property:

```powershell
$configurationReport.Port
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    HashtablePortCorrect = (
        $configuration["Port"] -eq 3000
    )
    ObjectPortCorrect = (
        $configurationReport.Port -eq 3000
    )
    ObjectIsReady = (
        $configurationReport.Ready -eq $true
    )
}
```

Every value should be `True`.

---

## P1.18 Understand Splatting

### The Target

Recognize a hashtable used to supply command parameters.

### The Concept

**Splatting** passes a collection of named parameters to a command.

Without splatting:

```powershell
Get-ChildItem -LiteralPath $documentsPath -File -Recurse
```

With splatting:

```powershell
$parameters = @{
    LiteralPath = $documentsPath
    File = $true
    Recurse = $true
}

Get-ChildItem @parameters
```

Notice the syntax:

- `$parameters` retrieves the hashtable as a value.
- `@parameters` splats its keys into command parameters.

Splatting makes long commands easier to construct and conditionally modify.

### The Implementation

Create a parameter hashtable:

```powershell
$childItemParameters = @{
    LiteralPath = $documentsPath
    File = $true
    Recurse = $true
    ErrorAction = "Stop"
}
```

Run the command:

```powershell
Get-ChildItem @childItemParameters |
    Select-Object Name, Extension, Length
```

Add another parameter conditionally:

```powershell
$includeHidden = $true

if ($includeHidden) {
    $childItemParameters.Force = $true
}

Get-ChildItem @childItemParameters
```

### The Verification

Compare normal and splatted results:

```powershell
$normalResults = @(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File `
        -Recurse `
        -Force `
        -ErrorAction Stop
)

$splattedResults = @(
    Get-ChildItem @childItemParameters
)

[PSCustomObject]@{
    CountsMatch = (
        $normalResults.Count -eq
        $splattedResults.Count
    )
    NamesMatch = (
        ($normalResults.Name | Sort-Object) -join "," -eq
        ($splattedResults.Name | Sort-Object) -join ","
    )
}
```

Both values should be `True`.

---

## P1.19 Understand Comments

### The Target

Distinguish executable commands from explanatory comments.

### The Concept

A comment is text for humans that PowerShell does not execute.

A single-line comment begins with:

```text
#
```

A block comment uses:

```text
<#
...
#>
```

Comments should explain why a command exists, especially when the reason is not obvious.

### The Implementation

Run:

```powershell
# This command displays the current location.
Get-Location
```

Use an inline comment:

```powershell
$fileCount = 3 # Expected number of primer files.
```

Use a block comment:

```powershell
<#
This block explains several lines of code.
PowerShell ignores everything until the closing marker.
#>

Get-ChildItem -LiteralPath $documentsPath
```

Avoid comments that merely repeat obvious syntax:

```powershell
# Bad: Set the variable to 3000.
$port = 3000
```

A more useful comment explains intent:

```powershell
# Use an unprivileged development port to avoid administrator requirements.
$port = 3000
```

### The Verification

Confirm comments did not change the value:

```powershell
$commentDemo = "unchanged" # PowerShell ignores this comment.

$commentDemo -eq "unchanged"
```

Expected result:

```text
True
```

---

## P1.20 Read Multiline Commands

### The Target

Understand how one logical command can span several physical lines.

### The Concept

Long commands are easier to read when formatted vertically.

PowerShell naturally continues after certain incomplete syntax, including:

- A pipeline operator
- An open parenthesis
- An open brace
- An open array expression
- A comma in a list

PowerShell also supports the backtick as an explicit continuation character, but it is fragile because trailing spaces after it can break continuation.

### The Implementation

This pipeline naturally spans lines because each pipeline operator indicates that another command follows:

```powershell
Get-ChildItem -LiteralPath $documentsPath -File |
    Where-Object {
        $_.Length -gt 0
    } |
    Sort-Object -Property Name |
    Select-Object Name, Length
```

This array naturally spans lines:

```powershell
$names = @(
    "notes.txt"
    "project-plan.md"
    "settings.json"
)
```

This parenthesized expression naturally spans lines:

```powershell
$fileCount = (
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File
).Count
```

The previous example uses backticks for parameter-line continuation. A less fragile alternative is splatting:

```powershell
$parameters = @{
    LiteralPath = $documentsPath
    File = $true
}

$fileCount = (
    Get-ChildItem @parameters
).Count
```

### The Verification

Confirm both forms produce the same count:

```powershell
$backtickCount = (
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File
).Count

$splatParameters = @{
    LiteralPath = $documentsPath
    File = $true
}

$splattedCount = (
    Get-ChildItem @splatParameters
).Count

[PSCustomObject]@{
    BacktickCount = $backtickCount
    SplattedCount = $splattedCount
    CountsMatch = $backtickCount -eq $splattedCount
}
```

Expected result:

```text
BacktickCount : 3
SplattedCount : 3
CountsMatch   : True
```

---

## P1.21 Distinguish Code, Output, and Prompt Text

### The Target

Know which text should be typed into PowerShell.

### The Concept

Tutorials often display three different kinds of text:

1. Commands you should type
2. Output produced by commands
3. Prompt text displayed by the shell

A prompt may resemble:

```text
PS C:\Users\Ada>
```

Do not type the prompt itself.

If a tutorial shows:

```text
PS C:\Users\Ada> Get-Location
```

type only:

```powershell
Get-Location
```

Output is also not a follow-up command unless explicitly instructed.

### The Implementation

Type this command:

```powershell
Get-Location
```

PowerShell may display:

```text
Path
----
C:\Users\YourName\powershell-reading-primer
```

Do not copy `Path`, the dashed line, or the returned location back into the terminal as commands.

Run:

```powershell
Write-Output "This line is output, not another command."
```

### The Verification

Use an unmistakable marker:

```powershell
Write-Host "COMMAND COMPLETED" -ForegroundColor Green
```

The words `COMMAND COMPLETED` are output. You do not need to type them again.

---

## P1.22 Understand Success Output, Warnings, and Errors

### The Target

Recognize different kinds of PowerShell messages.

### The Concept

PowerShell has several output streams.

The most important for beginners are:

| Stream | Purpose |
|---|---|
| Success | Ordinary data returned by commands |
| Error | Failures |
| Warning | Important caution |
| Verbose | Additional diagnostic details |
| Information | Informational messages |

This distinction matters because ordinary output can move through a pipeline, while warnings and errors communicate different conditions.

### The Implementation

Write ordinary output:

```powershell
Write-Output "ordinary output"
```

Write a warning:

```powershell
Write-Warning "This is a training warning."
```

Write a verbose message:

```powershell
Write-Verbose `
    "This appears because -Verbose was supplied." `
    -Verbose
```

Write an error without stopping the session:

```powershell
Write-Error `
    "This is a controlled training error." `
    -ErrorAction Continue
```

Create a terminating error and catch it:

```powershell
try {
    Get-Item `
        -LiteralPath "$primerRoot\missing-file.txt" `
        -ErrorAction Stop
}
catch {
    Write-Host "The missing file was handled safely." `
        -ForegroundColor Yellow

    Write-Host "Message: $($_.Exception.Message)"
}
```

### The Verification

Run a controlled success/failure test:

```powershell
$errorWasCaught = $false

try {
    Get-Item `
        -LiteralPath "$primerRoot\missing-file.txt" `
        -ErrorAction Stop
}
catch {
    $errorWasCaught = $true
}

$errorWasCaught
```

Expected result:

```text
True
```

---

## P1.23 Understand Semicolons and Multiple Commands

### The Target

Recognize when several commands are written on one line.

### The Concept

A semicolon separates PowerShell statements:

```powershell
$first = 1; $second = 2
```

This is valid, but placing each command on its own line is usually easier to read.

Unlike a pipeline, a semicolon does not pass objects between commands. It simply separates instructions.

### The Implementation

Run two commands on one line:

```powershell
$firstNumber = 10; $secondNumber = 20
```

Calculate their sum:

```powershell
$total = $firstNumber + $secondNumber
$total
```

The more readable form is:

```powershell
$firstNumber = 10
$secondNumber = 20
$total = $firstNumber + $secondNumber

$total
```

Compare this with a pipeline:

```powershell
Get-ChildItem -LiteralPath $documentsPath -File |
    Select-Object Name
```

The pipeline passes file objects into `Select-Object`; a semicolon would not.

### The Verification

Run:

```powershell
[PSCustomObject]@{
    FirstNumber = $firstNumber
    SecondNumber = $secondNumber
    Total = $total
    Passed = $total -eq 30
}
```

`Passed` should be `True`.

---

## P1.24 Use Built-In Help

### The Target

Learn how to investigate an unfamiliar command without guessing.

### The Concept

You do not need to memorize every PowerShell command.

Use:

- `Get-Command` to discover commands
- `Get-Help` to learn syntax and parameters
- `Get-Member` to inspect returned objects

These tools form PowerShell’s built-in learning system.

### The Implementation

Find commands related to child items:

```powershell
Get-Command -Name "*ChildItem*"
```

Read general help:

```powershell
Get-Help -Name Get-ChildItem
```

Read examples:

```powershell
Get-Help `
    -Name Get-ChildItem `
    -Examples
```

Read detailed help:

```powershell
Get-Help `
    -Name Get-ChildItem `
    -Detailed
```

Read help for one parameter:

```powershell
Get-Help `
    -Name Get-ChildItem `
    -Parameter Recurse
```

Open online documentation:

```powershell
Get-Help `
    -Name Get-ChildItem `
    -Online
```

Inspect a file object:

```powershell
Get-Item `
    -LiteralPath "$documentsPath\notes.txt" |
    Get-Member
```

### The Verification

Confirm that help recognizes the command:

```powershell
$help = Get-Help -Name Get-ChildItem

[PSCustomObject]@{
    HelpWasFound = $null -ne $help
    CorrectCommand = $help.Name -eq "Get-ChildItem"
}
```

Both values should be `True`.

---

## P1.25 Deconstruct a Complete Command

### The Target

Read and explain a realistic PowerShell pipeline one component at a time.

### The Concept

Consider:

```powershell
Get-ChildItem -LiteralPath $documentsPath -File |
    Where-Object { $_.Length -gt 20 } |
    Sort-Object -Property Length -Descending |
    Select-Object -Property Name, Extension, Length
```

Its anatomy is:

```text
Get-ChildItem
└─ Retrieve child-item objects.

-LiteralPath $documentsPath
└─ Read the exact directory path stored in the variable.

-File
└─ Return only files.

|
└─ Pass those file objects to the next command.

Where-Object
└─ Filter the incoming objects.

{ $_.Length -gt 20 }
├─ { ... } creates a script block.
├─ $_ means the current file.
├─ .Length reads its byte length.
└─ -gt 20 retains files larger than 20 bytes.

|
└─ Pass the surviving objects onward.

Sort-Object -Property Length -Descending
├─ Sort using the Length property.
└─ Put larger values first.

|
└─ Pass the sorted objects onward.

Select-Object -Property Name, Extension, Length
└─ Produce output with only these properties.
```

### The Implementation

Run each stage separately.

Stage 1:

```powershell
$allFiles = @(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File
)

$allFiles
```

Stage 2:

```powershell
$largeFiles = @(
    $allFiles |
        Where-Object {
            $_.Length -gt 20
        }
)

$largeFiles
```

Stage 3:

```powershell
$sortedFiles = @(
    $largeFiles |
        Sort-Object `
            -Property Length `
            -Descending
)

$sortedFiles
```

Stage 4:

```powershell
$report = @(
    $sortedFiles |
        Select-Object `
            -Property Name, Extension, Length
)

$report |
    Format-Table -AutoSize
```

Now run the combined pipeline:

```powershell
$combinedReport = @(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File |
        Where-Object {
            $_.Length -gt 20
        } |
        Sort-Object `
            -Property Length `
            -Descending |
        Select-Object `
            -Property Name, Extension, Length
)
```

### The Verification

Compare the staged and combined reports:

```powershell
$stagedJson = $report |
    ConvertTo-Json -Compress

$combinedJson = $combinedReport |
    ConvertTo-Json -Compress

[PSCustomObject]@{
    CountsMatch = $report.Count -eq $combinedReport.Count
    ResultsMatch = $stagedJson -eq $combinedJson
}
```

Both values should be `True`.

---

## P1.26 Read a Small Conditional Script

### The Target

Understand variables, conditions, command calls, and output in one complete example.

### The Concept

An `if` statement chooses what to do based on a Boolean condition:

```powershell
if (condition) {
    # Run when true.
}
else {
    # Run when false.
}
```

Think of it as a checkpoint:

> If the path exists, inspect it. Otherwise, report the problem.

### The Implementation

Run:

```powershell
$targetFile = Join-Path `
    -Path $documentsPath `
    -ChildPath "settings.json"

if (
    Test-Path `
        -LiteralPath $targetFile `
        -PathType Leaf
) {
    $item = Get-Item `
        -LiteralPath $targetFile `
        -ErrorAction Stop

    Write-Host "File found." -ForegroundColor Green

    [PSCustomObject]@{
        Name = $item.Name
        Extension = $item.Extension
        Length = $item.Length
        FullName = $item.FullName
    }
}
else {
    Write-Warning "File not found: $targetFile"
}
```

Read it in order:

1. Store the expected path.
2. Ask whether it exists and is a file.
3. If true, retrieve the file.
4. Display a success message.
5. Return a structured report.
6. Otherwise, display a warning.

### The Verification

Confirm the true branch was appropriate:

```powershell
[PSCustomObject]@{
    TargetExists = Test-Path `
        -LiteralPath $targetFile `
        -PathType Leaf
    CorrectName = (
        Get-Item -LiteralPath $targetFile
    ).Name -eq "settings.json"
}
```

Both values should be `True`.

---

# Primer 1 Reference: Symbol Guide

| Syntax | Meaning |
|---|---|
| `Get-ChildItem` | Command name |
| `-Path` | Named parameter |
| `-File` | Switch parameter |
| `$name` | Variable |
| `"text"` | Expandable string |
| `'text'` | Literal string |
| `|` | Pipeline |
| `.` | Property/member access when used as `$object.Name` |
| `.` | Current directory when used as a path |
| `..` | Parent directory |
| `.\src` | `src` beneath the current directory |
| `@(...)` | Array expression |
| `@{...}` | Hashtable |
| `[PSCustomObject]@{...}` | Custom structured object |
| `{...}` | Script block |
| `$_` | Current pipeline object |
| `(...)` | Group and evaluate an expression |
| `#` | Single-line comment |
| `<# ... #>` | Block comment |
| `` ` `` | Escape or explicit continuation character |
| `;` | Statement separator |
| `-eq` | Equal |
| `-gt` | Greater than |
| `-and` | Logical AND |
| `-not` | Logical negation |
| `@parameters` | Splat a parameter hashtable |
| `& $scriptPath` | Execute a command or script stored in a variable |
| `. $profilePath` | Dot-source a script into the current scope |

---

# Primer 1 Reference: How to Read Any Command

When you encounter an unfamiliar PowerShell command, ask these questions in order.

## 1. What commands are being invoked?

Look for command names:

```powershell
Get-ChildItem
Where-Object
Sort-Object
Select-Object
```

## 2. Are any names aliases?

Check:

```powershell
Get-Command -Name ls
Get-Alias -Name ls
```

## 3. Which parameters belong to each command?

Parameters start with hyphens:

```text
-LiteralPath
-File
-Property
-Descending
```

## 4. Which values belong to those parameters?

Examples:

```text
$documentsPath
Length
Name, Extension, Length
```

## 5. Which options are switches?

Examples:

```text
-File
-Recurse
-Force
-Descending
```

## 6. Where are objects passed through a pipeline?

Look for:

```text
|
```

Read pipeline stages from left to right.

## 7. What does `$_` represent?

Inside a pipeline script block, it is the current incoming object:

```powershell
Where-Object {
    $_.Length -gt 20
}
```

## 8. Which object properties are being accessed?

Look for member-access dots:

```powershell
$_.Length
$file.Name
(Get-Location).Path
```

## 9. What conditions are tested?

Look for operators:

```text
-eq
-ne
-gt
-like
-in
-and
-or
```

## 10. What should the command change?

Before running an unfamiliar command, identify whether it only reads state or changes state.

Common read commands:

```text
Get-Location
Get-ChildItem
Get-Item
Get-Content
Test-Path
```

Common state-changing commands:

```text
Set-Content
New-Item
Copy-Item
Move-Item
Rename-Item
Remove-Item
```

Use extra caution with state-changing commands, especially `Remove-Item`.

---

# Primer 1 Common Reading Mistakes

## Mistake 1: Typing the prompt

Do not type:

```text
PS C:\Users\Ada>
```

Type only the command after it.

## Mistake 2: Treating output as another command

If PowerShell displays:

```text
True
```

that is a result, not an instruction to type `True`.

## Mistake 3: Assuming every hyphenated word is a separate command

In:

```powershell
Get-ChildItem -File -Recurse
```

only `Get-ChildItem` is the command. `-File` and `-Recurse` are parameters.

## Mistake 4: Assuming `ls` uses UNIX options

In PowerShell:

```powershell
ls
```

normally resolves to:

```powershell
Get-ChildItem
```

Use PowerShell parameters:

```powershell
Get-ChildItem -Force
```

rather than assuming Bash syntax applies.

## Mistake 5: Confusing `|` with `;`

This passes objects:

```powershell
Get-ChildItem |
    Select-Object Name
```

This merely separates commands:

```powershell
Get-ChildItem; Get-Location
```

## Mistake 6: Confusing `$variable.Property` with part of the variable name

In:

```powershell
$file.Name
```

- `$file` is the variable.
- `.Name` accesses a property on its object.

## Mistake 7: Expecting single quotes to expand variables

This expands:

```powershell
"Location: $primerRoot"
```

This does not:

```powershell
'Location: $primerRoot'
```

## Mistake 8: Reading `$_` as random punctuation

Inside pipeline script blocks:

```powershell
$_
```

means the current object.

## Mistake 9: Formatting too early

Use:

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 20
    } |
    Format-Table Name, Length
```

Do not place `Format-Table` before filtering. Formatting commands are for final presentation.

## Mistake 10: Running a destructive command before understanding it

Do not run this merely because it appears in an example:

```powershell
Remove-Item -Recurse -Force
```

First identify:

- Its exact path
- Whether it uses wildcards
- Whether recursion is enabled
- Whether `-WhatIf` is available

Filesystem safety is covered in the next primer.

---

# Primer 1 Readiness Challenge

## The Target

Read and execute a complete pipeline that generates a file report.

### The Concept

The challenge combines:

- A variable
- A path
- A cmdlet
- Named parameters
- Switch parameters
- A pipeline
- A script block
- `$_`
- A comparison
- Sorting
- Property selection
- A custom verification object

### The Implementation

Run:

```powershell
$primerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "powershell-reading-primer"

$documentsPath = Join-Path `
    -Path $primerRoot `
    -ChildPath "documents"

$readinessReport = @(
    Get-ChildItem `
        -LiteralPath $documentsPath `
        -File |
        Where-Object {
            $_.Length -gt 0
        } |
        Sort-Object `
            -Property Name |
        Select-Object `
            -Property Name, Extension, Length, FullName
)

$readinessReport |
    Format-Table -AutoSize
```

Explain it in plain language:

1. `$primerRoot` stores the laboratory’s path.
2. `$documentsPath` stores the documents path.
3. `Get-ChildItem` retrieves exact child items.
4. `-File` excludes directories.
5. `|` passes file objects into `Where-Object`.
6. `$_` represents each current file.
7. `-gt 0` keeps nonempty files.
8. `Sort-Object` orders files by name.
9. `Select-Object` creates the final report properties.
10. `@(...)` ensures the result is collected as an array.
11. `Format-Table` displays the completed report.

### The Verification

Run:

```powershell
$readinessChecks = [PSCustomObject]@{
    ReportContainsThreeFiles = (
        $readinessReport.Count -eq 3
    )
    EveryFileHasContent = @(
        $readinessReport |
            Where-Object {
                $_.Length -le 0
            }
    ).Count -eq 0
    NotesFileIncluded = (
        "notes.txt" -in $readinessReport.Name
    )
    MarkdownFileIncluded = (
        "project-plan.md" -in $readinessReport.Name
    )
    JsonFileIncluded = (
        "settings.json" -in $readinessReport.Name
    )
    EveryPathIsAbsolute = @(
        $readinessReport |
            Where-Object {
                -not [System.IO.Path]::IsPathRooted(
                    $_.FullName
                )
            }
    ).Count -eq 0
}

$readinessChecks |
    Format-List
```

Determine whether every check passed:

```powershell
$failedReadinessChecks = @(
    $readinessChecks.PSObject.Properties |
        Where-Object {
            $_.Value -ne $true
        }
)

if ($failedReadinessChecks.Count -eq 0) {
    Write-Host "Primer 1 readiness check passed." `
        -ForegroundColor Green
}
else {
    $failedReadinessChecks |
        Select-Object Name, Value |
        Format-Table -AutoSize

    throw "Primer 1 readiness check failed."
}
```

Expected message:

```text
Primer 1 readiness check passed.
```

---

# Primer 1 Key Takeaways

A PowerShell command can be read as a collection of predictable parts:

```powershell
Get-ChildItem -LiteralPath $documentsPath -File
```

```text
Get-ChildItem    → command
-LiteralPath     → named parameter
$documentsPath   → parameter value stored in a variable
-File            → switch parameter
```

A pipeline passes objects from one command to another:

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 0
    } |
    Select-Object Name, Length
```

Inside a pipeline script block:

```powershell
$_
```

means the current object.

Properties are accessed with a dot:

```powershell
$file.Name
$file.Length
$_.Extension
```

Variables begin with `$`:

```powershell
$projectRoot
$fileCount
```

Double-quoted strings expand variables:

```powershell
"Project: $projectRoot"
```

Single-quoted strings preserve them literally:

```powershell
'Project: $projectRoot'
```

When a command is unfamiliar, investigate it instead of guessing:

```powershell
Get-Command -Name Get-ChildItem
Get-Help -Name Get-ChildItem -Examples
Get-Help -Name Get-ChildItem -Parameter Recurse
```

Most importantly, read commands from the inside out and from left to right:

1. Identify each command.
2. Identify its parameters.
3. Match parameters with their values.
4. Find pipeline boundaries.
5. Identify the objects being passed.
6. Read script-block conditions.
7. Determine whether the command reads or changes state.
8. Verify the result after execution.
