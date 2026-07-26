# Appendix C: Python Collection Decision Guide

Python provides several built-in collection types for storing groups of values.

The main collection types are:

- Lists.
- Tuples.
- Dictionaries.
- Sets.

The correct choice depends on questions such as:

- Does order matter?
- Should values be changeable?
- Are duplicate values allowed?
- Do you need to look up values by name?
- Do you need fast membership checks?

---

# 1. Quick Comparison

| Collection | Ordered | Changeable | Allows duplicates | Uses indexes | Main purpose |
|---|---:|---:|---:|---:|---|
| List | Yes | Yes | Yes | Yes | A changeable sequence |
| Tuple | Yes | No | Yes | Yes | A fixed group of values |
| Dictionary | Yes* | Yes | Keys must be unique | No numeric indexes | Key-value data |
| Set | No index-based access | Yes | No | No | Unique values and membership |

Modern Python dictionaries preserve insertion order. However, dictionaries should primarily be understood as key-value structures rather than position-based sequences.

---

# 2. Lists

## What Is a List?

A list stores multiple values in a specific order.

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
- Able to contain duplicate values.
- Able to contain different types, although similar types are usually clearer.

Example:

```python
values = [
    "Python",
    42,
    True,
]
```

---

## Accessing List Items

Python list indexes start at zero:

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

The first item is at index `0`.

The final item can be accessed with `-1`:

```python
print(tasks[-1])
```

Output:

```text
Build a CLI tool
```

Negative indexes count from the end:

```text
Index:     0                1                 2
Negative: -3               -2                -1
Value:   Learn Python       Practice loops    Build a CLI tool
```

---

## Changing List Items

Lists are mutable, which means they can be changed after creation.

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

Only the item at index `1` was replaced.

---

## Adding Items to a List

### `append()`

Use `append()` to add one item to the end:

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

---

### `insert()`

Use `insert()` to add an item at a specific index:

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

The first argument is the position.

The second argument is the value.

---

### `extend()`

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

The `extend()` method modifies the existing list.

---

## Removing Items from a List

### `remove()`

Use `remove()` when you know the value:

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

---

### `pop()`

Use `pop()` to remove an item by index and return it:

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

Calling `pop()` without an index removes the final item:

```python
last_task = tasks.pop()
```

---

### `del`

Use `del` to remove an item by index:

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

---

### `clear()`

Use `clear()` to remove every item:

```python
tasks.clear()

print(tasks)
```

Output:

```text
[]
```

The list still exists, but it contains no values.

---

## Checking List Contents

Use `in`:

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

Use `not in`:

```python
if "Build a CLI tool" not in tasks:
    print("That task has not been added.")
```

---

## Finding the List Length

Use `len()`:

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

---

## List Slicing

A slice extracts part of a list:

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

The starting index is included.

The ending index is excluded.

Other examples:

```python
print(tasks[:2])
print(tasks[2:])
print(tasks[:])
print(tasks[-2:])
```

Output:

```text
['Learn Python', 'Practice loops']
['Build a CLI tool', 'Read documentation']
['Learn Python', 'Practice loops', 'Build a CLI tool', 'Read documentation']
['Build a CLI tool', 'Read documentation']
```

---

## Sorting Lists

Sort a list in place:

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

Use `sorted()` to create a new sorted list:

```python
scores = [82, 95, 71, 88]

sorted_scores = sorted(scores)

print(scores)
print(sorted_scores)
```

Output:

```text
[82, 95, 71, 88]
[71, 82, 88, 95]
```

The original list remains unchanged when using `sorted()`.

---

## When to Use a List

Use a list when:

- Order matters.
- The collection will change.
- Duplicate values are allowed or meaningful.
- You need index-based access.
- You need to process values in sequence.

Examples:

```python
shopping_list = [
    "bread",
    "milk",
    "apples",
]
```

```python
scores = [85, 92, 78, 90]
```

```python
tasks = [
    "Learn Python",
    "Practice functions",
]
```

---

# 3. Tuples

## What Is a Tuple?

A tuple is an ordered collection that cannot be changed after creation.

```python
coordinates = (51.5074, -0.1278)
```

Tuples are:

- Ordered.
- Immutable.
- Indexable.
- Able to contain duplicate values.

**Immutable** means that the contents cannot be changed after the tuple is created.

---

## Accessing Tuple Items

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

Negative indexes work with tuples:

```python
print(coordinates[-1])
```

Output:

```text
-0.1278
```

---

## Tuples Cannot Be Changed

This raises a `TypeError`:

```python
coordinates = (51.5074, -0.1278)

coordinates[0] = 40.7128
```

Use a tuple when the values should remain fixed.

---

## Tuple Unpacking

Tuple values can be assigned to separate variables:

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

Lists can also be unpacked:

```python
person = ["Ada", 36]

name, age = person

print(name)
print(age)
```

The number of variables must match the number of values.

This causes an error:

```python
person = ["Ada", 36, "London"]

name, age = person
```

There are three values but only two variables.

---

## One-Item Tuples

A one-item tuple requires a trailing comma:

```python
single_item = ("Python",)

print(type(single_item))
```

Output:

```text
<class 'tuple'>
```

Without the comma, it is a string:

```python
not_a_tuple = ("Python")

print(type(not_a_tuple))
```

Output:

```text
<class 'str'>
```

---

## When to Use a Tuple

Use a tuple when:

- Values form one fixed group.
- The collection should not change.
- You want to communicate immutability.
- The values are naturally treated as one record.

Examples:

```python
screen_size = (1920, 1080)
```

```python
rgb_color = (255, 128, 0)
```

```python
point = (10, 20)
```

```python
date_of_birth = (1990, 5, 17)
```

---

## List or Tuple?

Use a list when values may change:

```python
coordinates = [10, 20]
coordinates[0] = 15
```

Use a tuple when values should remain fixed:

```python
coordinates = (10, 20)
```

The choice communicates intent:

```python
tasks = []
```

suggests a collection that will grow or shrink.

```python
screen_size = (1920, 1080)
```

suggests a fixed pair of related values.

---

# Part 1 Summary

## Use a list for:

```python
tasks = [
    "Learn Python",
    "Practice loops",
]
```

Lists are ordered and changeable.

## Use a tuple for:

```python
coordinates = (10, 20)
```

Tuples are ordered and unchangeable.

## Main comparison

| Feature | List | Tuple |
|---|---:|---:|
| Ordered | Yes | Yes |
| Mutable | Yes | No |
| Indexable | Yes | Yes |
| Duplicates allowed | Yes | Yes |
| Syntax | `[]` | `()` |
| Good for | Changeable sequences | Fixed groups |

The next section is:

# Appendix C, Part 2: Dictionaries and Sets

It will cover:

- Key-value data.
- Adding and updating dictionary values.
- Safe dictionary lookup.
- Dictionary iteration.
- Unique values.
- Set membership.
- Union, intersection, and difference.

---

# Appendix C, Part 2 of 3: Dictionaries and Sets

This is the second section of Appendix C.

In Part 1, you learned about:

- Lists.
- Tuples.
- Indexing.
- Slicing.
- Mutability and immutability.
- Adding and removing list items.

This section covers:

- Dictionaries.
- Dictionary keys and values.
- Safe dictionary lookup.
- Dictionary iteration.
- Sets.
- Set membership.
- Set operations.

---

# 1. Dictionaries

## What Is a Dictionary?

A dictionary stores data as key-value pairs.

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

Each key identifies a value:

```text
"id"        → 1
"title"     → "Learn Python"
"completed" → False
```

A dictionary is useful when values need descriptive labels.

Compare:

```python
task = [
    1,
    "Learn Python",
    False,
]
```

with:

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

The dictionary makes the meaning of each value clear.

---

## Creating a Dictionary

Use curly braces:

```python
person = {
    "name": "Ada Lovelace",
    "age": 36,
    "city": "London",
}
```

Keys are usually strings, but they can also be other immutable types.

Common key types include:

```python
"user_id"
42
(10, 20)
```

In beginner and application code, string keys are the most common.

---

## Accessing Dictionary Values

Use a key inside square brackets:

```python
person = {
    "name": "Ada Lovelace",
    "age": 36,
    "city": "London",
}

print(person["name"])
print(person["age"])
```

Output:

```text
Ada Lovelace
36
```

The key must exist.

This causes a `KeyError`:

```python
print(person["email"])
```

because `"email"` is not present.

---

## Adding a Key-Value Pair

Assign a new key:

```python
person["email"] = "ada@example.com"
```

The dictionary now contains:

```python
{
    "name": "Ada Lovelace",
    "age": 36,
    "city": "London",
    "email": "ada@example.com",
}
```

---

## Updating a Value

Assign to an existing key:

```python
person["city"] = "Oxford"
```

The old value is replaced.

```python
person["age"] = 37
```

Dictionaries are mutable, so values can be changed after creation.

---

## Safe Lookup with `get()`

Use `.get()` when a key might not exist:

```python
email = person.get("email")
```

If the key is missing, `.get()` returns:

```python
None
```

You can provide a default value:

```python
phone = person.get("phone", "No phone number")
```

If `"phone"` is missing, the result is:

```text
No phone number
```

This is often safer than using square brackets for optional fields.

---

## Checking Whether a Key Exists

Use `in`:

```python
if "email" in person:
    print("Email address exists.")
```

Use `not in`:

```python
if "phone" not in person:
    print("No phone number saved.")
```

When used directly with a dictionary, `in` checks keys.

```python
print("name" in person)
```

This checks whether `"name"` is a key.

---

## Checking Dictionary Values

To check whether a value exists, use `.values()`:

```python
if "Ada Lovelace" in person.values():
    print("Name found.")
```

This checks values rather than keys.

---

# 2. Dictionary Methods

## `.keys()`

Returns the dictionary's keys:

```python
person = {
    "name": "Ada",
    "age": 36,
}

print(person.keys())
```

You can loop through the keys:

```python
for key in person.keys():
    print(key)
```

Output:

```text
name
age
```

The following is also valid:

```python
for key in person:
    print(key)
```

---

## `.values()`

Returns the values:

```python
for value in person.values():
    print(value)
```

Output:

```text
Ada
36
```

---

## `.items()`

Returns key-value pairs:

```python
for key, value in person.items():
    print(f"{key}: {value}")
```

Output:

```text
name: Ada
age: 36
```

This is the most common way to process both keys and values together.

---

# 3. Removing Dictionary Values

## `.pop()`

Remove a key and return its value:

```python
person = {
    "name": "Ada",
    "age": 36,
    "city": "London",
}

city = person.pop("city")

print(city)
print(person)
```

Output:

```text
London
{'name': 'Ada', 'age': 36}
```

Provide a default if the key may be missing:

```python
phone = person.pop("phone", None)
```

This returns `None` instead of raising an error.

---

## `del`

Remove a key:

```python
del person["age"]
```

`del` raises a `KeyError` if the key does not exist.

---

## `.clear()`

Remove all key-value pairs:

```python
person.clear()

print(person)
```

Output:

```text
{}
```

---

# 4. Dictionary Length

Use `len()`:

```python
person = {
    "name": "Ada",
    "age": 36,
    "city": "London",
}

print(len(person))
```

Output:

```text
3
```

For a dictionary, `len()` counts the number of keys.

---

# 5. Dictionaries with Different Value Types

A dictionary can store values of different types:

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
    "priority": "high",
    "tags": ["python", "beginner"],
}
```

This is useful for records that contain several kinds of information.

The values can be accessed normally:

```python
print(task["id"])
print(task["title"])
print(task["completed"])
print(task["tags"])
```

---

# 6. Lists of Dictionaries

A common application structure is a list containing dictionaries.

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

Each dictionary stores one task's fields.

Access the first task:

```python
print(tasks[0])
```

Access the first task's title:

```python
print(tasks[0]["title"])
```

Output:

```text
Learn Python
```

Loop through the tasks:

```python
for task in tasks:
    print(task["title"])
```

Output:

```text
Learn Python
Build a CLI tool
```

This is the main data structure used by the capstone task manager.

---

# 7. Nested Dictionaries

Dictionaries can contain other dictionaries:

```python
users = {
    "ada": {
        "name": "Ada Lovelace",
        "active": True,
    },
    "grace": {
        "name": "Grace Hopper",
        "active": True,
    },
}
```

Access nested values:

```python
print(users["ada"]["name"])
```

Output:

```text
Ada Lovelace
```

Nested structures are useful, but excessive nesting can make code difficult to read. Use clear names and focused functions.

---

# 8. Sets

## What Is a Set?

A set stores unique values.

```python
tags = {
    "python",
    "cli",
    "beginner",
}
```

If the same value is included more than once, the set keeps only one copy:

```python
tags = {
    "python",
    "python",
    "cli",
}

print(tags)
```

The output order may vary, but `"python"` appears only once.

---

## Creating an Empty Set

This creates an empty dictionary:

```python
empty_value = {}
```

This creates an empty set:

```python
empty_set = set()
```

The distinction is important.

---

## Adding Set Values

Use `.add()`:

```python
tags = {"python", "cli"}

tags.add("beginner")

print(tags)
```

The set now contains `"beginner"`.

Adding an existing value does not create a duplicate:

```python
tags.add("python")
```

The set still contains one `"python"` value.

---

## Removing Set Values

Use `.remove()`:

```python
tags.remove("cli")
```

If the value is missing, `.remove()` raises a `KeyError`.

Use `.discard()` when the value may not exist:

```python
tags.discard("advanced")
```

If `"advanced"` is missing, nothing happens.

Remove every item:

```python
tags.clear()
```

---

# 9. Set Membership

Sets are useful for checking whether a value exists:

```python
allowed_roles = {
    "admin",
    "editor",
    "viewer",
}

role = "editor"

if role in allowed_roles:
    print("Access allowed.")
```

Output:

```text
Access allowed.
```

For large collections, membership checks in a set are generally faster than membership checks in a list.

---

# 10. List Versus Set Membership

List:

```python
allowed_roles = [
    "admin",
    "editor",
    "viewer",
]

if "editor" in allowed_roles:
    print("Access allowed.")
```

Set:

```python
allowed_roles = {
    "admin",
    "editor",
    "viewer",
}

if "editor" in allowed_roles:
    print("Access allowed.")
```

Both versions work.

Choose a list when:

- Order matters.
- Duplicates are allowed.
- You need index access.

Choose a set when:

- Values must be unique.
- Order is not important.
- Membership checking is frequent.

---

# 11. Set Operations

Set operations are useful for comparing groups of values.

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

---

## Union

The union combines values from both sets:

```python
all_topics = python_topics | completed_topics

print(all_topics)
```

Possible result:

```text
{'variables', 'lists', 'functions'}
```

The order may vary.

Using a method:

```python
all_topics = python_topics.union(completed_topics)
```

---

## Intersection

The intersection finds values shared by both sets:

```python
shared_topics = python_topics & completed_topics

print(shared_topics)
```

Result:

```text
{'variables', 'lists'}
```

Using a method:

```python
shared_topics = python_topics.intersection(
    completed_topics
)
```

---

## Difference

The difference finds values in the first set but not the second:

```python
remaining_topics = python_topics - completed_topics

print(remaining_topics)
```

Result:

```text
{'functions'}
```

Using a method:

```python
remaining_topics = python_topics.difference(
    completed_topics
)
```

---

## Symmetric Difference

The symmetric difference finds values that appear in one set but not both:

```python
different_topics = python_topics ^ completed_topics

print(different_topics)
```

If both sets contain the same value, that value is excluded.

Using a method:

```python
different_topics = python_topics.symmetric_difference(
    completed_topics
)
```

---

# 12. Comparing Set Relationships

You can check whether one set is contained in another.

```python
all_topics = {
    "variables",
    "lists",
    "functions",
    "files",
}

completed_topics = {
    "variables",
    "lists",
}
```

Check whether all completed topics are included:

```python
print(completed_topics.issubset(all_topics))
```

Output:

```text
True
```

Check whether one set contains another:

```python
print(all_topics.issuperset(completed_topics))
```

Output:

```text
True
```

Check whether sets share no values:

```python
first = {"a", "b"}
second = {"x", "y"}

print(first.isdisjoint(second))
```

Output:

```text
True
```

---

# 13. Converting Between Collections

## List to Set

Convert a list to a set to remove duplicates:

```python
words = [
    "python",
    "code",
    "python",
    "list",
]

unique_words = set(words)

print(unique_words)
```

The order is not guaranteed.

---

## Set to List

```python
tags = {"python", "cli"}

tag_list = list(tags)
```

The resulting list may not have a predictable order.

If you need sorted output:

```python
tag_list = sorted(tags)
```

---

## Tuple to List

```python
coordinates = (10, 20)

coordinate_list = list(coordinates)
```

---

## List to Tuple

```python
values = [10, 20]

value_tuple = tuple(values)
```

---

# 14. Copying Dictionaries and Sets

Assignment creates another reference to the same object:

```python
original = {
    "name": "Ada",
}

copy = original

copy["name"] = "Grace"

print(original)
```

Output:

```text
{'name': 'Grace'}
```

Use `.copy()` for a shallow copy:

```python
original = {
    "name": "Ada",
}

copy = original.copy()

copy["name"] = "Grace"

print(original)
print(copy)
```

Output:

```text
{'name': 'Ada'}
{'name': 'Grace'}
```

Sets also support `.copy()`:

```python
original_tags = {"python", "cli"}
copied_tags = original_tags.copy()
```

---

# 15. Dictionary Decision Examples

## User Profile

```python
user = {
    "name": "Ada Lovelace",
    "email": "ada@example.com",
    "active": True,
}
```

Use a dictionary because each value has a named field.

## Product

```python
product = {
    "name": "Notebook",
    "price": 4.50,
    "quantity": 10,
}
```

Use a dictionary because the fields describe one product.

## Configuration

```python
configuration = {
    "theme": "dark",
    "font_size": 14,
    "notifications": True,
}
```

Use a dictionary because settings are accessed by name.

---

# 16. Set Decision Examples

## Unique File Extensions

```python
extensions = {
    ".txt",
    ".pdf",
    ".jpg",
}
```

## Registered Usernames

```python
usernames = {
    "ada",
    "grace",
    "linus",
}
```

## Unique Words

```python
words = ["python", "code", "python"]

unique_words = set(words)
```

---

# 17. Dictionary and Set Comparison

| Requirement | Dictionary | Set |
|---|---:|---:|
| Store key-value pairs | Yes | No |
| Store unique values | Keys only | Yes |
| Look up by key | Yes | No |
| Check membership | Keys | Values |
| Store labels | Yes | No |
| Remove duplicates | Not generally | Yes |

Use a dictionary:

```python
prices = {
    "notebook": 4.50,
    "pen": 1.25,
}
```

Use a set:

```python
products = {
    "notebook",
    "pen",
}
```

---

# 18. Part 2 Summary

## Use a dictionary when:

```python
task = {
    "title": "Learn Python",
    "completed": False,
}
```

You need named fields and lookup by key.

## Use a set when:

```python
tags = {"python", "cli"}
```

You need unique values and membership checks.

## Main comparison

| Feature | Dictionary | Set |
|---|---:|---:|
| Stores key-value pairs | Yes | No |
| Stores unique values | Keys unique | Values unique |
| Mutable | Yes | Yes |
| Numeric indexing | No | No |
| Main syntax | `{key: value}` | `{value1, value2}` |
| Empty form | `{}` | `set()` |

The next section is:

# Appendix C, Part 3: Choosing the Right Collection

It will cover:

- Collection decision rules.
- Lists versus tuples.
- Lists versus sets.
- Dictionaries versus lists.
- Nested collections.
- Performance considerations.
- Common collection mistakes.

---

# Appendix C, Part 3 of 3: Choosing the Right Collection

This is the final section of Appendix C.

You have already learned:

- **Part 1:** Lists and tuples.
- **Part 2:** Dictionaries and sets.

This section provides decision rules, comparisons, practical examples, performance guidance, and common mistakes.

---

# 1. The Collection Decision Process

When choosing a collection, ask these questions:

1. Do I need key-value labels?
2. Must the values be unique?
3. Does order matter?
4. Will the collection change?
5. Do I need numeric index access?
6. Will I perform frequent membership checks?

Use the following general guide:

```text
Need named fields?
    Yes → Dictionary

Need unique values?
    Yes → Set

Need a fixed, unchangeable group?
    Yes → Tuple

Otherwise
    → List
```

---

# 2. Use a List for Changeable Sequences

Use a list when you need an ordered collection that can grow, shrink, or be updated.

```python
tasks = [
    "Learn Python",
    "Practice loops",
    "Build a CLI tool",
]
```

Lists are appropriate for:

- Shopping lists.
- Task lists.
- Scores.
- Search results.
- Menu options.
- Ordered records.

Example:

```python
tasks.append("Read documentation")
tasks.remove("Practice loops")
```

The order remains meaningful.

---

# 3. Use a Tuple for Fixed Groups

Use a tuple when values belong together and should not change.

```python
coordinates = (51.5074, -0.1278)
```

Good tuple examples:

```python
screen_size = (1920, 1080)
rgb_color = (255, 128, 0)
point = (10, 20)
```

A tuple communicates:

> These values form one fixed group.

A list communicates:

> These values form a collection that may change.

---

# 4. Use a Dictionary for Named Fields

Use a dictionary when one object has multiple properties.

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

A dictionary is clearer than a positional list:

```python
task = [
    1,
    "Learn Python",
    False,
]
```

With the list, the reader must remember what each position means.

With the dictionary, the field names explain the data.

---

# 5. Use a Set for Unique Values

Use a set when duplicates should not exist.

```python
file_extensions = {
    ".txt",
    ".pdf",
    ".jpg",
}
```

Adding an existing value does not create a duplicate:

```python
file_extensions.add(".pdf")
```

Sets are useful for:

- Unique tags.
- Supported file extensions.
- Registered usernames.
- Permission names.
- Membership checks.

---

# 6. Lists Versus Tuples

| Requirement | List | Tuple |
|---|---:|---:|
| Ordered | Yes | Yes |
| Mutable | Yes | No |
| Indexable | Yes | Yes |
| Duplicate values | Allowed | Allowed |
| Good for changing data | Yes | No |
| Good for fixed data | Sometimes | Yes |

Use a list:

```python
shopping_list = [
    "bread",
    "milk",
]
```

Use a tuple:

```python
latitude_longitude = (
    51.5074,
    -0.1278,
)
```

---

# 7. Lists Versus Sets

| Requirement | List | Set |
|---|---:|---:|
| Preserve sequence order | Yes | No index-based order |
| Allow duplicates | Yes | No |
| Numeric indexes | Yes | No |
| Fast membership checks | Usually slower for large collections | Usually faster |
| Sort directly | Yes | Convert or use `sorted()` |
| Main use | Ordered sequence | Unique values |

Use a list:

```python
menu_items = [
    "Add",
    "List",
    "Quit",
]
```

Use a set:

```python
valid_commands = {
    "add",
    "list",
    "quit",
}
```

The menu needs order.

The valid-command collection mainly needs membership checking.

---

# 8. Dictionaries Versus Lists

Use a list when each item is simply a value:

```python
colors = [
    "red",
    "green",
    "blue",
]
```

Use a dictionary when values need labels:

```python
person = {
    "name": "Ada",
    "age": 36,
    "city": "London",
}
```

A dictionary is especially appropriate when you need to look up information by a meaningful key:

```python
prices = {
    "notebook": 4.50,
    "pen": 1.25,
}

print(prices["notebook"])
```

---

# 9. Dictionaries Versus Sets

A dictionary maps keys to values:

```python
prices = {
    "notebook": 4.50,
    "pen": 1.25,
}
```

A set stores unique values:

```python
products = {
    "notebook",
    "pen",
}
```

Use a dictionary when you need to answer:

> What value belongs to this key?

Use a set when you need to answer:

> Is this value present?

---

# 10. The Task Manager Data Structure

The capstone uses a list of dictionaries:

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

This structure is appropriate because:

- There are multiple tasks.
- Tasks have an order for display.
- Each task has named fields.
- Tasks can be added and removed.
- Each task has different types of values.

Access the first task:

```python
print(tasks[0])
```

Access the first task's title:

```python
print(tasks[0]["title"])
```

Loop through tasks:

```python
for task in tasks:
    print(task["title"])
```

---

# 11. Nested Collections

Collections can contain other collections.

## List of Dictionaries

```python
products = [
    {
        "name": "Notebook",
        "price": 4.50,
    },
    {
        "name": "Pen",
        "price": 1.25,
    },
]
```

## Dictionary of Lists

```python
student = {
    "name": "Ada",
    "subjects": [
        "Python",
        "Mathematics",
    ],
}
```

Access a subject:

```python
print(student["subjects"][0])
```

Output:

```text
Python
```

## Dictionary of Dictionaries

```python
users = {
    "ada": {
        "name": "Ada Lovelace",
        "active": True,
    },
    "grace": {
        "name": "Grace Hopper",
        "active": True,
    },
}
```

Access a nested value:

```python
print(users["ada"]["name"])
```

Output:

```text
Ada Lovelace
```

Nested structures are useful, but too many levels can make code difficult to understand.

---

# 12. Collection Performance

Performance describes how much time or memory an operation requires.

For beginner programs, clarity is usually more important than tiny performance differences. However, choosing the correct collection can matter for larger applications.

## List Membership

```python
items = ["a", "b", "c"]

if "b" in items:
    print("Found")
```

Python may check items one at a time.

## Set Membership

```python
items = {"a", "b", "c"}

if "b" in items:
    print("Found")
```

Sets are generally optimized for membership checks.

Use a set when:

- The collection is large.
- Membership checks happen frequently.
- Ordering is not important.
- Duplicate values are not wanted.

---

# 13. Dictionary Lookup

Dictionaries are useful for lookup by key:

```python
users = {
    "ada": "Ada Lovelace",
    "grace": "Grace Hopper",
}

print(users["ada"])
```

Output:

```text
Ada Lovelace
```

If you frequently search a list for a matching identifier:

```python
for task in tasks:
    if task["id"] == task_id:
        matching_task = task
        break
```

you may eventually consider a dictionary indexed by ID:

```python
tasks_by_id = {
    1: {
        "title": "Learn Python",
        "completed": False,
    },
    2: {
        "title": "Build a CLI tool",
        "completed": True,
    },
}
```

Now lookup is direct:

```python
task = tasks_by_id[1]
```

For the beginner capstone, a list of dictionaries is easier to understand and sufficient for a small task collection.

---

# 14. Removing Duplicates

Convert a list to a set:

```python
words = [
    "python",
    "code",
    "python",
    "list",
    "code",
]

unique_words = set(words)

print(unique_words)
```

The duplicates are removed.

If you need a sorted list afterward:

```python
unique_words = sorted(set(words))
```

Output:

```text
['code', 'list', 'python']
```

If you need to preserve the original order while removing duplicates, use:

```python
words = [
    "python",
    "code",
    "python",
    "list",
    "code",
]

unique_words = list(dict.fromkeys(words))

print(unique_words)
```

Output:

```text
['python', 'code', 'list']
```

This works because dictionary keys are unique and preserve insertion order.

---

# 15. Copying Collections

This does not create an independent list:

```python
original = ["Learn Python"]
copy = original

copy.append("Practice loops")

print(original)
```

Output:

```text
['Learn Python', 'Practice loops']
```

Both variables refer to the same list.

Create a shallow copy:

```python
original = ["Learn Python"]
copy = original.copy()

copy.append("Practice loops")

print(original)
print(copy)
```

Output:

```text
['Learn Python']
['Learn Python', 'Practice loops']
```

The same principle applies to dictionaries and sets:

```python
original_dictionary = {"name": "Ada"}
copied_dictionary = original_dictionary.copy()
```

```python
original_set = {"python", "cli"}
copied_set = original_set.copy()
```

---

# 16. Shallow Copies and Nested Data

A shallow copy copies only the outer collection.

```python
original = {
    "tags": ["python", "cli"],
}

copy = original.copy()

copy["tags"].append("beginner")

print(original)
```

Output:

```python
{'tags': ['python', 'cli', 'beginner']}
```

The nested list is still shared.

For more complex nested structures, use `copy.deepcopy()` carefully:

```python
import copy


original = {
    "tags": ["python", "cli"],
}

copy = copy.deepcopy(original)

copy["tags"].append("beginner")

print(original)
print(copy)
```

Output:

```python
{'tags': ['python', 'cli']}
{'tags': ['python', 'cli', 'beginner']}
```

Do not use deep copies automatically. Use them when independent nested data is actually required.

---

# 17. Common Mistakes

## Mistake 1: Using `{}` for an Empty Set

This creates a dictionary:

```python
value = {}
```

Create an empty set with:

```python
value = set()
```

---

## Mistake 2: Assuming Sets Are Indexable

This is invalid:

```python
tags = {"python", "cli"}

print(tags[0])
```

Sets do not support numeric indexing.

Loop through them instead:

```python
for tag in tags:
    print(tag)
```

Remember that set order should not be relied upon.

---

## Mistake 3: Accessing a Missing Dictionary Key

This may raise a `KeyError`:

```python
task = {
    "title": "Learn Python",
}

print(task["priority"])
```

Use `.get()` when the key may be absent:

```python
priority = task.get("priority", "normal")
```

---

## Mistake 4: Removing a Missing List Value

This raises a `ValueError`:

```python
tasks = ["Learn Python"]

tasks.remove("Practice loops")
```

Check first:

```python
if "Practice loops" in tasks:
    tasks.remove("Practice loops")
```

---

## Mistake 5: Removing a Missing Set Value

This raises a `KeyError`:

```python
tags = {"python"}

tags.remove("advanced")
```

Use `discard()` when the value may not exist:

```python
tags.discard("advanced")
```

---

## Mistake 6: Using a List for Named Fields

Less clear:

```python
task = [1, "Learn Python", False]
```

Clearer:

```python
task = {
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

---

## Mistake 7: Using a Set When Order Matters

Do not use a set for a numbered menu:

```python
menu_items = {
    "Add",
    "List",
    "Quit",
}
```

Use a list:

```python
menu_items = [
    "Add",
    "List",
    "Quit",
]
```

---

## Mistake 8: Modifying a Collection While Iterating

This can cause confusing behavior:

```python
for task in tasks:
    if task["completed"]:
        tasks.remove(task)
```

Safer alternatives include creating a new list:

```python
remaining_tasks = [
    task for task in tasks
    if not task["completed"]
]
```

Or iterating over a copy:

```python
for task in tasks.copy():
    if task["completed"]:
        tasks.remove(task)
```

For beginner code, creating a new filtered list is often clearest.

---

# 18. Practical Decision Table

| Requirement | Recommended collection |
|---|---|
| Ordered values that may change | List |
| Fixed ordered values | Tuple |
| Unique values | Set |
| Named fields for one object | Dictionary |
| Multiple named records | List of dictionaries |
| Lookup by identifier | Dictionary |
| Frequent membership tests | Set |
| Numbered display order | List |
| Immutable coordinates | Tuple |
| JSON task records | List of dictionaries |

---

# 19. Collection Decision Examples

## Example: Shopping List

Requirement:

> Store items in the order they should be purchased and allow items to be added or removed.

Use:

```python
shopping_list = [
    "bread",
    "milk",
    "apples",
]
```

Recommended collection:

```text
List
```

---

## Example: Screen Resolution

Requirement:

> Store a fixed width and height.

Use:

```python
screen_size = (1920, 1080)
```

Recommended collection:

```text
Tuple
```

---

## Example: User Account

Requirement:

> Store a name, email address, and active status.

Use:

```python
user = {
    "name": "Ada",
    "email": "ada@example.com",
    "active": True,
}
```

Recommended collection:

```text
Dictionary
```

---

## Example: Supported File Extensions

Requirement:

> Store unique extensions and check whether an extension is supported.

Use:

```python
supported_extensions = {
    ".txt",
    ".pdf",
    ".jpg",
}
```

Recommended collection:

```text
Set
```

---

## Example: Task Manager

Requirement:

> Store multiple tasks with IDs, titles, and completion states.

Use:

```python
tasks = [
    {
        "id": 1,
        "title": "Learn Python",
        "completed": False,
    }
]
```

Recommended collection:

```text
List of dictionaries
```

---

# 20. Final Collection Cheat Sheet

## List

```python
items = []
```

Use for an ordered, changeable sequence.

## Tuple

```python
items = ()
```

Use for a fixed, ordered group.

## Dictionary

```python
items = {}
```

Use for key-value data.

## Set

```python
items = set()
```

Use for unique values.

---

# 21. Final Decision Flowchart

```text
Do values need labels?
│
├── Yes → Use a dictionary.
│
└── No
    │
    ├── Must values be unique?
    │   │
    │   ├── Yes → Use a set.
    │   │
    │   └── No
    │
    ├── Should values remain unchanged?
    │   │
    │   ├── Yes → Use a tuple.
    │   │
    │   └── No → Use a list.
```

For multiple records with named fields:

```python
records = [
    {
        "id": 1,
        "name": "Example",
    }
]
```

---

# Appendix C Complete

You have now completed all three sections:

```text
Appendix C, Part 1: Lists and tuples
Appendix C, Part 2: Dictionaries and sets
Appendix C, Part 3: Choosing the right collection
```

The main rules are:

- Use a **list** for an ordered, changeable sequence.
- Use a **tuple** for a fixed group of values.
- Use a **dictionary** for labeled key-value data.
- Use a **set** for unique values and membership checks.
- Use a **list of dictionaries** for multiple structured records.
