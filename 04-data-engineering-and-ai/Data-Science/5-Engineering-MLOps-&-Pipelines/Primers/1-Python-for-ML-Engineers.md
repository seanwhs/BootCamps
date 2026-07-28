# Primer 1: Python for ML Engineers - Essential Concepts

## The Target: Foundational Python Knowledge for MLOps

This primer provides essential Python concepts specifically tailored for ML engineers and data scientists transitioning to production-grade MLOps. It covers the most critical Python patterns, practices, and concepts used throughout the series.

## The Concept: Production-Ready Python

Think of this like learning to cook professionally vs. cooking at home:
- **Scripting (Home Cooking)** = Works for personal use, flexible, forgiving
- **Production Code (Professional Kitchen)** = Standardized, tested, scalable, maintainable

This primer bridges the gap between "it works on my machine" and "it works in production."

---

## 1. Python Environment Management

### Virtual Environments

**Why:** Isolate project dependencies to avoid conflicts.

```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# Verify
which python  # Should point to venv
python -c "import sys; print(sys.executable)"
```

### Requirements Management

**Why:** Reproducible dependencies for all environments.

```bash
# Generate requirements
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt

# Install with specific versions
pip install numpy==1.24.3 pandas==2.0.3

# Check for outdated packages
pip list --outdated
```

### Project Structure

**Why:** Organization enables collaboration and maintainability.

```
project/
├── src/           # Source code (importable)
│   ├── __init__.py
│   ├── data/
│   ├── features/
│   └── utils/
├── tests/         # Test files
├── scripts/       # Executable scripts
├── configs/       # Configuration files
├── data/          # Data files (gitignored)
├── models/        # Model artifacts
├── logs/          # Log files
├── requirements.txt
├── setup.py       # Package setup
└── README.md
```

---

## 2. Type Hints and Type Safety

**Why:** Catches bugs early, improves IDE support, documents intent.

### Basic Type Hints

```python
from typing import List, Dict, Optional, Union, Tuple, Any

# Simple types
def greet(name: str) -> str:
    return f"Hello, {name}"

# Collections
def process_list(items: List[int]) -> List[int]:
    return [x * 2 for x in items]

# Dictionaries
def get_config() -> Dict[str, Union[str, int, bool]]:
    return {"name": "pipeline", "version": 1.0, "enabled": True}

# Optional (can be None)
def find_user(user_id: int) -> Optional[Dict[str, str]]:
    if user_id in users:
        return users[user_id]
    return None

# Union (multiple types)
def process_value(value: Union[int, float, str]) -> float:
    if isinstance(value, (int, float)):
        return float(value)
    return float(len(value))

# Tuple (fixed length)
def get_coordinates() -> Tuple[float, float]:
    return (42.0, -73.0)

# Any (unknown type - use sparingly)
def handle_any(data: Any) -> str:
    return str(data)
```

### Advanced Type Hints

```python
from typing import TypeVar, Callable, Generic, Protocol
from dataclasses import dataclass

# Type variables (generics)
T = TypeVar('T')

def first_element(items: List[T]) -> Optional[T]:
    return items[0] if items else None

# Callable (function types)
def apply_function(func: Callable[[int, int], int], x: int, y: int) -> int:
    return func(x, y)

# Dataclasses (structured data)
@dataclass
class ModelMetrics:
    accuracy: float
    precision: float
    recall: float
    f1: float
    
    def summary(self) -> str:
        return f"F1: {self.f1:.4f}, Acc: {self.accuracy:.4f}"

# Protocols (structural typing)
class HasName(Protocol):
    name: str

def greet_by_name(obj: HasName) -> str:
    return f"Hello, {obj.name}"
```

### Type Checking with mypy

```bash
# Install mypy
pip install mypy

# Run type checking
mypy src/
mypy src/ --strict
mypy src/ --ignore-missing-imports

# Configuration (mypy.ini)
cat > mypy.ini << 'EOF'
[mypy]
python_version = 3.10
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_any_unimported = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True
EOF
```

---

## 3. Context Managers

**Why:** Automatic resource management (files, connections, sessions).

### Using Context Managers

```python
# File handling (automatic close)
with open('file.txt', 'r') as f:
    content = f.read()
# File is automatically closed

# Database connections
import sqlite3
with sqlite3.connect('database.db') as conn:
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users')
    # Connection auto-commits and closes

# Custom context manager
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    import time
    start = time.time()
    try:
        yield
    finally:
        elapsed = time.time() - start
        print(f"{name} took {elapsed:.2f}s")

# Usage
with timer("data_processing"):
    process_data()

# Creating a context manager class
class ManagedResource:
    def __enter__(self):
        print("Acquiring resource...")
        self.resource = acquire()
        return self.resource
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print("Releasing resource...")
        release(self.resource)

# Usage
with ManagedResource() as resource:
    use(resource)
```

---

## 4. Decorators

**Why:** Clean code reuse and functional composition.

### Basic Decorators

```python
import functools
import time
from typing import Callable, Any

# Simple decorator
def timer_decorator(func: Callable) -> Callable:
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result
    return wrapper

@timer_decorator
def expensive_function():
    time.sleep(1)
    return "done"

# Decorator with arguments
def retry(max_attempts: int = 3, delay: int = 1):
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    time.sleep(delay * (attempt + 1))
            return None
        return wrapper
    return decorator

@retry(max_attempts=3, delay=2)
def unreliable_function():
    import random
    if random.random() < 0.5:
        raise ValueError("Random failure")
    return "success"

# Class-based decorator
class LogCall:
    def __init__(self, func: Callable):
        self.func = func
        functools.update_wrapper(self, func)
    
    def __call__(self, *args, **kwargs):
        print(f"Calling {self.func.__name__} with {args}")
        result = self.func(*args, **kwargs)
        print(f"Returned: {result}")
        return result
```

### Decorator Examples in MLOps

```python
# MLflow tracking decorator
def mlflow_run(func: Callable) -> Callable:
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        import mlflow
        with mlflow.start_run():
            return func(*args, **kwargs)
    return wrapper

# Data validation decorator
def validate_data(schema: dict):
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            result = func(*args, **kwargs)
            validate_against_schema(result, schema)
            return result
        return wrapper
    return decorator
```

---

## 5. Object-Oriented Programming Patterns

### Dataclasses

```python
from dataclasses import dataclass, field, asdict
from datetime import datetime
from typing import List, Optional

@dataclass
class Experiment:
    name: str
    params: dict
    metrics: dict = field(default_factory=dict)
    created_at: datetime = field(default_factory=datetime.now)
    tags: List[str] = field(default_factory=list)
    
    def add_metric(self, key: str, value: float):
        self.metrics[key] = value
    
    def to_dict(self):
        return asdict(self)

# Usage
exp = Experiment(
    name="model_v1",
    params={"learning_rate": 0.01, "batch_size": 32}
)
exp.add_metric("accuracy", 0.95)
print(exp.to_dict())
```

### Abstract Base Classes

```python
from abc import ABC, abstractmethod
from typing import Any, Dict, Optional

class BaseModel(ABC):
    """Abstract base class for all models."""
    
    def __init__(self, name: str):
        self.name = name
        self._metrics = {}
    
    @abstractmethod
    def train(self, X: Any, y: Any) -> None:
        """Train the model."""
        pass
    
    @abstractmethod
    def predict(self, X: Any) -> Any:
        """Make predictions."""
        pass
    
    @abstractmethod
    def evaluate(self, X: Any, y: Any) -> Dict[str, float]:
        """Evaluate model performance."""
        pass
    
    def log_metric(self, key: str, value: float) -> None:
        self._metrics[key] = value
    
    def get_metrics(self) -> Dict[str, float]:
        return self._metrics.copy()

class SklearnModel(BaseModel):
    """Concrete implementation using scikit-learn."""
    
    def __init__(self, name: str, model):
        super().__init__(name)
        self.model = model
    
    def train(self, X: Any, y: Any) -> None:
        self.model.fit(X, y)
    
    def predict(self, X: Any) -> Any:
        return self.model.predict(X)
    
    def evaluate(self, X: Any, y: Any) -> Dict[str, float]:
        from sklearn.metrics import accuracy_score, f1_score
        y_pred = self.predict(X)
        metrics = {
            'accuracy': accuracy_score(y, y_pred),
            'f1': f1_score(y, y_pred)
        }
        self._metrics.update(metrics)
        return metrics
```

### Singleton Pattern

```python
class RegistryManager:
    """Singleton for managing model registry."""
    
    _instance = None
    _initialized = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not self._initialized:
            self.models = {}
            self._initialized = True
    
    def register_model(self, name: str, model):
        self.models[name] = model
    
    def get_model(self, name: str):
        return self.models.get(name)

# Usage - both references are the same instance
registry1 = RegistryManager()
registry2 = RegistryManager()
assert registry1 is registry2  # True
```

### Factory Pattern

```python
class ModelFactory:
    """Factory for creating different model types."""
    
    @staticmethod
    def create_model(model_type: str, **kwargs):
        if model_type == 'random_forest':
            from sklearn.ensemble import RandomForestClassifier
            return RandomForestClassifier(**kwargs)
        elif model_type == 'gradient_boosting':
            from sklearn.ensemble import GradientBoostingClassifier
            return GradientBoostingClassifier(**kwargs)
        elif model_type == 'logistic_regression':
            from sklearn.linear_model import LogisticRegression
            return LogisticRegression(**kwargs)
        else:
            raise ValueError(f"Unknown model type: {model_type}")

# Usage
model = ModelFactory.create_model(
    'random_forest',
    n_estimators=100,
    max_depth=10
)
```

---

## 6. Error Handling and Logging

### Exception Handling

```python
import logging
import traceback

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Custom exceptions
class DataValidationError(Exception):
    """Raised when data validation fails."""
    pass

class ModelTrainingError(Exception):
    """Raised when model training fails."""
    pass

# Proper error handling
def process_data(data):
    try:
        # Validate data
        if not data:
            raise DataValidationError("Empty data provided")
        
        # Process data
        result = validate_and_process(data)
        
    except DataValidationError as e:
        logger.error(f"Validation failed: {e}")
        logger.debug(traceback.format_exc())
        raise
    except Exception as e:
        logger.critical(f"Unexpected error: {e}")
        logger.debug(traceback.format_exc())
        raise ModelTrainingError(f"Processing failed: {e}") from e
    else:
        logger.info("Data processed successfully")
        return result
    finally:
        logger.info("Data processing completed")
```

### Logging Best Practices

```python
import logging
from logging.handlers import RotatingFileHandler

def setup_logging():
    # Create logger
    logger = logging.getLogger('mlops')
    logger.setLevel(logging.DEBUG)
    
    # Create formatters
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    detailed_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(message)s'
    )
    
    # Console handler
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    console.setFormatter(formatter)
    logger.addHandler(console)
    
    # File handler with rotation
    file_handler = RotatingFileHandler(
        'logs/mlops.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(detailed_formatter)
    logger.addHandler(file_handler)
    
    return logger

# Usage
logger = setup_logging()

# Different log levels
logger.debug("Detailed debugging information")
logger.info("General information")
logger.warning("Warning message")
logger.error("Error occurred")
logger.critical("Critical failure")

# Structured logging
logger.info(
    "Training completed",
    extra={
        'model_type': 'random_forest',
        'accuracy': 0.95,
        'training_time': 120.5
    }
)
```

---

## 7. File I/O and Serialization

### JSON

```python
import json
from pathlib import Path

# Write JSON
data = {"name": "model", "version": 1.0, "metrics": {"accuracy": 0.95}}

with open("config.json", "w") as f:
    json.dump(data, f, indent=2)

# Read JSON
with open("config.json", "r") as f:
    loaded = json.load(f)

# JSON with custom objects
class ModelConfig:
    def __init__(self, name, version):
        self.name = name
        self.version = version

def encode_config(obj):
    if isinstance(obj, ModelConfig):
        return {"__class__": "ModelConfig", "name": obj.name, "version": obj.version}
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")

def decode_config(obj):
    if obj.get("__class__") == "ModelConfig":
        return ModelConfig(obj["name"], obj["version"])
    return obj

config = ModelConfig("rf_model", 1.0)
json_str = json.dumps(config, default=encode_config)
loaded = json.loads(json_str, object_hook=decode_config)
```

### YAML

```python
import yaml

# Write YAML
config = {
    'model': {
        'type': 'random_forest',
        'parameters': {
            'n_estimators': 100,
            'max_depth': 10
        }
    },
    'data': {
        'path': 'data/raw/',
        'test_size': 0.2
    }
}

with open('config.yaml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False)

# Read YAML
with open('config.yaml', 'r') as f:
    loaded = yaml.safe_load(f)
```

### Pickle (Model Serialization)

```python
import pickle

# Save model
with open('model.pkl', 'wb') as f:
    pickle.dump(model, f)

# Load model
with open('model.pkl', 'rb') as f:
    model = pickle.load(f)

# Save multiple objects
with open('artifacts.pkl', 'wb') as f:
    pickle.dump({
        'model': model,
        'scaler': scaler,
        'feature_names': feature_names
    }, f)

# Load multiple objects
with open('artifacts.pkl', 'rb') as f:
    artifacts = pickle.load(f)
    model = artifacts['model']
    scaler = artifacts['scaler']
```

### CSV and Parquet

```python
import pandas as pd

# CSV
df = pd.read_csv('data.csv')
df.to_csv('output.csv', index=False)

# Parquet (faster, compressed)
df.to_parquet('data.parquet', index=False)
df = pd.read_parquet('data.parquet')

# Read large CSV in chunks
for chunk in pd.read_csv('large_file.csv', chunksize=10000):
    process_chunk(chunk)
```

---

## 8. Path Handling

```python
from pathlib import Path
import os

# Creating paths
project_root = Path(__file__).parent.parent
data_dir = project_root / "data" / "raw"
data_dir.mkdir(parents=True, exist_ok=True)

# File operations
file_path = data_dir / "sensor_data.csv"

if file_path.exists():
    print(f"File exists: {file_path}")
    print(f"Size: {file_path.stat().st_size} bytes")
    print(f"Modified: {file_path.stat().st_mtime}")

# Finding files
for csv_file in data_dir.glob("*.csv"):
    print(csv_file)

# Relative paths
relative_path = Path("data/raw/sensor_data.csv")
absolute_path = relative_path.absolute()
parent_dir = relative_path.parent
file_name = relative_path.name
stem = relative_path.stem  # Without extension
suffix = relative_path.suffix  # Extension
```

---

## 9. Python Standard Library Essentials

### collections

```python
from collections import defaultdict, Counter, deque, namedtuple

# defaultdict
counter = defaultdict(int)
counter['a'] += 1
counter['b'] += 1

# Counter
counts = Counter(['a', 'b', 'a', 'c', 'a', 'b'])
print(counts)  # Counter({'a': 3, 'b': 2, 'c': 1})

# deque (fast appends/pops at both ends)
queue = deque([1, 2, 3])
queue.append(4)
queue.appendleft(0)
queue.popleft()

# namedtuple
Point = namedtuple('Point', ['x', 'y'])
p = Point(10, 20)
print(p.x, p.y)
```

### itertools

```python
import itertools

# Chain
list(itertools.chain([1, 2], [3, 4]))  # [1, 2, 3, 4]

# Product
list(itertools.product([1, 2], ['a', 'b']))  # [(1, 'a'), (1, 'b'), ...]

# Combinations
list(itertools.combinations([1, 2, 3], 2))  # [(1, 2), (1, 3), (2, 3)]

# Permutations
list(itertools.permutations([1, 2, 3], 2))

# Group by
data = [('a', 1), ('a', 2), ('b', 3)]
for key, group in itertools.groupby(data, lambda x: x[0]):
    print(key, list(group))

# Infinite iterators
counter = itertools.count(start=10, step=2)
cycler = itertools.cycle([1, 2, 3])
```

### functools

```python
from functools import partial, reduce, lru_cache

# Partial (fix arguments)
def power(base, exponent):
    return base ** exponent

square = partial(power, exponent=2)
cube = partial(power, exponent=3)
print(square(5))  # 25

# Reduce
sum_all = reduce(lambda a, b: a + b, [1, 2, 3, 4])  # 10

# Cache (memoization)
@lru_cache(maxsize=128)
def expensive_function(n):
    # Expensive computation
    return n * n

# Cache will store results
expensive_function(10)  # Computed
expensive_function(10)  # Retrieved from cache
```

---

## 10. Performance Optimization

### List Comprehensions

```python
# Faster than loops
squares = [x**2 for x in range(100)]
filtered = [x for x in range(100) if x % 2 == 0]
```

### Generators

```python
# Memory efficient
def generate_large_data():
    for i in range(1000000):
        yield i

# Use generator
for item in generate_large_data():
    process(item)

# Generator expression
sum_squares = sum(x**2 for x in range(1000000))
```

### Profiling

```python
import cProfile
import pstats

# Profile code
def profile_code():
    import time
    time.sleep(1)

cProfile.run('profile_code()', 'profile.stats')

# Analyze profile
stats = pstats.Stats('profile.stats')
stats.sort_stats('cumulative').print_stats(10)
stats.sort_stats('time').print_stats(10)

# Using profile decorator
def profile(func):
    def wrapper(*args, **kwargs):
        import cProfile
        profiler = cProfile.Profile()
        try:
            result = profiler.runcall(func, *args, **kwargs)
        finally:
            profiler.dump_stats(f"{func.__name__}.profile")
        return result
    return wrapper

@profile
def my_function():
    time.sleep(2)
```

---

## Quick Reference: Common Python Patterns

| Pattern | When to Use | Example |
|---------|-------------|---------|
| Context Manager | Resource cleanup | `with open(...) as f:` |
| Decorator | Cross-cutting concerns | `@timer`, `@retry` |
| Dataclass | Data containers | `@dataclass class Model:` |
| Type Hints | Code documentation | `def func(x: int) -> str:` |
| Factory Pattern | Object creation | `ModelFactory.create()` |
| Singleton | Single instance | `RegistryManager()` |
| Generator | Memory efficiency | `def generator(): yield` |
| List Comprehension | Fast list creation | `[x**2 for x in range(n)]` |
| Exception Handling | Error management | `try/except/finally` |
| Logging | Debugging/monitoring | `logger.info(...)` |

---

*End of Primer 1: Python for ML Engineers - Essential Concepts*
