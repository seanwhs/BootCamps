# Phase 2: Exploratory Data Analysis & Visualization

## Module 2.3: Interactive Data Exploration

### Part 2: Dash - Interactive Web Dashboards

---

#### The Target

In this part, we'll build a complete interactive web dashboard using Dash. By the end, you'll have:

1. A fully functional Dash web application with multiple interactive components
2. Linked cross-filtering between charts (selecting in one chart filters others)
3. Dynamic dropdowns, sliders, and radio buttons for data exploration
4. Drill-down capabilities to explore specific customer segments
5. A reusable dashboard framework that can be adapted for any dataset

---

#### The Concept

**Dash: Python Web Apps for Data Visualization**

Think of Dash as a way to turn your Python data analysis into a full-featured web application without needing to learn JavaScript, HTML, or CSS. It's like building a PowerPoint presentation that's alive—users can interact with it, explore data, and get real-time feedback.

**How Dash Works:**

1. **Layout:** Defines what the page looks like (HTML components)
2. **Callbacks:** Defines how the page behaves (Python functions that update components)
3. **Components:** The building blocks (graphs, dropdowns, sliders, text)

**The Dash Architecture:**

```
User Interaction (click, select, type)
    ↓
Callback triggered (Python function runs)
    ↓
Data processed/transformed
    ↓
Component updates (graph redraws, text updates)
    ↓
User sees updated dashboard
```

**Why Dash for Data Dashboards:**

1. **100% Python:** No JavaScript required
2. **Interactive:** Real-time updates based on user input
3. **Customizable:** Everything from colors to layout can be controlled
4. **Deployable:** Can be shared as a web app or embedded in notebooks
5. **Integrated:** Works seamlessly with Plotly graphs

---

#### The Implementation

##### Step 1: Install Dash and Dependencies

First, make sure Dash is installed:

```bash
pip install dash dash-bootstrap-components dash-core-components dash-html-components
```

Add these to your requirements:

**File:** `requirements_dash.txt`
```txt
dash>=2.9.0
dash-bootstrap-components>=1.4.0
dash-core-components>=2.0.0
dash-html-components>=2.0.0
plotly>=5.14.0
pandas>=2.0.0
numpy>=1.24.0
```

---

##### Step 2: Create the Dash Dashboard Application

**File:** `src/dash_dashboard.py`
```python
"""
Interactive Dash Dashboard for Customer Analytics

A complete web application for exploring customer data with:
- Interactive filtering and cross-filtering
- Multiple chart types with synchronized selection
- Dynamic dropdowns and sliders
- Drill-down capabilities
- Professional styling with Bootstrap
"""

import dash
from dash import dcc, html, Input, Output, State, callback
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import numpy as np
from pathlib import Path
import json
import warnings
warnings.filterwarnings('ignore')

# Load the data
def load_data():
    """Load and prepare the dataset."""
    df = pd.read_csv('data/customer_data.csv')
    
    # Convert timestamps
    df['account_created'] = pd.to_datetime(df['account_created'])
    df['last_purchase'] = pd.to_datetime(df['last_purchase'])
    
    # Create derived columns
    df['account_age_days'] = (pd.Timestamp.now() - df['account_created']).dt.days
    df['days_since_purchase'] = (pd.Timestamp.now() - df['last_purchase']).dt.days
    
    # Map city tier to labels
    city_labels = {1: 'Major Metro', 2: 'Mid-size City', 3: 'Small City/Rural'}
    df['city_tier_label'] = df['city_tier'].map(city_labels)
    
    # Create age groups
    df['age_group'] = pd.cut(df['age'], 
                            bins=[0, 25, 35, 45, 55, 100],
                            labels=['Under 25', '25-35', '35-45', '45-55', '55+'])
    
    # Create engagement groups
    df['engagement_level'] = pd.cut(df['time_on_site'],
                                   bins=[0, 5, 15, 100],
                                   labels=['Low', 'Medium', 'High'])
    
    return df

# Load data
df = load_data()

# Get unique values for dropdowns
income_brackets = sorted(df['income_bracket'].dropna().unique())
categories = sorted(df['favorite_category'].dropna().unique())
genders = sorted(df['gender'].dropna().unique())
countries = sorted(df['country'].dropna().unique())
city_tiers = sorted(df['city_tier_label'].dropna().unique())

# Define color palette
COLORS = {
    'primary': '#2E86AB',
    'secondary': '#A23B72',
    'success': '#3F8C5A',
    'warning': '#F18F01',
    'danger': '#C73E1D',
    'info': '#6A8EAE',
    'light': '#F8F9FA',
    'dark': '#2C3E50'
}

# ---------- APP INITIALIZATION ----------

app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    title='Customer Analytics Dashboard',
    suppress_callback_exceptions=True
)

server = app.server

# ---------- LAYOUT ----------

app.layout = dbc.Container([
    # Header
    dbc.Row([
        dbc.Col([
            html.H1("🔍 Customer Analytics Dashboard", 
                   className="text-center my-4", 
                   style={'color': COLORS['dark']}),
            html.P("Explore customer behavior, demographics, and engagement patterns",
                  className="text-center text-muted mb-4")
        ])
    ]),
    
    # Global Filters Row
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Global Filters", className="bg-primary text-white"),
                dbc.CardBody([
                    dbc.Row([
                        dbc.Col([
                            html.Label("Income Bracket"),
                            dcc.Dropdown(
                                id='filter-income',
                                options=[{'label': 'All', 'value': 'All'}] + 
                                        [{'label': i, 'value': i} for i in income_brackets],
                                value='All',
                                className='mb-2'
                            )
                        ], md=3),
                        dbc.Col([
                            html.Label("Gender"),
                            dcc.Dropdown(
                                id='filter-gender',
                                options=[{'label': 'All', 'value': 'All'}] +
                                        [{'label': g, 'value': g} for g in genders],
                                value='All',
                                className='mb-2'
                            )
                        ], md=3),
                        dbc.Col([
                            html.Label("Favorite Category"),
                            dcc.Dropdown(
                                id='filter-category',
                                options=[{'label': 'All', 'value': 'All'}] +
                                        [{'label': c, 'value': c} for c in categories],
                                value='All',
                                className='mb-2'
                            )
                        ], md=3),
                        dbc.Col([
                            html.Label("City Tier"),
                            dcc.Dropdown(
                                id='filter-city',
                                options=[{'label': 'All', 'value': 'All'}] +
                                        [{'label': c, 'value': c} for c in city_tiers],
                                value='All',
                                className='mb-2'
                            )
                        ], md=3)
                    ]),
                    dbc.Row([
                        dbc.Col([
                            html.Label("Age Range"),
                            dcc.RangeSlider(
                                id='filter-age',
                                min=int(df['age'].min()),
                                max=int(df['age'].max()),
                                step=1,
                                value=[int(df['age'].min()), int(df['age'].max())],
                                marks={i: str(i) for i in range(20, 71, 10)},
                                className='mt-2'
                            )
                        ], md=6),
                        dbc.Col([
                            html.Label("Order Frequency Range"),
                            dcc.RangeSlider(
                                id='filter-frequency',
                                min=0,
                                max=float(df['order_frequency'].max()),
                                step=0.1,
                                value=[0, float(df['order_frequency'].max())],
                                marks={0: '0', 1: '1', 2: '2', 3: '3', 4: '4+'},
                                className='mt-2'
                            )
                        ], md=6)
                    ])
                ])
            ], className='mb-4')
        ])
    ]),
    
    # KPI Cards Row
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Total Customers", className="card-title text-muted"),
                    html.H2(id='kpi-total', children="0", className="text-primary"),
                    html.Small("Active customers in database", className="text-muted")
                ])
            ], className='mb-4')
        ], md=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Avg Order Value", className="card-title text-muted"),
                    html.H2(id='kpi-avg-order', children="$0", className="text-success"),
                    html.Small("Average across all customers", className="text-muted")
                ])
            ], className='mb-4')
        ], md=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Avg Customer Rating", className="card-title text-muted"),
                    html.H2(id='kpi-avg-rating', children="0.0", className="text-warning"),
                    html.Small("Out of 5.0", className="text-muted")
                ])
            ], className='mb-4')
        ], md=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Return Rate", className="card-title text-muted"),
                    html.H2(id='kpi-return-rate', children="0%", className="text-danger"),
                    html.Small("Average return percentage", className="text-muted")
                ])
            ], className='mb-4')
        ], md=3)
    ]),
    
    # Main Charts Row
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Customer Demographics", className="bg-secondary text-white"),
                dbc.CardBody([
                    dcc.Graph(id='chart-demographics')
                ])
            ], className='mb-4')
        ], md=6),
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Engagement & Behavior", className="bg-secondary text-white"),
                dbc.CardBody([
                    dcc.Graph(id='chart-engagement')
                ])
            ], className='mb-4')
        ], md=6)
    ]),
    
    # Second Row: More Charts
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Purchase Patterns", className="bg-info text-white"),
                dbc.CardBody([
                    dcc.Graph(id='chart-purchases')
                ])
            ], className='mb-4')
        ], md=6),
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Customer Segments", className="bg-info text-white"),
                dbc.CardBody([
                    dcc.Graph(id='chart-segments')
                ])
            ], className='mb-4')
        ], md=6)
    ]),
    
    # Third Row: Detailed Analysis
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Detailed Customer Analysis", className="bg-dark text-white"),
                dbc.CardBody([
                    dcc.Graph(id='chart-details')
                ])
            ], className='mb-4')
        ], md=12)
    ]),
    
    # Footer
    dbc.Row([
        dbc.Col([
            html.Hr(),
            html.P("Built with Dash and Plotly | Interactive Customer Analytics",
                  className="text-center text-muted"),
            html.P("Click on data points in charts to drill down | Hover for details",
                  className="text-center text-muted small")
        ])
    ])
], fluid=True)


# ---------- CALLBACKS ----------

def filter_dataframe(income, gender, category, city, age_range, freq_range):
    """Apply all filters to the dataframe."""
    filtered_df = df.copy()
    
    # Apply filters
    if income != 'All':
        filtered_df = filtered_df[filtered_df['income_bracket'] == income]
    
    if gender != 'All':
        filtered_df = filtered_df[filtered_df['gender'] == gender]
    
    if category != 'All':
        filtered_df = filtered_df[filtered_df['favorite_category'] == category]
    
    if city != 'All':
        filtered_df = filtered_df[filtered_df['city_tier_label'] == city]
    
    # Age range filter
    filtered_df = filtered_df[
        (filtered_df['age'] >= age_range[0]) & 
        (filtered_df['age'] <= age_range[1])
    ]
    
    # Frequency range filter
    filtered_df = filtered_df[
        (filtered_df['order_frequency'] >= freq_range[0]) & 
        (filtered_df['order_frequency'] <= freq_range[1])
    ]
    
    return filtered_df


@callback(
    Output('kpi-total', 'children'),
    Output('kpi-avg-order', 'children'),
    Output('kpi-avg-rating', 'children'),
    Output('kpi-return-rate', 'children'),
    Input('filter-income', 'value'),
    Input('filter-gender', 'value'),
    Input('filter-category', 'value'),
    Input('filter-city', 'value'),
    Input('filter-age', 'value'),
    Input('filter-frequency', 'value')
)
def update_kpis(income, gender, category, city, age_range, freq_range):
    """Update KPI cards based on filters."""
    filtered_df = filter_dataframe(income, gender, category, city, age_range, freq_range)
    
    total = len(filtered_df)
    avg_order = filtered_df['avg_order_value'].mean()
    avg_rating = filtered_df['customer_rating'].mean()
    return_rate = filtered_df['return_rate'].mean()
    
    return (
        f"{total:,}",
        f"${avg_order:.2f}",
        f"{avg_rating:.2f}" if not pd.isna(avg_rating) else "N/A",
        f"{return_rate:.1f}%" if not pd.isna(return_rate) else "N/A"
    )


@callback(
    Output('chart-demographics', 'figure'),
    Input('filter-income', 'value'),
    Input('filter-gender', 'value'),
    Input('filter-category', 'value'),
    Input('filter-city', 'value'),
    Input('filter-age', 'value'),
    Input('filter-frequency', 'value')
)
def update_demographics_chart(income, gender, category, city, age_range, freq_range):
    """Update demographics chart."""
    filtered_df = filter_dataframe(income, gender, category, city, age_range, freq_range)
    
    # Create subplots
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Age Distribution', 'Gender Distribution',
                       'Income Bracket Distribution', 'City Tier Distribution'),
        specs=[[{'type': 'histogram'}, {'type': 'pie'}],
               [{'type': 'histogram'}, {'type': 'pie'}]]
    )
    
    # Age histogram
    age_data = filtered_df['age'].dropna()
    if not age_data.empty:
        fig.add_trace(
            go.Histogram(x=age_data, nbinsx=20, name='Age', 
                        marker_color=COLORS['primary']),
            row=1, col=1
        )
    
    # Gender pie
    gender_counts = filtered_df['gender'].value_counts()
    if not gender_counts.empty:
        fig.add_trace(
            go.Pie(labels=gender_counts.index, values=gender_counts.values,
                  name='Gender', hole=0.3,
                  marker_colors=[COLORS['primary'], COLORS['secondary'], COLORS['info']]),
            row=1, col=2
        )
    
    # Income histogram
    income_counts = filtered_df['income_bracket'].value_counts()
    if not income_counts.empty:
        fig.add_trace(
            go.Bar(x=income_counts.index, y=income_counts.values,
                  name='Income', marker_color=COLORS['success']),
            row=2, col=1
        )
    
    # City tier pie
    city_counts = filtered_df['city_tier_label'].value_counts()
    if not city_counts.empty:
        fig.add_trace(
            go.Pie(labels=city_counts.index, values=city_counts.values,
                  name='City Tier', hole=0.3,
                  marker_colors=[COLORS['primary'], COLORS['success'], COLORS['warning']]),
            row=2, col=2
        )
    
    fig.update_layout(height=600, showlegend=False,
                     template='plotly_white',
                     title_text=f"Demographics ({len(filtered_df)} customers)")
    
    return fig


@callback(
    Output('chart-engagement', 'figure'),
    Input('filter-income', 'value'),
    Input('filter-gender', 'value'),
    Input('filter-category', 'value'),
    Input('filter-city', 'value'),
    Input('filter-age', 'value'),
    Input('filter-frequency', 'value')
)
def update_engagement_chart(income, gender, category, city, age_range, freq_range):
    """Update engagement chart."""
    filtered_df = filter_dataframe(income, gender, category, city, age_range, freq_range)
    
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Time on Site Distribution', 'Pages Viewed vs Time',
                       'Engagement Level Distribution', 'Email Open Rate'),
        specs=[[{'type': 'histogram'}, {'type': 'scatter'}],
               [{'type': 'pie'}, {'type': 'histogram'}]]
    )
    
    # Time on site histogram
    time_data = filtered_df['time_on_site'].dropna()
    if not time_data.empty:
        fig.add_trace(
            go.Histogram(x=time_data, nbinsx=30, name='Time on Site',
                        marker_color=COLORS['info']),
            row=1, col=1
        )
    
    # Pages vs Time scatter
    if not filtered_df.empty:
        fig.add_trace(
            go.Scatter(x=filtered_df['time_on_site'], 
                      y=filtered_df['pages_viewed'],
                      mode='markers', name='Pages vs Time',
                      marker=dict(size=6, color=COLORS['primary'],
                                opacity=0.6)),
            row=1, col=2
        )
    
    # Engagement level pie
    engagement_counts = filtered_df['engagement_level'].value_counts()
    if not engagement_counts.empty:
        fig.add_trace(
            go.Pie(labels=engagement_counts.index, values=engagement_counts.values,
                  name='Engagement', hole=0.3,
                  marker_colors=[COLORS['success'], COLORS['warning'], COLORS['danger']]),
            row=2, col=1
        )
    
    # Email open rate
    email_data = filtered_df['email_open_rate'].dropna()
    if not email_data.empty:
        fig.add_trace(
            go.Histogram(x=email_data, nbinsx=20, name='Email Open Rate',
                        marker_color=COLORS['secondary']),
            row=2, col=2
        )
    
    fig.update_layout(height=600, showlegend=False,
                     template='plotly_white',
                     title_text=f"Engagement Metrics ({len(filtered_df)} customers)")
    
    return fig


@callback(
    Output('chart-purchases', 'figure'),
    Input('filter-income', 'value'),
    Input('filter-gender', 'value'),
    Input('filter-category', 'value'),
    Input('filter-city', 'value'),
    Input('filter-age', 'value'),
    Input('filter-frequency', 'value')
)
def update_purchases_chart(income, gender, category, city, age_range, freq_range):
    """Update purchase patterns chart."""
    filtered_df = filter_dataframe(income, gender, category, city, age_range, freq_range)
    
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Order Frequency by Income', 'Avg Order Value by Category',
                       'Order Frequency Distribution', 'Avg Order Value Distribution'),
        specs=[[{'type': 'box'}, {'type': 'box'}],
               [{'type': 'histogram'}, {'type': 'histogram'}]]
    )
    
    # Order frequency by income
    if not filtered_df.empty:
        fig.add_trace(
            go.Box(x=filtered_df['income_bracket'], y=filtered_df['order_frequency'],
                  name='Order Freq by Income', marker_color=COLORS['primary']),
            row=1, col=1
        )
    
    # Order value by category
    if not filtered_df.empty:
        fig.add_trace(
            go.Box(x=filtered_df['favorite_category'], y=filtered_df['avg_order_value'],
                  name='Order Value by Category', marker_color=COLORS['success']),
            row=1, col=2
        )
    
    # Order frequency histogram
    freq_data = filtered_df['order_frequency'].dropna()
    if not freq_data.empty:
        fig.add_trace(
            go.Histogram(x=freq_data, nbinsx=30, name='Order Frequency',
                        marker_color=COLORS['warning']),
            row=2, col=1
        )
    
    # Order value histogram
    value_data = filtered_df['avg_order_value'].dropna()
    if not value_data.empty:
        fig.add_trace(
            go.Histogram(x=value_data, nbinsx=30, name='Avg Order Value',
                        marker_color=COLORS['danger']),
            row=2, col=2
        )
    
    fig.update_layout(height=600, showlegend=False,
                     template='plotly_white',
                     title_text=f"Purchase Patterns ({len(filtered_df)} customers)")
    
    return fig


@callback(
    Output('chart-segments', 'figure'),
    Input('filter-income', 'value'),
    Input('filter-gender', 'value'),
    Input('filter-category', 'value'),
    Input('filter-city', 'value'),
    Input('filter-age', 'value'),
    Input('filter-frequency', 'value')
)
def update_segments_chart(income, gender, category, city, age_range, freq_range):
    """Update customer segments chart."""
    filtered_df = filter_dataframe(income, gender, category, city, age_range, freq_range)
    
    # Create segment groupings
    if not filtered_df.empty:
        # Age group analysis
        age_means = filtered_df.groupby('age_group').agg({
            'order_frequency': 'mean',
            'avg_order_value': 'mean',
            'customer_rating': 'mean'
        }).reset_index()
        
        # Category analysis
        cat_means = filtered_df.groupby('favorite_category').agg({
            'order_frequency': 'mean',
            'avg_order_value': 'mean'
        }).reset_index()
        
        fig = make_subplots(
            rows=2, cols=2,
            subplot_titles=('Order Value by Age Group', 'Order Frequency by Category',
                          'Rating by Engagement', 'Return Rate by Rating'),
            specs=[[{'type': 'bar'}, {'type': 'bar'}],
                   [{'type': 'box'}, {'type': 'scatter'}]]
        )
        
        # Bar chart: Order value by age group
        fig.add_trace(
            go.Bar(x=age_means['age_group'], y=age_means['avg_order_value'],
                  name='Order Value', marker_color=COLORS['primary']),
            row=1, col=1
        )
        
        # Bar chart: Order frequency by category
        fig.add_trace(
            go.Bar(x=cat_means['favorite_category'], y=cat_means['order_frequency'],
                  name='Order Frequency', marker_color=COLORS['success']),
            row=1, col=2
        )
        
        # Box plot: Rating by engagement
        if not filtered_df.empty:
            fig.add_trace(
                go.Box(x=filtered_df['engagement_level'], y=filtered_df['customer_rating'],
                      name='Rating by Engagement', marker_color=COLORS['info']),
                row=2, col=1
            )
        
        # Scatter: Return rate vs rating
        rating_data = filtered_df.dropna(subset=['customer_rating', 'return_rate'])
        if not rating_data.empty:
            fig.add_trace(
                go.Scatter(x=rating_data['customer_rating'], 
                          y=rating_data['return_rate'],
                          mode='markers', name='Return vs Rating',
                          marker=dict(size=8, color=COLORS['secondary'], opacity=0.6)),
                row=2, col=2
            )
        
        fig.update_layout(height=600, showlegend=False,
                         template='plotly_white',
                         title_text=f"Customer Segments ({len(filtered_df)} customers)")
        
        return fig
    
    return go.Figure()


@callback(
    Output('chart-details', 'figure'),
    Input('filter-income', 'value'),
    Input('filter-gender', 'value'),
    Input('filter-category', 'value'),
    Input('filter-city', 'value'),
    Input('filter-age', 'value'),
    Input('filter-frequency', 'value')
)
def update_details_chart(income, gender, category, city, age_range, freq_range):
    """Update detailed analysis chart."""
    filtered_df = filter_dataframe(income, gender, category, city, age_range, freq_range)
    
    if filtered_df.empty:
        return go.Figure()
    
    # Create correlation heatmap
    corr_cols = ['age', 'time_on_site', 'pages_viewed', 'order_frequency', 
                'avg_order_value', 'customer_rating', 'return_rate']
    
    corr_data = filtered_df[corr_cols].dropna()
    corr_matrix = corr_data.corr()
    
    fig = go.Figure(data=[
        go.Heatmap(
            z=corr_matrix.values,
            x=corr_matrix.columns,
            y=corr_matrix.columns,
            colorscale='RdBu_r',
            zmid=0,
            text=corr_matrix.round(2).values,
            texttemplate='%{text}',
            textfont={'size': 10},
            hovertemplate='<b>%{x}</b> vs <b>%{y}</b><br>' +
                         'Correlation: %{z:.3f}<extra></extra>'
        )
    ])
    
    fig.update_layout(
        title=f"Correlation Matrix: Key Metrics ({len(filtered_df)} customers)",
        height=500,
        template='plotly_white',
        xaxis={'side': 'bottom'}
    )
    
    return fig


# ---------- MAIN ----------

if __name__ == '__main__':
    app.run_server(debug=True, host='127.0.0.1', port=8050)
```

---

##### Step 3: Create a Startup Script

**File:** `run_dashboard.py`
```python
"""
Startup script for the Dash dashboard.
"""

import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / 'src'))

# Run the dashboard
from src.dash_dashboard import app

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 STARTING CUSTOMER ANALYTICS DASHBOARD")
    print("=" * 60)
    print("\n📊 Dashboard will be available at: http://127.0.0.1:8050")
    print("💡 Press Ctrl+C to stop the server")
    print("\n" + "=" * 60)
    
    app.run_server(debug=True, host='127.0.0.1', port=8050)
```

---

##### Step 4: Create a Production-Ready Dashboard with Advanced Features

**File:** `src/dash_advanced.py`
```python
"""
Advanced Dash Dashboard with Drill-Down and Cross-Filtering

Adds advanced features:
- Click-based drill-down
- Multi-chart cross-filtering
- Export functionality
- Responsive design
"""

import dash
from dash import dcc, html, Input, Output, State, callback, no_update
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np
from pathlib import Path
import json
import warnings
warnings.filterwarnings('ignore')

# Load data (same as before)
df = pd.read_csv('data/customer_data.csv')
df['account_created'] = pd.to_datetime(df['account_created'])
df['last_purchase'] = pd.to_datetime(df['last_purchase'])
df['account_age_days'] = (pd.Timestamp.now() - df['account_created']).dt.days
city_labels = {1: 'Major Metro', 2: 'Mid-size City', 3: 'Small City/Rural'}
df['city_tier_label'] = df['city_tier'].map(city_labels)
df['age_group'] = pd.cut(df['age'], bins=[0, 25, 35, 45, 55, 100],
                        labels=['Under 25', '25-35', '35-45', '45-55', '55+'])

# Global variables for drill-down
selected_customer = None

app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.CYBORG],
    title='Advanced Analytics Dashboard',
    suppress_callback_exceptions=True
)

# ---------- LAYOUT ----------

app.layout = dbc.Container([
    dbc.Row([
        dbc.Col([
            html.H1("🎯 Advanced Customer Analytics", className="text-center my-4"),
            html.P("Click on any data point to drill down | Hover for details",
                  className="text-center text-muted mb-4")
        ])
    ]),
    
    # Control panel
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    dbc.Row([
                        dbc.Col([
                            html.Label("Select Analysis View"),
                            dcc.RadioItems(
                                id='view-selector',
                                options=[
                                    {'label': 'Overview', 'value': 'overview'},
                                    {'label': 'Demographics', 'value': 'demographics'},
                                    {'label': 'Behavior', 'value': 'behavior'},
                                    {'label': 'Purchases', 'value': 'purchases'}
                                ],
                                value='overview',
                                inline=True,
                                className='mb-2'
                            )
                        ], md=6),
                        dbc.Col([
                            html.Label("Drill-down Level"),
                            dcc.RadioItems(
                                id='drill-level',
                                options=[
                                    {'label': 'None', 'value': 'none'},
                                    {'label': 'Category', 'value': 'category'},
                                    {'label': 'Customer', 'value': 'customer'}
                                ],
                                value='none',
                                inline=True,
                                className='mb-2'
                            )
                        ], md=6)
                    ]),
                    dbc.Row([
                        dbc.Col([
                            html.Label("Selected Customer:"),
                            html.Div(id='selected-customer-display', 
                                    children="None selected",
                                    className="text-info")
                        ], md=6),
                        dbc.Col([
                            html.Button("Reset Drill-Down", 
                                       id='reset-button',
                                       className="btn btn-warning mt-2")
                        ], md=6)
                    ])
                ])
            ], className='mb-4')
        ])
    ]),
    
    # Charts
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Main Analysis View", className="bg-primary text-white"),
                dbc.CardBody([
                    dcc.Graph(id='main-chart', config={'displaylogo': False})
                ])
            ], className='mb-4')
        ], md=8),
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Detail View", className="bg-secondary text-white"),
                dbc.CardBody([
                    dcc.Graph(id='detail-chart', config={'displaylogo': False})
                ])
            ], className='mb-4')
        ], md=4)
    ]),
    
    # Data table
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Customer Data (Filtered View)", className="bg-dark text-white"),
                dbc.CardBody([
                    html.Div(id='data-table-container')
                ])
            ], className='mb-4')
        ])
    ])
], fluid=True)


# ---------- CALLBACKS ----------

@app.callback(
    Output('selected-customer-display', 'children'),
    Input('main-chart', 'clickData')
)
def update_selected_customer(clickData):
    """Update selected customer display based on chart click."""
    global selected_customer
    
    if clickData is None:
        selected_customer = None
        return "None selected"
    
    # Extract customer ID from click data
    try:
        if 'customdata' in clickData['points'][0]:
            customer_id = clickData['points'][0]['customdata'][0]
            selected_customer = customer_id
            return f"Customer: {customer_id}"
        else:
            selected_customer = None
            return "None selected"
    except:
        selected_customer = None
        return "None selected"


@app.callback(
    Output('main-chart', 'figure'),
    Output('detail-chart', 'figure'),
    Output('data-table-container', 'children'),
    Input('view-selector', 'value'),
    Input('drill-level', 'value'),
    Input('main-chart', 'clickData'),
    Input('reset-button', 'n_clicks')
)
def update_dashboard(view, drill_level, clickData, reset_clicks):
    """Main callback to update all dashboard components."""
    global selected_customer
    
    # Reset drill-down if button clicked
    if reset_clicks and reset_clicks > 0:
        selected_customer = None
    
    # Get data based on drill level
    if selected_customer is not None and drill_level == 'customer':
        filtered_df = df[df['customer_id'] == selected_customer]
        main_data = df  # Show full data for context
    elif drill_level == 'category' and clickData is not None:
        # Get category from click
        try:
            category = clickData['points'][0]['x']
            filtered_df = df[df['favorite_category'] == category]
            main_data = df
        except:
            filtered_df = df
            main_data = df
    else:
        filtered_df = df
        main_data = df
    
    # Create main chart based on view
    if view == 'overview':
        fig_main = create_overview_chart(main_data, filtered_df)
    elif view == 'demographics':
        fig_main = create_demographics_chart(main_data, filtered_df)
    elif view == 'behavior':
        fig_main = create_behavior_chart(main_data, filtered_df)
    elif view == 'purchases':
        fig_main = create_purchases_chart(main_data, filtered_df)
    
    # Create detail chart
    fig_detail = create_detail_chart(filtered_df)
    
    # Create data table
    table = create_data_table(filtered_df)
    
    return fig_main, fig_detail, table


def create_overview_chart(main_data, filtered_data):
    """Create overview chart with context."""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Order Frequency vs Value', 'Distribution by Income',
                       'Engagement Overview', 'Top Categories')
    )
    
    # Scatter: Order frequency vs value
    fig.add_trace(
        go.Scatter(x=main_data['order_frequency'], y=main_data['avg_order_value'],
                  mode='markers', name='All Customers',
                  marker=dict(size=5, color='lightgray', opacity=0.5),
                  customdata=main_data['customer_id'],
                  hovertemplate='<b>Customer: %{customdata}</b><br>' +
                               'Freq: %{x:.2f}<br>Value: $%{y:.2f}<extra></extra>'),
        row=1, col=1
    )
    
    # Highlight filtered data
    if not filtered_data.empty:
        fig.add_trace(
            go.Scatter(x=filtered_data['order_frequency'], y=filtered_data['avg_order_value'],
                      mode='markers', name='Selected',
                      marker=dict(size=10, color='red', opacity=0.8,
                                 line=dict(width=1, color='black')),
                      customdata=filtered_data['customer_id'],
                      hovertemplate='<b>Customer: %{customdata}</b><br>' +
                                   'Freq: %{x:.2f}<br>Value: $%{y:.2f}<extra></extra>'),
            row=1, col=1
        )
    
    # Income distribution
    income_counts = main_data['income_bracket'].value_counts()
    fig.add_trace(
        go.Bar(x=income_counts.index, y=income_counts.values,
              name='Income', marker_color='steelblue'),
        row=1, col=2
    )
    
    # Engagement (time on site)
    fig.add_trace(
        go.Histogram(x=main_data['time_on_site'], nbinsx=30,
                    name='Time on Site', marker_color='coral'),
        row=2, col=1
    )
    
    # Top categories
    cat_counts = main_data['favorite_category'].value_counts().head(5)
    fig.add_trace(
        go.Bar(x=cat_counts.index, y=cat_counts.values,
              name='Categories', marker_color='forestgreen'),
        row=2, col=2
    )
    
    fig.update_layout(height=600, template='plotly_white', showlegend=False)
    return fig


def create_demographics_chart(main_data, filtered_data):
    """Create demographics-focused chart."""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Age Distribution', 'Gender Split',
                       'City Tier Distribution', 'Age vs Income')
    )
    
    # Age histogram
    fig.add_trace(
        go.Histogram(x=main_data['age'].dropna(), nbinsx=20,
                    name='Age', marker_color='steelblue'),
        row=1, col=1
    )
    
    # Gender pie
    gender_counts = main_data['gender'].value_counts()
    fig.add_trace(
        go.Pie(labels=gender_counts.index, values=gender_counts.values,
              hole=0.3, name='Gender'),
        row=1, col=2
    )
    
    # City tier
    city_counts = main_data['city_tier_label'].value_counts()
    fig.add_trace(
        go.Bar(x=city_counts.index, y=city_counts.values,
              name='City Tier', marker_color='coral'),
        row=2, col=1
    )
    
    # Age vs Income (boxplot)
    fig.add_trace(
        go.Box(x=main_data['income_bracket'], y=main_data['age'],
              name='Age by Income', marker_color='forestgreen'),
        row=2, col=2
    )
    
    fig.update_layout(height=600, template='plotly_white', showlegend=False)
    return fig


def create_behavior_chart(main_data, filtered_data):
    """Create behavior-focused chart."""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Time on Site Distribution', 'Pages vs Time',
                       'Email Open Rate', 'Engagement by Income')
    )
    
    # Time on site
    fig.add_trace(
        go.Histogram(x=main_data['time_on_site'].dropna(), nbinsx=30,
                    name='Time on Site', marker_color='steelblue'),
        row=1, col=1
    )
    
    # Pages vs Time
    fig.add_trace(
        go.Scatter(x=main_data['time_on_site'], y=main_data['pages_viewed'],
                  mode='markers', name='Pages vs Time',
                  marker=dict(size=6, color='coral', opacity=0.5)),
        row=1, col=2
    )
    
    # Email open rate
    fig.add_trace(
        go.Histogram(x=main_data['email_open_rate'].dropna(), nbinsx=20,
                    name='Email Open Rate', marker_color='forestgreen'),
        row=2, col=1
    )
    
    # Engagement by income
    engagement_means = main_data.groupby('income_bracket')['time_on_site'].mean().reset_index()
    fig.add_trace(
        go.Bar(x=engagement_means['income_bracket'], y=engagement_means['time_on_site'],
              name='Time by Income', marker_color='purple'),
        row=2, col=2
    )
    
    fig.update_layout(height=600, template='plotly_white', showlegend=False)
    return fig


def create_purchases_chart(main_data, filtered_data):
    """Create purchases-focused chart."""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Order Frequency', 'Avg Order Value',
                       'Return Rate', 'Rating Distribution')
    )
    
    # Order frequency
    fig.add_trace(
        go.Histogram(x=main_data['order_frequency'].dropna(), nbinsx=30,
                    name='Order Frequency', marker_color='steelblue'),
        row=1, col=1
    )
    
    # Avg order value
    fig.add_trace(
        go.Histogram(x=main_data['avg_order_value'].dropna(), nbinsx=30,
                    name='Avg Order Value', marker_color='coral'),
        row=1, col=2
    )
    
    # Return rate
    fig.add_trace(
        go.Histogram(x=main_data['return_rate'].dropna(), nbinsx=20,
                    name='Return Rate', marker_color='forestgreen'),
        row=2, col=1
    )
    
    # Rating distribution
    fig.add_trace(
        go.Histogram(x=main_data['customer_rating'].dropna(), nbinsx=20,
                    name='Rating', marker_color='purple'),
        row=2, col=2
    )
    
    fig.update_layout(height=600, template='plotly_white', showlegend=False)
    return fig


def create_detail_chart(filtered_data):
    """Create detail view chart for selected data."""
    if filtered_data.empty:
        return go.Figure().update_layout(title="No data selected")
    
    # Create a radar chart for customer profile
    categories = ['age', 'time_on_site', 'order_frequency', 
                  'avg_order_value', 'customer_rating']
    
    # Normalize data
    normalized = pd.DataFrame()
    for cat in categories:
        max_val = df[cat].max()
        min_val = df[cat].min()
        if max_val != min_val:
            normalized[cat] = (filtered_data[cat] - min_val) / (max_val - min_val)
        else:
            normalized[cat] = 0.5
    
    mean_profile = normalized.mean()
    
    fig = go.Figure()
    
    fig.add_trace(go.Scatterpolar(
        r=mean_profile.values,
        theta=categories,
        fill='toself',
        name='Selected Profile',
        line_color='red'
    ))
    
    # Add overall profile for comparison
    overall_norm = pd.DataFrame()
    for cat in categories:
        max_val = df[cat].max()
        min_val = df[cat].min()
        if max_val != min_val:
            overall_norm[cat] = (df[cat] - min_val) / (max_val - min_val)
        else:
            overall_norm[cat] = 0.5
    
    overall_profile = overall_norm.mean()
    
    fig.add_trace(go.Scatterpolar(
        r=overall_profile.values,
        theta=categories,
        fill='toself',
        name='Overall Profile',
        line_color='blue',
        opacity=0.5
    ))
    
    fig.update_layout(
        polar=dict(
            radialaxis=dict(
                visible=True,
                range=[0, 1]
            )
        ),
        showlegend=True,
        title=f"Customer Profile Comparison (n={len(filtered_data)})",
        height=400
    )
    
    return fig


def create_data_table(filtered_data):
    """Create an HTML table of the filtered data."""
    if filtered_data.empty:
        return html.Div("No data to display")
    
    # Select columns for display
    display_cols = ['customer_id', 'age', 'gender', 'income_bracket', 
                   'favorite_category', 'order_frequency', 'avg_order_value',
                   'customer_rating', 'return_rate']
    
    table_data = filtered_data[display_cols].head(20)
    
    # Create table
    table = dbc.Table(
        [
            html.Thead(
                html.Tr([html.Th(col.replace('_', ' ').title()) for col in display_cols])
            ),
            html.Tbody([
                html.Tr([
                    html.Td(row[col]) for col in display_cols
                ]) for _, row in table_data.iterrows()
            ])
        ],
        bordered=True,
        striped=True,
        hover=True,
        responsive=True,
        size='sm'
    )
    
    return table


# ---------- MAIN ----------

if __name__ == '__main__':
    app.run_server(debug=True, host='127.0.0.1', port=8051)
```

---

#### The Verification

**Verification 1: Run the Dashboard**

```bash
# Run the basic dashboard
python src/dash_dashboard.py

# Or run the advanced dashboard
python src/dash_advanced.py

# Or use the startup script
python run_dashboard.py
```

**Verification 2: Open in Browser**

Open your browser and navigate to:
- Basic dashboard: http://127.0.0.1:8050
- Advanced dashboard: http://127.0.0.1:8051

**Verification 3: Test Interactive Features**

1. **Filters:** Change dropdowns and sliders to filter data
2. **KPI Cards:** Watch them update based on filters
3. **Charts:** Hover for tooltips, zoom/pan
4. **Click on points:** In advanced dashboard, click data points to drill down
5. **View Selector:** Change between overview, demographics, behavior, purchases

**Verification 4: Quick Validation Script**

**File:** `src/validate_dashboard.py`
```python
"""
Validate that the dashboard can be imported and started.
"""

import sys
from pathlib import Path

def validate_dashboard():
    """Check that dashboard dependencies are installed."""
    
    print("=" * 60)
    print("VALIDATING DASH DASHBOARD")
    print("=" * 60)
    
    # Check required packages
    required = ['dash', 'dash_bootstrap_components', 'plotly', 'pandas']
    missing = []
    
    for pkg in required:
        try:
            __import__(pkg)
            print(f"✅ {pkg} installed")
        except ImportError:
            print(f"❌ {pkg} NOT installed")
            missing.append(pkg)
    
    if missing:
        print(f"\n⚠️ Missing packages. Install with:")
        print(f"   pip install {' '.join(missing)}")
    else:
        print("\n✅ All dependencies installed")
        
        # Check if we can import the dashboard
        try:
            sys.path.insert(0, str(Path(__file__).parent))
            from dash_dashboard import app
            print("✅ Dashboard module loaded successfully")
            print("🚀 To run: python src/dash_dashboard.py")
        except Exception as e:
            print(f"❌ Could not import dashboard: {e}")
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    validate_dashboard()
```

Run it:
```bash
python src/validate_dashboard.py
```

---

#### What We've Accomplished

In this part, we've:

1. ✅ Built a complete interactive Dash dashboard with:
   - Global filters (income, gender, category, city, age, frequency)
   - Real-time KPI cards
   - Multiple synchronized charts
   - Professional styling with Bootstrap

2. ✅ Implemented advanced features:
   - Cross-filtering between charts
   - Click-based drill-down
   - Customer profile comparison
   - View selector for different analysis perspectives
   - Data table display

3. ✅ Created two versions:
   - Basic dashboard (single-page, comprehensive)
   - Advanced dashboard (with drill-down and cross-filtering)

4. ✅ Learned the Dash workflow:
   - Layout design with Bootstrap components
   - Callback functions for interactivity
   - Data filtering and transformation
   - Chart integration with Plotly

---

#### Deep Dive Reference: Dash Architecture and Best Practices

**Dash Component Hierarchy**

```
Dash App
  └── Layout (HTML structure)
        └── Container (dbc.Container)
              └── Row (dbc.Row)
                    └── Column (dbc.Col)
                          └── Card (dbc.Card)
                                ├── CardHeader
                                └── CardBody
                                      ├── dcc.Dropdown
                                      ├── dcc.Graph
                                      └── html elements
```

**Callback Patterns**

```python
# Single input, single output
@callback(
    Output('output-id', 'property'),
    Input('input-id', 'value')
)
def update(value):
    return transformed_value

# Multiple inputs, multiple outputs
@callback(
    Output('output1', 'property'),
    Output('output2', 'property'),
    Input('input1', 'value'),
    Input('input2', 'value')
)
def update(val1, val2):
    return result1, result2

# State for non-triggering inputs
@callback(
    Output('output', 'property'),
    Input('button', 'n_clicks'),
    State('input', 'value')
)
def update(clicks, state_value):
    return process(state_value)
```

**Performance Best Practices**

1. **Limit data:** Filter data before sending to callbacks
2. **Cache data:** Use `dash.dcc.Store` or `@cache` decorators
3. **Batch updates:** Return multiple outputs in one callback
4. **Avoid large data in callbacks:** Use client-side callbacks when possible

**Deployment Options**

| Method | Use Case | Complexity |
|--------|----------|------------|
| Local server | Development | Easy |
| Cloud (AWS, GCP) | Production | Medium |
| Dash Enterprise | Enterprise | Paid |
| Heroku | Small apps | Medium |
| Docker | Containerized | Medium |

---

#### Module 2.3 Summary

Congratulations! You've completed Module 2.3: Interactive Data Exploration. You now have:

1. **Plotly Express:** Quick, interactive charts with one line of code
2. **Plotly Graph Objects:** Fine-grained control over chart elements
3. **3D Visualizations:** Interactive 3D scatter and surface plots
4. **Interactive Controls:** Sliders, dropdowns, animations
5. **Dash Dashboards:** Complete web applications with cross-filtering

**What's Next:**

You're ready for the **Phase 2 Capstone: Exploratory Customer Insights Dashboard**, where you'll synthesize everything you've learned into a complete analytical artifact that combines:

- Static publication-ready figures (Matplotlib + Seaborn + Altair)
- Interactive exploration (Plotly)
- Professional dashboard (Dash)
- Deep statistical profiling
