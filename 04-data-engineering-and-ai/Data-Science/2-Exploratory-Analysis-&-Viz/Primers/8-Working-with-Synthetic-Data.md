# Primer 8: Working with Synthetic Data

## Generating, Validating, and Using Synthetic Data for Analysis

---

#### Purpose of This Primer

Throughout this series, we've used synthetic data extensively—from the initial customer dataset generation to various examples throughout the tutorials. This primer explains:

- **Why** synthetic data is valuable for learning and development
- **How** to generate realistic synthetic data
- **What** makes synthetic data valid and useful
- **When** to use synthetic vs. real data

---

## P8.1 Why Synthetic Data?

### P8.1.1 Benefits of Synthetic Data

| Benefit | Explanation | Example |
|---------|-------------|---------|
| **Privacy & Compliance** | No real customer data exposed | GDPR, HIPAA compliance |
| **Availability** | Always available, no access restrictions | No waiting for data access |
| **Control** | Define relationships and patterns | Test specific scenarios |
| **Scale** | Generate any size dataset | Test performance at scale |
| **Annotations** | Perfect ground truth labels | Know exactly what patterns exist |
| **Cost** | Free to generate, no collection costs | No data acquisition budget |
| **Security** | No risk of data breaches | Public sharing safe |

### P8.1.2 Use Cases in This Series

```python
# 1. Learning Data Science
# - Practice EDA techniques
# - Test visualization methods
# - Build dashboards

# 2. Developing Pipelines
# - Test data processing code
# - Validate statistical methods
# - Profile performance

# 3. Training Models
# - Test ML workflows
# - Validate model assumptions
# - Experiment with features

# 4. Sharing Code
# - Public repositories
# - Educational materials
# - Open-source contributions
```

---

## P8.2 Types of Synthetic Data

### P8.2.1 Classification by Structure

```python
import numpy as np
import pandas as pd
from faker import Faker
import random

# 1. Fully Synthetic
# - No relation to real data
# - Created from scratch
# - Used for learning and testing

# 2. Partially Synthetic
# - Some values from real data
# - Others synthesized
# - Better for realistic testing

# 3. Structurally Similar
# - Same structure as real data
# - Different values
# - Good for pipeline development

# 4. Distribution-Matched
# - Same statistical properties
# - Different individual values
# - Ideal for modeling
```

### P8.2.2 Methods for Generation

```python
# Method 1: Statistical Models
# - Generate from known distributions
# - Matches statistical properties

def generate_from_distributions(n):
    """Generate data from statistical distributions."""
    df = pd.DataFrame({
        'age': np.random.normal(35, 10, n),
        'income': np.random.lognormal(10, 1, n),
        'orders': np.random.poisson(5, n),
        'rating': np.random.beta(5, 2, n) * 5
    })
    return df

# Method 2: Pattern-Based
# - Define explicit relationships
# - Control correlations and interactions

def generate_with_relationships(n):
    """Generate data with controlled relationships."""
    # Base variables
    age = np.random.uniform(18, 70, n)
    income = 30000 + age * 500 + np.random.normal(0, 10000, n)
    
    # Derived relationships
    order_freq = 0.5 + (income / 100000) * 2 + np.random.normal(0, 0.5, n)
    order_value = 50 + (income / 1000) * 2 + np.random.normal(0, 20, n)
    
    return pd.DataFrame({
        'age': age,
        'income': income,
        'order_frequency': np.clip(order_freq, 0, 5),
        'avg_order_value': np.clip(order_value, 10, 300)
    })

# Method 3: Faker Library
# - Realistic fake data
# - Names, addresses, emails, etc.

fake = Faker()

def generate_faker_data(n):
    """Generate realistic fake data using Faker."""
    data = []
    for _ in range(n):
        data.append({
            'name': fake.name(),
            'email': fake.email(),
            'address': fake.address(),
            'phone': fake.phone_number(),
            'company': fake.company(),
            'job': fake.job()
        })
    return pd.DataFrame(data)

# Method 4: Generative AI
# - Use models like GANs, VAEs
# - Most realistic but complex
# - Requires training data

# Method 5: CTGAN (Conditional Tabular GAN)
# from ctgan import CTGAN
# ctgan = CTGAN()
# ctgan.fit(real_data)
# synthetic_data = ctgan.sample(n)
```

---

## P8.3 Generating Realistic Customer Data

### P8.3.1 The Data Generation Pipeline

```python
def generate_customer_data(n_customers=5000, random_seed=42):
    """
    Generate realistic synthetic customer data.
    
    This is the function used throughout the series.
    """
    np.random.seed(random_seed)
    random.seed(random_seed)
    Faker.seed(random_seed)
    
    fake = Faker()
    
    # 1. Demographics
    # Bimodal age distribution (young + middle-aged)
    age_young = np.random.normal(28, 5, int(n_customers * 0.6))
    age_old = np.random.normal(48, 6, int(n_customers * 0.4))
    age = np.concatenate([age_young, age_old])
    age = np.clip(age, 18, 70).astype(int)
    np.random.shuffle(age)
    
    # Gender with non-binary
    gender = np.random.choice(
        ['Male', 'Female', 'Non-binary'],
        size=n_customers,
        p=[0.48, 0.48, 0.04]
    )
    
    # Income brackets (skewed)
    income_brackets = ['<$25K', '$25K-$50K', '$50K-$75K', '$75K-$100K', '>$100K']
    income_weights = [0.10, 0.25, 0.30, 0.20, 0.15]
    income = np.random.choice(income_brackets, size=n_customers, p=income_weights)
    
    # 2. Geographic
    countries = ['USA', 'UK', 'Canada', 'Australia', 'Germany']
    country_weights = [0.70, 0.12, 0.08, 0.06, 0.04]
    country = np.random.choice(countries, size=n_customers, p=country_weights)
    
    # 3. Behavior
    # Order frequency depends on income, age, engagement
    income_numeric = [income_brackets.index(i) for i in income]
    income_factor = np.array(income_numeric) / 4
    age_factor = 1 - np.abs(age - 35) / 35
    age_factor = np.clip(age_factor, 0.3, 1)
    
    order_freq = (0.5 + 
                  0.8 * income_factor + 
                  0.6 * age_factor +
                  np.random.normal(0, 0.3, n_customers))
    order_freq = np.clip(order_freq, 0.1, 4.0)
    
    # 4. Satisfaction
    # Rating influenced by order frequency
    rating = 3.5 + 0.3 * (order_freq / order_freq.max()) - 0.2 * np.random.normal(0, 1, n_customers)
    rating = np.clip(rating, 1, 5)
    rating = np.round(rating, 1)
    
    # Return rate inversely related to rating
    return_rate = 15 - 2.5 * (rating - 3.5) + np.random.normal(0, 3, n_customers)
    return_rate = np.clip(return_rate, 0, 40)
    
    # 5. Temporal
    end_date = pd.Timestamp.now()
    start_date = end_date - pd.Timedelta(days=3*365)
    account_created = [
        fake.date_time_between(start_date=start_date, end_date=end_date)
        for _ in range(n_customers)
    ]
    
    # 6. Intentional missing values
    age_missing = np.random.choice(n_customers, size=int(n_customers * 0.05), replace=False)
    age[age_missing] = np.nan
    
    rating_missing = np.random.choice(n_customers, size=int(n_customers * 0.07), replace=False)
    rating[rating_missing] = np.nan
    
    # 7. Create DataFrame
    df = pd.DataFrame({
        'customer_id': [f'CUST_{i:05d}' for i in range(1, n_customers + 1)],
        'age': age,
        'gender': gender,
        'income_bracket': income,
        'country': country,
        'order_frequency': order_freq,
        'avg_order_value': 50 + 200 * income_factor + np.random.normal(0, 30, n_customers),
        'customer_rating': rating,
        'return_rate': return_rate,
        'account_created': account_created
    })
    
    return df
```

---

## P8.4 Validating Synthetic Data

### P8.4.1 Statistical Validation

```python
def validate_synthetic_data(real_df, synthetic_df):
    """
    Validate synthetic data against real data distribution.
    """
    results = {}
    
    # 1. Distribution comparison
    for col in ['age', 'order_frequency', 'avg_order_value']:
        real_mean = real_df[col].mean()
        synth_mean = synthetic_df[col].mean()
        
        # KS test for distribution similarity
        from scipy.stats import ks_2samp
        stat, p_value = ks_2samp(real_df[col].dropna(), 
                                 synthetic_df[col].dropna())
        
        results[col] = {
            'real_mean': real_mean,
            'synth_mean': synth_mean,
            'difference_pct': abs((synth_mean - real_mean) / real_mean * 100),
            'ks_statistic': stat,
            'ks_p_value': p_value,
            'similar_distribution': p_value > 0.05
        }
    
    # 2. Correlation comparison
    real_corr = real_df[['age', 'order_frequency', 'avg_order_value']].corr()
    synth_corr = synthetic_df[['age', 'order_frequency', 'avg_order_value']].corr()
    
    corr_diff = (real_corr - synth_corr).abs().mean().mean()
    results['correlation_similarity'] = 1 - corr_diff
    
    # 3. Value range validation
    for col in ['age', 'order_frequency', 'avg_order_value', 'customer_rating']:
        real_min = real_df[col].min()
        real_max = real_df[col].max()
        synth_min = synthetic_df[col].min()
        synth_max = synthetic_df[col].max()
        
        results[f'{col}_range'] = {
            'real': (real_min, real_max),
            'synth': (synth_min, synth_max),
            'reasonable': (synth_min >= real_min * 0.8 and 
                          synth_max <= real_max * 1.2)
        }
    
    return results

# Usage
real_data = pd.read_csv('real_customer_data.csv')
synthetic_data = generate_customer_data(5000)
validation = validate_synthetic_data(real_data, synthetic_data)
```

### P8.4.2 Visual Validation

```python
def visualize_validation(real_df, synthetic_df):
    """
    Visual comparison of real vs synthetic data.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # 1. Age distribution
    ax = axes[0, 0]
    sns.kdeplot(real_df['age'].dropna(), label='Real', ax=ax)
    sns.kdeplot(synthetic_df['age'].dropna(), label='Synthetic', ax=ax)
    ax.set_title('Age Distribution')
    ax.legend()
    
    # 2. Order frequency
    ax = axes[0, 1]
    sns.kdeplot(real_df['order_frequency'].dropna(), label='Real', ax=ax)
    sns.kdeplot(synthetic_df['order_frequency'].dropna(), label='Synthetic', ax=ax)
    ax.set_title('Order Frequency Distribution')
    ax.legend()
    
    # 3. Correlation heatmap comparison
    ax = axes[1, 0]
    real_corr = real_df[['age', 'order_frequency', 'avg_order_value']].corr()
    sns.heatmap(real_corr, annot=True, fmt='.2f', ax=ax, cmap='RdBu_r', center=0)
    ax.set_title('Real Data Correlations')
    
    ax = axes[1, 1]
    synth_corr = synthetic_df[['age', 'order_frequency', 'avg_order_value']].corr()
    sns.heatmap(synth_corr, annot=True, fmt='.2f', ax=ax, cmap='RdBu_r', center=0)
    ax.set_title('Synthetic Data Correlations')
    
    plt.tight_layout()
    plt.show()
```

---

## P8.5 Advanced Synthetic Data Generation

### P8.5.1 CTGAN (Conditional Tabular GAN)

```python
# pip install ctgan

from ctgan import CTGAN

def generate_with_ctgan(real_data, n_samples=5000):
    """
    Generate synthetic data using CTGAN.
    """
    # Prepare data
    X = real_data.drop(columns=['customer_id'])
    
    # Identify categorical columns
    categorical_cols = X.select_dtypes(include=['object']).columns.tolist()
    
    # Train CTGAN
    ctgan = CTGAN(
        epochs=300,
        batch_size=500,
        discriminator_steps=1,
        generator_steps=1
    )
    ctgan.fit(X, categorical_cols)
    
    # Generate synthetic data
    synthetic = ctgan.sample(n_samples)
    
    return synthetic

# Usage
real_data = pd.read_csv('real_customer_data.csv')
synthetic_data = generate_with_ctgan(real_data, n_samples=5000)
```

### P8.5.2 SDV (Synthetic Data Vault)

```python
# pip install sdv

from sdv.metadata import SingleTableMetadata
from sdv.single_table import GaussianCopulaSynthesizer

def generate_with_sdv(real_data, n_samples=5000):
    """
    Generate synthetic data using SDV Gaussian Copula.
    """
    # Create metadata
    metadata = SingleTableMetadata()
    metadata.detect_from_dataframe(real_data)
    
    # Create synthesizer
    synthesizer = GaussianCopulaSynthesizer(metadata)
    synthesizer.fit(real_data)
    
    # Generate synthetic data
    synthetic = synthesizer.sample(n_samples)
    
    return synthetic
```

### P8.5.3 Time Series Synthetic Data

```python
def generate_time_series_data(n_days=365, n_customers=100):
    """
    Generate synthetic time series customer data.
    """
    # Create date range
    dates = pd.date_range('2024-01-01', periods=n_days, freq='D')
    
    # Generate customer patterns
    data = []
    for customer_id in range(n_customers):
        # Base patterns
        base_purchase_rate = np.random.uniform(0.1, 0.5)
        base_order_value = np.random.uniform(50, 200)
        
        for date in dates:
            # Weekly pattern
            day_of_week = date.dayofweek
            weekly_factor = 1 + 0.3 * (day_of_week == 6)  # Sunday boost
            
            # Seasonal pattern
            season = (date.month % 12) / 12
            seasonal_factor = 1 + 0.2 * np.sin(2 * np.pi * season)
            
            # Random variation
            random_factor = 1 + np.random.normal(0, 0.2)
            
            # Calculate purchase probability
            prob = base_purchase_rate * weekly_factor * seasonal_factor * random_factor
            prob = np.clip(prob, 0, 1)
            
            # Generate purchase
            if np.random.random() < prob:
                data.append({
                    'customer_id': f'CUST_{customer_id:04d}',
                    'date': date,
                    'order_value': base_order_value * np.random.uniform(0.8, 1.2),
                    'items': np.random.poisson(3) + 1,
                    'category': np.random.choice(['Electronics', 'Clothing', 'Books'])
                })
    
    df = pd.DataFrame(data)
    return df
```

---

## P8.6 Common Use Cases in This Series

### P8.6.1 Testing EDA Methods

```python
# Generate data with known patterns
def generate_test_data():
    """Generate data with known patterns for testing EDA."""
    n = 1000
    
    # Linear relationship
    x = np.random.normal(0, 1, n)
    y_linear = 2 * x + np.random.normal(0, 0.5, n)
    
    # Non-linear relationship
    y_nonlinear = x**2 + np.random.normal(0, 0.5, n)
    
    # Categorical relationship
    categories = np.random.choice(['A', 'B', 'C'], n)
    y_categorical = np.where(categories == 'A', 10, 
                            np.where(categories == 'B', 20, 30)) + np.random.normal(0, 2, n)
    
    return pd.DataFrame({
        'x': x,
        'y_linear': y_linear,
        'y_nonlinear': y_nonlinear,
        'category': categories,
        'y_categorical': y_categorical
    })

# Use for testing correlation detection
test_data = generate_test_data()
print("Known patterns:")
print("Linear correlation should be ~0.97")
print("Non-linear should have low Pearson but high Spearman")
```

### P8.6.2 Testing Statistical Methods

```python
def generate_statistical_test_data():
    """Generate data with known statistical properties."""
    
    # Normal data
    normal = np.random.normal(0, 1, 1000)
    
    # Skewed data
    skewed = np.random.exponential(2, 1000)
    
    # Outliers
    outliers = np.concatenate([
        np.random.normal(0, 1, 990),
        np.random.normal(10, 1, 10)
    ])
    
    # Two groups with known difference
    group1 = np.random.normal(0, 1, 1000)
    group2 = np.random.normal(1, 1, 1000)
    
    return pd.DataFrame({
        'normal': normal,
        'skewed': skewed,
        'outliers': outliers,
        'group1': group1,
        'group2': group2
    })

# Test statistical methods
test_data = generate_statistical_test_data()
print("Known differences:")
print("T-test should find significant difference between group1 and group2")
```

### P8.6.3 Testing Visualization Methods

```python
def generate_visualization_test_data():
    """Generate data for testing visualization methods."""
    n = 1000
    
    # Heatmap data
    heatmap_data = np.random.multivariate_normal(
        [0, 0, 0], 
        [[1, 0.8, 0.6], [0.8, 1, 0.4], [0.6, 0.4, 1]],
        n
    )
    
    # Facet data
    categories = np.random.choice(['A', 'B', 'C', 'D'], n)
    x = np.random.normal(0, 1, n)
    y = 2 * x + np.random.normal(0, 0.5, n)
    
    return pd.DataFrame({
        'var1': heatmap_data[:, 0],
        'var2': heatmap_data[:, 1],
        'var3': heatmap_data[:, 2],
        'category': categories,
        'x': x,
        'y': y
    })

# Test visualization methods
viz_data = generate_visualization_test_data()
print("Known patterns:")
print("var1, var2, var3 have strong correlations")
print("Different categories should show different patterns")
```

---

## P8.7 Best Practices

### P8.7.1 Do's and Don'ts

```python
# DO:
# 1. Set random seeds for reproducibility
np.random.seed(42)
random.seed(42)

# 2. Document generation parameters
def generate_data(n=5000, relationship_strength=0.8):
    """Generate data with documented parameters."""
    pass

# 3. Validate against real data
validation = validate_synthetic_data(real_data, synthetic_data)

# 4. Include realistic noise and missing values
age[np.random.choice(n, size=int(n*0.05), replace=False)] = np.nan

# 5. Test edge cases
# Generate data with extreme values, missing patterns, etc.

# DON'T:
# 1. Use synthetic data for production models
# 2. Ignore statistical validation
# 3. Forget to include realistic messiness
# 4. Assume synthetic data reflects all real-world complexities
```

### P8.7.2 When to Use Synthetic Data

| Scenario | Use Synthetic? | Why |
|----------|----------------|-----|
| **Learning/Practice** | ✅ Yes | Safe environment to learn |
| **Pipeline Development** | ✅ Yes | Test without real data |
| **Public Sharing** | ✅ Yes | Avoid privacy issues |
| **Production Models** | ❌ No | Needs real data patterns |
| **Clinical Research** | ❌ No | Cannot risk false patterns |
| **Financial Decisions** | ❌ No | Real data required |

---

## P8.8 Key Takeaways

1. **Synthetic data is valuable** for learning, testing, and development
2. **Realistic relationships matter** - Generate data with known patterns
3. **Validate against real data** when possible
4. **Include messiness** - Missing values, outliers, noise
5. **Document generation parameters** - Reproducibility matters
6. **Use appropriate methods** - Statistical, ML-based, or rule-based
7. **Test your code** - Synthetic data lets you find bugs safely
8. **Don't rely on synthetic data** for production decisions

---

## P8.9 Additional Resources

**Libraries:**
- **Faker**: Realistic fake data
- **CTGAN**: GAN-based tabular data
- **SDV**: Comprehensive synthetic data generation
- **yData**: Privacy-preserving synthetic data

**Further Reading:**
- "Synthetic Data for Machine Learning" - MIT Press
- "Generative Deep Learning" - David Foster
- "The Synthetic Data Vault" - MIT research

This primer explains how and why we use synthetic data throughout this series. It covers the generation methods, validation techniques, and best practices that ensure the data is realistic and useful for learning.
