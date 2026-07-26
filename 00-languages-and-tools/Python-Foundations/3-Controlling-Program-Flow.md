# Part 3: Controlling Program Flow

So far, your programs have executed instructions from top to bottom.

Real programs need to do more than that. They must be able to:

- Make decisions.
- Repeat actions.
- Respond differently to different input.
- Stop repeating when a condition is met.
- Reject invalid input.
- Continue running after a user makes a mistake.

This part introduces **control flow**.

You will learn:

- Comparison operators.
- Boolean expressions.
- `if`, `elif`, and `else`.
- Logical operators.
- `for` loops.
- `while` loops.
- `range()`.
- `break` and `continue`.
- `enumerate()`.
- Input validation.
- How to build an interactive task program.

---

# 1. What Is Control Flow?

**Control flow** describes the order in which a program executes instructions.

A simple program follows a straight path:

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

A program with control flow can choose between paths:

```python
temperature = 30

if temperature > 25:
    print("It is warm.")
else:
    print("It is cool.")
```

Output:

```text
It is warm.
```

The program did not execute both messages. It selected one based on the value of `temperature`.

---

# 2. Comparison Operators

Comparison operators compare values.

They produce a Boolean result:

```python
True
False
```

| Operator | Meaning | Example |
|---|---|---|
| `==` | Equal to | `age == 18` |
| `!=` | Not equal to | `age != 18` |
| `>` | Greater than | `age > 18` |
| `<` | Less than | `age < 18` |
| `>=` | Greater than or equal to | `age >= 18` |
| `<=` | Less than or equal to | `age <= 18` |

Try these expressions in the interactive Python shell:

```python
print(5 == 5)
print(5 == 3)
print(5 != 3)
print(5 > 3)
print(5 < 3)
print(5 >= 5)
print(5 <= 4)
```

Output:

```text
True
False
True
True
False
True
False
```

---

## The Difference Between `=` and `==`

The single equals sign assigns a value:

```python
age = 36
```

The double equals sign compares values:

```python
print(age == 36)
```

Output:

```text
True
```

Do not confuse these two operations.

```python
age = 36
```

means:

> Store `36` in `age`.

```python
age == 36
```

means:

> Is the value of `age` equal to `36`?

---

# 3. Conditional Statements

A conditional statement runs code only when a condition is true.

Create:

```text
projects/check_age.py
```

Add:

```python
age = 20

if age >= 18:
    print("You are an adult.")
```

Run it:

```bash
python projects/check_age.py
```

Output:

```text
You are an adult.
```

The condition is:

```python
age >= 18
```

Because the condition is true, Python runs the indented line.

The colon after the condition is required:

```python
if condition:
```

The code controlled by the `if` statement must be indented:

```python
if condition:
    print("This belongs to the if block.")
```

---

## A Condition That Is False

Change the file:

```python
age = 15

if age >= 18:
    print("You are an adult.")
```

Run it again:

```bash
python projects/check_age.py
```

This time, nothing is printed because the condition is false.

---

# 4. The `else` Block

Use `else` to run code when the `if` condition is false.

Update `check_age.py`:

```python
age = 15

if age >= 18:
    print("You are an adult.")
else:
    print("You are not an adult.")
```

Output:

```text
You are not an adult.
```

The structure is:

```python
if condition:
    # Runs when condition is True
else:
    # Runs when condition is False
```

Only one of these blocks runs.

---

# 5. The `elif` Block

Use `elif`, short for “else if”, when there are several possible conditions.

Create:

```text
projects/grade_checker.py
```

Add:

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

Run it:

```bash
python projects/grade_checker.py
```

Output:

```text
Grade: B
```

Python checks the conditions from top to bottom.

For a score of `83`:

1. `83 >= 90` is false.
2. `83 >= 80` is true.
3. Python assigns `"B"`.
4. The remaining conditions are skipped.

The order of conditions matters.

This version is incorrect:

```python
if score >= 60:
    grade = "D"
elif score >= 80:
    grade = "B"
```

A score of `83` would receive a `"D"` because the first condition is already true.

Put more specific or higher thresholds first.

---

# 6. Nested Conditions

A conditional can contain another conditional.

Create:

```text
projects/access_checker.py
```

Add:

```python
is_logged_in = True
is_admin = False

if is_logged_in:
    print("User is logged in.")

    if is_admin:
        print("Admin controls are available.")
    else:
        print("Standard user controls are available.")
else:
    print("Please log in first.")
```

Output:

```text
User is logged in.
Standard user controls are available.
```

Nested conditions can be useful, but too many levels of nesting can make code difficult to read.

When programs become larger, functions can help separate complicated logic into smaller pieces.

---

# 7. Logical Operators

Logical operators combine conditions.

## `and`

`and` is true only when both conditions are true:

```python
age = 25
has_ticket = True

if age >= 18 and has_ticket:
    print("Entry allowed.")
```

Output:

```text
Entry allowed.
```

Truth table:

| First condition | Second condition | Result |
|---|---|---|
| `True` | `True` | `True` |
| `True` | `False` | `False` |
| `False` | `True` | `False` |
| `False` | `False` | `False` |

---

## `or`

`or` is true when at least one condition is true:

```python
day = "Saturday"

if day == "Saturday" or day == "Sunday":
    print("It is the weekend.")
```

Output:

```text
It is the weekend.
```

---

## `not`

`not` reverses a Boolean value:

```python
is_locked = False

if not is_locked:
    print("The door is open.")
```

Output:

```text
The door is open.
```

Another example:

```python
is_completed = False

if not is_completed:
    print("This task still needs attention.")
```

---

# 8. Combining Membership Checks with Conditions

The `in` operator can be used in conditions.

```python
valid_commands = {"add", "list", "complete", "remove"}

command = "list"

if command in valid_commands:
    print("Recognized command.")
else:
    print("Unknown command.")
```

Output:

```text
Recognized command.
```

For text, use the `in` operator to check whether one string contains another:

```python
message = "Python is readable."

if "Python" in message:
    print("The message mentions Python.")
```

Output:

```text
The message mentions Python.
```

---

# 9. Truthy and Falsy Values

Python allows many values to be used directly in conditions.

These values are generally considered false:

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

Most other values are considered true.

Example:

```python
name = ""

if name:
    print("A name was entered.")
else:
    print("The name is empty.")
```

Output:

```text
The name is empty.
```

This is useful for checking input:

```python
user_input = input("Enter a task: ")

if user_input:
    print(f"Task received: {user_input}")
else:
    print("You did not enter a task.")
```

A string containing spaces is not empty:

```python
text = "   "

print(bool(text))
```

Output:

```text
True
```

To treat whitespace-only input as empty, use `.strip()`:

```python
user_input = input("Enter a task: ").strip()

if user_input:
    print(f"Task received: {user_input}")
else:
    print("The task cannot be empty.")
```

The `.strip()` method removes whitespace from the beginning and end of a string.

---

# 10. `for` Loops

A `for` loop repeats code for each item in a collection.

Create:

```text
projects/loop_tasks.py
```

Add:

```python
tasks = [
    "Learn Python",
    "Practice conditions",
    "Practice loops",
]

for task in tasks:
    print(task)
```

Run it:

```bash
python projects/loop_tasks.py
```

Output:

```text
Learn Python
Practice conditions
Practice loops
```

The structure is:

```python
for item in collection:
    # Code repeated for each item
```

The variable `task` refers to a different item during each repetition.

---

## Adding Text to Each Item

```python
tasks = [
    "Learn Python",
    "Practice conditions",
    "Practice loops",
]

for task in tasks:
    print(f"Task: {task}")
```

Output:

```text
Task: Learn Python
Task: Practice conditions
Task: Practice loops
```

---

# 11. Using `range()`

The `range()` function generates a sequence of numbers.

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

The final value is not included.

This:

```python
range(5)
```

generates:

```text
0, 1, 2, 3, 4
```

To start from another number:

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

The general form is:

```python
range(start, stop)
```

The `stop` value is excluded.

---

## Using a Step Value

You can provide a third argument:

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

The structure is:

```python
range(start, stop, step)
```

Count backward with a negative step:

```python
for number in range(5, 0, -1):
    print(number)
```

Output:

```text
5
4
3
2
1
```

---

# 12. Looping with Indexes

Sometimes you need both an item's position and its value.

You can use `range(len(items))`:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

for index in range(len(tasks)):
    print(f"{index}: {tasks[index]}")
```

Output:

```text
0: Learn Python
1: Practice loops
2: Build a CLI tool
```

However, `enumerate()` is usually clearer.

---

## Using `enumerate()`

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

for index, task in enumerate(tasks):
    print(f"{index}: {task}")
```

Output:

```text
0: Learn Python
1: Practice loops
2: Build a CLI tool
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
3. Build a CLI tool
```

This is especially useful for displaying numbered menus.

---

# 13. Looping Through a List of Dictionaries

Create:

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

Output:

```text
[x] 1 - Learn Python
[ ] 2 - Practice loops
```

The loop processes one dictionary at a time.

The conditional determines which status symbol to display.

---

# 14. The `while` Loop

A `while` loop repeats code as long as a condition remains true.

Create:

```text
projects/countdown.py
```

Add:

```python
count = 5

while count > 0:
    print(count)
    count -= 1

print("Finished!")
```

Run it:

```bash
python projects/countdown.py
```

Output:

```text
5
4
3
2
1
Finished!
```

The loop condition is:

```python
count > 0
```

Each repetition reduces `count`:

```python
count -= 1
```

When `count` reaches zero, the condition becomes false and the loop ends.

---

## Avoiding Infinite Loops

This loop never ends:

```python
count = 5

while count > 0:
    print(count)
```

The value of `count` never changes, so `count > 0` remains true forever.

A `while` loop must usually change something that affects its condition:

```python
count -= 1
```

If you accidentally create an infinite loop, press:

```text
Ctrl+C
```

to stop the program.

---

# 15. Interactive `while` Loops

A `while` loop is useful for programs that should continue until the user chooses to quit.

Create:

```text
projects/simple_menu.py
```

Add:

```python
choice = ""

while choice != "q":
    print()
    print("Menu")
    print("----")
    print("a - Say hello")
    print("q - Quit")

    choice = input("Choose an option: ").strip().lower()

    if choice == "a":
        print("Hello!")
    elif choice == "q":
        print("Goodbye.")
    else:
        print("Unknown option.")
```

Run it:

```bash
python projects/simple_menu.py
```

Example session:

```text
Menu
----
a - Say hello
q - Quit
Choose an option: a
Hello!

Menu
----
a - Say hello
q - Quit
Choose an option: x
Unknown option.

Menu
----
a - Say hello
q - Quit
Choose an option: q
Goodbye.
```

The loop continues while `choice != "q"`.

The `.lower()` method converts input to lowercase, so these inputs are treated the same:

```text
A
a
```

---

# 16. `break`

The `break` statement immediately exits a loop.

Rewrite the menu using `break`:

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

The condition `while True` creates a loop that would continue forever.

The `break` statement provides the exit:

```python
break
```

Use this pattern when the exit condition is easier to understand inside the loop.

---

# 17. `continue`

The `continue` statement skips the rest of the current iteration and starts the next one.

Create:

```text
projects/skip_empty_tasks.py
```

Add:

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

Output:

```text
Learn Python
Practice loops
Build a CLI tool
```

When the program encounters an empty or whitespace-only task, `continue` skips the `print()` statement.

---

# 18. Input Validation

User input should not be trusted automatically.

A user might enter:

- An empty string.
- Letters where a number is required.
- A negative number.
- An unknown menu command.
- Extra spaces.
- Unexpected capitalization.

Validation means checking input before using it.

---

## Validating Required Text

Create:

```text
projects/required_text.py
```

Add:

```python
name = input("Enter your name: ").strip()

if not name:
    print("Name cannot be empty.")
else:
    print(f"Hello, {name}!")
```

Run it:

```bash
python projects/required_text.py
```

If the user enters only spaces, `.strip()` converts the value to an empty string, and the program rejects it.

---

## Validating Integer Text with `isdigit()`

Create:

```text
projects/number_validation.py
```

Add:

```python
age_text = input("Enter your age: ").strip()

if age_text.isdigit():
    age = int(age_text)
    print(f"Next year, you will be {age + 1}.")
else:
    print("Please enter a whole number.")
```

The `.isdigit()` method returns `True` when a string contains only digit characters.

Example:

```python
print("42".isdigit())
print("hello".isdigit())
print("4.2".isdigit())
```

Output:

```text
True
False
False
```

This handles positive whole numbers such as `42`.

It does not accept:

```text
-5
3.14
```

For more flexible numeric validation, we will use exception handling in Module 4.

---

## Validating a Range

A value can be numeric but still unreasonable.

For example, an age of `500` is a whole number, but it may not be valid for the application.

```python
age_text = input("Enter your age: ").strip()

if not age_text.isdigit():
    print("Please enter a whole number.")
else:
    age = int(age_text)

    if age < 0 or age > 120:
        print("Please enter an age between 0 and 120.")
    else:
        print(f"Your age is {age}.")
```

This uses the `or` operator:

```python
age < 0 or age > 120
```

The input is invalid if either condition is true.

---

# 19. Repeated Input Validation

A `while` loop can repeatedly ask for input until the user enters a valid value.

Create:

```text
projects/validated_age.py
```

Add:

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

The program behaves like this:

1. Ask for an age.
2. Check whether the input contains digits.
3. If not, display an error and restart the loop.
4. Convert the text to an integer.
5. Check whether the value is in the allowed range.
6. If not, display an error and restart the loop.
7. If valid, display the value and exit the loop.

Example session:

```text
Enter your age: tomorrow
Please enter a whole number.
Enter your age: 200
Please enter an age between 0 and 120.
Enter your age: 36
Accepted age: 36
```

---

# 20. Input Normalization

Input normalization transforms different forms of input into a consistent format.

```python
command = input("Enter a command: ").strip().lower()
```

This performs two operations:

- `.strip()` removes surrounding whitespace.
- `.lower()` converts letters to lowercase.

These inputs all become `"list"`:

```text
list
LIST
 List
list   
```

This makes command handling more reliable.

---

# 21. A Menu with Numbered Choices

Create:

```text
projects/numbered_menu.py
```

Add:

```python
while True:
    print()
    print("Main Menu")
    print("---------")
    print("1. Show greeting")
    print("2. Show status")
    print("3. Quit")

    choice = input("Choose an option: ").strip()

    if choice == "1":
        print("Hello from the program.")
    elif choice == "2":
        print("The program is running.")
    elif choice == "3":
        print("Goodbye.")
        break
    else:
        print("Please choose 1, 2, or 3.")
```

Run it:

```bash
python projects/numbered_menu.py
```

This is the basic pattern we will use for an interactive task manager.

---

# Mini-Project: Interactive Task Manager

We will now build a small task manager that runs in the terminal.

It will support:

- Adding tasks.
- Listing tasks.
- Completing tasks.
- Removing tasks.
- Quitting the program.
- Validating task names.
- Validating task IDs.

The data will be stored only in memory. When the program closes, the tasks will disappear. File persistence will be introduced in Part 4.

Create:

```text
projects/interactive_tasks.py
```

Add these complete contents:

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

                print(f"[{status}] {task['id']} - {task['title']}")

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
        task_id_text = input("Enter the task ID to complete: ").strip()

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
        task_id_text = input("Enter the task ID to remove: ").strip()

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

Run it:

```bash
python projects/interactive_tasks.py
```

Example session:

```text
Task Manager
------------
1. List tasks
2. Add task
3. Complete task
4. Remove task
5. Quit
Choose an option: 1

Tasks:
[ ] 1 - Learn Python
```

Add another task:

```text
Choose an option: 2
Enter a task title: Practice conditions
Task 2 created.
```

List tasks again:

```text
Choose an option: 1

Tasks:
[ ] 1 - Learn Python
[ ] 2 - Practice conditions
```

Complete the second task:

```text
Choose an option: 3
Enter the task ID to complete: 2
Task 2 completed.
```

List the tasks:

```text
Choose an option: 1

Tasks:
[ ] 1 - Learn Python
[x] 2 - Practice conditions
```

Remove a task:

```text
Choose an option: 4
Enter the task ID to remove: 1
Task 1 removed.
```

Quit:

```text
Choose an option: 5
Goodbye.
```

---

## How the Task Manager Works

The tasks are stored in a list:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    },
]
```

Each task is a dictionary.

The program uses `next_id` to assign a unique ID:

```python
next_id = 2
```

After adding a task, the ID increases:

```python
next_id += 1
```

The main menu is inside an infinite loop:

```python
while True:
```

The program exits only when it reaches:

```python
break
```

The list option checks whether the list is empty:

```python
if not tasks:
    print("No tasks found.")
```

An empty list is falsy, so `not tasks` becomes true when there are no tasks.

The complete option searches through the list:

```python
for task in tasks:
    if task["id"] == task_id:
        task["completed"] = True
```

The remove option searches for a matching task and removes it:

```python
tasks.remove(task)
```

The `break` statement stops searching after the correct task is found.

---

# 22. Important Loop Warning

Avoid removing items from a list while directly iterating through it unless you stop immediately after the removal.

This can cause confusing behavior:

```python
for task in tasks:
    if task["completed"]:
        tasks.remove(task)
```

Removing items changes the list while Python is still moving through it.

In the task manager, the program uses:

```python
tasks.remove(task)
break
```

The `break` prevents the loop from continuing after the list changes.

Later, you will learn additional techniques for safely filtering and transforming collections.

---

# 23. Practice Exercises

## Exercise 1: Even or Odd

Create:

```text
projects/even_odd.py
```

Store a number and determine whether it is even or odd.

Use the remainder operator:

```python
number % 2
```

A number is even when:

```python
number % 2 == 0
```

Example output:

```text
8 is even.
```

---

## Exercise 2: Temperature Advice

Create:

```text
projects/temperature_advice.py
```

Store a temperature and display advice:

- Above `30`: `"It is very hot."`
- From `20` through `30`: `"The temperature is comfortable."`
- From `10` through `19`: `"It is cool."`
- Below `10`: `"It is cold."`

Use `if`, `elif`, and `else`.

---

## Exercise 3: Count Down

Create:

```text
projects/countdown_input.py
```

Ask the user for a positive whole number.

Then count down to zero using a `while` loop.

Example:

```text
Enter a starting number: 3
3
2
1
0
Finished!
```

Reject empty input and non-numeric input.

---

## Exercise 4: Print Numbered Tasks

Create a list of tasks and use `enumerate()` to display them starting at one:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]
```

Expected output:

```text
1. Learn Python
2. Practice loops
3. Build a CLI tool
```

---

## Exercise 5: Search for a Task

Create a list of task dictionaries.

Ask the user for a task ID and search for it.

Display the task title if it exists:

```text
Task found: Learn Python
```

Otherwise display:

```text
No task found with that ID.
```

Validate that the ID contains a whole number before converting it with `int()`.

---

## Exercise 6: Improve the Task Manager

Modify `interactive_tasks.py` so it also supports:

```text
6. Show task statistics
```

The statistics should display:

- Total tasks.
- Completed tasks.
- Incomplete tasks.

Example:

```text
Total tasks: 4
Completed tasks: 2
Incomplete tasks: 2
```

---

# Verification Checklist

Before continuing, confirm that you can:

- [ ] Use `==`, `!=`, `>`, `<`, `>=`, and `<=`.
- [ ] Explain the difference between `=` and `==`.
- [ ] Write an `if` statement.
- [ ] Use `else`.
- [ ] Use multiple `elif` branches.
- [ ] Combine conditions with `and`.
- [ ] Combine conditions with `or`.
- [ ] Reverse a condition with `not`.
- [ ] Check membership with `in`.
- [ ] Check whether a collection is empty.
- [ ] Loop through a list with `for`.
- [ ] Use `range()`.
- [ ] Use `enumerate()`.
- [ ] Write a `while` loop.
- [ ] Stop a loop with `break`.
- [ ] Skip an iteration with `continue`.
- [ ] Normalize input with `.strip()` and `.lower()`.
- [ ] Validate required text.
- [ ] Validate positive whole numbers.
- [ ] Build and run the interactive task manager.
- [ ] Handle unknown menu choices without crashing.

Your project may now look like this:

```text
python-foundations/
├── .venv/
├── hello.py
├── variables.py
├── type_error_example.py
└── projects/
    ├── personal_report.py
    ├── greeting.py
    ├── price_calculator.py
    ├── show_tasks.py
    ├── task_collection.py
    ├── favorite_foods.py
    ├── contact.py
    ├── inventory.py
    ├── unique_words.py
    ├── check_age.py
    ├── grade_checker.py
    ├── access_checker.py
    ├── loop_tasks.py
    ├── countdown.py
    ├── simple_menu.py
    ├── skip_empty_tasks.py
    ├── required_text.py
    ├── number_validation.py
    ├── validated_age.py
    ├── numbered_menu.py
    └── interactive_tasks.py
```

---

# Summary

In this part, you learned how programs make decisions and repeat work.

Conditional statements allow programs to choose:

```python
if task["completed"]:
    print("Done")
else:
    print("Incomplete")
```

`for` loops process each item in a collection:

```python
for task in tasks:
    print(task)
```

`while` loops continue while a condition is true:

```python
while choice != "q":
    ...
```

`break` exits a loop:

```python
break
```

`continue` skips the current iteration:

```python
continue
```

You also learned how to validate user input before using it.

The interactive task manager now has the basic behavior of a real command-line application. However, it still has several limitations:

- The program is one large file.
- The data disappears when the program closes.
- The same logic is repeated in several places.
- Errors are handled only with basic validation.
- The program cannot read or write persistent data.

In the next part, you will learn how to define reusable functions, organize code into modules, read and write files, work with JSON, and handle exceptions safely.
