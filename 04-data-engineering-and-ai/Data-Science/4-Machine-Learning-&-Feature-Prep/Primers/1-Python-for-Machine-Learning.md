# Primer 1: Python for Machine Learning

## Overview

This primer provides a crash course in Python for machine learning. It covers the essential Python concepts, libraries, and patterns you need to understand before diving into the main series. If you're comfortable with Python basics, you can skip this primer. If you're new to Python or need a refresher, this primer will get you up to speed.

---

## 1. Python Fundamentals

### Why Python for ML?

Python is the dominant language for machine learning because of:
- **Readability**: Clean, intuitive syntax
- **Ecosystem**: Rich libraries for every ML task
- **Community**: Massive community support
- **Integration**: Works with other languages and tools
- **Flexibility**: Rapid prototyping to production

### Python Basics

#### Variables and Data Types

```python
# Numeric types
integer = 42
float_num = 3.14159
complex_num = 3 + 4j

# String
string = "Hello, World!"

# Boolean
is_true = True
is_false = False

# None (null)
nothing = None

# Type checking
print(type(integer))  # <class 'int'>
print(type(string))   # <class 'str'>
print(type(is_true))  # <class 'bool'>

# Type conversion
int_to_float = float(42)      # 42.0
float_to_int = int(3.14)      # 3
str_to_int = int("123")       # 123
int_to_str = str(456)         # "456"
```

#### Collections

```python
# List - ordered, mutable
my_list = [1, 2, 3, 4, 5]
my_list.append(6)             # [1, 2, 3, 4, 5, 6]
my_list[0] = 10              # [10, 2, 3, 4, 5, 6]
print(my_list[1:3])          # [2, 3] (slicing)

# Tuple - ordered, immutable
my_tuple = (1, 2, 3)
# my_tuple[0] = 10  # ERROR! Cannot modify

# Dictionary - key-value pairs
my_dict = {'name': 'Alice', 'age': 30}
my_dict['city'] = 'New York'
print(my_dict['name'])       # 'Alice'
print(my_dict.get('country', 'USA'))  # 'USA' (default)

# Set - unordered, unique
my_set = {1, 2, 3, 4, 4}     # {1, 2, 3, 4}
my_set.add(5)                # {1, 2, 3, 4, 5}
my_set.remove(3)             # {1, 2, 4, 5}
```

#### Control Flow

```python
# If-elif-else
x = 10
if x > 0:
    print("Positive")
elif x < 0:
    print("Negative")
else:
    print("Zero")

# For loop
for i in range(5):          # 0, 1, 2, 3, 4
    print(i)

# For loop with enumerate
fruits = ['apple', 'banana', 'cherry']
for idx, fruit in enumerate(fruits):
    print(f"{idx}: {fruit}")

# While loop
count = 0
while count < 5:
    print(count)
    count += 1

# List comprehension
squares = [x**2 for x in range(10)]  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
even_squares = [x**2 for x in range(10) if x % 2 == 0]

# Dictionary comprehension
square_dict = {x: x**2 for x in range(5)}  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}
```

#### Functions

```python
# Basic function
def greet(name):
    """Greet someone by name."""
    return f"Hello, {name}!"

print(greet("Alice"))  # "Hello, Alice!"

# Default arguments
def greet_with_title(name, title="Mr."):
    return f"Hello, {title} {name}!"

print(greet_with_title("Smith"))        # "Hello, Mr. Smith!"
print(greet_with_title("Smith", "Dr.")) # "Hello, Dr. Smith!"

# Keyword arguments
def describe_person(name, age, city):
    return f"{name} is {age} years old from {city}"

print(describe_person(name="Alice", age=30, city="NYC"))

# Variable arguments
def sum_all(*args):
    return sum(args)

print(sum_all(1, 2, 3, 4, 5))  # 15

# Keyword variable arguments
def print_kwargs(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_kwargs(name="Alice", age=30)

# Lambda (anonymous) functions
square = lambda x: x**2
print(square(5))  # 25
```

#### Classes

```python
class Person:
    """A simple Person class."""
    
    # Class variable (shared across instances)
    species = "Homo sapiens"
    
    def __init__(self, name, age):
        """Constructor - called when creating an instance."""
        self.name = name      # Instance variable
        self.age = age
    
    def greet(self):
        """Instance method."""
        return f"Hello, my name is {self.name} and I'm {self.age} years old."
    
    @classmethod
    def get_species(cls):
        """Class method."""
        return cls.species
    
    @staticmethod
    def is_adult(age):
        """Static method."""
        return age >= 18

# Create instance
person = Person("Alice", 30)
print(person.greet())           # "Hello, my name is Alice and I'm 30 years old."
print(Person.get_species())     # "Homo sapiens"
print(Person.is_adult(25))      # True

# Inheritance
class Student(Person):
    def __init__(self, name, age, student_id):
        super().__init__(name, age)  # Call parent constructor
        self.student_id = student_id
    
    def greet(self):
        # Override parent method
        return f"Hello, I'm {self.name}, student ID: {self.student_id}"

student = Student("Bob", 20, "S12345")
print(student.greet())  # "Hello, I'm Bob, student ID: S12345"
```

#### File I/O

```python
# Writing to file
with open('file.txt', 'w') as f:
    f.write("Hello, World!\n")
    f.write("This is line 2")

# Reading from file
with open('file.txt', 'r') as f:
    content = f.read()
    print(content)

# Reading line by line
with open('file.txt', 'r') as f:
    for line in f:
        print(line.strip())

# Working with CSV
import csv

# Write CSV
with open('data.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['name', 'age', 'city'])
    writer.writerow(['Alice', 30, 'NYC'])
    writer.writerow(['Bob', 25, 'LA'])

# Read CSV
with open('data.csv', 'r') as f:
    reader = csv.reader(f)
    for row in reader:
        print(row)
```

### Useful Built-in Functions

```python
# map - apply function to all items
numbers = [1, 2, 3, 4, 5]
squared = list(map(lambda x: x**2, numbers))  # [1, 4, 9, 16, 25]

# filter - filter items based on condition
even = list(filter(lambda x: x % 2 == 0, numbers))  # [2, 4]

# reduce - reduce to a single value
from functools import reduce
product = reduce(lambda x, y: x * y, numbers)  # 120

# zip - pair up items from multiple lists
names = ['Alice', 'Bob', 'Charlie']
ages = [30, 25, 35]
pairs = list(zip(names, ages))  # [('Alice', 30), ('Bob', 25), ('Charlie', 35)]

# enumerate - get index and value
for idx, value in enumerate(['a', 'b', 'c']):
    print(f"{idx}: {value}")

# any/all
print(any([True, False, False]))  # True
print(all([True, True, True]))    # True

# sorted
print(sorted([3, 1, 4, 2]))       # [1, 2, 3, 4]
print(sorted([3, 1, 4, 2], reverse=True))  # [4, 3, 2, 1]
```

---

## 2. NumPy

NumPy is the foundation of numerical computing in Python. It provides arrays, mathematical functions, and linear algebra operations.

### NumPy Arrays

```python
import numpy as np

# Creating arrays
arr1 = np.array([1, 2, 3, 4, 5])      # 1D array
arr2 = np.array([[1, 2], [3, 4]])     # 2D array
arr3 = np.zeros((3, 4))               # 3x4 array of zeros
arr4 = np.ones((2, 3))                # 2x3 array of ones
arr5 = np.full((3, 3), 7)             # 3x3 array filled with 7
arr6 = np.eye(4)                      # 4x4 identity matrix
arr7 = np.random.randn(3, 4)          # 3x4 random normal values

# Array attributes
print(arr2.shape)    # (2, 2)
print(arr2.ndim)     # 2
print(arr2.dtype)    # int64
print(arr2.size)     # 4

# Reshaping
arr_reshaped = arr1.reshape(1, 5)     # Reshape to 1x5
arr_flattened = arr2.flatten()        # Flatten to 1D

# Indexing and slicing
arr = np.array([10, 20, 30, 40, 50])
print(arr[0])         # 10
print(arr[1:4])       # [20, 30, 40]
print(arr[::2])       # [10, 30, 50] (step 2)

# 2D indexing
arr2 = np.array([[1, 2, 3],
                 [4, 5, 6],
                 [7, 8, 9]])
print(arr2[0, 1])     # 2
print(arr2[1:, :2])   # [[4, 5], [7, 8]]
print(arr2[arr2 > 5]) # [6, 7, 8, 9] (boolean indexing)
```

### NumPy Operations

```python
# Element-wise operations
a = np.array([1, 2, 3, 4])
b = np.array([5, 6, 7, 8])

print(a + b)          # [6, 8, 10, 12]
print(a * b)          # [5, 12, 21, 32]
print(a ** 2)         # [1, 4, 9, 16]
print(np.sqrt(a))     # [1, 1.41, 1.73, 2]

# Broadcasting
print(a + 10)         # [11, 12, 13, 14]
print(a * 2)          # [2, 4, 6, 8]

# Statistical operations
data = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
print(np.mean(data))    # 5.5
print(np.median(data))  # 5.5
print(np.std(data))     # 2.87
print(np.var(data))     # 8.25
print(np.min(data))     # 1
print(np.max(data))     # 10
print(np.sum(data))     # 55

# Matrix operations
A = np.array([[1, 2], [3, 4]])
B = np.array([[5, 6], [7, 8]])

print(A @ B)           # Matrix multiplication ([[19, 22], [43, 50]])
print(np.dot(A, B))    # Same as @
print(A.T)             # Transpose
print(np.linalg.inv(A))  # Inverse ([[-2, 1], [1.5, -0.5]])
```

---

## 3. Pandas

Pandas is the go-to library for data manipulation and analysis. It provides DataFrames and Series for structured data.

### Pandas Basics

```python
import pandas as pd

# Creating Series
s = pd.Series([1, 2, 3, 4, 5], index=['a', 'b', 'c', 'd', 'e'])
print(s)

# Creating DataFrame
data = {
    'name': ['Alice', 'Bob', 'Charlie', 'Diana'],
    'age': [30, 25, 35, 28],
    'city': ['NYC', 'LA', 'Chicago', 'NYC'],
    'salary': [70000, 60000, 80000, 65000]
}
df = pd.DataFrame(data)
print(df)

# Reading data from file
df_csv = pd.read_csv('data.csv')
df_json = pd.read_json('data.json')
df_excel = pd.read_excel('data.xlsx')

# Quick exploration
print(df.head())          # First 5 rows
print(df.tail(3))         # Last 3 rows
print(df.info())          # Data types and null counts
print(df.describe())      # Summary statistics
print(df.shape)           # (4, 4)

# Accessing data
print(df['name'])         # Series (single column)
print(df[['name', 'age']]) # DataFrame (multiple columns)
print(df.iloc[0])         # First row by position
print(df.loc[0])          # First row by index
print(df.iloc[0, 1])      # First row, second column
print(df.loc[:, 'name'])  # All rows, 'name' column
```

### Data Manipulation

```python
# Filtering
high_salary = df[df['salary'] > 65000]
nyc_employees = df[df['city'] == 'NYC']

# Multiple conditions
filtered = df[(df['age'] > 25) & (df['city'] == 'NYC')]

# Sorting
sorted_by_age = df.sort_values('age', ascending=False)
sorted_by_salary = df.sort_values('salary')

# Grouping
grouped = df.groupby('city')
print(grouped['salary'].mean())  # Average salary by city
print(grouped['age'].agg(['mean', 'min', 'max']))

# Aggregations
print(df['salary'].mean())
print(df['salary'].max())
print(df['salary'].min())
print(df['salary'].std())

# Adding columns
df['age_squared'] = df['age'] ** 2
df['tax'] = df['salary'] * 0.2

# Applying functions
def categorize_age(age):
    if age < 30:
        return 'young'
    elif age < 40:
        return 'middle'
    else:
        return 'senior'

df['age_group'] = df['age'].apply(categorize_age)
df['salary_log'] = df['salary'].apply(np.log)

# Handling missing values
df_with_na = df.copy()
df_with_na.loc[1, 'age'] = np.nan
print(df_with_na.isnull().sum())  # Count nulls

# Fill missing values
df_filled = df_with_na.fillna({'age': df_with_na['age'].mean()})
df_dropped = df_with_na.dropna()

# Merge and join
df1 = pd.DataFrame({'id': [1, 2, 3], 'name': ['A', 'B', 'C']})
df2 = pd.DataFrame({'id': [2, 3, 4], 'score': [95, 85, 75]})

merged = pd.merge(df1, df2, on='id', how='inner')  # Inner join
merged_left = pd.merge(df1, df2, on='id', how='left')  # Left join

# Pivot tables
pivot = pd.pivot_table(df, values='salary', index='city', columns='age_group', aggfunc='mean')
```

---

## 4. Matplotlib and Seaborn

These libraries are used for data visualization.

### Matplotlib

```python
import matplotlib.pyplot as plt

# Line plot
x = [1, 2, 3, 4, 5]
y = [2, 4, 6, 8, 10]
plt.plot(x, y, label='Line', color='blue', marker='o')
plt.xlabel('X-axis')
plt.ylabel('Y-axis')
plt.title('Line Plot')
plt.legend()
plt.grid(True)
plt.show()

# Scatter plot
x = np.random.randn(50)
y = np.random.randn(50)
plt.scatter(x, y, alpha=0.5, color='red')
plt.xlabel('X')
plt.ylabel('Y')
plt.title('Scatter Plot')
plt.show()

# Histogram
data = np.random.randn(1000)
plt.hist(data, bins=30, alpha=0.7, color='green', edgecolor='black')
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.title('Histogram')
plt.show()

# Subplots
fig, axes = plt.subplots(2, 2, figsize=(10, 8))
axes[0, 0].plot(x, y)
axes[0, 1].scatter(x, y)
axes[1, 0].hist(data)
axes[1, 1].boxplot(data)
plt.tight_layout()
plt.show()

# Saving figures
plt.savefig('plot.png', dpi=300, bbox_inches='tight')
```

### Seaborn

```python
import seaborn as sns

# Set style
sns.set_style('whitegrid')
sns.set_palette('husl')

# Distribution plot
sns.histplot(data, bins=30, kde=True)
plt.show()

# Box plot
sns.boxplot(x='city', y='salary', data=df)
plt.show()

# Pair plot
sns.pairplot(df[['age', 'salary', 'tax']])
plt.show()

# Heatmap
corr = df[['age', 'salary', 'tax']].corr()
sns.heatmap(corr, annot=True, cmap='coolwarm')
plt.show()

# Violin plot
sns.violinplot(x='city', y='salary', data=df)
plt.show()

# Count plot
sns.countplot(x='city', data=df)
plt.show()
```

---

## 5. Scikit-learn Basics

Scikit-learn provides ML algorithms and preprocessing.

```python
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix

# Train-test split
X = df[['age', 'salary']]
y = df['city']  # Example target

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Scaling
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Encoding
encoder = LabelEncoder()
y_train_encoded = encoder.fit_transform(y_train)
y_test_encoded = encoder.transform(y_test)

# Model training
model = LogisticRegression()
model.fit(X_train_scaled, y_train_encoded)

# Predictions
y_pred = model.predict(X_test_scaled)

# Evaluation
accuracy = accuracy_score(y_test_encoded, y_pred)
cm = confusion_matrix(y_test_encoded, y_pred)

print(f"Accuracy: {accuracy:.4f}")
print("Confusion Matrix:")
print(cm)

# Feature importance (Random Forest)
rf = RandomForestClassifier()
rf.fit(X_train_scaled, y_train_encoded)
importance = rf.feature_importances_
for feature, imp in zip(X.columns, importance):
    print(f"{feature}: {imp:.4f}")
```

---

## 6. Type Hints (Python 3.5+)

```python
from typing import List, Dict, Optional, Tuple, Union

def process_data(data: List[int]) -> Dict[str, float]:
    """Process a list of integers."""
    return {
        'mean': float(np.mean(data)),
        'std': float(np.std(data))
    }

def get_user(name: str, age: Optional[int] = None) -> str:
    """Get user information."""
    if age is None:
        return f"User: {name}"
    return f"User: {name}, Age: {age}"

def split_data(
    X: np.ndarray,
    y: np.ndarray,
    test_size: float = 0.2
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Split data into train and test sets."""
    from sklearn.model_selection import train_test_split
    return train_test_split(X, y, test_size=test_size, random_state=42)

# Multiple return types
def get_dataframe_info(
    df: pd.DataFrame,
    include_stats: bool = True
) -> Union[str, Dict[str, any]]:
    """Get DataFrame information."""
    if include_stats:
        return df.describe().to_dict()
    return str(df.shape)
```

---

## 7. Exception Handling

```python
# Basic try-except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero!")

# Multiple exceptions
try:
    data = pd.read_csv('file.csv')
except FileNotFoundError:
    print("File not found!")
except pd.errors.EmptyDataError:
    print("File is empty!")
except Exception as e:
    print(f"Unexpected error: {e}")

# Finally
try:
    file = open('data.txt', 'r')
    content = file.read()
except FileNotFoundError:
    print("File not found!")
finally:
    file.close()  # Always executed

# Custom exceptions
class DataValidationError(Exception):
    pass

try:
    if len(df) < 100:
        raise DataValidationError("Not enough data!")
except DataValidationError as e:
    print(f"Validation error: {e}")

# Logging
import logging
logging.basicConfig(level=logging.INFO)

try:
    result = 10 / 0
except Exception as e:
    logging.error(f"Error occurred: {e}")
```

---

## 8. Common Python Patterns for ML

```python
# Configuration using dictionaries
config = {
    'model_type': 'random_forest',
    'n_estimators': 100,
    'max_depth': 10,
    'random_state': 42
}

# Function with configuration
def train_model(config, X, y):
    if config['model_type'] == 'random_forest':
        from sklearn.ensemble import RandomForestClassifier
        model = RandomForestClassifier(**config)
    elif config['model_type'] == 'xgboost':
        import xgboost as xgb
        model = xgb.XGBClassifier(**config)
    model.fit(X, y)
    return model

# Pipeline pattern
from sklearn.pipeline import Pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model', LogisticRegression())
])

# Decorator for timing
import time
def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end-start:.4f}s")
        return result
    return wrapper

@timer
def train_model(X, y):
    model = LogisticRegression()
    model.fit(X, y)
    return model

# Context manager for setup/teardown
class TrainingContext:
    def __enter__(self):
        print("Setting up training")
        return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        print("Cleaning up training")

with TrainingContext():
    print("Training model...")
```

---

## Quick Reference: Essential Python for ML

### Most Common Operations

```python
# Import libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

# Load data
df = pd.read_csv('data.csv')

# Explore data
df.head()
df.info()
df.describe()

# Select columns
X = df[['feature1', 'feature2']]
y = df['target']

# Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Scale
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# Train model
model = RandomForestClassifier()
model.fit(X_train_scaled, y_train)

# Predict
y_pred = model.predict(X_test_scaled)

# Evaluate
accuracy = accuracy_score(y_test, y_pred)
```

---

## Conclusion

This primer covers the essential Python knowledge you need for machine learning. If you're comfortable with these concepts, you're ready to dive into the main series. If any concepts feel unclear, take time to practice with the examples provided.

**Next Steps:**
1. Practice with real datasets (e.g., Kaggle)
2. Familiarize yourself with the libraries
3. Experiment with your own code
4. Proceed to Part 1 of the series

---

*End of Primer 1*
