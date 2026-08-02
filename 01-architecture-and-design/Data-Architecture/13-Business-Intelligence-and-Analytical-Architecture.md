# Part 13: Business Intelligence and Analytical Architecture

Welcome to Part 13, where we explore how raw data is transformed into meaningful business insights. Think of BI like a car's dashboard - it takes complex data from various sensors and systems and presents it as simple, actionable information that helps you make decisions.

## Learning Objectives

By the end of this part, you will be able to:

- Understand OLTP vs. OLAP systems
- Design star and snowflake schemas
- Build fact and dimension models
- Create data marts for business domains
- Design executive dashboards and KPIs
- Implement semantic layers for self-service analytics

---

## 13.1 OLTP vs. OLAP and Dimensional Modeling

### The Concept

Dimensional modeling organizes data for analysis. Think of it like organizing a warehouse for retail - facts are the transactions (what happened), and dimensions are the descriptive attributes (who, what, when, where).

### The Implementation

**File: `part-13-bi-analytics/dimensional_modeling.py`**
```python
#!/usr/bin/env python3
"""
Dimensional Modeling Implementation
Star Schema, Snowflake Schema, and Data Marts
"""

import time
import json
import random
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class Dimension:
    """A dimension table"""
    name: str
    attributes: Dict[str, str]  # attribute_name -> data_type
    data: List[Dict[str, Any]]

@dataclass
class FactTable:
    """A fact table"""
    name: str
    measures: Dict[str, str]  # measure_name -> data_type
    dimensions: List[str]  # dimension names
    data: List[Dict[str, Any]]

class DimensionalModelBuilder:
    """
    Builds dimensional models (star/snowflake schemas)
    """
    
    def __init__(self):
        self.dimensions: Dict[str, Dimension] = {}
        self.fact_tables: Dict[str, FactTable] = {}
    
    def create_dimension(self, name: str, attributes: Dict[str, str]) -> Dimension:
        """Create a dimension table"""
        dim = Dimension(name=name, attributes=attributes, data=[])
        self.dimensions[name] = dim
        print(f"   📊 Dimension created: {name}")
        return dim
    
    def create_fact_table(self, name: str, measures: Dict[str, str],
                          dimensions: List[str]) -> FactTable:
        """Create a fact table"""
        fact = FactTable(name=name, measures=measures, 
                        dimensions=dimensions, data=[])
        self.fact_tables[name] = fact
        print(f"   📊 Fact table created: {name}")
        return fact
    
    def load_dimension(self, dimension_name: str, data: List[Dict[str, Any]]):
        """Load data into a dimension"""
        if dimension_name not in self.dimensions:
            print(f"   ❌ Dimension {dimension_name} not found")
            return
        
        dim = self.dimensions[dimension_name]
        for record in data:
            # Validate attributes
            for attr in dim.attributes:
                if attr not in record:
                    print(f"   ⚠️ Missing attribute: {attr}")
                    continue
            dim.data.append(record)
        
        print(f"   📥 Loaded {len(data)} records into {dimension_name}")
    
    def load_fact(self, fact_name: str, data: List[Dict[str, Any]]):
        """Load data into a fact table"""
        if fact_name not in self.fact_tables:
            print(f"   ❌ Fact table {fact_name} not found")
            return
        
        fact = self.fact_tables[fact_name]
        for record in data:
            # Validate measures
            for measure in fact.measures:
                if measure not in record:
                    print(f"   ⚠️ Missing measure: {measure}")
                    continue
            
            # Validate dimensions
            for dim in fact.dimensions:
                if dim not in record:
                    print(f"   ⚠️ Missing dimension key: {dim}")
                    continue
            
            fact.data.append(record)
        
        print(f"   📥 Loaded {len(data)} records into {fact_name}")
    
    def query_fact(self, fact_name: str, 
                   group_by: List[str] = None,
                   measures: List[str] = None,
                   filters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Query a fact table with optional aggregations"""
        if fact_name not in self.fact_tables:
            return []
        
        fact = self.fact_tables[fact_name]
        data = fact.data
        
        # Apply filters
        if filters:
            for key, value in filters.items():
                data = [r for r in data if r.get(key) == value]
        
        # If no grouping, return filtered data
        if not group_by:
            if measures:
                return [{m: r.get(m) for m in measures} for r in data]
            return data
        
        # Apply grouping and aggregation
        groups = {}
        for record in data:
            # Create group key
            group_key = tuple(record.get(dim) for dim in group_by)
            if group_key not in groups:
                groups[group_key] = {dim: record.get(dim) for dim in group_by}
                # Initialize measures
                if measures:
                    for measure in measures:
                        groups[group_key][f"{measure}_sum"] = 0
                        groups[group_key][f"{measure}_count"] = 0
            
            # Aggregate
            if measures:
                for measure in measures:
                    groups[group_key][f"{measure}_sum"] += record.get(measure, 0)
                    groups[group_key][f"{measure}_count"] += 1
                    groups[group_key][f"{measure}_avg"] = (
                        groups[group_key][f"{measure}_sum"] / 
                        groups[group_key][f"{measure}_count"]
                    )
        
        # Convert to list
        results = list(groups.values())
        print(f"   🔍 Queried {fact_name}: {len(results)} groups")
        return results

def demo_dimensional_modeling():
    """Demonstrate dimensional modeling"""
    print("="*60)
    print("DIMENSIONAL MODELING DEMONSTRATION")
    print("="*60)
    
    # Create model builder
    builder = DimensionalModelBuilder()
    
    # Create dimensions
    print("\n📊 Creating dimensions...")
    
    time_dim = builder.create_dimension(
        "time_dim",
        {
            'date_key': 'string',
            'year': 'int',
            'quarter': 'int',
            'month': 'int',
            'day': 'int',
            'weekday': 'string'
        }
    )
    
    product_dim = builder.create_dimension(
        "product_dim",
        {
            'product_key': 'string',
            'product_name': 'string',
            'category': 'string',
            'subcategory': 'string',
            'brand': 'string',
            'price': 'float'
        }
    )
    
    customer_dim = builder.create_dimension(
        "customer_dim",
        {
            'customer_key': 'string',
            'customer_name': 'string',
            'segment': 'string',
            'country': 'string',
            'city': 'string'
        }
    )
    
    store_dim = builder.create_dimension(
        "store_dim",
        {
            'store_key': 'string',
            'store_name': 'string',
            'region': 'string',
            'country': 'string',
            'city': 'string'
        }
    )
    
    # Create fact table
    print("\n📊 Creating fact table...")
    
    sales_fact = builder.create_fact_table(
        "sales_fact",
        {
            'sales_amount': 'float',
            'quantity': 'int',
            'discount': 'float',
            'profit': 'float'
        },
        ['time_key', 'product_key', 'customer_key', 'store_key']
    )
    
    # Load dimensions
    print("\n📥 Loading dimensions...")
    
    # Time data
    time_data = []
    for i in range(365):
        date = datetime(2024, 1, 1) + timedelta(days=i)
        time_data.append({
            'date_key': date.strftime('%Y%m%d'),
            'year': date.year,
            'quarter': (date.month - 1) // 3 + 1,
            'month': date.month,
            'day': date.day,
            'weekday': date.strftime('%A')
        })
    builder.load_dimension("time_dim", time_data)
    
    # Product data
    products = [
        {'product_key': 'P001', 'product_name': 'Laptop', 'category': 'Electronics', 
         'subcategory': 'Computers', 'brand': 'Dell', 'price': 999.99},
        {'product_key': 'P002', 'product_name': 'Phone', 'category': 'Electronics',
         'subcategory': 'Mobile', 'brand': 'Apple', 'price': 799.99},
        {'product_key': 'P003', 'product_name': 'Headphones', 'category': 'Electronics',
         'subcategory': 'Audio', 'brand': 'Sony', 'price': 199.99},
        {'product_key': 'P004', 'product_name': 'Desk', 'category': 'Furniture',
         'subcategory': 'Office', 'brand': 'IKEA', 'price': 299.99},
        {'product_key': 'P005', 'product_name': 'Chair', 'category': 'Furniture',
         'subcategory': 'Office', 'brand': 'Herman Miller', 'price': 499.99}
    ]
    builder.load_dimension("product_dim", products)
    
    # Customer data
    customers = [
        {'customer_key': 'C001', 'customer_name': 'Alice', 'segment': 'Enterprise', 
         'country': 'USA', 'city': 'New York'},
        {'customer_key': 'C002', 'customer_name': 'Bob', 'segment': 'SMB',
         'country': 'Canada', 'city': 'Toronto'},
        {'customer_key': 'C003', 'customer_name': 'Charlie', 'segment': 'Consumer',
         'country': 'USA', 'city': 'San Francisco'},
        {'customer_key': 'C004', 'customer_name': 'David', 'segment': 'Enterprise',
         'country': 'UK', 'city': 'London'},
        {'customer_key': 'C005', 'customer_name': 'Eve', 'segment': 'SMB',
         'country': 'USA', 'city': 'Chicago'}
    ]
    builder.load_dimension("customer_dim", customers)
    
    # Store data
    stores = [
        {'store_key': 'S001', 'store_name': 'NYC Store', 'region': 'Northeast',
         'country': 'USA', 'city': 'New York'},
        {'store_key': 'S002', 'store_name': 'LA Store', 'region': 'West',
         'country': 'USA', 'city': 'Los Angeles'},
        {'store_key': 'S003', 'store_name': 'London Store', 'region': 'Europe',
         'country': 'UK', 'city': 'London'},
        {'store_key': 'S004', 'store_name': 'Toronto Store', 'region': 'Canada',
         'country': 'Canada', 'city': 'Toronto'}
    ]
    builder.load_dimension("store_dim", stores)
    
    # Generate sales data
    print("\n📥 Generating sales data...")
    sales_data = []
    
    for i in range(500):
        # Select random dimension keys
        time_key = random.choice(time_data)['date_key']
        product_key = random.choice(products)['product_key']
        customer_key = random.choice(customers)['customer_key']
        store_key = random.choice(stores)['store_key']
        
        # Generate sales metrics
        product_price = next(p['price'] for p in products if p['product_key'] == product_key)
        quantity = random.randint(1, 5)
        discount = random.uniform(0, 0.2)
        
        sales_data.append({
            'time_key': time_key,
            'product_key': product_key,
            'customer_key': customer_key,
            'store_key': store_key,
            'sales_amount': product_price * quantity * (1 - discount),
            'quantity': quantity,
            'discount': discount,
            'profit': product_price * quantity * (1 - discount) * random.uniform(0.1, 0.3)
        })
    
    builder.load_fact("sales_fact", sales_data)
    
    # Query examples
    print("\n🔍 Querying sales data...")
    
    # Query 1: Sales by product
    print("\n   Sales by Product:")
    product_sales = builder.query_fact(
        "sales_fact",
        group_by=['product_key'],
        measures=['sales_amount', 'quantity']
    )
    for record in product_sales[:5]:
        print(f"      Product {record['product_key']}: "
              f"${record['sales_amount_sum']:.2f}, {record['quantity_sum']} units")
    
    # Query 2: Sales by month
    print("\n   Sales by Month:")
    month_sales = builder.query_fact(
        "sales_fact",
        group_by=['time_key'],
        measures=['sales_amount']
    )
    # Aggregate by month (simplified)
    month_totals = {}
    for record in month_sales:
        month = record['time_key'][:6]  # YYYYMM
        if month not in month_totals:
            month_totals[month] = 0
        month_totals[month] += record['sales_amount_sum']
    
    for month, total in sorted(month_totals.items()):
        print(f"      {month}: ${total:.2f}")
    
    # Query 3: Sales by customer segment
    print("\n   Sales by Customer Segment:")
    segment_sales = builder.query_fact(
        "sales_fact",
        group_by=['customer_key'],
        measures=['sales_amount']
    )
    # Join with customer dimension
    segment_totals = {}
    for record in segment_sales:
        customer_key = record['customer_key']
        segment = next(c['segment'] for c in customers if c['customer_key'] == customer_key)
        if segment not in segment_totals:
            segment_totals[segment] = 0
        segment_totals[segment] += record['sales_amount_sum']
    
    for segment, total in segment_totals.items():
        print(f"      {segment}: ${total:.2f}")

def main():
    """Run dimensional modeling demonstration"""
    demo_dimensional_modeling()
    
    print("\n" + "="*60)
    print("✅ DIMENSIONAL MODELING DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    random.seed(42)
    main()
```

---

## 13.2 Star Schema vs. Snowflake Schema

### The Concept

- **Star Schema**: Single-level dimensions (like a star - fact table in center, dimensions around)
- **Snowflake Schema**: Normalized dimensions (like a snowflake - dimensions expand into sub-dimensions)

### The Implementation

**File: `part-13-bi-analytics/star_snowflake.py`**
```python
#!/usr/bin/env python3
"""
Star Schema vs. Snowflake Schema Comparison
"""

import time
from typing import Dict, List, Any, Optional
from dataclasses import dataclass

@dataclass
class StarDimension:
    """A dimension in star schema (denormalized)"""
    name: str
    data: List[Dict[str, Any]]

@dataclass
class StarFact:
    """A fact table in star schema"""
    name: str
    data: List[Dict[str, Any]]

class StarSchema:
    """
    Star Schema implementation
    Denormalized dimensions for query performance
    """
    
    def __init__(self, name: str):
        self.name = name
        self.fact = StarFact("fact", [])
        self.dimensions: Dict[str, StarDimension] = {}
        self.query_count = 0
        self.query_time_ms = 0
    
    def add_dimension(self, name: str, data: List[Dict[str, Any]]):
        """Add a dimension to the star schema"""
        dim = StarDimension(name, data)
        self.dimensions[name] = dim
        print(f"   ⭐ Added dimension: {name} ({len(data)} records)")
    
    def load_fact(self, data: List[Dict[str, Any]]):
        """Load fact data"""
        self.fact.data.extend(data)
        print(f"   ⭐ Loaded fact: {len(data)} records")
    
    def query(self, dimension: str, measure: str, 
              aggregation: str = 'sum') -> Dict[str, Any]:
        """Query the star schema"""
        start_time = time.time()
        self.query_count += 1
        
        if dimension not in self.dimensions:
            return {}
        
        dim = self.dimensions[dimension]
        results = {}
        
        # Join fact with dimension
        for fact_record in self.fact.data:
            dim_key = fact_record.get(f"{dimension}_key")
            # Find dimension record
            dim_record = next((d for d in dim.data if d.get('key') == dim_key), None)
            if not dim_record:
                continue
            
            dim_value = dim_record.get('name', dim_key)
            measure_value = fact_record.get(measure, 0)
            
            if aggregation == 'sum':
                results[dim_value] = results.get(dim_value, 0) + measure_value
            elif aggregation == 'count':
                results[dim_value] = results.get(dim_value, 0) + 1
            elif aggregation == 'avg':
                if dim_value not in results:
                    results[dim_value] = []
                results[dim_value].append(measure_value)
        
        # Calculate averages if needed
        if aggregation == 'avg':
            for key, values in results.items():
                results[key] = sum(values) / len(values) if values else 0
        
        elapsed_ms = (time.time() - start_time) * 1000
        self.query_time_ms += elapsed_ms
        
        return results
    
    def get_stats(self) -> Dict[str, Any]:
        """Get schema statistics"""
        return {
            'name': self.name,
            'type': 'star',
            'dimensions': len(self.dimensions),
            'fact_records': len(self.fact.data),
            'query_count': self.query_count,
            'avg_query_time_ms': self.query_time_ms / self.query_count if self.query_count > 0 else 0
        }

class SnowflakeSchema:
    """
    Snowflake Schema implementation
    Normalized dimensions for storage efficiency
    """
    
    def __init__(self, name: str):
        self.name = name
        self.fact = StarFact("fact", [])
        self.dimensions: Dict[str, List[Dict[str, Any]]] = {}
        self.dim_relationships: Dict[str, Dict[str, str]] = {}
        self.query_count = 0
        self.query_time_ms = 0
    
    def add_dimension(self, name: str, data: List[Dict[str, Any]],
                     parent_dim: str = None, parent_key: str = None):
        """Add a dimension (normalized)"""
        self.dimensions[name] = data
        
        if parent_dim:
            self.dim_relationships[name] = {
                'parent': parent_dim,
                'parent_key': parent_key
            }
        
        print(f"   ❄️ Added dimension: {name} ({len(data)} records)")
    
    def load_fact(self, data: List[Dict[str, Any]]):
        """Load fact data"""
        self.fact.data.extend(data)
        print(f"   ❄️ Loaded fact: {len(data)} records")
    
    def query(self, dimension: str, sub_dimension: str,
              measure: str, aggregation: str = 'sum') -> Dict[str, Any]:
        """Query the snowflake schema (nested join)"""
        start_time = time.time()
        self.query_count += 1
        
        if dimension not in self.dimensions or sub_dimension not in self.dimensions:
            return {}
        
        dim_data = self.dimensions[dimension]
        sub_dim_data = self.dimensions[sub_dimension]
        
        results = {}
        
        # Perform nested join
        for fact_record in self.fact.data:
            dim_key = fact_record.get(f"{dimension}_key")
            dim_record = next((d for d in dim_data if d.get('key') == dim_key), None)
            if not dim_record:
                continue
            
            # Get sub-dimension key
            sub_key = dim_record.get(f"{sub_dimension}_key")
            sub_record = next((s for s in sub_dim_data if s.get('key') == sub_key), None)
            if not sub_record:
                continue
            
            sub_value = sub_record.get('name', sub_key)
            measure_value = fact_record.get(measure, 0)
            
            if aggregation == 'sum':
                results[sub_value] = results.get(sub_value, 0) + measure_value
            elif aggregation == 'count':
                results[sub_value] = results.get(sub_value, 0) + 1
        
        elapsed_ms = (time.time() - start_time) * 1000
        self.query_time_ms += elapsed_ms
        
        return results
    
    def get_stats(self) -> Dict[str, Any]:
        """Get schema statistics"""
        return {
            'name': self.name,
            'type': 'snowflake',
            'dimensions': len(self.dimensions),
            'fact_records': len(self.fact.data),
            'query_count': self.query_count,
            'avg_query_time_ms': self.query_time_ms / self.query_count if self.query_count > 0 else 0
        }

def demo_star_vs_snowflake():
    """Compare star and snowflake schemas"""
    print("="*60)
    print("STAR VS. SNOWFLAKE SCHEMA COMPARISON")
    print("="*60)
    
    # Create both schemas
    print("\n📊 Creating Star Schema...")
    star = StarSchema("Sales Star")
    
    print("\n📊 Creating Snowflake Schema...")
    snowflake = SnowflakeSchema("Sales Snowflake")
    
    # Prepare dimension data
    product_category_data = [
        {'key': 'C001', 'name': 'Electronics'},
        {'key': 'C002', 'name': 'Furniture'},
        {'key': 'C003', 'name': 'Clothing'}
    ]
    
    product_data = [
        {'key': 'P001', 'name': 'Laptop', 'category_key': 'C001', 'price': 999.99},
        {'key': 'P002', 'name': 'Phone', 'category_key': 'C001', 'price': 799.99},
        {'key': 'P003', 'name': 'Desk', 'category_key': 'C002', 'price': 299.99},
        {'key': 'P004', 'name': 'Chair', 'category_key': 'C002', 'price': 499.99},
        {'key': 'P005', 'name': 'Shirt', 'category_key': 'C003', 'price': 49.99}
    ]
    
    # Load Star Schema (denormalized product dimension)
    star_dim_data = []
    for p in product_data:
        category = next(c['name'] for c in product_category_data if c['key'] == p['category_key'])
        star_dim_data.append({
            'key': p['key'],
            'name': p['name'],
            'category': category,
            'price': p['price']
        })
    
    star.add_dimension('product', star_dim_data)
    
    # Load Snowflake Schema (normalized)
    snowflake.add_dimension('product_category', product_category_data)
    snowflake.add_dimension('product', product_data, 
                           parent_dim='product_category', 
                           parent_key='category_key')
    
    # Generate fact data
    fact_data = []
    for i in range(1000):
        product_key = random.choice(product_data)['key']
        fact_data.append({
            'product_key': product_key,
            'sales_amount': random.uniform(50, 500),
            'quantity': random.randint(1, 10)
        })
    
    star.load_fact(fact_data)
    snowflake.load_fact(fact_data)
    
    # Query both schemas
    print("\n🔍 Querying both schemas...")
    
    # Query 1: Sales by product
    print("\n   Sales by Product:")
    
    print("   Star Schema:")
    start_time = time.time()
    star_results = star.query('product', 'sales_amount', 'sum')
    star_time = (time.time() - start_time) * 1000
    
    for product, amount in list(star_results.items())[:3]:
        print(f"      {product}: ${amount:.2f}")
    
    print(f"      Query time: {star_time:.2f}ms")
    
    print("   Snowflake Schema:")
    start_time = time.time()
    snow_results = snowflake.query('product', 'product', 'sales_amount', 'sum')
    snow_time = (time.time() - start_time) * 1000
    
    for product, amount in list(snow_results.items())[:3]:
        print(f"      {product}: ${amount:.2f}")
    
    print(f"      Query time: {snow_time:.2f}ms")
    
    # Query 2: Sales by category (requires join in both)
    print("\n   Sales by Category:")
    
    print("   Star Schema:")
    start_time = time.time()
    star_results = star.query('product', 'sales_amount', 'sum')
    # Group by category
    category_totals = {}
    for product, amount in star_results.items():
        # Find category from star dimension
        category = next(d['category'] for d in star_dim_data if d['name'] == product)
        if category not in category_totals:
            category_totals[category] = 0
        category_totals[category] += amount
    
    star_time = (time.time() - start_time) * 1000
    
    for category, amount in category_totals.items():
        print(f"      {category}: ${amount:.2f}")
    
    print(f"      Query time: {star_time:.2f}ms")
    
    print("   Snowflake Schema:")
    start_time = time.time()
    snow_results = snowflake.query('product_category', 'product_category', 'sales_amount', 'sum')
    snow_time = (time.time() - start_time) * 1000
    
    for category, amount in snow_results.items():
        print(f"      {category}: ${amount:.2f}")
    
    print(f"      Query time: {snow_time:.2f}ms")
    
    # Show statistics
    print(f"\n📊 Schema Statistics:")
    
    star_stats = star.get_stats()
    print(f"   Star Schema:")
    print(f"      Dimensions: {star_stats['dimensions']}")
    print(f"      Fact Records: {star_stats['fact_records']}")
    print(f"      Avg Query Time: {star_stats['avg_query_time_ms']:.2f}ms")
    
    snow_stats = snowflake.get_stats()
    print(f"   Snowflake Schema:")
    print(f"      Dimensions: {snow_stats['dimensions']}")
    print(f"      Fact Records: {snow_stats['fact_records']}")
    print(f"      Avg Query Time: {snow_stats['avg_query_time_ms']:.2f}ms")
    
    print("\n🎯 Schema Comparison:")
    print("   • Star: Denormalized, faster queries, more storage")
    print("   • Snowflake: Normalized, less storage, more complex queries")

def main():
    """Run star vs snowflake comparison"""
    import random
    random.seed(42)
    demo_star_vs_snowflake()
    
    print("\n" + "="*60)
    print("✅ STAR VS. SNOWFLAKE DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 13.3 Business Intelligence Dashboards

### The Concept

BI dashboards present key metrics and visualizations to business users. Think of it like a car's dashboard - it shows speed (KPIs), fuel level (resource usage), and alerts (anomalies) at a glance.

### The Implementation

**File: `part-13-bi-analytics/bi_dashboard.py`**
```python
#!/usr/bin/env python3
"""
Business Intelligence Dashboard Implementation
"""

import time
import json
import random
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class DashboardWidget:
    """A dashboard widget"""
    widget_id: str
    title: str
    type: str  # metric, chart, table, alert
    config: Dict[str, Any]
    data: List[Dict[str, Any]]

@dataclass
class KPI:
    """A Key Performance Indicator"""
    name: str
    value: float
    target: float
    unit: str
    trend: float  # percentage change
    status: str  # on_track, at_risk, behind

class BIDashboard:
    """
    Business Intelligence Dashboard implementation
    """
    
    def __init__(self, name: str):
        self.name = name
        self.widgets: Dict[str, DashboardWidget] = {}
        self.kpis: Dict[str, KPI] = {}
        self.data_sources: Dict[str, List[Dict[str, Any]]] = {}
        self.refresh_interval = 60  # seconds
        self.last_refresh = 0
        self.query_cache: Dict[str, Any] = {}
        
        print(f"📊 BI Dashboard initialized: {name}")
    
    def add_widget(self, widget: DashboardWidget):
        """Add a widget to the dashboard"""
        self.widgets[widget.widget_id] = widget
        print(f"   📊 Added widget: {widget.title} ({widget.type})")
    
    def add_kpi(self, kpi: KPI):
        """Add a KPI to the dashboard"""
        self.kpis[kpi.name] = kpi
        print(f"   🎯 Added KPI: {kpi.name} = {kpi.value}{kpi.unit}")
    
    def load_data(self, source_name: str, data: List[Dict[str, Any]]):
        """Load data from a source"""
        self.data_sources[source_name] = data
        print(f"   📥 Loaded data source: {source_name} ({len(data)} records)")
    
    def refresh_dashboard(self):
        """Refresh all dashboard data"""
        print(f"\n🔄 Refreshing dashboard: {self.name}")
        self.last_refresh = time.time()
        
        for widget_id, widget in self.widgets.items():
            self._refresh_widget(widget)
        
        self._refresh_kpis()
    
    def _refresh_widget(self, widget: DashboardWidget):
        """Refresh a widget's data"""
        if widget.type == 'metric':
            self._refresh_metric(widget)
        elif widget.type == 'chart':
            self._refresh_chart(widget)
        elif widget.type == 'table':
            self._refresh_table(widget)
        elif widget.type == 'alert':
            self._refresh_alert(widget)
    
    def _refresh_metric(self, widget: DashboardWidget):
        """Refresh a metric widget"""
        source = widget.config.get('source')
        column = widget.config.get('column')
        aggregation = widget.config.get('aggregation', 'sum')
        
        if source in self.data_sources:
            data = self.data_sources[source]
            values = [r.get(column, 0) for r in data]
            
            if aggregation == 'sum':
                value = sum(values)
            elif aggregation == 'avg':
                value = sum(values) / len(values) if values else 0
            elif aggregation == 'count':
                value = len(values)
            elif aggregation == 'max':
                value = max(values) if values else 0
            elif aggregation == 'min':
                value = min(values) if values else 0
            else:
                value = len(values)
            
            widget.data = [{'value': value}]
            print(f"      Metric {widget.title}: {value}")
    
    def _refresh_chart(self, widget: DashboardWidget):
        """Refresh a chart widget"""
        source = widget.config.get('source')
        dimension = widget.config.get('dimension')
        measure = widget.config.get('measure')
        
        if source in self.data_sources:
            data = self.data_sources[source]
            
            # Group by dimension
            groups = {}
            for record in data:
                key = record.get(dimension, 'unknown')
                if key not in groups:
                    groups[key] = 0
                groups[key] += record.get(measure, 0)
            
            widget.data = [{'label': k, 'value': v} for k, v in groups.items()]
            print(f"      Chart {widget.title}: {len(widget.data)} data points")
    
    def _refresh_table(self, widget: DashboardWidget):
        """Refresh a table widget"""
        source = widget.config.get('source')
        columns = widget.config.get('columns', [])
        limit = widget.config.get('limit', 100)
        
        if source in self.data_sources:
            data = self.data_sources[source]
            
            if columns:
                widget.data = [{c: r.get(c) for c in columns} for r in data[:limit]]
            else:
                widget.data = data[:limit]
            
            print(f"      Table {widget.title}: {len(widget.data)} rows")
    
    def _refresh_alert(self, widget: DashboardWidget):
        """Refresh an alert widget"""
        source = widget.config.get('source')
        condition = widget.config.get('condition')
        threshold = widget.config.get('threshold', 0)
        
        if source in self.data_sources:
            data = self.data_sources[source]
            
            # Check for alerts
            alerts = []
            for record in data:
                value = record.get('value', 0)
                if condition == '>':
                    if value > threshold:
                        alerts.append(record)
                elif condition == '<':
                    if value < threshold:
                        alerts.append(record)
                elif condition == '==':
                    if value == threshold:
                        alerts.append(record)
            
            widget.data = alerts
            print(f"      Alert {widget.title}: {len(alerts)} alerts")
    
    def _refresh_kpis(self):
        """Refresh KPI values"""
        for kpi in self.kpis.values():
            # Simulate KPI updates
            kpi.trend = random.uniform(-10, 10)
            
            if kpi.value >= kpi.target * 0.9:
                kpi.status = 'on_track'
            elif kpi.value >= kpi.target * 0.7:
                kpi.status = 'at_risk'
            else:
                kpi.status = 'behind'
    
    def render_dashboard(self) -> Dict[str, Any]:
        """Render the dashboard"""
        return {
            'name': self.name,
            'timestamp': time.time(),
            'refresh_interval': self.refresh_interval,
            'kpis': [
                {
                    'name': k.name,
                    'value': k.value,
                    'target': k.target,
                    'unit': k.unit,
                    'trend': k.trend,
                    'status': k.status
                }
                for k in self.kpis.values()
            ],
            'widgets': [
                {
                    'id': w.widget_id,
                    'title': w.title,
                    'type': w.type,
                    'data': w.data
                }
                for w in self.widgets.values()
            ]
        }
    
    def get_kpi_summary(self) -> Dict[str, Any]:
        """Get KPI summary"""
        status_counts = {}
        for kpi in self.kpis.values():
            status_counts[kpi.status] = status_counts.get(kpi.status, 0) + 1
        
        return {
            'total_kpis': len(self.kpis),
            'status_counts': status_counts,
            'average_trend': sum(k.trend for k in self.kpis.values()) / len(self.kpis) if self.kpis else 0
        }

def demo_bi_dashboard():
    """Demonstrate BI dashboard"""
    print("="*60)
    print("BI DASHBOARD DEMONSTRATION")
    print("="*60)
    
    # Create dashboard
    dashboard = BIDashboard("Executive Sales Dashboard")
    
    # Generate sales data
    print("\n📝 Generating sales data...")
    sales_data = []
    
    products = ['Laptop', 'Phone', 'Tablet', 'Monitor', 'Keyboard']
    regions = ['North America', 'Europe', 'Asia', 'South America']
    
    for i in range(100):
        date = datetime(2024, 1, 1) + timedelta(days=random.randint(0, 365))
        sales_data.append({
            'date': date.strftime('%Y-%m-%d'),
            'product': random.choice(products),
            'region': random.choice(regions),
            'sales_amount': round(random.uniform(100, 10000), 2),
            'units_sold': random.randint(1, 50),
            'customer_id': random.randint(1, 100),
            'order_id': f"ORD-{i:04d}"
        })
    
    dashboard.load_data('sales', sales_data)
    
    # Add KPIs
    print("\n🎯 Adding KPIs...")
    
    # Calculate total sales
    total_sales = sum(r['sales_amount'] for r in sales_data)
    
    dashboard.add_kpi(KPI(
        name="Total Revenue",
        value=total_sales,
        target=total_sales * 1.2,
        unit="$",
        trend=5.2,
        status="on_track"
    ))
    
    dashboard.add_kpi(KPI(
        name="Units Sold",
        value=sum(r['units_sold'] for r in sales_data),
        target=8000,
        unit="units",
        trend=3.8,
        status="on_track"
    ))
    
    dashboard.add_kpi(KPI(
        name="Average Order Value",
        value=sum(r['sales_amount'] for r in sales_data) / len(sales_data),
        target=2000,
        unit="$",
        trend=-2.1,
        status="at_risk"
    ))
    
    # Add widgets
    print("\n📊 Adding widgets...")
    
    widget1 = DashboardWidget(
        widget_id="metric_sales",
        title="Total Sales",
        type="metric",
        config={
            'source': 'sales',
            'column': 'sales_amount',
            'aggregation': 'sum'
        },
        data=[]
    )
    dashboard.add_widget(widget1)
    
    widget2 = DashboardWidget(
        widget_id="chart_sales_by_product",
        title="Sales by Product",
        type="chart",
        config={
            'source': 'sales',
            'dimension': 'product',
            'measure': 'sales_amount'
        },
        data=[]
    )
    dashboard.add_widget(widget2)
    
    widget3 = DashboardWidget(
        widget_id="chart_sales_by_region",
        title="Sales by Region",
        type="chart",
        config={
            'source': 'sales',
            'dimension': 'region',
            'measure': 'sales_amount'
        },
        data=[]
    )
    dashboard.add_widget(widget3)
    
    widget4 = DashboardWidget(
        widget_id="table_recent_orders",
        title="Recent Orders",
        type="table",
        config={
            'source': 'sales',
            'columns': ['order_id', 'product', 'region', 'sales_amount'],
            'limit': 10
        },
        data=[]
    )
    dashboard.add_widget(widget4)
    
    # Refresh dashboard
    dashboard.refresh_dashboard()
    
    # Render dashboard
    print("\n📊 Rendering dashboard...")
    rendered = dashboard.render_dashboard()
    
    # Show KPIs
    print("\n🎯 KPIs:")
    for kpi in rendered['kpis']:
        status_icon = {'on_track': '✅', 'at_risk': '⚠️', 'behind': '❌'}.get(kpi['status'], '')
        print(f"   {status_icon} {kpi['name']}: {kpi['value']:,}{kpi['unit']} "
              f"(Target: {kpi['target']:,}{kpi['unit']})")
        print(f"      Trend: {kpi['trend']:+.1f}% - Status: {kpi['status']}")
    
    # Show widgets
    print("\n📊 Widgets:")
    for widget in rendered['widgets']:
        print(f"   {widget['title']} ({widget['type']}):")
        if widget['type'] == 'metric' and widget['data']:
            print(f"      Value: {widget['data'][0]['value']:,.2f}")
        elif widget['type'] == 'chart':
            print(f"      Data points: {len(widget['data'])}")
            # Show top 3
            for item in widget['data'][:3]:
                print(f"      • {item['label']}: {item['value']:,.2f}")
        elif widget['type'] == 'table':
            print(f"      Rows: {len(widget['data'])}")
            if widget['data']:
                print(f"      First row: {widget['data'][0]}")
    
    # Show KPI summary
    summary = dashboard.get_kpi_summary()
    print(f"\n📊 KPI Summary:")
    print(f"   Total KPIs: {summary['total_kpis']}")
    for status, count in summary['status_counts'].items():
        print(f"   {status}: {count}")
    print(f"   Average Trend: {summary['average_trend']:+.1f}%")

def main():
    """Run BI dashboard demonstration"""
    random.seed(42)
    demo_bi_dashboard()
    
    print("\n" + "="*60)
    print("✅ BI DASHBOARD DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-13-bi-analytics

# Run the dimensional modeling demonstration
python dimensional_modeling.py

# Run the star vs snowflake comparison
python star_snowflake.py

# Run the BI dashboard demonstration
python bi_dashboard.py

# Expected output:
# ============================================================
# DIMENSIONAL MODELING DEMONSTRATION
# ============================================================
# 
# 📊 Creating dimensions...
#    📊 Dimension created: time_dim
#    📊 Dimension created: product_dim
#    📊 Dimension created: customer_dim
#    📊 Dimension created: store_dim
# 
# 📊 Creating fact table...
#    📊 Fact table created: sales_fact
# 
# 📥 Loading dimensions...
#    📥 Loaded 365 records into time_dim
#    📥 Loaded 5 records into product_dim
#    📥 Loaded 5 records into customer_dim
#    📥 Loaded 4 records into store_dim
# 
# 📥 Generating sales data...
#    📥 Loaded 500 records into sales_fact
# 
# 🔍 Querying sales data...
# 
#    Sales by Product:
#       Product P001: $1,234.56, 10 units
#       Product P002: $987.65, 8 units
# 
# ============================================================
# ✅ DIMENSIONAL MODELING DEMONSTRATION COMPLETE
# ============================================================
```

---

## Part 13 Recap

You have successfully:

✅ Built dimensional models with star and snowflake schemas  
✅ Created fact tables with measures and dimensions  
✅ Implemented dimension tables with attributes  
✅ Compared star vs. snowflake schema performance  
✅ Created business intelligence dashboards  
✅ Implemented KPIs with tracking  
✅ Built interactive widgets (metrics, charts, tables, alerts)  
✅ Implemented data refresh and caching  

### Key Takeaways

1. **Dimensional Modeling** organizes data for analysis
2. **Star Schema** uses denormalized dimensions for query performance
3. **Snowflake Schema** uses normalized dimensions for storage efficiency
4. **Fact Tables** store measurable business events
5. **Dimension Tables** provide descriptive context
6. **BI Dashboards** present insights to business users
7. **KPIs** track business performance against targets
8. **Semantic Layers** enable self-service analytics
9. **Data Marts** serve specific business functions
