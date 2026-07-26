# Primer 6: Setup Troubleshooting

This primer helps learners resolve common setup problems before beginning the Python series.

It covers:

- Python command problems.
- Virtual environment problems.
- PowerShell activation.
- Package installation.
- Import errors.
- Incorrect directories.
- File paths.
- Interpreter selection.
- A systematic setup checklist.

---

# 1. Python Is Not Recognized

Try the command recommended for your operating system.

## Windows

```powershell
python --version
```

If that fails:

```powershell
py --version
```

## macOS or Linux

```bash
python3 --version
```

Some systems also support:

```bash
python --version
```

Record the command that works:

```text
____________________________________________________________
```

---

# 2. Python Is Not Installed

If none of these commands work, Python may not be installed.

Install Python 3 from the official Python website:

```text
https://www.python.org/downloads/
```

During Windows installation, enable the option similar to:

```text
Add Python to PATH
```

After installation, close and reopen the terminal.

Check again:

```bash
python --version
```

or:

```bash
py --version
```

---

# 3. The Wrong Python Version Is Running

Check the version:

```bash
python --version
```

Check the executable:

```bash
python -c "import sys; print(sys.executable)"
```

On Windows, also try:

```powershell
py -0p
```

This may list installed Python versions and their paths.

If multiple versions are installed, use the interpreter associated with the project.

---

# 4. `pip` Is Not Recognized

Instead of running:

```bash
pip install package-name
```

use:

```bash
python -m pip install package-name
```

This ensures that `pip` belongs to the Python interpreter you are using.

Check `pip`:

```bash
python -m pip --version
```

The displayed path should correspond to the active Python environment.

---

# 5. Creating the Virtual Environment Fails

Run:

```bash
python -m venv .venv
```

If `python` is not the correct command, try:

```bash
python3 -m venv .venv
```

On Windows:

```powershell
py -m venv .venv
```

If the `.venv` directory already exists and appears damaged, remove it and recreate it.

### Windows PowerShell

```powershell
Remove-Item .venv -Recurse -Force
py -m venv .venv
```

### macOS/Linux

```bash
rm -rf .venv
python3 -m venv .venv
```

Only remove `.venv` when you are certain it contains no important project-specific work. It can usually be recreated.

---

# 6. Activating on Windows PowerShell

Use:

```powershell
.venv\Scripts\Activate.ps1
```

If successful, the prompt should begin with:

```text
(.venv)
```

Example:

```text
(.venv) PS C:\Users\You\python-foundations>
```

---

# 7. PowerShell Execution Policy Error

You may see an error indicating that script execution is disabled.

Run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Confirm the change if prompted.

Then try again:

```powershell
.venv\Scripts\Activate.ps1
```

This modifies the policy for your user account.

---

# 8. Activating on Windows Command Prompt

If you use Command Prompt rather than PowerShell:

```cmd
.venv\Scripts\activate.bat
```

The prompt should show:

```text
(.venv)
```

---

# 9. Activating on macOS or Linux

Run:

```bash
source .venv/bin/activate
```

The prompt should show:

```text
(.venv)
```

If activation fails, check that the environment exists:

```bash
ls .venv
```

You should see directories such as:

```text
bin
include
lib
```

---

# 10. Confirming the Environment Is Active

Do not rely only on the prompt.

Run:

```bash
python -c "import sys; print(sys.executable)"
```

The path should contain:

```text
.venv
```

Example:

```text
/home/user/python-foundations/.venv/bin/python
```

If it does not, activate the environment again.

---

# 11. Deactivating the Environment

Run:

```bash
deactivate
```

The `(.venv)` prefix should disappear.

If the command is not recognized, simply close the terminal. The environment only affects the current terminal session.

---

# 12. The Project Package Cannot Be Imported

If this fails:

```bash
python -m foundation_cli --help
```

first confirm that you are in the project root.

The root should contain:

```text
pyproject.toml
src/
```

Check the current directory:

```bash
pwd
```

or:

```powershell
Get-Location
```

List its contents:

```bash
ls
```

or:

```powershell
Get-ChildItem
```

Then install the project:

```bash
python -m pip install --editable .
```

Try again:

```bash
python -m foundation_cli --help
```

---

# 13. `ModuleNotFoundError`

Example:

```text
ModuleNotFoundError: No module named 'foundation_cli'
```

Possible causes:

- The project is not installed.
- The virtual environment is not active.
- The current directory is wrong.
- The package directory is misspelled.
- The editor uses a different interpreter.

Check the package installation:

```bash
python -m pip show foundation-cli
```

Reinstall:

```bash
python -m pip install --editable .
```

Check the interpreter:

```bash
python -c "import sys; print(sys.executable)"
```

---

# 14. Relative Import Error

Inside a package, this is a relative import:

```python
from .tasks import create_task
```

A file containing a relative import should generally be run as a module:

```bash
python -m foundation_cli.some_module
```

Running it directly may fail:

```bash
python src/foundation_cli/some_module.py
```

Prefer:

```bash
python -m foundation_cli.some_module
```

For the main application, use:

```bash
python -m foundation_cli
```

---

# 15. Running from the Wrong Directory

Suppose your project is:

```text
python-foundations/
├── pyproject.toml
└── src/
    └── foundation_cli/
```

Run project commands from:

```text
python-foundations/
```

not from:

```text
python-foundations/src/
```

Check:

```bash
pwd
```

or:

```powershell
Get-Location
```

Confirm that `pyproject.toml` is visible:

```bash
ls pyproject.toml
```

On PowerShell:

```powershell
Get-ChildItem pyproject.toml
```

---

# 16. A File Cannot Be Found

If this fails:

```bash
python hello.py
```

check:

```bash
ls
```

or:

```powershell
Get-ChildItem
```

Possible causes:

- The file is in another directory.
- The filename is misspelled.
- The extension is wrong.
- The terminal is in the wrong directory.
- The file was not saved.

If the file is in `projects`, run:

```bash
python projects/hello.py
```

---

# 17. Data File Problems

The capstone expects:

```text
data/tasks.json
```

Check whether it exists:

```bash
ls data
```

or:

```powershell
Get-ChildItem data
```

Inspect it:

```bash
python -m json.tool data/tasks.json
```

If the file does not exist, the application may create it after adding a task:

```bash
python -m foundation_cli add "Test task"
```

---

# 18. Invalid JSON

If the application reports invalid JSON, inspect:

```bash
python -m json.tool data/tasks.json
```

Check for:

- Missing commas.
- Extra commas.
- Single quotes.
- Unquoted keys.
- `True` instead of `true`.
- `False` instead of `false`.
- Missing braces.
- Missing brackets.

Valid JSON:

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  }
]
```

---

# 19. Incorrect Editor Interpreter

Your editor may be using a different Python installation than your terminal.

Check the terminal:

```bash
python -c "import sys; print(sys.executable)"
```

Select the matching interpreter in the editor.

Typical virtual-environment paths:

### Windows

```text
.venv\Scripts\python.exe
```

### macOS/Linux

```text
.venv/bin/python
```

After selecting it, restart the editor's terminal if necessary.

---

# 20. Installed Package Does Not Reflect Code Changes

If the project was installed normally:

```bash
python -m pip install .
```

you may need to reinstall after source changes.

For development, use editable mode:

```bash
python -m pip install --editable .
```

Editable mode uses the source files directly.

---

# 21. The `foundation` Command Is Not Found

The project may provide:

```bash
foundation --help
```

after installation.

If this command is not found, use the module command:

```bash
python -m foundation_cli --help
```

Then reinstall:

```bash
python -m pip install --editable .
```

The module form is reliable during development.

---

# 22. Tests Cannot Import the Package

Run tests from the project root:

```bash
python -m unittest discover -s tests -v
```

Do not run them from inside `tests` unless the project is configured for that workflow.

Confirm the package is installed:

```bash
python -m pip show foundation-cli
```

Confirm the package imports:

```bash
python -c "import foundation_cli; print('Import works')"
```

---

# 23. Tests Modify Real Data

If tests are changing:

```text
data/tasks.json
```

they should use temporary files instead.

Recommended pattern:

```python
import tempfile
from pathlib import Path


with tempfile.TemporaryDirectory() as directory:
    file_path = Path(directory) / "tasks.json"
    ...
```

The test should not depend on the learner's current task data.

---

# 24. Organizer Safety Problems

Always test with a temporary directory first:

```text
organizer_demo/
```

Run:

```bash
python -m foundation_cli organize organizer_demo --dry-run
```

Check the planned moves before executing:

```bash
python -m foundation_cli organize organizer_demo
```

Do not begin with a personal downloads folder containing important files.

---

# 25. Command Checklist

When something fails, run:

```bash
python --version
```

```bash
python -c "import sys; print(sys.executable)"
```

```bash
python -c "from pathlib import Path; print(Path.cwd())"
```

```bash
python -m pip show foundation-cli
```

```bash
python -m foundation_cli --help
```

```bash
python -m unittest discover -s tests -v
```

These commands identify:

- Python version.
- Active interpreter.
- Current directory.
- Package installation.
- CLI availability.
- Test status.

---

# 26. Setup Troubleshooting Worksheet

## Problem Description

```text
____________________________________________________________

____________________________________________________________
```

## Exact Command

```text
____________________________________________________________
```

## Error Message

```text
____________________________________________________________

____________________________________________________________
```

## Python Version

```text
____________________________________________________________
```

## Active Interpreter

```text
____________________________________________________________
```

## Current Directory

```text
____________________________________________________________
```

## What I Tried

```text
____________________________________________________________

____________________________________________________________
```

## Solution

```text
____________________________________________________________

____________________________________________________________
```

---

# 27. Complete Setup Verification

Run these commands in order:

```bash
python --version
```

```bash
python -m venv .venv
```

Activate the environment.

```bash
python -c "import sys; print(sys.executable)"
```

Install the project:

```bash
python -m pip install --editable .
```

Run help:

```bash
python -m foundation_cli --help
```

Run tests:

```bash
python -m unittest discover -s tests -v
```

Record the results:

```text
Python version:

____________________________________________________________

Environment active:

____________________________________________________________

Project installed:

____________________________________________________________

CLI works:

____________________________________________________________

Tests pass:

____________________________________________________________
```

---

# 28. Primer 6 Review Questions

## Question 1

What should you try if `python` is not recognized on macOS or Linux?

```text
____________________________________________________________
```

## Question 2

What should you try on Windows if `python` is not recognized?

```text
____________________________________________________________
```

## Question 3

How do you check which Python executable is active?

```text
____________________________________________________________
```

## Question 4

What command installs the project in editable mode?

```text
____________________________________________________________
```

## Question 5

Why should package commands be run from the project root?

```text
____________________________________________________________

____________________________________________________________
```

## Question 6

How do you validate a JSON file from the terminal?

```text
____________________________________________________________
```

## Question 7

Why should the organizer be tested with `--dry-run` first?

```text
____________________________________________________________

____________________________________________________________
```

## Question 8

Why should tests use temporary directories?

```text
____________________________________________________________
```

---

# 29. Primer 6 Readiness Checklist

Before starting Part 1, confirm that you can:

- [ ] Check the Python version.
- [ ] Try alternative Python commands.
- [ ] Create a virtual environment.
- [ ] Activate it on your operating system.
- [ ] Resolve a PowerShell activation issue.
- [ ] Confirm the active interpreter.
- [ ] Use `python -m pip`.
- [ ] Install the project in editable mode.
- [ ] Check the current directory.
- [ ] Check whether a file exists.
- [ ] Validate JSON from the terminal.
- [ ] Resolve a missing-module problem.
- [ ] Run tests from the project root.
- [ ] Use temporary test data.
- [ ] Test file operations with dry-run mode.
