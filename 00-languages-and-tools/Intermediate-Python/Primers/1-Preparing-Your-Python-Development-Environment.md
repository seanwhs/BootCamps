# Primer 1: Preparing Your Python Development Environment

Before writing clean Python code, you need a clean workspace.

This primer prepares your computer for the rest of the series. You will:

- Confirm that a supported Python version is installed.
- Learn how to run Python from a terminal.
- Create a project folder.
- Create and activate a virtual environment.
- Install and verify development tools.
- Create a simple Python program and run it successfully.

By the end, you will have a working development environment that can support every later part of the tutorial.

---

## Who This Primer Is For

This primer is for readers who:

- Know some basic Python syntax.
- Have written a script or two.
- Are not fully confident with terminals, virtual environments, or package installation.
- Want a reliable setup before beginning the main series.

You do not need to understand object-oriented programming, testing, decorators, or API clients yet.

---

## What You Will Build

At the end of this primer, you will have this small starter project:

```text
pythonic-craftsmanship/
├── .gitignore
├── .venv/
└── hello_python.py
```

The `.venv/` directory is created locally but should not be committed to Git.

---

# Step 1: Confirm That Python Is Installed

## The Target

We are confirming that your computer has Python 3.11 or newer.

## The Concept

Python is both:

1. A programming language.
2. A program called an **interpreter** that reads and runs Python code.

When you run:

```bash
python hello_python.py
```

you are asking the Python interpreter to read and execute the file.

This series uses modern Python syntax such as:

```python
str | None
list[str]
```

For that reason, install Python 3.11 or newer.

## The Implementation

Open a terminal.

### macOS or Linux

Run:

```bash
python3 --version
```

Then also try:

```bash
python --version
```

### Windows PowerShell or Command Prompt

Run:

```powershell
py --version
```

Then also try:

```powershell
python --version
```

If no command works, install Python from:

```text
https://www.python.org/downloads/
```

On Windows, during installation, enable the option similar to:

```text
Add Python to PATH
```

`PATH` is the list of folders your terminal searches when you type a command such as `python`.

## The Verification

You should see output similar to:

```text
Python 3.12.4
```

Python 3.11, 3.12, or 3.13 are all suitable.

If you see Python 2.x, install a modern Python version. Python 2 has reached end of life and is not supported by this series.

---

# Step 2: Create Your Project Directory

## The Target

We are creating a folder named:

```text
pythonic-craftsmanship
```

## The Concept

A project directory is the home for everything related to one program:

- Source code
- Tests
- Documentation
- Configuration
- Local development files

Think of it as a labeled workshop. Keeping each project in its own directory prevents files from unrelated experiments becoming mixed together.

## The Implementation

Choose a location where you keep development projects.

### macOS or Linux

```bash
mkdir -p ~/projects/pythonic-craftsmanship
cd ~/projects/pythonic-craftsmanship
```

### Windows PowerShell

```powershell
mkdir $HOME\projects\pythonic-craftsmanship
cd $HOME\projects\pythonic-craftsmanship
```

### Windows Command Prompt

```bat
mkdir %USERPROFILE%\projects\pythonic-craftsmanship
cd %USERPROFILE%\projects\pythonic-craftsmanship
```

If you already have a preferred projects folder, use that instead.

## The Verification

Run:

### macOS or Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

### Windows Command Prompt

```bat
cd
```

The displayed location should end with:

```text
pythonic-craftsmanship
```

List the directory contents.

### macOS or Linux

```bash
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem -Force
```

The folder should be empty or contain only files you intentionally created.

---

# Step 3: Create a Virtual Environment

## The Target

We are creating a project-local virtual environment:

```text
.venv/
```

## The Concept

A virtual environment is an isolated Python workspace.

Without one, package installations may affect every Python project on your computer. That creates version conflicts.

For example:

```text
Project A needs pytest version X.
Project B needs pytest version Y.
```

A virtual environment gives each project its own tool shelf.

The `.venv` name is a common convention:

- The leading dot suggests it is a local project detail.
- Editors often recognize it automatically.
- The name makes it clear that this is a virtual environment.

## The Implementation

Run one of the following commands from the project root.

### macOS or Linux

```bash
python3 -m venv .venv
```

If `python3` is not the desired modern version but `python` is, use:

```bash
python -m venv .venv
```

### Windows PowerShell or Command Prompt

```powershell
py -m venv .venv
```

This creates the `.venv/` directory.

## The Verification

List the folder contents.

### macOS or Linux

```bash
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem -Force
```

You should see:

```text
.venv
```

Inside it, Python creates interpreter and package-management files.

### macOS or Linux

```bash
ls .venv
```

Typical output:

```text
bin
include
lib
pyvenv.cfg
```

### Windows PowerShell

```powershell
Get-ChildItem .venv
```

Typical output includes:

```text
Include
Lib
Scripts
pyvenv.cfg
```

---

# Step 4: Activate the Virtual Environment

## The Target

We are activating `.venv` so terminal commands use this project’s isolated Python installation.

## The Concept

Creating a virtual environment builds the workshop. Activating it means entering the workshop.

After activation:

```bash
python
```

and:

```bash
python -m pip
```

should refer to tools inside `.venv`, not globally installed tools elsewhere on your computer.

## The Implementation

### macOS or Linux

```bash
source .venv/bin/activate
```

### Windows PowerShell

```powershell
.\.venv\Scripts\Activate.ps1
```

If PowerShell says script execution is disabled, run this command once in the same PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then activate again:

```powershell
.\.venv\Scripts\Activate.ps1
```

### Windows Command Prompt

```bat
.venv\Scripts\activate.bat
```

## The Verification

Your shell prompt should usually begin with:

```text
(.venv)
```

For example:

```text
(.venv) user@computer pythonic-craftsmanship %
```

Confirm the Python executable.

### macOS or Linux

```bash
which python
```

Expected path pattern:

```text
.../pythonic-craftsmanship/.venv/bin/python
```

### Windows PowerShell

```powershell
Get-Command python
```

Expected path pattern:

```text
...\pythonic-craftsmanship\.venv\Scripts\python.exe
```

Finally, run:

```bash
python --version
```

It should display the supported Python version from this virtual environment.

---

# Step 5: Upgrade `pip` and Install Development Tools

## The Target

We are upgrading `pip`, Python’s package installer, then installing `pytest` and `mypy`.

## The Concept

`pip` installs Python packages.

We will eventually configure these tools inside `pyproject.toml`, but installing them now gives you immediate confirmation that your environment works.

| Tool | Purpose |
|---|---|
| `pytest` | Runs automated tests |
| `mypy` | Checks type hints without running the application |

Use:

```bash
python -m pip
```

instead of only:

```bash
pip
```

This ensures the package installer belongs to the active Python interpreter.

## The Implementation

Upgrade `pip`:

```bash
python -m pip install --upgrade pip
```

Install development tools:

```bash
python -m pip install pytest mypy
```

## The Verification

Run:

```bash
python -m pytest --version
```

Expected output resembles:

```text
pytest 8.x.x
```

Then run:

```bash
python -m mypy --version
```

Expected output resembles:

```text
mypy 1.x.x
```

The exact version numbers may differ.

---

# Step 6: Create Your First Project File

## The Target

We are creating:

```text
hello_python.py
```

## The Concept

A Python source file normally ends in `.py`.

When Python runs the file, it executes code from top to bottom.

We will use two basic built-in functions:

- `print()`: displays text in the terminal.
- `sys.version`: provides information about the active Python interpreter.

This confirms that your terminal is running the Python version from the virtual environment you activated.

## The Implementation

### `hello_python.py`

```python
"""Verify that the Pythonic Craftsmanship development environment works."""

from __future__ import annotations

import sys


def main() -> None:
    """Print a friendly setup confirmation and Python version."""
    print("Pythonic Craftsmanship environment is ready.")
    print(f"Active Python version: {sys.version.split()[0]}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python hello_python.py
```

Expected output resembles:

```text
Pythonic Craftsmanship environment is ready.
Active Python version: 3.12.4
```

The version should match the version reported after activating `.venv`.

---

# Step 7: Create a `.gitignore` File

## The Target

We are creating:

```text
.gitignore
```

## The Concept

Git tracks source files so they can be shared and versioned.

Some files should remain local:

- Virtual environments
- Python cache files
- Test cache files
- Editor settings
- Secret environment files

A `.gitignore` file tells Git not to track these local or generated files.

Think of it as a shipping rule:

> Share the blueprint and materials, but do not ship temporary tools, machine-specific dust, or private keys.

## The Implementation

### `.gitignore`

```gitignore
# Project-specific Python virtual environment.
.venv/

# Python bytecode and cache folders.
__pycache__/
*.py[cod]

# Test and type-checker cache folders.
.pytest_cache/
.mypy_cache/

# Coverage and generated report files.
.coverage
htmlcov/

# Environment files commonly used for local secrets.
.env
.env.*
!.env.example

# Editor and operating-system files.
.vscode/
.idea/
.DS_Store
```

## The Verification

Run:

```bash
git status
```

If Git is installed and the directory is already a Git repository, `.venv/` should not appear as an untracked directory.

If Git is not installed or the folder is not yet a repository, that is fine. Primer 4 can cover Git in more detail.

You can still confirm the file exists.

### macOS or Linux

```bash
cat .gitignore
```

### Windows PowerShell

```powershell
Get-Content .gitignore
```

---

# Step 8: Learn the Essential Environment Commands

## The Target

We are practicing the commands you will use repeatedly in the series.

## The Concept

You do not need to memorize every terminal command. You only need a small reliable set.

| Task | macOS/Linux | Windows PowerShell |
|---|---|---|
| Show current folder | `pwd` | `Get-Location` |
| List files | `ls -la` | `Get-ChildItem -Force` |
| Enter a folder | `cd folder_name` | `cd folder_name` |
| Go up one folder | `cd ..` | `cd ..` |
| Run Python file | `python file.py` | `python file.py` |
| Install package | `python -m pip install package` | Same |
| Run tests | `python -m pytest` | Same |
| Run type checks | `python -m mypy src tests` | Same |
| Leave virtual environment | `deactivate` | `deactivate` |

## The Implementation

From the project root, run:

```bash
python --version
python -m pip --version
python -m pytest --version
python -m mypy --version
python hello_python.py
```

## The Verification

Every command should run successfully.

The output from:

```bash
python -m pip --version
```

should include a path inside `.venv`.

For example:

```text
pip 24.x from .../pythonic-craftsmanship/.venv/lib/python3.12/site-packages/pip (python 3.12)
```

On Windows, the path contains:

```text
.venv\Lib\site-packages
```

---

# Primer 1 Reference: Common Setup Problems

## `python` Command Is Not Found

Try:

```bash
python3 --version
```

on macOS or Linux, or:

```powershell
py --version
```

on Windows.

If none work, install Python from:

```text
https://www.python.org/downloads/
```

---

## Virtual Environment Does Not Activate

Confirm `.venv` exists:

```bash
ls -la
```

Then run the activation command for your operating system again.

On PowerShell, a policy restriction may require:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This affects only the current terminal session.

---

## `pip` Installs Packages Globally

Use:

```bash
python -m pip install package-name
```

not:

```bash
pip install package-name
```

Also verify that your virtual environment is active before installing.

---

## `pytest` or `mypy` Is Not Found

Install them inside the active environment:

```bash
python -m pip install pytest mypy
```

Then run them through the same Python interpreter:

```bash
python -m pytest
python -m mypy
```

---

## Your Editor Uses the Wrong Python Interpreter

Configure your editor to use the interpreter inside:

```text
pythonic-craftsmanship/.venv/
```

Typical paths are:

### macOS or Linux

```text
.venv/bin/python
```

### Windows

```text
.venv\Scripts\python.exe
```

This ensures your editor sees the same installed packages and type hints as your terminal.
