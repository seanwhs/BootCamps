# Primer 6: Data Visualization Best Practices

## Designing Effective and Ethical Visualizations

---

#### Purpose of This Primer

Creating effective visualizations is both a science and an art. This primer covers the principles, guidelines, and best practices for designing visualizations that are clear, accurate, and impactful. Whether you're creating static publication figures or interactive dashboards, these principles will help you communicate your data effectively.

---

## P6.1 The Grammar of Graphics

### P6.1.1 Core Components

The Grammar of Graphics, formalized by Leland Wilkinson, provides a systematic framework for building visualizations:

```python
# Each visualization consists of:
# 1. Data - What are we visualizing?
# 2. Aesthetics - How are data mapped to visual properties?
# 3. Geometry - What geometric shapes are used?
# 4. Coordinates - What coordinate system?
# 5. Facets - How is data split into subplots?
# 6. Statistics - What statistical transformations are applied?
# 7. Scales - How are data values mapped to visual values?

# Example in Altair (declarative)
alt.Chart(df).mark_point().encode(
    x='age:Q',      # Aesthetic mapping
    y='value:Q',    # Aesthetic mapping
    color='category:N'  # Aesthetic mapping
).facet('gender:N')  # Facetting
```

### P6.1.2 Encoding Visual Variables

| Data Type | Visual Variables | Best Choices |
|-----------|------------------|--------------|
| **Quantitative** | Position, Length, Angle, Area, Color (gradient) | Position on common scale |
| **Ordinal** | Position, Color (hue), Size | Position, Color |
| **Nominal** | Position, Color (hue), Shape, Pattern | Color, Position |

---

## P6.2 Choosing the Right Chart Type

### P6.2.1 Chart Selection Guide

| Purpose | Best Charts | Avoid |
|---------|-------------|-------|
| **Compare categories** | Bar chart, Column chart, Dot plot | Pie chart (for >5 categories) |
| **Show distribution** | Histogram, Box plot, Violin plot, KDE | Bar chart |
| **Show relationship** | Scatter plot, Bubble chart, Heatmap | 3D charts |
| **Show composition** | Stacked bar, Pie chart, Treemap | 3D pie charts |
| **Show trend over time** | Line chart, Area chart, Bar chart | Pie charts |
| **Show geographic** | Map, Choropleth, Scatter map | Bar charts |
| **Show flow** | Sankey, Chord diagram | Pie charts |
| **Show ranking** | Bar chart, Dot plot | 3D charts |

### P6.2.2 Chart Type Decision Tree

```
1. What is your data type?
   ├── Categorical
   │   ├── One variable → Bar chart, Pie chart
   │   └── Multiple variables → Grouped bar, Stacked bar
   ├── Numerical
   │   ├── One variable → Histogram, Box plot
   │   ├── Two variables → Scatter plot, Line chart
   │   └── Multiple variables → Pair plot, Heatmap
   └── Temporal
       └── Line chart, Area chart

2. What is your purpose?
   ├── Comparison → Bar chart, Dot plot
   ├── Distribution → Histogram, Box plot
   ├── Relationship → Scatter plot, Heatmap
   ├── Composition → Stacked bar, Pie chart
   └── Trend → Line chart, Area chart
```

### P6.2.3 Common Chart Types and When to Use Them

#### Bar Charts

```python
# Horizontal bar (best for many categories)
sns.barplot(x='value', y='category', data=df)

# Vertical bar (best for few categories)
sns.barplot(x='category', y='value', data=df)

# Grouped bar (compare multiple series)
sns.barplot(x='category', y='value', hue='group', data=df)

# Stacked bar (show composition)
sns.barplot(x='category', y='value', hue='group', data=df, stacked=True)
```

**When to use:**
- Comparing categories
- Showing rankings
- Displaying counts or aggregates

**When NOT to use:**
- Showing continuous data
- Many categories (>15)

#### Histograms

```python
# Histogram
sns.histplot(data=df, x='value', bins=30)

# Histogram with KDE
sns.histplot(data=df, x='value', kde=True)

# Multiple histograms
sns.histplot(data=df, x='value', hue='category', multiple='dodge')
```

**When to use:**
- Showing distribution
- Understanding data shape
- Checking normality

**When NOT to use:**
- Small datasets
- Categorical data

#### Box and Violin Plots

```python
# Box plot
sns.boxplot(data=df, x='category', y='value')

# Violin plot (shows distribution shape)
sns.violinplot(data=df, x='category', y='value')

# Box plot with points
sns.boxplot(data=df, x='category', y='value')
sns.stripplot(data=df, x='category', y='value', alpha=0.3)
```

**When to use:**
- Comparing distributions across categories
- Identifying outliers
- Showing median and spread

**When NOT to use:**
- Very small sample sizes
- When you need exact values

#### Scatter Plots

```python
# Basic scatter
sns.scatterplot(data=df, x='x', y='y')

# Scatter with regression
sns.regplot(data=df, x='x', y='y')

# Scatter with color and size
sns.scatterplot(data=df, x='x', y='y', hue='category', size='value')
```

**When to use:**
- Showing relationships
- Identifying correlations
- Discovering patterns

**When NOT to use:**
- Too many points (>5000)
- No relationship expected

#### Line Charts

```python
# Line chart
sns.lineplot(data=df, x='date', y='value')

# Multiple lines
sns.lineplot(data=df, x='date', y='value', hue='category')

# Confidence band
sns.lineplot(data=df, x='date', y='value', ci=95)
```

**When to use:**
- Showing trends over time
- Continuous data
- Before/after comparisons

**When NOT to use:**
- Categorical x-axis
- No time ordering

---

## P6.3 Color Theory and Best Practices

### P6.3.1 Color Palettes

```python
import seaborn as sns
import plotly.express as px

# Categorical (qualitative)
sns.color_palette('Set2', 8)      # Colorblind-friendly
sns.color_palette('husl', 8)      # Perceptually uniform
px.colors.qualitative.Plotly      # Plotly default

# Sequential (numeric, ordered)
sns.color_palette('viridis', 8)   # Perceptually uniform
sns.color_palette('Blues', 8)     # Single hue

# Diverging (numeric, centered)
sns.color_palette('RdBu_r', 8)    # Red-Blue diverging
sns.color_palette('coolwarm', 8)  # Blue-Red diverging

# Custom palette
custom = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
```

### P6.3.2 Color Blindness Considerations

```python
# Use colorblind-friendly palettes
sns.color_palette('colorblind', 8)  # Seaborn colorblind
sns.color_palette('Set2', 8)        # Also good

# Check with tools
# coblis - color blindness simulator
# vizcheck - check your visualizations

# Guidelines:
# 1. Use shape or pattern in addition to color
# 2. Ensure sufficient contrast
# 3. Test with grayscale
# 4. Don't use red-green together
```

### P6.3.3 Color Usage Guidelines

| Use Case | Best Practice | Why |
|----------|---------------|-----|
| **Categorical** | Distinct hues, limited palette | Easy to distinguish |
| **Sequential** | Single hue, varying intensity | Shows order |
| **Diverging** | Two hues, neutral middle | Shows deviation |
| **Highlighting** | Contrasting color | Draws attention |
| **Background** | Low contrast | Doesn't distract |

**Common Mistakes:**
- Using too many colors
- Using rainbow colormaps
- Not considering color blindness
- Low contrast

---

## P6.4 Data-Ink Ratio (Tufte)

### P6.4.1 Edward Tufte's Principles

**Data-Ink Ratio:** The proportion of ink used to display data vs. total ink.

```python
# ❌ BAD: Low data-ink ratio (excessive decoration)
# Gridlines, borders, 3D effects, unnecessary colors
# vs

# ✅ GOOD: High data-ink ratio
# Clean, minimal, every element serves a purpose
```

**Guidelines:**
1. Remove non-data ink (gridlines, borders, backgrounds)
2. Remove redundant data ink (labels, 3D effects)
3. Maximize data-ink ratio
4. Use color purposefully

### P6.4.2 Applying Tufte's Principles

```python
# ❌ BAD: Cluttered, low data-ink
plt.style.use('default')
fig, ax = plt.subplots()
ax.plot(x, y, 'o-')
ax.grid(True, linestyle='-', linewidth=2, color='gray')
ax.set_title('My Chart', fontsize=20)
ax.set_xlabel('X Axis', fontsize=16)
ax.set_ylabel('Y Axis', fontsize=16)
ax.set_facecolor('lightgray')
# Many borders, decorations

# ✅ GOOD: Clean, high data-ink
plt.style.use('seaborn-v0_8-darkgrid')
fig, ax = plt.subplots()
ax.plot(x, y, 'o-', color='steelblue')
ax.grid(True, alpha=0.3, linestyle='--')
ax.set_title('My Chart', fontsize=14, fontweight='bold')
ax.set_xlabel('X Axis', fontsize=12)
ax.set_ylabel('Y Axis', fontsize=12)
# Minimal, purposeful
```

---

## P6.5 Gestalt Principles for Visualization

### P6.5.1 The Gestalt Principles

| Principle | Definition | Application |
|-----------|------------|-------------|
| **Proximity** | Objects close together are perceived as a group | Group related data |
| **Similarity** | Similar objects are perceived as a group | Consistent colors/shapes |
| **Continuity** | Lines are seen as continuous | Smooth trends |
| **Closure** | Incomplete shapes are completed | Axes, grid lines |
| **Common Fate** | Moving objects are seen as a group | Animated transitions |
| **Figure-Ground** | Foreground/background separation | Highlighting important data |
| **Symmetry** | Symmetrical objects are perceived as a whole | Balanced layouts |

### P6.5.2 Applying Gestalt Principles

```python
# Proximity: Group related data close together
# Similarity: Use same color for same category
# Continuity: Use smooth lines for trends
# Figure-Ground: Use contrast to highlight important data
```

---

## P6.6 Designing for Different Audiences

### P6.6.1 Audience Considerations

| Audience | Focus | Design Choices |
|----------|-------|----------------|
| **Executive** | Key insights, decisions | Simple, big numbers, clear takeaways |
| **Technical** | Details, patterns | More detail, supporting data |
| **General** | Story, context | Explanatory, narrative |
| **Internal** | Actionable insights | Practical, specific |

### P6.6.2 Tailoring Your Visualization

```python
# Executive dashboard - big numbers, simple charts
html.Div([
    dbc.Row([
        dbc.Col([
            html.H2("Total Revenue"),
            html.H1("$1.2M", style={'fontSize': '48px', 'color': 'green'})
        ]),
        dbc.Col([
            dcc.Graph(figure=simple_trend_chart())
        ])
    ])
])

# Technical report - detailed, comprehensive
html.Div([
    dcc.Graph(figure=detailed_trend_with_ci()),
    html.Pre(statistical_summary())
])
```

---

## P6.7 Common Visualization Mistakes

### P6.7.1 Mistakes to Avoid

| Mistake | Why It's Bad | Fix |
|---------|--------------|-----|
| **3D charts** | Distorts perception | Use 2D |
| **Dual axes** | Confuses comparison | Use separate charts |
| **Misleading axes** | Hides or exaggerates differences | Start at 0 |
| **Pie charts with many slices** | Hard to compare | Use bar chart |
| **Too much color** | Overwhelming | Use limited palette |
| **Too little color** | Hard to read | Use contrast |
| **Missing labels** | Unclear what's shown | Label everything |
| **Overlapping data** | Hides information | Use transparency or separate |
| **Chart junk** | Distracts | Remove decorations |

### P6.7.2 Example: Bad vs Good

```python
# ❌ BAD: 3D pie chart with exploded slices
fig = px.pie(df, values='value', names='category', 
             title='Market Share')
fig.update_traces(
    textposition='inside',
    textinfo='percent+label',
    pull=[0.1, 0, 0, 0, 0]  # Exploded
)

# ✅ GOOD: Bar chart (clear comparison)
fig = px.bar(df.sort_values('value', ascending=True),
             x='value', y='category',
             orientation='h',
             title='Market Share',
             text='value')
fig.update_traces(textposition='outside')
fig.update_layout(
    xaxis_title='Share',
    yaxis_title='Category'
)
```

---

## P6.8 Accessibility in Visualizations

### P6.8.1 Accessibility Guidelines

| Aspect | Guideline | Why |
|--------|-----------|-----|
| **Color** | Avoid red-green, use high contrast | Color blindness |
| **Labels** | Clear, descriptive labels | Screen readers |
| **Text** | 12pt minimum, sans-serif | Readability |
| **Alt Text** | Describe the chart | Screen readers |
| **Interactivity** | Keyboard navigable | Motor disabilities |
| **Data** | Provide raw data | Analysis |

### P6.8.2 Implementing Accessibility

```python
# Colorblind-friendly palette
colors = ['#0077BB', '#33BBEE', '#EE7733', '#CC3311']
# Blue, cyan, orange, red (works for most colorblind)

# Alt text for HTML
html.Img(src='chart.png', alt='Bar chart showing revenue by quarter')

# High contrast text
html.H1("Revenue", style={'color': '#000000'})

# Clear labels
ax.set_xlabel("Revenue ($)", fontsize=12)
ax.set_ylabel("Time (months)", fontsize=12)

# Legend placement (avoid overlapping)
ax.legend(loc='upper left', frameon=True, framealpha=0.8)
```

---

## P6.9 Ethical Data Visualization

### P6.9.1 Ethical Principles

1. **Be truthful** - Don't distort data
2. **Show context** - Don't cherry-pick
3. **Be transparent** - Show methods and limitations
4. **Consider impact** - How will it be interpreted?
5. **Respect privacy** - Anonymize sensitive data

### P6.9.2 Common Ethical Violations

```python
# ❌ BAD: Truncated y-axis (exaggerates differences)
ax.set_ylim(90, 100)  # Starting at 90

# ✅ GOOD: Full y-axis with 0 baseline
ax.set_ylim(0, 100)

# ❌ BAD: Cherry-picking time range
filtered = df[df['date'] > '2024-01-01']  # Convenient start

# ✅ GOOD: Show full context
filtered = df[df['date'] > '2023-01-01']

# ❌ BAD: Misleading averages (without showing distribution)
# Report only the mean, hide variation

# ✅ GOOD: Show distribution (mean + error bars)
sns.barplot(data=df, x='category', y='value')
sns.pointplot(data=df, x='category', y='value', ci=95)
```

---

## P6.10 Interactive Visualization Design

### P6.10.1 Interaction Types

| Interaction | Purpose | Example |
|-------------|---------|---------|
| **Hover** | Show details | Tooltips |
| **Zoom** | Explore detail | Pan, zoom |
| **Select** | Filter data | Click, brush |
| **Filter** | Subset data | Dropdowns, sliders |
| **Connect** | Link views | Cross-filtering |
| **Annotate** | Add context | Comments, highlights |

### P6.10.2 Design Guidelines for Interactive Visualizations

```python
# 1. Start with overview (default view)
# 2. Allow zoom and filter (exploration)
# 3. Provide details on demand (hover)
# 4. Link multiple views (cross-filtering)
# 5. Show context (minimap, navigation)

# Example: Interactive dashboard with cross-filtering
@callback(
    Output('chart1', 'figure'),
    Output('chart2', 'figure'),
    Input('chart1', 'selectedData'),
    Input('filter-dropdown', 'value')
)
def update_dashboard(selected, category):
    # Start with overview
    filtered = df[df['category'] == category]
    
    # Apply selection if any
    if selected:
        points = [p['x'] for p in selected['points']]
        filtered = filtered[filtered['x'].isin(points)]
    
    # Update both charts
    fig1 = create_overview(filtered)
    fig2 = create_detail(filtered)
    
    return fig1, fig2
```

---

## P6.11 Animation and Transitions

### P6.11.1 When to Use Animation

| Use Case | Benefit | Risk |
|----------|---------|------|
| **Temporal data** | Shows change over time | Can be distracting |
| **Transitions** | Maintains continuity | Can be misleading |
| **Sequences** | Shows process | Can be complex |
| **Comparison** | Shows before/after | Can hide details |

### P6.11.2 Animation Guidelines

```python
# Good animation: Smooth, purposeful
fig = px.scatter(df, x='x', y='y', 
                 animation_frame='time',
                 title='Data Over Time')

# Bad animation: Fast, confusing
# Use slow, smooth transitions
# Add play/pause controls
# Show current state/step

# Update transitions
fig.layout.updatemenus = [{
    'type': 'buttons',
    'showactive': False,
    'buttons': [
        {'label': 'Play',
         'method': 'animate',
         'args': [None, {'frame': {'duration': 500}}]}
    ]
}]
```

---

## P6.12 Quick Reference: Design Checklist

### Before Creating a Visualization:

- [ ] What is the story you want to tell?
- [ ] Who is the audience?
- [ ] What is the data type?
- [ ] What is the purpose (compare, show, explore)?

### During Creation:

- [ ] Choose appropriate chart type
- [ ] Use effective color palette
- [ ] Label all axes and legends
- [ ] Provide context (annotations)
- [ ] Use high data-ink ratio
- [ ] Make it accessible
- [ ] Test for clarity

### Before Publishing:

- [ ] Check for ethical issues
- [ ] Verify accuracy
- [ ] Get feedback
- [ ] Test interactivity
- [ ] Check accessibility
- [ ] Review for clarity

---

## P6.13 Key Takeaways

1. **Choose the right chart** for your data and purpose
2. **Use color effectively** - purposefully, consistently
3. **Maximize data-ink ratio** - remove decoration
4. **Consider your audience** - tailor complexity
5. **Make it accessible** - colorblind, readable
6. **Be ethical** - truthful, transparent
7. **Test and iterate** - get feedback
8. **Tell a story** - guide the viewer

This primer covers the essential principles of effective data visualization. These guidelines will help you create visualizations that are clear, accurate, and impactful—whether you're creating static figures or interactive dashboards.
