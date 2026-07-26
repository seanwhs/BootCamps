# Appendix E, Part 1 of 3: Debugging Checklist

This appendix provides a repeatable process for finding and fixing problems in Python programs.

Debugging is the process of investigating why a program behaves differently from what you expected.

The goal is not to guess randomly. A reliable debugging process is:

```text
Observe
    ↓
Identify
    ↓
Reproduce
    ↓
Inspect
    ↓
Change one thing
    ↓
Test again
```

This appendix is divided into three sections:

1. **Part 1:** Reading errors and identifying problems.
2. **Part 2:** Inspecting values, isolating bugs, and testing fixes.
3. **Part 3:** Preventing bugs and creating a repeatable debugging workflow.

---

# 1. Start with the Expected Behavior

Before changing code, clearly describe what should happen.

For example:

```text
When the user enters task ID 2, the program should mark task 2 as completed.
```

Then describe what actually happens:

```text
The program reports that task 2 does not exist.
```

This comparison helps define the problem:

```text
Expected:
Task 2 becomes completed.

Actual:
Task 2 is not found.
```

Avoid vague descriptions such as:

```text
The program is broken.
```

A specific description is more useful:

```text
The program receives the task ID as text but compares it with integer IDs.
```

---

# 2. Read the Complete Error Message

Suppose this program fails:

```python
tasks = ["Learn Python"]

print(tasks[1])
```

Python may display:

```text
Traceback (most recent call last):
  File "example.py", line 3, in <module>
    print(tasks[1])
IndexError: list index out of range
```

Read the traceback from the bottom upward.

The final line says:

```text
IndexError: list index out of range
```

This identifies the error type and general problem.

The earlier lines identify the location:

```text
File "example.py", line 3
```

The failing code is:

```python
print(tasks[1])
```

The list has only one item:

```text
Index 0 → "Learn Python"
```

Therefore, index `1` does not exist.

---

# 3. Identify the Error Type

Common error types include:

| Error | General meaning |
|---|---|
| `SyntaxError` | Python cannot understand the code structure |
| `IndentationError` | Code indentation is invalid |
| `NameError` | A variable or function name is unavailable |
| `TypeError` | An operation uses an inappropriate type |
| `ValueError` | A value has invalid content |
| `IndexError` | A list or tuple index does not exist |
| `KeyError` | A dictionary key does not exist |
| `FileNotFoundError` | A requested file does not exist |
| `ModuleNotFoundError` | Python cannot find an imported module |
| `JSONDecodeError` | JSON data is malformed |

The error type provides the first direction for your investigation.

---

# 4. Find the Relevant File and Line

A traceback may contain several function calls:

```text
Traceback (most recent call last):
  File "main.py", line 20, in <module>
    main()
  File "main.py", line 16, in main
    display_task(task)
  File "display.py", line 8, in display_task
    print(task["title"])
KeyError: 'title'
```

The final location is:

```text
display.py, line 8
```

The failing expression is:

```python
task["title"]
```

The dictionary probably does not contain the expected `"title"` key.

Inspect the data:

```python
print(task)
```

You may discover:

```python
{"id": 1, "name": "Learn Python"}
```

The program expects `"title"` but the data contains `"name"`.

---

# 5. Inspect the Values Involved

When an operation fails, inspect the values used by that operation.

```python
task_id = input("Task ID: ")

print("DEBUG task_id:", task_id)
print("DEBUG type:", type(task_id))
```

If the user enters `2`, the output is:

```text
DEBUG task_id: 2
DEBUG type: <class 'str'>
```

The input looks like a number but is actually a string.

If task IDs are integers:

```python
task["id"] == 2
```

then comparing against:

```python
task_id == "2"
```

will not match.

Convert the input:

```python
task_id = int(input("Task ID: "))
```

For safer input:

```python
task_id_text = input("Task ID: ").strip()

try:
    task_id = int(task_id_text)
except ValueError:
    print("Task ID must be a whole number.")
```

---

# 6. Inspect Types

Many Python bugs are caused by unexpected types.

Use:

```python
print(type(value))
```

For several values:

```python
print(f"value={value!r}")
print(f"type={type(value)}")
```

The `!r` in an f-string displays the representation of the value.

Example:

```python
text = "  hello  "

print(text)
print(repr(text))
```

Output:

```text
  hello  
'  hello  '
```

The second output makes whitespace visible.

---

# 7. Use `repr()` to Find Invisible Characters

These values appear similar:

```python
first = "task"
second = "task "
```

Normal output:

```python
print(first)
print(second)
```

may not clearly show the difference.

Use `repr()`:

```python
print(repr(first))
print(repr(second))
```

Output:

```text
'task'
'task '
```

This reveals the trailing space.

For input, normalize whitespace:

```python
command = input("Command: ").strip()
```

---

# 8. Check Whether a Collection Is Empty

Before accessing a list item, check whether the list contains anything.

Risky:

```python
tasks = []

print(tasks[0])
```

Safer:

```python
if tasks:
    print(tasks[0])
else:
    print("No tasks found.")
```

An empty list is considered falsy in Python.

This pattern also works with other collections:

```python
if not tasks:
    print("The collection is empty.")
```

---

# 9. Check Dictionary Keys

Risky:

```python
task = {
    "title": "Learn Python",
}

print(task["priority"])
```

The `"priority"` key does not exist.

Use `.get()` when a key is optional:

```python
priority = task.get("priority", "normal")

print(priority)
```

Or check explicitly:

```python
if "priority" in task:
    print(task["priority"])
else:
    print("No priority assigned.")
```

If the field is required, validate the dictionary before using it:

```python
required_keys = {"id", "title", "completed"}

if not required_keys.issubset(task):
    raise ValueError("Task is missing required fields.")
```

---

# 10. Check File Paths

File-related problems are often caused by incorrect paths or the wrong working directory.

Check the current working directory:

```bash
python -c "from pathlib import Path; print(Path.cwd())"
```

Inside Python:

```python
from pathlib import Path

print(Path.cwd())
```

Inspect a path:

```python
from pathlib import Path

file_path = Path("data/tasks.json")

print(f"Path: {file_path}")
print(f"Absolute path: {file_path.resolve()}")
print(f"Exists: {file_path.exists()}")
print(f"Is file: {file_path.is_file()}")
print(f"Is directory: {file_path.is_dir()}")
```

This can reveal that:

- The file is in another directory.
- The current directory is not what you expected.
- A file path was accidentally used as a directory.
- A directory path was accidentally used as a file.

---

# 11. Check JSON Files Directly

If a JSON file fails to load, inspect it from the terminal:

```bash
python -m json.tool data/tasks.json
```

For valid JSON, Python displays formatted data.

For invalid JSON, it reports an error location.

Check for:

- Missing commas.
- Extra commas.
- Missing quotation marks.
- Single quotes instead of double quotes.
- Unclosed braces.
- Unclosed brackets.
- Incorrect Boolean values.

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

Invalid JSON:

```json
[
  {
    'id': 1,
    'title': 'Learn Python',
    'completed': False,
  }
]
```

The invalid version uses Python syntax rather than JSON syntax.

---

# 12. Confirm the Correct Python Environment

If imports or installed packages fail, check the Python executable:

```bash
python -c "import sys; print(sys.executable)"
```

The result should point to the expected environment.

For a virtual environment, the path should contain:

```text
.venv
```

Check installed packages:

```bash
python -m pip list
```

Check a specific project:

```bash
python -m pip show foundation-cli
```

If necessary, reinstall the project:

```bash
python -m pip install --editable .
```

Using:

```bash
python -m pip
```

is generally safer than using `pip` directly because it connects `pip` to the selected Python interpreter.

---

# 13. Confirm the Command Being Run

When debugging a command-line application, write down the exact command:

```bash
python -m foundation_cli complete 2
```

Do not rely on memory.

Check:

- The command spelling.
- The argument order.
- The current directory.
- Whether the virtual environment is active.
- Whether the data file contains the expected data.

For the capstone, use:

```bash
python -m foundation_cli --help
```

to confirm the available commands and argument syntax.

---

# 14. Do Not Ignore Warnings

Warnings may not stop the program, but they can identify a problem.

For example:

```text
Warning: Invalid JSON in data/tasks.json.
```

Do not immediately ignore the message.

Ask:

- Is the file damaged?
- Was it edited manually?
- Was it written by an older version of the program?
- Is the program using the correct file?
- Should the file be repaired, replaced, or backed up?

Warnings are often early signals of future failures.

---

# 15. First-Part Checklist

When a problem occurs, begin with:

```text
[ ] What did I expect to happen?
[ ] What actually happened?
[ ] Is there a traceback?
[ ] What is the final error type?
[ ] What is the final error message?
[ ] Which file and line failed?
[ ] What values were involved?
[ ] What are their types?
[ ] Is whitespace affecting the input?
[ ] Is the collection empty?
[ ] Does the dictionary key exist?
[ ] Does the file path exist?
[ ] Am I using the correct Python environment?
[ ] Did I run the exact command I intended?
```

---

# Part 1 Summary

The first stage of debugging is gathering evidence.

Remember:

```text
Do not guess first.
Inspect first.
```

The most useful initial actions are:

```python
print(value)
print(repr(value))
print(type(value))
```

and:

```python
from pathlib import Path

print(Path.cwd())
print(file_path.resolve())
print(file_path.exists())
```

The next section will cover how to isolate a problem, create minimal examples, inspect program flow, and test possible fixes.

---

# Appendix E, Part 2 of 3: Isolating Problems and Testing Fixes

This is the second section of Appendix E.

In Part 1, you learned how to:

- Read error messages.
- Identify exception types.
- Inspect values and types.
- Check paths and JSON files.
- Verify the Python environment.
- Define expected and actual behavior.

Now you will learn how to isolate a problem, inspect program flow, and test possible fixes systematically.

---

# 1. Reduce the Problem

Large programs contain many moving parts.

If the complete application fails, do not immediately rewrite it. Reduce the problem to the smallest example that still fails.

Suppose this application fails somewhere:

```text
Command-line input
    ↓
Argument parser
    ↓
Task loader
    ↓
Task search
    ↓
Task update
    ↓
JSON save
    ↓
Terminal output
```

Test each layer independently:

1. Does the command-line parser receive the expected ID?
2. Does the storage layer load the tasks?
3. Does the task search find the ID?
4. Does the task update change the task?
5. Does saving write the result?
6. Does the display show the result?

This is easier than treating the entire program as one unit.

---

# 2. Create a Minimal Reproduction

A **minimal reproduction** is the smallest program that demonstrates the problem.

Suppose a task is not found:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]

task_id = input("Task ID: ")

for task in tasks:
    if task["id"] == task_id:
        print(task)
```

The program may produce no output when the user enters:

```text
1
```

Create a smaller version:

```python
task = {
    "id": 1,
    "title": "Learn Python",
}

task_id = input("Task ID: ")

print(repr(task["id"]))
print(type(task["id"]))
print(repr(task_id))
print(type(task_id))

print(task["id"] == task_id)
```

The output reveals:

```text
1
<class 'int'>
'1'
<class 'str'>
False
```

The problem is now clear: the input is a string, while the stored ID is an integer.

Correct:

```python
task_id = int(input("Task ID: "))
```

---

# 3. Test One Layer at a Time

Suppose `complete` does not work.

Test the task logic directly:

```python
from foundation_cli.tasks import complete_task


tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]

completed_task = complete_task(tasks, 1)

print(completed_task)
print(tasks)
```

If this works, the task logic is probably correct.

Next test storage:

```python
from pathlib import Path

from foundation_cli.storage import load_tasks, save_tasks


file_path = Path("temporary_tasks.json")

tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]

save_tasks(tasks, file_path)
loaded_tasks = load_tasks(file_path)

print(loaded_tasks)

file_path.unlink(missing_ok=True)
```

If storage works, the problem may be in the CLI dispatch or argument parsing.

---

# 4. Add Temporary Diagnostic Output

Temporary output can reveal the program's execution path.

```python
def handle_complete(task_id):
    print(f"DEBUG: received task_id={task_id!r}")
    print(f"DEBUG: type={type(task_id)}")

    tasks = load_tasks()

    print(f"DEBUG: loaded tasks={tasks!r}")

    task = complete_task(tasks, task_id)

    print(f"DEBUG: completed task={task!r}")

    save_tasks(tasks)
```

This can answer:

- Was the command handler called?
- Did it receive the expected ID?
- Were tasks loaded?
- Did the task logic return?
- Did saving occur?

Remove diagnostic output after fixing the problem unless it provides lasting value.

---

# 5. Use a Trace Variable

A trace variable can show program state at several points:

```python
print("Step 1: starting command")
tasks = load_tasks()

print("Step 2: tasks loaded")
task = find_task(tasks, task_id)

print("Step 3: task searched")

if task is None:
    print("Step 4: task was not found")
else:
    print("Step 4: task was found")
```

This helps identify the last step that executes successfully.

If you see:

```text
Step 1: starting command
Step 2: tasks loaded
```

but not:

```text
Step 3: task searched
```

the failure occurred during the search operation.

---

# 6. Inspect Function Arguments

A function may receive a different value than expected.

```python
def complete_task(tasks, task_id):
    print(f"tasks={tasks!r}")
    print(f"task_id={task_id!r}")
    print(f"task_id_type={type(task_id)}")

    ...
```

Check:

- The number of arguments.
- The argument order.
- The argument types.
- Whether optional arguments received defaults.
- Whether values were transformed before the call.

A common mistake is passing arguments in the wrong order:

```python
def calculate_total(price, quantity):
    return price * quantity


calculate_total(3, 4.50)
```

This may run but produce an incorrect result because the arguments are reversed.

Keyword arguments can make intent clearer:

```python
calculate_total(
    price=4.50,
    quantity=3,
)
```

---

# 7. Check Return Values

A function may return `None` unexpectedly.

```python
def find_task(tasks, task_id):
    for task in tasks:
        if task["id"] == task_id:
            return task
```

If no task matches, the function reaches the end without an explicit return and returns `None`.

Handle that result:

```python
task = find_task(tasks, task_id)

if task is None:
    print("Task not found.")
else:
    print(task["title"])
```

A common mistake is assuming that every search always succeeds:

```python
task = find_task(tasks, task_id)

print(task["title"])
```

If `task` is `None`, this causes an `AttributeError` or `TypeError`.

---

# 8. Check Branch Conditions

A condition may not evaluate as expected.

```python
command = input("Command: ")

if command == "list":
    print("Listing tasks.")
else:
    print("Unknown command.")
```

If the user enters:

```text
List
```

the condition is false because comparison is case-sensitive.

Normalize the input:

```python
command = input("Command: ").strip().lower()
```

Now these inputs are treated consistently:

```text
list
LIST
 List
list 
```

Use diagnostic output:

```python
print(f"Normalized command: {command!r}")
```

---

# 9. Check Loop Conditions

A `while` loop may stop too early or never stop.

## Loop Stops Too Early

```python
count = 0

while count < 3:
    print(count)
    break
    count += 1
```

The `break` ends the loop during the first iteration.

Remove it:

```python
count = 0

while count < 3:
    print(count)
    count += 1
```

---

## Infinite Loop

```python
count = 0

while count < 3:
    print(count)
```

The value of `count` never changes.

Correct:

```python
count = 0

while count < 3:
    print(count)
    count += 1
```

Stop an accidental infinite loop with:

```text
Ctrl+C
```

---

# 10. Check Collection Mutation

Changing a collection while iterating through it can cause unexpected behavior.

Risky:

```python
tasks = [
    {"completed": True},
    {"completed": False},
    {"completed": True},
]

for task in tasks:
    if task["completed"]:
        tasks.remove(task)
```

Some completed tasks may be skipped.

Create a new filtered list:

```python
remaining_tasks = [
    task for task in tasks
    if not task["completed"]
]
```

Or iterate over a copy:

```python
for task in tasks.copy():
    if task["completed"]:
        tasks.remove(task)
```

The new-list approach is often easier to understand.

---

# 11. Compare Before and After State

When a function changes data, inspect both states:

```python
before = tasks.copy()

complete_task(tasks, 1)

after = tasks

print(f"Before: {before!r}")
print(f"After: {after!r}")
```

For nested structures, `.copy()` only makes a shallow copy. If you need a completely independent snapshot:

```python
import copy


before = copy.deepcopy(tasks)

complete_task(tasks, 1)

print(f"Before: {before!r}")
print(f"After: {tasks!r}")
```

This helps determine whether the function changed the intended data.

---

# 12. Use Assertions During Investigation

Assertions can verify assumptions:

```python
assert isinstance(task_id, int)
assert isinstance(tasks, list)
```

For a task:

```python
assert isinstance(task["id"], int)
assert isinstance(task["title"], str)
assert isinstance(task["completed"], bool)
```

Include a message when useful:

```python
assert tasks, "Expected at least one task."
```

Remove overly specific temporary assertions after debugging, or convert important assumptions into normal validation.

---

# 13. Test Invalid Inputs Deliberately

Do not test only the successful path.

For a task title, test:

```text
Learn Python
```

```text

```

```text
     
```

For task IDs, test:

```text
1
```

```text
0
```

```text
-1
```

```text
abc
```

```text
999
```

For a file organizer, test:

- An existing directory.
- A missing directory.
- A file instead of a directory.
- An empty directory.
- Files with uppercase extensions.
- Files without extensions.
- Duplicate filenames.

Failure cases are part of the application's behavior.

---

# 14. Use Temporary Test Data

Do not use important personal files while testing the organizer.

Create a disposable directory:

```text
organizer_demo/
├── report.pdf
├── photo.jpg
└── notes.txt
```

Use dry-run mode first:

```bash
python -m foundation_cli organize organizer_demo --dry-run
```

Then inspect the plan before moving anything.

For automated tests, use:

```python
import tempfile
from pathlib import Path


with tempfile.TemporaryDirectory() as directory:
    test_directory = Path(directory)
    ...
```

The temporary directory is removed automatically after the test.

---

# 15. Check the Data File After Each Change

After running a command that changes tasks:

```bash
python -m foundation_cli add "Test persistence"
```

inspect:

```bash
python -m json.tool data/tasks.json
```

Confirm:

- The task was added.
- The ID is correct.
- The title is correct.
- `completed` is `false`.

After completing a task:

```bash
python -m foundation_cli complete 1
```

confirm:

```json
"completed": true
```

After removing a task, confirm that it no longer appears.

---

# 16. Reproduce the Problem Consistently

A problem that happens only once is difficult to diagnose.

Record the exact:

- Python version.
- Command.
- Input.
- File contents.
- Current directory.
- Expected output.
- Actual output.

Example:

```text
Python version:
Python 3.12.4

Current directory:
C:\Projects\python-foundations

Command:
python -m foundation_cli complete 2

Input:
2

Expected:
Task 2 completed.

Actual:
Error: No task found with ID 2.
```

This information provides a reproducible starting point.

---

# 17. Test the Smallest Suspected Function

If the CLI command fails, test the underlying function directly.

```python
from foundation_cli.tasks import find_task


tasks = [
    {
        "id": 2,
        "title": "Practice debugging",
        "completed": False,
    }
]

result = find_task(tasks, 2)

print(result)
```

Expected:

```text
{'id': 2, 'title': 'Practice debugging', 'completed': False}
```

If this works, the issue is likely outside `find_task()`.

---

# 18. Test Imports Separately

If you suspect an import problem, run a small command:

```bash
python -c "from foundation_cli.tasks import find_task; print('Import works')"
```

Test the package:

```bash
python -c "import foundation_cli; print(foundation_cli.__version__)"
```

Check the package location:

```bash
python -c "import foundation_cli; print(foundation_cli.__file__)"
```

This can reveal whether Python is importing the intended project rather than another package with the same name.

---

# 19. Run Tests After Each Fix

After changing code, run the automated tests:

```bash
python -m unittest discover -s tests -v
```

Then run the specific command related to the change:

```bash
python -m foundation_cli list
```

A fix is more trustworthy when:

- The original problem is gone.
- Existing tests still pass.
- A new test covers the problem if appropriate.

---

# 20. Part 2 Checklist

When isolating a problem, ask:

```text
[ ] Can I reproduce the issue consistently?
[ ] Can I reduce it to a smaller example?
[ ] Which layer is failing?
[ ] What arguments entered the function?
[ ] What did the function return?
[ ] Did a condition evaluate as expected?
[ ] Did a loop run the expected number of times?
[ ] Was a collection changed during iteration?
[ ] Did the data change as intended?
[ ] Did invalid inputs receive the expected response?
[ ] Did I test the smallest suspected function?
[ ] Did I run the automated tests after the change?
```

---

# Part 2 Summary

Effective debugging means narrowing the problem.

Useful techniques include:

```python
print(value)
print(repr(value))
print(type(value))
```

```python
assert condition
```

```python
before = copy.deepcopy(data)
operation(data)
after = data
```

And testing each application layer independently:

```text
Input
    ↓
Parsing
    ↓
Application logic
    ↓
Storage or file operation
    ↓
Output
```

The next section will cover prevention: clear design, validation, automated tests, logging, and a complete debugging workflow.

---

# Appendix E, Part 3 of 3: Preventing Bugs and Building a Debugging Workflow

This is the final section of Appendix E.

The previous sections covered:

- Reading errors.
- Inspecting values and types.
- Checking paths and files.
- Reducing problems.
- Testing individual functions.
- Reproducing failures.
- Testing invalid inputs.

This section focuses on preventing bugs and creating a reliable debugging process.

---

# 1. Use Small, Focused Functions

Large functions are difficult to understand and debug.

This function has too many responsibilities:

```python
def run_application():
    # Read command-line arguments
    # Load JSON
    # Validate tasks
    # Add a task
    # Save JSON
    # Print output
    # Handle errors
    ...
```

Separate those responsibilities:

```python
def load_tasks():
    ...


def create_task(tasks, title):
    ...


def save_tasks(tasks):
    ...


def display_task(task):
    ...


def main():
    ...
```

When a problem occurs, you can identify which operation is responsible.

---

# 2. Give Each Function One Main Responsibility

A function named:

```python
load_tasks()
```

should load tasks.

It should not also:

- Display a menu.
- Ask the user for a task title.
- Complete a task.
- Move files.

Focused functions are easier to:

- Read.
- Test.
- Reuse.
- Replace.
- Debug.

Example:

```python
def find_task(tasks, task_id):
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None
```

This function only searches for a task. It does not print output or modify the task.

---

# 3. Use Clear Names

Clear names reduce mistakes:

```python
completed_tasks = 3
incomplete_tasks = 2
```

This is harder to understand:

```python
x = 3
y = 2
```

Function names should describe actions:

```python
load_tasks()
save_tasks()
complete_task()
display_statistics()
```

Avoid vague names:

```python
process()
handle()
do_thing()
```

unless the context makes their purpose obvious.

---

# 4. Validate External Input

External input includes:

- User input.
- Command-line arguments.
- JSON files.
- Text files.
- Environment variables.
- Network responses.

Do not assume external data is valid.

Validate required text:

```python
title = input("Enter a task title: ").strip()

if not title:
    print("The title cannot be empty.")
```

Validate numeric input:

```python
try:
    task_id = int(user_input)
except ValueError:
    print("Task ID must be a whole number.")
```

Validate ranges:

```python
if task_id < 1:
    print("Task ID must be greater than zero.")
```

Validate JSON structure:

```python
if not isinstance(data, list):
    raise ValueError("Expected a list of tasks.")
```

---

# 5. Prefer Specific Exceptions

This hides useful information:

```python
try:
    run_application()
except Exception:
    print("Something went wrong.")
```

Prefer specific exceptions:

```python
try:
    task_id = int(user_input)
except ValueError:
    print("Task ID must be an integer.")
```

For file operations:

```python
try:
    contents = file_path.read_text(encoding="utf-8")
except FileNotFoundError:
    print("The file does not exist.")
except PermissionError:
    print("You do not have permission to read the file.")
```

Specific exceptions make the program's behavior clearer.

---

# 6. Use Assertions for Internal Assumptions

Assertions check conditions that should be true inside your own code:

```python
def calculate_total(price, quantity):
    assert price >= 0, "Price cannot be negative."
    assert quantity >= 0, "Quantity cannot be negative."

    return price * quantity
```

Assertions are useful for detecting programming mistakes.

Do not use assertions as the only validation for user input. Users should receive normal validation messages:

```python
if price < 0:
    print("Price cannot be negative.")
```

---

# 7. Use Type Hints

Type hints make intended values clearer:

```python
def find_task(
    tasks: list[dict],
    task_id: int,
) -> dict | None:
    ...
```

They help editors and static-analysis tools identify possible mistakes.

More specific aliases can improve readability:

```python
from typing import Any


Task = dict[str, Any]


def display_task(task: Task) -> None:
    print(task["title"])
```

Type hints do not replace runtime validation, but they document the design.

---

# 8. Keep Data Structures Consistent

A task should have one predictable shape:

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

Avoid mixing different shapes:

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

and:

```python
{
    "task_id": 2,
    "name": "Build a CLI",
    "done": True,
}
```

Inconsistent fields force every function to handle multiple formats.

Validate loaded data:

```python
required_keys = {"id", "title", "completed"}

if not required_keys.issubset(task):
    raise ValueError("Task is missing required fields.")
```

---

# 9. Test Success and Failure Cases

Do not test only successful input.

For task creation, test:

```python
create_task(tasks, "Learn Python")
```

Also test:

```python
create_task(tasks, "")
```

```python
create_task(tasks, "   ")
```

For task IDs, test:

```text
1
0
-1
abc
999
```

For file handling, test:

- An existing file.
- A missing file.
- Invalid JSON.
- An empty file.
- A directory used as a file.
- A file used as a directory.

Failure cases are part of the application's behavior.

---

# 10. Test Boundary Conditions

Boundary conditions are values at the edges of what is allowed.

Examples:

- An empty list.
- A one-item list.
- Zero.
- One.
- The largest allowed number.
- An empty string.
- A whitespace-only string.
- A missing dictionary key.

For a positive task ID:

```text
0
```

and:

```text
-1
```

should be rejected.

A valid minimum may be:

```text
1
```

Test each boundary deliberately.

---

# 11. Use Temporary Files in Tests

Tests should not modify real project data.

Avoid having tests change:

```text
data/tasks.json
```

Use a temporary directory:

```python
import tempfile
from pathlib import Path


with tempfile.TemporaryDirectory() as directory:
    file_path = Path(directory) / "tasks.json"
    file_path.write_text("[]", encoding="utf-8")
```

The temporary directory is automatically deleted when the block ends.

This keeps tests:

- Isolated.
- Repeatable.
- Safe.
- Independent of previous test runs.

---

# 12. Test One Change at a Time

Suppose `complete` is failing.

Do not immediately change:

- The JSON format.
- The CLI parser.
- The task logic.
- The display code.
- The storage module.

Instead, test in stages:

1. Confirm that the command receives the correct ID.
2. Confirm that tasks load correctly.
3. Confirm that the task can be found.
4. Confirm that the task changes to completed.
5. Confirm that the updated data saves.
6. Confirm that the CLI displays the result.

This identifies the failing layer.

---

# 13. Use a Layered Debugging Strategy

A structured application can be inspected layer by layer:

```text
Command-line input
        ↓
Argument parsing
        ↓
CLI dispatch
        ↓
Application logic
        ↓
Storage or file operation
        ↓
Output
```

For example, if this command fails:

```bash
python -m foundation_cli complete 2
```

check:

```text
Did argparse receive 2?
Did the CLI call handle_complete()?
Did load_tasks() return tasks?
Did find_task() find ID 2?
Did complete_task() update the dictionary?
Did save_tasks() write the JSON?
Did the output display correctly?
```

Do not assume the problem is in the first function you notice.

---

# 14. Use Logging for Larger Programs

Temporary `print()` calls are useful while learning.

For larger applications, use Python's `logging` module:

```python
import logging


logging.basicConfig(level=logging.INFO)

logging.info("Application started.")
logging.warning("Task file is missing.")
logging.error("Could not save tasks.")
```

You can use different levels:

```python
logging.debug("Detailed diagnostic information.")
logging.info("Normal application event.")
logging.warning("Unexpected but recoverable condition.")
logging.error("An operation failed.")
```

For the beginner capstone, normal user-facing output is sufficient. Logging becomes more useful as applications grow.

---

# 15. Check the Current Working Directory

File problems often occur because a program is running from an unexpected directory.

Check it from the terminal:

```bash
python -c "from pathlib import Path; print(Path.cwd())"
```

Check it inside a program:

```python
from pathlib import Path

print(Path.cwd())
```

Use reliable paths for application data:

```python
DATA_FILE = (
    Path(__file__).resolve().parents[2]
    / "data"
    / "tasks.json"
)
```

This is more reliable than assuming:

```python
Path("tasks.json")
```

always refers to the same location.

---

# 16. Inspect Files Directly

If a program reads incorrect data, inspect the file itself.

Display JSON:

```bash
python -m json.tool data/tasks.json
```

On Windows PowerShell:

```powershell
Get-Content data\tasks.json
```

On macOS or Linux:

```bash
cat data/tasks.json
```

Check for:

- Spelling errors.
- Missing commas.
- Incorrect quotation marks.
- Unexpected fields.
- Incorrect Boolean values.
- Duplicate or missing IDs.

---

# 17. Use Version Control

Git helps you compare changes and recover from mistakes.

Useful commands:

```bash
git status
```

Shows changed files.

```bash
git diff
```

Shows code changes.

```bash
git add .
```

Stages changes.

```bash
git commit -m "Add task completion command"
```

Creates a checkpoint.

Make small commits. If a change introduces a bug, you can inspect the exact difference that caused it.

---

# 18. Preserve Reproducibility

A problem is easier to fix when it can be reproduced.

Record:

- The Python version.
- The exact command.
- The input.
- The current directory.
- The data-file contents.
- The expected result.
- The actual result.

Example:

```text
Python version:
Python 3.12.4

Current directory:
C:\Projects\python-foundations

Command:
python -m foundation_cli complete 2

Expected:
Task 2 completed.

Actual:
Error: No task found with ID 2.
```

This gives you a clear starting point.

---

# 19. Add a Regression Test

A regression is a problem that returns after previously being fixed.

Suppose an empty task title once caused a crash.

Add a test:

```python
def test_empty_title_is_rejected(self):
    tasks = []

    with self.assertRaises(InvalidTaskTitleError):
        create_task(tasks, "   ")
```

Now future changes will reveal if the bug returns.

A useful rule is:

> When you fix an important bug, add a test that would have caught it.

---

# 20. Final Debugging Workflow

Use this complete process:

## Step 1: Describe the Problem

Write:

```text
Expected:
...

Actual:
...
```

## Step 2: Capture the Error

Record:

- The full traceback.
- The command.
- The input.
- The Python version.

## Step 3: Identify the Failing Layer

Determine whether the problem is in:

- Input.
- Parsing.
- Application logic.
- Storage.
- File operations.
- Output.

## Step 4: Inspect Values

Use:

```python
print(value)
print(repr(value))
print(type(value))
```

## Step 5: Create a Minimal Reproduction

Reduce the program to the smallest example that still fails.

## Step 6: Form a Hypothesis

For example:

```text
The task ID is a string, but stored IDs are integers.
```

## Step 7: Make One Change

Convert the input:

```python
task_id = int(task_id_text)
```

## Step 8: Re-run the Minimal Example

Confirm the hypothesis.

## Step 9: Run the Automated Tests

```bash
python -m unittest discover -s tests -v
```

## Step 10: Test the Full Command

```bash
python -m foundation_cli complete 2
```

## Step 11: Add a Regression Test

Ensure the problem cannot easily return.

---

# 21. Complete Debugging Checklist

```text
[ ] Did I define the expected behavior?
[ ] Did I record the actual behavior?
[ ] Did I read the complete error message?
[ ] Did I identify the exception type?
[ ] Did I find the file and line number?
[ ] Did I inspect the relevant values?
[ ] Did I check their types?
[ ] Did I use repr() to reveal whitespace?
[ ] Did I check whether collections are empty?
[ ] Did I check dictionary keys?
[ ] Did I verify the current directory?
[ ] Did I verify the file path?
[ ] Did I confirm the Python environment?
[ ] Did I reduce the problem?
[ ] Did I test one layer at a time?
[ ] Did I change only one thing?
[ ] Did I test both success and failure cases?
[ ] Did I run the automated tests?
[ ] Did I add a regression test?
```

---

# Appendix E Complete

You have now completed all three sections:

```text
Appendix E, Part 1:
Reading errors and identifying problems

Appendix E, Part 2:
Isolating problems and testing fixes

Appendix E, Part 3:
Preventing bugs and building a debugging workflow
```

The most important debugging habits are:

```text
Observe before changing.
Inspect values and types.
Reduce large problems.
Change one thing at a time.
Test success and failure.
Automate fixes with tests.
```

A reliable debugging process is:

```text
Describe
    ↓
Read
    ↓
Inspect
    ↓
Reproduce
    ↓
Hypothesize
    ↓
Change
    ↓
Test
    ↓
Document
```
