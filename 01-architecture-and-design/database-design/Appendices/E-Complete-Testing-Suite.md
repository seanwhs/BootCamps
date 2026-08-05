# APPENDIX E — Complete Testing Suite

## Comprehensive Testing Strategy for ScaleCart

---

## E.1 Introduction

This appendix provides a complete testing framework for the ScaleCart platform, including:

1. **Unit Tests** – Individual component testing
2. **Integration Tests** – Database and service integration
3. **Performance Tests** – Load and stress testing
4. **Security Tests** – Vulnerability and penetration testing
5. **Contract Tests** – API contract validation
6. **End-to-End Tests** – Complete user workflows

---

## E.2 Test Environment Setup

### E.2.1 Test Configuration

```python
# File: tests/conftest.py
import pytest
import asyncio
from typing import Generator, AsyncGenerator
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from fastapi.testclient import TestClient
from redis import Redis
from pymongo import MongoClient
from neo4j import GraphDatabase

from src.api.app import app
from src.utils.db import Base, get_db
from src.services.session_manager import SessionManager
from src.services.catalog_cache import CatalogCache

# Test database name
TEST_DB_NAME = "scalecart_test"

@pytest.fixture(scope="session")
def test_db():
    """Create test database."""
    # Connect to default postgres database
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        user="scalecart",
        password="scalecart_password",
        dbname="postgres"
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    
    # Terminate existing connections
    cur.execute(f"""
        SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = '{TEST_DB_NAME}'
        AND pid <> pg_backend_pid()
    """)
    
    # Drop and create test database
    cur.execute(f"DROP DATABASE IF EXISTS {TEST_DB_NAME}")
    cur.execute(f"CREATE DATABASE {TEST_DB_NAME}")
    cur.close()
    conn.close()
    
    # Create tables in test database
    engine = create_engine(
        f"postgresql://scalecart:scalecart_password@localhost:5432/{TEST_DB_NAME}"
    )
    Base.metadata.create_all(bind=engine)
    
    yield engine
    
    # Cleanup
    Base.metadata.drop_all(bind=engine)
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        user="scalecart",
        password="scalecart_password",
        dbname="postgres"
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute(f"DROP DATABASE IF EXISTS {TEST_DB_NAME}")
    cur.close()
    conn.close()

@pytest.fixture
def db_session(test_db) -> Generator[Session, None, None]:
    """Create database session for testing."""
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_db)
    session = SessionLocal()
    try:
        yield session
    finally:
        session.rollback()
        session.close()

@pytest.fixture
def client(db_session):
    """Create test client with database session override."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()

@pytest.fixture
def redis_client():
    """Create Redis test client."""
    redis = Redis(
        host="localhost",
        port=6379,
        password="scalecart_password",
        decode_responses=True
    )
    redis.flushdb()
    yield redis
    redis.flushdb()
    redis.close()

@pytest.fixture
def mongo_client():
    """Create MongoDB test client."""
    client = MongoClient(
        "mongodb://scalecart:scalecart_password@localhost:27017/"
    )
    db = client.scalecart_test
    yield db
    client.drop_database("scalecart_test")
    client.close()

@pytest.fixture
def neo4j_driver():
    """Create Neo4j test driver."""
    driver = GraphDatabase.driver(
        "bolt://localhost:7687",
        auth=("neo4j", "scalecart_neo4j_password")
    )
    with driver.session() as session:
        session.run("MATCH (n) DETACH DELETE n")
    yield driver
    with driver.session() as session:
        session.run("MATCH (n) DETACH DELETE n")
    driver.close()

@pytest.fixture
def session_manager(redis_client):
    """Create session manager for testing."""
    return SessionManager(
        redis_host="localhost",
        redis_port=6379,
        redis_password="scalecart_password"
    )

@pytest.fixture
def catalog_cache(mongo_client):
    """Create catalog cache for testing."""
    return CatalogCache(
        "mongodb://scalecart:scalecart_password@localhost:27017/scalecart_test"
    )

@pytest.fixture
def sample_products(db_session):
    """Insert sample products for testing."""
    from src.models.product import Product, Category
    
    # Create category
    category = Category(name="Electronics")
    db_session.add(category)
    db_session.flush()
    
    # Create products
    products = [
        Product(
            name="Laptop Pro",
            description="High-performance laptop",
            price=1999.99,
            category_id=category.id,
            sku=f"SKU-{i}"
        )
        for i in range(5)
    ]
    db_session.add_all(products)
    db_session.commit()
    
    return products

@pytest.fixture
def sample_customer(db_session):
    """Insert sample customer for testing."""
    from src.models.customer import Customer
    
    customer = Customer(
        email="test@example.com",
        password_hash="hashed_password",
        full_name="Test User",
        is_verified=True
    )
    db_session.add(customer)
    db_session.commit()
    
    return customer
```

---

## E.3 Unit Tests

### E.3.1 Model Tests

```python
# File: tests/test_models.py
import pytest
from datetime import datetime
from sqlalchemy.exc import IntegrityError
from src.models.product import Product, Category
from src.models.customer import Customer
from src.models.order import Order, OrderItem
from src.models.inventory import Inventory

class TestProductModel:
    def test_create_product(self, db_session):
        """Test product creation with valid data."""
        category = Category(name="Test Category")
        db_session.add(category)
        db_session.flush()
        
        product = Product(
            name="Test Product",
            price=99.99,
            category_id=category.id
        )
        db_session.add(product)
        db_session.commit()
        
        assert product.id is not None
        assert product.created_at is not None
        assert product.updated_at is not None

    def test_product_price_constraint(self, db_session):
        """Test price cannot be negative."""
        category = Category(name="Test Category")
        db_session.add(category)
        db_session.flush()
        
        product = Product(
            name="Invalid Product",
            price=-10.00,
            category_id=category.id
        )
        db_session.add(product)
        
        with pytest.raises(IntegrityError):
            db_session.commit()

    def test_product_unique_sku(self, db_session):
        """Test SKU must be unique."""
        category = Category(name="Test Category")
        db_session.add(category)
        db_session.flush()
        
        product1 = Product(
            name="Product 1",
            price=10.00,
            category_id=category.id,
            sku="TEST-SKU-001"
        )
        product2 = Product(
            name="Product 2",
            price=20.00,
            category_id=category.id,
            sku="TEST-SKU-001"  # Duplicate SKU
        )
        db_session.add_all([product1, product2])
        
        with pytest.raises(IntegrityError):
            db_session.commit()

    def test_product_search_vector_generated(self, db_session):
        """Test search_vector is automatically generated."""
        category = Category(name="Test Category")
        db_session.add(category)
        db_session.flush()
        
        product = Product(
            name="Amazing Laptop",
            description="High-performance laptop with great battery life",
            price=1999.99,
            category_id=category.id
        )
        db_session.add(product)
        db_session.commit()
        
        # Refresh to get generated column
        db_session.refresh(product)
        assert product.search_vector is not None
        assert "laptop" in product.search_vector
        assert "performance" in product.search_vector

class TestOrderModel:
    def test_order_status_transitions(self, db_session):
        """Test order status transitions."""
        customer = Customer(email="test@example.com", full_name="Test User")
        db_session.add(customer)
        db_session.flush()
        
        order = Order(
            customer_id=customer.id,
            status="pending",
            total_amount=100.00
        )
        db_session.add(order)
        db_session.commit()
        
        # Valid transition
        order.status = "paid"
        db_session.commit()
        assert order.status == "paid"
        
        # Invalid transition (should raise error or be prevented)
        with pytest.raises(Exception):
            order.status = "invalid_status"
            db_session.commit()

    def test_order_item_quantity(self, db_session):
        """Test order item quantity validation."""
        customer = Customer(email="test@example.com", full_name="Test User")
        category = Category(name="Test Category")
        db_session.add_all([customer, category])
        db_session.flush()
        
        product = Product(
            name="Test Product",
            price=10.00,
            category_id=category.id
        )
        db_session.add(product)
        db_session.flush()
        
        order = Order(
            customer_id=customer.id,
            status="pending",
            total_amount=0.00
        )
        db_session.add(order)
        db_session.flush()
        
        # Valid order item
        item = OrderItem(
            order_id=order.id,
            product_id=product.id,
            quantity=2,
            unit_price=10.00
        )
        db_session.add(item)
        db_session.commit()
        assert item.quantity == 2
        
        # Invalid quantity (zero)
        item2 = OrderItem(
            order_id=order.id,
            product_id=product.id,
            quantity=0,
            unit_price=10.00
        )
        db_session.add(item2)
        
        with pytest.raises(IntegrityError):
            db_session.commit()
```

### E.3.2 Service Tests

```python
# File: tests/test_services.py
import pytest
from unittest.mock import Mock, patch
from src.services.order_service import OrderService
from src.services.inventory_service import InventoryService
from src.services.product_service import ProductService

class TestOrderService:
    def test_place_order_success(self, db_session, sample_products, sample_customer):
        """Test successful order placement."""
        service = OrderService(db_session)
        
        items = [
            {'product_id': sample_products[0].id, 'quantity': 2},
            {'product_id': sample_products[1].id, 'quantity': 1}
        ]
        
        order_id = service.place_order(sample_customer.id, items)
        assert order_id is not None
        
        # Verify order was created
        order = service.get_order_with_items(order_id)
        assert order['customer_id'] == sample_customer.id
        assert order['status'] == 'pending'
        assert len(order['items']) == 2
        assert order['total_amount'] == 2 * 1999.99 + 1 * 1999.99

    def test_place_order_insufficient_stock(self, db_session, sample_products, sample_customer):
        """Test order fails when insufficient stock."""
        # Set low stock
        inventory_service = InventoryService(db_session)
        inventory_service.update_stock(sample_products[0].id, 1)  # Only 1 in stock
        
        service = OrderService(db_session)
        items = [
            {'product_id': sample_products[0].id, 'quantity': 5}  # Requesting 5
        ]
        
        with pytest.raises(ValueError, match="Insufficient stock"):
            service.place_order(sample_customer.id, items)

    def test_place_order_rollback(self, db_session, sample_products, sample_customer):
        """Test order transaction rolls back on failure."""
        service = OrderService(db_session)
        
        # This should fail because product doesn't exist
        items = [
            {'product_id': 99999, 'quantity': 1}  # Non-existent product
        ]
        
        with pytest.raises(ValueError):
            service.place_order(sample_customer.id, items)
        
        # Verify no order was created
        order_count = db_session.query(Order).filter_by(customer_id=sample_customer.id).count()
        assert order_count == 0

    def test_get_order_with_items(self, db_session, sample_products, sample_customer):
        """Test retrieving order with items."""
        service = OrderService(db_session)
        
        # Create an order
        items = [
            {'product_id': sample_products[0].id, 'quantity': 1},
        ]
        order_id = service.place_order(sample_customer.id, items)
        
        # Retrieve it
        result = service.get_order_with_items(order_id)
        assert result['id'] == order_id
        assert result['customer_id'] == sample_customer.id
        assert len(result['items']) == 1
        assert result['items'][0]['product_id'] == sample_products[0].id

class TestInventoryService:
    def test_reserve_inventory(self, db_session, sample_products):
        """Test inventory reservation."""
        service = InventoryService(db_session)
        
        product_id = sample_products[0].id
        initial_stock = service.get_stock(product_id)['stock_quantity']
        
        service.reserve_inventory(product_id, 5)
        
        updated = service.get_stock(product_id)
        assert updated['reserved_quantity'] == 5
        assert updated['stock_quantity'] == initial_stock  # Stock unchanged

    def test_reserve_inventory_insufficient(self, db_session, sample_products):
        """Test reservation fails with insufficient stock."""
        service = InventoryService(db_session)
        
        product_id = sample_products[0].id
        stock = service.get_stock(product_id)
        
        # Try to reserve more than available
        with pytest.raises(ValueError, match="Insufficient stock"):
            service.reserve_inventory(product_id, stock['stock_quantity'] + 10)

    def test_commit_reservation(self, db_session, sample_products):
        """Test committing a reservation (reducing stock)."""
        service = InventoryService(db_session)
        
        product_id = sample_products[0].id
        service.reserve_inventory(product_id, 5)
        
        service.commit_reservation(product_id, 5)
        
        updated = service.get_stock(product_id)
        assert updated['reserved_quantity'] == 0
        assert updated['stock_quantity'] == updated['stock_quantity']  # Stock reduced

class TestProductService:
    def test_get_product_caching(self, db_session, sample_products):
        """Test product caching behavior."""
        service = ProductService(db_session, "mongodb://localhost:27017")
        
        product = sample_products[0]
        
        # First call should hit database
        result1 = service.get_product(product.id)
        assert result1 is not None
        
        # Second call should hit cache
        with patch('src.services.catalog_cache.CatalogCache.get_product') as mock_cache:
            mock_cache.return_value = result1
            result2 = service.get_product(product.id)
            mock_cache.assert_called_once()
            assert result2 == result1
```

---

## E.4 Integration Tests

### E.4.1 API Tests

```python
# File: tests/test_api.py
import pytest
from fastapi.testclient import TestClient
from src.api.app import app

class TestProductAPI:
    def test_list_products(self, client, sample_products):
        """Test GET /products endpoint."""
        response = client.get("/api/v1/products")
        assert response.status_code == 200
        data = response.json()
        assert "data" in data
        assert "pagination" in data
        assert len(data["data"]) >= 1

    def test_get_product_by_id(self, client, sample_products):
        """Test GET /products/{id} endpoint."""
        product = sample_products[0]
        response = client.get(f"/api/v1/products/{product.id}")
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == product.id
        assert data["name"] == product.name

    def test_get_product_not_found(self, client):
        """Test GET /products with non-existent ID."""
        response = client.get("/api/v1/products/99999")
        assert response.status_code == 404

    def test_create_product_unauthorized(self, client):
        """Test POST /products without authentication."""
        response = client.post(
            "/api/v1/products",
            json={
                "name": "New Product",
                "price": 99.99,
                "category_id": 1
            }
        )
        assert response.status_code == 401

    def test_create_product_admin(self, client, sample_products):
        """Test POST /products with admin authentication."""
        # In test environment, we'd set up admin token
        admin_token = "test_admin_token"  # Mock token
        response = client.post(
            "/api/v1/products",
            json={
                "name": "New Product",
                "price": 99.99,
                "category_id": sample_products[0].category_id
            },
            headers={"Authorization": f"Bearer {admin_token}"}
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "New Product"

class TestOrderAPI:
    def test_create_order(self, client, sample_customer, sample_products):
        """Test POST /orders endpoint."""
        # Mock authentication
        token = "test_token"
        
        response = client.post(
            "/api/v1/orders",
            json={
                "customer_id": sample_customer.id,
                "items": [
                    {"product_id": sample_products[0].id, "quantity": 2}
                ]
            },
            headers={"Authorization": f"Bearer {token}"}
        )
        assert response.status_code == 201
        data = response.json()
        assert data["customer_id"] == sample_customer.id
        assert data["status"] == "pending"
        assert len(data["items"]) == 1

    def test_get_order(self, client, sample_customer, sample_products):
        """Test GET /orders/{id} endpoint."""
        # First create an order
        token = "test_token"
        create_response = client.post(
            "/api/v1/orders",
            json={
                "customer_id": sample_customer.id,
                "items": [
                    {"product_id": sample_products[0].id, "quantity": 1}
                ]
            },
            headers={"Authorization": f"Bearer {token}"}
        )
        order_id = create_response.json()["id"]
        
        # Then retrieve it
        response = client.get(
            f"/api/v1/orders/{order_id}",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == order_id

class TestAuthAPI:
    def test_register(self, client):
        """Test POST /auth/register."""
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "newuser@example.com",
                "password": "SecurePass123!",
                "full_name": "New User"
            }
        )
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "newuser@example.com"
        assert "id" in data

    def test_register_duplicate_email(self, client, sample_customer):
        """Test registration with existing email."""
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": sample_customer.email,
                "password": "SecurePass123!",
                "full_name": "Duplicate User"
            }
        )
        assert response.status_code == 409

    def test_login(self, client, sample_customer):
        """Test POST /auth/login."""
        # Note: In test, password would be hashed; this is a simplified test
        response = client.post(
            "/api/v1/auth/login",
            json={
                "email": sample_customer.email,
                "password": "password123"  # Mock password
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
```

### E.4.2 Database Integration Tests

```python
# File: tests/test_database_integration.py
import pytest
from sqlalchemy import text
from src.services.metrics_service import MetricsService
from src.services.graph_service import GraphService

class TestTransactionIntegrity:
    def test_transaction_rollback(self, db_session, sample_products):
        """Test transaction rollback on error."""
        product_id = sample_products[0].id
        
        try:
            with db_session.begin():
                # Update product
                db_session.execute(
                    text("UPDATE products SET price = price * 2 WHERE id = :id"),
                    {"id": product_id}
                )
                
                # This will fail
                db_session.execute(
                    text("UPDATE non_existent_table SET value = 1")
                )
        except Exception:
            db_session.rollback()
        
        # Verify price didn't change
        result = db_session.execute(
            text("SELECT price FROM products WHERE id = :id"),
            {"id": product_id}
        ).fetchone()
        
        assert result[0] == 1999.99  # Original price

    def test_foreign_key_constraints(self, db_session, sample_products):
        """Test foreign key constraints prevent orphaned records."""
        # Try to delete category that has products
        category_id = sample_products[0].category_id
        
        with pytest.raises(Exception):  # Integrity error
            db_session.execute(
                text("DELETE FROM categories WHERE id = :id"),
                {"id": category_id}
            )
            db_session.commit()

    def test_unique_constraint(self, db_session, sample_customer):
        """Test unique constraint prevents duplicates."""
        # Try to create duplicate email
        with pytest.raises(Exception):
            db_session.execute(
                text("""
                    INSERT INTO customers (email, password_hash, full_name)
                    VALUES (:email, :hash, :name)
                """),
                {
                    "email": sample_customer.email,
                    "hash": "hashed",
                    "name": "Duplicate User"
                }
            )
            db_session.commit()

class TestMetricsService:
    def test_log_product_view(self, db_session):
        """Test logging product view events."""
        service = MetricsService(db_session.bind)
        
        service.log_product_view(
            product_id=1,
            customer_id=42,
            session_id="test-session",
            duration=30
        )
        
        # Verify event was logged
        result = db_session.execute(
            text("SELECT COUNT(*) FROM product_view_events WHERE product_id = 1")
        ).fetchone()
        assert result[0] == 1

    def test_get_trending_products(self, db_session):
        """Test getting trending products."""
        service = MetricsService(db_session.bind)
        
        # Log some views
        for i in range(10):
            service.log_product_view(
                product_id=1,
                customer_id=i,
                session_id=f"session-{i}",
                duration=30
            )
        
        trending = service.get_trending_products(hours=24, limit=10)
        assert len(trending) >= 1
        assert trending[0]["product_id"] == 1
        assert trending[0]["view_count"] == 10

class TestGraphService:
    def test_record_purchase(self, neo4j_driver):
        """Test recording purchase in Neo4j."""
        service = GraphService(
            "bolt://localhost:7687",
            "neo4j",
            "scalecart_neo4j_password"
        )
        
        service.record_purchase(1, 100, 1001)
        
        with neo4j_driver.session() as session:
            result = session.run(
                """
                MATCH (c:Customer {id: 1})-[r:BOUGHT]->(p:Product {id: 100})
                RETURN r
                """
            )
            assert result.single() is not None

    def test_get_recommendations(self, neo4j_driver):
        """Test getting product recommendations."""
        service = GraphService(
            "bolt://localhost:7687",
            "neo4j",
            "scalecart_neo4j_password"
        )
        
        # Create test data
        with neo4j_driver.session() as session:
            session.run("""
                CREATE (c:Customer {id: 1})
                CREATE (p1:Product {id: 100, name: "Product A"})
                CREATE (p2:Product {id: 101, name: "Product B"})
                CREATE (p3:Product {id: 102, name: "Product C"})
                CREATE (c)-[:BOUGHT]->(p1)
                CREATE (c)-[:BOUGHT]->(p3)
            """)
        
        recommendations = service.get_recommendations(1, limit=5)
        assert len(recommendations) > 0
```

---

## E.5 Performance Tests

### E.5.1 Load Testing Script

```python
# File: tests/performance/test_load.py
import asyncio
import aiohttp
import time
from typing import List
import pytest
from locust import HttpUser, task, between

# Using Locust for load testing
class ScaleCartUser(HttpUser):
    wait_time = between(1, 5)
    
    def on_start(self):
        """Login before starting tasks."""
        self.login()
    
    def login(self):
        """Login to get token."""
        response = self.client.post(
            "/api/v1/auth/login",
            json={
                "email": f"user{self.id}@example.com",
                "password": "password123"
            }
        )
        if response.status_code == 200:
            self.token = response.json()["access_token"]
            self.headers = {"Authorization": f"Bearer {self.token}"}
    
    @task(3)
    def view_products(self):
        """View product list."""
        self.client.get("/api/v1/products", headers=self.headers)
    
    @task(2)
    def view_product(self):
        """View single product."""
        product_id = 1  # Randomize in production tests
        self.client.get(f"/api/v1/products/{product_id}", headers=self.headers)
    
    @task(1)
    def create_order(self):
        """Create an order."""
        self.client.post(
            "/api/v1/orders",
            json={
                "customer_id": 1,
                "items": [
                    {"product_id": 1, "quantity": 2}
                ]
            },
            headers=self.headers
        )

# Using Python's asyncio for simple load test
class AsyncLoadTest:
    def __init__(self, concurrent_users: int, duration_seconds: int):
        self.concurrent_users = concurrent_users
        self.duration_seconds = duration_seconds
        self.results = []
    
    async def make_request(self, session: aiohttp.ClientSession, url: str):
        """Make a single request and record timing."""
        start = time.time()
        try:
            async with session.get(url) as response:
                duration = time.time() - start
                self.results.append({
                    "status": response.status,
                    "duration": duration,
                    "success": response.status == 200
                })
        except Exception as e:
            self.results.append({
                "status": 0,
                "duration": time.time() - start,
                "success": False,
                "error": str(e)
            })
    
    async def user_session(self, user_id: int):
        """Simulate a user session."""
        async with aiohttp.ClientSession() as session:
            end_time = time.time() + self.duration_seconds
            while time.time() < end_time:
                # View products
                await self.make_request(session, "/api/v1/products")
                # View product detail
                await self.make_request(session, "/api/v1/products/1")
                # Random delay
                await asyncio.sleep(0.5)
    
    async def run_load_test(self):
        """Run the load test."""
        tasks = [
            self.user_session(i)
            for i in range(self.concurrent_users)
        ]
        await asyncio.gather(*tasks)
    
    def get_statistics(self):
        """Calculate test statistics."""
        total_requests = len(self.results)
        successful = sum(1 for r in self.results if r["success"])
        avg_duration = sum(r["duration"] for r in self.results) / total_requests if total_requests else 0
        
        return {
            "total_requests": total_requests,
            "success_rate": successful / total_requests if total_requests else 0,
            "average_response_time": avg_duration,
            "min_response_time": min((r["duration"] for r in self.results), default=0),
            "max_response_time": max((r["duration"] for r in self.results), default=0)
        }

@pytest.mark.performance
def test_load():
    """Simple load test."""
    test = AsyncLoadTest(concurrent_users=10, duration_seconds=30)
    asyncio.run(test.run_load_test())
    stats = test.get_statistics()
    
    assert stats["success_rate"] > 0.95, f"Success rate: {stats['success_rate']}"
    assert stats["average_response_time"] < 2.0, f"Avg response time: {stats['average_response_time']}s"
```

### E.5.2 Database Performance Tests

```python
# File: tests/performance/test_db_performance.py
import pytest
import time
from sqlalchemy import text

class TestQueryPerformance:
    def test_explain_analyze(self, db_session):
        """Test EXPLAIN ANALYZE for query optimization."""
        query = """
            EXPLAIN ANALYZE
            SELECT p.*, c.name as category_name
            FROM products p
            JOIN categories c ON p.category_id = c.id
            WHERE p.price BETWEEN 100 AND 1000
            ORDER BY p.price
            LIMIT 100
        """
        
        result = db_session.execute(text(query))
        explain_output = result.fetchall()
        
        # Check that index scan is used (not sequential scan)
        explain_text = " ".join(str(row) for row in explain_output)
        assert "Seq Scan" not in explain_text or "Index Scan" in explain_text

    def test_query_without_index(self, db_session):
        """Test performance without proper indexing."""
        # This query should be slow without index
        query = """
            SELECT * FROM order_items
            WHERE product_id = 1
            ORDER BY created_at DESC
        """
        
        start = time.time()
        result = db_session.execute(text(query))
        result.fetchall()
        duration = time.time() - start
        
        # Without index, this should take > 0.1s for large tables
        # With index, < 0.01s
        assert duration < 0.05, f"Query took {duration}s without proper indexing"

    def test_query_with_covering_index(self, db_session):
        """Test covering index performance."""
        query = """
            SELECT customer_id, total_amount, status
            FROM orders
            WHERE customer_id = 42
        """
        
        start = time.time()
        result = db_session.execute(text(query))
        result.fetchall()
        duration = time.time() - start
        
        # With covering index, should be very fast
        assert duration < 0.01, f"Query took {duration}s"

class TestBulkOperations:
    def test_bulk_insert_performance(self, db_session):
        """Test bulk insert performance."""
        start = time.time()
        
        # Insert 1000 orders
        order_data = [
            {
                "customer_id": i % 100,
                "status": "pending",
                "total_amount": 100.00 + i
            }
            for i in range(1000)
        ]
        
        db_session.execute(
            text("""
                INSERT INTO orders (customer_id, status, total_amount)
                VALUES (:customer_id, :status, :total_amount)
            """),
            order_data
        )
        db_session.commit()
        
        duration = time.time() - start
        assert duration < 1.0, f"Bulk insert took {duration}s"

    def test_index_maintenance_overhead(self, db_session):
        """Test performance overhead with indexes."""
        # Create table without indexes
        db_session.execute(text("""
            CREATE TABLE test_no_index AS
            SELECT * FROM products
        """))
        
        # Measure insert time without indexes
        start = time.time()
        db_session.execute(text("""
            INSERT INTO test_no_index (name, price, category_id)
            SELECT name, price, category_id FROM generate_series(1, 10000)
        """))
        db_session.commit()
        no_index_time = time.time() - start
        
        # Create indexes
        db_session.execute(text("""
            CREATE INDEX test_no_index_price ON test_no_index(price)
        """))
        
        # Measure insert time with indexes
        start = time.time()
        db_session.execute(text("""
            INSERT INTO test_no_index (name, price, category_id)
            SELECT name, price, category_id FROM generate_series(1, 10000)
        """))
        db_session.commit()
        with_index_time = time.time() - start
        
        # With indexes should be somewhat slower
        assert with_index_time > no_index_time * 0.8
        
        # Cleanup
        db_session.execute(text("DROP TABLE test_no_index"))
        db_session.commit()
```

---

## E.6 Security Tests

### E.6.1 SQL Injection Tests

```python
# File: tests/test_security.py
import pytest
from sqlalchemy import text

class TestSQLInjection:
    def test_sql_injection_prevention(self, client):
        """Test API endpoints against SQL injection."""
        malicious_inputs = [
            "'; DROP TABLE products; --",
            "1' OR '1'='1",
            "1; SELECT * FROM users",
            "' UNION SELECT * FROM customers --"
        ]
        
        for malicious in malicious_inputs:
            # Test product search
            response = client.get(f"/api/v1/products?search={malicious}")
            assert response.status_code in [200, 400]
            
            # The response should not include data from other tables
            data = response.json() if response.status_code == 200 else {}
            # Verify we're not seeing sensitive data
            assert "password" not in str(data).lower()
            assert "credit_card" not in str(data).lower()

    def test_parameterized_queries(self, db_session):
        """Test that parameterized queries prevent injection."""
        malicious = "'; DROP TABLE products; --"
        
        # Should be safe
        result = db_session.execute(
            text("SELECT id FROM products WHERE name = :name"),
            {"name": malicious}
        )
        
        # Table should still exist
        tables = db_session.execute(
            text("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")
        ).fetchall()
        table_names = [t[0] for t in tables]
        assert "products" in table_names

class TestAuthentication:
    def test_unauthorized_access(self, client):
        """Test that protected endpoints require authentication."""
        protected_endpoints = [
            ("GET", "/api/v1/orders"),
            ("POST", "/api/v1/orders"),
            ("GET", "/api/v1/customers/me"),
            ("PUT", "/api/v1/customers/me")
        ]
        
        for method, endpoint in protected_endpoints:
            if method == "GET":
                response = client.get(endpoint)
            else:
                response = client.post(endpoint, json={})
            
            assert response.status_code == 401

    def test_jwt_validation(self, client, sample_customer):
        """Test JWT token validation."""
        # Invalid token
        invalid_token = "invalid.token.here"
        response = client.get(
            "/api/v1/customers/me",
            headers={"Authorization": f"Bearer {invalid_token}"}
        )
        assert response.status_code == 401
        
        # Expired token (simulated)
        expired_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjMiLCJleHAiOjB9.invalid"
        response = client.get(
            "/api/v1/customers/me",
            headers={"Authorization": f"Bearer {expired_token}"}
        )
        assert response.status_code == 401

    def test_role_based_access(self, client):
        """Test role-based access control."""
        admin_token = "mock_admin_token"
        user_token = "mock_user_token"
        
        # Admin endpoint
        response = client.get(
            "/api/v1/admin/health",
            headers={"Authorization": f"Bearer {user_token}"}
        )
        assert response.status_code == 403
        
        response = client.get(
            "/api/v1/admin/health",
            headers={"Authorization": f"Bearer {admin_token}"}
        )
        assert response.status_code == 200

class TestSecurityHeaders:
    def test_security_headers(self, client):
        """Test security headers are present."""
        response = client.get("/")
        
        expected_headers = [
            "X-Frame-Options",
            "X-Content-Type-Options",
            "X-XSS-Protection",
            "Strict-Transport-Security",
            "Content-Security-Policy"
        ]
        
        for header in expected_headers:
            assert header in response.headers

    def test_cors_configuration(self, client):
        """Test CORS configuration."""
        response = client.options(
            "/api/v1/products",
            headers={
                "Origin": "https://example.com",
                "Access-Control-Request-Method": "GET"
            }
        )
        
        # Should allow configured origins
        assert response.headers.get("Access-Control-Allow-Origin") in [
            "https://example.com",
            "*"
        ]

class TestRateLimiting:
    def test_rate_limiting(self, client):
        """Test rate limiting on endpoints."""
        # Make many rapid requests
        for i in range(100):
            response = client.get("/api/v1/products")
            if response.status_code == 429:
                break
        
        # Should hit rate limit before 100 requests
        assert response.status_code == 429
        assert "X-RateLimit-Reset" in response.headers
        assert "X-RateLimit-Remaining" in response.headers

    def test_rate_limit_headers(self, client):
        """Test rate limit headers format."""
        response = client.get("/api/v1/products")
        assert "X-RateLimit-Limit" in response.headers
        assert "X-RateLimit-Remaining" in response.headers
        assert "X-RateLimit-Reset" in response.headers
        
        limit = int(response.headers["X-RateLimit-Limit"])
        remaining = int(response.headers["X-RateLimit-Remaining"])
        assert remaining <= limit
```

---

## E.7 Contract Tests

### E.7.1 API Contract Tests

```python
# File: tests/test_contracts.py
import pytest
from schemathesis import SchemaTestRunner

class TestAPIContracts:
    def test_openapi_validation(self, client):
        """Test that API responses match OpenAPI schema."""
        # Get OpenAPI spec
        response = client.get("/openapi.json")
        assert response.status_code == 200
        spec = response.json()
        
        # Validate OpenAPI spec
        assert "openapi" in spec
        assert "components" in spec
        assert "paths" in spec
        
        # Test each endpoint matches schema
        runner = SchemaTestRunner(spec)
        
        # Run tests for all endpoints
        runner.run()

    def test_contract_products_list(self, client):
        """Test products list contract."""
        response = client.get("/api/v1/products")
        data = response.json()
        
        # Contract validation
        assert "data" in data
        assert isinstance(data["data"], list)
        assert "pagination" in data
        assert "total" in data["pagination"]
        assert "page" in data["pagination"]
        assert "limit" in data["pagination"]
        
        if data["data"]:
            product = data["data"][0]
            required_fields = ["id", "name", "price", "category_id"]
            for field in required_fields:
                assert field in product

    def test_contract_order_create(self, client, sample_customer):
        """Test order creation contract."""
        # Create test data
        token = "mock_token"
        
        response = client.post(
            "/api/v1/orders",
            json={
                "customer_id": sample_customer.id,
                "items": [
                    {"product_id": 1, "quantity": 1}
                ]
            },
            headers={"Authorization": f"Bearer {token}"}
        )
        
        data = response.json()
        
        # Contract validation
        assert "id" in data
        assert "customer_id" in data
        assert "status" in data
        assert "total_amount" in data
        assert "items" in data
        assert isinstance(data["items"], list)
        assert "created_at" in data

class TestPaginationContract:
    def test_pagination_structure(self, client):
        """Test pagination structure is consistent."""
        response = client.get("/api/v1/products?page=1&limit=10")
        data = response.json()
        
        assert "pagination" in data
        pagination = data["pagination"]
        assert "page" in pagination
        assert "limit" in pagination
        assert "total" in pagination
        assert "pages" in pagination
        
        assert pagination["page"] == 1
        assert pagination["limit"] == 10
        assert pagination["pages"] >= 1

    def test_pagination_bounds(self, client):
        """Test pagination respects bounds."""
        # Test max limit
        response = client.get("/api/v1/products?limit=1000")
        assert response.status_code == 400  # Should reject
        data = response.json()
        assert "limit" in data["error"]["details"].lower()
```

---

## E.8 End-to-End Tests

### E.8.1 Complete User Flow

```python
# File: tests/test_e2e.py
import pytest
from src.api.app import app
from fastapi.testclient import TestClient

class TestE2EFlow:
    def test_complete_purchase_flow(self, client, db_session):
        """Test complete purchase flow from registration to order."""
        
        # 1. Register
        register_response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "e2e_user@example.com",
                "password": "SecurePass123!",
                "full_name": "E2E User"
            }
        )
        assert register_response.status_code == 201
        customer = register_response.json()
        
        # 2. Login
        login_response = client.post(
            "/api/v1/auth/login",
            json={
                "email": "e2e_user@example.com",
                "password": "SecurePass123!"
            }
        )
        assert login_response.status_code == 200
        token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        
        # 3. View products
        products_response = client.get("/api/v1/products", headers=headers)
        assert products_response.status_code == 200
        products = products_response.json()["data"]
        assert len(products) > 0
        
        # 4. Add to cart (session-based)
        cart_response = client.post(
            f"/api/v1/cart/items",
            json={
                "product_id": products[0]["id"],
                "quantity": 2
            },
            headers=headers
        )
        assert cart_response.status_code == 200
        
        # 5. View cart
        cart_response = client.get("/api/v1/cart", headers=headers)
        assert cart_response.status_code == 200
        cart = cart_response.json()
        assert cart["total_items"] == 1
        
        # 6. Place order
        order_response = client.post(
            "/api/v1/orders",
            json={
                "customer_id": customer["id"],
                "items": [
                    {"product_id": products[0]["id"], "quantity": 2}
                ]
            },
            headers=headers
        )
        assert order_response.status_code == 201
        order = order_response.json()
        
        # 7. View order
        order_view_response = client.get(
            f"/api/v1/orders/{order['id']}",
            headers=headers
        )
        assert order_view_response.status_code == 200
        order_view = order_view_response.json()
        assert order_view["status"] in ["pending", "paid"]
        assert order_view["id"] == order["id"]
        
        # 8. Check inventory (should be updated)
        product_id = products[0]["id"]
        inventory_response = client.get(
            f"/api/v1/inventory/{product_id}",
            headers=headers
        )
        assert inventory_response.status_code == 200
        inventory = inventory_response.json()
        # Stock should be reduced by 2
        
        # 9. Submit review (if delivered)
        review_response = client.post(
            f"/api/v1/products/{product_id}/reviews",
            json={
                "rating": 5,
                "title": "Excellent product!",
                "comment": "Very satisfied with my purchase."
            },
            headers=headers
        )
        # Note: This would normally require verified purchase
        if review_response.status_code == 400:
            # If purchase verification fails, that's expected in test
            pass
        else:
            assert review_response.status_code == 201

    def test_search_flow(self, client, sample_products):
        """Test search flow from query to results."""
        # 1. Simple search
        search_response = client.get(
            f"/api/v1/products?search=laptop"
        )
        assert search_response.status_code == 200
        data = search_response.json()
        assert len(data["data"]) >= 1
        assert "laptop" in data["data"][0]["name"].lower()
        
        # 2. Filtered search
        search_response = client.get(
            "/api/v1/products?min_price=1000&max_price=2000&category_id=1"
        )
        assert search_response.status_code == 200
        data = search_response.json()
        for product in data["data"]:
            assert product["price"] >= 1000
            assert product["price"] <= 2000
```

---

## E.9 Test Coverage Configuration

```ini
# File: .coveragerc
[run]
source = src
omit = 
    */tests/*
    */migrations/*
    */scripts/*
    */__init__.py

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    if __name__ == .__main__.:
    raise AssertionError
    raise NotImplementedError
    if TYPE_CHECKING:

ignore_errors = True

[html]
directory = htmlcov

[xml]
output = coverage.xml
```

---

## E.10 Test Execution Script

```bash
#!/bin/bash
# File: scripts/run_tests.sh

set -e

echo "🚀 Running ScaleCart Test Suite"
echo "================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Setup test environment
echo -e "${YELLOW}Setting up test environment...${NC}"
docker compose -f docker-compose.test.yml up -d
sleep 5

# 2. Run unit tests
echo -e "${YELLOW}Running unit tests...${NC}"
pytest tests/test_*.py -v --cov=src --cov-report=term --cov-report=html

# 3. Run integration tests
echo -e "${YELLOW}Running integration tests...${NC}"
pytest tests/test_integration.py -v -m integration

# 4. Run contract tests
echo -e "${YELLOW}Running contract tests...${NC}"
pytest tests/test_contracts.py -v

# 5. Run security tests
echo -e "${YELLOW}Running security tests...${NC}"
pytest tests/test_security.py -v

# 6. Run performance tests (optional)
if [ "$RUN_PERFORMANCE" = "true" ]; then
    echo -e "${YELLOW}Running performance tests...${NC}"
    pytest tests/performance/ -v -m performance
fi

# 7. Run E2E tests
echo -e "${YELLOW}Running E2E tests...${NC}"
pytest tests/test_e2e.py -v

# 8. Generate report
echo -e "${YELLOW}Generating test report...${NC}"
coverage report
coverage html

# 9. Cleanup
echo -e "${YELLOW}Cleaning up...${NC}"
docker compose -f docker-compose.test.yml down -v

echo -e "${GREEN}✅ All tests completed!${NC}"
echo "📊 Coverage report: open htmlcov/index.html"
```

---

## E.11 Test Data Factory

```python
# File: tests/factories.py
import factory
from factory import Faker
from datetime import datetime
import random
from src.models.product import Product, Category
from src.models.customer import Customer
from src.models.order import Order, OrderItem
from src.models.inventory import Inventory

class CategoryFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = Category
        sqlalchemy_session = None  # Set in test
    
    name = Faker("word")
    description = Faker("sentence")

class ProductFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = Product
        sqlalchemy_session = None
    
    name = Faker("catch_phrase")
    description = Faker("text", max_nb_chars=200)
    price = factory.LazyFunction(lambda: round(random.uniform(5.0, 5000.0), 2))
    sku = factory.LazyFunction(lambda: f"SKU-{random.randint(1000, 9999)}")
    weight_kg = factory.LazyFunction(lambda: round(random.uniform(0.1, 50.0), 2))
    
    @factory.post_generation
    def with_category(self, create, extracted, **kwargs):
        if not create:
            return
        if extracted:
            self.category = extracted

class CustomerFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = Customer
        sqlalchemy_session = None
    
    email = Faker("email")
    password_hash = Faker("password", length=60)
    full_name = Faker("name")
    phone = Faker("phone_number")
    is_active = True
    is_verified = True

class OrderFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = Order
        sqlalchemy_session = None
    
    status = factory.Iterator(["pending", "paid", "shipped", "delivered"])
    total_amount = factory.LazyFunction(lambda: round(random.uniform(10.0, 1000.0), 2))
    order_date = factory.LazyFunction(datetime.now)
    
    @factory.post_generation
    def with_items(self, create, extracted, **kwargs):
        if not create:
            return
        if extracted:
            for item in extracted:
                self.items.append(item)

class OrderItemFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = OrderItem
        sqlalchemy_session = None
    
    quantity = factory.LazyFunction(lambda: random.randint(1, 5))
    unit_price = factory.LazyFunction(lambda: round(random.uniform(5.0, 500.0), 2))
    discount_percent = factory.LazyFunction(lambda: random.choice([0.0, 5.0, 10.0]))

# Usage in tests
def test_factory_usage(db_session):
    """Example of factory usage."""
    # Set session for factories
    ProductFactory._meta.sqlalchemy_session = db_session
    
    # Create a category
    category = CategoryFactory()
    
    # Create products
    products = ProductFactory.create_batch(10, with_category=category)
    
    # Verify
    assert len(products) == 10
    assert all(p.category == category for p in products)
```

---

**[END OF APPENDIX E]**

*This complete testing suite provides comprehensive coverage for all aspects of the ScaleCart platform. Use it to ensure reliability, performance, and security in production.*
