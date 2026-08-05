# Part 4 — Modern Data Architectures Beyond SQL

## Choosing the Right Database for the Right Problem

---

### Introduction to Part 4

Welcome to the final phase of our journey. In Parts 1-3, we built a robust, fast, and transaction-safe relational database for ScaleCart. Now we expand our architecture to embrace the diversity of modern data workloads.

Relational databases are powerful—but they are not the answer to every problem. This part teaches you how to combine multiple data technologies into a cohesive, scalable architecture.

We will cover:

1. **NoSQL Decision Framework** – When to use document stores, key-value stores, and wide-column databases.
2. **Graph Databases** – Modeling highly connected data for recommendations and social networks.
3. **Emerging Database Technologies** – Time-series, event data, and vector databases for AI.
4. **Distributed Data Systems** – Eventual consistency, CAP theorem, Sagas, and the Transactional Outbox pattern.

By the end, you'll have a hybrid, polyglot persistence architecture that leverages the best database for each workload.

**Estimated time:** 5-7 hours.

---

## Section 4.1 – NoSQL Decision Framework

### 4.1.1 The Target

We'll evaluate where NoSQL databases fit in the ScaleCart architecture and implement MongoDB for product catalog caching and session management.

### 4.1.2 The Concept – When to Go Beyond SQL

**Analogy:** Imagine you have a toolbox. A relational database is your hammer—great for many tasks, but you wouldn't use it to tighten a screw. NoSQL databases are specialized tools for specific jobs.

**NoSQL Categories:**

| Category | Examples | Best For | Trade-offs |
|----------|----------|----------|------------|
| **Document Stores** | MongoDB, Couchbase | Flexible schemas, JSON data, hierarchical data | Less query power, eventual consistency |
| **Key-Value Stores** | Redis, DynamoDB | Caching, session storage, simple lookups | No complex queries, limited indexing |
| **Wide-Column Stores** | Cassandra, HBase | Time-series, high-volume writes, large-scale | Complex operations, eventual consistency |
| **Search Engines** | Elasticsearch | Full-text search, log analytics | Not a primary data store |

### 4.1.3 ScaleCart's NoSQL Use Cases

| Use Case | Why SQL Fails | NoSQL Solution |
|----------|---------------|----------------|
| **Product catalog cache** | Frequent reads, high load, flexible attributes | MongoDB (document store) |
| **Shopping cart session** | Temporary data, high write throughput | Redis (key-value) |
| **Analytics and events** | High-volume append-only logs | Elasticsearch or TimescaleDB |
| **Social recommendations** | Complex graph relationships | Neo4j (graph database) |
| **AI similarity search** | Vector operations not efficient in SQL | pgvector or specialized vector DB |

### 4.1.4 Implementing MongoDB for Product Catalog Cache

**Setup MongoDB:**

```yaml
# docker-compose.yml (add to existing)
mongodb:
  image: mongo:7.0
  container_name: scalecart_mongodb
  environment:
    MONGO_INITDB_ROOT_USERNAME: scalecart
    MONGO_INITDB_ROOT_PASSWORD: scalecart_password
    MONGO_INITDB_DATABASE: scalecart
  ports:
    - "27017:27017"
  volumes:
    - mongodb_data:/data/db
```

**Python connection and model:**

```python
# File: src/services/catalog_cache.py
"""
MongoDB cache for product catalog.
Reduces load on PostgreSQL for frequent product reads.
"""

import pymongo
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import json

class CatalogCache:
    def __init__(self, connection_string: str):
        self.client = pymongo.MongoClient(connection_string)
        self.db = self.client.scalecart
        self.cache_collection = self.db.product_cache
        # Create TTL index for automatic expiry
        self.cache_collection.create_index(
            "created_at", 
            expireAfterSeconds=3600  # 1 hour
        )

    def get_product(self, product_id: int) -> Optional[Dict[str, Any]]:
        """Retrieve product from cache, or return None if not found."""
        result = self.cache_collection.find_one({"_id": product_id})
        if result:
            # Remove internal fields
            result.pop("created_at", None)
            return result
        return None

    def set_product(self, product: Dict[str, Any]) -> None:
        """Store product in cache with expiry."""
        product["_id"] = product.pop("id")  # Rename id to _id for MongoDB
        product["created_at"] = datetime.utcnow()
        self.cache_collection.update_one(
            {"_id": product["_id"]},
            {"$set": product},
            upsert=True
        )

    def get_products_by_category(self, category_id: int) -> List[Dict[str, Any]]:
        """Get all products in a category from cache."""
        cursor = self.cache_collection.find({"category_id": category_id})
        return list(cursor)

    def invalidate_product(self, product_id: int) -> None:
        """Remove product from cache."""
        self.cache_collection.delete_one({"_id": product_id})

    def invalidate_category(self, category_id: int) -> None:
        """Remove all products in a category from cache."""
        self.cache_collection.delete_many({"category_id": category_id})

    def warm_cache(self, product_ids: List[int]) -> None:
        """
        Preload products into cache.
        In production, this would read from PostgreSQL.
        """
        # This would query PostgreSQL and load into MongoDB
        # Implementation depends on PostgreSQL connection
        pass

    def get_or_load(self, product_id: int, load_function) -> Dict[str, Any]:
        """
        Get from cache, or load using the provided function if missing.
        """
        product = self.get_product(product_id)
        if product:
            return product
        
        # Load from source (PostgreSQL)
        product = load_function(product_id)
        if product:
            self.set_product(product)
            return product
        raise ValueError(f"Product {product_id} not found")
```

**Using the cache in the product service:**

```python
# File: src/services/product_service.py
from src.services.catalog_cache import CatalogCache
import psycopg2

class ProductService:
    def __init__(self, pg_conn, mongo_uri: str):
        self.pg = pg_conn
        self.cache = CatalogCache(mongo_uri)

    def get_product(self, product_id: int) -> dict:
        """Get product with caching."""
        # Try cache first
        cached = self.cache.get_product(product_id)
        if cached:
            return cached

        # Fall back to PostgreSQL
        with self.pg.cursor() as cur:
            cur.execute(
                "SELECT id, name, description, price, category_id, created_at "
                "FROM products WHERE id = %s",
                (product_id,)
            )
            product = cur.fetchone()
            if not product:
                raise ValueError(f"Product {product_id} not found")

            product_dict = {
                "id": product[0],
                "name": product[1],
                "description": product[2],
                "price": float(product[3]),
                "category_id": product[4],
                "created_at": product[5].isoformat()
            }

        # Store in cache
        self.cache.set_product(product_dict)
        return product_dict

    def update_product(self, product_id: int, updates: dict) -> dict:
        """Update product and invalidate cache."""
        with self.pg:
            with self.pg.cursor() as cur:
                # Build update query dynamically
                set_clause = ", ".join([f"{k} = %s" for k in updates.keys()])
                values = list(updates.values()) + [product_id]
                cur.execute(
                    f"UPDATE products SET {set_clause}, updated_at = CURRENT_TIMESTAMP "
                    "WHERE id = %s RETURNING *",
                    values
                )
                product = cur.fetchone()
                if not product:
                    raise ValueError(f"Product {product_id} not found")

        # Invalidate cache
        self.cache.invalidate_product(product_id)
        
        # Return updated product (would fetch from PostgreSQL)
        return self.get_product(product_id)
```

### 4.1.5 Implementing Redis for Session and Cart Management

**Setup Redis:**

```yaml
# docker-compose.yml
redis:
  image: redis:7-alpine
  container_name: scalecart_redis
  ports:
    - "6379:6379"
  command: redis-server --requirepass scalecart_password
```

**Python Redis Session Manager:**

```python
# File: src/services/session_manager.py
import redis
import json
import uuid
from typing import Optional, Dict, Any
from datetime import timedelta

class SessionManager:
    def __init__(self, redis_host: str, redis_port: int, redis_password: str):
        self.redis = redis.Redis(
            host=redis_host,
            port=redis_port,
            password=redis_password,
            decode_responses=True
        )
        self.session_ttl = 3600 * 24  # 24 hours

    def create_session(self, customer_id: int, data: Optional[Dict] = None) -> str:
        """Create a new session and return session_id."""
        session_id = str(uuid.uuid4())
        session_data = {
            "customer_id": customer_id,
            "created_at": str(datetime.utcnow()),
            "data": data or {}
        }
        self.redis.setex(
            f"session:{session_id}",
            self.session_ttl,
            json.dumps(session_data)
        )
        return session_id

    def get_session(self, session_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve session data."""
        data = self.redis.get(f"session:{session_id}")
        if data:
            return json.loads(data)
        return None

    def update_session(self, session_id: str, data: Dict[str, Any]) -> bool:
        """Update session data."""
        session = self.get_session(session_id)
        if not session:
            return False
        
        session["data"].update(data)
        session["updated_at"] = str(datetime.utcnow())
        self.redis.setex(
            f"session:{session_id}",
            self.session_ttl,
            json.dumps(session)
        )
        return True

    def delete_session(self, session_id: str) -> None:
        """Invalidate session."""
        self.redis.delete(f"session:{session_id}")

    def get_cart(self, session_id: str) -> Dict[str, Any]:
        """Get shopping cart from session data."""
        session = self.get_session(session_id)
        if not session:
            return {"items": [], "total": 0.0}
        return session["data"].get("cart", {"items": [], "total": 0.0})

    def add_to_cart(self, session_id: str, product_id: int, quantity: int) -> Dict[str, Any]:
        """Add item to cart and update session."""
        session = self.get_session(session_id)
        if not session:
            raise ValueError("Session not found")

        cart = session["data"].get("cart", {"items": [], "total": 0.0})
        
        # Check if product already in cart
        for item in cart["items"]:
            if item["product_id"] == product_id:
                item["quantity"] += quantity
                break
        else:
            cart["items"].append({
                "product_id": product_id,
                "quantity": quantity,
                "price": 0.0  # Will be filled by product service
            })

        # Recalculate total (will be done by service)
        self.update_session(session_id, {"cart": cart})
        return cart

    def clear_cart(self, session_id: str) -> None:
        """Empty the cart."""
        session = self.get_session(session_id)
        if session:
            session["data"]["cart"] = {"items": [], "total": 0.0}
            self.update_session(session_id, session["data"])
```

---

## Section 4.2 – Graph Databases

### 4.2.1 The Target

We'll implement Neo4j for ScaleCart's recommendation engine and social features.

### 4.2.2 The Concept – Modeling Relationships as First-Class Citizens

**Analogy:** In SQL, relationships are like addresses on envelopes—you need to know the address to find the connection. In a graph database, relationships are like a web of interconnected strings—you can follow them naturally to discover patterns.

**Graph Database Concepts:**
- **Nodes** – Entities (Customer, Product, Category).
- **Relationships** – Connections between nodes (BOUGHT, VIEWED, RECOMMENDS).
- **Properties** – Attributes on nodes and relationships.

**When to use Graph Databases:**
- Social networks (follows, friends, connections).
- Recommendation engines (users who bought X also bought Y).
- Identity and access management (roles, permissions, hierarchies).
- Fraud detection (patterns of connections).

### 4.2.3 Setup Neo4j

```yaml
# docker-compose.yml
neo4j:
  image: neo4j:5-enterprise
  container_name: scalecart_neo4j
  environment:
    NEO4J_AUTH: neo4j/scalecart_neo4j_password
    NEO4J_ACCEPT_LICENSE_AGREEMENT: "yes"
  ports:
    - "7474:7474"   # HTTP
    - "7687:7687"   # Bolt (Python driver)
  volumes:
    - neo4j_data:/data
```

**Python driver setup:**

```bash
pip install neo4j
```

### 4.2.4 Neo4j Schema for Recommendations

```cypher
-- File: src/scripts/neo4j_schema.cql
-- Create constraints
CREATE CONSTRAINT IF NOT EXISTS FOR (c:Customer) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Product) REQUIRE p.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (cat:Category) REQUIRE cat.id IS UNIQUE;

-- Create indexes
CREATE INDEX IF NOT EXISTS FOR (p:Product) ON p.name;
CREATE INDEX IF NOT EXISTS FOR (c:Customer) ON c.email;
```

**Python graph service:**

```python
# File: src/services/graph_service.py
from neo4j import GraphDatabase, AsyncGraphDatabase
from typing import List, Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)

class GraphService:
    def __init__(self, uri: str, user: str, password: str):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self.driver.close()

    def record_purchase(self, customer_id: int, product_id: int, order_id: int):
        """
        Record that a customer purchased a product.
        Creates or updates relationships for recommendations.
        """
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH (c:Customer {id: $customer_id})
                MATCH (p:Product {id: $product_id})
                MERGE (c)-[r:BOUGHT {order_id: $order_id}]->(p)
                ON CREATE SET r.purchased_at = datetime()
                ON MATCH SET r.purchased_at = datetime()
                RETURN c, p
                """,
                customer_id=customer_id,
                product_id=product_id,
                order_id=order_id
            )
            logger.info(f"Recorded purchase: Customer {customer_id} -> Product {product_id}")
            return result.single()

    def record_view(self, customer_id: int, product_id: int):
        """Record that a customer viewed a product."""
        with self.driver.session() as session:
            session.run(
                """
                MATCH (c:Customer {id: $customer_id})
                MATCH (p:Product {id: $product_id})
                MERGE (c)-[r:VIEWED]->(p)
                ON CREATE SET r.viewed_at = datetime()
                ON MATCH SET r.viewed_at = datetime()
                """,
                customer_id=customer_id,
                product_id=product_id
            )

    def get_recommendations(self, customer_id: int, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Get product recommendations for a customer based on:
        1. Products bought by customers who bought similar products (collaborative filtering)
        2. Products in the same categories as previously purchased products
        """
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH (c:Customer {id: $customer_id})
                // Find products that other customers bought along with similar products
                MATCH (c)-[:BOUGHT]->(p:Product)
                MATCH (p)<-[:BOUGHT]-(other:Customer)-[:BOUGHT]->(recommended:Product)
                WHERE NOT (c)-[:BOUGHT]->(recommended)
                WITH recommended, COUNT(DISTINCT other) AS score
                // Also consider products in same categories
                MATCH (recommended)-[:IN_CATEGORY]->(cat:Category)
                MATCH (p)-[:IN_CATEGORY]->(cat)
                WHERE NOT (c)-[:BOUGHT]->(recommended)
                WITH recommended, score + 0.5 AS weighted_score
                // Include products recently viewed but not bought
                OPTIONAL MATCH (c)-[:VIEWED]->(viewed:Product)
                WHERE viewed.id = recommended.id
                WITH recommended, weighted_score + 
                    CASE WHEN viewed IS NOT NULL THEN 0.3 ELSE 0 END AS final_score
                RETURN recommended.id AS product_id,
                       recommended.name AS name,
                       recommended.price AS price,
                       final_score
                ORDER BY final_score DESC
                LIMIT $limit
                """,
                customer_id=customer_id,
                limit=limit
            )
            return [{
                "product_id": record["product_id"],
                "name": record["name"],
                "price": record["price"],
                "score": record["final_score"]
            } for record in result]

    def get_collaborative_recommendations(self, customer_id: int) -> List[int]:
        """
        Pure collaborative filtering: customers who bought similar items.
        """
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH (c:Customer {id: $customer_id})-[:BOUGHT]->(p:Product)<-[:BOUGHT]-(other:Customer)
                MATCH (other)-[:BOUGHT]->(rec:Product)
                WHERE NOT (c)-[:BOUGHT]->(rec)
                RETURN rec.id AS product_id, COUNT(*) AS frequency
                ORDER BY frequency DESC
                LIMIT 20
                """,
                customer_id=customer_id
            )
            return [record["product_id"] for record in result]

    def get_social_graph(self, customer_id: int, depth: int = 2) -> Dict[str, Any]:
        """
        Get social network recommendations:
        Friends of friends who bought products.
        """
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH (c:Customer {id: $customer_id})
                MATCH path = (c)-[:FRIEND_OF*1..2]-(friend)-[:BOUGHT]->(product:Product)
                WHERE NOT (c)-[:BOUGHT]->(product)
                RETURN friend.id AS friend_id,
                       product.id AS product_id,
                       product.name AS product_name,
                       LENGTH(path) AS distance
                ORDER BY distance, product_id
                LIMIT 20
                """,
                customer_id=customer_id
            )
            return [record.data() for record in result]

    def add_friend_relationship(self, customer1_id: int, customer2_id: int):
        """Add a FRIEND_OF relationship between two customers."""
        with self.driver.session() as session:
            session.run(
                """
                MATCH (c1:Customer {id: $c1_id})
                MATCH (c2:Customer {id: $c2_id})
                MERGE (c1)-[:FRIEND_OF]->(c2)
                MERGE (c2)-[:FRIEND_OF]->(c1)
                """,
                c1_id=customer1_id,
                c2_id=customer2_id
            )
            logger.info(f"Added friend relationship between {customer1_id} and {customer2_id}")
```

### 4.2.5 Populating the Graph

```python
# File: src/scripts/populate_graph.py
"""
Populate Neo4j with data from PostgreSQL.
"""
import psycopg2
from src.services.graph_service import GraphService

def main():
    # Connect to PostgreSQL
    pg_conn = psycopg2.connect(
        host="localhost",
        port=5432,
        user="scalecart",
        password="scalecart_password",
        dbname="scalecart"
    )

    # Connect to Neo4j
    graph = GraphService(
        "bolt://localhost:7687",
        "neo4j",
        "scalecart_neo4j_password"
    )

    # Create category nodes
    with pg_conn.cursor() as cur:
        cur.execute("SELECT id, name FROM categories")
        categories = cur.fetchall()
        for cat_id, name in categories:
            with graph.driver.session() as session:
                session.run(
                    "MERGE (c:Category {id: $id}) SET c.name = $name",
                    id=cat_id, name=name
                )

    # Create product nodes and link to categories
    with pg_conn.cursor() as cur:
        cur.execute("SELECT id, name, description, price, category_id FROM products")
        products = cur.fetchall()
        for prod_id, name, desc, price, cat_id in products:
            with graph.driver.session() as session:
                session.run(
                    """
                    MERGE (p:Product {id: $id})
                    SET p.name = $name, p.description = $desc, p.price = $price
                    WITH p
                    MATCH (c:Category {id: $cat_id})
                    MERGE (p)-[:IN_CATEGORY]->(c)
                    """,
                    id=prod_id, name=name, desc=desc, 
                    price=float(price), cat_id=cat_id
                )

    # Create customer nodes
    with pg_conn.cursor() as cur:
        cur.execute("SELECT id, email, full_name FROM customers LIMIT 1000")
        customers = cur.fetchall()
        for cust_id, email, name in customers:
            with graph.driver.session() as session:
                session.run(
                    "MERGE (c:Customer {id: $id}) SET c.email = $email, c.name = $name",
                    id=cust_id, email=email, name=name
                )

    # Create purchase relationships
    with pg_conn.cursor() as cur:
        cur.execute("""
            SELECT oi.order_id, o.customer_id, oi.product_id
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.id
            WHERE o.status IN ('paid', 'shipped', 'delivered')
            LIMIT 10000
        """)
        purchases = cur.fetchall()
        for order_id, customer_id, product_id in purchases:
            graph.record_purchase(customer_id, product_id, order_id)

    print("Graph populated successfully!")
    graph.close()
    pg_conn.close()

if __name__ == "__main__":
    main()
```

---

## Section 4.3 – Emerging Database Technologies

### 4.3.1 The Target

We'll explore time-series databases and vector databases, two critical technologies for modern applications.

### 4.3.2 Time-Series Databases

**Use Case:** Monitoring, metrics, IoT, event logs.

**Popular options:** TimescaleDB (PostgreSQL extension), InfluxDB, Prometheus.

**TimescaleDB Setup:**

```yaml
# docker-compose.yml (alternative to regular PostgreSQL)
timescaledb:
  image: timescale/timescaledb:2.11-pg15
  container_name: scalecart_timescaledb
  environment:
    POSTGRES_USER: scalecart
    POSTGRES_PASSWORD: scalecart_password
    POSTGRES_DB: scalecart_metrics
  ports:
    - "5433:5432"
  volumes:
    - timescaledb_data:/var/lib/postgresql/data
```

**Creating a hypertable for metrics:**

```sql
-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create table for metrics
CREATE TABLE product_view_events (
    time TIMESTAMPTZ NOT NULL,
    product_id INTEGER NOT NULL,
    customer_id INTEGER,
    session_id VARCHAR(100),
    view_duration_seconds INTEGER
);

-- Convert to hypertable (partition by time)
SELECT create_hypertable('product_view_events', 'time');

-- Create indexes
CREATE INDEX idx_product_view_events_product_id ON product_view_events (product_id, time DESC);
CREATE INDEX idx_product_view_events_customer ON product_view_events (customer_id, time DESC);

-- Query: Average view duration per product over last 24 hours
SELECT 
    product_id,
    AVG(view_duration_seconds) as avg_duration,
    COUNT(*) as view_count
FROM product_view_events
WHERE time > NOW() - INTERVAL '24 hours'
GROUP BY product_id
ORDER BY view_count DESC
LIMIT 10;
```

**Python integration:**

```python
# File: src/services/metrics_service.py
import psycopg2
from datetime import datetime, timedelta
from typing import List, Dict, Any

class MetricsService:
    def __init__(self, connection_string: str):
        self.conn = psycopg2.connect(connection_string)

    def log_product_view(self, product_id: int, customer_id: int, 
                         session_id: str, duration: int):
        """Log a product view event."""
        with self.conn:
            with self.conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO product_view_events 
                    (time, product_id, customer_id, session_id, view_duration_seconds)
                    VALUES (NOW(), %s, %s, %s, %s)
                    """,
                    (product_id, customer_id, session_id, duration)
                )

    def get_product_performance(self, product_id: int, days: int = 7) -> Dict[str, Any]:
        """Get performance metrics for a product over time."""
        with self.conn.cursor() as cur:
            cur.execute(
                """
                SELECT 
                    time_bucket('1 day', time) AS day,
                    COUNT(*) AS views,
                    AVG(view_duration_seconds) AS avg_duration,
                    COUNT(DISTINCT customer_id) AS unique_viewers
                FROM product_view_events
                WHERE product_id = %s 
                  AND time > NOW() - INTERVAL '%s days'
                GROUP BY day
                ORDER BY day DESC
                """,
                (product_id, days)
            )
            rows = cur.fetchall()
            return {
                "product_id": product_id,
                "daily_stats": [
                    {
                        "day": row[0],
                        "views": row[1],
                        "avg_duration": float(row[2]) if row[2] else 0,
                        "unique_viewers": row[3]
                    }
                    for row in rows
                ]
            }

    def get_trending_products(self, hours: int = 24, limit: int = 10) -> List[Dict[str, Any]]:
        """Get trending products by view count."""
        with self.conn.cursor() as cur:
            cur.execute(
                """
                SELECT 
                    product_id,
                    COUNT(*) AS view_count,
                    AVG(view_duration_seconds) AS avg_duration
                FROM product_view_events
                WHERE time > NOW() - INTERVAL '%s hours'
                GROUP BY product_id
                ORDER BY view_count DESC
                LIMIT %s
                """,
                (hours, limit)
            )
            rows = cur.fetchall()
            return [
                {
                    "product_id": row[0],
                    "view_count": row[1],
                    "avg_duration": float(row[2]) if row[2] else 0
                }
                for row in rows
            ]
```

### 4.3.3 Vector Databases for AI and Semantic Search

**Use Case:** RAG (Retrieval-Augmented Generation), semantic search, image similarity, recommendation.

**Setup pgvector (PostgreSQL extension):**

```bash
# In PostgreSQL container
docker exec -it scalecart_postgres psql -U scalecart -d scalecart

-- Enable extension
CREATE EXTENSION IF NOT EXISTS vector;
```

**Create vector table:**

```sql
-- Store product embeddings for semantic search
CREATE TABLE product_embeddings (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    embedding VECTOR(1536),  -- OpenAI's embedding dimension
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create index for fast similarity search
CREATE INDEX idx_product_embeddings_embedding ON product_embeddings 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- or use HNSW for better recall
CREATE INDEX idx_product_embeddings_hnsw ON product_embeddings
USING hnsw (embedding vector_cosine_ops);
```

**Semantic search queries:**

```sql
-- Find similar products to a given product
SELECT p.id, p.name, p.description, 
       1 - (pe.embedding <=> (SELECT embedding FROM product_embeddings WHERE product_id = 42)) AS similarity
FROM product_embeddings pe
JOIN products p ON pe.product_id = p.id
WHERE pe.product_id != 42
ORDER BY pe.embedding <=> (SELECT embedding FROM product_embeddings WHERE product_id = 42)
LIMIT 10;

-- Semantic search by text (requires generating embedding)
-- In application: embed search query, then:
SELECT p.id, p.name, p.description, 
       1 - (pe.embedding <=> %s::vector) AS similarity
FROM product_embeddings pe
JOIN products p ON pe.product_id = p.id
ORDER BY pe.embedding <=> %s::vector
LIMIT 20;
```

**Python service for vector search:**

```python
# File: src/services/vector_service.py
import psycopg2
import numpy as np
from typing import List, Dict, Any, Optional
import openai  # Requires API key

class VectorSearchService:
    def __init__(self, pg_conn, openai_api_key: Optional[str] = None):
        self.pg = pg_conn
        if openai_api_key:
            openai.api_key = openai_api_key
        self.client = openai.Client(api_key=openai_api_key) if openai_api_key else None

    def embed_text(self, text: str) -> List[float]:
        """Generate embedding using OpenAI's API."""
        if not self.client:
            raise ValueError("OpenAI client not configured")
        response = self.client.embeddings.create(
            model="text-embedding-3-small",
            input=text
        )
        return response.data[0].embedding

    def update_product_embedding(self, product_id: int, text: str):
        """Generate and store embedding for a product."""
        embedding = self.embed_text(text)
        
        with self.pg:
            with self.pg.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO product_embeddings (product_id, embedding, updated_at)
                    VALUES (%s, %s::vector, CURRENT_TIMESTAMP)
                    ON CONFLICT (product_id) DO UPDATE
                    SET embedding = EXCLUDED.embedding,
                        updated_at = CURRENT_TIMESTAMP
                    """,
                    (product_id, embedding)
                )

    def semantic_search(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Find products semantically similar to the query."""
        query_embedding = self.embed_text(query)
        
        with self.pg.cursor() as cur:
            cur.execute(
                """
                SELECT p.id, p.name, p.description, p.price,
                       1 - (pe.embedding <=> %s::vector) AS similarity
                FROM product_embeddings pe
                JOIN products p ON pe.product_id = p.id
                ORDER BY pe.embedding <=> %s::vector
                LIMIT %s
                """,
                (query_embedding, query_embedding, limit)
            )
            rows = cur.fetchall()
            return [
                {
                    "id": row[0],
                    "name": row[1],
                    "description": row[2],
                    "price": float(row[3]),
                    "similarity": float(row[4])
                }
                for row in rows
            ]

    def find_similar_products(self, product_id: int, limit: int = 10) -> List[Dict[str, Any]]:
        """Find products similar to a given product."""
        with self.pg.cursor() as cur:
            # Get embedding for the product
            cur.execute(
                "SELECT embedding FROM product_embeddings WHERE product_id = %s",
                (product_id,)
            )
            result = cur.fetchone()
            if not result:
                raise ValueError(f"Product {product_id} has no embedding")
            
            embedding = result[0]
            
            # Find similar products
            cur.execute(
                """
                SELECT p.id, p.name, p.description, p.price,
                       1 - (pe.embedding <=> %s::vector) AS similarity
                FROM product_embeddings pe
                JOIN products p ON pe.product_id = p.id
                WHERE pe.product_id != %s
                ORDER BY pe.embedding <=> %s::vector
                LIMIT %s
                """,
                (embedding, product_id, embedding, limit)
            )
            rows = cur.fetchall()
            return [
                {
                    "id": row[0],
                    "name": row[1],
                    "description": row[2],
                    "price": float(row[3]),
                    "similarity": float(row[4])
                }
                for row in rows
            ]
```

---

## Section 4.4 – Distributed Data Systems

### 4.4.1 The Target

We'll understand distributed systems concepts and implement patterns for event-driven architectures.

### 4.4.2 The Concept – CAP Theorem and Eventual Consistency

**CAP Theorem:** In a distributed system, you can only achieve two of three:
- **Consistency** – All nodes see the same data at the same time.
- **Availability** – Every request receives a response (even if stale).
- **Partition Tolerance** – System continues despite network partitions.

**ScaleCart's Trade-offs:**
- Core e-commerce (orders, payments): Use **CA** (PostgreSQL with strong consistency).
- Analytics, recommendations: Use **AP** (eventual consistency acceptable).

**Eventual Consistency Pattern:** Accept that data may be temporarily inconsistent, but will converge.

### 4.4.3 Saga Pattern for Distributed Transactions

**Problem:** A transaction spans multiple services (order service, payment service, inventory service). We can't use a single ACID transaction.

**Saga Pattern:** A sequence of local transactions, each with a compensating action for rollback.

**Types:**
- **Choreography** – Services publish events, react to each other.
- **Orchestration** – A central coordinator (orchestrator) tells services what to do.

**Example Orchestration Saga:**

```python
# File: src/services/saga_orchestrator.py
import logging
from enum import Enum
from typing import List, Dict, Any, Optional
from dataclasses import dataclass

logger = logging.getLogger(__name__)

class SagaStepStatus(Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    COMPENSATED = "compensated"

@dataclass
class SagaStep:
    name: str
    action: callable
    compensation: callable
    status: SagaStepStatus = SagaStepStatus.PENDING
    result: Any = None
    error: Optional[str] = None

class SagaOrchestrator:
    def __init__(self):
        self.steps: List[SagaStep] = []

    def add_step(self, name: str, action: callable, compensation: callable):
        """Add a step to the saga."""
        self.steps.append(SagaStep(name=name, action=action, compensation=compensation))

    def execute(self) -> bool:
        """Execute the saga."""
        completed_steps = []
        try:
            for step in self.steps:
                logger.info(f"Executing saga step: {step.name}")
                step.result = step.action()
                step.status = SagaStepStatus.COMPLETED
                completed_steps.append(step)
            
            logger.info("Saga completed successfully")
            return True
            
        except Exception as e:
            logger.error(f"Saga failed at step {step.name}: {e}")
            step.status = SagaStepStatus.FAILED
            step.error = str(e)
            
            # Execute compensation for completed steps (in reverse order)
            for completed_step in reversed(completed_steps):
                try:
                    logger.info(f"Compensating step: {completed_step.name}")
                    completed_step.compensation(completed_step.result)
                    completed_step.status = SagaStepStatus.COMPENSATED
                except Exception as comp_e:
                    logger.error(f"Compensation failed for {completed_step.name}: {comp_e}")
                    # Manual intervention required
            
            return False

# Usage example: Order placement saga
class OrderSaga:
    def __init__(self, order_service, payment_service, inventory_service):
        self.order_service = order_service
        self.payment_service = payment_service
        self.inventory_service = inventory_service

    def create_order_saga(self, customer_id, items, payment_method):
        saga = SagaOrchestrator()
        
        # Step 1: Reserve inventory
        def reserve_inventory():
            return self.inventory_service.reserve(customer_id, items)
        
        def release_inventory(reservation):
            self.inventory_service.release(reservation)
        
        saga.add_step("reserve_inventory", reserve_inventory, release_inventory)
        
        # Step 2: Create order
        def create_order():
            return self.order_service.create(customer_id, items)
        
        def cancel_order(order):
            self.order_service.cancel(order.id)
        
        saga.add_step("create_order", create_order, cancel_order)
        
        # Step 3: Process payment
        def process_payment():
            return self.payment_service.charge(customer_id, items, payment_method)
        
        def refund_payment(payment):
            self.payment_service.refund(payment.id)
        
        saga.add_step("process_payment", process_payment, refund_payment)
        
        return saga
```

### 4.4.4 Transactional Outbox Pattern

**Problem:** We need to reliably publish events (e.g., "Order Placed") when a transaction commits. If the event is published before the transaction commits, it might be sent even if the transaction rolls back.

**Solution:** Store events in the same database transaction (outbox table), then a separate publisher reads and sends them.

**Outbox table:**

```sql
-- File: outbox.sql
CREATE TABLE outbox_messages (
    id SERIAL PRIMARY KEY,
    message_id UUID NOT NULL UNIQUE,
    aggregate_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMPTZ,
    retry_count INTEGER DEFAULT 0,
    last_error TEXT
);

CREATE INDEX idx_outbox_messages_published ON outbox_messages (published_at NULLS FIRST) 
WHERE published_at IS NULL;
```

**Writing to outbox in transaction:**

```python
# File: src/services/outbox_writer.py
import uuid
import json
from typing import Dict, Any, Optional
import psycopg2
from psycopg2 import sql

class OutboxWriter:
    def __init__(self, pg_conn):
        self.pg = pg_conn

    def publish_event(self, aggregate_id: str, event_type: str, payload: Dict[str, Any]):
        """Store event in outbox (must be called within a transaction)."""
        message_id = str(uuid.uuid4())
        with self.pg.cursor() as cur:
            cur.execute(
                """
                INSERT INTO outbox_messages 
                (message_id, aggregate_id, event_type, payload)
                VALUES (%s, %s, %s, %s)
                """,
                (message_id, aggregate_id, event_type, json.dumps(payload))
            )
        logger.info(f"Stored outbox event {message_id}: {event_type}")

# Usage in order service:
def create_order(self, customer_id, items):
    with self.pg:
        with self.pg.cursor() as cur:
            # Create order...
            cur.execute("INSERT INTO orders ...")
            
            # Store event in outbox (same transaction)
            self.outbox.publish_event(
                aggregate_id=str(order_id),
                event_type="order.created",
                payload={"order_id": order_id, "customer_id": customer_id}
            )
        
    # Transaction commits, now outbox message is persisted
```

**Outbox publisher (runs independently):**

```python
# File: src/services/outbox_publisher.py
import json
import time
from typing import Optional
import psycopg2
from psycopg2 import sql
import redis
import pika  # for RabbitMQ

class OutboxPublisher:
    def __init__(self, pg_conn, redis_client: Optional[redis.Redis] = None):
        self.pg = pg_conn
        self.redis = redis_client
        self.rabbitmq_connection = None  # Setup RabbitMQ connection

    def run(self, poll_interval_seconds: int = 5, batch_size: int = 100):
        """Continuously poll outbox and publish messages."""
        logger.info("Starting outbox publisher...")
        while True:
            try:
                self.publish_batch(batch_size)
            except Exception as e:
                logger.error(f"Outbox publisher error: {e}")
            time.sleep(poll_interval_seconds)

    def publish_batch(self, batch_size: int):
        """Fetch and publish one batch of messages."""
        with self.pg.cursor() as cur:
            # Select and lock messages (with SKIP LOCKED)
            cur.execute(
                """
                SELECT id, message_id, aggregate_id, event_type, payload
                FROM outbox_messages
                WHERE published_at IS NULL
                ORDER BY created_at
                LIMIT %s
                FOR UPDATE SKIP LOCKED
                """,
                (batch_size,)
            )
            messages = cur.fetchall()

            if not messages:
                return

            for msg in messages:
                msg_id, message_id, agg_id, event_type, payload = msg
                try:
                    # Publish to message broker (RabbitMQ, Kafka, etc.)
                    self.publish_to_broker(event_type, payload)
                    
                    # Mark as published
                    cur.execute(
                        "UPDATE outbox_messages SET published_at = CURRENT_TIMESTAMP "
                        "WHERE id = %s",
                        (msg_id,)
                    )
                    logger.info(f"Published outbox message {message_id}")
                    
                except Exception as e:
                    # Increment retry count
                    cur.execute(
                        "UPDATE outbox_messages SET retry_count = retry_count + 1, "
                        "last_error = %s WHERE id = %s",
                        (str(e), msg_id)
                    )
                    logger.error(f"Failed to publish message {message_id}: {e}")
            
            self.pg.commit()

    def publish_to_broker(self, event_type: str, payload: dict):
        """Publish to RabbitMQ/Kafka."""
        # Example with Redis Pub/Sub (simpler)
        if self.redis:
            self.redis.publish("events", json.dumps({
                "event_type": event_type,
                "payload": payload,
                "timestamp": time.time()
            }))
        else:
            # RabbitMQ implementation
            connection = pika.BlockingConnection(
                pika.ConnectionParameters('localhost')
            )
            channel = connection.channel()
            channel.exchange_declare(exchange='events', exchange_type='fanout')
            channel.basic_publish(
                exchange='events',
                routing_key='',
                body=json.dumps(payload)
            )
            connection.close()
```

---

## Section 4.5 – Summary and Exercises

### 4.5.1 What We Accomplished

In this final part, we:

- Evaluated NoSQL databases and implemented MongoDB for caching and Redis for sessions.
- Built a graph database with Neo4j for recommendations and social features.
- Explored time-series databases (TimescaleDB) and vector databases (pgvector) for emerging workloads.
- Implemented distributed patterns: Saga for distributed transactions and Outbox for reliable event publishing.

You now have a complete, modern, polyglot persistence architecture for ScaleCart that can scale to enterprise-level demands.

### 4.5.2 The Complete Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                         SCALECART PLATFORM                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    APPLICATION LAYER                        │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │  Primary DB  │  │   Document   │  │     Graph    │             │
│  │ PostgreSQL   │  │   MongoDB    │  │    Neo4j     │             │
│  │              │  │              │  │              │             │
│  │ • Products   │  │ • Cache      │  │ • Social     │             │
│  │ • Orders     │  │ • Sessions   │  │   Graph      │             │
│  │ • Customers  │  │ • Cart       │  │ • Recs       │             │
│  │ • Inventory  │  │ • Audit Logs │  │ • Auth       │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│         │                  │                  │                    │
│         └──────────────────┼──────────────────┘                    │
│                            │                                       │
│                   ┌────────┴────────┐                              │
│                   │   Redis Cache   │                              │
│                   │   (Sessions)    │                              │
│                   └─────────────────┘                              │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                ADDITIONAL DATA SERVICES                     │    │
│  │                                                              │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │    │
│  │  │ TimescaleDB  │  │   pgvector   │  │   Outbox     │     │    │
│  │  │ (Metrics)    │  │ (AI Search)  │  │  Publisher   │     │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 4.5.3 Exercises

1. **Implement MongoDB's change streams** to invalidate cache when product updates occur.

2. **Build a real-time recommendation engine** using Neo4j that updates recommendations as users view products.

3. **Set up a time-series dashboard** using TimescaleDB and Grafana for monitoring product views and sales.

4. **Implement a vector similarity search** for products using pgvector. Create embeddings for 1,000 products and test semantic search.

5. **Design a complete Saga** for order cancellation that compensates inventory, refunds payment, and updates order status.

6. **Implement the Outbox pattern with Kafka** instead of Redis Pub/Sub.

### 4.5.4 Final Thoughts

Congratulations! You've completed the entire **Mastering Modern Database Design** series. You now have the knowledge and practical skills to:

- Design normalized, scalable relational databases.
- Optimize query performance with advanced indexing.
- Protect data integrity under high concurrency.
- Choose the right database technology for diverse workloads.
- Build distributed, polyglot persistence architectures.
- Scale from 1,000 records to hundreds of millions.

**Remember:** Database design is an iterative process. Start with a solid foundation, measure performance, and evolve your architecture as your application grows. The principles you've learned here will serve you throughout your career.
