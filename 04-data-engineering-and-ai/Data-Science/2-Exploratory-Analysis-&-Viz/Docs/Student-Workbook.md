# Student Workbook: Exploratory Data Analysis & Visualization

## Phase 2: Complete Hands-On Exercises

---

#### Introduction to the Workbook

This workbook accompanies the "Exploratory Data Analysis & Visualization" series. It contains hands-on exercises, code challenges, and reflection questions for each module. Complete these exercises as you progress through the series to reinforce your learning and build your portfolio.

**How to Use This Workbook:**
- Complete exercises in order
- Write code in the provided spaces
- Answer reflection questions thoughtfully
- Save your work for portfolio reference
- **All code solutions are provided at the end of each module**

---

# MODULE 2.1: SYSTEMATIC EDA & DATA PROFILING

## Part 1: Project Setup & Data Generation

### Exercise 2.1.1: Project Initialization

**Objective:** Set up your project environment correctly.

**Instructions:**
1. Create the directory structure described in the tutorial
2. Create a virtual environment
3. Install all dependencies

**Checklist:**
- [ ] Created `exploratory_data_analysis_series` directory
- [ ] Created `src/`, `data/`, `notebooks/`, `outputs/` subdirectories
- [ ] Created `outputs/figures/` and `outputs/reports/`
- [ ] Created virtual environment (`venv`)
- [ ] Installed all packages from `requirements.txt`
- [ ] Successfully ran `python src/verify_setup.py`

**Reflection:**
Why is it important to use a virtual environment for data science projects?

```
Your answer: _________________________________________________
_________________________________________________
_________________________________________________
```

---

### Exercise 2.1.2: Data Generation

**Objective:** Generate and explore the synthetic customer dataset.

**Instructions:**
1. Run the data generation script
2. Inspect the generated data
3. Answer the questions below

**Code:**
```python
# Write code to:
# 1. Load the generated dataset
# 2. Display the first 5 rows
# 3. Display the shape of the dataset
# 4. Display column names and data types
# 5. Count missing values per column

# Your code here:

import pandas as pd

# Load the data
df = pd.read_csv('data/customer_data.csv')

# 1. First 5 rows
print("First 5 rows:")
print(df.head())

# 2. Shape
print(f"\nDataset shape: {df.shape}")

# 3. Column names and dtypes
print("\nColumns and data types:")
print(df.dtypes)

# 4. Missing values
print("\nMissing values per column:")
print(df.isnull().sum())
```

**Questions:**
1. How many rows and columns does the dataset have?
   ```
   Your answer: _________________________________________________
   ```

2. Which columns have missing values? How many missing values in each?
   ```
   Your answer: _________________________________________________
   ```

3. What are the different data types in the dataset?
   ```
   Your answer: _________________________________________________
   ```

---

### Exercise 2.1.3: Initial Data Inspection

**Objective:** Perform initial data inspection to understand the dataset.

**Instructions:**
Write Python code to answer each question.

**Code:**
```python
# 1. Generate summary statistics for all numerical columns

# Your code here:

df.describe()
```

```python
# 2. Count the unique values in each categorical column

# Your code here:

categorical_cols = df.select_dtypes(include=['object']).columns
for col in categorical_cols:
    print(f"{col}: {df[col].nunique()} unique values")
```

```python
# 3. Find the most common values in 'favorite_category'

# Your code here:

df['favorite_category'].value_counts()
```

```python
# 4. Find the 5 customers with the highest 'avg_order_value'

# Your code here:

df.nlargest(5, 'avg_order_value')[['customer_id', 'avg_order_value', 'order_frequency']]
```

**Questions:**
1. What is the average age of customers?
   ```
   Your answer: _________________________________________________
   ```

2. What is the most common income bracket?
   ```
   Your answer: _________________________________________________
   ```

3. Which product category is most popular?
   ```
   Your answer: _________________________________________________
   ```

---

## Part 2: Univariate Analysis

### Exercise 2.2.1: Understanding Distributions

**Objective:** Visualize and interpret distributions of key variables.

**Instructions:**
1. Write code to create histograms for `age`, `order_frequency`, `avg_order_value`
2. Add KDE overlays
3. Annotate with mean and median

**Code:**
```python
import matplotlib.pyplot as plt
import seaborn as sns

fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Age distribution
sns.histplot(df['age'].dropna(), kde=True, ax=axes[0])
axes[0].axvline(df['age'].mean(), color='red', linestyle='--', label='Mean')
axes[0].axvline(df['age'].median(), color='green', linestyle='-.', label='Median')
axes[0].set_title('Age Distribution')
axes[0].legend()

# Order frequency
sns.histplot(df['order_frequency'].dropna(), kde=True, ax=axes[1])
axes[1].axvline(df['order_frequency'].mean(), color='red', linestyle='--', label='Mean')
axes[1].axvline(df['order_frequency'].median(), color='green', linestyle='-.', label='Median')
axes[1].set_title('Order Frequency Distribution')
axes[1].legend()

# Order value
sns.histplot(df['avg_order_value'].dropna(), kde=True, ax=axes[2])
axes[2].axvline(df['avg_order_value'].mean(), color='red', linestyle='--', label='Mean')
axes[2].axvline(df['avg_order_value'].median(), color='green', linestyle='-.', label='Median')
axes[2].set_title('Average Order Value Distribution')
axes[2].legend()

plt.tight_layout()
plt.show()
```

**Questions:**
1. Which distribution appears most skewed? Is it right or left skewed?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. Are there any variables that appear approximately normal?
   ```
   Your answer: _________________________________________________
   ```

3. In which variables is the mean significantly different from the median? Why?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.2.2: Detecting Outliers

**Objective:** Detect and visualize outliers in numerical variables.

**Instructions:**
1. Create boxplots for each numerical variable
2. Count outliers using the IQR method
3. Identify which variables have the most outliers

**Code:**
```python
# Create boxplots
num_cols = ['age', 'order_frequency', 'avg_order_value', 'customer_rating', 'return_rate']

fig, axes = plt.subplots(1, 5, figsize=(20, 4))
for idx, col in enumerate(num_cols):
    sns.boxplot(y=df[col].dropna(), ax=axes[idx])
    axes[idx].set_title(col)

plt.tight_layout()
plt.show()

# Count outliers using IQR method
def count_outliers_iqr(data):
    q1 = data.quantile(0.25)
    q3 = data.quantile(0.75)
    iqr = q3 - q1
    lower = q1 - 1.5 * iqr
    upper = q3 + 1.5 * iqr
    return ((data < lower) | (data > upper)).sum()

for col in num_cols:
    data = df[col].dropna()
    outliers = count_outliers_iqr(data)
    pct = (outliers / len(data)) * 100
    print(f"{col}: {outliers} outliers ({pct:.1f}%)")
```

**Questions:**
1. Which variable has the most outliers?
   ```
   Your answer: _________________________________________________
   ```

2. What might explain these outliers in a business context?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

3. How should you handle outliers in this dataset for future analysis?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.2.3: Categorical Analysis

**Objective:** Analyze and visualize categorical variables.

**Instructions:**
1. Create frequency tables for key categorical variables
2. Create bar charts for each
3. Calculate proportions

**Code:**
```python
# 1. Frequency tables
cat_cols = ['gender', 'income_bracket', 'favorite_category']

for col in cat_cols:
    print(f"\n{col}:")
    print(df[col].value_counts())
    print(f"Proportion:")
    print(df[col].value_counts(normalize=True).round(3) * 100)
```

```python
# 2. Bar charts
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

for idx, col in enumerate(cat_cols):
    df[col].value_counts().plot(kind='bar', ax=axes[idx])
    axes[idx].set_title(col)
    axes[idx].set_ylabel('Count')

plt.tight_layout()
plt.show()
```

**Questions:**
1. What is the gender distribution? Is it balanced?
   ```
   Your answer: _________________________________________________
   ```

2. Which income bracket is most common? Which is least common?
   ```
   Your answer: _________________________________________________
   ```

3. What is the distribution of favorite categories? Which is most popular?
   ```
   Your answer: _________________________________________________
   ```

---

## Part 3: Bivariate & Multivariate Analysis

### Exercise 2.3.1: Correlation Analysis

**Objective:** Identify relationships between variables.

**Instructions:**
1. Compute Pearson and Spearman correlation matrices
2. Create a correlation heatmap
3. Identify the strongest correlations

**Code:**
```python
# Compute correlation matrices
num_cols = ['age', 'order_frequency', 'avg_order_value', 'customer_rating', 'return_rate', 'time_on_site', 'pages_viewed']

# Pearson
pearson_corr = df[num_cols].corr(method='pearson')
print("Pearson Correlation Matrix:")
print(pearson_corr)

# Spearman
spearman_corr = df[num_cols].corr(method='spearman')
print("\nSpearman Correlation Matrix:")
print(spearman_corr)

# Heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(pearson_corr, annot=True, fmt='.2f', cmap='RdBu_r', center=0)
plt.title('Pearson Correlation Heatmap')
plt.tight_layout()
plt.show()
```

**Questions:**
1. What is the strongest positive correlation? What does this relationship mean?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What is the strongest negative correlation? What does this relationship mean?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

3. Are there any variables that are highly correlated with each other? How might this affect modeling?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.3.2: Scatter Plot Analysis

**Objective:** Create and interpret scatter plots for key relationships.

**Instructions:**
1. Create scatter plots for the top 3 strongest correlations
2. Add regression lines
3. Add correlation coefficients as annotations

**Code:**
```python
# Create scatter plots for top relationships
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# 1. Time on site vs Pages viewed
sns.regplot(x='time_on_site', y='pages_viewed', data=df, ax=axes[0])
axes[0].set_title('Time on Site vs Pages Viewed')
r = df[['time_on_site', 'pages_viewed']].corr().iloc[0, 1]
axes[0].text(0.05, 0.95, f'r = {r:.3f}', transform=axes[0].transAxes, fontsize=12)

# 2. Income vs Avg Order Value (using numeric income mapping)
income_map = {'<$25K': 0, '$25K-$50K': 1, '$50K-$75K': 2, '$75K-$100K': 3, '>$100K': 4}
df['income_numeric'] = df['income_bracket'].map(income_map)
sns.regplot(x='income_numeric', y='avg_order_value', data=df, ax=axes[1])
axes[1].set_title('Income vs Avg Order Value')
r = df[['income_numeric', 'avg_order_value']].corr().iloc[0, 1]
axes[1].text(0.05, 0.95, f'r = {r:.3f}', transform=axes[1].transAxes, fontsize=12)

# 3. Rating vs Return Rate
sns.regplot(x='customer_rating', y='return_rate', data=df.dropna(subset=['customer_rating']), ax=axes[2])
axes[2].set_title('Rating vs Return Rate')
r = df[['customer_rating', 'return_rate']].corr().iloc[0, 1]
axes[2].text(0.05, 0.95, f'r = {r:.3f}', transform=axes[2].transAxes, fontsize=12)

plt.tight_layout()
plt.show()
```

**Questions:**
1. What does the relationship between time on site and pages viewed tell you about customer behavior?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. How does income relate to average order value? Is this expected?
   ```
   Your answer: _________________________________________________
   ```

3. What does the relationship between rating and return rate suggest about customer satisfaction?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.3.3: Categorical vs Numerical Analysis

**Objective:** Analyze how numerical variables differ across categorical groups.

**Instructions:**
1. Create boxplots comparing `avg_order_value` across `income_bracket`
2. Create violin plots comparing `customer_rating` across `favorite_category`
3. Interpret the results

**Code:**
```python
# 1. Boxplot: Order value by income bracket
plt.figure(figsize=(10, 6))
sns.boxplot(x='income_bracket', y='avg_order_value', data=df)
plt.title('Average Order Value by Income Bracket')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# 2. Violin plot: Rating by category
plt.figure(figsize=(10, 6))
sns.violinplot(x='favorite_category', y='customer_rating', data=df.dropna(subset=['customer_rating']))
plt.title('Customer Rating by Favorite Category')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# 3. Calculate group means
print("Mean order value by income bracket:")
print(df.groupby('income_bracket')['avg_order_value'].mean().sort_values(ascending=False))

print("\nMean rating by category:")
print(df.groupby('favorite_category')['customer_rating'].mean().sort_values(ascending=False))
```

**Questions:**
1. How does average order value differ across income brackets?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. Which category has the highest average customer rating? Which has the lowest?
   ```
   Your answer: _________________________________________________
   ```

3. What business insights can you derive from these relationships?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   _________________________________________________
   ```

---

## Part 4: Automated EDA vs Custom Inspection

### Exercise 2.4.1: Automated EDA Tools

**Objective:** Explore automated EDA tools and compare their outputs.

**Instructions:**
1. Generate a ydata-profiling report
2. Generate a Sweetviz report
3. Compare the outputs

**Code:**
```python
# 1. ydata-profiling
from ydata_profiling import ProfileReport

profile = ProfileReport(df, title="Customer Data Profile", explorative=True)
profile.to_file("outputs/eda_reports/student_profile_report.html")
print("ydata-profiling report generated!")

# 2. Sweetviz
import sweetviz as sv

report = sv.analyze(df, target_feat='customer_rating')
report.show_html("outputs/eda_reports/student_sweetviz_report.html")
print("Sweetviz report generated!")
```

**Reflection:**
1. What insights from the automated reports surprised you?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What did the automated tools find that you missed in manual exploration?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

3. What limitations did you notice in the automated reports?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.4.2: Custom Visual Inspection

**Objective:** Create custom visualizations to explore deeper patterns.

**Instructions:**
1. Investigate missing data patterns
2. Explore segment differences
3. Look for interaction effects

**Code:**
```python
# 1. Missing data patterns
import matplotlib.pyplot as plt
import seaborn as sns

plt.figure(figsize=(12, 6))
missing = df.isnull().sum()
missing = missing[missing > 0].sort_values()
plt.bar(missing.index, missing.values)
plt.title('Missing Values by Column')
plt.xticks(rotation=45)
plt.ylabel('Count')
plt.tight_layout()
plt.show()

# 2. Segment differences: Age group by income
df['age_group'] = pd.cut(df['age'], bins=[0, 25, 35, 45, 55, 100],
                         labels=['<25', '25-35', '35-45', '45-55', '55+'])
age_income = pd.crosstab(df['age_group'], df['income_bracket'], normalize='index')
print("Age distribution by income bracket:")
print(age_income.round(3))

# 3. Interaction effects
plt.figure(figsize=(12, 6))
sns.barplot(x='age_group', y='order_frequency', hue='income_bracket', data=df)
plt.title('Order Frequency by Age Group and Income Bracket')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

**Reflection:**
1. What patterns did you discover in the missing data?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What segment differences did you find?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

3. What interaction effects did you discover?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

# MODULE 2.2: STATIC & DECLARATIVE VISUALIZATIONS

## Part 1: Matplotlib

### Exercise 2.2.1: Creating Custom Layouts

**Objective:** Create multi-panel figures with GridSpec.

**Instructions:**
1. Create a 2x2 GridSpec layout with unequal column widths
2. Add different plot types to each subplot
3. Format axes professionally

**Code:**
```python
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# Create figure
fig = plt.figure(figsize=(12, 10))

# Create GridSpec with unequal widths
gs = gridspec.GridSpec(2, 3, width_ratios=[1.5, 1, 1], height_ratios=[1, 1])

# 1. Main plot (spans 2 rows, 1 column)
ax1 = fig.add_subplot(gs[0:2, 0])
scatter = ax1.scatter(df['time_on_site'], df['pages_viewed'], 
                     c=df['order_frequency'], cmap='viridis', alpha=0.6)
ax1.set_xlabel('Time on Site (min)')
ax1.set_ylabel('Pages Viewed')
ax1.set_title('Engagement: Time vs Pages (colored by Order Freq)')
fig.colorbar(scatter, ax=ax1, label='Order Frequency')

# 2. Histogram (row 0, col 1)
ax2 = fig.add_subplot(gs[0, 1])
df['age'].dropna().hist(bins=20, ax=ax2, color='steelblue', edgecolor='black')
ax2.set_xlabel('Age')
ax2.set_ylabel('Count')
ax2.set_title('Age Distribution')

# 3. Box plot (row 0, col 2)
ax3 = fig.add_subplot(gs[0, 2])
df.boxplot(column='avg_order_value', by='income_bracket', ax=ax3)
ax3.set_title('Order Value by Income')
ax3.set_xlabel('Income Bracket')
ax3.set_ylabel('Avg Order Value')
plt.setp(ax3.xaxis.get_majorticklabels(), rotation=45)

# 4. Bar chart (row 1, col 1)
ax4 = fig.add_subplot(gs[1, 1])
category_counts = df['favorite_category'].value_counts()
ax4.bar(category_counts.index, category_counts.values, color='coral')
ax4.set_xlabel('Category')
ax4.set_ylabel('Count')
ax4.set_title('Favorite Categories')
plt.setp(ax4.xaxis.get_majorticklabels(), rotation=45)

# 5. Pie chart (row 1, col 2)
ax5 = fig.add_subplot(gs[1, 2])
gender_counts = df['gender'].value_counts()
ax5.pie(gender_counts.values, labels=gender_counts.index, autopct='%1.1f%%')
ax5.set_title('Gender Distribution')

plt.suptitle('Customer Analytics Dashboard', fontsize=16, fontweight='bold')
plt.tight_layout()
plt.show()
```

**Reflection:**
1. How does using GridSpec give you more control over layout?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What are the benefits of combining different plot types in one figure?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.2.2: Fine-Tuned Formatting

**Objective:** Apply professional formatting to charts.

**Instructions:**
1. Create a scatter plot
2. Customize all axes, ticks, and labels
3. Add annotations and highlights

**Code:**
```python
fig, ax = plt.subplots(figsize=(10, 8))

# Scatter plot
scatter = ax.scatter(df['order_frequency'], df['avg_order_value'],
                     c=df['customer_rating'], cmap='plasma', 
                     s=50, alpha=0.6)

# Customize axes
ax.set_xlabel('Order Frequency (orders/month)', fontsize=14, fontweight='bold')
ax.set_ylabel('Average Order Value ($)', fontsize=14, fontweight='bold')
ax.set_title('Purchase Behavior Analysis', fontsize=16, fontweight='bold')

# Ticks
ax.tick_params(axis='both', labelsize=12)
ax.xaxis.set_major_locator(plt.MultipleLocator(0.5))
ax.yaxis.set_major_locator(plt.MultipleLocator(50))

# Grid
ax.grid(True, alpha=0.3, linestyle='--')

# Add colorbar
cbar = fig.colorbar(scatter, ax=ax, label='Customer Rating', shrink=0.8)
cbar.ax.tick_params(labelsize=12)

# Add annotations
ax.axvline(df['order_frequency'].mean(), color='red', linestyle='--', alpha=0.5, label='Mean Frequency')
ax.axhline(df['avg_order_value'].mean(), color='blue', linestyle='--', alpha=0.5, label='Mean Order Value')

# Highlight high-value customers
high_value = df[df['avg_order_value'] > 200]
if not high_value.empty:
    ax.scatter(high_value['order_frequency'], high_value['avg_order_value'],
              s=150, facecolors='none', edgecolors='red', linewidth=2, label='High Value')

ax.legend(loc='upper left')

plt.tight_layout()
plt.show()
```

**Reflection:**
1. What formatting choices improved the readability of this chart?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. How do annotations help tell a story with data?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

## Part 2: Seaborn

### Exercise 2.2.3: Statistical Plots

**Objective:** Create statistical visualizations with Seaborn.

**Instructions:**
1. Create distribution plots for numerical variables
2. Create categorical comparison plots
3. Add statistical annotations

**Code:**
```python
import seaborn as sns

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 1. Distribution plot with KDE
sns.histplot(df['order_frequency'].dropna(), kde=True, ax=axes[0, 0])
axes[0, 0].axvline(df['order_frequency'].mean(), color='red', linestyle='--', label='Mean')
axes[0, 0].axvline(df['order_frequency'].median(), color='green', linestyle='-.', label='Median')
axes[0, 0].set_title('Order Frequency Distribution')
axes[0, 0].legend()

# 2. Violin plot
sns.violinplot(x='income_bracket', y='avg_order_value', data=df, ax=axes[0, 1])
axes[0, 1].set_title('Order Value by Income')
plt.setp(axes[0, 1].xaxis.get_majorticklabels(), rotation=45)

# 3. Box plot with swarm overlay
sns.boxplot(x='favorite_category', y='customer_rating', data=df.dropna(subset=['customer_rating']), ax=axes[1, 0])
sns.swarmplot(x='favorite_category', y='customer_rating', data=df.dropna(subset=['customer_rating']), 
              color='black', alpha=0.3, size=3, ax=axes[1, 0])
axes[1, 0].set_title('Rating by Category')
plt.setp(axes[1, 0].xaxis.get_majorticklabels(), rotation=45)

# 4. Regression plot
sns.regplot(x='customer_rating', y='return_rate', data=df.dropna(subset=['customer_rating']), ax=axes[1, 1])
axes[1, 1].set_title('Return Rate vs Rating')

plt.tight_layout()
plt.show()
```

**Questions:**
1. What does the violin plot reveal about order value distribution across income levels?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What does the regression plot suggest about the relationship between rating and return rate?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.2.4: FacetGrid and PairGrid

**Objective:** Create multi-plot grids for comparing across categories.

**Instructions:**
1. Use FacetGrid to create histograms by category
2. Use PairGrid to create pairwise plots

**Code:**
```python
# 1. FacetGrid - Age distribution by gender and income
g = sns.FacetGrid(df.dropna(subset=['age']), col='gender', row='income_bracket', height=3, aspect=1.5)
g.map(sns.histplot, 'age', kde=True)
g.set_axis_labels('Age', 'Count')
g.fig.suptitle('Age Distribution by Gender and Income', y=1.02)
plt.tight_layout()
plt.show()

# 2. PairGrid - Relationship between key variables
cols = ['age', 'order_frequency', 'avg_order_value', 'customer_rating']
g = sns.PairGrid(df[cols].dropna())
g.map_upper(sns.scatterplot, alpha=0.3)
g.map_lower(sns.kdeplot)
g.map_diag(sns.histplot, kde=True)
g.fig.suptitle('Pairwise Relationships', y=1.02)
plt.tight_layout()
plt.show()
```

**Reflection:**
1. What patterns do you see in the FacetGrid across gender and income?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. Which relationships in the PairGrid are most informative?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

## Part 3: Altair

### Exercise 2.3.5: Declarative Visualizations

**Objective:** Create declarative visualizations with Altair.

**Instructions:**
1. Create a scatter plot with color encoding
2. Create a histogram with KDE
3. Create a faceted chart

**Code:**
```python
import altair as alt

# 1. Scatter plot with color
chart1 = alt.Chart(df).mark_circle(size=60, opacity=0.7).encode(
    x=alt.X('order_frequency:Q', title='Order Frequency'),
    y=alt.Y('avg_order_value:Q', title='Avg Order Value ($)'),
    color=alt.Color('income_bracket:N', title='Income Bracket'),
    tooltip=['customer_id', 'order_frequency', 'avg_order_value']
).properties(
    title='Purchase Behavior by Income',
    width=600,
    height=400
).interactive()

chart1.show()  # or chart1.save('chart1.html')

# 2. Histogram with KDE
chart2 = alt.Chart(df).transform_density(
    'age',
    as_=['age', 'density']
).mark_line(color='red').encode(
    x=alt.X('age:Q', title='Age'),
    y=alt.Y('density:Q', title='Density')
)

hist = alt.Chart(df).mark_bar(opacity=0.7, color='steelblue').encode(
    x=alt.X('age:Q', bin=alt.Bin(maxbins=20), title='Age'),
    y=alt.Y('count()', title='Count')
)

chart2 = alt.layer(hist, chart2).properties(
    title='Age Distribution with KDE',
    width=600,
    height=400
).interactive()

# 3. Faceted chart
chart3 = alt.Chart(df).mark_bar(opacity=0.7).encode(
    x=alt.X('age:Q', bin=alt.Bin(maxbins=15), title='Age'),
    y=alt.Y('count()', title='Count'),
    color=alt.Color('gender:N', title='Gender')
).facet(
    facet=alt.Facet('income_bracket:N', columns=3),
    title='Age Distribution by Income Bracket and Gender'
).properties(
    width=200,
    height=200
)

chart3.show()
```

**Reflection:**
1. How does Altair's declarative syntax differ from Matplotlib's imperative approach?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What are the benefits of using Altair for exploratory analysis?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

# MODULE 2.3: INTERACTIVE DATA EXPLORATION

## Part 1: Plotly

### Exercise 2.3.1: Interactive Charts

**Objective:** Create interactive visualizations with Plotly.

**Instructions:**
1. Create an interactive scatter plot with hover details
2. Create an interactive histogram
3. Create a 3D scatter plot

**Code:**
```python
import plotly.express as px

# 1. Interactive scatter plot
fig1 = px.scatter(df, 
                  x='time_on_site', 
                  y='pages_viewed',
                  color='income_bracket',
                  size='order_frequency',
                  hover_data=['customer_id', 'customer_rating'],
                  title='Engagement Analysis',
                  template='plotly_white')
fig1.update_layout(width=800, height=600)
fig1.show()

# 2. Interactive histogram
fig2 = px.histogram(df, 
                    x='age', 
                    color='gender',
                    nbins=30,
                    marginal='box',
                    title='Age Distribution by Gender',
                    template='plotly_white',
                    barmode='overlay')
fig2.update_layout(width=800, height=600)
fig2.show()

# 3. 3D scatter plot
fig3 = px.scatter_3d(df.sample(500), 
                     x='age', 
                     y='order_frequency', 
                     z='avg_order_value',
                     color='customer_rating',
                     size='time_on_site',
                     title='3D Customer Analysis',
                     template='plotly_white')
fig3.update_layout(width=900, height=700)
fig3.show()
```

**Reflection:**
1. How does the interactivity of Plotly charts enhance exploration?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What advantages does 3D visualization provide over 2D?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.3.2: Chart with Controls

**Objective:** Add dynamic controls to charts.

**Instructions:**
1. Create a chart with a dropdown filter
2. Create a chart with a slider

**Code:**
```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# 1. Chart with dropdown
fig = go.Figure()

# Add traces for each category
categories = df['favorite_category'].unique()
for category in categories:
    cat_data = df[df['favorite_category'] == category]
    fig.add_trace(go.Scatter(
        x=cat_data['order_frequency'],
        y=cat_data['avg_order_value'],
        mode='markers',
        name=category,
        visible=(category == categories[0]),
        marker=dict(size=8, opacity=0.6),
        hovertemplate='Freq: %{x}<br>Value: %{y}<extra></extra>'
    ))

# Create dropdown buttons
buttons = []
for i, category in enumerate(categories):
    buttons.append(dict(
        label=category,
        method='update',
        args=[{'visible': [j == i for j in range(len(categories))]},
              {'title': f'Order Value vs Frequency - {category}'}]
    ))

fig.update_layout(
    updatemenus=[dict(
        type='dropdown',
        buttons=buttons,
        direction='down',
        showactive=True,
        x=0.02,
        y=0.98
    )],
    title='Filter by Category',
    xaxis_title='Order Frequency',
    yaxis_title='Avg Order Value',
    template='plotly_white',
    width=800,
    height=600
)
fig.show()

# 2. Chart with slider
fig2 = go.Figure()

# Group by city tier
tiers = sorted(df['city_tier'].unique())
tier_labels = {1: 'Major Metro', 2: 'Mid-size City', 3: 'Small City'}

for tier in tiers:
    tier_data = df[df['city_tier'] == tier]
    fig2.add_trace(go.Histogram(
        x=tier_data['customer_rating'].dropna(),
        name=tier_labels[tier],
        visible=(tier == tiers[0])
    ))

# Create slider steps
steps = []
for i, tier in enumerate(tiers):
    steps.append(dict(
        method='update',
        args=[{'visible': [j == i for j in range(len(tiers))]},
              {'title': f'Rating Distribution - {tier_labels[tier]}'}],
        label=tier_labels[tier]
    ))

fig2.update_layout(
    sliders=[dict(
        active=0,
        steps=steps,
        currentvalue={'prefix': 'City Tier: '}
    )],
    title='Rating Distribution by City Tier',
    xaxis_title='Rating',
    yaxis_title='Count',
    template='plotly_white',
    width=800,
    height=600,
    barmode='overlay'
)
fig2.show()
```

**Reflection:**
1. How do dropdowns and sliders enhance user exploration?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What other controls could you add to this visualization?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

## Part 2: Dash

### Exercise 2.3.3: Basic Dash Dashboard

**Objective:** Build a simple interactive dashboard with Dash.

**Instructions:**
1. Create a Dash app with a dropdown filter
2. Add a chart that updates based on the filter
3. Add KPI cards

**Code:**
```python
import dash
from dash import dcc, html, Input, Output
import plotly.express as px

# Load data
df = pd.read_csv('data/customer_data.csv')

# Initialize app
app = dash.Dash(__name__)

# Layout
app.layout = html.Div([
    html.H1("Customer Analytics", style={'textAlign': 'center'}),
    
    html.Div([
        html.Label("Filter by Income Bracket:"),
        dcc.Dropdown(
            id='income-filter',
            options=[{'label': 'All', 'value': 'All'}] +
                    [{'label': i, 'value': i} for i in df['income_bracket'].unique()],
            value='All'
        )
    ], style={'width': '50%', 'margin': 'auto'}),
    
    html.Div([
        html.Div(id='kpi-total', className='kpi-card'),
        html.Div(id='kpi-avg-value', className='kpi-card'),
        html.Div(id='kpi-avg-rating', className='kpi-card')
    ], style={'display': 'flex', 'justifyContent': 'space-around', 'margin': '20px'}),
    
    dcc.Graph(id='main-chart')
])

# Callback
@callback(
    Output('main-chart', 'figure'),
    Output('kpi-total', 'children'),
    Output('kpi-avg-value', 'children'),
    Output('kpi-avg-rating', 'children'),
    Input('income-filter', 'value')
)
def update_dashboard(selected_income):
    if selected_income == 'All':
        filtered = df
    else:
        filtered = df[df['income_bracket'] == selected_income]
    
    # KPI cards
    kpi_total = html.Div([
        html.H3("Total Customers"),
        html.H2(f"{len(filtered):,}")
    ])
    
    kpi_avg_value = html.Div([
        html.H3("Avg Order Value"),
        html.H2(f"${filtered['avg_order_value'].mean():.2f}")
    ])
    
    kpi_avg_rating = html.Div([
        html.H3("Avg Rating"),
        html.H2(f"{filtered['customer_rating'].mean():.2f}/5.0")
    ])
    
    # Chart
    fig = px.scatter(filtered, 
                     x='order_frequency', 
                     y='avg_order_value',
                     color='favorite_category',
                     title=f'Purchase Behavior ({len(filtered)} customers)')
    
    return fig, kpi_total, kpi_avg_value, kpi_avg_rating

if __name__ == '__main__':
    app.run_server(debug=True)
```

**Reflection:**
1. How does the dashboard enable data exploration?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What other features would you add to this dashboard?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

### Exercise 2.3.4: Cross-Filtering Dashboard

**Objective:** Create a dashboard with cross-filtering between charts.

**Instructions:**
1. Create two charts that cross-filter each other
2. Implement click-based filtering
3. Add a data table

**Code:**
```python
import dash
from dash import dcc, html, Input, Output
import plotly.express as px

df = pd.read_csv('data/customer_data.csv')
df['city_tier_label'] = df['city_tier'].map({1: 'Metro', 2: 'Mid-size', 3: 'Small'})

app = dash.Dash(__name__)

app.layout = html.Div([
    html.H1("Cross-Filtering Dashboard", style={'textAlign': 'center'}),
    
    html.Div([
        html.Div([
            dcc.Graph(id='scatter-chart')
        ], style={'width': '50%', 'display': 'inline-block'}),
        html.Div([
            dcc.Graph(id='histogram-chart')
        ], style={'width': '50%', 'display': 'inline-block'})
    ]),
    
    html.Div([
        dcc.Graph(id='box-chart')
    ]),
    
    html.Div(id='selection-info')
])

@callback(
    Output('scatter-chart', 'figure'),
    Output('histogram-chart', 'figure'),
    Output('box-chart', 'figure'),
    Output('selection-info', 'children'),
    Input('scatter-chart', 'selectedData'),
    Input('histogram-chart', 'selectedData'),
    Input('box-chart', 'selectedData')
)
def update_charts(scatter_selection, hist_selection, box_selection):
    filtered = df.copy()
    
    if scatter_selection:
        points = [p['x'] for p in scatter_selection['points']]
        filtered = filtered[filtered['order_frequency'].isin(points)]
    
    if hist_selection:
        points = [p['x'] for p in hist_selection['points']]
        filtered = filtered[filtered['age'].isin(points)]
    
    if box_selection:
        points = [p['x'] for p in box_selection['points']]
        filtered = filtered[filtered['city_tier_label'].isin(points)]
    
    # Scatter chart
    scatter = px.scatter(filtered, 
                         x='order_frequency', 
                         y='avg_order_value',
                         color='favorite_category',
                         title=f'Scatter ({len(filtered)} filtered)')
    
    # Histogram
    hist = px.histogram(filtered, 
                        x='age', 
                        nbins=20,
                        title='Age Distribution')
    
    # Box chart
    box = px.box(filtered, 
                 x='city_tier_label', 
                 y='avg_order_value',
                 title='Order Value by City Tier')
    
    info = f"Showing {len(filtered)} of {len(df)} customers"
    
    return scatter, hist, box, info

if __name__ == '__main__':
    app.run_server(debug=True)
```

**Reflection:**
1. How does cross-filtering enhance the analysis experience?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

2. What patterns can you discover by selecting across charts?
   ```
   Your answer: _________________________________________________
   _________________________________________________
   ```

---

# CAPSTONE EXERCISES

## Capstone Exercise 1: Comprehensive EDA

**Objective:** Perform a complete EDA on the customer dataset.

**Instructions:**
1. Generate a comprehensive statistical profile
2. Create publication-quality visualizations
3. Write key insights and recommendations

**Your Analysis Plan:**

1. **Data Profiling:**
   ```
   What variables will you analyze?
   _________________________________________________
   _________________________________________________
   ```

2. **Visualizations:**
   ```
   What visualizations will you create?
   _________________________________________________
   _________________________________________________
   ```

3. **Key Questions:**
   ```
   What questions will you try to answer?
   _________________________________________________
   _________________________________________________
   ```

**Code:**
```python
# Write your complete EDA code here
# Include:
# 1. Data loading and inspection
# 2. Univariate analysis
# 3. Bivariate analysis
# 4. Visualizations
# 5. Summary and insights

# Your code:

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
df = pd.read_csv('data/customer_data.csv')

# 1. Data inspection
print("Data Overview:")
print(f"Shape: {df.shape}")
print("\nColumns and dtypes:")
print(df.dtypes)
print("\nMissing values:")
print(df.isnull().sum())

# 2. Univariate analysis
# Numerical variables
num_cols = df.select_dtypes(include=[np.number]).columns
print("\nNumerical Summary:")
print(df[num_cols].describe())

# Categorical variables
cat_cols = df.select_dtypes(include=['object']).columns
for col in cat_cols:
    print(f"\n{col}:")
    print(df[col].value_counts())

# 3. Bivariate analysis
corr_matrix = df[num_cols].corr()
plt.figure(figsize=(10, 8))
sns.heatmap(corr_matrix, annot=True, fmt='.2f', cmap='RdBu_r', center=0)
plt.title('Correlation Heatmap')
plt.tight_layout()
plt.show()

# 4. Key visualizations
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Age distribution
sns.histplot(df['age'].dropna(), kde=True, ax=axes[0, 0])
axes[0, 0].set_title('Age Distribution')

# Order frequency by income
sns.boxplot(x='income_bracket', y='order_frequency', data=df, ax=axes[0, 1])
axes[0, 1].set_title('Order Frequency by Income')
plt.setp(axes[0, 1].xaxis.get_majorticklabels(), rotation=45)

# Rating by category
sns.violinplot(x='favorite_category', y='customer_rating', 
               data=df.dropna(subset=['customer_rating']), ax=axes[1, 0])
axes[1, 0].set_title('Rating by Category')
plt.setp(axes[1, 0].xaxis.get_majorticklabels(), rotation=45)

# Return rate vs rating
sns.regplot(x='customer_rating', y='return_rate', 
            data=df.dropna(subset=['customer_rating']), ax=axes[1, 1])
axes[1, 1].set_title('Return Rate vs Rating')

plt.tight_layout()
plt.show()

# 5. Key insights
print("\n" + "="*60)
print("KEY INSIGHTS")
print("="*60)
print("1. The dataset contains", len(df), "customers with", len(df.columns), "features")
print("2. Missing values found in:", df.isnull().sum()[df.isnull().sum() > 0].index.tolist())
print("3. Strongest correlation:", corr_matrix.unstack().sort_values(ascending=False).drop_duplicates().head(10))
```

---

## Capstone Exercise 2: Interactive Dashboard

**Objective:** Create an interactive dashboard for exploring the customer data.

**Instructions:**
1. Design a dashboard layout
2. Implement interactive filters
3. Add multiple chart types
4. Include KPI cards

**Your Dashboard Design:**

1. **Layout:**
   ```
   What will be on the dashboard?
   _________________________________________________
   _________________________________________________
   ```

2. **Filters:**
   ```
   What filters will you include?
   _________________________________________________
   _________________________________________________
   ```

3. **Charts:**
   ```
   What charts will you include?
   _________________________________________________
   _________________________________________________
   ```

**Code:**
```python
import dash
from dash import dcc, html, Input, Output, callback
import dash_bootstrap_components as dbc
import plotly.express as px
import pandas as pd

# Load data
df = pd.read_csv('data/customer_data.csv')

# Preprocess
df['city_tier_label'] = df['city_tier'].map({1: 'Metro', 2: 'Mid-size', 3: 'Small'})

# Initialize app
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.FLATLY])

# Layout
app.layout = dbc.Container([
    html.H1("Customer Insights Dashboard", className="text-center my-4"),
    
    # Filters
    dbc.Row([
        dbc.Col([
            html.Label("Income Bracket"),
            dcc.Dropdown(
                id='income-filter',
                options=[{'label': 'All', 'value': 'All'}] +
                        [{'label': i, 'value': i} for i in df['income_bracket'].unique()],
                value='All'
            )
        ], md=3),
        dbc.Col([
            html.Label("Gender"),
            dcc.Dropdown(
                id='gender-filter',
                options=[{'label': 'All', 'value': 'All'}] +
                        [{'label': g, 'value': g} for g in df['gender'].unique()],
                value='All'
            )
        ], md=3),
        dbc.Col([
            html.Label("Category"),
            dcc.Dropdown(
                id='category-filter',
                options=[{'label': 'All', 'value': 'All'}] +
                        [{'label': c, 'value': c} for c in df['favorite_category'].unique()],
                value='All'
            )
        ], md=3),
        dbc.Col([
            html.Label("City Tier"),
            dcc.Dropdown(
                id='city-filter',
                options=[{'label': 'All', 'value': 'All'}] +
                        [{'label': c, 'value': c} for c in df['city_tier_label'].unique()],
                value='All'
            )
        ], md=3)
    ], className='mb-4'),
    
    # KPI Cards
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Total Customers", className="text-muted"),
                    html.H2(id='kpi-total', className="text-primary")
                ])
            ])
        ], md=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Avg Order Value", className="text-muted"),
                    html.H2(id='kpi-order-value', className="text-success")
                ])
            ])
        ], md=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Avg Rating", className="text-muted"),
                    html.H2(id='kpi-rating', className="text-warning")
                ])
            ])
        ], md=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Return Rate", className="text-muted"),
                    html.H2(id='kpi-return', className="text-danger")
                ])
            ])
        ], md=3)
    ], className='mb-4'),
    
    # Charts
    dbc.Row([
        dbc.Col([
            dcc.Graph(id='scatter-chart')
        ], md=6),
        dbc.Col([
            dcc.Graph(id='histogram-chart')
        ], md=6)
    ]),
    
    dbc.Row([
        dbc.Col([
            dcc.Graph(id='box-chart')
        ], md=12)
    ])
], fluid=True)

# Callback
@callback(
    Output('kpi-total', 'children'),
    Output('kpi-order-value', 'children'),
    Output('kpi-rating', 'children'),
    Output('kpi-return', 'children'),
    Output('scatter-chart', 'figure'),
    Output('histogram-chart', 'figure'),
    Output('box-chart', 'figure'),
    Input('income-filter', 'value'),
    Input('gender-filter', 'value'),
    Input('category-filter', 'value'),
    Input('city-filter', 'value')
)
def update_dashboard(income, gender, category, city):
    # Filter data
    filtered = df.copy()
    
    if income != 'All':
        filtered = filtered[filtered['income_bracket'] == income]
    if gender != 'All':
        filtered = filtered[filtered['gender'] == gender]
    if category != 'All':
        filtered = filtered[filtered['favorite_category'] == category]
    if city != 'All':
        filtered = filtered[filtered['city_tier_label'] == city]
    
    # KPIs
    total = f"{len(filtered):,}"
    avg_value = f"${filtered['avg_order_value'].mean():.2f}"
    avg_rating = f"{filtered['customer_rating'].mean():.2f}" if not filtered.empty else "N/A"
    avg_return = f"{filtered['return_rate'].mean():.1f}%" if not filtered.empty else "N/A"
    
    # Scatter chart
    scatter = px.scatter(filtered, 
                         x='order_frequency', 
                         y='avg_order_value',
                         color='favorite_category',
                         title=f'Purchase Behavior ({len(filtered)} customers)',
                         template='plotly_white')
    
    # Histogram
    hist = px.histogram(filtered, 
                        x='age', 
                        nbins=20,
                        title='Age Distribution',
                        template='plotly_white')
    
    # Box chart
    box = px.box(filtered, 
                 x='income_bracket', 
                 y='avg_order_value',
                 title='Order Value by Income Bracket',
                 template='plotly_white')
    
    return total, avg_value, avg_rating, avg_return, scatter, hist, box

if __name__ == '__main__':
    app.run_server(debug=True)
```

---

# WORKBOOK ANSWER KEY

## Module 2.1 Answers

### Exercise 2.1.3 - Initial Data Inspection

**1. Average age of customers:**
```
Approximately 36-38 years (depending on random generation)
```

**2. Most common income bracket:**
```
$50K-$75K (30% of customers)
```

**3. Most popular product category:**
```
Varies by generation, typically Clothing or Electronics
```

### Exercise 2.2.1 - Understanding Distributions

**1. Most skewed distribution:**
```
Order frequency (right-skewed) - most customers order infrequently, few order often
```

**2. Approximately normal variables:**
```
Age shows bimodal distribution (two peaks), not truly normal
Customer rating shows slight left skew (more high ratings)
```

**3. Mean vs Median differences:**
```
Order frequency: Mean > Median (right-skewed)
Customer rating: Mean < Median (left-skewed)
```

### Exercise 2.2.2 - Detecting Outliers

**1. Variable with most outliers:**
```
Avg order value or Return rate (typically 3-5% outliers)
```

**2. Business explanation:**
```
High-order value outliers = premium customers
High return rate outliers = potentially dissatisfied or fraudulent
```

### Exercise 2.3.1 - Correlation Analysis

**1. Strongest positive correlation:**
```
Time on site ↔ Pages viewed (r ≈ 0.7-0.8)
Customers who spend more time view more pages
```

**2. Strongest negative correlation:**
```
Customer rating ↔ Return rate (r ≈ -0.4 to -0.5)
Customers with higher ratings return fewer items
```

**3. Highly correlated variables:**
```
Time on site and pages viewed (r > 0.7)
May cause multicollinearity in modeling
```

### Exercise 2.3.3 - Categorical vs Numerical

**1. Order value by income:**
```
Higher income = Higher order value (clear positive relationship)
```

**2. Rating by category:**
```
Varies - typically Home Goods and Electronics have higher ratings
```

---

## Module 2.2 Answers

### Exercise 2.2.3 - Statistical Plots

**1. Violin plot insights:**
```
Higher income = Higher order values
Wider distribution at higher income levels (more variation)
```

**2. Regression relationship:**
```
Negative slope: Higher rating = Lower return rate
1-point increase in rating ≈ 5-10% decrease in returns
```

### Exercise 2.2.4 - FacetGrid Patterns

**1. Gender and income patterns:**
```
Age distributions vary by income level
Higher income = older customers
Gender differences may be small
```

**2. Most informative relationships:**
```
Rating ↔ Return rate (strong business insight)
Income ↔ Order value (expected)
Time ↔ Pages (engagement metric)
```

---

## Module 2.3 Answers

### Exercise 2.3.1 - Interactive Charts

**1. Interactivity benefits:**
```
- Hover reveals exact values
- Zoom enables detail examination
- Pan enables exploration of large datasets
- Filtering isolates specific segments
```

**2. 3D advantages:**
```
- Shows three variables simultaneously
- Reveals clustering patterns
- Interactive rotation provides multiple perspectives
```

### Exercise 2.3.2 - Chart Controls

**1. Controls benefits:**
```
- Users can focus on categories of interest
- Reduces visual clutter
- Enables self-service exploration
```

### Exercise 2.3.3 - Dash Dashboard

**1. Dashboard benefits:**
```
- Real-time filtering
- Multiple views of same data
- KPI tracking
- Interactive exploration
```

---

## Capstone Exercises

### Capstone Exercise 1 - Complete EDA

**Key Insights to Include:**
1. Customer demographics profile
2. Behavioral patterns
3. Satisfaction metrics
4. Correlation discoveries
5. Segment identification
6. Business recommendations

**Sample Recommendations:**
```
1. Target high-income urban customers for premium products
2. Improve customer experience to reduce returns
3. Focus marketing on middle-aged customers (higher order frequency)
4. Optimize email engagement to increase purchase frequency
```

### Capstone Exercise 2 - Interactive Dashboard

**Required Features:**
1. Multiple filters (income, gender, category, city)
2. KPI cards (total customers, avg order, rating, return rate)
3. Multiple chart types (scatter, histogram, box)
4. Responsive layout with Bootstrap
5. Professional styling and clear labeling

---

# CERTIFICATE OF COMPLETION

## Student Workbook: Exploratory Data Analysis & Visualization

### Phase 2: Complete Hands-On Exercises

---

This workbook is designed to be completed alongside the "Exploratory Data Analysis & Visualization" series. Each exercise reinforces key concepts and builds practical skills.

**To complete this workbook:**
1. Fill in all code blocks
2. Answer all reflection questions
3. Save your work
4. Review with answer key
5. Share your portfolio

**For additional resources:**
- Source code: Available in the main series repository
- Data files: Generated using `src/generate_data.py`
- Solutions: See answer key or instructor materials

---

*Happy Learning!* 🚀
