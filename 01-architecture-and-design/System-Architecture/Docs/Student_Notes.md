# Student Notes
## Architecting Modern Systems: From Monolith to Evolvable Systems

---

## Meta-Principle: The Cost of Change

```
Cost of Change = Blast Radius × Coupling Severity
```

Every architectural decision in this series is evaluated against one question:
> *"When the business changes its mind next quarter, how much of this system do we have to rewrite, and have we deferred that cost until we have maximum information?"*

---

## Part 1: System Architecture vs. System Design

### The Three Zoom Levels

| Level | Question | Time Horizon | Reversibility |
|-------|----------|--------------|---------------|
| **Code** | Does this function produce the correct output? | Hours | Trivial |
| **Design** | How should this module structure its interfaces? | Days | Low cost (refactor in a PR) |
| **Architecture** | What does it cost us to change this in 6 months? | Months/Years | High cost (one-way doors) |

### Architecture vs. Design

| Aspect | Architecture | Design |
|--------|--------------|--------|
| Focus | High-level structure, boundaries, non-functional trade-offs | Component internals, algorithms, data models |
| Core Lens | Cost of Change & Quality Attributes | Correctness & Functional Requirements |
| Key Question | "What are the main pieces and how do they communicate?" | "How do we build this specific piece?" |
| Reversibility | Irreversible / High Cost | Reversible / Low Cost |

### The Three Questions Before Writing Code

1. **What varies, and what is stable?**
   - Stable: Business rules (e.g., "order cannot ship without payment")
   - Volatile: UI frameworks, database drivers, third-party SaaS vendors

2. **What depends on what?**
   - Dependencies must point from volatile details → stable abstractions. Never reverse.

3. **What is the blast radius of a mistake here?**
   - Leaf utility bug = 1 hour. Leaked DB dependency in domain = months of rewrite.

### Clean Architecture (Concentric Rings)

```
┌─────────────────────────────────────────────┐
│  Frameworks & Drivers (Next.js, Postgres)   │  ← Outermost, Most Volatile
│  ┌────────────────────────────────────────┐   │
│  │  Interface Adapters (Controllers, DTOs)│   │
│  │  ┌──────────────────────────────────┐  │   │
│  │  │  Application (Use Cases, Ports)   │  │   │
│  │  │  ┌────────────────────────────┐  │  │   │
│  │  │  │  Domain (Entities, Rules)  │  │  │   │  ← Innermost, Most Stable
│  │  │  └────────────────────────────┘  │  │   │
│  │  └──────────────────────────────────┘  │   │
│  └────────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

**Dependency Rule:** Source code dependencies point inward only. Domain knows nothing about Next.js, Postgres, or HTTP.

### Locality of Behavior (LoB)

> Code that changes together should live together. The behavior of a unit should be evident from looking at it, not traced through excessive indirection.

**Synthesis:** Layer by dependency direction, partition by feature context.

```
src/
  core/                    ← Zero framework imports
    ordering/              ← Bounded Context
      domain/              ← Pure entities, value objects, rules
      application/         ← Use cases, ports
    inventory/
    shared-kernel/         ← Minimal shared primitives
  infrastructure/          ← Concrete adapter implementations
    persistence/
    payments/
    events/
    container.ts           ← Composition root
  interface-adapters/        ← DTOs, gateway middleware
  app/                       ← Next.js (only layer that knows the framework)
```

### The C4 Model

| Level | Name | Purpose |
|-------|------|---------|
| L1 | System Context | People + systems + relationships |
| L2 | Container | Apps / data stores inside the system |
| L3 | Component | Major structural building blocks |
| L4 | Code | Classes / interfaces (usually auto-generated) |

Use **Mermaid** for Diagrams-as-Code. Store in `docs/c4-diagrams/`.

### Northwind Orders: Day 1 Decision

**Start as a Modular Monolith.**
- Pre-cut modular seams allow extraction later without modifying core domain rules.
- Microservices on Day 1 impose a scalability tax (network partitions, distributed tracing, sagas) before proving need.

---

## Part 2: Designing the Core (DDD Basics)

### Core Insight

> Business logic that is explicit and named costs little to change. Business logic that is implicit and scattered costs enormously because you must rediscover it before modifying it.

### Bounded Context

A boundary within which a specific model and terminology are consistent. The same word can mean different things in different contexts.

| Context | "Product" Means |
|---------|-----------------|
| Catalog | Description, price, images, category |
| Inventory | SKU, quantityOnHand, reorderThreshold |
| Ordering | SKU, quantityOrdered, priceAtTimeOfOrder |

**Why separate?** Different rates of change. Catalog changes for marketing. Inventory changes every transaction. Ordering price must be frozen at purchase time.

### Context Map Relationships

- **Customer/Supplier:** One context consumes another's output (Ordering → Catalog)
- **Published Language:** Events with well-defined shapes cross boundaries (Payments → Ordering)

### Entity vs. Value Object

| | Entity | Value Object |
|--|--------|--------------|
| Identity | Has persistent ID | No identity |
| Equality | By ID | By attribute values |
| Mutability | Mutable state transitions | Immutable; operations return new instances |
| Example | `Order` (id = "ord_123") | `Money` (\$5 === \$5) |

### Money (Canonical Value Object)

```typescript
export class Money {
  private constructor(private readonly cents: number, private readonly currency: string) {}

  static fromDollars(dollars: number, currency = "USD"): Money {
    if (dollars < 0) throw new Error("Money cannot be negative");
    return new Money(Math.round(dollars * 100), currency);
  }

  add(other: Money): Money { /* returns NEW instance */ }
  multiply(factor: number): Money { /* returns NEW instance */ }
  equals(other: Money): boolean { /* value comparison */ }
  toDollars(): number { return this.cents / 100; }
}
```

**Rules:** No `id`. No setters. Immutable. Private constructor with factory method for validation.

### Order Aggregate Root

```typescript
export class Order {
  private _status: OrderStatus = "Draft";
  private readonly _lineItems: OrderLineItem[] = [];

  addLineItem(item: OrderLineItem): void {
    if (this._status !== "Draft") throw new Error("Cannot modify placed order");
    this._lineItems.push(item);
  }

  place(): void {
    if (this._lineItems.length === 0) throw new Error("Cannot place empty order");
    this._status = "Placed";
  }

  markPaid(): void {
    if (this._status !== "Placed") throw new Error(`Cannot mark paid from ${this._status}`);
    this._status = "Paid";
  }

  ship(): void {
    if (this._status !== "Paid") throw new Error("Cannot ship unpaid order");
    this._status = "Shipped";
  }
}
```

**Key:** The rule "cannot ship without payment" lives in exactly one place: `Order.ship()`.

### Aggregate Rules

- Aggregate Root is the only entity outside code may reference directly.
- Transactional consistency boundary: things that must stay consistent together belong in the same aggregate.
- Things that can tolerate eventual consistency belong in separate aggregates, linked by ID + domain events.

---

## Part 3: Decoupling Components (IoC & DI)

### Inversion of Control

> High-level policy (business rules) should not depend on low-level detail. Both should depend on an abstraction. Low-level detail is plugged in from the outside.

### Port (Interface)

Owned by the application/domain layer. Describes a capability needed, without knowing who provides it.

```typescript
// core/ordering/application/ports/OrderRepository.ts
export interface OrderRepository {
  findById(id: string): Promise<Order | null>;
  save(order: Order): Promise<void>;
}

// core/ordering/application/ports/PaymentGateway.ts
export interface PaymentGateway {
  charge(orderId: string, amountCents: number): Promise<{ success: boolean; transactionId?: string }>;
}

// core/ordering/application/ports/EventPublisher.ts
export interface EventPublisher {
  publish(event: DomainEvent): Promise<void>;
}
```

**Direction of ownership matters:** Application layer defines the contract. Infrastructure conforms to it.

### Use Case (Application Service)

```typescript
export class PlaceOrderUseCase {
  constructor(
    private readonly orders: OrderRepository,      // Port
    private readonly payments: PaymentGateway,     // Port
    private readonly events: EventPublisher        // Port
  ) {}

  async execute(orderId: string): Promise<{ ok: true } | { ok: false; reason: string }> {
    const order = await this.orders.findById(orderId);
    if (!order) return { ok: false, reason: "Order not found" };

    order.place();

    const result = await this.payments.charge(order.id, order.total().toDollars() * 100);
    if (!result.success) return { ok: false, reason: "Payment failed" };

    order.markPaid();
    await this.orders.save(order);

    await this.events.publish({ type: "OrderPaid", payload: { orderId: order.id }, occurredAt: new Date() });
    return { ok: true };
  }
}
```

**Zero infrastructure imports.** Can run in Server Action, CLI, test, or future non-JS service.

### Adapter (Implementation)

```typescript
// infrastructure/persistence/InMemoryOrderRepository.ts
export class InMemoryOrderRepository implements OrderRepository { /* ... */ }

// infrastructure/payments/FakePaymentGateway.ts
export class FakePaymentGateway implements PaymentGateway { /* ... */ }

// infrastructure/events/ConsoleEventPublisher.ts
export class ConsoleEventPublisher implements EventPublisher { /* ... */ }
```

Small, replaceable, untestable-business-logic-free. Integration-test concern only.

### Composition Root

The one file allowed to know both Ports and Adapters simultaneously.

```typescript
// infrastructure/container.ts
const orderRepository = new InMemoryOrderRepository();
const paymentGateway = new FakePaymentGateway();
const eventPublisher = new ConsoleEventPublisher();

export const placeOrderUseCase = new PlaceOrderUseCase(
  orderRepository, paymentGateway, eventPublisher
);
```

```typescript
// app/actions/place-order.ts
"use server";
import { placeOrderUseCase } from "@/infrastructure/container";

export async function placeOrderAction(orderId: string) {
  const result = await placeOrderUseCase.execute(orderId);
  return result.ok ? { success: true } : { error: result.reason };
}
```

**Server Action = thin translation layer.** Framework-shaped input → use case → framework-shaped output.

### Why Manual DI Over a Framework?

- Zero decorators, zero reflection metadata polyfills
- Wiring is fully visible and greppable in one file
- Works identically in Server Components, Actions, Routes, CLI, tests
- Cost of changing the DI approach itself stays near zero

---

## Part 4: Data Orchestration

### Database Strategy for Modular Monolith

**One physical database, logically partitioned schemas. Hard rule: no cross-schema foreign keys, no cross-schema joins in application code.**

```sql
CREATE TABLE ordering.orders (id TEXT PRIMARY KEY, ...);
CREATE TABLE ordering.order_line_items (
  order_id TEXT NOT NULL REFERENCES ordering.orders(id),
  sku TEXT NOT NULL,        -- reference by VALUE, not FK into catalog
  ...
);
CREATE TABLE inventory.stock_items (sku TEXT PRIMARY KEY, ...);
```

**Why no cross-schema FK?** If Inventory changes its primary key strategy, Ordering must not break.

### The Dual-Write Problem

```
Write Order to DB  →  [CRASH]  →  Publish Event to Queue
     ✓                      ✗
```

Writing to two different systems (DB + queue) is not atomic. If the process crashes between steps, downstream services never hear about it.

### The Outbox Pattern

Write the event to the **same database, same transaction** as the business data change.

```sql
CREATE TABLE ordering.outbox_events (
  id TEXT PRIMARY KEY,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  occurred_at TIMESTAMP NOT NULL DEFAULT now(),
  published_at TIMESTAMP NULL   -- NULL = unpublished
);
```

```typescript
// SqlOrderRepository
async saveWithEvent(order: Order, eventType: string, payload: unknown): Promise<void> {
  await db.transaction(async (tx) => {
    await tx.orders.upsert(order);                          // Business data
    await tx.outboxEvents.insert({ id: crypto.randomUUID(), eventType, payload, occurredAt: new Date(), publishedAt: null });
  });
  // Both succeed together, or neither does.
}
```

```typescript
// OutboxRelay (background process)
async function relayOutboxEvents(): Promise<void> {
  const pending = await db.outboxEvents.findUnpublished();
  for (const event of pending) {
    try {
      await publisher.publish(event);
      await db.outboxEvents.markPublished(event.id);
    } catch (err) {
      // Leave unpublished → retry next tick
    }
  }
}
```

**Why this belongs in infrastructure:** `PlaceOrderUseCase` calls `events.publish(...)` via the Port. It doesn't know about Outbox tables.

### Schema Evolution: Additive by Default

| Change Type | Risk | Strategy |
|-------------|------|----------|
| Add nullable column | Low | Deploy anytime |
| Add table | Low | Deploy anytime |
| Rename column | High | Expand/Contract only |
| Change column type | High | Expand/Contract only |
| Drop column | Medium | Only after confirming zero readers |

### Expand/Contract Pattern

Example: Rename `customer_id` → `buyer_id`

```
Phase 1 (Expand):   Add buyer_id. Backfill from customer_id. Write to both.
Phase 2 (Migrate):  Update all readers to use buyer_id.
Phase 3 (Contract): Stop writing customer_id. Drop after safe monitoring window.
```

**Never rename directly.** Old deployed code may still read the old column during a rolling deploy.

---

## Part 5: Resilience & Scalability

### Retry with Exponential Backoff + Jitter

```typescript
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  options = { maxAttempts: 3, baseDelayMs: 200, maxDelayMs: 5000 }
): Promise<T> {
  for (let attempt = 1; attempt <= options.maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt === options.maxAttempts) throw err;
      const exponential = options.baseDelayMs * 2 ** (attempt - 1);
      const jitter = Math.random() * exponential * 0.3;
      const delay = Math.min(exponential + jitter, options.maxDelayMs);
      await new Promise((r) => setTimeout(r, delay));
    }
  }
}
```

**Why in `core/shared-kernel`?** Retry policy is domain-agnostic algorithm, not infrastructure detail.

### Circuit Breaker

| State | Behavior |
|-------|----------|
| **Closed** | Normal operation. Track failures. |
| **Open** | Fails fast without calling dependency. |
| **Half-Open** | Allows one trial request to check recovery. |

Opens after `failureThreshold` failures. Stays open for `openDurationMs`. Success resets to Closed.

### Decorator Pattern for Resilience

```typescript
export class ResilientPaymentGateway implements PaymentGateway {
  private readonly breaker = new CircuitBreaker(5, 30_000);

  constructor(private readonly inner: PaymentGateway) {}

  async charge(orderId: string, amountCents: number) {
    return this.breaker.execute(() =>
      retryWithBackoff(() => this.inner.charge(orderId, amountCents))
    );
  }
}
```

**Zero changes to `PlaceOrderUseCase` or the real gateway.** Composition root wires `new ResilientPaymentGateway(new RealStripeGateway())`.

### Caching Strategies

| Strategy | When to Use |
|----------|-------------|
| **Cache-aside** | Simple; risk of stale reads until TTL |
| **Write-through** | Cache always fresh; adds write latency |
| **Stale-while-revalidate** | Best perceived perf; tolerance for slight staleness |

**Rule:** Same Product data gets different caching treatment depending on where it's read. Catalog listing = stale-while-revalidate. Checkout price = cache-aside with short TTL or no cache.

### Graceful Degradation

Non-critical dependencies must not block critical paths.

```tsx
export async function RecommendedProducts({ customerId }: { customerId: string }) {
  try {
    const recs = await getRecommendations(customerId);
    return <ProductGrid products={recs} />;
  } catch {
    return null;  // Degrade: no widget, but checkout still works
  }
}
```

### Critical vs. Non-Critical Dependencies

| Dependency | Path | Strategy |
|------------|------|----------|
| Payment Gateway | Critical | Retry + Circuit Breaker |
| Inventory Check | Critical | Retry only (short timeout) |
| Notification Provider | Non-critical | Outbox ensures eventual delivery |
| Recommendation Engine | Non-critical | Graceful degradation to `null` |

---

## Part 6: API Evolution

### REST vs. RPC

| Style | Shape | Best For |
|-------|-------|----------|
| **REST** | `/orders/:id`, verbs via HTTP methods | Public APIs, cacheable reads, CRUD |
| **RPC** | Named procedures (`placeOrder`, `cancelOrder`) | Internal actions, workflows, monorepos |

**Northwind rule:** REST for public resource reads. RPC-style Server Actions for internal action-oriented writes.

### The DTO Boundary

> Never return a domain entity directly from an API. Map to a DTO.

```typescript
export interface OrderDTOv1 {
  id: string;
  status: string;
  totalDollars: number;
  lineItems: { sku: string; quantity: number }[];
}

export function toOrderDTOv1(order: Order): OrderDTOv1 {
  return {
    id: order.id,
    status: order.status,
    totalDollars: order.total().toDollars(),
    lineItems: order.lineItems.map((li) => ({ sku: li.sku, quantity: li.quantity })),
  };
}
```

**Why:** Every internal field of `Order` becomes part of the public contract if returned directly.

### API Versioning Strategy

**Default: Additive-only evolution.**
- Add optional fields. Never remove or rename.
- Introduce `/v2` only for fundamentally incompatible changes (e.g., restructuring `lineItems` shape).
- Both v1 and v2 call the same domain model. Versioning lives at the adapter layer.

### Additive Migration Path (No Version Bump)

Example: Split `phone` → `phoneCountryCode` + `phoneNumber`

1. Add `phoneCountryCode` and `phoneNumber` as new **optional** fields alongside existing `phone`.
2. Populate all three on writes.
3. Deprecate `phone` in docs.
4. Remove `phone` only after telemetry confirms zero consumers read it.

### Gateway / BFF Pattern

```typescript
export function withApiMiddleware(handler: Handler): Handler {
  return async (req: NextRequest) => {
    // Auth, rate limiting, logging — cross-cutting concerns
    // without leaking into core/
    return handler(req);
  };
}
```

Lightweight, composable, extractable into a dedicated gateway later.

---

## Part 7: Architectural Decision Records (ADRs)

### Purpose

Preserve the **why** behind decisions so future maintainers don't reverse-engineer reasoning from code.

### ADR-Worthiness Criteria

Write an ADR when a decision is:
1. **Expensive to reverse** (database choice, module boundary, auth strategy)
2. A **genuine trade-off** (a reasonable person could choose differently)
3. **Likely to be questioned later**
4. A **convention** the whole team must follow

**Do NOT write for:** variable naming, utility library choice, anything reversible in an afternoon.

### Michael Nygard Format

```markdown
# ADR-0007: Title

## Status
Accepted

## Context
What forced the decision.

## Decision
What we chose.

## Alternatives Considered
1. Option A — rejected because ...
2. Option B — rejected because ...
3. Chosen option.

## Consequences
- Positive: ...
- Negative: ...
- Revisit trigger: Under what condition should we reconsider?

## Date
YYYY-MM-DD
```

### ADR Governance Rules

- Numbered **sequentially, append-only**
- **Never edit to reverse.** Write a new ADR that supersedes the old one. Update old Status to `Superseded by ADR-00XX`.
- Live in `docs/adr/` **inside the codebase**, versioned in git
- Required in the **same PR** that implements the decision
- Link from code comments at the exact point of implementation

### Free Tooling

| Tool | Purpose |
|------|---------|
| `adr-tools` (CLI) | `adr new "Title"` scaffolds numbered files |
| `log4brains` (OSS) | Browsable static site from `docs/adr/` |
| Plain Markdown + `grep` | Zero-dependency fallback |

---

## Part 8: The Full System — Assembled

### End-to-End Trace: Placing an Order

```
1. Customer submits checkout form
   → app/actions/place-order.ts                    [Framework layer]

2. Server Action calls placeOrderUseCase.execute()
   → infrastructure/container.ts                   [Composition root wiring]

3. PlaceOrderUseCase executes
   → core/ordering/application/use-cases/          [Application layer]
   → order.place() enforces "must have line items" [Domain rule]
   → this.payments.charge(...) via Port            [IoC — doesn't know Stripe/fake]

4. ResilientPaymentGateway wraps real gateway
   → retryWithBackoff + CircuitBreaker             [Resilience decorators]

5. On success: order.markPaid(), orders.save(order)
   → SqlOrderRepository.saveWithEvent()            [Outbox pattern]
   → Writes Order row AND outbox_events row atomically

6. OutboxRelay (background) picks up OrderPaid event
   → Publishes → Inventory converts reservation to deduction
   → → Notifications sends confirmation              [Published Language]

7. Client polls or receives update
   → GET /api/v2/orders/:id → toOrderDTOv2(order)  [Versioned contract]

8. Every non-trivial choice
   → Has a corresponding entry in docs/adr/        [Decision governance]
```

### Dependency Rule Verification

| Layer | Imports From | Never Imports From |
|-------|--------------|-------------------|
| `core/` | `core/shared-kernel/` | `infrastructure/`, `app/`, `interface-adapters/` |
| `infrastructure/` | `core/` | `app/`, `interface-adapters/` |
| `interface-adapters/` | `core/` | `infrastructure/`, `app/` |
| `app/` | `core/`, `interface-adapters/`, `infrastructure/container.ts` | Nothing below is forbidden |

### Extracting a Context to Microservice

Because every bounded context already has its own `domain/`, `application/`, isolated schema, and Port-based boundaries:

1. Stand up new deployable hosting `core/inventory` + its own `infrastructure/inventory`
2. Replace in-process `EventPublisher` with message broker adapter (Kafka/RabbitMQ) in `container.ts`
3. Write ADR-00XX documenting trigger condition

**Zero `core/inventory` domain code changes.**

### When (and Only When) to Split

Split one context at a time, on **evidence**:
- Independent scaling pressure demonstrated
- Independent team ownership needed
- Independent failure isolation required

**Do NOT split all contexts simultaneously.** That pays the full microservices operational cost (distributed tracing, N pipelines, cross-service integration testing) before any context has proven need.

---

## Quick Reference: Pattern Locations

| Pattern | File Location | Part |
|---------|--------------|------|
| Clean Architecture layering | `src/core/`, `src/infrastructure/`, `src/app/` | 1 |
| Bounded Context | `src/core/ordering/`, `src/core/inventory/` | 2 |
| Value Object | `src/core/ordering/domain/value-objects/Money.ts` | 2 |
| Aggregate Root | `src/core/ordering/domain/entities/Order.ts` | 2 |
| Port | `src/core/ordering/application/ports/*.ts` | 3 |
| Adapter | `src/infrastructure/persistence/`, `payments/`, `events/` | 3 |
| Composition Root | `src/infrastructure/container.ts` | 3 |
| Outbox Table | `ordering.outbox_events` | 4 |
| Outbox Relay | `src/infrastructure/events/OutboxRelay.ts` | 4 |
| Retry + Jitter | `src/core/shared-kernel/resilience/retry.ts` | 5 |
| Circuit Breaker | `src/core/shared-kernel/resilience/CircuitBreaker.ts` | 5 |
| Resilient Decorator | `src/infrastructure/payments/ResilientPaymentGateway.ts` | 5 |
| DTO | `src/interface-adapters/dtos/OrderDTOv1.ts` | 6 |
| API Middleware | `src/interface-adapters/gateway/withApiMiddleware.ts` | 6 |
| ADR | `docs/adr/0001-*.md` | 7 |

---

## Decision Checklist

Before committing an architectural choice, verify:

- [ ] Does this violate the Dependency Rule? (Dependencies must point inward)
- [ ] If I swap the database/framework/vendor tomorrow, does `core/` change?
- [ ] Is the business rule explicit in the domain layer, or implicit in an adapter?
- [ ] Does this schema change require coordinated migration across contexts?
- [ ] Is the dual-write problem solved (Outbox or single transaction)?
- [ ] Are external calls wrapped with retry/circuit breaker?
- [ ] Is the API contract versioned at the DTO layer, not the domain?
- [ ] Is this decision documented in an ADR in the same PR?

---

*End of Student Notes*
