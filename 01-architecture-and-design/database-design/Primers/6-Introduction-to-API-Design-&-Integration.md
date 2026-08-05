# APPENDIX PRIMER 6 — Introduction to API Design & Integration

## Understanding How Applications Talk to Databases

---

## P6.1 Introduction

Welcome to the sixth primer! Now that you understand databases, performance, transactions, and NoSQL, it's time to learn how applications actually *talk* to these databases through APIs.

**By the end of this primer, you will understand:**
- What an API is and why it matters
- The difference between REST, GraphQL, and gRPC
- How APIs connect to databases
- API authentication and security basics
- API versioning and documentation
- How ScaleCart's API works

**Estimated time:** 30-45 minutes

---

## P6.2 What Is an API?

### P6.2.1 The Analogy: The Restaurant

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API ANALOGY                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Imagine a restaurant:                                          │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  YOU (Customer) = Your Application                         │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  You want to order food (request data)                 ││ │
│   │  │  You don't cook it yourself (you don't access DB)      ││ │
│   │  │  You give your order to the waiter (API call)          ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   │                                                             │ │
│   │  WAITER = API                                              │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  Takes your order (API request)                        ││ │
│   │  │  Goes to the kitchen (database)                        ││ │
│   │  │  Brings back your food (API response)                  ││ │
│   │  │  You don't need to know how it's made                  ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   │                                                             │ │
│   │  KITCHEN = Database                                        │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  Prepares the food (processes the query)              ││ │
│   │  │  Uses ingredients (data)                               ││ │
│   │  │  Sends food back via waiter (returns results)          ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   API = Application Programming Interface                         │
│   It's how different software systems communicate.                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P6.2.2 What Does an API Do?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API FUNCTIONS                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   An API is a set of rules and protocols for building and         │
│   interacting with software applications.                        │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. COMMUNICATION                                          │ │
│   │     • Allows different applications to talk               │ │
│   │     • Browser ↔ Server                                     │ │
│   │     • Server ↔ Database                                    │ │
│   │     • Service ↔ Service (microservices)                   │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  2. ABSTRACTION                                            │ │
│   │     • Hides complexity                                      │ │
│   │     • You don't need to know the database details          │ │
│   │     • Just call the API and get data                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  3. STANDARDIZATION                                        │ │
│   │     • Consistent way to access data                        │ │
│   │     • Same API works for web, mobile, desktop             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P6.3 Types of APIs

### P6.3.1 REST (Representational State Transfer)

REST is the most common API style. It uses HTTP methods and URLs.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REST API                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   REST APIs are based on resources (things) and operations.       │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  RESOURCES:                                                │ │
│   │  • /products  → Products collection                       │ │
│   │  • /products/1 → Specific product                          │ │
│   │  • /customers → Customers collection                       │ │
│   │  • /orders/42 → Specific order                            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   OPERATIONS (HTTP Methods):                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GET    → Read data (SELECT)                              │ │
│   │  POST   → Create data (INSERT)                            │ │
│   │  PUT    → Update entire record (UPDATE)                   │ │
│   │  PATCH  → Update partial record (UPDATE)                  │ │
│   │  DELETE → Remove data (DELETE)                            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Example Requests:                                              │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GET /api/v1/products                                      │ │
│   │  → Get all products                                        │ │
│   │                                                             │ │
│   │  GET /api/v1/products/123                                 │ │
│   │  → Get product with ID 123                                 │ │
│   │                                                             │ │
│   │  POST /api/v1/products                                     │ │
│   │  → Create a new product                                    │ │
│   │  Body: { "name": "Laptop", "price": 999.99 }              │ │
│   │                                                             │ │
│   │  PUT /api/v1/products/123                                 │ │
│   │  → Update product 123 completely                          │ │
│   │                                                             │ │
│   │  DELETE /api/v1/products/123                              │ │
│   │  → Delete product 123                                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P6.3.2 GraphQL

GraphQL lets clients ask for exactly what they need.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GRAPHQL                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   GraphQL is a query language for APIs.                          │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  PROBLEM WITH REST:                                        │ │
│   │  REST often returns too much or too little data.          │ │
│   │                                                             │ │
│   │  GET /api/v1/products/1                                  │ │
│   │  Returns: id, name, description, price, category, etc.    │ │
│   │  But you only need name and price!                        │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GRAPHQL SOLUTION:                                         │ │
│   │  You specify exactly what you want.                       │ │
│   │                                                             │ │
│   │  query {                                                   │ │
│   │    product(id: 1) {                                        │ │
│   │      name                                                  │ │
│   │      price                                                 │ │
│   │    }                                                       │ │
│   │  }                                                         │ │
│   │                                                             │ │
│   │  Returns: { "name": "Laptop", "price": 999.99 }          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   GraphQL also lets you get related data in one request:         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  query {                                                   │ │
│   │    product(id: 1) {                                        │ │
│   │      name                                                  │ │
│   │      price                                                 │ │
│   │      category {                                            │ │
│   │        name                                                │ │
│   │      }                                                     │ │
│   │      reviews {                                             │ │
│   │        rating                                              │ │
│   │        comment                                             │ │
│   │      }                                                     │ │
│   │    }                                                       │ │
│   │  }                                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P6.3.3 gRPC

gRPC is a high-performance, language-agnostic RPC framework.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GRPC                                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   gRPC = Google Remote Procedure Call                            │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  gRPC is:                                                  │ │
│   │  • Very fast (binary protocol)                             │ │
│   │  • Uses Protocol Buffers (structured data)                 │ │
│   │  • Supports streaming                                      │ │
│   │  • Great for microservices                                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Example Protocol Buffer Definition:                            │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  message ProductRequest {                                  │ │
│   │    int32 id = 1;                                           │ │
│   │  }                                                          │ │
│   │                                                             │ │
│   │  message ProductResponse {                                 │ │
│   │    int32 id = 1;                                           │ │
│   │    string name = 2;                                        │ │
│   │    double price = 3;                                       │ │
│   │  }                                                          │ │
│   │                                                             │ │
│   │  service ProductService {                                  │ │
│   │    rpc GetProduct(ProductRequest) returns (ProductResponse);│ │
│   │  }                                                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   REST vs GraphQL vs gRPC:                                       │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  REST      → Simple, human-readable, HTTP                 │ │
│   │  GraphQL   → Flexible queries, one endpoint               │ │
│   │  gRPC      → Fast, efficient, binary                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P6.4 How APIs Connect to Databases

### P6.4.1 The Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API → DATABASE FLOW                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. CLIENT REQUEST                                         │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  Mobile App / Browser / Another Service                ││ │
│   │  │  "I need product information"                          ││ │
│   │  │  GET /api/v1/products/123                             ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────────┬──────────────────────────────┘ │
│                                  │                                 │
│                                  ▼                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  2. API PROCESSES REQUEST                                 │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Validates authentication                            ││ │
│   │  │  • Validates request data                              ││ │
│   │  │  • Determines what data is needed                     ││ │
│   │  │  • Builds SQL query                                    ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────────┬──────────────────────────────┘ │
│                                  │                                 │
│                                  ▼                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  3. DATABASE QUERY                                        │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  SELECT * FROM products WHERE id = 123;              ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────────┬──────────────────────────────┘ │
│                                  │                                 │
│                                  ▼                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  4. DATABASE RETURNS RESULT                               │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  { id: 123, name: "Laptop", price: 999.99 }          ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────────┬──────────────────────────────┘ │
│                                  │                                 │
│                                  ▼                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  5. API FORMATS RESPONSE                                  │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  {                                                    ││ │
│   │  │    "data": {                                          ││ │
│   │  │      "id": 123,                                        ││ │
│   │  │      "name": "Laptop",                                ││ │
│   │  │      "price": 999.99                                  ││ │
│   │  │    }                                                   ││ │
│   │  │  }                                                     ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └──────────────────────────────┬──────────────────────────────┘ │
│                                  │                                 │
│                                  ▼                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  6. RESPONSE TO CLIENT                                   │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  Mobile App receives JSON data                        ││ │
│   │  │  Displays product information                         ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P6.4.2 API → Database Example

```python
# Example: FastAPI endpoint with database integration

from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from src.models.product import Product
from src.utils.db import get_db

app = FastAPI()

@app.get("/api/v1/products/{product_id}")
async def get_product(product_id: int, db: Session = Depends(get_db)):
    """
    API endpoint that fetches data from the database.
    
    GET /api/v1/products/123
    → Returns product data from PostgreSQL
    """
    
    # Build the database query
    product = db.query(Product).filter(Product.id == product_id).first()
    
    # Handle not found
    if not product:
        return {"error": "Product not found"}, 404
    
    # Return formatted response
    return {
        "data": {
            "id": product.id,
            "name": product.name,
            "price": product.price,
            "description": product.description
        }
    }
```

---

## P6.5 API Authentication & Security

### P6.5.1 Authentication Methods

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API AUTHENTICATION                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. API Keys                                                    │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Simple, static keys                                       │ │
│   │  Header: X-API-Key: your-key-here                         │ │
│   │  Good for: Machine-to-machine communication               │ │
│   │  Risk: Keys can be stolen                                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   2. JWT (JSON Web Tokens)                                        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Self-contained tokens                                     │ │
│   │  Header: Authorization: Bearer token-here                 │ │
│   │  Contains user info, expiry, signature                     │ │
│   │  Good for: User authentication                             │ │
│   │  Risk: Tokens can be stolen, need short expiry            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   3. OAuth2                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Industry standard for authorization                      │ │
│   │  "Login with Google/Facebook"                             │ │
│   │  Good for: Third-party access                             │ │
│   │  Risk: Complex to implement                               │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P6.5.2 JWT Explained

```
┌─────────────────────────────────────────────────────────────────────┐
│                    JWT STRUCTURE                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   JWT = JSON Web Token                                            │
│   A JWT has three parts:                                         │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  HEADER                                                     │ │
│   │  {                                                         │ │
│   │    "alg": "HS256",  ← Algorithm used                       │ │
│   │    "typ": "JWT"     ← Token type                           │ │
│   │  }                                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  PAYLOAD (Claims)                                          │ │
│   │  {                                                         │ │
│   │    "sub": "42",          ← User ID                         │ │
│   │    "email": "john@e.com", ← User email                    │ │
│   │    "role": "admin",      ← User role                       │ │
│   │    "exp": 1641024000     ← Expiration timestamp            │ │
│   │  }                                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SIGNATURE                                                 │ │
│   │  HMACSHA256(                                               │ │
│   │    base64UrlEncode(header) + "." +                        │ │
│   │    base64UrlEncode(payload),                              │ │
│   │    secret-key                                              │ │
│   │  )                                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Final Token:                                                  │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.                   │ │
│   │  eyJzdWIiOiI0MiIsImVtYWlsIjoiam9obkBlLmNvbSIsInJvbGUi... │ │
│   │  SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P6.6 API Versioning & Documentation

### P6.6.1 API Versioning

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API VERSIONING                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Why version APIs?                                              │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  • APIs evolve over time                                   │ │
│   │  • Existing clients should keep working                   │ │
│   │  • New features shouldn't break old apps                  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Versioning Methods:                                            │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. URL Versioning (Most Common)                          │ │
│   │     /api/v1/products                                       │ │
│   │     /api/v2/products                                       │ │
│   │                                                             │ │
│   │  2. Header Versioning                                      │ │
│   │     Accept: application/vnd.scalecart.v1+json            │ │
│   │                                                             │ │
│   │  3. Query Parameter Versioning                            │ │
│   │     /api/products?version=1                                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ScaleCart uses URL versioning:                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  /api/v1/products  ← Current version                      │ │
│   │  /api/v2/products  ← Next version (future)                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P6.6.2 API Documentation

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API DOCUMENTATION                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Good API documentation is essential for:                       │
│   • Developers using your API                                     │
│   • Internal teams                                                │
│   • Testing and debugging                                         │
│                                                                     │
│   ScaleCart uses OpenAPI (Swagger):                              │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GET /api/v1/products/{id}                                │ │
│   │                                                             │ │
│   │  Parameters:                                               │ │
│   │    id: integer (required) - Product ID                    │ │
│   │                                                             │ │
│   │  Response:                                                 │ │
│   │    200 OK: {                                               │ │
│   │      "id": 123,                                            │ │
│   │      "name": "Product Name",                              │ │
│   │      "price": 99.99                                        │ │
│   │    }                                                       │ │
│   │                                                             │ │
│   │    404 Not Found: {                                        │ │
│   │      "error": "Product not found"                          │ │
│   │    }                                                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Benefits of OpenAPI:                                          │
│   • Interactive documentation (Swagger UI)                      │
│   • Auto-generated client SDKs                                  │
│   • API contract for testing                                    │
│   • Always up-to-date                                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P6.7 ScaleCart's API Architecture

### P6.7.1 ScaleCart API Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART API ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ScaleCart uses FastAPI with:                                   │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  API STYLE: REST                                           │ │
│   │  • Resource-based URLs                                     │ │
│   │  • Standard HTTP methods (GET, POST, PUT, DELETE)         │ │
│   │  • JSON request/response bodies                            │ │
│   │  • HTTP status codes                                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  AUTHENTICATION: JWT                                      │ │
│   │  • Access tokens (30 minutes)                              │ │
│   │  • Refresh tokens (7 days)                                 │ │
│   │  • Role-based access control (RBAC)                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  DOCUMENTATION: OpenAPI 3.0                               │ │
│   │  • Swagger UI: /docs                                        │ │
│   │  • ReDoc: /redoc                                            │ │
│   │  • OpenAPI JSON: /openapi.json                            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SECURITY:                                                 │ │
│   │  • Rate limiting (100 req/min)                             │ │
│   │  • Input validation                                        │ │
│   │  • SQL injection prevention                                │ │
│   │  • CORS configuration                                      │ │
│   │  • HTTPS only (production)                                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P6.7.2 Example ScaleCart API Endpoints

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART API ENDPOINTS                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   PRODUCTS:                                                       │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GET    /api/v1/products          → List products         │ │
│   │  GET    /api/v1/products/{id}    → Get product           │ │
│   │  POST   /api/v1/products          → Create product        │ │
│   │  PUT    /api/v1/products/{id}    → Update product        │ │
│   │  DELETE /api/v1/products/{id}    → Delete product        │ │
│   │  GET    /api/v1/products/search  → Search products       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ORDERS:                                                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GET    /api/v1/orders            → List orders           │ │
│   │  GET    /api/v1/orders/{id}      → Get order             │ │
│   │  POST   /api/v1/orders            → Create order          │ │
│   │  PATCH  /api/v1/orders/{id}      → Update order status   │ │
│   │  POST   /api/v1/orders/{id}/cancel → Cancel order        │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   CUSTOMERS:                                                      │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GET    /api/v1/customers/me       → Get profile          │ │
│   │  PUT    /api/v1/customers/me       → Update profile       │ │
│   │  POST   /api/v1/customers/me/password → Change password  │ │
│   │  GET    /api/v1/customers/me/addresses → Get addresses   │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   AUTH:                                                           │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  POST   /api/v1/auth/register       → Register user      │ │
│   │  POST   /api/v1/auth/login          → Login              │ │
│   │  POST   /api/v1/auth/refresh        → Refresh token      │ │
│   │  POST   /api/v1/auth/logout         → Logout             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P6.8 API Testing

### P6.8.1 Testing Tools

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API TESTING TOOLS                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. cURL (Command Line)                                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  # Test a GET request                                       │ │
│   │  curl -X GET http://localhost:8000/api/v1/products        │ │
│   │                                                             │ │
│   │  # Test a POST request                                     │ │
│   │  curl -X POST http://localhost:8000/api/v1/products \     │ │
│   │    -H "Content-Type: application/json" \                  │ │
│   │    -H "Authorization: Bearer token" \                    │ │
│   │    -d '{"name": "New Product", "price": 99.99}'          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   2. Postman (GUI Tool)                                          │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  • User-friendly interface                                 │ │
│   │  • Save and organize requests                             │ │
│   │  • Environment variables                                  │ │
│   │  • Generate code for different languages                  │ │
│   │  • Automate tests                                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   3. HTTPie (Modern CLI)                                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  # Simple GET request                                      │ │
│   │  http GET localhost:8000/api/v1/products                 │ │
│   │                                                             │ │
│   │  # POST with JSON                                          │ │
│   │  http POST localhost:8000/api/v1/products \              │ │
│   │    name="New Product" price:=99.99                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P6.9 Why This Matters for ScaleCart

```
┌─────────────────────────────────────────────────────────────────────┐
│                    API IMPORTANCE IN SCALECART                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   The ScaleCart API is the bridge between:                       │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  FRONTEND (Web/Mobile)                                     │ │
│   │  • Customers browse products                               │ │
│   │  • Place orders                                             │ │
│   │  • Manage accounts                                          │ │
│   │  • View order history                                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  API LAYER                                                │ │
│   │  • Validates requests                                     │ │
│   │  • Authenticates users                                    │ │
│   │  • Enforces business rules                                │ │
│   │  • Formats responses                                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  DATABASE LAYER                                           │ │
│   │  • PostgreSQL (primary)                                    │ │
│   │  • Redis (cache)                                           │ │
│   │  • MongoDB (documents)                                    │ │
│   │  • Neo4j (graph)                                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   The API protects the database by:                              │
│   • Preventing direct database access                           │ │
│   • Validating all input                                        │ │
│   • Enforcing business rules                                    │ │
│   • Controlling access with authentication                      │ │
│   • Rate limiting to prevent abuse                             │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P6.10 Glossary of New Terms

| Term | Definition |
|------|------------|
| **API** | Application Programming Interface - how applications communicate |
| **REST** | Representational State Transfer - common API architecture style |
| **GraphQL** | Query language for APIs that allows clients to specify data needs |
| **gRPC** | High-performance RPC framework using Protocol Buffers |
| **Endpoint** | A specific URL that exposes API functionality |
| **JWT** | JSON Web Token - compact authentication token |
| **OAuth2** | Industry standard for authorization |
| **Rate Limiting** | Restricting the number of API requests per time period |
| **OpenAPI** | Specification for describing REST APIs |
| **Swagger** | Set of tools for designing and documenting APIs |
| **SDK** | Software Development Kit - client libraries for APIs |
| **Webhook** | Callback endpoint for real-time notifications |

---

## P6.11 Summary

### P6.11.1 Key Takeaways

1. **APIs are how applications talk to databases** – They provide a controlled interface.

2. **REST is the most common API style** – Uses HTTP methods and URLs.

3. **Authentication protects APIs** – JWT, API keys, and OAuth2 are common methods.

4. **Documentation is essential** – OpenAPI/Swagger makes APIs easier to use.

5. **APIs protect databases** – They validate input, enforce rules, and control access.

6. **ScaleCart uses a REST API** – Built with FastAPI and documented with OpenAPI.

### P6.11.2 What's Next?

You've completed all six primers! You're now ready for the full main series.

---

## P6.12 Quick Quiz

Test your understanding:

1. **What does API stand for?**
   - A) Application Protocol Interface
   - B) Application Programming Interface
   - C) Automated Program Interface
   - D) Advanced Protocol Integration

2. **Which HTTP method is used to read data?**
   - A) POST
   - B) PUT
   - C) GET
   - D) DELETE

3. **What is a JWT?**
   - A) A database type
   - B) A JSON Web Token
   - C) A programming language
   - D) A cloud service

4. **Which API style lets you request exactly what you need?**
   - A) REST
   - B) GraphQL
   - C) SOAP
   - D) JSON-RPC

5. **What is API versioning?**
   - A) Changing the API version number
   - B) Supporting multiple API versions simultaneously
   - C) Upgrading the database
   - D) Adding new endpoints

**Answers:** 1-B, 2-C, 3-B, 4-B, 5-B

---

**[END OF PRIMER 6]**

