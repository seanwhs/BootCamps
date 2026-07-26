# Python Foundations Quiz Bank

This quiz bank covers the complete **Python Foundations: From Zero to Functional Code** series.

To avoid cutting off the material, it is divided into sections:

```text
Quiz Bank Part 1: Environment, Syntax, and Collections
Quiz Bank Part 2: Control Flow, Functions, Files, JSON, and Exceptions
Quiz Bank Part 3: Capstone, Testing, Debugging, and Final Assessment
```

This is **Part 1**, with questions covering:

- Python setup.
- Virtual environments.
- Basic syntax.
- Variables.
- Data types.
- Strings.
- Type conversion.
- Lists.
- Tuples.
- Dictionaries.
- Sets.

---

# Quiz Bank Part 1: Foundations and Collections

## Instructions

Unless otherwise stated:

- Choose one answer.
- Assume Python 3.10 or newer.
- Code questions should be answered based on normal Python behavior.
- Answer keys appear after the questions.

---

# Section A: Python Environment

## Question 1

Which command checks the installed Python version?

A. `python check`

B. `python --version`

C. `python install`

D. `python version()`

---

## Question 2

What is a virtual environment?

A. A text editor for Python

B. An isolated Python workspace for a project

C. A replacement for the Python interpreter

D. A directory containing only Python source files

---

## Question 3

Which command creates a virtual environment named `.venv`?

A. `python create .venv`

B. `python -m venv .venv`

C. `python install venv`

D. `venv create python`

---

## Question 4

Which command activates a virtual environment on macOS or Linux?

A. `.venv\Scripts\activate`

B. `activate .venv`

C. `source .venv/bin/activate`

D. `python activate .venv`

---

## Question 5

Which command deactivates a virtual environment?

A. `stop`

B. `exit-env`

C. `deactivate`

D. `python -m deactivate`

---

## Question 6

Which command runs a Python file named `hello.py`?

A. `run hello.py`

B. `python hello.py`

C. `execute python hello.py`

D. `python --file hello.py`

---

## Question 7

What does the Python interactive shell display while waiting for input?

A. `>>>`

B. `###`

C. `...`

D. `python>`

---

# Section B: Basic Syntax and Types

## Question 8

What does this statement do?

```python
age = 36
```

A. Compares `age` with `36`

B. Stores `36` in the variable `age`

C. Converts `age` to a string

D. Prints `36`

---

## Question 9

Which operator compares two values for equality?

A. `=`

B. `==`

C. `:=`

D. `equals`

---

## Question 10

What type is `"42"`?

A. `int`

B. `float`

C. `str`

D. `bool`

---

## Question 11

What type is `42`?

A. `str`

B. `int`

C. `float`

D. `number`

---

## Question 12

What type is `42.0`?

A. `int`

B. `str`

C. `float`

D. `decimal`

---

## Question 13

Which values are valid Python Boolean literals?

A. `true` and `false`

B. `TRUE` and `FALSE`

C. `True` and `False`

D. `"True"` and `"False"`

---

## Question 14

What is printed?

```python
first = "Ada"
last = "Lovelace"

print(first + " " + last)
```

A. `AdaLovelace`

B. `Ada Lovelace`

C. `first last`

D. An error

---

## Question 15

What is printed?

```python
name = "Ada"
age = 36

print(f"{name} is {age}.")
```

A. `{name} is {age}.`

B. `name is age`

C. `Ada is 36.`

D. An error

---

## Question 16

What does `input()` return?

A. Always an integer

B. Always a float

C. Always a string

D. The type specified by the user

---

## Question 17

What does this code produce?

```python
number = int("42")
print(number + 1)
```

A. `421`

B. `43`

C. `"421"`

D. A `TypeError`

---

## Question 18

What error occurs here?

```python
age = "36"
print(age + 1)
```

A. `NameError`

B. `IndexError`

C. `TypeError`

D. `FileNotFoundError`

---

## Question 19

What does `.strip()` generally do to a string?

A. Converts it to lowercase

B. Removes surrounding whitespace

C. Removes all letters

D. Converts it to an integer

---

## Question 20

What does this expression produce?

```python
5 % 2
```

A. `0`

B. `1`

C. `2.5`

D. `10`

---

## Question 21

What does this expression produce?

```python
5 // 2
```

A. `2`

B. `2.5`

C. `3`

D. `1`

---

## Question 22

What is the purpose of indentation in Python?

A. It is optional formatting.

B. It defines blocks of related code.

C. It converts code to comments.

D. It separates variables from values.

---

# Section C: Lists

## Question 23

Which syntax creates a list?

A. `{1, 2, 3}`

B. `(1, 2, 3)`

C. `[1, 2, 3]`

D. `<1, 2, 3>`

---

## Question 24

What is the first index of a Python list?

A. `-1`

B. `0`

C. `1`

D. It depends on the list

---

## Question 25

What is printed?

```python
items = ["a", "b", "c"]

print(items[0])
```

A. `a`

B. `b`

C. `c`

D. An error

---

## Question 26

What is printed?

```python
items = ["a", "b", "c"]

print(items[-1])
```

A. `a`

B. `b`

C. `c`

D. An error

---

## Question 27

Which method adds one item to the end of a list?

A. `add()`

B. `append()`

C. `insert_end()`

D. `push_item()`

---

## Question 28

What does this code do?

```python
tasks = ["Learn Python", "Practice loops"]
tasks.append("Build a CLI")
```

A. Replaces the list

B. Adds `"Build a CLI"` to the end

C. Adds a nested list

D. Removes the final task

---

## Question 29

Which method removes an item by value?

A. `remove()`

B. `delete_value()`

C. `erase()`

D. `clear_one()`

---

## Question 30

Which method removes and returns an item by index?

A. `remove()`

B. `pop()`

C. `delete()`

D. `take()`

---

## Question 31

What is printed?

```python
numbers = [0, 1, 2, 3, 4]

print(numbers[1:4])
```

A. `[0, 1, 2]`

B. `[1, 2, 3]`

C. `[1, 2, 3, 4]`

D. `[0, 1, 2, 3]`

---

## Question 32

What does `len(items)` return?

A. The final index

B. The number of items

C. The memory size

D. The type of the list

---

## Question 33

What is the difference between `sort()` and `sorted()`?

A. They are completely unrelated.

B. `sort()` changes the list; `sorted()` creates a sorted result.

C. `sorted()` changes the list; `sort()` creates a copy.

D. Both always return tuples.

---

# Section D: Tuples

## Question 34

Which syntax creates a tuple?

A. `[1, 2, 3]`

B. `(1, 2, 3)`

C. `{1, 2, 3}`

D. `<1, 2, 3>`

---

## Question 35

What does immutable mean?

A. The collection cannot contain numbers.

B. The collection cannot be changed after creation.

C. The collection cannot be printed.

D. The collection cannot contain duplicate values.

---

## Question 36

What happens here?

```python
coordinates = (10, 20)
coordinates[0] = 15
```

A. The tuple becomes `(15, 20)`

B. The tuple becomes a list

C. A `TypeError` occurs

D. Nothing happens

---

## Question 37

What is tuple unpacking?

```python
coordinates = (10, 20)
x, y = coordinates
```

A. Removing tuple items

B. Assigning tuple values to separate variables

C. Converting a tuple to a set

D. Sorting a tuple

---

# Section E: Dictionaries

## Question 38

Which collection stores key-value pairs?

A. List

B. Tuple

C. Dictionary

D. Set

---

## Question 39

What is printed?

```python
task = {
    "title": "Learn Python",
    "completed": False,
}

print(task["title"])
```

A. `title`

B. `Learn Python`

C. `False`

D. An error

---

## Question 40

How do you safely read a possibly missing dictionary key?

A. `dictionary.safe()`

B. `dictionary.get()`

C. `dictionary.read()`

D. `dictionary.optional()`

---

## Question 41

What is printed?

```python
task = {
    "title": "Learn Python",
}

print(task.get("priority", "normal"))
```

A. `priority`

B. `None`

C. `normal`

D. A `KeyError`

---

## Question 42

What happens when you assign a value to an existing dictionary key?

```python
task = {"completed": False}
task["completed"] = True
```

A. A duplicate key is created

B. The original value is replaced

C. The dictionary becomes a list

D. A `TypeError` occurs

---

## Question 43

Which method returns dictionary key-value pairs?

A. `values()`

B. `keys()`

C. `items()`

D. `pairs()`

---

## Question 44

What is a common structure for multiple task records?

A. A tuple of strings

B. A list of dictionaries

C. A set of integers

D. A dictionary of Booleans only

---

# Section F: Sets

## Question 45

What is a primary property of a set?

A. It allows duplicate values.

B. It stores only strings.

C. It stores unique values.

D. It always preserves numeric indexes.

---

## Question 46

How do you create an empty set?

A. `{}`

B. `[]`

C. `()`

D. `set()`

---

## Question 47

What happens here?

```python
tags = {"python", "python", "cli"}
```

A. The program raises an error.

B. The set contains two `"python"` values.

C. The duplicate `"python"` is kept only once.

D. The set becomes a list.

---

## Question 48

Which method removes a set value without raising an error when the value is missing?

A. `remove()`

B. `discard()`

C. `delete()`

D. `ignore_remove()`

---

## Question 49

What does the `&` operator do with sets?

A. Union

B. Difference

C. Intersection

D. Sorting

---

## Question 50

When is a set usually more appropriate than a list?

A. When order and indexes are essential

B. When duplicate values are meaningful

C. When unique values and membership checks matter

D. When values must remain immutable

---

# Answer Key

## Section A: Python Environment

| Question | Answer | Explanation |
|---:|:---:|---|
| 1 | B | `python --version` displays the installed version. |
| 2 | B | A virtual environment isolates a project's Python workspace. |
| 3 | B | `python -m venv .venv` creates the environment. |
| 4 | C | `source .venv/bin/activate` is used on macOS/Linux. |
| 5 | C | `deactivate` exits the active virtual environment. |
| 6 | B | `python hello.py` runs the file. |
| 7 | A | `>>>` is the standard interactive prompt. |

---

## Section B: Basic Syntax and Types

| Question | Answer | Explanation |
|---:|:---:|---|
| 8 | B | The statement assigns `36` to `age`. |
| 9 | B | `==` compares values for equality. |
| 10 | C | Quoted text is a string. |
| 11 | B | `42` is an integer. |
| 12 | C | `42.0` is a float. |
| 13 | C | Python uses `True` and `False`. |
| 14 | B | The strings are combined with a space. |
| 15 | C | The f-string inserts the variable values. |
| 16 | C | `input()` always returns a string. |
| 17 | B | `"42"` is converted to `42`, then `1` is added. |
| 18 | C | Python cannot add an integer directly to a string. |
| 19 | B | `.strip()` removes surrounding whitespace. |
| 20 | B | `%` returns the remainder: `1`. |
| 21 | A | `//` performs floor division: `2`. |
| 22 | B | Indentation defines code blocks. |

---

## Section C: Lists

| Question | Answer | Explanation |
|---:|:---:|---|
| 23 | C | Lists use square brackets. |
| 24 | B | Python uses zero-based indexing. |
| 25 | A | Index `0` refers to `"a"`. |
| 26 | C | Index `-1` refers to the final item. |
| 27 | B | `append()` adds one item to the end. |
| 28 | B | The new string is appended to the list. |
| 29 | A | `remove()` removes by value. |
| 30 | B | `pop()` removes and returns an item. |
| 31 | B | The start is included and the end is excluded. |
| 32 | B | `len()` returns the number of items. |
| 33 | B | `sort()` changes the list; `sorted()` returns a sorted result. |

---

## Section D: Tuples

| Question | Answer | Explanation |
|---:|:---:|---|
| 34 | B | Tuples use parentheses. |
| 35 | B | Immutable means the value cannot be changed after creation. |
| 36 | C | Tuple item assignment raises `TypeError`. |
| 37 | B | Unpacking assigns tuple values to separate variables. |

---

## Section E: Dictionaries

| Question | Answer | Explanation |
|---:|:---:|---|
| 38 | C | Dictionaries store key-value pairs. |
| 39 | B | The `"title"` key maps to `"Learn Python"`. |
| 40 | B | `.get()` safely reads a potentially missing key. |
| 41 | C | `"normal"` is used as the default value. |
| 42 | B | Assigning to an existing key replaces its value. |
| 43 | C | `.items()` returns key-value pairs. |
| 44 | B | Multiple records are commonly stored as a list of dictionaries. |

---

## Section F: Sets

| Question | Answer | Explanation |
|---:|:---:|---|
| 45 | C | Sets store unique values. |
| 46 | D | `{}` creates an empty dictionary; `set()` creates an empty set. |
| 47 | C | Duplicate set values are automatically removed. |
| 48 | B | `discard()` does nothing if the value is absent. |
| 49 | C | `&` performs set intersection. |
| 50 | C | Sets are useful for uniqueness and membership checks. |

---

# Short-Answer Review

Answer these without looking at the key.

## Question 51

Explain the difference between:

```python
=
```

and:

```python
==
```

Answer:

```text
____________________________________________________________

____________________________________________________________
```

---

## Question 52

Why does this fail?

```python
age = "36"
print(age + 1)
```

Answer:

```text
____________________________________________________________

____________________________________________________________
```

---

## Question 53

Why is a list of dictionaries useful for a task manager?

Answer:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

## Question 54

When should you use a tuple instead of a list?

Answer:

```text
____________________________________________________________

____________________________________________________________
```

---

## Question 55

When should you use a set instead of a list?

Answer:

```text
____________________________________________________________

____________________________________________________________
```

---

# Practical Coding Questions

## Question 56

Write code that creates a list of three tasks and prints the final task.

Answer:

```python
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

## Question 57

Write code that safely reads a task priority with a default of `"normal"`.

Answer:

```python
____________________________________________________________

____________________________________________________________
```

---

## Question 58

Write code that removes duplicate words from a list.

Answer:

```python
____________________________________________________________

____________________________________________________________
```

---

## Question 59

Write code that creates a task dictionary with:

- ID `1`.
- Title `"Learn Python"`.
- Completion status `False`.

Answer:

```python
____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

## Question 60

Write code that displays a completed task as:

```text
[x] 1 - Learn Python
```

Answer:

```python
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Practical Coding Answer Key

## Question 56

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI",
]

print(tasks[-1])
```

---

## Question 57

```python
priority = task.get(
    "priority",
    "normal",
)
```

---

## Question 58

```python
words = [
    "python",
    "code",
    "python",
]

unique_words = set(words)

print(unique_words)
```

---

## Question 59

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

---

## Question 60

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": True,
}

status = "x" if task["completed"] else " "

print(
    f"[{status}] "
    f"{task['id']} - "
    f"{task['title']}"
)
```

---

# Part 1 Scoring Guide

| Score | Interpretation |
|---:|---|
| 54–60 | Excellent foundation |
| 45–53 | Strong understanding |
| 36–44 | Developing understanding |
| 0–35 | Review Parts 1 and 2 |

For the multiple-choice section, award one point per correct answer.

For short-answer and coding questions, assess:

- Correctness.
- Appropriate collection choice.
- Clear naming.
- Proper syntax.
- Ability to explain the decision.

---

# Next Section

The next quiz-bank section is:

# Quiz Bank Part 2: Control Flow, Functions, Files, JSON, and Exceptions

It will cover:

- `if`, `elif`, and `else`.
- Logical operators.
- `for` and `while` loops.
- `break` and `continue`.
- Functions.
- Parameters and returns.
- Modules.
- Files.
- JSON.
- Exception handling.
  
---

# Python Foundations Quiz Bank — Part 2

This section covers:

- Conditions.
- Logical operators.
- Loops.
- Input validation.
- Functions.
- Scope.
- Modules.
- Text files.
- `pathlib`.
- JSON.
- Exceptions.

---

# Section A: Conditions and Logical Operators

## Question 1

What does an `if` statement do?

A. Repeats code indefinitely.

B. Runs code only when a condition is true.

C. Defines a function.

D. Creates a list.

---

## Question 2

What is printed?

```python
age = 20

if age >= 18:
    print("Adult")
else:
    print("Minor")
```

A. `Adult`

B. `Minor`

C. `True`

D. Nothing

---

## Question 3

Which keyword checks another condition after an `if` condition is false?

A. `otherwise`

B. `elif`

C. `elseif`

D. `next`

---

## Question 4

What does `and` require?

A. At least one condition to be true.

B. Both conditions to be true.

C. Both conditions to be false.

D. The conditions to be strings.

---

## Question 5

What is printed?

```python
age = 20
has_ticket = True

if age >= 18 and has_ticket:
    print("Allowed")
else:
    print("Denied")
```

A. `Allowed`

B. `Denied`

C. `True`

D. An error

---

## Question 6

What does `or` mean?

A. Every condition must be true.

B. At least one condition must be true.

C. Every condition must be false.

D. It compares strings only.

---

## Question 7

What does `not` do?

A. Removes a variable.

B. Reverses a Boolean condition.

C. Ends a loop.

D. Converts text to a Boolean.

---

## Question 8

What is printed?

```python
is_completed = False

if not is_completed:
    print("Still incomplete")
```

A. `Still incomplete`

B. Nothing

C. `False`

D. An error

---

## Question 9

What does this check?

```python
if "python" in tags:
```

A. Whether `tags` is a string.

B. Whether `"python"` is present in `tags`.

C. Whether `"python"` should be removed.

D. Whether `tags` is empty.

---

## Question 10

What is printed?

```python
name = ""

if name:
    print("Name entered")
else:
    print("Name missing")
```

A. `Name entered`

B. `Name missing`

C. An empty line

D. A `ValueError`

---

# Section B: Loops

## Question 11

What does a `for` loop usually do?

A. Processes items in an iterable.

B. Defines a dictionary.

C. Handles exceptions.

D. Creates a virtual environment.

---

## Question 12

What is printed?

```python
for number in range(3):
    print(number)
```

A.

```text
1
2
3
```

B.

```text
0
1
2
```

C.

```text
0
1
2
3
```

D. Nothing

---

## Question 13

What values does `range(1, 5)` generate?

A. `1, 2, 3, 4`

B. `0, 1, 2, 3, 4`

C. `1, 2, 3, 4, 5`

D. `2, 3, 4, 5`

---

## Question 14

What is printed?

```python
tasks = ["Learn", "Practice"]

for task in tasks:
    print(task)
```

A. The list object only

B. Each task on a separate line

C. The indexes only

D. An error

---

## Question 15

What does `enumerate()` provide?

A. Only values.

B. Only indexes.

C. Both an index and a value.

D. A sorted list.

---

## Question 16

What is printed?

```python
tasks = ["Learn", "Practice"]

for number, task in enumerate(tasks, start=1):
    print(f"{number}. {task}")
```

A.

```text
0. Learn
1. Practice
```

B.

```text
1. Learn
2. Practice
```

C.

```text
Learn
Practice
```

D. An error

---

## Question 17

What does a `while` loop do?

A. Repeats while its condition is true.

B. Runs exactly once.

C. Sorts a collection.

D. Reads a JSON file.

---

## Question 18

What is wrong with this loop?

```python
count = 3

while count > 0:
    print(count)
```

A. The condition is invalid.

B. `count` never changes, so the loop may be infinite.

C. `print()` cannot be used in loops.

D. `while` requires a list.

---

## Question 19

What does `break` do?

A. Skips one iteration.

B. Exits the nearest loop.

C. Restarts the loop.

D. Pauses the program.

---

## Question 20

What does `continue` do?

A. Exits the program.

B. Exits the loop permanently.

C. Skips the current iteration and continues with the next.

D. Repeats the current iteration forever.

---

# Section C: Input Validation

## Question 21

What type does `input()` return?

A. `int`

B. `float`

C. `str`

D. It depends on the input

---

## Question 22

Which expression converts text to an integer?

A. `number(text)`

B. `integer(text)`

C. `int(text)`

D. `text.integer()`

---

## Question 23

What does this check?

```python
if not title.strip():
```

A. Whether the title contains numbers.

B. Whether the title is empty or whitespace-only.

C. Whether the title is uppercase.

D. Whether the title is a list.

---

## Question 24

What does `.isdigit()` generally check?

A. Whether a string contains only digit characters.

B. Whether a number is negative.

C. Whether a string contains decimal punctuation.

D. Whether a value is a Boolean.

---

## Question 25

Why should user input be validated?

A. Users always enter invalid data.

B. To prevent unexpected input from causing incorrect behavior or crashes.

C. Validation makes Python faster.

D. It removes the need for functions.

---

# Section D: Functions

## Question 26

Which keyword defines a function?

A. `function`

B. `define`

C. `def`

D. `func`

---

## Question 27

What is a parameter?

A. A value returned by a function.

B. A variable listed in a function definition.

C. An error message.

D. A file path.

---

## Question 28

What is an argument?

A. A value passed to a function call.

B. A variable that exists only in a loop.

C. A Python package.

D. A Boolean operator.

---

## Question 29

What is printed?

```python
def greet(name):
    return f"Hello, {name}!"


message = greet("Ada")
print(message)
```

A. `name`

B. `Hello, Ada!`

C. `None`

D. An error

---

## Question 30

What does `return` do?

A. Repeats a function.

B. Sends a value back to the caller.

C. Prints a value automatically.

D. Stops Python permanently.

---

## Question 31

What is printed?

```python
def add(first, second):
    return first + second


result = add(2, 3)
print(result)
```

A. `2`

B. `3`

C. `5`

D. `23`

---

## Question 32

What does a default parameter provide?

A. A value used when the caller does not provide that argument.

B. A value that cannot be changed.

C. An automatic exception handler.

D. A required argument.

---

## Question 33

What does this annotation mean?

```python
def greet(name: str) -> str:
```

A. The function accepts and returns strings as intended types.

B. The function can only be called once.

C. The function converts everything to strings automatically.

D. The function cannot return a value.

---

## Question 34

What is local scope?

A. A variable that can be used only inside its function or block context.

B. A variable saved in JSON.

C. A variable available everywhere.

D. A command-line argument.

---

## Question 35

Why is this pattern useful?

```python
if __name__ == "__main__":
    main()
```

A. It prevents functions from being defined.

B. It runs the main behavior when the file is executed directly.

C. It converts a file to JSON.

D. It activates a virtual environment.

---

# Section E: Modules and Files

## Question 36

What is a Python module?

A. A Python file containing reusable code.

B. A virtual environment.

C. A JSON object.

D. A terminal command.

---

## Question 37

Which statement imports `add` from `calculations.py`?

A. `include calculations.add`

B. `from calculations import add`

C. `load calculations.add`

D. `use calculations add`

---

## Question 38

What does file mode `"w"` generally do?

A. Reads a file.

B. Appends to a file.

C. Writes and replaces existing contents.

D. Creates only directories.

---

## Question 39

What does file mode `"a"` generally do?

A. Appends to existing contents.

B. Deletes the file.

C. Reads only the first line.

D. Runs a Python module.

---

## Question 40

Why is this pattern useful?

```python
with open("notes.txt", "r", encoding="utf-8") as file:
    contents = file.read()
```

A. It automatically closes the file safely.

B. It converts the file to a list.

C. It prevents all file errors.

D. It creates a virtual environment.

---

## Question 41

What is `pathlib.Path` used for?

A. Working with file and directory paths.

B. Creating only lists.

C. Handling Python exceptions.

D. Formatting strings.

---

## Question 42

What does this expression create?

```python
Path("data") / "tasks.json"
```

A. A numeric division.

B. A combined path.

C. A JSON dictionary.

D. A new Python module.

---

# Section F: JSON and Exceptions

## Question 43

What does JSON represent?

A. Structured data in a text format.

B. Only Python functions.

C. A virtual environment.

D. A type of loop.

---

## Question 44

Which function writes Python data to an open JSON file?

A. `json.write()`

B. `json.dump()`

C. `json.save()`

D. `json.file()`

---

## Question 45

Which function reads JSON from an open file?

A. `json.read()`

B. `json.load()`

C. `json.open()`

D. `json.import()`

---

## Question 46

What is the difference between `json.load()` and `json.loads()`?

A. `load()` reads from a file; `loads()` reads from a string.

B. `load()` reads strings; `loads()` reads files.

C. They are unrelated.

D. `loads()` only works with lists.

---

## Question 47

Which block contains code that may raise an exception?

A. `try`

B. `except`

C. `else`

D. `finally`

---

## Question 48

Which exception commonly occurs when converting `"hello"` to an integer?

A. `KeyError`

B. `ValueError`

C. `IndexError`

D. `FileNotFoundError`

---

## Question 49

Which exception represents malformed JSON?

A. `JSONDecodeError`

B. `JSONFormatError`

C. `FileJSONError`

D. `SyntaxJSONError`

---

## Question 50

Which exception represents a missing file?

A. `MissingFileError`

B. `FileNotFoundError`

C. `NoFileError`

D. `PathError`

---

# Answer Key

## Section A: Conditions and Logical Operators

| Question | Answer | Explanation |
|---:|:---:|---|
| 1 | B | `if` runs its block when the condition is true. |
| 2 | A | `20 >= 18` is true. |
| 3 | B | `elif` means “else if.” |
| 4 | B | `and` requires both conditions to be true. |
| 5 | A | Both age and ticket conditions are true. |
| 6 | B | `or` is true when at least one condition is true. |
| 7 | B | `not` reverses a Boolean condition. |
| 8 | A | `not False` is true. |
| 9 | B | `in` checks membership. |
| 10 | B | An empty string is falsy. |

---

## Section B: Loops

| Question | Answer | Explanation |
|---:|:---:|---|
| 11 | A | `for` processes values in an iterable. |
| 12 | B | `range(3)` produces `0`, `1`, and `2`. |
| 13 | A | The stop value `5` is excluded. |
| 14 | B | The loop prints each task. |
| 15 | C | `enumerate()` provides an index and value. |
| 16 | B | Counting begins at `1` because of `start=1`. |
| 17 | A | A `while` loop runs while its condition is true. |
| 18 | B | `count` never changes. |
| 19 | B | `break` exits the nearest loop. |
| 20 | C | `continue` skips the current iteration. |

---

## Section C: Input Validation

| Question | Answer | Explanation |
|---:|:---:|---|
| 21 | C | `input()` returns text. |
| 22 | C | `int(text)` converts text to an integer. |
| 23 | B | `.strip()` removes whitespace; `not` checks emptiness. |
| 24 | A | `.isdigit()` checks for digit characters. |
| 25 | B | Validation prevents unsafe or unexpected behavior. |

---

## Section D: Functions

| Question | Answer | Explanation |
|---:|:---:|---|
| 26 | C | Functions are defined with `def`. |
| 27 | B | A parameter appears in the function definition. |
| 28 | A | An argument is passed during a function call. |
| 29 | B | The function returns a formatted greeting. |
| 30 | B | `return` sends a value to the caller. |
| 31 | C | `2 + 3` equals `5`. |
| 32 | A | The default is used when an argument is omitted. |
| 33 | A | The annotations describe intended types. |
| 34 | A | Local variables are available within their local scope. |
| 35 | B | The pattern controls direct execution behavior. |

---

## Section E: Modules and Files

| Question | Answer | Explanation |
|---:|:---:|---|
| 36 | A | A module is a reusable Python file. |
| 37 | B | This imports `add` from `calculations`. |
| 38 | C | `"w"` writes and replaces existing contents. |
| 39 | A | `"a"` appends to existing contents. |
| 40 | A | The context manager closes the file safely. |
| 41 | A | `Path` represents file and directory paths. |
| 42 | B | `/` combines path components. |

---

## Section F: JSON and Exceptions

| Question | Answer | Explanation |
|---:|:---:|---|
| 43 | A | JSON is a structured text format. |
| 44 | B | `json.dump()` writes JSON to a file. |
| 45 | B | `json.load()` reads JSON from a file. |
| 46 | A | `load()` uses a file; `loads()` uses a string. |
| 47 | A | Potentially failing code belongs in `try`. |
| 48 | B | Invalid conversion commonly raises `ValueError`. |
| 49 | A | Malformed JSON raises `JSONDecodeError`. |
| 50 | B | A missing file raises `FileNotFoundError`. |

---

# Short-Answer Questions

## Question 51

Why should a function usually return a calculated value instead of always printing it?

### Answer

Returning a value allows the calling code to reuse, display, store, or further process the result.

---

## Question 52

Why should a task manager use functions such as `load_tasks()` and `save_tasks()`?

### Answer

They isolate storage operations, reduce duplication, and keep the main application logic easier to read and test.

---

## Question 53

Why should invalid JSON be handled?

### Answer

A file may be corrupted, manually edited incorrectly, or partially written. Handling the exception prevents an unexpected crash and allows the program to display a useful message or use safe default behavior.

---

## Question 54

What is the difference between a `for` loop and a `while` loop?

### Answer

A `for` loop usually processes items in an iterable or a known sequence. A `while` loop continues while a condition remains true.

---

## Question 55

What is the purpose of `.strip()` when reading command-line or user input?

### Answer

It removes leading and trailing whitespace, making validation and comparisons more reliable.

---

# Practical Coding Questions

## Question 56

Write a function that returns the square of a number.

### Answer

```python
def square(number: int) -> int:
    return number * number
```

---

## Question 57

Write a function that prints each task with a completion marker.

### Answer

```python
def display_tasks(tasks: list[dict]) -> None:
    for task in tasks:
        status = "x" if task["completed"] else " "
        print(
            f"[{status}] "
            f"{task['id']} - "
            f"{task['title']}"
        )
```

---

## Question 58

Write code that safely converts user input to an integer.

### Answer

```python
user_input = input("Enter a number: ").strip()

try:
    number = int(user_input)
except ValueError:
    print("Please enter a valid integer.")
else:
    print(number)
```

---

## Question 59

Write code that reads a JSON file safely.

### Answer

```python
import json
from pathlib import Path


file_path = Path("tasks.json")

try:
    with file_path.open(
        "r",
        encoding="utf-8",
    ) as file:
        tasks = json.load(file)
except FileNotFoundError:
    print("The file does not exist.")
    tasks = []
except json.JSONDecodeError:
    print("The file contains invalid JSON.")
    tasks = []
```

---

## Question 60

Write a function that returns `None` when a task ID cannot be found.

### Answer

```python
def find_task(
    tasks: list[dict],
    task_id: int,
) -> dict | None:
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None
```

---

# Part 2 Scoring Guide

| Score | Interpretation |
|---:|---|
| 54–60 | Excellent understanding |
| 45–53 | Strong understanding |
| 36–44 | Developing understanding |
| 0–35 | Review Modules 3 and 4 |

For coding questions, assess:

- Correct syntax.
- Correct control flow.
- Appropriate function structure.
- Correct exception handling.
- Clear names.
- Ability to explain the solution.

---

# Next Section

The next quiz-bank section is:

# Quiz Bank Part 3: Capstone, Testing, Debugging, and Final Assessment

It will cover:

- Project structure.
- `pyproject.toml`.
- `argparse`.
- CLI commands.
- JSON persistence.
- Custom exceptions.
- File organization.
- Dry-run mode.
- Automated tests.
- Debugging and architecture.

---

# Python Foundations Quiz Bank — Part 3A

This section covers:

- Capstone project structure.
- Python packages.
- `pyproject.toml`.
- `argparse`.
- CLI commands.
- Task logic.
- JSON persistence.
- Custom exceptions.

---

# Section A: Project Structure

## Question 1

Where should application source code be located in the capstone?

A. `data/`

B. `tests/`

C. `src/foundation_cli/`

D. `.venv/`

---

## Question 2

What is the purpose of `data/tasks.json`?

A. It stores Python source code.

B. It stores persistent task data.

C. It stores automated tests.

D. It activates the environment.

---

## Question 3

What is the purpose of the `tests/` directory?

A. Store temporary user input.

B. Store automated tests.

C. Store JSON data only.

D. Store virtual environments.

---

## Question 4

What does `__init__.py` indicate?

A. The file contains JSON.

B. The directory is a Python package.

C. The application is complete.

D. The directory is a virtual environment.

---

## Question 5

What does `__main__.py` allow?

A. Running the package with `python -m foundation_cli`.

B. Reading JSON automatically.

C. Creating a virtual environment.

D. Running only unit tests.

---

## Question 6

What is the purpose of `pyproject.toml`?

A. Store task records.

B. Define project metadata and packaging configuration.

C. Store terminal output.

D. Replace all Python files.

---

## Question 7

What does this configuration describe?

```toml
[project.scripts]
foundation = "foundation_cli.cli:main"
```

A. A JSON file named `foundation`.

B. A command named `foundation` that calls `main()`.

C. A virtual environment.

D. A test file.

---

# Section B: Command-Line Interfaces

## Question 8

Which standard-library module is commonly used to parse command-line arguments?

A. `commandline`

B. `argparse`

C. `cli_tools`

D. `terminal`

---

## Question 9

What does `ArgumentParser` create?

A. A JSON file.

B. A command-line argument parser.

C. A virtual environment.

D. A task dictionary.

---

## Question 10

What does this create?

```python
subparsers = parser.add_subparsers(
    dest="command"
)
```

A. Multiple command-line subcommands.

B. Multiple JSON files.

C. A list of tasks.

D. A set of extensions.

---

## Question 11

Which command adds a task?

A. `python -m foundation_cli task "Learn Python"`

B. `python -m foundation_cli add "Learn Python"`

C. `python -m foundation_cli create-task`

D. `foundation task-add`

---

## Question 12

Which command lists tasks?

A. `python -m foundation_cli show`

B. `python -m foundation_cli tasks`

C. `python -m foundation_cli list`

D. `python -m foundation_cli display-all`

---

## Question 13

What does `type=int` do in an argument definition?

A. Converts the argument to an integer.

B. Requires a JSON file.

C. Creates an integer task.

D. Prevents all invalid values.

---

## Question 14

What should happen when the user runs the application without a command?

A. The application should usually display help.

B. The application should delete the data file.

C. The application should crash.

D. The application should organize the current directory.

---

## Question 15

What is the purpose of `--help`?

A. Complete all tasks.

B. Display usage information.

C. Create a backup.

D. Activate the virtual environment.

---

# Section C: Task Logic

## Question 16

What is the appropriate structure for one task?

A.

```python
["Learn Python", False]
```

B.

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

C.

```python
("Learn Python")
```

D.

```python
{"Learn Python", False}
```

---

## Question 17

What should `get_next_id()` do?

A. Return a new ID greater than existing task IDs.

B. Delete the largest task ID.

C. Convert IDs to strings.

D. Return the number of completed tasks.

---

## Question 18

What should `find_task()` return when a matching task does not exist?

A. `False`

B. `0`

C. `None`

D. An empty string

---

## Question 19

Where should task rules such as completion and removal primarily be implemented?

A. `tasks.py`

B. `README.md`

C. `pyproject.toml`

D. `data/tasks.json`

---

## Question 20

Why should task logic be separate from CLI parsing?

A. It makes the project harder to understand.

B. It separates responsibilities and makes testing easier.

C. It prevents functions from working.

D. It removes the need for JSON.

---

## Question 21

What should happen when a user tries to complete a nonexistent task?

A. The program should silently create it.

B. The program should display a useful error.

C. The program should remove all tasks.

D. The program should treat it as completed.

---

# Section D: JSON Storage

## Question 22

What does `load_tasks()` usually do?

A. Parse command-line arguments.

B. Read and validate tasks from JSON.

C. Move files by extension.

D. Run automated tests.

---

## Question 23

What does `save_tasks()` usually do?

A. Write the current task list to JSON.

B. Print CLI help.

C. Create Python functions.

D. Delete completed tasks.

---

## Question 24

What should happen when `data/tasks.json` does not exist?

A. The program should usually begin with an empty task list.

B. The program should delete the project.

C. The program should create random tasks.

D. The program should always crash.

---

## Question 25

What exception represents malformed JSON?

A. `TaskDataError`

B. `JSONDecodeError`

C. `InvalidJSONFile`

D. `SyntaxErrorJSON`

---

## Question 26

Why should loaded JSON data be validated?

A. Valid JSON can still have the wrong application structure.

B. JSON cannot contain lists.

C. Validation makes files smaller.

D. Validation replaces testing.

---

## Question 27

Which JSON structure is appropriate for multiple tasks?

A.

```json
{
  "task": "Learn Python"
}
```

B.

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  }
]
```

C.

```json
"Learn Python"
```

D.

```json
true
```

---

# Section E: Custom Exceptions

## Question 28

Why create a custom exception such as `TaskNotFoundError`?

A. To communicate a specific application error.

B. To replace all functions.

C. To make errors impossible.

D. To create a new data type for JSON.

---

## Question 29

What should a task function do when a task does not exist?

A. Raise an appropriate application exception.

B. Print the entire JSON file.

C. Add a new task automatically.

D. Return a random task.

---

## Question 30

Which code catches expected application errors?

```python
try:
    handle_command(arguments)
except FoundationError as error:
    print(f"Error: {error}")
```

A. It catches application-specific errors.

B. It catches only syntax errors.

C. It prevents all file operations.

D. It creates a new task.

---

## Question 31

Why should expected user-facing errors usually not display full tracebacks?

A. Tracebacks contain useful debugging information only for the user.

B. Clear messages are more appropriate for normal application failures.

C. Tracebacks are always invalid Python.

D. The application cannot use exceptions.

---

# Answer Key — Part 3A

| Question | Answer | Explanation |
|---:|:---:|---|
| 1 | C | Application code belongs under `src/foundation_cli/`. |
| 2 | B | The JSON file stores persistent task data. |
| 3 | B | Automated tests belong in `tests/`. |
| 4 | B | `__init__.py` identifies a package. |
| 5 | A | `__main__.py` supports package execution with `-m`. |
| 6 | B | It stores project and packaging configuration. |
| 7 | B | It maps a console command to a Python function. |
| 8 | B | `argparse` is Python's standard CLI parser. |
| 9 | B | `ArgumentParser` parses command-line input. |
| 10 | A | Subparsers represent commands such as `add` and `list`. |
| 11 | B | This is the capstone's add command. |
| 12 | C | This is the capstone's list command. |
| 13 | A | It converts the argument using `int`. |
| 14 | A | Showing help is the usual behavior. |
| 15 | B | `--help` displays usage information. |
| 16 | B | A dictionary clearly labels task fields. |
| 17 | A | IDs should be unique and greater than existing IDs. |
| 18 | C | `None` represents no matching result. |
| 19 | A | Task rules belong in `tasks.py`. |
| 20 | B | Separation improves clarity and testing. |
| 21 | B | The user should receive a useful error. |
| 22 | B | `load_tasks()` reads and validates JSON task data. |
| 23 | A | `save_tasks()` writes tasks to JSON. |
| 24 | A | A missing file can represent a first run. |
| 25 | B | Malformed JSON raises `JSONDecodeError`. |
| 26 | A | Syntax validity does not guarantee the expected data shape. |
| 27 | B | A list of task objects represents multiple tasks. |
| 28 | A | The name communicates the specific failure. |
| 29 | A | The task layer should raise an appropriate error. |
| 30 | A | `FoundationError` represents expected application errors. |
| 31 | B | Users generally need clear, concise error messages. |

---

# Short-Answer Questions

## Question 32

Explain the purpose of this project structure:

```text
src/foundation_cli/
data/
tests/
```

### Answer

```text
src/foundation_cli/ → application source code
data/               → persistent application data
tests/              → automated tests
```

---

## Question 33

Why is a list of dictionaries appropriate for the task manager?

### Answer

A list stores multiple tasks in an ordered collection. Each dictionary represents one task with named fields such as `id`, `title`, and `completed`.

---

## Question 34

What should happen when a task title contains only spaces?

### Answer

The title should be stripped and rejected as empty.

Example:

```python
cleaned_title = title.strip()

if not cleaned_title:
    raise InvalidTaskTitleError(
        "Task title cannot be empty."
    )
```

---

## Question 35

Why is storage separated from task logic?

### Answer

Storage handles files and JSON, while task logic handles application rules. Separation makes the code easier to understand, test, and change.

---

## Question 36

What is the purpose of `--dry-run`?

### Answer

It previews planned file operations without actually moving or modifying files.

---

# Practical Coding Questions

## Question 37

Write a CLI parser argument for an `add` command with a required title.

### Answer

```python
add_parser = subparsers.add_parser(
    "add",
    help="Create a new task.",
)

add_parser.add_argument(
    "title",
    help="The title of the task.",
)
```

---

## Question 38

Write a function that creates and appends a task.

### Answer

```python
def create_task(tasks, title):
    cleaned_title = title.strip()

    if not cleaned_title:
        raise ValueError(
            "Task title cannot be empty."
        )

    task = {
        "id": len(tasks) + 1,
        "title": cleaned_title,
        "completed": False,
    }

    tasks.append(task)
    return task
```

A production implementation may use a more robust ID-generation function.

---

## Question 39

Write a command handler that loads, completes, saves, and displays a task.

### Answer

```python
def handle_complete(task_id):
    tasks = load_tasks()

    task = complete_task(
        tasks,
        task_id,
    )

    save_tasks(tasks)

    print("Task completed:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")
```

---

## Question 40

Write a simple file-extension folder function.

### Answer

```python
from pathlib import Path


def extension_folder(file_path: Path) -> str:
    suffix = file_path.suffix.lower().lstrip(".")

    if suffix:
        return suffix

    return "no_extension"
```

---

# Part 3A Completion Checklist

- [ ] Understand the `src` layout.
- [ ] Explain `pyproject.toml`.
- [ ] Explain `__init__.py`.
- [ ] Explain `__main__.py`.
- [ ] Use `argparse`.
- [ ] Explain CLI subcommands.
- [ ] Represent tasks as dictionaries.
- [ ] Explain task logic.
- [ ] Explain storage logic.
- [ ] Explain JSON persistence.
- [ ] Explain custom exceptions.
- [ ] Explain dry-run mode.

---

# Next Section

The final quiz section is:

# Quiz Bank Part 3B: File Organization, Testing, Debugging, and Final Assessment

It will cover:

- `pathlib`.
- `shutil`.
- File moves.
- Duplicate protection.
- Automated tests.
- Temporary directories.
- Tracebacks.
- Debugging.
- Architecture.
- Final practical assessment.

---

# Python Foundations Quiz Bank — Part 3B

This is the final section of the Quiz Bank.

It covers:

- File organization.
- `pathlib`.
- `shutil`.
- Dry-run behavior.
- Duplicate-file protection.
- Automated testing.
- Temporary directories.
- Debugging.
- Tracebacks.
- Architecture.
- Final practical assessment.

---

# Section A: File Organization

## Question 1

Which module provides the `Path` class?

A. `os.pathlib`

B. `pathlib`

C. `files`

D. `directories`

---

## Question 2

What does this expression do?

```python
file_path.suffix
```

A. Returns the file's extension.

B. Returns the file's contents.

C. Returns the file's parent directory.

D. Deletes the file.

---

## Question 3

What is the result of:

```python
Path("PHOTO.JPG").suffix.lower()
```

A. `.JPG`

B. `.jpg`

C. `jpg`

D. `PHOTO`

---

## Question 4

What does this expression do?

```python
file_path.suffix.lower().lstrip(".")
```

For:

```python
file_path = Path("report.PDF")
```

A. Returns `"report"`

B. Returns `".pdf"`

C. Returns `"pdf"`

D. Returns `"PDF"`

---

## Question 5

What folder should be used for a file with no extension?

A. `unknown_file`

B. `no_extension`

C. `none`

D. `default_file`

---

## Question 6

What does `Path.iterdir()` do?

A. Reads a text file.

B. Lists the direct contents of a directory.

C. Deletes a directory.

D. Recursively moves every file.

---

## Question 7

Which check determines whether a path refers to a file?

A. `path.is_file()`

B. `path.is_document()`

C. `path.file_exists()`

D. `path.is_text()`

---

## Question 8

Which check determines whether a path refers to a directory?

A. `path.is_folder()`

B. `path.is_directory()`

C. `path.is_dir()`

D. `path.directory()`

---

## Question 9

Which module provides `shutil.move()`?

A. `pathlib`

B. `shutil`

C. `moving`

D. `filesystem`

---

## Question 10

Why should an organizer skip directories while processing files?

A. Directories cannot have names.

B. The organizer is intended to move files, not recursively process destination folders.

C. Directories cannot be inspected.

D. Skipping directories makes files invisible.

---

## Question 11

What does dry-run mode do?

A. Deletes files temporarily.

B. Shows planned operations without performing them.

C. Moves files and then restores them.

D. Disables all error handling.

---

## Question 12

Why should duplicate destination names be handled?

A. To prevent accidental overwriting.

B. To make extensions uppercase.

C. To remove all files.

D. To avoid using `pathlib`.

---

## Question 13

Which destination is appropriate when `report.pdf` already exists?

A. `report.pdf`

B. `report_1.pdf`

C. `report.pdf.pdf`

D. `copy.report`

---

## Question 14

What should happen if the organizer receives a nonexistent directory?

A. It should silently organize the current directory.

B. It should create a random directory.

C. It should report a clear error.

D. It should delete the input path.

---

# Section B: Automated Testing

## Question 15

Which standard-library module is used in this course for testing?

A. `pytest`

B. `unittest`

C. `testlib`

D. `assertions`

---

## Question 16

What is the purpose of `unittest.TestCase`?

A. It provides a base class for test methods and assertions.

B. It creates JSON files.

C. It activates a virtual environment.

D. It moves files.

---

## Question 17

Which command discovers and runs tests in the `tests` directory?

A. `python run tests`

B. `python -m unittest discover -s tests -v`

C. `python tests --all`

D. `unittest execute`

---

## Question 18

What does `self.assertEqual(actual, expected)` check?

A. That two values are equal.

B. That two files are deleted.

C. That a function raises any error.

D. That a list is sorted.

---

## Question 19

What does `assertRaises()` test?

A. Whether a function raises an expected exception.

B. Whether a function prints text.

C. Whether a file exists.

D. Whether two strings match.

---

## Question 20

Why should tests cover failure cases?

A. Failure cases are not part of application behavior.

B. They verify that expected problems are handled correctly.

C. They make the program run faster.

D. They remove the need for successful tests.

---

## Question 21

Why should file tests use temporary directories?

A. To make tests slower.

B. To avoid modifying real project data.

C. To prevent files from being read.

D. To ensure paths are always invalid.

---

## Question 22

Which module provides temporary directories?

A. `temporary`

B. `tempfile`

C. `testpath`

D. `pathlib.temp`

---

## Question 23

What happens after this block ends?

```python
with tempfile.TemporaryDirectory() as directory:
    ...
```

A. The temporary directory is normally cleaned up automatically.

B. The directory becomes the project root.

C. All project files are deleted.

D. The directory becomes permanent.

---

## Question 24

What should a test do when it discovers a bug?

A. Ignore it.

B. Add or update a test so the bug cannot easily return.

C. Delete all tests.

D. Catch every exception broadly.

---

# Section C: Debugging

## Question 25

Where should you usually start reading a traceback?

A. At the top.

B. From the middle.

C. At the bottom.

D. From the file name only.

---

## Question 26

What does the final line of a traceback usually contain?

A. The Python version only.

B. The exception type and message.

C. The complete project structure.

D. The solution to the problem.

---

## Question 27

Which expression reveals invisible whitespace?

A. `print(value)`

B. `repr(value)`

C. `type(value)`

D. `len(type(value))`

---

## Question 28

Which expression checks a value's type?

A. `typeof(value)`

B. `value.type()`

C. `type(value)`

D. `inspect(value)`

---

## Question 29

What is a minimal reproduction?

A. The smallest example that still demonstrates a problem.

B. A complete production application.

C. A list of all possible errors.

D. A copy of the entire project.

---

## Question 30

Why should you change one thing at a time while debugging?

A. It makes the program longer.

B. It helps identify which change affected the result.

C. It prevents testing.

D. It avoids using functions.

---

## Question 31

What should you inspect when a comparison unexpectedly fails?

A. Only the variable names.

B. The values and their types.

C. The operating system wallpaper.

D. The README file only.

---

## Question 32

What is a regression?

A. A new feature.

B. A previously fixed problem that returns.

C. A successful test.

D. A type hint.

---

## Question 33

What is a useful response to a missing-task error?

A. Add a random task.

B. Display a clear message such as `No task found with ID 5.`

C. Delete the JSON file.

D. Hide the error completely.

---

## Question 34

Why is broad exception handling risky?

```python
try:
    ...
except Exception:
    print("Something went wrong.")
```

A. It may hide the real cause of a problem.

B. It always improves debugging.

C. It catches no exceptions.

D. It prevents syntax errors.

---

# Section D: Architecture and Code Quality

## Question 35

What should `cli.py` primarily handle?

A. Command-line parsing and user-facing command behavior.

B. Every file-system operation in the project.

C. Only JSON formatting.

D. Python installation.

---

## Question 36

What should `tasks.py` primarily handle?

A. Task-management rules.

B. Terminal installation.

C. File extensions only.

D. Test discovery.

---

## Question 37

What should `storage.py` primarily handle?

A. Loading and saving task data.

B. Printing CLI help.

C. Moving photographs.

D. Creating grades.

---

## Question 38

What should `organizer.py` primarily handle?

A. File classification and movement.

B. Task ID validation only.

C. JSON syntax only.

D. Python package metadata.

---

## Question 39

Why should functions have focused responsibilities?

A. Focused functions are easier to understand, test, and maintain.

B. Focused functions always run faster.

C. Focused functions eliminate all errors.

D. Focused functions cannot return values.

---

## Question 40

What is a benefit of separating storage from task logic?

A. The storage method can change with fewer changes to task behavior.

B. The project requires more global variables.

C. JSON becomes unnecessary.

D. Tests become impossible.

---

# Answer Key

## Section A: File Organization

| Question | Answer | Explanation |
|---:|:---:|---|
| 1 | B | `Path` comes from `pathlib`. |
| 2 | A | `.suffix` returns the extension, such as `.pdf`. |
| 3 | B | `.lower()` normalizes `.JPG` to `.jpg`. |
| 4 | C | `lstrip(".")` removes the leading dot. |
| 5 | B | Files without extensions use `no_extension`. |
| 6 | B | `iterdir()` lists direct directory contents. |
| 7 | A | `.is_file()` checks for a file. |
| 8 | C | `.is_dir()` checks for a directory. |
| 9 | B | `shutil.move()` is provided by `shutil`. |
| 10 | B | The organizer should process files, not destination directories. |
| 11 | B | Dry-run mode previews changes without modifying files. |
| 12 | A | Duplicate protection prevents overwriting. |
| 13 | B | A suffix such as `_1` creates a unique destination. |
| 14 | C | Invalid paths should produce clear errors. |

---

## Section B: Automated Testing

| Question | Answer | Explanation |
|---:|:---:|---|
| 15 | B | The course uses Python's built-in `unittest`. |
| 16 | A | `TestCase` provides test structure and assertions. |
| 17 | B | This command discovers tests in `tests`. |
| 18 | A | `assertEqual` compares two values. |
| 19 | A | `assertRaises` verifies expected exceptions. |
| 20 | B | Failure behavior must also be tested. |
| 21 | B | Temporary paths protect real project data. |
| 22 | B | `tempfile` provides temporary directories. |
| 23 | A | The temporary directory is cleaned up automatically. |
| 24 | B | A regression test protects the fix. |

---

## Section C: Debugging

| Question | Answer | Explanation |
|---:|:---:|---|
| 25 | C | The bottom usually contains the most useful final error. |
| 26 | B | It usually identifies the exception type and message. |
| 27 | B | `repr()` reveals whitespace and special characters. |
| 28 | C | `type(value)` returns the value's type. |
| 29 | A | A minimal reproduction isolates a problem. |
| 30 | B | One change makes cause and effect clearer. |
| 31 | B | Unexpected comparisons often involve values or type differences. |
| 32 | B | A regression is a returning bug. |
| 33 | B | Users need a clear, actionable message. |
| 34 | A | Broad handlers can hide useful diagnostic information. |

---

## Section D: Architecture and Code Quality

| Question | Answer | Explanation |
|---:|:---:|---|
| 35 | A | `cli.py` handles command-line interaction. |
| 36 | A | `tasks.py` contains task-management rules. |
| 37 | A | `storage.py` handles persistence. |
| 38 | A | `organizer.py` handles file operations. |
| 39 | A | Focused functions are easier to maintain and test. |
| 40 | A | Separation reduces future changes when storage evolves. |

---

# Short-Answer Questions

## Question 41

Why should the organizer provide a dry-run mode?

### Answer

A dry run allows users to preview planned file moves before modifying the file system. It reduces the risk of moving files incorrectly.

---

## Question 42

Why should an organizer avoid overwriting existing files?

### Answer

Overwriting could destroy existing data. A unique destination such as `report_1.pdf` preserves both files.

---

## Question 43

Why should automated tests not modify the real `data/tasks.json`?

### Answer

Tests should be isolated and repeatable. Modifying real application data can create side effects and make later tests unreliable.

---

## Question 44

What is the purpose of a regression test?

### Answer

It verifies that a previously fixed bug does not return after future code changes.

---

## Question 45

Describe the capstone application flow.

### Answer

```text
Command-line input
        ↓
Argument parsing
        ↓
CLI dispatch
        ↓
Application logic
        ↓
Storage or file-system operation
        ↓
User-facing output
```

---

# Practical Coding Questions

## Question 46

Write a function that returns a unique destination when a file already exists.

### Answer

```python
from pathlib import Path


def unique_destination(destination: Path) -> Path:
    if not destination.exists():
        return destination

    counter = 1

    while True:
        candidate = destination.with_name(
            f"{destination.stem}_{counter}"
            f"{destination.suffix}"
        )

        if not candidate.exists():
            return candidate

        counter += 1
```

---

## Question 47

Write a dry-run condition for a file move.

### Answer

```python
print(f"{source} -> {destination}")

if dry_run:
    return

shutil.move(
    str(source),
    str(destination),
)
```

---

## Question 48

Write a test that expects a `ValueError`.

### Answer

```python
def test_invalid_title(self):
    tasks = []

    with self.assertRaises(ValueError):
        create_task(tasks, "")
```

---

## Question 49

Write a test using a temporary directory.

### Answer

```python
import tempfile
from pathlib import Path


with tempfile.TemporaryDirectory() as directory:
    file_path = Path(directory) / "test.txt"

    file_path.write_text(
        "Hello",
        encoding="utf-8",
    )

    assert file_path.exists()
```

---

## Question 50

Write a debugging snippet that displays a value, its representation, and its type.

### Answer

```python
print(f"value: {value}")
print(f"repr: {value!r}")
print(f"type: {type(value)}")
```

---

# Final Practical Assessment

Ask the learner to add an `edit` command:

```bash
python -m foundation_cli edit 1 "Updated task title"
```

The learner should:

1. Add an `edit` subparser.
2. Accept a positive task ID.
3. Accept a new title.
4. Reject an empty title.
5. Find the task.
6. Update the title.
7. Save the JSON.
8. Display a confirmation.
9. Handle a missing task.
10. Add automated tests.

Expected output:

```text
Task updated:
  ID: 1
  Title: Updated task title
```

---

# Final Assessment Criteria

| Requirement | Complete? |
|---|---:|
| CLI parser accepts `edit` | [ ] |
| Task ID is validated | [ ] |
| Empty title is rejected | [ ] |
| Existing task can be found | [ ] |
| Title is updated | [ ] |
| JSON is saved | [ ] |
| Confirmation is displayed | [ ] |
| Missing task is handled | [ ] |
| Success case is tested | [ ] |
| Failure case is tested | [ ] |

---

# Final Quiz Score Guide

For the 40 multiple-choice questions:

| Score | Interpretation |
|---:|---|
| 36–40 | Excellent capstone understanding |
| 30–35 | Strong understanding |
| 24–29 | Developing understanding |
| 0–23 | Review capstone and testing modules |

For the practical assessment, evaluate:

- Correct implementation.
- Appropriate module placement.
- Validation.
- Error handling.
- Test coverage.
- Ability to explain the solution.

---

# Complete Quiz Bank

The full quiz bank now includes:

```text
Quiz Bank Part 1:
Environment, syntax, and collections

Quiz Bank Part 2:
Control flow, functions, files, JSON, and exceptions

Quiz Bank Part 3A:
Capstone structure, CLI, task logic, storage, and errors

Quiz Bank Part 3B:
File organization, testing, debugging, architecture, and assessment
```

The quiz bank tests both knowledge and practical programming ability.
