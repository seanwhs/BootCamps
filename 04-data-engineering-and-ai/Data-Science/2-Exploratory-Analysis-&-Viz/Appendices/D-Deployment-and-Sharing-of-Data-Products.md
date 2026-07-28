# Appendix D: Deployment and Sharing of Data Products

## Taking Your Dashboards and Reports from Local to Production

---

#### Purpose of This Appendix

Throughout this series, you've built sophisticated analytical products—static reports, interactive dashboards, and complete web applications. This appendix shows you how to share these products with the world, whether it's with a few colleagues or thousands of users.

You'll learn:
- Different deployment options and when to use each
- Step-by-step deployment guides for various platforms
- How to handle authentication and security
- Performance optimization for production
- Monitoring and maintenance best practices

---

## D.1 Deployment Options Overview

### D.1.1 Comparison of Deployment Methods

| Method | Best For | Pros | Cons | Cost |
|--------|----------|------|------|------|
| **Local Sharing** | Quick demo, internal team | No setup, instant | Limited access, security risks | Free |
| **Jupyter Notebooks** | Exploratory analysis, education | Interactive, familiar | Not for end-users | Free |
| **Streamlit / Dash Sharing** | Web apps, dashboards | Python-only, easy | Limited customization | $0-100/mo |
| **Cloud Platforms (AWS, GCP, Azure)** | Production, enterprise | Scalable, full control | Complex, expensive | $50-500+/mo |
| **Docker Containerization** | Consistent deployment | Portable, reproducible | Requires DevOps knowledge | Depends |
| **Static Hosting (GitHub Pages)** | Static reports | Free, fast | No interactivity | Free |

### D.1.2 Choosing the Right Method

**Decision Tree:**

```
Is interactivity required?
    ├── No → Static HTML/PDF report
    │       ├── GitHub Pages (free)
    │       └── Email/Slack attachment
    │
    └── Yes → Interactive app required
        ├── For internal team only?
        │   ├── Yes → Local server / Jupyter Notebook
        │   └── No → Public deployment
        │       ├── Simple app?
        │       │   ├── Yes → Streamlit / Dash Sharing
        │       │   └── No → Full cloud deployment
        │       │
        │       └── Enterprise requirements?
        │           ├── Yes → AWS/GCP/Azure
        │           └── No → Heroku / PythonAnywhere
```

---

## D.2 Exporting and Sharing Static Reports

### D.2.1 HTML Export from Dash

```python
# Export Dash app to static HTML (simple version)
import dash
from dash import dcc, html
import plotly.express as px

# Create a simple app
app = dash.Dash(__name__)
app.layout = html.Div([
    html.H1("My Dashboard"),
    dcc.Graph(figure=px.scatter(df, x='age', y='order_frequency'))
])

# Export to HTML
app.index_string = '''
<!DOCTYPE html>
<html>
    <head>
        {%metas%}
        <title>{%title%}</title>
        {%favicon%}
        {%css%}
    </head>
    <body>
        {%app_entry%}
        <footer>
            {%config%}
            {%scripts%}
            {%renderer%}
        </footer>
    </body>
</html>
'''

# Save as static HTML
with open('dashboard_static.html', 'w') as f:
    f.write(app.index_string)
```

### D.2.2 PDF Report Generation

```python
from weasyprint import HTML
import matplotlib.pyplot as plt
from pathlib import Path

def generate_pdf_report(df, figures, report_text, output_path):
    """
    Generate a PDF report with text and figures.
    """
    # Create HTML content
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            h1 { color: #2C3E50; border-bottom: 2px solid #3498DB; }
            h2 { color: #34495E; margin-top: 30px; }
            .figure { margin: 20px 0; text-align: center; }
            img { max-width: 100%; height: auto; border: 1px solid #ddd; }
            .summary { background: #f8f9fa; padding: 20px; border-radius: 5px; }
        </style>
    </head>
    <body>
        <h1>Customer Insights Report</h1>
        <div class="summary">
            <h2>Executive Summary</h2>
            <p>{summary}</p>
        </div>
        <h2>Key Figures</h2>
        {figures_html}
        <h2>Detailed Analysis</h2>
        <pre>{report_text}</pre>
    </body>
    </html>
    """
    
    # Convert figures to base64 for embedding
    figures_html = ""
    for i, fig in enumerate(figures):
        # Save figure to temp file
        temp_path = Path(f"temp_figure_{i}.png")
        fig.savefig(temp_path, dpi=150, bbox_inches='tight')
        
        # Encode as base64
        import base64
        with open(temp_path, 'rb') as f:
            img_data = base64.b64encode(f.read()).decode()
        
        figures_html += f'<div class="figure"><img src="data:image/png;base64,{img_data}" /></div>'
        temp_path.unlink()  # Clean up
    
    # Generate summary
    summary = f"""
    Total Customers: {len(df):,}
    Average Age: {df['age'].mean():.1f}
    Average Order Value: ${df['avg_order_value'].mean():.2f}
    Average Rating: {df['customer_rating'].mean():.2f}/5.0
    """
    
    # Fill template
    html_content = html_content.format(
        summary=summary,
        figures_html=figures_html,
        report_text=report_text
    )
    
    # Generate PDF
    HTML(string=html_content).write_pdf(output_path)
    print(f"✅ PDF report generated: {output_path}")

# Usage
figures = [create_figure1(), create_figure2(), create_figure3()]
generate_pdf_report(df, figures, report_text, "customer_report.pdf")
```

---

## D.3 Deploying Dash Apps

### D.3.1 Dash Enterprise (Paid)

```python
# dash_enterprise_deploy.py
import os
from dash import Dash

app = Dash(__name__)
# ... your app code ...

if __name__ == '__main__':
    # Dash Enterprise deployment
    app.run_server(
        debug=False,
        host='0.0.0.0',
        port=int(os.environ.get('PORT', 8050))
    )
```

### D.3.2 Heroku Deployment

**Step 1: Create Requirements File**

```txt
# requirements.txt for Heroku
dash==2.9.0
dash-bootstrap-components==1.4.0
plotly==5.14.0
pandas==2.0.0
numpy==1.24.0
gunicorn==20.1.0
```

**Step 2: Create Procfile**

```txt
# Procfile
web: gunicorn app:server
```

**Step 3: Create app.py**

```python
# app.py
import dash
from dash import dcc, html
import plotly.express as px
import pandas as pd

# Load data
df = pd.read_csv('data/customer_data.csv')

# Create app
app = dash.Dash(__name__)
server = app.server

app.layout = html.Div([
    html.H1("Customer Analytics"),
    dcc.Graph(figure=px.scatter(df, x='age', y='order_frequency'))
])

if __name__ == '__main__':
    app.run_server(debug=False)
```

**Step 4: Deploy to Heroku**

```bash
# Install Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# Login
heroku login

# Create app
heroku create my-customer-dashboard

# Add git
git init
git add .
git commit -m "Initial commit"

# Deploy
git push heroku main

# Open app
heroku open
```

### D.3.3 AWS EC2 Deployment

**Step 1: Launch EC2 Instance**

```bash
# SSH into EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Update system
sudo apt update
sudo apt upgrade -y

# Install Python and pip
sudo apt install python3-pip python3-venv -y

# Clone your repository
git clone https://github.com/yourusername/customer-dashboard.git
cd customer-dashboard

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

**Step 2: Run with Gunicorn**

```bash
# Install gunicorn
pip install gunicorn

# Run app
gunicorn -w 4 -b 0.0.0.0:8000 app:server
```

**Step 3: Set Up Nginx (Optional)**

```bash
# Install nginx
sudo apt install nginx -y

# Create nginx config
sudo nano /etc/nginx/sites-available/myapp

# Add configuration
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### D.3.4 Docker Deployment

**Dockerfile:**

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose port
EXPOSE 8050

# Run application
CMD ["python", "app.py"]
```

**docker-compose.yml:**

```yaml
# docker-compose.yml
version: '3.8'

services:
  dashboard:
    build: .
    ports:
      - "8050:8050"
    environment:
      - PYTHONUNBUFFERED=1
    volumes:
      - ./data:/app/data
    restart: unless-stopped
```

**Build and Run:**

```bash
# Build image
docker build -t customer-dashboard .

# Run container
docker run -p 8050:8050 customer-dashboard

# Or use docker-compose
docker-compose up -d
```

---

## D.4 Deploying Jupyter Notebooks

### D.4.1 Jupyter Notebook as Dashboard

```python
# Convert notebook to Python script with Voilà
# voila_dashboard.ipynb → voila_dashboard.py

import ipywidgets as widgets
from IPython.display import display
import pandas as pd
import plotly.express as px

# Load data
df = pd.read_csv('data/customer_data.csv')

# Create widgets
age_slider = widgets.IntSlider(
    min=18, max=70, value=35,
    description='Age:'
)

category_dropdown = widgets.Dropdown(
    options=['All'] + list(df['favorite_category'].unique()),
    value='All',
    description='Category:'
)

# Create output
output = widgets.Output()

def update_chart(age, category):
    with output:
        output.clear_output()
        filtered = df[df['age'] <= age]
        if category != 'All':
            filtered = filtered[filtered['favorite_category'] == category]
        fig = px.scatter(filtered, x='age', y='order_frequency')
        fig.show()

# Link widgets
widgets.interactive(update_chart, age=age_slider, category=category_dropdown)

# Display
display(age_slider, category_dropdown, output)
```

### D.4.2 Voilà Deployment

```bash
# Install Voilà
pip install voila

# Run voilà
voila voila_dashboard.ipynb

# Deploy with ngrok for public access
ngrok http 8866
```

---

## D.5 Deploying Altair Charts

### D.5.1 Altair as Standalone HTML

```python
import altair as alt
import pandas as pd

# Create chart
chart = alt.Chart(df).mark_point().encode(
    x='age:Q',
    y='order_frequency:Q',
    color='income_bracket:N'
).interactive()

# Save as HTML
chart.save('altair_chart.html')

# Embed in simple HTML page
html_template = """
<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
    <script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
    <script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>
</head>
<body>
    <div id="chart"></div>
    <script>
        vegaEmbed('#chart', {chart_spec}).then(result => {
            // Chart rendered
        }).catch(console.error);
    </script>
</body>
</html>
"""

# Embed chart specification
with open('altair_chart.json', 'r') as f:
    chart_spec = f.read()

html_content = html_template.replace('{chart_spec}', chart_spec)

with open('altair_embedded.html', 'w') as f:
    f.write(html_content)
```

### D.5.2 Altair with GitHub Pages

```bash
# Create GitHub repository
git init
git add altair_embedded.html
git commit -m "Add Altair chart"
git remote add origin https://github.com/username/repo.git
git push -u origin main

# Enable GitHub Pages
# Settings → Pages → Branch: main → /docs

# OR create docs folder
mkdir docs
cp altair_embedded.html docs/index.html
git add docs/
git commit -m "Add GitHub Pages"
git push
```

---

## D.6 Security and Authentication

### D.6.1 Basic Authentication with Dash

```python
import dash
from dash import dcc, html, Input, Output, State
import os

# Simple authentication
USERNAME = os.environ.get('DASH_USERNAME', 'admin')
PASSWORD = os.environ.get('DASH_PASSWORD', 'password')

app = dash.Dash(__name__)

# Login page
login_layout = html.Div([
    html.H2("Please Login"),
    html.Div([
        dcc.Input(id='username-input', placeholder='Username', type='text'),
        dcc.Input(id='password-input', placeholder='Password', type='password'),
        html.Button('Login', id='login-button'),
        html.Div(id='login-message')
    ])
])

# Main dashboard (protected)
dashboard_layout = html.Div([
    html.H1("Customer Dashboard"),
    dcc.Graph(id='main-chart'),
    html.Button('Logout', id='logout-button')
])

app.layout = html.Div(id='app-container', children=[login_layout])

# Authentication callback
@app.callback(
    Output('app-container', 'children'),
    Input('login-button', 'n_clicks'),
    State('username-input', 'value'),
    State('password-input', 'value')
)
def authenticate(n_clicks, username, password):
    if n_clicks:
        if username == USERNAME and password == PASSWORD:
            return dashboard_layout
        else:
            return html.Div([
                login_layout,
                html.Div("Invalid credentials", style={'color': 'red'})
            ])
    return login_layout

# Logout callback
@app.callback(
    Output('app-container', 'children', allow_duplicate=True),
    Input('logout-button', 'n_clicks'),
    prevent_initial_call=True
)
def logout(n_clicks):
    if n_clicks:
        return login_layout
```

### D.6.2 OAuth with Google (Advanced)

```python
# Requires: pip install flask-oauthlib
# This is a simplified example - see official docs for full implementation

from flask import Flask, redirect, url_for, session, request
from flask_oauthlib.client import OAuth

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev-secret-key')

oauth = OAuth(app)
google = oauth.remote_app(
    'google',
    consumer_key=os.environ.get('GOOGLE_CLIENT_ID'),
    consumer_secret=os.environ.get('GOOGLE_CLIENT_SECRET'),
    request_token_params={'scope': 'email'},
    base_url='https://www.googleapis.com/oauth2/v1/',
    request_token_url=None,
    access_token_method='POST',
    access_token_url='https://accounts.google.com/o/oauth2/token',
    authorize_url='https://accounts.google.com/o/oauth2/auth'
)

@app.route('/login')
def login():
    return google.authorize(callback=url_for('authorized', _external=True))

@app.route('/logout')
def logout():
    session.pop('google_token', None)
    return redirect('/')

@app.route('/authorized')
def authorized():
    resp = google.authorized_response()
    if resp is None:
        return 'Access denied: reason=%s error=%s' % (
            request.args['error_reason'],
            request.args['error_description']
        )
    session['google_token'] = (resp['access_token'], '')
    return redirect('/dashboard')
```

---

## D.7 Performance Optimization

### D.7.1 Data Optimization

```python
def optimize_dataframe(df):
    """
    Optimize DataFrame memory usage.
    """
    df_optimized = df.copy()
    
    for col in df_optimized.columns:
        col_type = df_optimized[col].dtype
        
        # Downcast numeric columns
        if col_type != 'object':
            if 'int' in str(col_type):
                df_optimized[col] = pd.to_numeric(df_optimized[col], downcast='integer')
            elif 'float' in str(col_type):
                df_optimized[col] = pd.to_numeric(df_optimized[col], downcast='float')
        
        # Convert to categorical for low cardinality
        elif df_optimized[col].nunique() / len(df_optimized) < 0.05:
            df_optimized[col] = df_optimized[col].astype('category')
    
    memory_usage = df.memory_usage(deep=True).sum() / 1024**2
    optimized_usage = df_optimized.memory_usage(deep=True).sum() / 1024**2
    
    print(f"Memory: {memory_usage:.2f} MB → {optimized_usage:.2f} MB")
    print(f"Reduction: {(1 - optimized_usage/memory_usage) * 100:.1f}%")
    
    return df_optimized

# Usage
df_optimized = optimize_dataframe(df)
```

### D.7.2 Caching Strategies

```python
from functools import lru_cache
import pandas as pd

# Cache data loading
@lru_cache(maxsize=1)
def load_data_cached():
    """Load data once and cache for subsequent calls."""
    return pd.read_csv('data/customer_data.csv')

# Cache expensive computations
@lru_cache(maxsize=128)
def expensive_computation(data_hash, params):
    """Cache results of expensive computations."""
    # Simulate expensive computation
    result = complex_analysis(data, params)
    return result

# Use in Dash callbacks
from dash import Dash, dcc, html, Input, Output, State, callback

@callback(
    Output('chart', 'figure'),
    Input('filter', 'value'),
    State('data-store', 'data')
)
def update_chart(filter_value, stored_data):
    # Use cached data
    df = load_data_cached()
    
    # Filter
    filtered = df[df['category'] == filter_value]
    
    # Create chart
    return create_chart(filtered)
```

### D.7.3 Lazy Loading

```python
# Lazy load large components
import dash_bootstrap_components as dbc

def create_dashboard():
    """Create dashboard with lazy-loaded components."""
    
    # Define placeholder for large chart
    chart_placeholder = html.Div([
        html.H4("Loading chart..."),
        dcc.Loading(
            id="loading-chart",
            type="circle",
            children=[
                html.Div(id="chart-container")
            ]
        )
    ])
    
    # Chart loads on demand via callback
    @callback(
        Output('chart-container', 'children'),
        Input('load-chart', 'n_clicks'),
        State('filter-data', 'value')
    )
    def load_chart_on_demand(n_clicks, filter_value):
        if n_clicks:
            # Create and return chart
            return dcc.Graph(figure=create_large_chart(filter_value))
        return html.Div("Click to load chart")
    
    return html.Div([
        html.Button("Load Chart", id="load-chart"),
        chart_placeholder
    ])
```

### D.7.4 Database Connections (for Large Datasets)

```python
import sqlite3
import pandas as pd

# Use SQLite for large datasets
def create_database(df, db_path='data.db'):
    """Store DataFrame in SQLite database."""
    conn = sqlite3.connect(db_path)
    df.to_sql('customers', conn, if_exists='replace', index=False)
    conn.close()
    print(f"✅ Database created: {db_path}")

def query_data(query, db_path='data.db'):
    """Query data from database."""
    conn = sqlite3.connect(db_path)
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df

# Usage
create_database(df, 'customer_data.db')

# Query only what you need
filtered = query_data("""
    SELECT customer_id, age, order_frequency, avg_order_value
    FROM customers
    WHERE age BETWEEN 25 AND 45
    AND order_frequency > 1
""")
```

---

## D.8 Monitoring and Maintenance

### D.8.1 Logging

```python
import logging
from datetime import datetime

# Set up logging
logging.basicConfig(
    filename='dashboard.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def log_dashboard_activity(user_action, details):
    """Log dashboard activity."""
    logging.info(f"User: {user_action} - {details}")

# Example usage in callback
@callback(
    Output('result', 'children'),
    Input('action-button', 'n_clicks'),
    State('user-id', 'value')
)
def perform_action(n_clicks, user_id):
    if n_clicks:
        try:
            # Perform action
            result = process_data()
            
            # Log success
            log_dashboard_activity(
                user_id,
                f"Action completed successfully: {result}"
            )
            
            return result
        
        except Exception as e:
            # Log error
            log_dashboard_activity(
                user_id,
                f"Error: {str(e)}"
            )
            return f"Error: {str(e)}"
```

### D.8.2 Health Checks

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/health')
def health_check():
    """Health check endpoint."""
    try:
        # Check database connection
        df = load_data_cached()
        if df is None:
            return jsonify({'status': 'error', 'message': 'Data not loaded'}), 500
        
        # Check memory
        import psutil
        memory = psutil.virtual_memory()
        if memory.percent > 90:
            return jsonify({'status': 'warning', 'message': 'Memory high'}), 200
        
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'data_rows': len(df),
            'memory_percent': memory.percent
        }), 200
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/metrics')
def metrics():
    """Application metrics."""
    import psutil
    
    return jsonify({
        'cpu_percent': psutil.cpu_percent(),
        'memory_percent': psutil.virtual_memory().percent,
        'disk_usage': psutil.disk_usage('/').percent,
        'data_rows': len(load_data_cached()),
        'uptime': datetime.now() - app.start_time
    })
```

### D.8.3 Scheduled Updates

```python
import schedule
import time
from threading import Thread

def update_data():
    """Scheduled data update function."""
    print(f"🔄 Updating data at {datetime.now()}")
    try:
        # Update data from source
        new_data = fetch_latest_data()
        new_data.to_csv('data/customer_data_latest.csv', index=False)
        
        # Invalidate cache
        load_data_cached.cache_clear()
        
        print(f"✅ Update complete. New records: {len(new_data)}")
    
    except Exception as e:
        print(f"❌ Update failed: {e}")

def run_scheduler():
    """Run scheduled tasks in background."""
    schedule.every().day.at("02:00").do(update_data)
    schedule.every(6).hours.do(update_data)  # Fallback
    
    while True:
        schedule.run_pending()
        time.sleep(60)

# Start scheduler in background thread
scheduler_thread = Thread(target=run_scheduler, daemon=True)
scheduler_thread.start()
```

---

## D.9 Common Deployment Issues and Solutions

| Issue | Solution |
|-------|----------|
| **App won't start** | Check logs: `heroku logs --tail` |
| **Memory limit exceeded** | Optimize data, use database |
| **Slow first load** | Implement caching, lazy loading |
| **Session timeout** | Configure session timeout in app |
| **Data not updating** | Implement scheduled updates |
| **SSL certificate error** | Use `verify=False` or proper cert |
| **Port already in use** | Change port or kill process |
| **Missing dependencies** | Check requirements.txt |
| **Static files not loading** | Check file paths, use absolute paths |

---

## D.10 Quick Deployment Checklist

**Before Deployment:**

- [ ] All dependencies listed in requirements.txt
- [ ] Environment variables configured
- [ ] Data files included or accessible
- [ ] Secret keys/passwords in environment variables
- [ ] App runs locally without errors
- [ ] Error handling implemented
- [ ] Logging configured
- [ ] Performance tested with realistic data

**During Deployment:**

- [ ] Platform selected
- [ ] Deployment method chosen
- [ ] Security configured
- [ ] Health checks implemented
- [ ] Monitoring set up

**After Deployment:**

- [ ] App accessible at URL
- [ ] All features working
- [ ] Data loading correctly
- [ ] Error logging working
- [ ] Performance acceptable
- [ ] Backup plan in place

---

## D.11 Useful Deployment Commands

```bash
# Heroku
heroku create app-name
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set SECRET_KEY=your-secret
git push heroku main
heroku logs --tail

# Docker
docker build -t myapp .
docker run -d -p 8050:8050 --name myapp myapp
docker logs myapp
docker stop myapp
docker rm myapp

# AWS EC2
ssh -i key.pem ubuntu@ec2-ip
sudo systemctl restart nginx
sudo journalctl -u myapp -f

# Gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 app:server
pkill gunicorn

# PythonAnywhere
# Web tab → Add Web App → Manual configuration
# Source code: /home/username/mysite/
# WSGI file: /var/www/username_pythonanywhere_com_wsgi.py
```

---

## D.12 Key Takeaways

1. **Choose the right deployment method** based on your needs and audience
2. **Security is critical** - always protect sensitive data
3. **Optimize performance** for a smooth user experience
4. **Monitor and maintain** your deployed application
5. **Document everything** for troubleshooting
6. **Test thoroughly** before deploying to production
7. **Have a rollback plan** if something goes wrong

This appendix provides a comprehensive guide to deploying and sharing your data products. It covers everything from simple static exports to full cloud deployments, with practical code examples and best practices throughout.

The techniques here will help you move from development to production, making your analytical work accessible to stakeholders and users around the world.
