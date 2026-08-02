# Part 8: Scalability, Distribution, and High Availability

Welcome to Part 8, where we explore how enterprise systems achieve massive scale while maintaining reliability. Think of scalability like a highway system - as traffic grows, you need more lanes (horizontal scaling), faster cars (vertical scaling), and smart traffic management (load balancing). Distribution ensures no single point of failure, making the system resilient to outages.

## Learning Objectives

By the end of this part, you will be able to:

- Implement horizontal and vertical scaling strategies
- Design data partitioning and sharding schemes
- Implement replication models for high availability
- Build consensus for distributed systems
- Design geo-distributed architectures
- Implement disaster recovery strategies

---

## 8.1 Scaling Strategies

### The Concept

Scaling is about handling increased load:

- **Vertical Scaling (Scale Up)**: Add more resources to a single machine
- **Horizontal Scaling (Scale Out)**: Add more machines to the system
- **Elastic Scaling**: Automatically adjust resources based on demand

### The Implementation

**File: `part-08-scalability/scaling_strategies.py`**
```python
#!/usr/bin/env python3
"""
Scaling Strategies Implementation
"""

import time
import threading
import random
import math
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import queue

class ScalingStrategy(Enum):
    """Types of scaling strategies"""
    VERTICAL = "vertical"
    HORIZONTAL = "horizontal"
    ELASTIC = "elastic"

@dataclass
class Node:
    """A node in the system"""
    node_id: str
    cpu_cores: int
    memory_gb: int
    disk_gb: int
    load: float = 0.0
    max_load: float = 1.0
    is_healthy: bool = True
    
    def can_handle(self, load: float) -> bool:
        """Check if node can handle additional load"""
        return self.load + load <= self.max_load
    
    def add_load(self, load: float) -> bool:
        """Add load to the node"""
        if not self.can_handle(load):
            return False
        self.load += load
        return True
    
    def remove_load(self, load: float):
        """Remove load from the node"""
        self.load = max(0, self.load - load)
    
    def get_utilization(self) -> float:
        """Get node utilization percentage"""
        return (self.load / self.max_load) * 100

class LoadBalancer:
    """
    Load balancer for distributing requests across nodes
    """
    
    def __init__(self, strategy: str = "round_robin"):
        self.nodes: List[Node] = []
        self.strategy = strategy
        self.current_index = 0
        self.total_requests = 0
        
    def add_node(self, node: Node):
        """Add a node to the load balancer"""
        self.nodes.append(node)
        
    def remove_node(self, node_id: str) -> bool:
        """Remove a node from the load balancer"""
        for i, node in enumerate(self.nodes):
            if node.node_id == node_id:
                self.nodes.pop(i)
                return True
        return False
    
    def get_next_node(self) -> Optional[Node]:
        """Get the next node based on strategy"""
        if not self.nodes:
            return None
        
        if self.strategy == "round_robin":
            return self._round_robin()
        elif self.strategy == "least_connections":
            return self._least_connections()
        elif self.strategy == "random":
            return self._random()
        elif self.strategy == "weighted":
            return self._weighted()
        else:
            return self._round_robin()
    
    def _round_robin(self) -> Node:
        """Round-robin selection"""
        for _ in range(len(self.nodes)):
            self.current_index = (self.current_index + 1) % len(self.nodes)
            node = self.nodes[self.current_index]
            if node.is_healthy:
                return node
        return self.nodes[0]
    
    def _least_connections(self) -> Node:
        """Select node with least load"""
        healthy_nodes = [n for n in self.nodes if n.is_healthy]
        if not healthy_nodes:
            return self.nodes[0]
        
        return min(healthy_nodes, key=lambda n: n.load)
    
    def _random(self) -> Node:
        """Random selection"""
        healthy_nodes = [n for n in self.nodes if n.is_healthy]
        if not healthy_nodes:
            return self.nodes[0]
        return random.choice(healthy_nodes)
    
    def _weighted(self) -> Node:
        """Weighted selection (based on capacity)"""
        healthy_nodes = [n for n in self.nodes if n.is_healthy]
        if not healthy_nodes:
            return self.nodes[0]
        
        # Weight by capacity
        weights = [n.cpu_cores * n.memory_gb for n in healthy_nodes]
        total_weight = sum(weights)
        if total_weight == 0:
            return random.choice(healthy_nodes)
        
        r = random.random()
        cumulative = 0
        for node, weight in zip(healthy_nodes, weights):
            cumulative += weight / total_weight
            if r <= cumulative:
                return node
        
        return healthy_nodes[-1]
    
    def handle_request(self, request_load: float) -> Tuple[Optional[Node], bool]:
        """Handle a request by distributing to a node"""
        self.total_requests += 1
        node = self.get_next_node()
        
        if node is None:
            return None, False
        
        success = node.add_load(request_load)
        return node, success
    
    def get_stats(self) -> Dict[str, Any]:
        """Get load balancer statistics"""
        return {
            'total_nodes': len(self.nodes),
            'total_requests': self.total_requests,
            'strategy': self.strategy,
            'nodes': [
                {
                    'id': n.node_id,
                    'load': n.load,
                    'utilization': n.get_utilization(),
                    'is_healthy': n.is_healthy
                }
                for n in self.nodes
            ],
            'average_utilization': sum(n.get_utilization() for n in self.nodes) / len(self.nodes) if self.nodes else 0
        }

class AutoScaler:
    """
    Automatic scaling based on load metrics
    """
    
    def __init__(self, min_nodes: int = 2, max_nodes: int = 10):
        self.min_nodes = min_nodes
        self.max_nodes = max_nodes
        self.load_balancer = LoadBalancer()
        self.scaling_cooldown = 30  # seconds
        self.last_scaling_time = 0
        
        # Initialize with minimum nodes
        for i in range(min_nodes):
            node = Node(
                node_id=f"node_{i}",
                cpu_cores=4,
                memory_gb=16,
                disk_gb=100
            )
            self.load_balancer.add_node(node)
    
    def add_node(self):
        """Add a new node"""
        if len(self.load_balancer.nodes) >= self.max_nodes:
            return False
        
        node_id = f"node_{len(self.load_balancer.nodes)}"
        node = Node(
            node_id=node_id,
            cpu_cores=4,
            memory_gb=16,
            disk_gb=100
        )
        self.load_balancer.add_node(node)
        self.last_scaling_time = time.time()
        print(f"   🔼 Scaled up: Added {node_id}")
        return True
    
    def remove_node(self):
        """Remove a node"""
        if len(self.load_balancer.nodes) <= self.min_nodes:
            return False
        
        # Remove the node with least load
        node = min(self.load_balancer.nodes, key=lambda n: n.load)
        self.load_balancer.remove_node(node.node_id)
        self.last_scaling_time = time.time()
        print(f"   🔽 Scaled down: Removed {node.node_id}")
        return True
    
    def check_and_scale(self, current_load: float):
        """Check load and scale if necessary"""
        if time.time() - self.last_scaling_time < self.scaling_cooldown:
            return
        
        avg_utilization = sum(n.get_utilization() for n in self.load_balancer.nodes) / len(self.load_balancer.nodes)
        
        # Scale up if utilization is high
        if avg_utilization > 80:
            self.add_node()
        
        # Scale down if utilization is low
        elif avg_utilization < 30 and len(self.load_balancer.nodes) > self.min_nodes:
            self.remove_node()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get auto-scaler statistics"""
        return {
            'current_nodes': len(self.load_balancer.nodes),
            'min_nodes': self.min_nodes,
            'max_nodes': self.max_nodes,
            'load_balancer_stats': self.load_balancer.get_stats()
        }

def demo_scaling():
    """Demonstrate scaling strategies"""
    print("="*60)
    print("SCALING STRATEGIES DEMONSTRATION")
    print("="*60)
    
    # Vertical Scaling demonstration
    print("\n📊 VERTICAL SCALING (Scale Up):")
    print("-" * 40)
    
    print("   Increasing resources on existing nodes:")
    node = Node("app_server", cpu_cores=2, memory_gb=4, disk_gb=50)
    print(f"   Initial: {node.cpu_cores} cores, {node.memory_gb}GB RAM, {node.disk_gb}GB disk")
    
    node.cpu_cores = 8
    node.memory_gb = 32
    node.disk_gb = 200
    print(f"   Scaled up: {node.cpu_cores} cores, {node.memory_gb}GB RAM, {node.disk_gb}GB disk")
    print(f"   ✅ Vertical scaling can handle more load on the same machine")
    
    # Horizontal Scaling demonstration
    print("\n📊 HORIZONTAL SCALING (Scale Out):")
    print("-" * 40)
    
    lb = LoadBalancer(strategy="round_robin")
    for i in range(3):
        node = Node(f"app_server_{i}", cpu_cores=4, memory_gb=16, disk_gb=100)
        lb.add_node(node)
    
    print("   Distributed load across multiple nodes:")
    for i in range(6):
        node, success = lb.handle_request(0.2)
        if success:
            print(f"   Request {i+1} → {node.node_id} (load: {node.load:.1f})")
    
    # Show load distribution
    stats = lb.get_stats()
    print(f"\n   Load Distribution:")
    for node_stats in stats['nodes']:
        print(f"   {node_stats['id']}: {node_stats['utilization']:.1f}% utilized")
    
    # Elastic Scaling demonstration
    print("\n📊 ELASTIC SCALING:")
    print("-" * 40)
    
    scaler = AutoScaler(min_nodes=2, max_nodes=6)
    print("   Starting with 2 nodes")
    
    # Simulate increasing load
    loads = [0.3, 0.5, 0.8, 1.2, 1.5, 1.0, 0.6, 0.3, 0.2]
    
    print("\n   Simulating load changes:")
    for i, load in enumerate(loads):
        print(f"   Load: {load:.1f}", end=" ")
        
        # Distribute load
        for _ in range(10):
            scaler.load_balancer.handle_request(load / 10)
        
        # Check scaling
        scaler.check_and_scale(load)
        
        # Show current state
        stats = scaler.get_stats()
        print(f"→ {stats['current_nodes']} nodes")
        
        time.sleep(0.1)
    
    # Final stats
    stats = scaler.get_stats()
    print(f"\n   Final State:")
    print(f"   Nodes: {stats['current_nodes']}")
    print(f"   Load Balancer Strategy: {stats['load_balancer_stats']['strategy']}")
    
    print("\n🎯 Scaling Strategy Summary:")
    print("   • Vertical: Add more resources to existing machines")
    print("   • Horizontal: Add more machines to distribute load")
    print("   • Elastic: Automatically adjust based on demand")

def main():
    """Run scaling demonstration"""
    demo_scaling()
    
    print("\n" + "="*60)
    print("✅ SCALING DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 8.2 Data Partitioning and Sharding

### The Concept

Partitioning (sharding) is like organizing a library by topic - each partition (shard) holds a subset of the data, making queries faster by only scanning relevant data.

### The Implementation

**File: `part-08-scalability/partitioning_sharding.py`**
```python
#!/usr/bin/env python3
"""
Data Partitioning and Sharding Implementation
"""

import hashlib
import time
import random
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

class PartitionStrategy(Enum):
    """Partitioning strategies"""
    RANGE = "range"
    HASH = "hash"
    LIST = "list"
    COMPOSITE = "composite"

@dataclass
class Shard:
    """A shard/partition"""
    shard_id: str
    data: Dict[str, Dict[str, Any]]
    size: int
    min_key: Optional[Any] = None
    max_key: Optional[Any] = None
    
    def insert(self, key: str, value: Dict[str, Any]) -> bool:
        """Insert data into shard"""
        if key in self.data:
            return False
        
        self.data[key] = value
        self.size += 1
        return True
    
    def get(self, key: str) -> Optional[Dict[str, Any]]:
        """Get data from shard"""
        return self.data.get(key)
    
    def delete(self, key: str) -> bool:
        """Delete data from shard"""
        if key not in self.data:
            return False
        del self.data[key]
        self.size -= 1
        return True
    
    def query_range(self, start_key: str, end_key: str) -> List[Dict[str, Any]]:
        """Query data in a range"""
        result = []
        for key, value in sorted(self.data.items()):
            if start_key <= key <= end_key:
                result.append(value)
        return result

class PartitionManager:
    """
    Manages data partitioning and sharding
    """
    
    def __init__(self, strategy: PartitionStrategy = PartitionStrategy.RANGE):
        self.strategy = strategy
        self.shards: List[Shard] = []
        self.partition_function = None
        
        # Initialize with default shards
        self._initialize_shards()
    
    def _initialize_shards(self):
        """Initialize shards based on strategy"""
        if self.strategy == PartitionStrategy.HASH:
            # Create shards for hash strategy
            for i in range(4):
                shard = Shard(
                    shard_id=f"shard_{i}",
                    data={},
                    size=0
                )
                self.shards.append(shard)
        
        elif self.strategy == PartitionStrategy.RANGE:
            # Create shards for range strategy
            ranges = [('a', 'f'), ('g', 'm'), ('n', 's'), ('t', 'z')]
            for i, (start, end) in enumerate(ranges):
                shard = Shard(
                    shard_id=f"shard_{i}",
                    data={},
                    size=0,
                    min_key=start,
                    max_key=end
                )
                self.shards.append(shard)
        
        elif self.strategy == PartitionStrategy.LIST:
            # Create shards for list strategy
            lists = [
                ['US', 'CA', 'MX'],
                ['UK', 'FR', 'DE'],
                ['JP', 'CN', 'KR'],
                ['AU', 'NZ', 'IN']
            ]
            for i, countries in enumerate(lists):
                shard = Shard(
                    shard_id=f"shard_{i}",
                    data={},
                    size=0,
                    min_key=countries[0],
                    max_key=countries[-1]
                )
                self.shards.append(shard)
    
    def get_shard_for_key(self, key: str) -> Optional[Shard]:
        """Get the shard for a given key"""
        if self.strategy == PartitionStrategy.HASH:
            return self._hash_partition(key)
        elif self.strategy == PartitionStrategy.RANGE:
            return self._range_partition(key)
        elif self.strategy == PartitionStrategy.LIST:
            return self._list_partition(key)
        return None
    
    def _hash_partition(self, key: str) -> Shard:
        """Hash-based partitioning"""
        hash_val = int(hashlib.md5(key.encode()).hexdigest(), 16)
        shard_index = hash_val % len(self.shards)
        return self.shards[shard_index]
    
    def _range_partition(self, key: str) -> Optional[Shard]:
        """Range-based partitioning"""
        first_char = key[0].lower()
        for shard in self.shards:
            if shard.min_key <= first_char <= shard.max_key:
                return shard
        return self.shards[-1]
    
    def _list_partition(self, key: str) -> Optional[Shard]:
        """List-based partitioning"""
        # For simplicity, use first character
        return self._range_partition(key)
    
    def insert(self, key: str, value: Dict[str, Any]) -> bool:
        """Insert data"""
        shard = self.get_shard_for_key(key)
        if shard is None:
            return False
        return shard.insert(key, value)
    
    def get(self, key: str) -> Optional[Dict[str, Any]]:
        """Get data"""
        shard = self.get_shard_for_key(key)
        if shard is None:
            return None
        return shard.get(key)
    
    def delete(self, key: str) -> bool:
        """Delete data"""
        shard = self.get_shard_for_key(key)
        if shard is None:
            return False
        return shard.delete(key)
    
    def query_range(self, start_key: str, end_key: str) -> List[Dict[str, Any]]:
        """Query a range of data"""
        results = []
        for shard in self.shards:
            results.extend(shard.query_range(start_key, end_key))
        return results
    
    def get_stats(self) -> Dict[str, Any]:
        """Get partition statistics"""
        return {
            'strategy': self.strategy.value,
            'shard_count': len(self.shards),
            'total_size': sum(s.size for s in self.shards),
            'shards': [
                {
                    'id': s.shard_id,
                    'size': s.size,
                    'min_key': s.min_key,
                    'max_key': s.max_key
                }
                for s in self.shards
            ]
        }

class ConsistentHash:
    """
    Consistent hashing for distributed systems
    """
    
    def __init__(self, nodes: List[str], virtual_nodes: int = 100):
        self.nodes = nodes
        self.virtual_nodes = virtual_nodes
        self.ring = {}
        self._build_ring()
    
    def _build_ring(self):
        """Build the consistent hash ring"""
        self.ring = {}
        for node in self.nodes:
            for i in range(self.virtual_nodes):
                key = self._hash(f"{node}_{i}")
                self.ring[key] = node
        
        # Sort the ring
        self.ring = dict(sorted(self.ring.items()))
    
    def _hash(self, value: str) -> int:
        """Hash a value"""
        return int(hashlib.md5(value.encode()).hexdigest(), 16)
    
    def get_node(self, key: str) -> str:
        """Get the node for a given key"""
        if not self.ring:
            return None
        
        hash_val = self._hash(key)
        
        # Find the first node with hash >= key hash
        for ring_hash, node in self.ring.items():
            if ring_hash >= hash_val:
                return node
        
        # Wrap around to the first node
        return next(iter(self.ring.values()))
    
    def add_node(self, node: str):
        """Add a node to the ring"""
        self.nodes.append(node)
        # Rebuild ring
        self._build_ring()
    
    def remove_node(self, node: str):
        """Remove a node from the ring"""
        if node in self.nodes:
            self.nodes.remove(node)
            self._build_ring()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get consistent hash statistics"""
        return {
            'node_count': len(self.nodes),
            'virtual_nodes_per_node': self.virtual_nodes,
            'ring_size': len(self.ring),
            'nodes': self.nodes
        }

def demo_partitioning():
    """Demonstrate data partitioning"""
    print("="*60)
    print("DATA PARTITIONING AND SHARDING DEMONSTRATION")
    print("="*60)
    
    # Test different partitioning strategies
    strategies = [
        (PartitionStrategy.RANGE, "Range"),
        (PartitionStrategy.HASH, "Hash"),
        (PartitionStrategy.LIST, "List")
    ]
    
    for strategy, name in strategies:
        print(f"\n📊 {name} Partitioning:")
        print("-" * 40)
        
        pm = PartitionManager(strategy=strategy)
        
        # Insert sample data
        test_data = [
            ('alice', {'age': 30, 'city': 'NY'}),
            ('bob', {'age': 25, 'city': 'LA'}),
            ('charlie', {'age': 35, 'city': 'SF'}),
            ('david', {'age': 28, 'city': 'CH'}),
            ('eve', {'age': 32, 'city': 'PH'}),
            ('frank', {'age': 27, 'city': 'SE'}),
            ('grace', {'age': 29, 'city': 'BO'}),
            ('henry', {'age': 31, 'city': 'DE'})
        ]
        
        for key, value in test_data:
            success = pm.insert(key, value)
            if success:
                shard = pm.get_shard_for_key(key)
                print(f"   Inserted {key} → {shard.shard_id}")
        
        # Show stats
        stats = pm.get_stats()
        print(f"\n   Stats:")
        print(f"   Total records: {stats['total_size']}")
        print(f"   Shards: {stats['shard_count']}")
        for shard_stats in stats['shards']:
            print(f"   {shard_stats['id']}: {shard_stats['size']} records")
        
        # Query range
        print(f"\n   Range query: 'd' to 'g'")
        results = pm.query_range('d', 'g')
        print(f"   Found {len(results)} records")
        for result in results:
            print(f"      {result}")

def demo_consistent_hashing():
    """Demonstrate consistent hashing"""
    print("\n" + "="*60)
    print("CONSISTENT HASHING DEMONSTRATION")
    print("="*60)
    
    # Create consistent hash ring
    nodes = ['node1', 'node2', 'node3']
    ch = ConsistentHash(nodes, virtual_nodes=100)
    
    print(f"\n📊 Initial ring with {len(nodes)} nodes")
    
    # Distribute keys
    print("\n📋 Distributing keys across nodes:")
    keys = ['user_1001', 'user_1002', 'user_1003', 'user_1004', 
            'user_1005', 'user_1006', 'user_1007', 'user_1008']
    
    distribution = {}
    for key in keys:
        node = ch.get_node(key)
        if node not in distribution:
            distribution[node] = []
        distribution[node].append(key)
        print(f"   {key} → {node}")
    
    print(f"\n📊 Initial Distribution:")
    for node, keys_assigned in distribution.items():
        print(f"   {node}: {len(keys_assigned)} keys")
    
    # Add a node
    print("\n🔄 Adding node4...")
    ch.add_node('node4')
    
    print("\n📋 Re-distributing keys:")
    distribution2 = {}
    for key in keys:
        node = ch.get_node(key)
        if node not in distribution2:
            distribution2[node] = []
        distribution2[node].append(key)
    
    print(f"\n📊 Final Distribution:")
    for node, keys_assigned in distribution2.items():
        print(f"   {node}: {len(keys_assigned)} keys")
    
    # Show moved keys
    moved = 0
    for key in keys:
        old_node = ch.get_node(key)  # After adding node, this would be different
        # For demonstration, compare with initial distribution
        for node, keys_assigned in distribution.items():
            if key in keys_assigned:
                old_node = node
                break
        
        new_node = ch.get_node(key)
        if old_node != new_node:
            moved += 1
    
    print(f"\n📊 Keys moved: {moved}/{len(keys)} ({moved/len(keys)*100:.1f}%)")
    print(f"   Consistent hashing minimizes reshuffling when nodes change")
    
    stats = ch.get_stats()
    print(f"\n📊 Ring Stats:")
    print(f"   Nodes: {stats['node_count']}")
    print(f"   Virtual nodes per node: {stats['virtual_nodes_per_node']}")
    print(f"   Ring size: {stats['ring_size']}")

def main():
    """Run partitioning demonstrations"""
    demo_partitioning()
    demo_consistent_hashing()
    
    print("\n" + "="*60)
    print("✅ PARTITIONING AND SHARDING DEMONSTRATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 8.3 Replication Models

### The Concept

Replication is like having backup copies of important documents - if one copy is lost or damaged, you have others to rely on.

### The Implementation

**File: `part-08-scalability/replication_models.py`**
```python
#!/usr/bin/env python3
"""
Replication Models Implementation
"""

import time
import threading
import random
from typing import Dict, List, Any, Optional, Set
from dataclasses import dataclass
from enum import Enum

class ReplicationStrategy(Enum):
    """Replication strategies"""
    LEADER_FOLLOWER = "leader_follower"
    MULTI_LEADER = "multi_leader"
    LEADERLESS = "leaderless"

@dataclass
class ReplicaNode:
    """A replica node"""
    node_id: str
    data: Dict[str, Any]
    is_leader: bool = False
    is_healthy: bool = True
    last_update_time: float = 0
    replication_lag: float = 0

class ReplicationManager:
    """
    Manages data replication across nodes
    """
    
    def __init__(self, strategy: ReplicationStrategy = ReplicationStrategy.LEADER_FOLLOWER):
        self.strategy = strategy
        self.nodes: Dict[str, ReplicaNode] = {}
        self.write_log: List[Dict[str, Any]] = []
        self.replication_queue: List[Dict[str, Any]] = []
        self.quorum_size = 2
        
    def add_node(self, node_id: str, is_leader: bool = False):
        """Add a replica node"""
        node = ReplicaNode(
            node_id=node_id,
            data={},
            is_leader=is_leader
        )
        self.nodes[node_id] = node
    
    def write(self, key: str, value: Any, timeout: float = 5.0) -> bool:
        """Write data with replication"""
        start_time = time.time()
        successful_writes = 0
        
        if self.strategy == ReplicationStrategy.LEADER_FOLLOWER:
            return self._leader_follower_write(key, value)
        elif self.strategy == ReplicationStrategy.MULTI_LEADER:
            return self._multi_leader_write(key, value)
        elif self.strategy == ReplicationStrategy.LEADERLESS:
            return self._leaderless_write(key, value, timeout)
        
        return False
    
    def _leader_follower_write(self, key: str, value: Any) -> bool:
        """Leader-follower replication write"""
        # Find leader
        leader = None
        for node in self.nodes.values():
            if node.is_leader and node.is_healthy:
                leader = node
                break
        
        if leader is None:
            print(f"   ❌ No leader available")
            return False
        
        # Write to leader
        leader.data[key] = value
        leader.last_update_time = time.time()
        
        # Log write
        self.write_log.append({
            'key': key,
            'value': value,
            'timestamp': time.time(),
            'leader': leader.node_id
        })
        
        # Replicate to followers (asynchronously)
        for node_id, node in self.nodes.items():
            if node_id != leader.node_id and node.is_healthy:
                # Simulate asynchronous replication
                threading.Thread(target=self._replicate_to_follower, 
                               args=(node, key, value)).start()
        
        print(f"   ✅ Leader {leader.node_id} wrote {key}={value}")
        return True
    
    def _replicate_to_follower(self, follower: ReplicaNode, key: str, value: Any):
        """Replicate data to a follower"""
        # Simulate replication delay
        delay = random.uniform(0.01, 0.1)
        time.sleep(delay)
        
        follower.data[key] = value
        follower.last_update_time = time.time()
        follower.replication_lag = delay
        
        print(f"   📋 Replicated {key} to follower {follower.node_id} (lag: {delay:.3f}s)")
    
    def _multi_leader_write(self, key: str, value: Any) -> bool:
        """Multi-leader replication write"""
        # All leaders accept writes
        leaders = [n for n in self.nodes.values() if n.is_leader and n.is_healthy]
        
        if not leaders:
            return False
        
        # Write to all leaders
        for leader in leaders:
            leader.data[key] = value
            leader.last_update_time = time.time()
            
            # Replicate to other leaders
            for other_leader in leaders:
                if other_leader.node_id != leader.node_id:
                    # Simulate cross-leader replication
                    threading.Thread(target=self._replicate_to_leader,
                                   args=(other_leader, key, value)).start()
        
        print(f"   ✅ Multi-leader write: {len(leaders)} leaders updated")
        return True
    
    def _replicate_to_leader(self, leader: ReplicaNode, key: str, value: Any):
        """Replicate between leaders"""
        time.sleep(random.uniform(0.02, 0.15))
        leader.data[key] = value
        leader.last_update_time = time.time()
    
    def _leaderless_write(self, key: str, value: Any, timeout: float) -> bool:
        """Leaderless replication (quorum-based) write"""
        healthy_nodes = [n for n in self.nodes.values() if n.is_healthy]
        
        if len(healthy_nodes) < self.quorum_size:
            print(f"   ❌ Not enough healthy nodes ({len(healthy_nodes)} < {self.quorum_size})")
            return False
        
        # Write to nodes until we achieve quorum
        successful_writes = 0
        start_time = time.time()
        
        for node in healthy_nodes:
            if time.time() - start_time > timeout:
                break
            
            # Simulate write
            if random.random() < 0.9:  # 90% success rate
                node.data[key] = value
                node.last_update_time = time.time()
                successful_writes += 1
                print(f"   ✅ Wrote to {node.node_id}")
            else:
                print(f"   ❌ Failed to write to {node.node_id}")
            
            if successful_writes >= self.quorum_size:
                print(f"   ✅ Quorum achieved: {successful_writes} writes")
                return True
        
        print(f"   ❌ Quorum failed: {successful_writes}/{self.quorum_size} writes")
        return False
    
    def read(self, key: str) -> Optional[Any]:
        """Read data (with quorum for leaderless)"""
        if self.strategy == ReplicationStrategy.LEADER_FOLLOWER:
            # Read from leader
            leader = None
            for node in self.nodes.values():
                if node.is_leader and node.is_healthy:
                    leader = node
                    break
            
            if leader and key in leader.data:
                return leader.data[key]
        
        elif self.strategy == ReplicationStrategy.MULTI_LEADER:
            # Read from any leader
            for node in self.nodes.values():
                if node.is_leader and node.is_healthy:
                    if key in node.data:
                        return node.data[key]
        
        elif self.strategy == ReplicationStrategy.LEADERLESS:
            # Read quorum
            healthy_nodes = [n for n in self.nodes.values() if n.is_healthy]
            values = []
            for node in healthy_nodes:
                if key in node.data:
                    values.append(node.data[key])
            
            if len(values) >= self.quorum_size:
                # Return the most recent value
                return values[-1]
        
        return None
    
    def get_stats(self) -> Dict[str, Any]:
        """Get replication statistics"""
        return {
            'strategy': self.strategy.value,
            'node_count': len(self.nodes),
            'healthy_nodes': sum(1 for n in self.nodes.values() if n.is_healthy),
            'write_log_size': len(self.write_log),
            'nodes': [
                {
                    'id': n.node_id,
                    'is_leader': n.is_leader,
                    'is_healthy': n.is_healthy,
                    'data_count': len(n.data),
                    'replication_lag': n.replication_lag
                }
                for n in self.nodes.values()
            ]
        }

def demo_replication():
    """Demonstrate replication models"""
    print("="*60)
    print("REPLICATION MODELS DEMONSTRATION")
    print("="*60)
    
    # Test each replication strategy
    strategies = [
        (ReplicationStrategy.LEADER_FOLLOWER, "Leader-Follower"),
        (ReplicationStrategy.MULTI_LEADER, "Multi-Leader"),
        (ReplicationStrategy.LEADERLESS, "Leaderless")
    ]
    
    for strategy, name in strategies:
        print(f"\n📊 {name} Replication:")
        print("-" * 40)
        
        rm = ReplicationManager(strategy=strategy)
        
        # Add nodes
        if strategy == ReplicationStrategy.LEADER_FOLLOWER:
            rm.add_node("leader1", is_leader=True)
            rm.add_node("follower1")
            rm.add_node("follower2")
            print("   Nodes: 1 leader, 2 followers")
            
        elif strategy == ReplicationStrategy.MULTI_LEADER:
            rm.add_node("leader1", is_leader=True)
            rm.add_node("leader2", is_leader=True)
            rm.add_node("leader3", is_leader=True)
            print("   Nodes: 3 leaders (all accept writes)")
            
        elif strategy == ReplicationStrategy.LEADERLESS:
            rm.add_node("node1")
            rm.add_node("node2")
            rm.add_node("node3")
            rm.add_node("node4")
            rm.add_node("node5")
            rm.quorum_size = 3
            print("   Nodes: 5 nodes, quorum size 3")
        
        # Write data
        print("\n📝 Writing data:")
        rm.write("user:001", {"name": "Alice", "age": 30})
        rm.write("user:002", {"name": "Bob", "age": 25})
        
        # Read data
        print("\n📖 Reading data:")
        for key in ["user:001", "user:002"]:
            value = rm.read(key)
            if value:
                print(f"   {key}: {value}")
        
        # Show stats
        stats = rm.get_stats()
        print(f"\n📊 Stats:")
        print(f"   Strategy: {stats['strategy']}")
        print(f"   Nodes: {stats['node_count']}")
        for node_stats in stats['nodes']:
            status = "✅" if node_stats['is_healthy'] else "❌"
            role = "Leader" if node_stats['is_leader'] else "Follower"
            print(f"   {status} {node_stats['id']}: {role}, {node_stats['data_count']} keys")
    
    print("\n🎯 Replication Model Summary:")
    print("   • Leader-Follower: Simple, consistent, but single point of failure")
    print("   • Multi-Leader: High availability, complex conflict resolution")
    print("   • Leaderless: Highly available, eventual consistency")

def demo_failover():
    """Demonstrate failover scenarios"""
    print("\n" + "="*60)
    print("FAILOVER DEMONSTRATION")
    print("="*60)
    
    rm = ReplicationManager(strategy=ReplicationStrategy.LEADER_FOLLOWER)
    rm.add_node("leader1", is_leader=True)
    rm.add_node("follower1")
    rm.add_node("follower2")
    
    print("📊 Initial state: 1 leader, 2 followers")
    
    # Write some data
    rm.write("key1", "value1")
    rm.write("key2", "value2")
    
    # Simulate leader failure
    print("\n💥 Simulating leader failure...")
    for node in rm.nodes.values():
        if node.is_leader:
            node.is_healthy = False
            print(f"   {node.node_id} is now offline")
    
    # Need to elect a new leader
    print("\n🔄 Electing new leader...")
    new_leader = None
    for node in rm.nodes.values():
        if node.is_healthy and not node.is_leader:
            node.is_leader = True
            new_leader = node
            break
    
    if new_leader:
        print(f"   {new_leader.node_id} elected as new leader")
        
        # Write with new leader
        print("\n📝 Writing with new leader:")
        rm.write("key3", "value3")
        
        # Read data
        print("\n📖 Reading data:")
        for key in ["key1", "key2", "key3"]:
            value = rm.read(key)
            if value:
                print(f"   {key}: {value}")
    
    # Show final state
    stats = rm.get_stats()
    print(f"\n📊 Final State:")
    for node_stats in stats['nodes']:
        status = "✅" if node_stats['is_healthy'] else "❌"
        role = "Leader" if node_stats['is_leader'] else "Follower"
        print(f"   {status} {node_stats['id']}: {role}")

def main():
    """Run replication demonstrations"""
    demo_replication()
    demo_failover()
    
    print("\n" + "="*60)
    print("✅ REPLICATION DEMONSTRATIONS COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 8.4 High Availability and Disaster Recovery

### The Concept

High Availability ensures systems remain operational despite failures. Disaster Recovery handles catastrophic failures through backups and geographic redundancy.

### The Implementation

**File: `part-08-scalability/ha_dr.py`**
```python
#!/usr/bin/env python3
"""
High Availability and Disaster Recovery Implementation
"""

import time
import json
import random
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class Backup:
    """A backup of data"""
    backup_id: str
    timestamp: float
    data: Dict[str, Any]
    type: str  # full, incremental
    size_mb: float
    location: str

@dataclass
class DisasterRecoveryPlan:
    """A disaster recovery plan"""
    name: str
    rpo_seconds: int  # Recovery Point Objective
    rto_seconds: int  # Recovery Time Objective
    backup_frequency_seconds: int
    region_pairs: List[str]
    status: str = "active"

class HighAvailabilityManager:
    """
    Manages high availability and disaster recovery
    """
    
    def __init__(self):
        self.primary_region: str = "us-east-1"
        self.secondary_regions: List[str] = ["us-west-1", "eu-west-1"]
        self.backups: Dict[str, List[Backup]] = {}
        self.current_data: Dict[str, Any] = {}
        self.backup_schedule: Dict[str, int] = {}  # region -> last_backup_time
        self.active_region = self.primary_region
        self.dr_plan: Optional[DisasterRecoveryPlan] = None
        
    def set_dr_plan(self, plan: DisasterRecoveryPlan):
        """Set the disaster recovery plan"""
        self.dr_plan = plan
        print(f"📋 DR Plan set: {plan.name}")
        print(f"   RPO: {plan.rpo_seconds}s, RTO: {plan.rto_seconds}s")
    
    def write_data(self, key: str, value: Any, region: str = None) -> bool:
        """Write data with cross-region replication"""
        if region is None:
            region = self.active_region
        
        # Write to primary
        self.current_data[key] = value
        
        # Replicate to secondary regions
        for sec_region in self.secondary_regions:
            if sec_region != region:
                # Simulate cross-region replication
                delay = random.uniform(0.01, 0.05)
                time.sleep(delay)
                print(f"   🌐 Replicated {key} to {sec_region}")
        
        # Check if backup needed
        self._check_backup_needed(region)
        
        return True
    
    def _check_backup_needed(self, region: str):
        """Check if a backup is needed based on schedule"""
        if not self.dr_plan:
            return
        
        last_backup = self.backup_schedule.get(region, 0)
        now = time.time()
        
        if now - last_backup >= self.dr_plan.backup_frequency_seconds:
            self.create_backup(region)
            self.backup_schedule[region] = now
    
    def create_backup(self, region: str) -> Backup:
        """Create a backup of data"""
        backup = Backup(
            backup_id=f"backup_{int(time.time())}_{region}",
            timestamp=time.time(),
            data=self.current_data.copy(),
            type="full",
            size_mb=len(str(self.current_data)) / (1024 * 1024),
            location=region
        )
        
        if region not in self.backups:
            self.backups[region] = []
        
        self.backups[region].append(backup)
        print(f"   💾 Backup created: {backup.backup_id}")
        
        # Clean up old backups (keep last 10)
        if len(self.backups[region]) > 10:
            oldest = self.backups[region].pop(0)
            print(f"   🗑️ Removed old backup: {oldest.backup_id}")
        
        return backup
    
    def restore_from_backup(self, backup_id: str) -> bool:
        """Restore data from a backup"""
        for region, backups in self.backups.items():
            for backup in backups:
                if backup.backup_id == backup_id:
                    self.current_data = backup.data.copy()
                    print(f"   🔄 Restored from backup: {backup_id}")
                    return True
        
        print(f"   ❌ Backup {backup_id} not found")
        return False
    
    def failover_to_region(self, region: str) -> bool:
        """Failover to a different region"""
        if region not in self.secondary_regions and region != self.primary_region:
            return False
        
        print(f"🔀 Failing over to {region}")
        
        # Simulate failover
        self.active_region = region
        print(f"   ✅ Active region now: {region}")
        
        # Check if we need to restore data
        # In reality, we'd sync from replicated data
        
        return True
    
    def simulate_disaster(self):
        """Simulate a disaster scenario"""
        print("\n💥 DISASTER SIMULATED:")
        print(f"   Primary region {self.primary_region} is DOWN!")
        print(f"   Starting disaster recovery...")
        
        start_time = time.time()
        
        # Find a healthy region
        healthy_region = None
        for region in self.secondary_regions:
            # Simulate health check
            if random.random() < 0.9:  # 90% chance healthy
                healthy_region = region
                break
        
        if healthy_region:
            # Failover
            self.failover_to_region(healthy_region)
            
            # Restore latest backup if needed
            if self.backups.get(healthy_region):
                latest_backup = self.backups[healthy_region][-1]
                self.restore_from_backup(latest_backup.backup_id)
            
            # Recovery time
            rto_actual = time.time() - start_time
            print(f"\n   ✅ Recovery complete!")
            print(f"   RTO achieved: {rto_actual:.2f}s")
            
            if self.dr_plan:
                meets_rto = rto_actual <= self.dr_plan.rto_seconds
                print(f"   Meets RTO ({self.dr_plan.rto_seconds}s): {'✅' if meets_rto else '❌'}")
        else:
            print(f"   ❌ No healthy region available!")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get HA/DR statistics"""
        return {
            'active_region': self.active_region,
            'primary_region': self.primary_region,
            'secondary_regions': self.secondary_regions,
            'data_size': len(str(self.current_data)),
            'backup_count': sum(len(bs) for bs in self.backups.values()),
            'backups_by_region': {
                region: len(backups) for region, backups in self.backups.items()
            }
        }

def demo_ha_dr():
    """Demonstrate High Availability and Disaster Recovery"""
    print("="*60)
    print("HIGH AVAILABILITY AND DISASTER RECOVERY")
    print("="*60)
    
    # Create HA manager
    ha = HighAvailabilityManager()
    
    # Set DR plan
    plan = DisasterRecoveryPlan(
        name="Production DR Plan",
        rpo_seconds=300,  # 5 minutes
        rto_seconds=600,  # 10 minutes
        backup_frequency_seconds=60,  # 1 minute
        region_pairs=["us-east-1", "us-west-1"]
    )
    ha.set_dr_plan(plan)
    
    # Write data
    print("\n📝 Writing data with cross-region replication:")
    for i in range(5):
        ha.write_data(f"key_{i}", f"value_{i}")
        time.sleep(0.1)
    
    # Show backups
    print(f"\n📊 Backup Status:")
    stats = ha.get_stats()
    print(f"   Total backups: {stats['backup_count']}")
    for region, count in stats['backups_by_region'].items():
        print(f"   {region}: {count} backups")
    
    # Show data
    print(f"\n📊 Current Data:")
    print(f"   {ha.current_data}")
    
    # Simulate disaster
    ha.simulate_disaster()
    
    # Show final state
    print(f"\n📊 Final State:")
    stats = ha.get_stats()
    print(f"   Active region: {stats['active_region']}")
    print(f"   Data size: {stats['data_size']} bytes")
    print(f"   Backups available: {stats['backup_count']}")

def main():
    """Run HA/DR demonstration"""
    demo_ha_dr()
    
    print("\n" + "="*60)
    print("✅ HIGH AVAILABILITY DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-08-scalability

# Run the scaling strategies demonstration
python scaling_strategies.py

# Run the partitioning and sharding demonstration
python partitioning_sharding.py

# Run the replication models demonstration
python replication_models.py

# Run the high availability demonstration
python ha_dr.py

# Expected output:
# ============================================================
# SCALING STRATEGIES DEMONSTRATION
# ============================================================
# 
# 📊 VERTICAL SCALING (Scale Up):
# ----------------------------------------
#    Initial: 2 cores, 4GB RAM, 50GB disk
#    Scaled up: 8 cores, 32GB RAM, 200GB disk
#    ✅ Vertical scaling can handle more load on the same machine
# 
# 📊 HORIZONTAL SCALING (Scale Out):
# ----------------------------------------
#    Distributed load across multiple nodes:
#    Request 1 → app_server_0 (load: 0.2)
#    Request 2 → app_server_1 (load: 0.2)
#    ...
# 
# 📊 ELASTIC SCALING:
# ----------------------------------------
#    Starting with 2 nodes
#    Simulating load changes:
#    Load: 0.3 → 2 nodes
#    Load: 0.5 → 2 nodes
#    Load: 0.8 → 3 nodes
#    ...
# 
# ============================================================
# ✅ SCALING DEMONSTRATION COMPLETE
# ============================================================
```

---

## Part 8 Recap

You have successfully:

✅ Implemented vertical, horizontal, and elastic scaling strategies  
✅ Built load balancers with multiple strategies  
✅ Implemented data partitioning and sharding  
✅ Created consistent hashing for distributed systems  
✅ Implemented leader-follower, multi-leader, and leaderless replication  
✅ Built automatic failover and recovery mechanisms  
✅ Implemented backup management for disaster recovery  
✅ Created comprehensive high availability systems  

### Key Takeaways

1. **Vertical Scaling** adds resources to existing machines (limited)
2. **Horizontal Scaling** adds more machines (virtually unlimited)
3. **Elastic Scaling** automatically adjusts to demand
4. **Partitioning** distributes data across nodes for scalability
5. **Consistent Hashing** minimizes data movement during scaling
6. **Replication** provides redundancy and high availability
7. **Failover** enables automatic recovery from failures
8. **Disaster Recovery** protects against catastrophic failures
9. **RPO/RTO** define recovery objectives and limits
