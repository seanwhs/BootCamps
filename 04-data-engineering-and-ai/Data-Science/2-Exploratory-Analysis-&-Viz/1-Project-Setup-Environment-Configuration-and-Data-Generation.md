# Phase 2: Exploratory Data Analysis & Visualization

## Module 2.1: Systematic EDA & Data Profiling

### Part 1: Project Setup, Environment Configuration, and Data Generation

---

#### The Target

In this first technical section, we're going to set up our entire project environment from scratch and generate a synthetic e-commerce customer dataset that we'll use throughout the entire series. By the end of this part, you'll have:

1. A properly structured project directory
2. An isolated Python virtual environment
3. All required dependencies installed
4. A generated dataset (`customer_data.csv`) with realistic e-commerce patterns
5. A verification script to confirm everything is working correctly

---

#### The Concept

**Why a virtual environment?**

Think of a virtual environment like a separate kitchen for each recipe you're cooking. If you're baking a cake and making a curry at the same time in the same kitchen, you might accidentally use salt instead of sugar. Similarly, different Python projects need different versions of libraries. A virtual environment keeps each project's dependencies isolated, so you never accidentally break one project while working on another.

**Why generate synthetic data instead of using a real dataset?**

Real datasets often come with privacy restrictions, missing documentation, or licensing issues. By generating our own synthetic dataset, we:
- Can share it freely with you
- Know exactly what patterns exist (so we can verify our analysis finds them)
- Can introduce realistic "messiness" (missing values, outliers, noise) in controlled ways
- Give you a dataset that's complex enough to be interesting but clean enough to learn from

---

#### The Implementation

##### Step 1: Create the Project Directory Structure

Open your terminal (Command Prompt on Windows, Terminal on macOS/Linux) and create the following directory structure:

```bash
# Create the main project directory
mkdir exploratory_data_analysis_series
cd exploratory_data_analysis_series

# Create subdirectories for organized code
mkdir src
mkdir data
mkdir notebooks
mkdir outputs
mkdir outputs/figures
mkdir outputs/reports

# Create an empty __init__.py to make src a Python package
touch src/__init__.py
```

**Why this structure?**
- `src/` — Contains all our Python scripts and modules
- `data/` — Holds raw and processed data files
- `notebooks/` — For Jupyter notebooks (useful for exploration)
- `outputs/` — Generated files (figures, reports, etc.)
- `outputs/figures/` — Saved visualizations
- `outputs/reports/` — Generated analysis reports

---

##### Step 2: Set Up the Virtual Environment

```bash
# Create a virtual environment named 'venv'
python -m venv venv

# Activate it (the command varies by OS)

# On macOS/Linux:
source venv/bin/activate

# On Windows (Command Prompt):
venv\Scripts\activate

# On Windows (PowerShell):
.\venv\Scripts\Activate.ps1
```

You should see `(venv)` appear at the beginning of your terminal prompt, indicating the environment is active.

---

##### Step 3: Install Dependencies

Create a `requirements.txt` file in the project root with all our needed libraries:

**File:** `requirements.txt`
```txt
# Core data manipulation
pandas>=2.0.0
numpy>=1.24.0

# Visualization libraries
matplotlib>=3.7.0
seaborn>=0.12.0
altair>=5.0.0
plotly>=5.14.0
dash>=2.9.0

# Statistical and numerical tools
scipy>=1.10.0
statsmodels>=0.14.0

# Notebook environment
jupyter>=1.0.0

# Dataset utilities (provides example datasets)
vega_datasets>=0.9.0

# For generating synthetic data
faker>=19.0.0

# For code formatting and linting (optional but recommended)
black>=23.0.0
pylint>=2.17.0
```

Now install everything:

```bash
pip install -r requirements.txt
```

This will take a few minutes. While it's installing, let me explain what each library does:

- **pandas** — Our main data wrangling tool. Think of it as Excel on steroids, designed for programmatic data manipulation.
- **numpy** — Provides fast numerical operations (pandas is built on top of this).
- **matplotlib** — The foundational plotting library in Python. Everything else builds on it.
- **seaborn** — A high-level interface for statistical visualizations built on matplotlib.
- **altair** — A declarative visualization library that uses a grammar-based approach.
- **plotly** — Creates interactive web-based visualizations.
- **dash** — Builds web dashboards using plotly visualizations.
- **scipy** — Advanced scientific computing (statistical tests, optimization, etc.).
- **statsmodels** — Statistical modeling and hypothesis testing.
- **jupyter** — Interactive notebook environment for iterative exploration.
- **vega_datasets** — Provides sample datasets for practice.
- **faker** — Generates realistic fake data (names, emails, dates, etc.).

---

##### Step 4: Generate the Synthetic Customer Dataset

Now we'll create a Python script that generates our realistic e-commerce customer dataset.

**File:** `src/generate_data.py`
```python
"""
Synthetic Customer Data Generator for E-Commerce Analysis

This script generates a realistic customer dataset with patterns,
relationships, and intentional "messiness" to practice EDA techniques.
"""

import numpy as np
import pandas as pd
from faker import Faker
from datetime import datetime, timedelta
import random

# Set random seeds for reproducibility
np.random.seed(42)
random.seed(42)
Faker.seed(42)

# Initialize faker for realistic data generation
fake = Faker()


def generate_customer_data(n_customers: int = 5000) -> pd.DataFrame:
    """
    Generate synthetic customer data with realistic e-commerce patterns.
    
    Parameters:
    -----------
    n_customers : int
        Number of customer records to generate
    
    Returns:
    --------
    pd.DataFrame
        DataFrame with synthetic customer data
    """
    
    # --- 1. CUSTOMER DEMOGRAPHICS ---
    
    # Customer IDs - unique identifiers
    customer_ids = [f"CUST_{i:05d}" for i in range(1, n_customers + 1)]
    
    # Age distribution: Bimodal (young adults and middle-aged)
    # This creates a realistic pattern: two peaks (25-35 and 45-55)
    age_1 = np.random.normal(28, 5, int(n_customers * 0.6))  # 60% young adults
    age_2 = np.random.normal(48, 6, int(n_customers * 0.4))  # 40% middle-aged
    age = np.concatenate([age_1, age_2])
    age = np.clip(age, 18, 70).astype(int)  # Clip to realistic range
    np.random.shuffle(age)  # Shuffle to mix the two groups
    
    # Gender: 50/50 split with some "non-binary"
    gender_options = ['Male', 'Female', 'Non-binary']
    gender_weights = [0.48, 0.48, 0.04]
    gender = np.random.choice(gender_options, size=n_customers, p=gender_weights)
    
    # Income bracket: Creates 5 tiers with realistic distribution
    # Note: This will be used to create relationships with spending
    income_brackets = [
        '<$25K', '$25K-$50K', '$50K-$75K', 
        '$75K-$100K', '>$100K'
    ]
    # Skewed distribution: more people in middle brackets
    income_weights = [0.10, 0.25, 0.30, 0.20, 0.15]
    income_bracket = np.random.choice(
        income_brackets, 
        size=n_customers, 
        p=income_weights
    )
    
    # --- 2. GEOGRAPHIC INFORMATION ---
    
    # Countries with realistic distribution (mostly US with some international)
    countries = ['USA', 'UK', 'Canada', 'Australia', 'Germany']
    country_weights = [0.70, 0.12, 0.08, 0.06, 0.04]
    country = np.random.choice(countries, size=n_customers, p=country_weights)
    
    # Region (US states primarily)
    us_states = [
        'CA', 'TX', 'FL', 'NY', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI',
        'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MO', 'MD', 'WI'
    ]
    # For non-US, use generic region names
    non_us_regions = ['London', 'Ontario', 'Sydney', 'Berlin']
    
    region = []
    for c in country:
        if c == 'USA':
            region.append(np.random.choice(us_states))
        else:
            region.append(np.random.choice(non_us_regions))
    
    # City Tier: 1=Major Metro, 2=Mid-size, 3=Small City/Rural
    city_tier = np.random.choice([1, 2, 3], size=n_customers, p=[0.30, 0.45, 0.25])
    
    # --- 3. ENGAGEMENT METRICS ---
    
    # Time on site (minutes) - positively correlated with pages viewed
    time_on_site_base = np.random.exponential(scale=8, size=n_customers)
    time_on_site = np.clip(time_on_site_base + np.random.normal(0, 2, n_customers), 0.5, 45)
    
    # Pages viewed - strongly correlated with time_on_site
    # Pages = 2 + (time_on_site / 2) + random noise
    pages_viewed = 2 + (time_on_site / 2.5) + np.random.normal(0, 2, n_customers)
    pages_viewed = np.clip(pages_viewed, 1, 50).astype(int)
    
    # Email open rate (%)
    email_open_rate = np.random.beta(a=2, b=5, size=n_customers) * 100
    email_open_rate = np.clip(email_open_rate, 0, 100)
    
    # --- 4. PURCHASE BEHAVIOR ---
    
    # Order frequency (orders per month)
    # Affected by income, age, and engagement
    income_index = [income_brackets.index(i) for i in income_bracket]
    income_factor = np.array(income_index) / 4  # 0 to 1 scale
    
    age_factor = 1 - np.abs(age - 35) / 35  # Peak at age 35
    age_factor = np.clip(age_factor, 0.3, 1)
    
    engagement_factor = np.clip(time_on_site / 20, 0.3, 1)
    
    order_freq_base = (0.5 + 
                      0.8 * income_factor + 
                      0.6 * age_factor + 
                      0.4 * engagement_factor +
                      np.random.normal(0, 0.3, n_customers))
    order_freq = np.clip(order_freq_base, 0.1, 4.0)
    
    # Average order value ($) - strongly correlated with income
    avg_order_value = 50 + 200 * income_factor + np.random.normal(0, 30, n_customers)
    avg_order_value = np.clip(avg_order_value, 10, 350)
    
    # Product categories - customers favor certain categories
    categories = ['Electronics', 'Clothing', 'Home Goods', 'Books', 'Sports']
    # Create preference distribution based on age and income
    category_weights = []
    for i in range(n_customers):
        # Age influences categories
        if age[i] < 30:
            age_cat_weights = [0.3, 0.4, 0.1, 0.1, 0.1]
        elif age[i] < 45:
            age_cat_weights = [0.2, 0.3, 0.2, 0.1, 0.2]
        else:
            age_cat_weights = [0.1, 0.2, 0.4, 0.2, 0.1]
        
        # Income modifies slightly
        if income_index[i] >= 3:  # Higher income
            age_cat_weights[0] += 0.1  # More electronics
        
        # Normalize
        age_cat_weights = np.array(age_cat_weights)
        age_cat_weights = age_cat_weights / age_cat_weights.sum()
        category_weights.append(age_cat_weights)
    
    favorite_category = [
        np.random.choice(categories, p=w) for w in category_weights
    ]
    
    # --- 5. SATISFACTION & LOYALTY ---
    
    # Customer rating (1-5) - influenced by service quality and product fit
    # Higher ratings correlate with higher order frequency and lower returns
    rating_base = 3.5 + 0.3 * (order_freq / order_freq.max()) - 0.2 * (np.random.normal(0, 1, n_customers))
    rating = np.clip(rating_base, 1, 5)
    rating = np.round(rating, 1)  # Ratings are often given to one decimal
    
    # Return rate (%) - inversely related to rating
    return_rate = 15 - 2.5 * (rating - 3.5) + np.random.normal(0, 3, n_customers)
    return_rate = np.clip(return_rate, 0, 40)
    
    # --- 6. TIMESTAMP INFORMATION ---
    
    # Account creation date (last 3 years)
    end_date = datetime.now()
    start_date = end_date - timedelta(days=3*365)
    account_created = [
        fake.date_time_between(start_date=start_date, end_date=end_date)
        for _ in range(n_customers)
    ]
    
    # Last purchase date (more recent if frequency is higher)
    last_purchase = []
    for freq in order_freq:
        # Days since last purchase: inversely related to frequency
        days_since = np.random.exponential(scale=30 / max(freq, 0.1))
        days_since = min(days_since, 60)  # Cap at 60 days
        last_purchase.append(end_date - timedelta(days=days_since))
    
    # --- 7. INTENTIONAL MESSINESS ---
    
    # Introduce missing values (5-10% in some columns)
    # This mimics real-world data quality issues
    
    # Missing in age (5%)
    age_missing_idx = np.random.choice(
        n_customers, 
        size=int(n_customers * 0.05), 
        replace=False
    )
    age[age_missing_idx] = np.nan
    
    # Missing in rating (7%)
    rating_missing_idx = np.random.choice(
        n_customers, 
        size=int(n_customers * 0.07), 
        replace=False
    )
    rating[rating_missing_idx] = np.nan
    
    # Missing in email_open_rate (8%)
    email_missing_idx = np.random.choice(
        n_customers, 
        size=int(n_customers * 0.08), 
        replace=False
    )
    email_open_rate[email_missing_idx] = np.nan
    
    # --- 8. CREATE THE DATAFRAME ---
    
    df = pd.DataFrame({
        'customer_id': customer_ids,
        'age': age,
        'gender': gender,
        'income_bracket': income_bracket,
        'country': country,
        'region': region,
        'city_tier': city_tier,
        'time_on_site': time_on_site,
        'pages_viewed': pages_viewed,
        'email_open_rate': email_open_rate,
        'order_frequency': order_freq,
        'avg_order_value': avg_order_value,
        'favorite_category': favorite_category,
        'customer_rating': rating,
        'return_rate': return_rate,
        'account_created': account_created,
        'last_purchase': last_purchase
    })
    
    return df


def main():
    """
    Main function to generate and save the dataset.
    """
    print("=" * 60)
    print("GENERATING SYNTHETIC CUSTOMER DATASET")
    print("=" * 60)
    
    # Generate the dataset with 5000 customers
    print("\n[1/2] Generating 5,000 customer records...")
    df = generate_customer_data(n_customers=5000)
    
    # Save to CSV
    output_path = "data/customer_data.csv"
    print(f"[2/2] Saving dataset to '{output_path}'...")
    df.to_csv(output_path, index=False)
    
    # Print summary statistics
    print("\n" + "=" * 60)
    print("DATASET GENERATION COMPLETE")
    print("=" * 60)
    print(f"\nShape: {df.shape[0]} rows, {df.shape[1]} columns")
    print("\nFirst 5 rows:")
    print(df.head())
    print("\nData types:")
    print(df.dtypes)
    print("\nMissing values count:")
    print(df.isnull().sum())
    
    # Save a brief summary report
    with open("outputs/reports/data_summary.txt", "w") as f:
        f.write("CUSTOMER DATASET SUMMARY\n")
        f.write("=" * 40 + "\n")
        f.write(f"Generated on: {datetime.now()}\n")
        f.write(f"Total records: {df.shape[0]}\n")
        f.write(f"Total features: {df.shape[1]}\n\n")
        f.write("Feature types:\n")
        f.write(df.dtypes.to_string())
        f.write("\n\nMissing values:\n")
        f.write(df.isnull().sum().to_string())
        f.write("\n\nSample (first 10 rows):\n")
        f.write(df.head(10).to_string())
    
    print("\n✅ Dataset saved successfully!")
    print(f"✅ Summary report saved to 'outputs/reports/data_summary.txt'")
    print("\n" + "=" * 60)


if __name__ == "__main__":
    main()
```

**Key design decisions in this data generation script:**

1. **Realistic relationships:** We've built in genuine correlations (e.g., income affects order value, age affects category preference) that mirror real-world patterns.
2. **Reproducibility:** All random processes are seeded so you and I get exactly the same data.
3. **Messiness:** We've intentionally introduced missing values (5-8% in selected columns) to practice data cleaning and imputation.
4. **Documentation:** Extensive docstrings and comments explain every step, making this a reusable template for generating other synthetic datasets.

---

##### Step 5: Create a Verification Script

Let's create a simple script to verify everything is installed correctly:

**File:** `src/verify_setup.py`
```python
"""
Verification Script for EDA Visualization Series Setup

Run this to confirm all dependencies are installed
and the environment is correctly configured.
"""

import sys
import importlib
from pathlib import Path

def check_module(module_name, display_name=None):
    """Check if a module is installed and display its version."""
    if display_name is None:
        display_name = module_name
    
    try:
        module = importlib.import_module(module_name)
        version = getattr(module, '__version__', 'unknown')
        print(f"✅ {display_name}: {version}")
        return True
    except ImportError:
        print(f"❌ {display_name}: NOT INSTALLED")
        return False

def main():
    print("=" * 60)
    print("VERIFYING EDA VISUALIZATION SERIES SETUP")
    print("=" * 60)
    
    # Check Python version
    print(f"\n🐍 Python version: {sys.version}")
    
    # Check directory structure
    print("\n📁 Directory structure:")
    required_dirs = ['src', 'data', 'notebooks', 'outputs', 'outputs/figures', 'outputs/reports']
    for dir_path in required_dirs:
        path = Path(dir_path)
        if path.exists():
            print(f"  ✅ {dir_path}/ exists")
        else:
            print(f"  ⚠️  {dir_path}/ missing (will be created on demand)")
    
    # Check required modules
    print("\n📦 Required modules:")
    modules_to_check = {
        'pandas': 'pandas',
        'numpy': 'numpy',
        'matplotlib': 'matplotlib',
        'seaborn': 'seaborn',
        'altair': 'altair',
        'plotly': 'plotly',
        'dash': 'dash',
        'scipy': 'scipy',
        'statsmodels': 'statsmodels',
        'jupyter': 'jupyter',
        'faker': 'faker',
        'vega_datasets': 'vega_datasets'
    }
    
    all_installed = True
    for module_name, display_name in modules_to_check.items():
        if not check_module(module_name, display_name):
            all_installed = False
    
    # Check if data file exists
    print("\n📊 Data file:")
    data_path = Path('data/customer_data.csv')
    if data_path.exists():
        print(f"  ✅ data/customer_data.csv exists")
        # Show file size
        size = data_path.stat().st_size / 1024  # KB
        print(f"     File size: {size:.2f} KB")
    else:
        print("  ⚠️  data/customer_data.csv not found")
        print("     Run 'python src/generate_data.py' to generate it")
    
    print("\n" + "=" * 60)
    if all_installed:
        print("✅ SETUP COMPLETE - Ready to proceed!")
    else:
        print("❌ Some modules are missing. Run:")
        print("   pip install -r requirements.txt")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

---

##### Step 6: Run the Data Generation and Verification

Now let's execute everything to make sure it works:

```bash
# First, generate the dataset
python src/generate_data.py

# Then, verify the setup
python src/verify_setup.py
```

---

#### The Verification

Let's walk through the verification step by step:

**1. Check that the virtual environment is active:**

Your terminal prompt should show `(venv)` at the beginning. If not, activate it using the commands from Step 2.

**2. Run the data generation script:**

```bash
python src/generate_data.py
```

You should see output similar to:

```
============================================================
GENERATING SYNTHETIC CUSTOMER DATASET
============================================================

[1/2] Generating 5,000 customer records...
[2/2] Saving dataset to 'data/customer_data.csv'...

============================================================
DATASET GENERATION COMPLETE
============================================================

Shape: 5000 rows, 16 columns

First 5 rows:
  customer_id   age  gender income_bracket country region  city_tier  ...  account_created        last_purchase
0  CUST_00001  35.0  Female      $50K-$75K     USA     CA          1  ... 2025-03-14  ... 2026-06-15 ...
...

Data types:
customer_id          object
age                 float64
gender              object
income_bracket      object
country             object
region              object
city_tier            int64
time_on_site       float64
pages_viewed         int64
email_open_rate    float64
order_frequency    float64
avg_order_value    float64
favorite_category   object
customer_rating    float64
return_rate        float64
account_created     object
last_purchase       object
dtype: object

Missing values count:
customer_id            0
age                  250
gender                 0
income_bracket         0
country                0
region                 0
city_tier              0
time_on_site           0
pages_viewed           0
email_open_rate      400
order_frequency        0
avg_order_value        0
favorite_category      0
customer_rating      350
return_rate            0
account_created        0
last_purchase          0
dtype: int64

✅ Dataset saved successfully!
✅ Summary report saved to 'outputs/reports/data_summary.txt'
```

**3. Run the verification script:**

```bash
python src/verify_setup.py
```

You should see output confirming all modules are installed and the directory structure is correct.

**4. Quick data inspection using pandas (optional):**

Create a quick test to read the data:

```python
# You can run this in a Python interpreter or create a temporary script
import pandas as pd

df = pd.read_csv('data/customer_data.csv')
print("Dataset shape:", df.shape)
print("\nColumn descriptions:")
print(df.describe())
print("\nMissing values:")
print(df.isnull().sum())
```

---

#### What We've Accomplished

In this first technical part, we've:

1. ✅ Set up a professional project structure with clear organization
2. ✅ Created an isolated Python environment to prevent dependency conflicts
3. ✅ Installed all necessary libraries for data analysis and visualization
4. ✅ Generated a realistic, multi-dimensional customer dataset with:
   - Demographic information (age, gender, income)
   - Geographic data (country, region, city tier)
   - Engagement metrics (time on site, pages viewed, email open rate)
   - Purchase behavior (order frequency, average order value, favorite category)
   - Satisfaction and loyalty (customer rating, return rate)
   - Temporal data (account creation, last purchase)
   - Intentional missing values for realistic practice
5. ✅ Created a verification script to ensure everything works correctly

---

#### Deep Dive Reference: Understanding Our Dataset's Structure

Now that we have our data, let's understand what each column represents and why we designed it this way:

**Customer Demographics:**
- `age`: Bimodal distribution (young adults 25-35 and middle-aged 45-55) — many real customer bases show this pattern
- `gender`: Nearly balanced with small non-binary representation
- `income_bracket`: Skewed toward middle-income brackets, representing real economic distributions

**Geographic Information:**
- `country`: Heavily US-weighted (70%) with international representation
- `region`: US states for American customers, generic regions for others
- `city_tier`: 1=Major Metro, 2=Mid-size City, 3=Small City/Rural — captures urban vs. rural behavior differences

**Engagement Metrics:**
- `time_on_site`: Exponential distribution (most users spend little time, some spend a lot) — realistic for website traffic
- `pages_viewed`: Strongly correlated with time_on_site (users who stay longer view more pages)
- `email_open_rate`: Beta distribution (most users have low-to-moderate open rates) — typical for marketing emails

**Purchase Behavior:**
- `order_frequency`: Composite metric influenced by income, age, and engagement — captures multiple real drivers
- `avg_order_value`: Income-driven with random noise — high-income customers spend more
- `favorite_category`: Age and income determine preference — young customers prefer clothing, older prefer home goods

**Satisfaction & Loyalty:**
- `customer_rating`: Influenced by order frequency (more satisfied customers order more) with some noise
- `return_rate`: Inversely related to rating (satisfied customers return fewer items)

**Temporal Data:**
- `account_created`: Spread over 3 years — allows for cohort analysis
- `last_purchase`: Inversely related to order frequency — frequent buyers have more recent purchases

---

#### Next Up

In **Part 2**, we'll dive into **Univariate Analysis** — understanding each variable individually through summary statistics, histograms, density plots, and boxplots. We'll learn to identify skewness, kurtosis, and outliers, and understand why these matter for downstream analysis.

You now have everything set up and a rich dataset to explore. In the next part, we'll start asking questions of our data:

- What's the typical age of our customers?
- How skewed is our order frequency distribution?
- Are there any extreme outliers in average order value?
- Which segments of customers are we missing data for?
