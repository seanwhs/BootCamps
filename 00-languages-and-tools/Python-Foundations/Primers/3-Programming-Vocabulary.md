# Primer 3: Programming Vocabulary

This primer introduces the words used throughout **Python Foundations: From Zero to Functional Code**.

Programming becomes easier when the terminology is familiar. These words describe the parts of a program, the actions it performs, and the problems that can occur.

---

# 1. Program

A **program** is a set of instructions that tells a computer what to do.

Example:

```python
name = "Ada"
print(f"Hello, {name}!")
```

This program:

1. Stores a name.
2. Creates a message.
3. Displays the message.

---

# 2. Script

A **script** is a program, usually saved in a file, that performs a task.

Example:

```text
greeting.py
```

A Python script may be run with:

```bash
python greeting.py
```

The terms *program* and *script* are sometimes used interchangeably. A script often suggests a smaller program used for automation or a specific task.

---

# 3. Source Code

**Source code** is the human-readable code written by a programmer.

Example:

```python
total = price * quantity
```

This is source code because a person can read and modify it.

Python reads the source code when you run the program.

---

# 4. Interpreter

An **interpreter** is a program that reads and executes source code.

When you run:

```bash
python hello.py
```

the Python interpreter:

1. Opens `hello.py`.
2. Checks the code.
3. Executes the instructions.
4. Displays output or reports an error.

---

# 5. Syntax

**Syntax** is the set of structural rules for writing valid code.

Valid Python:

```python
if age >= 18:
    print("Adult")
```

Invalid Python:

```python
if age >= 18
    print("Adult")
```

The invalid version is missing a colon.

Syntax is similar to grammar in a spoken language. If the structure is incorrect, Python cannot understand the instruction.

---

# 6. Statement

A **statement** is an instruction that performs an action.

Examples:

```python
name = "Ada"
```

```python
print(name)
```

```python
return total
```

```python
tasks.append(task)
```

A program is made of statements that Python executes.

---

# 7. Expression

An **expression** is code that produces a value.

Examples:

```python
2 + 3
```

```python
price * quantity
```

```python
name.upper()
```

```python
task["title"]
```

Expressions can be used inside statements:

```python
total = price * quantity
```

Here:

```python
price * quantity
```

is an expression.

---

# 8. Value

A **value** is a piece of data used by a program.

Examples:

```python
"Ada"
36
3.14
True
None
```

Values can be stored in variables:

```python
name = "Ada"
```

They can also be returned from functions:

```python
return total
```

---

# 9. Variable

A **variable** is a name that refers to a value.

```python
age = 36
```

The variable is:

```text
age
```

The value is:

```text
36
```

Variables allow programs to store information while they run.

---

# 10. Assignment

**Assignment** stores a value under a variable name.

```python
name = "Ada"
```

The single equals sign:

```python
=
```

is the assignment operator.

It does not ask whether two values are equal.

---

# 11. Comparison

A **comparison** checks the relationship between values.

```python
age == 36
```

Common comparison operators:

| Operator | Meaning |
|---|---|
| `==` | Equal to |
| `!=` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

Comparisons produce Boolean values:

```python
print(5 > 3)
```

Output:

```text
True
```

---

# 12. Data Type

A **data type** describes the kind of value being used.

Common Python types include:

| Type | Example | Purpose |
|---|---|---|
| `str` | `"Hello"` | Text |
| `int` | `42` | Whole numbers |
| `float` | `3.14` | Decimal numbers |
| `bool` | `True` | True/false values |
| `list` | `[1, 2, 3]` | Ordered changeable collection |
| `tuple` | `(1, 2, 3)` | Fixed ordered collection |
| `dict` | `{"name": "Ada"}` | Key-value data |
| `set` | `{"python", "cli"}` | Unique values |

---

# 13. String

A **string** is text.

```python
message = "Hello, Python!"
```

Strings can be:

- Combined.
- Sliced.
- Searched.
- Converted to lowercase or uppercase.
- Formatted with f-strings.

Example:

```python
name = "Ada"

print(f"Hello, {name}!")
```

---

# 14. Integer

An **integer** is a whole number.

```python
age = 36
count = -2
```

Integers support arithmetic:

```python
total = 5 + 3
```

---

# 15. Float

A **float** is a number with a decimal component.

```python
price = 19.99
height = 1.65
```

Format floats with f-strings:

```python
print(f"${price:.2f}")
```

Output:

```text
$19.99
```

---

# 16. Boolean

A **Boolean** represents one of two values:

```python
True
False
```

Example:

```python
is_completed = False
```

Booleans are commonly used in conditions:

```python
if is_completed:
    print("Done")
```

---

# 17. Collection

A **collection** stores multiple values.

Python's main built-in collection types are:

```python
list
tuple
dict
set
```

Examples:

```python
tasks = ["Learn Python", "Practice loops"]
```

```python
coordinates = (10, 20)
```

```python
task = {
    "title": "Learn Python",
    "completed": False,
}
```

```python
tags = {"python", "cli"}
```

---

# 18. Mutable

**Mutable** means that an object can be changed after creation.

Lists are mutable:

```python
tasks = ["Learn Python"]

tasks.append("Practice loops")
```

Dictionaries are mutable:

```python
task = {"completed": False}

task["completed"] = True
```

Sets are mutable:

```python
tags = {"python"}

tags.add("cli")
```

---

# 19. Immutable

**Immutable** means that an object cannot be changed after creation.

Tuples are immutable:

```python
coordinates = (10, 20)
```

This causes an error:

```python
coordinates[0] = 15
```

Strings are also immutable. Methods such as `.upper()` return a new string:

```python
name = "ada"
uppercase_name = name.upper()
```

The original `name` remains unchanged.

---

# 20. Function

A **function** is a named, reusable block of code.

```python
def greet(name):
    return f"Hello, {name}!"
```

Call it:

```python
message = greet("Ada")
```

Functions help divide a program into focused operations.

---

# 21. Parameter

A **parameter** is a variable listed in a function definition.

```python
def greet(name):
    ...
```

Here:

```text
name
```

is the parameter.

---

# 22. Argument

An **argument** is a value passed to a function when it is called.

```python
greet("Ada")
```

Here:

```text
"Ada"
```

is the argument.

Comparison:

```text
Parameter → name
Argument  → "Ada"
```

---

# 23. Return Value

A **return value** is the result sent from a function back to its caller.

```python
def add(first, second):
    return first + second
```

The calling code can store the result:

```python
result = add(2, 3)
```

A function can return:

- A string.
- A number.
- A Boolean.
- A list.
- A dictionary.
- `None`.

---

# 24. Scope

**Scope** describes where a variable can be accessed.

A variable created inside a function is usually local:

```python
def create_message():
    message = "Hello"
    print(message)
```

The variable is available inside the function but not automatically outside it.

Return the value when it needs to be used elsewhere:

```python
def create_message():
    return "Hello"


message = create_message()
```

---

# 25. Module

A **module** is a Python file containing reusable code.

Example:

```text
calculations.py
```

```python
def add(first, second):
    return first + second
```

Another file can import the function:

```python
from calculations import add
```

Modules help organize larger programs.

---

# 26. Package

A **package** is a directory containing related Python modules.

Example:

```text
foundation_cli/
├── __init__.py
├── __main__.py
├── cli.py
├── tasks.py
└── storage.py
```

The directory groups related application code.

---

# 27. Argument

The word **argument** can have two meanings in programming:

1. A value passed to a function.
2. A value passed to a command-line program.

Function argument:

```python
greet("Ada")
```

Command-line argument:

```bash
python -m foundation_cli complete 1
```

Here:

```text
complete
1
```

are command-line arguments.

---

# 28. Command-Line Interface

A **command-line interface**, or CLI, is a program controlled by typed terminal commands.

Examples include:

```text
git
python
docker
npm
```

The capstone CLI uses commands such as:

```bash
python -m foundation_cli list
```

A CLI usually includes:

- Commands.
- Arguments.
- Options.
- Help text.
- Error messages.
- Exit behavior.

---

# 29. Option or Flag

An option is an optional command-line argument that usually begins with a dash.

Example:

```bash
python -m foundation_cli organize downloads --dry-run
```

Here:

```text
--dry-run
```

is an option or flag.

A Boolean flag is usually either present or absent.

---

# 30. File Path

A **file path** identifies the location of a file or directory.

Relative path:

```python
Path("data") / "tasks.json"
```

Absolute path:

```text
/home/user/python-foundations/data/tasks.json
```

Python's `pathlib` module provides objects for working with paths.

---

# 31. Serialization

**Serialization** converts program data into a format that can be stored or transferred.

Example:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]
```

Writing it as JSON is serialization:

```python
json.dump(tasks, file, indent=2)
```

---

# 32. Deserialization

**Deserialization** converts stored data back into program data.

```python
tasks = json.load(file)
```

The JSON text becomes Python lists and dictionaries.

---

# 33. Exception

An **exception** is a runtime event indicating that an operation could not complete normally.

Examples:

```python
ValueError
```

```python
FileNotFoundError
```

```python
KeyError
```

```python
JSONDecodeError
```

Exceptions can be handled:

```python
try:
    number = int(value)
except ValueError:
    print("Invalid number.")
```

---

# 34. Error

An **error** is a problem that prevents code from behaving as intended.

Common categories include:

## Syntax Error

Python cannot understand the code.

## Runtime Error

A problem occurs while the program runs.

## Logic Error

The program runs but produces an incorrect result.

---

# 35. Bug

A **bug** is an unintended problem in a program.

Example:

```python
total = price + quantity
```

If the intended operation is multiplication, this is a logic bug.

The code may run successfully, but the result is wrong.

---

# 36. Traceback

A **traceback** is Python's report showing where an exception occurred.

It may include:

- File names.
- Line numbers.
- Function calls.
- The final exception type.
- The error message.

Read tracebacks from the bottom upward.

---

# 37. Debugging

**Debugging** is the process of finding and fixing problems.

A useful debugging process is:

```text
Describe expected behavior
        ↓
Observe actual behavior
        ↓
Read the error
        ↓
Inspect values and types
        ↓
Create a smaller example
        ↓
Change one thing
        ↓
Test again
```

---

# 38. Validation

**Validation** checks whether input is acceptable before using it.

Example:

```python
title = input("Title: ").strip()

if not title:
    print("Title cannot be empty.")
```

Validation is important for:

- User input.
- Command-line arguments.
- JSON files.
- File paths.
- Configuration data.

---

# 39. Persistence

**Persistence** means data survives after a program closes.

Without persistence:

```python
tasks = []
```

the tasks disappear when the program exits.

With persistence:

```text
data/tasks.json
```

the program can load the tasks when it starts again.

---

# 40. Test

A **test** is a repeatable check that code behaves as expected.

Example:

```python
self.assertEqual(
    add(2, 3),
    5,
)
```

Tests can check:

- Successful results.
- Expected exceptions.
- File behavior.
- Input validation.
- Edge cases.

---

# 41. Unit Test

A **unit test** tests a small unit of code, usually a function.

Example:

```python
def test_create_task(self):
    tasks = []

    task = create_task(
        tasks,
        "Learn Python",
    )

    self.assertEqual(task["id"], 1)
```

The test focuses on one behavior.

---

# 42. Regression Test

A **regression test** protects against a previously fixed bug returning.

Example:

```python
def test_empty_title_is_rejected(self):
    tasks = []

    with self.assertRaises(
        InvalidTaskTitleError
    ):
        create_task(tasks, "")
```

If a later change allows empty titles again, this test should fail.

---

# 43. Dry Run

A **dry run** previews an operation without performing it.

Example:

```bash
python -m foundation_cli organize downloads --dry-run
```

The program displays planned moves but leaves files unchanged.

Dry runs are useful for risky operations such as:

- Moving files.
- Deleting data.
- Renaming files.
- Applying batch changes.

---

# 44. Data Model

A **data model** describes the shape of application data.

The task model is:

```python
{
    "id": int,
    "title": str,
    "completed": bool,
}
```

A clear data model helps functions know what to expect.

---

# 45. Separation of Responsibilities

Separation of responsibilities means giving different parts of the program different jobs.

The capstone uses:

```text
cli.py
    Command-line parsing and output

tasks.py
    Task rules

storage.py
    JSON loading and saving

organizer.py
    File organization

errors.py
    Application-specific exceptions
```

This makes the project easier to understand and change.

---

# 46. Primer 3 Practice Exercise

Match each term to its description.

| Term | Description |
|---|---|
| Variable | ______________________________ |
| Function | ______________________________ |
| Parameter | ______________________________ |
| Argument | ______________________________ |
| Module | _______________________________ |
| Exception | _____________________________ |
| Debugging | ____________________________ |
| Persistence | __________________________ |

Possible descriptions:

```text
A reusable named block of code
A name referring to a value
A value passed to a function
A variable in a function definition
A Python file containing reusable code
A runtime problem event
Finding and fixing program problems
Data surviving after the program closes
```

---

# 47. Primer 3 Review Questions

## Question 1

What is the difference between a program and a script?

```text
____________________________________________________________

____________________________________________________________
```

## Question 2

What is the difference between a parameter and an argument?

```text
____________________________________________________________
```

## Question 3

What is the difference between an exception and a bug?

```text
____________________________________________________________

____________________________________________________________
```

## Question 4

What is the purpose of a module?

```text
____________________________________________________________
```

## Question 5

What does persistence mean?

```text
____________________________________________________________
```

## Question 6

What is a dry run?

```text
____________________________________________________________
```

## Question 7

Why is separation of responsibilities useful?

```text
____________________________________________________________

____________________________________________________________
```

---

# 48. Primer 3 Readiness Checklist

Before beginning Part 1, confirm that you can:

- [ ] Explain what a program is.
- [ ] Explain what a script is.
- [ ] Define source code.
- [ ] Define interpreter.
- [ ] Explain syntax.
- [ ] Identify a statement.
- [ ] Identify an expression.
- [ ] Explain variables.
- [ ] Explain data types.
- [ ] Define a function.
- [ ] Distinguish parameters and arguments.
- [ ] Explain return values.
- [ ] Explain local scope.
- [ ] Define a module.
- [ ] Define a package.
- [ ] Explain a CLI.
- [ ] Define an exception.
- [ ] Define a bug.
- [ ] Explain debugging.
- [ ] Explain persistence.
- [ ] Explain a unit test.
- [ ] Explain a dry run.
- [ ] Explain separation of responsibilities.

---

# Primer 3 Complete

You now understand the basic vocabulary used throughout the series.
