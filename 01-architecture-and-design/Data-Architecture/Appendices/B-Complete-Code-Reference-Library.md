# Appendix B: Complete Code Reference Library

Welcome to Appendix B, which serves as a comprehensive code reference for the entire Mastering Modern Data Architecture series. This appendix contains all the utility functions, helper classes, and reusable components that were used throughout the series. Think of this as your toolkit - a collection of battle-tested code snippets and patterns you can reuse in your own projects.

## B.1 Data Utilities

### The Concept

Data utilities provide common functions for working with data - from type conversions to data validation and transformation. These are the foundational building blocks used across the entire series.

### The Implementation

**File: `utils/data_utils.py`**
```python
#!/usr/bin/env python3
"""
Data Utilities Library
Common data manipulation and transformation functions
"""

import json
import csv
import io
import hashlib
import re
from typing import Dict, List, Any, Optional, Union, Tuple
from datetime import datetime, date, time, timedelta
from decimal import Decimal
import uuid
import base64
import zlib
import pickle

class DataUtils:
    """
    Comprehensive data utilities class
    Provides common data manipulation functions
    """
    
    # ============================================
    # TYPE CONVERSION UTILITIES
    # ============================================
    
    @staticmethod
    def safe_cast(value: Any, target_type: type, default: Any = None) -> Any:
        """
        Safely cast a value to a target type
        Returns default if casting fails
        """
        try:
            if target_type == int:
                if isinstance(value, (int, float)):
                    return int(value)
                if isinstance(value, str):
                    return int(value.strip())
                return default
            elif target_type == float:
                if isinstance(value, (int, float)):
                    return float(value)
                if isinstance(value, str):
                    return float(value.strip())
                return default
            elif target_type == str:
                if value is None:
                    return default
                return str(value)
            elif target_type == bool:
                if isinstance(value, bool):
                    return value
                if isinstance(value, str):
                    return value.lower() in ('true', '1', 'yes', 'y')
                if isinstance(value, (int, float)):
                    return bool(value)
                return default
            elif target_type == dict:
                if isinstance(value, dict):
                    return value
                if isinstance(value, str):
                    return json.loads(value)
                return default
            elif target_type == list:
                if isinstance(value, list):
                    return value
                if isinstance(value, str):
                    return json.loads(value)
                return default
            elif target_type == datetime:
                if isinstance(value, datetime):
                    return value
                if isinstance(value, str):
                    return DataUtils.parse_datetime(value)
                return default
            else:
                return target_type(value)
        except (ValueError, TypeError, json.JSONDecodeError):
            return default
    
    @staticmethod
    def parse_datetime(value: str, formats: List[str] = None) -> Optional[datetime]:
        """
        Parse a datetime string using multiple formats
        """
        if formats is None:
            formats = [
                '%Y-%m-%d %H:%M:%S',
                '%Y-%m-%d %H:%M:%S.%f',
                '%Y-%m-%dT%H:%M:%S',
                '%Y-%m-%dT%H:%M:%S.%f',
                '%Y-%m-%d',
                '%Y/%m/%d %H:%M:%S',
                '%Y/%m/%d',
                '%d-%m-%Y %H:%M:%S',
                '%d-%m-%Y',
                '%d/%m/%Y %H:%M:%S',
                '%d/%m/%Y'
            ]
        
        for fmt in formats:
            try:
                return datetime.strptime(value, fmt)
            except ValueError:
                continue
        
        return None
    
    @staticmethod
    def date_to_string(dt: datetime, format: str = '%Y-%m-%d %H:%M:%S') -> str:
        """Convert datetime to string"""
        if dt is None:
            return ''
        return dt.strftime(format)
    
    # ============================================
    # DATA VALIDATION UTILITIES
    # ============================================
    
    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email address format"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    @staticmethod
    def validate_phone(phone: str) -> bool:
        """Validate phone number format"""
        # Remove non-digit characters
        digits = re.sub(r'\D', '', phone)
        # Check if has valid length (10-15 digits)
        return 10 <= len(digits) <= 15
    
    @staticmethod
    def validate_url(url: str) -> bool:
        """Validate URL format"""
        pattern = r'^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$'
        return bool(re.match(pattern, url))
    
    @staticmethod
    def validate_json(data: str) -> bool:
        """Validate JSON string"""
        try:
            json.loads(data)
            return True
        except json.JSONDecodeError:
            return False
    
    @staticmethod
    def validate_schema(data: Dict[str, Any], schema: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """
        Validate a dictionary against a schema
        Schema format: {'field': {'type': str, 'required': bool, 'default': Any, 'validators': []}}
        """
        errors = []
        
        for field, rules in schema.items():
            required = rules.get('required', False)
            field_type = rules.get('type')
            default = rules.get('default')
            
            # Check if field exists
            if field not in data:
                if required:
                    errors.append(f"Missing required field: {field}")
                else:
                    # Set default value if provided
                    if default is not None:
                        data[field] = default
                continue
            
            value = data[field]
            
            # Check type
            if field_type and not isinstance(value, field_type):
                errors.append(f"Invalid type for {field}: expected {field_type.__name__}, got {type(value).__name__}")
                continue
            
            # Run custom validators
            validators = rules.get('validators', [])
            for validator in validators:
                if callable(validator):
                    try:
                        if not validator(value):
                            errors.append(f"Validation failed for {field}: {validator.__name__}")
                    except Exception as e:
                        errors.append(f"Validation error for {field}: {str(e)}")
        
        return len(errors) == 0, errors
    
    # ============================================
    # DATA HASHING AND ENCODING
    # ============================================
    
    @staticmethod
    def hash_data(data: Any, algorithm: str = 'sha256') -> str:
        """Hash data using specified algorithm"""
        if not isinstance(data, (str, bytes)):
            data = json.dumps(data, sort_keys=True)
        
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        if algorithm == 'md5':
            return hashlib.md5(data).hexdigest()
        elif algorithm == 'sha1':
            return hashlib.sha1(data).hexdigest()
        elif algorithm == 'sha256':
            return hashlib.sha256(data).hexdigest()
        elif algorithm == 'sha512':
            return hashlib.sha512(data).hexdigest()
        else:
            raise ValueError(f"Unsupported algorithm: {algorithm}")
    
    @staticmethod
    def encode_base64(data: Union[str, bytes]) -> str:
        """Encode data to base64"""
        if isinstance(data, str):
            data = data.encode('utf-8')
        return base64.b64encode(data).decode('utf-8')
    
    @staticmethod
    def decode_base64(data: str) -> bytes:
        """Decode base64 data"""
        return base64.b64decode(data.encode('utf-8'))
    
    @staticmethod
    def compress_data(data: Union[str, bytes]) -> bytes:
        """Compress data using zlib"""
        if isinstance(data, str):
            data = data.encode('utf-8')
        return zlib.compress(data)
    
    @staticmethod
    def decompress_data(data: bytes) -> bytes:
        """Decompress data using zlib"""
        return zlib.decompress(data)
    
    @staticmethod
    def serialize_to_bytes(obj: Any) -> bytes:
        """Serialize an object to bytes using pickle"""
        return pickle.dumps(obj)
    
    @staticmethod
    def deserialize_from_bytes(data: bytes) -> Any:
        """Deserialize bytes to object using pickle"""
        return pickle.loads(data)
    
    # ============================================
    # DATA GENERATION UTILITIES
    # ============================================
    
    @staticmethod
    def generate_uuid() -> str:
        """Generate a UUID string"""
        return str(uuid.uuid4())
    
    @staticmethod
    def generate_id(prefix: str = "", length: int = 8) -> str:
        """Generate a short ID"""
        import random
        import string
        
        chars = string.ascii_uppercase + string.digits
        random_part = ''.join(random.choices(chars, k=length))
        
        if prefix:
            return f"{prefix}_{random_part}"
        return random_part
    
    @staticmethod
    def generate_timestamp() -> float:
        """Generate current timestamp"""
        return time.time()
    
    @staticmethod
    def generate_date_range(start: datetime, end: datetime, 
                           interval: timedelta = timedelta(days=1)) -> List[datetime]:
        """Generate a list of dates between start and end"""
        dates = []
        current = start
        while current <= end:
            dates.append(current)
            current += interval
        return dates
    
    # ============================================
    # CSV/JSON UTILITIES
    # ============================================
    
    @staticmethod
    def csv_to_dict(csv_data: str, delimiter: str = ',') -> List[Dict[str, Any]]:
        """Convert CSV string to list of dictionaries"""
        reader = csv.DictReader(io.StringIO(csv_data), delimiter=delimiter)
        return list(reader)
    
    @staticmethod
    def dict_to_csv(data: List[Dict[str, Any]], delimiter: str = ',') -> str:
        """Convert list of dictionaries to CSV string"""
        if not data:
            return ''
        
        fieldnames = list(data[0].keys())
        output = io.StringIO()
        writer = csv.DictWriter(output, fieldnames=fieldnames, delimiter=delimiter)
        writer.writeheader()
        writer.writerows(data)
        return output.getvalue()
    
    @staticmethod
    def json_to_dict(json_data: str) -> Dict[str, Any]:
        """Convert JSON string to dictionary"""
        return json.loads(json_data)
    
    @staticmethod
    def dict_to_json(data: Dict[str, Any], indent: int = 2) -> str:
        """Convert dictionary to JSON string"""
        return json.dumps(data, indent=indent, default=str)
    
    @staticmethod
    def flatten_dict(data: Dict[str, Any], separator: str = '.') -> Dict[str, Any]:
        """
        Flatten a nested dictionary
        {'a': {'b': 1}} -> {'a.b': 1}
        """
        result = {}
        
        def _flatten(current: Dict[str, Any], prefix: str = ''):
            for key, value in current.items():
                new_key = f"{prefix}{separator}{key}" if prefix else key
                if isinstance(value, dict):
                    _flatten(value, new_key)
                else:
                    result[new_key] = value
        
        _flatten(data)
        return result
    
    @staticmethod
    def unflatten_dict(data: Dict[str, Any], separator: str = '.') -> Dict[str, Any]:
        """
        Unflatten a dictionary
        {'a.b': 1} -> {'a': {'b': 1}}
        """
        result = {}
        
        for key, value in data.items():
            parts = key.split(separator)
            current = result
            for part in parts[:-1]:
                if part not in current:
                    current[part] = {}
                current = current[part]
            current[parts[-1]] = value
        
        return result

class DataTransformer:
    """
    Data transformation utilities
    Common ETL transformations
    """
    
    @staticmethod
    def normalize_column_names(columns: List[str]) -> List[str]:
        """
        Normalize column names to snake_case
        "User ID" -> "user_id"
        """
        normalized = []
        for col in columns:
            # Lowercase
            col = col.lower()
            # Replace spaces and special characters
            col = re.sub(r'[^a-zA-Z0-9]', '_', col)
            # Remove consecutive underscores
            col = re.sub(r'_+', '_', col)
            # Remove leading/trailing underscores
            col = col.strip('_')
            normalized.append(col)
        return normalized
    
    @staticmethod
    def convert_to_snake_case(name: str) -> str:
        """Convert CamelCase to snake_case"""
        s1 = re.sub(r'(.)([A-Z][a-z]+)', r'\1_\2', name)
        return re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', s1).lower()
    
    @staticmethod
    def convert_to_camel_case(name: str) -> str:
        """Convert snake_case to CamelCase"""
        parts = name.split('_')
        return parts[0] + ''.join(p.title() for p in parts[1:])
    
    @staticmethod
    def remove_empty_records(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Remove records with all empty values"""
        return [r for r in data if any(v for v in r.values() if v is not None)]
    
    @staticmethod
    def filter_by_values(data: List[Dict[str, Any]], 
                        column: str, values: List[Any]) -> List[Dict[str, Any]]:
        """Filter records where column value is in values list"""
        return [r for r in data if r.get(column) in values]
    
    @staticmethod
    def filter_by_range(data: List[Dict[str, Any]], 
                       column: str, min_val: Any, max_val: Any) -> List[Dict[str, Any]]:
        """Filter records where column value is between min and max"""
        return [r for r in data if min_val <= r.get(column, min_val) <= max_val]
    
    @staticmethod
    def add_derived_column(data: List[Dict[str, Any]], 
                          new_col: str, 
                          expression: callable) -> List[Dict[str, Any]]:
        """Add a derived column to each record"""
        for record in data:
            record[new_col] = expression(record)
        return data
    
    @staticmethod
    def join_dataframes(left: List[Dict[str, Any]], 
                        right: List[Dict[str, Any]],
                        left_key: str, right_key: str,
                        how: str = 'inner') -> List[Dict[str, Any]]:
        """
        Join two lists of dictionaries
        Supports inner, left, right, outer joins
        """
        # Create index for right dataset
        right_index = {}
        for record in right:
            key = record.get(right_key)
            if key not in right_index:
                right_index[key] = []
            right_index[key].append(record)
        
        result = []
        
        # Process based on join type
        if how == 'inner':
            for left_record in left:
                key = left_record.get(left_key)
                if key in right_index:
                    for right_record in right_index[key]:
                        merged = {**left_record, **right_record}
                        result.append(merged)
        
        elif how == 'left':
            for left_record in left:
                key = left_record.get(left_key)
                if key in right_index:
                    for right_record in right_index[key]:
                        merged = {**left_record, **right_record}
                        result.append(merged)
                else:
                    result.append({**left_record})
        
        elif how == 'right':
            for right_record in right:
                key = right_record.get(right_key)
                # Find matching left records
                matched = False
                for left_record in left:
                    if left_record.get(left_key) == key:
                        merged = {**left_record, **right_record}
                        result.append(merged)
                        matched = True
                if not matched:
                    result.append({**right_record})
        
        elif how == 'outer':
            # All left records
            left_keys = set()
            for left_record in left:
                key = left_record.get(left_key)
                left_keys.add(key)
                if key in right_index:
                    for right_record in right_index[key]:
                        merged = {**left_record, **right_record}
                        result.append(merged)
                else:
                    result.append({**left_record})
            
            # Right records not in left
            for right_record in right:
                key = right_record.get(right_key)
                if key not in left_keys:
                    result.append({**right_record})
        
        return result

# Example usage
if __name__ == "__main__":
    # Test data utilities
    print("Testing DataUtils:")
    
    # Type conversion
    print(f"  safe_cast('123', int): {DataUtils.safe_cast('123', int)}")
    print(f"  safe_cast('123.45', float): {DataUtils.safe_cast('123.45', float)}")
    print(f"  safe_cast('true', bool): {DataUtils.safe_cast('true', bool)}")
    
    # Date parsing
    print(f"  parse_datetime('2024-01-15 10:30:00'): {DataUtils.parse_datetime('2024-01-15 10:30:00')}")
    
    # Validation
    print(f"  validate_email('test@example.com'): {DataUtils.validate_email('test@example.com')}")
    print(f"  validate_phone('+1-234-567-8900'): {DataUtils.validate_phone('+1-234-567-8900')}")
    
    # Hashing
    print(f"  hash_data('Hello World'): {DataUtils.hash_data('Hello World')}")
    
    # CSV conversion
    csv_data = "name,age,city\nAlice,30,NY\nBob,25,LA"
    dict_data = DataUtils.csv_to_dict(csv_data)
    print(f"  csv_to_dict: {dict_data}")
    
    # Flattening
    nested = {'user': {'name': 'Alice', 'address': {'city': 'NY', 'zip': '10001'}}}
    flat = DataUtils.flatten_dict(nested)
    print(f"  flatten_dict: {flat}")
    
    # Test DataTransformer
    print("\nTesting DataTransformer:")
    
    # Normalize columns
    cols = ['User ID', 'First Name', 'Last Name', 'Email Address']
    normalized = DataTransformer.normalize_column_names(cols)
    print(f"  normalize_column_names({cols}): {normalized}")
    
    # Filtering
    data = [
        {'name': 'Alice', 'age': 30, 'city': 'NY'},
        {'name': 'Bob', 'age': 25, 'city': 'LA'},
        {'name': 'Charlie', 'age': 35, 'city': 'NY'}
    ]
    
    filtered = DataTransformer.filter_by_values(data, 'city', ['NY'])
    print(f"  filter_by_values(city=NY): {filtered}")
    
    # Add derived column
    def age_group(record):
        age = record.get('age', 0)
        if age < 30:
            return 'Under 30'
        elif age < 40:
            return '30-39'
        else:
            return '40+'
    
    enriched = DataTransformer.add_derived_column(data, 'age_group', age_group)
    print(f"  add_derived_column(age_group): {enriched}")
```

**File: `utils/db_utils.py`**
```python
#!/usr/bin/env python3
"""
Database Utilities Library
Common database operations and connection management
"""

import time
import logging
from typing import Dict, List, Any, Optional, Union, Tuple
from contextlib import contextmanager
import threading
from dataclasses import dataclass
from enum import Enum

# Setup logging
logger = logging.getLogger(__name__)

class ConnectionPool:
    """
    Simple connection pool for database connections
    """
    
    def __init__(self, create_connection_func, max_connections: int = 10):
        self.create_connection = create_connection_func
        self.max_connections = max_connections
        self.connections = []
        self.in_use = set()
        self.lock = threading.Lock()
        self._closed = False
    
    @contextmanager
    def get_connection(self):
        """
        Get a connection from the pool
        Yields a connection and returns it to the pool when done
        """
        if self._closed:
            raise RuntimeError("Connection pool is closed")
        
        conn = None
        with self.lock:
            # Try to get an existing connection
            if self.connections:
                conn = self.connections.pop()
            
            # Create new connection if needed
            if conn is None and len(self.in_use) < self.max_connections:
                conn = self.create_connection()
            
            if conn is None:
                raise RuntimeError("No connections available")
            
            self.in_use.add(conn)
        
        try:
            yield conn
        finally:
            with self.lock:
                self.in_use.discard(conn)
                if not self._closed:
                    self.connections.append(conn)
    
    def close_all(self):
        """Close all connections in the pool"""
        with self.lock:
            self._closed = True
            for conn in self.connections:
                try:
                    conn.close()
                except Exception:
                    pass
            self.connections = []
            
            for conn in self.in_use:
                try:
                    conn.close()
                except Exception:
                    pass
            self.in_use = set()
    
    def get_stats(self) -> Dict[str, int]:
        """Get pool statistics"""
        with self.lock:
            return {
                'available': len(self.connections),
                'in_use': len(self.in_use),
                'total': len(self.connections) + len(self.in_use),
                'max': self.max_connections
            }

class TransactionManager:
    """
    Transaction management utility
    """
    
    def __init__(self, connection_pool: ConnectionPool):
        self.pool = connection_pool
        self.transactions = {}
        self.lock = threading.Lock()
    
    @contextmanager
    def transaction(self, isolation_level: str = 'READ_COMMITTED'):
        """
        Execute operations within a transaction
        """
        with self.pool.get_connection() as conn:
            try:
                # Begin transaction
                cursor = conn.cursor()
                cursor.execute(f"SET TRANSACTION ISOLATION LEVEL {isolation_level}")
                cursor.execute("BEGIN")
                
                yield conn
                
                # Commit transaction
                cursor.execute("COMMIT")
                
            except Exception as e:
                # Rollback on error
                try:
                    cursor.execute("ROLLBACK")
                except Exception:
                    pass
                raise e
            finally:
                cursor.close()
    
    def retry_transaction(self, func, max_retries: int = 3, delay: float = 0.1):
        """
        Retry a transaction function with exponential backoff
        """
        for attempt in range(max_retries):
            try:
                with self.transaction() as conn:
                    return func(conn)
            except Exception as e:
                if attempt == max_retries - 1:
                    raise e
                
                # Exponential backoff
                wait_time = delay * (2 ** attempt)
                logger.warning(f"Transaction retry {attempt + 1}/{max_retries}, waiting {wait_time}s")
                time.sleep(wait_time)
        
        return None

class QueryBuilder:
    """
    SQL query builder
    """
    
    def __init__(self):
        self._select = []
        self._from = []
        self._joins = []
        self._where = []
        self._group_by = []
        self._having = []
        self._order_by = []
        self._limit = None
        self._offset = None
    
    def select(self, *columns: str):
        """Add SELECT columns"""
        self._select.extend(columns)
        return self
    
    def from_table(self, table: str, alias: str = None):
        """Add FROM table"""
        if alias:
            self._from.append(f"{table} AS {alias}")
        else:
            self._from.append(table)
        return self
    
    def join(self, table: str, condition: str, 
             join_type: str = 'INNER', alias: str = None):
        """Add a JOIN"""
        join_clause = join_type
        if alias:
            join_clause += f" JOIN {table} AS {alias} ON {condition}"
        else:
            join_clause += f" JOIN {table} ON {condition}"
        self._joins.append(join_clause)
        return self
    
    def where(self, condition: str):
        """Add WHERE condition"""
        self._where.append(condition)
        return self
    
    def where_raw(self, condition: str, *args):
        """Add WHERE condition with parameters"""
        self._where.append(condition)
        return self
    
    def group_by(self, *columns: str):
        """Add GROUP BY columns"""
        self._group_by.extend(columns)
        return self
    
    def having(self, condition: str):
        """Add HAVING condition"""
        self._having.append(condition)
        return self
    
    def order_by(self, column: str, direction: str = 'ASC'):
        """Add ORDER BY"""
        self._order_by.append(f"{column} {direction}")
        return self
    
    def limit(self, limit: int):
        """Add LIMIT"""
        self._limit = limit
        return self
    
    def offset(self, offset: int):
        """Add OFFSET"""
        self._offset = offset
        return self
    
    def build(self) -> str:
        """Build the SQL query"""
        parts = []
        
        # SELECT
        if self._select:
            parts.append(f"SELECT {', '.join(self._select)}")
        else:
            parts.append("SELECT *")
        
        # FROM
        if self._from:
            parts.append(f"FROM {', '.join(self._from)}")
        
        # JOIN
        if self._joins:
            parts.extend(self._joins)
        
        # WHERE
        if self._where:
            parts.append(f"WHERE {' AND '.join(self._where)}")
        
        # GROUP BY
        if self._group_by:
            parts.append(f"GROUP BY {', '.join(self._group_by)}")
        
        # HAVING
        if self._having:
            parts.append(f"HAVING {' AND '.join(self._having)}")
        
        # ORDER BY
        if self._order_by:
            parts.append(f"ORDER BY {', '.join(self._order_by)}")
        
        # LIMIT
        if self._limit is not None:
            parts.append(f"LIMIT {self._limit}")
        
        # OFFSET
        if self._offset is not None:
            parts.append(f"OFFSET {self._offset}")
        
        return ' '.join(parts)

class DatabaseMetadata:
    """
    Database metadata utilities
    """
    
    def __init__(self, connection_pool: ConnectionPool):
        self.pool = connection_pool
    
    def get_tables(self, schema: str = None) -> List[str]:
        """Get list of tables"""
        with self.pool.get_connection() as conn:
            cursor = conn.cursor()
            if schema:
                cursor.execute("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = %s 
                    AND table_type = 'BASE TABLE'
                """, (schema,))
            else:
                cursor.execute("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_type = 'BASE TABLE'
                """)
            return [row[0] for row in cursor.fetchall()]
    
    def get_columns(self, table: str, schema: str = None) -> List[Dict[str, Any]]:
        """Get column information for a table"""
        with self.pool.get_connection() as conn:
            cursor = conn.cursor()
            if schema:
                cursor.execute("""
                    SELECT column_name, data_type, is_nullable, column_default
                    FROM information_schema.columns
                    WHERE table_name = %s AND table_schema = %s
                    ORDER BY ordinal_position
                """, (table, schema))
            else:
                cursor.execute("""
                    SELECT column_name, data_type, is_nullable, column_default
                    FROM information_schema.columns
                    WHERE table_name = %s
                    ORDER BY ordinal_position
                """, (table,))
            
            columns = []
            for row in cursor.fetchall():
                columns.append({
                    'name': row[0],
                    'data_type': row[1],
                    'nullable': row[2] == 'YES',
                    'default': row[3]
                })
            return columns
    
    def get_primary_key(self, table: str, schema: str = None) -> List[str]:
        """Get primary key columns"""
        with self.pool.get_connection() as conn:
            cursor = conn.cursor()
            if schema:
                cursor.execute("""
                    SELECT kcu.column_name
                    FROM information_schema.table_constraints tc
                    JOIN information_schema.key_column_usage kcu
                        ON tc.constraint_name = kcu.constraint_name
                    WHERE tc.constraint_type = 'PRIMARY KEY'
                        AND tc.table_name = %s
                        AND tc.table_schema = %s
                    ORDER BY kcu.ordinal_position
                """, (table, schema))
            else:
                cursor.execute("""
                    SELECT kcu.column_name
                    FROM information_schema.table_constraints tc
                    JOIN information_schema.key_column_usage kcu
                        ON tc.constraint_name = kcu.constraint_name
                    WHERE tc.constraint_type = 'PRIMARY KEY'
                        AND tc.table_name = %s
                    ORDER BY kcu.ordinal_position
                """, (table,))
            return [row[0] for row in cursor.fetchall()]
```

**File: `utils/performance_utils.py`**
```python
#!/usr/bin/env python3
"""
Performance Utilities Library
Caching, rate limiting, and performance monitoring
"""

import time
import functools
import threading
from typing import Dict, List, Any, Optional, Callable
from collections import OrderedDict
from dataclasses import dataclass

@dataclass
class CacheEntry:
    """Cache entry with metadata"""
    value: Any
    timestamp: float
    ttl: int

class LRUCache:
    """
    LRU (Least Recently Used) Cache implementation
    """
    
    def __init__(self, max_size: int = 100, default_ttl: int = 300):
        self.max_size = max_size
        self.default_ttl = default_ttl
        self.cache = OrderedDict()
        self.stats = {
            'hits': 0,
            'misses': 0
        }
        self.lock = threading.Lock()
    
    def get(self, key: str) -> Optional[Any]:
        """
        Get a value from the cache
        """
        with self.lock:
            if key not in self.cache:
                self.stats['misses'] += 1
                return None
            
            entry = self.cache[key]
            
            # Check if expired
            if time.time() - entry.timestamp > entry.ttl:
                del self.cache[key]
                self.stats['misses'] += 1
                return None
            
            # Move to end (most recently used)
            self.cache.move_to_end(key)
            self.stats['hits'] += 1
            return entry.value
    
    def put(self, key: str, value: Any, ttl: int = None):
        """
        Put a value in the cache
        """
        with self.lock:
            if ttl is None:
                ttl = self.default_ttl
            
            # If cache is full, remove least recently used
            if len(self.cache) >= self.max_size:
                self.cache.popitem(last=False)
            
            self.cache[key] = CacheEntry(
                value=value,
                timestamp=time.time(),
                ttl=ttl
            )
    
    def invalidate(self, key: str):
        """Invalidate a cache entry"""
        with self.lock:
            if key in self.cache:
                del self.cache[key]
    
    def clear(self):
        """Clear the cache"""
        with self.lock:
            self.cache.clear()
            self.stats = {'hits': 0, 'misses': 0}
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        total = self.stats['hits'] + self.stats['misses']
        return {
            'size': len(self.cache),
            'max_size': self.max_size,
            'hits': self.stats['hits'],
            'misses': self.stats['misses'],
            'hit_ratio': self.stats['hits'] / total if total > 0 else 0
        }

class RateLimiter:
    """
    Rate limiter implementation
    """
    
    def __init__(self, max_requests: int, time_window: int):
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests = []
        self.lock = threading.Lock()
    
    def allow_request(self) -> bool:
        """
        Check if a request is allowed
        """
        with self.lock:
            current_time = time.time()
            
            # Remove expired requests
            cutoff = current_time - self.time_window
            self.requests = [t for t in self.requests if t > cutoff]
            
            # Check if we can allow the request
            if len(self.requests) < self.max_requests:
                self.requests.append(current_time)
                return True
            
            return False
    
    def get_stats(self) -> Dict[str, Any]:
        """Get rate limiter statistics"""
        with self.lock:
            current_time = time.time()
            cutoff = current_time - self.time_window
            active_requests = len([t for t in self.requests if t > cutoff])
            
            return {
                'active_requests': active_requests,
                'max_requests': self.max_requests,
                'time_window': self.time_window,
                'utilization': active_requests / self.max_requests
            }

class PerformanceMonitor:
    """
    Performance monitoring utility
    """
    
    def __init__(self, name: str):
        self.name = name
        self.metrics = {
            'count': 0,
            'total_time': 0,
            'min_time': float('inf'),
            'max_time': 0,
            'percentiles': {}
        }
        self.lock = threading.Lock()
        self.times = []
    
    def record(self, duration: float):
        """
        Record a duration measurement
        """
        with self.lock:
            self.metrics['count'] += 1
            self.metrics['total_time'] += duration
            self.metrics['min_time'] = min(self.metrics['min_time'], duration)
            self.metrics['max_time'] = max(self.metrics['max_time'], duration)
            self.times.append(duration)
            
            # Keep only last 1000 measurements
            if len(self.times) > 1000:
                self.times = self.times[-1000:]
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Get performance statistics
        """
        with self.lock:
            if self.metrics['count'] == 0:
                return {
                    'name': self.name,
                    'count': 0
                }
            
            # Calculate percentiles
            sorted_times = sorted(self.times)
            total = len(sorted_times)
            
            percentiles = {
                'p50': sorted_times[int(total * 0.5)] if total > 0 else 0,
                'p90': sorted_times[int(total * 0.9)] if total > 0 else 0,
                'p95': sorted_times[int(total * 0.95)] if total > 0 else 0,
                'p99': sorted_times[int(total * 0.99)] if total > 0 else 0
            }
            
            return {
                'name': self.name,
                'count': self.metrics['count'],
                'total_time': self.metrics['total_time'],
                'avg_time': self.metrics['total_time'] / self.metrics['count'],
                'min_time': self.metrics['min_time'],
                'max_time': self.metrics['max_time'],
                'percentiles': percentiles
            }

def measure_time(monitor: PerformanceMonitor = None, name: str = None):
    """
    Decorator to measure function execution time
    """
    def decorator(func: Callable):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            try:
                result = func(*args, **kwargs)
                return result
            finally:
                elapsed = time.time() - start_time
                if monitor:
                    monitor.record(elapsed)
                elif name:
                    # Create temporary monitor
                    temp_monitor = PerformanceMonitor(name)
                    temp_monitor.record(elapsed)
        
        return wrapper
    return decorator

def rate_limit(max_requests: int, time_window: int):
    """
    Decorator to rate limit function calls
    """
    limiter = RateLimiter(max_requests, time_window)
    
    def decorator(func: Callable):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            if limiter.allow_request():
                return func(*args, **kwargs)
            raise RuntimeError("Rate limit exceeded")
        
        # Attach limiter for external access
        wrapper.limiter = limiter
        return wrapper
    return decorator

def cached(ttl: int = 300, max_size: int = 100):
    """
    Decorator to cache function results
    """
    cache = LRUCache(max_size=max_size, default_ttl=ttl)
    
    def decorator(func: Callable):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Create cache key
            key = f"{func.__name__}:{args}:{kwargs}"
            
            # Try cache
            result = cache.get(key)
            if result is not None:
                return result
            
            # Compute and cache
            result = func(*args, **kwargs)
            cache.put(key, result)
            return result
        
        # Attach cache for external access
        wrapper.cache = cache
        return wrapper
    return decorator
```

## Verification

Let's verify the utility library:

```bash
# Navigate to the utils directory
cd utils

# Test the data utilities
python data_utils.py

# Run a simple test of the utilities
python -c "
from data_utils import DataUtils, DataTransformer

# Test data_utils
print('Testing DataUtils:')
print(f'  safe_cast(\"123\", int): {DataUtils.safe_cast(\"123\", int)}')
print(f'  validate_email(\"test@example.com\"): {DataUtils.validate_email(\"test@example.com\")}')
print(f'  hash_data(\"Hello World\"): {DataUtils.hash_data(\"Hello World\")}')

# Test transformer
print('\nTesting DataTransformer:')
data = [{'name': 'Alice', 'age': 30}, {'name': 'Bob', 'age': 25}]
filtered = DataTransformer.filter_by_values(data, 'age', [30])
print(f'  filter_by_values(age=30): {filtered}')
"

# Expected output:
# Testing DataUtils:
#   safe_cast("123", int): 123
#   validate_email("test@example.com"): True
#   hash_data("Hello World"): 3f1f...
# 
# Testing DataTransformer:
#   filter_by_values(age=30): [{'name': 'Alice', 'age': 30}]
```
