# Primer 3: Getting Started with the Data Architecture Project

Welcome to the **Getting Started Guide** for the Mastering Modern Data Architecture project. This primer walks you through setting up your development environment, cloning the project, and running your first data pipeline. Think of this as your "first 15 minutes" - everything you need to start building.

---

## 1. Quick Start: 5-Minute Setup

### Prerequisites

Before you begin, ensure you have:

```
✓ Docker & Docker Compose (20.10+)
✓ Git (2.30+)
✓ Python 3.9+
✓ 8GB+ RAM (16GB recommended)
✓ 20GB+ free disk space
```

### One-Command Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/data-architecture-tutorial.git
cd data-architecture-tutorial

# Copy environment configuration
cp .env.example .env

# Run the automated setup script
chmod +x setup.sh
./setup.sh

# Start all services
docker-compose up -d

# Verify everything is running
python scripts/verify_environment.py
```

**Expected output:**
```
==========================================
ENVIRONMENT VERIFICATION
==========================================

🔍 Checking services...

   📊 Checking postgres...
      Port 5432: ✅
      Container: ✅
      Connection: ✅
   ✅ postgres is ready

   📊 Checking minio...
      Port 9000: ✅
      Container: ✅
      Connection: ✅
   ✅ minio is ready

... [all services passing]

==========================================
VERIFICATION SUMMARY
==========================================

   Services passed: 12/12

   🎉 All services are ready!
   You can proceed with the tutorial.
```

---

## 2. Project Structure Overview

```
data-architecture-tutorial/
│
├── part-00-introduction/          # Series overview
├── part-01-foundations/           # Data modeling
├── part-02-storage-engines/       # Storage internals
├── part-03-enterprise-storage/    # Storage architecture
├── part-04-object-storage/        # Object storage
├── part-05-data-formats/          # Parquet, ORC, Avro
├── part-06-transactions/          # ACID, 2PC, Saga
├── part-07-data-integration/      # ETL, Kafka, Airflow
├── part-08-scalability/           # Scaling, replication
├── part-09-caching/               # Redis, caching patterns
├── part-10-lakehouses/            # Delta Lake, Iceberg
├── part-11-data-hubs/             # Data Mesh, Data Hub
├── part-12-metadata-governance/   # Metadata, governance
├── part-13-bi-analytics/          # BI, dashboards
├── part-14-ml-data-architecture/  # Feature store, RAG
├── part-15-enterprise-platform/   # Reference architecture
│
├── utils/                         # Shared utilities
│   ├── data_utils.py
│   ├── db_utils.py
│   └── performance_utils.py
│
├── config/                        # Configuration
│   ├── default.yaml
│   ├── development.yaml
│   ├── production.yaml
│   └── config_loader.py
│
├── tests/                         # Test suite
│   ├── test_data_utils.py
│   ├── test_cache.py
│   └── test_integration.py
│
├── deployment/                    # Deployment files
│   ├── terraform/
│   ├── kubernetes/
│   └── ci-cd/
│
├── docker-compose.yml            # All services
├── .env                          # Environment variables
├── setup.sh                      # Automated setup
├── requirements.txt              # Python dependencies
└── README.md                     # Project documentation
```

---

## 3. Service URLs and Credentials

After running `docker-compose up -d`, you'll have access to:

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| **PostgreSQL** | `localhost:5432` | user: `dataarch`, pass: `dataarch123` | Transactional database |
| **MinIO Console** | `http://localhost:9001` | user: `minioadmin`, pass: `minioadmin123` | Object storage UI |
| **MinIO API** | `http://localhost:9000` | user: `minioadmin`, pass: `minioadmin123` | S3-compatible API |
| **Kafka** | `localhost:9092` | (none) | Message streaming |
| **Redis** | `localhost:6379` | (none) | Caching |
| **Airflow** | `http://localhost:8081` | user: `admin`, pass: `admin123` | Pipeline orchestration |
| **Superset** | `http://localhost:8088` | user: `admin`, pass: `admin123` | BI platform |
| **Grafana** | `http://localhost:3000` | user: `admin`, pass: `admin123` | Monitoring |
| **Prometheus** | `http://localhost:9090` | (none) | Metrics |
| **Jupyter** | `http://localhost:8888` | token: `dataarch123` | Notebooks |
| **Amundsen** | `http://localhost:5000` | user: `admin`, pass: `admin123` | Data catalog |
| **Great Expectations** | `http://localhost:8082` | (none) | Data quality |

---

## 4. Your First Data Pipeline

### Step 1: Verify the Database

```bash
# Connect to PostgreSQL
docker exec -it dataarch_postgres psql -U dataarch -d dataarch

# Check tables
\dt

# Expected output: List of tables including customers, products, orders
```

### Step 2: Run Your First ETL Pipeline

```bash
# Navigate to Part 1
cd part-01-foundations

# Run the verification script
python scripts/verify_setup.py

# Expected output:
# ✅ Database connection successful
# ✅ All required tables exist
# ✅ Sample data inserted successfully
# 🎉 Part 1 setup is ready!
```

### Step 3: Query Your Data

```bash
# Run a sample query
docker exec -i dataarch_postgres psql -U dataarch -d dataarch << EOF
SELECT 
    c.email,
    COUNT(o.order_id) as order_count,
    COALESCE(SUM(o.total_amount), 0) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.email;
EOF

# Expected output:
#      email      | order_count | total_spent 
# ----------------+-------------+-------------
# john.doe@...    |           0 |        0.00
# jane.smith@...  |           0 |        0.00
# bob.wilson@...  |           0 |        0.00
```

### Step 4: Explore the Data Lake

```bash
# List MinIO buckets
docker exec dataarch_minio mc ls local/

# Expected output:
# [2024-01-01 00:00:00 UTC]     0B data-lake/
# [2024-01-01 00:00:00 UTC]     0B data-lake-archive/
# [2024-01-01 00:00:00 UTC]     0B staging/
# [2024-01-01 00:00:00 UTC]     0B processed/
```

### Step 5: Upload Data to the Data Lake

```bash
# Create a sample file
echo '{"name": "sample_data", "value": 100}' > sample.json

# Upload to MinIO
docker exec -i dataarch_minio mc cp sample.json local/data-lake/sample.json

# Verify upload
docker exec dataarch_minio mc ls local/data-lake/
```

---

## 5. Running the Tutorial Notebooks

### Jupyter Notebooks

```bash
# Access Jupyter
# Open http://localhost:8888 in your browser
# Token: dataarch123

# Navigate to work/part-01-foundations/
# Open the Jupyter notebook for Part 1
```

### Python Interactive Sessions

```bash
# Activate virtual environment
source venv/bin/activate

# Start Python
python

# Import utilities
>>> from utils.data_utils import DataUtils
>>> DataUtils.validate_email("test@example.com")
True

# Connect to database
>>> import psycopg2
>>> conn = psycopg2.connect(
...     host='localhost',
...     database='dataarch',
...     user='dataarch',
...     password='dataarch123'
... )
>>> conn.closed
0
```

---

## 6. Common Troubleshooting

### Docker Services Won't Start

```bash
# Check logs
docker-compose logs --tail=50

# Check port conflicts
sudo lsof -i :5432  # PostgreSQL
sudo lsof -i :9000  # MinIO

# Reset and restart
docker-compose down -v
docker-compose up -d
```

### Database Connection Failed

```bash
# Wait for initialization
docker-compose logs postgres | grep "ready to accept connections"

# Reset database
docker-compose down -v
docker-compose up -d postgres
docker-compose exec postgres psql -U dataarch -d dataarch -f /docker-entrypoint-initdb.d/01-init.sql
```

### MinIO Connection Failed

```bash
# Check MinIO status
docker-compose logs minio

# Reset MinIO
docker-compose down -v
docker-compose up -d minio minio-init
```

### Permission Issues

```bash
# Fix permissions
sudo chown -R $USER:$USER .

# Ensure scripts are executable
chmod +x setup.sh
chmod +x scripts/*.py
```

---

## 7. Development Workflow

### Daily Workflow

```bash
# 1. Start services
docker-compose up -d

# 2. Check services
docker-compose ps

# 3. Activate environment
source venv/bin/activate

# 4. Run tests
pytest tests/

# 5. Work on a part
cd part-XX-part-name/

# 6. Run verification
python scripts/verify_setup.py

# 7. Stop services
docker-compose down
```

### Making Changes

```bash
# 1. Create a branch
git checkout -b feature/my-feature

# 2. Make changes
# Edit files in your IDE

# 3. Run tests
pytest tests/ -v

# 4. Format code
black .

# 5. Commit changes
git add .
git commit -m "Description of changes"

# 6. Push
git push origin feature/my-feature
```

---

## 8. Essential Commands Reference

### Docker Management

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d postgres

# Stop all services
docker-compose down

# View logs
docker-compose logs -f [service]

# Execute command in container
docker exec -it dataarch_postgres bash

# Check resource usage
docker stats
```

### Database Operations

```bash
# PostgreSQL
docker exec -it dataarch_postgres psql -U dataarch -d dataarch

# MySQL
docker exec -it dataarch_mysql mysql -u dataarch -p dataarch

# MongoDB
docker exec -it dataarch_mongodb mongosh -u root -p root123

# Redis
docker exec -it dataarch_redis redis-cli
```

### Data Processing

```bash
# Run Python script
python script.py

# Run Jupyter
jupyter notebook

# Run tests
pytest tests/ -v

# Run with coverage
pytest --cov=. tests/
```

---

## 9. Next Steps After Setup

### Complete These in Order

1. **Read Part 0**: Introduction and architecture overview
2. **Complete Part 1**: Build your first data model
3. **Follow the Series**: Progress through all 15 parts
4. **Explore the Appendices**: Deep dive into specific topics
5. **Build Your Own Project**: Apply what you've learned

### Recommended Learning Path

```
Week 1-2: Parts 0-3 (Foundations)
    → Understand data architecture fundamentals
    → Build your first data models
    → Learn storage engine internals

Week 3-4: Parts 4-6 (Storage & Transactions)
    → Work with object storage
    → Master data formats (Parquet, ORC)
    → Implement ACID transactions

Week 5-6: Parts 7-9 (Integration & Performance)
    → Build data pipelines (ETL, Kafka)
    → Implement scaling strategies
    → Master caching patterns

Week 7-8: Parts 10-12 (Analytics & Governance)
    → Build a lakehouse
    → Implement data governance
    → Set up metadata management

Week 9-10: Parts 13-15 (BI, ML & Platform)
    → Build BI dashboards
    → Implement ML architecture
    → Design enterprise platform
```

---

## 10. Getting Help

### Documentation
- **Inline Code Comments**: Every file has detailed comments
- **README Files**: Each part has its own README
- **Appendix Reference**: Complete reference materials

### Common Resources
- **Stack Overflow**: Tag your questions with #data-architecture
- **GitHub Issues**: Report bugs and request features
- **Community Discussion**: Join our Discord/Slack community

### Troubleshooting Flow

```
1. Check Services: docker-compose ps
2. Check Logs: docker-compose logs [service]
3. Verify Configuration: .env file
4. Run Verification: python scripts/verify_environment.py
5. Reset Services: docker-compose down -v && docker-compose up -d
6. Search Documentation: inline comments, READMEs
7. Ask for Help: community channels
```

---

## 11. Quick Success Checklist

✅ Docker and Docker Compose installed  
✅ Services starting without errors  
✅ All health checks passing  
✅ Database connections working  
✅ MinIO buckets created  
✅ Sample data loaded  
✅ Verification script passes  
✅ Environment variables configured  
