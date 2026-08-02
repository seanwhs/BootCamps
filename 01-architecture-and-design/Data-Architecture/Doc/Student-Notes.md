# Mastering Modern Data Architecture: Complete Student Notes

Welcome to the **Mastering Modern Data Architecture Student Notes**! This comprehensive reference guide distills the entire 15-part series into concise, easy-to-review notes. Think of this as your "cheat sheet" for the entire course - perfect for studying, quick reference, and exam preparation.

---

## How to Use These Notes

### Format
- **📌 Key Concepts** - Essential ideas to remember
- **💡 Important Insights** - Critical understanding
- **🔑 Key Terms** - Vocabulary to master
- **📊 Diagrams** - Visual representations
- **⚡ Quick Facts** - Bite-sized information
- **🎯 Exam Focus** - What to prioritize for tests

### Color Coding
- 🔵 **Blue** = New concept introduction
- 🟢 **Green** = Best practice or recommendation
- 🟠 **Orange** = Warning or common pitfall
- 🔴 **Red** = Critical or exam-focused

---

# PART 1: FOUNDATIONS OF DATA ARCHITECTURE AND DATA MODELING

## 📌 Key Concepts

### OLTP vs. OLAP
| Aspect | OLTP | OLAP |
|--------|------|------|
| **Purpose** | Operations | Decisions |
| **Users** | Employees | Executives |
| **Queries** | Many small | Few complex |
| **Model** | Normalized | Denormalized |
| **Latency** | Milliseconds | Seconds-minutes |

### Data Types
1. **Structured** - Fixed schema (SQL tables)
2. **Semi-Structured** - Flexible schema (JSON, XML)
3. **Unstructured** - No schema (images, videos)

### Normalization Forms
- **1NF**: Atomic values, no repeating groups
- **2NF**: Full key dependency
- **3NF**: No transitive dependencies

### CAP Theorem
- **C**onsistency - All nodes see same data
- **A**vailability - System always responds
- **P**artition Tolerance - System works despite network splits
- **You can only have two!**

### Star vs. Snowflake
| Feature | Star | Snowflake |
|---------|------|-----------|
| Dimensions | Denormalized | Normalized |
| Query Speed | Faster | Slower |
| Storage | More | Less |
| Complexity | Lower | Higher |

---

## 💡 Important Insights

1. **Data modeling is about understanding the business, not just the data**
2. **Normalization reduces redundancy, denormalization improves performance**
3. **There's no "one size fits all" - choose based on your use case**

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **ERD** | Entity-Relationship Diagram |
| **MDM** | Master Data Management |
| **Surrogate Key** | Artificial primary key |
| **Natural Key** | Business-meaningful key |
| **Golden Record** | Single source of truth |

---

# PART 2: STORAGE ENGINES AND DATABASE INTERNALS

## 📌 Key Concepts

### B-Tree vs. LSM Tree

| Feature | B-Tree | LSM Tree |
|---------|--------|----------|
| **Writes** | Random I/O | Sequential I/O |
| **Reads** | Fast (point queries) | Slower (compaction) |
| **Space** | More (fragmentation) | Less (compression) |
| **Use Case** | Mixed OLTP | Write-heavy analytics |
| **Example** | PostgreSQL, MySQL | Cassandra, RocksDB |

### MVCC (Multi-Version Concurrency Control)
- **Purpose**: Enable concurrent access without locks
- **How**: Multiple versions of each row
- **Benefits**: Readers don't block writers
- **Used in**: PostgreSQL, InnoDB

### Write-Ahead Logging (WAL)
- **Purpose**: Durability guarantee
- **Process**: Write log BEFORE data
- **Recovery**: Replay log after crash
- **Key Insight**: Sequential writes are fast

### Storage Hierarchy
```
Register (<1ns) → Cache (1-10ns) → RAM (100ns) → SSD (0.1ms) → HDD (10ms)
```

---

## 💡 Important Insights

1. **B-Trees are balanced** - all leaves at same depth
2. **LSM Trees use sequential writes** - much faster than random
3. **MVCC creates "time travel"** - snapshot isolation
4. **WAL is the foundation of durability**

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **SSTable** | Sorted String Table (immutable) |
| **Compaction** | Merging SSTables in LSM |
| **Page** | Unit of disk I/O |
| **Extent** | Group of contiguous pages |
| **Buffer Pool** | In-memory cache of pages |

---

# PART 3: ENTERPRISE STORAGE ARCHITECTURE

## 📌 Key Concepts

### Storage Types
| Type | Access | Performance | Sharing | Use Case |
|------|--------|-------------|---------|----------|
| **DAS** | Direct | Fastest | No | Local storage |
| **NAS** | File | Moderate | Yes | File sharing |
| **SAN** | Block | Very Fast | Yes | Enterprise DB |

### RAID Levels
| Level | Description | Redundancy | Performance |
|-------|-------------|------------|-------------|
| **0** | Striping | None | Excellent |
| **1** | Mirroring | 1 disk | Good reads |
| **5** | Striping + Parity | 1 disk | Good |
| **6** | Striping + 2 Parity | 2 disks | Good |
| **10** | Striped Mirrors | Excellent | Excellent |

### 3-2-1 Backup Rule
- **3** copies of data
- **2** different media types
- **1** copy offsite

### RPO vs. RTO
- **RPO** = Data loss tolerance
- **RTO** = Downtime tolerance

---

## 💡 Important Insights

1. **RAID is NOT a backup** - protects against hardware failure, not data corruption
2. **HDFS uses 128MB blocks** - optimized for sequential access
3. **More disks in RAID 0 = higher risk** - single disk failure loses ALL data
4. **Tiered storage** = cost optimization

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **NameNode** | HDFS metadata manager |
| **DataNode** | HDFS block storage |
| **HDFS** | Hadoop Distributed File System |
| **Rack Awareness** | HDFS replica placement |

---

# PART 4: CLOUD OBJECT STORAGE AND DATA LAKE FOUNDATIONS

## 📌 Key Concepts

### Object Storage Model
```
Account
  └── Bucket
        └── Object (Data + Key + Metadata)
```

### Data Lake Layers
| Layer | Description | Format |
|-------|-------------|--------|
| **Raw** | Data as ingested | Native (JSON, CSV) |
| **Staging** | Validated, cleaned | Parquet/Delta |
| **Curated** | Enriched, standardized | Optimized Parquet |
| **Analytics** | Aggregated | Tables/Views |
| **Archive** | Cold storage | Compressed |

### Partitioning Strategies
- **Range**: By value ranges (e.g., dates)
- **Hash**: By hash of key (even distribution)
- **List**: By explicit values (e.g., countries)
- **Composite**: Combination

### Prefix Optimization
```
✅ Good: year=2024/month=01/day=15/file.parquet
❌ Bad: /2024/01/15/file.parquet
```

---

## 💡 Important Insights

1. **Prefix structure = query performance** - use key=value patterns
2. **Lifecycle rules = cost savings** - move data to cheaper tiers
3. **Versioning = data protection** - recover from accidental deletions
4. **Partition pruning = faster queries** - only scan relevant data

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **S3** | Simple Storage Service |
| **Bucket** | Container for objects |
| **Object** | Data + key + metadata |
| **ETag** | Object hash (for verification) |
| **Lifecycle Rule** | Automates data movement |

---

# PART 5: MODERN DATA FORMATS AND STORAGE OPTIMIZATION

## 📌 Key Concepts

### Row vs. Columnar Storage

| Aspect | Row-Based | Columnar |
|--------|-----------|----------|
| **Structure** | All fields together | Each column separate |
| **Compression** | Poor | Excellent |
| **Analytics** | Slow | Fast |
| **OLTP** | Good | Poor |
| **Examples** | CSV, Avro | Parquet, ORC |

### File Formats
| Format | Type | Schema Evolution | Best For |
|--------|------|------------------|----------|
| **Parquet** | Columnar | Yes | Analytics |
| **ORC** | Columnar | Yes | Hive/Spark |
| **Avro** | Row-based | Yes | Kafka |
| **CSV** | Row-based | No | Interchange |

### Predicate Pushdown
```
Query: SELECT * FROM table WHERE age > 30
```
- **Without**: Read all data → filter → return
- **With**: Statistics → skip row groups → read only relevant

### Bloom Filters
- **Purpose**: Fast membership tests
- **False Positives**: Possible (rare)
- **False Negatives**: Impossible
- **Memory**: Efficient

---

## 💡 Important Insights

1. **Columnar storage = 10-100x faster for analytics**
2. **Small files = big performance problems** - compact to 128MB+
3. **Compression = storage savings but CPU cost**
4. **Predicate pushdown = I/O reduction**

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Predicate Pushdown** | Filter at storage layer |
| **Partition Pruning** | Skip irrelevant partitions |
| **Data Skipping** | Skip row groups using stats |
| **Bloom Filter** | Probabilistic membership test |
| **Small File Problem** | Many small files causing overhead |

---

# PART 6: TRANSACTION PROCESSING AND DISTRIBUTED CONSISTENCY

## 📌 Key Concepts

### ACID Properties
| Property | Definition | Example |
|----------|------------|---------|
| **Atomicity** | All or nothing | Transfer money |
| **Consistency** | Valid state | Balance >= 0 |
| **Isolation** | No interference | Concurrent transactions |
| **Durability** | Survives failure | Data persists |

### Isolation Levels

| Level | Dirty Reads | Non-Repeatable | Phantoms |
|-------|-------------|----------------|----------|
| Read Uncommitted | ✓ | ✓ | ✓ |
| Read Committed | ✗ | ✓ | ✓ |
| Repeatable Read | ✗ | ✗ | ✓ |
| Serializable | ✗ | ✗ | ✗ |

### Distributed Transaction Patterns
| Pattern | Pros | Cons |
|---------|------|------|
| **2PC** | Atomicity | Blocking |
| **3PC** | Less blocking | More complex |
| **Saga** | High availability | Eventual consistency |

### Consistency Models
- **Strong**: All reads see latest writes
- **Eventual**: Converges over time
- **Read-Your-Writes**: See your own writes
- **Causal**: Preserve operation order

---

## 💡 Important Insights

1. **Isolation levels = consistency vs. performance trade-off**
2. **2PC is blocking** - participants wait for coordinator
3. **Saga uses compensating actions** - rollback via undo operations
4. **BASE = Basically Available, Soft state, Eventually consistent**

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **2PC** | Two-Phase Commit |
| **3PC** | Three-Phase Commit |
| **Saga** | Transaction with compensating actions |
| **Dirty Read** | Reading uncommitted data |
| **Phantom Read** | New rows appearing |

---

# PART 7: DATA INTEGRATION AND MODERN DATA PIPELINES

## 📌 Key Concepts

### ETL vs. ELT vs. Reverse ETL
| Pattern | Process | When to Use |
|---------|---------|-------------|
| **ETL** | Extract → Transform → Load | Data warehouse, legacy |
| **ELT** | Extract → Load → Transform | Data lake, modern | 
| **Reverse ETL** | Analytics → Operational | Closing the loop |

### CDC (Change Data Capture)
- **Purpose**: Real-time database change replication
- **Mechanism**: Monitor database logs (WAL, binlog)
- **Output**: Change events (insert, update, delete)
- **Tools**: Debezium, AWS DMS, Striim

### Kafka Architecture
```
Producers → Topics (Partitions) → Consumers
                (Brokers)
```

### Airflow DAG
```
Task1 → Task2 → Task3
          ↘       ↗
          Task4
```

---

## 💡 Important Insights

1. **CDC = real-time + minimal impact** - no full table scans
2. **Kafka = highly available + fault tolerant** - message persistence
3. **Airflow = dependency management + error handling** - retry on failure
4. **ELT is becoming more common** - leverage modern compute power

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **CDC** | Change Data Capture |
| **DAG** | Directed Acyclic Graph |
| **Topic** | Kafka message stream |
| **Partition** | Kafka parallel unit |
| **Consumer Group** | Kafka consumer coordination |

---

# PART 8: SCALABILITY, DISTRIBUTION, AND HIGH AVAILABILITY

## 📌 Key Concepts

### Scaling Strategies
| Type | Method | Limits |
|------|--------|--------|
| **Vertical** | More resources | Hardware limits |
| **Horizontal** | More machines | Practically unlimited |
| **Elastic** | Automatic scaling | Cost management |

### Partitioning (Sharding)

| Strategy | Best For | Trade-off |
|----------|----------|-----------|
| **Range** | Range queries | Data skew |
| **Hash** | Even distribution | Range queries slow |
| **List** | Explicit control | Manual management |

### Replication Models

| Model | Writes | Reads | Consistency |
|-------|--------|-------|-------------|
| **Leader-Follower** | Leader only | Followers | Strong |
| **Multi-Leader** | Any leader | Any node | Complex |
| **Leaderless** | Any node | Any node | Quorum |

### RPO vs. RTO
- **RPO**: Recovery Point Objective (data loss)
- **RTO**: Recovery Time Objective (downtime)

---

## 💡 Important Insights

1. **Horizontal scaling = more complex** - distributed system challenges
2. **Consistent hashing = minimal data movement** - when nodes change
3. **Quorum = consistency + availability balance** - R + W > N
4. **Disaster recovery = plan + test** - not just a backup strategy

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Consistent Hashing** | Minimal data rebalancing |
| **Quorum** | Minimum nodes for consensus |
| **RPO** | Recovery Point Objective |
| **RTO** | Recovery Time Objective |
| **Sharding** | Data partitioning |

---

# PART 9: CACHING AND PERFORMANCE ENGINEERING

## 📌 Key Concepts

### Caching Patterns

| Pattern | Description | Use When |
|---------|-------------|----------|
| **Cache-Aside** | App manages cache | Simple, flexible |
| **Read-Through** | Cache handles misses | Consistent |
| **Write-Through** | Synchronous writes | Consistency critical |
| **Write-Behind** | Asynchronous writes | Write performance |

### Eviction Policies
- **LRU** - Least Recently Used
- **LFU** - Least Frequently Used
- **FIFO** - First In First Out
- **TTL** - Time To Live

### Redis Data Structures
| Structure | Use Case |
|-----------|----------|
| String | Simple values |
| Hash | Objects |
| List | Queues |
| Set | Unique items |
| Sorted Set | Leaderboards |

---

## 💡 Important Insights

1. **Cache hit ratio = performance** - target > 90%
2. **TTL = freshness + memory management** - choose appropriate value
3. **Write-behind = fast but risk** - data loss on failure
4. **Materialized views = pre-computed queries** - faster but storage cost

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Cache Hit** | Data found in cache |
| **Cache Miss** | Data not in cache |
| **TTL** | Time To Live |
| **Materialized View** | Pre-computed query result |
| **Eviction** | Removing cache entries |

---

# PART 10: DATA LAKES, LAKEHOUSES, AND MODERN ANALYTICS PLATFORMS

## 📌 Key Concepts

### Architecture Comparison

| Aspect | Data Warehouse | Data Lake | Lakehouse |
|--------|----------------|-----------|-----------|
| **Schema** | Schema-on-write | Schema-on-read | Both |
| **ACID** | Yes | No | Yes |
| **Performance** | Excellent | Moderate | Excellent |
| **Flexibility** | Low | High | High |

### Medallion Architecture
```
Bronze (Raw) → Silver (Clean) → Gold (Curated)
```

### Delta Lake Features
- ✅ ACID Transactions
- ✅ Time Travel (versioning)
- ✅ Schema Enforcement
- ✅ Data Skipping

### Open Table Formats
| Format | Creator | Best For |
|--------|---------|----------|
| **Delta Lake** | Databricks | Databricks, simple operations |
| **Iceberg** | Netflix | Multi-engine, partition evolution |
| **Hudi** | Uber | Streaming, incremental |

---

## 💡 Important Insights

1. **Lakehouse = best of both worlds** - flexibility + performance
2. **Medallion = data quality progression** - raw → clean → curated
3. **Time travel = audit + rollback** - query any version
4. **Open formats = no vendor lock-in** - portable data

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Lakehouse** | Data lake + ACID |
| **Medallion** | Bronze/Silver/Gold layers |
| **Delta Lake** | Open format with ACID |
| **Time Travel** | Query historical versions |
| **Schema Evolution** | Change schema without breaking |

---

# PART 11: ENTERPRISE DATA HUBS AND DATA MESH

## 📌 Key Concepts

### Data Mesh Principles

| Principle | Description | Benefit |
|-----------|-------------|---------|
| **Domain Ownership** | Teams own their data | Faster, better quality |
| **Data as Product** | Clear interfaces, SLAs | Discoverable, usable |
| **Self-Service** | Team autonomy | No bottlenecks |
| **Federated Governance** | Shared standards | Consistency + autonomy |

### Data Products vs. Data Assets
| Aspect | Data Asset | Data Product |
|--------|------------|--------------|
| **Curation** | Raw/uncurated | Business-ready |
| **Ownership** | Often unclear | Clear owner |
| **Documentation** | Minimal | Complete |
| **SLA** | None | Defined |

### Data Contract
```
Format: Schema
SLA: Availability, latency
Usage: Access method, rate limits
```

---

## 💡 Important Insights

1. **Data Mesh = organizational shift** - not just technology
2. **Data products = customer focus** - treat data as a product
3. **Data contracts = reliability** - formal agreements
4. **Event-driven = loose coupling** - real-time integration

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Data Mesh** | Decentralized data architecture |
| **Data Product** | Domain-owned, business-ready data |
| **Data Contract** | Formal agreement |
| **Federated Governance** | Distributed governance |

---

# PART 12: METADATA MANAGEMENT AND DATA GOVERNANCE

## 📌 Key Concepts

### Metadata Types

| Type | Description | Examples |
|------|-------------|----------|
| **Technical** | Storage, format, schema | Parquet, 500MB, schema |
| **Business** | Meaning, ownership | Description, owner |
| **Operational** | Usage, quality | Access count, quality score |

### Data Quality Dimensions
1. **Completeness** - All data present
2. **Accuracy** - Data reflects reality
3. **Consistency** - Across systems
4. **Timeliness** - Up-to-date
5. **Uniqueness** - No duplicates
6. **Validity** - Conforms to format

### Data Lineage
- **Purpose**: Track data origin and transformations
- **Benefits**: Impact analysis, debugging, compliance
- **Types**: Column-level, table-level

### Compliance Regulations
| Regulation | Region | Key Requirement |
|------------|--------|-----------------|
| **GDPR** | EU | Right to delete |
| **CCPA** | California | Right to opt-out |
| **HIPAA** | US | PHI protection |
| **SOX** | US | Audit trail |

---

## 💡 Important Insights

1. **Metadata = data about data** - critical for governance
2. **Data quality = trust** - poor quality = no trust
3. **Lineage = traceability** - know where data comes from
4. **Compliance = non-negotiable** - build it in from start

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Metadata** | Data about data |
| **Lineage** | Data origin and transformations |
| **Data Catalog** | Metadata repository |
| **DSAR** | Data Subject Access Request |
| **Data Steward** | Data quality owner |

---

# PART 13: BUSINESS INTELLIGENCE AND ANALYTICAL ARCHITECTURE

## 📌 Key Concepts

### Dimensional Modeling

| Component | Purpose | Examples |
|-----------|---------|----------|
| **Fact Table** | Measurable data | Sales amount |
| **Dimension Table** | Descriptive data | Product name |
| **Star Schema** | Denormalized | Fast queries |
| **Snowflake** | Normalized | Storage efficient |

### Fact vs. Dimension

| Aspect | Fact | Dimension |
|--------|------|-----------|
| **Data** | Quantitative | Descriptive |
| **Size** | Large, growing | Smaller, static |
| **Updates** | Append only | Occasional updates |
| **Keys** | Foreign keys | Surrogate keys |

### Semantic Layer
```
Business Concept (Revenue) → Technical (SUM(sales.amount))
```

### KPIs (Key Performance Indicators)
- Revenue Growth
- Customer Acquisition Cost
- Customer Lifetime Value
- Churn Rate
- Conversion Rate

---

## 💡 Important Insights

1. **Star schema = simpler queries** - fewer joins
2. **Snowflake schema = less storage** - more normalized
3. **Semantic layer = self-service** - business users understand
4. **KPIs = business success measure** - tied to objectives

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Fact** | Measurable business event |
| **Dimension** | Descriptive attribute |
| **Star Schema** | Denormalized dimensions |
| **Snowflake Schema** | Normalized dimensions |
| **Semantic Layer** | Business abstraction |
| **KPI** | Key Performance Indicator |

---

# PART 14: MACHINE LEARNING DATA ARCHITECTURE

## 📌 Key Concepts

### Feature Store Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Offline Store** | Training | Data warehouse/lake |
| **Online Store** | Inference | Redis, DynamoDB |
| **Feature Registry** | Definitions | Metadata store |

### Feature Store Benefits
- ✅ Consistency (train vs. serve)
- ✅ Reusability (across models)
- ✅ Governance (lineage, quality)
- ✅ Performance (fast serving)

### Vector Databases
- **Purpose**: Store and search embeddings
- **Key Metric**: Similarity (cosine, Euclidean)
- **Use Cases**: Semantic search, RAG, recommendations
- **Examples**: Pinecone, Qdrant, Weaviate

### RAG Architecture
```
Query → Retrieve (Vector DB) → Augment (Context) → Generate (LLM) → Response
```

### ML Pipeline
```
Data → Feature Engineering → Training → Validation → Deployment → Monitoring
```

---

## 💡 Important Insights

1. **Feature store = ML infrastructure** - consistent features
2. **Training-serving skew = common problem** - feature store prevents
3. **Embeddings = semantic meaning** - high-dimensional representation
4. **RAG = factual + up-to-date** - grounded LLM responses

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **Feature Store** | Centralized feature management |
| **Embedding** | Numerical representation |
| **Vector Database** | Similarity search |
| **RAG** | Retrieval-Augmented Generation |
| **Training-Serving Skew** | Feature mismatch |

---

# PART 15: ENTERPRISE DATA PLATFORM ARCHITECTURE

## 📌 Key Concepts

### Reference Architecture
```
Presentation Layer (BI, API, ML)
        ↓
Semantic Layer (Models, Metrics)
        ↓
Data Lakehouse (Gold/Silver/Bronze)
        ↓
Integration Layer (ETL, Streaming, CDC)
        ↓
Storage Layer (Object, File, DB)
        ↓
Infrastructure Layer (K8s, Monitoring)
```

### ADR (Architectural Decision Record)
```markdown
Title: Decision Title
Status: Proposed/Accepted/Deprecated
Context: Background and forces
Decision: What was decided
Alternatives: Other options considered
Consequences: Impact of decision
```

### Zero Trust Security
- **Never trust, always verify**
- Every access request is authenticated
- Least privilege access
- Continuous monitoring

### Data Observability
- **Quality**: Data meets expectations
- **Freshness**: Data is up-to-date
- **Volume**: Expected amount of data
- **Schema**: Schema is consistent

### Production Readiness Checklist
- ✅ Security (encryption, access control)
- ✅ Reliability (HA, DR, backup)
- ✅ Performance (optimization, caching)
- ✅ Governance (lineage, quality, compliance)
- ✅ Operations (monitoring, CI/CD, runbooks)

---

## 💡 Important Insights

1. **Reference architecture = blueprint** - guides implementation
2. **ADRs = knowledge capture** - why decisions were made
3. **Zero Trust = security paradigm** - verify everything
4. **Observability = system health** - know what's happening
5. **Production readiness = checklist** - don't skip steps

---

## 🔑 Key Terms

| Term | Definition |
|------|------------|
| **ADR** | Architectural Decision Record |
| **Zero Trust** | Verify every request |
| **Data Observability** | Data health monitoring |
| **Reference Architecture** | Platform blueprint |

---

# QUICK REFERENCE CARDS

## Architecture Patterns Card

```
┌─────────────────────────────────────────────────────────────┐
│              DATA ARCHITECTURE QUICK REFERENCE              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  STORAGE:                                                   │
│  Data Lake: Raw, flexible, schema-on-read                 │
│  Data Warehouse: Curated, fast, schema-on-write           │
│  Lakehouse: Best of both, ACID on data lake               │
│                                                             │
│  PROCESSING:                                                │
│  ETL: Extract → Transform → Load                          │
│  ELT: Extract → Load → Transform                          │
│  Reverse ETL: Analytics → Operational                     │
│                                                             │
│  CONSISTENCY:                                               │
│  Strong: All reads see latest writes                      │
│  Eventual: Converges over time                            │
│  Read-Your-Writes: Writer sees own writes                 │
│                                                             │
│  SCALING:                                                   │
│  Vertical: Add resources                                   │
│  Horizontal: Add machines                                  │
│  Elastic: Automatic scaling                                │
│                                                             │
│  CACHING:                                                   │
│  Cache-Aside: App manages                                  │
│  Read-Through: Cache handles misses                       │
│  Write-Through: Synchronous writes                        │
│  Write-Behind: Asynchronous writes                        │
│                                                             │
│  GOVERNANCE:                                                │
│  Metadata: Data about data                                 │
│  Lineage: Data origins                                     │
│  Quality: Completeness, accuracy, etc.                    │
│  Compliance: GDPR, CCPA, HIPAA                            │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack Card

```
┌─────────────────────────────────────────────────────────────┐
│              TECHNOLOGY STACK QUICK REFERENCE               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  DATABASES:                 STREAMING:                      │
│  • PostgreSQL, MySQL        • Apache Kafka                 │
│  • MongoDB                  • Debezium (CDC)               │
│                                                             │
│  STORAGE:                   PROCESSING:                    │
│  • MinIO (S3)               • Apache Spark                 │
│  • HDFS                     • Trino                        │
│  • Parquet, ORC, Avro       • DuckDB                       │
│  • Delta Lake, Iceberg                                     │
│                                                             │
│  ORCHESTRATION:             BI & VISUALIZATION:            │
│  • Apache Airflow           • Superset                     │
│                              • Streamlit                    │
│  MONITORING:                                                │
│  • Prometheus               ML & AI:                       │
│  • Grafana                  • Feature Store                │
│                              • Vector DB                    │
│  INFRASTRUCTURE:            • RAG                          │
│  • Docker, Kubernetes                                       │
│  • Terraform                                                 │
└─────────────────────────────────────────────────────────────┘
```

## Common Commands Card

```
┌─────────────────────────────────────────────────────────────┐
│              COMMON COMMANDS QUICK REFERENCE                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  DOCKER:                                                    │
│  docker-compose up -d               # Start services       │
│  docker-compose ps                  # Check status         │
│  docker-compose logs -f [service]   # View logs            │
│  docker-compose down -v             # Stop and clean       │
│                                                             │
│  POSTGRESQL:                                                │
│  psql -U dataarch -d dataarch       # Connect              │
│  \dt                                # List tables           │
│  \d table_name                      # Describe table       │
│  EXPLAIN ANALYZE SELECT...          # Query plan           │
│                                                             │
│  KAFKA:                                                     │
│  kafka-topics --list                # List topics          │
│  kafka-console-producer             # Produce              │
│  kafka-console-consumer             # Consume              │
│                                                             │
│  REDIS:                                                     │
│  redis-cli                          # Connect              │
│  SET key "value"                    # Set key              │
│  GET key                            # Get key              │
│  SETEX key 60 "value"               # Set with TTL         │
│                                                             │
│  MINIO (mc):                                                │
│  mc ls myminio                      # List buckets         │
│  mc mb myminio/bucket               # Create bucket        │
│  mc cp file myminio/bucket/         # Copy file            │
└─────────────────────────────────────────────────────────────┘
```

---

## Exam Preparation Tips

### Key Areas to Focus

1. **Architecture Patterns** - Understand when to use each
2. **Trade-offs** - Know the pros and cons
3. **Technology Choices** - Why choose one over another
4. **Data Modeling** - Normalization, star/snowflake
5. **Storage Engines** - B-Tree vs. LSM Tree
6. **Transaction Processing** - ACID, isolation levels, 2PC
7. **Data Integration** - ETL/ELT, CDC, Kafka
8. **Scalability** - Partitioning, replication, CAP theorem
9. **Performance** - Caching, indexing, optimization
10. **Governance** - Metadata, lineage, quality

### Common Exam Questions

1. **"What architecture would you use for X scenario?"**
   - Consider: OLTP vs. OLAP, data volume, latency, consistency

2. **"Compare and contrast X and Y..."**
   - Include: Use cases, trade-offs, strengths, weaknesses

3. **"Design a solution for..."**
   - Include: Architecture diagram, technology choices, rationale

4. **"Why would you choose X over Y?"**
   - Include: Specific requirements, trade-off analysis

5. **"What are the implications of..."**
   - Include: Performance, scalability, cost, governance

### Quick Memory Aids

| Concept | Mnemonic |
|---------|----------|
| ACID | Atomic, Consistent, Isolated, Durable |
| BASE | Basically Available, Soft state, Eventually consistent |
| CAP | Consistency, Availability, Partition Tolerance |
| OLTP | Online Transaction Processing |
| OLAP | Online Analytical Processing |
| ETL | Extract, Transform, Load |
| ELT | Extract, Load, Transform |
| CDC | Change Data Capture |
| MVCC | Multi-Version Concurrency Control |
| RPO | Recovery Point Objective |
| RTO | Recovery Time Objective |

---

*These student notes are a condensed reference for the Mastering Modern Data Architecture series. Use them alongside the full tutorials for comprehensive learning.*

**Happy Studying! 📚**
