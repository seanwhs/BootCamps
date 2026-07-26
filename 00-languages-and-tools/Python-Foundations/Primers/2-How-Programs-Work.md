# Primer 2: How Programs Work

This primer explains the basic model behind every program in the series.

Before learning Python syntax, it helps to understand what programs do:

```text
Receive input
    ↓
Store information
    ↓
Process information
    ↓
Produce output
```

This model will appear repeatedly in:

- Small Python scripts.
- The task manager.
- The file organizer.
- Command-line programs.
- Automated tests.

---

# 1. What Is a Program?

A program is a set of instructions that tells a computer what to do.

Example:

```python
print("Hello, Python!")
```

This program contains one instruction:

> Display the text `"Hello, Python!"`.

A larger program is still a collection of instructions, but it may also:

- Receive user input.
- Store data.
- Make decisions.
- Repeat operations.
- Read files.
- Write files.
- Handle errors.

---

# 2. Instructions

An instruction tells Python to perform an operation.

Examples:

```python
print("Hello")
```

```python
total = 5 + 3
```

```python
name = input("Name: ")
```

Each instruction contributes to the program's behavior.

Python normally executes instructions from top to bottom:

```python
print("First")
print("Second")
print("Third")
```

Output:

```text
First
Second
Third
```

---

# 3. Values

A value is a piece of information used by a program.

Examples:

```python
"Ada"
36
1.65
True
```

Values can represent:

- Text.
- Numbers.
- Yes/no states.
- Collections.
- Empty or missing data.

Examples of values:

```python
name = "Ada"
age = 36
height = 1.65
is_learning = True
```

---

# 4. Variables

A variable is a name that refers to a value.

```python
name = "Ada"
```

This can be read as:

> Associate the name `name` with the value `"Ada"`.

Another example:

```python
age = 36
```

The variable name is:

```text
age
```

The value is:

```text
36
```

Variables allow programs to remember information while running.

---

# 5. Changing Variables

A variable can refer to a new value:

```python
count = 1
count = 2
count = 3

print(count)
```

Output:

```text
3
```

The final assignment determines the value currently associated with `count`.

A variable can also be updated using its previous value:

```python
count = 1
count = count + 1

print(count)
```

Output:

```text
2
```

Shorter form:

```python
count += 1
```

---

# 6. Input, Processing, and Output

A common program model is:

```text
Input
  ↓
Processing
  ↓
Output
```

Example:

```python
name = input("What is your name? ")
message = f"Hello, {name}!"

print(message)
```

## Input

```python
name = input("What is your name? ")
```

The program receives text from the user.

## Processing

```python
message = f"Hello, {name}!"
```

The program creates a new message.

## Output

```python
print(message)
```

The program displays the result.

---

# 7. A Calculation Example

```python
price = 4.50
quantity = 3

total = price * quantity

print(f"Total: ${total:.2f}")
```

The flow is:

```text
Input values:
price = 4.50
quantity = 3

Processing:
total = price * quantity

Output:
Total: $13.50
```

Even though the values are written directly into the program, the structure is the same.

---

# 8. User Input Is Text

This program asks for a number:

```python
age = input("How old are you? ")
```

But the result is text:

```python
print(type(age))
```

If the user enters:

```text
36
```

Python receives:

```python
"36"
```

not:

```python
36
```

Convert the value when numeric processing is needed:

```python
age = int(input("How old are you? "))
```

Now:

```python
age + 1
```

works as numeric addition.

---

# 9. Processing Can Include Decisions

A program can choose different outputs based on input:

```python
age = 20

if age >= 18:
    message = "Adult"
else:
    message = "Minor"

print(message)
```

The flow is:

```text
Receive or define age
        ↓
Compare age with 18
        ↓
Choose a message
        ↓
Display the message
```

---

# 10. Processing Can Include Repetition

A program can repeat an operation:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI",
]

for task in tasks:
    print(task)
```

The flow is:

```text
Read the task list
        ↓
Take one task
        ↓
Display it
        ↓
Take the next task
        ↓
Repeat until finished
```

---

# 11. Program State

**State** means the information a program currently remembers.

A task manager's state might be:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]
```

When a task is completed:

```python
tasks[0]["completed"] = True
```

The program's state changes.

Before:

```python
"completed": False
```

After:

```python
"completed": True
```

Persistent storage allows state to survive after the program closes.

---

# 12. Temporary and Persistent State

## Temporary State

This exists only while the program is running:

```python
tasks = []
```

When the program closes, the data disappears.

## Persistent State

This is saved to a file:

```text
data/tasks.json
```

When the program starts again, it can load the saved data.

The capstone uses JSON persistence:

```text
Program starts
    ↓
Load tasks.json
    ↓
Change tasks in memory
    ↓
Save tasks.json
```

---

# 13. Source Code and Execution

**Source code** is the code written by a programmer:

```python
print("Hello")
```

**Execution** is what happens when Python runs the source code.

```bash
python hello.py
```

During execution, Python:

1. Reads the source code.
2. Checks its syntax.
3. Evaluates expressions.
4. Executes instructions.
5. Produces output or an error.

---

# 14. Syntax

Syntax is the structure Python expects.

This is valid:

```python
if True:
    print("Valid")
```

This is invalid:

```python
if True
    print("Invalid")
```

The invalid version is missing a colon.

Syntax is similar to grammar in a spoken language. If the structure is incorrect, Python cannot interpret the instruction.

---

# 15. Errors as Program Reports

If Python cannot complete an operation, it reports an error.

Example:

```python
number = int("hello")
```

The input cannot be converted to an integer, so Python raises a `ValueError`.

An error report often includes:

- Error type.
- Error message.
- File name.
- Line number.
- Code location.

An error is information about the program's current behavior.

---

# 16. Bugs

A **bug** is behavior that does not match the intended result.

A program may run without a Python exception and still contain a bug.

Example:

```python
price = 10
quantity = 3

total = price + quantity
```

This code runs, but the calculation is probably wrong.

The intended calculation may be:

```python
total = price * quantity
```

The program's syntax is valid, but its logic is incorrect.

---

# 17. Syntax Errors and Logic Errors

## Syntax Error

Python cannot understand the code structure:

```python
if True
    print("Hello")
```

## Logic Error

Python runs the code, but the result is wrong:

```python
total = price + quantity
```

when multiplication was intended.

## Runtime Error

Python understands the code but encounters a problem while running:

```python
number = int("hello")
```

These categories require different debugging approaches.

---

# 18. Functions as Named Operations

A function gives a name to a reusable operation:

```python
def calculate_total(price, quantity):
    return price * quantity
```

The function can be called:

```python
total = calculate_total(4.50, 3)
```

The program becomes easier to describe:

```text
Get price and quantity
        ↓
Call calculate_total()
        ↓
Receive total
        ↓
Display total
```

---

# 19. Modules as Organized Code

A module is a Python file containing related code.

For example:

```text
calculations.py
```

might contain:

```python
def add(first, second):
    return first + second
```

Another file can import it:

```python
from calculations import add
```

Modules help divide a large program into focused parts.

The capstone uses modules such as:

```text
cli.py
tasks.py
storage.py
organizer.py
errors.py
```

---

# 20. The Capstone as a System

The capstone's flow is:

```text
User enters a command
        ↓
argparse reads the command
        ↓
CLI dispatches the command
        ↓
Application logic performs the operation
        ↓
Storage or file system is updated
        ↓
The result is displayed
```

For example:

```bash
python -m foundation_cli add "Learn Python"
```

becomes:

```text
Terminal command
        ↓
arguments.command = "add"
        ↓
handle_add()
        ↓
create_task()
        ↓
save_tasks()
        ↓
Confirmation message
```

---

# 21. Data Flow in the Task Manager

## Add a Task

```text
User provides title
        ↓
Validate title
        ↓
Generate ID
        ↓
Create dictionary
        ↓
Append to task list
        ↓
Save JSON
        ↓
Display confirmation
```

## Complete a Task

```text
User provides ID
        ↓
Validate ID
        ↓
Load tasks
        ↓
Find matching task
        ↓
Change completed to True
        ↓
Save JSON
        ↓
Display confirmation
```

## List Tasks

```text
User runs list command
        ↓
Load JSON
        ↓
Loop through tasks
        ↓
Choose [ ] or [x]
        ↓
Display task lines
```

---

# 22. Why Programs Use Layers

A small script can place everything in one file.

A larger application benefits from layers:

```text
CLI layer
    Understands user commands

Application layer
    Applies task rules

Storage layer
    Reads and writes data

File-system layer
    Organizes files
```

Each layer has a focused responsibility.

This prevents every function from needing to understand every other part of the application.

---

# 23. What Happens When a Command Fails?

Suppose the user runs:

```bash
python -m foundation_cli complete 999
```

The flow is:

```text
Argument parser receives 999
        ↓
CLI calls handle_complete(999)
        ↓
Task logic searches for ID 999
        ↓
No task is found
        ↓
TaskNotFoundError is raised
        ↓
CLI catches the error
        ↓
User sees a clear message
```

Expected output:

```text
Error: No task found with ID 999.
```

The program handles the expected failure instead of exposing an unnecessary traceback.

---

# 24. Primer 2 Practice Exercise

Create a short program that follows this structure:

```text
Input
  ↓
Processing
  ↓
Decision
  ↓
Output
```

Requirements:

1. Ask the user for a number.
2. Convert it to an integer.
3. Determine whether it is even or odd.
4. Display the result.

Suggested structure:

```python
number_text = input("Enter a number: ")
number = int(number_text)

if number % 2 == 0:
    result = "even"
else:
    result = "odd"

print(f"{number} is {result}.")
```

Run it with:

```text
8
```

Expected output:

```text
8 is even.
```

Run it with:

```text
7
```

Expected output:

```text
7 is odd.
```

---

# 25. Primer 2 Reflection

What is the difference between input and output?

```text
____________________________________________________________

____________________________________________________________
```

What is program state?

```text
____________________________________________________________

____________________________________________________________
```

What is the difference between a syntax error and a logic error?

```text
____________________________________________________________

____________________________________________________________
```

Why are functions useful?

```text
____________________________________________________________

____________________________________________________________
```

Why does the capstone use multiple modules?

```text
____________________________________________________________

____________________________________________________________
```

---

# 26. Primer 2 Readiness Checklist

Before continuing, confirm that you can:

- [ ] Explain what a program is.
- [ ] Identify input, processing, and output.
- [ ] Explain variables.
- [ ] Explain program state.
- [ ] Distinguish source code from execution.
- [ ] Distinguish syntax errors from logic errors.
- [ ] Explain runtime errors.
- [ ] Describe what a function does.
- [ ] Describe what a module does.
- [ ] Explain the capstone data flow.
- [ ] Explain why layers separate responsibilities.
- [ ] Build a small input-processing-output program.

---

# Primer 2 Complete

You now understand the basic model behind the course:

```text
Input
    ↓
Store
    ↓
Process
    ↓
Decide or repeat
    ↓
Output
    ↓
Optionally persist
```
