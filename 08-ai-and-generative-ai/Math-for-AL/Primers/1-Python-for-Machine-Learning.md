# Primer 1: Python for Machine Learning — Essential Concepts

## A Gentle Introduction to Python for ML Practitioners

### The Target

This primer provides a quick-start guide to Python programming specifically for machine learning. It covers essential Python concepts, data structures, and patterns used throughout the series, assuming no prior Python experience.

### The Concept

Think of Python as your workshop—it's where you'll build all your machine learning models. Before you can build anything, you need to know your tools: how to store data, how to organize code, and how to use the library that powers all ML in Python (NumPy).

**Why this matters**: Every line of code in this series uses Python. Understanding these fundamentals will make the rest of the series much easier to follow.

### Python Basics

#### Variables and Data Types

```python
# Numbers
age = 25                    # Integer
price = 19.99              # Float (decimal)
complex_num = 3 + 4j       # Complex number

# Text
name = "Alice"             # String
message = 'Hello World'    # Single quotes work too
multi_line = """This is
a multi-line string"""

# Boolean (True/False)
is_raining = False
has_umbrella = True

# Checking types
print(type(age))           # <class 'int'>
print(type(price))         # <class 'float'>
print(type(name))          # <class 'str'>
print(type(is_raining))    # <class 'bool'>
```

#### Lists (Ordered Collections)

```python
# Creating lists
features = [2000, 3, 2]           # List of numbers
names = ["Alice", "Bob", "Charlie"] # List of strings
mixed = [1, "two", 3.0, True]     # Mixed types

# Accessing elements (0-indexed)
first_feature = features[0]       # 2000
second_feature = features[1]      # 3
last_feature = features[-1]       # 2 (negative index starts from end)

# Slicing (getting sub-lists)
first_two = features[0:2]         # [2000, 3]
last_two = features[1:]           # [3, 2]
all_but_first = features[1:]      # [3, 2]

# Modifying lists
features.append(4)                # Add to end: [2000, 3, 2, 4]
features.insert(0, 1)             # Insert at position: [1, 2000, 3, 2, 4]
features[2] = 5                   # Change value: [1, 2000, 5, 2, 4]
removed = features.pop()          # Remove last: removes 4
del features[1]                   # Remove by index: removes 2000

# List comprehension (very common in ML!)
squares = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]
even_numbers = [x for x in range(10) if x % 2 == 0]  # [0, 2, 4, 6, 8]

# Iterating
for feature in features:
    print(feature)

for i, feature in enumerate(features):
    print(f"Index {i}: {feature}")
```

#### Dictionaries (Key-Value Pairs)

```python
# Creating dictionaries
house = {
    "sqft": 2000,
    "bedrooms": 3,
    "bathrooms": 2,
    "address": "123 Main St"
}

# Accessing values
sqft = house["sqft"]                # 2000
bedrooms = house.get("bedrooms")    # 3
garage = house.get("garage", 0)     # 0 (default if missing)

# Modifying dictionaries
house["price"] = 300000             # Add new key
house["sqft"] = 2100                # Update existing key
del house["address"]                # Remove key

# Iterating
for key, value in house.items():
    print(f"{key}: {value}")

for key in house.keys():
    print(key)

for value in house.values():
    print(value)

# Dictionary comprehension
squares_dict = {x: x**2 for x in range(5)}  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}
```

#### Tuples (Immutable Collections)

```python
# Creating tuples
coordinates = (10, 20)              # Fixed size, immutable
single_tuple = (5,)                 # Single element needs comma

# Unpacking
x, y = coordinates                  # x=10, y=20

# Accessing
first = coordinates[0]              # 10

# Tuples are immutable!
# coordinates[0] = 15  # This would raise an error
```

#### Sets (Unique Collections)

```python
# Creating sets
unique_numbers = {1, 2, 3, 3, 2, 1}  # {1, 2, 3} (duplicates removed)
unique_letters = set("hello")        # {'h', 'e', 'l', 'o'}

# Set operations
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}

union = a | b                    # {1, 2, 3, 4, 5, 6}
intersection = a & b             # {3, 4}
difference = a - b               # {1, 2}
symmetric_diff = a ^ b           # {1, 2, 5, 6}

# Adding/removing
unique_numbers.add(4)            # {1, 2, 3, 4}
unique_numbers.remove(2)         # {1, 3, 4}
unique_numbers.discard(10)       # No error if not found
```

### Control Flow

#### Conditionals

```python
# if/elif/else
age = 25

if age < 18:
    print("Minor")
elif age < 65:
    print("Adult")
else:
    print("Senior")

# Multiple conditions
if age >= 18 and age < 65:
    print("Working age")

if age < 18 or age > 65:
    print("Not working age")

# Ternary operator
status = "Adult" if age >= 18 else "Minor"
```

#### Loops

```python
# for loops
for i in range(5):               # 0, 1, 2, 3, 4
    print(i)

for i in range(2, 5):            # 2, 3, 4
    print(i)

for i in range(0, 10, 2):        # 0, 2, 4, 6, 8
    print(i)

# while loops
i = 0
while i < 5:
    print(i)
    i += 1

# break and continue
for i in range(10):
    if i == 3:
        continue                 # Skip i=3
    if i == 7:
        break                    # Stop at i=7
    print(i)                     # 0, 1, 2, 4, 5, 6
```

### Functions

#### Defining Functions

```python
# Basic function
def greet(name):
    """Print a greeting."""  # Docstring
    print(f"Hello, {name}!")

greet("Alice")  # Hello, Alice!

# Function with return value
def add(a, b):
    return a + b

result = add(3, 4)  # 7

# Default arguments
def power(x, exponent=2):
    return x ** exponent

square = power(5)        # 25
cube = power(5, 3)       # 125

# Variable number of arguments
def sum_all(*args):
    return sum(args)

total = sum_all(1, 2, 3, 4)  # 10

# Keyword arguments
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_info(name="Alice", age=25)  # name: Alice, age: 25

# Type hints (helpful for ML code)
def multiply(x: float, y: float) -> float:
    return x * y
```

#### Lambda Functions

```python
# Simple lambda
square = lambda x: x ** 2
result = square(5)  # 25

# Used with sorting
people = [("Alice", 25), ("Bob", 30), ("Charlie", 20)]
people.sort(key=lambda person: person[1])  # Sort by age

# Used with map/filter
numbers = [1, 2, 3, 4, 5]
squared = list(map(lambda x: x**2, numbers))  # [1, 4, 9, 16, 25]
evens = list(filter(lambda x: x % 2 == 0, numbers))  # [2, 4]
```

### Classes and Objects

```python
# Basic class definition
class House:
    """Simple house class."""
    
    # Class variable (shared by all instances)
    property_type = "Residential"
    
    def __init__(self, sqft, bedrooms, bathrooms):
        """Constructor - called when creating an instance."""
        self.sqft = sqft
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self._price = None  # Private attribute (convention)
    
    # Method
    def get_size(self):
        return self.sqft
    
    # Method with logic
    def price_per_sqft(self):
        if self._price is not None:
            return self._price / self.sqft
        return None
    
    # Property (getter)
    @property
    def price(self):
        return self._price
    
    # Property (setter)
    @price.setter
    def price(self, value):
        if value < 0:
            raise ValueError("Price cannot be negative")
        self._price = value
    
    # String representation
    def __repr__(self):
        return f"House(sqft={self.sqft}, bedrooms={self.bedrooms})"
    
    def __str__(self):
        return f"House with {self.bedrooms} bedrooms, {self.bathrooms} bathrooms"

# Creating instances
house1 = House(2000, 3, 2)
house2 = House(1500, 2, 1)

# Accessing attributes
print(house1.sqft)         # 2000
print(house1.get_size())   # 2000

# Using properties
house1.price = 300000
print(house1.price)        # 300000
print(house1.price_per_sqft())  # 150.0

# Class variable
print(House.property_type)  # Residential

# Inheritance
class LuxuryHouse(House):
    def __init__(self, sqft, bedrooms, bathrooms, pool=False):
        super().__init__(sqft, bedrooms, bathrooms)
        self.pool = pool
    
    def has_pool(self):
        return self.pool
    
    # Override method
    def __repr__(self):
        return f"LuxuryHouse(sqft={self.sqft}, bedrooms={self.bedrooms}, pool={self.pool})"
```

### File I/O

#### Reading and Writing Files

```python
# Writing to a file
with open("data.txt", "w") as f:
    f.write("Hello, World!\n")
    f.write("Second line\n")

# Reading from a file
with open("data.txt", "r") as f:
    content = f.read()        # Read entire file
    print(content)

# Reading line by line
with open("data.txt", "r") as f:
    for line in f:
        print(line.strip())   # strip removes newline

# Writing CSV data
import csv

data = [
    ["sqft", "bedrooms", "bathrooms", "price"],
    [2000, 3, 2, 300000],
    [1500, 2, 1, 200000]
]

with open("houses.csv", "w", newline='') as f:
    writer = csv.writer(f)
    writer.writerows(data)

# Reading CSV data
with open("houses.csv", "r") as f:
    reader = csv.reader(f)
    header = next(reader)  # Skip header
    for row in reader:
        sqft, bedrooms, bathrooms, price = row
        print(f"House: {sqft} sqft, {bedrooms} beds")
```

### Exceptions and Error Handling

```python
# Basic try/except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero!")
except TypeError as e:
    print(f"Type error: {e}")
else:
    print("No error occurred!")
finally:
    print("This always runs")

# Raising exceptions
def validate_price(price):
    if price < 0:
        raise ValueError("Price must be non-negative")
    return price

# Custom exceptions
class InvalidHouseError(Exception):
    """Raised when house data is invalid."""
    pass

def create_house(sqft, bedrooms):
    if sqft < 100:
        raise InvalidHouseError("House too small!")
    return House(sqft, bedrooms, 2)
```

### Common Python Patterns in ML

#### List Comprehensions (Very Common!)

```python
# Basic list comprehension
squares = [x**2 for x in range(10)]  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# With condition
even_squares = [x**2 for x in range(10) if x % 2 == 0]  # [0, 4, 16, 36, 64]

# Nested loops
pairs = [(x, y) for x in range(3) for y in range(3)]  
# [(0,0), (0,1), (0,2), (1,0), (1,1), (1,2), (2,0), (2,1), (2,2)]

# Dictionary comprehension
squares_dict = {x: x**2 for x in range(5)}  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# Set comprehension
unique_squares = {x**2 for x in [-3, -2, -1, 0, 1, 2, 3]}  # {0, 1, 4, 9}
```

#### Zip and Enumerate

```python
# Zip - combine multiple iterables
features = [2000, 3, 2]
labels = ["sqft", "bedrooms", "bathrooms"]

for label, value in zip(labels, features):
    print(f"{label}: {value}")

# Enumerate - get index and value
for i, value in enumerate(features):
    print(f"Feature {i}: {value}")
```

#### Unpacking

```python
# Tuple unpacking
x, y = (10, 20)  # x=10, y=20

# List unpacking
first, *rest = [1, 2, 3, 4]  # first=1, rest=[2, 3, 4]

# Dictionary unpacking
house = {"sqft": 2000, "bedrooms": 3}
house_info = {"bathrooms": 2, **house}  # merge dictionaries
```

### NumPy Basics (Essential for ML)

```python
import numpy as np

# Creating arrays
arr = np.array([1, 2, 3, 4, 5])           # 1D array
matrix = np.array([[1, 2], [3, 4]])       # 2D array
zeros = np.zeros((3, 4))                  # 3x4 array of zeros
ones = np.ones((2, 3))                    # 2x3 array of ones
eye = np.eye(3)                           # 3x3 identity matrix
random_array = np.random.randn(5, 5)      # 5x5 random normal

# Array operations (vectorized!)
arr2 = arr * 2                            # [2, 4, 6, 8, 10]
arr3 = arr + arr                          # [2, 4, 6, 8, 10]
dot_product = arr @ arr                   # Dot product (55)
matrix_product = matrix @ matrix          # Matrix multiplication

# Shape and reshaping
print(arr.shape)           # (5,)
print(matrix.shape)        # (2, 2)
reshaped = arr.reshape(5, 1)  # Column vector

# Indexing and slicing
arr[0]                     # First element
arr[1:3]                   # Elements 1 and 2
matrix[0, 1]               # Row 0, column 1
matrix[:, 0]               # All rows, column 0

# Statistical operations
mean = np.mean(arr)        # 3.0
std = np.std(arr)          # 1.414...
sum_arr = np.sum(arr)      # 15
min_val = np.min(arr)      # 1
max_val = np.max(arr)      # 5

# Broadcasting (very important!)
arr + 10                   # [11, 12, 13, 14, 15]
arr * 2                    # [2, 4, 6, 8, 10]
arr + np.array([1, 2, 3, 4, 5])  # [2, 4, 6, 8, 10]
```

### Virtual Environments

```python
# Creating a virtual environment
# python -m venv ml_env

# Activating (Mac/Linux)
# source ml_env/bin/activate

# Activating (Windows)
# ml_env\Scripts\activate

# Installing packages
# pip install numpy scipy matplotlib jupyter

# Creating requirements.txt
# pip freeze > requirements.txt

# Installing from requirements.txt
# pip install -r requirements.txt
```

### Quick Reference

#### Common Python Functions

```python
len()          # Get length
type()         # Get type
print()        # Print to console
input()        # Get user input
range()        # Create range
enumerate()    # Get index and value
zip()          # Combine iterables
sum()          # Sum values
max()          # Maximum value
min()          # Minimum value
sorted()       # Sort iterable
round()        # Round number
abs()          # Absolute value
help()         # Get help on function
dir()          # Get attributes of object
```

#### Common NumPy Functions

```python
np.array()           # Create array
np.zeros()           # Create zeros
np.ones()            # Create ones
np.eye()             # Identity matrix
np.random.randn()    # Random normal
np.random.rand()     # Random uniform
np.reshape()         # Reshape array
np.concatenate()     # Concatenate arrays
np.mean()            # Mean
np.std()             # Standard deviation
np.sum()             # Sum
np.min()             # Minimum
np.max()             # Maximum
np.dot()             # Dot product
np.matmul()          # Matrix multiplication
np.transpose()       # Transpose
np.linalg.inv()      # Matrix inverse
np.linalg.eig()      # Eigenvalues
np.linalg.svd()      # SVD
```

---

**[END OF PRIMER 1]**
