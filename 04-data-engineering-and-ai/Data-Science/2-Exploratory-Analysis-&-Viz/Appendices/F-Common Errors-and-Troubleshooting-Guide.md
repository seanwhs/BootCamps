# Appendix F: Common Errors and Troubleshooting Guide

## Diagnosing and Fixing Issues in Data Analysis and Visualization

---

#### Purpose of This Appendix

This appendix serves as your comprehensive troubleshooting reference. Throughout the series, you may encounter various errors—from simple syntax mistakes to complex environmental issues. This guide helps you:

- Quickly identify common errors by their messages
- Understand the root cause of each error
- Apply proven solutions
- Prevent issues before they occur

Consider this your data analysis emergency kit. When something breaks, consult this guide first.

---

## F.1 Environment and Installation Errors

### F.1.1 ModuleNotFoundError / ImportError

**Error Message:**
```
ModuleNotFoundError: No module named 'plotly'
ImportError: cannot import name 'px' from 'plotly'
```

**Common Causes:**
- Library not installed
- Installed in wrong environment
- Version incompatibility
- Typo in import statement

**Solutions:**

```bash
# Check if package is installed
pip list | grep plotly

# Install missing package
pip install plotly

# Install specific version
pip install plotly==5.14.0

# For Jupyter, install in correct kernel
!pip install plotly  # Inside notebook
%pip install plotly  # Alternative

# Check Python environment
import sys
print(sys.executable)  # Shows which Python is running
print(sys.path)        # Shows import paths

# If using virtual environment, activate it
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install from requirements file
pip install -r requirements.txt
```

**Prevention:**
- Always use virtual environments
- Keep requirements.txt updated
- Document version numbers

### F.1.2 Version Conflicts

**Error Message:**
```
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed...
```
```
TypeError: ... got an unexpected keyword argument '...'
```

**Common Causes:**
- Incompatible library versions
- Outdated packages
- Conflicting dependencies

**Solutions:**

```bash
# Check installed versions
pip freeze

# Install specific compatible versions
pip install pandas==1.5.0 numpy==1.23.0

# Upgrade a package
pip install --upgrade pandas

# Downgrade a package
pip install pandas==1.4.0

# Show dependency tree
pipdeptree

# Clean install
pip uninstall package_name
pip install package_name

# Use constraints file
pip install -c constraints.txt package_name
```

**Common Compatible Versions:**

| Library | Recommended Version | Alternatives |
|---------|-------------------|--------------|
| pandas | 2.0.0+ | 1.5.0+ |
| numpy | 1.24.0+ | 1.23.0+ |
| matplotlib | 3.7.0+ | 3.5.0+ |
| seaborn | 0.12.0+ | 0.11.0+ |
| plotly | 5.14.0+ | 5.10.0+ |
| dash | 2.9.0+ | 2.6.0+ |
| altair | 5.0.0+ | 4.2.0+ |
| scikit-learn | 1.2.0+ | 1.0.0+ |

### F.1.3 Environment Activation Issues

**Error Message:**
```
venv\Scripts\activate : File cannot be loaded because running scripts is disabled on this system
```

**Solution (Windows PowerShell):**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or use Command Prompt instead
venv\Scripts\activate.bat
```

**Solution (Linux/Mac):**
```bash
# Check permissions
chmod +x venv/bin/activate

# Use source
source venv/bin/activate

# Or use absolute path
. /path/to/venv/bin/activate
```

---

## F.2 Data Loading Errors

### F.2.1 FileNotFoundError

**Error Message:**
```
FileNotFoundError: [Errno 2] No such file or directory: 'data/customer_data.csv'
```

**Common Causes:**
- Wrong file path
- Working directory is different
- File doesn't exist
- Case sensitivity on Linux/Mac

**Solutions:**

```python
import os
from pathlib import Path

# Check current working directory
print(os.getcwd())

# List files in directory
print(os.listdir('.'))

# Use absolute path
filepath = '/full/path/to/data/customer_data.csv'

# Use Path for robust path handling
base_dir = Path(__file__).parent.parent  # Goes up two levels
filepath = base_dir / 'data' / 'customer_data.csv'

# Check if file exists
if filepath.exists():
    df = pd.read_csv(filepath)
else:
    print(f"File not found: {filepath}")
    
# Create directory if needed
filepath.parent.mkdir(parents=True, exist_ok=True)
```

### F.2.2 ParserError / CSV Issues

**Error Message:**
```
ParserError: Error tokenizing data. C error: Expected 5 fields in line 3, saw 7
```

**Common Causes:**
- Inconsistent delimiters
- Special characters in data
- Encoding issues
- Header mismatch

**Solutions:**

```python
# Try different delimiters
df = pd.read_csv('file.csv', delimiter=';')
df = pd.read_csv('file.csv', delimiter='\t')
df = pd.read_csv('file.csv', sep=',', engine='python')

# Skip bad lines
df = pd.read_csv('file.csv', error_bad_lines=False)  # Deprecated
df = pd.read_csv('file.csv', on_bad_lines='skip')    # pandas 1.3+

# Specify encoding
df = pd.read_csv('file.csv', encoding='utf-8')
df = pd.read_csv('file.csv', encoding='latin-1')
df = pd.read_csv('file.csv', encoding='cp1252')

# Specify header
df = pd.read_csv('file.csv', header=None, names=['col1', 'col2', 'col3'])
df = pd.read_csv('file.csv', skiprows=3)  # Skip first 3 rows

# Handle quote characters
df = pd.read_csv('file.csv', quotechar='"')
df = pd.read_csv('file.csv', escapechar='\\')

# Use pandas infer
import chardet
with open('file.csv', 'rb') as f:
    encoding = chardet.detect(f.read())['encoding']
df = pd.read_csv('file.csv', encoding=encoding)
```

### F.2.3 MemoryError

**Error Message:**
```
MemoryError: Unable to allocate ... MiB for an array with shape ...
```

**Common Causes:**
- Dataset too large for RAM
- Inefficient data types
- Creating too many copies

**Solutions:**

```python
# Load in chunks
chunk_size = 100000
chunks = []
for chunk in pd.read_csv('large.csv', chunksize=chunk_size):
    chunks.append(chunk)
df = pd.concat(chunks, ignore_index=True)

# Specify dtypes to save memory
dtypes = {
    'col1': 'float32',
    'col2': 'int32',
    'col3': 'category'
}
df = pd.read_csv('large.csv', dtype=dtypes)

# Load only needed columns
usecols = ['col1', 'col2', 'col3']
df = pd.read_csv('large.csv', usecols=usecols)

# Use Dask for large data
import dask.dataframe as dd
df = dd.read_csv('large.csv')
result = df.groupby('col').sum().compute()

# Use Vaex for out-of-core
import vaex
df = vaex.from_csv('large.csv')

# Free memory
del df
import gc
gc.collect()
```

---

## F.3 Data Processing Errors

### F.3.1 KeyError

**Error Message:**
```
KeyError: 'customer_rating'
```

**Common Causes:**
- Column name doesn't exist
- Typo in column name
- Case sensitivity

**Solutions:**

```python
# Check available columns
print(df.columns.tolist())

# Case-insensitive access
def get_column(df, col_name):
    for col in df.columns:
        if col.lower() == col_name.lower():
            return df[col]
    raise KeyError(f"Column '{col_name}' not found")

# Use .get() for safe access
column = df.get('customer_rating', None)
if column is None:
    print("Column not found")

# Rename columns
df.columns = df.columns.str.lower()
df.columns = df.columns.str.strip()

# Reset index
df = df.reset_index()
```

### F.3.2 TypeError

**Error Message:**
```
TypeError: '>' not supported between instances of 'str' and 'int'
```

**Common Causes:**
- Mixing data types in operations
- Wrong data type for operation
- Missing conversion

**Solutions:**

```python
# Check data types
print(df.dtypes)
print(df['column'].dtype)

# Convert data types
df['age'] = df['age'].astype(float)
df['age'] = pd.to_numeric(df['age'], errors='coerce')
df['date'] = pd.to_datetime(df['date'])

# Handle categorical
df['category'] = df['category'].astype('category')

# Check for mixed types
df['column'].apply(type).value_counts()

# Safely convert
def safe_convert(value):
    try:
        return float(value)
    except (ValueError, TypeError):
        return np.nan

df['numeric_col'] = df['string_col'].apply(safe_convert)
```

### F.3.3 ValueError

**Error Message:**
```
ValueError: arrays must all be same length
ValueError: could not convert string to float: 'N/A'
ValueError: cannot reindex from a duplicate axis
```

**Common Causes:**
- Length mismatch
- Invalid values
- Duplicate indices

**Solutions:**

```python
# Length mismatch - align indices
df1 = df1.set_index('id')
df2 = df2.set_index('id')
result = df1.join(df2)

# Handle invalid values
df['col'] = pd.to_numeric(df['col'], errors='coerce')
df['col'] = df['col'].replace(['N/A', 'NaN', ''], np.nan)
df = df.dropna(subset=['col'])

# Remove duplicate indices
df = df[~df.index.duplicated(keep='first')]
df = df.reset_index(drop=True)

# For DataFrame operations
def safe_merge(df1, df2, on, how='inner'):
    # Remove duplicates before merge
    df1 = df1.drop_duplicates(subset=on)
    df2 = df2.drop_duplicates(subset=on)
    return pd.merge(df1, df2, on=on, how=how)
```

### F.3.4 SettingWithCopyWarning

**Warning Message:**
```
SettingWithCopyWarning: A value is trying to be set on a copy of a slice from a DataFrame
```

**Common Causes:**
- Modifying a slice of DataFrame
- Working on a view instead of a copy

**Solutions:**

```python
# ❌ BAD - causes warning
df_subset = df[df['age'] > 30]
df_subset['new_col'] = 0

# ✅ GOOD - use .loc
df.loc[df['age'] > 30, 'new_col'] = 0

# ✅ GOOD - make explicit copy
df_subset = df[df['age'] > 30].copy()
df_subset['new_col'] = 0

# ✅ GOOD - use .assign
df_new = df.assign(new_col=lambda x: x['age'] > 30)

# Suppress warning (only if you know what you're doing)
import warnings
warnings.filterwarnings('ignore', category=SettingWithCopyWarning)
```

---

## F.4 Visualization Errors

### F.4.1 Matplotlib Errors

**Error Message:**
```
UserWarning: Matplotlib is currently using agg, which is a non-GUI backend
```

**Solutions:**

```python
# Switch backend
import matplotlib
matplotlib.use('TkAgg')  # Or 'Qt5Agg', 'WebAgg'

# For Jupyter
%matplotlib inline  # Or 'notebook', 'widget'

# If using headless server
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Check available backends
print(matplotlib.rcsetup.all_backends)
```

**Error Message:**
```
AttributeError: module 'matplotlib' has no attribute 'pyplot'
```

**Solution:**
```python
# Check import
import matplotlib.pyplot as plt  # Correct
import matplotlib.pyplt as plt   # Wrong

# Reinstall if needed
pip uninstall matplotlib
pip install matplotlib
```

### F.4.2 Seaborn Errors

**Error Message:**
```
AttributeError: module 'seaborn' has no attribute 'histplot'
```

**Solutions:**
```python
# Upgrade Seaborn
pip install --upgrade seaborn

# Check version
import seaborn as sns
print(sns.__version__)  # Need >= 0.11.0 for histplot

# Use older function names
sns.distplot(df['age'])  # Deprecated but works in older versions
```

### F.4.3 Altair Errors

**Error Message:**
```
altair.vegalite.v4.schema.core.vegalite_compiler.MissingOptionalDependencyError: 
The 'altair_viewer' library is required to use the .show() method
```

**Solutions:**

```python
# Install required dependencies
pip install altair_viewer
pip install vega_datasets

# In Jupyter
alt.renderers.enable('notebook')

# For HTML export
chart.save('chart.html')

# For PNG export (requires altair_saver)
pip install altair_saver
chart.save('chart.png')

# Suppress renderer errors
alt.renderers.enable('default')
```

**Error Message:**
```
MaxRowsError: The number of rows in the dataset has exceeded the maximum allowed...
```

**Solutions:**

```python
# Increase max rows
alt.data_transformers.disable_max_rows()

# Or use sample
chart = alt.Chart(df.sample(10000)).mark_point()

# Or aggregate before plotting
chart = alt.Chart(df).mark_bar().encode(
    x='category:N',
    y='count()'
)
```

### F.4.4 Plotly Errors

**Error Message:**
```
ValueError: 'color' must be a column name or a plotly express color
```

**Solutions:**

```python
# Ensure column exists
print(df.columns)

# Use valid column name
fig = px.scatter(df, x='age', y='value', color='category')  # Column name

# Or use a color sequence
fig = px.scatter(df, x='age', y='value', color_discrete_sequence=['blue'])

# For continuous colors
fig = px.scatter(df, x='age', y='value', color='numeric_col', 
                 color_continuous_scale='Viridis')
```

**Error Message:**
```
dash.exceptions.InvalidCallbackReturnValue: The callback for output ... 
returned a value having type 'NoneType'
```

**Solutions:**

```python
# Ensure callback returns something
@callback(
    Output('output', 'children'),
    Input('input', 'value')
)
def update_output(value):
    if value is None:
        return "No input"  # Return something
    return f"Value: {value}"

# Use default return
def update_output(value):
    result = process(value)
    if result is None:
        return dash.no_update  # Or return empty string
    return result
```

---

## F.5 Jupyter/Notebook Errors

### F.5.1 Kernel Errors

**Error Message:**
```
Kernel died: Restarting kernel...
```

**Common Causes:**
- Memory exhaustion
- Infinite loop
- Segmentation fault

**Solutions:**

```python
# Check memory usage
import psutil
print(psutil.virtual_memory())

# Limit data size
df = df.head(1000)  # Use subset

# Restart kernel manually
# Kernel → Restart & Clear Output

# Check for infinite loops
# Add print statements to debug
# Use sys.setrecursionlimit for deep recursion

# Isolate problematic code
# Comment out sections to find culprit
```

### F.5.2 Display/Output Errors

**Error Message:**
```
IPython.core.error.UsageError: Cell magic `%%time` not found.
```

**Solutions:**

```python
# Install IPython magic
%load_ext  # Not needed for built-in magics

# Common magics
%time  # Time a single statement
%timeit  # Time multiple runs
%%time  # Time an entire cell
%run  # Run external script
%load  # Load code from file

# If magic doesn't work, use alternative
import time
start = time.time()
# Your code here
print(f"Time: {time.time() - start:.2f}s")
```

---

## F.6 Statistical Analysis Errors

### F.6.1 Scipy/Stats Errors

**Error Message:**
```
ZeroDivisionError: float division by zero
```

**Solutions:**

```python
# Check for zero values
if df['col'].std() == 0:
    print("Column has zero variance")
    # Handle accordingly
else:
    # Perform calculation
    pass

# Use try/except
try:
    result = scipy.stats.ttest_ind(group1, group2)
except (ZeroDivisionError, ValueError) as e:
    print(f"Test failed: {e}")
    result = None
```

**Error Message:**
```
RuntimeWarning: invalid value encountered in ...
```

**Solutions:**

```python
# Ignore warnings (if expected)
import warnings
warnings.filterwarnings('ignore', category=RuntimeWarning)

# Handle NaN values
data = df['col'].dropna()
if len(data) == 0:
    print("No valid data")
    return None

# Convert to numeric, coercing errors
df['col'] = pd.to_numeric(df['col'], errors='coerce')
```

---

## F.7 Dash Web App Errors

### F.7.1 Server Errors

**Error Message:**
```
OSError: [Errno 98] Address already in use
```

**Solutions:**

```bash
# Find process using port
sudo lsof -i :8050  # Linux/Mac
netstat -ano | findstr :8050  # Windows

# Kill the process
kill -9 PID  # Linux/Mac
taskkill /PID PID /F  # Windows

# Use different port
app.run_server(port=8051)
```

### F.7.2 Callback Errors

**Error Message:**
```
dash.exceptions.MissingCallbackContextException: 
Callbacks can only be used in a Dash app context
```

**Solutions:**

```python
# Ensure callback is in app context
app = Dash(__name__)

@callback(  # This works
    Output('output', 'children'),
    Input('input', 'value')
)
def update(value):
    return value

# Don't call callback functions directly
# update(value)  # ❌ Wrong
# Use app callback mechanism
```

**Error Message:**
```
dash.exceptions.CircularDependencyError: 
Circular dependency detected in the callback chain
```

**Solutions:**

```python
# ❌ BAD - Circular dependency
@callback(
    Output('a', 'children'),
    Input('b', 'value')
)
def update_a(b):
    return b

@callback(
    Output('b', 'children'),
    Input('a', 'value')
)
def update_b(a):
    return a

# ✅ GOOD - Break cycle
@callback(
    Output('a', 'children'),
    Output('b', 'children'),
    Input('trigger', 'n_clicks')
)
def update_both(n_clicks):
    # Update both from a single callback
    return 'a_value', 'b_value'
```

---

## F.8 Git and Version Control Errors

### F.8.1 .gitignore Issues

**Problem:** Large data files being tracked in git

**Solutions:**

```bash
# Add to .gitignore
echo "data/*.csv" >> .gitignore
echo "outputs/*" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
echo ".DS_Store" >> .gitignore
echo "venv/" >> .gitignore
echo ".env" >> .gitignore

# Remove already tracked files
git rm --cached data/customer_data.csv
git commit -m "Stop tracking data files"
```

### F.8.2 Merge Conflicts

**Solutions:**

```bash
# View conflicts
git status

# Open files and resolve manually
# Look for <<<<<<< HEAD and >>>>>>> branch

# After resolving
git add .
git commit -m "Resolved merge conflicts"

# Use merge tool
git mergetool

# Accept all from one side
git checkout --ours file.py
git checkout --theirs file.py
```

---

## F.9 Quick Reference: Error Message Lookup

| Error Message | Likely Cause | Quick Fix |
|---------------|--------------|-----------|
| `ModuleNotFoundError` | Missing package | `pip install package` |
| `ImportError` | Wrong import | Check import statement |
| `FileNotFoundError` | Wrong path | Use absolute path |
| `KeyError` | Column doesn't exist | Check column names |
| `TypeError` | Wrong data type | Convert dtype |
| `ValueError` | Invalid value | Clean data first |
| `MemoryError` | Data too large | Use chunks or optimize |
| `ParserError` | CSV formatting | Check delimiter, encoding |
| `SettingWithCopyWarning` | Modifying slice | Use `.loc` or `.copy()` |
| `Kernel died` | Memory/loop issue | Restart, use smaller data |
| `Address already in use` | Port occupied | Change port or kill process |
| `CircularDependencyError` | Callback cycle | Restructure callbacks |

---

## F.10 Prevention Checklist

**Before Starting a Project:**
- [ ] Set up virtual environment
- [ ] Install from requirements.txt
- [ ] Verify versions
- [ ] Test data loading

**During Development:**
- [ ] Use version control
- [ ] Write defensive code (try/except)
- [ ] Validate data types
- [ ] Check for missing values
- [ ] Use logging for debugging

**Before Deployment:**
- [ ] Test with realistic data
- [ ] Profile performance
- [ ] Check for memory leaks
- [ ] Implement error handling
- [ ] Set up monitoring

**Emergency Kit:**
- [ ] Backup data files
- [ ] Rollback plan
- [ ] Known working environment
- [ ] Debugging tools ready

---

## F.11 Useful Debugging Commands

```python
# Data exploration
df.info()
df.head()
df.describe()
df.columns.tolist()
df.dtypes
df.shape
df.isnull().sum()

# Environment
import sys
print(sys.version)
print(sys.executable)
!pip list

# Profiling
%timeit  # Jupyter
import cProfile
cProfile.run('function()')

# Debugging
import pdb; pdb.set_trace()  # Breakpoint
import traceback
traceback.print_exc()

# Logging
import logging
logging.basicConfig(level=logging.INFO)
logging.info('Debug message')

# Memory
import psutil
psutil.virtual_memory()
df.memory_usage(deep=True).sum() / 1024**2
```

This appendix provides a comprehensive troubleshooting guide for the most common errors you'll encounter. Keep it handy as you work through data analysis projects—it will save you hours of debugging time.

**Remember:** When you encounter an error:
1. **Read the error message carefully** - It often tells you exactly what's wrong
2. **Google the exact error message** - Someone has likely solved it before
3. **Check Stack Overflow** - The best resource for Python errors
4. **Reproduce with minimal code** - Isolate the issue
5. **Document your fix** - So you remember next time

Happy debugging! 🐛
