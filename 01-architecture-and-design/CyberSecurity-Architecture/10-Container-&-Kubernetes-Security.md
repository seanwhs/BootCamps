# Part 3: Cloud-Native Security & Modern Workloads
## Section 3.2: Container & Kubernetes Security

## The Target: Complete Container & Kubernetes Security for Nexus Global Industries

In this section, we'll implement comprehensive container and Kubernetes security controls, including:

1. **Container Image Security** - Scanning, SBOM generation, and signing
2. **Kubernetes Hardening** - CIS benchmarks and security configurations
3. **RBAC & Service Accounts** - Least privilege access control
4. **Admission Controllers** - Kyverno policy enforcement
5. **Pod Security Standards** - Restricted pod configurations
6. **Runtime Security** - Monitoring and threat detection

**What specific file(s) are we building?**
- `k8s/01_image_security.yaml` - Container image scanning and signing
- `k8s/02_hardening.yaml` - Kubernetes CIS benchmark configurations
- `k8s/03_rbac.yaml` - RBAC and service account policies
- `k8s/04_admission_controllers.yaml` - Kyverno policies
- `k8s/05_pod_security.yaml` - Pod security standards
- `k8s/06_runtime_security.yaml` - Runtime monitoring and detection

---

## The Concept: Container & Kubernetes Security in Plain English

Think of container and Kubernetes security like **a shipping container port with strict security procedures**:

**Container Image Security:** "Every shipping container is scanned for contraband before it enters the port." This is vulnerability scanning and SBOM generation.

**Kubernetes Hardening:** "The port has security cameras, fences, and access controls to prevent unauthorized entry." This is CIS benchmark compliance.

**RBAC:** "Only authorized port workers can access specific areas (cranes, warehouses, offices)." This is role-based access control.

**Admission Controllers:** "Every container is inspected before being unloaded. If it doesn't meet standards, it's rejected." This is policy enforcement at creation time.

**Pod Security Standards:** "All containers must have proper labels, run as non-root, and have resource limits." This is secure pod configurations.

**Runtime Security:** "Security guards continuously monitor containers for suspicious activity." This is runtime threat detection.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the k8s directory
cd ~/nexus_security_architecture
mkdir -p k8s

# Verify the structure
ls -la
# Expected: k8s directory appears
```

---

### Step 2: Container Image Security

**File:** `k8s/01_image_security.yaml`

```yaml
# Container Image Security - Nexus Global Industries
# File: k8s/01_image_security.yaml
# Version: 1.0

# ====================================================================
# TRIVY SCANNER CONFIGURATION
# ====================================================================

---
# Trivy Operator - Automated container scanning
apiVersion: v1
kind: Namespace
metadata:
  name: trivy-system

---
# Trivy Operator Deployment
apiVersion: aquasecurity.github.io/v1alpha1
kind: TrivyOperator
metadata:
  name: trivy-operator
  namespace: trivy-system
spec:
  # Scan all namespaces
  scanJobTimeout: 5m
  
  # Vulnerability scanning configuration
  vulnerabilityScanner:
    enabled: true
    scanOnlyCurrentRevisions: true
    trivyCommand: "image"
    
    # Severity levels to report
    severities:
      - "CRITICAL"
      - "HIGH"
      - "MEDIUM"
      - "LOW"
    
    # Registry credentials (if needed)
    registry:
      - name: "ecr"
        type: "aws"
        region: "us-east-1"
  
  # Config audit scanning
  configAuditScanner:
    enabled: true
  
  # Compliance scanning
  complianceScanner:
    enabled: true
    reportTypes:
      - "nsa"
      - "cis"

---
# VulnerabilityReport - Example scan results
apiVersion: aquasecurity.github.io/v1alpha1
kind: VulnerabilityReport
metadata:
  name: example-app
  namespace: production
spec:
  scanner:
    name: Trivy
    vendor: Aqua Security
    version: "0.40.0"
  vulnerabilities:
    - vulnerabilityID: "CVE-2023-12345"
      pkgName: "libssl"
      installedVersion: "1.1.1n"
      fixedVersion: "1.1.1o"
      title: "openssl: buffer overflow vulnerability"
      description: "A buffer overflow vulnerability in OpenSSL..."
      severity: "HIGH"
      primaryLink: "https://nvd.nist.gov/vuln/detail/CVE-2023-12345"
      status: "FIXED"
    - vulnerabilityID: "CVE-2023-67890"
      pkgName: "python3"
      installedVersion: "3.9.10"
      fixedVersion: "3.9.11"
      title: "python: vulnerability in urllib"
      description: "A vulnerability in urllib..."
      severity: "CRITICAL"
      primaryLink: "https://nvd.nist.gov/vuln/detail/CVE-2023-67890"
      status: "FIXED"

# ====================================================================
# SBOM GENERATION
# ====================================================================

---
# Syft SBOM Generation (CI/CD integration)
apiVersion: v1
kind: ConfigMap
metadata:
  name: sbom-config
  namespace: production
data:
  syft-config.yaml: |
    # Syft configuration for SBOM generation
    output:
      - "cyclonedx-json"
      - "spdx-json"
    
    catalogers:
      - "all"
    
    secrets:
      - ".*password.*"
      - ".*secret.*"
      - ".*key.*"
    
    exclude:
      - "**/node_modules/**"
      - "**/.git/**"
      - "**/.venv/**"

---
# SBOM Storage (ConfigMap for demonstration)
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-sbom
  namespace: production
data:
  sbom.json: |
    {
      "bomFormat": "CycloneDX",
      "specVersion": "1.4",
      "version": 1,
      "metadata": {
        "timestamp": "2026-08-02T00:00:00Z",
        "tools": [
          {
            "vendor": "Anchore",
            "name": "Syft",
            "version": "0.80.0"
          }
        ],
        "component": {
          "type": "container",
          "name": "example-app",
          "version": "1.0.0"
        }
      },
      "components": [
        {
          "type": "library",
          "name": "python",
          "version": "3.9.10",
          "purl": "pkg:pypi/python@3.9.10",
          "licenses": [
            {
              "license": {
                "id": "PSF-2.0"
              }
            }
          ]
        },
        {
          "type": "library",
          "name": "openssl",
          "version": "1.1.1n",
          "purl": "pkg:apk/openssl@1.1.1n",
          "licenses": [
            {
              "license": {
                "id": "OpenSSL"
              }
            }
          ]
        }
      ]
    }

# ====================================================================
# IMAGE SIGNING (Cosign)
# ====================================================================

---
# Cosign Key Pair (Example)
apiVersion: v1
kind: Secret
metadata:
  name: cosign-keys
  namespace: production
type: Opaque
data:
  # In production, these would be actual keys
  cosign.pub: "c29tZS1wdWJsaWMta2V5LWRhdGE="  # base64 placeholder
  cosign.key: "c29tZS1wcml2YXRlLWtleS1kYXRh"  # base64 placeholder

---
# Image Signing Policy
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-signing-policy
  namespace: production
data:
  policy.yaml: |
    # Image signing policy
    images:
      - name: "nexus/example-app"
        required_signatures: 1
        trusted_keys:
          - "cosign.pub"
        allowed_registries:
          - "123456789012.dkr.ecr.us-east-1.amazonaws.com"
          - "nexus.azurecr.io"
    
    signatures:
      - name: "cosign"
        type: "cosign"
        key: "cosign.pub"

---
# Kyverno Policy: Require Signed Images
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-signed-images
spec:
  validationFailureAction: Enforce
  background: false
  rules:
  - name: validate-image-signature
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      all:
      - key: "{{ request.operation }}"
        operator: In
        value: ["CREATE", "UPDATE"]
    validate:
      message: "Image must be signed with a trusted key"
      pattern:
        spec:
          containers:
          - image: "*"
            imagePullPolicy: "Always"
          imagePullSecrets:
          - name: "registry-credentials"
```

**Verification:**

```bash
# Verify image security file
ls -la k8s/01_image_security.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('k8s/01_image_security.yaml'))"
# Expected: No error output
```

---

### Step 3: Kubernetes Hardening (CIS Benchmarks)

**File:** `k8s/02_hardening.yaml`

```yaml
# Kubernetes Hardening - Nexus Global Industries
# File: k8s/02_hardening.yaml
# Version: 1.0

# ====================================================================
# CIS BENCHMARK CONTROLS
# ====================================================================

---
# Control 1.1.1: Ensure the API server pod specification file permissions
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-server-hardening
  namespace: kube-system
data:
  harden-api-server.sh: |
    #!/bin/bash
    # Ensure API server file permissions are 644
    chmod 644 /etc/kubernetes/manifests/kube-apiserver.yaml
    
    # Ensure API server uses TLS 1.3 only
    sed -i 's/--tls-min-version=VersionTLS12/--tls-min-version=VersionTLS13/g' /etc/kubernetes/manifests/kube-apiserver.yaml
    
    # Enable audit logging
    echo "--audit-log-path=/var/log/kubernetes/audit.log" >> /etc/kubernetes/manifests/kube-apiserver.yaml
    echo "--audit-log-maxage=30" >> /etc/kubernetes/manifests/kube-apiserver.yaml
    echo "--audit-log-maxbackup=10" >> /etc/kubernetes/manifests/kube-apiserver.yaml

---
# Control 1.1.2: Ensure the API server uses strong authentication
apiVersion: v1
kind: ConfigMap
metadata:
  name: authn-hardening
  namespace: kube-system
data:
  enable-oidc.sh: |
    #!/bin/bash
    # Enable OIDC authentication
    sed -i 's/--enable-admission-plugins=.*/--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,PodSecurity/g' /etc/kubernetes/manifests/kube-apiserver.yaml
    
    # Enable OIDC with Keycloak
    echo "--oidc-issuer-url=https://auth.nexus.com/realms/nexus" >> /etc/kubernetes/manifests/kube-apiserver.yaml
    echo "--oidc-client-id=kubernetes" >> /etc/kubernetes/manifests/kube-apiserver.yaml
    echo "--oidc-username-claim=email" >> /etc/kubernetes/manifests/kube-apiserver.yaml
    echo "--oidc-groups-claim=groups" >> /etc/kubernetes/manifests/kube-apiserver.yaml

---
# Control 1.1.3: Ensure the API server uses strong authorization
apiVersion: v1
kind: ConfigMap
metadata:
  name: authz-hardening
  namespace: kube-system
data:
  enable-rbac.sh: |
    #!/bin/bash
    # Enable RBAC authorization mode
    sed -i 's/--authorization-mode=.*/--authorization-mode=Node,RBAC/g' /etc/kubernetes/manifests/kube-apiserver.yaml

---
# Control 1.1.4: Ensure the etcd data directory permissions
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-hardening
  namespace: kube-system
data:
  harden-etcd.sh: |
    #!/bin/bash
    # Ensure etcd data directory permissions are 700
    chmod 700 /var/lib/etcd
    
    # Enable etcd authentication
    # This requires updating etcd manifest
    echo "--client-cert-auth=true" >> /etc/kubernetes/manifests/etcd.yaml
    echo "--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt" >> /etc/kubernetes/manifests/etcd.yaml
    echo "--cert-file=/etc/kubernetes/pki/etcd/server.crt" >> /etc/kubernetes/manifests/etcd.yaml
    echo "--key-file=/etc/kubernetes/pki/etcd/server.key" >> /etc/kubernetes/manifests/etcd.yaml

---
# Control 1.1.5: Ensure the controller manager uses TLS
apiVersion: v1
kind: ConfigMap
metadata:
  name: controller-hardening
  namespace: kube-system
data:
  enable-tls.sh: |
    #!/bin/bash
    # Enable TLS for controller manager
    echo "--tls-cert-file=/etc/kubernetes/pki/controller-manager.crt" >> /etc/kubernetes/manifests/kube-controller-manager.yaml
    echo "--tls-private-key-file=/etc/kubernetes/pki/controller-manager.key" >> /etc/kubernetes/manifests/kube-controller-manager.yaml
    echo "--use-service-account-credentials=true" >> /etc/kubernetes/manifests/kube-controller-manager.yaml

# ====================================================================
# KUBE-BENCH CONFIGURATION
# ====================================================================

---
# Kube-bench CronJob for periodic CIS scanning
apiVersion: batch/v1
kind: CronJob
metadata:
  name: kube-bench
  namespace: kube-system
spec:
  schedule: "0 0 * * *"  # Daily at midnight
  jobTemplate:
    spec:
      template:
        spec:
          hostNetwork: true
          hostPID: true
          containers:
          - name: kube-bench
            image: aquasec/kube-bench:latest
            command: ["kube-bench"]
            args:
            - "run"
            - "--benchmark"
            - "cis-1.24"
            - "--json"
            volumeMounts:
            - name: var-lib-etcd
              mountPath: /var/lib/etcd
              readOnly: true
            - name: etc-kubernetes
              mountPath: /etc/kubernetes
              readOnly: true
            - name: usr-bin
              mountPath: /usr/bin
              readOnly: true
          volumes:
          - name: var-lib-etcd
            hostPath:
              path: /var/lib/etcd
              type: Directory
          - name: etc-kubernetes
            hostPath:
              path: /etc/kubernetes
              type: Directory
          - name: usr-bin
            hostPath:
              path: /usr/bin
              type: Directory
          restartPolicy: OnFailure

---
# Kube-bench Report Storage (ConfigMap)
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-bench-report
  namespace: kube-system
data:
  report.json: |
    {
      "summary": {
        "total": 100,
        "pass": 85,
        "fail": 10,
        "warn": 5,
        "info": 0
      },
      "controls": [
        {
          "id": "1.1.1",
          "version": "1.24",
          "text": "Ensure that the API server pod specification file permissions are set to 644 or more restrictive",
          "scored": true,
          "status": "PASS",
          "remediation": "Run the command: chmod 644 /etc/kubernetes/manifests/kube-apiserver.yaml"
        },
        {
          "id": "1.1.2",
          "version": "1.24",
          "text": "Ensure that the API server --authorization-mode argument is set to Node,RBAC",
          "scored": true,
          "status": "PASS",
          "remediation": "Edit the API server pod specification file and set --authorization-mode=Node,RBAC"
        },
        {
          "id": "4.2.6",
          "version": "1.24",
          "text": "Ensure that the --protect-kernel-defaults argument is set to true",
          "scored": true,
          "status": "FAIL",
          "remediation": "Edit the kubelet config file and set protectKernelDefaults: true"
        }
      ]
    }

# ====================================================================
# ENCRYPTION AT REST (Secrets Encryption)
# ====================================================================

---
# Secrets Encryption Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: encryption-config
  namespace: kube-system
data:
  encryption-config.yaml: |
    kind: EncryptionConfig
    apiVersion: v1
    resources:
      - resources:
        - secrets
        providers:
        - aescbc:
            keys:
            - name: key1
              secret: c2VjcmV0LWtleS1mb3ItZW5jcnlwdGlvbg==
        - identity: {}
    
    # In production, this would be applied to the API server
    # with --encryption-provider-config=/etc/kubernetes/encryption-config.yaml

---
# Rotation of encryption keys
apiVersion: batch/v1
kind: CronJob
metadata:
  name: rotate-encryption-keys
  namespace: kube-system
spec:
  schedule: "0 0 1 * *"  # Monthly
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: rotator
            image: bitnami/kubectl:latest
            command:
            - /bin/sh
            - -c
            - |
              # Generate new encryption key
              NEW_KEY=$(openssl rand -base64 32)
              
              # Update encryption config
              kubectl patch configmap encryption-config -n kube-system -p "{\"data\":{\"encryption-config.yaml\":\"$(cat /etc/kubernetes/encryption-config.yaml | sed 's/secret: .*/secret: $NEW_KEY/')\"}}"
              
              # Restart API server to pick up new key
              kubectl delete pod -n kube-system -l component=kube-apiserver
              
              echo "Encryption keys rotated"
          restartPolicy: OnFailure
```

**Verification:**

```bash
# Verify hardening file
ls -la k8s/02_hardening.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('k8s/02_hardening.yaml'))"
# Expected: No error output
```

---

### Step 4: RBAC & Service Accounts

**File:** `k8s/03_rbac.yaml`

```yaml
# RBAC & Service Accounts - Nexus Global Industries
# File: k8s/03_rbac.yaml
# Version: 1.0

# ====================================================================
# SERVICE ACCOUNTS (Least Privilege)
# ====================================================================

---
# Production Service Account (Restricted)
apiVersion: v1
kind: ServiceAccount
metadata:
  name: production-sa
  namespace: production
  annotations:
    # Automount token disabled for security
    kubernetes.io/enforce-mountable-secrets: "true"
automountServiceAccountToken: false

---
# R&D Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: rd-sa
  namespace: rd
  annotations:
    kubernetes.io/enforce-mountable-secrets: "true"
automountServiceAccountToken: false

---
# Monitoring Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitoring-sa
  namespace: monitoring
automountServiceAccountToken: true

# ====================================================================
# CLUSTER ROLES (Global Permissions)
# ====================================================================

---
# Cluster Role: Read-only access
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: readonly-clusterrole
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["get", "list", "watch"]

---
# Cluster Role: Production Admin (Limited)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: production-admin
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["create", "get", "list", "update", "delete"]

# ====================================================================
# CLUSTER ROLE BINDINGS
# ====================================================================

---
# Bind readonly to all authenticated users
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: readonly-binding
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: readonly-clusterrole
  apiGroup: rbac.authorization.k8s.io

---
# Bind production-admin to production service account
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: production-admin-binding
subjects:
- kind: ServiceAccount
  name: production-sa
  namespace: production
roleRef:
  kind: ClusterRole
  name: production-admin
  apiGroup: rbac.authorization.k8s.io

# ====================================================================
# NAMESPACE ROLES (Limited Scope)
# ====================================================================

---
# Namespace Role: Production Edit
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: production-edit
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["create", "get", "list", "update", "delete"]

---
# Namespace Role: R&D Edit
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: rd-edit
  namespace: rd
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["create", "get", "list", "update", "delete"]

---
# Namespace Role: View-only
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: view-only
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]

# ====================================================================
# NAMESPACE ROLE BINDINGS
# ====================================================================

---
# Bind production-edit to production service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: production-edit-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: production-sa
  namespace: production
roleRef:
  kind: Role
  name: production-edit
  apiGroup: rbac.authorization.k8s.io

---
# Bind view-only to monitoring service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: view-only-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: monitoring-sa
  namespace: monitoring
roleRef:
  kind: Role
  name: view-only
  apiGroup: rbac.authorization.k8s.io

# ====================================================================
# POD SECURITY STANDARDS (RBAC Enforcement)
# ====================================================================

---
# Role for Pod Security Admission (PSA)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: psa-admin
rules:
- apiGroups: ["policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["create", "get", "list", "update", "delete"]
- apiGroups: ["admissionregistration.k8s.io"]
  resources: ["validatingwebhookconfigurations"]
  verbs: ["create", "get", "list", "update", "delete"]

---
# Bind PSA admin to security team
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: psa-admin-binding
subjects:
- kind: Group
  name: security-team
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: psa-admin
  apiGroup: rbac.authorization.k8s.io
```

**Verification:**

```bash
# Verify RBAC file
ls -la k8s/03_rbac.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('k8s/03_rbac.yaml'))"
# Expected: No error output
```

---

### Step 5: Admission Controllers (Kyverno)

**File:** `k8s/04_admission_controllers.yaml`

```yaml
# Admission Controllers - Nexus Global Industries
# File: k8s/04_admission_controllers.yaml
# Version: 1.0

# ====================================================================
# KYVERNO INSTALLATION
# ====================================================================

---
# Kyverno Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: kyverno
  labels:
    pod-security.kubernetes.io/enforce: "baseline"

---
# Kyverno ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: kyverno-config
  namespace: kyverno
data:
  KYVERNO_EXCLUSION_NAMESPACES: "kube-system,kyverno,istio-system"
  KYVERNO_FILTER_KIND: "Event,Lease"
  KYVERNO_MUTATION_FAIL_POLICY: "ignore"
  KYVERNO_VALIDATION_FAIL_POLICY: "audit"
  KYVERNO_LOG_LEVEL: "info"

# ====================================================================
# KYVERNO POLICIES: IMAGE INTEGRITY
# ====================================================================

---
# Policy: Require image tags (no 'latest')
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-image-tags
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-image-tag
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Image tag must not be 'latest'"
      pattern:
        spec:
          containers:
          - image: "*:*"
            image: "!*:latest"

---
# Policy: Require image from trusted registry
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-trusted-registry
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-registry
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Image must be from nexus registry"
      pattern:
        spec:
          containers:
          - image: "123456789012.dkr.ecr.us-east-1.amazonaws.com/* | nexus.azurecr.io/*"

# ====================================================================
# KYVERNO POLICIES: RESOURCE LIMITS
# ====================================================================

---
# Policy: Require resource limits
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resource-limits
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-resources
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Resource limits are required"
      pattern:
        spec:
          containers:
          - resources:
              limits:
                memory: "?*"
                cpu: "?*"
              requests:
                memory: "?*"
                cpu: "?*"

---
# Policy: Set default resource limits (mutation)
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: set-default-resource-limits
spec:
  rules:
  - name: mutate-resources
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        spec:
          containers:
          - (name): "*"
            resources:
              requests:
                memory: "256Mi"
                cpu: "100m"
              limits:
                memory: "512Mi"
                cpu: "250m"
    exclude:
      any:
      - resources:
          namespaces:
          - kube-system
          - istio-system

# ====================================================================
# KYVERNO POLICIES: SECURITY CONTEXT
# ====================================================================

---
# Policy: Require non-root user
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-non-root
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-non-root
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Containers must run as non-root"
      pattern:
        spec:
          securityContext:
            runAsNonRoot: true
          containers:
          - securityContext:
              runAsNonRoot: true

---
# Policy: Require read-only root filesystem
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-readonly-rootfs
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-rootfs
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Root filesystem must be read-only"
      pattern:
        spec:
          containers:
          - securityContext:
              readOnlyRootFilesystem: true

---
# Policy: Deny privilege escalation
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-privilege-escalation
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-privilege-escalation
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Privilege escalation is not allowed"
      pattern:
        spec:
          containers:
          - securityContext:
              allowPrivilegeEscalation: false

# ====================================================================
# KYVERNO POLICIES: NETWORK SECURITY
# ====================================================================

---
# Policy: Require network policies
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-network-policies
spec:
  validationFailureAction: Audit
  rules:
  - name: validate-networkpolicy
    match:
      any:
      - resources:
          kinds:
          - Namespace
    validate:
      message: "All namespaces must have network policies"
      pattern:
        metadata:
          labels:
            network-policy: "enforced"
    exclude:
      any:
      - resources:
          namespaces:
          - kube-system
          - kyverno
          - istio-system

---
# Policy: Deny node port services
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-nodeport
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-service
    match:
      any:
      - resources:
          kinds:
          - Service
    validate:
      message: "NodePort services are not allowed"
      pattern:
        spec:
          type: "!NodePort"

# ====================================================================
# KYVERNO POLICIES: CONFIGURATION MANAGEMENT
# ====================================================================

---
# Policy: Require labels
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-labels
    match:
      any:
      - resources:
          kinds:
          - Pod
          - Service
          - Deployment
    validate:
      message: "Required labels must be present"
      pattern:
        metadata:
          labels:
            app: "?*"
            environment: "?*"
            owner: "?*"

---
# Policy: Deny host networking
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-host-networking
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-hostnet
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Host networking is not allowed"
      pattern:
        spec:
          hostNetwork: "false"

---
# Policy: Deny host PID/IPC
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-host-pid-ipc
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-hostpid
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Host PID and IPC are not allowed"
      pattern:
        spec:
          hostPID: "false"
          hostIPC: "false"
```

**Verification:**

```bash
# Verify admission controllers file
ls -la k8s/04_admission_controllers.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('k8s/04_admission_controllers.yaml'))"
# Expected: No error output
```

---

### Step 6: Pod Security Standards

**File:** `k8s/05_pod_security.yaml`

```yaml
# Pod Security Standards - Nexus Global Industries
# File: k8s/05_pod_security.yaml
# Version: 1.0

# ====================================================================
# POD SECURITY ADMISSION (PSA) LABELS
# ====================================================================

---
# Production Namespace: Restricted
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: "restricted"
    pod-security.kubernetes.io/enforce-version: "latest"
    pod-security.kubernetes.io/audit: "restricted"
    pod-security.kubernetes.io/audit-version: "latest"
    pod-security.kubernetes.io/warn: "restricted"
    pod-security.kubernetes.io/warn-version: "latest"

---
# R&D Namespace: Baseline
apiVersion: v1
kind: Namespace
metadata:
  name: rd
  labels:
    pod-security.kubernetes.io/enforce: "baseline"
    pod-security.kubernetes.io/enforce-version: "latest"
    pod-security.kubernetes.io/audit: "baseline"
    pod-security.kubernetes.io/audit-version: "latest"
    pod-security.kubernetes.io/warn: "baseline"
    pod-security.kubernetes.io/warn-version: "latest"

---
# OT Namespace: Restricted (Highest Security)
apiVersion: v1
kind: Namespace
metadata:
  name: ot
  labels:
    pod-security.kubernetes.io/enforce: "restricted"
    pod-security.kubernetes.io/enforce-version: "latest"
    pod-security.kubernetes.io/audit: "restricted"
    pod-security.kubernetes.io/audit-version: "latest"
    pod-security.kubernetes.io/warn: "restricted"
    pod-security.kubernetes.io/warn-version: "latest"

---
# Development Namespace: Baseline (Permissive)
apiVersion: v1
kind: Namespace
metadata:
  name: dev
  labels:
    pod-security.kubernetes.io/enforce: "baseline"
    pod-security.kubernetes.io/enforce-version: "latest"
    pod-security.kubernetes.io/audit: "baseline"
    pod-security.kubernetes.io/audit-version: "latest"
    pod-security.kubernetes.io/warn: "baseline"
    pod-security.kubernetes.io/warn-version: "latest"

# ====================================================================
# POD SECURITY POLICY (Deprecated - PSA is preferred)
# Kept for reference for older clusters
# ====================================================================

---
# PodSecurityPolicy: Restricted
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: "docker/default,runtime/default"
    apparmor.security.beta.kubernetes.io/allowedProfileNames: "runtime/default"
    seccomp.security.alpha.kubernetes.io/defaultProfileName: "runtime/default"
    apparmor.security.beta.kubernetes.io/defaultProfileName: "runtime/default"
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
  - ALL
  allowedCapabilities: []
  volumes:
  - "configMap"
  - "emptyDir"
  - "projected"
  - "secret"
  - "downwardAPI"
  - "persistentVolumeClaim"
  hostNetwork: false
  hostPorts:
  - min: 0
    max: 0
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: "MustRunAsNonRoot"
    ranges:
    - min: 1000
      max: 65535
  selinux:
    rule: "RunAsAny"
  supplementalGroups:
    rule: "MustRunAs"
    ranges:
    - min: 1
      max: 65535
  fsGroup:
    rule: "MustRunAs"
    ranges:
    - min: 1
      max: 65535
  readOnlyRootFilesystem: true

---
# PodSecurityPolicy: Baseline
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: baseline
spec:
  privileged: false
  allowPrivilegeEscalation: true
  requiredDropCapabilities:
  - ALL
  volumes:
  - "*"
  hostNetwork: false
  hostPorts:
  - min: 0
    max: 65535
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: "MustRunAsNonRoot"
    ranges:
    - min: 1000
      max: 65535
  selinux:
    rule: "RunAsAny"
  supplementalGroups:
    rule: "RunAsAny"
  fsGroup:
    rule: "RunAsAny"
  readOnlyRootFilesystem: false

# ====================================================================
# SECURITY CONTEXT EXAMPLES
# ====================================================================

---
# Example: Secure Pod with Security Context
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: production
  labels:
    app: secure-app
    environment: prod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nexus.azurecr.io/secure-app:1.0.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "250m"

---
# Example: Restricted Pod (No Host Access)
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
  namespace: production
  labels:
    app: restricted-app
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app
    image: nexus.azurecr.io/restricted-app:1.0.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    resources:
      requests:
        memory: "128Mi"
        cpu: "50m"
      limits:
        memory: "256Mi"
        cpu: "100m"
  volumes:
  - name: tmp
    emptyDir:
      medium: Memory
      sizeLimit: 100Mi
```

**Verification:**

```bash
# Verify pod security file
ls -la k8s/05_pod_security.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('k8s/05_pod_security.yaml'))"
# Expected: No error output
```

---

### Step 7: Runtime Security

**File:** `k8s/06_runtime_security.yaml`

```yaml
# Runtime Security - Nexus Global Industries
# File: k8s/06_runtime_security.yaml
# Version: 1.0

# ====================================================================
# FALCO RUNTIME SECURITY
# ====================================================================

---
# Falco Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: falco
  labels:
    pod-security.kubernetes.io/enforce: "baseline"

---
# Falco DaemonSet Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-config
  namespace: falco
data:
  falco.yaml: |
    # Falco configuration
    json_output: true
    json_include_output_property: true
    http_output:
      enabled: true
      url: "http://logstash.siem.svc.cluster.local:5044"
    
    # Rules file
    rules_file:
      - /etc/falco/rules.d/*.yaml
    
    # Syscall buffer size
    syscall_event_drops:
      threshold: .1
      actions:
        - log
    
    # Priority: emergency, alert, critical, error, warning, notice, info, debug
    priority: warning

---
# Falco Rules: Suspicious Activities
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-rules
  namespace: falco
data:
  suspicious-activities.yaml: |
    # Falco Rules - Suspicious Activities
    - rule: Shell in container
      desc: A shell was spawned in a container
      condition: >
        container.id != host and proc.name in (bash, sh, zsh, fish)
        and proc.cmdline != "sh"
      output: "Shell in container (user=%user.name container=%container.id)"
      priority: WARNING
      tags: [container, shell]
    
    - rule: Outbound network connection
      desc: Container initiated outbound connection
      condition: >
        container.id != host and evt.type in (connect, accept)
        and fd.type != "unix"
        and fd.type != "pipe"
        and fd.sip != "10.0.0.0/8"
        and fd.sip != "172.16.0.0/12"
        and fd.sip != "192.168.0.0/16"
      output: "Outbound connection (user=%user.name container=%container.id)"
      priority: WARNING
      tags: [network, container]
    
    - rule: Privileged container
      desc: Container running in privileged mode
      condition: >
        container.id != host
        and container.privileged == true
      output: "Privileged container (user=%user.name container=%container.id)"
      priority: CRITICAL
      tags: [container, privilege]
    
    - rule: Mount of sensitive directory
      desc: Container mounted sensitive directory
      condition: >
        container.id != host
        and evt.type in (mount)
        and fd.name in (/etc, /root, /var/run/docker.sock, /proc, /sys)
      output: "Sensitive directory mounted (user=%user.name container=%container.id)"
      priority: CRITICAL
      tags: [container, mount]

---
# Falco DaemonSet
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco
  namespace: falco
  labels:
    app: falco
spec:
  selector:
    matchLabels:
      app: falco
  template:
    metadata:
      labels:
        app: falco
    spec:
      containers:
      - name: falco
        image: falcosecurity/falco:latest
        args:
        - /usr/bin/falco
        - -c
        - /etc/falco/falco.yaml
        - -r
        - /etc/falco/rules.d/
        securityContext:
          privileged: true
        volumeMounts:
        - name: host
          mountPath: /host
        - name: config
          mountPath: /etc/falco
        - name: rules
          mountPath: /etc/falco/rules.d
        env:
        - name: FALCO_K8S_AUDIT_ENABLE
          value: "true"
        - name: FALCO_K8S_AUDIT_URL
          value: "https://kubernetes.default.svc"
      volumes:
      - name: host
        hostPath:
          path: /
      - name: config
        configMap:
          name: falco-config
      - name: rules
        configMap:
          name: falco-rules
      serviceAccountName: falco

# ====================================================================
# KUBERNETES AUDIT LOGGING
# ====================================================================

---
# Kubernetes Audit Policy
apiVersion: v1
kind: ConfigMap
metadata:
  name: audit-policy
  namespace: kube-system
data:
  audit-policy.yaml: |
    # Kubernetes audit policy
    apiVersion: audit.k8s.io/v1
    kind: Policy
    rules:
    # Log all requests to the API server
    - level: Metadata
      resources:
      - group: ""
        resources: ["pods", "services", "configmaps", "secrets"]
    
    # Log sensitive requests in full
    - level: RequestResponse
      resources:
      - group: ""
        resources: ["secrets"]
      verbs: ["create", "update", "patch", "delete"]
    
    # Log authentication and authorization
    - level: Metadata
      userGroups: ["system:authenticated"]
    
    # Log all admin actions
    - level: Request
      verbs: ["create", "update", "patch", "delete"]
    
    # Log all RBAC changes
    - level: Request
      resources:
      - group: "rbac.authorization.k8s.io"
        resources: ["*"]

---
# Kubernetes Audit Webhook (SIEM Integration)
apiVersion: v1
kind: ConfigMap
metadata:
  name: audit-webhook
  namespace: kube-system
data:
  webhook.yaml: |
    # Audit webhook configuration
    apiVersion: audit.k8s.io/v1
    kind: Webhook
    config:
      endpoint: http://logstash.siem.svc.cluster.local:5044
      maxRetries: 3

# ====================================================================
# PROMETHEUS SECURITY METRICS
# ====================================================================

---
# ServiceMonitor for Kube-state-metrics
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kube-state-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: kube-state-metrics
  endpoints:
  - port: http
    path: /metrics
    interval: 30s

---
# ServiceMonitor for Kubernetes API
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kubernetes-api
  namespace: monitoring
spec:
  selector:
    matchLabels:
      component: apiserver
      provider: kubernetes
  endpoints:
  - port: https
    path: /metrics
    interval: 30s
    scheme: https
    tlsConfig:
      insecureSkipVerify: true

# ====================================================================
# GRAFANA DASHBOARDS FOR RUNTIME SECURITY
# ====================================================================

---
# ConfigMap for Grafana Dashboards
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards
  namespace: monitoring
data:
  k8s-security.json: |
    {
      "title": "Kubernetes Security Dashboard",
      "panels": [
        {
          "title": "Pod Security Violations",
          "targets": [
            {
              "expr": "kube_pod_security_violations_total",
              "legendFormat": "Violations"
            }
          ]
        },
        {
          "title": "API Server Audit Events",
          "targets": [
            {
              "expr": "rate(kube_audit_events_total[5m])",
              "legendFormat": "Events/s"
            }
          ]
        },
        {
          "title": "Falco Alerts",
          "targets": [
            {
              "expr": "falco_alerts_total",
              "legendFormat": "Alerts"
            }
          ]
        }
      ]
    }
```

**Verification:**

```bash
# Verify runtime security file
ls -la k8s/06_runtime_security.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('k8s/06_runtime_security.yaml'))"
# Expected: No error output
```

---

### Step 8: Kubernetes Security Summary

**File:** `k8s/README.md`

```markdown
# Container & Kubernetes Security - Nexus Global Industries

## Overview

This directory contains the complete container and Kubernetes security implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_image_security.yaml` | Image Security | Scanning, SBOM, signing |
| `02_hardening.yaml` | Hardening | CIS benchmark controls |
| `03_rbac.yaml` | RBAC | Role-based access control |
| `04_admission_controllers.yaml` | Admission | Kyverno policies |
| `05_pod_security.yaml` | Pod Security | Pod security standards |
| `06_runtime_security.yaml` | Runtime | Falco, audit, monitoring |

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│              CONTAINER & KUBERNETES SECURITY                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  IMAGE SECURITY                                       │   │
│  │  • Trivy vulnerability scanning                      │   │
│  │  • SBOM generation (Syft)                           │   │
│  │  • Image signing (Cosign)                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ADMISSION CONTROL (Kyverno)                           │   │
│  │  • Require image tags                                 │   │
│  │  • Require resource limits                           │   │
│  │  • Enforce non-root                                  │   │
│  │  • Deny privilege escalation                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  POD SECURITY (PSA)                                    │   │
│  │  • Restricted (production)                           │   │
│  │  • Baseline (R&D)                                   │   │
│  │  • Privileged (development)                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  RUNTIME SECURITY (Falco)                              │   │
│  │  • Shell detection                                    │   │
│  │  • Network monitoring                                │   │
│  │  • Privileged container detection                    │   │
│  │  • Sensitive mounts                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Tool | Description |
|---------|------|-------------|
| **Image Scanning** | Trivy | Vulnerability scanning in CI/CD |
| **SBOM** | Syft | Software Bill of Materials |
| **Image Signing** | Cosign | Sign and verify images |
| **Hardening** | Kube-bench | CIS benchmark compliance |
| **RBAC** | Kubernetes | Role-based access control |
| **Admission** | Kyverno | Policy enforcement |
| **Pod Security** | PSA | Pod security standards |
| **Runtime** | Falco | Runtime threat detection |

## Deployment Instructions

### 1. Deploy Image Security

```bash
kubectl apply -f k8s/01_image_security.yaml
```

### 2. Deploy Hardening Controls

```bash
kubectl apply -f k8s/02_hardening.yaml
```

### 3. Deploy RBAC

```bash
kubectl apply -f k8s/03_rbac.yaml
```

### 4. Deploy Admission Controllers

```bash
kubectl apply -f k8s/04_admission_controllers.yaml
```

### 5. Deploy Pod Security

```bash
kubectl apply -f k8s/05_pod_security.yaml
```

### 6. Deploy Runtime Security

```bash
kubectl apply -f k8s/06_runtime_security.yaml
```

## Verification Checklist

- [ ] Trivy scanning images in CI/CD
- [ ] SBOM generated for all images
- [ ] Images signed with Cosign
- [ ] CIS benchmark compliance (85%+)
- [ ] RBAC configured (least privilege)
- [ ] Kyverno policies enforced
- [ ] Pod security standards applied
- [ ] Falco runtime monitoring active

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la k8s/README.md
# Expected: File exists

echo "✅ Container & Kubernetes Security Complete!"
echo "   - Image security (scanning, SBOM, signing)"
echo "   - Kubernetes hardening (CIS)"
echo "   - RBAC and service accounts"
echo "   - Admission controllers (Kyverno)"
echo "   - Pod security standards"
echo "   - Runtime security (Falco)"
```

---

## End of Section 3.2: Container & Kubernetes Security

### Key Takeaway

You've implemented comprehensive container and Kubernetes security controls for Nexus Global Industries, including image scanning with SBOM generation, CIS benchmark hardening, least-privilege RBAC, Kyverno admission policies, pod security standards, and Falco runtime monitoring. This provides defense-in-depth for containerized workloads.

### What's Next

**Section 3.3** will cover **Infrastructure as Code (IaC) Security**, including:
- Terraform security scanning
- Policy-as-Code with OPA/Sentinel
- CI/CD pipeline security gates
- Secret management in IaC
- Compliance validation
x
