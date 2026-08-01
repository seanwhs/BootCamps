# Part 1: Foundations of Secure Architecture & Framework Integration
## Section 1.1: SABSA Enterprise Security Architecture Framework

## The Target: SABSA Framework for Nexus Global Industries

In this section, we'll build the complete **SABSA (Sherwood Applied Business Security Architecture)** framework for Nexus Global Industries. SABSA is a business-driven security architecture methodology that ensures every security control we implement directly supports business objectives.

**What specific file(s) are we building?**
- `sabsa_framework/01_contextual_architecture.xlsx` - Business context and requirements
- `sabsa_framework/02_conceptual_architecture.md` - High-level security strategy
- `sabsa_framework/03_logical_architecture.xlsx` - Security services and mechanisms
- `sabsa_framework/04_physical_architecture.md` - Technology implementation mapping
- `sabsa_framework/05_component_architecture.yaml` - Detailed component specifications
- `sabsa_framework/06_operational_architecture.md` - Operational procedures and governance

---

## The Concept: SABSA Architecture in Plain English

Think of SABSA like building a house:

**Contextual Layer (Why):** The owner says, "I need a house for my family of 5 with space for aging parents and a home office." This is the business requirement.

**Conceptual Layer (What):** The architect says, "We need a 4-bedroom, 2-story house with a ground-floor master suite and a dedicated office wing." This is the security strategy.

**Logical Layer (How):** The designer says, "We'll have load-bearing walls here, plumbing here, electrical here, and windows facing south for natural light." This is the security services specification.

**Physical Layer (Where):** The builder says, "We'll use 2x4 studs, drywall, copper plumbing, and this specific roofing material." This is the technology implementation.

**Component Layer (Who/Which):** The subcontractor says, "We need the HVAC unit from Carrier, the electrical panel from Siemens, and these specific light fixtures." This is the detailed component inventory.

**Operational Layer (When/Where/How):** The homeowner's manual says, "Change the HVAC filter quarterly, test the smoke detectors monthly, and have the roof inspected every 2 years." This is the operational governance.

Each layer maps down to the layer below it, creating a **traceability matrix** that connects every security control back to a business requirement.

---

## Implementation Phase

### Step 1: Create the Project Structure

First, let's create the directory structure for our SABSA framework:

```bash
# Create the project root directory
mkdir -p ~/nexus_security_architecture
cd ~/nexus_security_architecture

# Create the SABSA framework directory
mkdir -p sabsa_framework

# Verify the structure
ls -la
```

**Verification:**
```bash
# You should see the sabsa_framework directory
# Run this command to confirm:
ls -la sabsa_framework/
# Expected output: total 0 (empty directory, ready for files)
```

---

### Step 2: Contextual Architecture - Business Context

The Contextual Layer captures the business requirements, environment, and risk appetite. This is the "Why" of our security architecture.

**File:** `sabsa_framework/01_contextual_architecture.xlsx`

Since we're creating structured data, we'll use a CSV format that can be imported into Excel. This is more code-friendly and version-controllable.

**File:** `sabsa_framework/01_contextual_architecture.csv`

```csv
"Category","Attribute","Value","Notes"
"Business Requirements","Company Name","Nexus Global Industries","Multinational manufacturing and technology services"
"Business Requirements","Industry","Advanced Manufacturing + Technology Services","OT/ICS + AI/ML R&D + B2B SaaS"
"Business Requirements","Employees","15,000","42 countries"
"Business Requirements","Annual Revenue","$4.2B","USD"
"Business Requirements","Headquarters","Singapore","Regional hubs: London, Austin, Tokyo"
"Business Requirements","Regulatory Landscape","GDPR,NIST 800-171,Local Privacy Laws","EU, US, and APAC jurisdictions"
"Business Attributes","Confidentiality Requirement","HIGH","IP protection critical for R&D and manufacturing processes"
"Business Attributes","Integrity Requirement","HIGH","Manufacturing control systems require exact data integrity"
"Business Attributes","Availability Requirement","CRITICAL","Manufacturing outages cost $2.4M/hour"
"Business Attributes","Safety Requirement","CRITICAL","OT systems impact physical safety"
"Risk Environment","Known Threat Actors","Nation-state APTs,Ransomware Gangs,Insider Threats","Industry-specific targeting"
"Risk Environment","Previous Incidents","Code Repository Breach,Ransomware in Europe","2023-2024 incidents"
"Risk Environment","Risk Appetite","MODERATE-HIGH","Aggressive for innovation, conservative for IP/PII"
"Business Drivers","Cloud Transformation","50% workloads already cloud","Multi-cloud: AWS + Azure"
"Business Drivers","Digital Twin Initiative","Manufacturing digital twins in development","Critical IP"
"Business Drivers","Customer Portal Growth","50,000+ transactions/day","B2B platform expansion"
"Security Objectives","Prevent Data Breach","Top priority","Focus on IP and PII"
"Security Objectives","Ensure Business Continuity","RTO < 2 hours, RPO < 15 minutes","Manufacturing critical"
"Security Objectives","Maintain Regulatory Compliance","Zero significant findings","GDPR, NIST, Local laws"
```

**File:** `sabsa_framework/01_contextual_architecture.md`

```markdown
# SABSA Contextual Architecture - Nexus Global Industries
## Business Context and Security Requirements

## Executive Summary

Nexus Global Industries is a $4.2B multinational corporation operating in the advanced manufacturing and technology services sector. With 15,000 employees across 42 countries and three regional hubs (Singapore, London, Austin, Tokyo), the company is undergoing a significant cloud transformation while maintaining critical OT/ICS manufacturing operations.

### Business Mission

> "To revolutionize global manufacturing through AI-driven precision engineering while maintaining the highest standards of quality, safety, and security."

### Critical Business Assets

1. **Intellectual Property**
   - Proprietary AI/ML algorithms for manufacturing optimization
   - Manufacturing process designs and automation code
   - Digital twin models of factory operations
   - Customer-specific manufacturing recipes

2. **Customer Data**
   - B2B customer orders and specifications (50,000+ transactions/day)
   - Contracts, pricing, and commercial agreements
   - Customer support and interaction history
   - Payment and financial information

3. **Operational Technology**
   - Factory control systems (PLC, SCADA, DCS)
   - IoT sensor networks
   - Quality control systems
   - Safety systems

4. **Employee and HR Data**
   - Personal Identifiable Information (PII) for 15,000 employees
   - Payroll and benefits data
   - Performance and talent management data

5. **Financial Systems**
   - ERP and financial reporting systems
   - Payment processing
   - Treasury and banking systems

### Regulatory Obligations

| Regulation | Jurisdiction | Application |
|------------|--------------|-------------|
| GDPR | EU/Global | Personal data of EU citizens |
| NIST SP 800-171 | US Government | Defense and government contracts |
| CCPA/CPRA | California | Personal data of CA residents |
| PDPA | Singapore | Personal data of Singapore residents |
| Local Manufacturing Regulations | Various | OT/ICS safety and security |
| Export Controls | US/Global | Technology and IP export restrictions |

### Business Goals Driving Security Architecture

1. **Cloud-First Transformation**
   - Move 80% of workloads to public cloud (AWS/Azure) within 24 months
   - Maintain hybrid operations for OT/ICS workloads
   - Enable agile, DevOps-driven delivery

2. **Digital Twin Initiative**
   - Build real-time digital replicas of all manufacturing facilities
   - Enable remote monitoring and optimization
   - Protect IP as a competitive differentiator

3. **Customer Experience Excellence**
   - Expand B2B customer portal capabilities
   - Reduce onboarding friction
   - Enable 24/7 global customer support

4. **Operational Efficiency**
   - Reduce IT operating costs by 30%
   - Increase deployment velocity (from monthly to daily)
   - Zero-touch automation where possible

### Threat Environment Summary

Nexus Global Industries faces a sophisticated threat landscape:

| Threat Actor Type | Motivation | Recent Activity |
|-------------------|------------|-----------------|
| Nation-State APTs | IP theft, industrial espionage | Active targeting of manufacturing sector |
| Ransomware Gangs | Financial extortion | 2024 European datacenter ransomware incident |
| Competitors | Competitive intelligence | Known intellectual property theft attempts |
| Insider Threats | Financial, disgruntled employees | Remote workforce security challenges |
| Hacktivists | Reputational damage | Targeting environmental or geopolitical issues |

### Current Security Posture

| Domain | Current Maturity | Gaps Identified |
|--------|------------------|-----------------|
| Identity & Access | Basic AD + LDAP | No Zero Trust, limited MFA |
| Network Security | Perimeter-based | Limited east-west visibility |
| Cloud Security | Immature, ad-hoc | Inconsistent controls across clouds |
| Application Security | Traditional SDLC | No shift-left, limited DevSecOps |
| Detection & Response | Basic SIEM | Over-reliance on vendors, limited automation |
| Incident Response | Exercise annually | Untested, manual playbooks |
| Business Continuity | Existing DR plans | Not chaos-tested, RTO/RPO gaps |
| Governance | Disparate frameworks | No unified architecture methodology |

### Security Principles Adopted

The following principles guide all architectural decisions:

1. **Defense-in-Depth**: Multi-layered controls, no single point of failure
2. **Zero Trust**: Verify explicitly, use least privilege, assume breach
3. **Secure by Default**: Secure configurations out-of-the-box
4. **Fail Secure**: Systems fail to a safe, deny-by-default state
5. **Security as Code**: All security artifacts version-controlled and tested
6. **Continuous Verification**: Never stop assessing trust and risk
7. **Business Alignment**: Every control directly supports business objectives
8. **Privacy by Design**: Privacy controls integrated into the architecture

### Risk Appetite Statement

Nexus Global Industries has a **MODERATE-HIGH** risk appetite for:

- **Business agility and innovation**: We accept some risk to move faster and innovate
- **Security transformation**: We accept short-term operational disruption for long-term security

We have a **LOW** risk appetite for:

- **Loss of intellectual property**: R&D is core to our competitive advantage
- **Personal data breaches**: Regulatory fines and reputation damage are unacceptable
- **Safety incidents**: OT system compromise affecting physical safety
- **Operational outages**: Manufacturing downtime costs millions per hour

### Business Constraints

| Constraint | Description |
|------------|-------------|
| Budget | $45M annual security budget (+15% YoY increase approved) |
| Timeline | 90 days to deliver comprehensive blueprint |
| Legacy Systems | Must support existing OT/ICS and legacy applications |
| Talent | Scaling security team from 40 to 120 over 18 months |
| Geography | Must support operations in 42 countries with varying regulations |

### Success Criteria

The security architecture will be considered successful if:

1. **Zero major security incidents** (data breaches, ransomware) in first 12 months
2. **All critical systems** have RTO < 2 hours, RPO < 15 minutes
3. **Zero Trust fully operational** across all workloads (cloud, on-premises, OT)
4. **Compliance audits** show no critical findings
5. **Development velocity** not impeded (security enables, not blocks)
6. **Detection MTTD** < 1 hour, **Response MTTR** < 4 hours
7. **Security team attrition** < 10% (building a healthy security culture)

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0  
**Approval Status**: Draft

```

**Verification:**

```bash
# Verify files have been created
ls -la sabsa_framework/
# Expected: 01_contextual_architecture.csv and 01_contextual_architecture.md

# Validate CSV structure
head -n 5 sabsa_framework/01_contextual_architecture.csv
# Expected: Shows the CSV header and first 4 data rows
```

---

### Step 3: Conceptual Architecture - Security Strategy

The Conceptual Layer translates business requirements into a security strategy. This is the "What" of our architecture.

**File:** `sabsa_framework/02_conceptual_architecture.md`

```markdown
# SABSA Conceptual Architecture - Nexus Global Industries
## Security Strategy and Service Framework

## Introduction

The Conceptual Architecture represents the security strategy for Nexus Global Industries, derived directly from the Contextual Architecture's business requirements. This document defines the security services we will implement and maps them to business attributes.

## Security Service Framework

Our security architecture is organized around 5 domains of security services, each aligned with specific business requirements:

### 1. Security Management Services
*Governance, Risk, and Compliance (GRC) - Supporting business attribute: Regulatory Compliance*

| Service | Description | Business Driver |
|---------|-------------|-----------------|
| Policy Management | Centralized security policy definition and distribution | Regulatory compliance, consistent controls |
| Risk Management | Continuous risk assessment and treatment | Risk appetite alignment |
| Compliance Monitoring | Automated compliance validation and reporting | Regulatory obligations |
| Security Governance | Board-level security reporting and oversight | Executive visibility, risk acceptance |
| Security Awareness | Employee security training and phish testing | Human risk reduction |

### 2. Enterprise Identity & Access Services
*Identity-Centric Security - Supporting business attribute: Confidentiality*

| Service | Description | Business Driver |
|---------|-------------|-----------------|
| Identity Lifecycle Management | JML (Joiner-Mover-Leaver) automation | Operational efficiency, least privilege |
| Authentication | MFA, passwordless, biometric | Zero Trust, verify explicitly |
| Authorization | Dynamic, risk-based access control | Context-aware security |
| Privileged Access Management | JIT/JEA, session recording, vaulting | Critical system protection |
| Federated Identity | SAML, OIDC across all applications | User experience, operational efficiency |
| Directory Services | Enterprise AD, LDAP, SCIM | Centralized user management |

### 3. Infrastructure & Workload Security Services
*Protect the Environment - Supporting business attribute: Integrity*

| Service | Description | Business Driver |
|---------|-------------|-----------------|
| Zero Trust Architecture | PDP/PEP separation, continuous verification | Assume breach, modern security |
| Micro-segmentation | Workload-level network isolation | Lateral movement prevention |
| Container Security | Image scanning, SBOM, signing | Software supply chain security |
| Kubernetes Security | RBAC, Admission Controllers, Pod Security | Workload protection |
| Cloud Security Posture Management | CSPM, CIS benchmarks | Consistent cloud security |
| Data Protection | Encryption at rest, in transit, DLP | Data confidentiality and privacy |

### 4. Threat & Application Security Services
*Secure Development & Threat Protection - Supporting business attribute: Confidentiality, Integrity*

| Service | Description | Business Driver |
|---------|-------------|-----------------|
| Threat Modeling | STRIDE, PASTA, Attack Trees | Proactive risk identification |
| Application Security | SAST, DAST, SCA, IAST | Shift-left security |
| API Security | OWASP Top 10 protection | Customer portal security |
| Threat Intelligence | MITRE ATT&CK aligned | Threat-informed defense |
| Vulnerability Management | Continuous scanning and remediation | Risk reduction |
| Penetration Testing | Periodic ethical hacking | Control validation |

### 5. Detection & Resilience Services
*Detect & Recover - Supporting business attribute: Availability*

| Service | Description | Business Driver |
|---------|-------------|-----------------|
| SIEM / XDR | Centralized logging and detection | Threat detection, MTTD reduction |
| Detection Engineering | MITRE-aligned rule development | Threat-informed detection |
| Incident Response | Playbook-driven response | MTTR reduction |
| SOAR | Automated containment and response | Operational efficiency |
| Business Continuity | Immutable backups, air-gapped vaults | RTO/RPO compliance |
| Chaos Engineering | Failure domain testing | Resilience validation |

## Security Concept of Operations (CONOPS)

### Zero Trust Security Model

Nexus Global Industries will adopt a comprehensive Zero Trust architecture based on NIST SP 800-207:

**Key Tenets:**
1. All resources (users, devices, workloads) are treated as untrusted until verified
2. Access decisions are made per-session, per-request
3. Dynamic policies consider identity, device posture, location, and behavior
4. Micro-segmentation limits blast radius
5. All traffic is encrypted and authenticated (mTLS)

**Architectural Components:**
- **Policy Decision Point (PDP)**: Centralized policy engine (OPA + custom plugins)
- **Policy Enforcement Point (PEP)**: Distributed enforcers (Envoy, Istio, network gateways)
- **Policy Administration Point (PAP)**: Policy management portal
- **Policy Information Point (PIP)**: Context sources (identity, device, threat intel)

### Security Operations Model

**People:**
- Security Architects (5): Design the architecture
- Security Engineers (25): Build and maintain controls
- Detection Engineers (10): Build detection rules and hunt
- Incident Responders (15): Respond to incidents
- GRC Analysts (10): Manage risk and compliance
- Security Trainers (5): Security awareness and training

**Processes:**
- Threat modeling occurs at project inception
- Security reviews are gating items in CI/CD
- Detection engineering is continuous (new rules weekly)
- Chaos engineering runs monthly on production
- Incident response tabletop exercises quarterly

**Technology:**
- All controls are "as code" (Terraform, Kubernetes, OPA)
- Continuous verification in pipelines and runtime
- Self-healing where possible (automated remediation)
- Chaos-tested for resilience

## Security Service Traceability Matrix

This matrix maps security services back to business attributes (Contextual Layer):

| Business Attribute | Security Service Domain | Specific Services |
|--------------------|-------------------------|-------------------|
| **Confidentiality** | Enterprise Identity & Access | Authentication, Authorization, PAM, Data Protection |
| | Threat & Application Security | Application Security, API Security, Threat Modeling |
| **Integrity** | Infrastructure & Workload Security | Container Security, K8s Security, Data Protection |
| | Threat & Application Security | Application Security (SAST/DAST), Vulnerability Management |
| **Availability** | Detection & Resilience | SIEM/XDR, Incident Response, Business Continuity, Chaos Engineering |
| | Infrastructure & Workload Security | Cloud Security Posture Management |
| **Safety** | Infrastructure & Workload Security | Zero Trust, Micro-segmentation (OT isolation) |
| | Detection & Resilience | Incident Response (OT-specific playbooks) |
| **Compliance** | Security Management | Policy Management, Compliance Monitoring, Risk Management |
| | Enterprise Identity & Access | Identity Lifecycle, Audit Logging |
| **Regulatory** | Security Management | Governance, Risk Management, Compliance Monitoring |
| | Threat & Application Security | Application Security (regulatory alignment) |

## Architectural Principles Applied

| Principle | How We Implement |
|-----------|------------------|
| **Defense-in-Depth** | Identity + Network + Workload + Data + Monitoring layers |
| **Zero Trust** | PEP/PDP model, continuous verification, micro-segmentation |
| **Secure by Default** | OPA policies that deny by default, secure baseline images |
| **Fail Secure** | Circuit breakers, default-deny network policies, configurable fallbacks |
| **Security as Code** | All policies in Git, CI/CD validation, policy testing |
| **Continuous Verification** | Runtime policy evaluation, anomaly detection, periodic assessments |
| **Business Alignment** | Traceability matrix, SABSA methodology, risk-based decisions |
| **Privacy by Design** | Data minimization, encryption, purpose-limited access |

## Key Performance Indicators (KPIs)

| KPI | Target | Measurement Method |
|-----|--------|-------------------|
| **Zero Trust Coverage** | 100% of workloads in 12 months | % of workloads with PDP/PEP |
| **Security Policy Compliance** | > 95% | Automated scans in CI/CD |
| **Detection MTTD** | < 60 minutes | SIEM metrics, exercises |
| **Response MTTR** | < 4 hours | Incident response metrics |
| **Chaos Test Success** | 100% auto-recovery | Gremlin/chaos tests |
| **RPO Achievement** | < 15 minutes | Backup recovery tests |
| **RTO Achievement** | < 2 hours | Failover tests |
| **CI/CD Block Rate** | < 10% | Security gates in pipelines |

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0  
**Status**: Draft - Ready for Review

```

**Verification:**

```bash
# Verify the conceptual architecture document
ls -la sabsa_framework/02_conceptual_architecture.md
# Expected: File exists

# Check document size (should be > 10KB for comprehensive content)
wc -l sabsa_framework/02_conceptual_architecture.md
# Expected: Shows line count > 200
```

---

### Step 4: Logical Architecture - Security Services Detail

The Logical Layer defines specific security services and mechanisms. This is the "How" of our architecture.

**File:** `sabsa_framework/03_logical_architecture.csv`

```csv
"Service Domain","Service Name","Security Mechanism","Technology Examples","Business Service Mapping"
"Identity & Access","Authentication","Multi-Factor Authentication (MFA)","WebAuthn, TOTP, FIDO2, SMS (fallback)","Customer Portal, Employee Access, Contractor Access"
"Identity & Access","Authentication","Passwordless Authentication","WebAuthn/FIDO2, Biometrics (fingerprint, face)","Executive Access, R&D Systems"
"Identity & Access","Authorization","Role-Based Access Control (RBAC)","Kubernetes RBAC, AWS IAM, Azure RBAC","All Systems"
"Identity & Access","Authorization","Attribute-Based Access Control (ABAC)","OPA Policies (user attributes, device posture, location)","Critical Systems, PII Access"
"Identity & Access","Authorization","Dynamic Risk-Based Access Control","Behavioral analytics + OPA, risk score thresholds","Customer Portal, Financial Systems"
"Identity & Access","Identity Lifecycle","Automated JML (Joiner-Mover-Leaver)","SCIM 2.0 protocol, HR integration","Entire Organization"
"Identity & Access","Privileged Access","Just-In-Time (JIT) Access","HashiCorp Vault, AWS IAM Roles","Infrastructure Access, Production Access"
"Identity & Access","Privileged Access","Just-Enough-Administration (JEA)","Vault dynamic credentials, least privilege policies","Admin Access, Break-Glass Access"
"Identity & Access","Privileged Access","Session Recording","HashiCorp Vault UI, AWS Session Manager","Critical Systems, Audit Compliance"
"Identity & Access","Federated Identity","SAML/OIDC Federation","Azure AD, Keycloak, Okta","Single Sign-On (SSO) to all applications"
"Infrastructure Security","Zero Trust Architecture","Policy Decision Point (PDP)","Open Policy Agent (OPA)","All Access Decisions"
"Infrastructure Security","Zero Trust Architecture","Policy Enforcement Point (PEP)","Envoy Proxy, Istio Sidecar, Kong Gateway","All Workloads"
"Infrastructure Security","Micro-segmentation","Network Policies","Kubernetes NetworkPolicy, Calico, Cilium","East-West Traffic"
"Infrastructure Security","Micro-segmentation","Service Mesh","Istio, Linkerd (mTLS, authorization policies)","Microservices Communication"
"Infrastructure Security","Container Security","Image Scanning","Trivy, Grype, Snyk","CI/CD Pipeline, Pre-Deployment"
"Infrastructure Security","Container Security","SBOM Generation","Syft, CycloneDX, SPDX","All Container Images"
"Infrastructure Security","Container Security","Image Signing","Cosign (Sigstore)","All Container Images"
"Infrastructure Security","Kubernetes Security","RBAC","Kubernetes RBAC (Roles, ClusterRoles, ServiceAccounts)","K8s Workloads"
"Infrastructure Security","Kubernetes Security","Admission Controllers","Kyverno, Gatekeeper (OPA)","K8s Workloads"
"Infrastructure Security","Kubernetes Security","Pod Security","Pod Security Standards (Baseline, Restricted)","K8s Workloads"
"Infrastructure Security","Cloud Security","Cloud Security Posture Management (CSPM)","AWS Security Hub, Azure Security Center, Prisma Cloud","Cloud Workloads"
"Infrastructure Security","Cloud Security","CIS Benchmark Enforcement","AWS Config, Azure Policy, Custom Policies","Cloud Infrastructure"
"Infrastructure Security","Data Protection","Encryption at Rest","AES-256, AWS KMS, Azure Key Vault","All Storage Systems"
"Infrastructure Security","Data Protection","Encryption in Transit","TLS 1.3, mTLS (Istio), IPsec","All Network Traffic"
"Infrastructure Security","Data Protection","Data Loss Prevention (DLP)","Cloud-based DLP (AWS Macie, Azure DLP)","Sensitive Data (PII, IP)"
"Threat & Application Security","Threat Modeling","STRIDE Methodology","Manual analysis + threat modeling tools","New Systems, Major Changes"
"Threat & Application Security","Threat Modeling","PASTA Methodology","Manual analysis + business alignment","Critical Systems, High-Risk Features"
"Threat & Application Security","Threat Modeling","Attack Trees","Manual analysis + visual modeling","Top Threats, Red Team Exercises"
"Threat & Application Security","Application Security","SAST (Static Analysis)","Semgrep, SonarQube, Checkmarx","All Code Repositories"
"Threat & Application Security","Application Security","DAST (Dynamic Analysis)","OWASP ZAP, Burp Suite, Acunetix","Public-Facing Applications"
"Threat & Application Security","Application Security","SCA (Software Composition Analysis)","Snyk, Trivy, Dependabot","All Code Repositories"
"Threat & Application Security","Application Security","IAST (Interactive Testing)","Contrast Security, Snyk IAST","Critical Applications"
"Threat & Application Security","API Security","OWASP API Top 10 Protections","Rate Limiting, JWT Validation, Input Validation, Output Encoding","All APIs"
"Threat & Application Security","API Security","API Gateway Security","Kong, AWS API Gateway, Azure API Management","All Public APIs"
"Threat & Application Security","Threat Intelligence","MITRE ATT&CK Mapping","Detection rules, Threat hunting, Purple teaming","All Security Operations"
"Threat & Application Security","Vulnerability Management","Continuous Scanning","Qualys, Tenable, AWS Inspector","All Systems"
"Threat & Application Security","Vulnerability Management","Patch Management","Automated patching, Maintenance windows","All Systems"
"Threat & Application Security","Penetration Testing","Annual + Event-driven","External vendors, Internal red team","All Critical Systems"
"Detection & Resilience","SIEM/XDR","Centralized Logging","ELK Stack, Splunk, Datadog, Sentinel","All Systems"
"Detection & Resilience","SIEM/XDR","Behavioral Analytics","UEBA tools, ML-based anomaly detection","User and Entity Behavior"
"Detection & Resilience","Detection Engineering","Sigma Rules","Sigma format → SIEM queries","All Detection Rules"
"Detection & Resilience","Detection Engineering","MITRE ATT&CK Alignment","Rules tagged with ATT&CK TTPs","All Detection Rules"
"Detection & Resilience","Incident Response","Playbook-Driven Response","NIST SP 800-61 aligned, automated or manual","All Incident Types"
"Detection & Resilience","SOAR","Automated Playbooks","n8n, TheHive, Cortex, Splunk SOAR","Common Incident Types"
"Detection & Resilience","SOAR","Alert Enrichment","Automated threat intelligence lookups","All Alerts"
"Detection & Resilience","Business Continuity","Immutable Backups","AWS S3 Object Lock, Azure Immutable Blobs","All Critical Data"
"Detection & Resilience","Business Continuity","Air-Gapped Vaults","AWS S3 Glacier Deep Archive, Azure Archive","Critical Backups, Disaster Recovery"
"Detection & Resilience","Business Continuity","Disaster Recovery","Multi-region failover, Load balancing","All Systems (RTO/RPO dependent)"
"Detection & Resilience","Chaos Engineering","Failure Domain Testing","Gremlin, Chaos Mesh, AWS Fault Injection Simulator","All Critical Systems"
"Detection & Resilience","Chaos Engineering","Resilience Validation","Automated chaos tests in non-prod, prod","All Critical Systems"
"Security Management","Policy Management","Security Policy as Code","OPA policies in Git, Kyverno policies","All Policies"
"Security Management","Policy Management","Automated Policy Enforcement","CI/CD gates, Runtime enforcement","All Environments"
"Security Management","Risk Management","Continuous Risk Assessment","Automated risk scoring, Manual reviews","All Systems"
"Security Management","Risk Management","Risk Treatment Plans","Risk Register (Excel or specialized tool)","All Identified Risks"
"Security Management","Compliance Monitoring","Automated Compliance Checks","AWS Config, Azure Policy, Security Hub","All Cloud Workloads"
"Security Management","Compliance Monitoring","Audit Reporting","Automated reports, Audit dashboards","All Compliance Frameworks"
"Security Management","Security Governance","Board Reporting","Quarterly security briefings, Dashboards","Executive Leadership"
"Security Management","Security Awareness","Phishing Simulations","Automated campaigns with metrics","All Employees"
"Security Management","Security Awareness","Role-Based Training","Engineers, Executives, General staff","All Personnel"
```

**File:** `sabsa_framework/03_logical_architecture.md`

```markdown
# SABSA Logical Architecture - Nexus Global Industries
## Security Services and Mechanisms Specification

## Overview

The Logical Architecture defines the security services, mechanisms, and operational workflows that implement the Conceptual Architecture. This layer bridges business requirements (Contextual) and technology choices (Physical).

## Service Architecture Patterns

### 1. Zero Trust Identity Pattern

```
┌──────────────────────────────────────────────────────────────┐
│                    ZERO TRUST IDENTITY PATTERN               │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────┐     ┌────────────┐    ┌──────────────────┐   │
│  │  USER   │────▶│  DEVICE    │───▶│  PDP (OPA)       │   │
│  │         │     │  TRUST     │    │  Policy Decision │   │
│  └─────────┘     └────────────┘    └────────┬─────────┘   │
│                                              │              │
│                                    ┌─────────▼─────────────┐│
│                                    │  PEP (Envoy/Istio)    ││
│                                    │  Policy Enforcement   ││
│                                    └─────────┬─────────────┘│
│                                              │              │
│                                   ┌──────────▼──────────────┐│
│                                   │    TARGET RESOURCE      ││
│                                   │    (Workload/Data/API)  ││
│                                   └─────────────────────────┘│
│                                                              │
│  Flow:                                                      │
│  1. User authenticates → gets token with context            │
│  2. Device posture verified (browser, endpoint, e.g.)       │
│  3. PDP evaluates user+device+context → Allow/Deny        │
│  4. PEP enforces decision (allow, deny, challenge)        │
│  5. All decisions logged for auditing                     │
│  6. Per-session, per-request verification               │
└──────────────────────────────────────────────────────────────┘
```

### 2. Micro-Segmentation Pattern

```
┌──────────────────────────────────────────────────────────────┐
│                MICRO-SEGMENTATION PATTERN                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PRODUCTION NAMESPACE - FINANCIAL SYSTEMS (DENIED)   │ │
│  │  ├── Payment Gateway Service                         │ │
│  │  ├── Transaction Processor Service                   │ │
│  │  └── ONLY payment-* services can talk internally    │ │
│  └────────────────────────────────────────────────────────┘ │
│                     │                                       │
│                     ▼                                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PRODUCTION NAMESPACE - CUSTOMER PORTAL (ALLOWED)    │ │
│  │  ├── Customer API Gateway                            │ │
│  │  ├── Order Service                                   │ │
│  │  └── ONLY API Gateway talks to Order Service        │ │
│  └────────────────────────────────────────────────────────┘ │
│                     │                                       │
│                     ▼                                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  DEVELOPMENT NAMESPACE (ISOLATED)                    │ │
│  │  ├── All workloads (non-critical)                    │ │
│  │  └── No production data access                       │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Policies:                                                  │
│  - All traffic denied by default                           │
│  - Explicit allows between specific workloads               │
│  - mTLS for all inter-workload communication                │
│  - Egress policies control external connectivity            │
│  - Isolation per environment (prod/dev/stage)               │
└──────────────────────────────────────────────────────────────┘
```

### 3. Detection and Response Pattern

```
┌──────────────────────────────────────────────────────────────┐
│                DETECTION & RESPONSE PATTERN                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  DATA SOURCES                                         │ │
│  │  ├── Application Logs                                 │ │
│  │  ├── System Logs (OS, Network, Containers)            │ │
│  │  ├── Identity Logs (AuthN, AuthZ)                    │ │
│  │  ├── Cloud Logs (AWS CloudTrail, Azure Monitor)      │ │
│  │  └── Security Logs (WAF, IDS/IPS, etc.)              │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │                                        │
│                     ▼                                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  SIEM/XDR PIPELINE                                    │ │
│  │  ├── Logstash/Data Collection                         │ │
│  │  ├── Elasticsearch/Indexing                          │ │
│  │  ├── Detection Rules Engine (Sigma→SIEM queries)     │ │
│  │  └── Kibana Dashboard / Visualization                │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │                                        │
│                     ▼                                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  ALERT TRIAGE & SOAR                                  │ │
│  │  ├── Initial Triage (Analyst)                         │ │
│  │  ├── Automated Enrichment (Threat Intel)              │ │
│  │  ├── Playbook Execution (SOAR)                       │ │
│  │  └── Containment / Remediation                       │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Key Metrics:                                               │
│  - MTTD Goal: < 60 minutes                                 │
│  - MTTR Goal: < 4 hours                                   │
│  - False Positive Rate Target: < 3%                      │
│  - Coverage: 100% of critical systems                      │
└──────────────────────────────────────────────────────────────┘
```

## Service-to-Mechanism Mapping Matrix

| Service | Mechanism | Implementation Detail | Verification Method |
|---------|-----------|----------------------|-------------------|
| Authentication | MFA | WebAuthn + TOTP + SMS (fallback) | Required on all accounts |
| Authorization | RBAC + ABAC | OPA policies: role-based + context-aware | Test user/role/context combinations |
| Identity Lifecycle | SCIM | HRIS → SCIM → IdP → Directory | Automated on hr changes |
| PAM | JIT + Vault | Vault Dynamic Secrets, AWS IAM Roles | Request/access workflows |
| Network Segmentation | Kubernetes NetworkPolicy | Calico enforcement, default-deny | Network policy tests |
| Service Mesh | Istio | mTLS, authorization, telemetry | Mesh health checks |
| Container Security | Trivy Scanning | CI/CD gate: fail on critical findings | CI pipeline verification |
| SBOM | Syft + Cosign | Generate SBOM, sign with Cosign | Artifact integrity check |
| K8s Security | Kyverno | Admission policies, mutation, validation | Policy test suite |
| CSPM | AWS Security Hub | CIS benchmark, security standards | Compliance dashboard |
| Data Protection | Encryption | AES-256 (at rest), TLS 1.3 (in transit) | Audit logs, compliance scans |
| Threat Modeling | STRIDE | Manual analysis + threat model tools | Threat model reviews |
| SAST | Semgrep | Rules: custom + OWASP Top 10 | CI gate on critical findings |
| DAST | OWASP ZAP | OWASP Top 10, API scanning | CI/CD pipeline integration |
| SCA | Snyk | Build-time dependency scanning | Security gating in CI/CD |
| API Security | Kong Gateway | Rate limit (100 req/min), JWT validation | API tests, load tests |
| Threat Intelligence | MITRE ATT&CK | Mapping all detection rules | ATT&CK coverage matrix |
| Vulnerability Management | Qualys | 24/7 scanning, automated alerting | Vulnerability reports |
| SIEM | ELK Stack | Logstash → Elasticsearch → Kibana | Log analysis dashboards |
| Detection Engineering | Sigma | All rules in Sigma format → SIEM | Detection rule tests |
| Incident Response | Playbooks | NIST 800-61 aligned | Tabletop exercises |
| SOAR | n8n/TheHive | Automated playbooks, manual approvals | Playbook tests |
| Immutable Backups | AWS S3 Object Lock | 30-day retention, WORM protection | Recovery tests |
| Air-Gapped Vaults | S3 Glacier Deep Archive | Offline, immutable, accessible via request | Vault recovery tests |
| Chaos Engineering | Gremlin | Infrastructure, network, and application attacks | Chaos tests pass/fail |
| Security Governance | Quarterly Reviews | Board reporting, risk acceptance | Governance meeting minutes |

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0  
**Status**: Draft - Ready for Review

```

**Verification:**

```bash
# Verify logical architecture files
ls -la sabsa_framework/03_logical_architecture.*
# Expected: CSV and MD files

# Validate CSV has all rows
wc -l sabsa_framework/03_logical_architecture.csv
# Expected: Shows around 70+ lines (includes header row)
```

---

### Step 5: Physical Architecture - Technology Implementation

The Physical Layer maps mechanisms to specific technologies. This is the "Where" of our architecture.

**File:** `sabsa_framework/04_physical_architecture.md`

```markdown
# SABSA Physical Architecture - Nexus Global Industries
## Technology Implementation Mapping

## Technology Selection Principles

1. **Cloud-Native First**: Prefer managed services where available
2. **Multi-Cloud Flexibility**: Avoid vendor lock-in when possible
3. **Open Source Prioritization**: OSS with enterprise support options
4. **Security-First**: Security features built-in, not bolted-on
5. **Operational Maturity**: Must integrate with existing team skills
6. **Cost-Effectiveness**: Balance capabilities with budget ($45M annual)

## Environment Domains

| Domain | Description | Primary Technologies |
|--------|-------------|---------------------|
| **Cloud - AWS** | Primary cloud (60% workloads) | AWS Organizations, AWS Control Tower, AWS Security Hub |
| **Cloud - Azure** | Secondary cloud (20% workloads) | Azure Landing Zones, Azure Security Center, Microsoft Sentinel |
| **On-Premises** | Legacy/OT (15% workloads) | VMWare, OT network segmentation, legacy AD |
| **OT/ICS** | Manufacturing (5% critical) | SCADA, PLC/DCS, Purdue Model segmentation |
| **Edge/K8s** | Kubernetes (All clouds + on-prem) | Amazon EKS, Azure AKS, Self-managed k8s |
| **SaaS** | Business applications | O365, Salesforce, Workday, Slack |

## Technology Stack: Complete Architecture

### 1. Identity & Access Management (IAM)

| Component | Technology | Deployment Method | Rationale |
|-----------|------------|-------------------|-----------|
| **Identity Provider** | Keycloak (OSS) / Azure AD / Okta | Managed or self-hosted | OIDC/SAML support, rich feature set |
| **MFA** | WebAuthn, TOTP, Duo Security | Integrated with IdP | Passwordless option, strong MFA |
| **Directories** | Azure AD, AWS IAM Identity Center | Managed services | Active Directory integration |
| **Federated Identity** | SAML 2.0, OIDC | Via IdP | SSO for all apps (500+ applications) |
| **SCIM** | SCIM 2.0 | IdP + Application-specific | Automated JML via Workday integration |
| **Privileged Access** | HashiCorp Vault | Self-hosted (HA mode) | Dynamic secrets, JIT, session recording |
| **Access Policy Engine** | Open Policy Agent (OPA) | Sidecar/standalone | Flexible ABAC/RBAC, declarative policies |

### 2. Zero Trust & Network Security

| Component | Technology | Deployment Method | Rationale |
|-----------|------------|-------------------|-----------|
| **Service Mesh** | Istio (primary), Linkerd (backup) | Sidecar injection | mTLS, authz, telemetry, circuit breaking |
| **API Gateway** | Kong (OSS) / AWS API Gateway | Managed or self-hosted | Rate limiting, JWT validation, OWASP |
| **Network Policies** | Calico / Cilium | Kubernetes CNI plugin | Fine-grained east-west policy enforcement |
| **Software-Defined Perimeter** | OpenZiti | Self-hosted | "Black cloud" for infrastructure |
| **Web Application Firewall** | AWS WAF, Azure WAF, ModSecurity | Managed service | OWASP Top 10 protection |
| **Load Balancer** | AWS ALB, Azure Load Balancer | Managed service | TLS termination, WebSocket support |

### 3. Kubernetes & Container Security

| Component | Technology | Deployment Method | Rationale |
|-----------|------------|-------------------|-----------|
| **Kubernetes Platform** | EKS (AWS), AKS (Azure), Rancher (on-prem) | Managed or self-hosted | Hybrid/multi-cloud consistency |
| **Container Runtime** | Docker (dev), containerd (prod) | Standard runtime | Industry standard |
| **Image Scanning** | Trivy (OSS), Snyk | CI/CD + Runtime | Comprehensive vulnerability detection |
| **SBOM Generation** | Syft (Anchore), CycloneDX | CI/CD pipeline | Software supply chain transparency |
| **Image Signing** | Cosign (Sigstore) | CI/CD pipeline | Integrity and provenance |
| **Admission Control** | Kyverno (primary), Gatekeeper (backup) | Kubernetes admission webhook | Policy enforcement at creation/update |
| **Kubernetes RBAC** | Kubernetes native | Kubernetes API | Least privilege authorization |
| **Pod Security** | Pod Security Standards (Restricted) | Kubernetes | Baseline, restricted profiles |
| **Container Registry** | AWS ECR, Azure ACR, Harbor | Managed or self-hosted | Private registry + scanning integration |

### 4. Application & API Security

| Component | Technology | Deployment Method | Rationale |
|-----------|------------|-------------------|-----------|
| **SAST** | Semgrep (OSS), SonarQube | CI/CD pipeline | Fast, customizable rules |
| **DAST** | OWASP ZAP, Burp Suite | CI/CD + Scheduled | Automated dynamic scanning |
| **SCA** | Snyk, Dependabot | CI/CD pipeline | Dependency vulnerability scanning |
| **Secrets Scanning** | TruffleHog, GitLeaks | CI/CD pipeline | Prevent credential leakage |
| **API Security** | Kong Gateway (OWASP API Top 10) | API Gateway + WAF | Rate limit (100 req/min per user) |
| **JWT Security** | JWT validation (Kong), short-lived tokens (< 15 min) | API Gateway | OAuth 2.1 best practices |

### 5. Detection & Response

| Component | Technology | Deployment Method | Rationale |
|-----------|------------|-------------------|-----------|
| **SIEM / Log Aggregation** | ELK Stack (Elasticsearch, Logstash, Kibana) / OpenSearch | Self-hosted (HA) | Cost-effective, feature-rich |
| **XDR** | CrowdStrike, Microsoft Defender, Sentinel | Managed SaaS | Endpoint, network, cloud coverage |
| **Detection Rules** | Sigma (All rules) | Convert to SIEM queries | Community-supported format |
| **Threat Intelligence** | MITRE ATT&CK (free), ThreatConnect | Manual + automated | Threat-informed defense |
| **SOAR** | n8n, TheHive, Cortex | Self-hosted + OSS | Flexible automation, no vendor lock-in |
| **Incident Management** | Jira Service Management, PagerDuty | SaaS | Escalation, communication, tracking |
| **Vulnerability Scanner** | Qualys, Tenable | SaaS | Continuous VM, compliance scanning |
| **Chaos Engineering** | Gremlin, AWS FIS, Chaos Mesh | Managed/Self-hosted | Failure injection, resiliency testing |

### 6. Data Protection & Resilience

| Component | Technology | Deployment Method | Rationale |
|-----------|------------|-------------------|-----------|
| **Encryption at Rest** | AWS KMS, Azure Key Vault | Managed service | AES-256 encryption, key rotation |
| **Encryption in Transit** | TLS 1.3 (Auto), mTLS (Istio) | Standard + Service Mesh | Full transport security |
| **Key Management** | HashiCorp Vault (primary), Cloud KMS | Self-hosted + Managed | Centralized key lifecycle |
| **DLP** | AWS Macie, Azure Purview, Nightfall | Managed service | Sensitive data discovery |
| **Immutable Backups** | AWS S3 Object Lock, Azure Immutable Blob | Managed storage | WORM (Write-Once-Read-Many) |
| **Air-Gapped Vaults** | AWS S3 Glacier Deep Archive | Managed storage | Inaccessible except through approved workflow |
| **Disaster Recovery** | Multi-region, Active-Active / Active-Passive | Infrastructure as Code | RTO < 2 hours, RPO < 15 minutes |
| **Business Continuity** | AWS Backups, Azure Site Recovery | Managed service | Automated backup schedules, DR orchestration |

### 7. CI/CD & DevSecOps

| Component | Technology | Deployment Method | Rationale |
|-----------|------------|-------------------|-----------|
| **CI/CD Platform** | GitLab CI (primary), GitHub Actions | SaaS | Integrated security scanning |
| **Infrastructure as Code** | Terraform, Terragrunt | IAC Tool | Multi-cloud consistency |
| **Configuration Management** | Kubernetes manifests, Helm charts | IAC Tool | Declarative, versioned |
| **Policy-as-Code** | OPA, Kyverno, Sentinel | IAC Tool | Automated compliance checks |
| **Security Scanning Pipeline** | GitLab SAST/DAST/SCA, Trivy, Semgrep | CI/CD integration | Shift-left, all scans automated |

## Physical Architecture Topology

```
┌─────────────────────────────────────────────────────────────────┐
│                     NEXUS GLOBAL INDUSTRIES                     │
│                PHYSICAL ARCHITECTURE TOPOLOGY                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              CLOUD TIER 1: AWS (Primary)                │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  EKS     │  │  RDS     │  │  S3      │            │   │
│  │  │  Workloads│  │  DB      │  │  Storage │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  Istio   │  │  OPA     │  │  Kong    │            │   │
│  │  │  Mesh    │  │  PDP     │  │  Gateway │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              CLOUD TIER 2: Azure (Secondary)             │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  AKS     │  │  Azure   │  │  Azure   │            │   │
│  │  │  Workloads│  │  SQL DB  │  │  Blob    │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  │  ┌──────────┐  ┌──────────┐                           │   │
│  │  │  Istio   │  │  OPA     │                           │   │
│  │  │  Mesh    │  │  PDP     │                           │   │
│  │  └──────────┘  └──────────┘                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           ON-PREMISES TIER 3: Data Centers              │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  VMware  │  │  OT/ICS  │  │  Legacy  │            │   │
│  │  │  Clusters│  │  Network │  │  Systems │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  Rancher │  │  Vault   │  │  ELK     │            │   │
│  │  │  (K8s)   │  │  (PAM)   │  │  (SIEM)  │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           ENTERPRISE SERVICES (Global)                  │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  Keycloak│  │  Grafana │  │  Jira    │            │   │
│  │  │  (IdP)   │  │  (Obs)   │  │  (Inc)   │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  GitLab  │  │  Vault   │  │  Pager   │            │   │
│  │  │  (CI/CD) │  │  (Secrets)│  │  Duty    │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0  
**Status**: Draft - Ready for Review

```

**Verification:**

```bash
# Verify physical architecture file
ls -la sabsa_framework/04_physical_architecture.md
# Expected: File exists with size > 10KB

# Count technology components listed
grep -c "|.*|.*|" sabsa_framework/04_physical_architecture.md
# Expected: Shows 40+ technology components
```

---

### Step 6: Component Architecture - Detailed Specifications

The Component Layer provides detailed specifications for each component. This is the "Who/Which" of our architecture.

**File:** `sabsa_framework/05_component_architecture.yaml`

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

  # ==================== KUBERNETES SECURITY COMPONENTS ====================
  
  - id: "K8S-001"
    name: "Admission Controller - Kyverno"
    type: "kubernetes_security"
    description: "Policy-as-Code for Kubernetes admission control"
    specifications:
      version: "1.10+"
      deployment: "Kubernetes (Deployment)"
      replicas: 2
      policy_types:
        - "Validate: block non-compliant resources"
        - "Mutate: auto-correct configurations"
        - "Generate: auto-create resources"
      policy_examples:
        - "Enforce Pod Security Standards"
        - "Require image tags (no 'latest')"
        - "Require resource limits (CPU/memory)"
        - "Require security context (runAsNonRoot)"
        - "Validate network policies"
      policy_source:
        - "Git: all policies versioned"
        - "Applied via kubectl or GitOps"
      verification:
        - "Unit tests: Kyverno CLI tests"
        - "Policy exceptions: documented approvals"

  - id: "K8S-002"
    name: "Network Policy Engine - Calico"
    type: "kubernetes_security"
    description: "Fine-grained network security and segmentation"
    specifications:
      version: "3.26+"
      deployment: "Kubernetes (DaemonSet)"
      features:
        - "NetworkPolicy: default-deny for all namespaces"
        - "Flow logs: sent to ELK"
        - "GlobalNetworkPolicy: cluster-wide policies"
        - "ApplicationLayerPolicy: HTTP + mTLS awareness"
      policy_examples:
        - "Deny all traffic in non-production namespaces"
        - "Allow ingress only from ingress-nginx"
        - "Allow egress only to specific external IPs"
        - "Whitelist: only production → payment gateway"
      performance:
        - "Policy scale: up to 10,000 policies"
        - "Latency: < 1ms per packet"

  # ==================== APPLICATION SECURITY COMPONENTS ====================
  
  - id: "APP-001"
    name: "API Gateway - Kong"
    type: "application_security"
    description: "API security, rate limiting, and gateway"
    specifications:
      version: "3.4+"
      deployment: "Kubernetes (Deployment)"
      replicas: 3
      features:
        - "Rate limiting: 100 req/min per user (default)"
        - "JWT validation: OIDC integration"
        - "Plugin: OWASP API Top 10 protections"
        - "Plugin: CORS (configurable)"
        - "Plugin: Request/response transformation"
        - "Plugin: Logging to ELK"
      integrations:
        - "Keycloak (JWT validation)"
        - "OPA (policy enforcement)"
        - "Service mesh (Istio compatibility)"
      performance:
        - "Throughput: 10,000 req/sec"
        - "Latency: < 5ms per request"

  - id: "APP-002"
    name: "Static Application Security Testing (SAST) - Semgrep"
    type: "application_security"
    description: "Static analysis security testing for all code"
    specifications:
      version: "1.60+"
      integration: "CI/CD pipeline"
      rules:
        - "Custom rules: Nexus-specific patterns"
        - "Community rules: OWASP Top 10"
        - "Built-in: 2,000+ rules"
      configuration:
        - "Fail pipeline: critical and high findings"
        - "Notify: security team on failures"
        - "PR comments: automated findings"
      languages: "JavaScript, TypeScript, Python, Go, Java, C++, Ruby, etc."

  - id: "APP-003"
    name: "Software Composition Analysis (SCA) - Snyk"
    type: "application_security"
    description: "Dependency vulnerability scanning"
    specifications:
      version: "SaaS"
      integration: "CI/CD pipeline"
      features:
        - "Licensing: compliance scanning"
        - "Vulnerabilities: CVE tracking"
        - "Reachability: exploitable only"
        - "Dev dependency: optional scanning"
      configuration:
        - "Fail pipeline: critical and high findings"
        - "Alert: security team on vulnerabilities"
        - "Auto-PR: security fixes"

  # ==================== DETECTION & RESPONSE COMPONENTS ====================
  
  - id: "DR-001"
    name: "SIEM - ELK Stack"
    type: "detection_response"
    description: "Centralized logging, analysis, and detection"
    specifications:
      version: "Elasticsearch 8.10+, Kibana 8.10+, Logstash 8.10+"
      deployment: "Kubernetes (Elastic Cloud on Kubernetes or self-managed)"
      replicas: 
        - "Elasticsearch: 3 data nodes (hot), 3 warm nodes, 2 cold nodes"
        - "Kibana: 2 replicas"
        - "Logstash: 3 replicas"
      storage:
        - "Hot: 5TB SSD (90 days retention)"
        - "Warm: 10TB HDD (180 days)"
        - "Cold: 20TB HDD (365 days)"
      ingestion:
        - "Beats: Filebeat, Metricbeat, Winlogbeat"
        - "Agents: Elastic Agent (XDR integration)"
        - "Cloud: AWS CloudTrail, Azure Monitor"
        - "Custom: HTTP endpoints for apps"
      data_sources:
        - "Application logs (all services)"
        - "System logs (OS, network, containers)"
        - "Security logs (AuthN/AuthZ, WAF, IDS/IPS)"
        - "Identity logs (Keycloak, Vault, AD)"
        - "Cloud logs (AWS CloudTrail, Azure Monitor)"
        - "Network logs (Calico flow logs)"
      detection:
        - "Sigma rules → Elasticsearch queries"
        - "Custom rules: Nexus-specific threat models"
        - "ML-based anomaly detection (Elastic)"
      retention:
        - "Hot: 90 days (fast access)"
        - "Warm: 180 days (slow access)"
        - "Cold: 365 days (archive)"
        - "Total: 1-year minimum retention"

  - id: "DR-002"
    name: "SOAR - TheHive and Cortex"
    type: "detection_response"
    description: "Automated incident response and orchestration"
    specifications:
      version: "TheHive 5.0+, Cortex 3.0+"
      deployment: "Kubernetes (Deployment)"
      replicas: 3
      features:
        - "Case management: incident tracking"
        - "Automation: playbooks (Cortex analyzers)"
        - "Integration: SIEM alert ingestion"
        - "Reporting: incident reports"
      playbook_examples:
        - "Alert triage: automated enrichment"
        - "Phishing response: email, user isolation"
        - "Ransomware detection: network isolation"
        - "Compromised credentials: revoke, rotate, notify"
      integrations:
        - "ELK (alert ingestion)"
        - "Keycloak (user revocation)"
        - "Vault (credential rotation)"
        - "Jira (ticket creation)"
        - "Slack (notifications)"

  # ==================== RESILIENCE COMPONENTS ====================
  
  - id: "RES-001"
    name: "Immutable Backup - AWS S3 Object Lock"
    type: "resilience"
    description: "Immutable, WORM-protected backups"
    specifications:
      deployment: "AWS S3 (Object Lock enabled)"
      features:
        - "WORM: write once, read many"
        - "Retention: 30-day minimum (configurable)"
        - "Legal hold: immutable"
        - "Replication: cross-region backup"
      backup_schedule:
        - "Critical: daily (RPO 15 minutes)"
        - "Important: hourly (RPO 1 hour)"
        - "All: weekly full backup"
      recovery:
        - "RTO: 2 hours (self-service)"
        - "RPO: 15 minutes (critical data)"

  - id: "RES-002"
    name: "Chaos Engineering - Gremlin"
    type: "resilience"
    description: "Failure injection and resilience validation"
    specifications:
      version: "SaaS"
      features:
        - "Infrastructure attacks: CPU, memory, network"
        - "Application attacks: latency, errors"
        - "Security attacks: IAM revocation, network partition"
      test_scenarios:
        - "Node failure: Kubernetes node lost"
        - "Network partition: service unavailable"
        - "IAM revocation: credentials expire"
        - "Ransomware simulation: file encryption"
      schedule:
        - "Weekly: chaos tests on development"
        - "Monthly: chaos tests on staging"
        - "Quarterly: chaos tests on production"
      verification:
        - "All tests: MUST auto-recover"
        - "Report: MTTD, MTTR, failure mode analysis"

  # ==================== GOVERNANCE COMPONENTS ====================
  
  - id: "GOV-001"
    name: "Policy-as-Code Repository"
    type: "governance"
    description: "Centralized policy repository with CI/CD"
    specifications:
      repository: "Git (GitLab) with protected branches"
      policies:
        - "OPA policies: authorization, security"
        - "Kyverno policies: Kubernetes admission"
        - "Terraform policies: infrastructure compliance"
        - "Security policies: all in code"
      pipeline:
        - "CI: policy testing, syntax checking"
        - "CD: automatic deployment to environments"
      approval_workflow:
        - "All policy changes require 2 approvals"
        - "Security team approval required"
        - "Change advisory board for critical policies"
```

**Verification:**

```bash
# Verify component architecture file
ls -la sabsa_framework/05_component_architecture.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('sabsa_framework/05_component_architecture.yaml'))"
# Expected: No error output (YAML is valid)

# Count components defined
grep -c "^  - id:" sabsa_framework/05_component_architecture.yaml
# Expected: Shows 10+ components
```

---

### Step 7: Operational Architecture - Governance & Procedures

The Operational Layer defines how security is governed and operated. This is the "When/Where/How" of our architecture.

**File:** `sabsa_framework/06_operational_architecture.md`

```markdown
# SABSA Operational Architecture - Nexus Global Industries
## Governance, Procedures, and Operational Guidelines

## Governance Structure

### Security Governance Committee

```
┌─────────────────────────────────────────────────────────────┐
│                   SECURITY GOVERNANCE                       │
│                   COMMITTEE (SGC)                           │
├─────────────────────────────────────────────────────────────┤
│  Chair: CISO                                               │
│  Members: CEO, CFO, COO, GC, Board Representative          │
│  Frequency: Quarterly                                      │
│  Responsibilities:                                         │
│  - Approve security strategy and budget                    │
│  - Oversee risk acceptance decisions                        │
│  - Review incident response performance                    │
│  - Ensure compliance with regulatory obligations           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   SECURITY ARCHITECTURE                     │
│                   REVIEW BOARD (SARB)                       │
├─────────────────────────────────────────────────────────────┤
│  Chair: Lead Enterprise Security Architect                  │
│  Members: Cloud Architects, DevSecOps Leads, Compliance    │
│  Frequency: Bi-weekly                                      │
│  Responsibilities:                                         │
│  - Review and approve architecture changes                  │
│  - Conduct threat model reviews for new systems            │
│  - Maintain SABSA framework and traceability matrix        │
│  - Ensure alignment with standards and frameworks          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   SECURITY OPERATIONS                       │
│                   TEAM (SECOPS)                             │
├─────────────────────────────────────────────────────────────┤
│  Leads: Detection Engineering Manager, Incident Response  │
│  Members: Security Engineers, Detection Engineers,         │
│           IR Specialists                                   │
│  Frequency: Daily standup, weekly review                    │
│  Responsibilities:                                         │
│  - Monitor and respond to security events                  │
│  - Develop and maintain detection rules                     │
│  - Conduct threat hunting exercises                         │
│  - Execute incident response playbooks                      │
└─────────────────────────────────────────────────────────────┘
```

### Security Decision Flow

| Decision Type | Authority | Escalation Path | Documentation |
|---------------|-----------|-----------------|---------------|
| **Strategic Direction** | SGC | CISO → Board | Quarterly reports |
| **Architecture Changes** | SARB | Lead Architect → CISO | SARB minutes, architecture documents |
| **Policy Changes** | SARB → SGC (major) | Security Manager → SARB | Git (policy-as-code), review approvals |
| **Incident Response** | SecOps (triage) | IC Manager → CISO → Board | Incident reports, post-mortems |
| **Risk Acceptance** | CISO (minor), SGC (major) | Risk Owner → CISO → SGC | Risk register, accepted risk log |
| **Vulnerability Remediation** | Platform Team (technical) | DevSecOps → Security Manager | Vulnerability reports, Jira tickets |

## Security Operations Workflows

### 1. Threat Modeling Workflow

**When**: At project inception (SABSA Contextual and Conceptual)

**Who**: Security Architect + Developer Team + Business Stakeholder

**Process**:

1. **Contextual Phase**:
   - Define business objectives and criticality
   - Identify data flows (diagrams)
   - Define security requirements

2. **Threat Identification**:
   - Apply STRIDE to identify 50+ threats
   - Use PASTA to prioritize based on business impact
   - Create attack trees for critical threats

3. **Control Mapping**:
   - Map threats to controls (preventative, detective, corrective)
   - Map controls to SABSA services
   - Identify coverage gaps

4. **Risk Assessment**:
   - Assess likelihood and impact (SL/IL criteria)
   - Calculate risk score
   - Recommend risk treatment

5. **Review**:
   - Present to SARB
   - Approve controls and risk acceptance
   - Document all findings

### 2. Change Management Workflow

**When**: Any infrastructure, code, or configuration change

**Who**: Platform Engineer/Developer, Security Reviewer (for sensitive changes)

**Process**:

1. **Change Initiation**:
   - Developer/Engineer creates a change request
   - Includes impact analysis, rollback plan, security implications

2. **Security Review**:
   - Automated: SAST/DAST/SCA scans in CI/CD
   - Manual: For critical changes (SARB review)
   - Threat model update if applicable

3. **Approval**:
   - Standard: 2 engineering approvals
   - Security-sensitive: 2 approvals + 1 security team approval
   - Critical: SARB approval

4. **Deployment**:
   - Blue-green or canary (low-risk zones first)
   - Monitor for adverse effects
   - Security monitoring: watch for anomalies

5. **Post-Deployment**:
   - Chaos tests: run resilience validation
   - Review: change successful? Any issues?
   - Update documentation

### 3. Incident Response Workflow

**When**: An incident occurs (detected by SIEM, SOC, or reported)

**Who**: Incident Responder, SecOps, CISO (escalation)

**Process** (NIST SP 800-61 Aligned):

1. **Preparation**:
   - Ensure playbooks are updated and tested
   - Tabletop exercises quarterly
   - Tools and access prepared

2. **Detection & Analysis** (MTTD < 60 mins):
   - Alert triage: validate it's a true positive
   - Initial scope: What's affected? Who's affected?
   - Threat actor profiling: What's the TTP?
   - Evidence collection: Preserve logs and telemetry

3. **Containment** (MTTR < 4 hours):
   - Immediate actions: Network isolation, revoke credentials
   - Temporary fixes: Firewall rules, service shutdown
   - Backup operations: Switch to DR if needed

4. **Eradication**:
   - Remove the threat: Patch, delete malware
   - Clean affected systems
   - Validate cleanliness

5. **Recovery**:
   - Restore systems from immutable backups
   - Validate functionality
   - Monitor for re-infection

6. **Post-Incident Activity**:
   - Conduct post-mortem (within 72 hours)
   - Identify root cause and contributing factors
   - Update controls, playbooks, and detection rules
   - Report to SGC and Board (within 1 week)

### 4. Chaose Testing Workflow

**When**: Weekly (dev), monthly (staging), quarterly (production)

**Who**: Chaos Engineering Team + Platform Engineers

**Process**:

1. **Pre-Test**:
   - Define test scenarios
   - Notify stakeholders
   - Ensure monitoring is active

2. **Execution**:
   - Launch Gremlin/Chaos Mesh attacks
   - Monitor MTTD (detection time) and MTTR (recovery time)
   - Observe system behavior

3. **Post-Test**:
   - Analyze results: What failed? What auto-recovered?
   - Identify improvements
   - Document findings and recommendations

4. **Remediation**:
   - Fix any failures
   - Improve auto-recovery
   - Update playbooks

## Operational Maturity Metrics

| Domain | Metric | Target | Measurement |
|--------|--------|--------|-------------|
| **Identity** | MFA coverage | 100% | IdP reports |
| **Identity** | JML automation | 95% | SCIM reports |
| **Zero Trust** | mTLS coverage | 100% | Istio telemetry |
| **Zero Trust** | Policy evaluation time | < 10ms | OPA logs |
| **K8s Security** | Pod Security Standards | 100% Restricted | Kyverno reports |
| **K8s Security** | Image scan coverage | 100% | CI/CD reports |
| **App Security** | SAST/DAST coverage | 100% | CI/CD reports |
| **App Security** | Vulnerability patching time | < 7 days (critical) | VM reports |
| **Detection** | MTTD | < 60 min | SIEM metrics |
| **Detection** | MTTR | < 4 hours | Incident metrics |
| **Resilience** | RTO | < 2 hours | DR tests |
| **Resilience** | RPO | < 15 min | Backup tests |
| **Resilience** | Chaos test success | 100% | Chaos reports |
| **Governance** | Policy compliance | > 95% | OPA compliance dashboard |

## Staffing and Roles

### Security Team Structure

| Role | Headcount | Responsibilities | Skills Required |
|------|-----------|------------------|-----------------|
| Chief Information Security Officer | 1 | Strategy, governance, executive reporting | Security leadership, business strategy |
| Lead Enterprise Security Architect | 1 | Architecture design, framework alignment | SABSA, threat modeling, cloud security |
| Security Architects | 4 | Domain-specific architecture | Identity, cloud, network, application security |
| Security Engineers | 25 | Implement, operate security controls | IAM, container security, CSPM, SIEM |
| Detection Engineers | 10 | Build detection rules, threat hunt | SIEM, sigma, MITRE ATT&CK, analytics |
| Incident Responders | 15 | Respond to incidents, post-mortem | IR, forensics, cloud investigation |
| GRC Analysts | 10 | Risk management, compliance auditing | ISO 27001, NIST CSF, auditing, policy |
| Security Trainers | 5 | Security awareness, training | Education, communication |

**Total**: 70 (growing to 120 over 18 months)

### Skills Development Plan

| Role | Required Training | Timeline |
|------|-------------------|----------|
| All roles | Security awareness (annual) | Year 1 |
| Architects | SABSA Foundation & Practitioner | Q1-Q2 |
| Engineers | K8s Security (CKS), Cloud Security | Q1-Q3 |
| Detection Engineers | MITRE ATT&CK, Sigma | Q2-Q3 |
| IR Specialists | Incident Response certifications | Q2-Q4 |

## Documentation Standards

All security architecture documentation follows these standards:

1. **Markdown**: All documents are Markdown (.md)
2. **Diagrams**: Draw.io for all architecture diagrams
3. **Data Models**: Excel/CSV for traceability matrices
4. **Code**: All policies and configurations in Git
5. **Changelog**: Every document has a revision history
6. **Review**: All docs reviewed by SARB before finalization

### Document Naming Convention

```
{sabsa_layer}_{document_type}_{version}.{format}
```

Examples:
- `contextual_business_context_v1.0.md`
- `conceptual_security_strategy_v1.0.md`
- `logical_service_matrix_v1.0.xlsx`
- `physical_technology_stack_v1.0.md`

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0  
**Status**: Draft - Ready for Review

```

**Verification:**

```bash
# Verify operational architecture file
ls -la sabsa_framework/06_operational_architecture.md
# Expected: File exists

# Count sections
grep -c "^## " sabsa_framework/06_operational_architecture.md
# Expected: Shows 5+ major sections
```

---

### Step 8: SABSA Traceability Matrix

The traceability matrix connects the Operational Layer back to the Contextual Layer, ensuring every operational procedure supports a business requirement.

**File:** `sabsa_framework/07_traceability_matrix.csv`

```csv
"Business Attribute","Conceptual Service","Logical Mechanism","Physical Component","Operational Procedure","Verification Method"
"Confidentiality","Enterprise Identity & Access","Authentication: MFA","Keycloak + WebAuthn","User enrollment, periodic authentication","MFA coverage reports, IdP logs"
"Confidentiality","Enterprise Identity & Access","Authorization: RBAC/ABAC","OPA + Keycloak","Policy definition, access review, certification","Policy compliance scans, access reports"
"Confidentiality","Enterprise Identity & Access","PAM: JIT/JEA","HashiCorp Vault","Privileged access workflow, session recording","Vault audit logs, session reports"
"Confidentiality","Data Protection","Encryption at Rest","AWS KMS, Azure Key Vault","Key management, rotation, data classification","Encryption compliance scans, key rotation logs"
"Confidentiality","Data Protection","Encryption in Transit","Istio mTLS, TLS 1.3","Certificate management, mTLS enforcement","mTLS coverage metrics, TLS scans"
"Integrity","Infrastructure Security","Container Security","Trivy + Syft + Cosign","CI/CD scanning, SBOM generation, image signing","CI/CD pipeline results, SBOM reports, signature verification"
"Integrity","Infrastructure Security","Kubernetes Security","Kyverno + RBAC + Pod Security","Admission control, policy enforcement, pod security","Kyverno reports, RBAC audits"
"Integrity","Threat & Application Security","SAST / DAST / SCA","Semgrep + OWASP ZAP + Snyk","Security scanning in CI/CD pipeline","Scan results, vulnerability reports"
"Availability","Detection & Resilience","SIEM/XDR","ELK Stack + CrowdStrike","Log collection, detection rules, analytics","SIEM dashboards, detection rule coverage"
"Availability","Detection & Resilience","Incident Response","TheHive + Cortex + Playbooks","IR playbook execution, tabletop exercises","MTTD/MTTR metrics, post-mortem reports"
"Availability","Detection & Resilience","Business Continuity","AWS S3 Object Lock + Glacier","Immutable backups, air-gapped vaults, DR tests","RTO/RPO tests, backup integrity checks"
"Availability","Detection & Resilience","Chaos Engineering","Gremlin + Chaos Mesh","Failure injection, resilience validation","Chaos test results, auto-recovery metrics"
"Safety","Infrastructure Security","Zero Trust Architecture","OPA + Istio + Calico","Zero Trust policy enforcement, segmentation","Policy violation reports, network logs"
"Safety","Detection & Resilience","Incident Response (OT)","OT-specific IR playbooks","OT incident training, tabletop exercises","OT incident reports, drill results"
"Compliance","Security Management","Policy Management","OPA + Git","Policy-as-Code, version control, reviews","Policy compliance scans, audit reports"
"Compliance","Security Management","Compliance Monitoring","AWS Security Hub, Azure Policy","Automated compliance checks, reporting","Compliance dashboards, audit logs"
"Regulatory","Security Management","Governance","SARB + SGC","Architecture reviews, board reporting","Governance meeting records, decisions"
"Regulatory","Security Management","Risk Management","Risk Register + Assessments","Risk identification, assessment, treatment","Risk register, treatment plans"
```

**Verification:**

```bash
# Verify traceability matrix
ls -la sabsa_framework/07_traceability_matrix.csv
# Expected: File exists

# Count entries (should have at least 15+ rows of mappings)
wc -l sabsa_framework/07_traceability_matrix.csv
# Expected: Shows 15+ lines
```

---

## Verification: Complete SABSA Framework

Now let's verify that we have all six SABSA layers documented and linked.

**File:** `sabsa_framework/README.md`

```markdown
# Nexus Global Industries - SABSA Architecture Framework

## Overview

This directory contains the complete SABSA (Sherwood Applied Business Security Architecture) framework for Nexus Global Industries. The six layers provide a comprehensive, traceable security architecture from business requirements (Contextual) to operational governance (Operational).

## Directory Structure

| File | SABSA Layer | Purpose |
|------|-------------|---------|
| `01_contextual_architecture.csv` | Contextual | Business requirements, risk appetite, success criteria |
| `01_contextual_architecture.md` | Contextual | Detailed business context and environment |
| `02_conceptual_architecture.md` | Conceptual | Security strategy and service framework |
| `03_logical_architecture.csv` | Logical | Security services and mechanisms detailed |
| `03_logical_architecture.md` | Logical | Architecture patterns and service mapping |
| `04_physical_architecture.md` | Physical | Technology selection and topology |
| `05_component_architecture.yaml` | Component | Component specifications and configurations |
| `06_operational_architecture.md` | Operational | Governance, workflows, and procedures |
| `07_traceability_matrix.csv` | All Layers | Traceability linking all layers |

## Traceability Path

For any business requirement in Layer 1 (Contextual), you can trace through:

1. **Layer 1 → Layer 2**: Business attribute maps to security service
2. **Layer 2 → Layer 3**: Security service maps to mechanism
3. **Layer 3 → Layer 4**: Mechanism maps to technology
4. **Layer 4 → Layer 5**: Technology maps to component specifications
5. **Layer 5 → Layer 6**: Component maps to operational procedure

## Usage

1. Start with `01_contextual_architecture.md` to understand the business requirements
2. Review `02_conceptual_architecture.md` for the security strategy
3. Dive into `03_logical_architecture.md` for service mechanisms
4. Reference `04_physical_architecture.md` for technology selection
5. Use `05_component_architecture.yaml` for detailed specifications
6. Follow `06_operational_architecture.md` for governance and procedures
7. Maintain traceability via `07_traceability_matrix.csv`

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-08-02 | Lead Enterprise Security Architect | Initial creation |

## Review Status

| Layer | Reviewed By | Date | Status |
|-------|-------------|------|--------|
| Contextual | SARB | 2026-08-02 | Approved |
| Conceptual | SARB | 2026-08-02 | Approved |
| Logical | SARB | 2026-08-02 | Approved |
| Physical | SARB | 2026-08-02 | Approved |
| Component | SARB | 2026-08-02 | Approved |
| Operational | SARB | 2026-08-02 | Approved |

---

**Maintained By**: Lead Enterprise Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Final Verification:**

```bash
# List all SABSA files
ls -la sabsa_framework/
# Expected: All 9 files present

# Count total files
ls -1 sabsa_framework/ | wc -l
# Expected: 9 files

# Check file sizes (should all be > 1KB)
for file in sabsa_framework/*; do 
    echo "$file: $(wc -l < $file) lines"
done
# Expected: Shows line counts (each should be significant)

# Validate README exists
cat sabsa_framework/README.md | grep "Nexus Global Industries - SABSA Architecture Framework"
# Expected: Shows the README header

echo "✅ SABSA Framework Complete!"
echo "   - 6 layers documented"
echo "   - Traceability matrix created"
echo "   - All files in sabsa_framework/"
echo "   - README.md for reference"
```

---

**[GENERATED: Part 1, Section 1.1 - SABSA Framework]**

**[COMPLETED: SABSA Framework for Nexus Global Industries]**
- ✅ Contextual Architecture - Business context and requirements documented
- ✅ Conceptual Architecture - Security strategy and service framework defined
- ✅ Logical Architecture - Security services and mechanisms specified
- ✅ Physical Architecture - Technology stack and topology mapped
- ✅ Component Architecture - Detailed specifications for each component
- ✅ Operational Architecture - Governance and procedures established
- ✅ Traceability Matrix - All layers linked end-to-end
- ✅ README.md - Framework documentation complete

**[STARTING: Part 1, Section 1.2 - NIST CSF 2.0 Governance Implementation]**

---

## End of Section 1.1: SABSA Framework

### Key Takeaway

You've built a complete SABSA framework for Nexus Global Industries. Every business requirement now has a traceable path through security services, mechanisms, technologies, components, and operational procedures. This is the foundation upon which we'll build the rest of the security architecture.

### What's Next

In **Section 1.2**, we'll implement the **NIST CSF 2.0 Governance Function**, including:
- The 6 CSF functions (Govern, Identify, Protect, Detect, Respond, Recover)
- Governance policies as code
- Integration with SABSA
- CSF control mapping and traceability

The code-heavy implementation continues with complete YAML policy files, configuration examples, and verification steps.

