# Student Workbook
## Architecting Modern Systems: From Monolith to Evolvable Systems

---

## How to Use This Workbook

Read each part of the series, then complete the corresponding section in this workbook before moving on. The exercises are designed to be completed with a pen, in a text editor, or in discussion with a study group. Space is provided for your answers.

---

# Part 1: System Architecture vs. System Design

### Concept Check (Fill in the blank)

1. Architecture optimizes for _______________. Design optimizes for _______________.

2. The Dependency Rule states that source code dependencies can only point _______________.

3. Locality of Behavior (LoB) means: ________________________________________________
   ________________________________________________________________________________

4. The four levels of the C4 Model are:
   - Level 1: ________________________
   - Level 2: ________________________
   - Level 3: ________________________
   - Level 4: ________________________

### Reflection

5. Think of a system you have worked on. Was it closer to a "Big Ball of Mud" or a "Premature Distribution"? What was the primary cost you paid?
   ________________________________________________________________________________
   ________________________________________________________________________________
   ________________________________________________________________________________

6. Identify one framework or database in your current stack. If you had to replace it next quarter, how many files would need to change?
   ________________________________________________________________________________
   ________________________________________________________________________________

### Design Exercise: C4 Context Diagram

7. Draw a C4 Context Diagram for a system you are currently building or maintaining. Identify:
   - Human actors: ________________________________________________________________
   - External systems: ____________________________________________________________
   - The core system boundary: ____________________________________________________

---

# Part 2: Designing the Core (DDD Basics)

### Concept Check

1. A Bounded Context is: ___________________________________________________________
   ________________________________________________________________________________

2. The difference between an Entity and a Value Object:
   - Entity: _____________________________________________________________________
   - Value Object: ________________________________________________________________

3. Why should `OrderLineItem` not hold a foreign key reference to `Catalog.Product`?
   ________________________________________________________________________________
   ________________________________________________________________________________

4. The Aggregate Root rule: outside code may only reference the _______________ directly.

### Code Exercise: Money Value Object

5. Given the `Money` class from Part 2, what happens if you call `Money.fromDollars(-5)`?
   ________________________________________________________________________________

6. Why does `Money.add()` return a new instance instead of mutating `this`?
   ________________________________________________________________________________
   ________________________________________________________________________________

### Design Exercise: Discount Codes

7. Is `DiscountCode` (code string, percentage, expiry date) best modeled as an Entity or a Value Object? Justify.
   ________________________________________________________________________________
   ________________________________________________________________________________

8. If a discount code has a "maximum uses" limit that must be tracked over time, what additional concept do you need?
   ________________________________________________________________________________

9. Sketch a Context Map showing how a new `Promotions` bounded context communicates with `Ordering`.
   ________________________________________________________________________________
   ________________________________________________________________________________

---

# Part 3: Decoupling Components (IoC & DI)

### Concept Check

1. Inversion of Control means high-level policy should not depend on _______________; both should depend on _______________.

2. A Port is: ____________________________________________________________________
   ________________________________________________________________________________

3. An Adapter is: ________________________________________________________________
   ________________________________________________________________________________

4. The Composition Root is the only place allowed to: ______________________________
   ________________________________________________________________________________

### Code Exercise: Port Definition

5. Write the TypeScript interface for a `NotificationSender` port (method: `send(customerId: string, message: string): Promise<void>`).
   ```typescript
   // Your answer here:

   ```

6. Write a `ConsoleNotificationSender` adapter that implements this port.
   ```typescript
   // Your answer here:

   ```

### Trace Exercise

7. Trace the dependency arrows in this statement: `PlaceOrderUseCase` imports `OrderRepository` (a Port). `SqlOrderRepository` (an Adapter) imports `OrderRepository` and implements it.
   - Does `core/` know about `infrastructure/`?  Yes / No
   - Does `infrastructure/` know about `core/`?    Yes / No
   - Which direction does the dependency arrow point? _____________________________

### Design Exercise: Swapping Adapters

8. List three infrastructure changes that should require zero changes to `core/`:
   - _____________________________________________________________________________
   - _____________________________________________________________________________
   - _____________________________________________________________________________

9. Why does this series prefer manual constructor injection over a DI framework like InversifyJS?
   ________________________________________________________________________________
   ________________________________________________________________________________

---

# Part 4: Data Orchestration

### Concept Check

1. In a Modular Monolith, the recommended database strategy is: ____________________
   ________________________________________________________________________________

2. The Dual-Write Problem occurs when: ____________________________________________
   ________________________________________________________________________________

3. The Outbox Pattern solves this by: _____________________________________________
   ________________________________________________________________________________

4. What table is added to implement the Outbox Pattern? ____________________________

### Schema Exercise

5. Why should `order_line_items.sku` NOT be a foreign key into `inventory.stock_items`?
   ________________________________________________________________________________
   ________________________________________________________________________________

6. Design the `inventory.reservations` table schema:
   ```sql
   CREATE TABLE inventory.reservations (
     -- Your columns here
   );
   ```

### Migration Exercise

7. You need to rename the column `customer_id` to `buyer_id` in the `orders` table. Write the three phases of the expand/contract pattern:
   - Phase 1 (Expand): ____________________________________________________________
   - Phase 2 (Migrate): ___________________________________________________________
   - Phase 3 (Contract): __________________________________________________________

8. Why is adding a nullable column considered low-risk, while renaming a column is high-risk?
   ________________________________________________________________________________
   ________________________________________________________________________________

### Event Flow Exercise

9. Trace the Outbox event flow for: Order Placed -> Stock Reserved -> Payment Failed -> Stock Released.
   - Which context owns the `OrderPlaced` outbox event? ____________________________
   - Which context owns the `PaymentFailed` outbox event? ___________________________
   - Which context reacts to these events to release stock? _________________________

---

# Part 5: Resilience & Scalability

### Concept Check

1. Retry with exponential backoff uses the formula: delay = ________________________

2. Jitter is added to retries to prevent: _________________________________________

3. A Circuit Breaker has three states:
   - ________________________
   - ________________________
   - ________________________

4. The Decorator pattern allows us to add resilience without modifying: ____________

### Classification Exercise

5. Classify each Northwind dependency as Critical Path or Non-Critical:
   - Payment Gateway: ________________________
   - Notification Provider: __________________
   - Recommendation Engine: __________________
   - Inventory Check: ________________________

6. For each critical-path dependency, choose the appropriate resilience strategy:
   - Payment Gateway: Retry / Circuit Breaker / Both / Neither
   - Inventory Check: Retry / Circuit Breaker / Both / Neither

### Design Exercise: Caching

7. The Catalog product listing page should use which caching strategy? ______________
   Why? __________________________________________________________________________

8. The final price shown at checkout should use which caching strategy? ____________
   Why? __________________________________________________________________________

### Code Exercise: Graceful Degradation

9. Write pseudocode or TypeScript for a Server Component that renders a recommendations widget, but degrades to `null` if the service is down.
   ```typescript
   // Your answer here:

   ```

---

# Part 6: API Evolution

### Concept Check

1. REST is best for: _____________________________________________________________
   RPC-style is best for: _________________________________________________________

2. The DTO Boundary exists to prevent: ____________________________________________
   ________________________________________________________________________________

3. Additive-only API evolution means: ____________________________________________
   ________________________________________________________________________________

4. URI versioning (e.g., `/v1/orders`, `/v2/orders`) should be introduced only when: __
   ________________________________________________________________________________

### Design Exercise: DTO Mapping

5. An `Order` domain entity has these internal fields: `id`, `status`, `lineItems`, `totalCents`, `customerId`, `internalNotes`, `createdAt`, `paymentTransactionId`.
   Which fields belong in a public `OrderDTOv1`?
   ________________________________________________________________________________
   Which fields must NEVER be exposed?
   ________________________________________________________________________________

### Migration Exercise

6. A breaking change is requested: split `phone` into `phoneCountryCode` and `phoneNumber`. Design an additive-only migration path that avoids a `/v2` bump.
   ________________________________________________________________________________
   ________________________________________________________________________________
   ________________________________________________________________________________

### Style Exercise

7. Why is `cancelOrder` a poor fit for RESTful CRUD, and better suited to RPC-style?
   ________________________________________________________________________________
   ________________________________________________________________________________

---

# Part 7: Architectural Decision Records

### Concept Check

1. An ADR preserves the _______________ behind a decision, not just the result.

2. Four criteria for ADR-worthiness:
   - _____________________________________________________________________________
   - _____________________________________________________________________________
   - _____________________________________________________________________________
   - _____________________________________________________________________________

3. The Michael Nygard ADR format includes these sections:
   - ________________________
   - ________________________
   - ________________________
   - ________________________
   - ________________________

4. ADRs are numbered _______________ and are _______________ (never edited to reverse).

### Writing Exercise

5. Write ADR-0008 for the decision: "Use a single physical database with logically separated schemas instead of database-per-service."
   Include: Context, Decision, at least two Alternatives Considered, Consequences, and a Revisit Trigger.

   ```markdown
   # ADR-0008: Single Physical Database with Logical Schema Separation

   ## Status
   Accepted

   ## Context


   ## Decision


   ## Alternatives Considered
   1. 
   2. 

   ## Consequences
   - Positive: 
   - Negative: 
   - Revisit trigger: 

   ## Date

   ```

6. Write ADR-0009 for the decision: "Prefer additive-only API evolution over URI versioning by default." Define an explicit revisit trigger.

   ```markdown
   # ADR-0009: Additive-Only API Evolution by Default

   ## Status
   Accepted

   ## Context


   ## Decision


   ## Alternatives Considered
   1. 
   2. 

   ## Consequences
   - Positive: 
   - Negative: 
   - Revisit trigger: 

   ## Date

   ```

### Governance Exercise

7. Why should an ADR be required in the same PR that implements the decision?
   ________________________________________________________________________________
   ________________________________________________________________________________

8. Where should ADRs live? Why not a separate wiki?
   ________________________________________________________________________________
   ________________________________________________________________________________

---

# Part 8: The Full System — Capstone

### Integration Exercise

1. Trace the complete end-to-end flow of placing an order through the assembled system. Number each step from 1 to 8 and name the file/layer it occurs in.

   | Step | Layer / File | What Happens |
   |------|--------------|--------------|
   | 1 | | |
   | 2 | | |
   | 3 | | |
   | 4 | | |
   | 5 | | |
   | 6 | | |
   | 7 | | |
   | 8 | | |

2. If you extract `Inventory` into a standalone microservice, list the exact changes required:
   - _____________________________________________________________________________
   - _____________________________________________________________________________
   - _____________________________________________________________________________
   - _____________________________________________________________________________

3. Which file in the monolith would change to swap the in-process event bus for RabbitMQ?
   ________________________________________________________________________________

### ADR Exercise

4. Write ADR-0012 documenting the extraction of Inventory to a standalone service. Include context (what scaling pressure justified it), alternatives considered, and consequences.

   ```markdown
   # ADR-0012: Extract Inventory to Standalone Service
   ## Status
   Accepted (supersedes ADR-0003)

   ## Context


   ## Decision


   ## Alternatives Considered
   1. 
   2. 

   ## Consequences
   - Positive: 
   - Negative: 

   ## Date

   ```

### Justification Exercise

5. In one paragraph, explain why Northwind Orders should NOT jump straight to full microservices for all five contexts simultaneously, even after the Inventory split.
   ________________________________________________________________________________
   ________________________________________________________________________________
   ________________________________________________________________________________
   ________________________________________________________________________________
   ________________________________________________________________________________

---

# Final Reflection

## The Cost of Change Lens

1. Looking back at all eight parts, which single architectural decision do you think most effectively reduces the Cost of Change? Why?
   ________________________________________________________________________________
   ________________________________________________________________________________
   ________________________________________________________________________________

2. Identify one decision from your own current project that would have benefited from an ADR. Write a one-sentence summary of what that ADR would have captured.
   ________________________________________________________________________________
   ________________________________________________________________________________

3. If you could apply only ONE pattern from this series to your codebase tomorrow, which would it be and what is the first file you would create?
   ________________________________________________________________________________
   ________________________________________________________________________________

## Self-Assessment

Rate your confidence (1–5) in explaining each concept to a teammate:

| Concept | Confidence (1–5) | Notes |
|---------|------------------|-------|
| Clean Architecture layering | | |
| Bounded Contexts | | |
| Entities vs. Value Objects | | |
| Ports & Adapters | | |
| Composition Root | | |
| Outbox Pattern | | |
| Expand/Contract migrations | | |
| Retry + Circuit Breaker | | |
| DTO mapping | | |
| Additive API evolution | | |
| ADR format & governance | | |
| Modular Monolith extraction | | |

---

*Workbook complete. Return to the series text for solutions and discussion.*
