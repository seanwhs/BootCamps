# APPENDIX X — Complete Developer Getting Started Guide

## Your First 60 Minutes with ScaleCart

---

## X.1 Introduction

This appendix provides a complete, step-by-step guide for getting started with the ScaleCart platform as a developer. It covers:

1. **Quick Start** – 15-minute setup
2. **Environment Setup** – Complete development environment
3. **Project Structure** – Understanding the codebase
4. **First Code Changes** – Your first contribution
5. **Testing** – Running and writing tests
6. **Debugging** – Troubleshooting techniques
7. **Common Tasks** – Day-to-day development activities

---

## X.2 Quick Start (15 Minutes)

### X.2.1 One-Command Setup

```bash
# Clone the repository
git clone https://github.com/scalecart/scalecart.git
cd scalecart

# Run the quick start script
./scripts/quick-start.sh

# Or manually:
make env          # Create .env file
make up           # Start all services
make db-init      # Initialize database
make db-seed      # Seed test data
make db-migrate   # Run migrations

# Verify installation
curl http://localhost:8000/health
```

### X.2.2 Access the Services

```bash
# API
curl http://localhost:8000/api/v1/products

# API Documentation
open http://localhost:8000/docs

# Grafana (Monitoring)
open http://localhost:3000
# Username: admin
# Password: admin

# Neo4j Browser
open http://localhost:7474
# Username: neo4j
# Password: scalecart_neo4j_password
```

---

## X.3 Complete Environment Setup

### X.3.1 System Requirements

```bash
# Verify prerequisites
docker --version        # >= 20.10
docker compose --version # >= 2.0
python3 --version       # >= 3.10
git --version          # >= 2.30
make --version         # (optional but recommended)
```

### X.3.2 Detailed Installation

**macOS:**

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install docker docker-compose python git make

# Start Docker Desktop
open /Applications/Docker.app
```

**Ubuntu/Debian:**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Install other tools
sudo apt install python3 python3-pip git make -y
```

**Windows (WSL2):**

```powershell
# Install WSL2
wsl --install

# Install Ubuntu from Microsoft Store

# In Ubuntu:
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo apt install docker-compose-plugin python3 python3-pip git make -y
```

### X.3.3 Python Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Verify installation
python -c "import fastapi; print('FastAPI installed successfully')"
```

---

## X.4 Project Structure

### X.4.1 Directory Overview

```
scalecart/
├── src/                          # Source code
│   ├── api/                      # API layer
│   │   ├── app.py               # Main FastAPI application
│   │   └── routes/              # API route handlers
│   │       ├── products.py
│   │       ├── orders.py
│   │       └── customers.py
│   ├── models/                  # Database models (SQLAlchemy)
│   │   ├── product.py
│   │   ├── order.py
│   │   └── customer.py
│   ├── services/                # Business logic
│   │   ├── product_service.py
│   │   ├── order_service.py
│   │   └── inventory_service.py
│   ├── utils/                   # Utility functions
│   │   ├── db.py               # Database connection
│   │   └── config.py           # Configuration
│   └── migrations/              # Alembic database migrations
│       └── versions/
├── tests/                       # Test suite
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── factories/              # Test data factories
├── scripts/                     # Utility scripts
│   ├── generate_data.py
│   ├── backup.sh
│   └── quick-start.sh
├── k8s/                         # Kubernetes manifests
│   ├── base/
│   └── overlays/
├── docker-compose.yml           # Docker Compose configuration
├── Dockerfile                   # Container build file
├── requirements.txt             # Python dependencies
├── Makefile                     # Development shortcuts
└── .env.example                 # Environment variable template
```

### X.4.2 Key Files to Know

```python
# src/api/app.py - Main FastAPI application
from fastapi import FastAPI
from src.api.routes import products, orders, customers
from src.utils.db import engine
from src.utils.config import settings

app = FastAPI(
    title="ScaleCart API",
    version="1.0.0",
    description="E-commerce API"
)

# Include routers
app.include_router(products.router)
app.include_router(orders.router)
app.include_router(customers.router)

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

```python
# src/models/product.py - Product model
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from src.utils.db import Base

class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    price = Column(Numeric(10, 2), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"))
    
    category = relationship("Category", back_populates="products")
```

```python
# src/services/order_service.py - Business logic
from sqlalchemy.orm import Session
from src.models.order import Order
from src.models.inventory import Inventory

class OrderService:
    def __init__(self, db: Session):
        self.db = db
    
    def place_order(self, customer_id: int, items: list) -> Order:
        # Transaction logic
        with self.db.begin():
            order = Order(customer_id=customer_id)
            self.db.add(order)
            # ... process items
            return order
```

---

## X.5 First Code Changes

### X.5.1 Add a New Endpoint

**Step 1: Create the route file**

```python
# File: src/api/routes/health.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from src.utils.db import get_db
from src.services.health_service import HealthService

router = APIRouter(prefix="/health", tags=["health"])

@router.get("/detailed")
async def detailed_health(db: Session = Depends(get_db)):
    """Get detailed health information."""
    service = HealthService(db)
    return await service.get_detailed_health()
```

**Step 2: Register the router**

```python
# File: src/api/app.py
from src.api.routes import health

# Add to app
app.include_router(health.router)
```

**Step 3: Test the endpoint**

```bash
# Restart the API
docker compose restart api

# Test the new endpoint
curl http://localhost:8000/health/detailed
```

### X.5.2 Add a New Database Model

**Step 1: Create the model**

```python
# File: src/models/category.py
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from src.utils.db import Base

class Category(Base):
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False, unique=True)
    created_at = Column(DateTime, server_default=func.now())
    
    products = relationship("Product", back_populates="category")
```

**Step 2: Create migration**

```bash
# Generate migration
alembic revision --autogenerate -m "add_categories_table"

# Apply migration
alembic upgrade head
```

**Step 3: Update imports**

```python
# File: src/models/__init__.py
from src.models.category import Category
from src.models.product import Product
```

### X.5.3 Add a Service Method

```python
# File: src/services/category_service.py
from sqlalchemy.orm import Session
from src.models.category import Category
from typing import List, Optional

class CategoryService:
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_name(self, name: str) -> Optional[Category]:
        """Get category by name."""
        return self.db.query(Category).filter(Category.name == name).first()
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Category]:
        """Get all categories with pagination."""
        return self.db.query(Category).offset(skip).limit(limit).all()
```

---

## X.6 Testing

### X.6.1 Running Tests

```bash
# Run all tests
make test

# Run specific test file
pytest tests/unit/test_models.py -v

# Run specific test function
pytest tests/unit/test_models.py::TestProductModel::test_create_product -v

# Run tests with coverage
pytest --cov=src --cov-report=html tests/

# Run tests with debugger
pytest --pdb tests/
```

### X.6.2 Writing Tests

```python
# File: tests/unit/test_models/test_product.py
import pytest
from src.models.product import Product
from src.models.category import Category

class TestProductModel:
    def test_create_product(self, db_session):
        """Test creating a product."""
        # Create category
        category = Category(name="Electronics")
        db_session.add(category)
        db_session.flush()
        
        # Create product
        product = Product(
            name="Test Product",
            price=99.99,
            category_id=category.id
        )
        db_session.add(product)
        db_session.commit()
        
        # Assert
        assert product.id is not None
        assert product.name == "Test Product"
        assert product.price == 99.99
    
    def test_product_price_constraint(self, db_session):
        """Test price cannot be negative."""
        category = Category(name="Electronics")
        db_session.add(category)
        db_session.flush()
        
        product = Product(
            name="Invalid",
            price=-10.00,
            category_id=category.id
        )
        db_session.add(product)
        
        with pytest.raises(Exception):
            db_session.commit()
```

### X.6.3 Test Fixtures

```python
# File: tests/conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.utils.db import Base

@pytest.fixture
def db_session():
    """Create a test database session."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def sample_category(db_session):
    """Create a sample category."""
    category = Category(name="Electronics")
    db_session.add(category)
    db_session.commit()
    return category
```

---

## X.7 Debugging

### X.7.1 Logging

```python
# File: src/utils/logging.py
import logging
import structlog

def setup_logging():
    """Configure structured logging."""
    structlog.configure(
        processors=[
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    return structlog.get_logger()

# Usage
logger = structlog.get_logger()

async def create_order(order_data):
    logger.info("Creating order", customer_id=order_data.customer_id)
    try:
        order = await process_order(order_data)
        logger.info("Order created", order_id=order.id)
        return order
    except Exception as e:
        logger.error("Order creation failed", error=str(e), exc_info=True)
        raise
```

### X.7.2 Using the Debugger

```bash
# Run API with debugger
docker compose exec api python -m debugpy --listen 0.0.0.0:5678 -m uvicorn src.api.app:app --host 0.0.0.0 --port 8000

# In VS Code, add launch configuration:
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Remote Attach",
            "type": "python",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5678
            }
        }
    ]
}
```

### X.7.3 Common Debugging Commands

```bash
# Check API logs
docker compose logs api -f | grep ERROR

# Check database logs
docker compose logs postgres -f

# Check database connections
docker compose exec postgres psql -U scalecart -c "SELECT * FROM pg_stat_activity;"

# Check Redis keys
docker compose exec redis redis-cli -a scalecart_password KEYS "*"

# Check MongoDB collections
docker compose exec mongodb mongosh -u scalecart -p scalecart_password --eval "db.getCollectionNames()"

# Inspect container
docker compose exec api bash

# Check CPU/memory
docker stats
```

---

## X.8 Common Development Tasks

### X.8.1 Database Operations

```bash
# Connect to database
make psql

# Create migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1

# Reset database
make db-reset

# Seed test data
make db-seed
```

### X.8.2 Code Quality

```bash
# Format code
make format
# or
black src/ tests/
isort src/ tests/

# Run linters
make lint
# or
flake8 src/ tests/
mypy src/

# Check type hints
mypy src/

# Check import order
isort --check-only src/ tests/
```

### X.8.3 Package Management

```bash
# Add new package
pip install package-name

# Update requirements
pip freeze > requirements.txt

# Update package
pip install --upgrade package-name

# Remove package
pip uninstall package-name
```

### X.8.4 Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-feature

# Add changes
git add .

# Commit with message
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/new-feature

# Create pull request
gh pr create --title "Add new feature" --body "Description"

# Update branch
git pull origin main
git rebase main
```

---

## X.9 Development Tips

### X.9.1 Useful VS Code Extensions

```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.black-formatter",
    "ms-python.isort",
    "ms-azuretools.vscode-docker",
    "cweijan.vscode-mysql-client2",
    "redhat.vscode-yaml",
    "yzhang.markdown-all-in-one",
    "eamodio.gitlens"
  ]
}
```

### X.9.2 VS Code Settings

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.linting.mypyEnabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  },
  "files.watcherExclude": {
    "**/venv/**": true,
    "**/.git/**": true,
    "**/__pycache__/**": true
  }
}
```

### X.9.3 Development Cheat Sheet

```bash
# Environment
source venv/bin/activate
deactivate

# Docker
make up          # Start services
make down        # Stop services
make logs        # View logs
make psql        # Connect to database
make shell       # Open container shell

# Database
make db-init     # Initialize schema
make db-migrate  # Run migrations
make db-seed     # Seed data
make db-reset    # Reset database

# Testing
make test        # Run tests
make test-unit   # Run unit tests
make test-integration  # Run integration tests
make test-coverage     # Test with coverage

# Code Quality
make lint        # Run linters
make format      # Format code
make type-check  # Run type checker

# Project
make env         # Create .env
make up          # Start everything
make down        # Stop everything
make clean       # Clean cache
```

---

## X.10 Troubleshooting Common Issues

### X.10.1 Port Already in Use

```bash
# Check what's using the port
sudo lsof -i :5432  # PostgreSQL port

# Change port in .env
POSTGRES_PORT=5433

# Or kill the process
sudo kill -9 <PID>
```

### X.10.2 Docker Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Restart session
newgrp docker

# Or use sudo
sudo docker compose up -d
```

### X.10.3 Database Connection Error

```bash
# Check PostgreSQL is running
docker compose ps postgres

# Check logs
docker compose logs postgres

# Restart PostgreSQL
docker compose restart postgres

# Check connection string
echo $DATABASE_URL
```

### X.10.4 Migration Error

```bash
# Check current version
alembic current

# Check migration history
alembic history

# Reset to base (careful!)
alembic stamp base
alembic upgrade head
```

---

## X.11 Next Steps

### X.11.1 Learning Path

```yaml
learning_path:
  week_1:
    - "Complete this getting started guide"
    - "Explore the API (Swagger UI)"
    - "Run the tests and understand them"
    - "Make a small change and deploy"
  
  week_2:
    - "Learn about the database schema"
    - "Understand the service layer"
    - "Add a new endpoint"
    - "Write tests for your changes"
  
  week_3:
    - "Deep dive into performance"
    - "Learn about indexing and optimization"
    - "Understand the caching strategy"
    - "Profile and optimize a query"
  
  week_4:
    - "Understand the deployment architecture"
    - "Learn about the monitoring stack"
    - "Set up a staging environment"
    - "Practice disaster recovery"
```

### X.11.2 Community Resources

```yaml
resources:
  documentation:
    - "API Reference: https://docs.scalecart.com/api"
    - "Database Schema: https://docs.scalecart.com/schema"
    - "Deployment Guide: https://docs.scalecart.com/deployment"
    - "Contributing Guide: https://docs.scalecart.com/contributing"
  
  community:
    - "Slack: https://slack.scalecart.com"
    - "GitHub: https://github.com/scalecart"
    - "Discord: https://discord.scalecart.com"
    - "Forum: https://forum.scalecart.com"
  
  learning:
    - "FastAPI Tutorial: https://fastapi.tiangolo.com/tutorial/"
    - "SQLAlchemy Guide: https://docs.sqlalchemy.org/"
    - "PostgreSQL Documentation: https://www.postgresql.org/docs/"
    - "Docker Getting Started: https://docs.docker.com/get-started/"
```

---

**[END OF APPENDIX X]**

*This comprehensive developer guide provides everything needed to get started with ScaleCart development. Use it to quickly ramp up and become productive with the platform.*
