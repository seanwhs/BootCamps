# Part 6: Python CLI Development with PowerShell (Bonus)

Python is widely used for automation, data processing, web development, testing, artificial intelligence, and command-line applications.

In this part, you will use PowerShell to create a production-conscious Python command-line application named `devtasks`.

The completed CLI will support:

```text
devtasks add "Write documentation"
devtasks list
devtasks complete 1
devtasks remove 1
devtasks clear --completed
devtasks config
```

You will learn how to:

- Install and discover Python on Windows
- Distinguish `python`, `py`, `pip`, and `python -m pip`
- Select a Python interpreter safely
- Create an isolated virtual environment
- Understand interpreter and package resolution
- Create a modern `pyproject.toml`
- Use a `src` project layout
- Build a complete CLI with `argparse`
- Store data safely in JSON
- Use atomic file replacement
- Handle user input and errors
- Define an installable console command
- Write automated tests with `unittest`
- Run formatting and linting with Ruff
- Build wheel and source distributions
- Install and test the built wheel
- Manage Python environment variables from PowerShell
- Add optional PowerShell profile shortcuts

The completed architecture will be:

```text
$HOME/
└── cli-developer-environment-series/
    └── python-developer-cli/
        ├── .venv/
        ├── dist/
        ├── src/
        │   └── devtasks/
        │       ├── __init__.py
        │       ├── __main__.py
        │       ├── cli.py
        │       ├── models.py
        │       └── storage.py
        ├── tests/
        │   ├── __init__.py
        │   ├── test_cli.py
        │   └── test_storage.py
        ├── .gitignore
        ├── pyproject.toml
        └── README.md
```

The runtime data will be stored outside the source tree:

```text
$HOME/
└── .devtasks/
    └── tasks.json
```

Tests will use temporary directories instead of modifying the real task database.

---

## 6.1 Discover Python on Windows

### The Target

Determine whether Python and the Windows Python launcher are available.

### The Concept

On Windows, several commands may appear to mean “run Python”:

```text
python
python3
py
```

They are not always the same executable.

The Windows Python launcher, `py`, can discover installed Python versions. The `python` command runs whichever interpreter Windows finds first through command resolution.

Think of `py` as a dispatcher that can choose among installed interpreters, while `python` is a direct doorway to one interpreter.

### The Implementation

Ask PowerShell which commands are available:

```powershell
$pythonCommands = @(
    "python"
    "python3"
    "py"
)

$pythonDiscovery = foreach ($commandName in $pythonCommands) {
    $commands = @(
        Get-Command `
            -Name $commandName `
            -All `
            -ErrorAction SilentlyContinue
    )

    if ($commands.Count -eq 0) {
        [PSCustomObject]@{
            Command = $commandName
            Available = $false
            CommandType = "[not found]"
            Source = "[not found]"
        }

        continue
    }

    foreach ($command in $commands) {
        [PSCustomObject]@{
            Command = $commandName
            Available = $true
            CommandType = $command.CommandType
            Source = $command.Source
        }
    }
}

$pythonDiscovery |
    Format-Table -AutoSize
```

Check the Python launcher:

```powershell
if (Get-Command py -ErrorAction SilentlyContinue) {
    py --version
    py --list
}
```

Check the direct Python command:

```powershell
if (Get-Command python -ErrorAction SilentlyContinue) {
    python --version
}
```

Check the executable used by `python`:

```powershell
if (Get-Command python -ErrorAction SilentlyContinue) {
    python -c "import sys; print(sys.executable)"
}
```

### The Verification

Run this interpreter check:

```powershell
$pythonReady = $false
$pythonInvocation = $null

if (Get-Command py -ErrorAction SilentlyContinue) {
    try {
        py -3 -c "import sys; print(sys.version)"
        $pythonReady = $LASTEXITCODE -eq 0

        if ($pythonReady) {
            $pythonInvocation = "py -3"
        }
    }
    catch {
        $pythonReady = $false
    }
}

if (
    -not $pythonReady -and
    (Get-Command python -ErrorAction SilentlyContinue)
) {
    python -c "import sys; print(sys.version)"
    $pythonReady = $LASTEXITCODE -eq 0

    if ($pythonReady) {
        $pythonInvocation = "python"
    }
}

if (-not $pythonReady) {
    Write-Host "A working Python 3 interpreter was not found." `
        -ForegroundColor Yellow
}
else {
    Write-Host "Python is ready through: $pythonInvocation" `
        -ForegroundColor Green
}
```

---

## 6.2 Install Python When It Is Missing

### The Target

Install a supported Python 3 release if no working interpreter is available.

### The Concept

Python versions use:

```text
major.minor.patch
```

For example:

```text
3.13.2
```

This tutorial requires Python 3.11 or later.

For real projects, select a version supported by:

- Your application
- Your dependencies
- Your deployment platform
- Your organization’s security lifecycle

### The Implementation

If Python is missing and WinGet is available, search for current Python packages:

```powershell
winget search `
    --source winget `
    --name Python
```

Install an approved Python 3 release using the package identifier shown by WinGet. For example, if your selected release is Python 3.13:

```powershell
winget install `
    --id Python.Python.3.13 `
    --source winget `
    --accept-package-agreements `
    --accept-source-agreements
```

Package identifiers and supported releases change. Confirm the identifier through `winget search` before installation.

Alternatively, use the official installer:

```text
https://www.python.org/downloads/windows/
```

When using the installer:

- Install for your normal user unless organizational policy says otherwise.
- Retain the Python launcher option.
- Add Python to `PATH` if appropriate for your environment.
- Do not install an obsolete release merely to match an old tutorial.

After installation, close all existing terminals and open a new PowerShell session.

### The Verification

Run:

```powershell
py --version
py -3 -c "import sys; print(sys.executable)"
py -3 -c "import sys; print(sys.version_info)"
```

Verify the minimum version:

```powershell
py -3 -c @'
import sys

minimum = (3, 11)

if sys.version_info < minimum:
    raise SystemExit(
        f"Python {minimum[0]}.{minimum[1]} or later is required; "
        f"received {sys.version.split()[0]}"
    )

print(f"Python version is supported: {sys.version.split()[0]}")
'@
```

Expected output resembles:

```text
Python version is supported: 3.13.2
```

---

## 6.3 Understand `python`, `py`, `pip`, and `python -m pip`

### The Target

Understand the roles of Python’s interpreter and package-management commands.

### The Concept

The commands have different responsibilities:

| Command | Responsibility |
|---|---|
| `python` | Run a selected Python interpreter |
| `py` | Select and launch an installed Python on Windows |
| `pip` | Run whichever pip executable PowerShell resolves |
| `python -m pip` | Run pip through a specific Python interpreter |

The safest package command is usually:

```powershell
python -m pip
```

That explicitly means:

> Use this Python interpreter to execute its pip module.

A bare `pip` command might belong to another installation.

### The Implementation

Inspect command resolution:

```powershell
Get-Command python -All -ErrorAction SilentlyContinue |
    Select-Object Name, CommandType, Source

Get-Command py -All -ErrorAction SilentlyContinue |
    Select-Object Name, CommandType, Source

Get-Command pip -All -ErrorAction SilentlyContinue |
    Select-Object Name, CommandType, Source
```

Inspect pip through the launcher-selected interpreter:

```powershell
py -3 -m pip --version
```

If `python` is available:

```powershell
python -m pip --version
```

Display the relationship between Python and pip:

```powershell
py -3 -c "import sys; print(f'Interpreter: {sys.executable}')"
py -3 -m pip --version
```

### The Verification

Run:

```powershell
$interpreterPath = py -3 -c "import sys; print(sys.executable)"
$pipDescription = py -3 -m pip --version

[PSCustomObject]@{
    Interpreter = $interpreterPath
    PipDescription = $pipDescription
    PythonSucceeded = -not [string]::IsNullOrWhiteSpace(
        $interpreterPath
    )
    PipSucceeded = -not [string]::IsNullOrWhiteSpace(
        $pipDescription
    )
}
```

Both success values should be `True`.

---

## 6.4 Create the Python Project Directory

### The Target

Create:

```text
$HOME\cli-developer-environment-series\python-developer-cli
```

### The Concept

The project needs a dedicated root containing source, tests, packaging metadata, and an isolated Python environment.

Keeping those resources together makes the project reproducible and easier to inspect.

### The Implementation

Construct the paths:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$pythonProjectRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "python-developer-cli"
```

Create them when missing:

```powershell
foreach ($directory in @(
    $seriesRoot
    $pythonProjectRoot
)) {
    if (-not (
        Test-Path `
            -LiteralPath $directory `
            -PathType Container
    )) {
        $null = New-Item `
            -Path $directory `
            -ItemType Directory `
            -ErrorAction Stop
    }
}
```

Enter the project:

```powershell
Set-Location -LiteralPath $pythonProjectRoot
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    ProjectExists = Test-Path `
        -LiteralPath $pythonProjectRoot `
        -PathType Container
    CurrentLocationMatches = (
        (Get-Location).Path -eq $pythonProjectRoot
    )
}
```

Both values should be `True`.

---

## 6.5 Create a Virtual Environment

### The Target

Create an isolated Python environment at:

```text
python-developer-cli\.venv
```

### The Concept

A **virtual environment** is a project-local Python environment.

It isolates installed packages from:

- The system Python
- Other Python projects
- Globally installed tools

Think of it as a dedicated toolbox. Two projects can use different package versions without rearranging each other’s tools.

A virtual environment does not contain a completely independent copy of every Python component, but it provides an isolated package installation context and project-specific command directory.

### The Implementation

Ensure you are in the project:

```powershell
Set-Location -LiteralPath $pythonProjectRoot
```

Create the environment:

```powershell
py -3 -m venv .venv
```

The important Windows paths are:

```text
.venv\Scripts\python.exe
.venv\Scripts\pip.exe
.venv\Scripts\Activate.ps1
```

Inspect them:

```powershell
Get-ChildItem `
    -LiteralPath .\.venv\Scripts |
    Sort-Object Name |
    Select-Object Name, Length
```

### The Verification

Run the environment’s interpreter directly:

```powershell
.\.venv\Scripts\python.exe `
    -c "import sys; print(sys.executable)"
```

Confirm isolation:

```powershell
$venvPython = (
    Resolve-Path `
        -LiteralPath .\.venv\Scripts\python.exe
).Path

$reportedPython = .\.venv\Scripts\python.exe `
    -c "import sys; print(sys.executable)"

[PSCustomObject]@{
    EnvironmentExists = Test-Path `
        -LiteralPath .\.venv `
        -PathType Container
    InterpreterExists = Test-Path `
        -LiteralPath $venvPython `
        -PathType Leaf
    InterpreterMatches = (
        [System.IO.Path]::GetFullPath($reportedPython) -eq
        [System.IO.Path]::GetFullPath($venvPython)
    )
}
```

Every value should be `True`.

---

## 6.6 Activate the Virtual Environment

### The Target

Activate `.venv` in the current PowerShell session and understand what activation changes.

### The Concept

Activation does not start a special Python mode. It modifies the current shell environment so project-local commands are found first.

It primarily:

- Adds `.venv\Scripts` to the beginning of `PATH`
- Sets `VIRTUAL_ENV`
- Updates the interactive prompt

You can always avoid activation and call the interpreter explicitly:

```powershell
.\.venv\Scripts\python.exe
```

Explicit paths are often clearer in automation.

### The Implementation

Activate the environment:

```powershell
.\.venv\Scripts\Activate.ps1
```

If PowerShell blocks the activation script, do not weaken policy globally. You can continue by calling:

```powershell
.\.venv\Scripts\python.exe
```

and:

```powershell
.\.venv\Scripts\python.exe -m pip
```

After activation, inspect command resolution:

```powershell
Get-Command python |
    Select-Object Name, CommandType, Source

Get-Command pip |
    Select-Object Name, CommandType, Source
```

Inspect the environment variable:

```powershell
$env:VIRTUAL_ENV
```

Check the active interpreter:

```powershell
python -c "import sys; print(sys.executable)"
```

### The Verification

Run:

```powershell
$expectedEnvironment = (
    Resolve-Path -LiteralPath .\.venv
).Path

$activeInterpreter = python -c "import sys; print(sys.executable)"

[PSCustomObject]@{
    VirtualEnvironmentVariableMatches = (
        [System.IO.Path]::GetFullPath($env:VIRTUAL_ENV) -eq
        [System.IO.Path]::GetFullPath($expectedEnvironment)
    )
    ActiveInterpreterIsInsideVenv = (
        [System.IO.Path]::GetFullPath($activeInterpreter)
    ).StartsWith(
        [System.IO.Path]::GetFullPath($expectedEnvironment),
        [System.StringComparison]::OrdinalIgnoreCase
    )
}
```

Both values should be `True`.

To leave the environment later, run:

```powershell
deactivate
```

Keep it active for the remaining steps.

---

## 6.7 Upgrade Core Packaging Tools

### The Target

Update pip in the virtual environment and install the project’s development tools.

### The Concept

Python packaging uses several tools:

| Tool | Purpose |
|---|---|
| pip | Install packages |
| setuptools | Build and install many Python projects |
| wheel | Support wheel distributions |
| build | Build source and wheel distributions |
| Ruff | Format and lint Python code |

A **wheel** is a built Python package archive. It normally installs faster than rebuilding from source.

### The Implementation

Confirm the active interpreter:

```powershell
python -c "import sys; print(sys.executable)"
```

Upgrade pip:

```powershell
python -m pip install --upgrade pip
```

Install build and quality tools:

```powershell
python -m pip install `
    build `
    ruff
```

Inspect installed versions:

```powershell
python -m pip --version
python -m build --version
python -m ruff --version
```

### The Verification

Run:

```powershell
$requiredModules = @(
    "build"
    "ruff"
)

$moduleChecks = foreach ($moduleName in $requiredModules) {
    python -c "import importlib.util; raise SystemExit(0 if importlib.util.find_spec('$moduleName') else 1)"

    [PSCustomObject]@{
        Module = $moduleName
        Available = $LASTEXITCODE -eq 0
    }
}

$moduleChecks |
    Format-Table -AutoSize
```

Every `Available` value should be `True`.

---

## 6.8 Create the Python Project Structure

### The Target

Create source and test directories using the `src` layout.

### The Concept

A `src` layout places the installable package beneath:

```text
src/
```

This helps tests exercise the installed package instead of accidentally importing source from the current directory.

The package directory will be:

```text
src\devtasks
```

A Python package is a directory containing importable Python modules.

### The Implementation

Create the directories:

```powershell
$projectDirectories = @(
    "$pythonProjectRoot\src\devtasks"
    "$pythonProjectRoot\tests"
)

foreach ($directory in $projectDirectories) {
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
```

Create package marker files:

```powershell
Set-Content `
    -LiteralPath "$pythonProjectRoot\src\devtasks\__init__.py" `
    -Value @'
"""Developer task CLI package."""

__version__ = "1.0.0"
'@ `
    -Encoding UTF8

Set-Content `
    -LiteralPath "$pythonProjectRoot\tests\__init__.py" `
    -Value '"""Automated tests for devtasks."""' `
    -Encoding UTF8
```

### The Verification

Run:

```powershell
Get-ChildItem `
    -LiteralPath $pythonProjectRoot `
    -Recurse |
    Where-Object {
        $_.FullName -notlike "$pythonProjectRoot\.venv\*"
    } |
    Select-Object FullName
```

Confirm the package marker:

```powershell
Test-Path `
    -LiteralPath .\src\devtasks\__init__.py `
    -PathType Leaf
```

Expected result:

```text
True
```

---

## 6.9 Create `pyproject.toml`

### The Target

Create the project’s packaging, command, formatting, and test metadata.

### The Concept

`pyproject.toml` is the modern central configuration file for Python projects.

It can declare:

- The build system
- Project metadata
- Supported Python versions
- Dependencies
- Console commands
- Tool configuration

The console-script declaration will connect:

```text
devtasks
```

to:

```python
devtasks.cli:main
```

That means the installed `devtasks` command calls the `main` function in `cli.py`.

### The Implementation

Create the complete file.

### File: `python-developer-cli/pyproject.toml`

```powershell
$pyprojectContent = @'
[build-system]
requires = ["setuptools>=69", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "devtasks-cli"
version = "1.0.0"
description = "A production-conscious task-management CLI built with Python."
readme = "README.md"
requires-python = ">=3.11"
license = { text = "MIT" }
authors = [
  { name = "CLI Developer Environment Series" }
]
keywords = [
  "cli",
  "powershell",
  "python",
  "tasks"
]
classifiers = [
  "Programming Language :: Python :: 3",
  "Programming Language :: Python :: 3 :: Only",
  "Operating System :: Microsoft :: Windows",
  "Environment :: Console"
]
dependencies = []

[project.scripts]
devtasks = "devtasks.cli:main"

[tool.setuptools]
package-dir = { "" = "src" }

[tool.setuptools.packages.find]
where = ["src"]

[tool.ruff]
target-version = "py311"
line-length = 88
src = ["src", "tests"]

[tool.ruff.lint]
select = [
  "E",
  "F",
  "I",
  "UP",
  "B",
  "SIM"
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
line-ending = "auto"
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\pyproject.toml" `
    -Value $pyprojectContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Use Python’s built-in TOML parser:

```powershell
python -c @'
from pathlib import Path
import tomllib

path = Path("pyproject.toml")

with path.open("rb") as file:
    data = tomllib.load(file)

assert data["project"]["name"] == "devtasks-cli"
assert data["project"]["scripts"]["devtasks"] == "devtasks.cli:main"
assert data["project"]["requires-python"] == ">=3.11"

print("pyproject.toml validation passed.")
'@
```

Expected output:

```text
pyproject.toml validation passed.
```

---

## 6.10 Create `.gitignore`

### The Target

Exclude virtual environments, caches, local data, and generated package artifacts from Git.

### The Concept

Python creates several reproducible directories and files:

```text
.venv/
__pycache__/
dist/
*.egg-info/
```

These are generated rather than maintained as source.

The application’s task data is also user-specific and should remain outside version control.

### The Implementation

### File: `python-developer-cli/.gitignore`

```powershell
$gitIgnoreContent = @'
# Project-local Python environments
.venv/
venv/

# Python bytecode and caches
__pycache__/
*.py[cod]
*$py.class

# Test and analysis caches
.pytest_cache/
.ruff_cache/
.coverage
htmlcov/

# Packaging output
build/
dist/
*.egg-info/

# Editor and operating-system metadata
.vscode/
.idea/
.DS_Store
Thumbs.db

# Local runtime overrides and logs
.env
*.log
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\.gitignore" `
    -Value $gitIgnoreContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

If Git is available:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    if (-not (Test-Path -LiteralPath .\.git)) {
        git init
    }

    git check-ignore -v .venv
    git check-ignore -v dist
}
```

Otherwise, verify the rules directly:

```powershell
$ignoreText = Get-Content `
    -LiteralPath .\.gitignore `
    -Raw

[PSCustomObject]@{
    VenvIgnored = $ignoreText -match "(?m)^\.venv/$"
    DistIgnored = $ignoreText -match "(?m)^dist/$"
    CacheIgnored = $ignoreText -match "(?m)^__pycache__/$"
}
```

Every value should be `True`.

---

## 6.11 Create the Task Model

### The Target

Create a typed task model that validates stored and user-supplied data.

### The Concept

A model defines the shape and rules of application data.

Each task will contain:

```text
id
title
completed
created_at
completed_at
```

Python type hints communicate expected value types. They improve readability and tool support, but Python does not automatically enforce every hint at runtime. The code must still validate external input.

### The Implementation

### File: `python-developer-cli/src/devtasks/models.py`

```powershell
$modelsContent = @'
"""Task data model and validation helpers."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import UTC, datetime
from typing import Any


def utc_now_iso() -> str:
    """Return the current UTC time as an ISO 8601 string."""
    return datetime.now(UTC).isoformat()


@dataclass(slots=True)
class Task:
    """One task stored by the command-line application."""

    id: int
    title: str
    completed: bool
    created_at: str
    completed_at: str | None = None

    @classmethod
    def create(cls, task_id: int, title: str) -> Task:
        """Create and validate a new incomplete task."""
        normalized_title = title.strip()

        if task_id < 1:
            raise ValueError("Task ID must be a positive integer.")

        if not normalized_title:
            raise ValueError("Task title cannot be empty.")

        if len(normalized_title) > 200:
            raise ValueError("Task title cannot exceed 200 characters.")

        return cls(
            id=task_id,
            title=normalized_title,
            completed=False,
            created_at=utc_now_iso(),
            completed_at=None,
        )

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> Task:
        """Create a validated task from untrusted JSON-compatible data."""
        required_keys = {
            "id",
            "title",
            "completed",
            "created_at",
            "completed_at",
        }

        missing_keys = required_keys.difference(value)

        if missing_keys:
            missing = ", ".join(sorted(missing_keys))
            raise ValueError(f"Stored task is missing fields: {missing}")

        task_id = value["id"]
        title = value["title"]
        completed = value["completed"]
        created_at = value["created_at"]
        completed_at = value["completed_at"]

        if not isinstance(task_id, int) or isinstance(task_id, bool):
            raise ValueError("Stored task ID must be an integer.")

        if task_id < 1:
            raise ValueError("Stored task ID must be positive.")

        if not isinstance(title, str) or not title.strip():
            raise ValueError("Stored task title must be a nonempty string.")

        if len(title.strip()) > 200:
            raise ValueError("Stored task title cannot exceed 200 characters.")

        if not isinstance(completed, bool):
            raise ValueError("Stored task completion value must be Boolean.")

        if not isinstance(created_at, str) or not created_at:
            raise ValueError("Stored creation time must be a nonempty string.")

        if completed_at is not None and not isinstance(completed_at, str):
            raise ValueError(
                "Stored completion time must be a string or null."
            )

        return cls(
            id=task_id,
            title=title.strip(),
            completed=completed,
            created_at=created_at,
            completed_at=completed_at,
        )

    def complete(self) -> bool:
        """Complete the task and report whether its state changed."""
        if self.completed:
            return False

        self.completed = True
        self.completed_at = utc_now_iso()
        return True

    def to_dict(self) -> dict[str, Any]:
        """Convert the task into JSON-compatible data."""
        return asdict(self)
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\src\devtasks\models.py" `
    -Value $modelsContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
python -m py_compile .\src\devtasks\models.py
```

Temporarily import through `src`:

```powershell
$env:PYTHONPATH = "$pythonProjectRoot\src"

try {
    python -c @'
from devtasks.models import Task

task = Task.create(1, "  Learn Python CLI development  ")

assert task.id == 1
assert task.title == "Learn Python CLI development"
assert task.completed is False
assert task.complete() is True
assert task.completed is True
assert task.complete() is False

print(task.to_dict())
print("Task model verification passed.")
'@
}
finally {
    Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
}
```

---

## 6.12 Create the JSON Storage Layer

### The Target

Create safe task loading and atomic task saving.

### The Concept

The storage layer separates filesystem concerns from command parsing.

An **atomic replacement** writes complete new data to a temporary file and then replaces the destination. This reduces the chance that an interrupted write leaves a partially written JSON file.

The process is:

```text
serialize complete data
        ↓
write temporary file
        ↓
flush and close
        ↓
replace destination
```

### The Implementation

### File: `python-developer-cli/src/devtasks/storage.py`

```powershell
$storageContent = @'
"""JSON storage for the devtasks command-line application."""

from __future__ import annotations

import json
import os
import tempfile
from pathlib import Path
from typing import Any

from devtasks.models import Task

DATA_DIRECTORY_ENVIRONMENT_VARIABLE = "DEVTASKS_DATA_DIR"


class StorageError(RuntimeError):
    """Raised when task data cannot be read or written safely."""


def default_data_directory() -> Path:
    """Return the configured or default task-data directory."""
    configured_directory = os.environ.get(
        DATA_DIRECTORY_ENVIRONMENT_VARIABLE
    )

    if configured_directory:
        return Path(configured_directory).expanduser().resolve()

    return Path.home().joinpath(".devtasks").resolve()


def default_data_file() -> Path:
    """Return the path to the task JSON file."""
    return default_data_directory() / "tasks.json"


def _validate_document(value: Any) -> list[Task]:
    if not isinstance(value, dict):
        raise StorageError("Task data must be a JSON object.")

    if value.get("schema_version") != 1:
        raise StorageError("Unsupported or missing task schema version.")

    raw_tasks = value.get("tasks")

    if not isinstance(raw_tasks, list):
        raise StorageError("Task data field 'tasks' must be a list.")

    tasks: list[Task] = []
    observed_ids: set[int] = set()

    for raw_task in raw_tasks:
        if not isinstance(raw_task, dict):
            raise StorageError("Every stored task must be a JSON object.")

        try:
            task = Task.from_dict(raw_task)
        except ValueError as error:
            raise StorageError(str(error)) from error

        if task.id in observed_ids:
            raise StorageError(f"Duplicate stored task ID: {task.id}")

        observed_ids.add(task.id)
        tasks.append(task)

    return tasks


def load_tasks(data_file: Path | None = None) -> list[Task]:
    """Load and validate tasks from disk."""
    path = (data_file or default_data_file()).resolve()

    if not path.exists():
        return []

    if not path.is_file():
        raise StorageError(f"Task data path is not a file: {path}")

    try:
        with path.open("r", encoding="utf-8") as file:
            document = json.load(file)
    except json.JSONDecodeError as error:
        raise StorageError(
            f"Task data contains invalid JSON: {path}"
        ) from error
    except OSError as error:
        raise StorageError(
            f"Unable to read task data: {path}: {error}"
        ) from error

    return _validate_document(document)


def save_tasks(
    tasks: list[Task],
    data_file: Path | None = None,
) -> Path:
    """Validate and atomically save tasks to disk."""
    path = (data_file or default_data_file()).resolve()
    parent = path.parent

    observed_ids: set[int] = set()

    for task in tasks:
        if not isinstance(task, Task):
            raise StorageError("Only Task objects can be saved.")

        if task.id in observed_ids:
            raise StorageError(f"Duplicate task ID: {task.id}")

        observed_ids.add(task.id)

    document = {
        "schema_version": 1,
        "tasks": [task.to_dict() for task in tasks],
    }

    try:
        parent.mkdir(parents=True, exist_ok=True)

        temporary_file_descriptor, temporary_name = tempfile.mkstemp(
            prefix=f".{path.name}.",
            suffix=".tmp",
            dir=parent,
            text=True,
        )

        temporary_path = Path(temporary_name)

        try:
            with os.fdopen(
                temporary_file_descriptor,
                "w",
                encoding="utf-8",
                newline="\n",
            ) as file:
                json.dump(
                    document,
                    file,
                    ensure_ascii=False,
                    indent=2,
                    sort_keys=True,
                )
                file.write("\n")
                file.flush()
                os.fsync(file.fileno())

            temporary_path.replace(path)
        except Exception:
            temporary_path.unlink(missing_ok=True)
            raise
    except OSError as error:
        raise StorageError(
            f"Unable to write task data: {path}: {error}"
        ) from error

    return path


def next_task_id(tasks: list[Task]) -> int:
    """Return the next positive task identifier."""
    return max((task.id for task in tasks), default=0) + 1
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\src\devtasks\storage.py" `
    -Value $storageContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
python -m py_compile .\src\devtasks\storage.py
```

Verify using a temporary directory:

```powershell
$env:PYTHONPATH = "$pythonProjectRoot\src"

try {
    python -c @'
from pathlib import Path
from tempfile import TemporaryDirectory

from devtasks.models import Task
from devtasks.storage import load_tasks, save_tasks

with TemporaryDirectory() as directory:
    path = Path(directory) / "tasks.json"
    expected = [Task.create(1, "Verify atomic storage")]

    save_tasks(expected, path)
    actual = load_tasks(path)

    assert len(actual) == 1
    assert actual[0].title == "Verify atomic storage"
    assert path.is_file()

print("Storage verification passed.")
'@
}
finally {
    Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
}
```

---

## 6.13 Create the CLI

### The Target

Create a complete `argparse` command-line interface.

### The Concept

`argparse` is Python’s built-in command-line parser.

The CLI has a command tree:

```text
devtasks
├── add TITLE
├── list [--status ...] [--json]
├── complete ID
├── remove ID
├── clear --completed
└── config
```

Each subcommand maps to one function. This keeps parsing separate from business behavior.

Exit codes will follow this convention:

```text
0 → success
1 → runtime or storage failure
2 → command usage or requested-item error
```

### The Implementation

### File: `python-developer-cli/src/devtasks/cli.py`

```powershell
$cliContent = @'
"""Command-line interface for devtasks."""

from __future__ import annotations

import argparse
import json
import sys
from collections.abc import Sequence
from pathlib import Path

from devtasks.models import Task
from devtasks.storage import (
    StorageError,
    default_data_directory,
    default_data_file,
    load_tasks,
    next_task_id,
    save_tasks,
)


def positive_integer(raw_value: str) -> int:
    """Parse a positive integer for argparse."""
    try:
        value = int(raw_value)
    except ValueError as error:
        raise argparse.ArgumentTypeError(
            "value must be a positive integer"
        ) from error

    if value < 1:
        raise argparse.ArgumentTypeError(
            "value must be a positive integer"
        )

    return value


def build_parser() -> argparse.ArgumentParser:
    """Build the command parser."""
    parser = argparse.ArgumentParser(
        prog="devtasks",
        description="Manage a local developer task list.",
    )

    parser.add_argument(
        "--version",
        action="version",
        version="%(prog)s 1.0.0",
    )

    subparsers = parser.add_subparsers(
        dest="command",
        required=True,
    )

    add_parser = subparsers.add_parser(
        "add",
        help="Add a task.",
    )
    add_parser.add_argument(
        "title",
        help="Task title, from 1 through 200 characters.",
    )
    add_parser.set_defaults(handler=handle_add)

    list_parser = subparsers.add_parser(
        "list",
        help="List tasks.",
    )
    list_parser.add_argument(
        "--status",
        choices=("all", "open", "completed"),
        default="all",
        help="Filter tasks by completion status.",
    )
    list_parser.add_argument(
        "--json",
        action="store_true",
        help="Write machine-readable JSON.",
    )
    list_parser.set_defaults(handler=handle_list)

    complete_parser = subparsers.add_parser(
        "complete",
        help="Mark a task as completed.",
    )
    complete_parser.add_argument(
        "task_id",
        type=positive_integer,
        metavar="ID",
        help="Positive task identifier.",
    )
    complete_parser.set_defaults(handler=handle_complete)

    remove_parser = subparsers.add_parser(
        "remove",
        help="Permanently remove one task.",
    )
    remove_parser.add_argument(
        "task_id",
        type=positive_integer,
        metavar="ID",
        help="Positive task identifier.",
    )
    remove_parser.set_defaults(handler=handle_remove)

    clear_parser = subparsers.add_parser(
        "clear",
        help="Remove tasks in bulk.",
    )
    clear_parser.add_argument(
        "--completed",
        action="store_true",
        required=True,
        help="Remove all completed tasks.",
    )
    clear_parser.set_defaults(handler=handle_clear)

    config_parser = subparsers.add_parser(
        "config",
        help="Display nonsecret runtime paths.",
    )
    config_parser.set_defaults(handler=handle_config)

    return parser


def find_task(tasks: list[Task], task_id: int) -> Task | None:
    """Find one task by ID."""
    return next(
        (task for task in tasks if task.id == task_id),
        None,
    )


def handle_add(
    arguments: argparse.Namespace,
    data_file: Path,
) -> int:
    """Add one task."""
    tasks = load_tasks(data_file)
    task = Task.create(next_task_id(tasks), arguments.title)
    tasks.append(task)
    save_tasks(tasks, data_file)

    print(f"Added task {task.id}: {task.title}")
    return 0


def handle_list(
    arguments: argparse.Namespace,
    data_file: Path,
) -> int:
    """List tasks in text or JSON format."""
    tasks = load_tasks(data_file)

    if arguments.status == "open":
        tasks = [task for task in tasks if not task.completed]
    elif arguments.status == "completed":
        tasks = [task for task in tasks if task.completed]

    tasks.sort(key=lambda task: task.id)

    if arguments.json:
        print(
            json.dumps(
                [task.to_dict() for task in tasks],
                ensure_ascii=False,
                indent=2,
            )
        )
        return 0

    if not tasks:
        print("No tasks found.")
        return 0

    for task in tasks:
        marker = "x" if task.completed else " "
        print(f"[{marker}] {task.id:>4}  {task.title}")

    return 0


def handle_complete(
    arguments: argparse.Namespace,
    data_file: Path,
) -> int:
    """Complete one task."""
    tasks = load_tasks(data_file)
    task = find_task(tasks, arguments.task_id)

    if task is None:
        print(
            f"Task {arguments.task_id} was not found.",
            file=sys.stderr,
        )
        return 2

    if task.complete():
        save_tasks(tasks, data_file)
        print(f"Completed task {task.id}: {task.title}")
    else:
        print(f"Task {task.id} was already completed.")

    return 0


def handle_remove(
    arguments: argparse.Namespace,
    data_file: Path,
) -> int:
    """Remove one task permanently."""
    tasks = load_tasks(data_file)
    task = find_task(tasks, arguments.task_id)

    if task is None:
        print(
            f"Task {arguments.task_id} was not found.",
            file=sys.stderr,
        )
        return 2

    remaining_tasks = [
        existing_task
        for existing_task in tasks
        if existing_task.id != task.id
    ]

    save_tasks(remaining_tasks, data_file)
    print(f"Removed task {task.id}: {task.title}")
    return 0


def handle_clear(
    arguments: argparse.Namespace,
    data_file: Path,
) -> int:
    """Remove completed tasks."""
    if not arguments.completed:
        print(
            "No clear operation was selected.",
            file=sys.stderr,
        )
        return 2

    tasks = load_tasks(data_file)
    remaining_tasks = [
        task for task in tasks if not task.completed
    ]
    removed_count = len(tasks) - len(remaining_tasks)

    if removed_count > 0:
        save_tasks(remaining_tasks, data_file)

    noun = "task" if removed_count == 1 else "tasks"
    print(f"Removed {removed_count} completed {noun}.")
    return 0


def handle_config(
    arguments: argparse.Namespace,
    data_file: Path,
) -> int:
    """Display public runtime paths."""
    del arguments

    configuration = {
        "data_directory": str(default_data_directory()),
        "data_file": str(data_file),
    }

    print(json.dumps(configuration, indent=2))
    return 0


def run(
    arguments: Sequence[str] | None = None,
    *,
    data_file: Path | None = None,
) -> int:
    """Parse arguments and execute the selected command."""
    parser = build_parser()
    parsed_arguments = parser.parse_args(arguments)
    resolved_data_file = (
        data_file or default_data_file()
    ).expanduser().resolve()

    try:
        return int(
            parsed_arguments.handler(
                parsed_arguments,
                resolved_data_file,
            )
        )
    except ValueError as error:
        print(f"Input error: {error}", file=sys.stderr)
        return 2
    except StorageError as error:
        print(f"Storage error: {error}", file=sys.stderr)
        return 1


def main() -> None:
    """Console-script entry point."""
    raise SystemExit(run())
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\src\devtasks\cli.py" `
    -Value $cliContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Check syntax:

```powershell
python -m py_compile .\src\devtasks\cli.py
```

Display help through `PYTHONPATH` before installation:

```powershell
$env:PYTHONPATH = "$pythonProjectRoot\src"

try {
    python -c "from devtasks.cli import build_parser; build_parser().print_help()"
}
finally {
    Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
}
```

Expected help includes:

```text
add
list
complete
remove
clear
config
```

---

## 6.14 Add `python -m devtasks` Support

### The Target

Allow the package to run as:

```powershell
python -m devtasks
```

### The Concept

When Python executes:

```powershell
python -m package_name
```

it looks for:

```text
package_name\__main__.py
```

This offers a reliable alternative to an installed console command.

### The Implementation

### File: `python-developer-cli/src/devtasks/__main__.py`

```powershell
$mainModuleContent = @'
"""Run devtasks with python -m devtasks."""

from devtasks.cli import main

if __name__ == "__main__":
    main()
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\src\devtasks\__main__.py" `
    -Value $mainModuleContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Run through `PYTHONPATH`:

```powershell
$env:PYTHONPATH = "$pythonProjectRoot\src"

try {
    python -m devtasks --help
    python -m devtasks --version
}
finally {
    Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
}
```

Expected version:

```text
devtasks 1.0.0
```

---

## 6.15 Create the README

### The Target

Document installation, commands, storage, and development workflows.

### The Concept

A README is the project’s front door. A new developer should be able to understand what the project does and how to verify it without reading every implementation file.

### The Implementation

### File: `python-developer-cli/README.md`

```powershell
$readmeContent = @'
# devtasks CLI

`devtasks` is a small Python command-line application for managing a local
developer task list.

## Requirements

- Windows
- PowerShell
- Python 3.11 or later

## Development setup

```powershell
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install build ruff
python -m pip install --editable .
```

If activation is blocked, call the virtual-environment interpreter directly:

```powershell
.\.venv\Scripts\python.exe -m pip install --editable .
```

## Commands

```powershell
devtasks add "Write documentation"
devtasks list
devtasks list --status open
devtasks list --status completed
devtasks list --json
devtasks complete 1
devtasks remove 1
devtasks clear --completed
devtasks config
```

The package can also run through:

```powershell
python -m devtasks --help
```

## Storage

By default, task data is stored at:

```text
$HOME\.devtasks\tasks.json
```

Override the data directory for one PowerShell session:

```powershell
$env:DEVTASKS_DATA_DIR = "$env:TEMP\devtasks-demo"

try {
    devtasks add "Temporary task"
    devtasks list
}
finally {
    Remove-Item Env:DEVTASKS_DATA_DIR -ErrorAction SilentlyContinue
}
```

## Quality checks

```powershell
python -m ruff format --check .
python -m ruff check .
python -m unittest discover -s tests -v
python -m build
```

## Safety

- Tests use temporary directories.
- Runtime task data is stored outside the repository.
- JSON updates use temporary-file replacement.
- The CLI validates stored data before using it.
- `remove` and `clear` permanently remove task records from the JSON database.
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\README.md" `
    -Value $readmeContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Run:

```powershell
Get-Item -LiteralPath .\README.md |
    Select-Object Name, Length, FullName

Select-String `
    -LiteralPath .\README.md `
    -Pattern "devtasks add", "python -m unittest", "DEVTASKS_DATA_DIR"
```

All three patterns should match.

---

## 6.16 Install the Project in Editable Mode

### The Target

Install the package and its console command into `.venv`.

### The Concept

An **editable installation** connects the virtual environment to the source tree.

After:

```powershell
python -m pip install --editable .
```

changes to Python source files are reflected without rebuilding and reinstalling the package after every edit.

The install also creates the Windows console wrapper:

```text
.venv\Scripts\devtasks.exe
```

### The Implementation

Install the project:

```powershell
python -m pip install --editable .
```

Inspect it:

```powershell
python -m pip show devtasks-cli
```

Locate the console command:

```powershell
Get-Command devtasks |
    Select-Object Name, CommandType, Source
```

### The Verification

Run:

```powershell
devtasks --version
devtasks --help
python -m devtasks --version
```

Verify command resolution:

```powershell
$devtasksCommand = Get-Command devtasks

[PSCustomObject]@{
    CommandAvailable = $null -ne $devtasksCommand
    CommandIsInsideVenv = $devtasksCommand.Source.StartsWith(
        (Resolve-Path .\.venv).Path,
        [System.StringComparison]::OrdinalIgnoreCase
    )
    ModuleRuns = (
        python -m devtasks --version
    ) -match "1\.0\.0"
}
```

Every value should be `True`.

---

## 6.17 Exercise the CLI with Isolated Data

### The Target

Use the CLI without modifying the default `$HOME\.devtasks` database.

### The Concept

The environment variable:

```text
DEVTASKS_DATA_DIR
```

changes the task-data directory.

This is useful for:

- Tests
- Demos
- Separate task collections
- Avoiding changes to real user data

### The Implementation

Create a disposable data path:

```powershell
$demoDataDirectory = Join-Path `
    -Path $env:TEMP `
    -ChildPath "devtasks-cli-demo"

if (Test-Path -LiteralPath $demoDataDirectory) {
    Remove-Item `
        -LiteralPath $demoDataDirectory `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

$env:DEVTASKS_DATA_DIR = $demoDataDirectory
```

Display configuration:

```powershell
devtasks config
```

Add tasks:

```powershell
devtasks add "Write the Python CLI tutorial"
devtasks add "Run the automated tests"
devtasks add "Build the wheel package"
```

List them:

```powershell
devtasks list
```

Complete task 2:

```powershell
devtasks complete 2
```

List completed tasks:

```powershell
devtasks list --status completed
```

List open tasks:

```powershell
devtasks list --status open
```

Get JSON:

```powershell
devtasks list --json
```

### The Verification

Parse the JSON output:

```powershell
$taskJson = devtasks list --json
$tasks = $taskJson -join "`n" |
    ConvertFrom-Json

[PSCustomObject]@{
    TaskCount = @($tasks).Count
    CompletedCount = @(
        $tasks |
            Where-Object completed -eq $true
    ).Count
    OpenCount = @(
        $tasks |
            Where-Object completed -eq $false
    ).Count
    DataFileExists = Test-Path `
        -LiteralPath "$demoDataDirectory\tasks.json" `
        -PathType Leaf
}
```

Expected values:

```text
TaskCount     : 3
CompletedCount: 1
OpenCount     : 2
DataFileExists: True
```

---

## 6.18 Test Removal Commands

### The Target

Remove one task and clear completed tasks.

### The Concept

CLI deletion changes the JSON database rather than deleting arbitrary filesystem paths.

The same safety principle still applies:

- Understand the target ID.
- List current state.
- Perform the command.
- Verify remaining state.

### The Implementation

Inspect current tasks:

```powershell
devtasks list
```

Remove task 1:

```powershell
devtasks remove 1
```

List again:

```powershell
devtasks list
```

Clear completed tasks:

```powershell
devtasks clear --completed
```

List again:

```powershell
devtasks list
```

### The Verification

Parse the final state:

```powershell
$remainingJson = devtasks list --json
$remainingTasks = @(
    $remainingJson -join "`n" |
        ConvertFrom-Json
)

[PSCustomObject]@{
    RemainingCount = $remainingTasks.Count
    RemainingTaskId = $remainingTasks[0].id
    RemainingTitle = $remainingTasks[0].title
    RemainingTaskIsOpen = (
        $remainingTasks[0].completed -eq $false
    )
}
```

Expected result:

```text
RemainingCount      : 1
RemainingTaskId     : 3
RemainingTitle      : Build the wheel package
RemainingTaskIsOpen : True
```

Test removal of a missing task:

```powershell
devtasks remove 999
$missingTaskExitCode = $LASTEXITCODE

$missingTaskExitCode
```

Expected exit code:

```text
2
```

The error output should include:

```text
Task 999 was not found.
```

Keep `$env:DEVTASKS_DATA_DIR` set for the next few exercises.

---

## 6.19 Inspect the JSON Database

### The Target

Inspect and validate the application’s generated JSON data.

### The Concept

Although users normally interact through the CLI, the storage file should remain valid, readable JSON.

The storage document includes a schema version:

```json
{
  "schema_version": 1,
  "tasks": []
}
```

A **schema version** identifies the expected data structure. If the application’s storage format changes in the future, the version can guide a migration.

Do not manually edit the task file during ordinary use. A malformed edit could cause validation to fail.

### The Implementation

Construct the data-file path:

```powershell
$demoDataFile = Join-Path `
    -Path $demoDataDirectory `
    -ChildPath "tasks.json"
```

Inspect metadata:

```powershell
Get-Item `
    -LiteralPath $demoDataFile |
    Select-Object Name, Length, LastWriteTime, FullName
```

Parse it through PowerShell:

```powershell
$storedDocument = Get-Content `
    -LiteralPath $demoDataFile `
    -Raw |
    ConvertFrom-Json
```

Display only nonsecret structural information:

```powershell
[PSCustomObject]@{
    SchemaVersion = $storedDocument.schema_version
    TaskCount = @($storedDocument.tasks).Count
}
```

Validate it through the Python storage layer:

```powershell
python -c @'
from devtasks.storage import load_tasks

tasks = load_tasks()

assert len(tasks) == 1
assert tasks[0].id == 3
assert tasks[0].title == "Build the wheel package"

print("Stored task data is valid.")
'@
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    FileExists = Test-Path `
        -LiteralPath $demoDataFile `
        -PathType Leaf
    SchemaVersionIsOne = (
        $storedDocument.schema_version -eq 1
    )
    OneTaskRemains = (
        @($storedDocument.tasks).Count -eq 1
    )
    RemainingIdIsThree = (
        $storedDocument.tasks[0].id -eq 3
    )
}
```

Every value should be `True`.

---

## 6.20 Create Storage Tests

### The Target

Create automated tests for task persistence, missing files, invalid JSON, and duplicate IDs.

### The Concept

Storage tests should never modify the real user database.

Python’s `TemporaryDirectory` creates an isolated disposable directory for each test. The directory and its files are removed automatically when the context closes.

The tests will verify both successful and failing behavior.

### The Implementation

### File: `python-developer-cli/tests/test_storage.py`

```powershell
$storageTestContent = @'
"""Tests for JSON task storage."""

from __future__ import annotations

import json
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from devtasks.models import Task
from devtasks.storage import (
    StorageError,
    load_tasks,
    next_task_id,
    save_tasks,
)


class StorageTests(unittest.TestCase):
    """Verify task storage behavior."""

    def test_missing_file_returns_empty_list(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"

            self.assertEqual(load_tasks(path), [])

    def test_tasks_round_trip_through_json(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"
            tasks = [
                Task.create(1, "First task"),
                Task.create(2, "Second task"),
            ]

            tasks[1].complete()

            saved_path = save_tasks(tasks, path)
            loaded_tasks = load_tasks(path)

            self.assertEqual(saved_path, path.resolve())
            self.assertEqual(len(loaded_tasks), 2)
            self.assertEqual(loaded_tasks[0].title, "First task")
            self.assertFalse(loaded_tasks[0].completed)
            self.assertEqual(loaded_tasks[1].title, "Second task")
            self.assertTrue(loaded_tasks[1].completed)
            self.assertIsNotNone(loaded_tasks[1].completed_at)

    def test_saved_document_has_schema_version(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"

            save_tasks([Task.create(1, "Schema task")], path)

            with path.open("r", encoding="utf-8") as file:
                document = json.load(file)

            self.assertEqual(document["schema_version"], 1)
            self.assertEqual(len(document["tasks"]), 1)

    def test_invalid_json_is_rejected(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"
            path.write_text("{invalid-json", encoding="utf-8")

            with self.assertRaisesRegex(
                StorageError,
                "invalid JSON",
            ):
                load_tasks(path)

    def test_unsupported_schema_is_rejected(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"
            path.write_text(
                json.dumps(
                    {
                        "schema_version": 999,
                        "tasks": [],
                    }
                ),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(
                StorageError,
                "schema version",
            ):
                load_tasks(path)

    def test_duplicate_stored_ids_are_rejected(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"
            task = Task.create(1, "Duplicate task").to_dict()

            path.write_text(
                json.dumps(
                    {
                        "schema_version": 1,
                        "tasks": [task, task],
                    }
                ),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(
                StorageError,
                "Duplicate stored task ID",
            ):
                load_tasks(path)

    def test_duplicate_ids_cannot_be_saved(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"
            tasks = [
                Task.create(1, "First"),
                Task.create(1, "Duplicate"),
            ]

            with self.assertRaisesRegex(
                StorageError,
                "Duplicate task ID",
            ):
                save_tasks(tasks, path)

    def test_next_task_id_follows_largest_existing_id(self) -> None:
        tasks = [
            Task.create(2, "Second"),
            Task.create(8, "Eighth"),
            Task.create(4, "Fourth"),
        ]

        self.assertEqual(next_task_id(tasks), 9)

    def test_next_task_id_for_empty_list_is_one(self) -> None:
        self.assertEqual(next_task_id([]), 1)


if __name__ == "__main__":
    unittest.main()
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\tests\test_storage.py" `
    -Value $storageTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Run the storage tests:

```powershell
python -m unittest `
    tests.test_storage `
    -v
```

Expected summary:

```text
Ran 9 tests
OK
```

Inspect the exit code:

```powershell
$LASTEXITCODE
```

Expected result:

```text
0
```

---

## 6.21 Create CLI Tests

### The Target

Test command behavior without starting separate operating-system processes.

### The Concept

The CLI’s `run` function accepts:

- An explicit argument list
- An explicit data-file path

That design is intentional. Tests can call the application directly while capturing standard output and standard error.

This is faster and more isolated than invoking a new process for every test.

### The Implementation

### File: `python-developer-cli/tests/test_cli.py`

```powershell
$cliTestContent = @'
"""Tests for the devtasks command-line interface."""

from __future__ import annotations

import json
import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
from tempfile import TemporaryDirectory

from devtasks.cli import run
from devtasks.storage import load_tasks


class CliTests(unittest.TestCase):
    """Verify complete CLI command workflows."""

    def setUp(self) -> None:
        self.temporary_directory = TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.data_file = (
            Path(self.temporary_directory.name) / "tasks.json"
        )

    def execute(
        self,
        arguments: list[str],
    ) -> tuple[int, str, str]:
        standard_output = StringIO()
        standard_error = StringIO()

        with (
            redirect_stdout(standard_output),
            redirect_stderr(standard_error),
        ):
            exit_code = run(
                arguments,
                data_file=self.data_file,
            )

        return (
            exit_code,
            standard_output.getvalue(),
            standard_error.getvalue(),
        )

    def test_add_creates_a_task(self) -> None:
        exit_code, standard_output, standard_error = (
            self.execute(
                [
                    "add",
                    "Write automated tests",
                ]
            )
        )

        tasks = load_tasks(self.data_file)

        self.assertEqual(exit_code, 0)
        self.assertEqual(standard_error, "")
        self.assertIn("Added task 1", standard_output)
        self.assertEqual(len(tasks), 1)
        self.assertEqual(
            tasks[0].title,
            "Write automated tests",
        )

    def test_add_rejects_an_empty_title(self) -> None:
        exit_code, standard_output, standard_error = (
            self.execute(
                [
                    "add",
                    "   ",
                ]
            )
        )

        self.assertEqual(exit_code, 2)
        self.assertEqual(standard_output, "")
        self.assertIn(
            "Task title cannot be empty",
            standard_error,
        )
        self.assertFalse(self.data_file.exists())

    def test_list_reports_no_tasks(self) -> None:
        exit_code, standard_output, standard_error = (
            self.execute(["list"])
        )

        self.assertEqual(exit_code, 0)
        self.assertEqual(standard_error, "")
        self.assertEqual(
            standard_output.strip(),
            "No tasks found.",
        )

    def test_list_json_returns_machine_readable_data(self) -> None:
        self.execute(["add", "First task"])
        self.execute(["add", "Second task"])

        exit_code, standard_output, standard_error = (
            self.execute(["list", "--json"])
        )

        document = json.loads(standard_output)

        self.assertEqual(exit_code, 0)
        self.assertEqual(standard_error, "")
        self.assertEqual(len(document), 2)
        self.assertEqual(document[0]["id"], 1)
        self.assertEqual(document[1]["id"], 2)

    def test_complete_changes_task_state(self) -> None:
        self.execute(["add", "Complete this task"])

        exit_code, standard_output, standard_error = (
            self.execute(["complete", "1"])
        )

        tasks = load_tasks(self.data_file)

        self.assertEqual(exit_code, 0)
        self.assertEqual(standard_error, "")
        self.assertIn("Completed task 1", standard_output)
        self.assertTrue(tasks[0].completed)
        self.assertIsNotNone(tasks[0].completed_at)

    def test_completing_a_missing_task_returns_two(self) -> None:
        exit_code, standard_output, standard_error = (
            self.execute(["complete", "999"])
        )

        self.assertEqual(exit_code, 2)
        self.assertEqual(standard_output, "")
        self.assertIn(
            "Task 999 was not found",
            standard_error,
        )

    def test_remove_deletes_one_task(self) -> None:
        self.execute(["add", "Keep this task"])
        self.execute(["add", "Remove this task"])

        exit_code, standard_output, standard_error = (
            self.execute(["remove", "2"])
        )

        tasks = load_tasks(self.data_file)

        self.assertEqual(exit_code, 0)
        self.assertEqual(standard_error, "")
        self.assertIn("Removed task 2", standard_output)
        self.assertEqual(len(tasks), 1)
        self.assertEqual(tasks[0].id, 1)

    def test_status_filters_tasks(self) -> None:
        self.execute(["add", "Open task"])
        self.execute(["add", "Completed task"])
        self.execute(["complete", "2"])

        open_code, open_output, open_error = self.execute(
            [
                "list",
                "--status",
                "open",
                "--json",
            ]
        )

        completed_code, completed_output, completed_error = (
            self.execute(
                [
                    "list",
                    "--status",
                    "completed",
                    "--json",
                ]
            )
        )

        open_tasks = json.loads(open_output)
        completed_tasks = json.loads(completed_output)

        self.assertEqual(open_code, 0)
        self.assertEqual(completed_code, 0)
        self.assertEqual(open_error, "")
        self.assertEqual(completed_error, "")
        self.assertEqual(
            [task["id"] for task in open_tasks],
            [1],
        )
        self.assertEqual(
            [task["id"] for task in completed_tasks],
            [2],
        )

    def test_clear_removes_only_completed_tasks(self) -> None:
        self.execute(["add", "Open task"])
        self.execute(["add", "Completed task"])
        self.execute(["complete", "2"])

        exit_code, standard_output, standard_error = (
            self.execute(["clear", "--completed"])
        )

        tasks = load_tasks(self.data_file)

        self.assertEqual(exit_code, 0)
        self.assertEqual(standard_error, "")
        self.assertIn(
            "Removed 1 completed task.",
            standard_output,
        )
        self.assertEqual(len(tasks), 1)
        self.assertEqual(tasks[0].title, "Open task")

    def test_storage_error_returns_one(self) -> None:
        self.data_file.write_text(
            "{invalid-json",
            encoding="utf-8",
        )

        exit_code, standard_output, standard_error = (
            self.execute(["list"])
        )

        self.assertEqual(exit_code, 1)
        self.assertEqual(standard_output, "")
        self.assertIn("Storage error:", standard_error)


if __name__ == "__main__":
    unittest.main()
'@

Set-Content `
    -LiteralPath "$pythonProjectRoot\tests\test_cli.py" `
    -Value $cliTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Run CLI tests:

```powershell
python -m unittest `
    tests.test_cli `
    -v
```

Expected summary:

```text
Ran 10 tests
OK
```

Run all tests through discovery:

```powershell
python -m unittest `
    discover `
    -s tests `
    -v
```

Expected summary:

```text
Ran 19 tests
OK
```

---

## 6.22 Format and Lint with Ruff

### The Target

Apply consistent formatting and static analysis to all Python source and tests.

### The Concept

A formatter handles layout automatically. A linter detects suspicious or inconsistent code patterns.

Ruff provides both functions:

```text
ruff format → formatting
ruff check  → linting
```

Use the environment’s module form:

```powershell
python -m ruff
```

This ties the command to the active interpreter.

### The Implementation

Preview formatting differences:

```powershell
python -m ruff format `
    --diff `
    .
```

Apply formatting:

```powershell
python -m ruff format .
```

Run linting:

```powershell
python -m ruff check .
```

If Ruff reports automatically fixable import or style issues, inspect them first. For this tutorial project, you may run:

```powershell
python -m ruff check `
    --fix `
    .
```

Then run formatting once more:

```powershell
python -m ruff format .
```

### The Verification

Check formatting without modifying files:

```powershell
python -m ruff format `
    --check `
    .

$formatExitCode = $LASTEXITCODE
```

Check linting:

```powershell
python -m ruff check .

$lintExitCode = $LASTEXITCODE
```

Verify:

```powershell
[PSCustomObject]@{
    FormattingPassed = $formatExitCode -eq 0
    LintingPassed = $lintExitCode -eq 0
}
```

Both values should be `True`.

Run all tests again because formatting and automated fixes changed source files:

```powershell
python -m unittest discover -s tests -v
```

---

## 6.23 Compile All Python Source

### The Target

Verify that every Python file can be compiled to bytecode.

### The Concept

`compileall` catches syntax errors across a complete directory tree.

It does not prove that the program behaves correctly. Tests and runtime checks remain necessary.

The compilation process may create:

```text
__pycache__/
```

These cache directories are generated and ignored by Git.

### The Implementation

Compile source and tests:

```powershell
python -m compileall `
    -q `
    .\src `
    .\tests
```

Capture the result:

```powershell
$compileExitCode = $LASTEXITCODE
```

Inspect generated cache directories:

```powershell
Get-ChildItem `
    -LiteralPath $pythonProjectRoot `
    -Directory `
    -Recurse `
    -Force |
    Where-Object Name -eq "__pycache__" |
    Select-Object FullName
```

### The Verification

Run:

```powershell
if ($compileExitCode -ne 0) {
    throw "Python compilation failed."
}

Write-Host "All Python files compiled successfully." `
    -ForegroundColor Green
```

Expected message:

```text
All Python files compiled successfully.
```

---

## 6.24 Build the Python Package

### The Target

Create both:

- A source distribution
- A wheel distribution

under:

```text
dist/
```

### The Concept

A **source distribution**, usually ending in `.tar.gz`, contains source and packaging metadata.

A **wheel**, ending in `.whl`, is a built distribution designed for installation.

The build command reads `pyproject.toml` and uses the declared build backend.

### The Implementation

Remove stale build output:

```powershell
if (Test-Path -LiteralPath .\dist) {
    Remove-Item `
        -LiteralPath .\dist `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

if (Test-Path -LiteralPath .\build) {
    Remove-Item `
        -LiteralPath .\build `
        -Recurse `
        -Force `
        -ErrorAction Stop
}
```

Build:

```powershell
python -m build
```

Inspect output:

```powershell
Get-ChildItem `
    -LiteralPath .\dist `
    -File |
    Select-Object Name, Length, FullName
```

### The Verification

Capture package artifacts:

```powershell
$wheelFiles = @(
    Get-ChildItem `
        -LiteralPath .\dist `
        -Filter "*.whl" `
        -File
)

$sourceDistributions = @(
    Get-ChildItem `
        -LiteralPath .\dist `
        -Filter "*.tar.gz" `
        -File
)

[PSCustomObject]@{
    WheelCount = $wheelFiles.Count
    SourceDistributionCount = $sourceDistributions.Count
    ExactlyOneWheel = $wheelFiles.Count -eq 1
    ExactlyOneSourceDistribution = (
        $sourceDistributions.Count -eq 1
    )
}
```

Both Boolean values should be `True`.

---

## 6.25 Inspect the Wheel Contents

### The Target

Verify that the wheel contains the expected Python modules and metadata.

### The Concept

A wheel is a ZIP-format archive with a `.whl` extension.

It should contain:

```text
devtasks/__init__.py
devtasks/__main__.py
devtasks/cli.py
devtasks/models.py
devtasks/storage.py
distribution metadata
```

Inspecting the wheel catches packaging mistakes where source files exist locally but are absent from the built artifact.

### The Implementation

Use Python’s `zipfile` module:

```powershell
$wheelPath = $wheelFiles[0].FullName

python -c @"
from pathlib import Path
from zipfile import ZipFile

wheel_path = Path(r"$wheelPath")

with ZipFile(wheel_path) as wheel:
    for name in sorted(wheel.namelist()):
        print(name)
"@
```

Run an assertion-based check:

```powershell
python -c @"
from pathlib import Path
from zipfile import ZipFile

wheel_path = Path(r"$wheelPath")

required_files = {
    "devtasks/__init__.py",
    "devtasks/__main__.py",
    "devtasks/cli.py",
    "devtasks/models.py",
    "devtasks/storage.py",
}

with ZipFile(wheel_path) as wheel:
    names = set(wheel.namelist())

missing = required_files.difference(names)

if missing:
    raise SystemExit(
        "Wheel is missing files: " + ", ".join(sorted(missing))
    )

print("Wheel-content verification passed.")
"@
```

### The Verification

Expected output:

```text
Wheel-content verification passed.
```

Confirm the wheel is nonempty:

```powershell
(Get-Item -LiteralPath $wheelPath).Length -gt 0
```

Expected result:

```text
True
```

---

## 6.26 Test the Wheel in a Clean Virtual Environment

### The Target

Install the built wheel into a second isolated environment and run the installed command.

### The Concept

An editable development installation can hide packaging errors because it points directly to source.

A clean wheel test verifies that the built artifact is independently installable.

The test environment will be:

```text
.wheel-test-venv/
```

It is temporary generated output and will be removed afterward.

### The Implementation

Create the clean environment:

```powershell
$wheelTestEnvironment = Join-Path `
    -Path $pythonProjectRoot `
    -ChildPath ".wheel-test-venv"

if (Test-Path -LiteralPath $wheelTestEnvironment) {
    Remove-Item `
        -LiteralPath $wheelTestEnvironment `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

py -3 -m venv $wheelTestEnvironment
```

Install the wheel without contacting a package index:

```powershell
$wheelTestPython = Join-Path `
    -Path $wheelTestEnvironment `
    -ChildPath "Scripts\python.exe"

& $wheelTestPython `
    -m pip install `
    --no-index `
    $wheelPath
```

Use isolated runtime data:

```powershell
$wheelTestData = Join-Path `
    -Path $env:TEMP `
    -ChildPath "devtasks-wheel-test"

if (Test-Path -LiteralPath $wheelTestData) {
    Remove-Item `
        -LiteralPath $wheelTestData `
        -Recurse `
        -Force
}

$previousDataDirectory = $env:DEVTASKS_DATA_DIR
$env:DEVTASKS_DATA_DIR = $wheelTestData
```

Run the installed module and console command:

```powershell
$wheelTestCommand = Join-Path `
    -Path $wheelTestEnvironment `
    -ChildPath "Scripts\devtasks.exe"

try {
    & $wheelTestPython -m devtasks --version

    & $wheelTestCommand add "Installed wheel works"
    & $wheelTestCommand list
}
finally {
    if ($null -eq $previousDataDirectory) {
        Remove-Item `
            Env:DEVTASKS_DATA_DIR `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:DEVTASKS_DATA_DIR = $previousDataDirectory
    }
}
```

### The Verification

Temporarily restore the wheel-test data path to inspect JSON output:

```powershell
$previousDataDirectory = $env:DEVTASKS_DATA_DIR
$env:DEVTASKS_DATA_DIR = $wheelTestData

try {
    $installedTaskJson = & $wheelTestCommand list --json
    $installedTasks = @(
        $installedTaskJson -join "`n" |
            ConvertFrom-Json
    )
}
finally {
    if ($null -eq $previousDataDirectory) {
        Remove-Item `
            Env:DEVTASKS_DATA_DIR `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:DEVTASKS_DATA_DIR = $previousDataDirectory
    }
}

[PSCustomObject]@{
    TestEnvironmentExists = Test-Path `
        -LiteralPath $wheelTestEnvironment `
        -PathType Container
    InstalledCommandExists = Test-Path `
        -LiteralPath $wheelTestCommand `
        -PathType Leaf
    OneTaskWasCreated = $installedTasks.Count -eq 1
    CorrectTaskTitle = (
        $installedTasks[0].title -eq
        "Installed wheel works"
    )
}
```

Every value should be `True`.

Clean up the temporary wheel-test resources:

```powershell
Remove-Item `
    -LiteralPath $wheelTestEnvironment `
    -Recurse `
    -Force `
    -ErrorAction Stop

Remove-Item `
    -LiteralPath $wheelTestData `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue
```

---

## 6.27 Create a PowerShell Quality Script

### The Target

Create one PowerShell script that runs the complete Python quality gate.

The script will:

1. Verify the virtual environment
2. Check formatting
3. Run linting
4. Compile source
5. Run tests
6. Build distributions
7. Verify package artifacts

### The Concept

Python packaging does not require one universal script runner. A project may use:

- PowerShell scripts
- `tox`
- `nox`
- `hatch`
- `poe`
- `make`
- CI workflow commands

Because this series focuses on PowerShell, we will create a self-contained PowerShell quality script.

### The Implementation

### File: `python-developer-cli/scripts/Invoke-PythonQualityGate.ps1`

First create the scripts directory:

```powershell
$pythonScriptsDirectory = Join-Path `
    -Path $pythonProjectRoot `
    -ChildPath "scripts"

if (-not (
    Test-Path `
        -LiteralPath $pythonScriptsDirectory `
        -PathType Container
)) {
    $null = New-Item `
        -Path $pythonScriptsDirectory `
        -ItemType Directory `
        -ErrorAction Stop
}
```

Create the script:

```powershell
$qualityScriptPath = Join-Path `
    -Path $pythonScriptsDirectory `
    -ChildPath "Invoke-PythonQualityGate.ps1"

$qualityScriptContent = @'
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = Split-Path `
    -Path $PSScriptRoot `
    -Parent

$pythonPath = Join-Path `
    -Path $projectRoot `
    -ChildPath ".venv\Scripts\python.exe"

if (-not (
    Test-Path `
        -LiteralPath $pythonPath `
        -PathType Leaf
)) {
    throw "Virtual-environment interpreter is missing: $pythonPath"
}

function Invoke-CheckedPython {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments,

        [Parameter(Mandatory)]
        [string] $Description
    )

    Write-Host "[STARTING] $Description" -ForegroundColor Cyan

    & $pythonPath @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw (
            "$Description failed with exit code " +
            "$LASTEXITCODE."
        )
    }

    Write-Host "[PASSED] $Description" -ForegroundColor Green
}

Push-Location -LiteralPath $projectRoot

try {
    Invoke-CheckedPython `
        -Description "Ruff formatting check" `
        -Arguments @(
            "-m"
            "ruff"
            "format"
            "--check"
            "."
        )

    Invoke-CheckedPython `
        -Description "Ruff lint check" `
        -Arguments @(
            "-m"
            "ruff"
            "check"
            "."
        )

    Invoke-CheckedPython `
        -Description "Python compilation" `
        -Arguments @(
            "-m"
            "compileall"
            "-q"
            "src"
            "tests"
        )

    Invoke-CheckedPython `
        -Description "Unit tests" `
        -Arguments @(
            "-m"
            "unittest"
            "discover"
            "-s"
            "tests"
            "-v"
        )

    foreach ($generatedDirectory in @(
        "build"
        "dist"
    )) {
        $generatedPath = Join-Path `
            -Path $projectRoot `
            -ChildPath $generatedDirectory

        if (Test-Path -LiteralPath $generatedPath) {
            Remove-Item `
                -LiteralPath $generatedPath `
                -Recurse `
                -Force
        }
    }

    Invoke-CheckedPython `
        -Description "Package build" `
        -Arguments @(
            "-m"
            "build"
        )

    $wheelFiles = @(
        Get-ChildItem `
            -LiteralPath "$projectRoot\dist" `
            -Filter "*.whl" `
            -File
    )

    $sourceDistributions = @(
        Get-ChildItem `
            -LiteralPath "$projectRoot\dist" `
            -Filter "*.tar.gz" `
            -File
    )

    if ($wheelFiles.Count -ne 1) {
        throw (
            "Expected one wheel; found " +
            "$($wheelFiles.Count)."
        )
    }

    if ($sourceDistributions.Count -ne 1) {
        throw (
            "Expected one source distribution; found " +
            "$($sourceDistributions.Count)."
        )
    }

    Write-Host (
        "[PASSED] Python quality gate completed successfully."
    ) -ForegroundColor Green
}
finally {
    Pop-Location
}
'@

Set-Content `
    -LiteralPath $qualityScriptPath `
    -Value $qualityScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Parse the PowerShell script:

```powershell
$tokens = $null
$parseErrors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $qualityScriptPath,
    [ref] $tokens,
    [ref] $parseErrors
) | Out-Null

$parseErrors
```

No output means no parser errors.

Run it:

```powershell
& $qualityScriptPath
```

Expected final message:

```text
[PASSED] Python quality gate completed successfully.
```

---

## 6.28 Create a Python Smoke-Test Script

### The Target

Create a PowerShell script that exercises the installed console command in an isolated data directory.

### The Concept

Unit tests call Python functions directly. A smoke test verifies the real installed command wrapper.

It checks:

- Console command resolution
- Argument parsing
- Data persistence
- JSON output
- Exit codes
- Cleanup

### The Implementation

### File: `python-developer-cli/scripts/Test-PythonCli.ps1`

```powershell
$smokeTestPath = Join-Path `
    -Path $pythonScriptsDirectory `
    -ChildPath "Test-PythonCli.ps1"

$smokeTestContent = @'
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = Split-Path `
    -Path $PSScriptRoot `
    -Parent

$commandPath = Join-Path `
    -Path $projectRoot `
    -ChildPath ".venv\Scripts\devtasks.exe"

if (-not (
    Test-Path `
        -LiteralPath $commandPath `
        -PathType Leaf
)) {
    throw "Installed devtasks command is missing: $commandPath"
}

$testDataRoot = Join-Path `
    -Path ([System.IO.Path]::GetTempPath()) `
    -ChildPath (
        "devtasks-smoke-" +
        [System.Guid]::NewGuid().ToString("N")
    )

$previousDataDirectory = $env:DEVTASKS_DATA_DIR
$env:DEVTASKS_DATA_DIR = $testDataRoot

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments
    )

    & $commandPath @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw (
            "devtasks failed with exit code " +
            "$LASTEXITCODE: " +
            ($Arguments -join " ")
        )
    }
}

try {
    Invoke-CheckedCommand `
        -Arguments @(
            "add"
            "First smoke-test task"
        )

    Invoke-CheckedCommand `
        -Arguments @(
            "add"
            "Second smoke-test task"
        )

    Invoke-CheckedCommand `
        -Arguments @(
            "complete"
            "1"
        )

    $jsonOutput = & $commandPath list --json

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to retrieve task JSON."
    }

    $tasks = @(
        $jsonOutput -join [Environment]::NewLine |
            ConvertFrom-Json
    )

    if ($tasks.Count -ne 2) {
        throw "Expected two tasks, found $($tasks.Count)."
    }

    $firstTask = $tasks |
        Where-Object id -eq 1

    $secondTask = $tasks |
        Where-Object id -eq 2

    if ($firstTask.completed -ne $true) {
        throw "The first task was not completed."
    }

    if ($secondTask.completed -ne $false) {
        throw "The second task should remain open."
    }

    Invoke-CheckedCommand `
        -Arguments @(
            "clear"
            "--completed"
        )

    $remainingJson = & $commandPath list --json

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to retrieve final task JSON."
    }

    $remainingTasks = @(
        $remainingJson -join [Environment]::NewLine |
            ConvertFrom-Json
    )

    if ($remainingTasks.Count -ne 1) {
        throw (
            "Expected one remaining task, found " +
            "$($remainingTasks.Count)."
        )
    }

    [PSCustomObject]@{
        Passed = $true
        RemainingTaskId = $remainingTasks[0].id
        RemainingTaskTitle = $remainingTasks[0].title
        DataDirectory = $testDataRoot
    }
}
finally {
    if ($null -eq $previousDataDirectory) {
        Remove-Item `
            Env:DEVTASKS_DATA_DIR `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:DEVTASKS_DATA_DIR = $previousDataDirectory
    }

    if (Test-Path -LiteralPath $testDataRoot) {
        Remove-Item `
            -LiteralPath $testDataRoot `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }
}
'@

Set-Content `
    -LiteralPath $smokeTestPath `
    -Value $smokeTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

### The Verification

Run:

```powershell
$smokeResult = & $smokeTestPath

$smokeResult |
    Format-List
```

Expected properties include:

```text
Passed             : True
RemainingTaskId    : 2
RemainingTaskTitle : Second smoke-test task
```

Verify that the test data was cleaned:

```powershell
[PSCustomObject]@{
    SmokeTestPassed = $smokeResult.Passed -eq $true
    TemporaryDataWasRemoved = -not (
        Test-Path -LiteralPath $smokeResult.DataDirectory
    )
    ParentEnvironmentWasRestored = (
        $env:DEVTASKS_DATA_DIR -eq
        $previousDataDirectory
    )
}
```

The first two values should be `True`. The final value should also be `True` when the pre-test state was preserved correctly.

---

## 6.29 Understand Python Environment Variables

### The Target

Inspect Python’s runtime environment and configure the CLI for one PowerShell session.

### The Concept

Python reads operating-system environment variables through:

```python
os.environ
```

or:

```python
os.environ.get("NAME")
```

The same parent-child inheritance rules from Part 4 apply:

```text
PowerShell process
        │
        ▼
Python child process
```

The CLI uses:

```text
DEVTASKS_DATA_DIR
```

to override its default data location.

### The Implementation

Set a temporary value:

```powershell
$temporaryTaskDirectory = Join-Path `
    -Path $env:TEMP `
    -ChildPath "devtasks-environment-demo"

$env:DEVTASKS_DATA_DIR = $temporaryTaskDirectory
```

Inspect it through Python:

```powershell
python -c @'
import os

print(
    os.environ.get(
        "DEVTASKS_DATA_DIR",
        "[not set]",
    )
)
'@
```

Inspect the CLI’s resolved configuration:

```powershell
devtasks config
```

Remove the variable:

```powershell
Remove-Item `
    Env:DEVTASKS_DATA_DIR `
    -ErrorAction SilentlyContinue
```

Inspect the default:

```powershell
devtasks config
```

### The Verification

Run:

```powershell
$env:DEVTASKS_DATA_DIR = $temporaryTaskDirectory

try {
    $configJson = devtasks config
    $config = $configJson -join "`n" |
        ConvertFrom-Json

    $expectedDirectory = (
        [System.IO.Path]::GetFullPath(
            $temporaryTaskDirectory
        )
    )

    $actualDirectory = (
        [System.IO.Path]::GetFullPath(
            $config.data_directory
        )
    )

    $overrideWorked = $actualDirectory -eq $expectedDirectory
}
finally {
    Remove-Item `
        Env:DEVTASKS_DATA_DIR `
        -ErrorAction SilentlyContinue
}

$overrideWorked
```

Expected result:

```text
True
```

---

## 6.30 Understand `PYTHONPATH`

### The Target

Understand why `PYTHONPATH` was used before editable installation and why it should not be a routine project-global workaround.

### The Concept

`PYTHONPATH` adds directories to Python’s module search path.

Earlier, this temporary value allowed:

```text
src/
```

to be imported before the package was installed.

However, persistent `PYTHONPATH` configuration can cause:

- Imports from unexpected projects
- Hidden dependencies on shell state
- Different behavior across computers
- Tests passing against the wrong source tree

Prefer:

- Editable installation during development
- Wheel installation for deployment
- Explicit test configuration
- A project virtual environment

### The Implementation

Inspect Python’s module search path:

```powershell
python -c @'
import json
import sys

print(json.dumps(sys.path, indent=2))
'@
```

Inspect `PYTHONPATH`:

```powershell
Get-Item `
    Env:PYTHONPATH `
    -ErrorAction SilentlyContinue
```

Confirm that the installed package can be imported without `PYTHONPATH`:

```powershell
Remove-Item `
    Env:PYTHONPATH `
    -ErrorAction SilentlyContinue

python -c @'
import devtasks

print(devtasks.__version__)
print(devtasks.__file__)
'@
```

### The Verification

Run:

```powershell
$modulePath = python -c "import devtasks; print(devtasks.__file__)"

[PSCustomObject]@{
    PythonPathVariableIsAbsent = -not (
        Test-Path Env:PYTHONPATH
    )
    PackageImportsSuccessfully = -not (
        [string]::IsNullOrWhiteSpace($modulePath)
    )
}
```

Both values should be `True`.

Because this is an editable installation, the reported module path should point into:

```text
src\devtasks
```

---

## 6.31 Understand Virtual-Environment Activation and Execution Policy

### The Target

Handle a blocked `Activate.ps1` safely.

### The Concept

The virtual environment’s PowerShell activation file is a script:

```text
.venv\Scripts\Activate.ps1
```

PowerShell execution policy may block it.

Activation is convenient, but it is not required. The narrowest workaround is to call the interpreter directly:

```powershell
.\.venv\Scripts\python.exe
```

This mirrors the earlier npm lesson:

```text
Use the narrowest working execution path before changing policy.
```

### The Implementation

Inspect execution policy:

```powershell
Get-ExecutionPolicy -List
```

Inspect the activation script:

```powershell
Get-Item `
    -LiteralPath .\.venv\Scripts\Activate.ps1 |
    Select-Object Name, FullName, Length
```

If activation is blocked, use:

```powershell
.\.venv\Scripts\python.exe --version

.\.venv\Scripts\python.exe `
    -m pip --version

.\.venv\Scripts\python.exe `
    -m unittest discover -s tests -v
```

A temporary process-scoped policy may be appropriate in an approved development environment:

```powershell
Set-ExecutionPolicy `
    -Scope Process `
    -ExecutionPolicy Bypass
```

Then:

```powershell
.\.venv\Scripts\Activate.ps1
```

The process-scoped policy disappears when the terminal closes.

Do not apply:

```text
Unrestricted
```

at machine scope merely to activate one virtual environment.

### The Verification

Whether activated or not, verify the project interpreter directly:

```powershell
$directPython = .\.venv\Scripts\python.exe `
    -c "import sys; print(sys.executable)"

$expectedPython = (
    Resolve-Path `
        -LiteralPath .\.venv\Scripts\python.exe
).Path

[System.IO.Path]::GetFullPath($directPython) -eq
    [System.IO.Path]::GetFullPath($expectedPython)
```

Expected result:

```text
True
```

---

## 6.32 Deactivate and Reactivate the Environment

### The Target

Understand what changes when the environment is deactivated.

### The Concept

Deactivation restores the shell’s previous command-resolution state.

It does not:

- Delete `.venv`
- Uninstall packages
- Remove project source
- Remove the editable installation from `.venv`

### The Implementation

Record the active command:

```powershell
$activePythonSource = (
    Get-Command python
).Source

$activePythonSource
```

Deactivate:

```powershell
deactivate
```

Inspect command resolution:

```powershell
Get-Command python |
    Select-Object Name, Source

$env:VIRTUAL_ENV
```

The virtual-environment variable should be absent.

Reactivate:

```powershell
.\.venv\Scripts\Activate.ps1
```

If activation is blocked, continue with explicit `.venv` interpreter paths.

### The Verification

After reactivation:

```powershell
$reactivatedPythonSource = (
    Get-Command python
).Source

[PSCustomObject]@{
    VirtualEnvironmentIsSet = -not (
        [string]::IsNullOrWhiteSpace($env:VIRTUAL_ENV)
    )
    PythonCommandIsInsideVenv = (
        $reactivatedPythonSource.StartsWith(
            (Resolve-Path .\.venv).Path,
            [System.StringComparison]::OrdinalIgnoreCase
        )
    )
}
```

Both values should be `True`.

---

## 6.33 Add PowerShell Profile Functions

### The Target

Optionally add reusable Python-project functions to the PowerShell profile.

The functions will:

- Enter the Python project
- Activate its virtual environment
- Run the quality gate
- Run the CLI smoke test

### The Concept

Profile functions improve convenience, but they should remain general and nonsecret.

Do not store:

- `DEVTASKS_DATA_DIR` globally
- Passwords
- Tokens
- Production configuration

The data-directory override should remain explicit and temporary.

### The Implementation

Back up the profile:

```powershell
$profilePath = $PROFILE.CurrentUserCurrentHost
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
        -Force
}

if (Test-Path -LiteralPath $profilePath) {
    $profileBackup = (
        $profilePath +
        "." +
        (Get-Date -Format "yyyyMMdd-HHmmss") +
        ".backup"
    )

    Copy-Item `
        -LiteralPath $profilePath `
        -Destination $profileBackup `
        -ErrorAction Stop
}
else {
    $null = New-Item `
        -Path $profilePath `
        -ItemType File
}
```

Create a marked profile block:

```powershell
$pythonProfileBlock = @'
# BEGIN PYTHON DEVELOPER CLI

function Enter-PythonDeveloperCli {
    [CmdletBinding()]
    param()

    $projectRoot = Join-Path `
        -Path $HOME `
        -ChildPath "cli-developer-environment-series\python-developer-cli"

    if (-not (
        Test-Path `
            -LiteralPath $projectRoot `
            -PathType Container
    )) {
        throw "Python CLI project does not exist: $projectRoot"
    }

    Set-Location -LiteralPath $projectRoot
}

function Enable-PythonDeveloperCli {
    [CmdletBinding()]
    param()

    Enter-PythonDeveloperCli

    $activationScript = Join-Path `
        -Path (Get-Location).Path `
        -ChildPath ".venv\Scripts\Activate.ps1"

    if (-not (
        Test-Path `
            -LiteralPath $activationScript `
            -PathType Leaf
    )) {
        throw "Virtual-environment activation script is missing."
    }

    & $activationScript
}

function Invoke-PythonDeveloperCliCheck {
    [CmdletBinding()]
    param()

    Enter-PythonDeveloperCli

    & .\scripts\Invoke-PythonQualityGate.ps1
}

function Test-PythonDeveloperCli {
    [CmdletBinding()]
    param()

    Enter-PythonDeveloperCli

    & .\scripts\Test-PythonCli.ps1
}

Set-Alias `
    -Name pydev `
    -Value Enter-PythonDeveloperCli

# END PYTHON DEVELOPER CLI
'@
```

Append it only if absent:

```powershell
$currentProfileText = Get-Content `
    -LiteralPath $profilePath `
    -Raw `
    -ErrorAction SilentlyContinue

if ($null -eq $currentProfileText) {
    $currentProfileText = ""
}

if (
    $currentProfileText -notmatch
    [regex]::Escape(
        "# BEGIN PYTHON DEVELOPER CLI"
    )
) {
    Add-Content `
        -LiteralPath $profilePath `
        -Value "`n$pythonProfileBlock" `
        -Encoding UTF8
}
else {
    Write-Host "Python profile block already exists." `
        -ForegroundColor Yellow
}
```

### The Verification

Parse the profile:

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

    throw "The PowerShell profile contains syntax errors."
}
```

Load it:

```powershell
. $profilePath
```

Verify commands:

```powershell
Get-Command `
    Enter-PythonDeveloperCli,
    Enable-PythonDeveloperCli,
    Invoke-PythonDeveloperCliCheck,
    Test-PythonDeveloperCli,
    pydev |
    Select-Object Name, CommandType, Definition
```

Confirm the profile does not globally assign the data override:

```powershell
$profileText = Get-Content `
    -LiteralPath $profilePath `
    -Raw

$profileAssignsDataDirectory = (
    $profileText -match
    '(?m)^\s*\$env:DEVTASKS_DATA_DIR\s*='
)

if ($profileAssignsDataDirectory) {
    throw (
        "The profile must not assign " +
        "DEVTASKS_DATA_DIR globally."
    )
}
```

---

## 6.34 Understand Python CLI Exit Codes

### The Target

Observe success, item-not-found, and command-usage exit codes.

### The Concept

CLI programs communicate outcomes through both:

- Human-readable output
- Numeric process exit codes

This allows PowerShell and CI systems to decide whether a command succeeded.

The application uses:

```text
0 → success
1 → storage/runtime failure
2 → input or requested-item error
```

`argparse` also normally uses exit code `2` for invalid command syntax.

### The Implementation

Use isolated data:

```powershell
$exitCodeDataDirectory = Join-Path `
    -Path $env:TEMP `
    -ChildPath "devtasks-exit-code-demo"

if (Test-Path -LiteralPath $exitCodeDataDirectory) {
    Remove-Item `
        -LiteralPath $exitCodeDataDirectory `
        -Recurse `
        -Force
}

$env:DEVTASKS_DATA_DIR = $exitCodeDataDirectory
```

Run a successful command:

```powershell
devtasks add "Exit-code demonstration"
$successCode = $LASTEXITCODE
```

Request a missing task:

```powershell
devtasks remove 999
$missingCode = $LASTEXITCODE
```

Pass invalid syntax:

```powershell
devtasks complete not-a-number
$usageCode = $LASTEXITCODE
```

Create malformed storage:

```powershell
Set-Content `
    -LiteralPath "$exitCodeDataDirectory\tasks.json" `
    -Value "{invalid-json" `
    -Encoding UTF8

devtasks list
$storageCode = $LASTEXITCODE
```

Clean up:

```powershell
Remove-Item Env:DEVTASKS_DATA_DIR `
    -ErrorAction SilentlyContinue

Remove-Item `
    -LiteralPath $exitCodeDataDirectory `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue
```

### The Verification

Run:

```powershell
[PSCustomObject]@{
    SuccessCode = $successCode
    MissingTaskCode = $missingCode
    UsageErrorCode = $usageCode
    StorageErrorCode = $storageCode
    SuccessIsZero = $successCode -eq 0
    MissingTaskIsTwo = $missingCode -eq 2
    UsageErrorIsTwo = $usageCode -eq 2
    StorageErrorIsOne = $storageCode -eq 1
}
```

All four Boolean checks should be `True`.

---

# Part 6 Reference A: Python Command Resolution

## Windows launcher

List interpreters:

```powershell
py --list
```

Run Python 3:

```powershell
py -3
```

Run a particular installed minor version:

```powershell
py -3.12
```

Only use a requested version if it is installed and supported.

## Direct interpreter

```powershell
python --version
```

Inspect its executable:

```powershell
python -c "import sys; print(sys.executable)"
```

## Virtual-environment interpreter

```powershell
.\.venv\Scripts\python.exe --version
```

This is the clearest choice in automation because it identifies one exact interpreter.

## Package installation

Preferred:

```powershell
python -m pip install package-name
```

More ambiguous:

```powershell
pip install package-name
```

---

# Part 6 Reference B: Virtual Environments

## Create

```powershell
py -3 -m venv .venv
```

## Activate in PowerShell

```powershell
.\.venv\Scripts\Activate.ps1
```

## Deactivate

```powershell
deactivate
```

## Run without activation

```powershell
.\.venv\Scripts\python.exe `
    -m pip install `
    --editable .
```

## Remove and rebuild

A virtual environment is generated state. After confirming the exact project path:

```powershell
Remove-Item `
    -LiteralPath .\.venv `
    -Recurse `
    -Force `
    -WhatIf
```

Then, after reviewing the preview:

```powershell
Remove-Item `
    -LiteralPath .\.venv `
    -Recurse `
    -Force

py -3 -m venv .venv
```

Reinstall the project and tools afterward.

Do not commit `.venv`.

---

# Part 6 Reference C: pip Commands

## Display pip version

```powershell
python -m pip --version
```

## Upgrade pip

```powershell
python -m pip install --upgrade pip
```

## Install a package

```powershell
python -m pip install ruff
```

## Install the current project

```powershell
python -m pip install .
```

## Editable installation

```powershell
python -m pip install --editable .
```

Short form:

```powershell
python -m pip install -e .
```

## Show installed project information

```powershell
python -m pip show devtasks-cli
```

## List installed packages

```powershell
python -m pip list
```

## Check dependency consistency

```powershell
python -m pip check
```

## Uninstall

```powershell
python -m pip uninstall devtasks-cli
```

Do not uninstall the tutorial package until all exercises are complete.

---

# Part 6 Reference D: `pyproject.toml`

## Build system

```toml
[build-system]
requires = ["setuptools>=69", "wheel"]
build-backend = "setuptools.build_meta"
```

This tells frontends such as `build` which backend constructs the package.

## Project metadata

```toml
[project]
name = "devtasks-cli"
version = "1.0.0"
requires-python = ">=3.11"
dependencies = []
```

## Console command

```toml
[project.scripts]
devtasks = "devtasks.cli:main"
```

The format is:

```text
command-name = "module.path:function_name"
```

## Package discovery

```toml
[tool.setuptools]
package-dir = { "" = "src" }

[tool.setuptools.packages.find]
where = ["src"]
```

## Ruff configuration

```toml
[tool.ruff]
target-version = "py311"
line-length = 88
src = ["src", "tests"]
```

---

# Part 6 Reference E: Python Modules and Packages

## Module

One Python file:

```text
models.py
```

Imported as:

```python
from devtasks import models
```

## Package

A directory of related modules:

```text
devtasks/
├── __init__.py
├── cli.py
├── models.py
└── storage.py
```

## `__init__.py`

Marks and initializes a regular package:

```python
"""Developer task CLI package."""

__version__ = "1.0.0"
```

## `__main__.py`

Supports:

```powershell
python -m devtasks
```

## Import path

```python
from devtasks.storage import load_tasks
```

Avoid manipulating `sys.path` in ordinary application code merely to make imports work. Install the project properly.

---

# Part 6 Reference F: `argparse`

## Create a parser

```python
parser = argparse.ArgumentParser(
    prog="example",
    description="Example command.",
)
```

## Positional argument

```python
parser.add_argument(
    "title",
    help="Task title.",
)
```

## Optional argument

```python
parser.add_argument(
    "--status",
    choices=("all", "open", "completed"),
    default="all",
)
```

## Boolean switch

```python
parser.add_argument(
    "--json",
    action="store_true",
)
```

## Subcommands

```python
subparsers = parser.add_subparsers(
    dest="command",
    required=True,
)
```

## Validation function

```python
def positive_integer(raw_value: str) -> int:
    value = int(raw_value)

    if value < 1:
        raise argparse.ArgumentTypeError(
            "value must be positive"
        )

    return value
```

## Parse explicit test arguments

```python
arguments = parser.parse_args(
    [
        "complete",
        "1",
    ]
)
```

Passing explicit lists improves testability.

---

# Part 6 Reference G: Python Type Hints

Type hints communicate expected shapes:

```python
def load_tasks(path: Path) -> list[Task]:
    ...
```

Common hints include:

```python
str
int
bool
Path
list[Task]
dict[str, object]
str | None
Sequence[str]
```

Type hints do not automatically validate untrusted runtime data.

This remains necessary:

```python
if not isinstance(task_id, int):
    raise ValueError("Task ID must be an integer.")
```

Optional future tooling includes:

- mypy
- Pyright
- basedpyright

If adding a type checker, configure it in `pyproject.toml` and include it in the quality gate.

---

# Part 6 Reference H: JSON Storage Safety

## Validate before use

Never assume decoded JSON has the expected structure:

```python
document = json.load(file)

if not isinstance(document, dict):
    raise StorageError("Expected a JSON object.")
```

## Atomic replacement

Safer pattern:

```text
write temporary file
flush it
close it
replace destination
```

This reduces partial-write risk.

## Remaining limitations

The tutorial storage layer does not provide:

- Multi-process locking
- Database transactions
- Concurrent writer coordination
- Encryption
- Automatic backups
- Cross-device replacement guarantees
- Recovery from every filesystem failure

For concurrent or larger applications, use an appropriate database and locking strategy.

---

# Part 6 Reference I: Testing with `unittest`

## Test case

```python
class ExampleTests(unittest.TestCase):
    def test_addition(self) -> None:
        self.assertEqual(2 + 3, 5)
```

## Run one module

```powershell
python -m unittest `
    tests.test_storage `
    -v
```

## Discover tests

```powershell
python -m unittest `
    discover `
    -s tests `
    -v
```

## Temporary directories

```python
with TemporaryDirectory() as directory:
    path = Path(directory) / "data.json"
```

## Capture output

```python
with redirect_stdout(output):
    exit_code = run(["list"])
```

## Expected error

```python
with self.assertRaisesRegex(
    StorageError,
    "invalid JSON",
):
    load_tasks(path)
```

## Test isolation

Each test should control:

- Input arguments
- Data-file paths
- Environment values
- Standard output
- Standard error
- Cleanup

A test should not depend on the learner’s real task database.

---

# Part 6 Reference J: Ruff

## Check formatting

```powershell
python -m ruff format `
    --check `
    .
```

## Preview formatting changes

```powershell
python -m ruff format `
    --diff `
    .
```

## Apply formatting

```powershell
python -m ruff format .
```

## Run linting

```powershell
python -m ruff check .
```

## Preview available fixes

```powershell
python -m ruff check `
    --diff `
    .
```

## Apply safe automatic fixes

```powershell
python -m ruff check `
    --fix `
    .
```

Always rerun:

```powershell
python -m ruff format --check .
python -m ruff check .
python -m unittest discover -s tests -v
```

after applying automatic changes.

Formatting and linting do not replace tests. They verify different concerns:

```text
formatter → consistent layout
linter    → suspicious or inconsistent patterns
tests     → expected behavior
```

---

# Part 6 Reference K: Building Python Packages

## Install the build frontend

```powershell
python -m pip install build
```

## Build both distribution types

```powershell
python -m build
```

Expected artifacts resemble:

```text
dist/
├── devtasks_cli-1.0.0-py3-none-any.whl
└── devtasks_cli-1.0.0.tar.gz
```

The exact normalized filename follows Python packaging conventions. The project name:

```text
devtasks-cli
```

commonly becomes:

```text
devtasks_cli
```

in distribution filenames.

## Build only a wheel

```powershell
python -m build --wheel
```

## Build only a source distribution

```powershell
python -m build --sdist
```

## Install a local wheel

```powershell
python -m pip install `
    .\dist\devtasks_cli-1.0.0-py3-none-any.whl
```

Avoid hardcoding the filename when version numbers may change:

```powershell
$wheel = Get-ChildItem `
    -LiteralPath .\dist `
    -Filter "*.whl" `
    -File |
    Select-Object -First 1

python -m pip install $wheel.FullName
```

## Install without using a package index

```powershell
python -m pip install `
    --no-index `
    $wheel.FullName
```

This is useful when verifying that a local wheel has no undeclared external runtime dependencies.

---

# Part 6 Reference L: Editable Versus Wheel Installation

## Editable installation

```powershell
python -m pip install --editable .
```

Use during development.

Advantages:

- Source edits are immediately reflected.
- The console entry point is installed.
- Imports use the project source tree.

Limitations:

- It can hide packaging omissions.
- It is not the artifact normally deployed.

## Wheel installation

```powershell
python -m pip install `
    .\dist\package.whl
```

Use for artifact verification and deployment-like testing.

Advantages:

- Tests the actual built artifact.
- Reveals missing packaged files.
- Does not depend on the source checkout after installation.

A strong workflow uses both:

```text
editable install
      ↓
development and tests
      ↓
build wheel
      ↓
clean-environment wheel test
```

---

# Part 6 Reference M: Python Environment Variables

## Read in Python

```python
import os

value = os.environ.get("DEVTASKS_DATA_DIR")
```

## Require a variable

```python
import os

value = os.environ.get("REQUIRED_NAME")

if value is None or not value.strip():
    raise RuntimeError(
        "REQUIRED_NAME is required."
    )
```

## Set temporarily in PowerShell

```powershell
$env:DEVTASKS_DATA_DIR = "$env:TEMP\devtasks-demo"
```

## Remove it

```powershell
Remove-Item `
    Env:DEVTASKS_DATA_DIR `
    -ErrorAction SilentlyContinue
```

## Restore previous state safely

```powershell
$previousValue = $env:DEVTASKS_DATA_DIR

try {
    $env:DEVTASKS_DATA_DIR = "$env:TEMP\devtasks-demo"

    devtasks list
}
finally {
    if ($null -eq $previousValue) {
        Remove-Item `
            Env:DEVTASKS_DATA_DIR `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:DEVTASKS_DATA_DIR = $previousValue
    }
}
```

Environment variables are strings. Convert and validate values when a Python application expects numbers, Boolean values, paths, or enumerated modes.

---

# Part 6 Reference N: Python CLI Exit Codes

A CLI should communicate success or failure to its caller.

## Python

```python
def main() -> None:
    raise SystemExit(run())
```

## PowerShell

Immediately inspect:

```powershell
devtasks remove 999
$LASTEXITCODE
```

## Conventional meanings in this project

| Exit code | Meaning |
|---:|---|
| `0` | Command succeeded |
| `1` | Storage or runtime failure |
| `2` | Usage, input, or missing-task error |

## PowerShell automation check

```powershell
devtasks add "Automated task"

if ($LASTEXITCODE -ne 0) {
    throw "The devtasks command failed."
}
```

Do not rely only on printed words. Machine-readable exit codes allow scripts and CI systems to stop when a command fails.

---

# Part 6 Reference O: Python CLI Security and Reliability

This CLI is intentionally local and small, but it still follows several defensive practices.

## Input validation

The application validates:

- Positive integer IDs
- Nonempty titles
- Maximum title length
- JSON document shape
- Schema version
- Duplicate IDs
- Stored field types

## Filesystem behavior

The application:

- Stores runtime data outside source
- Creates missing parent directories
- Writes to a temporary file
- Flushes before replacement
- Cleans a temporary file after failure

## Output behavior

The application:

- Sends normal results to standard output
- Sends errors to standard error
- Uses nonzero exit codes for failures
- Supports JSON output for automation

## Limitations

The tutorial CLI does not provide:

- User authentication
- Encryption at rest
- Multi-user access control
- Multi-process locking
- A relational database
- Cloud synchronization
- Automatic backup or history
- Protection against a malicious local user with equivalent permissions

Choose architecture according to actual risk and concurrency requirements.

---

# Part 6 Reference P: Common Python CLI Mistakes

## Mistake 1: Installing packages globally

Risky:

```powershell
pip install ruff
```

Preferred:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install ruff
```

## Mistake 2: Using a bare `pip` without checking its interpreter

Prefer:

```powershell
python -m pip
```

Verify:

```powershell
python -c "import sys; print(sys.executable)"
python -m pip --version
```

## Mistake 3: Committing `.venv`

The environment is generated and machine-specific. Ignore it:

```gitignore
.venv/
```

## Mistake 4: Persisting `PYTHONPATH` globally

This can make imports resolve from unexpected directories. Install the project properly instead.

## Mistake 5: Running tests against real user data

Use:

```python
TemporaryDirectory()
```

or inject an explicit test path.

## Mistake 6: Testing only an editable installation

Build and install the wheel in a clean environment as well.

## Mistake 7: Treating type hints as runtime validation

External JSON still requires explicit validation.

## Mistake 8: Ignoring process exit codes

A CLI can print an error and still be mishandled by automation unless it returns a nonzero code.

## Mistake 9: Manually editing generated package metadata

Do not edit:

```text
*.egg-info/
dist/
build/
```

Change source or `pyproject.toml`, then rebuild.

## Mistake 10: Storing runtime data inside the package directory

Installed package files may be read-only, replaced during upgrades, or shared in unexpected ways. Store user data in an appropriate external directory.

## Mistake 11: Publishing accidentally

Do not upload tutorial packages to a public package index without:

- Selecting an appropriate unique name
- Reviewing every packaged file
- Removing secrets
- Configuring trusted publication
- Following organizational release procedures

## Mistake 12: Changing execution policy globally for activation

Activation is optional. Use the exact virtual-environment interpreter when scripts are restricted.

---

# Part 6 Reference Q: Compact Command Cookbook

## Discover Python

```powershell
Get-Command python, py -All `
    -ErrorAction SilentlyContinue

py --list
py -3 --version
```

## Create the environment

```powershell
py -3 -m venv .venv
```

## Activate

```powershell
.\.venv\Scripts\Activate.ps1
```

## Run without activation

```powershell
.\.venv\Scripts\python.exe --version
```

## Upgrade pip

```powershell
python -m pip install --upgrade pip
```

## Install development tools

```powershell
python -m pip install build ruff
```

## Install the project for development

```powershell
python -m pip install --editable .
```

## Display help

```powershell
devtasks --help
```

## Add and list tasks

```powershell
devtasks add "Write documentation"
devtasks list
```

## Complete and remove tasks

```powershell
devtasks complete 1
devtasks remove 1
```

## JSON output

```powershell
devtasks list --json
```

## Temporary data directory

```powershell
$env:DEVTASKS_DATA_DIR = "$env:TEMP\devtasks-demo"
```

## Format

```powershell
python -m ruff format .
```

## Lint

```powershell
python -m ruff check .
```

## Test

```powershell
python -m unittest discover -s tests -v
```

## Compile

```powershell
python -m compileall -q src tests
```

## Build

```powershell
python -m build
```

## Run the complete quality gate

```powershell
& .\scripts\Invoke-PythonQualityGate.ps1
```

## Run the CLI smoke test

```powershell
& .\scripts\Test-PythonCli.ps1
```

## Deactivate

```powershell
deactivate
```

---

# Part 6 Final Verification

## The Target

Verify the complete Python CLI project from interpreter selection through built-package execution.

## The Concept

The final checkpoint verifies independent layers:

```text
Python interpreter
        ↓
virtual environment
        ↓
editable package installation
        ↓
formatting and linting
        ↓
compilation
        ↓
unit tests
        ↓
wheel and source build
        ↓
installed CLI smoke test
        ↓
isolated runtime data
```

A successful `devtasks list` command alone would not prove that the wheel contains all source modules or that tests avoid real user data.

## The Implementation

Reconstruct the project path:

```powershell
$seriesRoot = Join-Path `
    -Path $HOME `
    -ChildPath "cli-developer-environment-series"

$pythonProjectRoot = Join-Path `
    -Path $seriesRoot `
    -ChildPath "python-developer-cli"

if (-not (
    Test-Path `
        -LiteralPath $pythonProjectRoot `
        -PathType Container
)) {
    throw "Python CLI project is missing: $pythonProjectRoot"
}

Set-Location -LiteralPath $pythonProjectRoot
```

Use the exact virtual-environment interpreter:

```powershell
$pythonPath = Join-Path `
    -Path $pythonProjectRoot `
    -ChildPath ".venv\Scripts\python.exe"

if (-not (
    Test-Path `
        -LiteralPath $pythonPath `
        -PathType Leaf
)) {
    throw "Virtual-environment interpreter is missing: $pythonPath"
}
```

Synchronize the editable installation:

```powershell
& $pythonPath `
    -m pip install `
    --editable .

if ($LASTEXITCODE -ne 0) {
    throw "Editable installation failed."
}
```

Run dependency consistency checking:

```powershell
& $pythonPath -m pip check

$pipCheckPassed = $LASTEXITCODE -eq 0
```

Run the quality gate:

```powershell
$qualityScriptPath = Join-Path `
    -Path $pythonProjectRoot `
    -ChildPath "scripts\Invoke-PythonQualityGate.ps1"

& $qualityScriptPath

$qualityGatePassed = $?
```

Run the CLI smoke test:

```powershell
$smokeTestPath = Join-Path `
    -Path $pythonProjectRoot `
    -ChildPath "scripts\Test-PythonCli.ps1"

$smokeResult = & $smokeTestPath
```

Inspect the package metadata:

```powershell
$packageVersion = & $pythonPath -c @'
import devtasks

print(devtasks.__version__)
'@

$packageFile = & $pythonPath -c @'
import devtasks

print(devtasks.__file__)
'@
```

Inspect generated artifacts:

```powershell
$wheelFiles = @(
    Get-ChildItem `
        -LiteralPath .\dist `
        -Filter "*.whl" `
        -File
)

$sourceDistributions = @(
    Get-ChildItem `
        -LiteralPath .\dist `
        -Filter "*.tar.gz" `
        -File
)
```

Build the file checks:

```powershell
$requiredProjectFiles = @(
    ".\pyproject.toml"
    ".\README.md"
    ".\.gitignore"
    ".\src\devtasks\__init__.py"
    ".\src\devtasks\__main__.py"
    ".\src\devtasks\cli.py"
    ".\src\devtasks\models.py"
    ".\src\devtasks\storage.py"
    ".\tests\__init__.py"
    ".\tests\test_cli.py"
    ".\tests\test_storage.py"
    ".\scripts\Invoke-PythonQualityGate.ps1"
    ".\scripts\Test-PythonCli.ps1"
)

$projectFileChecks = foreach (
    $requiredFile in $requiredProjectFiles
) {
    [PSCustomObject]@{
        Check = "Required file exists: $requiredFile"
        Passed = Test-Path `
            -LiteralPath $requiredFile `
            -PathType Leaf
    }
}
```

Check Git exclusions:

```powershell
if (Get-Command git -ErrorAction SilentlyContinue) {
    if (-not (Test-Path -LiteralPath .\.git)) {
        git init
    }

    git check-ignore -q .venv
    $venvIsIgnored = $LASTEXITCODE -eq 0

    git check-ignore -q dist
    $distIsIgnored = $LASTEXITCODE -eq 0
}
else {
    $gitIgnoreText = Get-Content `
        -LiteralPath .\.gitignore `
        -Raw

    $venvIsIgnored = (
        $gitIgnoreText -match "(?m)^\.venv/$"
    )

    $distIsIgnored = (
        $gitIgnoreText -match "(?m)^dist/$"
    )
}
```

Check that temporary environment overrides are absent:

```powershell
$environmentChecks = @(
    [PSCustomObject]@{
        Check = "DEVTASKS_DATA_DIR is absent"
        Passed = -not (
            Test-Path Env:DEVTASKS_DATA_DIR
        )
    }

    [PSCustomObject]@{
        Check = "PYTHONPATH is absent"
        Passed = -not (
            Test-Path Env:PYTHONPATH
        )
    }
)
```

Create the complete result:

```powershell
$partSixChecks = @(
    $projectFileChecks

    [PSCustomObject]@{
        Check = "Virtual environment exists"
        Passed = Test-Path `
            -LiteralPath .\.venv `
            -PathType Container
    }

    [PSCustomObject]@{
        Check = "Virtual-environment Python exists"
        Passed = Test-Path `
            -LiteralPath $pythonPath `
            -PathType Leaf
    }

    [PSCustomObject]@{
        Check = "pip dependency check passed"
        Passed = $pipCheckPassed
    }

    [PSCustomObject]@{
        Check = "Quality gate passed"
        Passed = $qualityGatePassed
    }

    [PSCustomObject]@{
        Check = "CLI smoke test passed"
        Passed = $smokeResult.Passed -eq $true
    }

    [PSCustomObject]@{
        Check = "Package version is 1.0.0"
        Passed = $packageVersion -eq "1.0.0"
    }

    [PSCustomObject]@{
        Check = "Package imports from project source"
        Passed = (
            [System.IO.Path]::GetFullPath($packageFile)
        ).StartsWith(
            [System.IO.Path]::GetFullPath(
                "$pythonProjectRoot\src\devtasks"
            ),
            [System.StringComparison]::OrdinalIgnoreCase
        )
    }

    [PSCustomObject]@{
        Check = "Exactly one wheel exists"
        Passed = $wheelFiles.Count -eq 1
    }

    [PSCustomObject]@{
        Check = "Exactly one source distribution exists"
        Passed = $sourceDistributions.Count -eq 1
    }

    [PSCustomObject]@{
        Check = ".venv is ignored"
        Passed = $venvIsIgnored
    }

    [PSCustomObject]@{
        Check = "dist is ignored"
        Passed = $distIsIgnored
    }

    $environmentChecks
)
```

### The Verification

Display all checks:

```powershell
$partSixChecks |
    Format-Table Check, Passed -AutoSize
```

Find failures:

```powershell
$failedPartSixChecks = @(
    $partSixChecks |
        Where-Object {
            -not $_.Passed
        }
)
```

Report the result:

```powershell
if ($failedPartSixChecks.Count -eq 0) {
    Write-Host (
        "Part 6 final verification passed. " +
        "The Python CLI is ready."
    ) -ForegroundColor Green
}
else {
    Write-Host "Part 6 final verification failed." `
        -ForegroundColor Red

    $failedPartSixChecks |
        Format-Table Check, Passed -AutoSize

    throw "Repair the failed Part 6 checks."
}
```

Expected final message:

```text
Part 6 final verification passed. The Python CLI is ready.
```

---

# Part 6 Readiness Challenge

## The Target

Demonstrate the complete Python CLI lifecycle without using the real default task database.

The challenge will:

1. Verify the interpreter.
2. Create a unique temporary data directory.
3. Add three tasks.
4. Complete one task.
5. Verify JSON output.
6. Remove one task.
7. Clear completed tasks.
8. Verify the final task.
9. Run unit tests.
10. Build distributions.
11. Restore the parent environment.
12. Remove temporary data.

## The Concept

This exercise combines PowerShell process control, Python packaging, CLI behavior, JSON parsing, exit codes, testing, and cleanup.

## The Implementation

Enter the project:

```powershell
Set-Location -LiteralPath $pythonProjectRoot
```

Select the exact interpreter and command:

```powershell
$challengePython = Join-Path `
    -Path $pythonProjectRoot `
    -ChildPath ".venv\Scripts\python.exe"

$challengeCommand = Join-Path `
    -Path $pythonProjectRoot `
    -ChildPath ".venv\Scripts\devtasks.exe"

foreach ($requiredCommandPath in @(
    $challengePython
    $challengeCommand
)) {
    if (-not (
        Test-Path `
            -LiteralPath $requiredCommandPath `
            -PathType Leaf
    )) {
        throw "Required executable is missing: $requiredCommandPath"
    }
}
```

Create a unique data directory:

```powershell
$challengeDataDirectory = Join-Path `
    -Path $env:TEMP `
    -ChildPath (
        "devtasks-readiness-" +
        [System.Guid]::NewGuid().ToString("N")
    )
```

Preserve the parent environment:

```powershell
$previousChallengeDataDirectory = (
    $env:DEVTASKS_DATA_DIR
)

$env:DEVTASKS_DATA_DIR = $challengeDataDirectory
```

Define a checked command helper:

```powershell
function Invoke-ReadinessCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments
    )

    & $challengeCommand @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw (
            "Readiness command failed with exit code " +
            "$LASTEXITCODE: " +
            ($Arguments -join " ")
        )
    }
}
```

Run the workflow:

```powershell
$readinessResult = $null

try {
    Invoke-ReadinessCommand `
        -Arguments @(
            "add"
            "Review Python packaging"
        )

    Invoke-ReadinessCommand `
        -Arguments @(
            "add"
            "Complete the readiness test"
        )

    Invoke-ReadinessCommand `
        -Arguments @(
            "add"
            "Preserve this final task"
        )

    Invoke-ReadinessCommand `
        -Arguments @(
            "complete"
            "2"
        )

    $initialJson = & $challengeCommand list --json

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read initial JSON output."
    }

    $initialTasks = @(
        $initialJson -join [Environment]::NewLine |
            ConvertFrom-Json
    )

    Invoke-ReadinessCommand `
        -Arguments @(
            "remove"
            "1"
        )

    Invoke-ReadinessCommand `
        -Arguments @(
            "clear"
            "--completed"
        )

    $finalJson = & $challengeCommand list --json

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read final JSON output."
    }

    $finalTasks = @(
        $finalJson -join [Environment]::NewLine |
            ConvertFrom-Json
    )

    & $challengePython `
        -m unittest discover `
        -s tests `
        -v

    $testsPassed = $LASTEXITCODE -eq 0

    & $challengePython -m build

    $buildPassed = $LASTEXITCODE -eq 0

    $readinessResult = [PSCustomObject]@{
        InitialTaskCountIsThree = (
            $initialTasks.Count -eq 3
        )
        SecondTaskWasCompleted = (
            (
                $initialTasks |
                    Where-Object id -eq 2
            ).completed -eq $true
        )
        FinalTaskCountIsOne = (
            $finalTasks.Count -eq 1
        )
        FinalTaskIdIsThree = (
            $finalTasks[0].id -eq 3
        )
        FinalTaskTitleIsCorrect = (
            $finalTasks[0].title -eq
            "Preserve this final task"
        )
        FinalTaskIsOpen = (
            $finalTasks[0].completed -eq $false
        )
        UnitTestsPassed = $testsPassed
        PackageBuildPassed = $buildPassed
        DataFileExistsDuringTest = Test-Path `
            -LiteralPath "$challengeDataDirectory\tasks.json" `
            -PathType Leaf
    }
}
finally {
    if ($null -eq $previousChallengeDataDirectory) {
        Remove-Item `
            Env:DEVTASKS_DATA_DIR `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:DEVTASKS_DATA_DIR = (
            $previousChallengeDataDirectory
        )
    }

    if (Test-Path -LiteralPath $challengeDataDirectory) {
        Remove-Item `
            -LiteralPath $challengeDataDirectory `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }

    Remove-Item `
        Function:Invoke-ReadinessCommand `
        -ErrorAction SilentlyContinue
}
```

## The Verification

Add cleanup checks:

```powershell
$cleanupResult = [PSCustomObject]@{
    TemporaryDataWasRemoved = -not (
        Test-Path -LiteralPath $challengeDataDirectory
    )
    ParentEnvironmentWasRestored = (
        $env:DEVTASKS_DATA_DIR -eq
        $previousChallengeDataDirectory
    )
}
```

Combine all properties:

```powershell
$readinessChecks = @(
    $readinessResult.PSObject.Properties
    $cleanupResult.PSObject.Properties
)

$readinessChecks |
    Select-Object Name, Value |
    Format-Table -AutoSize
```

Find failures:

```powershell
$failedReadinessChecks = @(
    $readinessChecks |
        Where-Object {
            $_.Value -ne $true
        }
)
```

Report:

```powershell
if ($failedReadinessChecks.Count -eq 0) {
    Write-Host "Part 6 readiness challenge passed." `
        -ForegroundColor Green
}
else {
    $failedReadinessChecks |
        Select-Object Name, Value |
        Format-Table -AutoSize

    throw "Part 6 readiness challenge failed."
}
```

Expected message:

```text
Part 6 readiness challenge passed.
```

---

# Part 6 Key Takeaways

## Python command selection matters

On Windows:

```text
py      → Python launcher
python  → resolved Python interpreter
pip     → resolved pip executable
```

Prefer:

```powershell
python -m pip
```

because it ties pip to the selected interpreter.

## Virtual environments isolate projects

Create:

```powershell
py -3 -m venv .venv
```

Activate:

```powershell
.\.venv\Scripts\Activate.ps1
```

Or use the interpreter directly:

```powershell
.\.venv\Scripts\python.exe
```

Activation is convenient, not mandatory.

## `pyproject.toml` is the project control file

It declares:

- Build backend
- Project metadata
- Supported Python version
- Dependencies
- Console entry point
- Package discovery
- Ruff configuration

## The `src` layout reduces accidental imports

The installable package lives under:

```text
src\devtasks
```

An editable installation connects that source to the virtual environment:

```powershell
python -m pip install --editable .
```

## `argparse` provides a production-quality standard-library CLI parser

The command tree is:

```text
devtasks
├── add
├── list
├── complete
├── remove
├── clear
└── config
```

It supplies:

- Help
- Subcommands
- Choices
- Type conversion
- Usage errors
- Exit behavior

## The storage layer validates external data

JSON is untrusted input even when the application wrote it previously.

The storage layer checks:

- Document shape
- Schema version
- Task fields
- Field types
- Duplicate IDs

## Atomic replacement reduces partial-write risk

The application writes a temporary file and then replaces the task database.

This is safer than directly truncating and rewriting the destination, though it is not a substitute for database transactions or multi-process locking.

## Tests use temporary data

Automated tests must not alter:

```text
$HOME\.devtasks\tasks.json
```

They inject explicit temporary paths.

## Quality tools verify different concerns

```text
Ruff format → layout
Ruff lint   → static analysis
compileall  → syntax across files
unittest    → behavior
build       → packaging
smoke test  → real installed command
```

## The wheel is the deployment-like artifact

Editable installation supports development. A clean wheel installation verifies the package that would actually be distributed.

## Environment variables follow the same process model

PowerShell supplies:

```text
DEVTASKS_DATA_DIR
```

to a child Python process. The child receives a copy.

Restore or remove temporary values after use.

## Profiles should contain convenience—not hidden state

Appropriate:

```text
Enter-PythonDeveloperCli
Invoke-PythonDeveloperCliCheck
Test-PythonDeveloperCli
```

Inappropriate:

```text
Permanent data-directory overrides
Passwords
Tokens
Production credentials
```

---

# Part 6 Completion Checklist

## Python runtime

- [ ] Discover Python installations
- [ ] Explain `py` versus `python`
- [ ] Explain `pip` versus `python -m pip`
- [ ] Verify Python 3.11 or later
- [ ] Identify the active interpreter path

## Virtual environment

- [ ] Create `.venv`
- [ ] Activate it in PowerShell
- [ ] Run its interpreter directly
- [ ] Explain what activation changes
- [ ] Deactivate and reactivate it
- [ ] Handle a blocked activation script safely

## Project setup

- [ ] Create a `src` layout
- [ ] Create `pyproject.toml`
- [ ] Create `.gitignore`
- [ ] Exclude `.venv`, caches, and build output
- [ ] Install the project in editable mode
- [ ] Run the installed console command

## Python implementation

- [ ] Create a typed task model
- [ ] Validate external JSON data
- [ ] Store schema version metadata
- [ ] Save through temporary-file replacement
- [ ] Build an `argparse` command tree
- [ ] Return meaningful exit codes
- [ ] Support JSON output
- [ ] Support `python -m devtasks`

## Testing and quality

- [ ] Test storage behavior
- [ ] Test CLI behavior
- [ ] Use temporary directories
- [ ] Capture standard output and standard error
- [ ] Run Ruff formatting checks
- [ ] Run Ruff linting
- [ ] Compile all source
- [ ] Run all unit tests
- [ ] Run the PowerShell quality gate

## Packaging

- [ ] Build a source distribution
- [ ] Build a wheel
- [ ] Inspect wheel contents
- [ ] Install the wheel in a clean environment
- [ ] Test the installed console command
- [ ] Remove temporary test environments

## PowerShell integration

- [ ] Set `DEVTASKS_DATA_DIR` temporarily
- [ ] Restore the previous environment state
- [ ] Avoid persistent global `PYTHONPATH`
- [ ] Add optional nonsecret profile functions
- [ ] Run the CLI smoke test
- [ ] Complete final verification

---

# Final Python CLI Architecture

The completed project is:

```text
$HOME/
└── cli-developer-environment-series/
    └── python-developer-cli/
        ├── .venv/
        │   └── Scripts/
        │       ├── python.exe
        │       ├── pip.exe
        │       ├── devtasks.exe
        │       └── Activate.ps1
        │
        ├── dist/
        │   ├── devtasks_cli-1.0.0-py3-none-any.whl
        │   └── devtasks_cli-1.0.0.tar.gz
        │
        ├── scripts/
        │   ├── Invoke-PythonQualityGate.ps1
        │   └── Test-PythonCli.ps1
        │
        ├── src/
        │   └── devtasks/
        │       ├── __init__.py
        │       ├── __main__.py
        │       ├── cli.py
        │       ├── models.py
        │       └── storage.py
        │
        ├── tests/
        │   ├── __init__.py
        │   ├── test_cli.py
        │   └── test_storage.py
        │
        ├── .gitignore
        ├── pyproject.toml
        └── README.md
```

Default user data lives separately:

```text
$HOME/
└── .devtasks/
    └── tasks.json
```

The daily development workflow is:

```powershell
pydev
.\.venv\Scripts\Activate.ps1
python -m pip install --editable .
& .\scripts\Invoke-PythonQualityGate.ps1
& .\scripts\Test-PythonCli.ps1
```

The daily CLI workflow is:

```powershell
devtasks add "Review pull request"
devtasks list
devtasks complete 1
devtasks list --status open
```

The artifact verification workflow is:

```powershell
python -m ruff format --check .
python -m ruff check .
python -m unittest discover -s tests -v
python -m build
```

This Python project now follows the same engineering principles as the Node.js project:

```text
explicit interpreter selection
        ↓
isolated dependencies
        ↓
validated input
        ↓
separated source and runtime data
        ↓
automated tests
        ↓
repeatable quality gate
        ↓
built artifact verification
        ↓
safe PowerShell integration
```
