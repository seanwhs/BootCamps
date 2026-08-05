# APPENDIX PRIMER 7 — Introduction to Application Architecture & Design Patterns

## Understanding How Applications Are Built


## P7.1 Introduction

Welcome to the seventh primer! You've learned about databases, performance, transactions, NoSQL, and APIs. Now it's time to understand how all these pieces fit together in a complete application architecture.

**By the end of this primer, you will understand:**
- What application architecture is
- The three-tier architecture pattern
- Monolithic vs. microservices architectures
- Common design patterns (MVC, Repository, Service Layer)
- How ScaleCart is structured
- Deployment and operations concepts

**Estimated time:** 30-45 minutes

---

## P7.2 What Is Application Architecture?

### P7.2.1 The Analogy: Building a House

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE ANALOGY                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Building a house requires:                                     │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  FOUNDATION = Database                                     │ │
│   │  • Where everything sits                                   │ │
│   │  • Provides stability                                     │ │
│   │  • Stores all data                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  WALLS = API/Backend                                      │ │
│   │  • Structure and support                                   │ │
│   │  • Connects foundation to the top                         │ │
│   │  • Processes requests                                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ROOF = Frontend                                          │ │
│   │  • What users see                                          │ │
│   │  • Protects from the outside (users)                      │ │
│   │  • Provides interface                                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P7.2.2 What Is Application Architecture?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    APPLICATION ARCHITECTURE DEFINITION          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Application architecture is the blueprint for:                 │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  • How components are organized                           │ │
│   │  • How they communicate                                    │ │
│   │  • How data flows                                         │ │
│   │  • How the system scales                                  │ │
│   │  • How it handles failures                                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Good architecture:                                             │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ✅ Makes the system easier to understand                  │ │
│   │  ✅ Makes the system easier to maintain                    │ │
│   │  ✅ Makes the system more reliable                         │ │
│   │  ✅ Makes the system more scalable                         │ │
│   │  ✅ Makes the system more secure                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P7.3 Three-Tier Architecture

### P7.3.1 The Classic Pattern

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THREE-TIER ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  PRESENTATION TIER (Frontend)                              │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • What users see and interact with                   ││ │
│   │  │  • Web browser, mobile app, desktop app               ││ │
│   │  │  • Handles UI/UX                                       ││ │
│   │  │  • Sends user requests to the next tier               ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  APPLICATION TIER (Backend)                               │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Business logic                                      ││ │
│   │  │  • Processes requests                                  ││ │
│   │  │  • Validates data                                      ││ │
│   │  │  • Enforces business rules                            ││ │
│   │  │  • Communicates with database                         ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  DATA TIER (Database)                                    │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Stores all data                                     ││ │
│   │  │  • PostgreSQL, Redis, MongoDB, Neo4j                  ││ │
│   │  │  • Ensures data integrity                             ││ │
│   │  │  • Handles queries                                     ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P7.4 Monolithic vs. Microservices

### P7.4.1 Monolithic Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MONOLITHIC ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   All code in a single application:                              │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │              ┌─────────────────────────────┐               │ │
│   │              │      MONOLITHIC APP         │               │ │
│   │              │                             │               │ │
│   │              │  ┌───────────────────────┐  │               │ │
│   │              │  │   User Management     │  │               │ │
│   │              │  ├───────────────────────┤  │               │ │
│   │              │  │   Product Catalog     │  │               │ │
│   │              │  ├───────────────────────┤  │               │ │
│   │              │  │   Order Processing    │  │               │ │
│   │              │  ├───────────────────────┤  │               │ │
│   │              │  │   Inventory           │  │               │ │
│   │              │  ├───────────────────────┤  │               │ │
│   │              │  │   Payments            │  │               │ │
│   │              │  └───────────────────────┘  │               │ │
│   │              │                             │               │ │
│   │              │      ┌─────────────────┐    │               │ │
│   │              │      │    Database     │    │               │ │
│   │              │      └─────────────────┘    │               │ │
│   │              └─────────────────────────────┘               │ │
│   │                                                             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Pros:                                                          │
│   • Simple to develop                                            │ │
│   • Easy to deploy                                               │ │
│   • Single codebase                                              │ │
│                                                                     │
│   Cons:                                                          │
│   • Hard to scale parts independently                           │ │
│   • Big codebase becomes complex                                │ │
│   • One bug can break everything                                │ │
│   • Hard to use different technologies                          │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P7.4.2 Microservices Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MICROSERVICES ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Each feature is its own service:                               │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │ │
│   │   │    User      │  │   Product    │  │    Order     │   │ │
│   │   │   Service    │  │   Service    │  │   Service    │   │ │
│   │   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │ │
│   │          │                 │                 │            │ │
│   │          └─────────────────┼─────────────────┘            │ │
│   │                            │                              │ │
│   │                   ┌────────┴────────┐                    │ │
│   │                   │   API Gateway   │                    │ │
│   │                   └─────────────────┘                    │ │
│   │                            │                              │ │
│   │   ┌──────────────┐  ┌────┴────┐  ┌──────────────┐      │ │
│   │   │   Inventory  │  │ Payment │  │  Notification│      │ │
│   │   │   Service    │  │ Service │  │   Service    │      │ │
│   │   └──────────────┘  └─────────┘  └──────────────┘      │ │
│   │                                                             │ │
│   │   Each service has its own database:                      │ │
│   │                                                             │ │
│   │   User DB    Product DB    Order DB    Inventory DB       │ │
│   │                                                             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Pros:                                                          │
│   • Independent scaling                                           │ │
│   • Teams can work independently                                │ │
│   • Different technologies per service                         │ │
│   • Fault isolation                                              │ │
│                                                                     │
│   Cons:                                                          │ │
│   • Complex to manage                                            │ │
│   • Hard to debug                                                │ │
│   • Network latency                                              │ │
│   • Data consistency challenges                                 │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P7.4.3 ScaleCart's Approach

ScaleCart uses a **hybrid approach**:

- **Core application**: Monolithic (easier to start)
- **Background workers**: Separate services
- **Future**: Can split into microservices as needed

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                    API SERVICE                             │ │
│   │                                                             │ │
│   │   ┌─────────────────────────────────────────────────────┐  │ │
│   │   │                    API LAYER                       │  │ │
│   │   │  (Products, Orders, Customers, Auth, etc.)        │  │ │
│   │   └─────────────────────────────────────────────────────┘  │ │
│   │                                                             │ │
│   │   ┌─────────────────────────────────────────────────────┐  │ │
│   │   │                 SERVICE LAYER                     │  │ │
│   │   │  (Business Logic, Transactions, Validation)       │  │ │
│   │   └─────────────────────────────────────────────────────┘  │ │
│   │                                                             │ │
│   │   ┌─────────────────────────────────────────────────────┐  │ │
│   │   │                 DATA LAYER                        │  │ │
│   │   │  (PostgreSQL, Redis, MongoDB, Neo4j)            │  │ │
│   │   └─────────────────────────────────────────────────────┘  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                   BACKGROUND WORKERS                     │ │
│   │                                                             │ │
│   │   ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │ │
│   │   │   Email     │  │  Analytics  │  │   Outbox        │ │ │
│   │   │   Worker    │  │   Worker    │  │   Publisher     │ │ │
│   │   └─────────────┘  └─────────────┘  └─────────────────┘ │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P7.5 Common Design Patterns

### P7.5.1 MVC (Model-View-Controller)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MVC PATTERN                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   MVC separates application into three components:               │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  MODEL (Data)                                              │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Represents data and business logic                 ││ │
│   │  │  • Talks to the database                               ││ │
│   │  │  • Example: Product, Order, Customer models            ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  VIEW (Presentation)                                      │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • What the user sees                                 ││ │
│   │  │  • Renders data                                        ││ │
│   │  │  • Example: Product list HTML, JSON response           ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  CONTROLLER (Logic)                                      │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Handles user requests                              ││ │
│   │  │  • Processes input                                     ││ │
│   │  │  • Updates model                                       ││ │
│   │  │  • Returns view                                        ││ │
│   │  │  • Example: ProductController, OrderController         ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   In ScaleCart (REST API):                                       │
│   • Model: SQLAlchemy models                                     │
│   • View: JSON responses                                         │
│   • Controller: FastAPI route handlers                         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P7.5.2 Repository Pattern

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REPOSITORY PATTERN                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Repository pattern abstracts data access:                      │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │   SERVICE LAYER                                            │ │
│   │   (Business Logic)                                         │ │
│   │         │                                                   │ │
│   │         ▼                                                   │ │
│   │   ┌─────────────────────────────────────────────────────┐  │ │
│   │   │           REPOSITORY                               │  │ │
│   │   │  (Data Access Abstraction)                        │  │ │
│   │   │                                                   │  │ │
│   │   │  product_repo.get(id)                             │  │ │
│   │   │  product_repo.save(product)                       │  │ │
│   │   │  product_repo.find_by_category(cat_id)           │  │ │
│   │   └─────────────────────────────────────────────────────┘  │ │
│   │         │                                                   │ │
│   │         ▼                                                   │ │
│   │   ┌─────────────────────────────────────────────────────┐  │ │
│   │   │           DATABASE                                │  │ │
│   │   │  (PostgreSQL, Redis, etc.)                       │  │ │
│   │   └─────────────────────────────────────────────────────┘  │ │
│   │                                                             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Benefits:                                                      │
│   • Hides database complexity                                    │ │
│   • Makes testing easier                                        │ │
│   • Can switch databases easily                                │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P7.5.3 Service Layer Pattern

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SERVICE LAYER PATTERN                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Service layer contains business logic:                         │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │   API ROUTE                                                │ │
│   │   (Request Handler)                                        │ │
│   │         │                                                   │ │
│   │         ▼                                                   │ │
│   │   ┌─────────────────────────────────────────────────────┐  │ │
│   │   │           SERVICE                                 │  │ │
│   │   │  (Business Logic)                                │  │ │
│   │   │                                                   │  │ │
│   │   │  OrderService.place_order()                       │  │ │
│   │   │    • Validate customer                           │  │ │
│   │   │    • Check inventory                             │  │ │
│   │   │    • Calculate total                             │  │ │
│   │   │    • Create order                                │  │ │
│   │   │    • Process payment                             │  │ │
│   │   │    • Send notification                           │  │ │
│   │   └─────────────────────────────────────────────────────┘  │ │
│   │         │                                                   │ │
│   │         ▼                                                   │ │
│   │   ┌─────────────────────────────────────────────────────┐  │ │
│   │   │           REPOSITORY                              │  │ │
│   │   │  (Data Access)                                    │  │ │
│   │   └─────────────────────────────────────────────────────┘  │ │
│   │                                                             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Benefits:                                                      │
│   • Business logic is centralized                              │ │
│   • Easy to test                                               │ │
│   • Reusable across different APIs                          │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P7.6 How ScaleCart Is Structured

### P7.6.1 Directory Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART DIRECTORY STRUCTURE                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   scalecart/                                                      │
│   ├── src/                                                       │
│   │   ├── api/                  # Presentation Layer            │
│   │   │   ├── app.py            # Main FastAPI app             │
│   │   │   ├── routes/           # API endpoints               │
│   │   │   │   ├── products.py                                 │
│   │   │   │   ├── orders.py                                   │
│   │   │   │   ├── customers.py                               │
│   │   │   │   └── auth.py                                     │
│   │   │   └── middleware/       # Request/response middleware  │
│   │   │       ├── auth.py                                     │
│   │   │       └── logging.py                                  │
│   │   │                                                         │
│   │   ├── models/               # Data Layer (M)             │
│   │   │   ├── product.py                                      │
│   │   │   ├── order.py                                        │
│   │   │   ├── customer.py                                     │
│   │   │   └── inventory.py                                    │
│   │   │                                                         │
│   │   ├── services/             # Service Layer              │
│   │   │   ├── order_service.py   # Business logic            │
│   │   │   ├── product_service.py                             │
│   │   │   ├── inventory_service.py                           │
│   │   │   └── catalog_cache.py  # MongoDB cache              │
│   │   │                                                         │
│   │   ├── repositories/          # Repository Layer           │
│   │   │   ├── product_repo.py    # Data access               │
│   │   │   ├── order_repo.py                                   │
│   │   │   └── customer_repo.py                               │
│   │   │                                                         │
│   │   ├── utils/                # Utilities                  │
│   │   │   ├── db.py             # Database connection         │
│   │   │   ├── config.py         # Configuration               │
│   │   │   └── logging.py        # Logging                     │
│   │   │                                                         │
│   │   └── migrations/            # Database migrations        │
│   │       └── versions/                                       │
│   │                                                             │
│   ├── tests/                    # Test suite                  │
│   │   ├── unit/                # Unit tests                 │
│   │   ├── integration/         # Integration tests          │
│   │   └── conftest.py          # Test fixtures               │
│   │                                                             │
│   ├── scripts/                  # Utility scripts            │
│   │   ├── generate_test_data.py                               │
│   │   ├── backup.sh                                          │
│   │   └── deploy.sh                                          │
│   │                                                             │
│   ├── docker-compose.yml        # Docker configuration         │
│   ├── Dockerfile                # Container build             │
│   ├── requirements.txt          # Python dependencies         │
│   └── Makefile                  # Common commands             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P7.6.2 The Flow of a Request

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REQUEST FLOW IN SCALECART                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. User makes request                                          │
│      GET /api/v1/products/123                                   │
│                                                                     │
│   2. API Route receives request                                 │
│      FastAPI route handler: products.py                        │
│                                                                     │
│   3. Middleware processes request                              │
│      • Authentication (JWT validation)                          │
│      • Logging                                                  │
│      • Rate limiting                                            │
│                                                                     │
│   4. Service layer processes business logic                     │
│      ProductService.get_product()                              │
│      • Check cache (Redis)                                      │
│      • If not in cache, query database                         │
│      • Format response                                         │
│                                                                     │
│   5. Repository layer accesses data                             │
│      ProductRepository.get_by_id()                             │
│      • Builds SQL query                                         │
│      • Executes query                                           │
│      • Returns data                                            │
│                                                                     │
│   6. Database returns data                                      │
│      PostgreSQL: SELECT * FROM products WHERE id = 123;       │
│                                                                     │
│   7. Response is returned                                       │
│      JSON: { "data": { "id": 123, "name": "Laptop", ... } }   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P7.7 Deployment & Operations

### P7.7.1 The Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT PIPELINE                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. DEVELOPER WRITES CODE                                 │ │
│   │  • Local development                                        │ │
│   │  • Runs tests                                              │ │
│   │  • Commits to Git                                          │ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  2. CI/CD PIPELINE                                       │ │
│   │  • Builds the application (Docker)                       │ │
│   │  • Runs automated tests                                   │ │
│   │  • Runs security scans                                   │ │
│   │  • Builds Docker image                                   │ │
│   │  • Pushes to registry (Docker Hub/ECR)                  │ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  3. DEPLOY TO STAGING                                    │ │
│   │  • Deploys to staging environment                          │ │
│   │  • Runs smoke tests                                       │ │
│   │  • Manual approval (if needed)                           │ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  4. DEPLOY TO PRODUCTION                                │ │
│   │  • Canary deployment (small % of traffic)                │ │
│   │  • Monitor for errors                                     │ │
│   │  • Gradually increase traffic                             │ │
│   │  • Full rollout                                            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P7.8 Why This Matters for ScaleCart

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE IMPORTANCE                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ScaleCart's architecture enables:                              │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SCALABILITY                                               │ │
│   │  • Can handle thousands of concurrent users                │ │
│   │  • Can scale horizontally                                   │ │
│   │  • Databases optimized for their workloads                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  MAINTAINABILITY                                          │ │
│   │  • Clear separation of concerns                           │ │
│   │  • Easy to add new features                               │ │
│   │  • Well-organized codebase                                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  RELIABILITY                                              │ │
│   │  • Fault isolation                                         │ │
│   │  • Graceful error handling                                │ │
│   │  • Monitoring and alerts                                  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SECURITY                                                  │ │
│   │  • Multiple security layers                                │ │
│   │  • Authentication and authorization                       │ │
│   │  • Data encryption                                        │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P7.9 Glossary of New Terms

| Term | Definition |
|------|------------|
| **Architecture** | The high-level structure of a software system |
| **Three-Tier** | Presentation, Application, Data tiers |
| **Monolithic** | Single application containing all functionality |
| **Microservices** | Independent services for each feature |
| **MVC** | Model-View-Controller design pattern |
| **Repository Pattern** | Abstraction for data access |
| **Service Layer** | Contains business logic |
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **Docker** | Containerization platform |
| **Kubernetes** | Container orchestration platform |
| **Orchestration** | Automated management of containers |

---

## P7.10 Summary

### P7.10.1 Key Takeaways

1. **Application architecture is the blueprint** for how components fit together.

2. **Three-tier architecture** separates presentation, logic, and data.

3. **Monolithic vs. Microservices** is a trade-off between simplicity and flexibility.

4. **Design patterns** like MVC, Repository, and Service Layer provide proven solutions.

5. **ScaleCart uses a hybrid approach** – monolithic core with separate workers.

6. **Good architecture enables** scalability, maintainability, reliability, and security.

### P7.10.2 What's Next?

You've completed all seven primers! You're now fully prepared for the main series.

---

## P7.11 Quick Quiz

Test your understanding:

1. **What are the three tiers in three-tier architecture?**
   - A) Database, Backend, Frontend
   - B) Presentation, Application, Data
   - C) Models, Views, Controllers
   - D) Development, Testing, Production

2. **What is a monolithic application?**
   - A) An application with one feature
   - B) An application where all code is in one codebase
   - C) An application that uses one database
   - D) An application that runs on one server

3. **What is the Repository pattern?**
   - A) A pattern for storing data
   - B) A pattern for abstracting data access
   - C) A pattern for user interfaces
   - D) A pattern for testing

4. **What does CI/CD stand for?**
   - A) Continuous Integration / Continuous Deployment
   - B) Code Integration / Code Deployment
   - C) Continuous Improvement / Continuous Delivery
   - D) Code Integrity / Code Distribution

5. **What is a service layer?**
   - A) A layer for database access
   - B) A layer for business logic
   - C) A layer for user interfaces
   - D) A layer for network communication

**Answers:** 1-B, 2-B, 3-B, 4-A, 5-B

---

**[END OF PRIMER 7]**
