# Appendix AC: Complete Security Engineering Reference

## Overview

This appendix provides comprehensive security engineering reference material for the Enterprise Cybersecurity Program. It includes secure development practices, security testing, code review standards, and DevOps security integration.

---

## AC.1: Secure Development Lifecycle (SDLC)

### AC.1.1: Secure SDLC Framework

**File:** `security-engineering/secure-sdlc.md`

```markdown
# Secure Software Development Lifecycle (SDLC)

## 1. Overview

### 1.1 Framework Purpose
To integrate security into every phase of the software development lifecycle.

### 1.2 SDLC Phases

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SECURE SDLC FRAMEWORK                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              REQUIREMENTS                                          │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Security requirements                                                       │ │    │
│  │  │  • Privacy requirements                                                         │ │    │
│  │  │  • Compliance requirements                                                      │ │    │
│  │  │  • Threat modeling                                                              │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              DESIGN                                               │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Security architecture                                                       │ │    │
│  │  │  • Design review                                                                │ │    │
│  │  │  • Security patterns                                                            │ │    │
│  │  │  • Attack surface analysis                                                      │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              IMPLEMENTATION                                       │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Secure coding practices                                                     │ │    │
│  │  │  • Code review                                                                  │ │    │
│  │  │  • Static analysis                                                              │ │    │
│  │  │  • Dependency scanning                                                          │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              TESTING                                              │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Security testing                                                            │ │    │
│  │  │  • Penetration testing                                                          │ │    │
│  │  │  • Vulnerability scanning                                                       │ │    │
│  │  │  • Fuzzing                                                                      │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              DEPLOYMENT                                            │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Secure deployment                                                           │ │    │
│  │  │  • Configuration hardening                                                      │ │    │
│  │  │  • Security validation                                                          │ │    │
│  │  │  • Monitoring setup                                                             │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              MAINTENANCE                                           │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Vulnerability management                                                    │ │    │
│  │  │  • Patch management                                                             │ │    │
│  │  │  • Incident response                                                            │ │    │
│  │  │  • Continuous improvement                                                       │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

## 2. Security Requirements

### 2.1 Requirements Categories

```yaml
# Security Requirements Categories
security_requirements:
  authentication:
    - "All users must authenticate"
    - "MFA required for privileged access"
    - "Password policies enforced"
    - "Session management implemented"
  
  authorization:
    - "Role-based access control"
    - "Least privilege enforced"
    - "Access reviews conducted"
    - "Permission validation"
  
  data_protection:
    - "Encryption at rest"
    - "Encryption in transit"
    - "Data classification"
    - "Secure data handling"
  
  logging:
    - "Audit logging"
    - "Security event logging"
    - "Log retention"
    - "Log protection"
  
  compliance:
    - "GDPR compliance"
    - "CCPA compliance"
    - "HIPAA compliance"
    - "PCI DSS compliance"
```

### 2.2 Threat Modeling

```yaml
# Threat Modeling Template
threat_model:
  application: "[Application Name]"
  version: "1.0"
  date: "2024-03-15"
  
  assets:
    - asset: "Customer Data"
      sensitivity: "High"
      protection: "Encryption, Access Control"
    
    - asset: "API Keys"
      sensitivity: "Critical"
      protection: "Secrets Management"
  
  threats:
    - id: "T-001"
      description: "Unauthorized data access"
      source: "External attacker"
      target: "Customer Database"
      severity: "Critical"
      mitigation: "Access control, encryption"
    
    - id: "T-002"
      description: "SQL Injection"
      source: "External attacker"
      target: "Web Application"
      severity: "High"
      mitigation: "Input validation, prepared statements"
  
  security_controls:
    - control: "Input Validation"
      type: "Preventive"
      effectiveness: "High"
    
    - control: "Encryption"
      type: "Preventive"
      effectiveness: "High"
    
    - control: "Logging"
      type: "Detective"
      effectiveness: "Medium"
```

## 3. Secure Coding Practices

### 3.1 Secure Coding Standards

```yaml
# Secure Coding Standards
secure_coding:
  input_validation:
    rules:
      - "Validate all user input"
      - "Use whitelist approach"
      - "Sanitize input"
      - "Parameterize queries"
  
  authentication:
    rules:
      - "Use strong passwords"
      - "Implement MFA"
      - "Secure session management"
      - "Implement account lockout"
  
  data_handling:
    rules:
      - "Encrypt sensitive data"
      - "Use secure protocols"
      - "Implement secure logging"
      - "Secure data disposal"
  
  error_handling:
    rules:
      - "Don't reveal internal details"
      - "Log errors securely"
      - "Implement proper error handling"
      - "Use secure error responses"
  
  configuration:
    rules:
      - "Secure default configurations"
      - "Disable unnecessary features"
      - "Implement least privilege"
      - "Use secure communication"
```

### 3.2 Secure Code Examples

```python
# Secure Code Examples

# Input Validation
def validate_user_input(input_data):
    """Validate and sanitize user input"""
    # Use whitelist approach
    allowed_chars = set('abcdefghijklmnopqrstuvwxyz0123456789_-')
    
    if not all(c in allowed_chars for c in input_data):
        raise ValueError("Invalid characters in input")
    
    # Sanitize input
    sanitized = input_data.strip()
    sanitized = sanitized.replace("'", "")
    sanitized = sanitized.replace("\"", "")
    sanitized = sanitized.replace(";", "")
    
    return sanitized

# Parameterized Query
def get_user_by_id(user_id):
    """Get user by ID using parameterized query"""
    import sqlite3
    
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    
    # Use parameterized query to prevent SQL injection
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    
    conn.close()
    return user

# Secure Password Handling
import bcrypt

def hash_password(password):
    """Hash password securely"""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed

def verify_password(password, hashed):
    """Verify password"""
    return bcrypt.checkpw(password.encode('utf-8'), hashed)

# Secure File Upload
def secure_file_upload(file):
    """Validate file upload"""
    # Check file type
    ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf']
    if file.content_type not in ALLOWED_TYPES:
        raise ValueError("File type not allowed")
    
    # Check file size (max 5MB)
    MAX_SIZE = 5 * 1024 * 1024
    if file.size > MAX_SIZE:
        raise ValueError("File too large")
    
    # Sanitize filename
    import re
    filename = re.sub(r'[^a-zA-Z0-9_.-]', '_', file.filename)
    
    # Store securely
    # ... implementation
    return filename
```

---

## AC.2: Security Testing

### AC.2.1: Security Testing Framework

**File:** `security-engineering/security-testing.md`

```markdown
# Security Testing Framework

## 1. Testing Types

### 1.1 Static Analysis (SAST)

```yaml
# SAST Configuration
sast:
  tools:
    - "SonarQube"
    - "Checkmarx"
    - "ESLint with security rules"
  
  frequency: "Every commit"
  
  rules:
    - "SQL Injection patterns"
    - "XSS vulnerabilities"
    - "Insecure cryptographic algorithms"
    - "Hardcoded credentials"
    - "Insecure deserialization"
  
  reporting:
    format: "JSON"
    threshold: "High"
    automated_remediation: true
```

### 1.2 Dynamic Analysis (DAST)

```yaml
# DAST Configuration
dast:
  tools:
    - "OWASP ZAP"
    - "Burp Suite"
    - "Nessus Web Application Scanner"
  
  frequency: "Weekly"
  
  scans:
    - "Crawl application"
    - "Automated scanning"
    - "Authentication testing"
    - "API testing"
  
  reporting:
    format: "HTML"
    threshold: "High"
    automated_remediation: false
```

### 1.3 Software Composition Analysis (SCA)

```yaml
# SCA Configuration
sca:
  tools:
    - "Snyk"
    - "Dependabot"
    - "Sonatype Nexus Lifecycle"
  
  frequency: "Every commit"
  
  scanning:
    - "Dependency scanning"
    - "License compliance"
    - "Vulnerability identification"
    - "SBOM generation"
  
  reporting:
    format: "JSON"
    threshold: "Medium"
    automated_remediation: true
```

## 2. Testing Execution

### 2.1 Test Automation

```yaml
# Test Automation Framework
test_automation:
  pipeline_integration: true
  triggering_events:
    - "Pull Request"
    - "Merge to Main"
    - "Weekly Schedule"
  
  tools:
    sast: "SonarQube"
    dast: "OWASP ZAP"
    sca: "Snyk"
  
  workflows:
    - name: "PR Security Scan"
      events:
        - "pull_request"
      steps:
        - "SAST scan"
        - "SCA scan"
        - "Report generation"
    
    - name: "Full Security Scan"
      events:
        - "schedule:weekly"
      steps:
        - "SAST scan"
        - "DAST scan"
        - "SCA scan"
        - "Penetration testing"
        - "Report generation"
```

### 2.2 Vulnerability Management

```yaml
# Vulnerability Management
vulnerability_management:
  severity_levels:
    critical:
      sla: "24 hours"
      escalation: "CISO"
    
    high:
      sla: "72 hours"
      escalation: "Security Manager"
    
    medium:
      sla: "30 days"
      escalation: "Team Lead"
    
    low:
      sla: "90 days"
      escalation: "Developer"
  
  remediation_workflow:
    - "Vulnerability identified"
    - "Severity assigned"
    - "Remediation assigned"
    - "Fix implemented"
    - "Validation testing"
    - "Vulnerability closed"
```

---

## AC.3: Code Review Standards

### AC.3.1: Security Code Review Guidelines

**File:** `security-engineering/code-review.md`

```markdown
# Security Code Review Standards

## 1. Review Process

### 1.1 Code Review Requirements

```yaml
# Code Review Requirements
code_review:
  mandatory: true
  approvers: 2
  security_review: true
  automated_scanning: true
  
  review_checklist:
    - "Input validation"
    - "Authentication checks"
    - "Authorization checks"
    - "Data protection"
    - "Error handling"
    - "Logging"
    - "Configuration"
    - "Dependencies"
    - "API security"
    - "Session management"
```

## 2. Review Checklist

### 2.1 Authentication Review

```yaml
# Authentication Review Checklist
authentication_checklist:
  - "MFA implemented"
  - "Password policies enforced"
  - "Session management secure"
  - "Account lockout implemented"
  - "Secure password storage"
  - "Session timeout configured"
  - "Secure logout implemented"
  - "API key rotation"
```

### 2.2 Authorization Review

```yaml
# Authorization Review Checklist
authorization_checklist:
  - "Role-based access control"
  - "Least privilege enforced"
  - "Access reviewed"
  - "Permission validation"
  - "Secure APIs"
  - "Database permissions"
  - "File permissions"
  - "Admin access limited"
```

### 2.3 Data Protection Review

```yaml
# Data Protection Checklist
data_protection_checklist:
  - "Encryption at rest"
  - "Encryption in transit"
  - "Data classification"
  - "Secure data handling"
  - "Data minimization"
  - "Secure data sharing"
  - "Data retention policy"
  - "Secure data disposal"
```

### 2.4 Error Handling Review

```yaml
# Error Handling Checklist
error_handling_checklist:
  - "Error messages secure"
  - "Internal details hidden"
  - "Proper logging"
  - "Error codes defined"
  - "Exception handling"
  - "Recovery procedures"
  - "User-friendly errors"
  - "Debug disabled"
```

---

## AC.4: DevOps Security (DevSecOps)

### AC.4.1: DevSecOps Integration

**File:** `security-engineering/devsecops.md`

```markdown
# DevSecOps Integration

## 1. CI/CD Pipeline Security

### 1.1 Pipeline Security Controls

```yaml
# CI/CD Pipeline Security
pipeline_security:
  code_scanning:
    - name: "SAST"
      stage: "Build"
      tools: ["SonarQube"]
      fail_on_critical: true
    
    - name: "SCA"
      stage: "Build"
      tools: ["Snyk"]
      fail_on_critical: true
    
    - name: "Container Scanning"
      stage: "Build"
      tools: ["Trivy"]
      fail_on_critical: true
  
  security_checks:
    - name: "Secrets Scanning"
      stage: "Pre-commit"
      tools: ["GitGuardian"]
      block_on_find: true
    
    - name: "Security Configuration"
      stage: "Deploy"
      tools: ["Checkov"]
      fail_on_critical: true
  
  compliance_checks:
    - name: "GDPR Compliance"
      stage: "Pre-deploy"
      tools: ["Custom"]
      fail_on_critical: true
    
    - name: "PCI DSS"
      stage: "Pre-deploy"
      tools: ["Custom"]
      fail_on_critical: true
```

## 2. Infrastructure as Code Security

### 2.1 IaC Security Controls

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

### 2.2 Kubernetes Security

```yaml
# Kubernetes Security
kubernetes_security:
  scanning:
    - tool: "kube-bench"
      stage: "Cluster provisioning"
      checks:
        - "CIS Kubernetes Benchmark"
        - "Security configuration"
    
    - tool: "kube-hunter"
      stage: "Runtime"
      checks:
        - "Security vulnerabilities"
        - "Misconfigurations"
  
  monitoring:
    - tool: "Falco"
      stage: "Runtime"
      rules:
        - "Suspicious activity"
        - "Unauthorized access"
        - "Container breakout"
  
  policies:
    - tool: "Open Policy Agent"
      stage: "Admission control"
      checks:
        - "Image provenance"
        - "Resource limits"
        - "Security context"
        - "Privileged containers"
```

## 3. CI/CD Pipeline Example

### 3.1 GitHub Actions Pipeline

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

## AC.5: Application Security Controls

### AC.5.1: Application Security Controls Reference

**File:** `security-engineering/app-security-controls.md`

```markdown
# Application Security Controls Reference

## 1. Control Categories

### 1.1 Authentication Controls

```yaml
# Authentication Controls
authentication_controls:
  mfa:
    - "TOTP (Google Authenticator)"
    - "FIDO2 (Security Keys)"
    - "SMS Verification"
    - "Email Verification"
    - "Push Notifications"
  
  password_policies:
    - minimum_length: 16
    - complexity: 3_of_4
    - history: 24
    - expiration: 90
    - lockout: 5_attempts
  
  session_management:
    - timeout: "30 minutes"
    - max_concurrent: 5
    - ssl_only: true
    - secure_cookies: true
```

### 1.2 Authorization Controls

```yaml
# Authorization Controls
authorization_controls:
  rbac:
    - roles:
        - "Admin"
        - "Manager"
        - "User"
        - "Guest"
    - permissions:
        - "CRUD"
        - "Read"
        - "Write"
        - "Execute"
  
  abac:
    - attributes:
        - "User Department"
        - "Data Classification"
        - "Location"
        - "Time"
    - policies:
        - "Users can access only their department data"
        - "Sensitive data requires approval"
  
  verification:
    - "Check before every operation"
    - "Check all API endpoints"
    - "Check before sensitive data access"
    - "Check before modifications"
```

### 1.3 Data Protection Controls

```yaml
# Data Protection Controls
data_protection_controls:
  encryption:
    at_rest:
      algorithm: "AES-256"
      key_management: "KMS"
    
    in_transit:
      protocol: "TLS 1.3"
      certificate: "Managed"
    
    in_use:
      algorithm: "Tokenization"
      implementation: "API Gateway"
  
  classification:
    levels:
      - "Public"
      - "Internal"
      - "Confidential"
      - "Highly Confidential"
      - "Critical"
  
  handling:
    - "Secure storage"
    - "Secure transmission"
    - "Secure sharing"
    - "Secure disposal"
```

### 1.4 Logging Controls

```yaml
# Logging Controls
logging_controls:
  types:
    - "Authentication events"
    - "Authorization events"
    - "Data access"
    - "Administrative actions"
    - "Security events"
    - "Error events"
  
  content:
    - "Timestamp"
    - "User ID"
    - "Action"
    - "Object"
    - "Result"
    - "Source IP"
    - "Session ID"
  
  protection:
    - "Log integrity"
    - "Log confidentiality"
    - "Log availability"
    - "Log retention"
```

---

This concludes Appendix AC: Complete Security Engineering Reference. This comprehensive reference provides the secure development framework, testing procedures, code review standards, and DevSecOps integration needed to build secure applications and systems as part of the Enterprise Cybersecurity Program.
