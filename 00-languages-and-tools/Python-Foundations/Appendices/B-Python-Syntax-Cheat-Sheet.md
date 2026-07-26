# Appendix B: Python Syntax Cheat Sheet

This appendix summarizes the Python syntax used throughout **Python Foundations: From Zero to Functional Code**.

Use it as a quick reference rather than reading it from beginning to end.

---

# 1. Comments

A single-line comment begins with `#`:

```python
# This is a comment.
print("Hello")
```

Python ignores comments when running the program.

---

# 2. Printing Output

Use `print()` to display information:

```python
print("Hello, Python!")
print(2 + 3)
```

Output:

```text
Hello, Python!
5
```

Print multiple values:

```python
name = "Ada"
age = 36

print(name, age)
```

Output:

```text
Ada 36
```

---

# 3. Variables

Assign a value with `=`:

```python
name = "Ada"
age = 36
height = 1.65
is_learning = True
```

Variable names should describe their values:

```python
completed_tasks = 3
```

Prefer this:

```python
user_name = "Ada"
```

Over this:

```python
x = "Ada"
```

Use `snake_case` for ordinary variable names:

```python
favorite_color = "blue"
task_count = 5
```

---

# 4. Basic Data Types

## Strings

Strings contain text:

```python
name = "Ada"
message = 'Hello'
```

## Integers

Integers are whole numbers:

```python
age = 36
temperature = -2
```

## Floats

Floats contain decimal values:

```python
price = 19.99
height = 1.65
```

## Booleans

Booleans represent true or false:

```python
is_complete = True
is_locked = False
```

## `None`

`None` represents the absence of a value:

```python
result = None
```

---

# 5. Checking Types

Use `type()`:

```python
value = 42

print(type(value))
```

Output:

```text
<class 'int'>
```

Use `isinstance()` for type checks:

```python
value = 42

print(isinstance(value, int))
print(isinstance(value, str))
```

Output:

```text
True
False
```

---

# 6. Arithmetic Operators

| Operator | Meaning | Example | Result |
|---|---|---:|---:|
| `+` | Addition | `5 + 2` | `7` |
| `-` | Subtraction | `5 - 2` | `3` |
| `*` | Multiplication | `5 * 2` | `10` |
| `/` | Division | `5 / 2` | `2.5` |
| `//` | Floor division | `5 // 2` | `2` |
| `%` | Remainder | `5 % 2` | `1` |
| `**` | Power | `5 ** 2` | `25` |

Examples:

```python
total = 5 + 2
difference = 5 - 2
product = 5 * 2
quotient = 5 / 2
remainder = 5 % 2
squared = 5 ** 2
```

---

# 7. Assignment Operators

Basic assignment:

```python
count = 10
```

Add and assign:

```python
count += 1
```

Equivalent to:

```python
count = count + 1
```

Other assignment operators:

```python
count -= 1
price *= 2
distance /= 2
remainder %= 3
```

---

# 8. Strings

## Combining Strings

```python
first_name = "Ada"
last_name = "Lovelace"

full_name = first_name + " " + last_name

print(full_name)
```

Output:

```text
Ada Lovelace
```

## String Length

```python
message = "Hello"

print(len(message))
```

Output:

```text
5
```

## Changing Case

```python
text = "Python Programming"

print(text.lower())
print(text.upper())
print(text.title())
```

Output:

```text
python programming
PYTHON PROGRAMMING
Python Programming
```

## Removing Whitespace

```python
user_input = "  Learn Python  "

cleaned = user_input.strip()

print(cleaned)
```

Output:

```text
Learn Python
```

## Replacing Text

```python
message = "I like Java."

updated_message = message.replace("Java", "Python")

print(updated_message)
```

Output:

```text
I like Python.
```

## Splitting Text

```python
text = "red,green,blue"

colors = text.split(",")

print(colors)
```

Output:

```text
['red', 'green', 'blue']
```

## Joining Text

```python
colors = ["red", "green", "blue"]

text = ", ".join(colors)

print(text)
```

Output:

```text
red, green, blue
```

---

# 9. F-Strings

F-strings insert values into text:

```python
name = "Ada"
age = 36

message = f"{name} is {age} years old."

print(message)
```

Output:

```text
Ada is 36 years old.
```

Expressions can be used inside braces:

```python
price = 12.50
quantity = 3

print(f"Total: ${price * quantity:.2f}")
```

Output:

```text
Total: $37.50
```

Common formatting examples:

```python
number = 3.14159

print(f"{number:.2f}")
print(f"{number:.0f}")
```

Output:

```text
3.14
3
```

---

# 10. Type Conversion

Convert to a string:

```python
text = str(42)
```

Convert to an integer:

```python
number = int("42")
```

Convert to a float:

```python
price = float("19.99")
```

Convert to a Boolean:

```python
is_available = bool(1)
```

User input is always returned as a string:

```python
age_text = input("Age: ")
age = int(age_text)
```

Handle invalid conversion safely:

```python
try:
    age = int(age_text)
except ValueError:
    print("Invalid age.")
```

---

# 11. Lists

Create a list:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a project",
]
```

Access items:

```python
print(tasks[0])
print(tasks[-1])
```

Change an item:

```python
tasks[1] = "Practice dictionaries"
```

Add an item:

```python
tasks.append("Read documentation")
```

Insert an item:

```python
tasks.insert(1, "Practice conditions")
```

Remove by value:

```python
tasks.remove("Learn Python")
```

Remove by index:

```python
removed_task = tasks.pop(0)
```

Remove all items:

```python
tasks.clear()
```

Find the number of items:

```python
print(len(tasks))
```

Check membership:

```python
if "Learn Python" in tasks:
    print("Task exists.")
```

---

# 12. List Slicing

Given:

```python
numbers = [0, 1, 2, 3, 4]
```

Select a range:

```python
print(numbers[1:4])
```

Output:

```text
[1, 2, 3]
```

The ending index is excluded.

Other examples:

```python
print(numbers[:3])
print(numbers[2:])
print(numbers[:])
print(numbers[-2:])
```

Output:

```text
[0, 1, 2]
[2, 3, 4]
[0, 1, 2, 3, 4]
[3, 4]
```

---

# 13. Sorting Lists

Sort a list in place:

```python
numbers = [3, 1, 2]

numbers.sort()

print(numbers)
```

Output:

```text
[1, 2, 3]
```

Sort in descending order:

```python
numbers.sort(reverse=True)
```

Create a sorted copy:

```python
numbers = [3, 1, 2]
sorted_numbers = sorted(numbers)
```

The original list remains unchanged.

---

# 14. Tuples

Create a tuple:

```python
coordinates = (51.5074, -0.1278)
```

Access values:

```python
latitude = coordinates[0]
longitude = coordinates[1]
```

Tuples cannot be changed:

```python
coordinates[0] = 40.7128
```

This raises a `TypeError`.

Unpack a tuple:

```python
coordinates = (51.5074, -0.1278)

latitude, longitude = coordinates
```

A one-item tuple requires a comma:

```python
single_item = ("Python",)
```

Without the comma, it is simply a string inside parentheses:

```python
not_a_tuple = ("Python")
```

---

# 15. Dictionaries

Create a dictionary:

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

Read a value:

```python
print(task["title"])
```

Add a key:

```python
task["priority"] = "high"
```

Update a value:

```python
task["completed"] = True
```

Read safely with `get()`:

```python
priority = task.get("priority", "normal")
```

Check for a key:

```python
if "title" in task:
    print("The task has a title.")
```

Get keys:

```python
print(task.keys())
```

Get values:

```python
print(task.values())
```

Get key-value pairs:

```python
print(task.items())
```

Remove a key:

```python
priority = task.pop("priority")
```

Remove all values:

```python
task.clear()
```

---

# 16. Sets

Create a set:

```python
tags = {"python", "cli", "beginner"}
```

Duplicate values are automatically removed:

```python
tags = {"python", "python", "cli"}

print(tags)
```

Add an item:

```python
tags.add("tutorial")
```

Remove an item:

```python
tags.remove("cli")
```

Remove safely if it may not exist:

```python
tags.discard("advanced")
```

Check membership:

```python
if "python" in tags:
    print("Python tag exists.")
```

---

# 17. Set Operations

```python
first = {"a", "b", "c"}
second = {"b", "c", "d"}
```

Union:

```python
print(first | second)
```

Intersection:

```python
print(first & second)
```

Difference:

```python
print(first - second)
```

Symmetric difference:

```python
print(first ^ second)
```

---

# 18. Conditional Statements

Basic `if`:

```python
age = 20

if age >= 18:
    print("Adult")
```

`if` and `else`:

```python
if age >= 18:
    print("Adult")
else:
    print("Minor")
```

Multiple branches:

```python
if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
elif score >= 70:
    grade = "C"
else:
    grade = "F"
```

Remember the colon:

```python
if condition:
```

Remember the indentation:

```python
if condition:
    print("Inside the block")
```

---

# 19. Comparison Operators

| Operator | Meaning |
|---|---|
| `==` | Equal |
| `!=` | Not equal |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |

Examples:

```python
age == 18
age != 18
age > 18
age < 18
age >= 18
age <= 18
```

Do not confuse:

```python
=
```

with:

```python
==
```

Assignment:

```python
age = 36
```

Comparison:

```python
age == 36
```

---

# 20. Logical Operators

Use `and` when every condition must be true:

```python
if age >= 18 and has_ticket:
    print("Entry allowed.")
```

Use `or` when at least one condition must be true:

```python
if day == "Saturday" or day == "Sunday":
    print("Weekend")
```

Use `not` to reverse a condition:

```python
if not is_completed:
    print("Task remains incomplete.")
```

---

# 21. Membership Operators

Use `in`:

```python
if "Python" in message:
    print("Found Python.")
```

Use `not in`:

```python
if username not in blocked_users:
    print("Access considered.")
```

For dictionaries, `in` checks keys:

```python
if "title" in task:
    print("Title exists.")
```

To check dictionary values:

```python
if "Learn Python" in task.values():
    print("Title found.")
```

---

# 22. Truthy and Falsy Values

These values are generally falsy:

```python
False
None
0
0.0
""
[]
{}
set()
```

Example:

```python
name = ""

if name:
    print("Name provided.")
else:
    print("Name missing.")
```

Output:

```text
Name missing.
```

Use this pattern for required text:

```python
value = input("Enter a value: ").strip()

if not value:
    print("Value cannot be empty.")
```

---

# 23. `for` Loops

Loop through a list:

```python
tasks = ["Learn Python", "Practice loops"]

for task in tasks:
    print(task)
```

Loop through a string:

```python
for character in "Python":
    print(character)
```

Loop through a dictionary's keys:

```python
for key in task:
    print(key)
```

Loop through values:

```python
for value in task.values():
    print(value)
```

Loop through key-value pairs:

```python
for key, value in task.items():
    print(f"{key}: {value}")
```

---

# 24. `range()`

Generate numbers from zero up to, but not including, the limit:

```python
for number in range(5):
    print(number)
```

Output:

```text
0
1
2
3
4
```

Specify a start and stop:

```python
for number in range(1, 6):
    print(number)
```

Specify a step:

```python
for number in range(0, 11, 2):
    print(number)
```

Output:

```text
0
2
4
6
8
10
```

Count backward:

```python
for number in range(5, 0, -1):
    print(number)
```

---

# 25. `enumerate()`

Use `enumerate()` when you need an index and a value:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a project",
]

for index, task in enumerate(tasks):
    print(index, task)
```

Start counting at one:

```python
for number, task in enumerate(tasks, start=1):
    print(f"{number}. {task}")
```

Output:

```text
1. Learn Python
2. Practice loops
3. Build a project
```

---

# 26. `while` Loops

A `while` loop continues while a condition is true:

```python
count = 3

while count > 0:
    print(count)
    count -= 1
```

Output:

```text
3
2
1
```

Always make sure something changes the loop condition.

This can become an infinite loop:

```python
count = 3

while count > 0:
    print(count)
```

Stop an accidental infinite loop with:

```text
Ctrl+C
```

---

# 27. `break` and `continue`

Use `break` to exit a loop:

```python
while True:
    command = input("Command: ")

    if command == "quit":
        break
```

Use `continue` to skip the current iteration:

```python
for task in tasks:
    if not task:
        continue

    print(task)
```

---

# 28. Functions

Define a function:

```python
def greet():
    print("Hello")
```

Call it:

```python
greet()
```

Use parameters:

```python
def greet(name):
    print(f"Hello, {name}!")


greet("Ada")
```

Return a value:

```python
def add(first, second):
    return first + second
```

Use the result:

```python
result = add(2, 3)
```

---

# 29. Function Type Hints

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"
```

```python
def calculate_total(
    price: float,
    quantity: int,
) -> float:
    return price * quantity
```

```python
def show_message(message: str) -> None:
    print(message)
```

---

# 30. Default Parameters

```python
def greet(name: str, greeting: str = "Hello") -> str:
    return f"{greeting}, {name}!"
```

Calls:

```python
greet("Ada")
greet("Grace", "Welcome")
```

Required parameters must appear before default parameters.

---

# 31. The `main()` Pattern

A common script structure is:

```python
def main() -> None:
    print("Program started.")


if __name__ == "__main__":
    main()
```

This allows the file to be:

- Run directly.
- Imported without automatically starting the program.

---

# 32. Importing Modules

Given this file:

```text
calculations.py
```

```python
def add(first, second):
    return first + second
```

Import the function:

```python
from calculations import add

print(add(2, 3))
```

Import the entire module:

```python
import calculations

print(calculations.add(2, 3))
```

Use a relative import inside a package:

```python
from .tasks import create_task
```

---

# 33. Opening Files

Read a file:

```python
with open("notes.txt", "r", encoding="utf-8") as file:
    contents = file.read()
```

Write a file:

```python
with open("notes.txt", "w", encoding="utf-8") as file:
    file.write("First note\n")
```

Append to a file:

```python
with open("notes.txt", "a", encoding="utf-8") as file:
    file.write("Another note\n")
```

The `with` statement closes the file safely.

---

# 34. `pathlib`

Import `Path`:

```python
from pathlib import Path
```

Create a path:

```python
file_path = Path("data") / "tasks.json"
```

Check existence:

```python
file_path.exists()
```

Check whether it is a file:

```python
file_path.is_file()
```

Check whether it is a directory:

```python
file_path.is_dir()
```

Create a directory:

```python
file_path.parent.mkdir(
    parents=True,
    exist_ok=True,
)
```

Write text:

```python
file_path.write_text(
    "Hello",
    encoding="utf-8",
)
```

Read text:

```python
contents = file_path.read_text(encoding="utf-8")
```

---

# 35. JSON

Import the module:

```python
import json
```

Write JSON to a file:

```python
with open("tasks.json", "w", encoding="utf-8") as file:
    json.dump(tasks, file, indent=2)
```

Read JSON from a file:

```python
with open("tasks.json", "r", encoding="utf-8") as file:
    tasks = json.load(file)
```

Convert Python data to a JSON string:

```python
json_text = json.dumps(tasks, indent=2)
```

Convert a JSON string to Python data:

```python
tasks = json.loads(json_text)
```

---

# 36. Exception Handling

Basic exception handling:

```python
try:
    number = int(user_input)
except ValueError:
    print("Invalid number.")
```

With `else`:

```python
try:
    number = int(user_input)
except ValueError:
    print("Invalid number.")
else:
    print(f"You entered {number}.")
```

With `finally`:

```python
try:
    process_data()
except ValueError:
    print("Invalid data.")
finally:
    print("Finished.")
```

Handle multiple errors:

```python
try:
    number = int(user_input)
    result = 100 / number
except ValueError:
    print("Invalid integer.")
except ZeroDivisionError:
    print("Cannot divide by zero.")
```

Prefer specific exceptions over:

```python
except Exception:
    ...
```

---

# 37. Raising Exceptions

Raise an exception when a function receives invalid data:

```python
def create_task(title: str) -> dict:
    if not title.strip():
        raise ValueError("Title cannot be empty.")

    return {
        "title": title.strip(),
        "completed": False,
    }
```

Custom exception:

```python
class TaskNotFoundError(Exception):
    """Raised when a task cannot be found."""
```

Raise it:

```python
raise TaskNotFoundError(
    f"No task found with ID {task_id}."
)
```

Handle it:

```python
try:
    complete_task(tasks, task_id)
except TaskNotFoundError as error:
    print(f"Error: {error}")
```

---

# 38. Dataclasses

Import `dataclass`:

```python
from dataclasses import dataclass
```

Define a data class:

```python
@dataclass
class FileMove:
    source: str
    destination: str
```

Create an instance:

```python
move = FileMove(
    source="report.pdf",
    destination="pdf/report.pdf",
)
```

Make it immutable:

```python
@dataclass(frozen=True)
class FileMove:
    source: str
    destination: str
```

---

# 39. Command-Line Arguments with `argparse`

Import the module:

```python
import argparse
```

Create a parser:

```python
parser = argparse.ArgumentParser(
    description="Example application.",
)
```

Add a positional argument:

```python
parser.add_argument(
    "name",
    help="The user's name.",
)
```

Parse arguments:

```python
arguments = parser.parse_args()
print(arguments.name)
```

Add a Boolean flag:

```python
parser.add_argument(
    "--dry-run",
    action="store_true",
)
```

Add a typed argument:

```python
parser.add_argument(
    "task_id",
    type=int,
)
```

---

# 40. Common Collection Patterns

## List of Tasks

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]
```

## Find an Item

```python
for task in tasks:
    if task["id"] == task_id:
        matching_task = task
        break
```

## Count Matching Items

```python
completed_count = sum(
    1 for task in tasks if task["completed"]
)
```

## Filter Items

```python
incomplete_tasks = [
    task for task in tasks
    if not task["completed"]
]
```

## Create a Dictionary from Values

```python
names = ["Ada", "Grace"]

lengths = {
    name: len(name)
    for name in names
}
```

---

# 41. Common Naming Conventions

## Variables and Functions

Use `snake_case`:

```python
task_count = 3


def display_tasks():
    ...
```

## Classes

Use `PascalCase`:

```python
class TaskManager:
    ...
```

## Constants

Use uppercase with underscores:

```python
DATA_FILE = Path("data/tasks.json")
MAX_RETRIES = 3
```

## Private Internal Names

A leading underscore commonly indicates an internal name:

```python
_internal_cache = {}
```

The underscore is a convention, not a strict access restriction.

---

# 42. Indentation and Formatting

Python uses indentation to define blocks:

```python
if ready:
    print("Start")
```

Use four spaces per indentation level.

This is valid:

```python
def main():
    if True:
        print("Running")
```

This is invalid:

```python
def main():
  if True:
      print("Running")
```

Avoid mixing tabs and spaces.

---

# 43. Multi-Line Expressions

Use parentheses for readable multi-line expressions:

```python
total = (
    price
    * quantity
    * tax_rate
)
```

Multi-line function calls:

```python
task = create_task(
    tasks,
    "Learn Python",
)
```

Multi-line collections:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
]
```

---

# 44. Useful Boolean Patterns

Check whether a list is empty:

```python
if not tasks:
    print("No tasks found.")
```

Check whether a value exists:

```python
if task is not None:
    print(task)
```

Prefer identity checks for `None`:

```python
if value is None:
    ...
```

Rather than:

```python
if value == None:
    ...
```

Check several allowed values:

```python
if command in {"add", "list", "remove"}:
    ...
```

---

# 45. Quick Complete Example

```python
from pathlib import Path
import json


DATA_FILE = Path("tasks.json")


def load_tasks() -> list[dict]:
    if not DATA_FILE.exists():
        return []

    with DATA_FILE.open("r", encoding="utf-8") as file:
        return json.load(file)


def save_tasks(tasks: list[dict]) -> None:
    with DATA_FILE.open("w", encoding="utf-8") as file:
        json.dump(tasks, file, indent=2)


def main() -> None:
    tasks = load_tasks()

    tasks.append(
        {
            "id": len(tasks) + 1,
            "title": "Review Python syntax",
            "completed": False,
        }
    )

    save_tasks(tasks)

    for task in tasks:
        print(task["title"])


if __name__ == "__main__":
    main()
```

This example combines:

- Imports.
- Constants.
- Functions.
- Type hints.
- `pathlib`.
- JSON.
- Lists.
- Dictionaries.
- Loops.
- The `main()` pattern.

---

# Appendix B Summary

The most important Python syntax patterns are:

```python
variable = value
```

```python
if condition:
    ...
elif another_condition:
    ...
else:
    ...
```

```python
for item in collection:
    ...
```

```python
while condition:
    ...
```

```python
def function_name(parameter):
    return value
```

```python
try:
    ...
except SpecificError:
    ...
```

```python
with open("file.txt", "r", encoding="utf-8") as file:
    contents = file.read()
```

```python
if __name__ == "__main__":
    main()
```

When writing Python, prioritize:

- Clear names.
- Consistent indentation.
- Small functions.
- Explicit error handling.
- Appropriate data structures.
- Readable formatting.
