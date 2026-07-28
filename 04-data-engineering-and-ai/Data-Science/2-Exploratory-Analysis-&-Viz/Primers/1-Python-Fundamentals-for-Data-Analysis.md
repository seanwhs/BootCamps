# Primer 1: Python Fundamentals for Data Analysis

## Essential Python Concepts for Working Through This Series

---

#### Purpose of This Primer

This primer is designed for readers who have some Python experience but need a refresher on the specific concepts and patterns used extensively throughout this series. If you find yourself confused by certain code patterns or want to understand the "why" behind common data analysis idioms, this primer is for you.

Think of this as your Python data analysis survival guide—the essential concepts you need to understand before diving into the main content.

---

## P1.1 Python Basics Review

### P1.1.1 Variables and Data Types

```python
# Numbers
integer = 42
float_number = 3.14159
complex_number = 3 + 4j

# Strings
string = "Hello, World!"
multiline = """This is a
multiline string"""

# Lists (mutable, ordered)
my_list = [1, 2, 3, 4, 5]
my_list.append(6)  # [1, 2, 3, 4, 5, 6]
my_list[0] = 10   # [10, 2, 3, 4, 5, 6]

# Tuples (immutable, ordered)
my_tuple = (1, 2, 3)
# my_tuple[0] = 10  # ❌ TypeError: 'tuple' object does not support item assignment

# Dictionaries (key-value pairs)
my_dict = {'name': 'Alice', 'age': 30, 'city': 'New York'}
my_dict['email'] = 'alice@example.com'  # Add new key-value pair

# Sets (unique, unordered)
my_set = {1, 2, 3, 4, 5}
my_set.add(5)  # No change (5 already exists)
my_set.add(6)  # {1, 2, 3, 4, 5, 6}

# Booleans
is_true = True
is_false = False

# None (null)
nothing = None
```

### P1.1.2 Type Checking and Conversion

```python
# Check type
x = 42
print(type(x))  # <class 'int'>

# Type conversion
int("42")        # 42
float("3.14")    # 3.14
str(42)          # "42"
list("abc")      # ['a', 'b', 'c']
tuple([1, 2, 3]) # (1, 2, 3)

# Safe conversion with error handling
def safe_int(value, default=0):
    try:
        return int(value)
    except (ValueError, TypeError):
        return default

safe_int("42")    # 42
safe_int("hello") # 0
safe_int(None)    # 0
```

### P1.1.3 Control Flow

```python
# If-elif-else
age = 25

if age < 18:
    print("Minor")
elif age < 65:
    print("Adult")
else:
    print("Senior")

# For loops
for i in range(5):  # 0, 1, 2, 3, 4
    print(i)

for item in ['a', 'b', 'c']:
    print(item)

for key, value in {'name': 'Alice', 'age': 30}.items():
    print(f"{key}: {value}")

# While loops
count = 0
while count < 5:
    print(count)
    count += 1

# List comprehensions (common in data science)
squares = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]
evens = [x for x in range(10) if x % 2 == 0]  # [0, 2, 4, 6, 8]

# Dictionary comprehensions
square_dict = {x: x**2 for x in range(5)}
# {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}
```

---

## P1.2 Functions and Scope

### P1.2.1 Defining Functions

```python
# Basic function
def greet(name):
    """Greet someone by name."""
    return f"Hello, {name}!"

# Function with default parameters
def greet_with_title(name, title="Mr."):
    return f"Hello, {title} {name}!"

# Function with variable arguments
def sum_all(*args):
    """Sum any number of arguments."""
    return sum(args)

# Function with keyword arguments
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

# Function with type hints (Python 3.5+)
def calculate_average(numbers: list) -> float:
    """Calculate average of a list of numbers."""
    if not numbers:
        return 0.0
    return sum(numbers) / len(numbers)

# Lambda functions (anonymous)
square = lambda x: x**2
apply_operation = lambda x, y, op: op(x, y)

# Usage
greet("Alice")                        # "Hello, Alice!"
greet_with_title("Bob", "Dr.")       # "Hello, Dr. Bob!"
sum_all(1, 2, 3, 4, 5)               # 15
print_info(name="Alice", age=30)     # name: Alice \n age: 30
calculate_average([1, 2, 3, 4, 5])   # 3.0

# Lambda usage
square(5)                            # 25
apply_operation(10, 5, lambda x, y: x + y)  # 15
```

### P1.2.2 Scope and Closures

```python
# Global vs local scope
global_var = 10

def modify_global():
    global global_var  # Required to modify global
    global_var = 20

def read_global():
    return global_var  # Read-only, no 'global' needed

# Closures (functions that remember their environment)
def make_multiplier(factor):
    def multiplier(x):
        return x * factor
    return multiplier

times_two = make_multiplier(2)
times_three = make_multiplier(3)

times_two(5)   # 10
times_three(5) # 15
```

### P1.2.3 Decorators (Common in Dash Callbacks)

```python
# Simple decorator
def timer(func):
    """Decorator to time function execution."""
    import time
    
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper

# Usage
@timer
def slow_function():
    import time
    time.sleep(1)
    return "Done"

# Decorator with parameters
def repeat(n):
    """Decorator to repeat function n times."""
    def decorator(func):
        def wrapper(*args, **kwargs):
            results = []
            for _ in range(n):
                results.append(func(*args, **kwargs))
            return results
        return wrapper
    return decorator

@repeat(3)
def say_hello(name):
    return f"Hello, {name}!"

# Dash callback decorator (simplified)
def callback(output, inputs):
    """Simplified version of Dash callback decorator."""
    def decorator(func):
        def wrapper(*args, **kwargs):
            # In Dash, this handles the callback logic
            return func(*args, **kwargs)
        return wrapper
    return decorator

# Actual Dash usage (from the series)
# @callback(
#     Output('chart', 'figure'),
#     Input('dropdown', 'value')
# )
# def update_chart(value):
#     return create_figure(value)
```

---

## P1.3 Working with Lists and Iterables

### P1.3.1 List Operations

```python
# Basic list operations
numbers = [1, 2, 3, 4, 5]

# Slicing
numbers[1:3]    # [2, 3] (index 1 to 2)
numbers[:3]     # [1, 2, 3] (start to index 2)
numbers[3:]     # [4, 5] (index 3 to end)
numbers[-2:]    # [4, 5] (last two)
numbers[::2]    # [1, 3, 5] (every other)

# Common methods
numbers.append(6)        # [1, 2, 3, 4, 5, 6]
numbers.insert(0, 0)     # [0, 1, 2, 3, 4, 5, 6]
numbers.pop()            # 6 (removes last)
numbers.pop(0)           # 0 (removes first)
numbers.remove(3)        # [1, 2, 4, 5]
numbers.sort()           # Sorts in place
numbers.reverse()        # Reverses in place
len(numbers)             # Length

# List comprehensions (critical for data processing)
squares = [x**2 for x in range(10)]  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
evens = [x for x in range(10) if x % 2 == 0]  # [0, 2, 4, 6, 8]
matrix = [[j for j in range(3)] for i in range(3)]  # 3x3 matrix

# Combining lists
list1 = [1, 2, 3]
list2 = [4, 5, 6]
combined = list1 + list2          # [1, 2, 3, 4, 5, 6]
zipped = list(zip(list1, list2))  # [(1, 4), (2, 5), (3, 6)]

# Unpacking
first, second, *rest = [1, 2, 3, 4, 5]
# first = 1, second = 2, rest = [3, 4, 5]

# any() and all()
numbers = [1, 2, 3, 4, 5]
any(x > 4 for x in numbers)   # True (5 > 4)
all(x > 0 for x in numbers)   # True (all positive)
```

### P1.3.2 Iterators and Generators

```python
# Generator functions (memory efficient)
def fibonacci(limit):
    """Generate Fibonacci numbers up to limit."""
    a, b = 0, 1
    while a < limit:
        yield a
        a, b = b, a + b

# Usage
for num in fibonacci(100):
    print(num)

# Generator expression (like list comprehension but lazy)
squares_gen = (x**2 for x in range(10))
for square in squares_gen:
    print(square)

# itertools (powerful iteration tools)
from itertools import chain, cycle, combinations, product

# Chain multiple iterables
for item in chain([1, 2], ['a', 'b']):
    print(item)  # 1, 2, 'a', 'b'

# Combinations
for combo in combinations([1, 2, 3], 2):
    print(combo)  # (1,2), (1,3), (2,3)

# Cartesian product
for p in product([1, 2], ['a', 'b']):
    print(p)  # (1,'a'), (1,'b'), (2,'a'), (2,'b')
```

---

## P1.4 Working with Dictionaries

### P1.4.1 Dictionary Operations

```python
# Creating dictionaries
person = {'name': 'Alice', 'age': 30, 'city': 'New York'}

# Accessing values
person['name']          # 'Alice'
person.get('name')      # 'Alice'
person.get('email', 'N/A')  # 'N/A' (with default)

# Adding/updating
person['email'] = 'alice@example.com'
person.update({'age': 31, 'country': 'USA'})

# Checking existence
'name' in person        # True
'phone' in person       # False

# Iteration
for key in person:
    print(f"{key}: {person[key]}")

for key, value in person.items():
    print(f"{key}: {value}")

# Dictionary comprehension
squares = {x: x**2 for x in range(5)}
# {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# Default values with collections.defaultdict
from collections import defaultdict
grouped = defaultdict(list)
for item in [1, 2, 3, 1, 2, 1]:
    grouped[item].append(item)
# defaultdict(<class 'list'>, {1: [1, 1, 1], 2: [2, 2], 3: [3]})

# Counter (counting items)
from collections import Counter
counts = Counter([1, 2, 3, 1, 2, 1])
# Counter({1: 3, 2: 2, 3: 1})
```

### P1.4.2 JSON Handling

```python
import json

# Convert dict to JSON
data = {'name': 'Alice', 'age': 30, 'hobbies': ['reading', 'coding']}
json_string = json.dumps(data, indent=2)

# Convert JSON to dict
parsed = json.loads(json_string)

# Read/write JSON files
with open('data.json', 'w') as f:
    json.dump(data, f, indent=2)

with open('data.json', 'r') as f:
    loaded = json.load(f)
```

---

## P1.5 Working with Files

### P1.5.1 File I/O

```python
# Reading files
with open('file.txt', 'r') as f:
    content = f.read()

# Reading line by line (memory efficient)
with open('large_file.txt', 'r') as f:
    for line in f:
        process(line)

# Writing files
with open('output.txt', 'w') as f:
    f.write("Hello, World!\n")
    f.writelines(["Line 1\n", "Line 2\n"])

# Appending to files
with open('log.txt', 'a') as f:
    f.write("New log entry\n")

# Path handling (modern approach)
from pathlib import Path

# Create paths
data_dir = Path('data')
file_path = data_dir / 'customer_data.csv'

# Check existence
if file_path.exists():
    print(f"File exists: {file_path}")
    print(f"Size: {file_path.stat().st_size} bytes")

# Create directories
data_dir.mkdir(parents=True, exist_ok=True)

# List files
for file in Path('.').glob('*.csv'):
    print(file)

# Read file with Path
content = file_path.read_text()
```

---

## P1.6 Exception Handling

### P1.6.1 Try/Except/Final

```python
# Basic try/except
try:
    result = 10 / 0
except ZeroDivisionError:
    result = float('inf')
    print("Cannot divide by zero")

# Multiple exceptions
try:
    value = int("abc")
except (ValueError, TypeError) as e:
    print(f"Conversion error: {e}")
    value = 0

# Specific exception handling
try:
    df = pd.read_csv('file.csv')
except FileNotFoundError as e:
    print(f"File not found: {e}")
    df = pd.DataFrame()
except pd.errors.ParserError as e:
    print(f"CSV parsing error: {e}")
    df = pd.DataFrame()
except Exception as e:
    print(f"Unexpected error: {e}")
    raise  # Re-raise unexpected errors

# Finally (always executes)
try:
    file = open('data.txt', 'r')
    content = file.read()
except IOError:
    print("Error reading file")
finally:
    file.close()  # Always closes the file

# Else (executes if no exception)
try:
    result = risky_operation()
except Exception as e:
    print(f"Error: {e}")
else:
    print(f"Success: {result}")

# Custom exceptions
class DataError(Exception):
    pass

def validate_data(df):
    if df.empty:
        raise DataError("DataFrame is empty")
```

---

## P1.7 Working with Dates and Times

### P1.7.1 datetime Module

```python
from datetime import datetime, date, timedelta

# Current time
now = datetime.now()
today = date.today()

# Creating dates
birthday = datetime(1990, 1, 15)
specific_date = date(2024, 12, 25)

# Formatting dates
now.strftime('%Y-%m-%d')        # '2024-07-28'
now.strftime('%B %d, %Y')       # 'July 28, 2024'
now.strftime('%A')              # 'Sunday'

# Parsing strings to dates
date_string = '2024-07-28'
parsed = datetime.strptime(date_string, '%Y-%m-%d')

# Date arithmetic
tomorrow = now + timedelta(days=1)
last_week = now - timedelta(weeks=1)
future = now + timedelta(days=30, hours=5)

# Comparing dates
if now > birthday:
    print("Birthday has passed")

# Timezone handling (use pytz or zoneinfo)
from zoneinfo import ZoneInfo
eastern = now.astimezone(ZoneInfo('America/New_York'))
```

### P1.7.2 pandas DateTime

```python
import pandas as pd

# Convert to datetime
df['date'] = pd.to_datetime(df['date_string'])
df['date'] = pd.to_datetime(df['date_string'], format='%Y-%m-%d')

# Extract components
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['day'] = df['date'].dt.day
df['dayofweek'] = df['date'].dt.dayofweek  # 0=Monday, 6=Sunday
df['quarter'] = df['date'].dt.quarter

# Date ranges
dates = pd.date_range('2024-01-01', '2024-12-31', freq='D')  # Daily
hours = pd.date_range('2024-01-01', periods=24, freq='H')   # Hourly

# Resampling (time series)
df_resampled = df.resample('M', on='date').mean()
```

---

## P1.8 Advanced Python Patterns

### P1.8.1 Context Managers

```python
# Custom context manager
class TimerContext:
    def __enter__(self):
        self.start = time.time()
        return self
    
    def __exit__(self, *args):
        self.end = time.time()
        print(f"Elapsed: {self.end - self.start:.4f}s")

# Usage
with TimerContext() as timer:
    # Do something
    import time
    time.sleep(1)
# Output: Elapsed: 1.0002s

# Using contextlib
from contextlib import contextmanager

@contextmanager
def timer():
    start = time.time()
    yield
    print(f"Elapsed: {time.time() - start:.4f}s")

with timer():
    time.sleep(1)
```

### P1.8.2 Working with *args and **kwargs

```python
# Flexible functions
def process_data(data, *args, **kwargs):
    """
    Process data with flexible arguments.
    
    Parameters:
    -----------
    data : pd.DataFrame
        The data to process
    *args : positional arguments
        Additional positional arguments
    **kwargs : keyword arguments
        Additional keyword arguments
    """
    print(f"Data shape: {data.shape}")
    print(f"Args: {args}")
    print(f"Kwargs: {kwargs}")
    
    # Extract specific kwargs
    method = kwargs.get('method', 'mean')
    columns = kwargs.get('columns', None)
    
    if method == 'mean':
        return data.mean()
    elif method == 'sum':
        return data.sum()
    else:
        return data

# Usage
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})
process_data(df, 'extra', 'arg', method='sum', columns=['A'])
# Data shape: (3, 2)
# Args: ('extra', 'arg')
# Kwargs: {'method': 'sum', 'columns': ['A']}
```

### P1.8.3 Type Hints (Python 3.5+)

```python
from typing import List, Dict, Optional, Union, Any

def process_numbers(numbers: List[int]) -> float:
    """Process a list of numbers."""
    return sum(numbers) / len(numbers)

def get_user(name: str, age: int, email: Optional[str] = None) -> Dict[str, Any]:
    """Create a user dictionary."""
    user = {'name': name, 'age': age}
    if email:
        user['email'] = email
    return user

def transform(data: Union[pd.DataFrame, pd.Series]) -> pd.DataFrame:
    """Transform DataFrame or Series."""
    if isinstance(data, pd.Series):
        return data.to_frame()
    return data.copy()
```

---

## P1.9 Common Data Science Imports

### P1.9.1 Standard Imports Pattern

```python
# Data manipulation
import pandas as pd
import numpy as np

# Visualization
import matplotlib.pyplot as plt
import seaborn as sns

# Statistical analysis
from scipy import stats
import statsmodels.api as sm

# Machine learning
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix

# Interactive visualization
import plotly.express as px
import plotly.graph_objects as go

# Web apps
import dash
from dash import dcc, html, Input, Output, State

# Utilities
import warnings
warnings.filterwarnings('ignore')
from tqdm import tqdm
import json
import os
from pathlib import Path
```

### P1.9.2 Jupyter-Specific Commands

```python
# Magic commands
%matplotlib inline  # Display plots inline
%load_ext autoreload  # Auto-reload modules
%autoreload 2
%time  # Time a single statement
%timeit  # Time multiple runs
%%time  # Time entire cell
%run script.py  # Run external script
%load script.py  # Load script content

# Display
from IPython.display import display, HTML
display(HTML("<h1>Custom HTML</h1>"))
```

---

## P1.10 Key Differences: Python for Data Science vs. General Python

### P1.10.1 Vectorization (Critical Concept)

```python
# ❌ SLOW: Python loops
def slow_mean_absolute_deviation(data):
    mean = sum(data) / len(data)
    deviations = []
    for x in data:
        deviations.append(abs(x - mean))
    return sum(deviations) / len(deviations)

# ✅ FAST: Vectorization with NumPy
def fast_mean_absolute_deviation(data):
    mean = np.mean(data)
    return np.mean(np.abs(data - mean))

# ✅ FAST: Vectorization with pandas
def pandas_mean_absolute_deviation(data):
    return (data - data.mean()).abs().mean()
```

### P1.10.2 Broadcasting (NumPy)

```python
import numpy as np

# Element-wise operations
arr = np.array([1, 2, 3, 4, 5])
arr + 10          # [11, 12, 13, 14, 15]
arr * 2           # [2, 4, 6, 8, 10]
arr ** 2          # [1, 4, 9, 16, 25]

# Broadcasting shapes
a = np.array([[1, 2, 3],
              [4, 5, 6]])  # shape (2, 3)
b = np.array([10, 20, 30])  # shape (3,)
a + b  # [[11, 22, 33], [14, 25, 36]]

# Boolean indexing
arr = np.array([1, 2, 3, 4, 5])
mask = arr > 3
arr[mask]  # [4, 5]
```

### P1.10.3 Pandas Idioms

```python
# ❌ SLOW: Iterating rows
for idx, row in df.iterrows():
    df.loc[idx, 'new_col'] = row['col1'] + row['col2']

# ✅ FAST: Vectorized operation
df['new_col'] = df['col1'] + df['col2']

# ✅ FAST: Using apply (still vectorized)
df['new_col'] = df.apply(lambda row: row['col1'] + row['col2'], axis=1)

# Condition-based assignment
df['new_col'] = np.where(
    df['age'] > 30,
    'Adult',
    'Young'
)

# Multiple conditions
df['segment'] = np.select(
    [
        (df['age'] < 18),
        (df['age'] < 65),
        (df['age'] >= 65)
    ],
    ['Minor', 'Adult', 'Senior'],
    default='Unknown'
)
```

---

## P1.11 Debugging Tips

### P1.11.1 Print Debugging

```python
# Using print statements
print(f"Data shape: {df.shape}")
print(f"Columns: {df.columns.tolist()}")
print(f"First row: {df.iloc[0].to_dict()}")
print(f"Missing values: {df.isnull().sum().sum()}")

# Pretty printing
import pprint
pprint.pprint(df.head().to_dict())
```

### P1.11.2 Using pdb (Python Debugger)

```python
import pdb

def problematic_function(data):
    # Set breakpoint
    pdb.set_trace()
    
    # Code continues here when debugger is active
    result = data.groupby('col').mean()
    return result

# Usage
result = problematic_function(df)

# pdb commands:
# n - next line
# s - step into function
# c - continue
# p variable - print variable
# q - quit debugger
```

### P1.11.3 Logging

```python
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Usage
logger.debug("Debug message")
logger.info("Info message")
logger.warning("Warning message")
logger.error("Error message")
logger.exception("Exception with traceback")
```

---

## P1.12 Common Pitfalls and Solutions

| Pitfall | Solution |
|---------|----------|
| **Forgetting .copy()** | Use `df2 = df.copy()` to avoid modifying original |
| **Modifying during iteration** | Iterate over `.copy()` or use list comprehension |
| **Chained indexing** | Use `.loc` instead of `df[df['col'] > 5]['other']` |
| **Missing imports** | Check import statements, use auto-import |
| **Case sensitivity** | Python is case-sensitive: `df` ≠ `DF` |
| **Mutable default arguments** | Use `None` and create new object in function |
| **Floating point issues** | Use `np.isclose()` for comparisons |
| **Memory leaks** | Use `del` for large objects, call `gc.collect()` |

---

## P1.13 Quick Reference: Essential Pandas Operations

```python
# Create DataFrame
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})

# Read/Write
df = pd.read_csv('file.csv')
df.to_csv('output.csv', index=False)

# Inspect
df.head()
df.tail()
df.info()
df.describe()
df.shape
df.columns
df.dtypes

# Select
df['A']               # Single column
df[['A', 'B']]        # Multiple columns
df.loc[0]             # Row by index
df.loc[0, 'A']        # Row and column
df.iloc[0, 0]         # Position-based
df[df['A'] > 1]       # Boolean filtering

# Modify
df['C'] = df['A'] + df['B']  # New column
df.drop('C', axis=1)         # Delete column
df.dropna()                   # Drop missing
df.fillna(0)                  # Fill missing
df.rename(columns={'A': 'X'}) # Rename

# Group
df.groupby('A').mean()
df.groupby('A').agg(['mean', 'sum'])
df.pivot_table(index='A', values='B', aggfunc='mean')

# Merge
pd.merge(df1, df2, on='key')
pd.concat([df1, df2], axis=0)  # Stack rows

# Apply
df['A'].apply(lambda x: x**2)
df.apply(lambda row: row['A'] + row['B'], axis=1)
```

---

## P1.14 Key Takeaways

1. **Vectorization is essential** - Avoid Python loops for data operations
2. **Use NumPy and pandas** - These are optimized for data work
3. **Understand mutability** - Know when to use `.copy()`
4. **Leverage comprehensions** - List/dict comprehensions are Pythonic and fast
5. **Handle errors properly** - Use try/except for robustness
6. **Use pathlib** - Modern and cross-platform path handling
7. **Type hints improve code** - Better documentation and IDE support
8. **Debug systematically** - Print, pdb, and logging are your friends

This primer covers the essential Python concepts you'll encounter throughout the series. Keep it handy as a reference when you encounter unfamiliar patterns in the main tutorials.
