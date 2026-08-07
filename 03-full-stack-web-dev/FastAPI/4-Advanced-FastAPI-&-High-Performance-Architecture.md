# Part 4: Advanced FastAPI & High-Performance Architecture

Welcome to Part 4 of our FastAPI Masterclass! Now that we have a secure, authenticated API with proper database integration, it's time to take things to the next level. In this module, we'll master asynchronous programming, implement real-time features with WebSockets, add caching for performance, set up task queues for background processing, and implement rate limiting to protect our API from abuse.

## Learning Objectives

By the end of Part 4, you will be able to:
- Master async/await programming patterns in FastAPI
- Implement background tasks for email and file processing
- Set up Celery with Redis for distributed task queues
- Add WebSocket endpoints for real-time communication
- Implement Redis caching for query optimization
- Add rate limiting with token bucket and sliding window algorithms
- Optimize performance with connection pooling and compression
- Profile and benchmark your FastAPI application

## Key Concepts Before We Begin

### What is Asynchronous Programming?
Think of async programming like a restaurant kitchen. In a synchronous kitchen, one chef prepares each dish from start to finish before starting the next. In an async kitchen, chefs can start multiple dishes, moving between them while waiting for things to cook or ingredients to arrive. This allows them to handle many orders simultaneously without getting overwhelmed.

### What are Background Tasks?
Background tasks are like delivery orders—they need to be fulfilled but don't require immediate attention. Instead of making the customer wait while you prepare the delivery, you take the order, give them a confirmation, and then complete the delivery in the background while handling other customers.

### What are WebSockets?
WebSockets are like a dedicated telephone line between the server and client. Unlike HTTP requests (which are like sending a letter and waiting for a reply), WebSockets keep the connection open so either side can send messages at any time—perfect for real-time features like chat or live updates.

## Step 1: Async Programming Fundamentals

### The Target
Master async/await patterns in FastAPI with proper error handling and concurrency management.

### The Concept
Async programming allows your application to handle multiple operations concurrently without blocking the event loop. Think of it as juggling—you can keep multiple balls in the air, switching between them quickly, rather than throwing one ball, catching it, then throwing the next.

### The Implementation

**Create `app/utils/async_utils.py`:**

```python
"""
app/utils/async_utils.py
Async programming utilities and patterns.
"""

import asyncio
from typing import List, Any, Callable, TypeVar, Coroutine
from concurrent.futures import ThreadPoolExecutor
import time
import logging

logger = logging.getLogger(__name__)

# Type variable for generic functions
T = TypeVar('T')

# Thread pool for CPU-bound operations
_thread_pool = ThreadPoolExecutor(max_workers=4)


# ────────────────────────────────────────────────────────────────
# Concurrent Execution Utilities
# ────────────────────────────────────────────────────────────────

async def gather_with_concurrency(
    max_concurrency: int,
    coroutines: List[Coroutine],
    *,
    return_exceptions: bool = False
) -> List[Any]:
    """
    Execute coroutines with a maximum concurrency limit.
    
    This is useful when you have many tasks but don't want to
    overwhelm the system by executing them all at once.
    
    Args:
        max_concurrency: Maximum number of coroutines to run concurrently
        coroutines: List of coroutines to execute
        return_exceptions: Whether to return exceptions or raise them
        
    Returns:
        List[Any]: Results of the coroutines
        
    Example:
        results = await gather_with_concurrency(
            5,
            [fetch_user(i) for i in range(100)]
        )
    """
    semaphore = asyncio.Semaphore(max_concurrency)
    
    async def sem_task(coro):
        async with semaphore:
            return await coro
    
    tasks = [sem_task(coro) for coro in coroutines]
    return await asyncio.gather(*tasks, return_exceptions=return_exceptions)


async def run_in_thread(func: Callable, *args, **kwargs) -> Any:
    """
    Run a synchronous function in a thread pool.
    
    This is useful for CPU-bound operations that would block the event loop.
    
    Args:
        func: Synchronous function to run
        *args: Positional arguments for the function
        **kwargs: Keyword arguments for the function
        
    Returns:
        Any: Result of the function
        
    Example:
        result = await run_in_thread(slow_cpu_bound_function, data)
    """
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(_thread_pool, func, *args)


async def run_in_process(func: Callable, *args, **kwargs) -> Any:
    """
    Run a function in a separate process.
    
    This is useful for very CPU-intensive operations that need
    their own process to avoid GIL limitations.
    
    Note: Requires multiprocessing setup.
    """
    # Simplified implementation - for production, use a proper process pool
    import multiprocessing
    with multiprocessing.Pool(processes=1) as pool:
        return await run_in_thread(pool.apply, func, args, kwargs)


# ────────────────────────────────────────────────────────────────
# Retry Utilities
# ────────────────────────────────────────────────────────────────

async def retry_async(
    func: Callable,
    *args,
    max_retries: int = 3,
    delay: float = 1.0,
    backoff: float = 2.0,
    exceptions: tuple = (Exception,),
    **kwargs
) -> Any:
    """
    Retry an async function with exponential backoff.
    
    This is useful for operations that might fail transiently,
    like database connections or external API calls.
    
    Args:
        func: Async function to retry
        max_retries: Maximum number of retry attempts
        delay: Initial delay between retries (seconds)
        backoff: Multiplier for delay on each retry
        exceptions: Tuple of exceptions to catch and retry
        *args: Positional arguments for the function
        **kwargs: Keyword arguments for the function
        
    Returns:
        Any: Result of the function
        
    Raises:
        Exception: The last exception raised
        
    Example:
        result = await retry_async(
            fetch_external_api,
            url,
            max_retries=5,
            delay=0.5
        )
    """
    last_exception = None
    current_delay = delay
    
    for attempt in range(max_retries):
        try:
            return await func(*args, **kwargs)
        except exceptions as e:
            last_exception = e
            logger.warning(
                f"Retry {attempt + 1}/{max_retries} failed: {e}",
                extra={"attempt": attempt + 1, "max_retries": max_retries}
            )
            
            if attempt < max_retries - 1:
                await asyncio.sleep(current_delay)
                current_delay *= backoff
    
    raise last_exception


# ────────────────────────────────────────────────────────────────
# Timing Utilities
# ────────────────────────────────────────────────────────────────

class AsyncTimer:
    """
    Context manager for timing async operations.
    
    Example:
        async with AsyncTimer("fetch_data") as timer:
            data = await fetch_data()
        logger.info(f"Fetched data in {timer.elapsed:.2f}s")
    """
    
    def __init__(self, name: str = "operation"):
        self.name = name
        self.start_time = None
        self.elapsed = None
    
    async def __aenter__(self):
        self.start_time = time.perf_counter()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        self.elapsed = time.perf_counter() - self.start_time
        logger.debug(f"{self.name} completed in {self.elapsed:.3f}s")
        
        # Log slow operations
        if self.elapsed > 1.0:
            logger.warning(f"Slow {self.name} took {self.elapsed:.3f}s")


def timed_async(name: str = None):
    """
    Decorator for timing async functions.
    
    Example:
        @timed_async("fetch_user_data")
        async def fetch_user_data(user_id: int):
            ...
    """
    def decorator(func):
        async def wrapper(*args, **kwargs):
            timer_name = name or func.__name__
            async with AsyncTimer(timer_name):
                return await func(*args, **kwargs)
        return wrapper
    return decorator


# ────────────────────────────────────────────────────────────────
# Rate Limiting Utilities
# ────────────────────────────────────────────────────────────────

class AsyncRateLimiter:
    """
    Rate limiter for async operations.
    
    Implements a token bucket algorithm.
    
    Example:
        limiter = AsyncRateLimiter(max_tokens=10, time_window=60)
        async for _ in range(100):
            await limiter.acquire()
            await send_request()
    """
    
    def __init__(self, max_tokens: int, time_window: float):
        """
        Initialize the rate limiter.
        
        Args:
            max_tokens: Maximum number of tokens (requests)
            time_window: Time window in seconds
        """
        self.max_tokens = max_tokens
        self.time_window = time_window
        self.tokens = max_tokens
        self.last_refill = asyncio.get_event_loop().time()
        self._lock = asyncio.Lock()
    
    async def acquire(self) -> bool:
        """
        Acquire a token from the bucket.
        
        Returns:
            bool: True if token was acquired, False otherwise
        """
        async with self._lock:
            now = asyncio.get_event_loop().time()
            
            # Refill tokens
            time_passed = now - self.last_refill
            if time_passed > 0:
                new_tokens = time_passed / self.time_window * self.max_tokens
                self.tokens = min(self.max_tokens, self.tokens + new_tokens)
                self.last_refill = now
            
            # Check if we have tokens
            if self.tokens >= 1:
                self.tokens -= 1
                return True
            
            return False
    
    async def wait_for_token(self, timeout: float = 60.0) -> None:
        """
        Wait until a token is available.
        
        Args:
            timeout: Maximum time to wait in seconds
            
        Raises:
            TimeoutError: If timeout is exceeded
        """
        start = asyncio.get_event_loop().time()
        while True:
            if await self.acquire():
                return
            
            if asyncio.get_event_loop().time() - start > timeout:
                raise TimeoutError("Timed out waiting for rate limiter token")
            
            await asyncio.sleep(0.1)


# ────────────────────────────────────────────────────────────────
# Caching Utilities
# ────────────────────────────────────────────────────────────────

from functools import wraps
from typing import Optional, Dict, Any
import json
import hashlib
from datetime import datetime, timedelta


class AsyncCache:
    """
    Simple in-memory cache for async functions.
    
    For production use Redis (see Step 4).
    """
    
    def __init__(self):
        self._cache: Dict[str, Dict[str, Any]] = {}
        self._lock = asyncio.Lock()
    
    async def get(self, key: str) -> Optional[Any]:
        """Get a value from cache."""
        async with self._lock:
            entry = self._cache.get(key)
            if entry:
                # Check if expired
                if entry.get("expires_at") and datetime.utcnow() > entry["expires_at"]:
                    del self._cache[key]
                    return None
                return entry.get("value")
            return None
    
    async def set(self, key: str, value: Any, ttl: Optional[int] = None):
        """Set a value in cache."""
        async with self._lock:
            entry = {"value": value}
            if ttl:
                entry["expires_at"] = datetime.utcnow() + timedelta(seconds=ttl)
            self._cache[key] = entry
    
    async def delete(self, key: str):
        """Delete a value from cache."""
        async with self._lock:
            self._cache.pop(key, None)
    
    async def clear(self):
        """Clear all cache."""
        async with self._lock:
            self._cache.clear()
    
    async def cleanup(self):
        """Remove expired entries."""
        async with self._lock:
            now = datetime.utcnow()
            expired_keys = [
                key for key, entry in self._cache.items()
                if entry.get("expires_at") and now > entry["expires_at"]
            ]
            for key in expired_keys:
                del self._cache[key]


# Global cache instance
_default_cache = AsyncCache()


def cached(ttl: Optional[int] = None, key_prefix: str = ""):
    """
    Decorator for caching async function results.
    
    Args:
        ttl: Time to live in seconds (None for no expiration)
        key_prefix: Prefix for cache keys
        
    Example:
        @cached(ttl=300)
        async def get_user_profile(user_id: int):
            return await fetch_from_db(user_id)
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Generate cache key
            key_data = f"{func.__name__}:{args}:{kwargs}"
            key = f"{key_prefix}{hashlib.md5(key_data.encode()).hexdigest()}"
            
            # Try to get from cache
            cached_result = await _default_cache.get(key)
            if cached_result is not None:
                return cached_result
            
            # Call the function
            result = await func(*args, **kwargs)
            
            # Store in cache
            await _default_cache.set(key, result, ttl)
            
            return result
        return wrapper
    return decorator


# ────────────────────────────────────────────────────────────────
# Async Context Managers
# ────────────────────────────────────────────────────────────────

class AsyncResourcePool:
    """
    Generic pool for async resources.
    
    Useful for managing connections, sessions, etc.
    """
    
    def __init__(self, resource_factory, max_size: int = 10):
        """
        Initialize the pool.
        
        Args:
            resource_factory: Async function that creates a resource
            max_size: Maximum number of resources in the pool
        """
        self._factory = resource_factory
        self._max_size = max_size
        self._pool: List[Any] = []
        self._lock = asyncio.Lock()
    
    async def acquire(self) -> Any:
        """
        Acquire a resource from the pool.
        
        Returns:
            Any: A resource from the pool
        """
        async with self._lock:
            if self._pool:
                return self._pool.pop()
            
            # Create new resource if pool is empty
            return await self._factory()
    
    async def release(self, resource: Any) -> None:
        """
        Release a resource back to the pool.
        
        Args:
            resource: Resource to release
        """
        async with self._lock:
            if len(self._pool) < self._max_size:
                self._pool.append(resource)
            else:
                # Pool is full, close the resource
                if hasattr(resource, "close"):
                    await resource.close()
    
    async def cleanup(self) -> None:
        """Close all resources in the pool."""
        async with self._lock:
            for resource in self._pool:
                if hasattr(resource, "close"):
                    await resource.close()
            self._pool.clear()
```

## Step 2: Background Tasks

### The Target
Implement FastAPI BackgroundTasks for handling operations that don't need to block the response.

### The Concept
Background tasks are like delegating work to an assistant while you continue serving customers. Instead of making the user wait for an email to send or a file to process, you acknowledge their request immediately and handle the heavy work in the background.

### The Implementation

**Create `app/services/background.py`:**

```python
"""
app/services/background.py
Background task services for email, notifications, and file processing.
"""

from fastapi import BackgroundTasks
from typing import Optional, Dict, Any, List
from datetime import datetime
import logging
import asyncio
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

from app.core.config import settings

logger = logging.getLogger(__name__)


# ────────────────────────────────────────────────────────────────
# Email Services
# ────────────────────────────────────────────────────────────────

class EmailService:
    """
    Service for sending emails in the background.
    """
    
    @staticmethod
    async def send_email(
        to: str,
        subject: str,
        body: str,
        html_body: Optional[str] = None,
        from_email: Optional[str] = None,
    ) -> bool:
        """
        Send an email.
        
        Args:
            to: Recipient email address
            subject: Email subject
            body: Plain text body
            html_body: Optional HTML body
            from_email: Sender email (default from settings)
            
        Returns:
            bool: True if sent successfully
        """
        try:
            from_email = from_email or settings.EMAIL_FROM or "noreply@example.com"
            
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = from_email
            msg["To"] = to
            
            # Add plain text body
            msg.attach(MIMEText(body, "plain"))
            
            # Add HTML body if provided
            if html_body:
                msg.attach(MIMEText(html_body, "html"))
            
            # Send email
            if settings.SMTP_HOST:
                with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
                    if settings.SMTP_USER and settings.SMTP_PASSWORD:
                        server.starttls()
                        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                    server.send_message(msg)
            else:
                # In development, just log the email
                logger.info(
                    f"📧 Email would be sent to {to}",
                    extra={
                        "to": to,
                        "subject": subject,
                        "body": body[:200],
                    }
                )
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to send email to {to}: {e}")
            return False
    
    @staticmethod
    async def send_welcome_email(to: str, name: str) -> bool:
        """
        Send welcome email to new user.
        
        Args:
            to: User email
            name: User full name
            
        Returns:
            bool: True if sent successfully
        """
        subject = f"Welcome to {settings.APP_NAME}!"
        body = f"""
        Hello {name},
        
        Welcome to {settings.APP_NAME}! We're excited to have you on board.
        
        To get started, log in to your account and explore the features.
        
        Best regards,
        The {settings.APP_NAME} Team
        """
        
        html_body = f"""
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background-color: #4CAF50; color: white; padding: 20px; text-align: center; }}
                .content {{ padding: 20px; }}
                .footer {{ background-color: #f4f4f4; padding: 10px; text-align: center; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Welcome to {settings.APP_NAME}!</h1>
                </div>
                <div class="content">
                    <p>Hello {name},</p>
                    <p>Welcome to {settings.APP_NAME}! We're excited to have you on board.</p>
                    <p>To get started, log in to your account and explore the features.</p>
                    <p>Best regards,<br>The {settings.APP_NAME} Team</p>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {settings.APP_NAME}. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return await EmailService.send_email(to, subject, body, html_body)
    
    @staticmethod
    async def send_password_reset_email(to: str, name: str, token: str) -> bool:
        """
        Send password reset email.
        
        Args:
            to: User email
            name: User full name
            token: Password reset token
            
        Returns:
            bool: True if sent successfully
        """
        reset_url = f"https://yourapp.com/reset-password?token={token}"
        
        subject = "Password Reset Request"
        body = f"""
        Hello {name},
        
        You requested a password reset. Click the link below to reset your password:
        
        {reset_url}
        
        This link will expire in 24 hours.
        
        If you didn't request this, please ignore this email.
        
        Best regards,
        The {settings.APP_NAME} Team
        """
        
        html_body = f"""
        <html>
        <body>
            <p>Hello {name},</p>
            <p>You requested a password reset. Click the link below to reset your password:</p>
            <p><a href="{reset_url}">Reset Password</a></p>
            <p>This link will expire in 24 hours.</p>
            <p>If you didn't request this, please ignore this email.</p>
            <p>Best regards,<br>The {settings.APP_NAME} Team</p>
        </body>
        </html>
        """
        
        return await EmailService.send_email(to, subject, body, html_body)


# ────────────────────────────────────────────────────────────────
# Notification Services
# ────────────────────────────────────────────────────────────────

class NotificationService:
    """
    Service for sending notifications.
    """
    
    @staticmethod
    async def send_notification(
        user_id: int,
        title: str,
        message: str,
        notification_type: str = "info",
        metadata: Optional[Dict[str, Any]] = None,
    ) -> None:
        """
        Send a notification to a user.
        
        Args:
            user_id: User ID
            title: Notification title
            message: Notification message
            notification_type: Type of notification (info, success, warning, error)
            metadata: Additional metadata
        """
        # In production, store in database or send to notification service
        logger.info(
            f"🔔 Notification for user {user_id}: {title}",
            extra={
                "user_id": user_id,
                "title": title,
                "message": message,
                "type": notification_type,
                "metadata": metadata,
            }
        )
        
        # WebSocket notification (see Step 5)
        # await notify_user_via_websocket(user_id, {
        #     "title": title,
        #     "message": message,
        #     "type": notification_type,
        #     "metadata": metadata,
        # })
    
    @staticmethod
    async def notify_task_assigned(
        user_id: int,
        task_title: str,
        task_id: int,
        assigned_by: str,
    ) -> None:
        """
        Notify user when a task is assigned to them.
        
        Args:
            user_id: User ID
            task_title: Task title
            task_id: Task ID
            assigned_by: Name of the person who assigned the task
        """
        await NotificationService.send_notification(
            user_id=user_id,
            title="New Task Assignment",
            message=f"{assigned_by} assigned you the task: {task_title}",
            notification_type="info",
            metadata={
                "task_id": task_id,
                "task_title": task_title,
                "assigned_by": assigned_by,
            }
        )
    
    @staticmethod
    async def notify_task_completed(
        user_id: int,
        task_title: str,
        task_id: int,
        completed_by: str,
    ) -> None:
        """
        Notify user when a task they created is completed.
        
        Args:
            user_id: User ID
            task_title: Task title
            task_id: Task ID
            completed_by: Name of the person who completed the task
        """
        await NotificationService.send_notification(
            user_id=user_id,
            title="Task Completed",
            message=f"{completed_by} completed the task: {task_title}",
            notification_type="success",
            metadata={
                "task_id": task_id,
                "task_title": task_title,
                "completed_by": completed_by,
            }
        )


# ────────────────────────────────────────────────────────────────
# File Processing Services
# ────────────────────────────────────────────────────────────────

class FileProcessingService:
    """
    Service for processing files in the background.
    """
    
    @staticmethod
    async def process_uploaded_file(
        file_path: str,
        file_name: str,
        user_id: int,
        file_size: int,
    ) -> Dict[str, Any]:
        """
        Process an uploaded file.
        
        Args:
            file_path: Path to the uploaded file
            file_name: Original file name
            user_id: User ID who uploaded the file
            file_size: Size of the file in bytes
            
        Returns:
            Dict: Processing results
        """
        try:
            # Simulate file processing
            await asyncio.sleep(2)  # Simulate work
            
            # Determine file type
            file_extension = file_name.split(".")[-1].lower() if "." in file_name else ""
            
            # Process based on file type
            if file_extension in ["jpg", "jpeg", "png", "gif"]:
                # Generate thumbnail
                thumbnail_path = f"{file_path}_thumb.jpg"
                # In production: resize image
                logger.info(f"Generated thumbnail: {thumbnail_path}")
            elif file_extension in ["pdf", "doc", "docx"]:
                # Extract text
                # In production: use PDF/DOC parsing
                logger.info(f"Extracted text from: {file_name}")
            else:
                logger.info(f"File {file_name} uploaded (no processing needed)")
            
            return {
                "processed": True,
                "file_name": file_name,
                "file_size": file_size,
                "file_type": file_extension,
                "user_id": user_id,
                "processed_at": datetime.utcnow().isoformat() + "Z",
            }
            
        except Exception as e:
            logger.error(f"Error processing file {file_name}: {e}")
            return {
                "processed": False,
                "file_name": file_name,
                "error": str(e),
            }


# ────────────────────────────────────────────────────────────────
# Background Task Wrappers
# ────────────────────────────────────────────────────────────────

def create_background_tasks() -> BackgroundTasks:
    """
    Create a BackgroundTasks instance.
    
    Returns:
        BackgroundTasks: Configured background tasks
    """
    return BackgroundTasks()


def add_background_task(
    background_tasks: BackgroundTasks,
    task_func,
    *args,
    **kwargs,
) -> None:
    """
    Add a background task to the BackgroundTasks instance.
    
    Args:
        background_tasks: BackgroundTasks instance
        task_func: Async function to run in background
        *args: Positional arguments for the task
        **kwargs: Keyword arguments for the task
    """
    background_tasks.add_task(task_func, *args, **kwargs)


# ────────────────────────────────────────────────────────────────
# Background Task Decorators
# ────────────────────────────────────────────────────────────────

def background_task(func):
    """
    Decorator to mark a function as a background task.
    
    Ensures the function is properly logged and error-handled.
    
    Example:
        @background_task
        async def send_welcome_email(email: str, name: str):
            ...
    """
    @wraps(func)
    async def wrapper(*args, **kwargs):
        try:
            logger.info(f"Starting background task: {func.__name__}")
            result = await func(*args, **kwargs)
            logger.info(f"Completed background task: {func.__name__}")
            return result
        except Exception as e:
            logger.error(
                f"Background task {func.__name__} failed: {e}",
                exc_info=True
            )
            raise
    
    return wrapper
```

## Step 3: Celery Task Queue Integration

### The Target
Set up Celery with Redis for distributed task processing, enabling heavy background jobs to be processed by separate workers.

### The Concept
Celery is like having a dedicated team of workers who handle tasks asynchronously. When you need something done (like sending 1000 emails), you put the request in a queue, and the workers pick it up and process it. This keeps your main application responsive and allows tasks to be processed even if the main server goes down.

### The Implementation

**Create `app/core/celery_app.py`:**

```python
"""
app/core/celery_app.py
Celery application configuration for distributed task processing.
"""

from celery import Celery
from celery.schedules import crontab
import os

from app.core.config import settings

# Create Celery app
celery_app = Celery(
    "fastapi_masterclass",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
    include=[
        "app.tasks.background",
        "app.tasks.scheduled",
    ],
)

# Configure Celery
celery_app.conf.update(
    # Task serialization
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    
    # Task execution
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutes
    task_soft_time_limit=25 * 60,  # 25 minutes
    
    # Worker settings
    worker_prefetch_multiplier=1,
    worker_max_tasks_per_child=100,
    
    # Result backend
    result_expires=60 * 60 * 24,  # 24 hours
    
    # Beat schedule (scheduled tasks)
    beat_schedule={
        "cleanup-old-tasks": {
            "task": "app.tasks.scheduled.cleanup_old_tasks",
            "schedule": crontab(hour=0, minute=0),  # Daily at midnight
        },
        "send-daily-digest": {
            "task": "app.tasks.scheduled.send_daily_digest",
            "schedule": crontab(hour=8, minute=0),  # Daily at 8 AM
        },
        "check-overdue-tasks": {
            "task": "app.tasks.scheduled.check_overdue_tasks",
            "schedule": crontab(minute="*/30"),  # Every 30 minutes
        },
    },
)

# Optional: Configure logging
celery_app.conf.update(
    worker_redirect_stdouts_level="INFO",
)

# Load settings from environment
celery_app.config_from_object("app.core.celery_config")


# ────────────────────────────────────────────────────────────────
# Celery Configuration Class
# ────────────────────────────────────────────────────────────────

class CeleryConfig:
    """Celery configuration."""
    
    # Broker settings
    broker_url = settings.REDIS_URL
    
    # Result backend
    result_backend = settings.REDIS_URL
    
    # Task routing
    task_routes = {
        "app.tasks.background.*": {"queue": "default"},
        "app.tasks.background.send_email": {"queue": "email"},
        "app.tasks.background.process_image": {"queue": "processing"},
        "app.tasks.scheduled.*": {"queue": "scheduled"},
    }
    
    # Task queues
    task_queues = {
        "default": {
            "exchange": "default",
            "routing_key": "default",
        },
        "email": {
            "exchange": "email",
            "routing_key": "email",
        },
        "processing": {
            "exchange": "processing",
            "routing_key": "processing",
        },
        "scheduled": {
            "exchange": "scheduled",
            "routing_key": "scheduled",
        },
    }

# Apply config
celery_app.config_from_object(CeleryConfig)
```

**Create `app/tasks/background.py`:**

```python
"""
app/tasks/background.py
Background tasks for Celery workers.
"""

from app.core.celery_app import celery_app
from app.services.background import EmailService, NotificationService, FileProcessingService
from app.services.user import UserService
from app.core.database import AsyncSessionLocal
import logging

logger = logging.getLogger(__name__)


@celery_app.task(name="app.tasks.background.send_welcome_email")
def send_welcome_email_task(email: str, name: str) -> dict:
    """
    Task to send welcome email to new user.
    
    Args:
        email: User email
        name: User full name
        
    Returns:
        dict: Result of the task
    """
    import asyncio
    
    try:
        # Run async function in sync context
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        result = loop.run_until_complete(
            EmailService.send_welcome_email(email, name)
        )
        
        loop.close()
        
        return {
            "status": "success" if result else "failure",
            "email": email,
            "name": name,
        }
    except Exception as e:
        logger.error(f"Failed to send welcome email to {email}: {e}")
        return {
            "status": "error",
            "email": email,
            "error": str(e),
        }


@celery_app.task(name="app.tasks.background.send_password_reset_email")
def send_password_reset_email_task(email: str, name: str, token: str) -> dict:
    """
    Task to send password reset email.
    
    Args:
        email: User email
        name: User full name
        token: Password reset token
        
    Returns:
        dict: Result of the task
    """
    import asyncio
    
    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        result = loop.run_until_complete(
            EmailService.send_password_reset_email(email, name, token)
        )
        
        loop.close()
        
        return {
            "status": "success" if result else "failure",
            "email": email,
            "name": name,
        }
    except Exception as e:
        logger.error(f"Failed to send password reset email to {email}: {e}")
        return {
            "status": "error",
            "email": email,
            "error": str(e),
        }


@celery_app.task(name="app.tasks.background.notify_task_assigned")
def notify_task_assigned_task(user_id: int, task_title: str, task_id: int, assigned_by: str) -> dict:
    """
    Task to notify user when a task is assigned.
    
    Args:
        user_id: User ID
        task_title: Task title
        task_id: Task ID
        assigned_by: Name of the assigner
        
    Returns:
        dict: Result of the task
    """
    import asyncio
    
    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        result = loop.run_until_complete(
            NotificationService.notify_task_assigned(
                user_id=user_id,
                task_title=task_title,
                task_id=task_id,
                assigned_by=assigned_by,
            )
        )
        
        loop.close()
        
        return {
            "status": "success",
            "user_id": user_id,
            "task_id": task_id,
        }
    except Exception as e:
        logger.error(f"Failed to notify user {user_id} about task {task_id}: {e}")
        return {
            "status": "error",
            "user_id": user_id,
            "task_id": task_id,
            "error": str(e),
        }


@celery_app.task(name="app.tasks.background.process_uploaded_file")
def process_uploaded_file_task(file_path: str, file_name: str, user_id: int, file_size: int) -> dict:
    """
    Task to process uploaded file.
    
    Args:
        file_path: Path to the file
        file_name: Original file name
        user_id: User ID who uploaded
        file_size: File size in bytes
        
    Returns:
        dict: Processing result
    """
    import asyncio
    
    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        result = loop.run_until_complete(
            FileProcessingService.process_uploaded_file(
                file_path=file_path,
                file_name=file_name,
                user_id=user_id,
                file_size=file_size,
            )
        )
        
        loop.close()
        
        return result
    except Exception as e:
        logger.error(f"Failed to process file {file_name}: {e}")
        return {
            "status": "error",
            "file_name": file_name,
            "error": str(e),
        }


@celery_app.task(name="app.tasks.background.send_bulk_emails")
def send_bulk_emails_task(email_data: list) -> dict:
    """
    Task to send bulk emails.
    
    Args:
        email_data: List of email data [{"to": email, "subject": subject, "body": body}]
        
    Returns:
        dict: Processing result
    """
    import asyncio
    
    successful = 0
    failed = 0
    
    for data in email_data:
        try:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            
            result = loop.run_until_complete(
                EmailService.send_email(
                    to=data["to"],
                    subject=data["subject"],
                    body=data["body"],
                    html_body=data.get("html_body"),
                )
            )
            
            loop.close()
            
            if result:
                successful += 1
            else:
                failed += 1
        except Exception as e:
            logger.error(f"Failed to send email to {data['to']}: {e}")
            failed += 1
    
    return {
        "status": "completed",
        "total": len(email_data),
        "successful": successful,
        "failed": failed,
    }
```

**Create `app/tasks/scheduled.py`:**

```python
"""
app/tasks/scheduled.py
Scheduled tasks for Celery beat.
"""

from app.core.celery_app import celery_app
from app.core.database import AsyncSessionLocal
from app.crud.task import TaskRepository
from app.crud.user import UserRepository
from app.services.background import EmailService, NotificationService
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


@celery_app.task(name="app.tasks.scheduled.cleanup_old_tasks")
def cleanup_old_tasks() -> dict:
    """
    Scheduled task to clean up old archived tasks.
    
    Runs daily at midnight.
    """
    import asyncio
    
    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        async def cleanup():
            async with AsyncSessionLocal() as session:
                task_repo = TaskRepository(session)
                
                # Delete tasks archived more than 90 days ago
                cutoff_date = datetime.utcnow() - timedelta(days=90)
                
                # In production: implement bulk delete based on archived_at
                
                return {"deleted_count": 0}
        
        result = loop.run_until_complete(cleanup())
        loop.close()
        
        logger.info(f"Cleaned up old tasks: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Failed to cleanup old tasks: {e}")
        return {"error": str(e)}


@celery_app.task(name="app.tasks.scheduled.send_daily_digest")
def send_daily_digest() -> dict:
    """
    Scheduled task to send daily digest emails to users.
    
    Runs daily at 8 AM.
    """
    import asyncio
    
    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        async def send_digest():
            async with AsyncSessionLocal() as session:
                user_repo = UserRepository(session)
                
                # Get all active users
                users = await user_repo.get_all(filters={"is_active": True})
                
                sent_count = 0
                for user in users:
                    # Get tasks created/completed today
                    # Get upcoming tasks
                    # Compile digest email
                    
                    # Send email
                    await EmailService.send_email(
                        to=user.email,
                        subject="Your Daily Task Digest",
                        body=f"""
                        Hello {user.full_name},
                        
                        Here's your daily task digest:
                        - Tasks created today: 0
                        - Tasks completed today: 0
                        - Upcoming tasks: 0
                        
                        Best regards,
                        The {settings.APP_NAME} Team
                        """,
                    )
                    
                    sent_count += 1
                
                return {"sent_count": sent_count}
        
        result = loop.run_until_complete(send_digest())
        loop.close()
        
        logger.info(f"Sent daily digest to {result['sent_count']} users")
        return result
        
    except Exception as e:
        logger.error(f"Failed to send daily digest: {e}")
        return {"error": str(e)}


@celery_app.task(name="app.tasks.scheduled.check_overdue_tasks")
def check_overdue_tasks() -> dict:
    """
    Scheduled task to check for overdue tasks and send notifications.
    
    Runs every 30 minutes.
    """
    import asyncio
    
    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        async def check_tasks():
            async with AsyncSessionLocal() as session:
                task_repo = TaskRepository(session)
                
                # Get overdue tasks
                overdue_tasks = await task_repo.get_overdue_tasks()
                
                notified_count = 0
                for task in overdue_tasks:
                    if task.assignee_id:
                        # Notify assignee
                        await NotificationService.send_notification(
                            user_id=task.assignee_id,
                            title="Task Overdue!",
                            message=f"Task '{task.title}' is overdue!",
                            notification_type="error",
                            metadata={
                                "task_id": task.id,
                                "task_title": task.title,
                                "due_date": task.due_date.isoformat() if task.due_date else None,
                            }
                        )
                        notified_count += 1
                
                return {"overdue_count": len(overdue_tasks), "notified_count": notified_count}
        
        result = loop.run_until_complete(check_tasks())
        loop.close()
        
        logger.info(f"Checked overdue tasks: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Failed to check overdue tasks: {e}")
        return {"error": str(e)}
```

## Step 4: Redis Caching

### The Target
Implement Redis caching for database queries and API responses to improve performance.

### The Concept
Redis caching is like having a personal assistant who remembers frequently asked questions. Instead of searching through the entire database every time, you check with the assistant first—if they know the answer, you get it instantly; if not, you ask the database and tell the assistant for next time.

### The Implementation

**Create `app/core/redis.py`:**

```python
"""
app/core/redis.py
Redis client for caching, rate limiting, and session management.
"""

import redis.asyncio as redis
from redis.asyncio import Redis
from typing import Optional, Any, Dict
import json
import pickle
from datetime import datetime, timedelta
import logging

from app.core.config import settings

logger = logging.getLogger(__name__)

# ────────────────────────────────────────────────────────────────
# Redis Client
# ────────────────────────────────────────────────────────────────

class RedisClient:
    """
    Redis client wrapper with async support.
    """
    
    def __init__(self):
        self._client: Optional[Redis] = None
        self._connected = False
    
    async def connect(self) -> None:
        """
        Connect to Redis server.
        """
        if self._connected:
            return
        
        try:
            self._client = redis.from_url(
                settings.REDIS_URL,
                encoding="utf-8",
                decode_responses=False,
                max_connections=10,
                socket_connect_timeout=5,
                socket_timeout=5,
                retry_on_timeout=True,
            )
            
            # Test connection
            await self._client.ping()
            self._connected = True
            logger.info("✅ Redis connection established")
            
        except Exception as e:
            logger.error(f"❌ Failed to connect to Redis: {e}")
            self._connected = False
            raise
    
    async def disconnect(self) -> None:
        """
        Disconnect from Redis server.
        """
        if self._client and self._connected:
            await self._client.close()
            self._connected = False
            logger.info("Redis connection closed")
    
    def is_connected(self) -> bool:
        """
        Check if Redis is connected.
        
        Returns:
            bool: True if connected
        """
        return self._connected and self._client is not None
    
    def get_client(self) -> Optional[Redis]:
        """
        Get the Redis client.
        
        Returns:
            Optional[Redis]: Redis client or None if not connected
        """
        return self._client


# ────────────────────────────────────────────────────────────────
# Redis Cache Service
# ────────────────────────────────────────────────────────────────

class RedisCache:
    """
    Redis-based caching service.
    """
    
    def __init__(self, client: RedisClient):
        self.client = client
    
    def _serialize_value(self, value: Any) -> bytes:
        """
        Serialize a value for Redis storage.
        
        Args:
            value: Value to serialize
            
        Returns:
            bytes: Serialized value
        """
        if isinstance(value, (str, int, float, bool)):
            return str(value).encode()
        return pickle.dumps(value)
    
    def _deserialize_value(self, data: bytes) -> Any:
        """
        Deserialize a value from Redis storage.
        
        Args:
            data: Serialized data
            
        Returns:
            Any: Deserialized value
        """
        if not data:
            return None
        
        # Try to decode as string first
        try:
            decoded = data.decode()
            # Try to parse as JSON
            try:
                return json.loads(decoded)
            except json.JSONDecodeError:
                return decoded
        except UnicodeDecodeError:
            # Binary data, try pickle
            try:
                return pickle.loads(data)
            except:
                return data
    
    async def get(self, key: str) -> Optional[Any]:
        """
        Get a value from cache.
        
        Args:
            key: Cache key
            
        Returns:
            Optional[Any]: Cached value or None
        """
        if not self.client.is_connected():
            return None
        
        try:
            redis = self.client.get_client()
            data = await redis.get(key.encode())
            if data:
                return self._deserialize_value(data)
            return None
        except Exception as e:
            logger.error(f"Redis get error for key {key}: {e}")
            return None
    
    async def set(
        self,
        key: str,
        value: Any,
        ttl: Optional[int] = None,
    ) -> bool:
        """
        Set a value in cache.
        
        Args:
            key: Cache key
            value: Value to cache
            ttl: Time to live in seconds
            
        Returns:
            bool: True if successful
        """
        if not self.client.is_connected():
            return False
        
        try:
            redis = self.client.get_client()
            serialized = self._serialize_value(value)
            
            if ttl:
                await redis.setex(key.encode(), ttl, serialized)
            else:
                await redis.set(key.encode(), serialized)
            return True
        except Exception as e:
            logger.error(f"Redis set error for key {key}: {e}")
            return False
    
    async def delete(self, key: str) -> bool:
        """
        Delete a value from cache.
        
        Args:
            key: Cache key
            
        Returns:
            bool: True if successful
        """
        if not self.client.is_connected():
            return False
        
        try:
            redis = self.client.get_client()
            await redis.delete(key.encode())
            return True
        except Exception as e:
            logger.error(f"Redis delete error for key {key}: {e}")
            return False
    
    async def delete_pattern(self, pattern: str) -> int:
        """
        Delete all keys matching a pattern.
        
        Args:
            pattern: Key pattern to match
            
        Returns:
            int: Number of keys deleted
        """
        if not self.client.is_connected():
            return 0
        
        try:
            redis = self.client.get_client()
            keys = await redis.keys(pattern)
            if keys:
                return await redis.delete(*keys)
            return 0
        except Exception as e:
            logger.error(f"Redis delete_pattern error: {e}")
            return 0
    
    async def exists(self, key: str) -> bool:
        """
        Check if a key exists in cache.
        
        Args:
            key: Cache key
            
        Returns:
            bool: True if key exists
        """
        if not self.client.is_connected():
            return False
        
        try:
            redis = self.client.get_client()
            return await redis.exists(key.encode()) > 0
        except Exception as e:
            logger.error(f"Redis exists error for key {key}: {e}")
            return False
    
    async def incr(self, key: str, amount: int = 1) -> int:
        """
        Increment a numeric value in cache.
        
        Args:
            key: Cache key
            amount: Amount to increment by
            
        Returns:
            int: New value
        """
        if not self.client.is_connected():
            return 0
        
        try:
            redis = self.client.get_client()
            return await redis.incrby(key.encode(), amount)
        except Exception as e:
            logger.error(f"Redis incr error for key {key}: {e}")
            return 0
    
    async def expire(self, key: str, ttl: int) -> bool:
        """
        Set expiration on a key.
        
        Args:
            key: Cache key
            ttl: Time to live in seconds
            
        Returns:
            bool: True if successful
        """
        if not self.client.is_connected():
            return False
        
        try:
            redis = self.client.get_client()
            return await redis.expire(key.encode(), ttl)
        except Exception as e:
            logger.error(f"Redis expire error for key {key}: {e}")
            return False


# ────────────────────────────────────────────────────────────────
# Cache Decorators
# ────────────────────────────────────────────────────────────────

# Create global cache instance
_cache_service: Optional[RedisCache] = None


def get_cache_service() -> RedisCache:
    """
    Get the cache service instance.
    
    Returns:
        RedisCache: Cache service instance
    """
    global _cache_service
    if _cache_service is None:
        client = RedisClient()
        _cache_service = RedisCache(client)
    return _cache_service


def cached_redis(ttl: int = 3600, prefix: str = ""):
    """
    Decorator for caching async function results in Redis.
    
    Args:
        ttl: Time to live in seconds
        prefix: Cache key prefix
        
    Example:
        @cached_redis(ttl=300, prefix="user")
        async def get_user_profile(user_id: int):
            ...
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            cache = get_cache_service()
            
            # Generate cache key
            key_parts = [prefix, func.__name__]
            key_parts.extend(str(arg) for arg in args if arg is not None)
            key_parts.extend(f"{k}:{v}" for k, v in kwargs.items() if v is not None)
            cache_key = ":".join(key_parts)
            
            # Try to get from cache
            cached_value = await cache.get(cache_key)
            if cached_value is not None:
                return cached_value
            
            # Call function
            result = await func(*args, **kwargs)
            
            # Cache result
            await cache.set(cache_key, result, ttl)
            
            return result
        return wrapper
    return decorator


def invalidate_cache(pattern: str):
    """
    Decorator to invalidate cache after a function call.
    
    Args:
        pattern: Cache key pattern to invalidate
        
    Example:
        @invalidate_cache("user:*")
        async def update_user_profile(user_id: int, data):
            ...
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            result = await func(*args, **kwargs)
            
            cache = get_cache_service()
            await cache.delete_pattern(pattern)
            
            return result
        return wrapper
    return decorator


# ────────────────────────────────────────────────────────────────
# Rate Limiting with Redis
# ────────────────────────────────────────────────────────────────

class RateLimiter:
    """
    Redis-based rate limiter using sliding window algorithm.
    """
    
    def __init__(self, cache: RedisCache):
        self.cache = cache
    
    async def is_allowed(
        self,
        key: str,
        max_requests: int,
        time_window: int,
    ) -> bool:
        """
        Check if a request is allowed under rate limiting.
        
        Args:
            key: Rate limit key (e.g., "ip:192.168.1.1")
            max_requests: Maximum requests allowed
            time_window: Time window in seconds
            
        Returns:
            bool: True if request is allowed
        """
        if not self.cache.client.is_connected():
            return True  # Allow if Redis is down
        
        try:
            # Use sliding window with sorted sets
            redis = self.cache.client.get_client()
            now = datetime.utcnow().timestamp()
            window_start = now - time_window
            
            # Remove old requests
            await redis.zremrangebyscore(key, 0, window_start)
            
            # Count requests in window
            count = await redis.zcard(key)
            
            if count >= max_requests:
                return False
            
            # Add current request
            await redis.zadd(key, {str(now): now})
            await redis.expire(key, time_window)
            
            return True
            
        except Exception as e:
            logger.error(f"Rate limiting error: {e}")
            return True  # Allow if rate limiting fails
```

## Step 5: WebSockets for Real-Time Features

### The Target
Implement WebSocket endpoints for real-time communication and notifications.

### The Concept
WebSockets create a persistent, two-way communication channel between the client and server. Think of it as leaving the door open for continuous conversation—either side can speak at any time, unlike HTTP where the client must initiate every request.

### The Implementation

**Create `app/websocket/manager.py`:**

```python
"""
app/websocket/manager.py
WebSocket connection manager for handling real-time connections.
"""

from fastapi import WebSocket, WebSocketDisconnect
from typing import Dict, Set, List, Any, Optional
import json
import asyncio
import logging

logger = logging.getLogger(__name__)


class ConnectionManager:
    """
    Manages WebSocket connections and message broadcasting.
    """
    
    def __init__(self):
        # Map of user_id to set of WebSocket connections
        self.active_connections: Dict[int, Set[WebSocket]] = {}
        # Map of connection_id to user_id
        self.connection_user: Dict[str, int] = {}
        # Map of room_id to set of connections
        self.rooms: Dict[str, Set[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int) -> None:
        """
        Connect a WebSocket for a user.
        
        Args:
            websocket: WebSocket connection
            user_id: User ID
        """
        await websocket.accept()
        
        # Add to user's connections
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)
        
        # Store connection mapping
        connection_id = id(websocket)
        self.connection_user[str(connection_id)] = user_id
        
        logger.info(
            f"WebSocket connected: user {user_id}",
            extra={"user_id": user_id, "connections": len(self.active_connections[user_id])}
        )
    
    def disconnect(self, websocket: WebSocket) -> None:
        """
        Disconnect a WebSocket.
        
        Args:
            websocket: WebSocket connection
        """
        # Get user ID
        connection_id = str(id(websocket))
        user_id = self.connection_user.pop(connection_id, None)
        
        if user_id and user_id in self.active_connections:
            self.active_connections[user_id].discard(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
        
        # Remove from rooms
        for room_name, connections in self.rooms.items():
            connections.discard(websocket)
        
        logger.info(
            f"WebSocket disconnected: user {user_id}",
            extra={"user_id": user_id}
        )
    
    async def send_personal_message(
        self,
        user_id: int,
        message: Dict[str, Any]
    ) -> int:
        """
        Send a message to a specific user.
        
        Args:
            user_id: Recipient user ID
            message: Message to send
            
        Returns:
            int: Number of connections sent to
        """
        sent_count = 0
        
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id]:
                try:
                    await connection.send_json(message)
                    sent_count += 1
                except Exception as e:
                    logger.error(f"Failed to send message to user {user_id}: {e}")
        
        return sent_count
    
    async def broadcast_to_room(
        self,
        room_name: str,
        message: Dict[str, Any],
        exclude: Optional[WebSocket] = None
    ) -> int:
        """
        Broadcast a message to all users in a room.
        
        Args:
            room_name: Room name
            message: Message to broadcast
            exclude: WebSocket connection to exclude
            
        Returns:
            int: Number of connections sent to
        """
        sent_count = 0
        
        if room_name in self.rooms:
            for connection in self.rooms[room_name]:
                if connection == exclude:
                    continue
                try:
                    await connection.send_json(message)
                    sent_count += 1
                except Exception as e:
                    logger.error(f"Failed to broadcast to room {room_name}: {e}")
        
        return sent_count
    
    async def join_room(self, websocket: WebSocket, room_name: str) -> None:
        """
        Join a room.
        
        Args:
            websocket: WebSocket connection
            room_name: Room name
        """
        if room_name not in self.rooms:
            self.rooms[room_name] = set()
        self.rooms[room_name].add(websocket)
        
        logger.debug(f"WebSocket joined room: {room_name}")
    
    async def leave_room(self, websocket: WebSocket, room_name: str) -> None:
        """
        Leave a room.
        
        Args:
            websocket: WebSocket connection
            room_name: Room name
        """
        if room_name in self.rooms:
            self.rooms[room_name].discard(websocket)
            if not self.rooms[room_name]:
                del self.rooms[room_name]
        
        logger.debug(f"WebSocket left room: {room_name}")
    
    def get_user_connection_count(self, user_id: int) -> int:
        """
        Get the number of connections for a user.
        
        Args:
            user_id: User ID
            
        Returns:
            int: Number of connections
        """
        return len(self.active_connections.get(user_id, set()))
    
    def get_connected_users(self) -> List[int]:
        """
        Get list of connected user IDs.
        
        Returns:
            List[int]: List of user IDs
        """
        return list(self.active_connections.keys())


# ────────────────────────────────────────────────────────────────
# WebSocket Endpoint
# ────────────────────────────────────────────────────────────────

from fastapi import APIRouter, Depends
from app.core.security import get_current_user
from app.models.user import User

websocket_router = APIRouter()

# Global connection manager
manager = ConnectionManager()


@websocket_router.websocket("/ws/{client_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    client_id: str,
    # In production, use authentication
    # user: User = Depends(get_current_user),
):
    """
    WebSocket endpoint for real-time communication.
    
    Args:
        websocket: WebSocket connection
        client_id: Client identifier (user ID)
    """
    try:
        user_id = int(client_id)
        
        # Accept connection and add to manager
        await manager.connect(websocket, user_id)
        
        # Send initial connection success message
        await websocket.send_json({
            "type": "connection",
            "status": "connected",
            "user_id": user_id,
            "message": "Connected to WebSocket server",
        })
        
        # Main message loop
        while True:
            # Receive message
            data = await websocket.receive_text()
            
            try:
                # Parse JSON message
                message = json.loads(data)
                message_type = message.get("type", "unknown")
                
                # Handle different message types
                if message_type == "ping":
                    # Respond to ping
                    await websocket.send_json({
                        "type": "pong",
                        "timestamp": datetime.utcnow().isoformat(),
                    })
                
                elif message_type == "join_room":
                    # Join a room
                    room_name = message.get("room")
                    if room_name:
                        await manager.join_room(websocket, room_name)
                        await websocket.send_json({
                            "type": "room_joined",
                            "room": room_name,
                        })
                
                elif message_type == "leave_room":
                    # Leave a room
                    room_name = message.get("room")
                    if room_name:
                        await manager.leave_room(websocket, room_name)
                        await websocket.send_json({
                            "type": "room_left",
                            "room": room_name,
                        })
                
                elif message_type == "message":
                    # Send message to room or user
                    recipient = message.get("to")
                    content = message.get("content")
                    
                    if recipient and content:
                        # Send to specific user
                        await manager.send_personal_message(
                            user_id=recipient,
                            message={
                                "type": "direct_message",
                                "from": user_id,
                                "content": content,
                                "timestamp": datetime.utcnow().isoformat(),
                            }
                        )
                    else:
                        # Broadcast to room or all
                        room_name = message.get("room")
                        if room_name:
                            await manager.broadcast_to_room(
                                room_name=room_name,
                                message={
                                    "type": "room_message",
                                    "from": user_id,
                                    "content": content,
                                    "timestamp": datetime.utcnow().isoformat(),
                                }
                            )
                
                elif message_type == "notification":
                    # User wants to receive notifications via WebSocket
                    # This is handled by the server
                    pass
                
                else:
                    # Unknown message type
                    await websocket.send_json({
                        "type": "error",
                        "message": f"Unknown message type: {message_type}",
                    })
                    
            except json.JSONDecodeError:
                # Invalid JSON
                await websocket.send_json({
                    "type": "error",
                    "message": "Invalid JSON message",
                })
            except Exception as e:
                logger.error(f"Error processing WebSocket message: {e}")
                await websocket.send_json({
                    "type": "error",
                    "message": str(e),
                })
                
    except WebSocketDisconnect:
        # Handle disconnection
        manager.disconnect(websocket)
        logger.info(f"WebSocket disconnected: {client_id}")
        
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        manager.disconnect(websocket)


# ────────────────────────────────────────────────────────────────
# Notification Helper
# ────────────────────────────────────────────────────────────────

async def notify_user_via_websocket(user_id: int, message: Dict[str, Any]) -> int:
    """
    Send a notification to a user via WebSocket.
    
    Args:
        user_id: User ID
        message: Notification message
        
    Returns:
        int: Number of connections notified
    """
    # Add timestamp if not present
    if "timestamp" not in message:
        message["timestamp"] = datetime.utcnow().isoformat()
    
    # Add notification type
    if "type" not in message:
        message["type"] = "notification"
    
    # Send to user
    return await manager.send_personal_message(user_id, message)


async def broadcast_to_project(
    project_id: int,
    message: Dict[str, Any],
    exclude_user_id: Optional[int] = None
) -> int:
    """
    Broadcast a message to all users in a project.
    
    Args:
        project_id: Project ID
        message: Message to broadcast
        exclude_user_id: User ID to exclude
        
    Returns:
        int: Number of connections notified
    """
    room_name = f"project_{project_id}"
    
    # Add timestamp
    if "timestamp" not in message:
        message["timestamp"] = datetime.utcnow().isoformat()
    
    # Add project info
    message["project_id"] = project_id
    
    # Broadcast to room
    # We need to get the WebSocket connections in the room
    # This is simplified - in production you'd track this differently
    
    return await manager.broadcast_to_room(room_name, message)
```

## Step 6: Rate Limiting Implementation

### The Target
Implement comprehensive rate limiting to protect your API from abuse and ensure fair usage.

### The Implementation

**Create `app/middleware/rate_limit.py`:**

```python
"""
app/middleware/rate_limit.py
Rate limiting middleware using Redis.
"""

from fastapi import Request, Response
from fastapi.middleware.base import BaseHTTPMiddleware
from typing import Optional, Tuple
import logging

from app.core.redis import get_cache_service, RateLimiter
from app.core.exceptions import TooManyRequestsException

logger = logging.getLogger(__name__)


class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Middleware for rate limiting API requests.
    
    Uses Redis to track request counts and enforce limits.
    """
    
    def __init__(
        self,
        app,
        default_limit: int = 100,
        default_window: int = 60,
        exclude_paths: Optional[list] = None,
    ):
        """
        Initialize the rate limiting middleware.
        
        Args:
            app: FastAPI application
            default_limit: Default rate limit (requests per window)
            default_window: Default time window in seconds
            exclude_paths: Paths to exclude from rate limiting
        """
        super().__init__(app)
        self.default_limit = default_limit
        self.default_window = default_window
        self.exclude_paths = exclude_paths or [
            "/health",
            "/ready",
            "/metrics",
            "/docs",
            "/redoc",
            "/openapi.json",
        ]
        self.cache = get_cache_service()
        self.rate_limiter = RateLimiter(self.cache)
    
    async def dispatch(self, request: Request, call_next):
        # Check if path should be excluded
        path = request.url.path
        if any(path.startswith(exclude) for exclude in self.exclude_paths):
            return await call_next(request)
        
        # Get client identifier (IP address or API key)
        client_id = self._get_client_id(request)
        
        # Get rate limit configuration for this path
        limit, window = self._get_rate_limit_for_path(path)
        
        # Create rate limit key
        key = f"rate_limit:{client_id}:{path}"
        
        # Check if allowed
        allowed = await self.rate_limiter.is_allowed(
            key=key,
            max_requests=limit,
            time_window=window,
        )
        
        if not allowed:
            raise TooManyRequestsException(
                detail=f"Rate limit exceeded. Maximum {limit} requests per {window} seconds.",
                error_code="RATE_LIMIT_EXCEEDED",
                data={
                    "limit": limit,
                    "window": window,
                    "retry_after": window,
                }
            )
        
        # Process the request
        response = await call_next(request)
        
        # Add rate limit headers
        response.headers["X-RateLimit-Limit"] = str(limit)
        response.headers["X-RateLimit-Window"] = str(window)
        
        return response
    
    def _get_client_id(self, request: Request) -> str:
        """
        Get client identifier for rate limiting.
        
        Args:
            request: FastAPI request
            
        Returns:
            str: Client identifier
        """
        # Try to get API key
        api_key = request.headers.get("X-API-Key")
        if api_key:
            return f"api_key:{api_key[:8]}"
        
        # Try to get user ID from request state
        if hasattr(request.state, "user_id"):
            return f"user:{request.state.user_id}"
        
        # Fall back to IP address
        client_ip = request.client.host if request.client else "unknown"
        return f"ip:{client_ip}"
    
    def _get_rate_limit_for_path(self, path: str) -> Tuple[int, int]:
        """
        Get rate limit configuration for a specific path.
        
        Args:
            path: Request path
            
        Returns:
            Tuple[int, int]: (limit, window) in seconds
        """
        # Define path-specific rate limits
        if path.startswith("/api/v1/auth/login"):
            return 10, 60  # 10 login attempts per minute
        elif path.startswith("/api/v1/auth/register"):
            return 5, 60   # 5 registration attempts per minute
        elif path.startswith("/api/v1/auth/reset-password"):
            return 3, 60   # 3 password reset attempts per minute
        elif path.startswith("/api/v1/tasks"):
            return 200, 60  # 200 task operations per minute
        elif path.startswith("/api/v1/users"):
            return 100, 60  # 100 user operations per minute
        elif path.startswith("/api/v1/projects"):
            return 100, 60  # 100 project operations per minute
        else:
            return self.default_limit, self.default_window
```

## Step 7: Performance Optimization

### The Target
Implement performance optimizations including connection pooling, response compression, and profiling.

### The Implementation

**Create `app/middleware/performance.py`:**

```python
"""
app/middleware/performance.py
Performance optimization middleware and utilities.
"""

from fastapi import Request, Response
from fastapi.middleware.base import BaseHTTPMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from typing import Optional
import time
import gzip
import logging
from datetime import datetime

logger = logging.getLogger(__name__)


class PerformanceMiddleware(BaseHTTPMiddleware):
    """
    Middleware for performance monitoring and optimization.
    """
    
    async def dispatch(self, request: Request, call_next):
        start_time = time.perf_counter()
        
        # Process request
        response = await call_next(request)
        
        # Calculate duration
        duration = time.perf_counter() - start_time
        
        # Add timing header
        response.headers["X-Response-Time"] = f"{duration:.3f}s"
        
        # Log slow requests
        if duration > 1.0:
            logger.warning(
                f"Slow request: {request.method} {request.url.path} took {duration:.2f}s",
                extra={
                    "method": request.method,
                    "path": request.url.path,
                    "duration": duration,
                    "status_code": response.status_code,
                }
            )
        
        return response


class CompressionMiddleware(BaseHTTPMiddleware):
    """
    Middleware for response compression.
    
    Compresses responses using gzip if client supports it.
    """
    
    def __init__(self, app, minimum_size: int = 1000):
        super().__init__(app)
        self.minimum_size = minimum_size
    
    async def dispatch(self, request: Request, call_next):
        # Check if client accepts gzip
        accept_encoding = request.headers.get("accept-encoding", "")
        if "gzip" not in accept_encoding.lower():
            return await call_next(request)
        
        # Process request
        response = await call_next(request)
        
        # Check if response should be compressed
        if (
            response.status_code >= 200 and
            response.status_code < 300 and
            len(response.body) >= self.minimum_size and
            "content-encoding" not in response.headers
        ):
            # Compress response
            compressed_body = gzip.compress(response.body)
            response.body = compressed_body
            response.headers["content-encoding"] = "gzip"
            response.headers["content-length"] = str(len(compressed_body))
        
        return response


class QueryOptimizationMiddleware(BaseHTTPMiddleware):
    """
    Middleware for query optimization logging.
    """
    
    async def dispatch(self, request: Request, call_next):
        # Check if request has pagination parameters
        if request.url.path.startswith("/api/v1"):
            # Log query parameters for optimization
            query_params = dict(request.query_params)
            if query_params:
                logger.debug(
                    f"Query parameters: {query_params}",
                    extra={
                        "path": request.url.path,
                        "params": query_params,
                    }
                )
        
        return await call_next(request)


# ────────────────────────────────────────────────────────────────
# Response Caching Middleware
# ────────────────────────────────────────────────────────────────

class ResponseCacheMiddleware(BaseHTTPMiddleware):
    """
    Middleware for caching HTTP responses.
    
    Caches GET requests using Redis.
    """
    
    def __init__(self, app, cache_service=None, ttl: int = 300):
        super().__init__(app)
        self.cache_service = cache_service
        self.ttl = ttl
        
        # Paths to cache
        self.cache_paths = [
            "/api/v1/tasks",
            "/api/v1/projects",
            "/api/v1/users",
        ]
    
    async def dispatch(self, request: Request, call_next):
        # Only cache GET requests
        if request.method != "GET":
            return await call_next(request)
        
        # Check if path should be cached
        path = request.url.path
        if not any(path.startswith(cache_path) for cache_path in self.cache_paths):
            return await call_next(request)
        
        # Generate cache key
        cache_key = f"response_cache:{request.url.path}{request.url.query}"
        
        # Try to get from cache
        if self.cache_service:
            cached_response = await self.cache_service.get(cache_key)
            if cached_response:
                # Return cached response
                return Response(
                    content=cached_response.get("body"),
                    status_code=cached_response.get("status_code"),
                    headers=cached_response.get("headers"),
                    media_type=cached_response.get("media_type"),
                )
        
        # Process request
        response = await call_next(request)
        
        # Cache successful responses
        if (
            response.status_code == 200 and
            self.cache_service and
            hasattr(response, "body")
        ):
            await self.cache_service.set(
                cache_key,
                {
                    "body": response.body,
                    "status_code": response.status_code,
                    "headers": dict(response.headers),
                    "media_type": response.media_type,
                },
                self.ttl
            )
        
        return response
```

## Step 8: Testing Advanced Features

### The Target
Write tests for WebSockets, Celery tasks, and rate limiting.

### The Implementation

**Create `tests/test_websocket.py`:**

```python
"""
tests/test_websocket.py
WebSocket tests.
"""

import pytest
from fastapi.testclient import TestClient
from websockets.sync.client import connect
import json
import asyncio

from app.main import app
from app.websocket.manager import manager


@pytest.mark.asyncio
async def test_websocket_connection():
    """
    Test WebSocket connection.
    """
    client = TestClient(app)
    
    with client.websocket_connect("/ws/1") as websocket:
        # Test connection message
        data = websocket.receive_json()
        assert data["type"] == "connection"
        assert data["status"] == "connected"
        assert data["user_id"] == 1


@pytest.mark.asyncio
async def test_websocket_ping_pong():
    """
    Test WebSocket ping-pong.
    """
    client = TestClient(app)
    
    with client.websocket_connect("/ws/1") as websocket:
        # Receive connection message
        websocket.receive_json()
        
        # Send ping
        websocket.send_json({"type": "ping"})
        
        # Receive pong
        data = websocket.receive_json()
        assert data["type"] == "pong"


@pytest.mark.asyncio
async def test_websocket_room():
    """
    Test WebSocket room functionality.
    """
    client = TestClient(app)
    
    with client.websocket_connect("/ws/1") as websocket1:
        with client.websocket_connect("/ws/2") as websocket2:
            # Receive connection messages
            websocket1.receive_json()
            websocket2.receive_json()
            
            # Join room
            websocket1.send_json({
                "type": "join_room",
                "room": "test_room"
            })
            data = websocket1.receive_json()
            assert data["type"] == "room_joined"
            assert data["room"] == "test_room"
            
            # Send message to room
            websocket1.send_json({
                "type": "message",
                "room": "test_room",
                "content": "Hello everyone!"
            })
            
            # User 2 should receive the message
            data = websocket2.receive_json()
            assert data["type"] == "room_message"
            assert data["content"] == "Hello everyone!"
            assert data["from"] == 1
```

**Create `tests/test_rate_limiting.py`:**

```python
"""
tests/test_rate_limiting.py
Rate limiting tests.
"""

import pytest
from fastapi.testclient import TestClient
import time

from app.main import app


def test_rate_limiting():
    """
    Test rate limiting functionality.
    """
    client = TestClient(app)
    
    # Make multiple requests quickly
    responses = []
    for _ in range(15):
        response = client.get("/api/v1/health/ping")
        responses.append(response.status_code)
    
    # Check that rate limiting was triggered
    # Some requests should return 429
    assert 429 in responses


def test_rate_limiting_headers():
    """
    Test rate limiting headers.
    """
    client = TestClient(app)
    
    response = client.get("/api/v1/tasks/")
    
    # Check rate limit headers
    assert "X-RateLimit-Limit" in response.headers
    assert "X-RateLimit-Window" in response.headers


@pytest.mark.asyncio
async def test_rate_limiting_by_ip():
    """
    Test rate limiting by IP address.
    """
    client1 = TestClient(app)
    client2 = TestClient(app)
    
    # Both clients should be rate limited separately
    for _ in range(60):
        response1 = client1.get("/api/v1/tasks/")
        response2 = client2.get("/api/v1/tasks/")
        
        # If one gets rate limited, the other should still work
        if response1.status_code == 429:
            assert response2.status_code != 429
            break
        if response2.status_code == 429:
            assert response1.status_code != 429
            break
```

## The Verification

Let's test our advanced features:

```bash
# 1. Start Redis
redis-server

# 2. Start Celery worker (in a new terminal)
celery -A app.core.celery_app worker --loglevel=info

# 3. Start Celery beat (for scheduled tasks, in another terminal)
celery -A app.core.celery_app beat --loglevel=info

# 4. Run the application
uvicorn app.main:app --reload

# 5. Test WebSocket connection using wscat
npm install -g wscat
wscat -c ws://localhost:8000/ws/1

# 6. Send messages via WebSocket
# Type: {"type": "ping"}
# Type: {"type": "join_room", "room": "project_1"}
# Type: {"type": "message", "room": "project_1", "content": "Hello team!"}

# 7. Test background task
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Test task with background notification",
    "description": "This will trigger a background notification"
  }'

# 8. Test rate limiting
for i in {1..20}; do
  curl -s -w "%{http_code}\n" http://localhost:8000/api/v1/tasks/ -o /dev/null
done

# 9. Test caching
time curl -X GET http://localhost:8000/api/v1/tasks/
# First request might take a moment, second request should be much faster
```

## Deep Dive: Celery Best Practices

### Task Design Patterns

```python
# app/tasks/patterns.py
from app.core.celery_app import celery_app
from typing import Optional
import json

# Chain tasks
@celery_app.task
def process_image(image_path: str) -> dict:
    """Process an image."""
    return {"processed": True, "path": image_path}

@celery_app.task
def generate_thumbnail(data: dict) -> dict:
    """Generate thumbnail from processed image."""
    data["thumbnail"] = f"thumb_{data['path']}"
    return data

@celery_app.task
def upload_to_s3(data: dict) -> dict:
    """Upload processed image to S3."""
    data["uploaded"] = True
    return data

# Chain them together
def process_image_pipeline(image_path: str):
    chain = process_image.s(image_path) | generate_thumbnail.s() | upload_to_s3.s()
    return chain.delay()

# Group tasks (run in parallel)
@celery_app.task
def send_notification(user_id: int, message: str):
    """Send notification to user."""
    return {"user": user_id, "status": "sent"}

def send_bulk_notifications(users: list, message: str):
    from celery import group
    tasks = [send_notification.s(user_id, message) for user_id in users]
    job = group(tasks)
    return job.apply_async()

# Retry on failure
@celery_app.task(bind=True, max_retries=3, default_retry_delay=60)
def call_external_api(self, url: str):
    import requests
    try:
        response = requests.get(url, timeout=10)
        return response.json()
    except Exception as e:
        self.retry(exc=e)
```

### Monitoring Celery

```bash
# Monitor with Flower
pip install flower
celery -A app.core.celery_app flower --port=5555

# Check task status
celery -A app.core.celery_app inspect active
celery -A app.core.celery_app inspect scheduled
celery -A app.core.celery_app inspect registered

# View logs
celery -A app.core.celery_app worker --loglevel=debug
```

## What We Accomplished

✅ Mastered async/await programming patterns
✅ Implemented FastAPI BackgroundTasks for immediate background work
✅ Set up Celery with Redis for distributed task queues
✅ Added comprehensive email and notification services
✅ Implemented Redis caching for performance optimization
✅ Added WebSocket endpoints for real-time communication
✅ Implemented rate limiting with sliding window algorithm
✅ Added performance monitoring and optimization middleware
✅ Created scheduled tasks for maintenance and notifications
✅ Wrote tests for WebSockets and rate limiting

## Key Takeaways

1. **Async Programming**: Use async/await to handle concurrent operations efficiently
2. **Background Tasks**: Use FastAPI BackgroundTasks for simple async work, Celery for complex distributed tasks
3. **Caching**: Redis caching dramatically improves performance for read-heavy operations
4. **WebSockets**: Enable real-time features that HTTP can't provide efficiently
5. **Rate Limiting**: Protect your API from abuse and ensure fair usage
6. **Celery**: Distribute task processing across multiple workers for scalability
7. **Performance**: Always monitor and optimize response times
8. **Monitoring**: Use tools like Flower to monitor Celery workers

## What's Next?

In **[Part 5: Testing, CI/CD & Production Deployment]** , we'll:
- Write comprehensive tests (unit, integration, E2E)
- Set up GitHub Actions for CI/CD pipelines
- Containerize with Docker (multi-stage builds)
- Configure Nginx as reverse proxy
- Deploy with Docker Compose for staging
- Set up monitoring with Prometheus and Grafana
- Implement logging and error tracking
- Prepare for production deployment
