# APPENDIX B — Complete API Reference

## Full REST API Documentation for ScaleCart

---

## B.1 Introduction

This appendix provides the complete API reference for the ScaleCart platform. All endpoints are RESTful, use JSON for request/response bodies, and require authentication where noted.

**Base URL:** `http://localhost:8000/api/v1`

**Authentication:** JWT Bearer token (except public endpoints)

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
```

**Error Responses:**
```json
{
    "error": {
        "code": "ERROR_CODE",
        "message": "Human readable message",
        "details": {},
        "timestamp": "2026-01-01T12:00:00Z"
    }
}
```

---

## B.2 Authentication Endpoints

### B.2.1 Register Customer

**Endpoint:** `POST /auth/register`

**Description:** Create a new customer account.

**Request Body:**
```json
{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "full_name": "John Doe",
    "phone": "+1234567890"
}
```

**Validation Rules:**
- `email`: Valid email format, unique
- `password`: Minimum 8 characters, at least one number and special character
- `full_name`: Required, max 100 characters

**Response (201 Created):**
```json
{
    "id": 42,
    "email": "user@example.com",
    "full_name": "John Doe",
    "registered_at": "2026-01-01T12:00:00Z",
    "is_active": true,
    "is_verified": false
}
```

**Error Responses:**
- `400`: Invalid input
- `409`: Email already exists

---

### B.2.2 Login

**Endpoint:** `POST /auth/login`

**Description:** Authenticate and receive JWT token.

**Request Body:**
```json
{
    "email": "user@example.com",
    "password": "SecurePass123!"
}
```

**Response (200 OK):**
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "token_type": "bearer",
    "expires_in": 86400,
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
        "id": 42,
        "email": "user@example.com",
        "full_name": "John Doe"
    }
}
```

---

### B.2.3 Refresh Token

**Endpoint:** `POST /auth/refresh`

**Description:** Get a new access token using refresh token.

**Request Body:**
```json
{
    "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 86400
}
```

---

### B.2.4 Logout

**Endpoint:** `POST /auth/logout`

**Description:** Invalidate current token.

**Headers:** Authorization required

**Response (200 OK):**
```json
{
    "message": "Logged out successfully"
}
```

---

## B.3 Product Endpoints

### B.3.1 List Products

**Endpoint:** `GET /products`

**Description:** Get paginated list of products with filtering.

**Query Parameters:**
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | integer | Page number | 1 |
| `limit` | integer | Items per page (max 100) | 20 |
| `category_id` | integer | Filter by category | 5 |
| `min_price` | decimal | Minimum price | 10.00 |
| `max_price` | decimal | Maximum price | 100.00 |
| `search` | string | Search in name/description | "laptop" |
| `sort_by` | string | Sort field | "price", "name", "created_at" |
| `sort_order` | string | "asc" or "desc" | "desc" |

**Response (200 OK):**
```json
{
    "data": [
        {
            "id": 1,
            "name": "MacBook Pro 16",
            "description": "High-performance laptop with M2 Pro chip",
            "price": "2499.99",
            "category_id": 4,
            "category_name": "Laptops",
            "stock_quantity": 50,
            "average_rating": 4.8,
            "review_count": 125,
            "created_at": "2026-01-01T12:00:00Z"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 1000,
        "pages": 50
    }
}
```

---

### B.3.2 Get Product by ID

**Endpoint:** `GET /products/{product_id}`

**Description:** Get detailed product information.

**Response (200 OK):**
```json
{
    "id": 1,
    "name": "MacBook Pro 16",
    "description": "High-performance laptop with M2 Pro chip",
    "price": "2499.99",
    "category": {
        "id": 4,
        "name": "Laptops",
        "parent_category": "Electronics"
    },
    "suppliers": [
        {
            "id": 1,
            "name": "TechSupply Co.",
            "supply_price": "2000.00",
            "is_preferred": true
        }
    ],
    "inventory": {
        "stock_quantity": 50,
        "reserved_quantity": 3,
        "available": 47,
        "reorder_threshold": 10
    },
    "reviews": {
        "average_rating": 4.8,
        "total_reviews": 125,
        "rating_distribution": {
            "5": 80,
            "4": 30,
            "3": 10,
            "2": 3,
            "1": 2
        }
    },
    "created_at": "2026-01-01T12:00:00Z",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

**Error Responses:**
- `404`: Product not found

---

### B.3.3 Create Product (Admin)

**Endpoint:** `POST /products`

**Description:** Create a new product.

**Headers:** Authorization required (admin)

**Request Body:**
```json
{
    "name": "New Product",
    "description": "Product description",
    "price": "99.99",
    "category_id": 5,
    "weight_kg": 1.5,
    "sku": "PROD-001"
}
```

**Response (201 Created):**
```json
{
    "id": 1001,
    "name": "New Product",
    "sku": "PROD-001",
    "created_at": "2026-01-01T12:00:00Z"
}
```

---

### B.3.4 Update Product (Admin)

**Endpoint:** `PUT /products/{product_id}`

**Description:** Update product details.

**Headers:** Authorization required (admin)

**Request Body:** (All fields optional)
```json
{
    "name": "Updated Product Name",
    "price": "109.99",
    "description": "Updated description"
}
```

**Response (200 OK):**
```json
{
    "id": 1001,
    "name": "Updated Product Name",
    "price": "109.99",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

---

### B.3.5 Delete Product (Admin)

**Endpoint:** `DELETE /products/{product_id}`

**Description:** Delete a product (soft delete).

**Headers:** Authorization required (admin)

**Response (204 No Content)**

---

### B.3.6 Get Product Recommendations

**Endpoint:** `GET /products/{product_id}/recommendations`

**Description:** Get similar/recommended products using graph database.

**Query Parameters:**
- `limit`: Number of recommendations (default: 10)

**Response (200 OK):**
```json
{
    "data": [
        {
            "id": 2,
            "name": "Dell XPS 13",
            "price": "1899.99",
            "similarity_score": 0.87
        }
    ],
    "source": "graph_database"
}
```

---

## B.4 Order Endpoints

### B.4.1 Create Order

**Endpoint:** `POST /orders`

**Description:** Place a new order with atomic transaction.

**Headers:** Authorization required

**Request Body:**
```json
{
    "customer_id": 42,
    "items": [
        {
            "product_id": 1,
            "quantity": 2
        },
        {
            "product_id": 5,
            "quantity": 1
        }
    ],
    "shipping_address_id": 10,
    "billing_address_id": 10,
    "payment_method": "credit_card",
    "notes": "Leave at front door"
}
```

**Response (201 Created):**
```json
{
    "id": 1001,
    "order_number": "ORD-2026-0001001",
    "customer_id": 42,
    "status": "pending",
    "total_amount": "5014.97",
    "items": [
        {
            "product_id": 1,
            "quantity": 2,
            "unit_price": "2499.99",
            "subtotal": "4999.98"
        },
        {
            "product_id": 5,
            "quantity": 1,
            "unit_price": "14.99",
            "subtotal": "14.99"
        }
    ],
    "payment": {
        "id": 1001,
        "amount": "5014.97",
        "method": "credit_card",
        "status": "pending"
    },
    "created_at": "2026-01-01T12:00:00Z"
}
```

**Error Responses:**
- `400`: Invalid input or insufficient stock
- `409`: Conflict (e.g., product unavailable)

---

### B.4.2 Get Order by ID

**Endpoint:** `GET /orders/{order_id}`

**Description:** Get order details.

**Headers:** Authorization required (customer or admin)

**Response (200 OK):**
```json
{
    "id": 1001,
    "order_number": "ORD-2026-0001001",
    "customer": {
        "id": 42,
        "full_name": "John Doe",
        "email": "john@example.com"
    },
    "status": "shipped",
    "total_amount": "5014.97",
    "items": [
        {
            "product_id": 1,
            "product_name": "MacBook Pro 16",
            "quantity": 2,
            "unit_price": "2499.99",
            "subtotal": "4999.98"
        }
    ],
    "shipping_address": {
        "street": "123 Maple St",
        "city": "Springfield",
        "state": "IL",
        "postal_code": "62701",
        "country": "USA"
    },
    "payments": [
        {
            "id": 1001,
            "amount": "5014.97",
            "method": "credit_card",
            "status": "completed",
            "payment_date": "2026-01-01T12:00:00Z"
        }
    ],
    "order_date": "2026-01-01T12:00:00Z",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

---

### B.4.3 List Customer Orders

**Endpoint:** `GET /orders`

**Description:** Get orders for authenticated customer.

**Headers:** Authorization required

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Filter by status |
| `start_date` | date | Orders from date |
| `end_date` | date | Orders until date |
| `page` | integer | Page number |
| `limit` | integer | Items per page |

**Response (200 OK):**
```json
{
    "data": [
        {
            "id": 1001,
            "order_number": "ORD-2026-0001001",
            "status": "shipped",
            "total_amount": "5014.97",
            "item_count": 2,
            "order_date": "2026-01-01T12:00:00Z"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 50,
        "pages": 3
    }
}
```

---

### B.4.4 Update Order Status

**Endpoint:** `PATCH /orders/{order_id}/status`

**Description:** Update order status.

**Headers:** Authorization required (admin)

**Request Body:**
```json
{
    "status": "shipped",
    "tracking_number": "1Z999AA10123456784",
    "carrier": "UPS"
}
```

**Response (200 OK):**
```json
{
    "id": 1001,
    "status": "shipped",
    "tracking_number": "1Z999AA10123456784",
    "carrier": "UPS",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

**Allowed Status Transitions:**
- `pending` → `paid`, `cancelled`
- `paid` → `shipped`, `refunded`
- `shipped` → `delivered`
- `delivered` → `refunded`

---

### B.4.5 Cancel Order

**Endpoint:** `POST /orders/{order_id}/cancel`

**Description:** Cancel an order and restore inventory.

**Headers:** Authorization required

**Request Body:**
```json
{
    "reason": "Changed my mind"
}
```

**Response (200 OK):**
```json
{
    "id": 1001,
    "status": "cancelled",
    "refund": {
        "amount": "5014.97",
        "status": "pending"
    },
    "cancelled_at": "2026-01-01T12:00:00Z"
}
```

---

## B.5 Customer Endpoints

### B.5.1 Get Current Customer Profile

**Endpoint:** `GET /customers/me`

**Description:** Get authenticated customer's profile.

**Headers:** Authorization required

**Response (200 OK):**
```json
{
    "id": 42,
    "email": "john@example.com",
    "full_name": "John Doe",
    "phone": "+1234567890",
    "registered_at": "2025-12-01T10:00:00Z",
    "last_login": "2026-01-01T12:00:00Z",
    "is_verified": true,
    "addresses": [
        {
            "id": 10,
            "type": "shipping",
            "street": "123 Maple St",
            "city": "Springfield",
            "state": "IL",
            "postal_code": "62701",
            "country": "USA",
            "is_default": true
        }
    ],
    "statistics": {
        "total_orders": 25,
        "total_spent": "12500.00",
        "average_order_value": "500.00",
        "last_order_date": "2026-01-01T12:00:00Z"
    }
}
```

---

### B.5.2 Update Customer Profile

**Endpoint:** `PUT /customers/me`

**Description:** Update profile information.

**Headers:** Authorization required

**Request Body:**
```json
{
    "full_name": "Johnathan Doe",
    "phone": "+19876543210"
}
```

**Response (200 OK):**
```json
{
    "id": 42,
    "full_name": "Johnathan Doe",
    "phone": "+19876543210",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

---

### B.5.3 Change Password

**Endpoint:** `POST /customers/me/change-password`

**Description:** Update password.

**Headers:** Authorization required

**Request Body:**
```json
{
    "current_password": "OldPass123!",
    "new_password": "NewPass456!"
}
```

**Response (200 OK):**
```json
{
    "message": "Password updated successfully"
}
```

**Error Responses:**
- `401`: Current password incorrect

---

### B.5.4 Add Address

**Endpoint:** `POST /customers/me/addresses`

**Description:** Add a new address.

**Headers:** Authorization required

**Request Body:**
```json
{
    "type": "shipping",
    "street": "456 Oak Ave",
    "city": "Springfield",
    "state": "IL",
    "postal_code": "62702",
    "country": "USA",
    "is_default": false
}
```

**Response (201 Created):**
```json
{
    "id": 11,
    "customer_id": 42,
    "type": "shipping",
    "street": "456 Oak Ave",
    "city": "Springfield",
    "state": "IL",
    "postal_code": "62702",
    "country": "USA",
    "is_default": false,
    "created_at": "2026-01-01T12:00:00Z"
}
```

---

### B.5.5 Update Address

**Endpoint:** `PUT /customers/me/addresses/{address_id}`

**Description:** Update address details.

**Headers:** Authorization required

**Request Body:** (All fields optional)
```json
{
    "street": "789 Pine Rd",
    "is_default": true
}
```

**Response (200 OK):**
```json
{
    "id": 11,
    "street": "789 Pine Rd",
    "is_default": true,
    "updated_at": "2026-01-01T12:00:00Z"
}
```

---

### B.5.6 Delete Address

**Endpoint:** `DELETE /customers/me/addresses/{address_id}`

**Description:** Delete an address.

**Headers:** Authorization required

**Response (204 No Content)**

---

## B.6 Inventory Endpoints

### B.6.1 Check Product Stock

**Endpoint:** `GET /inventory/{product_id}`

**Description:** Check stock levels for a product.

**Response (200 OK):**
```json
{
    "product_id": 1,
    "product_name": "MacBook Pro 16",
    "stock_quantity": 50,
    "reserved_quantity": 3,
    "available_quantity": 47,
    "reorder_threshold": 10,
    "status": "in_stock"
}
```

**Status Values:**
- `in_stock`: Available > 10
- `low_stock`: Available between 1-10
- `out_of_stock`: Available = 0

---

### B.6.2 Update Stock (Admin)

**Endpoint:** `PATCH /inventory/{product_id}`

**Description:** Update inventory levels.

**Headers:** Authorization required (admin)

**Request Body:**
```json
{
    "stock_quantity": 75,
    "reorder_threshold": 15,
    "reorder_quantity": 100
}
```

**Response (200 OK):**
```json
{
    "product_id": 1,
    "stock_quantity": 75,
    "previous_stock": 50,
    "change": 25,
    "last_updated": "2026-01-01T12:00:00Z"
}
```

---

### B.6.3 Get Low Stock Products (Admin)

**Endpoint:** `GET /inventory/low-stock`

**Description:** Get products below reorder threshold.

**Headers:** Authorization required (admin)

**Query Parameters:**
- `limit`: Max products to return (default: 50)

**Response (200 OK):**
```json
{
    "data": [
        {
            "product_id": 42,
            "product_name": "Popular Item",
            "stock_quantity": 5,
            "reorder_threshold": 20,
            "reorder_quantity": 50,
            "deficit": 15
        }
    ],
    "count": 1
}
```

---

## B.7 Review Endpoints

### B.7.1 Get Product Reviews

**Endpoint:** `GET /products/{product_id}/reviews`

**Description:** Get all reviews for a product.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `rating` | integer | Filter by rating (1-5) |
| `sort_by` | string | "date", "rating", "helpful" |
| `page` | integer | Page number |
| `limit` | integer | Items per page |

**Response (200 OK):**
```json
{
    "data": [
        {
            "id": 123,
            "customer": {
                "id": 42,
                "name": "John Doe",
                "is_verified": true
            },
            "rating": 5,
            "title": "Amazing product!",
            "comment": "Exceeded all expectations.",
            "helpful_count": 15,
            "is_verified_purchase": true,
            "review_date": "2026-01-01T12:00:00Z"
        }
    ],
    "summary": {
        "average_rating": 4.8,
        "total_reviews": 125,
        "rating_distribution": {
            "5": 80,
            "4": 30,
            "3": 10,
            "2": 3,
            "1": 2
        }
    },
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 125,
        "pages": 7
    }
}
```

---

### B.7.2 Create Review

**Endpoint:** `POST /products/{product_id}/reviews`

**Description:** Submit a product review.

**Headers:** Authorization required (must have purchased product)

**Request Body:**
```json
{
    "rating": 5,
    "title": "Excellent product",
    "comment": "Highly recommend this!",
    "is_verified_purchase": true
}
```

**Response (201 Created):**
```json
{
    "id": 124,
    "product_id": 1,
    "customer_id": 42,
    "rating": 5,
    "title": "Excellent product",
    "comment": "Highly recommend this!",
    "is_verified_purchase": true,
    "created_at": "2026-01-01T12:00:00Z"
}
```

**Error Responses:**
- `400`: Already reviewed this product
- `403`: No verified purchase

---

### B.7.3 Update Review

**Endpoint:** `PUT /reviews/{review_id}`

**Description:** Update your review.

**Headers:** Authorization required (review owner)

**Request Body:**
```json
{
    "rating": 4,
    "comment": "Updated review"
}
```

**Response (200 OK):**
```json
{
    "id": 124,
    "rating": 4,
    "comment": "Updated review",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

---

### B.7.4 Mark Review Helpful

**Endpoint:** `POST /reviews/{review_id}/helpful`

**Description:** Mark a review as helpful.

**Headers:** Authorization required

**Response (200 OK):**
```json
{
    "review_id": 124,
    "helpful_count": 16
}
```

---

## B.8 Cart & Session Endpoints

### B.8.1 Get Cart

**Endpoint:** `GET /cart`

**Description:** Get current user's cart.

**Headers:** Authorization required

**Response (200 OK):**
```json
{
    "items": [
        {
            "product_id": 1,
            "product_name": "MacBook Pro 16",
            "quantity": 2,
            "unit_price": "2499.99",
            "subtotal": "4999.98"
        }
    ],
    "total_items": 2,
    "total_amount": "5014.97",
    "created_at": "2026-01-01T12:00:00Z",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

---

### B.8.2 Add to Cart

**Endpoint:** `POST /cart/items`

**Description:** Add item to cart.

**Headers:** Authorization required

**Request Body:**
```json
{
    "product_id": 1,
    "quantity": 1
}
```

**Response (200 OK):**
```json
{
    "item": {
        "product_id": 1,
        "product_name": "MacBook Pro 16",
        "quantity": 1,
        "unit_price": "2499.99",
        "subtotal": "2499.99"
    },
    "cart_total": "7514.96"
}
```

---

### B.8.3 Update Cart Item

**Endpoint:** `PUT /cart/items/{product_id}`

**Description:** Update quantity of cart item.

**Headers:** Authorization required

**Request Body:**
```json
{
    "quantity": 3
}
```

**Response (200 OK):**
```json
{
    "product_id": 1,
    "quantity": 3,
    "subtotal": "7499.97",
    "cart_total": "10014.94"
}
```

---

### B.8.4 Remove Cart Item

**Endpoint:** `DELETE /cart/items/{product_id}`

**Description:** Remove item from cart.

**Headers:** Authorization required

**Response (204 No Content)**

---

### B.8.5 Clear Cart

**Endpoint:** `DELETE /cart`

**Description:** Clear entire cart.

**Headers:** Authorization required

**Response (204 No Content)**

---

## B.9 Analytics & Reporting Endpoints

### B.9.1 Get Sales Analytics (Admin)

**Endpoint:** `GET /analytics/sales`

**Description:** Get sales metrics over time.

**Headers:** Authorization required (admin)

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `start_date` | date | Start date (YYYY-MM-DD) |
| `end_date` | date | End date (YYYY-MM-DD) |
| `group_by` | string | "day", "week", "month" |
| `category_id` | integer | Filter by category |

**Response (200 OK):**
```json
{
    "period": {
        "start": "2026-01-01",
        "end": "2026-01-31",
        "days": 31
    },
    "summary": {
        "total_orders": 1250,
        "total_revenue": "125000.00",
        "average_order_value": "100.00",
        "total_items_sold": 2500
    },
    "daily_data": [
        {
            "date": "2026-01-01",
            "orders": 42,
            "revenue": "4200.00",
            "items_sold": 85
        }
    ],
    "top_products": [
        {
            "product_id": 1,
            "name": "MacBook Pro 16",
            "quantity_sold": 25,
            "revenue": "62499.75"
        }
    ]
}
```

---

### B.9.2 Get Customer Analytics (Admin)

**Endpoint:** `GET /analytics/customers`

**Description:** Get customer behavior metrics.

**Headers:** Authorization required (admin)

**Query Parameters:**
- `start_date`: Start date
- `end_date`: End date

**Response (200 OK):**
```json
{
    "summary": {
        "total_customers": 5000,
        "new_customers": 250,
        "active_customers": 1200,
        "churn_rate": "5.2%"
    },
    "cohort_data": [
        {
            "cohort_month": "2025-12",
            "customers": 300,
            "revenue": "15000.00",
            "retention_rate": "85.3%"
        }
    ],
    "top_customers": [
        {
            "customer_id": 42,
            "name": "John Doe",
            "total_orders": 25,
            "total_spent": "12500.00",
            "average_order": "500.00"
        }
    ]
}
```

---

### B.9.3 Get Product Performance (Admin)

**Endpoint:** `GET /analytics/products/{product_id}`

**Description:** Get performance metrics for a product.

**Headers:** Authorization required (admin)

**Response (200 OK):**
```json
{
    "product_id": 1,
    "name": "MacBook Pro 16",
    "metrics": {
        "total_orders": 125,
        "total_units_sold": 250,
        "total_revenue": "624999.50",
        "average_rating": 4.8,
        "return_rate": "1.2%",
        "conversion_rate": "4.5%"
    },
    "daily_views": [
        {
            "date": "2026-01-01",
            "views": 450
        }
    ],
    "top_customers": [
        {
            "customer_id": 42,
            "orders": 3,
            "units": 5,
            "revenue": "12499.95"
        }
    ]
}
```

---

### B.9.4 Get Real-Time Metrics

**Endpoint:** `GET /analytics/realtime`

**Description:** Get real-time metrics from TimescaleDB.

**Headers:** Authorization required (admin)

**Response (200 OK):**
```json
{
    "active_sessions": 1250,
    "orders_last_hour": 45,
    "revenue_last_hour": "4500.00",
    "top_viewed_products": [
        {
            "product_id": 1,
            "views_last_hour": 250
        }
    ],
    "system_health": {
        "response_time": "45ms",
        "error_rate": "0.12%",
        "db_connections": 25
    },
    "timestamp": "2026-01-01T12:00:00Z"
}
```

---

## B.10 Admin Endpoints

### B.10.1 Get System Health

**Endpoint:** `GET /admin/health`

**Description:** Comprehensive system health check.

**Headers:** Authorization required (admin)

**Response (200 OK):**
```json
{
    "status": "healthy",
    "timestamp": "2026-01-01T12:00:00Z",
    "services": {
        "database": {
            "status": "online",
            "connections": 25,
            "max_connections": 100,
            "lag": 0
        },
        "redis": {
            "status": "online",
            "memory_used": "125MB",
            "memory_total": "512MB",
            "connected_clients": 10
        },
        "mongodb": {
            "status": "online",
            "connections": 5,
            "indexes": 12
        },
        "neo4j": {
            "status": "online",
            "nodes": 25000,
            "relationships": 125000
        }
    },
    "warnings": [
        "Database connections at 25%"
    ]
}
```

---

### B.10.2 Get Database Statistics

**Endpoint:** `GET /admin/db/stats`

**Description:** Get detailed database statistics.

**Headers:** Authorization required (admin)

**Response (200 OK):**
```json
{
    "tables": {
        "products": {
            "row_count": 1000000,
            "size": "125MB",
            "index_size": "45MB",
            "last_vacuum": "2026-01-01T10:00:00Z",
            "dead_tuples": 150
        }
    },
    "queries": {
        "slowest": [
            {
                "query": "SELECT * FROM products WHERE ...",
                "execution_time": "250ms",
                "frequency": 1250
            }
        ],
        "total_queries": 45000,
        "cache_hit_ratio": "92.5%"
    },
    "connections": {
        "active": 25,
        "idle": 10,
        "max": 100
    }
}
```

---

### B.10.3 Run Database Maintenance

**Endpoint:** `POST /admin/db/maintenance`

**Description:** Trigger database maintenance tasks.

**Headers:** Authorization required (admin)

**Request Body:**
```json
{
    "tasks": ["vacuum", "analyze", "reindex"],
    "tables": ["products", "orders"]  // Optional, all if omitted
}
```

**Response (202 Accepted):**
```json
{
    "job_id": "maintenance-123",
    "status": "running",
    "tasks": ["vacuum", "analyze", "reindex"],
    "started_at": "2026-01-01T12:00:00Z",
    "estimated_completion": "2026-01-01T12:15:00Z"
}
```

---

### B.10.4 Clear Cache

**Endpoint:** `POST /admin/cache/clear`

**Description:** Clear all cached data.

**Headers:** Authorization required (admin)

**Request Body:**
```json
{
    "cache_type": ["product", "session", "all"]  // All if omitted
}
```

**Response (200 OK):**
```json
{
    "cleared": ["product_cache", "session_cache"],
    "timestamp": "2026-01-01T12:00:00Z"
}
```

---

## B.11 Webhook Endpoints

### B.11.1 Stripe Webhook

**Endpoint:** `POST /webhooks/stripe`

**Description:** Receive Stripe payment events.

**Headers:**
- `Stripe-Signature`: Webhook signature for verification

**Request Body:** (Stripe event object)

**Response (200 OK):**
```json
{
    "received": true
}
```

---

### B.11.2 Payment Status Callback

**Endpoint:** `POST /webhooks/payment/{payment_id}`

**Description:** External payment provider callback.

**Request Body:**
```json
{
    "status": "completed",
    "transaction_id": "txn_123456",
    "metadata": {}
}
```

**Response (200 OK):**
```json
{
    "payment_id": 1001,
    "status": "completed",
    "updated_at": "2026-01-01T12:00:00Z"
}
```

---

## B.12 Rate Limiting

All endpoints have rate limiting applied:

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| Public endpoints | 100 requests | 1 minute |
| Authenticated endpoints | 1000 requests | 1 minute |
| Admin endpoints | 100 requests | 1 minute |
| Auth endpoints | 10 requests | 1 minute |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 98
X-RateLimit-Reset: 1641024000
```

**Rate Limit Exceeded Response (429):**
```json
{
    "error": {
        "code": "RATE_LIMIT_EXCEEDED",
        "message": "Too many requests. Please wait 60 seconds.",
        "retry_after": 60
    }
}
```

---

## B.13 API Versioning

The API uses URL versioning:

- Current version: `v1`
- Future versions: `v2`, `v3`, etc.

**Deprecation Headers:**
```
Deprecation: true
Sunset: Tue, 31 Dec 2026 23:59:59 GMT
```

---

## B.14 Authentication Flow Example

### Complete Authentication Flow:

```bash
# 1. Register
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!",
    "full_name": "John Doe"
  }'

# 2. Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!"
  }'

# Response includes access_token
# {"access_token": "eyJ...", "refresh_token": "eyJ..."}

# 3. Use access token for protected endpoints
curl -X GET http://localhost:8000/api/v1/products/1 \
  -H "Authorization: Bearer eyJ..."

# 4. Refresh token when expired
curl -X POST http://localhost:8000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "eyJ..."}'
```

---

## B.15 SDK Examples

### Python SDK Example:

```python
# File: scalecart_sdk.py
import requests
from typing import Optional, Dict, List

class ScaleCartClient:
    def __init__(self, base_url: str = "http://localhost:8000/api/v1"):
        self.base_url = base_url
        self.token: Optional[str] = None
        self.session = requests.Session()
        self.session.headers.update({"Content-Type": "application/json"})

    def login(self, email: str, password: str) -> Dict:
        response = self.session.post(
            f"{self.base_url}/auth/login",
            json={"email": email, "password": password}
        )
        response.raise_for_status()
        data = response.json()
        self.token = data["access_token"]
        self.session.headers.update({"Authorization": f"Bearer {self.token}"})
        return data

    def get_products(self, page: int = 1, limit: int = 20, **filters) -> Dict:
        params = {"page": page, "limit": limit, **filters}
        response = self.session.get(f"{self.base_url}/products", params=params)
        response.raise_for_status()
        return response.json()

    def place_order(self, customer_id: int, items: List[Dict]) -> Dict:
        response = self.session.post(
            f"{self.base_url}/orders",
            json={"customer_id": customer_id, "items": items}
        )
        response.raise_for_status()
        return response.json()

    def get_order(self, order_id: int) -> Dict:
        response = self.session.get(f"{self.base_url}/orders/{order_id}")
        response.raise_for_status()
        return response.json()

# Usage
client = ScaleCartClient()
client.login("john@example.com", "SecurePass123!")
products = client.get_products(category_id=5, min_price=100)
order = client.place_order(42, [{"product_id": 1, "quantity": 2}])
```

---

## B.16 OpenAPI Specification

The API is fully documented with OpenAPI 3.0. You can access:

- **Interactive Swagger UI:** `http://localhost:8000/docs`
- **ReDoc UI:** `http://localhost:8000/redoc`
- **OpenAPI JSON:** `http://localhost:8000/openapi.json`

### B.16.1 Export OpenAPI Specification

```bash
# Download OpenAPI spec
curl http://localhost:8000/openapi.json > openapi.json

# Generate client SDK (using openapi-generator)
openapi-generator generate -i openapi.json -g python -o python-client

# Validate API
swagger-cli validate openapi.json
```

---

**[END OF APPENDIX B]**

*This API reference provides comprehensive documentation for all ScaleCart endpoints. Use it alongside the OpenAPI specification for complete integration guidance.*
