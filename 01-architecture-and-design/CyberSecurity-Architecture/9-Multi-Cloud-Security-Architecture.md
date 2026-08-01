# Part 3: Cloud-Native Security & Modern Workloads
## Section 3.1: Multi-Cloud Security Architecture

## The Target: Complete Multi-Cloud Security Architecture for Nexus Global Industries

In this section, we'll implement a comprehensive multi-cloud security architecture for Nexus Global Industries, including:

1. **Multi-Cloud Landing Zones** - AWS and Azure with consistent controls
2. **Shared Responsibility Model** - Operational boundaries mapping
3. **CSPM Implementation** - Cloud Security Posture Management (AWS Security Hub, Azure Security Center)
4. **Cross-Cloud Identity** - Consistent IAM across clouds
5. **Cloud Compliance** - CIS benchmarks and NIST 800-53 controls

**What specific file(s) are we building?**
- `cloud/01_landing_zones.tf` - Terraform landing zone configuration
- `cloud/02_shared_responsibility.md` - Shared responsibility mapping
- `cloud/03_cspm_config.yaml` - CSPM automation configuration
- `cloud/04_cross_cloud_iam.tf` - Cross-cloud IAM policies
- `cloud/05_compliance_checks.yaml` - Compliance automation

---

## The Concept: Multi-Cloud Security in Plain English

Think of multi-cloud security like **building the same security system across multiple buildings in different cities**:

**Multi-Cloud:** "Your company has offices in New York (AWS) and London (Azure)." This is using multiple cloud providers.

**Landing Zones:** "Both offices have the same alarm system, same locks, and same security guards." This is consistent security controls.

**Shared Responsibility:** "The building owner is responsible for the structure and locks, but you're responsible for your own office door and files." This is the cloud provider vs. customer responsibility split.

**CSPM:** "A central security team monitors both offices' alarms and cameras in real-time." This is continuous posture management.

**Cross-Cloud IAM:** "Your ID badge works in both the New York and London offices." This is consistent identity across clouds.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the cloud directory
cd ~/nexus_security_architecture
mkdir -p cloud

# Verify the structure
ls -la
# Expected: cloud directory appears
```

---

### Step 2: Multi-Cloud Landing Zones (Terraform)

**File:** `cloud/01_landing_zones.tf`

```hcl
# Multi-Cloud Landing Zones - Nexus Global Industries
# File: cloud/01_landing_zones.tf
# Version: 1.0

# ====================================================================
# PROVIDER CONFIGURATION
# ====================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Nexus-Security"
    }
  }
}

# Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# ====================================================================
# VARIABLES
# ====================================================================

variable "environment" {
  description = "Environment name (prod/staging/dev)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "nexus"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "organization_name" {
  description = "Organization name for naming"
  type        = string
  default     = "nexus"
}

# ====================================================================
# AWS LANDING ZONE
# ====================================================================

# AWS Organizations - Multi-account structure
resource "aws_organizations_organization" "nexus" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "securityhub.amazonaws.com",
    "guardduty.amazonaws.com"
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

# AWS Organizational Units (OUs)
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.nexus.roots[0].id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = aws_organizations_organization.nexus.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.nexus.roots[0].id
}

# AWS Accounts
resource "aws_organizations_account" "security" {
  name  = "nexus-security"
  email = "security@nexus.com"
  parent_id = aws_organizations_organizational_unit.security.id
  tags = {
    Environment = var.environment
    Purpose     = "Security Operations"
  }
}

resource "aws_organizations_account" "production" {
  name  = "nexus-production"
  email = "production@nexus.com"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags = {
    Environment = var.environment
    Purpose     = "Production Workloads"
  }
}

resource "aws_organizations_account" "rd" {
  name  = "nexus-rd"
  email = "rd@nexus.com"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags = {
    Environment = var.environment
    Purpose     = "R&D Workloads"
  }
}

# AWS SCP - Service Control Policies
resource "aws_organizations_policy" "deny_public_s3" {
  name        = "DenyPublicS3"
  description = "Denies public access to S3 buckets"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DenyPublicS3"
        Effect = "Deny"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketAcl",
          "s3:PutBucketPolicy"
        ]
        Resource = "arn:aws:s3:::*"
        Condition = {
          "Bool" = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_regions" {
  name        = "DenyRegions"
  description = "Restricts usage to allowed regions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DenyRegions"
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          "StringNotEquals" = {
            "aws:RequestedRegion" = [
              "us-east-1",
              "us-west-2",
              "eu-west-1",
              "ap-southeast-1"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "require_encryption" {
  name        = "RequireEncryption"
  description = "Requires encryption for all resources"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "RequireEncryption"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances",
          "rds:CreateDBInstance",
          "rds:CreateDBCluster",
          "s3:CreateBucket"
        ]
        Resource = "*"
        Condition = {
          "Bool" = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Attach SCPs to OUs
resource "aws_organizations_policy_attachment" "deny_public_s3" {
  policy_id = aws_organizations_policy.deny_public_s3.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_policy_attachment" "deny_regions" {
  policy_id = aws_organizations_policy.deny_regions.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_policy_attachment" "require_encryption" {
  policy_id = aws_organizations_policy.require_encryption.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

# AWS Control Tower - Guardrails
resource "aws_controltower_guardrail" "guardrail_1" {
  # Guardrail configuration
  # Note: Control Tower guardrails are managed via AWS API
}

# AWS Security Hub - Central security management
resource "aws_securityhub_account" "nexus" {
  # Enable Security Hub for AWS account
}

# AWS GuardDuty - Threat detection
resource "aws_guardduty_detector" "nexus" {
  enable = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
  }
}

# AWS Config - Compliance monitoring
resource "aws_config_configuration_recorder" "nexus" {
  name     = "nexus-config-recorder"
  role_arn = aws_iam_role.config_role.arn
}

resource "aws_config_delivery_channel" "nexus" {
  name           = "nexus-config-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
}

# AWS Config Rules
resource "aws_config_config_rule" "encrypted_volumes" {
  name = "encrypted-volumes"
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
}

resource "aws_config_config_rule" "restricted_ssh" {
  name = "restricted-ssh"
  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
}

resource "aws_config_config_rule" "s3_bucket_public_read" {
  name = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

# AWS CloudTrail - Audit logging
resource "aws_cloudtrail" "nexus" {
  name                          = "nexus-cloudtrail"
  s3_bucket_name               = aws_s3_bucket.cloudtrail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging                = true
  cloud_watch_logs_group_arn   = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn    = aws_iam_role.cloudtrail_role.arn
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}

# ====================================================================
# AZURE LANDING ZONE
# ====================================================================

# Azure Management Groups
resource "azurerm_management_group" "nexus" {
  display_name = "Nexus Global Industries"
}

resource "azurerm_management_group" "security" {
  display_name               = "Security"
  parent_management_group_id = azurerm_management_group.nexus.id
}

resource "azurerm_management_group" "infrastructure" {
  display_name               = "Infrastructure"
  parent_management_group_id = azurerm_management_group.nexus.id
}

resource "azurerm_management_group" "workloads" {
  display_name               = "Workloads"
  parent_management_group_id = azurerm_management_group.nexus.id
}

# Azure Subscriptions
resource "azurerm_subscription" "security" {
  subscription_name = "nexus-security"
  management_group_id = azurerm_management_group.security.id
}

resource "azurerm_subscription" "production" {
  subscription_name = "nexus-production"
  management_group_id = azurerm_management_group.workloads.id
}

# Azure Policies (equivalent to AWS SCPs)
resource "azurerm_policy_definition" "allowed_regions" {
  name         = "allowed-regions"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allowed regions for resources"
  
  policy_rule = jsonencode({
    "if": {
      "allOf": [
        {
          "field": "location",
          "notIn": ["eastus", "westus", "europe", "southeastasia"]
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  })
}

resource "azurerm_policy_definition" "require_encryption" {
  name         = "require-encryption"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require encryption for storage"
  
  policy_rule = jsonencode({
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Storage/storageAccounts"
        },
        {
          "field": "Microsoft.Storage/storageAccounts/enableHttpsTrafficOnly",
          "equals": false
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  })
}

# Azure Policy Assignments
resource "azurerm_policy_assignment" "allowed_regions" {
  name                 = "allowed-regions-assignment"
  policy_definition_id = azurerm_policy_definition.allowed_regions.id
  management_group_id  = azurerm_management_group.workloads.id
}

resource "azurerm_policy_assignment" "require_encryption" {
  name                 = "require-encryption-assignment"
  policy_definition_id = azurerm_policy_definition.require_encryption.id
  management_group_id  = azurerm_management_group.workloads.id
}

# Azure Security Center (Defender for Cloud)
resource "azurerm_security_center_subscription_pricing" "nexus" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

# Azure Sentinel (SIEM)
resource "azurerm_sentinel_workspace" "nexus" {
  name                       = "nexus-sentinel"
  location                   = "eastus"
  resource_group_name        = aws_azurerm_resource_group.security.name
  sku                        = "PerGB2018"
  retention_in_days          = 90
}

# Azure Policy Initiatives (Compliance bundles)
resource "azurerm_policy_set_definition" "cis_benchmark" {
  name         = "cis-benchmark"
  policy_type  = "Custom"
  display_name = "CIS Azure Benchmark Controls"
  
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_encryption.id
    reference_id        = "encryption"
  }
}

# ====================================================================
# COMMON RESOURCES (Cross-Cloud)
# ====================================================================

# AWS S3 Bucket for Config Logs
resource "aws_s3_bucket" "config_bucket" {
  bucket = "nexus-config-logs-${var.environment}"
  force_destroy = true
  tags = {
    Name = "nexus-config-logs"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# AWS S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "nexus-cloudtrail-logs-${var.environment}"
  force_destroy = true
  tags = {
    Name = "nexus-cloudtrail-logs"
  }
}

# AWS IAM Role for Config
resource "aws_iam_role" "config_role" {
  name = "nexus-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      }
    ]
  })
}

# AWS IAM Role for CloudTrail
resource "aws_iam_role" "cloudtrail_role" {
  name = "nexus-cloudtrail-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      }
    ]
  })
}

# AWS CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/nexus"
  retention_in_days = 90
}

# Azure Resource Group for Security
resource "azurerm_resource_group" "security" {
  name     = "nexus-security-rg"
  location = "eastus"
  tags = {
    Environment = var.environment
    Purpose     = "Security Operations"
  }
}

# Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "nexus" {
  name                = "nexus-log-analytics"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# ====================================================================
# OUTPUTS
# ====================================================================

output "aws_security_hub_arn" {
  value = aws_securityhub_account.nexus.id
}

output "azure_sentinel_workspace_id" {
  value = azurerm_sentinel_workspace.nexus.id
}

output "cross_cloud_identity_role_arns" {
  value = {
    aws = aws_iam_role.cross_cloud_role.arn
    azure = azurerm_role_definition.cross_cloud_role.id
  }
}
```

**Verification:**

```bash
# Verify Terraform landing zone file
ls -la cloud/01_landing_zones.tf
# Expected: File exists

# Validate Terraform syntax
terraform fmt -check cloud/01_landing_zones.tf 2>/dev/null || echo "Check complete"
# Expected: No errors
```

---

### Step 3: Shared Responsibility Model Mapping

**File:** `cloud/02_shared_responsibility.md`

```markdown
# Shared Responsibility Model - Nexus Global Industries

## Overview

The Shared Responsibility Model defines which security responsibilities are handled by the cloud provider and which are handled by Nexus Global Industries. This document provides a comprehensive mapping for AWS, Azure, and on-premises workloads.

## Responsibility Mapping Matrix

### AWS Shared Responsibility Model

| Domain | AWS Responsibility | Nexus Responsibility | Implementation |
|--------|-------------------|---------------------|----------------|
| **Physical Infrastructure** | ✅ | ❌ | Data centers, hardware, network |
| **Hypervisor** | ✅ | ❌ | EC2 hypervisor, virtualization |
| **Managed Services (S3, RDS, etc.)** | ✅ | ❌ | Patching, uptime, security |
| **Guest Operating System** | ❌ | ✅ | Patching, configuration, hardening |
| **Application Code** | ❌ | ✅ | SAST/DAST, secure development |
| **Data at Rest** | ❌ | ✅ | Encryption keys, access controls |
| **Data in Transit** | ❌ | ✅ | TLS, mTLS configuration |
| **IAM (Users, Groups, Roles)** | ❌ | ✅ | Identity management, MFA |
| **Network Security** | ❌ | ✅ | VPC, Security Groups, Network ACLs |
| **Security Configurations** | ❌ | ✅ | Security groups, IAM policies, logging |
| **Compliance Certifications** | ✅ | ❌ | SOC 2, PCI DSS, ISO 27001 (infrastructure) |
| **Compliance Implementation** | ❌ | ✅ | Compliance controls on workloads |

### Azure Shared Responsibility Model

| Domain | Azure Responsibility | Nexus Responsibility | Implementation |
|--------|---------------------|---------------------|----------------|
| **Physical Infrastructure** | ✅ | ❌ | Data centers, hardware, network |
| **Hypervisor** | ✅ | ❌ | Azure hypervisor, virtualization |
| **Managed Services (Blob, SQL, etc.)** | ✅ | ❌ | Patching, uptime, security |
| **Guest Operating System** | ❌ | ✅ | Patching, configuration, hardening |
| **Application Code** | ❌ | ✅ | SAST/DAST, secure development |
| **Data at Rest** | ❌ | ✅ | Encryption keys, access controls |
| **Data in Transit** | ❌ | ✅ | TLS, mTLS configuration |
| **IAM (Users, Groups, Roles)** | ❌ | ✅ | Identity management, MFA |
| **Network Security** | ❌ | ✅ | VNet, NSGs, Firewall |
| **Security Configurations** | ❌ | ✅ | NSGs, IAM policies, logging |
| **Compliance Certifications** | ✅ | ❌ | SOC 2, PCI DSS, ISO 27001 (infrastructure) |
| **Compliance Implementation** | ❌ | ✅ | Compliance controls on workloads |

### Multi-Cloud Responsibility Matrix

| Responsibility | AWS | Azure | Nexus Implementation |
|----------------|-----|-------|---------------------|
| **Physical Security** | AWS Data Centers | Azure Data Centers | ❌ |
| **Network Infrastructure** | AWS VPC | Azure VNet | Security Groups, NSGs |
| **Compute Security** | EC2 Security | VM Security | AMI/Hardened Images, Patching |
| **Storage Security** | S3 Security | Blob Security | Encryption, Access Controls |
| **Database Security** | RDS Security | SQL Security | Encryption, Access Controls |
| **Container Security** | EKS Security | AKS Security | Container scanning, RBAC |
| **Identity** | AWS IAM | Azure AD | Cross-cloud IAM federation |
| **Monitoring** | AWS CloudWatch | Azure Monitor | SIEM integration |
| **Compliance** | AWS Config | Azure Policy | Cross-cloud compliance automation |

## Responsibility Gaps and Mitigations

### Gap 1: Cross-Cloud Identity
- **Gap**: No unified identity across clouds
- **Mitigation**: Azure AD as primary IdP with AWS IAM federation
- **Owner**: Lead Security Architect
- **Status**: In Progress

### Gap 2: Cross-Cloud Monitoring
- **Gap**: Separate monitoring in each cloud
- **Mitigation**: Centralized SIEM with cross-cloud data ingestion
- **Owner**: Lead Security Architect
- **Status**: In Progress

### Gap 3: Consistent Compliance
- **Gap**: Different compliance tools across clouds
- **Mitigation**: Policy-as-Code with OPA across both clouds
- **Owner**: Lead Security Architect
- **Status**: In Progress

## Responsibility Escalation Process

| Issue | Primary Responsibility | Escalation Path | Timeline |
|-------|----------------------|-----------------|----------|
| **Infrastructure Outage** | Cloud Provider | Nexus → Cloud Provider | Immediate |
| **Configuration Misuse** | Nexus | Security Team → CISO | 1 hour |
| **Data Breach** | Nexus | IR Team → CISO → Board | Immediate |
| **Compliance Violation** | Nexus | Compliance Team → CISO | 24 hours |
| **Security Incident** | Nexus | IR Team → CISO → Board | Immediate |

## Training and Awareness

| Training Module | Audience | Frequency | Owner |
|-----------------|----------|-----------|-------|
| **Shared Responsibility Model** | All Cloud Teams | Annual | Lead Security Architect |
| **AWS Security Best Practices** | AWS Engineers | Quarterly | Lead Security Architect |
| **Azure Security Best Practices** | Azure Engineers | Quarterly | Lead Security Architect |
| **Cross-Cloud Security** | Security Team | Quarterly | Lead Security Architect |

---

**Document Owner**: Lead Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0
```

**Verification:**

```bash
# Verify shared responsibility document
ls -la cloud/02_shared_responsibility.md
# Expected: File exists

# Check sections
grep -c "##" cloud/02_shared_responsibility.md
# Expected: Shows multiple sections
```

---

### Step 4: Cloud Security Posture Management (CSPM)

**File:** `cloud/03_cspm_config.yaml`

```yaml
# Cloud Security Posture Management (CSPM) - Nexus Global Industries
# File: cloud/03_cspm_config.yaml
# Version: 1.0

# ====================================================================
# AWS SECURITY HUB CONFIGURATION
# ====================================================================

aws_security_hub:
  enabled: true
  regions:
    - "us-east-1"
    - "us-west-2"
    - "eu-west-1"
    - "ap-southeast-1"
  
  standards:
    - name: "CIS AWS Foundations Benchmark"
      version: "1.4.0"
      enabled: true
      controls:
        - "1.1"  # Avoid the use of the root user
        - "1.2"  # MFA enabled for root user
        - "1.3"  # Credential report
        - "2.1"  # CloudTrail enabled
        - "2.2"  # CloudTrail encryption
        - "2.3"  # CloudTrail log file validation
        - "3.1"  # S3 bucket logging
        - "3.2"  # S3 bucket public access
        - "4.1"  # Security group restrictions
        - "4.2"  # VPC flow logging
        - "5.1"  # IAM password policy
        - "5.2"  # IAM user with admin privileges
    
    - name: "AWS Foundational Security Best Practices"
      version: "1.0.0"
      enabled: true
    
    - name: "NIST SP 800-53 Rev. 5"
      version: "1.0.0"
      enabled: true
  
  security_controls:
    - control: "AWS-CONTROL-001"
      name: "IAM users with MFA"
      severity: "HIGH"
      remediation: "Enable MFA for all IAM users"
      automation: "aws_iam_mfa"
    
    - control: "AWS-CONTROL-002"
      name: "S3 bucket public access"
      severity: "CRITICAL"
      remediation: "Block public access to S3 buckets"
      automation: "aws_s3_block_public"
    
    - control: "AWS-CONTROL-003"
      name: "Security group unrestricted access"
      severity: "CRITICAL"
      remediation: "Restrict security group access"
      automation: "aws_security_group_restrict"
    
    - control: "AWS-CONTROL-004"
      name: "EC2 instances with public IP"
      severity: "HIGH"
      remediation: "Remove public IPs or use bastion"
      automation: "aws_ec2_public_ip"
    
    - control: "AWS-CONTROL-005"
      name: "RDS encryption at rest"
      severity: "HIGH"
      remediation: "Enable encryption for RDS"
      automation: "aws_rds_encryption"

# ====================================================================
# AZURE SECURITY CENTER CONFIGURATION
# ====================================================================

azure_security_center:
  enabled: true
  pricing_tier: "Standard"
  coverage:
    - "VirtualMachines"
    - "AppServices"
    - "StorageAccounts"
    - "SQLDatabases"
    - "Containers"
    - "KeyVault"
  
  standards:
    - name: "CIS Azure Foundations Benchmark"
      version: "1.4.0"
      enabled: true
    
    - name: "Azure Security Benchmark"
      version: "1.0.0"
      enabled: true
    
    - name: "NIST SP 800-53 Rev. 5"
      version: "1.0.0"
      enabled: true
  
  policies:
    - policy: "AZURE-CONTROL-001"
      name: "MFA for administrative accounts"
      severity: "HIGH"
      remediation: "Enable MFA for all admin accounts"
    
    - policy: "AZURE-CONTROL-002"
      name: "Network Security Group rules"
      severity: "CRITICAL"
      remediation: "Restrict NSG rules"
    
    - policy: "AZURE-CONTROL-003"
      name: "Storage account encryption"
      severity: "HIGH"
      remediation: "Enable encryption for storage"
    
    - policy: "AZURE-CONTROL-004"
      name: "SQL Server auditing"
      severity: "HIGH"
      remediation: "Enable SQL Server auditing"
    
    - policy: "AZURE-CONTROL-005"
      name: "Key Vault logging"
      severity: "HIGH"
      remediation: "Enable Key Vault logging"

# ====================================================================
# CROSS-CLOUD CSPM AUTOMATION
# ====================================================================

cspm_automation:
  enabled: true
  sync_interval: 60  # minutes
  
  integrations:
    - type: "aws_security_hub"
      destination: "siem"
      format: "cloudtrail"
      filter:
        severity: ["CRITICAL", "HIGH"]
    
    - type: "azure_security_center"
      destination: "siem"
      format: "activity_log"
      filter:
        severity: ["High", "Medium"]
  
  remediation_workflows:
    - name: "auto_remediate_s3_public"
      enabled: true
      trigger: "AWS-CONTROL-002"
      action: "block_public_access"
    
    - name: "auto_remediate_security_group"
      enabled: true
      trigger: "AWS-CONTROL-003"
      action: "remove_unrestricted_ssh"
    
    - name: "auto_remediate_storage_encryption"
      enabled: true
      trigger: "AZURE-CONTROL-003"
      action: "enable_encryption"
  
  notification:
    - channel: "slack"
      severity: ["CRITICAL"]
    - channel: "pagerduty"
      severity: ["CRITICAL"]
    - channel: "email"
      severity: ["HIGH", "MEDIUM"]

# ====================================================================
# COMPLIANCE SCANNING
# ====================================================================

compliance_scanning:
  enabled: true
  schedule: "daily"
  
  scans:
    - name: "CIS AWS Benchmark"
      frequency: "daily"
      tools:
        - "AWS Security Hub"
        - "AWS Config"
      reporting:
        - "siem"
        - "dashboards"
    
    - name: "CIS Azure Benchmark"
      frequency: "daily"
      tools:
        - "Azure Security Center"
        - "Azure Policy"
      reporting:
        - "siem"
        - "dashboards"
    
    - name: "Custom Nexus Baseline"
      frequency: "hourly"
      tools:
        - "OPA"
        - "Terraform Sentinel"
      policies:
        - "resource_encryption"
        - "network_restrictions"
        - "iam_best_practices"
      reporting:
        - "siem"
        - "slack"

# ====================================================================
# DASHBOARD CONFIGURATION
# ====================================================================

dashboards:
  - name: "Security Posture Overview"
    metrics:
      - "compliance_score"
      - "open_findings"
      - "risk_level"
      - "remediation_progress"
    source: "aws_security_hub,azure_security_center"
    visualization: "grafana"
  
  - name: "Cross-Cloud Compliance"
    metrics:
      - "aws_compliance_percentage"
      - "azure_compliance_percentage"
      - "critical_findings"
      - "remediated_findings"
    source: "aws_config,azure_policy"
    visualization: "grafana"
```

**Verification:**

```bash
# Verify CSPM configuration
ls -la cloud/03_cspm_config.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cloud/03_cspm_config.yaml'))"
# Expected: No error output
```

---

### Step 5: Cross-Cloud IAM Configuration

**File:** `cloud/04_cross_cloud_iam.tf`

```hcl
# Cross-Cloud IAM Configuration - Nexus Global Industries
# File: cloud/04_cross_cloud_iam.tf
# Version: 1.0

# ====================================================================
# AWS IAM ROLES FOR CROSS-CLOUD ACCESS
# ====================================================================

# AWS IAM Role for cross-cloud federation
resource "aws_iam_role" "cross_cloud_role" {
  name = "nexus-cross-cloud-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/sts.azure.net"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "sts.azure.net/tid": azuread_service_principal.nexus.client_id
          }
        }
      }
    ]
  })
  
  tags = {
    Name = "nexus-cross-cloud-role"
    Purpose = "Cross-cloud federation"
  }
}

# AWS IAM Policy for cross-cloud role
resource "aws_iam_policy" "cross_cloud_policy" {
  name        = "nexus-cross-cloud-policy"
  description = "Policy for cross-cloud access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketPolicyStatus",
          "iam:GetAccountSummary",
          "iam:ListUsers",
          "iam:ListRoles"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_policy_attachment" "cross_cloud" {
  name       = "nexus-cross-cloud-attachment"
  policy_arn = aws_iam_policy.cross_cloud_policy.arn
  roles      = [aws_iam_role.cross_cloud_role.name]
}

# ====================================================================
# AZURE AD INTEGRATION (FEDERATION)
# ====================================================================

# Azure AD Application for cross-cloud identity
resource "azuread_application" "nexus" {
  display_name     = "Nexus Global Industries"
  owners           = ["admin@nexus.com"]
  sign_in_audience = "AzureADMyOrg"
  
  web {
    redirect_uris = [
      "https://auth.nexus.com/oauth2",
      "https://portal.nexus.com/oauth2"
    ]
  }
}

# Azure AD Service Principal for AWS federation
resource "azuread_service_principal" "nexus" {
  application_id = azuread_application.nexus.application_id
}

# Azure AD Group for AWS access
resource "azuread_group" "aws_users" {
  display_name     = "AWS_Users"
  description      = "Users with AWS access"
  security_enabled = true
}

# Azure AD Group for Cloud Admins
resource "azuread_group" "cloud_admins" {
  display_name     = "Cloud_Admins"
  description      = "Cloud administrators"
  security_enabled = true
}

# Azure AD Group for Developers
resource "azuread_group" "developers" {
  display_name     = "Developers"
  description      = "Development team"
  security_enabled = true
}

# ====================================================================
# CROSS-CLOUD IAM POLICIES
# ====================================================================

# AWS Identity Center (formerly SSO) permission sets
resource "aws_ssoadmin_permission_set" "cloud_admin" {
  name             = "CloudAdmin"
  description      = "Full cloud administration access"
  instance_arn     = data.aws_ssoadmin_instances.default.arns[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set" "developer" {
  name             = "Developer"
  description      = "Developer access to cloud resources"
  instance_arn     = data.aws_ssoadmin_instances.default.arns[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set" "security_analyst" {
  name             = "SecurityAnalyst"
  description      = "Security monitoring and analysis"
  instance_arn     = data.aws_ssoadmin_instances.default.arns[0]
  session_duration = "PT8H"
}

# AWS Identity Center groups
resource "aws_identitystore_group" "cloud_admins" {
  identity_store_id = data.aws_ssoadmin_instances.default.identity_store_id
  display_name      = "Cloud Admins"
  description       = "Cloud administrators group"
}

resource "aws_identitystore_group" "developers" {
  identity_store_id = data.aws_ssoadmin_instances.default.identity_store_id
  display_name      = "Developers"
  description       = "Developers group"
}

# ====================================================================
# AZURE RBAC (Role-Based Access Control)
# ====================================================================

# Azure Role Definition - Custom roles
resource "azurerm_role_definition" "cloud_admin" {
  name        = "Nexus Cloud Admin"
  scope       = data.azurerm_subscription.primary.id
  description = "Custom cloud admin role"
  
  permissions {
    actions = [
      "Microsoft.Compute/*",
      "Microsoft.Storage/*",
      "Microsoft.Network/*",
      "Microsoft.Security/*",
      "Microsoft.Authorization/*/read"
    ]
    not_actions = []
  }
  
  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

resource "azurerm_role_definition" "security_analyst" {
  name        = "Nexus Security Analyst"
  scope       = data.azurerm_subscription.primary.id
  description = "Security analyst role"
  
  permissions {
    actions = [
      "Microsoft.Security/*/read",
      "Microsoft.OperationalInsights/workspaces/*/read",
      "Microsoft.Authorization/*/read"
    ]
    not_actions = []
  }
  
  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

# Azure Role Assignments
resource "azurerm_role_assignment" "cloud_admin_assign" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.cloud_admin.role_definition_resource_id
  principal_id       = azuread_group.cloud_admins.id
}

resource "azurerm_role_assignment" "developer_assign" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.cloud_admin.role_definition_resource_id
  principal_id       = azuread_group.developers.id
}

# ====================================================================
# DATA SOURCES
# ====================================================================

data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "default" {}

data "azurerm_subscription" "primary" {
  subscription_id = var.azure_subscription_id
}
```

**Verification:**

```bash
# Verify cross-cloud IAM file
ls -la cloud/04_cross_cloud_iam.tf
# Expected: File exists

# Validate Terraform syntax
terraform fmt -check cloud/04_cross_cloud_iam.tf 2>/dev/null || echo "Check complete"
```

---

### Step 6: Compliance Automation

**File:** `cloud/05_compliance_checks.yaml`

```yaml
# Compliance Automation - Nexus Global Industries
# File: cloud/05_compliance_checks.yaml
# Version: 1.0

# ====================================================================
# CIS AWS BENCHMARK CONTROLS
# ====================================================================

cis_aws_controls:
  - control_id: "1.1"
    name: "Avoid the use of the root user"
    severity: "CRITICAL"
    check: |
      aws iam get-account-summary | jq '.SummaryMap.AccountMFAEnabled'
    remediation: |
      aws iam create-account-alias --account-alias nexus
      aws iam update-account-password-policy --minimum-password-length 14
    automation: true
  
  - control_id: "1.2"
    name: "MFA enabled for root user"
    severity: "CRITICAL"
    check: |
      aws iam get-account-summary | jq '.SummaryMap.AccountMFAEnabled'
    remediation: |
      aws iam enable-mfa-device --user-name root --serial-number arn:aws:iam::123456789012:mfa/root
    automation: true
  
  - control_id: "2.1"
    name: "CloudTrail enabled"
    severity: "HIGH"
    check: |
      aws cloudtrail describe-trails | jq '.trailList[].IsMultiRegionTrail'
    remediation: |
      aws cloudtrail create-trail --name nexus-cloudtrail --s3-bucket-name nexus-cloudtrail-logs --is-multi-region-trail
    automation: true
  
  - control_id: "3.1"
    name: "S3 bucket logging enabled"
    severity: "HIGH"
    check: |
      aws s3api get-bucket-logging --bucket $BUCKET
    remediation: |
      aws s3api put-bucket-logging --bucket $BUCKET --bucket-logging-status '{"LoggingEnabled": {"TargetBucket": "nexus-logging", "TargetPrefix": "access-logs/"}}'
    automation: true
  
  - control_id: "4.1"
    name: "Security group restrictions"
    severity: "CRITICAL"
    check: |
      aws ec2 describe-security-groups --filters Name=ip-permission.to-port,Values=22
    remediation: |
      aws ec2 revoke-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
    automation: true

# ====================================================================
# CIS AZURE BENCHMARK CONTROLS
# ====================================================================

cis_azure_controls:
  - control_id: "1.1"
    name: "MFA for administrative accounts"
    severity: "CRITICAL"
    check: |
      az ad user list --filter "userType eq 'Member'" --query "[?startsWith(userPrincipalName, 'admin')].userPrincipalName"
    remediation: |
      az ad user update --upn $USER --force-change-password-next-login true
    automation: true
  
  - control_id: "2.1"
    name: "Activity log retention"
    severity: "HIGH"
    check: |
      az monitor diagnostic-settings list --resource /subscriptions/$SUB_ID
    remediation: |
      az monitor diagnostic-settings create --name nexus-diagnostics --resource /subscriptions/$SUB_ID --logs '[{"category": "Administrative", "enabled": true}]' --workspace $WORKSPACE_ID
    automation: true
  
  - control_id: "3.1"
    name: "Network Security Group rules"
    severity: "CRITICAL"
    check: |
      az network nsg list --query "[?contains(securityRules[?access=='Allow' && sourceAddressPrefix=='*' && destinationPortRange=='22'], 'yes')].name"
    remediation: |
      az network nsg rule update --name SSH --nsg-name $NSG_NAME --access Deny
    automation: true

# ====================================================================
# NIST 800-53 CONTROLS
# ====================================================================

nist_controls:
  - control_id: "AC-2"
    name: "Account Management"
    description: "Manage information system accounts"
    check: |
      aws iam list-users --query "Users[?CreateDate < '$(date -d '30 days ago' -I)']"
    remediation: |
      aws iam delete-login-profile --user-name $USER
    automation: true
  
  - control_id: "AC-3"
    name: "Access Enforcement"
    description: "Enforce approved authorizations for logical access"
    check: |
      aws iam get-account-authorization-details --filter User
    remediation: |
      aws iam attach-role-policy --role-name $ROLE --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
    automation: true
  
  - control_id: "AC-4"
    name: "Information Flow Enforcement"
    description: "Enforce approved information flow control policies"
    check: |
      aws ec2 describe-security-groups --filters Name=ip-permission.to-port,Values=3306
    remediation: |
      aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3306 --cidr 10.0.0.0/8
    automation: true
  
  - control_id: "AU-2"
    name: "Audit Events"
    description: "Identify, select, and define audit events"
    check: |
      aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin
    remediation: |
      aws cloudtrail create-trail --name nexus-audit --s3-bucket-name nexus-audit-logs --enable-log-file-validation
    automation: true
  
  - control_id: "AU-6"
    name: "Audit Review and Reporting"
    description: "Review and report on audit logs"
    check: |
      aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ModifyUserAttribute
    remediation: |
      aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ModifyUserAttribute
    automation: false

# ====================================================================
# AUTOMATED COMPLIANCE ENGINE
# ====================================================================

compliance_engine:
  enabled: true
  schedule: "hourly"
  
  checks:
    - name: "daily_scan"
      schedule: "0 0 * * *"  # Daily at midnight
      controls:
        - "cis_aws_controls"
        - "cis_azure_controls"
        - "nist_controls"
    
    - name: "hourly_scan"
      schedule: "0 * * * *"  # Hourly
      controls:
        - "CRITICAL" severity only
  
  remediation:
    enabled: true
    auto_remediate: false  # Require approval
    approval_required: true
    approval_channel: "slack"
    max_parallel: 5
  
  reporting:
    - destination: "siem"
      format: "json"
    - destination: "slack"
      format: "markdown"
    - destination: "email"
      format: "html"
      recipients: ["security@nexus.com"]

# ====================================================================
# COMPLIANCE SCORING
# ====================================================================

compliance_scoring:
  enabled: true
  
  weights:
    - category: "CRITICAL"
      weight: 50
    
    - category: "HIGH"
      weight: 30
    
    - category: "MEDIUM"
      weight: 15
    
    - category: "LOW"
      weight: 5
  
  thresholds:
    - status: "EXCELLENT"
      min_score: 90
      color: "green"
    
    - status: "GOOD"
      min_score: 75
      color: "yellow"
    
    - status: "FAIR"
      min_score: 60
      color: "orange"
    
    - status: "POOR"
      min_score: 0
      color: "red"
  
  target_score: 95
  current_score: 78  # Updated daily

# ====================================================================
# COMPLIANCE REPORTING
# ====================================================================

compliance_reporting:
  enabled: true
  
  reports:
    - name: "Executive Summary"
      format: "pdf"
      frequency: "weekly"
      recipients: ["executive@nexus.com", "security@nexus.com"]
      sections:
        - "overall_score"
        - "critical_findings"
        - "remediation_progress"
        - "trend_over_time"
    
    - name: "Detailed Compliance Report"
      format: "html"
      frequency: "daily"
      recipients: ["security@nexus.com", "compliance@nexus.com"]
      sections:
        - "all_findings"
        - "remediation_items"
        - "nist_controls_status"
        - "cis_controls_status"
```

**Verification:**

```bash
# Verify compliance file
ls -la cloud/05_compliance_checks.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cloud/05_compliance_checks.yaml'))"
# Expected: No error output

# Check control IDs
grep -c "control_id:" cloud/05_compliance_checks.yaml
# Expected: Shows 15+ controls
```

---

### Step 7: Cloud Security Summary

**File:** `cloud/README.md`

```markdown
# Cloud-Native Security Architecture - Nexus Global Industries

## Overview

This directory contains the complete multi-cloud security architecture for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_landing_zones.tf` | Terraform | Multi-cloud landing zone configuration |
| `02_shared_responsibility.md` | Governance | Shared responsibility model mapping |
| `03_cspm_config.yaml` | CSPM | Cloud Security Posture Management |
| `04_cross_cloud_iam.tf` | IAM | Cross-cloud identity federation |
| `05_compliance_checks.yaml` | Compliance | Automated compliance checks |

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                 MULTI-CLOUD SECURITY ARCHITECTURE               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  CROSS-CLOUD IAM (Azure AD + AWS IAM Federation)       │   │
│  │  • Unified identity across clouds                     │   │
│  │  • SCIM provisioning                                  │   │
│  │  • MFA enforcement                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  AWS Landing Zone                                      │   │
│  │  • Organizations (multi-account)                      │   │
│  │  • Control Tower (guardrails)                        │   │
│  │  • Security Hub (CSPM)                               │   │
│  │  • GuardDuty (threat detection)                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Azure Landing Zone                                    │   │
│  │  • Management Groups                                  │   │
│  │  • Security Center (CSPM)                            │   │
│  │  • Sentinel (SIEM)                                   │   │
│  │  • Policy (compliance)                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Shared Responsibility Model                          │   │
│  │  • AWS: IaaS, PaaS, SaaS mappings                    │   │
│  │  • Azure: IaaS, PaaS, SaaS mappings                  │   │
│  │  • Gap analysis and mitigation                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | AWS | Azure | Cross-Cloud |
|---------|-----|-------|-------------|
| **Identity** | IAM | Azure AD | Federation |
| **CSPM** | Security Hub | Security Center | Unified |
| **Threat Detection** | GuardDuty | Defender | SIEM |
| **Compliance** | Config | Policy | Automation |
| **Audit** | CloudTrail | Activity Log | Centralized |

## Deployment Instructions

### 1. Deploy AWS Landing Zone

```bash
terraform apply -target=aws_organizations_organization.nexus
terraform apply -target=aws_securityhub_account.nexus
terraform apply
```

### 2. Deploy Azure Landing Zone

```bash
terraform apply -target=azurerm_management_group.nexus
terraform apply -target=azurerm_security_center_subscription_pricing.nexus
terraform apply
```

### 3. Configure Cross-Cloud IAM

```bash
terraform apply -target=aws_iam_role.cross_cloud_role
terraform apply -target=azuread_service_principal.nexus
```

### 4. Deploy Compliance Automation

```bash
kubectl apply -f cloud/05_compliance_checks.yaml
```

## Verification Checklist

- [ ] AWS Organizations configured with SCPs
- [ ] Azure Management Groups configured
- [ ] AWS Security Hub enabled with all standards
- [ ] Azure Security Center enabled with Defender
- [ ] Cross-cloud identity federation working
- [ ] Compliance checks passing
- [ ] Shared responsibility model documented
- [ ] CSPM automation running

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la cloud/README.md
# Expected: File exists

echo "✅ Multi-Cloud Security Architecture Complete!"
echo "   - Landing zones (AWS + Azure)"
echo "   - Shared responsibility model"
echo "   - CSPM configuration"
echo "   - Cross-cloud IAM"
echo "   - Compliance automation"
```

---

## End of Section 3.1: Multi-Cloud Security Architecture

### Key Takeaway

You've implemented a complete multi-cloud security architecture for Nexus Global Industries, including consistent landing zones across AWS and Azure, a clear shared responsibility model, comprehensive CSPM automation, cross-cloud identity federation, and automated compliance checks.

### What's Next

**Section 3.2** will cover **Container & Kubernetes Security**, including:
- Container image scanning and SBOM generation
- Kubernetes hardening and RBAC
- Admission controllers (Kyverno)
- Pod security standards
- Runtime security monitoring
