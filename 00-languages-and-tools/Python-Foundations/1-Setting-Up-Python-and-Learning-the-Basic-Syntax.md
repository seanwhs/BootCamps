# Part 1: Setting Up Python and Learning the Basic Syntax

Welcome to the first technical part of **Python Foundations: From Zero to Functional Code**.

In this part, you will:

- Check whether Python is installed.
- Understand the `python` and `py` commands.
- Create a project directory.
- Create and activate a virtual environment.
- Write and run your first Python program.
- Learn about comments and indentation.
- Create variables.
- Work with strings, integers, floats, and Booleans.
- Convert values between types.
- Build a small Python report program.
- Verify that everything works.

By the end, you will be able to create, run, and modify a basic Python script.

---

## 1. Checking Your Python Installation

Python programs need an interpreter to run.

An **interpreter** is a program that reads your Python code and executes it.

Open a terminal.

### Windows PowerShell or Command Prompt

Try:

```bash
python --version
```

If that does not work, try:

```bash
py --version
```

### macOS or Linux

Try:

```bash
python3 --version
```

You should see output similar to:

```text
Python 3.12.4
```

The exact version may be different. Python 3.10 or newer is recommended for this series.

Do not use Python 2. Python 2 is obsolete and is not compatible with the code in this series.

---

## 2. Understanding `python`, `python3`, and `py`

Different operating systems commonly use different commands to start Python.

| Command | Common usage |
|---|---|
| `python` | Windows, some macOS and Linux systems |
| `python3` | macOS and many Linux systems |
| `py` | Windows Python launcher |

For the rest of this series, commands will usually use:

```bash
python
```

If your system requires `python3`, substitute it:

```bash
python3 script.py
```

On Windows, you can often use:

```bash
py script.py
```

The important idea is that these commands start Python. The correct command depends on how Python was installed on your computer.

---

## 3. Creating the Project Directory

A project directory keeps your files organized.

Choose a location where you normally store programming projects.

### Windows PowerShell

```powershell
mkdir python-foundations
cd python-foundations
```

### macOS or Linux

```bash
mkdir python-foundations
cd python-foundations
```

The `mkdir` command creates a directory.

The `cd` command means **change directory**. It moves the terminal into the directory you just created.

To check your current location:

### Windows PowerShell

```powershell
Get-Location
```

### macOS or Linux

```bash
pwd
```

You should see a path ending with:

```text
python-foundations
```

---

## 4. Creating a Virtual Environment

A **virtual environment** is an isolated Python workspace.

It allows each project to have its own packages and configuration. Even though we will mainly use Python's standard library, creating a virtual environment is a useful professional habit.

Think of a virtual environment as a separate toolbox for one project.

Create one named `.venv`.

### Windows

```powershell
py -m venv .venv
```

If you use `python` instead of `py`, run:

```powershell
python -m venv .venv
```

### macOS or Linux

```bash
python3 -m venv .venv
```

The command has several parts:

```text
python -m venv .venv
```

- `python` starts Python.
- `-m` tells Python to run a module.
- `venv` is Python's built-in virtual-environment module.
- `.venv` is the directory where the environment will be created.

After running the command, your project should contain a hidden-looking directory named `.venv`.

---

## 5. Activating the Virtual Environment

Creating a virtual environment is not enough. You must activate it before using it.

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

When activation succeeds, your terminal prompt may begin with:

```text
(.venv)
```

For example:

```text
(.venv) PS C:\Users\You\python-foundations>
```

### Windows Command Prompt

```cmd
.venv\Scripts\activate.bat
```

### macOS or Linux

```bash
source .venv/bin/activate
```

Your prompt may now look similar to:

```text
(.venv) user@computer:~/python-foundations$
```

The `(.venv)` prefix indicates that the environment is active.

---

### PowerShell Execution Policy Message

On some Windows systems, PowerShell may display an error about script execution being disabled.

If that happens, open PowerShell and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Confirm the change if PowerShell asks for confirmation.

Then try activation again:

```powershell
.venv\Scripts\Activate.ps1
```

This changes the policy for your user account, not for the entire computer.

---

## 6. Verifying the Virtual Environment

With the environment active, run:

### Windows

```powershell
python --version
```

### macOS or Linux

```bash
python --version
```

You can also ask Python where it is running from:

```bash
python -c "import sys; print(sys.executable)"
```

On Windows PowerShell, you may see a path similar to:

```text
C:\Users\You\python-foundations\.venv\Scripts\python.exe
```

On macOS or Linux, you may see:

```text
/home/user/python-foundations/.venv/bin/python
```

The path should contain `.venv`.

That confirms that the virtual environment's Python interpreter is being used.

---

## 7. Creating Your First Python File

Create a file named:

```text
hello.py
```

Your project should now look like this:

```text
python-foundations/
├── .venv/
└── hello.py
```

Open `hello.py` in a text editor and add the following complete contents:

```python
print("Hello, Python!")
print("This program is running correctly.")
```

Save the file.

Run it from the project directory:

```bash
python hello.py
```

Expected output:

```text
Hello, Python!
This program is running correctly.
```

The command has this structure:

```text
python hello.py
```

- `python` starts the interpreter.
- `hello.py` tells Python which file to execute.

---

## 8. Running Python Interactively

Python can also execute individual instructions interactively.

Run:

```bash
python
```

You should see a prompt similar to:

```text
>>>
```

The `>>>` prompt means Python is waiting for an instruction.

Try:

```python
2 + 3
```

Python should display:

```text
5
```

Try:

```python
print("Hello from the interactive shell")
```

You should see:

```text
Hello from the interactive shell
```

To leave the interactive shell:

### Windows

Press:

```text
Ctrl+Z
```

Then press Enter.

### macOS or Linux

Press:

```text
Ctrl+D
```

You can also type:

```python
exit()
```

The interactive shell is useful for quickly testing small expressions.

A `.py` file is better for programs that you want to save and run again.

---

## 9. Comments

A comment is text intended for human readers rather than Python.

Comments begin with the `#` character.

Replace the contents of `hello.py` with:

```python
# This is a comment.
# Python ignores comments when running the program.

print("Hello, Python!")
```

Run the file:

```bash
python hello.py
```

Output:

```text
Hello, Python!
```

The comments do not appear in the output.

Comments are useful for explaining:

- Why code exists.
- What a complicated section does.
- Important assumptions.
- Temporary notes while learning.

Avoid comments that merely repeat the code:

```python
# Print Hello
print("Hello")
```

The code is already clear. A more useful comment would explain something that is not obvious from the code itself.

---

## 10. Indentation

Python uses indentation to group related instructions.

For example:

```python
if True:
    print("This line is inside the if statement.")
```

The indented line belongs to the `if` statement.

Python conventionally uses four spaces for each indentation level.

This is valid:

```python
if True:
    print("Inside the block")
```

This is invalid:

```python
if True:
print("Missing indentation")
```

Python will report an error because the instruction controlled by `if` must be indented.

Indentation is not merely visual formatting in Python. It is part of the language's syntax.

Use spaces rather than manually inserting inconsistent tabs. Most code editors can automatically insert four spaces when you press Tab.

---

## 11. Variables

A variable is a name that refers to a value.

```python
name = "Ada"
age = 36
```

This code creates two variables:

- `name` refers to the string `"Ada"`.
- `age` refers to the integer `36`.

The equals sign assigns a value:

```python
variable_name = value
```

It does not mean “is equal to” in the mathematical sense. It means “store this value under this name.”

Create a new file named:

```text
variables.py
```

Add:

```python
name = "Ada"
age = 36
city = "London"

print(name)
print(age)
print(city)
```

Run it:

```bash
python variables.py
```

Output:

```text
Ada
36
London
```

A variable can be used in calculations and messages:

```python
age = 36
next_year_age = age + 1

print(next_year_age)
```

Output:

```text
37
```

---

## 12. Naming Variables

Good variable names make code easier to understand.

Prefer:

```python
completed_tasks = 3
```

Instead of:

```python
x = 3
```

Python variable names can contain:

- Letters.
- Numbers.
- Underscores.

A variable name cannot begin with a number.

Valid examples:

```python
user_name = "Mina"
task_count = 5
is_ready = True
```

Invalid examples:

```python
2_users = 10
user-name = "Mina"
```

Python is case-sensitive:

```python
name = "Ada"
Name = "Grace"
```

These are two different variables.

Use `snake_case` for ordinary Python variable names:

```python
favorite_color = "blue"
```

Do not use spaces:

```python
favorite color = "blue"
```

---

## 13. Basic Data Types

Python values have different types.

The most important types for this part are:

- `str` — text.
- `int` — whole numbers.
- `float` — decimal numbers.
- `bool` — `True` or `False`.

### Strings

A string is text.

```python
name = "Ada"
message = 'Welcome to Python'
```

Strings can use single or double quotation marks. Choose one style and use it consistently.

```python
first_name = "Ada"
last_name = "Lovelace"
```

Strings can be combined using `+`:

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

The space in `" "` is included explicitly.

---

### Integers

An integer is a whole number.

```python
age = 36
task_count = 4
temperature = -2
```

Integers support arithmetic:

```python
apples = 5
more_apples = 3

total_apples = apples + more_apples

print(total_apples)
```

Output:

```text
8
```

Common arithmetic operators include:

| Operator | Meaning | Example |
|---|---|---|
| `+` | Addition | `5 + 2` |
| `-` | Subtraction | `5 - 2` |
| `*` | Multiplication | `5 * 2` |
| `/` | Division | `5 / 2` |
| `//` | Floor division | `5 // 2` |
| `%` | Remainder | `5 % 2` |
| `**` | Exponentiation | `5 ** 2` |

Try:

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

### Floating-Point Numbers

A `float` represents a number with a decimal component.

```python
price = 19.99
temperature = 21.5
average_score = 87.25
```

Example:

```python
price = 19.99
quantity = 3

total = price * quantity

print(total)
```

Output may be:

```text
59.97
```

Floating-point values are useful for many measurements and calculations. However, they can sometimes produce tiny rounding differences because computers store decimal numbers in binary form.

For basic learning exercises, this is usually not a problem. Financial applications often use the `decimal` module instead of ordinary floating-point arithmetic.

---

### Booleans

A Boolean represents one of two values:

```python
True
False
```

Boolean values are commonly used to represent yes/no or on/off information.

```python
is_logged_in = True
has_completed_setup = False
```

Boolean values must begin with a capital letter:

```python
True
False
```

These are not valid Boolean values:

```python
true
false
```

Python would interpret them as variable names instead.

---

## 14. Checking a Value's Type

Use the built-in `type()` function:

```python
name = "Ada"
age = 36
height = 1.65
is_learning = True

print(type(name))
print(type(age))
print(type(height))
print(type(is_learning))
```

Output:

```text
<class 'str'>
<class 'int'>
<class 'float'>
<class 'bool'>
```

You can also use `isinstance()` when checking whether a value belongs to a type:

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

For now, `type()` is useful for inspecting values while learning. `isinstance()` is generally more flexible in application code.

---

## 15. Dynamic Typing

Python is dynamically typed.

This means you do not need to declare a variable's type before assigning a value:

```python
value = 10
```

Python understands that `value` currently refers to an integer.

A variable can later refer to a different type:

```python
value = 10
print(type(value))

value = "ten"
print(type(value))
```

Output:

```text
<class 'int'>
<class 'str'>
```

Although this is allowed, changing a variable between unrelated types can make code difficult to understand.

This is usually clearer:

```python
item_count = 10
item_label = "ten"
```

Rather than:

```python
value = 10
value = "ten"
```

Clear names communicate what a value represents.

---

## 16. Combining Text and Values

This code causes an error:

```python
age = 36
print("Age: " + age)
```

Python cannot directly combine a string and an integer using `+`.

One solution is to convert the integer to a string:

```python
age = 36
print("Age: " + str(age))
```

Output:

```text
Age: 36
```

A more readable solution is an **f-string**:

```python
name = "Ada"
age = 36

print(f"{name} is {age} years old.")
```

Output:

```text
Ada is 36 years old.
```

An f-string begins with `f` before the opening quotation mark. Expressions inside curly braces are evaluated and inserted into the text.

Example:

```python
price = 12.50
quantity = 4
total = price * quantity

print(f"Total cost: ${total}")
```

Output:

```text
Total cost: $50.0
```

For two decimal places, use a formatting expression:

```python
print(f"Total cost: ${total:.2f}")
```

Output:

```text
Total cost: $50.00
```

---

## 17. Converting Between Types

Python provides built-in functions for converting values.

### Convert to a string

```python
number = 42
text = str(number)

print(text)
print(type(text))
```

### Convert to an integer

```python
text = "42"
number = int(text)

print(number)
print(type(number))
```

### Convert to a float

```python
text = "3.14"
number = float(text)

print(number)
print(type(number))
```

### Convert to a Boolean

```python
print(bool(1))
print(bool(0))
```

Output:

```text
True
False
```

Be careful when converting arbitrary text to Boolean values:

```python
print(bool("False"))
```

Output:

```text
True
```

Any non-empty string is considered truthy, including `"False"`.

This is one reason user input needs to be validated carefully. We will study input validation in detail later.

---

## 18. A Common Type Error

Create a file named:

```text
type_error_example.py
```

Add:

```python
age = "36"

print(age + 1)
```

Run it:

```bash
python type_error_example.py
```

Python will report a `TypeError`.

The exact wording may vary, but it will be similar to:

```text
TypeError: can only concatenate str (not "int") to str
```

The problem is that `"36"` is a string, not an integer.

Correct the file:

```python
age = "36"
age_as_number = int(age)

print(age_as_number + 1)
```

Run it again:

```bash
python type_error_example.py
```

Output:

```text
37
```

The general debugging process is:

1. Read the final line of the error.
2. Find the file and line number.
3. Inspect the values involved.
4. Check their types.
5. Convert or change the values appropriately.
6. Run the program again.

Errors are part of programming. The goal is not to avoid every error. The goal is to learn how to understand and fix them.

---

# Mini-Project: Personal Python Report

We will now combine variables, data types, arithmetic, and f-strings.

Create this directory:

```text
python-foundations/
└── projects/
```

### Windows PowerShell

```powershell
mkdir projects
```

### macOS or Linux

```bash
mkdir projects
```

Create the file:

```text
projects/personal_report.py
```

Add these complete contents:

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

Run the program from the project root:

```bash
python projects/personal_report.py
```

Expected output:

```text
Personal Report
---------------
Name: Ada Lovelace
Age: 36
City: London
Approximate birth year: 1990
Height: 165 cm
Learning Python: True
```

The birth year is approximate because the program does not know whether the person's birthday has occurred yet this year.

---

## How the Mini-Project Works

These lines create values:

```python
name = "Ada Lovelace"
age = 36
city = "London"
height_meters = 1.65
is_learning_python = True
```

The values have different types:

| Variable | Type |
|---|---|
| `name` | `str` |
| `age` | `int` |
| `city` | `str` |
| `height_meters` | `float` |
| `is_learning_python` | `bool` |

This line performs arithmetic:

```python
birth_year = 2026 - age
```

This line converts meters to centimeters:

```python
height_centimeters = height_meters * 100
```

This expression formats the height with no decimal places:

```python
f"{height_centimeters:.0f}"
```

The `.0f` means:

- `f` — format as a floating-point number.
- `.0` — show zero digits after the decimal point.

---

## 19. Adding User Input

Python can read text typed by a user with the `input()` function.

Create:

```text
projects/greeting.py
```

Add:

```python
name = input("What is your name? ")

print(f"Hello, {name}!")
```

Run it:

```bash
python projects/greeting.py
```

Example session:

```text
What is your name? Sam
Hello, Sam!
```

The value returned by `input()` is always a string.

For example:

```python
age = input("How old are you? ")

print(type(age))
```

Even if the user types:

```text
36
```

the type will be:

```text
<class 'str'>
```

To use the value as a number, convert it:

```python
age_text = input("How old are you? ")
age = int(age_text)

print(f"Next year, you will be {age + 1}.")
```

This works for numeric input:

```text
How old are you? 36
Next year, you will be 37.
```

However, it will currently crash if the user types something that is not a whole number:

```text
How old are you? tomorrow
```

We will learn how to handle that safely in Module 3 and Module 4.

---

## 20. A Small Interactive Calculator

Create:

```text
projects/price_calculator.py
```

Add:

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

Run it:

```bash
python projects/price_calculator.py
```

Example session:

```text
What are you buying? Notebook
What is the price? 4.50
How many do you need? 3

Purchase Summary
----------------
Item: Notebook
Quantity: 3
Price per item: $4.50
Total: $13.50
```

This program demonstrates:

- Reading text with `input()`.
- Converting text to `float`.
- Converting text to `int`.
- Multiplying values.
- Formatting currency.
- Displaying a structured result.

---

## 21. Deactivating the Virtual Environment

When you finish working, you can deactivate the environment:

```bash
deactivate
```

The `(.venv)` prefix should disappear from your terminal prompt.

To work on the project again later:

1. Move into the project directory.
2. Activate the environment.

Example:

```bash
cd python-foundations
```

Then:

### Windows

```powershell
.venv\Scripts\Activate.ps1
```

### macOS or Linux

```bash
source .venv/bin/activate
```

---

## 22. Verification Checklist

Before continuing, confirm that you can complete all of the following:

- [ ] Check your Python version.
- [ ] Create the `python-foundations` directory.
- [ ] Create a `.venv` virtual environment.
- [ ] Activate the virtual environment.
- [ ] Confirm that Python is running from `.venv`.
- [ ] Create and run `hello.py`.
- [ ] Use the interactive Python shell.
- [ ] Create variables.
- [ ] Identify strings, integers, floats, and Booleans.
- [ ] Use arithmetic operators.
- [ ] Use an f-string.
- [ ] Convert a string to an integer.
- [ ] Run `personal_report.py`.
- [ ] Run `price_calculator.py`.
- [ ] Deactivate the virtual environment.

Your project should now look similar to this:

```text
python-foundations/
├── .venv/
├── hello.py
├── variables.py
├── type_error_example.py
└── projects/
    ├── personal_report.py
    ├── greeting.py
    └── price_calculator.py
```

The `.venv` directory contains environment files created by Python. Do not edit those files manually.

---

## 23. Practice Exercises

### Exercise 1: About You

Create:

```text
projects/about_you.py
```

Write a program that stores and displays:

- Your name.
- Your favorite color.
- Your age.
- Your height.
- Whether you are currently learning Python.

Use variables and f-strings.

---

### Exercise 2: Rectangle Calculator

Create:

```text
projects/rectangle.py
```

Store a rectangle's width and height.

Calculate and display:

- The area.
- The perimeter.

Use these formulas:

```text
area = width × height
perimeter = 2 × (width + height)
```

For example:

```python
width = 8
height = 5
```

Expected results:

```text
Area: 40
Perimeter: 26
```

---

### Exercise 3: Minutes to Seconds

Create:

```text
projects/time_converter.py
```

Store a number of minutes and convert it to seconds.

Use:

```text
seconds = minutes × 60
```

Example:

```python
minutes = 7
```

Expected output:

```text
7 minutes equals 420 seconds.
```

---

### Exercise 4: Modify the Price Calculator

Update `price_calculator.py` to display the tax.

Use a tax rate of 20 percent:

```python
tax_rate = 0.20
tax = total * tax_rate
grand_total = total + tax
```

Display:

```text
Subtotal: $13.50
Tax: $2.70
Grand total: $16.20
```

---

## Summary

In this part, you learned how to:

- Check and run Python.
- Create a project directory.
- Create and activate a virtual environment.
- Run Python files.
- Use the interactive shell.
- Write comments.
- Understand indentation.
- Create and name variables.
- Use strings, integers, floats, and Booleans.
- Perform arithmetic.
- Inspect types.
- Convert values between types.
- Use f-strings.
- Read basic input with `input()`.
- Build small working programs.

The central idea is that Python programs manipulate values.

A program can:

1. Receive values.
2. Store values in variables.
3. Transform values.
4. Display results.

The programs are still simple, but they already follow the basic pattern used by much larger applications.
