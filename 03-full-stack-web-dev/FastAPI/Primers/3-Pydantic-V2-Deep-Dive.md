# Primer 3: Pydantic V2 Deep Dive

Welcome to the third primer in our FastAPI Masterclass series! This comprehensive guide dives deep into Pydantic V2, the data validation library that powers FastAPI's request/response handling. Whether you're new to Pydantic or upgrading from V1, this primer will give you a thorough understanding of Pydantic's features, advanced validation techniques, and best practices.

## Table of Contents
1. [Pydantic Overview](#pydantic-overview)
2. [Basic Models](#basic-models)
3. [Field Validation](#field-validation)
4. [Custom Validators](#custom-validators)
5. [Nested Models](#nested-models)
6. [Generic Models](#generic-models)
7. [Configuration](#configuration)
8. [Performance Optimization](#performance-optimization)
9. [Advanced Features](#advanced-features)
10. [Best Practices](#best-practices)

---

## Pydantic Overview

### What is Pydantic?

Pydantic is like a quality control inspector for your data. It defines what data should look like and automatically checks, cleans, and validates data as it enters your application.

**Key Features:**
- **Type Validation**: Ensures data matches expected types
- **Data Parsing**: Automatically converts data to correct types
- **Validation**: Custom validation logic
- **Serialization**: Convert models to/from JSON
- **IDE Support**: Type hints for better autocomplete
- **Performance**: Built in Rust for speed (V2)

### Pydantic V2 vs V1

```python
"""
Pydantic V2 vs V1 comparison
"""

# ────────────────────────────────────────────────────────────────
# V1 Style (Deprecated)
# ────────────────────────────────────────────────────────────────
from pydantic import BaseModel, validator

class UserV1(BaseModel):
    name: str
    age: int
    
    # V1 validator
    @validator('age')
    def validate_age(cls, v):
        if v < 0:
            raise ValueError('Age must be positive')
        return v

# ────────────────────────────────────────────────────────────────
# V2 Style (Current)
# ────────────────────────────────────────────────────────────────
from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional

class UserV2(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=0, le=150)
    
    # V2 validator
    @field_validator('age')
    @classmethod
    def validate_age(cls, v: int) -> int:
        if v < 0:
            raise ValueError('Age must be positive')
        return v
    
    # V2 model validator (runs after all fields)
    @model_validator(mode='after')
    def validate_model(self) -> 'UserV2':
        # Access all fields
        if self.age < 18 and self.name == "admin":
            raise ValueError('Admins must be adults')
        return self

# ────────────────────────────────────────────────────────────────
# Key Differences
# ────────────────────────────────────────────────────────────────

# V2 features:
# - Faster (Rust core)
# - Better type hints
# - Improved validation (field_validator, model_validator)
# - Generic models support
# - Strict mode
# - Better serialization control

print("Pydantic V2 is the way to go!")
```

---

## Basic Models

### Creating Models

```python
"""
Basic Pydantic models
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime, date, time
from decimal import Decimal
from enum import Enum
import uuid

# ────────────────────────────────────────────────────────────────
# 1. Simple Model
# ────────────────────────────────────────────────────────────────

class User(BaseModel):
    """Basic user model."""
    name: str
    email: str
    age: int
    
# Create instance
user = User(name="John Doe", email="john@example.com", age=30)
print(user)
# > name='John Doe' email='john@example.com' age=30

# Access fields
print(user.name)  # "John Doe"
print(user.age)   # 30

# Convert to dict
print(user.model_dump())
# > {'name': 'John Doe', 'email': 'john@example.com', 'age': 30}

# Convert to JSON
print(user.model_dump_json())
# > '{"name":"John Doe","email":"john@example.com","age":30}'

# ────────────────────────────────────────────────────────────────
# 2. Model with Field Options
# ────────────────────────────────────────────────────────────────

class Product(BaseModel):
    """Product model with field constraints."""
    
    # Required fields with constraints
    name: str = Field(
        ...,
        min_length=1,
        max_length=100,
        description="Product name",
        examples=["Laptop", "Smartphone"]
    )
    
    price: Decimal = Field(
        ...,
        gt=0,
        decimal_places=2,
        description="Product price"
    )
    
    # Optional fields with defaults
    description: Optional[str] = Field(
        default=None,
        max_length=1000,
        description="Product description"
    )
    
    is_active: bool = Field(
        default=True,
        description="Whether product is active"
    )
    
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        description="Creation timestamp"
    )
    
    # Categories
    categories: List[str] = Field(
        default_factory=list,
        description="Product categories"
    )
    
    # Tags with max items
    tags: List[str] = Field(
        default_factory=list,
        max_length=10,
        description="Product tags"
    )

# ────────────────────────────────────────────────────────────────
# 3. Model with Enums
# ────────────────────────────────────────────────────────────────

class UserRole(str, Enum):
    """User role enumeration."""
    ADMIN = "admin"
    MANAGER = "manager"
    DEVELOPER = "developer"
    VIEWER = "viewer"

class TaskStatus(str, Enum):
    """Task status enumeration."""
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    REVIEW = "review"
    DONE = "done"
    ARCHIVED = "archived"

class Task(BaseModel):
    """Task model with enums."""
    title: str = Field(..., min_length=1, max_length=200)
    status: TaskStatus = Field(default=TaskStatus.TODO)
    role: UserRole = Field(default=UserRole.DEVELOPER)
    priority: int = Field(default=1, ge=1, le=5)

# ────────────────────────────────────────────────────────────────
# 4. Model with Nested Types
# ────────────────────────────────────────────────────────────────

class Address(BaseModel):
    """Address model."""
    street: str
    city: str
    state: str
    country: str
    postal_code: str

class ContactInfo(BaseModel):
    """Contact information."""
    email: str
    phone: Optional[str] = None
    address: Optional[Address] = None

class UserProfile(BaseModel):
    """User profile with nested models."""
    user_id: int
    username: str
    contact: ContactInfo
    preferences: Dict[str, Any] = Field(default_factory=dict)
    metadata: Dict[str, Any] = Field(default_factory=dict)

# ────────────────────────────────────────────────────────────────
# 5. Model with UUID
# ────────────────────────────────────────────────────────────────

class UUIDModel(BaseModel):
    """Model with UUID field."""
    id: uuid.UUID = Field(default_factory=uuid.uuid4)
    name: str
    
# UUID will be generated automatically
model = UUIDModel(name="Test")
print(model.id)  # e.g., 123e4567-e89b-12d3-a456-426614174000

# ────────────────────────────────────────────────────────────────
# 6. Model with Strict Types
# ────────────────────────────────────────────────────────────────

from pydantic import StrictStr, StrictInt, StrictBool

class StrictModel(BaseModel):
    """Model with strict types."""
    name: StrictStr  # Must be str, no coercion
    age: StrictInt   # Must be int, no coercion
    is_active: StrictBool  # Must be bool, no coercion
    
# This works
strict = StrictModel(name="John", age=30, is_active=True)

# This fails (coercion not allowed)
# strict = StrictModel(name="John", age="30", is_active="true")
# > ValidationError: age: Input should be a valid integer
```

### Type Conversion

```python
"""
Pydantic automatic type conversion
"""

from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# ────────────────────────────────────────────────────────────────
# 1. Type Coercion Examples
# ────────────────────────────────────────────────────────────────

class TypeConversionModel(BaseModel):
    """Model demonstrating type coercion."""
    # String conversion
    name: str              # Any input becomes string
    
    # Integer conversion
    age: int              # "30" -> 30, 30.5 -> 30
    
    # Float conversion
    height: float         # "5.9" -> 5.9
    
    # Boolean conversion
    is_active: bool       # "true" -> True, "false" -> False, "1" -> True
    
    # Datetime conversion
    created_at: datetime  # ISO string -> datetime
    
    # Optional fields
    optional_field: Optional[str] = None  # None allowed

# Examples
data = {
    "name": 123,                 # -> "123"
    "age": "30",                # -> 30
    "height": "5.9",            # -> 5.9
    "is_active": "true",        # -> True
    "created_at": "2024-01-01T12:00:00Z",  # -> datetime
}

model = TypeConversionModel(**data)
print(model)
# > name='123' age=30 height=5.9 is_active=True created_at=datetime(...)

# ────────────────────────────────────────────────────────────────
# 2. Union Types
# ────────────────────────────────────────────────────────────────

from typing import Union

class UnionModel(BaseModel):
    """Model with union types."""
    value: Union[int, str, None] = None
    
# Can be int, str, or None
m1 = UnionModel(value=42)
m2 = UnionModel(value="hello")
m3 = UnionModel(value=None)

# ────────────────────────────────────────────────────────────────
# 3. Literal Types
# ────────────────────────────────────────────────────────────────

from typing import Literal

class LiteralModel(BaseModel):
    """Model with literal types."""
    status: Literal["active", "inactive", "pending"]
    priority: Literal[1, 2, 3, 4, 5]

# Only allowed values
m1 = LiteralModel(status="active", priority=3)
# m2 = LiteralModel(status="invalid", priority=6)  # Validation error

# ────────────────────────────────────────────────────────────────
# 4. Any Type
# ────────────────────────────────────────────────────────────────

from typing import Any

class AnyTypeModel(BaseModel):
    """Model with Any type."""
    data: Any
    
# Can be anything
m1 = AnyTypeModel(data={"key": "value"})
m2 = AnyTypeModel(data=[1, 2, 3])
m3 = AnyTypeModel(data="string")
m4 = AnyTypeModel(data=42)
```

---

## Field Validation

### Built-in Validators

```python
"""
Built-in Pydantic validators
"""

from pydantic import BaseModel, Field, EmailStr, HttpUrl, FilePath, DirectoryPath
from typing import Optional, List
from decimal import Decimal
import re

# ────────────────────────────────────────────────────────────────
# 1. Common Field Validators
# ────────────────────────────────────────────────────────────────

class ValidatedModel(BaseModel):
    """Model with various field validators."""
    
    # String validators
    username: str = Field(
        min_length=3,
        max_length=50,
        pattern=r'^[a-zA-Z0-9_]+$'  # Regex pattern
    )
    
    # Email
    email: EmailStr  # Validates email format
    
    # URL
    website: Optional[HttpUrl] = None  # Validates URL format
    
    # File paths
    avatar: Optional[FilePath] = None  # Must be existing file
    
    # Numeric validators
    age: int = Field(ge=0, le=150)  # Between 0 and 150
    
    weight: float = Field(gt=0, le=1000)  # Greater than 0, max 1000
    
    price: Decimal = Field(
        gt=0,
        decimal_places=2,
        max_digits=10,
    )
    
    # List validators
    tags: List[str] = Field(
        max_length=10,  # Max 10 items
        min_length=0,   # Min 0 items
    )
    
    # String format validation
    phone_number: Optional[str] = Field(
        default=None,
        pattern=r'^\+?1?\d{9,15}$'  # Phone number pattern
    )
    
    # Custom pattern with validation
    product_code: str = Field(
        pattern=r'^[A-Z]{2}-\d{4}$'  # e.g., AB-1234
    )

# ────────────────────────────────────────────────────────────────
# 2. Common Patterns
# ────────────────────────────────────────────────────────────────

class PatternExamples(BaseModel):
    """Common regex patterns."""
    
    # US ZIP code
    zip_code: str = Field(
        pattern=r'^\d{5}(-\d{4})?$'
    )
    
    # Password (at least 8 chars, 1 uppercase, 1 lowercase, 1 number)
    password: str = Field(
        min_length=8,
        pattern=r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$'
    )
    
    # Color hex
    hex_color: str = Field(
        pattern=r'^#(?:[0-9a-fA-F]{3}){1,2}$'
    )
    
    # UUID
    uuid_value: str = Field(
        pattern=r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    )

# ────────────────────────────────────────────────────────────────
# 3. Constrained Types
# ────────────────────────────────────────────────────────────────

from pydantic import (
    constr,       # Constrained string
    conint,       # Constrained integer
    confloat,     # Constrained float
    condecimal,   # Constrained decimal
    conlist,      # Constrained list
)

class ConstrainedModel(BaseModel):
    """Model with constrained types."""
    
    # String constraints
    name: constr(min_length=2, max_length=50, pattern=r'^[a-zA-Z]')
    
    # Integer constraints
    level: conint(ge=1, le=10)
    
    # Float constraints
    rating: confloat(ge=0, le=5)
    
    # Decimal constraints
    amount: condecimal(max_digits=10, decimal_places=2)
    
    # List constraints
    items: conlist(item_type=str, min_length=1, max_length=10)

# ────────────────────────────────────────────────────────────────
# 4. Required vs Optional
# ────────────────────────────────────────────────────────────────

class RequiredOptionalModel(BaseModel):
    """Understanding required vs optional fields."""
    
    # Required (no default, no None)
    required_field: str
    
    # Required with default
    required_with_default: str = "default value"
    
    # Optional (can be None)
    optional_field: Optional[str] = None
    
    # Optional but required if present
    conditional_required: Optional[str] = Field(
        default=None,
        min_length=1,
    )
    
    # Required but can be None (use with caution)
    nullable_required: str | None

# ────────────────────────────────────────────────────────────────
# 5. Default Factory
# ────────────────────────────────────────────────────────────────

from datetime import datetime, timedelta

def default_expiry():
    """Default expiry date (30 days from now)."""
    return datetime.utcnow() + timedelta(days=30)

class DefaultFactoryModel(BaseModel):
    """Model with default factories."""
    
    # Current time
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Generated ID
    session_id: str = Field(default_factory=lambda: f"session_{uuid.uuid4().hex[:8]}")
    
    # Expiry from function
    expires_at: datetime = Field(default_factory=default_expiry)
    
    # Empty list
    items: List[str] = Field(default_factory=list)
    
    # Empty dict
    metadata: dict = Field(default_factory=dict)
```

### Custom Validators

```python
"""
Custom Pydantic validators
"""

from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional, List, Dict, Any
from datetime import datetime
import re

# ────────────────────────────────────────────────────────────────
# 1. Field Validators
# ────────────────────────────────────────────────────────────────

class UserRegistration(BaseModel):
    """User registration with custom validation."""
    
    username: str
    email: str
    password: str
    confirm_password: str
    age: Optional[int] = None
    
    # ────────────────────────────────────────────────────────────────
    # Field validator for a single field
    # ────────────────────────────────────────────────────────────────
    @field_validator('username')
    @classmethod
    def validate_username(cls, v: str) -> str:
        """Validate username."""
        if len(v) < 3:
            raise ValueError('Username must be at least 3 characters')
        
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('Username can only contain letters, numbers, and underscores')
        
        return v.lower()
    
    # ────────────────────────────────────────────────────────────────
    # Field validator with multiple fields
    # ────────────────────────────────────────────────────────────────
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Validate password strength."""
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one number')
        
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError('Password must contain at least one special character')
        
        return v
    
    # ────────────────────────────────────────────────────────────────
    # Field validator with access to other fields
    # ────────────────────────────────────────────────────────────────
    @field_validator('confirm_password')
    @classmethod
    def validate_confirm_password(cls, v: str, info) -> str:
        """Validate password confirmation."""
        # Access other field values via info.data
        if 'password' in info.data and v != info.data['password']:
            raise ValueError('Passwords do not match')
        return v
    
    # ────────────────────────────────────────────────────────────────
    # Field validator with custom parameter
    # ────────────────────────────────────────────────────────────────
    @field_validator('age')
    @classmethod
    def validate_age(cls, v: Optional[int]) -> Optional[int]:
        """Validate age."""
        if v is not None and (v < 0 or v > 150):
            raise ValueError('Age must be between 0 and 150')
        return v

# ────────────────────────────────────────────────────────────────
# 2. Model Validators
# ────────────────────────────────────────────────────────────────

class ProductValidation(BaseModel):
    """Product with model-level validation."""
    
    name: str
    price: float
    discount: float = 0.0
    category: str
    
    # ────────────────────────────────────────────────────────────────
    # After model validator (validates all fields)
    # ────────────────────────────────────────────────────────────────
    @model_validator(mode='after')
    def validate_product(self) -> 'ProductValidation':
        """Validate the entire model."""
        # Check discount doesn't exceed price
        if self.discount > self.price:
            raise ValueError('Discount cannot exceed price')
        
        # Category-specific validation
        if self.category == 'electronics' and self.price > 10000:
            raise ValueError('Electronics priced over 10000 need special approval')
        
        return self

# ────────────────────────────────────────────────────────────────
# 3. Before Model Validator
# ────────────────────────────────────────────────────────────────

class DataCleaningModel(BaseModel):
    """Model with before validator for data cleaning."""
    
    name: str
    email: str
    phone: str
    
    # ────────────────────────────────────────────────────────────────
    # Before model validator (runs before field validation)
    # ────────────────────────────────────────────────────────────────
    @model_validator(mode='before')
    @classmethod
    def clean_data(cls, data: Any) -> Any:
        """Clean data before validation."""
        if isinstance(data, dict):
            # Clean phone number
            if 'phone' in data:
                # Remove non-numeric characters
                data['phone'] = re.sub(r'[^0-9+]', '', data['phone'])
            
            # Strip whitespace from strings
            for key, value in data.items():
                if isinstance(value, str):
                    data[key] = value.strip()
        
        return data

# ────────────────────────────────────────────────────────────────
# 4. Root Validator (Deprecated in V2)
# ────────────────────────────────────────────────────────────────

# In V2, use model_validator instead of root_validator

class Order(BaseModel):
    """Order with root validation."""
    
    items: List[Dict[str, Any]]
    total: float
    discount_code: Optional[str] = None
    
    @model_validator(mode='after')
    def validate_order(self) -> 'Order':
        """Validate the entire order."""
        # Calculate expected total
        calculated_total = sum(item.get('price', 0) * item.get('quantity', 1) 
                              for item in self.items)
        
        # Check if total matches
        if abs(self.total - calculated_total) > 0.01:
            raise ValueError('Total does not match items')
        
        # Discount code validation
        if self.discount_code and not self.discount_code.startswith('DISCOUNT_'):
            raise ValueError('Invalid discount code format')
        
        return self

# ────────────────────────────────────────────────────────────────
# 5. Field Validator with Context
# ────────────────────────────────────────────────────────────────

from pydantic import ValidationInfo

class ContextAwareModel(BaseModel):
    """Model with context-aware validation."""
    
    user_id: int
    role: str
    permissions: List[str]
    
    @field_validator('permissions')
    @classmethod
    def validate_permissions(
        cls, 
        v: List[str], 
        info: ValidationInfo
    ) -> List[str]:
        """Validate permissions based on role."""
        role = info.data.get('role')
        
        if role == 'admin':
            # Admins can have any permission
            return v
        
        # Non-admins need permission validation
        allowed = ['read', 'write', 'delete']
        for perm in v:
            if perm not in allowed:
                raise ValueError(f'Invalid permission: {perm}')
        
        return v

# ────────────────────────────────────────────────────────────────
# 6. Validation with External Dependencies
# ────────────────────────────────────────────────────────────────

import re

class Config:
    """Configuration for validation."""
    
    BANNED_USERNAMES = {'admin', 'root', 'system', 'test'}
    ALLOWED_EMAIL_DOMAINS = {'example.com', 'test.com'}

class AdvancedValidation(BaseModel):
    """Model with advanced validation patterns."""
    
    username: str
    email: str
    
    @field_validator('username')
    @classmethod
    def validate_username(cls, v: str) -> str:
        """Complex username validation."""
        # Check for banned usernames
        if v.lower() in Config.BANNED_USERNAMES:
            raise ValueError(f'Username "{v}" is not allowed')
        
        # Check for profanity (simple example)
        profanity_pattern = re.compile(r'(badword|offensive)', re.IGNORECASE)
        if profanity_pattern.search(v):
            raise ValueError('Username contains inappropriate language')
        
        return v
    
    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        """Email validation with domain check."""
        domain = v.split('@')[-1]
        if domain not in Config.ALLOWED_EMAIL_DOMAINS:
            raise ValueError(f'Email domain "{domain}" is not allowed')
        return v
```

---

## Nested Models

### Working with Nested Models

```python
"""
Nested Pydantic models
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

# ────────────────────────────────────────────────────────────────
# 1. Basic Nesting
# ────────────────────────────────────────────────────────────────

class Address(BaseModel):
    """Address model."""
    street: str
    city: str
    state: str
    zip_code: str
    country: str

class User(BaseModel):
    """User with nested address."""
    id: int
    name: str
    email: str
    address: Address  # Nested model
    billing_address: Optional[Address] = None  # Optional nested

# Usage
user = User(
    id=1,
    name="John Doe",
    email="john@example.com",
    address={
        "street": "123 Main St",
        "city": "Boston",
        "state": "MA",
        "zip_code": "02101",
        "country": "USA"
    }
)

print(user.address.city)  # Boston

# ────────────────────────────────────────────────────────────────
# 2. Deep Nesting
# ────────────────────────────────────────────────────────────────

class Coordinates(BaseModel):
    """Coordinates model."""
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)

class Location(BaseModel):
    """Location model."""
    address: Address
    coordinates: Optional[Coordinates] = None
    timezone: str = "UTC"

class Venue(BaseModel):
    """Venue with nested location."""
    name: str
    location: Location
    capacity: int

# Usage
venue = Venue(
    name="Concert Hall",
    location={
        "address": {
            "street": "456 Music Ave",
            "city": "New York",
            "state": "NY",
            "zip_code": "10001",
            "country": "USA"
        },
        "coordinates": {
            "latitude": 40.7128,
            "longitude": -74.0060
        }
    },
    capacity=5000
)

print(venue.location.address.city)  # New York

# ────────────────────────────────────────────────────────────────
# 3. Lists of Nested Models
# ────────────────────────────────────────────────────────────────

class Item(BaseModel):
    """Item model."""
    id: int
    name: str
    price: float
    quantity: int = Field(..., ge=1)

class Order(BaseModel):
    """Order with list of items."""
    order_id: int
    items: List[Item]  # List of nested models
    total: float
    created_at: datetime = Field(default_factory=datetime.utcnow)

# Usage
order = Order(
    order_id=1001,
    items=[
        {"id": 1, "name": "Laptop", "price": 999.99, "quantity": 1},
        {"id": 2, "name": "Mouse", "price": 29.99, "quantity": 2},
        {"id": 3, "name": "Keyboard", "price": 79.99, "quantity": 1},
    ],
    total=1139.96
)

for item in order.items:
    print(f"{item.name}: ${item.price} x {item.quantity}")

# ────────────────────────────────────────────────────────────────
# 4. Dynamic Nested Models
# ────────────────────────────────────────────────────────────────

from typing import Type, Dict

class DynamicNestedModel(BaseModel):
    """Model with dynamic nested structure."""
    
    name: str
    data: Dict[str, Any]  # Can contain nested structures
    
    # Convert nested dict to model if needed
    def get_data_model(self, model_class: Type[BaseModel]) -> BaseModel:
        """Convert data to a specific model."""
        return model_class(**self.data)

# Usage
class ProductData(BaseModel):
    price: float
    category: str
    in_stock: bool

dynamic = DynamicNestedModel(
    name="Product",
    data={
        "price": 99.99,
        "category": "Electronics",
        "in_stock": True
    }
)

product = dynamic.get_data_model(ProductData)
print(product.price)  # 99.99

# ────────────────────────────────────────────────────────────────
# 5. Recursive Models
# ────────────────────────────────────────────────────────────────

class Category(BaseModel):
    """Recursive category model."""
    id: int
    name: str
    parent_id: Optional[int] = None
    subcategories: List['Category'] = Field(default_factory=list)

# Enable forward references
Category.model_rebuild()

# Usage
category = Category(
    id=1,
    name="Electronics",
    subcategories=[
        Category(
            id=2,
            name="Computers",
            parent_id=1,
            subcategories=[
                Category(id=4, name="Laptops", parent_id=2),
                Category(id=5, name="Desktops", parent_id=2),
            ]
        ),
        Category(
            id=3,
            name="Phones",
            parent_id=1,
        ),
    ]
)

def print_category(cat: Category, indent: int = 0):
    """Recursively print category tree."""
    print("  " * indent + f"- {cat.name} (ID: {cat.id})")
    for sub in cat.subcategories:
        print_category(sub, indent + 1)

print_category(category)

# ────────────────────────────────────────────────────────────────
# 6. Validating Nested Models
# ────────────────────────────────────────────────────────────────

class ValidatedNestedModel(BaseModel):
    """Model with validation on nested data."""
    
    name: str
    items: List[Dict[str, Any]]
    
    @field_validator('items')
    @classmethod
    def validate_items(cls, v: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Validate each item in the list."""
        for item in v:
            if 'price' in item and item['price'] < 0:
                raise ValueError('Item price cannot be negative')
        return v
    
    @model_validator(mode='after')
    def validate_total(self) -> 'ValidatedNestedModel':
        """Validate the entire model."""
        # Calculate total from items
        total = sum(item.get('price', 0) for item in self.items)
        
        # Check if total is reasonable
        if total > 10000:
            raise ValueError('Total exceeds maximum allowed')
        
        return self
```

---

## Generic Models

### Using Generics

```python
"""
Generic Pydantic models
"""

from pydantic import BaseModel, Field
from typing import Generic, TypeVar, Optional, List, Dict, Any
from typing import TypeVar, Generic

# ────────────────────────────────────────────────────────────────
# 1. Basic Generic Model
# ────────────────────────────────────────────────────────────────

T = TypeVar('T')

class Response(BaseModel, Generic[T]):
    """Generic response wrapper."""
    success: bool
    message: str
    data: Optional[T] = None

# Usage with different types
class User(BaseModel):
    id: int
    name: str

class Task(BaseModel):
    id: int
    title: str
    status: str

# User response
user_response = Response[User](
    success=True,
    message="User found",
    data=User(id=1, name="John")
)

# Task response
task_response = Response[Task](
    success=True,
    message="Task created",
    data=Task(id=1, title="Test", status="todo")
)

# List response
task_list_response = Response[List[Task]](
    success=True,
    message="Tasks found",
    data=[Task(id=1, title="Task 1", status="todo"), 
          Task(id=2, title="Task 2", status="done")]
)

# ────────────────────────────────────────────────────────────────
# 2. Multiple Type Parameters
# ────────────────────────────────────────────────────────────────

K = TypeVar('K')
V = TypeVar('V')

class KeyValuePair(BaseModel, Generic[K, V]):
    """Generic key-value pair."""
    key: K
    value: V
    metadata: Optional[Dict[str, Any]] = None

# Usage
pair1 = KeyValuePair[str, int](key="age", value=30)
pair2 = KeyValuePair[int, str](key=1, value="One")
pair3 = KeyValuePair[str, List[int]](key="scores", value=[10, 20, 30])

# ────────────────────────────────────────────────────────────────
# 3. Generic Paginated Response
# ────────────────────────────────────────────────────────────────

class PaginatedResponse(BaseModel, Generic[T]):
    """Generic paginated response."""
    items: List[T]
    total: int
    page: int
    size: int
    pages: int
    
    @classmethod
    def create(cls, items: List[T], total: int, page: int, size: int) -> 'PaginatedResponse[T]':
        """Create a paginated response."""
        pages = (total + size - 1) // size
        return cls(
            items=items,
            total=total,
            page=page,
            size=size,
            pages=pages
        )

# Usage
user_page = PaginatedResponse[User].create(
    items=[
        User(id=1, name="User 1"),
        User(id=2, name="User 2"),
        User(id=3, name="User 3"),
    ],
    total=42,
    page=1,
    size=10
)

print(f"Showing {len(user_page.items)} of {user_page.total} users")

# ────────────────────────────────────────────────────────────────
# 4. Generic with Constraints
# ────────────────────────────────────────────────────────────────

from typing import TypeVar, Union

# Constrained type variable
Numeric = TypeVar('Numeric', int, float, Decimal)

class NumericResponse(BaseModel, Generic[Numeric]):
    """Response for numeric data."""
    value: Numeric
    precision: int = Field(..., ge=0, le=10)

# Usage
int_response = NumericResponse[int](value=42, precision=2)
float_response = NumericResponse[float](value=3.14159, precision=5)

# ────────────────────────────────────────────────────────────────
# 5. Generic Validators
# ────────────────────────────────────────────────────────────────

class ValidatedGenericResponse(BaseModel, Generic[T]):
    """Generic response with validation."""
    success: bool
    data: T
    errors: Optional[List[str]] = None
    
    @model_validator(mode='after')
    def validate_response(self) -> 'ValidatedGenericResponse[T]':
        """Validate the response."""
        if not self.success and not self.errors:
            self.errors = ["Unknown error occurred"]
        return self

# ────────────────────────────────────────────────────────────────
# 6. Generic Factory Pattern
# ────────────────────────────────────────────────────────────────

class DataWrapper(BaseModel, Generic[T]):
    """Generic data wrapper with factory methods."""
    data: T
    version: str = "1.0"
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    @classmethod
    def wrap(cls, data: T, version: str = "1.0") -> 'DataWrapper[T]':
        """Wrap data in a generic wrapper."""
        return cls(data=data, version=version)
    
    def unwrap(self) -> T:
        """Extract the wrapped data."""
        return self.data

# Usage
user_wrapper = DataWrapper[User].wrap(
    User(id=1, name="John"),
    version="2.0"
)

print(user_wrapper.data.name)  # John
print(user_wrapper.version)    # 2.0

# ────────────────────────────────────────────────────────────────
# 7. Generic with Discriminated Union
# ────────────────────────────────────────────────────────────────

from pydantic import Field
from typing import Literal, Union

class Event(BaseModel):
    """Base event model."""
    event_type: str

class UserEvent(Event):
    """User-related event."""
    event_type: Literal["user.created", "user.updated", "user.deleted"]
    user_id: int

class TaskEvent(Event):
    """Task-related event."""
    event_type: Literal["task.created", "task.updated", "task.completed"]
    task_id: int
    status: str

# Generic event wrapper
class EventWrapper(BaseModel, Generic[T]):
    """Generic event wrapper."""
    event: T
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    source: str = "api"

# Usage
user_event = EventWrapper[UserEvent](
    event=UserEvent(
        event_type="user.created",
        user_id=1
    )
)

task_event = EventWrapper[TaskEvent](
    event=TaskEvent(
        event_type="task.completed",
        task_id=1,
        status="done"
    )
)

print(user_event.event.event_type)  # user.created
```

---

## Configuration

### Model Configuration

```python
"""
Pydantic model configuration
"""

from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

# ────────────────────────────────────────────────────────────────
# 1. Basic Configuration
# ────────────────────────────────────────────────────────────────

class ConfiguredModel(BaseModel):
    """Model with configuration."""
    
    name: str
    age: int
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Configuration
    model_config = ConfigDict(
        # Allow extra fields
        extra="forbid",  # 'forbid', 'allow', 'ignore'
        
        # Forbid extra fields
        # extra="forbid",
        
        # Enable ORM mode (for SQLAlchemy)
        from_attributes=True,
        
        # Custom JSON schema
        json_schema_extra={
            "examples": [
                {"name": "John Doe", "age": 30}
            ]
        },
        
        # Title and description
        title="User Model",
        description="A user in the system",
        
        # Validation
        validate_assignment=True,  # Validate on assignment
        validate_default=True,     # Validate defaults
        
        # Schema generation
        populate_by_name=True,     # Allow field name aliases
        use_enum_values=True,      # Use enum values instead of names
    )

# ────────────────────────────────────────────────────────────────
# 2. Extra Fields Control
# ────────────────────────────────────────────────────────────────

class ExtraFieldsModel(BaseModel):
    """Controlling extra fields."""
    
    name: str
    
    # Option 1: Forbid extra fields (strict)
    model_config = ConfigDict(extra="forbid")

class ExtraFieldsAllowModel(BaseModel):
    """Allow extra fields."""
    
    name: str
    
    # Option 2: Allow extra fields
    model_config = ConfigDict(extra="allow")

class ExtraFieldsIgnoreModel(BaseModel):
    """Ignore extra fields."""
    
    name: str
    
    # Option 3: Ignore extra fields
    model_config = ConfigDict(extra="ignore")

# Usage
strict = ExtraFieldsModel(name="John", extra="field")  # Validation error
allow = ExtraFieldsAllowModel(name="John", extra="field")  # Works
ignore = ExtraFieldsIgnoreModel(name="John", extra="field")  # Ignores extra

# ────────────────────────────────────────────────────────────────
# 3. ORM Mode (SQLAlchemy Integration)
# ────────────────────────────────────────────────────────────────

class ORMModel(BaseModel):
    """Model configured for ORM use."""
    
    id: int
    name: str
    email: str
    
    model_config = ConfigDict(
        from_attributes=True,  # Enable ORM mode
    )

# Usage with SQLAlchemy
# user = session.query(User).first()
# model = ORMModel.from_orm(user)

# ────────────────────────────────────────────────────────────────
# 4. Field Aliases
# ────────────────────────────────────────────────────────────────

class AliasedModel(BaseModel):
    """Model with field aliases."""
    
    username: str = Field(..., alias="user_name")
    full_name: str = Field(..., alias="fullName")
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        alias="createdAt"
    )
    
    model_config = ConfigDict(
        populate_by_name=True,  # Allow both name and alias
    )

# Usage with alias
data = {
    "user_name": "john_doe",
    "fullName": "John Doe",
    "createdAt": "2024-01-01T12:00:00Z"
}
model = AliasedModel(**data)
print(model.username)  # john_doe
print(model.full_name)  # John Doe

# Serialize using names
print(model.model_dump(by_alias=False))
# > {'username': 'john_doe', 'full_name': 'John Doe', ...}

# Serialize using aliases
print(model.model_dump(by_alias=True))
# > {'user_name': 'john_doe', 'fullName': 'John Doe', ...}

# ────────────────────────────────────────────────────────────────
# 5. Custom Serialization
# ────────────────────────────────────────────────────────────────

class SerializationModel(BaseModel):
    """Model with custom serialization."""
    
    name: str
    password: str
    secret_key: str
    
    model_config = ConfigDict(
        # Exclude certain fields from serialization
        fields={
            'password': {'exclude': True},
            'secret_key': {'exclude': True},
        }
    )
    
    # Custom serialization method
    def model_dump(self, **kwargs) -> Dict[str, Any]:
        """Custom dump that excludes sensitive fields."""
        data = super().model_dump(**kwargs)
        # Remove sensitive data
        data.pop('password', None)
        data.pop('secret_key', None)
        return data

# ────────────────────────────────────────────────────────────────
# 6. Schema Customization
# ────────────────────────────────────────────────────────────────

class SchemaCustomization(BaseModel):
    """Model with custom schema."""
    
    id: int = Field(
        ...,
        description="Unique identifier",
        examples=[1, 2, 3]
    )
    
    name: str = Field(
        ...,
        description="User's full name",
        min_length=1,
        max_length=100,
        examples=["John Doe"]
    )
    
    email: str = Field(
        ...,
        description="User's email address",
        pattern=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        examples=["john@example.com"]
    )
    
    age: Optional[int] = Field(
        default=None,
        description="User's age",
        ge=0,
        le=150,
        examples=[30, 25, 40]
    )
    
    model_config = ConfigDict(
        json_schema_extra={
            "title": "User Schema",
            "description": "Schema for user data",
            "examples": [
                {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com",
                    "age": 30
                }
            ]
        }
    )

# ────────────────────────────────────────────────────────────────
# 7. Strict Mode
# ────────────────────────────────────────────────────────────────

class StrictModel(BaseModel):
    """Model in strict mode."""
    
    name: str
    age: int
    is_active: bool
    
    model_config = ConfigDict(
        strict=True,  # Strict type checking
    )

# This works
strict = StrictModel(name="John", age=30, is_active=True)

# This fails (no coercion)
# strict = StrictModel(name="John", age="30", is_active="true")
# > ValidationError: age: Input should be a valid integer

# ────────────────────────────────────────────────────────────────
# 8. Immutability
# ────────────────────────────────────────────────────────────────

class ImmutableModel(BaseModel):
    """Immutable model."""
    
    id: int
    name: str
    
    model_config = ConfigDict(
        frozen=True,  # Make model immutable
    )

model = ImmutableModel(id=1, name="John")
# model.name = "Jane"  # ValidationError (frozen)

# ────────────────────────────────────────────────────────────────
# 9. Custom Config with Inheritance
# ────────────────────────────────────────────────────────────────

class BaseConfigModel(BaseModel):
    """Base model with common configuration."""
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None
    
    model_config = ConfigDict(
        from_attributes=True,
        extra="forbid",
        validate_assignment=True,
    )

class UserModel(BaseConfigModel):
    """User model inheriting configuration."""
    
    name: str
    email: str
    
    # Override config if needed
    model_config = ConfigDict(
        extra="allow",  # Override the base config
    )

# ────────────────────────────────────────────────────────────────
# 10. Environment Variable Integration
# ────────────────────────────────────────────────────────────────

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """Settings model with environment variables."""
    
    app_name: str = "My App"
    app_version: str = "1.0.0"
    debug: bool = False
    database_url: str
    
    model_config = ConfigDict(
        env_prefix="APP_",  # Prefix for environment variables
        env_file=".env",     # Load from .env file
        env_file_encoding="utf-8",
        extra="ignore",
    )

# Usage
# Load from environment variables:
# APP_APP_NAME="My App"
# APP_DEBUG=True
# APP_DATABASE_URL=postgresql://...
```

---

## Performance Optimization

### Pydantic Performance Tips

```python
"""
Pydantic performance optimization
"""

from pydantic import BaseModel, Field, TypeAdapter
from typing import List, Dict, Any, Optional
import time
import json

# ────────────────────────────────────────────────────────────────
# 1. Using TypeAdapter for Performance
# ────────────────────────────────────────────────────────────────

class User(BaseModel):
    """Simple user model."""
    id: int
    name: str
    email: str
    is_active: bool = True

# TypeAdapter is faster for validating single values
user_adapter = TypeAdapter(User)
list_adapter = TypeAdapter(List[User])

# Validate a single value
user = user_adapter.validate_python({
    "id": 1,
    "name": "John",
    "email": "john@example.com"
})

# Validate a list
users = list_adapter.validate_python([
    {"id": 1, "name": "User 1", "email": "u1@example.com"},
    {"id": 2, "name": "User 2", "email": "u2@example.com"},
])

# ────────────────────────────────────────────────────────────────
# 2. Validation Performance Comparison
# ────────────────────────────────────────────────────────────────

def performance_comparison():
    """Compare validation performance."""
    
    data = {"id": 1, "name": "John", "email": "john@example.com", "is_active": True}
    
    # Method 1: Direct model creation
    start = time.perf_counter()
    for _ in range(10000):
        user = User(**data)
    direct_time = time.perf_counter() - start
    
    # Method 2: Using TypeAdapter
    adapter = TypeAdapter(User)
    start = time.perf_counter()
    for _ in range(10000):
        user = adapter.validate_python(data)
    adapter_time = time.perf_counter() - start
    
    print(f"Direct creation: {direct_time:.4f}s")
    print(f"TypeAdapter: {adapter_time:.4f}s")
    print(f"Speedup: {direct_time/adapter_time:.2f}x")

# ────────────────────────────────────────────────────────────────
# 3. Caching with lru_cache
# ────────────────────────────────────────────────────────────────

from functools import lru_cache

@lru_cache(maxsize=128)
def get_user_schema():
    """Cache the model schema."""
    return User.model_json_schema()

@lru_cache(maxsize=1000)
def validate_user_cached(data_tuple):
    """Cached validation for repeated data."""
    data = dict(data_tuple)
    return User(**data)

# Usage
data_tuple = tuple({"id": 1, "name": "John", "email": "john@example.com"}.items())
user = validate_user_cached(data_tuple)

# ────────────────────────────────────────────────────────────────
# 4. Optimizing Validation with model_validate
# ────────────────────────────────────────────────────────────────

class OptimizedModel(BaseModel):
    """Model optimized for performance."""
    
    id: int
    name: str
    tags: List[str] = Field(default_factory=list)
    metadata: Dict[str, Any] = Field(default_factory=dict)
    
    @classmethod
    def from_dict_optimized(cls, data: Dict[str, Any]) -> 'OptimizedModel':
        """Optimized creation from dict."""
        # Use model_validate for better performance
        return cls.model_validate(data)

# Usage
data = {"id": 1, "name": "Test", "tags": ["tag1", "tag2"]}
model = OptimizedModel.from_dict_optimized(data)

# ────────────────────────────────────────────────────────────────
# 5. Avoiding Unnecessary Validation
# ────────────────────────────────────────────────────────────────

def avoid_unnecessary_validation():
    """Strategies to avoid unnecessary validation."""
    
    # Use TypeAdapter for data that's already validated
    user_adapter = TypeAdapter(User)
    
    # Use simple dicts for internal data when validation isn't needed
    user_dict = {"id": 1, "name": "John", "email": "john@example.com"}
    
    # Only validate at system boundaries (API input/output)
    # Use unvalidated data internally
    
    # Cache validation results for repeated data
    validation_cache = {}
    
    def get_validated_user(data):
        key = json.dumps(data, sort_keys=True)
        if key not in validation_cache:
            validation_cache[key] = User(**data)
        return validation_cache[key]

# ────────────────────────────────────────────────────────────────
# 6. Benchmarking Different Approaches
# ────────────────────────────────────────────────────────────────

def benchmark_validators():
    """Benchmark different validation approaches."""
    
    test_data = [
        {"id": i, "name": f"User {i}", "email": f"user{i}@example.com"}
        for i in range(100)
    ]
    
    # Approach 1: Individual validation
    start = time.perf_counter()
    users1 = [User(**data) for data in test_data]
    time1 = time.perf_counter() - start
    
    # Approach 2: Batch validation with TypeAdapter
    start = time.perf_counter()
    users2 = TypeAdapter(List[User]).validate_python(test_data)
    time2 = time.perf_counter() - start
    
    # Approach 3: Model validate on list
    start = time.perf_counter()
    users3 = [User.model_validate(data) for data in test_data]
    time3 = time.perf_counter() - start
    
    print(f"Individual validation: {time1:.4f}s")
    print(f"TypeAdapter batch: {time2:.4f}s")
    print(f"model_validate: {time3:.4f}s")
    print(f"Fastest: {min(time1, time2, time3):.4f}s")

# ────────────────────────────────────────────────────────────────
# 7. Serialization Optimization
# ────────────────────────────────────────────────────────────────

def serialize_optimization():
    """Optimize serialization performance."""
    
    user = User(id=1, name="John", email="john@example.com")
    
    # Approach 1: model_dump_json
    start = time.perf_counter()
    for _ in range(10000):
        json_str = user.model_dump_json()
    time1 = time.perf_counter() - start
    
    # Approach 2: model_dump + json.dumps
    start = time.perf_counter()
    for _ in range(10000):
        json_str = json.dumps(user.model_dump())
    time2 = time.perf_counter() - start
    
    # Approach 3: model_dump with fast serialization
    start = time.perf_counter()
    for _ in range(10000):
        json_str = json.dumps(
            user.model_dump(mode='python'),
            default=str
        )
    time3 = time.perf_counter() - start
    
    print(f"model_dump_json: {time1:.4f}s")
    print(f"model_dump + json.dumps: {time2:.4f}s")
    print(f"Optimized: {time3:.4f}s")
```

---

## Advanced Features

### Advanced Pydantic Features

```python
"""
Advanced Pydantic features
"""

from pydantic import BaseModel, Field, create_model, RootModel
from typing import Optional, List, Dict, Any, Union, Callable
import json
from datetime import datetime

# ────────────────────────────────────────────────────────────────
# 1. Dynamic Model Creation
# ────────────────────────────────────────────────────────────────

def create_dynamic_model(fields: Dict[str, Any]) -> BaseModel:
    """Create a model dynamically."""
    return create_model(
        'DynamicModel',
        **fields
    )

# Usage
DynamicUser = create_dynamic_model({
    'id': (int, ...),
    'name': (str, ...),
    'age': (Optional[int], None)
})

user = DynamicUser(id=1, name="John")
print(user)  # id=1 name='John' age=None

# With field validation
DynamicProduct = create_model(
    'DynamicProduct',
    name=(str, Field(..., min_length=1, max_length=100)),
    price=(float, Field(..., gt=0)),
    __config__=None
)

# ────────────────────────────────────────────────────────────────
# 2. Root Models
# ────────────────────────────────────────────────────────────────

class RootListModel(RootModel):
    """Model that wraps a list."""
    root: List[int]

# Usage
model = RootListModel(root=[1, 2, 3, 4, 5])
print(model.root)  # [1, 2, 3, 4, 5]

# With validation
class ValidatedList(RootModel):
    root: List[str]
    
    @field_validator('root')
    @classmethod
    def validate_list(cls, v: List[str]) -> List[str]:
        if len(v) > 10:
            raise ValueError('List cannot have more than 10 items')
        return v

# ────────────────────────────────────────────────────────────────
# 3. Discriminated Unions
# ────────────────────────────────────────────────────────────────

from pydantic import Tag

class BaseEvent(BaseModel):
    """Base event model."""
    event_type: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class UserCreated(BaseEvent):
    """User created event."""
    event_type: Literal["user.created"] = "user.created"
    user_id: int
    username: str

class TaskAssigned(BaseEvent):
    """Task assigned event."""
    event_type: Literal["task.assigned"] = "task.assigned"
    task_id: int
    assignee_id: int
    assigned_by: int

# Discriminated union with Tag
Event = Union[
    Annotated[UserCreated, Tag("user.created")],
    Annotated[TaskAssigned, Tag("task.assigned")],
]

# Usage
event_data = {
    "event_type": "user.created",
    "user_id": 1,
    "username": "john_doe",
    "timestamp": "2024-01-01T12:00:00Z"
}

event = Event.model_validate(event_data)
print(type(event))  # UserCreated

# ────────────────────────────────────────────────────────────────
# 4. Custom Type Validation
# ────────────────────────────────────────────────────────────────

from pydantic import GetJsonSchemaHandler
from pydantic.json_schema import JsonSchemaValue
from typing import Any

class PhoneNumber:
    """Custom phone number type."""
    
    def __init__(self, value: str):
        # Validate phone number
        if not re.match(r'^\+?1?\d{9,15}$', value):
            raise ValueError('Invalid phone number format')
        self.value = value
    
    def __str__(self):
        return self.value
    
    @classmethod
    def __get_pydantic_core_schema__(
        cls,
        source_type: Any,
        handler: GetCoreSchemaHandler
    ) -> CoreSchema:
        """Pydantic schema for custom type."""
        from pydantic_core import core_schema
        
        return core_schema.general_after_validator_function(
            cls._validate,
            core_schema.str_schema(),
        )
    
    @classmethod
    def _validate(cls, value: str):
        return cls(value)

# Usage in model
class UserWithPhone(BaseModel):
    name: str
    phone: PhoneNumber

user = UserWithPhone(name="John", phone="+1234567890")
print(user.phone)  # +1234567890

# ────────────────────────────────────────────────────────────────
# 5. Computed Fields
# ────────────────────────────────────────────────────────────────

from pydantic import computed_field

class UserWithComputed(BaseModel):
    """Model with computed fields."""
    
    first_name: str
    last_name: str
    email: str
    
    @computed_field
    @property
    def full_name(self) -> str:
        """Computed full name."""
        return f"{self.first_name} {self.last_name}"
    
    @computed_field
    @property
    def email_domain(self) -> str:
        """Computed email domain."""
        return self.email.split('@')[-1]

user = UserWithComputed(
    first_name="John",
    last_name="Doe",
    email="john@example.com"
)

print(user.full_name)  # John Doe
print(user.email_domain)  # example.com
print(user.model_dump())
# > {'first_name': 'John', 'last_name': 'Doe', 'email': 'john@example.com', 'full_name': 'John Doe', 'email_domain': 'example.com'}

# ────────────────────────────────────────────────────────────────
# 6. Private Fields
# ────────────────────────────────────────────────────────────────

class ModelWithPrivate(BaseModel):
    """Model with private fields."""
    
    name: str
    _internal_id: Optional[str] = None
    
    def __init__(self, **data):
        super().__init__(**data)
        self._internal_id = f"internal_{self.name.lower()}"
    
    @property
    def internal_id(self) -> str:
        """Access private field."""
        return self._internal_id

model = ModelWithPrivate(name="John")
print(model.internal_id)  # internal_john
print(model.model_dump())  # {'name': 'John'}  # Private fields excluded

# ────────────────────────────────────────────────────────────────
# 7. Custom Validation Context
# ────────────────────────────────────────────────────────────────

class ContextAwareModel(BaseModel):
    """Model with validation context."""
    
    name: str
    role: str
    
    @field_validator('role')
    @classmethod
    def validate_role(cls, v: str, info: ValidationInfo) -> str:
        """Validate role with context."""
        context = info.context or {}
        allowed_roles = context.get('allowed_roles', ['admin', 'user'])
        
        if v not in allowed_roles:
            raise ValueError(f'Role must be one of: {allowed_roles}')
        
        return v

# Usage with context
context = {'allowed_roles': ['admin', 'manager', 'viewer']}
user = ContextAwareModel.model_validate(
    {'name': 'John', 'role': 'manager'},
    context=context
)

# ────────────────────────────────────────────────────────────────
# 8. Model Transformers
# ────────────────────────────────────────────────────────────────

class TransformedModel(BaseModel):
    """Model with data transformation."""
    
    raw_data: Dict[str, Any]
    
    @field_validator('raw_data', mode='before')
    @classmethod
    def transform_data(cls, v: Any) -> Dict[str, Any]:
        """Transform data before validation."""
        if isinstance(v, str):
            # Parse JSON string
            return json.loads(v)
        return v
    
    @model_validator(mode='after')
    def process_data(self) -> 'TransformedModel':
        """Process data after validation."""
        # Extract specific fields
        self.processed = {
            'id': self.raw_data.get('id'),
            'name': self.raw_data.get('name'),
        }
        return self

# ────────────────────────────────────────────────────────────────
# 9. Custom JSON Encoder/Decoder
# ────────────────────────────────────────────────────────────────

class CustomJSONModel(BaseModel):
    """Model with custom JSON handling."""
    
    id: int
    name: str
    metadata: Dict[str, Any]
    
    def model_dump_json(self, **kwargs) -> str:
        """Custom JSON serialization."""
        # Use default implementation but with custom formatting
        return json.dumps(
            self.model_dump(**kwargs),
            indent=2,
            default=str
        )
    
    @classmethod
    def parse_raw(cls, data: str) -> 'CustomJSONModel':
        """Custom parsing from JSON."""
        parsed = json.loads(data)
        return cls(**parsed)

# ────────────────────────────────────────────────────────────────
# 10. Validation with Before/After Hooks
# ────────────────────────────────────────────────────────────────

class HooksModel(BaseModel):
    """Model with validation hooks."""
    
    name: str
    age: int
    
    @model_validator(mode='before')
    @classmethod
    def pre_validate(cls, data: Any) -> Any:
        """Hook before validation."""
        print(f"Pre-validation: {data}")
        return data
    
    @model_validator(mode='after')
    def post_validate(self) -> 'HooksModel':
        """Hook after validation."""
        print(f"Post-validation: {self}")
        return self
```

---

## Best Practices

### Pydantic Best Practices Guide

```python
"""
Pydantic best practices
"""

from pydantic import BaseModel, Field, field_validator
from typing import Optional, List
from datetime import datetime
import re

# ────────────────────────────────────────────────────────────────
# 1. Model Organization
# ────────────────────────────────────────────────────────────────

# Good: Separate request and response models
class UserCreate(BaseModel):
    """Request model for creating a user."""
    username: str
    email: str
    password: str

class UserResponse(BaseModel):
    """Response model for user data."""
    id: int
    username: str
    email: str
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class UserUpdate(BaseModel):
    """Request model for updating a user."""
    username: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None

# ────────────────────────────────────────────────────────────────
# 2. Validation Organization
# ────────────────────────────────────────────────────────────────

class UserValidation(BaseModel):
    """Model with well-organized validation."""
    
    username: str
    email: str
    password: str
    
    # Group related validators
    @field_validator('username')
    @classmethod
    def validate_username(cls, v: str) -> str:
        """Username validation."""
        return v.lower()
    
    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        """Email validation."""
        return v.lower().strip()
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Password validation."""
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v

# ────────────────────────────────────────────────────────────────
# 3. Use Enums for Constants
# ────────────────────────────────────────────────────────────────

from enum import Enum

class Priority(str, Enum):
    """Task priority."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class Status(str, Enum):
    """Task status."""
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    DONE = "done"

class TaskModel(BaseModel):
    """Task model using enums."""
    title: str
    priority: Priority
    status: Status = Status.TODO

# ────────────────────────────────────────────────────────────────
# 4. Use Type Hints Properly
# ────────────────────────────────────────────────────────────────

from typing import Optional, List, Union

class ProperTypeHints(BaseModel):
    """Model with proper type hints."""
    
    # Use specific types
    user_id: int
    name: str
    tags: List[str]  # Not list
    
    # Use Optional for nullable fields
    description: Optional[str] = None
    
    # Use Union for multiple types
    metadata: Union[Dict[str, Any], None] = None
    
    # Use Any sparingly
    raw_data: Any = None

# ────────────────────────────────────────────────────────────────
# 5. Use Field for Documentation
# ────────────────────────────────────────────────────────────────

class DocumentedModel(BaseModel):
    """Model with field documentation."""
    
    id: int = Field(..., description="Unique identifier")
    name: str = Field(
        ...,
        description="User's full name",
        examples=["John Doe", "Jane Smith"]
    )
    email: str = Field(
        ...,
        description="User's email address",
        pattern=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        description="Creation timestamp"
    )
    
    model_config = ConfigDict(
        json_schema_extra={
            "description": "User model with comprehensive documentation",
        }
    )

# ────────────────────────────────────────────────────────────────
# 6. Use Model Validators for Cross-Field Validation
# ────────────────────────────────────────────────────────────────

class CrossFieldValidation(BaseModel):
    """Model with cross-field validation."""
    
    start_date: datetime
    end_date: datetime
    
    @model_validator(mode='after')
    def validate_dates(self) -> 'CrossFieldValidation':
        """Ensure end_date is after start_date."""
        if self.end_date <= self.start_date:
            raise ValueError('End date must be after start date')
        return self

# ────────────────────────────────────────────────────────────────
# 7. Handle Optional Fields Properly
# ────────────────────────────────────────────────────────────────

class OptionalFieldHandling(BaseModel):
    """Model with proper optional field handling."""
    
    # Optional with default
    optional_field: Optional[str] = None
    
    # Required but can be None
    required_but_nullable: str | None
    
    # Optional but must be validated if present
    conditional_required: Optional[str] = Field(
        default=None,
        min_length=1,
        max_length=100
    )

# ────────────────────────────────────────────────────────────────
# 8. Use Type Adapters for Performance
# ────────────────────────────────────────────────────────────────

from pydantic import TypeAdapter

# Define adapters at module level for reuse
user_adapter = TypeAdapter(UserResponse)
users_adapter = TypeAdapter(List[UserResponse])

# Use adapters for better performance
def get_user_response(data: dict) -> UserResponse:
    return user_adapter.validate_python(data)

def get_users_response(data: List[dict]) -> List[UserResponse]:
    return users_adapter.validate_python(data)

# ────────────────────────────────────────────────────────────────
# 9. Avoid Deep Nesting
# ────────────────────────────────────────────────────────────────

# Bad: Deeply nested
class DeepNested(BaseModel):
    data: Dict[str, Dict[str, Dict[str, Any]]]  # Hard to validate

# Good: Flatten nested structures
class NestedLevel1(BaseModel):
    field1: str
    field2: int

class NestedLevel2(BaseModel):
    nested: NestedLevel1

class FlatStructure(BaseModel):
    """Flat structure is easier to validate."""
    field1: str
    field2: int
    field3: str
    field4: int

# ────────────────────────────────────────────────────────────────
# 10. Use Configuration Wisely
# ────────────────────────────────────────────────────────────────

class WellConfigured(BaseModel):
    """Model with sensible configuration."""
    
    id: int
    name: str
    
    model_config = ConfigDict(
        # Use from_attributes for ORM support
        from_attributes=True,
        
        # Use extra='forbid' to prevent unexpected fields
        extra='forbid',
        
        # Validate on assignment
        validate_assignment=True,
        
        # Use populate_by_name for flexibility
        populate_by_name=True,
        
        # Good for API documentation
        json_schema_extra={
            "example": {
                "id": 1,
                "name": "John Doe"
            }
        }
    )
```

---

This primer has provided a comprehensive deep dive into Pydantic V2. You should now understand:

1. **Basic Models**: Creating models with fields and type hints
2. **Field Validation**: Built-in validators and constraints
3. **Custom Validators**: Field and model-level validation
4. **Nested Models**: Working with complex data structures
5. **Generic Models**: Type-safe generic models
6. **Configuration**: Model configuration options
7. **Performance**: Optimization techniques
8. **Advanced Features**: Dynamic models, root models, discriminated unions
9. **Best Practices**: Organizing models and validation

These concepts are fundamental to building robust, type-safe FastAPI applications with Pydantic. Practice these patterns and refer back to this primer whenever you need to understand data validation in your applications.

**[END OF PRIMER 3]**

---

## Series Conclusion

Congratulations on completing the entire FastAPI Masterclass series including all primers! You now have a comprehensive understanding of:

**Main Series:**
- Building production-ready FastAPI applications
- Database integration with SQLAlchemy 2.0
- Authentication and authorization
- Advanced features (WebSockets, Celery, caching)
- Testing, CI/CD, and deployment
- Enterprise architecture patterns

**Primers:**
- Python Async/Await Deep Dive
- SQLAlchemy 2.0 Deep Dive
- Pydantic V2 Deep Dive

You are now equipped with the knowledge and skills to build, deploy, and maintain enterprise-grade FastAPI applications. Keep learning, keep building, and share your knowledge with the community!

**[END OF PRIMER 3]**
