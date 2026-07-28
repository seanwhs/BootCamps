# Student Notes: Exploratory Data Analysis & Visualization

## Phase 2: Complete Lecture Notes

---

#### How to Use These Notes

These notes are designed to accompany the "Exploratory Data Analysis & Visualization" video series. They provide:

- **Key concepts** defined and explained
- **Code snippets** from the lectures
- **Visual diagrams** (described in text)
- **Important takeaways** highlighted
- **Space** for your own annotations

Follow along with the videos and fill in your own notes in the provided spaces.

---

# MODULE 2.1: SYSTEMATIC EDA & DATA PROFILING

## Part 1: Project Setup & Data Generation

### 1.1 Why We Need Structure

**Key Concept:** *A well-organized project saves time and prevents confusion.*

**Standard Data Science Project Structure:**
```
project/
├── src/          # Source code (modules, scripts)
├── data/         # Raw and processed data
├── notebooks/    # Jupyter notebooks for exploration
├── outputs/      # Generated files (figures, reports)
└── requirements.txt  # Python dependencies
```

**Why This Matters:**
- Reproducibility
- Collaboration
- Version control
- Professional presentation

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.2 Virtual Environments

**Key Concept:** *Virtual environments isolate project dependencies.*

```bash
# Create virtual environment
python -m venv venv

# Activate (Mac/Linux)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

**Why This Matters:**
- Prevents dependency conflicts
- Ensures reproducibility
- Clean installation

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.3 Our Dataset

**Key Concept:** *Synthetic data mimics real-world patterns without privacy concerns.*

**Dataset Features:**

| Category | Variables |
|----------|-----------|
| Demographics | age, gender, income_bracket |
| Geographic | country, region, city_tier |
| Engagement | time_on_site, pages_viewed, email_open_rate |
| Purchase | order_frequency, avg_order_value, favorite_category |
| Satisfaction | customer_rating, return_rate |
| Temporal | account_created, last_purchase |

**Data Generation Design:**
- Bimodal age distribution (young + middle-aged)
- Income-driven spending
- Intentional missing values (5-8%)
- Realistic correlations built-in

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.4 Initial Data Inspection

**Key Concept:** *Always inspect your data before analysis.*

**Essential Pandas Commands:**

```python
# Shape and info
df.shape          # (rows, columns)
df.info()         # Column info with dtypes

# Preview
df.head()         # First 5 rows
df.tail()         # Last 5 rows

# Summary statistics
df.describe()     # Numerical summary
df.describe(include='object')  # Categorical summary

# Missing values
df.isnull().sum() # Count missing per column
df.isnull().sum().sum()  # Total missing

# Unique values
df['column'].unique()
df['column'].value_counts()
```

**Key Questions to Ask:**
1. How many rows and columns?
2. What data types do we have?
3. Are there missing values? Where?
4. What are the distributions?

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Part 2: Univariate Analysis

### 2.1 What is Univariate Analysis?

**Key Concept:** *Understanding each variable on its own.*

**Think of It Like:**
- Getting to know each team member individually
- Understanding their strengths and weaknesses
- Before seeing how they work together

**Two Types of Variables:**

**Numerical Variables:**
- Continuous: age, order_frequency
- Discrete: pages_viewed
- Statistics: mean, median, std, min, max

**Categorical Variables:**
- Nominal: gender, favorite_category
- Ordinal: income_bracket
- Statistics: frequencies, proportions

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.2 Numerical Statistics

**Key Concept:** *Statistics that describe the center, spread, and shape of data.*

**Measures of Center:**

| Measure | Definition | When to Use |
|---------|------------|-------------|
| **Mean** | Average | Symmetric distributions |
| **Median** | Middle value | Skewed distributions |
| **Mode** | Most frequent | Categorical data |

**Measures of Spread:**

| Measure | Definition | Interpretation |
|---------|------------|----------------|
| **Std Dev** | Average distance from mean | 68% within ±1σ |
| **Variance** | Squared std dev | Mathematical convenience |
| **Range** | Max - Min | Simple, sensitive to outliers |
| **IQR** | Q3 - Q1 | Robust to outliers |

**Measures of Shape:**

| Measure | Definition | Interpretation |
|---------|------------|----------------|
| **Skewness** | Asymmetry | 0 = symmetric, >0 = right-skewed, <0 = left-skewed |
| **Kurtosis** | Tailedness | 0 = normal, >0 = heavy tails, <0 = light tails |

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.3 Categorical Statistics

**Key Concept:** *Understanding the distribution of categories.*

**Key Metrics:**

```python
# Frequency counts
df['gender'].value_counts()

# Proportions
df['gender'].value_counts(normalize=True)

# Cross-tabulation
pd.crosstab(df['gender'], df['income_bracket'])
```

**Cardinality:**
- Number of unique values
- Low cardinality: < 10 (gender, income)
- High cardinality: > 50 (customer_id, region)
- Too high: Consider grouping

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.4 Visualization for Univariate Analysis

**Key Concept:** *Visual inspection reveals patterns numbers miss.*

**Numerical Visualizations:**

```python
# Histogram - shows distribution shape
sns.histplot(df['age'], bins=30, kde=True)

# Boxplot - shows quartiles and outliers
sns.boxplot(y=df['age'])

# KDE - smooth density estimate
sns.kdeplot(df['age'], fill=True)
```

**Categorical Visualizations:**

```python
# Bar chart - shows frequencies
df['gender'].value_counts().plot(kind='bar')

# Pie chart - shows proportions (use sparingly)
df['gender'].value_counts().plot(kind='pie')
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Part 3: Bivariate & Multivariate Analysis

### 3.1 What is Bivariate Analysis?

**Key Concept:** *Understanding relationships between pairs of variables.*

**Think of It Like:**
- Watching how team members interact
- Seeing who works well together
- Identifying conflicts

**Three Types of Relationships:**

1. **Numerical vs Numerical:**
   - Scatter plots
   - Correlation coefficients

2. **Categorical vs Categorical:**
   - Contingency tables
   - Cramér's V

3. **Numerical vs Categorical:**
   - Box plots
   - Violin plots

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 3.2 Correlation

**Key Concept:** *Measures the strength and direction of relationships.*

**Pearson Correlation (r):**
- Measures *linear* relationships
- Range: -1 to +1
- Assumes normality and linearity
- Sensitive to outliers

**Spearman Correlation (ρ):**
- Measures *monotonic* relationships
- Based on ranks
- Handles non-linear relationships
- More robust to outliers

**Interpretation:**

| Value | Strength |
|-------|----------|
| 0.00 - 0.19 | Very weak |
| 0.20 - 0.39 | Weak |
| 0.40 - 0.59 | Moderate |
| 0.60 - 0.79 | Strong |
| 0.80 - 1.00 | Very strong |

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 3.3 Categorical Association

**Key Concept:** *Cramér's V measures association between categorical variables.*

**Formula:**
```
V = sqrt(χ² / (n * min(r-1, c-1)))
```

**Interpretation:**

| Value | Strength |
|-------|----------|
| 0.00 - 0.10 | Very weak |
| 0.10 - 0.25 | Moderate |
| 0.25 - 0.40 | Strong |
| > 0.40 | Very strong |

**When to Use:**
- Two or more categorical variables
- Testing association
- Feature selection

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 3.4 Multi-Collinearity

**Key Concept:** *When variables are highly correlated with each other.*

**VIF (Variance Inflation Factor):**
```
VIF = 1 / (1 - R²)
```

**Interpretation:**

| VIF | Severity |
|-----|----------|
| 1 | No correlation |
| 1-5 | Acceptable |
| 5-10 | Problematic |
| > 10 | Severe |

**Why It Matters:**
- Affects model stability
- Inflates standard errors
- Complicates interpretation

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Part 4: Automated EDA vs Custom Inspection

### 4.1 Automated EDA Tools

**Key Concept:** *Tools that generate comprehensive EDA reports quickly.*

**Popular Tools:**

1. **ydata-profiling:**
   - Most comprehensive
   - Interactive HTML reports
   - Data quality alerts
   - Good for documentation

2. **Sweetviz:**
   - Comparison-focused
   - Train vs test
   - Segment comparisons

3. **D-Tale:**
   - Interactive GUI
   - Excel-like experience
   - Real-time exploration

4. **Lux:**
   - Intelligent recommendations
   - Suggests visualizations
   - Works in Jupyter

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 4.2 What Automated Tools Miss

**Key Concept:** *Automation is fast but lacks context and intuition.*

**What Automated Tools Miss:**

1. **Missing Data Patterns:**
   - Are missing values random or systematic?
   - Do they correlate with other variables?

2. **Outlier Context:**
   - Why do outliers exist?
   - Do they represent meaningful segments?

3. **Segment Differences:**
   - How do groups differ?
   - What business insights exist?

4. **Temporal Patterns:**
   - Are there trends or seasonality?
   - How have patterns changed?

5. **Interaction Effects:**
   - How do variables combine?
   - What are the joint effects?

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 4.3 The Hybrid Approach

**Key Concept:** *Use both automation and custom analysis.*

**The Workflow:**

```
Step 1: Automated EDA (5-10 min)
    └── Run ydata-profiling or Sweetviz
    └── Get overview, identify issues
    └── Note interesting patterns

Step 2: Hypothesis Generation (10-15 min)
    └── Based on automated results
    └── Formulate questions
    └── Plan custom investigation

Step 3: Custom Investigation (30-60 min)
    └── Create targeted visualizations
    └── Explore segment differences
    └── Investigate patterns in context

Step 4: Story Building (30-60 min)
    └── Synthesize findings
    └── Create publication-ready visuals
    └── Build final narrative
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

# MODULE 2.2: STATIC & DECLARATIVE VISUALIZATIONS

## Part 1: Matplotlib

### 1.1 Matplotlib Architecture

**Key Concept:** *Matplotlib is built on an object-oriented architecture.*

**The Object Hierarchy:**

```
Figure (The Canvas)
    └── Axes (Individual Plots)
        ├── Artists (Visual Elements)
        │   ├── Lines
        │   ├── Text
        │   └── Shapes
        ├── XAxis
        │   ├── Ticks
        │   └── Labels
        ├── YAxis
        ├── Spines (Borders)
        └── Title/Legend
```

**Two Approaches:**

```python
# Pyplot (Quick, limited)
plt.plot(x, y)
plt.title("Title")
plt.show()

# OO API (Full control)
fig, ax = plt.subplots()
ax.plot(x, y)
ax.set_title("Title")
fig.savefig("figure.png")
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.2 GridSpec Layouts

**Key Concept:** *GridSpec gives you total control over subplot layouts.*

**Basic GridSpec:**

```python
import matplotlib.gridspec as gridspec

# Create grid
gs = gridspec.GridSpec(2, 3, figure=fig)

# Add subplots
ax1 = fig.add_subplot(gs[0, 0])  # Row 0, Col 0
ax2 = fig.add_subplot(gs[0, 1:3])  # Row 0, Cols 1-2
ax3 = fig.add_subplot(gs[1, 0:2])  # Row 1, Cols 0-1
ax4 = fig.add_subplot(gs[1, 2])    # Row 1, Col 2
```

**Advanced Features:**
- `width_ratios`: Unequal column widths
- `height_ratios`: Unequal row heights
- Nested GridSpecs

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.3 Axes Formatting

**Key Concept:** *Professional formatting makes figures publication-ready.*

**Essential Formatting:**

```python
# Titles and labels
ax.set_title("Title", fontsize=14, fontweight='bold')
ax.set_xlabel("X Label", fontsize=12)
ax.set_ylabel("Y Label", fontsize=12)

# Ticks
ax.tick_params(labelsize=10, rotation=45)
ax.xaxis.set_major_locator(MultipleLocator(10))

# Grid
ax.grid(True, alpha=0.3, linestyle='--')

# Spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# Legend
ax.legend(loc='best', frameon=True)
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.4 Publication Quality

**Key Concept:** *Figures should be polished and professional.*

**Checklist:**

- [ ] Consistent font sizes (title > labels > ticks)
- [ ] Clear axis labels with units
- [ ] Legend if needed
- [ ] High contrast colors
- [ ] No overlapping elements
- [ ] Proper aspect ratio
- [ ] High resolution (300+ DPI)

**Saving Figures:**

```python
plt.savefig('figure.png', 
            dpi=300,           # Publication quality
            bbox_inches='tight', # Remove excess whitespace
            facecolor='white',  # White background
            transparent=False)  # Non-transparent
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Part 2: Seaborn

### 2.1 What is Seaborn?

**Key Concept:** *Seaborn = Matplotlib + Statistical Superpowers.*

**What Seaborn Provides:**

1. **Statistical Transformations:**
   - KDE, histograms
   - Confidence intervals
   - Regression lines

2. **Beautiful Defaults:**
   - Color palettes
   - Grid styling
   - Font sizes

3. **Multi-Plot Management:**
   - FacetGrid
   - PairGrid
   - Figure-level functions

4. **Pandas Integration:**
   - Works with DataFrames
   - Handles missing values

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.2 Distribution Plots

**Key Concept:** *Visualize the distribution of numerical variables.*

**Key Functions:**

```python
# Histogram with KDE
sns.histplot(data=df, x='age', bins=30, kde=True)

# KDE only
sns.kdeplot(data=df, x='age', fill=True)

# ECDF (Empirical CDF)
sns.ecdfplot(data=df, x='age')

# Figure-level distribution
sns.displot(data=df, x='age', kind='hist', col='gender')
```

**Parameters to Know:**
- `bins`: Number of bins
- `kde`: Add KDE overlay
- `fill`: Fill area under curve
- `bw_adjust`: Bandwidth adjustment

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.3 Categorical Plots

**Key Concept:** *Compare distributions across categories.*

**Key Functions:**

```python
# Box plot
sns.boxplot(data=df, x='income_bracket', y='avg_order_value')

# Violin plot (shows distribution shape)
sns.violinplot(data=df, x='income_bracket', y='avg_order_value')

# Boxen plot (for large datasets)
sns.boxenplot(data=df, x='income_bracket', y='avg_order_value')

# Point plot (mean with error bars)
sns.pointplot(data=df, x='income_bracket', y='avg_order_value')

# Bar plot (aggregated values)
sns.barplot(data=df, x='income_bracket', y='avg_order_value')

# Count plot (category frequencies)
sns.countplot(data=df, x='favorite_category')
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.4 Multi-Plot Grids

**Key Concept:** *Create multiple plots arranged in a grid.*

**FacetGrid:**

```python
# Create grid
g = sns.FacetGrid(df, col='income_bracket', row='gender', height=4)

# Map plot function
g.map(sns.histplot, 'age')

# Customize
g.set_axis_labels('Age', 'Count')
g.fig.suptitle('Age Distribution by Income and Gender')
```

**PairGrid:**

```python
# Pairwise relationships
g = sns.PairGrid(df[['age', 'order_frequency', 'avg_order_value']])

# Upper: scatter
g.map_upper(sns.scatterplot)

# Lower: density
g.map_lower(sns.kdeplot)

# Diagonal: histogram
g.map_diag(sns.histplot)
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.5 Color Palettes

**Key Concept:** *Color communicates information effectively.*

**Types of Palettes:**

1. **Qualitative (Categorical):**
   - `sns.color_palette('Set2')`
   - `sns.color_palette('husl')`
   - Distinct colors for categories

2. **Sequential (Numeric):**
   - `sns.color_palette('viridis')`
   - `sns.color_palette('Blues')`
   - Light to dark

3. **Diverging (Numeric, Centered):**
   - `sns.color_palette('RdBu_r')`
   - `sns.color_palette('coolwarm')`
   - Two colors with neutral middle

**Colorblind-Friendly Options:**
- `'colorblind'`
- `'Set2'`
- `'viridis'`

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Part 3: Altair

### 3.1 What is Altair?

**Key Concept:** *Declarative visualization using the Grammar of Graphics.*

**Declarative vs Imperative:**

```python
# Imperative (Matplotlib)
# Step-by-step instructions
fig, ax = plt.subplots()
ax.plot(x, y)
ax.set_title("Title")
plt.show()

# Declarative (Altair)
# Describe what you want
alt.Chart(data).mark_point().encode(
    x='age:Q',
    y='value:Q'
)
```

**The Grammar of Graphics:**
1. Data
2. Marks (geometric shapes)
3. Encodings (visual channels)
4. Scales
5. Guides
6. Facets

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 3.2 Basic Altair Charts

**Key Concept:** *Chart = Data + Mark + Encoding.*

**Basic Structure:**

```python
alt.Chart(data).mark_type().encode(
    x='column:Q',
    y='column:Q',
    color='column:N'
).properties(
    title='Chart Title',
    width=600,
    height=400
).interactive()
```

**Common Marks:**

| Mark | Purpose |
|------|---------|
| `mark_point()` | Scatter plot |
| `mark_circle()` | Scatter (circles) |
| `mark_bar()` | Bar chart |
| `mark_line()` | Line chart |
| `mark_area()` | Area chart |
| `mark_rect()` | Heatmap |
| `mark_boxplot()` | Box plot |
| `mark_text()` | Labels |

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 3.3 Encodings and Data Types

**Key Concept:** *Encodings map data to visual channels.*

**Encoding Types:**

```python
# Position
x=alt.X('column:Q', title='Label')
y=alt.Y('column:Q', title='Label')

# Color
color=alt.Color('column:N', scale=alt.Scale(scheme='category10'))

# Size
size=alt.Size('column:Q')

# Shape
shape=alt.Shape('column:N')

# Tooltip
tooltip=alt.Tooltip(['col1:Q', 'col2:N'])
```

**Data Types:**

| Suffix | Type | Example |
|--------|------|---------|
| `:Q` | Quantitative | `age:Q` |
| `:N` | Nominal | `gender:N` |
| `:O` | Ordinal | `income:O` |
| `:T` | Temporal | `date:T` |

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 3.4 Interactive Features

**Key Concept:** *Altair charts are interactive by default.*

**Built-in Interactivity:**
- Hover tooltips
- Zoom and pan
- Legend filtering

**Custom Interactions:**

```python
# Brush selection
selection = alt.selection_interval()
chart = chart.add_selection(selection)

# Click selection
selection = alt.selection_point()
chart = chart.add_selection(selection)

# Conditional color
color = alt.condition(
    selection,
    alt.ColorValue('red'),
    alt.ColorValue('lightgray')
)
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 3.5 Combining Charts

**Key Concept:** *Multiple charts can be combined and linked.*

**Combination Methods:**

```python
# Layer (overlay)
layered = alt.layer(chart1, chart2)

# Vertical concatenation
vconcat = alt.vconcat(chart1, chart2)

# Horizontal concatenation
hconcat = alt.hconcat(chart1, chart2)

# Facet (grid)
facet = chart.facet(facet='category:N', columns=3)
```

**Linking Charts:**
```python
# Shared selection
selection = alt.selection_interval()

chart1 = chart1.add_selection(selection)
chart2 = chart2.add_selection(selection)

# Cross-filtering
color = alt.condition(
    selection,
    alt.ColorValue('red'),
    alt.ColorValue('lightgray')
)
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

# MODULE 2.3: INTERACTIVE DATA EXPLORATION

## Part 1: Plotly

### 1.1 Plotly Ecosystem

**Key Concept:** *Plotly creates interactive, web-based visualizations.*

**Two Main APIs:**

1. **Plotly Express (px):**
   - High-level
   - One-line charts
   - Great for common types

2. **Graph Objects (go):**
   - Low-level
   - Full control
   - Complex charts

**Plotly vs Static Libraries:**

| Aspect | Plotly | Matplotlib/Seaborn |
|--------|--------|-------------------|
| Interactivity | Yes | No |
| Web Integration | Native | Limited |
| Code Length | Short | Medium |
| Publication | Good | Best |

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.2 Plotly Express

**Key Concept:** *Quick, interactive charts with minimal code.*

**Basic Chart Types:**

```python
import plotly.express as px

# Scatter
px.scatter(df, x='age', y='value', color='category')

# Line
px.line(df, x='date', y='value', color='category')

# Bar
px.bar(df, x='category', y='value')

# Histogram
px.histogram(df, x='value', nbins=30)

# Box
px.box(df, x='category', y='value')

# Heatmap
px.imshow(correlation_matrix)

# 3D
px.scatter_3d(df, x='x', y='y', z='z', color='category')
```

**Common Parameters:**
- `x`, `y`: Columns for axes
- `color`: Color encoding
- `size`: Size encoding
- `hover_data`: Tooltip data
- `title`: Chart title
- `template`: Style template

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.3 Graph Objects

**Key Concept:** *Low-level control for custom charts.*

**Basic Structure:**

```python
import plotly.graph_objects as go

# Create figure
fig = go.Figure()

# Add trace
fig.add_trace(go.Scatter(
    x=df['x'],
    y=df['y'],
    mode='markers+lines',
    name='Trace Name',
    marker=dict(size=10, color='red'),
    line=dict(width=2)
))

# Customize layout
fig.update_layout(
    title='Chart Title',
    xaxis_title='X Axis',
    yaxis_title='Y Axis',
    template='plotly_white',
    width=800,
    height=600
)

# Show
fig.show()
```

**Common Trace Types:**
- `go.Scatter`: Lines, markers, or both
- `go.Bar`: Bar charts
- `go.Histogram`: Histograms
- `go.Box`: Box plots
- `go.Heatmap`: Heatmaps

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.4 Interactive Features

**Key Concept:** *Interactivity is built into Plotly charts.*

**Built-in Features:**
- Hover tooltips
- Zoom and pan
- Legend toggling
- Selection (click, lasso, box)

**Custom Hover:**

```python
fig.update_traces(
    hovertemplate='<b>%{x}</b><br>Value: %{y}<extra></extra>'
)
```

**Custom Controls:**

```python
# Dropdown
fig.update_layout(
    updatemenus=[dict(
        type='dropdown',
        buttons=[
            dict(label='Option 1', method='update', args=[{'visible': [True, False]}]),
            dict(label='Option 2', method='update', args=[{'visible': [False, True]}])
        ]
    )]
)

# Slider
fig.update_layout(
    sliders=[dict(
        steps=[
            dict(method='update', args=[{'visible': [True, False]}], label='Step 1'),
            dict(method='update', args=[{'visible': [False, True]}], label='Step 2')
        ]
    )]
)
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 1.5 3D Visualizations

**Key Concept:** *3D plots reveal patterns in three dimensions.*

**3D Scatter:**

```python
px.scatter_3d(df, x='age', y='order_frequency', z='avg_order_value',
              color='income_bracket', size='customer_rating')
```

**3D Surface:**

```python
# Create pivot table first
pivot = df.pivot_table(values='value', index='col1', columns='col2')

fig = go.Figure(data=[go.Surface(
    z=pivot.values,
    x=pivot.columns,
    y=pivot.index,
    colorscale='Viridis'
)])
```

**3D Features:**
- Rotation (click and drag)
- Zoom (scroll)
- Hover for values
- Automatic scaling

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Part 2: Dash

### 2.1 Dash Architecture

**Key Concept:** *Dash = Python web apps for data visualization.*

**The Architecture:**

```
Browser (User Interface)
    ↑ ↓
Dash Server (Python)
    ├── Layout (HTML Components)
    │   ├── dcc.Graph (Plotly charts)
    │   ├── dcc.Dropdown (Filters)
    │   ├── dcc.Slider (Range controls)
    │   └── html components (Structure)
    └── Callbacks (Interactivity)
        ├── Input (User actions)
        └── Output (Component updates)
```

**Benefits:**
- 100% Python
- No JavaScript required
- Interactive web apps
- Professional dashboards

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.2 Basic Dash App

**Key Concept:** *Layout + Callbacks = Interactive App.*

**Minimal App:**

```python
import dash
from dash import dcc, html, Input, Output

app = dash.Dash(__name__)

app.layout = html.Div([
    html.H1("Title"),
    dcc.Dropdown(id='dropdown', options=options, value=default),
    dcc.Graph(id='chart')
])

@callback(
    Output('chart', 'figure'),
    Input('dropdown', 'value')
)
def update_chart(value):
    filtered = df[df['col'] == value]
    return px.scatter(filtered, x='x', y='y')

if __name__ == '__main__':
    app.run_server(debug=True)
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.3 Core Components

**Key Concept:** *Components are the building blocks of your layout.*

**Dash Core Components (dcc):**

| Component | Purpose |
|-----------|---------|
| `dcc.Graph` | Plotly charts |
| `dcc.Dropdown` | Selection dropdown |
| `dcc.Slider` | Numeric slider |
| `dcc.RangeSlider` | Range selection |
| `dcc.RadioItems` | Radio buttons |
| `dcc.Checklist` | Checkboxes |
| `dcc.Input` | Text input |
| `dcc.Store` | Data caching |
| `dcc.Loading` | Loading indicator |

**HTML Components (html):**

| Component | Purpose |
|-----------|---------|
| `html.Div` | Container |
| `html.H1` | Heading |
| `html.P` | Paragraph |
| `html.Button` | Button |
| `html.Table` | Table |

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.4 Callbacks

**Key Concept:** *Callbacks connect user interaction to updates.*

**Basic Callback:**

```python
@callback(
    Output('output-id', 'property'),
    Input('input-id', 'value')
)
def update_function(value):
    # Process value
    return result
```

**Multiple Inputs:**

```python
@callback(
    Output('chart', 'figure'),
    Input('dropdown', 'value'),
    Input('slider', 'value')
)
def update_chart(dropdown_value, slider_value):
    filtered = df[df['col'] == dropdown_value]
    filtered = filtered[filtered['value'] <= slider_value]
    return px.scatter(filtered, x='x', y='y')
```

**Multiple Outputs:**

```python
@callback(
    Output('chart1', 'figure'),
    Output('chart2', 'figure'),
    Output('text', 'children'),
    Input('dropdown', 'value')
)
def update_all(value):
    fig1 = create_chart1(value)
    fig2 = create_chart2(value)
    text = f"Showing: {value}"
    return fig1, fig2, text
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.5 Cross-Filtering

**Key Concept:** *Selecting in one chart filters another.*

**Cross-Filtering Pattern:**

```python
# Shared selection
@callback(
    Output('chart1', 'figure'),
    Output('chart2', 'figure'),
    Input('chart1', 'selectedData'),
    Input('chart2', 'selectedData')
)
def update_charts(selection1, selection2):
    filtered = df.copy()
    
    if selection1:
        # Filter based on selection1
        points = [p['x'] for p in selection1['points']]
        filtered = filtered[filtered['col1'].isin(points)]
    
    if selection2:
        # Filter based on selection2
        points = [p['x'] for p in selection2['points']]
        filtered = filtered[filtered['col2'].isin(points)]
    
    return create_chart1(filtered), create_chart2(filtered)
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### 2.6 Drill-Down

**Key Concept:** *Click on data to see more details.*

**Drill-Down Pattern:**

```python
@callback(
    Output('detail-chart', 'figure'),
    Output('detail-text', 'children'),
    Input('main-chart', 'clickData')
)
def drill_down(click_data):
    if click_data is None:
        return overview_figure(), "Click a point for details"
    
    # Extract data from click
    point = click_data['points'][0]
    category = point['x']
    
    # Filter data
    filtered = df[df['category'] == category]
    
    # Create detail view
    fig = create_detail(filtered)
    text = f"Showing details for: {category}"
    
    return fig, text
```

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

# CAPSTONE NOTES

## Capstone: Exploratory Customer Insights Dashboard

### Overview

**Key Concept:** *Synthesize all skills into a complete analytical product.*

**The Two Components:**

1. **Static Report:**
   - Publication-quality figures
   - Statistical profiling
   - Key insights
   - Recommendations

2. **Interactive Dashboard:**
   - Real-time filtering
   - Multiple charts
   - Cross-filtering
   - Customer lookup

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### Static Report Structure

**Key Concept:** *A comprehensive report with text and figures.*

**Report Sections:**

1. **Executive Summary:**
   - Dataset overview
   - Key metrics
   - Top insights
   - Recommendations

2. **Statistical Profile:**
   - Numerical summaries
   - Categorical summaries
   - Missing data analysis

3. **Key Findings:**
   - Top correlations
   - Segment analysis
   - Business insights

4. **Visualizations:**
   - Distribution plots
   - Correlation heatmap
   - Relationship plots

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### Interactive Dashboard Structure

**Key Concept:** *A web app for exploring the data.*

**Dashboard Tabs:**

1. **Overview:**
   - KPI cards
   - Demographics
   - Purchase behavior
   - Engagement

2. **Interactive:**
   - Global filters
   - Real-time charts
   - Data exploration

3. **Static Report:**
   - Full report text
   - Scrollable view

4. **Customer Profiling:**
   - Customer lookup
   - Demographics
   - Purchase history
   - Engagement
   - Segment classification

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### Deployment Considerations

**Key Concept:** *Share your analysis with stakeholders.*

**Deployment Options:**

1. **Local Sharing:**
   - Run on local server
   - Share URL
   - Quick demos

2. **Cloud Deployment:**
   - Heroku (easiest)
   - AWS EC2 (more control)
   - Docker (consistent)

3. **Static Export:**
   - HTML files
   - No server needed
   - Limited interactivity

**Your Notes:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

# QUICK REFERENCE CARDS

## Pandas Cheat Sheet

```python
# Read/Write
pd.read_csv('file.csv')
df.to_csv('output.csv', index=False)

# Inspect
df.head()
df.info()
df.describe()
df.shape
df.columns
df.dtypes

# Select
df['col']
df[['col1', 'col2']]
df.loc[0]
df.iloc[0]
df[df['col'] > value]

# Modify
df['new'] = df['a'] + df['b']
df.drop('col', axis=1)
df.dropna()
df.fillna(0)

# Group
df.groupby('col').mean()
df.groupby('col').agg(['mean', 'sum'])
df.pivot_table(index='col1', values='col2')

# Merge
pd.merge(df1, df2, on='key')
pd.concat([df1, df2])
```

## Matplotlib Cheat Sheet

```python
# Create figure
fig, ax = plt.subplots(figsize=(10, 6))

# Plot types
ax.plot(x, y)          # Line
ax.scatter(x, y)       # Scatter
ax.bar(x, y)           # Bar
ax.hist(data)          # Histogram
ax.boxplot(data)       # Box

# Customize
ax.set_title('Title')
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.grid(True)
ax.legend()

# Save
plt.savefig('figure.png', dpi=300, bbox_inches='tight')
plt.show()
```

## Seaborn Cheat Sheet

```python
# Distribution
sns.histplot(data=df, x='col', kde=True)
sns.kdeplot(data=df, x='col', fill=True)

# Categorical
sns.boxplot(data=df, x='cat', y='num')
sns.violinplot(data=df, x='cat', y='num')
sns.barplot(data=df, x='cat', y='num')
sns.countplot(data=df, x='cat')

# Regression
sns.regplot(data=df, x='x', y='y')
sns.lmplot(data=df, x='x', y='y', hue='cat')

# Grids
sns.pairplot(df, hue='cat')
sns.FacetGrid(df, col='cat').map(sns.histplot, 'col')
sns.heatmap(corr_matrix, annot=True)
```

## Altair Cheat Sheet

```python
# Basic chart
alt.Chart(df).mark_point().encode(
    x='col1:Q',
    y='col2:Q',
    color='cat:N'
).interactive()

# Marks
.mark_point()
.mark_bar()
.mark_line()
.mark_circle()
.mark_boxplot()

# Encodings
x=alt.X('col:Q', title='Label')
color=alt.Color('col:N', scale=alt.Scale(scheme='category10'))
tooltip=['col1:Q', 'col2:N']

# Combine
alt.layer(chart1, chart2)
alt.vconcat(chart1, chart2)
alt.hconcat(chart1, chart2)
```

## Plotly Cheat Sheet

```python
# Express
px.scatter(df, x='col1', y='col2', color='cat')
px.line(df, x='date', y='value', color='cat')
px.bar(df, x='cat', y='value')
px.histogram(df, x='col', nbins=30)
px.box(df, x='cat', y='value')
px.scatter_3d(df, x='x', y='y', z='z')

# Graph Objects
go.Figure()
fig.add_trace(go.Scatter(x=x, y=y, mode='markers'))
fig.update_layout(title='Title', xaxis_title='X', yaxis_title='Y')

# Interactivity
fig.update_traces(hovertemplate='Value: %{y}<extra></extra>')
fig.update_layout(hovermode='closest')

# Save
fig.write_html('file.html')
fig.write_image('file.png')
```

## Dash Cheat Sheet

```python
# App
app = dash.Dash(__name__)

# Layout
app.layout = html.Div([
    html.H1("Title"),
    dcc.Dropdown(id='dropdown', options=options, value=default),
    dcc.Graph(id='chart')
])

# Callback
@callback(
    Output('chart', 'figure'),
    Input('dropdown', 'value')
)
def update(value):
    return create_chart(value)

# Run
if __name__ == '__main__':
    app.run_server(debug=True)

# Components
dcc.Graph(id='chart')
dcc.Dropdown(id='dropdown', options=[{'label': 'A', 'value': 'a'}])
dcc.Slider(id='slider', min=0, max=100, step=1, value=50)
dcc.RangeSlider(id='range', min=0, max=100, value=[25, 75])
html.Div(children)
html.H1('Heading')
html.P('Paragraph')
```

---

# APPENDIX: COMMAND REFERENCE

## Terminal Commands

```bash
# Environment
python -m venv venv
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows
pip install -r requirements.txt
pip list

# Files
ls -la          # List files (Mac/Linux)
dir             # List files (Windows)
cd directory
mkdir directory
touch file.py   # Create file (Mac/Linux)
type nul > file.py  # Create file (Windows)

# Python
python script.py
python -m ipykernel install --user --name=venv --display-name="Python (venv)"
jupyter notebook
jupyter lab
```

## Git Commands

```bash
# Initialize
git init
git add .
git commit -m "Initial commit"

# Remote
git remote add origin https://github.com/username/repo.git
git push -u origin main

# Branches
git branch feature
git checkout feature
git merge feature
```

## Deployment Commands

```bash
# Heroku
heroku login
heroku create app-name
git push heroku main
heroku open

# Docker
docker build -t myapp .
docker run -d -p 8050:8050 --name myapp myapp
docker logs myapp
docker stop myapp
docker rm myapp
```

---

# STUDY CHECKLIST

## Module 2.1: Systematic EDA

- [ ] I understand project structure
- [ ] I can set up a virtual environment
- [ ] I can generate and load data
- [ ] I understand univariate analysis
- [ ] I can calculate descriptive statistics
- [ ] I understand correlation
- [ ] I can create correlation heatmaps
- [ ] I know the difference between EDA approaches

## Module 2.2: Static Visualizations

- [ ] I understand Matplotlib's OO API
- [ ] I can create GridSpec layouts
- [ ] I can format axes professionally
- [ ] I understand Seaborn's statistical plots
- [ ] I can create FacetGrids
- [ ] I understand Altair's declarative syntax
- [ ] I can create interactive Altair charts
- [ ] I know when to use each library

## Module 2.3: Interactive Exploration

- [ ] I understand Plotly Express
- [ ] I can create Plotly Graph Objects
- [ ] I understand interactive features
- [ ] I can create 3D visualizations
- [ ] I understand Dash architecture
- [ ] I can build a Dash layout
- [ ] I can write Dash callbacks
- [ ] I can deploy a Dash app

## Capstone

- [ ] I can generate a static report
- [ ] I can create publication-quality figures
- [ ] I can build an interactive dashboard
- [ ] I understand cross-filtering
- [ ] I can create customer profiles
- [ ] I can deploy my work

---

*Keep these notes handy as you work through the series. Add your own annotations and examples to reinforce your learning.*
