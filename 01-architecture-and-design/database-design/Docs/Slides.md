# Mastering Modern Database Design — Comprehensive Slide Outline

## Complete Course Structure for Teaching the Series

---

## COURSE OVERVIEW

**Title:** Mastering Modern Database Design: From Theory to Production-Scale Performance

**Target Audience:** Software Developers, Backend Engineers, Database Developers, Software Architects, Data Engineers

**Total Duration:** 20+ hours (4 modules, 7 days)

**Format:** 20+ slide decks, each with 15-30 slides

---

## PART 0: INTRODUCTION TO THE SERIES

### Module 0.1: Course Overview & Expectations (20 slides)

**Slide 1:** Title Slide
- "Mastering Modern Database Design"
- Subtitle: "From Theory to Production-Scale Performance"

**Slide 2:** Welcome & Introductions
- What this series covers
- Who should attend
- What you'll build

**Slide 3:** The Problem with Bad Database Design 
- Real-world consequences of poor design
- Technical debt examples
- Cost of fixing late-stage design issues

**Slide 4:** The ScaleCart Application
- What we're building
- Business requirements
- Target scale (1,000 → 100,000,000 records)

**Slide 5:** Course Learning Outcomes
- What you will know by the end
- Skills you'll gain
- Projects you'll complete

**Slide 6:** Course Structure
- Four-part breakdown
- 20-25 hours total
- Hands-on labs

**Slide 7:** The Technology Stack
- PostgreSQL 15+
- Redis 7+
- MongoDB 7+
- Neo4j 5+
- FastAPI + Python

**Slide 8:** Prerequisites Check
- SQL basics
- Python fundamentals
- Command line comfort
- Docker basics

**Slide 9:** The Primers
- 9 primers covering fundamentals
- How they prepare you
- Where to find them

**Slide 10:** Real-World E-Commerce Requirements
- Product catalog
- Inventory management
- Customer management
- Order processing

**Slide 11:** Success Stories
- Companies that scaled successfully
- Companies that failed

**Slide 12:** The Database Architect Mindset
- Thinking beyond CRUD
- Design for the future
- Balance theory and practice

**Slide 13:** Course Materials
- Slide decks
- Code repositories
- Hands-on labs
- Reference documentation

**Slide 14:** How to Follow Along
- Step-by-step approach
- Code-along instructions
- Testing each step

**Slide 15:** Lab Environment Setup
- Docker Compose
- Python environment
- Database clients
- IDE configuration

**Slide 16:** Community & Support
- Slack/Discord channels
- Office hours
- Q&A sessions

**Slide 17:** What You'll Build
- Complete e-commerce database
- Production-ready API
- Monitoring and alerting
- Disaster recovery

**Slide 18:** Quick Start Demo
- Show a working system
- 10-minute live demo

**Slide 19:** Key Takeaway
- "Whether you're designing a new application or modernizing an existing platform, this course equips you with the practical knowledge, architectural thinking, and performance engineering skills required to build production-grade database systems that scale with confidence."

**Slide 20:** Q&A / Next Steps

---

## PART 1: FOUNDATIONS OF RELATIONAL DATABASE DESIGN

### Module 1.1: Introduction to Relational Databases (25 slides)

**Slide 1:** Part 1 Title
- "Foundations of Relational Database Design"
- "Build the Right Foundation Before You Write a Single Query"

**Slide 2:** Part 1 Objectives
- What you'll learn
- What you'll build
- Time estimate

**Slide 3:** What Is a Database? 
- Digital filing cabinet analogy
- Why databases matter

**Slide 4:** Evolution of Database Systems 
- File System Era
- Hierarchical Databases
- Network Databases
- Relational Model
- Modern Systems

**Slide 5:** Why Relational? 
- Edgar Codd's revolution
- Mathematical foundation
- SQL standard

**Slide 6:** Database Architecture Overview 
- Three-level architecture
- Schema and instance
- Components of DBMS

**Slide 7:** The Relational Model 
- Tables (relations)
- Rows (tuples)
- Columns (attributes)

**Slide 8:** Key Concepts
- Primary keys
- Foreign keys
- Candidate keys
- Composite keys

**Slide 9:** Integrity Constraints 
- Entity integrity
- Referential integrity
- Domain integrity
- User-defined constraints

**Slide 10:** The ScaleCart Domain
- E-commerce business requirements
- Key entities
- Core workflows

**Slide 11:** Domain-Driven Data Modeling 
- Understanding the business
- Identifying entities
- Defining relationships

**Slide 12:** Requirements Collection 
- Stakeholder interviews
- Data flow diagrams
- Functional requirements
- Non-functional requirements

**Slide 13:** Conceptual vs Logical vs Physical 
- The three levels
- What each represents
- How they differ

**Slide 14:** Conceptual Design
- High-level view
- No implementation details
- For stakeholders

**Slide 15:** Logical Design
- Detailed definitions
- Attributes and data types
- Business rules

**Slide 16:** Physical Design
- Technology-specific
- Tables, columns, indexes
- Storage optimization

**Slide 17:** Why Proper Design Matters
- Data integrity
- Performance
- Maintainability
- Scalability

**Slide 18:** The Cost of Bad Design
- Real-world examples
- Technical debt
- Fixing late issues

**Slide 19:** Key Takeaways
- Design before code
- Understand the domain
- Plan for growth

**Slide 20-25:** Practice Exercise / Discussion / Q&A

---

### Module 1.2: Entity-Relationship Modeling (30 slides)

**Slide 1:** Introduction to ER Modeling 
- What is ER modeling?
- Why it matters
- When to use it

**Slide 2:** ER Model Components 
- Entities
- Attributes
- Relationships

**Slide 3:** Entities and Entity Types 
- Physical vs conceptual entities
- Entity sets
- Entity instances

**Slide 4:** Attributes 
- Simple vs composite
- Single-valued vs multi-valued
- Stored vs derived
- Null values

**Slide 5:** Attribute Types Example 
- Customer: name (composite)
- Customer: phone numbers (multi-valued)
- Customer: age (derived from DOB)

**Slide 6:** Key Attributes 
- Uniqueness constraints
- Composite keys
- Multiple keys

**Slide 7:** Relationships 
- What relationships represent
- Relationship types
- Relationship instances

**Slide 8:** Relationship Degree 
- Binary
- Ternary
- Higher degree

**Slide 9:** Cardinality 
- One-to-One (1:1)
- One-to-Many (1:N)
- Many-to-Many (N:M)

**Slide 10:** Cardinality Examples
- Customer to Order
- Product to Category
- Student to Course

**Slide 11:** Participation Constraints 
- Total vs partial
- Existence dependency
- When to use each

**Slide 12:** Role Names 
- Why roles matter
- Recursive relationships
- Example: Employee-Manager

**Slide 13:** Relationship Attributes 
- Attributes on relationships
- Where to place them
- Migration rules

**Slide 14:** Weak Entity Types 
- No key attribute
- Identifying relationship
- Partial keys (discriminators)

**Slide 15:** Weak Entity Example
- Order vs Order Item
- Dependent vs Employee

**Slide 16:** Extended E-R Features 
- Specialization
- Generalization
- Inheritance

**Slide 17:** EER Example
- Employee → Engineer, Manager, Salesperson
- IS-A relationships

**Slide 18:** ER Diagram Notation 
- Chen notation
- Crow's foot notation
- UML notation

**Slide 19:** Reading an ER Diagram
- Step-by-step
- Cardinality interpretation
- Common mistakes

**Slide 20:** Drawing Your First ERD
- Identify entities
- Define attributes
- Map relationships
- Add constraints

**Slide 21:** ER to Relational Mapping 
- Rules for 1:1 relationships
- Rules for 1:N relationships
- Rules for N:M relationships

**Slide 22:** Mapping Weak Entities
- The identifying relationship
- Foreign key placement

**Slide 23:** Mapping EER Features
- Specialization options
- Inheritance patterns

**Slide 24:** Common Design Patterns
- Associative entities
- Supertype/subtype
- Audit trails

**Slide 25:** Design Issues 
- Redundancy
- Missing relationships
- Overcomplication

**Slide 26:** ScaleCart ERD Walkthrough
- Complete diagram
- Step-by-step explanation
- Design decisions

**Slide 27-30:** Practice Exercise / Discussion / Q&A

---

### Module 1.3: Normalization (30 slides)

**Slide 1:** Introduction to Normalization 
- What is normalization?
- Why it matters
- The normalization process

**Slide 2:** The Problem: Data Redundancy 
- Example of denormalized data
- Update anomalies
- Insert anomalies
- Delete anomalies

**Slide 3:** Functional Dependencies 
- Definition
- Full vs partial
- Transitive dependencies

**Slide 4:** Finding Functional Dependencies
- Analyzing data
- Business rules
- Common patterns

**Slide 5:** First Normal Form (1NF) 
- Atomic values
- No repeating groups
- Example

**Slide 6:** 1NF Violation Example
- Customer with multiple phones
- Solution: separate rows/table

**Slide 7:** Second Normal Form (2NF) 
- Must be in 1NF
- No partial dependencies
- Composite key analysis

**Slide 8:** 2NF Example
- Order_Items table
- Composite key: (order_id, product_id)
- Partial dependency check

**Slide 9:** Third Normal Form (3NF) 
- Must be in 2NF
- No transitive dependencies
- Non-key dependencies

**Slide 10:** 3NF Example
- Customer table with city, state, zip
- Zip → city, state (transitive)
- Solution: separate address table

**Slide 11:** Boyce-Codd Normal Form (BCNF) 
- Stricter than 3NF
- Every determinant is a candidate key
- Overlapping candidate keys

**Slide 12:** BCNF Example
- Complex dependency scenarios
- When 3NF isn't enough

**Slide 13:** Normalization Summary
- 1NF → Atomic values
- 2NF → Full key dependency
- 3NF → No transitive dependencies
- BCNF → All determinants are keys

**Slide 14:** When to Denormalize 
- Performance reasons
- Reporting needs
- Controlled redundancy

**Slide 15:** Denormalization Trade-offs
- ✅ Faster reads
- ❌ Slower writes
- ❌ Data consistency challenges

**Slide 16:** Normalization vs Denormalization
- When to use each
- Hybrid approaches
- Real-world examples

**Slide 17:** Applying Normalization to ScaleCart
- Step-by-step
- Before and after
- Design decisions

**Slide 18:** Normalization Practice 1
- Identify NF violations
- Propose solutions

**Slide 19:** Normalization Practice 2
- Complex scenario
- Group exercise

**Slide 20:** Common Normalization Mistakes
- Over-normalization
- Under-normalization
- Misidentifying dependencies

**Slide 21:** Tools for Normalization
- ERD tools
- Dependency analysis
- Automation

**Slide 22-30:** Practice Exercises / Discussion / Q&A

---

### Module 1.4: Designing Efficient Tables (25 slides)

**Slide 1:** Introduction
- From ERD to tables
- Data type selection
- Constraints and rules

**Slide 2:** Choosing Data Types 
- Numeric types
- Text types
- Date/time types
- Special types

**Slide 3:** Numeric Types 
- SMALLINT, INTEGER, BIGINT
- DECIMAL/NUMERIC
- REAL/FLOAT
- When to use each

**Slide 4:** Text Types 
- VARCHAR(n)
- TEXT
- CHAR(n)
- Choosing lengths

**Slide 5:** Date/Time Types 
- DATE
- TIME
- TIMESTAMP
- TIMESTAMPTZ (recommended)

**Slide 6:** Special Types 
- BOOLEAN
- JSON/JSONB
- UUID
- ENUM

**Slide 7:** NULL vs NOT NULL
- When to allow NULLs
- NOT NULL best practices
- Default values

**Slide 8:** Check Constraints
- Range validation
- Format validation
- Business rules

**Slide 9:** Unique Constraints
- Single column
- Multiple columns
- When to use

**Slide 10:** Default Values
- CURRENT_TIMESTAMP
- Sequence defaults
- Custom defaults

**Slide 11:** Naming Conventions 
- Table naming
- Column naming
- Constraint naming
- Consistency matters

**Slide 12:** ScaleCart Table Definitions
- Complete list
- Each table explained
- Justification for decisions

**Slide 13:** ScaleCart: Categories Table
- Fields
- Data types
- Constraints

**Slide 14:** ScaleCart: Products Table
- Core fields
- Search vector
- Generated columns

**Slide 15:** ScaleCart: Orders Table
- Status enum
- Address references
- Total amount

**Slide 16:** ScaleCart: Order Items
- Composite key
- Historical pricing
- Discount handling

**Slide 17:** ScaleCart: Customers
- Email uniqueness
- Password hashing
- Version for optimistic locking

**Slide 18:** ScaleCart: Addresses
- Multiple types
- Default flag
- Customer reference

**Slide 19:** ScaleCart: Inventory
- Product ID as PK
- Stock and reserved
- Reorder thresholds

**Slide 20:** ScaleCart: Supplier Products
- Junction table
- Supply price
- Preferred flag

**Slide 21:** ScaleCart: Payments & Reviews
- Payment status tracking
- Review constraints
- Audit fields

**Slide 22:** Creating the Schema (DDL) 
- CREATE TABLE statements
- Complete SQL script
- Execution steps

**Slide 23:** Verifying the Schema
- \dt (list tables)
- \d (describe table)
- Constraint checks

**Slide 24:** Schema Documentation
- Comments
- Descriptions
- Self-documenting code

**Slide 25:** Key Takeaways
- Choose data types carefully
- Use constraints
- Document your design

---

## PART 2: SQL PERFORMANCE & ADVANCED DATABASE OPTIMIZATION

### Module 2.1: Understanding Query Execution (25 slides)

**Slide 1:** Part 2 Title
- "SQL Performance & Advanced Database Optimization"
- "Understand What the Database Engine Is Really Doing"

**Slide 2:** Part 2 Objectives
- Query optimization
- Indexing strategies
- Scaling to millions

**Slide 3:** The Query Execution Pipeline 
- Parser → Rewriter → Planner → Executor

**Slide 4:** The Query Optimizer 
- Cost-based optimization
- Statistics
- Plan generation

**Slide 5:** Cost Estimation
- Sequential page cost
- Random page cost
- CPU costs

**Slide 6:** Execution Plan Types 
- Sequential scan
- Index scan
- Index only scan
- Bitmap scan

**Slide 7:** Join Methods
- Nested loop join
- Hash join
- Merge join

**Slide 8:** EXPLAIN ANALYZE 
- Reading the output
- Understanding costs
- Identifying bottlenecks

**Slide 9:** EXPLAIN ANALYZE Example
- Before indexing
- After indexing
- Interpretation

**Slide 10:** Reading EXPLAIN Output
- Cost format (startup..total)
- Actual time
- Rows and loops

**Slide 11:** Common Plan Issues
- Sequential scans
- High costs
- Row estimates

**Slide 12:** Generating Test Data
- Faker library
- 1M+ records
- Realistic distribution

**Slide 13:** Sample Performance Queries
- Real-world patterns
- Analyzing output
- Identifying issues

**Slide 14:** Query Analysis Workflow
- Find slow queries
- EXPLAIN ANALYZE
- Identify bottlenecks
- Fix and re-test

**Slide 15-25:** Practice / Discussion / Q&A

---

### Module 2.2: Advanced Indexing Strategies (30 slides)

**Slide 1:** Introduction to Indexing 
- What is an index?
- How indexes work
- The phone book analogy

**Slide 2:** B-Tree Indexes 
- How B-trees work
- When to use
- Advantages and disadvantages

**Slide 3:** Index Types in PostgreSQL 
- B-Tree (default)
- Hash
- GiST
- GIN
- BRIN

**Slide 4:** GIN Indexes 
- Generalized Inverted Index
- Full-text search
- Array operations
- JSONB

**Slide 5:** GIN Index Example
- Full-text search setup
- tsvector and tsquery
- Performance comparison

**Slide 6:** GiST Indexes 
- Generalized Search Tree
- Geospatial data
- Nearest neighbor
- Range queries

**Slide 7:** BRIN Indexes 
- Block Range Index
- Very large tables
- Naturally ordered data

**Slide 8:** BRIN vs B-Tree
- When to use each
- Trade-offs
- Performance comparison

**Slide 9:** Composite Indexes 
- Multiple columns
- Column order matters
- Query patterns

**Slide 10:** Composite Index Example
- Orders (customer_id, status)
- Query coverage

**Slide 11:** Covering Indexes 
- INCLUDE clause
- Avoiding table access
- When to use

**Slide 12:** Covering Index Example
- Product queries
- Performance gain

**Slide 13:** Partial Indexes 
- Index subset of rows
- Smaller indexes
- WHERE clause

**Slide 14:** Partial Index Examples
- Pending orders only
- Active customers
- Low stock products

**Slide 15:** Expression Indexes 
- Index on expression
- LOWER(email)
- Computed values

**Slide 16:** Expression Index Example
- Case-insensitive search
- Date extraction

**Slide 17:** Unique Indexes 
- Enforce uniqueness
- Faster lookups
- Constraint enforcement

**Slide 18:** When to Index 
- Query patterns
- Selectivity
- Write overhead

**Slide 19:** Index Maintenance Costs 
- Write overhead
- Storage space
- Vacuum impact

**Slide 20:** Measuring Index Effectiveness
- Index usage stats
- Unused indexes
- Index scan ratios

**Slide 21:** Adding Indexes to ScaleCart
- Which tables
- Which columns
- Justification

**Slide 22:** Index Verification
- EXPLAIN before/after
- Performance metrics
- Size impact

**Slide 23:** Index Maintenance
- Reindexing
- Vacuum
- Monitoring

**Slide 24:** Common Index Mistakes
- Too many indexes
- Wrong column order
- Missing indexes

**Slide 25:** Index Design Checklist
- Query patterns
- Selectivity
- Write overhead
- Maintenance costs

**Slide 26:** Full-Text Search Implementation
- pg_trgm extension
- GIN indexes
- Search queries

**Slide 27:** Full-Text Search Example
- Setup
- Search syntax
- Ranking

**Slide 28:** Text Search Optimization
- tsvector generation
- Dictionary choices
- Performance tuning

**Slide 29:** Index Tuning Summary
- Choose the right type
- Monitor usage
- Maintain regularly

**Slide 30:** Practice / Discussion / Q&A

---

### Module 2.3: Scaling Large Datasets (25 slides)

**Slide 1:** Introduction to Scaling
- Why databases get slow
- Limits of vertical scaling
- Horizontal solutions

**Slide 2:** Table Partitioning 
- What is partitioning?
- Types of partitioning
- Benefits

**Slide 3:** Range Partitioning
- By date
- By numeric range
- Example

**Slide 4:** List Partitioning
- By discrete values
- By region
- Example

**Slide 5:** Hash Partitioning
- Even distribution
- Load balancing
- Example

**Slide 6:** Partitioning Orders by Date
- ScaleCart example
- Creating partitions
- Data migration

**Slide 7:** Partition Pruning
- Query optimization
- EXPLAIN examples
- Performance gains

**Slide 8:** Partition Management
- Adding partitions
- Dropping partitions
- Archiving

**Slide 9:** Sharding vs Partitioning
- Key differences
- When to use each
- Hybrid approaches

**Slide 10:** Sharding Strategy
- By customer_id
- Range vs hash
- Consistency hashing

**Slide 11:** Sharding Challenges
- Cross-shard queries
- Rebalancing
- Hot spots

**Slide 12:** Read Replicas 
- What are read replicas?
- Performance benefits
- Setup considerations

**Slide 13:** Replication Types
- Synchronous
- Asynchronous
- Multi-master

**Slide 14:** Read Replicas in ScaleCart
- Analytics queries
- Reporting
- Load distribution

**Slide 15:** Archiving Historical Data
- Moving old data
- Partition-based archiving
- Backup strategies

**Slide 16:** Archiving Example
- Orders older than 2 years
- Archive tables
- Query unification

**Slide 17:** Data Lifecycle Management
- Hot data
- Warm data
- Cold data
- Storage tiers

**Slide 18:** Distributed Systems Concepts
- CAP theorem
- Consistency models
- Trade-offs

**Slide 19:** CAP Theorem
- Consistency
- Availability
- Partition tolerance

**Slide 20:** CP vs AP Systems
- When to choose which
- Examples
- ScaleCart choices

**Slide 21:** Eventual Consistency
- Definition
- When to use
- Trade-offs

**Slide 22:** Materialized Views 
- What are they?
- When to use
- Refresh strategies

**Slide 23:** Materialized View Example
- Daily sales summary
- Performance gain
- Refresh schedule

**Slide 24:** Scaling Checklist
- Partition large tables
- Use read replicas
- Archive old data
- Monitor growth

**Slide 25:** Practice / Discussion / Q&A

---

## PART 3: TRANSACTIONS, CONCURRENCY & DATA INTEGRITY

### Module 3.1: ACID Transactions (25 slides)

**Slide 1:** Part 3 Title
- "Transactions, Concurrency & Data Integrity"
- "Build Systems That Remain Correct Under Load"

**Slide 2:** Part 3 Objectives
- ACID transactions
- Concurrency control
- Locking strategies
- Zero-downtime migrations

**Slide 3:** What Is a Transaction? 
- Definition
- The bank transfer analogy
- Why transactions matter

**Slide 4:** The ACID Properties 
- Atomicity
- Consistency
- Isolation
- Durability

**Slide 5:** Atomicity — All or Nothing
- Definition
- Example
- COMMIT and ROLLBACK

**Slide 6:** Consistency — Keep Data Valid
- Definition
- Constraints
- Business rules

**Slide 7:** Isolation — No Interference
- Definition
- Isolation levels
- Preventing anomalies

**Slide 8:** Durability — Survive Crashes
- Definition
- WAL (Write-Ahead Log)
- Recovery

**Slide 9:** Transaction Control in SQL 
- BEGIN
- COMMIT
- ROLLBACK
- SAVEPOINT

**Slide 10:** Transaction Example: Order Placement
- Complete workflow
- Step by step
- Error handling

**Slide 11:** Transaction Example in Python
- SQLAlchemy transactions
- With block
- Error handling

**Slide 12:** Nested Transactions
- Savepoints
- Partial rollback
- When to use

**Slide 13:** Transaction Best Practices
- Keep transactions short
- Avoid user input
- Handle errors gracefully

**Slide 14:** Transaction Scope
- What to include
- What to exclude
- Boundaries

**Slide 15:** Distributed Transactions
- Two-phase commit
- Saga pattern
- Trade-offs

**Slide 16:** Saga Pattern
- Choreography
- Orchestration
- Compensation

**Slide 17:** ScaleCart Transaction Workflows
- Order placement
- Inventory update
- Payment processing
- Order cancellation

**Slide 18:** Transaction Monitoring
- Monitoring tools
- Identifying issues
- Performance impact

**Slide 19-25:** Practice / Discussion / Q&A

---

### Module 3.2: Isolation Levels & Concurrency (25 slides)

**Slide 1:** Concurrency Problems 
- Why concurrent access is challenging
- Real-world scenarios
- Business impact

**Slide 2:** Dirty Reads 
- Definition
- Example
- How to prevent

**Slide 3:** Non-Repeatable Reads 
- Definition
- Example
- How to prevent

**Slide 4:** Phantom Reads 
- Definition
- Example
- How to prevent

**Slide 5:** PostgreSQL Isolation Levels 
- READ COMMITTED (default)
- REPEATABLE READ
- SERIALIZABLE

**Slide 6:** READ COMMITTED
- What it allows
- What it prevents
- Use cases

**Slide 7:** REPEATABLE READ
- What it allows
- What it prevents
- Use cases

**Slide 8:** SERIALIZABLE
- What it allows
- What it prevents
- Use cases

**Slide 9:** Choosing the Right Level
- Performance vs correctness
- Workload analysis
- ScaleCart recommendations

**Slide 10:** Optimistic Locking 
- Version numbers
- Check before commit
- Retry on conflict

**Slide 11:** Optimistic Locking Example
- Customer update
- Version column
- Error handling

**Slide 12:** Pessimistic Locking 
- SELECT FOR UPDATE
- Exclusive locks
- When to use

**Slide 13:** Pessimistic Locking Example
- Inventory reservation
- FOR UPDATE
- Deadlock considerations

**Slide 14:** Lock Types 
- Row-level locks
- Table-level locks
- Advisory locks

**Slide 15:** Lock Compatibility
- Shared vs Exclusive
- Matrix
- Implications

**Slide 16:** Deadlocks 
- Definition
- Example
- Detection

**Slide 17:** Deadlock Avoidance
- Consistent ordering
- Keep transactions short
- Retry on deadlock

**Slide 18:** Deadlock Example & Solution
- Two transactions
- Lock order
- Retry logic

**Slide 19:** Monitoring Locks
- pg_locks
- Lock waiting
- Identifying issues

**Slide 20:** Concurrency Best Practices
- Choose isolation carefully
- Use appropriate locks
- Handle deadlocks

**Slide 21-25:** Practice / Discussion / Q&A

---

### Module 3.3: Zero-Downtime Database Changes (20 slides)

**Slide 1:** The Challenge of Schema Changes
- Why changes are difficult
- Production impact
- The goal: no downtime

**Slide 2:** Principles of Zero-Downtime Changes
- Backward compatibility
- Multi-phase migrations
- Rollback capability

**Slide 3:** Adding Columns
- With DEFAULT
- Without DEFAULT
- Backfilling

**Slide 4:** Renaming Columns
- Add new column
- Backfill data
- Deploy code
- Drop old column

**Slide 5:** Changing Data Types
- Add new column with new type
- Backfill with conversion
- Switch application
- Drop old column

**Slide 6:** Creating Indexes Without Locking 
- CREATE INDEX CONCURRENTLY
- Monitoring progress
- Handling failures

**Slide 7:** Dropping Indexes
- Safety considerations
- Performance impact
- Recreating if needed

**Slide 8:** Online Schema Change Tools
- pg_repack
- gh-ost (MySQL)
- Native PostgreSQL features

**Slide 9:** Migration Strategies
- Blue-Green deployments
- Canary deployments
- Feature flags

**Slide 10:** Blue-Green Deployments
- Two environments
- Switch at the load balancer
- Zero downtime

**Slide 11:** Canary Deployments
- Gradual rollout
- Monitor errors
- Rollback quickly

**Slide 12:** Feature Flags
- Code deployment
- Enable features
- Rollback by disabling

**Slide 13:** Migration Testing
- Test on staging
- Load testing
- Rollback testing

**Slide 14:** Migration Rollback
- Safety procedures
- Recovery steps
- Communication

**Slide 15:** ScaleCart Migration Examples
- Adding product weight
- Splitting name fields
- Partitioning orders

**Slide 16:** Migration Tools
- Alembic (Python)
- Flyway
- Liquibase

**Slide 17-20:** Practice / Discussion / Q&A

---

## PART 4: MODERN DATA ARCHITECTURES BEYOND SQL

### Module 4.1: NoSQL Decision Framework (25 slides)

**Slide 1:** Part 4 Title
- "Modern Data Architectures Beyond SQL"
- "Choosing the Right Database for the Right Problem"

**Slide 2:** Part 4 Objectives
- NoSQL databases
- Graph databases
- Emerging technologies
- Distributed systems

**Slide 3:** Why NoSQL? 
- Limitations of SQL
- Modern application needs
- The data explosion

**Slide 4:** NoSQL Categories 
- Document stores
- Key-value stores
- Wide-column stores
- Graph databases

**Slide 5:** Document Stores 
- MongoDB, Couchbase
- JSON-like documents
- Flexible schema
- When to use

**Slide 6:** MongoDB Example
- Product catalog
- Nested data
- Query patterns

**Slide 7:** Key-Value Stores 
- Redis, DynamoDB
- Simple key-value
- Extremely fast
- When to use

**Slide 8:** Redis Example
- Sessions
- Caching
- Real-time data

**Slide 9:** Wide-Column Stores 
- Cassandra, HBase
- Sparse data
- Massive scale
- When to use

**Slide 10:** Graph Databases 
- Neo4j, Amazon Neptune
- Relationship-first
- Traversal performance

**Slide 11:** Graph Database Example
- Social networks
- Recommendations
- Fraud detection

**Slide 12:** Search Engines 
- Elasticsearch, Solr
- Full-text search
- Log analytics

**Slide 13:** Time-Series Databases 
- TimescaleDB, InfluxDB
- Time-stamped data
- Aggregation efficiency

**Slide 14:** Vector Databases
- pgvector, Pinecone
- Embedding search
- AI/ML workloads

**Slide 15:** SQL vs NoSQL Decision Framework
- When to use SQL
- When to use NoSQL
- Hybrid approaches

**Slide 16:** Polyglot Persistence 
- Using multiple databases
- Each for its strength
- ScaleCart example

**Slide 17:** ScaleCart NoSQL Usage
- Redis for sessions and cache
- MongoDB for catalog
- Neo4j for recommendations
- TimescaleDB for metrics

**Slide 18:** Choosing the Right Tool
- Data structure
- Access patterns
- Scale requirements
- Team expertise

**Slide 19-25:** Practice / Discussion / Q&A

---

### Module 4.2: Graph Databases (20 slides)

**Slide 1:** Introduction to Graph Databases 
- What are graph databases?
- Relationship-first approach
- When to use

**Slide 2:** Graph Database Concepts 
- Nodes
- Relationships
- Properties
- Labels

**Slide 3:** Neo4j Basics
- Setup
- Cypher query language
- Browser interface

**Slide 4:** Creating Nodes and Relationships
- CREATE statements
- MERGE
- Patterns

**Slide 5:** Querying Graphs
- MATCH
- WHERE
- RETURN

**Slide 6:** Traversal Queries
- Path patterns
- Depth
- Performance

**Slide 7:** Recommendation Queries
- Collaborative filtering
- Content-based
- Hybrid

**Slide 8:** Graph Indexes
- Node indexing
- Relationship indexing
- Performance

**Slide 9:** ScaleCart Graph Use Cases
- Product recommendations
- Social graph
- Fraud detection

**Slide 10:** Building the Graph
- Data import
- Schema design
- Query patterns

**Slide 11-20:** Practice / Discussion / Q&A

---

### Module 4.3: Distributed Systems & Event-Driven Architecture (20 slides)

**Slide 1:** Distributed Systems Concepts 
- Why distribute?
- Challenges
- Trade-offs

**Slide 2:** CAP Theorem 
- Consistency
- Availability
- Partition tolerance
- Choose two

**Slide 3:** CAP in Practice
- CA: PostgreSQL (single node)
- CP: MongoDB (majority writes)
- AP: Redis, Cassandra

**Slide 4:** Event-Driven Architecture
- Events as first-class citizens
- Decoupling
- Asynchronous processing

**Slide 5:** The Outbox Pattern 
- Reliable event publication
- Same transaction
- Async publisher

**Slide 6:** Outbox Implementation
- outbox_messages table
- Publisher process
- Idempotency

**Slide 7:** Saga Pattern
- Distributed transactions
- Choreography
- Orchestration

**Slide 8:** Saga Example
- Order placement saga
- Compensation actions
- Rollback

**Slide 9:** Eventual Consistency
- Definition
- When to accept
- Trade-offs

**Slide 10:** ScaleCart Event Flow
- Order created
- Inventory updated
- Customer notified

**Slide 11-20:** Practice / Discussion / Q&A

---

## APPENDICES (Reference Modules)

### Appendix A: Complete Project Structure & Setup (15 slides)
- Directory structure
- Docker setup
- Makefile commands

### Appendix B: Data Dictionary (15 slides)
- Complete table definitions
- Column descriptions
- Constraints

### Appendix C: API Reference (15 slides)
- Endpoint list
- Request/response formats
- Authentication

### Appendix D: Deployment Guide (20 slides)
- Production setup
- Security
- Monitoring

### Appendix E: Troubleshooting (15 slides)
- Common issues
- Diagnostic queries
- Solutions

### Appendix F: Performance Benchmarks (10 slides)
- Expected performance
- Testing methodology
- Optimization results

---

## TEACHING NOTES

### Slide Design Principles
- **Visuals before text**: Use diagrams, charts, and screenshots
- **One concept per slide**: Don't overload
- **Code snippets**: Show, don't just tell
- **Real-world examples**: ScaleCart throughout

### Pace Guide
- **Introduction**: 30 minutes
- **Part 1**: 5-6 hours (split over 2 days)
- **Part 2**: 6-8 hours (split over 2-3 days)
- **Part 3**: 4-6 hours (1-2 days)
- **Part 4**: 5-7 hours (2 days)
- **Labs**: Intersperse throughout

### Lab Exercises
- **ERD creation**: 1 hour
- **Schema implementation**: 2 hours
- **Index optimization**: 2 hours
- **Transaction tests**: 1 hour
- **NoSQL integration**: 2 hours
- **Final project**: 4+ hours
