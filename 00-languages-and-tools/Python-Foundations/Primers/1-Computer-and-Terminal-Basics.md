# Primer 1: Computer and Terminal Basics

Welcome to the first primer for **Python Foundations: From Zero to Functional Code**.

Before writing Python, you need to understand a few basic computer concepts:

- Files.
- Folders.
- File extensions.
- Terminals.
- Commands.
- Current directories.
- Relative paths.
- Absolute paths.

This primer assumes no previous terminal experience.

---

# 1. Files and Folders

A **file** stores information.

Examples include:

```text
notes.txt
photo.jpg
tasks.json
program.py
```

A **folder**, also called a directory, contains files and other folders.

Example:

```text
python-foundations/
├── hello.py
├── README.md
└── data/
    └── tasks.json
```

In this structure:

- `python-foundations` is a folder.
- `hello.py` is a Python file.
- `README.md` is a Markdown file.
- `data` is another folder.
- `tasks.json` is a JSON file inside `data`.

A useful analogy is:

```text
Folder = filing cabinet drawer
File = document inside the drawer
```

---

# 2. File Extensions

A file extension usually appears after the final period in a filename.

Examples:

| Filename | Extension | Typical purpose |
|---|---|---|
| `program.py` | `.py` | Python source code |
| `notes.txt` | `.txt` | Plain text |
| `tasks.json` | `.json` | Structured data |
| `README.md` | `.md` | Markdown documentation |
| `photo.jpg` | `.jpg` | Image |
| `settings.toml` | `.toml` | Configuration |

The extension helps the operating system and programs identify the file type.

For Python, the important extension is:

```text
.py
```

A Python program should normally be saved as:

```text
hello.py
```

Not:

```text
hello.txt
```

---

## Common File Extension Problem

On some systems, file extensions are hidden.

You may think you created:

```text
hello.py
```

but the actual filename may be:

```text
hello.py.txt
```

Python will not treat that as the expected filename.

If a command cannot find your file, check the complete filename.

---

# 3. Paths

A **path** describes the location of a file or folder.

For example:

```text
python-foundations/projects/hello.py
```

This identifies:

1. The `python-foundations` folder.
2. Its `projects` subfolder.
3. The `hello.py` file.

A path is similar to a postal address for a file.

---

# 4. Current Working Directory

The **current working directory** is the folder where your terminal is currently operating.

Many commands use this directory as their starting point.

For example, if your terminal is currently inside:

```text
python-foundations
```

and you run:

```bash
python hello.py
```

Python looks for:

```text
python-foundations/hello.py
```

If `hello.py` is actually inside `projects`, use:

```bash
python projects/hello.py
```

---

## Checking the Current Directory

### Windows PowerShell

```powershell
Get-Location
```

You can also use:

```powershell
pwd
```

### macOS or Linux

```bash
pwd
```

Example output:

```text
/home/user/python-foundations
```

or:

```text
C:\Users\User\python-foundations
```

---

# 5. Listing Directory Contents

To see the files and folders in the current directory:

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

For more detailed information on macOS/Linux:

```bash
ls -la
```

Example output might include:

```text
.venv
data
projects
README.md
```

---

# 6. Changing Directories

Use the `cd` command to change the current directory.

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

The two dots:

```text
..
```

represent the parent directory.

---

## Example Navigation

Suppose you begin here:

```text
home/
└── user/
```

Run:

```bash
cd python-foundations
```

Now you are here:

```text
home/user/python-foundations/
```

Run:

```bash
cd projects
```

Now you are here:

```text
home/user/python-foundations/projects/
```

Run:

```bash
cd ..
```

You return to:

```text
home/user/python-foundations/
```

---

# 7. Creating Folders from the Terminal

Use `mkdir` to create a folder.

### Windows PowerShell

```powershell
mkdir python-foundations
```

### macOS or Linux

```bash
mkdir python-foundations
```

Create a folder and enter it:

```bash
mkdir python-foundations
cd python-foundations
```

Create nested directories:

### Windows PowerShell

```powershell
mkdir src
mkdir src\foundation_cli
```

### macOS or Linux

```bash
mkdir -p src/foundation_cli
```

The macOS/Linux command creates missing parent directories automatically.

---

# 8. Creating Files from the Terminal

You can create files using a code editor, which is usually easier for writing Python.

You can also create empty files from the terminal.

### Windows PowerShell

```powershell
New-Item hello.py -ItemType File
```

### macOS or Linux

```bash
touch hello.py
```

After creating the file, open it in your editor and add Python code.

---

# 9. The Terminal and the Code Editor

The terminal and the code editor have different responsibilities.

| Tool | Purpose |
|---|---|
| Code editor | Write and save code |
| Terminal | Run commands and programs |
| Python shell | Test short Python expressions |

A normal workflow is:

```text
Open the editor
        ↓
Write Python code
        ↓
Save the file
        ↓
Open the terminal
        ↓
Move to the project directory
        ↓
Run the program
        ↓
Inspect the output
```

For example:

Create `hello.py` in your editor:

```python
print("Hello, Python!")
```

Save it.

Run it in the terminal:

```bash
python hello.py
```

---

# 10. Terminal Commands and Python Code Are Different

This is a terminal command:

```bash
python hello.py
```

This is Python code:

```python
print("Hello, Python!")
```

Do not place terminal commands inside a Python file unless you are deliberately using a special system-operation module.

For example, this belongs in the terminal:

```bash
mkdir projects
```

This belongs in a Python file:

```python
print("Creating a project")
```

---

# 11. Running a Python File

Suppose your project contains:

```text
python-foundations/
└── hello.py
```

First move into the project directory:

```bash
cd python-foundations
```

Then run:

```bash
python hello.py
```

If your system uses `python3`:

```bash
python3 hello.py
```

On Windows, you may also use:

```powershell
py hello.py
```

---

## Running a File in a Subdirectory

Suppose the structure is:

```text
python-foundations/
└── projects/
    └── hello.py
```

From `python-foundations`, run:

```bash
python projects/hello.py
```

On Windows, this also works:

```powershell
python projects\hello.py
```

Python generally accepts forward slashes in paths on Windows too:

```powershell
python projects/hello.py
```

---

# 12. Absolute Paths

An **absolute path** starts from the root of the file system.

Examples:

### Windows

```text
C:\Users\You\python-foundations\hello.py
```

### macOS/Linux

```text
/home/you/python-foundations/hello.py
```

An absolute path identifies the exact location from the system root.

You can run a file with an absolute path:

```bash
python /home/you/python-foundations/hello.py
```

Absolute paths are precise, but they are often specific to one computer.

---

# 13. Relative Paths

A **relative path** starts from the current working directory.

If your current directory is:

```text
python-foundations
```

then:

```bash
python projects/hello.py
```

uses a relative path.

The path is relative to:

```text
python-foundations/
```

Relative paths are useful because projects can be moved to another computer without changing every path.

---

# 14. The Difference Between Paths and Current Location

Suppose your project is:

```text
python-foundations/
├── hello.py
└── projects/
    └── report.py
```

If your terminal is inside `python-foundations`, this command works:

```bash
python projects/report.py
```

If your terminal is inside `projects`, use:

```bash
python report.py
```

If you are inside another directory, neither relative command may work.

When a file is “missing,” first check:

```bash
pwd
```

or:

```powershell
Get-Location
```

Then list the contents:

```bash
ls
```

or:

```powershell
Get-ChildItem
```

---

# 15. The `.` and `..` Path Symbols

A single period represents the current directory:

```text
.
```

Two periods represent the parent directory:

```text
..
```

Examples:

```bash
python ./hello.py
```

This runs `hello.py` in the current directory.

```bash
python ../hello.py
```

This runs `hello.py` in the parent directory.

Create a path inside a subdirectory:

```bash
python ./projects/hello.py
```

---

# 16. Terminal Command Practice

Open a terminal and complete these steps.

## Step 1: Create a Directory

```bash
mkdir terminal-practice
```

## Step 2: Enter It

```bash
cd terminal-practice
```

## Step 3: Check Your Location

### Windows PowerShell

```powershell
Get-Location
```

### macOS/Linux

```bash
pwd
```

## Step 4: List Contents

### Windows PowerShell

```powershell
Get-ChildItem
```

### macOS/Linux

```bash
ls
```

The directory should be empty.

## Step 5: Return to the Parent

```bash
cd ..
```

## Step 6: Remove the Temporary Directory

### Windows PowerShell

```powershell
Remove-Item terminal-practice
```

### macOS/Linux

```bash
rmdir terminal-practice
```

---

# 17. Command Practice Worksheet

Record the command used on your operating system.

| Task | Command |
|---|---|
| Check current directory | __________________________ |
| List contents | _________________________________ |
| Create a directory | ____________________________ |
| Enter a directory | _____________________________ |
| Move up one directory | _________________________ |
| Run a Python file | ______________________________ |
| Return to home directory | _______________________ |

---

# 18. Create and Run a Test Program

Create a project folder:

```bash
mkdir primer-practice
cd primer-practice
```

Create a file named:

```text
location.py
```

Add:

```python
from pathlib import Path


print("Current directory:")
print(Path.cwd())
```

Run:

```bash
python location.py
```

The program displays the current working directory from Python's perspective.

Record the output:

```text
____________________________________________________________

____________________________________________________________
```

Return to the parent directory:

```bash
cd ..
```

---

# 19. File Organization Exercise

Create this structure:

```text
primer-practice/
├── scripts/
└── notes/
```

### Windows PowerShell

```powershell
mkdir primer-practice
mkdir primer-practice\scripts
mkdir primer-practice\notes
```

### macOS/Linux

```bash
mkdir -p primer-practice/scripts
mkdir -p primer-practice/notes
```

Create:

```text
primer-practice/scripts/hello.py
```

Add:

```python
print("Hello from the scripts directory.")
```

From the project root, run:

```bash
python primer-practice/scripts/hello.py
```

Expected output:

```text
Hello from the scripts directory.
```

---

# 20. Terminal Troubleshooting

## Problem: The Command Is Not Recognized

If this fails:

```bash
python --version
```

try:

```bash
python3 --version
```

On Windows, try:

```powershell
py --version
```

---

## Problem: The File Is Not Found

If this fails:

```bash
python hello.py
```

check:

```bash
pwd
```

or:

```powershell
Get-Location
```

Then list files:

```bash
ls
```

or:

```powershell
Get-ChildItem
```

The file may be:

- In another directory.
- Named incorrectly.
- Saved as `hello.py.txt`.
- Being run from the wrong location.

---

## Problem: The Folder Is Not Found

If this fails:

```bash
cd projects
```

check the current contents:

```bash
ls
```

or:

```powershell
Get-ChildItem
```

The folder may have:

- A different name.
- A spelling mistake.
- Not been created yet.

---

## Problem: The Wrong Python Is Running

Check the executable:

```bash
python -c "import sys; print(sys.executable)"
```

If using a virtual environment, the path should contain:

```text
.venv
```

---

## Problem: The File Opens in the Wrong Program

Check the file extension.

A Python file should end in:

```text
.py
```

If the actual filename is:

```text
hello.py.txt
```

rename it to:

```text
hello.py
```

---

# 21. Readiness Exercise

Without looking at previous examples, complete this sequence:

1. Create a directory named `python-practice`.
2. Enter the directory.
3. Create a file named `hello.py`.
4. Write a Python print statement.
5. Run the file.
6. Return to the parent directory.
7. Delete the temporary directory.

Record the commands:

```text
1. _________________________________________________________

2. _________________________________________________________

3. _________________________________________________________

4. _________________________________________________________

5. _________________________________________________________

6. _________________________________________________________

7. _________________________________________________________
```

---

# 22. Primer 1 Review Questions

## Question 1

What is a file?

```text
____________________________________________________________

____________________________________________________________
```

## Question 2

What is a folder?

```text
____________________________________________________________

____________________________________________________________
```

## Question 3

What is a file extension?

```text
____________________________________________________________
```

## Question 4

What does `cd` do?

```text
____________________________________________________________
```

## Question 5

What does `pwd` show?

```text
____________________________________________________________
```

## Question 6

What is the difference between an absolute and relative path?

```text
____________________________________________________________

____________________________________________________________
```

## Question 7

What is the purpose of a terminal?

```text
____________________________________________________________

____________________________________________________________
```

## Question 8

How do you run a Python file named `program.py`?

```text
____________________________________________________________
```

## Question 9

What does `..` mean in a path?

```text
____________________________________________________________
```

## Question 10

Why might Python fail to find a file that appears to exist?

```text
____________________________________________________________

____________________________________________________________
```

---

# 23. Primer 1 Readiness Checklist

Before starting Part 1 of the series, confirm that you can:

- [ ] Explain the difference between a file and a folder.
- [ ] Recognize a `.py` file.
- [ ] Open a terminal.
- [ ] Check the current directory.
- [ ] List directory contents.
- [ ] Create a directory.
- [ ] Change directories.
- [ ] Move to the parent directory.
- [ ] Create and save a text file.
- [ ] Run a Python file.
- [ ] Distinguish terminal commands from Python code.
- [ ] Explain absolute and relative paths.
- [ ] Check which Python executable is running.
- [ ] Recognize a possible `.py.txt` problem.

---

# Primer 1 Complete

You now understand the basic computer and terminal skills needed for the Python series.

The next primer is:

# Primer 2: How Programs Work

It will introduce:

- Instructions.
- Values.
- Variables.
- Input.
- Processing.
- Output.
- Program flow.
- Errors.
- The difference between source code and execution.
