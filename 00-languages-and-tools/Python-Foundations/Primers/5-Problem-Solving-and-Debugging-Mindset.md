# Primer 5: Problem-Solving and Debugging Mindset

This primer introduces the habits that help you solve programming problems independently.

Python knowledge is important, but successful programming also requires a repeatable method for:

- Understanding requirements.
- Breaking large problems into smaller steps.
- Predicting behavior.
- Investigating errors.
- Testing small pieces.
- Changing one thing at a time.
- Recording solutions.

---

# 1. Programming Is Problem Solving

Programming is not only writing syntax.

It is the process of turning a goal into instructions.

Suppose the requirement is:

> Build a program that saves tasks and marks them as completed.

Before writing code, identify:

```text
What information must be stored?
What actions must the user perform?
What can go wrong?
How should the data be saved?
How will the program be tested?
```

This converts a vague request into concrete decisions.

---

# 2. Break Requirements into Steps

Large requirements are easier to manage when divided into smaller operations.

Requirement:

> Build a task manager.

Break it into:

```text
1. Represent one task.
2. Store multiple tasks.
3. Display tasks.
4. Add a task.
5. Find a task by ID.
6. Complete a task.
7. Remove a task.
8. Save tasks.
9. Load tasks.
10. Handle invalid input.
11. Test each operation.
```

Each step can be implemented and verified separately.

---

# 3. Use the Input-Process-Output Model

For any small program, ask:

```text
What is the input?
What processing is required?
What is the output?
```

Example:

> Convert minutes to seconds.

```text
Input:
Number of minutes

Processing:
minutes * 60

Output:
Number of seconds
```

Python implementation:

```python
minutes = 7
seconds = minutes * 60

print(seconds)
```

---

# 4. Write the Algorithm First

An **algorithm** is a sequence of steps for solving a problem.

Before code, write plain-language instructions.

Example:

```text
1. Ask the user for a task title.
2. Remove surrounding whitespace.
3. Check whether the title is empty.
4. If empty, display an error.
5. Otherwise, create a task.
6. Add the task to the list.
7. Save the list.
8. Display confirmation.
```

Then translate each step into Python.

This prevents you from trying to solve the entire problem at once.

---

# 5. Use Pseudocode

Pseudocode is an informal description of logic written in plain language.

Example:

```text
START
    Read task ID
    Convert task ID to integer
    Load tasks
    Search for matching task

    IF task does not exist
        Display error
    ELSE
        Mark task completed
        Save tasks
        Display success
END
```

Pseudocode does not need perfect syntax.

Its purpose is to clarify the logic before implementation.

---

# 6. Predict Before Running Code

Before executing code, predict the result.

Example:

```python
numbers = [1, 2, 3]
numbers.append(4)

print(numbers)
```

Ask:

```text
What will the list contain?
```

Expected:

```text
[1, 2, 3, 4]
```

Prediction exercises help learners understand cause and effect.

---

# 7. Trace Code by Hand

For a short program, write down the value of each variable after every instruction.

```python
count = 2
count = count + 3
count = count * 2
```

Trace:

| Instruction | `count` |
|---|---:|
| `count = 2` | 2 |
| `count = count + 3` | 5 |
| `count = count * 2` | 10 |

This is useful for understanding:

- Assignments.
- Loops.
- Conditions.
- Counters.
- State changes.

---

# 8. Inspect Values

When behavior is unexpected, inspect the values:

```python
print(value)
print(type(value))
```

Use `repr()` to reveal spaces:

```python
print(repr(value))
```

Example:

```python
command = input("Command: ")

print(f"Command: {command!r}")
print(f"Type: {type(command)}")
```

This may reveal:

```text
Command: ' list '
Type: <class 'str'>
```

The program can normalize it:

```python
command = command.strip().lower()
```

---

# 9. Read Errors as Information

Suppose Python reports:

```text
NameError: name 'task_id' is not defined
```

This tells you:

- The problem is a `NameError`.
- Python cannot find `task_id`.
- The issue is likely a spelling, scope, or assignment problem.

Suppose Python reports:

```text
IndexError: list index out of range
```

This suggests:

- A list or tuple was indexed.
- The requested position does not exist.
- The collection may be empty or shorter than expected.

The error message narrows the investigation.

---

# 10. Read Tracebacks from the Bottom

Example:

```text
Traceback (most recent call last):
  File "main.py", line 12, in <module>
    main()
  File "main.py", line 8, in main
    print(tasks[3])
IndexError: list index out of range
```

Start at the bottom:

```text
IndexError: list index out of range
```

Then find:

```text
File "main.py", line 8
```

Inspect:

```python
print(tasks[3])
```

Check the length:

```python
print(len(tasks))
```

---

# 11. Build Minimal Examples

If a large program fails, reduce it.

Instead of debugging the entire application, isolate the suspected behavior:

```python
stored_id = 1
entered_id = "1"

print(stored_id == entered_id)
```

Output:

```text
False
```

Inspect types:

```python
print(type(stored_id))
print(type(entered_id))
```

Output:

```text
<class 'int'>
<class 'str'>
```

The problem is now obvious.

---

# 12. Change One Thing at a Time

Suppose the task manager fails.

Do not simultaneously change:

- The JSON format.
- The task dictionary.
- The CLI parser.
- The storage path.
- The display function.

Instead:

1. Test the JSON file.
2. Test loading.
3. Test finding.
4. Test updating.
5. Test saving.
6. Test the complete command.

This identifies the failing component.

---

# 13. Test Small Functions Independently

Suppose you have:

```python
def count_completed(tasks):
    return sum(
        1 for task in tasks
        if task["completed"]
    )
```

Test it directly:

```python
tasks = [
    {"completed": True},
    {"completed": False},
    {"completed": True},
]

result = count_completed(tasks)

print(result)
```

Expected:

```text
2
```

This is easier than testing the entire CLI first.

---

# 14. Test Success and Failure

For every important feature, test:

- A normal valid case.
- An empty case.
- A missing case.
- An invalid case.
- A boundary case.

For task creation:

```text
Learn Python
```

```text
(empty)
```

```text
(spaces only)
```

For task IDs:

```text
1
0
-1
abc
999
```

For the organizer:

```text
Existing directory
Missing directory
Empty directory
File instead of directory
Duplicate file name
```

---

# 15. Test Boundaries

A boundary is an edge of the allowed range.

For a task ID that must be positive:

```text
0 → invalid
1 → valid
```

For an age from `0` through `120`:

```text
-1 → invalid
0 → valid
120 → valid
121 → invalid
```

Boundary tests reveal mistakes in comparison operators.

For example:

```python
if age > 0 and age < 120:
```

does not accept `0` or `120`.

If the intended range is inclusive, use:

```python
if age >= 0 and age <= 120:
```

---

# 16. Separate Data, Logic, and Output

A function that performs every task is hard to debug:

```python
def run_everything():
    # Read input
    # Validate input
    # Load JSON
    # Change tasks
    # Save JSON
    # Print output
    ...
```

Prefer:

```python
def read_task_id():
    ...


def load_tasks():
    ...


def complete_task():
    ...


def save_tasks():
    ...


def display_task():
    ...
```

Each function has a focused role.

---

# 17. Use Clear Names

Clear names make problems easier to identify.

Prefer:

```python
completed_tasks = 3
```

over:

```python
x = 3
```

Prefer:

```python
task_id_text = input("Task ID: ")
```

over:

```python
a = input("ID: ")
```

A name should communicate what a value represents.

---

# 18. Document Assumptions

Write down assumptions such as:

```text
Task IDs are positive integers.
Task titles cannot be empty.
The JSON root value must be a list.
Each task must contain id, title, and completed.
The organizer processes only direct files.
The organizer does not overwrite existing files.
```

These assumptions can become:

- Validation rules.
- Error messages.
- Tests.
- Documentation.

---

# 19. Use Assertions for Internal Assumptions

Assertions check conditions that should be true inside the program:

```python
assert isinstance(tasks, list)
```

```python
assert task_id > 0
```

```python
assert "title" in task
```

Include messages when useful:

```python
assert tasks, "Expected at least one task."
```

Assertions are mainly for programmer assumptions. User input should receive normal validation messages.

---

# 20. Keep a Debugging Log

Use this template:

```text
Date:
____________________________________________________________

Program:
____________________________________________________________

Command:
____________________________________________________________

Expected behavior:
____________________________________________________________

Actual behavior:
____________________________________________________________

Error message:
____________________________________________________________

Values inspected:
____________________________________________________________

What I tried:
____________________________________________________________

Solution:
____________________________________________________________

What I learned:
____________________________________________________________
```

Writing down solutions helps you recognize recurring patterns.

---

# 21. Use a Test Log

For manual testing:

```text
Test name:
____________________________________________________________

Input or command:
____________________________________________________________

Expected result:
____________________________________________________________

Actual result:
____________________________________________________________

Pass or fail:
____________________________________________________________

Notes:
____________________________________________________________
```

Example:

```text
Test name:
Complete missing task

Input or command:
python -m foundation_cli complete 999

Expected result:
Error: No task found with ID 999.

Actual result:
Error: No task found with ID 999.

Pass or fail:
Pass
```

---

# 22. Ask Precise Questions

When asking for help, include:

1. What you are trying to do.
2. The exact command.
3. The complete error.
4. The relevant code.
5. Expected behavior.
6. Actual behavior.
7. What you already tried.

Weak question:

```text
My Python program is broken.
```

Better question:

```text
I ran:

python -m foundation_cli complete 2

I expected task 2 to be completed.

Instead, I received:

Error: No task found with ID 2.

The JSON file contains a task with ID 2.

I checked that the command-line argument is an integer.
```

Precise questions are easier to answer.

---

# 23. Problem-Solving Practice

## Exercise 1: Break Down a Requirement

Requirement:

> Build a program that lets users add and complete tasks.

Break it into at least eight steps:

```text
1. _________________________________________________________

2. _________________________________________________________

3. _________________________________________________________

4. _________________________________________________________

5. _________________________________________________________

6. _________________________________________________________

7. _________________________________________________________

8. _________________________________________________________
```

---

## Exercise 2: Identify Input, Processing, and Output

Requirement:

> Ask the user for the width and height of a rectangle and display its area.

Input:

```text
____________________________________________________________
```

Processing:

```text
____________________________________________________________
```

Output:

```text
____________________________________________________________
```

---

## Exercise 3: Predict the Result

What does this program print?

```python
values = [1, 2, 3]

values.append(4)
values[0] = 10

print(values)
```

Answer:

```text
____________________________________________________________
```

---

## Exercise 4: Find the Problem

What is wrong?

```python
age_text = input("Age: ")

if age_text >= 18:
    print("Adult")
```

Answer:

```text
____________________________________________________________

____________________________________________________________
```

Correct version:

```python
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

## Exercise 5: Design a Test

Feature:

> Add a task with a title.

Successful test:

```text
Input:

____________________________________________________________

Expected result:

____________________________________________________________
```

Failure test:

```text
Input:

____________________________________________________________

Expected result:

____________________________________________________________
```

---

# 24. Debugging Workflow

Use this sequence whenever a problem occurs:

```text
1. Describe expected behavior.
2. Describe actual behavior.
3. Record the exact command.
4. Read the complete error.
5. Identify the error type.
6. Find the file and line.
7. Inspect values and types.
8. Check paths and files.
9. Create a minimal reproduction.
10. Form a hypothesis.
11. Change one thing.
12. Run the program again.
13. Run automated tests.
14. Record the solution.
```

---

# 25. Primer 5 Review Questions

## Question 1

Why should a large requirement be divided into smaller steps?

```text
____________________________________________________________

____________________________________________________________
```

## Question 2

What is pseudocode?

```text
____________________________________________________________
```

## Question 3

Why should you predict program output before running code?

```text
____________________________________________________________
```

## Question 4

Why is `repr()` useful while debugging?

```text
____________________________________________________________
```

## Question 5

Why should you change one thing at a time?

```text
____________________________________________________________

____________________________________________________________
```

## Question 6

What should be tested besides the successful case?

```text
____________________________________________________________
```

## Question 7

What is a regression test?

```text
____________________________________________________________
```

## Question 8

Why are clear variable names helpful during debugging?

```text
____________________________________________________________

____________________________________________________________
```

---

# 26. Primer 5 Readiness Checklist

Before starting Part 1, confirm that you can:

- [ ] Break a requirement into steps.
- [ ] Identify input, processing, and output.
- [ ] Write basic pseudocode.
- [ ] Predict simple program behavior.
- [ ] Trace variable values manually.
- [ ] Read the bottom of a traceback.
- [ ] Identify an exception type.
- [ ] Inspect values with `print()`.
- [ ] Inspect types with `type()`.
- [ ] Inspect invisible characters with `repr()`.
- [ ] Reduce a problem to a minimal example.
- [ ] Change one thing at a time.
- [ ] Test success and failure cases.
- [ ] Record a debugging solution.
- [ ] Ask a precise technical question.

---

# Primer 5 Complete

You now have a practical problem-solving process:

```text
Understand
    ↓
Break down
    ↓
Predict
    ↓
Implement
    ↓
Run
    ↓
Inspect
    ↓
Debug
    ↓
Test
    ↓
Improve
```
