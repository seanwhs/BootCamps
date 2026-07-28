# Detailed Slide Outline: Exploratory Data Analysis & Visualization Series

## Complete Presentation Structure (200+ Slides)

---

## PART 0: INTRODUCTION (Slides 1-25)

### Section 0.1: Welcome & Overview (Slides 1-6)

**Slide 1: Title Slide**
- Series Title: "From Raw Data to Insight: A Hands-on Data Science Visualization Series"
- Subtitle: "Phase 2: Exploratory Data Analysis & Visualization"
- Your Name/Organization
- Date

**Slide 2: What This Series Covers**
- Headline: "Complete EDA & Visualization Pipeline"
- Three key pillars:
  - Systematic Data Profiling
  - Publication-Ready Visualizations
  - Interactive Exploration Dashboards

**Slide 3: Who This Is For**
- Target audience bullets:
  - Beginner-to-intermediate data enthusiasts
  - Comfortable with basic Python
  - Want to build professional visualization skills
  - Ready to write lots of code

**Slide 4: What You'll Build**
- List of tangible deliverables:
  - Statistical profiling script
  - Gallery of publication-ready visualizations
  - Interactive exploration dashboard
  - Complete Exploratory Customer Insights Dashboard

**Slide 5: Series Architecture Diagram**
- Text-based architecture representation:
  - Phase 1 (Not in series): Data Collection & Cleaning
  - Phase 2 (This series): EDA & Visualization
    - Module 2.1: Systematic EDA
    - Module 2.2: Static Visualizations
    - Module 2.3: Interactive Exploration
    - Capstone: Customer Insights Dashboard
  - Phase 3 (Future): Feature Engineering & Modeling

**Slide 6: Learning Outcomes**
- By the end, you will be able to:
  - Profile any dataset systematically
  - Create publication-quality figures
  - Build interactive dashboards
  - Tell compelling data stories

### Section 0.2: Technical Prerequisites (Slides 7-10)

**Slide 7: Required Software**
- Python 3.8 or higher
- Code editor (VS Code recommended)
- Terminal/Command Prompt knowledge
- Basic Python syntax familiarity

**Slide 8: Our Software Stack**
- Core libraries table:
  - pandas ≥ 2.0.0
  - numpy ≥ 1.24.0
  - matplotlib ≥ 3.7.0
  - seaborn ≥ 0.12.0
  - altair ≥ 5.0.0
  - plotly ≥ 5.14.0
  - dash ≥ 2.9.0
  - scipy ≥ 1.10.0
  - jupyter ≥ 1.0.0

**Slide 9: Installation Command**
- `pip install -r requirements.txt`
- Full requirements list shown

**Slide 10: Dataset Overview**
- E-commerce customer dataset
- Demographics (age, gender, income)
- Purchase behavior (frequency, order value)
- Engagement metrics (time on site, pages)
- Satisfaction scores (ratings, returns)
- Geographic information

### Section 0.3: Series Structure (Slides 11-15)

**Slide 11: Module 2.1 - Systematic EDA**
- What you'll learn:
  - Univariate, bivariate, multivariate analysis
  - Statistical profiling
  - Correlation methodologies
  - Automated vs custom EDA

**Slide 12: Module 2.2 - Static Visualizations**
- What you'll learn:
  - Matplotlib OO API with GridSpec
  - Seaborn statistical plots
  - Altair declarative grammar
  - Publication-ready figures

**Slide 13: Module 2.3 - Interactive Exploration**
- What you'll learn:
  - Plotly Express and Graph Objects
  - Interactive features (hover, zoom, selection)
  - 3D visualizations
  - Dash web dashboards

**Slide 14: Phase 2 Capstone**
- What you'll build:
  - Exploratory Customer Insights Dashboard
  - Static report with publication figures
  - Interactive Dash application
  - Unified analytical artifact

**Slide 15: How to Follow Along**
- Each module follows consistent pattern:
  1. The Target (what we're building)
  2. The Concept (why it matters)
  3. The Implementation (code)
  4. The Verification (test it works)

### Section 0.4: Getting Started (Slides 16-20)

**Slide 16: Project Structure**
- Directory tree shown:
  - `exploratory_data_analysis_series/`
    - `src/` (source code)
    - `data/` (data files)
    - `notebooks/` (Jupyter notebooks)
    - `outputs/` (figures, reports)

**Slide 17: Virtual Environment Setup**
- Create virtual environment
- Activate it
- Install dependencies

**Slide 18: Generating the Dataset**
- `python src/generate_data.py`
- What this creates:
  - 5,000 customer records
  - 16 features
  - Realistic patterns
  - Intentional messiness

**Slide 19: Verification Script**
- `python src/verify_setup.py`
- Checks:
  - Python version
  - Directory structure
  - Module installations
  - Data file exists

**Slide 20: Ready to Begin**
- "Your environment is ready!"
- Next: Module 2.1, Part 1
- Link to start

### Section 0.5: Appendices & Primers (Slides 21-25)

**Slide 21: Appendix A - API Reference**
- Quick reference for:
  - Matplotlib
  - Seaborn
  - Altair
  - Plotly
- Common syntax and parameters

**Slide 22: Appendix B - Statistical Concepts**
- Deep dive into:
  - Descriptive statistics
  - Correlation and association
  - Hypothesis testing
  - Distributions

**Slide 23: Appendix C - Data Cleaning**
- Complete guide to:
  - Handling missing values
  - Outlier detection
  - Data type conversion
  - Feature engineering

**Slide 24: Appendix D - Deployment**
- Sharing your work:
  - Static exports
  - Dash deployment (Heroku, AWS)
  - Docker containerization
  - Security considerations

**Slide 25: Primer Overview**
- Seven primers available:
  1. Python Fundamentals
  2. NumPy Fundamentals
  3. Pandas Deep Dive
  4. Statistical Concepts
  5. Plotly & Dash
  6. Visualization Best Practices
  7. Machine Learning Fundamentals
  8. Synthetic Data

---

## MODULE 2.1: SYSTEMATIC EDA & DATA PROFILING (Slides 26-80)

### Module 2.1 Introduction (Slides 26-29)

**Slide 26: Module 2.1 Overview**
- Module Title: "Systematic EDA & Data Profiling"
- Four parts:
  - Part 1: Project Setup
  - Part 2: Univariate Analysis
  - Part 3: Bivariate & Multivariate Analysis
  - Part 4: Automated EDA vs Custom Inspection

**Slide 27: What is EDA?**
- Exploratory Data Analysis
- First step in data science workflow
- Understanding data before modeling
- Identifying patterns, anomalies, relationships

**Slide 28: The EDA Process**
- Step-by-step:
  1. Data collection and cleaning
  2. Univariate analysis (each variable)
  3. Bivariate analysis (pairs)
  4. Multivariate analysis (multiple)
  5. Visualization
  6. Hypothesis generation

**Slide 29: Why EDA Matters**
- Data quality assessment
- Feature selection guidance
- Model selection basis
- Storytelling foundation

### Part 1: Project Setup (Slides 30-39)

**Slide 30: Part 1 Overview**
- Target: Complete project environment
- Create directory structure
- Set up virtual environment
- Install dependencies
- Generate synthetic data

**Slide 31: Directory Structure**
- `src/` - Python modules
- `data/` - Raw and processed data
- `notebooks/` - Jupyter notebooks
- `outputs/` - Generated files
  - `figures/` - Visualizations
  - `reports/` - Analysis reports

**Slide 32: Virtual Environment Commands**
- Create: `python -m venv venv`
- Activate (Mac/Linux): `source venv/bin/activate`
- Activate (Windows): `venv\Scripts\activate`
- Why: Isolated dependency management

**Slide 33: requirements.txt**
- Full requirements file shown
- Core libraries: pandas, numpy
- Visualization: matplotlib, seaborn, altair, plotly
- Web: dash, dash-bootstrap-components
- Statistical: scipy, statsmodels

**Slide 34: Installing Dependencies**
- `pip install -r requirements.txt`
- Time estimate: 2-5 minutes
- Verify with `pip list`

**Slide 35: Data Generation Design**
- Why synthetic data:
  - Reproducible
  - No privacy concerns
  - Known patterns
  - Controlled messiness

**Slide 36: Data Generation Code Structure**
- Function: `generate_customer_data()`
- Parameters: `n_customers=5000`
- Sections:
  1. Demographics
  2. Geographic
  3. Engagement metrics
  4. Purchase behavior
  5. Satisfaction & loyalty
  6. Temporal data
  7. Intentional messiness

**Slide 37: Demographic Generation**
- Age: Bimodal distribution
  - 60% young adults (28 ± 5)
  - 40% middle-aged (48 ± 6)
- Gender: 48% Male, 48% Female, 4% Non-binary
- Income: Skewed, 5 brackets

**Slide 38: Behavior Generation**
- Order frequency: Income + age + engagement
- Average order value: Income-driven
- Customer rating: Order frequency influence
- Return rate: Inversely related to rating

**Slide 39: Intentional Messiness**
- Missing values:
  - Age: 5% missing
  - Rating: 7% missing
  - Email open rate: 8% missing
- Why: Real-world data is never perfect

### Part 2: Univariate Analysis (Slides 40-54)

**Slide 40: Part 2 Overview**
- Target: Univariate analysis pipeline
- Statistical summaries for each variable
- Visualizations for each variable
- Combined profiling function

**Slide 41: What is Univariate Analysis?**
- Analyzing one variable at a time
- Understanding individual characteristics
- Like getting to know each team member

**Slide 42: Univariate Statistics - Numerical**
- Center: Mean, Median, Mode
- Spread: Std Dev, Variance, Range, IQR
- Shape: Skewness, Kurtosis
- Extremes: Min, Max, Outliers

**Slide 43: Univariate Statistics - Categorical**
- Frequency counts
- Proportions/Percentages
- Cardinality (unique values)
- Missing value count

**Slide 44: UnivariateAnalyzer Class**
- Core class design
- Methods:
  - `numerical_summary()`
  - `categorical_summary()`
  - `plot_numerical()`
  - `plot_categorical()`
  - `analyze_all()`

**Slide 45: Numerical Summary Function**
- Returns DataFrame with:
  - count, missing, missing_pct
  - mean, median, mode
  - std, variance
  - min, max, range
  - q25, q75, iqr
  - skewness, kurtosis

**Slide 46: Categorical Summary Function**
- Returns DataFrame with:
  - Count per category
  - Proportion per category
  - Missing values

**Slide 47: Numerical Visualization**
- Two-panel layout:
  - Top: Histogram with KDE
  - Bottom: Boxplot
- Annotations:
  - Mean and median lines
  - Skewness value
  - Outlier count

**Slide 48: Categorical Visualization**
- Bar chart with:
  - Counts per category
  - Percentage labels (>5%)
  - Missing value annotation
  - Color-coded bars

**Slide 49: Understanding Skewness**
- Definition: Asymmetry measure
- Right-skewed: Mean > Median
- Left-skewed: Mean < Median
- Symmetric: Mean ≈ Median
- Examples from our data

**Slide 50: Understanding Kurtosis**
- Definition: Tailedness measure
- Leptokurtic (heavy tails): Kurtosis > 0
- Mesokurtic (normal): Kurtosis ≈ 0
- Platykurtic (light tails): Kurtosis < 0
- Risk implications

**Slide 51: Running the Analysis**
- Command: `python src/univariate_analysis.py`
- Output files:
  - Summary report: `univariate_report.txt`
  - Figures: `univariate_*.png`
  - CSV summaries: `numerical_*.csv`

**Slide 52: Key Findings - Demographics**
- Age: Bimodal distribution (28 and 48)
- Income: Skewed, middle-heavy
- Gender: Well-balanced
- Some missing values (5-8%)

**Slide 53: Key Findings - Behavior**
- Order frequency: Right-skewed (Pareto)
- Order value: Income-driven ($100-150 typical)
- Time on site: Exponential distribution
- Email open rate: Beta distribution

**Slide 54: Key Findings - Satisfaction**
- Rating: Moderately left-skewed
- Returns: Center around 10-15%
- Strong relationship between rating and returns
- Missing values in rating (7%)

### Part 3: Bivariate & Multivariate Analysis (Slides 55-68)

**Slide 55: Part 3 Overview**
- Target: Relationship analysis
- Pearson, Spearman correlations
- Cramér's V for categorical
- Multi-collinearity detection
- Visualizations for all relationships

**Slide 56: What is Bivariate Analysis?**
- Analyzing pairs of variables
- Understanding relationships
- Like watching how team members interact

**Slide 57: Correlation Types**
- Pearson: Linear relationships
- Spearman: Monotonic relationships
- Cramér's V: Categorical association
- Range: -1 to +1 (except V: 0 to 1)

**Slide 58: Pearson Correlation**
- Formula shown
- Assumptions:
  - Linear relationship
  - Normal distribution
  - No outliers
  - Homoscedasticity

**Slide 59: Spearman Correlation**
- Formula shown
- Based on ranks
- Handles non-linear relationships
- More robust to outliers

**Slide 60: Cramér's V**
- Formula shown
- Based on Chi-square statistic
- Measures association strength
- Interpretation: 0-1 range

**Slide 61: RelationshipAnalyzer Class**
- Core class design
- Methods:
  - `compute_pearson_correlation()`
  - `compute_spearman_correlation()`
  - `compute_categorical_association_matrix()`
  - `compute_vif()`
  - `plot_correlation_heatmap()`
  - `analyze_all()`

**Slide 62: Correlation Heatmap**
- Visual representation of correlation matrix
- Color-coded (red = positive, blue = negative)
- Annotations with values
- Upper triangle masked

**Slide 63: Scatter Plots with Regression**
- Two-panel layout
- Scatter points with transparency
- Regression line (OLS)
- Correlation annotations
- Significance testing

**Slide 64: Numerical vs Categorical**
- Box plots: Show distributions
- Violin plots: Show density shape
- Bar plots: Show means with error bars
- Statistical annotations (t-test)

**Slide 65: Multi-collinearity Detection**
- VIF (Variance Inflation Factor)
- VIF = 1: No correlation
- 1 < VIF < 5: Acceptable
- 5 < VIF < 10: Problematic
- VIF > 10: Severe

**Slide 66: Strong Correlations Found**
- Income ↔ Order Value: r ≈ 0.6
- Time on Site ↔ Pages: r ≈ 0.7
- Rating ↔ Return Rate: r ≈ -0.4
- Age ↔ Order Frequency: r ≈ 0.3

**Slide 67: Categorical Associations Found**
- Gender ↔ Category: V ≈ 0.25
- Income ↔ Category: V ≈ 0.20
- Region ↔ Category: V ≈ 0.15

**Slide 68: Multi-collinearity Findings**
- Time on Site vs Pages Viewed: VIF ≈ 6.2
- Recommendation: Use one or the other
- Other variables acceptable

### Part 4: Automated EDA vs Custom Inspection (Slides 69-80)

**Slide 69: Part 4 Overview**
- Target: Explore automated EDA tools
- Compare with custom analysis
- Learn when to use each
- Understand limits of automation

**Slide 70: Automated EDA Tools**
- Four tools covered:
  - ydata-profiling (pandas-profiling)
  - D-Tale
  - Sweetviz
  - Lux

**Slide 71: ydata-profiling**
- Most comprehensive
- Generates HTML reports
- Interactive visualizations
- Data quality alerts
- Good for documentation

**Slide 72: D-Tale**
- Interactive GUI
- In-browser exploration
- Real-time filtering
- Chart builder
- Excel-like experience

**Slide 73: Sweetviz**
- Comparison-focused
- Train vs Test
- Segment comparisons
- Visual associations
- Quick insights

**Slide 74: Lux**
- Intelligent recommendations
- Suggests visualizations
- Works in Jupyter
- Intent-based exploration
- Automatic chart generation

**Slide 75: Speed Comparison**
- Automated tools: 10-60 seconds
- Custom analysis: 30-120+ minutes
- Trade-off: Speed vs Depth
- Best approach: Both!

**Slide 76: What Automated Tools Miss**
- Missing data patterns
- Outlier context
- Segment differences
- Temporal patterns
- Interaction effects
- Business context

**Slide 77: Custom Visual Inspection**
- Five targeted investigations:
  1. Missing patterns
  2. Outlier context
  3. Segment differences
  4. Temporal patterns
  5. Interaction effects

**Slide 78: Missing Patterns Investigation**
- Visualize missingness across columns
- Detect systematic missing patterns
- Are missing values random?
- Example: Age missing in certain segments

**Slide 79: Outlier Context Investigation**
- Understand why outliers exist
- Do outliers correspond to segments?
- Example: High-value customers
- Business insights from outliers

**Slide 80: The Hybrid Approach**
- Step 1: Automated EDA (5-10 min)
- Step 2: Hypothesis generation (10-15 min)
- Step 3: Custom investigation (30-60 min)
- Step 4: Story building (30-60 min)

---

## MODULE 2.2: STATIC & DECLARATIVE VISUALIZATIONS (Slides 81-140)

### Module 2.2 Introduction (Slides 81-83)

**Slide 81: Module 2.2 Overview**
- Module Title: "Static & Declarative Visualizations"
- Three parts:
  - Part 1: Matplotlib
  - Part 2: Seaborn
  - Part 3: Altair

**Slide 82: Visualization Stack Overview**
- Three libraries, three approaches:
  - Matplotlib: Total control, imperative
  - Seaborn: Statistical, high-level
  - Altair: Declarative, grammar-based

**Slide 83: When to Use Each**
- Matplotlib: Publication-ready, custom layouts
- Seaborn: Statistical summaries, quick plots
- Altair: Interactive, reproducible, web-ready

### Part 1: Matplotlib (Slides 84-101)

**Slide 84: Part 1 Overview**
- Target: Master Matplotlib's OO API
- Figure and Axes architecture
- GridSpec layouts
- Fine-tuned formatting
- Publication-quality figures

**Slide 85: Matplotlib Architecture**
- Figure: The canvas (the house)
- Axes: Individual plots (rooms)
- Artists: Visual elements (furniture)
- GridSpec: Layout management (floor plan)

**Slide 86: Why Object-Oriented API?**
- Total control over elements
- Modify after creation
- Complex layouts
- Share axes between subplots
- Professional results

**Slide 87: Figure vs Pyplot**
- Pyplot: Quick, limited
- OO API: Verbose, powerful
- Example comparison
- Recommendation: Use OO for production

**Slide 88: GridSpec Basics**
- `gridspec.GridSpec(nrows, ncols)`
- `fig.add_subplot(gs[row, col])`
- Spanning: `gs[row:row+span, col:col+span]`
- Width/height ratios

**Slide 89: GridSpec Examples**
- Simple grid: 2 rows, 2 cols
- Unequal sizes: width_ratios
- Unequal heights: height_ratios
- Nested grids: GridSpecFromSubplotSpec

**Slide 90: Axes Formatting**
- Titles and labels
- Ticks and tick formatting
- Grid lines
- Spines (borders)
- Legends

**Slide 91: Custom Tick Control**
- `MultipleLocator()` for fixed intervals
- `FormatStrFormatter()` for formatting
- AutoMinorLocator for minor ticks
- Rotation: `tick_params(rotation=45)`

**Slide 92: Annotations**
- `ax.annotate()` for arrows
- `ax.text()` for plain text
- `ax.axvspan()` for highlighting
- BBox properties for backgrounds

**Slide 93: MatplotlibFigureBuilder Class**
- Core class design
- Methods:
  - `create_gridspec_layout()`
  - `add_subplot_from_gridspec()`
  - `format_axes()`
  - `add_annotation()`
  - `add_highlight_region()`
  - `save_figure()`

**Slide 94: FigureTemplates Class**
- Pre-built templates:
  - Distribution grid
  - Correlation heatmap
  - Time series panel

**Slide 95: Distribution Grid Template**
- Grid of histograms with KDE
- Consistent formatting
- Statistics annotations
- Configurable columns

**Slide 96: Correlation Heatmap Template**
- Professional heatmap
- Annotations
- Colorbar
- Masked upper triangle

**Slide 97: Time Series Panel Template**
- Multi-panel time series
- Moving averages
- Consistent axes
- Professional styling

**Slide 98: Advanced Layout - Magazine Style**
- Complex GridSpec layout
- Multiple plot types
- Spanning subplots
- Professional dashboard

**Slide 99: Advanced Layout - Nested Grids**
- GridSpec within GridSpec
- Maximum control
- Complex compositions
- Example: 2x2 inside larger grid

**Slide 100: Spine Customization**
- Hide spines: `spines['top'].set_visible(False)`
- Move spines: `set_position('center')`
- Custom colors and widths
- Scientific plot style

**Slide 101: Publication Quality**
- DPI: 300+
- Format: PNG, PDF, SVG
- bbox_inches: 'tight'
- Consistent styling
- Typefaces and sizes

### Part 2: Seaborn (Slides 102-120)

**Slide 102: Part 2 Overview**
- Target: Statistical visualizations
- Seaborn as Matplotlib supercharger
- Distribution, categorical, regression plots
- Multi-plot grids

**Slide 103: What Seaborn Provides**
- Statistical transformations
- Beautiful defaults
- Multi-plot management
- Pandas integration

**Slide 104: Seaborn vs Matplotlib**
- Seaborn = Automatic transmission
- Matplotlib = Manual transmission
- Seaborn handles complexity
- Matplotlib gives control

**Slide 105: Distribution Plots**
- `sns.histplot()`: Histogram with KDE
- `sns.kdeplot()`: Kernel density estimate
- `sns.ecdfplot()`: Empirical CDF
- `sns.displot()`: Figure-level distribution

**Slide 106: Categorical Plots**
- `sns.boxplot()`: Box and whisker
- `sns.violinplot()`: Violin with KDE
- `sns.boxenplot()`: Enhanced box plot
- `sns.pointplot()`: Point estimates
- `sns.barplot()`: Bar with error bars
- `sns.countplot()`: Count of categories

**Slide 107: Regression Plots**
- `sns.regplot()`: Scatter with regression
- `sns.lmplot()`: Faceted regression
- `sns.residplot()`: Residual analysis
- Confidence bands

**Slide 108: Matrix Plots**
- `sns.heatmap()`: Correlation heatmap
- `sns.clustermap()`: Hierarchical heatmap
- Annotations and custom colormaps

**Slide 109: FacetGrid**
- Create grid of subplots
- By categorical variables
- Map any plot function
- Professional multi-panel figures

**Slide 110: PairGrid**
- Matrix of pairwise relationships
- Diagonal: Distributions
- Upper/Lower: Different plots
- Customizable functions

**Slide 111: SeabornVisualizer Class**
- Core class design
- Methods:
  - `plot_histogram_with_kde()`
  - `plot_violin_with_box()`
  - `plot_pairwise_distribution()`
  - `plot_categorical_comparison()`
  - `plot_regression()`
  - `create_facet_grid()`

**Slide 112: Histogram with KDE**
- Two-panel layout
- Statistical annotations
- Mean/median lines
- Outlier detection

**Slide 113: Violin with Box**
- Combines KDE and boxplot
- Shows full distribution
- Quartile annotations
- Strip plot overlay

**Slide 114: Pairwise Distribution**
- PairGrid matrix
- Upper: Regression
- Lower: Scatter
- Diagonal: Histogram

**Slide 115: Categorical Comparison**
- Box, violin, bar, point
- Group statistics
- Error bars
- Multiple categories

**Slide 116: Regression with Confidence**
- Scatter with regression line
- 95% confidence band
- Correlation annotation
- Faceting option

**Slide 117: Correlation Heatmap**
- Professional heatmap
- Significance annotations
- Custom colormap
- Masked upper triangle

**Slide 118: FacetGrid Example**
- Distribution by category
- Multiple subplots
- Consistent axes
- Professional presentation

**Slide 119: Statistical Annotations**
- T-test annotations
- Effect sizes
- Confidence intervals
- Significance markers (*, **, ***)

**Slide 120: Custom Palettes**
- Sequential: Blues, viridis
- Diverging: RdBu_r, coolwarm
- Qualitative: Set2, husl
- Custom palettes

### Part 3: Altair (Slides 121-140)

**Slide 121: Part 3 Overview**
- Target: Declarative visualization
- Grammar of Graphics
- Vega-Lite specification
- Interactive charts
- Reproducible analysis

**Slide 122: Declarative vs Imperative**
- Imperative: Step-by-step instructions
- Declarative: Describe what you want
- Altair = Declarative
- Matplotlib = Imperative

**Slide 123: The Grammar of Graphics**
- Six components:
  1. Data
  2. Marks
  3. Encodings
  4. Scales
  5. Guides
  6. Facets

**Slide 124: Altair Chart Structure**
- `alt.Chart(data)`
- `.mark_type()` (point, bar, line)
- `.encode()` (x, y, color, size)
- `.properties()` (title, width, height)
- `.interactive()` (zoom, pan)

**Slide 125: Mark Types**
- `mark_point()`: Scatter
- `mark_bar()`: Bar chart
- `mark_line()`: Line chart
- `mark_area()`: Area chart
- `mark_rect()`: Heatmap
- `mark_boxplot()`: Box plot
- `mark_text()`: Labels

**Slide 126: Encoding Types**
- Position: `x`, `y`, `x2`, `y2`
- Color: `color`
- Size: `size`
- Shape: `shape`
- Opacity: `opacity`
- Tooltip: `tooltip`
- Facet: `facet`, `row`, `column`

**Slide 127: Data Types**
- `:Q` - Quantitative (numeric)
- `:N` - Nominal (categorical)
- `:O` - Ordinal (ordered)
- `:T` - Temporal (date/time)

**Slide 128: Transformations**
- `transform_aggregate()`: Group by
- `transform_bin()`: Binning
- `transform_filter()`: Filtering
- `transform_calculate()`: New columns
- `transform_density()`: KDE

**Slide 129: Interactive Features**
- `selection_interval()`: Brush selection
- `selection_point()`: Click selection
- `selection_single()`: Single selection
- `bind` controls: Sliders, dropdowns

**Slide 130: AltairVisualizer Class**
- Core class design
- Methods:
  - `create_scatter_plot()`
  - `create_bar_chart()`
  - `create_histogram()`
  - `create_box_plot()`
  - `create_heatmap()`
  - `create_interactive_dashboard()`

**Slide 131: Scatter Plot Example**
- Color encoding
- Size encoding
- Tooltips
- Interactive zoom
- Legend

**Slide 132: Bar Chart Example**
- Aggregation
- Color grouping
- Horizontal orientation
- Stacked option
- Labels

**Slide 133: Histogram Example**
- Binning
- KDE overlay
- Color grouping
- Density scaling
- Interactive brushing

**Slide 134: Box Plot Example**
- Categorical grouping
- Quartile visualization
- Outlier display
- Color encoding

**Slide 135: Heatmap Example**
- Two categorical variables
- Aggregation
- Color scale
- Text annotations

**Slide 136: Interactive Dashboard**
- Linked selection
- Cross-filtering
- Dropdown filters
- Real-time updates

**Slide 137: Multi-Panel Figures**
- `vconcat()`: Vertical
- `hconcat()`: Horizontal
- `facet()`: Grid
- `layer()`: Overlay

**Slide 138: Saving Altair Charts**
- HTML: `chart.save('chart.html')`
- JSON: `chart.save('chart.json')`
- PNG: Requires altair_saver
- Interactive in any browser

**Slide 139: Altair vs Matplotlib/Seaborn**
- Altair: Interactive, web-ready
- Matplotlib: Publication, custom
- Seaborn: Statistical, easy
- Choose based on use case

**Slide 140: Altair Best Practices**
- Start with simple chart
- Add encodings gradually
- Use transformations wisely
- Test interactivity
- Export to HTML for sharing

---

## MODULE 2.3: INTERACTIVE DATA EXPLORATION (Slides 141-175)

### Module 2.3 Introduction (Slides 141-143)

**Slide 141: Module 2.3 Overview**
- Module Title: "Interactive Data Exploration"
- Two parts:
  - Part 1: Plotly Express and Graph Objects
  - Part 2: Dash Web Dashboards

**Slide 142: Why Interactive Visualization?**
- Users explore on their own terms
- Engagement with data
- Pattern discovery
- Flexible analysis
- Self-service analytics

**Slide 143: Interactive vs Static**
- Static: Fixed story, publication-ready
- Interactive: Flexible, exploratory
- Both have their place
- Best: Combine both approaches

### Part 1: Plotly (Slides 144-162)

**Slide 144: Part 1 Overview**
- Target: Interactive charts with Plotly
- Plotly Express (high-level)
- Graph Objects (low-level)
- 3D visualizations
- Dynamic controls

**Slide 145: Plotly Ecosystem**
- Plotly Express: Quick, one-line charts
- Graph Objects: Fine-grained control
- Dash: Web dashboards
- All work together

**Slide 146: Plotly Express Basics**
- `px.scatter()`: Scatter plot
- `px.line()`: Line chart
- `px.bar()`: Bar chart
- `px.histogram()`: Histogram
- `px.box()`: Box plot
- All are interactive by default

**Slide 147: Plotly Express Parameters**
- `data_frame`: Source data
- `x`, `y`: Column names
- `color`: Color encoding
- `size`: Size encoding
- `hover_data`: Tooltip data
- `title`: Chart title
- `template`: Style template

**Slide 148: Graph Objects Basics**
- `go.Figure()`: Create figure
- `fig.add_trace()`: Add data
- `go.Scatter()`: Scatter trace
- `go.Bar()`: Bar trace
- `go.Histogram()`: Histogram
- Full control over every element

**Slide 149: Graph Objects vs Express**
- Express: Quick, less control
- Graph Objects: More code, full control
- Choose based on needs
- Express is often sufficient

**Slide 150: Interactive Features**
- Hover: Tooltips with data
- Zoom: Click and drag
- Pan: Shift-drag
- Selection: Click, lasso, box
- Legend: Toggle traces

**Slide 151: Custom Hover Templates**
- `hovertemplate`: Custom HTML
- Variables: `%{x}`, `%{y}`, `%{text}`
- `<b>` for bold
- `<extra></extra>`: Hide trace name
- Multiple lines

**Slide 152: Layout Customization**
- `fig.update_layout()`
- Title, axes, legend
- Width, height
- Margins, templates
- Hover mode

**Slide 153: 3D Visualizations**
- `px.scatter_3d()`: 3D scatter
- `px.line_3d()`: 3D line
- `px.surface_3d()`: 3D surface
- Rotation and zoom
- Color and size encoding

**Slide 154: 3D Scatter Example**
- Three numerical columns
- Color encoding
- Size encoding
- Interactive rotation

**Slide 155: 3D Surface Example**
- Pivot table
- Color gradient
- Axis labels
- Interactive rotation

**Slide 156: Dynamic Controls**
- Sliders: `sliders` parameter
- Dropdowns: `updatemenus` parameter
- Animation: `frames` parameter
- Real-time updates

**Slide 157: Slider Example**
- Sequential data
- Steps with labels
- Current value display
- Play/Pause buttons

**Slide 158: Dropdown Example**
- Filter categories
- Update visibility
- Button labels
- Interactive selection

**Slide 159: Animation Example**
- Time series data
- Frames for each time point
- Play/Pause controls
- Smooth transitions

**Slide 160: PlotlyVisualizer Class**
- Core class design
- Methods:
  - `create_scatter_plot()`
  - `create_histogram()`
  - `create_bar_chart()`
  - `create_heatmap()`
  - `create_box_plot()`
  - `create_3d_scatter()`
  - `create_chart_with_slider()`

**Slide 161: Saving Plotly Charts**
- HTML: `fig.write_html()`
- JSON: `fig.write_json()`
- PNG: `fig.write_image()`
- Requires kaleido for images

**Slide 162: Plotly in Jupyter**
- `fig.show()` displays
- Interactive by default
- Works in notebooks
- Also works in HTML

### Part 2: Dash (Slides 163-175)

**Slide 163: Part 2 Overview**
- Target: Interactive web dashboards
- Dash architecture
- Layout and components
- Callbacks
- Deploying dashboards

**Slide 164: What is Dash?**
- Web framework for analytics
- 100% Python
- No JavaScript required
- Interactive web apps
- Built on Plotly

**Slide 165: Dash Architecture**
- Layout: HTML structure
- Components: UI elements
- Callbacks: Interactive logic
- Server: Flask backend
- Browser: User interface

**Slide 166: Basic Dash App**
- Import dash
- Create app
- Define layout
- Define callbacks
- Run server

**Slide 167: Core Components (dcc)**
- `dcc.Graph`: Plotly charts
- `dcc.Dropdown`: Selection
- `dcc.Slider`: Range selection
- `dcc.RangeSlider`: Two-value selection
- `dcc.Input`: Text input
- `dcc.Store`: Data cache

**Slide 168: HTML Components (html)**
- `html.Div`: Container
- `html.H1`: Heading
- `html.P`: Paragraph
- `html.Button`: Button
- `html.Table`: Table
- Structured like HTML

**Slide 169: Dash Bootstrap Components**
- Professional styling
- Responsive design
- `dbc.Container`, `dbc.Row`, `dbc.Col`
- `dbc.Card`, `dbc.Button`
- Many Bootstrap themes

**Slide 170: Callbacks**
- `@callback` decorator
- Input: Triggers callback
- Output: Updates component
- State: Non-triggering input
- Multiple inputs and outputs

**Slide 171: Callback Example**
- Filter dropdown changes chart
- Input: Dropdown value
- Output: Graph figure
- Process data, return figure

**Slide 172: Cross-Filtering**
- Select in one chart
- Filters another chart
- Multiple charts linked
- Real-time updates

**Slide 173: Drill-Down**
- Click on data point
- Filter details
- Show specific data
- Reveal deeper insights

**Slide 174: Dash Dashboard Structure**
- Header with title
- Global filters
- KPI cards
- Multiple charts
- Interactive controls

**Slide 175: Deploying Dash**
- Local: `app.run_server(debug=True)`
- Heroku: Git push
- AWS EC2: Gunicorn + Nginx
- Docker: Containerized deployment
- Dash Enterprise: Paid

---

## PHASE 2 CAPSTONE (Slides 176-195)

### Capstone Introduction (Slides 176-179)

**Slide 176: Capstone Overview**
- Target: Complete analytical artifact
- Synthesize all modules
- Static report + interactive dashboard
- End-to-end analysis

**Slide 177: The Analytical Artifact**
- Static Report: Publication-ready
- Interactive Dashboard: Exploratory
- Unified Application: Both combined
- Professional, deployable product

**Slide 178: The Workflow**
- Raw Data
- Statistical Profiling
- Static Report (Matplotlib, Seaborn, Altair)
- Interactive Dashboard (Plotly, Dash)
- Unified Application

**Slide 179: Capstone Deliverables**
- Comprehensive static report
- Publication-quality figures
- Interactive Plotly dashboard
- Unified Dash application
- Deployable analytical product

### Capstone Implementation (Slides 180-190)

**Slide 180: CapstoneReportGenerator**
- Core class design
- Generates full report
- Creates all visualizations
- Saves to organized structure

**Slide 181: Executive Summary**
- Dataset overview
- Key metrics
- Key insights
- Recommendations

**Slide 182: Statistical Profile**
- Numerical variables summary
- Categorical variables summary
- Missing values analysis
- Distribution statistics

**Slide 183: Key Findings**
- Top correlations
- Segment analysis
- Age group insights
- Income insights
- Category preferences

**Slide 184: Static Visualizations**
- Distribution grid
- Correlation heatmap
- Histograms
- Box plots
- Scatter plots

**Slide 185: Altair Visualizations**
- Interactive scatter plots
- Bar charts
- Histograms
- Interactive dashboard

**Slide 186: CapstoneDashboard**
- Unified Dash application
- Four tabs:
  1. Overview
  2. Interactive
  3. Static Report
  4. Customer Profiling

**Slide 187: Overview Tab**
- KPI cards
- Demographics chart
- Purchase behavior chart
- Engagement chart

**Slide 188: Interactive Tab**
- Global filters
- Interactive scatter
- Interactive histogram
- Interactive box plot

**Slide 189: Report Tab**
- Full report display
- Scrollable content
- Well-formatted text

**Slide 190: Customer Profiling Tab**
- Customer lookup
- Demographics view
- Purchase history
- Engagement metrics
- Segment classification

### Capstone Execution (Slides 191-195)

**Slide 191: Running the Capstone**
- Step 1: `python src/capstone_report.py`
- Step 2: `python src/capstone_dashboard.py`
- Or: `python run_capstone.py`

**Slide 192: Output Files**
- Report: `customer_insights_report.txt`
- Figures: `figures/*.png`
- Altair charts: `altair/*.html`
- Dashboard: Interactive web app

**Slide 193: Dashboard Features**
- Real-time filtering
- Cross-filtering
- Customer lookup
- Static report viewing
- Professional styling

**Slide 194: Capstone Completion**
- You have built:
  - Complete static report
  - Publication-quality figures
  - Interactive dashboard
  - Unified analytical product

**Slide 195: What You've Accomplished**
- Systematic EDA skills
- Three visualization libraries
- Interactive dashboards
- Professional analytical artifact
- Ready for Phase 3

---

## APPENDICES & PRIMERS (Slides 196-210)

### Appendices Overview (Slides 196-202)

**Slide 196: Appendix A - API Reference**
- Matplotlib quick reference
- Seaborn quick reference
- Altair quick reference
- Plotly quick reference
- Common patterns

**Slide 197: Appendix B - Statistical Concepts**
- Descriptive statistics
- Correlation and association
- Hypothesis testing
- Distributions
- Transformations

**Slide 198: Appendix C - Data Cleaning**
- Missing values
- Outliers
- Data types
- Duplicates
- Feature engineering

**Slide 199: Appendix D - Deployment**
- Static exports
- Dash deployment
- Docker deployment
- Security
- Monitoring

**Slide 200: Appendix E - Performance**
- Pandas optimization
- Out-of-core processing
- Parallel processing
- Memory management
- File formats

**Slide 201: Appendix F - Troubleshooting**
- Environment errors
- Data loading errors
- Processing errors
- Visualization errors
- Dash errors

**Slide 202: Appendix G - Project Templates**
- Project structure
- Configuration files
- Code templates
- Quick start commands
- Deployment commands

### Primers Overview (Slides 203-210)

**Slide 203: Primer 1 - Python Fundamentals**
- Variables and data types
- Functions and scope
- Lists and iterables
- Dictionaries and JSON
- Exception handling

**Slide 204: Primer 2 - NumPy Fundamentals**
- Array creation
- Array operations
- Indexing and slicing
- Broadcasting
- Statistical operations

**Slide 205: Primer 3 - Pandas Deep Dive**
- Series and DataFrame
- Indexing and selection
- Data cleaning
- Group operations
- Time series

**Slide 206: Primer 4 - Statistical Concepts**
- Descriptive statistics
- Probability distributions
- Hypothesis testing
- Correlation and regression
- Statistical power

**Slide 207: Primer 5 - Plotly and Dash**
- Plotly Express
- Graph Objects
- Interactive features
- Dash architecture
- Callbacks

**Slide 208: Primer 6 - Visualization Best Practices**
- Grammar of Graphics
- Chart selection
- Color theory
- Data-ink ratio
- Accessibility

**Slide 209: Primer 7 - Machine Learning**
- Supervised learning
- Unsupervised learning
- Feature engineering
- Model selection
- Model evaluation

**Slide 210: Primer 8 - Synthetic Data**
- Why synthetic data
- Generation methods
- Validation
- Use cases
- Best practices

---

## CONCLUSION (Slides 211-215)

**Slide 211: Series Recap**
- Module 2.1: Systematic EDA
- Module 2.2: Static Visualizations
- Module 2.3: Interactive Exploration
- Capstone: Customer Insights Dashboard

**Slide 212: Skills Acquired**
- Project setup and structure
- Systematic EDA and profiling
- Publication-quality visualizations
- Interactive dashboards
- End-to-end analytics

**Slide 213: Real-World Application**
- Apply framework to any dataset
- Customize visualizations
- Build dashboards for stakeholders
- Continue to Phase 3

**Slide 214: Next Steps**
- Phase 3: Feature Engineering
- Phase 3: Machine Learning Modeling
- Phase 3: Model Deployment
- Continue your data science journey

**Slide 215: Thank You**
- Thank you for completing the series
- You are now a data visualization expert
- Apply your skills
- Keep learning and building
- Contact/Resources

---

## TOTAL SLIDES: 215+

This outline provides a comprehensive structure for teaching the entire series with:

- **Clear progression** from foundations to advanced topics
- **Logical organization** with modules, parts, and sections
- **Consistent slide counts** per topic area
- **Actionable content** with code examples and commands
- **Complete coverage** of all material from the series

---

**Note:** To convert this outline to actual slides, you can:
1. Copy each slide's content into PowerPoint/Google Slides
2. Use a tool like Marp to render Markdown as slides
3. Use Quarto or RISE for Jupyter-based presentations

Would you like me to provide any specific section in more detail or convert this to a different format?
