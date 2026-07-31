# Appendix BC: Complete DevSecOps Reference

## Overview

This appendix provides comprehensive DevSecOps reference material for the Enterprise Cybersecurity Program. It includes CI/CD security, infrastructure as code, container security, and security automation.

---

## BC.1: DevSecOps Framework

### BC.1.1: DevSecOps Overview

**File:** `devsecops/devsecops-framework.md`

```markdown
# DevSecOps Framework

## 1. Overview

### 1.1 DevSecOps Purpose
To integrate security into the DevOps lifecycle, ensuring security is embedded throughout the development and deployment process.

### 1.2 DevSecOps Principles

1. **Shift Left:** Security early in SDLC
2. **Automation:** Automate security controls
3. **Collaboration:** Security, development, and operations
4. **Continuous:** Ongoing security
5. **Measurable:** Track security metrics

## 2. DevSecOps Lifecycle

### 2.1 Lifecycle Integration

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              DEVSECOPS LIFECYCLE                                            │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              PLAN                                               │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Security requirements                                                       │ │    │
│  │  │  • Threat modeling                                                              │ │    │
│  │  │  • Risk assessment                                                              │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              CODE                                              │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Secure coding practices                                                     │ │    │
│  │  │  • SAST                                                                        │ │    │
│  │  │  • Code review                                                                  │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              BUILD                                             │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • SCA                                                                         │ │    │
│  │  │  • Container scanning                                                           │ │    │
│  │  │  • Secret scanning                                                              │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              TEST                                              │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • DAST                                                                        │ │    │
│  │  │  • Penetration testing                                                          │ │    │
│  │  │  • Fuzzing                                                                      │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              DEPLOY                                            │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Secure deployment                                                           │ │    │
│  │  │  • Configuration hardening                                                      │ │    │
│  │  │  • Security validation                                                          │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              OPERATE                                            │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Monitoring                                                                  │ │    │
│  │  │  • Incident response                                                           │ │    │
│  │  │  • Vulnerability management                                                     │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## BC.2: CI/CD Security

### BC.2.1: Pipeline Security

**File:** `devsecops/pipeline-security.md`

```markdown
# CI/CD Pipeline Security

## 1. Overview

### 1.1 Pipeline Security Purpose
To secure the CI/CD pipeline and ensure secure code delivery.

### 1.2 Pipeline Security Controls

```yaml
# Pipeline Security Controls
pipeline_security:
  code_scanning:
    - "SAST (Static Analysis)"
    - "SCA (Software Composition Analysis)"
    - "Secrets scanning"
  
  build_security:
    - "Container scanning"
    - "Dependency checking"
    - "Malware scanning"
  
  deployment_security:
    - "Secure configuration"
    - "Infrastructure as Code scanning"
    - "Compliance checks"
  
  runtime_security:
    - "Monitoring"
    - "Runtime protection"
    - "Incident response"
```

## 2. Pipeline Configuration

### 2.1 GitHub Actions Pipeline

```yaml
# GitHub Actions Security Pipeline
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Run SAST
      uses: SonarSource/sonarqube-scan-action@v2
      with:
        sonarqube-url: ${{ secrets.SONARQUBE_URL }}
        sonarqube-token: ${{ secrets.SONARQUBE_TOKEN }}
    
    - name: Run SCA
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
    
    - name: Run Secrets Scanning
      uses: trufflesecurity/trufflehog@main
      with:
        args: --json
    
    - name: Run Container Scan
      uses: anchore/scan-action@v3
      with:
        image: ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
        severity: critical
    
    - name: Upload Results
      uses: actions/upload-artifact@v3
      with:
        name: security-results
        path: |
          sonarqube-report.json
          snyk-report.json
          container-scan.json
```

---

## BC.3: Infrastructure as Code Security

### BC.3.1: IaC Security

**File:** `devsecops/iac-security.md`

```markdown
# Infrastructure as Code Security

## 1. Overview

### 1.1 IaC Security Purpose
To secure infrastructure defined as code.

### 1.2 IaC Security Controls

```yaml
# IaC Security Controls
iac_security:
  scanning:
    - tool: "Checkov"
      stages: ["Pre-commit", "Plan", "Apply"]
      rules:
        - "S3 bucket public access"
        - "EC2 security group rules"
        - "IAM least privilege"
        - "Encryption enabled"
        - "Logging enabled"
    
    - tool: "tfsec"
      stages: ["Pre-commit"]
      severity: "Critical"
  
  security:
    - "Infrastructure as code scanning"
    - "Configuration validation"
    - "Compliance checks"
    - "Security posture"
```

## 2. Terraform Security

### 2.1 Secure Terraform Example

```hcl
# Secure Terraform Example
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Secure S3 Bucket
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "${var.environment}-secure-bucket"
  
  # Block public access
  acl = "private"
  
  # Enable versioning
  versioning {
    enabled = true
  }
  
  # Enable encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  # Block public access
  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  
  # Enable logging
  logging {
    target_bucket = var.log_bucket
    target_prefix = "s3-logs/"
  }
  
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Security    = "enforced"
  }
}
```

---

## BC.4: Container Security

### BC.4.1: Container Security Framework

**File:** `devsecops/container-security.md`

```markdown
# Container Security Framework

## 1. Overview

### 1.1 Container Security Purpose
To secure containerized applications throughout the lifecycle.

### 1.2 Container Security Controls

```yaml
# Container Security Controls
container_security:
  image_security:
    - "Use trusted base images"
    - "Scan images for vulnerabilities"
    - "Sign images"
    - "Maintain SBOM"
  
  runtime_security:
    - "Run as non-root"
    - "Read-only filesystem"
    - "Drop capabilities"
    - "Network policies"
  
  orchestration_security:
    - "RBAC"
    - "Network policies"
    - "Pod security policies"
    - "Secret management"
```

## 2. Kubernetes Security

### 2.1 Secure Kubernetes Configuration

```yaml
# Secure Kubernetes Configuration
apiVersion: v1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 65535
  fsGroup:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 65535
  requiredDropCapabilities:
    - ALL

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  # Encoded secrets
  database-password: <base64-encoded>
  api-key: <base64-encoded>
```

---

This concludes Appendix BC: Complete DevSecOps Reference. This comprehensive reference provides the DevSecOps framework, CI/CD security, infrastructure as code security, and container security needed to integrate security into development operations as part of the Enterprise Cybersecurity Program.
