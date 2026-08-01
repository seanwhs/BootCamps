# Appendix B: Framework Reference & Quick Reference Guides
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Framework Integration Reference

## Overview

This appendix provides quick reference guides for all frameworks integrated throughout the series, including key concepts, control mappings, and cross-framework relationships. Use this as a reference during implementation and architecture reviews.

---

## 1. SABSA Framework Reference

### 1.1 The Six Layers

| Layer | Question | Focus | Artifact |
|-------|----------|-------|----------|
| **Contextual** | Why? | Business requirements, risk appetite | Business Context Document |
| **Conceptual** | What? | Security strategy, service framework | Strategy Document |
| **Logical** | How? | Security services, mechanisms | Service Matrix |
| **Physical** | Where? | Technology stack, deployment | Technology Architecture |
| **Component** | Who/Which? | Components, configurations | Component Specifications |
| **Operational** | When/Where/How? | Procedures, governance | Operational Procedures |

### 1.2 Attribute Traceability Matrix Template

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SABSA ATTRIBUTE TRACEABILITY                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Business Attribute → Service → Mechanism → Technology → Component → Ops   │
│                                                                             │
│  Example:                                                                   │
│  Confidentiality → Access Control → MFA → Keycloak → WebAuthn → Rotation   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Key Deliverables Checklist

| Deliverable | Description | Status |
|-------------|-------------|--------|
| [ ] Business Context Document | Business drivers, risk appetite | ☐ |
| [ ] Security Strategy Document | Service framework, principles | ☐ |
| [ ] Service Matrix | Mechanisms, technology mapping | ☐ |
| [ ] Technology Architecture | Stack selection, topology | ☐ |
| [ ] Component Specifications | Detailed configurations | ☐ |
| [ ] Operational Procedures | Governance, runbooks | ☐ |

---

## 2. NIST CSF 2.0 Reference

### 2.1 The Six Functions

| Function | Purpose | Key Activities |
|----------|---------|----------------|
| **Govern (GV)** | Establish cybersecurity strategy, expectations, and oversight | Policy, risk management, roles |
| **Identify (ID)** | Understand organizational assets, risks, and capabilities | Asset inventory, risk assessment |
| **Protect (PR)** | Implement safeguards to ensure delivery of critical services | Access control, data security |
| **Detect (DE)** | Identify the occurrence of a cybersecurity event | Monitoring, detection engineering |
| **Respond (RS)** | Take action regarding a detected cybersecurity incident | IR planning, analysis, mitigation |
| **Recover (RC)** | Restore capabilities and services impaired by an incident | Recovery planning, improvements |

### 2.2 CSF Categories Quick Reference

| Function | Categories |
|----------|------------|
| **Govern** | GV.OC, GV.RM, GV.RR, GV.PO, GV.OV, GV.SC, GV.AW, GV.FI |
| **Identify** | ID.AM, ID.RA, ID.BE, ID.GV, ID.IM |
| **Protect** | PR.AC, PR.AT, PR.DS, PR.IP, PR.MA, PR.ND, PR.IR |
| **Detect** | DE.AE, DE.CM, DE.DP, DE.AR, DE.DU, DE.SR |
| **Respond** | RS.RP, RS.AN, RS.MI, RS.IM, RS.CO |
| **Recover** | RC.RP, RC.IM, RC.RI, RC.RC |

### 2.3 CSF-SABSA Mapping Quick Reference

| CSF Function | SABSA Layer | Primary Document |
|--------------|-------------|------------------|
| Govern | Contextual + Operational | 01_contextual_architecture.md |
| Identify | Contextual | 01_contextual_architecture.md |
| Protect | Logical + Physical | 03_logical_architecture.md |
| Detect | Logical + Operational | 03_logical_architecture.md |
| Respond | Operational | 06_operational_architecture.md |
| Recover | Operational + Physical | 06_operational_architecture.md |

### 2.4 CSF Implementation Checklist

| Function | Status | Owner |
|----------|--------|-------|
| [ ] Govern - Policies established | ☐ | CISO |
| [ ] Identify - Asset inventory complete | ☐ | Lead Architect |
| [ ] Protect - Controls implemented | ☐ | Security Engineers |
| [ ] Detect - Monitoring operational | ☐ | Detection Engineers |
| [ ] Respond - IR playbooks tested | ☐ | IR Manager |
| [ ] Recover - DR plans validated | ☐ | Lead Architect |

---

## 3. ISO 27001 Reference

### 3.1 ISMS Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ISO 27001 ISMS COMPONENTS                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ISMS POLICY                                                       │   │
│  │  • Scope definition                                               │   │
│  │  • Management commitment                                          │   │
│  │  • Objectives                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  RISK ASSESSMENT                                                   │   │
│  │  • Asset inventory                                                │   │
│  │  • Threat identification                                          │   │
│  │  • Vulnerability assessment                                      │   │
│  │  • Risk scoring (Likelihood × Impact)                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  RISK TREATMENT                                                    │   │
│  │  • Control selection (Annex A)                                    │   │
│  │  • Statement of Applicability (SoA)                               │   │
│  │  • Treatment plans                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  IMPLEMENTATION & OPERATION                                        │   │
│  │  • Control implementation                                         │   │
│  │  • Training and awareness                                         │   │
│  │  • Monitoring and measurement                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  MONITORING & REVIEW                                               │   │
│  │  • Internal audits                                                │   │
│  │  • Management review                                              │   │
│  │  • Continuous improvement                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Annex A Control Categories

| Category | Control Count | Key Controls |
|----------|---------------|--------------|
| **A.5: Organizational Controls** | 37 | Information security policies, roles, access control |
| **A.6: People Controls** | 8 | Screening, employment terms, awareness |
| **A.7: Physical Controls** | 14 | Physical security, equipment, cabling |
| **A.8: Technology Controls** | 34 | Vulnerability management, logging, encryption |

### 3.3 Key Annex A Controls

| Control ID | Name | Priority |
|------------|------|----------|
| A.5.1 | Information Security Policy | HIGH |
| A.5.15 | Access Control Policy | HIGH |
| A.5.17 | Authentication | HIGH |
| A.5.18 | Privileged Access Rights | HIGH |
| A.5.25 | Secure Development Lifecycle | HIGH |
| A.5.29 | Security Testing | HIGH |
| A.5.42 | Audit Logging | HIGH |
| A.5.54 | Backup and Recovery | HIGH |
| A.5.55 | Cryptographic Controls | HIGH |
| A.8.9 | Vulnerability Management | HIGH |

### 3.4 Risk Scoring Matrix

| Likelihood | Impact 1 (Low) | Impact 2 (Medium) | Impact 3 (High) | Impact 4 (Very High) | Impact 5 (Critical) |
|------------|----------------|-------------------|-----------------|----------------------|---------------------|
| 1 (Very Low) | 1 | 2 | 3 | 4 | 5 |
| 2 (Low) | 2 | 4 | 6 | 8 | 10 |
| 3 (Moderate) | 3 | 6 | 9 | 12 | 15 |
| 4 (High) | 4 | 8 | 12 | 16 | 20 |
| 5 (Very High) | 5 | 10 | 15 | 20 | 25 |

**Risk Levels:**
- **1-4**: LOW (Accept/Monitor)
- **5-9**: MEDIUM (Treat within 6 months)
- **10-14**: HIGH (Treat within 3 months)
- **15-25**: CRITICAL (Treat immediately)

---

## 4. MITRE ATT&CK Reference

### 4.1 The 14 Tactics

| Tactic | Description | Key Techniques |
|--------|-------------|----------------|
| **Reconnaissance** | Gather information about the target | T1595 (Active Scanning) |
| **Resource Development** | Build infrastructure for attack | T1583 (Acquire Infrastructure) |
| **Initial Access** | Gain entry to the environment | T1078 (Valid Accounts), T1190 (Exploit Public App) |
| **Execution** | Run malicious code | T1059 (Command & Scripting Interpreter) |
| **Persistence** | Maintain foothold | T1053 (Scheduled Task/Job) |
| **Privilege Escalation** | Gain higher-level permissions | T1068 (Exploit for Priv Escalation) |
| **Defense Evasion** | Avoid detection | T1578 (Modify Cloud Infrastructure) |
| **Credential Access** | Steal credentials | T1003 (OS Credential Dumping) |
| **Discovery** | Learn about the environment | T1087 (Account Discovery) |
| **Lateral Movement** | Move through the environment | T1021 (Remote Services) |
| **Collection** | Gather target data | T1119 (Automated Collection) |
| **Command & Control** | Communicate with compromised systems | T1071 (Application Layer Protocol) |
| **Exfiltration** | Steal data | T1041 (Exfiltration Over C2) |
| **Impact** | Disrupt or destroy systems | T1486 (Data Encrypted for Impact) |

### 4.2 Key Techniques for Enterprise Security

| Technique ID | Name | Tactic | Controls |
|--------------|------|--------|----------|
| T1078 | Valid Accounts | Initial Access | MFA, Zero Trust |
| T1190 | Exploit Public-Facing App | Initial Access | WAF, API Security |
| T1053 | Scheduled Task/Job | Persistence | Monitoring, Audit |
| T1068 | Exploit for Priv Escalation | Privilege Escalation | Least Privilege, JIT |
| T1003 | OS Credential Dumping | Credential Access | MFA, EDR |
| T1021 | Remote Services | Lateral Movement | Micro-segmentation |
| T1041 | Exfiltration Over C2 | Exfiltration | DLP, Monitoring |
| T1486 | Data Encrypted for Impact | Impact | Immutable Backups |
| T1578 | Modify Cloud Infrastructure | Defense Evasion | CSPM, IaC Scanning |

### 4.3 Detection Rule Template (Sigma)

```yaml
title: "Rule Title"
id: "rule-xxx"
status: "production"
description: "Description of what the rule detects"
author: "Author Name"
date: "YYYY-MM-DD"
tags:
  - attack.tXXXX
  - attack.tactic_name
logsource:
  product: windows|linux|aws|azure
  service: service_name
detection:
  selection:
    FieldName: "Value"
  condition: selection
falsepositives:
  - "Legitimate activity that might trigger"
level: high|medium|low|critical
```

---

## 5. Zero Trust Architecture Reference (NIST SP 800-207)

### 5.1 Core Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Continuous Verification** | Every access request is verified | OPA, continuous monitoring |
| **Least Privilege** | Minimum permissions needed | RBAC/ABAC, JIT |
| **Assume Breach** | Never trust internal networks | Micro-segmentation |
| **Micro-segmentation** | Fine-grained network isolation | Calico, Istio |
| **Encrypt Everything** | All traffic is encrypted | mTLS, TLS 1.3 |

### 5.2 ZTA Components

| Component | Purpose | Implementation |
|-----------|---------|----------------|
| **PDP (Policy Decision Point)** | Makes access decisions | OPA |
| **PEP (Policy Enforcement Point)** | Enforces decisions | Istio, Kong, Calico |
| **PAP (Policy Administration Point)** | Manages policies | Git + CI/CD |
| **PIP (Policy Information Point)** | Provides context | Keycloak, CrowdStrike |

### 5.3 ZTA Policy Example (Rego)

```rego
# Service-to-Service Access
allow = true {
    input.source.service in allowed_services[input.target.service]
    input.mtls == true
}

# User Access
allow = true {
    input.user.authenticated == true
    input.user.mfa_enabled == true
    input.device.posture == "compliant"
    input.resource.classification in user_clearance[input.user.role]
}

# Context-Aware Access
allow = true {
    input.user.authenticated == true
    input.user.mfa_enabled == true
    risk_level(input.context) == "low"
}
```

---

## 6. OWASP API Security Top 10 Reference

### 6.1 The Top 10

| Rank | Vulnerability | Description | Protection |
|------|---------------|-------------|------------|
| 1 | Broken Object Level Authorization | User can access objects they shouldn't | BOLA protection |
| 2 | Broken Authentication | Weak authentication mechanisms | JWT, MFA, OIDC |
| 3 | Excessive Data Exposure | API returns too much data | Response filtering |
| 4 | Lack of Resources & Rate Limiting | No limits on API usage | Rate limiting, throttling |
| 5 | Broken Function Level Authorization | Function access not validated | Function auth checks |
| 6 | Mass Assignment | User can modify fields they shouldn't | Schema validation |
| 7 | Security Misconfiguration | Misconfigured security settings | Header checks, hardening |
| 8 | Injection | SQL, NoSQL, command injection | Input validation, sanitization |
| 9 | Improper Asset Management | Exposed old API versions | Deprecation headers |
| 10 | Insufficient Logging & Monitoring | No visibility into attacks | SIEM, audit logging |

### 6.2 API Security Checklist

| Check | Implementation |
|-------|----------------|
| [ ] Authentication required for all endpoints | OIDC, JWT |
| [ ] MFA for sensitive operations | WebAuthn, TOTP |
| [ ] Rate limiting configured | Kong rate-limit plugin |
| [ ] Input validation implemented | JSON Schema, sanitization |
| [ ] Output filtering applied | OWASP plugin |
| [ ] CORS properly configured | CORS headers |
| [ ] HTTPS enforced | TLS 1.3 |
| [ ] Audit logging enabled | SIEM integration |
| [ ] Security headers present | OWASP plugin |

---

## 7. CIS Benchmarks Reference

### 7.1 AWS CIS Controls

| Control ID | Description | Priority |
|------------|-------------|----------|
| 1.1 | Avoid the use of the root user | CRITICAL |
| 1.2 | MFA enabled for root user | CRITICAL |
| 2.1 | CloudTrail enabled | HIGH |
| 3.1 | S3 bucket logging enabled | HIGH |
| 4.1 | Security group restrictions | CRITICAL |
| 5.1 | IAM password policy | HIGH |

### 7.2 Kubernetes CIS Controls

| Control ID | Description | Priority |
|------------|-------------|----------|
| 1.1.1 | API server pod specification | HIGH |
| 1.1.2 | API server authentication | HIGH |
| 1.1.3 | API server authorization (RBAC) | HIGH |
| 4.2.6 | Protect kernel defaults | HIGH |
| 5.1.1 | Pod security policies | HIGH |

---

## 8. Quick Reference: RTO/RPO Targets

### 8.1 Nexus Global Industries Targets

| Tier | Description | RTO | RPO | Recovery Method |
|------|-------------|-----|-----|-----------------|
| **Tier 0** | Critical | 2 hours | 15 minutes | Active-Active |
| **Tier 1** | High | 4 hours | 1 hour | Active-Passive |
| **Tier 2** | Medium | 8 hours | 4 hours | Active-Passive |
| **Tier 3** | Low | 24 hours | 24 hours | Active-Passive |

### 8.2 Backup Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Immutable Backups** | WORM-protected storage | Tier 0-1 |
| **Air-Gapped Vaults** | Offline, isolated storage | Worst-case recovery |
| **Cross-Cloud Replication** | AWS → Azure replication | Cloud DR |
| **SaaS Provider** | Provider-managed backups | Tier 2-3 |

---

## 9. Quick Reference: Security Metrics

### 9.1 Key Performance Indicators

| Metric | Target | Measurement |
|--------|--------|-------------|
| **MTTD** | < 60 minutes | SIEM metrics |
| **MTTR** | < 4 hours | Incident metrics |
| **MFA Coverage** | 100% | IdP reports |
| **Zero Trust Coverage** | 100% | % with PDP/PEP |
| **RTO Achievement** | < 2 hours (Tier 0) | DR tests |
| **RPO Achievement** | < 15 minutes (Tier 0) | Backup tests |
| **False Positive Rate** | < 3% | Alert reports |
| **Compliance Score** | > 95% | Compliance scans |

### 9.2 Compliance Metrics

| Standard | Target | Measurement |
|----------|--------|-------------|
| **NIST CSF** | Level 4 | Maturity assessment |
| **ISO 27001** | Certified | Audit results |
| **CIS Benchmarks** | > 90% | Compliance scans |
| **OWASP API Top 10** | All protected | Security tests |

---

## 10. Technology Stack Quick Reference

### 10.1 Core Security Technologies

| Domain | Technology | Purpose |
|--------|------------|---------|
| **Identity** | Keycloak | Identity Provider |
| **Policy** | OPA | Policy Engine |
| **Secrets** | HashiCorp Vault | Secrets Management |
| **Service Mesh** | Istio | mTLS, Authorization |
| **API Gateway** | Kong | API Security |
| **Network Policies** | Calico | Micro-segmentation |
| **Container Scan** | Trivy | Vulnerability Scanning |
| **Admission Control** | Kyverno | Policy Enforcement |
| **SIEM** | ELK Stack | Centralized Logging |
| **XDR** | CrowdStrike | Endpoint Security |
| **SOAR** | TheHive/Cortex | Automation |
| **Chaos** | Gremlin | Chaos Engineering |

### 10.2 Deployment Commands

```bash
# Deploy Keycloak
kubectl apply -f iam/01_keycloak_configuration.yaml

# Deploy OPA
kubectl apply -f zero_trust/03_pep_configuration.yaml

# Deploy Istio
istioctl install --set profile=demo -y

# Deploy Kong
helm install kong kong/kong -f api/01_gateway_security.yaml

# Deploy ELK Stack
kubectl apply -f siem/01_elasticsearch.yaml
kubectl apply -f siem/02_logstash_pipelines.yaml
kubectl apply -f siem/03_kibana_dashboards.yaml

# Deploy Kyverno
kubectl apply -f k8s/04_admission_controllers.yaml

# Deploy Trivy
kubectl apply -f k8s/01_image_security.yaml
```

---

## 11. Framework Integration Quick Reference

### 11.1 Mapping Summary

| SABSA Layer | NIST CSF Function | ISO 27001 Annex A | MITRE ATT&CK |
|-------------|-------------------|-------------------|--------------|
| Contextual | Govern, Identify | Risk Assessment | Threat Intelligence |
| Conceptual | Govern, Identify | A.5 Controls | Tactic Mapping |
| Logical | Protect | A.8 Controls | Technique Mapping |
| Physical | Protect, Detect | A.7 Controls | Detection Rules |
| Component | Protect, Detect | A.8 Controls | Control Implementation |
| Operational | Respond, Recover | A.6 Controls | Response Playbooks |

### 11.2 Document Cross-Reference

| Requirement | SABSA | NIST CSF | ISO 27001 | MITRE ATT&CK |
|-------------|-------|----------|-----------|--------------|
| Governance | Contextual/Operational | Govern | A.5 | N/A |
| Risk Management | Contextual | Identify | Risk Assessment | Threat Intel |
| Access Control | Logical | Protect | A.5.15 | T1078 |
| Incident Response | Operational | Respond | A.5.45 | TTP Mapping |
| Business Continuity | Operational | Recover | A.5.46 | Impact |

---

## 12. Glossary of Terms

| Term | Definition |
|------|------------|
| **ABAC** | Attribute-Based Access Control - access based on attributes |
| **BCP** | Business Continuity Plan - plan for maintaining operations during disruption |
| **CSPM** | Cloud Security Posture Management - cloud compliance monitoring |
| **DAST** | Dynamic Application Security Testing - testing running applications |
| **IAM** | Identity and Access Management - managing user identities and access |
| **JEA** | Just Enough Administration - minimal permissions for privileged access |
| **JIT** | Just-In-Time - temporary privileged access |
| **MTTD** | Mean Time To Detect - average time to detect incidents |
| **MTTR** | Mean Time To Respond - average time to respond and recover |
| **PAM** | Privileged Access Management - managing privileged accounts |
| **PDP** | Policy Decision Point - component that makes access decisions |
| **PEP** | Policy Enforcement Point - component that enforces access decisions |
| **RPO** | Recovery Point Objective - maximum acceptable data loss |
| **RTO** | Recovery Time Objective - maximum acceptable downtime |
| **SAST** | Static Application Security Testing - analyzing code without running it |
| **SCA** | Software Composition Analysis - analyzing third-party dependencies |
| **SDP** | Software-Defined Perimeter - network perimeter that hides infrastructure |
| **SIEM** | Security Information and Event Management - centralized logging and analysis |
| **SOAR** | Security Orchestration, Automation, and Response - automated incident response |
| **XDR** | Extended Detection and Response - endpoint detection and response |

---

## 13. Architecture Review Checklist

### 13.1 Governance Review

| Check | Status | Notes |
|-------|--------|-------|
| [ ] SABSA framework complete | ☐ | |
| [ ] NIST CSF 2.0 implemented | ☐ | |
| [ ] ISO 27001 ISMS established | ☐ | |
| [ ] Risk assessment performed | ☐ | |
| [ ] Policies documented | ☐ | |
| [ ] Roles defined | ☐ | |

### 13.2 Zero Trust Review

| Check | Status | Notes |
|-------|--------|-------|
| [ ] PDP deployed | ☐ | |
| [ ] PEP deployed | ☐ | |
| [ ] mTLS enforced | ☐ | |
| [ ] Micro-segmentation active | ☐ | |
| [ ] Continuous verification | ☐ | |
| [ ] MFA coverage 100% | ☐ | |

### 13.3 Cloud Security Review

| Check | Status | Notes |
|-------|--------|-------|
| [ ] Multi-cloud landing zones | ☐ | |
| [ ] CSPM active | ☐ | |
| [ ] Container scanning | ☐ | |
| [ ] K8s admission controllers | ☐ | |
| [ ] API security configured | ☐ | |
| [ ] CI/CD security gates | ☐ | |

### 13.4 Detection & Response Review

| Check | Status | Notes |
|-------|--------|-------|
| [ ] SIEM operational | ☐ | |
| [ ] Detection rules deployed | ☐ | |
| [ ] Threat hunting program | ☐ | |
| [ ] SOAR playbooks | ☐ | |
| [ ] Chaos engineering | ☐ | |
| [ ] BCP tested | ☐ | |

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX B]**

This appendix provides quick reference guides for all frameworks, technologies, and processes used throughout the series. Use it during implementation, architecture reviews, and team training sessions.
