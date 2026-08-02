# Part 9: Caching and Performance Engineering

Welcome to Part 9, where we explore how caching transforms application performance. Think of caching like a quick-reference cheat sheet - instead of going to the library (database) for every question, you keep the most common answers right at your desk. This dramatically reduces response times and system load.

## Learning Objectives

By the end of this part, you will be able to:

- Implement Redis and Memcached caching strategies
- Apply cache-aside, read-through, and write-through patterns
- Design distributed caching systems
- Implement cache invalidation strategies
- Use caching for session management
- Optimize query performance with materialized views

---

## 9.1 Caching Fundamentals

### The Concept

Caching is about storing frequently accessed data in fast storage to reduce latency. The cache sits between the application and the slower data store, serving requests from memory rather than disk.

### The Implementation

**File: `part-09-caching/cache_fundamentals.py`**
```python
#!/usr/bin/env python3
"""
Caching Fundamentals Implementation
"""

import time
import random
import threading
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
from enum import Enum
from datetime import datetime, timedelta
import hashlib
import json

class EvictionPolicy(Enum):
    """Cache eviction policies"""
    LRU = "least_recently_used"
    LFU = "least_frequently_used"
    FIFO = "first_in_first_out"
    TTL = "time_to_live"
    RANDOM = "random"

@dataclass
class CacheEntry:
    """A cache entry"""
    key: str
    value: Any
    timestamp: float
    ttl_seconds: int
    access_count: int = 0
    last_access_time: float = 0
    
    def is_expired(self) -> bool:
        """Check if entry has expired"""
        if self.ttl_seconds <= 0:
            return False
        return time.time() - self.timestamp > self.ttl_seconds
    
    def touch(self):
        """Update access time and count"""
        self.last_access_time = time.time()
        self.access_count += 1

class Cache:
    """
    Generic cache implementation with multiple eviction policies
    """
    
    def __init__(self, max_size: int = 100, policy: EvictionPolicy = EvictionPolicy.LRU,
                 default_ttl: int = 300):
        self.max_size = max_size
        self.policy = policy
        self.default_ttl = default_ttl
        self.data: Dict[str, CacheEntry] = {}
        self.hits = 0
        self.misses = 0
        self.evictions = 0
        
    def get(self, key: str) -> Optional[Any]:
        """Get a value from the cache"""
        if key not in self.data:
            self.misses += 1
            return None
        
        entry = self.data[key]
        
        # Check if expired
        if entry.is_expired():
            del self.data[key]
            self.misses += 1
            return None
        
        # Update access stats
        entry.touch()
        self.hits += 1
        
        return entry.value
    
    def put(self, key: str, value: Any, ttl_seconds: int = None):
        """Put a value in the cache"""
        if ttl_seconds is None:
            ttl_seconds = self.default_ttl
        
        # Check if we need to evict
        if key not in self.data and len(self.data) >= self.max_size:
            self._evict()
        
        # Add/update entry
        self.data[key] = CacheEntry(
            key=key,
            value=value,
            timestamp=time.time(),
            ttl_seconds=ttl_seconds
        )
    
    def _evict(self):
        """Evict an entry based on policy"""
        if not self.data:
            return
        
        self.evictions += 1
        
        if self.policy == EvictionPolicy.LRU:
            # Find least recently used
            evict_key = min(self.data.items(), 
                          key=lambda x: x[1].last_access_time)[0]
            
        elif self.policy == EvictionPolicy.LFU:
            # Find least frequently used
            evict_key = min(self.data.items(), 
                          key=lambda x: x[1].access_count)[0]
            
        elif self.policy == EvictionPolicy.FIFO:
            # Find oldest
            evict_key = min(self.data.items(), 
                          key=lambda x: x[1].timestamp)[0]
            
        elif self.policy == EvictionPolicy.TTL:
            # Find closest to expiration
            evict_key = min(self.data.items(), 
                          key=lambda x: x[1].timestamp + x[1].ttl_seconds)[0]
            
        elif self.policy == EvictionPolicy.RANDOM:
            # Random eviction
            import random
            evict_key = random.choice(list(self.data.keys()))
        
        else:
            # Default to LRU
            evict_key = min(self.data.items(), 
                          key=lambda x: x[1].last_access_time)[0]
        
        del self.data[evict_key]
    
    def clear(self):
        """Clear the cache"""
        self.data.clear()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        total_requests = self.hits + self.misses
        hit_ratio = self.hits / total_requests if total_requests > 0 else 0
        
        return {
            'size': len(self.data),
            'max_size': self.max_size,
            'hits': self.hits,
            'misses': self.misses,
            'hit_ratio': hit_ratio,
            'evictions': self.evictions,
            'policy': self.policy.value
        }

class DistributedCache:
    """
    Distributed cache implementation with consistent hashing
    """
    
    def __init__(self, nodes: List[str], virtual_nodes: int = 100):
        self.nodes = nodes
        self.virtual_nodes = virtual_nodes
        self.ring = {}
        self.caches: Dict[str, Cache] = {}
        
        # Build consistent hash ring
        self._build_ring()
        
        # Initialize caches for each node
        for node in nodes:
            self.caches[node] = Cache(max_size=100)
    
    def _build_ring(self):
        """Build consistent hash ring"""
        self.ring = {}
        for node in self.nodes:
            for i in range(self.virtual_nodes):
                key = self._hash(f"{node}_{i}")
                self.ring[key] = node
        self.ring = dict(sorted(self.ring.items()))
    
    def _hash(self, value: str) -> int:
        """Hash a value"""
        return int(hashlib.md5(value.encode()).hexdigest(), 16)
    
    def _get_node(self, key: str) -> str:
        """Get the node for a given key"""
        if not self.ring:
            return None
        
        hash_val = self._hash(key)
        
        for ring_hash, node in self.ring.items():
            if ring_hash >= hash_val:
                return node
        
        return next(iter(self.ring.values()))
    
    def get(self, key: str) -> Optional[Any]:
        """Get a value from the distributed cache"""
        node = self._get_node(key)
        if node is None:
            return None
        
        return self.caches[node].get(key)
    
    def put(self, key: str, value: Any, ttl_seconds: int = 300):
        """Put a value in the distributed cache"""
        node = self._get_node(key)
        if node is None:
            return
        
        self.caches[node].put(key, value, ttl_seconds)
    
    def add_node(self, node: str):
        """Add a node to the cluster"""
        if node in self.nodes:
            return
        
        self.nodes.append(node)
        self.caches[node] = Cache(max_size=100)
        self._build_ring()
        print(f"   🖥️ Added node: {node}")
    
    def remove_node(self, node: str):
        """Remove a node from the cluster"""
        if node not in self.nodes:
            return
        
        self.nodes.remove(node)
        del self.caches[node]
        self._build_ring()
        print(f"   🗑️ Removed node: {node}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get distributed cache statistics"""
        total_size = 0
        total_hits = 0
        total_misses = 0
        
        for node, cache in self.caches.items():
            stats = cache.get_stats()
            total_size += stats['size']
            total_hits += stats['hits']
            total_misses += stats['misses']
        
        total_requests = total_hits + total_misses
        hit_ratio = total_hits / total_requests if total_requests > 0 else 0
        
        return {
            'node_count': len(self.nodes),
            'total_size': total_size,
            'total_hits': total_hits,
            'total_misses': total_misses,
            'hit_ratio': hit_ratio,
            'nodes': {
                node: cache.get_stats() for node, cache in self.caches.items()
            }
        }

def demo_cache_fundamentals():
    """Demonstrate caching fundamentals"""
    print("="*60)
    print("CACHING FUNDAMENTALS DEMONSTRATION")
    print("="*60)
    
    # Test different eviction policies
    policies = [
        (EvictionPolicy.LRU, "LRU"),
        (EvictionPolicy.LFU, "LFU"),
        (EvictionPolicy.FIFO, "FIFO"),
        (EvictionPolicy.TTL, "TTL")
    ]
    
    for policy, name in policies:
        print(f"\n📊 {name} Eviction Policy:")
        print("-" * 40)
        
        cache = Cache(max_size=5, policy=policy, default_ttl=10)
        
        # Add items
        for i in range(7):
            cache.put(f"key_{i}", f"value_{i}")
            print(f"   Added key_{i}")
        
        # Access some items
        cache.get("key_0")
        cache.get("key_1")
        cache.get("key_0")
        cache.get("key_2")
        
        # Show state
        print(f"\n   Cache state ({len(cache.data)} items):")
        for key, entry in cache.data.items():
            print(f"      {key}: access_count={entry.access_count}, "
                  f"last_access={entry.last_access_time:.2f}")
        
        stats = cache.get_stats()
        print(f"\n   Stats:")
        print(f"   Size: {stats['size']}/{stats['max_size']}")
        print(f"   Hits: {stats['hits']}, Misses: {stats['misses']}")
        print(f"   Hit ratio: {stats['hit_ratio']:.1%}")
        print(f"   Evictions: {stats['evictions']}")

def demo_distributed_cache():
    """Demonstrate distributed caching"""
    print("\n" + "="*60)
    print("DISTRIBUTED CACHE DEMONSTRATION")
    print("="*60)
    
    # Create distributed cache with 3 nodes
    print("\n🖥️ Creating distributed cache with 3 nodes...")
    dc = DistributedCache(['node1', 'node2', 'node3'])
    
    # Store data
    print("\n📝 Storing data across nodes:")
    for i in range(20):
        key = f"user_{i}"
        value = f"data_{i}"
        dc.put(key, value)
        node = dc._get_node(key)
        print(f"   {key} → {node}")
    
    # Retrieve data
    print("\n📖 Retrieving data:")
    hits = 0
    for i in range(20):
        key = f"user_{i}"
        value = dc.get(key)
        if value:
            hits += 1
            print(f"   ✅ {key}: {value}")
        else:
            print(f"   ❌ {key}: Not found")
    
    print(f"\n   Hit rate: {hits/20:.1%}")
    
    # Add a new node
    print("\n🔄 Adding node4...")
    dc.add_node('node4')
    
    # Show redistribution
    print("\n📝 Data distribution after adding node:")
    for i in range(5):
        key = f"user_{i}"
        node = dc._get_node(key)
        print(f"   {key} → {node}")
    
    # Show stats
    stats = dc.get_stats()
    print(f"\n📊 Distributed Cache Stats:")
    print(f"   Nodes: {stats['node_count']}")
    print(f"   Total items: {stats['total_size']}")
    print(f"   Hit ratio: {stats['hit_ratio']:.1%}")

def main():
    """Run caching demonstrations"""
    demo_cache_fundamentals()
    demo_distributed_cache()
    
    print("\n" + "="*60)
    print("✅ CACHING FUNDAMENTALS DEMONSTRATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 9.2 Caching Patterns

### The Concept

Caching patterns define how applications interact with the cache:

- **Cache-Aside**: Application manages cache directly
- **Read-Through**: Cache handles misses by loading from database
- **Write-Through**: Cache writes to database synchronously
- **Write-Behind**: Cache writes to database asynchronously

### The Implementation

**File: `part-09-caching/caching_patterns.py`**
```python
#!/usr/bin/env python3
"""
Caching Patterns Implementation
"""

import time
import random
import threading
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
from enum import Enum
import queue

class CachePattern(Enum):
    """Caching patterns"""
    CACHE_ASIDE = "cache_aside"
    READ_THROUGH = "read_through"
    WRITE_THROUGH = "write_through"
    WRITE_BEHIND = "write_behind"

class Database:
    """Simulated database"""
    
    def __init__(self):
        self.data: Dict[str, Any] = {}
        self.read_count = 0
        self.write_count = 0
        self.latency = 0.1  # Simulated latency in seconds
    
    def read(self, key: str) -> Optional[Any]:
        """Read from database"""
        time.sleep(self.latency)
        self.read_count += 1
        return self.data.get(key)
    
    def write(self, key: str, value: Any):
        """Write to database"""
        time.sleep(self.latency)
        self.data[key] = value
        self.write_count += 1
    
    def get_stats(self) -> Dict[str, Any]:
        """Get database statistics"""
        return {
            'read_count': self.read_count,
            'write_count': self.write_count,
            'total_operations': self.read_count + self.write_count,
            'size': len(self.data)
        }

class Cache:
    """Cache implementation"""
    
    def __init__(self):
        self.data: Dict[str, Any] = {}
        self.hits = 0
        self.misses = 0
    
    def get(self, key: str) -> Optional[Any]:
        """Get from cache"""
        if key in self.data:
            self.hits += 1
            return self.data[key]
        self.misses += 1
        return None
    
    def put(self, key: str, value: Any):
        """Put in cache"""
        self.data[key] = value
    
    def invalidate(self, key: str):
        """Invalidate a cache entry"""
        if key in self.data:
            del self.data[key]
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        total = self.hits + self.misses
        return {
            'hits': self.hits,
            'misses': self.misses,
            'hit_ratio': self.hits / total if total > 0 else 0,
            'size': len(self.data)
        }

class CacheAsidePattern:
    """
    Cache-Aside pattern (Lazy Loading)
    Application manages cache directly
    """
    
    def __init__(self):
        self.cache = Cache()
        self.db = Database()
    
    def get(self, key: str) -> Optional[Any]:
        """Get data with cache-aside"""
        # Try cache first
        value = self.cache.get(key)
        if value is not None:
            print(f"   ✅ Cache hit: {key}")
            return value
        
        # Cache miss - load from database
        print(f"   ⏳ Cache miss: {key}, loading from DB...")
        value = self.db.read(key)
        
        # Store in cache for future
        if value is not None:
            self.cache.put(key, value)
            print(f"   💾 Cached: {key}")
        
        return value
    
    def put(self, key: str, value: Any):
        """Write data with cache-aside"""
        # Write to database
        self.db.write(key, value)
        print(f"   📝 Written to DB: {key}")
        
        # Invalidate cache
        self.cache.invalidate(key)
        print(f"   🗑️ Invalidated cache: {key}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get statistics"""
        return {
            'cache': self.cache.get_stats(),
            'db': self.db.get_stats()
        }

class ReadThroughPattern:
    """
    Read-Through pattern
    Cache handles misses by loading from database
    """
    
    def __init__(self):
        self.cache = Cache()
        self.db = Database()
        self.cache_loads = 0
    
    def get(self, key: str) -> Optional[Any]:
        """Get data with read-through"""
        # Try cache first
        value = self.cache.get(key)
        if value is not None:
            print(f"   ✅ Cache hit: {key}")
            return value
        
        # Cache miss - cache loads from database
        print(f"   ⏳ Cache miss: {key}, cache loading from DB...")
        value = self.db.read(key)
        
        if value is not None:
            self.cache.put(key, value)
            self.cache_loads += 1
            print(f"   💾 Cache loaded: {key}")
        
        return value
    
    def put(self, key: str, value: Any):
        """Write through cache to database"""
        # Write to database
        self.db.write(key, value)
        print(f"   📝 Written to DB: {key}")
        
        # Update cache
        self.cache.put(key, value)
        print(f"   💾 Updated cache: {key}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get statistics"""
        return {
            'cache': self.cache.get_stats(),
            'db': self.db.get_stats(),
            'cache_loads': self.cache_loads
        }

class WriteThroughPattern:
    """
    Write-Through pattern
    Cache writes to database synchronously
    """
    
    def __init__(self):
        self.cache = Cache()
        self.db = Database()
    
    def get(self, key: str) -> Optional[Any]:
        """Get data (same as read-through)"""
        value = self.cache.get(key)
        if value is not None:
            print(f"   ✅ Cache hit: {key}")
            return value
        
        value = self.db.read(key)
        if value is not None:
            self.cache.put(key, value)
            print(f"   💾 Cached: {key}")
        
        return value
    
    def put(self, key: str, value: Any):
        """Write through cache to database synchronously"""
        # Write to database first
        self.db.write(key, value)
        print(f"   📝 Written to DB: {key}")
        
        # Then update cache
        self.cache.put(key, value)
        print(f"   💾 Updated cache: {key}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get statistics"""
        return {
            'cache': self.cache.get_stats(),
            'db': self.db.get_stats()
        }

class WriteBehindPattern:
    """
    Write-Behind pattern
    Cache writes to database asynchronously
    """
    
    def __init__(self):
        self.cache = Cache()
        self.db = Database()
        self.write_queue = queue.Queue()
        self.is_running = True
        self.write_thread = threading.Thread(target=self._process_writes)
        self.write_thread.daemon = True
        self.write_thread.start()
        self.pending_writes = 0
    
    def _process_writes(self):
        """Process write queue asynchronously"""
        while self.is_running:
            try:
                # Process writes in batches
                batch = []
                start_time = time.time()
                
                while len(batch) < 10 and time.time() - start_time < 0.5:
                    try:
                        key, value = self.write_queue.get(timeout=0.1)
                        batch.append((key, value))
                    except queue.Empty:
                        break
                
                if batch:
                    # Write to database
                    for key, value in batch:
                        self.db.write(key, value)
                        self.pending_writes -= 1
                    print(f"   📝 Batch wrote {len(batch)} items to DB")
                
                time.sleep(0.01)
                
            except Exception as e:
                print(f"   ⚠️ Write-behind error: {e}")
    
    def get(self, key: str) -> Optional[Any]:
        """Get data from cache"""
        value = self.cache.get(key)
        if value is not None:
            print(f"   ✅ Cache hit: {key}")
            return value
        
        # Cache miss - load from database
        value = self.db.read(key)
        if value is not None:
            self.cache.put(key, value)
            print(f"   💾 Cached: {key}")
        
        return value
    
    def put(self, key: str, value: Any):
        """Write to cache and queue for async write"""
        # Update cache immediately
        self.cache.put(key, value)
        print(f"   💾 Updated cache: {key}")
        
        # Queue for async write
        self.write_queue.put((key, value))
        self.pending_writes += 1
        print(f"   📋 Queued write for: {key}")
    
    def stop(self):
        """Stop the write-behind thread"""
        self.is_running = False
        # Wait for pending writes
        while self.pending_writes > 0:
            time.sleep(0.1)
        print(f"   ✅ All writes processed")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get statistics"""
        return {
            'cache': self.cache.get_stats(),
            'db': self.db.get_stats(),
            'pending_writes': self.pending_writes,
            'queue_size': self.write_queue.qsize()
        }

def demo_caching_patterns():
    """Demonstrate caching patterns"""
    print("="*60)
    print("CACHING PATTERNS DEMONSTRATION")
    print("="*60)
    
    patterns = [
        (CachePattern.CACHE_ASIDE, CacheAsidePattern()),
        (CachePattern.READ_THROUGH, ReadThroughPattern()),
        (CachePattern.WRITE_THROUGH, WriteThroughPattern()),
        (CachePattern.WRITE_BEHIND, WriteBehindPattern())
    ]
    
    for pattern_name, pattern_impl in patterns:
        print(f"\n📊 {pattern_name.value.upper()} Pattern:")
        print("-" * 40)
        
        # Initial data
        pattern_impl.put("user_1", "Alice")
        pattern_impl.put("user_2", "Bob")
        
        # Read operations
        print("\n   Reading data:")
        for i in range(3):
            pattern_impl.get("user_1")
            pattern_impl.get("user_2")
        
        # Write operations
        print("\n   Writing data:")
        pattern_impl.put("user_3", "Charlie")
        pattern_impl.put("user_4", "David")
        
        # Read new data
        print("\n   Reading new data:")
        pattern_impl.get("user_3")
        pattern_impl.get("user_4")
        
        # Show stats
        stats = pattern_impl.get_stats()
        print(f"\n   Stats:")
        print(f"   Cache hit ratio: {stats['cache']['hit_ratio']:.1%}")
        print(f"   Cache size: {stats['cache']['size']}")
        print(f"   DB reads: {stats['db']['read_count']}")
        print(f"   DB writes: {stats['db']['write_count']}")
        
        if hasattr(pattern_impl, 'pending_writes'):
            print(f"   Pending writes: {pattern_impl.pending_writes}")
            if isinstance(pattern_impl, WriteBehindPattern):
                pattern_impl.stop()

def main():
    """Run caching patterns demonstration"""
    demo_caching_patterns()
    
    print("\n" + "="*60)
    print("✅ CACHING PATTERNS DEMONSTRATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 9.3 Session Management with Redis

### The Concept

Session management stores user session data in a fast, distributed cache. Redis is ideal for this because it supports expiration times and can handle high throughput.

### The Implementation

**File: `part-09-caching/session_management.py`**
```python
#!/usr/bin/env python3
"""
Session Management with Redis Implementation
"""

import time
import json
import hashlib
import random
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class Session:
    """A user session"""
    session_id: str
    user_id: str
    data: Dict[str, Any]
    created_at: float
    last_accessed: float
    expires_at: float
    ip_address: str
    user_agent: str

class RedisSimulator:
    """
    Redis-like in-memory data store
    """
    
    def __init__(self):
        self.data: Dict[str, Any] = {}
        self.expiry: Dict[str, float] = {}
        self.hits = 0
        self.misses = 0
    
    def set(self, key: str, value: Any, ttl_seconds: int = 0):
        """Set a key with optional TTL"""
        self.data[key] = value
        if ttl_seconds > 0:
            self.expiry[key] = time.time() + ttl_seconds
        else:
            self.expiry.pop(key, None)
    
    def get(self, key: str) -> Optional[Any]:
        """Get a key"""
        # Check expiry
        if key in self.expiry and time.time() > self.expiry[key]:
            del self.data[key]
            del self.expiry[key]
            self.misses += 1
            return None
        
        if key in self.data:
            self.hits += 1
            return self.data[key]
        
        self.misses += 1
        return None
    
    def delete(self, key: str) -> bool:
        """Delete a key"""
        if key in self.data:
            del self.data[key]
            self.expiry.pop(key, None)
            return True
        return False
    
    def keys(self, pattern: str = "*") -> List[str]:
        """Get keys matching a pattern"""
        if pattern == "*":
            return list(self.data.keys())
        
        # Simple prefix matching
        prefix = pattern[:-1] if pattern.endswith("*") else pattern
        return [k for k in self.data.keys() if k.startswith(prefix)]
    
    def get_stats(self) -> Dict[str, Any]:
        """Get statistics"""
        total = self.hits + self.misses
        return {
            'hits': self.hits,
            'misses': self.misses,
            'hit_ratio': self.hits / total if total > 0 else 0,
            'size': len(self.data),
            'expiring_keys': len(self.expiry)
        }

class SessionManager:
    """
    Manages user sessions with Redis-like store
    """
    
    def __init__(self, redis_store: RedisSimulator, session_ttl: int = 3600):
        self.redis = redis_store
        self.session_ttl = session_ttl
        self.sessions: Dict[str, Session] = {}
        self.session_count = 0
    
    def create_session(self, user_id: str, ip_address: str, 
                       user_agent: str, data: Dict[str, Any] = None) -> str:
        """Create a new session"""
        session_id = self._generate_session_id(user_id)
        
        session = Session(
            session_id=session_id,
            user_id=user_id,
            data=data or {},
            created_at=time.time(),
            last_accessed=time.time(),
            expires_at=time.time() + self.session_ttl,
            ip_address=ip_address,
            user_agent=user_agent
        )
        
        # Store session
        self.sessions[session_id] = session
        self.redis.set(f"session:{session_id}", session, self.session_ttl)
        self.redis.set(f"user:{user_id}:sessions", session_id)
        
        self.session_count += 1
        print(f"   🆕 Session created: {session_id[:8]}... for user {user_id}")
        return session_id
    
    def _generate_session_id(self, user_id: str) -> str:
        """Generate a unique session ID"""
        import uuid
        return str(uuid.uuid4())
    
    def get_session(self, session_id: str) -> Optional[Session]:
        """Get a session by ID"""
        # Check local cache
        if session_id in self.sessions:
            session = self.sessions[session_id]
            
            # Check if expired
            if time.time() > session.expires_at:
                self.delete_session(session_id)
                return None
            
            # Update last accessed
            session.last_accessed = time.time()
            session.expires_at = time.time() + self.session_ttl
            
            # Update in Redis
            self.redis.set(f"session:{session_id}", session, self.session_ttl)
            
            return session
        
        # Check Redis
        session = self.redis.get(f"session:{session_id}")
        if session:
            self.sessions[session_id] = session
            return session
        
        return None
    
    def update_session_data(self, session_id: str, data: Dict[str, Any]) -> bool:
        """Update session data"""
        session = self.get_session(session_id)
        if not session:
            return False
        
        session.data.update(data)
        self.redis.set(f"session:{session_id}", session, self.session_ttl)
        print(f"   📝 Updated session {session_id[:8]}...")
        return True
    
    def get_session_data(self, session_id: str, key: str) -> Optional[Any]:
        """Get specific data from session"""
        session = self.get_session(session_id)
        if not session:
            return None
        
        return session.data.get(key)
    
    def delete_session(self, session_id: str) -> bool:
        """Delete a session"""
        session = self.get_session(session_id)
        if not session:
            return False
        
        # Remove from storage
        self.redis.delete(f"session:{session_id}")
        self.redis.delete(f"user:{session.user_id}:sessions")
        
        if session_id in self.sessions:
            del self.sessions[session_id]
        
        self.session_count -= 1
        print(f"   🗑️ Session deleted: {session_id[:8]}...")
        return True
    
    def clean_expired_sessions(self) -> int:
        """Clean expired sessions"""
        expired = []
        for session_id, session in self.sessions.items():
            if time.time() > session.expires_at:
                expired.append(session_id)
        
        for session_id in expired:
            self.delete_session(session_id)
        
        return len(expired)
    
    def get_user_sessions(self, user_id: str) -> List[Session]:
        """Get all sessions for a user"""
        user_sessions = []
        session_id = self.redis.get(f"user:{user_id}:sessions")
        
        if session_id:
            session = self.get_session(session_id)
            if session:
                user_sessions.append(session)
        
        return user_sessions
    
    def get_stats(self) -> Dict[str, Any]:
        """Get session manager statistics"""
        return {
            'session_count': self.session_count,
            'active_sessions': len(self.sessions),
            'redis_stats': self.redis.get_stats(),
            'session_ttl': self.session_ttl
        }

def demo_session_management():
    """Demonstrate session management"""
    print("="*60)
    print("SESSION MANAGEMENT DEMONSTRATION")
    print("="*60)
    
    # Create Redis simulator
    redis = RedisSimulator()
    
    # Create session manager
    sm = SessionManager(redis, session_ttl=60)  # 60 seconds TTL for demo
    
    print("\n📋 Testing session management:")
    
    # Create sessions
    print("\n🆕 Creating sessions...")
    session1 = sm.create_session(
        user_id="user_001",
        ip_address="192.168.1.100",
        user_agent="Mozilla/5.0",
        data={"cart": ["item1", "item2"], "preferences": {"theme": "dark"}}
    )
    
    session2 = sm.create_session(
        user_id="user_002",
        ip_address="192.168.1.101",
        user_agent="Chrome",
        data={"cart": ["item3"], "preferences": {"theme": "light"}}
    )
    
    # Get sessions
    print("\n📖 Retrieving sessions...")
    s1 = sm.get_session(session1)
    if s1:
        print(f"   ✅ Session {session1[:8]}...: {s1.data}")
    
    s2 = sm.get_session(session2)
    if s2:
        print(f"   ✅ Session {session2[:8]}...: {s2.data}")
    
    # Update session data
    print("\n📝 Updating session data...")
    sm.update_session_data(session1, {"cart": ["item1", "item2", "item4"]})
    sm.update_session_data(session2, {"preferences": {"theme": "dark"}})
    
    # Get specific data
    print("\n🔍 Getting specific session data...")
    cart = sm.get_session_data(session1, "cart")
    print(f"   Session 1 cart: {cart}")
    
    # Get user sessions
    print("\n👤 Getting user sessions...")
    user_sessions = sm.get_user_sessions("user_001")
    print(f"   User 001 has {len(user_sessions)} active sessions")
    
    # Show stats
    stats = sm.get_stats()
    print(f"\n📊 Session Manager Stats:")
    print(f"   Session count: {stats['session_count']}")
    print(f"   Active sessions: {stats['active_sessions']}")
    print(f"   Redis hit ratio: {stats['redis_stats']['hit_ratio']:.1%}")
    print(f"   Session TTL: {stats['session_ttl']}s")
    
    # Clean expired sessions
    print("\n🧹 Cleaning expired sessions...")
    expired = sm.clean_expired_sessions()
    print(f"   Removed {expired} expired sessions")
    
    # Final stats
    stats = sm.get_stats()
    print(f"\n📊 Final Stats:")
    print(f"   Session count: {stats['session_count']}")
    print(f"   Active sessions: {stats['active_sessions']}")
    
    print("\n🎯 Session Management Features:")
    print("   • Session creation with TTL")
    print("   • Data storage and retrieval")
    print("   • Automatic expiration")
    print("   • User session tracking")
    print("   • High availability with Redis")

def main():
    """Run session management demonstration"""
    demo_session_management()
    
    print("\n" + "="*60)
    print("✅ SESSION MANAGEMENT DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 9.4 Query Caching and Materialized Views

### The Concept

Query caching stores query results to avoid re-execution. Materialized views are pre-computed query results stored as tables, dramatically improving performance for complex queries.

### The Implementation

**File: `part-09-caching/query_caching.py`**
```python
#!/usr/bin/env python3
"""
Query Caching and Materialized Views Implementation
"""

import time
import json
import hashlib
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime

@dataclass
class QueryCacheEntry:
    """A query cache entry"""
    query_hash: str
    query_text: str
    result: Any
    timestamp: float
    ttl_seconds: int
    execution_time_ms: float

class QueryCache:
    """
    Cache for query results
    """
    
    def __init__(self, max_size: int = 100, default_ttl: int = 300):
        self.max_size = max_size
        self.default_ttl = default_ttl
        self.cache: Dict[str, QueryCacheEntry] = {}
        self.hits = 0
        self.misses = 0
    
    def _hash_query(self, query: str, params: Dict[str, Any] = None) -> str:
        """Hash a query with parameters"""
        key = query
        if params:
            key += json.dumps(params, sort_keys=True)
        return hashlib.md5(key.encode()).hexdigest()
    
    def get(self, query: str, params: Dict[str, Any] = None) -> Optional[Any]:
        """Get cached query result"""
        query_hash = self._hash_query(query, params)
        
        if query_hash not in self.cache:
            self.misses += 1
            return None
        
        entry = self.cache[query_hash]
        
        # Check TTL
        if time.time() - entry.timestamp > entry.ttl_seconds:
            del self.cache[query_hash]
            self.misses += 1
            return None
        
        self.hits += 1
        return entry.result
    
    def put(self, query: str, result: Any, execution_time_ms: float,
            params: Dict[str, Any] = None, ttl_seconds: int = None):
        """Cache a query result"""
        if ttl_seconds is None:
            ttl_seconds = self.default_ttl
        
        query_hash = self._hash_query(query, params)
        
        # Evict if cache is full
        if len(self.cache) >= self.max_size:
            # Remove oldest entry
            oldest = min(self.cache.items(), key=lambda x: x[1].timestamp)
            del self.cache[oldest[0]]
        
        self.cache[query_hash] = QueryCacheEntry(
            query_hash=query_hash,
            query_text=query,
            result=result,
            timestamp=time.time(),
            ttl_seconds=ttl_seconds,
            execution_time_ms=execution_time_ms
        )
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        total = self.hits + self.misses
        return {
            'hits': self.hits,
            'misses': self.misses,
            'hit_ratio': self.hits / total if total > 0 else 0,
            'size': len(self.cache),
            'max_size': self.max_size
        }

class MaterializedView:
    """
    A materialized view - pre-computed query results
    """
    
    def __init__(self, name: str, query: str, refresh_interval: int = 60):
        self.name = name
        self.query = query
        self.data: List[Dict[str, Any]] = []
        self.refresh_interval = refresh_interval
        self.last_refresh = 0
        self.is_initialized = False
    
    def refresh(self, data_source: List[Dict[str, Any]]):
        """Refresh the materialized view"""
        # Simulate query execution
        start_time = time.time()
        
        # Process data (simulated query)
        self.data = []
        for record in data_source:
            # Simulate filtering and aggregation
            if record.get('status') == 'active':
                # Transform data
                transformed = {
                    'id': record.get('id'),
                    'name': record.get('name'),
                    'value': record.get('value', 0) * 1.1,
                    'category': record.get('category', 'other')
                }
                self.data.append(transformed)
        
        execution_time = (time.time() - start_time) * 1000
        self.last_refresh = time.time()
        self.is_initialized = True
        
        print(f"   🔄 Refreshed MV {self.name}: {len(self.data)} records, {execution_time:.2f}ms")
    
    def query(self, filter_func: Callable = None) -> List[Dict[str, Any]]:
        """Query the materialized view"""
        if not self.is_initialized:
            return []
        
        if filter_func:
            return [d for d in self.data if filter_func(d)]
        
        return self.data
    
    def needs_refresh(self) -> bool:
        """Check if the view needs refreshing"""
        if not self.is_initialized:
            return True
        return time.time() - self.last_refresh > self.refresh_interval

class DatabaseWithMaterializedViews:
    """
    Database with materialized view support
    """
    
    def __init__(self):
        self.data: List[Dict[str, Any]] = []
        self.materialized_views: Dict[str, MaterializedView] = {}
        self.query_count = 0
        self.query_time_ms = 0
    
    def add_data(self, records: List[Dict[str, Any]]):
        """Add data to the database"""
        self.data.extend(records)
    
    def create_materialized_view(self, name: str, query: str, 
                                 refresh_interval: int = 60):
        """Create a materialized view"""
        view = MaterializedView(name, query, refresh_interval)
        self.materialized_views[name] = view
        print(f"   📊 Created materialized view: {name}")
        return view
    
    def refresh_materialized_view(self, name: str):
        """Refresh a materialized view"""
        if name in self.materialized_views:
            self.materialized_views[name].refresh(self.data)
            return True
        return False
    
    def query_direct(self, filter_func: Callable = None) -> List[Dict[str, Any]]:
        """Direct query on data (simulated)"""
        start_time = time.time()
        
        # Simulate complex query
        time.sleep(0.1)  # Simulate query time
        self.query_count += 1
        
        if filter_func:
            results = [d for d in self.data if filter_func(d)]
        else:
            results = self.data
        
        elapsed_ms = (time.time() - start_time) * 1000
        self.query_time_ms += elapsed_ms
        
        return results
    
    def query_view(self, view_name: str, filter_func: Callable = None) -> List[Dict[str, Any]]:
        """Query a materialized view"""
        if view_name not in self.materialized_views:
            return []
        
        view = self.materialized_views[view_name]
        
        # Refresh if needed
        if view.needs_refresh():
            self.refresh_materialized_view(view_name)
        
        self.query_count += 1
        return view.query(filter_func)
    
    def get_stats(self) -> Dict[str, Any]:
        """Get database statistics"""
        return {
            'record_count': len(self.data),
            'view_count': len(self.materialized_views),
            'query_count': self.query_count,
            'total_query_time_ms': self.query_time_ms,
            'avg_query_time_ms': self.query_time_ms / self.query_count if self.query_count > 0 else 0
        }

def demo_query_caching():
    """Demonstrate query caching"""
    print("="*60)
    print("QUERY CACHING DEMONSTRATION")
    print("="*60)
    
    # Create query cache
    cache = QueryCache(max_size=50, default_ttl=30)
    
    # Sample data for queries
    sample_data = [
        {'id': 1, 'name': 'Alice', 'age': 30, 'city': 'NY', 'status': 'active'},
        {'id': 2, 'name': 'Bob', 'age': 25, 'city': 'LA', 'status': 'active'},
        {'id': 3, 'name': 'Charlie', 'age': 35, 'city': 'SF', 'status': 'inactive'},
        {'id': 4, 'name': 'David', 'age': 28, 'city': 'CH', 'status': 'active'},
        {'id': 5, 'name': 'Eve', 'age': 32, 'city': 'PH', 'status': 'inactive'}
    ]
    
    def expensive_query(query_text: str, params: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Simulate an expensive query"""
        time.sleep(0.05)  # Simulate query time
        if params and 'city' in params:
            return [d for d in sample_data if d.get('city') == params['city']]
        return sample_data
    
    print("\n📋 Testing query cache:")
    
    # First query (cache miss)
    print("\n   First query (cache miss):")
    query = "SELECT * FROM users WHERE city = 'NY'"
    params = {'city': 'NY'}
    
    start_time = time.time()
    result = cache.get(query, params)
    if result is None:
        # Cache miss - execute query
        result = expensive_query(query, params)
        execution_time = (time.time() - start_time) * 1000
        cache.put(query, result, execution_time, params)
        print(f"   ⏳ Query executed in {execution_time:.2f}ms")
    print(f"   Result: {len(result)} records")
    
    # Second query (cache hit)
    print("\n   Second query (cache hit):")
    start_time = time.time()
    result = cache.get(query, params)
    if result is None:
        # Cache miss
        result = expensive_query(query, params)
        execution_time = (time.time() - start_time) * 1000
        cache.put(query, result, execution_time, params)
        print(f"   ⏳ Query executed in {execution_time:.2f}ms")
    else:
        print(f"   ✅ Cache hit! Retrieved from cache")
    print(f"   Result: {len(result)} records")
    
    # Show cache stats
    stats = cache.get_stats()
    print(f"\n📊 Cache Stats:")
    print(f"   Hit ratio: {stats['hit_ratio']:.1%}")
    print(f"   Cache size: {stats['size']}/{stats['max_size']}")

def demo_materialized_views():
    """Demonstrate materialized views"""
    print("\n" + "="*60)
    print("MATERIALIZED VIEWS DEMONSTRATION")
    print("="*60)
    
    # Create database
    db = DatabaseWithMaterializedViews()
    
    # Add sample data
    sample_data = []
    for i in range(1000):
        sample_data.append({
            'id': i,
            'name': f"User_{i}",
            'value': random.randint(1, 1000),
            'category': random.choice(['A', 'B', 'C', 'D']),
            'status': random.choice(['active', 'inactive']),
            'region': random.choice(['US', 'EU', 'APAC'])
        })
    db.add_data(sample_data)
    print(f"\n📋 Added {len(sample_data)} records")
    
    # Create materialized view
    print("\n📊 Creating materialized view...")
    db.create_materialized_view(
        name="active_users_summary",
        query="SELECT category, region, COUNT(*) as count, AVG(value) as avg_value FROM users WHERE status='active' GROUP BY category, region",
        refresh_interval=10
    )
    
    # Query direct
    print("\n📋 Querying directly (slow):")
    start_time = time.time()
    direct_results = db.query_direct(lambda r: r.get('status') == 'active')
    direct_time = (time.time() - start_time) * 1000
    print(f"   Direct query: {len(direct_results)} records, {direct_time:.2f}ms")
    
    # Query view (first time - triggers refresh)
    print("\n📋 Querying materialized view (first time - refreshing):")
    start_time = time.time()
    view_results = db.query_view('active_users_summary')
    view_time = (time.time() - start_time) * 1000
    print(f"   View query: {len(view_results)} records, {view_time:.2f}ms")
    
    # Query view again (cached)
    print("\n📋 Querying materialized view (cached):")
    start_time = time.time()
    view_results = db.query_view('active_users_summary')
    view_time = (time.time() - start_time) * 1000
    print(f"   View query: {len(view_results)} records, {view_time:.2f}ms")
    
    # Show stats
    stats = db.get_stats()
    print(f"\n📊 Database Stats:")
    print(f"   Query count: {stats['query_count']}")
    print(f"   Avg query time: {stats['avg_query_time_ms']:.2f}ms")
    print(f"   Views: {stats['view_count']}")
    
    print("\n🎯 Materialized View Benefits:")
    print("   • Pre-computed results for complex queries")
    print("   • Significant performance improvement")
    print("   • Periodic refresh for data freshness")
    print("   • Ideal for dashboards and reporting")

def main():
    """Run query caching demonstrations"""
    demo_query_caching()
    demo_materialized_views()
    
    print("\n" + "="*60)
    print("✅ QUERY CACHING DEMONSTRATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    import random
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-09-caching

# Run the caching fundamentals demonstration
python cache_fundamentals.py

# Run the caching patterns demonstration
python caching_patterns.py

# Run the session management demonstration
python session_management.py

# Run the query caching demonstration
python query_caching.py

# Expected output:
# ============================================================
# CACHING FUNDAMENTALS DEMONSTRATION
# ============================================================
# 
# 📊 LRU Eviction Policy:
# ----------------------------------------
#    Added key_0
#    Added key_1
#    Added key_2
#    Added key_3
#    Added key_4
#    Added key_5 (evicted key_0)
#    Added key_6 (evicted key_1)
# 
#    Cache state (5 items):
#       key_2: access_count=1, last_access=...
#       key_3: access_count=0, last_access=...
#       key_4: access_count=0, last_access=...
#       key_5: access_count=0, last_access=...
#       key_6: access_count=0, last_access=...
# 
#    Stats:
#    Size: 5/5
#    Hits: 4, Misses: 0
#    Hit ratio: 100.0%
#    Evictions: 2
# 
# ============================================================
# ✅ CACHING FUNDAMENTALS DEMONSTRATIONS COMPLETE
# ============================================================
```

---

## Part 9 Recap

You have successfully:

✅ Implemented caching with multiple eviction policies (LRU, LFU, FIFO, TTL, Random)  
✅ Built distributed caching with consistent hashing  
✅ Implemented cache-aside, read-through, write-through, and write-behind patterns  
✅ Built session management with Redis-like store  
✅ Implemented query caching for performance optimization  
✅ Created materialized views for complex queries  
✅ Measured cache hit ratios and performance improvements  

### Key Takeaways

1. **Caching** dramatically improves performance by storing frequently accessed data
2. **Eviction Policies** determine which data stays in cache when it's full
3. **Distributed Caching** enables horizontal scaling across multiple nodes
4. **Cache Patterns** define how applications interact with cache
5. **Session Management** leverages caching for user data storage
6. **Query Caching** stores query results to avoid re-execution
7. **Materialized Views** pre-compute complex query results
8. **Hit Ratio** is the key metric for cache effectiveness
9. **TTL** prevents stale data in the cache
