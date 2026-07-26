# Appendix A: Complete Project File Tree

This appendix provides the final intended repository layout for the `pulsequeue` capstone framework.

The project uses the **`src/` layout**:

```text
mastering-python/
├── src/
│   └── pulsequeue/
```

This keeps importable application code separate from tests, examples, build configuration, and local development files.

---

## Final Repository Structure

```text
mastering-python/
├── .venv/
├── Dockerfile
├── compose.yaml
├── pyproject.toml
├── setup.py
│
├── src/
│   └── pulsequeue/
│       ├── __init__.py
│       ├── app.py
│       ├── async_queue.py
│       ├── broker.py
│       ├── builtin_plugins.py
│       ├── cli.py
│       ├── config.py
│       ├── cpu_task.py
│       ├── descriptors.py
│       ├── envelope.py
│       ├── events.py
│       ├── execution.py
│       ├── executors.py
│       ├── health.py
│       ├── lifecycle.py
│       ├── loader.py
│       ├── logging.py
│       ├── memory.py
│       ├── memory_profiler.py
│       ├── metadata.py
│       ├── model.py
│       ├── namespace.py
│       ├── observers.py
│       ├── options.py
│       ├── plugins.py
│       ├── registry.py
│       ├── result.py
│       ├── result_backends.py
│       ├── retention.py
│       ├── runtime.py
│       ├── serialization.py
│       ├── task.py
│       ├── timeouts.py
│       ├── transformers.py
│       ├── typing.py
│       ├── worker.py
│       │
│       └── native/
│           └── native_module.c
│
├── examples/
│   ├── __init__.py
│   ├── 01_class_body_execution.py
│   ├── 02_descriptor_validation.py
│   ├── 03_metaclass_registry.py
│   ├── 04_introspection.py
│   ├── 05_attribute_hooks.py
│   ├── 06_task_metadata.py
│   ├── 07_attribute_namespace.py
│   ├── 08_computed_property.py
│   ├── 09_task_options.py
│   ├── 10_function_introspection.py
│   ├── 11_async_decorator.py
│   ├── 12_task_object.py
│   ├── 13_task_registry.py
│   ├── 14_decorator_registration.py
│   ├── 15_gil_threads.py
│   ├── 16_workload_kinds.py
│   ├── 17_blocking_io_thread.py
│   ├── 18_cpu_bound_process.py
│   ├── 19_process_pool_lifecycle.py
│   ├── 20_coroutine_scheduling.py
│   ├── 21_cancellation_cleanup.py
│   ├── 22_timeouts.py
│   ├── 23_bounded_async_queue.py
│   ├── 24_queue_backpressure.py
│   ├── 25_task_result_states.py
│   ├── 26_task_envelope.py
│   ├── 27_in_memory_broker.py
│   ├── 28_application_submission.py
│   ├── 29_first_async_worker.py
│   ├── 30_task_failures_and_timeouts.py
│   ├── 31_retry_configuration.py
│   ├── 32_successful_retry.py
│   ├── 33_retry_exhaustion.py
│   ├── 34_shutdown_modes.py
│   ├── 35_reference_counting.py
│   ├── 36_immediate_cleanup.py
│   ├── 37_reference_cycles.py
│   ├── 38_weak_observers.py
│   ├── 39_gc_diagnostics.py
│   ├── 40_instance_dictionary.py
│   ├── 41_slots_event_model.py
│   ├── 42_slots_size_comparison.py
│   ├── 43_tracemalloc_slots.py
│   ├── 44_slots_inheritance.py
│   ├── 45_memory_snapshot_comparison.py
│   ├── 46_memory_growth_workload.py
│   ├── 47_bounded_retention.py
│   ├── 48_protocol_basics.py
│   ├── 49_generic_transformers.py
│   ├── 50_plugin_lifecycle.py
│   ├── 51_builtin_plugins.py
│   ├── 52_plugin_startup_rollback.py
│   ├── 53_plugin_aware_worker.py
│   ├── 54_plugin_failure_isolation.py
│   ├── 55_runtime_context_manager.py
│   ├── 56_typed_runtime_configuration.py
│   ├── 57_counting_result_backend.py
│   ├── 58_task_envelope_serialization.py
│   ├── 59_cpu_task_definition.py
│   ├── 60_cpu_task_worker.py
│   ├── 61_structured_logging.py
│   ├── 62_runtime_health.py
│   ├── capstone_cpu_functions.py
│   ├── cpu_functions.py
│   └── worker_application.py
│
└── tests/
    ├── __init__.py
    ├── cpu_functions.py
    ├── process_functions.py
    ├── test_async_primitives.py
    ├── test_broker_and_worker.py
    ├── test_configuration_and_result_backends.py
    ├── test_dynamic_attributes.py
    ├── test_events.py
    ├── test_execution.py
    ├── test_memory_and_observers.py
    ├── test_memory_profiler_and_retention.py
    ├── test_native_extension.py
    ├── test_operations.py
    ├── test_plugins_and_protocols.py
    ├── test_retries_and_shutdown.py
    ├── test_serialization_and_cpu_tasks.py
    ├── test_task_registration.py
    └── test_worker_plugins_and_runtime.py
```

---

# Root-Level Files

## `.venv/`

The local Python virtual environment.

It is created with:

```bash
python -m venv .venv
```

Do not commit this directory to Git. Add it to `.gitignore`.

---

## `pyproject.toml`

The modern Python packaging configuration.

It defines:

- build-system requirements;
- package metadata;
- Python version requirement;
- source package location;
- CLI entry point.

The important CLI section is:

```toml
[project.scripts]
pulsequeue = "pulsequeue.cli:main"
```

After installation, this allows:

```bash
pulsequeue check-config
pulsequeue --app examples.worker_application:app inspect
pulsequeue --app examples.worker_application:app run
```

---

## `setup.py`

Build configuration for the optional C extension:

```text
pulsequeue._native
```

It points setuptools to:

```text
src/pulsequeue/native/native_module.c
```

This file exists because the C extension needs explicit `Extension(...)` configuration.

---

## `Dockerfile`

Defines a container image for the PulseQueue worker process.

It:

- starts from Python 3.12;
- installs build tooling for the optional C extension;
- installs the package;
- creates and uses a non-root user;
- sets runtime environment defaults;
- starts the worker CLI.

---

## `compose.yaml`

A local Docker Compose configuration for the worker process.

It configures:

- worker concurrency;
- CPU process count;
- queue capacity;
- shutdown timeout;
- container health checks;
- graceful stop period.

Because the tutorial broker is in-memory, Compose demonstrates operational lifecycle only. It does not provide a shared distributed queue.

---

# Framework Package: `src/pulsequeue/`

## `__init__.py`

The public package API.

This file should export stable user-facing objects:

```python
from pulsequeue import (
    PulseQueue,
    PulseQueueRuntime,
    PulseQueueWorker,
    PulseQueueSettings,
)
```

Internal modules should generally be imported directly only when a user needs advanced extension behavior.

---

## `app.py`

Defines:

```python
PulseQueue
```

This is the framework’s main application object.

Responsibilities:

- own task registration;
- expose `@app.task(...)`;
- expose `@app.cpu_task(...)`;
- validate task names and queues;
- submit validated task calls to a broker;
- expose task introspection.

Example:

```python
app = PulseQueue("notifications")


@app.task(queue="emails")
async def send_email(user_id: int) -> str:
    return f"Sent email to {user_id}"
```

---

## `async_queue.py`

Defines bounded asynchronous queue infrastructure.

Key objects:

```python
AsyncWorkQueue
QueueClosedError
QueueStats
STOP_SIGNAL
```

Responsibilities:

- bound queue size;
- apply producer backpressure;
- track unfinished work;
- close submissions;
- signal consumers to stop;
- drain pending work during forced shutdown.

---

## `broker.py`

Defines:

```python
InMemoryBroker
```

Responsibilities:

- create task IDs;
- create task envelopes;
- enqueue work;
- delegate task state to a `ResultBackend`;
- provide worker queue access;
- cancel pending tasks during forced shutdown.

It is intentionally process-local and non-durable.

---

## `builtin_plugins.py`

Contains ready-to-use plugin implementations:

```python
ConsoleEventPlugin
InMemoryEventPlugin
```

`ConsoleEventPlugin` prints lifecycle events.

`InMemoryEventPlugin` stores immutable `TaskEvent` objects for tests, demos, and local diagnostics.

---

## `cli.py`

Defines the `pulsequeue` command-line interface.

Commands:

```bash
pulsequeue check-config
pulsequeue --app package.module:app inspect
pulsequeue --app package.module:app run
pulsequeue --app package.module:app submit-local task.name
```

It also installs signal handlers for:

```text
SIGINT
SIGTERM
```

so long-running worker processes stop gracefully.

---

## `config.py`

Defines:

```python
PulseQueueSettings
```

Responsibilities:

- parse environment variables;
- validate values once;
- provide immutable typed runtime configuration.

Environment variables:

```text
PULSEQUEUE_WORKER_CONCURRENCY
PULSEQUEUE_BROKER_MAX_QUEUE_SIZE
PULSEQUEUE_CPU_PROCESSES
PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS
```

---

## `cpu_task.py`

Defines:

```python
CpuTask
```

A `CpuTask` wraps an ordinary synchronous function intended for process execution.

Rules enforced by this module:

- task function must use `def`, not `async def`;
- function must be module-level;
- function cannot be a lambda;
- function arguments are validated by signature before submission.

---

## `descriptors.py`

Defines descriptor utilities, including:

```python
computed_property
```

This demonstrates and supports read-only computed values implemented through Python’s descriptor protocol.

---

## `envelope.py`

Defines:

```python
TaskEnvelope
```

A task envelope is the immutable message that flows through the broker.

It contains:

- task ID;
- task name;
- positional arguments;
- keyword arguments;
- submission timestamp.

---

## `events.py`

Defines:

```python
TaskEvent
TaskEventType
```

Task events are immutable, slot-based lifecycle records.

Typical event types:

```text
task.submitted
task.started
task.retrying
task.succeeded
task.failed
task.cancelled
```

---

## `execution.py`

Defines workload execution helpers:

```python
WorkloadKind
run_blocking_io
run_cpu_bound
```

Responsibilities:

- classify workloads;
- move blocking I/O into a thread;
- move CPU-bound work into a process executor.

---

## `executors.py`

Defines:

```python
ProcessExecutorPool
```

This owns a reusable `ProcessPoolExecutor` through an asynchronous lifecycle.

It prevents per-task process startup and ensures clean process shutdown.

---

## `health.py`

Defines:

```python
RuntimeHealth
runtime_health
```

Responsibilities:

- expose runtime state;
- expose worker counters;
- expose queue status;
- provide JSON-compatible health output.

---

## `lifecycle.py`

Contains lower-level asynchronous lifecycle examples and helpers.

Key objects:

```python
AsyncResource
ResourceStateError
```

This module teaches cancellation-safe resource acquisition and cleanup with async context managers.

---

## `loader.py`

Defines:

```python
load_application
ApplicationLoadError
```

It loads a PulseQueue app using deployment-friendly syntax:

```text
package.module:attribute
```

For example:

```python
app = load_application("examples.worker_application:app")
```

---

## `logging.py`

Defines:

```python
JsonLogFormatter
configure_logging
```

Responsibilities:

- configure the `pulsequeue` logger hierarchy;
- emit JSON logs in production;
- support plain-text logs during local development;
- serialize extra logging fields safely.

---

## `memory.py`

Defines garbage-collection diagnostics:

```python
GarbageCollectionStats
garbage_collection_stats
collect_cycles
```

Useful for investigating CPython cyclic garbage collection behavior.

---

## `memory_profiler.py`

Defines `tracemalloc` comparison utilities:

```python
MemorySnapshotSession
MemoryComparison
AllocationDifference
```

Use this module to compare allocations before and after workloads.

---

## `metadata.py`

Defines controlled dynamic metadata:

```python
TaskMetadata
MetadataField
```

It permits only declared metadata fields such as:

```text
owner
service
environment
priority
trace_id
```

This prevents silent spelling mistakes and unsupported arbitrary fields.

---

## `model.py`

Defines metaprogramming model primitives:

```python
Field
Model
ModelMeta
```

Responsibilities:

- descriptor-backed field validation;
- field collection at class creation time;
- subclass registration;
- inherited model field support.

---

## `namespace.py`

Defines:

```python
AttributeNamespace
```

This exposes read-only nested mappings through attribute access.

Example:

```python
app.tasks.emails.send_welcome_email
```

It supports `dir(...)` for interactive discoverability and rejects mutation.

---

## `observers.py`

Defines:

```python
TaskObserverRegistry
```

It stores bound observer methods with weak references so long-lived registries do not accidentally retain short-lived objects.

---

## `options.py`

Defines:

```python
TaskOptions
```

Task configuration includes:

- task name;
- queue name;
- retry settings;
- timeout;
- metadata;
- calculated maximum attempts;
- exponential-backoff delay calculation.

---

## `plugins.py`

Defines the plugin lifecycle system:

```python
PluginRegistry
PluginRegistryState
PluginRegistryStats
DuplicatePluginError
PluginLifecycleError
```

Responsibilities:

- register plugins;
- reject duplicate names;
- start plugins in registration order;
- roll back prior plugins after startup failure;
- stop plugins in reverse order;
- publish task events.

---

## `registry.py`

Defines:

```python
TaskRegistry
RegisteredTask
DuplicateTaskError
UnknownTaskError
```

The registry stores both:

```python
Task
CpuTask
```

and provides lookup by stable queue-qualified task name.

---

## `result.py`

Defines task-state and result-backend infrastructure:

```python
TaskState
TaskFailure
TaskResultSnapshot
TaskReceipt
ResultBackend
InMemoryResultStore
```

The `ResultBackend` protocol allows future storage implementations such as Redis or PostgreSQL.

---

## `result_backends.py`

Defines backend decorators and alternative backend implementations.

Current implementation:

```python
CountingResultBackend
```

It wraps another backend and tracks lifecycle transition counts.

---

## `retention.py`

Defines:

```python
BoundedRetentionStore
```

A fixed-capacity storage utility that evicts oldest entries first.

Useful for preventing unlimited in-memory history retention.

---

## `runtime.py`

Defines:

```python
PulseQueueRuntime
```

This is the high-level async context manager that combines:

- application;
- broker;
- worker;
- optional plugin registry;
- optional result backend;
- typed settings.

Typical usage:

```python
async with PulseQueueRuntime(app) as runtime:
    receipt = await runtime.submit("math.add", 20, 22)
    result = await receipt.result()
```

---

## `serialization.py`

Defines safe JSON task-message serialization:

```python
TaskSerializationError
ensure_json_value
envelope_to_json
envelope_from_json
```

This module intentionally does not use `pickle`.

It validates that task payloads contain only JSON-compatible data.

---

## `task.py`

Defines:

```python
Task
```

A `Task` wraps an `async def` function.

Responsibilities:

- validate coroutine function usage;
- preserve function metadata;
- capture function signature;
- validate arguments;
- expose task configuration and introspection.

---

## `timeouts.py`

Defines:

```python
OperationTimeoutError
await_with_timeout
```

This gives task execution a consistent timeout boundary.

A timeout of zero means no timeout.

---

## `transformers.py`

Defines generic transformation helpers:

```python
IdentityTransformer
TaskEventDictionaryTransformer
TaskResultDictionaryTransformer
apply_transformer
```

These demonstrate generic typing and convert internal records to JSON-compatible dictionaries.

---

## `typing.py`

Defines protocol contracts:

```python
EventSink
ResultTransformer
LifecyclePlugin
```

These are extension interfaces used by plugins and other framework components.

---

## `worker.py`

Defines:

```python
PulseQueueWorker
WorkerState
WorkerStats
```

This is the execution engine.

Responsibilities:

- run async consumer loops;
- start and stop plugins;
- own CPU process pool lifecycle;
- execute `Task` objects with `asyncio`;
- execute `CpuTask` objects in child processes;
- apply retries and exponential backoff;
- enforce task timeouts;
- publish lifecycle events;
- perform graceful or forced shutdown.

---

## `native/native_module.c`

The optional CPython C extension implementation.

Exports:

```python
pulsequeue._native.fast_sum(...)
```

This file demonstrates:

- CPython C API basics;
- new versus borrowed references;
- `Py_DECREF`;
- exception propagation;
- native module initialization.

---

# Examples Directory: `examples/`

The `examples/` directory contains runnable scripts for every major tutorial step.

## Naming Convention

Files are numbered in learning order:

```text
01_...
02_...
03_...
```

This allows readers to follow the series linearly.

Later files demonstrate assembled components, while early files isolate one Python language feature at a time.

---

## Early Language and Metaprogramming Examples

| File | Focus |
|---|---|
| `01_class_body_execution.py` | Executable class bodies |
| `02_descriptor_validation.py` | Descriptor validation |
| `03_metaclass_registry.py` | Metaclass field collection |
| `04_introspection.py` | Classes, metaclasses, MRO |
| `05_attribute_hooks.py` | `__getattr__`, `__getattribute__`, `__setattr__` |
| `06_task_metadata.py` | Controlled metadata attributes |
| `07_attribute_namespace.py` | Read-only dynamic namespaces |
| `08_computed_property.py` | Custom descriptor properties |
| `09_task_options.py` | Task options and metadata access |
| `10_function_introspection.py` | Function signatures |
| `11_async_decorator.py` | Metadata-preserving decorators |
| `12_task_object.py` | Direct `Task` construction |
| `13_task_registry.py` | Registry and namespace lookup |
| `14_decorator_registration.py` | `@app.task(...)` registration |

---

## Concurrency Examples

| File | Focus |
|---|---|
| `15_gil_threads.py` | GIL behavior with CPU-bound threads |
| `16_workload_kinds.py` | Workload classification |
| `17_blocking_io_thread.py` | Blocking I/O in a thread |
| `18_cpu_bound_process.py` | Process-based CPU execution |
| `19_process_pool_lifecycle.py` | Process executor lifecycle |
| `20_coroutine_scheduling.py` | Cooperative scheduling |
| `21_cancellation_cleanup.py` | Cancellation-safe cleanup |
| `22_timeouts.py` | Timeout boundaries |
| `23_bounded_async_queue.py` | Producer/consumer queue |
| `24_queue_backpressure.py` | Bounded queue backpressure |
| `25_task_result_states.py` | Task result lifecycle |
| `26_task_envelope.py` | Immutable envelope messages |
| `27_in_memory_broker.py` | Broker behavior |
| `28_application_submission.py` | Validated task submission |
| `29_first_async_worker.py` | Initial worker execution |
| `30_task_failures_and_timeouts.py` | Worker failure handling |
| `31_retry_configuration.py` | Backoff configuration |
| `32_successful_retry.py` | Retry then success |
| `33_retry_exhaustion.py` | Retry budget exhaustion |
| `34_shutdown_modes.py` | Graceful and forced shutdown |

---

## Memory and CPython Examples

| File | Focus |
|---|---|
| `35_reference_counting.py` | Reference count behavior |
| `36_immediate_cleanup.py` | CPython object cleanup |
| `37_reference_cycles.py` | Cyclic garbage collection |
| `38_weak_observers.py` | Weak-reference observers |
| `39_gc_diagnostics.py` | GC statistics |
| `40_instance_dictionary.py` | Normal object dictionaries |
| `41_slots_event_model.py` | Slot-based immutable events |
| `42_slots_size_comparison.py` | Shallow object-size comparison |
| `43_tracemalloc_slots.py` | Allocation comparison |
| `44_slots_inheritance.py` | Slot inheritance rules |
| `45_memory_snapshot_comparison.py` | `tracemalloc` snapshots |
| `46_memory_growth_workload.py` | Healthy versus retained allocations |
| `47_bounded_retention.py` | Bounded history storage |

---

## Typing, Plugin, and Runtime Examples

| File | Focus |
|---|---|
| `48_protocol_basics.py` | Structural protocol compatibility |
| `49_generic_transformers.py` | Generic transformers |
| `50_plugin_lifecycle.py` | Plugin startup and reverse shutdown |
| `51_builtin_plugins.py` | Console and in-memory plugins |
| `52_plugin_startup_rollback.py` | Startup rollback |
| `53_plugin_aware_worker.py` | Worker event publishing |
| `54_plugin_failure_isolation.py` | Plugin failure isolation |
| `55_runtime_context_manager.py` | High-level runtime |
| `56_typed_runtime_configuration.py` | Typed settings |
| `57_counting_result_backend.py` | Result backend decorator |

---

## Final Capstone and Operations Examples

| File | Focus |
|---|---|
| `58_task_envelope_serialization.py` | JSON task serialization |
| `59_cpu_task_definition.py` | CPU task registration |
| `60_cpu_task_worker.py` | CPU task execution |
| `61_structured_logging.py` | JSON logs |
| `62_runtime_health.py` | Runtime health snapshots |
| `worker_application.py` | CLI-loadable app |
| `capstone_cpu_functions.py` | Process-importable CPU functions |
| `cpu_functions.py` | Earlier multiprocessing helpers |

---

# Tests Directory: `tests/`

The `tests/` directory verifies framework behavior.

Run the complete suite from the project root:

```bash
python -m pytest -q
```

## Test Modules

| File | Coverage |
|---|---|
| `test_async_primitives.py` | Queues, lifecycle, timeouts |
| `test_broker_and_worker.py` | Submission, broker, worker execution |
| `test_configuration_and_result_backends.py` | Environment settings and backend decorators |
| `test_dynamic_attributes.py` | Metadata and dynamic APIs |
| `test_events.py` | Immutable task events |
| `test_execution.py` | Thread and process execution helpers |
| `test_memory_and_observers.py` | GC diagnostics and weak observers |
| `test_memory_profiler_and_retention.py` | Memory snapshots and bounded retention |
| `test_native_extension.py` | Optional C extension |
| `test_operations.py` | Health, loader, CLI |
| `test_plugins_and_protocols.py` | Protocols and plugin lifecycle |
| `test_retries_and_shutdown.py` | Retries and forced cancellation |
| `test_serialization_and_cpu_tasks.py` | JSON task messages and CPU tasks |
| `test_task_registration.py` | Decorators, task validation, registration |
| `test_worker_plugins_and_runtime.py` | Worker event publication and runtime lifecycle |

## Test Helper Modules

| File | Purpose |
|---|---|
| `tests/__init__.py` | Makes test helpers importable |
| `tests/cpu_functions.py` | Module-level CPU functions for process tests |
| `tests/process_functions.py` | Module-level multiprocessing test functions |

---

# Recommended `.gitignore`

The final project should include a `.gitignore` file.

## `.gitignore`

```gitignore
# Python bytecode and caches
__pycache__/
*.py[cod]
*$py.class

# Virtual environments
.venv/
venv/

# Test and coverage output
.pytest_cache/
.coverage
htmlcov/

# Type checker caches
.mypy_cache/
.pyright/
.ruff_cache/

# Build artifacts
build/
dist/
*.egg-info/

# Native extension build products
*.so
*.pyd
*.dll
*.dylib

# Environment files and secrets
.env
.env.*
!.env.example

# Editor and operating-system files
.vscode/
.idea/
.DS_Store
```

---

# Recommended Root Commands

From `mastering-python/`, these are the most useful commands.

Install the package in editable mode:

```bash
python -m pip install --editable .
```

Run all tests:

```bash
python -m pytest -q
```

Compile source files:

```bash
python -m compileall -q src
```

Inspect a CLI application:

```bash
pulsequeue --app examples.worker_application:app inspect
```

Validate environment configuration:

```bash
pulsequeue check-config
```

Execute an async task locally:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  examples.greet \
  --args '["Ada"]'
```

Execute a CPU task locally:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  analytics.square \
  --args '[12]'
```

Start a local long-running worker:

```bash
pulsequeue --app examples.worker_application:app run
```
