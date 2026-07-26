# Appendix A: Command Reference

This appendix provides a quick reference for the commands used throughout **Python Foundations: From Zero to Functional Code**.

Commands are grouped by purpose:

1. Checking Python.
2. Managing project directories.
3. Creating virtual environments.
4. Activating and deactivating environments.
5. Running Python programs.
6. Installing the project.
7. Running the capstone application.
8. Running tests.
9. Managing files and directories.
10. Troubleshooting common command issues.

---

# 1. Checking Python

## Windows

Try:

```powershell
python --version
```

If that does not work:

```powershell
py --version
```

## macOS or Linux

Try:

```bash
python3 --version
```

Example output:

```text
Python 3.12.4
```

Some systems also support:

```bash
python --version
```

The exact version may differ.

---

## Checking the Python Executable

To see which Python executable is being used:

```bash
python -c "import sys; print(sys.executable)"
```

Example Windows output:

```text
C:\Users\You\python-foundations\.venv\Scripts\python.exe
```

Example macOS or Linux output:

```text
/home/user/python-foundations/.venv/bin/python
```

If the path contains `.venv`, the virtual environment is active.

---

## Checking `pip`

`pip` is Python's package-management tool.

Use:

```bash
python -m pip --version
```

Using `python -m pip` is generally safer than calling `pip` directly because it ensures that `pip` belongs to the Python interpreter you selected.

---

# 2. Creating and Navigating Directories

## Create a Directory

### Windows PowerShell

```powershell
mkdir python-foundations
```

### macOS or Linux

```bash
mkdir python-foundations
```

---

## Create Nested Directories

### Windows PowerShell

```powershell
mkdir src
mkdir src\foundation_cli
mkdir data
mkdir tests
```

### macOS or Linux

```bash
mkdir -p src/foundation_cli
mkdir -p data
mkdir -p tests
```

The `-p` option allows macOS and Linux to create missing parent directories automatically.

---

## Enter a Directory

```bash
cd python-foundations
```

Move into a subdirectory:

```bash
cd projects
```

Move up one directory:

```bash
cd ..
```

Move up two directories:

```bash
cd ../..
```

---

## Return to the Home Directory

### Windows PowerShell

```powershell
cd ~
```

### macOS or Linux

```bash
cd ~
```

---

## Display the Current Directory

### Windows PowerShell

```powershell
Get-Location
```

Short form:

```powershell
pwd
```

### macOS or Linux

```bash
pwd
```

---

## List Directory Contents

### Windows PowerShell

```powershell
Get-ChildItem
```

Short form:

```powershell
ls
```

### macOS or Linux

```bash
ls
```

Show more details:

```bash
ls -la
```

---

# 3. Creating a Virtual Environment

A virtual environment isolates the project's Python installation and packages.

First, move into the project directory:

```bash
cd python-foundations
```

## Windows

Using the Python launcher:

```powershell
py -m venv .venv
```

Using the `python` command:

```powershell
python -m venv .venv
```

## macOS or Linux

```bash
python3 -m venv .venv
```

If your system uses `python` for Python 3:

```bash
python -m venv .venv
```

The `.venv` directory should now exist:

```text
python-foundations/
└── .venv/
```

---

# 4. Activating a Virtual Environment

## Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

The prompt should display:

```text
(.venv)
```

Example:

```text
(.venv) PS C:\Users\You\python-foundations>
```

---

## Windows Command Prompt

```cmd
.venv\Scripts\activate.bat
```

---

## macOS or Linux

```bash
source .venv/bin/activate
```

Example:

```text
(.venv) user@computer:~/python-foundations$
```

---

## PowerShell Execution Policy Issue

If PowerShell reports that script execution is disabled, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then activate the environment again:

```powershell
.venv\Scripts\Activate.ps1
```

This changes the policy for your user account.

---

## Confirming Activation

Run:

```bash
python -c "import sys; print(sys.executable)"
```

The displayed path should contain:

```text
.venv
```

---

## Deactivating the Environment

When finished working:

```bash
deactivate
```

The `(.venv)` prefix should disappear from the terminal prompt.

---

# 5. Running Python Programs

Run a Python file with:

```bash
python filename.py
```

Example:

```bash
python hello.py
```

Run a file inside a directory:

```bash
python projects/personal_report.py
```

On systems where Python 3 uses `python3`:

```bash
python3 projects/personal_report.py
```

On Windows, you can also use:

```powershell
py projects/personal_report.py
```

---

## Running the Interactive Python Shell

```bash
python
```

You should see:

```text
>>>
```

Try:

```python
print("Hello, Python!")
```

Exit the shell with:

```python
exit()
```

You can also use:

- Windows: `Ctrl+Z`, then Enter.
- macOS/Linux: `Ctrl+D`.

---

## Running a Short Python Command

Use the `-c` option:

```bash
python -c "print(2 + 3)"
```

Output:

```text
5
```

Another example:

```bash
python -c "import sys; print(sys.version)"
```

---

# 6. Running Python Modules

Run a module with:

```bash
python -m module_name
```

For the capstone application:

```bash
python -m foundation_cli
```

Run a module inside a package:

```bash
python -m foundation_cli.cli
```

The preferred capstone command is:

```bash
python -m foundation_cli
```

This works because the package contains:

```text
src/foundation_cli/__main__.py
```

---

# 7. Installing the Project

From the project root, with the virtual environment active:

```bash
python -m pip install --editable .
```

The `--editable` option means that changes to the source code are immediately available without reinstalling after every edit.

You can also write:

```bash
python -m pip install -e .
```

These commands are equivalent.

---

## Upgrading `pip`

```bash
python -m pip install --upgrade pip
```

This is optional for the project but can help resolve package-installation issues.

---

## Viewing Installed Packages

```bash
python -m pip list
```

Show information about the current project:

```bash
python -m pip show foundation-cli
```

---

## Uninstalling the Project

```bash
python -m pip uninstall foundation-cli
```

This removes the installed package from the active environment.

It does not delete your source files.

---

# 8. Capstone CLI Commands

Run these commands from the project root:

```bash
python -m foundation_cli --help
```

Displays available commands and options.

```bash
python -m foundation_cli --version
```

Displays the application version.

---

## Add a Task

```bash
python -m foundation_cli add "Learn Python"
```

Example output:

```text
Task created:
  ID: 1
  Title: Learn Python
  Status: incomplete
```

---

## List Tasks

```bash
python -m foundation_cli list
```

Example output:

```text
Tasks:
[ ] 1 - Learn Python
[ ] 2 - Build a CLI tool
```

---

## Complete a Task

```bash
python -m foundation_cli complete 1
```

Example output:

```text
Task completed:
  ID: 1
  Title: Learn Python
```

---

## Remove a Task

```bash
python -m foundation_cli remove 1
```

Example output:

```text
Task removed:
  ID: 1
  Title: Learn Python
```

---

## Display Task Statistics

```bash
python -m foundation_cli stats
```

Example output:

```text
Total tasks: 2
Completed tasks: 1
Incomplete tasks: 1
```

---

## Preview File Organization

Use `--dry-run` to see what would happen without moving files:

```bash
python -m foundation_cli organize ./downloads --dry-run
```

Windows example:

```powershell
python -m foundation_cli organize .\downloads --dry-run
```

Example output:

```text
Dry run: no files will be moved.
report.pdf -> downloads/pdf/report.pdf
photo.jpg -> downloads/jpg/photo.jpg
Dry run complete.
```

---

## Organize Files

```bash
python -m foundation_cli organize ./downloads
```

Windows example:

```powershell
python -m foundation_cli organize .\downloads
```

Example output:

```text
report.pdf -> downloads/pdf/report.pdf
photo.jpg -> downloads/jpg/photo.jpg
Moved 2 file(s).
```

Always use `--dry-run` first when working with an important directory.

---

# 9. Running Tests

The project uses Python's built-in `unittest` framework.

From the project root, run:

```bash
python -m unittest discover -s tests -v
```

The command means:

- `python -m unittest` — run the testing module.
- `discover` — find test files.
- `-s tests` — search in the `tests` directory.
- `-v` — display detailed test names.

Expected final output:

```text
----------------------------------------------------------------------
Ran 20 tests in 0.05s

OK
```

The exact number of tests may vary.

---

## Run One Test File

```bash
python -m unittest tests.test_tasks -v
```

Depending on your project configuration, this may require the `tests` directory to contain an `__init__.py` file.

Alternatively, use discovery with a pattern:

```bash
python -m unittest discover -s tests -p "test_tasks.py" -v
```

Run storage tests:

```bash
python -m unittest discover -s tests -p "test_storage.py" -v
```

Run organizer tests:

```bash
python -m unittest discover -s tests -p "test_organizer.py" -v
```

---

# 10. Creating and Removing Files

## Create an Empty File

### Windows PowerShell

```powershell
New-Item example.txt -ItemType File
```

### macOS or Linux

```bash
touch example.txt
```

---

## Write Text to a File

### Windows PowerShell

```powershell
Set-Content example.txt "Hello, Python!"
```

### macOS or Linux

```bash
printf "Hello, Python!\n" > example.txt
```

---

## Delete a File

### Windows PowerShell

```powershell
Remove-Item example.txt
```

### macOS or Linux

```bash
rm example.txt
```

---

## Delete a Directory

Be careful with recursive deletion.

### Windows PowerShell

```powershell
Remove-Item example_directory -Recurse -Force
```

### macOS or Linux

```bash
rm -rf example_directory
```

Only use these commands when you are certain that the path points to a disposable directory.

---

# 11. Inspecting JSON Data

Display the task data file.

### Windows PowerShell

```powershell
Get-Content data\tasks.json
```

### macOS or Linux

```bash
cat data/tasks.json
```

Pretty-print the JSON with Python:

```bash
python -m json.tool data/tasks.json
```

Example output:

```json
[
    {
        "id": 1,
        "title": "Learn Python",
        "completed": false
    }
]
```

This is useful for checking whether the JSON file is valid and readable.

---

# 12. Useful Python Diagnostics

## Show Python Version

```bash
python -c "import sys; print(sys.version)"
```

## Show the Current Working Directory

```bash
python -c "from pathlib import Path; print(Path.cwd())"
```

## Show the Executable Path

```bash
python -c "import sys; print(sys.executable)"
```

## Check Whether a Package Can Be Imported

```bash
python -c "import foundation_cli; print('Import successful')"
```

## Check the Package Version

```bash
python -c "import foundation_cli; print(foundation_cli.__version__)"
```

---

# 13. Common Command Problems

## `python` Is Not Recognized

Try:

```bash
python3 --version
```

On Windows, try:

```powershell
py --version
```

If none work, Python may not be installed or may not be available on your system's `PATH`.

---

## `python3` Is Not Recognized

Try:

```bash
python --version
```

Some systems use `python` rather than `python3`.

---

## The Virtual Environment Does Not Activate

Check that the environment exists:

### Windows PowerShell

```powershell
Get-ChildItem .venv
```

### macOS or Linux

```bash
ls .venv
```

If it does not exist, create it again:

```bash
python -m venv .venv
```

---

## `foundation_cli` Cannot Be Imported

Confirm that:

1. The virtual environment is active.
2. The project was installed.
3. You are in the project root.

Run:

```bash
python -m pip install --editable .
```

Then test:

```bash
python -m foundation_cli --help
```

---

## `foundation` Command Is Not Found

Use the module form:

```bash
python -m foundation_cli --help
```

Then verify that the project is installed in the active environment:

```bash
python -m pip install --editable .
```

The module form is the most reliable command during development.

---

## `ModuleNotFoundError`

Check:

```bash
python -c "import sys; print(sys.executable)"
```

Then confirm that the package is installed:

```bash
python -m pip show foundation-cli
```

If necessary, reinstall:

```bash
python -m pip install --editable .
```

---

## `FileNotFoundError`

Check your current directory:

```bash
python -c "from pathlib import Path; print(Path.cwd())"
```

Then check the path you are using.

For example:

```bash
python -m foundation_cli organize downloads
```

requires a directory named `downloads` relative to the current working directory.

Use an absolute path if necessary.

---

# 14. Recommended Daily Workflow

When returning to the project:

## 1. Enter the project directory

```bash
cd python-foundations
```

## 2. Activate the environment

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

### macOS or Linux

```bash
source .venv/bin/activate
```

## 3. Run the tests

```bash
python -m unittest discover -s tests -v
```

## 4. Run the application

```bash
python -m foundation_cli --help
```

## 5. Make a small change

Edit one part of the program.

## 6. Run the tests again

```bash
python -m unittest discover -s tests -v
```

## 7. Test the changed command manually

For example:

```bash
python -m foundation_cli list
```

## 8. Deactivate when finished

```bash
deactivate
```

---

# 15. Command Summary Table

| Task | Command |
|---|---|
| Check Python | `python --version` |
| Create environment | `python -m venv .venv` |
| Activate on Windows PowerShell | `.venv\Scripts\Activate.ps1` |
| Activate on macOS/Linux | `source .venv/bin/activate` |
| Deactivate | `deactivate` |
| Install project | `python -m pip install --editable .` |
| Run package | `python -m foundation_cli` |
| Show help | `python -m foundation_cli --help` |
| Show version | `python -m foundation_cli --version` |
| Add task | `python -m foundation_cli add "Task"` |
| List tasks | `python -m foundation_cli list` |
| Complete task | `python -m foundation_cli complete 1` |
| Remove task | `python -m foundation_cli remove 1` |
| Show statistics | `python -m foundation_cli stats` |
| Preview organizer | `python -m foundation_cli organize downloads --dry-run` |
| Organize files | `python -m foundation_cli organize downloads` |
| Run tests | `python -m unittest discover -s tests -v` |
| Display JSON | `python -m json.tool data/tasks.json` |

---

# 16. Quick Start from a New Terminal

### Windows PowerShell

```powershell
cd path\to\python-foundations
.venv\Scripts\Activate.ps1
python -m foundation_cli --help
python -m unittest discover -s tests -v
```

### macOS or Linux

```bash
cd /path/to/python-foundations
source .venv/bin/activate
python -m foundation_cli --help
python -m unittest discover -s tests -v
```

If the project has not yet been installed:

```bash
python -m pip install --editable .
```

---

# Appendix A Summary

The most important commands are:

```bash
python --version
```

```bash
python -m venv .venv
```

```bash
python -m pip install --editable .
```

```bash
python -m foundation_cli --help
```

```bash
python -m foundation_cli add "Learn Python"
```

```bash
python -m foundation_cli list
```

```bash
python -m foundation_cli complete 1
```

```bash
python -m foundation_cli remove 1
```

```bash
python -m foundation_cli organize downloads --dry-run
```

```bash
python -m unittest discover -s tests -v
```

When uncertain, use the following sequence:

```bash
python --version
python -c "import sys; print(sys.executable)"
python -m pip install --editable .
python -m foundation_cli --help
python -m unittest discover -s tests -v
```
