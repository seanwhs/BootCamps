# Primer 1: Terminal, Files, Folders, and Paths

Git is usually used from a terminal: a text-based application where you enter commands.

Think of a terminal as a direct conversation with your computer:

```text
You type an instruction
        ↓
The operating system performs it
        ↓
The terminal displays the result
```

Before using Git, you need to be comfortable with four ideas:

1. Your current folder.
2. Listing files.
3. Creating folders and files.
4. Moving between folders.

---

## P1.1 Open a Terminal

### The Target

Open the command-line application you will use throughout the series.

### The Concept

A terminal is a text interface for your operating system.

Git commands such as:

```bash
git status
git add README.md
git commit -m "Add documentation"
```

are entered into a terminal.

### The Implementation

Use the terminal appropriate to your operating system:

| Operating system | Recommended application |
|---|---|
| macOS | Terminal |
| Windows | Git Bash or Windows Terminal |
| Linux | Terminal application included with your desktop environment |

On Windows, **Git Bash** is recommended for this tutorial because its commands closely match macOS and Linux examples.

Once open, you may see a prompt similar to:

```text
your-name@computer-name:~$
```

Or on Windows Git Bash:

```text
your-name@COMPUTER-NAME MINGW64 ~
$
```

The exact prompt does not matter. It means the terminal is ready for a command.

### The Verification

Run:

```bash
echo "Terminal is ready"
```

Expected output:

```text
Terminal is ready
```

---

## P1.2 Find Your Current Folder

### The Target

Display the folder where the terminal is currently operating.

### The Concept

Every terminal session has a **current working directory**: the folder where commands operate unless you specify another location.

Think of it as your current room in a building. If you say “show me the files,” the computer shows files in the room you are currently standing in.

### The Implementation

### macOS, Linux, or Git Bash

```bash
pwd
```

`pwd` means:

```text
Print Working Directory
```

### Windows PowerShell

```powershell
Get-Location
```

### The Verification

Expected output resembles:

```text
/Users/your-name
```

Or on Windows Git Bash:

```text
/c/Users/your-name
```

Or in PowerShell:

```text
Path
----
C:\Users\your-name
```

This is usually your home folder.

---

## P1.3 List Files and Folders

### The Target

See what files and folders exist in the current working directory.

### The Concept

A folder can contain:

- **Files**, such as `README.md` or `package.json`.
- **Directories**, also called folders, such as `projects` or `src`.

Listing contents is like looking at the labels on boxes in your current room.

### The Implementation

### macOS, Linux, or Git Bash

```bash
ls
```

For a detailed list that includes hidden files:

```bash
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem
```

For hidden files too:

```powershell
Get-ChildItem -Force
```

### The Verification

You should see files and folders in your home directory, potentially including names such as:

```text
Desktop
Documents
Downloads
projects
```

Hidden files often begin with a dot:

```text
.gitignore
.gitconfig
```

They are normally omitted unless you use `ls -la` or `Get-ChildItem -Force`.

---

## P1.4 Create a Projects Folder

### The Target

Create one parent folder where you will keep development repositories.

### The Concept

Keeping projects in a predictable location makes commands easier and reduces clutter.

For this series, use:

```text
~/projects/
```

The `~` symbol means your home folder.

For example:

```text
~/projects/release-notes-manager/
```

On Windows Git Bash, this may map to:

```text
C:\Users\your-name\projects\release-notes-manager
```

### The Implementation

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects" -Force
```

`mkdir` means “make directory.”

The `-p` option on macOS, Linux, and Git Bash means:

> Create the folder if it does not exist, but do not report an error if it already exists.

### The Verification

### macOS, Linux, or Git Bash

```bash
ls ~/projects
```

### Windows PowerShell

```powershell
Get-ChildItem "$HOME\projects"
```

The command may show no contents yet. That is expected. The important result is that the folder exists without an error.

---

## P1.5 Move Between Folders

### The Target

Move the terminal into the `projects` folder.

### The Concept

The command:

```bash
cd <folder>
```

means:

```text
Change Directory
```

It is like walking from one room to another.

### The Implementation

### macOS, Linux, or Git Bash

```bash
cd ~/projects
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects"
```

In PowerShell, this shorter form also works:

```powershell
cd "$HOME\projects"
```

Confirm where you are.

### macOS, Linux, or Git Bash

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

### The Verification

Expected path resembles:

```text
/Users/your-name/projects
```

Or on Windows:

```text
C:\Users\your-name\projects
```

---

## P1.6 Create and Enter a Practice Folder

### The Target

Create a disposable folder where you can safely practice file commands.

### The Concept

Before Git tracks a project, it is helpful to practice in a folder where mistakes have no consequences.

You will create:

```text
terminal-practice/
```

inside your projects folder.

### The Implementation

Create the folder:

```bash
mkdir terminal-practice
```

Move into it:

```bash
cd terminal-practice
```

Confirm the location:

```bash
pwd
```

On Windows PowerShell:

```powershell
Get-Location
```

### The Verification

Your location should end with:

```text
projects/terminal-practice
```

---

## P1.7 Create and Read a Text File

### The Target

Create a plain-text file and display its contents in the terminal.

### The Concept

Git tracks files. Before Git can track anything, you need to recognize basic file operations.

A plain-text file contains readable characters. Files such as these are plain text:

```text
README.md
package.json
src/releaseNotes.js
.gitignore
```

### The Implementation

Create a file named `notes.txt`.

### macOS, Linux, or Git Bash

```bash
printf "Terminal practice is complete.\n" > notes.txt
```

### Windows PowerShell

```powershell
"Terminal practice is complete." | Set-Content -Path notes.txt
```

List the folder contents:

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

Display the file contents.

### macOS, Linux, or Git Bash

```bash
cat notes.txt
```

### Windows PowerShell

```powershell
Get-Content notes.txt
```

### The Verification

Expected output:

```text
Terminal practice is complete.
```

---

## P1.8 Use Relative and Absolute Paths

### The Target

Understand the difference between a relative path and an absolute path.

### The Concept

A **path** identifies a file or folder.

An **absolute path** starts from the top-level location of your computer:

```text
/Users/your-name/projects/terminal-practice/notes.txt
```

Or on Windows:

```text
C:\Users\your-name\projects\terminal-practice\notes.txt
```

A **relative path** starts from your current folder.

If you are currently inside:

```text
~/projects/terminal-practice
```

then this is a relative path:

```text
notes.txt
```

And this is another relative path:

```text
../
```

The `..` means:

> “The parent folder: one level above the current folder.”

### The Implementation

Display the file using its relative path:

### macOS, Linux, or Git Bash

```bash
cat notes.txt
```

### Windows PowerShell

```powershell
Get-Content notes.txt
```

Move to the parent `projects` folder:

```bash
cd ..
```

List its contents:

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

Return to the practice folder:

```bash
cd terminal-practice
```

### The Verification

After running:

```bash
cd ..
```

your path should end with:

```text
projects
```

After running:

```bash
cd terminal-practice
```

your path should end with:

```text
projects/terminal-practice
```

---

## P1.9 Open the Current Folder in Visual Studio Code

### The Target

Open your current terminal folder in a graphical code editor.

### The Concept

The terminal is excellent for Git commands. A code editor is better for reading and editing files.

The command:

```bash
code .
```

means:

```text
Open the current folder in Visual Studio Code.
```

The dot (`.`) means “the current directory.”

### The Implementation

From inside `terminal-practice`, run:

```bash
code .
```

If the command is unavailable, open Visual Studio Code normally and choose:

```text
File → Open Folder
```

Then select:

```text
projects/terminal-practice
```

Open `notes.txt`, change it to:

```text
Terminal practice is complete and ready for Git.
```

Save the file.

### The Verification

Return to the terminal and display the file.

### macOS, Linux, or Git Bash

```bash
cat notes.txt
```

### Windows PowerShell

```powershell
Get-Content notes.txt
```

Expected output:

```text
Terminal practice is complete and ready for Git.
```

---

## P1.10 Clean Up the Practice Folder

### The Target

Remove the temporary practice folder before beginning Git work.

### The Concept

This folder exists only to make terminal navigation comfortable. Removing it demonstrates that deleting a folder is different from deleting Git history—because this folder has not been initialized as a Git repository.

Be careful with deletion commands. They can remove files permanently.

### The Implementation

First, move out of the folder:

```bash
cd ..
```

Confirm you are in `projects`:

### macOS, Linux, or Git Bash

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

Delete the practice folder.

### macOS, Linux, or Git Bash

```bash
rm -rf terminal-practice
```

### Windows PowerShell

```powershell
Remove-Item -Recurse -Force terminal-practice
```

### The Verification

List the `projects` folder.

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

`terminal-practice` should no longer appear.

---

# Primer 1 Reference: Essential Terminal Commands

| Command | Meaning |
|---|---|
| `pwd` | Print current working directory |
| `ls` | List files and folders |
| `ls -la` | List files, including hidden files, with details |
| `cd <folder>` | Move into a folder |
| `cd ..` | Move to the parent folder |
| `mkdir <folder>` | Create a folder |
| `cat <file>` | Print a text file’s contents |
| `rm <file>` | Delete a file |
| `rm -rf <folder>` | Delete a folder and its contents; use carefully |
| `code .` | Open the current folder in Visual Studio Code |

PowerShell equivalents:

| PowerShell command | Meaning |
|---|---|
| `Get-Location` | Show current folder |
| `Get-ChildItem` | List files and folders |
| `Set-Location <folder>` | Move into a folder |
| `New-Item -ItemType Directory` | Create a folder |
| `Get-Content <file>` | Print a text file |
| `Remove-Item -Recurse -Force <folder>` | Delete a folder and its contents; use carefully |

---

# Primer 1 Completion Check

Before beginning Part 1, confirm that you can:

- [ ] Open a terminal.
- [ ] Find your current folder.
- [ ] List files, including hidden files.
- [ ] Create a folder.
- [ ] Move into and out of folders.
- [ ] Create and read a text file.
- [ ] Explain the difference between a relative and absolute path.
- [ ] Open a project folder in Visual Studio Code.
- [ ] Delete a disposable practice folder carefully.
