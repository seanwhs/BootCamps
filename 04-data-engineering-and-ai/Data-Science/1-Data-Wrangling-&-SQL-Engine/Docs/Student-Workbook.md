# STUDENT WORKBOOK: Data Engineering & Data Science Mastery

## Complete Exercise Companion for the Series

---

## Introduction

This workbook is designed to accompany the main tutorial series and primers. It contains hands-on exercises, coding challenges, and practice problems for each major topic. Use this workbook to reinforce your learning, test your understanding, and build confidence in your skills.

**How to Use This Workbook:**

1. **Complete exercises after each module** - Don't skip ahead
2. **Write code from scratch** - Avoid copying solutions until you've tried
3. **Debug and experiment** - Break things on purpose to learn
4. **Track your progress** - Check off exercises as you complete them
5. **Review solutions** - Compare your approach with provided solutions

---

## WORKBOOK STRUCTURE

| Section | Topic | Exercises |
|---------|-------|-----------|
| W1 | Python Fundamentals | 5 exercises |
| W2 | SQL Fundamentals | 5 exercises |
| W3 | NumPy & Vectorization | 5 exercises |
| W4 | Pandas Data Manipulation | 5 exercises |
| W5 | Polars & Modern DataFrames | 5 exercises |
| W6 | DuckDB & Analytical SQL | 5 exercises |
| W7 | Data Quality & Validation | 5 exercises |
| W8 | EDA & Data Profiling | 5 exercises |
| W9 | Static Visualizations | 5 exercises |
| W10 | Interactive Visualizations | 5 exercises |
| W11 | Hypothesis Testing | 5 exercises |
| W12 | Statistical Modeling | 5 exercises |
| W13 | ETL Pipeline Project | 1 capstone |
| W14 | A/B Testing Capstone | 1 capstone |

---

## W1: Python Fundamentals Exercises

### Exercise W1.1: Data Type Practice

**Objective:** Work with different Python data types and type conversion.

```python
"""
Write a function that takes a mixed list of strings, numbers, and booleans
and returns a dictionary with counts of each type.

Example:
input: [1, "hello", True, 3.14, "world", False, 42]
output: {'int': 2, 'str': 2, 'bool': 2, 'float': 1}
"""

def count_types(data_list):
    # Your code here
    pass

# Test your function
test_data = [1, "hello", True, 3.14, "world", False, 42, None]
print(count_types(test_data))
```

<details>
<summary>Click for Solution</summary>

```python
def count_types(data_list):
    type_counts = {}
    for item in data_list:
        type_name = type(item).__name__
        type_counts[type_name] = type_counts.get(type_name, 0) + 1
    return type_counts

# Test
test_data = [1, "hello", True, 3.14, "world", False, 42, None]
print(count_types(test_data))
# Output: {'int': 2, 'str': 2, 'bool': 2, 'float': 1, 'NoneType': 1}
```
</details>

---

### Exercise W1.2: List Comprehensions

**Objective:** Master list comprehensions for efficient data transformation.

```python
"""
1. Given a list of numbers, create a list of their squares using list comprehension.
2. Given a list of numbers, create a list of even numbers only.
3. Given a list of strings, create a list of their lengths.
4. Given a list of strings, create a list of strings in uppercase.
5. Given a list of numbers, create a list of 'odd' or 'even' labels.

Example:
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
squares = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
evens = [2, 4, 6, 8, 10]
labels = ['odd', 'even', 'odd', 'even', ...]
"""

numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
strings = ["hello", "world", "python", "data", "science"]

# Your code here
squares = []
evens = []
lengths = []
uppercase = []
labels = []

print(f"Squares: {squares}")
print(f"Evens: {evens}")
print(f"Lengths: {lengths}")
print(f"Uppercase: {uppercase}")
print(f"Labels: {labels}")
```

<details>
<summary>Click for Solution</summary>

```python
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
strings = ["hello", "world", "python", "data", "science"]

squares = [x**2 for x in numbers]
evens = [x for x in numbers if x % 2 == 0]
lengths = [len(s) for s in strings]
uppercase = [s.upper() for s in strings]
labels = ['even' if x % 2 == 0 else 'odd' for x in numbers]

print(f"Squares: {squares}")
print(f"Evens: {evens}")
print(f"Lengths: {lengths}")
print(f"Uppercase: {uppercase}")
print(f"Labels: {labels}")
```
</details>

---

### Exercise W1.3: Dictionary Operations

**Objective:** Practice working with dictionaries for data aggregation.

```python
"""
Given a list of transactions, create:
1. A dictionary of total spending per customer
2. A dictionary of transaction count per customer
3. A dictionary of average transaction value per customer

Transactions format: [{'customer': 'Alice', 'amount': 100}, ...]
"""

transactions = [
    {'customer': 'Alice', 'amount': 100},
    {'customer': 'Bob', 'amount': 200},
    {'customer': 'Alice', 'amount': 150},
    {'customer': 'Carol', 'amount': 75},
    {'customer': 'Bob', 'amount': 50},
    {'customer': 'Alice', 'amount': 300},
    {'customer': 'David', 'amount': 250},
    {'customer': 'Carol', 'amount': 125},
]

def aggregate_transactions(transactions):
    # Your code here
    pass

result = aggregate_transactions(transactions)
print(f"Total spending: {result['total']}")
print(f"Transaction count: {result['count']}")
print(f"Average: {result['average']}")
```

<details>
<summary>Click for Solution</summary>

```python
def aggregate_transactions(transactions):
    totals = {}
    counts = {}
    
    for t in transactions:
        customer = t['customer']
        amount = t['amount']
        
        totals[customer] = totals.get(customer, 0) + amount
        counts[customer] = counts.get(customer, 0) + 1
    
    averages = {c: totals[c] / counts[c] for c in totals}
    
    return {
        'total': totals,
        'count': counts,
        'average': averages
    }

result = aggregate_transactions(transactions)
print(f"Total spending: {result['total']}")
print(f"Transaction count: {result['count']}")
print(f"Average: {result['average']}")
```
</details>

---

### Exercise W1.4: Error Handling

**Objective:** Implement robust error handling for data processing.

```python
"""
Write a function that processes a list of numbers and returns:
1. The sum
2. The average
3. The maximum

The function should handle:
- Empty lists
- Non-numeric values
- None values

Use try-except blocks appropriately.
"""

def process_numbers(numbers):
    # Your code here
    pass

# Test cases
test_cases = [
    [1, 2, 3, 4, 5],
    [],
    [1, None, 3, "four", 5],
    [10, 20, 30],
]

for test in test_cases:
    print(f"Input: {test}")
    result = process_numbers(test)
    print(f"Result: {result}")
    print()
```

<details>
<summary>Click for Solution</summary>

```python
def process_numbers(numbers):
    # Handle empty list
    if not numbers:
        return {'sum': 0, 'average': 0, 'max': None, 'error': 'Empty list'}
    
    # Filter out non-numeric values
    numeric_values = []
    errors = []
    
    for item in numbers:
        try:
            if item is not None:
                numeric_values.append(float(item))
        except (ValueError, TypeError):
            errors.append(f"Invalid value: {item}")
    
    if not numeric_values:
        return {'sum': 0, 'average': 0, 'max': None, 'error': 'No numeric values'}
    
    return {
        'sum': sum(numeric_values),
        'average': sum(numeric_values) / len(numeric_values),
        'max': max(numeric_values),
        'errors': errors if errors else None
    }

# Test cases
test_cases = [
    [1, 2, 3, 4, 5],
    [],
    [1, None, 3, "four", 5],
    [10, 20, 30],
]

for test in test_cases:
    print(f"Input: {test}")
    result = process_numbers(test)
    print(f"Result: {result}")
    print()
```
</details>

---

### Exercise W1.5: File I/O

**Objective:** Read and write data files with proper handling.

```python
"""
1. Write a function that reads a CSV file and returns a list of dictionaries.
2. Write a function that writes a list of dictionaries to a CSV file.
3. Handle errors (file not found, malformed data).

CSV format:
name,age,city
Alice,30,NYC
Bob,25,LA
Carol,35,Chicago
"""

import csv

def read_csv_to_dict(filename):
    # Your code here
    pass

def write_dict_to_csv(data, filename):
    # Your code here
    pass

# Test your functions
test_data = [
    {'name': 'Alice', 'age': 30, 'city': 'NYC'},
    {'name': 'Bob', 'age': 25, 'city': 'LA'},
    {'name': 'Carol', 'age': 35, 'city': 'Chicago'},
]

# Write data
write_dict_to_csv(test_data, 'test_output.csv')

# Read data
loaded_data = read_csv_to_dict('test_output.csv')
print(loaded_data)
```

<details>
<summary>Click for Solution</summary>

```python
import csv
import os

def read_csv_to_dict(filename):
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            return list(reader)
    except FileNotFoundError:
        print(f"File not found: {filename}")
        return []
    except Exception as e:
        print(f"Error reading file: {e}")
        return []

def write_dict_to_csv(data, filename):
    try:
        if not data:
            print("No data to write")
            return False
        
        fieldnames = data[0].keys()
        
        with open(filename, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)
        
        print(f"Successfully wrote {len(data)} rows to {filename}")
        return True
    
    except Exception as e:
        print(f"Error writing file: {e}")
        return False

# Test
test_data = [
    {'name': 'Alice', 'age': 30, 'city': 'NYC'},
    {'name': 'Bob', 'age': 25, 'city': 'LA'},
    {'name': 'Carol', 'age': 35, 'city': 'Chicago'},
]

write_dict_to_csv(test_data, 'test_output.csv')
loaded_data = read_csv_to_dict('test_output.csv')
print(loaded_data)

# Clean up
if os.path.exists('test_output.csv'):
    os.remove('test_output.csv')
```
</details>

---

## W2: SQL Fundamentals Exercises

### Exercise W2.1: Basic SELECT

**Objective:** Write basic SELECT queries to retrieve data.

```sql
/*
Given a customers table with columns:
customer_id, first_name, last_name, email, country, city, created_at

Write queries to:
1. Select all customers from the USA
2. Select customers from the UK or Canada
3. Select customers who signed up in 2025
4. Select customers sorted by last name descending
5. Select distinct countries
*/

-- Your SQL queries here
```

<details>
<summary>Click for Solution</summary>

```sql
-- 1. Select all customers from the USA
SELECT * FROM customers 
WHERE country = 'USA';

-- 2. Select customers from the UK or Canada
SELECT * FROM customers 
WHERE country IN ('UK', 'Canada');

-- 3. Select customers who signed up in 2025
SELECT * FROM customers 
WHERE EXTRACT(YEAR FROM created_at) = 2025;

-- 4. Select customers sorted by last name descending
SELECT * FROM customers 
ORDER BY last_name DESC;

-- 5. Select distinct countries
SELECT DISTINCT country FROM customers 
ORDER BY country;
```
</details>

---

### Exercise W2.2: Aggregations

**Objective:** Use aggregate functions and GROUP BY.

```sql
/*
Given an orders table with columns:
order_id, customer_id, order_date, total_amount, status

Write queries to:
1. Count total orders
2. Calculate total sales (sum of total_amount)
3. Calculate average order value
4. Find minimum and maximum order amount
5. Group by status and count orders in each status
6. Group by customer and find their total spending
7. Find customers who have spent more than $1000
*/

-- Your SQL queries here
```

<details>
<summary>Click for Solution</summary>

```sql
-- 1. Count total orders
SELECT COUNT(*) AS total_orders FROM orders;

-- 2. Calculate total sales
SELECT SUM(total_amount) AS total_sales FROM orders;

-- 3. Calculate average order value
SELECT AVG(total_amount) AS avg_order_value FROM orders;

-- 4. Find minimum and maximum order amount
SELECT 
    MIN(total_amount) AS min_order,
    MAX(total_amount) AS max_order
FROM orders;

-- 5. Group by status and count orders
SELECT 
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- 6. Group by customer and find total spending
SELECT 
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC;

-- 7. Find customers who have spent more than $1000
SELECT 
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > 1000
ORDER BY total_spent DESC;
```
</details>

---

### Exercise W2.3: Joins

**Objective:** Combine data from multiple tables.

```sql
/*
Given:
- customers: customer_id, first_name, last_name, email
- orders: order_id, customer_id, order_date, total_amount
- order_items: order_item_id, order_id, product_id, quantity, price
- products: product_id, product_name, category, price

Write queries to:
1. Show all orders with customer names
2. Show order details with product information
3. Find customers who have never placed an order
4. Calculate total revenue by product
5. Find the top 5 best-selling products (by quantity)
*/

-- Your SQL queries here
```

<details>
<summary>Click for Solution</summary>

```sql
-- 1. Show all orders with customer names
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    c.first_name,
    c.last_name,
    c.email
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- 2. Show order details with product information
SELECT 
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.price,
    oi.quantity * oi.price AS item_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_name;

-- 3. Find customers who have never placed an order
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 4. Calculate total revenue by product
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- 5. Find the top 5 best-selling products (by quantity)
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;
```
</details>

---

### Exercise W2.4: Window Functions

**Objective:** Use window functions for advanced analytics.

```sql
/*
Using the orders table:
order_id, customer_id, order_date, total_amount

Write queries to:
1. Rank orders by total_amount (highest first)
2. Find each customer's running total of spending
3. Calculate each order's percentage of total sales
4. Find the previous order amount for each customer
5. Calculate a 7-day moving average of daily sales
*/

-- Your SQL queries here
```

<details>
<summary>Click for Solution</summary>

```sql
-- 1. Rank orders by total_amount (highest first)
SELECT 
    order_id,
    customer_id,
    total_amount,
    RANK() OVER (ORDER BY total_amount DESC) AS amount_rank,
    DENSE_RANK() OVER (ORDER BY total_amount DESC) AS dense_rank
FROM orders;

-- 2. Find each customer's running total of spending
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
        ROWS UNBOUNDED PRECEDING
    ) AS running_total
FROM orders
ORDER BY customer_id, order_date;

-- 3. Calculate each order's percentage of total sales
SELECT 
    order_id,
    total_amount,
    total_amount / SUM(total_amount) OVER () * 100 AS pct_of_total
FROM orders
ORDER BY pct_of_total DESC;

-- 4. Find the previous order amount for each customer
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    LAG(total_amount, 1) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) AS previous_amount,
    total_amount - LAG(total_amount, 1) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) AS amount_change
FROM orders;

-- 5. Calculate a 7-day moving average of daily sales
WITH daily_sales AS (
    SELECT 
        DATE(order_date) AS sale_date,
        SUM(total_amount) AS daily_total
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT 
    sale_date,
    daily_total,
    AVG(daily_total) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ) AS moving_avg_7day
FROM daily_sales
ORDER BY sale_date;
```
</details>

---

### Exercise W2.5: CTEs and Subqueries

**Objective:** Use CTEs for complex, readable queries.

```sql
/*
Using customers, orders, order_items, and products tables:

Write a CTE-based query to find:
1. Customer lifetime value (total spending)
2. Average order value per customer
3. Total products purchased per customer
4. Customer segment based on spending

Then filter to show only high-value customers.
*/

-- Your SQL queries here
```

<details>
<summary>Click for Solution</summary>

```sql
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.quantity * oi.price) AS total_spent,
        AVG(oi.quantity * oi.price) AS avg_order_value,
        SUM(oi.quantity) AS total_products
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 1000 THEN 'High Value'
            WHEN total_spent >= 500 THEN 'Medium Value'
            WHEN total_spent > 0 THEN 'Low Value'
            ELSE 'No Purchases'
        END AS customer_segment
    FROM customer_metrics
)
SELECT 
    first_name,
    last_name,
    total_spent,
    order_count,
    avg_order_value,
    customer_segment
FROM customer_segments
WHERE customer_segment IN ('High Value', 'Medium Value')
ORDER BY total_spent DESC;
```
</details>

---

## W3: NumPy & Vectorization Exercises

### Exercise W3.1: Array Creation and Properties

**Objective:** Create and manipulate NumPy arrays.

```python
"""
Create NumPy arrays with different methods and explore their properties.
"""

import numpy as np

# 1. Create an array from a list
# 2. Create a 3x4 array of zeros
# 3. Create a 2x3 array of ones
# 4. Create a 4x4 identity matrix
# 5. Create an array with values from 0 to 100 step 5
# 6. Create a 3x3 array with random values from normal distribution
# 7. Print shape, size, dtype, ndim for each array
# 8. Reshape an array of 12 elements into 3x4

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np

# 1. Array from list
arr1 = np.array([1, 2, 3, 4, 5])
print(f"arr1: {arr1}")

# 2. Zeros
arr2 = np.zeros((3, 4))
print(f"\narr2 (zeros):\n{arr2}")

# 3. Ones
arr3 = np.ones((2, 3))
print(f"\narr3 (ones):\n{arr3}")

# 4. Identity matrix
arr4 = np.eye(4)
print(f"\narr4 (identity):\n{arr4}")

# 5. Range with step
arr5 = np.arange(0, 101, 5)
print(f"\narr5 (step 5): {arr5}")

# 6. Random normal
np.random.seed(42)
arr6 = np.random.randn(3, 3)
print(f"\narr6 (random normal):\n{arr6}")

# 7. Array properties
arrays = [arr1, arr2, arr3, arr4, arr5, arr6]
names = ['arr1', 'arr2', 'arr3', 'arr4', 'arr5', 'arr6']

for name, arr in zip(names, arrays):
    print(f"\n{name}:")
    print(f"  Shape: {arr.shape}")
    print(f"  Size: {arr.size}")
    print(f"  Dtype: {arr.dtype}")
    print(f"  Ndims: {arr.ndim}")

# 8. Reshape
arr = np.arange(12)
reshaped = arr.reshape(3, 4)
print(f"\nOriginal: {arr}")
print(f"Reshaped:\n{reshaped}")
```
</details>

---

### Exercise W3.2: Broadcasting

**Objective:** Understand and use broadcasting rules.

```python
"""
Demonstrate broadcasting by performing operations on arrays of different shapes.
"""

import numpy as np

# Create arrays
A = np.array([[1, 2, 3],
              [4, 5, 6]])
B = np.array([10, 20, 30])
C = np.array([[1],
              [2]])

# 1. Add B to each row of A
# 2. Add C to each column of A
# 3. Multiply A by 2
# 4. Multiply A by B
# 5. Add A + B + C
# 6. Try A + np.array([1, 2]) - what happens? (Error handling)

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np

A = np.array([[1, 2, 3],
              [4, 5, 6]])
B = np.array([10, 20, 30])
C = np.array([[1],
              [2]])

print("A:\n", A)
print("B:", B)
print("C:\n", C)

# 1. Add B to each row
print("\n1. A + B:\n", A + B)

# 2. Add C to each column
print("\n2. A + C:\n", A + C)

# 3. Multiply A by 2
print("\n3. A * 2:\n", A * 2)

# 4. Multiply A by B
print("\n4. A * B:\n", A * B)

# 5. Add A + B + C
print("\n5. A + B + C:\n", A + B + C)

# 6. Try A + np.array([1, 2]) - incompatible shapes
try:
    result = A + np.array([1, 2])
except ValueError as e:
    print("\n6. Error (expected):", e)
```
</details>

---

### Exercise W3.3: Vectorized Operations

**Objective:** Implement vectorized operations for performance.

```python
"""
Compare the performance of Python loops vs NumPy vectorized operations.
"""

import numpy as np
import time

# Create a large array
data = np.random.randn(1000000)

# Task: Calculate the square of each element and sum the results

# 1. Using a Python loop
def python_loop_square_sum(data):
    # Your code here
    pass

# 2. Using NumPy vectorized operations
def numpy_vectorized_square_sum(data):
    # Your code here
    pass

# 3. Using Python's built-in sum with list comprehension
def list_comprehension_square_sum(data):
    # Your code here
    pass

# Time each function
# Your timing code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
import time

data = np.random.randn(1000000)

# 1. Python loop
def python_loop_square_sum(data):
    total = 0
    for x in data:
        total += x ** 2
    return total

# 2. NumPy vectorized
def numpy_vectorized_square_sum(data):
    return np.sum(data ** 2)

# 3. List comprehension
def list_comprehension_square_sum(data):
    return sum([x ** 2 for x in data])

# Time each function
start = time.time()
result1 = python_loop_square_sum(data)
time1 = time.time() - start

start = time.time()
result2 = numpy_vectorized_square_sum(data)
time2 = time.time() - start

start = time.time()
result3 = list_comprehension_square_sum(data)
time3 = time.time() - start

print(f"Python loop: {time1:.4f} seconds")
print(f"NumPy vectorized: {time2:.4f} seconds")
print(f"List comprehension: {time3:.4f} seconds")
print(f"NumPy speedup: {time1/time2:.1f}x")
print(f"Results match: {np.isclose(result1, result2)}")
```
</details>

---

### Exercise W3.4: Boolean Indexing

**Objective:** Use boolean indexing for filtering and selection.

```python
"""
Use boolean indexing to filter and select data from arrays.
"""

import numpy as np

# Create an array with 100 random integers between 0 and 50
np.random.seed(42)
data = np.random.randint(0, 50, 100)

# 1. Find all values greater than 30
# 2. Find all values between 10 and 20 (inclusive)
# 3. Count the number of values greater than 25
# 4. Replace all values greater than 40 with 40
# 5. Create a new array with only the even numbers
# 6. Find the indices of all values greater than 35
# 7. Replace all negative values with 0 (create negative values first)

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np

np.random.seed(42)
data = np.random.randint(0, 50, 100)
print("Original data:", data[:20], "...")

# 1. Values > 30
gt_30 = data[data > 30]
print(f"\n1. Values > 30: {len(gt_30)} values, first 10: {gt_30[:10]}")

# 2. Values between 10 and 20
between_10_20 = data[(data >= 10) & (data <= 20)]
print(f"\n2. Values between 10 and 20: {len(between_10_20)} values")

# 3. Count values > 25
count_gt_25 = (data > 25).sum()
print(f"\n3. Count of values > 25: {count_gt_25}")

# 4. Replace > 40 with 40
data_capped = data.copy()
data_capped[data_capped > 40] = 40
print(f"\n4. Data capped at 40: {data_capped[:20]} ...")

# 5. Even numbers only
even_numbers = data[data % 2 == 0]
print(f"\n5. Even numbers: {len(even_numbers)} values")

# 6. Indices of values > 35
indices_gt_35 = np.where(data > 35)[0]
print(f"\n6. Indices of values > 35: {indices_gt_35[:10]}")

# 7. Replace negatives
data_with_negatives = data.copy()
data_with_negatives[::3] = -data_with_negatives[::3]  # Make every 3rd negative
data_no_negatives = data_with_negatives.copy()
data_no_negatives[data_no_negatives < 0] = 0
print(f"\n7. Original (with negatives): {data_with_negatives[:20]}...")
print(f"   After replacing negatives: {data_no_negatives[:20]}...")
```
</details>

---

### Exercise W3.5: Linear Algebra

**Objective:** Perform linear algebra operations with NumPy.

```python
"""
Solve a system of linear equations and perform matrix operations.
"""

import numpy as np

# Given the system:
# 3x + 2y = 8
# x + 4y = 11

# 1. Solve the system using numpy.linalg.solve
# 2. Verify the solution by computing A @ x
# 3. Calculate the determinant of A
# 4. Calculate the inverse of A
# 5. Calculate eigenvalues and eigenvectors of A

# Bonus: Solve a larger system:
# 2x + y - z = 8
# -3x - y + 2z = -11
# -2x + y + 2z = -3

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np

# System 1
A = np.array([[3, 2],
              [1, 4]])
b = np.array([8, 11])

# 1. Solve
x = np.linalg.solve(A, b)
print(f"1. Solution: x={x[0]:.2f}, y={x[1]:.2f}")

# 2. Verify
verification = A @ x
print(f"\n2. Verification: A @ x = {verification}, b = {b}")

# 3. Determinant
det = np.linalg.det(A)
print(f"\n3. Determinant of A: {det:.2f}")

# 4. Inverse
inv_A = np.linalg.inv(A)
print(f"\n4. Inverse of A:\n{inv_A}")

# 5. Eigenvalues and eigenvectors
eigenvalues, eigenvectors = np.linalg.eig(A)
print(f"\n5. Eigenvalues: {eigenvalues}")
print(f"   Eigenvectors:\n{eigenvectors}")

# Bonus: 3x3 system
A_bonus = np.array([[2, 1, -1],
                    [-3, -1, 2],
                    [-2, 1, 2]])
b_bonus = np.array([8, -11, -3])

x_bonus = np.linalg.solve(A_bonus, b_bonus)
print(f"\nBonus: Solution: x={x_bonus[0]:.2f}, y={x_bonus[1]:.2f}, z={x_bonus[2]:.2f}")
```
</details>

---

## W4: Pandas Data Manipulation Exercises

### Exercise W4.1: Data Loading and Inspection

**Objective:** Load data and perform initial inspection.

```python
"""
Load a dataset and perform initial exploratory analysis.
"""

import pandas as pd
import numpy as np

# Create a sample dataset
np.random.seed(42)
data = {
    'customer_id': range(1, 101),
    'name': [f'Customer_{i}' for i in range(1, 101)],
    'age': np.random.randint(18, 80, 100),
    'income': np.random.normal(50000, 20000, 100),
    'spending_score': np.random.normal(50, 20, 100),
    'country': np.random.choice(['USA', 'UK', 'Canada', 'Australia'], 100),
    'member_since': pd.date_range('2020-01-01', periods=100),
    'is_active': np.random.choice([True, False], 100)
}

df = pd.DataFrame(data)

# 1. Display the first 5 rows
# 2. Display the last 5 rows
# 3. Show summary info (info())
# 4. Show descriptive statistics (describe())
# 5. Show data types and memory usage
# 6. Check for missing values
# 7. Show unique values in country column
# 8. Show value counts for country column

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np

np.random.seed(42)
data = {
    'customer_id': range(1, 101),
    'name': [f'Customer_{i}' for i in range(1, 101)],
    'age': np.random.randint(18, 80, 100),
    'income': np.random.normal(50000, 20000, 100),
    'spending_score': np.random.normal(50, 20, 100),
    'country': np.random.choice(['USA', 'UK', 'Canada', 'Australia'], 100),
    'member_since': pd.date_range('2020-01-01', periods=100),
    'is_active': np.random.choice([True, False], 100)
}

df = pd.DataFrame(data)

print("1. First 5 rows:")
print(df.head())

print("\n2. Last 5 rows:")
print(df.tail())

print("\n3. DataFrame info:")
print(df.info())

print("\n4. Descriptive statistics:")
print(df.describe())

print("\n5. Data types:")
print(df.dtypes)

print(f"\n6. Memory usage: {df.memory_usage(deep=True).sum() / 1024:.2f} KB")

print("\n7. Missing values:")
print(df.isna().sum())

print("\n8. Unique countries:")
print(df['country'].unique())

print("\n9. Country value counts:")
print(df['country'].value_counts())
```
</details>

---

### Exercise W4.2: Data Cleaning

**Objective:** Handle missing values, duplicates, and outliers.

```python
"""
Clean a messy dataset.
"""

import pandas as pd
import numpy as np

# Create messy data
np.random.seed(42)
n = 200

df = pd.DataFrame({
    'id': range(1, n+1),
    'name': [f'User_{i}' for i in range(1, n+1)],
    'age': np.random.randint(18, 80, n),
    'income': np.random.normal(50000, 20000, n),
    'spending': np.random.normal(50, 20, n),
    'country': np.random.choice(['USA', 'UK', 'Canada'], n)
})

# Introduce issues
df.loc[np.random.random(n) < 0.05, 'age'] = np.nan
df.loc[np.random.random(n) < 0.05, 'income'] = np.nan
df.loc[np.random.random(n) < 0.05, 'spending'] = np.nan
df.loc[0, 'age'] = 150
df.loc[1, 'income'] = 1000000
df.loc[2, 'spending'] = 200
df = pd.concat([df, df.iloc[:5]])

# Tasks:
# 1. Check for missing values and duplicates
# 2. Handle missing values (fill numeric with median)
# 3. Remove duplicates
# 4. Handle outliers (age > 120, income > 99th percentile)
# 5. Validate data types
# 6. Add a derived column: income_category (Low, Medium, High)
# 7. Return cleaned DataFrame

def clean_data(df):
    # Your code here
    pass

cleaned_df = clean_data(df)
print(f"Original: {len(df)} rows")
print(f"Cleaned: {len(cleaned_df)} rows")
```

<details>
<summary>Click for Solution</summary>

```python
def clean_data(df):
    # Make a copy
    df_clean = df.copy()
    
    # 1. Check missing values
    missing = df_clean.isna().sum()
    print(f"Missing values before: {missing.sum()}")
    
    # 2. Handle missing values
    numeric_cols = ['age', 'income', 'spending']
    for col in numeric_cols:
        df_clean[col] = df_clean[col].fillna(df_clean[col].median())
    
    # 3. Remove duplicates
    df_clean = df_clean.drop_duplicates()
    
    # 4. Handle outliers
    # Age > 120 -> cap at 80 (reasonable max)
    df_clean.loc[df_clean['age'] > 80, 'age'] = 80
    
    # Income > 99th percentile -> cap at 99th percentile
    income_99 = df_clean['income'].quantile(0.99)
    df_clean.loc[df_clean['income'] > income_99, 'income'] = income_99
    
    # Spending > 99th percentile -> cap at 99th percentile
    spending_99 = df_clean['spending'].quantile(0.99)
    df_clean.loc[df_clean['spending'] > spending_99, 'spending'] = spending_99
    
    # 5. Validate data types
    df_clean['age'] = df_clean['age'].astype(int)
    df_clean['income'] = df_clean['income'].astype(float)
    df_clean['spending'] = df_clean['spending'].astype(float)
    
    # 6. Add derived column
    income_median = df_clean['income'].median()
    income_75 = df_clean['income'].quantile(0.75)
    
    df_clean['income_category'] = pd.cut(
        df_clean['income'],
        bins=[0, income_median, income_75, float('inf')],
        labels=['Low', 'Medium', 'High']
    )
    
    missing_after = df_clean.isna().sum().sum()
    print(f"Missing values after: {missing_after}")
    
    return df_clean

cleaned_df = clean_data(df)
print(f"\nOriginal: {len(df)} rows")
print(f"Cleaned: {len(cleaned_df)} rows")
print("\nCleaned DataFrame info:")
print(cleaned_df.info())
```
</details>

---

### Exercise W4.3: Grouping and Aggregation

**Objective:** Master group operations for analysis.

```python
"""
Perform grouping and aggregation operations.
"""

import pandas as pd
import numpy as np

np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'customer_id': np.random.randint(1, 101, n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'sales': np.random.uniform(10, 1000, n),
    'quantity': np.random.randint(1, 10, n),
    'date': pd.date_range('2025-01-01', periods=n)
})

# Tasks:
# 1. Group by category and calculate mean sales, median sales, and count
# 2. Group by region and calculate total sales
# 3. Group by category and region, calculate total quantity
# 4. Find the customer who spent the most in each category
# 5. Calculate daily total sales (group by date)
# 6. Calculate monthly average sales
# 7. Find the top 3 categories by total sales

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np

np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'customer_id': np.random.randint(1, 101, n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'sales': np.random.uniform(10, 1000, n),
    'quantity': np.random.randint(1, 10, n),
    'date': pd.date_range('2025-01-01', periods=n)
})

print("1. Category metrics:")
category_metrics = df.groupby('category')['sales'].agg(['mean', 'median', 'count'])
print(category_metrics)

print("\n2. Total sales by region:")
region_sales = df.groupby('region')['sales'].sum().sort_values(ascending=False)
print(region_sales)

print("\n3. Total quantity by category and region:")
cat_region_quantity = df.groupby(['category', 'region'])['quantity'].sum().unstack()
print(cat_region_quantity)

print("\n4. Top spending customer in each category:")
top_customer = df.groupby('category').apply(
    lambda x: x.loc[x['sales'].idxmax(), ['customer_id', 'sales']]
)
print(top_customer)

print("\n5. Daily total sales:")
daily_sales = df.groupby('date')['sales'].sum()
print(daily_sales.head(10))

print("\n6. Monthly average sales:")
df['month'] = df['date'].dt.to_period('M')
monthly_avg = df.groupby('month')['sales'].mean()
print(monthly_avg)

print("\n7. Top 3 categories by total sales:")
top_categories = df.groupby('category')['sales'].sum().sort_values(ascending=False).head(3)
print(top_categories)
```
</details>

---

### Exercise W4.4: Method Chaining

**Objective:** Write clean, efficient pipelines with method chaining.

```python
"""
Use method chaining to create a clean data processing pipeline.
"""

import pandas as pd
import numpy as np

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'id': range(1, n+1),
    'age': np.random.randint(18, 80, n),
    'income': np.random.normal(50000, 20000, n),
    'spending': np.random.normal(50, 20, n),
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Books'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# Convert the following step-by-step operations into a single method chain:

# 1. Filter to only customers with age > 25
# 2. Filter to only customers with income > 30000
# 3. Create a new column: spending_ratio = spending / income * 100
# 4. Group by category and region
# 5. Calculate mean spending_ratio
# 6. Sort by mean spending_ratio descending
# 7. Only show top 5 results

# Your code here (method chain)
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'id': range(1, n+1),
    'age': np.random.randint(18, 80, n),
    'income': np.random.normal(50000, 20000, n),
    'spending': np.random.normal(50, 20, n),
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Books'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# Method chain solution
result = (df
    .query('age > 25 and income > 30000')
    .assign(spending_ratio=lambda x: x['spending'] / x['income'] * 100)
    .groupby(['category', 'region'])['spending_ratio']
    .mean()
    .reset_index()
    .sort_values('spending_ratio', ascending=False)
    .head(5)
)

print("Top 5 category-region combinations by spending ratio:")
print(result)

# Alternative with pipe for custom functions
def log_result(df):
    print(f"Processing {len(df)} rows")
    return df

result_with_pipe = (df
    .pipe(log_result)
    .query('age > 25')
    .assign(spending_ratio=lambda x: x['spending'] / x['income'] * 100)
    .groupby('category')['spending_ratio']
    .mean()
    .sort_values(ascending=False)
)

print("\nCategory averages (with pipe):")
print(result_with_pipe)
```
</details>

---

### Exercise W4.5: Merging and Joining

**Objective:** Combine multiple DataFrames.

```python
"""
Combine data from multiple sources using merges and joins.
"""

import pandas as pd

# Customer data
customers = pd.DataFrame({
    'customer_id': [1, 2, 3, 4, 5, 6],
    'name': ['Alice', 'Bob', 'Carol', 'David', 'Eve', 'Frank'],
    'city': ['NYC', 'LA', 'Chicago', 'NYC', 'LA', 'Chicago']
})

# Order data
orders = pd.DataFrame({
    'order_id': [101, 102, 103, 104, 105, 106, 107],
    'customer_id': [1, 2, 1, 3, 4, 2, 5],
    'order_date': pd.date_range('2025-01-01', periods=7),
    'total': [100, 200, 150, 300, 250, 100, 400]
})

# Product data
products = pd.DataFrame({
    'product_id': [1, 2, 3, 4, 5],
    'product_name': ['Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Cable'],
    'category': ['Electronics', 'Accessories', 'Accessories', 'Electronics', 'Accessories']
})

# Order items
order_items = pd.DataFrame({
    'order_item_id': [1, 2, 3, 4, 5, 6, 7, 8],
    'order_id': [101, 101, 102, 103, 103, 104, 105, 106],
    'product_id': [1, 2, 3, 1, 4, 5, 2, 3],
    'quantity': [1, 2, 1, 1, 1, 3, 1, 2],
    'price': [1000, 50, 100, 1000, 300, 20, 50, 100]
})

# Tasks:
# 1. Merge orders with customers to show order details with customer names
# 2. Merge order_items with products to show product details in orders
# 3. Create a full view: order_id, customer_name, product_name, quantity, price, total
# 4. Find customers who have not placed any orders
# 5. Calculate total revenue per customer
# 6. Find the top 3 best-selling products (by quantity)

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd

customers = pd.DataFrame({
    'customer_id': [1, 2, 3, 4, 5, 6],
    'name': ['Alice', 'Bob', 'Carol', 'David', 'Eve', 'Frank'],
    'city': ['NYC', 'LA', 'Chicago', 'NYC', 'LA', 'Chicago']
})

orders = pd.DataFrame({
    'order_id': [101, 102, 103, 104, 105, 106, 107],
    'customer_id': [1, 2, 1, 3, 4, 2, 5],
    'order_date': pd.date_range('2025-01-01', periods=7),
    'total': [100, 200, 150, 300, 250, 100, 400]
})

products = pd.DataFrame({
    'product_id': [1, 2, 3, 4, 5],
    'product_name': ['Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Cable'],
    'category': ['Electronics', 'Accessories', 'Accessories', 'Electronics', 'Accessories']
})

order_items = pd.DataFrame({
    'order_item_id': [1, 2, 3, 4, 5, 6, 7, 8],
    'order_id': [101, 101, 102, 103, 103, 104, 105, 106],
    'product_id': [1, 2, 3, 1, 4, 5, 2, 3],
    'quantity': [1, 2, 1, 1, 1, 3, 1, 2],
    'price': [1000, 50, 100, 1000, 300, 20, 50, 100]
})

# 1. Orders with customer names
orders_with_customers = pd.merge(orders, customers, on='customer_id')
print("1. Orders with customer names:")
print(orders_with_customers[['order_id', 'name', 'order_date', 'total']])

# 2. Order items with product details
items_with_products = pd.merge(order_items, products, on='product_id')
print("\n2. Order items with product details:")
print(items_with_products[['order_item_id', 'order_id', 'product_name', 'quantity', 'price']])

# 3. Full view
full_view = (order_items
    .merge(orders, on='order_id')
    .merge(customers, on='customer_id')
    .merge(products, on='product_id')
)
print("\n3. Full view (sample):")
print(full_view[['order_id', 'name', 'product_name', 'quantity', 'price_x', 'total']].head())

# 4. Customers with no orders
customers_no_orders = customers[~customers['customer_id'].isin(orders['customer_id'])]
print("\n4. Customers with no orders:")
print(customers_no_orders)

# 5. Total revenue per customer
revenue_per_customer = (orders
    .groupby('customer_id')['total']
    .sum()
    .reset_index()
    .merge(customers, on='customer_id')
    .sort_values('total', ascending=False)
)
print("\n5. Total revenue per customer:")
print(revenue_per_customer)

# 6. Top 3 best-selling products
best_selling = (order_items
    .groupby('product_id')['quantity']
    .sum()
    .reset_index()
    .merge(products, on='product_id')
    .sort_values('quantity', ascending=False)
    .head(3)
)
print("\n6. Top 3 best-selling products:")
print(best_selling[['product_name', 'quantity']])
```
</details>

---

## W5: Polars & Modern DataFrames Exercises

### Exercise W5.1: Polars Basics

**Objective:** Get started with Polars DataFrames.

```python
"""
Create and manipulate Polars DataFrames.
"""

import polars as pl
import numpy as np

# 1. Create a DataFrame from a dictionary
# 2. Create a DataFrame from a list of dictionaries
# 3. Create a DataFrame from a NumPy array
# 4. Display DataFrame info (shape, columns, dtypes)
# 5. Select specific columns
# 6. Filter rows based on conditions
# 7. Add a new column
# 8. Sort the DataFrame

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import polars as pl
import numpy as np

# 1. From dictionary
df1 = pl.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35],
    'city': ['NYC', 'LA', 'Chicago']
})
print("1. From dict:")
print(df1)

# 2. From list of dicts
df2 = pl.DataFrame([
    {'name': 'Alice', 'age': 25},
    {'name': 'Bob', 'age': 30},
    {'name': 'Charlie', 'age': 35}
])
print("\n2. From list of dicts:")
print(df2)

# 3. From NumPy array
arr = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
df3 = pl.DataFrame(arr, schema=['col1', 'col2', 'col3'])
print("\n3. From NumPy:")
print(df3)

# 4. DataFrame info
print("\n4. DataFrame info:")
print(f"Shape: {df1.shape}")
print(f"Columns: {df1.columns}")
print(f"Dtypes: {df1.dtypes}")

# 5. Select columns
print("\n5. Select name and city:")
print(df1.select(['name', 'city']))

# 6. Filter rows
print("\n6. Filter age > 28:")
print(df1.filter(pl.col('age') > 28))

# 7. Add column
print("\n7. Add age_doubled column:")
print(df1.with_columns((pl.col('age') * 2).alias('age_doubled')))

# 8. Sort
print("\n8. Sort by age descending:")
print(df1.sort('age', descending=True))
```
</details>

---

### Exercise W5.2: Polars Expressions

**Objective:** Master Polars expression syntax.

```python
"""
Use Polars expressions for data manipulation.
"""

import polars as pl
import numpy as np

# Create DataFrame
np.random.seed(42)
df = pl.DataFrame({
    'id': range(1, 101),
    'value': np.random.randn(100),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 100),
    'date': pl.date_range(
        start='2025-01-01', 
        end='2025-04-10', 
        interval='1d'
    )[:100]
})

# 1. Select value and square it
# 2. Filter where value > 0
# 3. Add a column with value rounded to 2 decimals
# 4. Extract year, month, day from date
# 5. Group by category and calculate mean and std
# 6. Sort by category and date
# 7. Add a column with category prefix to id

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import polars as pl
import numpy as np

np.random.seed(42)
df = pl.DataFrame({
    'id': range(1, 101),
    'value': np.random.randn(100),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 100),
    'date': pl.date_range(
        start='2025-01-01', 
        end='2025-04-10', 
        interval='1d'
    )[:100]
})

# 1. Select value and square it
print("1. Value and square:")
print(df.select([
    pl.col('value'),
    (pl.col('value') ** 2).alias('value_squared')
]).head())

# 2. Filter where value > 0
print("\n2. Filter value > 0:")
print(df.filter(pl.col('value') > 0).head())

# 3. Add column with value rounded
print("\n3. Add rounded column:")
print(df.with_columns(
    pl.col('value').round(2).alias('value_rounded')
).head())

# 4. Extract date components
print("\n4. Date components:")
print(df.select([
    pl.col('date'),
    pl.col('date').dt.year().alias('year'),
    pl.col('date').dt.month().alias('month'),
    pl.col('date').dt.day().alias('day')
]).head())

# 5. Group by category
print("\n5. Group by category:")
print(df.group_by('category').agg([
    pl.col('value').mean().alias('mean_value'),
    pl.col('value').std().alias('std_value')
]))

# 6. Sort by category and date
print("\n6. Sort by category and date:")
print(df.sort(['category', 'date']).head())

# 7. Add category prefix to id
print("\n7. Category prefix:")
print(df.with_columns(
    (pl.col('category') + pl.col('id').cast(pl.Utf8)).alias('category_id')
).head())
```
</details>

---

### Exercise W5.3: Lazy Evaluation

**Objective:** Use lazy evaluation for performance optimization.

```python
"""
Implement lazy evaluation with Polars.
"""

import polars as pl
import numpy as np
import time

# Create a large DataFrame
n = 5_000_000
print(f"Creating DataFrame with {n:,} rows...")

data = {
    'id': range(n),
    'value': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n),
    'subcategory': np.random.choice(['X', 'Y', 'Z'], n)
}
df = pl.DataFrame(data)

# 1. Write the DataFrame to a Parquet file
# 2. Read it back using lazy evaluation (pl.scan_parquet)
# 3. Apply transformations (filter, group, aggregate)
# 4. Execute the query with .collect()
# 5. Compare performance with eager execution

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import polars as pl
import numpy as np
import time

# Create data
n = 5_000_000
print(f"Creating DataFrame with {n:,} rows...")

data = {
    'id': range(n),
    'value': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n),
    'subcategory': np.random.choice(['X', 'Y', 'Z'], n)
}
df = pl.DataFrame(data)

# 1. Write to Parquet
print("\n1. Writing to Parquet...")
start = time.time()
df.write_parquet('data/large_data.parquet')
print(f"   Time: {time.time() - start:.2f}s")

# 2. Lazy read
print("\n2. Lazy read with scan_parquet")
lazy_df = pl.scan_parquet('data/large_data.parquet')
print(f"   Lazy DataFrame created")

# 3. Build query plan
print("\n3. Building query plan...")
query = (lazy_df
    .filter(pl.col('value') > 0)
    .group_by(['category', 'subcategory'])
    .agg([
        pl.col('value').mean().alias('mean_value'),
        pl.col('value').std().alias('std_value'),
        pl.col('id').count().alias('count')
    ])
    .sort('mean_value', descending=True)
)

print("   Query plan created (not executed yet)")

# 4. Execute with collect
print("\n4. Executing query with .collect()...")
start = time.time()
result = query.collect()
lazy_time = time.time() - start
print(f"   Time: {lazy_time:.2f}s")
print(f"   Result shape: {result.shape}")

# 5. Compare with eager
print("\n5. Comparing with eager execution...")
eager_start = time.time()
eager_result = (df
    .filter(pl.col('value') > 0)
    .group_by(['category', 'subcategory'])
    .agg([
        pl.col('value').mean().alias('mean_value'),
        pl.col('value').std().alias('std_value'),
        pl.col('id').count().alias('count')
    ])
    .sort('mean_value', descending=True)
)
eager_time = time.time() - eager_start
print(f"   Eager time: {eager_time:.2f}s")
print(f"   Lazy time: {lazy_time:.2f}s")
print(f"   Speedup: {eager_time/lazy_time:.1f}x")

# 6. Show query plan
print("\n6. Query plan:")
print(query)

# Clean up
import os
if os.path.exists('data/large_data.parquet'):
    os.remove('data/large_data.parquet')
```
</details>

---

### Exercise W5.4: Performance Comparison

**Objective:** Compare Polars vs Pandas performance.

```python
"""
Benchmark Polars vs Pandas on common operations.
"""

import polars as pl
import pandas as pd
import numpy as np
import time

# Create a large dataset
n = 1_000_000
print(f"Benchmarking with {n:,} rows...")

data = {
    'id': range(n),
    'value': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
}

# 1. Create DataFrames
# 2. Test: Group by + Aggregate (mean, std, count)
# 3. Test: Filter + Sort
# 4. Test: Multiple operations chain
# 5. Report speedup

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import polars as pl
import pandas as pd
import numpy as np
import time

n = 1_000_000
print(f"Benchmarking with {n:,} rows...\n")

data = {
    'id': range(n),
    'value': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
}

# Create DataFrames
print("Creating DataFrames...")
start = time.time()
df_pandas = pd.DataFrame(data)
pandas_create = time.time() - start

start = time.time()
df_polars = pl.DataFrame(data)
polars_create = time.time() - start

print(f"Pandas create: {pandas_create:.3f}s")
print(f"Polars create: {polars_create:.3f}s")

# Test 1: Group by + Aggregate
print("\n1. Group by + Aggregate:")
start = time.time()
result_pd = df_pandas.groupby('category')['value'].agg(['mean', 'std', 'count'])
pandas_time1 = time.time() - start

start = time.time()
result_pl = df_polars.group_by('category').agg([
    pl.col('value').mean(),
    pl.col('value').std(),
    pl.col('value').count()
])
polars_time1 = time.time() - start

print(f"  Pandas: {pandas_time1:.4f}s")
print(f"  Polars: {polars_time1:.4f}s")
print(f"  Speedup: {pandas_time1/polars_time1:.1f}x")

# Test 2: Filter + Sort
print("\n2. Filter + Sort:")
start = time.time()
result_pd = df_pandas[df_pandas['value'] > 0].sort_values('value')
pandas_time2 = time.time() - start

start = time.time()
result_pl = df_polars.filter(pl.col('value') > 0).sort('value')
polars_time2 = time.time() - start

print(f"  Pandas: {pandas_time2:.4f}s")
print(f"  Polars: {polars_time2:.4f}s")
print(f"  Speedup: {pandas_time2/polars_time2:.1f}x")

# Test 3: Complex chain
print("\n3. Complex chain:")
start = time.time()
result_pd = (df_pandas
    .query('value > 0')
    .groupby(['category', 'region'])['value']
    .mean()
    .reset_index()
    .sort_values('value', ascending=False)
)
pandas_time3 = time.time() - start

start = time.time()
result_pl = (df_polars
    .filter(pl.col('value') > 0)
    .group_by(['category', 'region'])
    .agg(pl.col('value').mean())
    .sort('value', descending=True)
)
polars_time3 = time.time() - start

print(f"  Pandas: {pandas_time3:.4f}s")
print(f"  Polars: {polars_time3:.4f}s")
print(f"  Speedup: {pandas_time3/polars_time3:.1f}x")

print("\nSummary:")
print(f"  Average speedup: {(pandas_time1/polars_time1 + pandas_time2/polars_time2 + pandas_time3/polars_time3) / 3:.1f}x")
```
</details>

---

### Exercise W5.5: Streaming with Polars

**Objective:** Process data larger than RAM using streaming.

```python
"""
Use Polars streaming to process data that doesn't fit in memory.
"""

import polars as pl
import numpy as np
import os

# Create a large CSV file (simulated)
n = 5_000_000
print(f"Creating dataset with {n:,} rows...")

# Write in chunks to simulate large file
chunk_size = 500_000
num_chunks = n // chunk_size

if not os.path.exists('data'):
    os.makedirs('data')

# Write header first
with open('data/large_data.csv', 'w') as f:
    f.write('id,value,category\n')

# Write data in chunks
for i in range(num_chunks):
    chunk_data = {
        'id': range(i*chunk_size + 1, (i+1)*chunk_size + 1),
        'value': np.random.randn(chunk_size),
        'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], chunk_size)
    }
    chunk_df = pl.DataFrame(chunk_data)
    chunk_df.write_csv('data/large_data.csv', append=True)

file_size = os.path.getsize('data/large_data.csv') / (1024 * 1024)
print(f"File size: {file_size:.1f} MB")

# 1. Read with streaming
# 2. Apply transformations
# 3. Collect results

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import polars as pl
import numpy as np
import os
import time

# Check if file exists
if not os.path.exists('data/large_data.csv'):
    print("Creating dataset...")
    n = 5_000_000
    chunk_size = 500_000
    num_chunks = n // chunk_size
    
    if not os.path.exists('data'):
        os.makedirs('data')
    
    # Write header
    with open('data/large_data.csv', 'w') as f:
        f.write('id,value,category\n')
    
    # Write chunks
    for i in range(num_chunks):
        chunk_data = {
            'id': range(i*chunk_size + 1, (i+1)*chunk_size + 1),
            'value': np.random.randn(chunk_size),
            'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], chunk_size)
        }
        chunk_df = pl.DataFrame(chunk_data)
        chunk_df.write_csv('data/large_data.csv', append=True)
        if (i+1) % 5 == 0:
            print(f"  Written {i+1}/{num_chunks} chunks...")

file_size = os.path.getsize('data/large_data.csv') / (1024 * 1024)
print(f"File size: {file_size:.1f} MB\n")

# 1. Streaming read with scan_csv
print("1. Using scan_csv for streaming:")
start = time.time()
lazy_df = pl.scan_csv('data/large_data.csv')
print(f"   Lazy DataFrame created in {time.time() - start:.2f}s")

# 2. Apply transformations
print("\n2. Building query plan...")
query = (lazy_df
    .filter(pl.col('value') > 0)
    .group_by('category')
    .agg([
        pl.col('value').mean().alias('mean_value'),
        pl.col('value').std().alias('std_value'),
        pl.col('id').count().alias('count')
    ])
    .sort('mean_value', descending=True)
)

print("   Query plan built")

# 3. Execute with streaming
print("\n3. Executing with streaming...")
start = time.time()
result = query.collect(streaming=True)
streaming_time = time.time() - start
print(f"   Streaming time: {streaming_time:.2f}s")
print(f"   Result shape: {result.shape}")
print(f"   Results:\n{result}")

# Compare with non-streaming
print("\n4. Comparing with eager execution...")
eager_start = time.time()
eager_result = query.collect(streaming=False)
eager_time = time.time() - eager_start
print(f"   Eager time: {eager_time:.2f}s")
print(f"   Streaming time: {streaming_time:.2f}s")
print(f"   Speedup: {eager_time/streaming_time:.1f}x")

# Clean up
if os.path.exists('data/large_data.csv'):
    os.remove('data/large_data.csv')
```
</details>

---

## W6: DuckDB & Analytical SQL Exercises

### Exercise W6.1: DuckDB Basics

**Objective:** Get started with DuckDB for analytical queries.

```python
"""
Use DuckDB to query data efficiently.
"""

import duckdb
import pandas as pd
import numpy as np

# Create a sample DataFrame
np.random.seed(42)
df = pd.DataFrame({
    'id': range(1, 1001),
    'value': np.random.randn(1000),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 1000),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 1000),
    'date': pd.date_range('2025-01-01', periods=1000)
})

# 1. Connect to DuckDB
# 2. Register the DataFrame as a view
# 3. Run SQL queries on the DataFrame
# 4. Get results as a DataFrame
# 5. Query CSV files directly

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import duckdb
import pandas as pd
import numpy as np

np.random.seed(42)
df = pd.DataFrame({
    'id': range(1, 1001),
    'value': np.random.randn(1000),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 1000),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 1000),
    'date': pd.date_range('2025-01-01', periods=1000)
})

# 1. Connect
conn = duckdb.connect(':memory:')
print("1. Connected to DuckDB")

# 2. Register DataFrame
conn.register('data', df)
print("2. Registered DataFrame as 'data'")

# 3. Run queries
print("\n3. SQL Queries:")
result = conn.execute("""
    SELECT 
        category,
        COUNT(*) as count,
        AVG(value) as mean_value,
        STDDEV(value) as std_value
    FROM data
    GROUP BY category
    ORDER BY mean_value DESC
""").fetchdf()
print(result)

# 4. More complex query
print("\n4. Complex query with CTE:")
result = conn.execute("""
    WITH category_stats AS (
        SELECT 
            category,
            AVG(value) as avg_value,
            STDDEV(value) as std_value
        FROM data
        GROUP BY category
    )
    SELECT 
        d.id,
        d.value,
        d.category,
        s.avg_value,
        (d.value - s.avg_value) / s.std_value as z_score
    FROM data d
    JOIN category_stats s ON d.category = s.category
    WHERE ABS((d.value - s.avg_value) / s.std_value) > 2
    ORDER BY z_score DESC
""").fetchdf()
print(f"Found {len(result)} outliers")
print(result.head())

# 5. Query CSV (write sample first)
df.to_csv('data/sample_data.csv', index=False)
print("\n5. Querying CSV directly:")
result = conn.execute("""
    SELECT 
        region,
        AVG(value) as avg_value
    FROM 'data/sample_data.csv'
    GROUP BY region
    ORDER BY avg_value DESC
""").fetchdf()
print(result)

# Clean up
import os
if os.path.exists('data/sample_data.csv'):
    os.remove('data/sample_data.csv')
```
</details>

---

### Exercise W6.2: File Querying

**Objective:** Query CSV and Parquet files directly with DuckDB.

```python
"""
Query external files without loading them into memory.
"""

import duckdb
import pandas as pd
import numpy as np
import os

# 1. Create sample CSV and Parquet files
# 2. Query CSV directly
# 3. Query Parquet directly
# 4. Join data from multiple files
# 5. Write query results to a new file

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import duckdb
import pandas as pd
import numpy as np
import os

# Create data directory
os.makedirs('data', exist_ok=True)

# 1. Create sample files
np.random.seed(42)

# File 1: Customer data
customers = pd.DataFrame({
    'customer_id': range(1, 101),
    'name': [f'Customer_{i}' for i in range(1, 101)],
    'country': np.random.choice(['USA', 'UK', 'Canada', 'Australia'], 100)
})
customers.to_csv('data/customers.csv', index=False)

# File 2: Sales data
sales = pd.DataFrame({
    'sale_id': range(1, 1001),
    'customer_id': np.random.randint(1, 101, 1000),
    'amount': np.random.uniform(10, 1000, 1000),
    'date': pd.date_range('2025-01-01', periods=1000)
})
sales.to_parquet('data/sales.parquet')

print("Created sample files:")
print("  - data/customers.csv")
print("  - data/sales.parquet")

# 2. Query CSV directly
conn = duckdb.connect(':memory:')
print("\n2. Querying CSV:")
csv_result = conn.execute("""
    SELECT 
        country,
        COUNT(*) as customer_count
    FROM 'data/customers.csv'
    GROUP BY country
    ORDER BY customer_count DESC
""").fetchdf()
print(csv_result)

# 3. Query Parquet directly
print("\n3. Querying Parquet:")
parquet_result = conn.execute("""
    SELECT 
        DATE_TRUNC('month', date) as month,
        SUM(amount) as total_sales,
        COUNT(*) as transaction_count
    FROM 'data/sales.parquet'
    GROUP BY DATE_TRUNC('month', date)
    ORDER BY month
""").fetchdf()
print(parquet_result.head())

# 4. Join across files
print("\n4. Join CSV and Parquet:")
join_result = conn.execute("""
    SELECT 
        c.country,
        DATE_TRUNC('month', s.date) as month,
        SUM(s.amount) as total_sales
    FROM 'data/customers.csv' c
    JOIN 'data/sales.parquet' s ON c.customer_id = s.customer_id
    GROUP BY c.country, DATE_TRUNC('month', s.date)
    ORDER BY c.country, month
""").fetchdf()
print(join_result.head())

# 5. Write results
print("\n5. Writing query results:")
conn.execute("""
    COPY (
        SELECT 
            c.country,
            SUM(s.amount) as total_sales,
            AVG(s.amount) as avg_sale
        FROM 'data/customers.csv' c
        JOIN 'data/sales.parquet' s ON c.customer_id = s.customer_id
        GROUP BY c.country
        ORDER BY total_sales DESC
    ) TO 'data/country_sales.csv' (HEADER, DELIMITER ',')
""")
print("  Written to data/country_sales.csv")

# Clean up
for f in ['data/customers.csv', 'data/sales.parquet', 'data/country_sales.csv']:
    if os.path.exists(f):
        os.remove(f)
```
</details>

---

### Exercise W6.3: Advanced SQL

**Objective:** Use advanced SQL features with DuckDB.

```python
"""
Implement advanced SQL patterns with DuckDB.
"""

import duckdb
import pandas as pd
import numpy as np

# Create sample data
np.random.seed(42)
n = 1000

# Sales data
sales = pd.DataFrame({
    'sale_id': range(1, n+1),
    'customer_id': np.random.randint(1, 101, n),
    'product_id': np.random.randint(1, 21, n),
    'amount': np.random.uniform(10, 500, n),
    'date': pd.date_range('2025-01-01', periods=n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# Product data
products = pd.DataFrame({
    'product_id': range(1, 21),
    'product_name': [f'Product_{i}' for i in range(1, 21)],
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports'], 20),
    'cost': np.random.uniform(5, 200, 20)
})

# 1. Use window functions
# 2. Use CTEs
# 3. Use recursive CTEs
# 4. Complex aggregations
# 5. Pivot/Unpivot operations

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import duckdb
import pandas as pd
import numpy as np

np.random.seed(42)
n = 1000

sales = pd.DataFrame({
    'sale_id': range(1, n+1),
    'customer_id': np.random.randint(1, 101, n),
    'product_id': np.random.randint(1, 21, n),
    'amount': np.random.uniform(10, 500, n),
    'date': pd.date_range('2025-01-01', periods=n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

products = pd.DataFrame({
    'product_id': range(1, 21),
    'product_name': [f'Product_{i}' for i in range(1, 21)],
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports'], 20),
    'cost': np.random.uniform(5, 200, 20)
})

conn = duckdb.connect(':memory:')
conn.register('sales', sales)
conn.register('products', products)

# 1. Window functions
print("1. Window functions - Running total per customer:")
result = conn.execute("""
    SELECT 
        customer_id,
        sale_id,
        date,
        amount,
        SUM(amount) OVER (
            PARTITION BY customer_id 
            ORDER BY date
            ROWS UNBOUNDED PRECEDING
        ) as running_total
    FROM sales
    ORDER BY customer_id, date
    LIMIT 10
""").fetchdf()
print(result)

# 2. CTEs
print("\n2. CTE - Customer segmentation:")
result = conn.execute("""
    WITH customer_totals AS (
        SELECT 
            customer_id,
            SUM(amount) as total_spent,
            COUNT(*) as order_count
        FROM sales
        GROUP BY customer_id
    ),
    customer_segments AS (
        SELECT 
            *,
            CASE 
                WHEN total_spent >= 5000 THEN 'High Value'
                WHEN total_spent >= 2000 THEN 'Medium Value'
                ELSE 'Low Value'
            END as segment
        FROM customer_totals
    )
    SELECT 
        segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_spent
    FROM customer_segments
    GROUP BY segment
""").fetchdf()
print(result)

# 3. Recursive CTE
print("\n3. Recursive CTE - Date series:")
result = conn.execute("""
    WITH RECURSIVE date_series AS (
        SELECT '2025-01-01'::DATE as date
        UNION ALL
        SELECT date + INTERVAL '1 day'
        FROM date_series
        WHERE date < '2025-01-10'
    )
    SELECT * FROM date_series
""").fetchdf()
print(result)

# 4. Complex aggregation
print("\n4. Complex aggregation - Monthly stats with running totals:")
result = conn.execute("""
    WITH monthly_sales AS (
        SELECT 
            DATE_TRUNC('month', date) as month,
            SUM(amount) as total_sales,
            AVG(amount) as avg_sale,
            COUNT(*) as transaction_count
        FROM sales
        GROUP BY DATE_TRUNC('month', date)
    )
    SELECT 
        month,
        total_sales,
        avg_sale,
        transaction_count,
        SUM(total_sales) OVER (ORDER BY month) as running_total,
        total_sales - LAG(total_sales, 1) OVER (ORDER BY month) as month_change
    FROM monthly_sales
    ORDER BY month
""").fetchdf()
print(result)

# 5. Pivot/Unpivot (using CASE)
print("\n5. Pivot - Sales by region and category:")
result = conn.execute("""
    SELECT 
        DATE_TRUNC('month', s.date) as month,
        p.category,
        SUM(CASE WHEN s.region = 'North' THEN s.amount ELSE 0 END) as north_sales,
        SUM(CASE WHEN s.region = 'South' THEN s.amount ELSE 0 END) as south_sales,
        SUM(CASE WHEN s.region = 'East' THEN s.amount ELSE 0 END) as east_sales,
        SUM(CASE WHEN s.region = 'West' THEN s.amount ELSE 0 END) as west_sales
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY DATE_TRUNC('month', s.date), p.category
    ORDER BY month, category
""").fetchdf()
print(result.head())
```
</details>

---

### Exercise W6.4: Performance Tuning

**Objective:** Optimize DuckDB queries for performance.

```python
"""
Analyze and optimize DuckDB query performance.
"""

import duckdb
import pandas as pd
import numpy as np
import time

# Create a large dataset
n = 1_000_000
print(f"Creating dataset with {n:,} rows...")

df = pd.DataFrame({
    'id': range(n),
    'value1': np.random.randn(n),
    'value2': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n),
    'subcategory': np.random.choice(['X', 'Y', 'Z'], n),
    'date': pd.date_range('2025-01-01', periods=n)
})

# 1. Run queries with and without optimization
# 2. Use EXPLAIN to see query plans
# 3. Compare performance of different approaches

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import duckdb
import pandas as pd
import numpy as np
import time

n = 1_000_000
print(f"Creating dataset with {n:,} rows...")

df = pd.DataFrame({
    'id': range(n),
    'value1': np.random.randn(n),
    'value2': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n),
    'subcategory': np.random.choice(['X', 'Y', 'Z'], n),
    'date': pd.date_range('2025-01-01', periods=n)
})

conn = duckdb.connect(':memory:')
conn.register('data', df)

print("Memory database created")

# 1. Query with WHERE filter
print("\n1. Query with WHERE filter:")
start = time.time()
result = conn.execute("""
    SELECT 
        category,
        AVG(value1) as avg_value1,
        SUM(value2) as sum_value2
    FROM data
    WHERE value1 > 0 AND value2 > 0
    GROUP BY category
""").fetchdf()
time1 = time.time() - start
print(f"   Time: {time1:.2f}s")
print(f"   Result: {result}")

# 2. Query with JOIN
print("\n2. Creating subcategories table...")
subcats = pd.DataFrame({
    'subcategory': ['X', 'Y', 'Z'],
    'description': ['Sub A', 'Sub B', 'Sub C']
})
conn.register('subcats', subcats)

start = time.time()
result = conn.execute("""
    SELECT 
        d.category,
        s.description,
        AVG(d.value1) as avg_value1,
        COUNT(*) as count
    FROM data d
    JOIN subcats s ON d.subcategory = s.subcategory
    WHERE d.value1 > 0
    GROUP BY d.category, s.description
    ORDER BY avg_value1 DESC
""").fetchdf()
time2 = time.time() - start
print(f"   Time: {time2:.2f}s")
print(f"   Result shape: {result.shape}")

# 3. EXPLAIN ANALYZE
print("\n3. EXPLAIN ANALYZE:")
explain_result = conn.execute("""
    EXPLAIN ANALYZE
    SELECT 
        category,
        AVG(value1) as avg_value1
    FROM data
    WHERE value1 > 0
    GROUP BY category
""").fetchdf()
print(explain_result)

# 4. Optimized query with pre-aggregation
print("\n4. Optimized query with pre-aggregation (CTE):")
start = time.time()
result = conn.execute("""
    WITH filtered AS (
        SELECT 
            category,
            value1
        FROM data
        WHERE value1 > 0
    )
    SELECT 
        category,
        AVG(value1) as avg_value1,
        COUNT(*) as count
    FROM filtered
    GROUP BY category
""").fetchdf()
time4 = time.time() - start
print(f"   Time: {time4:.2f}s")
print(f"   Speedup: {time1/time4:.1f}x")

# 5. View query plan
print("\n5. Query plan:")
plan = conn.execute("EXPLAIN SELECT * FROM data WHERE value1 > 0 LIMIT 10").fetchdf()
print(plan.head())
```
</details>

---

### Exercise W6.5: Integration with Pandas

**Objective:** Seamlessly integrate DuckDB with Pandas workflows.

```python
"""
Combine DuckDB SQL with Pandas for hybrid workflows.
"""

import duckdb
import pandas as pd
import numpy as np

# 1. Create data in Pandas
# 2. Process with DuckDB SQL
# 3. Return results to Pandas
# 4. Continue Pandas processing
# 5. Use DuckDB for aggregations and Pandas for visualizations

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import duckdb
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# 1. Create data in Pandas
np.random.seed(42)
n = 10000

df = pd.DataFrame({
    'customer_id': np.random.randint(1, 101, n),
    'product_id': np.random.randint(1, 21, n),
    'amount': np.random.uniform(10, 500, n),
    'date': pd.date_range('2025-01-01', periods=n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

print("1. Pandas DataFrame created:")
print(f"   Shape: {df.shape}")
print(f"   Columns: {df.columns.tolist()}")

# 2. Process with DuckDB
conn = duckdb.connect(':memory:')
conn.register('sales', df)

print("\n2. DuckDB processing:")
duckdb_result = conn.execute("""
    SELECT 
        region,
        DATE_TRUNC('month', date) as month,
        SUM(amount) as total_sales,
        AVG(amount) as avg_sale,
        COUNT(*) as transaction_count
    FROM sales
    GROUP BY region, DATE_TRUNC('month', date)
    ORDER BY region, month
""").fetchdf()

print(f"   DuckDB result shape: {duckdb_result.shape}")

# 3. Continue Pandas processing
print("\n3. Pandas post-processing:")
monthly_totals = duckdb_result.pivot_table(
    values='total_sales',
    index='month',
    columns='region',
    aggfunc='sum'
)
print(f"   Pivot table shape: {monthly_totals.shape}")
print(f"   Pivot table preview:\n{monthly_totals.head()}")

# 4. More complex DuckDB processing
print("\n4. DuckDB - Customer segmentation:")
customer_segments = conn.execute("""
    WITH customer_spending AS (
        SELECT 
            customer_id,
            SUM(amount) as total_spent,
            COUNT(*) as order_count,
            AVG(amount) as avg_order_value
        FROM sales
        GROUP BY customer_id
    )
    SELECT 
        CASE 
            WHEN total_spent >= 10000 THEN 'High Value'
            WHEN total_spent >= 5000 THEN 'Medium Value'
            WHEN total_spent >= 1000 THEN 'Low Value'
            ELSE 'Infrequent'
        END as segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_spent,
        AVG(order_count) as avg_orders
    FROM customer_spending
    GROUP BY segment
    ORDER BY avg_spent DESC
""").fetchdf()

print(f"   Customer segments:\n{customer_segments}")

# 5. Use with visualizations
print("\n5. Visualization with Pandas:")
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Plot 1: Regional sales over time
monthly_totals.plot(ax=axes[0])
axes[0].set_title('Monthly Sales by Region')
axes[0].set_xlabel('Month')
axes[0].set_ylabel('Total Sales')
axes[0].legend(title='Region')

# Plot 2: Customer segments
customer_segments.plot(kind='bar', x='segment', y='customer_count', ax=axes[1])
axes[1].set_title('Customer Segment Distribution')
axes[1].set_xlabel('Segment')
axes[1].set_ylabel('Customer Count')

plt.tight_layout()
plt.savefig('data/integration_visualization.png')
plt.close()
print("  Saved visualization to data/integration_visualization.png")
```
</details>

---

## W7: Data Quality & Validation Exercises

### Exercise W7.1: Missing Data Analysis

**Objective:** Detect and handle different types of missing data.

```python
"""
Identify and handle MCAR, MAR, and MNAR missing data patterns.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import missingno as msno

# Create data with different missing patterns
np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'age': np.random.randint(18, 80, n),
    'income': np.random.normal(50000, 20000, n),
    'spending': np.random.normal(50, 20, n),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n)
})

# 1. MCAR: Missing completely at random
# 2. MAR: Missing at random (depends on age)
# 3. MNAR: Missing not at random (depends on income itself)

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import missingno as msno

np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'age': np.random.randint(18, 80, n),
    'income': np.random.normal(50000, 20000, n),
    'spending': np.random.normal(50, 20, n),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n)
})

# 1. MCAR: Random missing
df['income_mcar'] = df['income'].copy()
mcar_mask = np.random.random(n) < 0.1
df.loc[mcar_mask, 'income_mcar'] = np.nan

# 2. MAR: Depends on age
df['income_mar'] = df['income'].copy()
mar_prob = 1 / (1 + np.exp(-(df['age'] - 50) / 10))
mar_mask = np.random.random(n) < mar_prob
df.loc[mar_mask, 'income_mar'] = np.nan

# 3. MNAR: Depends on income
df['income_mnar'] = df['income'].copy()
mnar_prob = 1 / (1 + np.exp(-(df['income'] - 70000) / 10000))
mnar_mask = np.random.random(n) < mnar_prob
df.loc[mnar_mask, 'income_mnar'] = np.nan

print("Missing rates:")
print(f"  MCAR: {df['income_mcar'].isna().mean()*100:.1f}%")
print(f"  MAR: {df['income_mar'].isna().mean()*100:.1f}%")
print(f"  MNAR: {df['income_mnar'].isna().mean()*100:.1f}%")

print("\nMAR pattern by age:")
age_groups = pd.cut(df['age'], bins=[18, 30, 50, 80])
mar_by_age = df.groupby(age_groups)['income_mar'].apply(lambda x: x.isna().mean())
print(mar_by_age)

print("\nMNAR pattern by income (observed):")
income_bins = pd.cut(df[~df['income_mnar'].isna()]['income'], bins=4)
mnar_by_income = df[~df['income_mnar'].isna()].groupby(income_bins)['income_mnar'].apply(lambda x: x.isna().mean())
print(mnar_by_income)

# Visualize
fig, axes = plt.subplots(1, 3, figsize=(15, 4))
msno.matrix(df[['income_mcar', 'income_mar', 'income_mnar']], ax=axes[0])
axes[0].set_title('Missing Data Matrix')

msno.bar(df[['income_mcar', 'income_mar', 'income_mnar']], ax=axes[1])
axes[1].set_title('Missingness Bar Chart')

msno.heatmap(df[['income_mcar', 'income_mar', 'income_mnar']], ax=axes[2])
axes[2].set_title('Missing Correlation Heatmap')

plt.tight_layout()
plt.savefig('data/missing_patterns.png')
plt.close()
print("\nSaved missing patterns visualization to data/missing_patterns.png")
```
</details>

---

### Exercise W7.2: Schema Validation

**Objective:** Define and enforce data schemas.

```python
"""
Use Pydantic and Pandera for schema validation.
"""

import pandas as pd
import numpy as np
from pydantic import BaseModel, Field, validator
import pandera as pa
from pandera.typing import Series

# 1. Define a Pydantic model for a customer record
# 2. Define a Pandera schema for a customer DataFrame
# 3. Validate valid and invalid data
# 4. Handle validation errors gracefully

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
from pydantic import BaseModel, Field, validator
import pandera as pa
from pandera.typing import Series

# 1. Pydantic model
class CustomerRecord(BaseModel):
    customer_id: int = Field(gt=0)
    first_name: str = Field(min_length=1, max_length=50)
    last_name: str = Field(min_length=1, max_length=50)
    email: str = Field(regex=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    age: int = Field(ge=18, le=120)
    income: float = Field(ge=0)
    country: str = Field(min_length=2, max_length=50)
    
    @validator('email')
    def validate_email(cls, v):
        if '@' not in v or '.' not in v:
            raise ValueError('Invalid email format')
        return v.lower()

print("1. Pydantic model defined")

# Test valid data
valid_data = {
    'customer_id': 1,
    'first_name': 'John',
    'last_name': 'Doe',
    'email': 'john.doe@email.com',
    'age': 30,
    'income': 50000.0,
    'country': 'USA'
}

try:
    record = CustomerRecord(**valid_data)
    print(f"\nValid record: {record}")
except Exception as e:
    print(f"Error: {e}")

# Test invalid data
invalid_data = valid_data.copy()
invalid_data['email'] = 'not-an-email'
invalid_data['age'] = 16

print("\nTesting invalid data...")
try:
    record = CustomerRecord(**invalid_data)
except Exception as e:
    print(f"Validation error: {e}")

# 2. Pandera schema
class CustomerSchema(pa.SchemaModel):
    customer_id: Series[int] = pa.Field(gt=0)
    first_name: Series[str] = pa.Field(nullable=False)
    last_name: Series[str] = pa.Field(nullable=False)
    email: Series[str] = pa.Field(nullable=False)
    age: Series[int] = pa.Field(ge=18, le=120)
    income: Series[float] = pa.Field(ge=0)
    country: Series[str] = pa.Field(nullable=False)
    
    @pa.dataframe_check
    def validate_email_format(cls, df: pd.DataFrame) -> Series[bool]:
        return df['email'].str.contains(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

print("\n2. Pandera schema defined")

# Test valid DataFrame
valid_df = pd.DataFrame([valid_data])
print(f"\nValid DataFrame shape: {valid_df.shape}")
try:
    validated_df = CustomerSchema.validate(valid_df)
    print("Validation passed!")
except Exception as e:
    print(f"Validation error: {e}")

# Test invalid DataFrame
invalid_df = pd.DataFrame([
    valid_data,
    {'customer_id': -1, 'first_name': 'Jane', 'last_name': 'Smith', 
     'email': 'jane@email.com', 'age': 25, 'income': 60000, 'country': 'UK'},
    {'customer_id': 3, 'first_name': 'Bob', 'last_name': 'Johnson',
     'email': 'bob-email.com', 'age': 15, 'income': 30000, 'country': 'Canada'}
])

print(f"\nInvalid DataFrame shape: {invalid_df.shape}")
print("Rows:")
print(invalid_df)

print("\nAttempting validation...")
try:
    validated_df = CustomerSchema.validate(invalid_df, lazy=True)
except pa.errors.SchemaErrors as e:
    print(f"Validation failed with {len(e.failure_cases)} errors")
    print("Failure cases:")
    print(e.failure_cases)
```
</details>

---

### Exercise W7.3: Automated Quality Checks

**Objective:** Build an automated data quality monitoring system.

```python
"""
Create a data quality checker with automated reporting.
"""

import pandas as pd
import numpy as np
from datetime import datetime

class DataQualityChecker:
    """Automated data quality monitoring system."""
    
    def __init__(self, df, name="Dataset"):
        self.df = df
        self.name = name
        self.results = {}
    
    def check_missing_values(self, threshold=0.1):
        # Your code here
        pass
    
    def check_duplicates(self):
        # Your code here
        pass
    
    def check_outliers(self, method='iqr', threshold=1.5):
        # Your code here
        pass
    
    def check_data_types(self):
        # Your code here
        pass
    
    def generate_report(self):
        # Your code here
        pass

# Test the checker with sample data
np.random.seed(42)
df = pd.DataFrame({
    'id': range(1, 1001),
    'value': np.random.randn(1000),
    'category': np.random.choice(['A', 'B', 'C'], 1000)
})

# Introduce issues
df.loc[np.random.random(1000) < 0.05, 'value'] = np.nan
df.loc[0, 'value'] = 10  # Outlier
df = pd.concat([df, df.iloc[:5]])  # Duplicates

# Run quality checks
checker = DataQualityChecker(df, "Test Dataset")
report = checker.generate_report()
print(report)
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
from datetime import datetime

class DataQualityChecker:
    def __init__(self, df, name="Dataset"):
        self.df = df
        self.name = name
        self.results = {}
    
    def check_missing_values(self, threshold=0.1):
        missing_rates = self.df.isna().mean()
        high_missing = missing_rates[missing_rates > threshold]
        
        self.results['missing_values'] = {
            'columns_with_missing': list(missing_rates[missing_rates > 0].index),
            'high_missing_columns': list(high_missing.index),
            'max_missing_rate': missing_rates.max(),
            'total_missing': self.df.isna().sum().sum(),
            'summary': f"Found {len(missing_rates[missing_rates > 0])} columns with missing values"
        }
        return self.results['missing_values']
    
    def check_duplicates(self):
        duplicates = self.df.duplicated()
        self.results['duplicates'] = {
            'duplicate_count': duplicates.sum(),
            'duplicate_rate': duplicates.mean(),
            'summary': f"Found {duplicates.sum()} duplicate rows ({duplicates.mean():.2%})"
        }
        return self.results['duplicates']
    
    def check_outliers(self, method='iqr', threshold=1.5):
        numeric_cols = self.df.select_dtypes(include=[np.number]).columns
        outliers = {}
        
        for col in numeric_cols:
            if method == 'iqr':
                Q1 = self.df[col].quantile(0.25)
                Q3 = self.df[col].quantile(0.75)
                IQR = Q3 - Q1
                lower_bound = Q1 - threshold * IQR
                upper_bound = Q3 + threshold * IQR
                outliers_mask = (self.df[col] < lower_bound) | (self.df[col] > upper_bound)
                outliers[col] = {
                    'count': outliers_mask.sum(),
                    'rate': outliers_mask.mean(),
                    'lower_bound': lower_bound,
                    'upper_bound': upper_bound
                }
        
        self.results['outliers'] = {
            'columns_with_outliers': [col for col, data in outliers.items() if data['count'] > 0],
            'outlier_details': outliers,
            'summary': f"Found outliers in {len([c for c in outliers if outliers[c]['count'] > 0])} columns"
        }
        return self.results['outliers']
    
    def check_data_types(self):
        dtypes = self.df.dtypes.to_dict()
        memory_usage = self.df.memory_usage(deep=True)
        
        self.results['data_types'] = {
            'dtypes': dtypes,
            'memory_usage': memory_usage.to_dict(),
            'total_memory_mb': memory_usage.sum() / 1024 / 1024,
            'summary': f"Total memory usage: {memory_usage.sum() / 1024 / 1024:.2f} MB"
        }
        return self.results['data_types']
    
    def generate_report(self):
        self.check_missing_values()
        self.check_duplicates()
        self.check_outliers()
        self.check_data_types()
        
        print(f"\n{'='*60}")
        print(f"DATA QUALITY REPORT: {self.name}")
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}")
        
        print(f"\n1. Dataset Overview:")
        print(f"   Rows: {len(self.df):,}")
        print(f"   Columns: {len(self.df.columns)}")
        print(f"   {self.results['data_types']['summary']}")
        
        print(f"\n2. Missing Values:")
        print(f"   {self.results['missing_values']['summary']}")
        if self.results['missing_values']['high_missing_columns']:
            print(f"   High missing columns (>10%): {self.results['missing_values']['high_missing_columns']}")
        
        print(f"\n3. Duplicates:")
        print(f"   {self.results['duplicates']['summary']}")
        
        print(f"\n4. Outliers:")
        print(f"   {self.results['outliers']['summary']}")
        if self.results['outliers']['columns_with_outliers']:
            for col in self.results['outliers']['columns_with_outliers']:
                details = self.results['outliers']['outlier_details'][col]
                print(f"   {col}: {details['count']} outliers ({details['rate']:.2%})")
        
        return self.results

# Test
np.random.seed(42)
df = pd.DataFrame({
    'id': range(1, 1001),
    'value': np.random.randn(1000),
    'category': np.random.choice(['A', 'B', 'C'], 1000)
})

df.loc[np.random.random(1000) < 0.05, 'value'] = np.nan
df.loc[0, 'value'] = 10
df = pd.concat([df, df.iloc[:5]])

checker = DataQualityChecker(df, "Test Dataset")
report = checker.generate_report()
```
</details>

---

### Exercise W7.4: Data Drift Detection

**Objective:** Detect changes in data distributions over time.

```python
"""
Monitor data drift between baseline and new data.
"""

import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

# 1. Create baseline data
# 2. Create current data with drift
# 3. Detect drift using statistical tests
# 4. Visualize drift detection
# 5. Generate a drift report

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

# 1. Baseline data
np.random.seed(42)
baseline = pd.DataFrame({
    'value': np.random.normal(100, 15, 1000),
    'category': np.random.choice(['A', 'B', 'C'], 1000)
})

# 2. Current data with drift
current = pd.DataFrame({
    'value': np.random.normal(105, 18, 1000),  # Mean and std drifted
    'category': np.random.choice(['A', 'B', 'C'], 1000, p=[0.3, 0.5, 0.2])  # Distribution drifted
})

print("Baseline vs Current:")
print(f"Value mean: {baseline['value'].mean():.2f} → {current['value'].mean():.2f}")
print(f"Value std: {baseline['value'].std():.2f} → {current['value'].std():.2f}")
print(f"Category distribution:")
print(f"  Baseline: {baseline['category'].value_counts(normalize=True).to_dict()}")
print(f"  Current: {current['category'].value_counts(normalize=True).to_dict()}")

# 3. Detect drift
print("\n" + "="*60)
print("DRIFT DETECTION")
print("="*60)

# Kolmogorov-Smirnov test for value
ks_stat, ks_p = stats.ks_2samp(baseline['value'], current['value'])
print(f"\nValue distribution (KS test):")
print(f"  Statistic: {ks_stat:.4f}")
print(f"  P-value: {ks_p:.4f}")
print(f"  Drift detected: {'✅ YES' if ks_p < 0.05 else '❌ NO'}")

# Chi-square test for category
contigency = pd.crosstab(
    ['Baseline']*len(baseline) + ['Current']*len(current),
    list(baseline['category']) + list(current['category'])
)
chi2, chi_p, _, _ = stats.chi2_contingency(contigency)
print(f"\nCategory distribution (Chi-square):")
print(f"  Statistic: {chi2:.4f}")
print(f"  P-value: {chi_p:.4f}")
print(f"  Drift detected: {'✅ YES' if chi_p < 0.05 else '❌ NO'}")

# 4. Visualize
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Histogram comparison
axes[0].hist(baseline['value'], bins=30, alpha=0.5, label='Baseline')
axes[0].hist(current['value'], bins=30, alpha=0.5, label='Current')
axes[0].set_title('Value Distribution')
axes[0].set_xlabel('Value')
axes[0].set_ylabel('Frequency')
axes[0].legend()

# Box plot
data_to_box = [baseline['value'], current['value']]
axes[1].boxplot(data_to_box, labels=['Baseline', 'Current'])
axes[1].set_title('Value Box Plot')
axes[1].set_ylabel('Value')

# Category distribution
category_comp = pd.DataFrame({
    'Baseline': baseline['category'].value_counts(normalize=True),
    'Current': current['category'].value_counts(normalize=True)
}).fillna(0)

category_comp.plot(kind='bar', ax=axes[2])
axes[2].set_title('Category Distribution')
axes[2].set_xlabel('Category')
axes[2].set_ylabel('Proportion')
axes[2].legend()

plt.tight_layout()
plt.savefig('data/drift_detection.png')
plt.close()
print("\nSaved drift visualization to data/drift_detection.png")

# 5. Drift report
print("\n" + "="*60)
print("DRIFT REPORT")
print("="*60)

report = {
    'value_drift': {
        'test': 'KS Test',
        'statistic': ks_stat,
        'p_value': ks_p,
        'drift_detected': ks_p < 0.05
    },
    'category_drift': {
        'test': 'Chi-square',
        'statistic': chi2,
        'p_value': chi_p,
        'drift_detected': chi_p < 0.05
    }
}

print("\nSummary:")
if report['value_drift']['drift_detected']:
    print("⚠️  VALUE distribution has drifted significantly")
    print(f"   Baseline mean: {baseline['value'].mean():.2f}")
    print(f"   Current mean: {current['value'].mean():.2f}")
    print(f"   Change: {current['value'].mean() - baseline['value'].mean():.2f}")

if report['category_drift']['drift_detected']:
    print("⚠️  CATEGORY distribution has drifted significantly")
    print("   Baseline distribution:", baseline['category'].value_counts(normalize=True).to_dict())
    print("   Current distribution:", current['category'].value_counts(normalize=True).to_dict())
```
</details>

---

### Exercise W7.5: Integrated Validation Pipeline

**Objective:** Build a complete data validation pipeline.

```python
"""
Create an integrated pipeline that validates data at multiple stages.
"""

import pandas as pd
import numpy as np
from pydantic import BaseModel, Field, validator
import pandera as pa
from pandera.typing import Series

# 1. Define schemas for raw and processed data
# 2. Create validation functions for each stage
# 3. Build a pipeline that runs all validations
# 4. Generate a comprehensive validation report

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
from pydantic import BaseModel, Field, validator
import pandera as pa
from pandera.typing import Series
from datetime import datetime
import json

# 1. Raw data schema
class RawCustomerSchema(pa.SchemaModel):
    customer_id: Series[int] = pa.Field(gt=0, nullable=False)
    first_name: Series[str] = pa.Field(nullable=False)
    last_name: Series[str] = pa.Field(nullable=False)
    email: Series[str] = pa.Field(nullable=False)
    age: Series[int] = pa.Field(ge=0, le=150)
    income: Series[float] = pa.Field(ge=0)
    signup_date: Series[pd.Timestamp] = pa.Field(nullable=False)

# 2. Processed data schema (more strict)
class ProcessedCustomerSchema(RawCustomerSchema):
    age: Series[int] = pa.Field(ge=18, le=120)
    income: Series[float] = pa.Field(ge=0, le=1_000_000)
    email: Series[str] = pa.Field(nullable=False)
    
    @pa.dataframe_check
    def validate_email_format(cls, df: pd.DataFrame) -> Series[bool]:
        return df['email'].str.contains(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

# 3. Validation pipeline
class ValidationPipeline:
    def __init__(self):
        self.stages = []
        self.results = {}
    
    def add_stage(self, name, schema, validation_func=None):
        self.stages.append({
            'name': name,
            'schema': schema,
            'validation_func': validation_func
        })
    
    def validate(self, df):
        for stage in self.stages:
            try:
                validated_df = stage['schema'].validate(df, lazy=True)
                self.results[stage['name']] = {
                    'status': 'passed',
                    'message': f"Validation passed for {stage['name']}"
                }
                df = validated_df
            except pa.errors.SchemaErrors as e:
                self.results[stage['name']] = {
                    'status': 'failed',
                    'errors': e.failure_cases.to_dict('records'),
                    'error_count': len(e.failure_cases),
                    'message': f"Validation failed with {len(e.failure_cases)} errors"
                }
                
                # Attempt to fix
                if stage.get('validation_func'):
                    df = stage['validation_func'](df)
                    self.results[stage['name']]['fixed'] = True
            
            if stage.get('validation_func') and callable(stage['validation_func']):
                df = stage['validation_func'](df)
        
        return df, self.results
    
    def generate_report(self):
        print(f"\n{'='*60}")
        print("VALIDATION PIPELINE REPORT")
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}")
        
        for stage_name, result in self.results.items():
            status_symbol = '✅' if result['status'] == 'passed' else '❌'
            print(f"\n{status_symbol} Stage: {stage_name}")
            print(f"   Status: {result['status']}")
            print(f"   {result['message']}")
            
            if result['status'] == 'failed':
                print(f"   Sample errors:")
                for error in result['errors'][:3]:
                    print(f"     - {error}")

# 4. Test the pipeline
def fix_raw_data(df):
    """Fix common issues in raw data."""
    df_clean = df.copy()
    
    # Fix age outliers
    df_clean.loc[df_clean['age'] > 120, 'age'] = 120
    df_clean.loc[df_clean['age'] < 0, 'age'] = 18
    
    # Fix income outliers
    income_99 = df_clean['income'].quantile(0.99)
    df_clean.loc[df_clean['income'] > income_99, 'income'] = income_99
    
    # Fix missing values
    df_clean['age'] = df_clean['age'].fillna(30)
    df_clean['income'] = df_clean['income'].fillna(df_clean['income'].median())
    
    # Fix email format
    df_clean['email'] = df_clean['email'].str.lower()
    
    return df_clean

# Test data
np.random.seed(42)
test_df = pd.DataFrame({
    'customer_id': range(1, 101),
    'first_name': [f'User_{i}' for i in range(1, 101)],
    'last_name': [f'Last_{i}' for i in range(1, 101)],
    'email': [f'user{i}@email.com' for i in range(1, 101)],
    'age': np.random.randint(15, 150, 100),
    'income': np.random.normal(50000, 20000, 100),
    'signup_date': pd.date_range('2025-01-01', periods=100)
})

# Introduce issues
test_df.loc[0, 'age'] = -5
test_df.loc[1, 'age'] = 200
test_df.loc[2, 'income'] = 10_000_000
test_df.loc[3, 'email'] = 'invalid-email'
test_df.loc[4, 'signup_date'] = None

print("Test data created with issues")
print(f"Shape: {test_df.shape}")

# Create and run pipeline
pipeline = ValidationPipeline()
pipeline.add_stage('raw_data', RawCustomerSchema)
pipeline.add_stage('processed_data', ProcessedCustomerSchema, fix_raw_data)

validated_df, results = pipeline.validate(test_df)
pipeline.generate_report()

print(f"\nFinal data shape: {validated_df.shape}")
print(f"Final data sample:")
print(validated_df.head())
```
</details>

---

## W8: EDA & Data Profiling Exercises

### Exercise W8.1: Univariate Analysis

**Objective:** Perform comprehensive univariate analysis.

```python
"""
Analyze individual variables using appropriate statistics and visualizations.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import skew, kurtosis

# Create a dataset with different variable types
np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# 1. Analyze numerical variables (mean, median, std, skew, kurtosis, IQR)
# 2. Analyze categorical variables (frequencies, percentages)
# 3. Create appropriate visualizations for each variable type
# 4. Identify potential issues (outliers, missing values, unusual distributions)

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import skew, kurtosis

np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

print("="*60)
print("UNIVARIATE ANALYSIS")
print("="*60)

# 1. Numerical variables
numeric_cols = ['age', 'income', 'spending']
print("\n1. Numerical Variables:")
print("-"*40)

for col in numeric_cols:
    data = df[col].dropna()
    q1 = data.quantile(0.25)
    q3 = data.quantile(0.75)
    iqr = q3 - q1
    
    print(f"\n{col}:")
    print(f"  Count: {len(data):,}")
    print(f"  Mean: {data.mean():.2f}")
    print(f"  Median: {data.median():.2f}")
    print(f"  Std: {data.std():.2f}")
    print(f"  Min: {data.min():.2f}")
    print(f"  Max: {data.max():.2f}")
    print(f"  Q1: {q1:.2f}, Q3: {q3:.2f}, IQR: {iqr:.2f}")
    print(f"  Skewness: {skew(data):.3f}")
    print(f"  Kurtosis: {kurtosis(data):.3f}")
    
    # Outlier detection
    lower_bound = q1 - 1.5 * iqr
    upper_bound = q3 + 1.5 * iqr
    outliers = data[(data < lower_bound) | (data > upper_bound)]
    print(f"  Outliers: {len(outliers)} ({len(outliers)/len(data)*100:.1f}%)")

# 2. Categorical variables
cat_cols = ['satisfaction', 'category', 'region']
print("\n" + "-"*40)
print("2. Categorical Variables:")
print("-"*40)

for col in cat_cols:
    print(f"\n{col}:")
    print(f"  Unique values: {df[col].nunique()}")
    print(f"  Value counts:")
    value_counts = df[col].value_counts()
    for val, count in value_counts.items():
        print(f"    {val}: {count} ({count/len(df)*100:.1f}%)")

# 3. Visualizations
fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Numerical: Histograms
for idx, col in enumerate(numeric_cols):
    ax = axes[0, idx]
    df[col].hist(bins=30, ax=ax, alpha=0.7, edgecolor='black')
    ax.axvline(df[col].mean(), color='red', linestyle='--', label='Mean')
    ax.axvline(df[col].median(), color='green', linestyle='--', label='Median')
    ax.set_title(f'Distribution of {col}')
    ax.set_xlabel(col)
    ax.set_ylabel('Frequency')
    ax.legend()
    ax.grid(True, alpha=0.3)

# Categorical: Bar charts
for idx, col in enumerate(cat_cols):
    ax = axes[1, idx]
    value_counts = df[col].value_counts()
    ax.bar(value_counts.index, value_counts.values)
    ax.set_title(f'Distribution of {col}')
    ax.set_xlabel(col)
    ax.set_ylabel('Count')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('data/univariate_analysis.png')
plt.close()
print("\nSaved visualizations to data/univariate_analysis.png")

# 4. Key findings
print("\n" + "="*60)
print("KEY FINDINGS")
print("="*60)

print("\nData Quality Issues:")
for col in df.columns:
    missing = df[col].isna().sum()
    if missing > 0:
        print(f"  {col}: {missing} missing values")

print("\nOutlier Summary:")
for col in numeric_cols:
    q1 = df[col].quantile(0.25)
    q3 = df[col].quantile(0.75)
    iqr = q3 - q1
    lower = q1 - 1.5 * iqr
    upper = q3 + 1.5 * iqr
    outliers = df[(df[col] < lower) | (df[col] > upper)]
    if len(outliers) > 0:
        print(f"  {col}: {len(outliers)} outliers")

print("\nDistributions:")
for col in numeric_cols:
    s = skew(df[col].dropna())
    if s > 0.5:
        print(f"  {col}: Right-skewed (skew={s:.2f})")
    elif s < -0.5:
        print(f"  {col}: Left-skewed (skew={s:.2f})")
    else:
        print(f"  {col}: Approximately symmetric (skew={s:.2f})")
```
</details>

---

### Exercise W8.2: Bivariate Analysis

**Objective:** Analyze relationships between pairs of variables.

```python
"""
Explore relationships between variables using statistical tests and visualizations.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr, spearmanr, chi2_contingency

# Create data with relationships
np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n),
    'income': np.random.normal(50000, 20000, n),
    'spending': np.random.normal(50, 20, n),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n),
    'category': np.random.choice(['A', 'B', 'C'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# Add relationships
df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['satisfaction'] = np.clip(df['satisfaction'] + df['age'] / 20, 1, 5).round()

# 1. Numeric-numeric relationships (correlation, scatter plots)
# 2. Categorical-categorical relationships (chi-square, heatmaps)
# 3. Categorical-numeric relationships (box plots, ANOVA)
# 4. Create a correlation matrix

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr, spearmanr, chi2_contingency

np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n),
    'income': np.random.normal(50000, 20000, n),
    'spending': np.random.normal(50, 20, n),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n),
    'category': np.random.choice(['A', 'B', 'C'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['satisfaction'] = np.clip(df['satisfaction'] + df['age'] / 20, 1, 5).round()

print("="*60)
print("BIVARIATE ANALYSIS")
print("="*60)

# 1. Numeric-numeric relationships
print("\n1. Numeric-Numeric Relationships:")
print("-"*40)

numeric_cols = ['age', 'income', 'spending', 'satisfaction']
correlations = {}

for i in range(len(numeric_cols)):
    for j in range(i+1, len(numeric_cols)):
        col1, col2 = numeric_cols[i], numeric_cols[j]
        
        # Pearson
        pearson_r, pearson_p = pearsonr(df[col1].dropna(), df[col2].dropna())
        
        # Spearman
        spearman_r, spearman_p = spearmanr(df[col1].dropna(), df[col2].dropna())
        
        correlations[f"{col1}-{col2}"] = {
            'pearson_r': pearson_r,
            'pearson_p': pearson_p,
            'spearman_r': spearman_r,
            'spearman_p': spearman_p
        }
        
        print(f"\n{col1} vs {col2}:")
        print(f"  Pearson r: {pearson_r:.3f} (p={pearson_p:.4f})")
        print(f"  Spearman ρ: {spearman_r:.3f} (p={spearman_p:.4f})")
        if abs(pearson_r) > 0.3:
            print(f"  ✓ Moderate to strong correlation")

# 2. Categorical-categorical relationships
print("\n" + "-"*40)
print("2. Categorical-Categorical Relationships:")
print("-"*40)

cat_cols = ['category', 'region']
for col1 in cat_cols:
    for col2 in cat_cols:
        if col1 != col2:
            contingency = pd.crosstab(df[col1], df[col2])
            chi2, p, dof, expected = chi2_contingency(contingency)
            print(f"\n{col1} vs {col2}:")
            print(f"  Chi-square: {chi2:.3f}")
            print(f"  p-value: {p:.4f}")
            print(f"  Degrees of freedom: {dof}")
            if p < 0.05:
                print(f"  ✓ Significant relationship detected")

# 3. Categorical-numeric relationships
print("\n" + "-"*40)
print("3. Categorical-Numeric Relationships:")
print("-"*40)

for cat_col in ['category', 'region']:
    print(f"\n{cat_col}:")
    for num_col in numeric_cols:
        if num_col != cat_col:
            # Group means
            means = df.groupby(cat_col)[num_col].mean()
            print(f"  {num_col}:")
            for cat, mean in means.items():
                print(f"    {cat}: {mean:.2f}")

# 4. Correlation matrix and heatmap
print("\n" + "-"*40)
print("4. Correlation Matrix:")
print("-"*40)

corr_matrix = df[numeric_cols].corr()
print(corr_matrix.round(3))

# Create heatmap
plt.figure(figsize=(10, 8))
mask = np.triu(np.ones_like(corr_matrix, dtype=bool))
sns.heatmap(corr_matrix, mask=mask, annot=True, fmt='.2f', cmap='RdBu', center=0)
plt.title('Correlation Matrix')
plt.tight_layout()
plt.savefig('data/correlation_matrix.png')
plt.close()
print("\nSaved correlation heatmap to data/correlation_matrix.png")

# 5. Pairplot for key variables
print("\nCreating pairplot...")
sns.pairplot(df[numeric_cols], diag_kind='kde')
plt.savefig('data/pairplot.png')
plt.close()
print("Saved pairplot to data/pairplot.png")
```
</details>

---

### Exercise W8.3: Multivariate Analysis

**Objective:** Explore interactions between multiple variables.

```python
"""
Analyze complex relationships involving multiple variables.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

# Create data with complex patterns
np.random.seed(42)
n = 500

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'category': np.random.choice(['A', 'B', 'C'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# Create relationships
df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + 
          np.random.normal(0, 0.5, n))
df['cluster'] = (df['x1'] + df['x2'] + df['x3'] + 
                np.random.normal(0, 0.5, n))

# 1. PCA for dimensionality reduction
# 2. Pair plots with color coding
# 3. Faceted visualizations
# 4. Cluster analysis

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'category': np.random.choice(['A', 'B', 'C'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + 
          np.random.normal(0, 0.5, n))
df['cluster'] = (df['x1'] + df['x2'] + df['x3'] + 
                np.random.normal(0, 0.5, n))

print("="*60)
print("MULTIVARIATE ANALYSIS")
print("="*60)

# 1. PCA
print("\n1. Principal Component Analysis:")
print("-"*40)

# Prepare data
features = ['x1', 'x2', 'x3', 'y']
X = df[features].copy()
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA()
X_pca = pca.fit_transform(X_scaled)

# Explained variance
explained_variance = pca.explained_variance_ratio_
cumulative_variance = np.cumsum(explained_variance)

print(f"Explained variance ratios:")
for i, ev in enumerate(explained_variance[:3]):
    print(f"  PC{i+1}: {ev:.3f}")
print(f"Cumulative variance (first 2 PCs): {cumulative_variance[:2].sum():.3f}")

# Loadings
loadings = pd.DataFrame(
    pca.components_.T,
    columns=[f'PC{i+1}' for i in range(pca.n_components_)],
    index=features
)
print(f"\nLoadings:")
print(loadings.round(3))

# 2. Pairplot with color coding
print("\n2. Creating pairplot with color coding...")
sns.pairplot(df[['x1', 'x2', 'x3', 'y', 'category']], hue='category')
plt.savefig('data/pairplot_colored.png')
plt.close()
print("Saved colored pairplot to data/pairplot_colored.png")

# 3. Faceted visualizations
print("\n3. Creating faceted visualizations...")

# Scatter plot by category and region
g = sns.FacetGrid(df, col='category', row='region', margin_titles=True)
g.map(sns.scatterplot, 'x1', 'x2', alpha=0.5)
g.fig.suptitle('x1 vs x2 by Category and Region', y=1.02)
g.fig.savefig('data/facet_grid.png')
plt.close()
print("Saved facet grid to data/facet_grid.png")

# 4. Cluster analysis
print("\n4. Cluster Analysis:")
print("-"*40)

# K-means clustering
kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
df['kmeans_cluster'] = kmeans.fit_predict(X_scaled)

# Visualize clusters
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Cluster in original space
axes[0].scatter(df['x1'], df['x2'], c=df['kmeans_cluster'], cmap='viridis', alpha=0.6)
axes[0].set_title('Clusters in Original Space')
axes[0].set_xlabel('x1')
axes[0].set_ylabel('x2')

# Cluster in PCA space
axes[1].scatter(X_pca[:, 0], X_pca[:, 1], c=df['kmeans_cluster'], cmap='viridis', alpha=0.6)
axes[1].set_title('Clusters in PCA Space')
axes[1].set_xlabel('PC1')
axes[1].set_ylabel('PC2')

plt.tight_layout()
plt.savefig('data/cluster_analysis.png')
plt.close()
print("Saved cluster analysis to data/cluster_analysis.png")

print(f"\nCluster sizes:")
print(df['kmeans_cluster'].value_counts().sort_index())

print("\nCluster means:")
cluster_means = df.groupby('kmeans_cluster')[features].mean()
print(cluster_means.round(3))
```
</details>

---

### Exercise W8.4: Automated Profiling

**Objective:** Build a comprehensive data profiling tool.

```python
"""
Create an automated profiling system for any dataset.
"""

import pandas as pd
import numpy as np

class DataProfiler:
    """Automated data profiling system."""
    
    def __init__(self, df, name="Dataset"):
        self.df = df
        self.name = name
        self.profile = {}
    
    def profile_dataset(self):
        # Your code here
        pass
    
    def profile_numeric(self, col):
        # Your code here
        pass
    
    def profile_categorical(self, col):
        # Your code here
        pass
    
    def generate_report(self):
        # Your code here
        pass

# Test with sample data
np.random.seed(42)
df = pd.DataFrame({
    'age': np.random.normal(40, 15, 1000),
    'income': np.random.lognormal(10.5, 0.8, 1000),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 1000),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 1000),
    'spending': np.random.normal(50, 20, 1000)
})

profiler = DataProfiler(df, "Customer Data")
report = profiler.generate_report()
print(report)
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
from scipy.stats import skew, kurtosis
from datetime import datetime

class DataProfiler:
    def __init__(self, df, name="Dataset"):
        self.df = df
        self.name = name
        self.profile = {
            'dataset_info': {},
            'numeric': {},
            'categorical': {},
            'missing': {},
            'summary': {}
        }
    
    def profile_dataset(self):
        self.profile['dataset_info'] = {
            'rows': len(self.df),
            'columns': len(self.df.columns),
            'memory_mb': self.df.memory_usage(deep=True).sum() / 1024 / 1024,
            'duplicates': self.df.duplicated().sum()
        }
        
        for col in self.df.columns:
            if self.df[col].dtype in ['int64', 'float64']:
                self._profile_numeric(col)
            else:
                self._profile_categorical(col)
        
        self._profile_missing()
        self._generate_summary()
        
        return self.profile
    
    def _profile_numeric(self, col):
        data = self.df[col].dropna()
        q1 = data.quantile(0.25)
        q3 = data.quantile(0.75)
        iqr = q3 - q1
        
        self.profile['numeric'][col] = {
            'count': len(data),
            'missing': self.df[col].isna().sum(),
            'mean': data.mean(),
            'median': data.median(),
            'std': data.std(),
            'min': data.min(),
            'max': data.max(),
            'q1': q1,
            'q3': q3,
            'iqr': iqr,
            'skewness': skew(data),
            'kurtosis': kurtosis(data),
            'outliers_lower': q1 - 1.5 * iqr,
            'outliers_upper': q3 + 1.5 * iqr,
            'outlier_count': ((data < q1 - 1.5 * iqr) | (data > q3 + 1.5 * iqr)).sum()
        }
    
    def _profile_categorical(self, col):
        value_counts = self.df[col].value_counts()
        
        self.profile['categorical'][col] = {
            'count': len(self.df[col].dropna()),
            'missing': self.df[col].isna().sum(),
            'unique': self.df[col].nunique(),
            'top_values': value_counts.head(5).to_dict(),
            'top_value': value_counts.index[0],
            'top_frequency': value_counts.values[0],
            'top_percentage': value_counts.values[0] / len(self.df) * 100
        }
    
    def _profile_missing(self):
        missing = self.df.isna().sum()
        missing_pct = missing / len(self.df) * 100
        
        self.profile['missing'] = {
            'total_missing': missing.sum(),
            'total_missing_pct': missing.sum() / (len(self.df) * len(self.df.columns)) * 100,
            'columns': {
                col: {'count': int(missing[col]), 'percentage': missing_pct[col]}
                for col in self.df.columns if missing[col] > 0
            }
        }
    
    def _generate_summary(self):
        self.profile['summary'] = {
            'numeric_count': len(self.profile['numeric']),
            'categorical_count': len(self.profile['categorical']),
            'missing_columns': len(self.profile['missing']['columns']),
            'high_missing': [col for col, info in self.profile['missing']['columns'].items() 
                           if info['percentage'] > 10]
        }
    
    def generate_report(self):
        self.profile_dataset()
        
        print(f"\n{'='*60}")
        print(f"DATA PROFILE: {self.name}")
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}")
        
        # Dataset overview
        info = self.profile['dataset_info']
        print(f"\n1. Dataset Overview:")
        print(f"   Rows: {info['rows']:,}")
        print(f"   Columns: {info['columns']}")
        print(f"   Memory: {info['memory_mb']:.2f} MB")
        print(f"   Duplicates: {info['duplicates']}")
        
        # Numeric columns
        print(f"\n2. Numeric Features ({self.profile['summary']['numeric_count']}):")
        for col, stats in self.profile['numeric'].items():
            print(f"\n   {col}:")
            print(f"     Mean: {stats['mean']:.2f}")
            print(f"     Median: {stats['median']:.2f}")
            print(f"     Std: {stats['std']:.2f}")
            print(f"     Range: {stats['min']:.2f} - {stats['max']:.2f}")
            print(f"     Skew: {stats['skewness']:.3f}")
            print(f"     Outliers: {stats['outlier_count']} ({stats['outlier_count']/stats['count']*100:.1f}%)")
        
        # Categorical columns
        print(f"\n3. Categorical Features ({self.profile['summary']['categorical_count']}):")
        for col, stats in self.profile['categorical'].items():
            print(f"\n   {col}:")
            print(f"     Unique: {stats['unique']}")
            print(f"     Top: {stats['top_value']} ({stats['top_frequency']}, {stats['top_percentage']:.1f}%)")
        
        # Missing values
        print(f"\n4. Missing Values:")
        if self.profile['missing']['columns']:
            print(f"   Total missing: {self.profile['missing']['total_missing']}")
            for col, info in self.profile['missing']['columns'].items():
                print(f"     {col}: {info['count']} ({info['percentage']:.1f}%)")
        else:
            print("   No missing values detected")
        
        return self.profile

# Test
np.random.seed(42)
df = pd.DataFrame({
    'age': np.random.normal(40, 15, 1000),
    'income': np.random.lognormal(10.5, 0.8, 1000),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 1000),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 1000),
    'spending': np.random.normal(50, 20, 1000)
})

profiler = DataProfiler(df, "Customer Data")
report = profiler.generate_report()
```
</details>

---

### Exercise W8.5: Signal vs Noise

**Objective:** Identify informative features vs noise.

```python
"""
Analyze which features contain signal vs random noise.
"""

import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

# Create data with mixed signal and noise
np.random.seed(42)
n = 500

# Features with varying signal strength
df = pd.DataFrame({
    'strong_signal': np.random.normal(0, 1, n) + np.random.normal(0, 0.2, n),
    'medium_signal': np.random.normal(0, 1, n) + np.random.normal(0, 0.5, n),
    'weak_signal': np.random.normal(0, 1, n) + np.random.normal(0, 0.8, n),
    'noise': np.random.normal(0, 1, n),
    'feature_a': np.random.choice(['X', 'Y', 'Z'], n),
    'feature_b': np.random.choice([1, 2, 3, 4], n)
})

# Create target with relationships
df['target'] = (2*df['strong_signal'] - 1.5*df['medium_signal'] + 
                0.5*df['weak_signal'] + np.random.normal(0, 0.5, n))

# 1. Calculate correlation with target for numeric features
# 2. Calculate information gain for categorical features
# 3. Identify features with strongest signal
# 4. Visualize signal strength

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
from sklearn.feature_selection import mutual_info_regression

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'strong_signal': np.random.normal(0, 1, n) + np.random.normal(0, 0.2, n),
    'medium_signal': np.random.normal(0, 1, n) + np.random.normal(0, 0.5, n),
    'weak_signal': np.random.normal(0, 1, n) + np.random.normal(0, 0.8, n),
    'noise': np.random.normal(0, 1, n),
    'feature_a': np.random.choice(['X', 'Y', 'Z'], n),
    'feature_b': np.random.choice([1, 2, 3, 4], n)
})

df['target'] = (2*df['strong_signal'] - 1.5*df['medium_signal'] + 
                0.5*df['weak_signal'] + np.random.normal(0, 0.5, n))

print("="*60)
print("SIGNAL VS NOISE ANALYSIS")
print("="*60)

# 1. Numeric features - correlation
numeric_cols = ['strong_signal', 'medium_signal', 'weak_signal', 'noise']
numeric_signal = {}

print("\n1. Numeric Features - Correlation with Target:")
print("-"*40)

for col in numeric_cols:
    corr, p_value = stats.pearsonr(df[col], df['target'])
    numeric_signal[col] = {
        'correlation': corr,
        'p_value': p_value,
        'signal_strength': abs(corr)
    }
    
    print(f"\n{col}:")
    print(f"  Correlation: {corr:.3f}")
    print(f"  p-value: {p_value:.4f}")
    print(f"  Signal strength: {abs(corr):.3f}")
    
    if abs(corr) > 0.3:
        print(f"  ✓ Strong signal")
    elif abs(corr) > 0.1:
        print(f"  ~ Moderate signal")
    else:
        print(f"  ✗ Weak/no signal (noise)")

# 2. Categorical features
print("\n" + "-"*40)
print("2. Categorical Features - Mutual Information:")
print("-"*40)

cat_cols = ['feature_a', 'feature_b']
cat_signal = {}

for col in cat_cols:
    # One-hot encode
    X_encoded = pd.get_dummies(df[col], prefix=col)
    mi = mutual_info_regression(X_encoded, df['target']).mean()
    cat_signal[col] = {
        'mutual_information': mi,
        'signal_strength': mi
    }
    
    print(f"\n{col}:")
    print(f"  Mutual Information: {mi:.3f}")
    print(f"  Signal strength: {mi:.3f}")
    
    if mi > 0.1:
        print(f"  ✓ Informative feature")
    elif mi > 0.02:
        print(f"  ~ Somewhat informative")
    else:
        print(f"  ✗ Weak signal/noise")

# 3. Feature ranking
print("\n" + "="*60)
print("3. Feature Signal Ranking:")
print("="*60)

# Combine all features
all_signal = {}
for col, info in numeric_signal.items():
    all_signal[col] = info['signal_strength']
for col, info in cat_signal.items():
    all_signal[col] = info['signal_strength']

ranked_features = sorted(all_signal.items(), key=lambda x: x[1], reverse=True)

print("\nFeatures ranked by signal strength:")
for rank, (feature, strength) in enumerate(ranked_features, 1):
    status = "✅ STRONG" if strength > 0.3 else "⚠️ MODERATE" if strength > 0.1 else "❌ WEAK"
    print(f"{rank}. {feature}: {strength:.3f} - {status}")

# 4. Visualize
print("\n4. Creating visualization...")

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Feature importance
features = list(all_signal.keys())
strengths = list(all_signal.values())
colors = ['green' if s > 0.3 else 'orange' if s > 0.1 else 'red' for s in strengths]

axes[0].barh(features, strengths, color=colors)
axes[0].axvline(0.3, color='green', linestyle='--', alpha=0.5, label='Strong')
axes[0].axvline(0.1, color='orange', linestyle='--', alpha=0.5, label='Moderate')
axes[0].set_xlabel('Signal Strength')
axes[0].set_title('Feature Signal Strength')
axes[0].legend()

# Correlation plot
axes[1].scatter(df['strong_signal'], df['target'], alpha=0.3, label='Strong Signal')
axes[1].scatter(df['noise'], df['target'], alpha=0.3, label='Noise')
axes[1].set_xlabel('Feature Value')
axes[1].set_ylabel('Target')
axes[1].set_title('Signal vs Noise: Relationship with Target')
axes[1].legend()

plt.tight_layout()
plt.savefig('data/signal_vs_noise.png')
plt.close()
print("Saved signal vs noise visualization to data/signal_vs_noise.png")

# 5. Summary
print("\n" + "="*60)
print("SUMMARY")
print("="*60)

print("\nFeatures with strong signal (>0.3):")
strong_features = [f for f, s in all_signal.items() if s > 0.3]
if strong_features:
    for f in strong_features:
        print(f"  ✅ {f}")
else:
    print("  None found")

print("\nFeatures with moderate signal (0.1-0.3):")
moderate_features = [f for f, s in all_signal.items() if 0.1 < s <= 0.3]
if moderate_features:
    for f in moderate_features:
        print(f"  ⚠️ {f}")
else:
    print("  None found")

print("\nFeatures with weak signal (<0.1 - likely noise):")
weak_features = [f for f, s in all_signal.items() if s <= 0.1]
if weak_features:
    for f in weak_features:
        print(f"  ❌ {f}")
else:
    print("  None found")

print("\nRecommendation:")
print("  - Use strong signal features for modeling")
print("  - Consider dropping weak signal features to reduce noise")
print("  - Investigate moderate signal features further")
```
</details>

---

## W9: Static Visualizations Exercises

### Exercise W9.1: Matplotlib Mastery

**Objective:** Create publication-quality static visualizations.

```python
"""
Create complex, customized static visualizations using Matplotlib.
"""

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy as np
import pandas as pd

# Create data
np.random.seed(42)
data = pd.DataFrame({
    'x': np.linspace(0, 10, 100),
    'y1': np.sin(np.linspace(0, 10, 100)) + np.random.normal(0, 0.1, 100),
    'y2': np.cos(np.linspace(0, 10, 100)) + np.random.normal(0, 0.1, 100),
    'y3': np.sin(np.linspace(0, 10, 100)) * np.cos(np.linspace(0, 10, 100))
})

# 1. Create a complex multi-panel figure with GridSpec
# 2. Add proper labels, titles, and annotations
# 3. Customize colors, styles, and fonts
# 4. Add a colorbar and legend
# 5. Save as high-resolution image

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy as np
import pandas as pd

np.random.seed(42)
data = pd.DataFrame({
    'x': np.linspace(0, 10, 100),
    'y1': np.sin(np.linspace(0, 10, 100)) + np.random.normal(0, 0.1, 100),
    'y2': np.cos(np.linspace(0, 10, 100)) + np.random.normal(0, 0.1, 100),
    'y3': np.sin(np.linspace(0, 10, 100)) * np.cos(np.linspace(0, 10, 100))
})

# Create figure with GridSpec
fig = plt.figure(figsize=(14, 10))
gs = gridspec.GridSpec(3, 3, figure=fig, hspace=0.3, wspace=0.3)

# 1. Main plot (top-left, spanning 2x2)
ax_main = fig.add_subplot(gs[:2, :2])
ax_main.plot(data['x'], data['y1'], label='sin(x)', linewidth=2, color='#2E86C1')
ax_main.plot(data['x'], data['y2'], label='cos(x)', linewidth=2, color='#E74C3C')
ax_main.plot(data['x'], data['y3'], label='sin(x)*cos(x)', linewidth=2, color='#27AE60')
ax_main.set_xlabel('X', fontsize=12)
ax_main.set_ylabel('Y', fontsize=12)
ax_main.set_title('Main Plot: Trigonometric Functions', fontsize=14, fontweight='bold')
ax_main.legend(loc='upper right', frameon=True, fancybox=True, shadow=True)
ax_main.grid(True, alpha=0.3)

# 2. Histogram (top-right)
ax_hist = fig.add_subplot(gs[0, 2])
ax_hist.hist(data['y1'], bins=20, edgecolor='black', color='#2E86C1', alpha=0.7)
ax_hist.set_xlabel('Values', fontsize=10)
ax_hist.set_ylabel('Frequency', fontsize=10)
ax_hist.set_title('Histogram', fontsize=12, fontweight='bold')
ax_hist.grid(True, alpha=0.3)

# 3. Box plot (middle-right)
ax_box = fig.add_subplot(gs[1, 2])
box_data = [data['y1'], data['y2'], data['y3']]
bp = ax_box.boxplot(box_data, labels=['sin', 'cos', 'sin*cos'])
ax_box.set_ylabel('Values', fontsize=10)
ax_box.set_title('Box Plots', fontsize=12, fontweight='bold')
ax_box.grid(True, alpha=0.3)

# 4. Scatter plot (bottom row, first column)
ax_scatter = fig.add_subplot(gs[2, 0])
ax_scatter.scatter(data['y1'], data['y2'], alpha=0.5, s=30, c='#8E44AD')
ax_scatter.set_xlabel('sin(x)', fontsize=10)
ax_scatter.set_ylabel('cos(x)', fontsize=10)
ax_scatter.set_title('Scatter Plot', fontsize=12, fontweight='bold')
ax_scatter.grid(True, alpha=0.3)

# 5. Bar plot (bottom row, middle)
ax_bar = fig.add_subplot(gs[2, 1])
categories = ['sin', 'cos', 'sin*cos']
means = [data['y1'].mean(), data['y2'].mean(), data['y3'].mean()]
stds = [data['y1'].std(), data['y2'].std(), data['y3'].std()]
ax_bar.bar(categories, means, yerr=stds, capsize=5, color=['#2E86C1', '#E74C3C', '#27AE60'])
ax_bar.set_ylabel('Mean Value', fontsize=10)
ax_bar.set_title('Mean ± Std', fontsize=12, fontweight='bold')
ax_bar.grid(True, alpha=0.3, axis='y')

# 6. Heatmap (bottom-right)
ax_heat = fig.add_subplot(gs[2, 2])
matrix = np.random.randn(10, 10)
im = ax_heat.imshow(matrix, cmap='RdBu', aspect='auto', vmin=-2, vmax=2)
ax_heat.set_title('Heatmap', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax_heat)

# Overall title
fig.suptitle('Comprehensive Data Visualization', fontsize=16, fontweight='bold', y=0.98)

# Save figure
plt.tight_layout()
plt.savefig('data/matplotlib_masterpiece.png', dpi=300, bbox_inches='tight')
plt.close()
print("Saved comprehensive visualization to data/matplotlib_masterpiece.png")
```
</details>

---

### Exercise W9.2: Seaborn Statistical Plots

**Objective:** Create statistical visualizations using Seaborn.

```python
"""
Use Seaborn for statistical plots and visualizations.
"""

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Create data with statistical relationships
np.random.seed(42)
n = 500

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n)
})

# Add relationships
df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

# 1. Distribution plots (histogram, KDE, rug)
# 2. Categorical plots (box, violin, bar, count)
# 3. Relational plots (scatter, line)
# 4. Regression plots
# 5. Facet grids and pair plots

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'satisfaction': np.random.choice([1, 2, 3, 4, 5], n)
})

df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

print("Creating Seaborn visualizations...")

# 1. Distribution plots
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Histogram with KDE
sns.histplot(df['age'], kde=True, ax=axes[0, 0])
axes[0, 0].set_title('Age Distribution with KDE')

# KDE with rug
sns.kdeplot(df['income'], fill=True, ax=axes[0, 1])
sns.rugplot(df['income'], ax=axes[0, 1], alpha=0.3)
axes[0, 1].set_title('Income Distribution (KDE + Rug)')

# Distribution by category
sns.histplot(data=df, x='spending', hue='category', ax=axes[1, 0])
axes[1, 0].set_title('Spending Distribution by Category')

# Violin plot
sns.violinplot(x='category', y='spending', data=df, ax=axes[1, 1])
axes[1, 1].set_title('Spending Violin Plot by Category')

plt.tight_layout()
plt.savefig('data/seaborn_distributions.png')
plt.close()
print("Saved distribution plots to data/seaborn_distributions.png")

# 2. Categorical plots
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Box plot
sns.boxplot(x='category', y='spending', data=df, ax=axes[0])
axes[0].set_title('Box Plot by Category')

# Bar plot with error bars
sns.barplot(x='region', y='spending', data=df, ax=axes[1])
axes[1].set_title('Mean Spending by Region')

# Count plot
sns.countplot(x='category', hue='region', data=df, ax=axes[2])
axes[2].set_title('Category Counts by Region')

plt.tight_layout()
plt.savefig('data/seaborn_categorical.png')
plt.close()
print("Saved categorical plots to data/seaborn_categorical.png")

# 3. Relational plots
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Scatter with regression
sns.regplot(x='income', y='spending', data=df, ax=axes[0])
axes[0].set_title('Income vs Spending (with Regression)')

# Scatter with color
sns.scatterplot(x='income', y='spending', hue='category', data=df, ax=axes[1])
axes[1].set_title('Income vs Spending by Category')

plt.tight_layout()
plt.savefig('data/seaborn_relational.png')
plt.close()
print("Saved relational plots to data/seaborn_relational.png")

# 4. Pair plot (multi-variable)
print("Creating pair plot (may take a moment)...")
variables = ['age', 'income', 'spending', 'satisfaction']
g = sns.pairplot(df[variables + ['category']], hue='category', diag_kind='kde')
g.fig.suptitle('Pair Plot of Numeric Variables', y=1.02)
g.fig.savefig('data/seaborn_pairplot.png', dpi=300, bbox_inches='tight')
plt.close()
print("Saved pair plot to data/seaborn_pairplot.png")

# 5. Facet grid
print("Creating facet grid...")
g = sns.FacetGrid(df, col='region', row='category', margin_titles=True)
g.map(sns.scatterplot, 'income', 'spending', alpha=0.5)
g.fig.suptitle('Income vs Spending by Region and Category', y=1.02)
g.fig.savefig('data/seaborn_facetgrid.png', dpi=300, bbox_inches='tight')
plt.close()
print("Saved facet grid to data/seaborn_facetgrid.png")

# 6. Heatmap (correlation)
print("Creating correlation heatmap...")
corr = df[['age', 'income', 'spending', 'satisfaction']].corr()
plt.figure(figsize=(8, 6))
mask = np.triu(np.ones_like(corr, dtype=bool))
sns.heatmap(corr, mask=mask, annot=True, fmt='.2f', cmap='RdBu', center=0)
plt.title('Correlation Heatmap')
plt.tight_layout()
plt.savefig('data/seaborn_heatmap.png')
plt.close()
print("Saved correlation heatmap to data/seaborn_heatmap.png")
```
</details>

---

### Exercise W9.3: Altair Declarative Visualization

**Objective:** Create declarative, interactive visualizations with Altair.

```python
"""
Use Altair's declarative grammar for web-ready visualizations.
"""

import altair as alt
import pandas as pd
import numpy as np

# Create data
np.random.seed(42)
n = 500

df = pd.DataFrame({
    'date': pd.date_range('2025-01-01', periods=n),
    'sales': np.random.normal(1000, 200, n).cumsum() + 5000,
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# 1. Create a scatter plot
# 2. Create a bar chart
# 3. Create a line chart for time series
# 4. Add interactivity (tooltips, selection)
# 5. Create a faceted chart

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import altair as alt
import pandas as pd
import numpy as np

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'date': pd.date_range('2025-01-01', periods=n),
    'sales': np.random.normal(1000, 200, n).cumsum() + 5000,
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

print("Creating Altair visualizations...")

# 1. Scatter plot
scatter = alt.Chart(df).mark_circle(size=60, opacity=0.6).encode(
    x='date:T',
    y='sales:Q',
    color='category:N',
    tooltip=['date', 'sales', 'category']
).properties(
    title='Sales Over Time by Category',
    width=600,
    height=400
)
scatter.save('data/altair_scatter.html')
print("Saved scatter plot to data/altair_scatter.html")

# 2. Bar chart
bar = alt.Chart(df).mark_bar().encode(
    x='category:N',
    y='mean(sales):Q',
    color='category:N'
).properties(
    title='Average Sales by Category',
    width=600,
    height=400
)
bar.save('data/altair_bar.html')
print("Saved bar chart to data/altair_bar.html")

# 3. Time series line chart
# Aggregate by month first
df['month'] = df['date'].dt.to_period('M').astype(str)
monthly = df.groupby(['month', 'category']).agg({
    'sales': 'mean'
}).reset_index()

line = alt.Chart(monthly).mark_line(point=True).encode(
    x='month:T',
    y='sales:Q',
    color='category:N'
).properties(
    title='Monthly Sales by Category',
    width=600,
    height=400
)
line.save('data/altair_line.html')
print("Saved line chart to data/altair_line.html")

# 4. Interactive chart
brush = alt.selection_interval()

interactive = alt.Chart(df).mark_circle(size=60).encode(
    x='date:T',
    y='sales:Q',
    color=alt.condition(brush, 'category:N', alt.value('lightgray')),
    tooltip=['date', 'sales', 'category']
).add_params(
    brush
).properties(
    title='Interactive Sales Chart (select to filter)',
    width=600,
    height=400
)
interactive.save('data/altair_interactive.html')
print("Saved interactive chart to data/altair_interactive.html")

# 5. Faceted chart
facet = alt.Chart(df).mark_circle(size=30, opacity=0.5).encode(
    x='date:T',
    y='sales:Q'
).facet(
    row='category:N',
    column='region:N'
).properties(
    title='Sales by Category and Region',
    width=200,
    height=150
)
facet.save('data/altair_facet.html')
print("Saved faceted chart to data/altair_facet.html")

# 6. Layered chart
base = alt.Chart(df).encode(
    x='date:T',
    y='sales:Q'
)

# Scatter layer
scatter_layer = base.mark_circle(size=30, opacity=0.5).encode(
    color='region:N'
)

# Regression line
regression = base.transform_regression(
    'date',
    'sales',
    groupby=['region']
).mark_line()

layered = (scatter_layer + regression).properties(
    title='Sales with Regression Line by Region',
    width=600,
    height=400
)
layered.save('data/altair_layered.html')
print("Saved layered chart to data/altair_layered.html")

print("\nAll Altair charts saved as HTML. Open in browser to view.")
```
</details>

---

### Exercise W9.4: Publication-Ready Figures

**Objective:** Create figures suitable for papers and reports.

```python
"""
Create professional, publication-ready visualizations.
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.patches import Rectangle

# Create data
np.random.seed(42)
data = {
    'method': ['A', 'B', 'C', 'D'],
    'performance': [85, 72, 88, 65],
    'std': [5, 4, 6, 7],
    'time': [10, 15, 12, 8]
}
df = pd.DataFrame(data)

# 1. Professional bar chart with error bars
# 2. Professional scatter plot with annotations
# 3. Professional heatmap with proper styling
# 4. Multi-panel figure for publication
# 5. Use publication-ready fonts and styles

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.patches import Rectangle

np.random.seed(42)
data = {
    'method': ['A', 'B', 'C', 'D'],
    'performance': [85, 72, 88, 65],
    'std': [5, 4, 6, 7],
    'time': [10, 15, 12, 8]
}
df = pd.DataFrame(data)

# Set publication-ready style
plt.style.use('seaborn-v0_8-paper')
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.size'] = 12
plt.rcParams['figure.dpi'] = 300

print("Creating publication-ready figures...")

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.subplots_adjust(hspace=0.3, wspace=0.3)

# 1. Professional bar chart
ax = axes[0, 0]
colors = ['#2C3E50', '#3498DB', '#2ECC71', '#E74C3C']
bars = ax.bar(df['method'], df['performance'], yerr=df['std'], 
              capsize=5, color=colors, edgecolor='black', linewidth=0.5)
ax.set_ylabel('Performance (%)', fontsize=11)
ax.set_xlabel('Method', fontsize=11)
ax.set_title('Performance Comparison', fontsize=12, fontweight='bold')
ax.set_ylim(0, 100)
ax.grid(True, alpha=0.2, axis='y')

# Add value labels on bars
for bar, value, std in zip(bars, df['performance'], df['std']):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2,
            f'{value:.1f}±{std:.1f}', ha='center', va='bottom', fontsize=9)

# 2. Professional scatter plot
ax = axes[0, 1]
np.random.seed(42)
x = np.random.randn(50)
y = 2 * x + 1 + np.random.randn(50) * 0.5
ax.scatter(x, y, alpha=0.6, s=40, c='#3498DB', edgecolor='black', linewidth=0.5)

# Add trend line
z = np.polyfit(x, y, 1)
p = np.poly1d(z)
x_line = np.linspace(x.min(), x.max(), 100)
ax.plot(x_line, p(x_line), color='#E74C3C', linewidth=2, label=f'y={z[0]:.2f}x+{z[1]:.2f}')

# Add annotation
ax.annotate('Outlier', xy=(1.5, 4), xytext=(1, 4.5),
            arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
ax.set_xlabel('X Variable', fontsize=11)
ax.set_ylabel('Y Variable', fontsize=11)
ax.set_title('Relationship with Trend Line', fontsize=12, fontweight='bold')
ax.legend(loc='upper left', frameon=True, fancybox=True)
ax.grid(True, alpha=0.2)

# 3. Professional heatmap
ax = axes[1, 0]
matrix = np.random.randn(8, 8)
im = ax.imshow(matrix, cmap='RdBu', vmin=-2, vmax=2, aspect='auto')
ax.set_xticks(range(8))
ax.set_yticks(range(8))
ax.set_xticklabels([f'F{i}' for i in range(8)], rotation=45, ha='right')
ax.set_yticklabels([f'F{i}' for i in range(8)])
ax.set_title('Correlation Matrix', fontsize=12, fontweight='bold')

# Add colorbar
plt.colorbar(im, ax=ax, shrink=0.8)

# 4. Professional time series
ax = axes[1, 1]
dates = pd.date_range('2025-01-01', periods=100)
values = np.random.randn(100).cumsum() + 50
ax.plot(dates, values, color='#2C3E50', linewidth=2)
ax.fill_between(dates, values - 5, values + 5, alpha=0.2, color='#3498DB')
ax.set_xlabel('Date', fontsize=11)
ax.set_ylabel('Value', fontsize=11)
ax.set_title('Time Series with Confidence Band', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.2)

# Add highlight
ax.axvspan('2025-02-01', '2025-02-15', alpha=0.3, color='yellow', label='Event Period')
ax.legend(loc='upper left')

# Overall title
fig.suptitle('Publication-Ready Data Visualization', fontsize=16, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('data/publication_ready.png', dpi=300, bbox_inches='tight')
plt.close()
print("Saved publication-ready figure to data/publication_ready.png")
```
</details>

---

### Exercise W9.5: Multi-Plot Layouts

**Objective:** Create complex multi-plot layouts.

```python
"""
Create sophisticated multi-plot layouts with Matplotlib and Seaborn.
"""

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import seaborn as sns
import pandas as pd
import numpy as np

# Create data
np.random.seed(42)
n = 500
df = pd.DataFrame({
    'age': np.random.normal(40, 15, n),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# Add relationships
df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

# 1. Create a dashboard-style layout with 6+ subplots
# 2. Use different visualization types
# 3. Add proper titles and labels
# 4. Ensure the layout is clean and professional

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import seaborn as sns
import pandas as pd
import numpy as np

np.random.seed(42)
n = 500
df = pd.DataFrame({
    'age': np.random.normal(40, 15, n),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})
df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

print("Creating dashboard layout...")

# Create figure with GridSpec
fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(3, 3, figure=fig, hspace=0.4, wspace=0.3)

# 1. Histogram (top-left)
ax = fig.add_subplot(gs[0, 0])
sns.histplot(df['age'], kde=True, ax=ax, color='#2E86C1')
ax.set_title('Age Distribution', fontsize=12, fontweight='bold')
ax.set_xlabel('Age')
ax.set_ylabel('Frequency')
ax.grid(True, alpha=0.2)

# 2. Box plot (top-middle)
ax = fig.add_subplot(gs[0, 1])
sns.boxplot(x='category', y='spending', data=df, ax=ax)
ax.set_title('Spending by Category', fontsize=12, fontweight='bold')
ax.set_xlabel('Category')
ax.set_ylabel('Spending')
ax.grid(True, alpha=0.2)

# 3. Scatter plot (top-right)
ax = fig.add_subplot(gs[0, 2])
sns.scatterplot(x='income', y='spending', hue='category', data=df, ax=ax, alpha=0.6)
ax.set_title('Income vs Spending', fontsize=12, fontweight='bold')
ax.set_xlabel('Income')
ax.set_ylabel('Spending')
ax.legend(title='Category', loc='upper left')
ax.grid(True, alpha=0.2)

# 4. Bar chart (middle-left)
ax = fig.add_subplot(gs[1, 0])
region_means = df.groupby('region')['spending'].mean().sort_values()
ax.bar(region_means.index, region_means.values, color='#27AE60')
ax.set_title('Avg Spending by Region', fontsize=12, fontweight='bold')
ax.set_xlabel('Region')
ax.set_ylabel('Avg Spending')
ax.grid(True, alpha=0.2, axis='y')

# 5. Violin plot (middle-middle)
ax = fig.add_subplot(gs[1, 1])
sns.violinplot(x='region', y='age', data=df, ax=ax)
ax.set_title('Age Distribution by Region', fontsize=12, fontweight='bold')
ax.set_xlabel('Region')
ax.set_ylabel('Age')
ax.grid(True, alpha=0.2)

# 6. Correlation heatmap (middle-right)
ax = fig.add_subplot(gs[1, 2])
corr = df[['age', 'income', 'spending']].corr()
sns.heatmap(corr, annot=True, fmt='.2f', cmap='RdBu', center=0, ax=ax,
            vmin=-1, vmax=1, square=True)
ax.set_title('Correlation Matrix', fontsize=12, fontweight='bold')

# 7. Count plot (bottom-left)
ax = fig.add_subplot(gs[2, 0])
sns.countplot(x='region', hue='category', data=df, ax=ax)
ax.set_title('Category Counts by Region', fontsize=12, fontweight='bold')
ax.set_xlabel('Region')
ax.set_ylabel('Count')
ax.legend(title='Category')
ax.grid(True, alpha=0.2, axis='y')

# 8. Pair plot (bottom-middle and bottom-right combined)
ax = fig.add_subplot(gs[2, 1:])
# Create a small pair plot with just a few variables
pair_vars = ['age', 'income', 'spending']
g = sns.pairplot(df[pair_vars + ['category']], 
                  hue='category', 
                  diag_kind='kde',
                  plot_kws={'alpha': 0.3, 's': 20},
                  diag_kws={'fill': True})
g.fig.subplots_adjust(top=0.92)
g.fig.suptitle('Pair Plot of Numeric Variables', fontsize=14, fontweight='bold')
g.fig.savefig('data/dashboard_pairplot.png', dpi=300, bbox_inches='tight')
plt.close()

# Save the main dashboard
fig.suptitle('Data Science Dashboard', fontsize=18, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('data/dashboard_layout.png', dpi=300, bbox_inches='tight')
plt.close()
print("Saved dashboard to data/dashboard_layout.png")
print("Saved pair plot to data/dashboard_pairplot.png")
```
</details>

---

## W10: Interactive Visualizations Exercises

### Exercise W10.1: Plotly Express

**Objective:** Create interactive visualizations with Plotly Express.

```python
"""
Use Plotly Express for quick interactive visualizations.
"""

import plotly.express as px
import pandas as pd
import numpy as np

# Create data
np.random.seed(42)
n = 300

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'date': pd.date_range('2025-01-01', periods=n)
})

df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

# 1. Create scatter plot
# 2. Create histogram
# 3. Create box plot
# 4. Create bar chart
# 5. Create line chart (time series)
# 6. Add interactivity (hover, zoom, selection)

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import plotly.express as px
import pandas as pd
import numpy as np

np.random.seed(42)
n = 300

df = pd.DataFrame({
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'date': pd.date_range('2025-01-01', periods=n)
})

df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

print("Creating Plotly Express visualizations...")

# 1. Scatter plot
fig = px.scatter(
    df,
    x='income',
    y='spending',
    color='category',
    size='age',
    hover_data=['region'],
    title='Income vs Spending by Category'
)
fig.write_html('data/plotly_scatter.html')
print("Saved scatter plot to data/plotly_scatter.html")

# 2. Histogram
fig = px.histogram(
    df,
    x='age',
    color='category',
    marginal='box',
    title='Age Distribution by Category'
)
fig.write_html('data/plotly_histogram.html')
print("Saved histogram to data/plotly_histogram.html")

# 3. Box plot
fig = px.box(
    df,
    x='category',
    y='spending',
    color='region',
    title='Spending Distribution by Category and Region'
)
fig.write_html('data/plotly_boxplot.html')
print("Saved box plot to data/plotly_boxplot.html")

# 4. Bar chart
avg_spending = df.groupby(['category', 'region'])['spending'].mean().reset_index()
fig = px.bar(
    avg_spending,
    x='category',
    y='spending',
    color='region',
    title='Average Spending by Category and Region',
    barmode='group'
)
fig.write_html('data/plotly_barchart.html')
print("Saved bar chart to data/plotly_barchart.html")

# 5. Line chart
daily = df.groupby('date')['spending'].mean().reset_index()
fig = px.line(
    daily,
    x='date',
    y='spending',
    title='Daily Average Spending'
)
fig.write_html('data/plotly_line.html')
print("Saved line chart to data/plotly_line.html")

# 6. Faceted scatter
fig = px.scatter(
    df,
    x='income',
    y='spending',
    color='category',
    facet_col='region',
    facet_row='category',
    title='Faceted Income vs Spending'
)
fig.write_html('data/plotly_facet.html')
print("Saved faceted chart to data/plotly_facet.html")

# 7. Animated scatter (by date)
df['month'] = df['date'].dt.strftime('%Y-%m')
fig = px.scatter(
    df,
    x='income',
    y='spending',
    color='category',
    animation_frame='month',
    size='age',
    title='Income vs Spending Over Time'
)
fig.write_html('data/plotly_animated.html')
print("Saved animated chart to data/plotly_animated.html")

print("\nAll charts saved as HTML. Open in browser to view.")
```
</details>

---

### Exercise W10.2: Plotly Graph Objects

**Objective:** Create advanced interactive visualizations with Plotly Graph Objects.

```python
"""
Use Plotly Graph Objects for fine-grained control.
"""

import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np

# Create data
np.random.seed(42)
n = 500

df = pd.DataFrame({
    'date': pd.date_range('2025-01-01', periods=n),
    'sales': np.random.normal(1000, 200, n).cumsum() + 5000,
    'cost': np.random.normal(600, 150, n).cumsum() + 3000,
    'category': np.random.choice(['A', 'B', 'C'], n)
})

# 1. Create a multi-panel figure
# 2. Add 3D scatter plot
# 3. Create a heatmap
# 4. Add annotations and custom styling
# 5. Save interactive HTML

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'date': pd.date_range('2025-01-01', periods=n),
    'sales': np.random.normal(1000, 200, n).cumsum() + 5000,
    'cost': np.random.normal(600, 150, n).cumsum() + 3000,
    'category': np.random.choice(['A', 'B', 'C'], n)
})

print("Creating Plotly Graph Objects visualizations...")

# 1. Multi-panel figure
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=('Sales Over Time', 'Cost Over Time',
                   'Sales vs Cost', 'Monthly Summary'),
    specs=[[{'type': 'scatter'}, {'type': 'scatter'}],
           [{'type': 'scatter'}, {'type': 'bar'}]]
)

# Row 1, Col 1: Sales time series
fig.add_trace(
    go.Scatter(
        x=df['date'],
        y=df['sales'],
        mode='lines',
        name='Sales',
        line=dict(color='green', width=2)
    ),
    row=1, col=1
)

# Row 1, Col 2: Cost time series
fig.add_trace(
    go.Scatter(
        x=df['date'],
        y=df['cost'],
        mode='lines',
        name='Cost',
        line=dict(color='red', width=2)
    ),
    row=1, col=2
)

# Row 2, Col 1: Sales vs Cost scatter
fig.add_trace(
    go.Scatter(
        x=df['sales'],
        y=df['cost'],
        mode='markers',
        name='Sales vs Cost',
        marker=dict(size=5, color=df['category'].astype('category').cat.codes,
                   colorscale='Viridis')
    ),
    row=2, col=1
)

# Row 2, Col 2: Monthly summary
monthly = df.groupby(df['date'].dt.to_period('M'))['sales'].mean().reset_index()
monthly['month'] = monthly['date'].astype(str)
fig.add_trace(
    go.Bar(
        x=monthly['month'],
        y=monthly['sales'],
        name='Avg Sales',
        marker_color='blue'
    ),
    row=2, col=2
)

fig.update_layout(height=800, width=1000, title_text="Sales Dashboard")
fig.write_html('data/plotly_multipanel.html')
print("Saved multi-panel figure to data/plotly_multipanel.html")

# 2. 3D Scatter plot
fig3d = go.Figure(data=[
    go.Scatter3d(
        x=df['sales'][:200],
        y=df['cost'][:200],
        z=df['date'][:200],
        mode='markers',
        marker=dict(
            size=5,
            color=df['category'][:200].astype('category').cat.codes,
            colorscale='Viridis',
            opacity=0.8
        )
    )
])
fig3d.update_layout(
    title='3D Sales Visualization',
    scene=dict(
        xaxis_title='Sales',
        yaxis_title='Cost',
        zaxis_title='Date'
    )
)
fig3d.write_html('data/plotly_3d.html')
print("Saved 3D plot to data/plotly_3d.html")

# 3. Heatmap
corr = df[['sales', 'cost']].corr()
fig_heat = go.Figure(data=[
    go.Heatmap(
        z=corr,
        x=corr.columns,
        y=corr.columns,
        colorscale='RdBu',
        zmin=-1,
        zmax=1
    )
])
fig_heat.update_layout(title='Correlation Heatmap')
fig_heat.write_html('data/plotly_heatmap.html')
print("Saved heatmap to data/plotly_heatmap.html")

print("\nAll charts saved as HTML. Open in browser to view.")
```
</details>

---

### Exercise W10.3: Interactive Dashboards

**Objective:** Build complete interactive dashboards.

```python
"""
Create an interactive dashboard with multiple charts.
"""

import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np

# Create data
np.random.seed(42)
n = 500

df = pd.DataFrame({
    'customer_id': range(1, n+1),
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'date': pd.date_range('2025-01-01', periods=n)
})

df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

# 1. Create a dashboard with 6+ charts
# 2. Use subplots
# 3. Add interactive elements
# 4. Include filters (dropdown, range slider)
# 5. Make it professional and user-friendly

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'customer_id': range(1, n+1),
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n),
    'date': pd.date_range('2025-01-01', periods=n)
})

df['spending'] = df['spending'] + df['income'] / 1000 * 0.5
df['spending'] = df['spending'].clip(0, 100)

print("Creating interactive dashboard...")

# Create dashboard with subplots
fig = make_subplots(
    rows=3, cols=3,
    subplot_titles=(
        'Spending by Category',
        'Income Distribution',
        'Spending by Region',
        'Age vs Spending',
        'Monthly Trend',
        'Category Distribution',
        'Income vs Spending',
        'Age Distribution',
        'Churn Risk'
    ),
    specs=[
        [{'type': 'box'}, {'type': 'histogram'}, {'type': 'bar'}],
        [{'type': 'scatter'}, {'type': 'scatter'}, {'type': 'pie'}],
        [{'type': 'scatter'}, {'type': 'histogram'}, {'type': 'bar'}]
    ]
)

# Row 1, Col 1: Spending by Category (box)
fig.add_trace(
    go.Box(
        x=df['category'],
        y=df['spending'],
        name='Spending',
        boxmean='sd'
    ),
    row=1, col=1
)

# Row 1, Col 2: Income Distribution
fig.add_trace(
    go.Histogram(
        x=df['income'],
        nbinsx=30,
        name='Income'
    ),
    row=1, col=2
)

# Row 1, Col 3: Spending by Region
region_spending = df.groupby('region')['spending'].mean().reset_index()
fig.add_trace(
    go.Bar(
        x=region_spending['region'],
        y=region_spending['spending'],
        name='Avg Spending'
    ),
    row=1, col=3
)

# Row 2, Col 1: Age vs Spending
fig.add_trace(
    go.Scatter(
        x=df['age'],
        y=df['spending'],
        mode='markers',
        marker=dict(size=5, opacity=0.5),
        name='Age vs Spending'
    ),
    row=2, col=1
)

# Row 2, Col 2: Monthly Trend
monthly = df.groupby(pd.Grouper(key='date', freq='M'))['spending'].mean().reset_index()
fig.add_trace(
    go.Scatter(
        x=monthly['date'],
        y=monthly['spending'],
        mode='lines+markers',
        name='Monthly Avg'
    ),
    row=2, col=2
)

# Row 2, Col 3: Category Distribution (pie)
cat_counts = df['category'].value_counts().reset_index()
cat_counts.columns = ['category', 'count']
fig.add_trace(
    go.Pie(
        labels=cat_counts['category'],
        values=cat_counts['count'],
        name='Categories'
    ),
    row=2, col=3
)

# Row 3, Col 1: Income vs Spending
fig.add_trace(
    go.Scatter(
        x=df['income'],
        y=df['spending'],
        mode='markers',
        marker=dict(
            size=6,
            color=df['category'].astype('category').cat.codes,
            colorscale='Viridis',
            showscale=True
        ),
        name='Income vs Spending'
    ),
    row=3, col=1
)

# Row 3, Col 2: Age Distribution
fig.add_trace(
    go.Histogram(
        x=df['age'],
        nbinsx=30,
        name='Age'
    ),
    row=3, col=2
)

# Row 3, Col 3: Churn Risk (simulated)
churn_risk = df.groupby('category')['spending'].apply(
    lambda x: (x < x.median()).mean() * 100
).reset_index()
churn_risk.columns = ['category', 'risk']
fig.add_trace(
    go.Bar(
        x=churn_risk['category'],
        y=churn_risk['risk'],
        name='Churn Risk %'
    ),
    row=3, col=3
)

# Update layout
fig.update_layout(
    height=1200,
    width=1400,
    title_text="Customer Analytics Dashboard",
    showlegend=False
)

# Update axes titles
fig.update_xaxes(title_text="Category", row=1, col=1)
fig.update_yaxes(title_text="Spending", row=1, col=1)
fig.update_xaxes(title_text="Income", row=1, col=2)
fig.update_xaxes(title_text="Region", row=1, col=3)
fig.update_xaxes(title_text="Age", row=2, col=1)
fig.update_yaxes(title_text="Spending", row=2, col=1)
fig.update_xaxes(title_text="Income", row=3, col=1)
fig.update_yaxes(title_text="Spending", row=3, col=1)
fig.update_xaxes(title_text="Age", row=3, col=2)

fig.write_html('data/plotly_dashboard.html')
print("Saved interactive dashboard to data/plotly_dashboard.html")

print("\nDashboard saved as HTML. Open in browser to view.")
```
</details>

---

### Exercise W10.4: Cross-Filtering

**Objective:** Implement cross-filtering between charts.

```python
"""
Create cross-filtering interactions between charts.
"""

import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np

# Create data
np.random.seed(42)
n = 300

df = pd.DataFrame({
    'x': np.random.randn(n),
    'y': np.random.randn(n),
    'z': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'group': np.random.choice(['Group1', 'Group2', 'Group3'], n)
})

# 1. Create a dashboard with cross-filtering capability
# 2. Use consistent color coding
# 3. Add selection interactions
# 4. Link charts together

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np

np.random.seed(42)
n = 300

df = pd.DataFrame({
    'x': np.random.randn(n),
    'y': np.random.randn(n),
    'z': np.random.randn(n),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n),
    'group': np.random.choice(['Group1', 'Group2', 'Group3'], n)
})

print("Creating cross-filtering dashboard...")

# Create figure with subplots
fig = make_subplots(
    rows=2, cols=3,
    subplot_titles=(
        'Scatter: x vs y',
        'Scatter: y vs z',
        'Scatter: x vs z',
        'Category Distribution',
        'Group Distribution',
        'Summary'
    ),
    specs=[
        [{'type': 'scatter'}, {'type': 'scatter'}, {'type': 'scatter'}],
        [{'type': 'histogram'}, {'type': 'pie'}, {'type': 'bar'}]
    ]
)

# Color mapping
colors = {'A': 'red', 'B': 'blue', 'C': 'green', 'D': 'orange'}

# Row 1: Scatter plots
for idx, (x_col, y_col) in enumerate([('x', 'y'), ('y', 'z'), ('x', 'z')]):
    row, col = 1, idx + 1
    for cat in df['category'].unique():
        subset = df[df['category'] == cat]
        fig.add_trace(
            go.Scatter(
                x=subset[x_col],
                y=subset[y_col],
                mode='markers',
                name=cat,
                marker=dict(color=colors[cat], size=8, opacity=0.6),
                legendgroup=cat,
                hovertemplate=f'Category: {cat}<br>{x_col}: %{{x:.2f}}<br>{y_col}: %{{y:.2f}}<extra></extra>'
            ),
            row=row, col=col
        )

# Row 2, Col 1: Category histogram
for cat in df['category'].unique():
    subset = df[df['category'] == cat]
    fig.add_trace(
        go.Histogram(
            x=subset['x'],
            name=cat,
            marker_color=colors[cat],
            opacity=0.6,
            legendgroup=cat
        ),
        row=2, col=1
    )

# Row 2, Col 2: Pie chart - Category distribution
cat_counts = df['category'].value_counts()
fig.add_trace(
    go.Pie(
        labels=cat_counts.index,
        values=cat_counts.values,
        marker=dict(colors=[colors[cat] for cat in cat_counts.index]),
        name='Categories'
    ),
    row=2, col=2
)

# Row 2, Col 3: Bar chart - Group by category
group_cat = df.groupby(['category', 'group']).size().unstack(fill_value=0)
for group in df['group'].unique():
    fig.add_trace(
        go.Bar(
            x=group_cat.index,
            y=group_cat[group],
            name=group,
            legendgroup=group
        ),
        row=2, col=3
    )

# Update layout
fig.update_layout(
    height=800,
    width=1200,
    title_text="Cross-Filtering Dashboard",
    barmode='overlay'
)

# Update axes
fig.update_xaxes(title_text="x", row=1, col=1)
fig.update_yaxes(title_text="y", row=1, col=1)
fig.update_xaxes(title_text="y", row=1, col=2)
fig.update_yaxes(title_text="z", row=1, col=2)
fig.update_xaxes(title_text="x", row=1, col=3)
fig.update_yaxes(title_text="z", row=1, col=3)
fig.update_xaxes(title_text="x", row=2, col=1)

fig.write_html('data/plotly_crossfilter.html')
print("Saved cross-filtering dashboard to data/plotly_crossfilter.html")

print("\nDashboard saved as HTML. Open in browser to view.")
print("Note: Click legend items to filter across all charts.")
```
</details>

---

### Exercise W10.5: Jupyter Widgets Integration

**Objective:** Use ipywidgets for interactive exploration.

```python
"""
Create interactive widgets for Jupyter notebooks.
"""

import pandas as pd
import numpy as np
import plotly.express as px
from ipywidgets import interact, widgets

# Note: This exercise is designed for Jupyter notebooks.
# The code below shows how to set up interactive widgets.

# 1. Create data
# 2. Define interactive function
# 3. Add sliders, dropdowns, and checkboxes
# 4. Connect widgets to plot updates

# Your code here (for Jupyter notebook)
```

<details>
<summary>Click for Solution</summary>

```python
"""
This exercise requires a Jupyter notebook environment.
The code below demonstrates the pattern.

To use:
1. Run in a Jupyter notebook
2. Install ipywidgets: pip install ipywidgets
3. Enable: jupyter nbextension enable --py widgetsnbextension
"""

import pandas as pd
import numpy as np
import plotly.express as px
from ipywidgets import interact, widgets
import ipywidgets as ipw

# Create data
np.random.seed(42)
n = 500
df = pd.DataFrame({
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'spending': np.random.normal(50, 20, n).clip(0, 100),
    'category': np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports'], n),
    'region': np.random.choice(['North', 'South', 'East', 'West'], n)
})

# Define the interactive plotting function
def interactive_plot(min_age=18, max_age=80, category='All', region='All'):
    """
    Interactive function to filter and plot data.
    """
    # Filter data
    filtered = df[(df['age'] >= min_age) & (df['age'] <= max_age)]
    
    if category != 'All':
        filtered = filtered[filtered['category'] == category]
    
    if region != 'All':
        filtered = filtered[filtered['region'] == region]
    
    # Create scatter plot
    fig = px.scatter(
        filtered,
        x='income',
        y='spending',
        color='category',
        title=f'Income vs Spending (n={len(filtered)})',
        labels={'income': 'Income ($)', 'spending': 'Spending Score'},
        opacity=0.7
    )
    
    fig.show()

# Set up interactive widgets
print("""
To run this in a Jupyter notebook, use:

@interact(
    min_age=widgets.IntSlider(min=18, max=80, value=18, step=1),
    max_age=widgets.IntSlider(min=18, max=80, value=80, step=1),
    category=widgets.Dropdown(options=['All'] + sorted(df['category'].unique().tolist())),
    region=widgets.Dropdown(options=['All'] + sorted(df['region'].unique().tolist()))
)
def interactive_plot_widget(min_age, max_age, category, region):
    interactive_plot(min_age, max_age, category, region)

# Or using the interactive function directly:
interact(
    interactive_plot,
    min_age=widgets.IntSlider(min=18, max=80, value=18, description='Min Age'),
    max_age=widgets.IntSlider(min=18, max=80, value=80, description='Max Age'),
    category=widgets.Dropdown(options=['All'] + sorted(df['category'].unique().tolist())),
    region=widgets.Dropdown(options=['All'] + sorted(df['region'].unique().tolist()))
)
""")

# Preview the interactive pattern
print("\nCategories available:", sorted(df['category'].unique().tolist()))
print("Regions available:", sorted(df['region'].unique().tolist()))

# Example of the interactive function
print("\nExample: Filtering with min_age=30, max_age=60, category='Electronics'")
interactive_plot(min_age=30, max_age=60, category='Electronics', region='All')
```
</details>

---

## W11: Hypothesis Testing Exercises

### Exercise W11.1: Parametric Tests

**Objective:** Apply parametric hypothesis tests.

```python
"""
Use t-tests and ANOVA for hypothesis testing.
"""

import numpy as np
from scipy import stats
from scipy.stats import ttest_1samp, ttest_ind, ttest_rel, f_oneway

# 1. One-sample t-test
# 2. Independent two-sample t-test
# 3. Paired t-test
# 4. One-way ANOVA
# 5. Post-hoc tests

# Generate data
np.random.seed(42)
sample1 = np.random.normal(105, 15, 50)
sample2 = np.random.normal(100, 15, 50)
sample3 = np.random.normal(112, 15, 50)
before = np.random.normal(50, 10, 30)
after = before + np.random.normal(3, 5, 30)

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
from scipy import stats
from scipy.stats import ttest_1samp, ttest_ind, ttest_rel, f_oneway

np.random.seed(42)
sample1 = np.random.normal(105, 15, 50)
sample2 = np.random.normal(100, 15, 50)
sample3 = np.random.normal(112, 15, 50)
before = np.random.normal(50, 10, 30)
after = before + np.random.normal(3, 5, 30)

print("="*60)
print("PARAMETRIC HYPOTHESIS TESTS")
print("="*60)

# 1. One-sample t-test
print("\n1. One-sample t-test:")
print("-"*40)

hypothesized_mean = 100
t_stat, p_value = ttest_1samp(sample1, hypothesized_mean)
print(f"Sample mean: {np.mean(sample1):.2f}")
print(f"Hypothesized mean: {hypothesized_mean}")
print(f"t-statistic: {t_stat:.4f}")
print(f"p-value: {p_value:.4f}")
if p_value < 0.05:
    print("✓ Reject H₀: Sample mean significantly different")
    print(f"  → Mean difference: {np.mean(sample1) - hypothesized_mean:.2f}")
else:
    print("✗ Fail to reject H₀: No significant difference")

# 2. Independent t-test
print("\n2. Independent t-test:")
print("-"*40)

t_stat, p_value = ttest_ind(sample1, sample2)
print(f"Group 1 mean: {np.mean(sample1):.2f}")
print(f"Group 2 mean: {np.mean(sample2):.2f}")
print(f"Mean diff: {np.mean(sample1) - np.mean(sample2):.2f}")
print(f"t-statistic: {t_stat:.4f}")
print(f"p-value: {p_value:.4f}")
if p_value < 0.05:
    print("✓ Significant difference between groups")
else:
    print("✗ No significant difference")

# Effect size
pooled_std = np.sqrt((np.std(sample1, ddof=1)**2 + np.std(sample2, ddof=1)**2) / 2)
cohens_d = abs(np.mean(sample1) - np.mean(sample2)) / pooled_std
print(f"Effect size (Cohen's d): {cohens_d:.3f}")

# 3. Paired t-test
print("\n3. Paired t-test:")
print("-"*40)

t_stat, p_value = ttest_rel(before, after)
print(f"Before: {np.mean(before):.2f}")
print(f"After: {np.mean(after):.2f}")
print(f"Change: {np.mean(after) - np.mean(before):.2f}")
print(f"t-statistic: {t_stat:.4f}")
print(f"p-value: {p_value:.4f}")
if p_value < 0.05:
    print("✓ Significant change detected")
else:
    print("✗ No significant change")

# 4. One-way ANOVA
print("\n4. One-way ANOVA:")
print("-"*40)

f_stat, p_value = f_oneway(sample1, sample2, sample3)
print(f"Group 1 mean: {np.mean(sample1):.2f}")
print(f"Group 2 mean: {np.mean(sample2):.2f}")
print(f"Group 3 mean: {np.mean(sample3):.2f}")
print(f"F-statistic: {f_stat:.4f}")
print(f"p-value: {p_value:.4f}")
if p_value < 0.05:
    print("✓ Significant difference between groups")
else:
    print("✗ No significant difference")

# 5. Post-hoc (if ANOVA significant)
if p_value < 0.05:
    print("\n5. Post-hoc Tests:")
    print("-"*40)
    from statsmodels.stats.multicomp import pairwise_tukeyhsd
    
    all_data = np.concatenate([sample1, sample2, sample3])
    groups = np.concatenate([
        np.repeat('Group1', len(sample1)),
        np.repeat('Group2', len(sample2)),
        np.repeat('Group3', len(sample3))
    ])
    
    tukey = pairwise_tukeyhsd(all_data, groups, alpha=0.05)
    print(tukey)
```
</details>

---

### Exercise W11.2: Non-Parametric Tests

**Objective:** Apply non-parametric hypothesis tests.

```python
"""
Use non-parametric tests for non-normal data.
"""

import numpy as np
from scipy.stats import mannwhitneyu, wilcoxon, kruskal, chi2_contingency

# Generate non-normal data
np.random.seed(42)
group1 = np.random.exponential(10, 50)
group2 = np.random.exponential(12, 50)
group3 = np.random.exponential(15, 50)
before = np.random.exponential(10, 30)
after = before + np.random.exponential(2, 30)

# 1. Mann-Whitney U test (independent)
# 2. Wilcoxon signed-rank test (paired)
# 3. Kruskal-Wallis test (multiple groups)
# 4. Chi-square test of independence

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
from scipy.stats import mannwhitneyu, wilcoxon, kruskal, chi2_contingency
import pandas as pd

np.random.seed(42)
group1 = np.random.exponential(10, 50)
group2 = np.random.exponential(12, 50)
group3 = np.random.exponential(15, 50)
before = np.random.exponential(10, 30)
after = before + np.random.exponential(2, 30)

print("="*60)
print("NON-PARAMETRIC HYPOTHESIS TESTS")
print("="*60)

# Check normality
print("\nChecking normality (for comparison):")
print("-"*40)
from scipy.stats import shapiro

for name, data in [('Group1', group1), ('Group2', group2), ('Group3', group3)]:
    stat, p = shapiro(data)
    print(f"{name}: p={p:.4f} {'(Non-normal)' if p < 0.05 else '(Normal)'}")

# 1. Mann-Whitney U test
print("\n1. Mann-Whitney U Test:")
print("-"*40)

u_stat, p_value = mannwhitneyu(group1, group2)
print(f"Group 1 median: {np.median(group1):.2f}")
print(f"Group 2 median: {np.median(group2):.2f}")
print(f"U-statistic: {u_stat:.4f}")
print(f"p-value: {p_value:.4f}")
if p_value < 0.05:
    print("✓ Significant difference between groups")
else:
    print("✗ No significant difference")

# 2. Wilcoxon signed-rank test
print("\n2. Wilcoxon Signed-Rank Test:")
print("-"*40)

w_stat, p_value = wilcoxon(before, after)
print(f"Before median: {np.median(before):.2f}")
print(f"After median: {np.median(after):.2f}")
print(f"Change: {np.median(after) - np.median(before):.2f}")
print(f"W-statistic: {w_stat:.4f}")
print(f"p-value: {p_value:.4f}")
if p_value < 0.05:
    print("✓ Significant change detected")
else:
    print("✗ No significant change")

# 3. Kruskal-Wallis test
print("\n3. Kruskal-Wallis H Test:")
print("-"*40)

h_stat, p_value = kruskal(group1, group2, group3)
print(f"H-statistic: {h_stat:.4f}")
print(f"p-value: {p_value:.4f}")
if p_value < 0.05:
    print("✓ Significant difference between groups")
else:
    print("✗ No significant difference")

# 4. Chi-square test
print("\n4. Chi-square Test of Independence:")
print("-"*40)

# Create contingency table
data = pd.DataFrame({
    'Category': np.random.choice(['A', 'B', 'C'], 200),
    'Outcome': np.random.choice(['Success', 'Failure'], 200)
})

contingency = pd.crosstab(data['Category'], data['Outcome'])
print("Contingency Table:")
print(contingency)

chi2, p_value, dof, expected = chi2_contingency(contingency)
print(f"\nChi-square: {chi2:.4f}")
print(f"p-value: {p_value:.4f}")
print(f"Degrees of freedom: {dof}")
if p_value < 0.05:
    print("✓ Significant relationship between variables")
else:
    print("✗ No significant relationship")
```
</details>

---

### Exercise W11.3: Power Analysis

**Objective:** Perform power analysis for experiment design.

```python
"""
Calculate required sample sizes using power analysis.
"""

import numpy as np
from statsmodels.stats.power import TTestIndPower

# 1. Calculate sample size for given effect size
# 2. Calculate power for given sample size
# 3. Create power curves
# 4. Explore relationship between effect size and sample size

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
from statsmodels.stats.power import TTestIndPower
import matplotlib.pyplot as plt

print("="*60)
print("POWER ANALYSIS")
print("="*60)

# Parameters
alpha = 0.05
power = 0.80
effect_sizes = [0.2, 0.5, 0.8]  # Small, medium, large

print("\n1. Sample Size Calculation:")
print("-"*40)

power_analysis = TTestIndPower()
print(f"Target power: {power}")
print(f"Alpha: {alpha}")

for es in effect_sizes:
    n = power_analysis.solve_power(
        effect_size=es,
        alpha=alpha,
        power=power,
        alternative='two-sided'
    )
    n = int(np.ceil(n))
    print(f"\nEffect size {es:.1f}: {n} per group (total {n*2})")

# 2. Power for given sample size
print("\n" + "-"*40)
print("2. Power for Given Sample Size:")
print("-"*40)

sample_sizes = [20, 50, 100, 200]
effect_size = 0.5

print(f"Effect size: {effect_size:.1f}")
print(f"Alpha: {alpha}")
print(f"Sample size (per group):")

for n in sample_sizes:
    power_calc = power_analysis.power(
        effect_size=effect_size,
        nobs1=n,
        alpha=alpha,
        alternative='two-sided'
    )
    print(f"  n={n}: {power_calc:.3f}")

# 3. Power curves
print("\n" + "-"*40)
print("3. Power Curves:")
print("-"*40)

fig, ax = plt.subplots(figsize=(10, 6))

effect_sizes_range = np.linspace(0.1, 1.0, 20)
sample_sizes_curves = [20, 50, 100, 200]

for n in sample_sizes_curves:
    power_curve = power_analysis.power(
        effect_size=effect_sizes_range,
        nobs1=n,
        alpha=alpha,
        alternative='two-sided'
    )
    ax.plot(effect_sizes_range, power_curve, label=f'n={n}')

ax.axhline(0.80, color='red', linestyle='--', label='Target power (0.80)')
ax.set_xlabel('Effect Size (Cohen\'s d)')
ax.set_ylabel('Power')
ax.set_title('Power Curves for Different Sample Sizes')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('data/power_curves.png')
plt.close()
print("Saved power curves to data/power_curves.png")

# 4. Sample size vs effect size
print("\n" + "-"*40)
print("4. Sample Size vs Effect Size:")
print("-"*40)

effect_sizes_sample = np.linspace(0.1, 1.0, 10)
sample_sizes_needed = []

for es in effect_sizes_sample:
    n = power_analysis.solve_power(
        effect_size=es,
        alpha=alpha,
        power=power,
        alternative='two-sided'
    )
    sample_sizes_needed.append(np.ceil(n))

print("Effect size → Sample size (per group):")
for es, n in zip(effect_sizes_sample[::2], sample_sizes_needed[::2]):
    print(f"  {es:.1f} → {int(n)}")

print("\n" + "="*60)
print("INTERPRETATION:")
print("="*60)
print("""
- Small effect (d=0.2): Need ~393 per group
- Medium effect (d=0.5): Need ~64 per group  
- Large effect (d=0.8): Need ~26 per group

Use these guidelines when designing experiments:
1. Estimate expected effect size (based on prior research)
2. Determine desired power (typically 0.80)
3. Calculate required sample size
4. Ensure you can collect that many samples
""")
```
</details>

---

### Exercise W11.4: Multiple Testing

**Objective:** Apply multiple testing corrections.

```python
"""
Handle multiple comparisons to control false positives.
"""

import numpy as np
from scipy.stats import ttest_ind
from statsmodels.stats.multitest import multipletests

# Simulate multiple tests
np.random.seed(42)
n_tests = 100
n_samples = 30

# Generate data where 20% have real effects
p_values = []
for i in range(n_tests):
    if np.random.random() < 0.2:
        group1 = np.random.normal(100, 15, n_samples)
        group2 = np.random.normal(108, 15, n_samples)
    else:
        group1 = np.random.normal(100, 15, n_samples)
        group2 = np.random.normal(100, 15, n_samples)
    
    _, p_val = ttest_ind(group1, group2)
    p_values.append(p_val)

# 1. Count significant results without correction
# 2. Apply Bonferroni correction
# 3. Apply False Discovery Rate (FDR) correction
# 4. Compare methods

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
from scipy.stats import ttest_ind
from statsmodels.stats.multitest import multipletests
import matplotlib.pyplot as plt

np.random.seed(42)
n_tests = 100
n_samples = 30

p_values = []
for i in range(n_tests):
    if np.random.random() < 0.2:
        group1 = np.random.normal(100, 15, n_samples)
        group2 = np.random.normal(108, 15, n_samples)
    else:
        group1 = np.random.normal(100, 15, n_samples)
        group2 = np.random.normal(100, 15, n_samples)
    
    _, p_val = ttest_ind(group1, group2)
    p_values.append(p_val)

print("="*60)
print("MULTIPLE TESTING CORRECTION")
print("="*60)

print(f"Number of tests: {n_tests}")
print(f"Expected true effects: {int(n_tests * 0.2)} (20%)")
print(f"Alpha level: 0.05")

# 1. No correction
print("\n1. No Correction:")
print("-"*40)
significant_raw = sum(np.array(p_values) < 0.05)
print(f"Significant results: {significant_raw}")
print(f"Expected false positives: ~5 (5%)")

# 2. Bonferroni
print("\n2. Bonferroni Correction:")
print("-"*40)
bonferroni_p = np.array(p_values) * n_tests
bonferroni_p = np.clip(bonferroni_p, 0, 1)
significant_bonf = sum(bonferroni_p < 0.05)
print(f"Adjusted alpha: {0.05/n_tests:.6f}")
print(f"Significant results: {significant_bonf}")

# 3. FDR (Benjamini-Hochberg)
print("\n3. FDR Correction (Benjamini-Hochberg):")
print("-"*40)
rejected_fdr, p_adjusted_fdr, _, _ = multipletests(p_values, alpha=0.05, method='fdr_bh')
significant_fdr = rejected_fdr.sum()
print(f"Significant results: {significant_fdr}")

# 4. Comparison
print("\n" + "-"*40)
print("4. Comparison of Methods:")
print("-"*40)

methods = ['Raw', 'Bonferroni', 'FDR']
significant_counts = [significant_raw, significant_bonf, significant_fdr]

for method, count in zip(methods, significant_counts):
    print(f"{method}: {count} significant results")

# 5. Visualization
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# P-value distribution
ax = axes[0]
ax.hist(p_values, bins=20, edgecolor='black', alpha=0.7)
ax.axvline(0.05, color='red', linestyle='--', label='α=0.05')
ax.set_xlabel('P-value')
ax.set_ylabel('Frequency')
ax.set_title('Distribution of P-values')
ax.legend()
ax.grid(True, alpha=0.3)

# Comparison
ax = axes[1]
ax.bar(methods, significant_counts, color=['blue', 'green', 'orange'])
ax.axhline(n_tests * 0.2, color='red', linestyle='--', 
           label='Expected true positives')
ax.set_ylabel('Significant Results')
ax.set_title('Comparison of Correction Methods')
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('data/multiple_testing_comparison.png')
plt.close()
print("\nSaved comparison to data/multiple_testing_comparison.png")

print("\n" + "="*60)
print("GUIDELINES:")
print("="*60)
print("""
Bonferroni:
- Most conservative (fewer false positives)
- Use when false positives are very costly
- Can miss true effects (low power)

FDR (Benjamini-Hochberg):
- More permissive (more discoveries)
- Use when you can tolerate some false positives
- More powerful for exploratory analysis

Raw (No Correction):
- Use ONLY for pre-specified hypotheses
- May have high false positives
- Not recommended for exploratory analysis
""")
```
</details>

---

### Exercise W11.5: A/B Test Simulation

**Objective:** Simulate a complete A/B test.

```python
"""
Design and analyze a complete A/B test simulation.
"""

import numpy as np
from scipy.stats import chi2_contingency
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize

# 1. Design phase (power analysis)
# 2. Generate A/B test data
# 3. Analyze results
# 4. Make decision

# Parameters
baseline_conversion = 0.10
expected_lift = 0.02
alpha = 0.05
power = 0.80

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
from scipy.stats import chi2_contingency
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize
import matplotlib.pyplot as plt

print("="*60)
print("COMPLETE A/B TEST SIMULATION")
print("="*60)

# 1. Design Phase
print("\n1. Design Phase:")
print("-"*40)

baseline_conversion = 0.10
expected_lift = 0.02
alpha = 0.05
power = 0.80

effect_size = proportion_effectsize(baseline_conversion, 
                                   baseline_conversion + expected_lift)

print(f"Baseline conversion: {baseline_conversion*100:.1f}%")
print(f"Expected lift: {expected_lift*100:.1f} percentage points")
print(f"Expected conversion: {(baseline_conversion + expected_lift)*100:.1f}%")
print(f"Effect size (Cohen's h): {effect_size:.4f}")

power_analysis = NormalIndPower()
n = power_analysis.solve_power(
    effect_size=effect_size,
    alpha=alpha,
    power=power,
    alternative='two-sided'
)
n = int(np.ceil(n))

print(f"Required sample size per group: {n}")
print(f"Total sample size: {n*2}")

# 2. Generate Data
print("\n2. Data Generation:")
print("-"*40)

np.random.seed(42)

# Control
control = np.random.binomial(1, baseline_conversion, n)
control_conversion = np.mean(control)

# Treatment
treatment = np.random.binomial(1, baseline_conversion + expected_lift, n)
treatment_conversion = np.mean(treatment)

print(f"Control conversion: {control_conversion*100:.2f}%")
print(f"Treatment conversion: {treatment_conversion*100:.2f}%")
print(f"Observed lift: {(treatment_conversion - control_conversion)*100:.2f} percentage points")

# 3. Analyze
print("\n3. Analysis:")
print("-"*40)

# Chi-square test
contingency = np.array([
    [sum(control == 0), sum(control == 1)],
    [sum(treatment == 0), sum(treatment == 1)]
])
chi2, p_value, _, _ = chi2_contingency(contingency)

print(f"Chi-square statistic: {chi2:.4f}")
print(f"p-value: {p_value:.4f}")

# 4. Decision
print("\n4. Decision:")
print("-"*40)

is_significant = p_value < alpha
if is_significant:
    if treatment_conversion > control_conversion:
        print("✅ Implement treatment: Significant improvement detected")
    else:
        print("⚠️ Investigate: Significant decrease detected")
else:
    print("✗ No significant difference detected")
    print("  → Consider running longer or increasing sample size")

# 5. Visualize
print("\n5. Visualization:")
print("-"*40)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Conversion rates
ax = axes[0]
rates = [control_conversion, treatment_conversion]
labels = ['Control', 'Treatment']
colors = ['blue', 'green'] if treatment_conversion > control_conversion else ['blue', 'red']
ax.bar(labels, rates, color=colors, alpha=0.7, edgecolor='black')
ax.set_ylabel('Conversion Rate')
ax.set_title('Conversion Rates')
ax.set_ylim([0, max(rates) * 1.2])
ax.grid(True, alpha=0.3, axis='y')

# Confidence intervals
ax = axes[1]
for i, (name, data) in enumerate([('Control', control), ('Treatment', treatment)]):
    mean = np.mean(data)
    se = np.sqrt(mean * (1 - mean) / len(data))
    ci_lower = mean - 1.96 * se
    ci_upper = mean + 1.96 * se
    ax.errorbar(name, mean, yerr=[[mean - ci_lower], [ci_upper - mean]], 
               fmt='o', capsize=5, capthick=2, markersize=10)
ax.set_ylabel('Conversion Rate')
ax.set_title('95% Confidence Intervals')
ax.grid(True, alpha=0.3)

# P-value
ax = axes[2]
x = np.linspace(0, 15, 1000)
y = chi2.pdf(x, df=1)
ax.plot(x, y, 'b-', linewidth=2)
x_critical = chi2.ppf(0.95, df=1)
x_reject = x[x > x_critical]
ax.fill_between(x_reject, chi2.pdf(x_reject, df=1),
                color='red', alpha=0.3, label='Rejection region')
ax.axvline(chi2, color='green', linewidth=3, 
           label=f'χ²={chi2:.2f}\np={p_value:.4f}')
ax.set_xlabel('Chi-square statistic')
ax.set_ylabel('Density')
ax.set_title('Chi-square Distribution')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('data/ab_test_simulation.png')
plt.close()
print("Saved visualization to data/ab_test_simulation.png")

print("\n" + "="*60)
print("SIMULATION COMPLETE")
print("="*60)
```
</details>

---

## W12: Statistical Modeling Exercises

### Exercise W12.1: Linear Regression

**Objective:** Build and interpret linear regression models.

```python
"""
Fit and interpret linear regression models using StatsModels.
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.formula.api import ols

# Create data
np.random.seed(42)
n = 200

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'category': np.random.choice(['A', 'B', 'C'], n)
})

# Create target with relationships
df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + 
          np.random.normal(0, 0.5, n) + 10)

# 1. Fit simple linear regression
# 2. Fit multiple linear regression
# 3. Interpret coefficients
# 4. Check model assumptions

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt

np.random.seed(42)
n = 200

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'category': np.random.choice(['A', 'B', 'C'], n)
})

df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + 
          np.random.normal(0, 0.5, n) + 10)

print("="*60)
print("LINEAR REGRESSION")
print("="*60)

# 1. Simple linear regression
print("\n1. Simple Linear Regression:")
print("-"*40)

X = sm.add_constant(df[['x1']])
model = sm.OLS(df['y'], X).fit()
print(model.summary().tables[1])

print("\nInterpretation:")
print(f"  y = {model.params['const']:.2f} + {model.params['x1']:.2f}*x1")
print(f"  R² = {model.rsquared:.4f}")
print(f"  Adj R² = {model.rsquared_adj:.4f}")

# 2. Multiple linear regression
print("\n2. Multiple Linear Regression:")
print("-"*40)

X = sm.add_constant(df[['x1', 'x2', 'x3']])
model_multiple = sm.OLS(df['y'], X).fit()
print(model_multiple.summary().tables[1])

print("\nInterpretation:")
print(f"  y = {model_multiple.params['const']:.2f} + "
      f"{model_multiple.params['x1']:.2f}*x1 + "
      f"{model_multiple.params['x2']:.2f}*x2 + "
      f"{model_multiple.params['x3']:.2f}*x3")
print(f"  R² = {model_multiple.rsquared:.4f}")
print(f"  Adj R² = {model_multiple.rsquared_adj:.4f}")

# 3. Feature importance
print("\n3. Feature Importance:")
print("-"*40)

# Standardize predictors
X_scaled = (df[['x1', 'x2', 'x3']] - df[['x1', 'x2', 'x3']].mean()) / df[['x1', 'x2', 'x3']].std()
X_scaled = sm.add_constant(X_scaled)
model_scaled = sm.OLS(df['y'], X_scaled).fit()

importance = pd.DataFrame({
    'Feature': ['x1', 'x2', 'x3'],
    'Coefficient': model_scaled.params[['x1', 'x2', 'x3']].values,
    'Abs_Coefficient': np.abs(model_scaled.params[['x1', 'x2', 'x3']].values)
}).sort_values('Abs_Coefficient', ascending=False)

print(importance)

# 4. Model diagnostics
print("\n4. Model Diagnostics:")
print("-"*40)

residuals = model_multiple.resid
fitted = model_multiple.fittedvalues

# Test normality of residuals
from scipy.stats import shapiro
stat, p = shapiro(residuals)
print(f"Normality test (Shapiro-Wilk): p={p:.4f}")
if p > 0.05:
    print("  ✓ Residuals appear normal")
else:
    print("  ⚠️ Residuals may not be normal")

# Visualize residuals
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Residuals vs Fitted
axes[0, 0].scatter(fitted, residuals, alpha=0.5)
axes[0, 0].axhline(0, color='red', linestyle='--')
axes[0, 0].set_xlabel('Fitted Values')
axes[0, 0].set_ylabel('Residuals')
axes[0, 0].set_title('Residuals vs Fitted')
axes[0, 0].grid(True, alpha=0.3)

# Q-Q plot
from scipy.stats import probplot
probplot(residuals, dist="norm", plot=axes[0, 1])
axes[0, 1].set_title('Q-Q Plot')
axes[0, 1].grid(True, alpha=0.3)

# Histogram
axes[1, 0].hist(residuals, bins=20, edgecolor='black', alpha=0.7)
axes[1, 0].set_xlabel('Residuals')
axes[1, 0].set_ylabel('Frequency')
axes[1, 0].set_title('Residual Distribution')
axes[1, 0].grid(True, alpha=0.3)

# Scale-Location
axes[1, 1].scatter(fitted, np.sqrt(np.abs(residuals)), alpha=0.5)
axes[1, 1].set_xlabel('Fitted Values')
axes[1, 1].set_ylabel('√|Residuals|')
axes[1, 1].set_title('Scale-Location Plot')
axes[1, 1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('data/linear_regression_diagnostics.png')
plt.close()
print("Saved diagnostic plots to data/linear_regression_diagnostics.png")
```
</details>

---

### Exercise W12.2: Logistic Regression

**Objective:** Build and interpret logistic regression models.

```python
"""
Fit and interpret logistic regression models.
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.metrics import confusion_matrix, classification_report

# Create data
np.random.seed(42)
n = 500

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'category': np.random.choice(['A', 'B', 'C'], n)
})

# Create binary target
logit = 0.5 + 0.8*df['x1'] - 0.6*df['x2'] + 0.3*df['x3']
prob = 1 / (1 + np.exp(-logit))
df['y'] = np.random.binomial(1, prob)

# 1. Fit logistic regression
# 2. Interpret coefficients and odds ratios
# 3. Evaluate model performance
# 4. Make predictions

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.metrics import confusion_matrix, classification_report, roc_curve, auc
import matplotlib.pyplot as plt

np.random.seed(42)
n = 500

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'category': np.random.choice(['A', 'B', 'C'], n)
})

logit = 0.5 + 0.8*df['x1'] - 0.6*df['x2'] + 0.3*df['x3']
prob = 1 / (1 + np.exp(-logit))
df['y'] = np.random.binomial(1, prob)

print("="*60)
print("LOGISTIC REGRESSION")
print("="*60)

# 1. Fit model
print("\n1. Model Fitting:")
print("-"*40)

X = df[['x1', 'x2', 'x3']]
X = sm.add_constant(X)
y = df['y']

model = sm.Logit(y, X).fit(disp=0)
print(model.summary().tables[1])

# 2. Interpret coefficients
print("\n2. Interpretation (Odds Ratios):")
print("-"*40)

coefficients = model.params
odds_ratios = np.exp(coefficients)
conf_int = np.exp(model.conf_int())

for var in coefficients.index:
    if var != 'const':
        print(f"{var}:")
        print(f"  Coefficient: {coefficients[var]:.4f}")
        print(f"  Odds Ratio: {odds_ratios[var]:.4f}")
        print(f"  95% CI: [{conf_int.loc[var, 0]:.4f}, {conf_int.loc[var, 1]:.4f}]")
        
        if coefficients[var] > 0:
            print(f"  → {((odds_ratios[var]-1)*100):.1f}% increase in odds per unit")
        else:
            print(f"  → {((1-odds_ratios[var])*100):.1f}% decrease in odds per unit")

# 3. Model evaluation
print("\n3. Model Evaluation:")
print("-"*40)

# Predict probabilities
y_prob = model.predict(X)
y_pred = (y_prob > 0.5).astype(int)

# Confusion matrix
cm = confusion_matrix(y, y_pred)
print("Confusion Matrix:")
print(cm)

# Classification metrics
tn, fp, fn, tp = cm.ravel()
accuracy = (tp + tn) / (tp + tn + fp + fn)
precision = tp / (tp + fp) if (tp + fp) > 0 else 0
recall = tp / (tp + fn) if (tp + fn) > 0 else 0
f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0

print(f"\nAccuracy: {accuracy:.4f}")
print(f"Precision: {precision:.4f}")
print(f"Recall: {recall:.4f}")
print(f"F1-Score: {f1:.4f}")

# 4. ROC curve
print("\n4. ROC Analysis:")
print("-"*40)

fpr, tpr, _ = roc_curve(y, y_prob)
roc_auc = auc(fpr, tpr)
print(f"ROC AUC: {roc_auc:.4f}")

# Visualize
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# ROC curve
ax = axes[0]
ax.plot(fpr, tpr, 'b-', linewidth=2, label=f'ROC (AUC = {roc_auc:.3f})')
ax.plot([0, 1], [0, 1], 'r--', label='Random')
ax.set_xlabel('False Positive Rate')
ax.set_ylabel('True Positive Rate')
ax.set_title('ROC Curve')
ax.legend()
ax.grid(True, alpha=0.3)

# Confusion matrix heatmap
ax = axes[1]
im = ax.imshow(cm, cmap='Blues', aspect='auto')
ax.set_xticks([0, 1])
ax.set_yticks([0, 1])
ax.set_xticklabels(['Pred 0', 'Pred 1'])
ax.set_yticklabels(['True 0', 'True 1'])
plt.colorbar(im, ax=ax)
ax.set_title('Confusion Matrix')

for i in range(2):
    for j in range(2):
        ax.text(j, i, cm[i, j], ha='center', va='center', color='black')

plt.tight_layout()
plt.savefig('data/logistic_regression_evaluation.png')
plt.close()
print("Saved evaluation plots to data/logistic_regression_evaluation.png")
```
</details>

---

### Exercise W12.3: Model Diagnostics

**Objective:** Perform comprehensive model diagnostics.

```python
"""
Check regression model assumptions and diagnose issues.
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.stats.diagnostic import het_breuschpagan
from statsmodels.stats.outliers_influence import variance_inflation_factor

# Create data
np.random.seed(42)
n = 200

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'x4': np.random.normal(0, 1, n)  # Noise
})

# Create target
df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + 
          np.random.normal(0, 0.5, n))

# 1. Check multicollinearity (VIF)
# 2. Check heteroscedasticity (Breusch-Pagan)
# 3. Check influential points (Cook's distance)
# 4. Check normality of residuals

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.stats.diagnostic import het_breuschpagan
from statsmodels.stats.outliers_influence import variance_inflation_factor
from scipy.stats import shapiro
import matplotlib.pyplot as plt

np.random.seed(42)
n = 200

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'x4': np.random.normal(0, 1, n)
})

df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + 
          np.random.normal(0, 0.5, n))

# Fit model
X = sm.add_constant(df[['x1', 'x2', 'x3', 'x4']])
model = sm.OLS(df['y'], X).fit()

print("="*60)
print("MODEL DIAGNOSTICS")
print("="*60)

# 1. Multicollinearity (VIF)
print("\n1. Multicollinearity (VIF):")
print("-"*40)

X_vif = df[['x1', 'x2', 'x3', 'x4']]
vif_data = pd.DataFrame()
vif_data['Feature'] = X_vif.columns
vif_data['VIF'] = [variance_inflation_factor(X_vif.values, i) 
                   for i in range(X_vif.shape[1])]
print(vif_data)

high_vif = vif_data[vif_data['VIF'] > 5]
if len(high_vif) > 0:
    print("⚠️ Features with VIF > 5 may indicate multicollinearity:")
    for _, row in high_vif.iterrows():
        print(f"  {row['Feature']}: {row['VIF']:.2f}")
else:
    print("✓ No severe multicollinearity detected")

# 2. Heteroscedasticity
print("\n2. Heteroscedasticity (Breusch-Pagan):")
print("-"*40)

bp_stat, bp_p, _, _ = het_breuschpagan(model.resid, model.model.exog)
print(f"BP statistic: {bp_stat:.4f}")
print(f"p-value: {bp_p:.4f}")

if bp_p < 0.05:
    print("⚠️ Heteroscedasticity detected (p < 0.05)")
    print("   → Consider using robust standard errors")
else:
    print("✓ Homoscedasticity assumption seems valid")

# 3. Influential points
print("\n3. Influential Points (Cook's Distance):")
print("-"*40)

influence = model.get_influence()
cooks_d = influence.cooks_distance[0]
threshold = 4 / len(cooks_d)

influential = cooks_d > threshold
print(f"Number of influential points: {influential.sum()}")
print(f"Cook's D threshold: {threshold:.4f}")

if influential.sum() > 0:
    print("⚠️ Influential points detected - consider robust regression")
else:
    print("✓ No influential points detected")

# 4. Normality of residuals
print("\n4. Normality of Residuals:")
print("-"*40)

shapiro_stat, shapiro_p = shapiro(model.resid)
print(f"Shapiro-Wilk test: stat={shapiro_stat:.4f}, p={shapiro_p:.4f}")

if shapiro_p < 0.05:
    print("⚠️ Residuals are NOT normally distributed (p < 0.05)")
else:
    print("✓ Residuals appear normally distributed")

# Visualize diagnostics
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Residuals histogram
axes[0, 0].hist(model.resid, bins=20, edgecolor='black', alpha=0.7)
axes[0, 0].axvline(0, color='red', linestyle='--')
axes[0, 0].set_xlabel('Residuals')
axes[0, 0].set_ylabel('Frequency')
axes[0, 0].set_title('Residuals Distribution')
axes[0, 0].grid(True, alpha=0.3)

# Scale-Location
axes[0, 1].scatter(model.fittedvalues, np.sqrt(np.abs(model.resid)), alpha=0.5)
axes[0, 1].set_xlabel('Fitted Values')
axes[0, 1].set_ylabel('√|Residuals|')
axes[0, 1].set_title('Scale-Location Plot')
axes[0, 1].grid(True, alpha=0.3)

# Cook's Distance
axes[1, 0].bar(range(len(cooks_d)), cooks_d)
axes[1, 0].axhline(threshold, color='red', linestyle='--', label='Threshold')
axes[1, 0].set_xlabel('Observation')
axes[1, 0].set_ylabel("Cook's Distance")
axes[1, 0].set_title("Cook's Distance")
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

# Q-Q plot
from scipy.stats import probplot
probplot(model.resid, dist="norm", plot=axes[1, 1])
axes[1, 1].set_title('Q-Q Plot')
axes[1, 1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('data/model_diagnostics_comprehensive.png')
plt.close()
print("\nSaved diagnostic plots to data/model_diagnostics_comprehensive.png")

print("\n" + "="*60)
print("SUMMARY OF DIAGNOSTICS")
print("="*60)
print(f"""
VIF Issues: {'Yes' if len(high_vif) > 0 else 'No'}
Heteroscedasticity: {'Yes' if bp_p < 0.05 else 'No'}
Influential Points: {'Yes' if influential.sum() > 0 else 'No'}
Non-Normal Residuals: {'Yes' if shapiro_p < 0.05 else 'No'}
""")
```
</details>

---

### Exercise W12.4: Model Comparison

**Objective:** Compare different model specifications.

```python
"""
Compare models using AIC, BIC, and adjusted R².
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm

# Create data
np.random.seed(42)
n = 200

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'x4': np.random.normal(0, 1, n),
    'x5': np.random.normal(0, 1, n)
})

df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.3*df['x3'] + 
          np.random.normal(0, 0.5, n))

# 1. Define multiple model specifications
# 2. Fit each model
# 3. Compare using AIC, BIC, R²
# 4. Select best model

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt

np.random.seed(42)
n = 200

df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n),
    'x3': np.random.normal(0, 1, n),
    'x4': np.random.normal(0, 1, n),
    'x5': np.random.normal(0, 1, n)
})

df['y'] = (2*df['x1'] - 1.5*df['x2'] + 0.3*df['x3'] + 
          np.random.normal(0, 0.5, n))

print("="*60)
print("MODEL COMPARISON")
print("="*60)

# Define model specifications
models_spec = {
    'Model 1': ['x1'],
    'Model 2': ['x1', 'x2'],
    'Model 3': ['x1', 'x2', 'x3'],
    'Model 4': ['x1', 'x2', 'x3', 'x4'],
    'Model 5': ['x1', 'x2', 'x3', 'x4', 'x5']
}

# Fit models and collect metrics
results = []

print("Fitting models...")
for name, variables in models_spec.items():
    X = sm.add_constant(df[variables])
    model = sm.OLS(df['y'], X).fit()
    
    results.append({
        'Model': name,
        'R²': model.rsquared,
        'R²_adj': model.rsquared_adj,
        'AIC': model.aic,
        'BIC': model.bic,
        'F_stat': model.fvalue,
        'F_pval': model.f_pvalue,
        'N': model.nobs,
        'K': len(variables)
    })

# Display results
results_df = pd.DataFrame(results)
print("\nModel Comparison Results:")
print("-"*70)
print(results_df.round(4).to_string(index=False))

# Identify best models
best_adj_r2 = results_df.loc[results_df['R²_adj'].idxmax()]
best_aic = results_df.loc[results_df['AIC'].idxmin()]
best_bic = results_df.loc[results_df['BIC'].idxmin()]

print("\n" + "-"*40)
print("Best Models:")
print("-"*40)
print(f"Best R²_adj: {best_adj_r2['Model']} ({best_adj_r2['R²_adj']:.4f})")
print(f"Best AIC: {best_aic['Model']} ({best_aic['AIC']:.2f})")
print(f"Best BIC: {best_bic['Model']} ({best_bic['BIC']:.2f})")

# Visualize comparison
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# R² and AIC
ax = axes[0]
x = range(len(results_df))
width = 0.35

ax.bar([i - width/2 for i in x], results_df['R²'], width, label='R²', alpha=0.7)
ax.bar([i + width/2 for i in x], results_df['R²_adj'], width, label='R²_adj', alpha=0.7)
ax.set_xticks(x)
ax.set_xticklabels(results_df['Model'])
ax.set_ylabel('Value')
ax.set_title('R² and Adjusted R²')
ax.legend()
ax.grid(True, alpha=0.3)

# AIC and BIC
ax = axes[1]
ax.plot(x, results_df['AIC'], 'o-', label='AIC', linewidth=2, markersize=8)
ax.plot(x, results_df['BIC'], 's-', label='BIC', linewidth=2, markersize=8)
ax.set_xticks(x)
ax.set_xticklabels(results_df['Model'])
ax.set_ylabel('Value')
ax.set_title('AIC and BIC (lower is better)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('data/model_comparison.png')
plt.close()
print("\nSaved model comparison to data/model_comparison.png")

# Recommendation
print("\n" + "-"*40)
print("Recommendation:")
print("-"*40)

if best_aic['Model'] == best_bic['Model']:
    print(f"✅ AIC and BIC both select: {best_aic['Model']}")
else:
    print(f"⚠️ AIC selects: {best_aic['Model']}")
    print(f"⚠️ BIC selects: {best_bic['Model']}")
    print("  → BIC penalizes complexity more heavily")

print("\nModel Statistics:")
print(f"  Variables included: {len(best_adj_r2['K'])}")
print(f"  Adjusted R²: {best_adj_r2['R²_adj']:.4f}")
print(f"  AIC: {best_aic['AIC']:.2f}")
```
</details>

---

### Exercise W12.5: Feature Selection

**Objective:** Identify the most important features.

```python
"""
Use various methods for feature selection.
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.feature_selection import mutual_info_regression

# Create data
np.random.seed(42)
n = 300

df = pd.DataFrame({
    'feature1': np.random.normal(0, 1, n),
    'feature2': np.random.normal(0, 1, n),
    'feature3': np.random.normal(0, 1, n),
    'feature4': np.random.normal(0, 1, n),
    'feature5': np.random.normal(0, 1, n),
    'feature6': np.random.normal(0, 1, n),
    'feature7': np.random.normal(0, 1, n),
    'feature8': np.random.normal(0, 1, n)
})

df['target'] = (2*df['feature1'] - 1.5*df['feature3'] + 
               0.8*df['feature5'] + np.random.normal(0, 0.5, n))

# 1. Correlation with target
# 2. Mutual information
# 3. Forward selection (manual)
# 4. Feature importance from model

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.feature_selection import mutual_info_regression
import matplotlib.pyplot as plt

np.random.seed(42)
n = 300

df = pd.DataFrame({
    'feature1': np.random.normal(0, 1, n),
    'feature2': np.random.normal(0, 1, n),
    'feature3': np.random.normal(0, 1, n),
    'feature4': np.random.normal(0, 1, n),
    'feature5': np.random.normal(0, 1, n),
    'feature6': np.random.normal(0, 1, n),
    'feature7': np.random.normal(0, 1, n),
    'feature8': np.random.normal(0, 1, n)
})

df['target'] = (2*df['feature1'] - 1.5*df['feature3'] + 
               0.8*df['feature5'] + np.random.normal(0, 0.5, n))

features = [f'feature{i}' for i in range(1, 9)]

print("="*60)
print("FEATURE SELECTION")
print("="*60)

# 1. Correlation with target
print("\n1. Correlation with Target:")
print("-"*40)

correlations = {}
for feat in features:
    corr = df[feat].corr(df['target'])
    correlations[feat] = corr

corr_df = pd.DataFrame({
    'Feature': list(correlations.keys()),
    'Correlation': list(correlations.values())
}).sort_values('Correlation', ascending=False)

print(corr_df)

# 2. Mutual information
print("\n2. Mutual Information:")
print("-"*40)

mi_scores = mutual_info_regression(df[features], df['target'])
mi_df = pd.DataFrame({
    'Feature': features,
    'MI_Score': mi_scores
}).sort_values('MI_Score', ascending=False)

print(mi_df)

# 3. Forward selection
print("\n3. Forward Selection (by AIC):")
print("-"*40)

remaining = set(features)
selected = []
current_aic = float('inf')

for i in range(len(features)):
    best_aic = float('inf')
    best_feature = None
    
    for feature in remaining:
        current_features = selected + [feature]
        X = sm.add_constant(df[current_features])
        model = sm.OLS(df['target'], X).fit()
        
        if model.aic < best_aic:
            best_aic = model.aic
            best_feature = feature
    
    if best_aic < current_aic:
        selected.append(best_feature)
        remaining.remove(best_feature)
        current_aic = best_aic
        print(f"Step {i+1}: Added '{best_feature}' (AIC = {best_aic:.2f})")
    else:
        break

print(f"\nSelected features: {selected}")

# 4. Model-based importance
print("\n4. Model-Based Importance:")
print("-"*40)

X = sm.add_constant(df[features])
model = sm.OLS(df['target'], X).fit()

importance = model.tvalues[1:]  # Exclude constant
importance_df = pd.DataFrame({
    'Feature': features,
    't_statistic': importance.values
}).sort_values('t_statistic', ascending=False)

print(importance_df)

# Visualize
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Correlation
ax = axes[0, 0]
corr_df.plot(kind='barh', x='Feature', y='Correlation', ax=ax, legend=False)
ax.set_title('Correlation with Target')
ax.grid(True, alpha=0.3)

# Mutual information
ax = axes[0, 1]
mi_df.plot(kind='barh', x='Feature', y='MI_Score', ax=ax, legend=False)
ax.set_title('Mutual Information')
ax.grid(True, alpha=0.3)

# Feature importance
ax = axes[1, 0]
importance_df.plot(kind='barh', x='Feature', y='t_statistic', ax=ax, legend=False)
ax.set_title('Model-Based Importance (t-statistic)')
ax.grid(True, alpha=0.3)

# Comparison
ax = axes[1, 1]
ax.text(0.1, 0.9, 'Summary', transform=ax.transAxes, fontsize=14, fontweight='bold')
ax.text(0.1, 0.75, f'Selected features:', transform=ax.transAxes, fontweight='bold')
for i, feat in enumerate(selected):
    ax.text(0.1, 0.65 - i*0.1, f'  {i+1}. {feat}', transform=ax.transAxes)
ax.axis('off')

plt.tight_layout()
plt.savefig('data/feature_selection_comparison.png')
plt.close()
print("\nSaved feature selection comparison to data/feature_selection_comparison.png")

# Summary
print("\n" + "="*60)
print("SUMMARY")
print("="*60)

print("\nTop 3 features by each method:")
methods = {
    'Correlation': corr_df.head(3)['Feature'].tolist(),
    'Mutual Information': mi_df.head(3)['Feature'].tolist(),
    'Forward Selection': selected[:3]
}

for method, feats in methods.items():
    print(f"{method}: {', '.join(feats)}")

print("\nRecommended features: feature1, feature3, feature5")
```
</details>

---

## W13: ETL Pipeline Project

### Capstone: Complete ETL Pipeline

**Objective:** Build a complete ETL pipeline from scratch.

```python
"""
Build an end-to-end ETL pipeline for processing sales data.
"""

import pandas as pd
import polars as pl
import duckdb
import pandera as pa
from pandera.typing import Series
import numpy as np

# 1. Define schema
# 2. Implement extraction
# 3. Implement transformation
# 4. Implement validation
# 5. Implement loading
# 6. Orchestrate the pipeline

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import pandas as pd
import polars as pl
import duckdb
import pandera as pa
from pandera.typing import Series
import numpy as np
from datetime import datetime
import os

print("="*60)
print("COMPLETE ETL PIPELINE")
print("="*60)

# 1. Define schema
class SalesSchema(pa.SchemaModel):
    transaction_id: Series[str] = pa.Field(nullable=False)
    customer_id: Series[int] = pa.Field(gt=0, nullable=False)
    product_id: Series[int] = pa.Field(gt=0, nullable=False)
    quantity: Series[int] = pa.Field(ge=1, le=100, nullable=False)
    price: Series[float] = pa.Field(ge=0, le=10000, nullable=False)
    total_amount: Series[float] = pa.Field(ge=0, nullable=False)
    transaction_date: Series[pd.Timestamp] = pa.Field(nullable=False)
    region: Series[str] = pa.Field(isin=['North', 'South', 'East', 'West'], nullable=False)

    @pa.dataframe_check
    def validate_total(cls, df: pd.DataFrame) -> Series[bool]:
        return df['total_amount'] == df['quantity'] * df['price']

print("1. ✅ Schema defined")

# 2. Extraction function
def extract_data():
    """Extract data from CSV/Parquet files."""
    print("\n2. Extracting data...")
    
    # Generate sample data if no files exist
    if not os.path.exists('data/raw_sales.parquet'):
        print("   Generating sample data...")
        np.random.seed(42)
        n = 10000
        
        df = pd.DataFrame({
            'transaction_id': [f'T{datetime.now().strftime("%Y%m%d%H%M%S")}{i:06d}' 
                              for i in range(n)],
            'customer_id': np.random.randint(1, 1001, n),
            'product_id': np.random.randint(1, 101, n),
            'quantity': np.random.randint(1, 6, n),
            'price': np.random.uniform(10, 500, n),
            'total_amount': np.random.uniform(10, 2500, n),
            'transaction_date': pd.date_range('2025-01-01', periods=n),
            'region': np.random.choice(['North', 'South', 'East', 'West'], n)
        })
        
        # Some data quality issues
        df.loc[np.random.random(n) < 0.02, 'price'] = np.nan
        df.loc[np.random.random(n) < 0.01, 'total_amount'] = np.nan
        
        os.makedirs('data', exist_ok=True)
        df.to_parquet('data/raw_sales.parquet')
        print(f"   Generated {len(df):,} records")
    
    # Load using Polars (fast)
    df = pl.read_parquet('data/raw_sales.parquet')
    print(f"   Loaded {len(df):,} records")
    return df

# 3. Transformation function
def transform_data(df: pl.DataFrame):
    """Transform the data using Polars."""
    print("\n3. Transforming data...")
    
    # Clean and transform
    df_transformed = (df
        # Convert to proper types
        .with_columns([
            pl.col('price').cast(pl.Float64),
            pl.col('total_amount').cast(pl.Float64),
            pl.col('transaction_date').str.to_datetime("%Y-%m-%d %H:%M:%S")
        ])
        # Extract date components
        .with_columns([
            pl.col('transaction_date').dt.year().alias('year'),
            pl.col('transaction_date').dt.month().alias('month'),
            pl.col('transaction_date').dt.day().alias('day')
        ])
        # Calculate derived columns
        .with_columns([
            (pl.col('price') * pl.col('quantity')).alias('calculated_total')
        ])
        # Validate total
        .with_columns([
            pl.when(
                pl.col('total_amount').is_null() |
                (pl.col('total_amount') != pl.col('calculated_total'))
            )
            .then(pl.col('calculated_total'))
            .otherwise(pl.col('total_amount'))
            .alias('total_amount')
        ])
        # Handle missing values
        .with_columns([
            pl.col('price').fill_null(pl.col('price').mean()),
            pl.col('total_amount').fill_null(pl.col('total_amount').mean())
        ])
        # Add categories
        .with_columns([
            pl.when(pl.col('total_amount') > 1000)
             .then(pl.lit('High'))
             .when(pl.col('total_amount') > 500)
             .then(pl.lit('Medium'))
             .otherwise(pl.lit('Low'))
             .alias('value_category')
        ])
    )
    
    print(f"   Transformed {len(df_transformed):,} records")
    return df_transformed

# 4. Validation function
def validate_data(df: pd.DataFrame):
    """Validate the data using Pandera."""
    print("\n4. Validating data...")
    
    try:
        validated_df = SalesSchema.validate(df)
        print(f"   ✅ Validation passed for {len(validated_df):,} records")
        return validated_df
    except pa.errors.SchemaErrors as e:
        print(f"   ❌ Validation failed with {len(e.failure_cases)} errors")
        print("   Sample errors:")
        for _, row in e.failure_cases.head(3).iterrows():
            print(f"     - {row['column']}: {row['failure_cases']}")
        raise

# 5. Load function
def load_data(df: pd.DataFrame, output_path: str = 'data/processed_sales'):
    """Load the processed data."""
    print(f"\n5. Loading data to {output_path}...")
    
    # Save as partitioned Parquet
    if 'year' not in df.columns:
        df['year'] = df['transaction_date'].dt.year
        df['month'] = df['transaction_date'].dt.month
        df['day'] = df['transaction_date'].dt.day
    
    # Convert to Polars for better performance
    df_pl = pl.DataFrame(df)
    
    # Save with partitioning
    os.makedirs(output_path, exist_ok=True)
    
    df_pl.write_parquet(f"{output_path}/sales_data.parquet")
    print(f"   ✅ Loaded {len(df):,} records to {output_path}")
    
    # Also save summary statistics
    summary = df.groupby('region').agg({
        'total_amount': ['sum', 'mean', 'count']
    }).round(2)
    
    summary.to_csv(f"{output_path}/summary.csv")
    print(f"   ✅ Saved summary to {output_path}/summary.csv")
    
    return df

# 6. Complete ETL Pipeline
class ETLPipeline:
    def __init__(self):
        self.extracted_data = None
        self.transformed_data = None
        self.validated_data = None
    
    def run(self):
        """Run the complete ETL pipeline."""
        print("\n" + "="*60)
        print("RUNNING ETL PIPELINE")
        print("="*60)
        
        # Step 1: Extract
        self.extracted_data = extract_data()
        
        # Step 2: Transform
        self.transformed_data = transform_data(self.extracted_data)
        
        # Step 3: Validate
        self.validated_data = validate_data(self.transformed_data.to_pandas())
        
        # Step 4: Load
        load_data(self.validated_data)
        
        # Step 5: Report
        self.generate_report()
        
        return self.validated_data
    
    def generate_report(self):
        """Generate a pipeline report."""
        print("\n" + "="*60)
        print("PIPELINE REPORT")
        print("="*60)
        
        df = self.validated_data
        print(f"\nProcessed Data Summary:")
        print(f"  Total records: {len(df):,}")
        print(f"  Total columns: {len(df.columns)}")
        print(f"  Date range: {df['transaction_date'].min()} to {df['transaction_date'].max()}")
        print(f"  Total sales: ${df['total_amount'].sum():,.2f}")
        print(f"  Average order: ${df['total_amount'].mean():,.2f}")
        
        print(f"\nBy Region:")
        for region in df['region'].unique():
            region_data = df[df['region'] == region]
            print(f"  {region}:")
            print(f"    Sales: ${region_data['total_amount'].sum():,.2f}")
            print(f"    Orders: {len(region_data):,}")
            print(f"    Avg: ${region_data['total_amount'].mean():,.2f}")

# Run the pipeline
if __name__ == "__main__":
    pipeline = ETLPipeline()
    result = pipeline.run()
    print("\n" + "="*60)
    print("✅ ETL PIPELINE COMPLETE")
    print("="*60)
```
</details>

---

## W14: A/B Testing Capstone

### Capstone: Complete A/B Test Analysis

**Objective:** Design, run, and analyze a complete A/B test.

```python
"""
Complete A/B test from design to decision.
"""

import numpy as np
import pandas as pd
from scipy.stats import chi2_contingency
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize
import matplotlib.pyplot as plt

# 1. Power analysis
# 2. Generate experiment data
# 3. Statistical analysis
# 4. Logistic regression
# 5. Report and recommendations

# Your code here
```

<details>
<summary>Click for Solution</summary>

```python
import numpy as np
import pandas as pd
from scipy.stats import chi2_contingency
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize
import matplotlib.pyplot as plt
import statsmodels.api as sm

print("="*60)
print("COMPLETE A/B TEST ANALYSIS")
print("="*60)

# 1. Design phase
print("\n1. Design Phase:")
print("-"*40)

# Parameters
baseline_conversion = 0.10
expected_lift = 0.02
alpha = 0.05
power = 0.80

effect_size = proportion_effectsize(baseline_conversion, 
                                   baseline_conversion + expected_lift)

print(f"Baseline conversion: {baseline_conversion*100:.1f}%")
print(f"Expected lift: {expected_lift*100:.1f} percentage points")
print(f"Effect size: {effect_size:.4f}")

power_analysis = NormalIndPower()
n = power_analysis.solve_power(
    effect_size=effect_size,
    alpha=alpha,
    power=power,
    alternative='two-sided'
)
n = int(np.ceil(n))

print(f"Required sample size per group: {n}")

# 2. Data generation
print("\n2. Generating A/B Test Data:")
print("-"*40)

np.random.seed(42)

# Control group
control = np.random.binomial(1, baseline_conversion, n)
control_df = pd.DataFrame({
    'group': 'Control',
    'converted': control,
    'age': np.random.normal(40, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.5, 0.8, n),
    'tenure': np.random.exponential(24, n).clip(1, 120)
})

# Treatment group
treatment = np.random.binomial(1, baseline_conversion + expected_lift, n)
treatment_df = pd.DataFrame({
    'group': 'Treatment',
    'converted': treatment,
    'age': np.random.normal(41, 15, n).clip(18, 80),
    'income': np.random.lognormal(10.6, 0.8, n),
    'tenure': np.random.exponential(25, n).clip(1, 120)
})

df = pd.concat([control_df, treatment_df], ignore_index=True)

control_rate = df[df['group'] == 'Control']['converted'].mean()
treatment_rate = df[df['group'] == 'Treatment']['converted'].mean()

print(f"Control conversion: {control_rate*100:.2f}%")
print(f"Treatment conversion: {treatment_rate*100:.2f}%")
print(f"Observed lift: {(treatment_rate - control_rate)*100:.2f} percentage points")

# 3. Statistical analysis
print("\n3. Statistical Analysis:")
print("-"*40)

contingency = pd.crosstab(df['group'], df['converted'])
chi2, p_value, _, _ = chi2_contingency(contingency)

print(f"Chi-square: {chi2:.4f}")
print(f"p-value: {p_value:.4f}")

# 4. Logistic regression
print("\n4. Logistic Regression:")
print("-"*40)

X = pd.get_dummies(df[['group', 'age', 'income', 'tenure']], drop_first=True)
X = sm.add_constant(X)
y = df['converted']

logit_model = sm.Logit(y, X).fit(disp=0)
print(logit_model.summary().tables[1])

# Odds ratios
odds_ratios = np.exp(logit_model.params)
print("\nOdds Ratios:")
for var, or_val in odds_ratios.items():
    print(f"  {var}: {or_val:.4f}")

# 5. Decision
print("\n5. Decision:")
print("-"*40)

is_significant = p_value < 0.05
if is_significant and treatment_rate > control_rate:
    print("✅ IMPLEMENT TREATMENT")
    print(f"   Significant improvement: +{(treatment_rate-control_rate)*100:.2f} percentage points")
elif is_significant:
    print("⚠️ INVESTIGATE")
    print(f"   Significant decrease: {(treatment_rate-control_rate)*100:.2f} percentage points")
else:
    print("✗ NO SIGNIFICANT DIFFERENCE")
    print(f"   Observed lift: {(treatment_rate-control_rate)*100:.2f} percentage points")
    print("   → Consider running longer or increasing sample size")

# 6. Visualization
print("\n6. Creating visualization...")
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Conversion rates
ax = axes[0, 0]
rates = [control_rate, treatment_rate]
colors = ['blue', 'green'] if treatment_rate > control_rate else ['blue', 'red']
ax.bar(['Control', 'Treatment'], rates, color=colors, alpha=0.7, edgecolor='black')
ax.set_ylabel('Conversion Rate')
ax.set_title('Conversion Rates')
ax.set_ylim([0, max(rates) * 1.2])
ax.grid(True, alpha=0.3, axis='y')

# Confidence intervals
ax = axes[0, 1]
for name, group_data in [('Control', control), ('Treatment', treatment)]:
    mean = group_data.mean()
    se = np.sqrt(mean * (1 - mean) / len(group_data))
    ci_lower = mean - 1.96 * se
    ci_upper = mean + 1.96 * se
    ax.errorbar(name, mean, yerr=[[mean - ci_lower], [ci_upper - mean]], 
               fmt='o', capsize=5, capthick=2, markersize=10)
ax.set_ylabel('Conversion Rate')
ax.set_title('95% Confidence Intervals')
ax.grid(True, alpha=0.3)

# Chi-square distribution
ax = axes[1, 0]
x = np.linspace(0, 15, 1000)
y = chi2.pdf(x, df=1)
ax.plot(x, y, 'b-', linewidth=2)
x_critical = chi2.ppf(0.95, df=1)
x_reject = x[x > x_critical]
ax.fill_between(x_reject, chi2.pdf(x_reject, df=1),
                color='red', alpha=0.3)
ax.axvline(chi2, color='green', linewidth=3, 
           label=f'χ²={chi2:.2f}\np={p_value:.4f}')
ax.set_xlabel('Chi-square statistic')
ax.set_ylabel('Density')
ax.set_title('Chi-square Distribution')
ax.legend()
ax.grid(True, alpha=0.3)

# Feature importance
ax = axes[1, 1]
coefs = logit_model.params[1:]
ax.barh(coefs.index, coefs.values)
ax.set_xlabel('Coefficient')
ax.set_title('Feature Importance (Logistic Regression)')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('data/ab_test_complete_analysis.png')
plt.close()
print("Saved analysis to data/ab_test_complete_analysis.png")

print("\n" + "="*60)
print("✅ A/B TEST ANALYSIS COMPLETE")
print("="*60)
```
</details>

---

## Workbook Completion Checklist

### Phase 1: Data Processing
- [ ] W1: Python Fundamentals (5 exercises)
- [ ] W2: SQL Fundamentals (5 exercises)
- [ ] W3: NumPy & Vectorization (5 exercises)
- [ ] W4: Pandas Data Manipulation (5 exercises)
- [ ] W5: Polars & Modern DataFrames (5 exercises)
- [ ] W6: DuckDB & Analytical SQL (5 exercises)
- [ ] W7: Data Quality & Validation (5 exercises)

### Phase 2: EDA & Visualization
- [ ] W8: EDA & Data Profiling (5 exercises)
- [ ] W9: Static Visualizations (5 exercises)
- [ ] W10: Interactive Visualizations (5 exercises)

### Phase 3: Statistics & Modeling
- [ ] W11: Hypothesis Testing (5 exercises)
- [ ] W12: Statistical Modeling (5 exercises)

### Capstone Projects
- [ ] W13: ETL Pipeline Project
- [ ] W14: A/B Testing Capstone

---

## Congratulations!

You've completed the Student Workbook! This represents significant hands-on practice across all the major topics in the series. You now have:

✅ **70+ exercises** covering Python, SQL, data processing, visualization, and statistics  
✅ **2 complete capstone projects** (ETL pipeline and A/B testing)  
✅ **Real-world skills** you can apply immediately  
✅ **Confidence** to tackle data science challenges

---

**[STUDENT WORKBOOK COMPLETE]**  
