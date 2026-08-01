# Appendix H: Compliance & Audit Reference
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Compliance & Audit Guide

## Overview

This appendix provides a complete reference for compliance requirements, audit controls, and evidence collection across all frameworks implemented in the security architecture.

---

## 1. Regulatory Framework Quick Reference

### 1.1 Framework Requirements Matrix

| Requirement | GDPR | NIST 800-171 | ISO 27001 | SOC 2 | CCPA |
|-------------|------|--------------|-----------|-------|------|
| Data Inventory | ✅ | ✅ | ✅ | ✅ | ✅ |
| Data Classification | ✅ | ✅ | ✅ | ✅ | ✅ |
| Access Controls | ✅ | ✅ | ✅ | ✅ | ✅ |
| Encryption (At Rest) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Encryption (In Transit) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Audit Logging | ✅ | ✅ | ✅ | ✅ | ✅ |
| Incident Response | ✅ | ✅ | ✅ | ✅ | ✅ |
| Breach Notification | ✅ | ✅ | ✅ | ✅ | ✅ |
| Data Retention | ✅ | ✅ | ✅ | ✅ | ✅ |
| Data Deletion | ✅ | ✅ | ✅ | ✅ | ✅ |
| Vendor Risk Mgmt | ✅ | ✅ | ✅ | ✅ | ✅ |
| Security Training | ✅ | ✅ | ✅ | ✅ | ✅ |
| Business Continuity | ✅ | ✅ | ✅ | ✅ | ✅ |
| Penetration Testing | ✅ | ✅ | ✅ | ✅ | ✅ |
| Vulnerability Mgmt | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 2. GDPR Compliance Reference

### 2.1 GDPR Key Articles

| Article | Requirement | Implementation |
|---------|-------------|----------------|
| Art. 5 | Data Processing Principles | Data classification, purpose limitation |
| Art. 6 | Lawfulness of Processing | Consent management, legal basis |
| Art. 12-14 | Data Subject Rights | DSAR automation, data inventory |
| Art. 15 | Right of Access | Data access controls, logging |
| Art. 16 | Right to Rectification | Data correction workflows |
| Art. 17 | Right to Erasure | Data deletion automation |
| Art. 20 | Right to Portability | Data export capabilities |
| Art. 25 | Data Protection by Design | Privacy by design in architecture |
| Art. 28 | Data Processors | Vendor risk assessments |
| Art. 30 | Records of Processing | Data processing register |
| Art. 32 | Security of Processing | All security controls |
| Art. 33-34 | Breach Notification | Incident response plan |

### 2.2 GDPR Control Mapping

| GDPR Article | Security Control | Implementation | Evidence |
|--------------|------------------|----------------|----------|
| Art. 5(1)(f) | Confidentiality, Integrity, Availability | Encryption, Access Controls, Backups | Encryption policies, IAM logs |
| Art. 25(1) | Data Protection by Design | Privacy by Design in SABSA | Architecture documentation |
| Art. 28(2) | Processor Contracts | Vendor agreements | Vendor contracts |
| Art. 30(1) | Data Processing Records | Data inventory | Data inventory spreadsheet |
| Art. 32(1)(a) | Pseudonymization & Encryption | AES-256, TLS 1.3 | Encryption configuration |
| Art. 32(1)(b) | Confidentiality, Integrity, Availability | Access controls, Monitoring | Access logs, SIEM |
| Art. 32(1)(d) | Regular Testing | Vulnerability scanning, Pen testing | Scan reports |
| Art. 33(1) | Breach Notification | Incident response plan | IR documentation |
| Art. 35(1) | DPIA | Data Protection Impact Assessments | DPIA reports |

---

## 3. NIST SP 800-171 Compliance

### 3.1 NIST 800-171 Control Families

| Family | Name | Key Controls |
|--------|------|--------------|
| **AC** | Access Control | AC-1, AC-2, AC-3, AC-4, AC-6, AC-7, AC-8, AC-17, AC-18, AC-19, AC-20 |
| **AT** | Awareness & Training | AT-1, AT-2, AT-3, AT-4 |
| **AU** | Audit & Accountability | AU-1, AU-2, AU-3, AU-6, AU-7, AU-8, AU-9, AU-11, AU-12 |
| **CA** | Assessment & Authorization | CA-2, CA-3, CA-5, CA-7 |
| **CM** | Configuration Management | CM-2, CM-3, CM-4, CM-5, CM-6, CM-7, CM-8, CM-9, CM-10, CM-11 |
| **IA** | Identification & Authentication | IA-1, IA-2, IA-3, IA-4, IA-5, IA-6, IA-7, IA-8, IA-11 |
| **IR** | Incident Response | IR-1, IR-2, IR-4, IR-5, IR-6, IR-7, IR-8 |
| **MA** | Maintenance | MA-1, MA-2, MA-3, MA-4, MA-5, MA-6 |
| **MP** | Media Protection | MP-1, MP-2, MP-3, MP-4, MP-5, MP-6, MP-7, MP-8 |
| **PS** | Personnel Security | PS-1, PS-2, PS-3, PS-4, PS-5, PS-6, PS-7, PS-8 |
| **PE** | Physical & Environmental | PE-1, PE-2, PE-3, PE-4, PE-5, PE-6, PE-8, PE-9, PE-10, PE-11, PE-13, PE-14, PE-15, PE-16, PE-17 |
| **RA** | Risk Assessment | RA-1, RA-2, RA-3, RA-5, RA-7 |
| **CA** | Assessment & Authorization | CA-1, CA-2, CA-3, CA-5, CA-6, CA-7, CA-9 |
| **SC** | System & Communications Protection | SC-1, SC-2, SC-3, SC-4, SC-5, SC-7, SC-8, SC-12, SC-13, SC-15, SC-18, SC-20, SC-21, SC-22, SC-23, SC-24, SC-28, SC-36 |
| **SI** | System & Information Integrity | SI-1, SI-2, SI-3, SI-4, SI-5, SI-7, SI-10, SI-11, SI-12, SI-13, SI-14, SI-15, SI-16, SI-17 |

### 3.2 NIST 800-171 Control Mapping to Security Controls

| NIST Control | Security Control | Implementation |
|--------------|------------------|----------------|
| AC-2 | Account Management | Keycloak SCIM automation, JML |
| AC-3 | Access Enforcement | OPA policies, RBAC/ABAC |
| AC-6 | Least Privilege | JIT/JEA, Vault dynamic credentials |
| AC-7 | Unsuccessful Logon Attempts | Keycloak rate limiting, account lockout |
| AC-17 | Remote Access | VPN, Zero Trust, MFA |
| AC-20 | Use of External Systems | Vendor risk assessments |
| AU-2 | Audit Events | SIEM, audit logging enabled |
| AU-3 | Audit Record Content | Logging policies, structured logging |
| AU-6 | Audit Review & Analysis | SIEM dashboards, security analysts |
| AU-11 | Audit Record Retention | Log retention policies (365 days) |
| CM-2 | Baseline Configuration | CIS benchmarks, hardened images |
| CM-6 | Configuration Settings | Kyverno policies, OPA policies |
| CM-7 | Least Functionality | Minimal service exposure, micro-segmentation |
| IA-2 | Identification & Authentication | MFA, OIDC, password policies |
| IA-5 | Authenticator Management | Password rotation, Vault credential management |
| IR-2 | Incident Response Training | Security awareness training |
| IR-4 | Incident Handling | SOAR playbooks, incident response plan |
| IR-6 | Incident Reporting | Breach notification process |
| RA-5 | Vulnerability Scanning | Qualys, Trivy, AWS Inspector |
| SC-7 | Boundary Protection | Network policies, micro-segmentation, SDP |
| SC-8 | Transmission Confidentiality | TLS 1.3, mTLS |
| SC-12 | Cryptographic Key Management | Vault key management |
| SC-13 | Cryptographic Protection | AES-256 encryption |
| SC-28 | Protection of Information at Rest | Encryption at rest, S3 Object Lock |
| SI-2 | Flaw Remediation | Patch management, vulnerability management |
| SI-4 | Information System Monitoring | SIEM, XDR, Falco |
| SI-7 | Software & Information Integrity | Image signing, SBOM verification |

---

## 4. ISO 27001 Audit Reference

### 4.1 ISMS Audit Checklist

| Audit Area | Controls | Evidence Required |
|------------|----------|-------------------|
| **ISMS Policy** | A.5.1 | Policy document, approval signatures |
| **Risk Assessment** | A.5.6 | Risk register, treatment plans |
| **Statement of Applicability** | A.5.1 | SoA document, justification |
| **Asset Inventory** | A.5.8 | Asset list, owners, classifications |
| **Access Control** | A.5.15, A.5.16, A.5.17, A.5.18 | IAM configuration, MFA logs |
| **Authentication** | A.5.17 | MFA reports, password policy |
| **Privileged Access** | A.5.18 | JIT workflows, Vault logs |
| **Supplier Security** | A.5.22, A.5.23 | Vendor assessments, contracts |
| **Secure Development** | A.5.25, A.5.26 | SDLC documentation, pipeline scans |
| **Security Testing** | A.5.29 | SAST, DAST, SCA reports |
| **Vulnerability Management** | A.5.41 | Scanning reports, remediation plans |
| **Audit Logging** | A.5.42 | SIEM logs, retention policies |
| **Incident Response** | A.5.45 | Playbooks, incident reports |
| **Business Continuity** | A.5.46, A.5.54, A.5.59 | BCP, DR tests, backup validation |
| **Cryptographic Controls** | A.5.55, A.5.56 | Encryption policies, key management |
| **Security Awareness** | A.5.57 | Training records, completion reports |
| **Compliance** | A.5.60 | Compliance reports, audit results |

### 4.2 ISO 27001 Audit Evidence Collection

| Evidence Type | Source | Collection Method | Retention |
|---------------|--------|-------------------|-----------|
| **Access Logs** | Keycloak, Vault, Kubernetes | SIEM collection | 365 days |
| **Change Logs** | Git, Infrastructure as Code | Version control logs | Permanent |
| **Incident Reports** | TheHive SOAR | Case management | 7 years |
| **Training Records** | Learning Management System | Training platform | 7 years |
| **Scan Reports** | Trivy, Qualys, Terrascan | Report storage | 365 days |
| **Audit Logs** | All systems | SIEM | 365 days |
| **Backup Records** | AWS Backup, Azure Backup | Backup reports | 365 days |
| **Vendor Assessments** | GRC platform | Vendor management | 7 years |

---

## 5. SOC 2 Compliance Reference

### 5.1 SOC 2 Trust Service Criteria

| Trust Service Criteria | Category | Key Controls |
|------------------------|----------|--------------|
| **Security** | Protect against unauthorized access | Access control, encryption, monitoring |
| **Availability** | System is available for operation | Business continuity, DR, monitoring |
| **Processing Integrity** | System processes are complete, accurate | Data validation, error handling |
| **Confidentiality** | Information is protected | Encryption, access controls, DLP |
| **Privacy** | Personal information is protected | Data classification, privacy controls |

### 5.2 SOC 2 Control Mapping

| SOC 2 Criteria | Security Control | Implementation |
|----------------|------------------|----------------|
| CC1.1 | Control Environment | Security policies, leadership commitment |
| CC1.2 | Board Oversight | Security governance committee |
| CC2.1 | Risk Assessment | Regular risk assessments |
| CC2.2 | Risk Assessment Process | Threat modeling, vulnerability scanning |
| CC3.1 | Control Activities | Security controls implementation |
| CC3.2 | IT Control Activities | Security controls in IT systems |
| CC4.1 | Information & Communication | Security communication, training |
| CC4.2 | Communication of Information | Incident reporting, security alerts |
| CC5.1 | Monitoring Activities | SIEM, monitoring dashboards |
| CC5.2 | Monitoring of Controls | Regular control testing |
| CC6.1 | Logical Access | IAM, MFA, least privilege |
| CC6.2 | User Access | Access reviews, JML automation |
| CC6.3 | Authentication | MFA, password policies |
| CC6.4 | Cryptographic Keys | Key management, rotation |
| CC6.5 | Access Controls | Network policies, micro-segmentation |
| CC6.6 | Logical Access Reviews | Quarterly access reviews |
| CC7.1 | Security Incident Detection | SIEM, detection rules |
| CC7.2 | Incident Response | SOAR playbooks, IR team |
| CC8.1 | Change Management | Change control, approvals |
| CC9.1 | Business Continuity | BCP, DR plans, backups |
| CC9.2 | Disaster Recovery | DR tests, RTO/RPO validation |

---

## 6. Evidence Collection Templates

### 6.1 Risk Assessment Evidence Template

```markdown
# Risk Assessment Evidence
## Date: YYYY-MM-DD

### Risk: [Risk Name]
**Risk ID:** RISK-XXX
**Owner:** [Owner Name]
**Status:** [Active/Mitigated/Accepted]

### Assessment Details
- **Likelihood:** [Low/Medium/High/Critical]
- **Impact:** [Low/Medium/High/Critical]
- **Score:** [Score]
- **Method:** [STRIDE/PASTA/NIST]

### Control Assessment
| Control | Status | Evidence |
|---------|--------|----------|
| Control 1 | Pass/Fail | [Link to Evidence] |
| Control 2 | Pass/Fail | [Link to Evidence] |

### Treatment Plan
- **Treatment Option:** [Mitigate/Accept/Avoid/Transfer]
- **Implementation Date:** [Date]
- **Verification Date:** [Date]
```

### 6.2 Incident Response Evidence Template

```markdown
# Incident Response Evidence
## Incident ID: IR-XXX

### Incident Details
- **Date:** YYYY-MM-DD
- **Time:** HH:MM UTC
- **Type:** [Phishing/Ransomware/Data Breach]
- **Severity:** [Critical/High/Medium/Low]

### Timeline
| Time | Event | Action |
|------|-------|--------|
| T+0 | Detection | Alert generated |
| T+5 | Triage | Incident verified |
| T+15 | Containment | Network isolation |
| T+60 | Investigation | Root cause identified |
| T+240 | Resolution | Systems restored |

### Evidence Collected
- [ ] Logs
- [ ] Forensics
- [ ] Communications
- [ ] Screenshots

### Lessons Learned
- Root Cause: [Root cause]
- Improvements: [Control improvements]
- Detection: [Rule updates]
```

### 6.3 Compliance Evidence Template

```markdown
# Compliance Evidence
## Date: YYYY-MM-DD
## Framework: [NIST CSF/ISO 27001/GDPR]

### Control Assessment
| Control ID | Control Name | Status | Evidence | Notes |
|------------|--------------|--------|----------|-------|
| | | | | |

### Gap Analysis
| Gap | Impact | Remediation | Timeline |
|-----|--------|-------------|----------|
| | | | |

### Compliance Score
- **Overall:** XX%
- **Critical Controls:** XX%
- **High Controls:** XX%
- **Medium Controls:** XX%
- **Low Controls:** XX%
```

---

## 7. Compliance Monitoring Metrics

### 7.1 Compliance Dashboard Metrics

| Metric | Target | Current | Trend |
|--------|--------|---------|-------|
| **NIST CSF Score** | > 90% | 85% | 📈 |
| **ISO 27001 Controls** | 95% | 78% | 📈 |
| **GDPR Compliance** | 100% | 85% | 📈 |
| **Access Reviews** | 100% | 90% | 📈 |
| **Patch Compliance** | > 95% | 88% | 📈 |
| **MFA Coverage** | 100% | 85% | 📈 |
| **Encryption Coverage** | 100% | 92% | 📈 |
| **Training Completion** | 100% | 78% | 📈 |

### 7.2 Compliance Monitoring Schedule

| Activity | Frequency | Owner | Tool |
|----------|-----------|-------|------|
| **Configuration Scans** | Daily | Security Engineer | AWS Config, Azure Policy |
| **Vulnerability Scans** | Weekly | Security Engineer | Qualys, Trivy |
| **Access Reviews** | Monthly | GRC Manager | Keycloak, IAM |
| **Compliance Reporting** | Monthly | GRC Manager | Security Hub, Azure Center |
| **Control Testing** | Quarterly | Internal Audit | Manual + Automated |
| **Risk Assessment** | Quarterly | Lead Architect | Risk Register |
| **Audit Readiness** | Annually | GRC Manager | Compliance Checklist |

---

## 8. Audit Preparation Checklist

### 8.1 Pre-Audit Checklist

| Task | Owner | Status | Due Date |
|------|-------|--------|----------|
| [ ] Update ISMS Policy | GRC Manager | | |
| [ ] Complete Risk Assessment | Lead Architect | | |
| [ ] Update Statement of Applicability | GRC Manager | | |
| [ ] Review Access Controls | Security Engineer | | |
| [ ] Validate Monitoring Coverage | Detection Engineer | | |
| [ ] Test Incident Response | IR Manager | | |
| [ ] Validate Backup Recovery | SRE | | |
| [ ] Review Vendor Assessments | GRC Manager | | |
| [ ] Complete Training Records | GRC Manager | | |
| [ ] Run Compliance Scans | Security Engineer | | |
| [ ] Document Remediation | All Owners | | |

### 8.2 Evidence Collection Checklist

| Evidence Type | Location | Status |
|---------------|----------|--------|
| **Policies** | Git Repository | ☐ |
| **Risk Assessments** | Risk Register | ☐ |
| **Security Controls** | Architecture Documents | ☐ |
| **Access Logs** | SIEM | ☐ |
| **Incident Reports** | Case Management | ☐ |
| **Training Records** | LMS | ☐ |
| **Vendor Assessments** | Vendor Portal | ☐ |
| **Scan Reports** | Security Reports | ☐ |
| **Audit Trails** | SIEM | ☐ |
| **Change Logs** | Git/CMDB | ☐ |
| **Backup Reports** | Backup System | ☐ |

---

## 9. Compliance Reporting Templates

### 9.1 Executive Compliance Report

```markdown
# Cybersecurity Compliance Report
## Nexus Global Industries - QX 2026

### Executive Summary
- Overall Compliance: XX%
- Critical Issues: 0
- High Priority Issues: 2
- Compliance Trend: Improving

### Framework Status
| Framework | Score | Status |
|-----------|-------|--------|
| NIST CSF 2.0 | XX% | On Track |
| ISO 27001 | XX% | In Progress |
| GDPR | XX% | On Track |
| SOC 2 | XX% | In Progress |

### Key Initiatives
1. MFA rollout: 85% complete
2. Zero Trust implementation: 70% complete
3. Security awareness training: 78% complete

### Risk Status
- Critical Risks: 0
- High Risks: 2
- Medium Risks: 5
- Low Risks: 8

### Next Steps
1. Complete MFA rollout by Month 3
2. Zero Trust implementation by Month 6
3. ISO 27001 certification by Month 18
```

---

**Document Owner**: GRC Manager  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX H]**

This appendix provides a complete reference for compliance requirements and audit preparation across all frameworks. Use this as a guide for continuous compliance monitoring, audit preparation, and evidence collection.
