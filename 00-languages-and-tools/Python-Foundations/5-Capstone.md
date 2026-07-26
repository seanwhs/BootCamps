# Part 5A: Capstone Project — Creating the CLI Application

This is **Section 1 of the Capstone Project**.

The capstone will transform the earlier task manager into a structured command-line application named `foundation_cli`.

The completed application will support commands such as:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli organize ./downloads
```

The project will eventually contain:

```text
python-foundations/
├── README.md
├── pyproject.toml
├── src/
│   └── foundation_cli/
│       ├── __init__.py
│       ├── __main__.py
│       ├── cli.py
│       ├── tasks.py
│       ├── storage.py
│       ├── organizer.py
│       └── errors.py
├── data/
│   └── tasks.json
└── tests/
    ├── test_tasks.py
    ├── test_storage.py
    └── test_organizer.py
```

In this section, we will:

- Create the professional project structure.
- Create a Python package.
- Add a project configuration file.
- Run the package with `python -m`.
- Create the first command-line interface.
- Verify that the application starts correctly.

---

# 1. Why Use a `src` Layout?

Instead of keeping application code directly in the project root:

```text
python-foundations/
├── task_manager.py
└── storage.py
```

we will use:

```text
python-foundations/
└── src/
    └── foundation_cli/
        ├── __init__.py
        ├── __main__.py
        └── cli.py
```

This structure provides several benefits:

- Application code is separate from project configuration.
- Tests are separate from application code.
- Imports behave more like an installed package.
- The project can later be published or packaged.
- Different responsibilities can be placed in different modules.

The directory:

```text
foundation_cli
```

is the Python package name.

---

# 2. Creating the Project Directories

From the project root, create these directories.

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

Your structure should now look like:

```text
python-foundations/
├── data/
├── src/
│   └── foundation_cli/
└── tests/
```

The `data` directory will contain task data.

The `src/foundation_cli` directory will contain application code.

The `tests` directory will contain automated tests later.

---

# 3. Creating `pyproject.toml`

The `pyproject.toml` file describes the project and tells Python how to install it.

Create this file in the project root:

```text
pyproject.toml
```

Add these complete contents:

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

## Understanding the Configuration

The `[build-system]` section tells Python which packaging tool to use.

The `[project]` section defines:

- The project name.
- The version.
- A short description.
- The minimum Python version.
- External dependencies.

This project currently uses only the Python standard library, so:

```toml
dependencies = []
```

The `[project.scripts]` section creates a command named:

```bash
foundation
```

It will call:

```python
foundation_cli.cli:main
```

That means:

- Import the `main` function.
- Find it in `foundation_cli.cli`.
- Run it when the `foundation` command is used.

The final section tells the packaging tool that Python packages are located inside:

```text
src/
```

---

# 4. Creating `README.md`

The project configuration refers to a README file, so create:

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
foundation organize ./downloads
```
```

The README provides basic information about the project.

---

# 5. Creating the Package Initialization File

Create:

```text
src/foundation_cli/__init__.py
```

Add:

```python
"""Foundation CLI application."""
```

The `__init__.py` file tells Python that `foundation_cli` is a package.

It can also contain package metadata.

For now, add:

```python
"""Foundation CLI application."""

__version__ = "0.1.0"
```

The package version can be accessed later with:

```python
import foundation_cli

print(foundation_cli.__version__)
```

---

# 6. Creating the Command-Line Module

Create:

```text
src/foundation_cli/cli.py
```

Add these complete contents:

```python
import argparse


def build_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser."""
    parser = argparse.ArgumentParser(
        prog="foundation",
        description="A multi-utility command-line application.",
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

This is the first version of the command-line interface.

---

# 7. Understanding `argparse`

The `argparse` module is part of Python's standard library.

It helps programs:

- Read command-line arguments.
- Display help text.
- Validate command options.
- Show useful error messages.
- Create consistent command interfaces.

This function creates the parser:

```python
def build_parser() -> argparse.ArgumentParser:
```

The parser is configured with:

```python
parser = argparse.ArgumentParser(
    prog="foundation",
    description="A multi-utility command-line application.",
)
```

The `prog` value controls the displayed program name.

The `description` appears in the help output.

This option creates a version flag:

```python
parser.add_argument(
    "--version",
    action="version",
    version="foundation 0.1.0",
)
```

The user will eventually be able to run:

```bash
foundation --version
```

---

# 8. Creating `__main__.py`

To support this command:

```bash
python -m foundation_cli
```

create:

```text
src/foundation_cli/__main__.py
```

Add:

```python
from .cli import main


if __name__ == "__main__":
    main()
```

The dot in:

```python
from .cli import main
```

means:

> Import `main` from the `cli.py` module in this package.

The `__main__.py` file is the entry point used by:

```bash
python -m foundation_cli
```

---

# 9. Installing the Project in Editable Mode

The package needs to be installed into the active virtual environment.

First, make sure the virtual environment is active.

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

### macOS or Linux

```bash
source .venv/bin/activate
```

From the project root, install the project in editable mode:

```bash
python -m pip install --editable .
```

The `--editable` option means that changes to files inside `src/` are immediately used. You do not need to reinstall the project after every code change.

You may see output similar to:

```text
Successfully installed foundation-cli-0.1.0
```

---

# 10. Running the Application

Run the package with:

```bash
python -m foundation_cli
```

Expected output:

```text
usage: foundation [-h] [--version]

A multi-utility command-line application.

options:
  -h, --help  show this help message and exit
  --version   show program's version number and exit
```

You can also explicitly request help:

```bash
python -m foundation_cli --help
```

The result should be similar.

---

# 11. Testing the Version Option

Run:

```bash
python -m foundation_cli --version
```

Expected output:

```text
foundation 0.1.0
```

You can also run the installed command:

```bash
foundation --version
```

Expected output:

```text
foundation 0.1.0
```

If the `foundation` command is not found, confirm that:

- The virtual environment is active.
- The project was installed with `python -m pip install --editable .`.
- You are using the same terminal environment where the installation occurred.

The module command should still work:

```bash
python -m foundation_cli --version
```

---

# 12. Adding the First Subcommands

The application needs subcommands such as:

```text
add
list
complete
remove
organize
```

We will add their structure now, but the actual behavior will be implemented in later capstone sections.

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
        description="A multi-utility command-line application.",
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

    organize_parser = subparsers.add_parser(
        "organize",
        help="Organize files by extension.",
    )
    organize_parser.add_argument(
        "directory",
        help="The directory containing files to organize.",
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

# 13. Testing the Subcommands

Run:

```bash
python -m foundation_cli --help
```

Expected output should now include:

```text
commands:
  add       Create a new task.
  list      List all tasks.
  complete  Mark a task as completed.
  remove    Remove a task.
  organize  Organize files by extension.
```

Test the `add` command:

```bash
python -m foundation_cli add "Learn Python"
```

Expected output:

```text
Selected command: add
```

At this stage, the command is only being parsed. It does not create a task yet.

Test the `list` command:

```bash
python -m foundation_cli list
```

Expected output:

```text
Selected command: list
```

Test the `complete` command:

```bash
python -m foundation_cli complete 1
```

Expected output:

```text
Selected command: complete
```

Test the `remove` command:

```bash
python -m foundation_cli remove 1
```

Expected output:

```text
Selected command: remove
```

Test the `organize` command:

```bash
python -m foundation_cli organize ./downloads
```

Expected output:

```text
Selected command: organize
```

---

# 14. Inspecting Parsed Arguments

For learning purposes, temporarily replace:

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

Notice that `task_id` is already an integer because of:

```python
type=int
```

Restore the command-displaying version afterward:

```python
print(f"Selected command: {arguments.command}")
```

---

# 15. Handling Invalid Command Arguments

Try:

```bash
python -m foundation_cli complete
```

Expected output will be similar to:

```text
usage: foundation complete [-h] task_id
foundation complete: error: the following arguments are required: task_id
```

Try:

```bash
python -m foundation_cli complete abc
```

Expected output will be similar to:

```text
argument task_id: invalid int value: 'abc'
```

`argparse` performs this validation before the application logic runs.

That prevents the rest of the program from receiving an invalid task ID.

---

# 16. Adding Command Dispatch

Instead of printing the selected command, we can dispatch to separate functions.

Replace the `main()` function in:

```text
src/foundation_cli/cli.py
```

with:

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
    elif arguments.command == "organize":
        print(f"Organizing directory: {arguments.directory}")
```

Run the commands again:

```bash
python -m foundation_cli add "Learn Python"
```

```text
Adding task: Learn Python
```

```bash
python -m foundation_cli list
```

```text
Listing tasks.
```

```bash
python -m foundation_cli complete 1
```

```text
Completing task: 1
```

```bash
python -m foundation_cli remove 1
```

```text
Removing task: 1
```

```bash
python -m foundation_cli organize ./downloads
```

```text
Organizing directory: ./downloads
```

This is still temporary behavior. In later sections, each branch will call real application functions.

---

# 17. Current Project Structure

At this stage, your project should look similar to:

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

The earlier learning files may still exist:

```text
python-foundations/
├── projects/
├── src/
└── tests/
```

That is fine.

The capstone application is now located under:

```text
src/foundation_cli/
```

---

# 18. Verification Checklist

Confirm that you can:

- [ ] Create the `src` layout.
- [ ] Create a Python package.
- [ ] Create `pyproject.toml`.
- [ ] Install the project in editable mode.
- [ ] Run `python -m foundation_cli`.
- [ ] Run `python -m foundation_cli --help`.
- [ ] Run `python -m foundation_cli --version`.
- [ ] See the `add` command.
- [ ] See the `list` command.
- [ ] See the `complete` command.
- [ ] See the `remove` command.
- [ ] See the `organize` command.
- [ ] Understand positional command arguments.
- [ ] Observe `argparse` rejecting invalid arguments.
- [ ] Dispatch different commands to different branches.

---

# Part 5A Summary

You created the foundation of the capstone application.

The program now has:

- A package named `foundation_cli`.
- A project configuration file.
- A `python -m foundation_cli` entry point.
- A `foundation` console command.
- Built-in help.
- Version information.
- Five planned subcommands.
- Basic command dispatch.

The current commands only display placeholder messages. The next section will implement the task data model and storage layer.

# Next: Part 5B — Task Logic and JSON Storage

In the next section, we will create:

```text
src/foundation_cli/tasks.py
src/foundation_cli/storage.py
data/tasks.json
```

We will implement:

- Creating tasks.
- Listing tasks.
- Finding tasks by ID.
- Completing tasks.
- Removing tasks.
- Loading tasks from JSON.
- Saving tasks to JSON.
- Connecting the `add` and `list` CLI commands to real data.

---

# Part 5B: Task Logic and JSON Storage

This is **Section 2 of the Capstone Project**.

In Part 5A, you created:

- The `src` project layout.
- The `foundation_cli` package.
- The `pyproject.toml` configuration.
- The `python -m foundation_cli` entry point.
- The initial CLI commands.

The commands currently display placeholder messages. In this section, we will connect the `add` and `list` commands to real task data.

We will create:

```text
src/
└── foundation_cli/
    ├── tasks.py
    └── storage.py

data/
└── tasks.json
```

We will implement:

- Task creation.
- Task lookup.
- Task completion.
- Task removal.
- JSON loading.
- JSON saving.
- The real `add` command.
- The real `list` command.

---

# 1. Designing the Task Data

Each task will be represented as a dictionary:

```python
{
    "id": 1,
    "title": "Learn Python",
    "completed": False,
}
```

The task list will be a list of dictionaries:

```python
[
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

The JSON file will contain the same structure:

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  }
]
```

---

# 2. Creating `tasks.py`

Create:

```text
src/foundation_cli/tasks.py
```

Add these complete contents:

```python
from typing import Any


Task = dict[str, Any]


def create_task(tasks: list[Task], title: str) -> Task:
    """Create a new task and add it to the task list."""
    if not title.strip():
        raise ValueError("Task title cannot be empty.")

    next_id = get_next_id(tasks)

    task: Task = {
        "id": next_id,
        "title": title.strip(),
        "completed": False,
    }

    tasks.append(task)

    return task


def get_next_id(tasks: list[Task]) -> int:
    """Return the next available task ID."""
    if not tasks:
        return 1

    return max(task["id"] for task in tasks) + 1


def find_task(tasks: list[Task], task_id: int) -> Task | None:
    """Find a task by ID."""
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


def complete_task(tasks: list[Task], task_id: int) -> Task:
    """Mark a task as completed."""
    task = find_task(tasks, task_id)

    if task is None:
        raise ValueError(f"No task found with ID {task_id}.")

    if task["completed"]:
        raise ValueError(f"Task {task_id} is already completed.")

    task["completed"] = True

    return task


def remove_task(tasks: list[Task], task_id: int) -> Task:
    """Remove and return a task by ID."""
    task = find_task(tasks, task_id)

    if task is None:
        raise ValueError(f"No task found with ID {task_id}.")

    tasks.remove(task)

    return task


def count_completed(tasks: list[Task]) -> int:
    """Return the number of completed tasks."""
    return sum(
        1 for task in tasks if task["completed"]
    )
```

---

# 3. Understanding `tasks.py`

This module contains application logic.

It does not:

- Read command-line arguments.
- Open JSON files.
- Print menus.
- Decide where the data file is located.

That separation is intentional.

## Creating a Task

```python
def create_task(tasks: list[Task], title: str) -> Task:
```

This function:

1. Validates the title.
2. Finds the next available ID.
3. Creates a dictionary.
4. Adds the dictionary to the list.
5. Returns the new task.

The function rejects empty or whitespace-only titles:

```python
if not title.strip():
    raise ValueError("Task title cannot be empty.")
```

---

## Finding a Task

```python
def find_task(tasks: list[Task], task_id: int) -> Task | None:
```

This function returns:

- The matching task dictionary.
- `None` if the ID does not exist.

---

## Completing a Task

```python
def complete_task(tasks: list[Task], task_id: int) -> Task:
```

This function raises a `ValueError` when:

- The task does not exist.
- The task is already completed.

The command-line layer will catch and display those errors later.

---

## Removing a Task

```python
def remove_task(tasks: list[Task], task_id: int) -> Task:
```

The function removes the task from the list and returns it.

Returning the removed task allows the caller to display its title or ID.

---

# 4. Testing `tasks.py` Manually

Create:

```text
src/foundation_cli/test_tasks_manual.py
```

Add:

```python
from .tasks import (
    complete_task,
    count_completed,
    create_task,
    remove_task,
)


def main() -> None:
    tasks = []

    first_task = create_task(tasks, "Learn Python")
    second_task = create_task(tasks, "Build a CLI")

    print("Created:")
    print(first_task)
    print(second_task)

    complete_task(tasks, first_task["id"])

    print()
    print("After completing the first task:")
    print(tasks)

    print()
    print(f"Completed tasks: {count_completed(tasks)}")

    removed_task = remove_task(tasks, second_task["id"])

    print()
    print(f"Removed: {removed_task}")
    print(f"Remaining tasks: {tasks}")


if __name__ == "__main__":
    main()
```

Because this file uses a relative import, run it as a module from the project root:

```bash
python -m foundation_cli.test_tasks_manual
```

Expected output should resemble:

```text
Created:
{'id': 1, 'title': 'Learn Python', 'completed': False}
{'id': 2, 'title': 'Build a CLI', 'completed': False}

After completing the first task:
[{'id': 1, 'title': 'Learn Python', 'completed': True}, {'id': 2, 'title': 'Build a CLI', 'completed': False}]

Completed tasks: 1

Removed: {'id': 2, 'title': 'Build a CLI', 'completed': False}
Remaining tasks: [{'id': 1, 'title': 'Learn Python', 'completed': True}]
```

This test file is temporary. You may delete it after verification.

---

# 5. Creating `storage.py`

Create:

```text
src/foundation_cli/storage.py
```

Add these complete contents:

```python
import json
from pathlib import Path
from typing import Any


Task = dict[str, Any]

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIRECTORY = PROJECT_ROOT / "data"
DATA_FILE = DATA_DIRECTORY / "tasks.json"


def load_tasks(file_path: Path = DATA_FILE) -> list[Task]:
    """Load tasks from a JSON file."""
    if not file_path.exists():
        return []

    try:
        with file_path.open("r", encoding="utf-8") as file:
            data = json.load(file)
    except json.JSONDecodeError as error:
        raise ValueError(
            f"Task data is not valid JSON: {file_path}"
        ) from error
    except OSError as error:
        raise OSError(
            f"Could not read task data: {file_path}"
        ) from error

    if not isinstance(data, list):
        raise ValueError("Task data must be a JSON list.")

    for item in data:
        validate_task(item)

    return data


def save_tasks(
    tasks: list[Task],
    file_path: Path = DATA_FILE,
) -> None:
    """Save tasks to a JSON file."""
    try:
        file_path.parent.mkdir(parents=True, exist_ok=True)

        with file_path.open("w", encoding="utf-8") as file:
            json.dump(tasks, file, indent=2)
            file.write("\n")
    except OSError as error:
        raise OSError(
            f"Could not save task data: {file_path}"
        ) from error


def validate_task(value: object) -> None:
    """Validate one task dictionary."""
    if not isinstance(value, dict):
        raise ValueError("Each task must be a JSON object.")

    required_keys = {"id", "title", "completed"}

    if not required_keys.issubset(value):
        raise ValueError(
            "Each task must contain id, title, and completed."
        )

    if not isinstance(value["id"], int):
        raise ValueError("Task IDs must be integers.")

    if not isinstance(value["title"], str):
        raise ValueError("Task titles must be strings.")

    if not isinstance(value["completed"], bool):
        raise ValueError("Task completion values must be Boolean.")
```

---

# 6. Understanding the Data File Path

These lines locate the project root:

```python
PROJECT_ROOT = Path(__file__).resolve().parents[2]
```

The file is located approximately here:

```text
python-foundations/
└── src/
    └── foundation_cli/
        └── storage.py
```

The parent levels are:

```text
parents[0] → src/foundation_cli
parents[1] → src
parents[2] → python-foundations
```

The data file is then defined as:

```python
DATA_FILE = DATA_DIRECTORY / "tasks.json"
```

The final path is:

```text
python-foundations/data/tasks.json
```

This means the application can be run from the project root with:

```bash
python -m foundation_cli
```

without depending on the current directory for locating task data.

---

# 7. Understanding `load_tasks()`

If the file does not exist:

```python
if not file_path.exists():
    return []
```

the application starts with no tasks.

If the JSON is malformed:

```python
except json.JSONDecodeError as error:
```

the function raises a clearer `ValueError`.

This line preserves the original exception as the cause:

```python
) from error
```

If the JSON contains a valid list, each task is validated:

```python
for item in data:
    validate_task(item)
```

This prevents malformed task dictionaries from silently entering the application.

---

# 8. Understanding `save_tasks()`

The parent directory is created automatically:

```python
file_path.parent.mkdir(parents=True, exist_ok=True)
```

The task list is written as readable JSON:

```python
json.dump(tasks, file, indent=2)
```

The final newline:

```python
file.write("\n")
```

makes the file more pleasant to inspect in a terminal and follows common text-file conventions.

---

# 9. Testing the Storage Module

Create:

```text
src/foundation_cli/storage_manual.py
```

Add:

```python
from pathlib import Path

from .storage import load_tasks, save_tasks


def main() -> None:
    test_file = Path("data/storage_test.json")

    tasks = [
        {
            "id": 1,
            "title": "Test storage",
            "completed": False,
        }
    ]

    save_tasks(tasks, test_file)

    loaded_tasks = load_tasks(test_file)

    print(loaded_tasks)

    test_file.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
```

Run it from the project root:

```bash
python -m foundation_cli.storage_manual
```

Expected output:

```text
[{'id': 1, 'title': 'Test storage', 'completed': False}]
```

The temporary file should be removed automatically by:

```python
test_file.unlink(missing_ok=True)
```

---

# 10. Updating the CLI Module

Now connect the `add` and `list` commands to the task and storage modules.

Replace the complete contents of:

```text
src/foundation_cli/cli.py
```

with:

```python
import argparse

from .storage import load_tasks, save_tasks
from .tasks import create_task


def build_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser."""
    parser = argparse.ArgumentParser(
        prog="foundation",
        description="A multi-utility command-line application.",
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

    organize_parser = subparsers.add_parser(
        "organize",
        help="Organize files by extension.",
    )
    organize_parser.add_argument(
        "directory",
        help="The directory containing files to organize.",
    )

    return parser


def display_task(task: dict) -> None:
    """Display one task."""
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")


def handle_add(title: str) -> None:
    """Create and save a task."""
    tasks = load_tasks()
    task = create_task(tasks, title)
    save_tasks(tasks)

    print("Task created:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")
    print("  Status: incomplete")


def handle_list() -> None:
    """Load and display all tasks."""
    tasks = load_tasks()

    if not tasks:
        print("No tasks found.")
        return

    print("Tasks:")

    for task in tasks:
        display_task(task)


def main() -> None:
    """Run the command-line application."""
    parser = build_parser()
    arguments = parser.parse_args()

    if arguments.command is None:
        parser.print_help()
        return

    if arguments.command == "add":
        handle_add(arguments.title)
    elif arguments.command == "list":
        handle_list()
    elif arguments.command == "complete":
        print(f"Completing task: {arguments.task_id}")
    elif arguments.command == "remove":
        print(f"Removing task: {arguments.task_id}")
    elif arguments.command == "organize":
        print(f"Organizing directory: {arguments.directory}")


if __name__ == "__main__":
    main()
```

---

# 11. Testing the `list` Command

Ensure that no file exists at:

```text
data/tasks.json
```

Then run:

```bash
python -m foundation_cli list
```

Expected output:

```text
No tasks found.
```

The application starts safely when no task data exists.

---

# 12. Testing the `add` Command

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

The application should create:

```text
data/tasks.json
```

Its contents should be:

```json
[
  {
    "id": 1,
    "title": "Learn Python",
    "completed": false
  }
]
```

Add another task:

```bash
python -m foundation_cli add "Build a command-line tool"
```

Expected output:

```text
Task created:
  ID: 2
  Title: Build a command-line tool
  Status: incomplete
```

---

# 13. Testing the `list` Command Again

Run:

```bash
python -m foundation_cli list
```

Expected output:

```text
Tasks:
[ ] 1 - Learn Python
[ ] 2 - Build a command-line tool
```

Run it again after closing the terminal or restarting the command:

```bash
python -m foundation_cli list
```

The tasks should still be present because they are loaded from JSON.

---

# 14. Testing Empty Titles

The command-line parser requires a title argument, so this command:

```bash
python -m foundation_cli add
```

will display an argument error.

Try an empty quoted title:

```bash
python -m foundation_cli add ""
```

The current `create_task()` function raises:

```text
ValueError: Task title cannot be empty.
```

This is technically correct, but the command-line layer should eventually display a friendly error instead of a traceback.

We will improve exception handling in the next section.

For now, verify that empty titles are rejected.

---

# 15. Testing the Current Placeholder Commands

The `complete`, `remove`, and `organize` commands are not connected yet.

Run:

```bash
python -m foundation_cli complete 1
```

Current output:

```text
Completing task: 1
```

Run:

```bash
python -m foundation_cli remove 1
```

Current output:

```text
Removing task: 1
```

These commands will be implemented in the next capstone section.

---

# 16. Current Project Structure

Your capstone project should now look like:

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
│       ├── tasks.py
│       ├── storage.py
│       ├── test_tasks_manual.py
│       └── storage_manual.py
└── tests/
```

The manual test files are temporary. You may delete them:

### Windows PowerShell

```powershell
Remove-Item src\foundation_cli\test_tasks_manual.py
Remove-Item src\foundation_cli\storage_manual.py
```

### macOS or Linux

```bash
rm src/foundation_cli/test_tasks_manual.py
rm src/foundation_cli/storage_manual.py
```

After cleanup:

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
│       ├── tasks.py
│       └── storage.py
└── tests/
```

---

# 17. Verification Checklist

Confirm that you can:

- [ ] Create a task dictionary.
- [ ] Generate task IDs.
- [ ] Find tasks by ID.
- [ ] Complete tasks in memory.
- [ ] Remove tasks in memory.
- [ ] Count completed tasks.
- [ ] Save tasks as JSON.
- [ ] Load tasks from JSON.
- [ ] Handle a missing data file.
- [ ] Validate loaded task data.
- [ ] Run `python -m foundation_cli add "..."`.
- [ ] Run `python -m foundation_cli list`.
- [ ] Confirm that tasks persist after restarting the command.
- [ ] Confirm that `complete`, `remove`, and `organize` are still placeholders.

---

# Part 5B Summary

The capstone now has real task storage.

The application can:

```bash
python -m foundation_cli add "Learn Python"
```

and:

```bash
python -m foundation_cli list
```

The data flow is now:

```text
CLI arguments
    ↓
handle_add()
    ↓
create_task()
    ↓
save_tasks()
    ↓
data/tasks.json
```

For listing:

```text
CLI command
    ↓
handle_list()
    ↓
load_tasks()
    ↓
display_task()
```

The next section will connect the remaining task commands:

```bash
python -m foundation_cli complete 1
python -m foundation_cli remove 1
```

It will also add:

- Friendly error handling.
- A custom error module.
- Improved command dispatch.
- Task statistics.

---

# Part 5C: Completing and Removing Tasks

This is **Section 3 of the Capstone Project**.

In Part 5B, the application learned how to:

- Create tasks.
- Save tasks to JSON.
- Load tasks from JSON.
- List tasks.
- Generate task IDs.

The following commands are still placeholders:

```bash
python -m foundation_cli complete 1
python -m foundation_cli remove 1
```

In this section, we will implement:

- Completing tasks.
- Removing tasks.
- Friendly error handling.
- A custom error module.
- Task statistics.
- Improved command dispatch.

---

# 1. Current Project Structure

Your project should currently look similar to:

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
│       ├── tasks.py
│       └── storage.py
└── tests/
```

We will add:

```text
src/foundation_cli/errors.py
```

---

# 2. Creating an Error Module

Create:

```text
src/foundation_cli/errors.py
```

Add these complete contents:

```python
"""Application-specific exceptions."""


class FoundationError(Exception):
    """Base exception for expected application errors."""


class TaskNotFoundError(FoundationError):
    """Raised when a requested task does not exist."""


class TaskAlreadyCompletedError(FoundationError):
    """Raised when an incomplete-only operation targets a completed task."""


class InvalidTaskTitleError(FoundationError):
    """Raised when a task title is empty or invalid."""
```

These custom exceptions make application errors easier to distinguish from programming errors.

---

# 3. Updating `tasks.py`

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


def create_task(tasks: list[Task], title: str) -> Task:
    """Create a new task and add it to the task list."""
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


def get_next_id(tasks: list[Task]) -> int:
    """Return the next available task ID."""
    if not tasks:
        return 1

    return max(task["id"] for task in tasks) + 1


def find_task(tasks: list[Task], task_id: int) -> Task | None:
    """Find a task by ID."""
    for task in tasks:
        if task["id"] == task_id:
            return task

    return None


def require_task(tasks: list[Task], task_id: int) -> Task:
    """Find a task or raise an error."""
    task = find_task(tasks, task_id)

    if task is None:
        raise TaskNotFoundError(
            f"No task found with ID {task_id}."
        )

    return task


def complete_task(tasks: list[Task], task_id: int) -> Task:
    """Mark a task as completed."""
    task = require_task(tasks, task_id)

    if task["completed"]:
        raise TaskAlreadyCompletedError(
            f"Task {task_id} is already completed."
        )

    task["completed"] = True

    return task


def remove_task(tasks: list[Task], task_id: int) -> Task:
    """Remove and return a task by ID."""
    task = require_task(tasks, task_id)
    tasks.remove(task)

    return task


def count_completed(tasks: list[Task]) -> int:
    """Return the number of completed tasks."""
    return sum(
        1 for task in tasks if task["completed"]
    )


def count_incomplete(tasks: list[Task]) -> int:
    """Return the number of incomplete tasks."""
    return len(tasks) - count_completed(tasks)
```

---

# 4. Understanding the New Exceptions

The earlier version used:

```python
raise ValueError("No task found.")
```

Now the application uses more descriptive exceptions:

```python
raise TaskNotFoundError(
    f"No task found with ID {task_id}."
)
```

This allows the CLI layer to handle expected task errors specifically:

```python
except TaskNotFoundError as error:
    print(f"Error: {error}")
```

The exception classes do not need additional code. Their names communicate what happened.

---

# 5. Testing the Task Logic

Create a temporary file:

```text
src/foundation_cli/task_logic_manual.py
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

    first_task = create_task(tasks, "Learn Python")
    second_task = create_task(tasks, "Build a CLI")

    complete_task(tasks, first_task["id"])

    print(tasks)

    try:
        complete_task(tasks, first_task["id"])
    except TaskAlreadyCompletedError as error:
        print(f"Expected error: {error}")

    removed_task = remove_task(tasks, second_task["id"])
    print(f"Removed: {removed_task}")

    try:
        remove_task(tasks, 999)
    except TaskNotFoundError as error:
        print(f"Expected error: {error}")


if __name__ == "__main__":
    main()
```

Run it from the project root:

```bash
python -m foundation_cli.task_logic_manual
```

Expected output should resemble:

```text
[{'id': 1, 'title': 'Learn Python', 'completed': True}, {'id': 2, 'title': 'Build a CLI', 'completed': False}]
Expected error: Task 1 is already completed.
Removed: {'id': 2, 'title': 'Build a CLI', 'completed': False}
Expected error: No task found with ID 999.
```

After testing, delete the temporary file.

### Windows PowerShell

```powershell
Remove-Item src\foundation_cli\task_logic_manual.py
```

### macOS or Linux

```bash
rm src/foundation_cli/task_logic_manual.py
```

---

# 6. Updating `cli.py`

Replace the complete contents of:

```text
src/foundation_cli/cli.py
```

with:

```python
import argparse
from typing import Any

from .errors import FoundationError
from .storage import load_tasks, save_tasks
from .tasks import (
    complete_task,
    count_completed,
    count_incomplete,
    create_task,
    remove_task,
)


Task = dict[str, Any]


def build_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser."""
    parser = argparse.ArgumentParser(
        prog="foundation",
        description="A multi-utility command-line application.",
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
        help="The directory containing files to organize.",
    )

    return parser


def display_task(task: Task) -> None:
    """Display one task."""
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")


def handle_add(title: str) -> None:
    """Create and save a task."""
    tasks = load_tasks()
    task = create_task(tasks, title)
    save_tasks(tasks)

    print("Task created:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")
    print("  Status: incomplete")


def handle_list() -> None:
    """Load and display all tasks."""
    tasks = load_tasks()

    if not tasks:
        print("No tasks found.")
        return

    print("Tasks:")

    for task in tasks:
        display_task(task)


def handle_complete(task_id: int) -> None:
    """Complete and save a task."""
    tasks = load_tasks()
    task = complete_task(tasks, task_id)
    save_tasks(tasks)

    print("Task completed:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")


def handle_remove(task_id: int) -> None:
    """Remove and save the updated task list."""
    tasks = load_tasks()
    task = remove_task(tasks, task_id)
    save_tasks(tasks)

    print("Task removed:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")


def handle_stats() -> None:
    """Display task statistics."""
    tasks = load_tasks()

    total = len(tasks)
    completed = count_completed(tasks)
    incomplete = count_incomplete(tasks)

    print(f"Total tasks: {total}")
    print(f"Completed tasks: {completed}")
    print(f"Incomplete tasks: {incomplete}")


def handle_command(arguments: argparse.Namespace) -> None:
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
        print(f"Organizing directory: {arguments.directory}")


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


if __name__ == "__main__":
    main()
```

---

# 7. Why `handle_command()` Exists

The `main()` function now has a small responsibility:

```python
def main() -> None:
    parser = build_parser()
    arguments = parser.parse_args()

    if arguments.command is None:
        parser.print_help()
        return

    try:
        handle_command(arguments)
```

The command-specific behavior is moved into:

```python
def handle_command(arguments: argparse.Namespace) -> None:
```

This makes the program easier to extend.

The `main()` function handles:

- Building the parser.
- Reading arguments.
- Showing help.
- Catching expected errors.

The command handler chooses the operation.

---

# 8. Testing `complete`

First, list your current tasks:

```bash
python -m foundation_cli list
```

Suppose the output is:

```text
Tasks:
[ ] 1 - Learn Python
[ ] 2 - Build a command-line tool
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

List the tasks again:

```bash
python -m foundation_cli list
```

Expected output:

```text
Tasks:
[x] 1 - Learn Python
[ ] 2 - Build a command-line tool
```

---

# 9. Testing an Already Completed Task

Run:

```bash
python -m foundation_cli complete 1
```

Expected output:

```text
Error: Task 1 is already completed.
```

The program should not display a traceback.

---

# 10. Testing a Missing Task

Run:

```bash
python -m foundation_cli complete 999
```

Expected output:

```text
Error: No task found with ID 999.
```

The program should continue to exit normally with a clear message.

---

# 11. Testing `remove`

Remove task `2`:

```bash
python -m foundation_cli remove 2
```

Expected output:

```text
Task removed:
  ID: 2
  Title: Build a command-line tool
```

List tasks:

```bash
python -m foundation_cli list
```

Expected output:

```text
Tasks:
[x] 1 - Learn Python
```

The JSON file should also contain only task `1`.

---

# 12. Testing a Missing Task During Removal

Run:

```bash
python -m foundation_cli remove 999
```

Expected output:

```text
Error: No task found with ID 999.
```

---

# 13. Testing Statistics

Run:

```bash
python -m foundation_cli stats
```

Expected output:

```text
Total tasks: 1
Completed tasks: 1
Incomplete tasks: 0
```

The statistics command is now included in help:

```bash
python -m foundation_cli --help
```

You should see:

```text
stats       Display task statistics.
```

---

# 14. Testing Invalid Task IDs

Because `argparse` expects an integer, this command:

```bash
python -m foundation_cli complete abc
```

should produce an argument error similar to:

```text
argument task_id: invalid int value: 'abc'
```

This happens before the task logic runs.

A negative number is technically an integer:

```bash
python -m foundation_cli complete -1
```

The task logic will search for task ID `-1` and normally report:

```text
Error: No task found with ID -1.
```

We will add stronger positive-ID validation in the next refinement section.

---

# 15. Improving Save Error Handling

Currently, `save_tasks()` raises an `OSError` if saving fails.

The CLI catches it here:

```python
except OSError as error:
    print(f"File error: {error}")
```

This is useful because the user sees a short message rather than a full traceback.

For example, a future failure might display:

```text
File error: Could not save task data: data/tasks.json
```

Application errors and file errors are handled separately:

```python
except FoundationError as error:
    print(f"Error: {error}")
except OSError as error:
    print(f"File error: {error}")
```

This makes the error category clearer.

---

# 16. Current Project Structure

After removing the temporary manual files, your project should look similar to:

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
│       ├── storage.py
│       └── tasks.py
└── tests/
```

---

# 17. Verification Checklist

Confirm that you can:

- [ ] Complete a task with `complete`.
- [ ] Prevent a task from being completed twice.
- [ ] Remove a task with `remove`.
- [ ] Receive a useful error for a missing task.
- [ ] Display task statistics with `stats`.
- [ ] Handle custom application exceptions.
- [ ] Handle file-related exceptions.
- [ ] Run all commands without Python tracebacks for expected errors.
- [ ] Confirm that changes persist in `data/tasks.json`.

Test all current commands:

```bash
python -m foundation_cli --help
```

```bash
python -m foundation_cli add "Practice CLI commands"
```

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

---

# Part 5C Summary

The task portion of the capstone now supports:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
```

The application now has these layers:

```text
CLI layer
    ↓
Task logic layer
    ↓
Storage layer
    ↓
JSON file
```

The task logic does not know how commands are entered.

The storage layer does not know how tasks are completed.

The CLI layer connects the pieces and displays results.

The next section will implement the file-organizer utility:

```bash
python -m foundation_cli organize ./downloads
```

It will cover:

- `pathlib` directory traversal.
- File extensions.
- Creating destination folders.
- Moving files safely.
- Handling duplicate names.
- Preview and dry-run behavior.

---

# Part 5D: Building the File Organizer

This is **Section 4 of the Capstone Project**.

The task-management commands now work:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
```

In this section, we will implement:

```bash
python -m foundation_cli organize ./downloads
```

The organizer will:

- Inspect files in a directory.
- Group files by extension.
- Create folders such as `pdf`, `jpg`, and `txt`.
- Move files into those folders.
- Handle files without extensions.
- Avoid overwriting existing files.
- Support a safe `--dry-run` mode.

---

# 1. Example Before and After

Before organizing:

```text
downloads/
├── report.pdf
├── photo.jpg
├── notes.txt
├── presentation.pptx
└── data.csv
```

After organizing:

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

The organizer will only process files directly inside the selected directory. It will not recursively process files inside existing subdirectories.

---

# 2. Creating `organizer.py`

Create:

```text
src/foundation_cli/organizer.py
```

Add these complete contents:

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
            f"{destination.stem}_{counter}{destination.suffix}"
        )

        if not candidate.exists():
            return candidate

        counter += 1


def plan_moves(directory: Path) -> list[FileMove]:
    """Create a list of file moves without changing the file system."""
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
        print(f"{move.source.name} -> {move.destination}")

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
    """Plan and execute file moves."""
    moves = plan_moves(directory)

    return execute_moves(
        moves,
        dry_run=dry_run,
    )
```

---

# 3. Understanding `FileMove`

This data class describes one planned move:

```python
@dataclass(frozen=True)
class FileMove:
    source: Path
    destination: Path
```

For example:

```python
FileMove(
    source=Path("downloads/report.pdf"),
    destination=Path("downloads/pdf/report.pdf"),
)
```

The `@dataclass` decorator automatically creates useful methods for this data structure.

The `frozen=True` option makes each `FileMove` object immutable after creation.

That is appropriate because a planned move should not change unexpectedly after it has been created.

---

# 4. Understanding File Extensions

This function extracts an extension:

```python
def extension_folder(file_path: Path) -> str:
    suffix = file_path.suffix.lower().lstrip(".")

    if suffix:
        return suffix

    return "no_extension"
```

Examples:

| File | Resulting folder |
|---|---|
| `report.pdf` | `pdf` |
| `photo.JPG` | `jpg` |
| `data.csv` | `csv` |
| `README` | `no_extension` |

The `.lower()` call ensures that these files use the same folder:

```text
photo.jpg
photo.JPG
photo.JpG
```

They will all be categorized as:

```text
jpg
```

---

# 5. Handling Duplicate Names

Suppose the destination already contains:

```text
pdf/report.pdf
```

and the organizer finds another file named:

```text
report.pdf
```

The function:

```python
unique_destination()
```

creates a new name:

```text
report_1.pdf
```

If that exists too, it tries:

```text
report_2.pdf
```

This prevents the organizer from overwriting an existing file.

The relevant code is:

```python
candidate = destination.with_name(
    f"{destination.stem}_{counter}{destination.suffix}"
)
```

For:

```text
report.pdf
```

- `.stem` is `report`.
- `.suffix` is `.pdf`.

---

# 6. Planning Before Moving

The organizer separates planning from execution.

This function only creates a plan:

```python
def plan_moves(directory: Path) -> list[FileMove]:
```

It does not move anything.

This is useful because the program can:

- Display the planned changes.
- Support dry runs.
- Test the plan without modifying files.
- Review errors before execution.

The function skips directories:

```python
if not item.is_file():
    continue
```

Therefore, existing folders such as `pdf/` are not moved into another folder.

---

# 7. The `--dry-run` Option

A dry run displays what would happen without making changes.

For example:

```text
report.pdf -> pdf/report.pdf
photo.jpg -> jpg/photo.jpg
```

but the files remain in their original locations.

This is an important safety feature for file operations.

---

# 8. Creating Test Files

Create a temporary test directory.

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

Your test directory should contain:

```text
organizer_test/
├── README
├── notes.txt
├── photo.jpg
└── report.pdf
```

---

# 9. Testing the Organizer Directly

Create:

```text
src/foundation_cli/organizer_manual.py
```

Add:

```python
from pathlib import Path

from .organizer import organize_directory


def main() -> None:
    directory = Path("organizer_test")

    print("Preview:")
    organize_directory(directory, dry_run=True)


if __name__ == "__main__":
    main()
```

Run it from the project root:

```bash
python -m foundation_cli.organizer_manual
```

Expected output should resemble:

```text
Preview:
README -> organizer_test/no_extension/README
notes.txt -> organizer_test/txt/notes.txt
photo.jpg -> organizer_test/jpg/photo.jpg
report.pdf -> organizer_test/pdf/report.pdf
```

The files should still be in the original directory because this was a dry run.

Delete the temporary manual test afterward.

### Windows PowerShell

```powershell
Remove-Item src\foundation_cli\organizer_manual.py
```

### macOS or Linux

```bash
rm src/foundation_cli/organizer_manual.py
```

---

# 10. Updating the CLI

Replace the complete contents of:

```text
src/foundation_cli/cli.py
```

with:

```python
import argparse
from pathlib import Path
from typing import Any

from .errors import FoundationError
from .organizer import organize_directory
from .storage import load_tasks, save_tasks
from .tasks import (
    complete_task,
    count_completed,
    count_incomplete,
    create_task,
    remove_task,
)


Task = dict[str, Any]


def build_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser."""
    parser = argparse.ArgumentParser(
        prog="foundation",
        description="A multi-utility command-line application.",
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
        type=Path,
        help="The directory containing files to organize.",
    )
    organize_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without moving files.",
    )

    return parser


def display_task(task: Task) -> None:
    """Display one task."""
    status = "x" if task["completed"] else " "
    print(f"[{status}] {task['id']} - {task['title']}")


def handle_add(title: str) -> None:
    """Create and save a task."""
    tasks = load_tasks()
    task = create_task(tasks, title)
    save_tasks(tasks)

    print("Task created:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")
    print("  Status: incomplete")


def handle_list() -> None:
    """Load and display all tasks."""
    tasks = load_tasks()

    if not tasks:
        print("No tasks found.")
        return

    print("Tasks:")

    for task in tasks:
        display_task(task)


def handle_complete(task_id: int) -> None:
    """Complete and save a task."""
    tasks = load_tasks()
    task = complete_task(tasks, task_id)
    save_tasks(tasks)

    print("Task completed:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")


def handle_remove(task_id: int) -> None:
    """Remove and save the updated task list."""
    tasks = load_tasks()
    task = remove_task(tasks, task_id)
    save_tasks(tasks)

    print("Task removed:")
    print(f"  ID: {task['id']}")
    print(f"  Title: {task['title']}")


def handle_stats() -> None:
    """Display task statistics."""
    tasks = load_tasks()

    total = len(tasks)
    completed = count_completed(tasks)
    incomplete = count_incomplete(tasks)

    print(f"Total tasks: {total}")
    print(f"Completed tasks: {completed}")
    print(f"Incomplete tasks: {incomplete}")


def handle_organize(
    directory: Path,
    dry_run: bool,
) -> None:
    """Organize files in a directory."""
    if dry_run:
        print("Dry run: no files will be moved.")

    moved_count = organize_directory(
        directory,
        dry_run=dry_run,
    )

    if dry_run:
        print("Dry run complete.")
    else:
        print(f"Moved {moved_count} file(s).")


def handle_command(arguments: argparse.Namespace) -> None:
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
        handle_organize(
            arguments.directory,
            arguments.dry_run,
        )


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
    except (FileNotFoundError, NotADirectoryError) as error:
        print(f"File error: {error}")
    except OSError as error:
        print(f"File error: {error}")


if __name__ == "__main__":
    main()
```

---

# 11. Testing the Dry Run

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

Inspect the directory afterward.

The files should still be here:

```text
organizer_test/
├── README
├── notes.txt
├── photo.jpg
└── report.pdf
```

No destination directories should have been created by the dry run.

---

# 12. Running the Real Organizer

Run:

```bash
python -m foundation_cli organize organizer_test
```

Expected output:

```text
README -> organizer_test/no_extension/README
notes.txt -> organizer_test/txt/notes.txt
photo.jpg -> organizer_test/jpg/photo.jpg
report.pdf -> organizer_test/pdf/report.pdf
Moved 4 file(s).
```

The directory should now look like:

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

---

# 13. Testing Duplicate Names

Create a duplicate destination scenario.

First, create a new file with the same name as one already organized.

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

The output should use a unique destination similar to:

```text
photo.jpg -> organizer_test/jpg/photo_1.jpg
Moved 1 file(s).
```

The destination should contain:

```text
jpg/
├── photo.jpg
└── photo_1.jpg
```

The original file was not overwritten.

---

# 14. Testing a Missing Directory

Run:

```bash
python -m foundation_cli organize does-not-exist
```

Expected output should resemble:

```text
File error: Directory does not exist: does-not-exist
```

The application should not display a traceback.

---

# 15. Testing a File Instead of a Directory

Choose an existing file, such as:

```text
organizer_test/jpg/photo.jpg
```

Run:

```bash
python -m foundation_cli organize organizer_test/jpg/photo.jpg
```

Expected output should resemble:

```text
File error: Path is not a directory: organizer_test/jpg/photo.jpg
```

---

# 16. Cleaning Up the Test Directory

After testing, remove the temporary directory.

### Windows PowerShell

```powershell
Remove-Item organizer_test -Recurse -Force
```

### macOS or Linux

```bash
rm -rf organizer_test
```

Use this command only for the temporary test directory.

---

# 17. Updating the README

Replace the complete contents of:

```text
README.md
```

with:

```markdown
# Foundation CLI

A beginner-friendly multi-utility command-line application built with Python.

## Installation

Create and activate a virtual environment, then install the project:

```bash
python -m pip install --editable .
```

## Task commands

Add a task:

```bash
python -m foundation_cli add "Learn Python"
```

List tasks:

```bash
python -m foundation_cli list
```

Complete a task:

```bash
python -m foundation_cli complete 1
```

Remove a task:

```bash
python -m foundation_cli remove 1
```

Display statistics:

```bash
python -m foundation_cli stats
```

## File organizer

Preview file organization without moving files:

```bash
python -m foundation_cli organize ./downloads --dry-run
```

Organize files by extension:

```bash
python -m foundation_cli organize ./downloads
```

## Help

```bash
python -m foundation_cli --help
```
```

---

# 18. Current Project Structure

Your project should now look similar to:

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
```

---

# 19. Verification Checklist

Confirm that you can:

- [ ] Run the organizer in dry-run mode.
- [ ] Organize files by extension.
- [ ] Create extension folders.
- [ ] Handle files without extensions.
- [ ] Handle uppercase extensions.
- [ ] Avoid overwriting duplicate filenames.
- [ ] Reject missing directories.
- [ ] Reject file paths when a directory is required.
- [ ] Run the complete task command set.
- [ ] Read the updated README instructions.

Test the CLI help:

```bash
python -m foundation_cli --help
```

Test the version:

```bash
python -m foundation_cli --version
```

Test the task commands:

```bash
python -m foundation_cli add "Test the capstone"
```

```bash
python -m foundation_cli list
```

```bash
python -m foundation_cli stats
```

---

# Part 5D Summary

The capstone now supports two utilities:

## Task management

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
```

## File organization

```bash
python -m foundation_cli organize ./downloads --dry-run
python -m foundation_cli organize ./downloads
```

The file organizer uses:

- `pathlib.Path`.
- File extensions.
- Data classes.
- Directory creation.
- `shutil.move()`.
- Duplicate-name protection.
- Dry-run behavior.
- File-system error handling.

The next section will focus on testing and production-readiness improvements, including:

- Automated tests.
- Temporary test directories.
- CLI verification.
- Safer command behavior.
- Formatting and validation.
- Final project verification.

---

# Part 5E: Testing and Production-Readiness

This is **Section 5 of the Capstone Project**.

The capstone application now supports:

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
python -m foundation_cli organize ./downloads
```

In this section, we will:

- Add automated tests.
- Test task logic.
- Test JSON storage.
- Test the file organizer.
- Test command-line behavior.
- Add positive task-ID validation.
- Run the complete verification process.
- Review the final project structure.

We will use Python's built-in `unittest` module so that no additional testing dependency is required.

---

# 1. Why Automated Tests Matter

Manual testing is useful, but it has limitations.

For example, you may manually verify that:

```bash
python -m foundation_cli complete 1
```

works correctly.

However, after changing another part of the application, you may accidentally break task completion without realizing it.

Automated tests allow you to repeat checks consistently.

A test usually:

1. Creates known input.
2. Runs a function.
3. Checks the result.
4. Reports success or failure.

For example:

```python
result = add(2, 3)

self.assertEqual(result, 5)
```

If the result is not `5`, the test fails.

---

# 2. Testing Task Logic

Create:

```text
tests/test_tasks.py
```

Add these complete contents:

```python
import unittest

from foundation_cli.errors import (
    InvalidTaskTitleError,
    TaskAlreadyCompletedError,
    TaskNotFoundError,
)
from foundation_cli.tasks import (
    complete_task,
    count_completed,
    count_incomplete,
    create_task,
    find_task,
    remove_task,
)


class TaskTests(unittest.TestCase):
    def test_create_task_adds_task(self):
        tasks = []

        task = create_task(tasks, "Learn Python")

        self.assertEqual(task["id"], 1)
        self.assertEqual(task["title"], "Learn Python")
        self.assertFalse(task["completed"])
        self.assertEqual(len(tasks), 1)

    def test_create_task_strips_title_whitespace(self):
        tasks = []

        task = create_task(tasks, "  Learn Python  ")

        self.assertEqual(task["title"], "Learn Python")

    def test_create_task_rejects_empty_title(self):
        tasks = []

        with self.assertRaises(InvalidTaskTitleError):
            create_task(tasks, "   ")

    def test_task_ids_increase(self):
        tasks = []

        first_task = create_task(tasks, "First")
        second_task = create_task(tasks, "Second")

        self.assertEqual(first_task["id"], 1)
        self.assertEqual(second_task["id"], 2)

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
        self.assertEqual(task["title"], "Learn Python")

    def test_find_task_returns_none_when_missing(self):
        tasks = []

        task = find_task(tasks, 999)

        self.assertIsNone(task)

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

    def test_complete_task_rejects_missing_task(self):
        with self.assertRaises(TaskNotFoundError):
            complete_task([], 999)

    def test_complete_task_rejects_already_completed_task(self):
        tasks = [
            {
                "id": 1,
                "title": "Learn Python",
                "completed": True,
            }
        ]

        with self.assertRaises(TaskAlreadyCompletedError):
            complete_task(tasks, 1)

    def test_remove_task_removes_task(self):
        tasks = [
            {
                "id": 1,
                "title": "Learn Python",
                "completed": False,
            }
        ]

        removed_task = remove_task(tasks, 1)

        self.assertEqual(removed_task["id"], 1)
        self.assertEqual(tasks, [])

    def test_remove_task_rejects_missing_task(self):
        with self.assertRaises(TaskNotFoundError):
            remove_task([], 999)

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

        self.assertEqual(count_completed(tasks), 2)

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

        self.assertEqual(count_incomplete(tasks), 1)


if __name__ == "__main__":
    unittest.main()
```

---

# 3. Running the Task Tests

Run this command from the project root:

```bash
python -m unittest discover -s tests -v
```

Expected output should resemble:

```text
test_complete_task_marks_task_completed ... ok
test_complete_task_rejects_already_completed_task ... ok
test_complete_task_rejects_missing_task ... ok
...
----------------------------------------------------------------------
Ran 12 tests in 0.00s

OK
```

The exact number of tests may vary if you add more tests.

The command means:

```text
python -m unittest
```

Run Python's built-in testing module.

```text
discover
```

Find test files automatically.

```text
-s tests
```

Search inside the `tests` directory.

```text
-v
```

Display detailed test names.

---

# 4. Testing JSON Storage

Create:

```text
tests/test_storage.py
```

Add these complete contents:

```python
import json
import tempfile
import unittest
from pathlib import Path

from foundation_cli.storage import load_tasks, save_tasks


class StorageTests(unittest.TestCase):
    def test_missing_file_returns_empty_list(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            file_path = Path(temporary_directory) / "tasks.json"

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

        with tempfile.TemporaryDirectory() as temporary_directory:
            file_path = Path(temporary_directory) / "tasks.json"

            save_tasks(expected_tasks, file_path)
            actual_tasks = load_tasks(file_path)

            self.assertEqual(actual_tasks, expected_tasks)

    def test_save_creates_parent_directory(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            file_path = (
                Path(temporary_directory)
                / "nested"
                / "tasks.json"
            )

            save_tasks([], file_path)

            self.assertTrue(file_path.exists())
            self.assertEqual(load_tasks(file_path), [])

    def test_invalid_json_raises_value_error(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            file_path = Path(temporary_directory) / "tasks.json"
            file_path.write_text(
                "This is not JSON.",
                encoding="utf-8",
            )

            with self.assertRaises(ValueError):
                load_tasks(file_path)

    def test_json_must_contain_a_list(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            file_path = Path(temporary_directory) / "tasks.json"
            file_path.write_text(
                json.dumps({"title": "Not a list"}),
                encoding="utf-8",
            )

            with self.assertRaises(ValueError):
                load_tasks(file_path)

    def test_invalid_task_shape_raises_value_error(self):
        invalid_tasks = [
            {
                "id": "wrong type",
                "title": "Invalid task",
                "completed": False,
            }
        ]

        with tempfile.TemporaryDirectory() as temporary_directory:
            file_path = Path(temporary_directory) / "tasks.json"

            file_path.write_text(
                json.dumps(invalid_tasks),
                encoding="utf-8",
            )

            with self.assertRaises(ValueError):
                load_tasks(file_path)


if __name__ == "__main__":
    unittest.main()
```

Run all tests again:

```bash
python -m unittest discover -s tests -v
```

The storage tests use:

```python
tempfile.TemporaryDirectory()
```

This creates a temporary directory for each test and automatically removes it afterward.

That prevents tests from modifying your real:

```text
data/tasks.json
```

---

# 5. Testing the File Organizer

Create:

```text
tests/test_organizer.py
```

Add these complete contents:

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
    def test_extension_folder_uses_lowercase_extension(self):
        self.assertEqual(
            extension_folder(Path("PHOTO.JPG")),
            "jpg",
        )

    def test_extension_folder_handles_no_extension(self):
        self.assertEqual(
            extension_folder(Path("README")),
            "no_extension",
        )

    def test_plan_moves_only_includes_files(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory)

            (directory / "report.pdf").write_text(
                "PDF",
                encoding="utf-8",
            )
            (directory / "notes.txt").write_text(
                "Notes",
                encoding="utf-8",
            )
            (directory / "existing_folder").mkdir()

            moves = plan_moves(directory)

            sources = {move.source.name for move in moves}

            self.assertEqual(
                sources,
                {"report.pdf", "notes.txt"},
            )

    def test_dry_run_does_not_move_files(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory)
            source = directory / "report.pdf"

            source.write_text("PDF", encoding="utf-8")

            moves = plan_moves(directory)
            moved_count = execute_moves(moves, dry_run=True)

            self.assertEqual(moved_count, 0)
            self.assertTrue(source.exists())
            self.assertFalse(
                (directory / "pdf" / "report.pdf").exists()
            )

    def test_execute_moves_moves_files(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory)
            source = directory / "report.pdf"

            source.write_text("PDF", encoding="utf-8")

            moves = plan_moves(directory)
            moved_count = execute_moves(moves)

            destination = directory / "pdf" / "report.pdf"

            self.assertEqual(moved_count, 1)
            self.assertFalse(source.exists())
            self.assertTrue(destination.exists())
            self.assertEqual(
                destination.read_text(encoding="utf-8"),
                "PDF",
            )

    def test_duplicate_names_are_not_overwritten(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory)
            pdf_directory = directory / "pdf"
            pdf_directory.mkdir()

            existing_file = pdf_directory / "report.pdf"
            existing_file.write_text(
                "Existing",
                encoding="utf-8",
            )

            source = directory / "report.pdf"
            source.write_text(
                "New",
                encoding="utf-8",
            )

            moves = plan_moves(directory)
            execute_moves(moves)

            duplicate_file = pdf_directory / "report_1.pdf"

            self.assertTrue(existing_file.exists())
            self.assertTrue(duplicate_file.exists())
            self.assertEqual(
                existing_file.read_text(encoding="utf-8"),
                "Existing",
            )
            self.assertEqual(
                duplicate_file.read_text(encoding="utf-8"),
                "New",
            )

    def test_missing_directory_raises_error(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = (
                Path(temporary_directory)
                / "does-not-exist"
            )

            with self.assertRaises(FileNotFoundError):
                plan_moves(directory)


if __name__ == "__main__":
    unittest.main()
```

Run the tests:

```bash
python -m unittest discover -s tests -v
```

You should now see tests for:

- Task logic.
- Storage.
- File organization.

---

# 6. Adding a Positive Integer Validator

At the moment, `argparse` accepts negative integers:

```bash
python -m foundation_cli complete -1
```

The task logic will reject the missing ID, but the CLI can provide a more direct message.

We will create a custom parser function.

Open:

```text
src/foundation_cli/cli.py
```

Add this function near the top, after the `Task` alias:

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

Now change the `complete` parser argument from:

```python
complete_parser.add_argument(
    "task_id",
    type=int,
    help="The ID of the task to complete.",
)
```

to:

```python
complete_parser.add_argument(
    "task_id",
    type=positive_integer,
    help="The positive ID of the task to complete.",
)
```

Change the `remove` parser argument from:

```python
remove_parser.add_argument(
    "task_id",
    type=int,
    help="The ID of the task to remove.",
)
```

to:

```python
remove_parser.add_argument(
    "task_id",
    type=positive_integer,
    help="The positive ID of the task to remove.",
)
```

Now test:

```bash
python -m foundation_cli complete -1
```

Expected output should resemble:

```text
argument task_id: must be greater than zero
```

Test non-numeric input:

```bash
python -m foundation_cli complete abc
```

Expected output should resemble:

```text
argument task_id: must be a whole number
```

---

# 7. Testing the CLI Manually

Before running final verification, create a clean task-data file.

### Windows PowerShell

```powershell
Remove-Item data\tasks.json -ErrorAction SilentlyContinue
```

### macOS or Linux

```bash
rm -f data/tasks.json
```

Now run the following commands.

## Display help

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

## Display version

```bash
python -m foundation_cli --version
```

Expected:

```text
foundation 0.1.0
```

## List an empty task collection

```bash
python -m foundation_cli list
```

Expected:

```text
No tasks found.
```

## Add a task

```bash
python -m foundation_cli add "Learn Python testing"
```

Expected:

```text
Task created:
  ID: 1
  Title: Learn Python testing
  Status: incomplete
```

## Add another task

```bash
python -m foundation_cli add "Review the capstone"
```

Expected:

```text
Task created:
  ID: 2
  Title: Review the capstone
  Status: incomplete
```

## List tasks

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[ ] 1 - Learn Python testing
[ ] 2 - Review the capstone
```

## Complete a task

```bash
python -m foundation_cli complete 1
```

Expected:

```text
Task completed:
  ID: 1
  Title: Learn Python testing
```

## Display statistics

```bash
python -m foundation_cli stats
```

Expected:

```text
Total tasks: 2
Completed tasks: 1
Incomplete tasks: 1
```

## Remove a task

```bash
python -m foundation_cli remove 2
```

Expected:

```text
Task removed:
  ID: 2
  Title: Review the capstone
```

## Confirm the remaining task

```bash
python -m foundation_cli list
```

Expected:

```text
Tasks:
[x] 1 - Learn Python testing
```

---

# 8. Testing the File Organizer Manually

Create a temporary directory.

### Windows PowerShell

```powershell
mkdir organizer_demo
Set-Content organizer_demo\report.pdf "PDF content"
Set-Content organizer_demo\photo.jpg "JPG content"
Set-Content organizer_demo\notes.txt "Text content"
```

### macOS or Linux

```bash
mkdir -p organizer_demo
printf "PDF content" > organizer_demo/report.pdf
printf "JPG content" > organizer_demo/photo.jpg
printf "Text content" > organizer_demo/notes.txt
```

Run a dry run:

```bash
python -m foundation_cli organize organizer_demo --dry-run
```

Confirm that the files remain in their original locations.

Run the actual organizer:

```bash
python -m foundation_cli organize organizer_demo
```

Expected output should resemble:

```text
notes.txt -> organizer_demo/txt/notes.txt
photo.jpg -> organizer_demo/jpg/photo.jpg
report.pdf -> organizer_demo/pdf/report.pdf
Moved 3 file(s).
```

Inspect the result:

```text
organizer_demo/
├── jpg/
│   └── photo.jpg
├── pdf/
│   └── report.pdf
└── txt/
    └── notes.txt
```

Remove the temporary directory after testing.

### Windows PowerShell

```powershell
Remove-Item organizer_demo -Recurse -Force
```

### macOS or Linux

```bash
rm -rf organizer_demo
```

---

# 9. Running the Complete Test Suite

Run:

```bash
python -m unittest discover -s tests -v
```

Expected final output should resemble:

```text
----------------------------------------------------------------------
Ran 20 tests in 0.05s

OK
```

The exact number may differ depending on how many tests you created.

Every test should end with:

```text
ok
```

The final result must be:

```text
OK
```

If a test fails:

1. Read the test name.
2. Read the failure message.
3. Find the file and line number.
4. Reproduce the problem manually.
5. Fix one issue at a time.
6. Run the tests again.

---

# 10. Final Project Structure

Your completed capstone should look similar to:

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

The earlier practice files may still exist elsewhere in your project:

```text
projects/
```

That is acceptable, although you may eventually move them into a separate learning directory or remove them.

---

# 11. Responsibilities of Each Application File

## `__init__.py`

Defines the package and its version:

```python
__version__ = "0.1.0"
```

## `__main__.py`

Allows this command:

```bash
python -m foundation_cli
```

## `cli.py`

Handles:

- Command-line parsing.
- Command dispatch.
- User-facing output.
- User-facing errors.

## `tasks.py`

Handles:

- Creating tasks.
- Finding tasks.
- Completing tasks.
- Removing tasks.
- Counting task statuses.

## `storage.py`

Handles:

- Loading JSON.
- Saving JSON.
- Validating task data.
- Managing the data path.

## `organizer.py`

Handles:

- Discovering files.
- Determining extension folders.
- Planning moves.
- Moving files.
- Avoiding duplicate names.

## `errors.py`

Defines application-specific exceptions.

## `tests/`

Contains repeatable verification for the application.

---

# 12. Complete Command Reference

## Show help

```bash
python -m foundation_cli --help
```

## Show version

```bash
python -m foundation_cli --version
```

## Add a task

```bash
python -m foundation_cli add "Learn Python"
```

## List tasks

```bash
python -m foundation_cli list
```

## Complete a task

```bash
python -m foundation_cli complete 1
```

## Remove a task

```bash
python -m foundation_cli remove 1
```

## Display statistics

```bash
python -m foundation_cli stats
```

## Preview file organization

```bash
python -m foundation_cli organize ./downloads --dry-run
```

## Organize files

```bash
python -m foundation_cli organize ./downloads
```

## Run automated tests

```bash
python -m unittest discover -s tests -v
```

---

# 13. Production-Readiness Review

The application is still a learning project, but it now uses several professional practices.

## Clear Names

Examples:

```python
load_tasks()
save_tasks()
complete_task()
organize_directory()
```

The names communicate what the functions do.

## Focused Responsibilities

Each module has a clear purpose.

## Explicit Errors

The program handles expected errors with custom exceptions and clear messages.

## Safe File Operations

The organizer supports:

```bash
--dry-run
```

and avoids overwriting duplicate files.

## Persistent Data

Tasks remain available after the program exits.

## Input Validation

The program validates:

- Task titles.
- Task IDs.
- Command-line arguments.
- JSON structure.

## Automated Tests

The application has tests for:

- Task behavior.
- Storage behavior.
- File organization.

## Standard Library Only

The application uses Python's standard library:

- `argparse`
- `dataclasses`
- `json`
- `pathlib`
- `shutil`
- `tempfile`
- `unittest`

This keeps the project simple to install and understand.

---

# 14. Final Verification Checklist

Complete this checklist before considering the capstone finished.

## Environment

- [ ] Python runs successfully.
- [ ] The virtual environment is active.
- [ ] The project is installed in editable mode.
- [ ] `python -m foundation_cli` starts correctly.

## CLI

- [ ] `--help` displays useful information.
- [ ] `--version` displays the version.
- [ ] Missing commands display help.
- [ ] Invalid commands produce a useful error.
- [ ] Invalid task IDs are rejected.

## Tasks

- [ ] Tasks can be added.
- [ ] Empty titles are rejected.
- [ ] Tasks can be listed.
- [ ] Tasks can be completed.
- [ ] Already-completed tasks are rejected.
- [ ] Tasks can be removed.
- [ ] Missing task IDs produce a useful error.
- [ ] Statistics are accurate.
- [ ] Tasks persist in `data/tasks.json`.

## File Organizer

- [ ] Dry-run mode does not move files.
- [ ] Files are grouped by extension.
- [ ] Uppercase extensions are normalized.
- [ ] Files without extensions are supported.
- [ ] Duplicate filenames are not overwritten.
- [ ] Missing directories are reported.
- [ ] File paths are rejected when a directory is required.

## Tests

- [ ] Task tests pass.
- [ ] Storage tests pass.
- [ ] Organizer tests pass.
- [ ] The complete test suite reports `OK`.

---

# Part 5E Summary

The capstone is now complete.

You built a multi-utility command-line application with:

## Task management

```bash
python -m foundation_cli add "Learn Python"
python -m foundation_cli list
python -m foundation_cli complete 1
python -m foundation_cli remove 1
python -m foundation_cli stats
```

## File organization

```bash
python -m foundation_cli organize ./downloads --dry-run
python -m foundation_cli organize ./downloads
```

## Persistent JSON storage

```text
data/tasks.json
```

## Modular architecture

```text
cli.py
tasks.py
storage.py
organizer.py
errors.py
```

## Automated tests

```text
tests/test_tasks.py
tests/test_storage.py
tests/test_organizer.py
```

The complete application flow is:

```text
Command-line input
        ↓
Argument parsing
        ↓
CLI command dispatch
        ↓
Application logic
        ↓
Storage or file-system operation
        ↓
Result or friendly error message
```

You have now moved from individual Python scripts to a structured, reusable application.

The main skills developed throughout the series are:

- Breaking requirements into smaller operations.
- Choosing appropriate data structures.
- Separating responsibilities.
- Validating input.
- Handling expected failures.
- Persisting data.
- Testing behavior.
- Designing a useful command-line interface.
- Organizing a Python project professionally.
