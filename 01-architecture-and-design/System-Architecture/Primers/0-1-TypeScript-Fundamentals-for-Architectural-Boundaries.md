## Primer 0.1: TypeScript Fundamentals for Architectural Boundaries

Welcome to **Primer 0.1**. Before diving into Part 1, this primer covers the core TypeScript capabilities required to build clean, framework-agnostic architectural seams.

```
┌─────────────────────────────────────────────────────────┐
│                 TypeScript Seam Toolkit                 │
│                                                         │
│  1. Value Semantics via Branded Types & Readonly        │
│  2. Explicit Failure Boundaries via Discriminated Unions │
│  3. Interface Segregation via Structural Subtyping      │
└─────────────────────────────────────────────────────────┘

```

---

### 1. Structural Subtyping & The Structural Seam

Unlike nominal type systems (like C# or Java) where a class must explicitly declare `implements InterfaceName`, TypeScript uses **structural typing** ("duck typing" checked at compile-time).

#### Why It Matters for Architecture

This allows our application/domain layer (`core/`) to declare an interface (a **Port**) without taking a dependency on *any* concrete library or infrastructure class. Any object matching the shape automatically satisfies the contract.

```ts
// core/ordering/application/ports/Logger.ts
// Pure interface — zero external dependencies
export interface Logger {
  info(message: string, context?: Record<string, unknown>): void;
  error(message: string, error?: unknown): void;
}

// infrastructure/logging/PinoAdapter.ts
// Notice this class does NOT need to import or explicitly "implement" Logger
// As long as the method signatures match, TypeScript accepts it as a Logger Port adapter.
export class PinoAdapter {
  info(message: string, context?: Record<string, unknown>) {
    // Concrete logging implementation...
  }
  error(message: string, error?: unknown) {
    // Concrete error implementation...
  }
}

```

---

### 2. Immutability as a Design Defense (`readonly` & `ReadonlyArray`)

In Domain-Driven Design (DDD), **Value Objects** must be immutable, and **Aggregates** must strictly control internal state mutations.

```ts
// Enforcing immutability at compile time
export class Money {
  // 1. Immutable primitive properties
  constructor(
    public readonly cents: number,
    public readonly currency: string = "USD"
  ) {
    if (cents < 0) throw new Error("Money cannot be negative");
  }

  // 2. Operations return NEW instances rather than mutating internal state
  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new Error("Currency mismatch");
    }
    return new Money(this.cents + other.cents, this.currency);
  }
}

// Protecting Aggregate Collections
export class Order {
  private _lineItems: OrderLineItem[] = [];

  // Exposing a ReadonlyArray prevents external callers from doing `order.lineItems.push(...)`
  get lineItems(): readonly OrderLineItem[] {
    return this._lineItems;
  }
}

```

---

### 3. Nominal Types with Nominal Branding

Because TypeScript is structural, two types with identical structures are considered identical:

```ts
type CustomerId = string;
type OrderId = string;

let customerId: CustomerId = "cust_123";
let orderId: OrderId = "ord_999";

// DANGER: TypeScript allows this swap because both are structurally `string`
orderId = customerId; 

```

To prevent domain modeling bugs where identifiers are accidentally swapped, we use **Nominal Branding**:

```ts
// core/shared-kernel/types.ts
export type Brand<K, T> = K & { readonly __brand: T };

export type CustomerId = Brand<string, "CustomerId">;
export type OrderId = Brand<string, "OrderId">;

export function makeCustomerId(id: string): CustomerId {
  return id as CustomerId;
}

export function makeOrderId(id: string): OrderId {
  return id as OrderId;
}

// Usage:
let customerId = makeCustomerId("cust_123");
let orderId = makeOrderId("ord_999");

// Compile Error! Type 'Brand<string, "CustomerId">' is not assignable to type 'Brand<string, "OrderId">'
orderId = customerId; 

```

---

### 4. Explicit Error Handling via Discriminated Unions

In modern architecture, operational domain failures (e.g., "Out of Stock", "Payment Invalid") are **expected business outcomes**, not exceptional runtime crashes. We treat errors as return values using Discriminated Unions:

```ts
// Application Use Case Result Types
export type Result<T, E> = 
  | { ok: true; value: T }
  | { ok: false; error: E };

export type OrderPlacementError =
  | { kind: "OUT_OF_STOCK"; sku: string }
  | { kind: "PAYMENT_REJECTED"; reason: string }
  | { kind: "INVALID_ADDRESS" };

// Consuming the result with exhaustive pattern matching
function handleResult(result: Result<string, OrderPlacementError>) {
  if (result.ok) {
    console.log(`Order placed successfully: ${result.value}`);
    return;
  }

  // TypeScript narrows the type of `result.error` based on `kind`
  switch (result.error.kind) {
    case "OUT_OF_STOCK":
      alert(`Item ${result.error.sku} is out of stock.`);
      break;
    case "PAYMENT_REJECTED":
      alert(`Payment failed: ${result.error.reason}`);
      break;
    case "INVALID_ADDRESS":
      alert("Please check your shipping address.");
      break;
  }
}

```

---

### Checkpoint Exercise

1. Create a branded type `SKU` for product stock-keeping units.
2. Define a Value Object `Quantity` that wraps a `number` and guarantees it is a positive integer greater than zero.
3. Write a type-safe `Result` definition for an inventory reservation function that can fail due to `INSUFFICIENT_STOCK` or `WAREHOUSE_OFFLINE`.
