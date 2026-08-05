# APPENDIX O — Complete API Client SDK

## Official ScaleCart Client Libraries

---

## O.1 Introduction

This appendix provides complete SDK implementations for interacting with the ScaleCart API from various programming languages. It covers:

1. **Python SDK** – Full-featured Python client
2. **JavaScript/TypeScript SDK** – Node.js and browser client
3. **cURL Examples** – Command-line usage
4. **Postman Collection** – API testing collection
5. **OpenAPI Generator** – Auto-generating clients

---

## O.2 Python SDK

### O.2.1 Complete Python Client

```python
# File: scalecart/client.py
"""
ScaleCart Python SDK

Example usage:
    from scalecart import ScaleCartClient
    
    client = ScaleCartClient(
        base_url="https://api.scalecart.com",
        api_key="your-api-key"
    )
    
    # Get products
    products = client.products.list(limit=10)
    
    # Create order
    order = client.orders.create(
        customer_id=123,
        items=[{"product_id": 1, "quantity": 2}]
    )
"""

import json
import time
from typing import Optional, Dict, Any, List, Union
from dataclasses import dataclass, asdict
from enum import Enum
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# ============================================
# EXCEPTIONS
# ============================================

class ScaleCartError(Exception):
    """Base exception for ScaleCart SDK."""
    pass

class AuthenticationError(ScaleCartError):
    """Authentication failed."""
    pass

class NotFoundError(ScaleCartError):
    """Resource not found."""
    pass

class ValidationError(ScaleCartError):
    """Request validation failed."""
    pass

class RateLimitError(ScaleCartError):
    """Rate limit exceeded."""
    pass

class ServerError(ScaleCartError):
    """Server-side error."""
    pass

# ============================================
# ENUMS
# ============================================

class OrderStatus(str, Enum):
    PENDING = "pending"
    PAID = "paid"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"
    REFUNDED = "refunded"

class PaymentStatus(str, Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    REFUNDED = "refunded"

class PaymentMethod(str, Enum):
    CREDIT_CARD = "credit_card"
    PAYPAL = "paypal"
    BANK_TRANSFER = "bank_transfer"
    APPLE_PAY = "apple_pay"
    GOOGLE_PAY = "google_pay"

# ============================================
# DATA CLASSES
# ============================================

@dataclass
class Product:
    """Product data class."""
    id: int
    name: str
    price: float
    description: Optional[str] = None
    category_id: Optional[int] = None
    category_name: Optional[str] = None
    stock_quantity: Optional[int] = None
    average_rating: Optional[float] = None
    review_count: Optional[int] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    @classmethod
    def from_dict(cls, data: dict) -> "Product":
        return cls(**{k: v for k, v in data.items() if k in cls.__annotations__})

@dataclass
class Customer:
    """Customer data class."""
    id: int
    email: str
    full_name: str
    phone: Optional[str] = None
    registered_at: Optional[str] = None
    is_verified: bool = False
    is_active: bool = True

    @classmethod
    def from_dict(cls, data: dict) -> "Customer":
        return cls(**{k: v for k, v in data.items() if k in cls.__annotations__})

@dataclass
class OrderItem:
    """Order item data class."""
    product_id: int
    product_name: Optional[str] = None
    quantity: int = 1
    unit_price: float = 0.0
    subtotal: float = 0.0
    discount_percent: float = 0.0

@dataclass
class Order:
    """Order data class."""
    id: int
    customer_id: int
    status: OrderStatus
    total_amount: float
    items: List[OrderItem]
    order_date: Optional[str] = None
    shipping_address: Optional[Dict] = None
    billing_address: Optional[Dict] = None
    notes: Optional[str] = None

    @classmethod
    def from_dict(cls, data: dict) -> "Order":
        items = [OrderItem(**item) for item in data.get("items", [])]
        return cls(
            id=data["id"],
            customer_id=data["customer_id"],
            status=OrderStatus(data["status"]),
            total_amount=data["total_amount"],
            items=items,
            order_date=data.get("order_date"),
            shipping_address=data.get("shipping_address"),
            billing_address=data.get("billing_address"),
            notes=data.get("notes")
        )

# ============================================
# BASE CLIENT
# ============================================

class BaseClient:
    """Base HTTP client with retry logic."""
    
    def __init__(
        self,
        base_url: str,
        api_key: Optional[str] = None,
        timeout: int = 30,
        max_retries: int = 3
    ):
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self.timeout = timeout
        
        # Setup session with retry
        self.session = requests.Session()
        retry_strategy = Retry(
            total=max_retries,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "PUT", "DELETE", "OPTIONS", "TRACE"]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)
        
        # Set headers
        self.session.headers.update({
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "ScaleCart-Python-SDK/1.0.0"
        })
        
        if api_key:
            self.session.headers.update({
                "Authorization": f"Bearer {api_key}"
            })
    
    def _request(
        self,
        method: str,
        endpoint: str,
        data: Optional[Dict] = None,
        params: Optional[Dict] = None,
        headers: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """Make an HTTP request."""
        url = f"{self.base_url}{endpoint}"
        
        request_headers = self.session.headers.copy()
        if headers:
            request_headers.update(headers)
        
        try:
            response = self.session.request(
                method=method,
                url=url,
                json=data,
                params=params,
                headers=request_headers,
                timeout=self.timeout
            )
            
            # Handle rate limiting
            if response.status_code == 429:
                reset_time = int(response.headers.get("X-RateLimit-Reset", time.time() + 60))
                retry_after = max(0, reset_time - time.time())
                raise RateLimitError(
                    f"Rate limit exceeded. Retry after {retry_after:.0f} seconds."
                )
            
            # Handle errors
            if response.status_code >= 400:
                error_data = response.json() if response.content else {}
                error_message = error_data.get("error", {}).get("message", response.text)
                
                if response.status_code == 401:
                    raise AuthenticationError(error_message)
                elif response.status_code == 404:
                    raise NotFoundError(error_message)
                elif response.status_code == 422:
                    raise ValidationError(error_message)
                elif response.status_code >= 500:
                    raise ServerError(error_message)
                else:
                    raise ScaleCartError(f"{response.status_code}: {error_message}")
            
            return response.json() if response.content else {}
            
        except requests.RequestException as e:
            raise ScaleCartError(f"Request failed: {e}")

# ============================================
# RESOURCE CLIENTS
# ============================================

class ProductsClient:
    """Products API client."""
    
    def __init__(self, client: BaseClient):
        self.client = client
    
    def list(
        self,
        page: int = 1,
        limit: int = 20,
        category_id: Optional[int] = None,
        min_price: Optional[float] = None,
        max_price: Optional[float] = None,
        search: Optional[str] = None,
        sort_by: Optional[str] = None,
        sort_order: str = "asc"
    ) -> Dict[str, Any]:
        """List products with pagination and filters."""
        params = {
            "page": page,
            "limit": limit,
            "sort_order": sort_order
        }
        if category_id:
            params["category_id"] = category_id
        if min_price:
            params["min_price"] = min_price
        if max_price:
            params["max_price"] = max_price
        if search:
            params["search"] = search
        if sort_by:
            params["sort_by"] = sort_by
        
        result = self.client._request("GET", "/api/v1/products", params=params)
        result["data"] = [Product.from_dict(p) for p in result.get("data", [])]
        return result
    
    def get(self, product_id: int) -> Product:
        """Get a specific product by ID."""
        result = self.client._request("GET", f"/api/v1/products/{product_id}")
        return Product.from_dict(result)
    
    def create(
        self,
        name: str,
        price: float,
        category_id: int,
        description: Optional[str] = None,
        sku: Optional[str] = None,
        weight_kg: Optional[float] = None
    ) -> Product:
        """Create a new product (admin only)."""
        data = {
            "name": name,
            "price": price,
            "category_id": category_id
        }
        if description:
            data["description"] = description
        if sku:
            data["sku"] = sku
        if weight_kg:
            data["weight_kg"] = weight_kg
        
        result = self.client._request("POST", "/api/v1/products", data=data)
        return Product.from_dict(result)
    
    def update(self, product_id: int, **kwargs) -> Product:
        """Update a product."""
        result = self.client._request("PUT", f"/api/v1/products/{product_id}", data=kwargs)
        return Product.from_dict(result)
    
    def delete(self, product_id: int) -> bool:
        """Delete a product (admin only)."""
        self.client._request("DELETE", f"/api/v1/products/{product_id}")
        return True
    
    def get_recommendations(self, product_id: int, limit: int = 10) -> List[Product]:
        """Get product recommendations."""
        result = self.client._request(
            "GET",
            f"/api/v1/products/{product_id}/recommendations",
            params={"limit": limit}
        )
        return [Product.from_dict(p) for p in result.get("data", [])]

class OrdersClient:
    """Orders API client."""
    
    def __init__(self, client: BaseClient):
        self.client = client
    
    def list(
        self,
        customer_id: Optional[int] = None,
        status: Optional[OrderStatus] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        page: int = 1,
        limit: int = 20
    ) -> Dict[str, Any]:
        """List orders with filters."""
        params = {
            "page": page,
            "limit": limit
        }
        if customer_id:
            params["customer_id"] = customer_id
        if status:
            params["status"] = status.value
        if start_date:
            params["start_date"] = start_date
        if end_date:
            params["end_date"] = end_date
        
        result = self.client._request("GET", "/api/v1/orders", params=params)
        result["data"] = [Order.from_dict(o) for o in result.get("data", [])]
        return result
    
    def get(self, order_id: int) -> Order:
        """Get a specific order by ID."""
        result = self.client._request("GET", f"/api/v1/orders/{order_id}")
        return Order.from_dict(result)
    
    def create(
        self,
        customer_id: int,
        items: List[Dict[str, Any]],
        shipping_address_id: int,
        billing_address_id: int,
        payment_method: PaymentMethod,
        notes: Optional[str] = None
    ) -> Order:
        """Create a new order."""
        data = {
            "customer_id": customer_id,
            "items": items,
            "shipping_address_id": shipping_address_id,
            "billing_address_id": billing_address_id,
            "payment_method": payment_method.value
        }
        if notes:
            data["notes"] = notes
        
        result = self.client._request("POST", "/api/v1/orders", data=data)
        return Order.from_dict(result)
    
    def update_status(self, order_id: int, status: OrderStatus) -> Order:
        """Update order status (admin only)."""
        result = self.client._request(
            "PATCH",
            f"/api/v1/orders/{order_id}/status",
            data={"status": status.value}
        )
        return Order.from_dict(result)
    
    def cancel(self, order_id: int, reason: str = "Cancelled by customer") -> Order:
        """Cancel an order."""
        result = self.client._request(
            "POST",
            f"/api/v1/orders/{order_id}/cancel",
            data={"reason": reason}
        )
        return Order.from_dict(result)

class CustomersClient:
    """Customers API client."""
    
    def __init__(self, client: BaseClient):
        self.client = client
    
    def get_me(self) -> Customer:
        """Get current customer profile."""
        result = self.client._request("GET", "/api/v1/customers/me")
        return Customer.from_dict(result)
    
    def update_me(self, **kwargs) -> Customer:
        """Update current customer profile."""
        result = self.client._request("PUT", "/api/v1/customers/me", data=kwargs)
        return Customer.from_dict(result)
    
    def change_password(self, current_password: str, new_password: str) -> bool:
        """Change password."""
        self.client._request(
            "POST",
            "/api/v1/customers/me/change-password",
            data={
                "current_password": current_password,
                "new_password": new_password
            }
        )
        return True
    
    def get_addresses(self) -> List[Dict[str, Any]]:
        """Get customer addresses."""
        result = self.client._request("GET", "/api/v1/customers/me/addresses")
        return result.get("data", [])
    
    def add_address(self, **address_data) -> Dict[str, Any]:
        """Add a new address."""
        result = self.client._request(
            "POST",
            "/api/v1/customers/me/addresses",
            data=address_data
        )
        return result
    
    def update_address(self, address_id: int, **address_data) -> Dict[str, Any]:
        """Update an address."""
        result = self.client._request(
            "PUT",
            f"/api/v1/customers/me/addresses/{address_id}",
            data=address_data
        )
        return result
    
    def delete_address(self, address_id: int) -> bool:
        """Delete an address."""
        self.client._request("DELETE", f"/api/v1/customers/me/addresses/{address_id}")
        return True

class AuthClient:
    """Authentication API client."""
    
    def __init__(self, client: BaseClient):
        self.client = client
    
    def register(
        self,
        email: str,
        password: str,
        full_name: str,
        phone: Optional[str] = None
    ) -> Dict[str, Any]:
        """Register a new customer."""
        data = {
            "email": email,
            "password": password,
            "full_name": full_name
        }
        if phone:
            data["phone"] = phone
        
        return self.client._request("POST", "/api/v1/auth/register", data=data)
    
    def login(self, email: str, password: str) -> Dict[str, Any]:
        """Login and get tokens."""
        return self.client._request(
            "POST",
            "/api/v1/auth/login",
            data={"email": email, "password": password}
        )
    
    def refresh(self, refresh_token: str) -> Dict[str, Any]:
        """Refresh access token."""
        return self.client._request(
            "POST",
            "/api/v1/auth/refresh",
            data={"refresh_token": refresh_token}
        )
    
    def logout(self) -> bool:
        """Logout (invalidate token)."""
        self.client._request("POST", "/api/v1/auth/logout")
        return True

class InventoryClient:
    """Inventory API client."""
    
    def __init__(self, client: BaseClient):
        self.client = client
    
    def get_stock(self, product_id: int) -> Dict[str, Any]:
        """Get stock information for a product."""
        return self.client._request("GET", f"/api/v1/inventory/{product_id}")
    
    def update_stock(
        self,
        product_id: int,
        stock_quantity: int,
        reorder_threshold: Optional[int] = None
    ) -> Dict[str, Any]:
        """Update stock quantity (admin only)."""
        data = {"stock_quantity": stock_quantity}
        if reorder_threshold:
            data["reorder_threshold"] = reorder_threshold
        
        return self.client._request("PATCH", f"/api/v1/inventory/{product_id}", data=data)
    
    def get_low_stock(self, limit: int = 50) -> List[Dict[str, Any]]:
        """Get products with low stock (admin only)."""
        result = self.client._request(
            "GET",
            "/api/v1/inventory/low-stock",
            params={"limit": limit}
        )
        return result.get("data", [])

class ReviewsClient:
    """Reviews API client."""
    
    def __init__(self, client: BaseClient):
        self.client = client
    
    def list(
        self,
        product_id: int,
        rating: Optional[int] = None,
        sort_by: str = "date",
        page: int = 1,
        limit: int = 20
    ) -> Dict[str, Any]:
        """Get product reviews."""
        params = {
            "page": page,
            "limit": limit,
            "sort_by": sort_by
        }
        if rating:
            params["rating"] = rating
        
        return self.client._request(
            "GET",
            f"/api/v1/products/{product_id}/reviews",
            params=params
        )
    
    def create(
        self,
        product_id: int,
        rating: int,
        title: str,
        comment: str,
        is_verified_purchase: bool = False
    ) -> Dict[str, Any]:
        """Create a review."""
        data = {
            "rating": rating,
            "title": title,
            "comment": comment,
            "is_verified_purchase": is_verified_purchase
        }
        return self.client._request(
            "POST",
            f"/api/v1/products/{product_id}/reviews",
            data=data
        )
    
    def update(self, review_id: int, **kwargs) -> Dict[str, Any]:
        """Update a review."""
        return self.client._request("PUT", f"/api/v1/reviews/{review_id}", data=kwargs)
    
    def mark_helpful(self, review_id: int) -> Dict[str, Any]:
        """Mark a review as helpful."""
        return self.client._request("POST", f"/api/v1/reviews/{review_id}/helpful")

class CartClient:
    """Cart API client."""
    
    def __init__(self, client: BaseClient):
        self.client = client
    
    def get(self) -> Dict[str, Any]:
        """Get current cart."""
        return self.client._request("GET", "/api/v1/cart")
    
    def add_item(self, product_id: int, quantity: int = 1) -> Dict[str, Any]:
        """Add item to cart."""
        return self.client._request(
            "POST",
            "/api/v1/cart/items",
            data={"product_id": product_id, "quantity": quantity}
        )
    
    def update_item(self, product_id: int, quantity: int) -> Dict[str, Any]:
        """Update cart item quantity."""
        return self.client._request(
            "PUT",
            f"/api/v1/cart/items/{product_id}",
            data={"quantity": quantity}
        )
    
    def remove_item(self, product_id: int) -> bool:
        """Remove item from cart."""
        self.client._request("DELETE", f"/api/v1/cart/items/{product_id}")
        return True
    
    def clear(self) -> bool:
        """Clear cart."""
        self.client._request("DELETE", "/api/v1/cart")
        return True

# ============================================
# MAIN CLIENT
# ============================================

class ScaleCartClient:
    """
    Main ScaleCart API client.
    
    Example:
        client = ScaleCartClient(
            base_url="https://api.scalecart.com",
            api_key="your-api-key"
        )
        
        # Get products
        products = client.products.list(limit=10)
        
        # Create order
        order = client.orders.create(
            customer_id=123,
            items=[{"product_id": 1, "quantity": 2}],
            shipping_address_id=1,
            billing_address_id=1,
            payment_method=PaymentMethod.CREDIT_CARD
        )
    """
    
    def __init__(
        self,
        base_url: str = "https://api.scalecart.com",
        api_key: Optional[str] = None,
        timeout: int = 30,
        max_retries: int = 3
    ):
        self._client = BaseClient(base_url, api_key, timeout, max_retries)
        
        # Initialize resource clients
        self.products = ProductsClient(self._client)
        self.orders = OrdersClient(self._client)
        self.customers = CustomersClient(self._client)
        self.auth = AuthClient(self._client)
        self.inventory = InventoryClient(self._client)
        self.reviews = ReviewsClient(self._client)
        self.cart = CartClient(self._client)
    
    def set_api_key(self, api_key: str):
        """Set or update API key."""
        self._client.api_key = api_key
        self._client.session.headers.update({
            "Authorization": f"Bearer {api_key}"
        })
    
    def set_base_url(self, base_url: str):
        """Set or update base URL."""
        self._client.base_url = base_url.rstrip("/")
```

---

## O.3 JavaScript/TypeScript SDK

### O.3.1 TypeScript Client

```typescript
// File: scalecart/client.ts
/**
 * ScaleCart TypeScript SDK
 * 
 * Example:
 *   import { ScaleCartClient } from 'scalecart-sdk';
 *   
 *   const client = new ScaleCartClient({
 *     baseUrl: 'https://api.scalecart.com',
 *     apiKey: 'your-api-key'
 *   });
 *   
 *   // Get products
 *   const products = await client.products.list({ limit: 10 });
 */

// ============================================
// TYPES
// ============================================

export enum OrderStatus {
  PENDING = 'pending',
  PAID = 'paid',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded'
}

export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded'
}

export enum PaymentMethod {
  CREDIT_CARD = 'credit_card',
  PAYPAL = 'paypal',
  BANK_TRANSFER = 'bank_transfer',
  APPLE_PAY = 'apple_pay',
  GOOGLE_PAY = 'google_pay'
}

export interface Product {
  id: number;
  name: string;
  price: number;
  description?: string;
  category_id?: number;
  category_name?: string;
  stock_quantity?: number;
  average_rating?: number;
  review_count?: number;
  created_at?: string;
  updated_at?: string;
}

export interface Customer {
  id: number;
  email: string;
  full_name: string;
  phone?: string;
  registered_at?: string;
  is_verified: boolean;
  is_active: boolean;
}

export interface OrderItem {
  product_id: number;
  product_name?: string;
  quantity: number;
  unit_price: number;
  subtotal: number;
  discount_percent: number;
}

export interface Order {
  id: number;
  customer_id: number;
  status: OrderStatus;
  total_amount: number;
  items: OrderItem[];
  order_date?: string;
  shipping_address?: Record<string, any>;
  billing_address?: Record<string, any>;
  notes?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

// ============================================
// EXCEPTIONS
// ============================================

export class ScaleCartError extends Error {
  constructor(message: string, public statusCode?: number, public data?: any) {
    super(message);
    this.name = 'ScaleCartError';
  }
}

export class AuthenticationError extends ScaleCartError {
  constructor(message: string = 'Authentication failed') {
    super(message, 401);
    this.name = 'AuthenticationError';
  }
}

export class NotFoundError extends ScaleCartError {
  constructor(message: string = 'Resource not found') {
    super(message, 404);
    this.name = 'NotFoundError';
  }
}

export class RateLimitError extends ScaleCartError {
  constructor(public retryAfter: number, message: string = 'Rate limit exceeded') {
    super(message, 429);
    this.name = 'RateLimitError';
  }
}

// ============================================
// HTTP CLIENT
// ============================================

interface ClientConfig {
  baseUrl: string;
  apiKey?: string;
  timeout?: number;
  maxRetries?: number;
}

interface RequestOptions {
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  path: string;
  data?: any;
  params?: Record<string, any>;
  headers?: Record<string, string>;
}

export class HttpClient {
  private baseUrl: string;
  private apiKey?: string;
  private timeout: number;
  private maxRetries: number;

  constructor(config: ClientConfig) {
    this.baseUrl = config.baseUrl.replace(/\/+$/, '');
    this.apiKey = config.apiKey;
    this.timeout = config.timeout || 30000;
    this.maxRetries = config.maxRetries || 3;
  }

  async request<T>(options: RequestOptions): Promise<T> {
    const url = new URL(`${this.baseUrl}${options.path}`);
    
    if (options.params) {
      Object.entries(options.params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          url.searchParams.append(key, String(value));
        }
      });
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'ScaleCart-JS-SDK/1.0.0',
      ...options.headers
    };

    if (this.apiKey) {
      headers['Authorization'] = `Bearer ${this.apiKey}`;
    }

    const requestOptions: RequestInit = {
      method: options.method,
      headers,
      signal: AbortSignal.timeout(this.timeout)
    };

    if (options.data) {
      requestOptions.body = JSON.stringify(options.data);
    }

    let lastError: Error | null = null;
    
    for (let attempt = 0; attempt < this.maxRetries; attempt++) {
      try {
        const response = await fetch(url.toString(), requestOptions);
        const responseData = await response.json().catch(() => ({}));

        if (!response.ok) {
          const errorMessage = responseData?.error?.message || response.statusText;
          
          if (response.status === 429) {
            const retryAfter = parseInt(response.headers.get('X-RateLimit-Reset') || '60');
            throw new RateLimitError(retryAfter, errorMessage);
          }

          switch (response.status) {
            case 401:
              throw new AuthenticationError(errorMessage);
            case 404:
              throw new NotFoundError(errorMessage);
            default:
              throw new ScaleCartError(errorMessage, response.status, responseData);
          }
        }

        return responseData;

      } catch (error) {
        lastError = error as Error;
        
        // Don't retry on authentication errors
        if (error instanceof AuthenticationError || error instanceof NotFoundError) {
          throw error;
        }
        
        // Wait before retry
        if (attempt < this.maxRetries - 1) {
          await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
        }
      }
    }

    throw lastError || new ScaleCartError('Request failed after retries');
  }
}

// ============================================
// RESOURCE CLIENTS
// ============================================

export class ProductsClient {
  constructor(private http: HttpClient) {}

  async list(params?: {
    page?: number;
    limit?: number;
    category_id?: number;
    min_price?: number;
    max_price?: number;
    search?: string;
    sort_by?: string;
    sort_order?: 'asc' | 'desc';
  }): Promise<PaginatedResponse<Product>> {
    return this.http.request<PaginatedResponse<Product>>({
      method: 'GET',
      path: '/api/v1/products',
      params
    });
  }

  async get(productId: number): Promise<Product> {
    return this.http.request<Product>({
      method: 'GET',
      path: `/api/v1/products/${productId}`
    });
  }

  async create(data: {
    name: string;
    price: number;
    category_id: number;
    description?: string;
    sku?: string;
    weight_kg?: number;
  }): Promise<Product> {
    return this.http.request<Product>({
      method: 'POST',
      path: '/api/v1/products',
      data
    });
  }

  async update(productId: number, data: Partial<Omit<Product, 'id'>>): Promise<Product> {
    return this.http.request<Product>({
      method: 'PUT',
      path: `/api/v1/products/${productId}`,
      data
    });
  }

  async delete(productId: number): Promise<void> {
    await this.http.request({
      method: 'DELETE',
      path: `/api/v1/products/${productId}`
    });
  }

  async getRecommendations(productId: number, limit: number = 10): Promise<Product[]> {
    const result = await this.http.request<{ data: Product[] }>({
      method: 'GET',
      path: `/api/v1/products/${productId}/recommendations`,
      params: { limit }
    });
    return result.data;
  }
}

export class OrdersClient {
  constructor(private http: HttpClient) {}

  async list(params?: {
    customer_id?: number;
    status?: OrderStatus;
    start_date?: string;
    end_date?: string;
    page?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Order>> {
    return this.http.request<PaginatedResponse<Order>>({
      method: 'GET',
      path: '/api/v1/orders',
      params
    });
  }

  async get(orderId: number): Promise<Order> {
    return this.http.request<Order>({
      method: 'GET',
      path: `/api/v1/orders/${orderId}`
    });
  }

  async create(data: {
    customer_id: number;
    items: Array<{ product_id: number; quantity: number }>;
    shipping_address_id: number;
    billing_address_id: number;
    payment_method: PaymentMethod;
    notes?: string;
  }): Promise<Order> {
    return this.http.request<Order>({
      method: 'POST',
      path: '/api/v1/orders',
      data
    });
  }

  async updateStatus(orderId: number, status: OrderStatus): Promise<Order> {
    return this.http.request<Order>({
      method: 'PATCH',
      path: `/api/v1/orders/${orderId}/status`,
      data: { status }
    });
  }

  async cancel(orderId: number, reason: string = 'Cancelled by customer'): Promise<Order> {
    return this.http.request<Order>({
      method: 'POST',
      path: `/api/v1/orders/${orderId}/cancel`,
      data: { reason }
    });
  }
}

export class CustomersClient {
  constructor(private http: HttpClient) {}

  async getMe(): Promise<Customer> {
    return this.http.request<Customer>({
      method: 'GET',
      path: '/api/v1/customers/me'
    });
  }

  async updateMe(data: Partial<Omit<Customer, 'id'>>): Promise<Customer> {
    return this.http.request<Customer>({
      method: 'PUT',
      path: '/api/v1/customers/me',
      data
    });
  }

  async changePassword(currentPassword: string, newPassword: string): Promise<void> {
    await this.http.request({
      method: 'POST',
      path: '/api/v1/customers/me/change-password',
      data: { current_password: currentPassword, new_password: newPassword }
    });
  }

  async getAddresses(): Promise<Record<string, any>[]> {
    const result = await this.http.request<{ data: Record<string, any>[] }>({
      method: 'GET',
      path: '/api/v1/customers/me/addresses'
    });
    return result.data;
  }

  async addAddress(data: Record<string, any>): Promise<Record<string, any>> {
    return this.http.request<Record<string, any>>({
      method: 'POST',
      path: '/api/v1/customers/me/addresses',
      data
    });
  }

  async updateAddress(addressId: number, data: Record<string, any>): Promise<Record<string, any>> {
    return this.http.request<Record<string, any>>({
      method: 'PUT',
      path: `/api/v1/customers/me/addresses/${addressId}`,
      data
    });
  }

  async deleteAddress(addressId: number): Promise<void> {
    await this.http.request({
      method: 'DELETE',
      path: `/api/v1/customers/me/addresses/${addressId}`
    });
  }
}

export class AuthClient {
  constructor(private http: HttpClient) {}

  async register(data: {
    email: string;
    password: string;
    full_name: string;
    phone?: string;
  }): Promise<Customer> {
    return this.http.request<Customer>({
      method: 'POST',
      path: '/api/v1/auth/register',
      data
    });
  }

  async login(email: string, password: string): Promise<{
    access_token: string;
    refresh_token: string;
    token_type: string;
    expires_in: number;
  }> {
    return this.http.request({
      method: 'POST',
      path: '/api/v1/auth/login',
      data: { email, password }
    });
  }

  async refresh(refreshToken: string): Promise<{
    access_token: string;
    expires_in: number;
  }> {
    return this.http.request({
      method: 'POST',
      path: '/api/v1/auth/refresh',
      data: { refresh_token: refreshToken }
    });
  }

  async logout(): Promise<void> {
    await this.http.request({
      method: 'POST',
      path: '/api/v1/auth/logout'
    });
  }
}

export class InventoryClient {
  constructor(private http: HttpClient) {}

  async getStock(productId: number): Promise<{
    product_id: number;
    stock_quantity: number;
    reserved_quantity: number;
    available_quantity: number;
    reorder_threshold: number;
    status: 'in_stock' | 'low_stock' | 'out_of_stock';
  }> {
    return this.http.request({
      method: 'GET',
      path: `/api/v1/inventory/${productId}`
    });
  }

  async updateStock(
    productId: number,
    stockQuantity: number,
    reorderThreshold?: number
  ): Promise<{
    product_id: number;
    stock_quantity: number;
    previous_stock: number;
    change: number;
    last_updated: string;
  }> {
    return this.http.request({
      method: 'PATCH',
      path: `/api/v1/inventory/${productId}`,
      data: {
        stock_quantity: stockQuantity,
        reorder_threshold: reorderThreshold
      }
    });
  }

  async getLowStock(limit: number = 50): Promise<Array<{
    product_id: number;
    product_name: string;
    stock_quantity: number;
    reorder_threshold: number;
    deficit: number;
  }>> {
    const result = await this.http.request<{ data: any[] }>({
      method: 'GET',
      path: '/api/v1/inventory/low-stock',
      params: { limit }
    });
    return result.data;
  }
}

// ============================================
// MAIN CLIENT
// ============================================

export interface ScaleCartClientConfig {
  baseUrl?: string;
  apiKey?: string;
  timeout?: number;
  maxRetries?: number;
}

export class ScaleCartClient {
  private http: HttpClient;
  
  public products: ProductsClient;
  public orders: OrdersClient;
  public customers: CustomersClient;
  public auth: AuthClient;
  public inventory: InventoryClient;

  constructor(config: ScaleCartClientConfig = {}) {
    const baseUrl = config.baseUrl || 'https://api.scalecart.com';
    
    this.http = new HttpClient({
      baseUrl,
      apiKey: config.apiKey,
      timeout: config.timeout,
      maxRetries: config.maxRetries
    });

    this.products = new ProductsClient(this.http);
    this.orders = new OrdersClient(this.http);
    this.customers = new CustomersClient(this.http);
    this.auth = new AuthClient(this.http);
    this.inventory = new InventoryClient(this.http);
  }

  setApiKey(apiKey: string): void {
    this.http['apiKey'] = apiKey;
  }

  setBaseUrl(baseUrl: string): void {
    this.http['baseUrl'] = baseUrl.replace(/\/+$/, '');
  }
}

// ============================================
// REACT HOOKS (Optional)
// ============================================

/*
import { useState, useEffect } from 'react';

export function useProducts(client: ScaleCartClient, options?: any) {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    async function fetchProducts() {
      try {
        setLoading(true);
        const result = await client.products.list(options);
        setProducts(result.data);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    }
    fetchProducts();
  }, [client, JSON.stringify(options)]);

  return { products, loading, error };
}
*/
```

---

## O.4 cURL Examples

### O.4.1 Complete cURL Reference

```bash
#!/bin/bash
# File: examples/curl-commands.sh
# Complete cURL examples for ScaleCart API

# Base URL
BASE_URL="https://api.scalecart.com"
API_KEY="your-api-key"

# ============================================
# AUTHENTICATION
# ============================================

# Register
curl -X POST "${BASE_URL}/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "full_name": "John Doe"
  }'

# Login
curl -X POST "${BASE_URL}/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'

# ============================================
# PRODUCTS
# ============================================

# List products
curl -X GET "${BASE_URL}/api/v1/products?limit=10&page=1" \
  -H "Authorization: Bearer ${API_KEY}"

# Get product by ID
curl -X GET "${BASE_URL}/api/v1/products/1" \
  -H "Authorization: Bearer ${API_KEY}"

# Search products
curl -X GET "${BASE_URL}/api/v1/products?search=laptop&min_price=100&max_price=1000" \
  -H "Authorization: Bearer ${API_KEY}"

# Create product (admin only)
curl -X POST "${BASE_URL}/api/v1/products" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Product",
    "price": 99.99,
    "category_id": 5,
    "description": "Product description"
  }'

# Update product
curl -X PUT "${BASE_URL}/api/v1/products/1" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Product",
    "price": 109.99
  }'

# Delete product
curl -X DELETE "${BASE_URL}/api/v1/products/1" \
  -H "Authorization: Bearer ${API_KEY}"

# ============================================
# ORDERS
# ============================================

# Create order
curl -X POST "${BASE_URL}/api/v1/orders" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": 123,
    "items": [
      {"product_id": 1, "quantity": 2},
      {"product_id": 5, "quantity": 1}
    ],
    "shipping_address_id": 1,
    "billing_address_id": 1,
    "payment_method": "credit_card"
  }'

# Get order
curl -X GET "${BASE_URL}/api/v1/orders/1001" \
  -H "Authorization: Bearer ${API_KEY}"

# List orders
curl -X GET "${BASE_URL}/api/v1/orders?status=paid&limit=10" \
  -H "Authorization: Bearer ${API_KEY}"

# Cancel order
curl -X POST "${BASE_URL}/api/v1/orders/1001/cancel" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Changed my mind"}'

# ============================================
# CART
# ============================================

# Get cart
curl -X GET "${BASE_URL}/api/v1/cart" \
  -H "Authorization: Bearer ${API_KEY}"

# Add item to cart
curl -X POST "${BASE_URL}/api/v1/cart/items" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'

# Update cart item
curl -X PUT "${BASE_URL}/api/v1/cart/items/1" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"quantity": 3}'

# Remove cart item
curl -X DELETE "${BASE_URL}/api/v1/cart/items/1" \
  -H "Authorization: Bearer ${API_KEY}"

# Clear cart
curl -X DELETE "${BASE_URL}/api/v1/cart" \
  -H "Authorization: Bearer ${API_KEY}"

# ============================================
# INVENTORY
# ============================================

# Check stock
curl -X GET "${BASE_URL}/api/v1/inventory/1" \
  -H "Authorization: Bearer ${API_KEY}"

# Update stock (admin only)
curl -X PATCH "${BASE_URL}/api/v1/inventory/1" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"stock_quantity": 75, "reorder_threshold": 15}'

# ============================================
# REVIEWS
# ============================================

# Get product reviews
curl -X GET "${BASE_URL}/api/v1/products/1/reviews?limit=5" \
  -H "Authorization: Bearer ${API_KEY}"

# Create review
curl -X POST "${BASE_URL}/api/v1/products/1/reviews" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "title": "Excellent!",
    "comment": "Very satisfied with this product."
  }'

# ============================================
# ANALYTICS (Admin Only)
# ============================================

# Get sales analytics
curl -X GET "${BASE_URL}/api/v1/analytics/sales?start_date=2026-01-01&end_date=2026-01-31" \
  -H "Authorization: Bearer ${API_KEY}"

# Get real-time metrics
curl -X GET "${BASE_URL}/api/v1/analytics/realtime" \
  -H "Authorization: Bearer ${API_KEY}"

# ============================================
# HEALTH
# ============================================

# Health check
curl -X GET "${BASE_URL}/health"

# Full health check
curl -X GET "${BASE_URL}/health/full" \
  -H "Authorization: Bearer ${API_KEY}"
```

---

## O.5 Postman Collection

### O.5.1 Postman Collection Template

```json
{
  "info": {
    "name": "ScaleCart API",
    "description": "Complete API collection for ScaleCart",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "https://api.scalecart.com",
      "type": "string"
    },
    {
      "key": "api_key",
      "value": "",
      "type": "string"
    }
  ],
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{api_key}}",
        "type": "string"
      }
    ]
  },
  "item": [
    {
      "name": "Authentication",
      "item": [
        {
          "name": "Register",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"email\": \"user@example.com\",\n    \"password\": \"SecurePass123!\",\n    \"full_name\": \"John Doe\"\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/v1/auth/register",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "auth", "register"]
            }
          }
        },
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"email\": \"user@example.com\",\n    \"password\": \"SecurePass123!\"\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/v1/auth/login",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "auth", "login"]
            }
          }
        }
      ]
    },
    {
      "name": "Products",
      "item": [
        {
          "name": "List Products",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/v1/products?limit=10",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "products"],
              "query": [
                {
                  "key": "limit",
                  "value": "10",
                  "description": "Number of products to return"
                },
                {
                  "key": "page",
                  "value": "1",
                  "description": "Page number"
                }
              ]
            }
          }
        },
        {
          "name": "Get Product",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/v1/products/1",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "products", "1"]
            }
          }
        },
        {
          "name": "Create Product",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"name\": \"New Product\",\n    \"price\": 99.99,\n    \"category_id\": 5,\n    \"description\": \"Product description\"\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/v1/products",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "products"]
            }
          }
        }
      ]
    },
    {
      "name": "Orders",
      "item": [
        {
          "name": "Create Order",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"customer_id\": 123,\n    \"items\": [\n        {\"product_id\": 1, \"quantity\": 2}\n    ],\n    \"shipping_address_id\": 1,\n    \"billing_address_id\": 1,\n    \"payment_method\": \"credit_card\"\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/v1/orders",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "orders"]
            }
          }
        },
        {
          "name": "Get Order",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/v1/orders/1001",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "orders", "1001"]
            }
          }
        },
        {
          "name": "List Orders",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/v1/orders?status=paid",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "orders"],
              "query": [
                {
                  "key": "status",
                  "value": "paid"
                },
                {
                  "key": "limit",
                  "value": "10"
                }
              ]
            }
          }
        }
      ]
    },
    {
      "name": "Cart",
      "item": [
        {
          "name": "Get Cart",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/v1/cart",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "cart"]
            }
          }
        },
        {
          "name": "Add Item",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"product_id\": 1,\n    \"quantity\": 2\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/v1/cart/items",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "cart", "items"]
            }
          }
        }
      ]
    },
    {
      "name": "Inventory",
      "item": [
        {
          "name": "Get Stock",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/v1/inventory/1",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "inventory", "1"]
            }
          }
        },
        {
          "name": "Update Stock",
          "request": {
            "method": "PATCH",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"stock_quantity\": 75,\n    \"reorder_threshold\": 15\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/v1/inventory/1",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "inventory", "1"]
            }
          }
        }
      ]
    },
    {
      "name": "Reviews",
      "item": [
        {
          "name": "Get Reviews",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/v1/products/1/reviews",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "products", "1", "reviews"]
            }
          }
        },
        {
          "name": "Create Review",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"rating\": 5,\n    \"title\": \"Excellent!\",\n    \"comment\": \"Very satisfied with this product.\"\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/v1/products/1/reviews",
              "host": ["{{base_url}}"],
              "path": ["api", "v1", "products", "1", "reviews"]
            }
          }
        }
      ]
    },
    {
      "name": "Health",
      "item": [
        {
          "name": "Health Check",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/health",
              "host": ["{{base_url}}"],
              "path": ["health"]
            }
          }
        },
        {
          "name": "Full Health Check",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/health/full",
              "host": ["{{base_url}}"],
              "path": ["health", "full"]
            }
          }
        }
      ]
    }
  ]
}
```

---

## O.6 Generating Clients with OpenAPI Generator

### O.6.1 OpenAPI Generator Commands

```bash
# Install OpenAPI Generator
npm install -g @openapitools/openapi-generator-cli

# Or with Docker
docker pull openapitools/openapi-generator-cli

# Download OpenAPI spec
curl https://api.scalecart.com/openapi.json > openapi.json

# Generate Python client
openapi-generator generate -i openapi.json -g python -o python-client

# Generate TypeScript client
openapi-generator generate -i openapi.json -g typescript-axios -o typescript-client

# Generate Go client
openapi-generator generate -i openapi.json -g go -o go-client

# Generate Java client
openapi-generator generate -i openapi.json -g java -o java-client

# Generate C# client
openapi-generator generate -i openapi.json -g csharp -o csharp-client

# Generate Ruby client
openapi-generator generate -i openapi.json -g ruby -o ruby-client

# Generate PHP client
openapi-generator generate -i openapi.json -g php -o php-client
```

---

## O.7 SDK Usage Examples

### O.7.1 Python SDK Examples

```python
#!/usr/bin/env python3
# File: examples/python_example.py
"""
Complete Python SDK usage examples.
"""

from scalecart import ScaleCartClient
from scalecart import PaymentMethod, OrderStatus

def main():
    # Initialize client
    client = ScaleCartClient(
        base_url="https://api.scalecart.com",
        api_key="your-api-key"
    )
    
    # 1. Authentication
    auth_result = client.auth.login("user@example.com", "SecurePass123!")
    client.set_api_key(auth_result["access_token"])
    
    # 2. Get products
    products = client.products.list(
        category_id=5,
        min_price=100,
        max_price=1000,
        limit=10
    )
    print(f"Found {products['pagination']['total']} products")
    
    # 3. Get product by ID
    product = client.products.get(1)
    print(f"Product: {product.name} - ${product.price}")
    
    # 4. Add to cart
    client.cart.add_item(1, 2)
    cart = client.cart.get()
    print(f"Cart total: ${cart['total_amount']}")
    
    # 5. Create order
    order = client.orders.create(
        customer_id=123,
        items=[{"product_id": 1, "quantity": 2}],
        shipping_address_id=1,
        billing_address_id=1,
        payment_method=PaymentMethod.CREDIT_CARD
    )
    print(f"Order created: #{order.id} - ${order.total_amount}")
    
    # 6. Update order status (admin)
    order = client.orders.update_status(order.id, OrderStatus.PAID)
    print(f"Order status: {order.status}")
    
    # 7. Get customer profile
    customer = client.customers.get_me()
    print(f"Customer: {customer.full_name} ({customer.email})")
    
    # 8. Check inventory
    stock = client.inventory.get_stock(1)
    print(f"Stock: {stock['available_quantity']} available")
    
    # 9. Submit review
    review = client.reviews.create(
        product_id=1,
        rating=5,
        title="Excellent product!",
        comment="Highly recommended."
    )
    print(f"Review submitted: {review['id']}")

if __name__ == "__main__":
    main()
```

---

**[END OF APPENDIX O]**

*This complete API client SDK appendix provides everything needed to integrate with the ScaleCart API from any language or platform. Use the SDKs to build applications that interact with the ScaleCart platform programmatically.*
