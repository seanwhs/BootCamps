# FastAPI Masterclass: Trainer Guide

**Comprehensive Instructor Resource for Teaching Production-Ready APIs**

---

## How to Use This Trainer Guide

This guide is designed to help you deliver the FastAPI Masterclass effectively. It contains:

1. **Course Overview** - Complete course structure and objectives
2. **Lesson Plans** - Detailed session breakdowns with timing
3. **Teaching Strategies** - Best practices for different learning styles
4. **Slide Notes** - Key points for each slide
5. **Code Walkthroughs** - Detailed explanations of code examples
6. **Common Pitfalls** - Student issues and how to address them
7. **Demo Scripts** - Live coding demonstrations
8. **Assessment Guide** - Grading criteria and evaluation rubrics
9. **Troubleshooting Guide** - Technical issues and solutions
10. **Resources** - Additional teaching materials

---

## Part 1: Course Overview

### Course Description

This comprehensive masterclass takes students from the fundamentals of API development to designing and deploying secure, scalable, and enterprise-grade backend services using FastAPI.

### Target Audience

**Prerequisites:**
- Intermediate Python programming (2+ years professional experience)
- Basic understanding of HTTP and REST APIs
- Familiarity with SQL databases
- Basic command-line experience
- Understanding of object-oriented programming

**Student Profile:**
- Python developers transitioning to web development
- Backend developers learning modern Python frameworks
- Full-stack developers wanting to improve backend skills
- Technical leads and architects designing systems

### Course Objectives

Upon completion, students will be able to:

1. Build high-performance asynchronous APIs with FastAPI
2. Design clean, modular, and maintainable backend architectures
3. Implement secure authentication and authorization using OAuth2 and JWT
4. Integrate SQLAlchemy 2.0 with asynchronous database access
5. Apply Clean Architecture and Repository patterns
6. Build real-time applications using WebSockets
7. Write comprehensive automated tests and CI/CD pipelines
8. Containerize and deploy applications using Docker and Nginx
9. Monitor, secure, and optimize APIs for production workloads
10. Architect enterprise-grade backend systems

### Course Structure

| Module | Duration | Topics |
|--------|----------|--------|
| Part 0 | 15 min | Introduction & Setup |
| Part 1 | 90 min | Foundations & Architecture |
| Part 2 | 90 min | Database Integration |
| Part 3 | 90 min | Authentication & Security |
| Part 4 | 90 min | Advanced Features |
| Part 5 | 90 min | Testing & Deployment |
| Part 6 | 60 min | Enterprise Architecture |

### Equipment Requirements

**Trainer Setup:**
- Projector/Large screen
- Audio system
- Whiteboard or digital whiteboard
- Code editor with large font (VS Code recommended)
- Terminal with multiple tabs

**Student Setup:**
- Laptop with Python 3.10+ installed
- VS Code (or preferred IDE)
- Postman or curl
- PostgreSQL installed (or Docker)
- Redis installed (or Docker)
- Git installed

---

## Part 2: Detailed Lesson Plans

### Day 1: Foundations (Part 0-1)

#### Session 1: Introduction & Setup (15 min)

**Learning Objectives:**
- Understand the course structure
- Set up development environment
- Create first FastAPI application

**Teaching Materials:**
- Slides 1-7
- Live code demo

**Lesson Flow:**

1. **Introduction (5 min)**
   - Welcome students
   - Review prerequisites
   - Explain course objectives

2. **Environment Setup (5 min)**
   - Demonstrate virtual environment creation
   - Show FastAPI installation
   - Verify installation

3. **Hello World Demo (5 min)**
   - Live code the first FastAPI app
   - Show Swagger UI
   - Explain the magic

**Common Issues:**
- Virtual environment not activated
- Port conflict (8000 already in use)
- Python version mismatch

**Solutions:**
```bash
# Check Python version
python --version  # Should be 3.10+

# Check if port is in use
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 <PID>
```

---

#### Session 2: FastAPI Foundations (45 min)

**Learning Objectives:**
- Understand ASGI vs WSGI
- Create endpoints with path/query parameters
- Use Pydantic for validation
- Implement dependency injection

**Teaching Materials:**
- Slides 8-13
- Live code demos
- Student exercise

**Lesson Flow:**

1. **ASGI vs WSGI (5 min)**
   - Explain the difference
   - Draw diagram on whiteboard
   - Why ASGI matters for FastAPI

2. **HTTP Methods & Endpoints (10 min)**
   ```python
   @app.get("/items/{item_id}")
   async def get_item(item_id: int, q: str = None):
       return {"item_id": item_id, "q": q}
   ```
   - Path parameters
   - Query parameters
   - Request body (Pydantic)

3. **Pydantic Deep Dive (15 min)**
   ```python
   class ItemCreate(BaseModel):
       name: str = Field(..., min_length=1)
       price: float = Field(..., gt=0)
       tags: list[str] = []
   
   @app.post("/items/")
   async def create_item(item: ItemCreate):
       return item
   ```
   - Field validation
   - Custom validators
   - Nested models

4. **Dependency Injection (10 min)**
   ```python
   def common_params(q: str = None, skip: int = 0):
       return {"q": q, "skip": skip}
   
   @app.get("/items/")
   async def list_items(commons: dict = Depends(common_params)):
       return commons
   ```
   - Why use DI
   - Common dependencies
   - Testability benefits

5. **Student Exercise (5 min)**
   - Build a user registration endpoint
   - With Pydantic validation
   - Test in Swagger UI

**Key Teaching Points:**
- Emphasize the automatic documentation
- Show how FastAPI integrates with type hints
- Explain the benefits of dependency injection

---

#### Session 3: Database Integration (45 min)

**Learning Objectives:**
- Set up SQLAlchemy 2.0
- Create database models
- Implement CRUD operations
- Understand the Repository pattern

**Teaching Materials:**
- Slides 14-17
- Live code demo
- Student exercise

**Lesson Flow:**

1. **SQLAlchemy Setup (10 min)**
   ```python
   from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
   DATABASE_URL = "postgresql+asyncpg://user:pass@localhost/db"
   engine = create_async_engine(DATABASE_URL)
   AsyncSessionLocal = async_sessionmaker(engine)
   ```
   - Engine
   - Session
   - Base class

2. **Database Models (10 min)**
   ```python
   class User(Base):
       __tablename__ = "users"
       id = Column(Integer, primary_key=True)
       username = Column(String(50), unique=True)
       email = Column(String(255), unique=True)
   ```
   - Column types
   - Relationships
   - Constraints

3. **Repository Pattern (15 min)**
   ```python
   class BaseRepository:
       async def create(self, **kwargs):
           obj = self.model(**kwargs)
           self.session.add(obj)
           await self.session.flush()
           return obj
   ```
   - Why abstract database operations
   - Separation of concerns
   - Testability

4. **CRUD Operations (5 min)**
   - Create, Read, Update, Delete
   - Async operations
   - Error handling

5. **Student Exercise (5 min)**
   - Create a Task model
   - Implement TaskRepository
   - Test CRUD operations

**Common Issues:**
- Connection errors
- Missing table
- Foreign key constraints

**Solutions:**
```bash
# Check PostgreSQL is running
brew services list  # macOS
sudo systemctl status postgresql  # Linux

# Create database
createdb fastapi_db

# Run migrations
alembic upgrade head
```

---

### Day 2: Authentication & Advanced (Part 3-4)

#### Session 4: Authentication & Security (45 min)

**Learning Objectives:**
- Implement JWT authentication
- Add password hashing
- Create login/register endpoints
- Implement RBAC

**Teaching Materials:**
- Slides 18-20
- Live code demo

**Lesson Flow:**

1. **JWT Overview (10 min)**
   - What is JWT
   - Header, Payload, Signature
   - OAuth2 Password Flow
   ```python
   def create_access_token(data: dict):
       expire = datetime.utcnow() + timedelta(minutes=30)
       data.update({"exp": expire})
       return jwt.encode(data, SECRET_KEY, algorithm="HS256")
   ```

2. **Password Hashing (5 min)**
   - bcrypt
   - Passlib
   ```python
   pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
   
   def verify_password(plain: str, hashed: str) -> bool:
       return pwd_context.verify(plain, hashed)
   ```

3. **Login Endpoint (10 min)**
   ```python
   @app.post("/token")
   async def login(form_data: OAuth2PasswordRequestForm = Depends()):
       user = await authenticate_user(form_data.username, form_data.password)
       if not user:
           raise HTTPException(status_code=401)
       return {"access_token": create_access_token({"sub": user.id})}
   ```

4. **Current User Dependency (10 min)**
   ```python
   async def get_current_user(token: str = Depends(oauth2_scheme)):
       payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
       user_id = payload.get("sub")
       return await get_user(user_id)
   ```

5. **RBAC Implementation (10 min)**
   ```python
   class PermissionChecker:
       def __init__(self, allowed_roles: list):
           self.allowed_roles = allowed_roles
       
       async def __call__(self, current_user: User = Depends(get_current_user)):
           if current_user.role not in self.allowed_roles:
               raise HTTPException(status_code=403)
           return current_user
   ```

**Key Teaching Points:**
- Token expiration
- Refresh tokens
- Secure storage (HttpOnly cookies)
- Role-based access

---

#### Session 5: Advanced Features (45 min)

**Learning Objectives:**
- Implement WebSockets
- Set up Celery
- Add Redis caching
- Implement rate limiting

**Teaching Materials:**
- Slides 21-23
- Live code demo

**Lesson Flow:**

1. **WebSockets (15 min)**
   ```python
   @app.websocket("/ws/{client_id}")
   async def websocket_endpoint(websocket: WebSocket, client_id: int):
       await websocket.accept()
       while True:
           data = await websocket.receive_text()
           await websocket.send_text(f"Echo: {data}")
   ```
   - Connection manager
   - Broadcasting
   - Real-time features

2. **Background Tasks (5 min)**
   ```python
   from fastapi import BackgroundTasks
   
   @app.post("/send-email/")
   async def send_email(data: dict, background_tasks: BackgroundTasks):
       background_tasks.add_task(send_welcome_email, data["email"])
       return {"message": "Email queued"}
   ```

3. **Celery (10 min)**
   ```python
   from celery import Celery
   
   celery_app = Celery("tasks", broker="redis://localhost:6379/0")
   
   @celery_app.task
   def process_image(image_path: str):
       # Heavy processing
       return {"status": "completed"}
   ```

4. **Redis Caching (10 min)**
   ```python
   import redis.asyncio as redis
   
   async def get_cached_user(user_id: int):
       cache = redis.from_url("redis://localhost:6379/0")
       data = await cache.get(f"user:{user_id}")
       if data:
           return json.loads(data)
       user = await db.get_user(user_id)
       await cache.setex(f"user:{user_id}", 300, json.dumps(user))
       return user
   ```

5. **Rate Limiting (5 min)**
   ```python
   class RateLimitMiddleware:
       def __init__(self, requests_per_minute: int = 60):
           self.limits = defaultdict(list)
           self.requests_per_minute = requests_per_minute
       
       async def is_allowed(self, client_ip: str) -> bool:
           # Check and clean old requests
           now = time.time()
           self.limits[client_ip] = [
               t for t in self.limits[client_ip] 
               if now - t < 60
           ]
           
           if len(self.limits[client_ip]) >= self.requests_per_minute:
               return False
           
           self.limits[client_ip].append(now)
           return True
   ```

---

### Day 3: Testing & Enterprise (Part 5-6)

#### Session 6: Testing & CI/CD (45 min)

**Learning Objectives:**
- Write unit and integration tests
- Set up GitHub Actions
- Create Docker containers
- Deploy to production

**Teaching Materials:**
- Slides 24-27
- Live code demo

**Lesson Flow:**

1. **Testing with pytest (15 min)**
   ```python
   @pytest.mark.asyncio
   async def test_create_user(client):
       response = await client.post("/users/", json={...})
       assert response.status_code == 201
       assert response.json()["username"] == "testuser"
   ```
   - Unit tests
   - Integration tests
   - Fixtures and mocks
   - Coverage reporting

2. **GitHub Actions (10 min)**
   ```yaml
   name: CI/CD Pipeline
   on: [push, pull_request]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Setup Python
           uses: actions/setup-python@v4
           with:
             python-version: '3.11'
         - name: Run tests
           run: pytest --cov=app
   ```

3. **Docker Containerization (10 min)**
   ```dockerfile
   FROM python:3.11-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   COPY . .
   CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
   ```

4. **Docker Compose (5 min)**
   ```yaml
   version: '3.8'
   services:
     app:
       build: .
       ports:
         - "8000:8000"
       depends_on:
         - db
     db:
       image: postgres:15
       environment:
         - POSTGRES_PASSWORD=postgres
   ```

5. **Deployment Strategies (5 min)**
   - Blue-Green deployment
   - Canary releases
   - Rolling updates

---

#### Session 7: Enterprise Architecture (45 min)

**Learning Objectives:**
- Apply Clean Architecture
- Implement Domain-Driven Design
- Use event-driven patterns
- Deploy to Kubernetes

**Teaching Materials:**
- Slides 28-30
- Case studies

**Lesson Flow:**

1. **Clean Architecture (15 min)**
   - Entities (Domain)
   - Use Cases (Application)
   - Interface Adapters (Infrastructure)
   - Frameworks (Web, DB)
   ```python
   # Domain layer
   class Task:
       def complete(self):
           if self.status == "done":
               raise ValueError("Already completed")
           self.status = "done"
   
   # Application layer
   class CompleteTaskUseCase:
       async def execute(self, task_id: str):
           task = await self.repo.get(task_id)
           task.complete()
           await self.repo.save(task)
   ```

2. **Domain Events (10 min)**
   ```python
   class TaskCompleted:
       def __init__(self, task_id: str):
           self.task_id = task_id
           self.occurred_at = datetime.utcnow()
   
   # Event handler
   class SendNotificationHandler:
       async def handle(self, event: TaskCompleted):
           await self.notification_service.send(event.task_id)
   ```

3. **Message Brokers (10 min)**
   - RabbitMQ
   - Kafka
   - Event-driven benefits

4. **Kubernetes (10 min)**
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: fastapi-app
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: fastapi-app
     template:
       metadata:
         labels:
           app: fastapi-app
       spec:
         containers:
           - name: fastapi-app
             image: ghcr.io/username/fastapi-app:latest
             ports:
               - containerPort: 8000
   ```

---

## Part 3: Teaching Strategies

### Active Learning Techniques

1. **Live Coding Sessions**
   - Write code from scratch
   - Make intentional mistakes
   - Debug together with students
   - Show error messages and solutions

2. **Think-Pair-Share**
   - Give students a problem
   - They think individually (2 min)
   - Pair up to discuss (3 min)
   - Share solutions with class (5 min)

3. **Mini-Challenges**
   - 5-minute coding challenges
   - Immediate application of concepts
   - Quick feedback loops

4. **Code Reviews**
   - Show student code
   - Identify issues together
   - Suggest improvements
   - Discuss best practices

5. **Pair Programming**
   - Students work in pairs
   - One drives, one reviews
   - Switch roles

### Differentiated Instruction

**For Fast Learners:**
- Challenge extensions in labs
- Additional research topics
- Advanced patterns
- Performance optimization

**For Struggling Students:**
- One-on-one assistance
- Office hours
- Additional resources
- Peer mentoring

**Visual Learners:**
- Diagrams on whiteboard
- Flow charts
- Sequence diagrams
- Architecture drawings

**Auditory Learners:**
- Verbal explanations
- Group discussions
- Podcasts/audio resources
- Call-and-response

**Kinesthetic Learners:**
- Live coding
- Hands-on labs
- Typing exercises
- Interactive demos

### Effective Code Demonstrations

1. **Preparation**
   - Start with a clean slate
   - Prepare code snippets
   - Know the steps by heart
   - Have backup plans

2. **During Demo**
   - Type slowly and deliberately
   - Explain what you're doing
   - Why this approach
   - What alternatives exist

3. **Error Handling**
   - Make common mistakes
   - Show the error
   - Explain the solution
   - This builds problem-solving skills

4. **Testing**
   - Show tests running
   - Demonstrate coverage
   - Test edge cases
   - Show debugging

---

## Part 4: Slide Notes

### Detailed Slide-by-Slide Notes

#### Part 0: Introduction

**Slide 1: Title**
- "Welcome to the FastAPI Masterclass"
- Set expectations for the journey ahead

**Slide 2: What is an API?**
- Use the Restaurant Waiter analogy
- "The waiter takes your order to the kitchen"
- "The kitchen prepares it and sends it back"

**Slide 3: Why FastAPI?**
- Show performance comparison chart
- "FastAPI is faster than Node.js and Go"
- "Production-ready out of the box"

**Slide 4: Course Roadmap**
- Show the journey
- Foundation → Scaling → Production
- "We're building a Task Management System"

#### Part 1: Foundations

**Slide 5: ASGI vs WSGI**
- Draw the multi-lane highway analogy
- "WSGI is one request at a time"
- "ASGI handles many concurrently"

**Slide 6: Hello World**
```python
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}
```
- Point out the decorator
- The async function
- Automatic docs

**Slide 7: Pydantic Models**
```python
class User(BaseModel):
    name: str
    email: str
    age: int = Field(..., ge=0, le=150)
```
- "Pydantic is the data validator"
- "It catches errors before they reach your code"
- "Type hints = automatic validation"

#### Part 2: Database

**Slide 8: SQLAlchemy Architecture**
- Show the pyramid (Engine → Session → Model)
- "It translates Python to SQL"
- "Async support is native in 2.0"

**Slide 9: Repository Pattern**
- "The Catalog analogy"
- "You don't need to know how the books are organized"
- "It abstracts the database away"

#### Part 3: Authentication

**Slide 10: OAuth2 Flow**
- Diagram of client → server → token
- "Username/password exchange"
- "Get a token, use it for access"

#### Part 4: Advanced

**Slide 11: WebSockets**
- "The telephone vs letters"
- "Both sides can talk at any time"
- "Real-time communication"

#### Part 5: Testing

**Slide 12: Testing Pyramid**
- Unit tests (base)
- Integration tests (middle)
- E2E tests (top)
- "More tests at bottom, fewer at top"

---

## Part 5: Common Pitfalls & Solutions

### Student Issues and How to Address Them

#### Python Environment

| Issue | Solution |
|-------|----------|
| Module not found | Ensure virtual environment is activated |
| Wrong Python version | Use `python3.11 -m venv venv` |
| Dependency conflicts | Use `requirements.txt` with pinned versions |

#### Database

| Issue | Solution |
|-------|----------|
| Connection refused | Check PostgreSQL is running |
| Table doesn't exist | Run Alembic migrations |
| Foreign key error | Check data consistency |

#### Authentication

| Issue | Solution |
|-------|----------|
| Invalid token | Check SECRET_KEY length |
| Token expired | Implement refresh tokens |
| No user found | Check the database |

#### Async

| Issue | Solution |
|-------|----------|
| Blocking the event loop | Use `asyncio.to_thread()` for CPU work |
| Forgetting `await` | Check coroutine usage |
| Mixing sync/async | Use `async` consistently |

#### WebSockets

| Issue | Solution |
|-------|----------|
| Connection drops | Implement reconnection logic |
| Message not received | Check room membership |
| Authentication | Use token in WebSocket connection |

#### Docker

| Issue | Solution |
|-------|----------|
| Port conflicts | Check ports with `lsof` |
| Volume permissions | Use `chown` or user mapping |
| Network issues | Check network configuration |

### Teaching Script for Common Issues

**When a student gets stuck:**

1. **Identify the issue**
   - "What error message are you seeing?"
   - "What did you expect to happen?"

2. **Isolate the problem**
   - "Show me the code around line X"
   - "What values are in the variables?"

3. **Explain the solution**
   - "Here's why this is happening"
   - "This is how we fix it"

4. **Prevent recurrence**
   - "Here's how to avoid this in the future"
   - "What other patterns use this concept?"

---

## Part 6: Demo Scripts

### Demo 1: First FastAPI App

**Script:**

```python
# Create a new file: main.py

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

**Commentary:**
- "We're creating a web server in 4 lines"
- "The decorator maps URLs to functions"
- "FastAPI reads the type hints for validation"

**Run:**
```bash
uvicorn main:app --reload
```

**Show:**
- Swagger UI at `/docs`
- ReDoc at `/redoc`
- Response in browser

---

### Demo 2: Pydantic Validation

**Script:**

```python
from pydantic import BaseModel, Field, field_validator
from fastapi import FastAPI, HTTPException

app = FastAPI()

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: str = Field(..., pattern=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    password: str = Field(..., min_length=8)
    
    @field_validator('password')
    def validate_password(cls, v: str) -> str:
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain uppercase')
        return v

@app.post("/users/")
async def create_user(user: UserCreate):
    # Validate automatically
    return {"message": "User created"}
```

**Show:**
- Valid request works
- Invalid request returns 422
- Error messages in response

---

### Demo 3: JWT Authentication

**Script:**

```python
from jose import jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(data: dict):
    expire = datetime.utcnow() + timedelta(minutes=30)
    data.update({"exp": expire})
    return jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401)
    return {"access_token": create_access_token({"sub": user.id})}
```

**Show:**
- Login returns token
- Token used for Authorization header
- Protected endpoints work with token

---

## Part 7: Assessment Guide

### Grading Criteria

| Component | Weight | Description |
|-----------|--------|-------------|
| Lab Exercises | 30% | Completion of hands-on labs |
| Mid-term Exam | 20% | Knowledge check after Part 3 |
| Capstone Project | 30% | Complete Task Management System |
| Final Exam | 20% | Comprehensive assessment |

### Rubric for Capstone Project

| Criteria | Excellent (90-100%) | Good (70-89%) | Satisfactory (50-69%) | Needs Improvement (<50%) |
|----------|---------------------|---------------|-----------------------|--------------------------|
| **Functionality** | All features work perfectly | All features work | Most features work | Few features work |
| **Code Quality** | Clean, commented, organized | Mostly clean | Some organization | Disorganized |
| **Testing** | >80% coverage | >60% coverage | >40% coverage | <40% coverage |
| **Documentation** | Complete OpenAPI docs | Good docs | Basic docs | No docs |
| **Architecture** | Clean Architecture | Good separation | Some separation | No separation |

### Sample Exam Questions

**Multiple Choice:**
1. What does ASGI stand for?
   a) Asynchronous Server Gateway Interface ✓
   b) Application Server Gateway Interface
   c) Async Standard Gateway Implementation

2. What is the default port for Uvicorn?
   a) 5000
   b) 8000 ✓
   c) 8080

**Code Completion:**
```python
@app.get("/users/{user_id}")
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = await db.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

**Short Answer:**
"Explain the difference between authentication and authorization."

**Expected Answer:**
- Authentication: Verifying identity (who you are)
- Authorization: Verifying permissions (what you can do)
- Example: Login vs. Role-based access

### Sample Lab Grading

**Lab 3: Database Integration (50 points)**

| Task | Points | Criteria |
|------|--------|----------|
| Database Setup | 10 | PostgreSQL running, migrations complete |
| User Model | 10 | Correct SQLAlchemy model, relationships |
| CRUD Operations | 15 | Create, read, update, delete working |
| Repository Pattern | 10 | Proper abstraction, separation of concerns |
| Tests | 5 | Passing tests for CRUD operations |

---

## Part 8: Troubleshooting Guide

### Technical Setup Issues

**1. Virtual Environment Issues**

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate

# Check
which python  # Should point to venv
```

**2. Database Connection Issues**

```bash
# Check PostgreSQL
pg_isready
psql -l

# Reset database
dropdb fastapi_db
createdb fastapi_db
alembic upgrade head
```

**3. Redis Connection Issues**

```bash
# Check Redis
redis-cli ping

# Reset Redis
redis-cli flushall
```

**4. Celery Worker Issues**

```bash
# Start worker
celery -A app.core.celery_app worker --loglevel=info

# Check status
celery -A app.core.celery_app status

# Purge tasks
celery -A app.core.celery_app purge -f
```

**5. Docker Issues**

```bash
# Check Docker
docker ps

# Reset Docker
docker-compose down -v
docker-compose up --build

# Check logs
docker-compose logs -f app
```

### Interactive Q&A Guide

| Question | Answer |
|----------|--------|
| "Why FastAPI over Django?" | FastAPI is for APIs, Django is for full websites |
| "When should I use async?" | For I/O-bound operations (DB, network) |
| "Is SQLAlchemy necessary?" | Not required but recommended for production |
| "How do I deploy to AWS?" | Use ECS, RDS, and Elasticache |
| "What about GraphQL?" | Use Strawberry or Ariadne with FastAPI |

---

## Part 9: Resources

### Recommended Reading

**Books:**
1. "FastAPI: Modern Python Web Development" - Bill Lubanovic
2. "SQLAlchemy 2.0 in Practice" - Michael Bayer
3. "Python Async Programming" - Caleb Hattingh
4. "Clean Architecture" - Robert C. Martin

**Documentation:**
1. [FastAPI Official Docs](https://fastapi.tiangolo.com/)
2. [SQLAlchemy 2.0 Docs](https://docs.sqlalchemy.org/)
3. [Celery Documentation](https://docs.celeryq.dev/)
4. [Docker Documentation](https://docs.docker.com/)

**Online Resources:**
1. [Real Python FastAPI Tutorials](https://realpython.com/tutorials/fastapi/)
2. [TestDriven.io FastAPI](https://testdriven.io/blog/topics/fastapi/)
3. [FastAPI GitHub Repository](https://github.com/tiangolo/fastapi)

### Sample Syllabi

**Week 1: Foundations**
- Monday: Introduction and Setup
- Tuesday: FastAPI Basics
- Wednesday: Pydantic Models
- Thursday: Dependency Injection
- Friday: Lab Review

**Week 2: Database**
- Monday: SQLAlchemy 2.0
- Tuesday: Models and Relationships
- Wednesday: Repository Pattern
- Thursday: CRUD Operations
- Friday: Lab Review

**Week 3: Security**
- Monday: JWT Authentication
- Tuesday: Password Hashing
- Wednesday: RBAC
- Thursday: Security Best Practices
- Friday: Lab Review

**Week 4: Advanced**
- Monday: Async Programming
- Tuesday: WebSockets
- Wednesday: Celery
- Thursday: Caching
- Friday: Lab Review

**Week 5: Production**
- Monday: Testing
- Tuesday: CI/CD
- Wednesday: Docker
- Thursday: Deployment
- Friday: Lab Review

**Week 6: Enterprise**
- Monday: Clean Architecture
- Tuesday: Domain Events
- Wednesday: Message Brokers
- Thursday: Kubernetes
- Friday: Capstone

---

## Part 10: Trainer Tips & Best Practices

### Before the Course

1. **Prepare Your Environment**
   - Test all code examples
   - Set up demo environment
   - Prepare fallback options
   - Have backup internet connection

2. **Know Your Students**
   - Review pre-course survey
   - Identify skill levels
   - Prepare differentiator content

3. **Set Up Classroom**
   - Test projector/display
   - Check audio
   - Arrange seating for collaboration

### During the Course

1. **Pace Yourself**
   - Watch for student engagement
   - Adjust speed as needed
   - Build in breaks
   - Allow time for questions

2. **Be Engaging**
   - Use analogies and stories
   - Show real-world examples
   - Encourage participation
   - Celebrate successes

3. **Handle Questions**
   - Allow questions throughout
   - Create "parking lot" for off-topic questions
   - Answer fully but concisely
   - Use questions as teaching opportunities

### After the Course

1. **Follow Up**
   - Send resources
   - Offer office hours
   - Collect feedback
   - Encourage continued learning

2. **Self-Reflection**
   - What worked well?
   - What could be improved?
   - Update materials accordingly
   - Share lessons learned

### Trainer Pitfalls to Avoid

1. **Too Fast**
   - Students get lost
   - Retain less information
   - Become discouraged

2. **Too Slow**
   - Students get bored
   - Lose engagement
   - Feel unchallenged

3. **Too Much Theory**
   - No practical application
   - Hard to remember
   - Low engagement

4. **Too Little Theory**
   - No context
   - Hard to understand
   - "Copy-paste" programming

5. **Ignoring Questions**
   - Students feel unheard
   - Misconceptions persist
   - Disengagement

### Effectiveness Tips

1. **Use Real-World Examples**
   - "This is how Uber handles authentication"
   - "Netflix uses this pattern"
   - "Spotify uses FastAPI for their backend"

2. **Show the "Why" Before the "How"**
   - "Here's why we need this"
   - "This solves this problem"
   - "Without this, we'd have to..."

3. **Encourage Experimentation**
   - "Try breaking it"
   - "What if you change this?"
   - "How would you improve this?"

4. **Build Community**
   - Students learning together
   - Shared success
   - Peer support

---

**End of Trainer Guide**
