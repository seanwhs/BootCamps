# APPENDIX S — Complete Performance Benchmark & Tuning Guide

## Systematic Performance Optimization for ScaleCart

---

## S.1 Introduction

This appendix provides a comprehensive performance benchmarking and tuning guide for the ScaleCart platform. It covers:

1. **Performance Metrics** – Key indicators to measure
2. **Benchmarking Methodology** – Systematic testing approach
3. **Baseline Measurements** – Expected performance targets
4. **Tuning Strategies** – Optimization techniques
5. **Load Testing** – Simulating production traffic
6. **Continuous Optimization** – Ongoing performance management

---

## S.2 Performance Metrics

### S.2.1 Key Performance Indicators

```yaml
# File: performance/metrics.yaml
key_performance_indicators:
  api_performance:
    latency:
      p50: "< 50ms"
      p95: "< 200ms"
      p99: "< 500ms"
      max: "< 2s"
    
    throughput:
      requests_per_second: "> 1000"
      concurrent_users: "> 100"
    
    error_rate:
      success_rate: "> 99.9%"
      5xx_errors: "< 0.1%"
      4xx_errors: "< 1%"
    
    availability:
      uptime: "> 99.95%"
      mttr: "< 30 minutes"

  database_performance:
    connections:
      active: "< 100"
      idle: "< 20"
      waiting: "< 5"
    
    queries:
      slow_queries: "< 10 per minute"
      average_query_time: "< 50ms"
      cache_hit_ratio: "> 90%"
    
    transactions:
      throughput: "> 500 TPS"
      rollback_rate: "< 1%"
    
    storage:
      growth_rate: "< 10% per month"
      fragmentation: "< 10%"

  cache_performance:
    hit_ratio: "> 90%"
    miss_ratio: "< 10%"
    memory_usage: "< 80%"
    eviction_rate: "< 100 per minute"
```

### S.2.2 Measurement Tools

```python
# File: performance/measurements.py
"""
Performance measurement utilities.
"""

import time
import asyncio
from dataclasses import dataclass
from typing import List, Dict, Any
import statistics

@dataclass
class PerformanceMetrics:
    """Performance metrics container."""
    p50: float
    p95: float
    p99: float
    p999: float
    min: float
    max: float
    mean: float
    std_dev: float
    count: int
    total: float

class PerformanceProfiler:
    """Performance profiling and measurement."""
    
    def __init__(self):
        self.results: List[float] = []
    
    def measure(self, func):
        """Decorator to measure function performance."""
        def wrapper(*args, **kwargs):
            start = time.perf_counter()
            result = func(*args, **kwargs)
            duration = time.perf_counter() - start
            self.results.append(duration)
            return result
        return wrapper
    
    async def measure_async(self, func):
        """Decorator for async functions."""
        async def wrapper(*args, **kwargs):
            start = time.perf_counter()
            result = await func(*args, **kwargs)
            duration = time.perf_counter() - start
            self.results.append(duration)
            return result
        return wrapper
    
    def get_metrics(self) -> PerformanceMetrics:
        """Calculate performance metrics."""
        if not self.results:
            return PerformanceMetrics(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        
        sorted_results = sorted(self.results)
        count = len(sorted_results)
        
        return PerformanceMetrics(
            p50=statistics.median(sorted_results),
            p95=sorted_results[int(count * 0.95)],
            p99=sorted_results[int(count * 0.99)],
            p999=sorted_results[int(count * 0.999)],
            min=min(self.results),
            max=max(self.results),
            mean=statistics.mean(self.results),
            std_dev=statistics.stdev(self.results) if count > 1 else 0,
            count=count,
            total=sum(self.results)
        )
    
    def format_report(self) -> str:
        """Format performance report."""
        metrics = self.get_metrics()
        return f"""
Performance Report:
====================
Total Samples:   {metrics.count}
Total Time:      {metrics.total:.4f}s
Mean:            {metrics.mean * 1000:.2f}ms
Std Dev:         {metrics.std_dev * 1000:.2f}ms
Min:             {metrics.min * 1000:.2f}ms
Max:             {metrics.max * 1000:.2f}ms
p50 (Median):    {metrics.p50 * 1000:.2f}ms
p95:             {metrics.p95 * 1000:.2f}ms
p99:             {metrics.p99 * 1000:.2f}ms
p99.9:           {metrics.p999 * 1000:.2f}ms
"""

# Usage example
profiler = PerformanceProfiler()

@profiler.measure
def process_order(customer_id: int, items: list):
    """Simulate order processing."""
    time.sleep(0.01)  # Simulate work
    return {"order_id": 123}

# After running multiple times
print(profiler.format_report())
```

---

## S.3 Benchmarking Methodology

### S.3.1 Systematic Benchmarking Process

```python
# File: performance/benchmark.py
"""
Systematic benchmark framework for ScaleCart.
"""

import asyncio
import time
import json
from typing import List, Dict, Any, Optional
from dataclasses import dataclass, field
import aiohttp
import statistics
from concurrent.futures import ThreadPoolExecutor

@dataclass
class BenchmarkResult:
    """Single benchmark result."""
    name: str
    timestamp: float
    duration: float
    success: bool
    error: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)

@dataclass
class BenchmarkSummary:
    """Summary of benchmark results."""
    name: str
    count: int
    success_count: int
    failure_count: int
    min_time: float
    max_time: float
    mean_time: float
    p50_time: float
    p95_time: float
    p99_time: float
    total_time: float
    throughput: float

class BenchmarkRunner:
    """Benchmark execution framework."""
    
    def __init__(self, name: str, warmup_iterations: int = 10):
        self.name = name
        self.warmup_iterations = warmup_iterations
        self.results: List[BenchmarkResult] = []
    
    async def run_benchmark(
        self,
        test_func,
        iterations: int = 1000,
        concurrency: int = 10
    ) -> BenchmarkSummary:
        """Run benchmark with specified parameters."""
        # Warmup
        for _ in range(self.warmup_iterations):
            await self._run_single(test_func, warmup=True)
        
        # Actual test
        start_time = time.time()
        tasks = []
        
        for i in range(iterations):
            tasks.append(self._run_single(test_func))
            if len(tasks) >= concurrency:
                await asyncio.gather(*tasks)
                tasks = []
        
        if tasks:
            await asyncio.gather(*tasks)
        
        end_time = time.time()
        
        return self._summarize(end_time - start_time)
    
    async def _run_single(self, func, warmup: bool = False):
        """Run single benchmark iteration."""
        start = time.perf_counter()
        try:
            result = await func()
            duration = time.perf_counter() - start
            if not warmup:
                self.results.append(
                    BenchmarkResult(
                        name=self.name,
                        timestamp=time.time(),
                        duration=duration,
                        success=True,
                        metadata={"result": result}
                    )
                )
        except Exception as e:
            duration = time.perf_counter() - start
            if not warmup:
                self.results.append(
                    BenchmarkResult(
                        name=self.name,
                        timestamp=time.time(),
                        duration=duration,
                        success=False,
                        error=str(e)
                    )
                )
    
    def _summarize(self, total_time: float) -> BenchmarkSummary:
        """Summarize benchmark results."""
        durations = [r.duration for r in self.results]
        success_count = sum(1 for r in self.results if r.success)
        failure_count = len(self.results) - success_count
        
        if durations:
            sorted_durations = sorted(durations)
            count = len(sorted_durations)
            return BenchmarkSummary(
                name=self.name,
                count=count,
                success_count=success_count,
                failure_count=failure_count,
                min_time=min(durations),
                max_time=max(durations),
                mean_time=statistics.mean(durations),
                p50_time=statistics.median(sorted_durations),
                p95_time=sorted_durations[int(count * 0.95)],
                p99_time=sorted_durations[int(count * 0.99)],
                total_time=total_time,
                throughput=count / total_time
            )
        else:
            return BenchmarkSummary(
                name=self.name,
                count=0,
                success_count=0,
                failure_count=0,
                min_time=0,
                max_time=0,
                mean_time=0,
                p50_time=0,
                p95_time=0,
                p99_time=0,
                total_time=0,
                throughput=0
            )
    
    def generate_report(self) -> str:
        """Generate human-readable report."""
        summary = self._summarize(0)
        return f"""
Benchmark Report: {self.name}
====================================
Total Runs:        {summary.count}
Successful:        {summary.success_count}
Failed:            {summary.failure_count}
Success Rate:      {(summary.success_count / summary.count * 100):.2f}%
Throughput:        {summary.throughput:.2f} req/s
Min Time:          {summary.min_time * 1000:.2f}ms
Max Time:          {summary.max_time * 1000:.2f}ms
Mean Time:         {summary.mean_time * 1000:.2f}ms
p50 (Median):      {summary.p50_time * 1000:.2f}ms
p95:               {summary.p95_time * 1000:.2f}ms
p99:               {summary.p99_time * 1000:.2f}ms
"""

# Example usage
async def test_api_endpoint():
    """Test API endpoint performance."""
    async with aiohttp.ClientSession() as session:
        async with session.get("http://localhost:8000/api/v1/products") as response:
            return await response.json()

async def run_benchmarks():
    runner = BenchmarkRunner("API-Products")
    summary = await runner.run_benchmark(test_api_endpoint, iterations=100, concurrency=10)
    print(runner.generate_report())

if __name__ == "__main__":
    asyncio.run(run_benchmarks())
```

---

## S.4 Baseline Performance Targets

### S.4.1 Expected Performance Baseline

```yaml
# File: performance/baseline.yaml
baseline_performance:
  api:
    products_endpoint:
      latency:
        p50: "20ms"
        p95: "50ms"
        p99: "100ms"
      throughput: "5000 req/s"
      concurrency: "200"
    
    order_endpoint:
      latency:
        p50: "100ms"
        p95: "300ms"
        p99: "500ms"
      throughput: "1000 req/s"
      concurrency: "100"
    
    auth_endpoint:
      latency:
        p50: "50ms"
        p95: "150ms"
        p99: "200ms"
      throughput: "2000 req/s"
      concurrency: "200"

  database:
    read_operations:
      simple_select: "< 1ms"
      complex_join: "< 10ms"
      full_text_search: "< 50ms"
    
    write_operations:
      insert: "< 5ms"
      update: "< 10ms"
      bulk_insert: "< 50ms per 1000 rows"
    
    index_performance:
      index_scan: "< 1ms"
      sequential_scan: "< 100ms per 1000 rows"

  cache:
    read_operations:
      hit: "< 0.5ms"
      miss: "< 1ms"
    
    write_operations:
      set: "< 1ms"
      delete: "< 1ms"
    
    hit_ratio: "> 95%"
```

### S.4.2 Performance Testing Script

```python
# File: performance/test_performance.py
"""
Performance testing script for ScaleCart.
"""

import asyncio
import aiohttp
import json
from typing import Dict, Any, List
from dataclasses import dataclass
import statistics
import time

@dataclass
class PerformanceTestResult:
    """Result of a performance test."""
    endpoint: str
    method: str
    total_requests: int
    successful_requests: int
    failed_requests: int
    min_time: float
    max_time: float
    mean_time: float
    p50_time: float
    p95_time: float
    p99_time: float
    throughput: float

class PerformanceTester:
    """Complete performance testing suite."""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.results: List[PerformanceTestResult] = []
    
    async def test_endpoint(
        self,
        path: str,
        method: str = "GET",
        data: Dict = None,
        iterations: int = 1000,
        concurrency: int = 50
    ) -> PerformanceTestResult:
        """Test a specific endpoint."""
        times = []
        success_count = 0
        
        async def make_request(session):
            nonlocal success_count
            start = time.perf_counter()
            try:
                if method == "GET":
                    async with session.get(f"{self.base_url}{path}") as response:
                        await response.text()
                else:
                    async with session.post(f"{self.base_url}{path}", json=data) as response:
                        await response.text()
                
                duration = time.perf_counter() - start
                times.append(duration)
                success_count += 1
            except Exception:
                times.append(time.perf_counter() - start)
        
        async with aiohttp.ClientSession() as session:
            tasks = []
            for i in range(iterations):
                tasks.append(make_request(session))
                if len(tasks) >= concurrency:
                    await asyncio.gather(*tasks)
                    tasks = []
            
            if tasks:
                await asyncio.gather(*tasks)
        
        # Calculate statistics
        sorted_times = sorted(times)
        count = len(times)
        total_time = sum(times)
        
        return PerformanceTestResult(
            endpoint=path,
            method=method,
            total_requests=count,
            successful_requests=success_count,
            failed_requests=count - success_count,
            min_time=min(times) if times else 0,
            max_time=max(times) if times else 0,
            mean_time=statistics.mean(times) if times else 0,
            p50_time=statistics.median(sorted_times) if times else 0,
            p95_time=sorted_times[int(count * 0.95)] if times else 0,
            p99_time=sorted_times[int(count * 0.99)] if times else 0,
            throughput=count / total_time if total_time > 0 else 0
        )
    
    async def run_full_suite(self):
        """Run complete performance test suite."""
        print("Running performance test suite...")
        print("=" * 50)
        
        # Test endpoints
        endpoints = [
            ("/api/v1/products?limit=10", "GET", None),
            ("/api/v1/products/1", "GET", None),
            ("/api/v1/products?search=laptop", "GET", None),
            ("/api/v1/orders?limit=10", "GET", None),
            ("/health", "GET", None),
            ("/health/full", "GET", None),
        ]
        
        for path, method, data in endpoints:
            print(f"\nTesting {method} {path}...")
            result = await self.test_endpoint(path, method, data, iterations=100, concurrency=20)
            self.results.append(result)
            
            # Print results
            print(f"  Requests: {result.total_requests}")
            print(f"  Success Rate: {(result.successful_requests / result.total_requests * 100):.2f}%")
            print(f"  Throughput: {result.throughput:.2f} req/s")
            print(f"  Mean: {result.mean_time * 1000:.2f}ms")
            print(f"  p95: {result.p95_time * 1000:.2f}ms")
            print(f"  p99: {result.p99_time * 1000:.2f}ms")
        
        # Summary
        print("\n" + "=" * 50)
        print("Performance Test Summary")
        print("=" * 50)
        
        # Throughput
        total_throughput = sum(r.throughput for r in self.results)
        avg_throughput = total_throughput / len(self.results)
        print(f"Average Throughput: {avg_throughput:.2f} req/s")
        print(f"Total Throughput: {total_throughput:.2f} req/s")
        
        # Success rates
        avg_success_rate = statistics.mean(
            r.successful_requests / r.total_requests * 100 for r in self.results
        )
        print(f"Average Success Rate: {avg_success_rate:.2f}%")
        
        # Latency
        avg_latency = statistics.mean(r.mean_time for r in self.results)
        print(f"Average Latency: {avg_latency * 1000:.2f}ms")
        
        print("\nDetailed Results:")
        for r in self.results:
            print(f"  {r.method} {r.endpoint}:")
            print(f"    p95: {r.p95_time * 1000:.2f}ms, Throughput: {r.throughput:.2f} req/s")

async def main():
    tester = PerformanceTester("http://localhost:8000")
    await tester.run_full_suite()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## S.5 Load Testing with Locust

### S.5.1 Locust Load Test Script

```python
# File: performance/locustfile.py
"""
Locust load testing for ScaleCart.
Run: locust -f performance/locustfile.py --host http://localhost:8000
"""

from locust import HttpUser, task, between, events
import random
import json
import time

class ScaleCartUser(HttpUser):
    """Simulated ScaleCart user for load testing."""
    
    wait_time = between(0.5, 2)
    
    def on_start(self):
        """Initialize user session."""
        self.customer_id = random.randint(1, 1000)
        self.token = None
        self.cart_items = []
        
        # Login
        response = self.client.post(
            "/api/v1/auth/login",
            json={
                "email": f"user{self.customer_id}@example.com",
                "password": "password123"
            }
        )
        if response.status_code == 200:
            self.token = response.json().get("access_token")
            self.headers = {"Authorization": f"Bearer {self.token}"}
    
    @task(3)
    def view_products(self):
        """View product catalog."""
        self.client.get(
            "/api/v1/products",
            headers=self.headers,
            params={"limit": 20, "page": random.randint(1, 5)}
        )
    
    @task(2)
    def view_product_details(self):
        """View product details."""
        product_id = random.randint(1, 100)
        self.client.get(
            f"/api/v1/products/{product_id}",
            headers=self.headers
        )
    
    @task(2)
    def search_products(self):
        """Search products."""
        search_terms = ["laptop", "phone", "book", "clothing", "electronics"]
        self.client.get(
            "/api/v1/products",
            headers=self.headers,
            params={"search": random.choice(search_terms)}
        )
    
    @task(1)
    def browse_categories(self):
        """Browse by category."""
        category_id = random.randint(1, 10)
        self.client.get(
            "/api/v1/products",
            headers=self.headers,
            params={"category_id": category_id}
        )
    
    @task(2)
    def add_to_cart(self):
        """Add product to cart."""
        product_id = random.randint(1, 100)
        response = self.client.post(
            "/api/v1/cart/items",
            headers=self.headers,
            json={
                "product_id": product_id,
                "quantity": random.randint(1, 3)
            }
        )
        if response.status_code == 200:
            self.cart_items.append(product_id)
    
    @task(1)
    def view_cart(self):
        """View shopping cart."""
        self.client.get("/api/v1/cart", headers=self.headers)
    
    @task(1)
    def place_order(self):
        """Place an order."""
        if len(self.cart_items) > 0:
            items = [
                {"product_id": pid, "quantity": random.randint(1, 2)}
                for pid in random.sample(self.cart_items, min(3, len(self.cart_items)))
            ]
            
            response = self.client.post(
                "/api/v1/orders",
                headers=self.headers,
                json={
                    "customer_id": self.customer_id,
                    "items": items,
                    "shipping_address_id": random.randint(1, 5),
                    "billing_address_id": random.randint(1, 5),
                    "payment_method": random.choice(["credit_card", "paypal"])
                }
            )
            
            if response.status_code == 201:
                # Clear cart after successful order
                self.client.delete("/api/v1/cart", headers=self.headers)
                self.cart_items = []
    
    @task(1)
    def leave_review(self):
        """Leave a product review."""
        product_id = random.randint(1, 100)
        self.client.post(
            f"/api/v1/products/{product_id}/reviews",
            headers=self.headers,
            json={
                "rating": random.randint(3, 5),
                "title": random.choice(["Great!", "Good", "Not bad", "Excellent"]),
                "comment": "This is a test review comment."
            }
        )
    
    @task(0.5)
    def view_order_history(self):
        """View order history."""
        self.client.get(
            "/api/v1/orders",
            headers=self.headers,
            params={"limit": 10, "page": 1}
        )
    
    @task(0.2)
    def get_order_details(self):
        """View specific order details."""
        order_id = random.randint(1, 500)
        self.client.get(
            f"/api/v1/orders/{order_id}",
            headers=self.headers
        )

@events.init_command_line_parser.add_listener
def _(parser):
    """Add custom command line options."""
    parser.add_argument("--test-data", type=str, help="Path to test data file")

@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Setup before test starts."""
    print("Load test starting...")
    
    # Load test data if provided
    if environment.parsed_options.test_data:
        with open(environment.parsed_options.test_data, 'r') as f:
            data = json.load(f)
            print(f"Loaded {len(data)} test records")

@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Cleanup after test finishes."""
    print("Load test finished")
    
    # Print statistics
    stats = environment.runner.stats
    print(f"Total requests: {stats.total.num_requests}")
    print(f"Total failures: {stats.total.num_failures}")
    print(f"Average response time: {stats.total.avg_response_time:.2f}ms")
```

---

## S.6 Tuning Strategies

### S.6.1 Database Query Optimization

```sql
-- ============================================
-- QUERY OPTIMIZATION TECHNIQUES
-- ============================================

-- 1. Use EXPLAIN ANALYZE to understand query plans
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT p.id, p.name, p.price, c.name as category
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.price BETWEEN 100 AND 1000
  AND p.created_at > '2025-01-01'
ORDER BY p.price DESC
LIMIT 100;

-- 2. Create covering indexes
CREATE INDEX CONCURRENTLY idx_products_covering ON products(category_id) 
INCLUDE (name, price);

-- 3. Use partial indexes for common filters
CREATE INDEX CONCURRENTLY idx_products_active ON products(id) 
WHERE is_active = true AND price > 0;

-- 4. Use expression indexes
CREATE INDEX CONCURRENTLY idx_products_name_lower ON products(LOWER(name));

-- 5. Partition large tables
CREATE TABLE orders_partitioned PARTITION OF orders 
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- 6. Use CTEs for complex queries
WITH category_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price
    FROM products
    WHERE is_active = true
    GROUP BY category_id
)
SELECT 
    c.name,
    cs.product_count,
    cs.avg_price
FROM categories c
JOIN category_stats cs ON c.id = cs.category_id
WHERE cs.product_count > 10
ORDER BY cs.avg_price DESC;

-- 7. Use materialized views for expensive aggregations
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    DATE(order_date) as sale_date,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM orders
WHERE status IN ('paid', 'shipped', 'delivered')
GROUP BY DATE(order_date)
WITH DATA;

REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_summary;

-- 8. Update statistics
ANALYZE products;
ANALYZE orders;
ANALYZE customers;
```

### S.6.2 Application Optimization

```python
# File: src/utils/optimization.py
"""
Application-level optimization techniques.
"""

import functools
from typing import Any, Callable
from asyncio import Semaphore
import redis
import json
from src.utils.cache import RedisCache

class OptimizationTechniques:
    """Application optimization techniques."""
    
    @staticmethod
    def cache_result(ttl: int = 300):
        """Cache function results."""
        def decorator(func):
            @functools.wraps(func)
            async def wrapper(*args, **kwargs):
                # Generate cache key
                key = f"{func.__name__}:{args}:{kwargs}"
                cache = RedisCache()
                
                # Try cache
                cached = await cache.get(key)
                if cached is not None:
                    return json.loads(cached)
                
                # Execute function
                result = await func(*args, **kwargs)
                
                # Store in cache
                await cache.set(key, json.dumps(result), ttl)
                
                return result
            return wrapper
        return decorator
    
    @staticmethod
    def rate_limit(limit: int, window: int):
        """Rate limiting decorator."""
        def decorator(func):
            redis_client = redis.Redis()
            
            @functools.wraps(func)
            async def wrapper(*args, **kwargs):
                # Get client identifier
                key = f"rate_limit:{func.__name__}"
                
                # Check current count
                current = redis_client.get(key)
                if current and int(current) >= limit:
                    raise Exception("Rate limit exceeded")
                
                # Increment and set TTL
                pipe = redis_client.pipeline()
                pipe.incr(key)
                pipe.expire(key, window)
                pipe.execute()
                
                return await func(*args, **kwargs)
            return wrapper
        return decorator
    
    @staticmethod
    def async_batch(limit: int = 100):
        """Batch async operations."""
        def decorator(func):
            @functools.wraps(func)
            async def wrapper(items, *args, **kwargs):
                semaphore = Semaphore(limit)
                
                async def process_item(item):
                    async with semaphore:
                        return await func(item, *args, **kwargs)
                
                # Process in parallel with limit
                tasks = [process_item(item) for item in items]
                return await asyncio.gather(*tasks)
            return wrapper
        return decorator
    
    @staticmethod
    def connection_pool(func):
        """Use connection pool for database operations."""
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            pool = await get_connection_pool()
            async with pool.acquire() as connection:
                return await func(connection, *args, **kwargs)
        return wrapper
    
    @staticmethod
    def circuit_breaker(failure_threshold: int = 5, recovery_timeout: int = 60):
        """Circuit breaker pattern."""
        def decorator(func):
            state = {"failures": 0, "last_failure": 0}
            
            @functools.wraps(func)
            async def wrapper(*args, **kwargs):
                # Check if circuit is open
                if state["failures"] >= failure_threshold:
                    if time.time() - state["last_failure"] < recovery_timeout:
                        raise Exception("Circuit breaker open")
                    else:
                        # Reset after timeout
                        state["failures"] = 0
                
                try:
                    result = await func(*args, **kwargs)
                    # Reset on success
                    state["failures"] = 0
                    return result
                except Exception as e:
                    state["failures"] += 1
                    state["last_failure"] = time.time()
                    raise e
            return wrapper
        return decorator
```

---

## S.7 Performance Tuning Checklist

```markdown
# Performance Tuning Checklist

## Database Tuning
- [ ] Analyze query execution plans with EXPLAIN ANALYZE
- [ ] Create missing indexes
- [ ] Remove unused indexes
- [ ] Update statistics (ANALYZE)
- [ ] Vacuum tables
- [ ] Optimize query structure
- [ ] Use table partitioning for large tables
- [ ] Configure connection pooling
- [ ] Enable query caching
- [ ] Use materialized views for aggregations

## Application Tuning
- [ ] Implement caching strategy
- [ ] Use connection pooling
- [ ] Optimize database queries
- [ ] Implement pagination
- [ ] Use batch operations
- [ ] Enable compression
- [ ] Configure timeouts appropriately
- [ ] Use async/await for I/O operations
- [ ] Implement circuit breaker pattern
- [ ] Profile and optimize code

## Infrastructure Tuning
- [ ] Right-size instances
- [ ] Use SSDs for databases
- [ ] Configure load balancer
- [ ] Set up auto-scaling
- [ ] Use CDN for static assets
- [ ] Configure DNS caching
- [ ] Monitor resource usage
- [ ] Optimize container resources

## Monitoring Tuning
- [ ] Set up performance monitoring
- [ ] Configure alerting
- [ ] Track key performance indicators
- [ ] Monitor slow queries
- [ ] Track error rates
- [ ] Monitor cache hit rates
- [ ] Track resource utilization
```

---

## S.8 Performance Monitoring Dashboard

```json
{
  "dashboard": {
    "title": "ScaleCart Performance Monitoring",
    "panels": [
      {
        "title": "API Response Time (p95)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint))",
            "legendFormat": "{{endpoint}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "alert": {
          "conditions": [
            {
              "type": "query",
              "query": {"params": ["A", "5m", "now"]},
              "evaluator": {"type": "gt", "params": [1]},
              "operator": {"type": "and"}
            }
          ],
          "notifications": [
            {"uid": "slack"}
          ]
        }
      },
      {
        "title": "Database Query Time",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(pg_stat_database_blks_hit[5m]) / rate(pg_stat_database_blks_read[5m])",
            "legendFormat": "Cache Hit Ratio"
          },
          {
            "expr": "rate(pg_stat_statements_mean_time[5m])",
            "legendFormat": "Average Query Time"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "title": "Throughput",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[1m]))",
            "legendFormat": "req/s"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 0, "y": 8}
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "(sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m]))) * 100",
            "legendFormat": "Error %"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 4, "y": 8}
      },
      {
        "title": "Cache Hit Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "(redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total)) * 100",
            "legendFormat": "Hit %"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 8, "y": 8}
      },
      {
        "title": "Slow Queries",
        "type": "table",
        "targets": [
          {
            "expr": "topk(10, pg_stat_statements_mean_time)",
            "legendFormat": "{{query}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 12}
      },
      {
        "title": "Resource Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "container_cpu_usage_seconds_total",
            "legendFormat": "CPU"
          },
          {
            "expr": "container_memory_usage_bytes",
            "legendFormat": "Memory"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 12}
      }
    ]
  }
}
```

---

## S.9 Performance Optimization Cheat Sheet

### S.9.1 Quick Optimization Commands

```bash
# ============================================
# DATABASE OPTIMIZATION
# ============================================

# Analyze query plan
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT * FROM products WHERE price > 100;

# Find slow queries
SELECT query, calls, total_time, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;

# Create index
CREATE INDEX CONCURRENTLY idx_products_price ON products(price);

# Vacuum table
VACUUM ANALYZE products;

# Check table bloat
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size, n_dead_tup, n_live_tup FROM pg_stat_user_tables WHERE n_dead_tup > 1000 ORDER BY n_dead_tup DESC;

# ============================================
# CACHE OPTIMIZATION
# ============================================

# Check Redis memory
redis-cli INFO memory

# Check cache hit rate
redis-cli INFO stats | grep keyspace

# Clear cache
redis-cli FLUSHDB

# Monitor commands
redis-cli MONITOR

# ============================================
# APPLICATION OPTIMIZATION
# ============================================

# Profile Python code
python -m cProfile -o output.prof src/api/app.py

# Analyze profiling data
snakeviz output.prof

# Check connection pool
python -c "from src.utils.connection_pool import ConnectionPoolManager; print(ConnectionPoolManager.get_postgres_pool().stats())"

# ============================================
# INFRASTRUCTURE OPTIMIZATION
# ============================================

# Check CPU usage
top -bn1 | grep "Cpu(s)"

# Check memory usage
free -h

# Check disk I/O
iostat -x 1

# Check network
netstat -i
```

---

**[END OF APPENDIX S]**

*This comprehensive performance tuning guide provides everything needed to benchmark, measure, and optimize the ScaleCart platform for maximum performance.*
