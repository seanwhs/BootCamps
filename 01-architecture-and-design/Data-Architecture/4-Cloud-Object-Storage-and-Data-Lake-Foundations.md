# Part 4: Cloud Object Storage and Data Lake Foundations

Welcome to Part 4, where we explore how cloud object storage has become the backbone of modern data platforms. Think of object storage as a massive digital warehouse where each item (object) has its own unique identifier and metadata, making it infinitely scalable and perfect for data lakes.

## Learning Objectives

By the end of this part, you will be able to:

- Understand object storage architecture and its advantages
- Implement S3-compatible object storage using MinIO
- Design optimal bucket structures and partitioning strategies
- Implement lifecycle policies and versioning
- Build a complete data lake foundation
- Optimize storage costs through tiering strategies

---

## 4.1 Object Storage Architecture

### The Concept

Object storage is like a massive, self-service storage facility where each item is stored in its own box (object) with a unique tracking number (object ID). Unlike traditional file systems with hierarchical directories, object storage uses a flat namespace with rich metadata for each object.

```
┌─────────────────────────────────────────────────────────────┐
│                     OBJECT STORAGE MODEL                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Bucket (Container)                                       │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Object 1: {                                        │ │
│  │    Key: "orders/2024/01/orders.csv"                 │ │
│  │    Data: <binary data>                              │ │
│  │    Metadata: {                                      │ │
│  │      "content-type": "text/csv",                    │ │
│  │      "created": "2024-01-15T10:30:00Z",            │ │
│  │      "source": "payment-system"                     │ │
│  │    }                                                │ │
│  │  }                                                  │ │
│  │                                                     │ │
│  │  Object 2: {                                        │ │
│  │    Key: "products/2024/01/products.parquet"        │ │
│  │    Data: <parquet data>                            │ │
│  │    Metadata: {                                     │ │
│  │      "content-type": "application/parquet",        │ │
│  │      "version": "v2",                              │ │
│  │      "schema": "product_schema_v3"                 │ │
│  │    }                                               │ │
│  │  }                                                 │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### The Target
Build a complete object storage system with S3-compatible API, lifecycle management, and data lake foundations.

### The Implementation

**File: `part-04-object-storage/docker-compose.yml`**
```yaml
version: '3.8'

services:
  minio:
    image: minio/minio:RELEASE.2024-01-16T16-07-14Z
    container_name: dataarch_minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_DOMAIN: minio.local
    ports:
      - "9000:9000"   # API port
      - "9001:9001"   # Console port
    volumes:
      - minio_data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  minio-mc:
    image: minio/mc:latest
    container_name: dataarch_minio_mc
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      until (/usr/bin/mc config host add myminio http://minio:9000 minioadmin minioadmin123) do echo '...waiting...' && sleep 1; done;
      /usr/bin/mc mb myminio/data-lake;
      /usr/bin/mc mb myminio/data-lake-archive;
      /usr/bin/mc mb myminio/staging;
      /usr/bin/mc mb myminio/processed;
      /usr/bin/mc policy set public myminio/data-lake;
      echo 'MinIO buckets created successfully';
      exit 0;
      "

volumes:
  minio_data:
```

---

## 4.2 Object Storage Client Implementation

### The Concept

An S3-compatible client provides a uniform interface to interact with object storage, regardless of the underlying provider (AWS S3, MinIO, Google Cloud Storage, Azure Blob).

### The Implementation

**File: `part-04-object-storage/object_storage_client.py`**
```python
#!/usr/bin/env python3
"""
Object Storage Client Implementation
S3-compatible API for MinIO and cloud object storage
"""

import os
import io
import json
import time
import hashlib
import base64
from typing import Dict, List, Any, Optional, BinaryIO, Iterator
from dataclasses import dataclass
from datetime import datetime, timedelta
import tempfile
import mimetypes
from urllib.parse import urlparse

# Simulated S3-like client (we'll use boto3 in production)
# For this tutorial, we implement the core concepts

@dataclass
class ObjectMetadata:
    """Metadata for an object in storage"""
    key: str
    size: int
    last_modified: datetime
    etag: str
    content_type: str
    user_metadata: Dict[str, str]
    storage_class: str = "STANDARD"
    version_id: Optional[str] = None

@dataclass
class ObjectInfo:
    """Information about an object during listing"""
    key: str
    size: int
    last_modified: datetime
    etag: str

class ObjectStorageClient:
    """
    S3-compatible object storage client.
    Provides core operations for managing objects and buckets.
    """
    
    def __init__(self, endpoint: str, access_key: str, secret_key: str, 
                 secure: bool = False, region: str = "us-east-1"):
        self.endpoint = endpoint
        self.access_key = access_key
        self.secret_key = secret_key
        self.secure = secure
        self.region = region
        
        # In-memory storage simulation
        self.buckets: Dict[str, Dict[str, Any]] = {}
        self.objects: Dict[str, Dict[str, Any]] = {}
        
        print(f"🔗 Connected to object storage at {endpoint}")
    
    # ==================== BUCKET OPERATIONS ====================
    
    def create_bucket(self, bucket_name: str, region: str = None) -> bool:
        """Create a new bucket"""
        if bucket_name in self.buckets:
            raise ValueError(f"Bucket {bucket_name} already exists")
        
        # Validate bucket name
        if not self._validate_bucket_name(bucket_name):
            raise ValueError(f"Invalid bucket name: {bucket_name}")
        
        self.buckets[bucket_name] = {
            'name': bucket_name,
            'created_at': datetime.now(),
            'region': region or self.region,
            'object_count': 0,
            'size_bytes': 0,
            'versioning_enabled': False,
            'lifecycle_rules': []
        }
        self.objects[bucket_name] = {}
        
        print(f"🪣 Created bucket: {bucket_name}")
        return True
    
    def list_buckets(self) -> List[str]:
        """List all buckets"""
        return list(self.buckets.keys())
    
    def delete_bucket(self, bucket_name: str, force: bool = False) -> bool:
        """Delete a bucket"""
        if bucket_name not in self.buckets:
            return False
        
        # Check if bucket is empty
        if self.objects[bucket_name] and not force:
            raise ValueError(f"Bucket {bucket_name} is not empty")
        
        if force:
            # Delete all objects in bucket
            self.objects[bucket_name] = {}
        
        del self.buckets[bucket_name]
        del self.objects[bucket_name]
        
        print(f"🗑️ Deleted bucket: {bucket_name}")
        return True
    
    def _validate_bucket_name(self, bucket_name: str) -> bool:
        """Validate bucket name according to S3 rules"""
        if len(bucket_name) < 3 or len(bucket_name) > 63:
            return False
        if not bucket_name[0].isalnum():
            return False
        if not all(c.isalnum() or c in '-.' for c in bucket_name):
            return False
        if '..' in bucket_name:
            return False
        return True
    
    # ==================== OBJECT OPERATIONS ====================
    
    def put_object(self, bucket_name: str, key: str, data: bytes, 
                   content_type: Optional[str] = None,
                   metadata: Optional[Dict[str, str]] = None) -> ObjectMetadata:
        """Upload an object to a bucket"""
        if bucket_name not in self.buckets:
            raise ValueError(f"Bucket {bucket_name} does not exist")
        
        # Calculate ETag (MD5 hash of content)
        etag = hashlib.md5(data).hexdigest()
        
        # Determine content type
        if content_type is None:
            content_type, _ = mimetypes.guess_type(key)
            if content_type is None:
                content_type = "application/octet-stream"
        
        # Store object
        object_id = f"{bucket_name}/{key}"
        object_data = {
            'key': key,
            'data': data,
            'size': len(data),
            'etag': etag,
            'content_type': content_type,
            'last_modified': datetime.now(),
            'user_metadata': metadata or {},
            'storage_class': 'STANDARD',
            'version_id': None,
            'is_deleted': False
        }
        
        # Handle versioning if enabled
        if self.buckets[bucket_name].get('versioning_enabled', False):
            object_data['version_id'] = f"{int(time.time())}_{etag[:8]}"
        
        self.objects[bucket_name][key] = object_data
        
        # Update bucket stats
        self.buckets[bucket_name]['object_count'] += 1
        self.buckets[bucket_name]['size_bytes'] += len(data)
        
        print(f"📤 Uploaded: {bucket_name}/{key} ({len(data)} bytes, {content_type})")
        
        return ObjectMetadata(
            key=key,
            size=len(data),
            last_modified=object_data['last_modified'],
            etag=etag,
            content_type=content_type,
            user_metadata=metadata or {},
            storage_class='STANDARD',
            version_id=object_data.get('version_id')
        )
    
    def get_object(self, bucket_name: str, key: str) -> Optional[bytes]:
        """Retrieve an object from a bucket"""
        if bucket_name not in self.buckets:
            return None
        
        if key not in self.objects[bucket_name]:
            return None
        
        object_data = self.objects[bucket_name][key]
        
        # Check if object is deleted (soft delete)
        if object_data.get('is_deleted', False):
            return None
        
        print(f"📥 Retrieved: {bucket_name}/{key}")
        return object_data['data']
    
    def get_object_metadata(self, bucket_name: str, key: str) -> Optional[ObjectMetadata]:
        """Get object metadata without downloading data"""
        if bucket_name not in self.buckets:
            return None
        
        if key not in self.objects[bucket_name]:
            return None
        
        object_data = self.objects[bucket_name][key]
        
        return ObjectMetadata(
            key=key,
            size=object_data['size'],
            last_modified=object_data['last_modified'],
            etag=object_data['etag'],
            content_type=object_data['content_type'],
            user_metadata=object_data['user_metadata'],
            storage_class=object_data.get('storage_class', 'STANDARD'),
            version_id=object_data.get('version_id')
        )
    
    def delete_object(self, bucket_name: str, key: str, version_id: Optional[str] = None) -> bool:
        """Delete an object from a bucket"""
        if bucket_name not in self.buckets:
            return False
        
        if key not in self.objects[bucket_name]:
            return False
        
        object_data = self.objects[bucket_name][key]
        
        # If versioning is enabled, soft delete
        if self.buckets[bucket_name].get('versioning_enabled', False):
            object_data['is_deleted'] = True
            object_data['deleted_at'] = datetime.now()
            print(f"🗑️ Soft deleted (versioned): {bucket_name}/{key}")
        else:
            # Permanent deletion
            self.buckets[bucket_name]['object_count'] -= 1
            self.buckets[bucket_name]['size_bytes'] -= object_data['size']
            del self.objects[bucket_name][key]
            print(f"🗑️ Permanently deleted: {bucket_name}/{key}")
        
        return True
    
    def list_objects(self, bucket_name: str, prefix: str = "", 
                     delimiter: str = "", max_keys: int = 1000) -> List[ObjectInfo]:
        """List objects in a bucket with optional prefix"""
        if bucket_name not in self.buckets:
            return []
        
        objects = []
        for key, object_data in self.objects[bucket_name].items():
            if object_data.get('is_deleted', False):
                continue
            
            if prefix and not key.startswith(prefix):
                continue
            
            objects.append(ObjectInfo(
                key=key,
                size=object_data['size'],
                last_modified=object_data['last_modified'],
                etag=object_data['etag']
            ))
            
            if len(objects) >= max_keys:
                break
        
        return sorted(objects, key=lambda x: x.key)
    
    def copy_object(self, source_bucket: str, source_key: str,
                   dest_bucket: str, dest_key: str) -> bool:
        """Copy an object within or between buckets"""
        # Get source object
        source_data = self.get_object(source_bucket, source_key)
        if source_data is None:
            return False
        
        # Get metadata from source
        source_metadata = self.get_object_metadata(source_bucket, source_key)
        if source_metadata is None:
            return False
        
        # Put object in destination
        self.put_object(
            dest_bucket,
            dest_key,
            source_data,
            content_type=source_metadata.content_type,
            metadata=source_metadata.user_metadata
        )
        
        print(f"📋 Copied: {source_bucket}/{source_key} -> {dest_bucket}/{dest_key}")
        return True
    
    # ==================== VERSIONING ====================
    
    def enable_versioning(self, bucket_name: str) -> bool:
        """Enable versioning on a bucket"""
        if bucket_name not in self.buckets:
            return False
        
        self.buckets[bucket_name]['versioning_enabled'] = True
        print(f"🔢 Versioning enabled for: {bucket_name}")
        return True
    
    def disable_versioning(self, bucket_name: str) -> bool:
        """Disable versioning on a bucket"""
        if bucket_name not in self.buckets:
            return False
        
        self.buckets[bucket_name]['versioning_enabled'] = False
        print(f"🔢 Versioning disabled for: {bucket_name}")
        return True
    
    def list_object_versions(self, bucket_name: str, key: str) -> List[Dict[str, Any]]:
        """List all versions of an object"""
        if bucket_name not in self.buckets:
            return []
        
        if key not in self.objects[bucket_name]:
            return []
        
        # In a real implementation, we would store all versions
        # For simulation, return the current version
        object_data = self.objects[bucket_name][key]
        return [{
            'version_id': object_data.get('version_id', 'null'),
            'last_modified': object_data['last_modified'],
            'size': object_data['size'],
            'is_deleted': object_data.get('is_deleted', False),
            'etag': object_data['etag']
        }]
    
    # ==================== LIFECYCLE MANAGEMENT ====================
    
    def add_lifecycle_rule(self, bucket_name: str, prefix: str,
                          action: str, days: int) -> bool:
        """
        Add a lifecycle rule to a bucket
        Actions: 'expire', 'transition_to_archive', 'transition_to_deep_archive'
        """
        if bucket_name not in self.buckets:
            return False
        
        rule = {
            'prefix': prefix,
            'action': action,
            'days': days,
            'created_at': datetime.now()
        }
        
        self.buckets[bucket_name]['lifecycle_rules'].append(rule)
        print(f"♻️ Added lifecycle rule: {action} objects with prefix '{prefix}' after {days} days")
        return True
    
    def apply_lifecycle_policies(self, bucket_name: str) -> int:
        """Apply all lifecycle policies to a bucket"""
        if bucket_name not in self.buckets:
            return 0
        
        rules = self.buckets[bucket_name].get('lifecycle_rules', [])
        processed = 0
        
        for key, object_data in list(self.objects[bucket_name].items()):
            if object_data.get('is_deleted', False):
                continue
            
            # Check each rule
            for rule in rules:
                if key.startswith(rule['prefix']):
                    age = (datetime.now() - object_data['last_modified']).days
                    
                    if age >= rule['days']:
                        if rule['action'] == 'expire':
                            self.delete_object(bucket_name, key)
                            processed += 1
                        elif rule['action'] in ['transition_to_archive', 'transition_to_deep_archive']:
                            object_data['storage_class'] = rule['action'].replace('transition_to_', '').upper()
                            processed += 1
        
        print(f"♻️ Applied lifecycle policies: {processed} objects affected")
        return processed
    
    # ==================== STORAGE TIERING ====================
    
    def transition_storage_class(self, bucket_name: str, key: str, 
                                storage_class: str) -> bool:
        """Change storage class of an object"""
        if bucket_name not in self.buckets:
            return False
        
        if key not in self.objects[bucket_name]:
            return False
        
        self.objects[bucket_name][key]['storage_class'] = storage_class
        print(f"📦 Transitioned {bucket_name}/{key} to {storage_class}")
        return True
    
    def get_storage_usage(self) -> Dict[str, Any]:
        """Get overall storage usage statistics"""
        total_objects = 0
        total_size_bytes = 0
        
        storage_by_class = {}
        
        for bucket_name, bucket_objects in self.objects.items():
            for key, object_data in bucket_objects.items():
                if object_data.get('is_deleted', False):
                    continue
                
                total_objects += 1
                total_size_bytes += object_data['size']
                
                storage_class = object_data.get('storage_class', 'STANDARD')
                storage_by_class[storage_class] = storage_by_class.get(storage_class, 0) + object_data['size']
        
        return {
            'total_objects': total_objects,
            'total_size_bytes': total_size_bytes,
            'total_size_gb': total_size_bytes / (1024 ** 3),
            'storage_by_class': storage_by_class,
            'bucket_count': len(self.buckets)
        }
    
    # ==================== UPLOAD/COPY UTILITIES ====================
    
    def multipart_upload(self, bucket_name: str, key: str, data: bytes,
                        part_size: int = 5 * 1024 * 1024) -> bool:
        """
        Simulate multipart upload for large files
        """
        if bucket_name not in self.buckets:
            return False
        
        total_size = len(data)
        parts = []
        upload_id = f"upload_{int(time.time())}_{key}"
        
        print(f"📤 Starting multipart upload: {bucket_name}/{key} ({total_size} bytes)")
        
        # Split data into parts
        offset = 0
        part_number = 1
        
        while offset < total_size:
            part_data = data[offset:offset + part_size]
            parts.append({
                'part_number': part_number,
                'size': len(part_data),
                'etag': hashlib.md5(part_data).hexdigest()
            })
            offset += part_size
            part_number += 1
        
        print(f"   Split into {len(parts)} parts")
        
        # Complete multipart upload
        print(f"   Completing multipart upload...")
        self.put_object(bucket_name, key, data)
        
        return True
    
    def generate_presigned_url(self, bucket_name: str, key: str,
                              expires_in: int = 3600) -> str:
        """
        Generate a presigned URL for temporary access
        """
        # In a real implementation, this would use actual signing
        # This is a simulation
        timestamp = int(time.time())
        expiry = timestamp + expires_in
        
        url = f"{self.endpoint}/{bucket_name}/{key}?X-Amz-Expires={expires_in}&X-Amz-Date={timestamp}"
        
        # Simulate signing
        signature = base64.b64encode(
            hashlib.sha256(f"{url}:{self.secret_key}".encode()).digest()
        ).decode()
        url += f"&X-Amz-Signature={signature}"
        
        print(f"🔗 Generated presigned URL for {bucket_name}/{key} (expires in {expires_in}s)")
        return url

class DataLakeBuilder:
    """
    Build and manage a data lake using object storage
    """
    
    def __init__(self, client: ObjectStorageClient):
        self.client = client
        self.standard_buckets = [
            'raw',         # Incoming raw data
            'staging',     # Processed staging area
            'curated',     # Cleaned and validated data
            'analytics',   # Aggregated analytics data
            'archive'      # Archived data
        ]
    
    def initialize_data_lake(self, prefix: str = "") -> Dict[str, str]:
        """Create the standard data lake bucket structure"""
        buckets = {}
        
        print("🏗️ Creating Data Lake Structure...")
        
        for bucket_name in self.standard_buckets:
            full_name = f"{prefix}{bucket_name}" if prefix else bucket_name
            self.client.create_bucket(full_name)
            buckets[bucket_name] = full_name
            
            # Configure lifecycle policies based on bucket type
            if bucket_name == 'raw':
                self.client.add_lifecycle_rule(full_name, "", 'transition_to_archive', 30)
            elif bucket_name == 'archive':
                self.client.add_lifecycle_rule(full_name, "", 'expire', 365)
        
        print(f"✅ Data Lake initialized with {len(buckets)} buckets")
        return buckets
    
    def ingest_data(self, bucket: str, key: str, data: bytes,
                   metadata: Dict[str, str] = None) -> bool:
        """Ingest data into the data lake"""
        # Add standard metadata
        if metadata is None:
            metadata = {}
        
        metadata.update({
            'data_lake_ingested_at': datetime.now().isoformat(),
            'data_lake_layer': bucket
        })
        
        self.client.put_object(bucket, key, data, metadata=metadata)
        return True
    
    def process_data_layer(self, source_bucket: str, target_bucket: str,
                          prefix: str = "", transform_func=None) -> int:
        """Move data from one layer to another with optional transformation"""
        # List objects in source bucket
        objects = self.client.list_objects(source_bucket, prefix=prefix)
        
        processed = 0
        for obj in objects:
            # Get object
            data = self.client.get_object(source_bucket, obj.key)
            if data is None:
                continue
            
            # Apply transformation if provided
            if transform_func:
                try:
                    data = transform_func(data)
                except Exception as e:
                    print(f"❌ Transform failed for {obj.key}: {e}")
                    continue
            
            # Write to target bucket
            target_key = obj.key
            self.client.put_object(target_bucket, target_key, data)
            processed += 1
            
            # Optionally delete from source
            # self.client.delete_object(source_bucket, obj.key)
        
        print(f"📊 Processed {processed} objects from {source_bucket} to {target_bucket}")
        return processed
    
    def get_lake_status(self) -> Dict[str, Any]:
        """Get status of all data lake buckets"""
        status = {}
        
        for bucket in self.standard_buckets:
            objects = self.client.list_objects(bucket)
            size = sum(obj.size for obj in objects)
            
            status[bucket] = {
                'object_count': len(objects),
                'size_bytes': size,
                'size_gb': size / (1024 ** 3),
                'age_days': 0  # Would calculate from metadata
            }
        
        return status
```

---

## 4.3 Data Lake Implementation

### The Concept

A data lake is like a massive, flexible repository that can store structured, semi-structured, and unstructured data in its native format. Unlike a data warehouse, which requires data to be structured and organized before storage, a data lake enables "schema-on-read" - you define the structure when you read the data.

```
Data Lake Architecture:
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAKE LAYERS                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Layer 1: Raw / Landing Zone                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Raw data from sources as-is                        │  │
│  │  Files: JSON, CSV, Parquet, Avro, logs             │  │
│  │  Retention: 30 days                                │  │
│  └──────────────────────────────────────────────────────┘  │
│                         ▼                                   │
│  Layer 2: Staging Zone                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Validated, light cleaning                          │  │
│  │  Files: Parquet, Delta Lake, Iceberg               │  │
│  │  Retention: 90 days                                │  │
│  └──────────────────────────────────────────────────────┘  │
│                         ▼                                   │
│  Layer 3: Curated Zone                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Cleaned, enriched, standardized data              │  │
│  │  Files: Optimized Parquet, Delta tables            │  │
│  │  Retention: 1 year                                │  │
│  └──────────────────────────────────────────────────────┘  │
│                         ▼                                   │
│  Layer 4: Analytics Zone                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Aggregated, denormalized for analytics            │  │
│  │  Files: Pre-computed aggregates, views             │  │
│  │  Retention: 3 years                               │  │
│  └──────────────────────────────────────────────────────┘  │
│                         ▼                                   │
│  Layer 5: Archive Zone                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Cold storage for compliance and historical         │  │
│  │  Files: Compressed Parquet                         │  │
│  │  Retention: 7-10 years                             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### The Implementation

**File: `part-04-object-storage/data_lake_demo.py`**
```python
#!/usr/bin/env python3
"""
Data Lake Implementation Demonstration
"""

import json
import csv
import io
import time
import random
from datetime import datetime, timedelta
from typing import Dict, List, Any
import pandas as pd
import numpy as np

from object_storage_client import ObjectStorageClient, DataLakeBuilder

def generate_sample_orders(num_orders: int = 1000) -> bytes:
    """Generate sample order data"""
    data = []
    
    for i in range(num_orders):
        order = {
            'order_id': f"ORD-{i:06d}",
            'customer_id': random.randint(1, 1000),
            'order_date': (datetime.now() - timedelta(days=random.randint(0, 365))).isoformat(),
            'total_amount': round(random.uniform(10, 5000), 2),
            'status': random.choice(['pending', 'processing', 'shipped', 'delivered', 'cancelled']),
            'items_count': random.randint(1, 10),
            'payment_method': random.choice(['credit_card', 'paypal', 'bank_transfer']),
            'shipping_country': random.choice(['US', 'UK', 'CA', 'DE', 'FR', 'JP']),
            'is_fraud_risk': random.random() < 0.05
        }
        data.append(order)
    
    # Return as JSON
    return json.dumps(data).encode('utf-8')

def generate_sample_products(num_products: int = 100) -> bytes:
    """Generate sample product data"""
    categories = ['Electronics', 'Clothing', 'Books', 'Home & Garden', 'Sports', 'Toys']
    
    data = []
    for i in range(num_products):
        product = {
            'product_id': f"PROD-{i:05d}",
            'name': f"Product {i}",
            'category': random.choice(categories),
            'price': round(random.uniform(5, 999), 2),
            'cost': round(random.uniform(2, 500), 2),
            'weight_kg': round(random.uniform(0.1, 10), 2),
            'stock_quantity': random.randint(0, 100),
            'created_at': (datetime.now() - timedelta(days=random.randint(0, 730))).isoformat(),
            'is_active': random.random() < 0.8,
            'rating': round(random.uniform(1, 5), 1),
            'reviews_count': random.randint(0, 500)
        }
        data.append(product)
    
    # Return as CSV
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=data[0].keys())
    writer.writeheader()
    writer.writerows(data)
    
    return output.getvalue().encode('utf-8')

def generate_sample_customers(num_customers: int = 500) -> bytes:
    """Generate sample customer data"""
    countries = ['US', 'UK', 'CA', 'DE', 'FR', 'JP', 'AU', 'BR', 'IN']
    segments = ['Premium', 'Standard', 'Basic', 'Trial']
    
    data = []
    for i in range(num_customers):
        customer = {
            'customer_id': f"CUST-{i:05d}",
            'email': f"user{i}@example.com",
            'first_name': f"First{i}",
            'last_name': f"Last{i}",
            'country': random.choice(countries),
            'segment': random.choice(segments),
            'signup_date': (datetime.now() - timedelta(days=random.randint(0, 730))).isoformat(),
            'last_purchase_date': None if random.random() < 0.3 else 
                (datetime.now() - timedelta(days=random.randint(0, 180))).isoformat(),
            'lifetime_value': round(random.uniform(0, 10000), 2),
            'email_verified': random.random() < 0.7,
            'phone_verified': random.random() < 0.5
        }
        data.append(customer)
    
    return json.dumps(data).encode('utf-8')

def transform_to_parquet_simulation(data: bytes) -> bytes:
    """
    Simulate transformation to Parquet format.
    In production, this would use pyarrow or similar.
    """
    # For simulation, we just add a header
    header = b"PARQUET:"
    return header + data

def enrich_order_data(data: bytes) -> bytes:
    """Enrich order data with additional derived columns"""
    orders = json.loads(data.decode('utf-8'))
    
    for order in orders:
        # Add derived columns
        order['order_year'] = datetime.fromisoformat(order['order_date']).year
        order['order_month'] = datetime.fromisoformat(order['order_date']).month
        order['order_quarter'] = (order['order_month'] - 1) // 3 + 1
        
        # Add status flags
        order['is_delivered'] = order['status'] == 'delivered'
        order['is_cancelled'] = order['status'] == 'cancelled'
        
        # Add value tier
        if order['total_amount'] >= 1000:
            order['value_tier'] = 'high'
        elif order['total_amount'] >= 100:
            order['value_tier'] = 'medium'
        else:
            order['value_tier'] = 'low'
    
    return json.dumps(orders).encode('utf-8')

def demo_data_lake():
    """Demonstrate complete data lake implementation"""
    print("="*60)
    print("DATA LAKE IMPLEMENTATION DEMONSTRATION")
    print("="*60)
    
    # Initialize object storage client
    client = ObjectStorageClient(
        endpoint="http://localhost:9000",
        access_key="minioadmin",
        secret_key="minioadmin123"
    )
    
    # Initialize data lake
    lake = DataLakeBuilder(client)
    bucket_names = lake.initialize_data_lake(prefix="datalake-")
    
    print(f"\n📊 Data Lake Buckets Created:")
    for layer, bucket in bucket_names.items():
        print(f"   {layer}: {bucket}")
    
    # Ingest raw data
    print("\n📥 Ingesting Data...")
    
    # Generate sample data
    print("   Generating sample data...")
    orders_data = generate_sample_orders(1000)
    products_data = generate_sample_products(100)
    customers_data = generate_sample_customers(500)
    
    # Ingest to raw layer
    print("   Uploading to raw layer...")
    lake.ingest_data(
        bucket_names['raw'],
        "orders/2024/orders_2024_01.json",
        orders_data,
        metadata={'source': 'order_system', 'format': 'json'}
    )
    
    lake.ingest_data(
        bucket_names['raw'],
        "products/products_2024.csv",
        products_data,
        metadata={'source': 'product_catalog', 'format': 'csv'}
    )
    
    lake.ingest_data(
        bucket_names['raw'],
        "customers/customers_2024.json",
        customers_data,
        metadata={'source': 'crm', 'format': 'json'}
    )
    
    # Process to staging layer (validation and light cleaning)
    print("\n🔄 Processing to staging layer...")
    
    # Transform orders
    lake.process_data_layer(
        bucket_names['raw'],
        bucket_names['staging'],
        prefix="orders/",
        transform_func=enrich_order_data
    )
    
    # Transform products (convert CSV to Parquet simulation)
    lake.process_data_layer(
        bucket_names['raw'],
        bucket_names['staging'],
        prefix="products/",
        transform_func=transform_to_parquet_simulation
    )
    
    # Process to curated layer (enrichment and standardization)
    print("\n✨ Processing to curated layer...")
    
    # Copy orders to curated (simulating more transformations)
    lake.process_data_layer(
        bucket_names['staging'],
        bucket_names['curated'],
        prefix="orders/"
    )
    
    # Show storage usage
    print(f"\n📊 Storage Usage:")
    usage = client.get_storage_usage()
    print(f"   Total Objects: {usage['total_objects']}")
    print(f"   Total Size: {usage['total_size_gb']:.2f} GB")
    
    print(f"\n   Storage by Class:")
    for storage_class, size in usage['storage_by_class'].items():
        print(f"   {storage_class}: {size / (1024**3):.2f} GB")
    
    # Show lake status
    print(f"\n📈 Data Lake Status:")
    status = lake.get_lake_status()
    for layer, stats in status.items():
        print(f"   {layer}: {stats['object_count']} objects, {stats['size_gb']:.2f} GB")
    
    # Test retrieval
    print(f"\n🔍 Testing Data Retrieval:")
    
    # Get a sample order
    orders = client.list_objects(bucket_names['staging'], prefix="orders/")
    if orders:
        sample_key = orders[0].key
        data = client.get_object(bucket_names['staging'], sample_key)
        if data:
            decoded = data.decode('utf-8')
            if decoded.startswith('PARQUET:'):
                print(f"   Retrieved {sample_key} (Parquet format)")
            else:
                print(f"   Retrieved {sample_key} (JSON format)")
                # Show first 200 chars
                print(f"   Preview: {decoded[:200]}...")
    
    print("\n" + "="*60)
    print("✅ DATA LAKE DEMONSTRATION COMPLETE")
    print("="*60)
    
    return client, lake

def demo_lifecycle_management():
    """Demonstrate lifecycle management"""
    print("\n" + "="*60)
    print("LIFECYCLE MANAGEMENT DEMONSTRATION")
    print("="*60)
    
    client = ObjectStorageClient(
        endpoint="http://localhost:9000",
        access_key="minioadmin",
        secret_key="minioadmin123"
    )
    
    # Create a test bucket
    bucket_name = "lifecycle-test"
    client.create_bucket(bucket_name)
    
    # Add lifecycle rules
    print("\n♻️ Adding Lifecycle Rules:")
    client.add_lifecycle_rule(bucket_name, "logs/", "expire", 30)
    client.add_lifecycle_rule(bucket_name, "temp/", "expire", 7)
    client.add_lifecycle_rule(bucket_name, "archive/", "transition_to_archive", 90)
    
    # Upload test objects with different ages
    print("\n📤 Uploading test objects with different ages...")
    
    # Current date
    now = datetime.now()
    
    # Upload old objects (simulated)
    for i in range(5):
        key = f"logs/app_{i}.log"
        client.put_object(bucket_name, key, f"Log entry {i}".encode())
        # Simulate old modification date
        client.objects[bucket_name][key]['last_modified'] = now - timedelta(days=15 + i)
        
    for i in range(3):
        key = f"temp/temp_{i}.tmp"
        client.put_object(bucket_name, key, f"Temp data {i}".encode())
        client.objects[bucket_name][key]['last_modified'] = now - timedelta(days=3 + i)
    
    # Show objects before lifecycle
    print("\n📋 Objects before lifecycle policies:")
    objects = client.list_objects(bucket_name)
    for obj in objects:
        meta = client.get_object_metadata(bucket_name, obj.key)
        age = (datetime.now() - meta.last_modified).days
        print(f"   {obj.key}: {obj.size} bytes, {age} days old")
    
    # Apply lifecycle policies
    print("\n♻️ Applying lifecycle policies...")
    affected = client.apply_lifecycle_policies(bucket_name)
    
    # Show objects after lifecycle
    print("\n📋 Objects after lifecycle policies:")
    objects = client.list_objects(bucket_name)
    for obj in objects:
        meta = client.get_object_metadata(bucket_name, obj.key)
        print(f"   {obj.key}: {obj.size} bytes, storage: {meta.storage_class}")
    
    print("\n" + "="*60)
    print("✅ LIFECYCLE MANAGEMENT DEMONSTRATION COMPLETE")
    print("="*60)

def demo_storage_tiering():
    """Demonstrate storage tiering strategies"""
    print("\n" + "="*60)
    print("STORAGE TIERING STRATEGIES")
    print("="*60)
    
    print("\n📊 Storage Tier Comparison:")
    print("-" * 70)
    print(f"{'Tier':<15} {'Access Latency':<20} {'Cost/GB':<15} {'Use Case':<20}")
    print("-" * 70)
    
    tiers = [
        ('Hot', 'Milliseconds', 'High', 'Frequently accessed data'),
        ('Warm', 'Seconds', 'Medium', 'Monthly reporting'),
        ('Cold', 'Minutes-Hours', 'Low', 'Quarterly reporting'),
        ('Archive', 'Hours-Days', 'Very Low', 'Compliance, historical')
    ]
    
    for tier in tiers:
        print(f"{tier[0]:<15} {tier[1]:<20} {tier[2]:<15} {tier[3]:<20}")
    
    print("\n💡 Tiering Strategy Recommendations:")
    print("   - Hot: Recent data (last 30 days)")
    print("   - Warm: Last 90 days of data")
    print("   - Cold: 90-365 days old")
    print("   - Archive: >365 days old")
    
    print("\n📈 Cost-Optimized Tiering Plan:")
    print("   Day 0-30:  All data in HOT tier")
    print("   Day 30-90: Move to WARM tier")
    print("   Day 90-365: Move to COLD tier")
    print("   Day 365+: Move to ARCHIVE tier")
    print("   Estimated savings: 60-80% compared to all HOT tier")

def main():
    """Run all demonstrations"""
    print("="*60)
    print("CLOUD OBJECT STORAGE AND DATA LAKE FOUNDATIONS")
    print("="*60)
    
    # Run demonstrations
    demo_data_lake()
    demo_lifecycle_management()
    demo_storage_tiering()
    
    print("\n" + "="*60)
    print("✅ ALL DEMONSTRATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 4.4 Practical S3 Operations with MinIO

### The Concept

MinIO provides an S3-compatible object storage experience. Here we'll demonstrate practical operations using the MinIO client.

**File: `part-04-object-storage/minio_operations.py`**
```python
#!/usr/bin/env python3
"""
Practical S3/MinIO Operations
Demonstrates common S3 workflows
"""

import os
import sys
import json
import time
from typing import Dict, List, Any
import io
import csv
import tempfile

# Note: In production, you would use boto3
# For this tutorial, we use our simulation client

from object_storage_client import ObjectStorageClient

def demo_bucket_management():
    """Demonstrate bucket management operations"""
    print("="*60)
    print("BUCKET MANAGEMENT OPERATIONS")
    print("="*60)
    
    client = ObjectStorageClient(
        endpoint="http://localhost:9000",
        access_key="minioadmin",
        secret_key="minioadmin123"
    )
    
    # Create multiple buckets
    print("\n🪣 Creating buckets...")
    buckets = ['analytics', 'logs', 'backup', 'user-data']
    
    for bucket in buckets:
        client.create_bucket(bucket)
    
    # List buckets
    print(f"\n📋 Existing buckets: {client.list_buckets()}")
    
    # Create a bucket with specific region
    print("\n🌍 Creating bucket in specific region...")
    client.create_bucket('europe-data', region='eu-west-1')
    
    # Get bucket info (simulated)
    print(f"\n📊 Bucket: analytics")
    print(f"   Region: {client.buckets['analytics']['region']}")
    print(f"   Created: {client.buckets['analytics']['created_at']}")
    print(f"   Objects: {client.buckets['analytics']['object_count']}")
    
    print("\n" + "="*60)

def demo_file_operations():
    """Demonstrate file upload/download operations"""
    print("="*60)
    print("FILE OPERATIONS")
    print("="*60)
    
    client = ObjectStorageClient(
        endpoint="http://localhost:9000",
        access_key="minioadmin",
        secret_key="minioadmin123"
    )
    
    bucket = "user-data"
    client.create_bucket(bucket)
    
    # Upload multiple files
    print("\n📤 Uploading files...")
    
    file_data = {
        'users.csv': b'id,name,email\n1,Alice,alice@ex.com\n2,Bob,bob@ex.com',
        'config.json': b'{"version":"1.0","environment":"prod"}',
        'report.pdf': b'%PDF-1.4\n%Test PDF content',
        'logs/access.log': b'127.0.0.1 - - [01/Jan/2024] "GET /" 200',
        'logs/error.log': b'ERROR: Database connection failed'
    }
    
    for key, data in file_data.items():
        client.put_object(bucket, key, data)
    
    # List files with prefix
    print("\n📋 Listing files...")
    
    # All files
    objects = client.list_objects(bucket)
    print(f"   All objects: {[o.key for o in objects]}")
    
    # Files with prefix
    log_objects = client.list_objects(bucket, prefix="logs/")
    print(f"   Log files: {[o.key for o in log_objects]}")
    
    # Read a file
    print("\n📥 Reading a file...")
    config_data = client.get_object(bucket, "config.json")
    if config_data:
        config = json.loads(config_data)
        print(f"   Config: {config}")
    
    # Copy file
    print("\n📋 Copying file...")
    client.copy_object(bucket, "config.json", bucket, "config.backup.json")
    
    # Get file metadata
    print("\n📄 File metadata...")
    metadata = client.get_object_metadata(bucket, "users.csv")
    if metadata:
        print(f"   users.csv:")
        print(f"   Size: {metadata.size} bytes")
        print(f"   Type: {metadata.content_type}")
        print(f"   ETag: {metadata.etag}")
        print(f"   Modified: {metadata.last_modified}")
    
    # Presigned URL
    print("\n🔗 Generating presigned URL...")
    url = client.generate_presigned_url(bucket, "users.csv", expires_in=300)
    print(f"   URL: {url}")
    
    # Delete file
    print("\n🗑️ Deleting file...")
    client.delete_object(bucket, "config.backup.json")
    print(f"   Files after deletion: {[o.key for o in client.list_objects(bucket)]}")
    
    print("\n" + "="*60)

def demo_versioning():
    """Demonstrate object versioning"""
    print("="*60)
    print("OBJECT VERSIONING DEMONSTRATION")
    print("="*60)
    
    client = ObjectStorageClient(
        endpoint="http://localhost:9000",
        access_key="minioadmin",
        secret_key="minioadmin123"
    )
    
    bucket = "versioned-data"
    client.create_bucket(bucket)
    client.enable_versioning(bucket)
    
    print(f"\n🔢 Versioning enabled on: {bucket}")
    
    # Upload multiple versions of same file
    print("\n📤 Uploading multiple versions...")
    
    versions = [
        ('v1', b'Version 1 content'),
        ('v2', b'Version 2 content - updated'),
        ('v3', b'Version 3 content - final version')
    ]
    
    for version, data in versions:
        client.put_object(bucket, f"document.txt", data)
        print(f"   Uploaded {version}")
        time.sleep(0.1)  # Ensure different timestamps
    
    # List versions
    print("\n📋 Object versions:")
    versions = client.list_object_versions(bucket, "document.txt")
    for version in versions:
        deleted = "(deleted)" if version.get('is_deleted') else ""
        print(f"   {version['version_id']} - {version['size']} bytes {deleted}")
    
    # Delete (soft delete) with versioning
    print("\n🗑️ Soft deleting document...")
    client.delete_object(bucket, "document.txt")
    
    # Show versions after deletion
    print("\n📋 Versions after deletion:")
    versions = client.list_object_versions(bucket, "document.txt")
    for version in versions:
        deleted = "(deleted)" if version.get('is_deleted') else ""
        print(f"   {version['version_id']} - {version['size']} bytes {deleted}")
    
    print("\n" + "="*60)

def demo_batch_operations():
    """Demonstrate batch operations on objects"""
    print("="*60)
    print("BATCH OPERATIONS")
    print("="*60)
    
    client = ObjectStorageClient(
        endpoint="http://localhost:9000",
        access_key="minioadmin",
        secret_key="minioadmin123"
    )
    
    bucket = "batch-data"
    client.create_bucket(bucket)
    
    # Upload batch of files
    print("\n📤 Uploading batch of files...")
    
    for i in range(20):
        key = f"data/part_{i:04d}.json"
        data = json.dumps({
            'id': i,
            'timestamp': time.time(),
            'value': i * 100,
            'active': i % 2 == 0
        }).encode()
        client.put_object(bucket, key, data)
    
    # List in batches
    print(f"\n📋 Listing objects (first 5):")
    objects = client.list_objects(bucket, max_keys=5)
    for obj in objects:
        print(f"   {obj.key}: {obj.size} bytes")
    
    # Simulate batch download
    print("\n📥 Batch downloading...")
    downloaded = 0
    for obj in client.list_objects(bucket, prefix="data/"):
        data = client.get_object(bucket, obj.key)
        if data:
            downloaded += 1
    
    print(f"   Downloaded {downloaded} objects")
    
    # Batch delete
    print("\n🗑️ Batch deleting...")
    deleted = 0
    for obj in client.list_objects(bucket, prefix="data/"):
        if obj.key.endswith(('02', '05', '07')):
            client.delete_object(bucket, obj.key)
            deleted += 1
    
    print(f"   Deleted {deleted} objects")
    
    # Remaining objects
    print(f"\n📋 Remaining objects:")
    remaining = client.list_objects(bucket)
    print(f"   {len(remaining)} objects remain")
    for obj in remaining[:5]:
        print(f"   {obj.key}")
    
    print("\n" + "="*60)

def demo_prefix_optimization():
    """Demonstrate prefix optimization for performance"""
    print("="*60)
    print("PREFIX OPTIMIZATION FOR PERFORMANCE")
    print("="*60)
    
    print("\n📊 Prefix Organization Patterns:")
    print("-" * 50)
    
    print("Poor Prefix Strategy:")
    print("  s3://bucket/file1.csv")
    print("  s3://bucket/file2.csv")
    print("  s3://bucket/file3.csv")
    print("  ❌ All files in root - slow listing")
    
    print("\nGood Prefix Strategy:")
    print("  s3://bucket/year=2024/month=01/day=15/file1.csv")
    print("  s3://bucket/year=2024/month=01/day=15/file2.csv")
    print("  s3://bucket/year=2024/month=01/day=16/file3.csv")
    print("  ✅ Partitioned by time - fast filtering")
    
    print("\nExcellent Prefix Strategy:")
    print("  s3://bucket/")
    print("    ├── source=crm/")
    print("    │   └── year=2024/")
    print("    │       └── month=01/")
    print("    │           └── day=15/")
    print("    │               └── customers.parquet")
    print("    ├── source=orders/")
    print("    │   └── year=2024/")
    print("    │       └── month=01/")
    print("    │           └── day=15/")
    print("    │               └── orders.parquet")
    print("    └── source=logs/")
    print("        └── year=2024/")
    print("            └── month=01/")
    print("                └── day=15/")
    print("                    └── access.log")
    
    print("\n💡 Prefix Optimization Tips:")
    print("   1. Use 'key=value' patterns for partition elimination")
    print("   2. Avoid deep nesting (>5 levels)")
    print("   3. Use consistent date formats (YYYY/MM/DD)")
    print("   4. Group related data with common prefixes")
    
    print("\n" + "="*60)

def main():
    """Run all S3/MinIO demonstrations"""
    print("="*60)
    print("S3 COMPATIBLE OBJECT STORAGE OPERATIONS")
    print("="*60)
    
    # Run demonstrations
    demo_bucket_management()
    demo_file_operations()
    demo_versioning()
    demo_batch_operations()
    demo_prefix_optimization()
    
    print("\n" + "="*60)
    print("✅ ALL OPERATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-04-object-storage

# Start MinIO
docker-compose up -d

# Wait for MinIO to be ready
sleep 10

# Run the data lake demonstration
python data_lake_demo.py

# Run the MinIO operations demonstration
python minio_operations.py

# Expected output:
# ============================================================
# DATA LAKE IMPLEMENTATION DEMONSTRATION
# ============================================================
# 
# 🔗 Connected to object storage at http://localhost:9000
# 🪣 Created bucket: datalake-raw
# 🪣 Created bucket: datalake-staging
# 🪣 Created bucket: datalake-curated
# 🪣 Created bucket: datalake-analytics
# 🪣 Created bucket: datalake-archive
# ♻️ Added lifecycle rule: transition_to_archive objects with prefix '' after 30 days
# ♻️ Added lifecycle rule: expire objects with prefix '' after 365 days
# 
# 📊 Data Lake Buckets Created:
#    raw: datalake-raw
#    staging: datalake-staging
#    curated: datalake-curated
#    analytics: datalake-analytics
#    archive: datalake-archive
# 
# 📥 Ingesting Data...
#    Generating sample data...
#    Uploading to raw layer...
# 📤 Uploaded: datalake-raw/orders/2024/orders_2024_01.json (XXX bytes, application/json)
# 📤 Uploaded: datalake-raw/products/products_2024.csv (XXX bytes, text/csv)
# 📤 Uploaded: datalake-raw/customers/customers_2024.json (XXX bytes, application/json)
# 
# ✅ DATA LAKE DEMONSTRATION COMPLETE
# ============================================================
```

---

## Part 4 Recap

You have successfully:

✅ Implemented an S3-compatible object storage client  
✅ Built a complete data lake with multiple layers  
✅ Implemented lifecycle management policies  
✅ Configured versioning for data protection  
✅ Optimized storage with tiering strategies  
✅ Demonstrated practical S3 operations  
✅ Implemented prefix optimization for performance  
✅ Created batch operations for large-scale data processing  

### Key Takeaways

1. **Object Storage** provides infinite scalability with a flat namespace
2. **Data Lakes** enable schema-on-read for flexible data storage
3. **Lifecycle Policies** automate data movement and cost optimization
4. **Versioning** protects against accidental deletions and enables rollback
5. **Storage Tiering** optimizes costs based on access patterns
6. **Prefix Organization** is critical for performance and filtering
7. **Metadata** enables rich querying and data governance
