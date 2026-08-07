# Part 6: Building Enterprise APIs

Welcome to the final part of our FastAPI Masterclass! We've covered foundations, databases, security, advanced features, and production deployment. Now it's time to bring everything together and build truly enterprise-grade APIs. In this module, we'll apply Clean Architecture principles, implement event-driven patterns, add advanced features like file storage and search, and build complete capstone projects.

## Learning Objectives

By the end of Part 6, you will be able to:
- Apply Clean Architecture and Domain-Driven Design principles
- Implement event-driven architecture with message brokers
- Add file uploads with cloud storage (AWS S3)
- Implement full-text search with Elasticsearch
- Build multi-tenant SaaS applications
- Deploy to Kubernetes for production
- Implement feature flags and canary deployments
- Build comprehensive capstone projects

## Key Concepts Before We Begin

### What is Clean Architecture?
Clean Architecture is like building a house with a strong foundation. The core business logic (the foundation) is independent of external concerns like databases, web frameworks, or UI. This makes your code more maintainable, testable, and adaptable to change.

### What is Domain-Driven Design?
Domain-Driven Design (DDD) is about modeling your software to match the business domain. Instead of thinking in terms of database tables, you think in terms of business concepts (e.g., "Order", "Customer", "Payment") and their behaviors.

### What is Event-Driven Architecture?
Event-Driven Architecture is like a news broadcast system. When something important happens (a task is completed, a user signs up), an "event" is published. Other parts of the system that are interested in that event can react to it independently.

## Step 1: Clean Architecture Implementation

### The Target
Refactor our application to follow Clean Architecture principles with clear separation of concerns.

### The Concept
Clean Architecture organizes code into concentric circles. The innermost circle contains the domain entities and business rules. Moving outward, we have use cases (application business rules), interface adapters (controllers, presenters), and finally frameworks (databases, web frameworks).

### The Implementation

**Create the new directory structure:**

```bash
# Create Clean Architecture structure
mkdir -p app/domain/{entities,value_objects,events}
mkdir -p app/application/{use_cases,services,dtos,interfaces}
mkdir -p app/infrastructure/{persistence,repositories,external,config}
mkdir -p app/interfaces/{api,webhooks,schemas}
```

**Create `app/domain/entities/task.py`:**

```python
"""
app/domain/entities/task.py
Domain entity for Task - Core business logic.
"""

from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Optional, List, Set
from enum import Enum
import uuid

from app.domain.value_objects.task_status import TaskStatus, TaskPriority
from app.domain.value_objects.task_tags import TaskTags
from app.domain.events.task_events import TaskCreated, TaskCompleted, TaskAssigned


@dataclass
class Task:
    """
    Task domain entity - Core business logic.
    
    This is the heart of our domain model. It contains business rules
    and behaviors independent of any framework or database.
    """
    
    # Identity
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    
    # Core attributes
    title: str
    description: Optional[str] = None
    status: TaskStatus = TaskStatus.TODO
    priority: TaskPriority = TaskPriority.MEDIUM
    
    # Timestamps
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime = field(default_factory=datetime.utcnow)
    due_date: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    
    # Relationships (IDs only at domain level)
    created_by: str  # User ID
    assignee_id: Optional[str] = None
    project_id: Optional[str] = None
    parent_task_id: Optional[str] = None
    
    # Additional attributes
    tags: TaskTags = field(default_factory=TaskTags)
    estimated_hours: Optional[float] = None
    actual_hours: Optional[float] = None
    
    # Domain events
    events: List = field(default_factory=list)
    
    def __post_init__(self):
        """Validate task invariants."""
        self._validate_title()
        self._validate_hours()
    
    def _validate_title(self):
        """Ensure title is not empty."""
        if not self.title or not self.title.strip():
            raise ValueError("Task title cannot be empty")
        if len(self.title) > 200:
            raise ValueError("Task title cannot exceed 200 characters")
    
    def _validate_hours(self):
        """Ensure hours are valid."""
        if self.estimated_hours is not None and self.estimated_hours < 0:
            raise ValueError("Estimated hours cannot be negative")
        if self.actual_hours is not None and self.actual_hours < 0:
            raise ValueError("Actual hours cannot be negative")
    
    # ────────────────────────────────────────────────────────────────
    # Business Logic Methods
    # ────────────────────────────────────────────────────────────────
    
    def start_work(self):
        """
        Start work on the task.
        
        Business Rule: Can only start if in TODO status.
        """
        if self.status == TaskStatus.TODO:
            self.status = TaskStatus.IN_PROGRESS
            self.updated_at = datetime.utcnow()
        else:
            raise ValueError(
                f"Cannot start work on task in '{self.status.value}' status"
            )
    
    def complete(self):
        """
        Complete the task.
        
        Business Rule: Can only complete if not already done or archived.
        """
        if self.status in (TaskStatus.DONE, TaskStatus.ARCHIVED):
            raise ValueError(f"Task is already '{self.status.value}'")
        
        self.status = TaskStatus.DONE
        self.completed_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        
        # Add domain event
        self.events.append(TaskCompleted(
            task_id=self.id,
            completed_at=self.completed_at
        ))
    
    def archive(self):
        """Archive the task."""
        if self.status == TaskStatus.ARCHIVED:
            raise ValueError("Task is already archived")
        
        self.status = TaskStatus.ARCHIVED
        self.updated_at = datetime.utcnow()
    
    def assign_to(self, user_id: str):
        """
        Assign the task to a user.
        
        Business Rule: Can assign to any active user.
        """
        if self.assignee_id == user_id:
            return  # Already assigned
        
        old_assignee = self.assignee_id
        self.assignee_id = user_id
        self.updated_at = datetime.utcnow()
        
        # Add domain event
        self.events.append(TaskAssigned(
            task_id=self.id,
            assignee_id=user_id,
            previous_assignee=old_assignee
        ))
    
    def update_priority(self, priority: TaskPriority):
        """
        Update task priority.
        
        Business Rule: Critical priority requires justification.
        """
        # Business rule: Critical tasks need special attention
        if priority == TaskPriority.CRITICAL and self.priority != TaskPriority.CRITICAL:
            # In real application, you might log this or require approval
            pass
        
        self.priority = priority
        self.updated_at = datetime.utcnow()
    
    def add_tag(self, tag: str):
        """Add a tag to the task."""
        self.tags.add(tag)
        self.updated_at = datetime.utcnow()
    
    def remove_tag(self, tag: str):
        """Remove a tag from the task."""
        self.tags.remove(tag)
        self.updated_at = datetime.utcnow()
    
    def extend_due_date(self, new_due_date: datetime):
        """
        Extend the due date.
        
        Business Rule: New due date must be in the future.
        """
        if new_due_date <= datetime.utcnow():
            raise ValueError("Due date must be in the future")
        
        self.due_date = new_due_date
        self.updated_at = datetime.utcnow()
    
    # ────────────────────────────────────────────────────────────────
    # Query Methods (Read-Only)
    # ────────────────────────────────────────────────────────────────
    
    def is_overdue(self) -> bool:
        """Check if the task is overdue."""
        if not self.due_date:
            return False
        if self.status in (TaskStatus.DONE, TaskStatus.ARCHIVED):
            return False
        return self.due_date < datetime.utcnow()
    
    def is_in_progress(self) -> bool:
        """Check if task is in progress."""
        return self.status == TaskStatus.IN_PROGRESS
    
    def is_completed(self) -> bool:
        """Check if task is completed."""
        return self.status == TaskStatus.DONE
    
    def get_completion_percentage(self, subtasks: List['Task']) -> float:
        """
        Calculate completion percentage based on subtasks.
        
        Args:
            subtasks: List of child tasks
            
        Returns:
            float: Completion percentage (0-100)
        """
        if not subtasks:
            return 100.0 if self.is_completed() else 0.0
        
        completed = sum(1 for t in subtasks if t.is_completed())
        total = len(subtasks)
        return (completed / total * 100) if total > 0 else 0.0
    
    def get_remaining_hours(self) -> Optional[float]:
        """
        Get remaining estimated hours.
        
        Returns:
            Optional[float]: Remaining hours if estimated
        """
        if self.estimated_hours is None:
            return None
        
        if self.actual_hours is None:
            return self.estimated_hours
        
        return max(0, self.estimated_hours - self.actual_hours)
    
    # ────────────────────────────────────────────────────────────────
    # Factory Methods
    # ────────────────────────────────────────────────────────────────
    
    @classmethod
    def create_new(
        cls,
        title: str,
        created_by: str,
        description: Optional[str] = None,
        priority: TaskPriority = TaskPriority.MEDIUM,
        due_date: Optional[datetime] = None,
        project_id: Optional[str] = None,
        tags: Optional[List[str]] = None,
        estimated_hours: Optional[float] = None,
    ) -> 'Task':
        """
        Factory method to create a new task.
        
        This enforces domain rules at creation time.
        """
        task = cls(
            title=title,
            description=description,
            priority=priority,
            due_date=due_date,
            created_by=created_by,
            project_id=project_id,
            estimated_hours=estimated_hours,
        )
        
        if tags:
            for tag in tags:
                task.add_tag(tag)
        
        # Add domain event
        task.events.append(TaskCreated(
            task_id=task.id,
            created_by=created_by,
            title=title
        ))
        
        return task
```

**Create `app/domain/value_objects/task_status.py`:**

```python
"""
app/domain/value_objects/task_status.py
Value objects for task status and priority.
"""

from enum import Enum
from typing import Set


class TaskStatus(Enum):
    """Task status enumeration with business rules."""
    
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    REVIEW = "review"
    DONE = "done"
    ARCHIVED = "archived"
    
    @classmethod
    def get_workflow(cls) -> list:
        """Get the standard workflow sequence."""
        return [cls.TODO, cls.IN_PROGRESS, cls.REVIEW, cls.DONE]
    
    def can_transition_to(self, target: 'TaskStatus') -> bool:
        """
        Check if transition to target status is allowed.
        
        Business Rules:
        - Can go forward in workflow
        - Can skip steps (e.g., TODO -> DONE)
        - Cannot go backward (except DONE -> REVIEW)
        - ARCHIVED is terminal
        """
        if self == TaskStatus.ARCHIVED:
            return False  # Cannot leave archived
        
        if target == TaskStatus.ARCHIVED:
            return True  # Can always archive
        
        workflow = self.get_workflow()
        
        # Allow forward transitions
        if self in workflow and target in workflow:
            return workflow.index(target) >= workflow.index(self)
        
        # Allow DONE -> REVIEW (for rework)
        if self == TaskStatus.DONE and target == TaskStatus.REVIEW:
            return True
        
        return False


class TaskPriority(Enum):
    """Task priority with business rules."""
    
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"
    
    @classmethod
    def get_priority_order(cls) -> list:
        """Get priority order from lowest to highest."""
        return [cls.LOW, cls.MEDIUM, cls.HIGH, cls.CRITICAL]
    
    def is_higher_than(self, other: 'TaskPriority') -> bool:
        """Check if this priority is higher than another."""
        order = self.get_priority_order()
        return order.index(self) > order.index(other)
    
    @classmethod
    def get_response_time(cls, priority: 'TaskPriority') -> str:
        """
        Get expected response time based on priority.
        
        Business Rule: Critical tasks get immediate attention.
        """
        response_times = {
            cls.LOW: "48 hours",
            cls.MEDIUM: "24 hours",
            cls.HIGH: "4 hours",
            cls.CRITICAL: "1 hour",
        }
        return response_times.get(priority, "24 hours")
```

**Create `app/domain/events/task_events.py`:**

```python
"""
app/domain/events/task_events.py
Domain events for task lifecycle.
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class DomainEvent:
    """Base domain event."""
    
    event_type: str
    occurred_at: datetime = datetime.utcnow()


@dataclass
class TaskCreated(DomainEvent):
    """Event emitted when a task is created."""
    
    task_id: str
    created_by: str
    title: str
    
    def __post_init__(self):
        self.event_type = "task.created"


@dataclass
class TaskCompleted(DomainEvent):
    """Event emitted when a task is completed."""
    
    task_id: str
    completed_at: datetime
    
    def __post_init__(self):
        self.event_type = "task.completed"


@dataclass
class TaskAssigned(DomainEvent):
    """Event emitted when a task is assigned."""
    
    task_id: str
    assignee_id: str
    previous_assignee: Optional[str] = None
    
    def __post_init__(self):
        self.event_type = "task.assigned"


@dataclass
class TaskPriorityChanged(DomainEvent):
    """Event emitted when task priority changes."""
    
    task_id: str
    new_priority: str
    old_priority: str
    
    def __post_init__(self):
        self.event_type = "task.priority_changed"


@dataclass
class TaskDueDateChanged(DomainEvent):
    """Event emitted when task due date changes."""
    
    task_id: str
    new_due_date: datetime
    old_due_date: Optional[datetime] = None
    
    def __post_init__(self):
        self.event_type = "task.due_date_changed"


@dataclass
class TaskOverdue(DomainEvent):
    """Event emitted when a task becomes overdue."""
    
    task_id: str
    assignee_id: str
    due_date: datetime
    
    def __post_init__(self):
        self.event_type = "task.overdue"
```

**Create `app/application/use_cases/task_use_cases.py`:**

```python
"""
app/application/use_cases/task_use_cases.py
Application use cases for task operations.
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
import asyncio

from app.domain.entities.task import Task
from app.domain.value_objects.task_status import TaskStatus, TaskPriority
from app.application.interfaces.repositories import TaskRepository
from app.application.interfaces.message_bus import MessageBus
from app.application.interfaces.id_generator import IDGenerator
from app.application.dtos.task_dtos import CreateTaskDTO, UpdateTaskDTO, TaskDTO


class CreateTaskUseCase:
    """
    Use case for creating a new task.
    
    This orchestrates the creation process and handles all
    cross-cutting concerns (validation, events, persistence).
    """
    
    def __init__(
        self,
        task_repo: TaskRepository,
        message_bus: MessageBus,
        id_generator: IDGenerator,
    ):
        self.task_repo = task_repo
        self.message_bus = message_bus
        self.id_generator = id_generator
    
    async def execute(self, dto: CreateTaskDTO) -> TaskDTO:
        """
        Execute the use case.
        
        Args:
            dto: Create task DTO
            
        Returns:
            TaskDTO: Created task DTO
            
        Raises:
            ValueError: If validation fails
        """
        # 1. Validate input
        self._validate_input(dto)
        
        # 2. Create domain entity
        task = Task.create_new(
            title=dto.title,
            created_by=dto.created_by,
            description=dto.description,
            priority=TaskPriority(dto.priority),
            due_date=dto.due_date,
            project_id=dto.project_id,
            tags=dto.tags,
            estimated_hours=dto.estimated_hours,
        )
        
        # 3. Assign if specified
        if dto.assignee_id:
            task.assign_to(dto.assignee_id)
        
        # 4. Persist the task
        await self.task_repo.save(task)
        
        # 5. Publish domain events
        for event in task.events:
            await self.message_bus.publish(event)
        
        # 6. Return DTO
        return TaskDTO.from_domain(task)
    
    def _validate_input(self, dto: CreateTaskDTO):
        """Validate the input DTO."""
        if not dto.title or not dto.title.strip():
            raise ValueError("Task title cannot be empty")
        if len(dto.title) > 200:
            raise ValueError("Task title cannot exceed 200 characters")
        if dto.estimated_hours is not None and dto.estimated_hours < 0:
            raise ValueError("Estimated hours cannot be negative")


class UpdateTaskUseCase:
    """
    Use case for updating a task.
    """
    
    def __init__(
        self,
        task_repo: TaskRepository,
        message_bus: MessageBus,
    ):
        self.task_repo = task_repo
        self.message_bus = message_bus
    
    async def execute(self, task_id: str, dto: UpdateTaskDTO) -> TaskDTO:
        """
        Execute the use case.
        
        Args:
            task_id: Task ID
            dto: Update task DTO
            
        Returns:
            TaskDTO: Updated task DTO
            
        Raises:
            ValueError: If task not found or validation fails
        """
        # 1. Get existing task
        task = await self.task_repo.get_by_id(task_id)
        if not task:
            raise ValueError(f"Task with ID {task_id} not found")
        
        # 2. Apply updates
        if dto.title is not None:
            task.title = dto.title
        
        if dto.description is not None:
            task.description = dto.description
        
        if dto.priority is not None:
            task.update_priority(TaskPriority(dto.priority))
        
        if dto.status is not None:
            status = TaskStatus(dto.status)
            if not task.status.can_transition_to(status):
                raise ValueError(
                    f"Cannot transition from {task.status.value} to {status.value}"
                )
            task.status = status
            if status == TaskStatus.DONE:
                task.complete()
        
        if dto.due_date is not None:
            task.extend_due_date(dto.due_date)
        
        if dto.assignee_id is not None:
            task.assign_to(dto.assignee_id)
        
        if dto.tags is not None:
            # Clear existing tags and add new ones
            for tag in task.tags:
                task.remove_tag(tag)
            for tag in dto.tags:
                task.add_tag(tag)
        
        if dto.estimated_hours is not None:
            task.estimated_hours = dto.estimated_hours
        
        if dto.actual_hours is not None:
            task.actual_hours = dto.actual_hours
        
        # 3. Save changes
        await self.task_repo.save(task)
        
        # 4. Publish events
        for event in task.events:
            await self.message_bus.publish(event)
        
        return TaskDTO.from_domain(task)


class GetTaskUseCase:
    """
    Use case for getting a task.
    """
    
    def __init__(self, task_repo: TaskRepository):
        self.task_repo = task_repo
    
    async def execute(self, task_id: str) -> Optional[TaskDTO]:
        """
        Execute the use case.
        
        Args:
            task_id: Task ID
            
        Returns:
            Optional[TaskDTO]: Task DTO if found
        """
        task = await self.task_repo.get_by_id(task_id)
        return TaskDTO.from_domain(task) if task else None


class GetTasksUseCase:
    """
    Use case for getting a list of tasks.
    """
    
    def __init__(self, task_repo: TaskRepository):
        self.task_repo = task_repo
    
    async def execute(
        self,
        filters: Optional[Dict[str, Any]] = None,
        page: int = 1,
        size: int = 10,
    ) -> Dict[str, Any]:
        """
        Execute the use case.
        
        Args:
            filters: Filters to apply
            page: Page number
            size: Page size
            
        Returns:
            Dict: Task list and pagination info
        """
        offset = (page - 1) * size
        
        tasks = await self.task_repo.get_all(
            filters=filters,
            offset=offset,
            limit=size,
        )
        
        total = await self.task_repo.count(filters=filters)
        
        return {
            "items": [TaskDTO.from_domain(task) for task in tasks],
            "total": total,
            "page": page,
            "size": size,
            "pages": (total + size - 1) // size,
        }


class DeleteTaskUseCase:
    """
    Use case for deleting a task.
    """
    
    def __init__(self, task_repo: TaskRepository):
        self.task_repo = task_repo
    
    async def execute(self, task_id: str) -> bool:
        """
        Execute the use case.
        
        Args:
            task_id: Task ID
            
        Returns:
            bool: True if deleted
        """
        return await self.task_repo.delete(task_id)


class CompleteTaskUseCase:
    """
    Use case for completing a task.
    """
    
    def __init__(self, task_repo: TaskRepository, message_bus: MessageBus):
        self.task_repo = task_repo
        self.message_bus = message_bus
    
    async def execute(self, task_id: str) -> TaskDTO:
        """
        Execute the use case.
        
        Args:
            task_id: Task ID
            
        Returns:
            TaskDTO: Completed task DTO
            
        Raises:
            ValueError: If task not found or cannot be completed
        """
        # 1. Get task
        task = await self.task_repo.get_by_id(task_id)
        if not task:
            raise ValueError(f"Task with ID {task_id} not found")
        
        # 2. Complete task
        task.complete()
        
        # 3. Save
        await self.task_repo.save(task)
        
        # 4. Publish events
        for event in task.events:
            await self.message_bus.publish(event)
        
        return TaskDTO.from_domain(task)
```

## Step 2: Event-Driven Architecture with RabbitMQ

### The Target
Implement event-driven architecture using RabbitMQ for loose coupling and scalability.

### The Concept
Event-driven architecture decouples components by making them communicate through events. When something happens, an event is published. Other components that care about that event can react to it without knowing about each other.

### The Implementation

**Create `app/infrastructure/external/message_bus.py`:**

```python
"""
app/infrastructure/external/message_bus.py
Message bus implementation using RabbitMQ.
"""

import asyncio
import json
from typing import Dict, Any, Callable, List
from dataclasses import dataclass
import aio_pika
from aio_pika import Message, ExchangeType, Connection
from aio_pika.abc import AbstractIncomingMessage

from app.core.config import settings
from app.application.interfaces.message_bus import MessageBus


@dataclass
class EventHandler:
    """Wrapper for event handlers."""
    
    callback: Callable
    topics: List[str]


class RabbitMQMessageBus(MessageBus):
    """
    RabbitMQ-based message bus implementation.
    """
    
    def __init__(self):
        self._connection: Optional[Connection] = None
        self._channel = None
        self._exchange = None
        self._handlers: Dict[str, List[EventHandler]] = {}
        self._consumer_task = None
        self._is_connected = False
    
    async def connect(self):
        """Connect to RabbitMQ."""
        try:
            # Parse connection URL
            # rabbitmq://guest:guest@localhost:5672/
            connection_url = settings.RABBITMQ_URL or "amqp://guest:guest@localhost:5672/"
            
            self._connection = await aio_pika.connect_robust(
                connection_url,
                timeout=10,
                retry=True
            )
            
            # Create channel
            self._channel = await self._connection.channel()
            
            # Create exchange
            self._exchange = await self._channel.declare_exchange(
                "task_events",
                ExchangeType.TOPIC,
                durable=True,
            )
            
            self._is_connected = True
            
            # Start consumer
            self._consumer_task = asyncio.create_task(self._consume_messages())
            
            return True
            
        except Exception as e:
            raise ConnectionError(f"Failed to connect to RabbitMQ: {e}")
    
    async def publish(self, event: Any) -> None:
        """
        Publish an event to the message bus.
        
        Args:
            event: Domain event to publish
        """
        if not self._is_connected:
            await self.connect()
        
        # Determine routing key from event type
        routing_key = self._get_routing_key(event)
        
        # Serialize event
        message_data = {
            "event_type": event.__class__.__name__,
            "event_data": self._serialize_event(event),
            "timestamp": event.occurred_at.isoformat() if hasattr(event, "occurred_at") else None,
        }
        
        # Create message
        message = Message(
            body=json.dumps(message_data).encode(),
            delivery_mode=aio_pika.DeliveryMode.PERSISTENT,
            content_type="application/json",
        )
        
        # Publish to exchange
        await self._exchange.publish(message, routing_key=routing_key)
    
    async def subscribe(self, topic: str, handler: Callable) -> None:
        """
        Subscribe to events on a topic.
        
        Args:
            topic: Topic to subscribe to (e.g., "task.created")
            handler: Handler function to call
        """
        if topic not in self._handlers:
            self._handlers[topic] = []
        
        self._handlers[topic].append(EventHandler(callback=handler, topics=[topic]))
    
    async def _consume_messages(self):
        """Consume messages from the queue."""
        # Declare a queue for this consumer
        queue_name = f"service.queue.{settings.APP_ENV}"
        queue = await self._channel.declare_queue(
            queue_name,
            durable=True,
            arguments={
                "x-message-ttl": 86400000,  # 24 hours
            }
        )
        
        # Bind queue to exchange for all topics
        for topic in self._handlers.keys():
            await queue.bind(self._exchange, routing_key=topic)
        
        # Start consuming
        await queue.consume(self._handle_message)
        
        # Keep the consumer running
        await asyncio.Event().wait()
    
    async def _handle_message(self, message: AbstractIncomingMessage):
        """Handle an incoming message."""
        async with message.process():
            try:
                # Parse message
                data = json.loads(message.body.decode())
                event_type = data["event_type"]
                event_data = data["event_data"]
                
                # Find handlers for this event type
                if event_type in self._handlers:
                    for handler in self._handlers[event_type]:
                        await handler.callback(event_data)
                        
            except Exception as e:
                # Log error but don't re-raise (message is acknowledged)
                print(f"Error handling message: {e}")
    
    def _get_routing_key(self, event) -> str:
        """Get routing key for an event."""
        if hasattr(event, "event_type"):
            return event.event_type
        return event.__class__.__name__.lower().replace("_", ".")
    
    def _serialize_event(self, event) -> Dict[str, Any]:
        """Serialize an event to a dictionary."""
        if hasattr(event, "__dataclass_fields__"):
            # Dataclass serialization
            result = {}
            for field_name, field_value in event.__dict__.items():
                if hasattr(field_value, "value"):
                    # Enum serialization
                    result[field_name] = field_value.value
                elif hasattr(field_value, "isoformat"):
                    # Datetime serialization
                    result[field_name] = field_value.isoformat()
                else:
                    result[field_name] = field_value
            return result
        return {}
    
    async def close(self):
        """Close the connection."""
        self._is_connected = False
        
        if self._consumer_task:
            self._consumer_task.cancel()
        
        if self._connection:
            await self._connection.close()
```

## Step 3: File Uploads with AWS S3

### The Target
Implement file upload functionality with local storage and AWS S3 support.

### The Implementation

**Create `app/infrastructure/external/storage.py`:**

```python
"""
app/infrastructure/external/storage.py
Storage service for file uploads with S3 support.
"""

from abc import ABC, abstractmethod
from typing import Optional, BinaryIO
from pathlib import Path
import os
import shutil
import uuid
from datetime import datetime
import mimetypes

from app.core.config import settings


class StorageService(ABC):
    """Abstract storage service."""
    
    @abstractmethod
    async def upload_file(
        self,
        file_content: bytes,
        file_name: str,
        folder: str = "",
    ) -> str:
        """Upload a file and return its URL."""
        pass
    
    @abstractmethod
    async def delete_file(self, file_url: str) -> bool:
        """Delete a file by URL."""
        pass
    
    @abstractmethod
    async def get_file_url(self, file_path: str) -> str:
        """Get the URL for a file path."""
        pass


class LocalStorageService(StorageService):
    """
    Local file system storage service.
    """
    
    def __init__(self, base_path: str = "./uploads"):
        self.base_path = Path(base_path)
        self.base_path.mkdir(exist_ok=True, parents=True)
    
    async def upload_file(
        self,
        file_content: bytes,
        file_name: str,
        folder: str = "",
    ) -> str:
        """
        Upload a file to local storage.
        
        Args:
            file_content: File content as bytes
            file_name: Original file name
            folder: Subfolder to store in
            
        Returns:
            str: File URL/path
        """
        # Generate unique filename
        ext = Path(file_name).suffix
        unique_name = f"{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}{ext}"
        
        # Build path
        file_path = self.base_path / folder / unique_name
        file_path.parent.mkdir(exist_ok=True, parents=True)
        
        # Write file
        with open(file_path, "wb") as f:
            f.write(file_content)
        
        # Return relative path as URL
        return f"/uploads/{folder}/{unique_name}" if folder else f"/uploads/{unique_name}"
    
    async def delete_file(self, file_url: str) -> bool:
        """
        Delete a file from local storage.
        
        Args:
            file_url: File URL/path
            
        Returns:
            bool: True if deleted
        """
        # Extract path from URL
        if file_url.startswith("/uploads/"):
            file_path = self.base_path / file_url[9:]  # Remove /uploads/
        else:
            file_path = self.base_path / file_url
        
        if file_path.exists():
            file_path.unlink()
            return True
        return False
    
    async def get_file_url(self, file_path: str) -> str:
        """Get URL for a file path."""
        return f"/uploads/{file_path}"


class S3StorageService(StorageService):
    """
    AWS S3 storage service.
    """
    
    def __init__(
        self,
        bucket_name: str,
        region: str = "us-east-1",
        access_key: Optional[str] = None,
        secret_key: Optional[str] = None,
    ):
        self.bucket_name = bucket_name
        self.region = region
        
        # Initialize S3 client
        import boto3
        from botocore.config import Config
        
        session = boto3.Session(
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
        )
        
        self.s3_client = session.client(
            "s3",
            config=Config(
                region_name=region,
                signature_version="s3v4",
            )
        )
    
    async def upload_file(
        self,
        file_content: bytes,
        file_name: str,
        folder: str = "",
    ) -> str:
        """
        Upload a file to S3.
        
        Args:
            file_content: File content as bytes
            file_name: Original file name
            folder: Subfolder to store in
            
        Returns:
            str: S3 URL
        """
        # Generate unique filename
        ext = Path(file_name).suffix
        unique_name = f"{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}{ext}"
        
        # Build S3 key
        s3_key = f"{folder}/{unique_name}" if folder else unique_name
        
        # Detect content type
        content_type, _ = mimetypes.guess_type(file_name)
        content_type = content_type or "application/octet-stream"
        
        # Upload to S3
        self.s3_client.put_object(
            Bucket=self.bucket_name,
            Key=s3_key,
            Body=file_content,
            ContentType=content_type,
            ACL="private",
            StorageClass="STANDARD",
        )
        
        # Generate URL
        return f"https://{self.bucket_name}.s3.{self.region}.amazonaws.com/{s3_key}"
    
    async def delete_file(self, file_url: str) -> bool:
        """
        Delete a file from S3.
        
        Args:
            file_url: File URL
            
        Returns:
            bool: True if deleted
        """
        # Extract key from URL
        key = file_url.split(f"{self.bucket_name}.s3.{self.region}.amazonaws.com/")[-1]
        
        try:
            self.s3_client.delete_object(Bucket=self.bucket_name, Key=key)
            return True
        except Exception:
            return False
    
    async def get_file_url(self, file_path: str) -> str:
        """Get URL for a file path."""
        return f"https://{self.bucket_name}.s3.{self.region}.amazonaws.com/{file_path}"
    
    async def generate_presigned_url(
        self,
        file_path: str,
        expiration: int = 3600,
    ) -> str:
        """
        Generate a presigned URL for temporary access.
        
        Args:
            file_path: File path in S3
            expiration: Expiration time in seconds
            
        Returns:
            str: Presigned URL
        """
        url = self.s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": self.bucket_name, "Key": file_path},
            ExpiresIn=expiration,
        )
        return url


def get_storage_service() -> StorageService:
    """
    Get the configured storage service.
    
    Returns:
        StorageService: Storage service instance
    """
    if settings.STORAGE_TYPE == "s3":
        return S3StorageService(
            bucket_name=settings.S3_BUCKET_NAME,
            region=settings.S3_REGION,
            access_key=settings.S3_ACCESS_KEY,
            secret_key=settings.S3_SECRET_KEY,
        )
    else:
        return LocalStorageService(base_path=settings.STORAGE_PATH or "./uploads")
```

**Create `app/interfaces/api/upload.py`:**

```python
"""
app/interfaces/api/upload.py
File upload API endpoints.
"""

from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from fastapi.responses import JSONResponse
from typing import List
import aiofiles

from app.infrastructure.external.storage import get_storage_service, StorageService
from app.core.security import get_current_active_user

router = APIRouter()


@router.post("/upload")
async def upload_file(
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_active_user),
    storage: StorageService = Depends(get_storage_service),
):
    """
    Upload a single file.
    
    Args:
        file: File to upload
        current_user: Authenticated user
        storage: Storage service
        
    Returns:
        dict: Upload result with file URL
    """
    # Validate file size (10MB limit)
    content = await file.read()
    if len(content) > 10 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="File too large (max 10MB)")
    
    # Validate file type
    allowed_types = ["image/jpeg", "image/png", "image/gif", "application/pdf"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=f"File type not allowed. Allowed: {', '.join(allowed_types)}"
        )
    
    # Upload file
    folder = f"users/{current_user.id}"
    file_url = await storage.upload_file(
        file_content=content,
        file_name=file.filename,
        folder=folder,
    )
    
    return {
        "message": "File uploaded successfully",
        "file_name": file.filename,
        "file_url": file_url,
        "file_size": len(content),
        "content_type": file.content_type,
    }


@router.post("/upload/multiple")
async def upload_multiple_files(
    files: List[UploadFile] = File(...),
    current_user: dict = Depends(get_current_active_user),
    storage: StorageService = Depends(get_storage_service),
):
    """
    Upload multiple files.
    
    Args:
        files: List of files to upload
        current_user: Authenticated user
        storage: Storage service
        
    Returns:
        dict: Upload results
    """
    results = []
    folder = f"users/{current_user.id}"
    
    for file in files:
        content = await file.read()
        if len(content) > 10 * 1024 * 1024:
            results.append({
                "file_name": file.filename,
                "error": "File too large (max 10MB)",
                "status": "failed",
            })
            continue
        
        try:
            file_url = await storage.upload_file(
                file_content=content,
                file_name=file.filename,
                folder=folder,
            )
            results.append({
                "file_name": file.filename,
                "file_url": file_url,
                "status": "success",
            })
        except Exception as e:
            results.append({
                "file_name": file.filename,
                "error": str(e),
                "status": "failed",
            })
    
    return {
        "message": "Upload complete",
        "results": results,
    }


@router.delete("/upload/{file_path:path}")
async def delete_file(
    file_path: str,
    current_user: dict = Depends(get_current_active_user),
    storage: StorageService = Depends(get_storage_service),
):
    """
    Delete a file.
    
    Args:
        file_path: File path to delete
        current_user: Authenticated user
        storage: Storage service
    """
    # Security: Ensure user can only delete their own files
    if not file_path.startswith(f"users/{current_user.id}/"):
        raise HTTPException(status_code=403, detail="Cannot delete this file")
    
    deleted = await storage.delete_file(file_path)
    if not deleted:
        raise HTTPException(status_code=404, detail="File not found")
    
    return {"message": "File deleted successfully"}
```

## Step 4: Elasticsearch Integration

### The Target
Implement full-text search capabilities using Elasticsearch.

### The Implementation

**Create `app/infrastructure/external/elasticsearch.py`:**

```python
"""
app/infrastructure/external/elasticsearch.py
Elasticsearch integration for search functionality.
"""

from elasticsearch import AsyncElasticsearch, Elasticsearch
from typing import List, Dict, Any, Optional
from datetime import datetime
import json

from app.core.config import settings


class SearchService:
    """
    Elasticsearch-based search service.
    """
    
    def __init__(self):
        self.client = None
        self.index_name = f"tasks_{settings.APP_ENV}"
        self._connected = False
    
    async def connect(self):
        """Connect to Elasticsearch."""
        if self._connected:
            return
        
        try:
            self.client = AsyncElasticsearch(
                hosts=[settings.ELASTICSEARCH_URL or "http://localhost:9200"],
                verify_certs=False,
                request_timeout=30,
            )
            
            # Test connection
            await self.client.info()
            self._connected = True
            
            # Create index if it doesn't exist
            await self._create_index()
            
        except Exception as e:
            raise ConnectionError(f"Failed to connect to Elasticsearch: {e}")
    
    async def _create_index(self):
        """Create the index with mappings."""
        index_exists = await self.client.indices.exists(index=self.index_name)
        
        if not index_exists:
            mapping = {
                "mappings": {
                    "properties": {
                        "id": {"type": "keyword"},
                        "title": {
                            "type": "text",
                            "analyzer": "standard",
                            "fields": {
                                "keyword": {"type": "keyword"},
                                "suggest": {"type": "completion"},
                            }
                        },
                        "description": {
                            "type": "text",
                            "analyzer": "standard",
                        },
                        "status": {"type": "keyword"},
                        "priority": {"type": "keyword"},
                        "due_date": {"type": "date"},
                        "created_at": {"type": "date"},
                        "updated_at": {"type": "date"},
                        "completed_at": {"type": "date"},
                        "created_by": {"type": "keyword"},
                        "assignee_id": {"type": "keyword"},
                        "project_id": {"type": "keyword"},
                        "tags": {"type": "keyword"},
                        "estimated_hours": {"type": "float"},
                        "actual_hours": {"type": "float"},
                    }
                }
            }
            
            await self.client.indices.create(
                index=self.index_name,
                body=mapping,
            )
    
    async def index_task(self, task_data: Dict[str, Any]) -> None:
        """
        Index a task document.
        
        Args:
            task_data: Task data to index
        """
        if not self._connected:
            await self.connect()
        
        doc_id = task_data.get("id")
        if not doc_id:
            raise ValueError("Task ID is required")
        
        await self.client.index(
            index=self.index_name,
            id=doc_id,
            document=task_data,
            refresh=True,
        )
    
    async def update_task(self, task_id: str, task_data: Dict[str, Any]) -> None:
        """
        Update a task document.
        
        Args:
            task_id: Task ID
            task_data: Updated task data
        """
        if not self._connected:
            await self.connect()
        
        await self.client.update(
            index=self.index_name,
            id=task_id,
            doc=task_data,
            refresh=True,
        )
    
    async def delete_task(self, task_id: str) -> None:
        """
        Delete a task document.
        
        Args:
            task_id: Task ID
        """
        if not self._connected:
            await self.connect()
        
        await self.client.delete(
            index=self.index_name,
            id=task_id,
            refresh=True,
            ignore=[404],
        )
    
    async def search_tasks(
        self,
        query: str,
        filters: Optional[Dict[str, Any]] = None,
        size: int = 10,
        from_: int = 0,
        sort: Optional[List[Dict]] = None,
    ) -> Dict[str, Any]:
        """
        Search for tasks.
        
        Args:
            query: Search query
            filters: Additional filters
            size: Number of results
            from_: Starting offset
            sort: Sort order
            
        Returns:
            Dict: Search results
        """
        if not self._connected:
            await self.connect()
        
        # Build must clauses
        must_clauses = []
        
        if query:
            must_clauses.append({
                "multi_match": {
                    "query": query,
                    "fields": ["title^3", "description", "tags"],
                    "fuzziness": "AUTO",
                    "operator": "and",
                }
            })
        
        # Add filters
        filter_clauses = []
        if filters:
            for field, value in filters.items():
                if value is not None:
                    filter_clauses.append({"term": {field: value}})
        
        # Build query
        search_body = {
            "query": {
                "bool": {
                    "must": must_clauses,
                    "filter": filter_clauses,
                }
            },
            "from": from_,
            "size": size,
        }
        
        if sort:
            search_body["sort"] = sort
        
        # Execute search
        response = await self.client.search(
            index=self.index_name,
            body=search_body,
        )
        
        return {
            "total": response["hits"]["total"]["value"],
            "items": [hit["_source"] for hit in response["hits"]["hits"]],
            "size": size,
            "from": from_,
        }
    
    async def autocomplete(self, prefix: str, field: str = "title") -> List[str]:
        """
        Autocomplete suggestions.
        
        Args:
            prefix: Prefix to autocomplete
            field: Field to autocomplete on
            
        Returns:
            List[str]: Suggestions
        """
        if not self._connected:
            await self.connect()
        
        response = await self.client.search(
            index=self.index_name,
            body={
                "suggest": {
                    "task_suggest": {
                        "prefix": prefix,
                        "completion": {
                            "field": f"{field}.suggest",
                            "size": 10,
                        }
                    }
                }
            }
        )
        
        suggestions = []
        for option in response["suggest"]["task_suggest"][0]["options"]:
            suggestions.append(option["text"])
        
        return suggestions
    
    async def get_task_suggestions(self, query: str) -> List[Dict]:
        """
        Get task suggestions for autocomplete.
        
        Args:
            query: Partial task title
            
        Returns:
            List[Dict]: Suggestions with IDs and titles
        """
        if not self._connected:
            await self.connect()
        
        response = await self.client.search(
            index=self.index_name,
            body={
                "query": {
                    "prefix": {
                        "title": {
                            "value": query,
                            "boost": 2.0,
                        }
                    }
                },
                "size": 10,
                "_source": ["id", "title"],
                "sort": [{"title.keyword": "asc"}],
            }
        )
        
        return [
            {"id": hit["_id"], "title": hit["_source"]["title"]}
            for hit in response["hits"]["hits"]
        ]
    
    async def close(self):
        """Close the Elasticsearch connection."""
        if self.client:
            await self.client.close()
            self._connected = False
```

## Step 5: Kubernetes Deployment

### The Target
Deploy our application to Kubernetes for production-grade orchestration.

### The Implementation

**Create `k8s/namespace.yaml`:**

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: fastapi-app
  labels:
    app: fastapi-app
    environment: production
```

**Create `k8s/configmap.yaml`:**

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fastapi-config
  namespace: fastapi-app
data:
  APP_NAME: "FastAPI Masterclass"
  APP_ENV: "production"
  DEBUG: "false"
  LOG_LEVEL: "INFO"
  ALGORITHM: "HS256"
  ACCESS_TOKEN_EXPIRE_MINUTES: "30"
  DATABASE_POOL_SIZE: "20"
  DATABASE_MAX_OVERFLOW: "40"
  REDIS_CACHE_EXPIRE: "3600"
  RATE_LIMIT_REQUESTS: "100"
  RATE_LIMIT_PERIOD: "60"
  STORAGE_TYPE: "s3"
  S3_REGION: "us-east-1"
```

**Create `k8s/secret.yaml`:**

```yaml
# k8s/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: fastapi-secrets
  namespace: fastapi-app
type: Opaque
stringData:
  SECRET_KEY: "your-super-secret-key-change-this"
  DATABASE_URL: "postgresql+asyncpg://user:password@postgres-service:5432/fastapi_db"
  REDIS_URL: "redis://:redis-password@redis-service:6379/0"
  RABBITMQ_URL: "amqp://guest:guest@rabbitmq-service:5672/"
  S3_BUCKET_NAME: "your-bucket"
  S3_ACCESS_KEY: "your-access-key"
  S3_SECRET_KEY: "your-secret-key"
```

**Create `k8s/postgres.yaml`:**

```yaml
# k8s/postgres.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: fastapi-app
  labels:
    app: postgres
spec:
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432
  clusterIP: None  # Headless service
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: fastapi-app
spec:
  serviceName: postgres-service
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15-alpine
          env:
            - name: POSTGRES_USER
              value: "postgres"
            - name: POSTGRES_PASSWORD
              value: "postgres"
            - name: POSTGRES_DB
              value: "fastapi_db"
            - name: PGDATA
              value: "/var/lib/postgresql/data/pgdata"
          ports:
            - containerPort: 5432
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
      volumes:
        - name: postgres-data
          persistentVolumeClaim:
            claimName: postgres-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: fastapi-app
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
```

**Create `k8s/app.yaml`:**

```yaml
# k8s/app.yaml
apiVersion: v1
kind: Service
metadata:
  name: fastapi-app
  namespace: fastapi-app
  labels:
    app: fastapi-app
spec:
  type: LoadBalancer
  selector:
    app: fastapi-app
  ports:
    - port: 8000
      targetPort: 8000
      name: http
  sessionAffinity: ClientIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app
  namespace: fastapi-app
  labels:
    app: fastapi-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: fastapi-app
  template:
    metadata:
      labels:
        app: fastapi-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
        - name: fastapi-app
          image: ghcr.io/your-username/fastapi-masterclass:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
              name: http
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: DATABASE_URL
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: REDIS_URL
            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: SECRET_KEY
            - name: RABBITMQ_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: RABBITMQ_URL
            - name: S3_BUCKET_NAME
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: S3_BUCKET_NAME
            - name: S3_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: S3_ACCESS_KEY
            - name: S3_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: S3_SECRET_KEY
          envFrom:
            - configMapRef:
                name: fastapi-config
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /ready
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 2
          startupProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 10
            failureThreshold: 30
```

**Create `k8s/celery.yaml`:**

```yaml
# k8s/celery.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: celery-worker
  namespace: fastapi-app
  labels:
    app: celery-worker
spec:
  replicas: 2
  selector:
    matchLabels:
      app: celery-worker
  template:
    metadata:
      labels:
        app: celery-worker
    spec:
      containers:
        - name: celery-worker
          image: ghcr.io/your-username/fastapi-masterclass:celery
          imagePullPolicy: Always
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: DATABASE_URL
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: REDIS_URL
            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: SECRET_KEY
            - name: RABBITMQ_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: RABBITMQ_URL
          envFrom:
            - configMapRef:
                name: fastapi-config
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: celery-beat
  namespace: fastapi-app
  labels:
    app: celery-beat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: celery-beat
  template:
    metadata:
      labels:
        app: celery-beat
    spec:
      containers:
        - name: celery-beat
          image: ghcr.io/your-username/fastapi-masterclass:beat
          imagePullPolicy: Always
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: DATABASE_URL
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: REDIS_URL
            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: SECRET_KEY
            - name: RABBITMQ_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: RABBITMQ_URL
          envFrom:
            - configMapRef:
                name: fastapi-config
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
```

**Create `k8s/ingress.yaml`:**

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fastapi-ingress
  namespace: fastapi-app
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/websocket-services: "fastapi-app"
spec:
  tls:
    - hosts:
        - api.your-domain.com
      secretName: fastapi-tls
  rules:
    - host: api.your-domain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: fastapi-app
                port:
                  number: 8000
```

**Create `k8s/hpa.yaml` (Horizontal Pod Autoscaler):**

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: fastapi-hpa
  namespace: fastapi-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: fastapi-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    - type: Pods
      pods:
        metric:
          name: http_requests_total
        target:
          type: AverageValue
          averageValue: "100"
```

## Step 6: Capstone Projects

### The Target
Build complete production-ready applications using everything we've learned.

### Project 1: E-Commerce Backend API

**Create `app/domain/entities/product.py`:**

```python
"""
app/domain/entities/product.py
Product domain entity for e-commerce.
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional, List
from decimal import Decimal
import uuid


@dataclass
class Product:
    """
    Product domain entity.
    """
    
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    description: str
    price: Decimal
    sku: str
    quantity_in_stock: int
    category: str
    tags: List[str] = field(default_factory=list)
    images: List[str] = field(default_factory=list)
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime = field(default_factory=datetime.utcnow)
    is_active: bool = True
    
    def reduce_stock(self, quantity: int) -> None:
        """Reduce stock by quantity."""
        if quantity > self.quantity_in_stock:
            raise ValueError(f"Insufficient stock. Available: {self.quantity_in_stock}")
        self.quantity_in_stock -= quantity
        self.updated_at = datetime.utcnow()
    
    def increase_stock(self, quantity: int) -> None:
        """Increase stock by quantity."""
        self.quantity_in_stock += quantity
        self.updated_at = datetime.utcnow()
    
    def is_available(self, quantity: int = 1) -> bool:
        """Check if product is available."""
        return self.is_active and self.quantity_in_stock >= quantity
```

### Project 2: Real-Time Chat Application

**Create `app/domain/entities/message.py`:**

```python
"""
app/domain/entities/message.py
Message domain entity for chat application.
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional
import uuid


@dataclass
class Message:
    """
    Message domain entity.
    """
    
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    room_id: str
    sender_id: str
    content: str
    message_type: str = "text"  # text, image, file
    sent_at: datetime = field(default_factory=datetime.utcnow)
    read_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    
    def mark_as_read(self) -> None:
        """Mark message as read."""
        self.read_at = datetime.utcnow()
    
    def mark_as_delivered(self) -> None:
        """Mark message as delivered."""
        self.delivered_at = datetime.utcnow()
```

### Project 3: Notification Service

**Create `app/domain/entities/notification.py`:**

```python
"""
app/domain/entities/notification.py
Notification domain entity.
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional, Dict, Any
import uuid


@dataclass
class Notification:
    """
    Notification domain entity.
    """
    
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    title: str
    message: str
    notification_type: str  # email, sms, push, in_app
    priority: str = "normal"  # low, normal, high, critical
    status: str = "pending"  # pending, sent, failed, delivered, read
    metadata: Dict[str, Any] = field(default_factory=dict)
    created_at: datetime = field(default_factory=datetime.utcnow)
    sent_at: Optional[datetime] = None
    read_at: Optional[datetime] = None
    
    def mark_as_sent(self) -> None:
        """Mark notification as sent."""
        self.status = "sent"
        self.sent_at = datetime.utcnow()
    
    def mark_as_delivered(self) -> None:
        """Mark notification as delivered."""
        self.status = "delivered"
    
    def mark_as_read(self) -> None:
        """Mark notification as read."""
        self.status = "read"
        self.read_at = datetime.utcnow()
    
    def mark_as_failed(self, error: str) -> None:
        """Mark notification as failed."""
        self.status = "failed"
        self.metadata["error"] = error
```

## Deployment Verification

```bash
# 1. Deploy to Kubernetes
kubectl apply -f k8s/

# 2. Check deployment status
kubectl get pods -n fastapi-app
kubectl get services -n fastapi-app
kubectl get ingress -n fastapi-app

# 3. Scale deployment
kubectl scale deployment fastapi-app -n fastapi-app --replicas=5

# 4. View logs
kubectl logs -f deployment/fastapi-app -n fastapi-app

# 5. Test autoscaling
kubectl get hpa -n fastapi-app

# 6. Run a load test
# Install vegeta
go get -u github.com/tsenart/vegeta
echo "GET http://localhost:8000/api/v1/health/ping" | vegeta attack -rate=100 -duration=30s | vegeta report

# 7. Check services
kubectl get svc -n fastapi-app
kubectl get ingress -n fastapi-app

# 8. Monitor with Prometheus
kubectl port-forward -n monitoring service/prometheus 9090:9090

# 9. Monitor with Grafana
kubectl port-forward -n monitoring service/grafana 3000:3000
```

## What We Accomplished

✅ Applied Clean Architecture principles to our application
✅ Implemented Domain-Driven Design (DDD) patterns
✅ Created domain entities with business logic
✅ Built use cases for application orchestration
✅ Implemented event-driven architecture with RabbitMQ
✅ Added file uploads with AWS S3 support
✅ Integrated Elasticsearch for full-text search
✅ Deployed to Kubernetes with auto-scaling
✅ Built three complete capstone projects

## Key Takeaways

1. **Clean Architecture**: Keep business logic independent of frameworks
2. **Domain-Driven Design**: Model your software after the business domain
3. **Event-Driven**: Use events to decouple components
4. **Storage**: Support multiple storage backends (local, S3)
5. **Search**: Elasticsearch provides powerful search capabilities
6. **Kubernetes**: Orchestrate containers for production-scale deployments
7. **Auto-scaling**: Scale based on load with Horizontal Pod Autoscaler
8. **Capstone Projects**: Apply everything to real-world applications

## Congratulations!

You've completed the **FastAPI Masterclass: Building Production-Ready APIs**! Let's recap what you've accomplished:

- ✅ **Part 1**: Built FastAPI foundations with proper architecture
- ✅ **Part 2**: Integrated PostgreSQL with SQLAlchemy 2.0
- ✅ **Part 3**: Implemented OAuth2, JWT, and RBAC security
- ✅ **Part 4**: Added async patterns, caching, WebSockets, and Celery
- ✅ **Part 5**: Containerized with Docker, set up CI/CD, monitoring
- ✅ **Part 6**: Applied Clean Architecture, event-driven patterns, Kubernetes

You now have the skills to:
- Design and build production-ready APIs
- Implement enterprise-grade architectures
- Deploy and scale applications in the cloud
- Follow industry best practices
- Build any backend application with confidence

### Next Steps

1. **Build your own projects**: Start building real applications
2. **Contribute to open source**: Apply your skills to real-world projects
3. **Keep learning**: Explore GraphQL, gRPC, and serverless
4. **Share your knowledge**: Help others learn by writing tutorials
5. **Stay updated**: Follow FastAPI and related technologies

The journey doesn't end here—this is just the beginning of your career as a backend architect!
