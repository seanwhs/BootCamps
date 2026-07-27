# Part 3 – Data Storage, Databases & Consistency

Data is almost always the hardest part of a system to scale correctly. Compute and networking can be multiplied; persistent state has stronger constraints around consistency, durability, and access patterns.

By the end of this part you will be able to look at a product feature (news feed, search, analytics, payments) and map it to an appropriate storage model, indexing strategy, partitioning scheme, and consistency guarantee.

---

### 3.1 SQL vs NoSQL – Choosing the Right Store by Access Pattern

**The Target**  
Learn the five major families of data stores and the access patterns each is optimized for.

**The Concept**  
Think of data stores as different kinds of filing cabinets:

| Family          | Analogy                              | Best for                              | Classic examples              |
|-----------------|--------------------------------------|---------------------------------------|-------------------------------|
| Relational (SQL)| Spreadsheet with strict columns + foreign keys | Transactions, joins, strong consistency | PostgreSQL, MySQL             |
| Document        | Folder of JSON files                 | Flexible schemas, nested data         | MongoDB, Couchbase, DynamoDB (document mode) |
| Key-Value       | Giant dictionary / hash map          | Simple lookups by ID, caching         | Redis, DynamoDB, etcd         |
| Columnar        | Spreadsheet stored by column         | Analytics, aggregations over many rows| ClickHouse, BigQuery, Cassandra (wide-column) |
| Graph           | Network of nodes and edges           | Relationships, recommendations, social graphs | Neo4j, Amazon Neptune     |

**Rule of thumb**  
Start with the queries you need to run, not with the technology name. If you need multi-row ACID transactions and complex joins → relational. If you need to fetch an entire user profile by ID in one round-trip and the shape changes often → document. If you only ever look up by primary key → key-value.

**The Implementation**  
A side-by-side illustration of the same “user + orders” data in relational style versus document style (using pure Python data structures so you can run it anywhere).

```python
# file: part3/sql_vs_document.py
from dataclasses import dataclass, field
from typing import List, Dict, Any
import json

# ---------- Relational mental model ----------
@dataclass
class UserRow:
    id: int
    email: str
    name: str

@dataclass
class OrderRow:
    id: int
    user_id: int
    amount: float
    status: str

# Simulated tables
users_table: Dict[int, UserRow] = {
    1: UserRow(1, "alice@example.com", "Alice"),
    2: UserRow(2, "bob@example.com", "Bob"),
}
orders_table: Dict[int, OrderRow] = {
    101: OrderRow(101, 1, 29.99, "paid"),
    102: OrderRow(102, 1, 9.50, "pending"),
    103: OrderRow(103, 2, 100.00, "paid"),
}

def get_user_with_orders_sql(user_id: int) -> Dict[str, Any]:
    """Emulates a JOIN."""
    user = users_table[user_id]
    orders = [o for o in orders_table.values() if o.user_id == user_id]
    return {
        "id": user.id,
        "email": user.email,
        "name": user.name,
        "orders": [{"id": o.id, "amount": o.amount, "status": o.status} for o in orders],
    }

# ---------- Document mental model ----------
user_documents: Dict[int, Dict[str, Any]] = {
    1: {
        "id": 1,
        "email": "alice@example.com",
        "name": "Alice",
        "orders": [
            {"id": 101, "amount": 29.99, "status": "paid"},
            {"id": 102, "amount": 9.50, "status": "pending"},
        ],
    },
    2: {
        "id": 2,
        "email": "bob@example.com",
        "name": "Bob",
        "orders": [
            {"id": 103, "amount": 100.00, "status": "paid"},
        ],
    },
}

def get_user_with_orders_document(user_id: int) -> Dict[str, Any]:
    """Single lookup – no join needed."""
    return user_documents[user_id]

if __name__ == "__main__":
    print("=== Relational (JOIN) style ===")
    print(json.dumps(get_user_with_orders_sql(1), indent=2))

    print("\n=== Document style ===")
    print(json.dumps(get_user_with_orders_document(1), indent=2))
```

**The Verification**  
```bash
cd part3
python sql_vs_document.py
```
Both produce the same logical result. The relational version required a join; the document version required only a single key lookup. That difference becomes dramatic at scale.

---

### 3.2 Indexing, Read Replicas, Connection Pooling, Partitioning / Sharding

**The Target**  
Learn the four most common techniques that keep databases responsive under load.

**The Concept**  

- **Index** – a sorted side table that lets the database find rows without scanning everything (like the index at the back of a book).  
- **Read replica** – a near-real-time copy of the primary database that serves only read queries, spreading the load.  
- **Connection pool** – a cache of open database connections so the application does not pay the expensive “open TCP + authenticate” cost on every request.  
- **Partitioning / Sharding** – splitting a large table across multiple machines (or disks) by a partition key (user_id, tenant_id, time range, etc.).

**Sharding analogy**  
Instead of one giant phone book for the whole country, you give each city its own phone book. Lookups stay fast, but any query that needs data from many cities becomes harder (scatter-gather).

**The Implementation**  
A working in-memory illustration of hash-based sharding + a simple connection-pool pattern.

```python
# file: part3/sharding_and_pool.py
import hashlib
import threading
from typing import List, Dict, Any, Optional
from dataclasses import dataclass

@dataclass
class FakeConnection:
    id: int
    in_use: bool = False

class ConnectionPool:
    """Extremely simplified connection pool."""
    def __init__(self, size: int = 5):
        self._pool = [FakeConnection(i) for i in range(size)]
        self._lock = threading.Lock()

    def acquire(self) -> FakeConnection:
        with self._lock:
            for conn in self._pool:
                if not conn.in_use:
                    conn.in_use = True
                    return conn
        raise RuntimeError("Pool exhausted")

    def release(self, conn: FakeConnection):
        with self._lock:
            conn.in_use = False

class Shard:
    def __init__(self, shard_id: int):
        self.shard_id = shard_id
        self.data: Dict[str, Any] = {}
        self.pool = ConnectionPool(size=3)

    def put(self, key: str, value: Any):
        conn = self.pool.acquire()
        try:
            self.data[key] = value
        finally:
            self.pool.release(conn)

    def get(self, key: str) -> Optional[Any]:
        conn = self.pool.acquire()
        try:
            return self.data.get(key)
        finally:
            self.pool.release(conn)

class ShardedStore:
    def __init__(self, num_shards: int = 4):
        self.shards = [Shard(i) for i in range(num_shards)]

    def _shard_for(self, key: str) -> Shard:
        h = int(hashlib.md5(key.encode()).hexdigest(), 16)
        return self.shards[h % len(self.shards)]

    def put(self, key: str, value: Any):
        self._shard_for(key).put(key, value)

    def get(self, key: str) -> Optional[Any]:
        return self._shard_for(key).get(key)

    def stats(self):
        return {f"shard-{s.shard_id}": len(s.data) for s in self.shards}

if __name__ == "__main__":
    store = ShardedStore(num_shards=4)

    for i in range(100):
        store.put(f"user:{i}", {"name": f"User{i}", "balance": i * 10})

    print("Distribution across shards:", store.stats())
    print("Lookup user:42 →", store.get("user:42"))
```

**The Verification**  
```bash
python sharding_and_pool.py
```
You should see the 100 keys spread across the four shards and a successful lookup. In a real system the same hash function decides which physical database node owns the key.

---

### 3.3 Distributed Transactions: Two-Phase Commit (2PC) and the Saga Pattern

**The Target**  
Understand why classic ACID transactions become difficult across service or database boundaries, and learn the two most common replacement patterns.

**The Concept**  

- **Two-Phase Commit (2PC)** – a coordinator asks all participants “Can you commit?” (prepare phase). If everyone says yes, it tells them “Commit”; otherwise “Rollback”.  
  Strong consistency, but the coordinator is a single point of failure and the protocol is blocking.

- **Saga** – break the business transaction into a sequence of local transactions. Each step has a compensating action that undoes it if a later step fails.  
  No global lock; eventual consistency; more complex error handling.

**Analogy**  
2PC is a group of friends who all raise their hands before anyone pays the bill.  
Saga is a group of friends who each pay their own part; if one person can’t pay, the others get refunds.

**The Implementation**  
A complete, runnable Saga for a classic “create order → charge payment → reserve inventory” flow, including compensations.

```python
# file: part3/saga_example.py
from enum import Enum, auto
from dataclasses import dataclass, field
from typing import List, Callable, Optional
import traceback

class StepStatus(Enum):
    PENDING = auto()
    SUCCESS = auto()
    FAILED = auto()
    COMPENSATED = auto()

@dataclass
class Step:
    name: str
    action: Callable[[], None]
    compensate: Callable[[], None]
    status: StepStatus = StepStatus.PENDING

@dataclass
class Saga:
    name: str
    steps: List[Step] = field(default_factory=list)

    def add_step(self, name: str, action: Callable, compensate: Callable):
        self.steps.append(Step(name, action, compensate))

    def execute(self) -> bool:
        print(f"\n=== Starting saga: {self.name} ===")
        for i, step in enumerate(self.steps):
            try:
                print(f"→ Executing: {step.name}")
                step.action()
                step.status = StepStatus.SUCCESS
            except Exception as e:
                print(f"✗ Step failed: {step.name} ({e})")
                step.status = StepStatus.FAILED
                # Compensate in reverse order
                for prev in reversed(self.steps[:i]):
                    if prev.status == StepStatus.SUCCESS:
                        print(f"  ← Compensating: {prev.name}")
                        try:
                            prev.compensate()
                            prev.status = StepStatus.COMPENSATED
                        except Exception as ce:
                            print(f"  !! Compensation failed: {ce}")
                return False
        print(f"=== Saga {self.name} completed successfully ===")
        return True

# ---------- Simulated services ----------
class PaymentService:
    def __init__(self):
        self.charges = {}

    def charge(self, order_id: str, amount: float):
        if amount > 500:
            raise Exception("Card declined")
        self.charges[order_id] = amount
        print(f"  [Payment] charged {amount} for {order_id}")

    def refund(self, order_id: str):
        amount = self.charges.pop(order_id, 0)
        print(f"  [Payment] refunded {amount} for {order_id}")

class InventoryService:
    def __init__(self):
        self.stock = {"sku-1": 10}

    def reserve(self, order_id: str, sku: str, qty: int):
        if self.stock.get(sku, 0) < qty:
            raise Exception("Out of stock")
        self.stock[sku] -= qty
        print(f"  [Inventory] reserved {qty} of {sku} for {order_id}")

    def release(self, order_id: str, sku: str, qty: int):
        self.stock[sku] = self.stock.get(sku, 0) + qty
        print(f"  [Inventory] released {qty} of {sku} for {order_id}")

class OrderService:
    def __init__(self):
        self.orders = {}

    def create(self, order_id: str, amount: float):
        self.orders[order_id] = {"amount": amount, "status": "created"}
        print(f"  [Order] created {order_id}")

    def cancel(self, order_id: str):
        if order_id in self.orders:
            self.orders[order_id]["status"] = "cancelled"
            print(f"  [Order] cancelled {order_id}")

# ---------- Demo ----------
if __name__ == "__main__":
    payments = PaymentService()
    inventory = InventoryService()
    orders = OrderService()

    def build_saga(order_id: str, amount: float, sku: str, qty: int) -> Saga:
        s = Saga(f"Order-{order_id}")
        s.add_step(
            "create-order",
            action=lambda: orders.create(order_id, amount),
            compensate=lambda: orders.cancel(order_id),
        )
        s.add_step(
            "charge-payment",
            action=lambda: payments.charge(order_id, amount),
            compensate=lambda: payments.refund(order_id),
        )
        s.add_step(
            "reserve-inventory",
            action=lambda: inventory.reserve(order_id, sku, qty),
            compensate=lambda: inventory.release(order_id, sku, qty),
        )
        return s

    # Happy path
    build_saga("ord-100", 42.0, "sku-1", 2).execute()

    # Failure path (amount > 500 triggers payment failure)
    build_saga("ord-101", 600.0, "sku-1", 1).execute()
```

**The Verification**  
```bash
python saga_example.py
```
The first saga succeeds. The second fails at the payment step and the earlier steps are compensated (order cancelled, no inventory left reserved). This is the pattern used by most modern microservice order flows.

---

### 3.4 Consistency Models

**The Target**  
Know the practical consistency guarantees you will actually encounter and when each is acceptable.

**The Concept**  

| Model                  | Guarantee                                      | Typical use case                     | Cost                          |
|------------------------|------------------------------------------------|--------------------------------------|-------------------------------|
| Strong                 | After a write completes, every subsequent read sees it | Bank balances, inventory reservation | Higher latency, lower availability |
| Eventual               | If no new writes occur, all readers will eventually see the last write | Social likes, view counts, product catalogs | Low latency, high availability |
| Read-your-writes       | A client always sees its own writes            | User profile updates, “my” cart      | Session affinity or version vectors |
| Monotonic reads        | Once a client has seen a value, it never sees an older one | Feed scrolling, timelines            | Careful replica selection     |
| Causal                 | If A causally precedes B, everyone sees A before B | Comment threads, collaborative editing | Metadata overhead             |

**Practical mapping**  
- Payments, stock reservation, unique username creation → strong.  
- “Number of likes”, recommendation scores, search indexes → eventual.  
- After a user edits their profile they must see the new data → read-your-writes.

**The Implementation**  
A tiny demonstration of eventual consistency versus strong consistency using two in-memory replicas.

```python
# file: part3/consistency_models.py
import time
import threading
from copy import deepcopy

class EventuallyConsistentStore:
    def __init__(self):
        self.replicas = [{"value": None}, {"value": None}]
        self.lock = threading.Lock()

    def write(self, value):
        with self.lock:
            self.replicas[0]["value"] = value
        # Asynchronously propagate to second replica
        def propagate():
            time.sleep(0.3)          # simulate network delay
            with self.lock:
                self.replicas[1]["value"] = value
        threading.Thread(target=propagate, daemon=True).start()

    def read(self, replica_id: int = 0):
        with self.lock:
            return self.replicas[replica_id]["value"]

class StronglyConsistentStore:
    def __init__(self):
        self.value = None
        self.lock = threading.Lock()

    def write(self, value):
        with self.lock:
            self.value = value

    def read(self):
        with self.lock:
            return self.value

if __name__ == "__main__":
    print("=== Eventual consistency ===")
    ec = EventuallyConsistentStore()
    ec.write("v1")
    print("Immediate read replica-0:", ec.read(0))
    print("Immediate read replica-1:", ec.read(1))   # still old
    time.sleep(0.4)
    print("After delay replica-1:", ec.read(1))      # now updated

    print("\n=== Strong consistency ===")
    sc = StronglyConsistentStore()
    sc.write("v1")
    print("Read after write:", sc.read())            # always sees latest
```

**The Verification**  
```bash
python consistency_models.py
```
You will observe the lag on the second replica under eventual consistency and the immediate visibility under strong consistency.

---

### Reference Section – Mapping Product Features to Storage

| Feature                        | Primary store type      | Consistency need     | Scaling technique          |
|--------------------------------|-------------------------|----------------------|----------------------------|
| User accounts & credentials    | Relational or document  | Strong               | Read replicas              |
| Shopping cart                  | Key-value or document   | Read-your-writes     | Sticky sessions / Redis    |
| Product catalog                | Document + search index | Eventual             | CDN + read replicas        |
| Order & payment                | Relational              | Strong + Saga        | Careful sharding by customer |
| Social news feed               | Hybrid (graph + timeline store) | Eventual / causal | Fan-out on write or read, sharding by user |
| Analytics / dashboards         | Columnar                | Eventual             | Time-based partitioning    |
| Real-time leaderboard          | Key-value (Redis sorted set) | Eventual          | In-memory + periodic snapshot |
| Friend / follow graph          | Graph or relational     | Strong for writes    | Sharding by user_id        |

---

### What You Can Do Now

Given any new feature you can ask:

1. What are the dominant access patterns (point lookup, range scan, join, aggregation, graph traversal)?  
2. How fresh does the data need to be for different readers?  
3. Can the data be partitioned by a key that appears in most queries?  
4. Do I need a multi-step business transaction that spans services? If yes, is Saga acceptable or do I truly need 2PC?

These four questions drive almost every storage decision you will make.
