# FastAPI Masterclass: Student Workbook

**Building Production-Ready APIs**

---

## Welcome & Instructions

### How to Use This Workbook

This workbook is designed to accompany the FastAPI Masterclass slide presentation and video series. It contains:

1. **Lesson Summaries** - Key concepts from each module
2. **Code Exercises** - Hands-on activities with increasing complexity
3. **Challenge Problems** - Independent projects to test your skills
4. **Reference Sheets** - Quick guides for common tasks
5. **Self-Assessment Questions** - Check your understanding

### Getting Started Checklist

- [ ] Python 3.10+ installed
- [ ] VS Code (or your preferred IDE) set up
- [ ] Git installed
- [ ] PostgreSQL installed (or Docker)
- [ ] Postman or Insomnia installed
- [ ] Virtual environment created (`python -m venv venv`)
- [ ] FastAPI installed (`pip install fastapi uvicorn`)

---

## Module 1: FastAPI Foundations

### Lesson 1.1: Introduction to FastAPI

**Key Concepts:**
- **API (Application Programming Interface):** A set of rules that allows different software applications to communicate with each other.
- **REST (Representational State Transfer):** An architectural style for designing APIs.
- **ASGI vs WSGI:** ASGI supports asynchronous programming, WSGI is synchronous.
- **OpenAPI:** The specification that powers FastAPI's automatic documentation.

**Core Code:**
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

**Exercise 1.1: Your First API**
1. Create a new Python file called `main.py`
2. Write a FastAPI app with the following endpoints:
   - `GET /` returning a welcome message
   - `GET /health` returning `{"status": "ok"}`
   - `GET /greet/{name}` returning `{"message": f"Hello {name}"}`
3. Run with `uvicorn main:app --reload`
4. Test in the browser at `http://localhost:8000/docs`

**Check Your Understanding:**
1. What is the difference between ASGI and WSGI?
2. Why does FastAPI automatically generate documentation?
3. What HTTP method should you use to retrieve data?

---

### Lesson 1.2: Pydantic Models & Validation

**Key Concepts:**
- **Pydantic:** A data validation library that uses Python type hints.
- **Model:** A class that inherits from `pydantic.BaseModel`.
- **Field Validation:** Using `Field()` to add constraints.
- **Custom Validators:** Using `@field_validator` and `@model_validator`.

**Core Code:**
```python
from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50, pattern=r'^[a-zA-Z0-9_]+$')
    email: str = Field(..., pattern=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    password: str = Field(..., min_length=8)
    confirm_password: str
    age: Optional[int] = Field(None, ge=0, le=150)
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain an uppercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain a number')
        return v
    
    @model_validator(mode='after')
    def validate_passwords_match(self) -> 'UserCreate':
        if self.password != self.confirm_password:
            raise ValueError('Passwords do not match')
        return self

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    created_at: datetime
```

**Exercise 1.2: User Registration**
1. Create a Pydantic model for `ProductCreate` with:
   - `name` (min 1, max 100)
   - `price` (greater than 0)
   - `category` (optional)
   - `in_stock` (boolean, default True)
2. Add a validator that checks if `price` is reasonable (< 10000)
3. Create an endpoint `POST /products/` that accepts this model
4. Return a `ProductResponse` model that includes an `id` and `created_at`

**Check Your Understanding:**
1. What is the difference between `@field_validator` and `@model_validator`?
2. Why should you use `Optional` for fields that might not be provided?
3. How does Pydantic handle automatic type conversion?

---

## Module 2: Database Integration

### Lesson 2.1: SQLAlchemy Setup

**Key Concepts:**
- **ORM (Object-Relational Mapping):** Maps Python classes to database tables.
- **Declarative Base:** The foundation for defining models.
- **Engine:** The connection to the database.
- **Session:** The unit of work for database operations.

**Core Code:**
```python
# app/core/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base

DATABASE_URL = "postgresql+asyncpg://user:pass@localhost:5432/db"

engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

Base = declarative_base()

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

# app/models/user.py
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())
```

**Exercise 2.1: Database Setup**
1. Install PostgreSQL locally or use Docker
2. Create a database named `fastapi_db`
3. Update the `DATABASE_URL` in your configuration
4. Create a `User` model with fields: `id`, `email`, `username`, `hashed_password`
5. Create the table using `Base.metadata.create_all()`

**Check Your Understanding:**
1. What is the purpose of the `engine`?
2. Why is `AsyncSessionLocal` important for FastAPI?
3. How does SQLAlchemy handle table creation?

---

### Lesson 2.2: CRUD Operations & Repositories

**Key Concepts:**
- **Repository Pattern:** Abstracts database operations.
- **CRUD:** Create, Read, Update, Delete operations.
- **Service Layer:** Business logic that orchestrates repositories.
- **Dependency Injection:** Injecting the database session into endpoints.

**Core Code:**
```python
# app/crud/base.py
from typing import TypeVar, Generic, Type, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

ModelType = TypeVar("ModelType")

class BaseRepository(Generic[ModelType]):
    def __init__(self, model: Type[ModelType], session: AsyncSession):
        self.model = model
        self.session = session
    
    async def create(self, **kwargs) -> ModelType:
        obj = self.model(**kwargs)
        self.session.add(obj)
        await self.session.flush()
        return obj
    
    async def get(self, id: int) -> Optional[ModelType]:
        result = await self.session.execute(select(self.model).where(self.model.id == id))
        return result.scalar_one_or_none()

# app/crud/user.py
class UserRepository(BaseRepository[User]):
    def __init__(self, session: AsyncSession):
        super().__init__(User, session)
    
    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.session.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()
```

**Exercise 2.2: User CRUD**
1. Create a `UserRepository` class with methods:
   - `create_user(username, email, password)`
   - `get_user_by_id(user_id)`
   - `get_user_by_email(email)`
   - `update_user(user_id, **kwargs)`
   - `delete_user(user_id)`
2. Create a `UserService` class that uses the repository
3. Write endpoints for:
   - `POST /users/` - Register a new user
   - `GET /users/{user_id}` - Get a user by ID
   - `PUT /users/{user_id}` - Update a user
   - `DELETE /users/{user_id}` - Delete a user

**Check Your Understanding:**
1. What is the benefit of the Repository pattern?
2. Why separate the Service layer from the Repository?
3. How does dependency injection help with testing?

---

## Module 3: Authentication & Security

### Lesson 3.1: JWT Authentication

**Key Concepts:**
- **OAuth2 Password Flow:** Username/password exchange for tokens.
- **JWT (JSON Web Token):** A self-contained token with expiration.
- **Refresh Tokens:** Long-lived tokens to obtain new access tokens.
- **Password Hashing:** Using bcrypt to securely store passwords.

**Core Code:**
```python
# app/core/security.py
from passlib.context import CryptContext
from jose import jwt, JWTError
from datetime import datetime, timedelta, timezone

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# app/api/endpoints/auth.py
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    access_token = create_access_token(data={"sub": user.id})
    return {"access_token": access_token, "token_type": "bearer"}

async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401)
    except JWTError:
        raise HTTPException(status_code=401)
    user = await get_user_by_id(user_id)
    if user is None:
        raise HTTPException(status_code=401)
    return user
```

**Exercise 3.1: Auth Implementation**
1. Set up password hashing with bcrypt
2. Create a `login` endpoint that accepts username/password
3. Return a JWT access token and refresh token
4. Create a `get_current_user` dependency
5. Protect a test endpoint with `Depends(get_current_user)`
6. Implement token refresh functionality

**Check Your Understanding:**
1. What are the three parts of a JWT token?
2. Why should you use refresh tokens instead of just long-lived access tokens?
3. How does bcrypt protect passwords?

---

### Lesson 3.2: Role-Based Access Control (RBAC)

**Key Concepts:**
- **Roles:** Predefined sets of permissions (Admin, Manager, Viewer).
- **Permissions:** Specific actions (Create, Read, Update, Delete).
- **Authorization:** Checking if a user can perform an action.
- **Permission Checker:** A reusable dependency for controlling access.

**Core Code:**
```python
# app/core/authorization.py
from enum import Enum

class UserRole(str, Enum):
    ADMIN = "admin"
    MANAGER = "manager"
    DEVELOPER = "developer"
    VIEWER = "viewer"

class PermissionChecker:
    def __init__(self, allowed_roles: list, allow_superuser: bool = True):
        self.allowed_roles = allowed_roles
        self.allow_superuser = allow_superuser
    
    async def __call__(self, current_user: User = Depends(get_current_user)):
        if self.allow_superuser and current_user.is_superuser:
            return current_user
        
        if current_user.role not in self.allowed_roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        
        return current_user

# Usage in endpoints
@router.post("/tasks/", dependencies=[Depends(PermissionChecker([UserRole.ADMIN, UserRole.MANAGER]))])
async def create_task(...):
    pass
```

**Exercise 3.2: Role-Based Access**
1. Define roles: `Admin`, `Manager`, `Developer`, `Viewer`
2. Add `role` and `is_superuser` fields to your User model
3. Create a permission checker that validates roles
4. Secure these endpoints:
   - `GET /users/` - Only Admin
   - `DELETE /tasks/{task_id}` - Admin and Manager
   - `POST /tasks/` - All authenticated users

**Check Your Understanding:**
1. What is the difference between authentication and authorization?
2. Why is RBAC important for enterprise applications?
3. How can you extend RBAC to support specific permissions?

---

## Module 4: Advanced Features

### Lesson 4.1: Async Programming & Background Tasks

**Key Concepts:**
- **Event Loop:** The core of async programming.
- **Async/Await:** Writing non-blocking code.
- **BackgroundTasks:** FastAPI's built-in feature for tasks after response.
- **Celery:** Distributed task queue for heavy operations.

**Core Code:**
```python
# Async background task
from fastapi import BackgroundTasks

async def send_email(email: str, subject: str, body: str):
    # Simulate slow email sending
    await asyncio.sleep(2)
    print(f"Email sent to {email}")

@router.post("/register/")
async def register_user(data: UserCreate, background_tasks: BackgroundTasks):
    user = await create_user(data)
    background_tasks.add_task(send_email, user.email, "Welcome!", "Thank you...")
    return {"message": "User created", "user": user}

# Celery task
from celery import Celery

celery_app = Celery("tasks", broker="redis://localhost:6379/0")

@celery_app.task
def process_image(image_path: str):
    # Heavy processing
    pass

@router.post("/upload/")
async def upload_image(file: UploadFile):
    file_path = await save_file(file)
    process_image.delay(file_path)
    return {"message": "File uploaded, processing started"}
```

**Exercise 4.1: Async & Background Tasks**
1. Create a slow calculation function (simulate CPU work)
2. Use `BackgroundTasks` to run it after the response
3. Set up Redis and Celery
4. Move the calculation to a Celery task
5. Create a endpoint to check task status

**Check Your Understanding:**
1. When should you use BackgroundTasks vs Celery?
2. What is the difference between async I/O and CPU-bound tasks?
3. How does the event loop handle concurrent requests?

---

### Lesson 4.2: WebSockets & Real-Time Communication

**Key Concepts:**
- **WebSocket:** Full-duplex communication channel.
- **ConnectionManager:** Manages active WebSocket connections.
- **Broadcasting:** Sending messages to multiple clients.
- **Real-Time Features:** Notifications, chat, live updates.

**Core Code:**
```python
# app/websocket/manager.py
from typing import Dict, Set

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, Set[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)
    
    def disconnect(self, websocket: WebSocket, user_id: int):
        self.active_connections[user_id].discard(websocket)
    
    async def send_personal_message(self, message: str, user_id: int):
        if user_id in self.active_connections:
            for websocket in self.active_connections[user_id]:
                await websocket.send_text(message)

manager = ConnectionManager()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            await websocket.send_text(f"Message received: {data}")
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
```

**Exercise 4.2: Real-Time Notifications**
1. Set up the WebSocket connection manager
2. Create a WebSocket endpoint for user connections
3. Broadcast notifications when a task is assigned
4. Build a simple message sending/receiving system
5. Test with a WebSocket client (wscat or browser)

**Check Your Understanding:**
1. How do WebSockets differ from HTTP requests?
2. What is the purpose of the ConnectionManager?
3. How would you handle authentication for WebSockets?

---

### Lesson 4.3: Caching & Performance Optimization

**Key Concepts:**
- **Redis:** In-memory data store for caching.
- **Cache Strategies:** TTL, LRU, Write-Through.
- **Cache Invalidation:** Removing stale data.
- **Multi-Level Cache:** Memory + Redis.

**Core Code:**
```python
# app/core/cache.py
import redis.asyncio as redis
from functools import wraps
import hashlib

class RedisCache:
    def __init__(self, redis_url: str):
        self.client = redis.from_url(redis_url)
    
    async def get(self, key: str):
        return await self.client.get(key)
    
    async def set(self, key: str, value: str, ttl: int = 300):
        await self.client.setex(key, ttl, value)

def cached(ttl: int = 300, prefix: str = ""):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            cache = get_cache_service()
            key = f"{prefix}:{func.__name__}:{hashlib.md5(str(args).encode()).hexdigest()}"
            
            cached_value = await cache.get(key)
            if cached_value:
                return json.loads(cached_value)
            
            result = await func(*args, **kwargs)
            await cache.set(key, json.dumps(result), ttl)
            return result
        return wrapper
    return decorator

# Usage
@cached(ttl=300, prefix="user")
async def get_user_profile(user_id: int):
    return await db.fetch_user_profile(user_id)
```

**Exercise 4.3: Implementing Caching**
1. Set up Redis
2. Create a RedisCache class
3. Implement a cached decorator
4. Apply caching to a slow endpoint
5. Measure performance improvement
6. Implement cache invalidation

**Check Your Understanding:**
1. What is cache invalidation and why is it important?
2. What are the trade-offs of caching?
3. How would you implement distributed caching?

---

## Module 5: Testing & Deployment

### Lesson 5.1: Testing

**Key Concepts:**
- **Unit Tests:** Testing individual components in isolation.
- **Integration Tests:** Testing interactions between components.
- **End-to-End Tests:** Testing the entire system.
- **Fixtures:** Reusable test setups.
- **Mocks:** Simulating external dependencies.

**Core Code:**
```python
# tests/conftest.py
import pytest
from httpx import AsyncClient
from app.main import app
from app.core.database import get_db

@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client

@pytest.fixture
async def db_session():
    # Create test database session
    pass

# tests/test_users.py
import pytest

@pytest.mark.asyncio
async def test_create_user(client):
    response = await client.post(
        "/api/v1/users/",
        json={
            "username": "testuser",
            "email": "test@example.com",
            "password": "SecurePass123!"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["username"] == "testuser"
```

**Exercise 5.1: Writing Tests**
1. Write unit tests for the UserService
2. Write integration tests for the User endpoints
3. Use fixtures for database setup
4. Mock external services
5. Run tests and check coverage

**Check Your Understanding:**
1. What is the testing pyramid?
2. Why is it important to mock external services?
3. How do you test async functions with pytest?

---

### Lesson 5.2: Docker & Deployment

**Key Concepts:**
- **Containerization:** Packaging code and dependencies.
- **Dockerfile:** Instructions for building a container image.
- **Multi-Stage Builds:** Separating build and runtime.
- **Docker Compose:** Running multiple containers.
- **CI/CD:** Automating testing and deployment.

**Core Code:**
```dockerfile
# Dockerfile
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/app
    depends_on:
      - db
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=app
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Exercise 5.2: Dockerization**
1. Create a Dockerfile for your FastAPI app
2. Create a docker-compose.yml file
3. Add PostgreSQL and Redis services
4. Build and run with Docker Compose
5. Verify the application works in containers

**Check Your Understanding:**
1. What are the benefits of containerization?
2. Why use multi-stage builds?
3. How does Docker Compose simplify development?

---

## Module 6: Enterprise Architecture

### Lesson 6.1: Clean Architecture

**Key Concepts:**
- **Entities:** Core business logic (domain models).
- **Use Cases:** Application-specific business rules.
- **Interfaces:** Contracts between layers.
- **Infrastructure:** External concerns (database, API, etc.).
- **Dependency Rule:** Dependencies point inward.

**Architecture Layers:**
```
┌─────────────────────────────────────┐
│  Interface Layer (FastAPI Routes)    │
├─────────────────────────────────────┤
│  Application Layer (Use Cases)       │
├─────────────────────────────────────┤
│  Domain Layer (Entities)             │
├─────────────────────────────────────┤
│  Infrastructure Layer (Repositories) │
└─────────────────────────────────────┘
```

**Core Code:**
```python
# app/domain/entities/task.py
from dataclasses import dataclass
from datetime import datetime

@dataclass
class Task:
    id: str
    title: str
    description: str = None
    status: str = "todo"
    created_at: datetime = datetime.utcnow()
    
    def complete(self):
        if self.status == "done":
            raise ValueError("Task already completed")
        self.status = "done"

# app/application/use_cases/task_use_cases.py
class CreateTaskUseCase:
    def __init__(self, task_repo: TaskRepository):
        self.task_repo = task_repo
    
    async def execute(self, dto: CreateTaskDTO) -> Task:
        task = Task.create_new(title=dto.title, description=dto.description)
        await self.task_repo.save(task)
        return task

# app/infrastructure/repositories/task_repository.py
class PostgreSQLTaskRepository(TaskRepository):
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def save(self, task: Task):
        db_task = TaskModel.from_domain(task)
        self.session.add(db_task)
        await self.session.flush()
```

**Exercise 6.1: Clean Architecture Implementation**
1. Create domain entities for your application
2. Create use cases for CRUD operations
3. Implement repositories as interfaces
4. Implement infrastructure repositories
5. Wire everything together with dependency injection

**Check Your Understanding:**
1. Why separate Domain from Infrastructure?
2. How do use cases orchestrate operations?
3. What is the Dependency Rule?

---

### Lesson 6.2: Event-Driven Architecture

**Key Concepts:**
- **Events:** Something that happened (e.g., "TaskCompleted").
- **Event Handlers:** Code that reacts to events.
- **Message Broker:** Middleware for event distribution.
- **Loose Coupling:** Components don't know about each other.

**Core Code:**
```python
# app/domain/events/task_events.py
@dataclass
class TaskCompleted:
    task_id: str
    completed_at: datetime
    event_type: str = "task.completed"

# app/application/handlers/notification_handler.py
class NotificationHandler:
    async def handle_task_completed(self, event: TaskCompleted):
        task = await self.task_repo.get(event.task_id)
        await self.notification_service.send_notification(
            user_id=task.assignee_id,
            message=f"Task completed: {task.title}"
        )

# app/infrastructure/message_bus/rabbitmq.py
class RabbitMQMessageBus:
    async def publish(self, event: DomainEvent):
        await self.channel.basic_publish(
            exchange="events",
            routing_key=event.event_type,
            body=json.dumps(event.dict()).encode()
        )
    
    async def subscribe(self, event_type: str, handler: Callable):
        queue = await self.channel.declare_queue(f"handler_{event_type}")
        await queue.consume(lambda msg: self._handle(msg, handler))
```

**Exercise 6.2: Event-Driven Implementation**
1. Create a domain event for task completion
2. Implement a handler that sends notifications
3. Set up a message bus (RabbitMQ)
4. Publish events when tasks are updated
5. Handle events in separate services

**Check Your Understanding:**
1. How does event-driven architecture improve scalability?
2. What is the role of a message broker?
3. How do you handle event ordering?

---

## Capstone Projects

### Project 1: E-Commerce Backend API

**Requirements:**
- User registration and authentication
- Product catalog with categories
- Shopping cart functionality
- Order management
- Payment processing (simulated)
- Admin dashboard

**Key Features:**
```
- Models: User, Product, Category, Cart, Order
- Endpoints: Product browsing, Cart operations, Checkout
- Security: JWT authentication, Admin only endpoints
- Advanced: Caching, Task queues for order processing
```

**Implementation Steps:**
1. Set up database models
2. Implement CRUD for products
3. Add cart functionality
4. Implement order processing
5. Add admin endpoints
6. Test the API

### Project 2: Task Management System (Complete)

**Requirements:**
- User authentication with roles
- Task CRUD with filtering and pagination
- Task assignment
- Comments and activity tracking
- Real-time notifications
- Analytics dashboard

**Key Features:**
```
- Models: User, Task, Project, Comment
- Endpoints: Task management, Comment system, Analytics
- Security: Role-based access control
- Advanced: WebSocket notifications, Celery for email
```

**Implementation Steps:**
1. Build on the existing task system
2. Add projects and comments
3. Implement real-time notifications
4. Add analytics endpoints
5. Set up Celery for background tasks
6. Create admin dashboard

### Project 3: Real-Time Chat Application

**Requirements:**
- User authentication
- Room creation and management
- Real-time messaging with WebSockets
- Message history
- Typing indicators
- Online/offline status

**Key Features:**
```
- Models: User, Room, Message
- Endpoints: Room management, Message history
- Advanced: WebSocket connection management
- Security: JWT authentication for WebSockets
```

**Implementation Steps:**
1. Set up database models
2. Implement room CRUD
3. Add WebSocket endpoints
4. Implement message sending and receiving
5. Add typing indicators
6. Add message history

---

## Appendix A: Reference Sheets

### Common FastAPI Patterns

**Creating an Endpoint:**
```python
@router.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int, db: Session = Depends(get_db)):
    item = await crud.get_item(db, item_id)
    if not item:
        raise HTTPException(404, "Item not found")
    return item
```

**Dependency Injection:**
```python
async def get_current_user(token: str = Depends(oauth2_scheme)):
    # ... validation ...
    return user

@router.get("/profile")
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user
```

**Error Handling:**
```python
class AppException(Exception):
    def __init__(self, status_code: int, detail: str, code: str = None):
        self.status_code = status_code
        self.detail = detail
        self.code = code

@router.get("/items/{item_id}")
async def get_item(item_id: int):
    if item_id < 0:
        raise AppException(400, "Invalid ID", "INVALID_ID")
```

### SQLAlchemy Reference

**Model Definition:**
```python
class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True)
    created_at = Column(DateTime, server_default=func.now())
    
    tasks = relationship("Task", back_populates="user")
```

**Common Queries:**
```python
# Get all
users = session.query(User).all()

# Filter
active_users = session.query(User).filter(User.is_active == True).all()

# Join
tasks = session.query(Task).join(User).filter(User.username == "john").all()

# Aggregation
count = session.query(func.count(User.id)).scalar()

# Eager Loading
users = session.query(User).options(selectinload(User.tasks)).all()
```

### Pydantic Reference

**Model Definition:**
```python
class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=8)
```

**Custom Validators:**
```python
@field_validator('username')
@classmethod
def validate_username(cls, v: str) -> str:
    if not re.match(r'^[a-zA-Z0-9_]+$', v):
        raise ValueError('Invalid username')
    return v.lower()

@model_validator(mode='after')
def validate_model(self) -> 'UserCreate':
    if self.password != self.confirm_password:
        raise ValueError('Passwords do not match')
    return self
```

### Testing Reference

**Basic Test Setup:**
```python
@pytest.mark.asyncio
async def test_create_user(client):
    response = await client.post("/users/", json={...})
    assert response.status_code == 201
    assert response.json()["username"] == "testuser"
```

**Testing Authentication:**
```python
async def test_protected_endpoint(client, auth_headers):
    response = await client.get("/protected/", headers=auth_headers)
    assert response.status_code == 200
```

---

## Appendix B: Troubleshooting Guide

### Common Issues & Solutions

**1. "ModuleNotFoundError: No module named 'app'"**
- Solution: Run `python -m app.main` or set `PYTHONPATH=.`
- Check if you're in the correct directory

**2. Database Connection Errors**
- Verify PostgreSQL is running: `brew services list` or `systemctl status postgresql`
- Check `DATABASE_URL` format
- Ensure database exists: `createdb fastapi_db`

**3. JWT Authentication Failures**
- Check `SECRET_KEY` length (must be at least 32 chars)
- Verify token expiration hasn't passed
- Check token format in Authorization header: `Bearer <token>`

**4. "Working outside of application context"**
- Solution: Make sure app is initialized before using dependencies
- Check that `app.include_router()` is called

**5. Async/Sync Mixing**
- Ensure all database operations are async: `await session.execute()`
- Use `asyncio.to_thread()` for blocking operations
- Avoid `time.sleep()` in async endpoints (use `asyncio.sleep()`)

**6. Docker Issues**
- Volume permission issues: `sudo chown -R $USER:$USER ./`
- Port conflicts: `lsof -i :8000` to find processes
- Cache issues: `docker-compose down -v && docker-compose up`

**7. Installation Issues**
- Use virtual environment: `python -m venv venv`
- Upgrade pip: `pip install --upgrade pip`
- Use requirements file: `pip install -r requirements.txt`

### Quick Fix Commands

```bash
# Reset database
alembic downgrade base && alembic upgrade head

# Clear cache
redis-cli flushall

# Run all tests
pytest -v --cov=app --cov-report=html

# Rebuild Docker
docker-compose down -v && docker-compose up --build

# Check logs
docker-compose logs -f app
```

---

## Self-Assessment Quiz

### Module 1: Foundations

1. What is the main difference between ASGI and WSGI?
   a) ASGI is newer
   b) ASGI supports asynchronous programming
   c) WSGI is faster
   d) WSGI only works with Django

2. What Pydantic feature automatically generates OpenAPI documentation?
   a) Field validators
   b) Model configuration
   c) Type hints and Field definitions
   d) None of the above

3. What is the correct way to define a required Pydantic field?
   a) `name: str = None`
   b) `name: str = Field(default=None)`
   c) `name: str = Field(...)`
   d) `name: str = Field(default="")`

### Module 2: Database

4. What is the Repository pattern used for?
   a) Storing images
   b) Abstracting database operations
   c) Creating database tables
   d) Managing user sessions

5. SQLAlchemy 2.0 uses which import for typed columns?
   a) `Column`
   b) `mapped_column`
   c) `sqlalchemy.Column`
   d) `db.Column`

6. What is the N+1 query problem?
   a) Running N+1 queries instead of 1
   b) Using too many joins
   c) Not using indexes
   d) Slow database connections

### Module 3: Security

7. What does JWT stand for?
   a) Java Web Token
   b) JSON Web Token
   c) JavaScript Web Token
   d) Joint Web Token

8. What is the purpose of refresh tokens?
   a) To improve security
   b) To get new access tokens without re-authenticating
   c) To refresh the user interface
   d) To clear cookies

9. Which of these is NOT a valid password hashing algorithm?
   a) bcrypt
   b) MD5
   c) Argon2
   d) PBKDF2

### Module 4: Advanced

10. When should you use Celery instead of BackgroundTasks?
    a) For simple operations
    b) For distributed and persistent tasks
    c) For WebSocket messages
    d) For error handling

11. What is the main advantage of WebSockets?
    a) They are faster than HTTP
    b) They allow bidirectional communication
    c) They work without authentication
    d) They don't need a server

12. Which Redis command sets a key with expiration?
    a) `SET`
    b) `SETEX`
    c) `GETSET`
    d) `SETNX`

### Module 5: Testing & Deployment

13. What is the testing pyramid?
    a) A testing framework
    b) A distribution of test types
    c) A debugging tool
    d) A deployment strategy

14. What is the purpose of multi-stage builds in Docker?
    a) Faster builds
    b) Smaller images
    c) Both a and b
    d) Neither a nor b

15. What is a fixture in pytest?
    a) A test function
    b) Reusable test setup
    c) A mock object
    d) A test runner

### Module 6: Architecture

16. What is the dependency rule in Clean Architecture?
    a) Dependencies point outward
    b) Dependencies point inward
    c) Dependencies are circular
    d) Dependencies are not allowed

17. What is an event handler?
    a) A function that emits events
    b) A function that processes events
    c) A message broker
    d) A database trigger

18. What is the main benefit of event-driven architecture?
    a) Faster response times
    b) Loose coupling between components
    c) Easier debugging
    d) Fewer dependencies

### Answer Key

1. b
2. c
3. c
4. b
5. b
6. a
7. b
8. b
9. b
10. b
11. b
12. b
13. b
14. c
15. b
16. b
17. b
18. b

---

## Final Project: Complete Task Management System

**Goal:** Build a fully functional task management API using everything you've learned.

**Requirements:**

1. **Users**
   - Registration and login
   - JWT authentication
   - Role-based access control (Admin, Manager, Developer, Viewer)

2. **Projects**
   - CRUD operations
   - Project members
   - Project status (Active, Paused, Completed)

3. **Tasks**
   - CRUD operations
   - Status workflow (Todo → In Progress → Review → Done)
   - Priority levels
   - Assignment to users
   - Due dates

4. **Comments**
   - Add comments to tasks
   - Edit and delete comments

5. **Notifications**
   - Email notifications for task assignments
   - WebSocket notifications for real-time updates

6. **Search & Filtering**
   - Filter tasks by status, priority, assignee
   - Full-text search

7. **API Documentation**
   - Complete OpenAPI documentation

8. **Testing**
   - Unit tests (80%+ coverage)
   - Integration tests

9. **Deployment**
   - Docker containerization
   - docker-compose for development
   - CI/CD pipeline (GitHub Actions)

**Deliverables:**
- Complete source code
- API documentation (OpenAPI)
- Test coverage report
- Deployment instructions

**Grading Criteria:**
- Code quality and organization (25%)
- Feature completeness (25%)
- Test coverage and quality (25%)
- Security and performance (25%)

---

**Congratulations!** You've completed the FastAPI Masterclass workbook. You now have the skills to build production-ready APIs. Keep learning, keep building, and share your knowledge with the community.
