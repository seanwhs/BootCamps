# Appendix I: Production Readiness Checklist

A system is not production-ready merely because it works on a developer’s machine.

Production readiness means the application can:

- Start predictably.
- Validate its configuration.
- Handle expected failures.
- Protect its dependencies.
- Avoid leaking memory and secrets.
- Provide useful diagnostics.
- Shut down safely.
- Be tested and deployed repeatedly.
- Be operated by someone who did not write every line of code.

This appendix provides a practical checklist for the Runtime Monitor application.

---

# I.1: Production Readiness Categories

Use these categories when reviewing the application:

```text
1. Correctness
2. Configuration
3. Security
4. Reliability
5. Performance
6. Observability
7. Testing
8. Deployment
9. Operations
10. Recovery
11. Documentation
12. Maintenance
```

A production review should evaluate every category rather than focusing only on feature completion.

---

# I.2: Correctness Checklist

## Functional Behavior

- [ ] Successful requests return correct data.
- [ ] Invalid inputs are rejected clearly.
- [ ] Missing data is handled explicitly.
- [ ] Partial dependency failures do not corrupt unrelated state.
- [ ] Cancellation does not appear as an unexpected failure.
- [ ] Timeouts stop or abandon work correctly.
- [ ] Retries stop at the configured limit.
- [ ] Circuit breakers recover after dependencies become healthy.
- [ ] State updates preserve required invariants.
- [ ] Derived values are calculated from current state.
- [ ] Duplicate events do not produce duplicate side effects.
- [ ] Repeated refreshes do not create overlapping obsolete work.
- [ ] Shutdown leaves no active timers or subscriptions.

## Data Validation

- [ ] External responses are validated.
- [ ] Required fields are checked.
- [ ] Numeric values are checked for finite values.
- [ ] Enumerated values are checked against allowed values.
- [ ] Unexpected fields are handled safely.
- [ ] Malformed JSON is handled.
- [ ] Invalid dates are rejected or normalized.
- [ ] User input is validated before use.

Example:

```js
"use strict";

export function parseMetricsResponse(value) {
  if (
    value === null ||
    typeof value !== "object"
  ) {
    throw new TypeError(
      "metrics response must be an object"
    );
  }

  if (
    !Number.isFinite(value.requestsPerSecond) ||
    value.requestsPerSecond < 0
  ) {
    throw new TypeError(
      "requestsPerSecond must be a non-negative number"
    );
  }

  if (
    !Number.isFinite(value.errorRate) ||
    value.errorRate < 0 ||
    value.errorRate > 1
  ) {
    throw new TypeError(
      "errorRate must be between 0 and 1"
    );
  }

  return Object.freeze({
    requestsPerSecond: value.requestsPerSecond,
    errorRate: value.errorRate
  });
}
```

---

# I.3: Configuration Checklist

Configuration should be loaded once, validated once, and passed explicitly.

## Configuration Rules

- [ ] Required values fail startup when missing.
- [ ] Numeric values are parsed and validated.
- [ ] Durations use one consistent unit.
- [ ] Defaults are documented.
- [ ] Production values are not hard-coded.
- [ ] Secrets are supplied through a secure secret mechanism.
- [ ] Configuration is not logged in full.
- [ ] Invalid configuration causes a clear startup error.
- [ ] Configuration values have safe upper bounds.
- [ ] Configuration changes have an operational procedure.

## Recommended Environment Variables

```text
APP_ENV=production
PORT=3000
API_BASE_URL=https://api.example.com

REQUEST_TIMEOUT_MS=5000
RETRY_MAX_ATTEMPTS=3
RETRY_BASE_DELAY_MS=100
RETRY_MAX_DELAY_MS=5000

CIRCUIT_FAILURE_THRESHOLD=5
CIRCUIT_RESET_TIMEOUT_MS=30000

BULKHEAD_MAX_CONCURRENCY=20
BULKHEAD_MAX_QUEUE=100

LOG_LEVEL=info
SHUTDOWN_TIMEOUT_MS=10000
```

## Configuration Loader

### `src/app/configuration.js`

```js
"use strict";

function requiredString(
  environment,
  name
) {
  const value = environment[name];

  if (
    typeof value !== "string" ||
    value.trim() === ""
  ) {
    throw new Error(
      `${name} must be a non-empty string`
    );
  }

  return value.trim();
}

function optionalString(
  environment,
  name,
  fallback
) {
  const value = environment[name];

  if (value === undefined) {
    return fallback;
  }

  if (
    typeof value !== "string" ||
    value.trim() === ""
  ) {
    throw new Error(
      `${name} must be a non-empty string`
    );
  }

  return value.trim();
}

function positiveInteger(
  environment,
  name,
  fallback
) {
  const rawValue = environment[name] ?? fallback;
  const value = Number(rawValue);

  if (
    !Number.isInteger(value) ||
    value <= 0
  ) {
    throw new Error(
      `${name} must be a positive integer`
    );
  }

  return value;
}

function boundedInteger(
  environment,
  name,
  fallback,
  minimum,
  maximum
) {
  const value = positiveInteger(
    environment,
    name,
    fallback
  );

  if (value < minimum || value > maximum) {
    throw new Error(
      `${name} must be between ${minimum} and ${maximum}`
    );
  }

  return value;
}

export function loadConfiguration(
  environment = process.env
) {
  const appEnvironment = optionalString(
    environment,
    "APP_ENV",
    "development"
  );

  const configuration = {
    appEnvironment,

    port: boundedInteger(
      environment,
      "PORT",
      3000,
      1,
      65_535
    ),

    apiBaseUrl: requiredString(
      environment,
      "API_BASE_URL"
    ),

    requestTimeoutMilliseconds:
      boundedInteger(
        environment,
        "REQUEST_TIMEOUT_MS",
        5_000,
        100,
        120_000
      ),

    retryMaximumAttempts:
      boundedInteger(
        environment,
        "RETRY_MAX_ATTEMPTS",
        3,
        1,
        10
      ),

    retryBaseDelayMilliseconds:
      boundedInteger(
        environment,
        "RETRY_BASE_DELAY_MS",
        100,
        0,
        60_000
      ),

    retryMaximumDelayMilliseconds:
      boundedInteger(
        environment,
        "RETRY_MAX_DELAY_MS",
        5_000,
        0,
        300_000
      ),

    circuitFailureThreshold:
      boundedInteger(
        environment,
        "CIRCUIT_FAILURE_THRESHOLD",
        5,
        1,
        100
      ),

    circuitResetTimeoutMilliseconds:
      boundedInteger(
        environment,
        "CIRCUIT_RESET_TIMEOUT_MS",
        30_000,
        100,
        3_600_000
      ),

    shutdownTimeoutMilliseconds:
      boundedInteger(
        environment,
        "SHUTDOWN_TIMEOUT_MS",
        10_000,
        100,
        120_000
      ),

    logLevel: optionalString(
      environment,
      "LOG_LEVEL",
      "info"
    )
  };

  if (
    configuration.retryBaseDelayMilliseconds >
    configuration.retryMaximumDelayMilliseconds
  ) {
    throw new Error(
      "retry base delay cannot exceed retry maximum delay"
    );
  }

  return Object.freeze(configuration);
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { loadConfiguration } from "./src/app/configuration.js";

const configuration = loadConfiguration({
  APP_ENV: "production",
  PORT: "3000",
  API_BASE_URL: "https://api.example.test",
  REQUEST_TIMEOUT_MS: "5000",
  RETRY_MAX_ATTEMPTS: "3",
  RETRY_BASE_DELAY_MS: "100",
  RETRY_MAX_DELAY_MS: "5000",
  CIRCUIT_FAILURE_THRESHOLD: "5",
  CIRCUIT_RESET_TIMEOUT_MS: "30000",
  SHUTDOWN_TIMEOUT_MS: "10000",
  LOG_LEVEL: "info"
});

console.log(configuration);
EOF
```

Expected output is a frozen configuration object with parsed numeric values.

---

# I.4: Security Checklist

## Secrets

- [ ] Secrets are not committed to source control.
- [ ] Secrets are not embedded in browser bundles.
- [ ] Secrets are not printed in logs.
- [ ] Secrets are not included in error responses.
- [ ] Secrets have rotation procedures.
- [ ] Development and production secrets are separate.
- [ ] Access to secret storage is limited.

## Input Security

- [ ] User input is validated.
- [ ] URLs are checked before requests.
- [ ] File paths are protected against traversal.
- [ ] HTML output is escaped or created with safe DOM APIs.
- [ ] SQL queries use parameterized values.
- [ ] Shell commands do not interpolate untrusted input.
- [ ] Request body sizes are limited.
- [ ] JSON depth and structure are bounded where necessary.

## Authentication and Authorization

- [ ] Authentication failures are distinguished from dependency failures.
- [ ] Authorization is checked server-side.
- [ ] Users cannot access another user’s data through modified identifiers.
- [ ] Tokens have expiration and rotation behavior.
- [ ] Session invalidation works.
- [ ] Administrative operations require stronger authorization.

## Browser Security

- [ ] Content Security Policy is configured.
- [ ] Sensitive cookies use `HttpOnly`.
- [ ] Sensitive cookies use `Secure`.
- [ ] Cookie `SameSite` policy is intentional.
- [ ] Cross-origin policy is restricted.
- [ ] Third-party scripts are reviewed.
- [ ] Dangerous HTML injection APIs are avoided.

## Transport Security

- [ ] Production traffic uses HTTPS.
- [ ] Certificate validation is enabled.
- [ ] Internal services use authenticated connections where required.
- [ ] Redirect behavior is understood.
- [ ] Sensitive values are not sent in URLs.

---

# I.5: Secure Logging

## The Problem

Errors and request objects can contain secrets:

```js
logger.error("request failed", {
  headers,
  requestBody,
  error
});
```

This can accidentally expose:

- Authorization headers.
- Cookies.
- Passwords.
- Access tokens.
- Personal information.

## Redaction Utility

### `src/app/redact.js`

```js
"use strict";

const sensitiveKeys = new Set([
  "authorization",
  "cookie",
  "password",
  "secret",
  "token",
  "accessToken",
  "refreshToken",
  "apiKey"
]);

export function redact(
  value,
  seen = new WeakSet()
) {
  if (
    value === null ||
    typeof value !== "object"
  ) {
    return value;
  }

  if (seen.has(value)) {
    return "[Circular]";
  }

  seen.add(value);

  if (Array.isArray(value)) {
    return value.map((item) =>
      redact(item, seen)
    );
  }

  const output = {};

  for (const [key, item] of Object.entries(value)) {
    if (sensitiveKeys.has(key)) {
      output[key] = "[REDACTED]";
    } else {
      output[key] = redact(item, seen);
    }
  }

  return output;
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { redact } from "./src/app/redact.js";

console.dir(
  redact({
    user: "Ada",
    authorization: "Bearer secret",
    nested: {
      password: "secret"
    }
  }),
  { depth: null }
);
EOF
```

Expected output:

```text
{
  user: 'Ada',
  authorization: '[REDACTED]',
  nested: { password: '[REDACTED]' }
}
```

---

# I.6: Dependency Management Checklist

- [ ] Dependencies are pinned or controlled through a lockfile.
- [ ] `npm audit` or an equivalent scanner runs regularly.
- [ ] Unused dependencies are removed.
- [ ] Transitive dependencies are reviewed.
- [ ] Package update procedures exist.
- [ ] Critical packages have an owner.
- [ ] Production installation excludes development-only dependencies where appropriate.
- [ ] Dependency licenses are reviewed.
- [ ] Build artifacts are reproducible.

Useful commands:

```bash
npm ci
npm audit
npm outdated
npm ls
```

Use `npm ci` in automated builds when installing from a lockfile.

---

# I.7: Build and Deployment Checklist

## Build

- [ ] The build runs from a clean checkout.
- [ ] The lockfile is used.
- [ ] Tests run before packaging.
- [ ] Static analysis runs.
- [ ] Configuration is not accidentally bundled.
- [ ] Source maps are handled safely.
- [ ] Artifacts are versioned.
- [ ] The build records the source commit.

## Deployment

- [ ] Deployment is automated.
- [ ] A failed deployment stops safely.
- [ ] Rollback is documented and tested.
- [ ] Health checks are available.
- [ ] Readiness and liveness are distinct.
- [ ] Database migrations are backward-compatible.
- [ ] Old and new application versions can coexist during rollout.
- [ ] Deployment timeouts are configured.
- [ ] Production environment variables are validated at startup.

---

# I.8: Health, Readiness, and Liveness

These endpoints have different purposes.

## Liveness

Answers:

> Is the process alive?

A liveness check should be lightweight. It should not necessarily call every dependency.

```text
GET /live
200 {"status":"alive"}
```

## Readiness

Answers:

> Can this instance receive traffic?

Readiness may consider:

- Startup complete.
- Required configuration loaded.
- Critical dependencies reachable.
- Shutdown not in progress.

```text
GET /ready
503 {"status":"not-ready"}
```

## Dependency Health

Answers:

> Which external services are healthy?

This can be more detailed and should not necessarily determine whether the process itself is alive.

---

# I.9: Health Endpoint Implementation

## Implementation

### `src/app/health.js`

```js
"use strict";

export function createHealthService({
  isShuttingDown,
  getDependencyStatuses
}) {
  if (typeof isShuttingDown !== "function") {
    throw new TypeError(
      "isShuttingDown must be a function"
    );
  }

  if (typeof getDependencyStatuses !== "function") {
    throw new TypeError(
      "getDependencyStatuses must be a function"
    );
  }

  return Object.freeze({
    live() {
      return {
        status: "alive"
      };
    },

    ready() {
      if (isShuttingDown()) {
        return {
          status: "not-ready",
          reason: "shutting-down"
        };
      }

      return {
        status: "ready"
      };
    },

    dependencies() {
      return {
        status: "dependencies",
        services: getDependencyStatuses()
      };
    }
  });
}
```

## Verification

```bash
node --input-type=module <<'EOF'
import { createHealthService } from "./src/app/health.js";

const health = createHealthService({
  isShuttingDown: () => false,
  getDependencyStatuses: () => ({
    metrics: "healthy",
    activity: "degraded"
  })
});

console.log(health.live());
console.log(health.ready());
console.log(health.dependencies());
EOF
```

---

# I.10: Observability Checklist

Observability helps explain what happened inside a running system.

## Logs

- [ ] Logs have timestamps.
- [ ] Logs have levels.
- [ ] Logs include request or correlation identifiers.
- [ ] Logs include service names.
- [ ] Logs include error categories.
- [ ] Logs are structured.
- [ ] Sensitive values are redacted.
- [ ] Log volume is bounded.
- [ ] Debug logging can be disabled.

## Metrics

- [ ] Request count is measured.
- [ ] Success and failure counts are measured.
- [ ] Latency percentiles are measured.
- [ ] Retry count is measured.
- [ ] Timeout count is measured.
- [ ] Cancellation count is measured.
- [ ] Circuit state changes are measured.
- [ ] Queue depth is measured.
- [ ] Memory and CPU are monitored.
- [ ] Event-loop delay is monitored where relevant.

## Traces

- [ ] A request can be followed across services.
- [ ] External dependency spans are recorded.
- [ ] Retries are visible.
- [ ] Timeouts are visible.
- [ ] Sensitive data is not included in trace attributes.

---

# I.11: Correlation Identifiers

A correlation identifier connects logs from one logical workflow.

```js
const context = {
  requestId: "request-123",
  operation: "dashboard-refresh",
  service: "metrics"
};
```

Every layer should preserve the identifier:

```text
incoming request
      │
      ▼
application workflow
      │
      ▼
retry attempt
      │
      ▼
external dependency
```

## Contextual Logger

### `src/app/contextual-logger.js`

```js
"use strict";

export function createContextualLogger(
  logger,
  context
) {
  if (!logger || typeof logger.info !== "function") {
    throw new TypeError(
      "logger must provide an info function"
    );
  }

  const safeContext = Object.freeze({
    ...context
  });

  return Object.freeze({
    info(message, details = {}) {
      logger.info(message, {
        ...safeContext,
        ...details
      });
    },

    warn(message, details = {}) {
      logger.warn(message, {
        ...safeContext,
        ...details
      });
    },

    error(message, details = {}) {
      logger.error(message, {
        ...safeContext,
        ...details
      });
    }
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createContextualLogger } from "./src/app/contextual-logger.js";

const logger = createContextualLogger(
  console,
  {
    requestId: "request-123",
    operation: "refresh"
  }
);

logger.info("request started", {
  service: "metrics"
});
EOF
```

---

# I.12: Alerting Checklist

Alerts should represent actionable conditions.

## Good Alerts

- Error rate exceeds the agreed threshold.
- p95 latency exceeds the service objective.
- Circuit remains open beyond an expected period.
- Memory usage grows continuously.
- Event-loop delay exceeds a safe threshold.
- Readiness failures affect multiple instances.
- Retry exhaustion increases suddenly.
- Queue depth approaches capacity.

## Poor Alerts

- Every single failed request.
- Every expected cancellation.
- A one-second metric spike with no user impact.
- Debug log volume.
- A dependency failure that already has a graceful fallback and no user impact.

Every alert should define:

- Owner.
- Severity.
- Threshold.
- Runbook.
- Escalation path.
- Expected response time.

---

# I.13: Service-Level Objectives

A service-level objective, or SLO, defines a target.

Examples:

```text
Availability:
99.9% of valid requests succeed monthly.

Latency:
95% of dashboard refreshes complete within 500 ms.

Freshness:
99% of healthy dashboards display data less than 60 seconds old.

Recovery:
A dependency outage does not cause more than 20% of dashboard panels to fail.
```

SLOs make resilience and performance discussions concrete.

---

# I.14: Error Budgets

An error budget is the amount of failure allowed by an availability or reliability objective.

For a 99.9% monthly availability objective, the approximate budget is:

```text
0.1% of the month
```

If the service spends its error budget rapidly:

- Slow risky deployments.
- Prioritize reliability work.
- Investigate dependency failures.
- Review capacity and resilience settings.

Error budgets connect product delivery and operational stability.

---

# I.15: API Contract Checklist

- [ ] Request and response formats are documented.
- [ ] Required fields are explicit.
- [ ] Optional fields have defined behavior.
- [ ] Error responses have stable codes.
- [ ] Rate limits are documented.
- [ ] Timeout behavior is documented.
- [ ] Retry expectations are documented.
- [ ] Idempotency behavior is documented.
- [ ] Pagination behavior is documented.
- [ ] Versioning behavior is documented.
- [ ] Backward compatibility is considered.
- [ ] Unknown fields are handled safely.

Example error response:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "limit must be a positive integer",
    "requestId": "request-123"
  }
}
```

Do not return stack traces or internal dependency details to ordinary clients.

---

# I.16: Data Contract Validation

## Implementation

### `src/app/contracts.js`

```js
"use strict";

export function assertMetricsContract(value) {
  if (
    value === null ||
    typeof value !== "object"
  ) {
    throw new Error(
      "metrics response must be an object"
    );
  }

  const requiredFields = [
    "requestsPerSecond",
    "errorRate"
  ];

  for (const field of requiredFields) {
    if (!(field in value)) {
      throw new Error(
        `metrics response missing ${field}`
      );
    }
  }

  if (
    !Number.isFinite(value.requestsPerSecond) ||
    value.requestsPerSecond < 0
  ) {
    throw new Error(
      "requestsPerSecond is invalid"
    );
  }

  if (
    !Number.isFinite(value.errorRate) ||
    value.errorRate < 0 ||
    value.errorRate > 1
  ) {
    throw new Error(
      "errorRate is invalid"
    );
  }

  return Object.freeze({
    requestsPerSecond: value.requestsPerSecond,
    errorRate: value.errorRate
  });
}
```

## Verification

```bash
node --input-type=module <<'EOF'
import { assertMetricsContract } from "./src/app/contracts.js";

console.log(
  assertMetricsContract({
    requestsPerSecond: 125,
    errorRate: 0.01
  })
);
EOF
```

---

# I.17: Database and Persistence Checklist

If the application uses a database:

- [ ] Connections have timeouts.
- [ ] Connection pools have maximum sizes.
- [ ] Queries are parameterized.
- [ ] Transactions have clear boundaries.
- [ ] Transactions have timeouts.
- [ ] Retries do not duplicate non-idempotent writes.
- [ ] Migrations are versioned.
- [ ] Backups are configured.
- [ ] Restore procedures are tested.
- [ ] Data retention is documented.
- [ ] Sensitive data is encrypted appropriately.
- [ ] Connection failures are observable.
- [ ] Shutdown closes the pool.

A backup that has never been restored is an assumption, not a recovery plan.

---

# I.18: Deployment Strategies

## Rolling Deployment

Instances are replaced gradually.

Advantages:

- Lower immediate risk.
- No full outage.
- Easy to automate.

Considerations:

- Old and new versions coexist.
- API and database changes must be compatible.

## Blue-Green Deployment

Two environments exist:

```text
blue  → current production
green → new release
```

Traffic switches after verification.

Advantages:

- Fast rollback.
- Clear separation.

Considerations:

- Requires additional capacity.
- Data migrations need special care.

## Canary Deployment

A small percentage of traffic reaches the new version first.

Advantages:

- Real traffic validation.
- Lower blast radius.

Monitor:

- Error rate.
- Latency.
- Memory.
- Dependency calls.
- User behavior.

---

# I.19: Container and Process Checklist

- [ ] The process runs as a non-root user where possible.
- [ ] The image is minimal.
- [ ] Dependencies are installed reproducibly.
- [ ] Health checks are configured.
- [ ] Shutdown signals are forwarded.
- [ ] The process handles `SIGTERM`.
- [ ] CPU and memory limits are understood.
- [ ] Logs go to the expected output.
- [ ] Temporary files have cleanup policies.
- [ ] The image contains no secrets.
- [ ] The runtime version is pinned.
- [ ] Vulnerability scanning runs.

---

# I.20: Example Container Health Endpoint

### `src/server.js`

```js
"use strict";

import http from "node:http";

let shuttingDown = false;

const server = http.createServer(
  (request, response) => {
    if (request.url === "/live") {
      response.writeHead(200, {
        "content-type": "application/json"
      });

      response.end(
        JSON.stringify({
          status: "alive"
        })
      );

      return;
    }

    if (request.url === "/ready") {
      const statusCode = shuttingDown
        ? 503
        : 200;

      response.writeHead(statusCode, {
        "content-type": "application/json"
      });

      response.end(
        JSON.stringify({
          status: shuttingDown
            ? "not-ready"
            : "ready"
        })
      );

      return;
    }

    response.writeHead(404);
    response.end();
  }
);

server.listen(3000);

function shutdown() {
  if (shuttingDown) {
    return;
  }

  shuttingDown = true;

  server.close(() => {
    process.exit(0);
  });
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
```

## Verification

Run:

```bash
node src/server.js
```

In another terminal:

```bash
curl -i http://localhost:3000/live
curl -i http://localhost:3000/ready
```

Stop the process and verify that it closes the server.

---

# I.21: Incident Response Checklist

When an incident occurs:

## Stabilize

- [ ] Confirm the incident.
- [ ] Identify affected users or services.
- [ ] Reduce the blast radius.
- [ ] Disable a problematic feature if necessary.
- [ ] Roll back if the release is implicated.
- [ ] Protect dependencies from overload.

## Investigate

- [ ] Establish the incident timeline.
- [ ] Check error rate and latency.
- [ ] Check recent deployments.
- [ ] Check dependency health.
- [ ] Inspect logs by request identifier.
- [ ] Check memory and CPU.
- [ ] Check circuit-breaker state.
- [ ] Check queue depth and saturation.

## Communicate

- [ ] Assign an incident owner.
- [ ] Record decisions.
- [ ] Provide status updates.
- [ ] Avoid speculation presented as fact.
- [ ] Document user impact.

## Recover

- [ ] Confirm the triggering condition is resolved.
- [ ] Monitor recovery.
- [ ] Verify data consistency.
- [ ] Confirm error rates return to normal.
- [ ] Remove temporary mitigations carefully.

## Learn

- [ ] Write a timeline.
- [ ] Identify contributing factors.
- [ ] Define corrective actions.
- [ ] Assign owners and deadlines.
- [ ] Add regression tests or alerts.
- [ ] Update runbooks.

---

# I.22: Runbook Template

Create a runbook for each important failure mode.

```markdown
# Metrics API Outage

## Symptoms

- Metrics panel shows unavailable.
- `metrics_dependency_errors` increases.
- Circuit breaker is OPEN.

## Immediate Actions

1. Check the metrics API status.
2. Confirm the application is returning partial dashboard data.
3. Verify retry volume is not increasing rapidly.
4. Check whether the circuit breaker is protecting the dependency.

## User Impact

Metrics may be stale or unavailable.
Health and activity panels should remain available.

## Mitigation

- Preserve the last known metrics snapshot.
- Keep the metrics circuit open while the dependency is unhealthy.
- Avoid manually increasing retry attempts.

## Recovery

1. Confirm the metrics API is healthy.
2. Wait for the half-open probe.
3. Verify successful metrics requests.
4. Confirm the circuit returns to CLOSED.

## Escalation

Contact the metrics platform owner if the outage exceeds 15 minutes.
```

---

# I.23: Backup and Recovery Checklist

- [ ] Backup frequency is documented.
- [ ] Backup retention is documented.
- [ ] Backups are encrypted.
- [ ] Backups are stored separately from the primary system.
- [ ] Restore procedures are documented.
- [ ] Restore tests are performed regularly.
- [ ] Recovery time objective is defined.
- [ ] Recovery point objective is defined.
- [ ] Application startup after restore is tested.
- [ ] Data integrity checks exist.

## Definitions

**Recovery Time Objective, or RTO:**  
How quickly the service should recover.

**Recovery Point Objective, or RPO:**  
How much recent data loss is acceptable.

---

# I.24: Load and Capacity Testing

Before production, test realistic load:

- [ ] Normal expected traffic.
- [ ] Peak traffic.
- [ ] Dependency latency.
- [ ] Dependency failure.
- [ ] Retry behavior.
- [ ] Queue saturation.
- [ ] Memory growth.
- [ ] Long-running operation behavior.
- [ ] Deployment during traffic.
- [ ] Shutdown during traffic.

Record:

```text
requests per second
p50 latency
p95 latency
p99 latency
error rate
CPU
heap usage
event-loop delay
active connections
queue depth
retry count
```

Do not test only a successful dependency. A resilience design must be measured under failure conditions.

---

# I.25: Performance Readiness Checklist

- [ ] Main workflows have latency budgets.
- [ ] Tail latency is measured.
- [ ] Expensive synchronous work is identified.
- [ ] Event-loop delay is monitored where appropriate.
- [ ] Browser long tasks are investigated.
- [ ] Rendering updates are batched.
- [ ] Frequent input is debounced or throttled.
- [ ] Obsolete requests are cancelled.
- [ ] Caches have size and expiration policies.
- [ ] Memory is stable after repeated workflows.
- [ ] CPU-heavy work uses workers where appropriate.
- [ ] Performance regression tests exist.

---

# I.26: Testing Readiness Checklist

- [ ] Unit tests cover pure logic.
- [ ] Integration tests cover module boundaries.
- [ ] Failure paths are tested.
- [ ] Cancellation is tested.
- [ ] Timeout behavior is tested.
- [ ] Retry limits are tested.
- [ ] Circuit transitions are tested.
- [ ] Cleanup is tested.
- [ ] Configuration validation is tested.
- [ ] External dependencies are replaced with fakes.
- [ ] Tests do not require real production services.
- [ ] Tests are deterministic.
- [ ] Tests run from a clean checkout.
- [ ] Coverage is reviewed meaningfully.
- [ ] Security tests are included where relevant.

---

# I.27: Release Checklist

Before release:

- [ ] Version number is updated.
- [ ] Changelog is updated.
- [ ] Tests pass.
- [ ] Static analysis passes.
- [ ] Dependency scan passes.
- [ ] Build succeeds from a clean checkout.
- [ ] Configuration is validated.
- [ ] Database migration is reviewed.
- [ ] Rollback plan exists.
- [ ] Health checks are verified.
- [ ] Monitoring dashboards are ready.
- [ ] Alerts are tested.
- [ ] Runbooks are available.
- [ ] On-call ownership is clear.
- [ ] Release notes identify behavior changes.

---

# I.28: Startup Validation

The application should fail clearly when required configuration is invalid.

## Implementation

### `src/app/bootstrap.js`

```js
"use strict";

import { loadConfiguration } from "./configuration.js";

export function bootstrap({
  environment = process.env,
  logger = console
} = {}) {
  try {
    const configuration =
      loadConfiguration(environment);

    logger.info("configuration loaded", {
      environment:
        configuration.appEnvironment,
      port: configuration.port
    });

    return configuration;
  } catch (error) {
    logger.error(
      "application startup failed",
      {
        name: error.name,
        message: error.message
      }
    );

    throw error;
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  bootstrap();
}
```

## Verification

Run with an invalid configuration:

```bash
API_BASE_URL="" node src/app/bootstrap.js
```

The process should fail with a clear configuration message.

Run with a valid configuration:

```bash
API_BASE_URL="https://api.example.test" node src/app/bootstrap.js
```

The process should report that configuration loaded.

---

# I.29: Production Readiness Scorecard

Use a simple scorecard during review:

| Category | Pass? | Evidence |
|---|---:|---|
| Correctness | [ ] | Tests and verification |
| Configuration | [ ] | Startup validation |
| Security | [ ] | Review and scans |
| Reliability | [ ] | Failure tests |
| Performance | [ ] | Measurements |
| Observability | [ ] | Logs, metrics, alerts |
| Testing | [ ] | Automated suite |
| Deployment | [ ] | Repeatable pipeline |
| Operations | [ ] | Runbooks and ownership |
| Recovery | [ ] | Backup and restore tests |
| Documentation | [ ] | Architecture and procedures |
| Maintenance | [ ] | Dependency and upgrade plan |

Do not mark a category complete because a document exists. Require evidence.

---

# I.30: Definition of Done

A feature should not be considered complete until:

```text
implementation
    │
    ▼
validation
    │
    ▼
success tests
    │
    ▼
failure tests
    │
    ▼
cancellation and timeout behavior
    │
    ▼
cleanup behavior
    │
    ▼
observability
    │
    ▼
configuration
    │
    ▼
documentation
    │
    ▼
deployment verification
```

For an external service integration, the minimum definition of done should include:

- [ ] Request timeout.
- [ ] Response validation.
- [ ] Error classification.
- [ ] Retry policy.
- [ ] Cancellation support.
- [ ] Circuit-breaker policy if appropriate.
- [ ] Logging and metrics.
- [ ] Fallback behavior.
- [ ] Unit tests.
- [ ] Integration tests.
- [ ] Runbook.

---

# I.31: Final Production Review

Before launch, ask the team:

## Correctness

- What happens when the dependency succeeds?
- What happens when it returns invalid data?
- What happens when it never responds?
- What happens when the user cancels?

## Capacity

- What happens when traffic doubles?
- What happens when the dependency slows down?
- Can one feature consume all resources?
- Are queues bounded?

## Reliability

- What happens after repeated failures?
- Does the circuit breaker recover?
- Are retries safe?
- Is stale data clearly labeled?

## Operations

- How do we know something is wrong?
- Which dashboard shows the problem?
- Which alert fires?
- Who receives the alert?
- What does the runbook say?

## Recovery

- How do we roll back?
- How do we restore data?
- How do we restart safely?
- What happens during a deployment?

## Security

- Where are secrets stored?
- Could logs expose sensitive information?
- Is untrusted input validated?
- Are browser and server boundaries correct?

---

# I.32: Final Production Architecture

A production-ready Runtime Monitor should look conceptually like this:

```text
                    ┌───────────────────────────┐
                    │        User Interface       │
                    │ rendering, input, fallback  │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │        Application State    │
                    │ immutable transitions,      │
                    │ selectors, subscriptions    │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │      Workflow Boundary      │
                    │ cancellation, deadlines,   │
                    │ partial results, errors     │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │      Resilience Layer       │
                    │ bulkhead, circuit breaker,  │
                    │ retry, backoff, timeout     │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │       Dependency Client     │
                    │ validation, authentication, │
                    │ request and response logic  │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │     External Dependencies   │
                    └───────────────────────────┘

Cross-cutting:
- configuration validation
- structured logging
- metrics and tracing
- security controls
- testing
- graceful shutdown
- deployment and rollback
- runbooks and alerts
```

---

# I.33: Final Go-Live Checklist

## Before Deployment

- [ ] All automated tests pass.
- [ ] The application builds from a clean checkout.
- [ ] Configuration has been validated.
- [ ] Secrets are available through approved storage.
- [ ] Dependencies have been scanned.
- [ ] Health endpoints respond correctly.
- [ ] Logs contain no secrets.
- [ ] Metrics and alerts are configured.
- [ ] Rollback steps are documented.
- [ ] On-call ownership is assigned.

## During Deployment

- [ ] Monitor error rate.
- [ ] Monitor latency percentiles.
- [ ] Monitor memory and CPU.
- [ ] Monitor dependency failures.
- [ ] Monitor retry counts.
- [ ] Monitor circuit state.
- [ ] Verify readiness.
- [ ] Confirm traffic reaches new instances.
- [ ] Stop or roll back if thresholds are exceeded.

## After Deployment

- [ ] Verify primary user workflows.
- [ ] Verify health and readiness.
- [ ] Confirm logs are arriving.
- [ ] Confirm metrics are updating.
- [ ] Confirm no unexpected alerts fired.
- [ ] Check resource usage over time.
- [ ] Confirm shutdown behavior.
- [ ] Record the deployment result.

---

# I.34: Final Production Mental Model

Production readiness is a chain:

```text
correct code
    │
    ▼
validated configuration
    │
    ▼
secure inputs and secrets
    │
    ▼
bounded resource usage
    │
    ▼
controlled failure behavior
    │
    ▼
observable runtime behavior
    │
    ▼
repeatable deployment
    │
    ▼
documented recovery
```

The application is ready when the team can answer not only:

> Does the feature work?

but also:

- What happens when the network fails?
- What happens when the dependency is slow?
- What happens when the process runs out of capacity?
- What happens when a deployment is bad?
- What happens when data is malformed?
- What happens when the user leaves?
- What happens when the process shuts down?
- How do we detect the problem?
- How do we recover?
- Who owns the response?

That is the difference between code that works in development and software that can be responsibly operated in production.
