## Primer 0.4: Domain-Driven Foundations & Architectural Patterns

Welcome to **Primer 0.4**—the final bridge before Part 1. Primers 0.1 through 0.3 focused on language constructs and mechanics (TypeScript types, functional purity, async execution). This primer establishes the **conceptual vocabulary** and **core mental models** of modern software architecture that anchor the rest of the series.

```
┌───────────────────────────────────────────────────────────┐
│               Architectural Vocabulary Matrix             │
│                                                           │
│  1. Domain-Driven Design (DDD) Core Taxonomy              │
│  2. Clean Architecture & Dependency Direction             │
│  3. The Cost of Change Lens & Architectural Trade-offs    │
└───────────────────────────────────────────────────────────┘

```

---

### 1. The Domain-Driven Design (DDD) Taxonomy

When building complex software systems, technical code must mirror business realities. DDD gives us a precise vocabulary to draw boundaries around business logic.

```
                  ┌─────────────────────────────────────┐
                  │           Bounded Context           │
                  │                                     │
                  │   ┌─────────────────────────────┐   │
                  │   │       Aggregate Root        │   │
                  │   │  ┌───────────────────────┐  │   │
                  │   │  │        Entity         │  │   │
                  │   │  │   ┌───────────────┐   │  │   │
                  │   │  │   │ Value Object  │   │  │   │
                  │   │  │   └───────────────┘   │  │   │
                  │   │  └───────────────────────┘  │   │
                  │   └─────────────────────────────┘   │
                  └─────────────────────────────────────┘

```

| Concept | Definition | Key Characteristics | Code Example |
| --- | --- | --- | --- |
| **Bounded Context** | A explicit boundary within which a domain model applies and terms are unambiguous. | "Product" in Catalog means details/images; in Inventory it means stock count; in Ordering it means line item price. | Separate TypeScript modules (`core/ordering`, `core/inventory`). |
| **Value Object** | An immutable object defined entirely by its attributes, with no conceptual identity. | Equal by value equality, side-effect free, replaced rather than mutated. | `Money(cents, currency)`, `Address(street, city, zip)`. |
| **Entity** | A domain concept defined by a continuous identity that spans time and state changes. | Has a persistent unique ID (`id`). Two entities with identical properties are distinct if IDs differ. | `Order(id: OrderId)`, `Customer(id: CustomerId)`. |
| **Aggregate** | A cluster of entities and value objects treated as a single data consistency unit. | Enforces invariants. External code can only reference the **Aggregate Root**. | `Order` (Root) containing a collection of `OrderLineItem` entities. |
| **Domain Event** | A record of something significant that has happened in the business domain. | Immutable, past-tense named, published across contexts via event buses or outboxes. | `OrderPlaced`, `PaymentFailed`, `StockReserved`. |

---

### 2. Clean Architecture & The Dependency Inversion Principle

The core rule of Clean Architecture (Hexagonal / Ports & Adapters) is simple: **dependencies only point inward**.

```
  ┌─────────────────────────────────────────────────────────────────┐
  │ 1. Frameworks & Drivers (Next.js, Express, Postgres, Stripe)    │  ← Volatile
  │   ┌─────────────────────────────────────────────────────────┐   │
  │   │ 2. Interface Adapters (Repositories, Controllers, DTOs) │   │
  │   │   ┌─────────────────────────────────────────────────┐   │   │
  │   │   │ 3. Application Use Cases (PlaceOrder, Cancel)   │   │   │
  │   │   │   ┌─────────────────────────────────────────┐   │   │   │
  │   │   │   │ 4. Domain (Entities, Value Objects)     │   │   │   │  ← Stable
  │   │   │   └─────────────────────────────────────────┘   │   │   │
  │   │   └─────────────────────────────────────────────────┘   │   │
  │   └─────────────────────────────────────────────────────────┘   │
  └─────────────────────────────────────────────────────────────────┘

```

#### The Rule in Action

* The **Domain Layer** (`core/ordering/domain`) contains pure business entities and rules. It has **zero dependencies**—no React, no Next.js, no database libraries, no HTTP clients.
* The **Application Layer** (`core/ordering/application`) orchestrates use cases. It defines **Ports** (TypeScript interfaces) for capabilities it needs (e.g., `OrderRepository`, `PaymentGateway`).
* The **Infrastructure Layer** (`infrastructure/`) implements those ports via **Adapters** (e.g., `SqlOrderRepository`, `StripePaymentGateway`).
* **Inversion of Control (IoC)**: High-level policy (use cases) does not depend on low-level implementation (Stripe/Postgres). Both depend on abstractions (Ports).

```ts
// 1. PORT (Interface in Application Layer)
export interface PaymentGateway {
  charge(orderId: string, amountCents: number): Promise<{ success: boolean }>;
}

// 2. USE CASE (Application Layer — depends ONLY on the Port abstraction)
export class PlaceOrderUseCase {
  constructor(private readonly paymentGateway: PaymentGateway) {}

  async execute(orderId: string, totalCents: number) {
    // Business logic...
    const result = await this.paymentGateway.charge(orderId, totalCents);
    return result.success;
  }
}

// 3. ADAPTER (Infrastructure Layer — implements the Port)
export class StripeAdapter implements PaymentGateway {
  async charge(orderId: string, amountCents: number) {
    // Stripe SDK API calls...
    return { success: true };
  }
}

```

---

### 3. The Cost of Change Lens

A junior engineer asks: *"Does this code run correctly?"*

A senior engineer asks: *"Is this code clean and well-tested?"*

An **architect** asks: *"If requirements change in six months, what is the cost to modify this system?"*

#### The Cost Matrix

```
                        High Volatility (Changes Often)
                                     │
                                     │   UI Frameworks,
                                     │   Third-Party APIs,
                                     │   Database Drivers
                                     │
   Low Blast Radius  ────────────────┼────────────────  High Blast Radius
   (Local Utility)                   │                  (Core Business Rules,
                                     │                   Data Schemas)
                                     │
                                     │   Domain Entities,
                                     │   Invariants & State
                                     │
                          Low Volatility (Stable)

```

1. **Protect the High Blast Radius:** Business rules (`Order.place()`, tax logic) must be isolated from volatile infrastructure (Next.js Server Actions, ORM decorators). If swapping a database or web framework requires changing core business logic, your architectural seams are leaking.
2. **Defer Decisions:** Good architecture allows you to postpone choices about databases, messaging tools, and external services until you have maximum information—without blocking domain development.

---

### Checkpoint Exercise

1. **Taxonomy Identification:** In an e-commerce platform, categorize the following concepts as an *Entity*, *Value Object*, *Aggregate Root*, or *Domain Event*:
* `TrackingNumber("1Z9999999999999999")`
* `Order` (which contains line items, status, and shipping info)
* `Customer`
* `OrderShipped`


2. **Dependency Violation Check:** A developer writes `import { db } from "@/infrastructure/db"` directly inside `core/ordering/domain/Order.ts` to check if stock exists. Explain why this violates Clean Architecture principles and how to fix it using a Port.
3. **Architectural Trade-off:** Explain in two sentences why writing business rules directly inside Next.js Server Actions seems faster initially, but increases the overall Cost of Change over time.

---

## You Are Ready for Part 1!

With Primers 0.1 through 0.4 complete, you have mastered:

* **0.1:** Type-level boundaries (branded types, discriminated unions, readonly collections).
* **0.2:** Functional runtime behavior (pure logic, higher-order functions, pipe composition).
* **0.3:** Asynchronous foundations (event loop prioritization, cancellation signals, stream processing).
* **0.4:** Domain vocabulary & Clean Architecture layering concepts.

We are ready to dive into **Part 1: System Architecture vs. System Design (The Architect's Mindset)** and begin building **Northwind Orders**!
