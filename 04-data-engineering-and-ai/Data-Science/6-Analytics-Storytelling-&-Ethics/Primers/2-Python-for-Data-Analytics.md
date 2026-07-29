# Primer 2: Python for Data Analytics

## Introduction to This Primer

### Why This Primer Exists

Python is the backbone of our analytics pipeline. While the series assumes basic Python knowledge, this primer ensures you're comfortable with the specific patterns we use for data analysis, database operations, and machine learning.

Think of this as your **"Python cookbook"** for the series - it contains the recipes we use most often, explained in a way that's practical and immediately useful.

### What This Primer Covers

1. **Python Environment Setup** - Virtual environments, packages
2. **Core Python for Data** - Lists, dictionaries, comprehensions
3. **Pandas Fundamentals** - DataFrames, Series, operations
4. **Database Operations** - SQLAlchemy patterns
5. **Data Visualization** - Matplotlib, seaborn basics
6. **Machine Learning Basics** - scikit-learn patterns
7. **Error Handling & Logging** - Production-ready code
8. **Best Practices** - Clean, maintainable code

### How to Use This Primer
- **As a reference:** Look up specific patterns when coding
- **As a tutorial:** Run the examples to learn by doing
- **As a style guide:** Follow the patterns in your own code

---

## Chapter 1: Python Environment Setup

### 1.1 Virtual Environments

**The Concept:** Virtual environments are isolated Python installations. Think of them as separate "workspaces" where you can install different packages without conflicts.

**Our Setup:**

```bash
# Create a virtual environment
python3 -m venv venv

# Activate it
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install packages
pip install pandas numpy sqlalchemy psycopg2-binary

# Save dependencies
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt
```

### 1.2 Project Structure

```
project/
├── src/                    # Source code
│   ├── __init__.py
│   ├── database/
│   │   ├── __init__.py
│   │   └── postgres.py
│   └── etl/
│       ├── __init__.py
│       └── extract.py
├── notebooks/              # Jupyter notebooks
│   └── analysis.ipynb
├── tests/                  # Unit tests
│   ├── __init__.py
│   └── test_database.py
├── scripts/                # Utility scripts
│   └── setup.py
├── requirements.txt        # Dependencies
├── .env                    # Environment variables
└── README.md              # Project documentation
```

---

## Chapter 2: Core Python for Data

### 2.1 Lists and List Comprehensions

**The Concept:** Lists are ordered collections. List comprehensions are a concise way to create lists.

**Our Examples:**

```python
# Basic list operations
customers = ['Alice', 'Bob', 'Charlie']

# Add to list
customers.append('Diana')  # ['Alice', 'Bob', 'Charlie', 'Diana']

# Access by index
first_customer = customers[0]  # 'Alice'
last_customer = customers[-1]  # 'Diana'

# Slice
first_two = customers[:2]  # ['Alice', 'Bob']

# List comprehension
numbers = [1, 2, 3, 4, 5]
squared = [x**2 for x in numbers]  # [1, 4, 9, 16, 25]

# Filter with list comprehension
even_numbers = [x for x in numbers if x % 2 == 0]  # [2, 4]

# Nested list comprehension
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flattened = [num for row in matrix for num in row]
# [1, 2, 3, 4, 5, 6, 7, 8, 9]

# Dictionary comprehension
customers = ['Alice', 'Bob', 'Charlie']
customer_dict = {i+1: name for i, name in enumerate(customers)}
# {1: 'Alice', 2: 'Bob', 3: 'Charlie'}
```

### 2.2 Dictionaries

**The Concept:** Dictionaries are key-value pairs. Like a real dictionary, you look up values by their keys.

**Our Examples:**

```python
# Creating dictionaries
customer = {
    'id': 1,
    'name': 'Alice Johnson',
    'email': 'alice@example.com',
    'orders': 5
}

# Accessing values
name = customer['name']  # 'Alice Johnson'
email = customer.get('email', 'No email')  # 'alice@example.com'
phone = customer.get('phone', 'No phone')  # 'No phone'

# Adding/updating values
customer['phone'] = '555-0101'
customer['orders'] += 1

# Iterating
for key, value in customer.items():
    print(f"{key}: {value}")

# Dictionary comprehension
customer_ids = [1, 2, 3, 4, 5]
customer_names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve']
customers = {id: name for id, name in zip(customer_ids, customer_names)}
# {1: 'Alice', 2: 'Bob', 3: 'Charlie', 4: 'Diana', 5: 'Eve'}
```

### 2.3 Functions and Type Hints

**The Concept:** Functions are reusable blocks of code. Type hints document what types of arguments and return values are expected.

**Our Examples:**

```python
from typing import List, Dict, Optional, Tuple, Union

# Basic function
def calculate_discount(price: float, discount_percent: float) -> float:
    """Calculate discounted price."""
    return price * (1 - discount_percent / 100)

# Function with default arguments
def format_customer(name: str, age: Optional[int] = None) -> str:
    """Format customer name with optional age."""
    if age:
        return f"{name} ({age} years old)"
    return name

# Function returning multiple values
def get_customer_stats(orders: List[float]) -> Tuple[int, float, float]:
    """Return count, total, and average of orders."""
    count = len(orders)
    total = sum(orders)
    avg = total / count if count > 0 else 0
    return count, total, avg

# Function with complex type
def process_data(data: List[Dict[str, Union[str, int, float]]]) -> Dict[str, List]:
    """Process a list of dictionaries into categorized data."""
    result = {'names': [], 'values': []}
    for item in data:
        result['names'].append(item.get('name', 'Unknown'))
        result['values'].append(item.get('value', 0))
    return result

# Function with variable arguments
def concatenate_strings(*args: str, separator: str = ' ') -> str:
    """Concatenate any number of strings with a separator."""
    return separator.join(args)

# Using the function
result = concatenate_strings('Hello', 'World', 'from', 'Python')
# 'Hello World from Python'
```

### 2.4 Error Handling

**The Concept:** Error handling prevents your program from crashing when something goes wrong.

**Our Examples:**

```python
import logging
from typing import Optional

# Basic try/except
try:
    result = 10 / 0
except ZeroDivisionError as e:
    print(f"Error: {e}")
    result = None

# Multiple exceptions
try:
    value = int(input("Enter a number: "))
    result = 100 / value
except ValueError as e:
    print(f"Invalid number: {e}")
except ZeroDivisionError as e:
    print(f"Cannot divide by zero: {e}")
except Exception as e:
    print(f"Unexpected error: {e}")
finally:
    print("This always runs")

# Custom exception
class DataValidationError(Exception):
    """Raised when data validation fails."""
    pass

def validate_customer_data(data: dict) -> bool:
    if not data.get('email'):
        raise DataValidationError("Email is required")
    if not data.get('name'):
        raise DataValidationError("Name is required")
    return True

# Using custom exception
try:
    customer = {'email': 'test@example.com'}
    validate_customer_data(customer)
except DataValidationError as e:
    logging.error(f"Validation failed: {e}")
```

---

## Chapter 3: Pandas Fundamentals

### 3.1 Creating DataFrames

**The Concept:** A DataFrame is a 2D table of data, like a spreadsheet. It's the most important data structure in pandas.

**Our Examples:**

```python
import pandas as pd
import numpy as np

# From dictionary
data = {
    'name': ['Alice', 'Bob', 'Charlie', 'Diana'],
    'age': [25, 30, 35, 28],
    'city': ['New York', 'Los Angeles', 'Chicago', 'Boston'],
    'salary': [50000, 60000, 55000, 45000]
}
df = pd.DataFrame(data)

# From list of dictionaries
data = [
    {'name': 'Alice', 'age': 25, 'city': 'New York'},
    {'name': 'Bob', 'age': 30, 'city': 'Los Angeles'},
]
df = pd.DataFrame(data)

# From CSV
df = pd.read_csv('data.csv')

# From Excel
df = pd.read_excel('data.xlsx')

# From SQL
from sqlalchemy import create_engine
engine = create_engine('postgresql://user:pass@localhost:5432/db')
df = pd.read_sql('SELECT * FROM customers', engine)

# From dict with index
data = {'A': [1, 2, 3], 'B': [4, 5, 6]}
df = pd.DataFrame(data, index=['row1', 'row2', 'row3'])

# Creating DataFrame with numpy
df = pd.DataFrame(np.random.randn(100, 5), columns=['A', 'B', 'C', 'D', 'E'])
```

### 3.2 Exploring DataFrames

**Our Examples:**

```python
# Basic info
df.head()           # First 5 rows
df.tail()           # Last 5 rows
df.info()           # Column types, non-null counts
df.describe()       # Statistical summary
df.shape            # (rows, columns)
df.columns          # Column names
df.index            # Row index

# Summary statistics
df['salary'].mean()      # Average
df['salary'].median()    # Median
df['salary'].min()       # Minimum
df['salary'].max()       # Maximum
df['salary'].std()       # Standard deviation
df['salary'].count()     # Non-null count
df['salary'].unique()    # Unique values

# Correlation
df.corr()           # Correlation matrix

# Value counts
df['city'].value_counts()  # Count of each city
df['city'].value_counts(normalize=True)  # Percentage distribution

# Checking for nulls
df.isnull().sum()   # Count of nulls per column
df.isnull().any()   # Which columns have nulls
df.isnull().sum().sum()  # Total nulls

# Unique values
df['city'].unique()  # All unique values
df['city'].nunique() # Number of unique values
```

### 3.3 Data Selection and Filtering

**Our Examples:**

```python
# Selecting columns
df['name']              # Single column (Series)
df[['name', 'age']]     # Multiple columns (DataFrame)

# Selecting rows by position
df.iloc[0]              # First row
df.iloc[0:3]            # First 3 rows
df.iloc[[0, 2, 4]]      # Specific rows
df.iloc[0:3, 0:2]       # First 3 rows, first 2 columns

# Selecting rows by label
df.loc[0]               # Row with label 0
df.loc[0:3]             # Rows 0-3 (inclusive)
df.loc[0:3, ['name', 'age']]  # Specific columns

# Boolean indexing (filtering)
df[df['age'] > 30]      # Rows where age > 30
df[(df['age'] > 25) & (df['city'] == 'New York')]  # Multiple conditions
df[df['city'].isin(['New York', 'Boston'])]  # IN operator

# Query method
df.query('age > 30 and city == "New York"')

# Using .loc with boolean indexing
df.loc[df['age'] > 30, 'name']  # Names of people over 30

# Filter then select
df_high_salary = df[df['salary'] > 50000]
df_high_salary[['name', 'salary']]
```

### 3.4 Data Cleaning and Transformation

**Our Examples:**

```python
# Handling nulls
df.fillna(0)                    # Fill with 0
df.fillna(df.mean())            # Fill with mean
df.dropna()                     # Drop rows with any null
df.dropna(subset=['email'])     # Drop rows where email is null

# Renaming columns
df.rename(columns={'name': 'full_name', 'age': 'customer_age'}, inplace=True)

# Creating new columns
df['salary_plus_bonus'] = df['salary'] * 1.1
df['age_group'] = pd.cut(df['age'], bins=[0, 25, 35, 45, 100])

# Applying functions
def calculate_tax(income):
    return income * 0.2

df['tax'] = df['salary'].apply(calculate_tax)

# Using lambda
df['tax'] = df['salary'].apply(lambda x: x * 0.2)

# Map values
city_to_state = {'New York': 'NY', 'Los Angeles': 'CA', 'Chicago': 'IL'}
df['state'] = df['city'].map(city_to_state)

# String operations
df['name_upper'] = df['name'].str.upper()
df['email_domain'] = df['email'].str.split('@').str[1]

# Data type conversion
df['age'] = df['age'].astype(float)
df['date'] = pd.to_datetime(df['date'])
df['categorical'] = df['categorical'].astype('category')

# Sorting
df.sort_values('salary', ascending=False)  # Descending
df.sort_values(['city', 'salary'], ascending=[True, False])  # Multiple columns
```

### 3.5 Grouping and Aggregation

**Our Examples:**

```python
# Basic groupby
df.groupby('city')['salary'].mean()  # Average salary by city
df.groupby('city')['salary'].agg(['mean', 'sum', 'count'])  # Multiple aggregates

# Groupby with multiple columns
df.groupby(['city', 'age_group'])['salary'].mean()

# Custom aggregation functions
def range_calc(series):
    return series.max() - series.min()

df.groupby('city')['salary'].agg(['mean', 'std', range_calc])

# Groupby with multiple metrics
df.groupby('city').agg({
    'salary': ['mean', 'sum', 'count'],
    'age': ['mean', 'min', 'max']
})

# Transform
df['salary_standardized'] = df.groupby('city')['salary'].transform(
    lambda x: (x - x.mean()) / x.std()
)

# Apply custom function to groups
def group_analysis(group):
    return pd.Series({
        'avg_salary': group['salary'].mean(),
        'avg_age': group['age'].mean(),
        'count': len(group)
    })

df.groupby('city').apply(group_analysis)

# Pivot tables
pivot = df.pivot_table(
    values='salary',
    index='city',
    columns='age_group',
    aggfunc='mean',
    fill_value=0
)
```

### 3.6 Merging and Joining

**Our Examples:**

```python
# Creating two DataFrames for examples
customers = pd.DataFrame({
    'customer_id': [1, 2, 3, 4],
    'name': ['Alice', 'Bob', 'Charlie', 'Diana']
})

orders = pd.DataFrame({
    'order_id': [101, 102, 103, 104, 105],
    'customer_id': [1, 1, 2, 3, 3],
    'amount': [100, 150, 200, 300, 250]
})

# Inner join (only matching records)
inner_join = pd.merge(customers, orders, on='customer_id', how='inner')

# Left join (all customers, even without orders)
left_join = pd.merge(customers, orders, on='customer_id', how='left')

# Right join (all orders, even without customer)
right_join = pd.merge(customers, orders, on='customer_id', how='right')

# Outer join (all records from both)
outer_join = pd.merge(customers, orders, on='customer_id', how='outer')

# Joining on different column names
addresses = pd.DataFrame({
    'cust_id': [1, 2, 3],
    'city': ['New York', 'LA', 'Chicago']
})
df = pd.merge(customers, addresses, left_on='customer_id', right_on='cust_id')

# Concatenation
df1 = pd.DataFrame({'A': [1, 2], 'B': [3, 4]})
df2 = pd.DataFrame({'A': [5, 6], 'B': [7, 8]})
concat_df = pd.concat([df1, df2])

# Combining with index
df1 = pd.DataFrame({'A': [1, 2]}, index=['x', 'y'])
df2 = pd.DataFrame({'B': [3, 4]}, index=['x', 'z'])
combined = pd.concat([df1, df2], axis=1)

# Append rows
df1 = pd.DataFrame({'A': [1, 2], 'B': [3, 4]})
new_row = pd.DataFrame({'A': [5], 'B': [6]})
df1 = pd.concat([df1, new_row], ignore_index=True)
```

### 3.7 Common Pandas Patterns

```python
# 1. Chaining operations
result = (df
    .query('age > 25')
    .groupby('city')
    ['salary']
    .mean()
    .sort_values(ascending=False)
    .head(5)
)

# 2. Creating a DataFrame from a list of dictionaries
data = []
for i in range(100):
    data.append({
        'id': i,
        'value': np.random.randn(),
        'category': np.random.choice(['A', 'B', 'C'])
    })
df = pd.DataFrame(data)

# 3. Splitting and applying
def categorize(amount):
    if amount < 100:
        return 'Low'
    elif amount < 500:
        return 'Medium'
    else:
        return 'High'

df['category'] = df['amount'].apply(categorize)

# 4. Time series operations
df['date'] = pd.date_range('2024-01-01', periods=100, freq='D')
df['month'] = df['date'].dt.month
df['quarter'] = df['date'].dt.quarter
df['day_of_week'] = df['date'].dt.dayofweek

# 5. Rolling statistics
df['rolling_mean'] = df['value'].rolling(window=7).mean()
df['rolling_std'] = df['value'].rolling(window=30).std()

# 6. Resampling time series
df.set_index('date', inplace=True)
monthly_data = df.resample('M').mean()
weekly_data = df.resample('W').sum()

# 7. Creating dummy variables
dummies = pd.get_dummies(df['category'], prefix='cat')
df = pd.concat([df, dummies], axis=1)
```

---

## Chapter 4: Database Operations

### 4.1 SQLAlchemy Connection Pattern

**The Concept:** SQLAlchemy is our bridge between Python and the database. It handles connection pooling, transaction management, and SQL generation.

**Our Examples:**

```python
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import os
from dotenv import load_dotenv
import pandas as pd
import logging

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_connection_string():
    """Build connection string from environment variables."""
    host = os.getenv('POSTGRES_HOST', 'localhost')
    port = os.getenv('POSTGRES_PORT', '5432')
    database = os.getenv('POSTGRES_DB', 'analytics')
    user = os.getenv('POSTGRES_USER', 'analytics_user')
    password = os.getenv('POSTGRES_PASSWORD')
    
    return f"postgresql://{user}:{password}@{host}:{port}/{database}"

def get_engine():
    """Create SQLAlchemy engine with connection pooling."""
    connection_string = get_connection_string()
    engine = create_engine(
        connection_string,
        pool_size=5,          # Number of connections in pool
        max_overflow=10,      # Additional connections allowed
        pool_timeout=30,      # Timeout for getting connection
        pool_recycle=3600,    # Recycle connections after 1 hour
        echo=False            # Set to True for SQL logging
    )
    return engine

# Using the engine with context manager
def execute_query(sql, params=None):
    """Execute a query and return results as DataFrame."""
    engine = get_engine()
    
    try:
        with engine.connect() as conn:
            if params:
                df = pd.read_sql(sql, conn, params=params)
            else:
                df = pd.read_sql(sql, conn)
            
            logger.info(f"Query returned {len(df)} rows")
            return df
            
    except SQLAlchemyError as e:
        logger.error(f"Database error: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise

# Transaction management
def execute_transaction(sql_operations):
    """Execute multiple SQL operations in a transaction."""
    engine = get_engine()
    
    with engine.begin() as conn:
        for sql, params in sql_operations:
            try:
                conn.execute(text(sql), params)
                logger.info(f"Executed: {sql[:50]}...")
            except SQLAlchemyError as e:
                logger.error(f"Transaction failed: {e}")
                raise

# Bulk insert
def bulk_insert(table_name, data):
    """Insert multiple rows efficiently."""
    engine = get_engine()
    
    with engine.connect() as conn:
        conn.execute(
            text(f"INSERT INTO {table_name} (column1, column2) VALUES (:col1, :col2)"),
            [{'col1': row['col1'], 'col2': row['col2']} for row in data]
        )

# Using the connection
def get_customer_data():
    """Example: Get customer data with joins."""
    query = """
    SELECT 
        c.customer_id,
        c.email,
        c.first_name,
        c.last_name,
        COUNT(o.order_id) AS order_count,
        SUM(o.total_amount) AS total_spent
    FROM analytics.customers c
    LEFT JOIN analytics.orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.email, c.first_name, c.last_name
    ORDER BY total_spent DESC
    LIMIT 10
    """
    
    return execute_query(query)
```

### 4.2 Context Managers for Database

**The Concept:** Context managers ensure resources are properly cleaned up, even when errors occur.

**Our Examples:**

```python
from contextlib import contextmanager
from sqlalchemy import create_engine, text

@contextmanager
def get_connection():
    """Context manager for database connections."""
    engine = get_engine()
    conn = None
    try:
        conn = engine.connect()
        logger.debug("Database connection established")
        yield conn
    except Exception as e:
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            conn.close()
            logger.debug("Database connection closed")

# Using the context manager
def count_customers():
    with get_connection() as conn:
        result = conn.execute(text("SELECT COUNT(*) FROM analytics.customers"))
        count = result.fetchone()[0]
        return count

# Transaction context manager
@contextmanager
def transaction():
    """Context manager for database transactions."""
    engine = get_engine()
    conn = None
    try:
        conn = engine.connect()
        trans = conn.begin()
        yield conn
        trans.commit()
        logger.debug("Transaction committed")
    except Exception as e:
        if conn:
            trans.rollback()
            logger.warning(f"Transaction rolled back: {e}")
        raise
    finally:
        if conn:
            conn.close()

# Using transaction context
def update_customer_bulk(updates):
    """Bulk update with transaction."""
    with transaction() as conn:
        for customer_id, new_balance in updates.items():
            conn.execute(
                text("UPDATE analytics.customers SET balance = :balance WHERE customer_id = :id"),
                {'balance': new_balance, 'id': customer_id}
            )
```

---

## Chapter 5: Data Visualization

### 5.1 Matplotlib Basics

**The Concept:** Matplotlib is the foundation of Python visualization. It gives you full control over every aspect of your plots.

**Our Examples:**

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Basic line plot
x = np.linspace(0, 10, 100)
y = np.sin(x)

plt.figure(figsize=(10, 6))
plt.plot(x, y, label='sin(x)', color='blue', linewidth=2)
plt.xlabel('X axis')
plt.ylabel('Y axis')
plt.title('Sine Wave')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

# Multiple plots on same figure
x = np.linspace(0, 10, 100)
y1 = np.sin(x)
y2 = np.cos(x)

plt.figure(figsize=(12, 6))
plt.plot(x, y1, label='sin(x)', color='blue', linestyle='-')
plt.plot(x, y2, label='cos(x)', color='red', linestyle='--')
plt.xlabel('X')
plt.ylabel('Y')
plt.title('Sine and Cosine')
plt.legend()
plt.grid(True)
plt.show()

# Subplots
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
axes[0, 0].plot(x, y1, 'b-')
axes[0, 0].set_title('Sine')
axes[0, 1].plot(x, y2, 'r-')
axes[0, 1].set_title('Cosine')
axes[1, 0].plot(x, y1 * y2, 'g-')
axes[1, 0].set_title('Product')
axes[1, 1].plot(x, np.abs(y1), 'm-')
axes[1, 1].set_title('Absolute')
plt.tight_layout()
plt.show()
```

### 5.2 Seaborn for Statistical Visualizations

**The Concept:** Seaborn builds on matplotlib to create beautiful statistical visualizations with less code.

**Our Examples:**

```python
import seaborn as sns
import pandas as pd
import numpy as np

# Set style
sns.set_style('whitegrid')
sns.set_palette('husl')

# Sample data
np.random.seed(42)
data = pd.DataFrame({
    'category': np.random.choice(['A', 'B', 'C', 'D'], size=100),
    'value': np.random.randn(100) * 10 + 50,
    'group': np.random.choice(['X', 'Y'], size=100)
})

# Bar plot
plt.figure(figsize=(10, 6))
sns.barplot(data=data, x='category', y='value', ci=95)
plt.title('Bar Plot with Error Bars')
plt.show()

# Box plot
plt.figure(figsize=(10, 6))
sns.boxplot(data=data, x='category', y='value', hue='group')
plt.title('Box Plot by Category and Group')
plt.show()

# Histogram
plt.figure(figsize=(10, 6))
sns.histplot(data=data, x='value', hue='category', kde=True)
plt.title('Distribution by Category')
plt.show()

# Scatter plot
plt.figure(figsize=(10, 6))
sns.scatterplot(data=data, x='value', y='value' + np.random.randn(100) * 5, 
                hue='category', size='group', alpha=0.7)
plt.title('Scatter Plot')
plt.show()

# Correlation heatmap
corr_matrix = data.corr()
plt.figure(figsize=(8, 6))
sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0)
plt.title('Correlation Heatmap')
plt.show()

# Pairplot (shows all relationships)
sns.pairplot(data, hue='category')
plt.show()
```

### 5.3 Visualization Best Practices

```python
# 1. Always use descriptive labels
plt.xlabel('Revenue ($)', fontsize=12)
plt.ylabel('Customer Count', fontsize=12)
plt.title('Revenue Distribution by Customer Tier', fontsize=14, fontweight='bold')

# 2. Add legends for clarity
plt.legend(loc='best', framealpha=0.9)

# 3. Use consistent colors
colors = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D']
for i, col in enumerate(colors):
    plt.plot(x, y[i], color=col, label=f'Series {i+1}')

# 4. Add annotations for key points
plt.annotate('Peak', xy=(x_peak, y_peak), xytext=(x_peak+1, y_peak+1),
             arrowprops=dict(arrowstyle='->', color='red'))

# 5. Save high-quality figures
plt.savefig('figure.png', dpi=300, bbox_inches='tight', facecolor='white')

# 6. Use appropriate figure size
plt.figure(figsize=(12, 8))  # For presentations
plt.figure(figsize=(8, 6))   # For reports

# 7. Style consistency
sns.set_style('whitegrid')
sns.set_context('paper', font_scale=1.5)
```

---

## Chapter 6: Machine Learning Basics

### 6.1 Train/Test Split Pattern

**The Concept:** Train/test split is how we evaluate model performance on unseen data.

**Our Examples:**

```python
from sklearn.model_selection import train_test_split
import numpy as np
import pandas as pd

# Basic split
X = np.random.randn(1000, 10)  # 1000 samples, 10 features
y = np.random.randint(0, 2, 1000)  # Binary labels

X_train, X_test, y_train, y_test = train_test_split(
    X, y, 
    test_size=0.2,          # 20% for testing
    random_state=42,        # Reproducible results
    stratify=y              # Balanced classes
)

# With pandas DataFrame
df = pd.DataFrame({
    'feature1': np.random.randn(100),
    'feature2': np.random.randn(100),
    'target': np.random.randint(0, 2, 100)
})

X = df[['feature1', 'feature2']]
y = df['target']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42
)

# Checking the split
print(f"Training samples: {len(X_train)}")
print(f"Test samples: {len(X_test)}")
print(f"Training target distribution: {np.bincount(y_train)}")
print(f"Test target distribution: {np.bincount(y_test)}")
```

### 6.2 Scikit-learn Pipeline Pattern

**The Concept:** Pipelines combine preprocessing and modeling into a single object.

**Our Examples:**

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.impute import SimpleImputer

# Numeric preprocessing
numeric_features = ['age', 'income', 'purchase_count']
numeric_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

# Categorical preprocessing
categorical_features = ['city', 'customer_tier']
categorical_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
    ('onehot', OneHotEncoder(handle_unknown='ignore'))
])

# Combine preprocessing
preprocessor = ColumnTransformer(
    transformers=[
        ('num', numeric_transformer, numeric_features),
        ('cat', categorical_transformer, categorical_features)
    ]
)

# Complete pipeline
model = Pipeline(steps=[
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
])

# Train
model.fit(X_train, y_train)

# Predict
y_pred = model.predict(X_test)
y_pred_proba = model.predict_proba(X_test)[:, 1]

# Get feature importance
feature_names = (numeric_features + 
                 model.named_steps['preprocessor']
                 .named_transformers_['cat']
                 .named_steps['onehot']
                 .get_feature_names_out(categorical_features).tolist())

importances = model.named_steps['classifier'].feature_importances_
```

### 6.3 Model Evaluation Pattern

**Our Examples:**

```python
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, classification_report, confusion_matrix
)

def evaluate_model(y_true, y_pred, y_pred_proba=None):
    """Comprehensive model evaluation."""
    metrics = {
        'accuracy': accuracy_score(y_true, y_pred),
        'precision': precision_score(y_true, y_pred),
        'recall': recall_score(y_true, y_pred),
        'f1_score': f1_score(y_true, y_pred)
    }
    
    if y_pred_proba is not None:
        metrics['roc_auc'] = roc_auc_score(y_true, y_pred_proba)
    
    print("=" * 60)
    print("Model Performance Metrics")
    print("=" * 60)
    for metric, value in metrics.items():
        print(f"{metric:15s}: {value:.4f}")
    
    print("\n" + "=" * 60)
    print("Classification Report")
    print("=" * 60)
    print(classification_report(y_true, y_pred))
    
    print("\n" + "=" * 60)
    print("Confusion Matrix")
    print("=" * 60)
    print(confusion_matrix(y_true, y_pred))
    
    return metrics

# Cross-validation
from sklearn.model_selection import cross_val_score, cross_val_predict

def cross_validate_model(model, X, y, cv=5):
    """Perform cross-validation."""
    scores = cross_val_score(model, X, y, cv=cv, scoring='accuracy')
    
    print(f"Cross-validation Accuracy: {scores.mean():.4f} (+/- {scores.std() * 2:.4f})")
    
    # Get predictions from all folds
    y_pred_cv = cross_val_predict(model, X, y, cv=cv)
    print(f"CV F1 Score: {f1_score(y, y_pred_cv):.4f}")
    
    return scores
```

---

## Chapter 7: Error Handling & Logging

### 7.1 Logging Configuration

**The Concept:** Logging captures what your code is doing, making debugging and monitoring much easier.

**Our Examples:**

```python
import logging
import sys
from pathlib import Path

def setup_logging(log_file='app.log', log_level=logging.INFO):
    """Configure logging for the application."""
    
    # Create logs directory if it doesn't exist
    log_path = Path(log_file)
    log_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Configure logging
    logging.basicConfig(
        level=log_level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(sys.stdout)
        ]
    )
    
    # Set up specific loggers
    logger = logging.getLogger(__name__)
    logger.info(f"Logging configured (level={logging.getLevelName(log_level)})")
    
    return logger

# Using the logger
logger = setup_logging('logs/app.log')

def process_data(data):
    """Example function with logging."""
    logger.info(f"Processing data with {len(data)} rows")
    
    try:
        result = data.mean()
        logger.debug(f"Mean value: {result}")
        return result
    except Exception as e:
        logger.error(f"Error processing data: {e}")
        raise

# Different log levels
logger.debug("Detailed debugging information")
logger.info("General information")
logger.warning("Warning message")
logger.error("Error occurred")
logger.critical("Critical failure")
```

### 7.2 Custom Exception Classes

**Our Examples:**

```python
class DataPipelineError(Exception):
    """Base exception for data pipeline errors."""
    pass

class DataExtractionError(DataPipelineError):
    """Raised when data extraction fails."""
    pass

class DataTransformationError(DataPipelineError):
    """Raised when data transformation fails."""
    pass

class DataValidationError(DataPipelineError):
    """Raised when data validation fails."""
    pass

class DataLoadError(DataPipelineError):
    """Raised when data loading fails."""
    pass

# Exception hierarchy
def extract_data(source):
    try:
        # Attempt to extract data
        if not source:
            raise DataExtractionError("No data source provided")
        # ... extraction logic
    except Exception as e:
        raise DataExtractionError(f"Extraction failed: {e}")

# Using custom exceptions
def validate_customer_data(df):
    required_columns = ['customer_id', 'email', 'registration_date']
    
    missing_cols = [col for col in required_columns if col not in df.columns]
    if missing_cols:
        raise DataValidationError(f"Missing required columns: {missing_cols}")
    
    if df['email'].isnull().any():
        raise DataValidationError("Email column contains null values")
    
    return True
```

---

## Chapter 8: Best Practices

### 8.1 Code Style Guide

```python
# ====================================================
# 1. Module Docstring
# ====================================================
"""
Module: customer_analytics.py
Purpose: Customer analytics functions for retention analysis.
Author: Analytics Team
Created: 2024-07-29
"""

# ====================================================
# 2. Imports (organized by type)
# ====================================================
# Standard library
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Union, Tuple

# Third-party
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

# Local
from src.database.postgres import get_client
from src.config import settings

# ====================================================
# 3. Constants (UPPER_CASE)
# ====================================================
DEFAULT_BATCH_SIZE = 1000
MAX_RETRIES = 3
TIMEOUT_SECONDS = 30

# ====================================================
# 4. Function Definitions
# ====================================================
def calculate_customer_lifetime_value(
    customer_id: str,
    order_history: pd.DataFrame,
    discount_rate: float = 0.08
) -> float:
    """
    Calculate customer lifetime value.

    Args:
        customer_id: The customer's unique identifier
        order_history: DataFrame with customer orders
        discount_rate: Discount rate for present value

    Returns:
        Customer lifetime value as float

    Raises:
        ValueError: If customer_id is empty or order_history is empty
    """
    # Always validate inputs first
    if not customer_id:
        raise ValueError("customer_id cannot be empty")
    
    if order_history.empty:
        raise ValueError("order_history cannot be empty")
    
    try:
        # Function logic here
        total_value = order_history['amount'].sum()
        clv = total_value * (1 / (1 + discount_rate))
        return clv
    except Exception as e:
        logging.error(f"Error calculating CLV for {customer_id}: {e}")
        raise

# ====================================================
# 5. Class Definitions
# ====================================================
class CustomerAnalytics:
    """
    Customer analytics engine.

    Attributes:
        client: Database client
        cache_enabled: Whether to use caching
    """

    def __init__(self, cache_enabled: bool = True):
        """Initialize the analytics engine."""
        self.client = get_client()
        self.cache_enabled = cache_enabled
        self.logger = logging.getLogger(__name__)

    def get_churn_risk(self, customer_id: str) -> Dict:
        """
        Get churn risk assessment for a customer.

        Args:
            customer_id: Customer identifier

        Returns:
            Dictionary with churn risk metrics
        """
        try:
            # Implementation
            return {'risk': 'low', 'score': 0.2}
        except Exception as e:
            self.logger.error(f"Error getting churn risk: {e}")
            raise
```

### 8.2 Code Checklist

```markdown
# Python Code Quality Checklist

## Before Writing Code
- [ ] Understand the problem fully
- [ ] Design the solution before coding
- [ ] Consider edge cases and error conditions
- [ ] Write tests first (if possible)

## While Writing Code
- [ ] Use meaningful variable and function names
- [ ] Add docstrings to functions and classes
- [ ] Include type hints for functions
- [ ] Handle exceptions appropriately
- [ ] Use logging for important events
- [ ] Keep functions small and focused
- [ ] Avoid code duplication (DRY principle)
- [ ] Use context managers for resources

## After Writing Code
- [ ] Run linters (flake8, pylint)
- [ ] Format code (black, isort)
- [ ] Write unit tests
- [ ] Run tests (pytest)
- [ ] Check test coverage
- [ ] Document any tricky sections
- [ ] Review for security issues

## Production Readiness
- [ ] Environment variables for configuration
- [ ] Proper error handling
- [ ] Comprehensive logging
- [ ] Performance optimization
- [ ] Security review
- [ ] Documentation complete
```

---

## Quick Reference Card

### Common Pandas Operations

| Operation | Code |
|-----------|------|
| Load CSV | `pd.read_csv('file.csv')` |
| Save CSV | `df.to_csv('file.csv', index=False)` |
| First rows | `df.head()` |
| Column types | `df.dtypes` |
| Filter | `df[df['col'] > 0]` |
| Group by | `df.groupby('col')['value'].mean()` |
| Merge | `pd.merge(df1, df2, on='key')` |
| Pivot | `df.pivot_table(values='value', index='row', columns='col')` |

### Common Matplotlib Commands

| Operation | Code |
|-----------|------|
| Line plot | `plt.plot(x, y)` |
| Scatter | `plt.scatter(x, y)` |
| Bar chart | `plt.bar(x, y)` |
| Histogram | `plt.hist(x)` |
| Box plot | `plt.boxplot(data)` |
| Labels | `plt.xlabel('X'), plt.ylabel('Y')` |
| Title | `plt.title('Title')` |
| Legend | `plt.legend()` |
| Show | `plt.show()` |
| Save | `plt.savefig('fig.png')` |

### Python Type Hints Quick Reference

| Type | Usage |
|------|-------|
| `str` | String values |
| `int` | Integer values |
| `float` | Float values |
| `bool` | Boolean values |
| `List[str]` | List of strings |
| `Dict[str, int]` | Dictionary with string keys, int values |
| `Optional[str]` | String or None |
| `Union[int, float]` | Integer or float |
| `Tuple[int, str]` | Tuple of int and str |
| `Callable` | Function type |

---

**[END OF PRIMER 2]**
