# Primer 3: Pandas Deep Dive

## Mastering pandas for Data Manipulation and Analysis

---

#### Purpose of This Primer

pandas is the workhorse of data analysis in Python. Throughout this series, you've used pandas extensively for data loading, manipulation, and analysis. This primer provides a comprehensive reference for pandas operations, covering both the fundamentals and advanced techniques you'll encounter.

---

## P3.1 Core Data Structures

### P3.1.1 Series

A Series is a one-dimensional labeled array capable of holding any data type.

```python
import pandas as pd
import numpy as np

# Creating Series
s = pd.Series([1, 2, 3, 4, 5])
s = pd.Series([1, 2, 3, 4, 5], index=['a', 'b', 'c', 'd', 'e'])
s = pd.Series({'a': 1, 'b': 2, 'c': 3})

# Series attributes
s.index          # Index labels
s.values         # Values as numpy array
s.dtype          # Data type
s.shape          # (n,)
s.size           # Number of elements
s.name           # Series name

# Accessing values
s['a']           # Access by label
s[0]             # Access by position
s.iloc[0]        # Position-based (0-based)
s.loc['a']       # Label-based
s[['a', 'c']]    # Multiple labels
s[0:3]           # Slicing

# Boolean indexing
s[s > 2]         # Values greater than 2
s[(s > 2) & (s < 5)]  # Between 2 and 5

# Operations
s + 10           # Element-wise addition
s * 2            # Element-wise multiplication
s.mean()         # Mean
s.sum()          # Sum
s.describe()     # Summary statistics
```

### P3.1.2 DataFrame

A DataFrame is a two-dimensional labeled data structure with columns of potentially different types.

```python
# Creating DataFrames
# From dictionary
df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35],
    'City': ['New York', 'Boston', 'Chicago']
})

# From list of dictionaries
df = pd.DataFrame([
    {'Name': 'Alice', 'Age': 25, 'City': 'New York'},
    {'Name': 'Bob', 'Age': 30, 'City': 'Boston'}
])

# From numpy array
df = pd.DataFrame(np.random.randn(5, 3),
                 columns=['A', 'B', 'C'],
                 index=pd.date_range('2024-01-01', periods=5))

# DataFrame attributes
df.shape          # (rows, columns)
df.columns        # Column names
df.index          # Row index
df.values         # Values as numpy array
df.dtypes         # Data types per column
df.info()         # Summary info
df.describe()     # Summary statistics
df.head()         # First 5 rows
df.tail()         # Last 5 rows

# Accessing columns
df['Name']        # Single column (Series)
df[['Name', 'Age']]  # Multiple columns (DataFrame)
df.Name           # Column access (if name is valid Python identifier)

# Accessing rows
df.iloc[0]        # Row by position
df.loc[0]         # Row by label (if index is label)
df.iloc[0:3]      # First 3 rows

# Accessing values
df.at[0, 'Name']  # Single value by label
df.iat[0, 0]      # Single value by position
```

---

## P3.2 Indexing and Selection

### P3.2.1 .loc vs .iloc vs .ix

```python
# .loc - Label-based indexing
df.loc[0]                    # Row with label 0
df.loc[0:2]                  # Rows 0-2 (inclusive)
df.loc[0, 'Name']            # Row 0, column 'Name'
df.loc[[0, 2], ['Name', 'Age']]  # Specific rows and columns
df.loc[df['Age'] > 30]       # Boolean indexing

# .iloc - Position-based indexing
df.iloc[0]                   # First row
df.iloc[0:3]                 # First 3 rows (0, 1, 2)
df.iloc[0, 0]                # First row, first column
df.iloc[:, 0:2]              # All rows, first 2 columns
df.iloc[[0, 2], [0, 2]]      # Specific rows and columns

# .at - Fast scalar access by label
df.at[0, 'Name']             # Fast label-based scalar

# .iat - Fast scalar access by position
df.iat[0, 0]                 # Fast position-based scalar
```

### P3.2.2 Boolean Indexing

```python
# Single condition
df[df['Age'] > 30]
df[df['Name'] == 'Alice']

# Multiple conditions
df[(df['Age'] > 25) & (df['City'] == 'New York')]
df[(df['Age'] < 25) | (df['Age'] > 35)]

# Using .isin()
df[df['City'].isin(['New York', 'Boston'])]

# Using .str methods
df[df['Name'].str.startswith('A')]
df[df['Name'].str.contains('li')]

# Using .query() (string-based)
df.query('Age > 30 and City == "New York"')
df.query('Age in [25, 30, 35]')
```

### P3.2.3 MultiIndex (Hierarchical Indexing)

```python
# Creating MultiIndex
arrays = [
    ['A', 'A', 'B', 'B', 'C', 'C'],
    [1, 2, 1, 2, 1, 2]
]
index = pd.MultiIndex.from_arrays(arrays, names=['Letter', 'Number'])
df = pd.DataFrame(np.random.randn(6, 3), index=index, columns=['X', 'Y', 'Z'])

# Accessing MultiIndex
df.loc['A']              # All rows with Letter='A'
df.loc[('A', 1)]         # Specific combination
df.loc['A'].loc[1]       # Alternative
df.loc[(slice(None), 1)]  # All rows with Number=1
df.xs(1, level='Number')  # Cross-section

# Group by MultiIndex level
df.groupby(level='Letter').mean()
df.groupby(level=0).sum()
```

---

## P3.3 Data Cleaning and Preprocessing

### P3.3.1 Handling Missing Data

```python
# Detecting missing values
df.isnull()          # Boolean DataFrame
df.isnull().sum()    # Count per column
df.isnull().sum().sum()  # Total count

# Dropping missing values
df.dropna()          # Drop any row with missing
df.dropna(axis=1)    # Drop any column with missing
df.dropna(how='all') # Drop rows where all are missing
df.dropna(thresh=3)  # Drop rows with less than 3 non-null values
df.dropna(subset=['Name', 'Age'])  # Drop if specific columns missing

# Filling missing values
df.fillna(0)         # Fill with 0
df.fillna(method='ffill')  # Forward fill
df.fillna(method='bfill')  # Backward fill
df.fillna(df.mean()) # Fill with column mean
df.fillna({'Age': df['Age'].median(), 'City': 'Unknown'})

# Interpolation
df.interpolate()     # Linear interpolation
df.interpolate(method='polynomial', order=2)

# Replace values
df.replace(0, np.nan)  # Replace 0 with NaN
df.replace({'A': 1, 'B': 2}, {'A': 10, 'B': 20})  # Dict mapping
```

### P3.3.2 Data Type Handling

```python
# Checking types
df.dtypes
df['col'].dtype
df.select_dtypes(include=['float64', 'int64'])
df.select_dtypes(include=['object'])

# Converting types
df['Age'] = df['Age'].astype('float64')
df['Date'] = pd.to_datetime(df['Date'])
df['Category'] = df['Category'].astype('category')
df['Numeric'] = pd.to_numeric(df['Numeric'], errors='coerce')

# Category data type (memory efficient)
df['City'] = df['City'].astype('category')
df['City'].cat.categories  # List categories
df['City'].cat.codes       # Integer codes

# Memory optimization
def optimize_memory(df):
    """Optimize DataFrame memory usage."""
    for col in df.columns:
        if df[col].dtype == 'object':
            if df[col].nunique() < len(df) * 0.5:
                df[col] = df[col].astype('category')
        elif 'int' in str(df[col].dtype):
            df[col] = pd.to_numeric(df[col], downcast='integer')
        elif 'float' in str(df[col].dtype):
            df[col] = pd.to_numeric(df[col], downcast='float')
    return df
```

### P3.3.3 Duplicate Handling

```python
# Detecting duplicates
df.duplicated()           # Boolean Series
df.duplicated().sum()     # Count duplicates
df.duplicated(subset=['Name', 'Age'])  # Check specific columns

# Removing duplicates
df.drop_duplicates()      # Drop all duplicates
df.drop_duplicates(keep='first')  # Keep first occurrence
df.drop_duplicates(keep='last')   # Keep last occurrence
df.drop_duplicates(keep=False)    # Drop all duplicates
df.drop_duplicates(subset=['Name'])  # Specific columns
```

---

## P3.4 Data Transformation

### P3.4.1 Apply, Map, and Applymap

```python
# apply() - Apply function to columns/rows
df['Age_Squared'] = df['Age'].apply(lambda x: x**2)
df.apply(lambda x: x.max() - x.min())  # Row range
df.apply(lambda x: x.sum(), axis=1)    # Row-wise sum

# applymap() - Element-wise function
df.applymap(lambda x: x.upper() if isinstance(x, str) else x)

# map() - Replace values
df['City_Code'] = df['City'].map({'New York': 'NY', 'Boston': 'BOS'})

# Replace with function
df['Name_Length'] = df['Name'].map(len)

# Using transform
df.groupby('City')['Age'].transform('mean')  # Group mean as new column
```

### P3.4.2 Pivot and Reshape

```python
# Pivot (wide format)
pivot_df = df.pivot(index='Date', columns='City', values='Sales')

# Pivot with aggregation (handles duplicates)
pivot_df = df.pivot_table(index='Date', columns='City', 
                          values='Sales', aggfunc='mean')

# Pivot with multiple aggregations
pivot_df = df.pivot_table(index='Date', columns='City',
                          values='Sales', aggfunc=['mean', 'sum'])

# Melt (long format)
melted = df.melt(id_vars=['Date'], var_name='City', value_name='Sales')

# Stack/Unstack (with MultiIndex)
stacked = df.stack()     # Pivot from wide to long
unstacked = df.unstack() # Pivot from long to wide
```

### P3.4.3 Merging and Joining

```python
# Merge (SQL-style joins)
merged = pd.merge(df1, df2, on='key')
merged = pd.merge(df1, df2, on='key', how='inner')
merged = pd.merge(df1, df2, on='key', how='left')
merged = pd.merge(df1, df2, on='key', how='right')
merged = pd.merge(df1, df2, on='key', how='outer')

# Merge on different columns
merged = pd.merge(df1, df2, left_on='key1', right_on='key2')

# Joining (on index)
joined = df1.join(df2, lsuffix='_left', rsuffix='_right')

# Concatenation
concatenated = pd.concat([df1, df2])           # Vertical
concatenated = pd.concat([df1, df2], axis=1)   # Horizontal
concatenated = pd.concat([df1, df2], keys=['A', 'B'])  # With keys
```

---

## P3.5 Group Operations

### P3.5.1 GroupBy Basics

```python
# Group by single column
grouped = df.groupby('City')
grouped.mean()        # Mean of numeric columns
grouped.sum()         # Sum of numeric columns
grouped.size()        # Count per group
grouped.count()       # Count non-null per group

# Group by multiple columns
grouped = df.groupby(['City', 'Gender'])
grouped.mean()

# Group by index level (MultiIndex)
grouped = df.groupby(level='Letter')
grouped.sum()

# Group by function
grouped = df.groupby(lambda x: x.year)  # If index is datetime

# Group by dictionary
mapping = {'A': 'group1', 'B': 'group2'}
grouped = df.groupby(mapping, axis=1)  # Group columns
```

### P3.5.2 Aggregation Functions

```python
# Single aggregation
df.groupby('City')['Age'].mean()
df.groupby('City')['Age'].agg('mean')
df.groupby('City')['Age'].agg(['mean', 'std'])

# Multiple aggregations
df.groupby('City')['Age'].agg(['mean', 'std', 'count'])

# Different aggregations for different columns
df.groupby('City').agg({
    'Age': ['mean', 'max'],
    'Salary': ['sum', 'mean'],
    'Name': 'count'
})

# Named aggregations (pandas 0.25+)
df.groupby('City').agg(
    avg_age=('Age', 'mean'),
    max_age=('Age', 'max'),
    total_salary=('Salary', 'sum')
)

# Custom aggregation functions
df.groupby('City')['Age'].agg(lambda x: x.max() - x.min())
```

### P3.5.3 Transform and Filter

```python
# Transform - Apply function and keep original shape
df['City_Age_Mean'] = df.groupby('City')['Age'].transform('mean')
df['City_Age_Rank'] = df.groupby('City')['Age'].transform('rank')

# Filter - Remove groups based on condition
df.groupby('City').filter(lambda x: len(x) > 10)  # Cities with >10 rows
df.groupby('City').filter(lambda x: x['Age'].mean() > 30)

# Apply - Arbitrary function on groups
df.groupby('City').apply(lambda x: x.sort_values('Age'))

# Pipe - Chain operations
df.groupby('City').pipe(lambda x: x.mean())
```

---

## P3.6 Time Series Operations

### P3.6.1 Date Range and Resampling

```python
# Creating date ranges
dates = pd.date_range('2024-01-01', '2024-12-31', freq='D')
dates = pd.date_range('2024-01-01', periods=365, freq='D')
dates = pd.date_range('2024-01-01', periods=24, freq='H')

# Common frequencies
# 'D' - Daily
# 'W' - Weekly
# 'M' - Month end
# 'MS' - Month start
# 'Q' - Quarter end
# 'H' - Hourly
# 'T' - Minutely
# 'S' - Secondly

# Resampling (downsampling)
df.resample('M', on='Date').mean()
df.resample('W', on='Date').agg(['mean', 'sum'])
df.resample('Q', on='Date').agg({
    'Sales': 'sum',
    'Customers': 'mean'
})

# Upsampling (interpolation)
df.resample('H', on='Date').interpolate()
df.resample('H', on='Date').ffill()

# Rolling windows
df['rolling_mean'] = df['Value'].rolling(window=7).mean()
df['rolling_std'] = df['Value'].rolling(window=7).std()
df['rolling_median'] = df['Value'].rolling(window=7).median()

# Expanding windows (all data up to current point)
df['expanding_mean'] = df['Value'].expanding().mean()
df['expanding_std'] = df['Value'].expanding().std()
```

### P3.6.2 Shift and Lag

```python
# Shift - Shift values
df['Value_lag1'] = df['Value'].shift(1)   # Previous row
df['Value_lag7'] = df['Value'].shift(7)   # 7 days ago
df['Value_lead'] = df['Value'].shift(-1)  # Next row

# Diff - Calculate differences
df['diff'] = df['Value'].diff()           # Difference from previous
df['diff7'] = df['Value'].diff(7)         # 7-day difference

# Pct change - Percentage change
df['pct_change'] = df['Value'].pct_change()  # Percentage from previous
df['pct_change7'] = df['Value'].pct_change(7)
```

### P3.6.3 DateTime Accessors

```python
# Extract components from datetime
df['Year'] = df['Date'].dt.year
df['Month'] = df['Date'].dt.month
df['Day'] = df['Date'].dt.day
df['DayOfWeek'] = df['Date'].dt.dayofweek  # 0=Monday
df['DayName'] = df['Date'].dt.day_name()
df['Quarter'] = df['Date'].dt.quarter
df['WeekOfYear'] = df['Date'].dt.isocalendar().week
df['IsWeekend'] = df['Date'].dt.dayofweek.isin([5, 6])

# Time components
df['Hour'] = df['Timestamp'].dt.hour
df['Minute'] = df['Timestamp'].dt.minute
df['Second'] = df['Timestamp'].dt.second

# Business day calculations
df['IsBusinessDay'] = np.busday_count(df['Date'].dt.date, df['Date'].shift(1).dt.date) == 1
```

---

## P3.7 String Operations

### P3.7.1 String Methods

```python
# .str accessor
df['Name_Upper'] = df['Name'].str.upper()
df['Name_Lower'] = df['Name'].str.lower()
df['Name_Length'] = df['Name'].str.len()

# Splitting and extracting
df[['First', 'Last']] = df['FullName'].str.split(' ', expand=True)
df['Domain'] = df['Email'].str.split('@').str[1]

# Replacing
df['Clean'] = df['Text'].str.replace('old', 'new')
df['NoSpaces'] = df['Text'].str.replace(' ', '_')

# String matching
df[df['Text'].str.contains('keyword')]
df[df['Text'].str.startswith('Prefix')]
df[df['Text'].str.endswith('Suffix')]

# Extracting regex
df['Phone'] = df['Text'].str.extract(r'(\d{3}-\d{3}-\d{4})')
df[['Area', 'Number']] = df['Phone'].str.extract(r'(\d{3})-(\d{3}-\d{4})')
```

### P3.7.2 Categorical Operations

```python
# Creating categorical
df['Category'] = df['Category'].astype('category')

# Categorical properties
df['Category'].cat.categories  # List all categories
df['Category'].cat.codes       # Integer codes
df['Category'].cat.ordered     # Check if ordered

# Reordering categories
df['Category'] = df['Category'].cat.reorder_categories(['Low', 'Medium', 'High'])
df['Category'] = df['Category'].cat.as_ordered()

# Adding/removing categories
df['Category'] = df['Category'].cat.add_categories(['Very Low', 'Very High'])
df['Category'] = df['Category'].cat.remove_categories(['Medium'])
```

---

## P3.8 Performance Optimization

### P3.8.1 Efficient Operations

```python
# ❌ SLOW: Iterating rows
for idx, row in df.iterrows():
    df.loc[idx, 'new_col'] = row['a'] + row['b']

# ❌ SLOW: Itertuples (slightly faster)
for row in df.itertuples():
    df.loc[row.Index, 'new_col'] = row.a + row.b

# ✅ FAST: Vectorized
df['new_col'] = df['a'] + df['b']

# ✅ FAST: Using apply with vectorized operations
df['new_col'] = df.apply(lambda x: x['a'] + x['b'], axis=1)

# ✅ FAST: Using numpy where
df['new_col'] = np.where(df['a'] > 10, 'High', 'Low')

# Query optimization
df.query('Age > 30 and City == "New York"')  # Often faster than boolean
```

### P3.8.2 Memory Management

```python
# Use dtypes wisely
df['Age'] = df['Age'].astype('int32')  # Instead of int64
df['Score'] = df['Score'].astype('float32')  # Instead of float64

# Use category for low cardinality
df['City'] = df['City'].astype('category')

# Use sparse for sparse data
df['Sparse'] = pd.arrays.SparseArray(df['Value'], fill_value=0)

# Read only needed columns
df = pd.read_csv('large.csv', usecols=['col1', 'col2', 'col3'])

# Use chunksize for large files
for chunk in pd.read_csv('large.csv', chunksize=10000):
    process(chunk)

# Memory profiling
import sys
df.memory_usage(deep=True).sum() / 1024**2  # Memory in MB
sys.getsizeof(df) / 1024**2  # Approximate memory
```

### P3.8.3 Index Optimization

```python
# Set index for faster lookups
df = df.set_index('id')

# Sort index for better performance
df = df.sort_index()

# MultiIndex for complex grouping
df = df.set_index(['City', 'Date'])

# Reset index when needed
df = df.reset_index()

# Merge on index (faster than on columns)
df1 = df1.set_index('key')
df2 = df2.set_index('key')
merged = df1.join(df2)
```

---

## P3.9 Common Patterns and Recipes

### P3.9.1 Chaining Operations

```python
# Efficient chaining (no intermediate copies)
result = (df
    .query('Age > 30')
    .groupby('City')
    .agg({'Salary': ['mean', 'sum']})
    .reset_index()
    .rename(columns={'mean': 'Avg_Salary', 'sum': 'Total_Salary'})
)
```

### P3.9.2 Conditional Column Creation

```python
# Using np.where
df['Category'] = np.where(df['Age'] > 30, 'Adult', 'Young')

# Multiple conditions with np.select
conditions = [
    df['Age'] < 18,
    df['Age'] < 65,
    df['Age'] >= 65
]
choices = ['Minor', 'Adult', 'Senior']
df['Age_Group'] = np.select(conditions, choices, default='Unknown')

# Using loc
df.loc[df['Age'] > 30, 'Category'] = 'Adult'
df.loc[df['Age'] <= 30, 'Category'] = 'Young'
```

### P3.9.3 Window Functions

```python
# Rank within groups
df['Rank'] = df.groupby('City')['Age'].rank(ascending=False)

# Cumulative sum within groups
df['Cumulative_Sum'] = df.groupby('City')['Sales'].cumsum()

# Percentile within groups
df['Percentile'] = df.groupby('City')['Age'].rank(pct=True)

# Lead/Lag within groups
df['Previous_Value'] = df.groupby('City')['Value'].shift(1)
df['Next_Value'] = df.groupby('City')['Value'].shift(-1)
```

---

## P3.10 Key Takeaways

1. **Vectorize everything** - Avoid loops, use pandas vectorized operations
2. **Use appropriate indexing** - .loc for labels, .iloc for positions
3. **Understand views vs. copies** - Prevent unintentional modifications
4. **Optimize memory** - Use appropriate dtypes and category for low cardinality
5. **Chain operations** - For cleaner, more efficient code
6. **Use groupby effectively** - Transform, filter, and apply are powerful tools
7. **Leverage datetime features** - Time series analysis is built-in
8. **Use query** - For readable and often faster filtering
9. **Monitor performance** - Profile memory and time for large datasets

This primer provides a comprehensive reference for pandas operations used throughout the series. Keep it handy for quick lookups of syntax and patterns.
