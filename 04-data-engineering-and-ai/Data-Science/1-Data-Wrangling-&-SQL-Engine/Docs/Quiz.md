# TEST BANK: Comprehensive Assessments with Answer Keys

## Complete Evaluation System for the Data Engineering & Data Science Series

---

## Introduction

This Test Bank provides comprehensive assessments for each major topic in the series. Each test includes multiple-choice questions, coding exercises, and short-answer questions, with complete answer keys and explanations.

**How to Use This Test Bank:**

1. **Self-Assessment:** Test your understanding after each module
2. **Review:** Use answer explanations to reinforce learning
3. **Practice:** Simulate exam conditions
4. **Teaching:** Use as assessments for students

**Test Structure:**
- **Part A:** Multiple Choice (10 questions) - 20 points
- **Part B:** Short Answer (5 questions) - 25 points  
- **Part C:** Coding Exercises (3 questions) - 30 points
- **Part D:** Scenario-Based (1-2 questions) - 25 points
- **Total:** 100 points per test

**Scoring Guide:**
- 90-100: Excellent
- 80-89: Good
- 70-79: Satisfactory
- 60-69: Needs Review
- Below 60: Re-study material

---

## T1: Python Fundamentals Assessment

### Part A: Multiple Choice (20 points)

**Instructions:** Select the best answer for each question.

**1.** Which of the following is **NOT** a mutable data type in Python?  
A) List  
B) Dictionary  
C) Set  
D) Tuple  

**2.** What is the output of this code?
```python
x = [1, 2, 3]
y = x
y.append(4)
print(x)
```
A) `[1, 2, 3]`  
B) `[1, 2, 3, 4]`  
C) `[1, 2, 3] [4]`  
D) `[1, 2, 3, 4] [4]`  

**3.** Which of the following correctly creates a dictionary?  
A) `my_dict = {1, 2, 3}`  
B) `my_dict = {1: 'a', 2: 'b', 3: 'c'}`  
C) `my_dict = [1, 2, 3]`  
D) `my_dict = (1, 2, 3)`  

**4.** What does the following list comprehension produce?
```python
[x**2 for x in range(5) if x % 2 == 0]
```
A) `[0, 1, 4, 9, 16]`  
B) `[0, 4, 16]`  
C) `[0, 2, 4, 8, 16]`  
D) `[0, 1, 4]`  

**5.** Which of the following is the correct way to handle a `FileNotFoundError`?  
A) `if file_exists: open(file)`  
B) `try: open(file) except FileNotFoundError: print("Not found")`  
C) `open(file) or print("Not found")`  
D) `with open(file) except: print("Error")`  

**6.** What is the output of this code?
```python
def greet(name="World"):
    return f"Hello, {name}!"
print(greet())
print(greet("Alice"))
```
A) `Hello, !` `Hello, Alice`  
B) `Hello, World!` `Hello, Alice!`  
C) `World` `Alice`  
D) `Hello, NameError`  

**7.** Which method would you use to get a value from a dictionary with a default if the key doesn't exist?  
A) `dict[key]`  
B) `dict.get(key, default)`  
C) `dict.pop(key, default)`  
D) `dict.setdefault(key, default)`  

**8.** What is the output of this code?
```python
numbers = [1, 2, 3, 4, 5]
sliced = numbers[1:4]
print(sliced)
```
A) `[1, 2, 3]`  
B) `[2, 3, 4]`  
C) `[1, 2, 3, 4]`  
D) `[2, 3, 4, 5]`  

**9.** Which of the following is used to create a generator expression?  
A) `[x**2 for x in range(10)]`  
B) `(x**2 for x in range(10))`  
C) `{x**2 for x in range(10)}`  
D) `<x**2 for x in range(10)>`  

**10.** What is the output of this code?
```python
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n-1)
print(factorial(4))
```
A) `12`  
B) `24`  
C) `120`  
D) `6`  

---

### Part B: Short Answer (25 points)

**Instructions:** Write a brief answer for each question. (5 points each)

**11.** Explain the difference between a list and a tuple in Python. When would you use each?

**12.** What is the purpose of a virtual environment in Python development?

**13.** Explain the difference between `break`, `continue`, and `return` in Python.

**14.** What is a decorator in Python? Provide a simple example.

**15.** Explain the difference between shallow copy and deep copy.

---

### Part C: Coding Exercises (30 points)

**16.** (10 points) Write a function that takes a list of numbers and returns a new list containing only the numbers that are divisible by both 3 and 5.

```python
def divisible_by_3_and_5(numbers):
    # Your code here
    pass
```

**17.** (10 points) Write a function that reads a CSV file named `data.csv` with columns `name` and `value`, and returns a dictionary mapping each name to the sum of their values.

```python
import csv

def sum_values_by_name(filename):
    # Your code here
    pass
```

**18.** (10 points) Write a class `BankAccount` with methods `deposit()`, `withdraw()`, and `get_balance()`. Ensure that the balance cannot go negative.

```python
class BankAccount:
    def __init__(self, initial_balance=0):
        # Your code here
        pass
    
    def deposit(self, amount):
        # Your code here
        pass
    
    def withdraw(self, amount):
        # Your code here
        pass
    
    def get_balance(self):
        # Your code here
        pass
```

---

### Part D: Scenario-Based (25 points)

**19.** You are given a dataset of customer transactions:
```python
transactions = [
    {'customer': 'Alice', 'amount': 100, 'date': '2025-01-15'},
    {'customer': 'Bob', 'amount': 200, 'date': '2025-01-16'},
    {'customer': 'Alice', 'amount': 150, 'date': '2025-01-17'},
    {'customer': 'Carol', 'amount': 75, 'date': '2025-01-17'},
    {'customer': 'Bob', 'amount': 50, 'date': '2025-01-18'},
    {'customer': 'Alice', 'amount': 300, 'date': '2025-01-20'},
]
```

Write a function that:
1. Calculates total spending per customer
2. Finds the customer with the highest spending
3. Calculates the average transaction value
4. Returns a dictionary with all three metrics

```python
def analyze_transactions(transactions):
    # Your code here
    pass
```

---

## T1: Answer Key

### Part A: Multiple Choice

1. **D) Tuple** - Tuples are immutable, lists, dictionaries, and sets are mutable.

2. **B) `[1, 2, 3, 4]`** - `y = x` creates a reference, not a copy. Modifying `y` also modifies `x`.

3. **B) `{1: 'a', 2: 'b', 3: 'c'}`** - This uses the correct dictionary syntax (key: value pairs).

4. **B) `[0, 4, 16]`** - `range(5)` = 0,1,2,3,4. Filter even numbers (0,2,4). Square them.

5. **B) `try: open(file) except FileNotFoundError: print("Not found")`** - This is the correct error handling pattern.

6. **B) `Hello, World!` `Hello, Alice!`** - The default parameter is "World". 

7. **B) `dict.get(key, default)`** - `.get()` returns default if key doesn't exist.

8. **B) `[2, 3, 4]`** - Slicing includes start index, excludes end index.

9. **B) `(x**2 for x in range(10))`** - Parentheses create a generator expression.

10. **B) `24`** - 4! = 4 × 3 × 2 × 1 = 24.

---

### Part B: Short Answer

**11. Lists vs Tuples**
- **List:** Mutable, ordered sequence. Use when you need to modify data.
- **Tuple:** Immutable, ordered sequence. Use for fixed data, dictionary keys, or when performance matters.

**12. Virtual Environment Purpose**
- Isolates project dependencies
- Prevents version conflicts between projects
- Ensures reproducibility
- Keeps system Python clean

**13. break, continue, return**
- `break`: Exits loop entirely
- `continue`: Skips rest of current iteration, continues next
- `return`: Exits function, returns value

**14. Decorator**
A decorator is a function that modifies another function.

```python
def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        print(f"Time: {time.time() - start:.2f}s")
        return result
    return wrapper

@timer
def slow_function():
    time.sleep(1)
```

**15. Shallow vs Deep Copy**
- **Shallow Copy:** Copies only top-level structure. Nested objects are shared.
- **Deep Copy:** Copies all levels. Nested objects are fully duplicated.
- Use `copy.copy()` for shallow, `copy.deepcopy()` for deep.

---

### Part C: Coding Exercises

**16. Divisible by 3 and 5**

```python
def divisible_by_3_and_5(numbers):
    return [n for n in numbers if n % 3 == 0 and n % 5 == 0]
```

**17. Sum Values by Name**

```python
import csv

def sum_values_by_name(filename):
    sums = {}
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = row['name']
                value = float(row['value'])
                sums[name] = sums.get(name, 0) + value
        return sums
    except FileNotFoundError:
        return {}
```

**18. BankAccount Class**

```python
class BankAccount:
    def __init__(self, initial_balance=0):
        self._balance = max(0, initial_balance)
    
    def deposit(self, amount):
        if amount > 0:
            self._balance += amount
            return True
        return False
    
    def withdraw(self, amount):
        if 0 < amount <= self._balance:
            self._balance -= amount
            return True
        return False
    
    def get_balance(self):
        return self._balance
```

---

### Part D: Scenario-Based

**19. Transaction Analysis**

```python
def analyze_transactions(transactions):
    # Calculate total per customer
    totals = {}
    for t in transactions:
        customer = t['customer']
        amount = t['amount']
        totals[customer] = totals.get(customer, 0) + amount
    
    # Find highest spender
    highest_customer = max(totals, key=totals.get) if totals else None
    
    # Calculate average transaction value
    total_amount = sum(t['amount'] for t in transactions)
    avg_transaction = total_amount / len(transactions) if transactions else 0
    
    return {
        'totals': totals,
        'highest_spender': highest_customer,
        'highest_amount': totals.get(highest_customer, 0),
        'average_transaction': avg_transaction
    }
```

---

## T2: NumPy & Vectorization Assessment

### Part A: Multiple Choice (20 points)

**1.** What is the output of this code?
```python
import numpy as np
arr = np.array([1, 2, 3, 4, 5])
print(arr[1:4])
```
A) `[1, 2, 3]`  
B) `[2, 3, 4]`  
C) `[1, 2, 3, 4]`  
D) `[2, 3, 4, 5]`  

**2.** Which method creates a 3x3 identity matrix?  
A) `np.identity(3)`  
B) `np.eye(3)`  
C) `np.zeros((3,3))`  
D) Both A and B  

**3.** What is the shape of the result of broadcasting `(3, 4)` and `(4,)`?  
A) `(3, 4)`  
B) `(4, 4)`  
C) `(3, 3)`  
D) Error  

**4.** Which function creates an array with values from 0 to 10 with step 2?  
A) `np.arange(0, 10, 2)`  
B) `np.linspace(0, 10, 2)`  
C) `np.range(0, 10, 2)`  
D) `np.array(0, 10, 2)`  

**5.** What is the output of this code?
```python
import numpy as np
arr = np.array([[1, 2], [3, 4], [5, 6]])
print(arr.shape)
```
A) `(2, 3)`  
B) `(3, 2)`  
C) `(6,)`  
D) `(2, 2)`  

**6.** Which operation is vectorized in NumPy?  
A) `arr**2`  
B) `np.sqrt(arr)`  
C) `arr + 5`  
D) All of the above  

**7.** What is the output of this code?
```python
import numpy as np
arr = np.array([1, 2, 3, 4])
mask = arr > 2
print(arr[mask])
```
A) `[3, 4]`  
B) `[False, False, True, True]`  
C) `[1, 2, 3, 4]`  
D) Error  

**8.** Which NumPy function is used for matrix multiplication?  
A) `np.multiply()`  
B) `np.dot()`  
C) `np.matmul()`  
D) Both B and C  

**9.** What is the output of this code?
```python
import numpy as np
arr = np.random.randn(3, 4)
print(arr.ndim)
```
A) `3`  
B) `4`  
C) `2`  
D) `12`  

**10.** Which of the following is NOT a valid way to create a NumPy array?  
A) `np.array([1, 2, 3])`  
B) `np.zeros((2, 3))`  
C) `np.ones(shape=(2, 3))`  
D) `np.arange(1, 10, 2)`  

---

### Part B: Short Answer (25 points)

**11.** Explain broadcasting in NumPy and provide an example.

**12.** What is the difference between a view and a copy in NumPy?

**13.** Explain the relationship between Python loops and vectorization for performance.

**14.** What is the purpose of setting a random seed with `np.random.seed()`?

**15.** Explain the difference between `np.arange()` and `np.linspace()`.

---

### Part C: Coding Exercises (30 points)

**16.** (10 points) Create a NumPy array of shape (5, 5) with random values from a standard normal distribution. Then:
- Calculate the mean of each column
- Calculate the standard deviation of each row
- Find the maximum value in the array

```python
import numpy as np

# Your code here
```

**17.** (10 points) Using broadcasting, create a 4x4 array where each column contains the same value. For example:
```
[[1, 2, 3, 4],
 [1, 2, 3, 4],
 [1, 2, 3, 4],
 [1, 2, 3, 4]]
```

```python
import numpy as np

# Your code here
```

**18.** (10 points) Given a 1D array of values, use boolean indexing to:
- Replace all negative values with 0
- Create a new array with only positive values
- Calculate the number of values > 75th percentile

```python
import numpy as np

# Create sample data
np.random.seed(42)
data = np.random.randn(1000) * 10 + 50

# Your code here
```

---

### Part D: Scenario-Based (25 points)

**19.** You are analyzing sensor data from 1000 sensors, each taking 100 measurements over time.

```python
# Shape: (1000 sensors, 100 time points)
sensor_data = np.random.randn(1000, 100)
```

Write code that:
1. Calculates the mean value for each sensor (over time)
2. Calculates the standard deviation for each time point (across sensors)
3. Normalizes the entire dataset (subtract mean of each sensor, divide by std of each sensor)
4. Finds the sensor with the maximum mean value
5. Returns the indices of sensors with mean > 1.0

```python
import numpy as np

sensor_data = np.random.randn(1000, 100)

# Your code here
```

---

## T2: Answer Key

### Part A: Multiple Choice

1. **B) `[2, 3, 4]`** - Slicing `[1:4]` includes indices 1, 2, 3.

2. **D) Both A and B** - Both `np.identity(3)` and `np.eye(3)` create 3x3 identity matrices.

3. **A) `(3, 4)`** - The `(4,)` array broadcasts to `(1, 4)` then `(3, 4)`.

4. **A) `np.arange(0, 10, 2)`** - `arange` creates values with step.

5. **B) `(3, 2)`** - Shape is (rows, columns) = (3, 2).

6. **D) All of the above** - All are vectorized operations.

7. **A) `[3, 4]`** - Boolean indexing selects elements where mask is True.

8. **D) Both B and C** - Both `np.dot()` and `np.matmul()` perform matrix multiplication.

9. **C) `2`** - `ndim` returns number of dimensions: 2.

10. **C) `np.ones(shape=(2, 3))`** - Should be `np.ones((2, 3))`.

---

### Part B: Short Answer

**11. Broadcasting**
Broadcasting allows operations on arrays of different shapes by "stretching" smaller arrays to match larger ones.

Example:
```python
A = np.array([[1, 2, 3], [4, 5, 6]])
B = np.array([10, 20, 30])
# B broadcasts to shape (2, 3)
result = A + B  # [[11, 22, 33], [14, 25, 36]]
```

**12. View vs Copy**
- **View:** Shares data with original. Changes affect original. Created by slicing.
- **Copy:** Independent copy. Changes don't affect original. Created with `.copy()`.
- Use `.copy()` when you need to modify without affecting original.

**13. Python Loops vs Vectorization**
- Python loops operate element-by-element with interpreter overhead
- Vectorization uses compiled C code operating on entire arrays
- Vectorization is 100-1000x faster for numerical operations

**14. Random Seed Purpose**
- Ensures reproducibility of random numbers
- Same seed produces same sequence of random values
- Essential for debugging and comparison

**15. arange vs linspace**
- `arange(start, stop, step)`: Fixed step size. Stop exclusive.
- `linspace(start, stop, num)`: Fixed number of points. Both endpoints included.

---

### Part C: Coding Exercises

**16. Random Array Operations**

```python
import numpy as np

np.random.seed(42)
arr = np.random.randn(5, 5)

col_means = arr.mean(axis=0)
row_stds = arr.std(axis=1)
max_value = arr.max()

print("Column means:", col_means)
print("Row stds:", row_stds)
print("Max value:", max_value)
```

**17. Broadcasting Column Example**

```python
import numpy as np

# Create a 1x4 array and broadcast to 4x4
base = np.arange(1, 5)
result = np.tile(base, (4, 1))

# Alternative: Use broadcasting
result = np.ones((4, 1)) * base
```

**18. Boolean Indexing**

```python
import numpy as np

np.random.seed(42)
data = np.random.randn(1000) * 10 + 50

# Replace negatives with 0
data_positive = data.copy()
data_positive[data_positive < 0] = 0

# Create array with only positive values
positive_only = data[data > 0]

# Count values > 75th percentile
percentile_75 = np.percentile(data, 75)
above_75 = (data > percentile_75).sum()

print(f"Original mean: {data.mean():.2f}")
print(f"Positive count: {len(positive_only)}")
print(f"Values > 75th percentile: {above_75}")
```

---

### Part D: Scenario-Based

**19. Sensor Data Analysis**

```python
import numpy as np

sensor_data = np.random.randn(1000, 100)

# 1. Mean per sensor
sensor_means = sensor_data.mean(axis=1)

# 2. Std per time point
time_stds = sensor_data.std(axis=0)

# 3. Normalize
sensor_stds = sensor_data.std(axis=1)
normalized = (sensor_data - sensor_means.reshape(-1, 1)) / sensor_stds.reshape(-1, 1)

# 4. Sensor with max mean
max_sensor_idx = np.argmax(sensor_means)
max_sensor_mean = sensor_means[max_sensor_idx]

# 5. Sensors with mean > 1.0
high_mean_indices = np.where(sensor_means > 1.0)[0]

print(f"Shape - Original: {sensor_data.shape}")
print(f"Shape - Normalized: {normalized.shape}")
print(f"Sensor with max mean: {max_sensor_idx} (mean: {max_sensor_mean:.3f})")
print(f"Sensors with mean > 1.0: {len(high_mean_indices)}")
```

---

## T3: Pandas Data Manipulation Assessment

### Part A: Multiple Choice (20 points)

**1.** Which method displays summary statistics for a DataFrame?  
A) `df.info()`  
B) `df.summary()`  
C) `df.describe()`  
D) `df.stats()`  

**2.** What is the output of this code?
```python
import pandas as pd
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})
df.loc[0:1, 'A']
```
A) `[1, 2]`  
B) `[1]`  
C) `[1, 2, 3]`  
D) Error  

**3.** Which method would you use to select rows based on a condition?  
A) `df.select()`  
B) `df.loc[condition]`  
C) `df[condition]`  
D) Both B and C  

**4.** What is the output of this code?
```python
import pandas as pd
df = pd.DataFrame({'A': [1, 2, 1, 2], 'B': [10, 20, 30, 40]})
result = df.groupby('A')['B'].mean()
print(result)
```
A) `A 1: 20, A 2: 30`  
B) `[20, 30]`  
C) `(20, 30)`  
D) `{1: 20, 2: 30}`  

**5.** Which method is used to merge two DataFrames?  
A) `df.join()`  
B) `pd.merge()`  
C) `df.concat()`  
D) All of the above  

**6.** What is the output of this code?
```python
import pandas as pd
s = pd.Series([1, 2, 3, 4, 5])
print(s.iloc[2])
```
A) `1`  
B) `2`  
C) `3`  
D) `4`  

**7.** Which method creates a pivot table?  
A) `df.pivot_table()`  
B) `df.pivot()`  
C) `df.table()`  
D) `pd.pivot_table()`  

**8.** What is the output of this code?
```python
import pandas as pd
df = pd.DataFrame({'A': [1, 2, None, 4]})
print(df['A'].fillna(0))
```
A) `[1, 2, 0, 4]`  
B) `[1, 2, None, 4]`  
C) `[1, 2, 0, 0]`  
D) Error  

**9.** Which method creates a new column with the result of an expression?  
A) `df.assign()`  
B) `df.add_column()`  
C) `df.new_col()`  
D) `df.create_column()`  

**10.** What is the output of this code?
```python
import pandas as pd
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})
print(df.shape)
```
A) `(2, 3)`  
B) `(3, 2)`  
C) `(6,)`  
D) `(2, 2)`  

---

### Part B: Short Answer (25 points)

**11.** Explain the difference between `loc` and `iloc` in Pandas.

**12.** What is method chaining in Pandas and why is it useful?

**13.** Explain the difference between a view and a copy in Pandas.

**14.** What are the advantages of using `astype('category')` for categorical columns?

**15.** Explain the difference between `merge()`, `join()`, and `concat()`.

---

### Part C: Coding Exercises (30 points)

**16.** (10 points) Given a DataFrame with columns `name`, `age`, `city`, and `salary`, write code to:
- Filter to only people over 30
- Calculate the average salary by city
- Add a new column `income_category` (Low: < 50000, Medium: 50000-100000, High: > 100000)

```python
import pandas as pd
import numpy as np

np.random.seed(42)
df = pd.DataFrame({
    'name': [f'Person_{i}' for i in range(100)],
    'age': np.random.randint(18, 70, 100),
    'city': np.random.choice(['NYC', 'LA', 'Chicago', 'Boston'], 100),
    'salary': np.random.normal(70000, 30000, 100)
})

# Your code here
```

**17.** (10 points) Read a CSV file and perform data cleaning:
- Remove duplicates
- Fill missing values in numeric columns with median
- Remove rows where any column has more than 50% missing values
- Return the cleaned DataFrame

```python
import pandas as pd

def clean_data(filepath):
    # Your code here
    pass
```

**18.** (10 points) Write a function that takes two DataFrames and performs a merge, handling:
- Different column names for the join key
- Left join, inner join, and outer join options
- Handling of duplicate column names

```python
import pandas as pd

def flexible_merge(df1, df2, key1, key2, how='inner'):
    # Your code here
    pass
```

---

### Part D: Scenario-Based (25 points)

**19.** You are analyzing sales data with the following structure:
```python
sales_data = pd.DataFrame({
    'order_id': [1, 2, 3, 4, 5, 6],
    'customer_id': [101, 102, 101, 103, 102, 104],
    'order_date': pd.date_range('2025-01-01', periods=6),
    'amount': [100, 200, 150, 300, 250, 100],
    'category': ['A', 'B', 'A', 'C', 'B', 'A']
})

customers = pd.DataFrame({
    'customer_id': [101, 102, 103, 104, 105],
    'name': ['Alice', 'Bob', 'Carol', 'David', 'Eve'],
    'city': ['NYC', 'LA', 'Chicago', 'NYC', 'LA']
})
```

Write code that:
1. Merges sales_data with customers to show customer names
2. Calculates total sales per customer
3. Calculates average order value by category
4. Finds the top 2 customers by total sales
5. Creates a summary showing sales by city and category

---

## T3: Answer Key

### Part A: Multiple Choice

1. **C) `df.describe()`** - Shows summary statistics for numeric columns.

2. **A) `[1, 2]`** - `loc[0:1]` includes both index 0 and 1.

3. **D) Both B and C** - Both `df.loc[condition]` and `df[condition]` work.

4. **A) `A 1: 20, A 2: 30`** - Group by A, mean of B: (10+30)/2=20, (20+40)/2=30.

5. **D) All of the above** - All three can be used for combining DataFrames.

6. **C) `3`** - `iloc[2]` selects the 3rd element (index 2).

7. **A) `df.pivot_table()`** - Creates a pivot table with aggregation.

8. **A) `[1, 2, 0, 4]`** - `fillna(0)` replaces None with 0.

9. **A) `df.assign()`** - Creates new columns using expressions.

10. **B) `(3, 2)`** - Shape is (rows, columns) = (3, 2).

---

### Part B: Short Answer

**11. loc vs iloc**
- `loc`: Label-based indexing (uses row/column labels)
- `iloc`: Integer position-based indexing (uses 0-based positions)

**12. Method Chaining**
- Applying multiple operations in sequence without intermediate variables
- More readable, often more efficient
- Example: `df.query('age > 30').groupby('city').mean().sort_values()`

**13. View vs Copy**
- **View:** Reference to original data. Changes affect original. Created by slicing.
- **Copy:** Independent copy. Changes don't affect original. Created with `.copy()`.

**14. Category Type Advantages**
- Memory efficient (stores as integer codes)
- Faster for operations like groupby
- Enables categorical-specific operations
- Better for categorical data with finite categories

**15. Merge vs Join vs Concat**
- `merge()`: Combines based on column(s), SQL-like
- `join()`: Combines based on index
- `concat()`: Stack DataFrames (rows or columns)

---

### Part C: Coding Exercises

**16. Data Analysis Pipeline**

```python
import pandas as pd
import numpy as np

np.random.seed(42)
df = pd.DataFrame({
    'name': [f'Person_{i}' for i in range(100)],
    'age': np.random.randint(18, 70, 100),
    'city': np.random.choice(['NYC', 'LA', 'Chicago', 'Boston'], 100),
    'salary': np.random.normal(70000, 30000, 100)
})

# Filter
filtered = df[df['age'] > 30]

# Average salary by city
avg_salary = filtered.groupby('city')['salary'].mean()

# Add income category
def categorize_income(salary):
    if salary < 50000:
        return 'Low'
    elif salary <= 100000:
        return 'Medium'
    else:
        return 'High'

df['income_category'] = df['salary'].apply(categorize_income)

print("Average salary by city:")
print(avg_salary)
print("\nIncome category distribution:")
print(df['income_category'].value_counts())
```

**17. Data Cleaning Function**

```python
import pandas as pd

def clean_data(filepath):
    # Read data
    df = pd.read_csv(filepath)
    
    # Remove duplicates
    df = df.drop_duplicates()
    
    # Fill numeric columns with median
    numeric_cols = df.select_dtypes(include=['float64', 'int64']).columns
    for col in numeric_cols:
        df[col] = df[col].fillna(df[col].median())
    
    # Remove rows with >50% missing
    missing_pct = df.isna().mean(axis=1)
    df = df[missing_pct <= 0.5]
    
    return df
```

**18. Flexible Merge Function**

```python
import pandas as pd

def flexible_merge(df1, df2, key1, key2, how='inner'):
    # Rename the key column in df2 if different
    if key1 != key2:
        df2_renamed = df2.rename(columns={key2: key1})
    else:
        df2_renamed = df2
    
    # Perform merge
    result = pd.merge(df1, df2_renamed, on=key1, how=how)
    
    # Handle duplicate column names
    duplicate_cols = [col for col in result.columns 
                      if col.endswith('_x') or col.endswith('_y')]
    if duplicate_cols:
        # Keep only one version of duplicate columns
        for col in duplicate_cols:
            if col.endswith('_x'):
                base_name = col[:-2]
                result[base_name] = result[col]
    
    return result
```

---

### Part D: Scenario-Based

**19. Sales Analysis**

```python
import pandas as pd

sales_data = pd.DataFrame({
    'order_id': [1, 2, 3, 4, 5, 6],
    'customer_id': [101, 102, 101, 103, 102, 104],
    'order_date': pd.date_range('2025-01-01', periods=6),
    'amount': [100, 200, 150, 300, 250, 100],
    'category': ['A', 'B', 'A', 'C', 'B', 'A']
})

customers = pd.DataFrame({
    'customer_id': [101, 102, 103, 104, 105],
    'name': ['Alice', 'Bob', 'Carol', 'David', 'Eve'],
    'city': ['NYC', 'LA', 'Chicago', 'NYC', 'LA']
})

# 1. Merge with customer names
merged = pd.merge(sales_data, customers, on='customer_id')
print("1. Sales with customer names:")
print(merged[['order_id', 'name', 'amount', 'category']])

# 2. Total sales per customer
total_sales = merged.groupby('name')['amount'].sum().sort_values(ascending=False)
print("\n2. Total sales per customer:")
print(total_sales)

# 3. Average order value by category
avg_by_category = merged.groupby('category')['amount'].mean()
print("\n3. Average order value by category:")
print(avg_by_category)

# 4. Top 2 customers
top_customers = total_sales.head(2)
print("\n4. Top 2 customers:")
print(top_customers)

# 5. Sales by city and category
summary = merged.pivot_table(
    values='amount',
    index='city',
    columns='category',
    aggfunc='sum',
    fill_value=0
)
print("\n5. Sales by city and category:")
print(summary)
```

---

## T4: SQL Assessment

### Part A: Multiple Choice (20 points)

**1.** Which SQL clause is used to filter rows before grouping?  
A) `HAVING`  
B) `WHERE`  
C) `FILTER`  
D) `GROUP BY`  

**2.** What type of join returns all rows from the left table and matching rows from the right table?  
A) `INNER JOIN`  
B) `LEFT JOIN`  
C) `RIGHT JOIN`  
D) `FULL OUTER JOIN`  

**3.** Which aggregate function counts the number of rows?  
A) `COUNT(*)`  
B) `SUM(*)`  
C) `TOTAL(*)`  
D) `AVG(*)`  

**4.** What is the output of this query?
```sql
SELECT RANK() OVER (ORDER BY salary DESC) 
FROM employees;
```
A) Rank with no gaps  
B) Rank with gaps  
C) Row number  
D) Dense rank  

**5.** Which clause filters groups after aggregation?  
A) `WHERE`  
B) `HAVING`  
C) `GROUP BY`  
D) `FILTER`  

**6.** What does `UNION` do?  
A) Combines rows from two queries, removing duplicates  
B) Combines rows from two queries, keeping all  
C) Combines columns from two tables  
D) Joins two tables  

**7.** Which is a valid way to create a CTE?  
A) `WITH cte AS (SELECT ...)`  
B) `CREATE cte AS (SELECT ...)`  
C) `DEFINE cte AS (SELECT ...)`  
D) `VIEW cte AS (SELECT ...)`  

**8.** What does `LAG(column, 1)` do?  
A) Gets next row value  
B) Gets previous row value  
C) Gets first row value  
D) Gets last row value  

**9.** Which clause is used for sorting results?  
A) `SORT BY`  
B) `ORDER BY`  
C) `GROUP BY`  
D) `SORT`  

**10.** What is the purpose of `EXPLAIN ANALYZE`?  
A) Runs query faster  
B) Shows query execution plan  
C) Optimizes indexes automatically  
D) Creates an index  

---

### Part B: Short Answer (25 points)

**11.** Explain the difference between `WHERE` and `HAVING` clauses.

**12.** What is a window function and when would you use one?

**13.** Explain the difference between `UNION` and `UNION ALL`.

**14.** What is a Common Table Expression (CTE) and what are its benefits?

**15.** Explain the concept of database normalization and its benefits.

---

### Part C: Coding Exercises (30 points)

**16.** (10 points) Write a SQL query to find the top 5 customers by total order amount, including customer name and total amount.

```sql
-- Tables: customers(customer_id, name), orders(order_id, customer_id, amount)

-- Your query here
```

**17.** (10 points) Write a query to calculate a running total of sales by date.

```sql
-- Table: sales(sale_id, sale_date, amount)

-- Your query here
```

**18.** (10 points) Write a query to find the 3-month moving average of sales.

```sql
-- Table: daily_sales(sale_date, daily_total)

-- Your query here
```

---

### Part D: Scenario-Based (25 points)

**19.** Given the following schema:
```sql
customers: customer_id, first_name, last_name, email, signup_date
orders: order_id, customer_id, order_date, total_amount
order_items: order_item_id, order_id, product_id, quantity, price
products: product_id, product_name, category, price
```

Write SQL queries for:
1. Find customers who have never placed an order
2. Calculate customer lifetime value (total spending)
3. Find the top 3 products by revenue
4. Calculate month-over-month sales growth
5. Find customers who have ordered in the last 30 days

---

## T4: Answer Key

### Part A: Multiple Choice

1. **B) `WHERE`** - WHERE filters rows before grouping; HAVING filters after.

2. **B) `LEFT JOIN`** - Returns all left table rows plus matching right rows.

3. **A) `COUNT(*)`** - Counts all rows, including NULLs.

4. **B) Rank with gaps** - RANK() skips ranks after ties.

5. **B) `HAVING`** - Filters groups after aggregation.

6. **A) Combines rows, removing duplicates** - UNION removes duplicates.

7. **A) `WITH cte AS (SELECT ...)`** - CTE syntax.

8. **B) Gets previous row value** - LAG accesses previous row.

9. **B) `ORDER BY`** - Sorts query results.

10. **B) Shows query execution plan** - EXPLAIN ANALYZE shows plan with actual execution.

---

### Part B: Short Answer

**11. WHERE vs HAVING**
- `WHERE`: Filters rows before aggregation
- `HAVING`: Filters groups after aggregation
- WHERE is more efficient (reduces data before grouping)

**12. Window Functions**
- Perform calculations across rows related to current row
- Don't collapse rows like GROUP BY
- Used for ranking, running totals, moving averages
- Examples: ROW_NUMBER, RANK, LAG, LEAD, SUM() OVER()

**13. UNION vs UNION ALL**
- `UNION`: Combines results, removes duplicates (slower)
- `UNION ALL`: Combines results, keeps duplicates (faster)
- Use UNION ALL when duplicates are acceptable

**14. CTE**
- Temporary named result set within a query
- Improves readability for complex queries
- Can be recursive
- Enables breaking down complex queries

**15. Database Normalization**
- Organizing data to reduce redundancy
- Improves data integrity
- 3NF: No transitive dependencies
- Benefits: Less storage, fewer anomalies, simpler updates

---

### Part C: Coding Exercises

**16. Top 5 Customers**

```sql
SELECT 
    c.name,
    SUM(o.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 5;
```

**17. Running Total**

```sql
SELECT 
    sale_date,
    amount,
    SUM(amount) OVER (ORDER BY sale_date) AS running_total
FROM sales
ORDER BY sale_date;
```

**18. 3-Month Moving Average**

```sql
SELECT 
    sale_date,
    daily_total,
    AVG(daily_total) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3month
FROM daily_sales
ORDER BY sale_date;
```

---

### Part D: Scenario-Based

**19. Customer Analytics Queries**

```sql
-- 1. Customers with no orders
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 2. Customer lifetime value
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_value DESC;

-- 3. Top 3 products by revenue
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 3;

-- 4. Month-over-month sales growth
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    total_sales,
    LAG(total_sales, 1) OVER (ORDER BY month) AS previous_month,
    (total_sales - LAG(total_sales, 1) OVER (ORDER BY month)) / 
        LAG(total_sales, 1) OVER (ORDER BY month) * 100 AS growth_pct
FROM monthly_sales
ORDER BY month;

-- 5. Customers who ordered in last 30 days
SELECT DISTINCT c.*
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days';
```

---

## T5: Statistics & Hypothesis Testing Assessment

### Part A: Multiple Choice (20 points)

**1.** What does a p-value represent in hypothesis testing?  
A) Probability that the null hypothesis is true  
B) Probability of observing data as extreme as observed, assuming H₀ is true  
C) Probability of a Type II error  
D) Probability that the alternative hypothesis is true  

**2.** A Type I error occurs when:  
A) We fail to reject a false null hypothesis  
B) We reject a true null hypothesis  
C) We fail to reject a true null hypothesis  
D) We reject a false null hypothesis  

**3.** Which test would you use to compare two independent groups with normal data?  
A) Mann-Whitney U test  
B) Paired t-test  
C) Independent t-test  
D) Chi-square test  

**4.** What is the Central Limit Theorem?  
A) All distributions are normal  
B) Sample means approach normal distribution as sample size increases  
C) Population means are always normal  
D) Standard deviations are always equal  

**5.** Which effect size measure is used with t-tests?  
A) Pearson's r  
B) Cohen's d  
C) Cramér's V  
D) R²  

**6.** What does a confidence interval of 95% mean?  
A) 95% chance the true parameter is in the interval  
B) 95% of the data falls within the interval  
C) 95% of confidence intervals from repeated samples contain the true parameter  
D) 95% chance the interval contains the sample mean  

**7.** Which test is used for categorical data?  
A) t-test  
B) Chi-square test  
C) ANOVA  
D) Mann-Whitney U  

**8.** What is statistical power?  
A) 1 - α  
B) 1 - β  
C) α + β  
D) α / β  

**9.** Which of the following violates the assumptions of a parametric test?  
A) Normal distribution  
B) Homogeneity of variance  
C) Skewed distribution  
D) Independence  

**10.** What is the Bonferroni correction used for?  
A) Increasing statistical power  
B) Correcting for multiple testing  
C) Correcting for non-normal data  
D) Increasing sample size  

---

### Part B: Short Answer (25 points)

**11.** Explain the difference between Type I and Type II errors.

**12.** What is the relationship between sample size and standard error?

**13.** Explain the difference between parametric and non-parametric tests.

**14.** What is the purpose of power analysis in experimental design?

**15.** Explain the difference between correlation and causation.

---

### Part C: Coding Exercises (30 points)

**16.** (10 points) Perform a t-test to compare two groups and report the results including effect size.

```python
import numpy as np
from scipy import stats

np.random.seed(42)
group1 = np.random.normal(100, 15, 50)
group2 = np.random.normal(108, 15, 50)

# Your code here
```

**17.** (10 points) Calculate the required sample size for an A/B test with baseline conversion 0.10, expected lift 0.02, alpha=0.05, power=0.80.

```python
from statsmodels.stats.power import NormalIndPower

# Your code here
```

**18.** (10 points) Perform a Chi-square test of independence on a contingency table.

```python
import numpy as np
from scipy.stats import chi2_contingency

contingency = np.array([[45, 55], [60, 40]])

# Your code here
```

---

### Part D: Scenario-Based (25 points)

**19.** You are analyzing a marketing campaign's effectiveness. The campaign was shown to 500 users (treatment), while 500 users saw no campaign (control). The conversion rates were:

| Group | Converted | Not Converted |
|-------|-----------|---------------|
| Treatment | 65 | 435 |
| Control | 45 | 455 |

1. Calculate the conversion rates for both groups
2. Perform a Chi-square test to determine if the difference is statistically significant
3. Calculate the relative lift
4. Calculate Cohen's h effect size
5. Make a recommendation based on the results

---

## T5: Answer Key

### Part A: Multiple Choice

1. **B) Probability of observing data as extreme as observed, assuming H₀ is true** - Correct definition of p-value.

2. **B) We reject a true null hypothesis** - Type I error (false positive).

3. **C) Independent t-test** - Used for two independent groups with normal data.

4. **B) Sample means approach normal distribution as sample size increases** - Definition of CLT.

5. **B) Cohen's d** - Effect size measure for t-tests.

6. **C) 95% of confidence intervals from repeated samples contain the true parameter** - Correct interpretation.

7. **B) Chi-square test** - For categorical data.

8. **B) 1 - β** - Power = probability of rejecting false H₀.

9. **C) Skewed distribution** - Violates normality assumption.

10. **B) Correcting for multiple testing** - Adjusts alpha for multiple comparisons.

---

### Part B: Short Answer

**11. Type I vs Type II Errors**
- **Type I (α):** Rejecting true null hypothesis (False Positive)
- **Type II (β):** Failing to reject false null hypothesis (False Negative)
- α is set by researcher (usually 0.05)
- β determines power (1 - β)

**12. Sample Size and Standard Error**
- Standard Error = σ / √n
- Larger sample → smaller standard error
- Relationship is inverse square root
- To halve SE, need 4x sample size

**13. Parametric vs Non-Parametric Tests**
- **Parametric:** Assume normal distribution, use parameters (means, variances)
- **Non-parametric:** No distribution assumptions, use ranks
- Parametric is more powerful when assumptions met
- Non-parametric is more robust

**14. Power Analysis Purpose**
- Determines sample size needed to detect effect
- Ensures study has adequate sensitivity
- Balances Type I and Type II errors
- Prevents underpowered studies

**15. Correlation vs Causation**
- **Correlation:** Association between variables
- **Causation:** Direct cause-and-effect relationship
- Correlation doesn't imply causation
- Need randomized experiments for causation

---

### Part C: Coding Exercises

**16. T-test with Effect Size**

```python
import numpy as np
from scipy import stats

np.random.seed(42)
group1 = np.random.normal(100, 15, 50)
group2 = np.random.normal(108, 15, 50)

# Perform t-test
t_stat, p_value = stats.ttest_ind(group1, group2)

# Calculate Cohen's d
pooled_std = np.sqrt((np.std(group1, ddof=1)**2 + np.std(group2, ddof=1)**2) / 2)
cohens_d = (np.mean(group1) - np.mean(group2)) / pooled_std

print(f"Group 1 mean: {np.mean(group1):.2f}")
print(f"Group 2 mean: {np.mean(group2):.2f}")
print(f"t-statistic: {t_stat:.4f}")
print(f"p-value: {p_value:.4f}")
print(f"Cohen's d: {abs(cohens_d):.3f}")

if p_value < 0.05:
    print("✓ Significant difference")
else:
    print("✗ No significant difference")
```

**17. Sample Size Calculation**

```python
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize

power_analysis = NormalIndPower()
baseline = 0.10
expected_lift = 0.02

effect_size = proportion_effectsize(baseline, baseline + expected_lift)
n = power_analysis.solve_power(
    effect_size=effect_size,
    alpha=0.05,
    power=0.80,
    alternative='two-sided'
)

print(f"Baseline conversion: {baseline*100:.1f}%")
print(f"Expected lift: {expected_lift*100:.1f} percentage points")
print(f"Effect size: {effect_size:.4f}")
print(f"Required sample size per group: {int(np.ceil(n))}")
```

**18. Chi-square Test**

```python
import numpy as np
from scipy.stats import chi2_contingency

contingency = np.array([[45, 55], [60, 40]])

chi2, p_value, dof, expected = chi2_contingency(contingency)

print("Contingency Table:")
print(contingency)
print(f"\nExpected counts:")
print(expected.round(2))
print(f"\nChi-square: {chi2:.4f}")
print(f"p-value: {p_value:.4f}")
print(f"Degrees of freedom: {dof}")

if p_value < 0.05:
    print("✓ Significant association")
else:
    print("✗ No significant association")
```

---

### Part D: Scenario-Based

**19. Marketing Campaign Analysis**

```python
import numpy as np
from scipy.stats import chi2_contingency

# 1. Conversion rates
treatment_conversion = 65 / 500  # 0.13
control_conversion = 45 / 500    # 0.09

print(f"1. Conversion rates:")
print(f"  Treatment: {treatment_conversion*100:.2f}%")
print(f"  Control: {control_conversion*100:.2f}%")

# 2. Chi-square test
contingency = np.array([[65, 435], [45, 455]])
chi2, p_value, dof, expected = chi2_contingency(contingency)

print(f"\n2. Chi-square test:")
print(f"  Chi-square: {chi2:.4f}")
print(f"  p-value: {p_value:.4f}")
print(f"  Significant: {'Yes' if p_value < 0.05 else 'No'}")

# 3. Relative lift
relative_lift = (treatment_conversion - control_conversion) / control_conversion

print(f"\n3. Relative lift: {relative_lift*100:.2f}%")

# 4. Cohen's h effect size
from statsmodels.stats.proportion import proportion_effectsize
h = proportion_effectsize(treatment_conversion, control_conversion)

print(f"\n4. Cohen's h: {h:.4f}")

# 5. Recommendation
print(f"\n5. Recommendation:")
if p_value < 0.05 and treatment_conversion > control_conversion:
    print("  ✅ Implement the campaign: Significant improvement detected")
    print(f"     Lift: +{relative_lift*100:.1f}%")
elif p_value < 0.05:
    print("  ⚠️ Investigate: Significant decrease detected")
else:
    print("  ❌ No significant difference detected")
    print("     Consider running longer or increasing sample size")
```

---

## T6: Statistical Modeling Assessment

### Part A: Multiple Choice (20 points)

**1.** What does R² measure in a regression model?  
A) Correlation between variables  
B) Proportion of variance explained by the model  
C) Statistical significance  
D) Model complexity  

**2.** What is the interpretation of a coefficient in linear regression?  
A) Change in y for a 1-unit change in x  
B) Change in y for a 100-unit change in x  
C) Probability of y  
D) Correlation between x and y  

**3.** Which method is used to check for multicollinearity?  
A) Breusch-Pagan test  
B) Variance Inflation Factor (VIF)  
C) Shapiro-Wilk test  
D) Cook's distance  

**4.** What does an odds ratio of 2.0 mean in logistic regression?  
A) Twice the probability  
B) Twice the odds  
C) Twice the log-odds  
D) Twice the coefficient  

**5.** Which diagnostic test checks for heteroscedasticity?  
A) Shapiro-Wilk  
B) Breusch-Pagan  
C) VIF  
D) Durbin-Watson  

**6.** What is the purpose of regularization in regression?  
A) Increase R²  
B) Prevent overfitting  
C) Increase variance  
D) Remove outliers  

**7.** Which metric is minimized in ordinary least squares?  
A) Sum of absolute errors  
B) Sum of squared errors  
C) Mean absolute error  
D) Maximum error  

**8.** What does a residual plot showing a pattern indicate?  
A) Good model fit  
B) Violation of model assumptions  
C) Strong correlation  
D) Low variance  

**9.** In logistic regression, what transformation is applied to the probability?  
A) Square root  
B) Logit (log-odds)  
C) Exponential  
D) Reciprocal  

**10.** Which model selection criterion penalizes complexity?  
A) R²  
B) AIC  
C) Correlation  
D) All of the above  

---

### Part B: Short Answer (25 points)

**11.** Explain the difference between R² and adjusted R².

**12.** What are the key assumptions of linear regression?

**13.** Explain how to interpret coefficients in logistic regression.

**14.** What is the purpose of cross-validation in model evaluation?

**15.** Explain the difference between underfitting and overfitting.

---

### Part C: Coding Exercises (30 points)

**16.** (10 points) Fit a multiple linear regression model and interpret the coefficients.

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm

np.random.seed(42)
df = pd.DataFrame({
    'x1': np.random.normal(0, 1, 100),
    'x2': np.random.normal(0, 1, 100),
    'x3': np.random.normal(0, 1, 100)
})
df['y'] = 2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + np.random.normal(0, 0.5, 100)

# Your code here
```

**17.** (10 points) Fit a logistic regression model and calculate odds ratios.

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm

np.random.seed(42)
n = 200
df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n)
})
logit = -1 + 0.8*df['x1'] - 0.6*df['x2']
prob = 1 / (1 + np.exp(-logit))
df['y'] = np.random.binomial(1, prob)

# Your code here
```

**18.** (10 points) Perform model diagnostics on a fitted regression model.

```python
import statsmodels.api as sm
import numpy as np

np.random.seed(42)
X = np.random.randn(100, 3)
y = 2*X[:, 0] - 1.5*X[:, 1] + 0.5*X[:, 2] + np.random.randn(100) * 0.5

model = sm.OLS(y, sm.add_constant(X)).fit()

# Your code here - check residuals, VIF, influence
```

---

### Part D: Scenario-Based (25 points)

**19.** You are building a model to predict customer churn. Your dataset has:
- 10,000 customers
- Features: age, income, tenure_months, monthly_usage, support_tickets, satisfaction_score, plan_type
- Target: churned (0/1)

Describe how you would:
1. Split the data for modeling
2. Handle the categorical variable (plan_type)
3. Choose which features to include
4. Evaluate the model
5. Interpret the results for business stakeholders

---

## T6: Answer Key

### Part A: Multiple Choice

1. **B) Proportion of variance explained by the model** - R² = 1 - SS_res/SS_tot.

2. **A) Change in y for a 1-unit change in x** - Coefficient interpretation.

3. **B) Variance Inflation Factor (VIF)** - Checks multicollinearity.

4. **B) Twice the odds** - Odds ratio of 2.0 means odds are doubled.

5. **B) Breusch-Pagan** - Tests for heteroscedasticity.

6. **B) Prevent overfitting** - Regularization reduces overfitting.

7. **B) Sum of squared errors** - OLS minimizes SSE.

8. **B) Violation of model assumptions** - Patterns indicate issues.

9. **B) Logit (log-odds)** - Logit transformation: ln(p/(1-p)).

10. **B) AIC** - Penalizes complexity; lower AIC is better.

---

### Part B: Short Answer

**11. R² vs Adjusted R²**
- **R²:** Increases with more predictors, even if not useful
- **Adjusted R²:** Penalizes for number of predictors
- Adjusted R² = 1 - (1-R²)(n-1)/(n-k-1)

**12. Linear Regression Assumptions**
1. Linearity: Linear relationship between X and Y
2. Independence: Observations are independent
3. Homoscedasticity: Constant variance of residuals
4. Normality: Residuals are normally distributed
5. No multicollinearity: Predictors not highly correlated

**13. Logistic Regression Coefficients**
- **Coefficient:** Change in log-odds per unit change in x
- **Odds Ratio:** exp(coefficient)
- Odds ratio > 1: Positive effect
- Odds ratio < 1: Negative effect
- Interpret as multiplicative effect on odds

**14. Cross-Validation Purpose**
- Assesses model performance on unseen data
- Prevents overfitting
- Provides more reliable performance estimate
- Common: k-fold cross-validation (typically 5 or 10 folds)

**15. Underfitting vs Overfitting**
- **Underfitting:** Model too simple, high bias, poor training/test performance
- **Overfitting:** Model too complex, high variance, good training but poor test
- Goal: Balance bias and variance

---

### Part C: Coding Exercises

**16. Multiple Linear Regression**

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm

np.random.seed(42)
df = pd.DataFrame({
    'x1': np.random.normal(0, 1, 100),
    'x2': np.random.normal(0, 1, 100),
    'x3': np.random.normal(0, 1, 100)
})
df['y'] = 2*df['x1'] - 1.5*df['x2'] + 0.5*df['x3'] + np.random.normal(0, 0.5, 100)

X = sm.add_constant(df[['x1', 'x2', 'x3']])
model = sm.OLS(df['y'], X).fit()

print("Model Summary:")
print(model.summary().tables[1])

print("\nCoefficients:")
for var, coef, p_val in zip(X.columns, model.params, model.pvalues):
    print(f"  {var}: {coef:.4f} (p={p_val:.4f})")
```

**17. Logistic Regression**

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm

np.random.seed(42)
n = 200
df = pd.DataFrame({
    'x1': np.random.normal(0, 1, n),
    'x2': np.random.normal(0, 1, n)
})
logit = -1 + 0.8*df['x1'] - 0.6*df['x2']
prob = 1 / (1 + np.exp(-logit))
df['y'] = np.random.binomial(1, prob)

X = sm.add_constant(df[['x1', 'x2']])
model = sm.Logit(df['y'], X).fit(disp=0)

print("Logistic Regression Results:")
print(model.summary().tables[1])

print("\nOdds Ratios:")
for var, coef in model.params.items():
    or_val = np.exp(coef)
    print(f"  {var}: {or_val:.4f} (coef={coef:.4f})")
```

**18. Model Diagnostics**

```python
import statsmodels.api as sm
import numpy as np
from scipy.stats import shapiro
from statsmodels.stats.diagnostic import het_breuschpagan
from statsmodels.stats.outliers_influence import variance_inflation_factor

np.random.seed(42)
X = np.random.randn(100, 3)
y = 2*X[:, 0] - 1.5*X[:, 1] + 0.5*X[:, 2] + np.random.randn(100) * 0.5

model = sm.OLS(y, sm.add_constant(X)).fit()

print("1. Normality (Shapiro-Wilk):")
stat, p = shapiro(model.resid)
print(f"   p-value: {p:.4f}")
print(f"   {'Normal' if p > 0.05 else 'Not normal'}")

print("\n2. Heteroscedasticity (Breusch-Pagan):")
bp_stat, bp_p, _, _ = het_breuschpagan(model.resid, model.model.exog)
print(f"   p-value: {bp_p:.4f}")
print(f"   {'Homoscedastic' if bp_p > 0.05 else 'Heteroscedastic'}")

print("\n3. Multicollinearity (VIF):")
vif = [variance_inflation_factor(X, i) for i in range(X.shape[1])]
for i, v in enumerate(vif):
    print(f"   X{i}: {v:.4f}")

print("\n4. Influential Points:")
influence = model.get_influence()
cooks_d = influence.cooks_distance[0]
threshold = 4 / len(cooks_d)
influential = cooks_d > threshold
print(f"   Number of influential points: {influential.sum()}")
```

---

### Part D: Scenario-Based

**19. Churn Modeling Approach**

```python
print("1. Data Splitting:")
print("""
   - 70% Training: Model fitting
   - 15% Validation: Hyperparameter tuning
   - 15% Test: Final evaluation
   - Use stratified sampling (preserve churn ratio)
""")

print("\n2. Handling Categorical Variables:")
print("""
   - One-hot encoding for plan_type
   - Reference category approach (e.g., 'Basic' as baseline)
   - Or label encoding if ordinal
""")

print("\n3. Feature Selection:")
print("""
   - Include all features initially
   - Use backward elimination (remove non-significant)
   - Check VIF for multicollinearity
   - Consider domain knowledge
   - Recommended features:
     * tenure_months (negative relationship with churn)
     * support_tickets (positive relationship)
     * satisfaction_score (negative relationship)
     * monthly_usage (negative relationship)
""")

print("\n4. Model Evaluation:")
print("""
   Metrics:
   - Accuracy: Overall correct predictions
   - Precision: True positives / predicted positives
   - Recall: True positives / actual positives
   - F1-Score: Harmonic mean of precision and recall
   - ROC AUC: Ability to distinguish classes
   
   Also important:
   - Confusion matrix
   - Feature importance (coefficients)
   - Calibration (actual vs predicted probabilities)
""")

print("\n5. Business Interpretation:")
print("""
   - Present odds ratios (easier to understand)
   - Highlight key drivers: satisfaction, support tickets, tenure
   - Provide actionable insights:
     * "Each support ticket increases churn odds by X%"
     * "Increasing satisfaction from 3 to 4 reduces churn odds by Y%"
   - Recommend interventions based on findings
   - Use visualizations (coefficient plots, partial dependence plots)
""")
```

---

## Comprehensive Answer Key Summary

### Scoring Guide

| Score Range | Grade | Interpretation |
|-------------|-------|----------------|
| 90-100 | A | Excellent mastery |
| 80-89 | B | Good understanding |
| 70-79 | C | Satisfactory |
| 60-69 | D | Needs review |
| Below 60 | F | Re-study material |

### Test Summary

| Test | Topic | Total Points | Questions |
|------|-------|--------------|-----------|
| T1 | Python Fundamentals | 100 | 19 |
| T2 | NumPy & Vectorization | 100 | 19 |
| T3 | Pandas Data Manipulation | 100 | 19 |
| T4 | SQL | 100 | 19 |
| T5 | Statistics & Hypothesis Testing | 100 | 19 |
| T6 | Statistical Modeling | 100 | 19 |

---

**[TEST BANK COMPLETE]**  
