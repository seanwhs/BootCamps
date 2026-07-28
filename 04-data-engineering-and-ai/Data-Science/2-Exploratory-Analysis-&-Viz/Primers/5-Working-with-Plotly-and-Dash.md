# Primer 5: Working with Plotly and Dash

## Essential Concepts for Interactive Visualization and Web Dashboards

---

#### Purpose of This Primer

This primer covers the core concepts and patterns for working with Plotly and Dash that you'll encounter throughout the series. While the main tutorials focus on building specific visualizations and dashboards, this primer explains the underlying architecture, key components, and common patterns that make these tools powerful and flexible.

---

## P5.1 Plotly Fundamentals

### P5.1.1 The Plotly Ecosystem

```
Plotly.py
    ├── Plotly Express (px) - High-level API
    │   └── One-line charts for common types
    ├── Graph Objects (go) - Low-level API
    │   └── Fine-grained control over every element
    └── Dash - Web framework
        └── Interactive dashboards with Plotly charts
```

**When to use each:**

| API | Use Case | Example |
|-----|----------|---------|
| **Plotly Express** | Quick, common charts | `px.scatter(df, x='age', y='value')` |
| **Graph Objects** | Custom charts, complex layouts | `go.Figure(data=[go.Scatter(...)])` |
| **Dash** | Interactive web apps | `dash.Dash()` with callbacks |

### P5.1.2 Plotly Express (px)

Plotly Express is the high-level API that creates complete figures with minimal code.

```python
import plotly.express as px
import pandas as pd

# Basic scatter plot
fig = px.scatter(
    df,
    x='age',
    y='order_frequency',
    color='income_bracket',
    size='avg_order_value',
    hover_data=['customer_id', 'customer_rating'],
    title='Customer Behavior Analysis',
    template='plotly_white'
)

# Common chart types
fig = px.line(df, x='date', y='value', color='category')        # Line chart
fig = px.bar(df, x='category', y='value', color='group')        # Bar chart
fig = px.histogram(df, x='value', nbins=30)                     # Histogram
fig = px.box(df, x='category', y='value', color='group')        # Box plot
fig = px.violin(df, x='category', y='value', box=True)          # Violin plot
fig = px.heatmap(df, x='col1', y='col2', z='value')             # Heatmap
fig = px.scatter_3d(df, x='x', y='y', z='z', color='category')  # 3D scatter
fig = px.scatter_mapbox(df, lat='lat', lon='lon')               # Map

# Display
fig.show()
```

### P5.1.3 Plotly Express Parameters

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `data_frame` | Source data | `df` |
| `x`, `y`, `z` | Column names | `x='age', y='value'` |
| `color` | Color encoding | `color='category'` |
| `size` | Size encoding | `size='value'` |
| `symbol` | Symbol encoding | `symbol='group'` |
| `hover_name` | Name on hover | `hover_name='customer_id'` |
| `hover_data` | Additional hover data | `hover_data=['age', 'income']` |
| `title` | Chart title | `title='My Chart'` |
| `template` | Style template | `template='plotly_white'` |
| `width`/`height` | Dimensions | `width=800, height=600` |
| `log_x`/`log_y` | Log scale | `log_x=True` |
| `trendline` | Trend line | `trendline='ols'` |
| `marginal` | Marginal plot | `marginal='box'` |
| `barmode` | Bar mode | `barmode='group'` |
| `orientation` | Bar orientation | `orientation='h'` |

### P5.1.4 Graph Objects (go)

Graph Objects is the low-level API that gives you complete control.

```python
import plotly.graph_objects as go

# Creating a figure
fig = go.Figure()

# Adding traces
fig.add_trace(go.Scatter(
    x=df['age'],
    y=df['order_frequency'],
    mode='markers+lines',
    name='Customer Data',
    marker=dict(
        size=10,
        color=df['income_numeric'],
        colorscale='Viridis',
        showscale=True,
        colorbar=dict(title='Income Level')
    ),
    line=dict(
        width=2,
        dash='dash'
    ),
    hovertemplate='<b>Age: %{x}</b><br>Frequency: %{y}<extra></extra>'
))

# Adding multiple traces
fig.add_trace(go.Bar(
    x=df['category'],
    y=df['value'],
    name='Bars',
    marker=dict(color='steelblue')
))

# Customizing layout
fig.update_layout(
    title='Custom Chart',
    title_font=dict(size=20, family='Arial'),
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
    hovermode='closest'
)

# Display
fig.show()
```

---

## P5.2 Interactive Features

### P5.2.1 Hover and Tooltips

```python
# Custom hover template
fig = px.scatter(df, x='age', y='value')
fig.update_traces(
    hovertemplate='<b>Age: %{x}</b><br>Value: %{y}<br>Customer: %{customdata}<extra></extra>',
    customdata=df['customer_id']
)

# Multiple hover data
fig = px.scatter(
    df,
    x='age',
    y='value',
    hover_data=['income', 'rating', 'category']
)
```

### P5.2.2 Zoom and Pan

Built into all Plotly charts. No additional code needed.

```python
# Configure interaction options
fig.update_layout(
    dragmode='zoom',  # 'zoom', 'pan', 'select', 'lasso', 'orbit'
    hovermode='closest'  # 'x', 'y', 'closest', False
)

# Restrict zoom range
fig.update_xaxes(range=[0, 100])
fig.update_yaxes(range=[0, 100])
```

### P5.2.3 Selection and Highlighting

```python
# Click selection (highlights selected points)
fig = px.scatter(df, x='age', y='value')
fig.update_traces(
    selected=dict(marker=dict(color='red', size=15)),
    unselected=dict(marker=dict(opacity=0.3))
)

# Lasso and box selection
fig.update_layout(
    dragmode='lasso'  # 'lasso', 'select'
)
```

### P5.2.4 Legend Interaction

```python
# Click legend to toggle traces
fig = px.scatter(df, x='age', y='value', color='category')

# Customize legend
fig.update_layout(
    legend=dict(
        title='Categories',
        orientation='h',  # Horizontal
        yanchor='bottom',
        y=1.02,
        xanchor='right',
        x=1,
        bgcolor='rgba(255,255,255,0.8)'
    ),
    legend_traceorder='reversed'  # Reverse order
)

# Hide legend
fig.update_layout(showlegend=False)
```

---

## P5.3 Dash Fundamentals

### P5.3.1 The Dash Architecture

```
Browser (User Interface)
    ↑ ↓
Dash Server (Python)
    ├── Layout (HTML components)
    │   ├── dcc.Graph (Plotly charts)
    │   ├── dcc.Dropdown (Filter controls)
    │   ├── dcc.Slider (Range controls)
    │   └── html components (Structure)
    └── Callbacks (Interactivity)
        ├── Input (User actions)
        └── Output (Component updates)
```

### P5.3.2 Basic Dash App Structure

```python
import dash
from dash import dcc, html, Input, Output
import plotly.express as px
import pandas as pd

# Load data
df = pd.read_csv('data.csv')

# Initialize app
app = dash.Dash(__name__)

# Define layout
app.layout = html.Div([
    html.H1("My Dashboard"),
    
    # Dropdown filter
    dcc.Dropdown(
        id='filter-dropdown',
        options=[{'label': 'All', 'value': 'All'}] +
                [{'label': cat, 'value': cat} for cat in df['category'].unique()],
        value='All'
    ),
    
    # Chart
    dcc.Graph(id='main-chart'),
    
    # HTML components
    html.Div(id='output-div')
])

# Define callback
@callback(
    Output('main-chart', 'figure'),
    Output('output-div', 'children'),
    Input('filter-dropdown', 'value')
)
def update_chart(selected_category):
    # Filter data
    if selected_category == 'All':
        filtered_df = df
    else:
        filtered_df = df[df['category'] == selected_category]
    
    # Create chart
    fig = px.scatter(filtered_df, x='age', y='value')
    
    # Return updates
    return fig, f"Showing {len(filtered_df)} records"

# Run app
if __name__ == '__main__':
    app.run_server(debug=True)
```

### P5.3.3 Dash Components Overview

#### Core Components (dcc)

```python
# Graph
dcc.Graph(
    id='chart',
    figure=fig,
    config={'displayModeBar': True, 'responsive': True},
    className='custom-chart'
)

# Dropdown
dcc.Dropdown(
    id='dropdown',
    options=[
        {'label': 'Option 1', 'value': 'opt1'},
        {'label': 'Option 2', 'value': 'opt2'}
    ],
    value='opt1',  # Default value
    placeholder='Select an option',
    multi=True,  # Allow multiple selections
    clearable=True,
    className='custom-dropdown'
)

# Slider
dcc.Slider(
    id='slider',
    min=0,
    max=100,
    step=1,
    value=50,
    marks={i: str(i) for i in range(0, 101, 10)},
    tooltip={'placement': 'bottom', 'always_visible': True}
)

# Range Slider
dcc.RangeSlider(
    id='range-slider',
    min=0,
    max=100,
    step=1,
    value=[20, 80],
    marks={i: str(i) for i in range(0, 101, 20)}
)

# Radio Items
dcc.RadioItems(
    id='radio',
    options=[
        {'label': 'Option 1', 'value': 'opt1'},
        {'label': 'Option 2', 'value': 'opt2'}
    ],
    value='opt1',
    inline=True
)

# Checkbox
dcc.Checklist(
    id='checklist',
    options=[
        {'label': 'Option 1', 'value': 'opt1'},
        {'label': 'Option 2', 'value': 'opt2'}
    ],
    value=['opt1'],
    inline=True
)

# Input
dcc.Input(
    id='input',
    type='text',
    placeholder='Enter text...',
    value='Initial value',
    debounce=True  # Wait for user to finish typing
)

# Store (for caching data)
dcc.Store(
    id='data-store',
    data=df.to_dict('records')
)

# Loading indicator
dcc.Loading(
    id='loading',
    type='circle',  # 'graph', 'cube', 'circle', 'dot', 'default'
    children=[
        dcc.Graph(id='slow-chart')
    ]
)

# Interval (for polling)
dcc.Interval(
    id='interval',
    interval=60000,  # 60 seconds
    n_intervals=0
)

# Download
dcc.Download(id='download')
```

#### HTML Components (html)

```python
import dash_bootstrap_components as dbc

# Basic HTML
html.Div([
    html.H1("Title", className="text-center"),
    html.P("Paragraph text", style={'color': 'blue'}),
    html.Hr(),
    html.Br(),
    html.A("Link", href="https://example.com"),
    html.Img(src="image.png", style={'width': '100%'}),
    html.Table([
        html.Thead([
            html.Tr([
                html.Th("Header 1"),
                html.Th("Header 2")
            ])
        ]),
        html.Tbody([
            html.Tr([
                html.Td("Row 1, Col 1"),
                html.Td("Row 1, Col 2")
            ])
        ])
    ])
])

# Bootstrap Components (dbc)
dbc.Container([
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Card Header"),
                dbc.CardBody([
                    html.H5("Card Title"),
                    html.P("Card content")
                ]),
                dbc.CardFooter("Card Footer")
            ])
        ], md=4),
        dbc.Col([
            dbc.Button("Button", color="primary", className="mr-2"),
            dbc.Button("Button", color="secondary"),
            dbc.Alert("Alert message", color="success", dismissable=True)
        ], md=8)
    ])
], fluid=True)
```

---

## P5.4 Dash Callbacks

### P5.4.1 Callback Basics

```python
from dash import callback, Input, Output, State

# Single input, single output
@callback(
    Output('output-id', 'property'),
    Input('input-id', 'value')
)
def update_output(value):
    return process(value)

# Multiple inputs, single output
@callback(
    Output('chart', 'figure'),
    Input('dropdown', 'value'),
    Input('slider', 'value')
)
def update_chart(dropdown_value, slider_value):
    filtered = df[df['category'] == dropdown_value]
    filtered = filtered[filtered['value'] <= slider_value]
    return px.scatter(filtered, x='age', y='value')

# Multiple outputs
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

# Using State (non-triggering inputs)
@callback(
    Output('output', 'children'),
    Input('button', 'n_clicks'),
    State('input1', 'value'),
    State('input2', 'value')
)
def update(n_clicks, value1, value2):
    if n_clicks is None:
        return "Click the button"
    return f"Values: {value1}, {value2}"
```

### P5.4.2 Advanced Callback Patterns

```python
# Preventing initial call (dash >= 2.0)
@callback(
    Output('output', 'children'),
    Input('button', 'n_clicks'),
    prevent_initial_call=True
)
def update(n_clicks):
    return f"Clicked {n_clicks} times"

# Using dash.no_update (no change)
@callback(
    Output('chart', 'figure'),
    Input('input', 'value')
)
def update(value):
    if value is None:
        return dash.no_update
    return create_chart(value)

# Progress callbacks (dash >= 2.4)
from dash import Progress

@callback(
    Output('output', 'children'),
    Input('button', 'n_clicks'),
    progress=Progress()
)
def update(progress, n_clicks):
    progress.set_value("Loading...")
    # Long operation
    result = long_running_function()
    progress.set_value("Complete!")
    return result
```

### P5.4.3 Client-Side Callbacks (JavaScript)

```python
# For performance (runs in browser)
app.clientside_callback(
    """
    function(value) {
        return value.toUpperCase();
    }
    """,
    Output('output', 'children'),
    Input('input', 'value')
)

# Using JavaScript libraries
app.clientside_callback(
    """
    function(value) {
        // Use D3, jQuery, etc.
        return processed_value;
    }
    """,
    Output('output', 'children'),
    Input('input', 'value')
)
```

---

## P5.5 Common Dash Patterns

### P5.5.1 Filtering and Cross-Filtering

```python
# Global filter that affects multiple charts
@callback(
    Output('chart1', 'figure'),
    Output('chart2', 'figure'),
    Input('filter-dropdown', 'value'),
    Input('filter-slider', 'value')
)
def update_charts(category, value_range):
    filtered = df[df['category'] == category]
    filtered = filtered[(filtered['value'] >= value_range[0]) &
                        (filtered['value'] <= value_range[1])]
    
    fig1 = px.scatter(filtered, x='age', y='value1')
    fig2 = px.bar(filtered, x='category', y='value2')
    
    return fig1, fig2
```

### P5.5.2 Drill-Down

```python
# Click on chart to drill down
@callback(
    Output('detail-chart', 'figure'),
    Output('detail-text', 'children'),
    Input('main-chart', 'clickData')
)
def drill_down(click_data):
    if click_data is None:
        return create_overview(), "Click a point for details"
    
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

### P5.5.3 Dynamic Components

```python
# Dynamically create components
@callback(
    Output('dynamic-container', 'children'),
    Input('add-button', 'n_clicks')
)
def add_component(n_clicks):
    if n_clicks is None:
        return []
    
    # Create new components
    new_component = html.Div([
        dcc.Dropdown(
            id={'type': 'dynamic-dropdown', 'index': n_clicks},
            options=options,
            value=options[0]['value']
        ),
        dcc.Graph(
            id={'type': 'dynamic-chart', 'index': n_clicks}
        )
    ])
    
    return new_component

# Using pattern-matching callbacks
@callback(
    Output({'type': 'dynamic-chart', 'index': MATCH}, 'figure'),
    Input({'type': 'dynamic-dropdown', 'index': MATCH}, 'value')
)
def update_chart(value):
    return create_chart(value)
```

---

## P5.6 Styling and Theming

### P5.6.1 Dash Bootstrap Components

```python
import dash_bootstrap_components as dbc

# Use Bootstrap theme
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])

# Available themes
# dbc.themes.BOOTSTRAP
# dbc.themes.FLATLY
# dbc.themes.CERULEAN
# dbc.themes.CYBORG
# dbc.themes.DARKLY
# dbc.themes.SLATE
# dbc.themes.SUPERHERO

# Custom CSS
app = dash.Dash(__name__, external_stylesheets=['/assets/style.css'])
```

### P5.6.2 Custom CSS

```css
/* assets/style.css */
.custom-card {
    border-radius: 10px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    padding: 20px;
    margin: 10px 0;
}

.custom-chart {
    border: 1px solid #ddd;
    border-radius: 5px;
    padding: 10px;
}

.kpi-card {
    background: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.kpi-value {
    font-size: 32px;
    font-weight: bold;
    color: #2C3E50;
}

.kpi-label {
    font-size: 14px;
    color: #7F8C8D;
    margin-top: 5px;
}
```

---

## P5.7 Deployment

### P5.7.1 Running Locally

```python
if __name__ == '__main__':
    app.run_server(
        debug=True,  # Development mode
        host='127.0.0.1',
        port=8050,
        dev_tools_hot_reload=True  # Auto-reload on code changes
    )
```

### P5.7.2 Production Server

```python
# Use gunicorn (WSGI server)
# app.py
server = app.server

if __name__ == '__main__':
    app.run_server(debug=False)

# Run with: gunicorn app:server
```

### P5.7.3 Docker Deployment

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8050

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8050", "app:server"]
```

---

## P5.8 Key Takeaways

1. **Plotly Express** for quick, common charts
2. **Graph Objects** for custom, complex charts
3. **Dash** for interactive web applications
4. **Callbacks** connect user interaction to updates
5. **Components** build the user interface
6. **Cross-filtering** synchronizes multiple charts
7. **Drill-down** adds depth to exploration
8. **Bootstrap** for professional styling

---

## P5.9 Common Pitfalls

| Issue | Solution |
|-------|----------|
| **Callback not firing** | Check Input ID matches component ID |
| **Chart not updating** | Return updated figure object |
| **Memory leak** | Don't store large data in callbacks |
| **Slow performance** | Use `dcc.Store` for caching |
| **Circular callbacks** | Restructure logic, use single callback |
| **Missing dependencies** | Check requirements.txt |


This primer covers the essential Plotly and Dash concepts you'll encounter throughout the series. It provides a solid foundation for understanding interactive visualizations and web dashboards.
