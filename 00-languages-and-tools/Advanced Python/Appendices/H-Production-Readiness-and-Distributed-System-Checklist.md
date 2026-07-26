# Appendix H: Production Readiness and Distributed-System Checklist

The completed `pulsequeue` capstone is production-minded, but its default broker is intentionally in-memory.

Before deploying a task system for real business workloads, distinguish between:

```text
Framework correctness
```

and:

```text
Distributed production reliability
```

A single-process in-memory queue is excellent for:

- tests;
- tutorials;
- development;
- embedded local jobs;
- process-local background work.

It is not sufficient for:

- multiple worker processes;
- multiple machines;
- durable task delivery;
- restarts without task loss;
- reliable delayed retries;
- audit-grade job history.

This appendix is a checklist for the next production layer.

---

# 1. Distributed Architecture Target

A durable production architecture commonly looks like this:

```text
┌───────────────────────┐
│ Application / API     │
│ Producer              │
└───────────┬───────────┘
            │ authenticated, serialized messages
            ▼
┌───────────────────────┐
│ Durable Message Broker│
│ Redis / RabbitMQ /    │
│ SQS / Kafka / DB      │
└───────────┬───────────┘
            │ leased or acknowledged messages
            ▼
┌───────────────────────┐
│ Worker Fleet          │
│ Multiple processes or │
│ containers            │
└───────────┬───────────┘
            │
      ┌─────┴──────────┐
      ▼                ▼
┌──────────────┐  ┌──────────────────┐
│ Result Store │  │ External Systems │
│ PostgreSQL,  │  │ APIs, email, DB, │
│ Redis, etc.  │  │ file storage     │
└──────────────┘  └──────────────────┘
```

The task registration, task envelope, result backend protocol, plugin system, and serialization boundary already created in PulseQueue are designed to support this direction.

---

# 2. Delivery Guarantees

Task delivery guarantees must be explicit.

| Guarantee | Meaning | Typical complexity |
|---|---|---|
| At-most-once | Task may be lost, but never intentionally redelivered | Lower |
| At-least-once | Task can be redelivered after failure | Common |
| Exactly-once | Task executes one time only | Very difficult |
| Effectively-once | Duplicates possible, but business outcome remains safe | Recommended goal |

Most practical distributed task systems provide **at-least-once delivery**.

That means this can happen:

```text
Worker receives task
        ↓
Worker completes external side effect
        ↓
Worker crashes before acknowledgement
        ↓
Broker redelivers task
        ↓
Task executes again
```

Therefore task handlers must be designed for duplicate delivery.

---

# 3. Idempotency

An **idempotent** operation produces the same final business result even if it runs more than once.

Bad example:

```python
@app.task(queue="billing")
async def charge_customer(customer_id: str, amount_cents: int) -> None:
    await payment_provider.charge(customer_id, amount_cents)
```

If the task runs twice, the customer may be charged twice.

Better approach: use a stable idempotency key.

```python
@app.task(queue="billing")
async def charge_customer(
    invoice_id: str,
    customer_id: str,
    amount_cents: int,
) -> None:
    await payment_provider.charge(
        customer_id=customer_id,
        amount_cents=amount_cents,
        idempotency_key=f"invoice:{invoice_id}",
    )
```

The payment provider or your own database must enforce uniqueness for that key.

## Idempotency Checklist

- [ ] Every externally visible side effect has a stable business identifier.
- [ ] Payment, email, provisioning, and deletion tasks tolerate duplicate delivery.
- [ ] Database writes use unique constraints or upserts where appropriate.
- [ ] Result records distinguish task attempt IDs from business operation IDs.
- [ ] Retries do not create duplicate external records.

---

# 4. Message Acknowledgement

A durable broker must define when a task is acknowledged.

## Unsafe Pattern

```text
Worker receives message
        ↓
Worker acknowledges immediately
        ↓
Worker crashes during execution
        ↓
Task is lost
```

## Safer Pattern

```text
Worker receives message
        ↓
Worker executes task
        ↓
Worker records terminal result
        ↓
Worker acknowledges message
```

If the worker crashes before acknowledgement, the broker may redeliver the message.

That is why idempotency is required.

## Checklist

- [ ] Acknowledge only after task outcome is durably recorded.
- [ ] Define behavior for worker crash before acknowledgement.
- [ ] Define lease or visibility timeout duration.
- [ ] Extend lease for genuinely long-running tasks where supported.
- [ ] Monitor redelivery count.
- [ ] Avoid acknowledging messages before external side effects complete.

---

# 5. Visibility Timeouts and Leases

Many brokers use a visibility timeout or lease.

```text
Broker gives message to worker
        ↓
Message becomes invisible to other workers temporarily
        ↓
Worker must acknowledge before lease expires
        ↓
Otherwise broker makes message visible again
```

Choose lease durations carefully.

Too short:

```text
Task still running
        ↓
Lease expires
        ↓
Another worker receives duplicate
```

Too long:

```text
Worker crashes
        ↓
Broker waits too long before redelivery
```

For long tasks, prefer:

- smaller task units;
- heartbeat or lease renewal;
- externally tracked operation state;
- explicit task timeouts.

---

# 6. Retry Policy

Not every failure should retry.

## Usually Retryable

```text
ConnectionError
Temporary DNS failure
HTTP 408 request timeout
HTTP 429 rate limit
HTTP 502 / 503 / 504
Database connection reset
Temporary storage outage
```

## Usually Not Retryable

```text
TypeError
Validation error
Permission error
Authentication failure
Unknown task
Missing required record
Malformed payload
Schema mismatch
```

A production task policy should declare this explicitly.

Conceptual design:

```python
retry_for = (
    ConnectionError,
    TimeoutError,
)

do_not_retry_for = (
    ValueError,
    PermissionError,
)
```

## Retry Checklist

- [ ] Retry only known transient failures.
- [ ] Use exponential backoff.
- [ ] Add random jitter in distributed deployments.
- [ ] Set a maximum retry count.
- [ ] Set a maximum total retry age.
- [ ] Record final failure with useful context.
- [ ] Avoid retrying invalid input.
- [ ] Monitor retry rate by task name and exception type.

---

# 7. Add Jitter to Backoff

Without jitter, many tasks can retry simultaneously:

```text
10,000 tasks fail at 12:00:00
        ↓
10,000 tasks retry at 12:00:01
        ↓
Dependency receives another traffic spike
```

With jitter, retry delays spread out.

Example implementation:

```python
from __future__ import annotations

import random


def jittered_delay(
    base_delay_seconds: float,
    *,
    jitter_ratio: float = 0.2,
) -> float:
    """Return delay adjusted by a bounded random percentage."""
    if base_delay_seconds < 0:
        raise ValueError("base_delay_seconds must be zero or greater.")

    if not 0 <= jitter_ratio <= 1:
        raise ValueError("jitter_ratio must be between 0 and 1.")

    adjustment = random.uniform(-jitter_ratio, jitter_ratio)

    return base_delay_seconds * (1 + adjustment)
```

Example:

```python
delay = jittered_delay(10.0, jitter_ratio=0.2)
```

The result falls between approximately:

```text
8.0 and 12.0 seconds
```

Use a cryptographically secure random generator only when retry timing itself has a security-sensitive purpose. Ordinary retry jitter can use `random`.

---

# 8. Dead-Letter Queues

A **dead-letter queue**, often shortened to DLQ, stores messages that cannot be processed normally.

Examples:

- task exceeded retry budget;
- message schema is invalid;
- task name is unknown;
- payload cannot deserialize;
- task repeatedly violates timeout;
- worker cannot route the task.

Architecture:

```text
Main queue
    │
    ├── success → acknowledgement
    │
    ├── transient failure → delayed retry queue
    │
    └── permanent failure → dead-letter queue
```

## DLQ Checklist

- [ ] Store original task message unchanged.
- [ ] Include failure reason and timestamp.
- [ ] Include attempt count and worker identity.
- [ ] Set retention period.
- [ ] Provide an inspection and replay workflow.
- [ ] Require review before blindly replaying messages.
- [ ] Alert when DLQ volume rises unexpectedly.

---

# 9. Message Schema Versioning

Task messages evolve.

Initial schema:

```json
{
  "task_id": "task-001",
  "task_name": "emails.send_welcome_email",
  "args": [42],
  "kwargs": {},
  "submitted_at": "2026-07-24T12:00:00+00:00"
}
```

A later release may need:

```json
{
  "schema_version": 2,
  "task_id": "task-001",
  "task_name": "emails.send_welcome_email",
  "args": [42],
  "kwargs": {},
  "submitted_at": "2026-07-24T12:00:00+00:00",
  "trace_context": {
    "trace_id": "abc"
  }
}
```

Add an explicit schema version before deploying message producers and workers independently.

```python
MESSAGE_SCHEMA_VERSION = 1
```

## Versioning Checklist

- [ ] Add `schema_version` to durable messages.
- [ ] Make consumers accept compatible older versions during rollout.
- [ ] Reject unknown future versions safely.
- [ ] Do not repurpose fields with changed meanings.
- [ ] Preserve old task names during migration where necessary.
- [ ] Test producer-new/worker-old and producer-old/worker-new combinations.

---

# 10. Serialization Rules

PulseQueue’s JSON serializer intentionally rejects unsupported objects.

Good task arguments:

```python
{
    "user_id": 42,
    "locale": "en-GB",
    "tags": ["onboarding", "priority"],
}
```

Unsafe or unsuitable message values:

```python
datetime.now()          # Convert to ISO-8601 text first.
set(["a", "b"])         # Convert to sorted list.
database_connection     # Never serialize live connections.
lambda: None            # Never serialize executable code.
open("file.txt")        # Never serialize file handles.
```

Convert dates deliberately:

```python
from datetime import UTC, datetime


payload = {
    "created_at": datetime.now(UTC).isoformat(),
}
```

## Serialization Checklist

- [ ] Use JSON, MessagePack, Protobuf, Avro, or another deliberate data format.
- [ ] Do not use `pickle` for untrusted task messages.
- [ ] Validate message shape before execution.
- [ ] Enforce payload-size limits.
- [ ] Reject unknown task names.
- [ ] Avoid serializing secrets.
- [ ] Version message schemas.
- [ ] Canonicalize timestamps with timezone information.

---

# 11. Authentication and Transport Security

A broker is a command channel. Anyone who can publish a task may be able to trigger business operations.

Protect it accordingly.

## Checklist

- [ ] Require broker authentication.
- [ ] Use TLS for producer-to-broker connections.
- [ ] Use TLS for worker-to-broker connections.
- [ ] Use distinct credentials for producers and workers.
- [ ] Restrict publish permissions by queue or topic.
- [ ] Restrict consume permissions by queue or topic.
- [ ] Rotate credentials.
- [ ] Store credentials in a secret manager, not source code.
- [ ] Audit task submission where required.
- [ ] Do not expose broker ports publicly without a deliberate security model.

---

# 12. Result Backend Design

A production result backend needs retention rules.

Potential backend choices:

| Backend | Strengths | Risks |
|---|---|---|
| Redis | Fast state lookup, TTL support | Memory cost, eviction policy |
| PostgreSQL | Durable queries and audits | Higher write overhead |
| SQLite | Simple single-node setup | Limited concurrent write scaling |
| Object storage | Cheap long-term archival | Slower reads |
| No result backend | Minimal overhead | Callers cannot query final state |

## Result Retention Checklist

- [ ] Define result TTL.
- [ ] Define maximum result storage size.
- [ ] Avoid retaining raw exception tracebacks indefinitely.
- [ ] Store sanitized failure summaries.
- [ ] Delete or archive stale results.
- [ ] Protect result lookup with authorization where needed.
- [ ] Separate business audit history from short-lived task status.

---

# 13. Observability

A task system should emit enough data to answer:

```text
What is running?
What is delayed?
What is failing?
What is retrying?
What is stuck?
What is consuming memory?
```

## Core Metrics

| Metric | Labels |
|---|---|
| Task submitted count | task name, queue |
| Task completed count | task name, queue |
| Task failed count | task name, exception type |
| Task retry count | task name, attempt |
| Task cancelled count | task name |
| Task duration | task name, queue |
| Queue depth | queue |
| Queue wait time | queue |
| Active worker count | worker type |
| Event plugin failure count | plugin name |
| DLQ count | queue, reason |

## Logging Fields

Use structured fields such as:

```json
{
  "task_id": "task-001",
  "task_name": "emails.send_welcome_email",
  "queue": "emails",
  "attempt": 2,
  "worker_id": "worker-a",
  "duration_ms": 124,
  "state": "succeeded"
}
```

Avoid logging:

```text
Passwords
Access tokens
Session cookies
Raw personal data
Payment details
Entire task payloads by default
```

---

# 14. Distributed Tracing

For request-to-task tracing, carry trace context in task metadata or a dedicated message field.

Conceptual flow:

```text
HTTP request
    ↓ trace ID
Task submission
    ↓ serialized trace context
Worker receives task
    ↓ child span
External API call
```

A production trace context usually includes:

```text
trace_id
span_id
sampling decision
trace flags
```

Do not invent a tracing protocol if your organization already uses OpenTelemetry or another standard.

---

# 15. Queue Isolation and Worker Pools

Separate work by operational characteristics.

Bad design:

```text
One queue:
- latency-sensitive email
- massive report generation
- slow image conversion
- cleanup tasks
```

A CPU-heavy report can delay urgent email work.

Better:

```text
emails queue       → async I/O workers
analytics queue    → CPU workers
maintenance queue  → low-priority workers
integrations queue → rate-limited external API workers
```

## Isolation Checklist

- [ ] Separate latency-sensitive and batch workloads.
- [ ] Separate CPU-heavy and I/O-heavy workloads.
- [ ] Set queue-specific retry policies.
- [ ] Set queue-specific concurrency.
- [ ] Set queue-specific rate limits.
- [ ] Set queue-specific alert thresholds.
- [ ] Consider separate worker deployments for risky third-party integrations.

---

# 16. Rate Limiting and External Dependencies

Retries and concurrency can overwhelm external systems.

For example:

```text
100 workers × 20 concurrent tasks = 2,000 requests
```

If an API allows 100 requests per second, this can trigger rate limits or outages.

Use:

- semaphore limits;
- queue-specific concurrency;
- token bucket algorithms;
- vendor-provided rate-limit headers;
- backoff after HTTP `429`;
- circuit breakers.

A simple in-process concurrency limiter:

```python
from __future__ import annotations

import asyncio


partner_api_limit = asyncio.Semaphore(10)


async def call_partner_api() -> str:
    """Allow only ten simultaneous local calls."""
    async with partner_api_limit:
        await asyncio.sleep(0.1)
        return "partner response"
```

For multi-process or multi-machine limits, use a distributed coordination mechanism rather than an in-process semaphore.

---

# 17. Circuit Breakers

A circuit breaker prevents repeated requests to a dependency that is clearly unhealthy.

States:

```text
Closed    → requests allowed
Open      → requests rejected temporarily
Half-open → limited probe requests allowed
```

Conceptual behavior:

```text
Repeated failures
        ↓
Circuit opens
        ↓
New tasks fail fast or defer
        ↓
Cooldown expires
        ↓
One probe request checks recovery
```

Circuit breakers reduce retry storms and make failure behavior more predictable.

---

# 18. Deployment and Shutdown

A worker process must cooperate with its orchestrator.

For Kubernetes, Docker, systemd, or another supervisor:

```text
Supervisor sends SIGTERM
        ↓
Worker stops accepting new messages
        ↓
Worker drains or cancels active work
        ↓
Worker closes plugins and process pools
        ↓
Process exits
```

## Shutdown Checklist

- [ ] Handle `SIGTERM`.
- [ ] Handle `SIGINT`.
- [ ] Stop receiving new messages before shutdown.
- [ ] Set broker consumer prefetch appropriately.
- [ ] Wait for in-flight work until configured deadline.
- [ ] Cancel remaining work after deadline.
- [ ] Record cancellation state.
- [ ] Ensure orchestrator grace period exceeds worker shutdown timeout.
- [ ] Avoid force-killing process pools unless unavoidable.
- [ ] Test shutdown under queued, running, retrying, and CPU-bound workloads.

---

# 19. Health Checks

Use separate health concepts.

| Check | Meaning |
|---|---|
| Liveness | Is the process alive? |
| Readiness | Can this worker accept work? |
| Dependency health | Can required broker/result services be reached? |
| Business health | Are tasks completing within expected latency? |

PulseQueue’s local health snapshot provides process-local state:

```python
from pulsequeue.health import runtime_health

health = runtime_health(runtime)

print(health.as_dict())
```

A production worker should extend this with:

- broker connectivity;
- result backend connectivity;
- queue lag;
- process-pool health;
- plugin status.

---

# 20. Disaster Recovery and Backups

For durable systems, decide what survives:

| Data | Backup requirement |
|---|---|
| Pending messages | Usually critical |
| Retry schedules | Usually critical |
| Result state | Depends on product requirements |
| Audit events | Often compliance-dependent |
| Dead-letter messages | Usually important |
| Metrics | Usually external retention policy |

## Recovery Checklist

- [ ] Back up durable broker state where supported.
- [ ] Back up result backend if results are business records.
- [ ] Document restore procedures.
- [ ] Test restore procedures.
- [ ] Define replay rules for old tasks.
- [ ] Avoid replaying non-idempotent tasks without review.
- [ ] Document data-retention periods.

---

# 21. Load Testing

Do not infer production capacity from a laptop demo.

Test with realistic:

- payload sizes;
- worker counts;
- retry rates;
- slow dependencies;
- queue depth;
- shutdown scenarios;
- CPU saturation;
- memory duration.

Measure:

```text
Task throughput
Queue wait time
Task execution latency
p50 / p95 / p99 duration
Retry volume
Failure rate
Process RSS
CPU utilization
Broker latency
Result backend latency
```

## Load-Test Failure Scenarios

- [ ] Broker temporarily unavailable.
- [ ] Result backend temporarily unavailable.
- [ ] Worker crashes during task execution.
- [ ] Worker crashes after side effect but before acknowledgement.
- [ ] Task payload is malformed.
- [ ] Task schema version is unsupported.
- [ ] External dependency returns `429`.
- [ ] External dependency returns `503`.
- [ ] CPU task exceeds timeout.
- [ ] Shutdown occurs while tasks are retrying.
- [ ] Queue reaches capacity.
- [ ] Result retention reaches capacity.

---

# 22. Final Go-Live Checklist

## Broker and Message Safety

- [ ] Durable broker selected.
- [ ] Message acknowledgement strategy documented.
- [ ] Visibility timeout or lease strategy documented.
- [ ] JSON or another safe serialization format used.
- [ ] Schema versioning implemented.
- [ ] Payload size limits enforced.
- [ ] Dead-letter behavior implemented.

## Task Safety

- [ ] Tasks are idempotent or protected with idempotency keys.
- [ ] Retryable exception types are explicit.
- [ ] Permanent failures do not retry.
- [ ] Backoff includes jitter.
- [ ] Timeout values are realistic.
- [ ] CPU and I/O workloads use separate execution paths.

## Security

- [ ] Broker credentials stored in secrets manager.
- [ ] TLS enabled for networked dependencies.
- [ ] Least-privilege access applied.
- [ ] Logs exclude sensitive payload data.
- [ ] Worker container runs as non-root.
- [ ] Dependency versions are reviewed and patched.

## Operations

- [ ] Structured logging enabled.
- [ ] Metrics exported.
- [ ] Health and readiness checks implemented.
- [ ] Alerts configured for queue lag, failure rate, and DLQ volume.
- [ ] Graceful shutdown tested.
- [ ] Restore and replay procedures documented.
- [ ] Load tests completed.
[STARTING: Appendix I — Troubleshooting Guide]
