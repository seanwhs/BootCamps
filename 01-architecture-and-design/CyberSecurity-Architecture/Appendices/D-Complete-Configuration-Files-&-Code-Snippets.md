# Appendix D: Complete Configuration Files & Code Snippets
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - All Code Artifacts

## Overview

This appendix contains all configuration files, code snippets, and scripts referenced throughout the series. Each file is presented in full with its exact path and usage context.

---

## Part 1: Foundation Code Artifacts

### SABSA Framework

#### File: `sabsa_framework/05_component_architecture.yaml`

```yaml
# SABSA Component Architecture - Nexus Global Industries
# Detailed specifications for each security component

version: "1.0"
components:
  # ==================== IDENTITY COMPONENTS ====================
  
  - id: "IAM-001"
    name: "Identity Provider - Keycloak"
    type: "identity"
    description: "Centralized identity provider for all Nexus Global systems"
    specifications:
      version: "23.0+"
      deployment: "Kubernetes (StatefulSet)"
      replicas: 3
      database: "PostgreSQL (managed RDS/AKS)"
      configuration:
        - "OIDC provider enabled"
        - "SAML 2.0 enabled"
        - "SCIM 2.0 enabled"
        - "User federation with Active Directory"
        - "MFA enforcement: required for all users"
        - "Session management: 15-minute idle, 8-hour max"
        - "Audit logging: enabled, sent to ELK"
      integrations:
        - "Azure AD (identity federation)"
        - "Workday (JML via SCIM)"
        - "API Gateway (OIDC tokens)"
        - "Grafana (OIDC)"
        - "GitLab (OIDC)"
      lifecycle:
        - "Automated backup: daily"
        - "High availability: multi-region failover"
        - "Disaster recovery: RTO 1 hour, RPO 15 minutes"
  
  - id: "IAM-002"
    name: "Privileged Access Manager - HashiCorp Vault"
    type: "privileged_access"
    description: "Secrets management and privileged access control"
    specifications:
      version: "1.15+"
      deployment: "Kubernetes (StatefulSet)"
      replicas: 3
      storage: "Consul (backend) + AWS KMS (auto-unseal)"
      features:
        - "Dynamic secrets for cloud credentials"
        - "Static secrets for application configs"
        - "JIT privileged access workflows"
        - "Session recording for admin actions"
        - "Key rotation: automatic (30-day interval)"
        - "Audit logging: enabled, sent to ELK"
      integrations:
        - "AWS IAM (dynamic credentials)"
        - "Azure AD (JIT access)"
        - "Kubernetes (service account tokens)"
        - "CI/CD (secrets injection)"
      policies:
        - "Approval required for privileged actions"
        - "Time-bound access (15-minute max)"
        - "Justification required for all access"
  
  # ==================== ZERO TRUST COMPONENTS ====================
  
  - id: "ZT-001"
    name: "Policy Decision Point - Open Policy Agent (OPA)"
    type: "zero_trust"
    description: "Centralized policy engine for all access decisions"
    specifications:
      version: "0.60+"
      deployment: "Kubernetes (Deployment) + Sidecar mode"
      replicas: 5
      storage: "ConfigMaps + Git (policy-as-code)"
      policy_language: "Rego"
      policy_types:
        - "Identity-based policies (WHO)"
        - "Context-based policies (WHERE, HOW)"
        - "Resource-based policies (WHAT)"
        - "Risk-based policies (CONTEXT)"
      policy_sources:
        - "Git repository (source of truth)"
        - "Hot reload: automatic on git push"
        - "Versioned: every policy change tracked"
      integrations:
        - "Istio (PEP integration)"
        - "Kong Gateway (PEP)"
        - "Kubernetes (admission control)"
        - "API Gateway (request validation)"
      performance:
        - "Latency target: < 10ms per eval"
        - "Throughput: 10,000 req/sec per instance"
        - "Caching: enabled (5-minute TTL)"
  
  - id: "ZT-002"
    name: "Policy Enforcement Point - Istio Service Mesh"
    type: "zero_trust"
    description: "Distributed enforcement layer for zero trust policies"
    specifications:
      version: "1.20+"
      deployment: "Kubernetes (Sidecar injection)"
      features:
        - "mTLS: always on for all workloads"
        - "AuthorizationPolicy: OPA + Istio native"
        - "Telemetry: metrics, traces, logs"
        - "Circuit breaking: automatic failure detection"
        - "Retry policies: application-defined"
        - "Load balancing: round-robin, least-loaded"
      policy_integration:
        - "OPA decisions enforced via Envoy filter"
        - "Network policies complement Istio policies"
      observability:
        - "Kiali: service mesh visualization"
        - "Prometheus: metrics collection"
        - "Jaeger: distributed tracing"
        - "Grafana: dashboards"
```

---

### NIST CSF Policies

#### File: `nist_csf/01_governance_policies.yaml`

```yaml
# NIST CSF 2.0 - Governance Policies as Code
# Nexus Global Industries
# Version: 1.0

govern:
  # ================================================================
  # G1: Organizational Context (GV.OC)
  # ================================================================
  organizational_context:
    mission: >
      Revolutionize global manufacturing through AI-driven precision engineering
      while maintaining the highest standards of quality, safety, and security.
    vision: >
      To be the world's most trusted manufacturing and technology partner,
      securing intellectual property and customer trust through excellence.
    values:
      - "Security is every employee's responsibility"
      - "Transparency in all security matters"
      - "Continuous improvement through learning"
      - "Customer trust is earned through security"
    business_model: >
      Advanced manufacturing + technology services. 
      Revenue: $4.2B annual.
      Employees: 15,000 across 42 countries.
    regulatory_requirements:
      - "GDPR (EU General Data Protection Regulation)"
      - "NIST SP 800-171 (US Government contracts)"
      - "CCPA/CPRA (California Consumer Privacy Act)"
      - "PDPA (Singapore Personal Data Protection Act)"
      - "Local manufacturing regulations (various jurisdictions)"
      - "Export controls (US and international)"
    risk_appetite:
      high_acceptance:
        - "Business agility and innovation"
        - "Security transformation initiatives"
      low_acceptance:
        - "Loss of intellectual property"
        - "Personal data breaches"
        - "Safety incidents affecting OT systems"
        - "Operational outages (manufacturing downtime)"
      risk_tolerance:
        - "Financial impact: Up to $5M per incident (medium risk)"
        - "Regulatory fines: Avoided through compliance"
        - "Reputational impact: Proactively managed"
    threat_environment:
      known_threats:
        - actor_type: "Nation-state APTs"
          motivation: "IP theft, industrial espionage"
          recent_activity: "Active targeting of manufacturing sector"
        - actor_type: "Ransomware Gangs"
          motivation: "Financial extortion"
          recent_activity: "2024 European datacenter ransomware incident"
        - actor_type: "Competitors"
          motivation: "Competitive intelligence"
          recent_activity: "Known intellectual property theft attempts"
        - actor_type: "Insider Threats"
          motivation: "Financial, disgruntled employees"
          recent_activity: "Remote workforce security challenges"
        - actor_type: "Hacktivists"
          motivation: "Reputational damage"
          recent_activity: "Targeting environmental or geopolitical issues"

  # ================================================================
  # G2: Risk Management Strategy (GV.RM)
  # ================================================================
  risk_management_strategy:
    framework: "NIST CSF 2.0 + ISO 27001 + SABSA"
    risk_management_process:
      identify: >
        Identify risks through threat modeling, vulnerability assessments,
        and asset inventory. Use STRIDE, PASTA, and Attack Trees.
      assess: >
        Assess risks using likelihood and impact criteria.
        Quantitative scoring (0-100) with qualitative overlay.
      prioritize: >
        Prioritize based on business impact and risk appetite.
        Critical systems (OT, IP, PII) get highest priority.
      treat: >
        Treatment options: Accept, Avoid, Transfer, Mitigate.
        Document all decisions in risk register.
      monitor: >
        Continuous monitoring through security metrics, audits,
        and threat intelligence feeds.
    risk_management_roles:
      - role: "CISO"
        responsibility: "Overall risk management ownership"
      - role: "Security Architects"
        responsibility: "Risk assessment and mitigation design"
      - role: "Platform Teams"
        responsibility: "Implementation of risk controls"
      - role: "Auditors"
        responsibility: "Independent risk verification"
    risk_management_artifacts:
      - "Risk Register (maintained in Excel/GRC tool)"
      - "Risk Treatment Plans (for each identified risk)"
      - "Risk Acceptance Log (signed by CISO or Board)"
      - "Security Metrics Dashboard (real-time risk posture)"

  # ================================================================
  # G3: Roles, Responsibilities, and Authorities (GV.RR)
  # ================================================================
  roles_responsibilities:
    cybersecurity_team:
      - title: "Chief Information Security Officer (CISO)"
        responsibilities:
          - "Overall cybersecurity strategy and governance"
          - "Board reporting and executive engagement"
          - "Risk appetite enforcement"
        authority: "Full authority over cybersecurity budget and strategy"
        reporting_to: "CEO and Board"
      
      - title: "Lead Enterprise Security Architect"
        responsibilities:
          - "Security architecture design and framework alignment"
          - "SABSA, CSF, and ISO 27001 integration"
          - "Threat modeling and control mapping"
        authority: "Architecture decisions and framework selection"
        reporting_to: "CISO"
      
      - title: "Security Engineering Manager"
        responsibilities:
          - "Implementation and operation of security controls"
          - "Team management (25+ security engineers)"
          - "Security tooling and automation"
        authority: "Security tool selection and operations"
        reporting_to: "CISO"
      
      - title: "Detection Engineering Manager"
        responsibilities:
          - "Detection rules and threat hunting"
          - "SIEM operations and analytics"
          - "MITRE ATT&CK alignment"
        authority: "Detection strategy and rule approval"
        reporting_to: "CISO"
      
      - title: "Incident Response Manager"
        responsibilities:
          - "Incident response processes and playbooks"
          - "Security incident management"
          - "Post-mortem and lessons learned"
        authority: "Incident containment decisions during active incidents"
        reporting_to: "CISO"
      
      - title: "GRC Manager"
        responsibilities:
          - "Risk management, compliance, and governance"
          - "Audit facilitation and remediation"
          - "Policy management"
        authority: "Compliance and audit decisions"
        reporting_to: "CISO"

    business_roles:
      - title: "CEO"
        responsibility: "Overall business accountability for cybersecurity"
        authority: "Approves cybersecurity strategy and budget"
      
      - title: "CFO"
        responsibility: "Cybersecurity financial oversight"
        authority: "Approves budget and financial risk acceptance"
      
      - title: "COO"
        responsibility: "Operational cybersecurity risk management"
        authority: "Approves operational security decisions"
      
      - title: "GC (General Counsel)"
        responsibility: "Legal and regulatory compliance"
        authority: "Legal and regulatory decisions"
      
      - title: "Board of Directors"
        responsibility: "Oversight of cybersecurity governance"
        authority: "Appoints CISO, approves strategy"
```

---

### Threat Modeling Artifacts

#### File: `threat_models/02_pasta_risk_model.md`

```markdown
# PASTA Risk-Centric Threat Modeling - Nexus Global Industries

## Overview

PASTA (Process for Attack Simulation and Threat Analysis) is a risk-centric threat modeling methodology that aligns threats with business objectives and impacts. This document applies PASTA to the Nexus Global Industries Customer Portal and R&D systems.

## PASTA Stage 1: Define Business Objectives

### Customer Portal Business Objectives

1. **Objective 1**: Enable B2B customers to place orders 24/7 with 99.99% availability
   - Business Impact: $500K/hour revenue lost if unavailable
   - Stakeholders: Sales, Customer Success, Finance

2. **Objective 2**: Protect customer PII and order data from unauthorized access
   - Business Impact: Regulatory fines ($20M+), reputational damage
   - Stakeholders: Legal, GRC, Security

3. **Objective 3**: Provide seamless, frictionless ordering experience
   - Business Impact: Customer retention, competitive advantage
   - Stakeholders: Product, Engineering, Customer Success

### R&D Systems Business Objectives

1. **Objective 1**: Protect intellectual property (AI/ML models, manufacturing recipes)
   - Business Impact: $2B+ IP value, competitive advantage
   - Stakeholders: R&D, Legal, CEO

2. **Objective 2**: Enable rapid, secure code deployment (CI/CD)
   - Business Impact: Time-to-market advantage, innovation velocity
   - Stakeholders: Engineering, Product

3. **Objective 3**: Ensure code integrity and authenticity
   - Business Impact: Trust in products, supply chain security
   - Stakeholders: Quality Assurance, Security, Operations

## PASTA Stage 2: Define Technical Scope

### Customer Portal Technical Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CUSTOMER PORTAL ARCHITECTURE              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           CUSTOMER BROWSER / MOBILE APP             │   │
│  │           (WebAuthn, TLS 1.3, OIDC)                │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼────────────────────────────────┐   │
│  │           API GATEWAY (Kong)                        │   │
│  │           (Rate limit, JWT, OWASP)                 │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼────────────────────────────────┐   │
│  │           SERVICE MESH (Istio)                      │   │
│  │           (mTLS, Authz, Telemetry)                 │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │                                      │
│  ┌──────────┬─────────┼──────────┬─────────────────────┐   │
│  │          │         │          │                     │   │
│  ▼          ▼         ▼          ▼                     │   │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │   │
│  │Order │ │Auth  │ │User  │ │Payment│              │   │
│  │Svc   │ │Svc   │ │Svc   │ │Svc   │              │   │
│  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘              │   │
│     │        │        │        │                     │   │
│     └────────┼────────┼────────┘                     │   │
│              │        │                                │   │
│  ┌───────────▼────────▼──────────────────────────┐   │   │
│  │           DATABASE (PostgreSQL)               │   │   │
│  │           (Encrypted, replicated)             │   │   │
│  └────────────────────────────────────────────────┘   │   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### R&D Systems Technical Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    R&D SYSTEMS ARCHITECTURE                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           DEVELOPERS / CI/CD PIPELINES              │   │
│  │           (GitLab, Docker, Helm)                   │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼────────────────────────────────┐   │
│  │           CODE REPOSITORY (GitLab)                  │   │
│  │           (Branch protection, signed commits)       │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼────────────────────────────────┐   │
│  │           CI/CD PIPELINE                            │   │
│  │           (SAST, DAST, SCA, Container scan)        │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼────────────────────────────────┐   │
│  │           CONTAINER REGISTRY (ECR/ACR)              │   │
│  │           (Signed images, SBOM)                    │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼────────────────────────────────┐   │
│  │           KUBERNETES CLUSTER                        │   │
│  │           (Istio, OPA, Kyverno)                    │   │
│  └────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## PASTA Stage 3: Application Decomposition

### Customer Portal - Data Flow Diagram

| Component | Data Flow | Sensitivity | Access Controls |
|-----------|-----------|-------------|-----------------|
| Browser/App | HTTPS requests, JWT tokens | MEDIUM | TLS 1.3, CORS |
| API Gateway | API requests/responses | MEDIUM | Rate limiting, JWT |
| Service Mesh | mTLS traffic between services | HIGH | mTLS, authorization |
| Microservices | Order data, user data, payment data | HIGH | RBAC/ABAC, OPA |
| Database | Persistent data (orders, users, etc.) | CRITICAL | Encryption, access controls |
| Logging | Audit logs to SIEM | HIGH | Access controls, retention |

### R&D Systems - Data Flow Diagram

| Component | Data Flow | Sensitivity | Access Controls |
|-----------|-----------|-------------|-----------------|
| Developer | Code commits, git pushes | HIGH | SSH keys, MFA |
| GitLab | Code storage, CI/CD pipelines | CRITICAL | Branch protection, approvals |
| CI/CD Pipeline | Build artifacts, test data | HIGH | Tokens, secure variables |
| Container Registry | Container images, SBOM | HIGH | Authentication, signing |
| K8s Cluster | Running pods, secrets | CRITICAL | RBAC, encryption |
```

---

## Part 2: Zero Trust Artifacts

### OPA Policies

#### File: `zero_trust/02_pdp_policies.rego`

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

### Continuous Verification Service

#### File: `zero_trust/04_continuous_verification.py` (Excerpt)

```python
#!/usr/bin/env python3
"""
Zero Trust Continuous Verification Service - Nexus Global Industries
File: zero_trust/04_continuous_verification.py
Version: 1.0

This service continuously verifies active sessions, device posture, and behavior
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
```

---

## Part 3: Cloud Security Artifacts

### Terraform Landing Zone

#### File: `cloud/01_landing_zones.tf`

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

# Azure Security Center (Defender for Cloud)
resource "azurerm_security_center_subscription_pricing" "nexus" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

# Azure Sentinel (SIEM)
resource "azurerm_sentinel_workspace" "nexus" {
  name                       = "nexus-sentinel"
  location                   = "eastus"
  resource_group_name        = azurerm_resource_group.security.name
  sku                        = "PerGB2018"
  retention_in_days          = 90
}
```

---

### Kubernetes Security - Kyverno Policies

#### File: `k8s/04_admission_controllers.yaml` (Excerpt)

```yaml
# Admission Controllers - Nexus Global Industries
# File: k8s/04_admission_controllers.yaml
# Version: 1.0

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
```

---

## Part 4: Detection & Response Artifacts

### Sigma Detection Rules

#### File: `detection/01_sigma_rules.yaml`

```yaml
# Sigma Detection Rules - Nexus Global Industries
# File: detection/01_sigma_rules.yaml
# Version: 1.0

# ====================================================================
# RULE 1: CREDENTIAL DUMPING (T1003)
# ====================================================================

---
title: "Credential Dumping via LSASS Memory Access"
id: "rule-001"
status: "production"
description: "Detects access to LSASS process memory, indicating credential dumping activity"
author: "Nexus Detection Engineering Team"
date: "2026-08-02"
tags:
  - attack.t1003
  - attack.credential_access
logsource:
  product: windows
  service: security
  category: process_creation
detection:
  selection:
    EventID: 4688
    ProcessName:
      - "*\\rundll32.exe"
      - "*\\powershell.exe"
    CommandLine:
      - "*lsass*"
      - "*procdump*"
      - "*DumpLSASS*"
      - "*secretsdump*"
  condition: selection
falsepositives:
  - "Legitimate administration tools"
  - "Security software scanning"
level: high

---
# ====================================================================
# RULE 2: PRIVILEGE ESCALATION (T1068)
# ====================================================================

---
title: "Privilege Escalation via Sudo Abuse"
id: "rule-002"
status: "production"
description: "Detects suspicious sudo usage patterns indicating privilege escalation"
author: "Nexus Detection Engineering Team"
date: "2026-08-02"
tags:
  - attack.t1068
  - attack.privilege_escalation
logsource:
  product: linux
  service: auth
detection:
  selection:
    - sudo:
        - "ALL=(ALL) ALL"
        - "ALL=(ALL:ALL) ALL"
    - CMD:
        - "*nmap*"
        - "*nc*"
        - "*python*"
        - "*perl*"
        - "*ruby*"
    - USER:
        - "!root"
  filter:
    - CMD: "*apt*"
    - CMD: "*yum*"
    - CMD: "*pip*"
    - CMD: "*gem*"
  condition: selection and not filter
falsepositives:
  - "Legitimate package installation"
  - "Automated maintenance scripts"
level: high

---
# ====================================================================
# RULE 3: RANSOMWARE DETECTION (T1486)
# ====================================================================

---
title: "Suspicious File Encryption Activity"
id: "rule-008"
status: "production"
description: "Detects mass file encryption indicative of ransomware"
author: "Nexus Detection Engineering Team"
date: "2026-08-02"
tags:
  - attack.t1486
  - attack.impact
logsource:
  product: windows
  service: sysmon
detection:
  selection:
    EventID:
      - 1  # Process creation
      - 11 # File creation
    ProcessName:
      - "*vssadmin*"
      - "*wbadmin*"
      - "*bcdedit*"
      - "*cipher*"
    CommandLine:
      - "*delete shadows*"
      - "*delete snapshots*"
      - "*create backup*"
      - "*/e*"
  filter:
    ProcessName:
      - "*backup.exe"
      - "*vss.exe"
  condition: selection and not filter
falsepositives:
  - "Legitimate backup software"
  - "Maintenance scripts"
level: critical

---
# ====================================================================
# RULE 4: ZERO TRUST VIOLATION (T1078)
# ====================================================================

---
title: "Session Verification Failure"
id: "rule-010"
status: "production"
description: "Detects Zero Trust session verification failures indicating compromised sessions"
author: "Nexus Detection Engineering Team"
date: "2026-08-02"
tags:
  - attack.t1078
  - attack.initial_access
logsource:
  product: security
  service: zero_trust
detection:
  selection:
    event_type: "verification_failure"
    risk_score: "> 70"
    reason:
      - "device_noncompliant"
      - "geo_anomaly"
      - "behavior_anomaly"
  condition: selection
falsepositives:
  - "Legitimate travel"
  - "Device updates"
level: high
```

### SOAR Playbooks

#### File: `soar/01_playbooks.yaml` (Excerpt)

```yaml
# SOAR Playbooks - Nexus Global Industries
# File: soar/01_playbooks.yaml
# Version: 1.0

# ====================================================================
# PLAYBOOK 1: PHISHING RESPONSE
# ====================================================================

playbook_001:
  name: "Phishing Response Playbook"
  id: "SOAR-001"
  version: "1.0"
  owner: "Incident Response Manager"
  trigger: "Email security alert"
  severity: "MEDIUM"
  priority: 3
  
  steps:
    - step: 1
      name: "Alert Triage"
      action: |
        - Receive phishing alert from email gateway
        - Validate alert is a true positive
        - Extract sender, recipient, subject, and attachment details
      automation: "semi-automated"
      tools: ["Email Gateway API", "SIEM"]
      timeout: "5m"
    
    - step: 2
      name: "Email Analysis"
      action: |
        - Extract email headers
        - Check for malicious attachments (sandbox analysis)
        - Check for malicious URLs (URL reputation)
        - Generate threat intelligence report
      automation: "fully-automated"
      tools: ["Sandbox", "Threat Intelligence", "URL Reputation"]
      timeout: "10m"
    
    - step: 3
      name: "User Isolation"
      action: |
        - Quarantine affected mailbox
        - Disable compromised account if needed
        - Force password reset
        - Revoke active sessions
      automation: "fully-automated"
      tools: ["Active Directory", "Keycloak", "Email Gateway"]
      timeout: "5m"
    
    - step: 4
      name: "Containment"
      action: |
        - Remove malicious email from all mailboxes
        - Block sender domain in email gateway
        - Update threat intelligence feeds
        - Blacklist malicious URLs in proxy
      automation: "fully-automated"
      tools: ["Email Gateway", "Proxy", "Threat Intel Platform"]
      timeout: "10m"
    
    - step: 5
      name: "User Notification"
      action: |
        - Send notification to affected users
        - Provide phishing awareness tips
        - Offer additional training if needed
      automation: "semi-automated"
      tools: ["Communication Platform", "Training Platform"]
      timeout: "15m"
    
    - step: 6
      name: "Case Documentation"
      action: |
        - Create incident case
        - Document all actions taken
        - Update incident status
        - Close case
      automation: "fully-automated"
      tools: ["Case Management", "SIEM"]
      timeout: "5m"

# ====================================================================
# PLAYBOOK 2: RANSOMWARE DETECTION
# ====================================================================

playbook_002:
  name: "Ransomware Response Playbook"
  id: "SOAR-002"
  version: "1.0"
  owner: "Incident Response Manager"
  trigger: "Ransomware detection alert"
  severity: "CRITICAL"
  priority: 1
  
  steps:
    - step: 1
      name: "Alert Triage"
      action: |
        - Receive ransomware detection alert from XDR/SIEM
        - Validate alert is a true positive
        - Identify affected systems
      automation: "semi-automated"
      tools: ["XDR", "SIEM"]
      timeout: "5m"
    
    - step: 2
      name: "Network Isolation"
      action: |
        - Isolate affected network segments (Calico policies)
        - Block communication to C2 servers
        - Quarantine infected endpoints
      automation: "fully-automated"
      tools: ["Network Policy Engine", "Firewall", "XDR"]
      timeout: "2m"
    
    - step: 3
      name: "Credential Protection"
      action: |
        - Revoke compromised credentials
        - Force password reset for affected users
        - Rotate service account passwords
      automation: "fully-automated"
      tools: ["Keycloak", "Vault", "Active Directory"]
      timeout: "5m"
    
    - step: 4
      name: "Backup Recovery"
      action: |
        - Validate latest immutable backup
        - Initiate restore from immutable backups
        - Verify data integrity after restore
      automation: "semi-automated"
      tools: ["Backup System", "Storage", "Monitoring"]
      timeout: "30m"
    
    - step: 5
      name: "System Restoration"
      action: |
        - Reimage affected systems
        - Restore data from backups
        - Validate system functionality
      automation: "semi-automated"
      tools: ["Orchestration", "Monitoring"]
      timeout: "1h"
    
    - step: 6
      name: "Post-Incident Analysis"
      action: |
        - Conduct root cause analysis
        - Update detection rules
        - Improve response playbook
        - Report to leadership
      automation: "manual"
      tools: ["Case Management", "SIEM", "Analytics"]
      timeout: "4h"
```

---

## Part 5: Capstone - Implementation Roadmap

#### File: `capstone/06_implementation_roadmap.md` (Excerpt)

```markdown
# Implementation Roadmap - Nexus Global Industries
## 18-Month Security Architecture Transformation Plan

## 2. Implementation Phases

### Phase 1: Foundation (Months 1-6)
**Focus:** Establish governance, identity, and foundational controls

| Milestone | Deliverable | Timeline | Owner |
|-----------|-------------|----------|-------|
| SABSA Framework | Complete architecture framework | Month 1 | Lead Architect |
| NIST CSF 2.0 | Governance policies | Month 2 | Lead Architect |
| ISO 27001 ISMS | Risk assessment, SoA | Month 3 | GRC Manager |
| Keycloak Deployment | Identity Provider | Month 4 | Security Engineer |
| MFA Enforcement | All users MFA-enabled | Month 5 | Security Engineer |
| Zero Trust Foundation | OPA PDP/PEP | Month 6 | Lead Architect |

**Investment:** $8.5M

### Phase 2: Zero Trust & Cloud (Months 7-12)
**Focus:** Zero Trust rollout, cloud security, container security

| Milestone | Deliverable | Timeline | Owner |
|-----------|-------------|----------|-------|
| Istio Service Mesh | mTLS for all services | Month 7 | Platform Engineer |
| Micro-segmentation | Network policies | Month 8 | Platform Engineer |
| Multi-Cloud Landing Zones | AWS + Azure setup | Month 9 | Cloud Architect |
| CSPM Automation | Security Hub + Security Center | Month 10 | Cloud Architect |
| Container Security | Trivy, Kyverno | Month 11 | DevSecOps Engineer |
| API Security | Kong + OWASP protections | Month 12 | DevSecOps Engineer |

**Investment:** $9.5M

### Phase 3: Detection & Response (Months 13-15)
**Focus:** SIEM, detection, response automation

| Milestone | Deliverable | Timeline | Owner |
|-----------|-------------|----------|-------|
| SIEM/XDR | ELK Stack + CrowdStrike | Month 13 | Detection Engineer |
| Detection Rules | 10+ Sigma rules | Month 14 | Detection Engineer |
| SOAR Automation | Playbooks + integrations | Month 14 | IR Manager |
| Threat Hunting | Hunting program | Month 15 | Lead Threat Hunter |

**Investment:** $5.5M

### Phase 4: Resilience & Capstone (Months 16-18)
**Focus:** Chaos engineering, business continuity, final integration

| Milestone | Deliverable | Timeline | Owner |
|-----------|-------------|----------|-------|
| Chaos Engineering | Gremlin + custom tests | Month 16 | Lead Architect |
| Immutable Backups | S3 Object Lock | Month 16 | SRE |
| Air-Gapped Vaults | Primary + secondary | Month 17 | SRE |
| BCP Complete | Plan + testing | Month 17 | CISO |
| Capstone Delivery | Complete blueprint | Month 18 | Lead Architect |

**Investment:** $3.5M

---

## 3. Detailed Timeline

```
Q3 2026        Q4 2026        Q1 2027        Q2 2027        Q3 2027        Q4 2027
│              │              │              │              │              │
│  Phase 1     │  Phase 1     │  Phase 2     │  Phase 2     │  Phase 3     │  Phase 4     │
│  ──────────  │  ──────────  │  ──────────  │  ──────────  │  ──────────  │  ──────────  │
│              │              │              │              │              │              │
│  SABSA       │  Keycloak   │  Istio      │  Multi-Cloud │  SIEM        │  Chaos       │
│  NIST CSF    │  MFA        │  Micro-seg  │  CSPM        │  Rules       │  Backups     │
│  ISO 27001   │  OPA        │  Container  │  API Sec     │  SOAR        │  Vaults      │
│              │              │              │              │  Hunting     │  BCP         │
│              │              │              │              │              │  Capstone    │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

## 5. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Zero Trust Coverage** | 100% | % of workloads with PDP/PEP |
| **MFA Coverage** | 100% | IdP reports |
| **MTTD** | < 60 minutes | SIEM metrics |
| **MTTR** | < 4 hours | Incident metrics |
| **RTO** | < 2 hours (Tier 0) | DR tests |
| **RPO** | < 15 minutes (Tier 0) | Backup tests |
| **Compliance** | Zero critical findings | Audits |
| **Pipeline Block Rate** | < 10% | CI/CD metrics |
```

---

## Quick Deployment Commands

### Kubernetes Deployments

```bash
# Deploy Keycloak
kubectl apply -f iam/01_keycloak_configuration.yaml

# Deploy OPA PDP
kubectl apply -f zero_trust/03_pep_configuration.yaml

# Deploy Kyverno Policies
kubectl apply -f k8s/04_admission_controllers.yaml

# Deploy ELK Stack
kubectl apply -f siem/01_elasticsearch.yaml
kubectl apply -f siem/02_logstash_pipelines.yaml
kubectl apply -f siem/03_kibana_dashboards.yaml

# Deploy SOAR Playbooks
kubectl apply -f soar/01_playbooks.yaml
```

### Terraform Deployment

```bash
# Deploy AWS Landing Zone
terraform apply -target=aws_organizations_organization.nexus
terraform apply -target=aws_securityhub_account.nexus
terraform apply

# Deploy Azure Landing Zone
terraform apply -target=azurerm_management_group.nexus
terraform apply -target=azurerm_security_center_subscription_pricing.nexus
terraform apply
```

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX D]**

This appendix contains all configuration files and code snippets from the series. Use these as reference during implementation or customize them for your specific environment.
