# Appendix AH: Complete Application Security Reference

## Overview

This appendix provides comprehensive application security reference material for the Enterprise Cybersecurity Program. It includes secure development practices, application security testing, API security, and container security.

---

## AH.1: Application Security Framework

### AH.1.1: Application Security Standards

**File:** `application-security/app-security-standards.md`

```markdown
# Application Security Standards

## 1. Overview

### 1.1 Application Security Purpose
To ensure applications are developed, deployed, and maintained securely.

### 1.2 Application Security Principles

1. **Security by Design:** Security built into applications
2. **Defense in Depth:** Multiple security layers
3. **Least Privilege:** Minimal application permissions
4. **Secure Defaults:** Secure by default
5. **Continuous Security:** Ongoing security validation

## 2. Secure Development Lifecycle

### 2.1 SDLC Security Activities

```yaml
# SDLC Security Activities
sdlc_security:
  requirements:
    - "Security requirements defined"
    - "Privacy requirements defined"
    - "Compliance requirements defined"
    - "Threat modeling conducted"
  
  design:
    - "Security architecture review"
    - "Design review"
    - "Security patterns applied"
    - "Attack surface analysis"
  
  development:
    - "Secure coding practices"
    - "Code review"
    - "Static analysis (SAST)"
    - "Dependency scanning (SCA)"
  
  testing:
    - "Security testing"
    - "Penetration testing"
    - "Vulnerability scanning"
    - "Fuzzing"
  
  deployment:
    - "Secure deployment"
    - "Configuration hardening"
    - "Security validation"
    - "Monitoring setup"
  
  maintenance:
    - "Vulnerability management"
    - "Patch management"
    - "Incident response"
    - "Continuous improvement"
```

## 3. Application Security Controls

### 3.1 OWASP Top 10 Controls

```yaml
# OWASP Top 10 Controls
owasp_controls:
  A01:2021:
    name: "Broken Access Control"
    controls:
      - "Implement RBAC"
      - "Validate access on every request"
      - "Deny by default"
      - "Use session management"
  
  A02:2021:
    name: "Cryptographic Failures"
    controls:
      - "Use strong encryption"
      - "Use TLS 1.3"
      - "Secure key management"
      - "Use secure hash functions"
  
  A03:2021:
    name: "Injection"
    controls:
      - "Input validation"
      - "Parameterized queries"
      - "Output encoding"
      - "Use prepared statements"
  
  A04:2021:
    name: "Insecure Design"
    controls:
      - "Security by design"
      - "Threat modeling"
      - "Security reviews"
      - "Secure patterns"
  
  A05:2021:
    name: "Security Misconfiguration"
    controls:
      - "Secure defaults"
      - "Regular configuration reviews"
      - "Least privilege"
      - "Automated configuration management"
```

---

## AH.2: Application Security Testing

### AH.2.1: Testing Framework

**File:** `application-security/app-testing.md`

```markdown
# Application Security Testing Framework

## 1. Testing Types

### 1.1 Static Analysis (SAST)

```yaml
# SAST Configuration
sast:
  tools:
    - "SonarQube"
    - "Checkmarx"
    - "Veracode"
    - "ESLint"
  
  languages:
    - "Java"
    - "Python"
    - "JavaScript"
    - "Go"
    - "C#"
  
  rulesets:
    - "OWASP Top 10"
    - "CWE Top 25"
    - "Security specific rules"
  
  frequency: "Every commit"
  quality_gate: "No critical/high issues"
```

### 1.2 Dynamic Analysis (DAST)

```yaml
# DAST Configuration
dast:
  tools:
    - "OWASP ZAP"
    - "Burp Suite"
    - "Nessus"
    - "AppScan"
  
  testing:
    - "Authentication testing"
    - "Session management"
    - "Input validation"
    - "Authorization testing"
    - "API testing"
  
  frequency: "Weekly"
  reporting: "Detailed vulnerability report"
```

### 1.3 Software Composition Analysis (SCA)

```yaml
# SCA Configuration
sca:
  tools:
    - "Snyk"
    - "Dependabot"
    - "Sonatype Nexus"
    - "WhiteSource"
  
  scanning:
    - "Vulnerability detection"
    - "License compliance"
    - "Dependency versioning"
    - "SBOM generation"
  
  remediation:
    - "Automated pull requests"
    - "Vulnerability prioritization"
    - "License compliance"
    - "Version updates"
```

---

## AH.3: API Security

### AH.3.1: API Security Standards

**File:** `application-security/api-security.md`

```markdown
# API Security Standards

## 1. Overview

### 1.1 API Security Purpose
To protect APIs from unauthorized access and attacks.

### 1.2 API Security Principles

1. **Authentication:** Verify API clients
2. **Authorization:** Control API access
3. **Encryption:** Protect API data
4. **Rate Limiting:** Prevent abuse
5. **Input Validation:** Prevent injection
6. **Monitoring:** Detect attacks

## 2. API Security Controls

### 2.1 Authentication Controls

```yaml
# API Authentication Controls
api_authentication:
  methods:
    - "OAuth 2.0"
    - "OpenID Connect"
    - "API Keys"
    - "JWT"
  
  implementation:
    - "Use secure token management"
    - "Implement token expiration"
    - "Use refresh tokens"
    - "Validate tokens on every request"
  
  requirements:
    - "MFA for sensitive APIs"
    - "Strong encryption for tokens"
    - "Secure key storage"
    - "Regular token rotation"
```

### 2.2 Authorization Controls

```yaml
# API Authorization Controls
api_authorization:
  models:
    - "RBAC (Role-Based)"
    - "ABAC (Attribute-Based)"
    - "Claims-Based"
  
  implementation:
    - "Check authorization on every request"
    - "Validate permissions"
    - "Deny by default"
    - "Use scopes"
  
  best_practices:
    - "Implement least privilege"
    - "Use granular permissions"
    - "Validate all requests"
    - "Log authorization decisions"
```

### 2.3 Rate Limiting

```yaml
# API Rate Limiting
api_rate_limiting:
  policies:
    - type: "Global"
      limit: 1000
      window: "1 minute"
    
    - type: "Per User"
      limit: 100
      window: "1 minute"
    
    - type: "Per IP"
      limit: 1000
      window: "1 minute"
    
    - type: "Premium API"
      limit: 10000
      window: "1 minute"
  
  response:
    status: 429
    headers:
      - "X-RateLimit-Limit"
      - "X-RateLimit-Remaining"
      - "X-RateLimit-Reset"
    
    message: "Rate limit exceeded. Please try again later."
```

---

## AH.4: Container Security

### AH.4.1: Container Security Framework

**File:** `application-security/container-security.md`

```markdown
# Container Security Framework

## 1. Overview

### 1.1 Container Security Purpose
To protect containerized applications throughout the lifecycle.

### 1.2 Container Security Principles

1. **Secure Images:** Use trusted base images
2. **Image Scanning:** Scan for vulnerabilities
3. **Least Privilege:** Minimal container permissions
4. **Network Segmentation:** Secure container networking
5. **Runtime Security:** Monitor container activity

## 2. Container Security Controls

### 2.1 Image Security

```yaml
# Container Image Security
image_security:
  base_images:
    - repository: "alpine"
      tag: "3.18"
      safe: true
    
    - repository: "ubuntu"
      tag: "22.04"
      safe: true
  
  vulnerability_scanning:
    enabled: true
    scanner: "Trivy"
    frequency: "Daily"
    severity_threshold: "HIGH"
    fail_on_vulnerability: true
  
  image_policies:
    - name: "deny-latest"
      rule: "tag != latest"
    
    - name: "require-scans"
      rule: "scan_available == true"
    
    - name: "trusted-registry"
      rule: "registry == internal-registry.company.com"
```

### 2.2 Kubernetes Security

```yaml
# Kubernetes Security Configuration
kubernetes_security:
  rbac:
    enabled: true
    default_deny: true
    roles:
      - name: "developer"
        permissions:
          - "pods:get"
          - "pods:list"
          - "logs:get"
      
      - name: "admin"
        permissions:
          - "*:*"
  
  pod_security:
    run_as_non_root: true
    read_only_root_filesystem: true
    allow_privilege_escalation: false
    capabilities:
      drop: ["ALL"]
  
  network_policies:
    - name: "deny-all"
      pod_selector: {}
      policy_types: ["Ingress", "Egress"]
    
    - name: "allow-internal"
      pod_selector: {}
      policy_types: ["Ingress"]
      ingress:
        - from:
            - namespace: "production"
```

---

## AH.5: Secure Coding Standards

### AH.5.1: Secure Coding Guidelines

**File:** `application-security/secure-coding.md`

```markdown
# Secure Coding Guidelines

## 1. Overview

### 1.1 Secure Coding Purpose
To write secure code that prevents vulnerabilities.

### 1.2 Secure Coding Principles

1. **Input Validation:** Validate all input
2. **Output Encoding:** Encode all output
3. **Parameterized Queries:** Prevent SQL injection
4. **Proper Authentication:** Secure authentication
5. **Secure Storage:** Protect sensitive data
6. **Secure Communication:** Use encryption

## 2. Language-Specific Guidelines

### 2.1 Java Guidelines

```yaml
# Java Secure Coding
java_secure_coding:
  input_validation:
    - "Use validation framework (e.g., Bean Validation)"
    - "Validate on server side"
    - "Use whitelist approach"
  
  sql:
    - "Use prepared statements"
    - "Use ORM frameworks"
    - "Avoid dynamic SQL"
  
  authentication:
    - "Use strong password hashing"
    - "Implement MFA"
    - "Secure session management"
  
  cryptography:
    - "Use strong algorithms"
    - "Secure key management"
    - "Use TLS for communication"
```

### 2.2 Python Guidelines

```yaml
# Python Secure Coding
python_secure_coding:
  input_validation:
    - "Use validation libraries"
    - "Validate on server side"
    - "Use type validation"
  
  sql:
    - "Use parameterized queries"
    - "Use ORM frameworks"
    - "Avoid string concatenation"
  
  authentication:
    - "Use bcrypt for passwords"
    - "Implement MFA"
    - "Secure session management"
  
  cryptography:
    - "Use cryptography library"
    - "Secure key management"
    - "Use TLS for communication"
```

### 2.3 JavaScript Guidelines

```yaml
# JavaScript Secure Coding
javascript_secure_coding:
  input_validation:
    - "Use validation libraries"
    - "Validate on server side"
    - "Use whitelist approach"
  
  sql:
    - "Use parameterized queries"
    - "Use ORM frameworks"
    - "Avoid string concatenation"
  
  authentication:
    - "Use strong password hashing"
    - "Implement MFA"
    - "Secure session management"
  
  cryptography:
    - "Use crypto library"
    - "Secure key management"
    - "Use TLS for communication"
```

## 3. Code Review Checklist

### 3.1 Security Code Review Checklist

```yaml
# Security Code Review Checklist
security_review_checklist:
  authentication:
    - "MFA implemented"
    - "Password policies enforced"
    - "Session management secure"
    - "Account lockout implemented"
  
  authorization:
    - "Role-based access control"
    - "Least privilege enforced"
    - "Access reviewed"
    - "Permission validation"
  
  input_validation:
    - "All input validated"
    - "Whitelist approach used"
    - "Sanitization applied"
    - "SQL injection prevented"
  
  output_encoding:
    - "Output encoded"
    - "XSS prevented"
    - "Secure error messages"
    - "No internal details"
  
  data_protection:
    - "Encryption at rest"
    - "Encryption in transit"
    - "Secure key management"
    - "Data classification"
  
  logging:
    - "Security events logged"
    - "Audit logging implemented"
    - "Log protection"
    - "Log retention"
  
  error_handling:
    - "Secure error messages"
    - "Proper exception handling"
    - "No internal details"
    - "Error logging"
```

---

This concludes Appendix AH: Complete Application Security Reference. This comprehensive reference provides the application security framework, testing procedures, API security standards, and container security needed to secure applications as part of the Enterprise Cybersecurity Program.
