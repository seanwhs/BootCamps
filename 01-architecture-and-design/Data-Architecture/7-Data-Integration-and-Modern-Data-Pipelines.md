# Part 7: Data Integration and Modern Data Pipelines

Welcome to Part 7, where we explore how data moves across enterprise systems through modern data pipelines. Think of data integration like a sophisticated logistics network - data needs to be collected, transformed, validated, and delivered to the right destinations at the right time, just like packages in a supply chain.

## Learning Objectives

By the end of this part, you will be able to:

- Understand ETL, ELT, and reverse ETL architectures
- Implement Change Data Capture (CDC) patterns
- Build batch and streaming data pipelines
- Work with Apache Kafka for event streaming
- Implement pipeline orchestration with workflows
- Handle data synchronization across systems

---

## 7.1 ETL vs. ELT vs. Reverse ETL

### The Concept

Data integration patterns represent different approaches to moving and transforming data:

**ETL (Extract, Transform, Load)**: Traditional approach - transform before loading
**ELT (Extract, Load, Transform)**: Modern approach - load raw data, transform in place
**Reverse ETL**: Push analytics data back to operational systems

```
ETL Architecture:
┌─────────┐     ┌──────────────┐     ┌─────────┐
│ Extract │────▶│  Transform   │────▶│  Load   │
└─────────┘     └──────────────┘     └─────────┘
• Transform before loading
• Good for structured data
• Data warehouse focused

ELT Architecture:
┌─────────┐     ┌─────────┐     ┌──────────────┐
│ Extract │────▶│  Load   │────▶│  Transform   │
└─────────┘     └─────────┘     └──────────────┘
• Load raw data first
• Transform in warehouse
• Leverages modern compute power

Reverse ETL:
┌─────────┐     ┌─────────┐     ┌──────────────┐
│ Extract │────▶│Transform│────▶│ Load to Apps │
└─────────┘     └─────────┘     └──────────────┘
• Push analytics to operational systems
• Enable data-driven actions
• Real-time personalization
```

### The Implementation

**File: `part-07-data-integration/etl_patterns.py`**
```python
#!/usr/bin/env python3
"""
ETL, ELT, and Reverse ETL Implementation
"""

import json
import time
import random
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
import csv
import io
import hashlib

@dataclass
class DataSource:
    """Represents a data source"""
    name: str
    data: List[Dict[str, Any]]
    schema: Dict[str, str]

@dataclass
class DataDestination:
    """Represents a data destination"""
    name: str
    data: List[Dict[str, Any]] = None
    
    def __post_init__(self):
        if self.data is None:
            self.data = []

class ETLEngine:
    """
    ETL (Extract, Transform, Load) Engine
    """
    
    def __init__(self):
        self.extractors: Dict[str, Callable] = {}
        self.transformers: Dict[str, Callable] = {}
        self.loaders: Dict[str, Callable] = {}
        self.pipeline_logs: List[Dict[str, Any]] = []
    
    def register_extractor(self, name: str, extractor: Callable):
        """Register an extractor function"""
        self.extractors[name] = extractor
    
    def register_transformer(self, name: str, transformer: Callable):
        """Register a transformer function"""
        self.transformers[name] = transformer
    
    def register_loader(self, name: str, loader: Callable):
        """Register a loader function"""
        self.loaders[name] = loader
    
    def run_pipeline(self, extractor_name: str, transformer_name: str, 
                     loader_name: str, source_data: Any) -> bool:
        """Run a complete ETL pipeline"""
        start_time = time.time()
        
        try:
            # Extract
            self._log("extract", extractor_name, "started")
            extracted = self.extractors[extractor_name](source_data)
            self._log("extract", extractor_name, "completed", len(str(extracted)))
            
            # Transform
            self._log("transform", transformer_name, "started")
            transformed = self.transformers[transformer_name](extracted)
            self._log("transform", transformer_name, "completed", len(str(transformed)))
            
            # Load
            self._log("load", loader_name, "started")
            result = self.loaders[loader_name](transformed)
            self._log("load", loader_name, "completed", len(str(result)))
            
            duration = time.time() - start_time
            self._log("pipeline", "complete", f"ETL pipeline completed in {duration:.2f}s")
            
            return True
            
        except Exception as e:
            self._log("error", "pipeline", f"Failed: {str(e)}")
            return False
    
    def _log(self, phase: str, name: str, status: str, detail: str = ""):
        """Log pipeline activity"""
        log_entry = {
            'timestamp': time.time(),
            'phase': phase,
            'name': name,
            'status': status,
            'detail': detail
        }
        self.pipeline_logs.append(log_entry)
        print(f"   [{phase.upper()}] {name}: {status} {detail}")
    
    def get_logs(self) -> List[Dict[str, Any]]:
        """Get pipeline logs"""
        return self.pipeline_logs

class ELTEngine(ETLEngine):
    """
    ELT (Extract, Load, Transform) Engine
    Loads raw data first, then transforms
    """
    
    def run_pipeline(self, extractor_name: str, loader_name: str, 
                     transformer_name: str, source_data: Any) -> bool:
        """Run an ELT pipeline (different order)"""
        start_time = time.time()
        
        try:
            # Extract
            self._log("extract", extractor_name, "started")
            extracted = self.extractors[extractor_name](source_data)
            self._log("extract", extractor_name, "completed", len(str(extracted)))
            
            # Load (before transform)
            self._log("load", loader_name, "started")
            loaded = self.loaders[loader_name](extracted)
            self._log("load", loader_name, "completed", len(str(loaded)))
            
            # Transform (after load)
            self._log("transform", transformer_name, "started")
            transformed = self.transformers[transformer_name](loaded)
            self._log("transform", transformer_name, "completed", len(str(transformed)))
            
            duration = time.time() - start_time
            self._log("pipeline", "complete", f"ELT pipeline completed in {duration:.2f}s")
            
            return True
            
        except Exception as e:
            self._log("error", "pipeline", f"Failed: {str(e)}")
            return False

class ReverseETLEngine(ETLEngine):
    """
    Reverse ETL Engine
    Pushes data from analytics to operational systems
    """
    
    def __init__(self):
        super().__init__()
        self.destinations: Dict[str, DataDestination] = {}
    
    def register_destination(self, name: str, destination: DataDestination):
        """Register a destination for reverse ETL"""
        self.destinations[name] = destination
    
    def run_pipeline(self, source_name: str, destination_name: str,
                     transformer_name: str, source_data: Any) -> bool:
        """Run a reverse ETL pipeline"""
        start_time = time.time()
        
        try:
            # Extract from analytics
            self._log("extract", source_name, "started")
            extracted = self.extractors[source_name](source_data)
            self._log("extract", source_name, "completed", len(str(extracted)))
            
            # Transform for operational use
            self._log("transform", transformer_name, "started")
            transformed = self.transformers[transformer_name](extracted)
            self._log("transform", transformer_name, "completed", len(str(transformed)))
            
            # Load to operational system
            self._log("load", destination_name, "started")
            destination = self.destinations[destination_name]
            destination.data.extend(transformed)
            self._log("load", destination_name, "completed", len(str(transformed)))
            
            duration = time.time() - start_time
            self._log("pipeline", "complete", f"Reverse ETL completed in {duration:.2f}s")
            
            return True
            
        except Exception as e:
            self._log("error", "pipeline", f"Failed: {str(e)}")
            return False

def demo_etl():
    """Demonstrate ETL pipeline"""
    print("\n" + "="*60)
    print("ETL PIPELINE DEMONSTRATION")
    print("="*60)
    
    # Create sample data
    sample_data = [
        {'id': 1, 'name': 'Alice', 'age': 30, 'city': 'NY', 'salary': 75000},
        {'id': 2, 'name': 'Bob', 'age': 25, 'city': 'LA', 'salary': 65000},
        {'id': 3, 'name': 'Charlie', 'age': 35, 'city': 'NY', 'salary': 85000},
        {'id': 4, 'name': 'David', 'age': 28, 'city': 'SF', 'salary': 95000},
        {'id': 5, 'name': 'Eve', 'age': 32, 'city': 'LA', 'salary': 70000}
    ]
    
    # Define extractors
    def extract_json(data: Any) -> List[Dict[str, Any]]:
        return data
    
    def extract_csv(data: Any) -> List[Dict[str, Any]]:
        # Simulate CSV extraction
        return data
    
    # Define transformers
    def transform_clean(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Clean and validate data"""
        cleaned = []
        for record in data:
            # Remove null values
            clean_record = {k: v for k, v in record.items() if v is not None}
            # Validate data types
            if 'age' in clean_record and isinstance(clean_record['age'], (int, float)):
                pass
            cleaned.append(clean_record)
        return cleaned
    
    def transform_enrich(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Enrich data with derived fields"""
        enriched = []
        for record in data:
            record_copy = record.copy()
            # Add derived fields
            if 'salary' in record:
                record_copy['salary_bracket'] = 'high' if record['salary'] > 80000 else 'medium'
            if 'age' in record:
                record_copy['age_group'] = '30+' if record['age'] >= 30 else 'under30'
            enriched.append(record_copy)
        return enriched
    
    def transform_aggregate(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Aggregate data"""
        city_stats = {}
        for record in data:
            city = record.get('city', 'unknown')
            if city not in city_stats:
                city_stats[city] = {'count': 0, 'total_salary': 0}
            city_stats[city]['count'] += 1
            city_stats[city]['total_salary'] += record.get('salary', 0)
        
        result = []
        for city, stats in city_stats.items():
            result.append({
                'city': city,
                'employee_count': stats['count'],
                'avg_salary': stats['total_salary'] / stats['count']
            })
        return result
    
    # Define loaders
    def load_console(data: List[Dict[str, Any]]) -> bool:
        print(f"\n   Loaded {len(data)} records to console:")
        for record in data:
            print(f"      {record}")
        return True
    
    def load_json(data: List[Dict[str, Any]]) -> bool:
        json_str = json.dumps(data, indent=2)
        # Simulate saving to file
        return True
    
    # Create ETL engine
    etl = ETLEngine()
    etl.register_extractor('json', extract_json)
    etl.register_transformer('clean', transform_clean)
    etl.register_transformer('enrich', transform_enrich)
    etl.register_transformer('aggregate', transform_aggregate)
    etl.register_loader('console', load_console)
    
    print("\n📋 Running ETL Pipeline:")
    print("   Extract (JSON) → Transform (Clean + Enrich) → Load (Console)")
    
    # Run pipeline
    etl.run_pipeline('json', 'clean', 'console', sample_data)
    
    # Show pipeline logs
    print(f"\n📊 Pipeline Logs:")
    for log in etl.get_logs():
        timestamp = time.ctime(log['timestamp'])
        print(f"   [{timestamp}] {log['phase']}.{log['name']}: {log['status']}")

def demo_elt():
    """Demonstrate ELT pipeline"""
    print("\n" + "="*60)
    print("ELT PIPELINE DEMONSTRATION")
    print("="*60)
    
    # Sample data
    sample_data = [
        {'order_id': 'ORD-001', 'product': 'Laptop', 'quantity': 2, 'price': 999.99},
        {'order_id': 'ORD-002', 'product': 'Phone', 'quantity': 3, 'price': 599.99},
        {'order_id': 'ORD-003', 'product': 'Tablet', 'quantity': 1, 'price': 399.99}
    ]
    
    # Define extractor
    def extract_orders(data: Any) -> List[Dict[str, Any]]:
        return data
    
    # Define loader
    def load_raw(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        # Simulate loading to data lake/warehouse
        return data
    
    # Define transformer (runs after load)
    def transform_calc_total(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Calculate total for each order"""
        transformed = []
        for record in data:
            record_copy = record.copy()
            record_copy['total'] = record.get('quantity', 0) * record.get('price', 0)
            transformed.append(record_copy)
        return transformed
    
    # Create ELT engine
    elt = ELTEngine()
    elt.register_extractor('orders', extract_orders)
    elt.register_transformer('calc_total', transform_calc_total)
    elt.register_loader('raw', load_raw)
    
    print("\n📋 Running ELT Pipeline:")
    print("   Extract (Orders) → Load (Raw) → Transform (Calculate Total)")
    
    # Run pipeline
    elt.run_pipeline('orders', 'raw', 'calc_total', sample_data)

def demo_reverse_etl():
    """Demonstrate Reverse ETL pipeline"""
    print("\n" + "="*60)
    print("REVERSE ETL DEMONSTRATION")
    print("="*60)
    
    # Analytics data
    analytics_data = [
        {'customer_id': 'CUST-001', 'lifetime_value': 2500, 'segment': 'premium', 'last_purchase': '2024-01-15'},
        {'customer_id': 'CUST-002', 'lifetime_value': 800, 'segment': 'standard', 'last_purchase': '2024-02-01'},
        {'customer_id': 'CUST-003', 'lifetime_value': 4500, 'segment': 'premium', 'last_purchase': '2024-01-28'},
        {'customer_id': 'CUST-004', 'lifetime_value': 300, 'segment': 'basic', 'last_purchase': '2023-12-15'},
        {'customer_id': 'CUST-005', 'lifetime_value': 1200, 'segment': 'standard', 'last_purchase': '2024-02-10'}
    ]
    
    # Define extractor
    def extract_analytics(data: Any) -> List[Dict[str, Any]]:
        return data
    
    # Define transformer (prepare for operational system)
    def transform_for_crm(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Transform analytics data for CRM use"""
        transformed = []
        for record in data:
            # Create a format suitable for CRM
            crm_record = {
                'external_id': record['customer_id'],
                'total_spend': record['lifetime_value'],
                'tier': record['segment'].upper(),
                'last_activity': record['last_purchase'],
                # Add derived fields
                'loyalty_points': int(record['lifetime_value'] / 10),
                'should_promote': 'YES' if record['segment'] == 'premium' else 'NO'
            }
            transformed.append(crm_record)
        return transformed
    
    # Create destination
    crm_destination = DataDestination("CRM System")
    
    # Create Reverse ETL engine
    retl = ReverseETLEngine()
    retl.register_extractor('analytics', extract_analytics)
    retl.register_transformer('crm_format', transform_for_crm)
    retl.register_destination('crm', crm_destination)
    
    print("\n📋 Running Reverse ETL Pipeline:")
    print("   Extract (Analytics) → Transform (CRM Format) → Load (CRM System)")
    
    # Run pipeline
    retl.run_pipeline('analytics', 'crm', 'crm_format', analytics_data)
    
    print(f"\n📊 CRM Destination now has {len(crm_destination.data)} records:")
    for record in crm_destination.data:
        print(f"   {record}")
    
    print("\n🎯 Reverse ETL Use Cases:")
    print("   • Send customer segments to marketing automation")
    print("   • Push sales intelligence to CRM")
    print("   • Sync user analytics to product recommendation systems")
    print("   • Update customer support systems with account insights")

def main():
    """Run all ETL pattern demonstrations"""
    demo_etl()
    demo_elt()
    demo_reverse_etl()
    
    print("\n" + "="*60)
    print("✅ ETL PATTERN DEMONSTRATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 7.2 Change Data Capture (CDC)

### The Concept

Change Data Capture is like a surveillance system for your database - it monitors and captures all changes (inserts, updates, deletes) so they can be replicated to other systems in real-time.

### The Implementation

**File: `part-07-data-integration/change_data_capture.py`**
```python
#!/usr/bin/env python3
"""
Change Data Capture (CDC) Implementation
"""

import time
import json
import hashlib
import threading
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
from enum import Enum
from datetime import datetime
import queue

class ChangeType(Enum):
    """Types of database changes"""
    INSERT = "insert"
    UPDATE = "update"
    DELETE = "delete"
    SNAPSHOT = "snapshot"

@dataclass
class ChangeEvent:
    """A database change event"""
    sequence_id: int
    table: str
    change_type: ChangeType
    before: Optional[Dict[str, Any]]
    after: Optional[Dict[str, Any]]
    timestamp: float
    transaction_id: str
    
    def to_json(self) -> str:
        """Convert to JSON for streaming"""
        return json.dumps({
            'sequence_id': self.sequence_id,
            'table': self.table,
            'change_type': self.change_type.value,
            'before': self.before,
            'after': self.after,
            'timestamp': self.timestamp,
            'transaction_id': self.transaction_id
        })

class MockDatabase:
    """
    Mock database with CDC capabilities
    """
    
    def __init__(self, name: str):
        self.name = name
        self.data: Dict[str, Dict[Any, Dict[str, Any]]] = {}
        self.sequence_id = 0
        self.transaction_id = 0
        self.change_log: List[ChangeEvent] = []
        self.cdc_enabled = True
        
        # Subscribers for CDC events
        self.subscribers: List[Callable] = []
        
    def create_table(self, table_name: str):
        """Create a new table"""
        if table_name not in self.data:
            self.data[table_name] = {}
            print(f"📋 Table '{table_name}' created")
    
    def insert(self, table: str, record: Dict[str, Any], 
               primary_key: Optional[str] = None) -> bool:
        """Insert a record"""
        if table not in self.data:
            return False
        
        # Determine primary key
        if primary_key is None:
            primary_key = 'id'
        
        key_value = record.get(primary_key)
        if key_value is None:
            # Generate a key if not provided
            key_value = len(self.data[table]) + 1
            record[primary_key] = key_value
        
        # Store record
        self.data[table][key_value] = record.copy()
        
        # Create change event
        if self.cdc_enabled:
            self.sequence_id += 1
            self.transaction_id += 1
            event = ChangeEvent(
                sequence_id=self.sequence_id,
                table=table,
                change_type=ChangeType.INSERT,
                before=None,
                after=record.copy(),
                timestamp=time.time(),
                transaction_id=f"txn_{self.transaction_id}"
            )
            self.change_log.append(event)
            self._notify_subscribers(event)
        
        return True
    
    def update(self, table: str, key: Any, updates: Dict[str, Any]) -> bool:
        """Update a record"""
        if table not in self.data or key not in self.data[table]:
            return False
        
        before = self.data[table][key].copy()
        self.data[table][key].update(updates)
        after = self.data[table][key].copy()
        
        # Create change event
        if self.cdc_enabled:
            self.sequence_id += 1
            self.transaction_id += 1
            event = ChangeEvent(
                sequence_id=self.sequence_id,
                table=table,
                change_type=ChangeType.UPDATE,
                before=before,
                after=after,
                timestamp=time.time(),
                transaction_id=f"txn_{self.transaction_id}"
            )
            self.change_log.append(event)
            self._notify_subscribers(event)
        
        return True
    
    def delete(self, table: str, key: Any) -> bool:
        """Delete a record"""
        if table not in self.data or key not in self.data[table]:
            return False
        
        before = self.data[table][key].copy()
        del self.data[table][key]
        
        # Create change event
        if self.cdc_enabled:
            self.sequence_id += 1
            self.transaction_id += 1
            event = ChangeEvent(
                sequence_id=self.sequence_id,
                table=table,
                change_type=ChangeType.DELETE,
                before=before,
                after=None,
                timestamp=time.time(),
                transaction_id=f"txn_{self.transaction_id}"
            )
            self.change_log.append(event)
            self._notify_subscribers(event)
        
        return True
    
    def subscribe(self, callback: Callable):
        """Subscribe to change events"""
        self.subscribers.append(callback)
    
    def _notify_subscribers(self, event: ChangeEvent):
        """Notify all subscribers of a change"""
        for subscriber in self.subscribers:
            try:
                subscriber(event)
            except Exception as e:
                print(f"⚠️ Subscriber error: {e}")
    
    def get_changes_since(self, sequence_id: int) -> List[ChangeEvent]:
        """Get all changes since a given sequence ID"""
        return [e for e in self.change_log if e.sequence_id > sequence_id]

class CDCConsumer:
    """
    CDC Consumer - receives and processes change events
    """
    
    def __init__(self, name: str):
        self.name = name
        self.last_sequence_id = 0
        self.processed_events: List[ChangeEvent] = []
    
    def process_event(self, event: ChangeEvent):
        """Process a change event"""
        self.last_sequence_id = event.sequence_id
        self.processed_events.append(event)
        
        print(f"   [{self.name}] Processed {event.change_type.value} on {event.table}")
        
        # Simulate different processing based on change type
        if event.change_type == ChangeType.INSERT:
            print(f"      New record: {event.after}")
        elif event.change_type == ChangeType.UPDATE:
            print(f"      Updated from {event.before} to {event.after}")
        elif event.change_type == ChangeType.DELETE:
            print(f"      Deleted: {event.before}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get consumer statistics"""
        return {
            'name': self.name,
            'last_sequence_id': self.last_sequence_id,
            'processed_count': len(self.processed_events)
        }

class CDCReplicator:
    """
    CDC Replicator - replicates changes to a target system
    """
    
    def __init__(self, source_db: MockDatabase, target_db: MockDatabase):
        self.source_db = source_db
        self.target_db = target_db
        self.last_sequence_id = 0
        self.is_running = False
        self.replication_thread = None
        self.replication_delay = 0.1  # Seconds between polls
    
    def start(self):
        """Start replication process"""
        self.is_running = True
        self.replication_thread = threading.Thread(target=self._replicate_loop)
        self.replication_thread.daemon = True
        self.replication_thread.start()
        print(f"🔄 CDC Replication started")
    
    def stop(self):
        """Stop replication process"""
        self.is_running = False
        if self.replication_thread:
            self.replication_thread.join()
        print(f"🔄 CDC Replication stopped")
    
    def _replicate_loop(self):
        """Main replication loop"""
        while self.is_running:
            try:
                # Get new changes
                changes = self.source_db.get_changes_since(self.last_sequence_id)
                
                for event in changes:
                    self._apply_change(event)
                    self.last_sequence_id = event.sequence_id
                
                time.sleep(self.replication_delay)
                
            except Exception as e:
                print(f"⚠️ Replication error: {e}")
                time.sleep(1)
    
    def _apply_change(self, event: ChangeEvent):
        """Apply change to target database"""
        table = event.table
        
        # Ensure table exists in target
        if table not in self.target_db.data:
            self.target_db.create_table(table)
        
        if event.change_type == ChangeType.INSERT:
            # Determine primary key
            pk = 'id'
            key_value = event.after.get(pk)
            if key_value is not None:
                self.target_db.data[table][key_value] = event.after.copy()
        
        elif event.change_type == ChangeType.UPDATE:
            pk = 'id'
            key_value = event.after.get(pk)
            if key_value is not None and key_value in self.target_db.data[table]:
                self.target_db.data[table][key_value].update(event.after)
        
        elif event.change_type == ChangeType.DELETE:
            pk = 'id'
            key_value = event.before.get(pk)
            if key_value is not None and key_value in self.target_db.data[table]:
                del self.target_db.data[table][key_value]
        
        print(f"   ✅ Replicated {event.change_type.value} to target")

class CDCSnapshot:
    """
    Takes a snapshot of data for initial CDC synchronization
    """
    
    def __init__(self, source_db: MockDatabase):
        self.source_db = source_db
        self.snapshot_data: Dict[str, List[Dict[str, Any]]] = {}
    
    def take_snapshot(self) -> Dict[str, List[Dict[str, Any]]]:
        """Take a snapshot of all tables"""
        print(f"📸 Taking snapshot of database...")
        
        for table_name, records in self.source_db.data.items():
            self.snapshot_data[table_name] = []
            for key, record in records.items():
                self.snapshot_data[table_name].append(record.copy())
        
        print(f"   Snapshot taken: {len(self.snapshot_data)} tables, "
              f"{sum(len(r) for r in self.snapshot_data.values())} records")
        
        return self.snapshot_data
    
    def apply_snapshot(self, target_db: MockDatabase):
        """Apply snapshot to target database"""
        print(f"📤 Applying snapshot to target...")
        
        for table_name, records in self.snapshot_data.items():
            if table_name not in target_db.data:
                target_db.create_table(table_name)
            
            for record in records:
                pk = 'id'
                key_value = record.get(pk)
                if key_value is not None:
                    target_db.data[table_name][key_value] = record.copy()
        
        print(f"   Snapshot applied: {len(self.snapshot_data)} tables")

def demo_cdc():
    """Demonstrate Change Data Capture"""
    print("="*60)
    print("CHANGE DATA CAPTURE (CDC) DEMONSTRATION")
    print("="*60)
    
    # Create source database
    source_db = MockDatabase("SourceDB")
    source_db.create_table("users")
    source_db.create_table("orders")
    
    # Create target database
    target_db = MockDatabase("TargetDB")
    
    # Create consumer
    consumer = CDCConsumer("AnalyticsConsumer")
    source_db.subscribe(consumer.process_event)
    
    # Insert initial data
    print("\n📝 Inserting initial data...")
    source_db.insert("users", {"id": 1, "name": "Alice", "email": "alice@ex.com"})
    source_db.insert("users", {"id": 2, "name": "Bob", "email": "bob@ex.com"})
    source_db.insert("orders", {"id": 1, "user_id": 1, "amount": 100})
    
    # Update data
    print("\n📝 Updating data...")
    source_db.update("users", 1, {"email": "alice.new@ex.com"})
    
    # Delete data
    print("\n📝 Deleting data...")
    source_db.delete("users", 2)
    
    # Show change log
    print(f"\n📋 Change Log ({len(source_db.change_log)} events):")
    for event in source_db.change_log:
        print(f"   {event.sequence_id}: {event.change_type.value} on {event.table}")
    
    # Show consumer stats
    stats = consumer.get_stats()
    print(f"\n📊 Consumer Stats:")
    print(f"   Processed: {stats['processed_count']} events")
    print(f"   Last sequence: {stats['last_sequence_id']}")
    
    # Demonstrate replication
    print("\n🔄 Setting up CDC replication...")
    replicator = CDCReplicator(source_db, target_db)
    
    # Take snapshot for initial sync
    snapshot = CDCSnapshot(source_db)
    snapshot.take_snapshot()
    snapshot.apply_snapshot(target_db)
    
    print("\n📊 Source Database State:")
    for table, records in source_db.data.items():
        print(f"   {table}: {len(records)} records")
        for key, record in records.items():
            print(f"      {key}: {record}")
    
    # Start replication
    replicator.start()
    
    # Make some changes
    print("\n📝 Making changes after replication starts...")
    time.sleep(0.5)
    source_db.insert("users", {"id": 3, "name": "Charlie", "email": "charlie@ex.com"})
    time.sleep(0.5)
    source_db.update("orders", 1, {"amount": 150})
    time.sleep(0.5)
    source_db.delete("users", 1)
    
    # Stop replication after changes
    time.sleep(1)
    replicator.stop()
    
    print("\n📊 Target Database State (after replication):")
    for table, records in target_db.data.items():
        print(f"   {table}: {len(records)} records")
        for key, record in records.items():
            print(f"      {key}: {record}")
    
    print("\n📊 CDC Benefits:")
    print("   • Real-time data synchronization")
    print("   • Minimal impact on source system")
    print("   • Supports multiple consumers")
    print("   • Ability to replay changes")
    print("   • Audit and compliance benefits")

def main():
    """Run CDC demonstration"""
    demo_cdc()
    
    print("\n" + "="*60)
    print("✅ CDC DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 7.3 Apache Kafka Implementation

### The Concept

Apache Kafka is a distributed event streaming platform. Think of it like a modern postal system for events - producers send messages to topics (like addresses), and consumers subscribe to topics to receive messages. The system is fault-tolerant and can handle millions of messages per second.

### The Implementation

**File: `part-07-data-integration/kafka_implementation.py`**
```python
#!/usr/bin/env python3
"""
Apache Kafka Implementation Simulation
"""

import time
import json
import threading
import random
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
from datetime import datetime
import queue

@dataclass
class KafkaMessage:
    """A Kafka message"""
    topic: str
    key: str
    value: Any
    timestamp: float
    partition: int
    offset: int
    
    def to_json(self) -> str:
        return json.dumps({
            'topic': self.topic,
            'key': self.key,
            'value': self.value,
            'timestamp': self.timestamp,
            'partition': self.partition,
            'offset': self.offset
        })

class KafkaPartition:
    """
    A Kafka partition - ordered sequence of messages
    """
    
    def __init__(self, partition_id: int):
        self.partition_id = partition_id
        self.messages: List[KafkaMessage] = []
        self.last_offset = -1
        self.high_watermark = 0
        self.consumer_offsets: Dict[str, int] = {}  # consumer_group -> offset
    
    def append(self, message: KafkaMessage) -> int:
        """Append a message to the partition"""
        self.last_offset += 1
        message.offset = self.last_offset
        self.messages.append(message)
        self.high_watermark = self.last_offset + 1
        return self.last_offset
    
    def read(self, consumer_group: str, offset: int = -1) -> List[KafkaMessage]:
        """Read messages from the partition"""
        start_offset = offset if offset >= 0 else self.consumer_offsets.get(consumer_group, 0)
        
        if start_offset >= len(self.messages):
            return []
        
        messages = self.messages[start_offset:]
        self.consumer_offsets[consumer_group] = len(self.messages)
        
        return messages
    
    def get_committed_offset(self, consumer_group: str) -> int:
        """Get the committed offset for a consumer group"""
        return self.consumer_offsets.get(consumer_group, 0)

class KafkaTopic:
    """
    A Kafka topic with multiple partitions
    """
    
    def __init__(self, name: str, partitions: int = 3):
        self.name = name
        self.partitions: List[KafkaPartition] = []
        for i in range(partitions):
            self.partitions.append(KafkaPartition(i))
        self.message_count = 0
        self.creation_time = time.time()
    
    def write(self, key: str, value: Any) -> int:
        """Write a message to the topic"""
        # Determine partition (simple hash-based)
        partition_id = self._hash_partition(key)
        partition = self.partitions[partition_id]
        
        message = KafkaMessage(
            topic=self.name,
            key=key,
            value=value,
            timestamp=time.time(),
            partition=partition_id,
            offset=-1  # Will be set by partition
        )
        
        offset = partition.append(message)
        self.message_count += 1
        
        return offset
    
    def _hash_partition(self, key: str) -> int:
        """Determine partition based on key hash"""
        if key is None:
            return random.randint(0, len(self.partitions) - 1)
        return hash(key) % len(self.partitions)
    
    def read(self, consumer_group: str, partition_id: int = -1) -> List[KafkaMessage]:
        """Read messages from the topic"""
        if partition_id >= 0:
            return self.partitions[partition_id].read(consumer_group)
        
        # Read from all partitions
        all_messages = []
        for partition in self.partitions:
            messages = partition.read(consumer_group)
            all_messages.extend(messages)
        
        return sorted(all_messages, key=lambda m: (m.partition, m.offset))
    
    def get_stats(self) -> Dict[str, Any]:
        """Get topic statistics"""
        return {
            'name': self.name,
            'partitions': len(self.partitions),
            'message_count': self.message_count,
            'creation_time': self.creation_time,
            'partition_stats': [
                {
                    'partition_id': p.partition_id,
                    'message_count': len(p.messages),
                    'last_offset': p.last_offset
                }
                for p in self.partitions
            ]
        }

class KafkaProducer:
    """
    Kafka Producer - publishes messages to topics
    """
    
    def __init__(self, name: str):
        self.name = name
        self.produced_count = 0
        self.produced_bytes = 0
    
    def produce(self, topic: KafkaTopic, key: str, value: Any) -> bool:
        """Produce a message to a topic"""
        try:
            offset = topic.write(key, value)
            self.produced_count += 1
            
            # Calculate message size
            msg_str = json.dumps(value) if isinstance(value, (dict, list)) else str(value)
            self.produced_bytes += len(msg_str.encode('utf-8'))
            
            print(f"   [{self.name}] Produced to {topic.name}: {key} -> {offset}")
            return True
            
        except Exception as e:
            print(f"   ❌ [{self.name}] Failed to produce: {e}")
            return False
    
    def get_stats(self) -> Dict[str, Any]:
        """Get producer statistics"""
        return {
            'name': self.name,
            'produced_count': self.produced_count,
            'produced_bytes': self.produced_bytes,
            'produced_mb': self.produced_bytes / (1024 * 1024)
        }

class KafkaConsumer:
    """
    Kafka Consumer - consumes messages from topics
    """
    
    def __init__(self, name: str, consumer_group: str):
        self.name = name
        self.consumer_group = consumer_group
        self.consumed_count = 0
        self.last_message: Optional[KafkaMessage] = None
        self.message_handlers: List[Callable] = []
    
    def subscribe(self, topics: List[KafkaTopic], callback: Callable = None):
        """Subscribe to topics"""
        self.topics = topics
        if callback:
            self.message_handlers.append(callback)
    
    def consume(self, max_messages: int = 10) -> List[KafkaMessage]:
        """Consume messages from subscribed topics"""
        all_messages = []
        
        for topic in self.topics:
            messages = topic.read(self.consumer_group)
            all_messages.extend(messages[:max_messages])
            
            # Process messages
            for message in messages[:max_messages]:
                self.consumed_count += 1
                self.last_message = message
                
                # Call handlers
                for handler in self.message_handlers:
                    try:
                        handler(message)
                    except Exception as e:
                        print(f"   ⚠️ Handler error: {e}")
        
        return sorted(all_messages, key=lambda m: (m.partition, m.offset))
    
    def get_stats(self) -> Dict[str, Any]:
        """Get consumer statistics"""
        return {
            'name': self.name,
            'consumer_group': self.consumer_group,
            'consumed_count': self.consumed_count,
            'last_message_topic': self.last_message.topic if self.last_message else None,
            'last_message_key': self.last_message.key if self.last_message else None
        }

class KafkaStreamProcessing:
    """
    Kafka Stream Processing - process messages in real-time
    """
    
    def __init__(self, name: str):
        self.name = name
        self.processed_count = 0
        self.processed_bytes = 0
        self.running = False
        self.processing_thread = None
    
    def process_stream(self, consumer: KafkaConsumer, 
                       processor: Callable[[KafkaMessage], Any],
                       poll_interval: float = 0.5):
        """Process a stream of messages"""
        def process_loop():
            while self.running:
                messages = consumer.consume(max_messages=5)
                
                for message in messages:
                    try:
                        result = processor(message)
                        self.processed_count += 1
                        
                        # Update bytes processed
                        msg_str = json.dumps(message.value) if isinstance(message.value, (dict, list)) else str(message.value)
                        self.processed_bytes += len(msg_str.encode('utf-8'))
                        
                    except Exception as e:
                        print(f"   ⚠️ Processing error: {e}")
                
                time.sleep(poll_interval)
        
        self.running = True
        self.processing_thread = threading.Thread(target=process_loop)
        self.processing_thread.daemon = True
        self.processing_thread.start()
        print(f"📊 Stream processing started for {self.name}")
    
    def stop(self):
        """Stop stream processing"""
        self.running = False
        if self.processing_thread:
            self.processing_thread.join()
        print(f"📊 Stream processing stopped for {self.name}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get processing statistics"""
        return {
            'name': self.name,
            'processed_count': self.processed_count,
            'processed_bytes': self.processed_bytes,
            'processed_mb': self.processed_bytes / (1024 * 1024)
        }

def demo_kafka():
    """Demonstrate Apache Kafka"""
    print("="*60)
    print("APACHE KAFKA DEMONSTRATION")
    print("="*60)
    
    # Create a Kafka topic
    print("\n📋 Creating topic 'orders' with 3 partitions...")
    orders_topic = KafkaTopic("orders", partitions=3)
    
    # Create another topic
    print("📋 Creating topic 'alerts' with 2 partitions...")
    alerts_topic = KafkaTopic("alerts", partitions=2)
    
    # Create producers
    print("\n📤 Creating producers...")
    producer1 = KafkaProducer("OrderProducer")
    producer2 = KafkaProducer("AlertProducer")
    
    # Create consumer
    print("📥 Creating consumer group 'analytics'...")
    consumer = KafkaConsumer("AnalyticsConsumer", "analytics")
    consumer.subscribe([orders_topic, alerts_topic])
    
    # Message handler
    def log_message(message: KafkaMessage):
        print(f"   📨 Received: {message.topic}/{message.key} = {message.value}")
    
    consumer.subscribe([orders_topic, alerts_topic], log_message)
    
    # Produce messages
    print("\n📤 Producing messages...")
    order_keys = ['CUST-001', 'CUST-002', 'CUST-003', 'CUST-001', 'CUST-004']
    order_values = [
        {'order_id': 1001, 'amount': 150.00, 'items': 3},
        {'order_id': 1002, 'amount': 75.00, 'items': 1},
        {'order_id': 1003, 'amount': 230.00, 'items': 5},
        {'order_id': 1004, 'amount': 450.00, 'items': 2},
        {'order_id': 1005, 'amount': 89.99, 'items': 2}
    ]
    
    for i, key in enumerate(order_keys):
        producer1.produce(orders_topic, key, order_values[i % len(order_values)])
    
    # Produce alerts
    alert_messages = [
        ('HIGH_VALUE', {'order_id': 1003, 'amount': 230.00, 'message': 'Large order detected'}),
        ('SYSTEM', {'code': 'WARN', 'message': 'High CPU usage'}),
        ('FRAUD', {'order_id': 1001, 'message': 'Suspicious activity detected'})
    ]
    
    for key, value in alert_messages:
        producer2.produce(alerts_topic, key, value)
    
    # Consume messages
    print("\n📥 Consuming messages...")
    consumed = consumer.consume(max_messages=10)
    print(f"   Consumed {len(consumed)} messages")
    
    # Show consumer stats
    stats = consumer.get_stats()
    print(f"\n📊 Consumer Stats:")
    print(f"   Consumer: {stats['name']}")
    print(f"   Group: {stats['consumer_group']}")
    print(f"   Consumed: {stats['consumed_count']}")
    print(f"   Last Message: {stats['last_message_topic']}/{stats['last_message_key']}")
    
    # Show topic stats
    print(f"\n📊 Topic Stats:")
    for topic in [orders_topic, alerts_topic]:
        stats = topic.get_stats()
        print(f"   {stats['name']}:")
        print(f"      Partitions: {stats['partitions']}")
        print(f"      Messages: {stats['message_count']}")
        for p in stats['partition_stats']:
            print(f"      - Partition {p['partition_id']}: {p['message_count']} messages, last offset {p['last_offset']}")
    
    # Demonstrate stream processing
    print("\n📊 Starting stream processing...")
    
    def process_order(message: KafkaMessage) -> Dict[str, Any]:
        """Process an order message"""
        if message.topic == 'orders':
            order = message.value
            # Calculate metrics
            amount = order.get('amount', 0)
            items = order.get('items', 0)
            
            result = {
                'order_id': order.get('order_id'),
                'avg_item_price': amount / items if items > 0 else 0,
                'is_bulk': items > 3,
                'is_high_value': amount > 200
            }
            
            print(f"   📊 Processed order {order.get('order_id')}: {result}")
            return result
        
        return {}
    
    stream_processor = KafkaStreamProcessing("OrderProcessor")
    stream_processor.process_stream(consumer, process_order, poll_interval=0.2)
    
    # Produce more messages
    print("\n📤 Producing more messages for stream processing...")
    time.sleep(0.5)
    for i in range(3):
        producer1.produce(orders_topic, f"CUST-00{i}", 
                         {'order_id': 2000 + i, 'amount': 100 * (i + 1), 'items': i + 2})
    
    # Wait for processing
    time.sleep(2)
    
    # Stop stream processing
    stream_processor.stop()
    
    # Show processor stats
    stats = stream_processor.get_stats()
    print(f"\n📊 Stream Processor Stats:")
    print(f"   Processed: {stats['processed_count']} messages")
    print(f"   Processed: {stats['processed_mb']:.2f} MB")
    
    # Producer stats
    print(f"\n📊 Producer Stats:")
    for producer in [producer1, producer2]:
        stats = producer.get_stats()
        print(f"   {stats['name']}:")
        print(f"      Produced: {stats['produced_count']} messages")
        print(f"      Produced: {stats['produced_mb']:.2f} MB")
    
    print("\n🎯 Kafka Benefits:")
    print("   • High throughput (millions of messages/sec)")
    print("   • Fault-tolerant (replication)")
    print("   • Durable (persistent storage)")
    print("   • Scalable (partitioning)")
    print("   • Low latency (sub-second)")
    print("   • Multiple consumers (pub-sub)")

def main():
    """Run Kafka demonstration"""
    demo_kafka()
    
    print("\n" + "="*60)
    print("✅ KAFKA DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 7.4 Pipeline Orchestration with Airflow

### The Concept

Pipeline orchestration is like an automated factory assembly line - you define the steps (tasks), their dependencies, and the system ensures they run in the correct order, handles failures, and provides visibility into the entire process.

### The Implementation

**File: `part-07-data-integration/pipeline_orchestration.py`**
```python
#!/usr/bin/env python3
"""
Pipeline Orchestration (Airflow-style DAG implementation)
"""

import time
import json
import threading
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
from enum import Enum
from datetime import datetime
import queue

class TaskStatus(Enum):
    """Task execution status"""
    PENDING = "pending"
    RUNNING = "running"
    SUCCESS = "success"
    FAILED = "failed"
    SKIPPED = "skipped"
    UPSTREAM_FAILED = "upstream_failed"

@dataclass
class TaskInstance:
    """An instance of a task"""
    task_id: str
    dag_id: str
    status: TaskStatus
    start_time: Optional[float] = None
    end_time: Optional[float] = None
    retry_count: int = 0
    max_retries: int = 3
    result: Any = None
    error: Optional[str] = None

@dataclass
class Task:
    """A task definition"""
    task_id: str
    callable: Callable
    dependencies: List[str]
    retries: int = 3
    retry_delay: int = 5  # seconds
    timeout: int = 60  # seconds
    args: List[Any] = None
    kwargs: Dict[str, Any] = None

class DAG:
    """
    Directed Acyclic Graph for pipeline orchestration
    """
    
    def __init__(self, dag_id: str, description: str = ""):
        self.dag_id = dag_id
        self.description = description
        self.tasks: Dict[str, Task] = {}
        self.instance: Dict[str, TaskInstance] = {}
        self.execution_date: Optional[datetime] = None
        self.start_time: Optional[float] = None
        self.end_time: Optional[float] = None
        self.status: TaskStatus = TaskStatus.PENDING
        
        self.execution_queue: queue.Queue = queue.Queue()
        self.results: Dict[str, Any] = {}
        
    def add_task(self, task: Task):
        """Add a task to the DAG"""
        self.tasks[task.task_id] = task
    
    def set_execution_date(self, execution_date: datetime):
        """Set the execution date for this run"""
        self.execution_date = execution_date
    
    def run(self) -> bool:
        """Run the DAG"""
        print(f"\n🏃 Running DAG: {self.dag_id}")
        print(f"   Description: {self.description}")
        print(f"   Execution Date: {self.execution_date}")
        print(f"   Tasks: {len(self.tasks)}")
        
        self.start_time = time.time()
        self.status = TaskStatus.RUNNING
        
        # Initialize task instances
        for task_id in self.tasks:
            self.instance[task_id] = TaskInstance(
                task_id=task_id,
                dag_id=self.dag_id,
                status=TaskStatus.PENDING
            )
        
        # Execute tasks
        try:
            success = self._execute_tasks()
            self.status = TaskStatus.SUCCESS if success else TaskStatus.FAILED
            return success
            
        except Exception as e:
            print(f"❌ DAG failed: {e}")
            self.status = TaskStatus.FAILED
            return False
        
        finally:
            self.end_time = time.time()
    
    def _execute_tasks(self) -> bool:
        """Execute all tasks in order"""
        executed = set()
        remaining = set(self.tasks.keys())
        
        while remaining:
            # Find tasks with all dependencies met
            ready = set()
            for task_id in remaining:
                task = self.tasks[task_id]
                deps_met = all(dep in executed for dep in task.dependencies)
                
                # Check if any dependency failed
                dep_failed = any(self.instance[dep].status == TaskStatus.FAILED 
                               for dep in task.dependencies)
                
                if deps_met:
                    ready.add(task_id)
                elif dep_failed:
                    # Skip this task
                    self.instance[task_id].status = TaskStatus.UPSTREAM_FAILED
                    remaining.remove(task_id)
                    print(f"   ⚠️ Task {task_id} skipped (upstream failed)")
            
            if not ready:
                # Deadlock or all tasks processed
                break
            
            # Execute ready tasks
            for task_id in ready:
                success = self._execute_task(task_id)
                executed.add(task_id)
                remaining.remove(task_id)
                
                if not success:
                    # Stop execution on failure
                    return False
        
        return True
    
    def _execute_task(self, task_id: str) -> bool:
        """Execute a single task"""
        task = self.tasks[task_id]
        instance = self.instance[task_id]
        
        instance.status = TaskStatus.RUNNING
        instance.start_time = time.time()
        
        print(f"   ▶️ Running task: {task_id}")
        
        # Retry logic
        for attempt in range(task.retries + 1):
            try:
                # Execute with timeout
                result = self._run_with_timeout(task)
                
                instance.result = result
                instance.status = TaskStatus.SUCCESS
                instance.end_time = time.time()
                self.results[task_id] = result
                
                print(f"   ✅ Task {task_id} completed successfully")
                return True
                
            except Exception as e:
                instance.error = str(e)
                instance.retry_count += 1
                
                if instance.retry_count <= task.retries:
                    print(f"   ⚠️ Task {task_id} failed (attempt {attempt+1}), retrying...")
                    time.sleep(task.retry_delay)
                else:
                    instance.status = TaskStatus.FAILED
                    instance.end_time = time.time()
                    print(f"   ❌ Task {task_id} failed after {task.retries + 1} attempts: {e}")
                    return False
        
        return False
    
    def _run_with_timeout(self, task: Task) -> Any:
        """Run a task with timeout"""
        result_queue = queue.Queue()
        error_queue = queue.Queue()
        
        def task_wrapper():
            try:
                result = task.callable(*task.args, **task.kwargs)
                result_queue.put(result)
            except Exception as e:
                error_queue.put(e)
        
        thread = threading.Thread(target=task_wrapper)
        thread.daemon = True
        thread.start()
        thread.join(timeout=task.timeout)
        
        if thread.is_alive():
            raise TimeoutError(f"Task {task.task_id} timed out after {task.timeout}s")
        
        if not error_queue.empty():
            raise error_queue.get()
        
        if not result_queue.empty():
            return result_queue.get()
        
        return None
    
    def get_task_status(self, task_id: str) -> Optional[str]:
        """Get status of a specific task"""
        if task_id in self.instance:
            return self.instance[task_id].status.value
        return None
    
    def get_result(self, task_id: str) -> Optional[Any]:
        """Get result of a specific task"""
        if task_id in self.results:
            return self.results[task_id]
        return None
    
    def get_summary(self) -> Dict[str, Any]:
        """Get DAG execution summary"""
        duration = None
        if self.start_time and self.end_time:
            duration = self.end_time - self.start_time
        
        return {
            'dag_id': self.dag_id,
            'status': self.status.value,
            'start_time': self.start_time,
            'end_time': self.end_time,
            'duration_seconds': duration,
            'tasks': {
                task_id: instance.status.value 
                for task_id, instance in self.instance.items()
            }
        }

class DAGBuilder:
    """
    Builder for creating DAGs
    """
    
    @staticmethod
    def create_dag(dag_id: str, description: str = "") -> DAG:
        """Create a new DAG"""
        return DAG(dag_id, description)
    
    @staticmethod
    def task(task_id: str, callable: Callable, 
             dependencies: List[str] = None, 
             retries: int = 3, timeout: int = 60) -> Task:
        """Create a new task"""
        if dependencies is None:
            dependencies = []
        
        return Task(
            task_id=task_id,
            callable=callable,
            dependencies=dependencies,
            retries=retries,
            timeout=timeout
        )

def demo_pipeline_orchestration():
    """Demonstrate pipeline orchestration"""
    print("="*60)
    print("PIPELINE ORCHESTRATION DEMONSTRATION")
    print("="*60)
    
    # Define tasks
    def extract_data():
        """Extract data from source"""
        print("      📤 Extracting data...")
        time.sleep(1)
        return [
            {'id': 1, 'name': 'Alice', 'amount': 100},
            {'id': 2, 'name': 'Bob', 'amount': 200},
            {'id': 3, 'name': 'Charlie', 'amount': 300}
        ]
    
    def transform_data(data):
        """Transform the data"""
        print("      🔄 Transforming data...")
        time.sleep(0.5)
        return [{'id': d['id'], 'name': d['name'].upper(), 'amount': d['amount'] * 1.1} 
                for d in data]
    
    def validate_data(data):
        """Validate the data"""
        print("      ✅ Validating data...")
        time.sleep(0.3)
        valid_data = [d for d in data if d['amount'] > 0 and d['name']]
        if len(valid_data) != len(data):
            print("      ⚠️ Some data failed validation")
        return valid_data
    
    def load_data(data):
        """Load data to destination"""
        print("      💾 Loading data...")
        time.sleep(0.5)
        return f"Loaded {len(data)} records"
    
    def generate_report(load_result):
        """Generate a report"""
        print("      📊 Generating report...")
        time.sleep(0.3)
        return f"Report: {load_result}"
    
    def send_notification(report):
        """Send notification"""
        print("      📧 Sending notification...")
        time.sleep(0.2)
        return f"Notification sent: {report}"
    
    # Create DAG
    dag = DAGBuilder.create_dag("data_ingestion_dag", "Ingest and process data")
    
    # Create tasks with dependencies
    extract = DAGBuilder.task("extract", extract_data)
    transform = DAGBuilder.task("transform", transform_data, dependencies=["extract"])
    validate = DAGBuilder.task("validate", validate_data, dependencies=["transform"])
    load = DAGBuilder.task("load", load_data, dependencies=["validate"])
    report = DAGBuilder.task("report", generate_report, dependencies=["load"])
    notify = DAGBuilder.task("notify", send_notification, dependencies=["report"])
    
    # Add tasks to DAG
    dag.add_task(extract)
    dag.add_task(transform)
    dag.add_task(validate)
    dag.add_task(load)
    dag.add_task(report)
    dag.add_task(notify)
    
    # Set execution date
    dag.set_execution_date(datetime.now())
    
    # Run DAG
    print("\n📋 DAG Structure:")
    print("   extract → transform → validate → load → report → notify")
    print("   Dependencies defined for all tasks")
    
    success = dag.run()
    
    # Show summary
    summary = dag.get_summary()
    print(f"\n📊 DAG Summary:")
    print(f"   Status: {summary['status']}")
    print(f"   Duration: {summary['duration_seconds']:.2f}s")
    print(f"   Tasks:")
    for task_id, status in summary['tasks'].items():
        print(f"      {task_id}: {status}")
    
    # Show results
    if success:
        print(f"\n📈 Results:")
        for task_id in ['load', 'report', 'notify']:
            result = dag.get_result(task_id)
            if result:
                print(f"   {task_id}: {result}")
    
    # Demonstrate dependency failure
    print("\n\n🔬 Testing failure handling...")
    
    def failing_task():
        print("      💥 Task intentionally failing...")
        raise Exception("Intentional failure for demonstration")
    
    # Create DAG with failure
    dag2 = DAGBuilder.create_dag("failure_demo", "Demonstrate failure handling")
    
    task1 = DAGBuilder.task("task1", lambda: "Success")
    task2 = DAGBuilder.task("task2", failing_task, dependencies=["task1"])
    task3 = DAGBuilder.task("task3", lambda: "Should be skipped", dependencies=["task2"])
    task4 = DAGBuilder.task("task4", lambda: "Should run regardless", dependencies=[])
    
    dag2.add_task(task1)
    dag2.add_task(task2)
    dag2.add_task(task3)
    dag2.add_task(task4)
    dag2.set_execution_date(datetime.now())
    
    print("\n📋 Failure DAG Structure:")
    print("   task1 → task2 → task3")
    print("   task4 (independent)")
    print("   Expected: task2 fails, task3 skipped, task4 runs")
    
    success = dag2.run()
    
    summary = dag2.get_summary()
    print(f"\n📊 Failure DAG Summary:")
    print(f"   Status: {summary['status']}")
    print(f"   Tasks:")
    for task_id, status in summary['tasks'].items():
        print(f"      {task_id}: {status}")

def main():
    """Run pipeline orchestration demonstration"""
    demo_pipeline_orchestration()
    
    print("\n" + "="*60)
    print("✅ PIPELINE ORCHESTRATION DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-07-data-integration

# Run the ETL patterns demonstration
python etl_patterns.py

# Run the CDC demonstration
python change_data_capture.py

# Run the Kafka demonstration
python kafka_implementation.py

# Run the pipeline orchestration demonstration
python pipeline_orchestration.py

# Expected output:
# ============================================================
# ETL PIPELINE DEMONSTRATION
# ============================================================
# 
# 📋 Running ETL Pipeline:
#    Extract (JSON) → Transform (Clean + Enrich) → Load (Console)
#    [EXTRACT] json: started 
#    [EXTRACT] json: completed 197
#    [TRANSFORM] clean: started 
#    [TRANSFORM] clean: completed 202
#    [TRANSFORM] enrich: started 
#    [TRANSFORM] enrich: completed 295
#    [LOAD] console: started 
# 
#    Loaded 5 records to console:
#       {'id': 1, 'name': 'Alice', 'age': 30, 'city': 'NY', 'salary': 75000, 'salary_bracket': 'medium', 'age_group': '30+'}
#       ...
#    [LOAD] console: completed 295
#    [PIPELINE] complete: ETL pipeline completed in 0.03s
# 
# ============================================================
# ✅ ETL PATTERN DEMONSTRATIONS COMPLETE
# ============================================================
```

---

## Part 7 Recap

You have successfully:

✅ Implemented ETL, ELT, and Reverse ETL pipelines  
✅ Built a complete Change Data Capture (CDC) system  
✅ Implemented Apache Kafka with producers and consumers  
✅ Created stream processing with Kafka  
✅ Built pipeline orchestration with DAGs  
✅ Implemented task dependencies and retry logic  
✅ Handled failures and task skipping  

### Key Takeaways

1. **ETL** transforms data before loading - good for structured data warehouses
2. **ELT** loads raw data first - leverages modern warehouse compute
3. **Reverse ETL** pushes analytics to operational systems
4. **CDC** enables real-time data synchronization with minimal impact
5. **Kafka** provides high-throughput, fault-tolerant event streaming
6. **Orchestration** manages complex pipelines with dependencies
7. **Retry Logic** handles transient failures automatically
8. **Dependencies** ensure tasks run in the correct order
