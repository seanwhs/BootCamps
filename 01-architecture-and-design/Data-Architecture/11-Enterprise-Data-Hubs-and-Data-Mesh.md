# Part 11: Enterprise Data Hubs and Data Mesh

Welcome to Part 11, where we explore how large organizations design enterprise-wide data platforms that connect producers and consumers through governed data products. Think of this like a modern city's infrastructure—different neighborhoods (domains) produce and consume services, connected by a network of roads and governed by city planning (governance).

## Learning Objectives

By the end of this part, you will be able to:

- Design enterprise data hubs and operational data stores
- Implement domain-driven data mesh architecture
- Build data products with contracts
- Create event-driven integration patterns
- Implement API-first data sharing
- Design hybrid cloud integration

---

## 11.1 Enterprise Data Hub Architecture

### The Concept

An Enterprise Data Hub is like a central marketplace where data producers and consumers connect. It provides a unified platform for data discovery, sharing, and governance while maintaining domain ownership.

### The Implementation

**File: `part-11-data-hubs/enterprise_hub.py`**
```python
#!/usr/bin/env python3
"""
Enterprise Data Hub Implementation
Central platform for data discovery, sharing, and governance
"""

import time
import json
import hashlib
from typing import Dict, List, Any, Optional, Set
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum

class DataAssetType(Enum):
    """Types of data assets"""
    DATASET = "dataset"
    API = "api"
    STREAM = "stream"
    REPORT = "report"
    MODEL = "model"

class AssetStatus(Enum):
    """Status of a data asset"""
    DRAFT = "draft"
    PUBLISHED = "published"
    DEPRECATED = "deprecated"
    ARCHIVED = "archived"

@dataclass
class DataAsset:
    """A data asset in the enterprise hub"""
    asset_id: str
    name: str
    description: str
    asset_type: DataAssetType
    domain: str
    owner: str
    status: AssetStatus
    schema: Dict[str, str]
    tags: List[str]
    created_at: float
    updated_at: float
    version: int
    usage_count: int = 0
    quality_score: float = 0.0
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'asset_id': self.asset_id,
            'name': self.name,
            'description': self.description,
            'asset_type': self.asset_type.value,
            'domain': self.domain,
            'owner': self.owner,
            'status': self.status.value,
            'schema': self.schema,
            'tags': self.tags,
            'created_at': self.created_at,
            'updated_at': self.updated_at,
            'version': self.version,
            'usage_count': self.usage_count,
            'quality_score': self.quality_score
        }

@dataclass
class DataContract:
    """A data contract between producer and consumer"""
    contract_id: str
    asset_id: str
    consumer: str
    format: str
    frequency: str
    sla: Dict[str, Any]
    created_at: float
    last_accessed: float
    status: str = "active"  # active, suspended, expired

class EnterpriseDataHub:
    """
    Enterprise Data Hub implementation
    """
    
    def __init__(self, name: str):
        self.name = name
        self.assets: Dict[str, DataAsset] = {}
        self.contracts: Dict[str, DataContract] = {}
        self.domains: Set[str] = set()
        self.publish_log: List[Dict[str, Any]] = []
        self.usage_log: List[Dict[str, Any]] = []
        
        print(f"🏛️ Enterprise Data Hub initialized: {name}")
    
    def register_domain(self, domain: str, description: str = ""):
        """Register a domain in the hub"""
        self.domains.add(domain)
        print(f"   🌐 Domain registered: {domain}")
    
    def publish_asset(self, asset: DataAsset) -> str:
        """Publish a data asset"""
        if asset.asset_id in self.assets:
            # Update existing asset
            self.assets[asset.asset_id] = asset
            print(f"   📝 Updated asset: {asset.name}")
        else:
            # New asset
            self.assets[asset.asset_id] = asset
            self.domains.add(asset.domain)
            print(f"   📤 Published asset: {asset.name}")
        
        self.publish_log.append({
            'asset_id': asset.asset_id,
            'action': 'publish',
            'timestamp': time.time(),
            'version': asset.version
        })
        
        return asset.asset_id
    
    def discover_assets(self, domain: str = None, 
                       asset_type: DataAssetType = None,
                       tags: List[str] = None,
                       search: str = None) -> List[DataAsset]:
        """Discover data assets"""
        results = list(self.assets.values())
        
        # Filter by domain
        if domain:
            results = [a for a in results if a.domain == domain]
        
        # Filter by type
        if asset_type:
            results = [a for a in results if a.asset_type == asset_type]
        
        # Filter by tags
        if tags:
            results = [a for a in results if any(t in a.tags for t in tags)]
        
        # Filter by search text
        if search:
            search_lower = search.lower()
            results = [a for a in results 
                      if search_lower in a.name.lower() 
                      or search_lower in a.description.lower()
                      or any(search_lower in tag.lower() for tag in a.tags)]
        
        # Sort by quality score
        results.sort(key=lambda a: a.quality_score, reverse=True)
        
        print(f"   🔍 Discovered {len(results)} assets")
        return results
    
    def create_contract(self, asset_id: str, consumer: str,
                       format: str = "json", frequency: str = "daily",
                       sla: Dict[str, Any] = None) -> str:
        """Create a data contract between producer and consumer"""
        if asset_id not in self.assets:
            print(f"   ❌ Asset {asset_id} not found")
            return None
        
        asset = self.assets[asset_id]
        contract_id = f"contract_{int(time.time())}_{hashlib.md5(asset_id.encode()).hexdigest()[:8]}"
        
        contract = DataContract(
            contract_id=contract_id,
            asset_id=asset_id,
            consumer=consumer,
            format=format,
            frequency=frequency,
            sla=sla or {"availability": "99.9%", "latency": "500ms"},
            created_at=time.time(),
            last_accessed=0
        )
        
        self.contracts[contract_id] = contract
        self.usage_log.append({
            'contract_id': contract_id,
            'asset_id': asset_id,
            'consumer': consumer,
            'action': 'create_contract',
            'timestamp': time.time()
        })
        
        print(f"   📋 Contract created: {contract_id} for {consumer}")
        return contract_id
    
    def access_asset(self, contract_id: str) -> Optional[Dict[str, Any]]:
        """Access a data asset through a contract"""
        if contract_id not in self.contracts:
            print(f"   ❌ Contract {contract_id} not found")
            return None
        
        contract = self.contracts[contract_id]
        asset = self.assets.get(contract.asset_id)
        
        if not asset:
            print(f"   ❌ Asset {contract.asset_id} not found")
            return None
        
        # Update usage
        contract.last_accessed = time.time()
        asset.usage_count += 1
        
        self.usage_log.append({
            'contract_id': contract_id,
            'asset_id': contract.asset_id,
            'consumer': contract.consumer,
            'action': 'access',
            'timestamp': time.time()
        })
        
        print(f"   📖 Asset accessed: {asset.name} by {contract.consumer}")
        
        # Return asset data (simulated)
        return {
            'asset': asset.to_dict(),
            'contract': {
                'contract_id': contract.contract_id,
                'format': contract.format,
                'frequency': contract.frequency,
                'sla': contract.sla
            },
            'accessed_at': time.time()
        }
    
    def get_asset_usage_stats(self, asset_id: str) -> Dict[str, Any]:
        """Get usage statistics for an asset"""
        if asset_id not in self.assets:
            return {}
        
        asset = self.assets[asset_id]
        contract_count = sum(1 for c in self.contracts.values() if c.asset_id == asset_id)
        access_count = sum(1 for l in self.usage_log if l['asset_id'] == asset_id and l['action'] == 'access')
        
        return {
            'asset_id': asset_id,
            'name': asset.name,
            'total_contracts': contract_count,
            'total_accesses': access_count,
            'unique_consumers': len(set(c.consumer for c in self.contracts.values() 
                                      if c.asset_id == asset_id))
        }
    
    def deprecate_asset(self, asset_id: str) -> bool:
        """Deprecate a data asset"""
        if asset_id not in self.assets:
            return False
        
        asset = self.assets[asset_id]
        asset.status = AssetStatus.DEPRECATED
        asset.updated_at = time.time()
        
        self.publish_log.append({
            'asset_id': asset_id,
            'action': 'deprecate',
            'timestamp': time.time()
        })
        
        print(f"   ⚠️ Asset deprecated: {asset.name}")
        return True
    
    def get_hub_stats(self) -> Dict[str, Any]:
        """Get hub statistics"""
        active_assets = [a for a in self.assets.values() if a.status == AssetStatus.PUBLISHED]
        
        return {
            'name': self.name,
            'total_assets': len(self.assets),
            'active_assets': len(active_assets),
            'domains': len(self.domains),
            'total_contracts': len(self.contracts),
            'total_accesses': len([l for l in self.usage_log if l['action'] == 'access']),
            'avg_quality_score': sum(a.quality_score for a in self.assets.values()) / len(self.assets) if self.assets else 0
        }

def demo_enterprise_hub():
    """Demonstrate Enterprise Data Hub"""
    print("="*60)
    print("ENTERPRISE DATA HUB DEMONSTRATION")
    print("="*60)
    
    # Create hub
    hub = EnterpriseDataHub("Global Data Hub")
    
    # Register domains
    print("\n📋 Registering domains...")
    hub.register_domain("Sales", "Sales and revenue data")
    hub.register_domain("Marketing", "Marketing and campaign data")
    hub.register_domain("Engineering", "Engineering and product data")
    
    # Create and publish assets
    print("\n📤 Publishing assets...")
    
    # Sales assets
    sales_asset = DataAsset(
        asset_id="sales_customers",
        name="Customer Master",
        description="Master customer data including demographics and preferences",
        asset_type=DataAssetType.DATASET,
        domain="Sales",
        owner="sales-team@company.com",
        status=AssetStatus.PUBLISHED,
        schema={"customer_id": "string", "name": "string", "email": "string", "segment": "string"},
        tags=["customer", "master-data", "pii"],
        created_at=time.time(),
        updated_at=time.time(),
        version=1,
        quality_score=0.95
    )
    hub.publish_asset(sales_asset)
    
    sales_orders = DataAsset(
        asset_id="sales_orders",
        name="Order History",
        description="Historical orders including items, amounts, and status",
        asset_type=DataAssetType.DATASET,
        domain="Sales",
        owner="sales-team@company.com",
        status=AssetStatus.PUBLISHED,
        schema={"order_id": "string", "customer_id": "string", "amount": "float", "status": "string"},
        tags=["orders", "transactions", "historical"],
        created_at=time.time(),
        updated_at=time.time(),
        version=2,
        quality_score=0.98
    )
    hub.publish_asset(sales_orders)
    
    # Marketing asset
    marketing_asset = DataAsset(
        asset_id="marketing_campaigns",
        name="Campaign Performance",
        description="Marketing campaign performance metrics",
        asset_type=DataAssetType.REPORT,
        domain="Marketing",
        owner="marketing-team@company.com",
        status=AssetStatus.PUBLISHED,
        schema={"campaign_id": "string", "name": "string", "impressions": "int", "conversions": "int"},
        tags=["marketing", "campaigns", "metrics"],
        created_at=time.time(),
        updated_at=time.time(),
        version=1,
        quality_score=0.92
    )
    hub.publish_asset(marketing_asset)
    
    # Engineering asset
    eng_asset = DataAsset(
        asset_id="eng_services",
        name="Microservice Health",
        description="Service health and performance metrics",
        asset_type=DataAssetType.API,
        domain="Engineering",
        owner="platform-team@company.com",
        status=AssetStatus.PUBLISHED,
        schema={"service_id": "string", "status": "string", "latency": "float", "error_rate": "float"},
        tags=["monitoring", "health", "performance"],
        created_at=time.time(),
        updated_at=time.time(),
        version=3,
        quality_score=0.99
    )
    hub.publish_asset(eng_asset)
    
    # Discover assets
    print("\n🔍 Discovering assets...")
    
    print("\n   All assets:")
    all_assets = hub.discover_assets()
    for asset in all_assets:
        print(f"   • {asset.name} ({asset.domain}) - {asset.asset_type.value}")
    
    print("\n   Sales domain assets:")
    sales_assets = hub.discover_assets(domain="Sales")
    for asset in sales_assets:
        print(f"   • {asset.name} - quality: {asset.quality_score:.0%}")
    
    print("\n   Assets tagged with 'customer':")
    customer_assets = hub.discover_assets(tags=["customer"])
    for asset in customer_assets:
        print(f"   • {asset.name}")
    
    # Create contracts
    print("\n📋 Creating data contracts...")
    
    contract1 = hub.create_contract(
        asset_id="sales_customers",
        consumer="Analytics Team",
        format="json",
        frequency="daily",
        sla={"availability": "99.5%", "latency": "200ms"}
    )
    
    contract2 = hub.create_contract(
        asset_id="sales_orders",
        consumer="Finance Team",
        format="csv",
        frequency="hourly"
    )
    
    # Access assets
    print("\n📖 Accessing assets through contracts...")
    
    if contract1:
        data = hub.access_asset(contract1)
        if data:
            print(f"   Accessed: {data['asset']['name']}")
            print(f"   Format: {data['contract']['format']}")
    
    if contract2:
        data = hub.access_asset(contract2)
        if data:
            print(f"   Accessed: {data['asset']['name']}")
            print(f"   Format: {data['contract']['format']}")
    
    # Show usage stats
    print("\n📊 Asset usage statistics:")
    for asset_id in ["sales_customers", "sales_orders"]:
        stats = hub.get_asset_usage_stats(asset_id)
        if stats:
            print(f"   {stats['name']}:")
            print(f"      Contracts: {stats['total_contracts']}")
            print(f"      Accesses: {stats['total_accesses']}")
            print(f"      Consumers: {stats['unique_consumers']}")
    
    # Deprecate an asset
    print("\n⚠️ Deprecating an asset...")
    hub.deprecate_asset("marketing_campaigns")
    
    # Hub statistics
    stats = hub.get_hub_stats()
    print(f"\n📊 Hub Statistics:")
    print(f"   Name: {stats['name']}")
    print(f"   Total Assets: {stats['total_assets']}")
    print(f"   Active Assets: {stats['active_assets']}")
    print(f"   Domains: {stats['domains']}")
    print(f"   Total Contracts: {stats['total_contracts']}")
    print(f"   Total Accesses: {stats['total_accesses']}")
    print(f"   Average Quality: {stats['avg_quality_score']:.1%}")

def main():
    """Run enterprise hub demonstration"""
    demo_enterprise_hub()
    
    print("\n" + "="*60)
    print("✅ ENTERPRISE DATA HUB DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 11.2 Data Mesh Architecture

### The Concept

Data Mesh is a decentralized data architecture where domains own and operate their data products. Think of it as moving from a central supermarket (data lake) to neighborhoods with their own specialty stores (domain data products) connected by a common marketplace (data mesh).

### The Implementation

**File: `part-11-data-hubs/data_mesh.py`**
```python
#!/usr/bin/env python3
"""
Data Mesh Architecture Implementation
Decentralized data with domain ownership
"""

import time
import json
import uuid
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime

@dataclass
class DataProduct:
    """A data product owned by a domain"""
    product_id: str
    name: str
    description: str
    domain: str
    owner_team: str
    version: int
    schema: Dict[str, str]
    quality_metrics: Dict[str, float]
    published_at: float
    updated_at: float
    status: str  # active, deprecated, archived

@dataclass
class DataMeshNode:
    """A node in the data mesh (domain)"""
    node_id: str
    name: str
    description: str
    owner: str
    data_products: Dict[str, DataProduct]
    dependencies: List[str]
    status: str  # active, degraded, offline

class DataMesh:
    """
    Data Mesh implementation
    Decentralized data architecture
    """
    
    def __init__(self, name: str):
        self.name = name
        self.nodes: Dict[str, DataMeshNode] = {}
        self.interfaces: Dict[str, Dict[str, Any]] = {}  # Interface registry
        self.query_log: List[Dict[str, Any]] = []
        self.governance_policies: Dict[str, Dict[str, Any]] = {}
        
        print(f"🕸️ Data Mesh initialized: {name}")
    
    def register_domain(self, node_id: str, name: str, 
                       description: str, owner: str) -> str:
        """Register a domain as a node in the mesh"""
        if node_id in self.nodes:
            print(f"   ⚠️ Node {node_id} already exists")
            return node_id
        
        node = DataMeshNode(
            node_id=node_id,
            name=name,
            description=description,
            owner=owner,
            data_products={},
            dependencies=[],
            status="active"
        )
        self.nodes[node_id] = node
        print(f"   🌐 Domain registered: {name} ({node_id})")
        return node_id
    
    def publish_data_product(self, node_id: str, product: DataProduct) -> bool:
        """Publish a data product from a domain"""
        if node_id not in self.nodes:
            print(f"   ❌ Node {node_id} not found")
            return False
        
        node = self.nodes[node_id]
        
        # Check if product exists
        if product.product_id in node.data_products:
            # Update existing
            node.data_products[product.product_id] = product
            print(f"   📝 Updated data product: {product.name}")
        else:
            # New product
            node.data_products[product.product_id] = product
            print(f"   📤 Published data product: {product.name}")
        
        # Register interface
        self.interfaces[product.product_id] = {
            'product_id': product.product_id,
            'domain': product.domain,
            'owner': product.owner_team,
            'schema': product.schema,
            'version': product.version,
            'published_at': product.published_at
        }
        
        return True
    
    def query_data_product(self, product_id: str, 
                          filters: Dict[str, Any] = None) -> Optional[Dict[str, Any]]:
        """Query a data product across the mesh"""
        if product_id not in self.interfaces:
            print(f"   ❌ Data product {product_id} not found")
            return None
        
        # Find which node owns this product
        owner_node = None
        for node_id, node in self.nodes.items():
            if product_id in node.data_products:
                owner_node = node
                break
        
        if not owner_node:
            print(f"   ❌ Owner node not found for product {product_id}")
            return None
        
        product = owner_node.data_products[product_id]
        
        # Simulate query
        self.query_log.append({
            'product_id': product_id,
            'domain': product.domain,
            'timestamp': time.time(),
            'filters': filters
        })
        
        # Return simulated data
        data = {
            'product_id': product_id,
            'name': product.name,
            'domain': product.domain,
            'data': [
                {'id': i, 'value': f"Sample data {i}"} 
                for i in range(5)
            ],
            'quality_metrics': product.quality_metrics
        }
        
        print(f"   📊 Queried: {product.name} from {product.domain}")
        return data
    
    def add_dependency(self, from_node_id: str, to_node_id: str) -> bool:
        """Add a dependency between domains"""
        if from_node_id not in self.nodes or to_node_id not in self.nodes:
            return False
        
        if to_node_id not in self.nodes[from_node_id].dependencies:
            self.nodes[from_node_id].dependencies.append(to_node_id)
            print(f"   🔗 Added dependency: {from_node_id} → {to_node_id}")
            return True
        
        return False
    
    def discover_products(self, domain: str = None, 
                         status: str = "active") -> List[DataProduct]:
        """Discover data products in the mesh"""
        products = []
        
        for node_id, node in self.nodes.items():
            if domain and node.name != domain:
                continue
            
            for product in node.data_products.values():
                if product.status == status:
                    products.append(product)
        
        print(f"   🔍 Discovered {len(products)} data products")
        return products
    
    def get_domain_lineage(self, node_id: str) -> Dict[str, Any]:
        """Get data lineage for a domain"""
        if node_id not in self.nodes:
            return {}
        
        node = self.nodes[node_id]
        products = list(node.data_products.keys())
        dependencies = node.dependencies
        
        return {
            'domain': node.name,
            'products': products,
            'dependencies': dependencies,
            'dependents': [n.node_id for n in self.nodes.values() 
                          if node_id in n.dependencies]
        }
    
    def apply_governance_policy(self, policy_id: str, 
                               policy: Dict[str, Any]) -> bool:
        """Apply a governance policy"""
        self.governance_policies[policy_id] = policy
        print(f"   📋 Governance policy applied: {policy_id}")
        return True
    
    def get_mesh_stats(self) -> Dict[str, Any]:
        """Get mesh statistics"""
        total_products = sum(len(n.data_products) for n in self.nodes.values())
        active_products = sum(1 for n in self.nodes.values() 
                            for p in n.data_products.values() 
                            if p.status == "active")
        
        return {
            'name': self.name,
            'domains': len(self.nodes),
            'data_products': total_products,
            'active_products': active_products,
            'queries': len(self.query_log),
            'avg_quality': self._calculate_avg_quality()
        }
    
    def _calculate_avg_quality(self) -> float:
        """Calculate average quality across products"""
        all_metrics = []
        for node in self.nodes.values():
            for product in node.data_products.values():
                if product.quality_metrics:
                    all_metrics.append(sum(product.quality_metrics.values()) / len(product.quality_metrics))
        
        if all_metrics:
            return sum(all_metrics) / len(all_metrics)
        return 0.0

def demo_data_mesh():
    """Demonstrate Data Mesh architecture"""
    print("="*60)
    print("DATA MESH ARCHITECTURE DEMONSTRATION")
    print("="*60)
    
    # Create data mesh
    mesh = DataMesh("Enterprise Data Mesh")
    
    # Register domains
    print("\n🌐 Registering domains...")
    mesh.register_domain(
        node_id="sales_domain",
        name="Sales",
        description="Sales and revenue domain",
        owner="sales-team@company.com"
    )
    
    mesh.register_domain(
        node_id="marketing_domain",
        name="Marketing",
        description="Marketing and campaign domain",
        owner="marketing-team@company.com"
    )
    
    mesh.register_domain(
        node_id="product_domain",
        name="Product",
        description="Product and engineering domain",
        owner="engineering-team@company.com"
    )
    
    # Create and publish data products
    print("\n📤 Publishing data products...")
    
    # Sales products
    sales_product = DataProduct(
        product_id="sales_customers",
        name="Customer Data Product",
        description="Master customer data including demographics and preferences",
        domain="Sales",
        owner_team="sales-team@company.com",
        version=1,
        schema={"customer_id": "string", "name": "string", "segment": "string"},
        quality_metrics={"completeness": 0.95, "accuracy": 0.98, "timeliness": 0.90},
        published_at=time.time(),
        updated_at=time.time(),
        status="active"
    )
    mesh.publish_data_product("sales_domain", sales_product)
    
    sales_orders = DataProduct(
        product_id="sales_orders",
        name="Order Data Product",
        description="Historical order data",
        domain="Sales",
        owner_team="sales-team@company.com",
        version=2,
        schema={"order_id": "string", "customer_id": "string", "amount": "float"},
        quality_metrics={"completeness": 0.99, "accuracy": 0.99, "timeliness": 0.95},
        published_at=time.time(),
        updated_at=time.time(),
        status="active"
    )
    mesh.publish_data_product("sales_domain", sales_orders)
    
    # Marketing products
    marketing_product = DataProduct(
        product_id="marketing_campaigns",
        name="Campaign Data Product",
        description="Marketing campaign performance data",
        domain="Marketing",
        owner_team="marketing-team@company.com",
        version=1,
        schema={"campaign_id": "string", "name": "string", "impressions": "int"},
        quality_metrics={"completeness": 0.92, "accuracy": 0.95, "timeliness": 0.88},
        published_at=time.time(),
        updated_at=time.time(),
        status="active"
    )
    mesh.publish_data_product("marketing_domain", marketing_product)
    
    # Product domain products
    product_metrics = DataProduct(
        product_id="product_metrics",
        name="Product Performance",
        description="Product usage and performance metrics",
        domain="Product",
        owner_team="engineering-team@company.com",
        version=1,
        schema={"product_id": "string", "name": "string", "users": "int", "performance": "float"},
        quality_metrics={"completeness": 0.97, "accuracy": 0.99, "timeliness": 0.92},
        published_at=time.time(),
        updated_at=time.time(),
        status="active"
    )
    mesh.publish_data_product("product_domain", product_metrics)
    
    # Add dependencies
    print("\n🔗 Adding dependencies...")
    mesh.add_dependency("marketing_domain", "sales_domain")  # Marketing uses Sales data
    mesh.add_dependency("product_domain", "sales_domain")    # Product uses Sales data
    
    # Discover products
    print("\n🔍 Discovering data products...")
    products = mesh.discover_products()
    for product in products:
        print(f"   • {product.name} (Domain: {product.domain})")
    
    print("\n   Products in Sales domain:")
    sales_products = mesh.discover_products(domain="Sales")
    for product in sales_products:
        print(f"   • {product.name} - Quality: {product.quality_metrics['completeness']:.0%}")
    
    # Query data products
    print("\n📊 Querying data products...")
    data = mesh.query_data_product("sales_customers")
    if data:
        print(f"   Retrieved: {data['name']}")
        print(f"   Quality: {data['quality_metrics']}")
    
    # Get lineage
    print("\n📋 Domain lineage:")
    lineage = mesh.get_domain_lineage("marketing_domain")
    print(f"   Marketing Domain:")
    print(f"   Products: {lineage['products']}")
    print(f"   Dependencies: {lineage['dependencies']}")
    
    # Apply governance
    print("\n📋 Applying governance policies...")
    mesh.apply_governance_policy(
        policy_id="data_quality_001",
        policy={
            "name": "Data Quality Policy",
            "requirements": {
                "completeness": 0.90,
                "accuracy": 0.95,
                "timeliness": 0.85
            },
            "actions": {
                "violation": "alert_owner"
            }
        }
    )
    
    # Mesh statistics
    stats = mesh.get_mesh_stats()
    print(f"\n📊 Mesh Statistics:")
    print(f"   Name: {stats['name']}")
    print(f"   Domains: {stats['domains']}")
    print(f"   Data Products: {stats['data_products']}")
    print(f"   Active Products: {stats['active_products']}")
    print(f"   Queries: {stats['queries']}")
    print(f"   Average Quality: {stats['avg_quality']:.1%}")

def main():
    """Run data mesh demonstration"""
    demo_data_mesh()
    
    print("\n" + "="*60)
    print("✅ DATA MESH DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 11.3 Event-Driven Integration

### The Concept

Event-driven integration connects systems through events. Think of it like a notification system - when something happens (an event), interested parties are notified and can react.

### The Implementation

**File: `part-11-data-hubs/event_driven_integration.py`**
```python
#!/usr/bin/env python3
"""
Event-Driven Integration Implementation
"""

import time
import json
import threading
import queue
import uuid
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass
from enum import Enum
from datetime import datetime

class EventType(Enum):
    """Types of events"""
    DATA_CHANGE = "data_change"
    SYSTEM_ALERT = "system_alert"
    USER_ACTION = "user_action"
    BUSINESS_EVENT = "business_event"
    INTEGRATION = "integration"

class EventSeverity(Enum):
    """Event severity levels"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"

@dataclass
class Event:
    """An event in the system"""
    event_id: str
    event_type: EventType
    source: str
    timestamp: float
    data: Dict[str, Any]
    severity: EventSeverity
    version: int = 1
    correlation_id: Optional[str] = None

class EventBroker:
    """
    Event broker for publish-subscribe messaging
    """
    
    def __init__(self, name: str):
        self.name = name
        self.subscribers: Dict[EventType, List[Callable]] = {}
        self.event_log: List[Event] = []
        self.event_queue = queue.Queue()
        self.is_running = True
        self.processor_thread = threading.Thread(target=self._process_events)
        self.processor_thread.daemon = True
        self.processor_thread.start()
        
        print(f"📡 Event Broker initialized: {name}")
    
    def publish(self, event: Event):
        """Publish an event to the broker"""
        self.event_queue.put(event)
        self.event_log.append(event)
        
        print(f"   📢 Published: {event.event_type.value} from {event.source}")
    
    def subscribe(self, event_type: EventType, handler: Callable):
        """Subscribe to events of a specific type"""
        if event_type not in self.subscribers:
            self.subscribers[event_type] = []
        self.subscribers[event_type].append(handler)
        
        print(f"   📋 Subscribed: {event_type.value} handler added")
    
    def _process_events(self):
        """Process events asynchronously"""
        while self.is_running:
            try:
                event = self.event_queue.get(timeout=0.1)
                self._deliver_event(event)
            except queue.Empty:
                continue
            except Exception as e:
                print(f"   ⚠️ Event processing error: {e}")
    
    def _deliver_event(self, event: Event):
        """Deliver event to subscribers"""
        if event.event_type in self.subscribers:
            for handler in self.subscribers[event.event_type]:
                try:
                    handler(event)
                except Exception as e:
                    print(f"   ⚠️ Handler error: {e}")
    
    def get_event_log(self, limit: int = 100) -> List[Event]:
        """Get recent events from the log"""
        return self.event_log[-limit:]
    
    def get_stats(self) -> Dict[str, Any]:
        """Get broker statistics"""
        return {
            'name': self.name,
            'total_events': len(self.event_log),
            'subscriber_count': sum(len(h) for h in self.subscribers.values()),
            'queue_size': self.event_queue.qsize()
        }

class EventConsumer:
    """
    Event consumer that processes events
    """
    
    def __init__(self, name: str):
        self.name = name
        self.processed_events: List[Event] = []
        self.last_event: Optional[Event] = None
    
    def process_data_change(self, event: Event):
        """Process a data change event"""
        self.processed_events.append(event)
        self.last_event = event
        
        data = event.data
        operation = data.get('operation', 'unknown')
        entity = data.get('entity', 'unknown')
        
        print(f"      🔄 {self.name} processed data change: {operation} on {entity}")
        
        # Simulate processing
        if operation == 'insert':
            print(f"         New data: {data.get('new_data', {})}")
        elif operation == 'update':
            print(f"         Updated from: {data.get('old_data', {})}")
            print(f"         Updated to: {data.get('new_data', {})}")
        elif operation == 'delete':
            print(f"         Deleted: {data.get('old_data', {})}")
    
    def process_business_event(self, event: Event):
        """Process a business event"""
        self.processed_events.append(event)
        self.last_event = event
        
        data = event.data
        event_name = data.get('event_name', 'unknown')
        
        print(f"      📊 {self.name} processed business event: {event_name}")
        
        if event_name == 'order_completed':
            order_id = data.get('order_id')
            total = data.get('total', 0)
            print(f"         Order {order_id} completed: ${total}")
        
        elif event_name == 'customer_signup':
            customer_id = data.get('customer_id')
            print(f"         New customer: {customer_id}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get consumer statistics"""
        return {
            'name': self.name,
            'events_processed': len(self.processed_events),
            'last_event': self.last_event.event_type.value if self.last_event else None
        }

def demo_event_driven_integration():
    """Demonstrate event-driven integration"""
    print("="*60)
    print("EVENT-DRIVEN INTEGRATION DEMONSTRATION")
    print("="*60)
    
    # Create broker
    broker = EventBroker("Enterprise Event Broker")
    
    # Create consumers
    data_consumer = EventConsumer("Data Sync Service")
    business_consumer = EventConsumer("Business Intelligence")
    alert_consumer = EventConsumer("Alert Service")
    
    # Subscribe consumers to events
    print("\n📋 Setting up subscriptions...")
    broker.subscribe(EventType.DATA_CHANGE, data_consumer.process_data_change)
    broker.subscribe(EventType.BUSINESS_EVENT, business_consumer.process_business_event)
    broker.subscribe(EventType.BUSINESS_EVENT, alert_consumer.process_business_event)
    
    # Generate events
    print("\n📢 Publishing events...")
    
    # Data change events
    events = [
        Event(
            event_id=str(uuid.uuid4()),
            event_type=EventType.DATA_CHANGE,
            source="order_system",
            timestamp=time.time(),
            data={
                'operation': 'insert',
                'entity': 'order',
                'new_data': {'order_id': 'ORD-001', 'customer': 'Alice', 'total': 150.00}
            },
            severity=EventSeverity.INFO
        ),
        Event(
            event_id=str(uuid.uuid4()),
            event_type=EventType.DATA_CHANGE,
            source="customer_system",
            timestamp=time.time(),
            data={
                'operation': 'update',
                'entity': 'customer',
                'old_data': {'customer_id': 'CUST-001', 'email': 'alice@old.com'},
                'new_data': {'customer_id': 'CUST-001', 'email': 'alice@new.com'}
            },
            severity=EventSeverity.INFO
        ),
        Event(
            event_id=str(uuid.uuid4()),
            event_type=EventType.DATA_CHANGE,
            source="inventory_system",
            timestamp=time.time(),
            data={
                'operation': 'update',
                'entity': 'product',
                'old_data': {'product_id': 'PROD-001', 'stock': 10},
                'new_data': {'product_id': 'PROD-001', 'stock': 5}
            },
            severity=EventSeverity.WARNING
        )
    ]
    
    for event in events:
        broker.publish(event)
        time.sleep(0.1)  # Allow processing
    
    # Business events
    business_events = [
        Event(
            event_id=str(uuid.uuid4()),
            event_type=EventType.BUSINESS_EVENT,
            source="order_system",
            timestamp=time.time(),
            data={
                'event_name': 'order_completed',
                'order_id': 'ORD-001',
                'total': 150.00,
                'items': ['Laptop']
            },
            severity=EventSeverity.INFO
        ),
        Event(
            event_id=str(uuid.uuid4()),
            event_type=EventType.BUSINESS_EVENT,
            source="signup_system",
            timestamp=time.time(),
            data={
                'event_name': 'customer_signup',
                'customer_id': 'CUST-002',
                'name': 'Bob',
                'plan': 'premium'
            },
            severity=EventSeverity.INFO
        ),
        Event(
            event_id=str(uuid.uuid4()),
            event_type=EventType.BUSINESS_EVENT,
            source="payment_system",
            timestamp=time.time(),
            data={
                'event_name': 'payment_failed',
                'order_id': 'ORD-002',
                'reason': 'insufficient_funds'
            },
            severity=EventSeverity.ERROR
        )
    ]
    
    for event in business_events:
        broker.publish(event)
        time.sleep(0.1)
    
    # Show consumer stats
    print("\n📊 Consumer Statistics:")
    for consumer in [data_consumer, business_consumer, alert_consumer]:
        stats = consumer.get_stats()
        print(f"   {stats['name']}:")
        print(f"      Events processed: {stats['events_processed']}")
        print(f"      Last event: {stats['last_event']}")
    
    # Show broker stats
    stats = broker.get_stats()
    print(f"\n📊 Broker Statistics:")
    print(f"   Name: {stats['name']}")
    print(f"   Total events: {stats['total_events']}")
    print(f"   Subscribers: {stats['subscriber_count']}")
    print(f"   Queue size: {stats['queue_size']}")
    
    # Show event log
    print("\n📋 Recent events:")
    for event in broker.get_event_log(limit=5):
        print(f"   • {event.event_type.value} from {event.source} at "
              f"{datetime.fromtimestamp(event.timestamp).strftime('%H:%M:%S')}")
    
    print("\n🎯 Event-Driven Integration Benefits:")
    print("   • Loose coupling between systems")
    print("   • Real-time reactivity")
    print("   • Scalable event processing")
    print("   • Multiple subscribers")
    print("   • Audit trail of events")
    
    # Clean up
    broker.is_running = False
    if broker.processor_thread:
        broker.processor_thread.join(timeout=1)

def main():
    """Run event-driven integration demonstration"""
    demo_event_driven_integration()
    
    print("\n" + "="*60)
    print("✅ EVENT-DRIVEN INTEGRATION DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-11-data-hubs

# Run the enterprise hub demonstration
python enterprise_hub.py

# Run the data mesh demonstration
python data_mesh.py

# Run the event-driven integration demonstration
python event_driven_integration.py

# Expected output:
# ============================================================
# ENTERPRISE DATA HUB DEMONSTRATION
# ============================================================
# 
# 🏛️ Enterprise Data Hub initialized: Global Data Hub
# 
# 📋 Registering domains...
#    🌐 Domain registered: Sales
#    🌐 Domain registered: Marketing
#    🌐 Domain registered: Engineering
# 
# 📤 Publishing assets...
#    📤 Published asset: Customer Master
#    📤 Published asset: Order History
#    📤 Published asset: Campaign Performance
#    📤 Published asset: Microservice Health
# 
# 🔍 Discovering assets...
#    All assets:
#    • Customer Master (Sales) - dataset
#    • Order History (Sales) - dataset
#    • Campaign Performance (Marketing) - report
#    • Microservice Health (Engineering) - api
# 
# 📋 Creating data contracts...
#    📋 Contract created: contract_1234... for Analytics Team
#    📋 Contract created: contract_5678... for Finance Team
# 
# 📖 Accessing assets through contracts...
#    📖 Asset accessed: Customer Master by Analytics Team
#    Accessed: Customer Master
#    Format: json
# 
# 📊 Hub Statistics:
#    Name: Global Data Hub
#    Total Assets: 4
#    Active Assets: 4
#    Domains: 3
#    Total Contracts: 2
#    Total Accesses: 2
#    Average Quality: 96.0%
# 
# ============================================================
# ✅ ENTERPRISE DATA HUB DEMONSTRATION COMPLETE
# ============================================================
```

---

## Part 11 Recap

You have successfully:

✅ Implemented an Enterprise Data Hub with asset management  
✅ Built data contracts between producers and consumers  
✅ Implemented Data Mesh architecture with domain ownership  
✅ Created data products with quality metrics  
✅ Implemented event-driven integration patterns  
✅ Built event brokers with publish-subscribe  
✅ Created consumers for different event types  
✅ Implemented governance policies  

### Key Takeaways

1. **Enterprise Data Hubs** provide centralized asset discovery and governance
2. **Data Contracts** formalize agreements between producers and consumers
3. **Data Mesh** enables decentralized domain ownership
4. **Data Products** are the unit of sharing in Data Mesh
5. **Domain Ownership** ensures quality and accountability
6. **Event-Driven Integration** enables loose coupling and real-time reactivity
7. **Publish-Subscribe** patterns enable multiple consumers
8. **Governance** ensures compliance and quality across the mesh
