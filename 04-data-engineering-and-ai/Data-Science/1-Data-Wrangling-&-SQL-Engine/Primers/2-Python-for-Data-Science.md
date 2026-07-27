# PRIMER 2: Python for Data Science

## A Complete Python Refresher for the Data Engineering Series

---

## Introduction

This primer is designed for readers who need a refresher on Python fundamentals, with a focus on the patterns and techniques used throughout the data engineering series. While the main series assumes basic Python knowledge, this primer ensures you have the foundation needed for data manipulation, analysis, and pipeline development.

**What This Primer Covers:**
- Python fundamentals (data types, control flow, functions)
- Data structures (lists, dictionaries, sets, tuples)
- Working with files and paths
- Functional programming concepts
- Data science libraries (NumPy, Pandas basics)
- Virtual environments and package management

**What This Primer Does NOT Cover:**
- Object-oriented programming in depth
- Web frameworks
- Advanced Python internals

---

## P2.1: Python Fundamentals

### Data Types

```python
# Numeric types
integer = 42
float_num = 3.14159
complex_num = 3 + 4j

# Boolean
is_true = True
is_false = False

# String
string = "Hello, World!"
multiline = """This is a
multiline string"""
f_string = f"Hello, {string}"

# None (null)
nothing = None

# Type checking
print(type(integer))  # <class 'int'>
print(type(float_num))  # <class 'float'>
print(type(string))  # <class 'str'>
print(type(is_true))  # <class 'bool'>
```

### Variables and Assignment

```python
# Basic assignment
x = 10
y = 20

# Multiple assignment
a, b, c = 1, 2, 3

# Swap variables (Python magic)
a, b = b, a

# Dynamic typing (no type declaration needed)
x = 10      # x is int
x = "hello"  # x is now str

# Type hints (for readability, not enforced)
def greet(name: str) -> str:
    return f"Hello, {name}"
```

### Control Flow

```python
# If-elif-else
age = 25

if age < 18:
    status = "Minor"
elif age < 65:
    status = "Adult"
else:
    status = "Senior"

# Ternary operator (conditional expression)
status = "Minor" if age < 18 else "Adult"

# For loops
for i in range(5):  # 0, 1, 2, 3, 4
    print(i)

for i in range(1, 10, 2):  # 1, 3, 5, 7, 9
    print(i)

# While loops
count = 0
while count < 5:
    print(count)
    count += 1

# Break and continue
for i in range(10):
    if i == 3:
        continue  # Skip 3
    if i == 7:
        break     # Stop at 7
    print(i)
```

### Functions

```python
# Basic function
def greet(name):
    return f"Hello, {name}!"

# Function with default parameters
def greet(name, greeting="Hello"):
    return f"{greeting}, {name}!"

# Function with multiple returns
def get_stats(numbers):
    return min(numbers), max(numbers), sum(numbers) / len(numbers)

min_val, max_val, mean_val = get_stats([1, 2, 3, 4, 5])

# *args (variable positional arguments)
def sum_all(*args):
    return sum(args)

print(sum_all(1, 2, 3, 4))  # 10

# **kwargs (variable keyword arguments)
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_info(name="Alice", age=30, city="NYC")

# Lambda functions (anonymous)
square = lambda x: x ** 2
print(square(5))  # 25

# Map, Filter, Reduce
numbers = [1, 2, 3, 4, 5]
squared = list(map(lambda x: x ** 2, numbers))
evens = list(filter(lambda x: x % 2 == 0, numbers))

# List comprehension (more Pythonic)
squared = [x ** 2 for x in numbers]
evens = [x for x in numbers if x % 2 == 0]
```

### Error Handling

```python
# Try-except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero!")
except Exception as e:
    print(f"An error occurred: {e}")
else:
    print("No errors occurred!")
finally:
    print("This always runs")

# Raising exceptions
def validate_age(age):
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age seems too high")
    return age

# Custom exceptions
class DataQualityError(Exception):
    pass

def validate_data(df):
    if df.empty:
        raise DataQualityError("DataFrame is empty")
```

---

## P2.2: Data Structures

### Lists (Mutable, Ordered)

```python
# Creation
empty_list = []
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True]

# Access
first = numbers[0]
last = numbers[-1]
subset = numbers[1:3]  # [2, 3]

# Methods
numbers.append(6)        # Add at end
numbers.insert(0, 0)     # Insert at position
numbers.remove(3)        # Remove first occurrence
popped = numbers.pop()   # Remove and return last
numbers.sort()           # Sort in place
numbers.reverse()        # Reverse in place

# List comprehensions
squares = [x**2 for x in range(10)]
even_squares = [x**2 for x in range(10) if x % 2 == 0]

# Nested lists (matrix)
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
element = matrix[1][2]  # 6
```

### Tuples (Immutable, Ordered)

```python
# Creation
point = (10, 20)
single_tuple = (1,)  # Note: comma needed

# Unpacking
x, y = point

# Useful for returning multiple values
def get_customer():
    return 1, "Alice", "alice@email.com"

id, name, email = get_customer()

# Tuple vs List
# - Tuple: immutable, faster, can be used as dict keys
# - List: mutable, slower
```

### Dictionaries (Key-Value Pairs)

```python
# Creation
empty_dict = {}
person = {
    "name": "Alice",
    "age": 30,
    "city": "New York"
}

# Access
name = person["name"]  # Raises KeyError if missing
name = person.get("name", "Unknown")  # Returns default if missing

# Methods
person["email"] = "alice@email.com"  # Add
person["age"] = 31  # Update
del person["city"]  # Delete
keys = person.keys()
values = person.values()
items = person.items()

# Iteration
for key, value in person.items():
    print(f"{key}: {value}")

# Dictionary comprehension
squares = {x: x**2 for x in range(10)}

# defaultdict (handles missing keys)
from collections import defaultdict
word_count = defaultdict(int)
for word in ["apple", "banana", "apple"]:
    word_count[word] += 1  # No KeyError!
```

### Sets (Unique, Unordered)

```python
# Creation
empty_set = set()
numbers = {1, 2, 3, 4, 5}

# Methods
numbers.add(6)
numbers.remove(3)
numbers.discard(10)  # No error if missing

# Set operations
set_a = {1, 2, 3, 4}
set_b = {3, 4, 5, 6}

union = set_a | set_b          # {1, 2, 3, 4, 5, 6}
intersection = set_a & set_b   # {3, 4}
difference = set_a - set_b     # {1, 2}
symmetric_diff = set_a ^ set_b # {1, 2, 5, 6}

# Remove duplicates
unique = list(set([1, 2, 2, 3, 3, 3]))  # [1, 2, 3]
```

---

## P2.3: Working with Files

### Reading Files

```python
# Basic file reading
with open('file.txt', 'r') as f:
    content = f.read()

# Read line by line
with open('file.txt', 'r') as f:
    for line in f:
        print(line.strip())

# Read CSV (simple)
with open('data.csv', 'r') as f:
    for line in f:
        row = line.strip().split(',')
        # Process row

# Using pandas (recommended)
import pandas as pd
df = pd.read_csv('data.csv')
df = pd.read_excel('data.xlsx')
df = pd.read_parquet('data.parquet')
df = pd.read_json('data.json')
```

### Writing Files

```python
# Write text
with open('output.txt', 'w') as f:
    f.write("Hello, World!\n")
    f.write("Second line")

# Append to file
with open('output.txt', 'a') as f:
    f.write("Appended line\n")

# Write CSV
import csv
with open('output.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['name', 'age'])
    writer.writerow(['Alice', 30])
    writer.writerow(['Bob', 25])

# Using pandas
df.to_csv('output.csv', index=False)
df.to_parquet('output.parquet')
df.to_excel('output.xlsx', index=False)
df.to_json('output.json')
```

### Working with Paths

```python
from pathlib import Path

# Create Path objects
data_dir = Path('data')
file_path = data_dir / 'processed' / 'output.parquet'

# Check if exists
if file_path.exists():
    print("File exists!")

# Create directories
data_dir.mkdir(parents=True, exist_ok=True)

# List files
for file in data_dir.glob('*.csv'):
    print(file.name)

# Get file info
print(file_path.parent)   # Directory
print(file_path.stem)     # Filename without extension
print(file_path.suffix)   # Extension
print(file_path.name)     # Full filename
```

---

## P2.4: Functional Programming in Python

### Key Concepts

```python
# First-class functions (functions can be passed as arguments)
def apply_operation(func, numbers):
    return [func(x) for x in numbers]

result = apply_operation(lambda x: x**2, [1, 2, 3, 4])

# Higher-order functions
# - map: apply function to each element
squared = list(map(lambda x: x**2, [1, 2, 3, 4]))

# - filter: filter elements
evens = list(filter(lambda x: x % 2 == 0, [1, 2, 3, 4]))

# - reduce: reduce to single value
from functools import reduce
product = reduce(lambda x, y: x * y, [1, 2, 3, 4])  # 24

# Decorators (functions that modify other functions)
import time

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.2f}s")
        return result
    return wrapper

@timer
def slow_function():
    time.sleep(1)

slow_function()
```

### Comprehensions vs Loops

```python
# List comprehension (fast, Pythonic)
squares = [x**2 for x in range(10)]

# Dictionary comprehension
squares_dict = {x: x**2 for x in range(10)}

# Set comprehension
even_numbers = {x for x in range(10) if x % 2 == 0}

# Generator expression (memory efficient)
squares_gen = (x**2 for x in range(1000000))  # No memory issue

# Nested comprehension
matrix = [[1, 2, 3], [4, 5, 6]]
flattened = [x for row in matrix for x in row]  # [1, 2, 3, 4, 5, 6]
```

---

## P2.5: NumPy Essentials

### Array Creation

```python
import numpy as np

# From list
arr = np.array([1, 2, 3, 4, 5])

# Common arrays
zeros = np.zeros((3, 4))
ones = np.ones((2, 3))
identity = np.eye(5)
full = np.full((3, 3), 7)

# Ranges
arange = np.arange(0, 10, 2)  # [0, 2, 4, 6, 8]
linspace = np.linspace(0, 1, 5)  # [0, 0.25, 0.5, 0.75, 1]

# Random
np.random.seed(42)  # For reproducibility
random = np.random.randn(3, 4)  # Normal distribution
uniform = np.random.uniform(0, 1, (2, 3))
integers = np.random.randint(0, 10, (3, 3))
```

### Array Operations

```python
arr = np.array([1, 2, 3, 4, 5])

# Element-wise operations
arr + 10
arr * 2
arr ** 2
np.sqrt(arr)
np.exp(arr)
np.log(arr)

# Aggregations
arr.sum()
arr.mean()
arr.std()
arr.min()
arr.max()

# Broadcasting (operations with different shapes)
arr2 = np.array([[1, 2, 3], [4, 5, 6]])
arr2 + np.array([10, 20, 30])  # Adds to each row

# Reshaping
matrix = np.arange(12).reshape(3, 4)
matrix.T  # Transpose
matrix.flatten()  # 1D

# Indexing and slicing
arr = np.arange(10)
arr[5:]  # [5, 6, 7, 8, 9]
arr[::2]  # Even indices

matrix = np.arange(12).reshape(3, 4)
matrix[1, 2]  # Single element
matrix[:, 1]  # Column 1
matrix[1:, 2:]  # Submatrix

# Boolean indexing
arr = np.random.randn(10)
mask = arr > 0
positive = arr[mask]
```

---

## P2.6: Pandas Essentials

### Series and DataFrame Creation

```python
import pandas as pd
import numpy as np

# Series (1D)
s = pd.Series([1, 2, 3, 4, 5], index=['a', 'b', 'c', 'd', 'e'])

# DataFrame (2D)
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35],
    'city': ['NYC', 'LA', 'Chicago']
})

# From dict of lists
df = pd.DataFrame(data)

# From list of dicts
df = pd.DataFrame([
    {'name': 'Alice', 'age': 25},
    {'name': 'Bob', 'age': 30}
])

# From NumPy array
df = pd.DataFrame(np.random.randn(5, 3), columns=['A', 'B', 'C'])

# From CSV
df = pd.read_csv('data.csv')

# From Parquet
df = pd.read_parquet('data.parquet')
```

### Data Exploration

```python
# View data
df.head()      # First 5 rows
df.tail()      # Last 5 rows
df.sample(10)  # Random sample

# Information
df.info()      # Column types, non-null counts
df.describe()  # Summary statistics
df.shape       # (rows, columns)
df.columns     # Column names
df.dtypes      # Data types

# Check for missing values
df.isna().sum()
df.isna().mean() * 100  # Percentage missing
```

### Data Manipulation

```python
# Selecting columns
df['name']
df[['name', 'age']]

# Filtering rows
df[df['age'] > 30]
df.query('age > 30 and city == "NYC"')

# Loc (label-based) and iloc (integer-based)
df.loc[0]                  # First row
df.loc[0:2, 'name':'age']  # Rows 0-2, columns name-age
df.iloc[0:2, 0:2]          # First 2 rows, first 2 columns

# Adding/modifying columns
df['new_col'] = df['age'] * 2
df['is_adult'] = df['age'] >= 18

# Renaming columns
df.rename(columns={'name': 'full_name'}, inplace=True)

# Sorting
df.sort_values('age', ascending=False)

# Grouping and aggregation
df.groupby('city')['age'].mean()
df.groupby('city').agg({
    'age': ['mean', 'std', 'count'],
    'name': 'count'
})

# Pivot tables
df.pivot_table(
    values='age',
    index='city',
    columns='gender',
    aggfunc='mean'
)

# Merging DataFrames
merged = pd.merge(
    df1, 
    df2, 
    on='id',
    how='inner'  # 'left', 'right', 'outer'
)

# Concatenating
combined = pd.concat([df1, df2], axis=0)  # Rows
combined = pd.concat([df1, df2], axis=1)  # Columns
```

### Handling Missing Data

```python
# Check missing values
df.isna().sum()

# Drop missing values
df.dropna()  # Drop any row with NA
df.dropna(subset=['age'])  # Drop rows missing 'age'

# Fill missing values
df.fillna(0)  # Fill with 0
df.fillna(df.mean())  # Fill with mean
df['age'].fillna(df['age'].median())  # Fill specific column

# Interpolation
df.interpolate()  # Linear interpolation
```

---

## P2.7: Virtual Environments

### Why Use Virtual Environments?

Virtual environments isolate project dependencies, preventing conflicts between different projects.

```bash
# Creating a virtual environment
python3 -m venv venv

# Activating
# Linux/macOS
source venv/bin/activate

# Windows
venv\Scripts\activate

# Installing packages
pip install numpy pandas polars

# Saving dependencies
pip freeze > requirements.txt

# Installing from requirements
pip install -r requirements.txt

# Deactivating
deactivate
```

### requirements.txt Best Practices

```txt
# Core data processing
numpy==1.24.3
pandas==2.0.3
polars==0.18.15

# SQL and databases
duckdb==0.8.1
psycopg2-binary==2.9.6

# Visualization
matplotlib==3.7.2
seaborn==0.12.2
plotly==5.15.0

# Statistics
scipy==1.11.1
statsmodels==0.14.0

# Development
pytest==7.4.0
black==23.7.0
```

---

## P2.8: Common Data Science Patterns

### Data Pipeline Pattern

```python
def data_pipeline(input_path, output_path):
    """A typical data pipeline pattern."""
    import pandas as pd
    
    # 1. Load
    df = pd.read_parquet(input_path)
    
    # 2. Clean
    df = df.dropna(subset=['required_column'])
    df = df.drop_duplicates()
    
    # 3. Transform
    df['new_column'] = df['column1'] + df['column2']
    df = df[df['value'] > 0]
    
    # 4. Aggregate
    result = df.groupby('category').agg({
        'value': ['sum', 'mean', 'count']
    })
    
    # 5. Save
    result.to_parquet(output_path)
    
    return result
```

### ETL Pattern

```python
class ETLPipeline:
    """ETL pipeline template."""
    
    def __init__(self, config):
        self.config = config
        
    def extract(self):
        """Extract data from source."""
        # Implement extraction logic
        pass
    
    def transform(self, data):
        """Transform the data."""
        # Implement transformation logic
        pass
    
    def load(self, data):
        """Load data to destination."""
        # Implement loading logic
        pass
    
    def run(self):
        """Run the complete pipeline."""
        data = self.extract()
        data = self.transform(data)
        self.load(data)
        return data
```

### Functional Pipeline Pattern

```python
def pipeline(*functions):
    """Compose multiple functions into a pipeline."""
    def apply(data):
        for func in functions:
            data = func(data)
        return data
    return apply

# Usage
clean_data = pipeline(
    lambda df: df.dropna(),
    lambda df: df.drop_duplicates(),
    lambda df: df[df['value'] > 0]
)

result = clean_data(df)
```

---

## P2.9: Common Pitfalls and Best Practices

### Pitfalls to Avoid

```python
# 1. NOT using vectorized operations (slow)
# Bad
for i in range(len(df)):
    df.loc[i, 'new_col'] = df.loc[i, 'col1'] + df.loc[i, 'col2']

# Good
df['new_col'] = df['col1'] + df['col2']

# 2. NOT checking data types
# Bad
df['date'] = df['date_string']  # Keeps as string

# Good
df['date'] = pd.to_datetime(df['date_string'])

# 3. NOT handling errors
# Bad
df = pd.read_csv('file.csv')

# Good
try:
    df = pd.read_csv('file.csv')
except FileNotFoundError:
    print("File not found!")
    raise

# 4. NOT using context managers
# Bad
f = open('file.txt', 'r')
content = f.read()
f.close()  # Might be forgotten

# Good
with open('file.txt', 'r') as f:
    content = f.read()  # Automatically closes

# 5. Using mutable default arguments
# Bad
def append_to_list(item, my_list=[]):
    my_list.append(item)
    return my_list

# Good
def append_to_list(item, my_list=None):
    if my_list is None:
        my_list = []
    my_list.append(item)
    return my_list
```

### Best Practices Checklist

- [ ] Use descriptive variable names
- [ ] Write docstrings for functions
- [ ] Use type hints for clarity
- [ ] Use list comprehensions instead of loops
- [ ] Use vectorized operations for data processing
- [ ] Handle exceptions properly
- [ ] Use context managers for resources
- [ ] Keep functions small and focused
- [ ] Use virtual environments for dependencies
- [ ] Write unit tests for critical functions

---

## P2.10: Practice Exercises

### Exercise 1: Data Cleaning

```python
"""
Exercise: Clean a dataset with missing values, duplicates, and outliers.
"""

import pandas as pd
import numpy as np

# Create messy data
np.random.seed(42)
df = pd.DataFrame({
    'id': range(1, 101),
    'name': [f'User_{i}' for i in range(1, 101)],
    'age': np.random.randint(18, 80, 100),
    'income': np.random.normal(50000, 20000, 100),
    'country': np.random.choice(['USA', 'UK', 'Canada'], 100)
})

# Introduce issues
df.loc[np.random.random(100) < 0.05, 'age'] = np.nan
df.loc[np.random.random(100) < 0.05, 'income'] = np.nan
df.loc[0, 'age'] = 150  # Outlier
df.loc[1, 'income'] = 1000000  # Outlier
df = pd.concat([df, df.iloc[:5]])  # Duplicates

# Your task: Clean this dataset
def clean_dataset(df):
    # 1. Remove duplicates
    # 2. Handle missing values
    # 3. Handle outliers (age > 120, income > 99th percentile)
    # 4. Return cleaned DataFrame
    pass
```

### Exercise 2: Data Analysis

```python
"""
Exercise: Analyze sales data and compute key metrics.
"""

# Sample sales data
sales_data = pd.DataFrame({
    'date': pd.date_range('2025-01-01', periods=100, freq='D'),
    'product': np.random.choice(['A', 'B', 'C'], 100),
    'sales': np.random.uniform(100, 1000, 100),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 100)
})

# Your task: Compute the following
# 1. Total sales by product
# 2. Average daily sales by region
# 3. Month-over-month growth
# 4. Top 5 days by sales
```

### Exercise 3: Function Design

```python
"""
Exercise: Design a reusable function for loading data.
"""

def load_data(
    file_path: str,
    file_type: str = 'csv',
    **kwargs
) -> pd.DataFrame:
    """
    Load data from various file formats.
    
    Args:
        file_path: Path to the file
        file_type: 'csv', 'parquet', 'excel', 'json'
        **kwargs: Additional arguments for the read function
    
    Returns:
        pd.DataFrame: Loaded data
    """
    # Your implementation here
    pass
```

---

## P2.11: Quick Reference

### Data Structures

| Type | Mutable | Ordered | Unique | Use Case |
|------|---------|---------|--------|----------|
| List | Yes | Yes | No | General sequences |
| Tuple | No | Yes | No | Fixed data, keys |
| Dict | Yes | Yes (3.7+) | Keys unique | Key-value lookups |
| Set | Yes | No | Yes | Membership, dedupe |

### Common Operations

```python
# List
len(list), list[i], list.append(), list.pop(), list.sort()

# Dict
len(dict), dict[key], dict.get(), dict.items(), dict.values()

# Set
len(set), set.add(), set.remove(), set.union(), set.intersection()

# String
len(str), str.upper(), str.lower(), str.strip(), str.split()

# NumPy
arr.shape, arr.reshape(), arr.T, arr.sum(), arr.mean()

# Pandas
df.shape, df.head(), df.info(), df.describe(), df.groupby()
```

---

**[PRIMER 2 COMPLETE]**  
x
