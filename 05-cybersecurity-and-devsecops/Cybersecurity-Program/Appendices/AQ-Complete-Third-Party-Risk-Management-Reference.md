# Appendix AQ: Complete Third-Party Risk Management Reference

## Overview

This appendix provides comprehensive third-party risk management reference material for the Enterprise Cybersecurity Program. It includes vendor risk frameworks, assessment methodologies, monitoring procedures, and vendor management templates.

---

## AQ.1: Third-Party Risk Management Framework

### AQ.1.1: Risk Management Program

**File:** `third-party-risk/risk-management-framework.md`

```markdown
# Third-Party Risk Management Framework

## 1. Overview

### 1.1 Program Purpose
To identify, assess, monitor, and mitigate risks associated with third-party vendors and suppliers.

### 1.2 Program Scope
- All vendors and suppliers
- All partners and contractors
- All service providers
- All critical dependencies
- Fourth-party risk

### 1.3 Program Objectives
1. **Risk Identification:** Identify vendor risks
2. **Risk Assessment:** Assess vendor security
3. **Risk Mitigation:** Address vendor risks
4. **Risk Monitoring:** Continuously monitor vendors
5. **Risk Reporting:** Report vendor risk status

## 2. Risk Management Process

### 2.1 Process Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         THIRD-PARTY RISK MANAGEMENT PROCESS                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  1. Vendor Identification                                                                    │
│     ├── Identify all vendors                                                                 │
│     ├── Classify by criticality                                                              │
│     └── Document vendor inventory                                                            │
│                                                                                             │
│  2. Risk Assessment                                                                          │
│     ├── Security questionnaire                                                               │
│     ├── Review certifications                                                                 │
│     ├── Assess security controls                                                             │
│     └── Calculate risk score                                                                 │
│                                                                                             │
│  3. Risk Treatment                                                                           │
│     ├── Define security requirements                                                         │
│     ├── Include in contracts                                                                 │
│     ├── Implement controls                                                                   │
│     └── Accept remaining risk                                                                │
│                                                                                             │
│  4. Risk Monitoring                                                                          │
│     ├── Continuous monitoring                                                                │
│     ├── Regular assessments                                                                  │
│     ├── Incident monitoring                                                                  │
│     └── Risk reporting                                                                       │
│                                                                                             │
│  5. Risk Review                                                                              │
│     ├── Annual review                                                                        │
│     ├── Trigger-based review                                                                 │
│     ├── Update risk scores                                                                   │
│     └── Report to stakeholders                                                               │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

## 3. Vendor Classification

### 3.1 Classification Categories

```yaml
# Vendor Classification Categories
vendor_classification:
  critical_vendors:
    description: "Vendors critical to business operations"
    examples:
      - "Cloud providers"
      - "Core applications"
      - "Key suppliers"
    assessment_frequency: "Quarterly"
    risk_threshold: "High"
  
  high_risk_vendors:
    description: "Vendors with access to sensitive data"
    examples:
      - "Data processors"
      - "IT service providers"
      - "Financial services"
    assessment_frequency: "Bi-annually"
    risk_threshold: "Medium-High"
  
  medium_risk_vendors:
    description: "Vendors with moderate access"
    examples:
      - "Professional services"
      - "Non-critical applications"
      - "Facilities services"
    assessment_frequency: "Annually"
    risk_threshold: "Medium"
  
  low_risk_vendors:
    description: "Vendors with minimal access"
    examples:
      - "Supplies vendors"
      - "Limited services"
      - "Non-sensitive providers"
    assessment_frequency: "Annually"
    risk_threshold: "Low"
```

### 3.2 Risk Scoring

```yaml
# Risk Scoring Methodology
risk_scoring:
  factors:
    data_sensitivity:
      weight: 30
      scoring:
        - "Public data: 1-2"
        - "Internal data: 3-4"
        - "Confidential data: 5-7"
        - "Highly Confidential data: 8-10"
    
    access_level:
      weight: 25
      scoring:
        - "No access: 1-2"
        - "Limited access: 3-4"
        - "Full access: 5-7"
        - "Privileged access: 8-10"
    
    criticality:
      weight: 25
      scoring:
        - "Low criticality: 1-2"
        - "Medium criticality: 3-4"
        - "High criticality: 5-7"
        - "Critical to business: 8-10"
    
    security_score:
      weight: 20
      scoring:
        - "Score 80-100: 1-2"
        - "Score 60-79: 3-4"
        - "Score 40-59: 5-7"
        - "Score 0-39: 8-10"
  
  risk_levels:
    critical: "80-100"
    high: "60-79"
    medium: "40-59"
    low: "0-39"
```

---

## AQ.2: Vendor Security Assessment

### AQ.2.1: Assessment Questionnaire

**File:** `third-party-risk/vendor-assessment.md`

```markdown
# Vendor Security Assessment Questionnaire

## 1. Overview

### 1.1 Purpose
To assess vendor security controls and practices.

### 1.2 Instructions
1. Complete all required sections
2. Provide supporting evidence
3. Return by assessment deadline
4. Contact security team for questions

## 2. Vendor Information

### 2.1 Basic Information

```yaml
vendor_information:
  name: "[Vendor Name]"
  address: "[Address]"
  website: "[URL]"
  contact_name: "[Name]"
  contact_email: "[Email]"
  contact_phone: "[Phone]"
  revenue: "[Annual Revenue]"
  employees: "[Number of Employees]"
```

## 3. Security Controls Assessment

### 3.1 Governance and Compliance

```yaml
governance_assessment:
  security_policy:
    question: "Does the vendor have an information security policy?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  incident_response:
    question: "Does the vendor have an incident response plan?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  business_continuity:
    question: "Does the vendor have a business continuity plan?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  certifications:
    question: "What security certifications does the vendor hold?"
    options: ["SOC 2", "ISO 27001", "PCI DSS", "HIPAA", "None"]
    evidence_required: true
```

### 3.2 Access Control

```yaml
access_control_assessment:
  mfa:
    question: "Is MFA required for all system access?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  password_policy:
    question: "Are strong password policies enforced?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  least_privilege:
    question: "Is least privilege access enforced?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  access_review:
    question: "Are regular access reviews conducted?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
```

### 3.3 Data Protection

```yaml
data_protection_assessment:
  encryption_at_rest:
    question: "Is data encrypted at rest?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  encryption_in_transit:
    question: "Is data encrypted in transit?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  data_classification:
    question: "Is data classified based on sensitivity?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  data_retention:
    question: "Are data retention policies enforced?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  data_breach:
    question: "What is the data breach notification timeline?"
    options: ["24 hours", "48 hours", "72 hours", "Other"]
    evidence_required: true
```

### 3.4 Security Operations

```yaml
security_operations_assessment:
  monitoring:
    question: "Is security monitoring implemented?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  vulnerability_scanning:
    question: "Are regular vulnerability scans conducted?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  penetration_testing:
    question: "Are regular penetration tests conducted?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
  
  patching:
    question: "Is there a patch management program?"
    options: ["Yes", "No", "Partial", "Not Applicable"]
    evidence_required: true
```

---

## AQ.3: Vendor Risk Scorecard

### AQ.3.1: Scorecard Template

**File:** `third-party-risk/vendor-scorecard.md`

```markdown
# Vendor Risk Scorecard

## 1. Overview

### 1.1 Vendor Information

| Field | Value |
|-------|-------|
| Vendor Name | [Name] |
| Assessment Date | [Date] |
| Assessor | [Name] |
| Assessment Type | [Initial/Annual/Renewal] |

## 2. Risk Scoring

### 2.1 Score Breakdown

| Category | Weight | Score | Weighted Score |
|----------|--------|-------|----------------|
| Governance | 20% | [Score] | [Score] |
| Access Control | 25% | [Score] | [Score] |
| Data Protection | 25% | [Score] | [Score] |
| Security Operations | 30% | [Score] | [Score] |
| **Total** | **100%** | | **[Score]** |

### 2.2 Risk Category

| Score | Category | Action Required |
|-------|----------|-----------------|
| 80-100 | Critical | Immediate remediation required |
| 60-79 | High | Mitigation plan required |
| 40-59 | Medium | Enhanced monitoring |
| 0-39 | Low | Standard monitoring |

## 3. Findings

### 3.1 Critical Findings

| Finding | Description | Recommendation | Status |
|---------|-------------|----------------|--------|
| F-001 | [Description] | [Recommendation] | [Status] |

### 3.2 High Findings

| Finding | Description | Recommendation | Status |
|---------|-------------|----------------|--------|
| F-002 | [Description] | [Recommendation] | [Status] |

### 3.3 Medium Findings

| Finding | Description | Recommendation | Status |
|---------|-------------|----------------|--------|
| F-003 | [Description] | [Recommendation] | [Status] |

## 4. Remediation Plan

### 4.1 Planned Remediation

| Finding | Action | Owner | Timeline | Status |
|---------|--------|-------|----------|--------|
| F-001 | [Action] | [Owner] | [Date] | [Status] |

## 5. Recommendations

### 5.1 Improvement Recommendations

1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

## 6. Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Assessor | | | |
| Vendor Risk Manager | | | |
| CISO | | | |
```

---

## AQ.4: Vendor Monitoring

### AQ.4.1: Continuous Monitoring

**File:** `third-party-risk/vendor-monitoring.md`

```markdown
# Vendor Continuous Monitoring

## 1. Overview

### 1.1 Monitoring Purpose
To continuously track vendor security posture and identify changes in risk.

### 1.2 Monitoring Frequency

```yaml
monitoring_frequency:
  critical_vendors:
    frequency: "Real-time"
    methods: ["Security Ratings", "Breach Monitoring", "Access Reviews"]
  
  high_risk_vendors:
    frequency: "Weekly"
    methods: ["Security Ratings", "Breach Monitoring"]
  
  medium_risk_vendors:
    frequency: "Monthly"
    methods: ["Security Ratings"]
  
  low_risk_vendors:
    frequency: "Quarterly"
    methods: ["Security Ratings"]
```

## 2. Monitoring Activities

### 2.1 Activity Types

```yaml
monitoring_activities:
  security_rating:
    - "Monitor security rating changes"
    - "Track rating trends"
    - "Alert on significant changes"
  
  breach_monitoring:
    - "Monitor for vendor breaches"
    - "Alert on breach notifications"
    - "Assess impact of breaches"
  
  access_review:
    - "Review vendor access"
    - "Verify access permissions"
    - "Remove unnecessary access"
  
  compliance_check:
    - "Monitor compliance status"
    - "Check certificate validity"
    - "Verify security controls"
```

---

This concludes Appendix AQ: Complete Third-Party Risk Management Reference. This comprehensive reference provides the third-party risk management framework, assessment methodologies, scorecard templates, and monitoring procedures needed to manage vendor risk as part of the Enterprise Cybersecurity Program.
