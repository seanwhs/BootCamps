# Appendix J: Complete Glossary & Terminology Reference
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Security Terminology Guide

## Overview

This appendix provides a comprehensive glossary of all security terms, acronyms, and concepts referenced throughout the series. Use this as a reference for team training, documentation, and communication.

---

## 1. Architecture & Frameworks

### SABSA

| Term | Definition |
|------|------------|
| **SABSA** | Sherwood Applied Business Security Architecture - A business-driven security architecture methodology |
| **Contextual Layer** | SABSA Layer 1: Defines the business requirements and environment |
| **Conceptual Layer** | SABSA Layer 2: Defines the security strategy and service framework |
| **Logical Layer** | SABSA Layer 3: Defines the security services and mechanisms |
| **Physical Layer** | SABSA Layer 4: Defines the technology and implementation |
| **Component Layer** | SABSA Layer 5: Defines the components and specifications |
| **Operational Layer** | SABSA Layer 6: Defines the operational procedures |
| **Traceability Matrix** | Maps business attributes to security controls across layers |

### NIST CSF

| Term | Definition |
|------|------------|
| **CSF** | Cybersecurity Framework - NIST's framework for managing cybersecurity risk |
| **Govern Function** | CSF 2.0 function establishing cybersecurity strategy and oversight |
| **Identify Function** | CSF function understanding assets, risks, and capabilities |
| **Protect Function** | CSF function implementing safeguards |
| **Detect Function** | CSF function identifying cybersecurity events |
| **Respond Function** | CSF function taking action on detected incidents |
| **Recover Function** | CSF function restoring capabilities after incidents |

### ISO 27001

| Term | Definition |
|------|------------|
| **ISMS** | Information Security Management System - Systematic approach to managing information security |
| **Annex A** | ISO 27001 control objectives and controls (78 controls) |
| **SoA** | Statement of Applicability - Document listing which Annex A controls apply |
| **Risk Treatment** | Actions taken to reduce, accept, avoid, or transfer risk |
| **PDCA** | Plan-Do-Check-Act - Continuous improvement cycle |

### MITRE ATT&CK

| Term | Definition |
|------|------------|
| **ATT&CK** | Adversarial Tactics, Techniques, and Common Knowledge - MITRE's knowledge base of adversary behavior |
| **Tactic** | The "why" of an attack - the adversary's goal |
| **Technique** | The "how" of an attack - how the adversary achieves the goal |
| **TTP** | Tactics, Techniques, and Procedures - Adversary behavior patterns |
| **MITRE ID** | Unique identifier for each technique (e.g., T1003) |

---

## 2. Zero Trust & Identity

### Zero Trust

| Term | Definition |
|------|------------|
| **Zero Trust** | Security model that eliminates implicit trust and continuously verifies every access request |
| **PDP** | Policy Decision Point - Component that makes access decisions |
| **PEP** | Policy Enforcement Point - Component that enforces access decisions |
| **PAP** | Policy Administration Point - Component that manages policies |
| **PIP** | Policy Information Point - Component that provides context for decisions |
| **Continuous Verification** | Ongoing validation of sessions and access |
| **Assume Breach** | Operating assumption that attackers are already inside |
| **Micro-segmentation** | Fine-grained network isolation at the workload level |
| **SDP** | Software-Defined Perimeter - "Black cloud" approach hiding infrastructure |

### Identity & Access

| Term | Definition |
|------|------------|
| **IAM** | Identity and Access Management - Managing user identities and access |
| **OAuth 2.1** | Authorization framework for delegated access |
| **OIDC** | OpenID Connect - Authentication layer on top of OAuth 2.0 |
| **SAML** | Security Assertion Markup Language - XML-based authentication protocol |
| **SCIM** | System for Cross-domain Identity Management - Automated identity provisioning |
| **JML** | Joiner-Mover-Leaver - Identity lifecycle events |
| **MFA** | Multi-Factor Authentication - Authentication using multiple factors |
| **WebAuthn** | Web Authentication - FIDO Alliance's standard for passwordless authentication |
| **TOTP** | Time-based One-Time Password - Authenticator app codes |
| **RBAC** | Role-Based Access Control - Access based on user roles |
| **ABAC** | Attribute-Based Access Control - Access based on user attributes |
| **JIT** | Just-In-Time - Temporary privileged access |
| **JEA** | Just Enough Administration - Minimal privileged access |
| **PAM** | Privileged Access Management - Managing privileged accounts |

---

## 3. Cloud Security

### Cloud Architecture

| Term | Definition |
|------|------------|
| **IaC** | Infrastructure as Code - Managing infrastructure through code |
| **CSPM** | Cloud Security Posture Management - Continuous cloud compliance monitoring |
| **CIS Benchmark** | Center for Internet Security benchmark - Best practices for cloud security |
| **Landing Zone** | Pre-configured cloud environment with security controls |
| **Shared Responsibility Model** | Division of security responsibility between cloud provider and customer |
| **Multi-Cloud** | Using multiple cloud providers (e.g., AWS + Azure) |
| **Hybrid Cloud** | Mix of on-premises and cloud infrastructure |

### Container & Kubernetes

| Term | Definition |
|------|------------|
| **Container** | Lightweight, portable runtime environment |
| **Kubernetes** | Container orchestration platform |
| **RBAC** | Role-Based Access Control in Kubernetes |
| **Service Mesh** | Infrastructure layer for service-to-service communication (e.g., Istio) |
| **mTLS** | Mutual TLS - Two-way authentication between services |
| **Admission Controller** | Kubernetes component that intercepts and validates requests |
| **Kyverno** | Kubernetes-native policy engine |
| **Pod Security** | Security standards for Kubernetes pods |
| **SBOM** | Software Bill of Materials - List of components in software |
| **Image Signing** | Digital signing of container images for integrity |

---

## 4. Application Security

### API Security

| Term | Definition |
|------|------------|
| **API** | Application Programming Interface - How applications communicate |
| **API Gateway** | Entry point for API requests, handling security and routing |
| **JWT** | JSON Web Token - Compact, URL-safe token for authentication |
| **Rate Limiting** | Restricting request frequency to prevent abuse |
| **CORS** | Cross-Origin Resource Sharing - Browser security policy |
| **BOLA** | Broken Object Level Authorization - OWASP API Top 10 #1 |
| **Mass Assignment** | Allowing users to modify fields they shouldn't - OWASP API Top 10 #6 |
| **Injection** | Code injection attacks (SQL, NoSQL, Command) - OWASP API Top 10 #8 |

### DevSecOps

| Term | Definition |
|------|------------|
| **DevSecOps** | Integrating security into DevOps practices |
| **SAST** | Static Application Security Testing - Analyzing code without running it |
| **DAST** | Dynamic Application Security Testing - Testing running applications |
| **SCA** | Software Composition Analysis - Analyzing third-party dependencies |
| **CI/CD** | Continuous Integration/Continuous Deployment - Automated pipeline |
| **Shift-Left** | Moving security earlier in the development lifecycle |
| **Policy-as-Code** | Security policies defined and enforced as code |
| **Security Gate** | Automated check that must pass for pipeline to continue |

---

## 5. Detection & Response

### SIEM/XDR

| Term | Definition |
|------|------------|
| **SIEM** | Security Information and Event Management - Centralized logging and analysis |
| **XDR** | Extended Detection and Response - Endpoint detection and response |
| **Elasticsearch** | Distributed search and analytics engine (ELK stack) |
| **Logstash** | Log ingestion and processing pipeline (ELK stack) |
| **Kibana** | Visualization and dashboard tool (ELK stack) |
| **Ingestion** | Process of collecting and processing logs |
| **Correlation** | Linking related events from different sources |
| **Enrichment** | Adding context to events (e.g., GeoIP, threat intelligence) |

### Detection Engineering

| Term | Definition |
|------|------------|
| **Detection Rule** | Logic used to identify security events |
| **Sigma** | Standardized format for detection rules |
| **False Positive** | Alert triggered by benign activity |
| **True Positive** | Alert triggered by actual malicious activity |
| **MTTD** | Mean Time to Detect - Average time to detect incidents |
| **MTTR** | Mean Time to Respond - Average time to respond and recover |
| **Rule Tuning** | Adjusting rules to reduce false positives |

### Threat Hunting

| Term | Definition |
|------|------------|
| **Threat Hunting** | Proactive search for threats not detected by automated tools |
| **Hypothesis** | Informed theory about potential threats to investigate |
| **Indicators** | Signs of compromise (IPs, domains, hashes) |
| **TTP** | Tactics, Techniques, and Procedures - Adversary behavior |
| **Hunting Playbook** | Reusable hunting procedure |
| **Jupyter Notebook** | Interactive tool for data analysis and visualization |

### SOAR

| Term | Definition |
|------|------------|
| **SOAR** | Security Orchestration, Automation, and Response - Automated incident response |
| **Playbook** | Automated response workflow |
| **Case Management** | Tracking and managing incidents |
| **Integration Hub** | Central point connecting security tools |
| **Alert Enrichment** | Adding context to alerts automatically |
| **Automated Response** | Actions taken automatically in response to threats |

### Chaos Engineering

| Term | Definition |
|------|------------|
| **Chaos Engineering** | Testing system resilience by injecting failures |
| **Failure Domain** | Scope of a potential failure |
| **Resilience** | System's ability to recover from failures |
| **MTTD** | Mean Time to Detect - During chaos tests |
| **MTTR** | Mean Time to Respond - During chaos tests |
| **Resilience Score** | Metric measuring system resilience |
| **Security Chaos** | Testing security controls with simulated attacks |

---

## 6. Business Continuity

| Term | Definition |
|------|------------|
| **BCP** | Business Continuity Plan - Plan for maintaining operations during disruption |
| **BIA** | Business Impact Analysis - Assessing impact of disruptions |
| **RTO** | Recovery Time Objective - Maximum acceptable downtime |
| **RPO** | Recovery Point Objective - Maximum acceptable data loss |
| **Immutable Backup** | Backup that cannot be modified or deleted |
| **Air-Gapped** | Completely isolated from networks (offline storage) |
| **WORM** | Write Once, Read Many - Storage that prevents modification |
| **Active-Active** | Multiple sites running simultaneously for failover |
| **Active-Passive** | Primary site with standby site for failover |
| **Failover** | Switching to backup site or system |
| **Fallback** | Alternative system when primary fails |

---

## 7. General Security

### Security Principles

| Term | Definition |
|------|------------|
| **Defense-in-Depth** | Multiple layers of security controls |
| **Least Privilege** | Minimum permissions needed for function |
| **Confidentiality** | Protecting information from unauthorized access |
| **Integrity** | Protecting information from unauthorized modification |
| **Availability** | Ensuring information is accessible when needed |
| **CIA Triad** | Confidentiality, Integrity, Availability |
| **Zero Trust** | Never trust, always verify |
| **Assume Breach** | Design as if attackers are already inside |
| **Secure by Default** | Secure configurations out of the box |
| **Fail Secure** | Fail to a secure state |

### Security Architecture

| Term | Definition |
|------|------------|
| **Perimeter Security** | Traditional security focusing on network boundary |
| **Castle-and-Moat** | Traditional security model with hard outer shell |
| **East-West Traffic** | Traffic between internal systems |
| **North-South Traffic** | Traffic between internal and external systems |
| **Blast Radius** | Extent of damage from a security incident |
| **Trust Boundary** | Boundary between trusted and untrusted zones |
| **Security Zone** | Network segment with defined security controls |
| **DMZ** | Demilitarized Zone - Semi-trusted network segment |
| **OT** | Operational Technology - Industrial control systems |
| **ICS** | Industrial Control Systems - SCADA, PLC, DCS |
| **SCADA** | Supervisory Control and Data Acquisition - Industrial monitoring |

### Threat & Risk

| Term | Definition |
|------|------------|
| **Threat** | Potential cause of harm to assets |
| **Vulnerability** | Weakness that can be exploited |
| **Risk** | Likelihood of a threat exploiting a vulnerability |
| **Risk Appetite** | Amount of risk an organization is willing to accept |
| **Risk Tolerance** | Acceptable deviation from risk appetite |
| **Risk Assessment** | Process of identifying and evaluating risks |
| **Risk Treatment** | Actions to address identified risks |
| **Threat Actor** | Entity carrying out attacks |
| **APT** | Advanced Persistent Threat - Sophisticated long-term attacks |
| **TTP** | Tactics, Techniques, and Procedures - Adversary behavior |

### Incident & Response

| Term | Definition |
|------|------------|
| **Incident** | Security event that requires response |
| **Breach** | Unauthorized access to data or systems |
| **Containment** | Preventing spread of an incident |
| **Eradication** | Removing the threat |
| **Recovery** | Restoring systems and operations |
| **Post-Mortem** | Analysis after incident to learn lessons |
| **Playbook** | Documented response procedure |
| **Runbook** | Operational procedure document |
| **Escalation** | Raising an issue to higher authority |
| **Triage** | Initial assessment and prioritization |

---

## 8. Common Acronyms Quick Reference

| Acronym | Meaning |
|---------|---------|
| **ABAC** | Attribute-Based Access Control |
| **AD** | Active Directory |
| **AKS** | Azure Kubernetes Service |
| **API** | Application Programming Interface |
| **AWS** | Amazon Web Services |
| **BCP** | Business Continuity Plan |
| **BIA** | Business Impact Analysis |
| **CIA** | Confidentiality, Integrity, Availability |
| **CIS** | Center for Internet Security |
| **CISO** | Chief Information Security Officer |
| **CORS** | Cross-Origin Resource Sharing |
| **CSF** | Cybersecurity Framework |
| **CSPM** | Cloud Security Posture Management |
| **DAST** | Dynamic Application Security Testing |
| **DLP** | Data Loss Prevention |
| **DMZ** | Demilitarized Zone |
| **DNS** | Domain Name System |
| **DR** | Disaster Recovery |
| **ECS** | Elastic Container Service |
| **EKS** | Elastic Kubernetes Service |
| **ELK** | Elasticsearch, Logstash, Kibana |
| **ETCD** | Distributed key-value store for Kubernetes |
| **GDPR** | General Data Protection Regulation |
| **GRC** | Governance, Risk, and Compliance |
| **HA** | High Availability |
| **IAM** | Identity and Access Management |
| **IaC** | Infrastructure as Code |
| **ICS** | Industrial Control Systems |
| **IDP** | Identity Provider |
| **IDS** | Intrusion Detection System |
| **ILM** | Index Lifecycle Management |
| **IPS** | Intrusion Prevention System |
| **IR** | Incident Response |
| **ISMS** | Information Security Management System |
| **ISO** | International Organization for Standardization |
| **JEA** | Just Enough Administration |
| **JIT** | Just-In-Time |
| **JML** | Joiner-Mover-Leaver |
| **JSON** | JavaScript Object Notation |
| **JWT** | JSON Web Token |
| **K8s** | Kubernetes |
| **KMS** | Key Management Service |
| **KPI** | Key Performance Indicator |
| **LDAP** | Lightweight Directory Access Protocol |
| **MFA** | Multi-Factor Authentication |
| **MTTD** | Mean Time to Detect |
| **MTTR** | Mean Time to Respond |
| **NIST** | National Institute of Standards and Technology |
| **OIDC** | OpenID Connect |
| **OPA** | Open Policy Agent |
| **OT** | Operational Technology |
| **PAM** | Privileged Access Management |
| **PAP** | Policy Administration Point |
| **PDP** | Policy Decision Point |
| **PEP** | Policy Enforcement Point |
| **PII** | Personally Identifiable Information |
| **PIP** | Policy Information Point |
| **PKI** | Public Key Infrastructure |
| **PSA** | Pod Security Admission |
| **RBAC** | Role-Based Access Control |
| **RDP** | Remote Desktop Protocol |
| **RPO** | Recovery Point Objective |
| **RTO** | Recovery Time Objective |
| **SAST** | Static Application Security Testing |
| **SCA** | Software Composition Analysis |
| **SCADA** | Supervisory Control and Data Acquisition |
| **SCIM** | System for Cross-domain Identity Management |
| **SCP** | Service Control Policy |
| **SDP** | Software-Defined Perimeter |
| **SIEM** | Security Information and Event Management |
| **SLA** | Service Level Agreement |
| **SMB** | Server Message Block |
| **SOC** | Security Operations Center |
| **SoA** | Statement of Applicability |
| **SOAR** | Security Orchestration, Automation, and Response |
| **SSH** | Secure Shell |
| **SSL** | Secure Sockets Layer |
| **TLS** | Transport Layer Security |
| **TOTP** | Time-based One-Time Password |
| **TTP** | Tactics, Techniques, and Procedures |
| **UEBA** | User and Entity Behavior Analytics |
| **VPN** | Virtual Private Network |
| **WAF** | Web Application Firewall |
| **XDR** | Extended Detection and Response |
| **XSS** | Cross-Site Scripting |

---

## 9. Key Concepts & Formulas

### Risk Calculation

```
Risk Score = Likelihood × Impact

Likelihood: 1 (Very Low) to 5 (Very High)
Impact: 1 (Low) to 5 (Critical)

Risk Levels:
- 1-4: LOW
- 5-9: MEDIUM
- 10-14: HIGH
- 15-25: CRITICAL
```

### MTTD/MTTR

```
MTTD = Σ(Detection Time - Event Time) / Number of Incidents
MTTR = Σ(Resolution Time - Detection Time) / Number of Incidents
```

### Resilience Score

```
Resilience Score = (MTTD_score × 0.3) + (MTTR_score × 0.3) + (Recovery_Rate_score × 0.2) + (Error_Rate_score × 0.2)
```

### RTO/RPO

```
RTO: Maximum acceptable downtime
RPO: Maximum acceptable data loss
```

---

## 10. Pronunciation Guide

| Term | Pronunciation |
|------|---------------|
| **Kubernetes** | Koo-ber-net-eez |
| **Istio** | Is-tee-oh |
| **Kyverno** | Ky-ver-no |
| **Rego** | Re-go |
| **OIDC** | Oh-eye-dee-see |
| **SCIM** | Skim |
| **SABSA** | Sab-sah |
| **PASTA** | Pah-stah |
| **STRIDE** | Stride |
| **MITRE** | My-ter |
| **NIST** | Nist |
| **CISA** | See-sah |
| **GDPR** | Gee-dee-pee-are |
| **SAML** | Sam-el |
| **SCADA** | Skay-dah |

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX J]**

This appendix provides a comprehensive glossary of all security terms and concepts referenced throughout the series. Use this as a reference for team training, documentation, and communication to ensure consistent understanding across the organization.
