# Appendix C: Comprehensions, Iterators, Generators, and `itertools` Cheat Sheet

This appendix is a quick-reference guide to Python’s collection-processing tools.

Use it when you need to decide:

- Should this be a normal loop or a comprehension?
- Should I build a list now or yield values lazily?
- Why did my generator return no values the second time?
- Which `itertools` helper fits this stream-processing problem?
- When should I use `Counter`, `defaultdict`, or `deque`?

The core goal is clarity first, efficiency second, cleverness last.

---

# C.1 Choosing the Right Collection Tool

| Need | Recommended tool |
|---|---|
| Build a list from a simple transformation | List comprehension |
| Build a dictionary from key-value pairs | Dictionary comprehension |
| Keep only unique values | Set comprehension |
| Process values one at a time | Generator function or generator expression |
| Count repeated values | `collections.Counter` |
| Group values by a key | `collections.defaultdict` |
| Keep a bounded recent history | `collections.deque(maxlen=...)` |
| Combine iterables lazily | `itertools.chain()` |
| Take only the first N values | `itertools.islice()` |
| Filter out matching values | `itertools.filterfalse()` |
| Create fixed-length chunks | `itertools.batched()` on Python 3.12+ |
| Loop through items normally | `for` loop |

---

# C.2 List Comprehensions

A list comprehension creates a list from an iterable.

## Basic Form

```python
result = [expression for item in iterable]
```

Example:

```python
titles = [project.name for project in projects]
```

Equivalent loop:

```python
titles: list[str] = []

for project in projects:
    titles.append(project.name)
```

## Filtered Form

```python
result = [
    expression
    for item in iterable
    if condition
]
```

Example:

```python
active_project_names = [
    project.name
    for project in projects
    if project.status == "active"
]
```

Equivalent loop:

```python
active_project_names: list[str] = []

for project in projects:
    if project.status == "active":
        active_project_names.append(project.name)
```

## Conditional Expression in the Output

Use a conditional expression when every item belongs in the output but the output value differs.

```python
availability_labels = [
    "available" if not item.is_checked_out else "checked out"
    for item in library
]
```

Do not confuse this with a filtering condition:

```python
# Filters out checked-out items.
available_titles = [
    item.title
    for item in library
    if not item.is_checked_out
]
```

---

# C.3 Dictionary Comprehensions

A dictionary comprehension builds key-value mappings.

## Basic Form

```python
result = {
    key_expression: value_expression
    for item in iterable
}
```

Example:

```python
projects_by_id = {
    project.id: project
    for project in projects
}
```

Then:

```python
project = projects_by_id["project-123"]
```

## Filtering a Dictionary Comprehension

```python
active_projects_by_id = {
    project.id: project
    for project in projects
    if project.status == "active"
}
```

## Duplicate Key Warning

Duplicate keys overwrite previous values:

```python
records = [
    {"id": "project-123", "name": "First"},
    {"id": "project-123", "name": "Second"},
]

projects_by_id = {
    record["id"]: record
    for record in records
}

print(projects_by_id)
```

Output:

```text
{'project-123': {'id': 'project-123', 'name': 'Second'}}
```

If duplicates are invalid, validate explicitly:

```python
projects_by_id: dict[str, dict[str, str]] = {}

for record in records:
    project_id = record["id"]

    if project_id in projects_by_id:
        raise ValueError(f'Duplicate project ID "{project_id}".')

    projects_by_id[project_id] = record
```

---

# C.4 Set Comprehensions

A set comprehension keeps unique values.

```python
authors = {
    item.author
    for item in library
}
```

Example:

```python
statuses = {
    project.status
    for project in projects
}

print(statuses)
```

Possible output:

```text
{'active', 'archived', 'paused'}
```

Sets are useful for:

- Unique tags
- Unique authors
- Unique status values
- Membership checks
- Tracking visited pagination tokens or page numbers

Example pagination safety:

```python
visited_page_numbers: set[int] = set()

if page_number in visited_page_numbers:
    raise ValueError("Pagination repeated a page number.")

visited_page_numbers.add(page_number)
```

For stable display output, sort a set:

```python
for status in sorted(statuses):
    print(status)
```

---

# C.5 When a Normal Loop Is Better

A comprehension is not always clearer.

Use a normal loop when you need:

- Multiple statements
- Logging
- Error handling
- Multiple branches
- Intermediate names
- Early exit
- Complex validation

## Prefer a Loop Here

```python
projects_by_id: dict[str, Project] = {}

for project in projects:
    if project.id in projects_by_id:
        raise ValueError(f'Duplicate project ID "{project.id}".')

    projects_by_id[project.id] = project
```

Trying to force that logic into a comprehension would hide important behavior.

A useful rule:

> If the comprehension needs a comment to explain its control flow, consider a regular loop.

---

# C.6 Generator Expressions

A generator expression is the lazy counterpart to a list comprehension.

## List Comprehension: Eager

```python
titles = [project.name for project in projects]
```

This immediately creates every title and stores them in memory.

## Generator Expression: Lazy

```python
titles = (project.name for project in projects)
```

This creates a generator object. Values are produced only when requested.

```python
print(next(titles))
```

Use generator expressions with aggregation functions:

```python
has_archived_project = any(
    project.status == "archived"
    for project in projects
)

all_projects_active = all(
    project.status == "active"
    for project in projects
)

total_name_length = sum(
    len(project.name)
    for project in projects
)
```

Avoid this unnecessary list:

```python
# Works, but creates a temporary list.
has_archived_project = any(
    [project.status == "archived" for project in projects]
)
```

Prefer:

```python
has_archived_project = any(
    project.status == "archived"
    for project in projects
)
```

---

# C.7 Generator Functions and `yield`

A generator function uses `yield`.

```python
from collections.abc import Iterator


def iter_active_projects(projects: list[Project]) -> Iterator[Project]:
    """Yield active projects one at a time."""
    for project in projects:
        if project.status == "active":
            yield project
```

Usage:

```python
for project in iter_active_projects(projects):
    print(project.name)
```

## `return` in a Generator

A bare `return` stops the generator:

```python
from collections.abc import Iterator


def count_up_to(limit: int) -> Iterator[int]:
    for number in range(1, limit + 1):
        yield number

    return
```

You normally do not need to write the final `return`; reaching the end ends the generator naturally.

Do not manually raise `StopIteration` inside a generator:

```python
# Do not do this.
raise StopIteration
```

Use `return` or simply let the function finish.

---

# C.8 Iterator Consumption

Iterators and generators are usually consumed once.

```python
project_names = (
    project.name
    for project in projects
)

print(list(project_names))
print(list(project_names))
```

Output:

```text
['Website Redesign', 'Mobile App']
[]
```

The first conversion consumed every generated value.

If you need repeated use, create a list intentionally:

```python
project_names = [
    project.name
    for project in projects
]

print(project_names)
print(project_names)
```

Or recreate the generator:

```python
def iter_project_names() -> Iterator[str]:
    for project in projects:
        yield project.name

print(list(iter_project_names()))
print(list(iter_project_names()))
```

---

# C.9 `any()` and `all()`

## `any()`

Returns `True` when at least one value is truthy.

```python
has_active_project = any(
    project.status == "active"
    for project in projects
)
```

## `all()`

Returns `True` only when every value is truthy.

```python
all_projects_have_names = all(
    bool(project.name.strip())
    for project in projects
)
```

## Empty Collection Behavior

```python
any([])  # False
all([])  # True
```

`all([])` is true because no element violates the condition.

If an empty collection should not count as “all valid,” include an explicit check:

```python
all_projects_active = bool(projects) and all(
    project.status == "active"
    for project in projects
)
```

---

# C.10 `enumerate()`

Use `enumerate()` when you need both an index and a value.

```python
for position, project in enumerate(projects, start=1):
    print(f"{position}. {project.name}")
```

Output:

```text
1. Website Redesign
2. Mobile App
```

Avoid manual counters when `enumerate()` is clearer:

```python
# Less clear.
position = 1

for project in projects:
    print(f"{position}. {project.name}")
    position += 1
```

---

# C.11 `zip()`

Use `zip()` to process related iterables in parallel.

```python
project_ids = ["project-001", "project-002"]
project_names = ["Website Redesign", "Mobile App"]

for project_id, name in zip(project_ids, project_names, strict=True):
    print(f"{project_id}: {name}")
```

Output:

```text
project-001: Website Redesign
project-002: Mobile App
```

Use `strict=True` when mismatched lengths indicate a bug:

```python
zip(project_ids, project_names, strict=True)
```

Without `strict=True`, `zip()` silently stops at the shortest iterable.

---

# C.12 `collections.Counter`

`Counter` counts repeated values.

```python
from collections import Counter

statuses = [
    "active",
    "archived",
    "active",
    "paused",
    "active",
]

counts = Counter(statuses)

print(counts)
```

Output:

```text
Counter({'active': 3, 'archived': 1, 'paused': 1})
```

Use it for:

```python
from collections import Counter

projects_by_status = Counter(
    project.status
    for project in projects
)
```

Most common values:

```python
print(projects_by_status.most_common(2))
```

Example output:

```text
[('active', 3), ('archived', 1)]
```

---

# C.13 `collections.defaultdict`

`defaultdict` creates a default value for a missing key.

## Grouping Values

```python
from collections import defaultdict

projects_by_status: defaultdict[str, list[Project]] = defaultdict(list)

for project in projects:
    projects_by_status[project.status].append(project)
```

Equivalent normal-dictionary version:

```python
projects_by_status: dict[str, list[Project]] = {}

for project in projects:
    projects_by_status.setdefault(project.status, []).append(project)
```

`defaultdict` is often cleaner when you control the internal implementation.

For public return values, a regular `dict` can be easier for callers:

```python
return dict(projects_by_status)
```

## Counting with `defaultdict`

```python
from collections import defaultdict

counts: defaultdict[str, int] = defaultdict(int)

for project in projects:
    counts[project.status] += 1
```

Use `Counter` when you only need counting. Use `defaultdict` when grouping or accumulating more complex values.

---

# C.14 `collections.deque`

A `deque` is a double-ended queue.

```python
from collections import deque

recent_events = deque(maxlen=3)

recent_events.append("created project")
recent_events.append("updated project")
recent_events.append("archived project")
recent_events.append("deleted project")

print(recent_events)
```

Output:

```text
deque(['updated project', 'archived project', 'deleted project'], maxlen=3)
```

Useful operations:

```python
queue.append("new item")       # Add right side.
queue.appendleft("urgent")     # Add left side.
queue.pop()                    # Remove right side.
queue.popleft()                # Remove left side.
```

Use a deque for:

- Work queues
- Breadth-first search
- Recent event history
- Sliding windows
- Message processing

Avoid using a list as a queue with `pop(0)` for large queues:

```python
# Inefficient for large lists.
items.pop(0)
```

Prefer:

```python
items.popleft()
```

---

# C.15 `itertools.chain()`

`chain()` joins multiple iterables lazily.

```python
from itertools import chain

north_projects = ["north-1", "north-2"]
south_projects = ["south-1"]

for project_id in chain(north_projects, south_projects):
    print(project_id)
```

Output:

```text
north-1
north-2
south-1
```

For many iterables:

```python
from itertools import chain

project_groups = [
    ["project-001", "project-002"],
    ["project-003"],
    ["project-004", "project-005"],
]

all_project_ids = chain.from_iterable(project_groups)

print(list(all_project_ids))
```

Output:

```text
['project-001', 'project-002', 'project-003', 'project-004', 'project-005']
```

---

# C.16 `itertools.islice()`

`islice()` takes a limited portion of any iterable, including generators.

```python
from itertools import islice

first_three = islice(projects, 3)

for project in first_three:
    print(project.name)
```

Unlike list slicing, it works with lazy streams:

```python
from collections.abc import Iterator
from itertools import islice


def iter_project_ids() -> Iterator[str]:
    page = 1

    while True:
        yield f"project-page-{page}"
        page += 1


first_five = list(islice(iter_project_ids(), 5))

print(first_five)
```

Output:

```text
['project-page-1', 'project-page-2', 'project-page-3', 'project-page-4', 'project-page-5']
```

---

# C.17 `itertools.filterfalse()`

`filterfalse()` keeps values for which a predicate returns false.

```python
from itertools import filterfalse

available_projects = filterfalse(
    lambda project: project.status == "archived",
    projects,
)
```

Equivalent generator expression:

```python
available_projects = (
    project
    for project in projects
    if project.status != "archived"
)
```

Use the version that reads more naturally.

For a more complex condition, prefer a named predicate:

```python
def is_archived(project: Project) -> bool:
    return project.status == "archived"


available_projects = filterfalse(is_archived, projects)
```

---

# C.18 `itertools.batched()`

Python 3.12 introduced `itertools.batched()`.

```python
from itertools import batched

project_ids = [
    "project-001",
    "project-002",
    "project-003",
    "project-004",
    "project-005",
]

for batch in batched(project_ids, 2):
    print(batch)
```

Output:

```text
('project-001', 'project-002')
('project-003', 'project-004')
('project-005',)
```

This is useful when an API supports bulk requests:

```text
POST /projects/bulk
```

and accepts a limited number of IDs in each request.

For Python 3.11 compatibility, define a small helper:

```python
from collections.abc import Iterable, Iterator
from itertools import islice
from typing import TypeVar

Item = TypeVar("Item")


def batched(
    items: Iterable[Item],
    batch_size: int,
) -> Iterator[tuple[Item, ...]]:
    """Yield fixed-size batches from items."""
    if batch_size < 1:
        raise ValueError("Batch size must be at least 1.")

    item_iterator = iter(items)

    while batch := tuple(islice(item_iterator, batch_size)):
        yield batch
```

---

# C.19 `itertools.count()`, `cycle()`, and `repeat()`

These helpers can create infinite iterators.

## `count()`

```python
from itertools import count

for page_number in count(start=1):
    print(page_number)

    if page_number == 3:
        break
```

Output:

```text
1
2
3
```

Useful for sequential page numbers, but ensure a termination condition exists.

## `cycle()`

```python
from itertools import cycle, islice

environments = cycle(["development", "staging", "production"])

print(list(islice(environments, 5)))
```

Output:

```text
['development', 'staging', 'production', 'development', 'staging']
```

## `repeat()`

```python
from itertools import repeat

print(list(repeat("retry", 3)))
```

Output:

```text
['retry', 'retry', 'retry']
```

Use infinite iterators carefully. They must have an external stopping condition.

---

# C.20 Sorting Collections

## `sorted()`

`sorted()` creates a new sorted list.

```python
sorted_projects = sorted(
    projects,
    key=lambda project: project.name.casefold(),
)
```

Use `casefold()` for robust case-insensitive text sorting.

```python
for project in sorted_projects:
    print(project.name)
```

## `list.sort()`

`list.sort()` mutates an existing list and returns `None`.

```python
projects.sort(key=lambda project: project.name.casefold())
```

Do not write:

```python
sorted_projects = projects.sort()
```

`sorted_projects` becomes `None`.

## Multiple Sort Criteria

```python
sorted_projects = sorted(
    projects,
    key=lambda project: (
        project.status,
        project.name.casefold(),
    ),
)
```

---

# C.21 `min()`, `max()`, and `key=`

Find the newest project:

```python
newest_project = max(
    projects,
    key=lambda project: project.created_at,
)
```

Find the shortest project name:

```python
shortest_name_project = min(
    projects,
    key=lambda project: len(project.name),
)
```

For possibly empty collections, provide `default`:

```python
newest_project = max(
    projects,
    key=lambda project: project.created_at,
    default=None,
)
```

---

# C.22 `map()` and `filter()`

Python supports functional helpers:

```python
names = map(lambda project: project.name, projects)
```

```python
active_projects = filter(
    lambda project: project.status == "active",
    projects,
)
```

They are valid, but comprehensions are often more readable:

```python
names = [project.name for project in projects]
```

```python
active_projects = [
    project
    for project in projects
    if project.status == "active"
]
```

Use `map()` especially when passing an existing named function:

```python
normalized_names = map(str.strip, names)
```

Use `filter()` especially when an existing predicate already communicates intent:

```python
active_projects = filter(is_active_project, projects)
```

---

# C.23 Collection-Processing Anti-Patterns

## Building a List Only to Iterate Once

```python
for project in list(
    project
    for project in projects
    if project.status == "active"
):
    print(project.name)
```

Better:

```python
for project in projects:
    if project.status == "active":
        print(project.name)
```

Or:

```python
for project in (
    project
    for project in projects
    if project.status == "active"
):
    print(project.name)
```

The plain loop is often clearest.

---

## Reusing an Exhausted Generator

```python
results = client.iter_projects()

print(len(list(results)))
print(len(list(results)))
```

The second result is zero.

Fix by creating a list if repeated access is genuinely needed:

```python
results = list(client.iter_projects())

print(len(results))
print(len(results))
```

---

## Overly Nested Comprehensions

This is valid but difficult to read:

```python
pairs = [
    (team.name, project.name)
    for organization in organizations
    for team in organization.teams
    for project in team.projects
    if project.status == "active"
]
```

Use a normal loop if the structure needs explanation:

```python
pairs: list[tuple[str, str]] = []

for organization in organizations:
    for team in organization.teams:
        for project in team.projects:
            if project.status == "active":
                pairs.append((team.name, project.name))
```

---

## Modifying a List While Iterating Over It

Avoid:

```python
for project in projects:
    if project.status == "archived":
        projects.remove(project)
```

This can skip values unexpectedly.

Prefer a new list:

```python
active_projects = [
    project
    for project in projects
    if project.status != "archived"
]
```

Or, when mutation is required:

```python
projects[:] = [
    project
    for project in projects
    if project.status != "archived"
]
```

---

# C.24 Collection Tool Decision Checklist

Before choosing a collection-processing pattern, ask:

1. Do I need all values immediately, or one at a time?
2. Could the input be large or unbounded?
3. Will I need to iterate over the result more than once?
4. Is a comprehension still easy to read?
5. Do I need unique values, grouping, counting, or ordering?
6. Can the operation stop early with `any()`, `all()`, or a generator?
7. Does the data need validation before transformation?
8. Would a named helper function make the condition clearer?
