# Python Foundations: Student Workbook

## From Zero to Functional Code

This workbook accompanies the **Python Foundations** series.

Use it to:

- Record what you learn.
- Complete hands-on exercises.
- Write and test Python code.
- Track your progress.
- Document errors and solutions.
- Build the capstone application step by step.

This workbook is divided into sections so it can be completed alongside the course.

---

# Workbook Contents

```text
Part 1: Environment and Basic Syntax
Part 2: Collections
Part 3: Program Flow
Part 4: Functions, Files, JSON, and Exceptions
Part 5: Capstone Project
Appendix A: Command Reference
Appendix B: Syntax Reference
Appendix C: Collection Decision Guide
Appendix D: Common Errors
Appendix E: Debugging Checklist
```

---

# How to Use This Workbook

For each lesson:

1. Read the concept explanation.
2. Type the example yourself.
3. Run the program.
4. Complete the exercise.
5. Record the result.
6. Write down any errors.
7. Explain the concept in your own words.
8. Mark the checkpoint complete.

Do not only copy and paste code. Typing examples yourself helps you notice syntax, indentation, punctuation, and structure.

---

# Progress Tracker

| Section | Started | Completed |
|---|---:|---:|
| Part 1: Environment and Syntax | [ ] | [ ] |
| Part 2: Collections | [ ] | [ ] |
| Part 3: Program Flow | [ ] | [ ] |
| Part 4: Functions and IO | [ ] | [ ] |
| Part 5: Capstone | [ ] | [ ] |
| Appendix A: Commands | [ ] | [ ] |
| Appendix B: Syntax | [ ] | [ ] |
| Appendix C: Collections | [ ] | [ ] |
| Appendix D: Errors | [ ] | [ ] |
| Appendix E: Debugging | [ ] | [ ] |

---

# Learning Log

Use this space throughout the series.

## What I Already Know

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## What I Want to Build

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## Questions I Have

```text
1. _________________________________________________________

2. _________________________________________________________

3. _________________________________________________________
```

---

# Part 1: Environment and Basic Syntax

## Learning Goals

By the end of Part 1, you should be able to:

- Check your Python version.
- Create a project directory.
- Create and activate a virtual environment.
- Run a Python file.
- Use the interactive Python shell.
- Write comments.
- Understand indentation.
- Create variables.
- Use strings, integers, floats, and Booleans.
- Convert values between types.
- Read basic user input.
- Explain a basic type error.

---

# Activity 1: Check Python

Open a terminal and run the appropriate command.

### Windows

```bash
python --version
```

If necessary:

```bash
py --version
```

### macOS or Linux

```bash
python3 --version
```

Record your result:

```text
Python command I used:

____________________________________________________________

Python version:

____________________________________________________________
```

## Checkpoint

Mark each statement when complete:

- [ ] I know which command starts Python on my computer.
- [ ] I confirmed that Python 3 is installed.
- [ ] I recorded my Python version.
- [ ] I know how to check the version again.

---

# Activity 2: Create the Project Directory

Run:

```bash
mkdir python-foundations
cd python-foundations
```

Check your current directory.

### Windows PowerShell

```powershell
Get-Location
```

### macOS or Linux

```bash
pwd
```

Record the path:

```text
My project path:

____________________________________________________________
```

## Reflection

Why is it useful to keep project files in a dedicated directory?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 3: Create a Virtual Environment

Create the environment:

```bash
python -m venv .venv
```

If your system uses `python3`:

```bash
python3 -m venv .venv
```

Activate it.

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

### macOS or Linux

```bash
source .venv/bin/activate
```

Confirm that the terminal prompt begins with:

```text
(.venv)
```

Check which Python is active:

```bash
python -c "import sys; print(sys.executable)"
```

Record the result:

```text
Active Python executable:

____________________________________________________________
```

## Checkpoint

- [ ] I created `.venv`.
- [ ] I activated `.venv`.
- [ ] My prompt displays `(.venv)`.
- [ ] I confirmed the active Python executable.
- [ ] I understand why virtual environments are useful.

---

# Activity 4: Run Your First Program

Create:

```text
hello.py
```

Write:

```python
print("Hello, Python!")
print("My first program is running.")
```

Run:

```bash
python hello.py
```

Record the output:

```text
____________________________________________________________

____________________________________________________________
```

## Modify the Program

Change the second line so it displays your name:

```python
print("Hello, Python!")
print("My name is __________.")
```

Run it again.

What changed?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 5: Interactive Python

Start the interactive shell:

```bash
python
```

Run these expressions:

```python
2 + 3
10 * 4
20 / 5
"Python" + " Foundations"
```

Record the results:

```text
2 + 3 = _________________________________________________

10 * 4 = ________________________________________________

20 / 5 = ________________________________________________

"Python" + " Foundations" = ______________________________
```

Exit the shell:

```python
exit()
```

## Reflection

When might the interactive shell be useful?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 6: Comments

Create or update:

```text
comments.py
```

Write:

```python
# This program displays a short message.

message = "Python is readable."
print(message)
```

Run it:

```bash
python comments.py
```

## Exercise

Add a comment explaining what this calculation does:

```python
minutes = 5
seconds = minutes * 60

print(seconds)
```

Your completed code:

```python
____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 7: Indentation

Write this program:

```python
is_ready = True

if is_ready:
    print("The program is ready.")
```

Run it.

Now deliberately remove the indentation:

```python
is_ready = True

if is_ready:
print("The program is ready.")
```

Run the program again and record the error type:

```text
Error type:

____________________________________________________________
```

Restore the indentation.

## Reflection

Why is indentation important in Python?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 8: Variables

Create:

```text
variables.py
```

Write:

```python
name = "Ada"
age = 36
city = "London"

print(name)
print(age)
print(city)
```

Run it.

## Exercise

Replace the values with your own information:

```python
name = "________________"
age = ________________
city = "________________"
```

Add a variable for your favorite programming topic:

```python
favorite_topic = "________________"
```

Display it with:

```python
print(favorite_topic)
```

---

# Activity 9: Data Types

Complete the table.

| Value | Python type |
|---|---|
| `"Hello"` | __________________ |
| `42` | __________________ |
| `3.14` | __________________ |
| `True` | __________________ |
| `None` | __________________ |

Create:

```text
types.py
```

Write:

```python
text_value = "Hello"
integer_value = 42
float_value = 3.14
boolean_value = True

print(type(text_value))
print(type(integer_value))
print(type(float_value))
print(type(boolean_value))
```

Run it and record the output:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 10: Arithmetic

Complete the table.

| Expression | Result |
|---|---:|
| `8 + 3` | ______ |
| `8 - 3` | ______ |
| `8 * 3` | ______ |
| `8 / 3` | ______ |
| `8 // 3` | ______ |
| `8 % 3` | ______ |
| `8 ** 3` | ______ |

Write a program:

```python
width = 8
height = 5

area = width * height
perimeter = 2 * (width + height)

print(f"Area: {area}")
print(f"Perimeter: {perimeter}")
```

Expected output:

```text
Area: 40
Perimeter: 26
```

## Exercise

Change the width and height.

```text
New width: _______________________________________________

New height: ______________________________________________

New area: ________________________________________________

New perimeter: ___________________________________________
```

---

# Activity 11: Strings and F-Strings

Write:

```python
first_name = "Ada"
last_name = "Lovelace"

full_name = first_name + " " + last_name

print(full_name)
```

Now use an f-string:

```python
age = 36
city = "London"

print(f"{full_name} is {age} years old and lives in {city}.")
```

Expected output:

```text
Ada Lovelace is 36 years old and lives in London.
```

## Exercise

Create an f-string sentence containing:

- Your name.
- Your age.
- Your city.
- Your learning goal.

```python
____________________________________________________________

____________________________________________________________
```

---

# Activity 12: Type Conversion

Write:

```python
age_text = "36"
age = int(age_text)

print(age + 1)
```

Expected output:

```text
37
```

Complete the conversions:

```python
number_text = "42"
number = ______________________
```

```python
price_text = "19.99"
price = ______________________
```

```python
number = 42
number_text = ______________________
```

## Reflection

Why can this fail?

```python
age = "36"
print(age + 1)
```

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 13: User Input

Create:

```text
greeting.py
```

Write:

```python
name = input("What is your name? ")

print(f"Hello, {name}!")
```

Run it and record your interaction:

```text
What is your name? ________________________________________

Program output:

____________________________________________________________
```

Now create a simple age program:

```python
age_text = input("How old are you? ")
age = int(age_text)

print(f"Next year, you will be {age + 1}.")
```

Test it with a valid number.

```text
Input:

____________________________________________________________

Output:

____________________________________________________________
```

---

# Activity 14: Personal Report Project

Create:

```text
projects/personal_report.py
```

Write:

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

Run:

```bash
python projects/personal_report.py
```

## Modify the Project

Replace the example values with your own:

```python
name = "________________________________"
age = ________________________________
city = "________________________________"
height_meters = ______________________
is_learning_python = _________________
```

Record your output:

```text
Personal Report
---------------

____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 15: Price Calculator

Create:

```text
projects/price_calculator.py
```

Write:

```python
item_name = input("What are you buying? ")
price_text = input("What is the price? ")
quantity_text = input("How many do you need? ")

price = float(price_text)
quantity = int(quantity_text)

total = price * quantity

print()
print("Purchase Summary")
print("----------------")
print(f"Item: {item_name}")
print(f"Quantity: {quantity}")
print(f"Price per item: ${price:.2f}")
print(f"Total: ${total:.2f}")
```

Run the program.

Record your test:

```text
Item:

____________________________________________________________

Price:

____________________________________________________________

Quantity:

____________________________________________________________

Total:

____________________________________________________________
```

---

# Activity 16: Add Tax

Modify the price calculator.

Add:

```python
tax_rate = 0.20
tax = total * tax_rate
grand_total = total + tax
```

Display:

```python
print(f"Subtotal: ${total:.2f}")
print(f"Tax: ${tax:.2f}")
print(f"Grand total: ${grand_total:.2f}")
```

Test your program:

```text
Subtotal: ________________________________________________

Tax: ____________________________________________________

Grand total: _____________________________________________
```

---

# Activity 17: Investigate a Type Error

Create:

```text
type_error_example.py
```

Write:

```python
age = "36"

print(age + 1)
```

Run it.

Record:

```text
Error type:

____________________________________________________________

Error message:

____________________________________________________________
```

Fix the program:

```python
age = "36"
age_as_number = int(age)

print(age_as_number + 1)
```

Record the corrected output:

```text
____________________________________________________________
```

## What Caused the Error?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Part 1 Review

Answer the following questions.

## 1. What does a virtual environment do?

```text
____________________________________________________________

____________________________________________________________
```

## 2. What is the difference between `=` and `==`?

```text
____________________________________________________________

____________________________________________________________
```

## 3. What type does `input()` return?

```text
____________________________________________________________
```

## 4. How do you convert text to an integer?

```text
____________________________________________________________
```

## 5. Why is indentation important?

```text
____________________________________________________________

____________________________________________________________
```

## 6. What is the difference between an integer and a float?

```text
____________________________________________________________
```

---

# Part 1 Completion Checklist

Mark each item when you can complete it without assistance.

- [ ] Check the installed Python version.
- [ ] Create a project directory.
- [ ] Create a virtual environment.
- [ ] Activate the virtual environment.
- [ ] Run a Python file.
- [ ] Open the Python interactive shell.
- [ ] Write a comment.
- [ ] Explain Python indentation.
- [ ] Create and use variables.
- [ ] Identify basic data types.
- [ ] Perform arithmetic.
- [ ] Use f-strings.
- [ ] Convert a string to an integer.
- [ ] Read user input.
- [ ] Run the personal report project.
- [ ] Run the price calculator.
- [ ] Explain and fix a `TypeError`.

---

# Personal Reflection

What was easiest in Part 1?

```text
____________________________________________________________

____________________________________________________________
```

What was most difficult?

```text
____________________________________________________________

____________________________________________________________
```

What do you want to practice again?

```text
____________________________________________________________

____________________________________________________________
```

What program can you now build that you could not build before?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 1 Complete

You have completed the workbook activities for:

```text
Part 1: Environment and Basic Syntax
```

The next workbook section is:

# Part 2: Structuring Data

It will cover:

- Lists.
- Tuples.
- Dictionaries.
- Sets.
- Nested collections.
- Collection exercises.
- A small in-memory task manager.

---
You’re right—the workbook response was cut off after Part 1. I’ll continue in smaller sections.

# Student Workbook — Part 2: Structuring Data

This section covers:

- Lists.
- Tuples.
- Dictionaries.
- Sets.
- Nested collections.
- Choosing the right collection.
- A small in-memory task manager.

---

# Part 2 Learning Goals

By the end of this section, you should be able to:

- Create and modify lists.
- Access list items by index.
- Slice lists.
- Add and remove list values.
- Create and unpack tuples.
- Create and update dictionaries.
- Read dictionary values safely.
- Create sets.
- Remove duplicate values.
- Perform basic set operations.
- Store dictionaries inside lists.
- Choose an appropriate collection type.

---

# Activity 1: Create a List

Create:

```text
projects/favorite_foods.py
```

Add:

```python
favorite_foods = [
    "pizza",
    "rice",
    "apples",
]

print(favorite_foods)
```

Run:

```bash
python projects/favorite_foods.py
```

Record the output:

```text
____________________________________________________________
```

## Add More Foods

Add two more values:

```python
favorite_foods.append("________________")
favorite_foods.append("________________")
```

Print the list again.

Final list:

```text
____________________________________________________________
```

---

# Activity 2: List Indexes

Use this list:

```python
tasks = [
    "Learn Python",
    "Practice collections",
    "Build a CLI tool",
]
```

Complete the table:

| Expression | Result |
|---|---|
| `tasks[0]` | __________________________ |
| `tasks[1]` | __________________________ |
| `tasks[2]` | __________________________ |
| `tasks[-1]` | __________________________ |
| `tasks[-2]` | __________________________ |

Write:

```python
tasks = [
    "Learn Python",
    "Practice collections",
    "Build a CLI tool",
]

print(tasks[0])
print(tasks[-1])
```

Expected output:

```text
Learn Python
Build a CLI tool
```

---

# Activity 3: Change a List Item

Create:

```python
tasks = [
    "Learn Python",
    "Practice collections",
    "Build a CLI tool",
]

tasks[1] = "Practice dictionaries"

print(tasks)
```

Expected output:

```text
['Learn Python', 'Practice dictionaries', 'Build a CLI tool']
```

## Exercise

Change the third task:

```python
tasks[2] = "________________________________"
```

Final task list:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 4: Add List Items

Use the following list:

```python
tasks = [
    "Learn Python",
]
```

Add one task with `append()`:

```python
tasks.append("Practice loops")
```

Insert a task at index `1`:

```python
tasks.insert(1, "Practice conditions")
```

Add several tasks with `extend()`:

```python
tasks.extend(
    [
        "Read documentation",
        "Build a project",
    ]
)
```

Print the final list:

```python
print(tasks)
```

Record the order:

```text
1. ________________________________________________________

2. ________________________________________________________

3. ________________________________________________________

4. ________________________________________________________

5. ________________________________________________________
```

---

# Activity 5: Remove List Items

Create:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]
```

Remove by value:

```python
tasks.remove("Practice loops")
```

Add another task:

```python
tasks.append("Read documentation")
```

Remove the final task with `pop()`:

```python
removed_task = tasks.pop()

print(f"Removed: {removed_task}")
print(tasks)
```

Record the output:

```text
Removed:

____________________________________________________________

Remaining tasks:

____________________________________________________________
```

---

# Activity 6: List Length and Membership

Write:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

print(f"Number of tasks: {len(tasks)}")
print("Learn Python" in tasks)
print("Read documentation" in tasks)
```

Expected output:

```text
Number of tasks: 3
True
False
```

## Exercise

Add a condition:

```python
if "Build a CLI tool" in tasks:
    print("The CLI task exists.")
```

Now check for a missing task:

```python
if "Read documentation" not in tasks:
    print("The documentation task has not been added.")
```

---

# Activity 7: List Slicing

Create:

```python
topics = [
    "variables",
    "strings",
    "lists",
    "dictionaries",
    "sets",
]
```

Complete the table:

| Expression | Values |
|---|---|
| `topics[:2]` | __________________________ |
| `topics[2:]` | __________________________ |
| `topics[1:4]` | __________________________ |
| `topics[-2:]` | __________________________ |

Test:

```python
print(topics[:2])
print(topics[2:])
print(topics[1:4])
print(topics[-2:])
```

---

# Activity 8: Sorting

Create:

```python
scores = [82, 95, 71, 88]
```

Sort the list in place:

```python
scores.sort()

print(scores)
```

Expected output:

```text
[71, 82, 88, 95]
```

Sort in reverse order:

```python
scores.sort(reverse=True)

print(scores)
```

Expected output:

```text
[95, 88, 82, 71]
```

## Exercise

Create a list of five names and sort them alphabetically.

```python
names = [
    "________________",
    "________________",
    "________________",
    "________________",
    "________________",
]

names.sort()

print(names)
```

---

# Activity 9: Tuples

Create:

```python
coordinates = (51.5074, -0.1278)

print(coordinates)
print(coordinates[0])
print(coordinates[1])
```

Record the values:

```text
First value:

____________________________________________________________

Second value:

____________________________________________________________
```

Try to change the first value:

```python
coordinates[0] = 40.7128
```

Record the error type:

```text
____________________________________________________________
```

## Reflection

Why might a tuple be suitable for coordinates?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 10: Tuple Unpacking

Write:

```python
person = ("Ada Lovelace", 36, "London")

name, age, city = person

print(name)
print(age)
print(city)
```

Expected output:

```text
Ada Lovelace
36
London
```

## Exercise

Create and unpack a tuple containing:

- A product name.
- A price.
- A quantity.

```python
product = (
    "________________",
    ________________,
    ________________,
)

product_name, price, quantity = product

print(product_name)
print(price)
print(quantity)
```

---

# Activity 11: Dictionaries

Create:

```python
contact = {
    "name": "Ada Lovelace",
    "email": "ada@example.com",
    "city": "London",
}
```

Print the values:

```python
print(contact["name"])
print(contact["email"])
print(contact["city"])
```

Record the output:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 12: Add and Update Dictionary Values

Start with:

```python
task = {
    "title": "Learn Python",
    "completed": False,
}
```

Add a priority:

```python
task["priority"] = "high"
```

Add an ID:

```python
task["id"] = 1
```

Update the completion status:

```python
task["completed"] = True
```

Print the dictionary:

```python
print(task)
```

Expected result:

```python
{
    "title": "Learn Python",
    "completed": True,
    "priority": "high",
    "id": 1,
}
```

The exact display order may depend on the order in which keys were inserted.

---

# Activity 13: Safe Dictionary Lookup

Create:

```python
task = {
    "title": "Learn Python",
    "completed": False,
}
```

This may fail:

```python
print(task["priority"])
```

Use `get()` instead:

```python
priority = task.get("priority", "normal")

print(priority)
```

Expected output:

```text
normal
```

## Exercise

Read an optional due date:

```python
due_date = task.get(
    "due_date",
    "No due date",
)

print(due_date)
```

---

# Activity 14: Dictionary Membership

Write:

```python
task = {
    "title": "Learn Python",
    "completed": False,
}
```

Check for keys:

```python
if "title" in task:
    print("The task has a title.")

if "priority" not in task:
    print("The task has no priority.")
```

Check for a value:

```python
if "Learn Python" in task.values():
    print("The title was found.")
```

---

# Activity 15: Loop Through a Dictionary

Create:

```python
person = {
    "name": "Ada",
    "age": 36,
    "city": "London",
}
```

Loop through keys:

```python
for key in person:
    print(key)
```

Loop through values:

```python
for value in person.values():
    print(value)
```

Loop through key-value pairs:

```python
for key, value in person.items():
    print(f"{key}: {value}")
```

Record one line of output:

```text
____________________________________________________________
```

---

# Activity 16: Sets

Create:

```python
tags = {
    "python",
    "cli",
    "beginner",
    "python",
}

print(tags)
```

How many unique values are present?

```python
print(len(tags))
```

Record the number:

```text
____________________________________________________________
```

The order of set output may vary.

## Reflection

Why did `"python"` appear only once?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 17: Set Membership

Create:

```python
allowed_roles = {
    "admin",
    "editor",
    "viewer",
}
```

Write:

```python
role = "editor"

if role in allowed_roles:
    print("Access allowed.")
else:
    print("Access denied.")
```

Change the role to:

```python
role = "guest"
```

Record the output:

```text
____________________________________________________________
```

---

# Activity 18: Set Operations

Create:

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

Find the union:

```python
print(python_topics | completed_topics)
```

Find the intersection:

```python
print(python_topics & completed_topics)
```

Find the difference:

```python
print(python_topics - completed_topics)
```

Complete the table:

| Operation | Meaning |
|---|---|
| `|` | __________________________ |
| `&` | __________________________ |
| `-` | __________________________ |
| `^` | __________________________ |

---

# Activity 19: Choose the Collection

Choose the best collection type.

| Situation | Choice |
|---|---|
| A shopping list that changes | __________________ |
| A fixed screen size | __________________ |
| A user's named profile fields | __________________ |
| A collection of unique file extensions | __________________ |
| Multiple task records with IDs and titles | __________________ |
| A numbered menu | __________________ |
| A fixed latitude and longitude pair | __________________ |

Possible answers:

```text
list
tuple
dictionary
set
list of dictionaries
```

---

# Activity 20: Lists of Dictionaries

Create:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
    {
        "id": 2,
        "title": "Practice collections",
        "completed": True,
    },
]
```

Access the first title:

```python
print(tasks[0]["title"])
```

Access the second completion state:

```python
print(tasks[1]["completed"])
```

Loop through all tasks:

```python
for task in tasks:
    print(
        f"{task['id']}: "
        f"{task['title']} "
        f"({task['completed']})"
    )
```

Record the output:

```text
____________________________________________________________

____________________________________________________________
```

---

# Mini-Project: In-Memory Task Manager

Create:

```text
projects/task_collection.py
```

Write:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python variables",
        "completed": True,
    },
    {
        "id": 2,
        "title": "Practice lists and dictionaries",
        "completed": False,
    },
    {
        "id": 3,
        "title": "Build a small program",
        "completed": False,
    },
]

print("Task List")
print("---------")

for task in tasks:
    if task["completed"]:
        status = "x"
    else:
        status = " "

    print(
        f"[{status}] "
        f"{task['id']} - "
        f"{task['title']}"
    )

completed_count = 0

for task in tasks:
    if task["completed"]:
        completed_count += 1

print()
print(f"Total tasks: {len(tasks)}")
print(f"Completed tasks: {completed_count}")
print(
    f"Remaining tasks: "
    f"{len(tasks) - completed_count}"
)
```

Run:

```bash
python projects/task_collection.py
```

Expected output:

```text
Task List
---------
[x] 1 - Learn Python variables
[ ] 2 - Practice lists and dictionaries
[ ] 3 - Build a small program

Total tasks: 3
Completed tasks: 1
Remaining tasks: 2
```

---

# Mini-Project Exercises

## Exercise A: Add a Task

Add this dictionary:

```python
tasks.append(
    {
        "id": 4,
        "title": "Review collection types",
        "completed": False,
    }
)
```

Where did you add it?

```text
____________________________________________________________
```

---

## Exercise B: Complete a Task

Change task `2` to completed:

```python
tasks[1]["completed"] = True
```

Run the program again.

Updated completed count:

```text
____________________________________________________________
```

---

## Exercise C: Add Priorities

Add a `"priority"` field to every task:

```python
"priority": "high",
```

or:

```python
"priority": "normal",
```

Update the display:

```python
print(
    f"[{status}] "
    f"{task['id']} - "
    f"{task['title']} "
    f"({task['priority']})"
)
```

Example:

```text
[x] 1 - Learn Python variables (high)
```

---

# Part 2 Review

## 1. Which collection is ordered and changeable?

```text
____________________________________________________________
```

## 2. Which collection is ordered but immutable?

```text
____________________________________________________________
```

## 3. Which collection stores key-value pairs?

```text
____________________________________________________________
```

## 4. Which collection automatically removes duplicates?

```text
____________________________________________________________
```

## 5. What is the first index of a list?

```text
____________________________________________________________
```

## 6. What method safely reads a possibly missing dictionary key?

```text
____________________________________________________________
```

## 7. What is the difference between `remove()` and `pop()`?

```text
____________________________________________________________

____________________________________________________________
```

## 8. Why is a list of dictionaries useful for the task manager?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 2 Completion Checklist

- [ ] Create a list.
- [ ] Access list values by index.
- [ ] Use negative indexes.
- [ ] Change a list item.
- [ ] Append an item.
- [ ] Insert an item.
- [ ] Extend a list.
- [ ] Remove by value.
- [ ] Remove by index.
- [ ] Slice a list.
- [ ] Sort a list.
- [ ] Create a tuple.
- [ ] Explain tuple immutability.
- [ ] Unpack a tuple.
- [ ] Create a dictionary.
- [ ] Read a dictionary value.
- [ ] Add and update dictionary values.
- [ ] Use `get()` with a default.
- [ ] Loop through dictionary items.
- [ ] Create a set.
- [ ] Remove duplicate values.
- [ ] Use set union.
- [ ] Use set intersection.
- [ ] Use set difference.
- [ ] Store dictionaries in a list.
- [ ] Build the in-memory task manager.

---

# Part 2 Reflection

Which collection type was easiest to understand?

```text
____________________________________________________________
```

Which collection type was most confusing?

```text
____________________________________________________________
```

What is one real-world example of a list?

```text
____________________________________________________________
```

What is one real-world example of a dictionary?

```text
____________________________________________________________
```

What is one real-world example of a set?

```text
____________________________________________________________
```

Explain why the capstone uses a list of dictionaries:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Next Workbook Section

The next section is:

# Part 3: Controlling Program Flow

It will cover:

- Comparison operators.
- `if`, `elif`, and `else`.
- Logical operators.
- `for` loops.
- `while` loops.
- `break`.
- `continue`.
- Input validation.
- An interactive task manager.
---
# Student Workbook — Part 3: Controlling Program Flow

This section covers:

- Comparison operators.
- Conditional statements.
- Logical operators.
- `for` loops.
- `while` loops.
- `break`.
- `continue`.
- Input validation.
- An interactive task manager.

---

# Part 3 Learning Goals

By the end of this section, you should be able to:

- Compare values.
- Use `if`, `elif`, and `else`.
- Combine conditions.
- Loop through collections.
- Generate number sequences with `range()`.
- Use `enumerate()`.
- Repeat input with a `while` loop.
- Stop loops with `break`.
- Skip iterations with `continue`.
- Validate text and numeric input.
- Build a menu-driven task manager.

---

# Activity 1: Comparison Operators

Complete the table.

| Expression | Result |
|---|---|
| `5 == 5` | __________ |
| `5 == 3` | __________ |
| `5 != 3` | __________ |
| `5 > 3` | __________ |
| `5 < 3` | __________ |
| `5 >= 5` | __________ |
| `5 <= 4` | __________ |

The comparison operators are:

| Operator | Meaning |
|---|---|
| `==` | Equal to |
| `!=` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

---

# Activity 2: `if` Statements

Create:

```text
projects/check_age.py
```

Write:

```python
age = 20

if age >= 18:
    print("You are an adult.")
```

Run:

```bash
python projects/check_age.py
```

Expected output:

```text
You are an adult.
```

Change the age to:

```python
age = 15
```

Run it again.

What happened?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 3: `else`

Update the program:

```python
age = 15

if age >= 18:
    print("You are an adult.")
else:
    print("You are not an adult.")
```

Test these values:

```text
Age 15 output:

____________________________________________________________

Age 20 output:

____________________________________________________________
```

Complete the pattern:

```python
if ______________________________:
    ______________________________
else:
    ______________________________
```

---

# Activity 4: `elif`

Create:

```text
projects/grade_checker.py
```

Write:

```python
score = 83

if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
elif score >= 70:
    grade = "C"
elif score >= 60:
    grade = "D"
else:
    grade = "F"

print(f"Grade: {grade}")
```

Test these scores:

| Score | Grade |
|---:|---|
| `95` | __________ |
| `84` | __________ |
| `72` | __________ |
| `61` | __________ |
| `40` | __________ |

## Reflection

Why should higher score thresholds be checked first?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 5: Logical Operators

## `and`

Both conditions must be true:

```python
age = 25
has_ticket = True

if age >= 18 and has_ticket:
    print("Entry allowed.")
else:
    print("Entry denied.")
```

Test these combinations:

| Age | Has ticket | Result |
|---:|---:|---|
| `25` | `True` | __________________ |
| `25` | `False` | __________________ |
| `15` | `True` | __________________ |
| `15` | `False` | __________________ |

---

## `or`

At least one condition must be true:

```python
day = "Saturday"

if day == "Saturday" or day == "Sunday":
    print("It is the weekend.")
else:
    print("It is a weekday.")
```

Test:

```python
day = "Monday"
```

Output:

```text
____________________________________________________________
```

---

## `not`

`not` reverses a Boolean value:

```python
is_completed = False

if not is_completed:
    print("This task still needs attention.")
```

Output:

```text
____________________________________________________________
```

---

# Activity 6: Membership Conditions

Create:

```python
valid_commands = {
    "add",
    "list",
    "complete",
    "remove",
}

command = "list"

if command in valid_commands:
    print("Recognized command.")
else:
    print("Unknown command.")
```

Change the command to:

```python
command = "delete"
```

Record the output:

```text
____________________________________________________________
```

## Exercise

Create a set of allowed file extensions:

```python
allowed_extensions = {
    "________________",
    "________________",
    "________________",
}
```

Check whether `".pdf"` is allowed.

---

# Activity 7: Truthy and Falsy Values

Python treats these values as false:

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

Write:

```python
name = ""

if name:
    print("A name was entered.")
else:
    print("The name is empty.")
```

Expected output:

```text
The name is empty.
```

Now use input:

```python
name = input("Enter your name: ").strip()

if name:
    print(f"Hello, {name}!")
else:
    print("Name cannot be empty.")
```

Test:

1. A normal name.
2. An empty response.
3. Several spaces.

Record what happened:

```text
Normal name:

____________________________________________________________

Empty input:

____________________________________________________________

Spaces only:

____________________________________________________________
```

---

# Activity 8: `for` Loops

Create:

```text
projects/loop_tasks.py
```

Write:

```python
tasks = [
    "Learn Python",
    "Practice conditions",
    "Practice loops",
]

for task in tasks:
    print(task)
```

Run:

```bash
python projects/loop_tasks.py
```

Expected output:

```text
Learn Python
Practice conditions
Practice loops
```

## Exercise

Change the loop to display each task with a label:

```python
for task in tasks:
    print(f"Task: {task}")
```

---

# Activity 9: `range()`

Write:

```python
for number in range(5):
    print(number)
```

Expected output:

```text
0
1
2
3
4
```

Complete the table:

| Expression | Values |
|---|---|
| `range(3)` | __________________ |
| `range(1, 4)` | __________________ |
| `range(0, 10, 2)` | __________________ |
| `range(5, 0, -1)` | __________________ |

## Exercise

Print the numbers from 1 through 10:

```python
for number in range(________________):
    print(number)
```

---

# Activity 10: `enumerate()`

Create:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

for number, task in enumerate(tasks, start=1):
    print(f"{number}. {task}")
```

Expected output:

```text
1. Learn Python
2. Practice loops
3. Build a CLI tool
```

## Exercise

Display a list of five favorite books with numbers starting at one.

```python
books = [
    "________________",
    "________________",
    "________________",
    "________________",
    "________________",
]

for number, book in enumerate(books, start=1):
    print(f"{number}. {book}")
```

---

# Activity 11: Looping Through Task Dictionaries

Write:

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
    if task["completed"]:
        status = "x"
    else:
        status = " "

    print(f"[{status}] {task['id']} - {task['title']}")
```

Expected output:

```text
[x] 1 - Learn Python
[ ] 2 - Practice loops
```

## Exercise

Add a third task and display it.

```python
____________________________________________________________

____________________________________________________________
```

---

# Activity 12: `while` Loops

Create:

```text
projects/countdown.py
```

Write:

```python
count = 5

while count > 0:
    print(count)
    count -= 1

print("Finished!")
```

Run:

```bash
python projects/countdown.py
```

Expected output:

```text
5
4
3
2
1
Finished!
```

Answer:

```text
What causes the loop to stop?

____________________________________________________________

What does count -= 1 do?

____________________________________________________________
```

---

# Activity 13: Infinite Loops

This program never ends:

```python
count = 5

while count > 0:
    print(count)
```

Why?

```text
____________________________________________________________

____________________________________________________________
```

Stop an accidental infinite loop with:

```text
Ctrl+C
```

Fix the program:

```python
count = 5

while count > 0:
    print(count)
    count -= 1
```

---

# Activity 14: `break`

Create:

```text
projects/simple_menu.py
```

Write:

```python
while True:
    print()
    print("Menu")
    print("----")
    print("a - Say hello")
    print("q - Quit")

    choice = input("Choose an option: ").strip().lower()

    if choice == "a":
        print("Hello.")
    elif choice == "q":
        print("Goodbye.")
        break
    else:
        print("Unknown option.")
```

Run:

```bash
python projects/simple_menu.py
```

Test:

```text
a
x
q
```

Record the results:

```text
Option a:

____________________________________________________________

Option x:

____________________________________________________________

Option q:

____________________________________________________________
```

---

# Activity 15: `continue`

Create:

```text
projects/skip_empty_tasks.py
```

Write:

```python
tasks = [
    "Learn Python",
    "",
    "Practice loops",
    "   ",
    "Build a CLI tool",
]

for task in tasks:
    cleaned_task = task.strip()

    if not cleaned_task:
        continue

    print(cleaned_task)
```

Expected output:

```text
Learn Python
Practice loops
Build a CLI tool
```

## Reflection

What does `continue` do?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 16: Validate Required Text

Create:

```text
projects/required_text.py
```

Write:

```python
task_title = input("Enter a task title: ").strip()

if not task_title:
    print("Task title cannot be empty.")
else:
    print(f"Task received: {task_title}")
```

Test:

| Input | Expected result |
|---|---|
| `Learn Python` | __________________ |
| Empty input | __________________ |
| Spaces only | __________________ |

---

# Activity 17: Validate Whole Numbers

Create:

```text
projects/number_validation.py
```

Write:

```python
age_text = input("Enter your age: ").strip()

if age_text.isdigit():
    age = int(age_text)
    print(f"Next year, you will be {age + 1}.")
else:
    print("Please enter a whole number.")
```

Test these inputs:

```text
36
```

```text
tomorrow
```

```text
3.5
```

Record the result:

```text
36:

____________________________________________________________

tomorrow:

____________________________________________________________

3.5:

____________________________________________________________
```

---

# Activity 18: Validate a Range

Write:

```python
age_text = input("Enter your age: ").strip()

if not age_text.isdigit():
    print("Please enter a whole number.")
else:
    age = int(age_text)

    if age < 0 or age > 120:
        print("Please enter an age between 0 and 120.")
    else:
        print(f"Accepted age: {age}.")
```

Test:

| Input | Result |
|---|---|
| `36` | __________________ |
| `0` | __________________ |
| `120` | __________________ |
| `121` | __________________ |
| `-1` | __________________ |
| `abc` | __________________ |

---

# Activity 19: Repeated Validation

Create:

```text
projects/validated_age.py
```

Write:

```python
while True:
    age_text = input("Enter your age: ").strip()

    if not age_text.isdigit():
        print("Please enter a whole number.")
        continue

    age = int(age_text)

    if age < 0 or age > 120:
        print("Please enter an age between 0 and 120.")
        continue

    print(f"Accepted age: {age}")
    break
```

Test this sequence:

```text
tomorrow
200
36
```

Record the interaction:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Mini-Project: Interactive Task Manager

Create:

```text
projects/interactive_tasks.py
```

Add:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
]

next_id = 2

while True:
    print()
    print("Task Manager")
    print("------------")
    print("1. List tasks")
    print("2. Add task")
    print("3. Complete task")
    print("4. Remove task")
    print("5. Quit")

    choice = input("Choose an option: ").strip()

    if choice == "1":
        print()

        if not tasks:
            print("No tasks found.")
        else:
            print("Tasks:")

            for task in tasks:
                if task["completed"]:
                    status = "x"
                else:
                    status = " "

                print(
                    f"[{status}] "
                    f"{task['id']} - "
                    f"{task['title']}"
                )

    elif choice == "2":
        title = input("Enter a task title: ").strip()

        if not title:
            print("Task title cannot be empty.")
            continue

        tasks.append(
            {
                "id": next_id,
                "title": title,
                "completed": False,
            }
        )

        print(f"Task {next_id} created.")
        next_id += 1

    elif choice == "3":
        task_id_text = input(
            "Enter the task ID to complete: "
        ).strip()

        if not task_id_text.isdigit():
            print("Task ID must be a whole number.")
            continue

        task_id = int(task_id_text)
        found_task = False

        for task in tasks:
            if task["id"] == task_id:
                task["completed"] = True
                found_task = True
                print(f"Task {task_id} completed.")
                break

        if not found_task:
            print(f"No task found with ID {task_id}.")

    elif choice == "4":
        task_id_text = input(
            "Enter the task ID to remove: "
        ).strip()

        if not task_id_text.isdigit():
            print("Task ID must be a whole number.")
            continue

        task_id = int(task_id_text)
        found_task = False

        for task in tasks:
            if task["id"] == task_id:
                tasks.remove(task)
                found_task = True
                print(f"Task {task_id} removed.")
                break

        if not found_task:
            print(f"No task found with ID {task_id}.")

    elif choice == "5":
        print("Goodbye.")
        break

    else:
        print("Please choose a number from 1 to 5.")
```

Run:

```bash
python projects/interactive_tasks.py
```

---

# Interactive Task Manager Test Plan

Complete the following test sequence.

## Test 1: List Initial Tasks

Input:

```text
1
```

Expected:

```text
[ ] 1 - Learn Python
```

Actual:

```text
____________________________________________________________
```

---

## Test 2: Add a Task

Input:

```text
2
Practice conditions
```

Expected:

```text
Task 2 created.
```

Actual:

```text
____________________________________________________________
```

---

## Test 3: List Tasks Again

Input:

```text
1
```

Expected:

```text
[ ] 1 - Learn Python
[ ] 2 - Practice conditions
```

Actual:

```text
____________________________________________________________
```

---

## Test 4: Complete a Task

Input:

```text
3
2
```

Expected:

```text
Task 2 completed.
```

Actual:

```text
____________________________________________________________
```

---

## Test 5: List Completed Tasks

Input:

```text
1
```

Expected:

```text
[ ] 1 - Learn Python
[x] 2 - Practice conditions
```

Actual:

```text
____________________________________________________________
```

---

## Test 6: Remove a Task

Input:

```text
4
1
```

Expected:

```text
Task 1 removed.
```

Actual:

```text
____________________________________________________________
```

---

## Test 7: Invalid Menu Choice

Input:

```text
hello
```

Expected:

```text
Please choose a number from 1 to 5.
```

Actual:

```text
____________________________________________________________
```

---

## Test 8: Invalid Task ID

Choose the complete option and enter:

```text
abc
```

Expected:

```text
Task ID must be a whole number.
```

Actual:

```text
____________________________________________________________
```

---

# Part 3 Review

## 1. What is the difference between `if` and `while`?

```text
____________________________________________________________

____________________________________________________________
```

## 2. What does `break` do?

```text
____________________________________________________________
```

## 3. What does `continue` do?

```text
____________________________________________________________
```

## 4. Why does `input()` require conversion before numeric operations?

```text
____________________________________________________________

____________________________________________________________
```

## 5. Why should user input be validated?

```text
____________________________________________________________

____________________________________________________________
```

## 6. What is the purpose of `.strip()`?

```text
____________________________________________________________
```

## 7. What is the purpose of `.lower()`?

```text
____________________________________________________________
```

---

# Part 3 Completion Checklist

- [ ] Use comparison operators.
- [ ] Write an `if` statement.
- [ ] Use `else`.
- [ ] Use `elif`.
- [ ] Combine conditions with `and`.
- [ ] Combine conditions with `or`.
- [ ] Use `not`.
- [ ] Check membership with `in`.
- [ ] Check whether a collection is empty.
- [ ] Write a `for` loop.
- [ ] Use `range()`.
- [ ] Use `enumerate()`.
- [ ] Write a `while` loop.
- [ ] Stop a loop with `break`.
- [ ] Skip an iteration with `continue`.
- [ ] Normalize input with `.strip()`.
- [ ] Normalize input with `.lower()`.
- [ ] Validate required text.
- [ ] Validate whole numbers.
- [ ] Validate numeric ranges.
- [ ] Build the interactive task manager.
- [ ] Test successful and unsuccessful input.

---

# Part 3 Reflection

Which control-flow structure was easiest to understand?

```text
____________________________________________________________
```

Which was most difficult?

```text
____________________________________________________________
```

What happens if a `while` loop never changes its condition?

```text
____________________________________________________________

____________________________________________________________
```

How does the program respond when a user enters invalid input?

```text
____________________________________________________________

____________________________________________________________
```

What improvement would you make to the interactive task manager?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 3 Complete

You have completed:

```text
Part 3: Controlling Program Flow
```

The next workbook section is:

# Part 4: Functions, Files, JSON, and Exceptions

It will cover:

- Functions.
- Parameters.
- Return values.
- Scope.
- Modules.
- Text files.
- `pathlib`.
- JSON.
- Exception handling.
- A persistent task manager.
---
# Student Workbook — Part 4A: Functions and Reusable Code

This is the first section of Part 4.

Part 4 is divided into four sections:

1. **Part 4A:** Functions and reusable code.
2. **Part 4B:** Modules, text files, and `pathlib`.
3. **Part 4C:** JSON, exceptions, and safe file handling.
4. **Part 4D:** Building the persistent task manager.

This section covers:

- Defining functions.
- Calling functions.
- Parameters and arguments.
- Return values.
- Default parameters.
- Type hints.
- Variable scope.
- The `main()` pattern.

---

# Part 4A Learning Goals

By the end of this section, you should be able to:

- Define a function with `def`.
- Call a function.
- Pass arguments.
- Return values.
- Use default parameters.
- Add basic type hints.
- Explain local scope.
- Use the `main()` pattern.
- Separate task operations into functions.

---

# Activity 1: Define and Call a Function

Create:

```text
projects/functions_intro.py
```

Write:

```python
def show_welcome():
    print("Welcome to Python.")
    print("We are learning about functions.")


show_welcome()
```

Run:

```bash
python projects/functions_intro.py
```

Expected output:

```text
Welcome to Python.
We are learning about functions.
```

## Reflection

When does the function actually run?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 2: Call a Function Multiple Times

Write:

```python
def show_separator():
    print("----------------")


show_separator()
print("Task Manager")
show_separator()
```

Expected output:

```text
----------------
Task Manager
----------------
```

## Exercise

Create a function called `show_title()` that prints:

```text
Python Foundations
```

Your code:

```python
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 3: Parameters

Write:

```python
def greet(name):
    print(f"Hello, {name}!")


greet("Ada")
greet("Grace")
greet("Linus")
```

Expected output:

```text
Hello, Ada!
Hello, Grace!
Hello, Linus!
```

Complete the terms:

```text
name is the ______________________.

"Ada" is an ______________________.
```

---

# Activity 4: Multiple Parameters

Write:

```python
def describe_person(name, age, city):
    print(
        f"{name} is {age} years old "
        f"and lives in {city}."
    )


describe_person("Ada", 36, "London")
```

Expected output:

```text
Ada is 36 years old and lives in London.
```

## Exercise

Call the function with your own information:

```python
describe_person(
    "________________",
    ________________,
    "________________",
)
```

---

# Activity 5: Keyword Arguments

Write:

```python
def describe_person(name, age, city):
    print(
        f"{name} is {age} years old "
        f"and lives in {city}."
    )


describe_person(
    name="Ada",
    age=36,
    city="London",
)
```

Keyword arguments use parameter names explicitly.

## Exercise

Call the function in a different order:

```python
describe_person(
    city="________________",
    name="________________",
    age=________________,
)
```

Why does the order still work?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 6: Return Values

Write:

```python
def add_numbers(first, second):
    return first + second


result = add_numbers(3, 4)

print(result)
```

Expected output:

```text
7
```

The function returns a result instead of printing it directly.

## Exercise

Create a function called `multiply_numbers()`:

```python
def multiply_numbers(first, second):
    return ______________________________
```

Test it:

```python
result = multiply_numbers(6, 7)
print(result)
```

Expected result:

```text
42
```

---

# Activity 7: Use a Return Value

Write:

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

Expected output:

```text
Subtotal: $13.50
Tax: $2.70
Grand total: $16.20
```

## Reflection

Why is returning a value more flexible than printing it inside the function?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 8: Return Boolean Values

Write:

```python
def is_even(number):
    return number % 2 == 0


print(is_even(8))
print(is_even(7))
```

Expected output:

```text
True
False
```

Use the function in a condition:

```python
number = 12

if is_even(number):
    print("The number is even.")
else:
    print("The number is odd.")
```

## Exercise

Create an `is_positive()` function:

```python
def is_positive(number):
    return ______________________________
```

Test it with:

```python
print(is_positive(5))
print(is_positive(-2))
```

---

# Activity 9: Default Parameters

Write:

```python
def greet(name, greeting="Hello"):
    return f"{greeting}, {name}!"


print(greet("Ada"))
print(greet("Grace", "Welcome"))
```

Expected output:

```text
Hello, Ada!
Welcome, Grace!
```

## Exercise

Create a task function with a default priority:

```python
def create_task(title, priority="normal"):
    return {
        "title": title,
        "priority": priority,
        "completed": False,
    }
```

Test it:

```python
print(create_task("Learn Python"))
print(create_task("Build a project", "high"))
```

---

# Activity 10: Type Hints

Add type hints to this function:

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"
```

Add type hints to:

```python
def calculate_total(
    price: float,
    quantity: int,
) -> float:
    return price * quantity
```

Add a `None` return type:

```python
def show_message(message: str) -> None:
    print(message)
```

## Practice

Add type hints:

```python
def add_numbers(
    first: ________,
    second: ________,
) -> ________:
    return first + second
```

---

# Activity 11: Local Scope

Write:

```python
def create_message():
    message = "Hello"
    print(message)


create_message()
```

This works because `message` is used inside the function.

Now try:

```python
def create_message():
    message = "Hello"


create_message()
print(message)
```

Record the error:

```text
Error type:

____________________________________________________________
```

## Correct Version

```python
def create_message():
    message = "Hello"
    return message


message = create_message()
print(message)
```

Expected output:

```text
Hello
```

---

# Activity 12: Passing Values Explicitly

This uses a variable outside the function:

```python
application_name = "Task Manager"


def show_application_name():
    print(application_name)


show_application_name()
```

A clearer version passes the value explicitly:

```python
def show_application_name(name):
    print(name)


show_application_name("Task Manager")
```

## Reflection

Why is passing values explicitly useful?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 13: The `main()` Pattern

Create:

```text
projects/main_pattern.py
```

Write:

```python
def main() -> None:
    print("The program is running.")


if __name__ == "__main__":
    main()
```

Run:

```bash
python projects/main_pattern.py
```

Expected output:

```text
The program is running.
```

Complete the explanation:

```python
if __name__ == "__main__":
```

means:

> _________________________________________________________

> _________________________________________________________
```

---

# Activity 14: Task Display Functions

Create:

```text
projects/task_functions.py
```

Write:

```python
from typing import Any


Task = dict[str, Any]


def display_task(task: Task) -> None:
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")


def display_tasks(tasks: list[Task]) -> None:
    if not tasks:
        print("No tasks found.")
        return

    for task in tasks:
        display_task(task)


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
```

Expected output:

```text
[ ] 1 - Learn functions
[x] 2 - Practice return values
```

---

# Activity 15: Find a Task Function

Add this function:

```python
def find_task(
    tasks: list[Task],
    task_id: int,
) -> Task | None:
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None
```

Test it:

```python
task = find_task(tasks, 2)

if task is not None:
    print(f"Found: {task['title']}")
else:
    print("Task not found.")
```

Expected output:

```text
Found: Practice return values
```

Now test a missing ID:

```python
task = find_task(tasks, 999)

if task is not None:
    print(f"Found: {task['title']}")
else:
    print("Task not found.")
```

Expected output:

```text
Task not found.
```

---

# Mini-Project: Function-Based Task Program

Create:

```text
projects/function_task_manager.py
```

Write:

```python
from typing import Any


Task = dict[str, Any]


def display_task(task: Task) -> None:
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")


def display_tasks(tasks: list[Task]) -> None:
    if not tasks:
        print("No tasks found.")
        return

    print("Tasks:")

    for task in tasks:
        display_task(task)


def get_next_id(tasks: list[Task]) -> int:
    if not tasks:
        return 1

    return max(task["id"] for task in tasks) + 1


def create_task(
    tasks: list[Task],
    title: str,
) -> Task:
    cleaned_title = title.strip()

    if not cleaned_title:
        raise ValueError("Task title cannot be empty.")

    task = {
        "id": get_next_id(tasks),
        "title": cleaned_title,
        "completed": False,
    }

    tasks.append(task)

    return task


def find_task(
    tasks: list[Task],
    task_id: int,
) -> Task | None:
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


def complete_task(
    tasks: list[Task],
    task_id: int,
) -> Task:
    task = find_task(tasks, task_id)

    if task is None:
        raise ValueError(
            f"No task found with ID {task_id}."
        )

    task["completed"] = True

    return task


def main() -> None:
    tasks: list[Task] = []

    create_task(tasks, "Learn functions")
    create_task(tasks, "Practice return values")
    complete_task(tasks, 1)

    display_tasks(tasks)


if __name__ == "__main__":
    main()
```

Run:

```bash
python projects/function_task_manager.py
```

Expected output:

```text
Tasks:
[x] 1 - Learn functions
[ ] 2 - Practice return values
```

---

# Function Design Review

For each function, write its responsibility.

| Function | Responsibility |
|---|---|
| `display_task()` | __________________________________ |
| `display_tasks()` | _________________________________ |
| `get_next_id()` | __________________________________ |
| `create_task()` | __________________________________ |
| `find_task()` | ____________________________________ |
| `complete_task()` | _________________________________ |

---

# Part 4A Review

## 1. What is a function?

```text
____________________________________________________________

____________________________________________________________
```

## 2. What is the difference between a parameter and an argument?

```text
____________________________________________________________

____________________________________________________________
```

## 3. What does `return` do?

```text
____________________________________________________________
```

## 4. What is a default parameter?

```text
____________________________________________________________
```

## 5. What does `-> None` mean in a type hint?

```text
____________________________________________________________
```

## 6. What is local scope?

```text
____________________________________________________________

____________________________________________________________
```

## 7. Why is the `main()` pattern useful?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4A Completion Checklist

- [ ] Define a function.
- [ ] Call a function.
- [ ] Use parameters.
- [ ] Pass arguments.
- [ ] Use keyword arguments.
- [ ] Return a value.
- [ ] Return a Boolean.
- [ ] Use default parameters.
- [ ] Add type hints.
- [ ] Explain local scope.
- [ ] Pass values explicitly.
- [ ] Use the `main()` pattern.
- [ ] Create task display functions.
- [ ] Find a task by ID.
- [ ] Create a function-based task program.

---

# Part 4A Reflection

Which function was easiest to write?

```text
____________________________________________________________
```

Which function was hardest?

```text
____________________________________________________________
```

Why is a collection of small functions easier to maintain than one large block of code?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

What function would you add to improve the task manager?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4A Complete

You have completed:

```text
Part 4A: Functions and Reusable Code
```

The next workbook section is:

# Part 4B: Modules, Text Files, and `pathlib`

It will cover:

- Creating modules.
- Importing functions.
- Writing text files.
- Reading text files.
- Appending content.
- Creating directories.
- Building file paths with `pathlib`.

---

# Student Workbook — Part 4B: Modules, Text Files, and `pathlib`

This is the second section of Part 4.

Part 4 is divided into:

1. **Part 4A:** Functions and reusable code.
2. **Part 4B:** Modules, text files, and `pathlib`.
3. **Part 4C:** JSON, exceptions, and safe file handling.
4. **Part 4D:** Building the persistent task manager.

This section covers:

- Creating modules.
- Importing functions.
- Writing text files.
- Reading text files.
- Appending content.
- Creating directories.
- Building portable paths with `pathlib`.

---

# Part 4B Learning Goals

By the end of this section, you should be able to:

- Explain what a Python module is.
- Import a function from another file.
- Import an entire module.
- Write text to a file.
- Read text from a file.
- Append text without replacing existing content.
- Create directories with `pathlib`.
- Check whether paths exist.
- Combine path components safely.

---

# Activity 1: Create a Module

Create:

```text
projects/calculations.py
```

Add:

```python
def add(first: int, second: int) -> int:
    return first + second


def subtract(first: int, second: int) -> int:
    return first - second


def multiply(first: int, second: int) -> int:
    return first * second
```

This file is a module.

It defines functions but does not call them.

---

# Activity 2: Import Functions

Create:

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

Run from the `projects` directory:

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

## Reflection

What does this statement do?

```python
from calculations import add, multiply
```

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 3: Import an Entire Module

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

Run from `projects`:

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

Return to the project root:

```bash
cd ..
```

Complete:

```text
The module name is used before a function:

calculations._______________________________________________
```

---

# Activity 4: Import Aliases

Write:

```python
import calculations as calc


print(calc.add(2, 3))
```

The alias is:

```text
____________________________________________________________
```

You can also alias a function:

```python
from calculations import multiply as multiply_numbers

print(multiply_numbers(4, 5))
```

## Reflection

Why might an alias be useful?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 5: Module Execution

Create:

```text
projects/message_module.py
```

Add:

```python
def show_message() -> None:
    print("Hello from the module.")


if __name__ == "__main__":
    show_message()
```

Run it directly:

```bash
cd projects
python message_module.py
```

Expected output:

```text
Hello from the module.
```

Now create:

```text
projects/use_message_module.py
```

Add:

```python
from message_module import show_message


print("The function was imported.")
show_message()
```

Run:

```bash
python use_message_module.py
```

Expected output:

```text
The function was imported.
Hello from the module.
```

## Reflection

Why is this pattern useful?

```python
if __name__ == "__main__":
    show_message()
```

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 6: Write a Text File

Create:

```text
projects/write_text.py
```

Add:

```python
file_path = "example.txt"

with open(
    file_path,
    "w",
    encoding="utf-8",
) as file:
    file.write("First line\n")
    file.write("Second line\n")

print(f"Created {file_path}")
```

Run from `projects`:

```bash
cd projects
python write_text.py
```

Expected output:

```text
Created example.txt
```

The file should contain:

```text
First line
Second line
```

Return to the project root:

```bash
cd ..
```

---

# Activity 7: File Modes

Complete the table:

| Mode | Meaning |
|---|---|
| `"r"` | __________________________ |
| `"w"` | __________________________ |
| `"a"` | __________________________ |
| `"x"` | __________________________ |

Important:

```python
"w"
```

replaces the existing contents.

```python
"a"
```

adds content to the end.

---

# Activity 8: Read a Text File

Create:

```text
projects/read_text.py
```

Add:

```python
with open(
    "example.txt",
    "r",
    encoding="utf-8",
) as file:
    contents = file.read()

print(contents)
```

Run from `projects`:

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

## Reflection

What does `.read()` return?

```text
____________________________________________________________
```

---

# Activity 9: Read Lines

Write:

```python
with open(
    "example.txt",
    "r",
    encoding="utf-8",
) as file:
    for line in file:
        print(line.strip())
```

Expected output:

```text
First line
Second line
```

Why is `.strip()` useful here?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 10: Append to a File

Create:

```text
projects/append_text.py
```

Add:

```python
with open(
    "example.txt",
    "a",
    encoding="utf-8",
) as file:
    file.write("Third line\n")

print("Added a line.")
```

Run from `projects`:

```bash
cd projects
python append_text.py
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

## Reflection

What is the difference between `"w"` and `"a"`?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 11: Use `pathlib`

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

contents = file_path.read_text(
    encoding="utf-8",
)

print(contents)
```

Run from `projects`:

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

Complete:

```text
Path objects are imported from the __________________ module.
```

---

# Activity 12: Check Paths

Write:

```python
from pathlib import Path


file_path = Path("example.txt")

print(f"Exists: {file_path.exists()}")
print(f"Is file: {file_path.is_file()}")
print(f"Is directory: {file_path.is_dir()}")
```

Expected output:

```text
Exists: True
Is file: True
Is directory: False
```

## Exercise

Check a directory named `data`:

```python
data_directory = Path("data")

print(data_directory.exists())
print(data_directory.is_dir())
```

---

# Activity 13: Create a Directory

Create:

```text
projects/create_directory.py
```

Add:

```python
from pathlib import Path


data_directory = Path("data")

data_directory.mkdir(exist_ok=True)

print(
    f"Directory exists: "
    f"{data_directory.exists()}"
)
```

Run from `projects`:

```bash
cd projects
python create_directory.py
```

Expected output:

```text
Directory exists: True
```

Return to the project root:

```bash
cd ..
```

The `data` directory should now exist inside `projects`.

---

# Activity 14: Create Nested Directories

Write:

```python
from pathlib import Path


archive_directory = (
    Path("data")
    / "archive"
    / "2026"
)

archive_directory.mkdir(
    parents=True,
    exist_ok=True,
)

print(archive_directory)
```

Run it from `projects`.

Expected output may resemble:

```text
data/archive/2026
```

Complete:

```text
parents=True allows Python to create missing
____________________________________________________________
```

---

# Activity 15: Combine Paths

Avoid manually constructing paths:

```python
file_path = "data/" + "tasks.json"
```

Use `Path`:

```python
from pathlib import Path


data_directory = Path("data")
file_path = data_directory / "tasks.json"

print(file_path)
```

Expected output:

```text
data/tasks.json
```

## Exercise

Create this path:

```text
data/archive/notes.txt
```

```python
file_path = (
    Path("data")
    / "archive"
    / "notes.txt"
)
```

---

# Activity 16: Inspect Path Components

Write:

```python
from pathlib import Path


file_path = Path("documents/report.txt")

print(file_path.name)
print(file_path.stem)
print(file_path.suffix)
print(file_path.parent)
```

Expected output:

```text
report.txt
report
.txt
documents
```

Complete the table:

| Property | Meaning |
|---|---|
| `.name` | __________________________ |
| `.stem` | __________________________ |
| `.suffix` | __________________________ |
| `.parent` | __________________________ |

---

# Activity 17: List Directory Contents

Create:

```text
projects/list_directory.py
```

Add:

```python
from pathlib import Path


directory = Path(".")

for item in directory.iterdir():
    print(item)
```

Run from `projects`:

```bash
cd projects
python list_directory.py
```

Record three items:

```text
1. ________________________________________________________

2. ________________________________________________________

3. ________________________________________________________
```

Return to the project root:

```bash
cd ..
```

---

# Activity 18: Identify Files and Directories

Update the program:

```python
from pathlib import Path


directory = Path(".")

for item in directory.iterdir():
    if item.is_file():
        print(f"File: {item}")
    elif item.is_dir():
        print(f"Directory: {item}")
```

This pattern will later be used by the file-organizer utility.

---

# Activity 19: Find Matching Files

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

Run from `projects`:

```bash
cd projects
python find_python_files.py
```

Expected output will include Python files in the current directory.

Return to the project root:

```bash
cd ..
```

Search recursively:

```python
for file_path in projects_directory.rglob("*.py"):
    print(file_path)
```

The difference is:

```text
glob() searches the current directory.

rglob() searches the current directory and subdirectories.
```

---

# Mini-Project: Notes Program

Create:

```text
projects/notes.py
```

Add:

```python
from pathlib import Path


NOTES_FILE = Path("notes.txt")


def add_note(note: str) -> None:
    """Append one note to the notes file."""
    with NOTES_FILE.open(
        "a",
        encoding="utf-8",
    ) as file:
        file.write(f"{note}\n")


def list_notes() -> list[str]:
    """Return all saved notes."""
    if not NOTES_FILE.exists():
        return []

    contents = NOTES_FILE.read_text(
        encoding="utf-8",
    )

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

Run from `projects`:

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

Run the program again and add another note:

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

# Notes Program Analysis

Complete the table:

| Code | Purpose |
|---|---|
| `NOTES_FILE = Path("notes.txt")` | __________________ |
| `add_note()` | __________________ |
| `list_notes()` | __________________ |
| `.exists()` | __________________ |
| `.read_text()` | __________________ |
| `.splitlines()` | __________________ |

---

# Part 4B Review

## 1. What is a module?

```text
____________________________________________________________

____________________________________________________________
```

## 2. How do you import a function?

```text
____________________________________________________________
```

## 3. What does `"w"` do when opening a file?

```text
____________________________________________________________
```

## 4. What does `"a"` do?

```text
____________________________________________________________
```

## 5. Why is the `with` statement useful for files?

```text
____________________________________________________________

____________________________________________________________
```

## 6. What is `pathlib` used for?

```text
____________________________________________________________

____________________________________________________________
```

## 7. What does `Path.exists()` check?

```text
____________________________________________________________
```

## 8. What is the difference between `glob()` and `rglob()`?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4B Completion Checklist

- [ ] Create a Python module.
- [ ] Import individual functions.
- [ ] Import an entire module.
- [ ] Use an import alias.
- [ ] Use the `main()` pattern in a module.
- [ ] Write a text file.
- [ ] Read a text file.
- [ ] Append to a text file.
- [ ] Use `Path`.
- [ ] Check whether a path exists.
- [ ] Check whether a path is a file.
- [ ] Check whether a path is a directory.
- [ ] Create a directory.
- [ ] Create nested directories.
- [ ] Combine paths with `/`.
- [ ] Inspect file names and extensions.
- [ ] List directory contents.
- [ ] Find files with `glob()`.
- [ ] Build the notes program.

---

# Part 4B Reflection

What is the benefit of splitting code into modules?

```text
____________________________________________________________

____________________________________________________________
```

What is the safest file mode for adding content without replacing existing content?

```text
____________________________________________________________
```

Why are `Path` objects preferable to manually joining path strings?

```text
____________________________________________________________

____________________________________________________________
```

What would you improve in the notes program?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4B Complete

You have completed:

```text
Part 4B: Modules, Text Files, and pathlib
```

The next workbook section is:

# Part 4C: JSON, Exceptions, and Safe File Handling

It will cover:

- Writing JSON.
- Reading JSON.
- `try` and `except`.
- Missing files.
- Invalid JSON.
- Invalid numeric input.
- Validating loaded data.
- Creating a storage module.

---

# Student Workbook — Part 4C: JSON, Exceptions, and Safe File Handling

This is the third section of Part 4.

Part 4 is divided into:

1. **Part 4A:** Functions and reusable code.
2. **Part 4B:** Modules, text files, and `pathlib`.
3. **Part 4C:** JSON, exceptions, and safe file handling.
4. **Part 4D:** Building the persistent task manager.

This section covers:

- JSON data.
- Writing JSON files.
- Reading JSON files.
- `try` and `except`.
- Missing files.
- Invalid JSON.
- Invalid user input.
- Data validation.
- Separating storage logic from application logic.

---

# Part 4C Learning Goals

By the end of this section, you should be able to:

- Explain what JSON is.
- Write Python data to a JSON file.
- Read JSON into Python data.
- Handle invalid numeric input.
- Handle missing files.
- Handle malformed JSON.
- Validate the shape of loaded data.
- Create a storage module.

---

# Activity 1: Understand JSON

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

Complete the table:

| Python | JSON |
|---|---|
| `True` | __________________ |
| `False` | __________________ |
| `None` | __________________ |
| Python list | __________________ |
| Python dictionary | __________________ |

---

# Activity 2: Write JSON

Create:

```text
projects/write_json.py
```

Add:

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

with file_path.open(
    "w",
    encoding="utf-8",
) as file:
    json.dump(tasks, file, indent=2)

print(f"Saved tasks to {file_path}")
```

Run from `projects`:

```bash
cd projects
python write_json.py
```

Expected output:

```text
Saved tasks to tasks.json
```

Return to the project root:

```bash
cd ..
```

Inspect the file:

### Windows PowerShell

```powershell
Get-Content projects\tasks.json
```

### macOS or Linux

```bash
cat projects/tasks.json
```

Record one line from the file:

```text
____________________________________________________________
```

---

# Activity 3: Read JSON

Create:

```text
projects/read_json.py
```

Add:

```python
import json
from pathlib import Path


file_path = Path("tasks.json")

with file_path.open(
    "r",
    encoding="utf-8",
) as file:
    tasks = json.load(file)

for task in tasks:
    print(task["title"])
```

Run from `projects`:

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

Complete:

```text
json.load() reads JSON from a ____________________________.

json.loads() reads JSON from a ____________________________.
```

---

# Activity 4: JSON Strings

Create:

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

Expected output:

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
| `json.dump()` | ______________________________ |
| `json.dumps()` | ______________________________ |
| `json.load()` | ______________________________ |
| `json.loads()` | ______________________________ |

---

# Activity 5: Basic Exception Handling

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

Run:

```bash
python projects/safe_number.py
```

Test valid input:

```text
42
```

Output:

```text
____________________________________________________________
```

Test invalid input:

```text
hello
```

Output:

```text
____________________________________________________________
```

---

# Activity 6: Understand `try`, `except`, and `else`

Complete the table:

| Block | Purpose |
|---|---|
| `try` | ______________________________________________ |
| `except` | ___________________________________________ |
| `else` | ______________________________________________ |
| `finally` | ___________________________________________ |

The basic structure is:

```python
try:
    ______________________________
except ValueError:
    ______________________________
else:
    ______________________________
```

---

# Activity 7: Multiple Exceptions

Write:

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

Test:

| Input | Expected result |
|---|---|
| `hello` | __________________ |
| `0` | __________________ |
| `4` | __________________ |

---

# Activity 8: `finally`

Write:

```python
try:
    number = int("42")
except ValueError:
    print("Invalid number.")
finally:
    print("The conversion attempt is finished.")
```

Expected output:

```text
The conversion attempt is finished.
```

Change `"42"` to `"hello"`.

Record the output:

```text
____________________________________________________________

____________________________________________________________
```

## Reflection

When might `finally` be useful?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 9: Missing Files

Create:

```text
projects/read_missing_file.py
```

Add:

```python
from pathlib import Path


file_path = Path("missing.txt")

try:
    contents = file_path.read_text(
        encoding="utf-8",
    )
except FileNotFoundError:
    print("The file does not exist.")
else:
    print(contents)
```

Run from the project root:

```bash
python projects/read_missing_file.py
```

Expected output:

```text
The file does not exist.
```

## Exercise

Change the program so that it creates an empty file when the file is missing.

Hint:

```python
file_path.write_text("", encoding="utf-8")
```

Your code:

```python
____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 10: Invalid JSON

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
    with file_path.open(
        "r",
        encoding="utf-8",
    ) as file:
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

Run it from `projects`:

```bash
cd projects
python safe_json.py
```

Return to the project root:

```bash
cd ..
```

---

# Activity 11: Test Corrupted JSON

Open:

```text
projects/tasks.json
```

Replace its contents with:

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

Return to the project root:

```bash
cd ..
```

Restore the file by running:

```bash
cd projects
python write_json.py
cd ..
```

---

# Activity 12: Validate JSON Structure

Valid JSON is not necessarily valid task data.

This is valid JSON:

```json
{
  "message": "hello"
}
```

But a task manager expects a list.

Write:

```python
import json
from pathlib import Path


file_path = Path("tasks.json")

with file_path.open(
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)

if not isinstance(data, list):
    print("Expected a list of tasks.")
else:
    print(f"Loaded {len(data)} tasks.")
```

Complete:

```text
The JSON syntax can be valid even when the data's
____________________________________________________________
```

---

# Activity 13: Validate a Task

Write:

```python
def is_valid_task(value: object) -> bool:
    if not isinstance(value, dict):
        return False

    required_keys = {
        "id",
        "title",
        "completed",
    }

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

Test it:

```python
valid_task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}

invalid_task = {
    "id": "one",
    "title": "Invalid ID",
    "completed": False,
}

print(is_valid_task(valid_task))
print(is_valid_task(invalid_task))
```

Expected output:

```text
True
False
```

---

# Activity 14: Create a Storage Module

Create:

```text
projects/task_storage.py
```

Add:

```python
import json
from pathlib import Path
from typing import Any


Task = dict[str, Any]


def load_tasks(file_path: Path) -> list[Task]:
    """Load tasks from a JSON file."""
    if not file_path.exists():
        return []

    try:
        with file_path.open(
            "r",
            encoding="utf-8",
        ) as file:
            data = json.load(file)
    except json.JSONDecodeError:
        print(f"Warning: Invalid JSON in {file_path}.")
        return []
    except OSError as error:
        print(
            f"Warning: Could not read "
            f"{file_path}: {error}"
        )
        return []

    if not isinstance(data, list):
        print(
            f"Warning: Expected {file_path} "
            f"to contain a list."
        )
        return []

    return data


def save_tasks(
    file_path: Path,
    tasks: list[Task],
) -> bool:
    """Save tasks to a JSON file."""
    try:
        file_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        with file_path.open(
            "w",
            encoding="utf-8",
        ) as file:
            json.dump(tasks, file, indent=2)

    except OSError as error:
        print(
            f"Could not save "
            f"{file_path}: {error}"
        )
        return False

    return True
```

---

# Activity 15: Use the Storage Module

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

Run from `projects`:

```bash
cd projects
python use_task_storage.py
```

Expected output:

```text
[{'id': 1, 'title': 'Test storage', 'completed': False}]
```

Run it again.

What happens?

```text
____________________________________________________________

____________________________________________________________
```

Return to the project root:

```bash
cd ..
```

Delete the temporary file when finished.

### Windows PowerShell

```powershell
Remove-Item projects\storage_test.json
```

### macOS or Linux

```bash
rm projects/storage_test.json
```

---

# Activity 16: Input Helper

Create:

```text
projects/input_helpers.py
```

Add:

```python
def read_integer(prompt: str) -> int | None:
    """Read an integer or return None."""
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

Run from `projects`:

```bash
cd projects
python use_input_helpers.py
```

Test:

```text
42
```

```text
hello
```

Return to the project root:

```bash
cd ..
```

---

# Part 4C Review

## 1. What does JSON represent?

```text
____________________________________________________________

____________________________________________________________
```

## 2. What does `json.dump()` do?

```text
____________________________________________________________
```

## 3. What does `json.load()` do?

```text
____________________________________________________________
```

## 4. Which exception represents invalid numeric conversion?

```text
____________________________________________________________
```

## 5. Which exception represents malformed JSON?

```text
____________________________________________________________
```

## 6. Which exception represents a missing file?

```text
____________________________________________________________
```

## 7. Why is valid JSON not always valid task data?

```text
____________________________________________________________

____________________________________________________________
```

## 8. Why should storage logic be separated from application logic?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4C Completion Checklist

- [ ] Explain JSON.
- [ ] Write JSON to a file.
- [ ] Read JSON from a file.
- [ ] Convert JSON to a string.
- [ ] Use `try`.
- [ ] Use `except`.
- [ ] Use `else`.
- [ ] Use `finally`.
- [ ] Handle `ValueError`.
- [ ] Handle `FileNotFoundError`.
- [ ] Handle `JSONDecodeError`.
- [ ] Handle `OSError`.
- [ ] Validate JSON structure.
- [ ] Validate individual tasks.
- [ ] Create a storage module.
- [ ] Create an input helper.
- [ ] Test invalid input and invalid JSON.

---

# Part 4C Reflection

What was the most useful exception-handling pattern?

```text
____________________________________________________________

____________________________________________________________
```

Why should a program handle malformed JSON?

```text
____________________________________________________________

____________________________________________________________
```

What could happen if a program trusts every value loaded from a file?

```text
____________________________________________________________

____________________________________________________________
```

What responsibility should belong to the storage module?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4C Complete

You have completed:

```text
Part 4C: JSON, Exceptions, and Safe File Handling
```

The next workbook section is:

# Part 4D: Building the Persistent Task Manager

It will combine:

- Functions.
- Modules.
- `pathlib`.
- JSON.
- Exceptions.
- Input validation.
- A persistent menu-driven task manager.

---

# Student Workbook — Part 4D: Persistent Task Manager

This is the final section of Part 4.

You will combine:

- Functions.
- Modules.
- `pathlib`.
- JSON.
- Exceptions.
- Input validation.
- Persistent storage.
- A menu-driven application.

The final program will save tasks in a JSON file so they remain available after the program closes.

---

# Part 4D Learning Goals

By the end of this section, you should be able to:

- Load tasks from a JSON file.
- Save tasks to a JSON file.
- Create a persistent task manager.
- Add tasks.
- List tasks.
- Complete tasks.
- Remove tasks.
- Handle invalid IDs.
- Handle missing and malformed files.
- Separate storage code from user-interface code.

---

# Activity 1: Create the Project Directory

Create:

```text
projects/persistent_tasks/
```

### Windows PowerShell

```powershell
mkdir projects\persistent_tasks
```

### macOS or Linux

```bash
mkdir -p projects/persistent_tasks
```

The directory will contain:

```text
persistent_tasks/
├── task_manager.py
└── tasks.json
```

The `tasks.json` file will be created by the program.

---

# Activity 2: Create the Storage Module

Create:

```text
projects/persistent_tasks/task_storage.py
```

Add:

```python
import json
from pathlib import Path
from typing import Any


Task = dict[str, Any]


def is_valid_task(value: object) -> bool:
    """Return True when value has the expected task structure."""
    if not isinstance(value, dict):
        return False

    required_keys = {
        "id",
        "title",
        "completed",
    }

    if not required_keys.issubset(value):
        return False

    if not isinstance(value["id"], int):
        return False

    if not isinstance(value["title"], str):
        return False

    if not isinstance(value["completed"], bool):
        return False

    return True


def load_tasks(file_path: Path) -> list[Task]:
    """Load valid tasks from a JSON file."""
    if not file_path.exists():
        return []

    try:
        with file_path.open(
            "r",
            encoding="utf-8",
        ) as file:
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


def save_tasks(
    file_path: Path,
    tasks: list[Task],
) -> bool:
    """Save tasks to a JSON file."""
    try:
        file_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        with file_path.open(
            "w",
            encoding="utf-8",
        ) as file:
            json.dump(tasks, file, indent=2)
            file.write("\n")

    except OSError as error:
        print(f"Could not save {file_path}: {error}")
        return False

    return True
```

---

# Activity 3: Review the Storage Module

Complete the table:

| Function | Responsibility |
|---|---|
| `is_valid_task()` | __________________________________ |
| `load_tasks()` | _____________________________________ |
| `save_tasks()` | _____________________________________ |

Answer:

```text
What happens if the JSON file does not exist?

____________________________________________________________

What happens if the JSON is malformed?

____________________________________________________________

Why does save_tasks() create parent directories?

____________________________________________________________
```

---

# Activity 4: Create the Task Manager

Create:

```text
projects/persistent_tasks/task_manager.py
```

Add:

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
    """Return the next available task ID."""
    if not tasks:
        return 1

    return max(task["id"] for task in tasks) + 1


def find_task(
    tasks: list[Task],
    task_id: int,
) -> Task | None:
    """Find a task by ID."""
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


def read_task_id(prompt: str) -> int | None:
    """Read and validate a task ID."""
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
    task_id = read_task_id(
        "Enter the task ID to complete: "
    )

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
    task_id = read_task_id(
        "Enter the task ID to remove: "
    )

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
    """Display task statistics."""
    total = len(tasks)

    completed = sum(
        1 for task in tasks
        if task["completed"]
    )

    incomplete = total - completed

    print()
    print(f"Total tasks: {total}")
    print(f"Completed tasks: {completed}")
    print(f"Incomplete tasks: {incomplete}")


def show_menu() -> None:
    """Display the menu."""
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

        choice = input(
            "Choose an option: "
        ).strip()

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

# Activity 5: Run the Task Manager

Run from the project root:

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

Choose:

```text
1
```

Expected output:

```text
No tasks found.
```

Record your result:

```text
____________________________________________________________
```

---

# Activity 6: Add a Task

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

Now inspect:

```text
projects/persistent_tasks/tasks.json
```

It should contain something similar to:

```json
[
  {
    "id": 1,
    "title": "Learn persistent storage",
    "completed": false
  }
]
```

Record the file path:

```text
____________________________________________________________
```

---

# Activity 7: Add a Second Task

Run the program if necessary:

```bash
python projects/persistent_tasks/task_manager.py
```

Choose:

```text
2
```

Enter:

```text
Practice JSON
```

Expected output:

```text
Task 2 created.
```

List the tasks:

```text
Choose an option: 1
```

Expected output:

```text
Tasks:
[ ] 1 - Learn persistent storage
[ ] 2 - Practice JSON
```

Actual output:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 8: Complete a Task

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

List the tasks again.

Expected:

```text
Tasks:
[x] 1 - Learn persistent storage
[ ] 2 - Practice JSON
```

Actual:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 9: Remove a Task

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

List tasks again.

Expected:

```text
Tasks:
[x] 1 - Learn persistent storage
```

Actual:

```text
____________________________________________________________
```

---

# Activity 10: Display Statistics

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

Record your output:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 11: Test Persistence

Quit:

```text
6
```

Start the program again:

```bash
python projects/persistent_tasks/task_manager.py
```

Choose:

```text
1
```

The completed task should still exist.

Why?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 12: Test Invalid Input

Test an invalid menu option:

```text
hello
```

Expected:

```text
Please choose a number from 1 to 6.
```

Test an empty title:

```text
2
     
```

Expected:

```text
Task title cannot be empty.
```

Test an invalid task ID:

```text
3
abc
```

Expected:

```text
Task ID must be a whole number.
```

Test a negative task ID:

```text
4
-1
```

Expected:

```text
Task ID must be greater than zero.
```

Record any unexpected behavior:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 13: Test a Missing Task

Choose:

```text
3
999
```

Expected:

```text
No task found with ID 999.
```

Then choose:

```text
4
999
```

Expected:

```text
No task found with ID 999.
```

Record the results:

```text
Complete missing task:

____________________________________________________________

Remove missing task:

____________________________________________________________
```

---

# Activity 14: Inspect the Data File

Display the JSON file.

### Windows PowerShell

```powershell
Get-Content projects\persistent_tasks\tasks.json
```

### macOS or Linux

```bash
cat projects/persistent_tasks/tasks.json
```

You can also validate and format it:

```bash
python -m json.tool projects/persistent_tasks/tasks.json
```

Record what the JSON stores:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 15: Test Corrupted JSON

Stop the program.

Open:

```text
projects/persistent_tasks/tasks.json
```

Replace its contents with:

```text
This is not valid JSON.
```

Run the program:

```bash
python projects/persistent_tasks/task_manager.py
```

Expected warning:

```text
Warning: Invalid JSON in ...
```

Choose:

```text
1
```

Expected:

```text
No tasks found.
```

## Restore the File

Delete the corrupted file.

### Windows PowerShell

```powershell
Remove-Item projects\persistent_tasks\tasks.json
```

### macOS or Linux

```bash
rm projects/persistent_tasks/tasks.json
```

Run the program again and create a new task.

---

# Activity 16: Explain the Data Flow

Complete the flow:

```text
User chooses "Add"
        ↓
______________________________
        ↓
______________________________
        ↓
______________________________
        ↓
tasks.json
```

For listing:

```text
User chooses "List"
        ↓
______________________________
        ↓
______________________________
        ↓
Terminal output
```

---

# Activity 17: Identify Responsibilities

Complete the table:

| Function | Responsibility |
|---|---|
| `display_task()` | __________________________________ |
| `list_tasks()` | _____________________________________ |
| `get_next_id()` | __________________________________ |
| `find_task()` | ____________________________________ |
| `read_task_id()` | _________________________________ |
| `add_task()` | _____________________________________ |
| `complete_task()` | ________________________________ |
| `remove_task()` | __________________________________ |
| `show_statistics()` | ______________________________ |
| `show_menu()` | ____________________________________ |
| `main()` | _________________________________________ |

---

# Part 4D Review

## 1. What makes the task manager persistent?

```text
____________________________________________________________

____________________________________________________________
```

## 2. Where are tasks stored?

```text
____________________________________________________________
```

## 3. What happens when the JSON file is missing?

```text
____________________________________________________________
```

## 4. What happens when the JSON file is invalid?

```text
____________________________________________________________
```

## 5. Why does the program use `Path(__file__).parent`?

```text
____________________________________________________________

____________________________________________________________
```

## 6. Why are tasks stored as a list of dictionaries?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4D Completion Checklist

- [ ] Create the persistent task directory.
- [ ] Create the storage module.
- [ ] Validate loaded task data.
- [ ] Load tasks from JSON.
- [ ] Save tasks to JSON.
- [ ] Create a task manager.
- [ ] Add tasks.
- [ ] List tasks.
- [ ] Complete tasks.
- [ ] Remove tasks.
- [ ] Display statistics.
- [ ] Reject empty titles.
- [ ] Reject invalid IDs.
- [ ] Handle missing tasks.
- [ ] Test persistence.
- [ ] Handle malformed JSON.
- [ ] Inspect the saved JSON file.

---

# Part 4 Reflection

What was the most important new concept in Part 4?

```text
____________________________________________________________

____________________________________________________________
```

Why is saving data to JSON useful?

```text
____________________________________________________________

____________________________________________________________
```

What would happen if `save_tasks()` were removed?

```text
____________________________________________________________

____________________________________________________________
```

Which function would you improve first?

```text
____________________________________________________________

____________________________________________________________
```

What feature would you add to the task manager?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 4 Complete

You have completed:

```text
Part 4A: Functions and Reusable Code
Part 4B: Modules, Text Files, and pathlib
Part 4C: JSON, Exceptions, and Safe File Handling
Part 4D: Persistent Task Manager
```

The next workbook section is:

# Part 5: Capstone Project

It will guide you through:

- Creating a professional project layout.
- Building a package.
- Creating a command-line interface.
- Connecting task logic to CLI commands.
- Adding a file organizer.
- Writing automated tests.
- Completing final verification.

---

# Student Workbook — Part 5A: Capstone Project Setup

This is the first section of Part 5.

The capstone will transform the earlier task manager into a structured command-line application named:

```text
foundation_cli
```

The completed application will support commands such as:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
python -m foundation_cli organize downloads
```

Part 5 is divided into:

1. **Part 5A:** Project structure and CLI setup.
2. **Part 5B:** Task logic and JSON storage.
3. **Part 5C:** Complete, remove, statistics, and error handling.
4. **Part 5D:** File organizer.
5. **Part 5E:** Automated testing and final verification.

---

# Part 5A Learning Goals

By the end of this section, you should be able to:

- Create a professional project layout.
- Understand the `src` layout.
- Create a Python package.
- Create `pyproject.toml`.
- Install a project in editable mode.
- Run a package with `python -m`.
- Create a command-line parser.
- Add CLI subcommands.
- Display help and version information.

---

# Activity 1: Create the Project Directories

From the project root, create:

```text
src/
src/foundation_cli/
data/
tests/
```

### Windows PowerShell

```powershell
mkdir src
mkdir src\foundation_cli
mkdir data
mkdir tests
```

### macOS or Linux

```bash
mkdir -p src/foundation_cli
mkdir -p data
mkdir -p tests
```

Your project should now look similar to:

```text
python-foundations/
├── data/
├── src/
│   └── foundation_cli/
└── tests/
```

---

# Activity 2: Understand the `src` Layout

The application code will be placed here:

```text
src/foundation_cli/
```

The data will be placed here:

```text
data/
```

The tests will be placed here:

```text
tests/
```

The project configuration will be placed in the root:

```text
pyproject.toml
```

Complete the table:

| Directory or file | Responsibility |
|---|---|
| `src/foundation_cli/` | __________________________________ |
| `data/` | _____________________________________________ |
| `tests/` | ____________________________________________ |
| `pyproject.toml` | ___________________________________ |
| `README.md` | ________________________________________ |

---

# Activity 3: Create `pyproject.toml`

Create this file in the project root:

```text
pyproject.toml
```

Add:

```toml
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "foundation-cli"
version = "0.1.0"
description = "A beginner-friendly multi-utility command-line application"
readme = "README.md"
requires-python = ">=3.10"
dependencies = []

[project.scripts]
foundation = "foundation_cli.cli:main"

[tool.setuptools.packages.find]
where = ["src"]
```

---

# Activity 4: Understand `pyproject.toml`

Complete the table:

| Setting | Purpose |
|---|---|
| `name` | __________________________________ |
| `version` | _______________________________ |
| `description` | __________________________ |
| `requires-python` | ______________________ |
| `dependencies` | _________________________ |
| `project.scripts` | _______________________ |
| `where = ["src"]` | _______________________ |

The project currently uses only Python's standard library, so:

```toml
dependencies = []
```

---

# Activity 5: Create `README.md`

Create:

```text
README.md
```

Add:

```markdown
# Foundation CLI

A beginner-friendly multi-utility command-line application built with Python.

## Current status

The project is under development.

## Planned commands

```text
foundation add "Learn Python"
foundation list
foundation complete 1
foundation remove 1
foundation stats
foundation organize ./downloads
```
```

The README describes the project and is referenced by `pyproject.toml`.

---

# Activity 6: Create the Package Initializer

Create:

```text
src/foundation_cli/__init__.py
```

Add:

```python
"""Foundation CLI application."""

__version__ = "0.1.0"
```

The `__init__.py` file identifies `foundation_cli` as a Python package.

It also defines the package version.

---

# Activity 7: Create the Initial CLI Module

Create:

```text
src/foundation_cli/cli.py
```

Add:

```python
import argparse


def build_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser."""
    parser = argparse.ArgumentParser(
        prog="foundation",
        description=(
            "A multi-utility command-line application."
        ),
    )

    parser.add_argument(
        "--version",
        action="version",
        version="foundation 0.1.0",
    )

    return parser


def main() -> None:
    """Run the command-line application."""
    parser = build_parser()
    parser.parse_args()

    parser.print_help()


if __name__ == "__main__":
    main()
```

---

# Activity 8: Create `__main__.py`

Create:

```text
src/foundation_cli/__main__.py
```

Add:

```python
from .cli import main


if __name__ == "__main__":
    main()
```

This file allows the package to run with:

```bash
python -m foundation_cli
```

Complete:

```text
__main__.py imports the __________ function from the __________ module.
```

---

# Activity 9: Install the Project

Make sure your virtual environment is active.

From the project root, run:

```bash
python -m pip install --editable .
```

The editable option means that changes to files inside `src/` are immediately available.

Record the result:

```text
Installation result:

____________________________________________________________

____________________________________________________________
```

If the command fails, check:

- The virtual environment is active.
- You are in the project root.
- `pyproject.toml` exists.
- `README.md` exists.
- The spelling of the package directory is correct.

---

# Activity 10: Run the Package

Run:

```bash
python -m foundation_cli
```

Expected output will resemble:

```text
usage: foundation [-h] [--version]

A multi-utility command-line application.

options:
  -h, --help  show this help message and exit
  --version   show program's version number and exit
```

Run help explicitly:

```bash
python -m foundation_cli --help
```

Record the application description:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 11: Test the Version Option

Run:

```bash
python -m foundation_cli --version
```

Expected output:

```text
foundation 0.1.0
```

Record your result:

```text
____________________________________________________________
```

You can also test the installed command:

```bash
foundation --version
```

If the command is unavailable, use:

```bash
python -m foundation_cli --version
```

The module command is the most reliable form during development.

---

# Activity 12: Add CLI Subcommands

Replace the complete contents of:

```text
src/foundation_cli/cli.py
```

with:

```python
import argparse


def build_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser."""
    parser = argparse.ArgumentParser(
        prog="foundation",
        description=(
            "A multi-utility command-line application."
        ),
    )

    parser.add_argument(
        "--version",
        action="version",
        version="foundation 0.1.0",
    )

    subparsers = parser.add_subparsers(
        dest="command",
        title="commands",
    )

    add_parser = subparsers.add_parser(
        "add",
        help="Create a new task.",
    )
    add_parser.add_argument(
        "title",
        help="The title of the task.",
    )

    subparsers.add_parser(
        "list",
        help="List all tasks.",
    )

    complete_parser = subparsers.add_parser(
        "complete",
        help="Mark a task as completed.",
    )
    complete_parser.add_argument(
        "task_id",
        type=int,
        help="The ID of the task to complete.",
    )

    remove_parser = subparsers.add_parser(
        "remove",
        help="Remove a task.",
    )
    remove_parser.add_argument(
        "task_id",
        type=int,
        help="The ID of the task to remove.",
    )

    subparsers.add_parser(
        "stats",
        help="Display task statistics.",
    )

    organize_parser = subparsers.add_parser(
        "organize",
        help="Organize files by extension.",
    )
    organize_parser.add_argument(
        "directory",
        help="The directory containing files.",
    )

    return parser


def main() -> None:
    """Run the command-line application."""
    parser = build_parser()
    arguments = parser.parse_args()

    if arguments.command is None:
        parser.print_help()
        return

    print(f"Selected command: {arguments.command}")


if __name__ == "__main__":
    main()
```

---

# Activity 13: Inspect the Help Output

Run:

```bash
python -m foundation_cli --help
```

The help output should include:

```text
commands:
  add       Create a new task.
  list      List all tasks.
  complete  Mark a task as completed.
  remove    Remove a task.
  stats     Display task statistics.
  organize  Organize files by extension.
```

Record which commands appear:

```text
1. ________________________________________________________

2. ________________________________________________________

3. ________________________________________________________

4. ________________________________________________________

5. ________________________________________________________

6. ________________________________________________________
```

---

# Activity 14: Test the `add` Command

Run:

```bash
python -m foundation_cli add "Learn Python"
```

Expected output:

```text
Selected command: add
```

At this stage, the command is only being parsed. It does not create a task yet.

Record:

```text
Command tested:

____________________________________________________________

Output:

____________________________________________________________
```

---

# Activity 15: Test the Other Commands

Run each command:

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
python -m foundation_cli organize downloads
```

Record the command selected for each:

| Command | Selected command |
|---|---|
| `list` | __________________ |
| `complete 1` | __________________ |
| `remove 1` | __________________ |
| `stats` | __________________ |
| `organize downloads` | __________________ |

---

# Activity 16: Test Missing Arguments

Run:

```bash
python -m foundation_cli complete
```

Expected output will resemble:

```text
usage: foundation complete [-h] task_id
foundation complete: error: the following arguments are required: task_id
```

Run:

```bash
python -m foundation_cli add
```

Record the error message:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 17: Test Invalid Argument Types

Run:

```bash
python -m foundation_cli complete abc
```

Expected output will resemble:

```text
argument task_id: invalid int value: 'abc'
```

Why does this happen?

```text
____________________________________________________________

____________________________________________________________
```

The argument was defined with:

```python
type=int
```

This causes `argparse` to reject non-integer values before the application logic runs.

---

# Activity 18: Inspect Parsed Arguments

Temporarily replace:

```python
print(f"Selected command: {arguments.command}")
```

with:

```python
print(arguments)
```

Run:

```bash
python -m foundation_cli add "Learn Python"
```

You may see:

```text
Namespace(command='add', title='Learn Python')
```

Run:

```bash
python -m foundation_cli complete 12
```

You may see:

```text
Namespace(command='complete', task_id=12)
```

Record one parsed namespace:

```text
____________________________________________________________
```

Restore:

```python
print(f"Selected command: {arguments.command}")
```

---

# Activity 19: Add Basic Command Dispatch

Replace the `main()` function with:

```python
def main() -> None:
    """Run the command-line application."""
    parser = build_parser()
    arguments = parser.parse_args()

    if arguments.command is None:
        parser.print_help()
        return

    if arguments.command == "add":
        print(f"Adding task: {arguments.title}")
    elif arguments.command == "list":
        print("Listing tasks.")
    elif arguments.command == "complete":
        print(f"Completing task: {arguments.task_id}")
    elif arguments.command == "remove":
        print(f"Removing task: {arguments.task_id}")
    elif arguments.command == "stats":
        print("Displaying statistics.")
    elif arguments.command == "organize":
        print(
            f"Organizing directory: "
            f"{arguments.directory}"
        )
```

Test:

```bash
python -m foundation_cli add "Learn Python"
```

Expected:

```text
Adding task: Learn Python
```

Test:

```bash
python -m foundation_cli complete 1
```

Expected:

```text
Completing task: 1
```

These are still placeholder messages. Real behavior will be added in Part 5B and later.

---

# Activity 20: Current Project Structure

Your project should now look similar to:

```text
python-foundations/
├── README.md
├── pyproject.toml
├── data/
├── src/
│   └── foundation_cli/
│       ├── __init__.py
│       ├── __main__.py
│       └── cli.py
└── tests/
```

Earlier practice files may still exist in:

```text
projects/
```

That is acceptable.

---

# Part 5A Review

## 1. What is a Python package?

```text
____________________________________________________________

____________________________________________________________
```

## 2. What is the purpose of `pyproject.toml`?

```text
____________________________________________________________

____________________________________________________________
```

## 3. What does `python -m foundation_cli` do?

```text
____________________________________________________________
```

## 4. What does `argparse` provide?

```text
____________________________________________________________

____________________________________________________________
```

## 5. What is a subcommand?

```text
____________________________________________________________
```

## 6. Why is `type=int` useful for `task_id`?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 5A Completion Checklist

- [ ] Create `src/foundation_cli/`.
- [ ] Create `data/`.
- [ ] Create `tests/`.
- [ ] Create `pyproject.toml`.
- [ ] Create `README.md`.
- [ ] Create `__init__.py`.
- [ ] Create `__main__.py`.
- [ ] Create `cli.py`.
- [ ] Install the project in editable mode.
- [ ] Run `python -m foundation_cli`.
- [ ] Display help.
- [ ] Display the version.
- [ ] Add CLI subcommands.
- [ ] Test missing arguments.
- [ ] Test invalid argument types.
- [ ] Inspect parsed arguments.
- [ ] Add basic command dispatch.

---

# Part 5A Reflection

What is the benefit of using a package instead of one large script?

```text
____________________________________________________________

____________________________________________________________
```

Why is command-line validation useful?

```text
____________________________________________________________

____________________________________________________________
```

Which CLI command are you most interested in implementing?

```text
____________________________________________________________
```

What should happen when the user runs the application without a command?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 5A Complete

You have completed:

```text
Part 5A: Project Structure and CLI Setup
```

The next workbook section is:

# Part 5B: Task Logic and JSON Storage

It will cover:

- Creating tasks.
- Finding tasks.
- Completing tasks.
- Removing tasks.
- Loading task data.
- Saving task data.
- Connecting the `add` and `list` commands to real storage.

---

# Student Workbook — Part 5B: Task Logic and JSON Storage

This is the second section of Part 5.

In Part 5A, you created:

- The project structure.
- The `foundation_cli` package.
- `pyproject.toml`.
- The CLI parser.
- The `add`, `list`, `complete`, `remove`, `stats`, and `organize` commands.

The commands currently display placeholder messages.

In this section, you will implement:

- Task creation.
- Task lookup.
- Task completion logic.
- Task removal logic.
- JSON loading.
- JSON saving.
- Real `add` behavior.
- Real `list` behavior.

---

# Part 5B Learning Goals

By the end of this section, you should be able to:

- Represent tasks as dictionaries.
- Create task-management functions.
- Find tasks by ID.
- Generate task IDs.
- Save tasks to JSON.
- Load tasks from JSON.
- Connect application logic to CLI commands.
- Verify data persistence.

---

# Activity 1: Define the Task Structure

A task will have this structure:

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

Complete the table:

| Field | Type | Purpose |
|---|---|---|
| `id` | __________ | ______________________________ |
| `title` | __________ | ______________________________ |
| `completed` | __________ | ______________________________ |

A task list will look like:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
    {
        "id": 2,
        "title": "Build a CLI",
        "completed": True,
    },
]
```

---

# Activity 2: Create `tasks.py`

Create:

```text
src/foundation_cli/tasks.py
```

Add:

```python
from typing import Any


Task = dict[str, Any]


def get_next_id(tasks: list[Task]) -> int:
    """Return the next available task ID."""
    if not tasks:
        return 1

    return max(
        task["id"]
        for task in tasks
    ) + 1


def create_task(
    tasks: list[Task],
    title: str,
) -> Task:
    """Create and add a new task."""
    cleaned_title = title.strip()

    if not cleaned_title:
        raise ValueError(
            "Task title cannot be empty."
        )

    task: Task = {
        "id": get_next_id(tasks),
        "title": cleaned_title,
        "completed": False,
    }

    tasks.append(task)

    return task


def find_task(
    tasks: list[Task],
    task_id: int,
) -> Task | None:
    """Find a task by ID."""
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


def complete_task(
    tasks: list[Task],
    task_id: int,
) -> Task:
    """Mark a task as completed."""
    task = find_task(tasks, task_id)

    if task is None:
        raise ValueError(
            f"No task found with ID {task_id}."
        )

    if task["completed"]:
        raise ValueError(
            f"Task {task_id} is already completed."
        )

    task["completed"] = True

    return task


def remove_task(
    tasks: list[Task],
    task_id: int,
) -> Task:
    """Remove and return a task."""
    task = find_task(tasks, task_id)

    if task is None:
        raise ValueError(
            f"No task found with ID {task_id}."
        )

    tasks.remove(task)

    return task


def count_completed(tasks: list[Task]) -> int:
    """Return the number of completed tasks."""
    return sum(
        1 for task in tasks
        if task["completed"]
    )


def count_incomplete(tasks: list[Task]) -> int:
    """Return the number of incomplete tasks."""
    return len(tasks) - count_completed(tasks)
```

---

# Activity 3: Test Task Creation

Create a temporary file:

```text
src/foundation_cli/task_logic_check.py
```

Add:

```python
from .tasks import create_task


def main() -> None:
    tasks = []

    first_task = create_task(
        tasks,
        "Learn Python",
    )

    second_task = create_task(
        tasks,
        "Build a CLI",
    )

    print(first_task)
    print(second_task)
    print(tasks)


if __name__ == "__main__":
    main()
```

Run from the project root:

```bash
python -m foundation_cli.task_logic_check
```

Expected output should resemble:

```text
{'id': 1, 'title': 'Learn Python', 'completed': False}
{'id': 2, 'title': 'Build a CLI', 'completed': False}
[{'id': 1, 'title': 'Learn Python', 'completed': False}, {'id': 2, 'title': 'Build a CLI', 'completed': False}]
```

Delete the temporary file afterward.

### Windows PowerShell

```powershell
Remove-Item src\foundation_cli\task_logic_check.py
```

### macOS or Linux

```bash
rm src/foundation_cli/task_logic_check.py
```

---

# Activity 4: Test Empty Titles

In the interactive Python shell or a temporary script, test:

```python
from foundation_cli.tasks import create_task

tasks = []

create_task(tasks, "")
```

Expected error:

```text
ValueError: Task title cannot be empty.
```

Test whitespace:

```python
create_task(tasks, "   ")
```

This should also fail.

Why should whitespace-only titles be rejected?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 5: Test Task Lookup

Create a temporary file:

```text
src/foundation_cli/task_lookup_check.py
```

Add:

```python
from .tasks import find_task


def main() -> None:
    tasks = [
        {
            "id": 1,
            "title": "Learn Python",
            "completed": False,
        }
    ]

    existing_task = find_task(tasks, 1)
    missing_task = find_task(tasks, 999)

    print(existing_task)
    print(missing_task)


if __name__ == "__main__":
    main()
```

Run:

```bash
python -m foundation_cli.task_lookup_check
```

Expected output:

```text
{'id': 1, 'title': 'Learn Python', 'completed': False}
None
```

Complete:

```text
find_task() returns a task dictionary when the ID
____________________________________________________________

If no task matches, it returns ____________________________.
```

Delete the temporary file after testing.

---

# Activity 6: Create `storage.py`

Create:

```text
src/foundation_cli/storage.py
```

Add:

```python
import json
from pathlib import Path
from typing import Any


Task = dict[str, Any]

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIRECTORY = PROJECT_ROOT / "data"
DATA_FILE = DATA_DIRECTORY / "tasks.json"


def validate_task(value: object) -> None:
    """Validate one task dictionary."""
    if not isinstance(value, dict):
        raise ValueError(
            "Each task must be a JSON object."
        )

    required_keys = {
        "id",
        "title",
        "completed",
    }

    if not required_keys.issubset(value):
        raise ValueError(
            "Each task must contain "
            "id, title, and completed."
        )

    if not isinstance(value["id"], int):
        raise ValueError(
            "Task IDs must be integers."
        )

    if not isinstance(value["title"], str):
        raise ValueError(
            "Task titles must be strings."
        )

    if not isinstance(value["completed"], bool):
        raise ValueError(
            "Task completion values must be Boolean."
        )


def load_tasks(
    file_path: Path = DATA_FILE,
) -> list[Task]:
    """Load tasks from a JSON file."""
    if not file_path.exists():
        return []

    try:
        with file_path.open(
            "r",
            encoding="utf-8",
        ) as file:
            data = json.load(file)
    except json.JSONDecodeError as error:
        raise ValueError(
            f"Task data is not valid JSON: "
            f"{file_path}"
        ) from error
    except OSError as error:
        raise OSError(
            f"Could not read task data: "
            f"{file_path}"
        ) from error

    if not isinstance(data, list):
        raise ValueError(
            "Task data must be a JSON list."
        )

    for item in data:
        validate_task(item)

    return data


def save_tasks(
    tasks: list[Task],
    file_path: Path = DATA_FILE,
) -> None:
    """Save tasks to a JSON file."""
    try:
        file_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        with file_path.open(
            "w",
            encoding="utf-8",
        ) as file:
            json.dump(tasks, file, indent=2)
            file.write("\n")

    except OSError as error:
        raise OSError(
            f"Could not save task data: "
            f"{file_path}"
        ) from error
```

---

# Activity 7: Understand the Data File Path

These lines identify the project root:

```python
PROJECT_ROOT = Path(__file__).resolve().parents[2]
```

The file is located at:

```text
python-foundations/
└── src/
    └── foundation_cli/
        └── storage.py
```

The parent levels are approximately:

```text
parents[0] → src/foundation_cli
parents[1] → src
parents[2] → python-foundations
```

The data file becomes:

```text
python-foundations/data/tasks.json
```

Complete:

```text
The data file is stored in the __________________ directory.
```

---

# Activity 8: Test Storage

Create a temporary file:

```text
src/foundation_cli/storage_check.py
```

Add:

```python
from pathlib import Path

from .storage import load_tasks, save_tasks


def main() -> None:
    file_path = Path("data/storage_test.json")

    tasks = [
        {
            "id": 1,
            "title": "Test storage",
            "completed": False,
        }
    ]

    save_tasks(tasks, file_path)

    loaded_tasks = load_tasks(file_path)

    print(loaded_tasks)

    file_path.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
```

Run from the project root:

```bash
python -m foundation_cli.storage_check
```

Expected output:

```text
[{'id': 1, 'title': 'Test storage', 'completed': False}]
```

Delete the temporary test file afterward.

---

# Activity 9: Connect `add` to the CLI

Open:

```text
src/foundation_cli/cli.py
```

Add these imports near the top:

```python
from .storage import load_tasks, save_tasks
from .tasks import create_task
```

Add this function:

```python
def handle_add(title: str) -> None:
    """Create and save a task."""
    tasks = load_tasks()
    task = create_task(tasks, title)
    save_tasks(tasks)

    print("Task created:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")
    print("  Status: incomplete")
```

Update the `main()` function.

Replace:

```python
if arguments.command == "add":
    print(f"Adding task: {arguments.title}")
```

with:

```python
if arguments.command == "add":
    handle_add(arguments.title)
```

Run:

```bash
python -m foundation_cli add "Learn Python"
```

Expected output:

```text
Task created:
  ID: 1
  Title: Learn Python
  Status: incomplete
```

---

# Activity 10: Inspect `data/tasks.json`

Run:

### Windows PowerShell

```powershell
Get-Content data\tasks.json
```

### macOS or Linux

```bash
cat data/tasks.json
```

Expected structure:

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  }
]
```

Validate the JSON:

```bash
python -m json.tool data/tasks.json
```

---

# Activity 11: Connect `list` to the CLI

Add this function to `cli.py`:

```python
def display_task(task: dict) -> None:
    """Display one task."""
    status = "x" if task["completed"] else " "
    print(
        f"[{status}] "
        f"{task['id']} - "
        f"{task['title']}"
    )


def handle_list() -> None:
    """Load and display all tasks."""
    tasks = load_tasks()

    if not tasks:
        print("No tasks found.")
        return

    print("Tasks:")

    for task in tasks:
        display_task(task)
```

Update the `main()` branch:

```python
elif arguments.command == "list":
    handle_list()
```

Run:

```bash
python -m foundation_cli list
```

Expected output:

```text
Tasks:
[ ] 1 - Learn Python
```

---

# Activity 12: Add Another Task

Run:

```bash
python -m foundation_cli add "Build a CLI"
```

Expected output:

```text
Task created:
  ID: 2
  Title: Build a CLI
  Status: incomplete
```

List tasks:

```bash
python -m foundation_cli list
```

Expected output:

```text
Tasks:
[ ] 1 - Learn Python
[ ] 2 - Build a CLI
```

Record your output:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 13: Test Persistence

Run:

```bash
python -m foundation_cli list
```

Close the terminal or stop using the program.

Open a new terminal, activate the environment, and run:

```bash
python -m foundation_cli list
```

The tasks should still exist.

Why?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 14: Test Empty Task Data

Delete the data file.

### Windows PowerShell

```powershell
Remove-Item data\tasks.json
```

### macOS or Linux

```bash
rm data/tasks.json
```

Run:

```bash
python -m foundation_cli list
```

Expected output:

```text
No tasks found.
```

The application starts safely when no file exists.

---

# Activity 15: Test Invalid Titles

Run:

```bash
python -m foundation_cli add ""
```

The current application may display a traceback because `create_task()` raises `ValueError`.

Record the result:

```text
____________________________________________________________

____________________________________________________________
```

This will be improved in Part 5C by adding application-level error handling.

---

# Activity 16: Current CLI Behavior

At this point, these commands should work:

```bash
python -m foundation_cli add "Learn Python"
```

```bash
python -m foundation_cli list
```

These commands are still placeholders:

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
python -m foundation_cli organize downloads
```

Record which commands are complete:

```text
Implemented commands:

____________________________________________________________

Placeholder commands:

____________________________________________________________
```

---

# Part 5B Review

## 1. What fields does each task contain?

```text
____________________________________________________________
```

## 2. What does `get_next_id()` do?

```text
____________________________________________________________

____________________________________________________________
```

## 3. What does `find_task()` return when no task exists?

```text
____________________________________________________________
```

## 4. What does `load_tasks()` do when the file is missing?

```text
____________________________________________________________
```

## 5. Where is persistent task data stored?

```text
____________________________________________________________
```

## 6. Why is JSON useful for this project?

```text
____________________________________________________________

____________________________________________________________
```

## 7. Which commands currently work?

```text
____________________________________________________________
```

---

# Part 5B Completion Checklist

- [ ] Define the task structure.
- [ ] Create `tasks.py`.
- [ ] Generate task IDs.
- [ ] Create tasks.
- [ ] Reject empty titles.
- [ ] Find tasks by ID.
- [ ] Complete a task in memory.
- [ ] Remove a task in memory.
- [ ] Count completed tasks.
- [ ] Create `storage.py`.
- [ ] Validate loaded tasks.
- [ ] Save JSON.
- [ ] Load JSON.
- [ ] Connect `add`.
- [ ] Connect `list`.
- [ ] Confirm persistence.
- [ ] Test missing task data.
- [ ] Identify remaining placeholder commands.

---

# Part 5B Reflection

What is the difference between task logic and storage logic?

```text
____________________________________________________________

____________________________________________________________
```

Why should `tasks.py` not need to know the location of `tasks.json`?

```text
____________________________________________________________

____________________________________________________________
```

What happens when the application is run for the first time?

```text
____________________________________________________________
```

What would happen if the JSON file contained a dictionary instead of a list?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 5B Complete

You have completed:

```text
Part 5B: Task Logic and JSON Storage
```

The next workbook section is:

# Part 5C: Completing, Removing, Statistics, and Error Handling

It will cover:

- Custom exceptions.
- Completing tasks from the CLI.
- Removing tasks from the CLI.
- Task statistics.
- Friendly error messages.
- Positive task-ID validation.

---

# Student Workbook — Part 5C: Completing, Removing, Statistics, and Error Handling

This is the third section of Part 5.

In Part 5B, you implemented:

- Task creation.
- Task lookup.
- JSON loading.
- JSON saving.
- The `add` command.
- The `list` command.

This section will implement:

- Custom exceptions.
- The `complete` command.
- The `remove` command.
- The `stats` command.
- Friendly error messages.
- Positive task-ID validation.

---

# Part 5C Learning Goals

By the end of this section, you should be able to:

- Define application-specific exceptions.
- Complete tasks from the CLI.
- Remove tasks from the CLI.
- Display task statistics.
- Handle expected errors without tracebacks.
- Validate positive task IDs.
- Separate error handling from task logic.

---

# Activity 1: Create `errors.py`

Create:

```text
src/foundation_cli/errors.py
```

Add:

```python
"""Application-specific exceptions."""


class FoundationError(Exception):
    """Base exception for expected application errors."""


class TaskNotFoundError(FoundationError):
    """Raised when a requested task does not exist."""


class TaskAlreadyCompletedError(FoundationError):
    """Raised when a task is already completed."""


class InvalidTaskTitleError(FoundationError):
    """Raised when a task title is invalid."""
```

---

# Activity 2: Understand Custom Exceptions

Complete the table:

| Exception | Meaning |
|---|---|
| `FoundationError` | __________________________________ |
| `TaskNotFoundError` | ________________________________ |
| `TaskAlreadyCompletedError` | _________________________ |
| `InvalidTaskTitleError` | ______________________________ |

Why are custom exceptions useful?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 3: Update `tasks.py`

Replace the complete contents of:

```text
src/foundation_cli/tasks.py
```

with:

```python
from typing import Any

from .errors import (
    InvalidTaskTitleError,
    TaskAlreadyCompletedError,
    TaskNotFoundError,
)


Task = dict[str, Any]


def get_next_id(tasks: list[Task]) -> int:
    """Return the next available task ID."""
    if not tasks:
        return 1

    return max(
        task["id"]
        for task in tasks
    ) + 1


def create_task(
    tasks: list[Task],
    title: str,
) -> Task:
    """Create and add a new task."""
    cleaned_title = title.strip()

    if not cleaned_title:
        raise InvalidTaskTitleError(
            "Task title cannot be empty."
        )

    task: Task = {
        "id": get_next_id(tasks),
        "title": cleaned_title,
        "completed": False,
    }

    tasks.append(task)

    return task


def find_task(
    tasks: list[Task],
    task_id: int,
) -> Task | None:
    """Find a task by ID."""
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


def require_task(
    tasks: list[Task],
    task_id: int,
) -> Task:
    """Find a task or raise an error."""
    task = find_task(tasks, task_id)

    if task is None:
        raise TaskNotFoundError(
            f"No task found with ID {task_id}."
        )

    return task


def complete_task(
    tasks: list[Task],
    task_id: int,
) -> Task:
    """Mark a task as completed."""
    task = require_task(tasks, task_id)

    if task["completed"]:
        raise TaskAlreadyCompletedError(
            f"Task {task_id} is already completed."
        )

    task["completed"] = True

    return task


def remove_task(
    tasks: list[Task],
    task_id: int,
) -> Task:
    """Remove and return a task."""
    task = require_task(tasks, task_id)
    tasks.remove(task)

    return task


def count_completed(tasks: list[Task]) -> int:
    """Return the number of completed tasks."""
    return sum(
        1 for task in tasks
        if task["completed"]
    )


def count_incomplete(tasks: list[Task]) -> int:
    """Return the number of incomplete tasks."""
    return len(tasks) - count_completed(tasks)
```

---

# Activity 4: Test the Updated Task Logic

Create a temporary file:

```text
src/foundation_cli/task_error_check.py
```

Add:

```python
from .errors import (
    TaskAlreadyCompletedError,
    TaskNotFoundError,
)
from .tasks import (
    complete_task,
    create_task,
    remove_task,
)


def main() -> None:
    tasks = []

    first_task = create_task(
        tasks,
        "Learn Python",
    )

    second_task = create_task(
        tasks,
        "Build a CLI",
    )

    complete_task(tasks, first_task["id"])

    print(tasks)

    try:
        complete_task(tasks, first_task["id"])
    except TaskAlreadyCompletedError as error:
        print(f"Expected error: {error}")

    removed_task = remove_task(
        tasks,
        second_task["id"],
    )

    print(f"Removed: {removed_task}")

    try:
        remove_task(tasks, 999)
    except TaskNotFoundError as error:
        print(f"Expected error: {error}")


if __name__ == "__main__":
    main()
```

Run:

```bash
python -m foundation_cli.task_error_check
```

Expected output should resemble:

```text
[{'id': 1, 'title': 'Learn Python', 'completed': True}, {'id': 2, 'title': 'Build a CLI', 'completed': False}]
Expected error: Task 1 is already completed.
Removed: {'id': 2, 'title': 'Build a CLI', 'completed': False}
Expected error: No task found with ID 999.
```

Delete the temporary file afterward.

---

# Activity 5: Add `complete` Imports to `cli.py`

Open:

```text
src/foundation_cli/cli.py
```

Update the task imports:

```python
from .tasks import (
    complete_task,
    count_completed,
    count_incomplete,
    create_task,
    remove_task,
)
```

Update the error import:

```python
from .errors import FoundationError
```

---

# Activity 6: Add `handle_complete()`

Add this function to `cli.py`:

```python
def handle_complete(task_id: int) -> None:
    """Complete and save a task."""
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

Update the command dispatch:

```python
elif arguments.command == "complete":
    handle_complete(arguments.task_id)
```

---

# Activity 7: Test `complete`

First list tasks:

```bash
python -m foundation_cli list
```

Suppose the output is:

```text
Tasks:
[ ] 1 - Learn Python
[ ] 2 - Build a CLI
```

Complete task `1`:

```bash
python -m foundation_cli complete 1
```

Expected output:

```text
Task completed:
  ID: 1
  Title: Learn Python
```

List again:

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[x] 1 - Learn Python
[ ] 2 - Build a CLI
```

Record your output:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 8: Add `handle_remove()`

Add this function to `cli.py`:

```python
def handle_remove(task_id: int) -> None:
    """Remove and save the updated task list."""
    tasks = load_tasks()

    task = remove_task(
        tasks,
        task_id,
    )

    save_tasks(tasks)

    print("Task removed:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")
```

Update the command dispatch:

```python
elif arguments.command == "remove":
    handle_remove(arguments.task_id)
```

---

# Activity 9: Test `remove`

Run:

```bash
python -m foundation_cli remove 2
```

Expected output:

```text
Task removed:
  ID: 2
  Title: Build a CLI
```

List tasks:

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[x] 1 - Learn Python
```

Record your result:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 10: Add `handle_stats()`

Add this function to `cli.py`:

```python
def handle_stats() -> None:
    """Display task statistics."""
    tasks = load_tasks()

    total = len(tasks)
    completed = count_completed(tasks)
    incomplete = count_incomplete(tasks)

    print(f"Total tasks: {total}")
    print(f"Completed tasks: {completed}")
    print(f"Incomplete tasks: {incomplete}")
```

Update the command dispatch:

```python
elif arguments.command == "stats":
    handle_stats()
```

---

# Activity 11: Test Statistics

Run:

```bash
python -m foundation_cli stats
```

Expected:

```text
Total tasks: 1
Completed tasks: 1
Incomplete tasks: 0
```

Record:

```text
Total tasks:

____________________________________________________________

Completed tasks:

____________________________________________________________

Incomplete tasks:

____________________________________________________________
```

---

# Activity 12: Add Error Handling to `main()`

Update the imports in `cli.py`:

```python
from .errors import FoundationError
```

Wrap command dispatch with `try` and `except`:

```python
def main() -> None:
    """Run the command-line application."""
    parser = build_parser()
    arguments = parser.parse_args()

    if arguments.command is None:
        parser.print_help()
        return

    try:
        handle_command(arguments)
    except FoundationError as error:
        print(f"Error: {error}")
    except OSError as error:
        print(f"File error: {error}")
```

Create a `handle_command()` function:

```python
def handle_command(
    arguments: argparse.Namespace,
) -> None:
    """Run the selected command."""
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
        print(
            f"Organizing directory: "
            f"{arguments.directory}"
        )
```

The final `main()` function should call:

```python
handle_command(arguments)
```

inside the `try` block.

---

# Activity 13: Test Missing Tasks

Run:

```bash
python -m foundation_cli complete 999
```

Expected:

```text
Error: No task found with ID 999.
```

Run:

```bash
python -m foundation_cli remove 999
```

Expected:

```text
Error: No task found with ID 999.
```

Record your actual output:

```text
Complete:

____________________________________________________________

Remove:

____________________________________________________________
```

---

# Activity 14: Test Already Completed Tasks

Run:

```bash
python -m foundation_cli complete 1
```

If task `1` is already complete, expected output is:

```text
Error: Task 1 is already completed.
```

Record:

```text
____________________________________________________________
```

The program should display a message instead of a traceback.

---

# Activity 15: Add Positive Integer Validation

At the top of `cli.py`, add:

```python
def positive_integer(value: str) -> int:
    """Parse a positive integer for argparse."""
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

Change the `complete` parser argument:

```python
complete_parser.add_argument(
    "task_id",
    type=positive_integer,
    help="The positive task ID.",
)
```

Change the `remove` parser argument:

```python
remove_parser.add_argument(
    "task_id",
    type=positive_integer,
    help="The positive task ID.",
)
```

---

# Activity 16: Test Positive ID Validation

Run:

```bash
python -m foundation_cli complete -1
```

Expected output should include:

```text
must be greater than zero
```

Run:

```bash
python -m foundation_cli complete abc
```

Expected output should include:

```text
must be a whole number
```

Complete the table:

| Input | Expected behavior |
|---|---|
| `1` | __________________________ |
| `0` | __________________________ |
| `-1` | _________________________ |
| `abc` | _________________________ |
| `999` | _________________________ |

---

# Activity 17: Update `handle_add()` Error Behavior

Run:

```bash
python -m foundation_cli add ""
```

Expected output:

```text
Error: Task title cannot be empty.
```

If you receive a traceback instead, verify that:

- `InvalidTaskTitleError` is defined.
- `create_task()` raises `InvalidTaskTitleError`.
- `InvalidTaskTitleError` inherits from `FoundationError`.
- `main()` catches `FoundationError`.

---

# Activity 18: Verify the Command Set

Run:

```bash
python -m foundation_cli --help
```

The available commands should include:

```text
add
list
complete
remove
stats
organize
```

Run:

```bash
python -m foundation_cli add "Practice error handling"
```

Then:

```bash
python -m foundation_cli list
```

Then:

```bash
python -m foundation_cli stats
```

Record the results:

```text
Add result:

____________________________________________________________

List result:

____________________________________________________________

Statistics result:

____________________________________________________________
```

---

# Part 5C Review

## 1. What is a custom exception?

```text
____________________________________________________________

____________________________________________________________
```

## 2. Why should expected errors not display full tracebacks?

```text
____________________________________________________________

____________________________________________________________
```

## 3. What does `handle_complete()` do?

```text
____________________________________________________________
```

## 4. What does `handle_remove()` do?

```text
____________________________________________________________
```

## 5. What does `handle_stats()` calculate?

```text
____________________________________________________________
```

## 6. Why is positive task-ID validation useful?

```text
____________________________________________________________

____________________________________________________________
```

## 7. Where should task rules be implemented?

```text
____________________________________________________________
```

## 8. Where should user-facing errors be displayed?

```text
____________________________________________________________
```

---

# Part 5C Completion Checklist

- [ ] Create `errors.py`.
- [ ] Create a base application exception.
- [ ] Create task-specific exceptions.
- [ ] Update task logic to raise custom errors.
- [ ] Implement `complete`.
- [ ] Implement `remove`.
- [ ] Implement `stats`.
- [ ] Add command dispatch.
- [ ] Catch expected application errors.
- [ ] Catch file errors.
- [ ] Reject missing task IDs.
- [ ] Reject already-completed tasks.
- [ ] Reject negative IDs.
- [ ] Reject non-numeric IDs.
- [ ] Reject empty task titles.
- [ ] Confirm commands persist their changes.

---

# Part 5C Reflection

Which error message is most useful to the user?

```text
____________________________________________________________
```

Why should task logic raise an error instead of printing directly?

```text
____________________________________________________________

____________________________________________________________
```

What is the advantage of using `handle_command()`?

```text
____________________________________________________________

____________________________________________________________
```

What additional task error should the application handle?

```text
____________________________________________________________
```

---

# Part 5C Complete

You have completed:

```text
Part 5C: Completing, Removing, Statistics, and Error Handling
```

The next workbook section is:

# Part 5D: File Organizer

It will cover:

- File extensions.
- Directory traversal.
- Planning file moves.
- Dry-run mode.
- Duplicate filenames.
- Safe file operations.
- Connecting `organize` to the CLI.

---

# Student Workbook — Part 5D: File Organizer

This is the fourth section of Part 5.

The task-management portion of the capstone now supports:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
```

This section implements:

```bash
python -m foundation_cli organize downloads
```

The organizer will:

- Inspect files in a directory.
- Group files by extension.
- Create destination folders.
- Move files.
- Handle files without extensions.
- Avoid overwriting duplicate filenames.
- Support `--dry-run`.

---

# Part 5D Learning Goals

By the end of this section, you should be able to:

- Inspect directory contents with `pathlib`.
- Extract file extensions.
- Create destination directories.
- Move files with `shutil`.
- Plan file operations before executing them.
- Implement dry-run behavior.
- Avoid overwriting existing files.
- Handle missing directories safely.

---

# Activity 1: Understand the Organizer

Before organization:

```text
downloads/
├── report.pdf
├── photo.jpg
├── notes.txt
├── presentation.pptx
└── data.csv
```

After organization:

```text
downloads/
├── csv/
│   └── data.csv
├── jpg/
│   └── photo.jpg
├── pdf/
│   └── report.pdf
├── pptx/
│   └── presentation.pptx
└── txt/
    └── notes.txt
```

Complete the table:

| File | Destination folder |
|---|---|
| `report.pdf` | __________________ |
| `photo.jpg` | __________________ |
| `notes.txt` | __________________ |
| `data.csv` | __________________ |
| `README` | __________________ |

---

# Activity 2: Create Test Files

Create a temporary directory named:

```text
organizer_test/
```

### Windows PowerShell

```powershell
mkdir organizer_test
Set-Content organizer_test\report.pdf "PDF content"
Set-Content organizer_test\photo.jpg "JPG content"
Set-Content organizer_test\notes.txt "Text content"
Set-Content organizer_test\README "No extension"
```

### macOS or Linux

```bash
mkdir -p organizer_test
printf "PDF content" > organizer_test/report.pdf
printf "JPG content" > organizer_test/photo.jpg
printf "Text content" > organizer_test/notes.txt
printf "No extension" > organizer_test/README
```

Expected directory:

```text
organizer_test/
├── README
├── notes.txt
├── photo.jpg
└── report.pdf
```

---

# Activity 3: Extract File Extensions

Create:

```text
projects/file_extensions.py
```

Add:

```python
from pathlib import Path


files = [
    Path("report.pdf"),
    Path("photo.JPG"),
    Path("notes.txt"),
    Path("README"),
]

for file_path in files:
    extension = file_path.suffix.lower()
    print(f"{file_path.name}: {extension}")
```

Run:

```bash
python projects/file_extensions.py
```

Expected output:

```text
report.pdf: .pdf
photo.JPG: .jpg
notes.txt: .txt
README:
```

To remove the leading dot:

```python
folder_name = file_path.suffix.lower().lstrip(".")
```

For files without an extension:

```python
if not folder_name:
    folder_name = "no_extension"
```

---

# Activity 4: Create `organizer.py`

Create:

```text
src/foundation_cli/organizer.py
```

Add:

```python
from dataclasses import dataclass
from pathlib import Path
import shutil


@dataclass(frozen=True)
class FileMove:
    """Describe one planned file move."""

    source: Path
    destination: Path


def extension_folder(file_path: Path) -> str:
    """Return the folder name for a file."""
    suffix = file_path.suffix.lower().lstrip(".")

    if suffix:
        return suffix

    return "no_extension"


def unique_destination(destination: Path) -> Path:
    """Return a non-conflicting destination path."""
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


def plan_moves(directory: Path) -> list[FileMove]:
    """Plan file moves without changing the file system."""
    if not directory.exists():
        raise FileNotFoundError(
            f"Directory does not exist: {directory}"
        )

    if not directory.is_dir():
        raise NotADirectoryError(
            f"Path is not a directory: {directory}"
        )

    moves: list[FileMove] = []

    for item in sorted(directory.iterdir()):
        if not item.is_file():
            continue

        folder_name = extension_folder(item)
        destination_directory = directory / folder_name
        destination = destination_directory / item.name
        destination = unique_destination(destination)

        moves.append(
            FileMove(
                source=item,
                destination=destination,
            )
        )

    return moves


def execute_moves(
    moves: list[FileMove],
    dry_run: bool = False,
) -> int:
    """Execute planned moves and return the number moved."""
    moved_count = 0

    for move in moves:
        print(
            f"{move.source.name} "
            f"-> {move.destination}"
        )

        if dry_run:
            continue

        move.destination.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        shutil.move(
            str(move.source),
            str(move.destination),
        )

        moved_count += 1

    return moved_count


def organize_directory(
    directory: Path,
    dry_run: bool = False,
) -> int:
    """Plan and execute directory organization."""
    moves = plan_moves(directory)

    return execute_moves(
        moves,
        dry_run=dry_run,
    )
```

---

# Activity 5: Understand `FileMove`

The data class stores:

```python
source
destination
```

Example:

```python
FileMove(
    source=Path("downloads/report.pdf"),
    destination=Path("downloads/pdf/report.pdf"),
)
```

Complete:

```text
source means:

____________________________________________________________

destination means:

____________________________________________________________
```

Why is it useful to plan a move before executing it?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 6: Test Extension Folders

Use the function:

```python
from pathlib import Path

from foundation_cli.organizer import extension_folder


print(extension_folder(Path("report.pdf")))
print(extension_folder(Path("photo.JPG")))
print(extension_folder(Path("README")))
```

Expected output:

```text
pdf
jpg
no_extension
```

Complete the table:

| File | Folder |
|---|---|
| `document.DOCX` | __________________ |
| `archive.ZIP` | __________________ |
| `Makefile` | __________________ |
| `image.png` | __________________ |

---

# Activity 7: Test Move Planning

Create:

```text
src/foundation_cli/organizer_check.py
```

Add:

```python
from pathlib import Path

from .organizer import plan_moves


def main() -> None:
    directory = Path("organizer_test")

    moves = plan_moves(directory)

    for move in moves:
        print(
            f"{move.source} "
            f"-> {move.destination}"
        )


if __name__ == "__main__":
    main()
```

Run from the project root:

```bash
python -m foundation_cli.organizer_check
```

Expected output should resemble:

```text
organizer_test/README -> organizer_test/no_extension/README
organizer_test/notes.txt -> organizer_test/txt/notes.txt
organizer_test/photo.jpg -> organizer_test/jpg/photo.jpg
organizer_test/report.pdf -> organizer_test/pdf/report.pdf
```

Confirm that no files have moved yet.

Why not?

```text
____________________________________________________________

____________________________________________________________
```

Delete the temporary checking file:

### Windows PowerShell

```powershell
Remove-Item src\foundation_cli\organizer_check.py
```

### macOS or Linux

```bash
rm src/foundation_cli/organizer_check.py
```

---

# Activity 8: Test Dry-Run Mode

Create:

```text
src/foundation_cli/organizer_dry_run.py
```

Add:

```python
from pathlib import Path

from .organizer import organize_directory


def main() -> None:
    directory = Path("organizer_test")

    moved_count = organize_directory(
        directory,
        dry_run=True,
    )

    print(f"Moved: {moved_count}")


if __name__ == "__main__":
    main()
```

Run:

```bash
python -m foundation_cli.organizer_dry_run
```

Expected output will show planned moves.

The final count should be:

```text
Moved: 0
```

Why?

```text
____________________________________________________________

____________________________________________________________
```

Delete the temporary file afterward.

---

# Activity 9: Connect `organize` to the CLI

Open:

```text
src/foundation_cli/cli.py
```

Add this import:

```python
from pathlib import Path

from .organizer import organize_directory
```

Update the organizer parser:

```python
organize_parser = subparsers.add_parser(
    "organize",
    help="Organize files by extension.",
)

organize_parser.add_argument(
    "directory",
    type=Path,
    help="The directory containing files.",
)

organize_parser.add_argument(
    "--dry-run",
    action="store_true",
    help="Preview changes without moving files.",
)
```

Add this handler:

```python
def handle_organize(
    directory: Path,
    dry_run: bool,
) -> None:
    """Organize files in a directory."""
    if dry_run:
        print(
            "Dry run: no files will be moved."
        )

    moved_count = organize_directory(
        directory,
        dry_run=dry_run,
    )

    if dry_run:
        print("Dry run complete.")
    else:
        print(
            f"Moved {moved_count} file(s)."
        )
```

Update `handle_command()`:

```python
elif arguments.command == "organize":
    handle_organize(
        arguments.directory,
        arguments.dry_run,
    )
```

---

# Activity 10: Run the CLI Dry Run

From the project root, run:

```bash
python -m foundation_cli organize organizer_test --dry-run
```

Expected output should resemble:

```text
Dry run: no files will be moved.
README -> organizer_test/no_extension/README
notes.txt -> organizer_test/txt/notes.txt
photo.jpg -> organizer_test/jpg/photo.jpg
report.pdf -> organizer_test/pdf/report.pdf
Dry run complete.
```

Inspect the directory.

The files should still be in:

```text
organizer_test/
```

Record:

```text
Were files moved?

____________________________________________________________

Why or why not?

____________________________________________________________
```

---

# Activity 11: Run the Actual Organizer

Run:

```bash
python -m foundation_cli organize organizer_test
```

Expected output should resemble:

```text
README -> organizer_test/no_extension/README
notes.txt -> organizer_test/txt/notes.txt
photo.jpg -> organizer_test/jpg/photo.jpg
report.pdf -> organizer_test/pdf/report.pdf
Moved 4 file(s).
```

Expected directory:

```text
organizer_test/
├── jpg/
│   └── photo.jpg
├── no_extension/
│   └── README
├── pdf/
│   └── report.pdf
└── txt/
    └── notes.txt
```

Record your output:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 12: Test Duplicate Files

Create another file with the same name as an existing destination file.

### Windows PowerShell

```powershell
Set-Content organizer_test\photo.jpg "Another JPG"
```

### macOS or Linux

```bash
printf "Another JPG" > organizer_test/photo.jpg
```

Run:

```bash
python -m foundation_cli organize organizer_test
```

Expected destination:

```text
organizer_test/jpg/photo_1.jpg
```

Why was the original not overwritten?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 13: Test Missing Directories

Run:

```bash
python -m foundation_cli organize missing_directory
```

Expected output should contain:

```text
Directory does not exist
```

Record the complete output:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 14: Test a File Instead of a Directory

Choose an existing file, such as:

```text
organizer_test/jpg/photo.jpg
```

Run:

```bash
python -m foundation_cli organize organizer_test/jpg/photo.jpg
```

Expected output should contain:

```text
Path is not a directory
```

Record:

```text
____________________________________________________________
```

---

# Activity 15: Clean Up Test Files

Remove the temporary organizer directory.

### Windows PowerShell

```powershell
Remove-Item organizer_test -Recurse -Force
```

### macOS or Linux

```bash
rm -rf organizer_test
```

Remove any temporary Python files you created for manual checks.

---

# Activity 16: Update the README

Ensure `README.md` includes:

```markdown
## File organizer

Preview organization:

```bash
python -m foundation_cli organize ./downloads --dry-run
```

Organize files:

```bash
python -m foundation_cli organize ./downloads
```
```

Why should the README recommend dry-run mode?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 5D Review

## 1. What does the organizer use to classify files?

```text
____________________________________________________________
```

## 2. What happens to files without extensions?

```text
____________________________________________________________
```

## 3. What does `--dry-run` do?

```text
____________________________________________________________

____________________________________________________________
```

## 4. Why should duplicate files not be overwritten?

```text
____________________________________________________________

____________________________________________________________
```

## 5. What does `shutil.move()` do?

```text
____________________________________________________________
```

## 6. Why does the organizer skip directories?

```text
____________________________________________________________
```

## 7. What happens if the requested directory does not exist?

```text
____________________________________________________________
```

---

# Part 5D Completion Checklist

- [ ] Create test files.
- [ ] Extract file extensions.
- [ ] Normalize extensions to lowercase.
- [ ] Handle files without extensions.
- [ ] Create `FileMove`.
- [ ] Plan moves without changing files.
- [ ] Execute moves.
- [ ] Create destination directories.
- [ ] Implement dry-run mode.
- [ ] Prevent duplicate overwrites.
- [ ] Handle missing directories.
- [ ] Handle file paths used as directories.
- [ ] Connect `organize` to the CLI.
- [ ] Test dry-run mode.
- [ ] Test actual moves.
- [ ] Clean up test files.

---

# Part 5D Reflection

Why is a dry run useful for file operations?

```text
____________________________________________________________

____________________________________________________________
```

What could go wrong if the organizer overwrote duplicate files?

```text
____________________________________________________________

____________________________________________________________
```

What additional file category could you support?

```text
____________________________________________________________
```

What improvement would make the organizer safer?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 5D Complete

You have completed:

```text
Part 5D: File Organizer
```

The next workbook section is:

# Part 5E: Testing and Final Verification

It will cover:

- Unit tests.
- Task tests.
- Storage tests.
- Organizer tests.
- Temporary directories.
- CLI verification.
- Production-readiness review.
- Final capstone completion.

---

# Student Workbook — Part 5E, Part 1 of 2: Automated Testing

This is the fifth section of Part 5.

To keep the workbook manageable, Part 5E is divided into:

1. **Part 5E-1:** Automated testing.
2. **Part 5E-2:** Final verification and production-readiness review.

In this section, you will:

- Understand automated tests.
- Test task logic.
- Test JSON storage.
- Test the file organizer.
- Use temporary directories.
- Run the full test suite.

---

# Part 5E-1 Learning Goals

By the end of this section, you should be able to:

- Explain why automated tests are useful.
- Create a `unittest.TestCase`.
- Test successful behavior.
- Test expected exceptions.
- Use temporary directories.
- Test JSON storage without changing real project data.
- Test dry-run file organization.
- Run the complete test suite.

---

# Activity 1: Why Test Automatically?

Manual testing might involve commands such as:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
```

Manual testing is useful, but it has limitations:

- It takes time.
- It may be inconsistent.
- It is easy to forget a case.
- Changes can break old behavior.
- It does not create a permanent record.

Automated tests can be run repeatedly:

```bash
python -m unittest discover -s tests -v
```

Complete the sentence:

```text
Automated tests help confirm that code continues to
____________________________________________________________
```

---

# Activity 2: Create a Basic Test

Create:

```text
tests/test_tasks.py
```

Add:

```python
import unittest


class BasicTests(unittest.TestCase):
    def test_addition(self):
        result = 2 + 3

        self.assertEqual(result, 5)


if __name__ == "__main__":
    unittest.main()
```

Run from the project root:

```bash
python -m unittest discover -s tests -v
```

Expected result:

```text
test_addition ... ok
```

The final result should include:

```text
OK
```

---

# Activity 3: Understand Assertions

Complete the table:

| Assertion | Purpose |
|---|---|
| `assertEqual(a, b)` | __________________________________ |
| `assertNotEqual(a, b)` | ______________________________ |
| `assertTrue(value)` | __________________________________ |
| `assertFalse(value)` | _________________________________ |
| `assertIsNone(value)` | ________________________________ |
| `assertIsNotNone(value)` | _____________________________ |
| `assertRaises(Error)` | _________________________________ |

Examples:

```python
self.assertEqual(2 + 3, 5)
self.assertTrue(True)
self.assertFalse(False)
self.assertIsNone(None)
```

---

# Activity 4: Test Task Creation

Replace the contents of:

```text
tests/test_tasks.py
```

with:

```python
import unittest

from foundation_cli.errors import InvalidTaskTitleError
from foundation_cli.tasks import create_task


class TaskTests(unittest.TestCase):
    def test_create_task_adds_task(self):
        tasks = []

        task = create_task(
            tasks,
            "Learn Python",
        )

        self.assertEqual(task["id"], 1)
        self.assertEqual(
            task["title"],
            "Learn Python",
        )
        self.assertFalse(task["completed"])
        self.assertEqual(len(tasks), 1)

    def test_create_task_strips_whitespace(self):
        tasks = []

        task = create_task(
            tasks,
            "  Learn Python  ",
        )

        self.assertEqual(
            task["title"],
            "Learn Python",
        )

    def test_create_task_rejects_empty_title(self):
        tasks = []

        with self.assertRaises(
            InvalidTaskTitleError
        ):
            create_task(tasks, "   ")


if __name__ == "__main__":
    unittest.main()
```

Run:

```bash
python -m unittest discover -s tests -v
```

Expected result:

```text
test_create_task_adds_task ... ok
test_create_task_rejects_empty_title ... ok
test_create_task_strips_whitespace ... ok

OK
```

---

# Activity 5: Test Task IDs

Add these tests to `tests/test_tasks.py` inside the `TaskTests` class:

```python
    def test_task_ids_increase(self):
        tasks = []

        first_task = create_task(
            tasks,
            "First task",
        )
        second_task = create_task(
            tasks,
            "Second task",
        )

        self.assertEqual(first_task["id"], 1)
        self.assertEqual(second_task["id"], 2)
```

Run:

```bash
python -m unittest discover -s tests -v
```

Expected:

```text
OK
```

---

# Activity 6: Test Finding Tasks

Update the imports in `tests/test_tasks.py`:

```python
from foundation_cli.tasks import (
    create_task,
    find_task,
)
```

Add these tests inside `TaskTests`:

```python
    def test_find_task_returns_matching_task(self):
        tasks = [
            {
                "id": 1,
                "title": "Learn Python",
                "completed": False,
            }
        ]

        task = find_task(tasks, 1)

        self.assertIsNotNone(task)
        self.assertEqual(
            task["title"],
            "Learn Python",
        )

    def test_find_task_returns_none_when_missing(self):
        task = find_task([], 999)

        self.assertIsNone(task)
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 7: Test Completing Tasks

Update the imports:

```python
from foundation_cli.errors import (
    InvalidTaskTitleError,
    TaskAlreadyCompletedError,
    TaskNotFoundError,
)
```

Update the task imports:

```python
from foundation_cli.tasks import (
    complete_task,
    create_task,
    find_task,
)
```

Add these tests:

```python
    def test_complete_task_marks_task_completed(self):
        tasks = [
            {
                "id": 1,
                "title": "Learn Python",
                "completed": False,
            }
        ]

        task = complete_task(tasks, 1)

        self.assertTrue(task["completed"])
        self.assertTrue(tasks[0]["completed"])

    def test_complete_missing_task_raises_error(self):
        with self.assertRaises(
            TaskNotFoundError
        ):
            complete_task([], 999)

    def test_complete_completed_task_raises_error(self):
        tasks = [
            {
                "id": 1,
                "title": "Already done",
                "completed": True,
            }
        ]

        with self.assertRaises(
            TaskAlreadyCompletedError
        ):
            complete_task(tasks, 1)
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 8: Test Removing Tasks

Update the task imports:

```python
from foundation_cli.tasks import (
    complete_task,
    create_task,
    find_task,
    remove_task,
)
```

Add:

```python
    def test_remove_task_removes_task(self):
        tasks = [
            {
                "id": 1,
                "title": "Learn Python",
                "completed": False,
            }
        ]

        removed_task = remove_task(tasks, 1)

        self.assertEqual(
            removed_task["id"],
            1,
        )
        self.assertEqual(tasks, [])

    def test_remove_missing_task_raises_error(self):
        with self.assertRaises(
            TaskNotFoundError
        ):
            remove_task([], 999)
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 9: Test Statistics

Update the task imports:

```python
from foundation_cli.tasks import (
    complete_task,
    count_completed,
    count_incomplete,
    create_task,
    find_task,
    remove_task,
)
```

Add:

```python
    def test_count_completed(self):
        tasks = [
            {
                "id": 1,
                "title": "First",
                "completed": True,
            },
            {
                "id": 2,
                "title": "Second",
                "completed": False,
            },
            {
                "id": 3,
                "title": "Third",
                "completed": True,
            },
        ]

        self.assertEqual(
            count_completed(tasks),
            2,
        )

    def test_count_incomplete(self):
        tasks = [
            {
                "id": 1,
                "title": "First",
                "completed": True,
            },
            {
                "id": 2,
                "title": "Second",
                "completed": False,
            },
        ]

        self.assertEqual(
            count_incomplete(tasks),
            1,
        )
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 10: Review the Task Tests

Your `tests/test_tasks.py` should now test:

- Creating a task.
- Stripping title whitespace.
- Rejecting empty titles.
- Increasing task IDs.
- Finding an existing task.
- Handling a missing task.
- Completing a task.
- Rejecting an already-completed task.
- Removing a task.
- Rejecting a missing task during removal.
- Counting completed tasks.
- Counting incomplete tasks.

Complete the table:

| Behavior | Tested? |
|---|---:|
| Create a task | [ ] |
| Reject an empty title | [ ] |
| Generate IDs | [ ] |
| Find a task | [ ] |
| Handle a missing task | [ ] |
| Complete a task | [ ] |
| Reject duplicate completion | [ ] |
| Remove a task | [ ] |
| Count completed tasks | [ ] |
| Count incomplete tasks | [ ] |

---

# Activity 11: Create Storage Tests

Create:

```text
tests/test_storage.py
```

Add:

```python
import tempfile
import unittest
from pathlib import Path

from foundation_cli.storage import (
    load_tasks,
    save_tasks,
)


class StorageTests(unittest.TestCase):
    def test_missing_file_returns_empty_list(self):
        with tempfile.TemporaryDirectory() as directory:
            file_path = Path(directory) / "tasks.json"

            tasks = load_tasks(file_path)

            self.assertEqual(tasks, [])

    def test_save_and_load_tasks(self):
        expected_tasks = [
            {
                "id": 1,
                "title": "Learn JSON",
                "completed": False,
            }
        ]

        with tempfile.TemporaryDirectory() as directory:
            file_path = Path(directory) / "tasks.json"

            save_tasks(
                expected_tasks,
                file_path,
            )

            actual_tasks = load_tasks(file_path)

            self.assertEqual(
                actual_tasks,
                expected_tasks,
            )

    def test_save_creates_parent_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            file_path = (
                Path(directory)
                / "nested"
                / "tasks.json"
            )

            save_tasks([], file_path)

            self.assertTrue(file_path.exists())
            self.assertEqual(
                load_tasks(file_path),
                [],
            )


if __name__ == "__main__":
    unittest.main()
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 12: Test Invalid JSON

Add this import:

```python
import json
```

Add this test inside `StorageTests`:

```python
    def test_invalid_json_raises_value_error(self):
        with tempfile.TemporaryDirectory() as directory:
            file_path = Path(directory) / "tasks.json"

            file_path.write_text(
                "This is not JSON.",
                encoding="utf-8",
            )

            with self.assertRaises(ValueError):
                load_tasks(file_path)
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 13: Test Incorrect JSON Structure

Add:

```python
    def test_json_must_contain_a_list(self):
        with tempfile.TemporaryDirectory() as directory:
            file_path = Path(directory) / "tasks.json"

            file_path.write_text(
                json.dumps(
                    {
                        "title": "Not a list",
                    }
                ),
                encoding="utf-8",
            )

            with self.assertRaises(ValueError):
                load_tasks(file_path)
```

This verifies that valid JSON still must have the correct application structure.

---

# Activity 14: Test Invalid Task Data

Add:

```python
    def test_invalid_task_shape_raises_value_error(self):
        invalid_tasks = [
            {
                "id": "wrong type",
                "title": "Invalid task",
                "completed": False,
            }
        ]

        with tempfile.TemporaryDirectory() as directory:
            file_path = Path(directory) / "tasks.json"

            file_path.write_text(
                json.dumps(invalid_tasks),
                encoding="utf-8",
            )

            with self.assertRaises(ValueError):
                load_tasks(file_path)
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 15: Create Organizer Tests

Create:

```text
tests/test_organizer.py
```

Add:

```python
import tempfile
import unittest
from pathlib import Path

from foundation_cli.organizer import (
    execute_moves,
    extension_folder,
    plan_moves,
)


class OrganizerTests(unittest.TestCase):
    def test_extension_folder_uses_lowercase(self):
        result = extension_folder(
            Path("PHOTO.JPG")
        )

        self.assertEqual(result, "jpg")

    def test_extension_folder_handles_no_extension(self):
        result = extension_folder(
            Path("README")
        )

        self.assertEqual(
            result,
            "no_extension",
        )

    def test_plan_moves_only_includes_files(self):
        with tempfile.TemporaryDirectory() as directory:
            directory_path = Path(directory)

            (directory_path / "report.pdf").write_text(
                "PDF",
                encoding="utf-8",
            )

            (directory_path / "notes.txt").write_text(
                "Notes",
                encoding="utf-8",
            )

            (directory_path / "existing_folder").mkdir()

            moves = plan_moves(directory_path)

            sources = {
                move.source.name
                for move in moves
            }

            self.assertEqual(
                sources,
                {
                    "report.pdf",
                    "notes.txt",
                },
            )

    def test_dry_run_does_not_move_files(self):
        with tempfile.TemporaryDirectory() as directory:
            directory_path = Path(directory)
            source = directory_path / "report.pdf"

            source.write_text(
                "PDF",
                encoding="utf-8",
            )

            moves = plan_moves(directory_path)
            moved_count = execute_moves(
                moves,
                dry_run=True,
            )

            self.assertEqual(moved_count, 0)
            self.assertTrue(source.exists())
            self.assertFalse(
                (
                    directory_path
                    / "pdf"
                    / "report.pdf"
                ).exists()
            )


if __name__ == "__main__":
    unittest.main()
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 16: Test Actual File Moves

Add this test inside `OrganizerTests`:

```python
    def test_execute_moves_moves_files(self):
        with tempfile.TemporaryDirectory() as directory:
            directory_path = Path(directory)
            source = directory_path / "report.pdf"

            source.write_text(
                "PDF",
                encoding="utf-8",
            )

            moves = plan_moves(directory_path)
            moved_count = execute_moves(moves)

            destination = (
                directory_path
                / "pdf"
                / "report.pdf"
            )

            self.assertEqual(moved_count, 1)
            self.assertFalse(source.exists())
            self.assertTrue(destination.exists())
            self.assertEqual(
                destination.read_text(
                    encoding="utf-8"
                ),
                "PDF",
            )
```

Run:

```bash
python -m unittest discover -s tests -v
```

The test uses a temporary directory, so it does not move files in your real project.

---

# Activity 17: Test Duplicate Names

Add:

```python
    def test_duplicate_names_are_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            directory_path = Path(directory)
            pdf_directory = directory_path / "pdf"

            pdf_directory.mkdir()

            existing_file = (
                pdf_directory / "report.pdf"
            )

            existing_file.write_text(
                "Existing",
                encoding="utf-8",
            )

            source = directory_path / "report.pdf"

            source.write_text(
                "New",
                encoding="utf-8",
            )

            moves = plan_moves(directory_path)
            execute_moves(moves)

            duplicate_file = (
                pdf_directory / "report_1.pdf"
            )

            self.assertTrue(existing_file.exists())
            self.assertTrue(duplicate_file.exists())

            self.assertEqual(
                existing_file.read_text(
                    encoding="utf-8"
                ),
                "Existing",
            )

            self.assertEqual(
                duplicate_file.read_text(
                    encoding="utf-8"
                ),
                "New",
            )
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 18: Test a Missing Directory

Add:

```python
    def test_missing_directory_raises_error(self):
        with tempfile.TemporaryDirectory() as directory:
            directory_path = (
                Path(directory)
                / "does-not-exist"
            )

            with self.assertRaises(
                FileNotFoundError
            ):
                plan_moves(directory_path)
```

Run:

```bash
python -m unittest discover -s tests -v
```

---

# Activity 19: Run All Tests

Run:

```bash
python -m unittest discover -s tests -v
```

The output should end with something similar to:

```text
----------------------------------------------------------------------
Ran 20 tests in 0.05s

OK
```

The exact number may differ depending on the tests you included.

Record your result:

```text
Tests run:

____________________________________________________________

Final result:

____________________________________________________________
```

If the final result is not `OK`, record the failing test:

```text
Failing test:

____________________________________________________________

Error message:

____________________________________________________________
```

---

# Activity 20: Test Failure Diagnosis

If a test fails, use this process:

```text
1. Read the failing test name.
2. Read the assertion message.
3. Find the source function being tested.
4. Reproduce the behavior manually.
5. Inspect the values involved.
6. Make one change.
7. Run the test again.
```

Do not skip directly to changing several files.

---

# Part 5E-1 Review

## 1. Why are automated tests useful?

```text
____________________________________________________________

____________________________________________________________
```

## 2. What does `unittest.TestCase` provide?

```text
____________________________________________________________
```

## 3. Why use temporary directories?

```text
____________________________________________________________

____________________________________________________________
```

## 4. What does `assertRaises()` test?

```text
____________________________________________________________
```

## 5. Why should the organizer tests not use your real downloads folder?

```text
____________________________________________________________

____________________________________________________________
```

## 6. What should the test suite display when every test passes?

```text
____________________________________________________________
```

---

# Part 5E-1 Completion Checklist

- [ ] Create `tests/test_tasks.py`.
- [ ] Test task creation.
- [ ] Test empty-title rejection.
- [ ] Test task IDs.
- [ ] Test task lookup.
- [ ] Test task completion.
- [ ] Test duplicate completion.
- [ ] Test task removal.
- [ ] Test missing tasks.
- [ ] Test task statistics.
- [ ] Create `tests/test_storage.py`.
- [ ] Test missing files.
- [ ] Test saving and loading.
- [ ] Test nested directories.
- [ ] Test invalid JSON.
- [ ] Test invalid task structures.
- [ ] Create `tests/test_organizer.py`.
- [ ] Test extensions.
- [ ] Test dry-run mode.
- [ ] Test actual moves.
- [ ] Test duplicate names.
- [ ] Test missing directories.
- [ ] Run the complete test suite.

---

# Part 5E-1 Complete

You have completed the automated-testing portion of the capstone.

The next section is:

# Part 5E-2: Final Verification and Production Readiness

It will cover:

- Manual CLI testing.
- Final project structure.
- Complete command verification.
- Data-file verification.
- Organizer verification.
- Production-readiness review.
- Final capstone checklist.

---

# Student Workbook — Part 5E-2: Final Verification and Production Readiness

This is the final section of the Student Workbook.

You have already:

- Built the CLI structure.
- Implemented task logic.
- Added JSON storage.
- Added custom exceptions.
- Built the file organizer.
- Added automated tests.

Now you will perform a complete verification of the capstone.

---

# Part 5E-2 Learning Goals

By the end of this section, you should be able to:

- Run every CLI command.
- Verify successful and unsuccessful behavior.
- Confirm that task data persists.
- Test the file organizer safely.
- Confirm that automated tests pass.
- Review the project architecture.
- Identify possible future improvements.
- Complete the capstone project.

---

# Activity 1: Confirm the Environment

Activate the virtual environment.

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

### macOS or Linux

```bash
source .venv/bin/activate
```

Confirm the Python version:

```bash
python --version
```

Confirm the Python executable:

```bash
python -c "import sys; print(sys.executable)"
```

The executable path should contain:

```text
.venv
```

Record:

```text
Python version:

____________________________________________________________

Python executable:

____________________________________________________________
```

---

# Activity 2: Reinstall the Project

From the project root, run:

```bash
python -m pip install --editable .
```

Expected result should indicate that the project was installed.

Record:

```text
Installation result:

____________________________________________________________
```

---

# Activity 3: Inspect the Final Help

Run:

```bash
python -m foundation_cli --help
```

Confirm that the help includes:

```text
add
list
complete
remove
stats
organize
```

Record all commands:

```text
1. ________________________________________________________

2. ________________________________________________________

3. ________________________________________________________

4. ________________________________________________________

5. ________________________________________________________

6. ________________________________________________________
```

---

# Activity 4: Check the Version

Run:

```bash
python -m foundation_cli --version
```

Expected:

```text
foundation 0.1.0
```

Record:

```text
____________________________________________________________
```

---

# Activity 5: Start with Clean Data

For a clean verification, remove the current task file.

### Windows PowerShell

```powershell
Remove-Item data\tasks.json -ErrorAction SilentlyContinue
```

### macOS or Linux

```bash
rm -f data/tasks.json
```

Run:

```bash
python -m foundation_cli list
```

Expected:

```text
No tasks found.
```

Record:

```text
____________________________________________________________
```

---

# Activity 6: Add Tasks

Run:

```bash
python -m foundation_cli add "Learn Python"
```

Expected:

```text
Task created:
  ID: 1
  Title: Learn Python
  Status: incomplete
```

Add another task:

```bash
python -m foundation_cli add "Practice testing"
```

Expected:

```text
Task created:
  ID: 2
  Title: Practice testing
  Status: incomplete
```

Add a third task:

```bash
python -m foundation_cli add "Review the capstone"
```

Expected:

```text
Task created:
  ID: 3
  Title: Review the capstone
  Status: incomplete
```

Record the IDs:

```text
Learn Python:

____________________________________________________________

Practice testing:

____________________________________________________________

Review the capstone:

____________________________________________________________
```

---

# Activity 7: List Tasks

Run:

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[ ] 1 - Learn Python
[ ] 2 - Practice testing
[ ] 3 - Review the capstone
```

Record your output:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Activity 8: Complete a Task

Run:

```bash
python -m foundation_cli complete 1
```

Expected:

```text
Task completed:
  ID: 1
  Title: Learn Python
```

List tasks:

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[x] 1 - Learn Python
[ ] 2 - Practice testing
[ ] 3 - Review the capstone
```

Record:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 9: Complete Another Task

Run:

```bash
python -m foundation_cli complete 2
```

Then:

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[x] 1 - Learn Python
[x] 2 - Practice testing
[ ] 3 - Review the capstone
```

Record the number of completed tasks:

```text
____________________________________________________________
```

---

# Activity 10: Test Duplicate Completion

Run:

```bash
python -m foundation_cli complete 1
```

Expected:

```text
Error: Task 1 is already completed.
```

Record:

```text
____________________________________________________________
```

The program should display a friendly message and should not produce a traceback.

---

# Activity 11: Display Statistics

Run:

```bash
python -m foundation_cli stats
```

Expected:

```text
Total tasks: 3
Completed tasks: 2
Incomplete tasks: 1
```

Record:

```text
Total tasks:

____________________________________________________________

Completed tasks:

____________________________________________________________

Incomplete tasks:

____________________________________________________________
```

---

# Activity 12: Remove a Task

Run:

```bash
python -m foundation_cli remove 3
```

Expected:

```text
Task removed:
  ID: 3
  Title: Review the capstone
```

List the remaining tasks:

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[x] 1 - Learn Python
[x] 2 - Practice testing
```

Record:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 13: Test Missing Tasks

Run:

```bash
python -m foundation_cli complete 999
```

Expected:

```text
Error: No task found with ID 999.
```

Run:

```bash
python -m foundation_cli remove 999
```

Expected:

```text
Error: No task found with ID 999.
```

Record:

```text
Complete result:

____________________________________________________________

Remove result:

____________________________________________________________
```

---

# Activity 14: Test Invalid IDs

Run:

```bash
python -m foundation_cli complete abc
```

Expected output should indicate:

```text
must be a whole number
```

Run:

```bash
python -m foundation_cli remove 0
```

Expected output should indicate:

```text
must be greater than zero
```

Run:

```bash
python -m foundation_cli complete -1
```

Expected output should indicate:

```text
must be greater than zero
```

Complete the table:

| Command | Result |
|---|---|
| `complete abc` | __________________ |
| `remove 0` | __________________ |
| `complete -1` | __________________ |

---

# Activity 15: Test Invalid Titles

Run:

```bash
python -m foundation_cli add ""
```

Expected:

```text
Error: Task title cannot be empty.
```

Try whitespace-only input:

```bash
python -m foundation_cli add "   "
```

Expected:

```text
Error: Task title cannot be empty.
```

Record:

```text
Empty title result:

____________________________________________________________

Whitespace title result:

____________________________________________________________
```

---

# Activity 16: Verify JSON Persistence

Display the task file.

### Windows PowerShell

```powershell
Get-Content data\tasks.json
```

### macOS or Linux

```bash
cat data/tasks.json
```

Validate and format it:

```bash
python -m json.tool data/tasks.json
```

Confirm:

- Task IDs are integers.
- Titles are strings.
- Completion values are Boolean.
- Removed tasks are absent.
- Completed tasks have `"completed": true`.

Record an observation:

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 17: Restart Verification

Close the terminal or deactivate the environment:

```bash
deactivate
```

Open a new terminal.

Return to the project root:

```bash
cd path/to/python-foundations
```

Activate the environment again.

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

### macOS or Linux

```bash
source .venv/bin/activate
```

Run:

```bash
python -m foundation_cli list
```

The tasks should still be available.

Why?

```text
____________________________________________________________

____________________________________________________________
```

---

# Activity 18: Create an Organizer Test Directory

Create:

```text
organizer_demo/
```

### Windows PowerShell

```powershell
mkdir organizer_demo
Set-Content organizer_demo\report.pdf "PDF content"
Set-Content organizer_demo\photo.jpg "JPG content"
Set-Content organizer_demo\notes.txt "Text content"
Set-Content organizer_demo\README "No extension"
```

### macOS or Linux

```bash
mkdir -p organizer_demo
printf "PDF content" > organizer_demo/report.pdf
printf "JPG content" > organizer_demo/photo.jpg
printf "Text content" > organizer_demo/notes.txt
printf "No extension" > organizer_demo/README
```

---

# Activity 19: Test Organizer Dry Run

Run:

```bash
python -m foundation_cli organize organizer_demo --dry-run
```

Expected output should list planned moves.

Confirm:

```text
No files should have moved.
```

Record:

```text
____________________________________________________________

____________________________________________________________
```

Inspect the directory and verify that the original files remain directly inside `organizer_demo`.

---

# Activity 20: Run the Organizer

Run:

```bash
python -m foundation_cli organize organizer_demo
```

Expected structure:

```text
organizer_demo/
├── jpg/
│   └── photo.jpg
├── no_extension/
│   └── README
├── pdf/
│   └── report.pdf
└── txt/
    └── notes.txt
```

Record the number of moved files:

```text
____________________________________________________________
```

---

# Activity 21: Test Duplicate Protection

Create another file with the same name as an existing source file.

### Windows PowerShell

```powershell
Set-Content organizer_demo\photo.jpg "Another JPG"
```

### macOS or Linux

```bash
printf "Another JPG" > organizer_demo/photo.jpg
```

Run:

```bash
python -m foundation_cli organize organizer_demo
```

Expected:

```text
photo_1.jpg
```

Confirm that both files exist:

```text
Original file preserved:

____________________________________________________________

New file created:

____________________________________________________________
```

---

# Activity 22: Test Invalid Organizer Paths

Run:

```bash
python -m foundation_cli organize missing_directory
```

Expected:

```text
Directory does not exist
```

Run the organizer on a file:

```bash
python -m foundation_cli organize organizer_demo/jpg/photo.jpg
```

Expected:

```text
Path is not a directory
```

Record:

```text
Missing directory:

____________________________________________________________

File used as directory:

____________________________________________________________
```

---

# Activity 23: Clean Up Organizer Data

Remove the temporary organizer directory.

### Windows PowerShell

```powershell
Remove-Item organizer_demo -Recurse -Force
```

### macOS or Linux

```bash
rm -rf organizer_demo
```

Confirm that the temporary directory is gone.

---

# Activity 24: Run the Complete Test Suite

Run:

```bash
python -m unittest discover -s tests -v
```

The final output should end with:

```text
OK
```

Record:

```text
Number of tests:

____________________________________________________________

Final result:

____________________________________________________________
```

If any test fails, record it:

```text
Failing test:

____________________________________________________________

Error:

____________________________________________________________

Likely cause:

____________________________________________________________
```

---

# Activity 25: Review the Project Structure

Your completed project should look similar to:

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

Check each file:

| File | Present? |
|---|---:|
| `README.md` | [ ] |
| `pyproject.toml` | [ ] |
| `__init__.py` | [ ] |
| `__main__.py` | [ ] |
| `cli.py` | [ ] |
| `errors.py` | [ ] |
| `organizer.py` | [ ] |
| `storage.py` | [ ] |
| `tasks.py` | [ ] |
| `test_organizer.py` | [ ] |
| `test_storage.py` | [ ] |
| `test_tasks.py` | [ ] |

---

# Activity 26: Review Module Responsibilities

Complete the table:

| Module | Responsibility |
|---|---|
| `cli.py` | __________________________________ |
| `tasks.py` | __________________________________ |
| `storage.py` | ______________________________ |
| `organizer.py` | _____________________________ |
| `errors.py` | ________________________________ |
| `__main__.py` | ______________________________ |

---

# Activity 27: Production-Readiness Review

Review the application against these qualities.

## Clear Names

Examples:

```python
load_tasks()
save_tasks()
complete_task()
organize_directory()
```

Does the project use clear names?

```text
[ ] Yes
[ ] Needs improvement
```

## Focused Functions

Does each function have a focused responsibility?

```text
[ ] Yes
[ ] Needs improvement
```

## Input Validation

Does the application reject invalid IDs and empty titles?

```text
[ ] Yes
[ ] Needs improvement
```

## Safe File Operations

Does the organizer support dry-run mode and duplicate protection?

```text
[ ] Yes
[ ] Needs improvement
```

## Persistent Storage

Are tasks saved to JSON?

```text
[ ] Yes
[ ] Needs improvement
```

## Automated Tests

Do the tests pass?

```text
[ ] Yes
[ ] Needs improvement
```

---

# Activity 28: Final Command Reference

Record whether each command works.

| Command | Works? |
|---|---:|
| `python -m foundation_cli --help` | [ ] |
| `python -m foundation_cli --version` | [ ] |
| `python -m foundation_cli add "Task"` | [ ] |
| `python -m foundation_cli list` | [ ] |
| `python -m foundation_cli complete 1` | [ ] |
| `python -m foundation_cli remove 1` | [ ] |
| `python -m foundation_cli stats` | [ ] |
| `python -m foundation_cli organize folder --dry-run` | [ ] |
| `python -m foundation_cli organize folder` | [ ] |
| `python -m unittest discover -s tests -v` | [ ] |

---

# Activity 29: Final Capstone Checklist

## Project Setup

- [ ] The virtual environment works.
- [ ] The package is installed in editable mode.
- [ ] `python -m foundation_cli` works.
- [ ] The project uses a `src` layout.
- [ ] `pyproject.toml` exists.
- [ ] `README.md` exists.

## CLI

- [ ] Help is available.
- [ ] Version information is available.
- [ ] Missing commands display help.
- [ ] Invalid arguments are rejected.
- [ ] Commands dispatch correctly.

## Task Management

- [ ] Tasks can be added.
- [ ] Empty titles are rejected.
- [ ] Tasks can be listed.
- [ ] Tasks can be completed.
- [ ] Already-completed tasks are rejected.
- [ ] Tasks can be removed.
- [ ] Missing task IDs are handled.
- [ ] Statistics are accurate.
- [ ] Tasks persist after restarting the application.
- [ ] JSON data is valid.
- [ ] Removed tasks are absent from the JSON file.

## File Organizer

- [ ] Files are grouped by extension.
- [ ] Uppercase extensions are normalized.
- [ ] Files without extensions are supported.
- [ ] Dry-run mode does not move files.
- [ ] Duplicate names are not overwritten.
- [ ] Missing directories are reported.
- [ ] File paths are rejected when a directory is required.
- [ ] Temporary organizer files are removed after testing.

## Testing

- [ ] Task tests pass.
- [ ] Storage tests pass.
- [ ] Organizer tests pass.
- [ ] The complete test suite ends with `OK`.
- [ ] Tests use temporary files or directories where appropriate.

---

# Activity 30: Final Architecture Review

Complete the application flow:

```text
Command-line input
        ↓
______________________________
        ↓
______________________________
        ↓
______________________________
        ↓
Terminal output or file change
```

Suggested answers:

```text
Argument parsing
        ↓
CLI command dispatch
        ↓
Application logic
        ↓
Storage or file-system operation
```

---

# Activity 31: Explain the Application Layers

## CLI Layer

What does the CLI layer do?

```text
____________________________________________________________

____________________________________________________________
```

## Application Logic Layer

What does `tasks.py` do?

```text
____________________________________________________________

____________________________________________________________
```

## Storage Layer

What does `storage.py` do?

```text
____________________________________________________________

____________________________________________________________
```

## File Organizer Layer

What does `organizer.py` do?

```text
____________________________________________________________

____________________________________________________________
```

## Error Layer

What does `errors.py` do?

```text
____________________________________________________________
```

---

# Activity 32: Identify Future Improvements

Choose at least three improvements you might add later:

- [ ] Edit an existing task.
- [ ] Add task priorities.
- [ ] Add due dates.
- [ ] Filter tasks by completion status.
- [ ] Search tasks by title.
- [ ] Export tasks to CSV.
- [ ] Import tasks from CSV.
- [ ] Add colored terminal output.
- [ ] Add logging.
- [ ] Add configuration files.
- [ ] Add a database.
- [ ] Add more CLI options.
- [ ] Add continuous integration.
- [ ] Package and publish the application.

My planned improvements:

```text
1. _________________________________________________________

2. _________________________________________________________

3. _________________________________________________________
```

---

# Activity 33: Final Reflection

## What Can You Build Now?

Describe a program you could build using the skills from this series:

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## What Programming Concept Was Most Important?

```text
____________________________________________________________

____________________________________________________________
```

## What Was Most Difficult?

```text
____________________________________________________________

____________________________________________________________
```

## What Error Taught You the Most?

```text
____________________________________________________________

____________________________________________________________
```

## What Would You Do Differently in Your Next Project?

```text
____________________________________________________________

____________________________________________________________
```

---

# Final Capstone Completion Certificate

Complete the statement:

```text
I completed the Python Foundations capstone.

I built a command-line application that can:

____________________________________________________________

____________________________________________________________

____________________________________________________________

I verified the application with:

____________________________________________________________

____________________________________________________________
```

Name:

```text
____________________________________________________________
```

Date:

```text
____________________________________________________________
```

---

# Final Capstone Summary

You have built a structured Python application with:

## Task Management

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
```

## File Organization

```bash
python -m foundation_cli organize downloads --dry-run
python -m foundation_cli organize downloads
```

## Persistent Storage

```text
data/tasks.json
```

## Application Modules

```text
src/foundation_cli/
├── cli.py
├── tasks.py
├── storage.py
├── organizer.py
└── errors.py
```

## Automated Tests

```text
tests/
├── test_tasks.py
├── test_storage.py
└── test_organizer.py
```

## Test Command

```bash
python -m unittest discover -s tests -v
```

---

# Final Student Workbook Completion Checklist

## Part 1: Environment and Syntax

- [ ] Python installed and verified.
- [ ] Virtual environment created.
- [ ] Variables understood.
- [ ] Basic data types understood.
- [ ] User input used.
- [ ] Basic errors investigated.

## Part 2: Collections

- [ ] Lists used.
- [ ] Tuples used.
- [ ] Dictionaries used.
- [ ] Sets used.
- [ ] Nested collections created.
- [ ] Collection choices understood.

## Part 3: Program Flow

- [ ] Conditions used.
- [ ] Loops used.
- [ ] `break` and `continue` used.
- [ ] Input validated.
- [ ] Interactive task manager created.

## Part 4: Functions and IO

- [ ] Functions created.
- [ ] Modules imported.
- [ ] Text files read and written.
- [ ] `pathlib` used.
- [ ] JSON used.
- [ ] Exceptions handled.
- [ ] Persistent task manager created.

## Part 5: Capstone

- [ ] Package structure created.
- [ ] CLI created.
- [ ] Task commands implemented.
- [ ] JSON storage implemented.
- [ ] File organizer implemented.
- [ ] Custom errors added.
- [ ] Automated tests added.
- [ ] Final verification completed.

---

# Student Workbook Complete

You have completed the workbook for:

```text
Python Foundations: From Zero to Functional Code
```

The complete learning path was:

```text
Environment and syntax
        ↓
Collections
        ↓
Program flow
        ↓
Functions and input/output
        ↓
Command-line capstone
        ↓
Testing and debugging
```

The central skill you developed is the ability to turn a requirement into:

```text
Data structures
        ↓
Functions
        ↓
Control flow
        ↓
Input validation
        ↓
Storage
        ↓
Testing
        ↓
A working program
```

The next step is to continue improving the application independently, one small feature and one verified change at a time.
