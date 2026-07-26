# Part 2: Structuring Data with Collections

In Part 1, you worked with individual values:

```python
name = "Ada"
age = 36
is_learning_python = True
```

Real programs usually need to work with groups of related values.

A task manager might need to store several tasks:

```python
tasks = [
    "Learn Python",
    "Practice collections",
    "Build a CLI tool",
]
```

A single task may contain several properties:

```python
task = {
    "title": "Learn Python",
    "completed": False,
    "priority": "high",
}
```

Python provides four important built-in collection types:

- **Lists** — ordered, changeable collections.
- **Tuples** — ordered collections intended to remain unchanged.
- **Dictionaries** — key-value structures.
- **Sets** — unordered collections of unique values.

In this part, you will learn:

- How to create collections.
- How to access individual items.
- How to add, remove, and update values.
- How to loop through collections.
- When to use lists, tuples, dictionaries, and sets.
- How to combine collections.
- How to build a small task-data program.

---

# 1. Lists

A list stores multiple values in a specific order.

Create a list with square brackets:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]
```

Each item has a position called an **index**.

Python indexes start at zero:

```text
Index:   0                  1                 2
Value:   Learn Python       Practice loops    Build a CLI tool
```

Access an item by placing its index inside square brackets:

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

The first item is at index `0`, not index `1`.

---

## 2. Negative List Indexes

Negative indexes count from the end of a list.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

print(tasks[-1])
print(tasks[-2])
```

Output:

```text
Build a CLI tool
Practice loops
```

The indexes work like this:

```text
Index:   0                1                 2
Negative: -3             -2                -1
Value:   Learn Python     Practice loops    Build a CLI tool
```

Using `[-1]` is a convenient way to access the final item.

---

## 3. Changing List Items

Lists are **mutable**.

Mutable means that their contents can be changed after the list is created.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

tasks[1] = "Practice dictionaries"

print(tasks)
```

Output:

```text
['Learn Python', 'Practice dictionaries', 'Build a CLI tool']
```

The item at index `1` was replaced.

---

## 4. Adding Items to a List

### The `append()` Method

Use `append()` to add one item to the end of a list:

```python
tasks = [
    "Learn Python",
    "Practice loops",
]

tasks.append("Build a CLI tool")

print(tasks)
```

Output:

```text
['Learn Python', 'Practice loops', 'Build a CLI tool']
```

The list grows by one item.

---

### The `insert()` Method

Use `insert()` when you want to add an item at a particular position:

```python
tasks = [
    "Learn Python",
    "Build a CLI tool",
]

tasks.insert(1, "Practice loops")

print(tasks)
```

Output:

```text
['Learn Python', 'Practice loops', 'Build a CLI tool']
```

The first argument is the index where the new item should be placed.

---

### The `extend()` Method

Use `extend()` to add multiple items:

```python
tasks = [
    "Learn Python",
]

additional_tasks = [
    "Practice loops",
    "Build a CLI tool",
]

tasks.extend(additional_tasks)

print(tasks)
```

Output:

```text
['Learn Python', 'Practice loops', 'Build a CLI tool']
```

You can also combine lists with `+`:

```python
first_group = ["Learn Python"]
second_group = ["Practice loops", "Build a CLI tool"]

all_tasks = first_group + second_group

print(all_tasks)
```

The `+` operator creates a new list.

The `extend()` method changes the original list.

---

## 5. Removing Items from a List

### The `remove()` Method

Use `remove()` when you know the value you want to delete:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

tasks.remove("Practice loops")

print(tasks)
```

Output:

```text
['Learn Python', 'Build a CLI tool']
```

If the value does not exist, `remove()` raises a `ValueError`.

```python
tasks = ["Learn Python"]

tasks.remove("Practice loops")
```

This produces an error because `"Practice loops"` is not in the list.

We will learn how to handle such errors safely in a later part.

---

### The `pop()` Method

Use `pop()` to remove an item by index.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

removed_task = tasks.pop(1)

print(f"Removed: {removed_task}")
print(tasks)
```

Output:

```text
Removed: Practice loops
['Learn Python', 'Build a CLI tool']
```

If you call `pop()` without an index, it removes and returns the final item:

```python
tasks = [
    "Learn Python",
    "Practice loops",
]

last_task = tasks.pop()

print(f"Removed: {last_task}")
print(tasks)
```

Output:

```text
Removed: Practice loops
['Learn Python']
```

---

### The `del` Statement

You can use `del` to remove an item by index:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

del tasks[1]

print(tasks)
```

Output:

```text
['Learn Python', 'Build a CLI tool']
```

`pop()` is useful when you need the removed value.

`del` is useful when you only need to remove it.

---

### The `clear()` Method

Use `clear()` to remove every item:

```python
tasks = [
    "Learn Python",
    "Practice loops",
]

tasks.clear()

print(tasks)
```

Output:

```text
[]
```

The list still exists, but it is empty.

---

## 6. Checking List Contents

Use the `in` operator to check whether a value exists:

```python
tasks = [
    "Learn Python",
    "Practice loops",
]

print("Learn Python" in tasks)
print("Build a CLI tool" in tasks)
```

Output:

```text
True
False
```

Use `not in` to check that a value does not exist:

```python
print("Build a CLI tool" not in tasks)
```

Output:

```text
True
```

You can use the result in a conditional:

```python
tasks = ["Learn Python"]

if "Learn Python" in tasks:
    print("That task exists.")
```

The `if` statement will be covered more fully in Module 3.

---

## 7. Finding the Length of a Collection

Use the built-in `len()` function:

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]

print(len(tasks))
```

Output:

```text
3
```

You can use the length when displaying information:

```python
print(f"You have {len(tasks)} tasks.")
```

Output:

```text
You have 3 tasks.
```

---

## 8. List Slicing

A slice extracts part of a list.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
    "Read documentation",
]

print(tasks[0:2])
```

Output:

```text
['Learn Python', 'Practice loops']
```

The syntax is:

```python
list[start:end]
```

The start index is included.

The end index is excluded.

So:

```python
tasks[0:2]
```

means:

- Start at index `0`.
- Stop before index `2`.

You can omit either side:

```python
print(tasks[:2])
print(tasks[2:])
print(tasks[:])
```

Output:

```text
['Learn Python', 'Practice loops']
['Build a CLI tool', 'Read documentation']
['Learn Python', 'Practice loops', 'Build a CLI tool', 'Read documentation']
```

A negative slice can select items near the end:

```python
print(tasks[-2:])
```

Output:

```text
['Build a CLI tool', 'Read documentation']
```

---

## 9. Sorting Lists

Use `sort()` to sort a list in place:

```python
tasks = [
    "Build a CLI tool",
    "Learn Python",
    "Practice loops",
]

tasks.sort()

print(tasks)
```

Output:

```text
['Build a CLI tool', 'Learn Python', 'Practice loops']
```

For numbers:

```python
scores = [82, 95, 71, 88]

scores.sort()

print(scores)
```

Output:

```text
[71, 82, 88, 95]
```

Sort in descending order:

```python
scores.sort(reverse=True)

print(scores)
```

Output:

```text
[95, 88, 82, 71]
```

The `sorted()` function creates a new sorted list without changing the original:

```python
tasks = [
    "Build a CLI tool",
    "Learn Python",
    "Practice loops",
]

sorted_tasks = sorted(tasks)

print(tasks)
print(sorted_tasks)
```

Output:

```text
['Build a CLI tool', 'Learn Python', 'Practice loops']
['Build a CLI tool', 'Learn Python', 'Practice loops']
```

---

# 10. Tuples

A tuple is an ordered collection.

Tuples are commonly written with parentheses:

```python
coordinates = (51.5074, -0.1278)
```

You can access tuple items using indexes:

```python
coordinates = (51.5074, -0.1278)

print(coordinates[0])
print(coordinates[1])
```

Output:

```text
51.5074
-0.1278
```

Tuples support many operations that lists support:

```python
colors = ("red", "green", "blue")

print(colors[0])
print(len(colors))
print("red" in colors)
```

Output:

```text
red
3
True
```

---

## 11. Tuples Are Immutable

Tuples cannot be changed after creation.

This causes an error:

```python
coordinates = (51.5074, -0.1278)

coordinates[0] = 40.7128
```

A tuple is appropriate when the values belong together and should not be modified.

Examples include:

```python
point = (10, 20)
rgb_color = (255, 128, 0)
month_range = (1, 12)
```

A tuple communicates:

> “These values form a fixed group.”

A list communicates:

> “These values form a collection that may change.”

---

## 12. Tuple Unpacking

You can assign tuple values to separate variables:

```python
coordinates = (51.5074, -0.1278)

latitude, longitude = coordinates

print(latitude)
print(longitude)
```

Output:

```text
51.5074
-0.1278
```

This is called **tuple unpacking**.

It can also be used with lists:

```python
person = ["Ada", 36]

name, age = person

print(name)
print(age)
```

The number of variables must match the number of values:

```python
person = ["Ada", 36, "London"]

name, age = person
```

This produces an error because there are three values but only two variables.

---

# 13. Dictionaries

A dictionary stores data as key-value pairs.

Create a dictionary with curly braces:

```python
task = {
    "title": "Learn Python",
    "completed": False,
    "priority": "high",
}
```

Each key identifies a value:

```text
"title"     → "Learn Python"
"completed" → False
"priority"  → "high"
```

Access a value using its key:

```python
print(task["title"])
print(task["completed"])
print(task["priority"])
```

Output:

```text
Learn Python
False
high
```

A dictionary is useful when values have labels.

Instead of this:

```python
task = ["Learn Python", False, "high"]
```

you can write:

```python
task = {
    "title": "Learn Python",
    "completed": False,
    "priority": "high",
}
```

The dictionary version is easier to understand because each value has a name.

---

## 14. Adding and Updating Dictionary Values

Add a new key-value pair:

```python
task = {
    "title": "Learn Python",
    "completed": False,
}

task["priority"] = "high"

print(task)
```

Output:

```text
{'title': 'Learn Python', 'completed': False, 'priority': 'high'}
```

Update an existing value:

```python
task["completed"] = True

print(task)
```

Output:

```text
{'title': 'Learn Python', 'completed': True, 'priority': 'high'}
```

Dictionary keys are unique. Assigning to an existing key replaces its value.

---

## 15. Safely Reading Dictionary Values

This raises a `KeyError` if the key does not exist:

```python
task = {
    "title": "Learn Python",
}

print(task["priority"])
```

Use `get()` when a key may be missing:

```python
task = {
    "title": "Learn Python",
}

priority = task.get("priority")

print(priority)
```

Output:

```text
None
```

You can provide a default value:

```python
priority = task.get("priority", "normal")

print(priority)
```

Output:

```text
normal
```

The `get()` method is useful when working with incomplete or external data.

---

## 16. Checking Dictionary Keys

Use `in` to check whether a key exists:

```python
task = {
    "title": "Learn Python",
    "completed": False,
}

print("title" in task)
print("priority" in task)
```

Output:

```text
True
False
```

By default, `in` checks keys, not values.

```python
print("Learn Python" in task)
```

Output:

```text
False
```

To check values, use:

```python
print("Learn Python" in task.values())
```

Output:

```text
True
```

---

## 17. Dictionary Methods

Use `.keys()` to access the keys:

```python
task = {
    "title": "Learn Python",
    "completed": False,
    "priority": "high",
}

print(task.keys())
```

Use `.values()` to access the values:

```python
print(task.values())
```

Use `.items()` to access key-value pairs:

```python
print(task.items())
```

These methods are especially useful when looping through dictionaries.

---

## 18. Removing Dictionary Values

Use `pop()` to remove a key and return its value:

```python
task = {
    "title": "Learn Python",
    "completed": False,
    "priority": "high",
}

priority = task.pop("priority")

print(f"Removed priority: {priority}")
print(task)
```

Output:

```text
Removed priority: high
{'title': 'Learn Python', 'completed': False}
```

Use `del` to remove a key:

```python
del task["completed"]

print(task)
```

Use `clear()` to remove all key-value pairs:

```python
task.clear()

print(task)
```

Output:

```text
{}
```

---

# 19. Sets

A set stores unique values.

Create a set with curly braces:

```python
tags = {"python", "beginner", "cli"}
```

A set automatically removes duplicates:

```python
tags = {
    "python",
    "beginner",
    "python",
    "cli",
}

print(tags)
```

The output order may vary, but `"python"` will appear only once.

Sets are useful when:

- Duplicate values should not be stored.
- You need to test membership frequently.
- The order of items is not important.
- You want to compare groups of values.

---

## 20. Adding and Removing Set Items

Add an item with `add()`:

```python
tags = {"python", "beginner"}

tags.add("cli")

print(tags)
```

Remove an item with `remove()`:

```python
tags.remove("beginner")

print(tags)
```

`remove()` raises a `KeyError` if the item does not exist.

Use `discard()` when you want to avoid an error:

```python
tags.discard("advanced")
```

If `"advanced"` is missing, nothing happens.

Remove all items:

```python
tags.clear()
```

---

## 21. Set Membership

Sets are particularly useful for membership tests:

```python
allowed_roles = {"admin", "editor", "viewer"}

role = "editor"

if role in allowed_roles:
    print("Access allowed.")
```

Output:

```text
Access allowed.
```

For large collections, membership checks in a set are generally faster than membership checks in a list.

However, sets do not replace lists in every situation.

Use a list when:

- Order matters.
- Duplicate values are meaningful.
- You need index-based access.

Use a set when:

- Values must be unique.
- Order does not matter.
- Fast membership checking is useful.

---

## 22. Set Operations

Sets support mathematical operations.

Create two sets:

```python
python_topics = {"variables", "lists", "functions"}
completed_topics = {"variables", "lists"}
```

### Union

The union combines values from both sets:

```python
all_topics = python_topics | completed_topics

print(all_topics)
```

Output:

```text
{'variables', 'lists', 'functions'}
```

### Intersection

The intersection finds values shared by both sets:

```python
shared_topics = python_topics & completed_topics

print(shared_topics)
```

Output:

```text
{'variables', 'lists'}
```

### Difference

The difference finds values in the first set but not the second:

```python
remaining_topics = python_topics - completed_topics

print(remaining_topics)
```

Output:

```text
{'functions'}
```

### Symmetric Difference

The symmetric difference finds values in either set, but not both:

```python
different_topics = python_topics ^ completed_topics

print(different_topics)
```

---

# 23. Looping Through Collections

A `for` loop repeats an action for each item in a collection.

Create:

```text
projects/show_tasks.py
```

Add:

```python
tasks = [
    "Learn Python",
    "Practice collections",
    "Build a CLI tool",
]

for task in tasks:
    print(task)
```

Run it:

```bash
python projects/show_tasks.py
```

Output:

```text
Learn Python
Practice collections
Build a CLI tool
```

The variable `task` refers to one item at a time.

The loop means:

> For every item in `tasks`, execute the indented code.

---

## 24. Looping Through Dictionaries

You can loop through dictionary keys:

```python
task = {
    "title": "Learn Python",
    "completed": False,
    "priority": "high",
}

for key in task:
    print(key)
```

Output:

```text
title
completed
priority
```

Loop through values:

```python
for value in task.values():
    print(value)
```

Loop through keys and values:

```python
for key, value in task.items():
    print(f"{key}: {value}")
```

Output:

```text
title: Learn Python
completed: False
priority: high
```

The `for` loop and indentation will be explored in more detail in Module 3.

---

# 25. Collections Inside Collections

Collections can contain other collections.

A list of dictionaries is a natural way to represent multiple tasks:

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

Access the first task:

```python
print(tasks[0])
```

Output:

```text
{'id': 1, 'title': 'Learn Python', 'completed': False}
```

Access the title inside the first task:

```python
print(tasks[0]["title"])
```

Output:

```text
Learn Python
```

Access the completion status of the second task:

```python
print(tasks[1]["completed"])
```

Output:

```text
True
```

This pattern is important because our final application will store multiple task dictionaries inside a list.

---

# 26. Copying Collections

Be careful when assigning one list to another variable:

```python
original_tasks = ["Learn Python", "Practice loops"]
copied_tasks = original_tasks

copied_tasks.append("Build a CLI tool")

print(original_tasks)
```

Output:

```text
['Learn Python', 'Practice loops', 'Build a CLI tool']
```

Both variables refer to the same list.

To create a shallow copy, use `.copy()`:

```python
original_tasks = ["Learn Python", "Practice loops"]
copied_tasks = original_tasks.copy()

copied_tasks.append("Build a CLI tool")

print(original_tasks)
print(copied_tasks)
```

Output:

```text
['Learn Python', 'Practice loops']
['Learn Python', 'Practice loops', 'Build a CLI tool']
```

You can also copy a list with slicing:

```python
copied_tasks = original_tasks[:]
```

For simple lists, `.copy()` clearly communicates your intention.

---

# 27. Choosing the Right Collection

Use the following general guide:

| Collection | Ordered? | Changeable? | Allows duplicates? | Best for |
|---|---:|---:|---:|---|
| List | Yes | Yes | Yes | A sequence of items |
| Tuple | Yes | No | Yes | Fixed grouped values |
| Dictionary | Insertion order preserved | Yes | Keys must be unique | Named properties |
| Set | No index-based order | Yes | No | Unique values and membership |

### Use a list when:

```python
shopping_list = ["bread", "milk", "apples"]
```

The order and possible duplicates may matter.

### Use a tuple when:

```python
screen_size = (1920, 1080)
```

The values form a fixed group.

### Use a dictionary when:

```python
user = {
    "name": "Ada",
    "email": "ada@example.com",
}
```

The values need descriptive labels.

### Use a set when:

```python
unique_extensions = {".txt", ".py", ".json"}
```

Duplicate values should not be stored.

---

# Mini-Project: Task Collection Manager

We will now build a small program that manages tasks in memory.

This program will not save data to a file yet. It will demonstrate how lists and dictionaries work together.

Create:

```text
projects/task_collection.py
```

Add these complete contents:

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

    print(f"[{status}] {task['id']} - {task['title']}")

completed_count = 0

for task in tasks:
    if task["completed"]:
        completed_count += 1

print()
print(f"Total tasks: {len(tasks)}")
print(f"Completed tasks: {completed_count}")
print(f"Remaining tasks: {len(tasks) - completed_count}")
```

Run it:

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

## How the Task Program Works

The outer list stores multiple task dictionaries:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python variables",
        "completed": True,
    },
]
```

Each task has three properties:

- An integer `id`.
- A string `title`.
- A Boolean `completed`.

This expression accesses the completion status:

```python
task["completed"]
```

This expression accesses the title:

```python
task["title"]
```

This expression accesses the ID:

```python
task["id"]
```

The program uses a `status` variable to choose whether to display `[x]` or `[ ]`.

The `completed_count` variable starts at zero:

```python
completed_count = 0
```

Each completed task increases the count:

```python
completed_count += 1
```

This is a shorter form of:

```python
completed_count = completed_count + 1
```

---

# 28. Updating a Task

Add the following code to the end of `task_collection.py`:

```python
tasks[1]["completed"] = True

print()
print("Updated second task:")
print(tasks[1])
```

The complete file should now be:

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

    print(f"[{status}] {task['id']} - {task['title']}")

completed_count = 0

for task in tasks:
    if task["completed"]:
        completed_count += 1

print()
print(f"Total tasks: {len(tasks)}")
print(f"Completed tasks: {completed_count}")
print(f"Remaining tasks: {len(tasks) - completed_count}")

tasks[1]["completed"] = True

print()
print("Updated second task:")
print(tasks[1])
```

Run it:

```bash
python projects/task_collection.py
```

The second task will now have:

```text
'completed': True
```

Because dictionaries and lists are mutable, the program can update their contents.

---

# 29. Adding a New Task

Add a new dictionary to the list:

```python
new_task = {
    "id": 4,
    "title": "Review the standard library",
    "completed": False,
}

tasks.append(new_task)
```

You can also append the dictionary directly:

```python
tasks.append(
    {
        "id": 4,
        "title": "Review the standard library",
        "completed": False,
    }
)
```

The first approach is often easier to read when the dictionary contains several properties.

---

# 30. Practice Exercises

## Exercise 1: Favorite Foods

Create:

```text
projects/favorite_foods.py
```

Create a list containing at least five foods.

Then:

1. Print the first food.
2. Print the final food.
3. Add a new food.
4. Remove one food.
5. Print the final list.
6. Print the number of foods.

---

## Exercise 2: Contact Information

Create:

```text
projects/contact.py
```

Create a dictionary containing:

- `name`
- `email`
- `phone`
- `city`

Print each value using its key.

Example:

```python
contact = {
    "name": "Ada Lovelace",
    "email": "ada@example.com",
    "phone": "555-0100",
    "city": "London",
}
```

---

## Exercise 3: Product Inventory

Create:

```text
projects/inventory.py
```

Create a list of dictionaries representing products.

Each product should contain:

- `name`
- `price`
- `quantity`

Example:

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

Calculate the value of each product's inventory:

```text
price × quantity
```

Display the result for each product.

---

## Exercise 4: Unique Words

Create:

```text
projects/unique_words.py
```

Create a list containing repeated words:

```python
words = [
    "python",
    "code",
    "python",
    "list",
    "code",
    "python",
]
```

Convert the list to a set and display the unique words.

Also display:

- The number of words in the original list.
- The number of unique words.

---

## Exercise 5: Improve the Task Manager

Modify `task_collection.py` so that it:

1. Adds a `priority` field to every task.
2. Displays each task's priority.
3. Adds a fourth task.
4. Marks the second task as completed.
5. Displays the total number of completed tasks.

Example task:

```python
{
    "id": 1,
    "title": "Learn Python variables",
    "completed": True,
    "priority": "high",
}
```

Expected display:

```text
[x] 1 - Learn Python variables (high)
```

---

# Verification Checklist

Before continuing, confirm that you can:

- [ ] Create a list.
- [ ] Access an item by index.
- [ ] Use a negative index.
- [ ] Change a list item.
- [ ] Add items with `append()`.
- [ ] Insert an item with `insert()`.
- [ ] Remove an item with `remove()`.
- [ ] Remove an item with `pop()`.
- [ ] Use list slicing.
- [ ] Sort a list.
- [ ] Create a tuple.
- [ ] Unpack a tuple.
- [ ] Explain why tuples cannot be changed.
- [ ] Create a dictionary.
- [ ] Read a dictionary value by key.
- [ ] Add and update dictionary values.
- [ ] Use `get()` with a default value.
- [ ] Loop through dictionary items.
- [ ] Create a set.
- [ ] Remove duplicate values with a set.
- [ ] Perform a set union and intersection.
- [ ] Store dictionaries inside a list.
- [ ] Build and run the task collection program.

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
    └── unique_words.py
```

---

# Summary

In this part, you learned how Python stores groups of related values.

Lists are useful for changeable ordered sequences:

```python
tasks = ["Learn Python", "Practice loops"]
```

Tuples are useful for fixed groups of values:

```python
coordinates = (51.5, -0.1)
```

Dictionaries are useful for labeled information:

```python
task = {
    "title": "Learn Python",
    "completed": False,
}
```

Sets are useful for unique values and membership checks:

```python
tags = {"python", "cli", "beginner"}
```

You also learned that collections can be combined:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]
```

This list-of-dictionaries structure will become the foundation of the task manager in the capstone project.
