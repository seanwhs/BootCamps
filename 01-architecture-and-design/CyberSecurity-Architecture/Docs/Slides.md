# Enterprise Cybersecurity Architecture & Frameworks
## Complete Slide Deck Outline
### Comprehensive Training Presentation (250+ Slides)

---

**[GENERATED: Complete Slide Deck Outline]**

---

## Overview

This document provides a comprehensive slide-by-slide outline for teaching the entire 5-part series. Each slide includes:
- **Slide Number** for reference
- **Title** for clear identification
- **Content Bullets** for what to present
- **Visual Notes** for diagram/visual recommendations
- **Speaker Notes** for key talking points
- **Time Estimate** for pacing

**Total Slides:** 250+
**Estimated Duration:** 12-15 instructional days
**Target Audience:** Enterprise Security Architects, Cloud Security Architects, DevSecOps Engineers, Platform Engineers

---

## SECTION 0: INTRODUCTION & SERIES OVERVIEW
### 10 Slides | 60 Minutes

---

### Slide 0.1: Title Slide
**Content:**
- Enterprise Cybersecurity Architecture & Frameworks
- An Engineering-Led, Risk-Driven Curriculum
- [Your Name/Organization]
- [Date]

**Visual Notes:** Full-screen title with security-themed background

**Speaker Notes:** "Welcome to the complete enterprise cybersecurity architecture training series. Over the next 12-15 days, we'll build a complete security architecture from the ground up."

**Time:** 2 minutes

---

### Slide 0.2: The Modern Enterprise Reality
**Content:**
- Hybrid cloud infrastructure
- Containerized microservices on Kubernetes
- SaaS applications via APIs
- Distributed remote workforces
- IoT/OT environments
- Complex supply chains

**Visual Notes:** Diagram showing interconnected enterprise components

**Speaker Notes:** "The perimeter has evaporated. Trust can no longer be implicit. We need a new approach."

**Time:** 3 minutes

---

### Slide 0.3: The Problem We're Solving
**Content:**
- Traditional perimeter security is dead
- Threat actors are more sophisticated than ever
- Compliance checklists aren't strategies
- Security must be an engineering discipline

**Visual Notes:** Side-by-side comparison of traditional vs modern security

**Speaker Notes:** "We're moving from checkbox security to true security architecture."

**Time:** 3 minutes

---

### Slide 0.4: What You'll Build
**Content:**
- Complete security architecture for Nexus Global Industries
- 5-part series, 24 sections
- 129+ artifacts
- Production-grade code and configurations

**Visual Notes:** Architecture diagram of final deliverable

**Speaker Notes:** "By the end, you'll have built a complete, defensible enterprise security architecture."

**Time:** 3 minutes

---

### Slide 0.5: The Four Layers (Part 1)
**Content:**
- **Layer 1: Governance & Risk**
  - SABSA, NIST CSF 2.0, ISO 27001
  - Threat Modeling (STRIDE, PASTA, Attack Trees)
  - Risk management and compliance

**Visual Notes:** Layer diagram showing governance at the top

**Speaker Notes:** "Everything starts with governance. We build the blueprint before we build the house."

**Time:** 2 minutes

---

### Slide 0.6: The Four Layers (Part 2)
**Content:**
- **Layer 2: Zero Trust & Identity**
  - NIST SP 800-207 Zero Trust
  - Identity Management (Keycloak)
  - Privileged Access (Vault)
  - Micro-segmentation (Calico, Istio)

**Visual Notes:** Layer diagram showing identity and Zero Trust

**Speaker Notes:** "Zero Trust is the foundation of modern security. We replace perimeter trust with continuous verification."

**Time:** 2 minutes

---

### Slide 0.7: The Four Layers (Part 3)
**Content:**
- **Layer 3: Cloud-Native Security**
  - Multi-Cloud (AWS + Azure)
  - Kubernetes Security
  - API Security (OWASP Top 10)
  - DevSecOps CI/CD

**Visual Notes:** Layer diagram showing cloud-native security

**Speaker Notes:** "Cloud-native requires new thinking. Containers, APIs, and pipelines all need security."

**Time:** 2 minutes

---

### Slide 0.8: The Four Layers (Part 4)
**Content:**
- **Layer 4: Detection, Response & Resilience**
  - SIEM/XDR (ELK + CrowdStrike)
  - Detection Engineering (Sigma + MITRE)
  - Threat Hunting
  - SOAR Automation
  - Chaos Engineering
  - Business Continuity

**Visual Notes:** Layer diagram showing detection and resilience

**Speaker Notes:** "Assume breach. Detect quickly. Respond effectively. Recover fast."

**Time:** 2 minutes

---

### Slide 0.9: The Complete Architecture
**Content:**
- Governance & Risk
- Zero Trust & Identity
- Cloud-Native Security
- Detection, Response & Resilience

**Visual Notes:** Full 4-layer architecture diagram

**Speaker Notes:** "This is what we're building—an integrated, layered security architecture."

**Time:** 3 minutes

---

### Slide 0.10: The Target Audience & Prerequisites
**Content:**
- **Audience:**
  - Enterprise Security Architects
  - Cloud Security Architects
  - DevSecOps Engineers
  - Platform Engineers
  - Solutions Architects
  - Technical Security Managers

- **Prerequisites:**
  - Basic TCP/IP, DNS, HTTP(S)
  - Some cloud experience (AWS/Azure/GCP)
  - Docker basics
  - OAuth/JWT concepts
  - Some Python, YAML, Terraform
  - Basic security terms

**Visual Notes:** Audience icons and prerequisite checklist

**Speaker Notes:** "Don't worry if you're not expert-level in everything. We'll build from the ground up."

**Time:** 3 minutes

---

## SECTION 1: FOUNDATIONS & FRAMEWORKS
### Part 1: 60 Slides | 3 Days

---

### Slide 1.0: Part 1 Introduction
**Content:**
- Foundations of Secure Architecture & Framework Integration
- 4 sections:
  1.1 SABSA Enterprise Security Architecture
  1.2 NIST CSF 2.0 Governance
  1.3 ISO/IEC 27001 ISMS
  1.4 Threat Modeling

**Visual Notes:** Part 1 section overview diagram

**Speaker Notes:** "Part 1 is the foundation. Everything else builds on this."

**Time:** 2 minutes

---

## SECTION 1.1: SABSA FRAMEWORK
### 15 Slides | 3 Hours

---

### Slide 1.1.0: SABSA Introduction
**Content:**
- Sherwood Applied Business Security Architecture
- Business-driven security architecture
- 6 layers from business to operations

**Visual Notes:** SABSA logo and 6-layer diagram

**Speaker Notes:** "SABSA is about traceability from business requirements to operational procedures."

**Time:** 3 minutes

---

### Slide 1.1.1: The Six Layers Overview
**Content:**
1. Contextual (Why?)
2. Conceptual (What?)
3. Logical (How?)
4. Physical (Where?)
5. Component (Who/Which?)
6. Operational (When/Where/How?)

**Visual Notes:** 6-layer pyramid diagram

**Speaker Notes:** "Each layer maps to the one below it, creating complete traceability."

**Time:** 3 minutes

---

### Slide 1.1.2: Layer 1 - Contextual Architecture
**Content:**
- Business requirements and environment
- Risk appetite and tolerances
- Regulatory landscape
- Business drivers and objectives

**Visual Notes:** Business context diagram

**Speaker Notes:** "This is the WHY. What does the business need from security?"

**Time:** 5 minutes

---

### Slide 1.1.3: Contextual Output Example
**Content:**
- Nexus Global Industries profile
- Critical assets identified
- Risk appetite defined
- Business drivers documented

**Visual Notes:** Example business context document

**Time:** 5 minutes

---

### Slide 1.1.4: Layer 2 - Conceptual Architecture
**Content:**
- Security strategy and service framework
- Security service domains:
  - Security Management
  - Enterprise Identity & Access
  - Infrastructure & Workload Security
  - Threat & Application Security
  - Detection & Resilience

**Visual Notes:** Security service framework diagram

**Speaker Notes:** "This is the WHAT. What security services do we need to deliver?"

**Time:** 5 minutes

---

### Slide 1.1.5: Conceptual Output Example
**Content:**
- Security service framework
- Service-to-business attribute mapping
- Architectural principles defined

**Visual Notes:** Service matrix example

**Time:** 5 minutes

---

### Slide 1.1.6: Layer 3 - Logical Architecture
**Content:**
- Security services and mechanisms
- Service-to-mechanism mapping
- Architecture patterns:
  - Zero Trust Identity
  - Micro-segmentation
  - Detection & Response

**Visual Notes:** Architecture pattern diagrams

**Speaker Notes:** "This is the HOW. How do we deliver each security service?"

**Time:** 5 minutes

---

### Slide 1.1.7: Logical Output Example
**Content:**
- Service mechanism matrix
- Architecture pattern diagrams
- Mechanism-to-technology mapping

**Visual Notes:** Service mechanism matrix example

**Time:** 5 minutes

---

### Slide 1.1.8: Layer 4 - Physical Architecture
**Content:**
- Technology stack selection
- Environment domains:
  - Cloud (AWS + Azure)
  - On-Premises
  - OT/ICS
  - Kubernetes
  - SaaS

**Visual Notes:** Technology stack diagram

**Speaker Notes:** "This is the WHERE. What technology implements each mechanism?"

**Time:** 5 minutes

---

### Slide 1.1.9: Physical Output Example
**Content:**
- Technology stack architecture
- Domain-specific technology choices
- Topology diagrams

**Visual Notes:** Physical architecture topology diagram

**Time:** 5 minutes

---

### Slide 1.1.10: Layer 5 - Component Architecture
**Content:**
- Detailed component specifications
- Component configurations
- Integration points
- Lifecycle management

**Visual Notes:** Component specification example

**Speaker Notes:** "This is the WHO/WHICH. What specific components make up the architecture?"

**Time:** 5 minutes

---

### Slide 1.1.11: Component Output Example
**Content:**
- Component specifications (YAML)
- Configuration details
- Integration dependencies

**Visual Notes:** Component specification YAML example

**Time:** 5 minutes

---

### Slide 1.1.12: Layer 6 - Operational Architecture
**Content:**
- Governance structure
- Operational procedures
- Security workflows:
  - Threat Modeling
  - Change Management
  - Incident Response
  - Chaos Testing
- Staffing and roles

**Visual Notes:** Operational governance diagram

**Speaker Notes:** "This is the WHEN/WHERE/HOW. How do we operate and govern it all?"

**Time:** 5 minutes

---

### Slide 1.1.13: Operational Output Example
**Content:**
- Governance committee structure
- Workflow diagrams
- Role descriptions
- Operational metrics

**Visual Notes:** Governance structure and workflow diagrams

**Time:** 5 minutes

---

### Slide 1.1.14: The Traceability Matrix
**Content:**
- Connects all six layers
- Ensures business alignment
- Provides audit trail
- Maps: Business → Service → Mechanism → Technology → Component → Procedure

**Visual Notes:** Traceability matrix example

**Speaker Notes:** "This is the magic of SABSA—complete traceability from business to operations."

**Time:** 5 minutes

---

## SECTION 1.2: NIST CSF 2.0
### 15 Slides | 3 Hours

---

### Slide 1.2.0: NIST CSF Introduction
**Content:**
- NIST Cybersecurity Framework 2.0
- Risk-based approach to cybersecurity
- 6 functions (Govern is NEW)
- Common language for risk management

**Visual Notes:** NIST CSF logo and functions diagram

**Speaker Notes:** "CSF 2.0 adds Governance, recognizing that cybersecurity is a business leadership responsibility."

**Time:** 3 minutes

---

### Slide 1.2.1: The 6 Functions
**Content:**
1. **Govern** - Strategy and oversight
2. **Identify** - Assets and risks
3. **Protect** - Safeguards
4. **Detect** - Events
5. **Respond** - Incidents
6. **Recover** - Operations

**Visual Notes:** 6-function wheel diagram

**Speaker Notes:** "These six functions cover the entire cybersecurity lifecycle."

**Time:** 3 minutes

---

### Slide 1.2.2: Govern Function (GV)
**Content:**
- GV.OC Organizational Context
- GV.RM Risk Management Strategy
- GV.RR Roles & Responsibilities
- GV.PO Policies & Procedures
- GV.OV Oversight
- GV.SC Supply Chain Risk
- GV.AW Awareness & Training
- GV.FI Feedback & Improvement

**Visual Notes:** Governance categories diagram

**Speaker Notes:** "Govern is the new function in CSF 2.0—it's about leadership and strategy."

**Time:** 5 minutes

---

### Slide 1.2.3: Govern Output Example
**Content:**
- Governance policies as code (YAML)
- Risk management strategy
- Roles and responsibilities
- Policy framework

**Visual Notes:** Governance YAML example

**Time:** 5 minutes

---

### Slide 1.2.4: Identify Function (ID)
**Content:**
- ID.AM Asset Management
- ID.RA Risk Assessment
- ID.BE Business Environment
- ID.GV Governance & Risk
- ID.IM Improvement

**Visual Notes:** Identify categories diagram

**Speaker Notes:** "You can't protect what you don't know you have."

**Time:** 5 minutes

---

### Slide 1.2.5: Identify Output Example
**Content:**
- Asset inventory (YAML)
- Risk assessment
- Business environment analysis
- Improvement plan

**Visual Notes:** Asset inventory YAML example

**Time:** 5 minutes

---

### Slide 1.2.6: Protect Function (PR)
**Content:**
- PR.AC Access Control
- PR.AT Awareness & Training
- PR.DS Data Security
- PR.IP Information Protection
- PR.MA Maintenance
- PR.ND Network Security
- PR.IR Incident Response

**Visual Notes:** Protect categories diagram

**Speaker Notes:** "This is where most traditional security controls live."

**Time:** 5 minutes

---

### Slide 1.2.7: Protect Output Example
**Content:**
- Access control policies
- Data security controls
- Network security policies
- Maintenance procedures

**Visual Notes:** Protect YAML example

**Time:** 5 minutes

---

### Slide 1.2.8: Detect Function (DE)
**Content:**
- DE.AE Anomalies & Events
- DE.CM Continuous Monitoring
- DE.DP Detection Processes
- DE.AR Anomaly Response
- DE.DU Detection of Unauthorized Activity
- DE.SR Security Monitoring

**Visual Notes:** Detect categories diagram

**Speaker Notes:** "Detection is about having the eyes and ears to know when something is wrong."

**Time:** 5 minutes

---

### Slide 1.2.9: Detect Output Example
**Content:**
- Monitoring configuration
- Detection rules
- Anomaly detection processes
- Security monitoring dashboards

**Visual Notes:** Detect YAML example

**Time:** 5 minutes

---

### Slide 1.2.10: Respond Function (RS)
**Content:**
- RS.RP Response Planning
- RS.AN Analysis
- RS.MI Mitigation
- RS.IM Improvement
- RS.CO Communications

**Visual Notes:** Respond categories diagram

**Speaker Notes:** "Response is about having a plan and executing it effectively."

**Time:** 5 minutes

---

### Slide 1.2.11: Respond Output Example
**Content:**
- Incident response playbooks
- Analysis procedures
- Mitigation strategies
- Communication plans

**Visual Notes:** Respond YAML example

**Time:** 5 minutes

---

### Slide 1.2.12: Recover Function (RC)
**Content:**
- RC.RP Recovery Planning
- RC.IM Improvement
- RC.RI Recovery Infrastructure
- RC.RC Recovery Communications

**Visual Notes:** Recover categories diagram

**Speaker Notes:** "Recovery is about getting back to normal as quickly as possible."

**Time:** 5 minutes

---

### Slide 1.2.13: Recover Output Example
**Content:**
- Recovery plans
- Infrastructure configuration
- Communications plan
- DR testing schedule

**Visual Notes:** Recover YAML example

**Time:** 5 minutes

---

### Slide 1.2.14: CSF-SABSA Integration
**Content:**
- CSF functions map to SABSA layers
- Traceability across frameworks
- Complete governance coverage

**Visual Notes:** CSF-SABSA mapping matrix

**Speaker Notes:** "Together, SABSA and CSF provide complete architecture and governance."

**Time:** 5 minutes

---

## SECTION 1.3: ISO 27001 ISMS
### 15 Slides | 3 Hours

---

### Slide 1.3.0: ISO 27001 Introduction
**Content:**
- International standard for information security management
- Systematic approach to managing security
- 78 Annex A controls
- Certification path

**Visual Notes:** ISO 27001 logo and ISMS diagram

**Speaker Notes:** "ISO 27001 is about building a management system, not just a checklist."

**Time:** 3 minutes

---

### Slide 1.3.1: The ISMS Components
**Content:**
1. ISMS Policy
2. Risk Assessment
3. Risk Treatment
4. Statement of Applicability (SoA)
5. Implementation & Operation
6. Monitoring & Review
7. Continuous Improvement

**Visual Notes:** ISMS component diagram

**Speaker Notes:** "The ISMS is the engine that drives security management."

**Time:** 5 minutes

---

### Slide 1.3.2: Risk Assessment Methodology
**Content:**
- Asset-based risk assessment
- Likelihood × Impact scoring
- Risk levels:
  - LOW (1-4): Accept/Monitor
  - MEDIUM (5-9): Treat within 6 months
  - HIGH (10-14): Treat within 3 months
  - CRITICAL (15-25): Treat immediately

**Visual Notes:** Risk matrix diagram

**Speaker Notes:** "Risk assessment is the foundation of ISO 27001."

**Time:** 5 minutes

---

### Slide 1.3.3: Risk Scoring Matrix
**Content:**
- Likelihood 1-5 (Very Low to Very High)
- Impact 1-5 (Low to Critical)
- Risk Score = Likelihood × Impact

**Visual Notes:** Risk scoring table

**Time:** 5 minutes

---

### Slide 1.3.4: Risk Register Example
**Content:**
- 10 risks identified
- Each scored and prioritized
- Treatment plans defined
- Owners assigned

**Visual Notes:** Risk register table

**Time:** 5 minutes

---

### Slide 1.3.5: Statement of Applicability (SoA)
**Content:**
- 78 Annex A controls
- Applicable or Not Applicable
- Justification for each
- Implementation status

**Visual Notes:** SoA spreadsheet

**Speaker Notes:** "The SoA is your control selection document. It shows which controls apply and why."

**Time:** 5 minutes

---

### Slide 1.3.6: Annex A Control Categories
**Content:**
- A.5 Organizational (37)
- A.6 People (8)
- A.7 Physical (14)
- A.8 Technology (34)

**Visual Notes:** Annex A category diagram

**Time:** 5 minutes

---

### Slide 1.3.7: Risk Treatment Planning
**Content:**
- Treatment options:
  - Mitigate (Implement controls)
  - Accept (Accept risk with justification)
  - Avoid (Stop the activity)
  - Transfer (Insurance, outsourcing)

**Visual Notes:** Risk treatment decision diagram

**Time:** 5 minutes

---

### Slide 1.3.8: Risk Treatment Plan Example
**Content:**
- 10 risks treated
- Controls identified
- Owners assigned
- Timelines defined

**Visual Notes:** Risk treatment plan table

**Time:** 5 minutes

---

### Slide 1.3.9: Annex A Control Mapping
**Content:**
- Each control mapped to implementation
- Status tracked
- Evidence collected
- Verification method defined

**Visual Notes:** Annex A mapping spreadsheet

**Time:** 5 minutes

---

### Slide 1.3.10: The PDCA Cycle
**Content:**
- Plan: Establish ISMS
- Do: Implement and operate
- Check: Monitor and review
- Act: Maintain and improve

**Visual Notes:** PDCA cycle diagram

**Speaker Notes:** "ISO 27001 is about continuous improvement, not just achieving certification."

**Time:** 5 minutes

---

### Slide 1.3.11: ISMS Metrics
**Content:**
- Performance metrics (MTTD, MTTR)
- Compliance metrics
- Security incident metrics
- Risk management metrics

**Visual Notes:** Metrics dashboard

**Time:** 5 minutes

---

### Slide 1.3.12: Internal Audit Program
**Content:**
- Regular internal audits
- Scope and frequency
- Audit checklists
- Non-conformance tracking

**Visual Notes:** Audit schedule diagram

**Time:** 5 minutes

---

### Slide 1.3.13: Management Review
**Content:**
- Quarterly management reviews
- ISMS performance
- Risk status
- Improvement opportunities
- Resource needs

**Visual Notes:** Management review agenda

**Time:** 5 minutes

---

### Slide 1.3.14: Certification Path
**Content:**
- Stage 1: Documentation review
- Stage 2: Implementation review
- Certification awarded
- Annual surveillance audits
- Recertification every 3 years

**Visual Notes:** Certification timeline

**Speaker Notes:** "Certification is a journey, not a destination. It requires ongoing commitment."

**Time:** 5 minutes

---

## SECTION 1.4: THREAT MODELING
### 15 Slides | 3 Hours

---

### Slide 1.4.0: Threat Modeling Introduction
**Content:**
- Systematic approach to identifying threats
- Four methodologies:
  1. STRIDE
  2. PASTA
  3. Attack Trees
  4. MITRE ATT&CK

**Visual Notes:** Threat modeling overview diagram

**Speaker Notes:** "You can't defend against threats you haven't identified."

**Time:** 3 minutes

---

### Slide 1.4.1: STRIDE Methodology
**Content:**
- **S** poofing
- **T** ampering
- **R** epudiation
- **I** nformation Disclosure
- **D** enial of Service
- **E** levation of Privilege

**Visual Notes:** STRIDE acronym with icons

**Speaker Notes:** "STRIDE helps you systematically identify threats to each component."

**Time:** 5 minutes

---

### Slide 1.4.2: STRIDE Analysis Example
**Content:**
- Component: Customer Portal Authentication
- Threats identified for each category
- Mitigations defined
- Status tracked

**Visual Notes:** STRIDE analysis table

**Time:** 5 minutes

---

### Slide 1.4.3: PASTA Methodology
**Content:**
- Process for Attack Simulation and Threat Analysis
- 7 stages:
  1. Define Business Objectives
  2. Define Technical Scope
  3. Application Decomposition
  4. Threat Analysis
  5. Vulnerability Analysis
  6. Attack Modeling
  7. Risk & Impact Analysis

**Visual Notes:** PASTA 7-stage diagram

**Speaker Notes:** "PASTA is business-aligned threat modeling. Start with business impact, work back to threats."

**Time:** 5 minutes

---

### Slide 1.4.4: PASTA Example
**Content:**
- Business objective: Protect customer PII
- Technical scope: Customer portal architecture
- Threats identified
- Attack paths modeled
- Risk analysis conducted

**Visual Notes:** PASTA analysis example

**Time:** 5 minutes

---

### Slide 1.4.5: Attack Trees
**Content:**
- Visual representation of attack paths
- Root goal at top
- OR/AND nodes
- Leaf nodes are specific attack steps

**Visual Notes:** Attack tree diagram example

**Speaker Notes:** "Attack trees help you visualize how an attacker might achieve their goal."

**Time:** 5 minutes

---

### Slide 1.4.6: Attack Tree Example - Ransomware
**Content:**
- Root: "Ransomware Encrypts OT Systems"
- Sub-goals: Initial Access, Privilege Escalation
- Leaf nodes: Phishing, VPN Exploit, LSASS Dump
- Complete attack path

**Visual Notes:** Ransomware attack tree diagram

**Time:** 5 minutes

---

### Slide 1.4.7: MITRE ATT&CK Framework
**Content:**
- Knowledge base of adversary behavior
- 14 tactics
- Hundreds of techniques
- Common language for threats

**Visual Notes:** MITRE ATT&CK overview diagram

**Speaker Notes:** "MITRE ATT&CK is the encyclopedia of attacker techniques."

**Time:** 5 minutes

---

### Slide 1.4.8: The 14 Tactics
**Content:**
1. Reconnaissance
2. Resource Development
3. Initial Access
4. Execution
5. Persistence
6. Privilege Escalation
7. Defense Evasion
8. Credential Access
9. Discovery
10. Lateral Movement
11. Collection
12. Command & Control
13. Exfiltration
14. Impact

**Visual Notes:** 14 tactics list with icons

**Time:** 5 minutes

---

### Slide 1.4.9: ATT&CK Control Mapping
**Content:**
- Map threats to techniques
- Map techniques to controls
- Identify coverage gaps
- Prioritize implementations

**Visual Notes:** ATT&CK control mapping matrix

**Time:** 5 minutes

---

### Slide 1.4.10: ATT&CK Coverage Example
**Content:**
- 14 tactics mapped
- Coverage percentage calculated
- Gaps identified
- Remediation planned

**Visual Notes:** Coverage dashboard

**Time:** 5 minutes

---

### Slide 1.4.11: Threat Modeling Integration
**Content:**
- How all four methodologies work together
- STRIDE for component-level
- PASTA for business alignment
- Attack Trees for visualization
- MITRE ATT&CK for threat intelligence

**Visual Notes:** Integration diagram

**Speaker Notes:** "Use all four together for complete threat modeling."

**Time:** 5 minutes

---

### Slide 1.4.12: Threat Modeling Process
**Content:**
- Planning and scoping
- Data collection
- Threat identification
- Analysis and prioritization
- Mitigation and validation
- Review and handoff

**Visual Notes:** Process flow diagram

**Time:** 5 minutes

---

### Slide 1.4.13: Threat Modeling Artifacts
**Content:**
- Architecture diagrams
- Data flow diagrams
- STRIDE analysis
- PASTA document
- Attack trees
- MITRE ATT&CK mapping

**Visual Notes:** Artifact examples

**Time:** 5 minutes

---

### Slide 1.4.14: Part 1 Summary
**Content:**
- SABSA: Business-driven architecture
- NIST CSF 2.0: Risk management
- ISO 27001: Management system
- Threat Modeling: Threat identification

**Visual Notes:** Part 1 summary diagram

**Speaker Notes:** "Part 1 provides the foundation for everything we'll build."

**Time:** 5 minutes

---

## SECTION 2: ZERO TRUST & IDENTITY
### Part 2: 60 Slides | 3 Days

---

### Slide 2.0: Part 2 Introduction
**Content:**
- Zero Trust & Identity-Centric Enterprise Architecture
- 4 sections:
  2.1 Zero Trust Architecture
  2.2 Identity & Access Management
  2.3 Privileged Access Management
  2.4 Micro-segmentation & SDP

**Visual Notes:** Part 2 section overview diagram

**Speaker Notes:** "Part 2 is about replacing implicit trust with continuous verification."

**Time:** 2 minutes

---

## SECTION 2.1: ZERO TRUST ARCHITECTURE
### 15 Slides | 3 Hours

---

### Slide 2.1.0: Zero Trust Introduction
**Content:**
- NIST SP 800-207 Zero Trust Architecture
- Never trust, always verify
- 3 core principles:
  1. Verify Explicitly
  2. Least Privilege
  3. Assume Breach

**Visual Notes:** Zero Trust principles diagram

**Speaker Notes:** "Zero Trust is not a product—it's a philosophy and architecture."

**Time:** 5 minutes

---

### Slide 2.1.1: The Problem with Perimeter Security
**Content:**
- Castle-and-moat model is obsolete
- No perimeter in modern enterprise
- Remote work, cloud, mobile, APIs
- Trusted insider = vulnerable

**Visual Notes:** Traditional vs modern security diagram

**Speaker Notes:** "The perimeter has evaporated. We need a new approach."

**Time:** 5 minutes

---

### Slide 2.1.2: The 3 Core Principles
**Content:**
1. **Verify Explicitly**: Always authenticate and authorize
2. **Least Privilege**: Minimum access needed
3. **Assume Breach**: Design for detection

**Visual Notes:** 3 principles with icons

**Time:** 5 minutes

---

### Slide 2.1.3: ZTA Components
**Content:**
- PDP: Policy Decision Point (makes decisions)
- PEP: Policy Enforcement Point (enforces decisions)
- PAP: Policy Administration Point (manages policies)
- PIP: Policy Information Point (provides context)

**Visual Notes:** ZTA component architecture diagram

**Speaker Notes:** "These four components work together to implement Zero Trust."

**Time:** 5 minutes

---

### Slide 2.1.4: The Zero Trust Flow
**Content:**
1. User requests access
2. PEP intercepts
3. PIP gathers context
4. PDP evaluates policy
5. Decision made (Allow/Deny/Challenge)
6. PEP enforces decision
7. Decision logged to SIEM

**Visual Notes:** Zero Trust flow diagram

**Time:** 5 minutes

---

### Slide 2.1.5: OPA PDP Implementation
**Content:**
- Open Policy Agent (OPA)
- Rego policy language
- Policy examples
- Integration with Istio and Kong

**Visual Notes:** OPA architecture diagram

**Speaker Notes:** "OPA is the brain of our Zero Trust implementation."

**Time:** 5 minutes

---

### Slide 2.1.6: OPA Policy Example
**Content:**
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
}
```

**Visual Notes:** Rego policy code example

**Time:** 5 minutes

---

### Slide 2.1.7: Istio PEP Implementation
**Content:**
- Istio service mesh
- mTLS for all services
- Authorization policies
- Telemetry and observability

**Visual Notes:** Istio architecture diagram

**Speaker Notes:** "Istio provides the enforcement layer for Zero Trust."

**Time:** 5 minutes

---

### Slide 2.1.8: Istio Authorization Example
**Content:**
```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: payment-service-authz
spec:
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/order-service"]
    to:
    - operation:
        methods: ["POST"]
        paths: ["/api/v1/payment/*"]
```

**Visual Notes:** AuthorizationPolicy YAML example

**Time:** 5 minutes

---

### Slide 2.1.9: Continuous Verification Service
**Content:**
- Python service
- Redis for session storage
- Periodic verification (60 seconds)
- Risk scoring
- Step-up authentication

**Visual Notes:** Continuous verification flow diagram

**Time:** 5 minutes

---

### Slide 2.1.10: Risk Scoring
**Content:**
- Risk factors:
  - Session age (>8 hours)
  - Inactivity (>15 minutes)
  - Device posture
  - Geographic anomaly
  - Behavioral anomaly
- Scores 0-100
- Thresholds:
  - <70: Low risk
  - 70-89: Suspicious (step-up)
  - 90+: Critical (terminate)

**Visual Notes:** Risk scoring diagram

**Time:** 5 minutes

---

### Slide 2.1.11: Zero Trust Policies
**Content:**
- Identity policies (MFA, session timeout)
- Device policies (compliance)
- Network policies (default deny, micro-segmentation)
- Data policies (classification, encryption)
- Privileged access policies (JIT, session recording)

**Visual Notes:** Policy categories diagram

**Time:** 5 minutes

---

### Slide 2.1.12: Zero Trust Implementation Roadmap
**Content:**
- Phase 1: Foundation (Months 1-3)
  - OPA deployment, basic policies
- Phase 2: Workload Protection (Months 4-6)
  - Istio, mTLS, PEP
- Phase 3: User Access (Months 7-9)
  - IdP integration, user policies
- Phase 4: Advanced (Months 10-12)
  - Continuous verification, risk scoring

**Visual Notes:** Implementation timeline

**Time:** 5 minutes

---

### Slide 2.1.13: Zero Trust Maturity Model
**Content:**
- Level 1: Traditional (perimeter-based)
- Level 2: Initial (MFA, basic segmentation)
- Level 3: Advanced (micro-segmentation, continuous verification)
- Level 4: Mature (automated, self-healing)

**Visual Notes:** Maturity model diagram

**Time:** 5 minutes

---

### Slide 2.1.14: Section 2.1 Summary
**Content:**
- NIST SP 800-207 Zero Trust Architecture
- PDP (OPA) and PEP (Istio)
- Continuous verification
- Risk-based access

**Visual Notes:** Zero Trust summary diagram

**Time:** 5 minutes

---

## SECTION 2.2: IDENTITY & ACCESS MANAGEMENT
### 15 Slides | 3 Hours

---

### Slide 2.2.0: IAM Introduction
**Content:**
- Identity is the new perimeter
- Centralized identity management
- Key components:
  - Identity Provider
  - Authentication
  - Authorization
  - Identity Lifecycle

**Visual Notes:** IAM overview diagram

**Speaker Notes:** "Identity is the foundation of Zero Trust."

**Time:** 5 minutes

---

### Slide 2.2.1: Keycloak Identity Provider
**Content:**
- Open-source identity provider
- OAuth 2.1/OIDC support
- SAML 2.0 federation
- SCIM 2.0 provisioning
- MFA support

**Visual Notes:** Keycloak architecture diagram

**Speaker Notes:** "Keycloak is our centralized identity hub."

**Time:** 5 minutes

---

### Slide 2.2.2: Authentication Flow
**Content:**
1. User accesses application
2. Redirected to Keycloak
3. User authenticates (MFA)
4. Keycloak issues JWT
5. Application validates JWT
6. User granted access

**Visual Notes:** Authentication flow diagram

**Time:** 5 minutes

---

### Slide 2.2.3: MFA Configuration
**Content:**
- WebAuthn (primary)
- TOTP (backup)
- SMS (fallback)
- MFA required for all users
- Step-up authentication for high-risk

**Visual Notes:** MFA methods diagram

**Time:** 5 minutes

---

### Slide 2.2.4: SCIM 2.0 Automation
**Content:**
- System for Cross-domain Identity Management
- Automated JML:
  - Joiner: Create account
  - Mover: Update permissions
  - Leaver: Disable/delete
- Integration with HRIS (Workday)

**Visual Notes:** SCIM automation flow

**Speaker Notes:** "SCIM automates the entire identity lifecycle."

**Time:** 5 minutes

---

### Slide 2.2.5: JML Workflow
**Content:**
- Joiner: HR triggers → SCIM creates account → Groups assigned → MFA enrollment
- Mover: HR updates → SCIM updates account → Access reviewed
- Leaver: HR terminates → SCIM disables account → Sessions revoked

**Visual Notes:** JML process diagram

**Time:** 5 minutes

---

### Slide 2.2.6: RBAC/ABAC Policies
**Content:**
- Role-Based Access Control
- Attribute-Based Access Control
- OPA policies for authorization
- Least privilege enforcement

**Visual Notes:** RBAC/ABAC diagram

**Speaker Notes:** "RBAC and ABAC work together for fine-grained access control."

**Time:** 5 minutes

---

### Slide 2.2.7: RBAC Policy Example
**Content:**
```rego
role_permissions := {
    "admin": {"allowed_resources": ["*"], "allowed_actions": ["*"]},
    "rd-engineer": {"allowed_resources": ["rd/*"], "allowed_actions": ["read", "write"]},
    "finance": {"allowed_resources": ["finance/*"], "allowed_actions": ["read", "write"]},
}
```

**Visual Notes:** RBAC Rego policy example

**Time:** 5 minutes

---

### Slide 2.2.8: ABAC Policy Example
**Content:**
```rego
allow_abac_clearance := true {
    user_attr := user_attributes[input.user.username]
    resource_attr := resource_attributes[input.resource.name]
    user_attr.clearance_level >= resource_attr.classification_level
}
```

**Visual Notes:** ABAC Rego policy example

**Time:** 5 minutes

---

### Slide 2.2.9: Identity Federation
**Content:**
- SAML 2.0 for Azure AD federation
- Single sign-on across all applications
- Consistent identity management
- User attribute mapping

**Visual Notes:** Federation diagram

**Time:** 5 minutes

---

### Slide 2.2.10: Application Integration
**Content:**
- OIDC integration for custom apps
- SAML integration for legacy apps
- SCIM provisioning for all apps
- Consistent authentication

**Visual Notes:** Application integration diagram

**Time:** 5 minutes

---

### Slide 2.2.11: Security Hardening
**Content:**
- Strong password policy (12+ chars, complexity)
- MFA for all users
- Session management (8 hours max, 15 min idle)
- Credential rotation (90 days)
- Audit logging

**Visual Notes:** Security hardening checklist

**Time:** 5 minutes

---

### Slide 2.2.12: Identity Audit & Monitoring
**Content:**
- Authentication logs
- Authorization decisions
- Account lifecycle events
- MFA enrollment
- SIEM integration

**Visual Notes:** Identity monitoring dashboard

**Time:** 5 minutes

---

### Slide 2.2.13: Section 2.2 Summary
**Content:**
- Keycloak: Identity Provider
- MFA: All users
- SCIM: Automated JML
- RBAC/ABAC: OPA policies
- Federation: Single sign-on

**Visual Notes:** IAM summary diagram

**Time:** 5 minutes

---

## SECTION 2.3: PRIVILEGED ACCESS MANAGEMENT
### 15 Slides | 3 Hours

---

### Slide 2.3.0: PAM Introduction
**Content:**
- Privileged Access Management
- Managing elevated access
- Key concepts:
  - JIT (Just-In-Time)
  - JEA (Just-Enough-Administration)
  - Session recording
  - Credential rotation

**Visual Notes:** PAM overview diagram

**Speaker Notes:** "Privileged access is the most critical to protect."

**Time:** 5 minutes

---

### Slide 2.3.1: HashiCorp Vault Architecture
**Content:**
- Secrets management
- Dynamic credentials
- JIT workflows
- Session recording
- Audit logging

**Visual Notes:** Vault architecture diagram

**Speaker Notes:** "Vault is our PAM solution."

**Time:** 5 minutes

---

### Slide 2.3.2: JIT Access Workflow
**Content:**
1. User requests privileged access
2. Approval workflow (manager + security)
3. Vault generates dynamic credentials
4. Session recording starts
5. Time-bound access (15 min max)
6. Auto-expiration and cleanup

**Visual Notes:** JIT workflow diagram

**Time:** 5 minutes

---

### Slide 2.3.3: JEA (Just Enough Administration)
**Content:**
- Minimal permissions for privileged tasks
- Least privilege applied to admin access
- Granular permission controls
- No permanent admin access

**Visual Notes:** JEA principle diagram

**Speaker Notes:** "Give admins only the permissions they need, when they need them."

**Time:** 5 minutes

---

### Slide 2.3.4: Vault Dynamic Credentials
**Content:**
- AWS IAM roles (dynamic)
- Azure AD credentials
- Database credentials
- API keys
- Service account tokens

**Visual Notes:** Dynamic credentials diagram

**Time:** 5 minutes

---

### Slide 2.3.5: Session Recording
**Content:**
- All privileged sessions recorded
- Audit trail for admin actions
- Compliance evidence
- Incident investigation
- Retention: 365 days

**Visual Notes:** Session recording flow

**Time:** 5 minutes

---

### Slide 2.3.6: Credential Rotation
**Content:**
- Automatic rotation (30 days)
- On-demand rotation
- Secret versioning
- Historical audit
- No secrets exposed in code

**Visual Notes:** Credential rotation diagram

**Time:** 5 minutes

---

### Slide 2.3.7: Break-Glass Access
**Content:**
- Emergency access procedure
- Immediate activation
- 30-minute sessions
- Immediate alerts
- Strict audit requirements
- 2-person approval

**Visual Notes:** Break-glass process diagram

**Speaker Notes:** "Break-glass is for emergencies only. It triggers immediate alerts."

**Time:** 5 minutes

---

### Slide 2.3.8: Break-Glass Workflow
**Content:**
1. Emergency declared
2. User requests break-glass
3. Session activated (30 min)
4. Alerts triggered
5. Actions logged
6. Post-incident review required

**Visual Notes:** Break-glass workflow diagram

**Time:** 5 minutes

---

### Slide 2.3.9: Vault Policies
**Content:**
- Admin: Full access
- Platform Engineer: Infrastructure access
- Security Engineer: Security operations
- Developer: Application secrets
- JIT Admin: Temporary admin
- Break-Glass: Emergency access

**Visual Notes:** Policy hierarchy diagram

**Time:** 5 minutes

---

### Slide 2.3.10: Vault Integration
**Content:**
- Kubernetes authentication
- LDAP integration
- AWS IAM authentication
- Azure AD integration
- CI/CD integration

**Visual Notes:** Integration diagram

**Time:** 5 minutes

---

### Slide 2.3.11: PAM Monitoring
**Content:**
- Privileged access logs
- Session recordings
- Credential usage
- Failed access attempts
- SIEM integration

**Visual Notes:** PAM monitoring dashboard

**Time:** 5 minutes

---

### Slide 2.3.12: PAM Compliance
**Content:**
- Audit logs (365 days)
- Session recordings
- Approval records
- Justification records
- Access reviews

**Visual Notes:** Compliance evidence diagram

**Time:** 5 minutes

---

### Slide 2.3.13: Section 2.3 Summary
**Content:**
- HashiCorp Vault: Secrets + PAM
- JIT: Temporary privileged access
- JEA: Minimal admin permissions
- Session recording: Audit trail
- Break-glass: Emergency access

**Visual Notes:** PAM summary diagram

**Time:** 5 minutes

---

## SECTION 2.4: MICRO-SEGMENTATION & SDP
### 15 Slides | 3 Hours

---

### Slide 2.4.0: Micro-segmentation Introduction
**Content:**
- Fine-grained network isolation
- Limiting blast radius
- East-west traffic control
- Default deny

**Visual Notes:** Micro-segmentation overview diagram

**Speaker Notes:** "Micro-segmentation prevents lateral movement."

**Time:** 5 minutes

---

### Slide 2.4.1: Traditional vs Micro-segmentation
**Content:**
- Traditional: Broad network segments
- Micro-segmentation: Pod/namespace level
- East-west traffic controlled
- Blast radius minimized

**Visual Notes:** Side-by-side comparison diagram

**Time:** 5 minutes

---

### Slide 2.4.2: Calico Network Policies
**Content:**
- Kubernetes-native network policies
- Default deny for all namespaces
- Micro-segmentation
- Flow logs for monitoring

**Visual Notes:** Calico architecture diagram

**Speaker Notes:** "Calico provides network-level segmentation."

**Time:** 5 minutes

---

### Slide 2.4.3: Network Policy Examples
**Content:**
- Default deny
- Allow ingress from gateway
- Allow internal portal communication
- Isolate R&D namespace
- Isolate OT namespace

**Visual Notes:** Network policy YAML examples

**Time:** 5 minutes

---

### Slide 2.4.4: Istio Service Mesh
**Content:**
- Service-to-service communication
- mTLS for all traffic
- Authorization policies
- Telemetry and observability

**Visual Notes:** Istio architecture diagram

**Speaker Notes:** "Istio provides application-layer segmentation."

**Time:** 5 minutes

---

### Slide 2.4.5: Istio Authorization
**Content:**
- PeerAuthentication (mTLS)
- AuthorizationPolicy (RBAC)
- Service-to-service permissions
- Fine-grained controls

**Visual Notes:** Istio authorization example

**Time:** 5 minutes

---

### Slide 2.4.6: SDP - Software-Defined Perimeter
**Content:**
- "Black cloud" architecture
- Infrastructure invisible
- Authentication required before visibility
- OpenZiti implementation

**Visual Notes:** SDP concept diagram

**Speaker Notes:** "SDP hides infrastructure until authenticated."

**Time:** 5 minutes

---

### Slide 2.4.7: SDP Architecture
**Content:**
- SDP Controller
- SDP Gateways (Edge Routers)
- SDP Clients
- Identity provider integration

**Visual Notes:** SDP architecture diagram

**Time:** 5 minutes

---

### Slide 2.4.8: SDP Service Definition
**Content:**
- Customer Portal: Protected by SDP
- R&D Systems: Protected by SDP
- Financial Systems: Protected by SDP
- Policy-based access

**Visual Notes:** SDP service definitions

**Time:** 5 minutes

---

### Slide 2.4.9: East-West Traffic Controls
**Content:**
- Circuit breaking
- Retry policies
- Timeouts
- Rate limiting
- Load balancing

**Visual Notes:** East-west controls diagram

**Time:** 5 minutes

---

### Slide 2.4.10: Blast Radius Minimization
**Content:**
- Limit blast radius for incidents
- Production isolation from R&D
- OT complete isolation
- Environment isolation (dev, stage, prod)

**Visual Notes:** Blast radius diagram

**Speaker Notes:** "Limit the impact of any security incident."

**Time:** 5 minutes

---

### Slide 2.4.11: Policy Automation
**Content:**
- Automated policy deployment
- Policy validation
- Compliance checking
- Audit logging
- GitOps workflow

**Visual Notes:** Policy automation diagram

**Time:** 5 minutes

---

### Slide 2.4.12: Section 2.4 Summary
**Content:**
- Calico: Network micro-segmentation
- Istio: Service mesh
- SDP: Black cloud
- East-West controls
- Blast radius minimization

**Visual Notes:** Micro-segmentation summary diagram

**Time:** 5 minutes

---

### Slide 2.4.13: Part 2 Summary
**Content:**
- Zero Trust Architecture (NIST SP 800-207)
- Identity & Access Management (Keycloak)
- Privileged Access Management (Vault)
- Micro-segmentation & SDP

**Visual Notes:** Part 2 summary diagram

**Speaker Notes:** "Part 2 built the Zero Trust foundation for the enterprise."

**Time:** 5 minutes

---

## SECTION 3: CLOUD-NATIVE SECURITY
### Part 3: 70 Slides | 3.5 Days

---

### Slide 3.0: Part 3 Introduction
**Content:**
- Cloud-Native Security & Modern Workloads
- 5 sections:
  3.1 Multi-Cloud Security
  3.2 Container & Kubernetes Security
  3.3 Infrastructure as Code Security
  3.4 API Security
  3.5 DevSecOps CI/CD

**Visual Notes:** Part 3 section overview diagram

**Speaker Notes:** "Part 3 secures the cloud-native environment."

**Time:** 2 minutes

---

## SECTION 3.1: MULTI-CLOUD SECURITY
### 15 Slides | 3 Hours

---

### Slide 3.1.0: Multi-Cloud Security Introduction
**Content:**
- AWS + Azure landing zones
- Consistent security controls
- Shared responsibility model
- CSPM automation

**Visual Notes:** Multi-cloud overview diagram

**Speaker Notes:** "We need consistent security across multiple clouds."

**Time:** 5 minutes

---

### Slide 3.1.1: Multi-Cloud Strategy
**Content:**
- AWS: Primary (60% workloads)
- Azure: Secondary (20% workloads)
- On-premises: Legacy/OT (15%)
- Consistent controls

**Visual Notes:** Multi-cloud strategy diagram

**Time:** 5 minutes

---

### Slide 3.1.2: AWS Landing Zone
**Content:**
- AWS Organizations (multi-account)
- Organizational Units: Security, Infrastructure, Workloads
- SCPs (Service Control Policies)
- Security Hub, GuardDuty, Config

**Visual Notes:** AWS landing zone diagram

**Time:** 5 minutes

---

### Slide 3.1.3: AWS SCP Examples
**Content:**
- Deny public S3 buckets
- Restrict regions
- Require encryption
- Enforce TLS

**Visual Notes:** SCP policy examples

**Time:** 5 minutes

---

### Slide 3.1.4: Azure Landing Zone
**Content:**
- Management Groups
- Azure Policy (equivalent to SCPs)
- Security Center
- Sentinel
- Defender

**Visual Notes:** Azure landing zone diagram

**Time:** 5 minutes

---

### Slide 3.1.5: Azure Policy Examples
**Content:**
- Allowed regions
- Require encryption
- Restrict network access
- Enforce tagging

**Visual Notes:** Azure policy examples

**Time:** 5 minutes

---

### Slide 3.1.6: Shared Responsibility Model
**Content:**
- Cloud Provider: Physical, hardware, hypervisor
- Customer: Data, apps, OS, config
- Implications for security

**Visual Notes:** Shared responsibility diagram

**Speaker Notes:** "Know who is responsible for what."

**Time:** 5 minutes

---

### Slide 3.1.7: Shared Responsibility by Service Model
**Content:**
- IaaS: Customer responsible for OS, apps, data
- PaaS: Customer responsible for apps, data
- SaaS: Customer responsible for data, user mgmt

**Visual Notes:** Responsibility matrix

**Time:** 5 minutes

---

### Slide 3.1.8: CSPM Automation
**Content:**
- AWS Security Hub
- Azure Security Center
- Continuous compliance monitoring
- Automated remediation
- Reporting

**Visual Notes:** CSPM architecture diagram

**Speaker Notes:** "CSPM provides continuous cloud compliance."

**Time:** 5 minutes

---

### Slide 3.1.9: Cross-Cloud IAM
**Content:**
- Azure AD → AWS IAM federation
- Single sign-on
- Consistent RBAC/ABAC
- SCIM provisioning

**Visual Notes:** Cross-cloud IAM diagram

**Time:** 5 minutes

---

### Slide 3.1.10: Cross-Cloud Identity Configuration
**Content:**
- Azure AD Application for federation
- AWS IAM Role for cross-cloud
- Permission sets
- Group mappings

**Visual Notes:** Cross-cloud identity config

**Time:** 5 minutes

---

### Slide 3.1.11: Compliance Automation
**Content:**
- CIS AWS Benchmark controls
- CIS Azure Benchmark controls
- NIST 800-53 controls
- Automated compliance checks

**Visual Notes:** Compliance automation diagram

**Time:** 5 minutes

---

### Slide 3.1.12: Cross-Cloud Monitoring
**Content:**
- SIEM aggregation (ELK)
- Unified dashboards
- Cross-cloud alerts
- Compliance reporting

**Visual Notes:** Cross-cloud monitoring architecture

**Time:** 5 minutes

---

### Slide 3.1.13: Cross-Cloud Backup & DR
**Content:**
- AWS → Azure replication
- Immutable backups
- Cross-cloud DR failover
- RTO/RPO validation

**Visual Notes:** Cross-cloud backup architecture

**Time:** 5 minutes

---

### Slide 3.1.14: Section 3.1 Summary
**Content:**
- AWS + Azure landing zones
- Shared responsibility model
- CSPM automation
- Cross-cloud IAM
- Compliance automation

**Visual Notes:** Multi-cloud summary diagram

**Time:** 5 minutes

---

## SECTION 3.2: CONTAINER & KUBERNETES SECURITY
### 15 Slides | 3 Hours

---

### Slide 3.2.0: Container Security Introduction
**Content:**
- Container security controls
- Image scanning
- SBOM generation
- Image signing
- Runtime security

**Visual Notes:** Container security overview diagram

**Speaker Notes:** "Containers need security at every stage."

**Time:** 5 minutes

---

### Slide 3.2.1: Container Security Lifecycle
**Content:**
- Build: Image scanning, SBOM, signing
- Deploy: Admission controllers, pod security
- Runtime: Falco, monitoring, isolation

**Visual Notes:** Container lifecycle diagram

**Time:** 5 minutes

---

### Slide 3.2.2: Trivy Image Scanning
**Content:**
- Vulnerability scanning
- OS and application vulnerabilities
- SBOM generation
- CI/CD integration

**Visual Notes:** Trivy scanning diagram

**Time:** 5 minutes

---

### Slide 3.2.3: SBOM Generation (Syft)
**Content:**
- Software Bill of Materials
- All components in container
- CycloneDX and SPDX formats
- Vulnerability correlation

**Visual Notes:** SBOM generation diagram

**Speaker Notes:** "Know exactly what's in your containers."

**Time:** 5 minutes

---

### Slide 3.2.4: Image Signing (Cosign)
**Content:**
- Digital signing of images
- Integrity verification
- Supply chain security
- Sigstore integration

**Visual Notes:** Image signing flow

**Time:** 5 minutes

---

### Slide 3.2.5: Kubernetes Security Overview
**Content:**
- API server security
- RBAC
- Admission controllers
- Pod security
- Network security

**Visual Notes:** Kubernetes security overview

**Time:** 5 minutes

---

### Slide 3.2.6: Kubernetes RBAC
**Content:**
- Roles and ClusterRoles
- RoleBindings and ClusterRoleBindings
- Least privilege
- Service accounts

**Visual Notes:** RBAC architecture diagram

**Time:** 5 minutes

---

### Slide 3.2.7: RBAC Configuration Example
**Content:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: readonly-clusterrole
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
```

**Visual Notes:** RBAC YAML example

**Time:** 5 minutes

---

### Slide 3.2.8: Kyverno Admission Controller
**Content:**
- Policy enforcement
- Validation and mutation
- Kubernetes-native
- Policy examples

**Visual Notes:** Kyverno architecture diagram

**Speaker Notes:** "Kyverno enforces policies on all Kubernetes resources."

**Time:** 5 minutes

---

### Slide 3.2.9: Kyverno Policy Examples
**Content:**
- Require image tags (no 'latest')
- Require resource limits
- Require non-root user
- Deny privilege escalation

**Visual Notes:** Kyverno policy examples

**Time:** 5 minutes

---

### Slide 3.2.10: Pod Security Standards (PSA)
**Content:**
- Restricted (production, OT)
- Baseline (R&D, dev)
- Privileged (legacy)
- Namespace labels

**Visual Notes:** Pod security diagram

**Time:** 5 minutes

---

### Slide 3.2.11: Falco Runtime Security
**Content:**
- Runtime threat detection
- Shell detection
- Outbound connections
- Privileged containers
- Sensitive mounts

**Visual Notes:** Falco architecture diagram

**Speaker Notes:** "Falco monitors running containers for suspicious activity."

**Time:** 5 minutes

---

### Slide 3.2.12: Kubernetes Audit Logging
**Content:**
- API server audit logs
- Audit policy configuration
- Webhook to SIEM
- Monitoring and alerting

**Visual Notes:** Audit logging flow

**Time:** 5 minutes

---

### Slide 3.2.13: Section 3.2 Summary
**Content:**
- Trivy: Image scanning
- SBOM: Supply chain transparency
- Cosign: Image signing
- Kyverno: Admission control
- Falco: Runtime security

**Visual Notes:** Container/K8s summary diagram

**Time:** 5 minutes

---

## SECTION 3.3: INFRASTRUCTURE AS CODE SECURITY
### 15 Slides | 3 Hours

---

### Slide 3.3.0: IaC Security Introduction
**Content:**
- Infrastructure as Code security
- Terraform scanning
- Policy-as-Code (OPA/Sentinel)
- CI/CD security gates
- Secret management

**Visual Notes:** IaC security overview diagram

**Speaker Notes:** "Security must be built into infrastructure code."

**Time:** 5 minutes

---

### Slide 3.3.1: Terraform Security Scanning
**Content:**
- Terrascan: Vulnerability scanning
- Checkov: Misconfiguration detection
- CIS benchmarks
- Custom policies

**Visual Notes:** Scanning tools diagram

**Time:** 5 minutes

---

### Slide 3.3.2: Terrascan Example
**Content:**
```bash
terrascan scan -i terraform -d . --severity critical,high
```

**Visual Notes:** Terrascan command and output

**Time:** 5 minutes

---

### Slide 3.3.3: Checkov Example
**Content:**
```bash
checkov -d . --framework terraform
```

**Visual Notes:** Checkov command and output

**Time:** 5 minutes

---

### Slide 3.3.4: Policy-as-Code (OPA)
**Content:**
- OPA policies for IaC
- RDS encryption check
- S3 encryption check
- Security group checks

**Visual Notes:** OPA IaC policy examples

**Time:** 5 minutes

---

### Slide 3.3.5: OPA Policy Example
**Content:**
```rego
# Require RDS encryption
deny[msg] {
    resource := input.resource.aws_db_instance[_]
    resource.storage_encrypted == false
    msg := sprintf("RDS instance %s must have encryption enabled", [resource.name])
}
```

**Visual Notes:** OPA policy code

**Time:** 5 minutes

---

### Slide 3.3.6: Sentinel Policies
**Content:**
- Terraform Cloud/Enterprise
- Policy-as-Code
- Enforce tagging
- Require encryption

**Visual Notes:** Sentinel policy examples

**Time:** 5 minutes

---

### Slide 3.3.7: CI/CD Security Gates
**Content:**
- Pre-commit hooks
- Security scanning stage
- Policy check stage
- Deployment approval gate

**Visual Notes:** Security gate diagram

**Speaker Notes:** "Security gates ensure only secure code is deployed."

**Time:** 5 minutes

---

### Slide 3.3.8: GitLab CI Security Pipeline
**Content:**
- Pre-commit: fmt, validate
- Security scan: Terrascan, Checkov
- Policy check: OPA
- Deployment: Manual approval

**Visual Notes:** GitLab CI pipeline diagram

**Time:** 5 minutes

---

### Slide 3.3.9: GitHub Actions Security Workflow
**Content:**
- Setup Terraform
- Terraform format & validate
- Run Terrascan
- Run Checkov
- Run OPA policy
- Upload security results

**Visual Notes:** GitHub Actions workflow

**Time:** 5 minutes

---

### Slide 3.3.10: Secrets Management in IaC
**Content:**
- Vault integration
- Terraform Vault provider
- Dynamic credentials
- No secrets in code

**Visual Notes:** Vault-Terraform integration

**Speaker Notes:** "Never hardcode secrets in IaC."

**Time:** 5 minutes

---

### Slide 3.3.11: Vault Terraform Integration
**Content:**
```hcl
data "vault_generic_secret" "aws_credentials" {
  path = "secret/data/aws/production"
}

resource "aws_db_instance" "main" {
  username = data.vault_generic_secret.aws_credentials.data["db_username"]
  password = data.vault_generic_secret.aws_credentials.data["db_password"]
}
```

**Visual Notes:** Vault-Terraform code example

**Time:** 5 minutes

---

### Slide 3.3.12: Compliance Validation
**Content:**
- NIST 800-53 compliance checks
- CIS compliance checks
- PCI DSS compliance checks
- Automated validation

**Visual Notes:** Compliance validation diagram

**Time:** 5 minutes

---

### Slide 3.3.13: Section 3.3 Summary
**Content:**
- Terrascan/Checkov: IaC scanning
- OPA/Sentinel: Policy-as-Code
- CI/CD gates: Security controls
- Vault: Secret management
- Compliance: Automated validation

**Visual Notes:** IaC summary diagram

**Time:** 5 minutes

---

## SECTION 3.4: API SECURITY
### 15 Slides | 3 Hours

---

### Slide 3.4.0: API Security Introduction
**Content:**
- OWASP API Security Top 10
- API Gateway security
- JWT validation
- Rate limiting
- Input validation

**Visual Notes:** API security overview diagram

**Speaker Notes:** "APIs are the most common attack vector."

**Time:** 5 minutes

---

### Slide 3.4.1: OWASP API Top 10
**Content:**
1. Broken Object Level Authorization (BOLA)
2. Broken Authentication
3. Excessive Data Exposure
4. Lack of Resources & Rate Limiting
5. Broken Function Level Authorization
6. Mass Assignment
7. Security Misconfiguration
8. Injection
9. Improper Asset Management
10. Insufficient Logging & Monitoring

**Visual Notes:** OWASP API Top 10 list

**Time:** 5 minutes

---

### Slide 3.4.2: API Gateway Security
**Content:**
- Kong API Gateway
- Authentication (OIDC, JWT)
- Rate limiting
- OWASP protections
- Request validation

**Visual Notes:** Kong architecture diagram

**Speaker Notes:** "API Gateway is the security control point."

**Time:** 5 minutes

---

### Slide 3.4.3: Kong Security Plugins
**Content:**
- OIDC: Authentication
- JWT: Token validation
- Rate Limiting: Request throttling
- CORS: Cross-origin protection
- OWASP: API Top 10 protections

**Visual Notes:** Kong plugins diagram

**Time:** 5 minutes

---

### Slide 3.4.4: JWT Validation
**Content:**
- OIDC integration with Keycloak
- JWT signature validation
- Claim validation (exp, aud, iss)
- MFA claim check

**Visual Notes:** JWT validation flow

**Time:** 5 minutes

---

### Slide 3.4.5: JWT Validation Service
**Content:**
- Node.js/Express service
- JWKS client for public keys
- Token validation middleware
- Claim validation

**Visual Notes:** JWT validation service code

**Time:** 5 minutes

---

### Slide 3.4.6: Rate Limiting
**Content:**
- Per-user limits (100 req/min)
- Per-IP limits
- API-specific limits
- Redis for distributed rate limiting

**Visual Notes:** Rate limiting diagram

**Time:** 5 minutes

---

### Slide 3.4.7: Rate Limiting Configuration
**Content:**
```yaml
config:
  minute: 100
  hour: 10000
  policy: redis
  redis_host: redis.default.svc.cluster.local
  limit_by: consumer
```

**Visual Notes:** Rate limiting YAML

**Time:** 5 minutes

---

### Slide 3.4.8: Input Validation
**Content:**
- JSON schema validation
- SQL injection detection
- XSS detection
- Input sanitization

**Visual Notes:** Input validation diagram

**Speaker Notes:** "Validate all inputs, reject invalid data."

**Time:** 5 minutes

---

### Slide 3.4.9: JSON Schema Example
**Content:**
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "customer_id": {
      "type": "string",
      "pattern": "^CUST-[0-9]{6}$"
    },
    "items": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50
    }
  },
  "required": ["customer_id", "items"]
}
```

**Visual Notes:** JSON schema example

**Time:** 5 minutes

---

### Slide 3.4.10: API Security Testing (ZAP)
**Content:**
- OWASP ZAP automated scanning
- Active scan: SQLi, XSS, etc.
- Passive scan: Headers, cookies
- CI/CD integration

**Visual Notes:** ZAP scanning diagram

**Time:** 5 minutes

---

### Slide 3.4.11: ZAP Scan Configuration
**Content:**
```yaml
rules:
  active_scan:
    - rule_id: 40012  # XSS
    - rule_id: 40006  # SQL Injection
    - rule_id: 40009  # Path Traversal
  passive_scan:
    - rule_id: 10054  # Cookie HttpOnly
    - rule_id: 10055  # Cookie Secure
```

**Visual Notes:** ZAP rules configuration

**Time:** 5 minutes

---

### Slide 3.4.12: API Security Unit Tests
**Content:**
- Authentication tests
- JWT validation tests
- Rate limiting tests
- Input validation tests
- HTTPS enforcement tests

**Visual Notes:** API test examples

**Time:** 5 minutes

---

### Slide 3.4.13: Section 3.4 Summary
**Content:**
- OWASP API Top 10 protections
- Kong API Gateway
- JWT validation
- Rate limiting
- Input validation
- Automated testing

**Visual Notes:** API security summary diagram

**Time:** 5 minutes

---

## SECTION 3.5: DEVSECOPS CI/CD
### 15 Slides | 3 Hours

---

### Slide 3.5.0: DevSecOps Introduction
**Content:**
- Security in CI/CD pipelines
- Shift-left security
- SAST, DAST, SCA
- Container scanning
- Policy enforcement

**Visual Notes:** DevSecOps overview diagram

**Speaker Notes:** "Security must be embedded in the development pipeline."

**Time:** 5 minutes

---

### Slide 3.5.1: The DevSecOps Pipeline
**Content:**
- Plan → Code → Build → Test → Release → Deploy → Operate
- Security at every stage
- Shift-left: Security earlier in the process

**Visual Notes:** DevSecOps pipeline diagram

**Time:** 5 minutes

---

### Slide 3.5.2: SAST Integration
**Content:**
- Static Application Security Testing
- Semgrep for code scanning
- OWASP Top 10 rules
- Custom rules
- Fail on critical/high findings

**Visual Notes:** SAST architecture diagram

**Speaker Notes:** "SAST finds vulnerabilities in code before it runs."

**Time:** 5 minutes

---

### Slide 3.5.3: SAST Rule Example
**Content:**
```yaml
rules:
  - id: owasp-top10-a03-injection
    pattern: |
      query = "SELECT * FROM users WHERE id = " + user_input
    message: "SQL injection risk"
    severity: ERROR
```

**Visual Notes:** SAST rule example

**Time:** 5 minutes

---

### Slide 3.5.4: SCA Integration
**Content:**
- Software Composition Analysis
- Dependency vulnerability scanning
- License compliance
- Fail on critical/high vulnerabilities

**Visual Notes:** SCA architecture diagram

**Speaker Notes:** "SCA finds vulnerabilities in dependencies."

**Time:** 5 minutes

---

### Slide 3.5.5: Container Scanning in CI/CD
**Content:**
- Trivy in CI/CD pipeline
- Build → Scan → Fail/Succeed
- SBOM generation
- Image signing

**Visual Notes:** Container scanning pipeline

**Time:** 5 minutes

---

### Slide 3.5.6: Pipeline Hardening
**Content:**
- GitLab Runner security
- Protected variables
- Secret masking
- Branch protection
- Audit logging

**Visual Notes:** Pipeline hardening checklist

**Time:** 5 minutes

---

### Slide 3.5.7: GitLab CI Security Configuration
**Content:**
- Runner security settings
- Protected variables (main only)
- Secret masking in logs
- Job token scoping

**Visual Notes:** GitLab CI security config

**Time:** 5 minutes

---

### Slide 3.5.8: Secret Management in CI/CD
**Content:**
- Vault for secrets
- No secrets in code
- Dynamic credentials
- Secure variable injection

**Visual Notes:** Vault-CI/CD integration

**Time:** 5 minutes

---

### Slide 3.5.9: CI/CD Audit Logging
**Content:**
- All pipeline events logged
- Audit to SIEM
- Security event tracking
- Compliance evidence

**Visual Notes:** Audit logging architecture

**Time:** 5 minutes

---

### Slide 3.5.10: Policy Enforcement in CI/CD
**Content:**
- OPA policies for pipelines
- Must pass all checks
- Zero critical vulnerabilities
- Limited high vulnerabilities
- Required approvals

**Visual Notes:** Policy enforcement diagram

**Speaker Notes:** "Automated policies block insecure deployments."

**Time:** 5 minutes

---

### Slide 3.5.11: CI/CD Security Gates Summary
**Content:**
- Gate 1: Pre-commit (secrets, format)
- Gate 2: Build (SAST, SCA)
- Gate 3: Container (scan, SBOM)
- Gate 4: Deploy (policy, approvals)

**Visual Notes:** Security gates diagram

**Time:** 5 minutes

---

### Slide 3.5.12: Section 3.5 Summary
**Content:**
- SAST: Code vulnerability scanning
- SCA: Dependency scanning
- Container scanning: Trivy
- Pipeline hardening
- Policy enforcement

**Visual Notes:** DevSecOps summary diagram

**Time:** 5 minutes

---

### Slide 3.5.13: Part 3 Summary
**Content:**
- Multi-Cloud Security: AWS + Azure
- Container/K8s Security: Trivy, Kyverno, Falco
- IaC Security: Terrascan, Checkov, OPA
- API Security: OWASP Top 10, Kong
- DevSecOps: SAST, DAST, SCA

**Visual Notes:** Part 3 summary diagram

**Speaker Notes:** "Part 3 secured the cloud-native environment."

**Time:** 5 minutes

---

## SECTION 4: DETECTION, RESPONSE & RESILIENCE
### Part 4: 80 Slides | 4 Days

---

### Slide 4.0: Part 4 Introduction
**Content:**
- Detection, Response & Operational Resilience
- 6 sections:
  4.1 SIEM/XDR
  4.2 Detection Engineering
  4.3 Threat Hunting
  4.4 SOAR Automation
  4.5 Chaos Engineering
  4.6 Business Continuity

**Visual Notes:** Part 4 section overview diagram

**Speaker Notes:** "Part 4 is about assuming breach and building resilience."

**Time:** 2 minutes

---

## SECTION 4.1: SIEM/XDR ARCHITECTURE
### 15 Slides | 3 Hours

---

### Slide 4.1.0: SIEM Introduction
**Content:**
- Security Information and Event Management
- Centralized logging and analysis
- Detection and alerting
- Compliance evidence

**Visual Notes:** SIEM overview diagram

**Speaker Notes:** "SIEM is your central nervous system for security."

**Time:** 5 minutes

---

### Slide 4.1.1: SIEM Architecture
**Content:**
- Data sources: Application, System, Security, Cloud, XDR
- Logstash: Ingestion and enrichment
- Elasticsearch: Storage and indexing
- Kibana: Visualization and dashboards

**Visual Notes:** SIEM architecture diagram

**Time:** 5 minutes

---

### Slide 4.1.2: ELK Stack Components
**Content:**
- Elasticsearch: Distributed search and analytics
- Logstash: Data processing pipeline
- Kibana: Visualization
- Beats: Lightweight shippers

**Visual Notes:** ELK stack diagram

**Time:** 5 minutes

---

### Slide 4.1.3: Elasticsearch Configuration
**Content:**
- Cluster (3 nodes)
- Index templates
- ILM policies
- Security (TLS, auth)

**Visual Notes:** Elasticsearch configuration

**Time:** 5 minutes

---

### Slide 4.1.4: Logstash Pipelines
**Content:**
- Main pipeline: General logs
- Security pipeline: Security logs
- Audit pipeline: Audit logs
- Application pipeline: App logs

**Visual Notes:** Logstash pipelines diagram

**Time:** 5 minutes

---

### Slide 4.1.5: Logstash Pipeline Example
**Content:**
```conf
input {
  beats { port => 5044 }
}
filter {
  date { match => [ "timestamp", "ISO8601" ] }
  geoip { source => "source_ip" }
}
output {
  elasticsearch { hosts => ["elasticsearch:9200"] }
}
```

**Visual Notes:** Logstash configuration example

**Time:** 5 minutes

---

### Slide 4.1.6: Kibana Dashboards
**Content:**
- Security Overview Dashboard
- Incident Response Dashboard
- Threat Hunting Workspace
- Compliance Dashboard

**Visual Notes:** Kibana dashboard examples

**Time:** 5 minutes

---

### Slide 4.1.7: XDR Integration
**Content:**
- CrowdStrike Falcon XDR
- Endpoint telemetry
- Malware detection
- Endpoint isolation
- SIEM integration

**Visual Notes:** XDR architecture diagram

**Speaker Notes:** "XDR extends SIEM to the endpoint."

**Time:** 5 minutes

---

### Slide 4.1.8: Log Retention Strategy
**Content:**
- Hot: 90 days (fast access)
- Warm: 180 days (slow access)
- Cold: 365 days (archive)
- Delete: 365+ days

**Visual Notes:** Retention tiers diagram

**Time:** 5 minutes

---

### Slide 4.1.9: Backup & Archiving
**Content:**
- Daily snapshots
- Cross-region replication
- Immutable storage
- Automated backup schedule

**Visual Notes:** Backup architecture diagram

**Time:** 5 minutes

---

### Slide 4.1.10: Section 4.1 Summary
**Content:**
- SIEM: ELK Stack
- XDR: CrowdStrike
- Logstash: Ingestion
- Elasticsearch: Storage
- Kibana: Visualization

**Visual Notes:** SIEM/XDR summary diagram

**Time:** 5 minutes

---

## SECTION 4.2: DETECTION ENGINEERING
### 15 Slides | 3 Hours

---

### Slide 4.2.0: Detection Engineering Introduction
**Content:**
- Creating detection rules
- Sigma standard format
- MITRE ATT&CK mapping
- Rule lifecycle

**Visual Notes:** Detection engineering overview diagram

**Speaker Notes:** "Detection engineering is about building the rules that find threats."

**Time:** 5 minutes

---

### Slide 4.2.1: Sigma Rules
**Content:**
- Vendor-neutral detection format
- Portable across SIEMs
- Community library
- Structured and testable

**Visual Notes:** Sigma format diagram

**Time:** 5 minutes

---

### Slide 4.2.2: Sigma Rule Structure
**Content:**
- Title and ID
- Status (production/development)
- Description
- Tags (MITRE ATT&CK)
- Logsource (product, service)
- Detection (selection, condition)
- False positives
- Level (critical/high/medium/low)

**Visual Notes:** Sigma rule anatomy

**Time:** 5 minutes

---

### Slide 4.2.3: Sigma Rule Example
**Content:**
```yaml
title: "Credential Dumping via LSASS"
id: "rule-001"
status: "production"
tags:
  - attack.t1003
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4688
    CommandLine:
      - "*lsass*"
      - "*procdump*"
  condition: selection
level: high
```

**Visual Notes:** Sigma rule code example

**Time:** 5 minutes

---

### Slide 4.2.4: MITRE ATT&CK Mapping
**Content:**
- Each rule maps to ATT&CK techniques
- T1003: Credential Dumping
- T1068: Privilege Escalation
- T1021: Lateral Movement
- T1486: Ransomware

**Visual Notes:** ATT&CK mapping table

**Time:** 5 minutes

---

### Slide 4.2.5: Detection Coverage
**Content:**
- Tactic coverage
- Technique coverage
- Coverage gaps
- Priority improvements

**Visual Notes:** Coverage matrix

**Time:** 5 minutes

---

### Slide 4.2.6: Rule Testing Framework
**Content:**
- Test cases per rule
- Positive and negative tests
- Automated testing
- False positive validation

**Visual Notes:** Test framework diagram

**Speaker Notes:** "Rules must be tested before deployment."

**Time:** 5 minutes

---

### Slide 4.2.7: Rule Lifecycle
**Content:**
1. Identify threat
2. Develop rule
3. Test rule
4. Deploy rule
5. Monitor alerts
6. Tune as needed
7. Review and improve

**Visual Notes:** Rule lifecycle diagram

**Time:** 5 minutes

---

### Slide 4.2.8: False Positive Management
**Content:**
- False positive identification
- Tuning strategies
- Exception management
- Continuous improvement

**Visual Notes:** FP management process

**Time:** 5 minutes

---

### Slide 4.2.9: Section 4.2 Summary
**Content:**
- Sigma rules
- MITRE ATT&CK mapping
- Rule testing
- Detection lifecycle
- False positive management

**Visual Notes:** Detection summary diagram

**Time:** 5 minutes

---

## SECTION 4.3: THREAT HUNTING
### 15 Slides | 3 Hours

---

### Slide 4.3.0: Threat Hunting Introduction
**Content:**
- Proactive threat detection
- Hypothesis-driven approach
- Finding unknown threats
- Continuous improvement

**Visual Notes:** Threat hunting overview

**Speaker Notes:** "Hunting finds threats that automated detection misses."

**Time:** 5 minutes

---

### Slide 4.3.1: Reactive vs Proactive
**Content:**
- Reactive: Alert → Investigate → Respond
- Proactive: Hypothesis → Search → Discover

**Visual Notes:** Comparison diagram

**Time:** 5 minutes

---

### Slide 4.3.2: Hunting Process
**Content:**
1. Hypothesis formulation
2. Data collection
3. Analysis & investigation
4. Discovery & validation
5. Improvement

**Visual Notes:** Hunting process diagram

**Time:** 5 minutes

---

### Slide 4.3.3: Hypothesis Types
**Content:**
- Intel-Based: Driven by threat intelligence
- Data-Driven: Driven by data analysis
- TTP-Based: Driven by attacker behavior
- Analytics-Based: Driven by anomalies

**Visual Notes:** Hypothesis types diagram

**Time:** 5 minutes

---

### Slide 4.3.4: Hunting Playbooks
**Content:**
- Credential Dumping Hunt
- Lateral Movement Hunt
- Data Exfiltration Hunt
- Privilege Escalation Hunt

**Visual Notes:** Playbook examples

**Time:** 5 minutes

---

### Slide 4.3.5: Credential Dumping Hunt
**Content:**
- Hypothesis: Attackers may be dumping credentials
- Data sources: Windows logs, Sysmon
- Query: LSASS access, suspicious processes
- Validation: Review findings

**Visual Notes:** Credential dumping hunt flow

**Time:** 5 minutes

---

### Slide 4.3.6: Hunting Queries
**Content:**
- Elasticsearch queries
- Kibana queries
- Python analytics
- Jupyter notebooks

**Visual Notes:** Hunting query examples

**Time:** 5 minutes

---

### Slide 4.3.7: Jupyter Hunting Notebook
**Content:**
- Interactive hunting environment
- Data exploration
- Visualization
- Collaboration

**Visual Notes:** Jupyter notebook example

**Speaker Notes:** "Jupyter notebooks provide an interactive hunting environment."

**Time:** 5 minutes

---

### Slide 4.3.8: Hunting Tools
**Content:**
- SIEM (Kibana)
- Jupyter notebooks
- Python analytics
- MITRE ATT&CK Navigator
- Threat intelligence feeds

**Visual Notes:** Hunting tools diagram

**Time:** 5 minutes

---

### Slide 4.3.9: Hunting Findings
**Content:**
- Confirmed Threat: Escalate to IR
- Suspicious: Monitor and investigate
- False Positive: Document and tune
- No Finding: Document and archive

**Visual Notes:** Findings classification

**Time:** 5 minutes

---

### Slide 4.3.10: Section 4.3 Summary
**Content:**
- Hypothesis-driven hunting
- Hunting playbooks
- Data analysis
- Jupyter notebooks
- Findings classification

**Visual Notes:** Threat hunting summary

**Time:** 5 minutes

---

## SECTION 4.4: SOAR AUTOMATION
### 15 Slides | 3 Hours

---

### Slide 4.4.0: SOAR Introduction
**Content:**
- Security Orchestration, Automation, and Response
- Automated incident response
- Playbook execution
- Case management

**Visual Notes:** SOAR overview diagram

**Speaker Notes:** "SOAR automates the response process."

**Time:** 5 minutes

---

### Slide 4.4.1: SOAR Components
**Content:**
- Orchestration: Connect tools
- Automation: Execute playbooks
- Response: Take actions
- Case Management: Track incidents

**Visual Notes:** SOAR components diagram

**Time:** 5 minutes

---

### Slide 4.4.2: Playbooks
**Content:**
- Phishing Response
- Ransomware Response
- Compromised Credentials
- Zero Trust Violation
- API Abuse

**Visual Notes:** Playbook examples

**Time:** 5 minutes

---

### Slide 4.4.3: Phishing Response Playbook
**Content:**
1. Alert Triage (5 min)
2. Email Analysis (10 min)
3. User Isolation (5 min)
4. Containment (10 min)
5. User Notification (15 min)
6. Case Documentation (15 min)

**Visual Notes:** Phishing playbook flow

**Time:** 5 minutes

---

### Slide 4.4.4: Ransomware Response Playbook
**Content:**
1. Alert Triage (5 min)
2. Network Isolation (2 min)
3. Credential Protection (5 min)
4. Backup Recovery (30 min)
5. System Restoration (1 hour)
6. Post-Incident Analysis (4 hours)

**Visual Notes:** Ransomware playbook flow

**Time:** 5 minutes

---

### Slide 4.4.5: Alert Enrichment
**Content:**
- Threat intelligence
- GeoIP lookup
- WHOIS lookup
- URL reputation
- User context

**Visual Notes:** Enrichment flow

**Time:** 5 minutes

---

### Slide 4.4.6: Case Management
**Content:**
- Case creation
- Case assignment
- Status tracking
- Collaboration
- Documentation

**Visual Notes:** Case management flow

**Time:** 5 minutes

---

### Slide 4.4.7: Automated Actions
**Content:**
- Quarantine mailbox
- Disable account
- Reset password
- Revoke sessions
- Block IP
- Isolate endpoint
- Rotate credentials

**Visual Notes:** Automated actions list

**Time:** 5 minutes

---

### Slide 4.4.8: SOAR Integrations
**Content:**
- SIEM (ELK)
- Identity (Keycloak)
- Vault
- XDR (CrowdStrike)
- Email Gateway
- Network Policy (Calico)
- Communication (Slack)

**Visual Notes:** Integration diagram

**Time:** 5 minutes

---

### Slide 4.4.9: Section 4.4 Summary
**Content:**
- Playbooks: Automated response
- Enrichment: Context
- Case Management: Tracking
- Automated Actions: Response
- Integrations: Connected

**Visual Notes:** SOAR summary diagram

**Time:** 5 minutes

---

## SECTION 4.5: CHAOS ENGINEERING
### 15 Slides | 3 Hours

---

### Slide 4.5.0: Chaos Engineering Introduction
**Content:**
- Testing system resilience
- Injecting failures
- Measuring recovery
- Continuous improvement

**Visual Notes:** Chaos engineering overview

**Speaker Notes:** "Chaos engineering tests if your systems can survive failures."

**Time:** 5 minutes

---

### Slide 4.5.1: The Chaos Principle
**Content:**
- Fire drills for systems
- Test before real incidents
- Find weaknesses proactively
- Build confidence

**Visual Notes:** Chaos principle diagram

**Time:** 5 minutes

---

### Slide 4.5.2: Failure Scenarios
**Content:**
- CHAOS-001: Node Failure (Weekly)
- CHAOS-002: Network Partition (Bi-weekly)
- CHAOS-003: DNS Failure (Weekly)
- CHAOS-004: Database Failure (Weekly)
- CHAOS-005: CPU Pressure (Monthly)

**Visual Notes:** Failure scenarios list

**Time:** 5 minutes

---

### Slide 4.5.3: Security Chaos Experiments
**Content:**
- IAM Policy Revocation (Monthly)
- MFA Bypass Simulation (Monthly)
- Ransomware Simulation (Quarterly)
- Credential Replay Attack (Monthly)
- Zero Trust Violation (Weekly)
- API Security Control Test (Weekly)

**Visual Notes:** Security chaos list

**Time:** 5 minutes

---

### Slide 4.5.4: Resilience Validation
**Content:**
- MTTD measurement
- MTTR measurement
- Recovery rate
- Error rate
- Resilience scoring

**Visual Notes:** Resilience metrics

**Time:** 5 minutes

---

### Slide 4.5.5: Chaos Test Process
**Content:**
1. Define hypothesis
2. Plan test
3. Execute test
4. Analyze results
5. Improve

**Visual Notes:** Chaos process diagram

**Time:** 5 minutes

---

### Slide 4.5.6: Chaos Test Example
**Content:**
- Hypothesis: System auto-recovers from node failure
- Test: Turn off a Kubernetes node
- Measure: Recovery time
- Result: Auto-recovery < 2 minutes
- Improvement: Optimize pod scheduling

**Visual Notes:** Chaos test example

**Time:** 5 minutes

---

### Slide 4.5.7: MTTD/MTTR Measurement
**Content:**
- Detection time tracking
- Response time tracking
- Trend analysis
- Improvement targets

**Visual Notes:** MTTD/MTTR dashboard

**Time:** 5 minutes

---

### Slide 4.5.8: Chaos Test Automation
**Content:**
- Python service
- Gremlin integration
- Custom experiments
- Scheduled execution
- Automated reporting

**Visual Notes:** Automation architecture

**Time:** 5 minutes

---

### Slide 4.5.9: Section 4.5 Summary
**Content:**
- Failure scenarios
- Security chaos
- Resilience validation
- MTTD/MTTR measurement
- Automated testing

**Visual Notes:** Chaos summary diagram

**Time:** 5 minutes

---

## SECTION 4.6: BUSINESS CONTINUITY
### 15 Slides | 3 Hours

---

### Slide 4.6.0: Business Continuity Introduction
**Content:**
- Planning for disruptions
- Recovery strategies
- Immutable backups
- Air-gapped vaults
- RTO/RPO validation

**Visual Notes:** BCP overview diagram

**Speaker Notes:** "Business continuity ensures you can recover from the worst."

**Time:** 5 minutes

---

### Slide 4.6.1: Recovery Tiers
**Content:**
- Tier 0: Critical (2 hours, 15 minutes)
- Tier 1: High (4 hours, 1 hour)
- Tier 2: Medium (8 hours, 4 hours)
- Tier 3: Low (24 hours, 24 hours)

**Visual Notes:** Recovery tiers table

**Time:** 5 minutes

---

### Slide 4.6.2: Recovery Strategies
**Content:**
- Active-Active: Multiple live sites
- Active-Passive: Primary + standby
- Air-Gapped: Offline recovery
- SaaS Provider: Provider managed

**Visual Notes:** Recovery strategies diagram

**Time:** 5 minutes

---

### Slide 4.6.3: Immutable Backups
**Content:**
- WORM protection (Write Once Read Many)
- AWS S3 Object Lock
- Azure Immutable Blob
- 30-day minimum retention
- Cannot be modified or deleted

**Visual Notes:** Immutable backup diagram

**Speaker Notes:** "Immutable backups protect against ransomware."

**Time:** 5 minutes

---

### Slide 4.6.4: AWS S3 Object Lock
**Content:**
- Governance mode
- Compliance mode
- Retention periods
- Legal hold
- Versioning

**Visual Notes:** S3 Object Lock configuration

**Time:** 5 minutes

---

### Slide 4.6.5: Azure Immutable Blob
**Content:**
- Time-based retention
- Legal hold
- Immutability policies
- Append blobs only

**Visual Notes:** Azure Immutable Blob configuration

**Time:** 5 minutes

---

### Slide 4.6.6: Air-Gapped Vaults
**Content:**
- Primary vault (Singapore)
- Secondary vault (London)
- AWS S3 Glacier Deep Archive
- Offline tape storage
- 2-person access
- 12-24 hour retrieval

**Visual Notes:** Air-gapped vault architecture

**Time:** 5 minutes

---

### Slide 4.6.7: Air-Gapped Access Procedure
**Content:**
1. Request access
2. Secondary approval
3. Retrieve backup
4. Validate integrity
5. Restore data
6. Document access

**Visual Notes:** Access procedure flow

**Time:** 5 minutes

---

### Slide 4.6.8: RTO/RPO Validation
**Content:**
- Regular DR tests
- Backup recovery tests
- Chaos tests
- Metrics collection
- Compliance reporting

**Visual Notes:** Validation framework

**Time:** 5 minutes

---

### Slide 4.6.9: BCP Testing Schedule
**Content:**
- Tabletop exercises: Quarterly
- Backup recovery tests: Monthly
- Full DR tests: Bi-annual
- Chaos tests: Monthly

**Visual Notes:** Testing schedule

**Time:** 5 minutes

---

### Slide 4.6.10: Section 4.6 Summary
**Content:**
- RTO/RPO targets
- Active-Active and Active-Passive
- Immutable backups
- Air-gapped vaults
- Regular validation

**Visual Notes:** BCP summary diagram

**Time:** 5 minutes

---

### Slide 4.6.11: Part 4 Summary
**Content:**
- SIEM/XDR: Monitoring
- Detection Engineering: Rules
- Threat Hunting: Proactive
- SOAR: Automation
- Chaos Engineering: Testing
- Business Continuity: Recovery

**Visual Notes:** Part 4 summary diagram

**Speaker Notes:** "Part 4 built the detection, response, and resilience capabilities."

**Time:** 5 minutes

---

## SECTION 5: ENTERPRISE CAPSTONE
### Part 5: 20 Slides | 2 Days

---

### Slide 5.0: Part 5 Introduction
**Content:**
- Enterprise Capstone
- Complete architecture blueprint
- 6 deliverables:
  1. Executive Summary
  2. Enterprise Topology
  3. Threat Model Package
  4. Zero Trust Blueprint
  5. Detection, Response & Resilience
  6. Implementation Roadmap

**Visual Notes:** Part 5 section overview

**Speaker Notes:** "Part 5 synthesizes everything into a complete deliverable."

**Time:** 5 minutes

---

### Slide 5.1: Capstone Challenge
**Content:**
- Nexus Global Industries
- Cloud transformation
- Active adversarial pressure
- Board mandate
- 90-day blueprint

**Visual Notes:** Capstone scenario

**Time:** 5 minutes

---

### Slide 5.2: Deliverable 1 - Executive Summary
**Content:**
- Business context
- Vision and objectives
- Architecture overview
- Investment summary
- Success criteria

**Visual Notes:** Executive summary example

**Time:** 5 minutes

---

### Slide 5.3: Deliverable 1 - Key Elements
**Content:**
- The challenge (why change is needed)
- The vision (what we're building)
- The architecture (how it works)
- The benefits (what it delivers)
- The investment (what it costs)

**Visual Notes:** Executive summary structure

**Time:** 5 minutes

---

### Slide 5.4: Deliverable 2 - Enterprise Topology
**Content:**
- Multi-zone network architecture
- Trust boundaries
- Cloud landing zones
- Cross-cloud architecture
- IAM/PAM integration

**Visual Notes:** Topology diagrams

**Time:** 5 minutes

---

### Slide 5.5: Deliverable 2 - Key Elements
**Content:**
- Zone 1: OT/Manufacturing
- Zone 2: Data & Identity
- Zone 3: Application (AWS + Azure)
- Zone 4: DMZ
- Zone 5: Internet/Customer

**Visual Notes:** Zone architecture diagram

**Time:** 5 minutes

---

### Slide 5.6: Deliverable 3 - Threat Model Package
**Content:**
- STRIDE analysis
- PASTA risk model
- Attack trees
- MITRE ATT&CK mapping
- Risk assessment

**Visual Notes:** Threat model examples

**Time:** 5 minutes

---

### Slide 5.7: Deliverable 3 - Key Elements
**Content:**
- Top threats identified
- MITRE coverage: 71.4%
- Risk assessment (10 risks)
- Control mapping
- Prioritization

**Visual Notes:** Threat model summary

**Time:** 5 minutes

---

### Slide 5.8: Deliverable 4 - Zero Trust Blueprint
**Content:**
- NIST SP 800-207 compliance
- PDP/OPA implementation
- PEP/Istio implementation
- Continuous verification
- Micro-segmentation

**Visual Notes:** Zero Trust blueprint

**Time:** 5 minutes

---

### Slide 5.9: Deliverable 4 - Key Elements
**Content:**
- Zero Trust policies
- OPA Rego examples
- Istio authorization
- Continuous verification service
- API security (OWASP Top 10)
- DevSecOps pipeline

**Visual Notes:** Blueprint details

**Time:** 5 minutes

---

### Slide 5.10: Deliverable 5 - Detection & Resilience
**Content:**
- SIEM/XDR architecture
- Detection rules (10+ Sigma)
- Threat hunting program
- SOAR playbooks
- Chaos engineering
- Business continuity

**Visual Notes:** Detection & resilience architecture

**Time:** 5 minutes

---

### Slide 5.11: Deliverable 5 - Key Elements
**Content:**
- SIEM: ELK Stack
- Detection: Sigma + MITRE
- Hunting: Methodology + playbooks
- SOAR: Automated response
- Chaos: Failure scenarios
- BCP: RTO/RPO validation

**Visual Notes:** D&R details

**Time:** 5 minutes

---

### Slide 5.12: Deliverable 6 - Implementation Roadmap
**Content:**
- 18-month plan
- 4 phases
- $27M investment
- Success metrics
- Governance

**Visual Notes:** Implementation roadmap

**Time:** 5 minutes

---

### Slide 5.13: Deliverable 6 - Key Elements
**Content:**
- Phase 1: Foundation (Months 1-6, $8.5M)
- Phase 2: Zero Trust & Cloud (Months 7-12, $9.5M)
- Phase 3: Detection & Response (Months 13-15, $5.5M)
- Phase 4: Resilience & Capstone (Months 16-18, $3.5M)

**Visual Notes:** Roadmap timeline

**Time:** 5 minutes

---

### Slide 5.14: Success Metrics
**Content:**
- Zero Trust Coverage: 100%
- MFA Coverage: 100%
- MTTD: < 60 minutes
- MTTR: < 4 hours
- RTO: < 2 hours (Tier 0)
- RPO: < 15 minutes (Tier 0)
- Compliance: Zero critical findings

**Visual Notes:** Metrics dashboard

**Time:** 5 minutes

---

### Slide 5.15: Capstone Summary
**Content:**
- Complete enterprise architecture
- Business-aligned security
- Zero Trust foundation
- Cloud-native security
- Detection and resilience

**Visual Notes:** Final architecture diagram

**Speaker Notes:** "This is the complete, defensible enterprise security architecture."

**Time:** 5 minutes

---

## SERIES CONCLUSION
### 5 Slides | 30 Minutes

---

### Slide C.1: What You've Built
**Content:**
- 5 parts
- 45 sections
- 129+ artifacts
- 4 frameworks
- 14 security domains

**Visual Notes:** Summary diagram

**Time:** 5 minutes

---

### Slide C.2: The Complete Architecture
**Content:**
- Governance & Risk
- Zero Trust & Identity
- Cloud-Native Security
- Detection, Response & Resilience

**Visual Notes:** Full 4-layer architecture diagram

**Time:** 5 minutes

---

### Slide C.3: Key Takeaways
**Content:**
1. Security is a business enabler
2. Zero Trust is the foundation
3. Cloud-native requires new thinking
4. Detection is critical
5. Resilience is non-negotiable
6. Automation is essential
7. Compliance is a byproduct
8. People matter most

**Visual Notes:** Key takeaways

**Time:** 5 minutes

---

### Slide C.4: Next Steps
**Content:**
1. Review the architecture
2. Adapt to your organization
3. Build the foundation
4. Implement phase by phase
5. Measure and improve
6. Stay current

**Visual Notes:** Next steps

**Time:** 5 minutes

---

### Slide C.5: Thank You
**Content:**
- Questions and discussion
- Thank you for attending

**Visual Notes:** Thank you slide

**Time:** 10 minutes

---

## APPENDICES
### 20 Slides | As Needed

---

### Appendix A: Complete Artifact Index
**Content:**
- All 129+ files listed
- By part and section
- File descriptions

**Visual Notes:** File index

**Time:** Reference only

---

### Appendix B: Framework Quick Reference
**Content:**
- SABSA 6 layers
- NIST CSF 6 functions
- ISO 27001 Annex A
- MITRE ATT&CK 14 tactics

**Visual Notes:** Quick reference cards

**Time:** Reference only

---

### Appendix C: Deployment Commands
**Content:**
- Kubernetes deployments
- Terraform commands
- Security tool setup

**Visual Notes:** Command reference

**Time:** Reference only

---

### Appendix D: Troubleshooting Guide
**Content:**
- Common issues
- Quick fixes
- Diagnostic commands

**Visual Notes:** Troubleshooting flowcharts

**Time:** Reference only

---

## Total Statistics

| Section | Slides | Estimated Time |
|---------|--------|----------------|
| Introduction | 10 | 1 hour |
| Part 1 | 60 | 3 days |
| Part 2 | 60 | 3 days |
| Part 3 | 70 | 3.5 days |
| Part 4 | 80 | 4 days |
| Part 5 | 20 | 2 days |
| Conclusion | 5 | 0.5 hours |
| Appendices | 20 | Reference |
| **Total** | **~325** | **12-15 days** |

---

**[END OF SLIDE DECK OUTLINE]**

---

## Teaching Tips

### Daily Structure
- Morning: Theory and concepts (1-2 hours)
- Mid-day: Hands-on implementation (2-3 hours)
- Afternoon: Review and Q&A (1 hour)

### Recommended Delivery
- **Day 1-3**: Part 1 (Foundations & Frameworks)
- **Day 4-6**: Part 2 (Zero Trust & Identity)
- **Day 7-10**: Part 3 (Cloud-Native Security)
- **Day 11-14**: Part 4 (Detection & Resilience)
- **Day 15**: Part 5 (Capstone & Defense)

### Interactive Elements
- Live demos of each component
- Hands-on labs for each section
- Group discussions for threat modeling
- Capstone presentation at end

### Materials to Provide
- Slide deck (this outline)
- Lab guide with step-by-step instructions
- Code repository with all artifacts
- Architecture diagrams
- Reference guides
