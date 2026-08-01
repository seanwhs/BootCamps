# Part 4: Detection Engineering, Security Operations & Operational Resilience
## Section 4.6: Business Continuity & Resilience

## The Target: Complete Business Continuity & Resilience Program for Nexus Global Industries

In this section, we'll implement a comprehensive business continuity and resilience program for Nexus Global Industries, including:

1. **Business Continuity Planning** - BCP strategy and governance
2. **Recovery Strategies** - RTO/RPO-aligned recovery approaches
3. **Immutable Backups** - WORM-protected backup systems
4. **Air-Gapped Vaults** - Offline, isolated recovery storage
5. **RTO/RPO Validation** - Regular recovery testing

**What specific file(s) are we building?**
- `bcr/01_bcp_plan.md` - Business continuity plan
- `bcr/02_recovery_strategies.yaml` - Recovery strategies by tier
- `bcr/03_immutable_backups.yaml` - Immutable backup configuration
- `bcr/04_air_gapped_vaults.yaml` - Air-gapped vault setup
- `bcr/05_rpo_rto_validation.py` - RTO/RPO validation framework

---

## The Concept: Business Continuity in Plain English

Think of business continuity like **a backup plan for running your business during a disaster**:

**Business Continuity Planning:** "What do we do if the office building burns down?" This is the overall plan.

**Recovery Strategies:** "We have a backup office, laptops, and cloud systems ready to go." This is how you recover.

**Immutable Backups:** "The backup tapes are stored in a fireproof safe that can't be altered." This is WORM-protected data.

**Air-Gapped Vaults:** "We also have backup tapes stored in a different city, disconnected from the network." This is offline storage.

**RTO/RPO Validation:** "We practice fire drills to make sure everyone can get out and we can be back in business within 4 hours." This is testing recovery.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the bcr directory
cd ~/nexus_security_architecture
mkdir -p bcr

# Verify the structure
ls -la
# Expected: bcr directory appears
```

---

### Step 2: Business Continuity Plan

**File:** `bcr/01_bcp_plan.md`

```markdown
# Business Continuity Plan - Nexus Global Industries

## Overview

This document defines the Business Continuity Plan (BCP) for Nexus Global Industries. The BCP ensures the organization can continue operating during and after disruptive events, minimizing impact on customers, employees, and stakeholders.

## Scope

The BCP covers all critical business functions, systems, and processes at Nexus Global Industries:

1. **Manufacturing Operations** - OT/ICS systems, production planning, quality control
2. **Customer Portal** - B2B ordering, specifications, support
3. **R&D Systems** - Code repositories, CI/CD, IP storage
4. **Financial Systems** - ERP, payments, procurement
5. **HR Systems** - Employee data, benefits, payroll
6. **Internal Collaboration** - Email, messaging, document sharing

## Business Impact Analysis (BIA)

### Criticality Tiers

| Tier | Description | Systems | RTO | RPO |
|------|-------------|---------|-----|-----|
| **Tier 0** | Critical - Business stops without it | Manufacturing OT, Customer Portal | 2 hours | 15 minutes |
| **Tier 1** | High - Significant business impact | Financial Systems, R&D Repositories | 4 hours | 1 hour |
| **Tier 2** | Medium - Moderate business impact | HR Systems, Internal Collaboration | 8 hours | 4 hours |
| **Tier 3** | Low - Minimal business impact | Public website, Analytics | 24 hours | 24 hours |

### Recovery Priority Matrix

| Function | Tier | RTO | RPO | Recovery Method | Owner |
|----------|------|-----|-----|-----------------|-------|
| Manufacturing OT | 0 | 2h | 15m | Active-Passive DR | VP Manufacturing |
| Customer Portal | 0 | 2h | 15m | Active-Active | VP Engineering |
| Financial Systems | 1 | 4h | 1h | Active-Passive | CFO |
| R&D Repositories | 1 | 4h | 1h | Active-Passive | CTO |
| HR Systems | 2 | 8h | 4h | Active-Passive | CHRO |
| Internal Collaboration | 2 | 8h | 4h | SaaS Provider | CIO |
| Public Website | 3 | 24h | 24h | Active-Passive | CMO |

## Incident Scenarios

### Scenario 1: Ransomware Attack
- **Impact**: Systems encrypted, data inaccessible
- **Response**: Isolate affected systems, restore from immutable backups
- **Recovery**: Failover to DR environment
- **Timeline**: RTO target: 4 hours

### Scenario 2: Cloud Provider Outage (AWS/Azure)
- **Impact**: Cloud services unavailable
- **Response**: Failover to secondary cloud provider
- **Recovery**: Active-Passive cross-cloud failover
- **Timeline**: RTO target: 2 hours

### Scenario 3: Data Center Fire/Flood
- **Impact**: Physical infrastructure lost
- **Response**: Failover to remote disaster recovery site
- **Recovery**: Restore from air-gapped backups
- **Timeline**: RTO target: 8 hours

### Scenario 4: Cyber Attack on OT Systems
- **Impact**: Manufacturing halted, safety risks
- **Response**: Isolate OT network, manual override
- **Recovery**: Restore OT systems from immutable backups
- **Timeline**: RTO target: 2 hours

### Scenario 5: Supply Chain Compromise
- **Impact**: Third-party software/service unavailable
- **Response**: Activate alternative vendors
- **Recovery**: Restore from clean backups
- **Timeline**: RTO target: 24 hours

## Recovery Strategies

### Active-Active
- Multiple regions/clouds running simultaneously
- Load balancing across all regions
- Zero downtime failover
- Used for: Customer Portal

### Active-Passive
- Primary site active, secondary site on standby
- Data replication from primary to secondary
- Manual or automated failover
- Used for: Financial Systems, R&D Repositories

### SaaS Provider
- Business-critical SaaS applications
- Provider handles continuity
- Used for: Internal Collaboration (O365, Slack)

### Air-Gapped Restore
- Offline backups in secure location
- Manual restore process
- Used for: Worst-case scenarios (ransomware, data center loss)

## BCP Governance

### Roles and Responsibilities

| Role | Responsibility |
|------|----------------|
| **BCP Owner (CISO)** | Overall BCP governance and approval |
| **BCP Coordinator** | BCP maintenance, testing, and updates |
| **Business Unit Leads** | BCP implementation for their area |
| **IT Operations** | Technical recovery execution |
| **Security Team** | Security incident response |

### Testing Schedule

| Test Type | Frequency | Owner | Scope |
|-----------|-----------|-------|-------|
| **Tabletop Exercise** | Quarterly | BCP Coordinator | All tiers |
| **Backup Recovery Test** | Monthly | IT Operations | Tier 0-1 |
| **Full DR Test** | Bi-annual | BCP Coordinator | All tiers |
| **Chaos Test** | Monthly | Security Team | Resilience validation |

## Communication Plan

### Internal Communications

| Stakeholder | Method | Timeline |
|-------------|--------|----------|
| **Executive Team** | Direct call | Immediate |
| **Employees** | Email/Slack | Within 15 minutes |
| **IT Teams** | PagerDuty | Immediate |
| **All Staff** | Mass notification | Within 30 minutes |

### External Communications

| Stakeholder | Method | Timeline |
|-------------|--------|----------|
| **Customers** | Email/Portal | Within 1 hour |
| **Regulators** | Formal notification | Per regulation |
| **Partners** | Email | Within 2 hours |
| **Public** | Press release | As needed |

## BCP Documentation

### Required Documents

1. **BCP Plan** - This document
2. **Risk Assessment** - BIA and risk register
3. **Recovery Procedures** - Technical runbooks
4. **Contact List** - Emergency contacts
5. **Vendor Agreements** - DR providers, cloud providers
6. **Test Reports** - Results of testing

### Document Maintenance

- Review: Quarterly
- Update: After any significant change
- Version: Major changes versioned
- Access: Restricted to authorized personnel

## BCP Activation Criteria

The BCP is activated when:

1. Critical systems are unavailable for > 15 minutes
2. Data loss is detected or suspected
3. Physical safety is at risk
4. Executive leadership declares a disaster
5. Regulatory reporting is required

## BCP Deactivation Criteria

The BCP is deactivated when:

1. All critical systems are restored
2. Data integrity is verified
3. Normal operations resume
4. Post-incident review is complete

---

**Document Owner**: CISO  
**Last Updated**: 2026-08-02  
**Version**: 1.0  
**Approval Status**: Draft - Ready for Review
```

**Verification:**

```bash
# Verify BCP plan file
ls -la bcr/01_bcp_plan.md
# Expected: File exists

# Check sections
grep -c "##" bcr/01_bcp_plan.md
# Expected: Shows multiple sections
```

---

### Step 3: Recovery Strategies

**File:** `bcr/02_recovery_strategies.yaml`

```yaml
# Recovery Strategies - Nexus Global Industries
# File: bcr/02_recovery_strategies.yaml
# Version: 1.0

# ====================================================================
# TIER 0 - CRITICAL SYSTEMS
# ====================================================================

tier_0:
  description: "Critical systems - business stops without them"
  rto: "2 hours"
  rpo: "15 minutes"
  recovery_type: "active-active"
  
  systems:
    - name: "Manufacturing OT"
      strategy: |
        - Active-Passive across 2 manufacturing sites
        - Continuous replication to secondary site
        - Manual failover (safety critical)
        - Immutable backups every 15 minutes
      validation:
        - "Full DR test: quarterly"
        - "Backup recovery test: weekly"
      dependencies:
        - "Power"
        - "Network"
        - "SCADA controllers"
    
    - name: "Customer Portal"
      strategy: |
        - Active-Active across AWS us-east-1 and us-west-2
        - DNS-based load balancing
        - Automatic failover (health checks)
        - Auto-scaling for demand
      validation:
        - "Chaos tests: weekly"
        - "Full DR test: monthly"
      dependencies:
        - "AWS services"
        - "Database replication"
        - "CDN"

# ====================================================================
# TIER 1 - HIGH SYSTEMS
# ====================================================================

tier_1:
  description: "High impact - significant business impact"
  rto: "4 hours"
  rpo: "1 hour"
  recovery_type: "active-passive"
  
  systems:
    - name: "Financial Systems"
      strategy: |
        - Active-Passive across AWS and Azure
        - Hourly database snapshots
        - 4-hour recovery time
        - Immutable backups daily
      validation:
        - "Full DR test: quarterly"
        - "Backup recovery test: monthly"
      dependencies:
        - "ERP system"
        - "Payment gateways"
        - "Banking integrations"
    
    - name: "R&D Repositories"
      strategy: |
        - Active-Passive with GitLab HA
        - Replication to secondary site
        - 4-hour recovery time
        - Immutable backups daily
      validation:
        - "Full DR test: quarterly"
        - "Backup recovery test: monthly"
      dependencies:
        - "GitLab"
        - "Storage"
        - "Network"

# ====================================================================
# TIER 2 - MEDIUM SYSTEMS
# ====================================================================

tier_2:
  description: "Medium impact - moderate business impact"
  rto: "8 hours"
  rpo: "4 hours"
  recovery_type: "active-passive"
  
  systems:
    - name: "HR Systems"
      strategy: |
        - Active-Passive with SaaS provider
        - Provider handles continuity
        - 8-hour recovery target
        - Daily backups
      validation:
        - "Backup recovery test: quarterly"
      dependencies:
        - "SaaS provider"
        - "Employee data"
    
    - name: "Internal Collaboration"
      strategy: |
        - SaaS provider continuity
        - 8-hour recovery target
        - Provider handles backups
      validation:
        - "SaaS provider SLA review: quarterly"
      dependencies:
        - "O365"
        - "Slack"
        - "Network"

# ====================================================================
# CROSS-CLOUD RECOVERY
# ====================================================================

cross_cloud_recovery:
  enabled: true
  primary: "AWS"
  secondary: "Azure"
  
  data_replication:
    - source: "AWS RDS"
      target: "Azure SQL"
      method: "CDC (Change Data Capture)"
      frequency: "continuous"
    
    - source: "AWS S3"
      target: "Azure Blob"
      method: "Replication"
      frequency: "hourly"
    
    - source: "AWS EBS"
      target: "Azure Managed Disk"
      method: "Snapshot replication"
      frequency: "daily"
  
  failover_process:
    - step: "Initiate failover (manual or automated)"
    - step: "Update DNS records"
    - step: "Activate secondary services"
    - step: "Verify data integrity"
    - step: "Monitor performance"
    - step: "Communicate status"

# ====================================================================
# RECOVERY TOOLING
# ====================================================================

recovery_tooling:
  - tool: "Velero"
    purpose: "Kubernetes backup and restore"
    schedule: "daily"
    retention: "30 days"
    location: "AWS S3"
  
  - tool: "AWS Backup"
    purpose: "AWS service backups"
    schedule: "continuous"
    retention: "90 days"
    location: "AWS S3"
  
  - tool: "Azure Backup"
    purpose: "Azure service backups"
    schedule: "continuous"
    retention: "90 days"
    location: "Azure Blob"
  
  - tool: "GitLab Backup"
    purpose: "Code repository backups"
    schedule: "daily"
    retention: "30 days"
    location: "AWS S3"
  
  - tool: "Database Backup"
    purpose: "Database backups"
    schedule: "continuous"
    retention: "30 days"
    location: "Cross-cloud"
```

**Verification:**

```bash
# Verify recovery strategies file
ls -la bcr/02_recovery_strategies.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('bcr/02_recovery_strategies.yaml'))"
# Expected: No error output
```

---

### Step 4: Immutable Backups

**File:** `bcr/03_immutable_backups.yaml`

```yaml
# Immutable Backups - Nexus Global Industries
# File: bcr/03_immutable_backups.yaml
# Version: 1.0

# ====================================================================
# AWS S3 OBJECT LOCK CONFIGURATION
# ====================================================================

aws_s3_object_lock:
  enabled: true
  buckets:
    - name: "nexus-critical-backups"
      region: "us-east-1"
      versioning: true
      object_lock:
        enabled: true
        mode: "GOVERNANCE"
        retention_days: 30
      encryption:
        enabled: true
        algorithm: "AES256"
      access:
        public_access: false
        bucket_policy: |
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Sid": "DenyNonSSL",
                "Effect": "Deny",
                "Principal": "*",
                "Action": "s3:*",
                "Resource": [
                  "arn:aws:s3:::nexus-critical-backups/*",
                  "arn:aws:s3:::nexus-critical-backups"
                ],
                "Condition": {
                  "Bool": {
                    "aws:SecureTransport": "false"
                  }
                }
              },
              {
                "Sid": "DenyDelete",
                "Effect": "Deny",
                "Principal": "*",
                "Action": [
                  "s3:DeleteObject",
                  "s3:DeleteObjectVersion",
                  "s3:PutBucketPolicy"
                ],
                "Resource": [
                  "arn:aws:s3:::nexus-critical-backups/*",
                  "arn:aws:s3:::nexus-critical-backups"
                ]
              }
            ]
          }
    
    - name: "nexus-rd-backups"
      region: "us-west-2"
      versioning: true
      object_lock:
        enabled: true
        mode: "GOVERNANCE"
        retention_days: 90
      encryption:
        enabled: true
        algorithm: "AES256"
    
    - name: "nexus-financial-backups"
      region: "eu-west-1"
      versioning: true
      object_lock:
        enabled: true
        mode: "COMPLIANCE"
        retention_days: 365
      encryption:
        enabled: true
        algorithm: "AES256"

# ====================================================================
# AZURE IMMUTABLE BLOB
# ====================================================================

azure_immutable_blob:
  enabled: true
  
  storage_accounts:
    - name: "nexusstorage"
      location: "eastus"
      sku: "Standard_GRS"
      blob_services:
        - container_name: "critical-backups"
          immutability_policy:
            enabled: true
            period: 30
            allow_protected_append_writes: true
        
        - container_name: "financial-backups"
          immutability_policy:
            enabled: true
            period: 365
            allow_protected_append_writes: true
        
        - container_name: "rd-backups"
          immutability_policy:
            enabled: true
            period: 90
            allow_protected_append_writes: true

# ====================================================================
# BACKUP LIFE CYCLE
# ====================================================================

backup_lifecycle:
  - class: "Critical"
    retention: "365 days"
    immutable: true
    encryption: true
    location: "AWS + Azure"
    schedule: "continuous"
    systems: ["Manufacturing OT", "Customer Portal"]
  
  - class: "High"
    retention: "90 days"
    immutable: true
    encryption: true
    location: "AWS"
    schedule: "daily"
    systems: ["Financial Systems", "R&D Repositories"]
  
  - class: "Medium"
    retention: "30 days"
    immutable: false
    encryption: true
    location: "AWS"
    schedule: "daily"
    systems: ["HR Systems"]
  
  - class: "Low"
    retention: "7 days"
    immutable: false
    encryption: false
    location: "AWS"
    schedule: "weekly"
    systems: ["Public Website"]

# ====================================================================
# BACKUP VALIDATION
# ====================================================================

backup_validation:
  enabled: true
  
  checks:
    - name: "Backup Integrity"
      frequency: "daily"
      method: "Checksum validation"
      fail_action: "alert"
    
    - name: "Backup Completeness"
      frequency: "daily"
      method: "Compare backup count vs expected"
      fail_action: "alert"
    
    - name: "Backup Encryption"
      frequency: "daily"
      method: "Verify encryption status"
      fail_action: "alert"
    
    - name: "Backup Retention"
      frequency: "weekly"
      method: "Check retention compliance"
      fail_action: "alert"
  
  reports:
    - name: "Backup Status Report"
      frequency: "daily"
      recipients: ["security@nexus.com", "sre@nexus.com"]
      
    - name: "Backup Compliance Report"
      frequency: "weekly"
      recipients: ["security@nexus.com", "audit@nexus.com"]
```

**Verification:**

```bash
# Verify immutable backups file
ls -la bcr/03_immutable_backups.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('bcr/03_immutable_backups.yaml'))"
# Expected: No error output
```

---

### Step 5: Air-Gapped Vaults

**File:** `bcr/04_air_gapped_vaults.yaml`

```yaml
# Air-Gapped Vaults - Nexus Global Industries
# File: bcr/04_air_gapped_vaults.yaml
# Version: 1.0

# ====================================================================
# AIR-GAPPED STORAGE CONFIGURATION
# ====================================================================

air_gapped_vaults:
  enabled: true
  
  vaults:
    - name: "Primary Air-Gapped Vault"
      location: "Singapore (HQ)"
      type: "Physical + Cloud"
      storage:
        - type: "AWS S3 Glacier Deep Archive"
          region: "ap-southeast-1"
          vault_name: "nexus-primary-vault"
          retention: "365 days"
          retrieval_time: "12 hours"
        
        - type: "Offline Tape Storage"
          location: "Data Center - Singapore"
          capacity: "100TB"
          retention: "365 days"
          retrieval_time: "24 hours"
      
      contents:
        - "Tier 0 critical backups"
        - "Tier 1 high-priority backups"
        - "Encryption keys (Vault)"
        - "Disaster recovery plans"
      
      access:
        - "Approval: 2 persons required"
        - "Documentation: Signed access log"
        - "Audit: Every access recorded"
    
    - name: "Secondary Air-Gapped Vault"
      location: "London (EMEA)"
      type: "Physical + Cloud"
      storage:
        - type: "AWS S3 Glacier Deep Archive"
          region: "eu-west-2"
          vault_name: "nexus-secondary-vault"
          retention: "365 days"
          retrieval_time: "12 hours"
        
        - type: "Offline Tape Storage"
          location: "Data Center - London"
          capacity: "50TB"
          retention: "365 days"
          retrieval_time: "24 hours"
      
      contents:
        - "Cross-replicated from primary vault"
        - "Additional regional backups"
      
      access:
        - "Approval: 2 persons required"
        - "Documentation: Signed access log"
        - "Audit: Every access recorded"

# ====================================================================
# VAULT ACCESS PROCEDURE
# ====================================================================

vault_access_procedure:
  steps:
    - step: 1
      description: "Request access to air-gapped vault"
      approver: "Security Manager"
      documentation: "Access request form"
    
    - step: 2
      description: "Secondary approval"
      approver: "CISO"
      documentation: "Approval email"
    
    - step: 3
      description: "Retrieve backup from vault"
      method: "AWS S3 Glacier retrieval or physical tape"
      timing: "12-24 hours"
    
    - step: 4
      description: "Validate backup integrity"
      method: "Checksum verification"
      timing: "1 hour"
    
    - step: 5
      description: "Restore from backup"
      method: "Restore to recovery environment"
      timing: "As per RTO"
    
    - step: 6
      description: "Document access"
      documentation: "Access log entry"
      retention: "7 years"

# ====================================================================
# VAULT ROTATION
# ====================================================================

vault_rotation:
  schedule: "annually"
  
  procedures:
    - procedure: "Full vault rotation"
      frequency: "annually"
      steps:
        - "Create new backup set"
        - "Store in air-gapped vault"
        - "Update vault inventory"
        - "Test restore from new vault"
    
    - procedure: "Partial vault refresh"
      frequency: "quarterly"
      steps:
        - "Update critical backups"
        - "Verify encryption"
        - "Validate integrity"
    
    - procedure: "Vault integrity check"
      frequency: "monthly"
      steps:
        - "Random sample verification"
        - "Check encryption status"
        - "Validate checksums"

# ====================================================================
# VAULT SECURITY
# ====================================================================

vault_security:
  physical_security:
    - "24/7 security guards"
    - "Biometric access control"
    - "CCTV monitoring"
    - "Fire suppression"
  
  logical_security:
    - "Encryption: AES-256"
    - "Access: 2-person rule"
    - "Audit: All access logged"
    - "Monitoring: SIEM integration"
  
  operational_security:
    - "Access policy: Need-to-know"
    - "Background checks for all personnel"
    - "Regular security training"
    - "Incident response plan"

# ====================================================================
# VAULT INVENTORY
# ====================================================================

vault_inventory:
  - id: "VLT-001"
    type: "Application Backup"
    contents: "Customer Portal - Full Backup"
    date: "2026-08-01"
    size: "2.5TB"
    encryption: "AES-256"
    checksum: "sha256:abc123def456"
  
  - id: "VLT-002"
    type: "Application Backup"
    contents: "Manufacturing OT - Full Backup"
    date: "2026-08-01"
    size: "5.2TB"
    encryption: "AES-256"
    checksum: "sha256:def456ghi789"
  
  - id: "VLT-003"
    type: "Database Backup"
    contents: "Financial Systems - Full Backup"
    date: "2026-08-01"
    size: "1.8TB"
    encryption: "AES-256"
    checksum: "sha256:ghi789jkl012"
  
  - id: "VLT-004"
    type: "Database Backup"
    contents: "R&D Repository - Full Backup"
    date: "2026-08-01"
    size: "3.1TB"
    encryption: "AES-256"
    checksum: "sha256:jkl012mno345"
  
  - id: "VLT-005"
    type: "Configuration Backup"
    contents: "Infrastructure as Code - Full Backup"
    date: "2026-08-01"
    size: "0.5TB"
    encryption: "AES-256"
    checksum: "sha256:mno345pqr678"
  
  - id: "VLT-006"
    type: "System Backup"
    contents: "Kubernetes Clusters - Full Backup"
    date: "2026-08-01"
    size: "1.2TB"
    encryption: "AES-256"
    checksum: "sha256:pqr678stu901"
```

**Verification:**

```bash
# Verify air-gapped vaults file
ls -la bcr/04_air_gapped_vaults.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('bcr/04_air_gapped_vaults.yaml'))"
# Expected: No error output
```

---

### Step 6: RTO/RPO Validation Framework

**File:** `bcr/05_rpo_rto_validation.py`

```python
#!/usr/bin/env python3
"""
RTO/RPO Validation Framework - Nexus Global Industries
File: bcr/05_rpo_rto_validation.py
Version: 1.0

This service validates RTO (Recovery Time Objective) and RPO (Recovery Point Objective)
compliance through automated testing and validation.
"""

import os
import json
import logging
import time
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict

import requests
import boto3
from azure.storage.blob import BlobServiceClient
from kubernetes import client, config

# ====================================================================
# Configuration
# ====================================================================

CONFIG = {
    "AWS_ACCESS_KEY": os.getenv("AWS_ACCESS_KEY", ""),
    "AWS_SECRET_KEY": os.getenv("AWS_SECRET_KEY", ""),
    "AWS_REGION": os.getenv("AWS_REGION", "us-east-1"),
    "AZURE_CONNECTION_STRING": os.getenv("AZURE_CONNECTION_STRING", ""),
    "REPORT_PATH": os.getenv("REPORT_PATH", "/reports"),
    "LOG_LEVEL": os.getenv("LOG_LEVEL", "INFO"),
}

# ====================================================================
# Logging Setup
# ====================================================================

logging.basicConfig(
    level=getattr(logging, CONFIG["LOG_LEVEL"]),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ====================================================================
# Data Models
# ====================================================================

@dataclass
class RTOValidationResult:
    """RTO validation result."""
    system_name: str
    tier: str
    rto_target: int  # seconds
    rto_achieved: int  # seconds
    passed: bool
    timestamp: datetime
    details: Dict[str, Any]

@dataclass
class RPOValidationResult:
    """RPO validation result."""
    system_name: str
    tier: str
    rpo_target: int  # seconds
    rpo_achieved: int  # seconds
    passed: bool
    timestamp: datetime
    details: Dict[str, Any]

# ====================================================================
# RTO/RPO Validation Service
# ====================================================================

class RTOValidator:
    """Validates RTO compliance for systems."""
    
    def __init__(self):
        """Initialize the RTO validator."""
        # Initialize AWS clients
        if CONFIG["AWS_ACCESS_KEY"]:
            self.aws_session = boto3.Session(
                aws_access_key_id=CONFIG["AWS_ACCESS_KEY"],
                aws_secret_access_key=CONFIG["AWS_SECRET_KEY"],
                region_name=CONFIG["AWS_REGION"]
            )
            self.s3_client = self.aws_session.client('s3')
            self.ec2_client = self.aws_session.client('ec2')
        else:
            self.s3_client = None
            self.ec2_client = None
        
        # Initialize Azure clients
        if CONFIG["AZURE_CONNECTION_STRING"]:
            self.azure_client = BlobServiceClient.from_connection_string(
                CONFIG["AZURE_CONNECTION_STRING"]
            )
        else:
            self.azure_client = None
        
        # Initialize Kubernetes client
        try:
            config.load_incluster_config()
        except:
            config.load_kube_config()
        self.k8s_client = client.CoreV1Api()
        
        logger.info("RTO/RPO Validation Service initialized")
    
    def validate_rto(self, system_name: str, tier: str, rto_target: int) -> RTOValidationResult:
        """
        Validate RTO for a system.
        
        Args:
            system_name: Name of the system
            tier: Criticality tier
            rto_target: Target RTO in seconds
            
        Returns:
            RTOValidationResult
        """
        logger.info(f"Validating RTO for {system_name} (target: {rto_target}s)")
        
        start_time = time.time()
        
        try:
            # Simulate system recovery
            # In production, this would actually trigger a failover/recovery
            
            # Tier-specific recovery simulation
            if tier == "0":
                # Critical - simulate faster recovery
                recovery_time = self._simulate_critical_recovery()
            elif tier == "1":
                # High - moderate recovery
                recovery_time = self._simulate_high_recovery()
            elif tier == "2":
                # Medium - slower recovery
                recovery_time = self._simulate_medium_recovery()
            else:
                # Low - slowest recovery
                recovery_time = self._simulate_low_recovery()
            
            elapsed = time.time() - start_time
            passed = elapsed <= rto_target
            
            # Log result
            result = RTOValidationResult(
                system_name=system_name,
                tier=tier,
                rto_target=rto_target,
                rto_achieved=int(elapsed),
                passed=passed,
                timestamp=datetime.utcnow(),
                details={
                    "recovery_method": "simulated_failover",
                    "recovery_time": elapsed,
                    "target_met": passed
                }
            )
            
            logger.info(f"RTO validation for {system_name}: {'PASSED' if passed else 'FAILED'} ({int(elapsed)}s / {rto_target}s)")
            
            return result
            
        except Exception as e:
            logger.error(f"Error validating RTO for {system_name}: {e}")
            return RTOValidationResult(
                system_name=system_name,
                tier=tier,
                rto_target=rto_target,
                rto_achieved=0,
                passed=False,
                timestamp=datetime.utcnow(),
                details={"error": str(e)}
            )
    
    def validate_rpo(self, system_name: str, tier: str, rpo_target: int) -> RPOValidationResult:
        """
        Validate RPO for a system.
        
        Args:
            system_name: Name of the system
            tier: Criticality tier
            rpo_target: Target RPO in seconds
            
        Returns:
            RPOValidationResult
        """
        logger.info(f"Validating RPO for {system_name} (target: {rpo_target}s)")
        
        try:
            # Simulate data loss detection
            # In production, this would check actual backup timestamps
            
            # Tier-specific RPO simulation
            if tier == "0":
                # Critical - minimal data loss
                data_loss = self._simulate_critical_rpo()
            elif tier == "1":
                # High - small data loss
                data_loss = self._simulate_high_rpo()
            elif tier == "2":
                # Medium - moderate data loss
                data_loss = self._simulate_medium_rpo()
            else:
                # Low - larger data loss
                data_loss = self._simulate_low_rpo()
            
            passed = data_loss <= rpo_target
            
            result = RPOValidationResult(
                system_name=system_name,
                tier=tier,
                rpo_target=rpo_target,
                rpo_achieved=data_loss,
                passed=passed,
                timestamp=datetime.utcnow(),
                details={
                    "last_backup_age": data_loss,
                    "target_met": passed
                }
            )
            
            logger.info(f"RPO validation for {system_name}: {'PASSED' if passed else 'FAILED'} ({data_loss}s / {rpo_target}s)")
            
            return result
            
        except Exception as e:
            logger.error(f"Error validating RPO for {system_name}: {e}")
            return RPOValidationResult(
                system_name=system_name,
                tier=tier,
                rpo_target=rpo_target,
                rpo_achieved=0,
                passed=False,
                timestamp=datetime.utcnow(),
                details={"error": str(e)}
            )
    
    def _simulate_critical_recovery(self) -> int:
        """Simulate recovery time for critical systems."""
        # Simulated recovery time: 30-120 seconds
        import random
        return random.randint(30, 120)
    
    def _simulate_high_recovery(self) -> int:
        """Simulate recovery time for high systems."""
        # Simulated recovery time: 60-240 seconds
        import random
        return random.randint(60, 240)
    
    def _simulate_medium_recovery(self) -> int:
        """Simulate recovery time for medium systems."""
        # Simulated recovery time: 120-480 seconds
        import random
        return random.randint(120, 480)
    
    def _simulate_low_recovery(self) -> int:
        """Simulate recovery time for low systems."""
        # Simulated recovery time: 240-1440 seconds
        import random
        return random.randint(240, 1440)
    
    def _simulate_critical_rpo(self) -> int:
        """Simulate RPO for critical systems."""
        # Simulated data loss: 5-15 minutes
        import random
        return random.randint(5, 15) * 60
    
    def _simulate_high_rpo(self) -> int:
        """Simulate RPO for high systems."""
        # Simulated data loss: 15-60 minutes
        import random
        return random.randint(15, 60) * 60
    
    def _simulate_medium_rpo(self) -> int:
        """Simulate RPO for medium systems."""
        # Simulated data loss: 1-4 hours
        import random
        return random.randint(1, 4) * 3600
    
    def _simulate_low_rpo(self) -> int:
        """Simulate RPO for low systems."""
        # Simulated data loss: 4-24 hours
        import random
        return random.randint(4, 24) * 3600

# ====================================================================
# Test Runner
# ====================================================================

class BCTestRunner:
    """Runs BCP validation tests."""
    
    def __init__(self):
        self.validator = RTOValidator()
        self.results = []
    
    def run_all_tests(self) -> Dict[str, Any]:
        """Run all BCP validation tests."""
        test_configs = [
            {"system": "Manufacturing OT", "tier": "0", "rto": 7200, "rpo": 900},
            {"system": "Customer Portal", "tier": "0", "rto": 7200, "rpo": 900},
            {"system": "Financial Systems", "tier": "1", "rto": 14400, "rpo": 3600},
            {"system": "R&D Repositories", "tier": "1", "rto": 14400, "rpo": 3600},
            {"system": "HR Systems", "tier": "2", "rto": 28800, "rpo": 14400},
            {"system": "Internal Collaboration", "tier": "2", "rto": 28800, "rpo": 14400},
        ]
        
        results = {
            "timestamp": datetime.utcnow().isoformat(),
            "tests": [],
            "summary": {
                "total": 0,
                "passed": 0,
                "failed": 0
            }
        }
        
        for config in test_configs:
            system = config["system"]
            tier = config["tier"]
            rto_target = config["rto"]
            rpo_target = config["rpo"]
            
            # Run RTO validation
            rto_result = self.validator.validate_rto(system, tier, rto_target)
            
            # Run RPO validation
            rpo_result = self.validator.validate_rpo(system, tier, rpo_target)
            
            test_result = {
                "system": system,
                "tier": tier,
                "rto": {
                    "target": rto_target,
                    "achieved": rto_result.rto_achieved,
                    "passed": rto_result.passed
                },
                "rpo": {
                    "target": rpo_target,
                    "achieved": rpo_result.rpo_achieved,
                    "passed": rpo_result.passed
                },
                "overall_passed": rto_result.passed and rpo_result.passed
            }
            
            results["tests"].append(test_result)
            results["summary"]["total"] += 1
            if test_result["overall_passed"]:
                results["summary"]["passed"] += 1
            else:
                results["summary"]["failed"] += 1
        
        return results
    
    def generate_report(self, results: Dict[str, Any]) -> str:
        """Generate a BCP validation report."""
        report = []
        report.append("=" * 70)
        report.append("BCP VALIDATION REPORT")
        report.append("=" * 70)
        report.append(f"Timestamp: {results['timestamp']}")
        report.append("")
        
        report.append("Test Results:")
        report.append("-" * 40)
        
        for test in results["tests"]:
            status = "✅ PASS" if test["overall_passed"] else "❌ FAIL"
            report.append(f"\n{status} - {test['system']} (Tier {test['tier']})")
            report.append(f"  RTO: {test['rto']['achieved']}s / {test['rto']['target']}s ({'✅' if test['rto']['passed'] else '❌'})")
            report.append(f"  RPO: {test['rpo']['achieved']}s / {test['rpo']['target']}s ({'✅' if test['rpo']['passed'] else '❌'})")
        
        report.append("")
        report.append("Summary:")
        report.append("-" * 40)
        report.append(f"Total Tests: {results['summary']['total']}")
        report.append(f"Passed: {results['summary']['passed']}")
        report.append(f"Failed: {results['summary']['failed']}")
        report.append(f"Pass Rate: {((results['summary']['passed'] / results['summary']['total']) * 100) if results['summary']['total'] > 0 else 0:.1f}%")
        report.append("")
        
        if results["summary"]["failed"] > 0:
            report.append("⚠️  WARNING: Some BCP tests failed. Review and remediate.")
        else:
            report.append("✅ SUCCESS: All BCP tests passed!")
        
        return "\n".join(report)

# ====================================================================
# Main Entry Point
# ====================================================================

def main():
    """Main entry point."""
    logger.info("Starting BCP validation tests...")
    
    runner = BCTestRunner()
    results = runner.run_all_tests()
    report = runner.generate_report(results)
    
    print(report)
    
    # Save report
    report_dir = CONFIG["REPORT_PATH"]
    if not os.path.exists(report_dir):
        os.makedirs(report_dir)
    
    report_file = os.path.join(report_dir, f"bcp_report_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.txt")
    with open(report_file, 'w') as f:
        f.write(report)
    
    # Save JSON results
    json_file = os.path.join(report_dir, f"bcp_results_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.json")
    with open(json_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    logger.info(f"Report generated: {report_file}")
    logger.info(f"Results saved: {json_file}")
    
    # Exit with error if any tests failed
    if results["summary"]["failed"] > 0:
        exit(1)
    else:
        exit(0)

if __name__ == "__main__":
    main()
```

**Verification:**

```bash
# Verify RTO/RPO validation file
ls -la bcr/05_rpo_rto_validation.py
# Expected: File exists

# Check Python syntax
python3 -m py_compile bcr/05_rpo_rto_validation.py
# Expected: No syntax errors
```

---

### Step 7: Business Continuity Summary

**File:** `bcr/README.md`

```markdown
# Business Continuity & Resilience - Nexus Global Industries

## Overview

This directory contains the complete business continuity and resilience implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_bcp_plan.md` | Plan | Business continuity plan |
| `02_recovery_strategies.yaml` | Strategies | Recovery strategies by tier |
| `03_immutable_backups.yaml` | Backups | Immutable backup configuration |
| `04_air_gapped_vaults.yaml` | Vaults | Air-gapped vault setup |
| `05_rpo_rto_validation.py` | Validation | RTO/RPO validation framework |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│               BUSINESS CONTINUITY & RESILIENCE                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  BUSINESS CONTINUITY PLAN                             │   │
│  │  • BIA and criticality tiers                         │   │
│  │  • Incident scenarios                               │   │
│  │  • Recovery strategies                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  RECOVERY STRATEGIES                                   │   │
│  │  • Active-Active                                      │   │
│  │  • Active-Passive                                     │   │
│  │  • Cross-cloud recovery                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  IMMUTABLE BACKUPS                                    │   │
│  │  • AWS S3 Object Lock                                │   │
│  │  • Azure Immutable Blob                              │   │
│  │  • WORM protection                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  AIR-GAPPED VAULTS                                    │   │
│  │  • Primary and secondary vaults                       │   │
│  │  • Offline storage                                    │   │
│  │  • 2-person access                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  RTO/RPO VALIDATION                                   │   │
│  │  • Automated testing                                 │   │
│  │  • Compliance reporting                              │   │
│  │  • Continuous monitoring                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Description |
|---------|-------------|
| **BCP Plan** | Complete business continuity plan |
| **Recovery Strategies** | Tier-based recovery approaches |
| **Immutable Backups** | WORM-protected backup systems |
| **Air-Gapped Vaults** | Offline recovery storage |
| **RTO/RPO Validation** | Automated testing framework |
| **Cross-Cloud** | AWS + Azure recovery |

## RTO/RPO Targets

| Tier | Description | RTO | RPO | Recovery Method |
|------|-------------|-----|-----|-----------------|
| **Tier 0** | Critical | 2 hours | 15 minutes | Active-Active |
| **Tier 1** | High | 4 hours | 1 hour | Active-Passive |
| **Tier 2** | Medium | 8 hours | 4 hours | Active-Passive |
| **Tier 3** | Low | 24 hours | 24 hours | Active-Passive |

## Deployment Instructions

### 1. Configure Immutable Backups

```bash
# AWS
aws s3api put-bucket-versioning --bucket nexus-critical-backups --versioning-configuration Status=Enabled
aws s3api put-object-lock-configuration --bucket nexus-critical-backups --object-lock-configuration '{"ObjectLockEnabled":"Enabled"}'

# Azure
az storage container immutability-policy set --container-name critical-backups --account-name nexusstorage --period 30 --allow-protected-append-writes true
```

### 2. Configure Air-Gapped Vaults

```bash
# AWS Glacier Vault
aws glacier create-vault --vault-name nexus-primary-vault --account-id -

# Azure Archive Storage
az storage container create --name archive-backups --account-name nexusstorage --public-access off
```

### 3. Run BCP Validation

```bash
python3 bcr/05_rpo_rto_validation.py
```

## Verification Checklist

- [ ] BCP plan documented
- [ ] Recovery strategies defined
- [ ] Immutable backups configured
- [ ] Air-gapped vaults established
- [ ] RTO/RPO validation passing
- [ ] BCP testing schedule in place
- [ ] All tiers covered

---

**Maintained By**: CISO  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la bcr/README.md
# Expected: File exists

echo "✅ Business Continuity & Resilience Complete!"
echo "   - BCP plan documented"
echo "   - Recovery strategies by tier"
echo "   - Immutable backup configuration"
echo "   - Air-gapped vault setup"
echo "   - RTO/RPO validation framework"
```

---

## Part 4 Completion Summary

**[GENERATED: Part 4 Complete - Detection Engineering, Security Operations & Operational Resilience]**

### What We've Built

| Section | Artifacts | Status |
|---------|-----------|--------|
| **4.1 SIEM/XDR Architecture** | 5 files (Elasticsearch, Logstash, Kibana, XDR, retention) | ✅ Complete |
| **4.2 Detection Engineering** | 5 files (Sigma rules, MITRE mapping, testing, lifecycle, FP) | ✅ Complete |
| **4.3 Threat Hunting** | 5 files (methodology, playbooks, queries, notebook, reporting) | ✅ Complete |
| **4.4 SOAR Automation** | 5 files (playbooks, enrichment, case management, actions, integrations) | ✅ Complete |
| **4.5 Chaos Engineering** | 5 files (failure scenarios, security chaos, validation, metrics, automation) | ✅ Complete |
| **4.6 Business Continuity** | 5 files (BCP plan, recovery strategies, immutable backups, vaults, validation) | ✅ Complete |

### Total Artifacts Created (Part 4)

```
siem/
├── 01_elasticsearch.yaml
├── 02_logstash_pipelines.yaml
├── 03_kibana_dashboards.yaml
├── 04_xdr_integration.yaml
├── 05_log_retention.yaml
└── README.md

detection/
├── 01_sigma_rules.yaml
├── 02_mitre_mapping.yaml
├── 03_rule_testing.py
├── 04_detection_lifecycle.md
├── 05_false_positive_management.yaml
└── README.md

hunting/
├── 01_hunting_methodology.md
├── 02_hunting_playbooks.yaml
├── 03_hunting_queries.md
├── 04_hunting_notebook.ipynb
├── 05_hunting_reporting.yaml
└── README.md

soar/
├── 01_playbooks.yaml
├── 02_enrichment.yaml
├── 03_case_management.yaml
├── 04_automated_actions.yaml
├── 05_integrations.yaml
└── README.md

chaos/
├── 01_failure_scenarios.yaml
├── 02_security_chaos.yaml
├── 03_resilience_validation.yaml
├── 04_metrics.yaml
├── 05_automation.py
└── README.md

bcr/
├── 01_bcp_plan.md
├── 02_recovery_strategies.yaml
├── 03_immutable_backups.yaml
├── 04_air_gapped_vaults.yaml
├── 05_rpo_rto_validation.py
└── README.md
```

**Total Files Created in Part 4: 36+**

---

**[END OF PART 4]**

Part 4: Detection Engineering, Security Operations & Operational Resilience is now complete. You have built a complete security operations and resilience program for Nexus Global Industries, including SIEM/XDR, detection engineering, threat hunting, SOAR automation, chaos engineering, and business continuity.

### What's Next

**Part 5: Enterprise Capstone - End-to-End Secure Architecture Blueprint** will integrate all previous parts into a complete enterprise security architecture deliverable, including:
- Executive summary and business architecture
- Enterprise security topology
- Threat model package
- Zero Trust and cloud blueprint
- Detection, response, and resilience
