# Trainer Guide — Python Foundations: From Zero to Functional Code

## Trainer Edition

This guide supports instructors, mentors, and workshop facilitators delivering the **Python Foundations** series.

The course takes complete beginners from basic Python syntax to a tested, persistent command-line application.

The guide includes:

- Course goals.
- Audience and prerequisites.
- Recommended delivery format.
- Teaching strategies.
- Lesson objectives.
- Timing guidance.
- Demonstration notes.
- Common learner difficulties.
- Assessment methods.
- Troubleshooting advice.
- Capstone facilitation.
- Final evaluation criteria.

To keep the guide manageable, it is divided into sections:

```text
Trainer Guide Part 1: Course Design and Delivery
Trainer Guide Part 2: Teaching Modules 1 and 2
Trainer Guide Part 3: Teaching Modules 3 and 4
Trainer Guide Part 4: Teaching the Capstone
Trainer Guide Part 5: Assessment, Troubleshooting, and Extensions
```

This section is **Trainer Guide Part 1**.

---

# 1. Course Overview

## Course Title

```text
Python Foundations: From Zero to Functional Code
```

## Target Audience

This course is designed for:

- Complete programming beginners.
- Hobbyists.
- Students learning Python for the first time.
- Developers transitioning from non-scripting languages.
- Professionals who need a practical Python foundation.
- Learners who understand basic computer operations but have limited programming experience.

---

# 2. Course Description

Learners begin by setting up Python and writing simple scripts. They then learn how to:

- Store values.
- Organize collections.
- Control program flow.
- Define reusable functions.
- Read and write files.
- Work with JSON.
- Handle expected errors.
- Build a command-line application.
- Write automated tests.
- Debug problems methodically.

The course uses a progressive capstone approach. Each module contributes knowledge needed for the final application.

The final project is a multi-utility command-line application with:

- Task management.
- JSON persistence.
- File organization.
- Input validation.
- Error handling.
- Automated tests.

---

# 3. Course Outcomes

By the end of the course, learners should be able to:

## Environment

- Install or locate Python.
- Check the Python version.
- Create a virtual environment.
- Activate and deactivate the environment.
- Run Python scripts.
- Use the interactive Python shell.

## Python Fundamentals

- Use variables and basic data types.
- Perform arithmetic.
- Format strings with f-strings.
- Convert values between types.
- Read basic user input.
- Explain common type errors.

## Collections

- Use lists.
- Use tuples.
- Use dictionaries.
- Use sets.
- Choose an appropriate collection type.
- Represent multiple records with lists of dictionaries.

## Program Flow

- Use `if`, `elif`, and `else`.
- Use comparison and logical operators.
- Write `for` loops.
- Write `while` loops.
- Use `range()` and `enumerate()`.
- Use `break` and `continue`.
- Validate user input.

## Reusable Code and IO

- Define functions.
- Use parameters and return values.
- Explain local scope.
- Add type hints.
- Import modules.
- Read and write text files.
- Use `pathlib`.
- Read and write JSON.
- Handle exceptions.

## Application Development

- Organize a Python project.
- Build a command-line interface.
- Separate responsibilities across modules.
- Persist data.
- Handle invalid input safely.
- Write automated tests.
- Use temporary directories in tests.
- Explain application architecture.

---

# 4. Recommended Delivery Formats

The course can be delivered in several formats.

## Intensive Workshop

Recommended duration:

```text
5 full days
```

Possible schedule:

| Day | Focus |
|---|---|
| Day 1 | Environment, syntax, and basic values |
| Day 2 | Collections and program flow |
| Day 3 | Functions, files, JSON, and exceptions |
| Day 4 | Capstone architecture and task commands |
| Day 5 | File organizer, tests, and final verification |

---

## Weekly Course

Recommended duration:

```text
8–10 weeks
```

Possible schedule:

| Week | Focus |
|---|---|
| 1 | Environment and Python syntax |
| 2 | Strings, numbers, Booleans, and input |
| 3 | Lists, tuples, dictionaries, and sets |
| 4 | Conditions and loops |
| 5 | Functions and modules |
| 6 | Files, JSON, and exceptions |
| 7 | Capstone CLI and task storage |
| 8 | File organizer and testing |
| 9 | Debugging and production-readiness |
| 10 | Presentations and extensions |

---

## Self-Paced Course

For self-paced learners, each lesson should include:

1. A short explanation.
2. A complete example.
3. A guided exercise.
4. A verification step.
5. A reflection question.
6. A progress checkpoint.

The trainer should encourage learners to avoid moving forward until the current step works.

---

# 5. Recommended Session Structure

Use this pattern for each teaching session.

## 1. Opening — 5 to 10 Minutes

Cover:

- What the lesson teaches.
- Why the concept matters.
- How it connects to the capstone.
- What learners will build.

Example:

> Today we will learn lists and dictionaries. These structures allow the task manager to store multiple tasks and task properties.

---

## 2. Concept Explanation — 15 to 25 Minutes

Explain the concept with:

- Plain language.
- A simple analogy.
- One small code example.
- A comparison with a familiar concept.

Avoid introducing too many related ideas at once.

---

## 3. Live Demonstration — 15 to 20 Minutes

Write code visibly and deliberately.

The trainer should:

- Type rather than paste whenever practical.
- Explain punctuation.
- Deliberately run the program.
- Show the output.
- Make one small mistake.
- Read and fix the error.

Learners should see that errors are a normal part of programming.

---

## 4. Guided Practice — 20 to 40 Minutes

Learners complete a similar exercise with support.

The trainer should circulate or monitor:

- Indentation.
- File paths.
- Command spelling.
- Variable names.
- Error messages.
- Whether learners are running the correct file.

---

## 5. Independent Practice — 20 to 40 Minutes

Learners modify or extend the example independently.

Examples:

- Add fields to a dictionary.
- Add a new task.
- Validate another input.
- Add a statistics command.
- Write a new test.

---

## 6. Verification — 10 to 15 Minutes

Require learners to run the program and record the result.

Verification questions:

```text
What command did you run?
What output did you expect?
What output did you receive?
Did the program handle invalid input?
```

---

## 7. Reflection — 5 to 10 Minutes

Ask learners to explain:

- What the code does.
- Why it is structured that way.
- What could go wrong.
- How they would test it.

---

# 6. Teaching Principles

## Principle 1: Prefer Understanding Over Speed

Beginners often appear to progress quickly when copying code, but copying does not guarantee understanding.

Ask learners:

- What does this variable represent?
- What type is this value?
- Why does this function return a value?
- What happens if the list is empty?
- What happens if the file is missing?

---

## Principle 2: Make Errors Visible

Do not hide every error.

Use small demonstrations:

```python
age = "36"
print(age + 1)
```

Ask learners to predict what will happen.

Then run it and inspect the error.

Teach learners that errors contain useful information.

---

## Principle 3: Change One Thing at a Time

When learners encounter a problem, discourage random changes.

Use:

```text
Observe
    ↓
Identify
    ↓
Inspect
    ↓
Change one thing
    ↓
Test again
```

---

## Principle 4: Connect Every Concept to the Capstone

Examples:

| Concept | Capstone connection |
|---|---|
| Variables | Task fields |
| Lists | Task collections |
| Dictionaries | Individual tasks |
| Conditions | Completion status |
| Loops | Displaying tasks |
| Functions | Task operations |
| Files | Persistent data |
| JSON | Task storage |
| Exceptions | Safe failures |
| `pathlib` | Data and organizer paths |
| `argparse` | CLI commands |
| Tests | Reliable behavior |

---

## Principle 5: Encourage Learners to Explain

A learner who can explain code is more likely to understand it.

Ask learners to explain a function using this template:

```text
This function receives:
____________________________________________________________

It does:
____________________________________________________________

It returns:
____________________________________________________________

It may fail when:
____________________________________________________________
```

---

# 7. Trainer Preparation Checklist

Before teaching the course, confirm that you can:

- [ ] Install Python or identify the correct interpreter.
- [ ] Create and activate a virtual environment.
- [ ] Run every course example.
- [ ] Run the capstone from a clean directory.
- [ ] Reproduce common beginner errors.
- [ ] Explain the project structure.
- [ ] Run the automated tests.
- [ ] Demonstrate the file organizer safely.
- [ ] Explain the difference between `python`, `python3`, and `py`.
- [ ] Support both Windows and macOS/Linux commands.
- [ ] Prepare a backup copy of the working capstone.
- [ ] Prepare a deliberately broken example for debugging.

---

# 8. Required Trainer Materials

The trainer should prepare:

- A working Python installation.
- A code editor.
- A terminal.
- The course source files.
- The Student Workbook.
- A clean capstone project.
- A backup capstone project.
- Sample JSON files.
- Sample organizer files.
- A list of common error messages.
- A test environment.

Optional materials:

- Projector or screen sharing.
- Whiteboard.
- Printed worksheets.
- Pair-programming exercises.
- Exit-ticket questions.
- Code-review checklist.

---

# 9. Learner Prerequisites

Learners do not need prior Python knowledge.

They should be comfortable with:

- Creating folders.
- Opening files.
- Saving files.
- Opening a terminal.
- Copying and pasting text.
- Running commands.
- Finding files.

No advanced mathematics is required.

If learners have programming experience in another language, explain that Python's syntax may differ even when the underlying concepts are familiar.

---

# 10. Common Teaching Challenges

## Challenge: Learners Confuse the Terminal and Editor

Clarify the difference:

| Tool | Purpose |
|---|---|
| Code editor | Write and save Python files |
| Terminal | Run commands and programs |
| Python shell | Test short Python expressions |

A common workflow is:

```text
Write code in editor
        ↓
Save the file
        ↓
Run the file in terminal
        ↓
Inspect output
        ↓
Return to editor if needed
```

---

## Challenge: Learners Copy Code Without Understanding

Pause after each block and ask:

```text
What is the type of this value?
What does this line change?
What happens if this value is empty?
```

Require learners to modify at least one part of every example.

---

## Challenge: Learners Fear Errors

Normalize errors by saying:

> A traceback is information. It tells us what Python noticed and where it noticed it.

Use a deliberate-error activity:

```python
numbers = [1, 2, 3]

print(numbers[5])
```

Ask learners to identify:

- Error type.
- File.
- Line.
- Cause.
- Fix.

---

## Challenge: Learners Fall Behind During Setup

Do not let setup problems consume the entire lesson.

Prepare:

- A troubleshooting sheet.
- A verified environment.
- An alternative computer.
- A shared starter project.
- A short setup verification script.

A learner may continue conceptual activities while setup is being repaired.

---

# 11. Formative Assessment

Use short assessments throughout the course.

## Prediction Questions

Before running code, ask learners to predict output:

```python
values = [1, 2, 3]
values.append(4)

print(values)
```

Ask:

```text
What will be displayed?
```

---

## Explain-in-Your-Own-Words Questions

Examples:

```text
Why does input() return a string?
```

```text
Why does the task manager use a list of dictionaries?
```

```text
Why should storage logic be separated from CLI logic?
```

---

## Small Code Tasks

Ask learners to write:

- A function that returns a total.
- A function that finds a task.
- A validation check.
- A loop that displays numbered items.
- A test for an invalid title.

---

## Exit Ticket

At the end of a lesson, ask learners to answer:

```text
Today I learned:
____________________________________________________________

One thing I can now do:
____________________________________________________________

One question I still have:
____________________________________________________________
```

---

# 12. Recommended Assessment Categories

Assess learners in five areas:

| Category | Suggested weighting |
|---|---:|
| Environment and syntax | 15% |
| Data structures and control flow | 20% |
| Functions, files, and JSON | 20% |
| Capstone functionality | 30% |
| Testing, debugging, and explanation | 15% |

Adjust the weighting according to the course format.

---

# 13. Trainer Observation Checklist

During practical work, observe whether learners:

- [ ] Use meaningful variable names.
- [ ] Indent code correctly.
- [ ] Run programs from the correct directory.
- [ ] Read error messages.
- [ ] Check types when needed.
- [ ] Use small functions.
- [ ] Validate input.
- [ ] Test invalid cases.
- [ ] Ask focused questions.
- [ ] Explain their decisions.
- [ ] Avoid changing many things at once.

---

# 14. Recommended Trainer Language

Useful phrases:

```text
What did you expect to happen?
```

```text
What actually happened?
```

```text
What is the type of that value?
```

```text
What does the final line of the error say?
```

```text
Can we reduce this to a smaller example?
```

```text
What responsibility does this function have?
```

```text
How could we test the failure case?
```

```text
What would happen if the list were empty?
```

Avoid immediately saying:

```text
The answer is...
```

Instead, guide learners toward discovering the answer.

---

# 15. Part 1 Delivery Checklist

Before moving to the next trainer-guide section, confirm that learners can:

- [ ] Open a terminal.
- [ ] Check Python.
- [ ] Create a project directory.
- [ ] Create a virtual environment.
- [ ] Run a Python file.
- [ ] Explain variables and basic types.
- [ ] Use f-strings.
- [ ] Convert input values.
- [ ] Read a basic traceback.
- [ ] Complete a small independent script.

---

# Trainer Guide Part 1 Complete

This section covered:

```text
Course design
Learning outcomes
Delivery formats
Session structure
Teaching principles
Trainer preparation
Learner prerequisites
Teaching challenges
Assessment methods
Trainer observation
```

The next section is:

# Trainer Guide Part 2: Teaching Modules 1 and 2

It will include:

- Lesson-by-lesson objectives.
- Demonstration plans.
- Guided exercises.
- Common misconceptions.
- Suggested assessment questions.
- Teaching notes for syntax and collections.

---

# Trainer Guide — Part 2: Teaching Modules 1 and 2

This section provides delivery guidance for:

```text
Module 1: Environment and Basic Syntax
Module 2: Structuring Data
```

It includes:

- Lesson objectives.
- Suggested timing.
- Demonstration plans.
- Common misconceptions.
- Guided activities.
- Assessment questions.
- Support strategies.

---

# Module 1: Environment and Basic Syntax

## Module Purpose

Module 1 gives learners a reliable environment and introduces Python's basic building blocks.

The focus is not on memorizing every syntax rule. The focus is on helping learners understand that programs:

```text
Receive values
    ↓
Store values
    ↓
Transform values
    ↓
Display results
```

---

# Module 1 Outcomes

By the end of the module, learners should be able to:

- Check their Python installation.
- Create a project directory.
- Create and activate a virtual environment.
- Run Python scripts.
- Use the interactive shell.
- Explain comments and indentation.
- Create variables.
- Identify basic data types.
- Perform arithmetic.
- Use f-strings.
- Convert values between types.
- Read basic user input.
- Explain a simple `TypeError`.

---

# Module 1 Suggested Schedule

| Lesson | Topic | Suggested time |
|---|---|---:|
| 1 | Python installation and terminal basics | 30–45 minutes |
| 2 | Virtual environments and project setup | 30–45 minutes |
| 3 | Running scripts and the interactive shell | 20–30 minutes |
| 4 | Comments and indentation | 20–30 minutes |
| 5 | Variables and basic data types | 45–60 minutes |
| 6 | Arithmetic and f-strings | 30–45 minutes |
| 7 | Input and type conversion | 30–45 minutes |
| 8 | Personal report project | 45–60 minutes |

Adjust the schedule according to learner experience.

---

# Lesson 1: Python and the Terminal

## Objective

Learners can:

- Open a terminal.
- Check their Python version.
- Identify the command used on their operating system.
- Move between directories.

## Key Explanation

Explain that Python is both:

- A programming language.
- A program that interprets Python code.

Introduce the terminal as a text-based way to interact with the operating system.

Use this analogy:

> The editor is where you write instructions. The terminal is where you ask the computer to execute them.

## Demonstration

Run:

```bash
python --version
```

If necessary:

```bash
python3 --version
```

On Windows, demonstrate:

```powershell
py --version
```

Then create a project directory:

```bash
mkdir python-foundations
cd python-foundations
```

Check the current directory:

```bash
pwd
```

On Windows PowerShell:

```powershell
Get-Location
```

## Guided Practice

Ask learners to:

1. Open a terminal.
2. Check their Python version.
3. Create `python-foundations`.
4. Enter the directory.
5. Record the path in the workbook.

## Common Problems

### `python` is not recognized

Ask learners to try:

```bash
python3 --version
```

or on Windows:

```powershell
py --version
```

### Learner is in the wrong directory

Use:

```bash
pwd
```

or:

```powershell
Get-Location
```

Explain that commands operate relative to the current directory.

## Checkpoint Questions

Ask:

```text
What is the terminal used for?
```

```text
How can you check which directory you are currently in?
```

```text
Which command starts Python on your computer?
```

---

# Lesson 2: Virtual Environments

## Objective

Learners can:

- Create a virtual environment.
- Activate it.
- Confirm activation.
- Deactivate it.

## Key Explanation

Use the toolbox analogy:

> A virtual environment is a separate toolbox for one project. Tools installed in one toolbox do not automatically interfere with another.

Explain that the course uses a virtual environment even though it initially relies on the standard library.

This establishes a professional habit early.

## Demonstration

Create the environment:

```bash
python -m venv .venv
```

Windows PowerShell activation:

```powershell
.venv\Scripts\Activate.ps1
```

macOS/Linux activation:

```bash
source .venv/bin/activate
```

Confirm the prompt begins with:

```text
(.venv)
```

Confirm the executable:

```bash
python -c "import sys; print(sys.executable)"
```

Deactivate:

```bash
deactivate
```

## Important Trainer Note

Do not assume activation looks identical in every terminal. The important verification is the executable path, not only the prompt.

## PowerShell Execution Policy

If learners receive a script-policy error:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then retry:

```powershell
.venv\Scripts\Activate.ps1
```

## Guided Practice

Ask learners to record:

```text
Python executable before activation:
____________________________________________________________

Python executable after activation:
____________________________________________________________
```

Discuss the difference.

## Checkpoint Questions

```text
Why should each project have an isolated environment?
```

```text
How can you verify that the environment is active?
```

```text
What command deactivates the environment?
```

---

# Lesson 3: Running Scripts and the Interactive Shell

## Objective

Learners can:

- Create a `.py` file.
- Run it from the terminal.
- Use the interactive shell for small experiments.

## Demonstration

Create `hello.py`:

```python
print("Hello, Python!")
print("This program is running.")
```

Run:

```bash
python hello.py
```

Then launch the shell:

```bash
python
```

Demonstrate:

```python
2 + 3
```

```python
print("Hello from the shell")
```

Exit:

```python
exit()
```

## Teaching Point

Explain the difference:

| File | Interactive shell |
|---|---|
| Saved for later | Temporary experimentation |
| Suitable for programs | Suitable for short expressions |
| Can be rerun | Useful for quick checks |
| Supports project structure | Not ideal for large programs |

## Guided Practice

Ask learners to:

- Create `hello.py`.
- Run it.
- Change the output.
- Test an arithmetic expression in the interactive shell.
- Exit and rerun the file.

## Common Misconception

Some learners believe the interactive shell saves their code automatically.

Clarify:

> The shell remembers commands during that session, but it does not automatically create a reusable `.py` file.

---

# Lesson 4: Comments and Indentation

## Objective

Learners can:

- Write comments.
- Explain why indentation matters.
- Recognize an indentation error.

## Demonstration

Valid code:

```python
# This line explains the program.
if True:
    print("Inside the block")
```

Deliberately break it:

```python
if True:
print("Missing indentation")
```

Run the code and inspect the error.

## Teaching Point

In many languages, braces define blocks. Python uses indentation.

Explain:

```text
The colon starts a block.
The indentation identifies the block's contents.
```

## Guided Practice

Ask learners to write:

```python
is_ready = True

if is_ready:
    print("Ready to start.")
```

Then ask them to add an `else` block:

```python
if is_ready:
    print("Ready to start.")
else:
    print("Not ready.")
```

## Common Problems

### Mixed tabs and spaces

Recommend using an editor configured to insert four spaces.

### Incorrect indentation level

Ask learners to compare the indentation of related lines visually.

## Checkpoint Questions

```text
What does the colon after if indicate?
```

```text
How many spaces should normally be used per indentation level?
```

```text
Why is indentation more than formatting in Python?
```

---

# Lesson 5: Variables and Basic Types

## Objective

Learners can:

- Assign values to variables.
- Use descriptive variable names.
- Identify strings, integers, floats, and Booleans.
- Inspect types.

## Demonstration

```python
name = "Ada"
age = 36
height = 1.65
is_learning = True
```

Display values:

```python
print(name)
print(age)
print(height)
print(is_learning)
```

Inspect types:

```python
print(type(name))
print(type(age))
print(type(height))
print(type(is_learning))
```

## Analogy

Use labeled containers:

- A variable is a label.
- The value is the item stored under the label.
- The type describes what kind of value it is.

## Important Distinction

Explain:

```python
age = 36
```

means assignment.

```python
age == 36
```

means comparison.

Learners often confuse these operators. Reinforce the difference repeatedly.

## Guided Practice

Ask learners to create:

```python
student_name = "________________"
lesson_number = ________________
completion_rate = ________________
is_ready = ________________
```

Then inspect each type.

## Common Misconceptions

### Dynamic typing means no types exist

Clarify:

> Python still has types. You simply do not need to declare the type before assigning a value.

### All numbers are the same

Explain the difference between:

```python
42
```

and:

```python
42.0
```

The first is an `int`; the second is a `float`.

---

# Lesson 6: Arithmetic and F-Strings

## Objective

Learners can:

- Use arithmetic operators.
- Store calculated results.
- Format values in readable output.
- Format decimal numbers.

## Demonstration

```python
price = 4.50
quantity = 3

total = price * quantity

print(f"Total: ${total:.2f}")
```

Explain:

```text
.2f
```

means two digits after the decimal point.

Demonstrate operators:

```python
print(5 + 2)
print(5 - 2)
print(5 * 2)
print(5 / 2)
print(5 // 2)
print(5 % 2)
print(5 ** 2)
```

## Teaching Point

The goal is not to memorize every operator immediately. Learners should understand that expressions produce values.

## Guided Exercise

Ask learners to build a rectangle calculator:

```python
width = 8
height = 5

area = width * height
perimeter = 2 * (width + height)

print(f"Area: {area}")
print(f"Perimeter: {perimeter}")
```

## Checkpoint Questions

```text
What does % return?
```

```text
What is the difference between / and //?
```

```text
What does :.2f do inside an f-string?
```

---

# Lesson 7: Input and Type Conversion

## Objective

Learners can:

- Read user input.
- Explain that `input()` returns a string.
- Convert input to integers or floats.
- Recognize a conversion failure.

## Demonstration

```python
age_text = input("How old are you? ")

print(type(age_text))
```

Even if the learner enters `36`, the type is:

```text
<class 'str'>
```

Convert it:

```python
age = int(age_text)

print(age + 1)
```

Demonstrate the failure:

```python
age = int("tomorrow")
```

Explain that safe handling will be introduced later.

## Guided Practice

Ask learners to create a price calculator:

```python
price = float(input("Price: "))
quantity = int(input("Quantity: "))

total = price * quantity

print(f"Total: ${total:.2f}")
```

## Trainer Note

Some learners will enter currency symbols:

```text
$4.50
```

This fails with `float()`.

Explain that the current program expects:

```text
4.50
```

Input formatting rules should be communicated clearly to users.

---

# Lesson 8: Personal Report Project

## Objective

Learners combine:

- Variables.
- Types.
- Arithmetic.
- F-strings.
- Output formatting.

## Demonstration

Use the complete personal report from the Student Workbook.

Ask learners to change:

- Name.
- Age.
- City.
- Height.
- Learning status.

## Assessment Opportunity

Ask each learner to explain:

```text
Which variable is a string?
Which variable is an integer?
Which variable is a float?
Which variable is a Boolean?
Which line performs arithmetic?
```

## Completion Criteria

The program should:

- Run without errors.
- Display all required fields.
- Use variables rather than hard-coded repeated text.
- Format the height or another decimal value.
- Produce readable output.

---

# Module 1 Common Misconceptions

## Misconception 1: `input()` Returns Numbers

Correction:

```python
input()
```

always returns text.

Use:

```python
int(input(...))
```

or:

```python
float(input(...))
```

when appropriate.

---

## Misconception 2: `=` Means Comparison

Correction:

```python
=
```

assigns.

```python
==
```

compares.

---

## Misconception 3: Indentation Is Optional

Correction:

> Indentation defines code blocks and is part of Python syntax.

---

## Misconception 4: A Type Error Means Python Is Broken

Correction:

> A type error usually means the program attempted an operation that does not make sense for the values provided.

---

# Module 1 Assessment

Ask learners to complete this independently:

Create a program that:

1. Asks for a name.
2. Asks for a number of study hours.
3. Converts the hours to minutes.
4. Displays a formatted report.
5. Handles the valid-input case correctly.

Expected design:

```python
name = input("Name: ")
hours = int(input("Study hours: "))

minutes = hours * 60

print(f"{name} studied for {minutes} minutes.")
```

For this stage, invalid-input handling is optional because exception handling is introduced later.

---

# Module 2: Structuring Data

## Module Purpose

Module 2 introduces collection types.

Learners move from storing individual values:

```python
name = "Ada"
age = 36
```

to storing groups of values:

```python
tasks = [
    "Learn Python",
    "Practice loops",
]
```

The module prepares learners to represent task records:

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

---

# Module 2 Outcomes

By the end of the module, learners should be able to:

- Create lists.
- Access list items.
- Modify lists.
- Slice lists.
- Sort lists.
- Create tuples.
- Explain tuple immutability.
- Create dictionaries.
- Update dictionary values.
- Use safe dictionary lookup.
- Create sets.
- Perform set operations.
- Store dictionaries in lists.
- Select a suitable collection type.

---

# Module 2 Suggested Schedule

| Lesson | Topic | Suggested time |
|---|---|---:|
| 1 | Lists and indexes | 45–60 minutes |
| 2 | List modification and slicing | 45–60 minutes |
| 3 | Tuples | 20–30 minutes |
| 4 | Dictionaries | 45–60 minutes |
| 5 | Sets | 30–45 minutes |
| 6 | Choosing collection types | 30–45 minutes |
| 7 | Task records | 45–60 minutes |

---

# Lesson 1: Lists and Indexes

## Objective

Learners can:

- Create a list.
- Access list items.
- Use positive and negative indexes.
- Explain that indexes begin at zero.

## Demonstration

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]
```

Display:

```python
print(tasks[0])
print(tasks[-1])
```

Draw the index map:

```text
Index:     0                 1                 2
Value:   Learn Python    Practice loops    Build a CLI tool
```

## Common Misconception

Learners often expect the first item to be at index `1`.

Repeat:

> Python uses zero-based indexing. The first position is `0`.

## Guided Exercise

Ask learners to create a list of five favorite foods and display:

- First item.
- Third item.
- Last item.

---

# Lesson 2: Modifying and Slicing Lists

## Objective

Learners can:

- Change list values.
- Add values.
- Remove values.
- Slice lists.
- Sort values.

## Demonstration

```python
tasks[1] = "Practice dictionaries"
tasks.append("Read documentation")
tasks.insert(1, "Practice conditions")
```

Remove values:

```python
tasks.remove("Read documentation")
removed = tasks.pop()
```

Slice:

```python
print(tasks[:2])
print(tasks[-2:])
```

Sort:

```python
tasks.sort()
```

## Teaching Point

Explain the difference between:

```python
tasks.sort()
```

and:

```python
sorted_tasks = sorted(tasks)
```

The first changes the original list. The second creates a new list.

## Common Problems

### Removing a value that does not exist

```python
tasks.remove("Missing task")
```

This raises a `ValueError`.

Use membership checking:

```python
if "Missing task" in tasks:
    tasks.remove("Missing task")
```

---

# Lesson 3: Tuples

## Objective

Learners can:

- Create a tuple.
- Access tuple values.
- Unpack a tuple.
- Explain immutability.

## Demonstration

```python
coordinates = (51.5074, -0.1278)

latitude, longitude = coordinates
```

Attempt to change it:

```python
coordinates[0] = 40.7128
```

Discuss the resulting `TypeError`.

## Analogy

Use a sealed record or fixed label:

> A tuple is appropriate when values form a group that should not be changed accidentally.

## Examples

```python
screen_size = (1920, 1080)
rgb_color = (255, 128, 0)
```

---

# Lesson 4: Dictionaries

## Objective

Learners can:

- Create dictionaries.
- Read values by key.
- Add and update keys.
- Use `.get()`.
- Loop through keys and values.

## Demonstration

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

Read:

```python
print(task["title"])
```

Update:

```python
task["completed"] = True
```

Add:

```python
task["priority"] = "high"
```

Safe lookup:

```python
priority = task.get("priority", "normal")
```

## Analogy

Use a labeled filing cabinet:

> A dictionary is useful when the labels matter more than numeric positions.

## Common Misconception

Learners may confuse:

```python
task["title"]
```

with:

```python
task[0]
```

Explain that dictionaries use keys, not list-style numeric positions.

---

# Lesson 5: Sets

## Objective

Learners can:

- Create sets.
- Add and remove values.
- Remove duplicates.
- Check membership.
- Perform basic set operations.

## Demonstration

```python
tags = {
    "python",
    "cli",
    "python",
}
```

Explain that duplicate values are retained only once.

Membership:

```python
if "python" in tags:
    print("Python tag exists.")
```

Operations:

```python
first = {"a", "b"}
second = {"b", "c"}

print(first | second)
print(first & second)
print(first - second)
```

## Important Note

Do not promise learners that set output is sorted or predictable.

Explain:

> Sets are designed for uniqueness and membership, not positional display order.

---

# Lesson 6: Choosing Collection Types

## Objective

Learners can select a collection based on requirements.

Use this decision table:

| Requirement | Collection |
|---|---|
| Ordered and changeable | List |
| Fixed ordered group | Tuple |
| Named fields | Dictionary |
| Unique values | Set |
| Multiple structured records | List of dictionaries |

## Trainer Exercise

Read each situation and ask learners to choose:

1. A shopping list.
2. A GPS coordinate.
3. A user profile.
4. Unique file extensions.
5. Multiple task records.

Expected answers:

```text
1. List
2. Tuple
3. Dictionary
4. Set
5. List of dictionaries
```

---

# Lesson 7: Task Records

## Objective

Learners can represent multiple tasks using a list of dictionaries.

## Demonstration

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

Access nested values:

```python
print(tasks[0]["title"])
```

Loop:

```python
for task in tasks:
    print(task["title"])
```

Display completion status:

```python
for task in tasks:
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['title']}")
```

## Key Teaching Point

This structure is not arbitrary. It reflects the requirements:

- Multiple tasks require a list.
- Named task fields require dictionaries.
- Completion requires a Boolean.
- IDs require integers.
- Titles require strings.

---

# Module 2 Common Misconceptions

## Misconception 1: Lists and Dictionaries Are Interchangeable

Correction:

- Lists are primarily sequences.
- Dictionaries are primarily key-value records.

---

## Misconception 2: Tuples Are Just Lists with Parentheses

Correction:

> Tuples are immutable, which communicates that their values should not change.

---

## Misconception 3: Sets Preserve a Meaningful Display Order

Correction:

> Sets are for uniqueness and membership. Use a list when order matters.

---

## Misconception 4: Dictionary Keys Can Be Duplicated

Dictionary keys must be unique.

```python
values = {
    "name": "Ada",
    "name": "Grace",
}
```

The second value replaces the first.

---

## Misconception 5: Nested Collections Are Always Complicated

Explain that nested collections reflect real data structures:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]
```

Break the structure down:

```text
Outer list → many tasks
Inner dictionary → one task
Dictionary fields → task properties
```

---

# Module 2 Assessment

Ask learners to build a product inventory:

```python
products = [
    {
        "name": "Notebook",
        "price": 4.50,
        "quantity": 10,
    },
    {
        "name": "Pen",
        "price": 1.25,
        "quantity": 25,
    },
]
```

They should:

1. Display each product.
2. Calculate each inventory value.
3. Display the total inventory value.
4. Add a third product.
5. Update a quantity.

Expected calculation:

```python
value = product["price"] * product["quantity"]
```

---

# Modules 1 and 2 Final Trainer Check

Before moving forward, confirm that learners can:

- [ ] Run Python reliably.
- [ ] Activate their environment.
- [ ] Write and execute a script.
- [ ] Explain variables and types.
- [ ] Convert input values.
- [ ] Use lists and indexes.
- [ ] Modify a list.
- [ ] Explain tuples.
- [ ] Use dictionaries.
- [ ] Use sets.
- [ ] Represent tasks as dictionaries.
- [ ] Store multiple tasks in a list.

---

# Trainer Guide Part 2 Complete

This section covered:

```text
Module 1: Environment and Basic Syntax
Module 2: Structuring Data
```

The next section is:

# Trainer Guide Part 3: Teaching Modules 3 and 4

It will include:

- Conditions and loops.
- Input validation.
- Functions.
- Modules.
- Files.
- JSON.
- Exceptions.
- Teaching the persistent task manager.

---

# Trainer Guide — Part 3: Teaching Modules 3 and 4

This section provides delivery guidance for:

```text
Module 3: Controlling Program Flow
Module 4: Reusable Code, Files, JSON, and Exceptions
```

It includes:

- Lesson objectives.
- Suggested timing.
- Demonstration plans.
- Common misconceptions.
- Guided exercises.
- Assessment activities.
- Teaching notes for the persistent task manager.

---

# Module 3: Controlling Program Flow

## Module Purpose

Module 3 teaches learners how programs make decisions and repeat work.

Learners move from linear scripts:

```python
print("First")
print("Second")
print("Third")
```

to programs that can:

- Choose between alternatives.
- Repeat operations.
- Respond to user input.
- Stop when a condition is met.
- Reject unexpected input.

---

# Module 3 Outcomes

By the end of the module, learners should be able to:

- Use comparison operators.
- Write `if`, `elif`, and `else` statements.
- Combine conditions with `and`, `or`, and `not`.
- Use membership checks.
- Write `for` loops.
- Use `range()`.
- Use `enumerate()`.
- Write `while` loops.
- Use `break` and `continue`.
- Validate required text.
- Validate numbers.
- Build an interactive menu-driven program.

---

# Module 3 Suggested Schedule

| Lesson | Topic | Suggested time |
|---|---|---:|
| 1 | Comparisons and conditions | 45–60 minutes |
| 2 | Logical operators and truthiness | 30–45 minutes |
| 3 | `for` loops and `range()` | 45–60 minutes |
| 4 | `enumerate()` and nested data | 30–45 minutes |
| 5 | `while` loops | 30–45 minutes |
| 6 | `break` and `continue` | 20–30 minutes |
| 7 | Input validation | 45–60 minutes |
| 8 | Interactive task manager | 60–90 minutes |

---

# Lesson 1: Comparisons and Conditions

## Objective

Learners can:

- Compare values.
- Use comparison results in conditions.
- Write `if`, `elif`, and `else`.

## Demonstration

Start with expressions:

```python
print(5 == 5)
print(5 != 3)
print(5 > 3)
print(5 < 3)
print(5 >= 5)
print(5 <= 4)
```

Ask learners to predict the output before running it.

Then demonstrate:

```python
age = 20

if age >= 18:
    print("You are an adult.")
else:
    print("You are not an adult.")
```

## Essential Distinction

Reinforce:

```python
age = 20
```

means assignment.

```python
age == 20
```

means comparison.

A useful verbal explanation is:

- `=` means “put this value into this variable.”
- `==` means “ask whether these values are equal.”

## Guided Exercise

Ask learners to write a temperature adviser:

```python
temperature = 25

if temperature > 30:
    print("Very hot.")
elif temperature >= 20:
    print("Comfortable.")
elif temperature >= 10:
    print("Cool.")
else:
    print("Cold.")
```

## Common Misconceptions

### `elif` conditions are all evaluated

Clarify that Python stops after the first matching branch.

### `else` requires a condition

Explain that `else` runs when all preceding conditions are false.

### Conditions must compare numbers

Show that strings can also be compared:

```python
command = "list"

if command == "list":
    print("Listing tasks.")
```

---

# Lesson 2: Logical Operators and Truthiness

## Objective

Learners can:

- Combine conditions.
- Use `and`, `or`, and `not`.
- Check membership.
- Recognize truthy and falsy values.

## Demonstration

```python
age = 25
has_ticket = True

if age >= 18 and has_ticket:
    print("Entry allowed.")
```

Then:

```python
day = "Saturday"

if day == "Saturday" or day == "Sunday":
    print("Weekend.")
```

Then:

```python
is_completed = False

if not is_completed:
    print("Task remains incomplete.")
```

## Truthiness Demonstration

```python
name = ""

if name:
    print("Name provided.")
else:
    print("Name missing.")
```

Explain that these are generally falsy:

```python
False
None
0
""
[]
{}
set()
```

## Input Example

```python
task_title = input("Task title: ").strip()

if not task_title:
    print("Task title cannot be empty.")
```

This is an important bridge to the capstone.

## Guided Exercise

Ask learners to validate a command:

```python
valid_commands = {
    "add",
    "list",
    "complete",
    "remove",
}

command = input("Command: ").strip().lower()

if command in valid_commands:
    print("Recognized command.")
else:
    print("Unknown command.")
```

## Trainer Note

Explain why `.strip().lower()` is useful:

```text
" LIST "
```

becomes:

```text
"list"
```

This makes input handling more forgiving.

---

# Lesson 3: `for` Loops and `range()`

## Objective

Learners can:

- Iterate through collections.
- Repeat a task for each item.
- Generate number sequences with `range()`.

## Demonstration

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI",
]

for task in tasks:
    print(task)
```

Explain the loop using plain language:

> For each item in `tasks`, temporarily call that item `task` and execute the indented code.

## `range()` Demonstration

```python
for number in range(5):
    print(number)
```

Emphasize that the endpoint is excluded.

```python
range(5)
```

produces:

```text
0, 1, 2, 3, 4
```

Other examples:

```python
range(1, 6)
range(0, 11, 2)
range(5, 0, -1)
```

## Guided Exercise

Ask learners to print a countdown:

```python
for number in range(5, 0, -1):
    print(number)

print("Finished!")
```

## Common Misconception

Learners may think `range(1, 5)` includes `5`.

Draw the sequence explicitly:

```text
start = 1
stop before = 5
values = 1, 2, 3, 4
```

---

# Lesson 4: `enumerate()` and Nested Data

## Objective

Learners can:

- Display item numbers.
- Loop through a list of dictionaries.
- Use nested dictionary values.

## Demonstration

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI",
]

for number, task in enumerate(tasks, start=1):
    print(f"{number}. {task}")
```

Then use task dictionaries:

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
    print(f"[{status}] {task['id']} - {task['title']}")
```

## Teaching Point

Break down:

```python
task["completed"]
```

as:

```text
task
    ↓
dictionary
    ↓
key "completed"
    ↓
Boolean value
```

## Guided Exercise

Ask learners to add:

- A third task.
- A priority field.
- A display of the priority.

---

# Lesson 5: `while` Loops

## Objective

Learners can:

- Repeat while a condition is true.
- Update loop state.
- Identify and prevent infinite loops.

## Demonstration

```python
count = 5

while count > 0:
    print(count)
    count -= 1

print("Finished!")
```

Emphasize that the loop condition must eventually become false.

## Deliberate Error

```python
count = 5

while count > 0:
    print(count)
```

Ask:

```text
Why does this not stop?
```

Expected answer:

> `count` never changes, so `count > 0` remains true.

## Interactive Menu

```python
while True:
    choice = input("Choose an option: ")

    if choice == "q":
        break

    print(f"You selected {choice}.")
```

Explain that:

```python
while True:
```

creates a loop that requires an internal exit.

---

# Lesson 6: `break` and `continue`

## Objective

Learners can:

- Exit a loop with `break`.
- Skip an iteration with `continue`.

## Demonstration: `break`

```python
while True:
    command = input("Command: ").strip()

    if command == "quit":
        break

    print(f"Running: {command}")
```

## Demonstration: `continue`

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

## Common Misconception

Learners may believe `continue` exits the entire loop.

Clarify:

- `break` exits the loop.
- `continue` skips the current iteration and proceeds to the next one.

---

# Lesson 7: Input Validation

## Objective

Learners can:

- Validate required text.
- Validate numeric input.
- Validate ranges.
- Repeatedly request input until valid.

## Required Text

```python
title = input("Task title: ").strip()

if not title:
    print("Task title cannot be empty.")
else:
    print(f"Accepted: {title}")
```

## Whole Numbers

```python
age_text = input("Age: ").strip()

if age_text.isdigit():
    age = int(age_text)
    print(age)
else:
    print("Please enter a whole number.")
```

Explain the limitation of `.isdigit()`:

- It accepts positive digit strings.
- It does not accept `-1`.
- It does not accept `3.14`.

This is a good opportunity to foreshadow exceptions.

## Repeated Validation

```python
while True:
    value = input("Enter an age: ").strip()

    if not value.isdigit():
        print("Please enter a whole number.")
        continue

    age = int(value)

    if age < 0 or age > 120:
        print("Enter an age from 0 to 120.")
        continue

    break
```

## Assessment Prompt

Ask learners:

> What should happen if a user enters `"tomorrow"` when the program expects a number?

Expected answer:

> The program should display a clear message and ask again rather than crashing.

---

# Lesson 8: Interactive Task Manager

## Objective

Learners combine:

- Lists.
- Dictionaries.
- Conditions.
- Loops.
- Input validation.
- Mutation.
- Menu design.

## Teaching Sequence

Do not present the entire program at once.

Build it incrementally.

### Step 1: Store Initial Tasks

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
]
```

### Step 2: Display Tasks

```python
for task in tasks:
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")
```

### Step 3: Add the Menu

```python
while True:
    print("1. List tasks")
    print("2. Add task")
    print("3. Complete task")
    print("4. Remove task")
    print("5. Quit")

    choice = input("Choose: ").strip()
```

### Step 4: Add One Branch at a Time

Start with list:

```python
if choice == "1":
    ...
```

Then add:

```python
elif choice == "2":
    ...
```

Continue until all branches are implemented.

## Trainer Note

This lesson is a natural place to demonstrate why large monolithic scripts become difficult to maintain. Do not refactor immediately if the learning goal is control flow. Explain that functions and modules will address the growing complexity in Module 4.

---

# Module 3 Common Misconceptions

## Misconception 1: `while True` Is Always Bad

Clarify that `while True` can be appropriate for interactive programs when a clear `break` condition exists.

---

## Misconception 2: `break` Only Works in `while` Loops

It works in both `for` and `while` loops.

---

## Misconception 3: `.isdigit()` Handles All Numbers

It does not handle:

```text
-1
3.14
```

Explain that exception-based conversion is more flexible.

---

## Misconception 4: A Loop Automatically Changes the Collection

A loop reads or processes items. It does not automatically modify the collection unless the code explicitly changes it.

---

# Module 3 Assessment

Ask learners to create a menu program with:

```text
1. Show a greeting
2. Count from 1 to 5
3. Validate a number
4. Quit
```

Requirements:

- Use a `while` loop.
- Use `if`/`elif`/`else`.
- Reject unknown commands.
- Continue until the user chooses quit.

Assessment criteria:

- Menu repeats.
- Correct branches run.
- Invalid choices are handled.
- Quit exits cleanly.
- Code is indented correctly.

---

# Module 4: Functions, Files, JSON, and Exceptions

## Module Purpose

Module 4 teaches learners how to move from one-file experiments to reusable and persistent applications.

The module introduces:

- Functions.
- Scope.
- Modules.
- Text files.
- `pathlib`.
- JSON.
- Exceptions.
- Persistent storage.

---

# Module 4 Outcomes

By the end of the module, learners should be able to:

- Define focused functions.
- Use parameters and return values.
- Explain local scope.
- Use the `main()` pattern.
- Import modules.
- Read and write text files.
- Use `pathlib`.
- Read and write JSON.
- Handle missing and malformed files.
- Build a persistent task manager.

---

# Module 4 Suggested Schedule

| Lesson | Topic | Suggested time |
|---|---|---:|
| 1 | Functions and parameters | 45–60 minutes |
| 2 | Return values and scope | 45–60 minutes |
| 3 | Modules and imports | 30–45 minutes |
| 4 | Text files and `pathlib` | 45–60 minutes |
| 5 | JSON | 30–45 minutes |
| 6 | Exceptions | 45–60 minutes |
| 7 | Storage separation | 30–45 minutes |
| 8 | Persistent task manager | 60–90 minutes |

---

# Lesson 1: Functions and Parameters

## Objective

Learners can:

- Define functions.
- Call functions.
- Use parameters.
- Explain arguments.

## Demonstration

```python
def greet(name):
    print(f"Hello, {name}!")


greet("Ada")
```

Explain:

```text
name → parameter
"Ada" → argument
```

## Guided Exercise

Ask learners to define:

```python
def display_task(task):
    print(task)
```

Then call it with:

```python
display_task("Learn Python")
```

---

# Lesson 2: Return Values and Scope

## Objective

Learners can:

- Return values.
- Reuse returned values.
- Explain local scope.
- Avoid unnecessary global state.

## Demonstration

```python
def calculate_total(price, quantity):
    return price * quantity


total = calculate_total(4.50, 3)
```

Contrast with printing inside the function:

```python
def print_total(price, quantity):
    print(price * quantity)
```

Explain that returning values gives the caller more flexibility.

## Scope Demonstration

```python
def create_message():
    message = "Hello"
    return message


message = create_message()
print(message)
```

Then show the failing version where `message` is not returned.

---

# Lesson 3: Modules and Imports

## Objective

Learners can:

- Create a reusable module.
- Import functions.
- Use `if __name__ == "__main__"`.

## Demonstration

`calculations.py`:

```python
def add(first, second):
    return first + second
```

`use_calculations.py`:

```python
from calculations import add

print(add(2, 3))
```

Explain that modules divide code by responsibility.

## Common Problems

### Running from the wrong directory

If a module cannot be imported, check:

```bash
pwd
```

or:

```powershell
Get-Location
```

### Incorrect filename or import name

The file:

```text
calculations.py
```

must be imported as:

```python
import calculations
```

---

# Lesson 4: Text Files and `pathlib`

## Objective

Learners can:

- Write text files.
- Read text files.
- Append text.
- Create directories.
- Build portable paths.

## Demonstration

```python
from pathlib import Path


file_path = Path("notes.txt")

file_path.write_text(
    "First note\n",
    encoding="utf-8",
)

contents = file_path.read_text(
    encoding="utf-8",
)

print(contents)
```

Explain why this is preferable to manually joining strings:

```python
Path("data") / "tasks.json"
```

## Guided Exercise

Ask learners to create a notes program that:

- Rejects empty notes.
- Appends notes.
- Displays all saved notes.

---

# Lesson 5: JSON

## Objective

Learners can:

- Explain JSON.
- Serialize Python data.
- Deserialize JSON data.
- Recognize JSON syntax differences.

## Demonstration

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

Then file operations:

```python
with open("tasks.json", "w", encoding="utf-8") as file:
    json.dump([task], file, indent=2)
```

Read:

```python
with open("tasks.json", "r", encoding="utf-8") as file:
    tasks = json.load(file)
```

## Common Misconceptions

### JSON is the same as Python

Explain that JSON uses:

```text
true
false
null
```

while Python uses:

```text
True
False
None
```

### Valid JSON means valid application data

A JSON object can be syntactically valid but still not be a valid task list.

---

# Lesson 6: Exceptions

## Objective

Learners can:

- Catch expected exceptions.
- Handle invalid input.
- Handle missing files.
- Handle malformed JSON.
- Use specific exceptions.

## Demonstration

```python
try:
    number = int(input("Number: "))
except ValueError:
    print("Invalid number.")
else:
    print(number)
```

Missing file:

```python
from pathlib import Path


try:
    contents = Path("missing.txt").read_text(
        encoding="utf-8",
    )
except FileNotFoundError:
    print("The file does not exist.")
```

Invalid JSON:

```python
import json

try:
    data = json.loads(text)
except json.JSONDecodeError:
    print("Invalid JSON.")
```

## Teaching Point

Use this rule:

> Catch an exception where the program knows how to respond meaningfully.

---

# Lesson 7: Separating Storage

## Objective

Learners can:

- Move file operations into a storage module.
- Keep application logic independent from file details.
- Explain separation of responsibilities.

## Demonstration

Instead of placing JSON code throughout the application:

```python
tasks = load_tasks(file_path)
save_tasks(file_path, tasks)
```

The application uses storage functions.

Explain the layers:

```text
User interface
    ↓
Application logic
    ↓
Storage
    ↓
JSON file
```

## Guided Exercise

Ask learners to create:

```text
task_storage.py
```

with:

```python
load_tasks()
save_tasks()
```

Then use those functions from another module.

---

# Lesson 8: Persistent Task Manager

## Objective

Learners combine all Module 4 concepts.

## Recommended Build Order

Build in this sequence:

1. Create `tasks.json` path.
2. Load missing data as an empty list.
3. Display loaded tasks.
4. Add a task.
5. Save the task.
6. Restart and verify persistence.
7. Complete a task.
8. Save again.
9. Remove a task.
10. Handle invalid IDs.
11. Handle malformed JSON.

## Trainer Strategy

Do not provide the final complete program immediately.

Use checkpoints:

```text
Checkpoint 1:
The application starts without a JSON file.

Checkpoint 2:
A task can be added.

Checkpoint 3:
The task appears in tasks.json.

Checkpoint 4:
The task remains after restarting.

Checkpoint 5:
The task can be completed.

Checkpoint 6:
The task can be removed.
```

Require learners to run a verification step after each checkpoint.

---

# Module 4 Common Misconceptions

## Misconception 1: `return` Displays a Value

Correction:

```python
return
```

sends a value back to the caller.

It does not display anything unless the caller prints it.

---

## Misconception 2: Exceptions Are Always Bad

Correction:

> Exceptions are a normal mechanism for reporting operations that cannot complete successfully.

The problem is not that an exception exists. The problem is failing to handle an expected one appropriately.

---

## Misconception 3: `json.load()` Reads a JSON String

Correction:

- `json.load()` reads from a file object.
- `json.loads()` reads from a string.

---

## Misconception 4: File Paths Are Always Relative to the Script

Correction:

> Relative paths are usually based on the current working directory, not automatically the script's directory.

This is why stable `pathlib` paths are important.

---

# Module 4 Assessment

Ask learners to create a persistent notes or task program that:

- Uses at least three functions.
- Saves data as JSON.
- Loads data when starting.
- Handles a missing file.
- Handles invalid numeric input.
- Displays a useful error message.
- Allows the user to add and list records.

Assessment criteria:

- Functions have focused responsibilities.
- Data persists between runs.
- Invalid input does not crash the program.
- JSON is valid.
- File paths are handled with `pathlib`.
- The learner can explain the code.

---

# Modules 3 and 4 Final Trainer Check

Before beginning the capstone, confirm that learners can:

- [ ] Write conditions.
- [ ] Use loops.
- [ ] Validate input.
- [ ] Explain `break` and `continue`.
- [ ] Define functions.
- [ ] Return values.
- [ ] Import modules.
- [ ] Read and write text files.
- [ ] Use `pathlib`.
- [ ] Read and write JSON.
- [ ] Handle expected exceptions.
- [ ] Build a persistent small application.

---

# Trainer Guide Part 3 Complete

This section covered:

```text
Module 3: Controlling Program Flow
Module 4: Functions, Files, JSON, and Exceptions
```

The next section is:

# Trainer Guide Part 4: Teaching the Capstone

It will include:

- Capstone sequencing.
- Architecture demonstrations.
- CLI teaching strategies.
- Task-management implementation.
- File-organizer implementation.
- Testing checkpoints.
- Instructor intervention guidance.

---

# Trainer Guide — Part 4: Teaching the Capstone

This section provides guidance for delivering the capstone project.

The capstone transforms the earlier task manager into a structured multi-utility command-line application.

The completed application supports:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
python -m foundation_cli organize downloads
```

This guide covers:

- Capstone sequencing.
- Architecture demonstrations.
- CLI teaching strategies.
- Task implementation.
- File organizer implementation.
- Testing checkpoints.
- Instructor intervention.

---

# 1. Capstone Purpose

The capstone gives learners an opportunity to combine all foundational concepts.

It should not be presented as a large block of advanced code.

Instead, explain that the project is built through layers:

```text
Project structure
        ↓
Command-line parser
        ↓
Task logic
        ↓
JSON storage
        ↓
File organizer
        ↓
Automated tests
        ↓
Final verification
```

Each layer should be implemented and verified before the next one is introduced.

---

# 2. Capstone Outcomes

By the end of the capstone, learners should be able to:

- Organize a Python project.
- Create a package.
- Use `pyproject.toml`.
- Run a package with `python -m`.
- Parse command-line arguments.
- Implement subcommands.
- Separate CLI, application, storage, and file-system logic.
- Store tasks in JSON.
- Handle expected errors.
- Organize files by extension.
- Protect duplicate files from being overwritten.
- Use dry-run mode.
- Write automated tests.
- Explain the application architecture.

---

# 3. Recommended Capstone Schedule

| Section | Focus | Suggested time |
|---|---|---:|
| 5A | Project structure and CLI | 60–90 minutes |
| 5B | Task logic and storage | 60–90 minutes |
| 5C | Task commands and errors | 60–90 minutes |
| 5D | File organizer | 60–90 minutes |
| 5E | Automated tests | 60–90 minutes |
| Final | Verification and presentation | 45–60 minutes |

For beginners, allow additional time for setup and debugging.

---

# 4. Capstone Teaching Sequence

## Stage 1: Create the Project Layout

The initial structure should be:

```text
python-foundations/
├── README.md
├── pyproject.toml
├── data/
├── src/
│   └── foundation_cli/
└── tests/
```

Explain each part:

| Location | Purpose |
|---|---|
| `src/foundation_cli/` | Application code |
| `data/` | Persistent task data |
| `tests/` | Automated tests |
| `README.md` | Project documentation |
| `pyproject.toml` | Project configuration |

## Trainer Demonstration

Draw the structure on a whiteboard before learners create it.

Explain:

> We are not adding folders merely to look professional. Each location represents a different responsibility.

---

# 5. Stage 2: Create the Package

Create:

```text
src/foundation_cli/__init__.py
```

Use:

```python
"""Foundation CLI application."""

__version__ = "0.1.0"
```

Create:

```text
src/foundation_cli/__main__.py
```

Use:

```python
from .cli import main


if __name__ == "__main__":
    main()
```

Demonstrate:

```bash
python -m foundation_cli
```

## Teaching Point

Explain the difference between:

```bash
python script.py
```

and:

```bash
python -m package
```

The first runs a file directly.

The second runs a package's module entry point.

---

# 6. Stage 3: Create `pyproject.toml`

Use the project configuration from the Student Workbook.

After creating it, install the project:

```bash
python -m pip install --editable .
```

## Verification

Run:

```bash
python -m foundation_cli --help
```

Do not move forward until every learner can run this command.

## Common Problems

### `ModuleNotFoundError`

Check:

```bash
python -m pip install --editable .
```

Then confirm the virtual environment:

```bash
python -c "import sys; print(sys.executable)"
```

### Running from the Wrong Directory

The install command should be run from the project root containing:

```text
pyproject.toml
```

---

# 7. Stage 4: Build the CLI Parser

The CLI should initially support:

```text
add
list
complete
remove
stats
organize
```

Use `argparse`.

## Teaching Strategy

Build one parser at a time.

Start with:

```python
parser = argparse.ArgumentParser(
    prog="foundation",
)
```

Then add:

```python
subparsers = parser.add_subparsers(
    dest="command",
)
```

Then add the `add` command:

```python
add_parser = subparsers.add_parser("add")
add_parser.add_argument("title")
```

Run:

```bash
python -m foundation_cli add "Learn Python"
```

Inspect:

```python
print(arguments)
```

Show learners the parsed result:

```text
Namespace(command='add', title='Learn Python')
```

## Teaching Point

Explain that `argparse` converts raw terminal text into structured data.

```text
Terminal command
        ↓
Argument parser
        ↓
Namespace object
```

---

# 8. CLI Checkpoint

Before implementing task behavior, learners should be able to:

```bash
python -m foundation_cli --help
python -m foundation_cli --version
python -m foundation_cli add "Test"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
python -m foundation_cli organize downloads
```

At this stage, placeholder output is acceptable.

The goal is to verify argument parsing before adding application logic.

---

# 9. Stage 5: Implement Task Logic

Create:

```text
src/foundation_cli/tasks.py
```

The task layer should contain functions such as:

```python
create_task()
get_next_id()
find_task()
complete_task()
remove_task()
count_completed()
count_incomplete()
```

## Teaching Point

The task layer should not know:

- How commands are typed.
- Where JSON files are located.
- How output is formatted.
- How file organization works.

It should focus on task rules.

## Demonstration

```python
tasks = []

task = create_task(
    tasks,
    "Learn Python",
)

print(task)
```

Expected:

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

---

# 10. Explain Application Logic Versus CLI Logic

Compare:

```python
def create_task(tasks, title):
    ...
```

with:

```python
def handle_add(title):
    ...
```

The first function contains task rules.

The second function coordinates:

1. Loading data.
2. Calling task logic.
3. Saving data.
4. Displaying output.

Use this diagram:

```text
handle_add()
    ├── load_tasks()
    ├── create_task()
    ├── save_tasks()
    └── print result
```

This is a useful point to discuss separation of responsibilities.

---

# 11. Stage 6: Implement JSON Storage

Create:

```text
src/foundation_cli/storage.py
```

The storage layer should contain:

```python
load_tasks()
save_tasks()
validate_task()
```

## Demonstration

Show the data flow:

```text
data/tasks.json
        ↓
load_tasks()
        ↓
Python list of dictionaries
        ↓
application logic
        ↓
save_tasks()
        ↓
data/tasks.json
```

## Important Teaching Point

The task layer should not open JSON files directly.

This keeps the application easier to change.

For example, if JSON is eventually replaced by a database, the task logic should require minimal changes.

---

# 12. Stage 7: Connect `add` and `list`

Implement:

```python
handle_add()
handle_list()
```

Then verify:

```bash
python -m foundation_cli add "Learn Python"
```

```bash
python -m foundation_cli list
```

## Required Checkpoint

Learners must verify:

1. A task can be added.
2. `data/tasks.json` is created.
3. The task appears in the JSON.
4. The task appears in `list`.
5. The task remains after restarting the command.

Do not proceed until persistence works.

---

# 13. Stage 8: Add Custom Exceptions

Create:

```text
src/foundation_cli/errors.py
```

Define:

```python
class FoundationError(Exception):
    """Base application error."""


class TaskNotFoundError(FoundationError):
    """Raised when a task does not exist."""


class TaskAlreadyCompletedError(FoundationError):
    """Raised when a task is already completed."""


class InvalidTaskTitleError(FoundationError):
    """Raised when a title is invalid."""
```

## Teaching Point

Explain why this is better than raising generic exceptions everywhere.

Custom exception names communicate meaning:

```python
raise TaskNotFoundError(
    f"No task found with ID {task_id}."
)
```

The CLI can catch all expected application errors:

```python
except FoundationError as error:
    print(f"Error: {error}")
```

---

# 14. Stage 9: Implement `complete`, `remove`, and `stats`

Build in this order:

## Complete

```bash
python -m foundation_cli complete 1
```

Verify:

```bash
python -m foundation_cli list
```

Expected:

```text
[x] 1 - Learn Python
```

## Remove

```bash
python -m foundation_cli remove 1
```

Verify:

```bash
python -m foundation_cli list
```

## Statistics

```bash
python -m foundation_cli stats
```

Expected:

```text
Total tasks: 2
Completed tasks: 1
Incomplete tasks: 1
```

---

# 15. Error Demonstrations

Demonstrate these commands:

```bash
python -m foundation_cli complete 999
```

Expected:

```text
Error: No task found with ID 999.
```

```bash
python -m foundation_cli add ""
```

Expected:

```text
Error: Task title cannot be empty.
```

```bash
python -m foundation_cli complete abc
```

Expected argument validation error.

Ask learners:

```text
Which errors are handled by argparse?
Which errors are handled by task logic?
Which errors are handled by storage?
```

---

# 16. Stage 10: Build the File Organizer

Explain that the organizer is a separate utility with a separate responsibility.

Create:

```text
src/foundation_cli/organizer.py
```

The organizer should:

- Inspect a directory.
- Skip subdirectories.
- Determine extensions.
- Plan moves.
- Create folders.
- Move files.
- Avoid overwrites.
- Support dry-run mode.

## Important Safety Principle

Always demonstrate on a temporary directory.

Do not use a learner's real downloads folder during initial testing.

---

# 17. File Organizer Demonstration

Create:

```text
organizer_demo/
├── report.pdf
├── photo.jpg
├── notes.txt
└── README
```

First run:

```bash
python -m foundation_cli organize organizer_demo --dry-run
```

Ask learners to confirm that no files moved.

Then run:

```bash
python -m foundation_cli organize organizer_demo
```

Inspect the result.

## Teaching Point

The dry run is not decorative. It is a safety mechanism.

Use the phrase:

> Preview first, modify second.

---

# 18. Duplicate File Demonstration

Create a duplicate file:

```text
organizer_demo/photo.jpg
```

Run the organizer again.

The original destination should remain:

```text
jpg/photo.jpg
```

The new file should become:

```text
jpg/photo_1.jpg
```

Ask learners:

```text
What would be dangerous about overwriting the existing file?
```

---

# 19. Stage 11: Automated Testing

Introduce tests after the main functionality works.

Explain that tests are not a replacement for understanding. They are a repeatable verification tool.

Recommended test files:

```text
tests/
├── test_tasks.py
├── test_storage.py
└── test_organizer.py
```

## Testing Task Logic

Test:

- Creating a task.
- Rejecting empty titles.
- Finding a task.
- Completing a task.
- Rejecting duplicate completion.
- Removing a task.
- Counting statuses.

## Testing Storage

Test:

- Missing files.
- Saving and loading.
- Invalid JSON.
- Wrong data structures.
- Invalid task fields.

## Testing Organizer

Test:

- Extension folders.
- No-extension files.
- Dry-run behavior.
- Actual moves.
- Duplicate names.
- Missing directories.

---

# 20. Use Temporary Directories in Tests

Explain why this is unsafe:

```python
file_path = Path("data/tasks.json")
```

inside tests.

It changes real project data.

Use:

```python
with tempfile.TemporaryDirectory() as directory:
    file_path = Path(directory) / "tasks.json"
```

This provides isolated test data.

---

# 21. Testing Checkpoint

Run:

```bash
python -m unittest discover -s tests -v
```

Do not accept only a general statement that tests pass.

Ask learners to identify:

- Number of tests.
- Test file names.
- Any skipped tests.
- Any failures.
- The final result.

Expected ending:

```text
OK
```

---

# 22. Handling Test Failures

When a test fails, ask the learner to:

1. Read the test name.
2. Identify the assertion.
3. Find the source function.
4. Reproduce the issue manually.
5. Inspect the values.
6. Fix one thing.
7. Run the tests again.

Do not immediately provide the corrected code.

Use guiding questions:

```text
What did the test expect?
What did it receive?
Which function produced that value?
```

---

# 23. Capstone Milestones

Use these milestones to track progress.

## Milestone 1: Package Runs

```bash
python -m foundation_cli --help
```

## Milestone 2: CLI Commands Parse

All subcommands appear in help and accept expected arguments.

## Milestone 3: Tasks Persist

```bash
python -m foundation_cli add "Test"
python -m foundation_cli list
```

The task remains after restarting.

## Milestone 4: Task Commands Work

```bash
complete
remove
stats
```

## Milestone 5: Errors Are Friendly

Expected failures do not display unnecessary tracebacks.

## Milestone 6: Organizer Works Safely

Dry-run, actual moves, and duplicate protection work.

## Milestone 7: Tests Pass

```bash
python -m unittest discover -s tests -v
```

## Milestone 8: Learner Can Explain the Architecture

The learner can describe each module's responsibility.

---

# 24. Trainer Intervention Levels

## Level 1: Ask a Question

Use when the learner is close to the solution:

```text
What type is this value?
```

```text
Which function should own this rule?
```

```text
What does the traceback say?
```

---

## Level 2: Point to the Relevant Concept

Use when the learner needs direction:

```text
This looks like the dictionary lookup problem we discussed.
```

```text
Check how the path is constructed.
```

```text
Compare the stored ID type with the command-line ID type.
```

---

## Level 3: Show a Smaller Example

Use when the full project is overwhelming:

```python
task = {"id": 1}
task_id = "1"

print(task["id"] == task_id)
```

Ask the learner to identify the problem.

---

## Level 4: Provide a Partial Template

Give the function signature or control structure, but let the learner complete the body.

---

## Level 5: Provide the Complete Fix

Use only after the learner has attempted to investigate and can explain the correction.

---

# 25. Capstone Presentation Activity

At the end of the capstone, each learner should present:

1. The project structure.
2. One task command.
3. The organizer dry run.
4. The automated test command.
5. One design decision.
6. One problem they solved.

Suggested presentation format:

```text
My project is called:
____________________________________________________________

It solves this problem:
____________________________________________________________

The main commands are:
____________________________________________________________

The most important module is:
____________________________________________________________

One error I solved was:
____________________________________________________________

One future improvement is:
____________________________________________________________
```

---

# 26. Capstone Completion Criteria

A learner completes the capstone when:

- [ ] The package runs.
- [ ] Help works.
- [ ] Version works.
- [ ] Tasks can be added.
- [ ] Tasks can be listed.
- [ ] Tasks can be completed.
- [ ] Tasks can be removed.
- [ ] Statistics are accurate.
- [ ] Tasks persist in JSON.
- [ ] Invalid input is handled.
- [ ] The organizer supports dry runs.
- [ ] Duplicate files are protected.
- [ ] Missing directories are handled.
- [ ] Automated tests pass.
- [ ] The learner can explain the architecture.

---

# Trainer Guide Part 4 Complete

This section covered:

```text
Capstone sequencing
Project architecture
CLI construction
Task logic
JSON storage
Custom errors
File organization
Testing
Milestones
Trainer intervention
Presentation
```

The next section is:

# Trainer Guide Part 5: Assessment, Troubleshooting, and Extensions

It will include:

- Assessment rubrics.
- Practical evaluation.
- Troubleshooting procedures.
- Learner support.
- Extension projects.
- Final instructor checklist.

---

# Trainer Guide — Part 5: Assessment, Troubleshooting, and Extensions

This is the final section of the Trainer Guide.

It includes:

- Assessment rubrics.
- Practical evaluation.
- Troubleshooting procedures.
- Learner support strategies.
- Extension projects.
- Final instructor checklist.

---

# 1. Assessment Philosophy

Assessment should measure more than whether the final program runs.

A learner may copy a working program without understanding:

- Why a list is used.
- Why a function returns a value.
- Why JSON is stored separately.
- Why exceptions are handled.
- Why tests use temporary directories.

Assess both:

1. **Implementation**
2. **Understanding**

A strong learner should be able to explain the program, modify it, and debug it.

---

# 2. Suggested Assessment Structure

| Area | Weight |
|---|---:|
| Environment and basic syntax | 15% |
| Collections and control flow | 20% |
| Functions, files, JSON, and exceptions | 20% |
| Capstone functionality | 30% |
| Testing, debugging, and explanation | 15% |
| **Total** | **100%** |

Adjust the weighting for your course format.

---

# 3. Assessment Rubric

## A. Environment and Basic Syntax — 15 Points

| Performance | Points |
|---|---:|
| Checks Python version and uses the correct command | 2 |
| Creates and activates a virtual environment | 3 |
| Runs Python files successfully | 2 |
| Uses variables and basic data types correctly | 3 |
| Uses arithmetic and f-strings | 2 |
| Converts input values appropriately | 2 |
| Explains a basic type error | 1 |

---

## B. Collections and Control Flow — 20 Points

| Performance | Points |
|---|---:|
| Uses lists appropriately | 3 |
| Uses dictionaries for structured records | 3 |
| Explains tuples and sets | 2 |
| Uses conditions correctly | 3 |
| Uses `for` loops | 2 |
| Uses `while` loops | 2 |
| Uses `break` and `continue` appropriately | 2 |
| Validates input | 3 |

---

## C. Functions, Files, JSON, and Exceptions — 20 Points

| Performance | Points |
|---|---:|
| Defines focused functions | 3 |
| Uses parameters and return values | 3 |
| Uses type hints appropriately | 2 |
| Separates code into modules | 2 |
| Reads and writes files | 2 |
| Uses `pathlib` | 2 |
| Reads and writes JSON | 3 |
| Handles expected exceptions | 3 |

---

## D. Capstone Functionality — 30 Points

| Performance | Points |
|---|---:|
| Creates a working project structure | 3 |
| CLI help and version work | 3 |
| Adds tasks | 4 |
| Lists tasks | 3 |
| Completes tasks | 3 |
| Removes tasks | 3 |
| Displays statistics | 2 |
| Persists tasks in JSON | 3 |
| Organizes files | 3 |
| Supports dry-run and duplicate protection | 3 |

---

## E. Testing, Debugging, and Explanation — 15 Points

| Performance | Points |
|---|---:|
| Writes meaningful automated tests | 3 |
| Tests success cases | 2 |
| Tests failure cases | 2 |
| Uses temporary directories for file tests | 2 |
| Reads and explains tracebacks | 2 |
| Can explain the architecture | 2 |
| Can describe a future improvement | 2 |

---

# 4. Practical Final Assessment

Give learners the following task:

> Add a new `edit` command that changes the title of an existing task.

The learner should:

1. Add an `edit` subcommand to `argparse`.
2. Accept a task ID and new title.
3. Validate the task ID.
4. Reject an empty title.
5. Find the task.
6. Update the title.
7. Save the updated list.
8. Display a confirmation.
9. Handle a missing task.
10. Add automated tests.

Expected command:

```bash
python -m foundation_cli edit 1 "Updated title"
```

Expected output:

```text
Task updated:
  ID: 1
  Title: Updated title
```

This assessment tests whether learners understand the existing architecture rather than merely reproducing earlier code.

---

# 5. Practical Assessment Rubric

## Excellent

The learner:

- Implements the feature independently.
- Places logic in appropriate modules.
- Validates input.
- Handles expected errors.
- Adds tests.
- Explains each design choice.
- Verifies both success and failure cases.

## Competent

The learner:

- Implements the feature with limited guidance.
- Produces working behavior.
- Handles most expected errors.
- Adds at least one test.
- Can explain the main changes.

## Developing

The learner:

- Requires substantial support.
- Implements only part of the feature.
- Has limited validation.
- Tests only the successful case.
- Needs help explaining the architecture.

## Beginning

The learner:

- Cannot yet connect the CLI to application logic.
- Has difficulty modifying existing modules.
- Does not test changes.
- Requires step-by-step assistance.

---

# 6. Troubleshooting Workflow for Trainers

When a learner reports:

```text
It does not work.
```

Ask the following questions:

1. What command did you run?
2. What did you expect?
3. What actually happened?
4. Was there an error message?
5. What is the final line of the traceback?
6. What file and line number are identified?
7. What are the relevant values?
8. What are their types?
9. Are you in the correct directory?
10. Is the virtual environment active?
11. Can you reproduce the problem with fewer lines?

This encourages diagnostic thinking rather than dependency on the trainer.

---

# 7. Common Setup Problems

## Python Is Not Found

Try:

```bash
python3 --version
```

On Windows:

```powershell
py --version
```

If none work, Python may not be installed or may not be on the system path.

---

## Virtual Environment Does Not Activate

Check whether `.venv` exists.

### Windows PowerShell

```powershell
Get-ChildItem .venv
```

### macOS/Linux

```bash
ls .venv
```

Recreate it if necessary:

```bash
python -m venv .venv
```

---

## PowerShell Blocks Activation

Run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then:

```powershell
.venv\Scripts\Activate.ps1
```

---

## Package Cannot Be Imported

Confirm that the project is installed:

```bash
python -m pip install --editable .
```

Confirm the active executable:

```bash
python -c "import sys; print(sys.executable)"
```

Try:

```bash
python -m foundation_cli --help
```

---

# 8. Common Application Problems

## Tasks Disappear

Check:

- Is `save_tasks()` being called?
- Is the correct `data/tasks.json` being used?
- Is the save operation failing?
- Is the program being run from the expected project?
- Does the JSON file contain the new task?

Inspect:

```bash
python -m json.tool data/tasks.json
```

---

## Task ID Is Not Found

Check:

- Is the command-line ID an integer?
- Are stored IDs integers?
- Does the task actually exist?
- Is the correct data file loaded?
- Are IDs being regenerated incorrectly?

Use:

```python
print(repr(task_id), type(task_id))
print(repr(tasks))
```

---

## Empty Titles Are Accepted

Check that the code uses:

```python
cleaned_title = title.strip()

if not cleaned_title:
    ...
```

Do not only check:

```python
if title == "":
```

because whitespace-only values are not technically empty until stripped.

---

## Organizer Moves the Wrong Files

Check:

- Is the correct directory being used?
- Does `plan_moves()` skip directories?
- Is the extension normalized?
- Are destination folders inside the source directory?
- Is a file being processed more than once?

Run dry-run mode:

```bash
python -m foundation_cli organize folder --dry-run
```

---

## Organizer Overwrites a File

Check:

```python
unique_destination(destination)
```

Make sure the destination is passed through the duplicate-protection function before moving.

---

## Tests Modify Real Data

Use:

```python
tempfile.TemporaryDirectory()
```

Do not use the production data file directly in tests.

---

# 9. Debugging a Failing Test

Use this process:

```text
1. Read the failing test name.
2. Read the assertion.
3. Identify the expected value.
4. Identify the actual value.
5. Find the function under test.
6. Reproduce the input manually.
7. Inspect types and values.
8. Fix one issue.
9. Run the test again.
```

Ask the learner:

```text
What did the test expect?
What did it receive?
Which function produced the result?
```

---

# 10. Learner Support Levels

## Level 1: Prompt

Ask a question:

```text
What type is the task ID?
```

## Level 2: Hint

Point to the relevant concept:

```text
This may be related to input conversion.
```

## Level 3: Small Example

Reduce the problem:

```python
stored_id = 1
entered_id = "1"

print(stored_id == entered_id)
```

## Level 4: Partial Code

Provide a function signature:

```python
def edit_task(tasks, task_id, new_title):
    ...
```

Let the learner complete the body.

## Level 5: Full Demonstration

Provide the solution only after the learner has attempted diagnosis and can explain the correction.

---

# 11. Extension Challenges

After the capstone works, offer optional improvements.

## Extension 1: Edit Tasks

Add:

```bash
python -m foundation_cli edit 1 "New title"
```

Requirements:

- Validate the ID.
- Validate the title.
- Update the task.
- Save the JSON.
- Add tests.

---

## Extension 2: Task Priorities

Add:

```json
{
  "id": 1,
  "title": "Learn Python",
  "completed": false,
  "priority": "high"
}
```

Add a command option:

```bash
python -m foundation_cli add "Learn Python" --priority high
```

---

## Extension 3: Filter Tasks

Add:

```bash
python -m foundation_cli list --completed
python -m foundation_cli list --incomplete
```

---

## Extension 4: Search Tasks

Add:

```bash
python -m foundation_cli search Python
```

Display tasks whose titles contain the search text.

---

## Extension 5: Clear Completed Tasks

Add:

```bash
python -m foundation_cli clear-completed
```

Ask learners to consider:

- Confirmation prompts.
- Undo behavior.
- Tests.
- Empty results.

---

## Extension 6: Export to CSV

Use Python's `csv` module:

```python
import csv
```

Export:

```text
id,title,completed
1,Learn Python,false
```

---

## Extension 7: Logging

Add logging for:

- Application startup.
- Task creation.
- Task completion.
- File moves.
- Storage errors.

---

## Extension 8: Configuration

Allow users to choose the data file through:

- A command-line option.
- An environment variable.
- A configuration file.

---

## Extension 9: Database Storage

Replace JSON with SQLite.

Discuss:

- What should remain unchanged?
- Which storage functions need replacement?
- Why separation of responsibilities helps.

---

## Extension 10: Continuous Integration

Configure a service to run:

```bash
python -m unittest discover -s tests -v
```

whenever code is pushed to a repository.

---

# 12. Code Review Checklist

Use this checklist for learner projects.

## Structure

- [ ] Application code is under `src/`.
- [ ] Tests are under `tests/`.
- [ ] Data is separate from source code.
- [ ] The package has `__init__.py`.
- [ ] The package has `__main__.py`.
- [ ] `pyproject.toml` exists.

## Naming

- [ ] Variables use clear names.
- [ ] Functions use `snake_case`.
- [ ] Classes use `PascalCase`.
- [ ] Constants use uppercase names.

## Functions

- [ ] Functions have focused responsibilities.
- [ ] Parameters are meaningful.
- [ ] Return values are used appropriately.
- [ ] Type hints are present where useful.
- [ ] Functions do not rely unnecessarily on global state.

## Errors

- [ ] Expected input errors are handled.
- [ ] Missing files are handled.
- [ ] Invalid JSON is handled.
- [ ] Error messages are understandable.
- [ ] Broad exception handling is avoided.

## Files

- [ ] Paths use `pathlib`.
- [ ] Files use context managers or `Path` methods.
- [ ] Organizer has dry-run behavior.
- [ ] Existing files are protected from overwriting.

## Tests

- [ ] Success cases are tested.
- [ ] Failure cases are tested.
- [ ] Temporary directories are used for file tests.
- [ ] Tests are repeatable.
- [ ] The full suite passes.

---

# 13. Final Instructor Checklist

Before closing the course, confirm that:

## Course Delivery

- [ ] Every module was introduced progressively.
- [ ] Learners ran examples themselves.
- [ ] Learners completed independent exercises.
- [ ] Learners practiced reading errors.
- [ ] Verification steps were not skipped.

## Environment

- [ ] Learners can activate their environments.
- [ ] Learners can run the project.
- [ ] Learners know how to check Python versions.
- [ ] Learners understand the project directory.

## Fundamentals

- [ ] Learners can use variables and data types.
- [ ] Learners can choose collections.
- [ ] Learners can write conditions and loops.
- [ ] Learners can define functions.
- [ ] Learners can read and write files.
- [ ] Learners can work with JSON.
- [ ] Learners can handle exceptions.

## Capstone

- [ ] The package runs.
- [ ] CLI help works.
- [ ] Tasks persist.
- [ ] Task commands work.
- [ ] The organizer works.
- [ ] Dry-run mode works.
- [ ] Duplicate protection works.
- [ ] Automated tests pass.
- [ ] Learners can explain the architecture.

## Assessment

- [ ] Practical assessment completed.
- [ ] Learner project reviewed.
- [ ] Learner explained at least one design decision.
- [ ] Learner demonstrated debugging.
- [ ] Learner identified a future improvement.

---

# 14. Final Trainer Reflection

After delivering the course, record:

## What Worked Well?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## Which Concepts Caused Difficulty?

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

## Which Exercises Should Be Improved?

```text
____________________________________________________________

____________________________________________________________
```

## Where Did Learners Need More Time?

```text
____________________________________________________________

____________________________________________________________
```

## What Should Be Added or Removed?

```text
____________________________________________________________

____________________________________________________________
```

---

# Trainer Guide Complete

The complete Trainer Guide now includes:

```text
Part 1: Course Design and Delivery
Part 2: Teaching Modules 1 and 2
Part 3: Teaching Modules 3 and 4
Part 4: Teaching the Capstone
Part 5: Assessment, Troubleshooting, and Extensions
```

The instructor's central role is to help learners develop a repeatable process:

```text
Understand the requirement
        ↓
Choose the data structure
        ↓
Write a small piece
        ↓
Run it
        ↓
Read the result
        ↓
Handle errors
        ↓
Test the behavior
        ↓
Improve the design
```

The course is successful when learners can independently turn a simple requirement into a working, testable Python program.
