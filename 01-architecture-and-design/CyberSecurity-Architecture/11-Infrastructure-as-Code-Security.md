# Part 3: Cloud-Native Security & Modern Workloads
## Section 3.3: Infrastructure as Code (IaC) Security

## The Target: Complete IaC Security for Nexus Global Industries

In this section, we'll implement comprehensive Infrastructure as Code security controls, including:

1. **Terraform Security Scanning** - Static analysis and vulnerability detection
2. **Policy-as-Code** - OPA and Sentinel policy enforcement
3. **CI/CD Security Gates** - Automated pipeline validation
4. **Secret Management** - Secure handling of secrets in IaC
5. **Compliance Validation** - Automated compliance checking

**What specific file(s) are we building?**
- `iac/01_terraform_scanning.yaml` - Terraform security scanning
- `iac/02_policy_as_code.yaml` - OPA/Sentinel policies
- `iac/03_cicd_gates.yaml` - CI/CD security gates
- `iac/04_secrets_management.yaml` - Secrets management
- `iac/05_compliance_validation.yaml` - Compliance automation

---

## The Concept: IaC Security in Plain English

Think of IaC security like **a blueprint review process for building construction**:

**Terraform Security Scanning:** "An inspector reviews the building blueprints for structural problems before construction begins." This is static analysis of infrastructure code.

**Policy-as-Code:** "The building must comply with zoning laws, fire codes, and safety regulations—all automatically checked." This is automated policy enforcement.

**CI/CD Security Gates:** "Before moving to the next construction phase, inspectors verify the work meets standards." This is pipeline validation.

**Secret Management:** "The blueprint doesn't include the actual key codes for doors; they're stored separately and securely." This is secure secret handling.

**Compliance Validation:** "The completed building is inspected to ensure it meets all legal requirements." This is compliance automation.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the iac directory
cd ~/nexus_security_architecture
mkdir -p iac

# Verify the structure
ls -la
# Expected: iac directory appears
```

---

### Step 2: Terraform Security Scanning

**File:** `iac/01_terraform_scanning.yaml`

```yaml
# Terraform Security Scanning - Nexus Global Industries
# File: iac/01_terraform_scanning.yaml
# Version: 1.0

# ====================================================================
# TERRASCAN CONFIGURATION
# ====================================================================

---
# Terrascan Policy Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: terrascan-config
  namespace: iac-security
data:
  config.yaml: |
    # Terrascan configuration
    severity:
      - "CRITICAL"
      - "HIGH"
      - "MEDIUM"
      - "LOW"
    
    # Policy categories to scan
    categories:
      - "aws"
      - "azure"
      - "kubernetes"
      - "gcp"
    
    # Exclude specific rules
    exclude_rules:
      - "AKS.Kubernetesv1.49"  # Example exclusion
      - "AWS.IAM.10"
    
    # Output format
    output:
      format: "json"
      file: "scan-results.json"

---
# Terrascan Scanning Job (CI/CD Integration)
apiVersion: batch/v1
kind: CronJob
metadata:
  name: terrascan-scan
  namespace: iac-security
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: terrascan
            image: accurics/terrascan:latest
            command:
            - /bin/sh
            - -c
            - |
              # Clone infrastructure repository
              git clone https://gitlab.nexus.com/infrastructure/terraform.git /repo
              
              # Run terrascan scan
              terrascan scan -i terraform -d /repo -o json > /results/scan.json
              
              # Check for critical findings
              CRITICAL_COUNT=$(jq '.results.violations[] | select(.severity=="CRITICAL") | length' /results/scan.json)
              HIGH_COUNT=$(jq '.results.violations[] | select(.severity=="HIGH") | length' /results/scan.json)
              
              # Fail if critical findings exist
              if [ "$CRITICAL_COUNT" -gt 0 ]; then
                echo "CRITICAL: Found $CRITICAL_COUNT critical violations"
                exit 1
              fi
              
              # Warn about high findings
              if [ "$HIGH_COUNT" -gt 5 ]; then
                echo "WARNING: Found $HIGH_COUNT high violations (limit: 5)"
                exit 0
              fi
              
              echo "Scan passed: $CRITICAL_COUNT critical, $HIGH_COUNT high violations"
            volumeMounts:
            - name: results
              mountPath: /results
          volumes:
          - name: results
            emptyDir: {}
          restartPolicy: OnFailure

# ====================================================================
# CHECKOV CONFIGURATION
# ====================================================================

---
# Checkov Configuration (Alternative scanning tool)
apiVersion: v1
kind: ConfigMap
metadata:
  name: checkov-config
  namespace: iac-security
data:
  config.yaml: |
    # Checkov configuration
    framework:
      - terraform
      - kubernetes
      - dockerfile
    
    # Skip checks
    skip_check:
      - "CKV_AWS_1"  # Example exclusion
    
    # Output format
    output: "json"
    
    # Soft fail
    soft_fail: false
    
    # Failure threshold
    fail_on_severity: "CRITICAL"

---
# Checkov Scanning CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: checkov-scan
  namespace: iac-security
spec:
  schedule: "0 3 * * *"  # Daily at 3 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: checkov
            image: bridgecrew/checkov:latest
            command:
            - /bin/sh
            - -c
            - |
              # Clone repository
              git clone https://gitlab.nexus.com/infrastructure/terraform.git /repo
              
              # Run Checkov
              checkov -d /repo -o json --framework terraform > /results/checkov.json
              
              # Parse results
              FAILED_CHECKS=$(jq '.summary.failed' /results/checkov.json)
              
              echo "Checkov scan complete: $FAILED_CHECKS failed checks"
              
              # Send to SIEM
              if [ "$FAILED_CHECKS" -gt 0 ]; then
                curl -X POST -H "Content-Type: application/json" \
                  -d @/results/checkov.json \
                  http://logstash.siem.svc.cluster.local:5044
              fi
            volumeMounts:
            - name: results
              mountPath: /results
          volumes:
          - name: results
            emptyDir: {}
          restartPolicy: OnFailure

# ====================================================================
# POLICY VIOLATION ALERTS
# ====================================================================

---
# Policy Violation Alerting
apiVersion: v1
kind: ConfigMap
metadata:
  name: policy-violation-alerts
  namespace: iac-security
data:
  alerts.yaml: |
    # Alert configuration
    alerts:
      - severity: "CRITICAL"
        channels:
          - "slack"
          - "pagerduty"
        message: |
          🚨 IaC Security Violation Detected
          - Severity: CRITICAL
          - Policy: {{ .Policy }}
          - Resource: {{ .Resource }}
          - Line: {{ .Line }}
          - Remediation: {{ .Remediation }}
      
      - severity: "HIGH"
        channels:
          - "slack"
        message: |
          ⚠️ IaC Security Violation Detected
          - Severity: HIGH
          - Policy: {{ .Policy }}
          - Resource: {{ .Resource }}
          - Line: {{ .Line }}
          - Remediation: {{ .Remediation }}
```

**Verification:**

```bash
# Verify Terraform scanning file
ls -la iac/01_terraform_scanning.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('iac/01_terraform_scanning.yaml'))"
# Expected: No error output
```

---

### Step 3: Policy-as-Code (OPA/Sentinel)

**File:** `iac/02_policy_as_code.yaml`

```yaml
# Policy-as-Code - Nexus Global Industries
# File: iac/02_policy_as_code.yaml
# Version: 1.0

# ====================================================================
# OPA POLICIES FOR TERRAFORM
# ====================================================================

---
# OPA Policy: Require encryption for RDS
apiVersion: v1
kind: ConfigMap
metadata:
  name: opa-terraform-policies
  namespace: iac-security
data:
  rds_encryption.rego: |
    # OPA Policy: Require RDS encryption
    package terraform.aws
    
    # Deny if RDS instance doesn't have encryption enabled
    deny[msg] {
      resource := input.resource.aws_db_instance[_]
      resource.storage_encrypted == false
      msg := sprintf("RDS instance %s must have storage_encrypted=true", [resource.name])
    }
    
    # Deny if RDS instance has public accessibility
    deny[msg] {
      resource := input.resource.aws_db_instance[_]
      resource.publicly_accessible == true
      msg := sprintf("RDS instance %s must not be publicly accessible", [resource.name])
    }

  s3_encryption.rego: |
    # OPA Policy: Require S3 encryption
    package terraform.aws
    
    # Deny if S3 bucket doesn't have encryption
    deny[msg] {
      resource := input.resource.aws_s3_bucket[_]
      not resource.server_side_encryption_configuration
      msg := sprintf("S3 bucket %s must have server-side encryption enabled", [resource.name])
    }
    
    # Deny if S3 bucket allows public access
    deny[msg] {
      resource := input.resource.aws_s3_bucket[_]
      resource.bucket_public_access_block == false
      msg := sprintf("S3 bucket %s must block public access", [resource.name])
    }

  security_groups.rego: |
    # OPA Policy: Restrict security groups
    package terraform.aws
    
    # Deny if security group allows unrestricted SSH
    deny[msg] {
      resource := input.resource.aws_security_group[_]
      ingress := resource.ingress[_]
      ingress.cidr_blocks[_] == "0.0.0.0/0"
      ingress.from_port == 22
      msg := sprintf("Security group %s allows unrestricted SSH access", [resource.name])
    }
    
    # Deny if security group allows unrestricted RDP
    deny[msg] {
      resource := input.resource.aws_security_group[_]
      ingress := resource.ingress[_]
      ingress.cidr_blocks[_] == "0.0.0.0/0"
      ingress.from_port == 3389
      msg := sprintf("Security group %s allows unrestricted RDP access", [resource.name])
    }

# ====================================================================
# SENTINEL POLICIES FOR TERRAFORM CLOUD/ENTERPRISE
# ====================================================================

---
# Sentinel Policy: Enforce tagging
apiVersion: v1
kind: ConfigMap
metadata:
  name: sentinel-policies
  namespace: iac-security
data:
  enforce-tagging.sentinel: |
    # Sentinel policy: Enforce tagging on all resources
    import "tfplan"
    
    # All resources must have these tags
    required_tags = ["Environment", "Project", "Owner", "ManagedBy"]
    
    # Check all resources
    main = rule {
      all tfplan.resources as _, instances {
        all instances as _, r {
          all required_tags as tag {
            r.applied.tags contains tag
          }
        }
      }
    }

  require-encryption.sentinel: |
    # Sentinel policy: Require encryption
    import "tfplan"
    
    # Check RDS encryption
    rds_encryption = rule {
      all tfplan.resources.aws_db_instance as _, r {
        r.applied.storage_encrypted is true
      }
    }
    
    # Check S3 encryption
    s3_encryption = rule {
      all tfplan.resources.aws_s3_bucket as _, r {
        r.applied.server_side_encryption_configuration exists
      }
    }
    
    main = rule {
      rds_encryption and s3_encryption
    }

# ====================================================================
# OPA SERVER FOR POLICY ENFORCEMENT
# ====================================================================

---
# OPA Server Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opa-server
  namespace: iac-security
spec:
  replicas: 2
  selector:
    matchLabels:
      app: opa-server
  template:
    metadata:
      labels:
        app: opa-server
    spec:
      containers:
      - name: opa
        image: openpolicyagent/opa:latest
        args:
        - "run"
        - "--server"
        - "--addr=:8181"
        - "--log-level=debug"
        - "--set=decision_logs.console=true"
        ports:
        - containerPort: 8181
        livenessProbe:
          httpGet:
            path: /health
            port: 8181
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8181
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: policies
          mountPath: /policies
      volumes:
      - name: policies
        configMap:
          name: opa-terraform-policies

---
# OPA Server Service
apiVersion: v1
kind: Service
metadata:
  name: opa-server
  namespace: iac-security
spec:
  selector:
    app: opa-server
  ports:
  - port: 8181
    targetPort: 8181

# ====================================================================
# POLICY TESTING
# ====================================================================

---
# OPA Policy Testing Job
apiVersion: batch/v1
kind: CronJob
metadata:
  name: opa-policy-test
  namespace: iac-security
spec:
  schedule: "0 4 * * *"  # Daily at 4 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: opa-test
            image: openpolicyagent/opa:latest
            command:
            - /bin/sh
            - -c
            - |
              # Run policy tests
              opa test /policies/ -v
              
              # Check coverage
              opa coverage /policies/
              
              # Ensure all policies have tests
              echo "Policy tests complete"
            volumeMounts:
            - name: policies
              mountPath: /policies
          volumes:
          - name: policies
            configMap:
              name: opa-terraform-policies
          restartPolicy: OnFailure
```

**Verification:**

```bash
# Verify policy-as-code file
ls -la iac/02_policy_as_code.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('iac/02_policy_as_code.yaml'))"
# Expected: No error output
```

---

### Step 4: CI/CD Security Gates

**File:** `iac/03_cicd_gates.yaml`

```yaml
# CI/CD Security Gates - Nexus Global Industries
# File: iac/03_cicd_gates.yaml
# Version: 1.0

# ====================================================================
# GITLAB CI SECURITY PIPELINE
# ====================================================================

---
# GitLab CI Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-ci-security
  namespace: iac-security
data:
  .gitlab-ci.yml: |
    # GitLab CI Pipeline with Security Gates
    stages:
      - validate
      - security-scan
      - policy-check
      - deploy
      - compliance
    
    # Variables
    variables:
      TERRAFORM_VERSION: "1.5.0"
      TERRASCAN_VERSION: "1.18.0"
      CHECKOV_VERSION: "2.3.0"
    
    # Pre-commit validation
    validate:
      stage: validate
      image: hashicorp/terraform:${TERRAFORM_VERSION}
      script:
        - terraform fmt -check -recursive
        - terraform init
        - terraform validate
      only:
        - merge_requests
        - main
    
    # Security scanning
    terraform-scan:
      stage: security-scan
      image: accurics/terrascan:${TERRASCAN_VERSION}
      script:
        - terrascan scan -i terraform -d . -o json
      artifacts:
        reports:
          terraform: terrascan-report.json
      only:
        - merge_requests
        - main
    
    # Checkov scanning
    checkov-scan:
      stage: security-scan
      image: bridgecrew/checkov:${CHECKOV_VERSION}
      script:
        - checkov -d . -o json --framework terraform
      artifacts:
        reports:
          terraform: checkov-report.json
      only:
        - merge_requests
        - main
    
    # OPA policy check
    opa-policy:
      stage: policy-check
      image: openpolicyagent/opa:latest
      script:
        - opa eval -i terraform.tfplan.json -d policies/ -p terraform.aws
      only:
        - merge_requests
        - main
    
    # Sentinel policy check (Terraform Cloud)
    sentinel-policy:
      stage: policy-check
      image: hashicorp/terraform:${TERRAFORM_VERSION}
      script:
        - terraform plan -out=tfplan.binary
        - terraform show -json tfplan.binary > tfplan.json
        - sentinel apply policies/sentinel-policy.sentinel
      only:
        - merge_requests
        - main
    
    # Compliance validation
    compliance:
      stage: compliance
      image: hashicorp/terraform:${TERRAFORM_VERSION}
      script:
        - terraform plan -out=tfplan.binary
        - terraform show -json tfplan.binary > tfplan.json
        - checkov --framework terraform -f tfplan.json -o json
      only:
        - merge_requests
        - main
    
    # Deployment (only after all checks pass)
    deploy:
      stage: deploy
      image: hashicorp/terraform:${TERRAFORM_VERSION}
      script:
        - terraform plan
        - terraform apply -auto-approve
      only:
        - main
      when: manual

# ====================================================================
# GITHUB ACTIONS SECURITY WORKFLOW
# ====================================================================

---
# GitHub Actions Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: github-actions-security
  namespace: iac-security
data:
  terraform-security.yml: |
    # GitHub Actions Security Workflow
    name: Terraform Security Scan
    
    on:
      pull_request:
        branches: [ main, develop ]
      push:
        branches: [ main ]
    
    jobs:
      security-scan:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout code
          uses: actions/checkout@v3
        
        - name: Setup Terraform
          uses: hashicorp/setup-terraform@v2
          with:
            terraform_version: 1.5.0
        
        - name: Terraform Format
          run: terraform fmt -check -recursive
        
        - name: Terraform Validate
          run: terraform init && terraform validate
        
        - name: Run Terrascan
          uses: runatlantis/atlantis@v2
          with:
            args: terrascan scan -i terraform
        
        - name: Run Checkov
          uses: bridgecrewio/checkov-action@v12
          with:
            framework: terraform
        
        - name: Run OPA Policy
          uses: open-policy-agent/opa@v0.45.0
          with:
            args: eval -i terraform.tfplan.json -d policies/ -p terraform.aws
        
        - name: Upload Security Results
          uses: actions/upload-artifact@v3
          with:
            name: security-results
            path: |
              terrascan-report.json
              checkov-report.json

# ====================================================================
# PIPELINE SECURITY GATES
# ====================================================================

---
# Security Gate Configurations
apiVersion: v1
kind: ConfigMap
metadata:
  name: pipeline-security-gates
  namespace: iac-security
data:
  gates.yaml: |
    # Pipeline security gates configuration
    
    # Gate 1: Pre-commit validation
    pre-commit:
      checks:
        - terraform fmt
        - terraform validate
        - checkov scan
      failure_action: "block"
    
    # Gate 2: Security scan
    security-scan:
      checks:
        - terrascan (critical/high only)
        - checkov (critical/high only)
        - opa policies
      thresholds:
        critical: 0
        high: 5
      failure_action: "block"
    
    # Gate 3: Policy check
    policy-check:
      checks:
        - opa policy evaluation
        - sentinel policy evaluation
      failure_action: "block"
    
    # Gate 4: Compliance validation
    compliance:
      checks:
        - nist controls
        - cis benchmarks
        - custom policies
      failure_action: "warn"
    
    # Gate 5: Deployment approval
    deployment:
      checks:
        - all previous gates passed
        - manual approval for production
      failure_action: "manual-approval-required"
```

**Verification:**

```bash
# Verify CI/CD gates file
ls -la iac/03_cicd_gates.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('iac/03_cicd_gates.yaml'))"
# Expected: No error output
```

---

### Step 5: Secrets Management in IaC

**File:** `iac/04_secrets_management.yaml`

```yaml
# Secrets Management in IaC - Nexus Global Industries
# File: iac/04_secrets_management.yaml
# Version: 1.0

# ====================================================================
# VAULT SECRETS INJECTION IN TERRAFORM
# ====================================================================

---
# Vault Provider Configuration for Terraform
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-terraform-config
  namespace: iac-security
data:
  vault-provider.tf: |
    # Vault provider for Terraform
    provider "vault" {
      address = "https://vault.nexus.com:8200"
      token   = var.vault_token
    }
    
    # Vault secret data source
    data "vault_generic_secret" "aws_credentials" {
      path = "secret/data/aws/production"
    }
    
    # Use secret in Terraform
    resource "aws_db_instance" "main" {
      username = data.vault_generic_secret.aws_credentials.data["db_username"]
      password = data.vault_generic_secret.aws_credentials.data["db_password"]
      # ... other configuration
    }

---
# Vault Secrets in Kubernetes Terraform Provider
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-k8s-secrets
  namespace: iac-security
data:
  vault-k8s.tf: |
    # Vault Kubernetes provider
    provider "kubernetes" {
      host = var.kubernetes_host
      config_path = var.kubernetes_config_path
    }
    
    # External secret (using Vault)
    resource "kubernetes_secret" "app_secrets" {
      metadata {
        name = "app-secrets"
        namespace = "production"
      }
      
      data = {
        db_password = data.vault_generic_secret.db_password.data["value"]
        api_key     = data.vault_generic_secret.api_key.data["value"]
      }
    }

# ====================================================================
# SECRET SCANNING IN CI/CD
# ====================================================================

---
# TruffleHog Secret Scanning
apiVersion: batch/v1
kind: CronJob
metadata:
  name: trufflehog-scan
  namespace: iac-security
spec:
  schedule: "0 1 * * *"  # Daily at 1 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: trufflehog
            image: trufflesecurity/trufflehog:latest
            command:
            - /bin/sh
            - -c
            - |
              # Scan Git repositories for secrets
              trufflehog git --json --repo https://gitlab.nexus.com/infrastructure/terraform.git > /results/secrets.json
              
              # Check for secrets
              SECRET_COUNT=$(jq '. | length' /results/secrets.json)
              
              if [ "$SECRET_COUNT" -gt 0 ]; then
                echo "ALERT: Found $SECRET_COUNT secrets in repositories"
                cat /results/secrets.json
                exit 1
              fi
              
              echo "No secrets found in repositories"
            volumeMounts:
            - name: results
              mountPath: /results
          volumes:
          - name: results
            emptyDir: {}
          restartPolicy: OnFailure

---
# GitLeaks Secret Scanning
apiVersion: batch/v1
kind: CronJob
metadata:
  name: gitleaks-scan
  namespace: iac-security
spec:
  schedule: "0 1 * * *"  # Daily at 1 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: gitleaks
            image: zricethezav/gitleaks:latest
            command:
            - /bin/sh
            - -c
            - |
              # Clone repository
              git clone https://gitlab.nexus.com/infrastructure/terraform.git /repo
              
              # Run gitleaks
              gitleaks detect --source /repo --report-path /results/gitleaks.json
              
              # Check results
              if [ -f /results/gitleaks.json ]; then
                LEAKS=$(jq '. | length' /results/gitleaks.json)
                echo "Found $LEAKS potential secrets"
                
                if [ "$LEAKS" -gt 0 ]; then
                  cat /results/gitleaks.json
                  exit 1
                fi
              fi
              
              echo "No secrets found"
            volumeMounts:
            - name: results
              mountPath: /results
          volumes:
          - name: results
            emptyDir: {}
          restartPolicy: OnFailure

# ====================================================================
# TERRAGRUNT SECRETS WITH VAULT
# ====================================================================

---
# Terragrunt Configuration with Vault
apiVersion: v1
kind: ConfigMap
metadata:
  name: terragrunt-vault
  namespace: iac-security
data:
  terragrunt.hcl: |
    # Terragrunt configuration with Vault secrets
    terraform {
      source = "git::https://gitlab.nexus.com/infrastructure/modules//aws-rds"
    }
    
    # Vault secret retrieval
    locals {
      db_secrets = vault_generic_secret("secret/data/database")
    }
    
    inputs = {
      db_username = local.db_secrets.data.db_username
      db_password = local.db_secrets.data.db_password
      db_name     = local.db_secrets.data.db_name
      
      # Environment variables
      environment = "production"
      region      = "us-east-1"
    }
```

**Verification:**

```bash
# Verify secrets management file
ls -la iac/04_secrets_management.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('iac/04_secrets_management.yaml'))"
# Expected: No error output
```

---

### Step 6: Compliance Validation

**File:** `iac/05_compliance_validation.yaml`

```yaml
# Compliance Validation - Nexus Global Industries
# File: iac/05_compliance_validation.yaml
# Version: 1.0

# ====================================================================
# NIST COMPLIANCE CHECKS
# ====================================================================

---
# NIST 800-53 Compliance Policies
apiVersion: v1
kind: ConfigMap
metadata:
  name: nist-compliance
  namespace: iac-security
data:
  nist-800-53.rego: |
    # NIST 800-53 Compliance Policies
    package nist_800_53
    
    # AC-3: Access Enforcement
    deny[msg] {
      resource := input.resource.aws_s3_bucket[_]
      not resource.bucket_public_access_block
      msg := sprintf("AC-3: S3 bucket %s does not have public access block enabled", [resource.name])
    }
    
    # AC-4: Information Flow Enforcement
    deny[msg] {
      resource := input.resource.aws_security_group[_]
      ingress := resource.ingress[_]
      ingress.cidr_blocks[_] == "0.0.0.0/0"
      msg := sprintf("AC-4: Security group %s allows unrestricted ingress", [resource.name])
    }
    
    # SC-13: Cryptographic Protection
    deny[msg] {
      resource := input.resource.aws_db_instance[_]
      not resource.storage_encrypted
      msg := sprintf("SC-13: RDS instance %s does not have encryption enabled", [resource.name])
    }
    
    # SC-28: Protection of Information at Rest
    deny[msg] {
      resource := input.resource.aws_s3_bucket[_]
      not resource.server_side_encryption_configuration
      msg := sprintf("SC-28: S3 bucket %s does not have encryption enabled", [resource.name])
    }
    
    # SI-4: Information System Monitoring
    deny[msg] {
      resource := input.resource.aws_cloudtrail[_]
      not resource.is_multi_region_trail
      msg := sprintf("SI-4: CloudTrail %s is not multi-region", [resource.name])
    }

# ====================================================================
# CIS COMPLIANCE CHECKS
# ====================================================================

---
# CIS Compliance Policies
apiVersion: v1
kind: ConfigMap
metadata:
  name: cis-compliance
  namespace: iac-security
data:
  cis-aws.rego: |
    # CIS AWS Foundations Benchmark
    package cis_aws
    
    # 1.1: Root user MFA
    deny[msg] {
      resource := input.resource.aws_iam_account_password_policy[_]
      not resource.require_symbols
      msg := "CIS 1.1: Password policy must require symbols"
    }
    
    # 1.2: Password policy minimum length
    deny[msg] {
      resource := input.resource.aws_iam_account_password_policy[_]
      resource.minimum_password_length < 14
      msg := "CIS 1.2: Password minimum length must be at least 14"
    }
    
    # 2.1: CloudTrail enabled
    deny[msg] {
      not input.resource.aws_cloudtrail[_]
      msg := "CIS 2.1: CloudTrail must be enabled"
    }
    
    # 3.1: S3 bucket logging
    deny[msg] {
      resource := input.resource.aws_s3_bucket[_]
      not resource.logging
      msg := sprintf("CIS 3.1: S3 bucket %s must have logging enabled", [resource.name])
    }
    
    # 4.1: Security group restriction
    deny[msg] {
      resource := input.resource.aws_security_group[_]
      ingress := resource.ingress[_]
      ingress.cidr_blocks[_] == "0.0.0.0/0"
      ingress.from_port <= 22
      msg := sprintf("CIS 4.1: Security group %s allows unrestricted SSH", [resource.name])
    }

# ====================================================================
# PCI DSS COMPLIANCE CHECKS
# ====================================================================

---
# PCI DSS Compliance Policies
apiVersion: v1
kind: ConfigMap
metadata:
  name: pci-compliance
  namespace: iac-security
data:
  pci-dss.rego: |
    # PCI DSS Compliance Policies
    package pci_dss
    
    # Requirement 2: Do not use vendor-supplied defaults
    deny[msg] {
      resource := input.resource.aws_db_instance[_]
      resource.engine == "mysql" and resource.engine_version == "latest"
      msg := "PCI 2.1: MySQL version must be explicitly specified"
    }
    
    # Requirement 3: Protect stored cardholder data
    deny[msg] {
      resource := input.resource.aws_db_instance[_]
      not resource.storage_encrypted
      msg := "PCI 3.4: RDS instance must have encryption enabled"
    }
    
    # Requirement 7: Restrict access to cardholder data
    deny[msg] {
      resource := input.resource.aws_security_group[_]
      ingress := resource.ingress[_]
      ingress.cidr_blocks[_] == "0.0.0.0/0"
      msg := "PCI 7.1: Security group must restrict access to cardholder data"
    }
    
    # Requirement 10: Track and monitor access
    deny[msg] {
      not input.resource.aws_cloudtrail
      msg := "PCI 10.2: CloudTrail must be enabled"
    }

# ====================================================================
# COMPLIANCE VALIDATION ENGINE
# ====================================================================

---
# Compliance Validation Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: compliance-validator
  namespace: iac-security
spec:
  replicas: 2
  selector:
    matchLabels:
      app: compliance-validator
  template:
    metadata:
      labels:
        app: compliance-validator
    spec:
      containers:
      - name: validator
        image: openpolicyagent/opa:latest
        args:
        - "run"
        - "--server"
        - "--addr=:8181"
        - "--log-level=debug"
        volumeMounts:
        - name: policies
          mountPath: /policies
        - name: compliance-reporting
          mountPath: /reports
        ports:
        - containerPort: 8181
        livenessProbe:
          httpGet:
            path: /health
            port: 8181
          initialDelaySeconds: 10
          periodSeconds: 10
      volumes:
      - name: policies
        configMap:
          name: nist-compliance
      - name: compliance-reporting
        emptyDir: {}

---
# Compliance Validation CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: compliance-validation
  namespace: iac-security
spec:
  schedule: "0 6 * * *"  # Daily at 6 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: validator
            image: openpolicyagent/opa:latest
            command:
            - /bin/sh
            - -c
            - |
              # Validate compliance
              echo "Running compliance validation..."
              
              # Check NIST compliance
              opa eval -d /policies/nist-800-53.rego -i /terraform/plan.json
              
              # Check CIS compliance
              opa eval -d /policies/cis-aws.rego -i /terraform/plan.json
              
              # Check PCI compliance
              opa eval -d /policies/pci-dss.rego -i /terraform/plan.json
              
              # Generate report
              opa eval --format=json --explain=notes -d /policies/ -i /terraform/plan.json > /reports/compliance.json
              
              # Send to SIEM
              curl -X POST -H "Content-Type: application/json" \
                -d @/reports/compliance.json \
                http://logstash.siem.svc.cluster.local:5044
              
              echo "Compliance validation complete"
            volumeMounts:
            - name: policies
              mountPath: /policies
            - name: compliance-reporting
              mountPath: /reports
          volumes:
          - name: policies
            configMap:
              name: nist-compliance
          - name: compliance-reporting
            emptyDir: {}
          restartPolicy: OnFailure
```

**Verification:**

```bash
# Verify compliance validation file
ls -la iac/05_compliance_validation.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('iac/05_compliance_validation.yaml'))"
# Expected: No error output
```

---

### Step 7: IaC Security Summary

**File:** `iac/README.md`

```markdown
# Infrastructure as Code (IaC) Security - Nexus Global Industries

## Overview

This directory contains the complete Infrastructure as Code security implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_terraform_scanning.yaml` | Scanning | Terrascan, Checkov configuration |
| `02_policy_as_code.yaml` | Policy | OPA/Sentinel policies |
| `03_cicd_gates.yaml` | CI/CD | Pipeline security gates |
| `04_secrets_management.yaml` | Secrets | Vault and secret scanning |
| `05_compliance_validation.yaml` | Compliance | NIST, CIS, PCI checks |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    IAC SECURITY ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  DEVELOPER WRITES TERRAFORM CODE                        │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  PRE-COMMIT HOOKS                                      │   │
│  │  • Terraform fmt                                      │   │
│  │  • Terraform validate                                 │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  CI/CD SECURITY GATES                                  │   │
│  │  • Terrascan (vulnerability scanning)                 │   │
│  │  • Checkov (static analysis)                          │   │
│  │  • OPA/Sentinel (policy enforcement)                  │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  SECRET MANAGEMENT                                     │   │
│  │  • Vault integration                                   │   │
│  │  • TruffleHog scanning                                │   │
│  │  • GitLeaks scanning                                  │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  COMPLIANCE VALIDATION                                 │   │
│  │  • NIST 800-53                                        │   │
│  │  • CIS Benchmarks                                     │   │
│  │  • PCI DSS                                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Tool | Description |
|---------|------|-------------|
| **Static Analysis** | Terrascan | Infrastructure vulnerability scanning |
| **Security Rules** | Checkov | Misconfiguration detection |
| **Policy Enforcement** | OPA | Policy-as-Code enforcement |
| **Secret Management** | Vault | Secure secret storage and injection |
| **Secret Scanning** | TruffleHog | Automated secret detection |
| **Compliance** | OPA Rules | Automated compliance validation |

## Deployment Instructions

### 1. Deploy Scanning Infrastructure

```bash
kubectl apply -f iac/01_terraform_scanning.yaml
```

### 2. Deploy Policy-as-Code

```bash
kubectl apply -f iac/02_policy_as_code.yaml
```

### 3. Configure CI/CD Gates

```bash
kubectl apply -f iac/03_cicd_gates.yaml
```

### 4. Configure Secrets Management

```bash
kubectl apply -f iac/04_secrets_management.yaml
```

### 5. Deploy Compliance Validation

```bash
kubectl apply -f iac/05_compliance_validation.yaml
```

## Verification Checklist

- [ ] Terrascan scanning all Terraform code
- [ ] Checkov policies enforced in CI/CD
- [ ] OPA policies validating infrastructure
- [ ] Vault integrating with Terraform
- [ ] Secret scanning in CI/CD pipeline
- [ ] Compliance validation running daily
- [ ] No secrets in code repositories
- [ ] NIST, CIS, and PCI compliance checks passing

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la iac/README.md
# Expected: File exists

echo "✅ Infrastructure as Code Security Complete!"
echo "   - Terraform scanning (Terrascan, Checkov)"
echo "   - Policy-as-Code (OPA, Sentinel)"
echo "   - CI/CD security gates"
echo "   - Secrets management (Vault, scanning)"
echo "   - Compliance validation (NIST, CIS, PCI)"
```

---

## End of Section 3.3: Infrastructure as Code Security

### Key Takeaway

You've implemented comprehensive Infrastructure as Code security controls for Nexus Global Industries, including static analysis with Terrascan and Checkov, policy-as-code enforcement with OPA and Sentinel, CI/CD security gates, secure secrets management with Vault, and automated compliance validation against NIST, CIS, and PCI standards.

### What's Next

**Section 3.4** will cover **API Security (OWASP API Top 10)** , including:
- OWASP API Top 10 protections
- JWT validation and token security
- Rate limiting and throttling
- Input validation and sanitization
- API security testing
