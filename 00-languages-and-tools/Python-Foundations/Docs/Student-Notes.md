# Python Foundations: Student Notes

## From Zero to Functional Code

These notes summarize the key ideas from the **Python Foundations** series.

They are designed for quick review after lessons, exercises, and projects.

To keep the notes manageable, they are divided into sections:

```text
Student Notes Part 1: Environment and Basic Syntax
Student Notes Part 2: Collections
Student Notes Part 3: Program Flow
Student Notes Part 4: Functions, Files, JSON, and Exceptions
Student Notes Part 5: Capstone Architecture and CLI
Student Notes Part 6: Testing, Debugging, and Reference
```

This is **Student Notes Part 1**.

---

# Part 1: Environment and Basic Syntax

## 1. Python

Python is a general-purpose programming language known for readable syntax.

A Python program is usually saved in a file ending with:

```text
.py
```

Example:

```text
hello.py
```

Run it with:

```bash
python hello.py
```

Depending on the operating system, you may use:

```bash
python3 hello.py
```

or on Windows:

```bash
py hello.py
```

---

## 2. Checking Python

Check the installed version:

```bash
python --version
```

Alternative commands:

```bash
python3 --version
```

```bash
py --version
```

Check the active Python executable:

```bash
python -c "import sys; print(sys.executable)"
```

Check the Python version from inside Python:

```bash
python -c "import sys; print(sys.version)"
```

---

## 3. Project Directories

A project directory keeps related files organized.

Create and enter a directory:

```bash
mkdir python-foundations
cd python-foundations
```

Check the current directory:

### Windows PowerShell

```powershell
Get-Location
```

### macOS/Linux

```bash
pwd
```

List contents:

### Windows PowerShell

```powershell
Get-ChildItem
```

### macOS/Linux

```bash
ls
```

Move up one directory:

```bash
cd ..
```

---

## 4. Virtual Environments

A virtual environment is an isolated Python workspace for one project.

Create one:

```bash
python -m venv .venv
```

Windows alternative:

```powershell
py -m venv .venv
```

macOS/Linux alternative:

```bash
python3 -m venv .venv
```

Activate on Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Activate on Windows Command Prompt:

```cmd
.venv\Scripts\activate.bat
```

Activate on macOS/Linux:

```bash
source .venv/bin/activate
```

Deactivate:

```bash
deactivate
```

Verify activation:

```bash
python -c "import sys; print(sys.executable)"
```

The path should contain:

```text
.venv
```

---

## 5. PowerShell Activation Problem

If PowerShell says that script execution is disabled, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try:

```powershell
.venv\Scripts\Activate.ps1
```

---

## 6. The Python Interactive Shell

Start it with:

```bash
python
```

You will see:

```text
>>>
```

Try:

```python
2 + 3
```

Output:

```text
5
```

Try:

```python
print("Hello from Python")
```

Exit with:

```python
exit()
```

The interactive shell is useful for quick experiments.

A `.py` file is better for saved programs.

---

## 7. Comments

Comments begin with `#`:

```python
# This is a comment.
print("Hello")
```

Python ignores comments when executing the program.

Useful comments explain:

- Why code exists.
- A non-obvious decision.
- An important assumption.
- A temporary learning note.

Avoid obvious comments such as:

```python
# Print Hello
print("Hello")
```

---

## 8. Indentation

Python uses indentation to define blocks.

Valid:

```python
if True:
    print("Inside the block")
```

Invalid:

```python
if True:
print("Missing indentation")
```

Use four spaces per indentation level.

Indentation is part of Python syntax, not merely formatting.

---

## 9. Variables

A variable is a name referring to a value.

```python
name = "Ada"
age = 36
```

Assignment uses:

```python
=
```

This means:

> Store the value on the right under the name on the left.

Good names:

```python
completed_tasks = 3
user_name = "Ada"
```

Poor names:

```python
x = 3
a = "Ada"
```

Use `snake_case`:

```python
favorite_color = "blue"
```

Python is case-sensitive:

```python
name = "Ada"
Name = "Grace"
```

These are different variables.

---

## 10. Basic Data Types

### String

Text:

```python
name = "Ada"
```

Type:

```python
str
```

### Integer

Whole number:

```python
age = 36
```

Type:

```python
int
```

### Float

Decimal number:

```python
price = 19.99
```

Type:

```python
float
```

### Boolean

True or false:

```python
is_complete = False
```

Type:

```python
bool
```

### None

Represents no value:

```python
result = None
```

---

## 11. Inspecting Types

Use `type()`:

```python
value = 42

print(type(value))
```

Use `isinstance()` for a type check:

```python
print(isinstance(value, int))
```

Example:

```python
age = 36

print(isinstance(age, int))
print(isinstance(age, str))
```

Output:

```text
True
False
```

---

## 12. Arithmetic Operators

| Operator | Meaning | Example |
|---|---|---:|
| `+` | Addition | `5 + 2` |
| `-` | Subtraction | `5 - 2` |
| `*` | Multiplication | `5 * 2` |
| `/` | Division | `5 / 2` |
| `//` | Floor division | `5 // 2` |
| `%` | Remainder | `5 % 2` |
| `**` | Exponentiation | `5 ** 2` |

Examples:

```python
print(5 + 2)
print(5 - 2)
print(5 * 2)
print(5 / 2)
print(5 // 2)
print(5 % 2)
print(5 ** 2)
```

Output:

```text
7
3
10
2.5
2
1
25
```

---

## 13. Assignment Operators

```python
count = 1
```

Add and assign:

```python
count += 1
```

Equivalent to:

```python
count = count + 1
```

Other examples:

```python
count -= 1
price *= 2
value /= 2
remainder %= 3
```

---

## 14. Strings

Combine strings:

```python
first_name = "Ada"
last_name = "Lovelace"

full_name = first_name + " " + last_name
```

String methods:

```python
text = "  Python Foundations  "

print(text.strip())
print(text.lower())
print(text.upper())
print(text.title())
```

Useful methods:

| Method | Purpose |
|---|---|
| `.strip()` | Removes surrounding whitespace |
| `.lower()` | Converts to lowercase |
| `.upper()` | Converts to uppercase |
| `.title()` | Capitalizes words |
| `.replace()` | Replaces text |
| `.split()` | Splits text into a list |
| `.join()` | Combines strings |

Example:

```python
text = "red,green,blue"

colors = text.split(",")

print(colors)
```

Output:

```text
['red', 'green', 'blue']
```

---

## 15. F-Strings

F-strings insert values into text:

```python
name = "Ada"
age = 36

print(f"{name} is {age} years old.")
```

Output:

```text
Ada is 36 years old.
```

Format decimal values:

```python
price = 12.5

print(f"Price: ${price:.2f}")
```

Output:

```text
Price: $12.50
```

The `.2f` means two decimal places.

---

## 16. Type Conversion

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
available = bool(1)
```

Remember:

```python
input()
```

always returns a string.

Convert numeric input:

```python
age_text = input("Age: ")
age = int(age_text)
```

---

## 17. Common Type Error

This fails:

```python
age = "36"

print(age + 1)
```

Why?

```text
"36" is a string.
1 is an integer.
```

Correct:

```python
age = "36"
age_as_number = int(age)

print(age_as_number + 1)
```

Or:

```python
age = 36

print(f"Age: {age}")
```

---

## 18. User Input

Read text:

```python
name = input("What is your name? ")

print(f"Hello, {name}!")
```

Normalize input:

```python
command = input("Command: ").strip().lower()
```

This makes inputs like these equivalent:

```text
list
LIST
 List
list
```

Required text:

```python
title = input("Task title: ").strip()

if not title:
    print("Title cannot be empty.")
```

---

## 19. Basic Program Pattern

Many beginner programs follow this model:

```text
Input
    ↓
Store
    ↓
Process
    ↓
Output
```

Example:

```python
minutes = 7
seconds = minutes * 60

print(f"{minutes} minutes equals {seconds} seconds.")
```

---

## 20. Personal Report Example

```python
name = "Ada Lovelace"
age = 36
city = "London"
height_meters = 1.65
is_learning_python = True

birth_year = 2026 - age
height_centimeters = height_meters * 100

print("Personal Report")
print("---------------")
print(f"Name: {name}")
print(f"Age: {age}")
print(f"City: {city}")
print(f"Approximate birth year: {birth_year}")
print(f"Height: {height_centimeters:.0f} cm")
print(f"Learning Python: {is_learning_python}")
```

---

# Part 1 Quick Review

## Commands

```bash
python --version
python -m venv .venv
python hello.py
python -c "print(2 + 3)"
deactivate
```

## Core Syntax

```python
name = "Ada"
age = 36
is_ready = True
```

## Core Types

```python
str
int
float
bool
None
```

## Key Reminders

```text
=  means assignment
== means comparison
input() returns a string
Python uses indentation
Indexes begin at zero
```

---

# Part 1 Self-Test

Complete these without looking back.

## 1. What command checks the Python version?

```text
____________________________________________________________
```

## 2. What command creates a virtual environment?

```text
____________________________________________________________
```

## 3. What type is `"42"`?

```text
____________________________________________________________
```

## 4. What type is `42`?

```text
____________________________________________________________
```

## 5. What type does `input()` return?

```text
____________________________________________________________
```

## 6. What is the difference between `=` and `==`?

```text
____________________________________________________________
```

## 7. What does `.strip()` do?

```text
____________________________________________________________
```

## 8. What does `.2f` do in an f-string?

```text
____________________________________________________________
```

---

# Part 1 Complete

Key ideas:

```text
Python executes instructions.
Variables store values.
Types describe values.
Input arrives as text.
Expressions produce results.
F-strings format output.
Indentation defines blocks.
```

Next:

# Student Notes Part 2: Collections

It will summarize:

- Lists.
- Tuples.
- Dictionaries.
- Sets.
- Nested collections.
- Collection selection.

---

# Python Foundations: Student Notes

## Part 2: Collections

Collections store groups of values.

The four main collection types are:

```text
List       → ordered, changeable values
Tuple      → ordered, fixed values
Dictionary → key-value data
Set        → unique values
```

---

# 1. Lists

A list stores an ordered, changeable sequence.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]
```

Lists are:

- Ordered.
- Mutable.
- Indexable.
- Able to contain duplicates.

---

## List Indexes

Indexes begin at zero:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

print(tasks[0])
print(tasks[1])
print(tasks[2])
```

Output:

```text
Learn Python
Practice loops
Build a CLI tool
```

Negative indexes count from the end:

```python
print(tasks[-1])
```

Output:

```text
Build a CLI tool
```

Index map:

```text
Index:     0                1                 2
Negative: -3               -2                -1
```

---

## Changing List Items

```python
tasks[1] = "Practice dictionaries"
```

Lists are mutable, so their contents can change.

---

## Adding Items

Add one item:

```python
tasks.append("Read documentation")
```

Insert at a specific position:

```python
tasks.insert(1, "Practice conditions")
```

Add multiple items:

```python
tasks.extend(
    [
        "Write tests",
        "Debug programs",
    ]
)
```

Combine lists:

```python
all_tasks = first_tasks + second_tasks
```

---

## Removing Items

Remove by value:

```python
tasks.remove("Read documentation")
```

Remove by index and return the value:

```python
removed_task = tasks.pop(1)
```

Remove the final item:

```python
last_task = tasks.pop()
```

Remove by index:

```python
del tasks[0]
```

Remove every item:

```python
tasks.clear()
```

---

## List Membership

```python
if "Learn Python" in tasks:
    print("Task exists.")
```

```python
if "Unknown task" not in tasks:
    print("Task was not found.")
```

---

## List Length

```python
print(len(tasks))
```

`len()` returns the number of items.

---

## List Slicing

Given:

```python
topics = [
    "variables",
    "strings",
    "lists",
    "dictionaries",
    "sets",
]
```

Examples:

```python
print(topics[:2])
```

Output:

```text
['variables', 'strings']
```

```python
print(topics[2:])
```

Output:

```text
['lists', 'dictionaries', 'sets']
```

```python
print(topics[1:4])
```

Output:

```text
['strings', 'lists', 'dictionaries']
```

The starting index is included.

The ending index is excluded.

---

## Sorting Lists

Sort in place:

```python
scores = [82, 95, 71, 88]

scores.sort()

print(scores)
```

Output:

```text
[71, 82, 88, 95]
```

Sort in reverse:

```python
scores.sort(reverse=True)
```

Create a sorted copy:

```python
sorted_scores = sorted(scores)
```

Difference:

```text
sort()    → changes the original list
sorted()  → creates a sorted result
```

---

# 2. Tuples

A tuple is an ordered collection that cannot be changed after creation.

```python
coordinates = (51.5074, -0.1278)
```

Tuples are:

- Ordered.
- Immutable.
- Indexable.
- Able to contain duplicates.

---

## Accessing Tuples

```python
print(coordinates[0])
print(coordinates[-1])
```

---

## Tuple Immutability

This raises a `TypeError`:

```python
coordinates[0] = 40.7128
```

Use a tuple when values should remain fixed.

Examples:

```python
screen_size = (1920, 1080)
rgb_color = (255, 128, 0)
point = (10, 20)
```

---

## Tuple Unpacking

```python
coordinates = (10, 20)

x, y = coordinates

print(x)
print(y)
```

Another example:

```python
person = ("Ada", 36, "London")

name, age, city = person
```

The number of variables must match the number of values.

---

## One-Item Tuples

A one-item tuple requires a comma:

```python
single_item = ("Python",)
```

This is a string, not a tuple:

```python
not_a_tuple = ("Python")
```

---

# 3. Dictionaries

A dictionary stores key-value pairs.

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

A dictionary is useful when values need labels.

---

## Reading Dictionary Values

```python
print(task["title"])
print(task["completed"])
```

Output:

```text
Learn Python
False
```

A missing key causes a `KeyError`:

```python
print(task["priority"])
```

---

## Adding and Updating Values

Add a key:

```python
task["priority"] = "high"
```

Update a value:

```python
task["completed"] = True
```

Dictionary keys are unique. Assigning to an existing key replaces its value.

---

## Safe Dictionary Lookup

Use `.get()` when a key may be missing:

```python
priority = task.get("priority")
```

Provide a default:

```python
priority = task.get(
    "priority",
    "normal",
)
```

---

## Checking Dictionary Keys

```python
if "title" in task:
    print("Title exists.")
```

```python
if "priority" not in task:
    print("No priority assigned.")
```

To search values:

```python
if "Learn Python" in task.values():
    print("Title found.")
```

---

## Dictionary Methods

Get keys:

```python
task.keys()
```

Get values:

```python
task.values()
```

Get key-value pairs:

```python
task.items()
```

Loop through pairs:

```python
for key, value in task.items():
    print(f"{key}: {value}")
```

---

## Removing Dictionary Values

Remove and return a value:

```python
priority = task.pop("priority")
```

Remove a key:

```python
del task["completed"]
```

Remove all values:

```python
task.clear()
```

Use a default with `pop()` if a key may be missing:

```python
phone = task.pop(
    "phone",
    None,
)
```

---

# 4. Lists of Dictionaries

A common application structure is a list of dictionaries:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
    {
        "id": 2,
        "title": "Build a CLI tool",
        "completed": True,
    },
]
```

The outer list stores multiple tasks.

Each dictionary stores one task.

Access a task:

```python
print(tasks[0])
```

Access a field:

```python
print(tasks[0]["title"])
```

Loop through tasks:

```python
for task in tasks:
    print(task["title"])
```

Display status:

```python
for task in tasks:
    status = "x" if task["completed"] else " "

    print(
        f"[{status}] "
        f"{task['id']} - "
        f"{task['title']}"
    )
```

This is the main structure used by the capstone task manager.

---

# 5. Sets

A set stores unique values.

```python
tags = {
    "python",
    "cli",
    "beginner",
}
```

Duplicate values are automatically removed:

```python
tags = {
    "python",
    "python",
    "cli",
}
```

The set contains one `"python"` value.

Sets are:

- Unique.
- Mutable.
- Not accessed by numeric index.
- Useful for membership checking.

---

## Empty Sets

This creates an empty dictionary:

```python
empty_dictionary = {}
```

This creates an empty set:

```python
empty_set = set()
```

---

## Adding and Removing Set Values

Add:

```python
tags.add("tutorial")
```

Remove and raise an error if missing:

```python
tags.remove("cli")
```

Remove safely if missing:

```python
tags.discard("advanced")
```

Remove everything:

```python
tags.clear()
```

---

## Set Membership

```python
allowed_roles = {
    "admin",
    "editor",
    "viewer",
}

if "editor" in allowed_roles:
    print("Access allowed.")
```

Sets are often efficient for frequent membership checks.

---

# 6. Set Operations

Given:

```python
python_topics = {
    "variables",
    "lists",
    "functions",
}

completed_topics = {
    "variables",
    "lists",
}
```

## Union

Combines values from both sets:

```python
all_topics = (
    python_topics
    | completed_topics
)
```

## Intersection

Finds shared values:

```python
shared_topics = (
    python_topics
    & completed_topics
)
```

Result:

```text
{'variables', 'lists'}
```

## Difference

Finds values in the first set but not the second:

```python
remaining_topics = (
    python_topics
    - completed_topics
)
```

Result:

```text
{'functions'}
```

## Symmetric Difference

Finds values in either set but not both:

```python
different_topics = (
    python_topics
    ^ completed_topics
)
```

---

# 7. Choosing a Collection

Use a **list** when:

- Order matters.
- Values may change.
- Duplicate values are allowed.
- Numeric indexes are useful.

```python
tasks = [
    "Learn Python",
    "Practice loops",
]
```

Use a **tuple** when:

- Values form a fixed group.
- Values should not change.

```python
coordinates = (10, 20)
```

Use a **dictionary** when:

- Values have descriptive names.
- You need lookup by key.
- One object has multiple properties.

```python
user = {
    "name": "Ada",
    "active": True,
}
```

Use a **set** when:

- Values must be unique.
- Order is not important.
- Membership checking is important.

```python
extensions = {
    ".txt",
    ".pdf",
    ".jpg",
}
```

---

# 8. Collection Comparison

| Feature | List | Tuple | Dictionary | Set |
|---|---:|---:|---:|---:|
| Ordered | Yes | Yes | Insertion order | No index order |
| Mutable | Yes | No | Yes | Yes |
| Duplicates | Yes | Yes | Keys no | No |
| Numeric indexing | Yes | Yes | No | No |
| Key-value fields | No | No | Yes | No |
| Membership use | Good | Good | Keys | Excellent |
| Main syntax | `[]` | `()` | `{key: value}` | `{value}` |

---

# 9. Collection Performance

For large collections, sets are generally faster than lists for membership checks:

```python
if value in collection:
    ...
```

Use a set when:

- The collection is large.
- Membership checks happen frequently.
- Order does not matter.

For small collections, clarity is usually more important than minor performance differences.

Dictionaries are useful for direct lookup by key:

```python
users = {
    "ada": "Ada Lovelace",
    "grace": "Grace Hopper",
}

print(users["ada"])
```

---

# 10. Copying Collections

This creates two references to the same list:

```python
original = ["Learn Python"]
copy = original

copy.append("Practice loops")

print(original)
```

Both variables now show the added item.

Use `.copy()`:

```python
original = ["Learn Python"]
copy = original.copy()

copy.append("Practice loops")

print(original)
print(copy)
```

For dictionaries:

```python
copy = original_dictionary.copy()
```

For sets:

```python
copy = original_set.copy()
```

---

# 11. Common Collection Errors

## Missing List Index

```python
tasks = []

print(tasks[0])
```

Raises:

```text
IndexError
```

Check first:

```python
if tasks:
    print(tasks[0])
```

## Missing Dictionary Key

```python
print(task["priority"])
```

Use:

```python
print(task.get("priority", "normal"))
```

## Missing Set Value

```python
tags.remove("missing")
```

Use:

```python
tags.discard("missing")
```

## Empty Set Confusion

```python
{}
```

is an empty dictionary.

```python
set()
```

is an empty set.

---

# 12. Collection Review

## 1. Which collection is ordered and mutable?

```text
____________________________________________________________
```

## 2. Which collection is immutable?

```text
____________________________________________________________
```

## 3. Which collection stores key-value pairs?

```text
____________________________________________________________
```

## 4. Which collection stores unique values?

```text
____________________________________________________________
```

## 5. Why does the task manager use a list of dictionaries?

```text
____________________________________________________________

____________________________________________________________
```

## 6. What does `get()` help prevent?

```text
____________________________________________________________
```

---

# 13. Part 2 Quick Reference

```python
items = []
```

List.

```python
items = ()
```

Tuple.

```python
items = {}
```

Dictionary.

```python
items = set()
```

Set.

Common methods:

```python
list.append(value)
list.remove(value)
list.pop(index)
list.sort()
```

```python
dictionary.get(key, default)
dictionary.keys()
dictionary.values()
dictionary.items()
```

```python
set.add(value)
set.remove(value)
set.discard(value)
```

---

# Part 2 Complete

Key ideas:

```text
Lists store ordered, changeable sequences.
Tuples store fixed ordered groups.
Dictionaries store labeled data.
Sets store unique values.
```

The next section is:

# Student Notes Part 3: Program Flow

It will summarize:

- Comparisons.
- Conditions.
- Logical operators.
- Loops.
- `range()`.
- `enumerate()`.
- `break`.
- `continue`.
- Input validation.

---

# Python Foundations: Student Notes

## Part 3: Program Flow

Program flow controls the order in which instructions execute.

A basic script runs from top to bottom:

```python
print("First")
print("Second")
print("Third")
```

Control flow allows programs to:

- Make decisions.
- Repeat actions.
- Stop loops.
- Skip iterations.
- Validate input.

---

# 1. Comparison Operators

Comparison expressions produce Boolean values:

```python
True
False
```

| Operator | Meaning |
|---|---|
| `==` | Equal to |
| `!=` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

Examples:

```python
print(5 == 5)
print(5 != 3)
print(5 > 3)
print(5 < 3)
print(5 >= 5)
print(5 <= 4)
```

Output:

```text
True
True
True
False
True
False
```

Remember:

```python
=
```

assigns a value:

```python
age = 36
```

```python
==
```

compares values:

```python
age == 36
```

---

# 2. `if` Statements

An `if` statement runs a block when its condition is true.

```python
age = 20

if age >= 18:
    print("You are an adult.")
```

The colon starts the block.

The indented line belongs to the block.

---

# 3. `else`

Use `else` when an alternative should run if the condition is false.

```python
age = 15

if age >= 18:
    print("You are an adult.")
else:
    print("You are not an adult.")
```

Only one branch runs.

---

# 4. `elif`

Use `elif` to test additional conditions.

```python
score = 83

if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
elif score >= 70:
    grade = "C"
else:
    grade = "F"

print(grade)
```

Python checks conditions from top to bottom and stops at the first true condition.

---

# 5. Logical Operators

## `and`

Both conditions must be true:

```python
age = 25
has_ticket = True

if age >= 18 and has_ticket:
    print("Entry allowed.")
```

## `or`

At least one condition must be true:

```python
day = "Saturday"

if day == "Saturday" or day == "Sunday":
    print("Weekend.")
```

## `not`

Reverses a Boolean value:

```python
is_completed = False

if not is_completed:
    print("Task remains incomplete.")
```

---

# 6. Membership Conditions

Use `in` to check whether a value exists in a collection:

```python
valid_commands = {
    "add",
    "list",
    "complete",
    "remove",
}

if "list" in valid_commands:
    print("Recognized command.")
```

Use `not in`:

```python
if "delete" not in valid_commands:
    print("Unknown command.")
```

For dictionaries, `in` checks keys:

```python
task = {
    "title": "Learn Python",
}

if "title" in task:
    print("Title exists.")
```

To check dictionary values:

```python
if "Learn Python" in task.values():
    print("Value exists.")
```

---

# 7. Truthy and Falsy Values

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

Most other values are truthy.

Example:

```python
name = ""

if name:
    print("Name entered.")
else:
    print("Name missing.")
```

Output:

```text
Name missing.
```

This is useful for validating required text:

```python
title = input("Task title: ").strip()

if not title:
    print("Task title cannot be empty.")
```

---

# 8. `for` Loops

A `for` loop processes each item in a collection.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI",
]

for task in tasks:
    print(task)
```

The variable `task` refers to one item during each iteration.

---

# 9. `range()`

`range()` generates a sequence of numbers.

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

The ending value is excluded.

Specify a start and stop:

```python
for number in range(1, 6):
    print(number)
```

Output:

```text
1
2
3
4
5
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

# 10. `enumerate()`

Use `enumerate()` when you need both the position and the value.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI",
]

for index, task in enumerate(tasks):
    print(index, task)
```

Start counting at one:

```python
for number, task in enumerate(
    tasks,
    start=1,
):
    print(f"{number}. {task}")
```

Output:

```text
1. Learn Python
2. Practice loops
3. Build a CLI
```

---

# 11. Looping Through Task Dictionaries

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": True,
    },
    {
        "id": 2,
        "title": "Practice loops",
        "completed": False,
    },
]

for task in tasks:
    status = "x" if task["completed"] else " "

    print(
        f"[{status}] "
        f"{task['id']} - "
        f"{task['title']}"
    )
```

Output:

```text
[x] 1 - Learn Python
[ ] 2 - Practice loops
```

---

# 12. `while` Loops

A `while` loop repeats while a condition remains true.

```python
count = 5

while count > 0:
    print(count)
    count -= 1

print("Finished!")
```

The loop must change something that eventually makes the condition false.

This is an infinite loop:

```python
count = 5

while count > 0:
    print(count)
```

`count` never changes.

Stop an accidental infinite loop with:

```text
Ctrl+C
```

---

# 13. Interactive Menus

A `while` loop is useful for programs that continue until the user quits.

```python
while True:
    print("1. Say hello")
    print("2. Quit")

    choice = input("Choose: ").strip()

    if choice == "1":
        print("Hello.")
    elif choice == "2":
        print("Goodbye.")
        break
    else:
        print("Unknown option.")
```

The loop continues until:

```python
break
```

runs.

---

# 14. `break`

`break` immediately exits the nearest loop.

```python
while True:
    command = input("Command: ").strip()

    if command == "quit":
        break

    print(f"Running: {command}")
```

`break` can be used in both `for` and `while` loops.

---

# 15. `continue`

`continue` skips the rest of the current iteration and starts the next one.

```python
tasks = [
    "Learn Python",
    "",
    "Practice loops",
    "   ",
    "Build a CLI",
]

for task in tasks:
    task = task.strip()

    if not task:
        continue

    print(task)
```

Output:

```text
Learn Python
Practice loops
Build a CLI
```

Difference:

```text
break    → exits the loop
continue → skips this iteration
```

---

# 16. Input Normalization

Normalize input before comparing or validating it:

```python
command = input(
    "Command: "
).strip().lower()
```

Operations:

```python
.strip()
```

removes surrounding whitespace.

```python
.lower()
```

converts letters to lowercase.

These inputs become equivalent:

```text
list
LIST
 List
list 
```

---

# 17. Required Text Validation

```python
title = input(
    "Task title: "
).strip()

if not title:
    print("Task title cannot be empty.")
else:
    print(f"Accepted: {title}")
```

Whitespace-only input is rejected because `.strip()` converts it to an empty string.

---

# 18. Numeric Input Validation

User input is text, so convert it carefully.

Simple validation:

```python
age_text = input(
    "Enter your age: "
).strip()

if age_text.isdigit():
    age = int(age_text)
    print(f"Age: {age}")
else:
    print("Please enter a whole number.")
```

`.isdigit()` accepts strings such as:

```text
42
100
```

It does not accept:

```text
-1
3.14
hello
```

For more flexible validation, use `try` and `except` in Part 4.

---

# 19. Range Validation

A value can be numeric but still invalid for the application.

```python
age_text = input(
    "Enter your age: "
).strip()

if not age_text.isdigit():
    print("Please enter a whole number.")
else:
    age = int(age_text)

    if age < 0 or age > 120:
        print(
            "Enter an age between 0 and 120."
        )
    else:
        print(f"Accepted age: {age}")
```

---

# 20. Repeated Validation

Ask again until the input is valid:

```python
while True:
    age_text = input(
        "Enter your age: "
    ).strip()

    if not age_text.isdigit():
        print("Please enter a whole number.")
        continue

    age = int(age_text)

    if age < 0 or age > 120:
        print(
            "Enter an age between 0 and 120."
        )
        continue

    print(f"Accepted age: {age}")
    break
```

Flow:

```text
Ask for input
    ↓
Validate type
    ↓
Validate range
    ↓
Repeat if invalid
    ↓
Continue if valid
```

---

# 21. Program Flow Example

A task-completion operation may follow this flow:

```text
Read task ID
    ↓
Validate task ID
    ↓
Loop through tasks
    ↓
Compare each ID
    ↓
Update matching task
    ↓
Display success
```

If no matching task is found:

```text
Display an error
```

---

# 22. Common Control-Flow Errors

## Missing Colon

Incorrect:

```python
if age >= 18
```

Correct:

```python
if age >= 18:
```

## Missing Indentation

Incorrect:

```python
if ready:
print("Ready")
```

Correct:

```python
if ready:
    print("Ready")
```

## Infinite Loop

Incorrect:

```python
count = 0

while count < 3:
    print(count)
```

Correct:

```python
count = 0

while count < 3:
    print(count)
    count += 1
```

## Wrong Comparison Operator

Incorrect:

```python
if age = 18:
```

Correct:

```python
if age == 18:
```

---

# 23. Interactive Task Manager Flow

The menu structure:

```text
while program is running:
    display menu
    read choice

    if choice is list:
        display tasks
    elif choice is add:
        validate and add task
    elif choice is complete:
        validate ID and complete task
    elif choice is remove:
        validate ID and remove task
    elif choice is quit:
        stop program
    else:
        display invalid-choice message
```

This is the foundation of the later command-line application.

---

# 24. Program Flow Review

## 1. What does `if` do?

```text
____________________________________________________________
```

## 2. What does `elif` do?

```text
____________________________________________________________
```

## 3. What does `and` require?

```text
____________________________________________________________
```

## 4. What does a `for` loop do?

```text
____________________________________________________________
```

## 5. What does a `while` loop do?

```text
____________________________________________________________
```

## 6. What does `break` do?

```text
____________________________________________________________
```

## 7. What does `continue` do?

```text
____________________________________________________________
```

## 8. Why should user input be validated?

```text
____________________________________________________________

____________________________________________________________
```

---

# 25. Part 3 Quick Reference

## Conditions

```python
if condition:
    ...
elif another_condition:
    ...
else:
    ...
```

## Logical Operators

```python
condition_a and condition_b
condition_a or condition_b
not condition
```

## For Loop

```python
for item in collection:
    ...
```

## While Loop

```python
while condition:
    ...
```

## Exit a Loop

```python
break
```

## Skip an Iteration

```python
continue
```

## Number Sequence

```python
range(start, stop, step)
```

## Numbered Items

```python
enumerate(items, start=1)
```

---

# Part 3 Complete

Key ideas:

```text
Conditions make decisions.
For loops process collections.
While loops repeat while a condition is true.
Break exits a loop.
Continue skips an iteration.
Validation protects programs from unexpected input.
```

The next section is:

# Student Notes Part 4: Functions, Files, JSON, and Exceptions

It will summarize:

- Functions.
- Parameters.
- Return values.
- Scope.
- Modules.
- Text files.
- `pathlib`.
- JSON.
- Exceptions.
- Persistent storage.

---

# Python Foundations: Student Notes

## Part 4: Functions, Files, JSON, and Exceptions

This section summarizes the concepts needed to move from small scripts to reusable, persistent applications.

The main topics are:

```text
Functions
Modules
Text files
pathlib
JSON
Exceptions
Persistent storage
```

---

# 1. Functions

A function is a named, reusable block of code.

Define a function:

```python
def show_welcome():
    print("Welcome to Python.")
```

Call it:

```python
show_welcome()
```

A function does not run merely because it is defined. It runs when called.

---

# 2. Parameters and Arguments

A parameter is listed in a function definition:

```python
def greet(name):
    print(f"Hello, {name}!")
```

An argument is supplied when calling the function:

```python
greet("Ada")
```

Here:

```text
name → parameter
"Ada" → argument
```

Multiple parameters:

```python
def describe_person(name, age, city):
    print(
        f"{name} is {age} years old "
        f"and lives in {city}."
    )
```

Call:

```python
describe_person(
    "Ada",
    36,
    "London",
)
```

---

# 3. Keyword Arguments

Arguments can be passed by name:

```python
describe_person(
    name="Ada",
    age=36,
    city="London",
)
```

Keyword arguments improve readability and can be supplied in a different order.

---

# 4. Return Values

Use `return` to send a result back to the caller.

```python
def add(first, second):
    return first + second


result = add(2, 3)

print(result)
```

Output:

```text
5
```

A return value can be reused:

```python
total = calculate_total(
    price,
    quantity,
)

tax = total * 0.20
grand_total = total + tax
```

A function that returns a value is often more flexible than one that only prints.

---

# 5. Returning Booleans

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

Use the result in a condition:

```python
if is_even(number):
    print("Even")
else:
    print("Odd")
```

---

# 6. Default Parameters

A default parameter is used when the caller omits an argument.

```python
def greet(
    name,
    greeting="Hello",
):
    return f"{greeting}, {name}!"
```

Calls:

```python
greet("Ada")
```

```python
greet("Grace", "Welcome")
```

Required parameters must come before default parameters.

---

# 7. Type Hints

Type hints document expected types.

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

A function that does not return a meaningful value can use:

```python
def show_message(message: str) -> None:
    print(message)
```

Type hints improve readability and editor support, but do not automatically enforce types at runtime.

---

# 8. Scope

Scope determines where a variable can be used.

A variable created inside a function is local:

```python
def create_message():
    message = "Hello"
    print(message)
```

This variable is not automatically available outside the function.

Return it:

```python
def create_message():
    return "Hello"


message = create_message()
print(message)
```

Prefer passing dependencies explicitly:

```python
def show_name(name):
    print(name)


show_name("Ada")
```

This is clearer than relying on global variables.

---

# 9. The `main()` Pattern

A common Python script structure is:

```python
def main() -> None:
    print("Program started.")


if __name__ == "__main__":
    main()
```

This means:

- Run `main()` when the file is executed directly.
- Do not automatically run `main()` when the file is imported.

This pattern is especially useful in modules.

---

# 10. Modules

A module is a Python file containing reusable code.

`calculations.py`:

```python
def add(first, second):
    return first + second
```

Another file:

```python
from calculations import add

print(add(2, 3))
```

Import an entire module:

```python
import calculations

print(calculations.add(2, 3))
```

Use relative imports inside a package:

```python
from .tasks import create_task
```

---

# 11. Function Responsibilities

Good functions usually have focused responsibilities.

Examples:

```python
display_tasks()
find_task()
create_task()
load_tasks()
save_tasks()
```

A function named `load_tasks()` should load tasks. It should not also:

- Display menus.
- Ask for input.
- Move files.
- Complete tasks.
- Print unrelated output.

Focused functions are easier to test and maintain.

---

# 12. Text Files

Open a file safely with a context manager:

```python
with open(
    "notes.txt",
    "r",
    encoding="utf-8",
) as file:
    contents = file.read()
```

The `with` statement closes the file after the block.

---

# 13. File Modes

| Mode | Meaning |
|---|---|
| `"r"` | Read |
| `"w"` | Write and replace |
| `"a"` | Append |
| `"x"` | Create, failing if the file exists |

Write:

```python
with open(
    "notes.txt",
    "w",
    encoding="utf-8",
) as file:
    file.write("First note\n")
```

Append:

```python
with open(
    "notes.txt",
    "a",
    encoding="utf-8",
) as file:
    file.write("Another note\n")
```

---

# 14. Reading Lines

Read all contents:

```python
contents = file.read()
```

Loop through lines:

```python
with open(
    "notes.txt",
    "r",
    encoding="utf-8",
) as file:
    for line in file:
        print(line.strip())
```

The `.strip()` call removes surrounding whitespace and newline characters.

---

# 15. `pathlib`

Import `Path`:

```python
from pathlib import Path
```

Create a path:

```python
file_path = Path("data") / "tasks.json"
```

Check whether it exists:

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

---

# 16. Reading and Writing with `Path`

Write text:

```python
file_path.write_text(
    "Hello\n",
    encoding="utf-8",
)
```

Read text:

```python
contents = file_path.read_text(
    encoding="utf-8",
)
```

Use `/` to combine paths:

```python
data_file = (
    Path("data")
    / "tasks.json"
)
```

This is more portable than manually joining strings.

---

# 17. Path Information

Given:

```python
file_path = Path(
    "documents/report.txt"
)
```

Properties:

```python
file_path.name
```

returns:

```text
report.txt
```

```python
file_path.stem
```

returns:

```text
report
```

```python
file_path.suffix
```

returns:

```text
.txt
```

```python
file_path.parent
```

returns:

```text
documents
```

---

# 18. Directory Traversal

List direct contents:

```python
directory = Path("downloads")

for item in directory.iterdir():
    print(item)
```

Identify files:

```python
for item in directory.iterdir():
    if item.is_file():
        print(f"File: {item}")
```

Identify directories:

```python
if item.is_dir():
    print(f"Directory: {item}")
```

Find matching files:

```python
for file_path in directory.glob("*.py"):
    print(file_path)
```

Search recursively:

```python
for file_path in directory.rglob("*.py"):
    print(file_path)
```

---

# 19. JSON

JSON is a structured text format.

Python:

```python
task = {
    "id": 1,
    "title": "Learn JSON",
    "completed": False,
}
```

JSON:

```json
{
  "id": 1,
  "title": "Learn JSON",
  "completed": false
}
```

Differences:

```text
Python True  → JSON true
Python False → JSON false
Python None  → JSON null
```

---

# 20. Writing JSON

```python
import json
from pathlib import Path


tasks = [
    {
        "id": 1,
        "title": "Learn JSON",
        "completed": False,
    }
]

file_path = Path("tasks.json")

with file_path.open(
    "w",
    encoding="utf-8",
) as file:
    json.dump(
        tasks,
        file,
        indent=2,
    )
```

The result is readable JSON.

---

# 21. Reading JSON

```python
with file_path.open(
    "r",
    encoding="utf-8",
) as file:
    tasks = json.load(file)
```

The JSON array becomes a Python list.

The JSON objects become Python dictionaries.

---

# 22. JSON String Functions

`json.dumps()` converts Python data to a JSON string:

```python
json_text = json.dumps(
    task,
    indent=2,
)
```

`json.loads()` converts a JSON string into Python data:

```python
task = json.loads(json_text)
```

Comparison:

| Function | Input | Output |
|---|---|---|
| `json.dump()` | Python data and file | Writes JSON |
| `json.dumps()` | Python data | JSON string |
| `json.load()` | File | Python data |
| `json.loads()` | JSON string | Python data |

---

# 23. Exceptions

An exception is a runtime problem event.

Basic structure:

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

---

# 24. Common Exceptions

| Exception | Typical cause |
|---|---|
| `ValueError` | Invalid value conversion |
| `TypeError` | Incompatible types |
| `KeyError` | Missing dictionary key |
| `IndexError` | Invalid list index |
| `FileNotFoundError` | Missing file |
| `PermissionError` | Access denied |
| `JSONDecodeError` | Malformed JSON |
| `ZeroDivisionError` | Division by zero |
| `ModuleNotFoundError` | Missing import |

---

# 25. Specific Exception Handling

Prefer specific exceptions:

```python
try:
    number = int(value)
except ValueError:
    print("Please enter an integer.")
```

For files:

```python
try:
    contents = file_path.read_text(
        encoding="utf-8",
    )
except FileNotFoundError:
    print("The file does not exist.")
except PermissionError:
    print("Permission denied.")
```

Avoid hiding problems with:

```python
except Exception:
    print("Something went wrong.")
```

Broad handlers can hide programming errors.

---

# 26. Handling Missing JSON Files

A task manager may start with an empty list if its data file does not exist:

```python
def load_tasks(file_path):
    if not file_path.exists():
        return []

    ...
```

This is appropriate for a first run.

---

# 27. Handling Invalid JSON

```python
import json

try:
    with file_path.open(
        "r",
        encoding="utf-8",
    ) as file:
        data = json.load(file)
except FileNotFoundError:
    data = []
except json.JSONDecodeError:
    print("Invalid JSON.")
    data = []
```

A corrupted data file should not cause an unexplained crash.

---

# 28. Validate Data Shape

Valid JSON does not guarantee valid task data.

Check the root value:

```python
if not isinstance(data, list):
    raise ValueError(
        "Task data must be a list."
    )
```

Check task fields:

```python
required_keys = {
    "id",
    "title",
    "completed",
}

if not required_keys.issubset(task):
    raise ValueError(
        "Task is missing required fields."
    )
```

---

# 29. Persistent Task Manager Data Flow

```text
Program starts
        ↓
Load tasks.json
        ↓
Store tasks in memory
        ↓
User changes tasks
        ↓
Save updated tasks.json
```

Task structure:

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

---

# 30. Persistent Task Manager Functions

Typical functions:

```python
load_tasks()
save_tasks()
display_task()
list_tasks()
get_next_id()
find_task()
add_task()
complete_task()
remove_task()
show_statistics()
```

Each function should have a focused role.

---

# 31. Part 4 Review

## 1. What does `return` do?

```text
____________________________________________________________
```

## 2. What does `pathlib` provide?

```text
____________________________________________________________
```

## 3. What is the difference between `json.load()` and `json.loads()`?

```text
____________________________________________________________
```

## 4. What exception represents malformed JSON?

```text
____________________________________________________________
```

## 5. Why should task data be validated after loading?

```text
____________________________________________________________

____________________________________________________________
```

## 6. Why is a context manager useful when opening files?

```text
____________________________________________________________
```

---

# Part 4 Complete

Key ideas:

```text
Functions organize reusable behavior.
Modules divide code into files.
Pathlib handles paths.
JSON persists structured data.
Exceptions handle expected failures.
Validation protects the application.
```

The next section is:

# Student Notes Part 5: Capstone Architecture and CLI

It will summarize:

- Project structure.
- `pyproject.toml`.
- Packages.
- `argparse`.
- CLI subcommands.
- Task logic.
- Storage.
- File organization.
- Application layers.
  
---

# Python Foundations: Student Notes

## Part 5: Capstone Architecture and CLI

The capstone transforms the earlier task manager into a structured multi-utility command-line application.

The application supports commands such as:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
python -m foundation_cli organize downloads
```

---

# 1. Capstone Project Structure

Recommended structure:

```text
python-foundations/
├── README.md
├── pyproject.toml
├── data/
│   └── tasks.json
├── src/
│   └── foundation_cli/
│       ├── __init__.py
│       ├── __main__.py
│       ├── cli.py
│       ├── errors.py
│       ├── organizer.py
│       ├── storage.py
│       └── tasks.py
└── tests/
    ├── test_organizer.py
    ├── test_storage.py
    └── test_tasks.py
```

---

# 2. Directory Responsibilities

| Location | Responsibility |
|---|---|
| `src/foundation_cli/` | Application source code |
| `data/` | Persistent data |
| `tests/` | Automated tests |
| `README.md` | Documentation |
| `pyproject.toml` | Project metadata and packaging |

---

# 3. `__init__.py`

The package initializer identifies the package and can store metadata:

```python
"""Foundation CLI application."""

__version__ = "0.1.0"
```

---

# 4. `__main__.py`

This file enables:

```bash
python -m foundation_cli
```

Contents:

```python
from .cli import main


if __name__ == "__main__":
    main()
```

---

# 5. `pyproject.toml`

A basic project configuration:

```toml
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "foundation-cli"
version = "0.1.0"
description = "A beginner-friendly command-line application"
readme = "README.md"
requires-python = ">=3.10"
dependencies = []

[project.scripts]
foundation = "foundation_cli.cli:main"

[tool.setuptools.packages.find]
where = ["src"]
```

Install the project in editable mode:

```bash
python -m pip install --editable .
```

---

# 6. Running the Package

Run the package:

```bash
python -m foundation_cli
```

Display help:

```bash
python -m foundation_cli --help
```

Display the version:

```bash
python -m foundation_cli --version
```

The editable installation means source changes are used immediately.

---

# 7. CLI with `argparse`

Import:

```python
import argparse
```

Create a parser:

```python
parser = argparse.ArgumentParser(
    prog="foundation",
    description=(
        "A multi-utility command-line application."
    ),
)
```

Add a version option:

```python
parser.add_argument(
    "--version",
    action="version",
    version="foundation 0.1.0",
)
```

Parse arguments:

```python
arguments = parser.parse_args()
```

---

# 8. CLI Subcommands

Create subparsers:

```python
subparsers = parser.add_subparsers(
    dest="command",
)
```

Add a command:

```python
add_parser = subparsers.add_parser(
    "add",
    help="Create a new task.",
)
```

Add a required positional argument:

```python
add_parser.add_argument(
    "title",
    help="The title of the task.",
)
```

The resulting command is:

```bash
python -m foundation_cli add "Learn Python"
```

---

# 9. Capstone Commands

## Add

```bash
python -m foundation_cli add "Learn Python"
```

## List

```bash
python -m foundation_cli list
```

## Complete

```bash
python -m foundation_cli complete 1
```

## Remove

```bash
python -m foundation_cli remove 1
```

## Statistics

```bash
python -m foundation_cli stats
```

## Organize

```bash
python -m foundation_cli organize downloads
```

## Organize Preview

```bash
python -m foundation_cli organize downloads --dry-run
```

---

# 10. Command Dispatch

After parsing:

```python
if arguments.command == "add":
    handle_add(arguments.title)
elif arguments.command == "list":
    handle_list()
elif arguments.command == "complete":
    handle_complete(arguments.task_id)
elif arguments.command == "remove":
    handle_remove(arguments.task_id)
elif arguments.command == "stats":
    handle_stats()
elif arguments.command == "organize":
    handle_organize(
        arguments.directory,
        arguments.dry_run,
    )
```

A separate dispatcher keeps `main()` easier to read:

```python
def handle_command(arguments):
    ...
```

---

# 11. Task Layer

The task layer contains task rules.

Typical functions:

```python
create_task()
get_next_id()
find_task()
require_task()
complete_task()
remove_task()
count_completed()
count_incomplete()
```

Example:

```python
def create_task(
    tasks,
    title,
):
    cleaned_title = title.strip()

    if not cleaned_title:
        raise InvalidTaskTitleError(
            "Task title cannot be empty."
        )

    task = {
        "id": get_next_id(tasks),
        "title": cleaned_title,
        "completed": False,
    }

    tasks.append(task)

    return task
```

The task layer should not parse command-line arguments or open JSON files.

---

# 12. Task IDs

Generate the first ID:

```python
if not tasks:
    return 1
```

Generate the next ID:

```python
return max(
    task["id"]
    for task in tasks
) + 1
```

If existing IDs are:

```text
1, 2, 5
```

the next ID is:

```text
6
```

---

# 13. Finding Tasks

```python
def find_task(
    tasks,
    task_id,
):
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None
```

Use the result safely:

```python
task = find_task(tasks, task_id)

if task is None:
    print("Task not found.")
else:
    print(task["title"])
```

---

# 14. Completing Tasks

```python
def complete_task(
    tasks,
    task_id,
):
    task = require_task(
        tasks,
        task_id,
    )

    if task["completed"]:
        raise TaskAlreadyCompletedError(
            f"Task {task_id} is already completed."
        )

    task["completed"] = True

    return task
```

Display:

```text
[x] 1 - Learn Python
```

---

# 15. Removing Tasks

```python
def remove_task(
    tasks,
    task_id,
):
    task = require_task(
        tasks,
        task_id,
    )

    tasks.remove(task)

    return task
```

The caller should save the updated list after removal.

---

# 16. Statistics

Count completed tasks:

```python
completed = sum(
    1 for task in tasks
    if task["completed"]
)
```

Count total tasks:

```python
total = len(tasks)
```

Count incomplete tasks:

```python
incomplete = total - completed
```

Display:

```text
Total tasks: 3
Completed tasks: 2
Incomplete tasks: 1
```

---

# 17. Storage Layer

The storage layer manages JSON.

Typical functions:

```python
load_tasks()
save_tasks()
validate_task()
```

Data flow:

```text
tasks.json
    ↓
load_tasks()
    ↓
Python list of dictionaries
    ↓
Application changes
    ↓
save_tasks()
    ↓
tasks.json
```

---

# 18. Data File Path

A stable path can be constructed with:

```python
from pathlib import Path


PROJECT_ROOT = (
    Path(__file__)
    .resolve()
    .parents[2]
)

DATA_FILE = (
    PROJECT_ROOT
    / "data"
    / "tasks.json"
)
```

This avoids depending on the terminal's current directory.

---

# 19. Loading Tasks

```python
def load_tasks(file_path):
    if not file_path.exists():
        return []

    with file_path.open(
        "r",
        encoding="utf-8",
    ) as file:
        data = json.load(file)

    if not isinstance(data, list):
        raise ValueError(
            "Task data must be a list."
        )

    return data
```

A production version should also handle:

- Invalid JSON.
- File permissions.
- Invalid task fields.
- Unexpected file-system errors.

---

# 20. Saving Tasks

```python
def save_tasks(
    tasks,
    file_path,
):
    file_path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with file_path.open(
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            tasks,
            file,
            indent=2,
        )
        file.write("\n")
```

The parent directory is created automatically if necessary.

---

# 21. Custom Exceptions

`errors.py`:

```python
class FoundationError(Exception):
    """Base application error."""


class TaskNotFoundError(FoundationError):
    """Raised when a task does not exist."""


class TaskAlreadyCompletedError(FoundationError):
    """Raised when a task is already complete."""


class InvalidTaskTitleError(FoundationError):
    """Raised for an invalid title."""
```

Handle expected errors in the CLI:

```python
try:
    handle_command(arguments)
except FoundationError as error:
    print(f"Error: {error}")
```

---

# 22. Positive Integer Validation

Use a custom parser function:

```python
def positive_integer(value: str) -> int:
    try:
        number = int(value)
    except ValueError as error:
        raise argparse.ArgumentTypeError(
            "must be a whole number"
        ) from error

    if number < 1:
        raise argparse.ArgumentTypeError(
            "must be greater than zero"
        )

    return number
```

Use it:

```python
complete_parser.add_argument(
    "task_id",
    type=positive_integer,
)
```

---

# 23. File Organizer

The organizer uses:

```python
from pathlib import Path
import shutil
```

Determine an extension folder:

```python
def extension_folder(file_path):
    suffix = (
        file_path.suffix
        .lower()
        .lstrip(".")
    )

    return suffix or "no_extension"
```

Examples:

| File | Folder |
|---|---|
| `report.pdf` | `pdf` |
| `photo.JPG` | `jpg` |
| `README` | `no_extension` |

---

# 24. File Move Planning

A move can be represented with a data class:

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class FileMove:
    source: Path
    destination: Path
```

Planning first allows:

- Dry-run previews.
- Testing without changes.
- Review before execution.
- Safer operations.

---

# 25. Dry-Run Mode

Command:

```bash
python -m foundation_cli organize downloads --dry-run
```

The program displays:

```text
report.pdf -> downloads/pdf/report.pdf
```

but does not move the file.

Implementation idea:

```python
if dry_run:
    continue
```

Only perform:

```python
shutil.move(...)
```

when `dry_run` is false.

---

# 26. Duplicate Protection

If a destination already exists, generate another name:

```python
report.pdf
report_1.pdf
report_2.pdf
```

Example:

```python
candidate = destination.with_name(
    f"{destination.stem}_{counter}"
    f"{destination.suffix}"
)
```

Never overwrite existing user files without explicit permission.

---

# 27. CLI and Application Layers

Application flow:

```text
Command-line input
        ↓
argparse
        ↓
CLI handler
        ↓
Task or organizer logic
        ↓
Storage or file system
        ↓
Terminal output
```

Responsibilities:

| Layer | Responsibility |
|---|---|
| CLI | Parse commands and display output |
| Tasks | Apply task rules |
| Storage | Read and write JSON |
| Organizer | Move files |
| Errors | Define expected application errors |

---

# 28. Capstone Verification Commands

```bash
python -m foundation_cli --help
```

```bash
python -m foundation_cli --version
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
python -m foundation_cli stats
```

```bash
python -m foundation_cli organize downloads --dry-run
```

```bash
python -m unittest discover -s tests -v
```

---

# 29. Part 5 Review

## 1. What does `pyproject.toml` describe?

```text
____________________________________________________________
```

## 2. What does `__main__.py` enable?

```text
____________________________________________________________
```

## 3. What does `argparse` do?

```text
____________________________________________________________
```

## 4. Where should task rules be stored?

```text
____________________________________________________________
```

## 5. Where should JSON file operations be stored?

```text
____________________________________________________________
```

## 6. What does `--dry-run` do?

```text
____________________________________________________________
```

## 7. Why should duplicate files not be overwritten?

```text
____________________________________________________________
```

---

# Part 5 Complete

Key ideas:

```text
The CLI parses commands.
The task layer applies task rules.
The storage layer manages JSON.
The organizer manages files.
Custom exceptions represent expected failures.
Tests verify behavior.
```

The next section is:

# Student Notes Part 6: Testing, Debugging, and Reference

It will summarize:

- Unit tests.
- Temporary directories.
- Test assertions.
- Tracebacks.
- Debugging workflows.
- Common errors.
- Final commands.

---

# Python Foundations: Student Notes

## Part 6: Testing, Debugging, and Reference

This section summarizes the final skills needed to verify and maintain the capstone application.

Topics:

```text
Automated tests
Temporary directories
Assertions
Tracebacks
Debugging
Common errors
CLI reference
Project checklist
```

---

# 1. Automated Tests

Automated tests are repeatable checks that verify program behavior.

Run the full test suite:

```bash
python -m unittest discover -s tests -v
```

Expected final output:

```text
OK
```

A test usually:

1. Creates known input.
2. Calls code.
3. Checks the result.
4. Reports success or failure.

---

# 2. `unittest`

Basic test:

```python
import unittest


class BasicTests(unittest.TestCase):
    def test_addition(self):
        result = 2 + 3

        self.assertEqual(
            result,
            5,
        )


if __name__ == "__main__":
    unittest.main()
```

Test files commonly begin with:

```text
test_
```

Examples:

```text
test_tasks.py
test_storage.py
test_organizer.py
```

---

# 3. Common Assertions

```python
self.assertEqual(actual, expected)
```

Checks equality.

```python
self.assertNotEqual(actual, expected)
```

Checks inequality.

```python
self.assertTrue(value)
```

Checks truthiness.

```python
self.assertFalse(value)
```

Checks falsiness.

```python
self.assertIsNone(value)
```

Checks for `None`.

```python
self.assertIsNotNone(value)
```

Checks that a value is not `None`.

```python
with self.assertRaises(ValueError):
    operation()
```

Checks that an operation raises a specific exception.

---

# 4. Task Tests

Test task creation:

```python
def test_create_task(self):
    tasks = []

    task = create_task(
        tasks,
        "Learn Python",
    )

    self.assertEqual(task["id"], 1)
    self.assertFalse(task["completed"])
```

Test empty titles:

```python
def test_empty_title(self):
    tasks = []

    with self.assertRaises(
        InvalidTaskTitleError
    ):
        create_task(tasks, "")
```

Test completion:

```python
def test_complete_task(self):
    tasks = [
        {
            "id": 1,
            "title": "Learn Python",
            "completed": False,
        }
    ]

    complete_task(tasks, 1)

    self.assertTrue(
        tasks[0]["completed"]
    )
```

---

# 5. Temporary Directories

Use temporary directories for file tests:

```python
import tempfile
from pathlib import Path


with tempfile.TemporaryDirectory() as directory:
    file_path = (
        Path(directory)
        / "tasks.json"
    )

    file_path.write_text(
        "[]",
        encoding="utf-8",
    )
```

The directory is removed automatically after the block.

Benefits:

- Tests do not alter real project data.
- Tests are isolated.
- Tests can run repeatedly.
- Cleanup is automatic.

---

# 6. Storage Tests

Test a missing file:

```python
def test_missing_file(self):
    with tempfile.TemporaryDirectory() as directory:
        file_path = (
            Path(directory)
            / "missing.json"
        )

        tasks = load_tasks(file_path)

        self.assertEqual(tasks, [])
```

Test saving and loading:

```python
def test_save_and_load(self):
    expected_tasks = [
        {
            "id": 1,
            "title": "Learn JSON",
            "completed": False,
        }
    ]

    with tempfile.TemporaryDirectory() as directory:
        file_path = (
            Path(directory)
            / "tasks.json"
        )

        save_tasks(
            expected_tasks,
            file_path,
        )

        actual_tasks = load_tasks(file_path)

        self.assertEqual(
            actual_tasks,
            expected_tasks,
        )
```

Test invalid JSON:

```python
with self.assertRaises(ValueError):
    load_tasks(file_path)
```

---

# 7. Organizer Tests

Test extension handling:

```python
self.assertEqual(
    extension_folder(
        Path("PHOTO.JPG")
    ),
    "jpg",
)
```

Test no extension:

```python
self.assertEqual(
    extension_folder(
        Path("README")
    ),
    "no_extension",
)
```

Test dry-run:

```python
moved_count = execute_moves(
    moves,
    dry_run=True,
)

self.assertEqual(
    moved_count,
    0,
)
```

Test actual movement:

```python
moved_count = execute_moves(moves)

self.assertEqual(
    moved_count,
    1,
)
```

---

# 8. Test Success and Failure

Test successful behavior:

```text
Add a valid task.
Complete an existing task.
Load valid JSON.
Move a valid file.
```

Test failures:

```text
Empty task title.
Missing task ID.
Already-completed task.
Invalid JSON.
Missing file.
Missing directory.
Duplicate destination.
```

Both successful and unsuccessful behavior are part of the application contract.

---

# 9. Reading Tracebacks

Example:

```text
Traceback (most recent call last):
  File "main.py", line 10, in <module>
    print(tasks[3])
IndexError: list index out of range
```

Read from the bottom:

```text
IndexError: list index out of range
```

Then inspect:

```text
main.py, line 10
```

Then inspect:

```python
print(tasks[3])
```

Check:

```python
print(tasks)
print(len(tasks))
```

---

# 10. Inspecting Values

Use:

```python
print(value)
```

Inspect the type:

```python
print(type(value))
```

Reveal whitespace and special characters:

```python
print(repr(value))
```

Example:

```python
task_id = input("ID: ")

print(repr(task_id))
print(type(task_id))
```

If the user enters `1`, the result may be:

```text
'1'
<class 'str'>
```

Convert it:

```python
task_id = int(task_id)
```

---

# 11. Minimal Reproduction

If a large program fails, reduce it to a small example.

Example:

```python
stored_id = 1
entered_id = "1"

print(stored_id == entered_id)
print(type(stored_id))
print(type(entered_id))
```

Output:

```text
False
<class 'int'>
<class 'str'>
```

The reduced example reveals the type mismatch.

---

# 12. Debugging Process

Use this sequence:

```text
Describe expected behavior
        ↓
Describe actual behavior
        ↓
Read the error
        ↓
Identify the failing line
        ↓
Inspect values and types
        ↓
Reduce the problem
        ↓
Make one change
        ↓
Run again
        ↓
Run tests
        ↓
Record the solution
```

Avoid changing many unrelated parts at once.

---

# 13. Common Errors

## `SyntaxError`

Python cannot understand the code structure.

Common causes:

- Missing colon.
- Missing quotation mark.
- Missing parenthesis.
- Invalid assignment.

## `IndentationError`

The indentation is missing or inconsistent.

## `NameError`

A variable or function name is undefined or misspelled.

## `TypeError`

An operation uses incompatible types.

## `ValueError`

A value has invalid content.

Example:

```python
int("hello")
```

## `IndexError`

A list or tuple index does not exist.

## `KeyError`

A dictionary key does not exist.

## `FileNotFoundError`

A requested file does not exist.

## `ModuleNotFoundError`

Python cannot find an imported module.

## `JSONDecodeError`

JSON data is malformed.

---

# 14. Common Error Fixes

## Missing Dictionary Key

Risky:

```python
priority = task["priority"]
```

Safer:

```python
priority = task.get(
    "priority",
    "normal",
)
```

## Invalid Integer Conversion

Risky:

```python
number = int(user_input)
```

Safer:

```python
try:
    number = int(user_input)
except ValueError:
    print("Invalid number.")
```

## Empty List Access

Risky:

```python
print(tasks[0])
```

Safer:

```python
if tasks:
    print(tasks[0])
else:
    print("No tasks.")
```

## Missing File

Safer:

```python
if not file_path.exists():
    return []
```

---

# 15. CLI Command Reference

Show help:

```bash
python -m foundation_cli --help
```

Show version:

```bash
python -m foundation_cli --version
```

Add a task:

```bash
python -m foundation_cli add "Learn Python"
```

List tasks:

```bash
python -m foundation_cli list
```

Complete a task:

```bash
python -m foundation_cli complete 1
```

Remove a task:

```bash
python -m foundation_cli remove 1
```

Display statistics:

```bash
python -m foundation_cli stats
```

Preview organization:

```bash
python -m foundation_cli organize downloads --dry-run
```

Organize files:

```bash
python -m foundation_cli organize downloads
```

Run tests:

```bash
python -m unittest discover -s tests -v
```

Validate JSON:

```bash
python -m json.tool data/tasks.json
```

---

# 16. Final Project Structure

```text
python-foundations/
├── README.md
├── pyproject.toml
├── data/
│   └── tasks.json
├── src/
│   └── foundation_cli/
│       ├── __init__.py
│       ├── __main__.py
│       ├── cli.py
│       ├── errors.py
│       ├── organizer.py
│       ├── storage.py
│       └── tasks.py
└── tests/
    ├── test_organizer.py
    ├── test_storage.py
    └── test_tasks.py
```

---

# 17. Final Architecture

```text
CLI layer
    ↓
Application logic
    ↓
Storage or file-system operations
    ↓
Persistent data or moved files
```

Module roles:

```text
cli.py
    Commands, arguments, output

tasks.py
    Task rules and operations

storage.py
    JSON loading and saving

organizer.py
    File classification and movement

errors.py
    Expected application errors

tests/
    Automated verification
```

---

# 18. Final Verification Checklist

## Environment

- [ ] Python version checked.
- [ ] Virtual environment active.
- [ ] Correct interpreter selected.
- [ ] Project installed in editable mode.

## CLI

- [ ] Help works.
- [ ] Version works.
- [ ] Commands appear in help.
- [ ] Invalid arguments are rejected.
- [ ] Error messages are readable.

## Tasks

- [ ] Tasks can be added.
- [ ] Empty titles are rejected.
- [ ] Tasks can be listed.
- [ ] Tasks can be completed.
- [ ] Duplicate completion is rejected.
- [ ] Tasks can be removed.
- [ ] Missing IDs are handled.
- [ ] Statistics are accurate.
- [ ] Tasks persist after restarting.

## Storage

- [ ] Missing data files are handled.
- [ ] Valid JSON loads successfully.
- [ ] Invalid JSON is reported.
- [ ] Task structure is validated.
- [ ] Data directories are created if needed.

## Organizer

- [ ] Extensions are normalized.
- [ ] Files are grouped correctly.
- [ ] Files without extensions are supported.
- [ ] Dry-run mode works.
- [ ] Duplicate names are protected.
- [ ] Missing directories are handled.
- [ ] File paths are rejected when a directory is expected.

## Testing

- [ ] Task tests pass.
- [ ] Storage tests pass.
- [ ] Organizer tests pass.
- [ ] Temporary directories are used.
- [ ] The complete suite ends with `OK`.

---

# 19. Student Notes Complete

You have completed the full Student Notes series:

```text
Part 1: Environment and Basic Syntax
Part 2: Collections
Part 3: Program Flow
Part 4: Functions, Files, JSON, and Exceptions
Part 5: Capstone Architecture and CLI
Part 6: Testing, Debugging, and Reference
```

The complete development process is:

```text
Set up the environment
        ↓
Learn the syntax
        ↓
Choose data structures
        ↓
Control program flow
        ↓
Create functions
        ↓
Read and write files
        ↓
Persist JSON data
        ↓
Handle exceptions
        ↓
Build the CLI
        ↓
Test and debug
        ↓
Improve the application
```
