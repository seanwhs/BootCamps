# Part 3: Cloud-Native Security & Modern Workloads
## Section 3.5: DevSecOps CI/CD Pipeline Security

## The Target: Complete DevSecOps CI/CD Pipeline Security for Nexus Global Industries

In this section, we'll implement comprehensive DevSecOps CI/CD pipeline security controls, including:

1. **SAST Integration** - Static Application Security Testing
2. **DAST Integration** - Dynamic Application Security Testing
3. **SCA Integration** - Software Composition Analysis
4. **Container Security Scanning** - Pipeline-based container scanning
5. **Pipeline Hardening** - Secure CI/CD configurations
6. **Policy Enforcement** - Automated security gates

**What specific file(s) are we building?**
- `cicd/01_sast_dast_sca.yaml` - SAST/DAST/SCA integration
- `cicd/02_container_scanning.yaml` - Container security scanning
- `cicd/03_pipeline_hardening.yaml` - CI/CD pipeline hardening
- `cicd/04_policy_enforcement.yaml` - Security policy gates
- `cicd/05_pipeline_security_tests.yaml` - Pipeline security validation

---

## The Concept: DevSecOps in Plain English

Think of DevSecOps like **a manufacturing assembly line with quality checks at every station**:

**SAST (Static Analysis):** "Engineers inspect the blueprints for design flaws before manufacturing begins." This is analyzing code without running it.

**DAST (Dynamic Analysis):** "Quality control runs the finished product through tests while it's running." This is testing running applications.

**SCA (Software Composition Analysis):** "The assembly line checks that all imported parts meet safety standards." This is scanning third-party dependencies.

**Container Scanning:** "Each shipping container is x-rayed before being loaded onto the truck." This is scanning container images for vulnerabilities.

**Pipeline Hardening:** "The assembly line itself has safety features to prevent tampering." This is securing the CI/CD system.

**Policy Enforcement:** "The line automatically stops if any quality check fails." This is automated security gates.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the cicd directory
cd ~/nexus_security_architecture
mkdir -p cicd

# Verify the structure
ls -la
# Expected: cicd directory appears
```

---

### Step 2: SAST/DAST/SCA Integration

**File:** `cicd/01_sast_dast_sca.yaml`

```yaml
# SAST/DAST/SCA Integration - Nexus Global Industries
# File: cicd/01_sast_dast_sca.yaml
# Version: 1.0

# ====================================================================
# GITLAB CI SECURITY STAGES
# ====================================================================

---
# GitLab CI Security Pipeline Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-ci-security
  namespace: cicd-security
data:
  .gitlab-ci.yml: |
    # GitLab CI Security Pipeline
    stages:
      - build
      - sast
      - dast
      - sca
      - container-scan
      - policy-check
      - deploy

    variables:
      SAST_IMAGE: "registry.gitlab.com/security-products/sast:latest"
      DAST_IMAGE: "registry.gitlab.com/security-products/dast:latest"
      SCA_IMAGE: "registry.gitlab.com/security-products/dependency-scanning:latest"
      CONTAINER_SCAN_IMAGE: "registry.gitlab.com/security-products/container-scanning:latest"

    # SAST Stage
    sast:
      stage: sast
      image: ${SAST_IMAGE}
      script:
        - /analyzer run
      artifacts:
        reports:
          sast: gl-sast-report.json
        paths:
          - gl-sast-report.json
      only:
        - merge_requests
        - main
      rules:
        - if: $CI_MERGE_REQUEST_ID
        - if: $CI_COMMIT_BRANCH == "main"

    # DAST Stage
    dast:
      stage: dast
      image: ${DAST_IMAGE}
      script:
        - /analyzer run --target-url https://staging.nexus.com
      artifacts:
        reports:
          dast: gl-dast-report.json
        paths:
          - gl-dast-report.json
      only:
        - main
      when: manual

    # SCA Stage
    sca:
      stage: sca
      image: ${SCA_IMAGE}
      script:
        - /analyzer run
      artifacts:
        reports:
          dependency_scanning: gl-dependency-scanning-report.json
        paths:
          - gl-dependency-scanning-report.json
      only:
        - merge_requests
        - main

    # Policy check gate
    policy-check:
      stage: policy-check
      image: python:3.11-slim
      script:
        - python /security/check_policies.py
      dependencies:
        - sast
        - sca
      only:
        - merge_requests
        - main

---
# SAST Rules (Custom)
apiVersion: v1
kind: ConfigMap
metadata:
  name: sast-rules
  namespace: cicd-security
data:
  custom-rules.yml: |
    # Custom SAST Rules
    rules:
      - id: NEXUS-001
        name: "Hardcoded Secrets"
        severity: "CRITICAL"
        language: "python"
        pattern: |
          (password|secret|key|token|api_key)\s*=\s*['"][^'"]+['"]
        message: "Hardcoded secrets found in code"
      
      - id: NEXUS-002
        name: "SQL Injection Risk"
        severity: "HIGH"
        language: "python"
        pattern: |
          cursor\.execute\s*\(\s*["'](.*?%.*?)["']\s*%
        message: "Potential SQL injection vulnerability"
      
      - id: NEXUS-003
        name: "Command Injection"
        severity: "HIGH"
        language: "python"
        pattern: |
          os\.system\s*\(.*?\+.*?\)
        message: "Potential command injection vulnerability"
      
      - id: NEXUS-004
        name: "Insecure Deserialization"
        severity: "HIGH"
        language: "python"
        pattern: |
          pickle\.loads\s*\(
        message: "Insecure deserialization detected"
      
      - id: NEXUS-005
        name: "XSS Vulnerability"
        severity: "MEDIUM"
        language: "javascript"
        pattern: |
          (innerHTML|outerHTML)\s*=\s*.*?\+
        message: "Potential XSS vulnerability"

---
# Dependency Scanning Config
apiVersion: v1
kind: ConfigMap
metadata:
  name: sca-config
  namespace: cicd-security
data:
  .dependency-scanning.yml: |
    # Dependency Scanning Configuration
    ---
    # Exclude certain packages
    exclude:
      - "*.test"
      - "*.mock"
    
    # Vulnerability thresholds
    thresholds:
      critical: 0
      high: 5
      medium: 20
      low: 50
    
    # Override severity for specific CVEs
    override:
      - CVE-2023-12345: "CRITICAL"
      - CVE-2023-67890: "HIGH"
    
    # Custom policies
    policies:
      - rule: "package_manager == 'pip'"
        min_version: "1.0.0"
        max_version: "2.0.0"
        message: "Version 1.x of this package is deprecated"

# ====================================================================
# SEMGREP SAST INTEGRATION
# ====================================================================

---
# Semgrep CI Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: semgrep-config
  namespace: cicd-security
data:
  semgrep.yml: |
    # Semgrep SAST Configuration
    rules:
      # OWASP Top 10 rules
      - id: owasp-top10-a01-broken-access-control
        pattern: |
          @app.route(...)
          def ...():
            ...
            return render_template(...)
        message: "Potential broken access control"
        severity: ERROR
      
      - id: owasp-top10-a02-crypto-failures
        pattern: |
          hashlib.md5(...)
        message: "MD5 is insecure, use SHA-256 or stronger"
        severity: ERROR
      
      - id: owasp-top10-a03-injection
        pattern: |
          query = "SELECT * FROM users WHERE id = " + user_input
        message: "SQL injection risk"
        severity: ERROR
      
      - id: owasp-top10-a04-insecure-design
        pattern: |
          eval(...)
        message: "Use of eval() is dangerous"
        severity: ERROR
      
      - id: owasp-top10-a05-security-misconfiguration
        pattern: |
          DEBUG = True
        message: "Debug mode enabled in production"
        severity: ERROR
      
      - id: owasp-top10-a06-vulnerable-components
        pattern: |
          import "package:some/old/package"
        message: "Vulnerable dependency detected"
        severity: ERROR
      
      - id: owasp-top10-a07-identification-auth-failures
        pattern: |
          password == "admin123"
        message: "Hardcoded credentials"
        severity: ERROR
      
      - id: owasp-top10-a08-software-data-integrity
        pattern: |
          requests.get(url, verify=False)
        message: "SSL verification disabled"
        severity: ERROR
      
      - id: owasp-top10-a09-security-logging-monitoring
        pattern: |
          except Exception as e:
            pass
        message: "Exception suppressed without logging"
        severity: WARNING
      
      - id: owasp-top10-a10-server-side-request-forgery
        pattern: |
          requests.get(request.args.get('url'))
        message: "Potential SSRF vulnerability"
        severity: ERROR
```

**Verification:**

```bash
# Verify SAST/DAST/SCA file
ls -la cicd/01_sast_dast_sca.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cicd/01_sast_dast_sca.yaml'))"
# Expected: No error output
```

---

### Step 3: Container Security Scanning in Pipelines

**File:** `cicd/02_container_scanning.yaml`

```yaml
# Container Security Scanning - Nexus Global Industries
# File: cicd/02_container_scanning.yaml
# Version: 1.0

# ====================================================================
# TRIVY SCANNING IN CI/CD
# ====================================================================

---
# Trivy CI Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: trivy-ci-config
  namespace: cicd-security
data:
  .trivy.yml: |
    # Trivy Scanning Configuration
    ---
    # Image scanning
    image:
      enabled: true
      format: "json"
      output: "trivy-report.json"
    
    # Severity levels to scan
    severity:
      - "CRITICAL"
      - "HIGH"
      - "MEDIUM"
    
    # Vulnerability types
    vulnerability_types:
      - "os"
      - "library"
    
    # Ignore unfixed vulnerabilities
    ignore_unfixed: false
    
    # Timeout
    timeout: 10m
    
    # Registry configuration
    registry:
      - type: "aws"
        region: "us-east-1"
        url: "123456789012.dkr.ecr.us-east-1.amazonaws.com"

---
# GitLab CI Container Scanning Stage
apiVersion: v1
kind: ConfigMap
metadata:
  name: container-scan-stage
  namespace: cicd-security
data:
  .container-scan.yml: |
    # Container Scanning Stage
    container-scan:
      stage: container-scan
      image: aquasec/trivy:latest
      script:
        - |
          # Build the container image
          docker build -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA} .
          
          # Scan the image
          trivy image --severity CRITICAL,HIGH --format json \
            --output gl-container-scanning-report.json \
            ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
          
          # Check for critical vulnerabilities
          CRITICAL=$(jq '.Results[].Vulnerabilities[] | select(.Severity=="CRITICAL") | .VulnerabilityID' gl-container-scanning-report.json | wc -l)
          
          if [ "$CRITICAL" -gt 0 ]; then
            echo "CRITICAL: Found $CRITICAL critical vulnerabilities"
            exit 1
          fi
          
          # Check for high vulnerabilities threshold
          HIGH=$(jq '.Results[].Vulnerabilities[] | select(.Severity=="HIGH") | .VulnerabilityID' gl-container-scanning-report.json | wc -l)
          if [ "$HIGH" -gt 5 ]; then
            echo "ERROR: Found $HIGH high vulnerabilities (limit: 5)"
            exit 1
          fi
          
          echo "Scan passed: $CRITICAL critical, $HIGH high vulnerabilities"
      artifacts:
        reports:
          container_scanning: gl-container-scanning-report.json
        paths:
          - gl-container-scanning-report.json
      only:
        - merge_requests
        - main

# ====================================================================
# SBOM GENERATION IN PIPELINE
# ====================================================================

---
# SBOM Generation Stage
apiVersion: v1
kind: ConfigMap
metadata:
  name: sbom-generation
  namespace: cicd-security
data:
  .sbom.yml: |
    # SBOM Generation
    generate-sbom:
      stage: container-scan
      image: anchore/syft:latest
      script:
        - |
          # Generate SBOM in multiple formats
          syft dir:. -o cyclonedx-json > sbom.cyclonedx.json
          syft dir:. -o spdx-json > sbom.spdx.json
          syft dir:. -o table > sbom.txt
          
          # Upload to SBOM repository
          curl -X PUT -H "Content-Type: application/json" \
            -d @sbom.cyclonedx.json \
            https://sbom.nexus.com/api/v1/sboms/${CI_PROJECT_NAME}/${CI_COMMIT_SHORT_SHA}
          
          echo "SBOM generated and uploaded"
      artifacts:
        paths:
          - sbom.cyclonedx.json
          - sbom.spdx.json
          - sbom.txt
      only:
        - main

# ====================================================================
# IMAGE SIGNING IN CI/CD (Cosign)
# ====================================================================

---
# Cosign Signing Stage
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-signing
  namespace: cicd-security
data:
  .cosign.yml: |
    # Image Signing with Cosign
    sign-image:
      stage: container-scan
      image: sigstore/cosign:latest
      script:
        - |
          # Sign the container image
          cosign sign --key k8s://cosign-keys/cosign \
            ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
          
          # Verify the signature
          cosign verify --key cosign.pub \
            ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
          
          echo "Image signed and verified"
      only:
        - main
      when: manual

# ====================================================================
# CLAIR SCANNING (Alternative)
# ====================================================================

---
# Clair Scanning Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: clair-config
  namespace: cicd-security
data:
  clair.yml: |
    # Clair Scanning Configuration
    clair:
      # Clair API endpoint
      endpoint: "http://clair:6060"
      
      # Scan all layers
      scan_all_layers: true
      
      # Priority for vulnerabilities
      priority:
        - "CRITICAL"
        - "HIGH"
        - "MEDIUM"
        - "LOW"
      
      # Database configuration
      database:
        type: "pgsql"
        options:
          source: "host=postgres port=5432 user=clair dbname=clair sslmode=disable"
```

**Verification:**

```bash
# Verify container scanning file
ls -la cicd/02_container_scanning.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cicd/02_container_scanning.yaml'))"
# Expected: No error output
```

---

### Step 4: Pipeline Hardening

**File:** `cicd/03_pipeline_hardening.yaml`

```yaml
# Pipeline Hardening - Nexus Global Industries
# File: cicd/03_pipeline_hardening.yaml
# Version: 1.0

# ====================================================================
# CI/CD SECURITY BEST PRACTICES
# ====================================================================

---
# GitLab Runner Security Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-runner-security
  namespace: cicd-security
data:
  config.toml: |
    # GitLab Runner Security Configuration
    concurrent = 10
    check_interval = 0
    
    [session_server]
      listen_address = ":8093"
      advertise_address = "runner-coordinator.cicd:8093"
      session_timeout = 1800
    
    [[runners]]
      name = "docker-runner"
      url = "https://gitlab.nexus.com"
      token = "gitlab-runner-token"
      executor = "docker"
      
      [runners.docker]
        tls_verify = false
        image = "ubuntu:22.04"
        privileged = false
        disable_cache = false
        volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
        shm_size = 0
        
        # Security settings
        security_opt = ["seccomp=unconfined"]
        cap_add = ["NET_ADMIN", "SYS_ADMIN"]
        cap_drop = ["ALL"]
        
        # Resource limits
        memory = "2048m"
        memory_swap = "4096m"
        cpu_quota = "50000"
        cpu_period = "100000"
        
        # Network isolation
        network_mode = "bridge"
        extra_hosts = ["gitlab.nexus.com:10.0.0.10"]
      
      [runners.docker.sysctls]
        "net.core.somaxconn" = "1024"
        "net.ipv4.tcp_syncookies" = "1"

---
# GitLab CI Security Settings
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-ci-security-settings
  namespace: cicd-security
data:
  .gitlab-ci-security.yml: |
    # GitLab CI Security Settings
    
    # Disable CI/CD jobs on forks (prevent secret leakage)
    variables:
      SECURE_DISABLE_JOB_TOKEN: "true"
      SECURE_JOB_TOKEN_SCOPING: "true"
      SECURE_SKIP_AUTO_VULNERABILITY: "false"
    
    # Secret masking in logs
    secrets:
      - ".*password.*"
      - ".*secret.*"
      - ".*token.*"
      - ".*key.*"
    
    # Protected variables (only on main branch)
    protected_variables:
      - name: "DEPLOY_KEY"
        value: "deploy-key-12345"
        branches: ["main"]
      
      - name: "PRODUCTION_SECRET"
        value: "prod-secret-67890"
        branches: ["main"]
    
    # CI/CD job token scope
    job_token_scope:
      enabled: true
      allow_others: false

---
# GitLab Project Security Settings
apiVersion: v1
kind: ConfigMap
metadata:
  name: project-security-settings
  namespace: cicd-security
data:
  project-settings.yml: |
    # Project Security Settings
    
    # Repository settings
    repository:
      # Branch protection
      protected_branches:
        - name: "main"
          merge_access: "maintainer"
          push_access: "maintainer"
          code_owner_approval_required: true
          require_linear_history: true
      
      # Require signed commits
      require_signed_commits: true
    
    # Merge request settings
    merge_requests:
      approvals_required: 2
      approvals_before_merge: true
      require_all_threads_resolved: true
      require_pipeline_succeeded: true
      require_security_reports: true
    
    # CI/CD settings
    ci_cd:
      allow_auto_merge: false
      allow_pipelines_on_protected_branches: true
      require_approval_for_security_changes: true

# ====================================================================
# SECURE SECRETS MANAGEMENT IN CI/CD
# ====================================================================

---
# Vault Integration for CI/CD Secrets
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-cicd-integration
  namespace: cicd-security
data:
  vault-config.hcl: |
    # Vault CI/CD Integration
    # Using Vault for secure secret injection
    
    # Vault address
    vault_addr = "https://vault.nexus.com:8200"
    
    # Authentication method
    auth_method = "kubernetes"
    
    # Kubernetes service account
    service_account = "gitlab-runner-sa"
    
    # Role mapping
    role = "gitlab-ci"
    
    # Secrets to inject
    secrets:
      - path: "secret/data/ci/aws"
        inject: true
        env_prefix: "AWS_"
      
      - path: "secret/data/ci/gitlab"
        inject: true
        env_prefix: "GITLAB_"
      
      - path: "secret/data/ci/docker"
        inject: true
        env_prefix: "DOCKER_"

---
# Vault Agent Sidecar for CI/CD
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-agent-config
  namespace: cicd-security
data:
  vault-agent.hcl: |
    # Vault Agent Configuration
    pid_file = "/tmp/pidfile"
    
    auto_auth {
      method {
        type = "kubernetes"
        config = {
          role = "gitlab-ci"
          service_account = "gitlab-runner-sa"
        }
      }
      
      sink {
        type = "file"
        config = {
          path = "/home/runner/.vault-token"
        }
      }
    }
    
    template {
      destination = "/secrets/.env"
      contents = <<EOH
        {{ with secret "secret/data/ci/aws" }}
        AWS_ACCESS_KEY_ID={{ .Data.data.access_key }}
        AWS_SECRET_ACCESS_KEY={{ .Data.data.secret_key }}
        AWS_REGION={{ .Data.data.region }}
        {{ end }}
        
        {{ with secret "secret/data/ci/gitlab" }}
        GITLAB_TOKEN={{ .Data.data.token }}
        GITLAB_URL={{ .Data.data.url }}
        {{ end }}
      EOH
    }

# ====================================================================
# CI/CD AUDIT LOGGING
# ====================================================================

---
# CI/CD Audit Logging to SIEM
apiVersion: v1
kind: ConfigMap
metadata:
  name: cicd-audit-logging
  namespace: cicd-security
data:
  audit-logging.py: |
    # CI/CD Audit Logging to SIEM
    import os
    import json
    import requests
    from datetime import datetime
    
    class CICDAuditLogger:
        """Audit logging for CI/CD events"""
        
        def __init__(self):
            self.siem_url = os.environ.get('SIEM_URL', 'http://logstash.siem.svc.cluster.local:5044')
        
        def log_event(self, event_type, data):
            """Log CI/CD event to SIEM"""
            log_entry = {
                'event_type': f'CICD_{event_type}',
                'timestamp': datetime.utcnow().isoformat(),
                'pipeline_id': os.environ.get('CI_PIPELINE_ID'),
                'project_id': os.environ.get('CI_PROJECT_ID'),
                'commit_sha': os.environ.get('CI_COMMIT_SHA'),
                'branch': os.environ.get('CI_COMMIT_BRANCH'),
                'user': os.environ.get('GITLAB_USER_EMAIL'),
                'data': data
            }
            
            try:
                requests.post(self.siem_url, json=log_entry, timeout=5)
                print(f"Audit log sent: {event_type}")
            except Exception as e:
                print(f"Error sending audit log: {e}")
        
        def log_security_event(self, event_type, severity, details):
            """Log security-specific CI/CD events"""
            self.log_event(f'SECURITY_{event_type}', {
                'severity': severity,
                'details': details
            })
    
    # Usage in CI/CD pipeline
    if __name__ == '__main__':
        logger = CICDAuditLogger()
        
        # Log pipeline start
        logger.log_event('PIPELINE_START', {
            'pipeline_type': os.environ.get('CI_PIPELINE_SOURCE')
        })
        
        # Log security scan results
        logger.log_security_event('SCAN_COMPLETE', 'INFO', {
            'scan_type': 'SAST',
            'findings': 0
        })
```

**Verification:**

```bash
# Verify pipeline hardening file
ls -la cicd/03_pipeline_hardening.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cicd/03_pipeline_hardening.yaml'))"
# Expected: No error output
```

---

### Step 5: Policy Enforcement in CI/CD

**File:** `cicd/04_policy_enforcement.yaml`

```yaml
# Policy Enforcement in CI/CD - Nexus Global Industries
# File: cicd/04_policy_enforcement.yaml
# Version: 1.0

# ====================================================================
# SECURITY POLICY ENGINE
# ====================================================================

---
# Policy Engine Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: policy-engine
  namespace: cicd-security
data:
  policies.rego: |
    # CI/CD Security Policies
    package cicd.policies
    
    # Policy: Require SAST scan
    require_sast {
      input.pipeline.stages[_] == "sast"
    }
    
    # Policy: Require SCA scan
    require_sca {
      input.pipeline.stages[_] == "sca"
    }
    
    # Policy: Require container scan (for container builds)
    require_container_scan {
      input.pipeline.stages[_] == "container-scan"
      input.pipeline.variables.CONTAINER_BUILD == "true"
    }
    
    # Policy: Zero critical vulnerabilities
    zero_critical_vulns {
      count(input.scan_results.critical) == 0
    }
    
    # Policy: High vulnerability limit
    high_vuln_limit {
      count(input.scan_results.high) <= 5
    }
    
    # Policy: Required approvals for deployment
    require_approval {
      input.pipeline.environment == "production"
      input.pipeline.approvals >= 2
    }
    
    # Policy: Branch protection
    branch_protected {
      input.pipeline.branch in ["main", "production"]
      input.pipeline.branch_protected == true
    }
    
    # Policy: Commit signing
    commit_signed {
      input.pipeline.commit_signed == true
    }
    
    # Combined policy: All checks must pass
    all_checks_passed {
      require_sast
      require_sca
      zero_critical_vulns
      high_vuln_limit
      commit_signed
    }
    
    # Combined policy: Production deployment
    production_deploy_ok {
      all_checks_passed
      require_approval
      branch_protected
      require_container_scan
    }

---
# Policy Enforcement Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: policy-enforcer
  namespace: cicd-security
spec:
  replicas: 2
  selector:
    matchLabels:
      app: policy-enforcer
  template:
    metadata:
      labels:
        app: policy-enforcer
    spec:
      containers:
      - name: enforcer
        image: openpolicyagent/opa:latest
        args:
        - "run"
        - "--server"
        - "--addr=:8181"
        - "--log-level=debug"
        volumeMounts:
        - name: policies
          mountPath: /policies
        ports:
        - containerPort: 8181
        livenessProbe:
          httpGet:
            path: /health
            port: 8181
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"
      volumes:
      - name: policies
        configMap:
          name: policy-engine

# ====================================================================
# CI/CD GATE KEEPER
# ====================================================================

---
# Gatekeeper Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper
  namespace: cicd-security
spec:
  replicas: 2
  selector:
    matchLabels:
      app: gatekeeper
  template:
    metadata:
      labels:
        app: gatekeeper
    spec:
      containers:
      - name: gatekeeper
        image: python:3.11-slim
        command:
        - python
        - /app/gatekeeper.py
        env:
        - name: OPA_URL
          value: "http://policy-enforcer:8181"
        - name: SIEM_URL
          value: "http://logstash.siem.svc.cluster.local:5044"
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: app
          mountPath: /app
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"
      volumes:
      - name: app
        configMap:
          name: gatekeeper-app

---
# Gatekeeper Application
apiVersion: v1
kind: ConfigMap
metadata:
  name: gatekeeper-app
  namespace: cicd-security
data:
  gatekeeper.py: |
    # CI/CD Gatekeeper Service
    import os
    import json
    import requests
    from flask import Flask, request, jsonify
    
    app = Flask(__name__)
    OPA_URL = os.environ.get('OPA_URL', 'http://policy-enforcer:8181')
    SIEM_URL = os.environ.get('SIEM_URL', 'http://logstash.siem.svc.cluster.local:5044')
    
    @app.route('/health', methods=['GET'])
    def health():
        return jsonify({'status': 'healthy'})
    
    @app.route('/api/evaluate', methods=['POST'])
    def evaluate():
        """Evaluate pipeline against policies"""
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Send to OPA for evaluation
        try:
            response = requests.post(
                f"{OPA_URL}/v1/data/cicd/policies/production_deploy_ok",
                json={'input': data}
            )
            response.raise_for_status()
            result = response.json()
            
            allowed = result.get('result', False)
            
            # Log to SIEM
            if not allowed:
                log_entry = {
                    'event_type': 'PIPELINE_BLOCKED',
                    'timestamp': datetime.utcnow().isoformat(),
                    'pipeline': data.get('pipeline', {}).get('id'),
                    'reason': 'Policy violation'
                }
                requests.post(SIEM_URL, json=log_entry)
            
            return jsonify({
                'allowed': allowed,
                'result': result
            })
            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/block', methods=['POST'])
    def block_pipeline():
        """Block a pipeline that violated policies"""
        data = request.json
        pipeline_id = data.get('pipeline_id')
        reason = data.get('reason')
        
        # Send block notification
        log_entry = {
            'event_type': 'PIPELINE_BLOCKED',
            'timestamp': datetime.utcnow().isoformat(),
            'pipeline_id': pipeline_id,
            'reason': reason
        }
        requests.post(SIEM_URL, json=log_entry)
        
        # In production, use GitLab API to cancel pipeline
        return jsonify({
            'blocked': True,
            'pipeline_id': pipeline_id,
            'reason': reason
        })
    
    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=8080)
```

**Verification:**

```bash
# Verify policy enforcement file
ls -la cicd/04_policy_enforcement.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cicd/04_policy_enforcement.yaml'))"
# Expected: No error output
```

---

### Step 6: Pipeline Security Validation

**File:** `cicd/05_pipeline_security_tests.yaml`

```yaml
# Pipeline Security Validation - Nexus Global Industries
# File: cicd/05_pipeline_security_tests.yaml
# Version: 1.0

# ====================================================================
# PIPELINE SECURITY TESTS
# ====================================================================

---
# Security Test Suite for CI/CD Pipeline
apiVersion: v1
kind: ConfigMap
metadata:
  name: pipeline-security-tests
  namespace: cicd-security
data:
  test_pipeline.py: |
    # Pipeline Security Tests
    import os
    import json
    import unittest
    import requests
    from datetime import datetime
    
    class PipelineSecurityTest(unittest.TestCase):
        """Security tests for CI/CD pipeline"""
        
        def setUp(self):
            self.gitlab_url = os.environ.get('GITLAB_URL', 'https://gitlab.nexus.com')
            self.gitlab_token = os.environ.get('GITLAB_TOKEN')
            self.api_url = os.environ.get('API_URL', 'http://gatekeeper:8080')
        
        def test_pipeline_requires_sast(self):
            """Test that pipeline requires SAST"""
            response = requests.get(
                f"{self.gitlab_url}/api/v4/projects/1/pipelines/latest",
                headers={'PRIVATE-TOKEN': self.gitlab_token}
            )
            
            pipeline = response.json()
            stages = pipeline.get('stages', [])
            
            self.assertIn('sast', stages, "SAST stage missing from pipeline")
        
        def test_pipeline_requires_sca(self):
            """Test that pipeline requires SCA"""
            response = requests.get(
                f"{self.gitlab_url}/api/v4/projects/1/pipelines/latest",
                headers={'PRIVATE-TOKEN': self.gitlab_token}
            )
            
            pipeline = response.json()
            stages = pipeline.get('stages', [])
            
            self.assertIn('sca', stages, "SCA stage missing from pipeline")
        
        def test_pipeline_has_security_gates(self):
            """Test that pipeline has security gates"""
            response = requests.get(
                f"{self.gitlab_url}/api/v4/projects/1/pipelines/latest",
                headers={'PRIVATE-TOKEN': self.gitlab_token}
            )
            
            pipeline = response.json()
            jobs = pipeline.get('jobs', [])
            
            security_jobs = [j for j in jobs if 'security' in j.get('name', '')]
            self.assertGreater(len(security_jobs), 0, "No security jobs found")
        
        def test_pipeline_blocks_vulnerabilities(self):
            """Test that pipeline blocks vulnerabilities"""
            # Simulate vulnerability detection
            response = requests.post(
                f"{self.api_url}/api/evaluate",
                json={
                    'pipeline': {
                        'id': 'test-pipeline',
                        'stages': ['build', 'sast', 'sca', 'deploy']
                    },
                    'scan_results': {
                        'critical': ['CVE-2023-12345'],
                        'high': ['CVE-2023-67890']
                    }
                }
            )
            
            result = response.json()
            self.assertFalse(result.get('allowed', True), "Pipeline should be blocked")
        
        def test_pipeline_requires_approvals(self):
            """Test that production requires approvals"""
            response = requests.post(
                f"{self.api_url}/api/evaluate",
                json={
                    'pipeline': {
                        'id': 'prod-pipeline',
                        'environment': 'production',
                        'approvals': 1,
                        'stages': ['build', 'sast', 'sca', 'deploy']
                    },
                    'scan_results': {
                        'critical': [],
                        'high': []
                    }
                }
            )
            
            result = response.json()
            self.assertFalse(result.get('allowed', True), "Production should require 2 approvals")
        
        def test_pipeline_has_audit_logging(self):
            """Test that pipeline has audit logging"""
            # Check for audit logging configuration
            response = requests.get(
                f"{self.gitlab_url}/api/v4/projects/1/variables",
                headers={'PRIVATE-TOKEN': self.gitlab_token}
            )
            
            variables = response.json()
            audit_vars = [v for v in variables if 'AUDIT' in v.get('key', '')]
            
            self.assertGreater(len(audit_vars), 0, "Audit logging not configured")
        
        def test_pipeline_secrets_are_masked(self):
            """Test that secrets are masked in logs"""
            response = requests.get(
                f"{self.gitlab_url}/api/v4/projects/1/pipelines/latest/jobs",
                headers={'PRIVATE-TOKEN': self.gitlab_token}
            )
            
            jobs = response.json()
            for job in jobs:
                # Check that secrets are not exposed
                log = job.get('trace', '')
                self.assertNotIn('password', log.lower(), "Secret exposed in logs")
                self.assertNotIn('secret', log.lower(), "Secret exposed in logs")
                self.assertNotIn('token', log.lower(), "Secret exposed in logs")
        
        def test_pipeline_container_scanning(self):
            """Test that pipeline scans containers"""
            response = requests.post(
                f"{self.api_url}/api/evaluate",
                json={
                    'pipeline': {
                        'id': 'container-pipeline',
                        'variables': {
                            'CONTAINER_BUILD': 'true'
                        },
                        'stages': ['build', 'container-scan', 'deploy']
                    },
                    'scan_results': {
                        'critical': [],
                        'high': []
                    }
                }
            )
            
            result = response.json()
            self.assertTrue(result.get('allowed', False), "Container scan should be required")
    
    if __name__ == '__main__':
        unittest.main()

---
# Pipeline Security Test Runner
apiVersion: batch/v1
kind: CronJob
metadata:
  name: pipeline-security-tests
  namespace: cicd-security
spec:
  schedule: "0 12 * * *"  # Daily at noon
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: test-runner
            image: python:3.11-slim
            command:
            - python
            - /tests/test_pipeline.py
            env:
            - name: GITLAB_URL
              value: "https://gitlab.nexus.com"
            - name: GITLAB_TOKEN
              valueFrom:
                secretKeyRef:
                  name: gitlab-token
                  key: token
            - name: API_URL
              value: "http://gatekeeper:8080"
            volumeMounts:
            - name: tests
              mountPath: /tests
          volumes:
          - name: tests
            configMap:
              name: pipeline-security-tests
          restartPolicy: OnFailure
```

**Verification:**

```bash
# Verify pipeline security tests file
ls -la cicd/05_pipeline_security_tests.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cicd/05_pipeline_security_tests.yaml'))"
# Expected: No error output
```

---

### Step 7: DevSecOps Summary

**File:** `cicd/README.md`

```markdown
# DevSecOps CI/CD Pipeline Security - Nexus Global Industries

## Overview

This directory contains the complete DevSecOps CI/CD pipeline security implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_sast_dast_sca.yaml` | SAST/DAST/SCA | Security scanning integration |
| `02_container_scanning.yaml` | Container | Container security scanning |
| `03_pipeline_hardening.yaml` | Hardening | CI/CD pipeline hardening |
| `04_policy_enforcement.yaml` | Policy | Security policy gates |
| `05_pipeline_security_tests.yaml` | Testing | Pipeline security validation |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVSECOPS CI/CD ARCHITECTURE                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  DEVELOPER PUSHES CODE                                 │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  PRE-COMMIT / PRE-MERGE CHECKS                         │   │
│  │  • Code linting                                       │   │
│  │  • Secret scanning (TruffleHog)                       │   │
│  │  • Commit signing verification                       │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  CI/CD PIPELINE                                        │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │  SAST (Semgrep/CodeQl)                       │    │   │
│  │  │  • OWASP Top 10 checks                      │    │   │
│  │  │  • Custom rules                            │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │  SCA (Dependency Scanning)                    │    │   │
│  │  │  • Vulnerable dependencies                   │    │   │
│  │  │  • License compliance                       │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │  Container Scanning (Trivy)                   │    │   │
│  │  │  • OS vulnerabilities                        │    │   │
│  │  │  • Application vulnerabilities               │    │   │
│  │  │  • SBOM generation                           │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │  DAST (ZAP)                                  │    │   │
│  │  │  • Dynamic scanning                          │    │   │
│  │  │  • API testing                               │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  POLICY GATE                                          │   │
│  │  • Zero critical vulnerabilities                     │   │
│  │  • <5 high vulnerabilities                          │   │
│  │  • Required approvals                               │   │
│  │  • Branch protection                                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  DEPLOYMENT                                            │   │
│  │  • Secure deployment to production                   │   │
│  │  • Immutable infrastructure                          │   │
│  │  • Audit logging                                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Tool | Description |
|---------|------|-------------|
| **SAST** | Semgrep/CodeQL | Static analysis for OWASP Top 10 |
| **DAST** | OWASP ZAP | Dynamic testing of running apps |
| **SCA** | GitLab SCA | Dependency vulnerability scanning |
| **Container Scan** | Trivy | Container image vulnerability scanning |
| **SBOM** | Syft | Software Bill of Materials generation |
| **Image Signing** | Cosign | Container image signing |
| **Policy Enforcement** | OPA | Automated security gates |
| **Secret Management** | Vault | Secure secret injection |

## Deployment Instructions

### 1. Configure GitLab CI Pipeline

Add security stages to existing `.gitlab-ci.yml`:

```yaml
include:
  - local: .gitlab-ci-security.yml
```

### 2. Deploy Policy Engine

```bash
kubectl apply -f cicd/04_policy_enforcement.yaml
```

### 3. Configure Vault Integration

```bash
kubectl apply -f cicd/03_pipeline_hardening.yaml
```

### 4. Deploy Security Tests

```bash
kubectl apply -f cicd/05_pipeline_security_tests.yaml
```

## Verification Checklist

- [ ] SAST scanning in CI/CD pipeline
- [ ] SCA scanning for dependencies
- [ ] Container scanning for all container builds
- [ ] SBOM generation for all images
- [ ] Image signing with Cosign
- [ ] Policy gates block vulnerable code
- [ ] Secrets injected securely via Vault
- [ ] Pipeline audit logs sent to SIEM
- [ ] Pipeline security tests passing

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la cicd/README.md
# Expected: File exists

echo "✅ DevSecOps CI/CD Pipeline Security Complete!"
echo "   - SAST/DAST/SCA integration"
echo "   - Container security scanning"
echo "   - Pipeline hardening"
echo "   - Policy enforcement"
echo "   - Pipeline security validation"
```

---

## Part 3 Completion Summary

**[GENERATED: Part 3 Complete - Cloud-Native Security & Modern Workloads]**

### What We've Built

| Section | Artifacts | Status |
|---------|-----------|--------|
| **3.1 Multi-Cloud Security** | 5 files (landing zones, shared responsibility, CSPM, IAM, compliance) | ✅ Complete |
| **3.2 Container & Kubernetes Security** | 6 files (image security, hardening, RBAC, admission, pod, runtime) | ✅ Complete |
| **3.3 Infrastructure as Code Security** | 5 files (scanning, policy, CI/CD gates, secrets, compliance) | ✅ Complete |
| **3.4 API Security** | 5 files (gateway, JWT, rate limiting, validation, testing) | ✅ Complete |
| **3.5 DevSecOps CI/CD** | 5 files (SAST/DAST/SCA, container scanning, hardening, policy, tests) | ✅ Complete |

### Total Artifacts Created (Part 3)

```
cloud/
├── 01_landing_zones.tf
├── 02_shared_responsibility.md
├── 03_cspm_config.yaml
├── 04_cross_cloud_iam.tf
├── 05_compliance_checks.yaml
└── README.md

k8s/
├── 01_image_security.yaml
├── 02_hardening.yaml
├── 03_rbac.yaml
├── 04_admission_controllers.yaml
├── 05_pod_security.yaml
├── 06_runtime_security.yaml
└── README.md

iac/
├── 01_terraform_scanning.yaml
├── 02_policy_as_code.yaml
├── 03_cicd_gates.yaml
├── 04_secrets_management.yaml
├── 05_compliance_validation.yaml
└── README.md

api/
├── 01_gateway_security.yaml
├── 02_jwt_security.yaml
├── 03_rate_limiting.yaml
├── 04_input_validation.yaml
├── 05_api_security_testing.yaml
└── README.md

cicd/
├── 01_sast_dast_sca.yaml
├── 02_container_scanning.yaml
├── 03_pipeline_hardening.yaml
├── 04_policy_enforcement.yaml
├── 05_pipeline_security_tests.yaml
└── README.md
```

**Total Files Created in Part 3: 28+**

---

**[END OF PART 3]**

Part 3: Cloud-Native Security & Modern Workloads is now complete. You have built comprehensive cloud-native security controls for Nexus Global Industries, including multi-cloud security, container/Kubernetes security, IaC security, API security, and DevSecOps CI/CD pipeline security.

### What's Next

**Part 4: Detection Engineering, Security Operations & Operational Resilience** will include:
- SIEM/XDR architecture
- Detection engineering with MITRE ATT&CK
- Threat hunting
- SOAR automation
- Chaos engineering
- Business continuity and resilience
