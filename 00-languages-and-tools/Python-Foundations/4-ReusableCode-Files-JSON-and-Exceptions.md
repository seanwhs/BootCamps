You’re right. I’ll divide **Part 4** into smaller, clearly labeled sections so it does not get cut off.

# Part 4A: Functions and Reusable Code

This is **Section 1 of 4**.

The four sections will be:

1. **Part 4A:** Functions, parameters, return values, scope, and type hints.
2. **Part 4B:** Modules, text files, and `pathlib`.
3. **Part 4C:** JSON, exceptions, and safe file handling.
4. **Part 4D:** Building the persistent task manager.

---

# Part 4A: Functions and Reusable Code

In previous parts, your programs placed most instructions directly in the main script.

For example:

```python
tasks = []

while True:
    # Display menu
    # Read input
    # Add tasks
    # Remove tasks
    # Complete tasks
    # Display tasks
```

This can work for a small experiment, but larger programs become difficult to read and maintain.

Functions help us divide a program into smaller, focused operations.

---

## 1. What Is a Function?

A function is a named block of reusable code.

Without a function:

```python
print("Hello, Ada!")
print("Hello, Grace!")
```

With a function:

```python
def greet(name):
    print(f"Hello, {name}!")


greet("Ada")
greet("Grace")
```

Output:

```text
Hello, Ada!
Hello, Grace!
```

The function gives a name to an operation:

```python
greet
```

The function is called here:

```python
greet("Ada")
```

---

## 2. Defining a Function

The basic structure is:

```python
def function_name():
    # Function body
```

Create:

```text
projects/functions_intro.py
```

Add these complete contents:

```python
def show_welcome():
    print("Welcome to Python.")
    print("We are learning about functions.")


show_welcome()
```

Run it:

```bash
python projects/functions_intro.py
```

Expected output:

```text
Welcome to Python.
We are learning about functions.
```

The function body is indented by four spaces.

The function does not run when Python reads the definition. It runs when Python reaches:

```python
show_welcome()
```

---

## 3. Calling a Function Multiple Times

A function can be called repeatedly:

```python
def show_separator():
    print("----------------")


show_separator()
print("Task Manager")
show_separator()
```

Output:

```text
----------------
Task Manager
----------------
```

This prevents you from copying the same code into multiple places.

---

## 4. Parameters

A parameter is a variable listed inside a function definition.

```python
def greet(name):
    print(f"Hello, {name}!")
```

The parameter is:

```python
name
```

When calling the function, provide an argument:

```python
greet("Ada")
```

Here:

- `name` is the parameter.
- `"Ada"` is the argument.

Create:

```text
projects/greetings.py
```

Add:

```python
def greet(name):
    print(f"Hello, {name}!")


greet("Ada")
greet("Grace")
greet("Linus")
```

Run it:

```bash
python projects/greetings.py
```

Expected output:

```text
Hello, Ada!
Hello, Grace!
Hello, Linus!
```

---

## 5. Multiple Parameters

A function can accept several parameters:

```python
def describe_person(name, age, city):
    print(f"{name} is {age} years old and lives in {city}.")


describe_person("Ada", 36, "London")
```

Output:

```text
Ada is 36 years old and lives in London.
```

Arguments are normally matched by position.

This call:

```python
describe_person("Ada", 36, "London")
```

matches:

```text
name → "Ada"
age  → 36
city → "London"
```

---

## 6. Keyword Arguments

You can provide arguments by name:

```python
def describe_person(name, age, city):
    print(f"{name} is {age} years old and lives in {city}.")


describe_person(
    name="Ada",
    age=36,
    city="London",
)
```

Keyword arguments make calls easier to understand.

You can also provide them in a different order:

```python
describe_person(
    city="London",
    name="Ada",
    age=36,
)
```

The result is the same because each value is associated with a parameter name.

---

## 7. Returning Values

A function can return a result using `return`.

```python
def add_numbers(first, second):
    return first + second


result = add_numbers(3, 4)

print(result)
```

Output:

```text
7
```

The function returns:

```python
first + second
```

The caller stores that result in:

```python
result
```

---

## 8. Why `return` Is Useful

A function that prints a result is less flexible:

```python
def calculate_total(price, quantity):
    print(price * quantity)
```

A function that returns a result can be reused:

```python
def calculate_total(price, quantity):
    return price * quantity


total = calculate_total(4.50, 3)
tax = total * 0.20
grand_total = total + tax

print(f"Subtotal: ${total:.2f}")
print(f"Tax: ${tax:.2f}")
print(f"Grand total: ${grand_total:.2f}")
```

Output:

```text
Subtotal: $13.50
Tax: $2.70
Grand total: $16.20
```

The function only calculates the total. The calling code decides how to display or use it.

---

## 9. Returning Boolean Values

A function can return `True` or `False`.

```python
def is_even(number):
    return number % 2 == 0


print(is_even(8))
print(is_even(7))
```

Output:

```text
True
False
```

The function can be used inside a conditional:

```python
number = 12

if is_even(number):
    print("The number is even.")
else:
    print("The number is odd.")
```

Output:

```text
The number is even.
```

---

## 10. Functions and Lists

Functions can receive lists as parameters.

```python
def display_tasks(tasks):
    for task in tasks:
        print(task)


tasks = [
    "Learn Python",
    "Practice functions",
    "Build a project",
]

display_tasks(tasks)
```

Output:

```text
Learn Python
Practice functions
Build a project
```

A function can also calculate information about a list:

```python
def count_tasks(tasks):
    return len(tasks)


tasks = [
    "Learn Python",
    "Practice functions",
    "Build a project",
]

number_of_tasks = count_tasks(tasks)

print(f"Number of tasks: {number_of_tasks}")
```

Output:

```text
Number of tasks: 3
```

---

## 11. Default Parameters

A parameter can have a default value:

```python
def greet(name, greeting="Hello"):
    return f"{greeting}, {name}!"


print(greet("Ada"))
print(greet("Grace", "Welcome"))
```

Output:

```text
Hello, Ada!
Welcome, Grace!
```

The default is used when the caller does not provide that argument.

A task function could use a default priority:

```python
def create_task(title, priority="normal"):
    return {
        "title": title,
        "priority": priority,
        "completed": False,
    }


print(create_task("Learn Python"))
print(create_task("Build a project", "high"))
```

Output:

```text
{'title': 'Learn Python', 'priority': 'normal', 'completed': False}
{'title': 'Build a project', 'priority': 'high', 'completed': False}
```

Required parameters must come before default parameters:

```python
def create_task(title, priority="normal"):
    ...
```

---

## 12. Type Hints

Type hints describe the values a function expects and returns.

```python
def add_numbers(first: int, second: int) -> int:
    return first + second
```

This communicates that:

- `first` should be an integer.
- `second` should be an integer.
- The function should return an integer.

Another example:

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"
```

A function that only performs an action can use `None`:

```python
def show_message(message: str) -> None:
    print(message)
```

Type hints improve readability and help code editors detect possible mistakes.

They do not automatically enforce types at runtime.

This still executes:

```python
def add_numbers(first: int, second: int) -> int:
    return first + second


print(add_numbers("a", "b"))
```

Output:

```text
ab
```

The annotations describe intended usage; they do not perform automatic validation.

---

## 13. Type Hints for Tasks

Python 3.9 and newer support collection type hints like these:

```python
def display_tasks(tasks: list[str]) -> None:
    for task in tasks:
        print(task)
```

For task dictionaries with different value types, you can use `Any`:

```python
from typing import Any


Task = dict[str, Any]
```

Now you can write:

```python
def display_task(task: Task) -> None:
    print(task["title"])
```

The alias makes the function signature easier to read.

---

## 14. Building Task Functions

Create:

```text
projects/task_functions.py
```

Add these complete contents:

```python
from typing import Any


Task = dict[str, Any]


def display_task(task: Task) -> None:
    """Display one task."""
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")


def display_tasks(tasks: list[Task]) -> None:
    """Display all tasks."""
    if not tasks:
        print("No tasks found.")
        return

    print("Tasks:")

    for task in tasks:
        display_task(task)


def find_task(tasks: list[Task], task_id: int) -> Task | None:
    """Find a task by ID."""
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


tasks: list[Task] = [
    {
        "id": 1,
        "title": "Learn functions",
        "completed": False,
    },
    {
        "id": 2,
        "title": "Practice return values",
        "completed": True,
    },
]

display_tasks(tasks)

task = find_task(tasks, 2)

if task is not None:
    print()
    print(f"Found task: {task['title']}")
```

Run it:

```bash
python projects/task_functions.py
```

Expected output:

```text
Tasks:
[ ] 1 - Learn functions
[x] 2 - Practice return values

Found task: Practice return values
```

---

## 15. Understanding the Task Functions

This function displays one task:

```python
def display_task(task: Task) -> None:
```

This function displays every task:

```python
def display_tasks(tasks: list[Task]) -> None:
```

It calls `display_task()` for each dictionary:

```python
for task in tasks:
    display_task(task)
```

This function searches for a task:

```python
def find_task(tasks: list[Task], task_id: int) -> Task | None:
```

If it finds a matching task, it returns that dictionary:

```python
return task
```

If it reaches the end without finding a match, it returns:

```python
return None
```

The caller checks for `None`:

```python
if task is not None:
    print(f"Found task: {task['title']}")
```

---

## 16. Variable Scope

Scope determines where a variable can be accessed.

A variable created inside a function is local to that function:

```python
def create_message():
    message = "Hello"
    print(message)


create_message()
```

This works because `message` is used inside the function.

This does not work:

```python
def create_message():
    message = "Hello"


create_message()
print(message)
```

The variable `message` exists only inside `create_message()`.

---

## 17. Function Parameters Are Local

```python
def show_name(name):
    print(name)


show_name("Ada")
```

The parameter `name` is available inside the function but not outside it.

Use `return` when information needs to leave a function:

```python
def create_name():
    name = "Ada"
    return name


person_name = create_name()
print(person_name)
```

Output:

```text
Ada
```

---

## 18. Variables Outside Functions

A variable created outside a function belongs to the surrounding module:

```python
application_name = "Task Manager"


def show_application_name():
    print(application_name)


show_application_name()
```

This works because the function can read the surrounding variable.

However, it is generally clearer to pass values explicitly:

```python
def show_application_name(name):
    print(name)


show_application_name("Task Manager")
```

Explicit parameters make dependencies easier to understand and test.

---

## 19. Avoiding Unnecessary Global State

This style uses a global variable:

```python
tasks = []


def add_task(title):
    tasks.append(title)
```

It works, but the function secretly depends on the global `tasks` list.

A clearer style passes the list explicitly:

```python
def add_task(tasks, title):
    tasks.append(title)


tasks = []

add_task(tasks, "Learn Python")
```

The function's required data is visible in its parameters.

This becomes especially important when testing functions.

---

## 20. The `main()` Pattern

A common structure for Python programs is:

```python
def main():
    print("Program started.")


if __name__ == "__main__":
    main()
```

Create:

```text
projects/main_pattern.py
```

Add these complete contents:

```python
def main() -> None:
    print("The program is running.")


if __name__ == "__main__":
    main()
```

Run it:

```bash
python projects/main_pattern.py
```

Expected output:

```text
The program is running.
```

The condition:

```python
if __name__ == "__main__":
```

is true when the file is executed directly.

It is false when the file is imported by another module.

This prevents the main program from starting automatically during import.

---

## 21. Refactoring the Example

Instead of:

```python
print("Task Manager")
print("------------")
```

you can create:

```python
def show_menu() -> None:
    print("Task Manager")
    print("------------")
```

Then call:

```python
show_menu()
```

This gives the operation a meaningful name and keeps the main program easier to read.

---

## 22. Verification

Run each of these commands:

```bash
python projects/functions_intro.py
```

```bash
python projects/greetings.py
```

```bash
python projects/task_functions.py
```

```bash
python projects/main_pattern.py
```

Confirm that:

- Functions are defined with `def`.
- Functions are called by name.
- Arguments are passed correctly.
- Functions can return values.
- Type hints do not change the basic execution.
- The task functions display and find tasks correctly.

Your project should now include:

```text
projects/
├── functions_intro.py
├── greetings.py
├── task_functions.py
└── main_pattern.py
```

---

## Part 4A Summary

In this section, you learned:

- What functions are.
- How to define and call functions.
- Parameters and arguments.
- Keyword arguments.
- Return values.
- Default parameters.
- Type hints.
- Local and surrounding scope.
- The `main()` pattern.
- How to separate task operations into functions.

The key idea is to give each operation a clear responsibility.

For example:

```python
display_tasks()
find_task()
create_task()
save_tasks()
```

A well-named function makes a program easier to understand.

The next section is:

# Part 4B: Modules, Text Files, and `pathlib`

It will cover:

- Importing code from other files.
- Creating modules.
- Writing text files.
- Reading text files.
- Appending content.
- Creating directories.
- Building platform-independent paths.

---

# Part 4B: Modules, Text Files, and `pathlib`

This is **Section 2 of 4** in Part 4.

In Part 4A, you learned how to create reusable functions. Now you will learn how to place related functions in separate files and work with files on your computer.

You will learn:

- What modules are.
- How to import functions.
- How to write text files.
- How to read text files.
- How to append content.
- How to use `pathlib`.
- How to create directories.
- How to combine paths safely.

---

# 1. What Is a Module?

A **module** is a Python file containing reusable code.

For example, this file:

```text
calculations.py
```

can contain calculation functions:

```python
def add(first, second):
    return first + second
```

Another file can import and use that function.

Modules help you:

- Keep related code together.
- Avoid very long files.
- Reuse functions.
- Separate responsibilities.
- Make programs easier to test.

---

# 2. Creating a Module

Create:

```text
projects/calculations.py
```

Add these complete contents:

```python
def add(first: int, second: int) -> int:
    return first + second


def subtract(first: int, second: int) -> int:
    return first - second


def multiply(first: int, second: int) -> int:
    return first * second
```

This file defines three functions but does not call them.

Now create:

```text
projects/use_calculations.py
```

Add:

```python
from calculations import add, multiply


def main() -> None:
    print(add(2, 3))
    print(multiply(4, 5))


if __name__ == "__main__":
    main()
```

Run it from the `projects` directory:

```bash
cd projects
python use_calculations.py
```

Expected output:

```text
5
20
```

Return to the project root:

```bash
cd ..
```

This statement imports two specific functions:

```python
from calculations import add, multiply
```

---

# 3. Importing an Entire Module

Instead of importing individual functions, you can import the entire module.

Create:

```text
projects/use_calculations_module.py
```

Add:

```python
import calculations


def main() -> None:
    print(calculations.add(10, 5))
    print(calculations.subtract(10, 5))
    print(calculations.multiply(10, 5))


if __name__ == "__main__":
    main()
```

Run it from `projects`:

```bash
cd projects
python use_calculations_module.py
```

Expected output:

```text
15
5
50
```

The module name appears before each function:

```python
calculations.add(10, 5)
```

This makes it clear where the function came from.

---

# 4. Import Aliases

You can give an imported module a shorter name:

```python
import calculations as calc


print(calc.add(2, 3))
```

You can also give an imported function an alias:

```python
from calculations import multiply as multiply_numbers


print(multiply_numbers(4, 5))
```

Use aliases carefully. Clear names are usually better than overly short names.

---

# 5. The `if __name__` Pattern in Modules

Consider this file:

```python
def show_message():
    print("Hello from the module.")


show_message()
```

If another file imports it:

```python
import message_module
```

the `show_message()` call runs immediately during import.

Usually, reusable modules should define functions without automatically starting the program.

Use this structure instead:

```python
def show_message():
    print("Hello from the module.")


if __name__ == "__main__":
    show_message()
```

Now:

- Running the file directly executes `show_message()`.
- Importing the file only makes the function available.

---

# 6. Writing Text Files

Programs can save information in text files.

Create:

```text
projects/write_text.py
```

Add:

```python
file_path = "example.txt"

with open(file_path, "w", encoding="utf-8") as file:
    file.write("First line\n")
    file.write("Second line\n")

print(f"Created {file_path}")
```

Run it from the `projects` directory:

```bash
cd projects
python write_text.py
```

Expected output:

```text
Created example.txt
```

The program creates:

```text
projects/example.txt
```

Its contents should be:

```text
First line
Second line
```

Return to the project root:

```bash
cd ..
```

---

## Understanding the File Code

This line opens the file:

```python
with open(file_path, "w", encoding="utf-8") as file:
```

The parts mean:

- `open()` opens a file.
- `file_path` is the file's name or path.
- `"w"` means write mode.
- `encoding="utf-8"` supports standard text characters.
- `as file` gives the opened file a variable name.
- `with` closes the file safely afterward.

The newline character is:

```python
"\n"
```

This writes two separate lines:

```python
file.write("First line\n")
file.write("Second line\n")
```

---

# 7. File Modes

Python commonly uses these file modes:

| Mode | Purpose |
|---|---|
| `"r"` | Read an existing file |
| `"w"` | Write and replace existing contents |
| `"a"` | Append to existing contents |
| `"x"` | Create a new file, failing if it already exists |

Be careful with `"w"`.

This code replaces the complete contents of the file:

```python
with open("example.txt", "w", encoding="utf-8") as file:
    file.write("New content\n")
```

---

# 8. Reading a Text File

Create:

```text
projects/read_text.py
```

Add:

```python
with open("example.txt", "r", encoding="utf-8") as file:
    contents = file.read()

print(contents)
```

Run it from the `projects` directory:

```bash
cd projects
python read_text.py
```

Expected output:

```text
First line
Second line
```

Return to the project root:

```bash
cd ..
```

The `.read()` method returns the entire file as one string.

---

# 9. Reading Lines One at a Time

You can loop through a file line by line:

```python
with open("example.txt", "r", encoding="utf-8") as file:
    for line in file:
        print(line.strip())
```

The `.strip()` method removes the newline and surrounding whitespace.

Without `.strip()`, the file's newline and `print()`'s newline can create blank lines between outputs.

---

# 10. Reading All Lines into a List

Use `.readlines()`:

```python
with open("example.txt", "r", encoding="utf-8") as file:
    lines = file.readlines()

print(lines)
```

The result may look like:

```python
['First line\n', 'Second line\n']
```

The newline characters remain in the list items.

You can remove them:

```python
with open("example.txt", "r", encoding="utf-8") as file:
    lines = [line.strip() for line in file]

print(lines)
```

Output:

```text
['First line', 'Second line']
```

The list-comprehension syntax will be studied more thoroughly later, but the important idea is that each line is transformed with `.strip()`.

---

# 11. Appending to a Text File

Use append mode, `"a"`, to add content without replacing existing contents.

Create:

```text
projects/append_text.py
```

Add:

```python
with open("example.txt", "a", encoding="utf-8") as file:
    file.write("Third line\n")

print("Added a line.")
```

Run it from `projects`:

```bash
cd projects
python append_text.py
```

Read the file:

```bash
python read_text.py
```

Expected output:

```text
First line
Second line
Third line
```

Return to the project root:

```bash
cd ..
```

---

# 12. Using `pathlib`

The `pathlib` module provides an object-oriented way to work with paths.

It is generally clearer and safer than manually building paths with strings.

Create:

```text
projects/pathlib_example.py
```

Add:

```python
from pathlib import Path


file_path = Path("example.txt")

file_path.write_text(
    "Written using pathlib.\n",
    encoding="utf-8",
)

contents = file_path.read_text(encoding="utf-8")

print(contents)
```

Run it from the `projects` directory:

```bash
cd projects
python pathlib_example.py
```

Expected output:

```text
Written using pathlib.
```

Return to the project root:

```bash
cd ..
```

The following line creates a `Path` object:

```python
file_path = Path("example.txt")
```

The file can then be written with:

```python
file_path.write_text(...)
```

and read with:

```python
file_path.read_text(...)
```

---

# 13. Creating a Directory

You can create directories with `Path.mkdir()`.

Create:

```text
projects/create_directory.py
```

Add:

```python
from pathlib import Path


data_directory = Path("data")

data_directory.mkdir(exist_ok=True)

print(f"Directory exists: {data_directory.exists()}")
```

Run it from `projects`:

```bash
cd projects
python create_directory.py
```

Expected output:

```text
Directory exists: True
```

A directory named `data` should now exist:

```text
projects/
└── data/
```

Return to the project root:

```bash
cd ..
```

The argument:

```python
exist_ok=True
```

prevents an error if the directory already exists.

---

# 14. Creating Nested Directories

Suppose you want to create:

```text
data/archive/2026/
```

Use:

```python
from pathlib import Path


archive_directory = Path("data") / "archive" / "2026"

archive_directory.mkdir(parents=True, exist_ok=True)

print(f"Created: {archive_directory}")
```

The `parents=True` argument creates missing parent directories.

Without `parents=True`, Python may fail if `data` or `archive` does not already exist.

---

# 15. Combining Paths

Do not manually construct paths like this:

```python
file_path = "data/" + "tasks.json"
```

This can be less portable across operating systems.

Use the `/` operator with `Path` objects:

```python
from pathlib import Path


data_directory = Path("data")
file_path = data_directory / "tasks.json"

print(file_path)
```

Output:

```text
data/tasks.json
```

On Windows, Python handles the appropriate path representation internally.

---

# 16. Absolute and Relative Paths

A **relative path** starts from the current working directory:

```python
Path("data/tasks.json")
```

An **absolute path** describes the complete location:

```text
C:\Users\You\python-foundations\data\tasks.json
```

Relative paths are usually preferable for project files because they make projects easier to move between computers.

You can inspect the current working directory:

```python
from pathlib import Path


print(Path.cwd())
```

You can convert a relative path to an absolute path:

```python
file_path = Path("data/tasks.json")

print(file_path.resolve())
```

---

# 17. Checking Paths

`Path` objects provide useful methods:

```python
from pathlib import Path


file_path = Path("example.txt")

print(f"Exists: {file_path.exists()}")
print(f"Is file: {file_path.is_file()}")
print(f"Is directory: {file_path.is_dir()}")
```

Possible output:

```text
Exists: True
Is file: True
Is directory: False
```

For a directory:

```python
directory = Path("data")

print(directory.exists())
print(directory.is_dir())
```

---

# 18. File Names and Extensions

`pathlib` can inspect parts of a path:

```python
from pathlib import Path


file_path = Path("documents/report.txt")

print(file_path.name)
print(file_path.stem)
print(file_path.suffix)
print(file_path.parent)
```

Output:

```text
report.txt
report
.txt
documents
```

The properties mean:

| Property | Result |
|---|---|
| `.name` | `report.txt` |
| `.stem` | `report` |
| `.suffix` | `.txt` |
| `.parent` | `documents` |

These properties will be useful in the capstone file-organizer utility.

---

# 19. Listing Directory Contents

Use `.iterdir()` to inspect a directory:

```python
from pathlib import Path


directory = Path(".")

for item in directory.iterdir():
    print(item)
```

The dot means the current directory.

You can identify files and directories:

```python
from pathlib import Path


directory = Path(".")

for item in directory.iterdir():
    if item.is_file():
        print(f"File: {item}")
    elif item.is_dir():
        print(f"Directory: {item}")
```

---

# 20. Finding Files with `glob()`

Use `.glob()` to find matching paths.

Create:

```text
projects/find_python_files.py
```

Add:

```python
from pathlib import Path


projects_directory = Path(".")

for file_path in projects_directory.glob("*.py"):
    print(file_path)
```

Run it from `projects`:

```bash
cd projects
python find_python_files.py
```

This lists Python files in the current directory.

To search recursively through subdirectories, use `rglob()`:

```python
for file_path in projects_directory.rglob("*.py"):
    print(file_path)
```

Return to the project root:

```bash
cd ..
```

---

# 21. A Notes Program

We can combine functions and `pathlib` to create a small notes program.

Create:

```text
projects/notes.py
```

Add these complete contents:

```python
from pathlib import Path


NOTES_FILE = Path("notes.txt")


def add_note(note: str) -> None:
    """Append one note to the notes file."""
    with NOTES_FILE.open("a", encoding="utf-8") as file:
        file.write(f"{note}\n")


def list_notes() -> list[str]:
    """Return all saved notes."""
    if not NOTES_FILE.exists():
        return []

    contents = NOTES_FILE.read_text(encoding="utf-8")
    return contents.splitlines()


def main() -> None:
    note = input("Enter a note: ").strip()

    if not note:
        print("The note cannot be empty.")
        return

    add_note(note)

    print("Saved notes:")
    for saved_note in list_notes():
        print(f"- {saved_note}")


if __name__ == "__main__":
    main()
```

Run it from the `projects` directory:

```bash
cd projects
python notes.py
```

Example:

```text
Enter a note: Review Python functions
Saved notes:
- Review Python functions
```

Run it again:

```bash
python notes.py
```

Enter:

```text
Practice pathlib
```

Expected output:

```text
Enter a note: Practice pathlib
Saved notes:
- Review Python functions
- Practice pathlib
```

Return to the project root:

```bash
cd ..
```

---

# 22. Understanding the Notes Program

This constant identifies the data file:

```python
NOTES_FILE = Path("notes.txt")
```

This function appends a note:

```python
def add_note(note: str) -> None:
```

This function returns all saved notes:

```python
def list_notes() -> list[str]:
```

If the file does not exist, it returns an empty list:

```python
if not NOTES_FILE.exists():
    return []
```

The `.splitlines()` method converts the file contents into a list:

```python
return contents.splitlines()
```

For example:

```python
"First note\nSecond note".splitlines()
```

becomes:

```python
["First note", "Second note"]
```

---

# 23. Verification

Run the following commands:

```bash
python projects/use_calculations.py
```

```bash
python projects/use_calculations_module.py
```

```bash
python projects/write_text.py
```

```bash
python projects/read_text.py
```

```bash
python projects/pathlib_example.py
```

```bash
python projects/create_directory.py
```

```bash
python projects/notes.py
```

Confirm that:

- You can import functions from another module.
- You can write a text file.
- You can read a text file.
- You can append content.
- You can create directories.
- You can construct paths with `Path`.
- You can inspect file extensions.
- The notes program preserves data between runs.

Your project should now contain files similar to:

```text
projects/
├── calculations.py
├── use_calculations.py
├── use_calculations_module.py
├── write_text.py
├── read_text.py
├── append_text.py
├── pathlib_example.py
├── create_directory.py
├── find_python_files.py
├── notes.py
├── example.txt
├── notes.txt
└── data/
```

---

# Part 4B Summary

In this section, you learned:

- A module is a reusable Python file.
- Functions can be imported from other files.
- The `with open(...)` pattern safely works with files.
- `"w"` replaces file contents.
- `"a"` appends to file contents.
- `"r"` reads file contents.
- `pathlib.Path` provides cross-platform paths.
- `mkdir()` creates directories.
- `.exists()`, `.is_file()`, and `.is_dir()` inspect paths.
- `.glob()` and `.rglob()` find files.
- Text files can preserve data between program runs.

The next section is:

# Part 4C: JSON, Exceptions, and Safe File Handling

It will cover:

- Writing Python data as JSON.
- Reading JSON data.
- Handling missing files.
- Handling invalid JSON.
- Handling invalid numeric input.
- Separating storage logic from application logic.

---

# Part 4C: JSON, Exceptions, and Safe File Handling

This is **Section 3 of 4** in Part 4.

In Part 4B, you learned how to work with modules, text files, and `pathlib`.

Now you will learn how to store structured Python data in JSON and handle expected errors safely.

You will learn:

- What JSON is.
- How to write JSON files.
- How to read JSON files.
- How to handle missing files.
- How to handle malformed JSON.
- How to handle invalid user input with exceptions.
- How to validate loaded data.
- How to separate storage code from application code.

---

# 1. What Is JSON?

JSON stands for **JavaScript Object Notation**.

It is a text format commonly used to store and exchange structured data.

Python dictionary:

```python
task = {
    "id": 1,
    "title": "Learn JSON",
    "completed": False,
}
```

Equivalent JSON:

```json
{
  "id": 1,
  "title": "Learn JSON",
  "completed": false
}
```

The differences include:

| Python | JSON |
|---|---|
| `True` | `true` |
| `False` | `false` |
| `None` | `null` |
| Single or double quotes | Double quotes required for strings |

JSON can represent:

- Objects, which become Python dictionaries.
- Arrays, which become Python lists.
- Strings.
- Numbers.
- Booleans.
- `null`.

A list of tasks is naturally represented as a JSON array:

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  },
  {
    "id": 2,
    "title": "Build a project",
    "completed": true
  }
]
```

---

# 2. Writing JSON with `json.dump()`

Create:

```text
projects/write_json.py
```

Add these complete contents:

```python
import json
from pathlib import Path


tasks = [
    {
        "id": 1,
        "title": "Learn JSON",
        "completed": False,
    },
    {
        "id": 2,
        "title": "Save task data",
        "completed": True,
    },
]

file_path = Path("tasks.json")

with file_path.open("w", encoding="utf-8") as file:
    json.dump(tasks, file, indent=2)

print(f"Saved tasks to {file_path}")
```

Run it from the `projects` directory:

```bash
cd projects
python write_json.py
```

Expected output:

```text
Saved tasks to tasks.json
```

A file named `tasks.json` should now exist.

Return to the project root:

```bash
cd ..
```

The JSON file should contain:

```json
[
  {
    "id": 1,
    "title": "Learn JSON",
    "completed": false
  },
  {
    "id": 2,
    "title": "Save task data",
    "completed": true
  }
]
```

The `indent=2` argument formats the file so it is easier for humans to read.

Without indentation, the output may appear on one line:

```json
[{"id": 1, "title": "Learn JSON", "completed": false}]
```

Both versions are valid JSON, but the indented version is easier to inspect manually.

---

# 3. Writing JSON as a String

`json.dumps()` converts Python data into a JSON string.

```python
import json


task = {
    "id": 1,
    "title": "Learn JSON",
    "completed": False,
}

json_text = json.dumps(task, indent=2)

print(json_text)
```

Output:

```json
{
  "id": 1,
  "title": "Learn JSON",
  "completed": false
}
```

The difference is:

| Function | Purpose |
|---|---|
| `json.dump()` | Writes JSON directly to a file |
| `json.dumps()` | Returns JSON as a string |

The extra `s` in `dumps` means “string.”

---

# 4. Reading JSON with `json.load()`

Create:

```text
projects/read_json.py
```

Add:

```python
import json
from pathlib import Path


file_path = Path("tasks.json")

with file_path.open("r", encoding="utf-8") as file:
    tasks = json.load(file)

for task in tasks:
    print(task["title"])
```

Run it from the `projects` directory:

```bash
cd projects
python read_json.py
```

Expected output:

```text
Learn JSON
Save task data
```

Return to the project root:

```bash
cd ..
```

The `json.load()` function reads JSON from an open file and converts it into Python objects.

In this example:

```json
[
  {
    "id": 1,
    "title": "Learn JSON",
    "completed": false
  }
]
```

becomes:

```python
[
    {
        "id": 1,
        "title": "Learn JSON",
        "completed": False,
    }
]
```

---

# 5. Reading JSON from a String

The `json.loads()` function converts a JSON string into Python data.

```python
import json


json_text = """
{
    "name": "Ada",
    "age": 36,
    "is_learning": true
}
"""

person = json.loads(json_text)

print(person["name"])
print(person["age"])
print(person["is_learning"])
```

Output:

```text
Ada
36
True
```

The difference is:

| Function | Purpose |
|---|---|
| `json.load()` | Reads JSON from a file |
| `json.loads()` | Reads JSON from a string |

---

# 6. Exceptions

An exception is an error that occurs while a program is running.

For example:

```python
number = int("not a number")
```

This raises a `ValueError`.

If the exception is not handled, Python stops the program and displays a traceback.

Use `try` and `except` to handle expected errors:

```python
try:
    number = int("not a number")
except ValueError:
    print("That value is not a valid integer.")
```

Output:

```text
That value is not a valid integer.
```

The basic structure is:

```python
try:
    # Code that might fail
except SomeError:
    # Code that handles that error
```

---

# 7. Handling Numeric Input

Create:

```text
projects/safe_number.py
```

Add:

```python
user_input = input("Enter a whole number: ")

try:
    number = int(user_input)
except ValueError:
    print("Please enter a valid whole number.")
else:
    print(f"You entered {number}.")
```

Run it:

```bash
python projects/safe_number.py
```

Valid input:

```text
Enter a whole number: 42
You entered 42.
```

Invalid input:

```text
Enter a whole number: hello
Please enter a valid whole number.
```

The `else` block runs only if the `try` block succeeds.

---

# 8. The `finally` Block

A `finally` block runs whether an exception occurs or not:

```python
try:
    number = int("42")
except ValueError:
    print("Invalid number.")
finally:
    print("The conversion attempt is finished.")
```

Output:

```text
The conversion attempt is finished.
```

If the conversion fails:

```python
try:
    number = int("hello")
except ValueError:
    print("Invalid number.")
finally:
    print("The conversion attempt is finished.")
```

Output:

```text
Invalid number.
The conversion attempt is finished.
```

`finally` is useful for cleanup operations.

When using:

```python
with open(...) as file:
```

Python already manages file cleanup, so you usually do not need `finally` just to close the file.

---

# 9. Handling Multiple Exceptions

A single block may raise different types of exceptions.

```python
try:
    number = int(input("Enter a number: "))
    result = 100 / number
except ValueError:
    print("Please enter a valid integer.")
except ZeroDivisionError:
    print("The number cannot be zero.")
else:
    print(f"Result: {result}")
```

Possible sessions:

```text
Enter a number: hello
Please enter a valid integer.
```

```text
Enter a number: 0
The number cannot be zero.
```

```text
Enter a number: 4
Result: 25.0
```

Each `except` block handles a specific expected problem.

---

# 10. Avoiding Overly Broad Exception Handling

This catches many different exceptions:

```python
try:
    value = int(user_input)
except Exception:
    print("Something went wrong.")
```

Although this may prevent a crash, it can hide programming mistakes.

Prefer specific exceptions:

```python
try:
    value = int(user_input)
except ValueError:
    print("The input is not a valid integer.")
```

Specific exception handling makes failures easier to understand.

---

# 11. Handling Missing Files

Trying to read a file that does not exist raises `FileNotFoundError`.

Create:

```text
projects/read_missing_file.py
```

Add:

```python
from pathlib import Path


file_path = Path("missing.txt")

try:
    contents = file_path.read_text(encoding="utf-8")
except FileNotFoundError:
    print("The file does not exist.")
else:
    print(contents)
```

Run it:

```bash
python projects/read_missing_file.py
```

Expected output:

```text
The file does not exist.
```

A program can use this behavior to start with default data when its storage file has not yet been created.

---

# 12. Handling Invalid JSON

Malformed JSON raises `json.JSONDecodeError`.

Create:

```text
projects/safe_json.py
```

Add:

```python
import json
from pathlib import Path


file_path = Path("tasks.json")

try:
    with file_path.open("r", encoding="utf-8") as file:
        tasks = json.load(file)
except FileNotFoundError:
    print("The task file does not exist.")
    tasks = []
except json.JSONDecodeError:
    print("The task file contains invalid JSON.")
    tasks = []
else:
    print(f"Loaded {len(tasks)} tasks.")
```

Run it from the `projects` directory:

```bash
cd projects
python safe_json.py
```

If `tasks.json` contains valid JSON, you may see:

```text
Loaded 2 tasks.
```

Return to the project root:

```bash
cd ..
```

If the file does not exist:

```text
The task file does not exist.
```

If the file contains malformed JSON:

```text
The task file contains invalid JSON.
```

---

# 13. Testing Invalid JSON

Make a backup copy of `projects/tasks.json` if you want to preserve it.

Then replace its contents with:

```text
This is not valid JSON.
```

Run:

```bash
cd projects
python safe_json.py
```

Expected output:

```text
The task file contains invalid JSON.
```

The program should not display a traceback.

After testing, restore the original file or delete it:

```bash
rm tasks.json
```

On Windows PowerShell:

```powershell
Remove-Item tasks.json
```

Then return to the root:

```bash
cd ..
```

---

# 14. Handling File System Errors

Some file operations can fail for reasons other than missing files.

For example:

- Permission is denied.
- A directory is used where a file is expected.
- A device or disk error occurs.

Many file-related errors inherit from `OSError`.

```python
from pathlib import Path


file_path = Path("example.txt")

try:
    contents = file_path.read_text(encoding="utf-8")
except OSError as error:
    print(f"Could not read the file: {error}")
else:
    print(contents)
```

This handles common operating-system file errors.

For a beginner application, a useful pattern is:

```python
try:
    ...
except OSError as error:
    print(f"File operation failed: {error}")
```

---

# 15. Validating the Shape of Loaded JSON

Valid JSON is not necessarily valid task data.

This JSON is syntactically valid:

```json
{
  "message": "hello"
}
```

But a task manager may expect a list of task dictionaries.

The data should be checked after loading.

```python
import json
from pathlib import Path


file_path = Path("tasks.json")

try:
    with file_path.open("r", encoding="utf-8") as file:
        data = json.load(file)
except FileNotFoundError:
    data = []
except json.JSONDecodeError:
    print("Invalid JSON.")
    data = []
else:
    if not isinstance(data, list):
        print("Expected the JSON file to contain a list.")
        data = []

tasks = data
print(tasks)
```

The `isinstance()` function checks the type of the loaded value.

---

# 16. Validating Individual Tasks

A list may contain values that are not valid task dictionaries:

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  },
  "not a task",
  42
]
```

You can validate each item:

```python
def is_valid_task(value: object) -> bool:
    if not isinstance(value, dict):
        return False

    required_keys = {"id", "title", "completed"}

    if not required_keys.issubset(value):
        return False

    if not isinstance(value["id"], int):
        return False

    if not isinstance(value["title"], str):
        return False

    if not isinstance(value["completed"], bool):
        return False

    return True
```

Use it like this:

```python
data = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
    "not a task",
]

valid_tasks = []

for item in data:
    if is_valid_task(item):
        valid_tasks.append(item)

print(valid_tasks)
```

Output:

```text
[{'id': 1, 'title': 'Learn Python', 'completed': False}]
```

This is defensive programming: the program checks external data before trusting it.

---

# 17. A Storage Module

Application logic should not need to know every detail about file operations.

Create:

```text
projects/task_storage.py
```

Add these complete contents:

```python
import json
from pathlib import Path
from typing import Any


Task = dict[str, Any]


def load_tasks(file_path: Path) -> list[Task]:
    """Load a list of tasks from a JSON file."""
    if not file_path.exists():
        return []

    try:
        with file_path.open("r", encoding="utf-8") as file:
            data = json.load(file)
    except json.JSONDecodeError:
        print(f"Warning: Invalid JSON in {file_path}.")
        return []
    except OSError as error:
        print(f"Warning: Could not read {file_path}: {error}")
        return []

    if not isinstance(data, list):
        print(f"Warning: Expected {file_path} to contain a list.")
        return []

    return data


def save_tasks(file_path: Path, tasks: list[Task]) -> bool:
    """Save tasks to a JSON file.

    Return True when saving succeeds and False otherwise.
    """
    try:
        with file_path.open("w", encoding="utf-8") as file:
            json.dump(tasks, file, indent=2)
    except OSError as error:
        print(f"Could not save {file_path}: {error}")
        return False

    return True
```

This module contains storage operations only.

It does not display menus or ask the user for input.

---

# 18. Using the Storage Module

Create:

```text
projects/use_task_storage.py
```

Add:

```python
from pathlib import Path

from task_storage import load_tasks, save_tasks


def main() -> None:
    file_path = Path("storage_test.json")

    tasks = load_tasks(file_path)

    if not tasks:
        tasks.append(
            {
                "id": 1,
                "title": "Test storage",
                "completed": False,
            }
        )

        save_tasks(file_path, tasks)

    print(tasks)


if __name__ == "__main__":
    main()
```

Run it from `projects`:

```bash
cd projects
python use_task_storage.py
```

Expected output:

```text
[{'id': 1, 'title': 'Test storage', 'completed': False}]
```

A file named `storage_test.json` should now exist.

Run the command again:

```bash
python use_task_storage.py
```

The existing task should be loaded from the file.

Return to the project root:

```bash
cd ..
```

---

# 19. Why Separate Storage?

Without separation, the main program might contain code like this everywhere:

```python
with open("tasks.json", "r", encoding="utf-8") as file:
    tasks = json.load(file)
```

and:

```python
with open("tasks.json", "w", encoding="utf-8") as file:
    json.dump(tasks, file)
```

Putting storage operations in functions makes the rest of the application simpler:

```python
tasks = load_tasks(file_path)
save_tasks(file_path, tasks)
```

This also makes it easier to change storage later.

For example, the application could eventually use:

- A different JSON file.
- A CSV file.
- A database.
- A web API.

The task-management code would need fewer changes if storage is isolated.

---

# 20. Reading User Input Safely with a Function

Create:

```text
projects/input_helpers.py
```

Add:

```python
def read_integer(prompt: str) -> int | None:
    """Read an integer from the user.

    Return None when the input is invalid.
    """
    user_input = input(prompt).strip()

    try:
        return int(user_input)
    except ValueError:
        print("Please enter a valid whole number.")
        return None
```

Create:

```text
projects/use_input_helpers.py
```

Add:

```python
from input_helpers import read_integer


def main() -> None:
    number = read_integer("Enter a number: ")

    if number is not None:
        print(f"You entered {number}.")


if __name__ == "__main__":
    main()
```

Run it from `projects`:

```bash
cd projects
python use_input_helpers.py
```

Test valid input:

```text
Enter a number: 25
You entered 25.
```

Test invalid input:

```text
Enter a number: hello
Please enter a valid whole number.
```

Return to the project root:

```bash
cd ..
```

The input-validation logic is now reusable.

---

# 21. Repeated Input Until Valid

The previous helper returns `None` for invalid input. Another function can keep asking until the user succeeds.

Update `input_helpers.py` to:

```python
def read_integer(prompt: str) -> int:
    """Keep asking until the user enters a valid integer."""
    while True:
        user_input = input(prompt).strip()

        try:
            return int(user_input)
        except ValueError:
            print("Please enter a valid whole number.")
```

Now update `use_input_helpers.py`:

```python
from input_helpers import read_integer


def main() -> None:
    number = read_integer("Enter a number: ")
    print(f"You entered {number}.")


if __name__ == "__main__":
    main()
```

Run it:

```bash
python projects/use_input_helpers.py
```

Example:

```text
Enter a number: abc
Please enter a valid whole number.
Enter a number: 42
You entered 42.
```

This approach guarantees that `read_integer()` returns an integer.

---

# 22. Exception Handling and Program Design

A useful rule is:

> Handle an exception at the point where you can respond meaningfully.

For example, a storage function can handle a missing or corrupted file because it knows how to provide an empty task list:

```python
except FileNotFoundError:
    return []
```

A user-interface function can handle invalid commands because it knows how to display instructions:

```python
except ValueError:
    print("Please enter a valid number.")
```

Do not catch an exception in a function that cannot decide what to do with it.

---

# 23. Verification

Run the following commands:

```bash
python projects/write_json.py
```

```bash
python projects/read_json.py
```

```bash
python projects/safe_number.py
```

```bash
python projects/read_missing_file.py
```

```bash
python projects/safe_json.py
```

```bash
python projects/use_task_storage.py
```

```bash
python projects/use_input_helpers.py
```

Confirm that:

- Python data can be written as JSON.
- JSON can be read back into Python data.
- Invalid numeric input does not crash the program.
- Missing files are handled.
- Invalid JSON is handled.
- Loaded data is checked.
- Storage logic is separated into a module.
- Input validation is reusable.

Your project should now contain files similar to:

```text
projects/
├── write_json.py
├── read_json.py
├── safe_number.py
├── read_missing_file.py
├── safe_json.py
├── task_storage.py
├── use_task_storage.py
├── input_helpers.py
├── use_input_helpers.py
├── tasks.json
└── storage_test.json
```

---

# Part 4C Summary

In this section, you learned:

- JSON represents structured data in a portable text format.
- `json.dump()` writes JSON to a file.
- `json.load()` reads JSON from a file.
- `json.dumps()` creates a JSON string.
- `json.loads()` reads JSON from a string.
- `try` and `except` handle expected exceptions.
- `FileNotFoundError` represents a missing file.
- `JSONDecodeError` represents malformed JSON.
- `ValueError` commonly occurs when converting invalid text to a number.
- Valid JSON still needs application-level validation.
- Storage functions should be separate from user-interface code.
- Reusable input functions can keep the main program cleaner.

The next section is:

# Part 4D: Building the Persistent Task Manager

It will combine:

- Functions.
- Modules.
- `pathlib`.
- JSON storage.
- Exception handling.
- Input validation.
- A persistent command-line task manager.

---

# Part 4D: Building the Persistent Task Manager

This is **Section 4 of 4** in Part 4.

In the previous sections, you learned:

- Functions.
- Type hints.
- Modules.
- Text files.
- `pathlib`.
- JSON.
- Exception handling.
- Input validation.
- Separating storage code from application code.

Now we will combine those ideas into a persistent task manager.

The program will:

- Load tasks from a JSON file.
- Save tasks after changes.
- Add tasks.
- List tasks.
- Complete tasks.
- Remove tasks.
- Validate user input.
- Handle missing and malformed files.
- Separate storage and application behavior.

---

# 1. The Final Part 4 Structure

Create this directory:

```text
projects/
└── persistent_tasks/
```

Inside it, we will create:

```text
persistent_tasks/
├── task_storage.py
└── task_manager.py
```

The program will eventually create:

```text
persistent_tasks/
└── tasks.json
```

The responsibilities will be divided like this:

| File | Responsibility |
|---|---|
| `task_storage.py` | Loading and saving JSON |
| `task_manager.py` | Menus, task operations, and user interaction |
| `tasks.json` | Persistent task data |

This is a small application, but it already uses separation of responsibilities.

---

# 2. Creating the Project Directory

From the project root, create the directory.

### Windows PowerShell

```powershell
mkdir projects\persistent_tasks
```

### macOS or Linux

```bash
mkdir -p projects/persistent_tasks
```

Your project should now contain:

```text
python-foundations/
└── projects/
    └── persistent_tasks/
```

---

# 3. Creating the Storage Module

Create:

```text
projects/persistent_tasks/task_storage.py
```

Add these complete contents:

```python
import json
from pathlib import Path
from typing import Any


Task = dict[str, Any]


def load_tasks(file_path: Path) -> list[Task]:
    """Load tasks from a JSON file.

    Return an empty list when the file does not exist,
    contains invalid JSON, or contains the wrong data shape.
    """
    if not file_path.exists():
        return []

    try:
        with file_path.open("r", encoding="utf-8") as file:
            data = json.load(file)
    except json.JSONDecodeError:
        print(f"Warning: Invalid JSON in {file_path}.")
        return []
    except OSError as error:
        print(f"Warning: Could not read {file_path}: {error}")
        return []

    if not isinstance(data, list):
        print(f"Warning: Expected {file_path} to contain a list.")
        return []

    valid_tasks: list[Task] = []

    for item in data:
        if is_valid_task(item):
            valid_tasks.append(item)

    return valid_tasks


def save_tasks(file_path: Path, tasks: list[Task]) -> bool:
    """Save tasks to a JSON file.

    Return True when saving succeeds and False otherwise.
    """
    try:
        file_path.parent.mkdir(parents=True, exist_ok=True)

        with file_path.open("w", encoding="utf-8") as file:
            json.dump(tasks, file, indent=2)

    except OSError as error:
        print(f"Could not save {file_path}: {error}")
        return False

    return True


def is_valid_task(value: object) -> bool:
    """Return True when value has the expected task structure."""
    if not isinstance(value, dict):
        return False

    required_keys = {"id", "title", "completed"}

    if not required_keys.issubset(value):
        return False

    if not isinstance(value["id"], int):
        return False

    if not isinstance(value["title"], str):
        return False

    if not isinstance(value["completed"], bool):
        return False

    return True
```

---

# 4. Understanding the Storage Module

## The Type Alias

```python
Task = dict[str, Any]
```

This gives a shorter name to the general task dictionary type.

A task might look like:

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

---

## The `load_tasks()` Function

```python
def load_tasks(file_path: Path) -> list[Task]:
```

This function accepts a path and returns a list of tasks.

If the file does not exist:

```python
if not file_path.exists():
    return []
```

the function starts with an empty task list.

If the JSON is malformed:

```python
except json.JSONDecodeError:
```

the function displays a warning and returns an empty list.

If a file-system error occurs:

```python
except OSError as error:
```

the function reports the error and returns an empty list.

---

## The `save_tasks()` Function

```python
def save_tasks(file_path: Path, tasks: list[Task]) -> bool:
```

This function writes tasks to the JSON file.

This line ensures the parent directory exists:

```python
file_path.parent.mkdir(parents=True, exist_ok=True)
```

The function returns:

```python
True
```

when saving succeeds and:

```python
False
```

when saving fails.

---

## The `is_valid_task()` Function

Valid JSON is not necessarily valid task data.

This is valid JSON:

```json
{
  "message": "hello"
}
```

But it is not a valid task.

The validation function checks that:

- The value is a dictionary.
- Required keys exist.
- The ID is an integer.
- The title is a string.
- The completed field is a Boolean.

---

# 5. Testing the Storage Module

Create:

```text
projects/persistent_tasks/test_storage_module.py
```

Add:

```python
from pathlib import Path

from task_storage import load_tasks, save_tasks


def main() -> None:
    file_path = Path("storage_test.json")

    tasks = [
        {
            "id": 1,
            "title": "Test storage",
            "completed": False,
        }
    ]

    saved = save_tasks(file_path, tasks)

    if saved:
        print("Tasks saved successfully.")

    loaded_tasks = load_tasks(file_path)

    print("Loaded tasks:")
    print(loaded_tasks)


if __name__ == "__main__":
    main()
```

Run it from the `persistent_tasks` directory:

```bash
cd projects/persistent_tasks
python test_storage_module.py
```

Expected output:

```text
Tasks saved successfully.
Loaded tasks:
[{'id': 1, 'title': 'Test storage', 'completed': False}]
```

The test should create:

```text
projects/persistent_tasks/storage_test.json
```

After testing, you may delete that file.

### Windows PowerShell

```powershell
Remove-Item storage_test.json
```

### macOS or Linux

```bash
rm storage_test.json
```

Return to the project root:

```bash
cd ../..
```

---

# 6. Creating the Task Manager

Create:

```text
projects/persistent_tasks/task_manager.py
```

Add these complete contents:

```python
from pathlib import Path
from typing import Any

from task_storage import load_tasks, save_tasks


Task = dict[str, Any]
DATA_FILE = Path(__file__).parent / "tasks.json"


def display_task(task: Task) -> None:
    """Display one task."""
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")


def list_tasks(tasks: list[Task]) -> None:
    """Display all tasks."""
    if not tasks:
        print("No tasks found.")
        return

    print()
    print("Tasks:")

    for task in tasks:
        display_task(task)


def get_next_id(tasks: list[Task]) -> int:
    """Return an unused task ID."""
    if not tasks:
        return 1

    return max(task["id"] for task in tasks) + 1


def find_task(tasks: list[Task], task_id: int) -> Task | None:
    """Find and return a task by ID."""
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


def read_task_id(prompt: str) -> int | None:
    """Read a whole-number task ID."""
    task_id_text = input(prompt).strip()

    try:
        task_id = int(task_id_text)
    except ValueError:
        print("Task ID must be a whole number.")
        return None

    if task_id < 1:
        print("Task ID must be greater than zero.")
        return None

    return task_id


def add_task(tasks: list[Task]) -> None:
    """Create and save a new task."""
    title = input("Enter a task title: ").strip()

    if not title:
        print("Task title cannot be empty.")
        return

    task = {
        "id": get_next_id(tasks),
        "title": title,
        "completed": False,
    }

    tasks.append(task)

    if save_tasks(DATA_FILE, tasks):
        print(f"Task {task['id']} created.")


def complete_task(tasks: list[Task]) -> None:
    """Mark a task as completed."""
    task_id = read_task_id("Enter the task ID to complete: ")

    if task_id is None:
        return

    task = find_task(tasks, task_id)

    if task is None:
        print(f"No task found with ID {task_id}.")
        return

    if task["completed"]:
        print(f"Task {task_id} is already completed.")
        return

    task["completed"] = True

    if save_tasks(DATA_FILE, tasks):
        print(f"Task {task_id} completed.")


def remove_task(tasks: list[Task]) -> None:
    """Remove a task."""
    task_id = read_task_id("Enter the task ID to remove: ")

    if task_id is None:
        return

    task = find_task(tasks, task_id)

    if task is None:
        print(f"No task found with ID {task_id}.")
        return

    tasks.remove(task)

    if save_tasks(DATA_FILE, tasks):
        print(f"Task {task_id} removed.")


def show_statistics(tasks: list[Task]) -> None:
    """Display task counts."""
    completed_count = sum(
        1 for task in tasks if task["completed"]
    )

    total_count = len(tasks)
    incomplete_count = total_count - completed_count

    print()
    print(f"Total tasks: {total_count}")
    print(f"Completed tasks: {completed_count}")
    print(f"Incomplete tasks: {incomplete_count}")


def show_menu() -> None:
    """Display the main menu."""
    print()
    print("Task Manager")
    print("------------")
    print("1. List tasks")
    print("2. Add task")
    print("3. Complete task")
    print("4. Remove task")
    print("5. Show statistics")
    print("6. Quit")


def main() -> None:
    """Run the task manager."""
    tasks = load_tasks(DATA_FILE)

    while True:
        show_menu()
        choice = input("Choose an option: ").strip()

        if choice == "1":
            list_tasks(tasks)
        elif choice == "2":
            add_task(tasks)
        elif choice == "3":
            complete_task(tasks)
        elif choice == "4":
            remove_task(tasks)
        elif choice == "5":
            show_statistics(tasks)
        elif choice == "6":
            print("Goodbye.")
            break
        else:
            print("Please choose a number from 1 to 6.")


if __name__ == "__main__":
    main()
```

---

# 7. Running the Task Manager

From the project root, run:

```bash
python projects/persistent_tasks/task_manager.py
```

You should see:

```text
Task Manager
------------
1. List tasks
2. Add task
3. Complete task
4. Remove task
5. Show statistics
6. Quit
Choose an option:
```

The first time you run the program, the task file may not exist. The program will start with an empty list.

Choose:

```text
1
```

Expected output:

```text
No tasks found.
```

---

# 8. Adding a Task

Choose:

```text
2
```

Enter:

```text
Learn persistent storage
```

Expected output:

```text
Task 1 created.
```

A file should now exist at:

```text
projects/persistent_tasks/tasks.json
```

Its contents should resemble:

```json
[
  {
    "id": 1,
    "title": "Learn persistent storage",
    "completed": false
  }
]
```

Add another task:

```text
Choose an option: 2
Enter a task title: Practice JSON
Task 2 created.
```

The file should now contain two tasks.

---

# 9. Listing Tasks

Choose:

```text
1
```

Expected output:

```text
Tasks:
[ ] 1 - Learn persistent storage
[ ] 2 - Practice JSON
```

The `[ ]` marker means incomplete.

After completion, the program will display `[x]`.

---

# 10. Completing a Task

Choose:

```text
3
```

Enter:

```text
1
```

Expected output:

```text
Task 1 completed.
```

List the tasks again:

```text
Choose an option: 1

Tasks:
[x] 1 - Learn persistent storage
[ ] 2 - Practice JSON
```

Try completing task `1` again:

```text
Choose an option: 3
Enter the task ID to complete: 1
Task 1 is already completed.
```

---

# 11. Removing a Task

Choose:

```text
4
```

Enter:

```text
2
```

Expected output:

```text
Task 2 removed.
```

List the tasks:

```text
Choose an option: 1

Tasks:
[x] 1 - Learn persistent storage
```

The task has been removed from the list and from the JSON file.

---

# 12. Displaying Statistics

Choose:

```text
5
```

Expected output:

```text
Total tasks: 1
Completed tasks: 1
Incomplete tasks: 0
```

If the task list is empty, the output will be:

```text
Total tasks: 0
Completed tasks: 0
Incomplete tasks: 0
```

---

# 13. Testing Invalid Input

## Invalid Menu Choice

At the menu, enter:

```text
hello
```

Expected output:

```text
Please choose a number from 1 to 6.
```

The program should continue running.

---

## Empty Task Title

Choose:

```text
2
```

Then enter only spaces:

```text
     
```

Expected output:

```text
Task title cannot be empty.
```

---

## Invalid Task ID

Choose:

```text
3
```

Enter:

```text
abc
```

Expected output:

```text
Task ID must be a whole number.
```

---

## Negative Task ID

Choose:

```text
4
```

Enter:

```text
-1
```

Expected output:

```text
Task ID must be greater than zero.
```

---

## Missing Task

Choose:

```text
3
```

Enter:

```text
999
```

Expected output:

```text
No task found with ID 999.
```

---

# 14. Testing Persistence

Quit the program:

```text
Choose an option: 6
Goodbye.
```

Start it again:

```bash
python projects/persistent_tasks/task_manager.py
```

Choose:

```text
1
```

The tasks should still be present.

This proves that the program is saving and loading JSON successfully.

---

# 15. Understanding the Data File Path

This line defines the location of the JSON file:

```python
DATA_FILE = Path(__file__).parent / "tasks.json"
```

`__file__` refers to the current Python file:

```text
task_manager.py
```

`Path(__file__).parent` refers to the directory containing that file:

```text
projects/persistent_tasks/
```

The `/ "tasks.json"` part adds the filename.

Therefore, the final path is:

```text
projects/persistent_tasks/tasks.json
```

This is more reliable than simply writing:

```python
DATA_FILE = Path("tasks.json")
```

because the latter depends on the current working directory.

---

# 16. Understanding `get_next_id()`

The function is:

```python
def get_next_id(tasks: list[Task]) -> int:
    if not tasks:
        return 1

    return max(task["id"] for task in tasks) + 1
```

If there are no tasks, it returns:

```text
1
```

If the existing IDs are:

```text
1, 2, 5
```

the largest ID is:

```text
5
```

The next ID becomes:

```text
6
```

This avoids reusing IDs that may already have belonged to deleted tasks.

---

# 17. Understanding `show_statistics()`

This expression counts completed tasks:

```python
completed_count = sum(
    1 for task in tasks if task["completed"]
)
```

It means:

> Add one for every task whose `completed` value is true.

For example:

```python
tasks = [
    {"completed": True},
    {"completed": False},
    {"completed": True},
]
```

The result is:

```text
2
```

The total count is:

```python
total_count = len(tasks)
```

The incomplete count is calculated by subtraction:

```python
incomplete_count = total_count - completed_count
```

---

# 18. Improving Save Failure Behavior

The current functions modify the in-memory task list before saving.

For example:

```python
tasks.append(task)

if save_tasks(DATA_FILE, tasks):
    print(f"Task {task['id']} created.")
```

If saving fails, the task remains in memory for the current run, even though it was not written to disk.

For a beginner application, this is acceptable, but a more careful approach could restore the previous state or report the failure more prominently.

For example:

```python
if save_tasks(DATA_FILE, tasks):
    print(f"Task {task['id']} created.")
else:
    tasks.remove(task)
    print("The task was not saved.")
```

This removes the task from memory if saving fails.

For the current project, the simpler version is sufficient.

---

# 19. Handling a Corrupted Data File

To test error handling, stop the program and open:

```text
projects/persistent_tasks/tasks.json
```

Replace its contents with:

```text
This is not valid JSON.
```

Run the task manager:

```bash
python projects/persistent_tasks/task_manager.py
```

Expected output:

```text
Warning: Invalid JSON in .../tasks.json.
```

The program should still start.

Choose:

```text
1
```

Expected output:

```text
No tasks found.
```

The corrupted file has not been automatically overwritten. To start fresh, delete it.

### Windows PowerShell

```powershell
Remove-Item projects\persistent_tasks\tasks.json
```

### macOS or Linux

```bash
rm projects/persistent_tasks/tasks.json
```

Run the program again and create new tasks.

---

# 20. Final Part 4 Project Structure

After completing this section, your relevant project structure should look like:

```text
python-foundations/
├── .venv/
├── hello.py
├── variables.py
├── type_error_example.py
└── projects/
    ├── functions_intro.py
    ├── greetings.py
    ├── task_functions.py
    ├── main_pattern.py
    ├── calculations.py
    ├── use_calculations.py
    ├── write_text.py
    ├── read_text.py
    ├── pathlib_example.py
    ├── notes.py
    ├── write_json.py
    ├── read_json.py
    ├── safe_number.py
    ├── safe_json.py
    ├── task_storage.py
    ├── input_helpers.py
    └── persistent_tasks/
        ├── task_storage.py
        ├── task_manager.py
        └── tasks.json
```

You may have some additional practice files. That is fine.

---

# 21. Final Verification Checklist

Confirm that you can:

- [ ] Define functions.
- [ ] Pass arguments to functions.
- [ ] Return values.
- [ ] Use default parameters.
- [ ] Add type hints.
- [ ] Explain local scope.
- [ ] Use the `main()` pattern.
- [ ] Import functions from another module.
- [ ] Read and write text files.
- [ ] Append to text files.
- [ ] Use `pathlib.Path`.
- [ ] Create directories.
- [ ] Build paths with `/`.
- [ ] Write JSON with `json.dump()`.
- [ ] Read JSON with `json.load()`.
- [ ] Handle `ValueError`.
- [ ] Handle missing files.
- [ ] Handle malformed JSON.
- [ ] Validate loaded data.
- [ ] Add tasks.
- [ ] List tasks.
- [ ] Complete tasks.
- [ ] Remove tasks.
- [ ] Display task statistics.
- [ ] Preserve tasks between program runs.
- [ ] Respond safely to invalid input.

---

# Part 4 Complete

You have now completed all four sections of Part 4:

```text
Part 4A: Functions and reusable code
Part 4B: Modules, text files, and pathlib
Part 4C: JSON, exceptions, and safe file handling
Part 4D: Persistent task manager
```

The application now has the essential behavior of a small real program:

```text
User input
    ↓
Validation
    ↓
Application logic
    ↓
JSON storage
    ↓
Displayed result
```

The task manager currently runs as a menu-based script:

```bash
python projects/persistent_tasks/task_manager.py
```

In the capstone project, we will reorganize this into a proper command-line application with commands such as:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
```

We will also add a file-organizer utility and create a clearer project structure with separate application, storage, command-line, and testing layers.
