# Quiz & Test Bank: Exploratory Data Analysis & Visualization

## Phase 2: Assessment Resource

---

#### How to Use This Assessment Bank

This assessment resource contains:

1. **Module Quizzes** (10-15 questions each) - For checking understanding after each module
2. **Module Tests** (20-25 questions each) - For comprehensive assessment after each module
3. **Cumulative Midterm** (50 questions) - For assessing understanding across Modules 2.1-2.2
4. **Final Exam** (75 questions) - For comprehensive assessment of all material
5. **Practical Exam** - Hands-on coding assessment
6. **Answer Keys** - Complete with explanations

---

# MODULE 2.1 QUIZ: SYSTEMATIC EDA & DATA PROFILING

## Part 1: Multiple Choice (10 Questions)

**1. What is the primary purpose of Exploratory Data Analysis (EDA)?**

A) To build machine learning models
B) To understand patterns and relationships in data before modeling
C) To clean and preprocess data
D) To deploy models to production

**Answer: B**
*Explanation: EDA is the process of understanding data characteristics, patterns, and relationships before formal modeling or hypothesis testing.*

---

**2. Which of the following is NOT a measure of central tendency?**

A) Mean
B) Median
C) Standard Deviation
D) Mode

**Answer: C**
*Explanation: Standard deviation is a measure of dispersion (spread), not central tendency.*

---

**3. A right-skewed distribution has which characteristic?**

A) Mean < Median
B) Mean > Median
C) Mean = Median
D) No relationship between mean and median

**Answer: B**
*Explanation: In a right-skewed distribution, the tail extends to the right, pulling the mean higher than the median.*

---

**4. What does a Pearson correlation coefficient of -0.85 indicate?**

A) Strong positive linear relationship
B) Strong negative linear relationship
C) Weak positive linear relationship
D) No relationship

**Answer: B**
*Explanation: -0.85 is close to -1, indicating a strong negative linear relationship. As one variable increases, the other decreases.*

---

**5. Which missing data pattern indicates that missingness depends on observed data?**

A) MCAR (Missing Completely at Random)
B) MAR (Missing at Random)
C) MNAR (Missing Not at Random)
D) All of the above

**Answer: B**
*Explanation: MAR means the probability of missing data depends on observed variables, not the missing values themselves.*

---

**6. What is the Interquartile Range (IQR) used for?**

A) Measuring central tendency
B) Measuring spread robustly
C) Measuring correlation
D) Measuring skewness

**Answer: B**
*Explanation: IQR (Q3-Q1) measures spread while being robust to outliers.*

---

**7. Cramér's V is used to measure association between:**

A) Two numerical variables
B) Two categorical variables
C) One numerical and one categorical variable
D) More than two variables

**Answer: B**
*Explanation: Cramér's V measures association between categorical variables.*

---

**8. A VIF (Variance Inflation Factor) score of 8 indicates:**

A) No multicollinearity
B) Moderate multicollinearity
C) High multicollinearity
D) Perfect multicollinearity

**Answer: C**
*Explanation: VIF > 5-10 indicates problematic multicollinearity.*

---

**9. Which automated EDA tool provides an interactive GUI for data exploration?**

A) ydata-profiling
B) Sweetviz
C) D-Tale
D) Lux

**Answer: C**
*Explanation: D-Tale provides an interactive GUI-based exploration experience.*

---

**10. What is the 68-95-99.7 rule related to?**

A) Correlation coefficients
B) Normal distribution
C) Categorical distributions
D) Missing data patterns

**Answer: B**
*Explanation: The 68-95-99.7 rule states that 68%, 95%, and 99.7% of data falls within 1, 2, and 3 standard deviations of the mean in a normal distribution.*

---

## Part 2: True/False (5 Questions)

**11. Spearman correlation is more robust to outliers than Pearson correlation.**

**Answer: True**
*Explanation: Spearman uses ranks, making it less sensitive to outliers than Pearson.*

---

**12. In a perfectly symmetric distribution, the mean equals the median.**

**Answer: True**
*Explanation: In symmetric distributions, the mean and median are equal.*

---

**13. Missing values should always be removed from a dataset.**

**Answer: False**
*Explanation: Missing values should be handled appropriately (imputation, indicators, etc.) depending on the pattern and context.*

---

**14. Cramér's V ranges from 0 to 1.**

**Answer: True**
*Explanation: Cramér's V ranges from 0 (no association) to 1 (perfect association).*

---

**15. Automated EDA tools can completely replace manual data exploration.**

**Answer: False**
*Explanation: Automated tools are useful for initial exploration but cannot replace human intuition, domain knowledge, and custom investigation.*

---

## Part 3: Short Answer (5 Questions)

**16. Explain the difference between MCAR, MAR, and MNAR missing data patterns.**

**Answer:**
- **MCAR (Missing Completely at Random):** Missingness is independent of both observed and unobserved data. Example: random survey non-response.
- **MAR (Missing at Random):** Missingness depends on observed data but not the missing values themselves. Example: women are more likely to skip income questions.
- **MNAR (Missing Not at Random):** Missingness depends on the missing values themselves. Example: high-income individuals are less likely to report income.

---

**17. When would you use Spearman correlation instead of Pearson correlation?**

**Answer:**
Use Spearman when:
- The relationship is non-linear but monotonic
- Data is ordinal
- Assumptions of normality are violated
- Outliers are present
- The data is heavily skewed

---

**18. What is the hybrid approach to EDA and why is it recommended?**

**Answer:**
The hybrid approach combines automated EDA tools with custom visual inspection:
1. **Automated EDA (5-10 min):** Quick overview, identify issues, generate hypotheses
2. **Custom Investigation (30-60 min):** Deep dive into specific patterns, context, domain insights
3. **Story Building (30-60 min):** Synthesize findings into a coherent narrative

It's recommended because automated tools provide speed and breadth while custom inspection provides depth and context that automation cannot deliver.

---

**19. How do you detect outliers using the IQR method?**

**Answer:**
1. Calculate Q1 (25th percentile) and Q3 (75th percentile)
2. Calculate IQR = Q3 - Q1
3. Calculate bounds: Lower = Q1 - 1.5 × IQR, Upper = Q3 + 1.5 × IQR
4. Values below lower bound or above upper bound are considered outliers

---

**20. What is multicollinearity and why is it problematic for modeling?**

**Answer:**
Multicollinearity occurs when predictor variables are highly correlated with each other. It is problematic because:
- It inflates the variance of coefficient estimates
- It makes coefficients unstable and sensitive to small data changes
- It makes it difficult to interpret individual variable effects
- It can reduce model prediction accuracy
- It violates assumptions of linear models (but is less problematic for tree-based models)

---

# MODULE 2.2 QUIZ: STATIC & DECLARATIVE VISUALIZATIONS

## Part 1: Multiple Choice (10 Questions)

**1. In Matplotlib's object-oriented API, what is the relationship between Figure and Axes?**

A) Figure contains multiple Axes
B) Axes contains multiple Figures
C) They are the same thing
D) They are unrelated

**Answer: A**
*Explanation: A Figure (the canvas) can contain multiple Axes (individual subplots).*

---

**2. Which Matplotlib component controls the layout of subplots?**

A) Axes
B) Figure
C) GridSpec
D) Artist

**Answer: C**
*Explanation: GridSpec controls the arrangement and sizing of subplots within a Figure.*

---

**3. Which Seaborn function would you use to create a grid of histograms by category?**

A) `sns.histplot()`
B) `sns.FacetGrid()`
C) `sns.PairGrid()`
D) `sns.boxplot()`

**Answer: B**
*Explanation: FacetGrid creates a grid of plots based on categorical variables.*

---

**4. What does the "data-ink ratio" concept (from Tufte) advocate for?**

A) Using more colors in visualizations
B) Maximizing the proportion of ink used to display data
C) Using 3D effects
D) Adding decorative elements

**Answer: B**
*Explanation: Tufte's data-ink ratio advocates maximizing the proportion of ink used to display data while minimizing non-data ink.*

---

**5. Which Altair mark type would you use to create a heatmap?**

A) `mark_point()`
B) `mark_bar()`
C) `mark_rect()`
D) `mark_line()`

**Answer: C**
*Explanation: `mark_rect()` is used for rectangular heatmap cells.*

---

**6. In Altair, what does the `:Q` suffix indicate in an encoding?**

A) Qualitative data
B) Quantitative data
C) Ordinal data
D) Temporal data

**Answer: B**
*Explanation: `:Q` indicates quantitative (numerical) data.*

---

**7. Which of the following is NOT a Gestalt principle applied to visualization?**

A) Proximity
B) Similarity
C) Continuity
D) Randomness

**Answer: D**
*Explanation: Randomness is not a Gestalt principle. The Gestalt principles relevant to visualization include Proximity, Similarity, Continuity, Closure, and Figure-Ground.*

---

**8. What is the primary advantage of Seaborn over Matplotlib?**

A) More customization options
B) Built-in statistical transformations
C) Faster rendering
D) Better 3D support

**Answer: B**
*Explanation: Seaborn provides built-in statistical transformations (KDE, confidence intervals, etc.) that Matplotlib lacks.*

---

**9. In Altair, what is the purpose of `transform_aggregate()`?**

A) To filter data
B) To group and aggregate data
C) To create new columns
D) To sort data

**Answer: B**
*Explanation: `transform_aggregate()` performs grouping and aggregation, similar to pandas `groupby().agg()`.*

---

**10. Which color palette is generally recommended for color-blind accessibility?**

A) Rainbow
B) Red-Green
C) Viridis
D) Pastel

**Answer: C**
*Explanation: Viridis is perceptually uniform and color-blind friendly.*

---

## Part 2: True/False (5 Questions)

**11. Seaborn is built on top of Matplotlib.**

**Answer: True**
*Explanation: Seaborn extends Matplotlib with higher-level functions and better defaults.*

---

**12. GridSpec can create subplots with different sizes.**

**Answer: True**
*Explanation: GridSpec allows unequal row heights and column widths using `height_ratios` and `width_ratios`.*

---

**13. Altair charts cannot be exported to HTML.**

**Answer: False**
*Explanation: Altair charts can be exported to HTML, JSON, and PNG (with dependencies).*

---

**14. In Matplotlib, modifying a slice of a DataFrame is always safe.**

**Answer: False**
*Explanation: Modifying a slice can trigger SettingWithCopyWarning and lead to unintended behavior. Always use `.loc` or `.copy()`.*

---

**15. Seaborn's PairGrid shows distributions on the diagonal.**

**Answer: True**
*Explanation: PairGrid typically shows distributions (histograms or KDE) on the diagonal and relationships off-diagonal.*

---

## Part 3: Short Answer (5 Questions)

**16. Explain the difference between imperative (Matplotlib) and declarative (Altair) visualization approaches.**

**Answer:**
- **Imperative (Matplotlib):** You give step-by-step instructions on HOW to build the visualization ("create figure, add axes, plot this data, set title..."). The focus is on the process.
- **Declarative (Altair):** You describe WHAT you want to see ("I want a scatter plot with x, y, color"). The focus is on the result, and the library handles the implementation.

---

**17. What are the key components of the Grammar of Graphics as implemented in Altair?**

**Answer:**
1. **Data:** The source data
2. **Marks:** Geometric shapes (points, bars, lines, areas)
3. **Encodings:** Mapping data to visual channels (x, y, color, size, shape)
4. **Scales:** Mapping data values to visual values
5. **Guides:** Legends, axis labels, titles
6. **Facets:** Creating multiple views based on data

---

**18. When would you use each of the three visualization libraries covered in this module?**

**Answer:**
- **Matplotlib:** When you need total control over every element of the figure, create complex custom layouts, or need publication-quality static figures.
- **Seaborn:** When you want statistical visualizations quickly, need distribution plots, categorical plots, or multi-plot grids with minimal code.
- **Altair:** When you want interactive, web-ready visualizations, need reproducibility, or prefer a declarative grammar-based approach.

---

**19. What is the data-ink ratio and why does it matter?**

**Answer:**
Data-ink ratio is the proportion of ink (visual elements) used to display data versus total ink in a visualization. It matters because:
- It helps create clear, focused visualizations
- It reduces visual clutter that distracts from the data
- It improves readability and comprehension
- It follows Tufte's principle of "maximize data-ink, minimize non-data-ink"

---

**20. How do you create a multi-panel figure with Matplotlib using GridSpec?**

**Answer:**
```python
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(12, 8))
gs = gridspec.GridSpec(2, 3, width_ratios=[1.5, 1, 1])

# Add subplots
ax1 = fig.add_subplot(gs[0:2, 0])  # Spans 2 rows, column 0
ax2 = fig.add_subplot(gs[0, 1])    # Row 0, column 1
ax3 = fig.add_subplot(gs[0, 2])    # Row 0, column 2
ax4 = fig.add_subplot(gs[1, 1:3])  # Row 1, columns 1-2
```

---

# MODULE 2.3 QUIZ: INTERACTIVE DATA EXPLORATION

## Part 1: Multiple Choice (10 Questions)

**1. Which Plotly API is used for quick, one-line charts?**

A) Plotly Graph Objects
B) Plotly Express
C) Dash
D) Plotly.js

**Answer: B**
*Explanation: Plotly Express is the high-level API that creates complete figures with minimal code.*

---

**2. In Dash, what connects user interactions to component updates?**

A) Layout
B) Components
C) Callbacks
D) HTML templates

**Answer: C**
*Explanation: Callbacks are Python functions that are triggered by user interactions (Inputs) and update components (Outputs).*

---

**3. Which Dash component is used to display Plotly charts?**

A) `html.Div`
B) `dcc.Graph`
C) `dcc.Dropdown`
D) `dcc.Slider`

**Answer: B**
*Explanation: `dcc.Graph` is the Dash component that renders Plotly figures.*

---

**4. What is the purpose of `dcc.Store` in Dash?**

A) To store user login information
B) To cache data for use across callbacks
C) To save HTML templates
D) To store CSS styles

**Answer: B**
*Explanation: `dcc.Store` is used to cache data in the browser, making it available across callbacks without re-loading.*

---

**5. What interactive feature is built into all Plotly charts?**

A) Dropdown filters
B) Slider controls
C) Hover tooltips
D) Export to PDF

**Answer: C**
*Explanation: Hover tooltips showing data values are built into all Plotly charts.*

---

**6. In Dash, what does the `Input` decorator parameter specify?**

A) What components to update
B) What user actions trigger the callback
C) What data to load
D) What style to apply

**Answer: B**
*Explanation: `Input` specifies the components and properties that trigger the callback when changed.*

---

**7. What is cross-filtering in the context of interactive dashboards?**

A) Filtering data by date range
B) Selecting data in one chart to filter another
C) Filtering by multiple categories
D) Saving filtered data to file

**Answer: B**
*Explanation: Cross-filtering allows selecting data points in one chart to filter the data displayed in other charts.*

---

**8. Which Dash component would you use to create a range selection slider?**

A) `dcc.Slider`
B) `dcc.RangeSlider`
C) `dcc.Dropdown`
D) `dcc.Input`

**Answer: B**
*Explanation: `dcc.RangeSlider` allows selecting a range of values with two handles.*

---

**9. What is the purpose of `prevent_initial_call` in Dash callbacks?**

A) To stop the app from starting
B) To prevent the callback from running on initial page load
C) To prevent errors in the callback
D) To make the app run faster

**Answer: B**
*Explanation: `prevent_initial_call=True` prevents the callback from executing when the app first loads.*

---

**10. Which of the following is NOT a valid deployment option for Dash apps?**

A) Local server
B) Heroku
C) AWS EC2
D) Microsoft Word

**Answer: D**
*Explanation: Microsoft Word is a word processor and cannot host Dash applications.*

---

## Part 2: True/False (5 Questions)

**11. Plotly charts are interactive by default.**

**Answer: True**
*Explanation: All Plotly charts include hover tooltips, zoom, pan, and selection by default.*

---

**12. Dash apps require JavaScript programming.**

**Answer: False**
*Explanation: Dash apps are built entirely in Python, with no JavaScript required.*

---

**13. In Plotly Graph Objects, you can use `fig.update_layout()` to customize the chart appearance.**

**Answer: True**
*Explanation: `fig.update_layout()` is used to customize titles, axes, legends, and other chart properties.*

---

**14. Cross-filtering in Dash is not possible without JavaScript.**

**Answer: False**
*Explanation: Cross-filtering can be implemented entirely in Python with Dash callbacks.*

---

**15. A Dash callback can have multiple inputs and multiple outputs.**

**Answer: True**
*Explanation: Dash callbacks support multiple Inputs and Outputs in the same callback function.*

---

## Part 3: Short Answer (5 Questions)

**16. Explain the difference between Plotly Express and Plotly Graph Objects.**

**Answer:**
- **Plotly Express (px):** High-level API for quick creation of common chart types with minimal code. Good for rapid exploration and standard visualizations.
- **Plotly Graph Objects (go):** Low-level API with complete control over every chart element. Use for complex, custom visualizations that Express doesn't support directly.

---

**17. What is a Dash callback and what are its components?**

**Answer:**
A Dash callback is a Python function that defines interactivity in a Dash app. It consists of:
- **@callback decorator:** Defines the function as a callback
- **Output:** Component(s) to update
- **Input:** Component(s) that trigger the callback
- **State (optional):** Component(s) that provide values but don't trigger

---

**18. How do you implement cross-filtering in a Dash app?**

**Answer:**
Cross-filtering is implemented by:
1. Adding interactive selection capabilities to charts (dragmode='select' or 'lasso')
2. Using `selectedData` from one chart as Input in a callback
3. Filtering the data based on the selection
4. Updating all other charts with the filtered data

---

**19. What are the key components of a Dash application?**

**Answer:**
1. **App initialization:** `app = dash.Dash(__name__)`
2. **Layout:** Defines the UI structure using HTML and Dash components
3. **Callbacks:** Defines interactivity and data processing
4. **Server:** Runs the application (Flask backend)
5. **Run command:** `app.run_server(debug=True)`

---

**20. How do you deploy a Dash app to Heroku?**

**Answer:**
1. Create `requirements.txt` with dependencies
2. Create `Procfile` with `web: gunicorn app:server`
3. Initialize Git repository
4. Create Heroku app: `heroku create`
5. Push to Heroku: `git push heroku main`
6. Open app: `heroku open`

---

# MODULE 2.1 TEST: SYSTEMATIC EDA & DATA PROFILING

## Part 1: Multiple Choice (15 Questions)

**1. Which of the following best describes Exploratory Data Analysis?**

A) Testing hypotheses with statistical models
B) Understanding data patterns and characteristics before formal analysis
C) Deploying machine learning models to production
D) Cleaning and preprocessing data only

**Answer: B**

---

**2. A dataset has a mean of 50 and a median of 45. What can you conclude about the distribution?**

A) It is symmetric
B) It is right-skewed
C) It is left-skewed
D) It is bimodal

**Answer: B**
*Explanation: When mean > median, the distribution is right-skewed (positive skew).*

---

**3. What does a Pearson correlation coefficient of 0.15 indicate?**

A) Strong positive relationship
B) Moderate negative relationship
C) Very weak relationship
D) Perfect positive relationship

**Answer: C**
*Explanation: 0.15 falls in the "very weak" range (0.00-0.19).*

---

**4. Which method is most robust for detecting outliers?**

A) Z-score method
B) IQR method
C) Mean method
D) Range method

**Answer: B**
*Explanation: The IQR method is robust to the presence of outliers because it uses quartiles rather than mean and standard deviation.*

---

**5. MCAR stands for:**

A) Missing Completely at Random
B) Missing Conditionally at Random
C) Mostly Complete at Random
D) Missing Correctly at Random

**Answer: A**

---

**6. Cramér's V is calculated from which statistic?**

A) T-statistic
B) F-statistic
C) Chi-square statistic
D) Z-statistic

**Answer: C**
*Explanation: Cramér's V is based on the chi-square statistic.*

---

**7. A VIF score of 3 indicates:**

A) Severe multicollinearity
B) Moderate multicollinearity
C) No multicollinearity
D) Perfect multicollinearity

**Answer: B**
*Explanation: VIF between 5-10 is considered concerning; 3 is moderate and typically acceptable.*

---

**8. Which tool provides the most comprehensive automated EDA report?**

A) Sweetviz
B) D-Tale
C) ydata-profiling (pandas-profiling)
D) Lux

**Answer: C**
*Explanation: ydata-profiling provides the most comprehensive HTML reports with interactive visualizations.*

---

**9. What does kurtosis measure?**

A) The center of a distribution
B) The symmetry of a distribution
C) The "tailedness" of a distribution
D) The spread of a distribution

**Answer: C**
*Explanation: Kurtosis measures the heaviness of tails relative to a normal distribution.*

---

**10. In a boxplot, the "whiskers" typically extend to:**

A) Q1 and Q3
B) Q1 - 1.5×IQR and Q3 + 1.5×IQR
C) The minimum and maximum values
D) Mean ± 2×standard deviation

**Answer: B**
*Explanation: Whiskers extend to Q1 - 1.5×IQR and Q3 + 1.5×IQR, with points beyond marked as outliers.*

---

**11. Which statement about Spearman correlation is TRUE?**

A) It assumes linearity
B) It is based on ranks
C) It requires normal distribution
D) It is more sensitive to outliers than Pearson

**Answer: B**
*Explanation: Spearman correlation works on ranked data and does not assume linearity or normality.*

---

**12. What is the formula for the IQR?**

A) Q3 - Q1
B) Q1 + Q3
C) Max - Min
D) Mean - Median

**Answer: A**
*Explanation: IQR = Q3 - Q1.*

---

**13. Which of the following is NOT a Gestalt principle?**

A) Proximity
B) Similarity
C) Randomness
D) Continuity

**Answer: C**

---

**14. What is the difference between MAR and MNAR missing data?**

A) MAR depends on observed data; MNAR depends on missing values
B) MAR depends on missing values; MNAR depends on observed data
C) MAR is more common than MNAR
D) There is no difference

**Answer: A**

---

**15. Which of the following is the recommended approach for EDA?**

A) Only use automated tools
B) Only use manual inspection
C) Use a hybrid approach combining both
D) Skip EDA and go directly to modeling

**Answer: C**

---

## Part 2: True/False (5 Questions)

**16. The median is more robust to outliers than the mean.**

**Answer: True**

---

**17. Spearman correlation can only detect linear relationships.**

**Answer: False**
*Explanation: Spearman detects monotonic relationships (any relationship that is consistently increasing or decreasing).*

---

**18. VIF values greater than 10 indicate severe multicollinearity.**

**Answer: True**

---

**19. Automated EDA tools can replace the need for domain knowledge.**

**Answer: False**

---

**20. The IQR method for outlier detection assumes the data is normally distributed.**

**Answer: False**
*Explanation: The IQR method does not assume normality.*

---

## Part 3: Short Answer (5 Questions)

**21. Explain the three types of missing data patterns and provide examples of each.**

**Answer:**
- **MCAR (Missing Completely at Random):** Missingness is independent of all data. Example: A survey respondent accidentally skips a question due to technical error.
- **MAR (Missing at Random):** Missingness depends on observed data. Example: Women are more likely to skip income questions.
- **MNAR (Missing Not at Random):** Missingness depends on missing values themselves. Example: High-income individuals are less likely to report their income.

---

**22. What is multicollinearity and how is it detected?**

**Answer:**
Multicollinearity occurs when predictor variables are highly correlated. It is detected using:
- Correlation matrices (looking for high correlations between predictors)
- VIF (Variance Inflation Factor): VIF = 1/(1-R²)
- Condition number from eigen-decomposition
- Tolerance (1/VIF)

---

**23. Compare and contrast the IQR and Z-score methods for outlier detection.**

**Answer:**
- **IQR Method:** Uses quartiles, robust to outliers, no distribution assumptions, uses Q1 - 1.5×IQR and Q3 + 1.5×IQR bounds.
- **Z-score Method:** Uses mean and standard deviation, assumes normality, sensitive to outliers, |z| > 3 indicates outliers.

---

**24. What is the purpose of univariate analysis and what statistics are typically calculated?**

**Answer:**
Univariate analysis examines each variable individually to understand its distribution and characteristics. Key statistics include:
- Numerical: Mean, median, mode, standard deviation, variance, min, max, range, IQR, skewness, kurtosis
- Categorical: Frequency counts, proportions, cardinality

---

**25. What is the hybrid EDA approach and why is it recommended?**

**Answer:**
The hybrid approach combines:
- **Automated tools (5-10 min):** Quick overview, identify data quality issues, generate hypotheses
- **Custom inspection (30-60 min):** Deep dive into specific patterns, investigate context, explore segments
- **Story building (30-60 min):** Synthesize insights into actionable recommendations

It's recommended because automated tools provide speed and breadth while custom inspection provides depth and context.

---

# MODULE 2.2 TEST: STATISTICAL & DECLARATIVE VISUALIZATIONS

## Part 1: Multiple Choice (15 Questions)

**1. In Matplotlib's object-oriented API, what does `fig, ax = plt.subplots()` return?**

A) Only a Figure object
B) Only an Axes object
C) A tuple of (Figure, Axes)
D) A list of Axes objects

**Answer: C**

---

**2. Which Matplotlib component allows you to create subplots of different sizes?**

A) `plt.subplot()`
B) `plt.subplots()`
C) `gridspec.GridSpec()`
D) `plt.axes()`

**Answer: C**

---

**3. Seaborn's `FacetGrid` is used to:**

A) Create a single histogram
B) Create a grid of plots based on categorical variables
C) Create pairwise relationships
D) Create a correlation heatmap

**Answer: B**

---

**4. What is the Tufte data-ink ratio?**

A) The ratio of ink used to display data to total ink used
B) The ratio of ink used to display axes to total ink
C) The number of colors used in a visualization
D) The resolution of the image

**Answer: A**

---

**5. In Altair, which encoding type is used for quantitative data?**

A) `:N`
B) `:Q`
C) `:O`
D) `:T`

**Answer: B**

---

**6. What does `alt.Chart(df).mark_point()` create?**

A) A line chart
B) A bar chart
C) A scatter plot
D) A histogram

**Answer: C**

---

**7. Which of the following is NOT a Gestalt principle?**

A) Proximity
B) Similarity
C) Closure
D) Complexity

**Answer: D**

---

**8. Seaborn's `sns.pairplot()` creates:**

A) A single scatter plot
B) A grid of histograms
C) A matrix of pairwise relationships
D) A correlation heatmap

**Answer: C**

---

**9. In Matplotlib, what is the purpose of `ax.tick_params()`?**

A) To customize axis labels and ticks
B) To create a new Axes object
C) To add a legend
D) To save the figure

**Answer: A**

---

**10. Which Altair transformation would you use to group and aggregate data?**

A) `transform_filter()`
B) `transform_aggregate()`
C) `transform_calculate()`
D) `transform_bin()`

**Answer: B**

---

**11. Which Seaborn function creates a boxplot with points overlaid?**

A) `sns.boxplot()` + `sns.stripplot()`
B) `sns.violinplot()`
C) `sns.barplot()`
D) `sns.countplot()`

**Answer: A**

---

**12. What is the primary advantage of Altair over Matplotlib?**

A) Faster rendering
B) Declarative grammar and interactivity
C) More statistical functions
D) Better 3D support

**Answer: B**

---

**13. In Matplotlib, `plt.tight_layout()` is used to:**

A) Make the figure smaller
B) Adjust subplot spacing automatically
C) Save the figure
D) Add a title

**Answer: B**

---

**14. Which color palette is considered colorblind-friendly?**

A) Rainbow
B) Viridis
C) Pastel
D) Jet

**Answer: B**

---

**15. What is the Grammar of Graphics?**

A) A Python library
B) A framework for describing and building visualizations
C) A statistical test
D) A data cleaning method

**Answer: B**

---

## Part 2: True/False (5 Questions)

**16. Seaborn is a standalone library that does not depend on Matplotlib.**

**Answer: False**
*Explanation: Seaborn is built on top of Matplotlib.*

---

**17. GridSpec can create subplots with different widths.**

**Answer: True**

---

**18. Altair charts cannot be made interactive.**

**Answer: False**
*Explanation: Altair charts are interactive by default with hover, zoom, and selection capabilities.*

---

**19. The data-ink ratio suggests using more colors and decorations.**

**Answer: False**
*Explanation: The data-ink ratio suggests maximizing data-ink and minimizing decorations.*

---

**20. In Altair, faceting creates multiple charts based on a categorical variable.**

**Answer: True**

---

## Part 3: Short Answer (5 Questions)

**21. Compare and contrast Matplotlib, Seaborn, and Altair for data visualization.**

**Answer:**
- **Matplotlib:** Low-level, imperative API. Maximum control, custom layouts. Best for publication-quality static figures.
- **Seaborn:** Built on Matplotlib, high-level statistical plots. Good defaults, statistical transformations. Best for quick statistical visualizations.
- **Altair:** Declarative, grammar-based. Interactive by default, web-native. Best for reproducible, interactive visualizations.

---

**22. Explain the concept of the Grammar of Graphics and how Altair implements it.**

**Answer:**
The Grammar of Graphics is a framework for describing visualizations by separating their components: data, marks, encodings, scales, guides, and facets. Altair implements this by allowing you to build charts by specifying each component separately.

---

**23. How do you create a multi-panel figure with Matplotlib using GridSpec?**

**Answer:**
```python
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(12, 8))
gs = gridspec.GridSpec(2, 3, width_ratios=[1.5, 1, 1])

ax1 = fig.add_subplot(gs[0:2, 0])  # Spans rows 0-1, col 0
ax2 = fig.add_subplot(gs[0, 1])    # Row 0, col 1
ax3 = fig.add_subplot(gs[0, 2])    # Row 0, col 2
ax4 = fig.add_subplot(gs[1, 1:3])  # Row 1, cols 1-2
```

---

**24. What are the key components of an Altair chart and how are they structured?**

**Answer:**
```python
alt.Chart(data)          # Data
.mark_point()            # Mark (geometric shape)
.encode(                 # Encodings (visual channels)
    x='col1:Q',
    y='col2:Q',
    color='col3:N'
).properties(            # Properties (title, sizing)
    title='Chart Title',
    width=600,
    height=400
).interactive()          # Interactivity
```

---

**25. Explain the Gestalt principles and how they apply to data visualization.**

**Answer:**
- **Proximity:** Objects close together are perceived as a group → group related data elements
- **Similarity:** Similar objects are perceived as a group → use consistent colors/shapes for categories
- **Continuity:** Lines are seen as continuous → use smooth trends
- **Closure:** Incomplete shapes are completed → use implicit axes
- **Figure-Ground:** Foreground/background separation → highlight important data
- **Common Fate:** Moving objects are seen as a group → animated transitions

---

# MODULE 2.3 TEST: INTERACTIVE DATA EXPLORATION

## Part 1: Multiple Choice (15 Questions)

**1. What is the primary difference between Plotly Express and Plotly Graph Objects?**

A) Express is for static charts; Graph Objects are for interactive charts
B) Express is high-level; Graph Objects are low-level with more control
C) Express only works in Jupyter; Graph Objects work everywhere
D) Express is slower than Graph Objects

**Answer: B**

---

**2. In Dash, what is the correct way to define a callback?**

A) `@app.callback()`
B) `@callback()`
C) `@dash.callback()`
D) All of the above are valid

**Answer: D**

---

**3. Which Dash component would you use to create a dropdown menu?**

A) `html.Select`
B) `dcc.Dropdown`
C) `dcc.Select`
D) `html.Dropdown`

**Answer: B**

---

**4. What does `dcc.Store` do in a Dash application?**

A) Saves figures to disk
B) Stores data in the browser for use across callbacks
C) Stores HTML templates
D) Stores CSS styles

**Answer: B**

---

**5. What is cross-filtering in a Dash dashboard?**

A) Filtering data by date
B) Selecting data in one chart that filters other charts
C) Applying multiple filters simultaneously
D) Exporting filtered data

**Answer: B**

---

**6. In a Dash callback, what is the purpose of `State`?**

A) To trigger the callback when changed
B) To provide additional input without triggering the callback
C) To define the output of the callback
D) To set the default values

**Answer: B**

---

**7. Which of the following is NOT a valid Dash deployment option?**

A) Local server
B) Heroku
C) AWS EC2
D) Excel spreadsheet

**Answer: D**

---

**8. In Plotly, what does `fig.update_layout()` do?**

A) Updates the data in the chart
B) Customizes the chart appearance (title, axes, legend)
C) Adds new traces to the chart
D) Removes traces from the chart

**Answer: B**

---

**9. What is the purpose of `prevent_initial_call` in Dash callbacks?**

A) To prevent the app from starting
B) To prevent the callback from running on initial page load
C) To prevent the callback from running at all
D) To make the app run faster

**Answer: B**

---

**10. Which Dash component displays a Plotly figure?**

A) `html.Figure`
B) `dcc.Graph`
C) `dcc.Figure`
D) `html.Plot`

**Answer: B**

---

**11. What is the purpose of `dcc.Loading` in Dash?**

A) To load data from a file
B) To show a loading indicator while content is being rendered
C) To load CSS styles
D) To load HTML templates

**Answer: B**

---

**12. In Plotly, what does `hovermode='closest'` do?**

A) Shows tooltips for the closest data point
B) Shows tooltips for all data points
C) Disables tooltips
D) Shows tooltips only on click

**Answer: A**

---

**13. Which of the following is a valid way to create a 3D scatter plot with Plotly?**

A) `px.scatter_3d()`
B) `px.scatter3d()`
C) `go.Scatter3d()`
D) Both A and C

**Answer: D**

---

**14. In Dash, what is the relationship between Input and Output in a callback?**

A) Input updates Output
B) Output triggers Input
C) They are unrelated
D) Input and Output must have the same type

**Answer: A**

---

**15. What is the purpose of `fig.write_html()` in Plotly?**

A) To save the figure as a static image
B) To save the figure as an interactive HTML file
C) To write the figure data to a CSV
D) To update the figure data

**Answer: B**

---

## Part 2: True/False (5 Questions)

**16. Plotly charts are interactive by default.**

**Answer: True**

---

**17. Dash apps require JavaScript programming.**

**Answer: False**

---

**18. In a Dash callback, you can have multiple inputs and multiple outputs.**

**Answer: True**

---

**19. Cross-filtering in Dash can only be implemented with JavaScript.**

**Answer: False**

---

**20. `dcc.Slider` and `dcc.RangeSlider` serve the same purpose.**

**Answer: False**
*Explanation: `dcc.Slider` selects a single value; `dcc.RangeSlider` selects a range.*

---

## Part 3: Short Answer (5 Questions)

**21. Explain the architecture of a Dash application.**

**Answer:**
Dash applications consist of:
1. **Layout:** Defines the UI using HTML components and Dash Core Components
2. **Callbacks:** Python functions that define interactivity, triggered by Inputs and updating Outputs
3. **Server:** Flask-based web server that serves the application
4. **Components:** Interactive elements like graphs, dropdowns, and sliders

---

**22. How do you implement cross-filtering in a Dash application?**

**Answer:**
1. Enable selection on charts: `dragmode='select'` or `dragmode='lasso'`
2. Create a callback that uses `selectedData` from one chart as Input
3. Filter the dataset based on the selection
4. Update all other charts with the filtered data
5. Return the updated figures from the callback

---

**23. What are the key differences between Plotly Express and Plotly Graph Objects?**

**Answer:**
- **Plotly Express:** High-level API, one-line charts, quick creation, limited customization
- **Plotly Graph Objects:** Low-level API, granular control, custom charts, more verbose code
- **Use Express for:** Standard charts, quick exploration
- **Use Graph Objects for:** Custom charts, complex layouts, fine-tuning

---

**24. What is a Dash callback and what are its key components?**

**Answer:**
A Dash callback is a Python function that defines interactivity:
```python
@callback(
    Output('output-id', 'property'),  # What to update
    Input('input-id', 'value')        # What triggers the callback
)
def update_function(input_value):
    # Process input
    return output_value  # Update Output
```

Key components:
- **@callback:** Decorator that registers the function
- **Output:** Component and property to update
- **Input:** Component and property that triggers the callback
- **State:** Optional additional inputs that don't trigger

---

**25. How do you deploy a Dash app to a cloud platform?**

**Answer:**
1. **Heroku:**
   - Create `requirements.txt` and `Procfile`
   - Initialize Git
   - `heroku create`
   - `git push heroku main`

2. **AWS EC2:**
   - Launch EC2 instance
   - Install dependencies
   - Copy application
   - Run with Gunicorn
   - Configure Nginx reverse proxy

3. **Docker:**
   - Create Dockerfile
   - Build image: `docker build -t myapp`
   - Run container: `docker run -p 8050:8050 myapp`
   - Push to container registry

---

# MIDTERM EXAM: MODULES 2.1 & 2.2

## Part 1: Multiple Choice (25 Questions)

**1. What is the primary purpose of Exploratory Data Analysis (EDA)?**

A) Building machine learning models
B) Understanding data patterns before formal analysis
C) Deploying models to production
D) Creating data visualizations only

**Answer: B**

---

**2. A dataset has a mean of 60 and a median of 55. The distribution is:**

A) Symmetric
B) Right-skewed
C) Left-skewed
D) Uniform

**Answer: B**

---

**3. Which measure of central tendency is most robust to outliers?**

A) Mean
B) Median
C) Mode
D) All are equally robust

**Answer: B**

---

**4. A Pearson correlation coefficient of -0.92 indicates:**

A) Strong positive relationship
B) Strong negative relationship
C) Weak positive relationship
D) No relationship

**Answer: B**

---

**5. What does MAR (Missing at Random) mean?**

A) Missingness is completely random
B) Missingness depends on observed data
C) Missingness depends on missing values
D) Missingness is random but patterned

**Answer: B**

---

**6. Cramér's V is used to measure association between:**

A) Two numerical variables
B) Two categorical variables
C) One numerical and one categorical variable
D) More than two variables

**Answer: B**

---

**7. A VIF score of 12 indicates:**

A) No multicollinearity
B) Moderate multicollinearity
C) Severe multicollinearity
D) Perfect multicollinearity

**Answer: C**

---

**8. What is the formula for IQR?**

A) Q1 - Q3
B) Q3 - Q1
C) Mean - Median
D) Max - Min

**Answer: B**

---

**9. In Matplotlib, what does GridSpec control?**

A) Color schemes
B) Subplot layout
C) Axis labels
D) Legend position

**Answer: B**

---

**10. What does Seaborn's FacetGrid create?**

A) A single plot
B) A grid of plots based on categorical variables
C) A pair plot matrix
D) A correlation heatmap

**Answer: B**

---

**11. In Altair, what does `mark_point()` create?**

A) Line chart
B) Scatter plot
C) Bar chart
D) Histogram

**Answer: B**

---

**12. What is the 68-95-99.7 rule related to?**

A) Correlation coefficients
B) Normal distribution
C) Categorical distributions
D) Missing data

**Answer: B**

---

**13. Which of the following is NOT a Gestalt principle?**

A) Proximity
B) Similarity
C) Continuity
D) Complexity

**Answer: D**

---

**14. What is the primary difference between MCAR and MNAR?**

A) MCAR is more common
B) MCAR depends on observed data; MNAR depends on missing values
C) MNAR depends on observed data; MCAR depends on missing values
D) There is no difference

**Answer: B**

---

**15. In Altair, what does `:Q` indicate?**

A) Qualitative data
B) Quantitative data
C) Ordinal data
D) Temporal data

**Answer: B**

---

**16. What is the data-ink ratio?**

A) The amount of ink in the printer
B) The proportion of ink used for data
C) The number of colors used
D) The figure resolution

**Answer: B**

---

**17. Which outlier detection method assumes normality?**

A) IQR method
B) Z-score method
C) Both IQR and Z-score
D) Neither

**Answer: B**

---

**18. Seaborn is built on which library?**

A) Altair
B) Plotly
C) Matplotlib
D) Pandas

**Answer: C**

---

**19. What does `alt.Chart(df).mark_bar().encode(x='cat:N', y='count()')` create?**

A) A scatter plot
B) A bar chart
C) A line chart
D) A histogram

**Answer: B**

---

**20. In Matplotlib, what does `plt.tight_layout()` do?**

A) Saves the figure
B) Adjusts subplot spacing
C) Adds a title
D) Creates a new figure

**Answer: B**

---

**21. What is the range of the Spearman correlation coefficient?**

A) 0 to 1
B) -1 to 1
C) 0 to 100
D) -∞ to ∞

**Answer: B**

---

**22. Which of the following is an example of a sequential color palette?**

A) Set2
B) Viridis
C) RdBu
D) Rainbow

**Answer: B**

---

**23. What is the purpose of `ax.annotate()` in Matplotlib?**

A) To add annotations with optional arrows
B) To create a new axes
C) To save the figure
D) To change the color scheme

**Answer: A**

---

**24. In Altair, what is the purpose of `transform_density()`?**

A) To filter data
B) To create a density estimation
C) To group data
D) To calculate percentages

**Answer: B**

---

**25. What is the recommended approach for EDA?**

A) Only automated tools
B) Only manual inspection
C) Hybrid approach
D) Skip EDA

**Answer: C**

---

## Part 2: True/False (10 Questions)

**26. The median is more robust to outliers than the mean.**

**Answer: True**

---

**27. Spearman correlation requires normally distributed data.**

**Answer: False**

---

**28. GridSpec can create subplots with different sizes.**

**Answer: True**

---

**29. Altair charts are interactive by default.**

**Answer: True**

---

**30. The IQR method for outlier detection assumes normality.**

**Answer: False**

---

**31. Seaborn is a standalone library independent of Matplotlib.**

**Answer: False**

---

**32. Automated EDA tools can completely replace manual analysis.**

**Answer: False**

---

**33. A VIF of 3 indicates severe multicollinearity.**

**Answer: False**

---

**34. In Altair, `:N` indicates nominal (categorical) data.**

**Answer: True**

---

**35. Cramér's V ranges from -1 to 1.**

**Answer: False**

---

## Part 3: Short Answer (15 Questions)

**36. Explain the difference between MCAR, MAR, and MNAR missing data patterns.**

**Answer:**
- **MCAR:** Missingness independent of observed and unobserved data
- **MAR:** Missingness depends on observed data
- **MNAR:** Missingness depends on missing values themselves

---

**37. When would you use Spearman instead of Pearson correlation?**

**Answer:**
- Non-linear but monotonic relationships
- Ordinal data
- Non-normal distributions
- Presence of outliers

---

**38. What is the hybrid EDA approach?**

**Answer:**
Combining automated tools (5-10 min) for quick overview with custom inspection (30-60 min) for deep exploration and context.

---

**39. Compare and contrast Matplotlib, Seaborn, and Altair.**

**Answer:**
- **Matplotlib:** Low-level, full control, publication quality
- **Seaborn:** Built on Matplotlib, statistical plots, quick
- **Altair:** Declarative, grammar-based, interactive

---

**40. How do you create a GridSpec layout with Matplotlib?**

**Answer:**
```python
import matplotlib.gridspec as gridspec
fig = plt.figure()
gs = gridspec.GridSpec(2, 3, width_ratios=[1.5, 1, 1])
ax1 = fig.add_subplot(gs[0:2, 0])
```

---

**41. Explain the Grammar of Graphics and how Altair implements it.**

**Answer:**
The Grammar of Graphics describes visualizations by components: Data, Marks, Encodings, Scales, Guides, Facets. Altair implements this declaratively.

---

**42. What is the data-ink ratio and why is it important?**

**Answer:**
Data-ink ratio is the proportion of ink used for data vs. total ink. It matters because it helps create clear, focused visualizations without clutter.

---

**43. How do you detect outliers using the IQR method?**

**Answer:**
1. Calculate Q1 and Q3
2. Calculate IQR = Q3 - Q1
3. Lower bound = Q1 - 1.5×IQR
4. Upper bound = Q3 + 1.5×IQR
5. Values outside are outliers

---

**44. What is multicollinearity and how is it detected?**

**Answer:**
Multicollinearity is high correlation between predictor variables. Detected using:
- Correlation matrices
- VIF (Variance Inflation Factor)
- Condition number

---

**45. Explain the Gestalt principles and their application to visualization.**

**Answer:**
- Proximity: Group related data close together
- Similarity: Use consistent colors for categories
- Continuity: Use smooth trends
- Closure: Use implicit axes
- Figure-Ground: Highlight important data

---

**46. What is the difference between Plotly Express and Plotly Graph Objects?**

**Answer:**
- **Express:** High-level, quick charts, one-line creation
- **Graph Objects:** Low-level, full control, more code

---

**47. What are the key components of an Altair chart?**

**Answer:**
```python
alt.Chart(data)          # Data source
.mark_type()             # Geometric shape
.encode()                # Visual encodings
.properties()            # Title, sizing
.interactive()           # Interactivity
```

---

**48. How do you create a multi-panel figure with Matplotlib?**

**Answer:**
Using GridSpec or `plt.subplots()` with proper indexing and layout.

---

**49. What is the purpose of Seaborn's PairGrid?**

**Answer:**
To create a matrix of pairwise relationships between variables, with histograms on the diagonal and scatter plots off-diagonal.

---

**50. Explain the concept of broadcasting in NumPy.**

**Answer:**
Broadcasting allows operations on arrays of different shapes by automatically expanding smaller arrays to match larger ones, following specific rules.

---

# FINAL EXAM: COMPLETE SERIES

## Part 1: Multiple Choice (40 Questions)

**1. What is the primary purpose of Exploratory Data Analysis?**

A) Building machine learning models
B) Understanding data patterns before formal analysis
C) Deploying models to production
D) Creating data visualizations only

**Answer: B**

---

**2. A distribution with skewness > 0 is:**

A) Symmetric
B) Right-skewed
C) Left-skewed
D) Bimodal

**Answer: B**

---

**3. Which measure is most robust to outliers?**

A) Mean
B) Median
C) Mode
D) Range

**Answer: B**

---

**4. A Pearson correlation of -0.85 indicates:**

A) Strong positive relationship
B) Strong negative relationship
C) Weak positive relationship
D) No relationship

**Answer: B**

---

**5. MAR missing data means:**

A) Missing is completely random
B) Missing depends on observed data
C) Missing depends on missing values
D) Missing is random but patterned

**Answer: B**

---

**6. Cramér's V is used for:**

A) Two numerical variables
B) Two categorical variables
C) One numerical and one categorical
D) More than two variables

**Answer: B**

---

**7. A VIF of 8 indicates:**

A) No multicollinearity
B) Moderate multicollinearity
C) High multicollinearity
D) Perfect multicollinearity

**Answer: C**

---

**8. The IQR is calculated as:**

A) Q1 - Q3
B) Q3 - Q1
C) Mean - Median
D) Max - Min

**Answer: B**

---

**9. In Matplotlib, GridSpec controls:**

A) Colors
B) Layout
C) Labels
D) Legend

**Answer: B**

---

**10. Seaborn's FacetGrid creates:**

A) Single plot
B) Grid of plots by category
C) Pair plot matrix
D) Heatmap

**Answer: B**

---

**11. In Altair, `mark_point()` creates:**

A) Line chart
B) Scatter plot
C) Bar chart
D) Histogram

**Answer: B**

---

**12. The 68-95-99.7 rule applies to:**

A) Correlation coefficients
B) Normal distribution
C) Categorical distributions
D) Missing data

**Answer: B**

---

**13. Which is NOT a Gestalt principle?**

A) Proximity
B) Similarity
C) Continuity
D) Complexity

**Answer: D**

---

**14. MNAR missing data:**

A) Depends on observed data
B) Depends on missing values
C) Is completely random
D) Is the most common

**Answer: B**

---

**15. In Altair, `:Q` indicates:**

A) Qualitative data
B) Quantitative data
C) Ordinal data
D) Temporal data

**Answer: B**

---

**16. The data-ink ratio is:**

A) Amount of ink in the printer
B) Proportion of ink used for data
C) Number of colors used
D) Figure resolution

**Answer: B**

---

**17. Which outlier detection assumes normality?**

A) IQR method
B) Z-score method
C) Both
D) Neither

**Answer: B**

---

**18. Seaborn is built on:**

A) Altair
B) Plotly
C) Matplotlib
D) Pandas

**Answer: C**

---

**19. `alt.Chart(df).mark_bar().encode(x='cat:N', y='count()')` creates:**

A) Scatter plot
B) Bar chart
C) Line chart
D) Histogram

**Answer: B**

---

**20. `plt.tight_layout()` does:**

A) Saves the figure
B) Adjusts subplot spacing
C) Adds a title
D) Creates new figure

**Answer: B**

---

**21. Spearman correlation ranges from:**

A) 0 to 1
B) -1 to 1
C) 0 to 100
D) -∞ to ∞

**Answer: B**

---

**22. Sequential color palette example:**

A) Set2
B) Viridis
C) RdBu
D) Rainbow

**Answer: B**

---

**23. `ax.annotate()` adds:**

A) Annotations with arrows
B) New axes
C) Figure save
D) Color scheme

**Answer: A**

---

**24. `transform_density()` in Altair:**

A) Filters data
B) Creates density estimation
C) Groups data
D) Calculates percentages

**Answer: B**

---

**25. The recommended EDA approach:**

A) Only automated
B) Only manual
C) Hybrid
D) Skip EDA

**Answer: C**

---

**26. Plotly Express vs Graph Objects:**

A) Express is static; Graph Objects are interactive
B) Express is high-level; Graph Objects are low-level
C) Express only works in Jupyter
D) Express is slower

**Answer: B**

---

**27. Dash callback components:**

A) Output and Input only
B) Output, Input, and State
C) Output only
D) Input only

**Answer: B**

---

**28. `dcc.Graph` displays:**

A) HTML
B) Plotly figures
C) Tables
D) Text

**Answer: B**

---

**29. `dcc.Store` in Dash:**

A) Saves figures to disk
B) Stores data in browser
C) Stores HTML templates
D) Stores CSS

**Answer: B**

---

**30. Cross-filtering in Dash:**

A) Filters data by date
B) Selecting in one chart filters another
C) Applies multiple filters
D) Exports filtered data

**Answer: B**

---

**31. `State` in Dash callbacks:**

A) Triggers callback
B) Provides input without triggering
C) Defines output
D) Sets defaults

**Answer: B**

---

**32. Not a valid Dash deployment:**

A) Local server
B) Heroku
C) AWS EC2
D) Excel

**Answer: D**

---

**33. `fig.update_layout()` does:**

A) Updates data
B) Customizes appearance
C) Adds traces
D) Removes traces

**Answer: B**

---

**34. `prevent_initial_call` does:**

A) Stops app
B) Prevents callback on load
C) Prevents callback entirely
D) Speeds up app

**Answer: B**

---

**35. `dcc.Loading` shows:**

A) Loading indicator
B) Data loading
C) CSS loading
D) HTML loading

**Answer: A**

---

**36. `hovermode='closest'`:**

A) Shows closest tooltip
B) Shows all tooltips
C) Disables tooltips
D) Shows on click

**Answer: A**

---

**37. 3D scatter in Plotly:**

A) `px.scatter_3d()`
B) `px.scatter3d()`
C) `go.Scatter3d()`
D) Both A and C

**Answer: D**

---

**38. Input/Output relationship:**

A) Input updates Output
B) Output triggers Input
C) Unrelated
D) Same type required

**Answer: A**

---

**39. `fig.write_html()`:**

A) Saves as image
B) Saves as HTML
C) Saves as CSV
D) Updates data

**Answer: B**

---

**40. Which is NOT a valid Dash component?**

A) `dcc.Graph`
B) `dcc.Dropdown`
C) `dcc.Figure`
D) `html.Div`

**Answer: C**

---

## Part 2: True/False (15 Questions)

**41. The median is more robust to outliers than the mean.**

**Answer: True**

---

**42. Spearman correlation requires normal distribution.**

**Answer: False**

---

**43. GridSpec can create subplots of different sizes.**

**Answer: True**

---

**44. Altair charts are interactive by default.**

**Answer: True**

---

**45. IQR outlier detection assumes normality.**

**Answer: False**

---

**46. Seaborn is independent of Matplotlib.**

**Answer: False**

---

**47. Automated EDA can replace manual analysis.**

**Answer: False**

---

**48. VIF of 3 indicates severe multicollinearity.**

**Answer: False**

---

**49. In Altair, `:N` indicates nominal data.**

**Answer: True**

---

**50. Cramér's V ranges from -1 to 1.**

**Answer: False**

---

**51. Plotly charts are interactive by default.**

**Answer: True**

---

**52. Dash requires JavaScript programming.**

**Answer: False**

---

**53. Dash callbacks support multiple inputs and outputs.**

**Answer: True**

---

**54. Cross-filtering in Dash requires JavaScript.**

**Answer: False**

---

**55. `dcc.Slider` and `dcc.RangeSlider` serve the same purpose.**

**Answer: False**

---

## Part 3: Short Answer (20 Questions)

**56. Explain MCAR, MAR, and MNAR missing data patterns.**

**Answer:**
- **MCAR:** Missingness independent of all data
- **MAR:** Missingness depends on observed data
- **MNAR:** Missingness depends on missing values

---

**57. When to use Spearman vs Pearson correlation?**

**Answer:**
Spearman for non-linear monotonic relationships, ordinal data, non-normal distributions; Pearson for linear relationships, normal data.

---

**58. What is the hybrid EDA approach?**

**Answer:**
Combining automated tools for quick overview and custom inspection for deep exploration.

---

**59. Compare Matplotlib, Seaborn, and Altair.**

**Answer:**
- **Matplotlib:** Low-level, full control
- **Seaborn:** Built on Matplotlib, statistical plots
- **Altair:** Declarative, grammar-based, interactive

---

**60. How to create a GridSpec layout?**

**Answer:**
```python
gs = gridspec.GridSpec(2, 3, width_ratios=[1.5, 1, 1])
ax = fig.add_subplot(gs[0:2, 0])
```

---

**61. Explain the Grammar of Graphics.**

**Answer:**
Framework describing visualizations by components: Data, Marks, Encodings, Scales, Guides, Facets.

---

**62. What is the data-ink ratio and why does it matter?**

**Answer:**
Proportion of ink used for data. Matters for creating clear, focused visualizations.

---

**63. How to detect outliers using IQR?**

**Answer:**
Calculate Q1, Q3, IQR. Bounds: Q1-1.5×IQR and Q3+1.5×IQR. Values outside are outliers.

---

**64. What is multicollinearity and how is it detected?**

**Answer:**
High correlation between predictors. Detected via correlation matrices, VIF, condition number.

---

**65. Explain Gestalt principles in visualization.**

**Answer:**
- Proximity: Group related data
- Similarity: Consistent colors for categories
- Continuity: Smooth trends
- Closure: Implicit axes
- Figure-Ground: Highlight data

---

**66. Plotly Express vs Graph Objects?**

**Answer:**
- **Express:** High-level, quick
- **Graph Objects:** Low-level, full control

---

**67. Key components of an Altair chart?**

**Answer:**
`alt.Chart(data).mark_type().encode().properties().interactive()`

---

**68. How to create a multi-panel figure with Matplotlib?**

**Answer:**
Using GridSpec or `plt.subplots()` with proper layout.

---

**69. Purpose of Seaborn's PairGrid?**

**Answer:**
Create matrix of pairwise relationships with histograms on diagonal.

---

**70. Explain broadcasting in NumPy.**

**Answer:**
Operations on arrays of different shapes by expanding smaller arrays.

---

**71. What is the Dash architecture?**

**Answer:**
Layout (UI components) + Callbacks (interactivity) + Server (Flask backend).

---

**72. Explain Dash callbacks and their components.**

**Answer:**
```python
@callback(
    Output('id', 'property'),
    Input('id', 'property'),
    State('id', 'property')
)
def function(input_value, state_value):
    return output_value
```

---

**73. How to implement cross-filtering in Dash?**

**Answer:**
Use `selectedData` from one chart as Input, filter data, update all charts.

---

**74. How to deploy a Dash app to Heroku?**

**Answer:**
Create requirements.txt, Procfile, Git, `heroku create`, `git push heroku main`.

---

**75. What are the key interactive features of Plotly?**

**Answer:**
Hover tooltips, zoom, pan, selection, legend toggling, custom controls.

---

# PRACTICAL EXAM

## Instructions

This is a hands-on coding assessment. Complete the tasks below using the skills you've learned throughout the series. Write clean, well-commented code.

**Time Allowed:** 3 hours

**Data:** You will generate the customer dataset using the provided `generate_customer_data()` function.

---

## Task 1: Data Loading and Inspection (10 points)

**Instructions:**
1. Load the customer dataset
2. Display the first 5 rows
3. Display the shape, columns, and data types
4. Count missing values per column
5. Generate summary statistics for numerical columns

**Answer:**
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
df = pd.read_csv('data/customer_data.csv')

# Display first 5 rows
print("First 5 rows:")
print(df.head())

# Shape, columns, dtypes
print(f"\nShape: {df.shape}")
print("\nColumns and dtypes:")
print(df.dtypes)

# Missing values
print("\nMissing values:")
print(df.isnull().sum())

# Summary statistics
print("\nSummary statistics:")
print(df.describe())
```

---

## Task 2: Univariate Analysis (15 points)

**Instructions:**
1. Create histograms with KDE for age, order_frequency, and avg_order_value
2. Add vertical lines for mean and median
3. Create boxplots for all numerical variables
4. Identify which variable has the most outliers

**Answer:**
```python
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Age
sns.histplot(df['age'].dropna(), kde=True, ax=axes[0])
axes[0].axvline(df['age'].mean(), color='red', linestyle='--', label='Mean')
axes[0].axvline(df['age'].median(), color='green', linestyle='-.', label='Median')
axes[0].set_title('Age Distribution')
axes[0].legend()

# Order frequency
sns.histplot(df['order_frequency'].dropna(), kde=True, ax=axes[1])
axes[1].axvline(df['order_frequency'].mean(), color='red', linestyle='--', label='Mean')
axes[1].axvline(df['order_frequency'].median(), color='green', linestyle='-.', label='Median')
axes[1].set_title('Order Frequency')
axes[1].legend()

# Avg order value
sns.histplot(df['avg_order_value'].dropna(), kde=True, ax=axes[2])
axes[2].axvline(df['avg_order_value'].mean(), color='red', linestyle='--', label='Mean')
axes[2].axvline(df['avg_order_value'].median(), color='green', linestyle='-.', label='Median')
axes[2].set_title('Average Order Value')
axes[2].legend()

plt.tight_layout()
plt.show()

# Boxplots
num_cols = ['age', 'order_frequency', 'avg_order_value', 'customer_rating', 'return_rate']
fig, axes = plt.subplots(1, 5, figsize=(20, 4))

for idx, col in enumerate(num_cols):
    sns.boxplot(y=df[col].dropna(), ax=axes[idx])
    axes[idx].set_title(col)

plt.tight_layout()
plt.show()

# Count outliers using IQR
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

---

## Task 3: Correlation Analysis (15 points)

**Instructions:**
1. Compute Pearson and Spearman correlation matrices
2. Create a correlation heatmap
3. Identify the top 3 strongest correlations
4. Explain what these correlations mean

**Answer:**
```python
from scipy.stats import pearsonr, spearmanr

# Pearson correlation
pearson_corr = df[num_cols].corr(method='pearson')
print("Pearson Correlation:")
print(pearson_corr)

# Spearman correlation
spearman_corr = df[num_cols].corr(method='spearman')
print("\nSpearman Correlation:")
print(spearman_corr)

# Heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(pearson_corr, annot=True, fmt='.2f', cmap='RdBu_r', center=0)
plt.title('Correlation Heatmap')
plt.tight_layout()
plt.show()

# Top correlations
corr_pairs = []
for i in range(len(pearson_corr.columns)):
    for j in range(i+1, len(pearson_corr.columns)):
        val = pearson_corr.iloc[i, j]
        if not pd.isna(val):
            corr_pairs.append((pearson_corr.columns[i], pearson_corr.columns[j], val))

corr_pairs.sort(key=lambda x: abs(x[2]), reverse=True)

print("\nTop 3 Strongest Correlations:")
for col1, col2, val in corr_pairs[:3]:
    print(f"{col1} ↔ {col2}: r = {val:.3f}")
    if val > 0:
        print(f"  Positive: As {col1} increases, {col2} increases")
    else:
        print(f"  Negative: As {col1} increases, {col2} decreases")
```

---

## Task 4: Visualization with Matplotlib (15 points)

**Instructions:**
1. Create a 2x2 GridSpec layout with unequal column widths
2. Add different plot types to each subplot
3. Format axes professionally with titles, labels, and grid

**Answer:**
```python
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(14, 10))
gs = gridspec.GridSpec(2, 3, width_ratios=[1.5, 1, 1], height_ratios=[1, 1])

# 1. Scatter plot (spans 2 rows, 1 column)
ax1 = fig.add_subplot(gs[0:2, 0])
scatter = ax1.scatter(df['time_on_site'], df['pages_viewed'],
                     c=df['order_frequency'], cmap='viridis', alpha=0.6)
ax1.set_xlabel('Time on Site (min)', fontsize=12)
ax1.set_ylabel('Pages Viewed', fontsize=12)
ax1.set_title('Engagement: Time vs Pages', fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.3)
fig.colorbar(scatter, ax=ax1, label='Order Frequency')

# 2. Histogram (row 0, col 1)
ax2 = fig.add_subplot(gs[0, 1])
df['age'].dropna().hist(bins=20, ax=ax2, color='steelblue', edgecolor='black')
ax2.set_xlabel('Age', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Age Distribution', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)

# 3. Boxplot (row 0, col 2)
ax3 = fig.add_subplot(gs[0, 2])
df.boxplot(column='avg_order_value', by='income_bracket', ax=ax3)
ax3.set_title('Order Value by Income', fontsize=14, fontweight='bold')
ax3.set_xlabel('Income Bracket', fontsize=12)
ax3.set_ylabel('Avg Order Value', fontsize=12)
plt.setp(ax3.xaxis.get_majorticklabels(), rotation=45)

# 4. Bar chart (row 1, col 1)
ax4 = fig.add_subplot(gs[1, 1])
category_counts = df['favorite_category'].value_counts()
ax4.bar(category_counts.index, category_counts.values, color='coral', edgecolor='black')
ax4.set_xlabel('Category', fontsize=12)
ax4.set_ylabel('Count', fontsize=12)
ax4.set_title('Favorite Categories', fontsize=14, fontweight='bold')
plt.setp(ax4.xaxis.get_majorticklabels(), rotation=45)

# 5. Pie chart (row 1, col 2)
ax5 = fig.add_subplot(gs[1, 2])
gender_counts = df['gender'].value_counts()
ax5.pie(gender_counts.values, labels=gender_counts.index, autopct='%1.1f%%')
ax5.set_title('Gender Distribution', fontsize=14, fontweight='bold')

plt.suptitle('Customer Analytics Dashboard', fontsize=18, fontweight='bold')
plt.tight_layout()
plt.show()
```

---

## Task 5: Interactive Dashboard with Dash (25 points)

**Instructions:**
1. Build a Dash app with:
   - A dropdown filter for income bracket
   - A slider for age range
   - KPI cards showing total customers and average order value
   - A scatter plot that updates based on filters
2. Format the layout professionally using Bootstrap

**Answer:**
```python
import dash
from dash import dcc, html, Input, Output, callback
import dash_bootstrap_components as dbc
import plotly.express as px
import pandas as pd

# Load data
df = pd.read_csv('data/customer_data.csv')

# Initialize app
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.FLATLY])

# Layout
app.layout = dbc.Container([
    html.H1("Customer Analytics Dashboard", className="text-center my-4"),
    
    dbc.Row([
        dbc.Col([
            html.Label("Income Bracket"),
            dcc.Dropdown(
                id='income-filter',
                options=[{'label': 'All', 'value': 'All'}] +
                        [{'label': i, 'value': i} for i in df['income_bracket'].unique()],
                value='All'
            )
        ], md=4),
        dbc.Col([
            html.Label("Age Range"),
            dcc.RangeSlider(
                id='age-slider',
                min=int(df['age'].min()),
                max=int(df['age'].max()),
                step=1,
                value=[int(df['age'].min()), int(df['age'].max())],
                marks={i: str(i) for i in range(20, 71, 10)}
            )
        ], md=8)
    ], className='mb-4'),
    
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H5("Total Customers", className="text-muted"),
                    html.H2(id='kpi-total', className="text-primary")
                ])
            ])
        ], md=6),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H5("Avg Order Value", className="text-muted"),
                    html.H2(id='kpi-order-value', className="text-success")
                ])
            ])
        ], md=6)
    ], className='mb-4'),
    
    dbc.Row([
        dbc.Col([
            dcc.Graph(id='main-chart')
        ], md=12)
    ])
], fluid=True)

# Callback
@callback(
    Output('kpi-total', 'children'),
    Output('kpi-order-value', 'children'),
    Output('main-chart', 'figure'),
    Input('income-filter', 'value'),
    Input('age-slider', 'value')
)
def update_dashboard(income, age_range):
    # Filter data
    filtered = df.copy()
    
    if income != 'All':
        filtered = filtered[filtered['income_bracket'] == income]
    
    filtered = filtered[
        (filtered['age'] >= age_range[0]) & 
        (filtered['age'] <= age_range[1])
    ]
    
    # KPIs
    total = f"{len(filtered):,}"
    avg_value = f"${filtered['avg_order_value'].mean():.2f}"
    
    # Chart
    fig = px.scatter(
        filtered,
        x='order_frequency',
        y='avg_order_value',
        color='favorite_category',
        title=f'Purchase Behavior ({len(filtered)} customers)',
        template='plotly_white',
        hover_data=['customer_id', 'customer_rating']
    )
    
    return total, avg_value, fig

if __name__ == '__main__':
    app.run_server(debug=True)
```

---

## Practical Exam Scoring Guide

| Task | Points | Criteria |
|------|--------|----------|
| Task 1 | 10 | Correct data loading, inspection, summary |
| Task 2 | 15 | All visualizations created, proper annotations |
| Task 3 | 15 | Correct correlations, heatmap, interpretation |
| Task 4 | 15 | GridSpec layout, all plot types, professional formatting |
| Task 5 | 25 | All components present, filters work, KPI cards update |
| Code Quality | 10 | Clean, well-commented, follows best practices |
| Documentation | 10 | Clear explanations, interpretations |

**Total: 100 points**

---

# ANSWER KEY: FINAL EXAM

## Part 1: Multiple Choice

1. B
2. B
3. B
4. B
5. B
6. B
7. C
8. B
9. B
10. B
11. B
12. B
13. D
14. B
15. B
16. B
17. B
18. C
19. B
20. B
21. B
22. B
23. A
24. B
25. C
26. B
27. B
28. B
29. B
30. B
31. B
32. D
33. B
34. B
35. A
36. A
37. D
38. A
39. B
40. C

## Part 2: True/False

41. True
42. False
43. True
44. True
45. False
46. False
47. False
48. False
49. True
50. False
51. True
52. False
53. True
54. False
55. False

## Part 3: Short Answer

(Answers provided in previous sections with full explanations)

---

# COMPREHENSIVE ANSWER KEY: ALL QUIZZES & TESTS

| Assessment | Total Questions | Passing Score |
|------------|----------------|---------------|
| Module 2.1 Quiz | 20 | 70% (14/20) |
| Module 2.1 Test | 25 | 70% (18/25) |
| Module 2.2 Quiz | 20 | 70% (14/20) |
| Module 2.2 Test | 25 | 70% (18/25) |
| Module 2.3 Quiz | 20 | 70% (14/20) |
| Module 2.3 Test | 25 | 70% (18/25) |
| Midterm Exam | 50 | 70% (35/50) |
| Final Exam | 75 | 70% (53/75) |
| Practical Exam | 100 | 70% (70/100) |

---

*This comprehensive assessment bank covers all material from the "Exploratory Data Analysis & Visualization" series. Use these assessments to evaluate understanding, identify areas for review, and prepare for certification.*
