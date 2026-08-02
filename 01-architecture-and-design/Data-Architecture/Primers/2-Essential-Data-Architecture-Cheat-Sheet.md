# Primer 2: Essential Data Architecture Cheat Sheet

Welcome to the **Data Architecture Cheat Sheet** - your quick reference guide to the most important concepts, patterns, and commands from the Mastering Modern Data Architecture series. Think of this as your pocket reference for daily data architecture work.

---

## 1. Core Architecture Patterns

### Data Storage Patterns

| Pattern | Description | Best For | Example Tech |
|---------|-------------|----------|--------------|
| **Data Lake** | Schema-on-read, raw data | Exploration, ML, big data | S3, HDFS, MinIO |
| **Data Warehouse** | Schema-on-write, curated data | BI reporting, analytics | Snowflake, Redshift |
| **Lakehouse** | ACID + lake flexibility | Modern analytics | Delta Lake, Iceberg |
| **Database (OLTP)** | Transactional, ACID | Application data | PostgreSQL, MySQL |
| **Data Hub** | Centralized data sharing | Enterprise integration | Kafka, APIs |
| **Data Mesh** | Decentralized ownership | Large organizations | Domain-driven design |

### ETL/ELT Patterns

```
ETL: Extract → Transform → Load
     Works well for structured data, data warehouses
     Pros: Clean data, validation before load
     Cons: Slow, heavy transformation

ELT: Extract → Load → Transform
     Works well for data lakes, modern warehouses
     Pros: Fast ingestion, flexible transformations
     Cons: Storage costs, raw data quality

Reverse ETL: Analytics → Operational Systems
     Works for closing the loop
     Pros: Data-driven actions
     Cons: Complexity, latency
```

---

## 2. Data Modeling Cheat Sheet

### Normalization Levels

| Level | Description | Use When |
|-------|-------------|----------|
| **1NF** | Atomic values, no repeating groups | Always |
| **2NF** | All non-key attributes depend on full key | OLTP systems |
| **3NF** | No transitive dependencies | Most databases |
| **Denormalized** | Redundant data for performance | Analytics, BI |

### Schema Types

```
Star Schema (Denormalized Dimensions)
┌─────────────────────────────────────┐
│         Fact Table                  │
│  ┌───────┐  ┌───────┐  ┌───────┐  │
│  │ Dim 1 │  │ Dim 2 │  │ Dim 3 │  │
│  └───────┘  └───────┘  └───────┘  │
└─────────────────────────────────────┘
✅ Simple queries, fast performance
❌ More storage, data redundancy

Snowflake Schema (Normalized Dimensions)
┌─────────────────────────────────────┐
│         Fact Table                  │
│  ┌───────┐  ┌───────┐  ┌───────┐  │
│  │ Dim 1 │  │ Dim 2 │  │ Dim 3 │  │
│  │  │    │  │  │    │  │  │    │  │
│  │  ▼    │  │  ▼    │  │  ▼    │  │
│  │SubDim │  │SubDim │  │SubDim │  │
│  └───────┘  └───────┘  └───────┘  │
└─────────────────────────────────────┘
✅ Less storage, normalized data
❌ More complex queries, slower
```

---

## 3. Storage Engines Comparison

| Engine | Type | Best For | Characteristics |
|--------|------|----------|-----------------|
| **B-Tree** (PostgreSQL) | Row-based | Mixed workloads | Balanced, ACID |
| **LSM Tree** (Cassandra) | Row-based | Write-heavy | High throughput, eventual consistency |
| **Columnar** (Parquet) | Column-based | Analytics | Compression, predicate pushdown |
| **In-Memory** (Redis) | Key-value | Caching, sessions | Sub-millisecond latency |

### B-Tree vs. LSM Tree

| Aspect | B-Tree | LSM Tree |
|--------|--------|----------|
| **Writes** | Moderate (random I/O) | Fast (sequential I/O) |
| **Reads** | Fast (point queries) | Slower (compaction) |
| **Space** | More (fragmentation) | Less (compression) |
| **Use Case** | Mixed OLTP | Write-heavy, analytics |

---

## 4. Consistency Models

### ACID vs. BASE

| ACID | BASE |
|------|------|
| **Atomicity** | **Basically Available** |
| **Consistency** | **Soft State** |
| **Isolation** | **Eventual Consistency** |
| **Durability** | |

### Consistency Levels

| Level | Description | Latency | Example |
|-------|-------------|---------|---------|
| **Strong** | Read after write sees latest | High | RDBMS |
| **Read-Your-Writes** | Session consistency | Medium | Some NoSQL |
| **Eventual** | Converges over time | Low | DNS, Cassandra |
| **Monotonic** | Reads never go backward | Medium | DynamoDB |

---

## 5. File Formats Quick Reference

| Format | Type | Compression | Schema | Use Case |
|--------|------|-------------|--------|----------|
| **Parquet** | Columnar | Excellent | Explicit | Analytics, data lakes |
| **ORC** | Columnar | Excellent | Explicit | Analytics, Hive |
| **Avro** | Row-based | Good | Explicit | Kafka, data integration |
| **CSV** | Row-based | None | Implicit | Interchange |
| **JSON** | Row-based | None | Implicit | APIs, semi-structured |
| **Delta Lake** | Table format | Excellent | Explicit | ACID on data lakes |
| **Iceberg** | Table format | Excellent | Explicit | Open table format |

---

## 6. Caching Patterns

```
┌─────────────────────────────────────────────────────────────┐
│                      CACHING PATTERNS                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Cache-Aside (Lazy Loading)                               │
│  ┌─────────┐   Miss   ┌───────┐   ┌─────────┐           │
│  │ Client  │─────────▶│ Cache │──▶│ Database│           │
│  └─────────┘          └───────┘   └─────────┘           │
│  • Application manages cache                              │
│  • Good for: Read-heavy workloads                         │
│                                                             │
│  Read-Through                                              │
│  ┌─────────┐   ┌───────────┐   ┌─────────┐              │
│  │ Client  │──▶│  Cache    │──▶│ Database│              │
│  └─────────┘   │ (read-only)│   └─────────┘              │
│                └───────────┘                              │
│  • Cache handles misses                                   │
│  • Good for: Consistent caching                           │
│                                                             │
│  Write-Through                                             │
│  ┌─────────┐   ┌───────────┐   ┌─────────┐              │
│  │ Client  │──▶│  Cache    │──▶│ Database│              │
│  └─────────┘   │ (write)   │   └─────────┘              │
│                └───────────┘                              │
│  • Cache writes to DB synchronously                      │
│  • Good for: Data consistency                            │
│                                                             │
│  Write-Behind (Write-Back)                                 │
│  ┌─────────┐   ┌───────────┐   ┌─────────┐              │
│  │ Client  │──▶│  Cache    │──▶│ Database│              │
│  └─────────┘   │ (write)   │   └─────────┘              │
│                └───────────┘                              │
│  • Cache writes to DB asynchronously                     │
│  • Good for: Write-heavy, acceptable latency             │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Replication Models

| Model | Description | Pros | Cons | Use Case |
|-------|-------------|------|------|----------|
| **Leader-Follower** | One leader, many followers | Simple, consistent | Single point of failure | RDBMS, most databases |
| **Multi-Leader** | Multiple leaders | High availability, local writes | Conflict resolution | Global applications |
| **Leaderless** | All nodes accept writes | High availability | Complexity, eventual consistency | Cassandra, DynamoDB |

---

## 8. Partitioning (Sharding) Strategies

| Strategy | Description | Example | Best For |
|----------|-------------|---------|----------|
| **Range** | Partition by value range | Date ranges | Time-series data |
| **Hash** | Partition by hash of key | Customer ID hash | Even distribution |
| **List** | Partition by explicit values | Country codes | Geographic data |
| **Composite** | Combination of strategies | (date, region) | Complex workloads |

### Consistent Hashing

```
┌─────────────────────────────────────────────────────────────┐
│                    CONSISTENT HASH RING                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                      [Node1]                                │
│                    ╱         ╲                              │
│                  ╱             ╲                            │
│                ╱                 ╲                          │
│              ╱                     ╲                        │
│            ╱                         ╲                      │
│      [Node4]                           [Node2]             │
│            ╲                         ╱                      │
│              ╲                     ╱                        │
│                ╲                 ╱                          │
│                  ╲             ╱                            │
│                    ╲         ╱                              │
│                      [Node3]                                │
│                                                             │
│  • Keys map to nodes on the ring                           │
│  • Adding/removing nodes minimizes rebalancing             │
│  • Virtual nodes improve distribution                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 9. Disaster Recovery Terminology

| Term | Definition | Example |
|------|------------|---------|
| **RPO** (Recovery Point Objective) | Maximum acceptable data loss | 15 minutes |
| **RTO** (Recovery Time Objective) | Maximum acceptable downtime | 1 hour |
| **Backup** | Point-in-time copy of data | Daily full backup |
| **Replication** | Continuous copy of data | Sync to DR region |
| **Failover** | Switch to backup system | Automatic or manual |
| **Fallback** | Switch back to primary | After recovery |

---

## 10. Data Quality Dimensions

| Dimension | Definition | Metric |
|-----------|------------|--------|
| **Completeness** | All required data present | % of missing values |
| **Accuracy** | Data reflects real world | Error rate |
| **Consistency** | Data is consistent across systems | Conflict rate |
| **Timeliness** | Data is up-to-date | Age of data |
| **Uniqueness** | No duplicate records | Duplicate rate |
| **Validity** | Data conforms to format | Validation pass rate |

---

## 11. Security Best Practices

### Data Classification

| Level | Description | Examples | Protection |
|-------|-------------|----------|------------|
| **Public** | No restrictions | Public website data | Minimal |
| **Internal** | Company-wide access | Org charts, internal reports | Internal only |
| **Confidential** | Restricted access | Customer PII, financials | Encryption, access control |
| **Restricted** | Highly sensitive | Health records, classified | Strong encryption, strict control |

### Security Controls

1. **Encryption at Rest**: AES-256 for stored data
2. **Encryption in Transit**: TLS 1.2+ for data in motion
3. **Access Control**: RBAC, least privilege
4. **Audit Logging**: Track all access and changes
5. **Data Masking**: Hide sensitive data in non-production
6. **Key Management**: Rotate keys regularly

---

## 12. Performance Optimization Checklist

### Query Optimization
- [ ] Use indexes on WHERE clauses
- [ ] Avoid SELECT * - select only needed columns
- [ ] Use LIMIT for large result sets
- [ ] Avoid functions in WHERE clauses
- [ ] Use EXPLAIN to analyze query plans
- [ ] Partition large tables
- [ ] Use materialized views for complex queries

### Storage Optimization
- [ ] Use columnar formats for analytics (Parquet/ORC)
- [ ] Compress data (Snappy, Zstd, Gzip)
- [ ] Partition data by date or key
- [ ] Handle small files (coalesce/compact)
- [ ] Use appropriate data types
- [ ] Archive old data

### Caching Optimization
- [ ] Cache frequent queries
- [ ] Use appropriate TTL
- [ ] Monitor cache hit ratio
- [ ] Use distributed cache for scaling
- [ ] Warm cache for critical queries

### Infrastructure Optimization
- [ ] Right-size instances
- [ ] Use auto-scaling
- [ ] Separate compute from storage
- [ ] Use spot instances for non-critical workloads
- [ ] Monitor resource utilization

---

## 13. Common SQL Patterns

### Window Functions
```sql
-- Running total
SELECT 
    date,
    sales,
    SUM(sales) OVER (ORDER BY date) as cumulative_sales
FROM daily_sales;

-- Ranking
SELECT 
    product,
    sales,
    RANK() OVER (ORDER BY sales DESC) as sales_rank
FROM products;

-- Moving average
SELECT 
    date,
    sales,
    AVG(sales) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_7day
FROM daily_sales;
```

### CTEs (Common Table Expressions)
```sql
WITH daily_avg AS (
    SELECT 
        customer_id,
        DATE(order_date) as order_day,
        AVG(amount) as avg_daily_amount
    FROM orders
    GROUP BY customer_id, DATE(order_date)
),
customer_stats AS (
    SELECT
        customer_id,
        AVG(avg_daily_amount) as avg_order_value
    FROM daily_avg
    GROUP BY customer_id
)
SELECT *
FROM customer_stats
WHERE avg_order_value > 100;
```

### Date/Time Queries
```sql
-- Last 7 days
SELECT * FROM table 
WHERE created_at >= NOW() - INTERVAL '7 days';

-- Month to date
SELECT * FROM table 
WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', NOW());

-- Year over year comparison
SELECT 
    DATE_TRUNC('month', created_at) as month,
    SUM(amount) as revenue
FROM orders
WHERE DATE_PART('year', created_at) = DATE_PART('year', NOW()) - 1
GROUP BY month;
```

---

## 14. Architecture Decision Checklist

When making architectural decisions, consider:

### Business Requirements
- [ ] What are the SLAs? (RPO, RTO, availability)
- [ ] What is the data volume and velocity?
- [ ] What are the security and compliance requirements?
- [ ] Who are the users and what are their needs?
- [ ] What is the budget and cost constraints?

### Technical Requirements
- [ ] What are the data sources and sinks?
- [ ] What are the latency requirements?
- [ ] What are the scalability requirements?
- [ ] What are the integration requirements?
- [ ] What is the team's expertise?

### Trade-offs to Consider
- Cost vs. Performance
- Speed vs. Accuracy
- Simplicity vs. Flexibility
- Consistency vs. Availability
- Time-to-Market vs. Long-term Maintainability

---

## 15. Quick Command Reference

### Docker
```bash
# Start services
docker-compose up -d

# Check services
docker-compose ps

# View logs
docker-compose logs -f [service]

# Restart service
docker-compose restart [service]

# Stop services
docker-compose down

# Clean up
docker-compose down -v
```

### PostgreSQL
```bash
# Connect
psql -U dataarch -d dataarch -h localhost

# Show databases
\l

# Show tables
\dt

# Describe table
\d table_name

# Show query plan
EXPLAIN ANALYZE SELECT * FROM table;

# Run SQL file
\i file.sql
```

### Kafka
```bash
# List topics
kafka-topics --bootstrap-server localhost:9092 --list

# Create topic
kafka-topics --bootstrap-server localhost:9092 \
    --create --topic my-topic \
    --partitions 3 --replication-factor 1

# Produce messages
kafka-console-producer --bootstrap-server localhost:9092 \
    --topic my-topic

# Consume messages
kafka-console-consumer --bootstrap-server localhost:9092 \
    --topic my-topic --from-beginning

# Describe topic
kafka-topics --bootstrap-server localhost:9092 \
    --describe --topic my-topic
```

### Redis
```bash
# Connect
redis-cli -h localhost -p 6379

# Set key
SET key "value"

# Get key
GET key

# Set with TTL
SETEX key 60 "value"

# Check TTL
TTL key

# Delete key
DEL key

# Monitor
MONITOR
```

### MinIO (mc)
```bash
# Add host
mc alias set myminio http://localhost:9000 minioadmin minioadmin123

# List buckets
mc ls myminio

# Create bucket
mc mb myminio/new-bucket

# Copy files
mc cp file.txt myminio/bucket/

# List objects
mc ls myminio/bucket/

# Delete object
mc rm myminio/bucket/file.txt
```

---

## 16. Essential Glossary

| Term | Definition |
|------|------------|
| **ACID** | Atomicity, Consistency, Isolation, Durability |
| **BASE** | Basically Available, Soft state, Eventually consistent |
| **CDC** | Change Data Capture |
| **CRUD** | Create, Read, Update, Delete |
| **DAG** | Directed Acyclic Graph |
| **Data Lake** | Raw data storage |
| **Data Warehouse** | Curated, structured storage |
| **DSAR** | Data Subject Access Request |
| **ETL** | Extract, Transform, Load |
| **ELT** | Extract, Load, Transform |
| **GDPR** | General Data Protection Regulation |
| **HA** | High Availability |
| **HDFS** | Hadoop Distributed File System |
| **KPI** | Key Performance Indicator |
| **Lakehouse** | Data lake + ACID transactions |
| **LSM Tree** | Log-Structured Merge Tree |
| **MDM** | Master Data Management |
| **MVCC** | Multi-Version Concurrency Control |
| **OLAP** | Online Analytical Processing |
| **OLTP** | Online Transaction Processing |
| **RAG** | Retrieval-Augmented Generation |
| **RPO** | Recovery Point Objective |
| **RTO** | Recovery Time Objective |
| **SLA** | Service Level Agreement |
| **SLO** | Service Level Objective |
| **2PC** | Two-Phase Commit |
| **3PC** | Three-Phase Commit |

---

## 17. Architecture Decision Patterns

### When to Use What

| Scenario | Recommended Approach |
|----------|---------------------|
| **Transactional data, ACID required** | RDBMS (PostgreSQL, MySQL) |
| **High volume writes, eventual consistency** | Cassandra, DynamoDB |
| **Analytics on structured data** | Data warehouse (Snowflake, Redshift) |
| **Analytics on diverse data** | Data lake + Lakehouse (Delta Lake) |
| **Real-time event streaming** | Kafka + Flink |
| **Batch processing** | Spark, Airflow |
| **Caching, session storage** | Redis, Memcached |
| **Search** | Elasticsearch |
| **ML feature management** | Feature store |
| **Vector similarity search** | Vector database |
| **BI dashboards** | Superset, Tableau, PowerBI |
| **Data governance** | Data catalog + Quality framework |

---

## 18. Cost Optimization Tips

### Storage Optimization
- **Tiered Storage**: Hot → Warm → Cold → Archive
- **Compression**: Use columnar formats with compression
- **Partitioning**: Partition by date for easier data lifecycle
- **Lifecycle Policies**: Automatically move/delete old data
- **Deduplication**: Remove duplicate data

### Compute Optimization
- **Right-size instances**: Don't over-provision
- **Auto-scaling**: Scale based on demand
- **Spot instances**: Use for non-critical workloads
- **Serverless**: Use when possible (BigQuery, Snowflake)
- **Reserved instances**: For steady-state workloads

### Query Optimization
- **Caching**: Cache frequent queries
- **Materialized views**: Pre-compute expensive queries
- **Indexes**: Proper indexing reduces query cost
- **Pushdown**: Push filters to storage layer
- **Partition pruning**: Query only relevant partitions

---

*This cheat sheet is your companion for the entire Mastering Modern Data Architecture series. Keep it handy for quick reference during your learning journey.*
