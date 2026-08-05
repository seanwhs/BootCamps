# APPENDIX M — Code Generation Templates & Scaffolding

## Accelerating ScaleCart Development with Templates

---

## M.1 Introduction

This appendix provides complete code generation templates and scaffolding tools for rapidly building new components in the ScaleCart platform. It covers:

1. **Model Templates** – Creating new database models
2. **Service Templates** – Building business logic services
3. **API Templates** – Generating FastAPI endpoints
4. **Migration Templates** – Alembic migration scaffolding
5. **Test Templates** – Unit and integration test generation
6. **Script Templates** – Utility script scaffolding
7. **CLI Tool** – Automated code generation

---

## M.2 Model Templates

### M.2.1 SQLAlchemy Model Template

```python
# File: src/models/_template.py
# Template for creating new SQLAlchemy models
"""
{model_name} model for {feature_name}.
"""

from sqlalchemy import Column, Integer, String, Numeric, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from src.utils.db import Base
from src.utils.audit import AuditMixin
from typing import Optional, List
import enum

# ============================================
# ENUMS
# ============================================

class {ModelName}Status(str, enum.Enum):
    """Status enumeration for {model_name}."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    PENDING = "pending"
    # Add more statuses as needed

# ============================================
# MODEL
# ============================================

class {ModelName}(Base, AuditMixin):
    """
    {ModelName} model representing {feature_description}.
    
    Attributes:
        id: Primary key
        {field1}: Description of field1
        {field2}: Description of field2
        created_at: Creation timestamp
        updated_at: Last update timestamp
    """
    
    __tablename__ = "{table_name}"
    
    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # Core fields
    name = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    status = Column(String(50), nullable=False, default={ModelName}Status.ACTIVE.value)
    
    # Numeric fields
    amount = Column(Numeric(10, 2), nullable=True)
    quantity = Column(Integer, default=0)
    
    # Boolean flags
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    
    # Foreign keys
    {foreign_key}_id = Column(Integer, ForeignKey("{related_table}.id"), nullable=True)
    
    # Relationships
    {foreign_key} = relationship("{RelatedModel}", back_populates="{model_name}s")
    items = relationship("{ItemModel}", back_populates="{model_name}", lazy="dynamic")
    
    # Timestamps (from AuditMixin)
    # created_at = Column(DateTime, server_default=func.now())
    # updated_at = Column(DateTime, onupdate=func.now())
    
    # Metadata
    metadata = Column(JSONB, nullable=True)
    
    def __repr__(self) -> str:
        """String representation."""
        return f"<{ModelName}(id={self.id}, name='{self.name}')>"
    
    def to_dict(self) -> dict:
        """Convert model to dictionary."""
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "status": self.status,
            "amount": float(self.amount) if self.amount else None,
            "quantity": self.quantity,
            "is_active": self.is_active,
            "is_verified": self.is_verified,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

# ============================================
# ASSOCIATION TABLE (Many-to-Many)
# ============================================

{model_name}_{related_model}_association = Table(
    "{table_name}_{related_table}",
    Base.metadata,
    Column("{model_name}_id", Integer, ForeignKey("{table_name}.id"), primary_key=True),
    Column("{related_model}_id", Integer, ForeignKey("{related_table}.id"), primary_key=True),
    Column("created_at", DateTime, server_default=func.now()),
    Column("metadata", JSONB, nullable=True)
)

# ============================================
# SCHEMAS (Pydantic)
# ============================================

from pydantic import BaseModel, Field, validator
from datetime import datetime
from typing import Optional

class {ModelName}Base(BaseModel):
    """Base {ModelName} schema."""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    status: str = Field(default="{ModelName}Status.ACTIVE.value")
    amount: Optional[float] = Field(None, ge=0)
    quantity: int = Field(default=0, ge=0)
    is_active: bool = True
    
    @validator("name")
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError("Name cannot be empty")
        return v.strip()

class {ModelName}Create({ModelName}Base):
    """Schema for creating a {ModelName}."""
    pass

class {ModelName}Update(BaseModel):
    """Schema for updating a {ModelName}."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    status: Optional[str] = None
    amount: Optional[float] = Field(None, ge=0)
    quantity: Optional[int] = Field(None, ge=0)
    is_active: Optional[bool] = None

class {ModelName}InDB({ModelName}Base):
    """Schema for {ModelName} as stored in database."""
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

# ============================================
# SERVICE
# ============================================

from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any
from src.services.base import BaseService

class {ModelName}Service(BaseService[{ModelName}]):
    """Service for {ModelName} operations."""
    
    def __init__(self, db_session: Session):
        super().__init__(db_session, {ModelName})
        self.db = db_session
    
    def get_active(self, skip: int = 0, limit: int = 100) -> List[{ModelName}]:
        """Get active {model_name}s."""
        return self.db.query({ModelName}).filter(
            {ModelName}.is_active == True
        ).offset(skip).limit(limit).all()
    
    def get_by_status(self, status: str) -> List[{ModelName}]:
        """Get {model_name}s by status."""
        return self.db.query({ModelName}).filter(
            {ModelName}.status == status
        ).all()
    
    def create(self, data: Dict[str, Any]) -> {ModelName}:
        """Create a new {model_name}."""
        # Add any business logic here
        return super().create(data)
    
    def update(self, id: int, data: Dict[str, Any]) -> {ModelName}:
        """Update an existing {model_name}."""
        # Add any business logic here
        return super().update(id, data)
    
    def soft_delete(self, id: int) -> bool:
        """Soft delete a {model_name} (mark as inactive)."""
        return self.update(id, {"is_active": False}) is not None

# ============================================
# FACTORY (for testing)
# ============================================

import factory
from faker import Faker
from .{table_name} import {ModelName}

fake = Faker()

class {ModelName}Factory(factory.alchemy.SQLAlchemyModelFactory):
    """Factory for creating test {ModelName} instances."""
    
    class Meta:
        model = {ModelName}
        sqlalchemy_session = None
    
    name = factory.LazyAttribute(lambda _: fake.catch_phrase())
    description = factory.LazyAttribute(lambda _: fake.text(max_nb_chars=200))
    status = factory.Iterator(["active", "inactive", "pending"])
    amount = factory.LazyAttribute(lambda _: round(fake.random_number(digits=3), 2))
    quantity = factory.LazyAttribute(lambda _: fake.random_int(min=0, max=100))
    is_active = True
```

### M.2.2 Model Generator Script

```python
#!/usr/bin/env python3
# File: scripts/generate_model.py
"""
Generate a new model with all required components.
Usage: python scripts/generate_model.py ModelName feature_name
"""

import os
import sys
from pathlib import Path

def generate_model(model_name: str, feature_name: str):
    """Generate a new model."""
    
    # Convert names to various formats
    snake_case = model_name.lower()
    table_name = snake_case + "s"
    foreign_key = snake_case + "_id"
    related_model = model_name + "Related"
    related_table = related_model.lower() + "s"
    item_model = model_name + "Item"
    
    # Paths
    project_root = Path(__file__).parent.parent
    models_dir = project_root / "src" / "models"
    services_dir = project_root / "src" / "services"
    schemas_dir = project_root / "src" / "schemas"
    
    # Create directories if they don't exist
    models_dir.mkdir(parents=True, exist_ok=True)
    services_dir.mkdir(parents=True, exist_ok=True)
    schemas_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate model file
    model_file = models_dir / f"{snake_case}.py"
    if model_file.exists():
        print(f"❌ {model_file} already exists")
        return False
    
    # Read template
    template = """# File: src/models/{snake_case}.py
\"\"\"
{model_name} model for {feature_name}.
\"\"\"

from sqlalchemy import Column, Integer, String, Numeric, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from src.utils.db import Base
from src.utils.audit import AuditMixin
from typing import Optional, List
import enum

class {ModelName}Status(str, enum.Enum):
    \"\"\"Status enumeration for {model_name}.\"\"\"
    ACTIVE = "active"
    INACTIVE = "inactive"
    PENDING = "pending"

class {ModelName}(Base, AuditMixin):
    \"\"\"
    {ModelName} model for {feature_name}.
    \"\"\"
    
    __tablename__ = "{table_name}"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    status = Column(String(50), nullable=False, default={ModelName}Status.ACTIVE.value)
    amount = Column(Numeric(10, 2), nullable=True)
    quantity = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    metadata = Column(JSONB, nullable=True)
    
    def __repr__(self) -> str:
        return f"<{ModelName}(id={{self.id}}, name='{{self.name}}')>"
    
    def to_dict(self) -> dict:
        return {{
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "status": self.status,
            "amount": float(self.amount) if self.amount else None,
            "quantity": self.quantity,
            "is_active": self.is_active,
            "is_verified": self.is_verified,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }}
"""
    
    # Fill template
    content = template.format(
        snake_case=snake_case,
        model_name=model_name,
        feature_name=feature_name,
        table_name=table_name,
        ModelName=model_name,
        model_name=snake_case,
    )
    
    # Write file
    model_file.write_text(content)
    print(f"✅ Created {model_file}")
    
    # Generate service file
    service_file = services_dir / f"{snake_case}_service.py"
    if not service_file.exists():
        service_template = """# File: src/services/{snake_case}_service.py
\"\"\"
Service for {model_name} operations.
\"\"\"

from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any
from src.models.{snake_case} import {ModelName}
from src.services.base import BaseService

class {ModelName}Service(BaseService[{ModelName}]):
    \"\"\"Service for {ModelName} operations.\"\"\"
    
    def __init__(self, db_session: Session):
        super().__init__(db_session, {ModelName})
    
    def get_active(self, skip: int = 0, limit: int = 100) -> List[{ModelName}]:
        \"\"\"Get active {model_name}s.\"\"\"
        return self.db.query({ModelName}).filter(
            {ModelName}.is_active == True
        ).offset(skip).limit(limit).all()
    
    def get_by_status(self, status: str) -> List[{ModelName}]:
        \"\"\"Get {model_name}s by status.\"\"\"
        return self.db.query({ModelName}).filter(
            {ModelName}.status == status
        ).all()
    
    def soft_delete(self, id: int) -> bool:
        \"\"\"Soft delete a {model_name}.\"\"\"
        return self.update(id, {{"is_active": False}}) is not None
"""
        service_file.write_text(service_template.format(
            snake_case=snake_case,
            model_name=model_name,
            ModelName=model_name,
        ))
        print(f"✅ Created {service_file}")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python scripts/generate_model.py ModelName feature_name")
        sys.exit(1)
    
    model_name = sys.argv[1]
    feature_name = sys.argv[2]
    
    generate_model(model_name, feature_name)
```

---

## M.3 API Templates

### M.3.1 FastAPI CRUD Endpoint Template

```python
# File: src/api/routes/_template.py
"""
API endpoints for {model_name} management.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from src.utils.db import get_db
from src.services.{model_name}_service import {ModelName}Service
from src.models.{model_name} import {ModelName}
from src.schemas.{model_name} import (
    {ModelName}Base,
    {ModelName}Create,
    {ModelName}Update,
    {ModelName}InDB
)
from src.security.auth import get_current_user, require_role

router = APIRouter(
    prefix="/{api_prefix}",
    tags=["{model_name}s"],
    responses={404: {"description": "Not found"}},
)

# ============================================
# PUBLIC ENDPOINTS
# ============================================

@router.get("/", response_model=dict)
async def list_{model_name}s(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    \"\"\"
    List {model_name}s with pagination and filtering.
    \"\"\"
    service = {ModelName}Service(db)
    
    # Build query
    query = db.query({ModelName})
    
    if status:
        query = query.filter({ModelName}.status == status)
    
    if search:
        query = query.filter({ModelName}.name.ilike(f"%{{search}}%"))
    
    total = query.count()
    items = query.offset(skip).limit(limit).all()
    
    return {
        "data": [item.to_dict() for item in items],
        "pagination": {
            "skip": skip,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit if limit > 0 else 0
        }
    }

@router.get("/{item_id}", response_model={ModelName}InDB)
async def get_{model_name}(
    item_id: int,
    db: Session = Depends(get_db)
):
    \"\"\"Get a specific {model_name} by ID.\"\"\"
    service = {ModelName}Service(db)
    item = service.get(item_id)
    
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="{ModelName} not found"
        )
    
    return item

# ============================================
# AUTHENTICATED ENDPOINTS
# ============================================

@router.post("/", response_model={ModelName}InDB, status_code=status.HTTP_201_CREATED)
async def create_{model_name}(
    data: {ModelName}Create,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    \"\"\"Create a new {model_name}.\"\"\"
    service = {ModelName}Service(db)
    
    try:
        item = service.create(data.dict())
        return item
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.put("/{item_id}", response_model={ModelName}InDB)
async def update_{model_name}(
    item_id: int,
    data: {ModelName}Update,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    \"\"\"Update an existing {model_name}.\"\"\"
    service = {ModelName}Service(db)
    
    try:
        item = service.update(item_id, data.dict(exclude_unset=True))
        if not item:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="{ModelName} not found"
            )
        return item
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_{model_name}(
    item_id: int,
    current_user: dict = Depends(require_role("admin")),
    db: Session = Depends(get_db)
):
    \"\"\"Delete a {model_name} (admin only).\"\"\"
    service = {ModelName}Service(db)
    
    if not service.delete(item_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="{ModelName} not found"
        )

# ============================================
# BULK OPERATIONS
# ============================================

@router.post("/bulk", response_model=List[{ModelName}InDB])
async def bulk_create_{model_name}s(
    items: List[{ModelName}Create],
    current_user: dict = Depends(require_role("admin")),
    db: Session = Depends(get_db)
):
    \"\"\"Bulk create {model_name}s (admin only).\"\"\"
    service = {ModelName}Service(db)
    created = []
    
    for data in items:
        try:
            item = service.create(data.dict())
            created.append(item)
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to create item: {str(e)}"
            )
    
    return created
```

---

## M.4 Migration Templates

### M.4.1 Alembic Migration Template

```python
# File: src/migrations/versions/_template.py
\"\"\"
{description}

Revision ID: {revision_id}
Revises: {down_revision}
Create Date: {create_date}
\"\"\"

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# Revision identifiers
revision = '{revision_id}'
down_revision = '{down_revision}'
branch_labels = None
depends_on = None

def upgrade():
    \"\"\"Apply the migration.\"\"\"
    # ============================================
    # ADD COLUMNS
    # ============================================
    
    # Add new column
    # op.add_column('table_name', sa.Column('column_name', sa.String(255), nullable=True))
    
    # ============================================
    # ADD TABLES
    # ============================================
    
    # op.create_table(
    #     'new_table',
    #     sa.Column('id', sa.Integer, primary_key=True),
    #     sa.Column('name', sa.String(255), nullable=False),
    #     sa.Column('created_at', sa.DateTime, server_default=sa.func.now()),
    # )
    
    # ============================================
    # CREATE INDEXES
    # ============================================
    
    # op.create_index('idx_table_column', 'table_name', ['column_name'])
    # op.create_index('idx_table_columns', 'table_name', ['col1', 'col2'], unique=False)
    
    # ============================================
    # CREATE FOREIGN KEYS
    # ============================================
    
    # op.create_foreign_key(
    #     'fk_table_column_refs',
    #     'table_name',
    #     'related_table',
    #     ['column_name'],
    #     ['id'],
    #     ondelete='CASCADE'
    # )
    
    # ============================================
    # ADD CONSTRAINTS
    # ============================================
    
    # op.create_unique_constraint('uq_table_column', 'table_name', ['column_name'])
    
    # ============================================
    # BACKFILL DATA
    # ============================================
    
    # connection = op.get_bind()
    # connection.execute(
    #     """
    #     UPDATE table_name 
    #     SET column_name = 'default_value' 
    #     WHERE column_name IS NULL
    #     """
    # )
    
    pass

def downgrade():
    \"\"\"Revert the migration.\"\"\"
    # Reverse order of upgrade operations
    
    # Drop foreign keys
    # op.drop_constraint('fk_table_column_refs', 'table_name', type_='foreignkey')
    
    # Drop indexes
    # op.drop_index('idx_table_column', table_name='table_name')
    
    # Drop tables
    # op.drop_table('new_table')
    
    # Drop columns
    # op.drop_column('table_name', 'column_name')
    
    pass
```

---

## M.5 Test Templates

### M.5.1 Unit Test Template

```python
# File: tests/test_{model_name}.py
\"\"\"
Unit tests for {ModelName}.
\"\"\"

import pytest
from sqlalchemy.exc import IntegrityError
from src.models.{model_name} import {ModelName}, {ModelName}Status
from src.services.{model_name}_service import {ModelName}Service
from tests.factories import {ModelName}Factory

class Test{ModelName}Model:
    \"\"\"Test {ModelName} model.\"\"\"
    
    def test_create_{model_name}(self, db_session):
        \"\"\"Test creating a {model_name}.\"\"\"
        item = {ModelName}(
            name="Test {ModelName}",
            description="Test description",
            status={ModelName}Status.ACTIVE.value
        )
        db_session.add(item)
        db_session.commit()
        
        assert item.id is not None
        assert item.created_at is not None
        assert item.name == "Test {ModelName}"
    
    def test_{model_name}_unique_constraint(self, db_session):
        \"\"\"Test unique constraint on {model_name}.\"\"\"
        # Add your unique constraint test here
        pass
    
    def test_{model_name}_default_status(self, db_session):
        \"\"\"Test default status is ACTIVE.\"\"\"
        item = {ModelName}(name="Test {ModelName}")
        db_session.add(item)
        db_session.commit()
        
        assert item.status == {ModelName}Status.ACTIVE.value

class Test{ModelName}Service:
    \"\"\"Test {ModelName}Service.\"\"\"
    
    @pytest.fixture
    def service(self, db_session):
        return {ModelName}Service(db_session)
    
    def test_create(self, service):
        \"\"\"Test creating a {model_name} via service.\"\"\"
        data = {{
            "name": "Service Test",
            "description": "Created by service"
        }}
        
        item = service.create(data)
        assert item.id is not None
        assert item.name == "Service Test"
    
    def test_get_active(self, service, db_session):
        \"\"\"Test getting active {model_name}s.\"\"\"
        # Create active items
        active_items = {ModelName}Factory.create_batch(3, is_active=True)
        inactive_items = {ModelName}Factory.create_batch(2, is_active=False)
        
        db_session.add_all(active_items + inactive_items)
        db_session.commit()
        
        results = service.get_active()
        assert len(results) == 3
        
        # Test with pagination
        results = service.get_active(limit=2)
        assert len(results) == 2
    
    def test_soft_delete(self, service, db_session):
        \"\"\"Test soft delete.\"\"\"
        item = {ModelName}Factory(is_active=True)
        db_session.add(item)
        db_session.commit()
        
        result = service.soft_delete(item.id)
        assert result is True
        
        # Verify it's marked inactive
        updated = service.get(item.id)
        assert updated.is_active is False
    
    def test_update(self, service, db_session):
        \"\"\"Test updating a {model_name}.\"\"\"
        item = {ModelName}Factory()
        db_session.add(item)
        db_session.commit()
        
        updated = service.update(item.id, {{"name": "Updated Name"}})
        assert updated.name == "Updated Name"

class Test{ModelName}API:
    \"\"\"Test {ModelName} API endpoints.\"\"\"
    
    def test_list_{model_name}s(self, client, db_session):
        \"\"\"Test GET /api/v1/{api_prefix}.\"\"\"
        # Create test data
        items = {ModelName}Factory.create_batch(5)
        db_session.add_all(items)
        db_session.commit()
        
        response = client.get(f"/api/v1/{api_prefix}")
        assert response.status_code == 200
        data = response.json()
        assert "data" in data
        assert "pagination" in data
        assert len(data["data"]) >= 1
    
    def test_get_{model_name}(self, client, db_session):
        \"\"\"Test GET /api/v1/{api_prefix}/{{id}}.\"\"\"
        item = {ModelName}Factory()
        db_session.add(item)
        db_session.commit()
        
        response = client.get(f"/api/v1/{api_prefix}/{{item.id}}")
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == item.id
        assert data["name"] == item.name
    
    def test_create_{model_name}_unauthorized(self, client):
        \"\"\"Test POST /api/v1/{api_prefix} without auth.\"\"\"
        response = client.post(
            f"/api/v1/{api_prefix}",
            json={{"name": "Test Item"}}
        )
        assert response.status_code == 401
    
    def test_create_{model_name}_authenticated(self, client, auth_token):
        \"\"\"Test POST /api/v1/{api_prefix} with auth.\"\"\"
        response = client.post(
            f"/api/v1/{api_prefix}",
            json={{"name": "Test Item"}},
            headers={{"Authorization": f"Bearer {{auth_token}}"}}
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Test Item"
```

---

## M.6 CLI Code Generator

### M.6.1 Main Generator Script

```python
#!/usr/bin/env python3
# File: scripts/generate.py
"""
ScaleCart Code Generator
Usage: python scripts/generate.py <type> <name> [options]
"""

import os
import sys
import argparse
from pathlib import Path
import subprocess

class CodeGenerator:
    """Code generation tool for ScaleCart."""
    
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        
    def generate(self, type: str, name: str, **kwargs):
        """Generate code based on type."""
        generators = {
            "model": self.generate_model,
            "api": self.generate_api,
            "service": self.generate_service,
            "migration": self.generate_migration,
            "test": self.generate_test,
            "all": self.generate_all,
        }
        
        if type not in generators:
            print(f"❌ Unknown type: {type}")
            print(f"Available types: {', '.join(generators.keys())}")
            return False
        
        return generators[type](name, **kwargs)
    
    def generate_model(self, name: str, **kwargs):
        """Generate a new model."""
        print(f"📝 Generating model: {name}")
        
        # Convert name to various formats
        snake_case = name.lower()
        model_name = name
        
        # Create model file
        model_file = self.project_root / "src" / "models" / f"{snake_case}.py"
        if model_file.exists():
            print(f"❌ {model_file} already exists")
            return False
        
        # Generate using template
        result = subprocess.run([
            sys.executable,
            str(self.project_root / "scripts" / "generate_model.py"),
            model_name,
            kwargs.get("feature", "general")
        ])
        
        return result.returncode == 0
    
    def generate_api(self, name: str, **kwargs):
        """Generate new API endpoints."""
        print(f"📝 Generating API: {name}")
        
        snake_case = name.lower()
        api_file = self.project_root / "src" / "api" / "routes" / f"{snake_case}.py"
        
        if api_file.exists():
            print(f"❌ {api_file} already exists")
            return False
        
        # Create API file from template
        # (Template handling code here)
        
        return True
    
    def generate_service(self, name: str, **kwargs):
        """Generate a new service."""
        print(f"📝 Generating service: {name}")
        
        snake_case = name.lower()
        service_file = self.project_root / "src" / "services" / f"{snake_case}_service.py"
        
        if service_file.exists():
            print(f"❌ {service_file} already exists")
            return False
        
        # Create service file from template
        # (Template handling code here)
        
        return True
    
    def generate_migration(self, name: str, **kwargs):
        """Generate a new migration."""
        print(f"📝 Generating migration: {name}")
        
        # Run alembic revision
        result = subprocess.run([
            "alembic", "revision", "--autogenerate", "-m", name
        ], cwd=str(self.project_root))
        
        return result.returncode == 0
    
    def generate_test(self, name: str, **kwargs):
        """Generate new test file."""
        print(f"📝 Generating tests: {name}")
        
        snake_case = name.lower()
        test_file = self.project_root / "tests" / f"test_{snake_case}.py"
        
        if test_file.exists():
            print(f"❌ {test_file} already exists")
            return False
        
        # Create test file from template
        # (Template handling code here)
        
        return True
    
    def generate_all(self, name: str, **kwargs):
        """Generate all components for a feature."""
        print(f"📝 Generating all components for: {name}")
        
        results = []
        results.append(self.generate_model(name, **kwargs))
        results.append(self.generate_api(name, **kwargs))
        results.append(self.generate_service(name, **kwargs))
        results.append(self.generate_test(name, **kwargs))
        
        return all(results)

def main():
    parser = argparse.ArgumentParser(description="ScaleCart Code Generator")
    parser.add_argument("type", help="Type to generate: model, api, service, migration, test, all")
    parser.add_argument("name", help="Name of the component")
    parser.add_argument("-f", "--feature", help="Feature name", default="general")
    parser.add_argument("--no-views", action="store_true", help="Skip view generation")
    parser.add_argument("--no-tests", action="store_true", help="Skip test generation")
    
    args = parser.parse_args()
    
    generator = CodeGenerator()
    kwargs = {
        "feature": args.feature,
        "include_views": not args.no_views,
        "include_tests": not args.no_tests,
    }
    
    success = generator.generate(args.type, args.name, **kwargs)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
```

---

## M.7 Quick Template Reference

### M.7.1 Template Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{model_name}` | Model name (PascalCase) | Product |
| `{snake_case}` | Model name (snake_case) | product |
| `{table_name}` | Table name (plural) | products |
| `{ModelName}` | Model name for Python | Product |
| `{feature_name}` | Feature description | Product Catalog |
| `{api_prefix}` | API route prefix | products |
| `{foreign_key}` | Foreign key column name | category_id |
| `{revision_id}` | Migration revision ID | abc123def456 |
| `{create_date}` | Current date | 2026-01-01 12:00:00 |

### M.7.2 Generator Commands

```bash
# Generate a complete feature
python scripts/generate.py all ProductCatalog --feature "Product Catalog"

# Generate just a model
python scripts/generate.py model Product --feature "Products"

# Generate API endpoints
python scripts/generate.py api Product

# Generate a service
python scripts/generate.py service Product

# Generate a migration
python scripts/generate.py migration "add_product_weight"

# Generate tests
python scripts/generate.py test Product
```

---

**[END OF APPENDIX M]**

*This comprehensive code generation guide provides templates and tools to accelerate development of new features in the ScaleCart platform. Use these templates to maintain consistency and reduce boilerplate code.*
