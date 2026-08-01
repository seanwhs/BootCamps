# Appendix C: Complete Security Control Mappings
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Control Mapping Reference

## Overview

This appendix provides comprehensive control mappings between all frameworks integrated throughout the series. Use this as a reference for compliance audits, architecture reviews, and control implementation planning.

---

## 1. SABSA → NIST CSF 2.0 Mapping

| SABSA Layer | NIST CSF Function | NIST CSF Category | Description |
|-------------|-------------------|-------------------|-------------|
| **Contextual** | Govern (GV) | GV.OC (Organizational Context) | Business context, mission, risk appetite |
| **Contextual** | Identify (ID) | ID.BE (Business Environment) | Business drivers, critical assets |
| **Contextual** | Identify (ID) | ID.RA (Risk Assessment) | Risk environment, threat landscape |
| **Conceptual** | Govern (GV) | GV.RM (Risk Management Strategy) | Security strategy, risk approach |
| **Conceptual** | Govern (GV) | GV.PO (Policies & Procedures) | Security policies, principles |
| **Logical** | Protect (PR) | PR.AC (Access Control) | Identity, authentication, authorization |
| **Logical** | Protect (PR) | PR.DS (Data Security) | Encryption, DLP, data classification |
| **Logical** | Protect (PR) | PR.ND (Network Security) | Segmentation, network controls |
| **Physical** | Protect (PR) | PR.IP (Information Protection) | Technology controls, hardening |
| **Physical** | Detect (DE) | DE.CM (Continuous Monitoring) | Monitoring tools, SIEM |
| **Component** | Protect (PR) | PR.MA (Maintenance) | Patching, vulnerability management |
| **Component** | Detect (DE) | DE.AE (Anomalies & Events) | Detection rules, analytics |
| **Operational** | Respond (RS) | RS.RP (Response Planning) | IR playbooks, procedures |
| **Operational** | Respond (RS) | RS.AN (Analysis) | Forensics, triage |
| **Operational** | Recover (RC) | RC.RP (Recovery Planning) | BCP, DR planning |
| **Operational** | Recover (RC) | RC.IM (Improvements) | Recovery testing, improvements |
| **Operational** | Govern (GV) | GV.RR (Roles & Responsibilities) | Security governance, roles |
| **Operational** | Govern (GV) | GV.OV (Oversight) | Board reporting, SGC |

---

## 2. NIST CSF 2.0 → ISO 27001 Annex A Mapping

| NIST CSF Function | ISO 27001 Annex A Control | Control ID |
|-------------------|---------------------------|------------|
| **GV.OC** (Organizational Context) | Information Security Policy | A.5.1 |
| **GV.RM** (Risk Management Strategy) | Information Security in Project Management | A.5.6 |
| **GV.RR** (Roles & Responsibilities) | Information Security Roles | A.5.2 |
| **GV.PO** (Policies & Procedures) | Information Security Policy | A.5.1 |
| **GV.OV** (Oversight) | Independent Review of Security | A.5.62 |
| **GV.SC** (Supply Chain Risk) | Supplier Selection | A.5.22 |
| **GV.SC** (Supply Chain Risk) | Supplier Agreements | A.5.23 |
| **GV.AW** (Awareness & Training) | Information Security Awareness Training | A.5.57 |
| **GV.FI** (Feedback & Improvement) | Independent Review of Security | A.5.62 |
| **ID.AM** (Asset Management) | Asset Inventory | A.5.8 |
| **ID.AM** (Asset Management) | Ownership of Assets | A.5.9 |
| **ID.RA** (Risk Assessment) | Risk Assessment | A.5.6 |
| **ID.BE** (Business Environment) | Business Continuity Management | A.5.46 |
| **PR.AC** (Access Control) | Access Control Policy | A.5.15 |
| **PR.AC** (Access Control) | Identity Management | A.5.16 |
| **PR.AC** (Access Control) | Authentication | A.5.17 |
| **PR.AC** (Access Control) | Privileged Access Rights | A.5.18 |
| **PR.AT** (Awareness & Training) | Information Security Awareness Training | A.5.57 |
| **PR.DS** (Data Security) | Classification of Information | A.5.12 |
| **PR.DS** (Data Security) | Cryptographic Controls | A.5.55 |
| **PR.DS** (Data Security) | Key Management | A.5.56 |
| **PR.IP** (Information Protection) | Secure Development Lifecycle | A.5.25 |
| **PR.IP** (Information Protection) | Security Testing | A.5.29 |
| **PR.MA** (Maintenance) | Management of Technical Vulnerabilities | A.5.41 |
| **PR.ND** (Network Security) | Network Security | A.5.37 |
| **PR.IR** (Incident Response) | Incident Response | A.5.45 |
| **DE.AE** (Anomalies & Events) | Audit Logging | A.5.42 |
| **DE.CM** (Continuous Monitoring) | Monitoring of ICT Systems | A.5.43 |
| **DE.CM** (Continuous Monitoring) | Security Monitoring | A.5.73 |
| **DE.DP** (Detection Processes) | Detection Engineering | A.5.69 |
| **RS.RP** (Response Planning) | Incident Response | A.5.45 |
| **RS.AN** (Analysis) | Digital Forensics | A.5.70 |
| **RS.MI** (Mitigation) | Incident Response | A.5.45 |
| **RS.IM** (Improvements) | Independent Review of Security | A.5.62 |
| **RS.CO** (Communications) | Information Event Reporting | A.5.44 |
| **RC.RP** (Recovery Planning) | Business Continuity Management | A.5.46 |
| **RC.RP** (Recovery Planning) | Information Security Continuity | A.5.59 |
| **RC.IM** (Improvements) | Business Continuity Management | A.5.46 |
| **RC.RI** (Recovery Infrastructure) | Redundancy of ICT Systems | A.5.47 |
| **RC.RI** (Recovery Infrastructure) | Backup and Recovery | A.5.54 |

---

## 3. ISO 27001 Annex A → MITRE ATT&CK Mapping

| Annex A Control | MITRE Tactic | MITRE Technique | Technique ID |
|-----------------|--------------|-----------------|--------------|
| A.5.15 (Access Control Policy) | Initial Access | Valid Accounts | T1078 |
| A.5.16 (Identity Management) | Initial Access | Valid Accounts | T1078 |
| A.5.17 (Authentication) | Initial Access | Valid Accounts | T1078 |
| A.5.18 (Privileged Access Rights) | Privilege Escalation | Abuse Elevation Control Mechanism | T1548 |
| A.5.25 (Secure Development) | Execution | User Execution | T1204 |
| A.5.25 (Secure Development) | Execution | Command and Scripting Interpreter | T1059 |
| A.5.29 (Security Testing) | All | All Techniques | N/A |
| A.5.41 (Vulnerability Management) | All | All Techniques | N/A |
| A.5.42 (Audit Logging) | All | All Techniques (Detection) | N/A |
| A.5.43 (Monitoring) | All | All Techniques (Detection) | N/A |
| A.5.45 (Incident Response) | All | All Techniques (Response) | N/A |
| A.5.46 (Business Continuity) | Impact | Data Encrypted for Impact | T1486 |
| A.5.46 (Business Continuity) | Impact | Network Denial of Service | T1498 |
| A.5.54 (Backup and Recovery) | Impact | Data Encrypted for Impact | T1486 |
| A.5.55 (Cryptographic Controls) | Exfiltration | Exfiltration Over C2 | T1041 |
| A.5.55 (Cryptographic Controls) | Exfiltration | Exfiltration to Cloud Storage | T1567 |
| A.5.69 (SIEM) | All | All Techniques (Detection) | N/A |
| A.5.70 (Digital Forensics) | All | All Techniques (Investigation) | N/A |
| A.5.73 (Security Monitoring) | All | All Techniques (Detection) | N/A |
| A.8.20 (Network Security) | Lateral Movement | Remote Services | T1021 |
| A.8.20 (Network Security) | Lateral Movement | Use Alternate Authentication Material | T1550 |
| A.8.23 (Web Filtering) | Initial Access | Exploit Public-Facing Application | T1190 |
| A.8.23 (Web Filtering) | Initial Access | Phishing | T1566 |

---

## 4. MITRE ATT&CK → Security Control Mapping

| MITRE Technique | Technique Name | Primary Controls | Secondary Controls |
|-----------------|----------------|------------------|-------------------|
| **T1003** | OS Credential Dumping | MFA, EDR, Least Privilege | Audit Logging, SIEM |
| **T1021** | Remote Services | Micro-segmentation, Network Policies | Firewall, VPN |
| **T1041** | Exfiltration Over C2 | DLP, Network Monitoring | SIEM, Encryption |
| **T1053** | Scheduled Task/Job | Audit Logging, SIEM | File Integrity Monitoring |
| **T1068** | Exploit for Priv Escalation | Patch Management, Least Privilege | Vulnerability Scanning |
| **T1078** | Valid Accounts | MFA, Zero Trust, Identity Management | Audit Logging |
| **T1190** | Exploit Public-Facing App | WAF, API Security, Rate Limiting | Patch Management |
| **T1195** | Supply Chain Compromise | SBOM, SCA Scanning, Vendor Assessment | Secure Development |
| **T1486** | Data Encrypted for Impact | Immutable Backups, Network Segmentation | SIEM, EDR |
| **T1548** | Abuse Elevation Control | JIT, JEA, Least Privilege | Audit Logging |
| **T1566** | Phishing | Email Security, MFA, Training | SIEM |
| **T1567** | Exfiltration to Cloud Storage | DLP, CSPM, Cloud Monitoring | SIEM |
| **T1578** | Modify Cloud Infrastructure | CSPM, IaC Security, Change Management | Audit Logging |
| **T1110** | Brute Force | Rate Limiting, Account Lockout | SIEM |
| **T1059** | Command & Scripting | Application Whitelisting, EDR | Audit Logging |
| **T1550** | Alternate Authentication | mTLS, Zero Trust | Network Policies |
| **T1498** | Network DoS | DDoS Protection, Auto-scaling | Network Monitoring |
| **T1036** | Masquerading | EDR, File Integrity Monitoring | SIEM |

---

## 5. SABSA → MITRE ATT&CK Mapping

| SABSA Layer | MITRE Tactic | MITRE Technique | Technique ID |
|-------------|--------------|-----------------|--------------|
| **Contextual** | Impact | Data Encrypted for Impact | T1486 |
| **Contextual** | Impact | Network Denial of Service | T1498 |
| **Conceptual** | All | All Techniques | N/A |
| **Logical** | Initial Access | Valid Accounts | T1078 |
| **Logical** | Initial Access | Exploit Public-Facing Application | T1190 |
| **Logical** | Execution | Command and Scripting Interpreter | T1059 |
| **Logical** | Persistence | Scheduled Task/Job | T1053 |
| **Logical** | Privilege Escalation | Exploit for Privilege Escalation | T1068 |
| **Logical** | Privilege Escalation | Abuse Elevation Control Mechanism | T1548 |
| **Logical** | Credential Access | OS Credential Dumping | T1003 |
| **Logical** | Credential Access | Brute Force | T1110 |
| **Logical** | Lateral Movement | Remote Services | T1021 |
| **Logical** | Lateral Movement | Use Alternate Authentication Material | T1550 |
| **Logical** | Defense Evasion | Modify Cloud Infrastructure | T1578 |
| **Logical** | Defense Evasion | Masquerading | T1036 |
| **Logical** | Exfiltration | Exfiltration Over C2 | T1041 |
| **Logical** | Exfiltration | Exfiltration to Cloud Storage | T1567 |
| **Physical** | All | All Techniques (Technology Controls) | N/A |
| **Component** | All | All Techniques (Implementation) | N/A |
| **Operational** | All | All Techniques (Response) | N/A |

---

## 6. CIS Controls Mapping

### 6.1 CIS Controls → MITRE ATT&CK

| CIS Control | MITRE Tactic | MITRE Technique | Technique ID |
|-------------|--------------|-----------------|--------------|
| **Control 1: Inventory** | Discovery | Account Discovery | T1087 |
| **Control 2: Secure Config** | Defense Evasion | Modify Cloud Infrastructure | T1578 |
| **Control 3: Data Protection** | Exfiltration | Exfiltration Over C2 | T1041 |
| **Control 4: Admin Privileges** | Privilege Escalation | Abuse Elevation Control | T1548 |
| **Control 5: Secure Config** | Defense Evasion | Masquerading | T1036 |
| **Control 6: Access Control** | Initial Access | Valid Accounts | T1078 |
| **Control 7: Continuous VM** | All | All Techniques | N/A |
| **Control 8: Audit Logs** | All | All Techniques (Detection) | N/A |
| **Control 9: Email/Web** | Initial Access | Phishing | T1566 |
| **Control 10: Malware Defenses** | Execution | User Execution | T1204 |
| **Control 11: Data Recovery** | Impact | Data Encrypted for Impact | T1486 |
| **Control 12: Network Infrastructure** | Lateral Movement | Remote Services | T1021 |
| **Control 13: Network Monitoring** | Command & Control | Application Layer Protocol | T1071 |
| **Control 14: Security Awareness** | Initial Access | Phishing | T1566 |
| **Control 15: Service Provider** | Initial Access | Supply Chain Compromise | T1195 |
| **Control 16: Application Security** | Execution | Command and Scripting Interpreter | T1059 |

### 6.2 CIS Controls → SABSA

| CIS Control | SABSA Layer | SABSA Element |
|-------------|-------------|---------------|
| Control 1: Inventory | Contextual | Asset Inventory |
| Control 2: Secure Config | Logical + Physical | Security Configuration |
| Control 3: Data Protection | Logical | Data Security |
| Control 4: Admin Privileges | Logical | Identity & Access |
| Control 5: Secure Config | Physical | Hardening |
| Control 6: Access Control | Logical | Identity & Access |
| Control 7: Continuous VM | Physical | Vulnerability Management |
| Control 8: Audit Logs | Operational | Monitoring |
| Control 9: Email/Web | Logical | Application Security |
| Control 10: Malware Defenses | Physical | Endpoint Security |
| Control 11: Data Recovery | Operational | Business Continuity |
| Control 12: Network Infrastructure | Physical | Network Security |
| Control 13: Network Monitoring | Operational | Detection |
| Control 14: Security Awareness | Operational | Training |
| Control 15: Service Provider | Contextual | Supply Chain |
| Control 16: Application Security | Logical | Application Security |

---

## 7. OWASP API Top 10 → MITRE ATT&CK Mapping

| OWASP API Vulnerability | MITRE Tactic | MITRE Technique | Technique ID |
|-------------------------|--------------|-----------------|--------------|
| API1: Broken Object Level Auth | Initial Access | Valid Accounts | T1078 |
| API2: Broken Authentication | Initial Access | Exploit Public-Facing App | T1190 |
| API3: Excessive Data Exposure | Exfiltration | Exfiltration Over C2 | T1041 |
| API4: Lack of Resources & Rate Limiting | Impact | Network Denial of Service | T1498 |
| API5: Broken Function Level Auth | Privilege Escalation | Abuse Elevation Control | T1548 |
| API6: Mass Assignment | Initial Access | Exploit Public-Facing App | T1190 |
| API7: Security Misconfiguration | Defense Evasion | Modify Cloud Infrastructure | T1578 |
| API8: Injection | Execution | Command and Scripting Interpreter | T1059 |
| API9: Improper Asset Management | Defense Evasion | Masquerading | T1036 |
| API10: Insufficient Logging & Monitoring | All | All Techniques (Detection) | N/A |

---

## 8. NIST SP 800-207 Zero Trust → MITRE ATT&CK

| Zero Trust Principle | MITRE Tactic | MITRE Technique | Technique ID |
|----------------------|--------------|-----------------|--------------|
| Continuous Verification | Initial Access | Valid Accounts | T1078 |
| Continuous Verification | Credential Access | OS Credential Dumping | T1003 |
| Least Privilege | Privilege Escalation | Abuse Elevation Control | T1548 |
| Least Privilege | Lateral Movement | Remote Services | T1021 |
| Assume Breach | All | All Techniques | N/A |
| Micro-segmentation | Lateral Movement | Remote Services | T1021 |
| Micro-segmentation | Lateral Movement | Use Alternate Authentication | T1550 |
| Encrypt Everything | Exfiltration | Exfiltration Over C2 | T1041 |

---

## 9. Control Implementation Status Matrix

| Control ID | Control Name | Framework | Status | Owner | Due Date |
|------------|--------------|-----------|--------|-------|----------|
| GV-001 | Information Security Policy | NIST CSF | In Progress | CISO | Q3 2026 |
| GV-002 | Risk Management Strategy | NIST CSF | In Progress | Lead Architect | Q3 2026 |
| ID-001 | Asset Inventory | NIST CSF | In Progress | Lead Architect | Q3 2026 |
| ID-002 | Risk Assessment | NIST CSF | In Progress | Lead Architect | Q3 2026 |
| PR-001 | Access Control | NIST CSF | Complete | Lead Architect | Q2 2026 |
| PR-002 | MFA Enforcement | NIST CSF | In Progress | Lead Architect | Q3 2026 |
| PR-003 | Data Encryption | NIST CSF | Complete | Lead Architect | Q2 2026 |
| PR-004 | Network Segmentation | NIST CSF | In Progress | Lead Architect | Q3 2026 |
| DE-001 | SIEM Implementation | NIST CSF | Planned | Detection Engineer | Q4 2026 |
| DE-002 | Detection Rules | NIST CSF | Planned | Detection Engineer | Q4 2026 |
| RS-001 | Incident Response Plan | NIST CSF | Planned | IR Manager | Q4 2026 |
| RC-001 | BCP Implementation | NIST CSF | Planned | Lead Architect | Q1 2027 |
| A.5.1 | Information Security Policy | ISO 27001 | In Progress | CISO | Q3 2026 |
| A.5.15 | Access Control Policy | ISO 27001 | Complete | Lead Architect | Q2 2026 |
| A.5.17 | Authentication | ISO 27001 | In Progress | Lead Architect | Q3 2026 |
| A.5.18 | Privileged Access Rights | ISO 27001 | In Progress | Lead Architect | Q3 2026 |
| A.5.54 | Backup and Recovery | ISO 27001 | Planned | Lead Architect | Q4 2026 |
| A.5.55 | Cryptographic Controls | ISO 27001 | Complete | Lead Architect | Q2 2026 |
| T1078 | Valid Accounts | MITRE ATT&CK | Complete | Lead Architect | Q2 2026 |
| T1003 | OS Credential Dumping | MITRE ATT&CK | In Progress | Lead Architect | Q3 2026 |
| T1486 | Data Encrypted for Impact | MITRE ATT&CK | Planned | Lead Architect | Q4 2026 |
| T1190 | Exploit Public-Facing App | MITRE ATT&CK | In Progress | Lead Architect | Q3 2026 |

---

## 10. Compliance Reporting Templates

### 10.1 NIST CSF 2.0 Report Template

```markdown
# NIST CSF 2.0 Compliance Report

## Summary
- **Organization**: Nexus Global Industries
- **Report Date**: YYYY-MM-DD
- **Compliance Score**: XX%

## Function Scores

| Function | Score | Status |
|----------|-------|--------|
| Govern | XX% | Status |
| Identify | XX% | Status |
| Protect | XX% | Status |
| Detect | XX% | Status |
| Respond | XX% | Status |
| Recover | XX% | Status |

## Gap Analysis

| Function | Gap | Remediation | Timeline |
|----------|-----|-------------|----------|
| | | | |

## Recommendations
1. Recommendation 1
2. Recommendation 2
```

### 10.2 ISO 27001 SoA Summary Template

```markdown
# ISO 27001 Statement of Applicability Summary

## Implementation Status

| Status | Count | Percentage |
|--------|-------|------------|
| Implemented | XX | XX% |
| In Progress | XX | XX% |
| Planned | XX | XX% |
| Not Applicable | XX | XX% |
| **Total** | **78** | **100%** |

## Control Gaps

| Control ID | Control Name | Gap | Remediation | Owner |
|------------|--------------|-----|-------------|-------|
| | | | | |

## Next Steps
1. Complete implementation of Annex A controls
2. Conduct internal audit
3. Schedule certification audit
```

### 10.3 MITRE ATT&CK Coverage Matrix

```markdown
# MITRE ATT&CK Coverage Report

## Coverage by Tactic

| Tactic | Covered | Total | Percentage |
|--------|---------|-------|------------|
| Reconnaissance | X | Y | Z% |
| Resource Development | X | Y | Z% |
| Initial Access | X | Y | Z% |
| ... | ... | ... | ... |

## Gap Analysis

| Technique | Tactic | Gap | Remediation |
|-----------|--------|-----|-------------|
| | | | |

## Recommendations
1. Implement detection for uncovered tactics
2. Enhance coverage for high-risk techniques
3. Regular review and update of detection rules
```

---

## 11. Control Mapping Verification Checklist

| Check | Status | Notes |
|-------|--------|-------|
| [ ] All NIST CSF controls mapped to SABSA | ☐ | |
| [ ] All ISO 27001 controls mapped to NIST CSF | ☐ | |
| [ ] All MITRE ATT&CK techniques mapped to controls | ☐ | |
| [ ] All OWASP API Top 10 vulnerabilities mapped | ☐ | |
| [ ] All Zero Trust principles mapped | ☐ | |
| [ ] All CIS controls mapped | ☐ | |
| [ ] Gap analysis complete | ☐ | |
| [ ] Remediation plans documented | ☐ | |
| [ ] Implementation owners assigned | ☐ | |
| [ ] Compliance reporting templates created | ☐ | |

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX C]**

This appendix provides complete control mappings between all frameworks, enabling comprehensive compliance tracking, gap analysis, and audit preparation.
