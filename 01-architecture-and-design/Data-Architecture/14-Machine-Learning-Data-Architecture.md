# Part 14: Machine Learning Data Architecture

Welcome to Part 14, where we explore how enterprise data platforms support artificial intelligence and machine learning. Think of ML data architecture like a manufacturing pipeline - raw materials (data) are processed through various stages (feature engineering, training, deployment) to produce finished products (models) that generate business value.

## Learning Objectives

By the end of this part, you will be able to:

- Design feature stores for ML
- Build training datasets and pipelines
- Implement ML data versioning
- Work with vector databases and embeddings
- Build Retrieval-Augmented Generation (RAG) systems
- Implement MLOps foundations

---

## 14.1 Feature Engineering and Feature Stores

### The Concept

Feature engineering transforms raw data into features that ML models can use. A feature store is like a centralized ingredient warehouse - it stores, manages, and serves features for both training and inference.

### The Implementation

**File: `part-14-ml-data-architecture/feature_store.py`**
```python
#!/usr/bin/env python3
"""
Feature Store Implementation
Centralized feature management for ML
"""

import time
import json
import hashlib
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime, timedelta
import numpy as np

@dataclass
class Feature:
    """A feature definition"""
    name: str
    description: str
    data_type: str  # int, float, string, boolean, vector
    source: str
    version: int
    created_at: float
    updated_at: float

@dataclass
class FeatureGroup:
    """A group of related features"""
    name: str
    description: str
    features: List[str]
    version: int
    created_at: float

@dataclass
class FeatureVector:
    """A feature vector for a specific entity"""
    entity_id: str
    features: Dict[str, Any]
    timestamp: float
    version: int

class FeatureStore:
    """
    Feature Store implementation
    """
    
    def __init__(self, name: str):
        self.name = name
        self.features: Dict[str, Feature] = {}
        self.feature_groups: Dict[str, FeatureGroup] = {}
        self.feature_vectors: Dict[str, List[FeatureVector]] = {}  # entity_id -> vectors
        self.metadata: Dict[str, Dict[str, Any]] = {}
        self.version_counter = 0
        
        print(f"🏪 Feature Store initialized: {name}")
    
    def register_feature(self, name: str, description: str,
                        data_type: str, source: str) -> str:
        """Register a new feature"""
        self.version_counter += 1
        
        feature = Feature(
            name=name,
            description=description,
            data_type=data_type,
            source=source,
            version=self.version_counter,
            created_at=time.time(),
            updated_at=time.time()
        )
        
        self.features[name] = feature
        print(f"   📝 Registered feature: {name} ({data_type})")
        return name
    
    def create_feature_group(self, name: str, description: str,
                            features: List[str]) -> str:
        """Create a feature group"""
        self.version_counter += 1
        
        # Validate features exist
        for f in features:
            if f not in self.features:
                print(f"   ⚠️ Feature {f} not found, creating...")
                self.register_feature(f, f"Auto-created for group {name}", "string", "unknown")
        
        group = FeatureGroup(
            name=name,
            description=description,
            features=features,
            version=self.version_counter,
            created_at=time.time()
        )
        
        self.feature_groups[name] = group
        print(f"   📦 Created feature group: {name} ({len(features)} features)")
        return name
    
    def ingest_feature_vector(self, entity_id: str,
                             features: Dict[str, Any]) -> bool:
        """Ingest a feature vector"""
        # Validate features
        for feature_name in features:
            if feature_name not in self.features:
                print(f"   ⚠️ Feature {feature_name} not registered")
                return False
        
        # Create feature vector
        vector = FeatureVector(
            entity_id=entity_id,
            features=features,
            timestamp=time.time(),
            version=self.version_counter
        )
        
        if entity_id not in self.feature_vectors:
            self.feature_vectors[entity_id] = []
        
        self.feature_vectors[entity_id].append(vector)
        
        print(f"   📥 Ingested features for {entity_id}: {len(features)} features")
        return True
    
    def get_features(self, entity_id: str, 
                     feature_names: List[str] = None,
                     timestamp: float = None) -> Optional[Dict[str, Any]]:
        """Get features for an entity"""
        if entity_id not in self.feature_vectors:
            return None
        
        vectors = self.feature_vectors[entity_id]
        
        # If timestamp provided, get latest before that time
        if timestamp:
            vectors = [v for v in vectors if v.timestamp <= timestamp]
        
        if not vectors:
            return None
        
        # Get the latest vector
        latest = max(vectors, key=lambda v: v.timestamp)
        
        if feature_names:
            return {name: latest.features.get(name) for name in feature_names}
        
        return latest.features
    
    def get_feature_group(self, group_name: str, 
                          entities: List[str]) -> Dict[str, Dict[str, Any]]:
        """Get features for multiple entities from a group"""
        if group_name not in self.feature_groups:
            return {}
        
        group = self.feature_groups[group_name]
        results = {}
        
        for entity_id in entities:
            features = self.get_features(entity_id, group.features)
            if features:
                results[entity_id] = features
        
        return results
    
    def get_feature_statistics(self, feature_name: str) -> Dict[str, Any]:
        """Get statistics for a feature"""
        if feature_name not in self.features:
            return {}
        
        values = []
        for vectors in self.feature_vectors.values():
            for v in vectors:
                if feature_name in v.features:
                    values.append(v.features[feature_name])
        
        if not values:
            return {'count': 0}
        
        # Convert to numpy for statistics
        # For demonstration, use Python statistics
        from statistics import mean, stdev
        
        if all(isinstance(v, (int, float)) for v in values):
            return {
                'count': len(values),
                'mean': mean(values),
                'stdev': stdev(values) if len(values) > 1 else 0,
                'min': min(values),
                'max': max(values)
            }
        else:
            # Categorical statistics
            categories = {}
            for v in values:
                categories[str(v)] = categories.get(str(v), 0) + 1
            
            return {
                'count': len(values),
                'unique_values': len(categories),
                'categories': categories
            }
    
    def get_store_stats(self) -> Dict[str, Any]:
        """Get feature store statistics"""
        return {
            'name': self.name,
            'features': len(self.features),
            'feature_groups': len(self.feature_groups),
            'entities': len(self.feature_vectors),
            'total_vectors': sum(len(v) for v in self.feature_vectors.values()),
            'version': self.version_counter
        }

def demo_feature_store():
    """Demonstrate feature store"""
    print("="*60)
    print("FEATURE STORE DEMONSTRATION")
    print("="*60)
    
    # Create feature store
    store = FeatureStore("Customer Feature Store")
    
    # Register features
    print("\n📝 Registering features...")
    
    store.register_feature(
        "total_spend",
        "Total amount spent by customer",
        "float",
        "transactions"
    )
    
    store.register_feature(
        "order_count",
        "Number of orders placed",
        "int",
        "transactions"
    )
    
    store.register_feature(
        "avg_order_value",
        "Average order value",
        "float",
        "transactions"
    )
    
    store.register_feature(
        "days_since_last_purchase",
        "Days since last purchase",
        "int",
        "transactions"
    )
    
    store.register_feature(
        "customer_segment",
        "Customer segment (Enterprise, SMB, Consumer)",
        "string",
        "crm"
    )
    
    store.register_feature(
        "engagement_score",
        "Customer engagement score",
        "float",
        "analytics"
    )
    
    # Create feature groups
    print("\n📦 Creating feature groups...")
    
    store.create_feature_group(
        "purchase_behavior",
        "Features related to purchase behavior",
        ["total_spend", "order_count", "avg_order_value", "days_since_last_purchase"]
    )
    
    store.create_feature_group(
        "customer_profile",
        "Customer demographic and profile features",
        ["customer_segment", "engagement_score"]
    )
    
    # Ingest feature vectors
    print("\n📥 Ingesting feature vectors...")
    
    # Generate sample customers
    customers = [
        ("CUST-001", {"total_spend": 5000.0, "order_count": 50, "avg_order_value": 100.0,
                     "days_since_last_purchase": 5, "customer_segment": "Enterprise",
                     "engagement_score": 0.95}),
        ("CUST-002", {"total_spend": 1500.0, "order_count": 20, "avg_order_value": 75.0,
                     "days_since_last_purchase": 15, "customer_segment": "SMB",
                     "engagement_score": 0.70}),
        ("CUST-003", {"total_spend": 300.0, "order_count": 5, "avg_order_value": 60.0,
                     "days_since_last_purchase": 30, "customer_segment": "Consumer",
                     "engagement_score": 0.40}),
        ("CUST-004", {"total_spend": 8000.0, "order_count": 80, "avg_order_value": 100.0,
                     "days_since_last_purchase": 2, "customer_segment": "Enterprise",
                     "engagement_score": 0.98}),
        ("CUST-005", {"total_spend": 800.0, "order_count": 10, "avg_order_value": 80.0,
                     "days_since_last_purchase": 20, "customer_segment": "SMB",
                     "engagement_score": 0.60})
    ]
    
    for customer_id, features in customers:
        store.ingest_feature_vector(customer_id, features)
    
    # Retrieve features
    print("\n🔍 Retrieving features...")
    
    # Get features for a single customer
    features = store.get_features("CUST-001")
    if features:
        print(f"\n   Features for CUST-001:")
        for name, value in features.items():
            print(f"      {name}: {value}")
    
    # Get feature group
    print(f"\n   Purchase behavior features for all customers:")
    group_data = store.get_feature_group("purchase_behavior", 
                                        ["CUST-001", "CUST-002", "CUST-003"])
    for entity_id, features in group_data.items():
        print(f"      {entity_id}: {features}")
    
    # Get feature statistics
    print(f"\n📊 Feature Statistics:")
    stats = store.get_feature_statistics("total_spend")
    print(f"   total_spend:")
    print(f"      Count: {stats['count']}")
    print(f"      Mean: {stats['mean']:.2f}")
    print(f"      Min: {stats['min']:.2f}")
    print(f"      Max: {stats['max']:.2f}")
    
    stats = store.get_feature_statistics("customer_segment")
    print(f"\n   customer_segment:")
    print(f"      Count: {stats['count']}")
    print(f"      Unique: {stats['unique_values']}")
    for category, count in stats['categories'].items():
        print(f"      {category}: {count}")
    
    # Show store stats
    stats = store.get_store_stats()
    print(f"\n📊 Feature Store Statistics:")
    print(f"   Features: {stats['features']}")
    print(f"   Feature Groups: {stats['feature_groups']}")
    print(f"   Entities: {stats['entities']}")
    print(f"   Total Vectors: {stats['total_vectors']}")

def main():
    """Run feature store demonstration"""
    demo_feature_store()
    
    print("\n" + "="*60)
    print("✅ FEATURE STORE DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 14.2 Vector Databases and Embeddings

### The Concept

Vector databases store and search high-dimensional vectors (embeddings). Think of it like finding similar items in a high-dimensional space - embeddings capture semantic meaning, and vector search finds items that are "close" in this space.

### The Implementation

**File: `part-14-ml-data-architecture/vector_database.py`**
```python
#!/usr/bin/env python3
"""
Vector Database and Embedding Implementation
"""

import time
import json
import math
import random
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
import hashlib

@dataclass
class Vector:
    """A vector with metadata"""
    id: str
    values: List[float]
    metadata: Dict[str, Any]
    timestamp: float

class VectorDatabase:
    """
    Vector database implementation
    Supports similarity search and nearest neighbor queries
    """
    
    def __init__(self, name: str, dimension: int = 128):
        self.name = name
        self.dimension = dimension
        self.vectors: Dict[str, Vector] = {}
        self.index: Dict[str, List[str]] = {}  # Simple index for demonstration
        self.query_count = 0
        self.average_query_time = 0
        
        print(f"🔢 Vector Database initialized: {name} (dim={dimension})")
    
    def insert(self, vector_id: str, values: List[float],
               metadata: Dict[str, Any] = None) -> bool:
        """Insert a vector"""
        if len(values) != self.dimension:
            print(f"   ⚠️ Vector dimension mismatch: expected {self.dimension}, got {len(values)}")
            return False
        
        if metadata is None:
            metadata = {}
        
        vector = Vector(
            id=vector_id,
            values=values,
            metadata=metadata,
            timestamp=time.time()
        )
        
        self.vectors[vector_id] = vector
        
        # Build simple index (partition by first dimension for demo)
        partition = self._get_partition(values)
        if partition not in self.index:
            self.index[partition] = []
        self.index[partition].append(vector_id)
        
        print(f"   📥 Inserted vector: {vector_id} (dim={len(values)})")
        return True
    
    def _get_partition(self, values: List[float]) -> str:
        """Get partition for a vector (simple hashing)"""
        # Use first dimension to create partitions
        first_val = values[0] if values else 0
        partition = int(first_val * 10) % 10
        return f"partition_{partition}"
    
    def similarity_search(self, query_vector: List[float],
                         top_k: int = 10,
                         filter_metadata: Dict[str, Any] = None) -> List[Tuple[str, float, Dict[str, Any]]]:
        """Find similar vectors"""
        start_time = time.time()
        self.query_count += 1
        
        if len(query_vector) != self.dimension:
            print(f"   ⚠️ Query dimension mismatch")
            return []
        
        # Find candidate vectors (use partition for filtering)
        partition = self._get_partition(query_vector)
        candidates = self.index.get(partition, [])
        
        # If no candidates in partition, search all
        if not candidates:
            candidates = list(self.vectors.keys())
        
        # Calculate similarities
        similarities = []
        for vector_id in candidates:
            vector = self.vectors[vector_id]
            
            # Apply metadata filter
            if filter_metadata:
                match = True
                for key, value in filter_metadata.items():
                    if vector.metadata.get(key) != value:
                        match = False
                        break
                if not match:
                    continue
            
            # Calculate cosine similarity
            similarity = self._cosine_similarity(query_vector, vector.values)
            similarities.append((vector_id, similarity, vector.metadata))
        
        # Sort by similarity (descending)
        similarities.sort(key=lambda x: x[1], reverse=True)
        
        elapsed = time.time() - start_time
        self.average_query_time = (self.average_query_time * (self.query_count - 1) + elapsed) / self.query_count
        
        return similarities[:top_k]
    
    def _cosine_similarity(self, v1: List[float], v2: List[float]) -> float:
        """Calculate cosine similarity between two vectors"""
        dot_product = sum(a * b for a, b in zip(v1, v2))
        norm1 = math.sqrt(sum(a * a for a in v1))
        norm2 = math.sqrt(sum(b * b for b in v2))
        
        if norm1 == 0 or norm2 == 0:
            return 0
        
        return dot_product / (norm1 * norm2)
    
    def get_vector(self, vector_id: str) -> Optional[Vector]:
        """Get a vector by ID"""
        return self.vectors.get(vector_id)
    
    def delete_vector(self, vector_id: str) -> bool:
        """Delete a vector"""
        if vector_id not in self.vectors:
            return False
        
        vector = self.vectors[vector_id]
        partition = self._get_partition(vector.values)
        if partition in self.index:
            self.index[partition].remove(vector_id)
        
        del self.vectors[vector_id]
        print(f"   🗑️ Deleted vector: {vector_id}")
        return True
    
    def get_stats(self) -> Dict[str, Any]:
        """Get database statistics"""
        return {
            'name': self.name,
            'dimension': self.dimension,
            'vector_count': len(self.vectors),
            'partition_count': len(self.index),
            'query_count': self.query_count,
            'avg_query_time_ms': self.average_query_time * 1000
        }

class EmbeddingGenerator:
    """
    Generates embeddings (simulated)
    """
    
    def __init__(self, dimension: int = 128):
        self.dimension = dimension
    
    def generate_embedding(self, text: str) -> List[float]:
        """Generate an embedding for text (simulated)"""
        # In practice, this would use a model like BERT, Sentence-BERT, etc.
        # For demonstration, generate deterministic embedding based on text hash
        
        # Create deterministic seed from text
        hash_bytes = hashlib.sha256(text.encode()).digest()
        seed = int.from_bytes(hash_bytes[:8], 'big')
        random.seed(seed)
        
        # Generate random vector
        embedding = [random.uniform(-1, 1) for _ in range(self.dimension)]
        
        # Normalize
        norm = math.sqrt(sum(x * x for x in embedding))
        embedding = [x / norm for x in embedding]
        
        return embedding
    
    def generate_embeddings(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings for multiple texts"""
        return [self.generate_embedding(text) for text in texts]

def demo_vector_database():
    """Demonstrate vector database"""
    print("="*60)
    print("VECTOR DATABASE DEMONSTRATION")
    print("="*60)
    
    # Create vector database
    vdb = VectorDatabase("Product Embeddings", dimension=128)
    
    # Create embedding generator
    embedder = EmbeddingGenerator(128)
    
    # Generate product descriptions
    print("\n📝 Generating product embeddings...")
    
    products = [
        {"id": "P001", "name": "Laptop", "description": "High-performance laptop with 16GB RAM"},
        {"id": "P002", "name": "Smartphone", "description": "Latest smartphone with 5G connectivity"},
        {"id": "P003", "name": "Headphones", "description": "Wireless noise-cancelling headphones"},
        {"id": "P004", "name": "Monitor", "description": "4K ultra-wide monitor for productivity"},
        {"id": "P005", "name": "Keyboard", "description": "Mechanical keyboard with RGB lighting"},
        {"id": "P006", "name": "Tablet", "description": "Lightweight tablet for reading and browsing"},
        {"id": "P007", "name": "Smartwatch", "description": "Fitness tracking smartwatch with GPS"},
        {"id": "P008", "name": "Printer", "description": "Wireless all-in-one printer with scanner"}
    ]
    
    for product in products:
        # Generate embedding from description
        embedding = embedder.generate_embedding(product['description'])
        
        # Store in database
        vdb.insert(
            vector_id=product['id'],
            values=embedding,
            metadata={"name": product['name'], "description": product['description']}
        )
    
    print(f"   Loaded {len(products)} product embeddings")
    
    # Search for similar products
    print("\n🔍 Searching for similar products...")
    
    # Query: "gaming laptop with good performance"
    query_text = "gaming laptop with good performance"
    query_embedding = embedder.generate_embedding(query_text)
    
    results = vdb.similarity_search(query_embedding, top_k=3)
    
    print(f"\n   Query: '{query_text}'")
    print(f"   Found {len(results)} similar products:")
    for vector_id, similarity, metadata in results:
        name = metadata.get('name', 'Unknown')
        print(f"      {name} (similarity: {similarity:.3f})")
    
    # Query: "wireless audio devices"
    print(f"\n   Query: 'wireless audio devices'")
    query_embedding = embedder.generate_embedding("wireless audio devices")
    
    results = vdb.similarity_search(query_embedding, top_k=3)
    for vector_id, similarity, metadata in results:
        name = metadata.get('name', 'Unknown')
        print(f"      {name} (similarity: {similarity:.3f})")
    
    # Show statistics
    stats = vdb.get_stats()
    print(f"\n📊 Vector Database Statistics:")
    print(f"   Name: {stats['name']}")
    print(f"   Vectors: {stats['vector_count']}")
    print(f"   Partitions: {stats['partition_count']}")
    print(f"   Queries: {stats['query_count']}")
    print(f"   Avg Query Time: {stats['avg_query_time_ms']:.2f}ms")

def main():
    """Run vector database demonstration"""
    demo_vector_database()
    
    print("\n" + "="*60)
    print("✅ VECTOR DATABASE DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 14.3 Retrieval-Augmented Generation (RAG)

### The Concept

RAG combines retrieval and generation. Think of it like having an assistant who knows a lot (LLM) but also has a reference library (knowledge base) they can look things up in before answering.

### The Implementation

**File: `part-14-ml-data-architecture/rag_system.py`**
```python
#!/usr/bin/env python3
"""
Retrieval-Augmented Generation (RAG) System Implementation
"""

import time
import json
import random
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
from vector_database import VectorDatabase, EmbeddingGenerator

@dataclass
class Document:
    """A document in the knowledge base"""
    doc_id: str
    content: str
    metadata: Dict[str, Any]
    embedding: List[float] = None

class RAGSystem:
    """
    Retrieval-Augmented Generation system
    Combines retrieval with LLM generation
    """
    
    def __init__(self, name: str, model_name: str = "GPT-4"):
        self.name = name
        self.model_name = model_name
        self.knowledge_base: Dict[str, Document] = {}
        self.vector_db = VectorDatabase(f"{name}_vectors", dimension=128)
        self.embedder = EmbeddingGenerator(128)
        self.chat_history: List[Dict[str, str]] = []
        self.context_cache: Dict[str, List[str]] = {}
        
        print(f"🤖 RAG System initialized: {name}")
        print(f"   Model: {model_name}")
    
    def add_document(self, doc_id: str, content: str,
                     metadata: Dict[str, Any] = None) -> bool:
        """Add a document to the knowledge base"""
        if metadata is None:
            metadata = {}
        
        # Generate embedding
        embedding = self.embedder.generate_embedding(content)
        
        # Store document
        doc = Document(
            doc_id=doc_id,
            content=content,
            metadata=metadata,
            embedding=embedding
        )
        self.knowledge_base[doc_id] = doc
        
        # Store in vector database
        self.vector_db.insert(
            vector_id=doc_id,
            values=embedding,
            metadata={**metadata, "content": content[:100]}
        )
        
        print(f"   📄 Added document: {doc_id}")
        return True
    
    def retrieve_context(self, query: str, top_k: int = 3) -> List[Document]:
        """Retrieve relevant documents for a query"""
        # Generate query embedding
        query_embedding = self.embedder.generate_embedding(query)
        
        # Search in vector database
        results = self.vector_db.similarity_search(query_embedding, top_k=top_k)
        
        # Retrieve full documents
        documents = []
        for vector_id, similarity, metadata in results:
            if vector_id in self.knowledge_base:
                doc = self.knowledge_base[vector_id]
                documents.append(doc)
                print(f"   📖 Retrieved: {doc.doc_id} (sim: {similarity:.3f})")
        
        return documents
    
    def generate_response(self, query: str, context: List[Document]) -> str:
        """Generate a response using retrieved context"""
        # In a real system, this would call an LLM API
        # For demonstration, we simulate the response
        
        # Build prompt
        context_text = "\n\n".join([f"Document {i+1}: {doc.content}" 
                                   for i, doc in enumerate(context)])
        
        # Simulate LLM response
        response = f"Based on the provided context, here is the response:\n\n"
        
        if context:
            # Extract relevant information from context
            first_doc = context[0]
            response += f"From Document {first_doc.doc_id}:\n"
            response += f"{first_doc.content[:200]}...\n\n"
            
            if len(context) > 1:
                response += f"Additional context from {len(context)-1} other documents.\n"
        else:
            response += "I couldn't find relevant information in the knowledge base."
        
        response += f"\n\n(Response generated using {self.model_name})"
        
        return response
    
    def query(self, query: str, top_k: int = 3) -> Dict[str, Any]:
        """Process a query through the RAG system"""
        print(f"\n🔍 Processing query: '{query}'")
        
        # Retrieve relevant documents
        print("\n   Retrieving context...")
        context = self.retrieve_context(query, top_k)
        
        # Generate response
        print("\n   Generating response...")
        response = self.generate_response(query, context)
        
        # Store in chat history
        self.chat_history.append({
            "query": query,
            "response": response,
            "timestamp": time.time(),
            "context_docs": [doc.doc_id for doc in context]
        })
        
        return {
            "query": query,
            "response": response,
            "context": [{"id": doc.doc_id, "content": doc.content[:200] + "..."} 
                       for doc in context],
            "timestamp": time.time()
        }
    
    def add_to_knowledge_base(self, docs: List[Tuple[str, str, Dict[str, Any]]]):
        """Add multiple documents to knowledge base"""
        for doc_id, content, metadata in docs:
            self.add_document(doc_id, content, metadata)
    
    def get_chat_history(self, limit: int = 10) -> List[Dict[str, str]]:
        """Get chat history"""
        return self.chat_history[-limit:]
    
    def get_stats(self) -> Dict[str, Any]:
        """Get system statistics"""
        return {
            'name': self.name,
            'model': self.model_name,
            'documents': len(self.knowledge_base),
            'chat_history': len(self.chat_history),
            'vector_db_stats': self.vector_db.get_stats()
        }

def demo_rag():
    """Demonstrate RAG system"""
    print("="*60)
    print("RETRIEVAL-AUGMENTED GENERATION DEMONSTRATION")
    print("="*60)
    
    # Create RAG system
    rag = RAGSystem("Customer Support RAG", model_name="GPT-4")
    
    # Add documents to knowledge base
    print("\n📚 Building knowledge base...")
    
    documents = [
        ("DOC001", 
         "Product return policy: Customers can return products within 30 days of purchase for a full refund. "
         "Products must be in original condition with all accessories. "
         "To initiate a return, contact customer support with your order number.",
         {"category": "policy", "type": "return"}),
        
        ("DOC002",
         "Shipping information: Standard shipping takes 3-5 business days. "
         "Express shipping is available for an additional fee and takes 1-2 business days. "
         "Free shipping on orders over $50.",
         {"category": "shipping", "type": "info"}),
        
        ("DOC003",
         "Warranty coverage: All products come with a 1-year limited warranty. "
         "The warranty covers manufacturing defects and hardware malfunctions. "
         "Warranty does not cover damage from accidents, misuse, or unauthorized modifications.",
         {"category": "warranty", "type": "coverage"}),
        
        ("DOC004",
         "Customer support hours: Support is available Monday-Friday, 9:00 AM - 6:00 PM EST. "
         "Email support typically responds within 24 hours. "
         "Phone support is available at 1-800-555-0199.",
         {"category": "support", "type": "hours"}),
        
        ("DOC005",
         "Account management: Customers can update their profile, payment methods, "
         "and shipping addresses through the account dashboard. "
         "Password resets can be initiated through the login page using the 'Forgot Password' link.",
         {"category": "account", "type": "management"})
    ]
    
    for doc_id, content, metadata in documents:
        rag.add_document(doc_id, content, metadata)
    
    # Process queries
    print("\n💬 Processing queries...")
    
    queries = [
        "How do I return a product?",
        "What is the shipping time for standard delivery?",
        "Does the warranty cover accidental damage?",
        "How can I reset my password?"
    ]
    
    for query in queries:
        result = rag.query(query)
        print(f"\n💬 Query: {query}")
        print(f"🤖 Response: {result['response']}")
        print(f"📚 Context used: {len(result['context'])} documents")
        time.sleep(0.5)
    
    # Show statistics
    stats = rag.get_stats()
    print(f"\n📊 RAG System Statistics:")
    print(f"   Name: {stats['name']}")
    print(f"   Model: {stats['model']}")
    print(f"   Documents: {stats['documents']}")
    print(f"   Chat History: {stats['chat_history']}")
    print(f"   Vector DB Stats:")
    print(f"      Vectors: {stats['vector_db_stats']['vector_count']}")
    print(f"      Avg Query Time: {stats['vector_db_stats']['avg_query_time_ms']:.2f}ms")

def main():
    """Run RAG demonstration"""
    demo_rag()
    
    print("\n" + "="*60)
    print("✅ RAG DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-14-ml-data-architecture

# Run the feature store demonstration
python feature_store.py

# Run the vector database demonstration
python vector_database.py

# Run the RAG system demonstration
python rag_system.py

# Expected output:
# ============================================================
# FEATURE STORE DEMONSTRATION
# ============================================================
# 
# 🏪 Feature Store initialized: Customer Feature Store
# 
# 📝 Registering features...
#    📝 Registered feature: total_spend (float)
#    📝 Registered feature: order_count (int)
#    📝 Registered feature: avg_order_value (float)
#    📝 Registered feature: days_since_last_purchase (int)
#    📝 Registered feature: customer_segment (string)
#    📝 Registered feature: engagement_score (float)
# 
# 📦 Creating feature groups...
#    📦 Created feature group: purchase_behavior (4 features)
#    📦 Created feature group: customer_profile (2 features)
# 
# 📥 Ingesting feature vectors...
#    📥 Ingested features for CUST-001: 6 features
#    📥 Ingested features for CUST-002: 6 features
#    📥 Ingested features for CUST-003: 6 features
#    📥 Ingested features for CUST-004: 6 features
#    📥 Ingested features for CUST-005: 6 features
# 
# 🔍 Retrieving features...
# 
#    Features for CUST-001:
#       total_spend: 5000.0
#       order_count: 50
#       avg_order_value: 100.0
#       days_since_last_purchase: 5
#       customer_segment: Enterprise
#       engagement_score: 0.95
# 
# 📊 Feature Store Statistics:
#    Features: 6
#    Feature Groups: 2
#    Entities: 5
#    Total Vectors: 5
# 
# ============================================================
# ✅ FEATURE STORE DEMONSTRATION COMPLETE
# ============================================================
```

---

## Part 14 Recap

You have successfully:

✅ Implemented a feature store for ML features  
✅ Registered features and created feature groups  
✅ Ingested and retrieved feature vectors  
✅ Built a vector database for embeddings  
✅ Implemented similarity search  
✅ Created a Retrieval-Augmented Generation (RAG) system  
✅ Built a knowledge base with embeddings  
✅ Implemented context retrieval and response generation  

### Key Takeaways

1. **Feature Stores** centralize feature management for ML
2. **Features** are the building blocks of ML models
3. **Feature Groups** organize related features
4. **Vector Databases** enable similarity search on embeddings
5. **Embeddings** capture semantic meaning in high-dimensional space
6. **RAG** combines retrieval with LLM generation
7. **Knowledge Bases** store domain-specific information
8. **Context Retrieval** finds relevant information for generation
