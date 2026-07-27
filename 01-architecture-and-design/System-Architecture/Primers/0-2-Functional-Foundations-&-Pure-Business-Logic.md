## Primer 0.2: Functional Foundations & Pure Business Logic

Welcome to **Primer 0.2**. While Primer 0.1 established type-level safety, this primer focuses on runtime behavior: **how we structure logic so it remains deterministic, testable, and isolated from side effects.**

```
┌───────────────────────────────────────────────────────────┐
│              Functional Core, Imperative Shell            │
│                                                           │
│  1. Pure Functions (Side-Effect Free)                     │
│  2. Higher-Order Functions & Currying                     │
│  3. Composition Seams (Pipelining Domain Logic)          │
└───────────────────────────────────────────────────────────┘

```

---

### 1. Pure Functions: The Core Building Blocks

A function is **pure** if:

1. Given the same input, it **always** returns the exact same output.
2. It produces **no side effects** (no database reads/writes, no network calls, no mutating global state or arguments).

#### Why It Matters for Architecture

In Clean Architecture and Domain-Driven Design, the core domain should consist almost entirely of pure functions or pure aggregate methods. Because they have zero side effects, **they can be unit-tested instantly in memory without mocks, databases, or test containers.**

```ts
// ❌ IMPURE: Reads hidden global/system state and mutates inputs
function calculateTaxImpure(order: { totalCents: number; taxRate?: number }) {
  // Side effect 1: Reading external state (system time / env)
  const currentHour = new Date().getHours(); 
  
  // Side effect 2: Mutating the incoming argument directly
  order.taxRate = currentHour > 18 ? 0.08 : 0.05; 
  
  return order.totalCents * order.taxRate;
}

// ✅ PURE: Explicit inputs, explicit return, zero mutations
export function calculateTax(totalCents: number, taxRate: number): number {
  if (totalCents < 0 || taxRate < 0) {
    throw new Error("Inputs must be non-negative");
  }
  return Math.round(totalCents * taxRate);
}

```

---

### 2. Pure State Transformations vs. In-Place Mutation

When modifying arrays or complex objects within the domain, we avoid mutating methods like `.push()`, `.splice()`, or assigning properties directly. Instead, we compute new states using pure operations.

```ts
export interface CartItem {
  readonly sku: string;
  readonly quantity: number;
  readonly priceCents: number;
}

// Adding or updating an item purely
export function updateCart(
  cart: readonly CartItem[],
  newItem: CartItem
): CartItem[] {
  const existingIndex = cart.findIndex((item) => item.sku === newItem.sku);

  if (existingIndex === -1) {
    return [...cart, newItem];
  }

  return cart.map((item, index) =>
    index === existingIndex
      ? { ...item, quantity: item.quantity + newItem.quantity }
      : item
  );
}

```

---

### 3. Higher-Order Functions & Strategy Injection

A **Higher-Order Function (HOF)** is a function that receives another function as an argument or returns a function. In the domain layer, HOFs allow us to inject policy rules dynamically without creating rigid class hierarchies.

```ts
type DiscountPolicy = (totalCents: number) => number;

// Policy 1: Flat discount
export const flatDiscount = (discountCents: number): DiscountPolicy => 
  (totalCents) => Math.max(0, totalCents - discountCents);

// Policy 2: Percentage discount
export const percentageDiscount = (percent: number): DiscountPolicy => 
  (totalCents) => Math.round(totalCents * (1 - percent / 100));

// Domain function accepting the policy strategy
export function applyOrderDiscount(
  orderTotalCents: number,
  policy: DiscountPolicy
): number {
  return policy(orderTotalCents);
}

// Usage:
const total = 10000; // $100.00
const finalTotal = applyOrderDiscount(total, percentageDiscount(15)); // $85.00

```

---

### 4. Function Composition: Pipelining Operations

Complex business calculations (e.g., total -> volume discount -> promo code -> tax) can be expressed as a linear pipeline of pure functions.

```ts
// Simple unary pipeline helper
export const pipe = <T>(initialValue: T, ...fns: Array<(arg: T) => T>): T =>
  fns.reduce((acc, fn) => fn(acc), initialValue);

// Individual pure transformations
const applyVolumeDiscount = (total: number) => (total > 10000 ? total * 0.9 : total);
const applyVIPDiscount = (total: number) => total - 500;
const applyStandardTax = (total: number) => total * 1.08;

// Pipelining the workflow clearly
export function calculateFinalCheckoutTotal(baseTotalCents: number): number {
  return Math.round(
    pipe(
      baseTotalCents,
      applyVolumeDiscount,
      applyVIPDiscount,
      applyStandardTax
    )
  );
}

```

---

### Checkpoint Exercise

1. Convert a function that calculates stock allocations by mutating an array in-place into a **pure function** returning a new state.
2. Write a Higher-Order Function `createThresholdValidator(minAmount: number)` that returns a policy function validating whether a purchase meets a minimum order threshold.
3. Use `pipe` to combine a sequence of string transformations that normalizes a raw user SKU input (e.g., trimming whitespace, converting to uppercase, removing invalid characters).
