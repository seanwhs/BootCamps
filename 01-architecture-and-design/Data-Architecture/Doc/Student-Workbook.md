# Mastering Modern Data Architecture: Complete Student Workbook

Welcome to the **Mastering Modern Data Architecture Student Workbook**! This comprehensive workbook is designed to complement the tutorial series with hands-on exercises, guided practice, and reflection questions. Think of this as your lab notebook - you'll work through exercises, document your findings, and build your skills step by step.

---

## How to Use This Workbook

### Structure
Each part follows a consistent format:

1. **Learning Objectives** - What you'll achieve
2. **Key Concepts Summary** - Quick review of essential ideas
3. **Hands-On Exercises** - Practical coding and implementation
4. **Check Your Understanding** - Knowledge checks
5. **Reflection Questions** - Critical thinking
6. **Challenge Problems** - Advanced application
7. **Self-Assessment Checklist** - Track your progress

### Format
- **✏️ Write**: Fill in blanks, write code, or answer questions
- **💻 Code**: Hands-on coding exercises (complete in your IDE)
- **🧪 Test**: Run verification commands
- **🤔 Reflect**: Think critically about what you've learned
- **⭐ Challenge**: Advanced problems for deeper learning

### Materials You'll Need
- Your development environment (Docker, Python, etc.)
- Access to the tutorial code repository
- A code editor (VS Code recommended)
- This workbook (print or digital)
- A notebook for notes (optional)

---

# PART 1: FOUNDATIONS OF DATA ARCHITECTURE AND DATA MODELING

## Learning Objectives
- [ ] Design entity-relationship diagrams for a business domain
- [ ] Normalize database schemas to 3NF
- [ ] Identify appropriate data models for different use cases
- [ ] Create data models using SQL DDL

---

## Key Concepts Summary

**Fill in the blanks:**

1. OLTP stands for ____________________ and is used for ____________________.

2. OLAP stands for ____________________ and is used for ____________________.

3. The three types of data are:
   - ____________________ (e.g., relational tables)
   - ____________________ (e.g., JSON)
   - ____________________ (e.g., videos)

4. In the CAP Theorem, you can only guarantee two of:
   - C: ____________________
   - A: ____________________
   - P: ____________________

5. Normalization forms:
   - 1NF: ____________________
   - 2NF: ____________________
   - 3NF: ____________________

---

## Hands-On Exercises

### Exercise 1.1: Design an ERD (✏️)

Design an entity-relationship diagram for a **library management system**. Include:

- Books (title, author, ISBN, publication_year)
- Members (name, email, membership_date)
- Loans (book_id, member_id, loan_date, return_date)
- Categories (name, description)
- Authors (name, biography)

**Draw your ERD here (or on a separate page):**

```
[Your ERD Here]
```

### Exercise 1.2: Normalize a Database (✏️)

A library has a single table with the following columns. Normalize it to 3NF.

**Current Table (Unnormalized):**
```
loan_id | book_title | book_author | member_name | member_email | loan_date | return_date
```

**Step 1: Identify the entities (write them):**

```
1. ____________________
2. ____________________
3. ____________________
4. ____________________
```

**Step 2: Write the normalized schema:**

```
CREATE TABLE books (
    ____________________
);

CREATE TABLE members (
    ____________________
);

CREATE TABLE loans (
    ____________________
);
```

### Exercise 1.3: Create the Schema (💻)

Write SQL DDL to create your normalized schema:

```sql
-- 1. Books table
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    publication_year INTEGER,
    category_id INTEGER REFERENCES categories(category_id)
);

-- 2. Complete the remaining tables:
-- Members table
CREATE TABLE members (
    ____________________
);

-- Categories table
CREATE TABLE categories (
    ____________________
);

-- Loans table
CREATE TABLE loans (
    ____________________
);
```

### Exercise 1.4: Insert Sample Data (💻)

Write INSERT statements for the following data:

```sql
-- Books
INSERT INTO books (title, author, isbn, publication_year) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', '978-0-7432-7356-5', 1925),
('To Kill a Mockingbird', 'Harper Lee', '978-0-06-112008-4', 1960);

-- Members
INSERT INTO members (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

-- Loans
INSERT INTO loans (book_id, member_id, loan_date, return_date) VALUES
(1, 1, '2024-01-15', '2024-02-15'),
(2, 2, '2024-01-20', NULL);
```

---

## Check Your Understanding

1. What is the difference between a natural key and a surrogate key?

   _______________________________________________________________________

2. Why would you denormalize a schema?

   _______________________________________________________________________

3. What is an anti-join? When would you use it?

   _______________________________________________________________________

4. What is the purpose of Master Data Management (MDM)?

   _______________________________________________________________________

---

## Reflection Questions

1. How would you model a many-to-many relationship in a relational database?

   _______________________________________________________________________

2. What trade-offs do you consider when deciding to normalize or denormalize?

   _______________________________________________________________________

3. How does the choice of data model affect application performance?

   _______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** An e-commerce platform needs to track customer orders with multiple items per order. Design a complete schema including:
- Customers (who can have multiple addresses)
- Products (with categories)
- Orders (with status, date, total)
- Order items (product, quantity, price)
- Payments (method, amount, status)
- Inventory (warehouse, stock)

**Write your complete schema here:**

```sql
-- Write your complete schema
-- (Use separate paper if needed)

```

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can explain OLTP vs. OLAP differences | ☐ |
| I can design ERD for a business domain | ☐ |
| I can normalize a database to 3NF | ☐ |
| I can create SQL DDL for a normalized schema | ☐ |
| I can identify appropriate use cases for different data models | ☐ |
| I understand the trade-offs of normalization vs. denormalization | ☐ |
| I can implement master data management concepts | ☐ |

---

# PART 2: STORAGE ENGINES AND DATABASE INTERNALS

## Learning Objectives
- [ ] Explain the difference between B-Trees and LSM Trees
- [ ] Understand how MVCC enables concurrent access
- [ ] Describe the purpose of Write-Ahead Logging
- [ ] Implement basic indexing strategies

---

## Key Concepts Summary

**Fill in the blanks:**

1. A B-Tree is balanced, meaning all leaves are at the same ____________________.

2. In a B+Tree, data is stored only in ____________________ nodes.

3. LSM Trees are optimized for ____________________ workloads because they use sequential writes.

4. MVCC stands for ____________________ and enables readers to see a consistent snapshot.

5. Write-Ahead Logging (WAL) ensures ____________________ by persisting logs before data.

6. The two main index types are ____________________ and ____________________.

---

## Hands-On Exercises

### Exercise 2.1: B-Tree Operations (✏️)

Given an empty B-Tree with order 3 (max 2 keys per node), show the tree after inserting:
```
5, 3, 8, 1, 7, 4, 9, 2, 6
```

**Step 1: Insert 5, 3, 8**
```
[5, 3, 8] (node - not split)
```

**Step 2: Insert 1**
```
[3, 5, 8] → Split → [3, 8] with left child [1] and right child [5]
```

**Continue drawing the tree at each step:**
```
After inserting 7:
____________________

After inserting 4:
____________________

After inserting 9:
____________________

After inserting 2:
____________________

After inserting 6:
____________________
```

### Exercise 2.2: Implement a Simple B-Tree (💻)

Using the provided code framework, implement `insert()` in a simple B-Tree:

```python
class BTreeNode:
    def __init__(self, is_leaf=True):
        self.keys = []
        self.children = []
        self.is_leaf = is_leaf
        self.max_keys = 3  # Order 4 (max 3 keys)

    def is_full(self):
        """Check if node has reached max capacity"""
        return len(self.keys) >= self.max_keys

    def insert_key_in_leaf(self, key):
        """Insert a key into a leaf node"""
        # TODO: Insert key in sorted order
        pass

    def split(self):
        """Split a full node into two"""
        # TODO: Split node into left and right
        pass

class BTree:
    def __init__(self):
        self.root = BTreeNode()
    
    def insert(self, key):
        """Insert a key into the B-Tree"""
        # TODO: Implement B-Tree insertion
        pass
```

**Your implementation:**

```python
# Write your implementation here

```

### Exercise 2.3: B-Tree vs. LSM Tree Comparison (✏️)

Fill in the comparison table:

| Aspect | B-Tree | LSM Tree |
|--------|--------|----------|
| Write Performance | __________ | __________ |
| Read Performance | __________ | __________ |
| Storage Efficiency | __________ | __________ |
| Use Case | __________ | __________ |
| Example Systems | __________ | __________ |

### Exercise 2.4: MVCC Simulation (✏️)

You have a row with value `100`. Three transactions occur:

```
T1: BEGIN; READ value; (value = 100)
T2: BEGIN; UPDATE value = 200; COMMIT
T3: BEGIN; READ value; (value = 200)
T1: READ value; (value = ____)
```

Assuming **READ COMMITTED** isolation, T1 reads:

```
First read: ________
Second read: ________
```

Assuming **REPEATABLE READ** isolation, T1 reads:

```
First read: ________
Second read: ________
```

Assuming **SERIALIZABLE** isolation, T1 reads:

```
First read: ________
Second read: ________
```

---

## Check Your Understanding

1. Why are B-Trees efficient for disk-based storage?

   _______________________________________________________________________

2. What is the trade-off between read and write performance in LSM Trees?

   _______________________________________________________________________

3. How does MVCC provide snapshot isolation?

   _______________________________________________________________________

4. Why is WAL important for database durability?

   _______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** You're designing a database for an IoT sensor network with 100,000 sensors sending data every second. Each sensor sends a reading (value, timestamp). Queries are:
- Latest reading for a sensor (point query)
- Average reading over 1 hour (range query)
- Anomaly detection over 24 hours (complex query)

**Which storage engine would you choose and why?**

_______________________________________________________________________

_______________________________________________________________________

**Design an indexing strategy:**

_______________________________________________________________________

_______________________________________________________________________

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can explain how B-Trees work and when to use them | ☐ |
| I can explain how LSM Trees work and when to use them | ☐ |
| I can describe the benefits of MVCC | ☐ |
| I can explain the purpose of Write-Ahead Logging | ☐ |
| I can design appropriate indexing strategies | ☐ |
| I can evaluate storage engine trade-offs | ☐ |

---

# PART 3: ENTERPRISE STORAGE ARCHITECTURE

## Learning Objectives
- [ ] Distinguish between DAS, NAS, and SAN
- [ ] Understand RAID configurations and their trade-offs
- [ ] Explain how distributed file systems work
- [ ] Design backup and disaster recovery strategies

---

## Key Concepts Summary

**Match each term with its description:**

| Term | Description |
|------|-------------|
| ___ DAS | A. Network file-level storage |
| ___ NAS | B. Directly attached to a server |
| ___ SAN | C. Block-level storage over a network |
| ___ RAID 0 | D. Provides both performance and redundancy |
| ___ RAID 1 | E. No redundancy, striping only |
| ___ RAID 5 | F. Full mirroring |
| ___ RAID 6 | G. Striping with single parity |
| ___ RAID 10 | H. Striping with double parity |

**Fill in the blanks:**

1. The default block size in HDFS is __________.

2. The 3-2-1 backup rule means:
   - 3 ____________________
   - 2 ____________________
   - 1 ____________________

3. RPO stands for ____________________ and measures ____________________.

4. RTO stands for ____________________ and measures ____________________.

---

## Hands-On Exercises

### Exercise 3.1: RAID Capacity Calculation (✏️)

You have 4 disks, each 1TB in size. Calculate the usable capacity for each RAID level:

**RAID 0:**
```
Usable Capacity = __________
```

**RAID 1:**
```
Usable Capacity = __________
```

**RAID 5:**
```
Usable Capacity = __________
```

**RAID 6:**
```
Usable Capacity = __________
```

**RAID 10:**
```
Usable Capacity = __________
```

### Exercise 3.2: RAID Performance Comparison (✏️)

4 disks, each with 100 IOPS. Calculate the effective IOPS:

**RAID 0 (Read/Write):**
```
Read: __________
Write: __________
```

**RAID 1 (Read/Write):**
```
Read: __________
Write: __________
```

**RAID 5 (Read/Write):**
```
Read: __________
Write: __________
```

**RAID 10 (Read/Write):**
```
Read: __________
Write: __________
```

### Exercise 3.3: Backup Strategy Design (✏️)

You have a database with:
- 1TB total size
- Daily change rate of 10GB
- RPO: 1 hour maximum data loss
- RTO: 4 hours maximum downtime

**Design a backup strategy:**

_______________________________________________________________________

_______________________________________________________________________

**Calculate storage requirements for 30 days of backups:**

_______________________________________________________________________

### Exercise 3.4: Distributed File System Diagram (✏️)

Draw the architecture of HDFS and label the components:

```
[Your diagram here]
```

---

## Check Your Understanding

1. What is the difference between block-level and file-level storage?

   _______________________________________________________________________

2. Why is HDFS block size typically 128MB, not 4KB?

   _______________________________________________________________________

3. What is the relationship between RAID and backup? Are they replacements?

   _______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** A media company needs to store 500TB of video files. Access patterns:
- 10% are frequently accessed (new releases)
- 40% are occasionally accessed
- 50% are rarely accessed (archives)

**Design a tiered storage strategy:**

| Tier | Storage Type | Capacity | Cost/GB | Access Latency |
|------|--------------|----------|---------|----------------|
|      |              |          |         |                |
|      |              |          |         |                |
|      |              |          |         |                |

**Explain your reasoning:**

_______________________________________________________________________

_______________________________________________________________________

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can distinguish between DAS, NAS, and SAN | ☐ |
| I can explain RAID levels and their trade-offs | ☐ |
| I can calculate RAID capacity and performance | ☐ |
| I can design a backup strategy with RPO/RTO | ☐ |
| I can explain how distributed file systems work | ☐ |
| I can design tiered storage strategies | ☐ |

---

# PART 4: CLOUD OBJECT STORAGE AND DATA LAKE FOUNDATIONS

## Learning Objectives
- [ ] Understand object storage architecture
- [ ] Design effective partitioning strategies
- [ ] Implement lifecycle management policies
- [ ] Build a data lake with proper organization

---

## Key Concepts Summary

**Fill in the blanks:**

1. In object storage, a __________ is a container for objects.

2. Each object consists of __________, __________, and __________.

3. Object storage uses a __________ namespace (flat structure).

4. Strong consistency in S3 means reads see the __________ version of an object.

5. The standard data lake layers are:
   - __________ (raw)
   - __________ (cleaned)
   - __________ (curated)
   - __________ (analytics)
   - __________ (archive)

---

## Hands-On Exercises

### Exercise 4.1: Prefix Optimization (✏️)

A company stores IoT data in S3 with the following structure:
```
s3://iot-data/
  /device_001/
    /data_2024-01-01_0001.json
    /data_2024-01-01_0002.json
    /data_2024-01-02_0001.json
  /device_002/
    /data_2024-01-01_0001.json
    ...
```

**Problem:** Queries for time ranges scan all devices unnecessarily.

**Redesign the prefix structure for optimal query performance:**

```
s3://iot-data/
  /____________________
    /____________________
      /____________________
```

**Explain why this is better:**

_______________________________________________________________________

### Exercise 4.2: Lifecycle Policy Design (✏️)

You need to create lifecycle policies for the following data:

| Data Type | Retention | Access Pattern |
|-----------|-----------|----------------|
| Raw logs | 30 days | Never accessed |
| Processed data | 90 days | Occasional queries |
| Aggregated data | 1 year | Frequent queries |
| Compliance data | 7 years | Rarely accessed |

**Design lifecycle policies:**

```
Raw logs (30 days):
- Days 0-30: __________
- After 30 days: __________

Processed data (90 days):
- Days 0-90: __________
- After 90 days: __________

Aggregated data (1 year):
- Days 0-365: __________
- After 365: __________

Compliance data (7 years):
- Days 0-2555: __________
- After 2555: __________
```

### Exercise 4.3: Data Lake Structure (✏️)

Design a data lake folder structure for a retail company with the following data sources:
- CRM (customers)
- Order Management (orders, order_items)
- Inventory (products, stock)
- Marketing (campaigns, clicks)
- Finance (invoices, payments)

```
s3://retail-data-lake/
├── bronze/
│   ├── crm/
│   ├── orders/
│   ├── inventory/
│   ├── marketing/
│   └── finance/
├── silver/
│   ├── customers/
│   ├── orders/
│   ├── products/
│   ├── campaigns/
│   └── invoices/
└── gold/
    ├── sales_summary/
    ├── customer_360/
    ├── inventory_status/
    └── marketing_performance/
```

**Add partition details for each layer:**

```
bronze/crm/
  └── year=YYYY/
      └── month=MM/
          └── day=DD/
              └── events.json

silver/orders/
  └── ____________________

gold/sales_summary/
  └── ____________________
```

---

## Check Your Understanding

1. What is the advantage of a flat namespace in object storage?

   _______________________________________________________________________

2. How does versioning protect against accidental deletions?

   _______________________________________________________________________

3. What is the difference between lifecycle transition and expiration?

   _______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** You are designing a data lake for a healthcare company. Requirements:
- 10+ years of data retention for compliance
- 90 days of frequent access
- 1 year of moderate access
- Must support GDPR deletion requests
- Must be encrypted at rest

**Design your data lake architecture:**

_______________________________________________________________________

_______________________________________________________________________

**Write lifecycle rules:**

_______________________________________________________________________

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can explain object storage architecture | ☐ |
| I can design effective prefix structures | ☐ |
| I can implement lifecycle management policies | ☐ |
| I can build a data lake with proper layers | ☐ |
| I understand versioning and data protection | ☐ |
| I can optimize for partition pruning | ☐ |

---

# PART 5: MODERN DATA FORMATS AND STORAGE OPTIMIZATION

## Learning Objectives
- [ ] Compare row-based and columnar storage
- [ ] Work with Parquet, ORC, and Avro formats
- [ ] Implement compression strategies
- [ ] Understand predicate pushdown and data skipping

---

## Key Concepts Summary

**Fill in the blanks:**

1. Row-based storage stores __________ together.

2. Columnar storage stores __________ together.

3. Parquet is a __________ storage format optimized for __________.

4. Predicate pushdown reduces I/O by __________.

5. The "small file problem" refers to __________.

6. Bloom filters provide fast __________ with possible __________.

---

## Hands-On Exercises

### Exercise 5.1: Storage Format Comparison (✏️)

Compare the storage formats:

| Format | Type | Compression | Schema Evolution | Use Case |
|--------|------|-------------|------------------|----------|
| Parquet | _____ | _____ | _____ | _____ |
| ORC | _____ | _____ | _____ | _____ |
| Avro | _____ | _____ | _____ | _____ |
| CSV | _____ | _____ | _____ | _____ |

### Exercise 5.2: Predicate Pushdown Example (✏️)

Consider a Parquet file with 10 row groups, each with 10,000 rows. The `age` column statistics:
```
Row Group 1: min=18, max=25
Row Group 2: min=22, max=30
Row Group 3: min=35, max=50
Row Group 4: min=28, max=33
Row Group 5: min=45, max=65
...

Query: SELECT * FROM table WHERE age > 30
```

**Which row groups will be read?**

____________________

**How many rows will be scanned?**

____________________

### Exercise 5.3: Compression Trade-Offs (✏️)

A 1TB dataset needs to be stored. Compression options:

| Algorithm | Ratio | Speed |
|-----------|-------|-------|
| Snappy | 2x | Fast |
| Gzip | 4x | Slow |
| Zstd | 3.5x | Medium |

**If storage costs $0.05/GB/month and compute costs $0.10/GB processed:**

| Option | Storage Cost/month | Processing Cost | Total |
|--------|-------------------|-----------------|-------|
| Uncompressed | _____ | _____ | _____ |
| Snappy | _____ | _____ | _____ |
| Gzip | _____ | _____ | _____ |
| Zstd | _____ | _____ | _____ |

**Which is most cost-effective for frequently queried data?**

_______________________________________________________________________

### Exercise 5.4: Avro Schema Evolution (✏️)

You have an Avro schema for customer data:

**Version 1:**
```json
{
  "type": "record",
  "name": "Customer",
  "fields": [
    {"name": "id", "type": "int"},
    {"name": "name", "type": "string"},
    {"name": "email", "type": "string"}
  ]
}
```

**Add a new field "phone" with a default value "":**

```json
{
  "type": "record",
  "name": "Customer",
  "fields": [
    {"name": "id", "type": "int"},
    {"name": "name", "type": "string"},
    {"name": "email", "type": "string"},
    ____________________
  ]
}
```

**Why is default value important for backward compatibility?**

_______________________________________________________________________

---

## Check Your Understanding

1. Why is columnar storage faster for analytical queries?

   _______________________________________________________________________

2. What is the trade-off of using a higher compression ratio?

   _______________________________________________________________________

3. How does predicate pushdown improve query performance?

   _______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** You have a data lake with 1 million Parquet files (average size 1MB). Queries are slow due to the small file problem. You need to compact these files into optimal sizes.

**Calculate:**
- Total data size: ________
- Optimal file size (128MB): ________
- Number of files after compaction: ________

**Write a compaction strategy:**

_______________________________________________________________________

_______________________________________________________________________

**What are the trade-offs of compaction?**

_______________________________________________________________________

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can compare row-based and columnar storage | ☐ |
| I can work with Parquet, ORC, and Avro | ☐ |
| I can implement compression strategies | ☐ |
| I understand predicate pushdown | ☐ |
| I can identify the small file problem | ☐ |
| I can use Bloom filters for optimization | ☐ |

---

# PART 6: TRANSACTION PROCESSING AND DISTRIBUTED CONSISTENCY

## Learning Objectives
- [ ] Understand ACID properties and isolation levels
- [ ] Explain distributed transaction protocols
- [ ] Implement the Saga pattern
- [ ] Understand consistency models

---

## Key Concepts Summary

**Fill in the blanks:**

1. ACID stands for:
   - A: ____________________
   - C: ____________________
   - I: ____________________
   - D: ____________________

2. The four isolation levels are:
   - ____________________ (dirty reads possible)
   - ____________________ (no dirty reads)
   - ____________________ (no non-repeatable reads)
   - ____________________ (full isolation)

3. BASE stands for:
   - B: ____________________
   - A: ____________________
   - S: ____________________
   - E: ____________________

---

## Hands-On Exercises

### Exercise 6.1: Isolation Level Anomalies (✏️)

For each isolation level, mark which anomalies are possible:

| Isolation Level | Dirty Reads | Non-Repeatable Reads | Phantom Reads |
|-----------------|-------------|---------------------|---------------|
| Read Uncommitted | _____ | _____ | _____ |
| Read Committed | _____ | _____ | _____ |
| Repeatable Read | _____ | _____ | _____ |
| Serializable | _____ | _____ | _____ |

### Exercise 6.2: Distributed Transaction Sequence (✏️)

Order the steps in a Two-Phase Commit (2PC) transaction:

```
___ Coordinator sends "COMMIT" to all participants
___ Coordinator receives "YES" from all participants
___ Coordinator sends "PREPARE" to all participants
___ Participants apply changes and send "DONE"
___ Coordinator decides to commit
___ Participants write to WAL and respond "YES"
___ Participants commit and acknowledge
```

**What happens if a participant responds "NO"?**

_______________________________________________________________________

### Exercise 6.3: Saga Pattern Design (✏️)

Design a Saga for an e-commerce order fulfillment process:

**Steps:**
1. Reserve Inventory
2. Process Payment
3. Create Order
4. Send Confirmation
5. Update Inventory

**Write the forward actions and compensating actions:**

| Step | Action | Compensating Action |
|------|--------|---------------------|
| 1 | Reserve Inventory | ____________________ |
| 2 | Process Payment | ____________________ |
| 3 | Create Order | ____________________ |
| 4 | Send Confirmation | ____________________ |
| 5 | Update Inventory | ____________________ |

**What happens if Step 3 fails?**

_______________________________________________________________________

### Exercise 6.4: Consistency Model Scenarios (✏️)

For each scenario, identify the appropriate consistency model:

**Scenario 1:** Banking transfer between accounts
- Model: ____________________
- Reason: ____________________

**Scenario 2:** Social media feed (likes, comments)
- Model: ____________________
- Reason: ____________________

**Scenario 3:** E-commerce inventory display
- Model: ____________________
- Reason: ____________________

**Scenario 4:** Shopping cart for a single user
- Model: ____________________
- Reason: ____________________

---

## Challenge Problem (⭐)

**Scenario:** A travel booking system needs to coordinate hotel, flight, and car rental bookings across three different services. The system must be highly available and cannot use 2PC due to performance concerns.

**Design a Saga-based solution:**

_______________________________________________________________________

_______________________________________________________________________

**List all steps and compensating actions:**

_______________________________________________________________________

_______________________________________________________________________

**Discuss trade-offs compared to 2PC:**

_______________________________________________________________________

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can explain ACID properties | ☐ |
| I understand isolation levels | ☐ |
| I can explain 2PC and 3PC | ☐ |
| I can design Saga patterns | ☐ |
| I understand consistency models | ☐ |
| I can evaluate consistency trade-offs | ☐ |

---

# PART 7: DATA INTEGRATION AND MODERN DATA PIPELINES

## Learning Objectives
- [ ] Distinguish between ETL, ELT, and Reverse ETL
- [ ] Implement Change Data Capture (CDC)
- [ ] Work with Kafka for event streaming
- [ ] Design pipeline orchestration with DAGs

---

## Key Concepts Summary

**Fill in the blanks:**

1. ETL stands for ____________________, ____________________, ____________________.

2. ELT stands for ____________________, ____________________, ____________________.

3. Reverse ETL pushes data from __________ back to __________.

4. CDC captures __________ changes from a database.

5. In Kafka, a __________ is a stream of messages, divided into __________ for parallelism.

6. A DAG in Airflow is a ____________________.

---

## Hands-On Exercises

### Exercise 7.1: ETL vs. ELT Comparison (✏️)

| Aspect | ETL | ELT |
|--------|-----|-----|
| Transformation Timing | _____ | _____ |
| Storage Requirements | _____ | _____ |
| Performance | _____ | _____ |
| Flexibility | _____ | _____ |
| Use Case | _____ | _____ |

### Exercise 7.2: CDC Event Design (✏️)

Design CDC events for the following changes:

**INSERT into customers:**
```
{
  "op": "insert",
  "table": "customers",
  "data": {
    "id": 101,
    "name": "Alice Johnson",
    "email": "alice@example.com"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  ____________________
}
```

**UPDATE on orders (status changed):**
```
{
  "op": "update",
  "table": "orders",
  "before": ____________________,
  "after": ____________________,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**DELETE from products:**
```
{
  "op": "delete",
  "table": "products",
  "data": ____________________,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Exercise 7.3: Kafka Topic Design (✏️)

Design Kafka topics for an e-commerce platform:

| Topic | Purpose | Partitions | Producers | Consumers |
|-------|---------|------------|-----------|-----------|
| orders | _____ | _____ | _____ | _____ |
| payments | _____ | _____ | _____ | _____ |
| inventory | _____ | _____ | _____ | _____ |
| customer-events | _____ | _____ | _____ | _____ |

### Exercise 7.4: Airflow DAG Design (✏️)

Design an Airflow DAG for a data pipeline:

```
Requirements:
- Extract from source (daily)
- Validate data (quality checks)
- Transform data (clean and enrich)
- Load to data warehouse
- Notify success/failure via email

Tasks:
1. extract_data
2. validate_data (depends on: ________)
3. transform_data (depends on: ________)
4. load_to_warehouse (depends on: ________)
5. notify (depends on: ________)

DAG Diagram:
[Your DAG diagram here]
```

---

## Check Your Understanding

1. Why is ELT becoming more popular than ETL?

   _______________________________________________________________________

2. What are the advantages of CDC over full reloads?

   _______________________________________________________________________

3. Why is Kafka a good choice for event streaming?

   _______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** An e-commerce company needs to process orders from 10 different systems (web, mobile, API partners). Orders must be:
- Validated for fraud
- Processed in real-time
- Loaded into the data warehouse within 5 minutes
- Made available for customer notifications

**Design the complete integration pipeline:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Data ingestion approach
- Processing steps
- Technologies used
- Failure handling

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can distinguish between ETL, ELT, and Reverse ETL | ☐ |
| I can implement CDC patterns | ☐ |
| I can design Kafka topics and producers/consumers | ☐ |
| I can design Airflow DAGs | ☐ |
| I understand streaming vs. batch processing | ☐ |
| I can handle pipeline failures | ☐ |

---

# PART 8: SCALABILITY, DISTRIBUTION, AND HIGH AVAILABILITY

## Learning Objectives
- [ ] Compare vertical and horizontal scaling
- [ ] Implement data partitioning strategies
- [ ] Understand replication models
- [ ] Design for high availability and disaster recovery

---

## Key Concepts Summary

**Fill in the blanks:**

1. __________ scaling adds more resources to existing machines.

2. __________ scaling adds more machines to the system.

3. __________ is a partitioning strategy that minimizes data movement when nodes change.

4. In leader-follower replication, __________ handle writes, __________ handle reads.

5. RPO measures __________, RTO measures __________.

---

## Hands-On Exercises

### Exercise 8.1: Scaling Calculations (✏️)

A system handles 10,000 requests/second with 2 servers (each handles 5,000 req/s). If load grows to 50,000 req/s:

**Vertical scaling option:**
- Need to scale each server to handle __________ req/s
- Total capacity needed: __________

**Horizontal scaling option:**
- Number of servers needed: __________
- Additional servers needed: __________

**Pros and cons:**

| Approach | Pros | Cons |
|----------|------|------|
| Vertical | _____ | _____ |
| Horizontal | _____ | _____ |

### Exercise 8.2: Partitioning Strategy Design (✏️)

Design a partitioning strategy for each scenario:

**Scenario 1: Customer data, queries by customer_id:**
- Strategy: ____________________
- Why: ____________________

**Scenario 2: Time-series logs, queries by date range:**
- Strategy: ____________________
- Why: ____________________

**Scenario 3: Multi-tenant data, queries by tenant_id:**
- Strategy: ____________________
- Why: ____________________

**Scenario 4: Global user data, queries by region:**
- Strategy: ____________________
- Why: ____________________

### Exercise 8.3: Consistent Hashing (✏️)

Draw a consistent hash ring with 3 nodes (A, B, C) and 5 keys (1-5):

```
[Your diagram here]
```

**Add node D. Which keys move?**

____________________

**Remove node B. Which keys move?**

____________________

### Exercise 8.4: Replication Model Comparison (✏️)

| Model | Write Availability | Read Scalability | Consistency | Complexity | Use Case |
|-------|-------------------|------------------|-------------|------------|----------|
| Leader-Follower | _____ | _____ | _____ | _____ | _____ |
| Multi-Leader | _____ | _____ | _____ | _____ | _____ |
| Leaderless | _____ | _____ | _____ | _____ | _____ |

---

## Check Your Understanding

1. What are the limitations of vertical scaling?

   _______________________________________________________________________

2. How does consistent hashing improve scalability?

   _______________________________________________________________________

3. What is the trade-off between consistency and availability?

   _______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** A global streaming service needs to handle 1M concurrent users with 99.99% availability. They need disaster recovery with RPO of 5 minutes and RTO of 15 minutes.

**Design your architecture:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Scaling strategy
- Data partitioning
- Replication model
- Disaster recovery plan

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can compare vertical and horizontal scaling | ☐ |
| I can design partitioning strategies | ☐ |
| I understand consistent hashing | ☐ |
| I can evaluate replication models | ☐ |
| I can design for high availability | ☐ |
| I can create disaster recovery plans | ☐ |

---

# PART 9: CACHING AND PERFORMANCE ENGINEERING

## Learning Objectives
- [ ] Understand caching patterns and strategies
- [ ] Implement Redis for session management
- [ ] Use materialized views for query optimization
- [ ] Measure and improve cache hit ratios

---

## Key Concepts Summary

**Fill in the blanks:**

1. The four caching patterns are:
   - ____________________ (application manages cache)
   - ____________________ (cache handles misses)
   - ____________________ (synchronous writes)
   - ____________________ (asynchronous writes)

2. Cache eviction policies:
   - LRU: ____________________
   - LFU: ____________________
   - FIFO: ____________________
   - TTL: ____________________

3. TTL stands for ____________________.

4. A materialized view is a ____________________.

---

## Hands-On Exercises

### Exercise 9.1: Cache Pattern Selection (✏️)

For each scenario, choose the appropriate caching pattern:

**Scenario 1: Product catalog (frequent reads, occasional updates)**
- Pattern: ____________________
- Why: ____________________

**Scenario 2: Real-time stock prices (needs consistency)**
- Pattern: ____________________
- Why: ____________________

**Scenario 3: Analytics tracking (high write volume)**
- Pattern: ____________________
- Why: ____________________

**Scenario 4: User sessions (moderate read/write)**
- Pattern: ____________________
- Why: ____________________

### Exercise 9.2: Cache Hit Ratio Calculation (✏️)

A cache receives 10,000 requests:
- 8,000 requests are hits
- 2,000 requests are misses

**Calculate:**
- Hit ratio: __________
- Miss ratio: __________

If cache latency is 1ms and database latency is 100ms:

**Average response time:**
- Without cache: __________
- With cache: __________

**Improvement factor:** __________

### Exercise 9.3: Redis Data Structures (✏️)

For each use case, select the appropriate Redis data structure:

| Use Case | Data Structure |
|----------|----------------|
| User sessions | _____ |
| Leaderboard (sorted scores) | _____ |
| Shopping cart (multiple items) | _____ |
| Unique visitor tracking | _____ |
| Message queue | _____ |
| User profile (key-value) | _____ |

### Exercise 9.4: Materialized View Design (✏️)

Design materialized views for the following query patterns:

**Query 1: Daily sales by region**
```sql
SELECT 
    region,
    DATE(order_date) as day,
    SUM(amount) as daily_sales
FROM orders
GROUP BY region, DATE(order_date)
```

**Materialized View:**

_______________________________________________________________________

**Refresh strategy:** ____________________

**Query 2: Top 10 products by revenue (last 30 days)**
```sql
SELECT 
    product_id,
    SUM(quantity * price) as revenue
FROM order_items
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10
```

**Materialized View:**

_______________________________________________________________________

**Refresh strategy:** ____________________

---

## Challenge Problem (⭐)

**Scenario:** A social media feed needs to load in under 200ms for 10M daily active users. The feed query reads posts from the last 7 days, including likes, comments, and user data.

**Design a caching strategy:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- What to cache
- Cache pattern to use
- Eviction policy
- TTL values
- Cache invalidation strategy

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can select appropriate caching patterns | ☐ |
| I can calculate cache hit ratios | ☐ |
| I can use Redis for session management | ☐ |
| I can design materialized views | ☐ |
| I can implement cache invalidation | ☐ |
| I can optimize cache performance | ☐ |

---

# PART 10: DATA LAKES, LAKEHOUSES, AND MODERN ANALYTICS PLATFORMS

## Learning Objectives
- [ ] Compare data warehouse, data lake, and lakehouse
- [ ] Implement Medallion Architecture layers
- [ ] Use Delta Lake features (ACID, time travel)
- [ ] Build analytics platforms

---

## Key Concepts Summary

**Fill in the blanks:**

1. A data lake uses __________ (schema-on-read/write).

2. A data warehouse uses __________ (schema-on-read/write).

3. A lakehouse combines __________ flexibility with __________ performance.

4. The Medallion Architecture layers:
   - __________ (raw)
   - __________ (cleaned)
   - __________ (curated)

5. Delta Lake provides __________ transactions on data lakes.

---

## Hands-On Exercises

### Exercise 10.1: Architecture Selection (✏️)

For each scenario, select the appropriate architecture:

**Scenario 1: Financial reporting (requires ACID, high performance)**
- Architecture: ____________________
- Why: ____________________

**Scenario 2: ML data exploration (variety of data types)**
- Architecture: ____________________
- Why: ____________________

**Scenario 3: Both analytics and ML on the same data**
- Architecture: ____________________
- Why: ____________________

### Exercise 10.2: Medallion Architecture Design (✏️)

Design a Medallion Architecture for a retail company:

| Layer | Data Sources | Transformations | Format | Retention |
|-------|--------------|-----------------|--------|-----------|
| Bronze | _____ | _____ | _____ | _____ |
| Silver | _____ | _____ | _____ | _____ |
| Gold | _____ | _____ | _____ | _____ |

### Exercise 10.3: Delta Lake Time Travel (✏️)

You have a Delta table with the following versions:

```
Version 0: Initial load (1000 records)
Version 1: Added 500 records
Version 2: Updated 200 records
Version 3: Deleted 50 records
Version 4: Added 300 records
```

**How many records in each version?**

| Version | Record Count |
|---------|--------------|
| 0 | _____ |
| 1 | _____ |
| 2 | _____ |
| 3 | _____ |
| 4 | _____ |

**How to query version 2?**
```sql
SELECT * FROM table ____________________
```

**How to rollback to version 2?**
```sql
____________________
```

### Exercise 10.4: Open Table Format Comparison (✏️)

| Feature | Delta Lake | Iceberg | Hudi |
|---------|------------|---------|------|
| ACID Transactions | _____ | _____ | _____ |
| Time Travel | _____ | _____ | _____ |
| Partition Evolution | _____ | _____ | _____ |
| Schema Evolution | _____ | _____ | _____ |
| Primary Key Support | _____ | _____ | _____ |
| Best Use Case | _____ | _____ | _____ |

---

## Challenge Problem (⭐)

**Scenario:** A company wants to replace their traditional data warehouse with a lakehouse. They have 5TB of data, 100 daily ETL jobs, and 50 SQL users.

**Design the migration plan:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Data migration strategy
- Schema conversion
- Performance optimization
- User training
- Rollback plan

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can compare data lake, warehouse, and lakehouse | ☐ |
| I can design Medallion Architecture | ☐ |
| I can use Delta Lake features | ☐ |
| I understand open table formats | ☐ |
| I can implement time travel | ☐ |
| I can build analytics platforms | ☐ |

---

# PART 11: ENTERPRISE DATA HUBS AND DATA MESH

## Learning Objectives
- [ ] Design enterprise data hubs
- [ ] Implement data contracts
- [ ] Understand Data Mesh principles
- [ ] Build event-driven integrations

---

## Key Concepts Summary

**Fill in the blanks:**

1. A data contract specifies __________, __________, and __________.

2. Data Mesh has four principles:
   - ____________________
   - ____________________
   - ____________________
   - ____________________

3. Data products should have clear __________, __________, and __________.

---

## Hands-On Exercises

### Exercise 11.1: Data Hub Design (✏️)

Design an enterprise data hub for a company with:
- 5 business domains
- 3 data warehouses
- 2 data lakes
- Multiple SaaS applications

**Components:**

| Component | Purpose | Technology |
|-----------|---------|------------|
| Asset Catalog | _____ | _____ |
| Data Contracts | _____ | _____ |
| Governance | _____ | _____ |
| Security | _____ | _____ |

**Data flow diagram:**

```
[Your diagram here]
```

### Exercise 11.2: Data Contract Design (✏️)

Write a data contract for a "Customer 360" data product:

```yaml
Data Contract: Customer 360
Version: 1.0.0

Owner: ____________________
Description: ____________________

Schema:
  - customer_id: string (required)
  - name: string (required)
  - email: string (required)
  - phone: string (optional)
  - segment: string (enum: ['Enterprise', 'SMB', 'Consumer'])
  - preferences: map<string, string>

SLAs:
  - Availability: ____________________
  - Latency: ____________________
  - Freshness: ____________________

Access:
  - Method: ____________________
  - Authentication: ____________________
  - Rate Limits: ____________________

Security:
  - Classification: ____________________
  - Encryption: ____________________
  - Retention: ____________________
```

### Exercise 11.3: Domain Ownership (✏️)

For each domain, list their data products:

| Domain | Data Products |
|--------|---------------|
| Sales | _____ |
| Marketing | _____ |
| Engineering | _____ |
| Finance | _____ |
| HR | _____ |

**Who owns the customer master data?**

_______________________________________________________________________

**What about cross-domain data?**

_______________________________________________________________________

### Exercise 11.4: Event-Driven Integration (✏️)

Design event-driven integration for order processing:

**Events produced:**

| Event | Source | Content | Consumers |
|-------|--------|---------|-----------|
| Order Created | _____ | _____ | _____ |
| Payment Processed | _____ | _____ | _____ |
| Inventory Updated | _____ | _____ | _____ |
| Order Shipped | _____ | _____ | _____ |

**Event flow diagram:**

```
[Your diagram here]
```

---

## Challenge Problem (⭐)

**Scenario:** A large enterprise wants to implement Data Mesh across 20+ domains. They have existing data infrastructure (data lakes, warehouses, ETL tools) and are struggling with data quality and discoverability.

**Design the Data Mesh implementation plan:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Domain identification
- Data product strategy
- Governance model
- Technology choices
- Migration approach

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can design enterprise data hubs | ☐ |
| I can create data contracts | ☐ |
| I understand Data Mesh principles | ☐ |
| I can define data products | ☐ |
| I can implement event-driven integration | ☐ |
| I understand federated governance | ☐ |

---

# PART 12: METADATA MANAGEMENT AND DATA GOVERNANCE

## Learning Objectives
- [ ] Understand metadata types and management
- [ ] Implement data lineage tracking
- [ ] Build data quality frameworks
- [ ] Ensure regulatory compliance

---

## Key Concepts Summary

**Fill in the blanks:**

1. Technical metadata includes __________, __________, and __________.

2. Business metadata includes __________, __________, and __________.

3. Operational metadata includes __________, __________, and __________.

4. Data lineage tracks __________ of data.

5. Data quality dimensions include __________, __________, __________, __________.

---

## Hands-On Exercises

### Exercise 12.1: Metadata Classification (✏️)

Classify the following metadata:

| Metadata | Type |
|----------|------|
| File format (Parquet) | _____ |
| Data owner (Sales Team) | _____ |
| Last access time | _____ |
| Data quality score | _____ |
| Schema definition | _____ |
| Data steward (Alice) | _____ |
| Query count | _____ |
| Description ("Customer 360") | _____ |

### Exercise 12.2: Data Lineage Diagram (✏️)

Draw lineage for a customer report:

```
Sources:
- CRM (customers)
- OMS (orders)
- ERP (inventory)

Transformation:
- Step 1: Join customers and orders
- Step 2: Aggregate by customer
- Step 3: Add inventory status
- Step 4: Calculate lifetime value

Output:
- Customer 360 report (dashboard)

[Your lineage diagram here]
```

**Identify upstream dependencies:**

____________________

**Identify downstream dependencies:**

____________________

### Exercise 12.3: Data Quality Rules (✏️)

Write data quality rules for the following scenarios:

**Rule 1: Email format validation**
```sql
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```
Severity: ____________________
Threshold: ____________________

**Rule 2: Customer segment consistency**
```
Allowed values: ['Enterprise', 'SMB', 'Consumer', 'Trial']
```
Severity: ____________________
Threshold: ____________________

**Rule 3: Order amount must be positive**
```
CHECK (amount > 0)
```
Severity: ____________________
Threshold: ____________________

### Exercise 12.4: Compliance Requirements (✏️)

Map regulatory requirements to technical controls:

| Regulation | Requirement | Technical Control |
|------------|-------------|-------------------|
| GDPR | Right to access | _____ |
| GDPR | Right to delete | _____ |
| GDPR | Data portability | _____ |
| GDPR | Breach notification | _____ |
| GDPR | Consent management | _____ |
| CCPA | Right to opt-out | _____ |
| HIPAA | PHI protection | _____ |
| SOX | Audit trail | _____ |

---

## Challenge Problem (⭐)

**Scenario:** A healthcare company needs to comply with HIPAA, GDPR, and CCPA simultaneously. They have data across multiple systems and need to implement comprehensive governance.

**Design the governance framework:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Data classification scheme
- Access controls
- Data quality monitoring
- Compliance automation
- Audit capabilities

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can classify metadata types | ☐ |
| I can implement data lineage | ☐ |
| I can build data quality frameworks | ☐ |
| I understand regulatory compliance | ☐ |
| I can design governance policies | ☐ |
| I can implement data catalogs | ☐ |

---

# PART 13: BUSINESS INTELLIGENCE AND ANALYTICAL ARCHITECTURE

## Learning Objectives
- [ ] Design dimensional models (star/snowflake)
- [ ] Build fact and dimension tables
- [ ] Create BI dashboards
- [ ] Implement semantic layers

---

## Key Concepts Summary

**Fill in the blanks:**

1. Fact tables contain __________ data, dimension tables contain __________ data.

2. A star schema uses __________ (normalized/denormalized) dimensions.

3. A snowflake schema uses __________ (normalized/denormalized) dimensions.

4. A semantic layer translates __________ to __________.

5. KPIs are ____________________.

---

## Hands-On Exercises

### Exercise 13.1: Dimensional Model Design (✏️)

Design a star schema for sales analytics:

**Fact Table: Sales Fact**
- Measures: ____________________
- Dimension Keys: ____________________

**Dimension Tables:**

| Dimension | Attributes |
|-----------|------------|
| Time | _____ |
| Product | _____ |
| Customer | _____ |
| Store | _____ |

**Write CREATE TABLE statements:**

```sql
-- Fact table
CREATE TABLE sales_fact (
    ____________________
);

-- Dimension tables
CREATE TABLE time_dim (
    ____________________
);

CREATE TABLE product_dim (
    ____________________
);

CREATE TABLE customer_dim (
    ____________________
);
```

### Exercise 13.2: Query Design (✏️)

Write queries for the following business questions:

**Question 1: Total sales by product category for Q1 2024**
```sql
SELECT 
    ____________________
FROM sales_fact f
JOIN product_dim p ON f.product_key = p.product_key
JOIN time_dim t ON f.time_key = t.time_key
WHERE ____________________
GROUP BY ____________________
ORDER BY ____________________
```

**Question 2: Top 10 customers by revenue (last 30 days)**
```sql
SELECT 
    ____________________
FROM sales_fact f
JOIN customer_dim c ON f.customer_key = c.customer_key
WHERE ____________________
GROUP BY ____________________
ORDER BY ____________________
LIMIT ____________________
```

### Exercise 13.3: Dashboard Design (✏️)

Design a BI dashboard for a retail executive:

**KPIs:**
1. ____________________
2. ____________________
3. ____________________

**Charts:**
1. ____________________ (purpose: _____)
2. ____________________ (purpose: _____)
3. ____________________ (purpose: _____)

**Filters:**
1. ____________________
2. ____________________
3. ____________________

**Sketch the dashboard layout:**

```
┌─────────────────────────────────────────────────────────────┐
│  [Your dashboard sketch here]                              │
│                                                             │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Exercise 13.4: Semantic Layer Definition (✏️)

Define semantic layer metrics:

| Business Term | Technical Definition |
|---------------|---------------------|
| Revenue | _____ |
| Average Order Value | _____ |
| Customer Lifetime Value | _____ |
| Churn Rate | _____ |
| Conversion Rate | _____ |

**Why is the semantic layer important?**

_______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** A retail company wants a single source of truth for their sales analytics. They need to support both executive dashboards and detailed analysis by analysts. Data is in a data warehouse with complex schemas.

**Design the BI architecture:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Dimensional model
- Semantic layer
- Dashboard design
- Self-service capabilities

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can design star and snowflake schemas | ☐ |
| I can create fact and dimension tables | ☐ |
| I can write analytical queries | ☐ |
| I can design BI dashboards | ☐ |
| I can implement semantic layers | ☐ |
| I understand KPIs and metrics | ☐ |

---

# PART 14: MACHINE LEARNING DATA ARCHITECTURE

## Learning Objectives
- [ ] Design feature stores
- [ ] Work with vector databases
- [ ] Implement RAG systems
- [ ] Build ML data pipelines

---

## Key Concepts Summary

**Fill in the blanks:**

1. A feature store has two components:
   - __________ (training)
   - __________ (inference)

2. Vector embeddings are __________ representations of data.

3. RAG stands for ____________________.

4. A vector database uses __________ to find similar items.

---

## Hands-On Exercises

### Exercise 14.1: Feature Store Design (✏️)

Design a feature store for a recommendation system:

**Features:**

| Feature | Description | Type | Source |
|---------|-------------|------|--------|
| user_avg_rating | _____ | _____ | _____ |
| user_review_count | _____ | _____ | _____ |
| product_category | _____ | _____ | _____ |
| product_price | _____ | _____ | _____ |
| user_browsing_history | _____ | _____ | _____ |

**Feature Groups:**

| Group | Features |
|-------|----------|
| User Features | _____ |
| Product Features | _____ |
| Behavior Features | _____ |

### Exercise 14.2: Vector Embedding Use Cases (✏️)

For each use case, explain why embeddings are appropriate:

**Use Case 1: Semantic search**
- Why embeddings? ____________________

**Use Case 2: Recommendation systems**
- Why embeddings? ____________________

**Use Case 3: Anomaly detection**
- Why embeddings? ____________________

**Use Case 4: Document clustering**
- Why embeddings? ____________________

### Exercise 14.3: RAG System Design (✏️)

Design a RAG system for a customer support knowledge base:

**Components:**

| Component | Purpose | Technology |
|-----------|---------|------------|
| Knowledge Base | _____ | _____ |
| Embedding Model | _____ | _____ |
| Vector Database | _____ | _____ |
| LLM | _____ | _____ |

**Flow diagram:**

```
User Query → ________ → ________ → ________ → Response
              (Step 2)   (Step 3)   (Step 4)
```

**Step 1: User Query**  
**Step 2:** ____________________  
**Step 3:** ____________________  
**Step 4:** ____________________  

**What embeddings would you use?**

_______________________________________________________________________

### Exercise 14.4: ML Pipeline Design (✏️)

Design an ML pipeline for a customer churn prediction model:

**Data Sources:**
1. CRM data (customer profiles)
2. Transaction data (purchase history)
3. Support data (tickets, interactions)
4. Usage data (product engagement)

**Pipeline Steps:**

| Step | Description | Technology |
|------|-------------|------------|
| Extract | _____ | _____ |
| Transform | _____ | _____ |
| Feature Engineering | _____ | _____ |
| Train | _____ | _____ |
| Deploy | _____ | _____ |

**Feature Store:**
- Online features: ____________________
- Offline features: ____________________

**Model Serving:**
- Method: ____________________
- Frequency: ____________________

---

## Challenge Problem (⭐)

**Scenario:** An e-commerce company wants to build a personalized product recommendation system that uses both user behavior and product embeddings.

**Design the complete ML data architecture:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Feature store design
- Embedding generation
- Vector database
- Recommendation algorithm
- Serving architecture

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can design feature stores | ☐ |
| I can work with vector embeddings | ☐ |
| I can implement RAG systems | ☐ |
| I can design ML data pipelines | ☐ |
| I understand online/offline features | ☐ |
| I can integrate ML with data platforms | ☐ |

---

# PART 15: ENTERPRISE DATA PLATFORM ARCHITECTURE

## Learning Objectives
- [ ] Design reference architectures
- [ ] Implement end-to-end data flows
- [ ] Document architectural decisions
- [ ] Assess production readiness

---

## Key Concepts Summary

**Fill in the blanks:**

1. A reference architecture provides a __________ for system design.

2. ADR stands for ____________________.

3. Zero Trust security means ____________________.

4. Data observability monitors __________, __________, and __________.

---

## Hands-On Exercises

### Exercise 15.1: Reference Architecture Design (✏️)

Design a complete enterprise data platform reference architecture:

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                         │
│ [Dashboard] [API Gateway] [ML Inference]                   │
├─────────────────────────────────────────────────────────────┤
│ SEMANTIC LAYER                                             │
│ _____                                                      │
├─────────────────────────────────────────────────────────────┤
│ DATA LAKEHOUSE                                             │
│ _____                                                      │
├─────────────────────────────────────────────────────────────┤
│ INTEGRATION LAYER                                          │
│ _____                                                      │
├─────────────────────────────────────────────────────────────┤
│ STORAGE LAYER                                              │
│ _____                                                      │
├─────────────────────────────────────────────────────────────┤
│ INFRASTRUCTURE LAYER                                       │
│ _____                                                      │
└─────────────────────────────────────────────────────────────┘
```

**Add details for each layer:**

| Layer | Components | Technologies |
|-------|------------|--------------|
| Presentation | _____ | _____ |
| Semantic | _____ | _____ |
| Data Lakehouse | _____ | _____ |
| Integration | _____ | _____ |
| Storage | _____ | _____ |
| Infrastructure | _____ | _____ |

### Exercise 15.2: End-to-End Data Flow (✏️)

Trace a data flow from source to dashboard:

**Source: CRM (customer data)**

```
Step 1: ________ (CDC from CRM)
Step 2: ________ (Bronze layer storage)
Step 3: ________ (Silver layer transformations)
Step 4: ________ (Gold layer aggregates)
Step 5: ________ (Semantic layer)
Step 6: ________ (BI dashboard)

```

**Data transformations at each step:**

| Step | Transformation |
|------|----------------|
| CDC | _____ |
| Bronze | _____ |
| Silver | _____ |
| Gold | _____ |
| Semantic | _____ |

### Exercise 15.3: ADR Creation (✏️)

Write an ADR for a key architectural decision:

```markdown
# ADR-001: [Decision Title]

**Status:** [Proposed/Accepted/Deprecated]

**Date:** [Date]

**Author:** [Your Name]

**Context:**
[What is the context for this decision?]

_______________________________________________________________________

_______________________________________________________________________

**Decision:**
[What is the decision?]

_______________________________________________________________________

_______________________________________________________________________

**Alternatives Considered:**
1. [Alternative 1]
   - Pros: _____
   - Cons: _____

2. [Alternative 2]
   - Pros: _____
   - Cons: _____

**Consequences:**
- Positive: _____
- Negative: _____
```

### Exercise 15.4: Production Readiness Assessment (✏️)

Assess production readiness for a data platform:

| Area | Requirement | Status | Actions |
|------|-------------|--------|---------|
| Security | _____ | _____ | _____ |
| Reliability | _____ | _____ | _____ |
| Performance | _____ | _____ | _____ |
| Governance | _____ | _____ | _____ |
| Operations | _____ | _____ | _____ |

**Risk Assessment:**

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |

**Recommendations:**

_______________________________________________________________________

_______________________________________________________________________

---

## Challenge Problem (⭐)

**Scenario:** A company wants to build a greenfield data platform from scratch. Requirements:
- 100TB initial data, growing to 1PB
- 100+ daily ETL jobs
- 50+ SQL users
- 10 data scientists
- Real-time streaming
- 99.9% availability
- GDPR compliance
- $1M annual budget

**Design the complete platform:**

_______________________________________________________________________

_______________________________________________________________________

**Include:**
- Reference architecture
- Technology choices
- Cost estimates
- Implementation timeline
- Team structure
- Migration strategy

---

## Self-Assessment Checklist

| Skill | ✅ |
|-------|---|
| I can design reference architectures | ☐ |
| I can document ADRs | ☐ |
| I can design end-to-end data flows | ☐ |
| I can assess production readiness | ☐ |
| I understand Zero Trust security | ☐ |
| I can build enterprise data platforms | ☐ |

---

# FINAL PROJECT: COMPLETE DATA PLATFORM DESIGN

## Project Overview

Design and document a complete enterprise data platform for a fictional company. This project synthesizes all the knowledge from the 15 parts.

### Company Profile

**Company:** DataMart Retail
**Industry:** E-commerce
**Size:** 5,000 employees, 10M customers
**Revenue:** $5B annually
**Data Sources:**
- E-commerce platform (orders, customers, products)
- CRM (customer interactions)
- ERP (inventory, finance)
- Marketing (campaigns, clicks, conversions)
- Mobile app (user behavior)
- IoT (store sensors, inventory tracking)
- Social media (sentiment, engagement)

### Requirements

1. **Business Intelligence:**
   - Executive dashboards (KPIs, trends)
   - Self-service analytics
   - 90-day historical analysis

2. **Real-Time Analytics:**
   - Inventory visibility (< 1s delay)
   - Personalization (product recommendations)
   - Fraud detection

3. **Machine Learning:**
   - Customer churn prediction
   - Product recommendation system
   - Demand forecasting

4. **Data Governance:**
   - GDPR compliance
   - Data quality monitoring
   - Data lineage tracking

5. **Operations:**
   - 99.9% availability
   - 4-hour RTO
   - 15-minute RPO

---

## Project Deliverables

### Part 1: Architecture Design
- [ ] High-level architecture diagram
- [ ] Reference architecture with all layers
- [ ] Technology selection with rationale
- [ ] Data flow diagram

### Part 2: Data Model
- [ ] Conceptual data model (ERD)
- [ ] Logical data model (star/snowflake)
- [ ] Physical data model (DDL)
- [ ] Partitioning strategy

### Part 3: Data Pipeline Design
- [ ] Data ingestion strategy
- [ ] ETL/ELT design
- [ ] Streaming architecture
- [ ] Orchestration (Airflow DAGs)

### Part 4: Storage Design
- [ ] Data lake layout
- [ ] Data warehouse design
- [ ] Format selection (Parquet/ORC/Delta)
- [ ] Lifecycle policies

### Part 5: Governance
- [ ] Data classification scheme
- [ ] Data quality rules
- [ ] Data lineage tracking
- [ ] Compliance approach

### Part 6: Operations
- [ ] Deployment strategy
- [ ] Monitoring and alerting
- [ ] Disaster recovery plan
- [ ] Cost estimation

### Part 7: ADRs
- [ ] 5+ Architectural Decision Records
- [ ] Clear rationale and alternatives
- [ ] Trade-off analysis

### Part 8: Documentation
- [ ] Platform overview
- [ ] Architecture decisions
- [ ] Operational runbooks
- [ ] User guides

---

## Project Template

Use this template to organize your project:

```markdown
# DataMart Retail: Enterprise Data Platform

## 1. Executive Summary
[Summary of the platform design]

## 2. Architecture Overview
[High-level architecture diagram and description]

## 3. Detailed Design

### 3.1 Storage Layer
[Data lake, warehouse, formats, lifecycle]

### 3.2 Integration Layer
[Ingestion, ETL, streaming, CDC]

### 3.3 Processing Layer
[Batch, real-time, orchestration]

### 3.4 Governance Layer
[Metadata, lineage, quality, compliance]

### 3.5 Presentation Layer
[BI, API, ML serving]

## 4. Technology Choices
[Selected technologies with rationale]

## 5. Data Models
[ERD, star schema, DDL]

## 6. Pipelines
[ETL/ELT design, DAGs]

## 7. Security
[Encryption, access control, audit]

## 8. Operations
[Deployment, monitoring, DR]

## 9. Cost Estimation
[Storage, compute, networking costs]

## 10. ADRs
[Architectural decision records]

## 11. Recommendations
[Future improvements, next steps]
```

---

# APPENDIX: ANSWER KEYS

## Part 1 Answer Key

**Key Concepts Fill-in:**
1. Online Transaction Processing, day-to-day operations
2. Online Analytical Processing, business decisions
3. Structured, Semi-structured, Unstructured
4. Consistency, Availability, Partition Tolerance
5. Atomic values/no repeating groups, full key dependency, no transitive dependencies

**Exercise 1.1 ERD:** Students should include entities: Books, Members, Loans, Categories, Authors with appropriate relationships.

**Exercise 1.2 Normalization:**
1. Books, Members, Loans
2. CREATE TABLE books (book_id, title, author, isbn, publication_year, category_id)
   CREATE TABLE members (member_id, name, email, membership_date)
   CREATE TABLE loans (loan_id, book_id, member_id, loan_date, return_date)

## Part 2 Answer Key

**Key Concepts Fill-in:**
1. depth
2. leaf
3. write-heavy
4. Multi-Version Concurrency Control
5. durability
6. clustered, non-clustered

**Exercise 2.4 MVCC Simulation:**
- READ COMMITTED: First read = 100, Second read = 200
- REPEATABLE READ: First read = 100, Second read = 100
- SERIALIZABLE: First read = 100, Second read = 100

## Part 3 Answer Key

**Key Concepts Match:**
DAS → B, NAS → A, SAN → C, RAID 0 → E, RAID 1 → F, RAID 5 → G, RAID 6 → H, RAID 10 → D

**Fill-in:**
1. 128MB
2. 3 copies, 2 different media, 1 offsite
3. Recovery Point Objective, maximum acceptable data loss
4. Recovery Time Objective, maximum acceptable downtime

## Part 4 Answer Key

**Key Concepts Fill-in:**
1. bucket
2. data, key, metadata
3. flat
4. latest
5. Raw/Bronze, Staging/Silver, Curated/Gold, Analytics, Archive

## Part 5 Answer Key

**Key Concepts Fill-in:**
1. all fields of a row
2. all values for a column
3. columnar, analytical workloads
4. filtering data at the storage layer before reading
5. many small files causing metadata overhead
6. membership tests, false positives

## Part 6 Answer Key

**Exercise 6.1:**
| Isolation Level | Dirty Reads | Non-Repeatable Reads | Phantom Reads |
|-----------------|-------------|---------------------|---------------|
| Read Uncommitted | Yes | Yes | Yes |
| Read Committed | No | Yes | Yes |
| Repeatable Read | No | No | Yes |
| Serializable | No | No | No |

**Exercise 6.2:**
Order: 3, 4, 1, 6, 5, 2, 7

## Part 7 Answer Key

**Key Concepts Fill-in:**
1. Extract, Transform, Load
2. Extract, Load, Transform
3. analytics, operational systems
4. data
5. topic, partitions
6. Directed Acyclic Graph

## Part 8 Answer Key

**Key Concepts Fill-in:**
1. Vertical
2. Horizontal
3. Consistent hashing
4. leaders, followers
5. data loss, downtime

## Part 9 Answer Key

**Key Concepts Fill-in:**
1. Cache-Aside, Read-Through, Write-Through, Write-Behind
2. Least Recently Used, Least Frequently Used, First In First Out, Time To Live
3. Time To Live
4. pre-computed query result stored as a table

## Part 10 Answer Key

**Key Concepts Fill-in:**
1. schema-on-read
2. schema-on-write
3. data lake, data warehouse
4. Bronze/Silver/Gold
5. ACID

## Part 11 Answer Key

**Key Concepts Fill-in:**
1. data format, SLA, usage policies
2. Domain Ownership, Data as a Product, Self-Service Infrastructure, Federated Governance
3. interfaces, SLAs, quality guarantees

## Part 12 Answer Key

**Key Concepts Fill-in:**
1. schema, format, location
2. description, owner, glossary terms
3. access counts, quality scores, freshness
4. the origin and transformation
5. completeness, accuracy, consistency, timeliness

## Part 13 Answer Key

**Key Concepts Fill-in:**
1. measurable, descriptive
2. denormalized
3. normalized
4. technical data, business concepts
5. Key Performance Indicators

## Part 14 Answer Key

**Key Concepts Fill-in:**
1. offline store, online store
2. numerical
3. Retrieval-Augmented Generation
4. similarity

## Part 15 Answer Key

**Key Concepts Fill-in:**
1. blueprint
2. Architectural Decision Record
3. verify every access request regardless of source
4. data quality, freshness, reliability

---

*This workbook accompanies the Mastering Modern Data Architecture tutorial series. Work through each part sequentially, completing exercises and documenting your progress.*
