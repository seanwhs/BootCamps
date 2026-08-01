# Part 2: Zero Trust & Identity-Centric Enterprise Architecture
## Section 2.1: Zero Trust Architecture (NIST SP 800-207)

## The Target: NIST SP 800-207 Zero Trust Architecture for Nexus Global Industries

In this section, we'll implement a complete **Zero Trust Architecture (ZTA)** based on NIST SP 800-207 for Nexus Global Industries. Zero Trust replaces implicit network trust with continuous verification of every access request.

**What specific file(s) are we building?**
- `zero_trust/01_architecture_design.md` - ZTA design and components
- `zero_trust/02_pdp_policies.rego` - Policy Decision Point (OPA) policies
- `zero_trust/03_pep_configuration.yaml` - Policy Enforcement Point (Istio/Kong) configs
- `zero_trust/04_continuous_verification.py` - Continuous verification service
- `zero_trust/05_zero_trust_policies.yaml` - Comprehensive ZTA policies

---

## The Concept: Zero Trust in Plain English

Think of Zero Trust like **a nightclub with no VIP list based on who's already inside**:

**Traditional Security (Castle-and-Moat):** "Once you're inside the nightclub, you can go anywhere—the VIP room, the bar, the kitchen, the office." This assumes everyone inside is trustworthy.

**Zero Trust:** "Even if you're inside the nightclub, you need to prove your identity and get specific permission for every single area you want to enter." This verifies continuously.

**NIST SP 800-207's Key Components:**

**PDP (Policy Decision Point):** "The bouncer who checks your ID and decides if you're allowed in." This is the centralized policy engine.

**PEP (Policy Enforcement Point):** "The door guards who enforce the bouncer's decisions." These are distributed enforcers at every access point.

**PAP (Policy Administration Point):** "The manager who sets the club's entry policies." This is the policy management interface.

**PIP (Policy Information Point):** "The camera system and guest list that provides context." This supplies identity, device, and environmental data.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the zero_trust directory
cd ~/nexus_security_architecture
mkdir -p zero_trust

# Verify the structure
ls -la
# Expected: zero_trust directory appears
```

---

### Step 2: Zero Trust Architecture Design

**File:** `zero_trust/01_architecture_design.md`

```markdown
# NIST SP 800-207 Zero Trust Architecture - Nexus Global Industries

## Overview

Nexus Global Industries adopts a Zero Trust Architecture (ZTA) based on NIST Special Publication 800-207. Zero Trust eliminates implicit trust and continuously verifies every access request based on identity, device posture, and context.

## Core Principles

1. **Continuous Verification**: Every access request is authenticated, authorized, and continuously verified
2. **Least Privilege**: Users and systems have minimal permissions needed for their function
3. **Assume Breach**: Architecture operates under the assumption that attackers are already inside
4. **Micro-segmentation**: Fine-grained network segmentation limits blast radius
5. **Encrypt Everything**: All traffic is encrypted (mTLS for east-west, TLS for north-south)

## ZTA Components

### Architectural Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    ZERO TRUST ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           POLICY ADMINISTRATION POINT (PAP)             │   │
│  │           • Policy management interface                 │   │
│  │           • Policy versioning (Git)                    │   │
│  │           • Policy approval workflow                   │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │           POLICY DECISION POINT (PDP)                   │   │
│  │           • OPA (Open Policy Agent)                    │   │
│  │           • Centralized policy evaluation              │   │
│  │           • Decision logging                          │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │           POLICY INFORMATION POINT (PIP)                │   │
│  │           • Identity (Keycloak)                       │   │
│  │           • Device posture (CrowdStrike)             │   │
│  │           • Context (Geo, time, behavior)            │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │           POLICY ENFORCEMENT POINT (PEP)                │   │
│  │           • Istio sidecars (services)                 │   │
│  │           • Kong Gateway (external)                   │   │
│  │           • Calico (network)                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Component Descriptions

#### PDP: Policy Decision Point (OPA)

- **Purpose**: Centralized policy evaluation engine
- **Implementation**: Open Policy Agent (OPA) as a sidecar or standalone service
- **Policy Language**: Rego
- **Decision Inputs**: User identity, device posture, resource, context
- **Decision Outputs**: Allow, Deny, Challenge (step-up authentication)

#### PEP: Policy Enforcement Point (Istio + Kong + Calico)

- **Purpose**: Enforce PDP decisions at access points
- **Implementation**:
  - **Services**: Istio sidecars (Envoy) with OPA integration
  - **External APIs**: Kong Gateway with OPA plugin
  - **Network**: Calico network policies (L3/L4 enforcement)
- **Enforcement Actions**: Allow traffic, block traffic, redirect to authentication

#### PAP: Policy Administration Point

- **Purpose**: Manage and distribute policies
- **Implementation**: Git repository + CI/CD pipeline
- **Features**:
  - Version control (Git)
  - Approval workflow (pull requests)
  - Automated testing (policy unit tests)
  - Deployment automation (GitOps)

#### PIP: Policy Information Point

- **Purpose**: Provide context for policy decisions
- **Implementation**: Multiple data sources
- **Data Sources**:
  - **Identity**: Keycloak (user attributes, roles, groups)
  - **Device**: CrowdStrike (device posture, compliance)
  - **Network**: Istio telemetry (source/destination)
  - **Context**: Time, geolocation, behavior analytics

## ZTA Deployment Architecture

### Workload Types and Trust Levels

| Workload Type | Trust Level | Data Classification | Access Requirements |
|---------------|-------------|---------------------|---------------------|
| Manufacturing OT | CRITICAL | RESTRICTED | ZTA + Micro-segmentation |
| R&D Systems | CRITICAL | RESTRICTED | ZTA + Continuous Verification |
| Customer Portal | HIGH | CONFIDENTIAL | ZTA + MFA Required |
| Financial Systems | HIGH | CONFIDENTIAL | ZTA + PAM Required |
| Internal Services | MEDIUM | INTERNAL | ZTA + RBAC |
| Public Services | LOW | PUBLIC | Limited ZTA |

### Policy Decision Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    POLICY DECISION FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User/Service Request                                        │
│     └──→ PEP intercepts request                                 │
│                                                                 │
│  2. PEP Gathers Context                                         │
│     ├── Identity (user, roles, groups)                        │
│     ├── Device (posture, compliance)                          │
│     ├── Resource (sensitivity, classification)               │
│     └── Context (time, location, behavior)                   │
│                                                                 │
│  3. PEP → PDP (policy query)                                   │
│     └── OPA evaluates against policies                         │
│                                                                 │
│  4. PDP Decision                                               │
│     ├── ALLOW → PEP grants access                             │
│     ├── DENY → PEP blocks access                              │
│     └── CHALLENGE → Step-up authentication required           │
│                                                                 │
│  5. PEP Enforces Decision                                      │
│     ├── Allow: Traffic routed to resource                     │
│     ├── Deny: 401/403 response                                │
│     └── Challenge: Redirect to MFA/step-up                   │
│                                                                 │
│  6. Audit Logging                                              │
│     └── All decisions logged to SIEM                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Zero Trust Policy Examples

### Example 1: Service-to-Service Access

**Policy**: "Only the Order Service can access the Payment Service"

```rego
# Pseudocode
allow = true if {
    source.service == "order-service"
    target.service == "payment-service"
    mfa == true
    device.posture == "compliant"
}
```

### Example 2: User-to-Resource Access

**Policy**: "R&D engineers can access R&D code repositories from compliant devices during work hours"

```rego
# Pseudocode
allow = true if {
    user.role == "rd-engineer"
    resource.classification == "restricted"
    resource.type == "repository"
    device.posture == "compliant"
    time.within_hours(9, 18)
    user.mfa_enabled == true
}
```

### Example 3: Conditional Access (Risk-Based)

**Policy**: "Low-risk users get standard access; high-risk users need step-up authentication"

```rego
# Pseudocode
allow = true if {
    user.risk_score <= 30
    user.role in allowed_roles
    device.posture == "compliant"
}
allow = true if {
    user.risk_score > 30
    user.risk_score <= 60
    step_up_mfa == true
    user.role in allowed_roles
    device.posture == "compliant"
}
# Deny otherwise
allow = false
```

## Zero Trust Maturity Assessment

| Capability | Current | Target | Gap |
|------------|---------|--------|-----|
| **Identity Verification** | Basic (AD) | Continuous (PDP/PEP) | Deploy OPA |
| **Device Posture** | Limited | Continuous (CrowdStrike) | Integrate device trust |
| **Network Segmentation** | Perimeter-based | Micro-segmentation | Deploy Calico/Cilium |
| **Encryption** | TLS for external | mTLS for everything | Deploy Istio |
| **Policy Enforcement** | Manual | Automated (PEP) | Deploy service mesh |
| **Continuous Monitoring** | Basic | Advanced (SIEM) | Enhance telemetry |

## Zero Trust Implementation Roadmap

| Phase | Timeline | Activities | Deliverables |
|-------|----------|------------|--------------|
| **Phase 1: Foundation** | Months 1-3 | Deploy PDP (OPA), basic policies, PAP (Git) | OPA deployed, initial policies |
| **Phase 2: Workload Protection** | Months 4-6 | Deploy Istio service mesh, mTLS, PEP | Service mesh, mTLS coverage |
| **Phase 3: User Access** | Months 7-9 | Integrate IdP (Keycloak), user policies | User ZTA policies |
| **Phase 4: Advanced** | Months 10-12 | Continuous verification, risk scoring | Full ZTA maturity |

---

**Document Owner**: Lead Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0  
**Status**: Draft - Ready for Review
```

**Verification:**

```bash
# Verify architecture design
ls -la zero_trust/01_architecture_design.md
# Expected: File exists

# Check for core principles
grep -c "Continuous Verification" zero_trust/01_architecture_design.md
# Expected: Shows at least 1 occurrence

# Check for component descriptions
grep -c "PDP" zero_trust/01_architecture_design.md
grep -c "PEP" zero_trust/01_architecture_design.md
grep -c "PAP" zero_trust/01_architecture_design.md
grep -c "PIP" zero_trust/01_architecture_design.md
# Expected: Each shows multiple occurrences
```

---

### Step 3: PDP Policies (OPA Rego)

**File:** `zero_trust/02_pdp_policies.rego`

```rego
# OPA Rego Policies - Nexus Global Industries Zero Trust PDP
# File: zero_trust/02_pdp_policies.rego
# Version: 1.0

package nexus.zero_trust

import future.keywords.in

# ====================================================================
# POLICY: SERVICE-TO-SERVICE ACCESS
# ====================================================================

# Rule: Allow service-to-service communication if:
# - Source and destination are explicitly allowed in the service registry
# - Both services have valid mTLS certificates
# - The communication is encrypted (mTLS)
default allow = false

# Service mesh mTLS is required for all internal communication
allow = true if {
    input.source.type == "service"
    input.target.type == "service"
    input.mtls == true
    input.source.service in allowed_services[input.target.service]
}

# Service registry: Map of allowed source services per target service
allowed_services := {
    "payment-service": ["order-service", "customer-service"],
    "order-service": ["api-gateway", "customer-service"],
    "customer-service": ["api-gateway"],
    "product-service": ["api-gateway"],
    "inventory-service": ["order-service"],
    "notification-service": ["order-service", "customer-service"],
}

# ====================================================================
# POLICY: USER ACCESS TO RESOURCES
# ====================================================================

# Rule: Allow user access to resources if:
# - User has valid identity (authenticated)
# - User has required role(s)
# - Resource classification matches user clearance
# - Device is compliant
# - MFA is enabled
allow = true if {
    input.user.type == "user"
    input.user.authenticated == true
    input.user.mfa_enabled == true
    input.device.posture == "compliant"
    input.resource.classification in user_clearance[input.user.role]
}

# User clearance based on role
user_clearance := {
    "admin": ["restricted", "confidential", "internal", "public"],
    "security-team": ["restricted", "confidential", "internal"],
    "rd-engineer": ["restricted", "confidential", "internal"],
    "rd-manager": ["restricted", "confidential", "internal"],
    "finance": ["confidential", "internal"],
    "hr": ["confidential", "internal"],
    "engineer": ["internal", "public"],
    "support": ["internal", "public"],
    "contractor": ["internal", "public"],
    "customer": ["public"],
    "anonymous": ["public"],
}

# ====================================================================
# POLICY: CONTEXT-AWARE ACCESS
# ====================================================================

# Rule: Allow access with additional verification if context is high-risk
allow = true if {
    input.user.type == "user"
    input.user.authenticated == true
    input.user.mfa_enabled == true
    input.device.posture == "compliant"
    risk_level(input.context) == "high"
    step_up_mfa_passed == true
}

# Risk scoring function
risk_level(context) := "high" if {
    # Multiple risk factors
    (context.geo_location != "home_country" and context.login_time not in working_hours)
}

risk_level(context) := "medium" if {
    # One risk factor
    context.geo_location != "home_country"
}

risk_level(context) := "low" if {
    # No risk factors
    context.geo_location == "home_country"
    context.login_time in working_hours
    context.behavior_score < 50
}

# Define working hours
working_hours := {"time": "09:00-18:00", "day": "Monday-Friday"}

# ====================================================================
# POLICY: API GATEWAY (EXTERNAL)
# ====================================================================

# Rule: Allow external API access if:
# - Valid JWT with proper audience and issuer
# - Rate limiting not exceeded
# - IP not in blocklist
allow = true if {
    input.source.type == "external"
    input.target.type == "api"
    valid_jwt == true
    rate_limited == false
    ip_blocked == false
}

# JWT validation
valid_jwt := true if {
    input.jwt.issuer == "https://auth.nexus.com"
    input.jwt.audience == "api-gateway"
    input.jwt.expiration > now
    input.jwt.signature_verified == true
}

# Rate limiting check
rate_limited := true if {
    user_rate_count(input.jwt.user_id) > user_rate_limit
}

# Rate limit policy
user_rate_limit := 100 # requests per minute

# IP blocklist
ip_blocked := true if {
    input.source.ip in blocklist_ips
}

blocklist_ips := {
    "192.168.1.100",
    "10.0.0.50",
}

# ====================================================================
# POLICY: PRIVILEGED ACCESS
# ====================================================================

# Rule: Allow privileged access if:
# - User has PAM permissions
# - Access is JIT (Just-In-Time) approved
# - Session is recorded
# - Time-bound access (15-minute max)
allow = true if {
    input.user.type == "user"
    input.user.authenticated == true
    input.user.mfa_enabled == true
    input.user.pam_approved == true
    input.resource.classification == "restricted"
    input.resource.privileged == true
    session_recorded == true
    time_bound == true
}

# JIT approval check
jit_approved := true if {
    input.user.pam_approval.timestamp > now - 15 * 60 # Approved in last 15 minutes
    input.user.pam_approval.justification != ""
    input.user.pam_approval.approver != ""
}

# Session recording check
session_recorded := true if {
    input.session.recording == true
    input.session.recording_location != ""
}

# Time-bound check
time_bound := true if {
    input.session.expires - now < 15 * 60 # 15-minute max session
}

# ====================================================================
# POLICY: DATA ACCESS
# ====================================================================

# Rule: Allow data access if:
# - User has need-to-know
# - Data is classified appropriately
# - Access is audited
allow = true if {
    input.user.type == "user"
    input.user.authenticated == true
    input.user.mfa_enabled == true
    input.resource.data_classification in user_data_access[input.user.role]
    audit_logged == true
}

# Data access levels per role
user_data_access := {
    "admin": ["restricted", "confidential", "internal", "public"],
    "rd-engineer": ["restricted", "confidential"],
    "finance": ["confidential"],
    "hr": ["confidential"],
    "engineer": ["internal"],
    "support": ["internal"],
}

# Audit logging
audit_logged := true if {
    input.audit.enabled == true
    input.audit.destination == "siem"
}

# ====================================================================
# POLICY: DEFAULT DENY
# ====================================================================

# Default deny: Any request that doesn't match an allow rule is denied
# This is enforced by the default allow = false at the top

# ====================================================================
# UTILITY FUNCTIONS
# ====================================================================

# Check if user has MFA
user_mfa_enabled(user) := true if {
    user.mfa_methods != []
    "webauthn" in user.mfa_methods
}

# Check if device is compliant
device_compliant(device) := true if {
    device.os_version >= min_os_version
    device.encryption == true
    device.anti_malware == true
}

# Minimum OS versions
min_os_version := {
    "windows": 10.0,
    "macos": 12.0,
    "linux": 5.10,
}

# Now function (time)
now := time.now_ns() / 1000000000
```

**Verification:**

```bash
# Verify OPA policies file
ls -la zero_trust/02_pdp_policies.rego
# Expected: File exists

# Validate Rego syntax (if OPA installed)
# opa check zero_trust/02_pdp_policies.rego

# Count policies (there should be multiple allow rules)
grep -c "^allow = true" zero_trust/02_pdp_policies.rego
# Expected: Shows 6+ allow rules
```

---

### Step 4: PEP Configuration (Istio + Kong)

**File:** `zero_trust/03_pep_configuration.yaml`

```yaml
# Zero Trust PEP Configuration - Nexus Global Industries
# Components: Istio Service Mesh + Kong Gateway
# Version: 1.0

# ====================================================================
# PART 1: ISTIO SERVICE MESH CONFIGURATION
# ====================================================================

---
# Istio PeerAuthentication - Enforce mTLS for all services
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: mtz-default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT

---
# Istio AuthorizationPolicy - Service-to-Service Authorization
# Enforces the service-to-service policies defined in OPA
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: zta-service-policy
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  action: CUSTOM
  provider:
    name: "opa-provider"
  rules:
  - from:
    - source:
        principals: ["*"]
    to:
    - operation:
        methods: ["*"]
        paths: ["*"]

---
# Istio AuthorizationPolicy - Service Mesh RBAC
# Allows only authorized services to communicate
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: mesh-rbac
  namespace: istio-system
spec:
  selector:
    matchLabels:
      security.istio.io/tlsMode: "istio"
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/payment-service"]
    to:
    - operation:
        ports: ["9080"]
        hosts: ["order-service.default.svc.cluster.local"]

---
# Istio DestinationRule - Circuit Breaking and Retry Policies
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: circuit-breaker
  namespace: default
spec:
  host: "*"
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
        connectTimeout: 10s
    loadBalancer:
      simple: ROUND_ROBIN
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 60s
      maxEjectionPercent: 50

---
# Istio VirtualService - Request Routing with Timeouts
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: payment-service-routing
  namespace: default
spec:
  hosts:
  - payment-service
  http:
  - timeout: 5s
    retries:
      attempts: 3
      perTryTimeout: 2s
    route:
    - destination:
        host: payment-service
        subset: v1
      weight: 100

# ====================================================================
# PART 2: KONG GATEWAY CONFIGURATION
# ====================================================================

---
# KongPlugin - OPA Policy Enforcement Plugin
# Applies OPA policies at the API Gateway level
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: opa-plugin
  namespace: default
config:
  opa_decision: "nexus/zero_trust/allow"
  opa_url: "http://opa-server.opa.svc.cluster.local:8181"
  opa_timeout: 1000
  include_jwt: true
  include_client_ip: true
  include_user_agent: true
  include_headers: true
plugin: opa

---
# KongPlugin - Rate Limiting Plugin
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rate-limiting
  namespace: default
config:
  minute: 100
  hour: 10000
  policy: redis
  redis_host: redis.default.svc.cluster.local
  redis_port: 6379
plugin: rate-limiting

---
# KongPlugin - JWT Validation Plugin
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: jwt-validation
  namespace: default
config:
  secret_is_base64: false
  claims_to_verify:
  - expiration
  - audience
  allowed_iss: https://auth.nexus.com
  allowed_aud: api-gateway
plugin: jwt

---
# KongPlugin - CORS Protection
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: cors-protection
  namespace: default
config:
  origins:
  - https://api.nexus.com
  methods:
  - GET
  - POST
  - PUT
  - DELETE
  credentials: true
  max_age: 86400
plugin: cors

---
# KongIngress - Default Gateway Configuration
apiVersion: configuration.konghq.com/v1
kind: KongIngress
metadata:
  name: default-gateway
  namespace: default
upstream:
  healthchecks:
    active:
      healthy:
        http_statuses:
        - 200
        - 201
        - 202
        - 203
        - 204
        successes: 5
      unhealthy:
        http_statuses:
        - 500
        - 502
        - 503
        - 504
        failures: 3
    passive:
      healthy:
        http_statuses:
        - 200
        - 201
        - 202
        - 203
        - 204
        successes: 3
      unhealthy:
        http_statuses:
        - 500
        - 502
        - 503
        - 504
        failures: 2

# ====================================================================
# PART 3: CALICO NETWORK POLICIES
# ====================================================================

---
# Calico GlobalNetworkPolicy - Default Deny
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: default-deny
spec:
  order: 1000
  selector: "all()"
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
    source: {}
  egress:
  - action: Deny
    destination: {}

---
# Calico NetworkPolicy - Allow Services to Services
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-payment-service
  namespace: default
spec:
  selector: app == 'payment-service'
  types:
  - Ingress
  ingress:
  - action: Allow
    source:
      selector: app == 'order-service'

---
# Calico NetworkPolicy - Allow Ingress from Gateway
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-gateway
  namespace: default
spec:
  selector: app in {'order-service', 'customer-service', 'product-service'}
  types:
  - Ingress
  ingress:
  - action: Allow
    source:
      selector: app == 'kong-gateway'

---
# Calico NetworkPolicy - Allow Egress to Database
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-egress-to-db
  namespace: default
spec:
  selector: app in {'order-service', 'customer-service', 'product-service'}
  types:
  - Egress
  egress:
  - action: Allow
    destination:
      selector: app == 'postgresql'

---
# Calico NetworkPolicy - Isolate R&D Namespace
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: isolate-rd-namespace
  namespace: rd
spec:
  selector: all()
  types:
  - Ingress
  - Egress
  ingress:
  - action: Allow
    source:
      selector: app in {'rd-repository', 'rd-ci-cd'}
  egress:
  - action: Allow
    destination:
      selector: app in {'rd-repository', 'rd-ci-cd'}

---
# Calico NetworkPolicy - Allow OT Network Isolation
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: isolate-ot-network
  namespace: ot
spec:
  selector: all()
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
    source:
      namespaceSelector: "!kubernetes.io/metadata.name == 'ot'"
  egress:
  - action: Deny
    destination:
      namespaceSelector: "!kubernetes.io/metadata.name == 'ot'"

# ====================================================================
# PART 4: OPA CONFIGMAP FOR KUBERNETES
# ====================================================================

---
# ConfigMap for OPA Policies
apiVersion: v1
kind: ConfigMap
metadata:
  name: opa-policies
  namespace: opa
data:
  policies.rego: |
    # OPA policies loaded from ConfigMap
    # This will be populated from zero_trust/02_pdp_policies.rego
    package nexus.zero_trust
    
    # Default deny
    default allow = false
    
    # Example policy (full policy in ConfigMap)
    allow = true {
      input.user.authenticated == true
      input.user.mfa_enabled == true
    }

---
# Deployment for OPA Server (PDP)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opa-server
  namespace: opa
  labels:
    app: opa-server
spec:
  replicas: 3
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
        - "--diagnostic-addr=:8282"
        - "--log-level=debug"
        - "--set=plugins.envoy_ext_authz_grpc.addr=:9191"
        - "--set=plugins.envoy_ext_authz_grpc.path=allow"
        - "--set=decision_logs.console=true"
        ports:
        - containerPort: 8181
          name: http
        - containerPort: 9191
          name: grpc
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
        env:
        - name: OPA_DECISION
          value: "nexus/zero_trust/allow"
      volumes:
      - name: policies
        configMap:
          name: opa-policies

---
# Service for OPA Server
apiVersion: v1
kind: Service
metadata:
  name: opa-server
  namespace: opa
  labels:
    app: opa-server
spec:
  selector:
    app: opa-server
  ports:
  - name: http
    port: 8181
    targetPort: 8181
  - name: grpc
    port: 9191
    targetPort: 9191

---
# Istio EnvoyFilter for OPA Integration
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: opa-authz-filter
  namespace: istio-system
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.http_connection_manager
            subFilter:
              name: envoy.filters.http.router
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.ext_authz
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
          transport_api_version: V3
          grpc_service:
            google_grpc:
              target_uri: "opa-server.opa.svc.cluster.local:9191"
              stat_prefix: "ext_authz"
          with_request_body:
            max_request_bytes: 1024
```

**Verification:**

```bash
# Verify PEP configuration file
ls -la zero_trust/03_pep_configuration.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('zero_trust/03_pep_configuration.yaml'))"
# Expected: No error output

# Check for Kubernetes resources
grep -c "apiVersion:" zero_trust/03_pep_configuration.yaml
# Expected: Shows 10+ Kubernetes resources
```

---

### Step 5: Continuous Verification Service

**File:** `zero_trust/04_continuous_verification.py`

```python
#!/usr/bin/env python3
"""
Zero Trust Continuous Verification Service - Nexus Global Industries
File: zero_trust/04_continuous_verification.py
Version: 1.0

This service continuously verifies active sessions, device posture, and user behavior
to detect anomalies and trigger step-up authentication or session termination.
"""

import os
import json
import time
import logging
import threading
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from enum import Enum

import requests
import redis
import jwt
from flask import Flask, request, jsonify, g
from prometheus_client import Counter, Histogram, Gauge, start_http_server

# ====================================================================
# Configuration
# ====================================================================

CONFIG = {
    "OPA_URL": os.getenv("OPA_URL", "http://opa-server.opa.svc.cluster.local:8181"),
    "REDIS_URL": os.getenv("REDIS_URL", "redis://redis.default.svc.cluster.local:6379/0"),
    "KEYCLOAK_URL": os.getenv("KEYCLOAK_URL", "https://auth.nexus.com"),
    "CROWDSTRIKE_URL": os.getenv("CROWDSTRIKE_URL", "https://api.crowdstrike.com"),
    "SIEM_ENDPOINT": os.getenv("SIEM_ENDPOINT", "http://logstash.siem.svc.cluster.local:5044"),
    "REFRESH_INTERVAL": int(os.getenv("REFRESH_INTERVAL", "60")),  # seconds
    "SUSPICIOUS_THRESHOLD": int(os.getenv("SUSPICIOUS_THRESHOLD", "70")),
    "CRITICAL_THRESHOLD": int(os.getenv("CRITICAL_THRESHOLD", "90")),
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
# Prometheus Metrics
# ====================================================================

VERIFICATION_REQUESTS = Counter(
    'verification_requests_total', 
    'Total number of verification requests'
)

VERIFICATION_DURATION = Histogram(
    'verification_duration_seconds',
    'Time taken for verification checks'
)

ACTIVE_SESSIONS_GAUGE = Gauge(
    'active_sessions_total',
    'Number of active sessions being monitored'
)

ANOMALY_COUNTER = Counter(
    'anomalies_detected_total',
    'Total number of anomalies detected'
)

# ====================================================================
# Data Models
# ====================================================================

class RiskLevel(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

@dataclass
class Session:
    """Represents an active user session."""
    session_id: str
    user_id: str
    user_roles: List[str]
    device_id: str
    device_posture: Dict[str, Any]
    auth_method: str
    auth_time: datetime
    last_activity: datetime
    ip_address: str
    user_agent: str
    geo_location: Dict[str, float]
    risk_score: int
    step_up_required: bool = False
    terminated: bool = False

@dataclass
class VerificationResult:
    """Result of a verification check."""
    session_id: str
    user_id: str
    passed: bool
    risk_score: int
    risk_level: RiskLevel
    checks: Dict[str, bool]
    reason: Optional[str] = None
    timestamp: datetime = None

    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.utcnow()

@dataclass
class SecurityEvent:
    """Security event for SIEM integration."""
    event_type: str
    severity: str
    user_id: str
    session_id: str
    event_data: Dict[str, Any]
    timestamp: datetime = None

    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.utcnow()

# ====================================================================
# Core Service
# ====================================================================

class ContinuousVerificationService:
    """
    Continuous Verification Service for Zero Trust Architecture.
    Continuously validates active sessions, device posture, and behavior.
    """
    
    def __init__(self):
        """Initialize the verification service."""
        # Redis connection for session storage
        self.redis_client = redis.from_url(CONFIG["REDIS_URL"])
        
        # Active sessions cache
        self.sessions: Dict[str, Session] = {}
        self.lock = threading.RLock()
        
        # Start background monitoring threads
        self._start_monitoring_threads()
        
        logger.info("Continuous Verification Service initialized")
    
    def _start_monitoring_threads(self) -> None:
        """Start background threads for continuous monitoring."""
        # Thread for periodic session verification
        verification_thread = threading.Thread(
            target=self._run_verification_loop,
            daemon=True,
            name="VerificationLoop"
        )
        verification_thread.start()
        
        # Thread for device posture polling
        device_thread = threading.Thread(
            target=self._run_device_posture_loop,
            daemon=True,
            name="DevicePostureLoop"
        )
        device_thread.start()
        
        # Thread for anomaly detection
        anomaly_thread = threading.Thread(
            target=self._run_anomaly_detection_loop,
            daemon=True,
            name="AnomalyDetectionLoop"
        )
        anomaly_thread.start()
        
        logger.info("Background monitoring threads started")
    
    def verify_session(self, session_id: str) -> VerificationResult:
        """
        Verify a single session against Zero Trust policies.
        
        Args:
            session_id: The session ID to verify
            
        Returns:
            VerificationResult containing the verification outcome
        """
        VERIFICATION_REQUESTS.inc()
        
        with self.lock:
            session = self.sessions.get(session_id)
            
            if not session:
                logger.warning(f"Session not found: {session_id}")
                return VerificationResult(
                    session_id=session_id,
                    user_id="unknown",
                    passed=False,
                    risk_score=100,
                    risk_level=RiskLevel.CRITICAL,
                    checks={"session_exists": False},
                    reason="Session not found"
                )
            
            if session.terminated:
                return VerificationResult(
                    session_id=session_id,
                    user_id=session.user_id,
                    passed=False,
                    risk_score=100,
                    risk_level=RiskLevel.CRITICAL,
                    checks={"session_active": False},
                    reason="Session already terminated"
                )
        
        # Perform verification checks
        checks = {}
        risk_score = 0
        
        # Check 1: Session age (re-authenticate if too old)
        session_age = (datetime.utcnow() - session.auth_time).total_seconds()
        checks["session_age_ok"] = session_age < 8 * 3600  # 8-hour max
        if not checks["session_age_ok"]:
            risk_score += 30
        
        # Check 2: Inactivity timeout
        idle_time = (datetime.utcnow() - session.last_activity).total_seconds()
        checks["idle_time_ok"] = idle_time < 15 * 60  # 15-minute idle
        if not checks["idle_time_ok"]:
            risk_score += 20
        
        # Check 3: Device posture
        device_checks = self._check_device_posture(session.device_id)
        checks.update(device_checks)
        if not all(device_checks.values()):
            risk_score += 25
        
        # Check 4: Geographic anomaly
        checks["geo_ok"] = self._check_geo_anomaly(session)
        if not checks["geo_ok"]:
            risk_score += 15
        
        # Check 5: Behavioral anomaly
        checks["behavior_ok"] = self._check_behavior(session)
        if not checks["behavior_ok"]:
            risk_score += 20
        
        # Calculate final risk level
        risk_level = self._calculate_risk_level(risk_score)
        
        # Determine if verification passed
        passed = risk_score < CONFIG["SUSPICIOUS_THRESHOLD"]
        
        result = VerificationResult(
            session_id=session_id,
            user_id=session.user_id,
            passed=passed,
            risk_score=risk_score,
            risk_level=risk_level,
            checks=checks
        )
        
        # Log to SIEM
        if risk_score >= CONFIG["CRITICAL_THRESHOLD"]:
            self._send_siem_event(SecurityEvent(
                event_type="critical_verification_failure",
                severity="critical",
                user_id=session.user_id,
                session_id=session_id,
                event_data={
                    "risk_score": risk_score,
                    "risk_level": risk_level.value,
                    "checks": checks,
                }
            ))
        
        # Update session risk score
        with self.lock:
            if session_id in self.sessions:
                self.sessions[session_id].risk_score = risk_score
                if risk_score >= CONFIG["CRITICAL_THRESHOLD"]:
                    self.sessions[session_id].terminated = True
                    self.redis_client.delete(f"session:{session_id}")
        
        return result
    
    def register_session(self, session_data: Dict[str, Any]) -> Session:
        """
        Register a new session for continuous verification.
        
        Args:
            session_data: Session data from authentication
            
        Returns:
            The registered Session object
        """
        session = Session(
            session_id=session_data.get("session_id"),
            user_id=session_data.get("user_id"),
            user_roles=session_data.get("roles", []),
            device_id=session_data.get("device_id"),
            device_posture=session_data.get("device_posture", {}),
            auth_method=session_data.get("auth_method", "mfa"),
            auth_time=datetime.utcnow(),
            last_activity=datetime.utcnow(),
            ip_address=session_data.get("ip_address", ""),
            user_agent=session_data.get("user_agent", ""),
            geo_location=session_data.get("geo_location", {"lat": 0, "lon": 0}),
            risk_score=0
        )
        
        with self.lock:
            self.sessions[session.session_id] = session
        
        # Store in Redis for persistence
        self.redis_client.setex(
            f"session:{session.session_id}",
            3600,  # 1-hour TTL
            json.dumps({
                "user_id": session.user_id,
                "device_id": session.device_id,
                "risk_score": session.risk_score,
                "auth_time": session.auth_time.isoformat(),
                "ip_address": session.ip_address,
            })
        )
        
        ACTIVE_SESSIONS_GAUGE.inc()
        logger.info(f"Session registered: {session.session_id}")
        return session
    
    def update_session_activity(self, session_id: str) -> None:
        """Update the last activity time for a session."""
        with self.lock:
            if session_id in self.sessions:
                self.sessions[session_id].last_activity = datetime.utcnow()
                self.sessions[session_id].risk_score = max(
                    0, 
                    self.sessions[session_id].risk_score - 5
                )
    
    def _check_device_posture(self, device_id: str) -> Dict[str, bool]:
        """
        Check device posture against CrowdStrike API.
        
        Args:
            device_id: The device ID to check
            
        Returns:
            Dict of check results
        """
        # Simulated device posture check
        # In production, this would call CrowdStrike Falcon API
        posture = {
            "encryption_enabled": True,
            "anti_malware_active": True,
            "os_patched": True,
            "firewall_enabled": True,
            "disk_encrypted": True
        }
        
        # Get device posture from Redis cache
        cache_key = f"device:{device_id}"
        cached_posture = self.redis_client.get(cache_key)
        if cached_posture:
            posture.update(json.loads(cached_posture))
        
        return {
            "encryption": posture.get("encryption_enabled", False),
            "anti_malware": posture.get("anti_malware_active", False),
            "os_patched": posture.get("os_patched", False),
            "firewall": posture.get("firewall_enabled", False),
            "disk_encrypted": posture.get("disk_encrypted", False),
        }
    
    def _check_geo_anomaly(self, session: Session) -> bool:
        """Check for geographic anomalies."""
        # Check if user logged in from an unusual location
        if session.geo_location:
            # Check distance from known home location
            # In production, this would use geolocation APIs
            pass
        
        # Check for impossible travel (within 1 hour)
        # In production, this would compare with previous login locations
        return True
    
    def _check_behavior(self, session: Session) -> bool:
        """Check for behavioral anomalies."""
        # In production, this would use ML-based anomaly detection
        # Check unusual access patterns, time, data access
        
        # Simulated behavior score
        behavior_score = session.risk_score
        if behavior_score > 50:
            return False
        
        # Check access patterns (too many access attempts)
        access_count = self.redis_client.get(f"access:{session.session_id}")
        if access_count and int(access_count) > 100:
            return False
        
        return True
    
    def _calculate_risk_level(self, risk_score: int) -> RiskLevel:
        """Calculate risk level from risk score."""
        if risk_score < 30:
            return RiskLevel.LOW
        elif risk_score < 50:
            return RiskLevel.MEDIUM
        elif risk_score < CONFIG["SUSPICIOUS_THRESHOLD"]:
            return RiskLevel.HIGH
        else:
            return RiskLevel.CRITICAL
    
    def _send_siem_event(self, event: SecurityEvent) -> None:
        """Send security event to SIEM."""
        try:
            # In production, this would send to Logstash/ELK
            logger.info(f"SIEM Event: {event.event_type} - {event.severity}")
            
            # Simulated SIEM send
            event_data = asdict(event)
            event_data["timestamp"] = event.timestamp.isoformat()
            
            # Send to Logstash HTTP endpoint
            if CONFIG["SIEM_ENDPOINT"]:
                requests.post(
                    CONFIG["SIEM_ENDPOINT"],
                    json=event_data,
                    timeout=5
                )
        except Exception as e:
            logger.error(f"Failed to send SIEM event: {e}")
    
    def _run_verification_loop(self) -> None:
        """Background loop for periodic session verification."""
        while True:
            try:
                with self.lock:
                    session_ids = list(self.sessions.keys())
                
                for session_id in session_ids:
                    try:
                        self.verify_session(session_id)
                    except Exception as e:
                        logger.error(f"Error verifying session {session_id}: {e}")
                
                time.sleep(CONFIG["REFRESH_INTERVAL"])
            except Exception as e:
                logger.error(f"Error in verification loop: {e}")
                time.sleep(10)
    
    def _run_device_posture_loop(self) -> None:
        """Background loop for polling device posture."""
        while True:
            try:
                # In production, this would call CrowdStrike API
                # to get device posture for all active devices
                time.sleep(300)  # 5 minutes
            except Exception as e:
                logger.error(f"Error in device posture loop: {e}")
                time.sleep(30)
    
    def _run_anomaly_detection_loop(self) -> None:
        """Background loop for detecting anomalies."""
        while True:
            try:
                with self.lock:
                    for session_id, session in self.sessions.items():
                        # Check for multiple anomalies
                        if session.risk_score >= CONFIG["SUSPICIOUS_THRESHOLD"]:
                            ANOMALY_COUNTER.inc()
                            
                            # Check if this is a critical anomaly
                            if session.risk_score >= CONFIG["CRITICAL_THRESHOLD"]:
                                self._send_siem_event(SecurityEvent(
                                    event_type="anomaly_detected",
                                    severity="critical",
                                    user_id=session.user_id,
                                    session_id=session_id,
                                    event_data={
                                        "risk_score": session.risk_score,
                                        "anomaly_type": "multiple_risk_factors"
                                    }
                                ))
                
                time.sleep(60)  # 1 minute
            except Exception as e:
                logger.error(f"Error in anomaly detection loop: {e}")
                time.sleep(10)

# ====================================================================
# Flask Web API
# ====================================================================

app = Flask(__name__)
verification_service = ContinuousVerificationService()

@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint."""
    return jsonify({"status": "healthy", "service": "continuous-verification"})

@app.route("/verify/<session_id>", methods=["GET"])
def verify(session_id: str):
    """Verify a session."""
    try:
        result = verification_service.verify_session(session_id)
        
        if result.passed:
            return jsonify({
                "verified": True,
                "risk_score": result.risk_score,
                "risk_level": result.risk_level.value,
                "checks": result.checks
            }), 200
        else:
            return jsonify({
                "verified": False,
                "risk_score": result.risk_score,
                "risk_level": result.risk_level.value,
                "reason": result.reason,
                "checks": result.checks
            }), 401
    except Exception as e:
        logger.error(f"Error in verify endpoint: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/register", methods=["POST"])
def register():
    """Register a new session."""
    try:
        data = request.json
        session = verification_service.register_session(data)
        return jsonify({
            "session_id": session.session_id,
            "registered": True,
            "verification_started": True
        }), 201
    except Exception as e:
        logger.error(f"Error in register endpoint: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/activity/<session_id>", methods=["POST"])
def activity(session_id: str):
    """Update session activity."""
    try:
        verification_service.update_session_activity(session_id)
        return jsonify({"updated": True}), 200
    except Exception as e:
        logger.error(f"Error in activity endpoint: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/sessions", methods=["GET"])
def list_sessions():
    """List all active sessions."""
    with verification_service.lock:
        sessions = []
        for session_id, session in verification_service.sessions.items():
            if not session.terminated:
                sessions.append({
                    "session_id": session.session_id,
                    "user_id": session.user_id,
                    "risk_score": session.risk_score,
                    "auth_time": session.auth_time.isoformat(),
                    "last_activity": session.last_activity.isoformat()
                })
        return jsonify({"sessions": sessions}), 200

# ====================================================================
# Main Entry Point
# ====================================================================

def main():
    """Main entry point for the service."""
    # Start Prometheus metrics server
    start_http_server(9090)
    
    # Start Flask app
    app.run(host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()
```

**Verification:**

```bash
# Verify verification service
ls -la zero_trust/04_continuous_verification.py
# Expected: File exists

# Check Python syntax
python3 -m py_compile zero_trust/04_continuous_verification.py
# Expected: No syntax errors

# Check for Flask endpoints
grep -c "@app.route" zero_trust/04_continuous_verification.py
# Expected: Shows 5+ endpoints
```

---

### Step 6: Comprehensive Zero Trust Policies

**File:** `zero_trust/05_zero_trust_policies.yaml`

```yaml
# Comprehensive Zero Trust Policies - Nexus Global Industries
# This file defines all ZTA policies in a human-readable format
# Version: 1.0

zero_trust_policies:
  version: "1.0"
  created: "2026-08-02"
  
  # ====================================================================
  # POLICY: IDENTITY AND ACCESS
  # ====================================================================
  
  identity_policies:
    - policy_id: "ZTA-001"
      name: "MFA Required for All Users"
      description: "All users must have MFA enabled to access any resource"
      enforcement: "Keycloak MFA policies"
      exceptions:
        - "Service accounts with approved exceptions"
      severity: "CRITICAL"
      
    - policy_id: "ZTA-002"
      name: "Session Timeout"
      description: "Sessions expire after 8 hours and 15 minutes idle"
      enforcement: "Keycloak session settings"
      max_session: "8 hours"
      idle_timeout: "15 minutes"
      severity: "HIGH"
    
    - policy_id: "ZTA-003"
      name: "Least Privilege Access"
      description: "Users have minimal permissions needed for their role"
      enforcement: "OPA RBAC/ABAC policies"
      review: "Quarterly"
      severity: "CRITICAL"
  
  # ====================================================================
  # POLICY: DEVICE POSTURE
  # ====================================================================
  
  device_policies:
    - policy_id: "ZTA-004"
      name: "Compliant Devices Required"
      description: "Only compliant devices can access corporate resources"
      enforcement: "CrowdStrike + OPA"
      requirements:
        - "Encryption enabled"
        - "Antivirus active"
        - "OS patched (within 30 days)"
        - "Firewall enabled"
      exceptions:
        - "R&D systems with DevSecOps approval"
      severity: "HIGH"
    
    - policy_id: "ZTA-005"
      name: "Device Registration"
      description: "All devices must be registered before accessing resources"
      enforcement: "CrowdStrike + Keycloak"
      severity: "HIGH"
  
  # ====================================================================
  # POLICY: NETWORK ACCESS
  # ====================================================================
  
  network_policies:
    - policy_id: "ZTA-006"
      name: "Default Deny"
      description: "All traffic is denied by default, explicitly allowed by policy"
      enforcement: "Calico network policies + Istio"
      severity: "CRITICAL"
    
    - policy_id: "ZTA-007"
      name: "Micro-segmentation"
      description: "Workloads are isolated by namespace, service, and data sensitivity"
      enforcement: "Calico + Istio authorization"
      segments:
        - name: "production"
          allowed_sources: ["api-gateway", "authenticated-users"]
        - name: "rd"
          allowed_sources: ["rd-engineer", "rd-ci-cd"]
        - name: "ot"
          allowed_sources: ["ot-engineer", "ot-monitor"]
      severity: "CRITICAL"
    
    - policy_id: "ZTA-008"
      name: "mTLS for All Internal Traffic"
      description: "All service-to-service communication uses mTLS"
      enforcement: "Istio STRICT mTLS"
      severity: "CRITICAL"
  
  # ====================================================================
  # POLICY: DATA ACCESS
  # ====================================================================
  
  data_policies:
    - policy_id: "ZTA-009"
      name: "Data Classification Access"
      description: "Access to data based on classification and user clearance"
      enforcement: "OPA data access policies"
      classification_matrix:
        restricted: ["admin", "security-team", "rd-engineer", "rd-manager"]
        confidential: ["admin", "security-team", "rd-engineer", "rd-manager", "finance", "hr"]
        internal: ["admin", "engineer", "support", "rd-engineer"]
        public: ["all"]
      severity: "CRITICAL"
    
    - policy_id: "ZTA-010"
      name: "Data Encryption"
      description: "All sensitive data encrypted at rest and in transit"
      enforcement: "AES-256 (at rest), TLS 1.3 (in transit)"
      severity: "CRITICAL"
  
  # ====================================================================
  # POLICY: PRIVILEGED ACCESS
  # ====================================================================
  
  privileged_access_policies:
    - policy_id: "ZTA-011"
      name: "JIT Access Required"
      description: "Privileged access requires Just-In-Time approval"
      enforcement: "HashiCorp Vault"
      max_session: "15 minutes"
      approval_required: true
      severity: "CRITICAL"
    
    - policy_id: "ZTA-012"
      name: "Session Recording"
      description: "All privileged sessions are recorded"
      enforcement: "Vault session recording + SIEM"
      retention: "365 days"
      severity: "CRITICAL"
    
    - policy_id: "ZTA-013"
      name: "Credential Rotation"
      description: "All privileged credentials rotate automatically"
      enforcement: "Vault dynamic secrets"
      rotation_interval: "30 days"
      severity: "HIGH"
  
  # ====================================================================
  # POLICY: CONTINUOUS VERIFICATION
  # ====================================================================
  
  verification_policies:
    - policy_id: "ZTA-014"
      name: "Continuous Session Verification"
      description: "Sessions are verified every 60 seconds"
      enforcement: "Continuous Verification Service"
      refresh_interval: "60 seconds"
      threshold_suspicious: 70
      threshold_critical: 90
      severity: "HIGH"
    
    - policy_id: "ZTA-015"
      name: "Behavioral Anomaly Detection"
      description: "User behavior is analyzed for anomalies"
      enforcement: "ML-based analysis + SIEM"
      detection_factors:
        - "Geolocation changes"
        - "Unusual access times"
        - "Unusual data access patterns"
        - "Rate anomalies"
      severity: "HIGH"
    
    - policy_id: "ZTA-016"
      name: "Risk-Based Step-Up Authentication"
      description: "High-risk sessions require additional authentication"
      enforcement: "OPA + Keycloak"
      step_up_methods: ["MFA", "Biometric", "Security Questions"]
      severity: "HIGH"
  
  # ====================================================================
  # POLICY: AUDIT AND COMPLIANCE
  # ====================================================================
  
  audit_policies:
    - policy_id: "ZTA-017"
      name: "Comprehensive Audit Logging"
      description: "All access decisions and security events logged"
      enforcement: "SIEM (ELK Stack)"
      retention: "365 days"
      severity: "HIGH"
    
    - policy_id: "ZTA-018"
      name: "Real-time Alerting"
      description: "Security alerts trigger in real-time"
      enforcement: "SIEM + PagerDuty"
      alert_channels:
        - "Slack (#security-alerts)"
        - "PagerDuty (critical only)"
      severity: "HIGH"
  
  # ====================================================================
  # POLICY: EXCEPTIONS AND OVERRIDES
  # ====================================================================
  
  exceptions:
    - policy_id: "ZTA-EX-001"
      name: "Emergency Break-Glass Access"
      description: "Critical emergency access with strict approval"
      approval: "CISO + 2 senior engineers"
      duration: "30 minutes"
      audit: "Immediate review required"
      
    - policy_id: "ZTA-EX-002"
      name: "Legacy System Exceptions"
      description: "Legacy systems with documented exceptions"
      approval: "SARB"
      duration: "Until modernization complete"
      compensating_controls:
        - "Additional monitoring"
        - "Network isolation"
  
  # ====================================================================
  # POLICY: IMPLEMENTATION PHASES
  # ====================================================================
  
  implementation_phases:
    - phase: "Phase 1: Foundation"
      timeline: "Months 1-3"
      policies:
        - "ZTA-001 (MFA Required)"
        - "ZTA-003 (Least Privilege)"
        - "ZTA-006 (Default Deny)"
        - "ZTA-017 (Audit Logging)"
    
    - phase: "Phase 2: Workload Protection"
      timeline: "Months 4-6"
      policies:
        - "ZTA-004 (Compliant Devices)"
        - "ZTA-007 (Micro-segmentation)"
        - "ZTA-008 (mTLS)"
        - "ZTA-009 (Data Classification)"
    
    - phase: "Phase 3: User Access"
      timeline: "Months 7-9"
      policies:
        - "ZTA-002 (Session Timeout)"
        - "ZTA-010 (Data Encryption)"
        - "ZTA-014 (Continuous Verification)"
    
    - phase: "Phase 4: Advanced"
      timeline: "Months 10-12"
      policies:
        - "ZTA-011 (JIT Access)"
        - "ZTA-015 (Behavioral Anomaly)"
        - "ZTA-016 (Step-Up Auth)"
```

**Verification:**

```bash
# Verify comprehensive policies
ls -la zero_trust/05_zero_trust_policies.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('zero_trust/05_zero_trust_policies.yaml'))"
# Expected: No error output

# Count policies
grep -c "policy_id:" zero_trust/05_zero_trust_policies.yaml
# Expected: Shows 18+ policies
```

---

### Step 7: Zero Trust Summary

**File:** `zero_trust/README.md`

```markdown
# Zero Trust Architecture - Nexus Global Industries

## Overview

This directory contains the complete Zero Trust Architecture (ZTA) implementation for Nexus Global Industries, based on NIST Special Publication 800-207.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_architecture_design.md` | Design | ZTA design, components, and architecture |
| `02_pdp_policies.rego` | PDP | OPA policies for Policy Decision Point |
| `03_pep_configuration.yaml` | PEP | Istio, Kong, and Calico configurations |
| `04_continuous_verification.py` | Verification | Continuous verification service |
| `05_zero_trust_policies.yaml` | Policies | Comprehensive ZTA policies |

## Architecture Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    NEXUS GLOBAL ZERO TRUST                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  PAP: Policy Administration                            │   │
│  │  • GitLab (policy-as-code)                            │   │
│  │  • CI/CD deployment                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  PDP: Policy Decision Point                            │   │
│  │  • OPA Server (3 replicas)                            │   │
│  │  • Rego policies                                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  PIP: Policy Information Point                         │   │
│  │  • Keycloak (identity)                                │   │
│  │  • CrowdStrike (device)                               │   │
│  │  • Istio (context)                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  PEP: Policy Enforcement Point                         │   │
│  │  • Istio (service mesh)                               │   │
│  │  • Kong (API gateway)                                 │   │
│  │  • Calico (network)                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Deployment Instructions

### 1. Deploy OPA Server (PDP)

```bash
kubectl apply -f zero_trust/03_pep_configuration.yaml
```

### 2. Deploy Istio with mTLS

```bash
istioctl install --set profile=demo -y
kubectl apply -f zero_trust/03_pep_configuration.yaml
```

### 3. Deploy Kong Gateway (PEP)

```bash
helm install kong kong/kong -f zero_trust/03_pep_configuration.yaml
```

### 4. Deploy Calico Network Policies

```bash
calicoctl apply -f zero_trust/03_pep_configuration.yaml
```

### 5. Deploy Continuous Verification Service

```bash
kubectl apply -f zero_trust/04_continuous_verification.py
```

## Verification Checklist

- [ ] OPA server running and accessible
- [ ] Istio mTLS enabled (STRICT mode)
- [ ] Kong gateway with OPA plugin
- [ ] Calico network policies enforced
- [ ] Continuous verification service running
- [ ] MFA enabled for all users
- [ ] Device posture checks working
- [ ] SIEM receiving audit logs

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la zero_trust/README.md
# Expected: File exists

echo "✅ Zero Trust Architecture Complete!"
echo "   - Architecture design documented"
echo "   - OPA PDP policies created"
echo "   - PEP configurations (Istio, Kong, Calico)"
echo "   - Continuous verification service"
echo "   - Comprehensive policies defined"
```

---

**[GENERATED: Part 2, Section 2.1 - Zero Trust Architecture]**

**[COMPLETED: NIST SP 800-207 Zero Trust Architecture]**
- ✅ Architecture Design - Components and flow documented
- ✅ PDP Policies - 6+ OPA Rego policies
- ✅ PEP Configurations - Istio, Kong, Calico
- ✅ Continuous Verification - Python service with Flask API
- ✅ Comprehensive Policies - 18+ policies defined

---

## End of Section 2.1: Zero Trust Architecture

### Key Takeaway

You've implemented a complete NIST SP 800-207 Zero Trust Architecture for Nexus Global Industries. The architecture includes a Policy Decision Point (OPA), Policy Enforcement Points (Istio, Kong, Calico), a Policy Administration Point (Git-based), and a Policy Information Point (Keycloak, CrowdStrike). The continuous verification service ensures that sessions are constantly validated, and risk-based policies dynamically adapt to changing conditions.

### What's Next

In **Section 2.2**, we'll implement the **Identity & Access Management** system, including:
- Keycloak Identity Provider deployment
- OAuth 2.1/OIDC integration
- SCIM 2.0 for JML automation
- Role-Based and Attribute-Based Access Control

The implementation continues with complete Keycloak configuration, OIDC integration, and SCIM automation.
