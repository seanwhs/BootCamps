# Appendix A: Complete API Reference for Visualization Libraries

## A Quick Reference Guide for Matplotlib, Seaborn, Altair, and Plotly

---

#### Purpose of This Appendix

This appendix serves as a comprehensive, at-a-glance reference for the four major visualization libraries we used throughout this series. Instead of searching through documentation or remembering syntax, you can quickly look up:

- Common chart types and their syntax
- Key parameters and their purposes
- Styling and customization options
- Best practices and common patterns

---

## A.1 Matplotlib Quick Reference

### A.1.1 Core Architecture

```python
# The Object-Oriented Approach (Recommended)
import matplotlib.pyplot as plt

# Create figure and axes
fig, ax = plt.subplots(figsize=(10, 6))

# Plot data
ax.plot(x, y, 'b-', linewidth=2, label='Line')
ax.scatter(x, y, s=50, c='red', alpha=0.5, label='Points')
ax.bar(x, y, width=0.8, color='steelblue', label='Bars')

# Customize
ax.set_title('Title', fontsize=14, fontweight='bold')
ax.set_xlabel('X Label', fontsize=12)
ax.set_ylabel('Y Label', fontsize=12)
ax.legend(loc='best')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 10)
ax.set_ylim(0, 100)

# Save and show
plt.tight_layout()
plt.savefig('figure.png', dpi=300, bbox_inches='tight')
plt.show()
```

### A.1.2 Common Plot Types

| Plot Type | Syntax | Key Parameters |
|-----------|--------|----------------|
| **Line Plot** | `ax.plot(x, y)` | `color`, `linestyle`, `linewidth`, `marker`, `label` |
| **Scatter Plot** | `ax.scatter(x, y)` | `s` (size), `c` (color), `alpha`, `marker`, `label` |
| **Bar Chart** | `ax.bar(x, height)` | `width`, `bottom`, `align`, `color`, `label` |
| **Histogram** | `ax.hist(data)` | `bins`, `density`, `cumulative`, `color`, `edgecolor` |
| **Box Plot** | `ax.boxplot(data)` | `patch_artist`, `whiskerprops`, `flierprops` |
| **Heatmap** | `ax.imshow(matrix)` | `cmap`, `vmin`, `vmax`, `aspect`, `interpolation` |
| **Error Bars** | `ax.errorbar(x, y, yerr)` | `xerr`, `fmt`, `capsize`, `elinewidth` |
| **Fill Between** | `ax.fill_between(x, y1, y2)` | `where`, `interpolate`, `color`, `alpha` |
| **Pie Chart** | `ax.pie(sizes)` | `labels`, `colors`, `explode`, `autopct`, `shadow` |

### A.1.3 GridSpec Layouts

```python
import matplotlib.gridspec as gridspec

# Basic grid
gs = gridspec.GridSpec(2, 3, figure=fig)

# Unequal sizes
gs = gridspec.GridSpec(2, 3, width_ratios=[1, 2, 1], height_ratios=[1, 2])

# Spanning
ax_big = fig.add_subplot(gs[0:2, 0:2])  # Span rows 0-1, cols 0-1
ax_small = fig.add_subplot(gs[0, 2])    # Single cell

# Nested grids
inner_gs = gridspec.GridSpecFromSubplotSpec(2, 2, subplot_spec=gs[1, 0])
```

### A.1.4 Customization Cheat Sheet

| Element | Method | Common Parameters |
|---------|--------|-------------------|
| **Title** | `ax.set_title()` | `fontsize`, `fontweight`, `pad`, `color` |
| **Labels** | `ax.set_xlabel()` | `fontsize`, `labelpad`, `color` |
| **Ticks** | `ax.tick_params()` | `labelsize`, `rotation`, `width`, `length` |
| **Grid** | `ax.grid()` | `linestyle`, `linewidth`, `alpha`, `color` |
| **Spines** | `ax.spines['top'].set_visible()` | `color`, `linewidth`, `position` |
| **Legend** | `ax.legend()` | `loc`, `frameon`, `fancybox`, `shadow` |
| **Colorbar** | `fig.colorbar()` | `shrink`, `aspect`, `pad`, `label` |
| **Annotation** | `ax.annotate()` | `xy`, `xytext`, `arrowprops`, `bbox` |
| **Text** | `ax.text()` | `transform`, `ha`, `va`, `fontsize` |

### A.1.5 Color and Style Shortcuts

```python
# Line styles
linestyles = ['-', '--', '-.', ':', 'solid', 'dashed', 'dashdot', 'dotted']

# Markers
markers = ['.', ',', 'o', 'v', '^', '<', '>', 's', 'p', '*', 'h', 'H', 'D', 'd']

# Common colors (named)
colors = ['blue', 'green', 'red', 'cyan', 'magenta', 'yellow', 'black', 'white']

# Matplotlib colormaps
colormaps = ['viridis', 'plasma', 'inferno', 'magma', 'cividis', 
             'RdBu', 'coolwarm', 'Spectral', 'seismic', 'turbo']
```

---

## A.2 Seaborn Quick Reference

### A.2.1 Setup and Styling

```python
import seaborn as sns

# Set style
sns.set_theme(style='darkgrid')  # 'darkgrid', 'whitegrid', 'dark', 'white', 'ticks'
sns.set_context('notebook')      # 'paper', 'notebook', 'talk', 'poster'
sns.set_palette('husl')          # 'deep', 'muted', 'pastel', 'bright', 'dark', 'colorblind'

# Custom sizes
sns.set_context('paper', font_scale=1.5, rc={'figure.figsize': (12, 8)})
```

### A.2.2 Distribution Plots

| Function | Purpose | Key Parameters |
|----------|---------|----------------|
| `sns.histplot()` | Histogram with KDE option | `bins`, `kde`, `stat`, `cumulative` |
| `sns.kdeplot()` | Kernel density estimate | `bw_adjust`, `fill`, `multiple`, `cut` |
| `sns.ecdfplot()` | Empirical cumulative distribution | `stat`, `complementary` |
| `sns.rugplot()` | Rug plot for small data | `height`, `expand_margins` |
| `sns.displot()` | Figure-level distribution | `kind`, `col`, `row`, `height` |

```python
# Examples
sns.histplot(data=df, x='age', bins=30, kde=True, color='steelblue')
sns.kdeplot(data=df, x='age', fill=True, bw_adjust=0.5)
sns.ecdfplot(data=df, x='age', stat='count')
sns.rugplot(data=df, x='age', height=0.05)
sns.displot(data=df, x='age', col='gender', kind='kde')
```

### A.2.3 Categorical Plots

| Function | Purpose | Key Parameters |
|----------|---------|----------------|
| `sns.boxplot()` | Box and whisker plot | `orient`, `width`, `dodge` |
| `sns.violinplot()` | Violin plot with KDE | `inner`, `scale`, `split` |
| `sns.boxenplot()` | Enhanced box plot | `k_depth`, `outlier_prop` |
| `sns.pointplot()` | Point estimates | `capsize`, `errwidth`, `join` |
| `sns.barplot()` | Bar chart with error bars | `errwidth`, `capsize`, `estimator` |
| `sns.countplot()` | Count of categorical values | `order`, `hue_order` |
| `sns.stripplot()` | Scatter-like categorical | `jitter`, `size`, `dodge` |
| `sns.swarmplot()` | Non-overlapping points | `dodge`, `size`, `order` |

```python
# Examples
sns.boxplot(data=df, x='income_bracket', y='avg_order_value')
sns.violinplot(data=df, x='income_bracket', y='avg_order_value', inner='quartile')
sns.pointplot(data=df, x='category', y='rating', capsize=0.2)
sns.barplot(data=df, x='category', y='value', estimator='mean')
sns.countplot(data=df, x='favorite_category', hue='gender')
sns.swarmplot(data=df, x='income_bracket', y='avg_order_value', size=3)
```

### A.2.4 Regression and Matrix Plots

| Function | Purpose | Key Parameters |
|----------|---------|----------------|
| `sns.regplot()` | Scatter with regression | `ci`, `scatter_kws`, `line_kws` |
| `sns.lmplot()` | Faceted regression | `col`, `row`, `hue`, `order` |
| `sns.residplot()` | Residual plot | `lowess`, `order` |
| `sns.heatmap()` | Correlation heatmap | `annot`, `fmt`, `cmap`, `mask` |
| `sns.clustermap()` | Hierarchically clustered heatmap | `method`, `metric`, `figsize` |

```python
# Examples
sns.regplot(data=df, x='time_on_site', y='pages_viewed', ci=95)
sns.lmplot(data=df, x='time_on_site', y='pages_viewed', hue='gender', col='income_bracket')
sns.residplot(data=df, x='time_on_site', y='pages_viewed', lowess=True)
sns.heatmap(df.corr(), annot=True, cmap='RdBu_r', center=0)
```

### A.2.5 Multi-Plot Grids

```python
# FacetGrid - create grid of subplots
g = sns.FacetGrid(df, col='income_bracket', row='gender', height=4)
g.map(sns.histplot, 'age')
g.set_axis_labels('Age', 'Count')
g.add_legend()

# PairGrid - pairwise relationships
g = sns.PairGrid(df[['age', 'order_frequency', 'avg_order_value']])
g.map_upper(sns.scatterplot)
g.map_lower(sns.kdeplot)
g.map_diag(sns.histplot)

# PairPlot - quick pairwise
sns.pairplot(df, hue='income_bracket', diag_kind='kde')

# JointGrid - bivariate with marginals
g = sns.JointGrid(data=df, x='order_frequency', y='avg_order_value')
g.plot(sns.scatterplot, sns.histplot)
```

### A.2.6 Color Palettes

```python
# Qualitative (categorical)
sns.color_palette('deep', 8)
sns.color_palette('husl', 8)
sns.color_palette('Set2', 8)

# Sequential (numeric, ordered)
sns.color_palette('Blues', 8)
sns.color_palette('viridis', 8)

# Diverging (numeric, centered)
sns.color_palette('RdBu_r', 8)
sns.color_palette('coolwarm', 8)

# Custom
custom_palette = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
sns.set_palette(custom_palette)
```

---

## A.3 Altair Quick Reference

### A.3.1 Basic Chart Structure

```python
import altair as alt

# Core pattern: Chart + Mark + Encode
chart = alt.Chart(data).mark_type().encode(
    x=alt.X('column:Q', title='X Axis'),
    y=alt.Y('column:Q', title='Y Axis'),
    color=alt.Color('column:N', title='Legend'),
    tooltip=['col1', 'col2']
).properties(
    title='Chart Title',
    width=600,
    height=400
).interactive()
```

### A.3.2 Mark Types

| Mark | Purpose | Syntax |
|------|---------|--------|
| `mark_point()` | Scatter plot | `.mark_point(size=60, opacity=0.7)` |
| `mark_circle()` | Scatter with circles | `.mark_circle(size=60)` |
| `mark_square()` | Scatter with squares | `.mark_square(size=50)` |
| `mark_bar()` | Bar chart | `.mark_bar(cornerRadiusTopLeft=3)` |
| `mark_line()` | Line chart | `.mark_line(strokeWidth=2)` |
| `mark_area()` | Area chart | `.mark_area(opacity=0.5)` |
| `mark_rect()` | Heatmap/rectangle | `.mark_rect()` |
| `mark_text()` | Text labels | `.mark_text(fontSize=12)` |
| `mark_boxplot()` | Box plot | `.mark_boxplot(extent='min-max')` |
| `mark_errorbar()` | Error bars | `.mark_errorbar()` |
| `mark_tick()` | Tick plot | `.mark_tick()` |
| `mark_rule()` | Rule/line | `.mark_rule()` |

### A.3.3 Encoding Types

| Encoding | Purpose | Syntax |
|----------|---------|--------|
| **Position** | X-axis | `alt.X('column:Q', title='Label')` |
| **Position** | Y-axis | `alt.Y('column:Q', title='Label')` |
| **Color** | Color encoding | `alt.Color('column:N', scale=alt.Scale(scheme='category10'))` |
| **Size** | Size encoding | `alt.Size('column:Q', legend=alt.Legend(title='Size'))` |
| **Shape** | Shape encoding | `alt.Shape('column:N', scale=alt.Scale(scheme='category10'))` |
| **Opacity** | Opacity encoding | `alt.Opacity('column:Q', legend=None)` |
| **Tooltip** | Hover info | `alt.Tooltip('column:Q', title='Label', format='.2f')` |
| **Facet** | Split into grid | `alt.Facet('column:N', columns=3)` |
| **Row** | Row facet | `alt.Row('column:N')` |
| **Column** | Column facet | `alt.Column('column:N')` |

### A.3.4 Data Types

| Type | Description | Example |
|------|-------------|---------|
| `:Q` | Quantitative (numeric) | `age:Q`, `value:Q` |
| `:N` | Nominal (categorical) | `gender:N`, `category:N` |
| `:O` | Ordinal (ordered categories) | `income:O`, `rank:O` |
| `:T` | Temporal (date/time) | `date:T`, `timestamp:T` |

### A.3.5 Common Transformations

```python
# Aggregation
chart.transform_aggregate(
    mean_value='mean(value)',
    groupby=['category']
)

# Binning
chart.transform_bin(
    'age_binned',
    field='age',
    bin=alt.Bin(maxbins=10)
)

# Filtering
chart.transform_filter(
    alt.datum.income > 50000
)

# Calculation
chart.transform_calculate(
    'value_squared', 'datum.value * datum.value'
)

# Density estimation
chart.transform_density(
    'value',
    as_=['value', 'density']
)

# Window functions
chart.transform_window(
    rank='rank()',
    sort=[alt.SortField('value', order='descending')]
)

# Stacking
chart.transform_stack(
    'value',
    as_=['start', 'end'],
    groupby=['category']
)
```

### A.3.6 Interactive Components

```python
# Selection types
selection = alt.selection_interval()  # Rectangular selection
selection = alt.selection_point()     # Click selection
selection = alt.selection_single()    # Single selection

# Binding
slider = alt.binding_range(min=0, max=100, step=1)
selection = alt.selection_single(
    fields=['value'],
    bind=slider,
    name='slider'
)

dropdown = alt.binding_select(
    options=['A', 'B', 'C'],
    name='Select: '
)
selection = alt.selection_single(
    fields=['category'],
    bind=dropdown
)

# Conditional encoding
color = alt.condition(
    selection,
    alt.ColorValue('red'),       # Selected
    alt.ColorValue('lightgray')  # Not selected
)
```

### A.3.7 Combining Charts

```python
# Layer charts (same axes)
layered = alt.layer(chart1, chart2, chart3)

# Horizontal concatenation
hconcat = alt.hconcat(chart1, chart2, chart3)

# Vertical concatenation
vconcat = alt.vconcat(chart1, chart2, chart3)

# Facet
facet = chart.facet(facet=alt.Facet('category:N', columns=3))
```

---

## A.4 Plotly Quick Reference

### A.4.1 Plotly Express (High-Level)

```python
import plotly.express as px

# Common chart types
fig = px.scatter(df, x='col1', y='col2', color='category')
fig = px.line(df, x='date', y='value', color='category')
fig = px.bar(df, x='category', y='value', color='group')
fig = px.histogram(df, x='value', nbins=30, color='group')
fig = px.box(df, x='category', y='value', color='group')
fig = px.violin(df, x='category', y='value', box=True)
fig = px.heatmap(df, x='col1', y='col2', z='value')
fig = px.scatter_3d(df, x='x', y='y', z='z', color='category')
fig = px.scatter_mapbox(df, lat='lat', lon='lon', color='category')
fig = px.choropleth(df, locations='country', color='value')
```

### A.4.2 Plotly Express Parameters

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `data_frame` | DataFrame | `df` |
| `x`, `y`, `z` | Variables | `x='age'`, `y='value'` |
| `color` | Color encoding | `color='category'` |
| `size` | Size encoding | `size='value'` |
| `symbol` | Symbol encoding | `symbol='group'` |
| `hover_name` | Name on hover | `hover_name='customer_id'` |
| `hover_data` | Additional hover | `hover_data=['age', 'income']` |
| `title` | Chart title | `title='My Chart'` |
| `template` | Style template | `template='plotly_white'` |
| `width` | Width in pixels | `width=800` |
| `height` | Height in pixels | `height=600` |
| `log_x` | Log scale x | `log_x=True` |
| `log_y` | Log scale y | `log_y=True` |
| `trendline` | Trend line | `trendline='ols'` |
| `marginal` | Marginal plot | `marginal='box'` |
| `barmode` | Bar mode | `barmode='group'` |
| `orientation` | Bar orientation | `orientation='h'` |

### A.4.3 Plotly Graph Objects (Low-Level)

```python
import plotly.graph_objects as go

# Creating traces
fig = go.Figure()

# Scatter
fig.add_trace(go.Scatter(
    x=df['x'],
    y=df['y'],
    mode='markers+lines',
    name='Trace Name',
    marker=dict(size=10, color='red'),
    line=dict(width=2, dash='dash'),
    hovertemplate='Value: %{y}<extra></extra>'
))

# Bar
fig.add_trace(go.Bar(
    x=df['category'],
    y=df['value'],
    name='Bars',
    marker=dict(color='steelblue')
))

# Histogram
fig.add_trace(go.Histogram(
    x=df['value'],
    nbinsx=30,
    marker=dict(color='steelblue')
))

# Box
fig.add_trace(go.Box(
    x=df['category'],
    y=df['value'],
    boxmean='sd'
))

# Heatmap
fig.add_trace(go.Heatmap(
    z=matrix,
    x=columns,
    y=rows,
    colorscale='Viridis'
))

# 3D Scatter
fig.add_trace(go.Scatter3d(
    x=df['x'],
    y=df['y'],
    z=df['z'],
    mode='markers',
    marker=dict(size=5)
))
```

### A.4.4 Layout Customization

```python
fig.update_layout(
    title='Chart Title',
    title_font=dict(size=20, family='Arial', color='black'),
    xaxis_title='X Axis',
    yaxis_title='Y Axis',
    xaxis=dict(
        title_font=dict(size=14),
        tickfont=dict(size=12),
        gridcolor='lightgray',
        gridwidth=1,
        zeroline=True,
        zerolinecolor='black'
    ),
    yaxis=dict(
        title_font=dict(size=14),
        tickfont=dict(size=12)
    ),
    legend=dict(
        title='Legend',
        yanchor='top',
        y=0.99,
        xanchor='left',
        x=0.01
    ),
    template='plotly_white',
    width=800,
    height=600,
    hovermode='closest',
    margin=dict(l=50, r=50, t=80, b=50)
)
```

### A.4.5 Interactive Components

```python
# Updatemenus (dropdowns)
fig.update_layout(
    updatemenus=[dict(
        type='dropdown',
        buttons=[
            dict(label='Option 1', method='update', args=[{'visible': [True, False]}]),
            dict(label='Option 2', method='update', args=[{'visible': [False, True]}])
        ],
        direction='down',
        showactive=True,
        x=0.02,
        y=0.98
    )]
)

# Sliders
fig.update_layout(
    sliders=[dict(
        active=0,
        steps=[
            dict(method='update', args=[{'visible': [True, False]}], label='Step 1'),
            dict(method='update', args=[{'visible': [False, True]}], label='Step 2')
        ],
        currentvalue={'prefix': 'Value: '}
    )]
)

# Animation
fig.frames = [
    go.Frame(data=[go.Scatter(x=frame_data['x'], y=frame_data['y'])])
    for frame_data in frames
]

# Annotations
fig.add_annotation(
    x=0.5,
    y=0.5,
    text='Annotation',
    showarrow=True,
    arrowhead=2,
    ax=20,
    ay=-30
)

# Shapes
fig.add_shape(
    type='rect',
    x0=0, x1=1,
    y0=0, y1=1,
    line=dict(color='red', width=2),
    fillcolor='rgba(255,0,0,0.1)'
)
```

### A.4.6 Subplots

```python
from plotly.subplots import make_subplots

fig = make_subplots(
    rows=2,
    cols=2,
    subplot_titles=('Plot 1', 'Plot 2', 'Plot 3', 'Plot 4'),
    shared_xaxes=True,
    shared_yaxes=False,
    specs=[
        [{'type': 'scatter'}, {'type': 'bar'}],
        [{'type': 'histogram'}, {'type': 'box'}]
    ]
)

# Add traces to specific subplots
fig.add_trace(go.Scatter(x=x, y=y), row=1, col=1)
fig.add_trace(go.Bar(x=x, y=y), row=1, col=2)
fig.add_trace(go.Histogram(x=x), row=2, col=1)
fig.add_trace(go.Box(x=x, y=y), row=2, col=2)

# Update axes for subplots
fig.update_xaxes(title_text='X Axis 1', row=1, col=1)
fig.update_yaxes(title_text='Y Axis 1', row=1, col=1)
```

### A.4.7 Color Scales

```python
# Sequential (numeric, ordered)
colorscale = 'Blues'     # Single color, light to dark
colorscale = 'Viridis'   # Perceptually uniform
colorscale = 'Plasma'    # Vibrant
colorscale = 'Cividis'   # Colorblind-friendly

# Diverging (numeric, centered)
colorscale = 'RdBu'      # Red-Blue
colorscale = 'RdYlGn'    # Red-Yellow-Green
colorscale = 'Spectral'  # Full spectrum

# Qualitative (categorical, discrete)
color_discrete_sequence = px.colors.qualitative.Set2
color_discrete_sequence = px.colors.qualitative.Plotly

# Custom scales
colorscale = [
    [0, 'rgb(0,0,255)'],
    [0.5, 'rgb(255,255,255)'],
    [1, 'rgb(255,0,0)']
]
```

### A.4.8 Common Styling Shortcuts

```python
# Update all traces
fig.update_traces(
    marker=dict(line=dict(width=1, color='white'))
)

# Update axes
fig.update_xaxes(
    showgrid=True,
    gridcolor='lightgray',
    gridwidth=1,
    zeroline=True,
    zerolinecolor='black'
)

# Update layout
fig.update_layout(
    hovermode='x unified',  # 'x', 'y', 'closest'
    bargap=0.1,
    bargroupgap=0.05
)

# Remove legend
fig.update_layout(showlegend=False)

# Set background
fig.update_layout(
    plot_bgcolor='rgba(0,0,0,0)',
    paper_bgcolor='rgba(0,0,0,0)'
)
```

---

## A.5 Quick Comparison: When to Use Which Library

| Scenario | Matplotlib | Seaborn | Altair | Plotly |
|----------|------------|---------|--------|--------|
| **Publication-ready static figures** | ✅ Best | ✅ Excellent | ✅ Good | ❌ Limited |
| **Quick exploratory plots** | ⚠️ Verbose | ✅ Excellent | ✅ Good | ✅ Excellent |
| **Statistical analysis** | ⚠️ Manual | ✅ Built-in | ⚠️ Limited | ⚠️ Limited |
| **Interactive exploration** | ❌ No | ❌ No | ✅ Excellent | ✅ Best |
| **Web dashboards** | ❌ No | ❌ No | ✅ Good | ✅ Best |
| **Complex custom layouts** | ✅ Best | ⚠️ Limited | ⚠️ Limited | ⚠️ Limited |
| **Large datasets (>10k)** | ✅ Good | ✅ Good | ⚠️ Slow | ✅ Good |
| **3D visualizations** | ⚠️ Basic | ❌ No | ❌ No | ✅ Excellent |
| **Learning curve** | Steep | Moderate | Moderate | Easy |

---

## A.6 Common Patterns and Snippets

### A.6.1 Saving Figures

```python
# Matplotlib
plt.savefig('figure.png', dpi=300, bbox_inches='tight')

# Seaborn (uses matplotlib)
sns_plot = sns.histplot(data=df, x='age')
plt.savefig('figure.png', dpi=300)

# Altair
chart.save('chart.html')
chart.save('chart.png')  # Requires selenium and chromedriver
chart.save('chart.json')

# Plotly
fig.write_html('figure.html')
fig.write_image('figure.png')  # Requires kaleido
fig.write_json('figure.json')
```

### A.6.2 Figure Sizing Reference

| Use Case | Matplotlib (figsize) | Altair (width, height) | Plotly (width, height) |
|----------|----------------------|------------------------|----------------------|
| Presentation | (12, 8) | 800, 600 | 900, 600 |
| Publication | (6, 4) | 400, 300 | 500, 400 |
| Notebook | (10, 6) | 600, 400 | 700, 500 |
| Dashboard | (14, 10) | 1000, 700 | 1200, 800 |

### A.6.3 DPI and Resolution Reference

| Purpose | DPI | Output Size |
|---------|-----|-------------|
| Web/Notebook | 72-100 | 800-1200px wide |
| Presentation | 150-200 | 1200-1600px wide |
| Print (low quality) | 150 | 1500-2000px wide |
| Print (high quality) | 300 | 3000-4000px wide |
| Vector format | N/A | Any size (scalable) |

---

## A.7 Troubleshooting Common Issues

### A.7.1 Matplotlib Issues

| Issue | Solution |
|-------|----------|
| **Missing fonts** | `plt.rcParams['font.family'] = 'sans-serif'` |
| **Too many subplots** | Use `plt.tight_layout()` |
| **Overlapping labels** | `plt.tight_layout()` or `fig.subplots_adjust()` |
| **Memory error** | `plt.close('all')` to close figures |
| **Interactive mode** | `plt.ion()` for interactive, `plt.ioff()` for non-interactive |

### A.7.2 Seaborn Issues

| Issue | Solution |
|-------|----------|
| **Style not applying** | Call `sns.set_theme()` before plotting |
| **Color palette not working** | `sns.set_palette('husl')` |
| **KDE bandwidth too small** | `bw_adjust=0.5` in `kdeplot` |
| **Boxplot not showing** | Check data types (need numeric y) |
| **PairGrid too slow** | Reduce number of columns or sample data |

### A.7.3 Altair Issues

| Issue | Solution |
|-------|----------|
| **Data too large** | Use `alt.data_transformers.disable_max_rows()` |
| **Chart not rendering in Jupyter** | `alt.renderers.enable('notebook')` |
| **Interactive not working** | Call `.interactive()` on chart |
| **Tooltip not showing** | `tooltip` encoding in `encode()` |
| **Colormap not working** | Use `Scale(scheme='viridis')` |

### A.7.4 Plotly Issues

| Issue | Solution |
|-------|----------|
| **Chart not showing in Jupyter** | `fig.show()` |
| **Image export failing** | `pip install kaleido` |
| **Slow rendering** | Reduce data size or use `scattergl` |
| **Legend overlapping** | `fig.update_layout(legend=dict(yanchor='top', y=0.99))` |
| **3D chart not rotating** | Add `config={'displayModeBar': True}` |

---

## A.8 Quick Reference Cards

### Matplotlib Quick Reference Card

```python
# Colors
'blue', 'green', 'red', 'cyan', 'magenta', 'yellow', 'black', 'white'
'#FF5733', 'rgba(255,87,51,0.5)'

# Line Styles
'-', '--', '-.', ':', 'solid', 'dashed', 'dashdot', 'dotted'

# Markers
'.', ',', 'o', 'v', '^', '<', '>', 's', 'p', '*', 'h', 'H', 'D', 'd'

# Common Patterns
fig, axes = plt.subplots(2, 2, figsize=(12, 8))
ax = fig.add_subplot(gs[0:2, 0:2])
ax.set_xlim(0, 10)
ax.set_ylim(0, 100)
ax.legend(loc='best')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('file.png', dpi=300, bbox_inches='tight')
```

### Seaborn Quick Reference Card

```python
# Distribution
sns.histplot(data=df, x='col', kde=True)
sns.kdeplot(data=df, x='col', fill=True)

# Categorical
sns.boxplot(data=df, x='cat', y='num')
sns.violinplot(data=df, x='cat', y='num')
sns.barplot(data=df, x='cat', y='num')

# Regression
sns.regplot(data=df, x='col1', y='col2', ci=95)
sns.lmplot(data=df, x='col1', y='col2', hue='cat')

# Grids
sns.pairplot(df, hue='cat')
sns.FacetGrid(df, col='cat').map(sns.histplot, 'col')
```

### Altair Quick Reference Card

```python
# Basic
alt.Chart(df).mark_point().encode(
    x='col1:Q',
    y='col2:Q',
    color='cat:N'
).interactive()

# Common Marks
.mark_bar()      # Bar chart
.mark_line()     # Line chart
.mark_circle()   # Scatter
.mark_boxplot()  # Box plot

# Interactive
alt.selection_interval()
alt.selection_point()
```

### Plotly Quick Reference Card

```python
# Express
px.scatter(df, x='col1', y='col2', color='cat')
px.bar(df, x='cat', y='num')
px.histogram(df, x='col', nbins=30)

# Graph Objects
go.Figure()
fig.add_trace(go.Scatter(x=x, y=y, mode='markers'))
fig.add_trace(go.Bar(x=x, y=y))

# Layout
fig.update_layout(title='Title', xaxis_title='X', yaxis_title='Y')
fig.update_traces(marker=dict(size=10))

# Interactive
fig.write_html('file.html')
fig.write_image('file.png')
```

---

[END OF APPENDIX A]
