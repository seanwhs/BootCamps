# APPENDIX PRIMER 5 — Introduction to NoSQL & Distributed Systems

## Understanding Modern Data Architectures

---

## P5.1 Introduction

Welcome to the fifth primer! You've learned about relational databases, performance optimization, and transactions. Now it's time to explore the world beyond traditional SQL databases.

**By the end of this primer, you will understand:**
- What NoSQL databases are and why they exist
- The different types of NoSQL databases
- When to use NoSQL vs. SQL
- Basic concepts of distributed systems
- What the CAP theorem means
- How ScaleCart uses multiple database technologies

**Estimated time:** 30-45 minutes

---

## P5.2 What Is NoSQL?

### P5.2.1 The Analogy: Different Tools for Different Jobs

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NOSQL ANALOGY                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Imagine you have a toolbox:                                    │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SQL Database = A Hammer                                   │ │
│   │  • Good for many tasks                                     │ │
│   │  • Strong and reliable                                     │ │
│   │  • But not always the right tool                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  NoSQL Databases = Specialized Tools                       │ │
│   │  • Screwdriver for screws                                  │ │
│   │  • Wrench for bolts                                        │ │
│   │  • Saw for cutting                                         │ │
│   │  • Each tool is best for specific jobs                     │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   NoSQL = "Not Only SQL"                                          │
│   Not "No SQL" - it's about using different approaches           │
│   for different data needs.                                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.2.2 Why NoSQL?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHY NOSQL?                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   SQL Databases (RDBMS) are great for:                           │
│   • Structured data with fixed schemas                           │
│   • Strong consistency requirements                              │
│   • Complex joins and relationships                              │
│   • ACID transactions                                            │
│                                                                     │
│   NoSQL Databases are better for:                                │
│   • Unstructured or semi-structured data                         │
│   • Massive scale (millions of users)                           │
│   • High write throughput                                        │
│   • Flexible schemas                                             │
│   • Horizontal scaling                                           │
│   • Specialized data patterns                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P5.3 Types of NoSQL Databases

### P5.3.1 Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NOSQL CATEGORIES                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. DOCUMENT STORES                                        │ │
│   │  • Store data as JSON-like documents                       │ │
│   │  • Flexible schema                                         │ │
│   │  • Example: MongoDB, Couchbase                            │ │
│   │  • Best for: Catalogs, user profiles, content management  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  2. KEY-VALUE STORES                                      │ │
│   │  • Simple key-value pairs                                  │ │
│   │  • Extremely fast                                          │ │
│   │  • Example: Redis, DynamoDB, Memcached                   │ │
│   │  • Best for: Caching, sessions, real-time data            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  3. WIDE-COLUMN STORES                                    │ │
│   │  • Tables with rows and dynamic columns                   │ │
│   │  • Sparse data, huge scale                                │ │
│   │  • Example: Cassandra, HBase                             │ │
│   │  • Best for: Time-series, IoT, logging                   │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  4. GRAPH DATABASES                                       │ │
│   │  • Nodes and relationships                                 │ │
│   │  • Traversal is the primary operation                     │ │
│   │  • Example: Neo4j, Amazon Neptune                        │ │
│   │  • Best for: Social networks, recommendations, fraud     │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  5. SEARCH ENGINES                                        │ │
│   │  • Full-text search and analytics                          │ │
│   │  • Inverted indexes                                        │ │
│   │  • Example: Elasticsearch, Solr                          │ │
│   │  • Best for: Search, log analytics, monitoring           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  6. TIME-SERIES DATABASES                                 │ │
│   │  • Optimized for time-stamped data                        │ │
│   │  • Efficient aggregation                                   │ │
│   │  • Example: TimescaleDB, InfluxDB                       │ │
│   │  • Best for: Metrics, IoT, monitoring                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.3.2 Document Stores: MongoDB Example

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MONGODB EXAMPLE                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   SQL (Relational):                                               │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Table: Products                                           │ │
│   │  ┌──────┬──────────────┬────────────┬─────────────────┐  │ │
│   │  │ id   │ name         │ price      │ category_id     │  │ │
│   │  ├──────┼──────────────┼────────────┼─────────────────┤  │ │
│   │  │ 1    │ MacBook Pro  │ 2499.99    │ 5               │  │ │
│   │  └──────┴──────────────┴────────────┴─────────────────┘  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   MongoDB (Document):                                            │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  {                                                         │ │
│   │    "_id": ObjectId("..."),                                │ │
│   │    "name": "MacBook Pro",                                 │ │
│   │    "price": 2499.99,                                      │ │
│   │    "category": {                                           │ │
│   │      "id": 5,                                              │ │
│   │      "name": "Laptops",                                   │ │
│   │      "parent": "Electronics"                              │ │
│   │    },                                                     │ │
│   │    "specs": {                                              │ │
│   │      "cpu": "M2 Pro",                                     │ │
│   │      "ram": "16GB",                                       │ │
│   │      "storage": "512GB"                                   │ │
│   │    },                                                     │ │
│   │    "reviews": [                                            │ │
│   │      { "user": "john", "rating": 5, "comment": "Great!" },│ │
│   │      { "user": "jane", "rating": 4, "comment": "Good" }   │ │
│   │    ]                                                      │ │
│   │  }                                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Benefits:                                                      │
│   • Nested data without joins                                    │
│   • Flexible schema (can add fields anytime)                    │
│   • Natural mapping to application objects                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.3.3 Key-Value Stores: Redis Example

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REDIS EXAMPLE                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Redis is a key-value store with advanced data structures.       │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SET user:42:name "John Doe"                              │ │
│   │  SET user:42:email "john@example.com"                     │ │
│   │  GET user:42:name  → "John Doe"                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Redis also supports:                                           │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  • Hashes (like objects)                                   │ │
│   │    HSET user:42 name "John" email "john@e.com"            │ │
│   │    HGET user:42 name → "John"                             │ │
│   │                                                             │ │
│   │  • Lists (ordered)                                         │ │
│   │    LPUSH user:42:orders "order1" "order2"                  │ │
│   │                                                             │ │
│   │  • Sets (unique, unordered)                                │ │
│   │    SADD user:42:favorites "product1" "product2"            │ │
│   │                                                             │ │
│   │  • Sorted Sets (with scores)                               │ │
│   │    ZADD leaderboard 100 "player1" 95 "player2"            │ │
│   │                                                             │ │
│   │  • TTL (Time To Live) - auto-expire keys                  │ │
│   │    EXPIRE session:abc123 3600                              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.3.4 Graph Databases: Neo4j Example

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NEO4J EXAMPLE                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Graph databases are built around relationships:                │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │        ┌──────────┐                                        │ │
│   │        │  John    │                                        │ │
│   │        │(Customer)│                                        │ │
│   │        └────┬─────┘                                        │ │
│   │             │                                               │ │
│   │     FRIEND_OF │                                             │ │
│   │             │                                               │ │
│   │        ┌────▼─────┐                                        │ │
│   │        │  Jane    │                                        │ │
│   │        │(Customer)│                                        │ │
│   │        └────┬─────┘                                        │ │
│   │             │                                               │ │
│   │      BOUGHT │                                               │ │
│   │             │                                               │ │
│   │        ┌────▼─────┐    BELONGS_TO   ┌──────────┐         │ │
│   │        │ MacBook  │─────────────────│ Laptops  │         │ │
│   │        │(Product) │                 │(Category)│         │ │
│   │        └──────────┘                 └──────────┘         │ │
│   │                                                             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Query: "Find products bought by friends of John"               │
│                                                                     │
│   Cypher Query:                                                  │
│   MATCH (john:Customer {name: "John"})                           │
│         -[:FRIEND_OF]-(friend:Customer)                         │
│         -[:BOUGHT]->(product:Product)                           │
│   RETURN product.name                                            │
│                                                                     │
│   Benefits:                                                      │
│   • Relationships are first-class citizens                       │
│   • Traversal is natural and fast                               │
│   • Perfect for recommendation engines                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P5.4 SQL vs. NoSQL: When to Use Which

### P5.4.1 Comparison Table

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SQL VS. NOSQL                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Feature              │ SQL              │ NoSQL                │
│   ─────────────────────┼──────────────────┼──────────────────────┤
│   Schema               │ Fixed            │ Flexible             │
│   Relationships        │ Strong (FK)      │ Weak or none        │
│   Transactions         │ ACID             │ BASE (eventual)     │
│   Scaling              │ Vertical         │ Horizontal           │
│   Query Language       │ SQL              │ Varies               │
│   Best For             │ Structured data  │ Unstructured data   │
│   Examples             │ PostgreSQL,      │ MongoDB, Redis,     │
│                        │ MySQL            │ Cassandra, Neo4j    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.4.2 Decision Framework

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CHOOSING THE RIGHT TOOL                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   USE SQL WHEN:                                                  │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ✓ Data is structured and predictable                      │ │
│   │  ✓ You need strong consistency                             │ │
│   │  ✓ You need complex joins and queries                      │ │
│   │  ✓ You need ACID transactions                              │ │
│   │  ✓ Your team is familiar with SQL                          │ │
│   │  ✓ Example: Financial systems, order management            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   USE NOSQL WHEN:                                                │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ✓ Data is unstructured or flexible                        │ │
│   │  ✓ You need massive scale (millions of users)              │ │
│   │  ✓ You need high write throughput                          │ │
│   │  ✓ You need specialized features (graph, search)           │ │
│   │  ✓ You can tolerate eventual consistency                   │ │
│   │  ✓ Example: Catalogs, user profiles, real-time analytics  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P5.5 The CAP Theorem

### P5.5.1 What Is CAP?

The **CAP Theorem** states that in a distributed system, you can only achieve two of three properties:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CAP THEOREM                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   C = CONSISTENCY                                                │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  All nodes see the same data at the same time              │ │
│   │  Every read returns the most recent write                  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   A = AVAILABILITY                                               │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Every request gets a response (even if stale)             │ │
│   │  System remains operational                                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   P = PARTITION TOLERANCE                                        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  System continues to operate despite network failures      │ │
│   │  Nodes can be separated by network partitions              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │                   ┌──────────┐                             │ │
│   │          ┌────────│CONSISTENCY│────────┐                   │ │
│   │          │        └──────────┘        │                   │ │
│   │          │                            │                   │ │
│   │          │         ┌──────────┐       │                   │ │
│   │          │         │    CP    │       │                   │ │
│   │          │         └──────────┘       │                   │ │
│   │          │              │              │                   │ │
│   │          │              │              │                   │ │
│   │    ┌─────▼─────┐        │        ┌─────▼─────┐           │ │
│   │    │    CA     │        │        │    AP     │           │ │
│   │    └─────┬─────┘        │        └─────┬─────┘           │ │
│   │          │              │              │                   │ │
│   │          └──────────┐ ┌─▼──────────────▼─┐               │ │
│   │                     │ │  AVAILABILITY   │ │               │ │
│   │                     └───────────────────┘ │               │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.5.2 CAP in Practice

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CAP IN PRACTICE                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   CA (Consistency + Availability)                                │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  • No Partition Tolerance                                  │ │
│   │  • Single-node databases                                   │ │
│   │  • Example: PostgreSQL (single node)                      │ │
│   │  • Use when: Network partitions are rare                   │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   CP (Consistency + Partition Tolerance)                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  • May sacrifice availability                              │ │
│   │  • Will reject requests if consistency can't be guaranteed │ │
│   │  • Example: MongoDB (with majority writes)                │ │
│   │  • Use when: Accuracy is critical                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   AP (Availability + Partition Tolerance)                       │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  • May sacrifice consistency                               │ │
│   │  • Returns stale data if needed                            │ │
│   │  • Example: Redis, Cassandra                              │ │
│   │  • Use when: High availability is critical                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P5.6 Distributed Systems Concepts

### P5.6.1 Replication

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REPLICATION                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Replication = Copying data across multiple nodes                │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │         ┌──────────┐                                      │ │
│   │         │ PRIMARY  │                                      │ │
│   │         │  Node    │                                      │ │
│   │         └────┬─────┘                                      │ │
│   │              │                                            │ │
│   │      ┌───────┼───────┐                                   │ │
│   │      │       │       │                                   │ │
│   │      ▼       ▼       ▼                                   │ │
│   │   ┌────┐  ┌────┐  ┌────┐                                │ │
│   │   │R1  │  │R2  │  │R3  │                                │ │
│   │   │READ │  │READ │  │READ│                               │ │
│   │   └────┘  └────┘  └────┘                                │ │
│   │                                                             │ │
│   │  Benefits:                                                 │ │
│   │  • High availability (if one node fails)                   │ │
│   │  • Read scalability (read from replicas)                  │ │
│   │  • Data locality                                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Types:                                                         │
│   • Synchronous: Write waits for all replicas                   │ │
│   • Asynchronous: Write returns after primary, sync later      │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.6.2 Sharding

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SHARDING                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Sharding = Splitting data across multiple nodes                │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │   All Customers (10 million)                               │ │
│   │        │                                                    │ │
│   │        ▼                                                    │ │
│   │   ┌───────────┐                                           │ │
│   │   │  Shard 1  │  Customers 1-1000                        │ │
│   │   │  (Node 1) │                                           │ │
│   │   ├───────────┤                                           │ │
│   │   │  Shard 2  │  Customers 1001-2000                     │ │
│   │   │  (Node 2) │                                           │ │
│   │   ├───────────┤                                           │ │
│   │   │  Shard 3  │  Customers 2001-3000                     │ │
│   │   │  (Node 3) │                                           │ │
│   │   ├───────────┤                                           │ │
│   │   │   ...     │                                            │ │
│   │   └───────────┘                                           │ │
│   │                                                             │ │
│   │  Benefits:                                                 │ │
│   │  • Horizontal scaling                                      │ │
│   │  • Each shard handles subset of data                      │ │
│   │  • Can scale by adding more shards                        │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Challenges:                                                    │ │
│   • Cross-shard queries are complex                              │ │
│   • Rebalancing when adding nodes                               │ │
│   • Hot spots (uneven data distribution)                        │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P5.7 ScaleCart's Polyglot Architecture

### P5.7.1 Why Multiple Databases?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART POLYGLOT ARCHITECTURE               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ScaleCart uses different databases for different needs:        │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  POSTGRESQL (Primary Database)                            │ │
│   │  • Product catalog                                         │ │
│   │  • Orders and order items                                  │ │
│   │  • Customers and addresses                                │ │
│   │  • Inventory tracking                                     │ │
│   │  • Payments and refunds                                   │ │
│   │  • Reviews and ratings                                    │ │
│   │                                                             │ │
│   │  Why: ACID transactions, complex queries, data integrity  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  REDIS (Cache & Session Store)                            │ │
│   │  • User sessions                                           │ │
│   │  • Shopping carts                                          │ │
│   │  • Product cache                                           │ │
│   │  • Rate limiting counters                                 │ │
│   │  • Real-time analytics                                    │ │
│   │                                                             │ │
│   │  Why: Sub-millisecond latency, TTL support                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  MONGODB (Document Store)                                │ │
│   │  • Product catalog cache                                   │ │
│   │  • Dynamic product attributes                             │ │
│   │  • Audit logs                                              │ │
│   │  • User preferences                                       │ │
│   │                                                             │ │
│   │  Why: Flexible schema, nested documents                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  NEO4J (Graph Database)                                  │ │
│   │  • Product recommendations                                │ │
│   │  • Customer social graph                                  │ │
│   │  • Fraud detection patterns                              │ │
│   │  • Permission graphs                                      │ │
│   │                                                             │ │
│   │  Why: Native relationship traversal, Cypher query        │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  TIMESCALEDB (Time-Series)                               │ │
│   │  • Website analytics                                       │ │
│   │  • Performance metrics                                    │ │
│   │  • Customer behavior tracking                            │ │
│   │  • Business intelligence                                  │ │
│   │                                                             │ │
│   │  Why: Time-based partitioning, continuous aggregates    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P5.7.2 Data Flow Example

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART DATA FLOW                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Customer browsing products:                                    │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. Check Redis cache (fast)                                │ │
│   │  2. If not found, check MongoDB (catalog cache)            │ │
│   │  3. If not found, query PostgreSQL (source of truth)       │ │
│   │  4. Cache result in MongoDB and Redis                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Customer placing order:                                        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. Start PostgreSQL transaction                          │ │
│   │  2. Check inventory (PostgreSQL)                           │ │
│   │  3. Reserve inventory (PostgreSQL, with lock)              │ │
│   │  4. Create order (PostgreSQL)                              │ │
│   │  5. Process payment (PostgreSQL)                           │ │
│   │  6. Commit transaction                                      │ │
│   │  7. Invalidate cache (Redis, MongoDB)                     │ │
│   │  8. Update graph (Neo4j - async)                           │ │
│   │  9. Log analytics (TimescaleDB - async)                   │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P5.8 Glossary of New Terms

| Term | Definition |
|------|------------|
| **NoSQL** | Non-relational databases, designed for specific workloads |
| **Document Store** | Database storing semi-structured data as documents (JSON) |
| **Key-Value Store** | Simple storage with key-value pairs |
| **Graph Database** | Database optimized for relationship traversal |
| **Time-Series Database** | Database optimized for time-stamped data |
| **CAP Theorem** | Consistency, Availability, Partition Tolerance - choose two |
| **Consistency** | All nodes see the same data |
| **Availability** | Every request gets a response |
| **Partition Tolerance** | System continues despite network failures |
| **Replication** | Copying data to multiple nodes |
| **Sharding** | Splitting data across multiple nodes |
| **Polyglot Persistence** | Using multiple database technologies |
| **BASE** | Basically Available, Soft state, Eventually consistent |

---

## P5.9 Summary

### P5.9.1 Key Takeaways

1. **NoSQL is "Not Only SQL"** – It's about using different tools for different jobs.

2. **There are many types of NoSQL databases:**
   - Document stores (MongoDB)
   - Key-value stores (Redis)
   - Graph databases (Neo4j)
   - Wide-column stores (Cassandra)
   - Search engines (Elasticsearch)
   - Time-series (TimescaleDB)

3. **SQL vs. NoSQL isn't a battle** – They each have strengths. Choose based on your needs.

4. **The CAP theorem** tells us we must make trade-offs in distributed systems.

5. **Polyglot persistence** – Using multiple database technologies together is a modern best practice.

### P5.9.2 What's Next?

You've completed all five primers! You're ready to dive into the main series.

---

## P5.10 Quick Quiz

Test your understanding:

1. **What is NoSQL?**
   - A) No SQL at all
   - B) Not Only SQL
   - C) New SQL
   - D) Network SQL

2. **Which NoSQL type stores data as JSON-like documents?**
   - A) Key-Value
   - B) Document Store
   - C) Graph
   - D) Wide-Column

3. **What is the CAP theorem?**
   - A) A theorem about databases
   - B) A theorem about networks
   - C) A theorem about consistency, availability, partition tolerance
   - D) A theorem about cloud computing

4. **Which database is best for social network relationships?**
   - A) PostgreSQL
   - B) MongoDB
   - C) Neo4j
   - D) Redis

5. **What is polyglot persistence?**
   - A) Using one database type
   - B) Using multiple database types
   - C) Using no databases
   - D) Using only SQL databases

**Answers:** 1-B, 2-B, 3-C, 4-C, 5-B

---

**[END OF PRIMER 5]**

*You have now completed all five primers! You're fully prepared to begin the main series. Congratulations!*
