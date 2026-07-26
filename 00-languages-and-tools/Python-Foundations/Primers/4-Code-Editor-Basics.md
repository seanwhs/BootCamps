# Primer 4: Code Editor Basics

This primer explains how to use a code editor while working through **Python Foundations: From Zero to Functional Code**.

You do not need a particular editor. You can use:

- Visual Studio Code.
- PyCharm.
- IDLE.
- Sublime Text.
- Notepad++.
- Another editor that can save plain-text files.

The important requirements are that your editor can:

- Create files.
- Save files.
- Open folders.
- Display line numbers.
- Preserve indentation.
- Edit plain text.

---

# 1. What Is a Code Editor?

A code editor is a program used to write and modify source code.

A Python file contains plain text, such as:

```python
name = "Ada"
print(f"Hello, {name}!")
```

A code editor may provide:

- Syntax highlighting.
- Automatic indentation.
- Code completion.
- Error indicators.
- Search and replace.
- Integrated terminals.
- File browsing.

These features help, but the editor does not replace understanding Python.

---

# 2. Open the Project Folder

It is usually better to open the entire project folder rather than a single file.

Example project:

```text
python-foundations/
├── projects/
├── src/
├── data/
└── tests/
```

Open:

```text
python-foundations/
```

not only:

```text
hello.py
```

Opening the project folder makes it easier to:

- Find related files.
- See the directory structure.
- Open the terminal in the correct location.
- Use relative paths.
- Work with multiple modules.

---

# 3. Create a Python File

Create a file named:

```text
hello.py
```

Make sure the complete filename is:

```text
hello.py
```

not:

```text
hello.py.txt
```

Add:

```python
print("Hello, Python!")
```

Save the file.

Run it from the terminal:

```bash
python hello.py
```

Expected output:

```text
Hello, Python!
```

---

# 4. File Extensions

The `.py` extension identifies a Python source file.

Examples:

```text
hello.py
variables.py
task_manager.py
```

Other extensions used in the course include:

```text
.json
.toml
.md
.txt
```

The extension helps both tools and people understand the file's purpose.

---

# 5. Hidden File Extensions

Some operating systems hide known file extensions.

This can create a problem.

You may create a file that appears as:

```text
hello.py
```

but the actual filename is:

```text
hello.py.txt
```

If Python reports that it cannot find `hello.py`, inspect the complete filename.

## Windows File Explorer

To show extensions:

1. Open File Explorer.
2. Select the View menu.
3. Open Show or Folder Options.
4. Enable file-name extensions.

The exact menu labels may vary by Windows version.

---

# 6. Save Files as Plain Text

Python source files should be plain text.

When saving a file, ensure that:

- The filename ends in `.py`.
- The file is not saved as a Word document.
- The editor does not add a second extension.
- The encoding is UTF-8 when available.

Avoid using rich-text editors for Python source code.

---

# 7. Line Numbers

Enable line numbers in your editor.

Tracebacks identify locations such as:

```text
File "program.py", line 12
```

Line numbers help you locate the relevant code quickly.

Example:

```python
1  name = "Ada"
2  age = 36
3
4  print(name)
5  print(age)
```

If Python reports an error on line `4`, inspect that line and the nearby code.

Remember that the real cause may sometimes appear on the line before the reported line, especially for:

- Missing quotation marks.
- Unclosed parentheses.
- Incorrect indentation.
- Multi-line expressions.

---

# 8. Syntax Highlighting

Syntax highlighting displays different parts of code in different visual styles.

For example:

```python
def greet(name):
    return f"Hello, {name}!"
```

An editor may visually distinguish:

- Keywords such as `def` and `return`.
- Strings such as `"Hello"`.
- Function names.
- Comments.
- Numbers.

Syntax highlighting is useful, but it does not guarantee that code is correct.

A highlighted file can still contain logic errors.

---

# 9. Automatic Indentation

Python uses indentation to define blocks.

Example:

```python
if ready:
    print("Start")
```

Most editors automatically indent after a colon:

```python
if ready:
```

When you press Enter, the next line may automatically receive four spaces.

Check that your editor uses:

```text
Four spaces per indentation level
```

Avoid manually mixing tabs and spaces.

---

# 10. Indentation Settings

Recommended settings:

```text
Indentation: Spaces
Indent size: 4
Tab size: 4
```

If an editor inserts tabs automatically, configure it to convert tabs to spaces for Python files.

Inconsistent indentation can produce:

```text
IndentationError
```

or:

```text
TabError
```

---

# 11. Use the Editor's Terminal Carefully

Many editors provide an integrated terminal.

This terminal behaves like a normal terminal, but you should still check its location.

Run:

```bash
pwd
```

or on Windows PowerShell:

```powershell
Get-Location
```

Confirm that it is inside the project root before running:

```bash
python -m foundation_cli --help
```

An integrated terminal does not automatically guarantee the correct working directory.

---

# 12. Run Code from the Terminal

The editor's Run button may use a different interpreter or working directory than your terminal.

For predictable behavior, run important commands explicitly:

```bash
python hello.py
```

For the capstone:

```bash
python -m foundation_cli list
```

For tests:

```bash
python -m unittest discover -s tests -v
```

This also helps you learn the commands that will work outside the editor.

---

# 13. Select the Correct Python Interpreter

Editors may detect multiple Python installations.

Possible interpreters include:

- System Python.
- A different project environment.
- The virtual environment.
- A Conda environment.
- A Python installation from another project.

Select the interpreter inside `.venv`.

A typical path is:

### Windows

```text
.venv\Scripts\python.exe
```

### macOS/Linux

```text
.venv/bin/python
```

Confirm from the terminal:

```bash
python -c "import sys; print(sys.executable)"
```

The result should contain:

```text
.venv
```

---

# 14. Unsaved Files

Always save before running a program.

A common workflow error is:

1. Modify code.
2. Click Run.
3. Forget that the file was not saved.
4. See old output.
5. Assume Python ignored the change.

Use:

```text
Save
Run
Inspect output
```

Some editors save automatically, but do not rely on that while learning.

---

# 15. Read-Only or Locked Files

If you cannot save a file:

- Check whether it is read-only.
- Check whether another application has locked it.
- Check whether you have permission to edit the directory.
- Move the project into a directory you control.

Avoid placing beginner projects in protected system directories.

---

# 16. Search and Replace

Editors can search within a file or project.

Useful searches include:

```text
tasks.json
save_tasks
TODO
print(
```

Search helps you find:

- All uses of a function.
- Duplicate code.
- Old variable names.
- Temporary debug statements.
- References to a data file.

Use replace carefully. Make one change at a time and run tests afterward.

---

# 17. Code Formatting

Readable formatting matters.

Prefer:

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

over:

```python
task={"id":1,"title":"Learn Python","completed":False}
```

Use:

- Four spaces.
- Clear line breaks.
- Consistent quotation style.
- Blank lines between functions.
- Meaningful names.

---

# 18. Comments in the Editor

Comments begin with:

```python
#
```

Example:

```python
# Load tasks before displaying the menu.
tasks = load_tasks()
```

Use comments to explain:

- Why a non-obvious decision exists.
- An important assumption.
- A temporary learning observation.
- A limitation.

Do not comment every obvious line:

```python
# Set name to Ada
name = "Ada"
```

The code already explains itself.

---

# 19. Integrated Error Indicators

Editors may display red or yellow marks under code.

These may indicate:

- Syntax errors.
- Undefined names.
- Unused imports.
- Formatting problems.
- Type-hint warnings.

Treat these indicators as suggestions or clues, not absolute proof.

Always run the program or tests:

```bash
python program.py
```

```bash
python -m unittest discover -s tests -v
```

---

# 20. Create a Simple Editor Exercise

Create:

```text
editor-practice.py
```

Write:

```python
name = "Ada"
age = 36

if age >= 18:
    print(f"{name} is an adult.")
else:
    print(f"{name} is not an adult.")
```

Practice:

1. Rename `name` to `person_name`.
2. Change the age.
3. Change the message.
4. Break the indentation temporarily.
5. Run the file.
6. Read the error.
7. Restore the indentation.
8. Run the file again.

Record the error type you saw:

```text
____________________________________________________________
```

---

# 21. Editor Navigation Exercise

Create this structure:

```text
editor-practice/
├── scripts/
│   └── hello.py
├── data/
│   └── notes.txt
└── README.md
```

Open the `editor-practice` folder in your editor.

Practice:

- Opening `hello.py`.
- Opening `notes.txt`.
- Creating a new file.
- Renaming a file.
- Moving between folders.
- Opening the integrated terminal.
- Running `python scripts/hello.py`.

Expected output:

```text
Hello from the scripts directory.
```

---

# 22. Common Editor Problems

## The Editor Shows Old Output

Possible causes:

- The file was not saved.
- The wrong file was run.
- A different interpreter was selected.
- The terminal is in another directory.

Check:

```bash
python -c "import sys; print(sys.executable)"
```

and:

```bash
pwd
```

---

## The Editor Cannot Find Imports

Possible causes:

- The virtual environment is not active.
- The project was not installed.
- The project folder was not opened.
- The wrong interpreter is selected.

Run:

```bash
python -m pip install --editable .
```

Then:

```bash
python -m foundation_cli --help
```

---

## The Editor Adds the Wrong Extension

Check the actual filename.

It may be:

```text
program.py.txt
```

Rename it to:

```text
program.py
```

---

## The Editor Changes Indentation

Check:

- Tabs versus spaces.
- Indentation size.
- Automatic indentation settings.
- Whether code was pasted from another source.

Use four spaces for Python indentation.

---

# 23. Editor Habits Checklist

Develop these habits:

- [ ] Open the whole project folder.
- [ ] Save files before running them.
- [ ] Enable line numbers.
- [ ] Use four spaces.
- [ ] Select the project interpreter.
- [ ] Check the terminal's working directory.
- [ ] Read editor warnings.
- [ ] Run code from the terminal.
- [ ] Run tests after changes.
- [ ] Avoid rich-text editors.
- [ ] Check file extensions.
- [ ] Keep files organized.

---

# 24. Primer 4 Review Questions

## Question 1

Why is it better to open the project folder rather than only one Python file?

```text
____________________________________________________________

____________________________________________________________
```

## Question 2

What file extension should a Python source file have?

```text
____________________________________________________________
```

## Question 3

Why are line numbers useful?

```text
____________________________________________________________
```

## Question 4

What indentation style is recommended for Python?

```text
____________________________________________________________
```

## Question 5

Why should you save a file before running it?

```text
____________________________________________________________
```

## Question 6

How can you check which Python interpreter is active?

```text
____________________________________________________________
```

## Question 7

What is a possible cause of a file being named `hello.py.txt`?

```text
____________________________________________________________
```

## Question 8

Why should important commands be run from the terminal even when an editor has a Run button?

```text
____________________________________________________________

____________________________________________________________
```

---

# 25. Primer 4 Readiness Checklist

Before starting Part 1, confirm that you can:

- [ ] Open a project folder.
- [ ] Create a Python file.
- [ ] Save a Python file with a `.py` extension.
- [ ] Enable or use line numbers.
- [ ] Recognize syntax highlighting.
- [ ] Configure four-space indentation.
- [ ] Open an integrated terminal.
- [ ] Check the terminal's working directory.
- [ ] Select the virtual-environment interpreter.
- [ ] Run a file from the terminal.
- [ ] Read editor error indicators.
- [ ] Search within a project.
- [ ] Identify unsaved-file problems.
- [ ] Identify incorrect file-extension problems.

---

# Primer 4 Complete

You now understand the editor skills needed for the series.
