# Part 0: Introduction

Welcome to **Pythonic Craftsmanship: Writing Clean, Idiomatic Code**.

Knowing Python syntax is a great starting point. You may already be able to write variables, loops, functions, conditions, and small scripts that solve useful problems. This series is about taking the next step: turning code that *works* into code that is easier to read, test, change, reuse, and safely run in real projects.

The central idea is **Pythonic code**. “Pythonic” does not simply mean short code. It means code that uses Python’s built-in strengths—its expressive syntax, object model, standard library, package system, and conventions—to communicate intent clearly.

A useful comparison:

- A quick script is like assembling a piece of furniture just well enough for it to stand.
- A production-quality Python package is like designing furniture that can be assembled, repaired, extended, safety-checked, and used by other people.

By the end of this series, you will understand how to make that transition.

---

## What You Will Build

The series leads toward a capstone project: a **modular Python API client package**.

An **API client** is code that communicates with an external web service. Instead of scattering HTTP requests, error handling, and data parsing throughout an application, the client provides a clean, reusable interface.

For example, the final package will let a developer write code conceptually like this:

```python
from craftapi import CraftApiClient

client = CraftApiClient(base_url="https://api.example.com", api_token="secret-token")

project = client.get_project("project-123")
print(project.name)
```

Behind that simple interface, the package will handle important responsibilities:

- Building and sending HTTP requests
- Validating configuration
- Safely handling network failures and unexpected responses
- Converting raw API data into well-defined Python objects
- Providing readable exception types
- Supporting context-manager usage with `with`
- Remaining fully testable without contacting a real network service
- Enforcing type correctness with static type checking

The final architecture will look like this:

```text
pythonic-craftsmanship/
├── README.md
├── pyproject.toml
├── .gitignore
├── .python-version
├── src/
│   └── craftapi/
│       ├── __init__.py
│       ├── client.py
│       ├── config.py
│       ├── exceptions.py
│       ├── models.py
│       ├── transport.py
│       └── utils.py
└── tests/
    ├── __init__.py
    ├── conftest.py
    ├── test_client.py
    ├── test_config.py
    ├── test_models.py
    └── test_transport.py
```

Each part has a focused job:

| Location | Responsibility |
|---|---|
| `src/craftapi/` | The installable application package |
| `client.py` | The public, developer-friendly API client interface |
| `config.py` | Configuration validation and normalization |
| `exceptions.py` | Clear, domain-specific error types |
| `models.py` | Python objects representing API resources |
| `transport.py` | Low-level HTTP communication |
| `utils.py` | Small reusable helpers |
| `tests/` | Automated checks proving behavior remains correct |
| `pyproject.toml` | Project dependencies and tooling configuration |

We will not start by building all of this at once. First, we will learn the language patterns that make the architecture clean and maintainable.

---

## Who This Series Is For

This series is designed for developers who already understand Python fundamentals, including:

- Variables and basic data types such as `str`, `int`, `list`, and `dict`
- Conditional statements: `if`, `elif`, and `else`
- Loops: `for` and `while`
- Functions using `def`
- Imports such as `import json` or `from pathlib import Path`
- Reading and writing small scripts from the terminal

You do **not** need prior experience with:

- Object-oriented programming
- Python packages
- Automated testing
- Type hints
- Decorators
- HTTP client design
- Production project layouts

We will introduce those ideas one at a time.

---

## What “Production-Ready” Means Here

No program is permanently perfect, but production-ready code is written with the expectation that it will be used, maintained, and changed by real people.

Throughout this series, “production-ready” means we will consistently practice:

1. **Clear boundaries**  
   Each module and class should have one understandable responsibility.

2. **Helpful errors**  
   When something fails, the program should explain what happened and preserve enough detail to diagnose it.

3. **Safe configuration**  
   Secrets such as API tokens will come from environment variables or explicit configuration—not be hard-coded into source files.

4. **Testability**  
   Important behavior will be covered by automated tests, so future changes can be made confidently.

5. **Type safety**  
   Type hints will describe the data a function expects and returns. Tools such as `mypy` can inspect those descriptions before the code runs.

6. **Readable code**  
   Future readers—including you—should be able to understand the program without reverse-engineering clever shortcuts.

7. **Appropriate use of Python’s standard library**  
   The standard library is Python’s built-in toolbox. We will use it whenever it is a better fit than adding unnecessary dependencies.

---

## The Learning Path

The technical work is organized into four modules followed by the capstone.

### Module 1: Object-Oriented Programming

We will learn how to model related data and behavior using **classes**.

A class is a blueprint. An instance is one concrete object built from that blueprint.

For example:

- A `Project` class is a blueprint for a project returned by an API.
- A specific project named `"Website Redesign"` is an instance of that class.

This module covers:

- Classes and instances
- Constructors with `__init__`
- Instance attributes and class attributes
- Encapsulation: protecting an object’s valid internal state
- Inheritance: creating specialized versions of a base class
- Polymorphism: using different objects through a shared interface
- Dunder methods—special methods with double underscores—such as:
  - `__init__`
  - `__repr__`
  - `__str__`
  - `__len__`
  - `__eq__`

These patterns will later help us create useful models, exceptions, and client components.

---

### Module 2: Pythonic Mechanics

Python offers concise, expressive tools for working with collections and sequences of data.

This module covers:

- List, dictionary, and set comprehensions
- Generator expressions
- Iterators and the iteration protocol
- Lazy evaluation
- Context managers and `with` blocks
- `itertools` for composing efficient iteration behavior
- `collections` for specialized containers such as `Counter`, `defaultdict`, and `deque`

These tools are especially useful when transforming API response data, managing resources, and handling large sequences without unnecessary memory use.

---

### Module 3: Decorators and Functions as First-Class Objects

In Python, functions are **first-class objects**. That means you can store them in variables, pass them to other functions, return them from functions, and attach behavior around them.

This module covers:

- Higher-order functions
- Closures
- `*args` and `**kwargs`
- Function decorators
- Preserving metadata with `functools.wraps`
- Building practical decorators for concerns such as logging, retries, and validation

A decorator is like a protective or useful wrapper around a function. The underlying function still does its original job, while the wrapper can add behavior before or after it runs.

---

### Module 4: Package Architecture and Testing

This module turns individual Python files into a maintainable project.

We will cover:

- Creating isolated environments with `venv`
- Organizing source code in a `src/` layout
- Understanding imports and `__init__.py`
- Installing packages in editable mode
- Managing dependencies with `pyproject.toml`
- Writing tests with `pytest`
- Creating fixtures for reusable test setup
- Mocking external HTTP calls
- Adding type annotations
- Checking types with `mypy`
- Formatting and linting principles

This is where the work begins to resemble a professional Python codebase rather than a collection of scripts.

---

### Capstone: A Fully Tested API Client Package

The capstone combines every preceding module into one cohesive implementation.

You will build a package with:

- A clean public client interface
- Immutable configuration where appropriate
- Structured data models
- Custom exception hierarchy
- HTTP transport abstraction
- Context-manager resource cleanup
- Pagination support using iterators or generators
- Decorator-based behavior where it improves clarity
- Comprehensive `pytest` test coverage
- Static type checking with `mypy`
- Clear installation and usage documentation

The goal is not merely to finish one project. The goal is to learn a repeatable way of thinking:

> Separate responsibilities, make invalid states difficult to create, expose a simple interface, and prove behavior with tests.

---

## How Each Technical Step Will Work

Every implementation step in this series will use the same predictable format:

### The Target

We will name the exact file, configuration, or behavior being built.

### The Concept

We will explain the reasoning in plain language before writing code.

### The Implementation

You will receive complete file contents with exact paths. Code will be designed to be copied and run as written.

### The Verification

You will run a specific command, test, or small program to confirm that the current step works before moving forward.

This structure matters because programming is easier when you can verify small pieces as you build them. It is like checking each section of a bridge before driving across the completed structure.

---

## Tools You Will Use

The primary tool is a modern Python installation. Examples in this series will use Python 3.12-style code, though most examples are compatible with Python 3.11.

We will introduce these tools when they become necessary:

| Tool | Purpose |
|---|---|
| `python` | Runs Python programs |
| `venv` | Creates an isolated environment for project dependencies |
| `pip` | Installs Python packages |
| `pytest` | Runs automated tests |
| `mypy` | Checks type hints without running the program |
| `pathlib` | Works safely with file system paths |
| `dataclasses` | Reduces boilerplate when modeling data |
| `collections` | Provides specialized containers |
| `itertools` | Provides efficient iterator-building tools |
| `functools` | Provides utilities for functions and decorators |

We will avoid introducing a tool merely because it is popular. Every dependency and language feature should earn its place by solving a concrete problem.

---

## A Note on “Clean” Code

Clean code is not code with the fewest lines. It is code with the lowest *confusion cost*.

For example, this is short:

```python
result = [item["name"] for item in items if item.get("active")]
```

It is also clear when the reader understands comprehensions.

But this is not automatically better:

```python
result = list(map(lambda item: item["name"], filter(lambda item: item.get("active"), items)))
```

Both may produce similar results. The first better matches common Python reading habits, while the second forces readers to mentally unpack nested function calls.

We will learn when Python’s concise forms improve clarity and when a few explicit lines are the more maintainable choice.

---

## Ground Rules for the Journey

As we build, we will follow several practical rules:

- Prefer descriptive names over cryptic abbreviations.
- Keep functions focused on one job.
- Validate input near the boundary where it enters the system.
- Raise meaningful exceptions rather than silently hiding failures.
- Use `with` blocks for resources that must be cleaned up.
- Avoid global mutable state.
- Write tests for behavior, not for incidental implementation details.
- Use type hints to document interfaces and catch mistakes early.
- Keep secrets out of source control.
- Favor standard library solutions before adding a third-party package.

These are not arbitrary restrictions. They reduce the number of surprises a program can create.

---

## The Destination

At the end of the series, you will be able to look at a Python requirement—such as “build a client for this web API”—and break it into sensible components:

```text
Requirement
    ↓
Public interface
    ↓
Data models and configuration
    ↓
Transport and error boundaries
    ↓
Tests and type checks
    ↓
Installable, maintainable package
```

More importantly, you will understand *why* each component exists.

You will be ready to replace one-off scripts with structured Python projects that scale in complexity without becoming fragile.
