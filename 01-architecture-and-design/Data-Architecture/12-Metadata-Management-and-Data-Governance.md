# Part 12: Metadata Management and Data Governance

Welcome to Part 12, where we explore how organizations build trusted, discoverable, and compliant data ecosystems. Think of metadata management as the library catalog system for your data - it tells you what data exists, where it came from, what it means, and who can use it. Data governance ensures everyone follows the rules, like a city's zoning and building codes.

## Learning Objectives

By the end of this part, you will be able to:

- Implement technical, business, and operational metadata
- Build data lineage and impact analysis
- Create data catalogs for discovery
- Implement data quality frameworks
- Design data classification and privacy controls
- Build data observability systems

---

## 12.1 Metadata Architecture

### The Concept

Metadata is "data about data." Think of it like the information on a book's cover and copyright page - it tells you the title, author, publication date, and where to find it.

### The Implementation

**File: `part-12-metadata-governance/metadata_architecture.py`**
```python
#!/usr/bin/env python3
"""
Metadata Architecture Implementation
Technical, Business, and Operational Metadata
"""

import time
import json
import hashlib
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime
from enum import Enum

class MetadataType(Enum):
    """Types of metadata"""
    TECHNICAL = "technical"
    BUSINESS = "business"
    OPERATIONAL = "operational"

@dataclass
class TechnicalMetadata:
    """Technical metadata about data assets"""
    asset_id: str
    name: str
    location: str
    format: str
    schema: Dict[str, str]
    size_bytes: int
    created_at: float
    updated_at: float
    version: int
    data_type: str
    encoding: str
    partitioning: List[str]

@dataclass
class BusinessMetadata:
    """Business metadata describing meaning and usage"""
    asset_id: str
    name: str
    description: str
    business_owner: str
    data_steward: str
    glossary_terms: List[str]
    tags: List[str]
    sensitivity: str  # public, internal, confidential, restricted
    retention_policy: str
    compliance_classification: str

@dataclass
class OperationalMetadata:
    """Operational metadata about data lifecycle"""
    asset_id: str
    last_accessed: float
    access_count: int
    freshness_score: float
    quality_score: float
    run_frequency: str
    last_updated: float
    processing_time_ms: float
    error_count: int
    status: str  # active, stale, deprecated

class MetadataRepository:
    """
    Repository for storing and managing metadata
    """
    
    def __init__(self):
        self.technical_metadata: Dict[str, TechnicalMetadata] = {}
        self.business_metadata: Dict[str, BusinessMetadata] = {}
        self.operational_metadata: Dict[str, OperationalMetadata] = {}
        self.lineage: Dict[str, Dict[str, List[str]]] = {}
        self.change_log: List[Dict[str, Any]] = []
    
    def register_asset(self, asset_id: str, technical: TechnicalMetadata,
                       business: BusinessMetadata = None) -> bool:
        """Register a data asset with metadata"""
        self.technical_metadata[asset_id] = technical
        
        if business:
            self.business_metadata[asset_id] = business
        
        self.operational_metadata[asset_id] = OperationalMetadata(
            asset_id=asset_id,
            last_accessed=0,
            access_count=0,
            freshness_score=1.0,
            quality_score=1.0,
            run_frequency="unknown",
            last_updated=time.time(),
            processing_time_ms=0,
            error_count=0,
            status="active"
        )
        
        self._log_change(asset_id, "register", "Asset registered")
        print(f"   📋 Asset registered: {asset_id}")
        return True
    
    def get_asset_metadata(self, asset_id: str) -> Dict[str, Any]:
        """Get all metadata for an asset"""
        result = {}
        
        if asset_id in self.technical_metadata:
            result['technical'] = self.technical_metadata[asset_id].__dict__
        
        if asset_id in self.business_metadata:
            result['business'] = self.business_metadata[asset_id].__dict__
        
        if asset_id in self.operational_metadata:
            result['operational'] = self.operational_metadata[asset_id].__dict__
        
        return result
    
    def update_operational_metadata(self, asset_id: str,
                                    updates: Dict[str, Any]) -> bool:
        """Update operational metadata"""
        if asset_id not in self.operational_metadata:
            return False
        
        meta = self.operational_metadata[asset_id]
        for key, value in updates.items():
            if hasattr(meta, key):
                setattr(meta, key, value)
        
        self._log_change(asset_id, "update_operational", "Updated operational metadata")
        return True
    
    def add_lineage(self, asset_id: str, upstream: List[str],
                   downstream: List[str]) -> bool:
        """Add data lineage information"""
        if asset_id not in self.lineage:
            self.lineage[asset_id] = {
                'upstream': [],
                'downstream': []
            }
        
        self.lineage[asset_id]['upstream'].extend(upstream)
        self.lineage[asset_id]['downstream'].extend(downstream)
        
        self._log_change(asset_id, "add_lineage", "Added lineage information")
        return True
    
    def search_by_term(self, term: str) -> List[str]:
        """Search for assets by metadata term"""
        results = []
        term_lower = term.lower()
        
        for asset_id, tech in self.technical_metadata.items():
            if term_lower in tech.name.lower():
                results.append(asset_id)
                continue
            
            if asset_id in self.business_metadata:
                business = self.business_metadata[asset_id]
                if term_lower in business.description.lower():
                    results.append(asset_id)
                    continue
                
                if any(term_lower in gloss.lower() for gloss in business.glossary_terms):
                    results.append(asset_id)
                    continue
                
                if any(term_lower in tag.lower() for tag in business.tags):
                    results.append(asset_id)
                    continue
        
        print(f"   🔍 Found {len(results)} assets matching '{term}'")
        return results
    
    def _log_change(self, asset_id: str, operation: str, description: str):
        """Log a metadata change"""
        self.change_log.append({
            'asset_id': asset_id,
            'operation': operation,
            'description': description,
            'timestamp': time.time()
        })
    
    def get_change_log(self, asset_id: str = None, limit: int = 100) -> List[Dict[str, Any]]:
        """Get change log entries"""
        if asset_id:
            return [c for c in self.change_log[-limit:] if c['asset_id'] == asset_id]
        return self.change_log[-limit:]
    
    def get_stats(self) -> Dict[str, Any]:
        """Get metadata repository statistics"""
        return {
            'total_assets': len(self.technical_metadata),
            'assets_with_business_metadata': len(self.business_metadata),
            'assets_with_lineage': len(self.lineage),
            'total_changes': len(self.change_log),
            'metadata_types': {
                'technical': len(self.technical_metadata),
                'business': len(self.business_metadata),
                'operational': len(self.operational_metadata)
            }
        }

def demo_metadata():
    """Demonstrate metadata management"""
    print("="*60)
    print("METADATA ARCHITECTURE DEMONSTRATION")
    print("="*60)
    
    # Create metadata repository
    repo = MetadataRepository()
    
    print("\n📋 Registering assets with metadata...")
    
    # Register customer asset
    tech_customer = TechnicalMetadata(
        asset_id="customer_master",
        name="Customer Master",
        location="s3://data-lake/customers/",
        format="Parquet",
        schema={"customer_id": "string", "name": "string", "email": "string", "segment": "string"},
        size_bytes=1024 * 1024 * 500,
        created_at=time.time() - 86400 * 30,
        updated_at=time.time() - 3600,
        version=3,
        data_type="structured",
        encoding="UTF-8",
        partitioning=["year", "month", "day"]
    )
    
    business_customer = BusinessMetadata(
        asset_id="customer_master",
        name="Customer Master",
        description="Master customer data containing all customer information",
        business_owner="Sales Team",
        data_steward="Data Governance",
        glossary_terms=["Customer", "Master Data", "PII"],
        tags=["customer", "master", "pii", "sales"],
        sensitivity="confidential",
        retention_policy="10 years",
        compliance_classification="GDPR"
    )
    
    repo.register_asset("customer_master", tech_customer, business_customer)
    
    # Register order asset
    tech_orders = TechnicalMetadata(
        asset_id="orders",
        name="Order History",
        location="s3://data-lake/orders/",
        format="Delta Lake",
        schema={"order_id": "string", "customer_id": "string", "amount": "float", "status": "string"},
        size_bytes=1024 * 1024 * 200,
        created_at=time.time() - 86400 * 60,
        updated_at=time.time() - 7200,
        version=5,
        data_type="structured",
        encoding="UTF-8",
        partitioning=["year", "month"]
    )
    
    business_orders = BusinessMetadata(
        asset_id="orders",
        name="Order History",
        description="Historical order transactions",
        business_owner="Finance Team",
        data_steward="Data Engineering",
        glossary_terms=["Order", "Transaction", "Revenue"],
        tags=["orders", "transactions", "finance"],
        sensitivity="internal",
        retention_policy="7 years",
        compliance_classification="SOX"
    )
    
    repo.register_asset("orders", tech_orders, business_orders)
    
    # Add lineage
    print("\n📊 Adding lineage information...")
    repo.add_lineage(
        asset_id="sales_summary",
        upstream=["orders", "customer_master"],
        downstream=["executive_dashboard"]
    )
    
    repo.add_lineage(
        asset_id="executive_dashboard",
        upstream=["sales_summary"],
        downstream=[]
    )
    
    # Search for assets
    print("\n🔍 Searching for assets...")
    
    print("\n   Searching for 'customer':")
    results = repo.search_by_term("customer")
    for asset_id in results:
        print(f"   • {asset_id}")
    
    print("\n   Searching for 'finance':")
    results = repo.search_by_term("finance")
    for asset_id in results:
        print(f"   • {asset_id}")
    
    # Get asset metadata
    print("\n📊 Metadata for 'customer_master':")
    metadata = repo.get_asset_metadata("customer_master")
    
    if 'technical' in metadata:
        tech = metadata['technical']
        print(f"   Technical:")
        print(f"      Location: {tech['location']}")
        print(f"      Format: {tech['format']}")
        print(f"      Schema: {tech['schema']}")
    
    if 'business' in metadata:
        business = metadata['business']
        print(f"   Business:")
        print(f"      Description: {business['description']}")
        print(f"      Owner: {business['business_owner']}")
        print(f"      Sensitivity: {business['sensitivity']}")
    
    # Update operational metadata
    print("\n📝 Updating operational metadata...")
    repo.update_operational_metadata("customer_master", {
        'access_count': 1000,
        'quality_score': 0.95,
        'status': 'active'
    })
    
    # Show stats
    stats = repo.get_stats()
    print(f"\n📊 Metadata Repository Statistics:")
    print(f"   Total Assets: {stats['total_assets']}")
    print(f"   Assets with Business Metadata: {stats['assets_with_business_metadata']}")
    print(f"   Assets with Lineage: {stats['assets_with_lineage']}")
    print(f"   Total Changes: {stats['total_changes']}")

def main():
    """Run metadata demonstration"""
    demo_metadata()
    
    print("\n" + "="*60)
    print("✅ METADATA DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 12.2 Data Quality Framework

### The Concept

Data quality ensures data is fit for its intended use. Think of it like quality control in manufacturing - you inspect products to ensure they meet specifications before they're shipped.

### The Implementation

**File: `part-12-metadata-governance/data_quality.py`**
```python
#!/usr/bin/env python3
"""
Data Quality Framework Implementation
Quality rules, metrics, and monitoring
"""

import time
import json
import random
from typing import Dict, List, Any, Optional, Tuple, Callable
from dataclasses import dataclass
from enum import Enum

class QualityDimension(Enum):
    """Data quality dimensions"""
    COMPLETENESS = "completeness"
    ACCURACY = "accuracy"
    CONSISTENCY = "consistency"
    TIMELINESS = "timeliness"
    UNIQUENESS = "uniqueness"
    VALIDITY = "validity"

@dataclass
class QualityRule:
    """A data quality rule"""
    rule_id: str
    name: str
    dimension: QualityDimension
    description: str
    check_function: Callable[[Dict[str, Any]], bool]
    severity: str  # critical, error, warning, info
    threshold: float = 0.95

@dataclass
class QualityResult:
    """Result of a quality check"""
    rule_id: str
    asset_id: str
    passed: bool
    record_count: int
    failed_count: int
    success_rate: float
    timestamp: float
    details: Dict[str, Any]

class DataQualityFramework:
    """
    Data quality framework with rules and monitoring
    """
    
    def __init__(self):
        self.rules: Dict[str, QualityRule] = {}
        self.results: List[QualityResult] = []
        self.quality_scores: Dict[str, float] = {}
    
    def add_rule(self, rule: QualityRule):
        """Add a quality rule"""
        self.rules[rule.rule_id] = rule
        print(f"   📋 Quality rule added: {rule.name}")
    
    def check_quality(self, asset_id: str, data: List[Dict[str, Any]]) -> List[QualityResult]:
        """Check data quality against all rules"""
        results = []
        
        for rule in self.rules.values():
            result = self._apply_rule(asset_id, rule, data)
            results.append(result)
            
            if result.passed:
                print(f"   ✅ {rule.name}: {result.success_rate:.1%} passed")
            else:
                print(f"   ❌ {rule.name}: {result.success_rate:.1%} failed (threshold: {rule.threshold:.1%})")
        
        self.results.extend(results)
        self._update_quality_score(asset_id)
        
        return results
    
    def _apply_rule(self, asset_id: str, rule: QualityRule,
                    data: List[Dict[str, Any]]) -> QualityResult:
        """Apply a single quality rule"""
        passed = 0
        failed = 0
        
        for record in data:
            if rule.check_function(record):
                passed += 1
            else:
                failed += 1
        
        total = passed + failed
        success_rate = passed / total if total > 0 else 0
        
        return QualityResult(
            rule_id=rule.rule_id,
            asset_id=asset_id,
            passed=success_rate >= rule.threshold,
            record_count=total,
            failed_count=failed,
            success_rate=success_rate,
            timestamp=time.time(),
            details={'total_records': total, 'passed_records': passed, 'failed_records': failed}
        )
    
    def _update_quality_score(self, asset_id: str):
        """Update the overall quality score for an asset"""
        asset_results = [r for r in self.results if r.asset_id == asset_id]
        if not asset_results:
            return
        
        # Calculate weighted average
        total_score = sum(r.success_rate for r in asset_results)
        avg_score = total_score / len(asset_results)
        
        self.quality_scores[asset_id] = avg_score
    
    def get_quality_report(self, asset_id: str) -> Dict[str, Any]:
        """Get a quality report for an asset"""
        asset_results = [r for r in self.results if r.asset_id == asset_id]
        
        if not asset_results:
            return {'error': 'No results found'}
        
        return {
            'asset_id': asset_id,
            'overall_score': self.quality_scores.get(asset_id, 0),
            'check_count': len(asset_results),
            'pass_count': sum(1 for r in asset_results if r.passed),
            'fail_count': sum(1 for r in asset_results if not r.passed),
            'results': [
                {
                    'rule_name': self.rules.get(r.rule_id).name if self.rules.get(r.rule_id) else r.rule_id,
                    'passed': r.passed,
                    'success_rate': r.success_rate,
                    'details': r.details
                }
                for r in asset_results
            ]
        }
    
    def get_rules_by_dimension(self, dimension: QualityDimension) -> List[QualityRule]:
        """Get rules for a specific dimension"""
        return [r for r in self.rules.values() if r.dimension == dimension]

def demo_data_quality():
    """Demonstrate data quality framework"""
    print("="*60)
    print("DATA QUALITY FRAMEWORK DEMONSTRATION")
    print("="*60)
    
    # Create quality framework
    qf = DataQualityFramework()
    
    # Define quality rules
    print("\n📋 Defining quality rules...")
    
    # Completeness rule
    completeness_rule = QualityRule(
        rule_id="comp_001",
        name="Customer Completeness",
        dimension=QualityDimension.COMPLETENESS,
        description="Check that all required fields are present",
        check_function=lambda r: all(k in r for k in ['id', 'name', 'email', 'segment']),
        severity="critical",
        threshold=0.95
    )
    qf.add_rule(completeness_rule)
    
    # Validity rule
    validity_rule = QualityRule(
        rule_id="valid_001",
        name="Email Valid",
        dimension=QualityDimension.VALIDITY,
        description="Check that email addresses are valid",
        check_function=lambda r: '@' in r.get('email', '') and '.' in r.get('email', ''),
        severity="error",
        threshold=0.90
    )
    qf.add_rule(validity_rule)
    
    # Consistency rule
    consistency_rule = QualityRule(
        rule_id="consist_001",
        name="Segment Consistency",
        dimension=QualityDimension.CONSISTENCY,
        description="Check that segment is from allowed list",
        check_function=lambda r: r.get('segment') in ['Enterprise', 'SMB', 'Consumer', 'Trial'],
        severity="warning",
        threshold=0.85
    )
    qf.add_rule(consistency_rule)
    
    # Uniqueness rule
    uniqueness_rule = QualityRule(
        rule_id="unique_001",
        name="Unique IDs",
        dimension=QualityDimension.UNIQUENESS,
        description="Check that IDs are unique",
        check_function=lambda r: True,  # Will be checked differently
        severity="error",
        threshold=1.0
    )
    qf.add_rule(uniqueness_rule)
    
    # Generate sample data
    print("\n📝 Generating sample data...")
    sample_data = []
    
    customers = [
        {'id': 1, 'name': 'Alice', 'email': 'alice@ex.com', 'segment': 'Enterprise'},
        {'id': 2, 'name': 'Bob', 'email': 'bob@ex.com', 'segment': 'SMB'},
        {'id': 3, 'name': 'Charlie', 'email': 'charlie@ex', 'segment': 'Consumer'},  # Invalid email
        {'id': 4, 'name': 'David', 'segment': 'Enterprise'},  # Missing fields
        {'id': 5, 'name': 'Eve', 'email': 'eve@ex.com', 'segment': 'SMB'},
        {'id': 6, 'name': 'Frank', 'email': 'frank@ex.com', 'segment': 'Premium'},  # Invalid segment
        {'id': 7, 'name': 'Grace', 'email': 'grace@ex.com', 'segment': 'Consumer'},
        {'id': 8, 'name': 'Henry', 'email': 'henry@ex.com', 'segment': 'Enterprise'},
        {'id': 9, 'name': 'Ivy', 'email': 'ivy@ex.com', 'segment': 'SMB'},
        {'id': 10, 'name': 'Jack', 'email': 'jack@ex.com', 'segment': 'Consumer'}
    ]
    
    sample_data.extend(customers)
    print(f"   Generated {len(sample_data)} customer records")
    
    # Check quality
    print("\n🔍 Running quality checks...")
    results = qf.check_quality("customer_master", sample_data)
    
    # Get quality report
    print("\n📊 Quality Report:")
    report = qf.get_quality_report("customer_master")
    
    print(f"   Asset: {report['asset_id']}")
    print(f"   Overall Score: {report['overall_score']:.1%}")
    print(f"   Checks: {report['check_count']}")
    print(f"   Passed: {report['pass_count']}")
    print(f"   Failed: {report['fail_count']}")
    
    print(f"\n   Check Details:")
    for result in report['results']:
        status = "✅" if result['passed'] else "❌"
        print(f"   {status} {result['rule_name']}: {result['success_rate']:.1%}")
    
    # Show rules by dimension
    print(f"\n📋 Rules by Dimension:")
    for dimension in QualityDimension:
        rules = qf.get_rules_by_dimension(dimension)
        if rules:
            print(f"   {dimension.value}: {len(rules)} rules")
            for rule in rules:
                print(f"      - {rule.name} (threshold: {rule.threshold:.1%})")

def main():
    """Run data quality demonstration"""
    demo_data_quality()
    
    print("\n" + "="*60)
    print("✅ DATA QUALITY DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## 12.3 Data Governance and Compliance

### The Concept

Data governance establishes policies and procedures for managing data assets. Think of it like the rulebook for how data can be used, who can access it, and how it must be protected.

### The Implementation

**File: `part-12-metadata-governance/data_governance.py`**
```python
#!/usr/bin/env python3
"""
Data Governance and Compliance Implementation
"""

import time
import json
import hashlib
import random
from typing import Dict, List, Any, Optional, Set
from dataclasses import dataclass
from enum import Enum
from datetime import datetime, timedelta

class DataClassification(Enum):
    """Data classification levels"""
    PUBLIC = "public"
    INTERNAL = "internal"
    CONFIDENTIAL = "confidential"
    RESTRICTED = "restricted"

class PrivacyRegulation(Enum):
    """Privacy regulations"""
    GDPR = "gdpr"
    CCPA = "ccpa"
    HIPAA = "hipaa"
    SOX = "sox"

class AccessLevel(Enum):
    """Access levels"""
    READ = "read"
    WRITE = "write"
    ADMIN = "admin"
    NONE = "none"

@dataclass
class DataPolicy:
    """A data governance policy"""
    policy_id: str
    name: str
    description: str
    classification: DataClassification
    allowed_access: AccessLevel
    retention_days: int
    encryption_required: bool
    audit_required: bool
    regulations: List[PrivacyRegulation]
    
@dataclass
class DataSubjectRequest:
    """A data subject access request (DSAR)"""
    request_id: str
    subject_id: str
    request_type: str  # access, delete, correct
    status: str  # pending, processing, completed, rejected
    submitted_at: float
    completed_at: float = 0
    details: Dict[str, Any] = None

class DataGovernanceSystem:
    """
    Data governance system implementation
    """
    
    def __init__(self):
        self.policies: Dict[str, DataPolicy] = {}
        self.subject_requests: Dict[str, DataSubjectRequest] = {}
        self.access_logs: List[Dict[str, Any]] = []
        self.data_catalog: Dict[str, Dict[str, Any]] = {}
        self.regulations = {
            'gdpr': {
                'right_to_access': True,
                'right_to_delete': True,
                'right_to_correct': True,
                'processing_time_days': 30
            },
            'ccpa': {
                'right_to_access': True,
                'right_to_delete': True,
                'right_to_opt_out': True,
                'processing_time_days': 45
            }
        }
    
    def create_policy(self, policy: DataPolicy) -> str:
        """Create a data governance policy"""
        self.policies[policy.policy_id] = policy
        print(f"   📋 Policy created: {policy.name}")
        return policy.policy_id
    
    def classify_data(self, asset_id: str, classification: DataClassification) -> bool:
        """Classify a data asset"""
        if asset_id not in self.data_catalog:
            self.data_catalog[asset_id] = {}
        
        self.data_catalog[asset_id]['classification'] = classification
        self.data_catalog[asset_id]['classified_at'] = time.time()
        
        print(f"   🏷️ Data classified: {asset_id} → {classification.value}")
        return True
    
    def check_access(self, user: str, asset_id: str, 
                    required_level: AccessLevel) -> bool:
        """Check if a user has access to a data asset"""
        # Check classification
        if asset_id not in self.data_catalog:
            print(f"   ⚠️ Asset {asset_id} not found in catalog")
            return False
        
        classification = self.data_catalog[asset_id].get('classification')
        if not classification:
            print(f"   ⚠️ Asset {asset_id} not classified")
            return False
        
        # Check policies
        for policy in self.policies.values():
            if policy.classification == classification:
                # Check if user has required access
                if policy.allowed_access.value >= required_level.value:
                    self._log_access(user, asset_id, required_level, True)
                    return True
        
        self._log_access(user, asset_id, required_level, False)
        print(f"   ❌ Access denied for {user} to {asset_id}")
        return False
    
    def _log_access(self, user: str, asset_id: str, level: AccessLevel, granted: bool):
        """Log an access attempt"""
        self.access_logs.append({
            'user': user,
            'asset_id': asset_id,
            'level': level.value,
            'granted': granted,
            'timestamp': time.time()
        })
    
    def submit_subject_request(self, subject_id: str, request_type: str,
                               details: Dict[str, Any] = None) -> str:
        """Submit a data subject access request"""
        request_id = f"dsr_{int(time.time())}_{hashlib.md5(subject_id.encode()).hexdigest()[:8]}"
        
        request = DataSubjectRequest(
            request_id=request_id,
            subject_id=subject_id,
            request_type=request_type,
            status="pending",
            submitted_at=time.time(),
            details=details
        )
        
        self.subject_requests[request_id] = request
        print(f"   📨 Subject request submitted: {request_id} ({request_type})")
        return request_id
    
    def process_subject_request(self, request_id: str) -> bool:
        """Process a data subject request"""
        if request_id not in self.subject_requests:
            return False
        
        request = self.subject_requests[request_id]
        request.status = "processing"
        
        # Simulate processing
        print(f"   ⏳ Processing request: {request_id}")
        time.sleep(0.1)
        
        if request.request_type == "access":
            # Retrieve data
            data = self._retrieve_subject_data(request.subject_id)
            request.details = data
            print(f"   📤 Prepared access data for {request.subject_id}")
            
        elif request.request_type == "delete":
            # Delete data
            self._delete_subject_data(request.subject_id)
            print(f"   🗑️ Deleted data for {request.subject_id}")
            
        elif request.request_type == "correct":
            # Correct data
            corrections = request.details.get('corrections', {})
            self._correct_subject_data(request.subject_id, corrections)
            print(f"   ✏️ Corrected data for {request.subject_id}")
        
        request.status = "completed"
        request.completed_at = time.time()
        
        print(f"   ✅ Request {request_id} completed")
        return True
    
    def _retrieve_subject_data(self, subject_id: str) -> Dict[str, Any]:
        """Simulate retrieving subject data"""
        return {
            'subject_id': subject_id,
            'name': f"User_{subject_id}",
            'email': f"{subject_id}@example.com",
            'preferences': {'language': 'en', 'timezone': 'UTC'},
            'history': [{'date': '2024-01-01', 'action': 'login'}]
        }
    
    def _delete_subject_data(self, subject_id: str):
        """Simulate deleting subject data"""
        pass
    
    def _correct_subject_data(self, subject_id: str, corrections: Dict[str, Any]):
        """Simulate correcting subject data"""
        pass
    
    def get_compliance_report(self) -> Dict[str, Any]:
        """Get compliance status report"""
        pending_requests = [r for r in self.subject_requests.values() 
                           if r.status == "pending" or r.status == "processing"]
        
        completed_requests = [r for r in self.subject_requests.values() 
                             if r.status == "completed"]
        
        return {
            'total_requests': len(self.subject_requests),
            'pending_requests': len(pending_requests),
            'completed_requests': len(completed_requests),
            'policies_count': len(self.policies),
            'classified_assets': len(self.data_catalog),
            'access_logs': len(self.access_logs),
            'regulations': list(self.regulations.keys())
        }

def demo_data_governance():
    """Demonstrate data governance"""
    print("="*60)
    print("DATA GOVERNANCE DEMONSTRATION")
    print("="*60)
    
    # Create governance system
    gov = DataGovernanceSystem()
    
    # Create policies
    print("\n📋 Creating governance policies...")
    
    policy1 = DataPolicy(
        policy_id="pol_001",
        name="Public Data Policy",
        description="Policy for public data",
        classification=DataClassification.PUBLIC,
        allowed_access=AccessLevel.READ,
        retention_days=365,
        encryption_required=False,
        audit_required=False,
        regulations=[]
    )
    gov.create_policy(policy1)
    
    policy2 = DataPolicy(
        policy_id="pol_002",
        name="Confidential Data Policy",
        description="Policy for confidential data",
        classification=DataClassification.CONFIDENTIAL,
        allowed_access=AccessLevel.READ,
        retention_days=0,  # Indefinite
        encryption_required=True,
        audit_required=True,
        regulations=[PrivacyRegulation.GDPR, PrivacyRegulation.CCPA]
    )
    gov.create_policy(policy2)
    
    policy3 = DataPolicy(
        policy_id="pol_003",
        name="Restricted Data Policy",
        description="Policy for restricted data",
        classification=DataClassification.RESTRICTED,
        allowed_access=AccessLevel.ADMIN,
        retention_days=2555,  # 7 years
        encryption_required=True,
        audit_required=True,
        regulations=[PrivacyRegulation.HIPAA, PrivacyRegulation.GDPR]
    )
    gov.create_policy(policy3)
    
    # Classify data
    print("\n🏷️ Classifying data assets...")
    gov.classify_data("customer_master", DataClassification.CONFIDENTIAL)
    gov.classify_data("orders", DataClassification.INTERNAL)
    gov.classify_data("health_records", DataClassification.RESTRICTED)
    gov.classify_data("public_data", DataClassification.PUBLIC)
    
    # Test access
    print("\n🔍 Testing access controls...")
    
    test_cases = [
        ("alice", "public_data", AccessLevel.READ),
        ("alice", "customer_master", AccessLevel.READ),
        ("bob", "customer_master", AccessLevel.READ),
        ("admin", "health_records", AccessLevel.ADMIN),
        ("admin", "health_records", AccessLevel.READ)
    ]
    
    for user, asset, level in test_cases:
        print(f"\n   User: {user}, Asset: {asset}, Level: {level.value}")
        granted = gov.check_access(user, asset, level)
        print(f"   Access {'✅ GRANTED' if granted else '❌ DENIED'}")
    
    # Submit subject requests
    print("\n📨 Submitting data subject requests...")
    
    request1 = gov.submit_subject_request(
        subject_id="user_001",
        request_type="access",
        details={"format": "json"}
    )
    
    request2 = gov.submit_subject_request(
        subject_id="user_002",
        request_type="delete",
        details={"reason": "account_closed"}
    )
    
    request3 = gov.submit_subject_request(
        subject_id="user_003",
        request_type="correct",
        details={"corrections": {"email": "user003_corrected@example.com"}}
    )
    
    # Process requests
    print("\n⏳ Processing subject requests...")
    gov.process_subject_request(request1)
    gov.process_subject_request(request2)
    gov.process_subject_request(request3)
    
    # Get compliance report
    print("\n📊 Compliance Report:")
    report = gov.get_compliance_report()
    print(f"   Total Requests: {report['total_requests']}")
    print(f"   Completed Requests: {report['completed_requests']}")
    print(f"   Policies: {report['policies_count']}")
    print(f"   Classified Assets: {report['classified_assets']}")
    print(f"   Access Logs: {report['access_logs']}")
    print(f"   Regulations: {', '.join(report['regulations'])}")
    
    print("\n🎯 Data Governance Benefits:")
    print("   • Data classification and protection")
    print("   • Access control and audit")
    print("   • Privacy regulation compliance")
    print("   • Subject rights management")
    print("   • Policy enforcement")

def main():
    """Run data governance demonstration"""
    demo_data_governance()
    
    print("\n" + "="*60)
    print("✅ DATA GOVERNANCE DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

---

## Verification

Let's verify all components are working correctly:

```bash
# Navigate to the part directory
cd part-12-metadata-governance

# Run the metadata architecture demonstration
python metadata_architecture.py

# Run the data quality demonstration
python data_quality.py

# Run the data governance demonstration
python data_governance.py

# Expected output:
# ============================================================
# METADATA ARCHITECTURE DEMONSTRATION
# ============================================================
# 
# 📋 Registering assets with metadata...
#    📋 Asset registered: customer_master
#    📋 Asset registered: orders
# 
# 📊 Adding lineage information...
# 
# 🔍 Searching for assets...
# 
#    Searching for 'customer':
#    🔍 Found 1 assets matching 'customer'
#    • customer_master
# 
# 📊 Metadata for 'customer_master':
#    Technical:
#       Location: s3://data-lake/customers/
#       Format: Parquet
#       Schema: {'customer_id': 'string', 'name': 'string', 'email': 'string', 'segment': 'string'}
#    Business:
#       Description: Master customer data containing all customer information
#       Owner: Sales Team
#       Sensitivity: confidential
# 
# 📊 Metadata Repository Statistics:
#    Total Assets: 2
#    Assets with Business Metadata: 2
#    Assets with Lineage: 1
#    Total Changes: 5
# 
# ============================================================
# ✅ METADATA DEMONSTRATION COMPLETE
# ============================================================
```

---

## Part 12 Recap

You have successfully:

✅ Implemented technical, business, and operational metadata
✅ Built data lineage tracking and impact analysis
✅ Created a data catalog for asset discovery
✅ Implemented a comprehensive data quality framework
✅ Built data governance with policies and compliance
✅ Implemented data classification and access control
✅ Created data subject request handling
✅ Built compliance reporting and auditing

### Key Takeaways

1. **Metadata** is critical for understanding and managing data
2. **Technical Metadata** describes storage, format, and schema
3. **Business Metadata** describes meaning, ownership, and usage
4. **Operational Metadata** tracks freshness, quality, and access
5. **Data Quality** ensures data is fit for its intended use
6. **Governance** establishes policies for data management
7. **Compliance** ensures adherence to regulations (GDPR, CCPA)
8. **Data Lineage** tracks data flow and dependencies
9. **Subject Rights** enable individuals to control their data
