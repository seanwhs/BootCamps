# Appendix G: CPython C Extension Safety Checklist

C extensions allow Python code to call compiled native code.

They can be valuable when profiling proves a bottleneck exists in:

- tight CPU loops;
- binary parsing;
- compression;
- cryptography;
- image or audio processing;
- numerical routines;
- platform-specific operating-system integrations.

However, C extensions are fundamentally different from ordinary Python modules.

A Python exception is usually recoverable.

A C extension bug can:

- crash the interpreter;
- corrupt memory;
- leak memory;
- deadlock threads;
- expose security vulnerabilities;
- create behavior that appears correct until production load.

The main rule is:

> Write native code only after profiling identifies a real bottleneck, and keep the C boundary as small as possible.

---

# 1. Before Writing C: Verify That Native Code Is Necessary

Before creating an extension, measure the existing Python implementation.

Use:

```bash
python -m cProfile -o profile.out your_script.py
```

Inspect the profile:

```bash
python -m pstats profile.out
```

Or use `tracemalloc` for allocation pressure:

```python
from pulsequeue.memory_profiler import MemorySnapshotSession

session = MemorySnapshotSession()
session.start()

run_workload()

comparison = session.compare(limit=10)

for difference in comparison.largest_differences:
    print(difference)

session.stop()
```

Ask these questions:

- Is the slow function actually responsible for meaningful total runtime?
- Can the algorithm improve in Python first?
- Can a built-in function replace custom Python loops?
- Does an existing maintained library solve the problem?
- Would a process pool provide enough performance?
- Is the work I/O-bound rather than CPU-bound?
- Is the bottleneck really Python, or is it database/network latency?

Avoid native code for premature optimization.

---

# 2. Minimal Extension Anatomy

A CPython extension module needs:

1. C source code;
2. a module definition;
3. exported methods;
4. a module initialization function;
5. build configuration.

PulseQueue’s optional extension is:

```text
src/pulsequeue/native/native_module.c
```

It exposes:

```python
from pulsequeue import _native

_native.fast_sum([10, 20, 12])
```

Expected output:

```text
42
```

---

# 3. The Most Important Concept: Reference Ownership

Every `PyObject *` pointer has an ownership rule.

There are two important categories:

| Reference type | Meaning |
|---|---|
| New reference | Your code owns one reference and must release it |
| Borrowed reference | Another object owns it; do not release it unless you first increment it |

This is the central memory-management rule of the CPython C API.

---

## New Reference

Example:

```c
PyObject *iterator = PyObject_GetIter(iterable);
```

`PyObject_GetIter(...)` returns a **new reference**.

Your C code must eventually release it:

```c
Py_DECREF(iterator);
```

unless ownership is transferred elsewhere.

Another example:

```c
PyObject *result = PyLong_FromLongLong(total);
```

`PyLong_FromLongLong(...)` creates and returns a new reference.

Returning it from the extension function transfers ownership back to the Python interpreter:

```c
return result;
```

Do not decrement it before returning:

```c
/* Incorrect. */
Py_DECREF(result);
return result;
```

That may return a pointer to an already-destroyed object.

---

## Borrowed Reference

A borrowed reference is owned by another Python object.

For example, many container-access APIs return borrowed references.

Conceptual example:

```c
PyObject *item = PyTuple_GET_ITEM(args, 0);
```

`item` is typically borrowed.

Do not do this:

```c
Py_DECREF(item);
```

because your function does not own that reference.

If you need to retain the object beyond the lifetime guaranteed by its owner, create your own owned reference:

```c
Py_INCREF(item);

/* Store or use item beyond the borrowed-reference lifetime. */

Py_DECREF(item);
```

---

# 4. The Ownership Rule in One Sentence

```text
New reference     → DECREF exactly once, unless ownership transfers.
Borrowed reference → Do not DECREF unless you first INCREF.
```

---

# 5. `Py_INCREF` and `Py_DECREF`

## Incrementing a Reference

```c
Py_INCREF(object);
```

This tells CPython:

> “I need this object to remain alive independently.”

## Decrementing a Reference

```c
Py_DECREF(object);
```

This tells CPython:

> “I am done with one owned reference.”

If the reference count reaches zero, CPython may destroy the object immediately.

## Safe Decrement

When a pointer may be `NULL`, use:

```c
Py_XDECREF(object);
```

This behaves like:

```c
if (object != NULL) {
    Py_DECREF(object);
}
```

Example cleanup pattern:

```c
PyObject *iterator = NULL;
PyObject *result = NULL;

iterator = PyObject_GetIter(iterable);

if (iterator == NULL) {
    goto cleanup;
}

/* More work here. */

result = PyLong_FromLong(42);

cleanup:
Py_XDECREF(iterator);
return result;
```

If an error occurs and `result` remains `NULL`, returning `NULL` tells Python that an exception should already be set.

---

# 6. Error Handling Contract

Most CPython C API functions use this pattern:

| Outcome | Return value |
|---|---|
| Success | Valid non-`NULL` pointer or non-negative integer |
| Failure | `NULL` pointer or `-1`, with Python exception set |

Example:

```c
PyObject *iterator = PyObject_GetIter(iterable);

if (iterator == NULL) {
    return NULL;
}
```

`PyObject_GetIter(...)` sets a Python exception automatically if the input is not iterable.

Your function should preserve that exception by returning:

```c
return NULL;
```

---

## Set Your Own Exception

When your code detects an invalid state, set a Python exception:

```c
PyErr_SetString(
    PyExc_ValueError,
    "value must be greater than zero"
);

return NULL;
```

Example:

```c
if (limit < 0) {
    PyErr_SetString(
        PyExc_ValueError,
        "limit cannot be negative"
    );
    return NULL;
}
```

---

## Do Not Return a Value with an Active Exception

Incorrect:

```c
PyErr_SetString(PyExc_ValueError, "invalid input");
return PyLong_FromLong(0);
```

A C extension must not return a normal result while an exception remains active.

Correct:

```c
PyErr_SetString(PyExc_ValueError, "invalid input");
return NULL;
```

---

# 7. Parsing Python Arguments Safely

Use `PyArg_ParseTuple(...)` for positional argument parsing.

Example:

```c
PyObject *iterable;

if (!PyArg_ParseTuple(args, "O:fast_sum", &iterable)) {
    return NULL;
}
```

Meaning:

| Format | Meaning |
|---|---|
| `O` | Any Python object |
| `:fast_sum` | Function name included in generated errors |

For a required integer:

```c
int count;

if (!PyArg_ParseTuple(args, "i:repeat", &count)) {
    return NULL;
}
```

For a required string:

```c
const char *name;

if (!PyArg_ParseTuple(args, "s:greet", &name)) {
    return NULL;
}
```

For keyword arguments, use:

```c
PyArg_ParseTupleAndKeywords(...)
```

Example:

```c
static char *keyword_names[] = {
    "value",
    "multiplier",
    NULL
};

long value;
long multiplier = 1;

if (!PyArg_ParseTupleAndKeywords(
    args,
    kwargs,
    "l|l:scale",
    keyword_names,
    &value,
    &multiplier
)) {
    return NULL;
}
```

This accepts:

```python
scale(10)
scale(10, 3)
scale(value=10, multiplier=3)
```

---

# 8. Integer Conversion Safety

This conversion:

```c
long long value = PyLong_AsLongLong(item);
```

can fail.

The special return value `-1` is ambiguous because `-1` may be a valid Python integer.

Correct pattern:

```c
long long value = PyLong_AsLongLong(item);

if (value == -1 && PyErr_Occurred()) {
    return NULL;
}
```

This asks:

> “Did conversion return `-1` because the value is genuinely `-1`, or because conversion failed?”

---

# 9. Iteration Safety Pattern

PulseQueue’s native `fast_sum(...)` demonstrates safe iteration:

```c
PyObject *iterator = PyObject_GetIter(iterable);

if (iterator == NULL) {
    return NULL;
}

while ((item = PyIter_Next(iterator)) != NULL) {
    long long value = PyLong_AsLongLong(item);

    Py_DECREF(item);

    if (value == -1 && PyErr_Occurred()) {
        Py_DECREF(iterator);
        return NULL;
    }

    total += value;
}

Py_DECREF(iterator);

if (PyErr_Occurred()) {
    return NULL;
}

return PyLong_FromLongLong(total);
```

Important facts:

- `PyObject_GetIter(...)` returns a new reference.
- `PyIter_Next(...)` returns a new reference for each item.
- Each `item` needs `Py_DECREF(item)`.
- `PyIter_Next(...)` returns `NULL` when iteration ends normally.
- `PyIter_Next(...)` also returns `NULL` when iteration fails.
- `PyErr_Occurred()` distinguishes normal completion from failure.

---

# 10. Avoid C Integer Overflow

C integer overflow can cause undefined behavior.

This is dangerous:

```c
total += value;
```

when `total + value` exceeds the range of the C integer type.

Use explicit checks:

```c
#include <limits.h>

if (
    (value > 0 && total > LLONG_MAX - value) ||
    (value < 0 && total < LLONG_MIN - value)
) {
    PyErr_SetString(
        PyExc_OverflowError,
        "sum exceeds signed 64-bit integer range"
    );
    return NULL;
}

total += value;
```

Python integers support arbitrary precision, but your C implementation may not.

Be explicit about the supported range.

---

# 11. GIL Safety

The **Global Interpreter Lock** protects many CPython interpreter operations.

You must hold the GIL when:

- accessing Python objects;
- changing Python reference counts;
- calling Python C API functions;
- creating Python exceptions;
- allocating most Python objects;
- calling Python callbacks.

---

## Releasing the GIL

For long-running native work that does not use Python objects, release the GIL:

```c
Py_BEGIN_ALLOW_THREADS

/* Native computation with no Python object access. */

Py_END_ALLOW_THREADS
```

This allows other Python threads to run while native computation continues.

Safe only if the enclosed code:

- does not access `PyObject *` values;
- does not call Python C API functions;
- does not call `Py_INCREF` or `Py_DECREF`;
- does not create Python exceptions;
- is independently thread-safe;
- does not use Python-managed memory unsafely.

---

## Unsafe GIL Release Example

Incorrect:

```c
Py_BEGIN_ALLOW_THREADS

Py_DECREF(item);
PyObject *result = PyLong_FromLong(42);

Py_END_ALLOW_THREADS
```

This is unsafe because both operations manipulate Python interpreter state.

---

# 12. Native Thread Safety Is Still Your Responsibility

Releasing the GIL does not automatically make native code safe.

If native code modifies shared state:

```c
static long global_counter = 0;
```

then several threads may race:

```c
global_counter += 1;
```

Use a native mutex or redesign to avoid shared mutable state.

The GIL does not protect native operations while it is released.

---

# 13. Module Initialization

A minimal module definition looks like this:

```c
static PyMethodDef module_methods[] = {
    {
        "fast_sum",
        fast_sum,
        METH_VARARGS,
        PyDoc_STR("Return the signed 64-bit sum of integer values.")
    },
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef module_definition = {
    PyModuleDef_HEAD_INIT,
    "_native",
    "Optional native helpers.",
    -1,
    module_methods
};

PyMODINIT_FUNC
PyInit__native(void)
{
    return PyModule_Create(&module_definition);
}
```

The initialization function name must match the extension module name.

For:

```text
pulsequeue._native
```

the initializer must be:

```c
PyInit__native
```

---

# 14. Building the PulseQueue Extension

PulseQueue uses:

```text
setup.py
```

to configure:

```python
Extension(
    name="pulsequeue._native",
    sources=["src/pulsequeue/native/native_module.c"],
)
```

Build with editable installation:

```bash
python -m pip install --editable .
```

Verify:

```bash
python -c "from pulsequeue import _native; print(_native.fast_sum([10, 20, 12]))"
```

Expected output:

```text
42
```

---

# 15. Compiler Toolchain Requirements

| Platform | Typical command or requirement |
|---|---|
| Ubuntu/Debian | `sudo apt install build-essential python3-dev` |
| Fedora | `sudo dnf install gcc python3-devel` |
| macOS | `xcode-select --install` |
| Windows | Visual Studio Build Tools with C++ desktop tools |

Verify a C compiler:

```bash
cc --version
```

On Windows, use the Visual Studio Developer Command Prompt when necessary.

---

# 16. Test Native Code Aggressively

Run the native extension tests:

```bash
python -m pytest tests/test_native_extension.py -q
```

Test normal behavior:

```bash
python -c "from pulsequeue import _native; print(_native.fast_sum([1, 2, 3]))"
```

Test invalid values:

```bash
python -c "from pulsequeue import _native; print(_native.fast_sum([1, 'two']))"
```

Expected result ends with a Python exception:

```text
TypeError: 'str' object cannot be interpreted as an integer
```

Test generator support:

```bash
python - <<'PY'
from pulsequeue import _native

print(_native.fast_sum(value for value in range(10)))
PY
```

Expected output:

```text
45
```

---

# 17. Debug Builds and Memory Tools

For serious native-extension work, use specialized tools.

## AddressSanitizer

On compatible Unix-like systems, compile with:

```text
-fsanitize=address
```

AddressSanitizer can detect:

- use-after-free;
- out-of-bounds access;
- double frees;
- some memory leaks.

## Valgrind

On Linux:

```bash
valgrind --leak-check=full python -c \
  "from pulsequeue import _native; print(_native.fast_sum([1, 2, 3]))"
```

Valgrind is slower but useful for native memory diagnosis.

## Python Debug Build

A debug CPython build can detect some reference-count and API misuse issues more aggressively than a release build.

For extension authors, test against:

- current supported Python release;
- newest Python release;
- debug builds when practical;
- Linux, macOS, and Windows if distributing binary wheels.

---

# 18. C Extension Security Checklist

- [ ] Never deserialize untrusted bytes with unsafe native parsing.
- [ ] Validate sizes before allocating buffers.
- [ ] Check all integer conversions and integer overflow paths.
- [ ] Check every C API return value.
- [ ] Return `NULL` after setting a Python exception.
- [ ] Release every owned reference exactly once.
- [ ] Never decref a borrowed reference.
- [ ] Do not access Python objects while GIL is released.
- [ ] Avoid unsafe string functions such as unchecked `strcpy`.
- [ ] Use bounded operations and explicit length values.
- [ ] Test malformed input.
- [ ] Test large input.
- [ ] Test repeated calls for leaks.
- [ ] Test failure paths, not only successful calls.
- [ ] Keep extension APIs narrow and simple.

---

# 19. C Extension Design Recommendations

Prefer this:

```text
Python validates application-level input
        ↓
C extension receives simple primitive values
        ↓
C performs a narrow optimized operation
        ↓
C returns simple Python value
```

Example:

```python
result = _native.fast_sum(values)
```

Avoid this:

```text
C extension owns task broker
C extension parses arbitrary network traffic
C extension manages Python async lifecycle
C extension stores arbitrary Python callbacks globally
```

The more Python object graphs, callbacks, threads, and lifecycle logic cross into C, the more difficult the extension becomes to reason about safely.

---

# 20. When to Prefer Other Options

Before a hand-written C extension, consider:

| Need | Consider |
|---|---|
| Numeric loops | NumPy, Numba, Cython |
| Native library wrapper | Existing maintained Python binding |
| CPU parallelism | `ProcessPoolExecutor` |
| Faster parsing | Built-in `json`, `orjson`, `msgspec`, existing libraries |
| System calls | `ctypes`, `cffi`, maintained bindings |
| Hot Python loop | Algorithm improvement, built-ins, comprehensions, standard library |

A native extension is an engineering commitment, not just a speed tweak.
