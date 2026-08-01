# Enterprise Cybersecurity Program: Complete Student Notes

## Comprehensive Reference Notes for the Enterprise Cybersecurity Program

---

# PART 0: INTRODUCTION

## 0.1: Program Overview

### Key Takeaways

- Cybersecurity is a business risk, not just an IT issue
- A comprehensive program requires governance, protection, detection, response, and recovery
- The program follows NIST CSF 2.0 and ISO 27001 frameworks
- Security must align with business objectives

### Critical Concepts

**Why Cybersecurity Programs Fail:**
1. Lack of executive support
2. No clear governance
3. Insufficient resources
4. Poor risk management
5. Weak security culture

**Success Factors:**
1. Executive sponsorship
2. Risk-based approach
3. Clear governance
4. Continuous improvement
5. Security culture

### Notes

```
[Your Notes Here]
```

---

## 0.2: The Architecture

### Architecture Layers

**1. Governance Layer**
- Executive leadership
- Risk management
- Policy framework
- Compliance

**2. Identify & Protect Layer**
- Asset management
- Identity management
- Access control
- Security controls
- Data protection

**3. Detect & Respond Layer**
- Security monitoring
- Incident response
- Business continuity
- Disaster recovery

**4. Supply Chain Layer**
- Vendor risk management
- Third-party security
- SBOM management

**5. Culture & Improvement Layer**
- Security awareness
- Training
- Metrics
- Continuous improvement

### Notes

```
[Your Notes Here]
```

---

## 0.3: Key Frameworks

### NIST CSF 2.0

| Function | Description |
|----------|-------------|
| GOVERN | Leadership and strategy |
| IDENTIFY | Know your assets and risks |
| PROTECT | Implement security controls |
| DETECT | Monitor for threats |
| RESPOND | Handle incidents |
| RECOVER | Restore operations |

### ISO 27001:2022

- International standard for Information Security Management Systems (ISMS)
- 93 controls across 4 themes: Organizational, People, Physical, Technological
- Requires continuous improvement

### CIS Controls v8

- 18 prioritized controls
- Organized by implementation group (IG1, IG2, IG3)
- Focus on practical, actionable security measures

### Zero Trust Architecture (NIST SP 800-207)

- "Never trust, always verify"
- Continuous verification
- Least privilege
- Assume breach
- Micro-segmentation

### Notes

```
[Your Notes Here]
```

---

# PART 1: GOVERNANCE, LEADERSHIP & CYBER RISK STRATEGY

## 1.1: Why Governance First

### Key Takeaways

- Governance is the foundation of cybersecurity
- Security is a business risk, not just an IT issue
- Without governance, controls are disconnected and ineffective

### Governance Answers Three Questions

1. **Who decides?** Decision-making authority
2. **What do we protect?** Risk appetite and priorities
3. **How do we know we're successful?** Measurement and accountability

### The Cost of Poor Governance

- Unclear accountability → Security gaps
- No risk framework → Poor prioritization
- No policies → Inconsistent enforcement
- No strategy → Reactive approach
- No measurement → No improvement

### Notes

```
[Your Notes Here]
```

---

## 1.2: Executive Sponsorship & Governance

### Governance Structure

```
Board of Directors
  └── Board Cybersecurity Committee
        └── Executive Cybersecurity Council
              └── Cybersecurity Operational Committee
                    └── Regional Security Committees
```

### Roles and Responsibilities

**Board Cybersecurity Committee:**
- Approve cybersecurity strategy and budget
- Oversee risk posture
- Review key risk indicators
- Approve major investments
- Ensure executive accountability

**Executive Cybersecurity Council:**
- Set strategic direction
- Allocate resources
- Make key risk decisions
- Oversee program execution
- Review and approve policies

**Cybersecurity Operational Committee:**
- Operationalize strategic decisions
- Manage security projects
- Coordinate across regions
- Monitor operations and metrics

**Regional Security Committees:**
- Address regional regulations
- Adapt global policies locally
- Manage regional risk
- Coordinate with local authorities

### Notes

```
[Your Notes Here]
```

---

## 1.3: RACI & Organizational Responsibilities

### The RACI Model

**R = Responsible** (who does the work)
**A = Accountable** (who ensures it gets done)
**C = Consulted** (who provides input)
**I = Informed** (who needs to know)

### RACI Examples

| Activity | CISO | CIO | CRO | BU Head |
|----------|------|-----|-----|---------|
| Security Strategy | R | C | C | C |
| Risk Management | R | C | A | C |
| Policy Approval | R | C | C | C |
| Incident Response | R | C | - | C |

### Escalation Paths

```
Level 1: SOC Analyst → (30 min)
Level 2: IR Lead → (2 hours)
Level 3: CISO → (1 hour)
Level 4: Executive Council → (4 hours)
Level 5: Board Committee
```

### Notes

```
[Your Notes Here]
```

---

## 1.4: Risk Management Framework

### Risk Calculation

```
Risk = Likelihood × Impact × Velocity

Likelihood: 1-5 (probability)
Impact: 1-5 (consequence)
Velocity: 1-5 (speed)
Risk Score: 1-125
```

### Risk Levels

| Score | Level | Required Action |
|-------|-------|-----------------|
| 1-8 | Low | Accept/monitor |
| 9-18 | Medium | Mitigate within 90 days |
| 19-36 | High | Mitigate within 30 days |
| 37-125 | Critical | Immediate mitigation |

### Risk Treatment Options

1. **Accept:** Do nothing (within appetite)
2. **Mitigate:** Implement controls
3. **Transfer:** Insurance, vendor agreements
4. **Avoid:** Stop the activity

### Risk Register

| Field | Description |
|-------|-------------|
| Risk ID | Unique identifier |
| Owner | Person accountable |
| Description | Clear risk statement |
| Category | Risk type |
| Score | Calculated risk score |
| Level | Critical/High/Medium/Low |
| Controls | Existing controls |
| Action Plan | Mitigation steps |

### Notes

```
[Your Notes Here]
```

---

## 1.5: Security Policies

### Policy Hierarchy

```
Strategic: Information Security Policy (the "why")
Tactical: Domain Policies (the "what")
Operational: Procedures and Guidelines (the "how")
```

### Core Policies

1. Information Security Policy
2. Access Control Policy
3. Acceptable Use Policy
4. Data Classification Policy
5. Incident Response Policy
6. BCP/DR Policy
7. Third-Party Security Policy
8. Security Awareness Policy

### Policy Structure

1. Purpose
2. Scope
3. Policy Statements
4. Roles and Responsibilities
5. Compliance and Enforcement
6. Review Cycle
7. Framework Mapping

### Notes

```
[Your Notes Here]
```

---

## 1.6: Cyber Risk Strategy

### 3-Year Strategy

**Year 1: Foundation**
- Governance and strategy
- Asset discovery
- Identity and access
- Foundational controls

**Year 2: Operational Excellence**
- Detection and response
- BCP/DR
- Cloud security
- Third-party security

**Year 3: Program Maturity**
- Security culture
- Automation and AI
- Maturity assessment
- Continuous improvement

### Success Metrics

| Metric | Year 1 | Year 2 | Year 3 |
|--------|--------|--------|--------|
| Maturity Level | 2 | 3 | 4 |
| Risk Score | 25 | 18 | 12 |
| MFA Adoption | 90% | 95% | 98% |
| Incident MTTR | 24 hrs | 8 hrs | 4 hrs |

### Notes

```
[Your Notes Here]
```

---

# PART 2: DISCOVER, CLASSIFY & PROTECT ENTERPRISE ASSETS

## 2.1: Why Asset Discovery Matters

### Key Takeaways

- You cannot protect what you don't know exists
- Asset visibility is the foundation of security
- Unknown assets = unknown risks

### The Visibility Problem

- Shadow IT (unauthorized cloud services)
- Unmanaged devices (BYOD, IoT)
- Legacy systems (forgotten servers)
- Data sprawl (where is your data?)
- Cloud complexity (multi-cloud environments)

### Asset Categories

- Hardware (servers, network devices, endpoints)
- Software (OS, applications, databases)
- Data (structured, unstructured, IP)
- Cloud (instances, storage, services)
- Network (segments, IP ranges, connections)

### Notes

```
[Your Notes Here]
```

---

## 2.2: Asset Discovery

### Discovery Methods

1. **Automated Discovery**
   - Network scanning (nmap, Nessus)
   - Cloud APIs (AWS, Azure, GCP)
   - Agent-based discovery

2. **Manual Discovery**
   - Inventory audits
   - User surveys
   - Process reviews

3. **Continuous Discovery**
   - Real-time monitoring
   - Change detection
   - Automated reconciliation

### Discovery Workflow

1. Define Scope
2. Select Tools
3. Execute Discovery
4. Validate Results
5. Reconcile
6. Document in CMDB

### Key Discovery Questions

- What is it? (Asset type and purpose)
- Where is it? (Location and environment)
- Who owns it? (Business owner)
- What data does it contain? (Data sensitivity)
- What does it connect to? (Dependencies)

### Notes

```
[Your Notes Here]
```

---

## 2.3: CMDB

### What is a CMDB?

A Configuration Management Database is a repository that stores information about IT assets and their relationships.

### Why You Need a CMDB

- **Visibility:** Know what you have
- **Relationships:** Understand dependencies
- **Impact Analysis:** Assess changes
- **Change Management:** Track changes
- **Asset Lifecycle:** Manage from acquisition to retirement

### CMDB Components

- **Configuration Items (CIs):** Individual assets
- **CI Attributes:** Asset properties
- **Relationships:** How assets connect
- **Version History:** Change tracking

### CMDB Building Process

1. Define CI Types
2. Define Attributes
3. Populate Data
4. Define Relationships
5. Maintain and Update

### Notes

```
[Your Notes Here]
```

---

## 2.4: Data Classification

### Classification Levels

| Level | Name | Examples | Protection |
|-------|------|----------|------------|
| 1 | Public | Marketing, press releases | Availability |
| 2 | Internal | Policies, internal comms | Access controls, encryption in transit |
| 3 | Confidential | Customer data, financial projections | RBAC, encryption at rest and in transit |
| 4 | Highly Confidential | PII, PHI, IP | Strict access, AES-256 encryption |
| 5 | Critical | Encryption keys, credentials | HSM, air-gapped storage, MFA |

### Classification Decision Tree

```
Is the data publicly available?
  ├── YES → Level 1 (Public)
  └── NO → Contains personal information?
      ├── YES → Contains PII/PHI?
      │   ├── YES → Level 4 (Highly Confidential)
      │   └── NO → Level 3 (Confidential)
      └── NO → Contains business-sensitive info?
          ├── YES → Contains IP/trade secrets?
          │   ├── YES → Level 4 (Highly Confidential)
          │   └── NO → Level 3 (Confidential)
          └── NO → Level 2 (Internal)
```

### Data Classification Process

1. Identify data (where is your data?)
2. Analyze content (what is the data?)
3. Apply criteria (what is the sensitivity?)
4. Assign classification (what level?)
5. Apply labels (mark the data)
6. Implement controls (protect the data)
7. Review and update (annual review)

### Notes

```
[Your Notes Here]
```

---

## 2.5: Regulatory Mapping

### Key Regulations

| Regulation | Jurisdiction | Focus |
|------------|--------------|-------|
| GDPR | EU | Data protection |
| CCPA/CPRA | California | Privacy rights |
| HIPAA | US | Healthcare data |
| PCI DSS | Global | Payment card data |
| PDPA | Singapore | Personal data |

### GDPR Key Requirements

- Lawful processing (Article 6)
- Data subject rights (Articles 12-22)
- Security of processing (Article 32)
- Breach notification (Article 33)
- Data Protection Impact Assessment (Article 35)

### CCPA Key Requirements

- Right to know (1798.100)
- Right to delete (1798.105)
- Right to opt-out (1798.110)
- Right to correct (1798.106)
- Right to non-discrimination (1798.130)

### Notes

```
[Your Notes Here]
```

---

## 2.6: Zero Trust Architecture

### Zero Trust Principles

1. **Never Trust, Always Verify:** Verify every access request
2. **Least Privilege:** Minimum required access
3. **Assume Breach:** Design as if already compromised
4. **Micro-segmentation:** Granular network segmentation
5. **Continuous Monitoring:** Real-time visibility

### Zero Trust Components

- **Identity & Access:** MFA, SSO, PAM, IGA
- **Device Security:** EDR/XDR, MDM, compliance
- **Network Security:** Micro-segmentation, ZTNA, monitoring
- **Data Protection:** Classification, encryption, DLP

### ZTNA vs VPN

| VPN | ZTNA |
|-----|------|
| Full network access | Application-level access |
| Implicit trust | Continuous verification |
| Limited visibility | Full visibility |
| Broad attack surface | Reduced attack surface |

### Zero Trust Implementation Phases

1. Identity Foundation (Months 1-3)
2. Device Security (Months 3-6)
3. Network Segmentation (Months 6-9)
4. Data Protection (Months 9-12)

### Notes

```
[Your Notes Here]
```

---

# PART 3: IMPLEMENT FOUNDATIONAL SECURITY CONTROLS

## 3.1: Control Overview

### Control Categories

- **Preventive:** Stop the threat
- **Detective:** Find the threat
- **Corrective:** Fix the problem
- **Deterrent:** Discourage the threat

### Control Priority

1. **Identity & Access:** Most common attack vector
2. **Endpoint Security:** Critical for protection
3. **Network Security:** Prevent lateral movement
4. **Data Protection:** Protect what matters most
5. **Security Operations:** Detect and respond

### Key Controls

| Control | Purpose | Priority |
|---------|---------|----------|
| MFA | Prevent credential theft | 1 |
| PAM | Secure privileged access | 1 |
| EDR | Protect endpoints | 2 |
| Encryption | Protect data | 3 |
| SIEM | Monitor and alert | 4 |

### Notes

```
[Your Notes Here]
```

---

## 3.2: Identity and Access Management

### IAM Components

1. **Identity Management:** User lifecycle, role management, identity governance
2. **Authentication:** MFA, password policies, SSO
3. **Authorization:** RBAC, least privilege, access reviews
4. **Privileged Access:** PAM, just-in-time access, session recording

### MFA Implementation

1. Select MFA solution
2. Define MFA policies
3. Enroll users
4. Enforce MFA
5. Monitor adoption

### PAM Requirements

- Credential vaulting
- Credential rotation (90 days)
- Just-in-time access
- Session recording

### Access Reviews

| Type | Frequency |
|------|-----------|
| User Access | Quarterly |
| Privileged Access | Monthly |
| Application Access | Quarterly |
| Vendor Access | Monthly |

### Notes

```
[Your Notes Here]
```

---

## 3.3: Endpoint Security

### Endpoint Security Components

1. **EDR/XDR:** Real-time monitoring, threat detection, automated response
2. **Antivirus:** Signature-based detection, behavioral analysis
3. **Endpoint Hardening:** Secure configurations, patch management
4. **MDM:** Device enrollment, policy enforcement, remote wipe

### EDR Implementation

1. Select EDR solution
2. Define policies
3. Deploy agents
4. Configure monitoring
5. Train team

### Endpoint Hardening

- Secure configurations
- Patch management
- Application control
- Firewall
- Encryption

### Patch Management Process

1. Identify (monitor vendor updates)
2. Assess (evaluate urgency)
3. Test (validate in test environment)
4. Deploy (phased rollout)
5. Verify (validate installation)

### Notes

```
[Your Notes Here]
```

---

## 3.4: Network Security

### Network Security Components

1. **Segmentation:** Network segmentation, micro-segmentation, VLANs
2. **Firewalls:** Perimeter, internal, cloud, NGFW
3. **ZTNA:** Application-level access, continuous verification
4. **Monitoring:** Traffic analysis, anomaly detection, IDS/IPS

### Segmentation Levels

1. Basic: DMZ, internal, management
2. Functional: HR, finance, engineering
3. Application: Web, app, database tiers
4. Workload: Individual servers/services

### Firewall Principles

- Default Deny
- Least Privilege
- Defense in Depth
- Regular Review

### Cloud Security Components

- CSPM (Cloud Security Posture Management)
- Cloud IAM
- Cloud monitoring
- Cloud compliance

### Notes

```
[Your Notes Here]
```

---

## 3.5: Data Protection

### Data Protection Components

1. **Encryption:** At rest (AES-256), in transit (TLS 1.3), in use (Tokenization/FHE)
2. **DLP:** Data discovery, policy enforcement, monitoring
3. **Backup:** Regular backups, immutable backups, recovery testing
4. **Lifecycle:** Creation, usage, retention, destruction

### Encryption Strategy

| Data State | Standard |
|------------|----------|
| At Rest | AES-256 |
| In Transit | TLS 1.3 |
| In Use | Tokenization/FHE |

### DLP Implementation

1. Identify sensitive data
2. Define policies
3. Deploy DLP tools
4. Configure alerts
5. Remediate
6. Review and tune

### Immutable Backups

- Definition: Backups that cannot be modified
- Why: Protect against ransomware
- How: WORM storage, access controls
- Retention: Minimum 30 days

### Notes

```
[Your Notes Here]
```

---

# PART 4: DETECTION, INCIDENT RESPONSE & CYBER RESILIENCE

## 4.1: Detection & Response Overview

### The Detection & Response Lifecycle

1. **Detect:** Find the threat
2. **Triage:** Assess severity
3. **Contain:** Stop the spread
4. **Eradicate:** Remove the threat
5. **Recover:** Restore operations
6. **Learn:** Improve

### Key Metrics

| Metric | Target |
|--------|--------|
| MTTD (Mean Time to Detect) | <2 hours |
| MTTR (Mean Time to Respond) | <4 hours |
| Containment Time | <1 hour |
| Recovery Time | <24 hours |

### Notes

```
[Your Notes Here]
```

---

## 4.2: SIEM

### What is SIEM?

Security Information and Event Management provides centralized logging, correlation, and alerting.

### SIEM Components

- **Log Collection:** Agents, APIs, Syslog
- **Normalization:** Standardize log formats
- **Correlation:** Identify patterns and threats
- **Alerting:** Notify on suspicious activity
- **Dashboards:** Visualize data
- **Reporting:** Generate reports

### Critical Log Sources

- Firewalls
- Servers (OS logs)
- Cloud services
- Applications
- Databases
- Endpoints (EDR)
- Identity (IAM)

### Correlation Rules

| Rule | Condition | Severity |
|------|-----------|----------|
| Multiple Failed Logins | >5 attempts in 5 minutes | Medium |
| Privilege Escalation | Privilege changes | High |
| Malware Detection | Malware alert | Critical |
| Data Exfiltration | >10GB outbound | Critical |

### Notes

```
[Your Notes Here]
```

---

## 4.3: SOC

### SOC Structure

```
SOC Manager
  └── Shift Supervisors
        ├── Tier 1 Analysts (triage)
        ├── Tier 2 Analysts (investigation)
        ├── Tier 3 Analysts (advanced)
        └── Threat Hunters (proactive)
```

### SOC Tiers

| Tier | Responsibility |
|------|----------------|
| Tier 1 | Alert triage, initial investigation |
| Tier 2 | Deep investigation, analysis |
| Tier 3 | Advanced investigation, threat hunting |

### Shift Schedule

| Shift | Time | Team Size |
|-------|------|-----------|
| Day | 6 AM - 2 PM | 8-10 |
| Afternoon | 2 PM - 10 PM | 6-8 |
| Night | 10 PM - 6 AM | 4-6 |

### Threat Hunting

- Proactive searching for threats
- Hypothesis-driven
- Data-driven
- Intelligence-driven

### Notes

```
[Your Notes Here]
```

---

## 4.4: Incident Response

### Incident Response Process

1. **Detection:** Identify incident
2. **Triage:** Assess severity, determine impact
3. **Investigation:** Gather evidence, analyze root cause
4. **Containment:** Isolate systems, block activity
5. **Eradication:** Remove threat, patch vulnerabilities
6. **Recovery:** Restore systems, validate functionality
7. **Lessons Learned:** Review, document, improve

### Severity Levels

| Severity | Response Time | Escalation |
|----------|---------------|------------|
| Critical | Immediate | CISO/Executive |
| High | <15 minutes | Security Manager |
| Medium | <1 hour | SOC Lead |
| Low | <4 hours | SOC Analyst |

### IR Playbook Types

- Malware/Ransomware
- Phishing
- Data Breach
- Insider Threat
- DDoS

### Tabletop Exercises

- Frequency: Quarterly
- Participants: Leadership, IR team, stakeholders
- Purpose: Practice incident response

### Notes

```
[Your Notes Here]
```

---

## 4.5: Business Continuity & Resilience

### BCP/DR Components

1. **Business Impact Analysis (BIA):** Identify critical functions, assess impact
2. **Recovery Strategies:** Alternate processes, backup facilities
3. **Plan Development:** Document procedures, assign responsibilities
4. **Testing:** Tabletop exercises, technical tests, full exercises

### RTO and RPO

| Term | Description |
|------|-------------|
| RTO (Recovery Time Objective) | Time to recover |
| RPO (Recovery Point Objective) | Data loss tolerance |

### Recovery Strategies

- **Active-Active:** Live systems in multiple locations
- **Active-Standby:** Standby systems ready
- **Cold Backup:** Systems provisioned when needed
- **Cloud Recovery:** Recovery in cloud

### Immutable Backups

- Cannot be modified or deleted
- Protect against ransomware
- WORM storage
- Minimum 30 days retention

### Notes

```
[Your Notes Here]
```

---

# PART 5: SUPPLY CHAIN & THIRD-PARTY CYBER RISK MANAGEMENT

## 5.1: Supply Chain Security Overview

### Key Takeaways

- 60%+ of breaches involve third parties
- 50%+ of organizations have experienced a supply chain attack
- 80%+ of software uses open-source components

### Supply Chain Risks

- Vendor breaches
- Software vulnerabilities
- Supply chain attacks
- Regulatory violations
- Reputation damage

### Notes

```
[Your Notes Here]
```

---

## 5.2: Vendor Risk Management

### Vendor Risk Categories

| Category | Description | Assessment Frequency |
|----------|-------------|---------------------|
| Critical | Essential to business | Quarterly |
| High | Significant access | Bi-annually |
| Medium | Moderate access | Annually |
| Low | Minimal access | Annually |

### Vendor Risk Management Process

1. **Identify:** Create vendor inventory, classify criticality
2. **Assess:** Security questionnaire, review certifications
3. **Mitigate:** Define requirements, contractual clauses
4. **Monitor:** Continuous monitoring, regular reviews
5. **Review:** Annual review, update risk scores

### Risk Scoring

| Factor | Weight |
|--------|--------|
| Data Sensitivity | 30% |
| Access Level | 25% |
| Criticality | 25% |
| Security Score | 20% |

### Risk Levels

| Score | Category | Action |
|-------|----------|--------|
| 80-100 | Critical | Immediate remediation |
| 60-79 | High | Mitigation plan required |
| 40-59 | Medium | Enhanced monitoring |
| 0-39 | Low | Standard monitoring |

### Notes

```
[Your Notes Here]
```

---

## 5.3: Software Supply Chain Security

### What is SBOM?

A Software Bill of Materials is a list of all components, libraries, and dependencies used in software.

### Why SBOM Matters

- Identify vulnerable components
- Track dependencies
- Respond to vulnerabilities (Log4j)
- Maintain compliance

### SBOM Formats

- SPDX (Software Package Data Exchange)
- CycloneDX
- SWID (Software Identification)

### SBOM Implementation

1. Generate SBOM at build time
2. Validate SBOM completeness
3. Scan for vulnerabilities
4. Remediate issues
5. Update SBOM
6. Maintain inventory

### Open-Source Governance

- Open-source policy
- Approved licenses
- Security scanning
- Component tracking

### Notes

```
[Your Notes Here]
```

---

## 5.4: Third-Party Security

### Third-Party Access Requirements

- MFA for all third-party access
- Least privilege access
- Just-in-time access
- Access reviews
- Session recording

### Contractual Requirements

- Security policy compliance
- Data protection requirements
- Incident response (24-hour notification)
- Access control (MFA, least privilege)
- Audit rights
- Data destruction

### Monitoring Activities

- Security ratings
- Breach monitoring
- Access reviews
- Compliance checks

### Security SLAs

| Metric | Requirement |
|--------|-------------|
| Uptime | 99.9%+ |
| Incident Response | <24 hours |
| Security Patch | <15 days |
| Vulnerability Remediation | 30 days |

### Notes

```
[Your Notes Here]
```

---

# PART 6: DEVELOP A SECURITY-FIRST CULTURE & CONTINUOUS IMPROVEMENT

## 6.1: Security Culture Overview

### Key Takeaways

- 95% of breaches involve human error
- 80% of organizations have experienced incidents due to employee behavior
- Security culture is the #1 predictor of program success

### Security Culture Maturity

1. **Compliance-Driven:** Follow rules because you have to
2. **Awareness-Driven:** Know about security risks
3. **Behavior-Driven:** Consistently practice secure behaviors
4. **Culture-Driven:** Security is part of the organizational DNA
5. **Resilient Culture:** Continuously improved and adapted

### Notes

```
[Your Notes Here]
```

---

## 6.2: Security Culture

### Elements of Security Culture

1. **Leadership Commitment:** Executives model security behavior
2. **Shared Responsibility:** Everyone owns security
3. **Trust and Transparency:** Blameless reporting, open communication
4. **Continuous Learning:** Regular training, knowledge sharing
5. **Positive Reinforcement:** Recognizing good behavior

### Building Security Culture

1. Start at the top
2. Communicate regularly
3. Make it personal
4. Celebrate success
5. Learn from mistakes
6. Make it easy
7. Measure and improve

### Security Champions

- Definition: Security advocates in business units
- Benefits: Amplify security messages, provide local expertise
- Activities: Monthly meetings, team education, awareness promotion

### Notes

```
[Your Notes Here]
```

---

## 6.3: Security Awareness

### Training Programs

| Training Type | Frequency | Audience |
|---------------|-----------|----------|
| New Hire | Upon hire | All new employees |
| Annual | Annually | All employees |
| Role-Based | Quarterly | Targeted groups |

### Phishing Simulations

- **Frequency:** Monthly
- **Target:** All employees
- **Metrics:** Click rate (<5%), Report rate (>10%)

### Response Protocol

- **Clicked:** Provide immediate training
- **Reported:** Positive reinforcement
- **Repeated:** Additional training

### Awareness Campaigns

- Monthly themes
- Email newsletters
- Intranet posts
- Slack/Teams tips
- Town halls

### Notes

```
[Your Notes Here]
```

---

## 6.4: Metrics and KPIs

### Key KPIs

| KPI | Target |
|-----|--------|
| MFA Adoption | 95%+ |
| Patch Compliance | 95%+ |
| Training Completion | 100% |
| Phishing Click Rate | <5% |
| Incident MTTR | <4 hours |
| Vulnerability Remediation | 95%+ |

### Key KRIs

| KRI | Threshold |
|-----|-----------|
| Open Critical Vulnerabilities | <5 |
| Security Incidents | <5/month |
| Compliance Findings | <10 |
| Vendor Risk Score | <40 |
| Unpatched Systems | <10% |

### Dashboard Sections

- Program Health (maturity, risk)
- Performance (MTTD, MTTR)
- Control Status (MFA, patching)
- Risk (open risks, vulnerabilities)

### Notes

```
[Your Notes Here]
```

---

## 6.5: Continuous Improvement

### The PDCA Cycle

1. **Plan:** Identify improvements, define goals, develop action plan
2. **Do:** Execute action plan, implement changes
3. **Check:** Monitor results, measure against targets
4. **Act:** Standardize successes, plan for next cycle

### Maturity Assessment

- **C2M2 Levels:** None, Initial, Repeatable, Defined, Managed, Optimizing
- **Domains:** Governance, Risk, IAM, Architecture, Threat Management, Incident Management, Operations, Supply Chain, BCP, Training

### Improvement Process

1. Identify improvement opportunities
2. Define goals
3. Develop action plan
4. Execute plan
5. Measure results
6. Standardize success

### Notes

```
[Your Notes Here]
```

---

# QUICK REFERENCE CARDS

## Card 1: Key Frameworks

| Framework | Purpose |
|-----------|---------|
| NIST CSF 2.0 | Cybersecurity risk management |
| ISO 27001 | Security management |
| CIS Controls | Prioritized security actions |
| Zero Trust | "Never trust, always verify" |

## Card 2: Key Controls

| Control | Purpose | Priority |
|---------|---------|----------|
| MFA | Prevent credential theft | 1 |
| PAM | Secure privileged access | 1 |
| EDR | Protect endpoints | 2 |
| Encryption | Protect data | 3 |
| SIEM | Monitor and alert | 4 |

## Card 3: Key Metrics

| Metric | Target |
|--------|--------|
| MFA Adoption | 95%+ |
| Phishing Click Rate | <5% |
| Training Completion | 100% |
| MTTD | <2 hours |
| MTTR | <4 hours |
| Patch Compliance | 95%+ |

## Card 4: Key Regulations

| Regulation | Jurisdiction |
|------------|--------------|
| GDPR | EU |
| CCPA/CPRA | California |
| HIPAA | US |
| PCI DSS | Global |

## Card 5: Key Roles

| Role | Responsibility |
|------|----------------|
| CISO | Security leadership |
| Security Architect | Security design |
| Security Engineer | Security implementation |
| Security Analyst | Security operations |
| SOC Analyst | Security monitoring |
| Incident Responder | Incident handling |

## Card 6: Incident Response

| Phase | Actions |
|-------|---------|
| Detect | Identify incident |
| Triage | Assess severity |
| Contain | Isolate systems |
| Eradicate | Remove threat |
| Recover | Restore operations |
| Learn | Improve |

## Card 7: Implementation Checklist

- [ ] Secure executive sponsorship
- [ ] Define risk appetite
- [ ] Create security policies
- [ ] Discover your assets
- [ ] Classify your data
- [ ] Enable MFA
- [ ] Deploy EDR
- [ ] Implement encryption
- [ ] Deploy SIEM
- [ ] Develop IR playbooks
- [ ] Implement BCP/DR
- [ ] Assess vendors
- [ ] Launch awareness program
- [ ] Define KPIs/KRIs
- [ ] Conduct maturity assessment

---

*End of Student Notes*
