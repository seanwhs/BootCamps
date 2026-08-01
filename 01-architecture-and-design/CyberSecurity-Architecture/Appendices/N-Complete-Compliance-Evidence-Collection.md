# Appendix N: Complete Compliance Evidence Collection
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Audit Evidence Reference

## Overview

This appendix provides a complete reference for collecting and organizing compliance evidence across all frameworks. Use this as a guide for audit preparation, continuous compliance monitoring, and evidence management.

---

## 1. Evidence Collection Framework

### 1.1 Evidence Categories

| Category | Description | Examples | Retention |
|----------|-------------|----------|-----------|
| **Policies** | Security policies and procedures | ISMS policy, access control policy | Current + 7 years |
| **Controls** | Implementation of security controls | Firewall rules, IAM configuration | Current + 7 years |
| **Logs** | System and security logs | SIEM logs, audit logs, access logs | 365 days |
| **Reports** | Security assessment reports | Pen test reports, vulnerability scans | 3 years |
| **Training** | Security training records | Completion certificates, attendance | 3 years |
| **Incidents** | Incident reports | IR reports, post-mortems | 7 years |
| **Tests** | Security test results | DR tests, chaos tests, BCP tests | 3 years |
| **Risk** | Risk assessments | Risk register, threat models | 3 years |

### 1.2 Evidence Collection Methods

| Method | Description | Tools |
|--------|-------------|-------|
| **Automated Collection** | SIEM, logs, scans | ELK, AWS Config, Azure Policy |
| **Manual Collection** | Policies, reports, training | Document management |
| **Audit Trail** | System-generated evidence | CloudTrail, Activity Logs |
| **API Collection** | Tool-based collection | REST APIs, SDKs |
| **Interview** | Process validation | Audit interviews |

---

## 2. NIST CSF 2.0 Evidence Collection

### 2.1 Govern Function (GV)

| Category | Evidence | Location | Collection |
|----------|----------|----------|------------|
| **GV.OC** (Organizational Context) | Business context document | Documentation | Manual |
| | Mission statement | Documentation | Manual |
| | Risk appetite statement | Risk register | Manual |
| **GV.RM** (Risk Management Strategy) | Risk management policy | Policy docs | Manual |
| | Risk register | GRC tool | Automated |
| | Risk treatment plans | GRC tool | Automated |
| **GV.RR** (Roles & Responsibilities) | Org chart | HR system | Manual |
| | Role descriptions | Documentation | Manual |
| **GV.PO** (Policies & Procedures) | Information security policy | Git/Policies | Manual |
| | All supporting policies | Git/Policies | Manual |
| | Policy approval records | Git | Manual |
| **GV.OV** (Oversight) | SGC meeting minutes | Documentation | Manual |
| | SARB meeting minutes | Documentation | Manual |
| | Board security reports | Documentation | Manual |
| **GV.SC** (Supply Chain Risk) | Vendor risk assessments | Vendor portal | Manual |
| | Vendor contracts | Legal docs | Manual |
| | Vendor SOC 2 reports | Vendor portal | Manual |
| **GV.AW** (Awareness & Training) | Training completion records | LMS | Automated |
| | Phishing simulation results | Simulation tool | Automated |
| **GV.FI** (Feedback & Improvement) | Audit findings | Audit reports | Manual |
| | Improvement plans | Documentation | Manual |

### 2.2 Identify Function (ID)

| Category | Evidence | Location | Collection |
|----------|----------|----------|------------|
| **ID.AM** (Asset Management) | Asset inventory | CMDB | Automated |
| | Asset owners | CMDB | Automated |
| | Data classification | Data catalog | Manual |
| **ID.RA** (Risk Assessment) | Risk assessments | Risk register | Automated |
| | Threat models | Documentation | Manual |
| | Vulnerability scans | Scanning tools | Automated |
| **ID.BE** (Business Environment) | Criticality tiers | BIA document | Manual |
| | RTO/RPO targets | BCP document | Manual |
| **ID.GV** (Governance & Risk) | Compliance assessments | GRC tool | Manual |
| | Control status | GRC tool | Automated |
| **ID.IM** (Improvement) | Maturity assessments | Documentation | Manual |
| | Improvement plans | Project mgmt | Manual |

### 2.3 Protect Function (PR)

| Category | Evidence | Location | Collection |
|----------|----------|----------|------------|
| **PR.AC** (Access Control) | IAM configuration | Keycloak | Automated |
| | MFA reports | Keycloak | Automated |
| | Access review records | IAM tool | Manual |
| | Privileged access logs | Vault | Automated |
| **PR.AT** (Awareness & Training) | Training records | LMS | Automated |
| | Role-based training | LMS | Automated |
| **PR.DS** (Data Security) | Encryption policies | Documentation | Manual |
| | Encryption configuration | Cloud tools | Automated |
| | DLP configuration | DLP tool | Automated |
| **PR.IP** (Information Protection) | Secure development policy | Documentation | Manual |
| | DevSecOps pipeline config | CI/CD | Automated |
| | Security testing results | Testing tools | Automated |
| **PR.MA** (Maintenance) | Patch management policy | Documentation | Manual |
| | Patching records | VM tools | Automated |
| | Maintenance logs | ITSM | Automated |
| **PR.ND** (Network Security) | Network architecture | Diagrams | Manual |
| | Network policies | Network tools | Automated |
| | Firewall rules | Network tools | Automated |
| **PR.IR** (Incident Response) | IR policy | Documentation | Manual |
| | IR playbooks | Documentation | Manual |
| | Tabletop exercise results | Documentation | Manual |

### 2.4 Detect Function (DE)

| Category | Evidence | Location | Collection |
|----------|----------|----------|------------|
| **DE.AE** (Anomalies & Events) | SIEM configuration | SIEM | Automated |
| | Detection rules | SIEM | Automated |
| | Anomaly detection logs | SIEM | Automated |
| **DE.CM** (Continuous Monitoring) | Monitoring configuration | Monitoring tools | Automated |
| | Monitoring dashboards | Monitoring tools | Automated |
| | Alert logs | SIEM | Automated |
| **DE.DP** (Detection Processes) | Detection engineering process | Documentation | Manual |
| | Rule testing results | Testing tools | Automated |
| | Threat hunting reports | Hunting tools | Manual |
| **DE.AR** (Anomaly Response) | Alert triage logs | SOAR | Automated |
| | Escalation records | PagerDuty | Automated |
| **DE.DU** (Detection Unauthorized) | UEBA configuration | UEBA tool | Automated |
| | Malware detection logs | XDR | Automated |
| **DE.SR** (Security Monitoring) | Monitoring coverage report | Monitoring tools | Automated |
| | Monitoring gap analysis | Documentation | Manual |

### 2.5 Respond Function (RS)

| Category | Evidence | Location | Collection |
|----------|----------|----------|------------|
| **RS.RP** (Response Planning) | IR plan | Documentation | Manual |
| | IR playbooks | Documentation | Manual |
| | IR team roster | Documentation | Manual |
| **RS.AN** (Analysis) | Incident reports | Case management | Automated |
| | Forensic analysis reports | Documentation | Manual |
| | Root cause analysis | Documentation | Manual |
| **RS.MI** (Mitigation) | Containment records | IR tools | Automated |
| | Remediation records | ITSM | Automated |
| **RS.IM** (Improvements) | Post-incident reviews | Documentation | Manual |
| | Improvement tracking | Project mgmt | Manual |
| **RS.CO** (Communications) | Incident communication logs | Slack/Email | Automated |
| | Customer notifications | Documentation | Manual |

### 2.6 Recover Function (RC)

| Category | Evidence | Location | Collection |
|----------|----------|----------|------------|
| **RC.RP** (Recovery Planning) | BCP document | Documentation | Manual |
| | DR plan | Documentation | Manual |
| | BIA document | Documentation | Manual |
| **RC.IM** (Improvements) | DR test results | Testing tools | Manual |
| | Recovery improvement plans | Project mgmt | Manual |
| **RC.RI** (Recovery Infrastructure) | Backup configuration | Backup tools | Automated |
| | Backup logs | Backup tools | Automated |
| | DR infrastructure config | Cloud tools | Automated |
| **RC.RC** (Recovery Communications) | Recovery communication plan | Documentation | Manual |
| | Crisis communication logs | Slack/Email | Automated |

---

## 3. ISO 27001 Evidence Collection

### 3.1 ISMS Evidence

| Control | Evidence | Location | Collection |
|---------|----------|----------|------------|
| **A.5.1** (Information Security Policy) | ISMS policy document | Git/Policies | Manual |
| | Approval records | Git | Manual |
| **A.5.2** (Information Security Roles) | Security org chart | Documentation | Manual |
| | Role descriptions | Documentation | Manual |
| **A.5.6** (Information Security in Projects) | Project security reviews | Project docs | Manual |
| | Threat modeling results | Documentation | Manual |
| **A.5.15** (Access Control Policy) | Access control policy | Git/Policies | Manual |
| | IAM configuration | Keycloak | Automated |
| **A.5.16** (Identity Management) | SCIM configuration | SCIM tool | Automated |
| | User lifecycle records | SCIM tool | Automated |
| **A.5.17** (Authentication) | MFA configuration | Keycloak | Automated |
| | MFA coverage report | Keycloak | Automated |
| **A.5.18** (Privileged Access Rights) | PAM configuration | Vault | Automated |
| | Privileged access logs | Vault | Automated |
| **A.5.25** (Secure Development Lifecycle) | SDLC policy | Git/Policies | Manual |
| | Security gates in CI/CD | CI/CD | Automated |
| **A.5.29** (Security Testing) | SAST results | CI/CD | Automated |
| | DAST results | CI/CD | Automated |
| | Pen test reports | Documentation | Manual |
| **A.5.41** (Vulnerability Management) | Vulnerability scan logs | Qualys/Trivy | Automated |
| | Remediation records | ITSM | Automated |
| **A.5.42** (Audit Logging) | SIEM configuration | SIEM | Automated |
| | Audit log retention | SIEM | Automated |
| **A.5.43** (Monitoring) | SIEM dashboards | SIEM | Automated |
| | Alert configuration | SIEM | Automated |
| **A.5.45** (Incident Response) | IR plan | Git/Policies | Manual |
| | Incident reports | TheHive | Automated |
| **A.5.46** (Business Continuity) | BCP document | Git/Policies | Manual |
| | BCP test records | Documentation | Manual |
| **A.5.54** (Backup and Recovery) | Backup configuration | Backup tools | Automated |
| | Backup logs | Backup tools | Automated |
| **A.5.55** (Cryptographic Controls) | Encryption policy | Git/Policies | Manual |
| | Encryption configuration | Cloud tools | Automated |
| **A.5.57** (Security Awareness) | Training records | LMS | Automated |
| | Phishing simulation | Simulation tool | Automated |
| **A.5.62** (Independent Review) | Internal audit reports | Documentation | Manual |
| | External audit reports | Documentation | Manual |

---

## 4. GDPR Evidence Collection

### 4.1 GDPR Articles

| Article | Evidence | Location | Collection |
|---------|----------|----------|------------|
| **Art. 5** (Processing Principles) | Data inventory | Data catalog | Manual |
| | Data classification | Data catalog | Manual |
| | Data retention policy | Git/Policies | Manual |
| **Art. 25** (Privacy by Design) | Privacy by Design documentation | Architecture docs | Manual |
| | Data protection controls | Security tools | Automated |
| **Art. 30** (Records of Processing) | Data processing records | Data catalog | Manual |
| | Processor contracts | Legal docs | Manual |
| **Art. 32** (Security of Processing) | Security controls | Security tools | Automated |
| | Security testing results | Testing tools | Automated |
| | Incident logs | SIEM | Automated |
| **Art. 33-34** (Breach Notification) | Incident response plan | Git/Policies | Manual |
| | Breach notification procedures | Git/Policies | Manual |
| | Incident reports | TheHive | Automated |

---

## 5. Evidence Collection Templates

### 5.1 Evidence Log Template

```markdown
# Evidence Collection Log

## Evidence ID: [EVID-XXX]
**Date Collected:** YYYY-MM-DD
**Collected By:** [Name]
**Framework:** [NIST CSF/ISO 27001/GDPR]
**Control ID:** [Control ID]
**Control Name:** [Control Name]

### Evidence Details
- **Type:** [Policy/Log/Report/Configuration]
- **Format:** [PDF/JSON/YAML/Log]
- **Location:** [URL/Path]
- **Collection Method:** [Automated/Manual]

### Evidence Description
[Description of the evidence and what it demonstrates]

### Verification
- [ ] Evidence is complete
- [ ] Evidence is accurate
- [ ] Evidence is current
- [ ] Evidence is accessible
- [ ] Evidence is secure

### Retention
- **Retention Period:** [30 days/1 year/7 years]
- **Retention Location:** [S3/Glacier/Archive]

### Notes
[Additional notes]
```

### 5.2 Control Evidence Checklist

```markdown
# Control Evidence Checklist
## Control ID: [CONTROL-XXX]
## Control Name: [Control Name]
## Framework: [Framework]

### Required Evidence
| Evidence Type | Status | Location | Notes |
|---------------|--------|----------|-------|
| Policy | ☐ | | |
| Implementation | ☐ | | |
| Logs | ☐ | | |
| Reports | ☐ | | |
| Tests | ☐ | | |

### Evidence Collected
1. [Evidence 1] - [Status]
2. [Evidence 2] - [Status]

### Evidence Gaps
| Gap | Action | Owner | Timeline |
|-----|--------|-------|----------|
| | | | |

### Control Status
- **Overall:** [Compliant/Partial/Non-Compliant]
- **Target:** [Date]
- **Owner:** [Name]
```

### 5.3 Audit Evidence Request Template

```markdown
# Audit Evidence Request
## Request ID: [REQ-XXX]
**Date:** YYYY-MM-DD
**Requestor:** [Auditor Name]
**Audit:** [Audit Type]

### Requested Evidence
| ID | Evidence Description | Location | Owner | Status |
|----|---------------------|----------|-------|--------|
| | | | | |

### Due Date
[Date]

### Delivery Method
[Secure Portal/Email/File Share]

### Notes
[Additional instructions]
```

---

## 6. Evidence Management System

### 6.1 Evidence Storage

| Storage Type | Purpose | Retention | Access |
|--------------|---------|-----------|--------|
| **SIEM (ELK)** | Logs, events | 365 days | Security Team |
| **Git Repository** | Policies, code | Permanent | All |
| **Document Management** | Reports, assessments | 7 years | GRC Team |
| **S3 Glacier** | Archived evidence | 7+ years | Limited |
| **GRC Tool** | Compliance data | Current | GRC Team |

### 6.2 Evidence Lifecycle

```
Collect
  │
  ▼
Validate
  │
  ▼
Store
  │
  ▼
Retain
  │
  ▼
Review (Periodic)
  │
  ▼
Archive
  │
  ▼
Dispose (After Retention)
```

### 6.3 Evidence Access Control

| Role | Access | Permissions |
|------|--------|-------------|
| **Auditors** | Evidence Review | Read-only |
| **GRC Team** | Evidence Management | Read/Write/Delete |
| **Security Team** | Evidence Collection | Read/Write |
| **Management** | Evidence Reports | Read-only |

---

## 7. Compliance Evidence Dashboard

### 7.1 Evidence Collection Status

```
┌─────────────────────────────────────────────────────────────────┐
│                    EVIDENCE DASHBOARD                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Total Evidence Required: 450                                   │
│  Evidence Collected: 385 (85.6%)                              │
│  Evidence Missing: 65 (14.4%)                                 │
│                                                                 │
│  By Framework:                                                  │
│  NIST CSF 2.0: 150/180 (83.3%)                                │
│  ISO 27001: 120/140 (85.7%)                                   │
│  GDPR: 80/90 (88.9%)                                          │
│  SOC 2: 35/40 (87.5%)                                         │
│                                                                 │
│  By Category:                                                   │
│  Policies: 25/25 (100%)                                       │
│  Controls: 180/200 (90%)                                      │
│  Logs: 100/120 (83.3%)                                        │
│  Reports: 40/50 (80%)                                         │
│  Tests: 40/55 (72.7%)                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Evidence Aging

```
┌─────────────────────────────────────────────────────────────────┐
│                    EVIDENCE AGING                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Recent (0-30 days): 45%                                       │
│  Current (31-90 days): 35%                                    │
│  Aging (91-180 days): 15%                                     │
│  Expiring (181-365 days): 5%                                  │
│                                                                 │
│  Expiring Evidence:                                            │
│  - Pen Test Report (expires in 15 days)                       │
│  - DR Test Results (expires in 30 days)                       │
│  - Phishing Simulation Results (expires in 45 days)           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 7.3 Gap Analysis

```
┌─────────────────────────────────────────────────────────────────┐
│                    GAP ANALYSIS                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Critical Gaps: 2                                              │
│  High Gaps: 8                                                 │
│  Medium Gaps: 15                                              │
│  Low Gaps: 40                                                 │
│                                                                 │
│  Top Gaps:                                                     │
│  1. Incident Response Logs (DE.AE)                            │
│  2. Vendor Risk Assessments (GV.SC)                          │
│  3. Threat Hunting Reports (DE.DP)                           │
│  4. Backup Restoration Tests (RC.RI)                         │
│  5. Security Awareness Completion (GV.AW)                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Quick Reference: Evidence Collection Commands

### 8.1 AWS Evidence Collection

```bash
# Collect AWS Config compliance
aws configservice get-compliance-details-by-config-rule \
  --compliance-types NON_COMPLIANT \
  --output json > compliance-report.json

# Collect CloudTrail logs
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
  --start-time $(date -d '30 days ago' -I) \
  --output json > cloudtrail-logs.json

# Collect Security Hub findings
aws securityhub get-findings \
  --filters '{"ComplianceStatus": [{"Value": "FAILED", "Comparison": "EQUALS"}]}' \
  --output json > security-hub-findings.json

# Collect IAM users
aws iam list-users --output json > iam-users.json

# Collect S3 bucket policies
aws s3api get-bucket-policy --bucket nexus-critical-backups > s3-policy.json
```

### 8.2 Azure Evidence Collection

```bash
# Collect Azure Policy compliance
az policy state list \
  --all \
  --output json > azure-policy-compliance.json

# Collect Activity Logs
az monitor activity-log list \
  --start-time $(date -d '30 days ago' -I) \
  --output json > azure-activity-logs.json

# Collect Security Center findings
az security assessment list \
  --output json > azure-security-findings.json

# Collect Azure AD users
az ad user list --output json > azure-ad-users.json
```

### 8.3 Kubernetes Evidence Collection

```bash
# Collect RBAC configuration
kubectl get clusterroles -o yaml > cluster-roles.yaml
kubectl get clusterrolebindings -o yaml > cluster-role-bindings.yaml

# Collect network policies
kubectl get networkpolicies -A -o yaml > network-policies.yaml

# Collect admission controller config
kubectl get validatingwebhookconfigurations -o yaml > validating-webhooks.yaml

# Collect audit logs
kubectl logs -n kube-system deployment/kube-apiserver \
  --tail=10000 > api-server-logs.txt
```

### 8.4 SIEM Evidence Collection

```bash
# Export security events
curl -k -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{"query": {"match_all": {}}, "size": 10000}' \
  > security-events.json

# Export audit events
curl -k -X GET "https://elasticsearch:9200/audit-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{"query": {"match_all": {}}, "size": 10000}' \
  > audit-events.json
```

---

## 9. Compliance Audit Schedule

### 9.1 Annual Compliance Calendar

| Month | Activity | Owner |
|-------|----------|-------|
| January | Evidence collection review | GRC Team |
| February | NIST CSF self-assessment | Lead Architect |
| March | ISO 27001 internal audit | Internal Audit |
| April | GDPR compliance review | GRC Team |
| May | SOC 2 readiness assessment | GRC Team |
| June | Penetration testing | External Vendor |
| July | ISO 27001 surveillance audit | External Auditor |
| August | NIST CSF gap analysis | Lead Architect |
| September | GDPR gap analysis | GRC Team |
| October | SOC 2 audit | External Auditor |
| November | Evidence cleanup | GRC Team |
| December | Annual compliance report | GRC Manager |

### 9.2 Audit Preparation Checklist

| Task | Owner | Status | Due Date |
|------|-------|--------|----------|
| Update policies | GRC Manager | ☐ | |
| Complete risk assessment | Lead Architect | ☐ | |
| Review controls | Security Team | ☐ | |
| Collect evidence | GRC Team | ☐ | |
| Validate logs | SIEM Admin | ☐ | |
| Test incident response | IR Manager | ☐ | |
| Review training records | GRC Manager | ☐ | |
| Update documentation | Lead Architect | ☐ | |

---

**Document Owner**: GRC Manager  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX N]**

This appendix provides complete guidance for collecting and organizing compliance evidence. Use this as a reference for audit preparation, continuous compliance monitoring, and evidence management.
