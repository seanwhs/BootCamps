# Appendix D: Common Python Errors and Fixes

This appendix explains common Python errors, why they occur, and how to fix them.

Error messages are not random obstacles. They are reports from Python describing what went wrong and where it happened.

This appendix is divided into three parts:

1. **Part 1:** Syntax, indentation, name, and type errors.
2. **Part 2:** Value, index, key, file, module, and JSON errors.
3. **Part 3:** Debugging strategies and error-prevention practices.

---

# Part 1: Syntax, Indentation, Name, and Type Errors

## 1. How to Read a Python Error

Consider this program:

```python
name = "Ada"

print(age)
```

Python may display:

```text
Traceback (most recent call last):
  File "example.py", line 3, in <module>
    print(age)
NameError: name 'age' is not defined
```

Read the traceback from the bottom upward.

The final line usually contains the most important information:

```text
NameError: name 'age' is not defined
```

The earlier lines identify where the problem occurred:

```text
File "example.py", line 3
```

The problematic code is:

```python
print(age)
```

Use this process:

1. Read the final error type.
2. Read the error message.
3. Find the file and line number.
4. Inspect the surrounding code.
5. Check the values and their types.
6. Make one focused correction.
7. Run the program again.

---

# 2. `SyntaxError`

A `SyntaxError` means Python cannot understand the structure of your code.

## Missing Parenthesis

Incorrect:

```python
print("Hello"
```

Possible error:

```text
SyntaxError: '(' was never closed
```

Correct:

```python
print("Hello")
```

---

## Missing Colon

Incorrect:

```python
if age >= 18
    print("Adult")
```

Correct:

```python
if age >= 18:
    print("Adult")
```

A colon is required after statements such as:

```python
if condition:
for item in items:
while condition:
def function_name():
class ClassName:
try:
except SomeError:
```

---

## Assignment Instead of Comparison

Incorrect:

```python
if age = 18:
    print("Age is 18.")
```

Correct:

```python
if age == 18:
    print("Age is 18.")
```

Use:

```python
=
```

for assignment:

```python
age = 18
```

Use:

```python
==
```

for comparison:

```python
age == 18
```

---

## Incorrect String Quotation

Incorrect:

```python
message = "Hello
```

Correct:

```python
message = "Hello"
```

If a string contains double quotation marks, use single quotation marks around it:

```python
message = 'She said "Hello".'
```

If a string contains an apostrophe, use double quotation marks:

```python
message = "Ada's program"
```

You can also escape a quotation mark:

```python
message = "She said \"Hello\"."
```

---

## Invalid Variable Names

Incorrect:

```python
2_users = 10
```

A variable name cannot begin with a number.

Correct:

```python
user_count = 10
```

Incorrect:

```python
user-name = "Ada"
```

Python interprets `-` as subtraction.

Correct:

```python
user_name = "Ada"
```

---

# 3. `IndentationError`

Python uses indentation to define blocks.

## Missing Indentation

Incorrect:

```python
if True:
print("This should be indented.")
```

Possible error:

```text
IndentationError: expected an indented block
```

Correct:

```python
if True:
    print("This should be indented.")
```

---

## Unexpected Indentation

Incorrect:

```python
name = "Ada"
    print(name)
```

Possible error:

```text
IndentationError: unexpected indent
```

Correct:

```python
name = "Ada"
print(name)
```

Do not indent code unless it belongs to a block.

---

## Inconsistent Indentation

Incorrect:

```python
if True:
    print("First line")
  print("Second line")
```

The two lines use different indentation levels.

Correct:

```python
if True:
    print("First line")
    print("Second line")
```

Use four spaces for each indentation level.

Avoid mixing tabs and spaces.

---

## Incorrect Nested Indentation

Incorrect:

```python
if logged_in:
    print("Logged in.")
      if is_admin:
          print("Admin.")
```

Correct:

```python
if logged_in:
    print("Logged in.")

    if is_admin:
        print("Admin.")
```

Each nested block should be indented consistently.

---

# 4. `NameError`

A `NameError` occurs when Python cannot find a variable, function, or other name.

## Undefined Variable

```python
print(username)
```

If `username` was never created, Python may display:

```text
NameError: name 'username' is not defined
```

Correct:

```python
username = "Ada"

print(username)
```

---

## Misspelled Variable Names

```python
user_name = "Ada"

print(username)
```

These are different names:

```text
user_name
username
```

Correct:

```python
user_name = "Ada"

print(user_name)
```

---

## Incorrect Capitalization

Python is case-sensitive:

```python
name = "Ada"
Name = "Grace"
```

These are separate variables.

This may fail:

```python
name = "Ada"

print(Name)
```

Use consistent capitalization:

```python
name = "Ada"

print(name)
```

---

## Undefined Function

```python
greet_user("Ada")
```

If the function has not been defined, Python raises a `NameError`.

Correct:

```python
def greet_user(name):
    print(f"Hello, {name}!")


greet_user("Ada")
```

---

## Scope-Related `NameError`

A variable created inside a function is local to that function:

```python
def create_message():
    message = "Hello"


create_message()
print(message)
```

The variable `message` does not exist outside the function.

Return the value instead:

```python
def create_message():
    return "Hello"


message = create_message()
print(message)
```

Output:

```text
Hello
```

---

# 5. `TypeError`

A `TypeError` occurs when an operation is used with an inappropriate type.

## Combining a String and Integer

Incorrect:

```python
age = 36

print("Age: " + age)
```

Possible error:

```text
TypeError: can only concatenate str (not "int") to str
```

Correct with `str()`:

```python
print("Age: " + str(age))
```

Better with an f-string:

```python
print(f"Age: {age}")
```

---

## Adding Incompatible Values

Incorrect:

```python
result = "10" + 5
```

Correct by converting the string:

```python
result = int("10") + 5

print(result)
```

Output:

```text
15
```

---

## Calling a Non-Callable Value

Incorrect:

```python
message = "Hello"

message()
```

A string is not a function and cannot be called with parentheses.

Correct:

```python
print(message)
```

---

## Wrong Number of Function Arguments

```python
def greet(name):
    print(f"Hello, {name}!")


greet()
```

Possible error:

```text
TypeError: greet() missing 1 required positional argument
```

Correct:

```python
greet("Ada")
```

Providing too many arguments also causes a `TypeError`:

```python
greet("Ada", "Grace")
```

The function accepts one argument but receives two.

---

## Indexing an Integer

Incorrect:

```python
number = 42

print(number[0])
```

Integers cannot be indexed.

Correct:

```python
text = "42"

print(text[0])
```

Output:

```text
4
```

---

# 6. `AttributeError`

An `AttributeError` occurs when an object does not have the requested attribute or method.

## Misspelled Method

Incorrect:

```python
name = "Ada"

print(name.uppercase())
```

Strings have `.upper()`, not `.uppercase()`.

Correct:

```python
print(name.upper())
```

---

## Using a List Method on a String

Incorrect:

```python
name = "Ada"

name.append("Lovelace")
```

Strings do not have an `append()` method.

Correct:

```python
names = ["Ada"]

names.append("Grace")
```

---

## Calling a Method on `None`

```python
task = None

print(task.get("title"))
```

This raises an `AttributeError` because `None` does not have a `.get()` method.

Check first:

```python
if task is not None:
    print(task.get("title"))
```

---

# 7. `UnboundLocalError`

An `UnboundLocalError` can occur when a function uses a local variable before assigning it.

Incorrect:

```python
count = 10


def increase_count():
    print(count)
    count += 1


increase_count()
```

Because the function assigns to `count`, Python treats `count` as a local variable throughout the function. The `print()` statement tries to use it before it has a local value.

A clearer solution is to pass the value and return the result:

```python
def increase_count(count):
    return count + 1


count = 10
count = increase_count(count)

print(count)
```

Output:

```text
11
```

Passing values explicitly is usually better than modifying global variables.

---

# 8. `ImportError`

An `ImportError` occurs when Python finds a module but cannot import the requested name.

Suppose `calculations.py` contains:

```python
def add(first, second):
    return first + second
```

This import is incorrect:

```python
from calculations import multiply
```

Python may report:

```text
ImportError: cannot import name 'multiply'
```

Correct:

```python
from calculations import add
```

---

## Importing the Wrong Module Name

Suppose the file is named:

```text
calculations.py
```

This is incorrect:

```python
import calculation
```

Correct:

```python
import calculations
```

The module name must match the filename.

Avoid naming your own files after standard-library modules, such as:

```text
json.py
pathlib.py
typing.py
```

These filenames can interfere with imports.

Prefer names such as:

```text
json_examples.py
path_examples.py
type_examples.py
```

---

# Part 1 Summary

This section covered:

- `SyntaxError`
- `IndentationError`
- `NameError`
- `TypeError`
- `AttributeError`
- `UnboundLocalError`
- `ImportError`

The most important debugging process is:

```text
Read the final line.
Find the file and line number.
Inspect the values involved.
Check the types.
Make one focused change.
Run the program again.
```

---

# Appendix D, Part 2 of 3: Value, Index, Key, File, Module, and JSON Errors

This section covers errors that commonly occur when working with:

- User input.
- Lists and tuples.
- Dictionaries.
- Files and directories.
- Imports.
- JSON data.

---

# 1. `ValueError`

A `ValueError` occurs when a value has the correct general type but an inappropriate content.

## Invalid Integer Conversion

```python
age = int("tomorrow")
```

Possible error:

```text
ValueError: invalid literal for int() with base 10
```

The input is a string, but it does not represent a valid integer.

Handle it with `try` and `except`:

```python
age_text = input("Enter your age: ")

try:
    age = int(age_text)
except ValueError:
    print("Please enter a whole number.")
else:
    print(f"Your age is {age}.")
```

---

## Invalid Float Conversion

```python
price = float("free")
```

This also raises a `ValueError`.

Safe version:

```python
price_text = input("Enter the price: ")

try:
    price = float(price_text)
except ValueError:
    print("Please enter a valid price.")
else:
    print(f"Price: ${price:.2f}")
```

---

## Value Outside an Allowed Range

A value may be numeric but still invalid for the application:

```python
age = 250
```

A range check can reject it:

```python
if age < 0 or age > 120:
    print("Please enter an age between 0 and 120.")
```

---

## Invalid List Removal

```python
tasks = ["Learn Python"]

tasks.remove("Practice loops")
```

Possible error:

```text
ValueError: list.remove(x): x not in list
```

Check before removing:

```python
if "Practice loops" in tasks:
    tasks.remove("Practice loops")
else:
    print("Task not found.")
```

---

# 2. `IndexError`

An `IndexError` occurs when you access a list or tuple position that does not exist.

```python
tasks = [
    "Learn Python",
    "Practice loops",
]

print(tasks[2])
```

The valid indexes are:

```text
0
1
```

Possible error:

```text
IndexError: list index out of range
```

---

## Checking the Length First

```python
if len(tasks) > 2:
    print(tasks[2])
else:
    print("There is no third task.")
```

---

## Avoiding Hard-Coded Indexes

Instead of assuming an item exists at a position:

```python
print(tasks[0])
```

you can check whether the collection contains anything:

```python
if tasks:
    print(tasks[0])
else:
    print("No tasks available.")
```

---

## Safe Access with a Loop

If you need to process every available item, use a loop:

```python
for task in tasks:
    print(task)
```

The loop does not attempt to access an invalid index.

---

## Negative Index Errors

This is valid when the list has at least one item:

```python
tasks[-1]
```

But this fails for an empty list:

```python
tasks = []

print(tasks[-1])
```

Check first:

```python
if tasks:
    print(tasks[-1])
```

---

# 3. `KeyError`

A `KeyError` occurs when you access a dictionary key that does not exist.

```python
task = {
    "title": "Learn Python",
}

print(task["priority"])
```

Possible error:

```text
KeyError: 'priority'
```

---

## Using `get()`

Use `.get()` when a key may be missing:

```python
priority = task.get("priority")
```

If the key is absent, the result is:

```python
None
```

Provide a default:

```python
priority = task.get("priority", "normal")

print(priority)
```

Output:

```text
normal
```

---

## Checking Before Accessing

```python
if "priority" in task:
    print(task["priority"])
else:
    print("No priority assigned.")
```

---

## Using `try` and `except`

```python
try:
    priority = task["priority"]
except KeyError:
    print("No priority assigned.")
```

For simple optional fields, `.get()` is usually clearer.

---

# 4. `FileNotFoundError`

A `FileNotFoundError` occurs when a program tries to open a file that does not exist.

```python
from pathlib import Path


file_path = Path("missing.txt")

contents = file_path.read_text(encoding="utf-8")
```

Possible error:

```text
FileNotFoundError
```

---

## Checking Before Reading

```python
from pathlib import Path


file_path = Path("missing.txt")

if file_path.exists():
    contents = file_path.read_text(encoding="utf-8")
    print(contents)
else:
    print("The file does not exist.")
```

---

## Handling the Exception

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

---

## Starting with Default Data

A task manager can treat a missing data file as an empty task list:

```python
def load_tasks(file_path):
    if not file_path.exists():
        return []

    return read_tasks_from_file(file_path)
```

This is useful when the program is being run for the first time.

---

# 5. `NotADirectoryError`

A `NotADirectoryError` occurs when a program expects a directory but receives a file path.

For example:

```python
from pathlib import Path


file_path = Path("notes.txt")

for item in file_path.iterdir():
    print(item)
```

If `notes.txt` is a file, it cannot be searched as a directory.

Check first:

```python
if not file_path.is_dir():
    print("The path is not a directory.")
else:
    for item in file_path.iterdir():
        print(item)
```

The capstone organizer uses this kind of validation before processing a path.

---

# 6. `PermissionError`

A `PermissionError` occurs when the operating system refuses access to a file or directory.

Possible causes include:

- The file is read-only.
- The current user lacks permission.
- Another application has locked the file.
- The directory requires administrator access.

Handle it explicitly when appropriate:

```python
from pathlib import Path


file_path = Path("protected.txt")

try:
    contents = file_path.read_text(encoding="utf-8")
except PermissionError:
    print("You do not have permission to read this file.")
```

For general file-operation handling:

```python
except OSError as error:
    print(f"File operation failed: {error}")
```

`PermissionError` is a type of `OSError`.

---

# 7. `IsADirectoryError`

An `IsADirectoryError` occurs when a program tries to use a directory as if it were a file.

For example:

```python
from pathlib import Path


directory = Path("data")

contents = directory.read_text(encoding="utf-8")
```

Check the path first:

```python
if directory.is_file():
    contents = directory.read_text(encoding="utf-8")
else:
    print("The path is not a file.")
```

---

# 8. `OSError`

`OSError` represents many operating-system-related failures.

Examples include:

- Permission problems.
- Invalid paths.
- Device errors.
- File-system failures.

A general handler:

```python
from pathlib import Path


file_path = Path("data/tasks.json")

try:
    file_path.write_text("[]", encoding="utf-8")
except OSError as error:
    print(f"Could not write the file: {error}")
```

Use specific exceptions when you need a specific response:

```python
try:
    ...
except FileNotFoundError:
    ...
except PermissionError:
    ...
except OSError:
    ...
```

More specific handlers should appear before broader handlers.

---

# 9. `ModuleNotFoundError`

A `ModuleNotFoundError` occurs when Python cannot find a module being imported.

```python
import imaginary_module
```

Possible error:

```text
ModuleNotFoundError: No module named 'imaginary_module'
```

Common causes:

- The module name is misspelled.
- The package is not installed.
- The virtual environment is not active.
- The command is being run from the wrong directory.
- The source layout has not been installed.

---

## Checking the Active Interpreter

Run:

```bash
python -c "import sys; print(sys.executable)"
```

The path should point to the expected Python environment.

---

## Installing the Project

From the project root:

```bash
python -m pip install --editable .
```

Then test:

```bash
python -m foundation_cli --help
```

---

## Checking an Installed Package

```bash
python -m pip show foundation-cli
```

If the package is not listed, install it:

```bash
python -m pip install --editable .
```

---

# 10. `JSONDecodeError`

A `JSONDecodeError` occurs when Python tries to read invalid JSON.

Invalid JSON:

```text
This is not JSON.
```

Another invalid example:

```json
{
  "title": "Learn Python",
}
```

The trailing comma is not valid in standard JSON.

---

## Handling Invalid JSON

```python
import json
from pathlib import Path


file_path = Path("tasks.json")

try:
    with file_path.open("r", encoding="utf-8") as file:
        data = json.load(file)
except FileNotFoundError:
    print("The file does not exist.")
    data = []
except json.JSONDecodeError:
    print("The file contains invalid JSON.")
    data = []
```

---

## Inspecting JSON with Python

You can check a JSON file from the terminal:

```bash
python -m json.tool data/tasks.json
```

If the file is valid, Python displays formatted JSON.

If invalid, it reports the approximate line and column where the problem occurred.

---

# 11. Valid JSON with the Wrong Structure

A file can contain valid JSON but still have the wrong shape.

This is valid JSON:

```json
{
  "message": "Hello"
}
```

But a task manager may expect a list:

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  }
]
```

Validate the loaded value:

```python
data = json.load(file)

if not isinstance(data, list):
    raise ValueError("Expected a list of tasks.")
```

Validate individual tasks:

```python
for task in data:
    if not isinstance(task, dict):
        raise ValueError("Each task must be an object.")
```

---

# 12. `UnicodeDecodeError`

A `UnicodeDecodeError` can occur when a file is read using an incompatible text encoding.

Use UTF-8 explicitly for normal text files:

```python
from pathlib import Path


contents = Path("notes.txt").read_text(
    encoding="utf-8",
)
```

When using `open()`:

```python
with open(
    "notes.txt",
    "r",
    encoding="utf-8",
) as file:
    contents = file.read()
```

If a file was created using another encoding, you may need to identify and use that encoding.

---

# 13. `RecursionError`

A `RecursionError` occurs when a function calls itself too many times without stopping.

Incorrect:

```python
def count_forever():
    count_forever()


count_forever()
```

The function never reaches a stopping condition.

A recursive function needs a base case:

```python
def countdown(number):
    if number <= 0:
        return

    print(number)
    countdown(number - 1)


countdown(3)
```

Output:

```text
3
2
1
```

For beginner programs, loops are often easier to understand than recursion.

---

# 14. `ZeroDivisionError`

This occurs when a program divides by zero:

```python
result = 10 / 0
```

Handle it:

```python
try:
    number = int(input("Enter a divisor: "))
    result = 100 / number
except ValueError:
    print("Please enter an integer.")
except ZeroDivisionError:
    print("The divisor cannot be zero.")
else:
    print(result)
```

Validate before performing the operation when possible:

```python
if number == 0:
    print("Cannot divide by zero.")
else:
    result = 100 / number
```

---

# 15. `OverflowError`

An `OverflowError` can occur when a numeric operation produces a value too large for the operation.

For example, some floating-point operations may exceed the supported range.

Use reasonable input limits:

```python
if number > 1_000_000:
    print("Number is too large.")
```

For very large integers, Python integers can usually grow substantially, but memory and processing limits still apply.

---

# 16. Common Error Reference Table

| Error | Typical cause |
|---|---|
| `SyntaxError` | Invalid Python structure |
| `IndentationError` | Incorrect indentation |
| `NameError` | Undefined or misspelled name |
| `TypeError` | Incompatible type operation |
| `ValueError` | Correct type, invalid value |
| `AttributeError` | Missing method or attribute |
| `IndexError` | Invalid list or tuple index |
| `KeyError` | Missing dictionary key |
| `FileNotFoundError` | Missing file |
| `NotADirectoryError` | File used as directory |
| `PermissionError` | Access denied |
| `IsADirectoryError` | Directory used as file |
| `ModuleNotFoundError` | Module cannot be found |
| `ImportError` | Name cannot be imported |
| `JSONDecodeError` | Invalid JSON |
| `UnicodeDecodeError` | Incorrect text encoding |
| `ZeroDivisionError` | Division by zero |
| `RecursionError` | Recursion lacks a stopping point |

---

# 17. A General Exception-Handling Pattern

```python
try:
    # Code that may fail
    result = perform_operation()
except SpecificError as error:
    # Handle a known problem
    print(f"Operation failed: {error}")
else:
    # Runs when no exception occurs
    print(result)
finally:
    # Runs whether an error occurred or not
    print("Operation finished.")
```

Use `try` around the smallest practical block.

Avoid this:

```python
try:
    # A large portion of the entire program
    ...
except Exception:
    print("Something went wrong.")
```

Large, broad handlers can hide the actual source of programming mistakes.

---

# 18. Part 2 Summary

This section covered:

- `ValueError`
- `IndexError`
- `KeyError`
- `FileNotFoundError`
- `NotADirectoryError`
- `PermissionError`
- `IsADirectoryError`
- `OSError`
- `ModuleNotFoundError`
- `JSONDecodeError`
- `UnicodeDecodeError`
- `RecursionError`
- `ZeroDivisionError`
- `OverflowError`

The next section is:

# Appendix D, Part 3: Debugging Strategies and Error Prevention

It will cover:

- A repeatable debugging process.
- Reading tracebacks.
- Inspecting values and types.
- Reducing problems to small examples.
- Using assertions.
- Writing defensive code.
- Preventing common errors.

---

# Appendix D, Part 3 of 3: Debugging Strategies and Error Prevention

This is the final section of Appendix D.

You have already learned about common Python error types. Now you will learn how to investigate problems systematically and prevent many errors before they occur.

The goal of debugging is not to guess randomly. It is to collect evidence, form a hypothesis, test it, and make a focused correction.

---

# 1. A Repeatable Debugging Process

When a program fails, use this sequence:

1. Read the complete error message.
2. Identify the exception type.
3. Find the file and line number.
4. Inspect the values used on that line.
5. Check the values' types.
6. Reproduce the smallest failing example.
7. Make one focused change.
8. Run the program again.
9. Add a test if the problem could return.

Do not immediately rewrite the entire program.

Changing many things at once makes it difficult to determine which change fixed or caused the problem.

---

# 2. Read the Traceback from the Bottom

Consider:

```text
Traceback (most recent call last):
  File "task_manager.py", line 24, in main
    task = tasks[task_id]
IndexError: list index out of range
```

The important information is:

```text
IndexError: list index out of range
```

The location is:

```text
task_manager.py, line 24
```

The code is:

```python
task = tasks[task_id]
```

The likely problem is that `task_id` is larger than the final valid index.

---

# 3. Inspect Values with `print()`

Suppose this code fails:

```python
def calculate_total(price, quantity):
    return price * quantity


price = input("Price: ")
quantity = input("Quantity: ")

total = calculate_total(price, quantity)
print(total)
```

The inputs are strings, not numbers.

Add diagnostic output:

```python
print(f"price={price!r}, type={type(price)}")
print(f"quantity={quantity!r}, type={type(quantity)}")
```

The `!r` displays a value's representation, making whitespace easier to see.

Example:

```text
price='4.50', type=<class 'str'>
quantity='3', type=<class 'str'>
```

Convert the values:

```python
price = float(price)
quantity = int(quantity)
```

---

# 4. Use `repr()` to Reveal Whitespace

These values may look similar:

```python
first = "task"
second = "task "
```

Print them normally:

```python
print(first)
print(second)
```

The difference is difficult to see.

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

For user input, use:

```python
user_input = input("Enter a command: ").strip()
```

---

# 5. Check Types Explicitly

When an operation behaves unexpectedly, inspect the types:

```python
value = input("Enter a number: ")

print(value)
print(type(value))
```

Even if the user enters:

```text
42
```

the type is:

```text
<class 'str'>
```

Convert it:

```python
number = int(value)

print(number)
print(type(number))
```

For collections:

```python
tasks = [
    "Learn Python",
    "Practice loops",
]

print(type(tasks))
print(type(tasks[0]))
```

---

# 6. Reduce the Problem

If a large program fails, isolate the smallest piece that reproduces the problem.

Instead of debugging an entire task manager, create:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]

task_id = 2

for task in tasks:
    if task["id"] == task_id:
        print(task)
```

Ask:

- Is the task ID correct?
- Does the loop execute?
- Does the dictionary contain the expected keys?
- Does the condition ever become true?

A smaller example is easier to inspect.

---

# 7. Use Assertions

An assertion checks an assumption.

```python
age = 36

assert age >= 0
```

If the condition is false, Python raises an `AssertionError`.

```python
age = -1

assert age >= 0
```

You can include a message:

```python
assert age >= 0, "Age cannot be negative."
```

Assertions are useful for detecting programmer mistakes and invalid internal state.

Do not rely on assertions as the only way to validate user input. User input should receive normal validation and friendly messages.

---

## Example Assertion

```python
def calculate_total(price, quantity):
    assert price >= 0, "Price cannot be negative."
    assert quantity >= 0, "Quantity cannot be negative."

    return price * quantity
```

These checks document assumptions made by the function.

---

# 8. Validate External Input

External input includes:

- User input.
- Command-line arguments.
- JSON files.
- Text files.
- Environment variables.
- Network responses.

Never assume external data is valid.

Validate user input:

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

# 9. Use Small Functions

Large functions are difficult to debug.

This function has too many responsibilities:

```python
def run_program():
    # Read arguments
    # Load JSON
    # Validate data
    # Add task
    # Save JSON
    # Print output
    # Handle errors
    ...
```

Separate the operations:

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

When an error occurs, you can identify which operation is responsible.

---

# 10. Give Functions One Main Responsibility

A function named:

```python
load_tasks()
```

should load tasks.

It should not also:

- Display a menu.
- Ask the user for a title.
- Complete a task.
- Move files.

Focused functions are easier to:

- Read.
- Test.
- Reuse.
- Replace.
- Debug.

---

# 11. Use Clear Variable Names

This is difficult to understand:

```python
x = 3
y = 2
z = x - y
```

This is clearer:

```python
total_tasks = 3
completed_tasks = 2
incomplete_tasks = total_tasks - completed_tasks
```

Clear names reduce the need for comments and make errors easier to diagnose.

---

# 12. Handle Expected Exceptions

Expected problems should be handled deliberately.

```python
try:
    task_id = int(user_input)
except ValueError:
    print("Please enter a valid task ID.")
```

Avoid using exceptions as a substitute for all validation.

Use ordinary conditions when they make the rule clearer:

```python
if not title.strip():
    print("The title cannot be empty.")
```

Use exceptions when an operation may naturally fail:

```python
try:
    data = json.loads(text)
except json.JSONDecodeError:
    print("The JSON is invalid.")
```

---

# 13. Avoid Broad Exception Handling

This can hide serious bugs:

```python
try:
    run_application()
except Exception:
    print("Something went wrong.")
```

The message does not explain the real problem.

Prefer specific exceptions:

```python
try:
    task_id = int(user_input)
except ValueError:
    print("Task ID must be an integer.")
```

If a broad handler is necessary at the outermost application boundary, log or display enough information to diagnose the failure.

---

# 14. Test One Change at a Time

Suppose the task manager has a broken `complete` command.

Avoid changing all of these at once:

- The JSON format.
- The task logic.
- The CLI parser.
- The display code.
- The storage module.

Instead:

1. Confirm that the task exists in JSON.
2. Test `load_tasks()`.
3. Test `find_task()`.
4. Test `complete_task()`.
5. Test `save_tasks()`.
6. Test the complete CLI command.

This identifies the failing layer.

---

# 15. Test Functions Independently

Suppose you have:

```python
def count_completed(tasks):
    return sum(
        1 for task in tasks if task["completed"]
    )
```

Test it with simple known data:

```python
tasks = [
    {"completed": True},
    {"completed": False},
    {"completed": True},
]

result = count_completed(tasks)

assert result == 2
```

This tests the function without running the entire application.

---

# 16. Use Temporary Files in Tests

Do not let tests modify your real data:

```text
data/tasks.json
```

Use temporary directories:

```python
import tempfile
from pathlib import Path


with tempfile.TemporaryDirectory() as directory:
    file_path = Path(directory) / "tasks.json"
    file_path.write_text("[]", encoding="utf-8")
```

The temporary directory is automatically removed when the block ends.

This keeps tests isolated and repeatable.

---

# 17. Test Both Success and Failure

A function should be tested with valid and invalid input.

For task creation:

```python
def test_create_task():
    ...
```

Also test an empty title:

```python
def test_empty_title_is_rejected():
    ...
```

For file loading, test:

- A missing file.
- Valid JSON.
- Invalid JSON.
- A valid JSON value with the wrong structure.

For the organizer, test:

- A normal file.
- A file without an extension.
- Duplicate names.
- A missing directory.
- Dry-run behavior.

---

# 18. Test Boundary Conditions

Boundary conditions are values near the edge of what is allowed.

Examples:

- An empty list.
- One-item list.
- Zero.
- One.
- The maximum allowed number.
- A missing dictionary key.
- An empty string.
- A whitespace-only string.

For a positive task ID:

```python
0
```

and:

```python
-1
```

should be rejected.

A valid minimum may be:

```python
1
```

Testing boundaries catches many bugs.

---

# 19. Preserve Reproducibility

A problem is easier to debug when it can be reproduced.

Record:

- The command that was run.
- The input that was entered.
- The data file contents.
- The Python version.
- The expected result.
- The actual result.

Example:

```text
Command:
python -m foundation_cli complete 3

Data:
tasks.json contains IDs 1 and 2

Expected:
No task found with ID 3.

Actual:
IndexError
```

This provides a clear starting point for investigation.

---

# 20. Check the Current Working Directory

File problems often occur because a program is running from a different directory than expected.

Check it with:

```bash
python -c "from pathlib import Path; print(Path.cwd())"
```

In Python:

```python
from pathlib import Path

print(Path.cwd())
```

For application data, use a path based on the source or project structure when appropriate:

```python
DATA_FILE = Path(__file__).resolve().parents[2] / "data" / "tasks.json"
```

This is more reliable than assuming:

```python
Path("tasks.json")
```

always refers to the same location.

---

# 21. Inspect Files Directly

If a program reads incorrect data, inspect the file itself.

Display JSON:

```bash
python -m json.tool data/tasks.json
```

Read a text file:

### Windows PowerShell

```powershell
Get-Content data\tasks.json
```

### macOS or Linux

```bash
cat data/tasks.json
```

Check:

- Spelling.
- Punctuation.
- Missing commas.
- Incorrect quotation marks.
- Unexpected whitespace.
- Unexpected data types.

---

# 22. Use Version Control

Git can help you recover from mistakes and compare changes.

Common commands:

```bash
git status
```

```bash
git diff
```

```bash
git add .
```

```bash
git commit -m "Add task completion command"
```

When debugging, make small commits.

If a change causes a problem, you can inspect the difference or return to a previous version.

---

# 23. Preventing Common Errors

## Prevent `NameError`

- Use clear names.
- Check spelling.
- Keep variable scope understandable.
- Run code after defining required functions and variables.

## Prevent `TypeError`

- Inspect input types.
- Convert user input explicitly.
- Use type hints.
- Avoid mixing unrelated types.

## Prevent `IndexError`

- Check collection length.
- Use loops when processing all items.
- Check whether a list is empty.

## Prevent `KeyError`

- Use `.get()` for optional keys.
- Validate dictionaries.
- Define a clear data schema.

## Prevent `FileNotFoundError`

- Check `.exists()`.
- Create required directories.
- Use reliable paths.
- Handle missing files intentionally.

## Prevent `JSONDecodeError`

- Write JSON with `json.dump()`.
- Validate files with `python -m json.tool`.
- Handle corrupted files.
- Do not manually edit JSON carelessly.

---

# 24. Debugging Checklist

When your program fails, ask:

```text
What is the exact exception type?
What is the final error message?
Which file and line failed?
What values are involved?
What are their types?
Is whitespace affecting the value?
Is the path correct?
Does the file exist?
Does the dictionary key exist?
Is the list empty?
Is the function receiving the expected arguments?
Can I reproduce the problem in a smaller example?
```

Then:

```text
Make one change.
Run the program again.
Record the result.
Add a test if appropriate.
```

---

# 25. Example Debugging Session

Suppose this program fails:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
    }
]

task_id = input("Task ID: ")

for task in tasks:
    if task["id"] == task_id:
        print(task["title"])
```

The user enters:

```text
1
```

Nothing is displayed.

The problem is that:

```python
task["id"]
```

is an integer:

```python
1
```

but:

```python
task_id
```

is a string:

```python
"1"
```

Inspect the values:

```python
print(repr(task["id"]), type(task["id"]))
print(repr(task_id), type(task_id))
```

Output:

```text
1 <class 'int'>
'1' <class 'str'>
```

Convert the input:

```python
task_id = int(input("Task ID: "))
```

Now the comparison works:

```python
if task["id"] == task_id:
    print(task["title"])
```

---

# 26. Debugging with Temporary Output

Temporary diagnostic output is useful:

```python
print(f"Loaded tasks: {tasks!r}")
print(f"Requested task ID: {task_id!r}")
```

After fixing the issue, remove unnecessary diagnostic output.

Permanent logging can be added later with Python's `logging` module.

---

# 27. Logging Instead of `print()`

For larger programs, use `logging`:

```python
import logging


logging.basicConfig(level=logging.INFO)

logging.info("Application started.")
logging.warning("Task file is missing.")
logging.error("Could not save tasks.")
```

Logging can include:

- Severity levels.
- Timestamps.
- File output.
- Debug messages.
- Error details.

For the beginner capstone, normal user-facing `print()` messages are sufficient. Logging becomes more useful as applications grow.

---

# 28. When to Ask for Help

When seeking help with an error, include:

1. The complete error message.
2. The smallest relevant code example.
3. The command used.
4. The Python version.
5. The expected behavior.
6. The actual behavior.
7. What you already tried.

Avoid sharing only:

```text
It does not work.
```

A complete report is more useful:

```text
I ran:

python -m foundation_cli list

I expected the task list to display.

Instead, I received:

FileNotFoundError: ...

The data file is located at:

data/tasks.json
```

---

# Appendix D Complete

You have now completed all three sections:

```text
Appendix D, Part 1:
Syntax, indentation, name, and type errors

Appendix D, Part 2:
Value, index, key, file, module, and JSON errors

Appendix D, Part 3:
Debugging strategies and error prevention
```

The main lessons are:

- Read error messages carefully.
- Start at the bottom of a traceback.
- Inspect values and types.
- Validate external input.
- Use small, focused functions.
- Handle specific exceptions.
- Test success and failure cases.
- Use temporary files in tests.
- Change one thing at a time.
- Add tests for bugs that could return.

A useful final debugging pattern is:

```text
Observe
    ↓
Identify
    ↓
Reproduce
    ↓
Hypothesize
    ↓
Change one thing
    ↓
Test
    ↓
Document or automate the fix
```
