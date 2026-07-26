# Primer 2: Terminal Navigation, Files, Paths, and Running Python Programs

Before building multi-file Python packages, you need to be comfortable moving around a project from the terminal.

A terminal is a text-based way to interact with your computer. Instead of clicking folders and buttons, you type commands.

This can feel unfamiliar at first, but you only need a small set of commands to work effectively with Python projects.

By the end of this primer, you will be able to:

- Identify your current directory.
- List files and folders.
- Create folders and files.
- Move between directories.
- Understand relative and absolute paths.
- Run Python files from the correct project location.
- Understand the special `__name__ == "__main__"` pattern.
- Avoid common path and execution mistakes.

---

## What You Will Build

You will extend the environment created in Primer 1.

Expected project structure:

```text
pythonic-craftsmanship/
├── .gitignore
├── .venv/
├── hello_python.py
├── notes/
│   └── terminal_practice.txt
└── scripts/
    └── path_demo.py
```

The `notes/` and `scripts/` folders are practice folders. Later tutorial parts will introduce the real package directories:

```text
src/
tests/
examples/
```

---

# Step 1: Understand Files, Directories, and Paths

## The Target

We are learning the words and concepts used by terminal commands.

## The Concept

A **file** stores information.

Examples:

```text
hello_python.py
README.md
pyproject.toml
```

A **directory**, also called a folder, contains files and other directories.

Examples:

```text
pythonic-craftsmanship/
src/
tests/
```

A **path** identifies where a file or directory is located.

Think of a path like a postal address:

```text
Country → City → Street → Building → Apartment
```

A file path is similar:

```text
project folder → subfolder → file
```

For example:

```text
pythonic-craftsmanship/scripts/path_demo.py
```

This means:

1. Start in `pythonic-craftsmanship`.
2. Enter `scripts`.
3. Find `path_demo.py`.

---

## Path Separators

Operating systems display paths differently.

### macOS and Linux

```text
/home/alex/projects/pythonic-craftsmanship/scripts/path_demo.py
```

Uses forward slashes:

```text
/
```

### Windows

```text
C:\Users\Alex\projects\pythonic-craftsmanship\scripts\path_demo.py
```

Uses backslashes:

```text
\
```

Python’s `pathlib` module helps code work safely across both systems. We will use it later in the main series.

---

# Step 2: Confirm Your Current Directory

## The Target

We are confirming that your terminal is currently in the `pythonic-craftsmanship` project directory.

## The Concept

The **current working directory** is the folder where your terminal is currently standing.

When you run:

```bash
python hello_python.py
```

Python looks for `hello_python.py` in the current working directory unless you provide a different path.

This is why knowing where you are matters.

## The Implementation

Activate the virtual environment if it is not active.

### macOS or Linux

```bash
source .venv/bin/activate
```

### Windows PowerShell

```powershell
.\.venv\Scripts\Activate.ps1
```

Then show the current directory.

### macOS or Linux

```bash
pwd
```

`pwd` means **print working directory**.

### Windows PowerShell

```powershell
Get-Location
```

### Windows Command Prompt

```bat
cd
```

## The Verification

Your output should end with something similar to:

```text
pythonic-craftsmanship
```

For example:

```text
/home/alex/projects/pythonic-craftsmanship
```

If it does not, move to the project folder.

### macOS or Linux

```bash
cd ~/projects/pythonic-craftsmanship
```

### Windows PowerShell

```powershell
cd $HOME\projects\pythonic-craftsmanship
```

### Windows Command Prompt

```bat
cd %USERPROFILE%\projects\pythonic-craftsmanship
```

Run the location command again to confirm.

---

# Step 3: List Project Files

## The Target

We are listing the files and folders in the current project directory.

## The Concept

Listing directory contents is like opening a drawer and checking what is inside.

This is one of the most useful debugging actions in programming. If a command says a file does not exist, list the directory before assuming the code is wrong.

## The Implementation

### macOS or Linux

```bash
ls -la
```

Meaning:

| Flag | Meaning |
|---|---|
| `-l` | Use a detailed list format |
| `-a` | Include hidden files such as `.gitignore` and `.venv` |

### Windows PowerShell

```powershell
Get-ChildItem -Force
```

### Windows Command Prompt

```bat
dir /a
```

## The Verification

You should see files from Primer 1, including:

```text
.gitignore
.venv
hello_python.py
```

The exact formatting differs by operating system.

---

# Step 4: Create Practice Directories

## The Target

We are creating two folders:

```text
notes/
scripts/
```

## The Concept

Projects use folders to group related files.

Later, this series will use:

```text
src/       Application source code
tests/     Automated tests
examples/  Runnable demonstrations
```

For now, we will practice with:

```text
notes/     Plain-text notes
scripts/   Small Python programs
```

## The Implementation

### macOS or Linux

```bash
mkdir notes scripts
```

### Windows PowerShell

```powershell
mkdir notes, scripts
```

### Windows Command Prompt

```bat
mkdir notes
mkdir scripts
```

## The Verification

List the directory again.

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
notes
scripts
```

---

# Step 5: Move Into and Out of Directories

## The Target

We are practicing the `cd` command.

## The Concept

`cd` means **change directory**.

Think of it as walking between rooms in a building.

If your current location is:

```text
pythonic-craftsmanship/
```

and you run:

```bash
cd scripts
```

your new location becomes:

```text
pythonic-craftsmanship/scripts/
```

To move up one level, use:

```bash
cd ..
```

The two dots mean “the parent directory.”

## The Implementation

Enter the `scripts` directory:

```bash
cd scripts
```

Confirm where you are.

### macOS or Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

Move back to the project root:

```bash
cd ..
```

Confirm your location again.

## The Verification

After entering `scripts`, your path should end with:

```text
pythonic-craftsmanship/scripts
```

After running:

```bash
cd ..
```

your path should end with:

```text
pythonic-craftsmanship
```

---

# Step 6: Learn Relative and Absolute Paths

## The Target

We are learning how commands locate files.

## The Concept

A path may be **absolute** or **relative**.

### Absolute Path

An absolute path starts from the root of the file system.

Example on macOS or Linux:

```text
/home/alex/projects/pythonic-craftsmanship/hello_python.py
```

Example on Windows:

```text
C:\Users\Alex\projects\pythonic-craftsmanship\hello_python.py
```

It works regardless of your current terminal directory.

### Relative Path

A relative path starts from your current directory.

If you are in:

```text
pythonic-craftsmanship/
```

then:

```text
hello_python.py
```

is a relative path.

So is:

```text
scripts/path_demo.py
```

If you are inside:

```text
pythonic-craftsmanship/scripts/
```

then the relative path to `hello_python.py` is:

```text
../hello_python.py
```

The `..` means “go up one directory.”

## The Implementation

From the project root, run:

```bash
python hello_python.py
```

Then enter the `scripts` directory:

```bash
cd scripts
```

Run the same file using a relative path:

```bash
python ../hello_python.py
```

Finally, return to the project root:

```bash
cd ..
```

## The Verification

Both Python commands should print output similar to:

```text
Pythonic Craftsmanship environment is ready.
Active Python version: 3.12.4
```

This confirms that relative paths depend on your current location.

---

# Step 7: Create a Text File from the Terminal

## The Target

We are creating:

```text
notes/terminal_practice.txt
```

## The Concept

Many project files are plain text:

- Python files
- Markdown documentation
- Configuration files
- Test files
- `.gitignore`

You can create them with a code editor, but it is useful to understand terminal-based file creation too.

## The Implementation

### macOS or Linux

Run:

```bash
printf "Terminal practice complete.\n" > notes/terminal_practice.txt
```

### Windows PowerShell

Run:

```powershell
Set-Content -Path notes\terminal_practice.txt -Value "Terminal practice complete."
```

### Windows Command Prompt

Run:

```bat
echo Terminal practice complete. > notes\terminal_practice.txt
```

## The Verification

Read the file.

### macOS or Linux

```bash
cat notes/terminal_practice.txt
```

### Windows PowerShell

```powershell
Get-Content notes\terminal_practice.txt
```

### Windows Command Prompt

```bat
type notes\terminal_practice.txt
```

Expected output:

```text
Terminal practice complete.
```

---

# Step 8: Create and Run a Python File in a Subdirectory

## The Target

We are creating:

```text
scripts/path_demo.py
```

## The Concept

A Python file is just a text file containing valid Python syntax.

The `path_demo.py` script will use `pathlib.Path`, Python’s built-in path-handling tool, to show:

- The working directory from which Python was launched.
- The physical location of the script file itself.
- The project root inferred from the script’s location.

This distinction is important:

- The **working directory** depends on where you run a command.
- The **script path** depends on where the file lives.

## The Implementation

### `scripts/path_demo.py`

```python
"""Demonstrate the difference between working and script file paths."""

from __future__ import annotations

from pathlib import Path


def main() -> None:
    """Print useful file-system locations for this project."""
    working_directory = Path.cwd()
    script_path = Path(__file__).resolve()
    project_root = script_path.parent.parent

    print(f"Working directory: {working_directory}")
    print(f"Script path: {script_path}")
    print(f"Project root: {project_root}")


if __name__ == "__main__":
    main()
```

## The Verification

From the project root, run:

```bash
python scripts/path_demo.py
```

Expected output resembles:

```text
Working directory: /home/alex/projects/pythonic-craftsmanship
Script path: /home/alex/projects/pythonic-craftsmanship/scripts/path_demo.py
Project root: /home/alex/projects/pythonic-craftsmanship
```

On Windows, the paths use backslashes.

Now enter the `scripts` folder:

```bash
cd scripts
```

Run:

```bash
python path_demo.py
```

Expected output will differ in one important way:

```text
Working directory: .../pythonic-craftsmanship/scripts
Script path: .../pythonic-craftsmanship/scripts/path_demo.py
Project root: .../pythonic-craftsmanship
```

Return to the root:

```bash
cd ..
```

The script location did not change, but the working directory did.

---

# Step 9: Understand `if __name__ == "__main__"`

## The Target

We are understanding this pattern already used in both scripts:

```python
if __name__ == "__main__":
    main()
```

## The Concept

Python assigns every module a special `__name__` value.

When you run a file directly:

```bash
python scripts/path_demo.py
```

Python sets:

```python
__name__ == "__main__"
```

When another Python file imports it:

```python
import path_demo
```

Python sets:

```python
__name__ == "path_demo"
```

The guard lets a file behave in two useful ways:

1. It can run as a standalone script.
2. It can be imported without automatically executing its main program.

Think of it like a stove with a safety switch:

- Running the file directly turns the stove on.
- Importing the file lets you reuse its tools without turning it on.

## The Implementation

Create a small import demonstration.

### `scripts/import_demo.py`

```python
"""Import path_demo without automatically running its main function."""

from __future__ import annotations

import path_demo


def main() -> None:
    """Confirm that imported modules expose reusable names."""
    print(f"Imported module name: {path_demo.__name__}")
    print("The imported module did not run path_demo.main() automatically.")


if __name__ == "__main__":
    main()
```

## The Verification

Enter the `scripts` folder:

```bash
cd scripts
```

Run:

```bash
python import_demo.py
```

Expected output:

```text
Imported module name: path_demo
The imported module did not run path_demo.main() automatically.
```

Notice that you do **not** see the path information printed by `path_demo.main()`.

Return to the project root:

```bash
cd ..
```

---

# Step 10: Practice a Reliable “Run This Project” Routine

## The Target

We are practicing the routine you should use whenever returning to the project.

## The Concept

A consistent workflow avoids common environment problems.

When beginning work:

```text
Open terminal
    ↓
Move to project directory
    ↓
Activate virtual environment
    ↓
Run commands through `python -m ...`
```

## The Implementation

From any terminal location, use the following pattern.

### macOS or Linux

```bash
cd ~/projects/pythonic-craftsmanship
source .venv/bin/activate

python hello_python.py
python scripts/path_demo.py
python -m pytest --version
python -m mypy --version
```

### Windows PowerShell

```powershell
cd $HOME\projects\pythonic-craftsmanship
.\.venv\Scripts\Activate.ps1

python hello_python.py
python scripts\path_demo.py
python -m pytest --version
python -m mypy --version
```

## The Verification

All commands should succeed.

Your project should now resemble:

```text
pythonic-craftsmanship/
├── .gitignore
├── .venv/
├── hello_python.py
├── notes/
│   └── terminal_practice.txt
└── scripts/
    ├── import_demo.py
    └── path_demo.py
```

---

# Primer 2 Reference: Essential Terminal Commands

## Navigation

| Action | macOS/Linux | Windows PowerShell |
|---|---|---|
| Show current directory | `pwd` | `Get-Location` |
| List files | `ls -la` | `Get-ChildItem -Force` |
| Enter directory | `cd directory_name` | `cd directory_name` |
| Move up one directory | `cd ..` | `cd ..` |
| Return to home directory | `cd ~` | `cd $HOME` |

---

## Files and Directories

| Action | macOS/Linux | Windows PowerShell |
|---|---|---|
| Create folder | `mkdir folder_name` | `mkdir folder_name` |
| Read text file | `cat file.txt` | `Get-Content file.txt` |
| Create empty file | `touch file.txt` | `New-Item file.txt -ItemType File` |
| Remove file | `rm file.txt` | `Remove-Item file.txt` |
| Remove folder recursively | `rm -rf folder_name` | `Remove-Item -Recurse -Force folder_name` |

Be careful with recursive removal commands. They can permanently delete many files.

Before running:

```bash
rm -rf folder_name
```

or:

```powershell
Remove-Item -Recurse -Force folder_name
```

confirm your current directory and target path.

---

## Python Environment

| Task | Command |
|---|---|
| Check Python version | `python --version` |
| Create virtual environment | `python -m venv .venv` |
| Activate on macOS/Linux | `source .venv/bin/activate` |
| Activate on PowerShell | `.\.venv\Scripts\Activate.ps1` |
| Leave virtual environment | `deactivate` |
| Install package | `python -m pip install package-name` |
| Run Python file | `python file.py` |
| Run tests | `python -m pytest` |
| Run type checks | `python -m mypy src tests` |

---

# Primer 2 Reference: Common Path Mistakes

## “No Such File or Directory”

Example:

```text
python: can't open file 'hello_python.py': [Errno 2] No such file or directory
```

First, check your current location:

```bash
pwd
```

or:

```powershell
Get-Location
```

Then list files:

```bash
ls -la
```

or:

```powershell
Get-ChildItem -Force
```

You may be in the wrong directory or using an incorrect relative path.

---

## Spaces in File or Folder Names

Avoid spaces in project paths when possible.

Prefer:

```text
python-projects/
my_api_client/
```

over:

```text
Python Projects/
My API Client/
```

If a path contains spaces, quote it:

### macOS or Linux

```bash
cd "Python Projects"
```

### Windows PowerShell

```powershell
cd "Python Projects"
```

Python project names usually use lowercase letters, numbers, hyphens, or underscores.

---

## Running the Wrong File

If you have several files named similarly:

```text
project.py
projects.py
project_demo.py
```

list the directory before running one:

```bash
ls
```

Then copy the exact filename into your command.

---

## Accidentally Running Python Outside the Virtual Environment

If package imports fail unexpectedly, verify:

```bash
which python
```

on macOS/Linux, or:

```powershell
Get-Command python
```

on PowerShell.

The path must include:

```text
.venv
```

If it does not, activate the environment again.
