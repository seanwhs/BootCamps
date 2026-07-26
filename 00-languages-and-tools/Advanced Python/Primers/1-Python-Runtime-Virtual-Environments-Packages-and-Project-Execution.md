# Primer 1: Python Runtime, Virtual Environments, Packages, and Project Execution

Yes—primers are valuable.

The main tutorial targets experienced developers, but advanced topics become much easier when readers share the same baseline understanding of how Python finds code, installs packages, runs modules, and isolates dependencies.

This first primer establishes that baseline before readers work with metaclasses, concurrency, multiprocessing, and framework architecture.

---

## Scope

This primer explains:

- What the Python interpreter does.
- The difference between a script, module, and package.
- Why virtual environments matter.
- Why the tutorial uses a `src/` project layout.
- How editable installs work.
- Why `python -m ...` is safer than executing files directly.
- How to verify that the correct code is being imported.

---

# Step 1: Confirm the Python Runtime

## The Target

Verify that you are using a supported CPython interpreter.

## The Concept

The **Python interpreter** is the program that reads and executes Python code.

When you run:

```bash
python my_script.py
```

you are asking the interpreter to:

1. Read `my_script.py`.
2. Compile it into internal bytecode instructions.
3. Execute those instructions.
4. Import any modules the script depends on.

This series focuses on **CPython**, the standard Python implementation.

You can think of CPython as the engine in a car. Python source code is the route instruction; CPython is the engine that actually turns those instructions into movement.

Other Python implementations exist, such as PyPy, Jython, and GraalPy. They may behave differently in areas such as:

- memory management;
- garbage collection;
- runtime performance;
- C-extension compatibility;
- Global Interpreter Lock behavior.

The PulseQueue tutorial assumes CPython 3.12 or later.

## The Implementation

Run:

```bash
python --version
```

Also confirm the implementation:

```bash
python -c "import platform; print(platform.python_implementation())"
```

## The Verification

Expected output resembles:

```text
Python 3.12.4
CPython
```

If your version is below Python 3.12, install a newer version before continuing.

---

# Step 2: Create and Activate a Virtual Environment

## The Target

Create an isolated environment for this project’s packages and command-line tools.

## The Concept

A **virtual environment** is an isolated Python installation for one project.

Without one, installing a package affects your global Python environment:

```bash
python -m pip install pytest
```

That can create conflicts between projects:

```text
Project A needs package-x version 1
Project B needs package-x version 2
```

A virtual environment gives each project its own toolbox.

## The Implementation

From the project root:

```bash
python -m venv .venv
```

Activate it.

### macOS or Linux

```bash
source .venv/bin/activate
```

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

Upgrade package tooling:

```bash
python -m pip install --upgrade pip
```

## The Verification

Check the active Python executable:

```bash
python -c "import sys; print(sys.executable)"
```

Expected path shape on macOS or Linux:

```text
/path/to/mastering-python/.venv/bin/python
```

Expected path shape on Windows:

```text
C:\path\to\mastering-python\.venv\Scripts\python.exe
```

Check the active `pip` belongs to the same environment:

```bash
python -m pip --version
```

The displayed path should include:

```text
.venv
```

---

# Step 3: Understand Scripts, Modules, and Packages

## The Target

Learn the three units Python uses to organize code.

## The Concept

Python code commonly appears in three related forms.

| Term | Meaning | Example |
|---|---|---|
| Script | A Python file executed directly | `python examples/demo.py` |
| Module | A Python file imported by other code | `import pulsequeue.worker` |
| Package | A directory of modules | `src/pulsequeue/` |

A module is simply a `.py` file:

```text
src/pulsequeue/worker.py
```

Its import name is:

```python
import pulsequeue.worker
```

A package is a directory that groups modules:

```text
src/
└── pulsequeue/
    ├── __init__.py
    ├── app.py
    └── worker.py
```

The `__init__.py` file tells Python that the directory is an ordinary importable package and provides a place to define its public API.

## The Implementation

Create this small package demonstration.

## `primer_examples/package_demo/__init__.py`

```python
"""A small package used by Primer 1."""
```

## `primer_examples/package_demo/greeting.py`

```python
"""Greeting helpers used by the package demonstration."""

from __future__ import annotations


def greet(name: str) -> str:
    """Return a deterministic greeting."""
    return f"Hello, {name}."
```

## `primer_examples/package_demo/main.py`

```python
"""Run the package greeting demonstration as a module."""

from __future__ import annotations

from primer_examples.package_demo.greeting import greet


def main() -> None:
    """Print one greeting."""
    print(greet("Ada"))


if __name__ == "__main__":
    main()
```

Also create the parent package initializer.

## `primer_examples/__init__.py`

```python
"""Examples used by the PulseQueue primer series."""
```

## The Verification

Run the module from the project root:

```bash
python -m primer_examples.package_demo.main
```

Expected output:

```text
Hello, Ada.
```

---

# Step 4: Understand Why `python -m` Is Important

## The Target

Run a module in a way that preserves its package context.

## The Concept

Consider this import:

```python
from primer_examples.package_demo.greeting import greet
```

Python needs to know where the top-level package begins:

```text
mastering-python/
└── primer_examples/
```

When you run:

```bash
python -m primer_examples.package_demo.main
```

Python understands that `main.py` belongs to the `primer_examples.package_demo` package.

By contrast, directly running the file can produce import problems:

```bash
python primer_examples/package_demo/main.py
```

Depending on the working directory and imports, Python may not know how to resolve package-relative code correctly.

Think of `python -m` as giving Python the full mailing address of a module instead of handing it an unlabeled piece of paper.

## The Implementation

From the project root, run the correct command:

```bash
python -m primer_examples.package_demo.main
```

Then intentionally try the direct-file command:

```bash
python primer_examples/package_demo/main.py
```

## The Verification

The module command should always work from the project root:

```text
Hello, Ada.
```

The direct-file command may work in this specific example because the project root is on Python’s import path. However, in more complex packages it can fail or produce different import behavior.

For framework, test, and CLI code, prefer:

```bash
python -m package.module
```

Examples from this series:

```bash
python -m pytest -q
python -m pulsequeue.cli check-config
python -m examples.60_cpu_task_worker
```

---

# Step 5: Understand the `src/` Layout

## The Target

Understand why PulseQueue source code lives inside `src/pulsequeue/` rather than directly in the repository root.

## The Concept

The final project uses this layout:

```text
mastering-python/
├── pyproject.toml
├── src/
│   └── pulsequeue/
│       ├── __init__.py
│       └── worker.py
└── tests/
```

This is called the **`src/` layout**.

A common alternative is:

```text
mastering-python/
├── pulsequeue/
│   ├── __init__.py
│   └── worker.py
└── tests/
```

The `src/` layout is safer for package development because it helps reveal packaging mistakes.

Without `src/`, tests may accidentally import code from the working directory even if the package was not installed correctly.

With `src/`, Python needs an installed package or explicit import configuration to find:

```python
import pulsequeue
```

That makes tests closer to how users will run the installed package.

Think of it as testing a product from its shipping box rather than testing it only from the factory workbench.

## The Implementation

Ensure your root structure resembles:

```text
mastering-python/
├── pyproject.toml
├── src/
│   └── pulsequeue/
│       └── __init__.py
└── tests/
```

Check the package location:

```bash
find src/pulsequeue -maxdepth 1 -type f | sort
```

On Windows PowerShell:

```powershell
Get-ChildItem -File src\pulsequeue | Sort-Object Name
```

## The Verification

At minimum, you should see:

```text
src/pulsequeue/__init__.py
```

For the completed capstone, you should also see modules such as:

```text
src/pulsequeue/app.py
src/pulsequeue/broker.py
src/pulsequeue/runtime.py
src/pulsequeue/worker.py
```

---

# Step 6: Install the Package in Editable Mode

## The Target

Install the local project so Python imports `pulsequeue` from the `src/` directory.

## The Concept

An **editable install** links the environment to the project source directory.

Normal installation copies or builds a package into the environment:

```bash
python -m pip install .
```

Editable installation points the environment at your working files:

```bash
python -m pip install --editable .
```

That means changes to:

```text
src/pulsequeue/worker.py
```

become available immediately, without reinstalling after every edit.

This is ideal during framework development.

## The Implementation

From the project root:

```bash
python -m pip install --editable .
```

Verify the package import location:

```bash
python -c "import pulsequeue; print(pulsequeue.__file__)"
```

## The Verification

Expected output ends with:

```text
src/pulsequeue/__init__.py
```

For example:

```text
/path/to/mastering-python/src/pulsequeue/__init__.py
```

Also verify the package version:

```bash
python -c "import pulsequeue; print(pulsequeue.__version__)"
```

Expected output:

```text
0.1.0
```

---

# Step 7: Inspect Python’s Import Search Path

## The Target

Understand where Python looks when processing an import.

## The Concept

When Python processes:

```python
import pulsequeue
```

it searches directories listed in:

```python
sys.path
```

Inspect it:

```python
import sys

for entry in sys.path:
    print(entry)
```

The search path can include:

- the current working directory;
- installed packages in the virtual environment;
- standard library directories;
- values from `PYTHONPATH`;
- editable-install metadata.

Import mistakes often happen because Python found a different module with the same name.

For example, this file is dangerous:

```text
pulsequeue.py
```

in the project root.

It can shadow the intended package:

```text
src/pulsequeue/
```

## The Implementation

Run:

```bash
python - <<'PY'
import sys

for index, entry in enumerate(sys.path):
    print(f"{index}: {entry}")
PY
```

Then inspect the imported package:

```bash
python - <<'PY'
import pulsequeue

print(f"PulseQueue imported from: {pulsequeue.__file__}")
PY
```

## The Verification

The package path should point into your project:

```text
.../mastering-python/src/pulsequeue/__init__.py
```

If it points elsewhere, uninstall conflicting packages and reinstall your local project:

```bash
python -m pip uninstall pulsequeue
python -m pip install --editable .
```

---

# Step 8: Use a Reliable Command Pattern

## The Target

Adopt command forms that always use the currently active interpreter and package environment.

## The Concept

These commands look similar:

```bash
pip install pytest
pytest
python
```

But they may refer to different environments if your machine has multiple Python installations.

Prefer this pattern:

```bash
python -m pip install ...
python -m pytest ...
python -m package.module ...
```

This guarantees that the module runs under the same Python interpreter shown by:

```bash
python --version
```

## The Implementation

Use these commands throughout the tutorial:

Install package dependencies:

```bash
python -m pip install --editable .
```

Run tests:

```bash
python -m pytest -q
```

Run the CLI:

```bash
python -m pulsequeue.cli check-config
```

Run a numbered example module:

```bash
python -m examples.60_cpu_task_worker
```

## The Verification

Run:

```bash
python -m pulsequeue.cli check-config
```

Expected output resembles:

```json
{"settings": {"broker_max_queue_size": 1000, "cpu_processes": null, "shutdown_timeout_seconds": 30.0, "worker_concurrency": 1}, "status": "valid"}
```

---

# Primer 1 Reference: Essential Commands

| Goal | Command |
|---|---|
| Check Python version | `python --version` |
| Check Python implementation | `python -c "import platform; print(platform.python_implementation())"` |
| Create environment | `python -m venv .venv` |
| Activate on macOS/Linux | `source .venv/bin/activate` |
| Activate on Windows PowerShell | `.venv\Scripts\Activate.ps1` |
| Upgrade pip | `python -m pip install --upgrade pip` |
| Install project editable | `python -m pip install --editable .` |
| Verify package origin | `python -c "import pulsequeue; print(pulsequeue.__file__)"` |
| Run tests | `python -m pytest -q` |
| Run a module | `python -m package.module` |
| Compile source | `python -m compileall -q src` |

---

# Primer 1 Completion Checklist

Before moving to the next primer, confirm:

- [ ] `python --version` reports Python 3.12 or later.
- [ ] `platform.python_implementation()` reports `CPython`.
- [ ] Your virtual environment is active.
- [ ] `python -m pip --version` references `.venv`.
- [ ] `python -m pip install --editable .` succeeds.
- [ ] `import pulsequeue` resolves to `src/pulsequeue/__init__.py`.
- [ ] `python -m pytest -q` runs the test suite.
- [ ] You understand why `python -m ...` is preferred for package modules.
- [ ] You understand why the project uses `src/pulsequeue/`.
